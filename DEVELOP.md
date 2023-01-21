## running locally
make a fakezod using part one of this guide: https://www.ajlamarc.com/blog/2022-11-19-urbit-setup/ and configure it to recognize an urbhue desk.

```hoon
~zod:dojo> |commit %base
~zod:dojo> |new-desk %urbhue
~zod:dojo> |mount %urbhue
~zod:dojo> |exit
```

Watch this desk into zod:
```bash
~/urbit$ watch cp -LR hue/desk/* zod/urbhue/
```

Start up agent:
```hoon
~zod:dojo> |commit %urbhue
~zod:dojo> |install our %urbhue
~zod:dojo> :hue +dbug
```

Start up frontend
```bash
~/urbit/hue/ui$ npm i && npm run dev
```
Ensure you are logged in, should be good to go after that!