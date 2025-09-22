// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ai_toolkit/src/views/chat_input/chat_suggestion_view.dart';

import '../chat_view_model/chat_view_model_client.dart';
import '../providers/interface/chat_message.dart';
import '../providers/interface/message_origin.dart';
import 'chat_message_view/llm_message_view.dart';
import 'chat_message_view/user_message_view.dart';

/// A widget that displays a history of chat messages.
///
/// This widget renders a scrollable list of chat messages, supporting
/// selection and editing of messages. It displays messages in reverse
/// chronological order (newest at the bottom).
@immutable
class ChatHistoryView extends StatefulWidget {
  /// Creates a [ChatHistoryView].
  ///
  /// If [onEditMessage] is provided, it will be called when a user initiates an
  /// edit action on an editable message (typically the last user message in the
  /// history).
  const ChatHistoryView({
    this.onEditMessage,
    required this.onSelectSuggestion,
    super.key,
  });

  /// Optional callback function for editing a message.
  ///
  /// If provided, this function will be called when a user initiates an edit
  /// action on an editable message (typically the last user message in the
  /// history). The function receives the [ChatMessage] to be edited as its
  /// parameter.
  final void Function(ChatMessage message)? onEditMessage;

  /// The callback function to call when a suggestion is selected.
  final void Function(String suggestion) onSelectSuggestion;

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  final _clientKey = const Key('chat-client');
  final _listKey = const Key('chat-list');
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  int userMessageCount = 0;
  @override
  Widget build(BuildContext context) => ChatViewModelClient(
    key: _clientKey,
    builder: (context, viewModel, child) {
      final showWelcomeMessage = viewModel.welcomeMessage != null;
      final showSuggestions =
          viewModel.suggestions.isNotEmpty &&
          viewModel.provider.history.isEmpty;
      final history = [
        if (showWelcomeMessage)
          ChatMessage(
            origin: MessageOrigin.llm,
            text: viewModel.welcomeMessage,
            attachments: [],
          ),
        if (showSuggestions)
          ChatSuggestionsView(
            suggestions: viewModel.suggestions,
            onSelectSuggestion: widget.onSelectSuggestion,
          ),
        ...viewModel.provider.history,
      ];

      final currentCount =
          history
              .where((e) => e is ChatMessage && e.origin == MessageOrigin.user)
              .length;
      print('TT: $currentCount != $userMessageCount');
      if (currentCount != userMessageCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients &&
              !_scrollController.position.isScrollingNotifier.value) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });
        userMessageCount = currentCount;
      }

      return ListView.builder(
        key: _listKey,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        physics: ClampingScrollPhysics(),
        controller: _scrollController,
        // reverse: true,
        itemCount: history.length,
        itemBuilder: (context, index) {
          final messageIndex = index; //history.length - index - 1;
          final message = history[messageIndex];

          if (message is ChatSuggestionsView) {
            return message;
          }
          if (message is! ChatMessage) {
            return Text('unknown item');
          }
          final isLastUserMessage =
              message.origin.isUser && messageIndex >= history.length - 2;
          final canEdit = isLastUserMessage && widget.onEditMessage != null;
          final isUser = message.origin.isUser;

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child:
                isUser
                    ? UserMessageView(
                      message,
                      onEdit:
                          canEdit
                              ? () => widget.onEditMessage?.call(message)
                              : null,
                    )
                    : LlmMessageView(
                      message,
                      isWelcomeMessage: messageIndex == 0,
                    ),
          );
        },
      );
    },
  );
}
