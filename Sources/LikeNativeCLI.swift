import AppKit
import ArgumentParser
import Foundation
import OpenAI

@main
@available(macOS 12, *) // to properly parse the options with async run function
struct LikeNative: AsyncParsableCommand {
    @Option var lang: String = "French"

    mutating func run() async throws {
        let pasteboard = NSPasteboard.general
        if let input = pasteboard.string(forType: .string) {
            let corrector = newCorrector(lang: self.lang)
            let output = await corrector?.correct(text: input) ?? input
            pasteboard.clearContents()
            pasteboard.setString(output, forType: .string)
        }
    }
}

func fail(msg: String) {
    print("ERROR: \(msg)")
    exit(1)
}

@available(macOS 10.15, *) // to use GPT4Corrector
func newCorrector(lang: String) -> Corrector? {
    // return DoNothingCorrector(lang: self.lang)
    if let token = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
        return GPT4Corrector(apiToken: token, lang: lang)
    } else {
        fail(msg: "cannot find OPENAI_API_KEY env var")
        return nil
    }
}

class Corrector {
    var lang: String

    init(lang: String) {
        self.lang = lang
    }

    func correct(text: String) async -> String {
        fatalError("func 'correct' is not implemented")
    }
}

@available(macOS 10.15, *)
class GPT4Corrector: Corrector {
    private static let promptTemplate = """
        You are the grammar and spelling corrector. The user has written a text in %@, and they are not a native %@ speaker. Your task is to rephrase the text to sound like a native speaker would. The rules are:
        * Maintain the original meaning of the message. Preserve the user's writing style as much as possible. If the input is an informal speach like often used in a chat - keep the informal style. If the input is obviously formal - keep the formal style. If the input is already correct - no need to change or make it better.
        * Introduce as few changes as necessary.
        * Only modify the message if something is significantly different from how a native speaker would express it, or if there's a mistake.
        * Output only the corrected result, with no additional comments or remarks.
        * If the text includes both English and %@ (e.g., technical terms in English), retain the original English words.
        * Do not introduce or remove any line breaks.
        """

    private var apiToken: String

    init(apiToken: String, lang: String) {
        self.apiToken = apiToken
        super.init(lang: lang)
    }

    override func correct(text: String) async -> String {
        let openAI = OpenAI(apiToken: self.apiToken)
        let prompt = String(format: GPT4Corrector.promptTemplate, self.lang, self.lang, self.lang)
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: prompt)!,
                .init(role: .user, content: text)!,
            ], model: .gpt4_o_mini)
        do {
            let result = try await openAI.chats(query: query) // requires macOS 10.15
            // FIXME: better error handling
            return result.choices[0].message.content?.string ?? text
        } catch {
            return text
        }
    }
}

class DoNothingCorrector: Corrector {
    override func correct(text: String) async -> String {
        return text
    }
}
