# API文档
## isLoggedIn
是否处于登录状态
* @returns {Promise< Boolean >}
```javascript
JMessage.isLoggedIn().then((isLoggedIn) => {
	console.log('user isLoggedIn', isLoggedIn);
});
``` 
## login
登录账号
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
用户信息
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
## logout
注销账户
* @returns {Promise< Boolean >}
```javascript
JMessageModule.logout().then((isLogout) => {
	console.log('user logout', isLogout);
});
```
## myInfo
获取个人信息
* @returns {Promise< Object >} 个人信息
```javascript
JMessage.myInfo().then((info) => {
	console.log('user login', info);
}).catch(error => {
	console.error(error.message);
});
```
个人信息
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
## sendSingleMessage
发送单聊消息
* param {Object} 消息体
* returns {Promise< Object >} 消息内容
消息体结构
| name   | type   | description                |
|--------|--------|----------------------------|
| name   | String | 用户名                      |
| type   | String | 消息类型(目前只支持text,image)|
| data   | Object | 消息数据                    |
发送文本消息
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
发送图片消息
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


