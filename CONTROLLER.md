# controller pins

arduino sends `{"pin": N, "on": true/false}` over UDP port 4242

| pin | physical input | on=true       | on=false      |
|-----|---------------|---------------|---------------|
| 2   | shiny switch  | shiny home    | shiny left    |
| 3   | fluffy switch | fluffy home   | fluffy left   |
| 4   | door sensor   | door closed   | door open     |
