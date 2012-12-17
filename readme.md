# What's this

This is an extremely simple Menu bar application that controls apache in Mountain Lion because of the removal of the Web Sharing preference.

### How does it work?

This application uses a somewhat hacky way to deal with administrator shell commands using AppleScript in this format 

```
do shell script \"apachectl start\" with administrator privileges
```
