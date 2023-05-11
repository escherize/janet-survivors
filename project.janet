(declare-project
 :name "janet survivors"
 :description "Some kind of game"
 :dependencies ["https://github.com/janet-lang/jaylib.git"])

(declare-executable
 :name "janet_survivors"
 :entry "main.janet"
 :install true)
