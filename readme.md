# What's this?

This is an extremely simple Menu bar application that controls apache in Mountain Lion because of the removal of the Web Sharing preference.

## Continuing development

At the moment I don't have any major future development plans for Web Sharing. I will try to fix any bugs submitted and I will accept pull requests through Github.

### How does it work?

This application uses a somewhat hacky way to deal with administrator shell commands using AppleScript in this format `do shell script \"apachectl start\" with administrator privileges`

Web sharing uses [Sparkle](https://github.com/andymatuschak/Sparkle) for automatic updates
