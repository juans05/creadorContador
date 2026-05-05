import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  const ChatScreen({super.key, required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    try {
      // Get user ID from username
      final profileResp = await ApiClient.dio.get('/influencers/${widget.username}');
      if (profileResp.data['success'] != true) return;
      
      final influencerId = profileResp.data['data']['influencerId'];
      
      // Load conversation
      final resp = await ApiClient.dio.get('/messages/conversation/$influencerId');
      if (resp.data['success'] == true) {
        setState(() {
          _messages = resp.data['data']['conversation'] ?? [];
        });
      }
    } catch (e) {}
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    
    setState(() => _isSending = true);
    _messageController.clear();

    // Optimistic update
    setState(() {
      _messages.add({
        'content': text,
        'from': 'me',
        'createdAt': DateTime.now().toIso8601String(),
      });
    });

    try {
      // Get influencer ID first
      final profileResp = await ApiClient.dio.get('/influencers/${widget.username}');
      if (profileResp.data['success'] != true) return;
      
      final influencerId = profileResp.data['data']['influencerId'];
      
      await ApiClient.dio.post('/messages', data: {
        'receiverId': influencerId,
        'content': text,
      });
    } catch (e) {}
    finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Ahora';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientName = widget.username;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: LuxorColors.surfaceElevated, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LuxorColors.gradientPrimary,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: LuxorColors.background,
                      child: Text(
                        recipientName.isNotEmpty ? recipientName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@$recipientName', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const Text(
                          'Chat privado',
                          style: TextStyle(color: LuxorColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
                  : _messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 48, color: LuxorColors.textMuted),
                              SizedBox(height: 16),
                              Text('Envía un mensaje para iniciar la conversación', style: TextStyle(color: LuxorColors.textMuted)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMine = msg['from'] == 'me';
                            final content = msg['content'] ?? '';
                            final time = _formatTime(msg['createdAt']);

                            return Align(
                              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                child: Column(
                                  crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isMine ? LuxorColors.primary.withValues(alpha: 0.15) : LuxorColors.surface,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: Radius.circular(isMine ? 16 : 4),
                                          bottomRight: Radius.circular(isMine ? 4 : 16),
                                        ),
                                        border: Border.all(
                                          color: isMine ? LuxorColors.primary.withValues(alpha: 0.3) : LuxorColors.surfaceElevated.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        content,
                                        style: const TextStyle(fontSize: 14, height: 1.4),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: const TextStyle(color: LuxorColors.textMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: const BoxDecoration(
                color: LuxorColors.surface,
                border: Border(top: BorderSide(color: LuxorColors.surfaceElevated, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: LuxorColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: LuxorColors.surfaceElevated),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: LuxorColors.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          filled: false,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: LuxorColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
