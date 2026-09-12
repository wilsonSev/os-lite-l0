# OS Lite H0 — памятка преподавателю

## Shell как инструмент / Docker как пользователь

**Продолжительность:** 90 минут

## 1. Цель занятия

К концу пары студент должен уметь:
- ориентироваться в Linux shell;
- находить справку;
- понимать `stdout`, `stderr`, redirects и pipe;
- понимать exit code;
- читать и фильтровать лог;
- собирать небольшой pipeline;
- понимать quoting и command substitution;
- прочитать и запустить готовый Bash-скрипт;
- запустить Docker image;
- понимать на пользовательском уровне, как работает checker.

**Не является целью H0:** полноценно научить программированию на Bash. Полные `if`/`for`, `$1`, `"$@"`, `set -euo pipefail`, debugging Bash, `sed`, `awk` и Dockerfile идут дальше.

---

## 2. Главный принцип занятия

Не проводить пару как каталог команд. Использовать цикл:

```text
проблема → потребность → новая команда/концепция → применение → новая улика → следующая проблема
```

Команды должны появляться из необходимости.

---

## 3. Правило интерактива

Не спрашивать о том, чего студент ещё не мог знать.

Метки:
- **[SHOW]** — новая концепция;
- **[ASK]** — вопрос по уже данной модели;
- **[PREDICT]** — команда набрана, Enter пока не нажимаем;
- **[DEBUG]** — намеренно получаем ошибку и разбираем причину.

---

## 4. Подготовка до занятия

```bash
cd ~/os-lite-l0
./reset-demo
./setup
wc -l logs/myitmo.log
grep -c ' ERROR ' logs/myitmo.log
grep ' ERROR ' logs/myitmo.log \
  | cut -d' ' -f3 \
  | sort \
  | uniq -c \
  | sort -nr

man tail
docker info
docker run --rm hello-world
./check --docker
```

Docker images должны быть загружены заранее. Иметь backup-запись Docker-demo.

Настроить терминал:

```bash
export LC_ALL=C
export TZ=UTC
PS1='demo $ '
clear
```

Также:
- крупный шрифт;
- простой prompt;
- отключить уведомления;
- не показывать git branch;
- проверить ширину длинных pipelines.

---

## 5. Тайминг

| Время | Блок |
|---|---|
| 0–3 | Рамка занятия |
| 3–6 | Финальный результат |
| 6–13 | Навигация и справка |
| 13–20 | stdout / stderr / redirects / pipe |
| 20–26 | Exit codes |
| 26–42 | Инцидент и pipeline |
| 42–50 | Variables / quoting |
| 50–56 | BONUS: globbing + `if` |
| 56–63 | Bash-script как артефакт |
| 63–75 | Docker minimum |
| 75–82 | Checker / CI / callback |
| 82–90 | Q&A / buffer |

---

# 6. 0–3 мин — рамка

Сказать:

> Сегодня Bash для нас не предмет сам по себе. Shell — это инструмент, через который мы будем работать с Linux в течение курса.

Сюжет:

> Представим, что открылась выборность курсов в myITMO. Пользователи жалуются: выбор курса не сохраняется, часть запросов возвращает ошибки. У нас есть Linux-машина и журналы приложения. Попробуем понять, что происходит.

Обязательно:

> Сценарий и данные учебные. Мы не анализируем настоящий production myITMO.

Цель блока: создать вопрос «Как исследовать происходящее, если у нас есть только терминал?»

---

# 7. 3–6 мин — показать финал

```bash
./check --docker
```

Сказать:

> Сейчас это чёрный ящик. В конце занятия вернёмся к этой же команде и восстановим, что произошло.

Уточнить:

> Этот checker — демонстрация механизма проверки, а не healthcheck myITMO.

---

# 8. 6–13 мин — навигация

## Где мы?

```bash
pwd
```

> Shell всегда имеет текущую директорию. `pwd` показывает её.

## Что здесь?

```bash
ls
```

> `ls` показывает содержимое директории.

При необходимости:

```bash
ls -l
```

> `-l` включает подробное представление с метаданными.

Не уходить в `total`, inode, link count и filesystem blocks.

## Переходим в logs

```bash
cd logs
pwd
ls
```

**[ASK]** После `cd logs`:

> Что теперь должен показать `pwd`?

Объяснить:

> `cd` не перемещает файлы. Он меняет current working directory shell.

Вернуться:

```bash
cd ..
```

Коротко показать Tab, ↑, `Ctrl-R`.

---

# 9. Справка

```bash
man ls
```

Внутри показать поиск:

```text
/long
```

Выход:

```text
q
```

Тезис:

> Не обязательно помнить флаг — важно уметь его найти.

Можно упомянуть:

```bash
ls --help
help cd
```

Но не обещать `--help` любой Unix-команде.

---

# 10. SHOULD — job control

```bash
sleep 60
```

**[ASK]**:

> Терминал сломался?

Дальше:

```text
Ctrl-Z
```

```bash
jobs
bg
jobs
fg
```

И:

```text
Ctrl-C
```

Коротко объяснить foreground/background. Сигналы глубоко не разбирать.

---

# 11. 13–20 мин — stdout/stderr

Сначала:

```bash
ls exists.txt missing.txt
```

Показать модель:

```text
stdin  = 0
stdout = 1
stderr = 2
```

## Redirect stdout

```bash
ls exists.txt missing.txt > output.txt
```

**[PREDICT]**:

> Что останется на экране?

Потом:

```bash
cat output.txt
```

Тезис:

> `>` перенаправил stdout, но stderr остался отдельно.

## Redirect stderr

```bash
ls exists.txt missing.txt > output.txt 2> errors.txt
cat output.txt
cat errors.txt
```

Зафиксировать:

```text
>   stdout
2>  stderr
```

## `>` и `>>`

```bash
echo first > output.txt
echo second > output.txt
cat output.txt
```

**[ASK]**:

> Где `first`?

Потом:

```bash
echo first > output.txt
echo second >> output.txt
cat output.txt
```

Тезис:

```text
>  overwrite
>> append
```

## `/dev/null`

```bash
ls missing.txt 2>/dev/null
```

> `/dev/null` — sink для ненужного вывода.

---

# 12. Первый pipe

```bash
cat exists.txt | wc -l
```

Модель:

```text
cat stdout → pipe → wc stdin
```

> Pipe передаёт stdout одной программы на stdin другой.

---

# 13. 20–26 мин — exit codes

```bash
ls missing.txt 2>/dev/null
echo "$?"
```

Модель:

```text
0        — успешное завершение
non-zero — другой исход / ошибка согласно контракту программы
```

Уточнить:

> `$?` содержит status предыдущей завершившейся команды.

## `&&`

```bash
./check && echo 'Можно продолжать'
```

> B выполняется, если A успешна.

## `||`

```bash
./scripts/healthcheck.bash || echo 'Нужно расследование'
```

> B выполняется, если A завершилась неуспешно.

**[ASK]**:

> Почему checker PASS, а healthcheck сообщает проблему?

Ответ: это разные контракты.

---

# 14. 26–42 мин — главный incident

## Большой файл

```bash
cat logs/myitmo.log
```

Через секунду можно `Ctrl-C`.

> Большой лог неудобно читать целиком.

## `less`

```bash
less logs/myitmo.log
```

Показать:

```text
/ERROR
n
q
```

> `less` — интерактивный просмотр большого текста.

## `tail`

```bash
tail logs/myitmo.log
```

> Во время инцидента часто сначала интересуют последние события.

Можно:

```bash
tail -n 3 logs/myitmo.log
```

## `man tail`

Сказать:

> Лог продолжает расти. Хочу видеть новые строки сразу, но не помню флаг.

```bash
man tail
```

Поиск:

```text
/follow
```

Найти `-f, --follow`, выйти `q`.

Тезис:

> Знали задачу — нашли нужный flag.

**Важно:** generator пока не запускать, чтобы цифры расследования оставались детерминированными.

---

# 15. Оставить ERROR

```bash
grep ' ERROR ' logs/myitmo.log
```

> `grep` оставляет строки, соответствующие шаблону.

Regex глубоко не разбирать.

---

# 16. Посчитать ошибки

Набрать, но не Enter:

```bash
grep ' ERROR ' logs/myitmo.log | wc -l
```

**[PREDICT]**:

> Что получит `wc`?

После Enter спросить:

> Это число чего?

Ответ: количество ERROR-строк.

---

# 17. Вытащить endpoint

Показать структуру строки:

```text
2026-09-14T09:00:01Z ERROR endpoint=/enroll status=503 event=db_pool_timeout
```

Поля:

```text
1 timestamp
2 ERROR
3 endpoint=/enroll
4 status=503
5 event=db_pool_timeout
```

Команда:

```bash
grep ' ERROR ' logs/myitmo.log | cut -d' ' -f3
```

Объяснить:
- `-d' '` — delimiter пробел;
- `-f3` — третье поле.

Уточнить:

> Такой `cut` работает, потому что формат учебного лога стабилен.

---

# 18. Частота по endpoint

```bash
grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f3   | sort
```

Потом:

```bash
grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f3   | sort   | uniq -c
```

**[ASK]**:

> Почему перед `uniq` нужен `sort`?

Ответ:

> `uniq` работает с соседними одинаковыми строками.

Финал:

```bash
grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f3   | sort   | uniq -c   | sort -nr
```

Вывод:

> В учебной выборке `/enroll` встречается среди ERROR чаще остальных endpoints.

Не говорить про error rate без denominator.

---

# 19. Какая ошибка общая?

```bash
grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f5   | sort   | uniq -c
```

Получаем `db_pool_timeout`.

Объяснить:

> Connection pool — ограниченный набор соединений к БД. Если все заняты, новый запрос ждёт; если слишком долго — timeout.

Не утверждать, что база «упала». Это пока симптом.

---

# 20. Проверка health

```bash
grep 'endpoint=/health ' logs/myitmo.log
```

**[ASK]**:

> Значит ли это, что БД здорова?

Нет.

Инженерный вывод:

```text
process отвечает
+
DB-dependent requests получают timeout
```

Root cause ещё не доказан.

---

# 21. OPTIONAL — live log

После детерминированного расследования:

```bash
./scripts/generate-log.bash &
GEN_PID=$!
tail -f logs/myitmo.log
```

Показать 5–10 секунд, затем `Ctrl-C`.

**[ASK]**:

> Генератор тоже остановился?

Нет.

```bash
jobs
kill "$GEN_PID"
wait "$GEN_PID"
./reset-demo
```

---

# 22. 42–50 мин — variables и quoting

```bash
file='my log.txt'
```

Набрать:

```bash
cat $file
```

Не Enter.

**[PREDICT]**:

> Как shell передаст это `cat`?

После ошибки:

```bash
cat "$file"
```

Тезис:

> Quoting влияет на то, какие аргументы получит программа.

## Одинарные и двойные

```bash
echo '$file'
echo "$file"
```

```text
'...' — literal
"..." — expansions выполняются
```

## Command substitution

```bash
count=$(grep -c ' ERROR ' logs/myitmo.log)
echo "$count"
```

> `$(...)` запускает команду и подставляет её stdout.

## `export`

```bash
export MODE=demo
```

> `export` делает переменную частью environment дочерних процессов.

---

# 23. 50–56 мин — BONUS: globbing / if

Первый блок на удаление при отставании.

```bash
printf '%s
' fixtures/*.initial
printf '%s
' 'fixtures/*.initial'
```

> В первом случае glob раскрывает shell; во втором `*` защищена кавычками.

Короткий `if`:

```bash
if grep -q ' ERROR ' logs/myitmo.log; then
    echo "Есть ошибки"
fi
```

Тезис:

> `if` в Bash запускает команду и смотрит на её exit status.

Циклы полноценно не преподавать.

---

# 24. 56–63 мин — script как артефакт

```bash
cat scripts/healthcheck.bash
```

Не разбирать весь код построчно.

Показать четыре идеи:

## Shebang

```bash
#!/usr/bin/env bash
```

> Определяет interpreter.

## Script — те же команды

Показать знакомые `grep`, variables, exit codes.

## Собственный exit status

```bash
./scripts/healthcheck.bash
echo "$?"
```

## Executable permission

```bash
ls -l scripts/healthcheck.bash
```

Теперь естественно показать:

```bash
chmod +x scripts/healthcheck.bash
```

> Добавляет право исполнения.

---

# 25. `set -euo pipefail`

На H0 глубоко не разбирать.

Сказать:

> Это более строгий режим выполнения Bash-script. У него есть corner cases, поэтому подробно разберём позже.

Можно показать:

```bash
grep -c ' ERROR ' fixtures/myitmo.log.healthy
echo "$?"
```

Главный вывод:

> stdout и exit status — разные каналы информации.

---

# 26. 63–75 мин — Docker minimum

Начать:

> Сегодня Docker — не отдельная тема. Это инструмент для запуска checker в воспроизводимой Linux-среде.

## Зачем

У студентов Linux/macOS/Windows, разные версии и реализации утилит. Checker должен работать в контролируемой среде.

## Image vs container

```text
image
  ↓ docker run
container
```

> Image — подготовленный шаблон окружения.  
> Container — запущенный экземпляр image.

Не разбирать namespaces/cgroups/Dockerfile/networking.

## Первый run

```bash
docker run --rm hello-world
```

Разобрать:
- `docker run`;
- image `hello-world`;
- `--rm`.

---

# 27. Checker wrapper

```bash
cat check
```

Не разбирать всю Bash-реализацию.

Фокус на:
- `docker run`;
- `--rm`;
- `-v`;
- image.

## Bind mount

```text
HOST                     CONTAINER

./src/       ───────▶    /workspace/src
```

> Код остаётся на host, но виден внутри container.

---

# 28. PASS → FAIL → PASS

```bash
./check --docker
```

PASS.

Потом:

```bash
printf 'broken
' > src/hello.txt
./check --docker
echo "$?"
```

FAIL.

**[ASK]**:

> Нужно ли пересобирать Docker image после изменения `src/hello.txt`?

Нет, потому что `src` монтируется внутрь container.

Вернуть:

```bash
printf 'Hello, OS Lite!
' > src/hello.txt
./check --docker
```

PASS.

---

# 29. SHOULD — debugging container

Если есть время:

```bash
docker ps -a
docker logs <container>
```

Уточнить:

> Если container запускался с `--rm`, после завершения он удалён.

---

# 30. 75–82 мин — финальный callback

Снова:

```bash
./check --docker
```

Попросить студентов восстановить цепочку:

```text
shell
 ↓
./check
 ↓
Bash script
 ↓
docker run
 ↓
image
 ↓
container
 ↓
bind mount src
 ↓
checker
 ↓
exit status
 ↓
PASS / FAIL
```

---

# 31. CI

Одним слайдом:

> Та же идея переносится в CI: локально и на сервере запускается максимально похожая проверка.

Не разбирать CI workflow подробно.

---

# 32. 82–90 мин — Q&A / buffer

Если setup студентов должен быть готов:

```bash
docker run --rm hello-world
```

или repo smoke-check.

Цель — найти проблемы окружения до лабораторной.

---

# 33. Что резать при отставании

## MUST

Не вырезать:
- framing;
- ранний PASS;
- `pwd` / `ls` / `cd`;
- stdout / stderr;
- redirects;
- exit codes;
- основной pipeline;
- quoting trap;
- готовый script;
- Docker image/container;
- bind mount;
- callback.

## SHOULD

Можно сократить:
- `Ctrl-R`;
- подробный `man`;
- job control;
- live generator;
- `/dev/null`;
- `docker ps -a`;
- `docker logs`.

## BONUS

Первым удалить:
- globbing;
- полноценный `if`;
- циклы;
- shellcheck demo;
- дополнительные flags.

---

# 34. Чего сознательно НЕ преподавать на H0

- функции Bash;
- массивы;
- `case`;
- `while`;
- `$1`, `$@`, `$#`;
- полноценные `if`/`for`;
- regex подробно;
- `sed`;
- `awk`;
- глубокий `set -euo pipefail`;
- `/proc`;
- filesystem internals;
- permissions подробно;
- sudo/sudoers;
- Dockerfile;
- Docker networking;
- Docker `exec`;
- namespaces;
- cgroups;
- устройство Docker на macOS;
- глубокое сравнение VM/container.

Архитектура серии:

```text
H0 → shell literacy
следующая пара → shell programming
далее → processes / observation
далее → automation / container internals
```

---

# 35. Типичные ошибки преподавателя

## Объяснять всё, что попало на экран

Если `ls -l` показывает `total 4`, не уходить в filesystem blocks.

## Учить flags списком

Не показывать `ls -a/-l/-h/-R/-t` подряд без потребности.

## Спрашивать prediction слишком рано

Сначала дать модель, потом просить применять.

## Долго чинить demo

Если `man` отсутствует — использовать `tail --help`; Docker упал — backup recording.

## Объявлять симптом root cause

`db_pool_timeout` не означает автоматически «БД упала».

---

# 36. Полезные формулировки

> Не обязательно помнить флаг — важно уметь его найти.

> stdout и exit status — разные вещи.

> Pipe соединяет маленькие программы.

> Shell сначала интерпретирует командную строку, а уже потом запускает программу.

> Quoting влияет на то, какие аргументы получит программа.

> `if` в Bash обычно смотрит на exit status команды.

> Сегодня Docker — инструмент воспроизводимого запуска, а не тема про внутренности контейнеров.

---

# 37. Минимальная шпаргалка преподавателя

```bash
./reset-demo
./check --docker

pwd
ls
cd logs
pwd
ls
cd ..

ls exists.txt missing.txt
ls exists.txt missing.txt > output.txt
cat output.txt
ls exists.txt missing.txt > output.txt 2> errors.txt
cat errors.txt

ls missing.txt 2>/dev/null
echo "$?"
./check && echo "Можно продолжать"
./scripts/healthcheck.bash || echo "Нужно расследование"

cat logs/myitmo.log
less logs/myitmo.log
tail logs/myitmo.log
man tail
# /follow
# q

grep ' ERROR ' logs/myitmo.log
grep ' ERROR ' logs/myitmo.log | wc -l

grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f3   | sort   | uniq -c   | sort -nr

grep ' ERROR ' logs/myitmo.log   | cut -d' ' -f5   | sort   | uniq -c

grep 'endpoint=/health ' logs/myitmo.log

file='my log.txt'
cat $file
cat "$file"
echo '$file'
echo "$file"

count=$(grep -c ' ERROR ' logs/myitmo.log)
echo "$count"

./scripts/generate-log.bash &
GEN_PID=$!
tail -f logs/myitmo.log
# Ctrl-C
jobs
kill "$GEN_PID"
wait "$GEN_PID"
./reset-demo

cat scripts/healthcheck.bash
./scripts/healthcheck.bash
echo "$?"

docker run --rm hello-world
cat check
./check --docker

printf 'broken
' > src/hello.txt
./check --docker
echo "$?"

printf 'Hello, OS Lite!
' > src/hello.txt
./check --docker
```

---

# 38. Критерий успешной пары

Студент не обязан после H0 написать Bash-script с нуля.

Он должен быть способен сказать:

> Я могу зайти в shell, понять, где нахожусь, найти справку, посмотреть и отфильтровать лог, соединить команды через pipe, понять успех команды по exit code, аккуратно работать с quoting, запустить готовый script и воспользоваться Docker-checker.

Это и есть **shell literacy**, необходимая перед полноценным shell programming.

---

# 39. Главное правило преподавателя

> **Не объяснять команду потому, что она существует. Сначала создать задачу, для которой эта команда становится естественным следующим шагом.**
