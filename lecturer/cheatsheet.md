# H0: шпаргалка преподавателя и студента

Все команды — из корня площадки в Bash. Точные числа — после `./reset-demo`.

```bash
pwd
ls -la
cd logs
cd ..
man grep                    # q — выход; / — поиск
man -k directory            # база справки может отсутствовать
# Tab — дополнение; ↑ — история; Ctrl-R — поиск; Ctrl-C — прервать

ls exists.txt missing.txt > output.txt 2> errors.txt
cat output.txt
cat errors.txt
echo again >> output.txt
ls missing.txt 2>/dev/null
echo "$?"                    # читать сразу после проверяемой команды
./check && echo 'Можно продолжать'
./scripts/healthcheck.bash || echo 'Нужно расследование'

tail logs/myitmo.log
grep ' ERROR ' logs/myitmo.log | wc -l
grep ' ERROR ' logs/myitmo.log \
  | cut -d' ' -f3 | sort | uniq -c | sort -nr | head -n 3

# Все ошибки имеют одну причину ожидания:
grep ' ERROR ' logs/myitmo.log | cut -d' ' -f5 | sort | uniq -c

file='my log.txt'
cat "$file"
echo '$file'
echo "$file"
count=$(grep -c ' ERROR ' logs/myitmo.log)
echo "$count"
export LC_ALL=C TZ=UTC

./scripts/generate-log.bash &
GEN_PID=$!
jobs
tail -f logs/myitmo.log
# Ctrl-C останавливает tail; затем:
kill "$GEN_PID"
wait "$GEN_PID"
./reset-demo

./scripts/healthcheck.bash fixtures/myitmo.log.healthy
./check
./check --docker            # требует подготовленного Docker и образа
```

Ctrl-Z приостанавливает foreground job; `jobs` показывает задания текущей
оболочки; `bg` продолжает в фоне; `fg` возвращает на передний план. Эти команды
демонстрируйте на `sleep 60`, после `fg` завершите его Ctrl-C.
`less logs/myitmo.log` — просмотр, q — выход (если less установлен).

`>` перезаписывает, `>>` дописывает, `2>` перенаправляет stderr, `|` передаёт
stdout следующей команде. В обычном Bash код конвейера — код последней команды;
`pipefail` разбирается на следующей паре. Кавычки сохраняют пробелы внутри аргумента.
