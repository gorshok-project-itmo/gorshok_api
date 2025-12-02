# API doc

## Auth

### Регистрация

**Endpoint:**
`POST /signup`

**Body:**
```
{
    "user": {
        "email": "test@example.com",
        "password": "121212"
    } 
}
```

Ответ:

```
{"status":{"code":200,"message":"Signed up successfully.","token":"eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIzMDEyZTkxMi1iNTc5LTRhNjEtYTMwMy1kOTJiYzYwY2ZhMjMiLCJzdWIiOiI2Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzY0Njc1MDkyLCJleHAiOjE3NjQ3MTM0OTJ9.VcF4Ej9lQ56y-4BVFcWIcDFDEIvoxa8xeFudjognn1s","data":{"id":6,"email":"test@example.com"}}}
```
### Вход
**Endpoint:**
`POST /login`

**Body:**
```
{
    "user": {
        "email": "test@example.com",
        "password": "121212"
    } 
}
```

Ответ:

```
{"status":{"code":200,"message":"Logged in successfully.","token":"eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIzMDEyZTkxMi1iNTc5LTRhNjEtYTMwMy1kOTJiYzYwY2ZhMjMiLCJzdWIiOiI2Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzY0Njc1NDM2LCJleHAiOjE3NjQ3MTM4MzZ9.zWLeyh_fV6eLd5j6RTMaVuaZIj0xHXCrSZqT7pb-AOw","data":{"user":{"id":6,"email":"test@example.com"}}}}
```
### Выход
**Endpoint:**
`DELETE /logout`

**Headers:**
```
Authorization: Bearer <token>
```
Ответ:

```
{
    "status": 200,
    "message": "Logged out successfully."
}
```

### Plant
**Endpoint:**
`POST /plants`

**Body:**
```
    "plant": {
      "humidity_soil": 68,
      "humidity_env": 47,
      "temperature_env": 24
    }
```

Ответ:

```
{"id":2,"humidity_soil":68.0,"humidity_env":47.0,"temperature_env":24.0,"created_at":"2025-12-02T11:52:29.072Z","updated_at":"2025-12-02T11:52:29.072Z"}
```

**Endpoint:**
`Get /plants`
Это получить все растения 

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:

```
{"id":2,"humidity_soil":68.0,"humidity_env":47.0,"temperature_env":24.0,"created_at":"2025-12-02T11:52:29.072Z","updated_at":"2025-12-02T11:52:29.072Z"}
```

**Endpoint:**
`Get /plants/:id`
тут id это id самого растения 

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:

```
{"id":2,"humidity_soil":68.0,"humidity_env":47.0,"temperature_env":24.0,"created_at":"2025-12-02T11:52:29.072Z","updated_at":"2025-12-02T11:52:29.072Z"}
```

### Обновление растения 
**Endpoint:**
`PUT/PATCH /plants/:id`
Тут PUT - полное обновление(как показано ниже), PATCH - частичное обновление 

**Body:**
```
{
    "plant": {
      "humidity_soil": 72,
      "humidity_env": 49,
      "temperature_env": 25
    }
  }
```
Ответ:

```
{"humidity_soil":72.0,"humidity_env":49.0,"temperature_env":25.0,"id":2,"created_at":"2025-12-02T11:52:29.072Z","updated_at":"2025-12-02T12:07:12.663Z"}
```
### Удаление растения 
**Endpoint:** 
`DELETE /plants/:id`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:

```
204 No Content
```

### Получить статистику растений за последние 24 часа 
**Endpoint:** 
`GET /plants/stats`
stats - анализирует данные за последние 24 часа от текущего времени.

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:

```
{"total_records":1,"avg_soil_humidity":72.0,"avg_env_humidity":49.0,"avg_temperature":25.0,"max_temperature":25.0,"min_temperature":25.0}
```

## Devices
Все endpoints Devices требуют аутентификации пользователя через JWT токен.
### Создать
**Endpoint:** 
Это создание устройства 
`POST /devices`

**Body:**
```
    "device": {
      "name": "mydevice",
      "mode": "automatic",
      "interval_hours": 12,
      "duration_minutes": 10,
      "humidity_threshold": 40.5,
      "water_level": 100.0
    }
```
Ответ:

```
{"id":2,"name":"mydevice","mode":"automatic","interval_hours":12,"duration_minutes":10,"humidity_threshold":40.5,"next_watering":null,"water_level":100.0,"user_id":6,"created_at":"2025-12-02T12:32:06.040Z","updated_at":"2025-12-02T12:32:06.040Z"}
```

## Получить все устройства пользователя
**Endpoint:** 
`GET /devices`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:

```
[{"id":2,"name":"mydevice","mode":"automatic","interval_hours":12,"duration_minutes":10,"humidity_threshold":40.5,"next_watering":null,"water_level":100.0,"user_id":6,"created_at":"2025-12-02T12:32:06.040Z","updated_at":"2025-12-02T12:32:06.040Z"}]
```

## Получить конкретное устройство пользователя
**Endpoint:** 
`GET /devices/:id`
тут id - id устройства 

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"id":2,"name":"mydevice","mode":"automatic","interval_hours":12,"duration_minutes":10,"humidity_threshold":40.5,"next_watering":null,"water_level":100.0,"user_id":6,"created_at":"2025-12-02T12:32:06.040Z","updated_at":"2025-12-02T12:32:06.040Z"}
```

## Обновить устройство
**Endpoint:**
`PUT/PATCH /devices/:id`   

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"user_id":6,"mode":"manual","water_level":75.0,"interval_hours":12,"duration_minutes":10,"humidity_threshold":40.5,"id":2,"name":"mydevice","next_watering":null,"created_at":"2025-12-02T12:32:06.040Z","updated_at":"2025-12-02T12:41:51.814Z"}
```

## Получить статус полива устройства
**Endpoint:**
`GET /devices/:id/watering_status` 

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"device_name":"mydevice","mode":"manual","next_watering":null,"water_level":75.0,"humidity_threshold":40.5,"needs_watering":true}
```
## Получить статус полива устройства
**Endpoint:**
`POST /devices/:id/trigger_watering`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"message":"Watering triggered for mydevice","duration":10,"started_at":"2025-12-02T12:57:27.762Z","estimated_finish":"2025-12-02T13:07:27.762Z","water_level_before":75.0,"water_level_after":70.0}
```
## Получить сводку по всем устройствам пользователя
**Endpoint:**
`GET /devices/summary`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"total_devices":1,"devices_by_mode":{"manual":1},"average_water_level":70.0,"low_water_devices":0,"next_watering_devices":0}
```
## Создать расписание для устройства
**Endpoint:**
`POST /devices/:device_id/watering_schedules`

**Body:**
```
'{
    "watering_schedule": {
      "day_of_week": "friday",
      "start_time": "09:30",
      "end_time": "09:45",
      "active": true
    }
}
```
Ответ:
```
{"id":3,"device_id":2,"day_of_week":"friday","start_time":"09:30","end_time":"09:45","active":true,"created_at":"2025-12-02T13:06:48.111Z","updated_at":"2025-12-02T13:06:48.111Z"}
```

## Получить все расписания для устройства
**Endpoint:**
`GET /devices/:device_id/watering_schedules`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
[{"id":3,"device_id":2,"day_of_week":"friday","start_time":"09:30","end_time":"09:45","active":true,"created_at":"2025-12-02T13:06:48.111Z","updated_at":"2025-12-02T13:06:48.111Z"}]
```
## Получить предстоящие расписания для устройства
**Endpoint:**
`GET /devices/:device_id/watering_schedules/upcoming`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
[{"id":4,"device_id":2,"day_of_week":"tuesday","start_time":"09:30","end_time":"09:45","active":true,"created_at":"2025-12-02T13:17:33.469Z","updated_at":"2025-12-02T13:17:33.469Z"},{"id":5,"device_id":2,"day_of_week":"tuesday","start_time":"20:30","end_time":"20:45","active":true,"created_at":"2025-12-02T13:18:14.254Z","updated_at":"2025-12-02T13:18:14.254Z"}]
```
## Получить конкретное расписание
**Endpoint:**
`GET /watering_schedules/:id`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"id":3,"device_id":2,"day_of_week":"friday","start_time":"09:30","end_time":"09:45","active":true,"created_at":"2025-12-02T13:06:48.111Z","updated_at":"2025-12-02T13:06:48.111Z"}
```

## Обновить расписание
**Endpoint:**
`PUT/PATCH /watering_schedules/:id`
**Body:**
```
{
    "watering_schedule": {
      "active": false,
      "start_time": "10:00"
    }
}
```
Ответ:
```
{"start_time":"09:40","active":false,"device_id":2,"id":3,"day_of_week":"friday","end_time":"09:45","created_at":"2025-12-02T13:06:48.111Z","updated_at":"2025-12-02T13:27:27.712Z"}
```
## Удалить расписание 
**Endpoint:**
`DELETE /watering_schedules/:id`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
204 No Content
```
## Переключить активность расписания
**Endpoint:**
`PATCH /watering_schedules/:id/toggle_active`

**Headers:**
```
Authorization: Bearer <token>
```

Ответ:
```
{"id":3,"active":true,"message":"Schedule activated"}
```
