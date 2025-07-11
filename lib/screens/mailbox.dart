import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/storage.dart';

class MailboxPage extends StatefulWidget {
  @override
  _MailboxPageState createState() => _MailboxPageState();
}

class _MailboxPageState extends State<MailboxPage> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _selectMode = false;
  Set<String> _selectedItems = {};
  String _filterType = 'all'; // all, unread, read

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  // Method to refresh notifications
  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNotifications();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B4A9F),
              Color(0xFFD577A7),
              Color(0xFFF5C4C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterTabs(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingIndicator()
                    : RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        color: Color(0xFF8B4A9F),
                        child: _buildNotificationList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _notifications.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _selectMode = !_selectMode;
                  _selectedItems.clear();
                });
              },
              backgroundColor: Color(0xFF8B4A9F),
              child: Icon(
                _selectMode ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'กล่องข้อความ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'จัดการการแจ้งเตือนของคุณ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_selectMode)
            Row(
              children: [
                if (_selectedItems.isNotEmpty)
                  IconButton(
                    onPressed: _markSelectedAsRead,
                    icon: Icon(
                      Icons.mark_email_read,
                      color: Colors.white,
                    ),
                  ),
                if (_selectedItems.isNotEmpty)
                  IconButton(
                    onPressed: _deleteSelected,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          // Debug buttons (remove in production)
          if (!_selectMode)
            Row(
              children: [
                IconButton(
                  onPressed: _debugCheckStorage,
                  icon: Icon(
                    Icons.bug_report,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: _debugAddTestNotification,
                  icon: Icon(
                    Icons.add_alert,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: _debugClearStorage,
                  icon: Icon(
                    Icons.clear_all,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterTab('all', 'ทั้งหมด'),
          SizedBox(width: 10),
          _buildFilterTab('unread', 'ยังไม่อ่าน'),
          SizedBox(width: 10),
          _buildFilterTab('read', 'อ่านแล้ว'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String type, String label) {
    bool isSelected = _filterType == type;
    int count = _getFilterCount(type);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = type;
            _selectMode = false;
            _selectedItems.clear();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Color(0xFF8B4A9F) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Color(0xFF8B4A9F) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'กำลังโหลดข้อความ...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    List<NotificationItem> filteredNotifications = _getFilteredNotifications();
    
    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(filteredNotifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ไม่มีข้อความในหมวดหมู่นี้',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    bool isSelected = _selectedItems.contains(notification.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _selectMode
            ? Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItems.add(notification.id);
                    } else {
                      _selectedItems.remove(notification.id);
                    }
                  });
                },
                activeColor: Color(0xFF8B4A9F),
              )
            : Icon(
                Icons.notifications,
                color: notification.isRead ? Colors.grey : Color(0xFF8B4A9F),
                size: 20,
              ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            color: notification.isRead ? Colors.grey.shade600 : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          notification.message,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _selectMode
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF8B4A9F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'read':
                          _markAsRead(notification.id);
                          break;
                        case 'delete':
                          _deleteNotification(notification.id);
                          break;
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'read',
                        child: Row(
                          children: [
                            Icon(
                              notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                              color: Color(0xFF8B4A9F),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              notification.isRead ? 'ทำเครื่องหมายยังไม่อ่าน' : 'ทำเครื่องหมายอ่านแล้ว',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('ลบ', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        onTap: () {
          if (_selectMode) {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(notification.id);
              } else {
                _selectedItems.add(notification.id);
              }
            });
          } else {
            _markAsRead(notification.id);
            _showNotificationDetail(notification);
          }
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'info':
        icon = Icons.info;
        color = Colors.blue;
        break;
      case 'warning':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'error':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'success':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Color(0xFF8B4A9F);
    }
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  List<NotificationItem> _getFilteredNotifications() {
    switch (_filterType) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      default:
        return _notifications;
    }
  }

  int _getFilterCount(String type) {
    switch (type) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).length;
      case 'read':
        return _notifications.where((n) => n.isRead).length;
      default:
        return _notifications.length;
    }
  }

  String _getEmptyStateMessage() {
    switch (_filterType) {
      case 'unread':
        return 'ไม่มีข้อความที่ยังไม่อ่าน';
      case 'read':
        return 'ไม่มีข้อความที่อ่านแล้ว';
      default:
        return 'ไม่มีข้อความ';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }


  Future<void> _loadNotifications() async {
    try {
      List<NotificationItem> notifications = [];
      
      // Always load FCM notifications from storage first
      String? storageData = await AuthStorage.get('mailbox');
      if (storageData != null && storageData.isNotEmpty) {
        try {
          List<dynamic> storedNotifications = jsonDecode(storageData);
          List<NotificationItem> fcmNotifications = storedNotifications.map((data) {
            return NotificationItem(
              id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: data['title'] ?? 'Notification',
              message: data['message'] ?? 'You have a new message',
              type: data['type'] ?? 'info',
              isRead: data['isRead'] ?? false,
              createdAt: data['createdAt'] != null 
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now(),
              userId: data['userId'] ?? 'fcm_user',
            );
          }).toList();
          
          notifications.addAll(fcmNotifications);
          print('Loaded ${fcmNotifications.length} FCM notifications from storage');
        } catch (e) {
          print('Error parsing stored notifications: $e');
        }
      }
      
      // Try to load from Firestore and add to the list
      String? userId = await AuthStorage.get('user_id');
      if (userId != null) {
        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

          List<NotificationItem> firestoreNotifications = querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return NotificationItem(
              id: doc.id,
              title: data['title'] ?? '',
              message: data['message'] ?? '',
              type: data['type'] ?? 'info',
              isRead: data['isRead'] ?? false,
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              userId: data['userId'] ?? '',
            );
          }).toList();
          
          notifications.addAll(firestoreNotifications);
          print('Loaded ${firestoreNotifications.length} notifications from Firestore');
        } catch (e) {
          print('Error loading from Firestore: $e');
        }
      }
      
      // No sample notifications - only use FCM and Firestore data
      print('No sample notifications added - using only FCM and Firestore data');
      
      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
      
      print('Total notifications loaded: ${notifications.length}');
    } catch (e) {
      print('Error loading notifications: $e');
      // On error, show empty list
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  void _markAsRead(String notificationId) async {
    try {
      // Update local state first
      setState(() {
        int index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index].isRead = true;
        }
      });
      
      
      // Check if it's an FCM notification (stored in storage)
      String? storageData = await AuthStorage.get('mailbox');
      if (storageData != null && storageData.isNotEmpty) {
        try {
          List<dynamic> storedNotifications = jsonDecode(storageData);
          bool updated = false;
          
          for (int i = 0; i < storedNotifications.length; i++) {
            if (storedNotifications[i]['id'] == notificationId) {
              storedNotifications[i]['isRead'] = true;
              updated = true;
              break;
            }
          }
          
          if (updated) {
            String jsonString = jsonEncode(storedNotifications);
            await AuthStorage.set('mailbox', jsonString);
            print('Updated FCM notification in storage');
            return;
          }
        } catch (e) {
          print('Error updating FCM notification: $e');
        }
      }
      
      // Try to update in Firestore if not found in storage
      try {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
        print('Updated Firestore notification');
      } catch (e) {
        print('Error updating Firestore notification: $e');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void _markSelectedAsRead() async {
    try {
      // Store selected items before clearing
      Set<String> selectedItemsCopy = Set.from(_selectedItems);
      
      // Update local state first
      setState(() {
        for (String id in selectedItemsCopy) {
          int index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            _notifications[index].isRead = true;
          }
        }
        _selectedItems.clear();
        _selectMode = false;
      });
      
      // Separate different types of notifications
      List<String> fcmIds = [];
      List<String> firestoreIds = [];
      
      // Get storage data once to check which IDs are FCM notifications
      String? storageData = await AuthStorage.get('mailbox');
      List<dynamic> storedNotifications = [];
      
      if (storageData != null && storageData.isNotEmpty) {
        try {
          storedNotifications = jsonDecode(storageData);
        } catch (e) {
          print('Error parsing storage data: $e');
        }
      }
      
      for (String id in selectedItemsCopy) {
        // Check if it's an FCM notification by checking storage
        bool foundInStorage = storedNotifications.any((notification) => notification['id'] == id);
        if (foundInStorage) {
          fcmIds.add(id);
        } else {
          firestoreIds.add(id);
        }
      }
      
      // Update FCM notifications in storage
      if (fcmIds.isNotEmpty && storedNotifications.isNotEmpty) {
        try {
          for (String id in fcmIds) {
            for (int i = 0; i < storedNotifications.length; i++) {
              if (storedNotifications[i]['id'] == id) {
                storedNotifications[i]['isRead'] = true;
              }
            }
          }
          
          String jsonString = jsonEncode(storedNotifications);
          await AuthStorage.set('mailbox', jsonString);
          print('Updated ${fcmIds.length} FCM notifications in storage');
        } catch (e) {
          print('Error updating FCM notifications: $e');
        }
      }
      
      // Update Firestore notifications
      if (firestoreIds.isNotEmpty) {
        try {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          
          for (String id in firestoreIds) {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection('notifications')
                .doc(id);
            batch.update(docRef, {'isRead': true});
          }
          
          await batch.commit();
          print('Updated ${firestoreIds.length} Firestore notifications');
        } catch (e) {
          print('Error updating Firestore notifications: $e');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ทำเครื่องหมายอ่านแล้วเรียบร้อย'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error marking selected as read: $e');
    }
  }

  void _deleteNotification(String notificationId) async {
    try {
      print('=== DELETE NOTIFICATION ===');
      print('Attempting to delete notification ID: $notificationId');
      
      bool deletedSuccessfully = false;
      String deleteSource = '';
      
      // 1. FCM NOTIFICATIONS: Check if it's stored in AuthStorage
      String? storageData = await AuthStorage.get('mailbox');
      if (storageData != null && storageData.isNotEmpty) {
        try {
          List<dynamic> storedNotifications = jsonDecode(storageData);
          int originalLength = storedNotifications.length;
          print('Found $originalLength notifications in storage');
          
          // Check if this notification exists in storage
          bool foundInStorage = storedNotifications.any((notification) => 
            notification['id'].toString() == notificationId);
          
          if (foundInStorage) {
            print('Found notification in FCM storage, deleting...');
            // Remove from storage
            storedNotifications.removeWhere((notification) => 
              notification['id'].toString() == notificationId);
            
            print('Notifications after removal: ${storedNotifications.length}');
            
            // Save back to storage
            String jsonString = jsonEncode(storedNotifications);
            await AuthStorage.set('mailbox', jsonString);
            
            // Remove from UI
            setState(() {
              _notifications.removeWhere((n) => n.id == notificationId);
            });
            
            deletedSuccessfully = true;
            deleteSource = 'FCM storage';
            print('Successfully deleted from FCM storage');
          } else {
            print('Notification not found in FCM storage, trying Firestore...');
            
            // FIRESTORE NOTIFICATIONS: Try to delete from Firestore
            try {
              await FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(notificationId)
                  .delete();
              
              // Remove from UI
              setState(() {
                _notifications.removeWhere((n) => n.id == notificationId);
              });
              
              deletedSuccessfully = true;
              deleteSource = 'Firestore';
              print('Successfully deleted from Firestore');
            } catch (e) {
              print('Error deleting from Firestore: $e');
              
              // If Firestore fails, still remove from UI (might be a display-only notification)
              setState(() {
                _notifications.removeWhere((n) => n.id == notificationId);
              });
              deletedSuccessfully = true;
              deleteSource = 'UI only (Firestore failed)';
            }
          }
        } catch (e) {
          print('Error parsing storage data: $e');
          // If storage parsing fails, still try to remove from UI
          setState(() {
            _notifications.removeWhere((n) => n.id == notificationId);
          });
          deletedSuccessfully = true;
          deleteSource = 'UI only (storage parse failed)';
        }
      } else {
        print('No storage data found, trying Firestore...');
        
        // No storage data, try Firestore
        try {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notificationId)
              .delete();
          
          setState(() {
            _notifications.removeWhere((n) => n.id == notificationId);
          });
          
          deletedSuccessfully = true;
          deleteSource = 'Firestore';
          print('Successfully deleted from Firestore');
        } catch (e) {
          print('Error deleting from Firestore: $e');
          
          // Still remove from UI
          setState(() {
            _notifications.removeWhere((n) => n.id == notificationId);
          });
          deletedSuccessfully = true;
          deleteSource = 'UI only';
        }
      }
      
      print('Delete operation completed. Source: $deleteSource');
      print('========================');
      
      if (deletedSuccessfully) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบข้อความเรียบร้อย ($deleteSource)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถลบข้อความได้'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      print('Error in delete operation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบข้อความ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteSelected() async {
    try {
      print('=== DELETING SELECTED NOTIFICATIONS ===');
      print('Selected items count: ${_selectedItems.length}');

      // Separate different types of notifications to handle accordingly
      Set<String> fcmIds = Set();
      Set<String> firestoreIds = Set();

      String? storageData = await AuthStorage.get('mailbox');
      List<dynamic> storedNotifications = storageData != null && storageData.isNotEmpty ? jsonDecode(storageData) : [];

      for (String id in _selectedItems) {
        if (storedNotifications.any((notification) => notification['id'].toString() == id)) {
          fcmIds.add(id);
        } else {
          firestoreIds.add(id);
        }
      }

      print('FCM IDs: ${fcmIds.length}, Firestore IDs: ${firestoreIds.length}');

      // Handle deletion of FCM notifications
      if (fcmIds.isNotEmpty) {
        storedNotifications.removeWhere((notification) => fcmIds.contains(notification['id'].toString()));

        await AuthStorage.set('mailbox', jsonEncode(storedNotifications));
        print('Deleted FCM notifications from storage');
      }

      // Handle Firestore
      if (firestoreIds.isNotEmpty) {
        try {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (String id in firestoreIds) {
            batch.delete(FirebaseFirestore.instance.collection('notifications').doc(id));
          }
          await batch.commit();
          print('Deleted Firestore notifications');
        } catch (e) {
          print('Error deleting Firestore notifications: $e');
        }
      }

      // Update local list and state
      setState(() {
        _notifications.removeWhere((n) => _selectedItems.contains(n.id));
        _selectedItems.clear();
        _selectMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อความเรียบร้อย (${fcmIds.length + firestoreIds.length} รายการ)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting selected notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบข้อความ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Debug method to check storage data (remove in production)
  void _debugCheckStorage() async {
    try {
      String? storageData = await AuthStorage.get('mailbox');
      print('=== STORAGE DEBUG ===');
      print('Storage data exists: ${storageData != null}');
      print('Storage data empty: ${storageData?.isEmpty ?? true}');
      
      if (storageData != null && storageData.isNotEmpty) {
        List<dynamic> storedNotifications = jsonDecode(storageData);
        print('Total notifications in storage: ${storedNotifications.length}');
        print('Current UI notifications: ${_notifications.length}');
        
        // Show all notification IDs and types
        for (int i = 0; i < storedNotifications.length; i++) {
          print('Storage[$i]: ID=${storedNotifications[i]['id']}, Title=${storedNotifications[i]['title']}');
        }
        
        // Show UI notification IDs
        print('--- UI NOTIFICATIONS ---');
        for (int i = 0; i < _notifications.length && i < 5; i++) {
          print('UI[$i]: ID=${_notifications[i].id}, Title=${_notifications[i].title}');
        }
        print('==================');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage: ${storedNotifications.length}, UI: ${_notifications.length} (check console)'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        print('No data in storage');
        print('Current UI notifications: ${_notifications.length}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data in storage, UI: ${_notifications.length}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error checking storage: $e');
    }
  }

  // Debug method to add a test FCM notification (remove in production)
  void _debugAddTestNotification() async {
    try {
      // Create test notification data
      Map<String, dynamic> testNotification = {
        'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Test FCM Notification',
        'message': 'This is a test notification saved to storage',
        'type': 'info',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': 'fcm_user',
        'data': {'test': 'true'},
      };
      
      // Get existing notifications
      String? existingData = await AuthStorage.get('mailbox');
      List<dynamic> notifications = [];
      
      if (existingData != null && existingData.isNotEmpty) {
        try {
          notifications = jsonDecode(existingData);
        } catch (e) {
          print('Error parsing existing data: $e');
        }
      }
      
      // Add test notification
      notifications.insert(0, testNotification);
      
      // Save to storage
      String jsonString = jsonEncode(notifications);
      await AuthStorage.set('mailbox', jsonString);
      
      print('Added test FCM notification to storage');
      
      // Refresh the UI
      await _loadNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added test FCM notification'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding test notification: $e');
    }
  }

  // Debug method to clear all storage (remove in production)
  void _debugClearStorage() async {
    try {
      await AuthStorage.set('mailbox', '');
      print('Cleared all FCM notification storage');
      
      // Refresh the UI
      await _loadNotifications();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared FCM storage and refreshed'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }

  void _showNotificationDetail(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              _buildNotificationIcon(notification.type),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ปิด',
                style: TextStyle(color: Color(0xFF8B4A9F)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final DateTime createdAt;
  final String userId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.userId,
  });
}