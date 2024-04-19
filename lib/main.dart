import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Container(
          width: 200,
          color: Colors.green,
          child: MyReorderableDragBoundary(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: <Widget>[
                SliverMyReorderableList(
                  itemBuilder: (BuildContext context, int index) {
                    return MyReorderableDragStartListener(
                      key: ValueKey<int>(index),
                      index: index,
                      child: Text('$index'),
                    );
                  },
                  itemCount: 5,
                  onReorder: (int fromIndex, int toIndex) {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ));
}

/// A scrolling container that allows the user to interactively reorder the
/// list items.
///
/// This widget is similar to one created by [ListView.builder], and uses
/// an [IndexedWidgetBuilder] to create each item.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child such as a drag handle) with a drag listener that will recognize
/// the start of an item drag and then start the reorder by calling
/// [MyReorderableListState.startItemDragReorder]. This is most easily achieved
/// by wrapping each child in a [MyReorderableDragStartListener] or a
/// [MyReorderableDelayedDragStartListener]. These will take care of recognizing
/// the start of a drag gesture and call the list state's
/// [MyReorderableListState.startItemDragReorder] method.
///
/// This widget's [MyReorderableListState] can be used to manually start an item
/// reorder, or cancel a current drag. To refer to the
/// [MyReorderableListState] either provide a [GlobalKey] or use the static
/// [MyReorderableList.of] method from an item's build method.
///
/// See also:
///
///  * [SliverMyReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [MyReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class MyReorderableList extends StatefulWidget {
  /// Creates a scrolling container that allows the user to interactively
  /// reorder the list items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const MyReorderableList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
  })  : assert(itemCount >= 0),
        assert(
          (itemExtent == null && prototypeItem == null) || (itemExtent == null && itemExtentBuilder == null) || (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        );

  /// {@template flutter.widgets.MyReorderable_list.itemBuilder}
  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [IndexedWidgetBuilder] index parameter indicates the item's
  /// position in the list. The value of the index parameter will be between
  /// zero and one less than [itemCount]. All items in the list must have a
  /// unique [Key], and should have some kind of listener to start the drag
  /// (usually a [MyReorderableDragStartListener] or
  /// [MyReorderableDelayedDragStartListener]).
  /// {@endtemplate}
  final IndexedWidgetBuilder itemBuilder;

  /// {@template flutter.widgets.MyReorderable_list.itemCount}
  /// The number of items in the list.
  ///
  /// It must be a non-negative integer. When zero, nothing is displayed and
  /// the widget occupies no space.
  /// {@endtemplate}
  final int itemCount;

  /// {@template flutter.widgets.MyReorderable_list.onReorder}
  /// A callback used by the list to report that a list item has been dragged
  /// to a new location in the list and the application should update the order
  /// of the items.
  /// {@endtemplate}
  final ReorderCallback onReorder;

  /// {@template flutter.widgets.MyReorderable_list.onReorderStart}
  /// A callback that is called when an item drag has started.
  ///
  /// The index parameter of the callback is the index of the selected item.
  ///
  /// See also:
  ///
  ///   * [onReorderEnd], which is a called when the dragged item is dropped.
  ///   * [onReorder], which reports that a list item has been dragged to a new
  ///     location.
  /// {@endtemplate}
  final void Function(int index)? onReorderStart;

  /// {@template flutter.widgets.MyReorderable_list.onReorderEnd}
  /// A callback that is called when the dragged item is dropped.
  ///
  /// The index parameter of the callback is the index where the item is
  /// dropped. Unlike [onReorder], this is called even when the list item is
  /// dropped in the same location.
  ///
  /// See also:
  ///
  ///   * [onReorderStart], which is a called when an item drag has started.
  ///   * [onReorder], which reports that a list item has been dragged to a new
  ///     location.
  /// {@endtemplate}
  final void Function(int index)? onReorderEnd;

  /// {@template flutter.widgets.MyReorderable_list.proxyDecorator}
  /// A callback that allows the app to add an animated decoration around
  /// an item when it is being dragged.
  /// {@endtemplate}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// {@template flutter.widgets.MyReorderable_list.padding}
  /// The amount of space by which to inset the list contents.
  ///
  /// It defaults to `EdgeInsets.all(0)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.itemExtentBuilder}
  final ItemExtentBuilder? itemExtentBuilder;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  /// {@macro flutter.widgets.EdgeDraggingAutoScroller.velocityScalar}
  ///
  /// {@macro flutter.widgets.SliverMyReorderableList.autoScrollerVelocityScalar.default}
  final double? autoScrollerVelocityScalar;

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [MyReorderableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [MyReorderableList] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [MyReorderableList] ancestor is found.
  static MyReorderableListState of(BuildContext context) {
    final MyReorderableListState? result = context.findAncestorStateOfType<MyReorderableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('MyReorderableList.of() called with a context that does not contain a MyReorderableList.'),
          ErrorDescription(
            'No MyReorderableList ancestor could be found starting from the context that was passed to MyReorderableList.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the MyReorderableList. Please see the MyReorderableList documentation for examples '
            'of how to refer to an MyReorderableListState object:\n'
            '  https://api.flutter.dev/flutter/widgets/MyReorderableListState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [MyReorderableList] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [MyReorderableList] surrounds the context given, then this function will
  /// return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [MyReorderableList] ancestor
  ///    is found.
  static MyReorderableListState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<MyReorderableListState>();
  }

  @override
  MyReorderableListState createState() => MyReorderableListState();
}

/// The state for a list that allows the user to interactively reorder
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [MyReorderableList]'s state with a global key:
///
/// ```dart
/// GlobalKey<MyReorderableListState> listKey = GlobalKey<MyReorderableListState>();
/// // ...
/// Widget build(BuildContext context) {
///   return MyReorderableList(
///     key: listKey,
///     itemBuilder: (BuildContext context, int index) => const SizedBox(height: 10.0),
///     itemCount: 5,
///     onReorder: (int oldIndex, int newIndex) {
///        // ...
///     },
///   );
/// }
/// // ...
/// listKey.currentState!.cancelReorder();
/// ```
class MyReorderableListState extends State<MyReorderableList> {
  final GlobalKey<SliverMyReorderableListState> _sliverMyReorderableListKey = GlobalKey();

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a canceled drag.
  /// The list will take ownership of the returned recognizer and will dispose
  /// it when it is no longer needed.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [MyReorderableDragStartListener] or [MyReorderableDelayedDragStartListener]
  /// which call this for the application.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _sliverMyReorderableListKey.currentState!.startItemDragReorder(index: index, event: event, recognizer: recognizer);
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _sliverMyReorderableListKey.currentState!.cancelReorder();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverMyReorderableList(
            key: _sliverMyReorderableListKey,
            itemExtent: widget.itemExtent,
            prototypeItem: widget.prototypeItem,
            itemBuilder: widget.itemBuilder,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            onReorderStart: widget.onReorderStart,
            onReorderEnd: widget.onReorderEnd,
            proxyDecorator: widget.proxyDecorator,
            autoScrollerVelocityScalar: widget.autoScrollerVelocityScalar,
          ),
        ),
      ],
    );
  }
}

/// A sliver list that allows the user to interactively reorder the list items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the reorder by calling
/// [SliverMyReorderableListState.startItemDragReorder]. This is most easily
/// achieved by wrapping each child in a [MyReorderableDragStartListener] or
/// a [MyReorderableDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the list state's start
/// item drag method.
///
/// This widget's [SliverMyReorderableListState] can be used to manually start an item
/// reorder, or cancel a current drag that's already underway. To refer to the
/// [SliverMyReorderableListState] either provide a [GlobalKey] or use the static
/// [SliverMyReorderableList.of] method from an item's build method.
///
/// See also:
///
///  * [MyReorderableList], a regular widget list that allows the user to reorder
///    its items.
///  * [MyReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class SliverMyReorderableList extends StatefulWidget {
  /// Creates a sliver list that allows the user to interactively reorder its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverMyReorderableList({
    super.key,
    required this.itemBuilder,
    this.findChildIndexCallback,
    required this.itemCount,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    double? autoScrollerVelocityScalar,
  })  : autoScrollerVelocityScalar = autoScrollerVelocityScalar ?? _kDefaultAutoScrollVelocityScalar,
        assert(itemCount >= 0),
        assert(
          (itemExtent == null && prototypeItem == null) || (itemExtent == null && itemExtentBuilder == null) || (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        );

  // An eyeballed value for a smooth scrolling experience.
  static const double _kDefaultAutoScrollVelocityScalar = 50;

  /// {@macro flutter.widgets.MyReorderable_list.itemBuilder}
  final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.SliverChildBuilderDelegate.findChildIndexCallback}
  final ChildIndexGetter? findChildIndexCallback;

  /// {@macro flutter.widgets.MyReorderable_list.itemCount}
  final int itemCount;

  /// {@macro flutter.widgets.MyReorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.MyReorderable_list.onReorderStart}
  final void Function(int)? onReorderStart;

  /// {@macro flutter.widgets.MyReorderable_list.onReorderEnd}
  final void Function(int)? onReorderEnd;

  /// {@macro flutter.widgets.MyReorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.itemExtentBuilder}
  final ItemExtentBuilder? itemExtentBuilder;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  /// {@macro flutter.widgets.EdgeDraggingAutoScroller.velocityScalar}
  ///
  /// {@template flutter.widgets.SliverMyReorderableList.autoScrollerVelocityScalar.default}
  /// Defaults to 50 if not set or set to null.
  /// {@endtemplate}
  final double autoScrollerVelocityScalar;

  @override
  SliverMyReorderableListState createState() => SliverMyReorderableListState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverMyReorderableList] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverMyReorderableList] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverMyReorderableList] ancestor is found.
  static SliverMyReorderableListState of(BuildContext context) {
    final SliverMyReorderableListState? result = context.findAncestorStateOfType<SliverMyReorderableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverMyReorderableList.of() called with a context that does not contain a SliverMyReorderableList.',
          ),
          ErrorDescription(
            'No SliverMyReorderableList ancestor could be found starting from the context that was passed to SliverMyReorderableList.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the SliverMyReorderableList. Please see the SliverMyReorderableList documentation for examples '
            'of how to refer to an SliverMyReorderableList object:\n'
            '  https://api.flutter.dev/flutter/widgets/SliverMyReorderableListState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverMyReorderableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverMyReorderableList] surrounds the context given, this function
  /// will return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverMyReorderableList]
  ///    ancestor is found.
  static SliverMyReorderableListState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverMyReorderableListState>();
  }
}

/// The state for a sliver list that allows the user to interactively reorder
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverMyReorderableList]'s state with a global key:
///
/// ```dart
/// // (e.g. in a stateful widget)
/// GlobalKey<SliverMyReorderableListState> listKey = GlobalKey<SliverMyReorderableListState>();
///
/// // ...
///
/// @override
/// Widget build(BuildContext context) {
///   return SliverMyReorderableList(
///     key: listKey,
///     itemBuilder: (BuildContext context, int index) => const SizedBox(height: 10.0),
///     itemCount: 5,
///     onReorder: (int oldIndex, int newIndex) {
///        // ...
///     },
///   );
/// }
///
/// // ...
///
/// void _stop() {
///   listKey.currentState!.cancelReorder();
/// }
/// ```
///
/// [MyReorderableDragStartListener] and [MyReorderableDelayedDragStartListener]
/// refer to their [SliverMyReorderableList] with the static
/// [SliverMyReorderableList.of] method.
class SliverMyReorderableListState extends State<SliverMyReorderableList> with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final Map<int, _MyReorderableItemState> _items = <int, _MyReorderableItemState>{};

  OverlayEntry? _overlayEntry;
  int? _dragIndex;
  _DragInfo? _dragInfo;
  int? _insertIndex;
  Offset? _finalDropPosition;
  MultiDragGestureRecognizer? _recognizer;
  int? _recognizerPointer;

  EdgeDraggingAutoScroller? _autoScroller;

  late ScrollableState _scrollable;
  Axis get _scrollDirection => axisDirectionToAxis(_scrollable.axisDirection);
  bool get _reverse => _scrollable.axisDirection == AxisDirection.up || _scrollable.axisDirection == AxisDirection.left;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.of(context);
    if (_autoScroller?.scrollable != _scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = EdgeDraggingAutoScroller(
        _scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
        velocityScalar: widget.autoScrollerVelocityScalar,
      );
    }
  }

  @override
  void didUpdateWidget(covariant SliverMyReorderableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      cancelReorder();
    }

    if (widget.autoScrollerVelocityScalar != oldWidget.autoScrollerVelocityScalar) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = EdgeDraggingAutoScroller(
        _scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
        velocityScalar: widget.autoScrollerVelocityScalar,
      );
    }
  }

  @override
  void dispose() {
    _dragReset();
    _recognizer?.dispose();
    super.dispose();
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a canceled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [MyReorderableDragStartListener] or [MyReorderableDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    assert(0 <= index && index < widget.itemCount);
    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      } else if (_recognizer != null && _recognizerPointer != event.pointer) {
        _recognizer!.dispose();
        _recognizer = null;
        _recognizerPointer = null;
      }

      if (_items.containsKey(index)) {
        _dragIndex = index;
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
        _recognizerPointer = event.pointer;
      } else {
        // TODO(darrenaustin): Can we handle this better, maybe scroll to the item?
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the list to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    setState(() {
      _dragReset();
    });
  }

  void _registerItem(_MyReorderableItemState item) {
    if (_dragInfo != null && _items[item.index] != item) {
      item.updateForGap(_dragInfo!.index, _dragInfo!.index, _dragInfo!.itemExtent, false, _reverse);
    }
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(int index, _MyReorderableItemState item) {
    final _MyReorderableItemState? currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  Drag? _dragStart(Offset position) {
    assert(_dragInfo == null);
    final _MyReorderableItemState item = _items[_dragIndex!]!;
    item.dragging = true;
    widget.onReorderStart?.call(_dragIndex!);
    item.rebuild();

    _insertIndex = item.index;
    _dragInfo = _DragInfo(
      item: item,
      initialPosition: position,
      scrollDirection: _scrollDirection,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );
    _dragInfo!.startDrag();

    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);

    for (final _MyReorderableItemState childItem in _items.values) {
      if (childItem == item || !childItem.mounted) {
        continue;
      }
      childItem.updateForGap(_insertIndex!, _insertIndex!, _dragInfo!.itemExtent, false, _reverse);
    }
    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScroller?.startAutoScrollIfNecessary(_dragTargetRect);
    });
  }

  void _dragCancel(_DragInfo item) {
    setState(() {
      _dragReset();
    });
  }

  void _dragEnd(_DragInfo item) {
    setState(() {
      if (_insertIndex == item.index) {
        _finalDropPosition = _itemOffsetAt(_insertIndex!);
      } else if (_reverse) {
        if (_insertIndex! >= _items.length) {
          // Drop at the starting position of the last element and offset its own extent
          _finalDropPosition = _itemOffsetAt(_items.length - 1) - _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          // Drop at the end of the current element occupying the insert position
          _finalDropPosition = _itemOffsetAt(_insertIndex!) + _extentOffset(_itemExtentAt(_insertIndex!), _scrollDirection);
        }
      } else {
        if (_insertIndex! == 0) {
          // Drop at the starting position of the first element and offset its own extent
          _finalDropPosition = _itemOffsetAt(0) - _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          // Drop at the end of the previous element occupying the insert position
          final int atIndex = _insertIndex! - 1;
          _finalDropPosition = _itemOffsetAt(atIndex) + _extentOffset(_itemExtentAt(atIndex), _scrollDirection);
        }
      }
    });
    widget.onReorderEnd?.call(_insertIndex!);
  }

  void _dropCompleted() {
    final int fromIndex = _dragIndex!;
    final int toIndex = _insertIndex!;
    if (fromIndex != toIndex) {
      widget.onReorder.call(fromIndex, toIndex);
    }
    setState(() {
      _dragReset();
    });
  }

  void _dragReset() {
    if (_dragInfo != null) {
      if (_dragIndex != null && _items.containsKey(_dragIndex)) {
        final _MyReorderableItemState dragItem = _items[_dragIndex!]!;
        dragItem._dragging = false;
        dragItem.rebuild();
        _dragIndex = null;
      }
      _dragInfo?.dispose();
      _dragInfo = null;
      _autoScroller?.stopAutoScroll();
      _resetItemGap();
      _recognizer?.dispose();
      _recognizer = null;
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
      _finalDropPosition = null;
    }
  }

  void _resetItemGap() {
    for (final _MyReorderableItemState item in _items.values) {
      item.resetGap();
    }
  }

  void _handleScrollableAutoScrolled() {
    if (_dragInfo == null) {
      return;
    }
    _dragUpdateItems();
    // Continue scrolling if the drag is still in progress.
    _autoScroller?.startAutoScrollIfNecessary(_dragTargetRect);
  }

  void _dragUpdateItems() {
    assert(_dragInfo != null);
    final double gapExtent = _dragInfo!.itemExtent;
    final double proxyItemStart = _offsetExtent(_dragInfo!.dragPosition - _dragInfo!.dragOffset, _scrollDirection);
    final double proxyItemEnd = proxyItemStart + gapExtent;

    // Find the new index for inserting the item being dragged.
    int newIndex = _insertIndex!;
    for (final _MyReorderableItemState item in _items.values) {
      if (item.index == _dragIndex! || !item.mounted) {
        continue;
      }

      final Rect geometry = item.targetGeometry();
      final double itemStart = _scrollDirection == Axis.vertical ? geometry.top : geometry.left;
      final double itemExtent = _scrollDirection == Axis.vertical ? geometry.height : geometry.width;
      final double itemEnd = itemStart + itemExtent;
      final double itemMiddle = itemStart + itemExtent / 2;

      if (_reverse) {
        if (itemEnd >= proxyItemEnd && proxyItemEnd >= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle >= proxyItemStart && proxyItemStart >= itemStart) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemStart > proxyItemEnd && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemStart > itemEnd && newIndex > item.index) {
          newIndex = item.index;
        }
      } else {
        if (itemStart <= proxyItemStart && proxyItemStart <= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle <= proxyItemEnd && proxyItemEnd <= itemEnd) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemEnd < proxyItemStart && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemEnd < itemStart && newIndex > item.index) {
          newIndex = item.index;
        }
      }
    }

    if (newIndex != _insertIndex) {
      _insertIndex = newIndex;
      for (final _MyReorderableItemState item in _items.values) {
        if (item.index == _dragIndex! || !item.mounted) {
          continue;
        }
        item.updateForGap(_dragIndex!, newIndex, gapExtent, true, _reverse);
      }
    }
  }

  Rect get _dragTargetRect {
    final Offset origin = _dragInfo!.dragPosition - _dragInfo!.dragOffset;
    return Rect.fromLTWH(origin.dx, origin.dy, _dragInfo!.itemSize.width, _dragInfo!.itemSize.height);
  }

  Offset _itemOffsetAt(int index) {
    return _items[index]!.targetGeometry().topLeft;
  }

  double _itemExtentAt(int index) {
    return _sizeExtent(_items[index]!.targetGeometry().size, _scrollDirection);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_dragInfo != null && index >= widget.itemCount) {
      return switch (_scrollDirection) {
        Axis.horizontal => SizedBox(width: _dragInfo!.itemExtent),
        Axis.vertical => SizedBox(height: _dragInfo!.itemExtent),
      };
    }
    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All list items must have a key');
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    return _MyReorderableItem(
      key: _MyReorderableItemGlobalKey(child.key!, index, this),
      index: index,
      capturedThemes: InheritedTheme.capture(from: context, to: overlay.context),
      child: _wrapWithSemantics(child, index),
    );
  }

  Widget _wrapWithSemantics(Widget child, int index) {
    void reorder(int startIndex, int endIndex) {
      if (startIndex != endIndex) {
        widget.onReorder(startIndex, endIndex);
      }
    }

    // First, determine which semantics actions apply.
    final Map<CustomSemanticsAction, VoidCallback> semanticsActions = <CustomSemanticsAction, VoidCallback>{};

    // Create the appropriate semantics actions.
    void moveToStart() => reorder(index, 0);
    void moveToEnd() => reorder(index, widget.itemCount);
    void moveBefore() => reorder(index, index - 1);
    // To move after, go to index+2 because it is moved to the space
    // before index+2, which is after the space at index+1.
    void moveAfter() => reorder(index, index + 2);

    final WidgetsLocalizations localizations = WidgetsLocalizations.of(context);
    final bool isHorizontal = _scrollDirection == Axis.horizontal;
    // If the item can move to before its current position in the list.
    if (index > 0) {
      semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToStart)] = moveToStart;
      String reorderItemBefore = localizations.reorderItemUp;
      if (isHorizontal) {
        reorderItemBefore = Directionality.of(context) == TextDirection.ltr ? localizations.reorderItemLeft : localizations.reorderItemRight;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] = moveBefore;
    }

    // If the item can move to after its current position in the list.
    if (index < widget.itemCount - 1) {
      String reorderItemAfter = localizations.reorderItemDown;
      if (isHorizontal) {
        reorderItemAfter = Directionality.of(context) == TextDirection.ltr ? localizations.reorderItemRight : localizations.reorderItemLeft;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] = moveAfter;
      semanticsActions[CustomSemanticsAction(label: localizations.reorderItemToEnd)] = moveToEnd;
    }

    // Pass toWrap with a GlobalKey into the item so that when it
    // gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.
    //
    // Also apply the relevant custom accessibility actions for moving the item
    // up, down, to the start, and to the end of the list.
    return Semantics(
      container: true,
      customSemanticsActions: semanticsActions,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    final SliverChildBuilderDelegate childrenDelegate = SliverChildBuilderDelegate(
      _itemBuilder,
      childCount: widget.itemCount,
      findChildIndexCallback: widget.findChildIndexCallback,
    );
    if (widget.itemExtent != null) {
      return SliverFixedExtentList(
        delegate: childrenDelegate,
        itemExtent: widget.itemExtent!,
      );
    } else if (widget.itemExtentBuilder != null) {
      return SliverVariedExtentList(
        delegate: childrenDelegate,
        itemExtentBuilder: widget.itemExtentBuilder!,
      );
    } else if (widget.prototypeItem != null) {
      return SliverPrototypeExtentList(
        delegate: childrenDelegate,
        prototypeItem: widget.prototypeItem!,
      );
    }
    return SliverList(delegate: childrenDelegate);
  }
}

class _MyReorderableItem extends StatefulWidget {
  const _MyReorderableItem({
    required Key key,
    required this.index,
    required this.child,
    required this.capturedThemes,
  }) : super(key: key);

  final int index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _MyReorderableItemState createState() => _MyReorderableItemState();
}

class _MyReorderableItemState extends State<_MyReorderableItem> {
  late SliverMyReorderableListState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverMyReorderableList.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MyReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      final Size size = _extentSize(_listState._dragInfo!.itemExtent, _listState._scrollDirection);
      return SizedBox.fromSize(size: size);
    }
    _listState._registerItem(this);
    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(index, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue = Curves.easeInOut.transform(_offsetAnimation!.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue)!;
    }
    return _targetOffset;
  }

  void updateForGap(int dragIndex, int gapIndex, double gapExtent, bool animate, bool reverse) {
    // An offset needs to be added to create a gap when we are between the
    // moving element (dragIndex) and the current gap position (gapIndex).
    // For how to update the gap position, refer to [_dragUpdateItems].
    final Offset newTargetOffset;
    if (gapIndex < dragIndex && index < dragIndex && index >= gapIndex) {
      newTargetOffset = _extentOffset(reverse ? -gapExtent : gapExtent, _listState._scrollDirection);
    } else if (gapIndex > dragIndex && index > dragIndex && index < gapIndex) {
      newTargetOffset = _extentOffset(reverse ? gapExtent : -gapExtent, _listState._scrollDirection);
    } else {
      newTargetOffset = Offset.zero;
    }
    if (newTargetOffset != _targetOffset) {
      _targetOffset = newTargetOffset;
      if (animate) {
        if (_offsetAnimation == null) {
          _offsetAnimation = AnimationController(
            vsync: _listState,
            duration: const Duration(milliseconds: 250),
          )
            ..addListener(rebuild)
            ..addStatusListener((AnimationStatus status) {
              if (status == AnimationStatus.completed) {
                _startOffset = _targetOffset;
                _offsetAnimation!.dispose();
                _offsetAnimation = null;
              }
            })
            ..forward();
        } else {
          _startOffset = offset;
          _offsetAnimation!.forward(from: 0.0);
        }
      } else {
        if (_offsetAnimation != null) {
          _offsetAnimation!.dispose();
          _offsetAnimation = null;
        }
        _startOffset = _targetOffset;
      }
      rebuild();
    }
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a MyReorderable list.
///
/// See also:
///
///  * [MyReorderableDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [MyReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverMyReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [MyReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class MyReorderableDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a list item like a drag
  /// handle.
  const MyReorderableDragStartListener({
    super.key,
    required this.child,
    required this.index,
    this.enabled = true,
  });

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a MyReorderable list.
  final Widget child;

  /// The index of the associated item that will be dragged in the list.
  final int index;

  /// Whether the [child] item can be dragged and moved in the list.
  ///
  /// If true, the item can be moved to another location in the list when the
  /// user taps on the child. If false, tapping on the child will be ignored.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (PointerDownEvent event) => _startDragging(context, event) : null,
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final DeviceGestureSettings? gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final SliverMyReorderableListState? list = SliverMyReorderableList.maybeOf(context);
    list?.startItemDragReorder(
      index: index,
      event: event,
      recognizer: createRecognizer()..gestureSettings = gestureSettings,
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the MyReorderable list.
///
/// See also:
///
///  * [MyReorderableDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [MyReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverMyReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [MyReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class MyReorderableDelayedDragStartListener extends MyReorderableDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire list item in a MyReorderable
  /// list.
  const MyReorderableDelayedDragStartListener({
    super.key,
    required super.child,
    required super.index,
    super.enabled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}

typedef _DragItemUpdate = void Function(_DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    required _MyReorderableItemState item,
    Offset initialPosition = Offset.zero,
    this.scrollDirection = Axis.vertical,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
  }) {
    // TODO(polina-c): stop duplicating code across disposables
    // https://github.com/flutter/flutter/issues/137435
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:flutter/widgets.dart',
        className: '$_DragInfo',
        object: this,
      );
    }
    final RenderBox itemRenderBox = item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    index = item.index;
    child = item.widget.child;
    capturedThemes = item.widget.capturedThemes;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size!;
    _rawDragPosition = initialPosition;
    dragPosition = _adjustedDragOffset(initialPosition);
    itemExtent = _sizeExtent(itemSize, scrollDirection);
    scrollable = Scrollable.of(item.context);
  }

  final Axis scrollDirection;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onEnd;
  final _DragItemCallback? onCancel;
  final VoidCallback? onDropCompleted;
  final ReorderItemProxyDecorator? proxyDecorator;
  final TickerProvider tickerProvider;

  late SliverMyReorderableListState listState;
  late int index;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;
  late double itemExtent;
  late CapturedThemes capturedThemes;
  ScrollableState? scrollable;
  AnimationController? _proxyAnimation;
  late Offset _rawDragPosition;

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    final Offset delta = _restrictAxis(details.delta, scrollDirection);
    _rawDragPosition += delta;
    dragPosition = _adjustedDragOffset(_rawDragPosition);
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation!.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  Offset _adjustedDragOffset(Offset offset) {
    final Rect? boundingRects = MyReorderableDragBoundary._boundingRectsOf(listState)?.shift(dragOffset);
    if (boundingRects != null) {
      final double adjustedX = clampDouble(
        offset.dx,
        boundingRects.left,
        math.max(boundingRects.left, boundingRects.right - itemSize.width),
      );
      final double adjustedY = clampDouble(
        offset.dy,
        boundingRects.top,
        math.max(boundingRects.top, boundingRects.bottom - itemSize.height),
      );
      return Offset(adjustedX, adjustedY);
    }
    return offset;
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    return capturedThemes.wrap(
      _DragItemProxy(
        listState: listState,
        index: index,
        size: itemSize,
        animation: _proxyAnimation!,
        position: dragPosition - dragOffset - _overlayOrigin(context),
        proxyDecorator: proxyDecorator,
        child: child,
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay = Overlay.of(context, debugRequiredFor: context.widget);
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    required this.listState,
    required this.index,
    required this.child,
    required this.position,
    required this.size,
    required this.animation,
    required this.proxyDecorator,
  });

  final SliverMyReorderableListState listState;
  final int index;
  final Widget child;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild = proxyDecorator?.call(child, index, animation.view) ?? child;
    final Offset overlayOrigin = _overlayOrigin(context);

    return MediaQuery(
      // Remove the top padding so that any nested list views in the item
      // won't pick up the scaffold's padding in the overlay.
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          Offset effectivePosition = position;
          final Offset? dropPosition = listState._finalDropPosition;
          if (dropPosition != null) {
            effectivePosition = Offset.lerp(dropPosition - overlayOrigin, effectivePosition, Curves.easeOut.transform(animation.value))!;
          }
          return Positioned(
            left: effectivePosition.dx,
            top: effectivePosition.dy,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          );
        },
        child: proxyChild,
      ),
    );
  }
}

double _sizeExtent(Size size, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => size.width,
    Axis.vertical => size.height,
  };
}

Size _extentSize(double extent, Axis scrollDirection) {
  switch (scrollDirection) {
    case Axis.horizontal:
      return Size(extent, 0);
    case Axis.vertical:
      return Size(0, extent);
  }
}

double _offsetExtent(Offset offset, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => offset.dx,
    Axis.vertical => offset.dy,
  };
}

Offset _extentOffset(double extent, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => Offset(extent, 0.0),
    Axis.vertical => Offset(0.0, extent),
  };
}

Offset _restrictAxis(Offset offset, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => Offset(offset.dx, 0.0),
    Axis.vertical => Offset(0.0, offset.dy),
  };
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _MyReorderableItemGlobalKey extends GlobalObjectKey {
  const _MyReorderableItemGlobalKey(this.subKey, this.index, this.state) : super(subKey);

  final Key subKey;
  final int index;
  final SliverMyReorderableListState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _MyReorderableItemGlobalKey && other.subKey == subKey && other.index == index && other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, index, state);
}

/// [MyReorderableDragBoundary] is a widget that limits the drag boundary of a [MyReorderableList].
///
/// When this widget wraps a [MyReorderableList], the drag boundary of the [MyReorderableList] is confined within this widget.
/// If the [dragBoundingRect] property is provided, the drag boundary is limited to the rectangle returned by [dragBoundingRect].
/// The boundary is specified in global coordinates.
class MyReorderableDragBoundary extends InheritedWidget {
  /// Create a [MyReorderableDragBoundary] to set the drag boundary for the [MyReorderableList].
  ///
  /// The [dragBoundingRect] needs to return a rectangle in global coordinates.
  const MyReorderableDragBoundary({
    required super.child,
    this.dragBoundingRect,
    super.key,
  });

  /// Return the drag boundary of [MyReorderableList].
  final Rect Function(SliverMyReorderableListState MyReorderableListCurrentState)? dragBoundingRect;

  @override
  bool updateShouldNotify(covariant MyReorderableDragBoundary oldWidget) {
    return oldWidget.dragBoundingRect != dragBoundingRect;
  }

  static Rect? _boundingRectsOf(SliverMyReorderableListState listState) {
    final InheritedElement? element = listState.context.getElementForInheritedWidgetOfExactType<MyReorderableDragBoundary>();
    if (element == null) {
      return null;
    }
    final MyReorderableDragBoundary dragBoundary = element.widget as MyReorderableDragBoundary;
    final Rect boundingRect;
    if (dragBoundary.dragBoundingRect != null) {
      boundingRect = dragBoundary.dragBoundingRect!.call(listState);
    } else {
      final RenderBox renderBox = element.findRenderObject()! as RenderBox;
      boundingRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }
    return boundingRect;
  }
}
