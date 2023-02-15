package com.salesforcesdkforreactnative.salesforce.chat;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.view.inputmethod.EditorInfo;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import com.salesforce.android.chat.core.AgentAvailabilityClient;
import com.salesforce.android.chat.core.ChatCore;
import com.salesforce.android.chat.core.model.AvailabilityState;
import com.salesforce.android.chat.core.ChatConfiguration;
import com.salesforce.android.chat.core.SessionStateListener;
import com.salesforce.android.chat.core.model.ChatEndReason;
import com.salesforce.android.chat.core.model.ChatEntity;
import com.salesforce.android.chat.core.model.ChatEntityField;
import com.salesforce.android.chat.core.model.ChatSessionState;
import com.salesforce.android.chat.core.model.ChatUserData;
import com.salesforce.android.chat.ui.ChatUI;
import com.salesforce.android.chat.ui.ChatUIClient;
import com.salesforce.android.chat.ui.ChatUIConfiguration;
import com.salesforce.android.chat.ui.model.PreChatTextInputField;
import com.salesforce.android.service.common.utilities.control.Async;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import com.salesforcesdkforreactnative.R;

public class SalesforceChatModule extends ReactContextBaseJavaModule implements SessionStateListener {
    private static final String NATIVE_MODULE_NAME = "SalesforceChatModule";
    private static final String CASE_SUBJECT = "Chat Conversation";
    private static final String CASE_ORIGIN = "Mobile App";

	private final String ChatSessionStateChanged = "ChatSessionStateChanged";
	private final String ChatSessionEnd = "ChatSessionEnd";
	private final String Connecting = "Connecting";
	private final String Queued = "Queued";
	private final String Connected = "Connected";
	private final String Ending = "Ending";
	private final String Disconnected = "Disconnected";
	private final String EndReasonUser = "EndReasonUser";
	private final String EndReasonAgent = "EndReasonAgent";
	private final String EndReasonNoAgentsAvailable = "EndReasonNoAgentsAvailable";
	private final String EndReasonTimeout = "EndReasonTimeout";
	private final String EndReasonSessionError = "EndReasonSessionError";

	private final ReactApplicationContext reactContext;

    private ChatConfiguration chatConfiguration;
    List<ChatUserData> chatUserData;
    List<ChatEntity> chatEntities;

    public SalesforceChatModule(ReactApplicationContext reactContext) {
        super(reactContext);

        this.reactContext = reactContext;

        chatUserData = new ArrayList<>();
        chatEntities = new ArrayList<>();
    }

    @Override
    public String getName() {
        return NATIVE_MODULE_NAME;
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put(ChatSessionStateChanged, ChatSessionStateChanged);
        constants.put(ChatSessionEnd, ChatSessionEnd);
        constants.put(Connecting, Connecting);
        constants.put(Queued, Queued);
        constants.put(Connected, Connected);
        constants.put(Ending, Ending);
        constants.put(Disconnected, Disconnected);
        constants.put(EndReasonUser, EndReasonUser);
        constants.put(EndReasonAgent, EndReasonAgent);
        constants.put(EndReasonNoAgentsAvailable, EndReasonNoAgentsAvailable);
        constants.put(EndReasonTimeout, EndReasonTimeout);
        constants.put(EndReasonSessionError, EndReasonSessionError);

        return constants;
    }

    /**
     * Configures pre-chat fields
     */
    @ReactMethod
    public void initializePreChatUserData() {
        chatUserData = new ArrayList<>();

        PreChatTextInputField firstName = new PreChatTextInputField.Builder()
                .required(true)
                .build(reactContext.getString(R.string.enter_first_name), reactContext.getString(R.string.first_name));
        PreChatTextInputField lastName = new PreChatTextInputField.Builder()
                .required(true)
                .build(reactContext.getString(R.string.enter_last_name), reactContext.getString(R.string.last_name));

        PreChatTextInputField email = new PreChatTextInputField.Builder()
                .required(true)
                .inputType(EditorInfo.TYPE_TEXT_VARIATION_EMAIL_ADDRESS)
                .mapToChatTranscriptFieldName("Email__c")
                .build(reactContext.getString(R.string.enter_email), reactContext.getString(R.string.email));

        ChatUserData subject = new ChatUserData(
                "Hidden Subject Field",
                CASE_SUBJECT,
                false
        );
        ChatUserData origin = new ChatUserData(
                "Hidden Origin Field",
                CASE_ORIGIN,
                false
        );

        chatUserData.add(firstName);
        chatUserData.add(lastName);
        chatUserData.add(email);
        chatUserData.add(subject);
        chatUserData.add(origin);

        chatEntities = new ArrayList<>();

        ChatEntity caseEntity = new ChatEntity.Builder()
                .showOnCreate(true)
                .linkToTranscriptField("Case")
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(false)
                        .isExactMatch(false)
                        .doCreate(true)
                        .build("Subject", subject))
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(false)
                        .isExactMatch(false)
                        .doCreate(true)
                        .build("Origin", origin))
                .build("Case");

        ChatEntity contactEntity = new ChatEntity.Builder()
                .showOnCreate(true)
                .linkToTranscriptField("Contact")
                .linkToAnotherSalesforceObject(caseEntity, "ContactId")
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("FirstName", firstName))
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("LastName", lastName))
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("Email", email))
                .build("Contact");

        ChatEntity accountEntity = new ChatEntity.Builder()
                .showOnCreate(true)
                .linkToTranscriptField("Account")
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("FirstName", firstName))
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("LastName", lastName))
                .addChatEntityField(new ChatEntityField.Builder()
                        .doFind(true)
                        .isExactMatch(true)
                        .doCreate(false)
                        .build("PersonEmail", email))
                .build("Account");

        chatEntities.add(caseEntity);
        chatEntities.add(contactEntity);
        chatEntities.add(accountEntity);
    }

    /**
    * Build a configuration object
    */
    @ReactMethod
    public void configureChat(String orgId, String buttonId, String deploymentId, String liveAgentPod, @Nullable String visitorName) {
        ChatConfiguration.Builder chatConfigurationBuilder = new ChatConfiguration.Builder(
                orgId,
                buttonId,
                deploymentId,
                liveAgentPod
        );

        if (visitorName != null) {
            chatConfigurationBuilder.visitorName(visitorName);
        }

        chatConfiguration = chatConfigurationBuilder.chatUserData(chatUserData).chatEntities(chatEntities).build();
    }

    @ReactMethod
    public void openChat(final Callback successCallback, final Callback failureCallback) {
        // Create an agent availability client
        AgentAvailabilityClient client = ChatCore.configureAgentAvailability(chatConfiguration);

        // Check agent availability
        client.check().onResult(new Async.ResultHandler<AvailabilityState>() {
            @Override
            public void handleResult(Async<?> async, @NonNull AvailabilityState state) {
                switch (state.getStatus()) {
                    case AgentsAvailable: {
                        launch(successCallback, failureCallback);
                        break;
                    }
                    case NoAgentsAvailable: {
                        failureCallback.invoke(reactContext.getString(R.string.no_agents_available_state));
                        break;
                    }
                    case Unknown: {
                        failureCallback.invoke(reactContext.getString(R.string.unknown_state));
                        break;
                    }
                }
            }
        });
    }

    private void launch(final Callback successCallback, final Callback failureCallback) {
        ChatUIConfiguration chatUiConfiguration = new ChatUIConfiguration.Builder()
                .chatConfiguration(chatConfiguration)
                .build();

        Runnable startChatRunnable = new Runnable() {
            @Override
            public void run() {
                Async.ResultHandler<? super ChatUIClient> resultHandler = new Async.ResultHandler<ChatUIClient>() {
                    @Override
                    public void handleResult(Async<?> operation, @NonNull final ChatUIClient chatUIClient) {
                        chatUIClient.startChatSession(SalesforceChatModule.this.getCurrentActivity());
                        chatUIClient.addSessionStateListener(SalesforceChatModule.this);
                        successCallback.invoke();
                    }
                };

                Async.ErrorHandler errorHandler = new Async.ErrorHandler() {
                    @Override
                    public void handleError(Async<?> async, @NonNull Throwable throwable) {
                        failureCallback.invoke(String.format("%s %s", "error -", throwable.getLocalizedMessage()));
                    }
                };

                ChatUI.configure(chatUiConfiguration).createClient(reactContext).onResult(resultHandler).onError(errorHandler);
            }
        };

        reactContext.runOnUiQueueThread(startChatRunnable);
    }

    @Override
    public void onSessionStateChange(ChatSessionState chatSessionState) {
        String state;

        switch (chatSessionState) {
            case Initializing:
                state = Connecting;
                break;
            case InQueue:
                state = Queued;
                break;
            case Connected:
                state = Connected;
                break;
            case Ending:
                state = Ending;
                break;
            default:
                state = Disconnected;
                break;
        }

        WritableMap params = Arguments.createMap();
        params.putString("state", state);

        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(ChatSessionStateChanged, params);
    }

    @Override
    public void onSessionEnded(ChatEndReason chatEndReason) {
        String endReason;

        switch (chatEndReason) {
            case EndedByClient:
                endReason = EndReasonUser;
                break;
            case EndedByAgent:
                endReason = EndReasonAgent;
                break;
            case NoAgentsAvailable:
                endReason = EndReasonNoAgentsAvailable;
                break;
            case LiveAgentTimeout:
                endReason = EndReasonTimeout;
                break;
            default:
                endReason = EndReasonSessionError;
                break;
        }

        WritableMap params = Arguments.createMap();
        params.putString("reason", endReason);

        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(ChatSessionEnd, params);
    }
}
