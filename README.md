# Like a native

An AI-based (GPT) spelling and grammar corrector that transforms user input to sound
like a native speaker, with minimal style alterations.

This tool is ideally suited for scenarios where your understanding of a foreign
language has surpassed the point requiring an automated translator, you desire
to sound authentic, and yet, you still make those minor errors which are so
obvious to any native speaker.

## Status

Stable. Not distributed. Installing from the source is straightforward and
described below, but requires a little bit of a "hands-on" approach.

## Pre-requisites

Obtain an [OpenAI API key](https://platform.openai.com/account/api-keys).

OpenAI API key should be available in the `OPENAI_API_KEY` env var. E.g., add
this to your `~./zshrc` file:

    export OPENAI_API_KEY="sk-..."

The tool uses the "GPT-4o mini" model, which is the cheapest at the time of
this writing. Be aware of the [prices](https://openai.com/api/pricing/) you
incur by using the tool with your token.

## Build

    swift build

## Usage

The application is a command line tool. When run, it replaces the text in the
clipboard with a corrected version.

For instance, to execute in the command line directly from the source directory:

    swift run LikeNativeCLI --lang LANG

where `LANG` is a common name of any language GPT4 might know well. E.g.,
"French", "German", etc.

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

### Mistakes

Beware that this tool uses the "GPT-4o mini" model and can make mistakes, such
as providing inconsistent responses or refusing to correct the text. In this
case, you will receive the tool's output back to the clipboard.

### Tutor mode

Pass the `--tutor` flag to enable "Tutor" mode. In this case, the tool will
provide an explanation of the changes made to the source text.

## Implementation. Prompt engineering.

Technically, you can adjust the GPT prompt to carry out any sort of edits or
corrections to the text in the clipboard. Tweak the `promptTemplate` as
required. Please feel free to submit your prompts via GitHub issues.
