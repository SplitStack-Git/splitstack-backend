import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'page4_model.dart';
export 'page4_model.dart';

class Page4Widget extends StatefulWidget {
  const Page4Widget({
    super.key,
    required this.doc,
  });

  final DocumentReference? doc;

  static String routeName = 'Page4';
  static String routePath = '/page4';

  @override
  State<Page4Widget> createState() => _Page4WidgetState();
}

class _Page4WidgetState extends State<Page4Widget> {
  late Page4Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Page4Model());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return StreamBuilder<StacksRecord>(
      stream: StacksRecord.getDocument(widget.doc!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).info,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final page4StacksRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).info,
            body: SafeArea(
              top: true,
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).info,
                ),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.safePop();
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF121212),
                                    size: 24.0,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      valueOrDefault<String>(
                                        page4StacksRecord.stackFor,
                                        'Dinner',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF121212),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Text(
                                      'by ${valueOrDefault<String>(
                                        page4StacksRecord.organiserName,
                                        'Luke',
                                      )}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF121212),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(width: 12.0)),
                            ),
                            Icon(
                              Icons.refresh,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                        StreamBuilder<List<ParticipantsRecord>>(
                          stream: queryParticipantsRecord(
                            queryBuilder: (participantsRecord) =>
                                participantsRecord.where(
                              'stack_id',
                              isEqualTo: page4StacksRecord.reference,
                            ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
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
                            List<ParticipantsRecord>
                                containerParticipantsRecordList =
                                snapshot.data!;

                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFFAFAFA),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 16.0, 16.0, 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Amount',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF121212),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${valueOrDefault<String>(
                                                        FFAppState()
                                                            .currencyList
                                                            .where((e) =>
                                                                e.code ==
                                                                page4StacksRecord
                                                                    .currency)
                                                            .toList()
                                                            .firstOrNull
                                                            ?.symbol,
                                                        '\$',
                                                      )}${valueOrDefault<String>(
                                                        formatNumber(
                                                          page4StacksRecord
                                                              .totalAmount,
                                                          formatType:
                                                              FormatType.custom,
                                                          format: '#,##0.00',
                                                          locale: '',
                                                        ),
                                                        '0.0',
                                                      )}',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .displaySmall
                                                          .override(
                                                            font: GoogleFonts
                                                                .interTight(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle: FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmall
                                                                  .fontStyle,
                                                            ),
                                                            color: Color(
                                                                0xFF121212),
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .displaySmall
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Remaining',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF121212),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 0.0),
                                                      child: Text(
                                                        '${valueOrDefault<String>(
                                                          FFAppState()
                                                              .currencyList
                                                              .where((e) =>
                                                                  e.code ==
                                                                  page4StacksRecord
                                                                      .currency)
                                                              .toList()
                                                              .firstOrNull
                                                              ?.symbol,
                                                          '\$',
                                                        )}${valueOrDefault<String>(
                                                          formatNumber(
                                                            functions.add(
                                                                containerParticipantsRecordList
                                                                    .where((e) =>
                                                                        e.paidStatus ==
                                                                        false)
                                                                    .toList()
                                                                    .map((e) =>
                                                                        valueOrDefault<
                                                                            double>(
                                                                          e.amount,
                                                                          0.0,
                                                                        ))
                                                                    .toList()),
                                                            formatType:
                                                                FormatType
                                                                    .custom,
                                                            format: '#,##0.00',
                                                            locale: '',
                                                          ),
                                                          '0.0',
                                                        )}',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .displaySmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .displaySmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0xFF16A149),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .displaySmall
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${valueOrDefault<String>(
                                            containerParticipantsRecordList
                                                .where(
                                                    (e) => e.paidStatus == true)
                                                .toList()
                                                .length
                                                .toString(),
                                            '0',
                                          )} out of ${valueOrDefault<String>(
                                            containerParticipantsRecordList
                                                .length
                                                .toString(),
                                            '0',
                                          )} collected',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF121212),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          '${valueOrDefault<String>(
                                            FFAppState()
                                                .currencyList
                                                .where((e) =>
                                                    e.code ==
                                                    page4StacksRecord.currency)
                                                .toList()
                                                .firstOrNull
                                                ?.symbol,
                                            '\$',
                                          )}${valueOrDefault<String>(
                                            formatNumber(
                                              functions.add(
                                                  containerParticipantsRecordList
                                                      .where((e) =>
                                                          e.paidStatus == true)
                                                      .toList()
                                                      .map((e) =>
                                                          valueOrDefault<
                                                              double>(
                                                            e.amount,
                                                            0.0,
                                                          ))
                                                      .toList()),
                                              formatType: FormatType.custom,
                                              currency: '\$',
                                              format: '#,##0.00',
                                              locale: '',
                                            ),
                                            '0.0',
                                          )} collected',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF121212),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: LinearPercentIndicator(
                                            percent: valueOrDefault<double>(
                                              functions.progressbar(
                                                  valueOrDefault<String>(
                                                    page4StacksRecord
                                                        .totalAmount
                                                        .toString(),
                                                    '0',
                                                  ),
                                                  valueOrDefault<String>(
                                                    functions
                                                        .add(containerParticipantsRecordList
                                                            .where((e) =>
                                                                e.paidStatus ==
                                                                true)
                                                            .toList()
                                                            .map(
                                                                (e) => e.amount)
                                                            .toList())
                                                        .toString(),
                                                    '0',
                                                  )),
                                              0.0,
                                            ),
                                            lineHeight: 25.0,
                                            animation: true,
                                            animateFromLastPercent: true,
                                            progressColor: Color(0xFF16A149),
                                            backgroundColor: Color(0xCCC8C5C5),
                                            center: Text(
                                              valueOrDefault<String>(
                                                functions.progressbarpercent(
                                                    valueOrDefault<String>(
                                                      page4StacksRecord
                                                          .totalAmount
                                                          .toString(),
                                                      '0',
                                                    ),
                                                    functions
                                                        .add(containerParticipantsRecordList
                                                            .where((e) =>
                                                                e.paidStatus ==
                                                                true)
                                                            .toList()
                                                            .map(
                                                                (e) => e.amount)
                                                            .toList())
                                                        .toString()),
                                                '0%',
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .headlineSmall
                                                  .override(
                                                    font:
                                                        GoogleFonts.interTight(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineSmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineSmall
                                                              .fontStyle,
                                                    ),
                                                    fontSize: 20.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .headlineSmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .headlineSmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                            barRadius: Radius.circular(30.0),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0.0,
                                  2.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 16.0, 16.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: Color(0xFF121212),
                                          size: 20.0,
                                        ),
                                        Text(
                                          'Who Owes What',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF121212),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    Container(
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 2.0, 8.0, 0.0),
                                        child: FutureBuilder<int>(
                                          future: queryParticipantsRecordCount(
                                            queryBuilder:
                                                (participantsRecord) =>
                                                    participantsRecord.where(
                                              'stack_id',
                                              isEqualTo:
                                                  page4StacksRecord.reference,
                                            ),
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            int textCount = snapshot.data!;

                                            return Text(
                                              '${valueOrDefault<String>(
                                                textCount.toString(),
                                                '0',
                                              )} people',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFF121212),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ),
                              StreamBuilder<List<ParticipantsRecord>>(
                                stream: queryParticipantsRecord(
                                  queryBuilder: (participantsRecord) =>
                                      participantsRecord
                                          .where(
                                            'stack_id',
                                            isEqualTo:
                                                page4StacksRecord.reference,
                                          )
                                          .orderBy('created_at',
                                              descending: true),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<ParticipantsRecord>
                                      columnParticipantsRecordList =
                                      snapshot.data!;

                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: List.generate(
                                        columnParticipantsRecordList.length,
                                        (columnIndex) {
                                      final columnParticipantsRecord =
                                          columnParticipantsRecordList[
                                              columnIndex];
                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ListView(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        if (columnParticipantsRecord
                                                                .paidStatus ==
                                                            true)
                                                          Container(
                                                            width: 48.0,
                                                            height: 48.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFF16A149),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Icon(
                                                              Icons.check,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 24.0,
                                                            ),
                                                          ),
                                                        if (columnParticipantsRecord
                                                                .paidStatus ==
                                                            false)
                                                          Container(
                                                            width: 48.0,
                                                            height: 48.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            2.0),
                                                                child: Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    functions.firstLetter(
                                                                        columnParticipantsRecord
                                                                            .displayName),
                                                                    'A',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Color(
                                                                            0xFF121212),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  valueOrDefault<
                                                                      String>(
                                                                    columnParticipantsRecord
                                                                        .displayName,
                                                                    'Luke',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Color(
                                                                            0xFF121212),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                if (columnParticipantsRecord
                                                                        .paidStatus ==
                                                                    true)
                                                                  Container(
                                                                    width: 60.0,
                                                                    height:
                                                                        20.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0xFFFAFAFA),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .alternate,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          4.0,
                                                                          1.0,
                                                                          4.0,
                                                                          0.0),
                                                                      child:
                                                                          Text(
                                                                        'Paid Bill',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
                                                                              font: GoogleFonts.inter(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                              ),
                                                                              color: Color(0xFF121212),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                            Text(
                                                              '${valueOrDefault<String>(
                                                                FFAppState()
                                                                    .currencyList
                                                                    .where((e) =>
                                                                        e.code ==
                                                                        page4StacksRecord
                                                                            .currency)
                                                                    .toList()
                                                                    .firstOrNull
                                                                    ?.symbol,
                                                                '\$',
                                                              )}${valueOrDefault<String>(
                                                                formatNumber(
                                                                  columnParticipantsRecord
                                                                      .amount,
                                                                  formatType:
                                                                      FormatType
                                                                          .custom,
                                                                  format:
                                                                      '#,##0.00',
                                                                  locale: '',
                                                                ),
                                                                '0.0',
                                                              )}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Color(
                                                                        0xFF121212),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              height: 2.0)),
                                                        ),
                                                      ].divide(SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                    if ((columnParticipantsRecord
                                                                .paidStatus ==
                                                            false) &&
                                                        (columnParticipantsRecord
                                                                .paymentPending ==
                                                            true) &&
                                                        (columnParticipantsRecord
                                                                .isOrganiser ==
                                                            false))
                                                      Container(
                                                        width: 95.0,
                                                        height: 40.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xFF121212),
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'Pending',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (columnParticipantsRecord
                                                            .isOrganiser ==
                                                        true)
                                                      Container(
                                                        width: 95.0,
                                                        height: 40.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFE8F1E9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xFF16A149),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      8.0,
                                                                      12.0,
                                                                      8.0,
                                                                      12.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'Organizer',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .fontStyle,
                                                                      ),
                                                                      color: Color(
                                                                          0xFF121212),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 4.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    if ((columnParticipantsRecord
                                                                .paymentLinksend ==
                                                            true) &&
                                                        (columnParticipantsRecord
                                                                .paymentPending ==
                                                            false) &&
                                                        (columnParticipantsRecord
                                                                .isOrganiser ==
                                                            false))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child: Builder(
                                                          builder: (context) =>
                                                              FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              _model.checkoutResponseCopyCopy =
                                                                  await CreateCheckoutSessionCall
                                                                      .call(
                                                                amountCents:
                                                                    FFAppState()
                                                                        .paymentAmountCents,
                                                                currency:
                                                                    FFAppState()
                                                                        .paymentCurrency,
                                                                stackId:
                                                                    FFAppState()
                                                                        .stackid,
                                                                participantId:
                                                                    columnParticipantsRecord
                                                                        .reference
                                                                        .id,
                                                                successUrl:
                                                                    'splitstack://splitstack.com/paymentSuccess',
                                                                cancelUrl:
                                                                    'splitstack://splitstack.com/page1',
                                                              );

                                                              await Share.share(
                                                                'Hey ${columnParticipantsRecord.displayName}, you owe ${formatNumber(
                                                                  columnParticipantsRecord
                                                                      .amount,
                                                                  formatType:
                                                                      FormatType
                                                                          .custom,
                                                                  currency:
                                                                      '\$',
                                                                  format:
                                                                      '#,##0.00',
                                                                  locale: '',
                                                                )} for ${page4StacksRecord.stackFor}. Pay Here: ${getJsonField(
                                                                  (_model.checkoutResponseCopyCopy
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                  r'''$.checkout_url''',
                                                                ).toString()}',
                                                                sharePositionOrigin:
                                                                    getWidgetBoundingBox(
                                                                        context),
                                                              );

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: 'Resend',
                                                            options:
                                                                FFButtonOptions(
                                                              width: 95.0,
                                                              height: 40.0,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color:
                                                                  Colors.white,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Color(
                                                                            0xFF16A149),
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0xFF16A149),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if ((columnParticipantsRecord
                                                                .paymentLinksend ==
                                                            false) &&
                                                        (columnParticipantsRecord
                                                                .isOrganiser ==
                                                            false))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child: Builder(
                                                          builder: (context) =>
                                                              FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              _model.checkoutResponse =
                                                                  await CreateCheckoutSessionCall
                                                                      .call(
                                                                amountCents:
                                                                    (columnParticipantsRecord.amount *
                                                                            100)
                                                                        .round(),
                                                                currency:
                                                                    page4StacksRecord
                                                                        .currency,
                                                                stackId:
                                                                    page4StacksRecord
                                                                        .reference
                                                                        .id,
                                                                participantId:
                                                                    columnParticipantsRecord
                                                                        .reference
                                                                        .id,
                                                                successUrl:
                                                                    'splitstack://splitstack.com/paymentSuccess',
                                                                cancelUrl:
                                                                    'splitstack://splitstack.com/page1',
                                                              );

                                                              await Share.share(
                                                                'Hey ${columnParticipantsRecord.displayName}, you owe ${valueOrDefault<String>(
                                                                  FFAppState()
                                                                      .currencyList
                                                                      .where((e) =>
                                                                          e.code ==
                                                                          page4StacksRecord
                                                                              .currency)
                                                                      .toList()
                                                                      .firstOrNull
                                                                      ?.symbol,
                                                                  '\$',
                                                                )}${formatNumber(
                                                                  columnParticipantsRecord
                                                                      .amount,
                                                                  formatType:
                                                                      FormatType
                                                                          .custom,
                                                                  format:
                                                                      '#,##0.00',
                                                                  locale: '',
                                                                )} for ${page4StacksRecord.stackFor}. Pay Here: ${getJsonField(
                                                                  (_model.checkoutResponse
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                  r'''$.checkout_url''',
                                                                ).toString()}',
                                                                sharePositionOrigin:
                                                                    getWidgetBoundingBox(
                                                                        context),
                                                              );

                                                              await columnParticipantsRecord
                                                                  .reference
                                                                  .update(
                                                                      createParticipantsRecordData(
                                                                paymentLinksend:
                                                                    true,
                                                              ));

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text: 'Send',
                                                            options:
                                                                FFButtonOptions(
                                                              width: 95.0,
                                                              height: 40.0,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: Color(
                                                                  0xFF16A149),
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            thickness: 1.0,
                                            indent: 16.0,
                                            endIndent: 16.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      );
                                    }).divide(SizedBox(height: 20.0)),
                                  );
                                },
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                        FutureBuilder<List<ParticipantsRecord>>(
                          future: queryParticipantsRecordOnce(
                            queryBuilder: (participantsRecord) =>
                                participantsRecord.where(
                              'stack_id',
                              isEqualTo: page4StacksRecord.reference,
                            ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
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
                            List<ParticipantsRecord>
                                buttonParticipantsRecordList = snapshot.data!;

                            return FFButtonWidget(
                              onPressed: () async {
                                for (int loop1Index = 0;
                                    loop1Index <
                                        buttonParticipantsRecordList.length;
                                    loop1Index++) {
                                  final currentLoop1Item =
                                      buttonParticipantsRecordList[loop1Index];
                                  if (!currentLoop1Item.isOrganiser) {
                                    _model.multiCheckoutSessionRes =
                                        await CreateCheckoutSessionCall.call(
                                      amountCents:
                                          (currentLoop1Item.amount * 100)
                                              .round(),
                                      currency: page4StacksRecord.currency,
                                      stackId: page4StacksRecord.reference.id,
                                      participantId:
                                          currentLoop1Item.reference.id,
                                      successUrl:
                                          'https://splitstack.com/success',
                                      cancelUrl:
                                          'https://splitstack.com/cancel',
                                    );

                                    _model.addToSendToAllLinks(
                                        'Hey ${currentLoop1Item.displayName}, you owe ${valueOrDefault<String>(
                                      FFAppState()
                                          .currencyList
                                          .where((e) =>
                                              e.code ==
                                              page4StacksRecord.currency)
                                          .toList()
                                          .firstOrNull
                                          ?.symbol,
                                      '\$',
                                    )}${formatNumber(
                                      currentLoop1Item.amount,
                                      formatType: FormatType.decimal,
                                    )} for ${page4StacksRecord.stackFor}. Pay Here: ${getJsonField(
                                      (_model.multiCheckoutSessionRes
                                              ?.jsonBody ??
                                          ''),
                                      r'''$.checkout_url''',
                                    ).toString()}');
                                  }
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _model.sendToAllLinks.length.toString(),
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );

                                safeSetState(() {});
                              },
                              text: 'Send To All',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: EdgeInsets.all(8.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: Color(0xFF16A149),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).info,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            );
                          },
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
