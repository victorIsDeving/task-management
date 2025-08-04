# README

This is a weekend project i develop in order to perfect my craft with Ruby On Rails.
It grows with time, adding some more functionalities and adptations that expands my knowledge about Ruby On Rails.

It's a simple task management API with team collaboration. Mainly it has:
- A simple user authentication
- RESTFUL APIs to manage:
    - users
    - teams
    - projects
    - tasks
    - comments on tasks
- role based permissions

Some important points:

* Ruby version
    - ruby 3.2.0 (2022-12-25 revision a528908271) [arm64-darwin24]
* Rails version
    - 8.0.2
* PostgreSQL database
    - version 15.3
* Running
    - `rails server`

Some testing endpoints are:
- user register, returns a token needed for other operations
```
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tim Duncan",
    "email": "big@fundamental.com",
    "password": "spursporvida21",
    "password_confirmation": "spursporvida21"
  }'
```
- login for registered user
```
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "big@fundamental.com",
    "password": "spursporvida21"
  }'
```
- team create, returns a team id to use on task creation
```
curl -X POST http://localhost:3000/api/v1/teams \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer USER_TOKEN" \
  -d '{
    "team": {
      "name": "San Antonio Spurs",
      "description": "5 times NBA champion"
    }
  }'
```
- project create
```
curl -X POST http://localhost:3000/api/v1/teams/TEAM_ID/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer USER_TOKEN" \
  -d '{
    "project": {
      "name": "20250516 vs Lakers",
      "description": "next game vs the Lakers, watch out for number 24"
    }
  }'
```

### Next Steps
---
- Looking to buid a full api collection to run and test things easily
- Develop RSpec test cases with FactoryBot
- Some services objects that implement business logic

- Add a simple third-party API integration.