# hue

## running locally
make a fakezod using part one of this guide: https://www.ajlamarc.com/blog/2022-11-19-urbit-setup/ and configure it to recognize a hue desk.

```hoon
~zod:dojo> |commit %base
~zod:dojo> |new-desk %hue
~zod:dojo> |mount %hue
~zod:dojo> |exit
```

Watch this desk into zod:
```bash
~/urbit$ watch cp -LR hue/desk/* zod/hue/
```

Start up agent:
```hoon
~zod:dojo> |commit %hue
~zod:dojo> |install our %hue
~zod:dojo> :hue +dbug
```

Start up frontend
```bash
~/urbit/hue/ui$ npm i && npm run dev
```
Ensure you are logged in, should be good to go after that!

## Debugging

If controlling the bulbs becomes permanently corrupted,
start by unlinking the bridge from UrbHue / urbhue.
There is a link for this in the `logs` tab of the application.

Then hard restart the agent:
```hoon
~zod:dojo> |nuke %hue
~zod:dojo> |rein %hue [& %hue]
```

Then you should be prompted to redo the setup process on the frontend.