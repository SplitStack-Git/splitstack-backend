// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/stack_delete_widget.dart';
import '/auth/firebase_auth/auth_util.dart';

const double kRecentStacksSwipeDeleteGap = 10.0;
const double kRecentStacksSwipeDeleteCircle = 50.0;

Widget buildRecentStacksSwipeDeleteIcon() {
  return Container(
    width: kRecentStacksSwipeDeleteCircle,
    height: kRecentStacksSwipeDeleteCircle,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(kRecentStacksSwipeDeleteCircle / 2),
      color: const Color(0xFFFF0002),
    ),
    child: const Icon(
      Icons.delete_outline,
      color: Colors.white,
      size: 24.0,
    ),
  );
}

/// Single recent-stack row (data comes from [stack] — not hardcoded).
class RecentStackRowSwipe extends StatefulWidget {
  const RecentStackRowSwipe({
    super.key,
    this.width,
    this.height,
    required this.stack,
  });

  final double? width;
  final double? height;
  final StacksRecord stack;

  @override
  State<RecentStackRowSwipe> createState() => _RecentStackRowSwipeState();
}

class _RecentStackRowSwipeState extends State<RecentStackRowSwipe> {
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<int>(
      key: ValueKey('stack_row_${widget.stack.reference.id}'),
      future: queryParticipantsRecordCount(
        queryBuilder: (participantsRecord) => participantsRecord
            .where('stack_id', isEqualTo: widget.stack.reference)
            .where('paid_status', isEqualTo: false),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final containerCount = snapshot.data!;

        final stackListTile = InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pushNamed(
              'Page4',
              queryParameters: {
                'doc': serializeParam(
                  widget.stack.reference,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.stack.stackFor,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                        ),
                      ),
                      if (containerCount == 0)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1E9),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: const Color(0xFF16A149),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 4.0, 8.0, 4.0),
                            child: Text(
                              'Paid',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    dateTimeFormat("yMMMd", widget.stack.createdAt!),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                  ),
                  StreamBuilder<List<ParticipantsRecord>>(
                    stream: queryParticipantsRecord(
                      queryBuilder: (participantsRecord) => participantsRecord
                          .where('stack_id', isEqualTo: widget.stack.reference)
                          .where('isOrganiser', isEqualTo: true),
                      singleRecord: true,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.data!.isEmpty) {
                        return Container();
                      }
                      final rowParticipantsRecordList = snapshot.data!;
                      final rowParticipantsRecord =
                          rowParticipantsRecordList.isNotEmpty
                              ? rowParticipantsRecordList.first
                              : null;

                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${valueOrDefault<String>(
                              FFAppState()
                                  .currencyList
                                  .where((e) => e.code == widget.stack.currency)
                                  .toList()
                                  .firstOrNull
                                  ?.symbol,
                              r'$',
                            )}${formatNumber(
                              widget.stack.totalAmount,
                              formatType: FormatType.custom,
                              format: '#,##0.00',
                              locale: '',
                            )}',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          if (rowParticipantsRecord?.amount != null)
                            Text(
                              valueOrDefault<String>(
                                'Your share: ${valueOrDefault<String>(
                                  FFAppState()
                                      .currencyList
                                      .where((e) =>
                                          e.code == widget.stack.currency)
                                      .toList()
                                      .firstOrNull
                                      ?.symbol,
                                  r'$',
                                )}${formatNumber(
                                  rowParticipantsRecord?.amount,
                                  formatType: FormatType.custom,
                                  format: '#,##0.00',
                                  locale: '',
                                )}',
                                '0.0',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF14181B),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (containerCount == 0)
                    Text(
                      'Settled',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                            color: const Color(0xFF16A149),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                          ),
                    ),
                ].divide(const SizedBox(height: 2.0)),
              ),
            ),
          ),
        );

        // ── UNPAID (containerCount > 0) ──────────────────────────────────────
        // Swipe → delete icon → tap → nested "Confirm delete" button → dialog
        if (containerCount > 0) {
          return SwipeActionCell(
            key: ValueKey(widget.stack.reference.id),
            backgroundColor: FlutterFlowTheme.of(context).info,
            trailingActions: <SwipeAction>[
              SwipeAction(
                color: Colors.transparent,
                widthSpace: kRecentStacksSwipeDeleteGap +
                    kRecentStacksSwipeDeleteCircle,
                backgroundRadius: 25.0,
                content: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: kRecentStacksSwipeDeleteGap,
                  ),
                  child: buildRecentStacksSwipeDeleteIcon(),
                ),
                nestedAction: SwipeNestedAction(
                  nestedWidth: 180.0,
                  impactWhenShowing: true,
                  content: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: kRecentStacksSwipeDeleteGap,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: const Color(0xFFFF0002),
                      ),
                      width: 170.0,
                      height: 50.0,
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Confirm delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: (handler) async {
                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(dialogContext).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: StackDeleteWidget(
                            stackRefrence: widget.stack.reference,
                          ),
                        ),
                      );
                    },
                  );
                  await handler(false);
                },
              ),
            ],
            child: stackListTile,
          );
        }
        // ── PAID (containerCount == 0) ───────────────────────────────────────
        // Swipe → delete icon → tap → DIRECT delete (no confirm dialog)
        return SwipeActionCell(
          key: ValueKey('paid_${widget.stack.reference.id}'),
          backgroundColor: FlutterFlowTheme.of(context).info,
          trailingActions: <SwipeAction>[
            SwipeAction(
              color: Colors.transparent,
              widthSpace:
                  kRecentStacksSwipeDeleteGap + kRecentStacksSwipeDeleteCircle,
              backgroundRadius: 25.0,
              content: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: kRecentStacksSwipeDeleteGap,
                ),
                child: buildRecentStacksSwipeDeleteIcon(),
              ),
              onTap: (handler) async {
                // Dismiss the swipe cell first, then delete the document
                await handler(true);
                await widget.stack.reference.delete();
              },
            ),
          ],
          child: stackListTile,
        );
      },
    );
  }
}

// // Automatic FlutterFlow imports
// import '/backend/backend.dart';
// import '/backend/schema/structs/index.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/widgets/index.dart'; // Imports other custom widgets
// import '/custom_code/actions/index.dart'; // Imports custom actions
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// import 'package:flutter/material.dart';
// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// // Custom widget: place as the *child* of your Column / Container (below "Recent Stacks"
// // header), or inside a scroll view. ListView is shrink-wrapped. Requires
// // `flutter_swipe_action_cell` in project dependencies.
// //
// // FlutterFlow: Custom Code → Custom Widget → paste this file (adjust imports
// // if your app uses different paths). Add dependency: flutter_swipe_action_cell: ^3.1.6

// import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '/components/stack_delete_widget.dart';
// import '/auth/firebase_auth/auth_util.dart';

// const double kRecentStacksSwipeDeleteGap = 10.0;
// const double kRecentStacksSwipeDeleteCircle = 50.0;

// Widget buildRecentStacksSwipeDeleteIcon() {
//   return Container(
//     width: kRecentStacksSwipeDeleteCircle,
//     height: kRecentStacksSwipeDeleteCircle,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(kRecentStacksSwipeDeleteCircle / 2),
//       color: const Color(0xFFFF0002),
//     ),
//     child: const Icon(
//       Icons.delete_outline,
//       color: Colors.white,
//       size: 24.0,
//     ),
//   );
// }

// /// Single recent-stack row (data comes from [stack] — not hardcoded).
// class RecentStackRowSwipe extends StatefulWidget {
//   const RecentStackRowSwipe({
//     super.key,
//     this.width,
//     this.height,
//     required this.stack,
//   });

//   final double? width;
//   final double? height;
//   final StacksRecord stack;

//   @override
//   State<RecentStackRowSwipe> createState() => _RecentStackRowSwipeState();
// }

// class _RecentStackRowSwipeState extends State<RecentStackRowSwipe> {
//   @override
//   Widget build(BuildContext context) {
//     context.watch<FFAppState>();

//     return FutureBuilder<int>(
//       key: ValueKey('stack_row_${widget.stack.reference.id}'),
//       future: queryParticipantsRecordCount(
//         queryBuilder: (participantsRecord) => participantsRecord
//             .where('stack_id', isEqualTo: widget.stack.reference)
//             .where('paid_status', isEqualTo: false),
//       ),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(
//             child: SizedBox(
//               width: 50.0,
//               height: 50.0,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   FlutterFlowTheme.of(context).primary,
//                 ),
//               ),
//             ),
//           );
//         }
//         final containerCount = snapshot.data!;

//         final stackListTile = InkWell(
//           splashColor: Colors.transparent,
//           focusColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           onTap: () async {
//             context.pushNamed(
//               'Page4',
//               queryParameters: {
//                 'doc': serializeParam(
//                   widget.stack.reference,
//                   ParamType.DocumentReference,
//                 ),
//               }.withoutNulls,
//             );
//           },
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: FlutterFlowTheme.of(context).secondaryBackground,
//               borderRadius: BorderRadius.circular(8.0),
//               border: Border.all(
//                 color: FlutterFlowTheme.of(context).alternate,
//                 width: 1.0,
//               ),
//             ),
//             child: Padding(
//               padding:
//                   const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           widget.stack.stackFor,
//                           style: FlutterFlowTheme.of(context)
//                               .titleMedium
//                               .override(
//                                 font: GoogleFonts.interTight(
//                                   fontWeight: FlutterFlowTheme.of(context)
//                                       .titleMedium
//                                       .fontWeight,
//                                   fontStyle: FlutterFlowTheme.of(context)
//                                       .titleMedium
//                                       .fontStyle,
//                                 ),
//                                 color: FlutterFlowTheme.of(context).primaryText,
//                                 letterSpacing: 0.0,
//                                 fontWeight: FlutterFlowTheme.of(context)
//                                     .titleMedium
//                                     .fontWeight,
//                                 fontStyle: FlutterFlowTheme.of(context)
//                                     .titleMedium
//                                     .fontStyle,
//                               ),
//                         ),
//                       ),
//                       // Original row had a trash icon here when unsettled; swipe
//                       // replaces that. When settled, keep the same "Paid" badge.
//                       if (containerCount == 0)
//                         Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE8F1E9),
//                             borderRadius: BorderRadius.circular(4.0),
//                             border: Border.all(
//                               color: const Color(0xFF16A149),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsetsDirectional.fromSTEB(
//                                 8.0, 4.0, 8.0, 4.0),
//                             child: Text(
//                               'Paid',
//                               style: FlutterFlowTheme.of(context)
//                                   .labelSmall
//                                   .override(
//                                     font: GoogleFonts.inter(
//                                       fontWeight: FlutterFlowTheme.of(context)
//                                           .labelSmall
//                                           .fontWeight,
//                                       fontStyle: FlutterFlowTheme.of(context)
//                                           .labelSmall
//                                           .fontStyle,
//                                     ),
//                                     color: FlutterFlowTheme.of(context)
//                                         .secondaryText,
//                                     letterSpacing: 0.0,
//                                     fontWeight: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .fontWeight,
//                                     fontStyle: FlutterFlowTheme.of(context)
//                                         .labelSmall
//                                         .fontStyle,
//                                   ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   Text(
//                     dateTimeFormat("yMMMd", widget.stack.createdAt!),
//                     style: FlutterFlowTheme.of(context).bodySmall.override(
//                           font: GoogleFonts.inter(
//                             fontWeight: FlutterFlowTheme.of(context)
//                                 .bodySmall
//                                 .fontWeight,
//                             fontStyle: FlutterFlowTheme.of(context)
//                                 .bodySmall
//                                 .fontStyle,
//                           ),
//                           color: FlutterFlowTheme.of(context).secondaryText,
//                           letterSpacing: 0.0,
//                           fontWeight:
//                               FlutterFlowTheme.of(context).bodySmall.fontWeight,
//                           fontStyle:
//                               FlutterFlowTheme.of(context).bodySmall.fontStyle,
//                         ),
//                   ),
//                   StreamBuilder<List<ParticipantsRecord>>(
//                     stream: queryParticipantsRecord(
//                       queryBuilder: (participantsRecord) => participantsRecord
//                           .where('stack_id', isEqualTo: widget.stack.reference)
//                           .where('isOrganiser', isEqualTo: true),
//                       singleRecord: true,
//                     ),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return Center(
//                           child: SizedBox(
//                             width: 50.0,
//                             height: 50.0,
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 FlutterFlowTheme.of(context).primary,
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       if (snapshot.data!.isEmpty) {
//                         return Container();
//                       }
//                       final rowParticipantsRecordList = snapshot.data!;
//                       final rowParticipantsRecord =
//                           rowParticipantsRecordList.isNotEmpty
//                               ? rowParticipantsRecordList.first
//                               : null;

//                       return Row(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Total: ${valueOrDefault<String>(
//                               FFAppState()
//                                   .currencyList
//                                   .where((e) => e.code == widget.stack.currency)
//                                   .toList()
//                                   .firstOrNull
//                                   ?.symbol,
//                               r'$',
//                             )}${formatNumber(
//                               widget.stack.totalAmount,
//                               formatType: FormatType.custom,
//                               format: '#,##0.00',
//                               locale: '',
//                             )}',
//                             style: FlutterFlowTheme.of(context)
//                                 .bodyMedium
//                                 .override(
//                                   font: GoogleFonts.inter(
//                                     fontWeight: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .fontWeight,
//                                     fontStyle: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .fontStyle,
//                                   ),
//                                   color:
//                                       FlutterFlowTheme.of(context).primaryText,
//                                   letterSpacing: 0.0,
//                                   fontWeight: FlutterFlowTheme.of(context)
//                                       .bodyMedium
//                                       .fontWeight,
//                                   fontStyle: FlutterFlowTheme.of(context)
//                                       .bodyMedium
//                                       .fontStyle,
//                                 ),
//                           ),
//                           if (rowParticipantsRecord?.amount != null)
//                             Text(
//                               valueOrDefault<String>(
//                                 'Your share: ${valueOrDefault<String>(
//                                   FFAppState()
//                                       .currencyList
//                                       .where((e) =>
//                                           e.code == widget.stack.currency)
//                                       .toList()
//                                       .firstOrNull
//                                       ?.symbol,
//                                   r'$',
//                                 )}${formatNumber(
//                                   rowParticipantsRecord?.amount,
//                                   formatType: FormatType.custom,
//                                   format: '#,##0.00',
//                                   locale: '',
//                                 )}',
//                                 '0.0',
//                               ),
//                               style: FlutterFlowTheme.of(context)
//                                   .bodyMedium
//                                   .override(
//                                     font: GoogleFonts.inter(
//                                       fontWeight: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .fontWeight,
//                                       fontStyle: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .fontStyle,
//                                     ),
//                                     color: const Color(0xFF14181B),
//                                     letterSpacing: 0.0,
//                                     fontWeight: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .fontWeight,
//                                     fontStyle: FlutterFlowTheme.of(context)
//                                         .bodyMedium
//                                         .fontStyle,
//                                   ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                   if (containerCount == 0)
//                     Text(
//                       'Settled',
//                       style: FlutterFlowTheme.of(context).labelSmall.override(
//                             font: GoogleFonts.inter(
//                               fontWeight: FlutterFlowTheme.of(context)
//                                   .labelSmall
//                                   .fontWeight,
//                               fontStyle: FlutterFlowTheme.of(context)
//                                   .labelSmall
//                                   .fontStyle,
//                             ),
//                             color: const Color(0xFF16A149),
//                             letterSpacing: 0.0,
//                             fontWeight: FlutterFlowTheme.of(context)
//                                 .labelSmall
//                                 .fontWeight,
//                             fontStyle: FlutterFlowTheme.of(context)
//                                 .labelSmall
//                                 .fontStyle,
//                           ),
//                     ),
//                 ].divide(const SizedBox(height: 2.0)),
//               ),
//             ),
//           ),
//         );

//         if (containerCount > 0) {
//           return SwipeActionCell(
//             key: ValueKey(widget.stack.reference.id),
//             backgroundColor: FlutterFlowTheme.of(context).info,
//             trailingActions: <SwipeAction>[
//               SwipeAction(
//                 color: Colors.transparent,
//                 widthSpace: kRecentStacksSwipeDeleteGap +
//                     kRecentStacksSwipeDeleteCircle,
//                 backgroundRadius: 25.0,
//                 content: Padding(
//                   padding: const EdgeInsetsDirectional.only(
//                     start: kRecentStacksSwipeDeleteGap,
//                   ),
//                   child: buildRecentStacksSwipeDeleteIcon(),
//                 ),
//                 nestedAction: SwipeNestedAction(
//                   nestedWidth: 180.0,
//                   impactWhenShowing: true,
//                   content: Padding(
//                     padding: const EdgeInsetsDirectional.only(
//                       start: kRecentStacksSwipeDeleteGap,
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30.0),
//                         color: const Color(0xFFFF0002),
//                       ),
//                       width: 170.0,
//                       height: 50.0,
//                       child: OverflowBox(
//                         maxWidth: double.infinity,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.delete,
//                               color: Colors.white,
//                             ),
//                             const SizedBox(width: 8.0),
//                             Text(
//                               'Confirm delete',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 onTap: (handler) async {
//                   await showDialog<void>(
//                     context: context,
//                     builder: (dialogContext) {
//                       return Dialog(
//                         elevation: 0,
//                         insetPadding: EdgeInsets.zero,
//                         backgroundColor: Colors.transparent,
//                         alignment: const AlignmentDirectional(0.0, 0.0)
//                             .resolve(Directionality.of(context)),
//                         child: GestureDetector(
//                           onTap: () {
//                             FocusScope.of(dialogContext).unfocus();
//                             FocusManager.instance.primaryFocus?.unfocus();
//                           },
//                           child: StackDeleteWidget(
//                             stackRefrence: widget.stack.reference,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                   await handler(false);
//                 },
//               ),
//             ],
//             child: stackListTile,
//           );
//         }
//         return stackListTile;
//       },
//     );
//   }
// }
// // Set your widget name, define your parameter, and then add the
// // boilerplate code using the green button on the right!
