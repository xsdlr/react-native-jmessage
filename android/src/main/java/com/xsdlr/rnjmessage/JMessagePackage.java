package com.xsdlr.rnjmessage;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import cn.jpush.reactnativejpush.JPushModule;
import cn.jpush.reactnativejpush.Logger;

/**
 * Created by xsdlr on 2016/12/14.
 */
public class JMessagePackage implements ReactPackage {
    public JMessagePackage(boolean isDebug) {
        this(isDebug, isDebug, isDebug);
    }

    public JMessagePackage(boolean isDebug, boolean isShutdownLog, boolean isShutdownToast) {
        super();
        JMessageModule.isDebug = isDebug;
        Logger.SHUTDOWNLOG = isShutdownLog;
        Logger.SHUTDOWNTOAST = isShutdownToast;
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        return Arrays.asList(new NativeModule[]{
                new JPushModule(reactContext),
                new JMessageModule(reactContext),
        });
    }

    @Override
    public List<Class<? extends JavaScriptModule>> createJSModules() {
        return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}
