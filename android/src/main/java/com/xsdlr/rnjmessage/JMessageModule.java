package com.xsdlr.rnjmessage;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Nullable;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.im.android.api.JMessageClient;
import cn.jpush.im.android.api.content.ImageContent;
import cn.jpush.im.android.api.content.MessageContent;
import cn.jpush.im.android.api.content.TextContent;
import cn.jpush.im.android.api.enums.ContentType;
import cn.jpush.im.android.api.enums.ConversationType;
import cn.jpush.im.android.api.event.MessageEvent;
import cn.jpush.im.android.api.model.Conversation;
import cn.jpush.im.android.api.model.GroupInfo;
import cn.jpush.im.android.api.model.Message;
import cn.jpush.im.android.api.model.UserInfo;
import cn.jpush.im.api.BasicCallback;

/**
 * Created by xsdlr on 2016/12/14.
 */
public class JMessageModule extends ReactContextBaseJavaModule {

    static boolean isDebug;
    final static Map<String, Conversation> conversationStore = new HashMap<>();

    public JMessageModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "JMessageModule";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("AppKey", getMetaData("JPUSH_APPKEY"));
        constants.put("MasterSecret", getMetaData("JPUSH_MASTER_SECRET"));
        return constants;
    }

    /**
     * 初始化方法
     */
    @ReactMethod
    public void setupJMessage() {
        JMessageClient.init(this.getReactApplicationContext());
        JMessageClient.registerEventReceiver(this);
        JPushInterface.setDebugMode(JMessageModule.isDebug);
    }

    /**
     * 获得注册id
     * @param promise
     */
    @ReactMethod
    public void getRegistrationID(final Promise promise) {
        Activity context = getCurrentActivity();
        if (context == null) {
            promise.reject(JMessageException.ACTIVITY_NOT_EXIST.getCode(), JMessageException.ACTIVITY_NOT_EXIST);
            return;
        }
        String id = JPushInterface.getRegistrationID(context);
        promise.resolve(id);
    }

    /**
     * 登录
     * @param username  用户名
     * @param password  密码
     * @param promise
     */
    @ReactMethod
    public void login(String username, String password, final Promise promise) {
        final JMessageModule _this = this;
        JMessageClient.login(username, password, new BasicCallback() {
            @Override
            public void gotResult(int responseCode, String loginDesc) {
                if (responseCode == 0) {
                    _this.getUserInfo(promise);
                } else {
                    promise.reject(String.valueOf(responseCode), loginDesc);
                }
            }
        });
    }

    /**
     * 注销
     */
    @ReactMethod
    public void logout() {
        JMessageClient.logout();
    }

    /**
     * 获得用户信息
     * @param promise
     */
    @ReactMethod
    public void getUserInfo(final Promise promise) {
        UserInfo info = JMessageClient.getMyInfo();
        if (info == null) {
            promise.reject(null, "获取用户信息失败");
        }
        WritableMap result = Arguments.createMap();
        result.putString("username", info.getUserName());
        result.putString("nickname", info.getNickname());
        result.putString("avatar", info.getAvatar());
        result.putString("username", info.getUserName());
        result.putInt("gender", messagePropsToInt(Utils.defaultValue(info.getGender(), UserInfo.Gender.unknown)));
        result.putString("genderDesc", messagePropsToString(Utils.defaultValue(info.getGender(), UserInfo.Gender.unknown)));
        result.putDouble("birthday", info.getBirthday());
        result.putString("region", info.getRegion());
        result.putString("signature", info.getSignature());
        result.putString("noteName", info.getNotename());
        result.putString("noteText", info.getNoteText());
        promise.resolve(result);
    }

    /**
     * 发送单聊消息
     * @param username  用户名
     * @param type      消息类型
     * @param data      数据
     * @param promise
     */
    @ReactMethod
    public void sendSingleMessage(String username, String type, ReadableMap data, final Promise promise) {
        Conversation conversation = Conversation.createSingleConversation(username);
        sendMessage(conversation, type, data, promise);
    }

    /**
     * 发送群聊消息
     * @param groupId   群号
     * @param type      消息类型
     * @param data      数据
     * @param promise
     */
    @ReactMethod
    public void sendGroupMessage(String groupId, String type, ReadableMap data, final Promise promise) {
        long gid;
        try {
            gid = Long.valueOf(groupId);
        } catch (NumberFormatException e) {
            JMessageException ex = JMessageException.ILLEGAL_ARGUMENT_EXCEPTION;
            promise.reject(ex.getCode(), ex.getMessage());
            return;
        }
        Conversation conversation = Conversation.createGroupConversation(gid);
        sendMessage(conversation, type, data, promise);
    }

    /**
     * 获取会话列表
     * @param promise
     */
    @ReactMethod
    public void allConversations(final Promise promise) {
        List<Conversation> conversations = JMessageClient.getConversationList();
        conversationStore.clear();
        WritableArray result = Arguments.createArray();
        for (Conversation conversation: conversations) {
            String cid = UUID.randomUUID().toString().toLowerCase().replace("-", "");
            conversationStore.put(cid, conversation);
            WritableMap conversationMap = tansformToWritableMap(conversation);
            conversationMap.putString("id", cid);
            result.pushMap(conversationMap);
        }
        promise.resolve(result);
    }

    /**
     * 获得历史消息
     * @param cid       会话id
     * @param offset    从最新开始的偏移
     * @param limit     数量
     * @param promise
     */
    @ReactMethod
    public void historyMessages(String cid, Integer offset, Integer limit, final Promise promise) {
        Integer _limit = limit <= 0 ? Integer.MAX_VALUE : limit;
        if (Utils.isEmpty(cid)) {
            JMessageException ex = JMessageException.CONVERSATION_ID_EMPTY;
            promise.reject(ex.getCode(), ex.getMessage());
            return;
        }
        Conversation conversation = conversationStore.get(cid);
        if (conversation == null) {
            JMessageException ex = JMessageException.CONVERSATION_INVALID;
            promise.reject(ex.getCode(), ex.getMessage());
            return;
        }
        WritableArray result = Arguments.createArray();
        for (Message message: conversation.getMessagesFromNewest(offset, _limit)) {
            result.pushMap(tansformToWritableMap(message));
        }
        promise.resolve(result);
    }
    /**
     * 接收消息事件监听
     * @param event
     */
    public void onEvent(MessageEvent event) {
        Message message = event.getMessage();
        this.getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("onReceiveMessage", tansformToWritableMap(message));
    }

    private WritableMap tansformToWritableMap(Message message) {
        WritableMap result = Arguments.createMap();
        if (message == null) return result;

        result.putString("msgId", Utils.defaultValue(message.getId(), "").toString());
        result.putString("serverMessageId", Utils.defaultValue(message.getServerMessageId(), "").toString());

        WritableMap from = Arguments.createMap();
        from.putString("type", message.getFromType());
        from.putString("name", message.getFromUser().getUserName());
        from.putString("nickname", message.getFromUser().getNickname());
        result.putMap("from", from);

        WritableMap target = Arguments.createMap();
        target.putInt("type", messagePropsToInt(message.getTargetType()));
        target.putString("typeDesc", messagePropsToString(message.getTargetType()));
        switch (message.getTargetType()) {
            case single:
                UserInfo userInfo = (UserInfo)message.getTargetInfo();
                target.putString("name", userInfo.getUserName());
                target.putString("nickname", userInfo.getNickname());
                break;
            case group:
                GroupInfo groupInfo = (GroupInfo)message.getTargetInfo();
                target.putString("name", groupInfo.getGroupName());
                target.putString("nickname", groupInfo.getGroupDescription());
                break;
            default:
                break;
        }
        result.putMap("target", target);
        result.putDouble("timestamp", message.getCreateTime());
        result.putInt("contentType", messagePropsToInt(message.getContentType()));
        result.putString("contentTypeDesc", messagePropsToString(message.getContentType()));
        result.putString("content", message.getContent().toJson());
        return result;
    }

    private WritableMap tansformToWritableMap(Conversation conversation) {
        WritableMap result = Arguments.createMap();
        File avatar = conversation.getAvatarFile();
        if (avatar != null) {
            String imageBase64 = Utils.imageToBase64(avatar, Bitmap.CompressFormat.PNG);
            result.putString("avatar", imageBase64);
        }
        result.putInt("type", messagePropsToInt(conversation.getType()));
        result.putString("typeDesc", messagePropsToString(conversation.getType()));
        result.putString("title", conversation.getTitle());

        result.putString("laseMessage", getLastMessageContent(conversation));
        result.putInt("unreadCount", conversation.getUnReadMsgCnt());
        return result;
    }

    private String messagePropsToString(UserInfo.Gender gender) {
        if (gender == null) return null;
        switch (gender) {
            case unknown:
                return "Unknown";
            case male:
                return "Male";
            case female:
                return "Female";
            default:
                return null;
        }
    }

    private String messagePropsToString(ConversationType type) {
        if (type == null) return null;
        switch (type) {
            case single:
                return "Single";
            case group:
                return "Group";
            default:
                return null;
        }
    }

    private String messagePropsToString(ContentType type) {
        if (type == null) return null;
        switch (type) {
            case unknown:
                return "Unknown";
            case text:
                return "Text";
            case image:
                return "Image";
            case voice:
                return "Voice";
            case custom:
                return "Custom";
            case eventNotification:
                return "Event";
            case file:
                return "File";
            case location:
                return "Location";
            default:
                return null;
        }
    }

    private Integer messagePropsToInt(UserInfo.Gender gender) {
        if (gender == null) return null;
        switch (gender) {
            case unknown:
                return 0;
            case male:
                return 1;
            case female:
                return 2;
            default:
                return null;
        }
    }

    private Integer messagePropsToInt(ConversationType type) {
        if (type == null) return null;
        switch (type) {
            case single:
                return 1;
            case group:
                return 2;
            default:
                return null;
        }
    }

    private Integer messagePropsToInt(ContentType type) {
        if (type == null) return null;
        switch (type) {
            case unknown:
                return 0;
            case text:
                return 1;
            case image:
                return 2;
            case voice:
                return 3;
            case custom:
                return 4;
            case eventNotification:
                return 5;
            case file:
                return 6;
            case location:
                return 7;
            default:
                return null;
        }
    }

    private String getMetaData(String name) {
        ReactApplicationContext reactContext = getReactApplicationContext();
        try {
            ApplicationInfo appInfo = reactContext.getPackageManager()
                    .getApplicationInfo(reactContext.getPackageName(),
                            PackageManager.GET_META_DATA);
            return appInfo.metaData.get(name).toString();
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getLastMessageContent(Conversation conversation) {
        Message message = conversation.getLatestMessage();
        if(message == null) return "";
        switch (message.getContentType()) {
            case unknown:
                return "[未知]";
            case text:
                return ((TextContent)message.getContent()).getText();
            case image:
                return "[图片]";
            case voice:
                return "[语音]";
            case custom:
                return "[自定义]";
            case eventNotification:
                return "[事件]";
            case file:
                return "[文件]";
            case location:
                return "[位置]";
            default:
                return "";
        }
    }

    private void sendMessage(Conversation conversation,
                             String contentType, ReadableMap data,
                             final Promise promise) {
        String type = contentType.toLowerCase();
        MessageContent content;

        if (conversation == null) {
            JMessageException ex = JMessageException.CONVERSATION_INVALID;
            promise.reject(ex.getCode(), ex.getMessage());
            return;
        }
        switch (type) {
            case "text":
                content = new TextContent(data.getString("text"));
                break;
            case "image":
                try {
                    File imageFile = new File(data.getString("image"));
                    content = new ImageContent(imageFile);
                } catch (FileNotFoundException e) {
                    JMessageException ex = JMessageException.MESSAGE_CONTENT_NULL;
                    promise.reject(ex.getCode(), ex.getMessage());
                    return;
                }
                break;
            default:
                JMessageException ex = JMessageException.MESSAGE_CONTENT_TYPE_NOT_SUPPORT;
                promise.reject(ex.getCode(), ex.getMessage());
                return;
        }
        final Message message = conversation.createSendMessage(content);
        message.setOnSendCompleteCallback(new BasicCallback() {
            @Override
            public void gotResult(int responseCode, String responseDesc) {
                if (responseCode == 0) {
                    promise.resolve(tansformToWritableMap(message));
                } else {
                    promise.reject(String.valueOf(responseCode), responseDesc);
                }
            }
        });
        JMessageClient.sendMessage(message);
    }
}
