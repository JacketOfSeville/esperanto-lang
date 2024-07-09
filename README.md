# Esperanto Lang

Convert the near incomprehensible language of **[Esperanto](https://en.wikipedia.org/wiki/Esperanto)** to the other near incomprehensible language of **JavaScript**

---

## Requirements

- GNU Lex ``>> flex``
- GNU Bison ``>> bison``
- Yacc

---

## Tokens

| Source  | Output       |
| ------- | ------------ |
| ``LASU``    | ``let``          |
| ``SE``      | ``if``           |
| ``ALIE``    | ``else``         |
| ``DUM``     | ``while``        |
| ``POR``     | ``for``          |
| ``PRESI``   | ``console.log``  |
| ``FUNKCIO`` | ``function``     |
| ``REVENI``  | ``return``       |
| ``NE``      | ``!``            |
| ``-*-``     | ``// (Comment)`` |

---

## Using the compiler in CLI

```bash
#!/bin/bash
flex translator.l
bison -d translator.y
gcc lex.yy.c translator.tab.c -o translator -lfl
./translator test.epo > output.js
```

```powershell
#powershell
flex translator.l
bison -d translator.y
gcc lex.yy.c translator.tab.c -o translator -lfl
.\translator.exe test.epo > output.js
```

---
