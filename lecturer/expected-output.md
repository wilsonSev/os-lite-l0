# Контрольные результаты и текстовый план Б

После остановки генератора и `./reset-demo`:

| Команда | Результат |
|---|---|
| `wc -l < logs/myitmo.log` | 10000 |
| `grep -c ' ERROR ' logs/myitmo.log` | 5, код 0 |
| `grep -c ' ERROR ' fixtures/myitmo.log.healthy` | 0, код 1 |
| `./scripts/healthcheck.bash` | stderr: `FAIL: ERROR events found in log`, код 1 |
| `./scripts/healthcheck.bash fixtures/myitmo.log.healthy` | stdout: `OK: no ERROR events in log`, код 0 |
| `./scripts/healthcheck.bash missing.txt` | stderr: `UNKNOWN: log must be a readable nonempty file`, код 2 |
| `./check` при исходном src | `PASS (demo): src/hello.txt matches the expected line`, код 0 |

Конвейер с `LC_ALL=C`:

```text
3 endpoint=/enroll
1 endpoint=/schedule
1 endpoint=/courses
```

Перед числами `uniq -c` может добавлять отступы. Текст ошибок `ls` и его точный
ненулевой код отличаются между ОС. Проверяйте разделение потоков и ненулевой
статус, а не дословную ошибку. PID, время, пути и вывод Docker зависят от машины.

План Б: если Docker недоступен, явно сказать об этом, показать команду из `check`,
этот эталон и локальный запуск. Это иллюстрирует контракт, но не доказывает
работоспособность Docker. До пары отдельно сохранить запись успешного
`./check --docker` и `hello-world` на машине ведущего.

Дополнительный конвейер по пятому полю ERROR возвращает:

```text
5 event=db_pool_timeout
```

`cat "my log.txt"` показывает две строки метрик и заметку об общем пуле:

```text
2026-09-14T08:59:50Z component=db_pool active=4 limit=20 waiting=0 incoming_rps=15
2026-09-14T09:00:00Z component=db_pool active=20 limit=20 waiting=180 incoming_rps=800
Diagnostic note: /courses, /enroll and /schedule share this pool; /health does not use the database.
```

Сюжетный вывод: при открытии выбора курсов заняты все 20 соединений с БД,
180 запросов ждут. Запросы завершаются `db_pool_timeout`, поэтому выбор курса
и загрузка расписания не работают. `/health` успешен, поскольку не использует БД.
Рост нагрузки виден в метриках, но для причины долгой занятости соединений
нужны данные о запросах, блокировках и освобождении соединений. Этот снимок
относится к исходному вымышленному инциденту и не обновляется генератором.
