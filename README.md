# NoFB
## Purpose
The users could subscribe to specific words in a facebook group. When there are any posts related to specific words, NoFB would notify users by sending email to them.
The best word to describe us is **Notification**.

## Resources
- class Posts
- class Post 

### Element
- class Posts
  * @size = int
  * @posts = [Post, Post, ...]
  * @post_list = [id, id, id, ...]
- class Post 
  * @updated_time
  * @message
  * @id

### Entities
There are objects that are import to the Facebook group.
* Posts

## Installation
```bash=
bundle install
```
If you have not installed the gcc, please run this command before install.
```bash=
sudo apt-get install build-essential
```

## Command
If you want to run the app:
```bash=
rackup
```

如果有error，請跑這行:
```bash=
rbenv rehash
```

Check the code spec:
```bash=
rake spec
```

Check the quality of code:
```bash=
rake quality:all
```

Run the db
```bash=
rake db:migrate
```

Drop the db
```bash=
rake db:drop
```

## Design of table in Database
1. Groups

| group_id | group_name | updated_at | created_at |
| -------- | ---------- | ---------- | ---------- |
| String   | String     | String     | String     |

2. Posts

| post_id | updated_time | message | user_id | group_id |
| ------- | ------------ | ------- | ------- | -------- |
| String  | String       | String  | String  | String   |

3. Users

| user_id | user_email | access_token |
| ------- | ---------- | ------------ |
| String  | String     | String       |


## Cache
- 60 sec. expired 
![](https://i.imgur.com/tYxm2X0.png)
- 700s ms without no cache
![](https://i.imgur.com/wuthm9W.png)
- 200s ms with cache
![](https://i.imgur.com/19SlruU.png)

## 12/12 quailty
![](https://i.imgur.com/9l6BOLS.png)