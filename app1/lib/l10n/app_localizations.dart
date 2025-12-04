import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // サポートする言語
  static const List<Locale> supportedLocales = [
    Locale('ja', 'JP'), // 日本語
    Locale('en', 'US'), // 英語
    Locale('zh', 'CN'), // 中国語
  ];

  // 言語名を取得
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return '日本語';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return locale.languageCode;
    }
  }

  // 翻訳データ
  static final Map<String, Map<String, String>> _localizedValues = {
    'ja': {
      // 共通
      'appTitle': 'カレンダー',
      'cancel': 'キャンセル',
      'save': '保存',
      'delete': '削除',
      'edit': '編集',
      'add': '追加',
      'confirm': '確認',
      'update': '更新',
      'close': '閉じる',
      'create': '作成',

      // ナビゲーション
      'calendar': 'カレンダー',
      'graph': 'グラフ',
      'menu': 'メニュー',

      // カレンダー画面
      'selectCalendar': 'カレンダー選択',
      'categorySettings': 'カテゴリ設定',
      'noCategories': 'カテゴリがありません',
      'addCategory': 'カテゴリを追加',
      'memo': 'メモ',
      'memoPlaceholder': 'メモを入力...',
      'photos': '写真',
      'addPhoto': '追加',
      'noPhotos': '写真がありません',
      'deletePhoto': '写真を削除',
      'deletePhotoConfirm': 'この写真を削除しますか？',

      // カレンダー設定
      'addNewCalendar': '新しいカレンダーを追加',
      'editCalendar': 'カレンダーを編集',
      'newCalendar': '新しいカレンダー',
      'calendarName': 'カレンダー名',
      'calendarNamePlaceholder': 'カレンダー名を入力',
      'color': 'カラー',
      'changeColor': 'カラーを変更',
      'tapToChangeColor': '色をタップで変更',
      'changeName': '名前を変更',
      'minOneCalendar': '最低1つのカレンダーが必要です',
      'deleteCalendarConfirm': 'を削除しますか？\n関連するすべてのデータも削除されます。',
      'duplicateCalendarName': 'この名前は既に使われています',
      'enterCalendarName': 'カレンダー名を入力してください',

      // カテゴリ設定
      'maxCategories': '最大3つのカテゴリを設定できます',
      'noCategory': 'カテゴリがありません\n追加してください',
      'newCategory': '新しいカテゴリ',
      'editCategory': 'カテゴリを編集',
      'categoryName': 'カテゴリ名',
      'categoryNamePlaceholder': 'カテゴリ名を入力',
      'maxCategoriesReached': 'カテゴリは最大3つまでです',
      'deleteCategoryConfirm': 'を削除しますか？\n関連するすべてのデータも削除されます。',
      'numericInput': '数値入力',
      'duplicateCategoryName': 'この名前は既に使われています',
      'enterCategoryName': 'カテゴリ名を入力してください',

      // グラフ画面
      'pieChart': '円グラフ',
      'lineChart': '折れ線',
      'day': '日',
      'week': '週',
      'month': '月',
      'dailyTotal': '1日の合計',
      'byCategory': 'カテゴリごと',
      'noData': 'データがありません',
      'total': '合計',

      // 曜日
      'sunday': '日',
      'monday': '月',
      'tuesday': '火',
      'wednesday': '水',
      'thursday': '木',
      'friday': '金',
      'saturday': '土',
      'dayOfWeek': '曜日',

      // カレンダー設定メニュー
      'calendarSettingsTitle': 'カレンダー設定',

      // メニュー画面
      'themeSettings': 'テーマ設定',
      'themeMode': 'テーマモード',
      'darkMode': 'ダークモード',
      'lightMode': 'ライトモード',
      'calendarManagement': 'カレンダー管理',
      'calendarSettingsDesc': 'カレンダーの追加・編集・削除',
      'categorySettingsMenu': 'カテゴリ設定',
      'categorySettingsDesc': 'カテゴリの設定',
      'appInfo': 'アプリ情報',
      'version': 'バージョン',
      'languageSettings': '言語設定',
      'language': '言語',
      'selectLanguage': '言語を選択',

      // 写真
      'addPhotoTitle': '写真を追加',
      'takePhoto': 'カメラで撮影',
      'chooseFromLibrary': 'ライブラリから選択',
      'photoAddFailed': '写真の追加に失敗しました',
      'photoDeleteFailed': '写真の削除に失敗しました',
      'imageLoadFailed': '画像を読み込めませんでした',

      // 初回起動
      'welcome': 'ようこそ',
      'selectLanguageDesc': '使用する言語を選択してください',
    },
    'en': {
      // Common
      'appTitle': 'Calendar',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'update': 'Update',
      'close': 'Close',
      'create': 'Create',

      // Navigation
      'calendar': 'Calendar',
      'graph': 'Graph',
      'menu': 'Menu',

      // Calendar screen
      'selectCalendar': 'Select Calendar',
      'categorySettings': 'Category Settings',
      'noCategories': 'No categories',
      'addCategory': 'Add category',
      'memo': 'Memo',
      'memoPlaceholder': 'Enter memo...',
      'photos': 'Photos',
      'addPhoto': 'Add',
      'noPhotos': 'No photos',
      'deletePhoto': 'Delete photo',
      'deletePhotoConfirm': 'Delete this photo?',

      // Calendar settings
      'addNewCalendar': 'Add new calendar',
      'editCalendar': 'Edit calendar',
      'newCalendar': 'New calendar',
      'calendarName': 'Calendar name',
      'calendarNamePlaceholder': 'Enter calendar name',
      'color': 'Color',
      'changeColor': 'Change color',
      'tapToChangeColor': 'Tap to change color',
      'changeName': 'Change name',
      'minOneCalendar': 'At least one calendar is required',
      'deleteCalendarConfirm':
          ' will be deleted.\nAll related data will also be deleted.',
      'duplicateCalendarName': 'This name is already in use',
      'enterCalendarName': 'Please enter a calendar name',

      // Category settings
      'maxCategories': 'You can set up to 3 categories',
      'noCategory': 'No categories\nPlease add one',
      'newCategory': 'New category',
      'editCategory': 'Edit category',
      'categoryName': 'Category name',
      'categoryNamePlaceholder': 'Enter category name',
      'maxCategoriesReached': 'Maximum 3 categories allowed',
      'deleteCategoryConfirm':
          ' will be deleted.\nAll related data will also be deleted.',
      'numericInput': 'Numeric input',
      'duplicateCategoryName': 'This name is already in use',
      'enterCategoryName': 'Please enter a category name',

      // Graph screen
      'pieChart': 'Pie Chart',
      'lineChart': 'Line Chart',
      'day': 'Day',
      'week': 'Week',
      'month': 'Month',
      'dailyTotal': 'Daily Total',
      'byCategory': 'By Category',
      'noData': 'No data',
      'total': 'Total',

      // Weekdays
      'sunday': 'Sun',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'dayOfWeek': '',

      // Calendar settings menu
      'calendarSettingsTitle': 'Calendar Settings',

      // Menu screen
      'themeSettings': 'Theme Settings',
      'themeMode': 'Theme Mode',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'calendarManagement': 'Calendar Management',
      'calendarSettingsDesc': 'Add, edit, delete calendars',
      'categorySettingsMenu': 'Category Settings',
      'categorySettingsDesc': 'Category settings',
      'appInfo': 'App Info',
      'version': 'Version',
      'languageSettings': 'Language Settings',
      'language': 'Language',
      'selectLanguage': 'Select Language',

      // Photos
      'addPhotoTitle': 'Add photo',
      'takePhoto': 'Take photo',
      'chooseFromLibrary': 'Choose from library',
      'photoAddFailed': 'Failed to add photo',
      'photoDeleteFailed': 'Failed to delete photo',
      'imageLoadFailed': 'Failed to load image',

      // First launch
      'welcome': 'Welcome',
      'selectLanguageDesc': 'Please select your language',
    },
    'zh': {
      // 共通
      'appTitle': '日历',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'confirm': '确认',
      'update': '更新',
      'close': '关闭',
      'create': '创建',

      // 导航
      'calendar': '日历',
      'graph': '图表',
      'menu': '菜单',

      // 日历画面
      'selectCalendar': '选择日历',
      'categorySettings': '类别设置',
      'noCategories': '没有类别',
      'addCategory': '添加类别',
      'memo': '备忘录',
      'memoPlaceholder': '输入备忘录...',
      'photos': '照片',
      'addPhoto': '添加',
      'noPhotos': '没有照片',
      'deletePhoto': '删除照片',
      'deletePhotoConfirm': '删除这张照片？',

      // 日历设置
      'addNewCalendar': '添加新日历',
      'editCalendar': '编辑日历',
      'newCalendar': '新日历',
      'calendarName': '日历名称',
      'calendarNamePlaceholder': '输入日历名称',
      'color': '颜色',
      'changeColor': '更改颜色',
      'tapToChangeColor': '点击更改颜色',
      'changeName': '更改名称',
      'minOneCalendar': '至少需要一个日历',
      'deleteCalendarConfirm': '将被删除。\n所有相关数据也将被删除。',
      'duplicateCalendarName': '此名称已被使用',
      'enterCalendarName': '请输入日历名称',

      // 类别设置
      'maxCategories': '最多可以设置3个类别',
      'noCategory': '没有类别\n请添加',
      'newCategory': '新类别',
      'editCategory': '编辑类别',
      'categoryName': '类别名称',
      'categoryNamePlaceholder': '输入类别名称',
      'maxCategoriesReached': '最多只能有3个类别',
      'deleteCategoryConfirm': '将被删除。\n所有相关数据也将被删除。',
      'numericInput': '数字输入',
      'duplicateCategoryName': '此名称已被使用',
      'enterCategoryName': '请输入类别名称',

      // 图表画面
      'pieChart': '饼图',
      'lineChart': '折线图',
      'day': '日',
      'total': '合计',

      // 星期
      'sunday': '日',
      'monday': '一',
      'tuesday': '二',
      'wednesday': '三',
      'thursday': '四',
      'friday': '五',
      'saturday': '六',
      'dayOfWeek': '',

      // 日历设置菜单
      'calendarSettingsTitle': '日历设置',

      // 继续
      'week': '周',
      'month': '月',
      'dailyTotal': '每日总计',
      'byCategory': '按类别',
      'noData': '没有数据',

      // 菜单画面
      'themeSettings': '主题设置',
      'themeMode': '主题模式',
      'darkMode': '深色模式',
      'lightMode': '浅色模式',
      'calendarManagement': '日历管理',
      'calendarSettingsDesc': '添加、编辑、删除日历',
      'categorySettingsMenu': '类别设置',
      'categorySettingsDesc': '类别设置',
      'appInfo': '应用信息',
      'version': '版本',
      'languageSettings': '语言设置',
      'language': '语言',
      'selectLanguage': '选择语言',

      // 照片
      'addPhotoTitle': '添加照片',
      'takePhoto': '拍照',
      'chooseFromLibrary': '从相册选择',
      'photoAddFailed': '添加照片失败',
      'photoDeleteFailed': '删除照片失败',
      'imageLoadFailed': '无法加载图片',

      // 首次启动
      'welcome': '欢迎',
      'selectLanguageDesc': '请选择您的语言',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // 便利なゲッター
  String get appTitle => translate('appTitle');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get confirm => translate('confirm');
  String get update => translate('update');
  String get close => translate('close');
  String get create => translate('create');

  // Navigation
  String get calendar => translate('calendar');
  String get graph => translate('graph');
  String get menu => translate('menu');

  // Calendar screen
  String get selectCalendar => translate('selectCalendar');
  String get categorySettings => translate('categorySettings');
  String get noCategories => translate('noCategories');
  String get addCategory => translate('addCategory');
  String get memo => translate('memo');
  String get memoPlaceholder => translate('memoPlaceholder');
  String get photos => translate('photos');
  String get addPhoto => translate('addPhoto');
  String get noPhotos => translate('noPhotos');
  String get deletePhoto => translate('deletePhoto');
  String get deletePhotoConfirm => translate('deletePhotoConfirm');

  // Calendar settings
  String get addNewCalendar => translate('addNewCalendar');
  String get editCalendar => translate('editCalendar');
  String get newCalendar => translate('newCalendar');
  String get calendarName => translate('calendarName');
  String get calendarNamePlaceholder => translate('calendarNamePlaceholder');
  String get color => translate('color');
  String get changeColor => translate('changeColor');
  String get tapToChangeColor => translate('tapToChangeColor');
  String get changeName => translate('changeName');
  String get minOneCalendar => translate('minOneCalendar');
  String get deleteCalendarConfirm => translate('deleteCalendarConfirm');
  String get duplicateCalendarName => translate('duplicateCalendarName');
  String get enterCalendarName => translate('enterCalendarName');

  // Category settings
  String get maxCategories => translate('maxCategories');
  String get noCategory => translate('noCategory');
  String get newCategory => translate('newCategory');
  String get editCategory => translate('editCategory');
  String get categoryName => translate('categoryName');
  String get categoryNamePlaceholder => translate('categoryNamePlaceholder');
  String get maxCategoriesReached => translate('maxCategoriesReached');
  String get deleteCategoryConfirm => translate('deleteCategoryConfirm');
  String get numericInput => translate('numericInput');
  String get duplicateCategoryName => translate('duplicateCategoryName');
  String get enterCategoryName => translate('enterCategoryName');

  // Graph screen
  String get pieChart => translate('pieChart');
  String get lineChart => translate('lineChart');
  String get day => translate('day');
  String get week => translate('week');
  String get month => translate('month');
  String get dailyTotal => translate('dailyTotal');
  String get byCategory => translate('byCategory');
  String get noData => translate('noData');
  String get total => translate('total');

  // Weekdays
  String get sunday => translate('sunday');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get dayOfWeek => translate('dayOfWeek');

  // Calendar settings menu
  String get calendarSettingsTitle => translate('calendarSettingsTitle');

  // Menu screen
  String get themeSettings => translate('themeSettings');
  String get themeMode => translate('themeMode');
  String get darkMode => translate('darkMode');
  String get lightMode => translate('lightMode');
  String get calendarManagement => translate('calendarManagement');
  String get calendarSettingsDesc => translate('calendarSettingsDesc');
  String get categorySettingsMenu => translate('categorySettingsMenu');
  String get categorySettingsDesc => translate('categorySettingsDesc');
  String get appInfo => translate('appInfo');
  String get version => translate('version');
  String get languageSettings => translate('languageSettings');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');

  // Photos
  String get addPhotoTitle => translate('addPhotoTitle');
  String get takePhoto => translate('takePhoto');
  String get chooseFromLibrary => translate('chooseFromLibrary');
  String get photoAddFailed => translate('photoAddFailed');
  String get photoDeleteFailed => translate('photoDeleteFailed');
  String get imageLoadFailed => translate('imageLoadFailed');

  // First launch
  String get welcome => translate('welcome');
  String get selectLanguageDesc => translate('selectLanguageDesc');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ja', 'en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
