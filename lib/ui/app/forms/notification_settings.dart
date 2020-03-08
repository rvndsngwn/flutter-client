import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/user_model.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_dropdown_button.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({
    @required this.user,
    @required this.onChanged,
  });

  final UserEntity user;
  final Function(String, List<String>) onChanged;

  static const NOTIFY_USER = 'user';
  static const NOTIFY_ALL = 'all';
  static const NOTIFY_NONE = 'none';
  static const NOTIFY_CUSTOM = 'custom';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final notifications =
        user.userCompany.notifications ?? BuiltMap<String, BuiltList<String>>();
    final BuiltList<String> emailNotifications =
        notifications.containsKey(kNotificationChannelEmail)
            ? notifications[kNotificationChannelEmail]
            : BuiltList<String>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DataTable(
                columns: [
                  DataColumn(
                    label: SizedBox(),
                  ),
                  DataColumn(
                    label: Text(localization.email),
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text(localization.all)),
                    DataCell(_NotificationSelector(
                      value: emailNotifications.contains(kNotificationsAll)
                          ? NOTIFY_ALL
                          : NOTIFY_NONE,
                      addCustom: true,
                      onChanged: (value) {
                        onChanged(
                            kNotificationChannelEmail,
                            value == NOTIFY_ALL
                                ? [kNotificationsAll]
                                : value == NOTIFY_USER
                                    ? [kNotificationsAllUser]
                                    : []);
                      },
                    ))
                  ]),
                  ...kNotificationEvents.map((eventType) {
                    String value;
                    if (emailNotifications.contains('all_notifications')) {
                      value = NOTIFY_ALL;
                    } else if (emailNotifications
                        .contains('all_user_notifications')) {
                      value = NOTIFY_USER;
                    } else if (emailNotifications
                        .contains('${eventType}_all')) {
                      value = NOTIFY_ALL;
                    } else if (emailNotifications
                        .contains('${eventType}_user')) {
                      value = NOTIFY_USER;
                    } else {
                      value = NOTIFY_NONE;
                    }
                    return DataRow(cells: [
                      DataCell(Text(localization.lookup(eventType))),
                      DataCell(_NotificationSelector(
                        value: value,
                        onChanged: (value) {
                          final options = emailNotifications.toList();
                          options.remove('${eventType}_all');
                          options.remove('${eventType}_user');
                          if (value == NOTIFY_ALL) {
                            options.add('${eventType}_all');
                          } else if (value == NOTIFY_USER) {
                            options.add('${eventType}_user');
                          }
                          onChanged(kNotificationChannelEmail, options);
                        },
                      )),
                    ]);
                  }).toList(),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class _NotificationSelector extends StatelessWidget {
  const _NotificationSelector({
    @required this.value,
    @required this.onChanged,
    this.addCustom = false,
  });

  final bool addCustom;
  final String value;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return AppDropdownButton<String>(
      value: value,
      //enabled: false,
      onChanged: (dynamic value) {
        onChanged(value);
      },
      items: [
        DropdownMenuItem(
          value: NotificationSettings.NOTIFY_ALL,
          child: Text(localization.all),
        ),
        DropdownMenuItem(
          value: NotificationSettings.NOTIFY_USER,
          child: Text(localization.mine),
        ),
        DropdownMenuItem(
          value: NotificationSettings.NOTIFY_NONE,
          child: Text(localization.none),
        ),
        if (addCustom)
          DropdownMenuItem(
            value: NotificationSettings.NOTIFY_CUSTOM,
            child: Text(localization.custom),
          ),
      ],
    );
  }
}
