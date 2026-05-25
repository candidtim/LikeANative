# Like a native

AI spelling and grammar corrector. Improves phrasing with minimal style
alterations. This is a macOS CLI app.

For a linux desktop app see https://github.com/candidtim/likeanative-nix .

## Status

Stable. Not distributed. Install from source.

## Pre-requisites

- [OpenAI API key](https://platform.openai.com/account/api-keys)

## Build

    swift build

## Usage

The application is a command line tool. When run, it replaces the text in the
clipboard with a corrected version.

For instance, to execute in the command line directly from the source directory:

    swift run LikeNativeCLI --lang LANG

where `LANG` is a common name of any language GPT4 might know well. E.g.,
"French", "German", etc.

AI can make mistakes, verify outputs before hitting "Enter" in Slack.

### Keyboard shortcut

You can set up a keyboard shortcut to run the tool. A typical scenario is:
write some text (in a chat or an email, etc.), select and copy it to the
clipboard (`⌘-A`, `⌘-C`), use the keyboard shortcut to correct it, then paste
the corrected text back in place of the previous selection (`⌘-V`). Neat!

1. Create an Automator Service:

   - Open Automator from Applications
   - Choose "Quick Action" as the document type
   - In the workflow area, change "Workflow receives current" to "no input"
   - Search for "Run Shell Script" in the actions list and drag it into the
     workflow area
   - The shell command should pass the API key in an environment variable, and
     then run the built binary. Keep the `&` at the end. See the example below.
   - Save the workflow with a name like "Like a native".

Example Automator command:

    OPENAI_API_KEY="sk-..." /Users/me/like-a-native/.build/arm64-apple-macosx/debug/LikeNativeCLI --lang French &

2. Assign a Keyboard Shortcut:

   - Open System Settings > Keyboard > Keyboard Shortcuts
   - Go to Services and find your saved Automator workflow under the "General"
     section
   - Assign a custom keyboard shortcut to it

Naturally, you can set up multiple keyboard shortcuts, each for a different language.

When you use the keyboard shortcut, a cog icon will appear in the system menu
bar, and then disappear once the text is corrected.

### Tutor mode

Pass the `--tutor` flag to enable "Tutor" mode. In this case, the tool will
provide an explanation of the changes made to the source text.

## License

MIT License
