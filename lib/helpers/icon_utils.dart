import 'package:flutter/cupertino.dart';

enum TaskListIcon {
  listBullet,
  bagFill,
  cartFill,
  bookmarkFill,
  locationNorthFill,
  giftFill,
  bookFill,
  alarmFill,
  archiveboxFill,
  bandage,
  briefcaseFill,
  burstFill,
  snow,
  sunMaxFill,
  moonFill,
  flame,
  airplane,
  musicNote2,
  gameControllerSolid,
}

extension TaskListIconExtension on TaskListIcon {
  IconData get iconData {
    switch (this) {
      case TaskListIcon.listBullet:
        return CupertinoIcons.list_bullet;
      case TaskListIcon.bagFill:
        return CupertinoIcons.bag_fill;
      case TaskListIcon.cartFill:
        return CupertinoIcons.cart_fill;
      case TaskListIcon.bookmarkFill:
        return CupertinoIcons.bookmark_fill;
      case TaskListIcon.locationNorthFill:
        return CupertinoIcons.location_north_fill;
      case TaskListIcon.giftFill:
        return CupertinoIcons.gift_fill;
      case TaskListIcon.bookFill:
        return CupertinoIcons.book_fill;
      case TaskListIcon.alarmFill:
        return CupertinoIcons.alarm_fill;
      case TaskListIcon.archiveboxFill:
        return CupertinoIcons.archivebox_fill;
      case TaskListIcon.bandage:
        return CupertinoIcons.bandage;
      case TaskListIcon.briefcaseFill:
        return CupertinoIcons.briefcase_fill;
      case TaskListIcon.burstFill:
        return CupertinoIcons.burst_fill;
      case TaskListIcon.snow:
        return CupertinoIcons.snow;
      case TaskListIcon.sunMaxFill:
        return CupertinoIcons.sun_max_fill;
      case TaskListIcon.moonFill:
        return CupertinoIcons.moon_fill;
      case TaskListIcon.flame:
        return CupertinoIcons.flame;
      case TaskListIcon.airplane:
        return CupertinoIcons.airplane;
      case TaskListIcon.musicNote2:
        return CupertinoIcons.music_note_2;
      case TaskListIcon.gameControllerSolid:
        return CupertinoIcons.game_controller_solid;
      default:
        return CupertinoIcons.list_bullet; // Default icon
    }
  }
}
