import AppKit
import ArgumentParser
import Foundation
import OpenAI

let promptTemplate = """
    You are the grammar and spelling corrector. User wrote a text in %@. User is not a native %@ speaker.
    Your task is to rephrase the text and make it sound like a native speaker would say it. The rules are:
    - Keep the same meaning of the original message. As much as possible preserve the users writing style.
    - Introduce as few changes as possible.
    - Only change the message when something is very different from how a native speaker would say it, or if there is an error.
    - Only output the result and nothing else. Do not add any other remarks.
    - If the text is obviously mixed English and %@ (e.g., contains technical terms in English), keep the original English words.
    - Do not introduce or remove new lines.
    """

@main
@available(macOS 12, *)
struct LikeNative: AsyncParsableCommand {
    @Option var lang: String = "French"

    mutating func run() async throws {
        let pasteboard = NSPasteboard.general
        if let input = pasteboard.string(forType: .string) {
            let token = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!
            let openAI = OpenAI(apiToken: token)

            let prompt = String(format: promptTemplate, self.lang, self.lang, self.lang)
            let query = ChatQuery(
                messages: [
                    .init(role: .system, content: prompt)!,
                    .init(role: .user, content: input)!,
                ], model: .gpt4)
            let result = try await openAI.chats(query: query)
            let output = result.choices[0].message.content!.string!
            pasteboard.clearContents()
            pasteboard.setString(output, forType: .string)
            print(output)
            print("\n--\nAbove output is now in the pasteboard")
        } else {
            print("Nothing in the pasteboard")
        }
    }
}
