# API文档

## 初始化
请仅在首个页面调用该方法
* `init`
```javascript
JMessage.init();
```

## 事件

### 监听接收消息
* `addReceiveMessageListener`
* @param {Function< Message >} 回调方法，包含消息内容
* @returns {Object} 事件监听句柄，可通过调用该对象的remove方法取消监听
```javascript
JMessage.addReceiveMessageListener((message) => {
	console.log('receive', message);
});
```
- 消息内容结构

| first level | second level | type   | description |
|------------|----------|-------------------------|
| msgId      |          | String | 消息id  |
| serverMessageId | | String | 服务器消息id(存在说明该消息与服务器同步)  |
| timestamp  |          | Number | 时间戳  |
| contentType|          | Number | 消息类型(0：未知，1：文本，2：图片，3：语音，4：自定义，5：事件通知，6：文件，7：地理位置)  |
| contentTypeDesc |          | String | 消息类型描述 |
| content    |          | Object | 消息内容 |
| from       |          | Object | 消息来源 |
|            | nickname | String | 昵称 |
|            | type     | String | 类型(默认的用户之间互发消息，其值是 "user"。如果是 App 管理员下发的消息，是 "admin") |
|            | name     | String | 用户名 |
|            | avatar   | String | 头像URL |
| target     |          | Object | 消息目标(收到的消息时target为自己，发送消息时为对方) |
|            | name     | String | 用户名 |   
|            | nickname | String | 昵称 |
|            | type     | String | 类型(1：单聊，2：群聊) | 
|            | typeDesc | String | 类型描述 |
|            | avatar   | String | 头像URL |

- 示例

test用户向管理员发送文本消息
```json
{
    from: { 
      nickname: "测试", 
      type: null, 
      name: "test", 
      avatar: null 
    },
    serverMessageId: "253697900",
    target: {
        avatar: null,
        nickname: "管理员",
        type: 1,
        typeDesc: "Single",
        name: "admin"
    },
    content: { text: "测试" },
    contentType: 1,
    msgId: "msgId_1487671293104767",
    timestamp: 1487671293296,
    contentTypeDesc: "Text"
}
```

### 取消事件监听
通过调用`JMessage.events`可以获得支持的事件名称
* removeAllListener
* @param {String|Array} 事件名称
```javascript
JMessage.removeAllListener();
```
```javascript
JMessage.removeAllListener(JMessage.events);
```
```javascript
JMessage.removeAllListener(JMessage.events.onReceiveMessage);
```

## 账户

### 登录状态
* `isLoggedIn`
* @returns {Promise< Boolean >} 是否处于登录状态
```javascript
JMessage.isLoggedIn().then((isLoggedIn) => {
	console.log('user isLoggedIn', isLoggedIn);
});
``` 

### 登录账户
* `login`
* @param {string} 用户名
* @param {string} 密码
* @returns {Promise< Object >} 用户信息
```javascript
JMessage.login(account, password).then((info) => {
	console.log('user login', info);
}).catch(error => {
	console.error(error.message);
});
```
- 用户信息数据格式

| name       | type   | description             |
|------------|--------|-------------------------|
| username   | String | 用户名                   |
| nickname   | String | 昵称                     |
| avatar     | String | 头像URL                  |
| gender     | Number | 性别(未知[0],男[1],女[2]) |
| genderDesc | String | 性别描述                  |
| birthday   | String | 生日                     |
| region     | String | 区域                     |   
| signature  | String | 签名                     |
| noteName   | String | 备注名                    | 
| noteText   | String | 备注信息                  |

### 注销账户
* `logout`
* @returns {Promise< Boolean >} 是否成功
```javascript
JMessageModule.logout().then((isLogout) => {
	console.log('user logout', isLogout);
});
```

### 个人信息
* `myInfo`
* @returns {Promise< Object >} 个人信息
```javascript
JMessage.myInfo().then((info) => {
	console.log('user login', info);
}).catch(error => {
	console.error(error.message);
});
```
- 个人信息格式

| name       | type   | description             |
|------------|--------|-------------------------|
| username   | String | 用户名                   |
| nickname   | String | 昵称                     |
| avatar     | String | 头像URL                  |
| gender     | Number | 性别(0：未知，1：男，2：女  |
| genderDesc | String | 性别描述                  |
| birthday   | String | 生日                     |
| region     | String | 区域                     |   
| signature  | String | 签名                     |
| noteName   | String | 备注名                    | 
| noteText   | String | 备注信息                  |

## 消息

### 发送单聊消息
* `sendSingleMessage`
* param {Object} 消息体
* returns {Promise< Object >} 消息内容（格式参照[监听消息事件](/api-document?id=%e7%9b%91%e5%90%ac%e6%8e%a5%e6%94%b6%e6%b6%88%e6%81%af)消息内容结构）

- 消息体结构

| name   | type   | description                |
|--------|--------|----------------------------|
| appkey | String | 应用的key                   |
| name   | String | 用户名                      |
| type   | String | 消息类型(目前只支持text,image)|
| data   | Object | 消息数据                    |

- 发送文本消息
```javascript
JMessage.sendSingleMessage({
	name: 'admin',
	type: 'text',
	data: { text: '测试消息' }
}).then((message) => {
	console.log('send text message', message);
}).catch(error => {
	console.error(error.message);
});
```
- 发送图片消息
```javascript
JMessage.sendSingleMessage({
	name: 'admin',
	type: 'image',
	data: { image: '...'/*image文件路径*/ }
}).then((message) => {
	console.log('send image message', message);
}).catch(error => {
	console.error(error.message);
});
```

### 发送群聊消息
* `sendGroupMessage`
* param {Object} 消息体
* returns {Promise< Object >} 消息内容（格式参照[监听消息事件](/api-document?id=%e7%9b%91%e5%90%ac%e6%8e%a5%e6%94%b6%e6%b6%88%e6%81%af)消息内容结构）

- 消息体结构

| name   | type   | description                |
|--------|--------|----------------------------|
| gid    | String、Number | 群组id              |
| type   | String | 消息类型(目前只支持text,image)|
| data   | Object | 消息数据(参照单聊)            |

### 根据会话发送消息
* `sendMessageByCID`
* param {Object} 消息体
* returns {Promise< Object >} 消息内容（格式参照[监听消息事件](/api-document?id=%e7%9b%91%e5%90%ac%e6%8e%a5%e6%94%b6%e6%b6%88%e6%81%af)消息内容结构）

- 消息体结构

| name   | type   | description                |
|--------|--------|----------------------------|
| cid    | String | 会话id(由[会话接口](/api-document?id=%e8%8e%b7%e5%be%97%e4%bc%9a%e8%af%9d%e5%88%97%e8%a1%a8)获得)         |
| type   | String | 消息类型(目前只支持text,image)|
| data   | Object | 消息数据(参照单聊)            |

### 历史消息
* `historyMessages`
* param {Object} 查询参数体
* returns {Promise< Array< Object > >} 消息列表（格式参照[监听消息事件](/api-document?id=%e7%9b%91%e5%90%ac%e6%8e%a5%e6%94%b6%e6%b6%88%e6%81%af)消息内容结构）

- 查询参数体结构

| name   | type   | description                |
|--------|--------|----------------------------|
| cid    | String | 会话id(由[会话接口](/api-document?id=%e8%8e%b7%e5%be%97%e4%bc%9a%e8%af%9d%e5%88%97%e8%a1%a8)获得)         |
| offset | Int    | 偏移量                      |
| limit  | Int    | 会话记录获取数               | 

## 会话

### 获得会话列表
* `allConversations`
* returns {Promise< Array< Object > >} 会话列表

- 会话数据结构

| name     | type   | description                |
|----------|--------|----------------------------|
| id       | String | 会话id                      |
| timestamp| Number | 时间戳                      |
| title    | String | 会话标题(一般为用户昵称)       |
| username | String | 会话目标用户的用户名(单聊时有) | 
| groupId  | String | 会话目标群的群id(群聊时有)    | 
| type     | String | 会话类型(1：单聊，2：群聊)    | 
| typeDesc | String | 会话类型描述                | 
| unreadCount | String | 会话未读记录数            |
| laseMessage | String | 最近聊天记录             |
| avatar   | String | 会话头像base64              |

- 示例
```json
{ 
    avatar: null,
    id: "c9120031-ad38-4f86-b901-c3d5b4537582",
    title: "管理员",
    laseMessage: "123",
    username: "admin",
    typeDesc: "Single",
    type: 1,
    groupId: null,
    unreadCount: 0,
    timestamp: 1487671293296 
 }
```

### 删除会话
* `removeConversation`
* param {String} 会话id(由[会话接口](/api-document?id=%e8%8e%b7%e5%be%97%e4%bc%9a%e8%af%9d%e5%88%97%e8%a1%a8)获得)
* returns{Promise} 无数据

```javascript
	JMessage.removeConversation(cid);
```

### 清除未读数
* `clearUnreadCount`
* param {String} 会话id(由[会话接口](/api-document?id=%e8%8e%b7%e5%be%97%e4%bc%9a%e8%af%9d%e5%88%97%e8%a1%a8)获得)
* returns {Promise< Int >} 原先未读记录数

```javascript
	JMessage.clearUnreadCount(cid);
```

