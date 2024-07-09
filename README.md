# esperanto

$ flex translator.l
$ bison -d translator.y
$ gcc lex.yy.c translator.tab.c -o translator -lfl
$ ./translator < example.epo
$ ./translator example.epo > output.rb
