--------------------------------------------------------
--  DDL for Package Body ARP_XLA_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_XLA_EVENTS" AS
/* $Header: ARXLAEVB.pls 120.56.12010000.16 2010/06/11 13:52:38 spdixit ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

/*-----------------------------------------------------------------------+
 | Globle Variable Declarations and initializations                      |
 +-----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------+
 | Built Event structure                                                 |
 +-----------------------------------------------------------------------*/
TYPE bld_ev_type IS RECORD (
     bld_dml_flag        DBMS_SQL.VARCHAR2_TABLE,--insert,update,delete
     bld_temp_event_id   DBMS_SQL.VARCHAR2_TABLE
);

TYPE line_tbl_type IS TABLE OF ra_customer_trx_lines.customer_trx_line_id%TYPE
       INDEX BY BINARY_INTEGER;

/*-----------------------------------------------------------------------+
 | Default bulk fetch size, and starting index                           |
 +-----------------------------------------------------------------------*/
  MAX_ARRAY_SIZE          BINARY_INTEGER := 1000 ;
  STARTING_INDEX          CONSTANT BINARY_INTEGER := 1;

line_tbl            line_tbl_type;
g_prev_trx_id       NUMBER := -9999;
g_rule_prev_trx_id  NUMBER := -9999;
g_first_crh_status  VARCHAR2(30) := 'X';
g_xla_user          VARCHAR2(30);
PG_DEBUG            VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
g_call_number       NUMBER := 1;
/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/
   PROCEDURE define_arrays( p_select_c   IN INTEGER,
                            p_xla_ev_rec IN xla_events_type,
                            p_ev_rec     IN ev_rec_type,
                            p_call_point IN NUMBER);

   PROCEDURE get_column_values(p_select_c   IN  INTEGER,
                               p_xla_ev_rec IN xla_events_type,
                               p_call_point IN NUMBER,
                               p_ev_rec     OUT NOCOPY ev_rec_type);

   PROCEDURE Build_Stmt(p_xla_ev_rec IN xla_events_type,
                        p_call_point IN NUMBER,
                        p_stmt OUT NOCOPY VARCHAR2               );

   PROCEDURE Create_All_Events(p_xla_ev_rec IN xla_events_type);

   PROCEDURE dump_ev_rec(p_ev_rec IN OUT NOCOPY ev_rec_type,
                         p_i IN BINARY_INTEGER);

   PROCEDURE dump_bld_rec(p_bld_rec IN OUT NOCOPY bld_ev_type,
                          p_i IN BINARY_INTEGER,
                          p_tag IN VARCHAR2);

   PROCEDURE dump_event_info
         (p_ev_info_tab IN OUT NOCOPY xla_events_pub_pkg.t_array_entity_event_info_s,
          p_i           IN BINARY_INTEGER        ,
          p_tag         IN VARCHAR2              );

   PROCEDURE Upd_Dist(p_xla_ev_rec IN xla_events_type);

   PROCEDURE un_denormalize_posting_entity
   ( p_xla_doc          IN VARCHAR2,
     p_event_id         IN NUMBER   );

   PROCEDURE dump_event_source_info
   (x_ev_source_info IN OUT NOCOPY xla_events_pub_pkg.t_event_Source_info);

  FUNCTION entity_code( p_doc_table     IN VARCHAR2)
  RETURN VARCHAR2;

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/
   FUNCTION  Get_Select_Cursor(p_xla_ev_rec IN xla_events_type,
                               p_call_point IN NUMBER)
      RETURN INTEGER;

   FUNCTION  Change_Matrix(
                  trx_status        IN VARCHAR2                   ,
                  dist_gl_date      IN DATE                       ,
                  ev_match_gl_date  IN DATE                       ,
                  ev_match_status   IN xla_events.event_status_code%TYPE,
                  posttogl          IN VARCHAR2) RETURN VARCHAR2;

 FUNCTION is_one_acct_asg_on_ctlgd
  (p_invoice_id     IN NUMBER,
   p_posting_entity IN VARCHAR2 DEFAULT 'CTLGD',
   p_mode           IN VARCHAR2 DEFAULT 'O') RETURN VARCHAR2;


PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
IF PG_DEBUG = 'Y' THEN
    arp_standard.debug(message);
END IF;
END log;



FUNCTION xla_user RETURN VARCHAR2
IS
  l_status       VARCHAR2(30);
  l_industry     VARCHAR2(30);
  l_schema       VARCHAR2(30);
  l_res          BOOLEAN;
BEGIN
  IF g_xla_user IS NULL THEN
    IF  fnd_installation.get_app_info(
                   application_short_name=>'XLA'
                 , status        => l_status
                 , industry      => l_industry
                 , oracle_schema => l_schema)
    THEN
        g_xla_user := l_schema;
    ELSE
        g_xla_user := 'XLA';
    END IF;
  END IF;
  RETURN g_xla_user;
END;

PROCEDURE  get_existing_event
  (p_event_id          IN NUMBER,
   x_event_id          OUT NOCOPY NUMBER,
   x_event_date        OUT NOCOPY DATE,
   x_event_status_code OUT NOCOPY VARCHAR2,
   x_event_type_code   OUT NOCOPY VARCHAR2)
  IS
    l_c           INTEGER;
    l_exec        INTEGER;
    l_fetch_row   INTEGER;
    l_stmt        VARCHAR2(2000);
    l_xla_user    VARCHAR2(30);
BEGIN
log('get_existing_event +');
    l_xla_user := xla_user;
log('  l_xla_user :'||l_xla_user);
    l_stmt :=
'SELECT ae.event_id,
        ae.event_date,
        ae.event_status_code,
        ae.event_type_code
  FROM '||xla_user||'.xla_events ae
 WHERE ae.event_id = :dist_event_id
 AND ae.application_id = 222';

log('  l_stmt :'||l_stmt);

    l_c  := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_c, l_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.BIND_VARIABLE(l_c,':dist_event_id',p_event_id);
    DBMS_SQL.DEFINE_COLUMN(l_c,1,x_event_id);
    DBMS_SQL.DEFINE_COLUMN(l_c,2,x_event_date);
    DBMS_SQL.DEFINE_COLUMN(l_c,3,x_event_status_code,30);
    DBMS_SQL.DEFINE_COLUMN(l_c,4,x_event_type_code,30);
    l_exec := DBMS_SQL.EXECUTE(l_c);
    l_fetch_row := DBMS_SQL.FETCH_ROWS(l_c);
    DBMS_SQL.COLUMN_VALUE(l_c, 1, x_event_id);
    DBMS_SQL.COLUMN_VALUE(l_c, 2, x_event_date);
    DBMS_SQL.COLUMN_VALUE(l_c, 3, x_event_status_code);
    DBMS_SQL.COLUMN_VALUE(l_c, 4, x_event_type_code);
    DBMS_SQL.CLOSE_CURSOR(l_c);


log('x_event_id:'||x_event_id);
log('x_event_date:'||x_event_date);
log(' x_event_status_code:'|| x_event_status_code);
log(' x_event_type_code:'|| x_event_type_code);

log('get_existing_event -');

END;

PROCEDURE  get_best_existing_event
(p_trx_id          IN NUMBER,
 p_gl_date         IN DATE,
 p_override_event  IN VARCHAR2,
 x_match_event_id  OUT NOCOPY NUMBER,
 x_match_gl_date   OUT NOCOPY DATE,
 x_match_status    OUT NOCOPY VARCHAR2,
 x_match_type      OUT NOCOPY VARCHAR2)
IS
 l_c           INTEGER;
 l_exec        INTEGER;
 l_fetch_row   INTEGER;
 l_stmt        VARCHAR2(2000);
 l_xla_user    VARCHAR2(30);
BEGIN
log('get_best_existing_event +');
    l_xla_user := xla_user;
    l_stmt :=
' select ae.event_id         ,
         ae.event_date       ,
         ae.event_status_code,
         ae.event_type_code
  from xla_events     ae,
       xla_transaction_entities_upg xt
 where xt.source_id_int_1 = :trx_id
 and xt.entity_id = ae.entity_id
 and nvl(ae.event_date,
     to_date(''01-01-1900'',''DD-MM-YYYY'')) = :dist_gl_date
 and ae.event_status_code <> ''P''
 and ae.event_type_code = :override_event
 and ae.application_id = 222
 and xt.application_id = 222';

log('l_stmt :'||l_stmt);

    l_c  := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_c, l_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.BIND_VARIABLE(l_c,':trx_id',p_trx_id);
    DBMS_SQL.BIND_VARIABLE(l_c,':dist_gl_date',p_gl_date);
    DBMS_SQL.BIND_VARIABLE(l_c,':override_event',p_override_event);

    DBMS_SQL.DEFINE_COLUMN(l_c,1,x_match_event_id);
    DBMS_SQL.DEFINE_COLUMN(l_c,2,x_match_gl_date);
    DBMS_SQL.DEFINE_COLUMN(l_c,3,x_match_status,30);
    DBMS_SQL.DEFINE_COLUMN(l_c,4,x_match_type,30);
    l_exec := DBMS_SQL.EXECUTE(l_c);
    l_fetch_row := DBMS_SQL.FETCH_ROWS(l_c);
    DBMS_SQL.COLUMN_VALUE(l_c, 1, x_match_event_id);
    DBMS_SQL.COLUMN_VALUE(l_c, 2, x_match_gl_date);
    DBMS_SQL.COLUMN_VALUE(l_c, 3, x_match_status);
    DBMS_SQL.COLUMN_VALUE(l_c, 4, x_match_type);
    DBMS_SQL.CLOSE_CURSOR(l_c);

IF x_match_gl_date IS NULL THEN x_match_gl_date := TO_DATE('01-01-1900','DD-MM-YYYY'); END IF;
IF x_match_status IS NULL THEN x_match_status := 'X'; END IF;

log('get_best_existing_event -');
END;

--}



/*========================================================================
 | PUBLIC PROCEDURE Create_Events
 |
 | DESCRIPTION
 |      Main routine which forks processing based on input parameters
 |      and creates events for a given Document.
 |
 |      This procedure does the following calls the create events routine
 |      for :
 |      a) Transactions
 |      b) Bills Receivable
 |      c) Receipts
 |      d) Adjustments
 |      e) Receipt/CM applications
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_All_Events
 |
 | PARAMETERS p_ev_rec which contains
 |      1) xla_from_doc_id  IN     NUMBER   --document id from
 |      2) xla_to_doc_id    IN     NUMBER   --document id to
 |      3) xla_req_id       IN     NUMBER   --request id batch processing
 |      4) xla_dist_id      IN     NUMBER   --distribution id
 |      5) xla_doc_table    IN     VARCHAR2 --document table OLTP
 |           CT   - Transactions
 |           CTCMAPP - Transactions and Credit Memo Applications
 |           ADJ  - Adjustments
 |           CRH  - Cash Receipt History
 |           CR   - Cash Receipt History and Misc Cash or Applications
 |           MCD   -Misc Cash Distributions
 |           APP   -Applications for Receipts
 |           CMAPP -Applications for CM
 |           TRH - Transaction history for Bills
 |      6) xla_doc_event    IN     VARCHAR2 --document business event OLTP
 |      7) xla_mode         IN     VARCHAR2
 |           U-upgrade
 |           O-oltp
 |           B-batch mode
 |      8) xla_call         IN     VARCHAR2
 |           C - Create events only
 |           D - Denormalize events only
 |           B - Create and Denormalize events on distributions
 |      9) xla_fetch_size   IN     NUMBER   --Bulk fetch size
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-AUG-2001           Vikram Ahluwalia  Created
 | 23-JUN-2005           Herve Yu          Ledger Id and Transaction Date
 *=======================================================================*/
PROCEDURE Create_Events(p_xla_ev_rec IN OUT NOCOPY xla_events_type ) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
 l_event_source_info   xla_events_pub_pkg.t_event_source_info;
 l_event_id            NUMBER;
 l_security            xla_events_pub_pkg.t_security;

BEGIN

   log('ARP_XLA_EVENTS.Create_Events()+');

   log('xla_from_doc_id    :'
                           || p_xla_ev_rec.xla_from_doc_id);

   log('xla_to_doc_id    :'
                           || p_xla_ev_rec.xla_to_doc_id);

   log('p_xla_req_id    :'
                           || p_xla_ev_rec.xla_req_id);

   log('p_xla_dist_id    :'
                           || p_xla_ev_rec.xla_dist_id);

   log('p_xla_doc_table :'
                           || p_xla_ev_rec.xla_doc_table);

   log('p_xla_doc_event :'
                           || p_xla_ev_rec.xla_doc_event);

   log('p_xla_mode      :'
                           || p_xla_ev_rec.xla_mode);

   log('p_xla_call      :'
                           || p_xla_ev_rec.xla_call);

   log('p_xla_fetch_size:'
                           || p_xla_ev_rec.xla_fetch_size);

/*-----------------------------------------------------------------------+
 | Create Events for documents                                           |
 +-----------------------------------------------------------------------*/
   Create_All_Events(p_xla_ev_rec => p_xla_ev_rec);

/*-----------------------------------------------------------------------+
 | Denormalize event ids on distributions                                |
 +-----------------------------------------------------------------------*/
-- bug 5965006
   g_call_number := 1;

   IF p_xla_ev_rec.xla_doc_table IN ('CTCMAPP') THEN
        g_call_number := 2;
   END IF;

   Upd_Dist(p_xla_ev_rec => p_xla_ev_rec);

   IF p_xla_ev_rec.xla_doc_table IN ('CTCMAPP') THEN
        g_call_number := 1;
        Upd_Dist(p_xla_ev_rec => p_xla_ev_rec);
   END IF;


   log('ARP_XLA_EVENTS.Create_Events()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log('NO_DATA_FOUND EXCEPTION: ARP_XLA_EVENTS.Create_Events');
    RAISE;

  WHEN OTHERS THEN
    log('OTHERS EXCEPTION: ARP_XLA_EVENTS.Create_Events');
    RAISE;

END Create_Events;

/*========================================================================
 | PUBLIC PROCEDURE Create_Events_doc
 |
 | DESCRIPTION
 |    Overload structure on the top of Create_events.
 |    This procedure is introduced to avoid record type structure.
 |    It is for the execution with document ids.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Events
 |
 | PARAMETERS
 |      1) p_document_id    IN     NUMBER   --document id from
 |      2) p_doc_table      IN     VARCHAR2 --document table OLTP
 |           CT   - Transactions
 |           ADJ  - Adjustments
 |           CRH  - Cash Receipt History
 |           CR   - Cash Receipt History and Misc Cash
 |           Distributions
 |           MCD   -Misc Cash Distributions
 |           APP   -Applications for Receipts
 |           CMAPP -Applications for CM
 |           TRH - Transaction history for Bills
 |      3) p_mode          IN     VARCHAR2
 |           U-upgrade
 |           O-oltp
 |           B-batch mode
 |      4) p_call          IN     VARCHAR2
 |           C - Create events only
 |           D - Denormalize events only
 |           B - Create and Denormalize events on distributions
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-OCT-2002           Herve Yu          Created
 *=======================================================================*/
  PROCEDURE create_events_doc( p_document_id  IN NUMBER,
                               p_doc_table    IN VARCHAR2,
                               p_mode         IN VARCHAR2,
                               p_call         IN VARCHAR2)
  IS
    l_xla_ev_rec  arp_xla_events.xla_events_type;
  BEGIN
    log('arp_xla_events.create_events_doc ()+');
    l_xla_ev_rec.xla_doc_table   := p_doc_table;
    l_xla_ev_rec.xla_from_doc_id := p_document_id;
    l_xla_ev_rec.xla_to_doc_id   := p_document_id;
    l_xla_ev_rec.xla_mode        := p_mode;
    l_xla_ev_rec.xla_call        := p_call;
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    log('arp_xla_events.create_events_doc ()-');
  EXCEPTION
    WHEN OTHERS THEN
    log('EXCEPTION: arp_xla_events.create_events_doc');
     RAISE;
  END;


/*========================================================================
 | PUBLIC PROCEDURE Create_Events_req
 |
 | DESCRIPTION
 |    Overload structure on the top of Create_events.
 |    This procedure is introduced to avoid record type structure.
 |    It is for the execution with request ids.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      a) Create_Events
 |
 | PARAMETERS
 |      1) p_request_id    IN     NUMBER   --request id from
 |      2) p_doc_table     IN     VARCHAR2 --document table OLTP
 |           CT   - Transactions
 |           ADJ  - Adjustments
 |           CRH  - Cash Receipt History
 |           CR   - Cash Receipt History and Misc Cash
 |           Distributions
 |           MCD   -Misc Cash Distributions
 |           APP   -Applications for Receipts
 |           CMAPP -Applications for CM
 |           TRH - Transaction history for Bills
 |      3) p_mode          IN     VARCHAR2
 |           U-upgrade
 |           O-oltp
 |           B-batch mode
 |      4) p_call          IN     VARCHAR2
 |           C - Create events only
 |           D - Denormalize events only
 |           B - Create and Denormalize events on distributions
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-OCT-2002           Herve Yu          Created
 *=======================================================================*/
  PROCEDURE create_events_req( p_request_id   IN NUMBER,
                               p_doc_table    IN VARCHAR2,
                               p_mode         IN VARCHAR2,
                               p_call         IN VARCHAR2)
  IS
    l_xla_ev_rec  arp_xla_events.xla_events_type;
  BEGIN
    log('arp_xla_events.create_events_req ()+');
    l_xla_ev_rec.xla_doc_table   := p_doc_table;
    l_xla_ev_rec.xla_req_id      := p_request_id;
    l_xla_ev_rec.xla_mode        := p_mode;
    l_xla_ev_rec.xla_call        := p_call;
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    log('arp_xla_events.create_events_req ()-');
  EXCEPTION
    WHEN OTHERS THEN
      log('EXCEPTION: arp_xla_events.create_events_req');
      RAISE;
  END;

/*========================================================================
 | PUBLIC PROCEDURE Build_Stmt
 |
 | DESCRIPTION
 |      Build the dynamic SQL for creation of events or denormalization of
 |      events based on input parameter values.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Get_Select_Cursor
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS p_ev_rec IN  Event input parameter record
 |            p_stmt   OUT Build dynamic SQL statement buffer
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-OCT-2002           Herve             Add the bind_variable b_xla_mode.
 |
 |           Need to differentiate the SQL statement by execution mode.
 |
 |           For example in Upgrade mode or in OLTP, for a postable document,
 |             distribution stamped with a event_id,
 |             trx_status complete,
 |             no status for the event
 |             exist_dist_gl_date null is abnormal.
 |
 |           * In OLTP, the OLTP sql will populate the event status.
 |           * In Upgrade mode the distribution stamped with a event_id is impossible.
 |           * But in Batch mode this situation can happen, when a receipt is created
 |             RECP_CREATE, then submit autoreceipt process in batch mode to create the
 |             the RECEIPT REMITTANCE record with the RECP_REMIT event.
 |             The previous RECP_CREATE event causes the situation described happen.
 |               - distribution is stamped True.
 |               - trx_complete
 |               - no status event and exist gl date is null because OLTP sql not executed.
 |             So by adding the clause based on :b_xla_mode, avoidance to retrieve the existing
 |             RECP_CREATE is accomplished so that the same situation of Upgrade happens.
 |
 *=======================================================================*/
PROCEDURE Build_Stmt(p_xla_ev_rec IN  xla_events_type,
                     p_call_point IN  NUMBER,
                     p_stmt       OUT NOCOPY VARCHAR2) IS

l_select_clause          VARCHAR2(10000);
l_from_clause            VARCHAR2(2000);
l_where_parm_clause      VARCHAR2(2000);
l_where_parm_clause_crh  VARCHAR2(2000);
l_where_clause           VARCHAR2(5000);
l_order_by_clause        VARCHAR2(2000);
l_group_by_clause        VARCHAR2(5000);
l_all_clause             VARCHAR2(4)   ;
l_union                  VARCHAR2(10)  ;
CRLF                     CONSTANT VARCHAR2(1) := arp_global.CRLF;

BEGIN
   log('ARP_XLA_EVENTS.Build_Stmt ()+');


   IF p_xla_ev_rec.xla_doc_table IN ('CRHMCD','CRHAPP','CTCMAPP') THEN
      l_union := ' UNION ';
   END IF;

  ------------------------------------------------------------------
  --Set the bulk fetch size
  ------------------------------------------------------------------
   IF p_xla_ev_rec.xla_fetch_size IS NOT NULL THEN
      MAX_ARRAY_SIZE := p_xla_ev_rec.xla_fetch_size;
   END IF;

  -------------------------------------------------------------------
  --Set the all clause to access base tables
  -------------------------------------------------------------------
   IF p_xla_ev_rec.xla_mode = 'U' THEN
      l_all_clause := '_all';
   END IF;

  -------------------------------------------------------------------
  --Build Generic select fragments
  -------------------------------------------------------------------

  -------------------------------------------------------------------
  -- Build statement for Transactions event creation
  -------------------------------------------------------------------
   IF (p_xla_ev_rec.xla_doc_table IN ('CT', 'CTCMAPP','CTNORCM')) THEN

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN
         --{BUG#5561163
         IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
           l_where_parm_clause :=
           '     AND ctlgd.customer_trx_id = :b_xla_from_doc_id
		     AND ctlgd.customer_trx_id = :b_xla_to_doc_id ' || CRLF;
         ELSE
           l_where_parm_clause :=
           '     AND ctlgd.customer_trx_id >= :b_xla_from_doc_id
               AND ctlgd.customer_trx_id <= :b_xla_to_doc_id   ' || CRLF;
         END IF;
         --}
      END IF;

      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND ctlgd.request_id = :b_xla_req_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND ctlgd.cust_trx_line_gl_dist_id = :b_xla_dist_id ' || CRLF;
      END IF;

    ------------------------------------------------------------------
    -- Build the clause for transactions create events stmt
    ------------------------------------------------------------------
      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

      l_select_clause :=
      ' select
        tty.post_to_gl                                POSTTOGL       ,
        tty.type                                      TRX_TYPE       ,
        decode(ct.complete_flag,
               ''Y'',''C'',
               ''I'')                                 COMP_FLAG      ,
        ctlgd.customer_trx_id                         TRX_ID         ,
        ct.trx_number                                 TRX_NUMBER     ,
        ct.org_id                                     ORG_ID         ,
        decode(nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
               nvl(ctlgd1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                  decode(ctlgd.posting_control_id,
                         ctlgd1.posting_control_id,  tty.type || ''_CREATE'',
                         tty.type || ''_UPDATE''),
               tty.type || ''_UPDATE'')               OVERRIDE_EVENT ,
        ctlgd.posting_control_id                      PSTID          ,
        nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')) GL_DATE,
        ctlgd.event_id                                EXIST_EVENT    ,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        ct.trx_date                            TRANSACTION_DATE,
        ct.legal_entity_id                            LEGAL_ENTITY_ID ' || CRLF;

        l_from_clause :=
      ' FROM ra_cust_trx_types'        || l_all_clause || ' tty,  '   || CRLF ||
      '      ra_customer_trx'          || l_all_clause || ' ct,   '   || CRLF ||
      '      ra_cust_trx_line_gl_dist' || l_all_clause || ' ctlgd1, ' || CRLF ||
      '      ra_cust_trx_line_gl_dist' || l_all_clause || ' ctlgd '   || CRLF;

--note that the ctlgd1 fragment can be made dynamic for batch processes
--since none of the distributions will be posted.

        l_where_clause :=
      ' WHERE decode(ctlgd.account_class,
                     ''REC'',ctlgd.latest_rec_flag,
                     ''Y'')              = ''Y''
        AND DECODE(ctlgd.account_set_flag,
                   ''N'',''N'',
                   ''Y'', decode(ctlgd.account_class,
                               ''REC'',''N'',
                               ''Y'')
                  ) = ''N''
        AND decode(ctlgd.event_id,
                   '''', ''Y'',
                   decode(:b_xla_mode, ''O'',''Y'',
                                              ''N'')) = ''Y''
        AND   ctlgd.customer_trx_id = ct.customer_trx_id
        AND   ctlgd1.customer_trx_id = ct.customer_trx_id
        AND   ctlgd1.latest_rec_flag = ''Y''
        AND   ct.cust_trx_type_id   = tty.cust_trx_type_id
        AND   nvl(tty.org_id,-9999) = nvl(ct.org_id,-9999) ' || CRLF;

      --{CTCMAPP should pick only the regular CM
      IF (p_xla_ev_rec.xla_doc_table IN ('CTCMAPP')) THEN
        l_where_clause := l_where_clause ||
        ' AND ct.PREVIOUS_CUSTOMER_TRX_ID IS NOT NULL
          AND tty.type  = ''CM'' ' || CRLF;
      END IF;
      --}

-- bug 5965006
      IF (p_xla_ev_rec.xla_doc_table IN ('CTNORCM')) THEN
         l_where_clause := l_where_clause ||
                          ' AND decode(tty.type, ''CM'',
                                       decode(nvl(ct.PREVIOUS_CUSTOMER_TRX_ID,0),0,''Y'',
                                       ''N''), ''Y'') = ''Y'' ' || CRLF;
      END IF;

       l_group_by_clause :=
    ' GROUP BY
       tty.post_to_gl,
       tty.type,
       decode(ct.complete_flag,
              ''Y'',''C'',
              ''I''),
       ctlgd.customer_trx_id,
       ct.trx_number,
       ct.org_id,
       decode(nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
              nvl(ctlgd1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                 decode(ctlgd.posting_control_id,
                        ctlgd1.posting_control_id,  tty.type || ''_CREATE'',
                        tty.type || ''_UPDATE''),
              tty.type || ''_UPDATE'') ,
       ctlgd.posting_control_id,
       nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
       ctlgd.event_id ,
       ct.trx_date,
       ct.legal_entity_id'|| CRLF;

      IF p_xla_ev_rec.xla_doc_table IN ('CT','CTNORCM') THEN
        l_order_by_clause :=
        'ORDER BY TRX_ID, OVERRIDE_EVENT, GL_DATE, PSTID DESC ';
      END IF;

    --------------------------------------------------------------------
    -- Build the clause for Transactions denormalize events stmt
    --------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Transactions statement ' );

        l_select_clause :=
     --BUG#5415512
      ' SELECT /*+ leading(ctlgd,evn,ev1) use_nl(evn,ev1) */
               ctlgd.rowid,
               ev1.event_id ';

        l_from_clause :=
      ' FROM xla_events'           ||                 ' ev1,  '  || CRLF ||
      '  xla_transaction_entities_upg' ||                 ' evn,  '  || CRLF ||
      '      ra_cust_trx_line_gl_dist' || l_all_clause || ' ctlgd '  || CRLF;

--{BUG#5131345 suggested by perf team

        l_where_clause :=
      ' WHERE ctlgd.account_set_flag = ''N''
        AND   ctlgd.event_id IS NULL
        AND   evn.entity_code = ''TRANSACTIONS''
        AND   evn.application_id = 222
        AND   ev1.entity_id       = evn.entity_id
        AND   evn.application_id  = 222
  AND  nvl(evn.source_id_int_1,-99) = ctlgd.customer_trx_id
  AND  evn.ledger_id          = ctlgd.set_of_books_id
  AND  ev1.application_id     = 222
        AND   ctlgd.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND    nvl(ev1.event_date,to_date(''01-01-1900'',''DD-MM-YYYY''))
              = nvl(ctlgd.gl_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND    (((ctlgd.posting_control_id = -3)
                  AND (ev1.event_status_code <> ''P''))
               OR ((ctlgd.posting_control_id <> -3)
                    AND (ev1.event_status_code = ''P'' ))) ' || CRLF;

        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Transactions statement ' );
      END IF; --create or update mode

   END IF; --transaction

  -------------------------------------------------------------------
  -- Build statement for Adjustments event creation
  -------------------------------------------------------------------
   IF (p_xla_ev_rec.xla_doc_table = 'ADJ') THEN

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN

         --{BUG#5561163
         IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
           l_where_parm_clause :=
           '    AND  adj.adjustment_id = :b_xla_from_doc_id
		      AND adj.adjustment_id = :b_xla_to_doc_id' || CRLF;
         ELSE
           l_where_parm_clause :=
           '     AND adj.adjustment_id >= :b_xla_from_doc_id
               AND adj.adjustment_id <= :b_xla_to_doc_id   ' || CRLF;
         END IF;
         --}

      END IF;

      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND adj.request_id = :b_xla_req_id ' || CRLF;
      END IF;

    --Not applicable to adjustment document
      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause ||
              'AND adj.adjustment_id = :b_xla_dist_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

--HYU trsnaction_date,legal_entity_id
      l_select_clause :=
      ' select
        decode(tty.post_to_gl,''Y'',tty.post_to_gl,nvl(tty.adj_post_to_gl,''N''))  POSTTOGL       ,
        ''ADJ''                                       TRX_TYPE       ,
        decode(adj.status,
               ''A'',''C'',
               ''I'')                                 COMP_FLAG      ,
        adj.adjustment_id                             TRX_ID         ,
        adj.adjustment_number                         TRX_NUMBER     ,
        adj.org_id                                    ORG_ID,
        ''ADJ_CREATE''                                OVERRIDE_EVENT ,
        adj.posting_control_id                        PSTID          ,
        nvl(adj.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')) GL_DATE,
        adj.event_id                                  EXIST_EVENT    ,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        ct.trx_date                          TRANSACTION_DATE,
        ct.legal_entity_id                           LEGAL_ENTITY_ID' || CRLF;

        l_from_clause :=
      ' FROM  ra_cust_trx_types'          || l_all_clause || ' tty,  ' || CRLF ||
      '      ra_customer_trx'            || l_all_clause || ' ct,   ' || CRLF ||
      '      ar_adjustments'             || l_all_clause || ' adj   ' || CRLF;

   ----------------------------------------------------------------------------------
   --A script to denormalize the BR_ADJUSTMENT_ID on adjustment table may be written
   --Open issue - Should Invoice against Deposit, Guarantee, shadow adjustments for
   --Bills Receivable and chargeback adjustments be created as a seperate adjustment
   --event or tracked as Create Invoice, Create Bills Receivable, Create Chargeback
   --events respectively. As of now for simplicity purposes seperate events are
   --retained.
   --Note : If treated as main transaction events then if gl date is different from
   --Invoice GL date for Create Invoice event, should the next event by Modify Invoice
   --or a new event called Adjust Invoice , or should we always have an adjust Invoice
   --event for shuch mergable evcent cases. Adjustments -> ADJ_CREATE, OR INV_ADJUST
   --Should a check be made to create events based on whether the adjustment has a
   --document sequence number ?
   ----------------------------------------------------------------------------------
      l_where_clause :=
      ' WHERE adj.customer_trx_id   = ct.customer_trx_id
        AND   ct.cust_trx_type_id   = tty.cust_trx_type_id
        AND decode(adj.event_id,
                   '''', ''Y'',
                   decode(:b_xla_mode, ''O'',''Y'',
                                              ''N'')) = ''Y''
        AND   nvl(tty.org_id,-9999) = nvl(ct.org_id,-9999) ' || CRLF;

   ----------------------------------------------------------------------------------
   --Open issue whether adjustments require to have a single event by adjusted document
   --because they have document sequencing, or do we need to create a seperate event
   --as INVOICE_ADJUST ? The group by clause will ascertain the uniqueness of the
   --created events. The solution may be to create the event as adjustment if document
   --sequence is populated else as an adjust transaction type event
   ----------------------------------------------------------------------------------
      l_group_by_clause := '';

      l_order_by_clause := '';


    ------------------------------------------------------------------
    -- Build the clause for adjustments denormalize events stmt
    ------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Adjustments statement ' );
        l_select_clause :=
      ' SELECT adj.rowid,
               ev1.event_id ';

        l_from_clause :=
      ' FROM xla_events'               ||                 ' ev1,  '  || CRLF ||
      '  xla_transaction_entities_upg' ||                 ' evn,  '  || CRLF ||
      '      ar_adjustments'           || l_all_clause || ' adj   '  || CRLF;

        l_where_clause :=
      ' WHERE adj.event_id IS NULL
        AND   evn.entity_code = ''ADJUSTMENTS''
        AND   evn.application_id = 222
        AND   ev1.entity_id  = evn.entity_id
        AND   NVL(evn.source_id_int_1,-99) = adj.adjustment_id
        AND   evn.ledger_id  = adj.set_of_books_id
        AND   ev1.application_id = 222
        AND   adj.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND    (((adj.posting_control_id = -3)
                  AND (ev1.event_status_code <> ''P''))
               OR ((adj.posting_control_id <> -3)
                    AND (ev1.event_status_code = ''P'' ))) ' || CRLF;


        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Adjustments statement ' );

      END IF; --Create event or denormalize

   END IF; --build adjustment event

  -------------------------------------------------------------------
  -- Build statement for Cash Receipts event creation
  -------------------------------------------------------------------
   IF (p_xla_ev_rec.xla_doc_table IN ('CRH','CRHMCD','CRHAPP')) THEN

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN

         --{BUG#5561163
         IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
           l_where_parm_clause :=
           '  AND  crh.cash_receipt_id = :b_xla_from_doc_id
            AND crh.cash_receipt_id = :b_xla_to_doc_id  ' || CRLF;
         ELSE
           l_where_parm_clause :=
         '   AND  crh.cash_receipt_id >= :b_xla_from_doc_id
               AND crh.cash_receipt_id <= :b_xla_to_doc_id   ' || CRLF;
         END IF;
         --}
      END IF;

      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND crh.request_id = :b_xla_req_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND crh.cash_receipt_history_id = :b_xla_dist_id ' || CRLF;
      END IF;

    ------------------------------------------------------------------
    -- Build the clause for cash receipt history create events stmt
    -- In Reality there should be a Union between APP and CRH
    --Note for CRH for APPROVED status 1952 has been seeded as the
    --gl date, this is defaulted to 1900 to enable change matrix
    --processing, in the event record a null gl date will exist
    ------------------------------------------------------------------
    -- This code is missing the following business rule :
    -- If the previous CRH record is posted then no matter of status
    -- event is RECP_CREATE.
    -- For example,
    -- 1) we create a receipt with the status REMITTED
    --    it will first create a RECP_CREATE event because its first posted flag is Y
    -- 2) we posted the receipt.
    -- 3) we increase the amount of the receipt, AR will create another CRH with the
    --    status REMITTED with the first posted rec flag <> Y
    --    So it will generate a RECP_REMIT event. Which is incorrect we need to create
    --    another RECP_CREATE.
    ------------------------------------------------------------------

      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

      l_select_clause :=
      ' select
        crh.postable_flag                             POSTTOGL       ,
        ''RECP''                                      TRX_TYPE       ,
        decode(crh.status,
               ''APPROVED'', ''I'',
               ''C'')                                 COMP_FLAG      ,
        crh.cash_receipt_id                           TRX_ID         ,
        cr.receipt_number                             TRX_NUMBER     ,
        cr.org_id                                     ORG_ID,
        decode(cr.type,
               ''MISC'',''MISC_'',
               '''') ||
        decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'', ''RECP_RATE_ADJUST'',
               decode(crh.status,
                      ''REVERSED'',''RECP_REVERSE'',
                      decode(crh1.first_posted_record_flag,
                             '''', ''RECP_CREATE'',
                             decode(decode(crh.postable_flag,
                                           ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                                           nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))),
                                    nvl(crh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                    decode(crh.posting_control_id,
                                           crh1.posting_control_id, ''RECP_CREATE'',
                                           ''RECP_UPDATE''),
                                    ''RECP_UPDATE'')))) OVERRIDE_EVENT,
        crh.posting_control_id                        PSTID          ,
        decode(crh.postable_flag,
               ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
               nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))) GL_DATE,
        crh.event_id                                  EXIST_EVENT,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        cr.receipt_date                               TRANSACTION_DATE,
        cr.legal_entity_id                             LEGAL_ENTITY_ID   ' || CRLF;

        l_from_clause :=
      ' FROM ar_cash_receipts'         || l_all_clause || ' cr,  '  || CRLF ||
      '      ar_cash_receipt_history'  || l_all_clause || ' crh1, ' || CRLF ||
      '      ar_cash_receipt_history'  || l_all_clause || ' crh  '  || CRLF;

       l_where_clause :=  ' WHERE crh.cash_receipt_id = cr.cash_receipt_id '    || CRLF ||
                          ' AND cr.cash_receipt_id = crh1.cash_receipt_id (+) ' || CRLF ||
                          ' AND ''Y'' = crh1.first_posted_record_flag (+) '     || CRLF ||
                          ' AND decode(crh.event_id,
                                       '''', ''Y'',
                                       decode(:b_xla_mode, ''O'',''Y'',
                                              ''N'')) = ''Y'' '                 || CRLF ||
                          ' AND decode(crh.postable_flag, ''Y'',''Y'', '        || CRLF ||
                          '       decode(crh.status, ''APPROVED'', '            || CRLF ||
                          '         decode(crh1.first_posted_record_flag, '''',''Y'', ' || CRLF ||
                          '                ''N''), '                                    || CRLF ||
                          '              ''N'')) = ''Y'' '                              || CRLF ;

       IF p_xla_ev_rec.xla_doc_table IN ('CRHMCD','CRHAPP') THEN
          l_where_clause := l_where_clause || l_where_parm_clause;
       END IF;

       l_group_by_clause :=
    ' GROUP BY
        crh.cash_receipt_id,
        cr.receipt_number,
        cr.org_id,
        decode(crh.status,
               ''APPROVED'', ''I'',
               ''C''),
        crh.postable_flag,
        crh.posting_control_id,
        decode(cr.type,
               ''MISC'',''MISC_'',
               '''') ||
        decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'', ''RECP_RATE_ADJUST'',
               decode(crh.status,
                     ''REVERSED'',''RECP_REVERSE'',
                        decode(crh1.first_posted_record_flag,
                               '''', ''RECP_CREATE'',
                               decode(decode(crh.postable_flag,
                                             ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                                             nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))),
                                      nvl(crh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                      decode(crh.posting_control_id,
                                             crh1.posting_control_id, ''RECP_CREATE'',
                                             ''RECP_UPDATE''),
                                      ''RECP_UPDATE'')))),
                decode(crh.postable_flag,
                       ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                       nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))),
                crh.event_id,
                cr.receipt_date,
                cr.legal_entity_id' || CRLF;

   /*---------------------------------------------------------------------+
    |The where clause below is appended to the Select which pulls data    |
    |from the inline query. Hence it appears odd that order by should have|
    |a where but nevertheless it is required                              |
    +---------------------------------------------------------------------*/
      /** BUG 6660834
      We can directly use the field OVERRIDE_EVENT in order by clause, s the value
      itself will maintain the order we are expecting in all the cases except in case
      where we have both RECP_UPDATE and RECP_REVERSE in the same call,this
      is only possible in case of an upgrade and this is not used for upgrade*/
      /*l_order_by_clause := l_order_by_clause ||
      'ORDER BY TRX_ID,
                decode(OVERRIDE_EVENT,
                       ''RECP_CREATE''             ,1,
                       ''RECP_UPDATE''             ,2,
                       ''RECP_RATE_ADJUST''        ,3,
                       ''RECP_REVERSE''            ,6,
                       ''MISC_RECP_CREATE''        ,1,
                       ''MISC_RECP_UPDATE''        ,2,
                       ''MISC_RECP_RATE_ADJUST''   ,3,
                       ''MISC_RECP_REVERSE'',       6,
                       7),
                GL_DATE,
                PSTID desc ' || CRLF;*/

      l_order_by_clause := l_order_by_clause || 'ORDER BY TRX_ID,OVERRIDE_EVENT,GL_DATE, PSTID desc ' || CRLF;

      log('l_select_clause   = ' || l_select_clause);
      log('l_order_by_clause = ' || l_order_by_clause);

    ---------------------------------------------------------------------
    -- Build the clause for Cash Receipt History  denormalize events stmt
    ---------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Cash Receipt History statement ' );

        l_select_clause :=
      ' SELECT crh.rowid,
               ev1.event_id ';

        l_from_clause :=
      ' FROM xla_events'               ||                 ' ev1,  '  || CRLF ||
      '      xla_transaction_entities_upg' ||                 ' evn,  '  || CRLF ||
      '      ar_cash_receipts'         || l_all_clause || ' cr,   '  || CRLF ||
      '      ar_cash_receipt_history'  || l_all_clause || ' crh   '  || CRLF ;

        l_where_clause :=
        ' WHERE
        decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'',
                     decode(cr.type,''MISC'',''MISC_'','''') || ''RECP_RATE_ADJUST'',
               decode(crh.status,
                     ''REVERSED'',
                         decode(cr.type,''MISC'',''MISC_'','''') || ''RECP_REVERSE'',
                     ev1.event_type_code)) = ev1.event_type_code
        AND   crh.event_id IS NULL
        AND   ev1.entity_id = evn.entity_id
        AND   ev1.application_id = 222
        AND   evn.application_id = 222
        AND   evn.entity_code = ''RECEIPTS''
        AND   crh.cash_receipt_id = NVL(evn.source_id_int_1,-99)
        AND   evn.ledger_id = cr.set_of_books_id
        AND   crh.cash_receipt_id = cr.cash_receipt_id
        AND   crh.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND decode(crh.postable_flag,
                   ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                   nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')))
               = nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND   decode(crh.posting_control_id,
                     -3, ev1.event_status_code,
                     ''P'') = ev1.event_status_code '||CRLF;

        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Cash Receipt History statement ' );

      END IF; --create or update mode

   END IF; --transaction

  -------------------------------------------------------------------
  -- Build statement for Misc Cash Distributions events creation
  -------------------------------------------------------------------
   IF p_xla_ev_rec.xla_doc_table IN ('MCD', 'CRHMCD') THEN

      IF p_xla_ev_rec.xla_call IN ('C', 'B')
            AND p_call_point = 1 AND p_xla_ev_rec.xla_doc_table = 'CRHMCD' THEN

         l_where_parm_clause_crh := l_where_parm_clause;
         l_where_parm_clause     := '';

      END IF;

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN


         --{BUG#5561163
         IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
           l_where_parm_clause :=
           ' AND   mcd.cash_receipt_id = :b_xla_from_doc_id
            AND mcd.cash_receipt_id = :b_xla_to_doc_id ' || CRLF;
         ELSE
         l_where_parm_clause :=
         '   AND  mcd.cash_receipt_id >= :b_xla_from_doc_id
               AND mcd.cash_receipt_id <= :b_xla_to_doc_id   ' || CRLF;
         END IF;
         --}
      END IF;

      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND mcd.request_id = :b_xla_req_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND mcd.misc_cash_distribution_id = :b_xla_dist_id ' || CRLF;
      END IF;

    ------------------------------------------------------------------
    -- Build the clause for Misc cash receipt create events stmt
    -- In Reality there should be a Union between APP and CRH
    --Note for CRH for APPROVED status 1952 has been seeded as the
    --gl date, this is defaulted to 1900 to enable change matrix
    --processing, in the event record a null gl date will exist
    ------------------------------------------------------------------
      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

        IF p_xla_ev_rec.xla_doc_table = 'CRHMCD' THEN
           l_select_clause := l_select_clause         || l_from_clause     || l_where_clause ||
                              l_where_parm_clause_crh || l_group_by_clause || l_union || CRLF;
        END IF;

--HYU transaction_date,legal_entity_id
      l_select_clause := l_select_clause ||
      ' select
        ''Y''                                         POSTTOGL       ,
        ''RECP''                                      TRX_TYPE       ,
        ''C''                                         COMP_FLAG      ,
        mcd.cash_receipt_id                           TRX_ID         ,
        cr.receipt_number                             TRX_NUMBER     ,
        cr.org_id                                     ORG_ID,
        decode(mcd.created_from,
               ''RATE ADJUSTMENT TRIGGER'', ''MISC_RECP_RATE_ADJUST'',
               decode(SUBSTRB(mcd.created_from,1,19),
                      ''ARP_REVERSE_RECEIPT'',''MISC_RECP_REVERSE'',
                      decode(nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             nvl(mcd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             decode(crh.posting_control_id,
                                    mcd.posting_control_id, ''MISC_RECP_CREATE'',
                                    ''MISC_RECP_UPDATE''),
                             ''MISC_RECP_UPDATE'')))  OVERRIDE_EVENT,
        mcd.posting_control_id                        PSTID         ,
        nvl(mcd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')) GL_DATE,
        mcd.event_id                                  EXIST_EVENT,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS,
        cr.receipt_date                               TRANSACTION_DATE,
        cr.legal_entity_id                            LEGAL_ENTITY_ID  ' || CRLF;

        log('l_select_clause ' || l_select_clause);

        l_from_clause :=
      ' FROM ar_misc_cash_distributions'  || l_all_clause || ' mcd,  ' || CRLF ||
      '      ar_cash_receipts'            || l_all_clause || ' cr, '   || CRLF ||
      '      ar_cash_receipt_history'     || l_all_clause || ' crh '   || CRLF;

        log('l_from_clause ' || l_from_clause);

       l_where_clause :=  ' WHERE 1 = 1 '                                  || CRLF ||
                          ' AND mcd.cash_receipt_id = cr.cash_receipt_id ' || CRLF ||
                          ' AND mcd.cash_receipt_id = crh.cash_receipt_id '|| CRLF ||
                          ' AND crh.first_posted_record_flag = ''Y'' '     || CRLF;

       l_group_by_clause :=
    ' GROUP BY mcd.cash_receipt_id,
               cr.receipt_number,
               cr.org_id,
               mcd.posting_control_id,
        decode(mcd.created_from,
               ''RATE ADJUSTMENT TRIGGER'', ''MISC_RECP_RATE_ADJUST'',
               decode(SUBSTRB(mcd.created_from,1,19),
                      ''ARP_REVERSE_RECEIPT'',''MISC_RECP_REVERSE'',
                     decode(nvl(crh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             nvl(mcd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             decode(crh.posting_control_id,
                                    mcd.posting_control_id, ''MISC_RECP_CREATE'',
                                    ''MISC_RECP_UPDATE''),
                             ''MISC_RECP_UPDATE''))),
                nvl(mcd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                mcd.event_id ,
                cr.receipt_date,
                cr.legal_entity_id ' || CRLF;

      IF p_xla_ev_rec.xla_doc_table = 'MCD' THEN

         l_order_by_clause :=
         'ORDER BY TRX_ID,
                   decode(OVERRIDE_EVENT,
                          ''MISC_RECP_CREATE''     ,1,
                          ''MISC_RECP_UPDATE''     ,2,
                          ''MISC_RECP_RATE_ADJUST'',3,
                          ''MISC_RECP_REVERSE''    ,6,
                          7),
                   GL_DATE,
                   PSTID desc ';
      END IF;

      log('l_select_clause   = ' || l_select_clause);
      log('l_where_clause    = ' || l_where_clause);
      log('l_group_by_clause = ' || l_group_by_clause);
      log('l_order_by_clause = ' || l_order_by_clause);

    ------------------------------------------------------------------
    -- Build the clause for Misc Cash Receipts denormalize events stmt
    ------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Misc Cash Distributions statement ' );
        /* Bug 6747662 JVARKEY Modified to check for the rate adjustment event
           from the last record of CRH rather than MCD. The reasom being if the
           receipt is cleared with different rate then a new event won't be
           created but MCD will say creted from Rate Adjustment. So we should
           check created from from CRH */
        l_select_clause :=
      ' SELECT mcd.rowid,
               ev1.event_id ';

        l_from_clause :=
      ' FROM xla_events'                  ||                 ' ev1,  '  || CRLF ||
      '      xla_transaction_entities_upg'    ||                 ' evn,  '  || CRLF ||
      '      ar_cash_receipt_history'     || l_all_clause || ' crh,  '  || CRLF ||
      '      ar_misc_cash_distributions'  || l_all_clause || ' mcd   '  || CRLF ;

        l_where_clause :=
      ' WHERE decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'', ''MISC_RECP_RATE_ADJUST'',
               decode(SUBSTRB(mcd.created_from,1,19),
                      ''ARP_REVERSE_RECEIPT'',''MISC_RECP_REVERSE'',
                      ev1.event_type_code))  = ev1.event_type_code
        AND   crh.cash_receipt_id = mcd.cash_receipt_id
        AND   crh.current_record_flag = ''Y''
        AND   mcd.event_id IS NULL
        AND   ev1.entity_id = evn.entity_id
        AND   evn.application_id = 222
        AND   ev1.application_id = 222
        AND   evn.entity_code = ''RECEIPTS''
        AND   mcd.cash_receipt_id = NVL(evn.source_id_int_1,-99)
        AND   evn.ledger_id = mcd.set_of_books_id
        AND   nvl(mcd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))
               = nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND   mcd.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND   decode(mcd.posting_control_id,
                     -3, ev1.event_status_code,
                     ''P'') = ev1.event_status_code' || CRLF;

        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Misc Cash Distributions statement ' );
      END IF; --create or update mode

    END IF; --create and denormalize events Misc Cash Receipts

  -------------------------------------------------------------------
  -- Build parameter clause for Applications Receipts and CM
  -------------------------------------------------------------------
    IF p_xla_ev_rec.xla_doc_table  IN ('APP','CRHAPP','CMAPP','CTCMAPP') THEN

      IF p_xla_ev_rec.xla_call IN ('C', 'B')
           AND p_call_point = 1 AND p_xla_ev_rec.xla_doc_table IN ('CRHAPP','CTCMAPP') THEN

         l_where_parm_clause_crh := l_where_parm_clause;
         l_where_parm_clause     := '';

      END IF;

-- bug 5965006
      IF p_xla_ev_rec.xla_doc_table IN ('CTCMAPP') AND p_call_point = 2 AND g_call_number = 1 THEN
          l_where_parm_clause     := '';
      END IF;

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN

         --{BUG#5561163
         IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
           l_where_parm_clause :=
           '   AND app.receivable_application_id = :b_xla_from_doc_id
            AND app.receivable_application_id = :b_xla_to_doc_id   ' || CRLF;
         ELSE
           l_where_parm_clause :=
           '   AND  app.receivable_application_id >= :b_xla_from_doc_id
               AND app.receivable_application_id <= :b_xla_to_doc_id   ' || CRLF;
         END IF;
         --}
      END IF;
-- bug 5965006
      IF p_xla_ev_rec.xla_doc_table = 'CTCMAPP' AND p_call_point = 2 AND g_call_number = 2 THEN
         NULL;
      ELSE
      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND app.request_id = :b_xla_req_id ' || CRLF;
      END IF;
      END IF;
      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND app.receivable_application_id = :b_xla_dist_id ' || CRLF;
      END IF;

    END IF; --App and CM app parameter construction section

  -------------------------------------------------------------------
  -- Build statement for Receivable Applications events creation
  -------------------------------------------------------------------
   IF p_xla_ev_rec.xla_doc_table IN ('APP', 'CRHAPP')  THEN

   ------------------------------------------------------------------
   -- Build the clause for Misc cash receipt create events stmt
   -- In Reality there should be a Union between APP and CRH
   --Note for CRH for APPROVED status 1952 has been seeded as the
   --gl date, this is defaulted to 1900 to enable change matrix
   --processing, in the event record a null gl date will exist
   --
   --Resolved Issues
   -----------------
   --I -It is not possible to accurately identify the
   --Unapply receipt application event, because positive and negative
   --application amounts can be created in Receivables to bump up
   --or down the from document (Receipt) and two document balcnce,
   --
   --II - A Receipt application reversed due to Receipt reversal is tagged
   --under the Reverse Receipt event as against the traditionaly event
   --apply receipt.
   --
   ------------------------------------------------------------------------
      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

       IF p_xla_ev_rec.xla_doc_table = 'CRHAPP' THEN
           l_select_clause := l_select_clause         || l_from_clause     || l_where_clause ||
                              l_where_parm_clause_crh || l_group_by_clause || l_union || CRLF;
       END IF;

/* Bug 9761480 : Incorrect OVERRIDE_EVENT 'RECP_RATE_ADJUST' for application records */
      l_select_clause := l_select_clause ||
      ' select
        decode(app.postable,
               ''N'',''N'',
               ''Y'')                                 POSTTOGL       ,
        ''RECP''                                      TRX_TYPE       ,
        decode(NVL(app.confirmed_flag,''Y''),
               ''Y'',''C'',
               ''N'')                                 COMP_FLAG      ,
        cr.cash_receipt_id                            TRX_ID , --BUG#3554871
        cr.receipt_number                             TRX_NUMBER     ,
        cr.org_id                                     ORG_ID         ,
        decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'',
	       decode(crh.posting_control_id, -3,
				decode(crh.gl_date,app.gl_date,''RECP_RATE_ADJUST'',''RECP_UPDATE''), ''RECP_UPDATE''),
               decode(crh.status,
                      ''REVERSED'',''RECP_REVERSE'',
                      decode(crh1.first_posted_record_flag,
                             '''', ''RECP_CREATE'',
                             decode(nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                    nvl(crh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                    decode(app.posting_control_id,
                                           crh1.posting_control_id, ''RECP_CREATE'',
                                           ''RECP_UPDATE''),
                                    ''RECP_UPDATE'')))) OVERRIDE_EVENT,
        app.posting_control_id                                  PSTID  ,
        nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')) GL_DATE,
        app.event_id                                  EXIST_EVENT   ,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        cr.receipt_date                               TRANSACTION_DATE,
        cr.legal_entity_id                            LEGAL_ENTITY_ID ' || CRLF;

        l_from_clause :=
      ' FROM ar_receivable_applications'  || l_all_clause || ' app, '   || CRLF ||
      '      ar_cash_receipt_history'     || l_all_clause || ' crh, '   || CRLF ||
      '      ar_cash_receipt_history'     || l_all_clause || ' crh1, ' || CRLF ||
      '      ar_cash_receipts'            || l_all_clause || ' cr   '   || CRLF ;

--{
-- The join to AND app.status IN (''APP'',''ACTIVITY'',''OTHER ACC'',''ACC'',''UNID'')
-- has been removed in the denormalisation for APPLICATION
--}
       l_where_clause :=
      ' WHERE app.application_type = ''CASH''
        AND app.cash_receipt_history_id = crh.cash_receipt_history_id
        AND app.cash_receipt_id = cr.cash_receipt_id
        AND cr.cash_receipt_id = crh1.cash_receipt_id (+)
        AND ''Y'' = crh1.first_posted_record_flag (+)
        AND decode(app.event_id,
                   '''', ''Y'',
                   decode(:b_xla_mode, ''O'',''Y'',
                                              ''N'')) = ''Y'' '|| CRLF ;

       l_group_by_clause :=
    ' GROUP BY
         cr.cash_receipt_id,
         cr.receipt_number,
         cr.org_id,
         decode(NVL(app.confirmed_flag,''Y''),
                    ''Y'',''C'',
                    ''N''),
         app.posting_control_id,
         decode(app.postable,
                ''N'',''N'',
                ''Y''),
         decode(crh.created_from,
               ''RATE ADJUSTMENT TRIGGER'',
	       decode(crh.posting_control_id, -3,
				decode(crh.gl_date,app.gl_date,''RECP_RATE_ADJUST'',''RECP_UPDATE''), ''RECP_UPDATE''),
               decode(crh.status,
                      ''REVERSED'',''RECP_REVERSE'',
                      decode(crh1.first_posted_record_flag,
                             '''', ''RECP_CREATE'',
                             decode(nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                    nvl(crh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                    decode(app.posting_control_id,
                                           crh1.posting_control_id, ''RECP_CREATE'',
                                           ''RECP_UPDATE''),
                                    ''RECP_UPDATE'')))),
          nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
          app.event_id ,
          cr.receipt_date,
          cr.legal_entity_id' || CRLF;

      IF p_xla_ev_rec.xla_doc_table = 'APP' THEN

       l_order_by_clause :=
       'ORDER BY TRX_ID,
                 decode(OVERRIDE_EVENT,
                        ''RECP_CREATE''     ,1,
                        ''RECP_UPDATE''     ,2,
                        ''RECP_RATE_ADJUST'',3,
                        ''RECP_REVERSE''    ,6,
                        7),
                 GL_DATE,
                 PSTID desc ';
      END IF;

    --------------------------------------------------------------------
    -- Build the clause for Receipts applications denormalize event stmt
    --------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Receivable Apps statement ' );

        l_select_clause :=
      ' SELECT app.rowid,
               ev1.event_id ';

        log('l_select_clause ' || l_select_clause);

        l_from_clause :=
      ' FROM xla_events'                  ||                 ' ev1,  '  || CRLF ||
      '      xla_transaction_entities_upg'    ||                 ' evn,  '  || CRLF ||
      '      ar_receivable_applications'  || l_all_clause || ' app,  '  || CRLF ||
      '      ar_cash_receipt_history'     || l_all_clause || ' crh   '  || CRLF ;

        log('l_from_clause ' || l_from_clause);
--{
-- The join to AND app.status IN (''APP'',''ACTIVITY'',''OTHER ACC'',''ACC'', ''UNID'')
-- has been removed in the denormalisation for APPLICATION
-- Use xla_transaction_entity_n1
--}
	/* Bug 9761480 : Incorrect RATE ADJUSTMENT TRIGGER event_type_code stamped on application record */
        l_where_clause :=
      ' WHERE app.application_type = ''CASH''
        AND   app.event_id IS NULL
        AND   app.cash_receipt_history_id = crh.cash_receipt_history_id
        AND   decode(crh.created_from,
                      ''RATE ADJUSTMENT TRIGGER'', decode(crh.posting_control_id, -3,
				decode(crh.gl_date,app.gl_date,''RECP_RATE_ADJUST'',''RECP_UPDATE''), ''RECP_UPDATE''),
                      decode(crh.status,
                             ''REVERSED'', ''RECP_REVERSE'',
                              ev1.event_type_code))  = ev1.event_type_code
        AND   app.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND   evn.entity_code = ''RECEIPTS''
        AND   ev1.entity_id  = evn.entity_id
        AND   evn.application_id = 222
        AND   ev1.application_id = 222
        AND   app.cash_receipt_id = NVL(evn.source_id_int_1,-99)
        AND   evn.ledger_id       = app.set_of_books_id
        AND   nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))
               = nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND   decode(app.posting_control_id,
                     -3, ev1.event_status_code,
                     ''P'') = ev1.event_status_code ' || CRLF;



        log('l_where_clause' || l_from_clause);

        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Receivable Apps statement ' );

      END IF; --create or update mode

   END IF; --create and denormalize events Receivable applications

  -------------------------------------------------------------------
  -- Build statement for Receivable Applications events creation
  -------------------------------------------------------------------
   IF p_xla_ev_rec.xla_doc_table IN ('CMAPP', 'CTCMAPP') THEN

      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

       IF p_xla_ev_rec.xla_doc_table = 'CTCMAPP' THEN
           l_select_clause := l_select_clause         || l_from_clause     || l_where_clause ||
                              l_where_parm_clause_crh || l_group_by_clause || l_union || CRLF;
       END IF;

      l_select_clause := l_select_clause ||
      ' select
        decode(app.postable,
               ''N'',''N'',
               ''Y'')                                 POSTTOGL       ,
        ''CM''                                        TRX_TYPE       ,
        decode(NVL(app.confirmed_flag,''Y''),
               ''Y'',''C'',
               ''N'')                                 COMP_FLAG      ,
        ctlgd.customer_trx_id                         TRX_ID, --BUG#3554871
        ct.trx_number                                 TRX_NUMBER     ,
        app.org_id                                    ORG_ID         ,
        decode(nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
               nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                  decode(app.posting_control_id,
                         ctlgd.posting_control_id, ''CM_CREATE'',
                         ''CM_UPDATE''),
               ''CM_UPDATE'')                         OVERRIDE_EVENT ,
        app.posting_control_id                        PSTID          ,
        nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')) GL_DATE,
        app.event_id                                  EXIST_EVENT   ,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        ct.trx_date                           TRANSACTION_DATE,
        ct.legal_entity_id                            LEGAL_ENTITY_ID  ' || CRLF;

        l_from_clause :=
      ' FROM ar_receivable_applications'  || l_all_clause || ' app,   ' ||
      '      ra_cust_trx_line_gl_dist'    || l_all_clause || ' ctlgd, ' ||
      '      ra_customer_trx'             || l_all_clause || ' ct     ' ||  CRLF ;

       l_where_clause :=
      ' WHERE app.application_type = ''CM''
        AND app.status IN (''APP'',''ACTIVITY'') --HYU
        AND ctlgd.customer_trx_id = app.customer_trx_id
        AND ctlgd.latest_rec_flag = ''Y''
        AND ctlgd.customer_trx_id = ct.customer_trx_id
        AND decode(app.event_id,
                   '''', ''Y'',
                   decode(:b_xla_mode, ''O'',''Y'',
                                              ''N'')) = ''Y'' '|| CRLF;

       l_group_by_clause :=
    ' GROUP BY ctlgd.customer_trx_id,
               ct.trx_number,
               app.org_id,
               decode(NVL(app.confirmed_flag,''Y''),
                          ''Y'',''C'',
                          ''N''),
               app.posting_control_id,
               decode(app.postable,
                      ''N'',''N'',
                      ''Y''),
               decode(nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                      nvl(ctlgd.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                      decode(app.posting_control_id,
                             ctlgd.posting_control_id, ''CM_CREATE'',
                             ''CM_UPDATE''),
                      ''CM_UPDATE''),
                nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                app.event_id,
                ct.trx_date,
                ct.legal_entity_id ' || CRLF;

      IF p_xla_ev_rec.xla_doc_table = 'CMAPP' THEN

         l_order_by_clause :=
         'ORDER BY TRX_ID,
                   OVERRIDE_EVENT,
                   GL_DATE,
                   PSTID desc ';

      END IF;

    ------------------------------------------------------------------
    -- Build the clause for CM Applications denormalize events stmt
    ------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN
-- bug 5965006
       IF p_xla_ev_rec.xla_doc_table = 'CTCMAPP' AND g_call_number = 2 THEN
          NULL;
       ELSE
        l_select_clause :=
      ' SELECT app.rowid,
               ev1.event_id ';

        l_from_clause :=
      ' FROM xla_events'                  ||                 ' ev1,  '  || CRLF ||
      '      xla_transaction_entities_upg'    ||                 ' evn,  '  || CRLF ||
      '      ar_receivable_applications'  || l_all_clause || ' app   '  || CRLF ;


--Use xla_transaction_entity_n1
        l_where_clause :=
      ' WHERE app.application_type = ''CM''
        AND   app.event_id IS NULL
        AND   app.status IN (''APP'',''ACTIVITY'') --HYU
        AND   ev1.entity_id = evn.entity_id
        AND   evn.application_id = 222
        AND   ev1.application_id = 222
        AND   app.customer_trx_id = NVL(evn.source_id_int_1,-99)
        AND   evn.ledger_id  = app.set_of_books_id
        AND   evn.entity_code = ''TRANSACTIONS''
        AND   app.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND   nvl(app.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))
               = nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND   decode(app.posting_control_id,
                     -3, ev1.event_status_code,
                     ''P'') = ev1.event_status_code ' || CRLF;


        l_group_by_clause := '';

        l_order_by_clause := '';
       END IF;
      END IF; --create or update mode

   END IF; --create and denormalize events Misc Cash Receipts

  -------------------------------------------------------------------
  -- Build statement for Bills Receivable event creation
  -------------------------------------------------------------------
   IF p_xla_ev_rec.xla_doc_table = 'TRH' THEN

      IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL
         AND p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN

        /*-----------------------------------------------------+
         | The document id for BR is a transaction history id  |
         | instead of customer_trx_id. The customer_trx_id is  |
         | only used for storing the header info BR, all the   |
         | accounting is driven by TRH. So the ARP_ACCT_MAIN   |
         | package which call ARP_XLA_EVENTS to create events  |
         | along with the accounting entries required a TRH_ID |
         | instead of a customer_trx_id.                       |
         | This change will not impact the upgrade mode neither|
         | the batch mode for they do not use document id      |
         | replace trh.customer_trx_id by                      |
         | trh.transaction_history_id.                         |
         +-----------------------------------------------------*/

        IF p_xla_ev_rec.xla_from_doc_id = p_xla_ev_rec.xla_to_doc_id THEN
          l_where_parm_clause :=
           '   AND  trh.transaction_history_id = :b_xla_from_doc_id
		    AND trh.transaction_history_id  = :b_xla_to_doc_id   ' || CRLF;
        ELSE
          l_where_parm_clause :=
         '   AND  trh.transaction_history_id >= :b_xla_from_doc_id
           AND trh.transaction_history_id  <= :b_xla_to_doc_id   ' || CRLF;
        END IF;
      END IF;


      IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND trh.request_id = :b_xla_req_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
         l_where_parm_clause := l_where_parm_clause
             || ' AND trh.transaction_history_id = :b_xla_dist_id ' || CRLF;
      END IF;

      IF p_xla_ev_rec.xla_call IN ('C', 'B') AND p_call_point = 1 THEN

      log('Start Building Bills Receivable statement ' );

      l_select_clause :=
      ' select
        tty.post_to_gl                                POSTTOGL       ,
        ''BILL''                                      TRX_TYPE       ,
        decode(trh.status,
               ''INCOMPLETE'', ''I'',
               ''PENDING_ACCEPTANCE'',''I'',
               ''C'')                                 COMP_FLAG      ,
        trh.customer_trx_id                           TRX_ID         ,
        ct.trx_number                                 TRX_NUMBER     ,
        ct.org_id                                     ORG_ID,
        decode(trh.event,
               ''INCOMPLETE''  , ''BILL_CREATE'',
               ''ACCEPTED''    , ''BILL_CREATE'',
               ''COMPLETED''   , decode(trh.status,
                                        ''PENDING_ACCEPTANCE'', ''BILL_CREATE'',
                                        ''PENDING_REMITTANCE'', ''BILL_CREATE'',
                                        ''NO_EVENT''),
               ''CANCELLED''   , ''BILL_REVERSE'',
               decode(trh1.first_posted_record_flag,
                      '''', ''BILL_CREATE'',
                      decode(nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             nvl(trh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                 decode(trh.posting_control_id,
                                        trh1.posting_control_id, ''BILL_CREATE'',
                                        ''BILL_UPDATE''),
                             ''BILL_UPDATE'')))       OVERRIDE_EVENT,
        trh.posting_control_id                        PSTID          ,
        decode(tty.post_to_gl,
               ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
               nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))) GL_DATE,
        trh.event_id                                  EXIST_EVENT   ,
        ''''                                          EVENT_ID       ,
        to_date(''01-01-1900'',''DD-MM-YYYY'')        ACCOUNTING_DATE,
        ''''                                          EVENT_TYPE     ,
        ''X''                                         EVENT_STATUS   ,
        ct.trx_date                           TRANSACTION_DATE,
        ct.legal_entity_id                            LEGAL_ENTITY_ID ';

        l_from_clause :=
      ' FROM ar_transaction_history'   || l_all_clause || ' trh, '  || CRLF ||
      '      ar_transaction_history'   || l_all_clause || ' trh1, ' || CRLF ||
      '      ra_customer_trx'          || l_all_clause || ' ct,  '  || CRLF ||
      '      ra_cust_trx_types'        || l_all_clause || ' tty  '  || CRLF;

       l_where_clause := ' where ct.customer_trx_id = trh.customer_trx_id '                || CRLF ||
                         ' and   ct.cust_trx_type_id = tty.cust_trx_type_id '              || CRLF ||
                         ' and   ct.org_id = tty.org_id '                                  || CRLF ||
                         ' and   ct.customer_trx_id = trh1.customer_trx_id (+) '           || CRLF ||
                         ' and   ''Y'' = trh1.first_posted_record_flag (+) '               || CRLF ||
                         ' and '                                                           || CRLF ||
                         ' decode(trh.event, '                                             || CRLF ||
                         '        ''INCOMPLETE'', '                                        || CRLF ||
                         '           decode(trh1.first_posted_record_flag,'''',''Y'', '    || CRLF ||
                         '                 ''Y'', ''Y'', ''N''), '                         || CRLF ||
                         '        ''COMPLETED'', '                                         || CRLF ||
                         '           decode(trh.status, '                                  || CRLF ||
                         '                  ''PENDING_ACCEPTANCE'', '                      || CRLF ||
                         '                     decode(trh1.first_posted_record_flag, '     || CRLF ||
                         '                            '''', ''Y'', ''Y'', ''Y'', '         || CRLF ||
                         '                            ''N''), '                            || CRLF ||
                         '                   trh.postable_flag), '                         || CRLF ||
                         '         trh.postable_flag) = ''Y'' '                            || CRLF ||
                         ' AND decode(trh.event_id, '                                      || CRLF ||
                         '             '''', ''Y'', '                                      || CRLF ||
                         '             decode(:b_xla_mode, ''O'',''Y'', '                  || CRLF ||
                         '                    ''N'')) = ''Y'' '                            || CRLF ;

    ---
    ---Note the above decode contains events whose values are equated to postable flag
    ---These will always be non accounting events and have been coded to ensure completeness
    ---and catch potential data issues if any.
    ---
       l_group_by_clause :=
    ' GROUP BY trh.customer_trx_id,
               ct.trx_number,
               ct.org_id,
               decode(trh.status,
                      ''INCOMPLETE'', ''I'',
                      ''PENDING_ACCEPTANCE'',''I'',
                      ''C''),
               tty.post_to_gl,
               trh.posting_control_id,
               decode(trh.event,
               ''INCOMPLETE''  , ''BILL_CREATE'',
               ''ACCEPTED''    , ''BILL_CREATE'',
               ''COMPLETED''   , decode(trh.status,
                                        ''PENDING_ACCEPTANCE'', ''BILL_CREATE'',
                                        ''PENDING_REMITTANCE'', ''BILL_CREATE'',
                                        ''NO_EVENT''),
               ''CANCELLED''   , ''BILL_REVERSE'',
               decode(trh1.first_posted_record_flag,
                      '''', ''BILL_CREATE'',
                      decode(nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             nvl(trh1.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                 decode(trh.posting_control_id,
                                        trh1.posting_control_id, ''BILL_CREATE'',
                                        ''BILL_UPDATE''),
                             ''BILL_UPDATE''))),
                decode(tty.post_to_gl,
                       ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                       nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))),
                trh.event_id ,
                ct.trx_date,
                ct.legal_entity_id ' || CRLF;


      l_order_by_clause :=
      'ORDER BY TRX_ID    ,
                GL_DATE   ,
                PSTID   desc ';

        log('End Building Bills Receivable statement ' );
    ---------------------------------------------------------------------
    -- Build the clause for Transaction History  denormalize events stmt
    ---------------------------------------------------------------------
      ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN

        log('Building Denormalize Bills Receivable statement ' );

        l_select_clause :=
      ' SELECT trh.rowid,
               ev1.event_id ';

--use  xla_transaction_entity_n1

      l_from_clause :=
      ' FROM xla_events'               ||                 ' ev1,  '  || CRLF ||
      '      xla_transaction_entities_upg' ||                 ' evn,  '  || CRLF ||
      '      ar_transaction_history'   || l_all_clause || ' trh,  '  || CRLF ||
      '      ra_customer_trx'          || l_all_clause || ' ct,   '  || CRLF ||
      '      ra_cust_trx_types'        || l_all_clause || ' tty   '  || CRLF;

        l_where_clause :=
        ' WHERE ct.customer_trx_id = trh.customer_trx_id '     || CRLF ||
        ' AND   trh.event_id IS NULL '                         || CRLF ||
        ' and   ct.cust_trx_type_id = tty.cust_trx_type_id '   || CRLF ||
        ' and   ct.org_id = tty.org_id '                       || CRLF ||
        ' and decode(trh.event,
                     ''CANCELLED''   , ''BILL_REVERSE'',
                     ev1.event_type_code) = ev1.event_type_code
        AND   ev1.entity_id  = evn.entity_id
        AND   ev1.application_id = 222
        AND   evn.entity_code = ''BILLS_RECEIVABLE''
        AND   evn.application_id = 222
        AND   trh.posting_control_id = nvl(ev1.reference_num_1,-3)
        AND   trh.customer_trx_id = NVL(evn.source_id_int_1,-99)
        AND   evn.ledger_id = ct.set_of_books_id
        AND   decode(tty.post_to_gl,
                     ''N'', to_date(''01-01-1900'',''DD-MM-YYYY''),
                      decode(trh.event,
                             ''INCOMPLETE'', nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY'')),
                             ''COMPLETED'',
                                 decode(trh.status,
                                        ''PENDING_ACCEPTANCE'',
                                            nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY'')),
                                        nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY''))),
                             nvl(trh.gl_date,to_date(''01-01-1900'',''DD-MM-YYYY'')))) =
                                        nvl(ev1.event_date, to_date(''01-01-1900'',''DD-MM-YYYY''))
        AND   decode(trh.event,
                     ''INCOMPLETE'', ''Y'',
                     ''COMPLETED'', decode(trh.status,
                                           ''PENDING_ACCEPTANCE'',''Y'',
                                           trh.postable_flag),
                     trh.postable_flag)  = ''Y''
        AND   decode(trh.posting_control_id,
                     -3, ev1.event_status_code,
                     ''P'') = ev1.event_status_code ' || CRLF;


        l_group_by_clause := '';

        l_order_by_clause := '';

        log('End Building Denormalize Bills Receivable statement ' );
      END IF; --create or update mode

   END IF; --transaction

   p_stmt := l_select_clause     ||
             l_from_clause       ||
             l_where_clause      ||
             l_where_parm_clause ||
             l_group_by_clause   ||
             l_order_by_clause   ;

   log('p_stmt ' || SUBSTRB(p_stmt,1,3980));

   log('ARP_XLA_EVENTS.Build_Stmt ()-');
EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.Build_Stmt');
     RAISE;

END Build_Stmt;

/*========================================================================
 | PUBLIC PROCEDURE Define Array
 |
 | DESCRIPTION
 |      Define positional place holders in the select list
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Get_Select_Cursor
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS p_select_c   IN  Cursor handle
 |            p_xla_ev_rec IN  Events parameter record
 |            p_ev_rec     IN  Events record
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE define_arrays( p_select_c   IN INTEGER,
                         p_xla_ev_rec IN xla_events_type,
                         p_ev_rec     IN ev_rec_type,
                         p_call_point IN NUMBER) IS
BEGIN
    log( 'ARP_XLA_EVENTS.define_arrays()+' );

    IF p_xla_ev_rec.xla_call IN ('C','B') AND p_call_point = 1 THEN

       dbms_sql.define_array(p_select_c, 1 , p_ev_rec.posttogl
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 2 , p_ev_rec.trx_type
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 3 , p_ev_rec.trx_status
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 4 , p_ev_rec.trx_id
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 5 , p_ev_rec.trx_number
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 6 , p_ev_rec.org_id
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 7 , p_ev_rec.override_event
                                           , MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 8 , p_ev_rec.pstid
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 9 , p_ev_rec.dist_gl_date
                                          ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 10, p_ev_rec.ev_match_event_id
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 11 , p_ev_rec.dist_event_id
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 12, p_ev_rec.ev_match_gl_date
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 13, p_ev_rec.ev_match_type
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 14, p_ev_rec.ev_match_status
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
--{HYU transaction_date,legal_entity_id
       dbms_sql.define_array(p_select_c, 15, p_ev_rec.transaction_date
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 16, p_ev_rec.legal_entity_id
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
--}

    ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN
       dbms_sql.define_array(p_select_c, 1 , p_ev_rec.dist_row_id
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
       dbms_sql.define_array(p_select_c, 2 , p_ev_rec.dist_event_id
                                           ,  MAX_ARRAY_SIZE, STARTING_INDEX );
    END IF;

    log( 'ARP_XLA_EVENTS.define_arrays()-' );

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.define_arrays');
     RAISE;

END define_arrays;

/*========================================================================
 | PUBLIC PROCEDURE Get_Column_Values
 |
 | DESCRIPTION
 |      Gets the values in select list and stores them in the target
 |      event record table variable
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Get_Column_Values
 |      Upd_Dist
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS p_select_c   IN  Cursor handle
 |            p_xla_ev_rec IN  Events parameter record
 |            p_ev_rec     OUT Events record
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE get_column_values(p_select_c   IN  INTEGER,
                            p_xla_ev_rec IN xla_events_type,
                            p_call_point IN NUMBER,
                            p_ev_rec     OUT NOCOPY ev_rec_type) IS
BEGIN
    log('ARP_XLA_EVENTS.get_column_values (+)');

    IF p_xla_ev_rec.xla_call IN ('C','B') AND p_call_point = 1 THEN
       dbms_sql.column_value(p_select_c, 1 , p_ev_rec.posttogl);
       dbms_sql.column_value(p_select_c, 2 , p_ev_rec.trx_type);
       dbms_sql.column_value(p_select_c, 3 , p_ev_rec.trx_status);
       dbms_sql.column_value(p_select_c, 4 , p_ev_rec.trx_id);
       dbms_sql.column_value(p_select_c, 5 , p_ev_rec.trx_number);
       dbms_sql.column_value(p_select_c, 6 , p_ev_rec.org_id);
       dbms_sql.column_value(p_select_c, 7 , p_ev_rec.override_event);
       dbms_sql.column_value(p_select_c, 8 , p_ev_rec.pstid);
       dbms_sql.column_value(p_select_c, 9 , p_ev_rec.dist_gl_date);
       dbms_sql.column_value(p_select_c, 10 , p_ev_rec.dist_event_id);
       dbms_sql.column_value(p_select_c, 11, p_ev_rec.ev_match_event_id);
       dbms_sql.column_value(p_select_c, 12, p_ev_rec.ev_match_gl_date);
       dbms_sql.column_value(p_select_c, 13, p_ev_rec.ev_match_type);
       dbms_sql.column_value(p_select_c, 14, p_ev_rec.ev_match_status);
--{HYU transaction_date,legal_entity_id
       dbms_sql.column_value(p_select_c, 15, p_ev_rec.transaction_date);
       dbms_sql.column_value(p_select_c, 16, p_ev_rec.legal_entity_id);
--}
    ELSIF p_xla_ev_rec.xla_call IN ('D','B') AND p_call_point = 2 THEN
       dbms_sql.column_value(p_select_c, 1 , p_ev_rec.dist_row_id);
       dbms_sql.column_value(p_select_c, 2 , p_ev_rec.dist_event_id);
    END IF;

    log('ARP_XLA_EVENTS.get_column_values (-)');

END get_column_values;

/*========================================================================
 | PUBLIC PROCEDURE Get_Select_Cursor
 |
 | DESCRIPTION
 |      Builds Select statement, opens cursor, parses it, defines place
 |      holders for select list, binds variables and returns a cursor
 |      handle.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Upd_Dist
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS p_xla_ev_rec IN Events parameter record
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
FUNCTION Get_Select_Cursor(p_xla_ev_rec IN xla_events_type,
                           p_call_point IN NUMBER) RETURN INTEGER IS

l_select_c INTEGER;
l_stmt     VARCHAR2(22000);
l_ev_rec   ev_rec_type;

BEGIN

   log('ARP_XLA_EVENTS.Get_Select_Cursor ()+');

   Build_Stmt(p_xla_ev_rec => p_xla_ev_rec,
              p_stmt       => l_stmt,
              p_call_point => p_call_point);

   log('Opening cursor, to give cursor handle');

   l_select_c := dbms_sql.open_cursor;

   log('Parsing select stmt');

   dbms_sql.parse(l_select_c, l_stmt, dbms_sql.v7);

   ------------------------------------------------------------
   -- Define Column Arrays
   ------------------------------------------------------------

   define_arrays(p_select_c   => l_select_c,
                 p_xla_ev_rec => p_xla_ev_rec,
                 p_ev_rec     => l_ev_rec,
                 p_call_point => p_call_point);

   ------------------------------------------------------------
   -- Bind Variables
   ------------------------------------------------------------
   IF p_call_point = 1 THEN
      log('p_xla_ev_rec.xla_mode   ' || p_xla_ev_rec.xla_mode);
      dbms_sql.bind_variable(l_select_c, ':b_xla_mode', p_xla_ev_rec.xla_mode);
   END IF;

   IF p_xla_ev_rec.xla_from_doc_id IS NOT NULL THEN
     log('p_xla_ev_rec.xla_from_doc_id ' || p_xla_ev_rec.xla_from_doc_id);
     dbms_sql.bind_variable(l_select_c, ':b_xla_from_doc_id', p_xla_ev_rec.xla_from_doc_id);
   END IF;

   IF p_xla_ev_rec.xla_to_doc_id IS NOT NULL THEN
     log('p_xla_ev_rec.xla_to_doc_id   ' || p_xla_ev_rec.xla_to_doc_id);
     dbms_sql.bind_variable(l_select_c, ':b_xla_to_doc_id', p_xla_ev_rec.xla_to_doc_id);
   END IF;

   IF p_xla_ev_rec.xla_req_id IS NOT NULL THEN
     log('p_xla_ev_rec.xla_req_id   ' || p_xla_ev_rec.xla_req_id);
     dbms_sql.bind_variable(l_select_c, ':b_xla_req_id', p_xla_ev_rec.xla_req_id);
   END IF;

   IF p_xla_ev_rec.xla_dist_id IS NOT NULL THEN
     log('p_xla_ev_rec.xla_dist_id   ' || p_xla_ev_rec.xla_dist_id);
     dbms_sql.bind_variable(l_select_c, ':b_xla_dist_id', p_xla_ev_rec.xla_dist_id);
   END IF;

   log('ARP_XLA_EVENTS.Get_Select_Cursor (-)');

   return(l_select_c);

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.Get_Select_Cursor:'||SQLERRM);
     RAISE;

END Get_Select_Cursor;

/*========================================================================
 | PUBLIC PROCEDURE Create_All_Events
 |
 | DESCRIPTION
 |      Creates, updates and deletes events for the transactions
 |      INV, DM, CM, CB, GUAR, DEP
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Execute
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_xla_ev_rec IN xla_events_type
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-SEP-2003           Herve Yu
 |          Use the set_of_books_id for now as the ledger_id bug#3135769
 |          we might need to come back on this point later after the uptake
 |          of ledger architecture project.
 *=======================================================================*/
PROCEDURE Create_All_Events(p_xla_ev_rec IN xla_events_type) IS

/*---------------------------------------------------------------------+
 | Main cursor which gets transaction data, and event data for decision|
 | making on which events require to be created, updated or deleted.   |
 +---------------------------------------------------------------------*/
TYPE get_tran_data_type IS REF CURSOR;

get_tran_data get_tran_data_type;

l_select_c BINARY_INTEGER;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
ev_rec        ev_rec_type    ;
empty_ev_rec  ev_rec_type    ;

bld_ev_rec    bld_ev_type    ;
empty_bld_ev_rec bld_ev_type    ;

--cache_ev_rec  bld_ev_type    ;

bld_ev_ent        xla_events_pub_pkg.t_array_entity_event_info_s;
empty_bld_ev_ent  xla_events_pub_pkg.t_array_entity_event_info_s;

prev_distid VARCHAR2(50) := '';

l_cached               BOOLEAN;
l_cached2              BOOLEAN;
ev_match_flg           BOOLEAN;
l_last_fetch           BOOLEAN;
l_match_event_in_cache BOOLEAN;

event_trx_gl_date_mismatch EXCEPTION;
abnormal_cond              EXCEPTION;

i BINARY_INTEGER := 0;
j BINARY_INTEGER := 0;
k BINARY_INTEGER := 0;
l BINARY_INTEGER := 0;
m BINARY_INTEGER := 0;
n BINARY_INTEGER := 0;
p BINARY_INTEGER := 0;
q BINARY_INTEGER := 0;
r BINARY_INTEGER := 0;

l_change_matrix VARCHAR2(30);

temp_event_id BINARY_INTEGER := 0;

prev_trx_id ra_customer_trx.customer_trx_id%TYPE;

l_type             VARCHAR2(30);
l_build_ctr        BINARY_INTEGER;
l_ev_type          VARCHAR2(20);
l_ignore           INTEGER;
l_rows_fetched     VARCHAR2(10);
l_low              INTEGER:=0;
l_high             INTEGER:=0;
lnb                NUMBER;
--xla event api declarations
l_event_source_info     xla_events_pub_pkg.t_event_source_info;
l_reference_info        xla_events_pub_pkg.t_event_reference_info;
l_security_context      xla_events_pub_pkg.t_security;
l_entity_event_info_tbl xla_events_pub_pkg.t_array_entity_event_info_s;
keep_flag          BOOLEAN;
l_revrun           VARCHAR2(5);
l_entity_code      VARCHAR2(20);
z                  NUMBER :=0;
cnt                INTEGER;
trxn_number	   VARCHAR2(240);
CURSOR for_batch IS
 SELECT 'X'
   FROM xla_events_int_gt
  WHERE entity_id IS NULL;
l_test             VARCHAR2(1);


BEGIN
   log('ARP_XLA_EVENTS.Create_All_Events ()+');

   --Bug#3135769
   --{
   IF arp_standard.sysparm.set_of_books_id IS NULL THEN
     arp_standard.init_standard;
   END IF;
   --}

   IF p_xla_ev_rec.xla_call IN ('C','B') THEN
      null;
   ELSE
      goto endlabel;
   END IF;

  -----------------------------------------------------------
  --Get the transaction entity
  -----------------------------------------------------------
   l_entity_code := entity_code( p_xla_ev_rec.xla_doc_table);

  ------------------------------------------------------------
  -- Build select statement and get cursor handle
  ------------------------------------------------------------
   l_select_c := Get_Select_Cursor(p_xla_ev_rec => p_xla_ev_rec,
                                   p_call_point => 1);

   l_ignore   := dbms_sql.execute( l_select_c );

   log( 'Fetching select stmt');

   LOOP  -- Main Cursor Loop

      log( 'reinitialize the build events cache');
      bld_ev_rec.bld_dml_flag      := empty_bld_ev_rec.bld_dml_flag;
      bld_ev_rec.bld_temp_event_id := empty_bld_ev_rec.bld_temp_event_id;

      --initialize the collection of records containing event information
      bld_ev_ent    := empty_bld_ev_ent;

      log( 'reinitialize the events cache');

      ev_rec.posttogl            := empty_ev_rec.posttogl;
      ev_rec.trx_type            := empty_ev_rec.trx_type;
      ev_rec.trx_status          := empty_ev_rec.trx_status;
      ev_rec.trx_id              := empty_ev_rec.trx_id;
      ev_rec.pstid               := empty_ev_rec.pstid;
      ev_rec.dist_gl_date        := empty_ev_rec.dist_gl_date;
      ev_rec.override_event      := empty_ev_rec.override_event;
      ev_rec.dist_event_id       := empty_ev_rec.dist_event_id;
      ev_rec.ev_match_event_id   := empty_ev_rec.ev_match_event_id;
      ev_rec.ev_match_gl_date    := empty_ev_rec.ev_match_gl_date;
      ev_rec.ev_match_type       := empty_ev_rec.ev_match_type;
      ev_rec.ev_match_status     := empty_ev_rec.ev_match_status;
--{HYU transaction_date,legal_entity_id
      ev_rec.transaction_date    := empty_ev_rec.transaction_date;
      ev_rec.legal_entity_id     := empty_ev_rec.legal_entity_id;
--}
      j := 0;

      l_rows_fetched := dbms_sql.fetch_rows(l_select_c);

      log('Rows Fetched are ' || l_rows_fetched);

      l_low := l_high + 1;
      l_high:= l_high + l_rows_fetched;

      IF l_rows_fetched > 0 THEN

         log('Fetched a row ');
         log('l_low  ' || l_low);
         log('l_high ' || l_high);

         get_column_values(p_select_c   => l_select_c,
                           p_xla_ev_rec => p_xla_ev_rec,
                           p_ev_rec     => ev_rec,
                           p_call_point => 1);

       -- no more rows to fetch
         IF l_rows_fetched < MAX_ARRAY_SIZE THEN
            log('Done fetching 1');

            IF( dbms_sql.is_open( l_select_c) ) THEN
                dbms_sql.close_cursor( l_select_c );
            END IF;

         END IF; --no more rows to fetch

       ELSE --if rows fetched = 0
          log('Done fetching 2');

          IF( dbms_sql.is_open( l_select_c ) ) THEN
                dbms_sql.close_cursor( l_select_c );
          END IF;

          EXIT;

      END IF; --rows fetched greater than 0

    /*--------------------------------------------------------+
     |Set the event id to the existing event id which is not  |
     |accounted, since for the current distribution gl date   |
     |another event could not be found, however there exists  |
     |another event which is not accounted which has a        |
     |different gl date, set values for decision making.      |
     +--------------------------------------------------------*/
      log('Bef Loop ');
      log('Number of rows selected : '|| ev_rec.trx_id.COUNT);
      FOR i IN ev_rec.trx_id.FIRST .. ev_rec.trx_id.LAST LOOP

      log('Processing Transactions Events using Change Matrix');

     --Initialize variables when new transaction is being processed
       IF NVL(prev_trx_id,-999) <> ev_rec.trx_id(i) THEN

          log('Initialization Tasks     ');

       END IF; --reinitialize trx cache

     /*----------------------------------------------------------+
      |Processing required in OLTP mode only                     |
      +----------------------------------------------------------*/
       IF p_xla_ev_rec.xla_mode = 'O' THEN
-- In batch mode, ar should also verify the existance of events
--       IF p_xla_ev_rec.xla_mode IN ('O','B') THEN

       /*-------------------------------------------------------------------------+
        |Get the data associated with the existing event to enable decision making|
        |Note : There must be an existing event - otherwise a no data found excep |
        |       will be raised                                                    |
        +-------------------------------------------------------------------------*/
          IF ev_rec.dist_event_id(i) IS NOT NULL THEN

/*
get_existing_event
  (p_event_id          => ev_rec.dist_event_id(i),
   x_event_id          => ev_rec.ev_match_event_id(i),
   x_event_date        => ev_rec.ev_match_gl_date(i),
   x_event_status_code => ev_rec.ev_match_status(i),
   x_event_type_code   => ev_rec.ev_match_type(i));
*/

             select ae.event_id         ,
                    ae.event_date       ,
                    ae.event_status_code,
                    ae.event_type_code
             into   ev_rec.ev_match_event_id(i) ,
                    ev_rec.ev_match_gl_date(i)  ,
                    ev_rec.ev_match_status(i)   ,
                    ev_rec.ev_match_type(i)
             from xla_events ae
             where ev_rec.dist_event_id(i) = ae.event_id
	     and   ae.application_id = 222;


       /*-------------------------------------------------------------------------+
        |Find an existing event to which the current distribution can latch on to |
        |and use in decision making - best match. As of a given gl date, there    |
        |can exists only one unposted event type matching the dist event type for |
        |the dist gl date for a document id (even if document ids overlapp, since |
        |event types are unique for existing events and cannot overlapp across    |
        |different document entities.                                             |
        +-------------------------------------------------------------------------*/
           ELSIF ev_rec.dist_event_id(i) IS NULL THEN
--
 --             BEGIN
--log('ev_rec.trx_id(i):'||ev_rec.trx_id(i));
--log('ev_rec.dist_gl_date(i):'||ev_rec.dist_gl_date(i));
--log('ev_rec.override_event(i):'||ev_rec.override_event(i));
/*
get_best_existing_event
(p_trx_id          => ev_rec.trx_id(i),
 p_gl_date         => ev_rec.dist_gl_date(i),
 p_override_event  => ev_rec.override_event(i),
 x_match_event_id  => ev_rec.ev_match_event_id(i),
 x_match_gl_date   => ev_rec.ev_match_gl_date(i),
 x_match_status    => ev_rec.ev_match_status(i),
 x_match_type      => ev_rec.ev_match_type(i));
*/

--{BUG#5347627
              BEGIN
               IF ev_rec.override_event(i) IN
               ('INV_CREATE','DM_CREATE','DEP_CREATE','CB_CREATE','CM_CREATE','GUAR_CREATE',
                'INV_UPDATE','DM_UPDATE','DEP_UPDATE','CB_UPDATE','CM_UPDATE','GUAR_UPDATE')
               THEN
		  select ae2.event_id         ,
			 ae2.event_date       ,
			 ae2.event_status_code,
			 ae2.event_type_code
		  into   ev_rec.ev_match_event_id(i) ,
			 ev_rec.ev_match_gl_date(i)  ,
			 ev_rec.ev_match_status(i)   ,
			 ev_rec.ev_match_type(i)
		  from xla_events ae2
		  where ae2.application_id = 222
		  and ae2.event_id IN
                  ( select MAX( ae.event_id )
                    from xla_events                   ae,
                         xla_transaction_entities_upg xt,
                         ra_customer_trx_all          trx
                    where trx.customer_trx_id         = ev_rec.trx_id(i)
                      and NVL(xt.source_id_int_1,-99) = trx.customer_trx_id
                      and xt.entity_code              = 'TRANSACTIONS'
                      and xt.ledger_id                = trx.set_of_books_id
                      and xt.entity_id                = ae.entity_id
                      and xt.application_id           = 222
                      and ae.application_id           = 222
                      and nvl(ae.event_date,
                            to_date('01-01-1900','DD-MM-YYYY')) = ev_rec.dist_gl_date(i)
                      and ae.event_status_code <> 'P'
		      and ae.event_type_code  IN
		         ('INV_CREATE','DM_CREATE','DEP_CREATE','CB_CREATE','CM_CREATE','GUAR_CREATE',
                          'INV_UPDATE','DM_UPDATE','DEP_UPDATE','CB_UPDATE','CM_UPDATE','GUAR_UPDATE')
		   )
		  FOR UPDATE OF ae2.event_id NOWAIT;

               ELSIF ev_rec.override_event(i) IN
               ('BILL_CREATE','BILL_UPDATE','BILL_REVERSE')
               THEN
		  select ae2.event_id         ,
			 ae2.event_date       ,
			 ae2.event_status_code,
			 ae2.event_type_code
		  into   ev_rec.ev_match_event_id(i) ,
			 ev_rec.ev_match_gl_date(i)  ,
			 ev_rec.ev_match_status(i)   ,
			 ev_rec.ev_match_type(i)
		  from xla_events ae2
		  where ae2.application_id = 222
		  and ae2.event_id IN
                  ( select MAX( ae.event_id )
                    from xla_events                   ae,
                         xla_transaction_entities_upg xt,
                         ra_customer_trx_all          trx
                    where trx.customer_trx_id         = ev_rec.trx_id(i)
                      and NVL(xt.source_id_int_1,-99) = trx.customer_trx_id
                      and xt.entity_code              = 'BILLS_RECEIVABLE'
                      and xt.ledger_id                = trx.set_of_books_id
                      and xt.entity_id                = ae.entity_id
                      and xt.application_id           = 222
                      and ae.application_id           = 222
                      and nvl(ae.event_date,
                            to_date('01-01-1900','DD-MM-YYYY')) = ev_rec.dist_gl_date(i)
                      and ae.event_status_code <> 'P'
                      and ev_rec.override_event(i) = ae.event_type_code )
		  FOR UPDATE OF ae2.event_id NOWAIT;


               ELSIF ev_rec.override_event(i) IN
                   ('RECP_CREATE','RECP_RATE_ADJUST','RECP_UPDATE','RECP_REVERSE',
                    'MISC_RECP_CREATE','MISC_RECP_RATE_ADJUST','MISC_RECP_UPDATE','MISC_RECP_REVERSE')
               THEN
		  select ae2.event_id         ,
			 ae2.event_date       ,
			 ae2.event_status_code,
			 ae2.event_type_code
		  into   ev_rec.ev_match_event_id(i) ,
			 ev_rec.ev_match_gl_date(i)  ,
			 ev_rec.ev_match_status(i)   ,
			 ev_rec.ev_match_type(i)
		  from xla_events ae2
		  where ae2.application_id = 222
		  and ae2.event_id IN
                  ( select MAX( ae.event_id )
                    from xla_events                   ae,
                         xla_transaction_entities_upg xt,
                         ar_Cash_receipts_all         cr
                    where cr.cash_receipt_id          = ev_rec.trx_id(i)
                      and NVL(xt.source_id_int_1,-99) = cr.cash_receipt_id
                      and xt.entity_code              = 'RECEIPTS'
                      and xt.ledger_id                = cr.set_of_books_id
                      and xt.entity_id                = ae.entity_id
                      and xt.application_id           = 222
                      and ae.application_id           = 222
                      and nvl(ae.event_date,
                            to_date('01-01-1900','DD-MM-YYYY')) = ev_rec.dist_gl_date(i)
                      and ae.event_status_code <> 'P'
                      and DECODE(ev_rec.override_event(i),
		                  'RECP_CREATE',      ae.event_type_code,
				  'MISC_RECP_CREATE', ae.event_type_code,
                                 ev_rec.override_event(i) ) = ae.event_type_code )
		  FOR UPDATE OF ae2.event_id NOWAIT;

               ELSIF ev_rec.override_event(i) IN ('ADJ_CREATE') THEN
		  select ae2.event_id         ,
			 ae2.event_date       ,
			 ae2.event_status_code,
			 ae2.event_type_code
		  into   ev_rec.ev_match_event_id(i) ,
			 ev_rec.ev_match_gl_date(i)  ,
			 ev_rec.ev_match_status(i)   ,
			 ev_rec.ev_match_type(i)
		  from xla_events ae2
		  where ae2.application_id = 222
		  and ae2.event_id IN
                  ( select MAX( ae.event_id )
                    from xla_events                   ae,
                         xla_transaction_entities_upg xt,
                         ar_adjustments_all           adj
                    where adj.adjustment_id           = ev_rec.trx_id(i)
                      and NVL(xt.source_id_int_1,-99) = adj.adjustment_id
                      and xt.entity_code              = 'ADJUSTMENTS'
                      and xt.ledger_id                = adj.set_of_books_id
                      and xt.entity_id                = ae.entity_id
                      and xt.application_id           = 222
                      and ae.application_id           = 222
                      and nvl(ae.event_date,
                            to_date('01-01-1900','DD-MM-YYYY')) = ev_rec.dist_gl_date(i)
                      and ae.event_status_code <> 'P'
                      and ev_rec.override_event(i) = ae.event_type_code )
		  FOR UPDATE OF ae2.event_id NOWAIT;
               END IF;

                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       --------------------------------------------------------------+
                       --|Since a match could not be found - ascertain whether there    |
                       --|is an existing event (Typically for Modify document event type|
                       --|Add condition on trx_type to avoid the undesirable latching of|
                       --|a RECP event on a previous one. For example :                 |
                       --| * Create of a Receipt, RECP_CREATE.                          |
                       --| * Reverse of the Receipt, RECP_REVERSE but if we do not add  |
                       --|   the condition to avoid the association between the reversal|
                       --|   and the creation of the receipt, the RECP_REVERSE event is |
                       --|   not created.                                               |
                       --+--------------------------------------------------------------
-- Processing below is not required since a Create or Update event will get created
--   if ther is no matching event - the SQL for each entity would have taken care of
--   building the correct event type. We no longer need to verify for existing events
--   since we look ate the first posted record flag.
                        NULL;
                    WHEN OTHERS THEN
		    /*ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired
		      The error indicates that there exist a matching event to latch on to,however
		      it is currently locked by some other process.The action would be to let the
		      process continue and create a new event of type UPDATE.

		      This code flow gets triggered only in cases where the concerned document already
		      has an event of type CREATE,will explictly override the event_type_code with
		      that of event type UPDATE to ensure that there exist only one event of type CREATE
		      for given document*/
		      IF SQLCODE = -54 THEN
			ev_rec.override_event(i) :=
			            CASE ev_rec.override_event(i)
					 WHEN 'INV_CREATE'       THEN 'INV_UPDATE'
					 WHEN 'DM_CREATE'        THEN 'DM_UPDATE'
					 WHEN 'DEP_CREATE'       THEN 'DEP_UPDATE'
					 WHEN 'CB_CREATE'        THEN 'CB_UPDATE'
					 WHEN 'CM_CREATE'        THEN 'CM_UPDATE'
					 WHEN 'GUAR_CREATE'      THEN 'GUAR_UPDATE'
					 WHEN 'RECP_CREATE'      THEN 'RECP_UPDATE'
					 WHEN 'MISC_RECP_CREATE' THEN 'MISC_RECP_UPDATE'
                                    END;
			IF PG_DEBUG = 'Y' THEN
			  arp_standard.debug(' ORA-00054 occurred,ev_rec.override_event set to '||
			                     ev_rec.override_event(i) );
			END IF;

		      ELSE
			RAISE;
		      END IF;
                 END; --distribution is not marked with an event

           END IF; --distribution is marked with an event if construct

         END IF; --processing for event creation in Oltp mode

     --Current distribution does not have an event
       IF ev_rec.dist_event_id(i) IS NULL THEN
          ev_match_flg := FALSE;
          log(' ev_match_flg ' || 'FALSE');
       ELSE
          log(' ev_match_flg ' || 'TRUE');
          ev_match_flg := TRUE;
       END IF;

       dump_ev_rec(p_ev_rec => ev_rec,  p_i => i);

     /*------------------------------------------------------------------+
      |Since the main cursor gets one row for creation of each new event |
      |hence there is no need to have an events cache. The only time we  |
      |need to figure out what the previous event insert did is to make  |
      |a decision as regards the construction of the event type as Create|
      |or modify.                                                        |
      +------------------------------------------------------------------*/

       l_change_matrix := Change_Matrix(
                       ev_rec.trx_status(i)             ,
                       ev_rec.dist_gl_date(i)           ,
                       ev_rec.ev_match_gl_date(i)       ,
                       ev_rec.ev_match_status(i)        ,
                       ev_rec.posttogl(i));

       log('l_change_matrix ' || l_change_matrix);
       l_type := 'NONE';

     /*------------------------------------------------------------------+
      |This routine cannot create events for posted transactions as XLA  |
      |apis do not allow it. Hence in oltp mode we set the event match   |
      |flag to true. This results in the distribution which is posted    |
      |to get skipped which is okay because :                            |
      |1) The downtime upgrade would have created the event if in range  |
      |OR 2) The post upgrade would have done so.                        |
      |In either situation we dont really care as the distribution is    |
      |posted. Bug 5600736 related change.                               |
      +------------------------------------------------------------------*/
       IF p_xla_ev_rec.xla_mode = 'O' AND  ev_rec.pstid(i) <> -3
          AND l_change_matrix = '1.12' THEN

          log(' Override ev_match_flg ' || 'TRUE');
          ev_match_flg := TRUE;

       END IF;

     /*-----------------------------------------------------------+
      |Latch on to the existing event where gldate matches.       |
      |Event id will have a value only if an event exists in the  |
      |database, otherwise it will be null and a negative event id|
      |seeded in the cache which will be used as a primary key for|
      |mapping the built event to the dist which maps to this     |
      |event, latching is implicit to these values and is done    |
      |After the Bulk Insert and Updates to Events table.         |
      |Latching occurs in the end.                                |
      +-----------------------------------------------------------*/
       /* IF ((NOT ev_match_flg)
           AND (l_change_matrix IN (1.01,1.03,1.07,1.09,1.13,1.14,
                                    1.16,1.17))) THEN  */
         /*------------------------------------------------+
          |Latching is implicit to ev_rec.ev_event_id for  |
          |Update or ev_rec.ev_temp_event_id for Insert    |
          |for all above change matrix values not in the   |
          |IF construct below. For others explicit latching|
          +------------------------------------------------*/
           /* IF (l_change_matrix IN (1.01, 1.09, 1.13, 1.17)) THEN
              ev_rec.dist_event_id(i) := ev_rec.ev_match_event_id(i);
           END IF; --latch on to matching event

       END IF; */  --Latch on to existing event check


     /*---------------------------------------------------------+
      | If Change_Matrix returns 1.02 1.04 1.08 1.10            |
      |    and the mode of execution is OLTP                    |
      | Then                                                    |
      | Need to check if the REV_RECOGNITION program has run on |
      | that invoice. Because if not then distributions are only|
      | modal, therefore they are not stamped with the event_id.|
      | Nevertheless, no new event should be created, only the  |
      | GLDate needs to be updated on that event.               |
      | Typically when a invoice with rules arrear has some     |
      | new lines entered then the transaction only has modal   |
      | REC distributions but the GLDate will be set the last   |
      | FORECASt REV_RECOGNITION date.                          |
      +---------------------------------------------------------*/
      l_revrun  := 'X';

      IF ev_rec.trx_type(i) = 'INV' AND p_xla_ev_rec.xla_mode = 'O' THEN
         log('arp_xla_events.is_one_acct_asg_on_ctlgd()+');
         log('The customer_trx_id :'||ev_rec.trx_id(i));

         l_revrun := is_one_acct_asg_on_ctlgd(ev_rec.trx_id(i));

         log('l_revrun : '||l_revrun);
         log('arp_xla_events.is_one_acct_asg_on_ctlgd()-');
      END IF;

     /*---------------------------------------------------------+
      |Update existing Event                                    |
      |Matrix  - Dist    - Description                          |
      |          Event                                          |
      |1.02    - T       - Update event gl date                 |
      |1.03    - T, F    - Update Status = Incomplete           |
      |1.04    - T       - Update gl date, Status = Incomplete  |
      |1.07    - T,F     - Update Status = Unprocessed          |
      |1.08    - T       - Update gl date, Status = Unprocessed |
      |1.10    - T       - Update gl date                       |
      |1.14    - T,F     - Status = Incomplete                  |
      |1.16    - T,F     - Status = Unprocessed                 |
      |1.08    - F       - Update gl date, Status = Unprocesse  |
      |                    if Acct_asg created for one line     |
      |1.02    - F       - Update gl date if ACT_ASG created    |
      |1.04    - F       - Update gl date if ACT_ASG created    |
      |1.10    - F       - Update gl date if ACT_ASG created    |
      |1.09    - T       - For the case of cleaning events      |
      |                    when update REV_REC event GL Dates.  |
      |1.23    -T,F      - Update of a postable trx to be       |
      |                    unpostable Bug#3320427               |
      |1.22    -T,F      - Update of a unpostable trx to be     |
      |                    postable Bug#3320427                 |
      +---------------------------------------------------------*/
      --BUG#3999572
      IF (l_change_matrix IN   ('1.13', '1.14', '1.15', '1.16', '1.17', '1.18', '1.19', '1.20', '1.21', '1.23'))
      THEN       NULL;
      --}
      ELSIF (((ev_match_flg)
             AND ((l_change_matrix IN ('1.02','1.03','1.04','1.07',
                                      '1.08','1.10'
                                      --,1.14,1.16,1.23
                                      ,'1.22'
                                      )) OR (  (p_xla_ev_rec.xla_doc_table <> 'CRH')  AND  (l_change_matrix IN ('1.09'))  )))
           OR ((NOT ev_match_flg)
                AND (l_change_matrix IN ('1.03','1.07'
                                    --,1.14,1.16,1.23
                                       ,'1.22'
                                        )))
           OR ((NOT ev_match_flg)
                AND (l_change_matrix IN ('1.02','1.04','1.08','1.10'))
                AND (l_revrun = 'N'))
          AND p_xla_ev_rec.xla_mode = 'O')
       THEN

          log('Entered Update Built event construct ');

          IF l_change_matrix IN ('1.02','1.04','1.08','1.10','1.22') THEN
             ev_rec.ev_match_gl_date(i) := ev_rec.dist_gl_date(i);
           --introduce validation to make sure that another dist
           --with the same GL Date does not exist
          --{BUG#3320427
          ELSIF l_change_matrix IN ('1.23') THEN
             ev_rec.ev_match_gl_date(i) := TO_DATE('01-01-1900','DD-MM-YYYY');
          --}
          END IF;
          --set the gl date

          IF l_change_matrix IN ('1.03', '1.04', '1.14','1.22') THEN
             ev_rec.ev_match_status(i)  := 'I';
          ELSIF l_change_matrix IN ('1.07','1.08','1.16') THEN
             ev_rec.ev_match_status(i)  := 'U';
          --{BUG#3320427
--{BUG#3999572
--          ELSIF l_change_matrix IN (1.23) THEN
--             ev_rec.ev_match_status(i)  := 'N';
--}
          --}
          END IF; --set the status

          /*--------------------------------------------------------------------+
           | Need to avoid the existance of multiple events of the same type    |
           | and the same GLDate for the same document in XLA_EVENTS table.     |
           | Typically this can happens when user update the GL_Date on a inv   |
           | with rules on which REV_RECOGNITION has run. In this case the      |
           | the xla_events table contains multiple REV_RECOGNITION events with |
           | different GLDate, when user updates the GL Date on the header      |
           | of the document, the GLDates for all the distributions related     |
           | to that document are updated to the new GLDate.                    |
           | In this case, we need :                                            |
           |  Reset the event_id of the distributions to NULL.                  |
           |  Conserve only one event of one type and a GLDate.                 |
           |  The denormalise mode should restamped the distributions with the  |
           |  correct event_id.                                                 |
           +--------------------------------------------------------------------*/
           keep_flag := TRUE;

          --This can happen only real time OLTP
           IF p_xla_ev_rec.xla_mode = 'O' THEN

              IF bld_ev_ent.COUNT > 0 THEN

              FOR indx IN bld_ev_ent.FIRST .. bld_ev_ent.LAST LOOP

                IF bld_ev_ent(indx).event_type_code   =  ev_rec.ev_match_type(i)    AND
                   bld_ev_ent(indx).transaction_number=  ev_rec.trx_number(i)       AND
                   bld_ev_ent(indx).security_id_int_1 =  ev_rec.org_id(i)           AND
                   bld_ev_ent(indx).event_date        =  ev_rec.ev_match_gl_date(i) AND
                   bld_ev_ent(indx).event_status_code =  ev_rec.ev_match_status(i)  AND
                   bld_ev_ent(indx).event_id         <>  ev_rec.ev_match_event_id(i)
                THEN
                  log('clean events (event_id) : '||ev_rec.ev_match_event_id(i));
                  log('clean events (event_type_code) : '||ev_rec.ev_match_type(i));
                  log('clean events (transaction_number) : '||ev_rec.trx_number(i));

               ------------------
               -- unset_event_ids
               ------------------
                  un_denormalize_posting_entity(p_xla_doc => p_xla_ev_rec.xla_doc_table,
                                                p_event_id => ev_rec.ev_match_event_id(i));

               ----------------
               -- delete events
               ----------------

               -- Set source_info
                  l_event_source_info.application_id       := 222;
                  l_event_source_info.legal_entity_id      := ev_rec.legal_entity_id(i); --to be set
                  l_event_source_info.ledger_id            := arp_standard.sysparm.set_of_books_id; --to be set

                  /* Bug 6932145: Modified l_event_source_info.entity_type_code = NULL to l_entity_code */
                  l_event_source_info.entity_type_code     := l_entity_code; -- '';
                  l_event_source_info.transaction_number   := ev_rec.trx_number(i);
                  l_event_source_info.source_id_int_1      := ev_rec.trx_id(i);

               -- Set security_context
               l_security_context.security_id_int_1     := ev_rec.org_id(i);

               -- Delete the event
                  xla_events_pub_pkg.delete_event
                  ( p_event_source_info   => l_event_source_info,
                    p_event_id            => ev_rec.ev_match_event_id(i),
                    p_valuation_method    => NULL,
                    p_security_context    => l_security_context);

                  keep_flag  := FALSE;

                  EXIT;

                END IF; --event needs to be deleted

              END LOOP; --loop through built events

           END IF; --built event exists

        END IF;--if OLTP then check whether existing events need to be deleted

        IF keep_flag THEN

           j := j + 1;
           l_type := 'BUILT_AN_EVENT';
           l_build_ctr := j;
           log('l_type ' || l_type);

      --Build the event record for update. It is possible for two dists
      --to have the same matching event, so for the same event two Update
      --dml statements will be introduced in OLTP only, the overhead is
      --acceptable versus unnecessarily sweeping the build cache table
      --which we intend to use for bulk operations only
           bld_ev_rec.bld_dml_flag(l_build_ctr)      := 'U';
           bld_ev_rec.bld_temp_event_id(l_build_ctr) := ev_rec.ev_match_event_id(i);
           bld_ev_ent(l_build_ctr).transaction_number:= ev_rec.trx_number(i);
           bld_ev_ent(l_build_ctr).security_id_int_1 := ev_rec.org_id(i);
           bld_ev_ent(l_build_ctr).event_date        := ev_rec.ev_match_gl_date(i);
           bld_ev_ent(l_build_ctr).event_status_code := ev_rec.ev_match_status(i);
           bld_ev_ent(l_build_ctr).event_type_code   := ev_rec.ev_match_type(i);
           bld_ev_ent(l_build_ctr).event_id          := ev_rec.ev_match_event_id(i);
           bld_ev_ent(l_build_ctr).source_id_int_1   := ev_rec.trx_id(i);
--{HYU transaction_date,legal_entity_id
           bld_ev_ent(l_build_ctr).transaction_date  := ev_rec.transaction_date(i);
           bld_ev_ent(l_build_ctr).reference_num_1   := ev_rec.legal_entity_id(i);
--}

           dump_bld_rec(p_bld_rec =>  bld_ev_rec ,
                        p_i       =>  l_build_ctr,
                        p_tag     => 'bld_ev_rec' );


           dump_event_info(p_ev_info_tab => bld_ev_ent,
                           p_i           => l_build_ctr,
                           p_tag         => 'bld_ev_ent');


         END IF;

       END IF; --Update event condition

     /*-----------------------------------------------------------------+
      | Create Events for distributions which do not have an existing   |
      | event to latch on to.                                           |
      |                                                                 |
      | For 1.02 1.04 1.08 1.10 need to check if REVENUE RECOGNITION    |
      | has run on the invoice.                                         |
      +-----------------------------------------------------------------*/
       IF (l_change_matrix IN ('1.05','1.06','1.11','1.12')
--{BUG#3999572
--,1.15,1.18,1.19,1.20)
--}
           AND (NOT ev_match_flg))
          OR
          (l_change_matrix IN ('1.02','1.04','1.08','1.10') AND (l_revrun = 'Y')
           AND (NOT ev_match_flg)) THEN

               log('Building an Event in Insert new' ||
                                  ' event construct ');

              --increment the event build table cell counter
                j := j + 1;
                l_type := 'BUILT_AN_EVENT';
                l_build_ctr := j;
                log('l_type ' || l_type);

             /*----------------------------------------------------+
              |Create event - construct event attributes           |
              +----------------------------------------------------*/
                bld_ev_rec.bld_dml_flag(l_build_ctr)       := 'I';
                bld_ev_ent(l_build_ctr).source_id_int_1    := ev_rec.trx_id(i);
                bld_ev_ent(l_build_ctr).transaction_number := ev_rec.trx_number(i);
                bld_ev_ent(l_build_ctr).security_id_int_1  := ev_rec.org_id(i);
--{HYU transaction_date,legal_entity_id
                bld_ev_ent(l_build_ctr).transaction_date  := ev_rec.transaction_date(i);
                bld_ev_ent(l_build_ctr).reference_num_1   := ev_rec.legal_entity_id(i);
--}
             /*----------------------------------------------------+
              |Set the event GL Date                               |
              +----------------------------------------------------*/
                log('Set the event GL Date');
                IF (ev_rec.posttogl(i) = 'Y') THEN
                   IF to_char(ev_rec.dist_gl_date(i),'DD-MM-YYYY')= '01-01-1900' THEN
                      bld_ev_ent(l_build_ctr).event_date := '';
                   ELSE
                      bld_ev_ent(l_build_ctr).event_date := ev_rec.dist_gl_date(i);
                   END IF;
                ELSIF (ev_rec.posttogl(i) = 'N') THEN
                   IF to_char(ev_rec.dist_gl_date(i),'DD-MM-YYYY') = '01-01-1900' THEN
                      --{Bug#3320427 None postable trx event_date should be 01-01-1900
                      -- event date is mandatory for XLA
                      bld_ev_ent(l_build_ctr).event_date := TO_DATE('01-01-1900','DD-MM-YYYY');
                      --}
                   ELSE
                      bld_ev_ent(l_build_ctr).event_date := ev_rec.dist_gl_date(i);
                   END IF;
                END IF; --post to gl condition to set gl date

             /*----------------------------------------------------+
              |Set the event Status                                |
              +----------------------------------------------------*/
                IF ev_rec.pstid(i) <> -3 THEN
                   -- P : PROCESSED
                   bld_ev_ent(l_build_ctr).event_status_code  := 'P';

                ELSIF l_change_matrix IN ('1.02','1.04','1.05','1.06') THEN
                      --Bug#3320427  exclude 1.15 for none postable trx creation)
                   -- I : INCOMPLETE
                   bld_ev_ent(l_build_ctr).event_status_code  := 'I';

                ELSIF l_change_matrix IN ('1.18','1.19','1.20','1.15') THEN
                   --Bug#3320427 include 1.15 to create No Active event
                   --for none postable transaction
                   -- N : NOACTION
                   bld_ev_ent(l_build_ctr).event_status_code  := 'N';

                ELSIF l_change_matrix IN ('1.08','1.10','1.11','1.12') THEN
                   -- U : UNPROCESSED
                   bld_ev_ent(l_build_ctr).event_status_code  := 'U';

                END IF; --set the event status

              /*---------------------------------------------------+
               |Set the event Type                                 |
               +---------------------------------------------------*/
                 bld_ev_ent(l_build_ctr).event_type_code := ev_rec.override_event(i);

              /*---------------------------------------------------+
               |Set the event Id to the temp internal ID, bld id   |
               |cell needs to be populated for update, so make sure|
               |contiguous null cell is created.                   |
               +---------------------------------------------------*/
                bld_ev_ent(l_build_ctr).event_id := '';

                dump_bld_rec(p_bld_rec => bld_ev_rec,
                             p_i => l_build_ctr ,
                             p_tag => 'bld_ev_rec');

                dump_event_info(p_ev_info_tab => bld_ev_ent,
                                p_i           => l_build_ctr,
                                p_tag         => 'bld_ev_ent');

              /*-----------------------------------------------------+
               |Override the current distributions matching event id |
               |and match temp event id with the actual event/temp id|
               +-----------------------------------------------------*/

       END IF; --Insert event condition

     /*---------------------------------------------------------------+
      |Abnormal conditions raise user defined exception. Typically    |
      |the current trx should be skipped in upgrade mode.             |
      | Remove : 1.11 When adding distributions to a posted document  |
      |          is situation can happen                              |
      |          the document status is C                             |
      |          the existing event status is P                       |
      |          the match_flg is TRUE                                |
      +---------------------------------------------------------------*/
       IF (l_change_matrix IN ('1.05','1.06'
--{BUG#399572
--,1.15,1.18,1.21
--}
	                          ,'1.12')
          AND (ev_match_flg)) THEN

           --Bug 5600736 added the block below
           IF p_xla_ev_rec.xla_mode = 'O' AND  ev_rec.pstid(i) <> -3
               AND l_change_matrix = '1.12' THEN
               null; --skip the distribution as distribution is posted
           ELSE
             RAISE abnormal_cond;
           END IF;

       END IF; --abnormal condition

--{BUG#4414585 - dont do anything
       IF l_change_matrix IN ('3.01') THEN
          NULL;
       END IF;
--}

     /*----------------------------------------------------+
      |Sweep Trx Cache to raise validation if other dist's |
      |with the different gl dates exist for the same event|
      |Applicable to events 1.2, 1.4, 1.6, 1.10 for OLTP an|
      |SQL may require to be added. Row based operations.  |
      |May be in update construct above.                   |
      +----------------------------------------------------*/

     /*---------------------------------------------------------+
      |Add an event to the events cache table for the current   |
      |transaction being processed. Get the hash index using    |
      |hash function and ascertain if the event has been cached |
      +---------------------------------------------------------*/

     /*-----------------------------------------------------------+
      |Set the previous row id of the distribution and trx id     |
      |used to reinitialize caches or skip processing duplicate   |
      |rows.                                                      |
      +-----------------------------------------------------------*/
       --prev_distid  := ev_rec.dist_id(i); same dist is not reprocessed
       prev_trx_id := ev_rec.trx_id(i); --reinitalize trx cache

       log('prev_trx_id = ' || prev_trx_id);

    END LOOP; --process distributions

  /*---------------------------------------------------------------------+
   |Call the xla events api passing it the tables for Bulk Insert, Update|
   |On return for inserted rows, the event_id will be returned and the   |
   |distributions will be updated with this event id using the temp event|
   |id which will ascertain the mapping of internal id's to actual ids   |
   |for a distribution.To be replaced by call to xla events api commit   |
   |issued by owning product.                                            |
   +---------------------------------------------------------------------*/

  /*-------------------------------------------------------------+
   | Insert into Events table, to be replaced with XLA apis      |
   +-------------------------------------------------------------*/

    IF p_xla_ev_rec.xla_mode IN ('U','B') AND test_flag = 'N' THEN

       log('xla_events_pub_pkg.create_bulk_events xla_mode IN (U,B)');

/*
       bld_ev_ent := xla_events_pub_pkg.create_bulk_events(
                p_application_id          => 222       ,
                p_legal_entity_id         => '1'        ,-- to be set later
                p_ledger_id               => arp_standard.sysparm.set_of_books_id ,-- to be set later
                p_entity_type_code        => l_entity_code        ,-- to be set later
                p_array_entity_event_info => bld_ev_ent);
--                p_valuation_method        => ''        ,
--                p_security_context        => l_security_context);
*/
/* As this call is not suitable to AR, the bug for XLA spi enhancement has been logged
   BUG#4448003 for now converting this call to single event call
        xla_events_pub_pkg.create_bulk_events(
                p_source_application_id   => NULL      ,
                p_application_id          => 222       ,
                p_legal_entity_id         => '1'        ,-- to be set later
                p_ledger_id               => arp_standard.sysparm.set_of_books_id ,-- to be set later
                p_entity_type_code        => l_entity_code);
*/
       cnt := bld_ev_ent.COUNT;
       IF cnt > 0 THEN
         FOR m IN bld_ev_ent.FIRST .. bld_ev_ent.LAST LOOP
           INSERT INTO xla_events_int_gt (
               APPLICATION_ID
             , LEGAL_ENTITY_ID
             , LEDGER_ID
             , ENTITY_CODE
             , TRANSACTION_NUMBER
             , SOURCE_ID_INT_1
             , EVENT_TYPE_CODE
             , EVENT_STATUS_CODE
             , EVENT_DATE
             , SECURITY_ID_INT_1
             , TRANSACTION_DATE     )
            VALUES   (
               222
             , bld_ev_ent(m).reference_num_1         -- LEGAL_ENTITY_ID
             , arp_standard.sysparm.set_of_books_id  -- LEDGER_ID
             , l_entity_code                         -- ENTITY_CODE
             , bld_ev_ent(m).transaction_number      -- TRANSACTION_NUMBER
             , bld_ev_ent(m).source_id_int_1         -- SOURCE_ID_INT_1
             , bld_ev_ent(m).event_type_code         -- EVENT_TYPE_CODE
             , bld_ev_ent(m).event_status_code       -- EVENT_STATUS_CODE
             , bld_ev_ent(m).event_date              -- EVENT_DATE
             , bld_ev_ent(m).security_id_int_1       -- SECURITY_ID_INT_1
             , bld_ev_ent(m).transaction_date);      -- TRANSACTION_DATE
         END LOOP;
        END IF;

       log('Bulk Mode not ready - using OLTP');

    END IF;

  /*--------------------------------------------------------------+
   |Bulk update the distributions already existing in the Database|
   |with the modified gl date or status, if unchanged these should|
   |retain their default original values in the assignments below.|
   +--------------------------------------------------------------*/

    IF    p_xla_ev_rec.xla_mode = 'O'
	--{Work around waiting for bulk mode
--       OR p_xla_ev_rec.xla_mode = 'B'
    --}
	THEN

       IF bld_ev_ent.COUNT > 0 THEN

         FOR m IN bld_ev_ent.FIRST .. bld_ev_ent.LAST LOOP

     /*----------------------------------------------------------+
      |Set the event source details                              |
      +----------------------------------------------------------*/
        l_event_source_info.application_id       := 222;
        --{HYU transaction_date,legal_entity_id
        l_event_source_info.legal_entity_id      := bld_ev_ent(l_build_ctr).reference_num_1; -- --to be set
        --}
        l_event_source_info.ledger_id            := arp_standard.sysparm.set_of_books_id; --to be set
        l_event_source_info.entity_type_code     := l_entity_code ;
        l_event_source_info.transaction_number   := bld_ev_ent(m).transaction_number;
        l_event_source_info.source_id_int_1      := bld_ev_ent(m).source_id_int_1;

     dump_event_source_info
     (x_ev_source_info => l_event_source_info);

     /*----------------------------------------------------------+
      |Set the security details                                  |
      +----------------------------------------------------------*/
        l_security_context.security_id_int_1     := bld_ev_ent(m).security_id_int_1;
     /*----------------------------------------------------------+
      |Set the event reference details                           |
      +----------------------------------------------------------*/
        --to be ascertained after events template is filled

        IF bld_ev_rec.bld_dml_flag(m) = 'I' AND test_flag = 'N'  THEN

           log('XLA_EVENTS_PUB_PKG.create_event');

z := z + 1;
log('hyu calling create event for zth time :'||z);

           lnb := XLA_EVENTS_PUB_PKG.create_event(
              p_event_source_info => l_event_source_info             ,
              p_event_type_code   => bld_ev_ent(m).event_type_code   ,
              p_event_date        => bld_ev_ent(m).event_date        ,
              p_event_status_code => bld_ev_ent(m).event_status_code ,
              p_event_number      => NULL                            ,
              p_reference_info    => l_reference_info                ,
              p_valuation_method  => ''                              ,
              --{HYU transaction_date
              p_transaction_date  => bld_ev_ent(m).transaction_date  ,
              --}
              p_security_context  => l_security_context               );

        ELSIF bld_ev_rec.bld_dml_flag(m) = 'U' AND test_flag = 'N' THEN

             log('XLA_EVENTS_PUB_PKG.update_event');

log('bld_ev_ent(m).event_id :'||bld_ev_ent(m).event_id );
log('bld_ev_ent(m).event_type_code :'||bld_ev_ent(m).event_type_code );
log(' bld_ev_ent(m).event_date :'|| bld_ev_ent(m).event_date );
log(' bld_ev_ent(m).event_status_code :'|| bld_ev_ent(m).event_status_code);
log(' p_security_context.security_id_int_1 :'|| l_security_context.security_id_int_1 );

              XLA_EVENTS_PUB_PKG.update_event(
                 p_event_source_info => l_event_source_info             ,
                 p_event_id          => bld_ev_ent(m).event_id          ,
                 p_event_type_code   => bld_ev_ent(m).event_type_code   ,
                 p_event_date        => bld_ev_ent(m).event_date        ,
                 p_event_status_code => bld_ev_ent(m).event_status_code ,
                 p_valuation_method  => ''                              ,
                 p_security_context  => l_security_context               );

-- Checking change of transaction number for Copy Document Sequence Feature

       IF NVL(l_entity_code,' ') = 'TRANSACTIONS' THEN

log(' Checking if Trxn number has changed by  Copy Document Sequence Feature');

	BEGIN
		SELECT a.transaction_number INTO trxn_number
		FROM   xla_transaction_entities_upg a,
		       xla_events b
		WHERE  NVL(a.source_id_int_1,-99) = bld_ev_ent(m).source_id_int_1
		AND    b.event_id  = bld_ev_ent(m).event_id
	        AND    a.entity_id = b.entity_id
		AND    a.security_id_int_1 = bld_ev_ent(m).security_id_int_1
		AND    a.application_id = 222;

	EXCEPTION
	  WHEN OTHERS THEN
	     log('EXCEPTION: XLA TRANSACTION NUMBER UPDATE');
	     log('SQLERRM ' || SQLERRM);
	     RAISE;
	END;

	IF NVL(trxn_number,-99) <> bld_ev_ent(m).transaction_number THEN
	      XLA_EVENTS_PUB_PKG.UPDATE_TRANSACTION_NUMBER(
		 p_event_source_info   =>   l_event_source_info,
		 p_transaction_number  =>   bld_ev_ent(m).transaction_number,
		 p_valuation_method    =>   '',
		 p_security_context    =>   l_security_context ,
		 p_event_id            =>   bld_ev_ent(m).event_id );
	END IF;
        END IF; -- end checking change of trxn number for transactions
        END IF; --end insert or update events in OLTP mode

      END LOOP;

     END IF;

    END IF;

  /*----------------------------------------------------------+
   |Denormalize the event id which has been inserted into the |
   |database, and update the event id column in the dist table|
   |This denormalization is used by the extract process.      |
   |The internal negative id i.e. temp_event_id is used to    |
   |ascertain as to which event.                              |
   +----------------------------------------------------------*/
 --Only used for upgrade
    IF p_xla_ev_rec.xla_mode = 'U' THEN
       Commit;
    END IF; --mode is Upgrade, Oltp or Batch

-- Exit from the loop if no. of rows fetched < array size
    EXIT WHEN l_rows_fetched < MAX_ARRAY_SIZE;

   END LOOP; --Array (Bulk) Fetch

--{XLA BULK API
   IF p_xla_ev_rec.xla_mode = 'B'  THEN
      OPEN for_batch;
      FETCH for_batch INTO l_test;
        IF for_batch%FOUND THEN
         log('Calling xla_events_pub_pkg.create_bulk_events +');
         xla_events_pub_pkg.create_bulk_events
         (p_application_id         => 222,
          p_ledger_id              => arp_standard.sysparm.set_of_books_id,
          p_entity_type_code       => l_entity_code);
         --avoid recreation of successfully events
         DELETE from xla_events_int_gt WHERE entity_id IS NOT NULL;
         log('Calling xla_events_pub_pkg.create_bulk_events -');
        END IF;
      CLOSE for_batch;
   END IF;
--}
  /*--------------------------------------------------------------+
   |Bulk update the distributions event ids with the newly created|
   |event ids as part of the mark transaction data associated with|
   |the event.                                                    |
   +--------------------------------------------------------------*/

<<endlabel>>
   log('ARP_XLA_EVENTS.Create_All_Events ()-');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.Create_All_Events ');
     log('SQLERRM ' || SQLERRM);
     log('EXCEPTION: ARP_XLA_EVENTS.Create_All_Events ');
     log('SQLERRM ' || SQLERRM);
    RAISE;
END Create_All_Events;

/*========================================================================
 | PRIVATE PROCEDURE un_denormalize_posting_entity
 |
 | DESCRIPTION
 |     Purpose : Erase the event_id on the distributions.
 |     It determines the posting entity on each the event_id should be erase.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     Create_all_events
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 | PARAMETERS p_override_event    generated by SQL dynamic
 |            p_trx_type          transaction type
 |            p_exist_event_type  existing event type
 |            p_event_id          event_id to be erase on distributions
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-OCT-2002           H. Yu
 *=======================================================================*/
  PROCEDURE un_denormalize_posting_entity
  ( p_xla_doc         IN VARCHAR2,
    p_event_id        IN NUMBER   ) IS

  BEGIN
    log('arp_xla_events.un_denormalize_posting_entity()+');

    IF test_flag = 'Y' THEN
      GOTO endlabel;
    END IF;

    IF p_xla_doc IN ('CT','CTCMAPP','CTNORCM') THEN

      UPDATE ra_cust_trx_line_gl_dist
         SET event_id = NULL
       WHERE event_id = p_event_id;

    ELSIF p_xla_doc IN ('CRH', 'CRHMCD', 'CRHAPP') THEN

      UPDATE ar_cash_receipt_history
         SET event_id = NULL
       WHERE event_id = p_event_id;

    ELSIF p_xla_doc = 'ADJ' THEN

      UPDATE ar_adjustments
         SET event_id = NULL
       WHERE event_id = p_event_id;

    ELSIF p_xla_doc IN ('CRHAPP', 'APP') THEN

      UPDATE ar_receivable_applications
         SET event_id = NULL
       WHERE event_id = p_event_id;

    ELSIF p_xla_doc IN ('CRHMCD', 'MCD') THEN

      UPDATE ar_misc_cash_distributions
         SET event_id = NULL
       WHERE event_id = p_event_id;

    ELSIF p_xla_doc = 'TRH' THEN

      UPDATE ar_transaction_history
         SET event_id = NULL
       WHERE event_id = p_event_id;

    END IF;

    <<endlabel>>

   log('arp_xla_events.un_denormalize_posting_entity()-');

   EXCEPTION
   WHEN OTHERS THEN
     log('EXCEPTION: arp_xla_events.un_denormalize_posting_entity');
     log('SQLERRM '||sqlerrm);
     RAISE;

END un_denormalize_posting_entity;

/*========================================================================
 | Private Function: is_one_acct_asg_on_ctlgd
 |
 | Description :
 |   Function only work for OLTP mode because it needs a org context.
 |   If necessary it is extensible for other mode
 |   Return
 |   + 'Y' if at least one invoice line has its account assignment created.
 |   + 'N' if no line has its account assignment created - Typically when a
 |         invoice with rules is completed without having been submitted to
 |         the revenue recognition process.
 |   + 'X' if the invoice p_posting_entity is not CTLGD means the accounting
 |         model does not use CTLGD.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |     Create_all_events
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 | Parameters :
 |   1) p_invoice_id      Customer_trx_id
 |   2) p_posting_entity  Transaction_type
 |   3) p_mode            'O' OLTP only
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-OCT-2002           H. Yu
 *=======================================================================*/
 FUNCTION is_one_acct_asg_on_ctlgd
  (p_invoice_id     IN NUMBER,
   p_posting_entity IN VARCHAR2 DEFAULT 'CTLGD',
   p_mode           IN VARCHAR2 DEFAULT 'O') RETURN VARCHAR2
 IS

   CURSOR cu_is_rev_rec_run IS
   SELECT 'Y'
     FROM ra_customer_trx_lines ctl
    WHERE ctl.customer_trx_id = p_invoice_id
      AND ctl.line_type = 'LINE'
      AND NVL(ctl.autorule_complete_flag,'Y') <> 'N';

   ltab  DBMS_SQL.VARCHAR2_TABLE;
   lres  VARCHAR2(1);

 BEGIN
   IF p_posting_entity <> 'CTLGD' THEN
     lres := 'X';
   ELSE
     OPEN cu_is_rev_rec_run;
     FETCH cu_is_rev_rec_run INTO lres;
     IF cu_is_rev_rec_run%NOTFOUND THEN
       -- None line has its account assignments created
       lres := 'N';
       -- Otherwise at least one line has its account
       -- assignments created the result will be 'Y'
     END IF;
     CLOSE cu_is_rev_rec_run;
   END IF;
   RETURN lres;

 EXCEPTION
   WHEN OTHERS THEN
     IF cu_is_rev_rec_run%ISOPEN THEN CLOSE cu_is_rev_rec_run; END IF;
     RAISE;

 END;


/*========================================================================
 | PUBLIC PROCEDURE Upd_Dist
 |
 | DESCRIPTION
 |      Denormalizes the event id for Receivables documents
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Execute
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_xla_ev_rec IN xla_events_type
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE Upd_Dist(p_xla_ev_rec IN xla_events_type) IS

type l_rowid_type IS TABLE OF VARCHAR2(50)
                      INDEX BY BINARY_INTEGER;
type l_event_id_type IS TABLE OF NUMBER(15)
                      INDEX BY BINARY_INTEGER;

ev_rec        ev_rec_type;
empty_ev_rec  ev_rec_type;

l_rowid l_rowid_type;
l_event_id l_event_id_type;

l_last_fetch BOOLEAN := FALSE;

l_select_c   INTEGER;

l_ignore           INTEGER;
l_rows_fetched     VARCHAR2(10);
l_low              INTEGER:=0;
l_high             INTEGER:=0;
--6785758
l_last_updated_by    NUMBER := arp_standard.profile.user_id;
l_last_update_login  NUMBER := arp_standard.profile.last_update_login;
BEGIN

   log('ARP_XLA_EVENTS.Upd_Dist()+');

   IF p_xla_ev_rec.xla_call IN ('D','B') THEN
      null;
   ELSE goto endlabel;
   END IF;

   l_select_c := Get_Select_Cursor(p_xla_ev_rec => p_xla_ev_rec,
                                   p_call_point => 2);

   l_ignore   := dbms_sql.execute(l_select_c);

   log( 'Fetching select stmt');

   LOOP  -- Main Cursor Loop

      ev_rec.dist_row_id   := empty_ev_rec.dist_row_id;
      ev_rec.dist_event_id := empty_ev_rec.dist_event_id;

      l_rows_fetched := dbms_sql.fetch_rows(l_select_c);

      log('Rows Fetched are ' || l_rows_fetched);

      l_low := l_high + 1;
      l_high:= l_high + l_rows_fetched;

      IF l_rows_fetched > 0 THEN

         log('Fetched a row ');
         log('l_low  ' || l_low);
         log('l_high ' || l_high);

         get_column_values(p_select_c   => l_select_c,
                           p_xla_ev_rec => p_xla_ev_rec,
                           p_ev_rec     => ev_rec,
                           p_call_point => 2);

       -- no more rows to fetch
         IF l_rows_fetched < MAX_ARRAY_SIZE THEN
            log('Done fetching 3');

            IF( dbms_sql.is_open( l_select_c) ) THEN
                dbms_sql.close_cursor( l_select_c );
            END IF;

         END IF; --no more rows to fetch

       ELSE --if rows fetched = 0
          log('Done fetching 4');

          IF( dbms_sql.is_open( l_select_c ) ) THEN
                dbms_sql.close_cursor( l_select_c );
          END IF;

          EXIT;

      END IF; --rows fetched greater than 0

      log('Commence bulk update processing');

      IF (p_xla_ev_rec.xla_doc_table IN ('CT','CTNORCM')
             OR (p_xla_ev_rec.xla_doc_table = 'CTCMAPP' AND g_call_number = 2))
         AND test_flag = 'N' THEN

         log('Bulk Updating Transactions');

         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
--6785758
	   UPDATE ra_cust_trx_line_gl_dist_all ctlgd
           SET ctlgd.event_id          = ev_rec.dist_event_id(m),
               ctlgd.last_update_date  = SYSDATE,
               ctlgd.last_update_login = l_last_update_login,
               ctlgd.last_updated_by   = l_last_updated_by
           WHERE ctlgd.rowid = ev_rec.dist_row_id(m);

      END IF;

      IF p_xla_ev_rec.xla_doc_table = 'ADJ' AND test_flag = 'N' THEN
         log('Bulk Updating Adjustments ');
         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
           UPDATE ar_adjustments_all           adj
           SET adj.event_id            = ev_rec.dist_event_id(m),
               adj.last_update_date    = SYSDATE,
               adj.last_update_login   = l_last_update_login,
               adj.last_updated_by     = l_last_updated_by
           WHERE adj.rowid = ev_rec.dist_row_id(m);
      END IF;

      IF p_xla_ev_rec.xla_doc_table = 'CRH'  AND test_flag = 'N' THEN
         log('Bulk Updating Cash Receipt History');
         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
--6785758
	   UPDATE ar_cash_receipt_history_all  crh
           SET crh.event_id            = ev_rec.dist_event_id(m),
               crh.last_update_date    = SYSDATE,
               crh.last_update_login   = l_last_update_login,
               crh.last_updated_by     = l_last_updated_by
           WHERE crh.rowid = ev_rec.dist_row_id(m);
      END IF;

      IF p_xla_ev_rec.xla_doc_table = 'MCD'  AND test_flag = 'N' THEN
         log('Bulk Updating misc cash distributions');
         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
--6785758
	   UPDATE ar_misc_cash_distributions_all mcd
           SET mcd.event_id            = ev_rec.dist_event_id(m),
               mcd.last_update_date    = SYSDATE,
               mcd.last_update_login   = l_last_update_login,
               mcd.last_updated_by     = l_last_updated_by
           WHERE mcd.rowid = ev_rec.dist_row_id(m);
      END IF;

      IF (p_xla_ev_rec.xla_doc_table IN ('APP', 'CMAPP')
            OR ( p_xla_ev_rec.xla_doc_table = 'CTCMAPP' AND g_call_number = 1))
         AND test_flag = 'N' THEN
         log('Bulk Updating receivable applications');
         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
--6785758
	   UPDATE ar_receivable_applications_all app
           SET app.event_id            = ev_rec.dist_event_id(m),
               app.last_update_date    = SYSDATE,
               app.last_update_login   = l_last_update_login,
               app.last_updated_by     = l_last_updated_by
           WHERE app.rowid = ev_rec.dist_row_id(m);
      END IF;

      IF p_xla_ev_rec.xla_doc_table = 'TRH'  AND test_flag = 'N' THEN
         log('Bulk Updating Bills Receivable transaction history ');
         FORALL m IN ev_rec.dist_row_id.FIRST .. ev_rec.dist_row_id.LAST
--6785758
	   UPDATE ar_transaction_history_all trh
           SET trh.event_id            = ev_rec.dist_event_id(m),
               trh.last_update_date    = SYSDATE,
               trh.last_update_login   = l_last_update_login,
               trh.last_updated_by     = l_last_updated_by
           WHERE trh.rowid = ev_rec.dist_row_id(m);
      END IF;

   --Only used for upgrade
      IF p_xla_ev_rec.xla_mode = 'U' THEN
          Commit;
      END IF; --mode is Upgrade, Oltp or Batch

   --Exit from the loop if no. of rows fetched < array size
      EXIT WHEN l_rows_fetched < MAX_ARRAY_SIZE;

   END LOOP; --Array (Bulk) Fetch

<<endlabel>>
   log('ARP_XLA_EVENTS.Upd_Dist()-');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.Upd_Dist');
     RAISE;

END Upd_Dist;

/*========================================================================
 | PUBLIC PROCEDURE dump_ev_rec
 |
 | DESCRIPTION
 |      Dumps the event record fetched for creation of events
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Create_All_Events
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_xla_ev_rec IN event record
 |      p_i          IN index
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE dump_ev_rec(p_ev_rec IN OUT NOCOPY ev_rec_type,
                      p_i IN BINARY_INTEGER) IS

BEGIN

   log(' ');
   log('ARP_XLA_EVENTS.dump_ev_rec()+');

   IF p_ev_rec.trx_status.EXISTS(p_i) THEN

      log('p_ev_rec.trx_status(' || p_i || ') = '
                               || p_ev_rec.trx_status(p_i));
      log('p_ev_rec.trx_id(' || p_i || ') = '
                               || p_ev_rec.trx_id(p_i));
      log('p_ev_rec.dist_event_id(' || p_i || ') = '
                               || p_ev_rec.dist_event_id(p_i));
      log('p_ev_rec.dist_gl_date(' || p_i || ') = '
                               || p_ev_rec.dist_gl_date(p_i));
      log('p_ev_rec.trx_type(' || p_i || ') = '
                               || p_ev_rec.trx_type(p_i));
      log('p_ev_rec.posttogl(' || p_i || ') = '
                               || p_ev_rec.posttogl(p_i));
      log('p_ev_rec.ev_match_event_id(' || p_i || ') = '
                               || p_ev_rec.ev_match_event_id(p_i));
      log('p_ev_rec.ev_match_gl_date(' || p_i || ') = '
                               || p_ev_rec.ev_match_gl_date(p_i));
      log('p_ev_rec.ev_match_status(' || p_i || ') = '
                               || p_ev_rec.ev_match_status(p_i));
      log('p_ev_rec.ev_match_type(' || p_i || ') = '
                               || p_ev_rec.ev_match_type(p_i));
  END IF;

  log('ARP_XLA_EVENTS.dump_ev_rec()-');
  log(' ');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.dump_ev_rec');
     RAISE;
END dump_ev_rec;


--HYU
PROCEDURE dump_event_source_info
  (x_ev_source_info IN OUT NOCOPY xla_events_pub_pkg.t_event_Source_info)
IS
BEGIN

   log(' ');
   log('ARP_XLA_EVENTS.dump_event_source_info()+');

   log('x_ev_source_info.application_id = '
                               || x_ev_source_info.application_id);
   log('x_ev_source_info.legal_entity_id = '
                               || x_ev_source_info.legal_entity_id);
   log('x_ev_source_info.ledger_id = '
                               || x_ev_source_info.ledger_id);
   log('x_ev_source_info.entity_type_code = '
                               || x_ev_source_info.entity_type_code);
   log('x_ev_source_info.transaction_number = '
                               || x_ev_source_info.transaction_number);
   log('x_ev_source_info.source_id_int_1 = '
                               || x_ev_source_info.source_id_int_1);
   log('x_ev_source_info.source_id_int_2 = '
                               || x_ev_source_info.source_id_int_2);
   log('x_ev_source_info.source_id_int_3 = '
                               || x_ev_source_info.source_id_int_3);
   log('x_ev_source_info.source_id_int_4 = '
                               || x_ev_source_info.source_id_int_4);
   log('x_ev_source_info.source_id_char_1 = '
                               || x_ev_source_info.source_id_char_1);
   log('x_ev_source_info.source_id_char_2 = '
                               || x_ev_source_info.source_id_char_2);
   log('x_ev_source_info.source_id_char_3 = '
                               || x_ev_source_info.source_id_char_3);
   log('x_ev_source_info.source_id_char_4 = '
                               || x_ev_source_info.source_id_char_4);
   log('x_ev_source_info.legal_entity_id = '
                               || x_ev_source_info.legal_entity_id);
   log('ARP_XLA_EVENTS.dump_event_source_info()-');
   log(' ');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.dump_event_source_info');
     RAISE;
END dump_event_source_info;

/*========================================================================
 | PUBLIC FUNCTION  Change_Matrix
 |
 | DESCRIPTION
 |      Decision matix which returns a number stating whether an update,
 |      insert or latch to an event is required.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Execute
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |       trx_status        IN Transaction status
 |       dist_gl_date      IN gldate of distribution
 |       ev_match_gl_date  IN matching or existing event accountin date
 |       ev_match_status   IN event status
 |       post_to_gl        IN post to Gl
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 |
 *=======================================================================*/
FUNCTION Change_Matrix(trx_status        IN VARCHAR2                   ,
                       dist_gl_date      IN DATE                       ,
                       ev_match_gl_date  IN DATE                       ,
                       ev_match_status   IN xla_events.event_status_code%TYPE,
                       posttogl          IN VARCHAR2) RETURN VARCHAR2 IS

l_change_matrix VARCHAR2(30);

BEGIN

    log('ARP_XLA_EVENTS.Change_Matrix()+');
    log('trx_status  :'||trx_status);
    log('dist_gl_date  :'||dist_gl_date);
    log('ev_match_gl_date  :'||ev_match_gl_date);
    log('ev_match_status   :'||ev_match_status);
    log('posttogl        :'||posttogl);

    IF posttogl = 'Y' THEN
        log('posttogl' || posttogl);
      /*-------------------------------------------------------+
       |1.01 - Current trx status    = Incomplete              |
       |       Current Gl date       = Existing Event Gl Date  |
       |       Existing Event Status = Incomplete              |
       +-------------------------------------------------------*/
        IF trx_status = 'I'
          AND dist_gl_date = NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
          AND ev_match_status = 'I' THEN
          l_change_matrix := '1.01';

      /*------------------------------------------------------+
       |1.02 - Current trx status   = Incomplete              |
       |       Current Gl date       <> Existing Event Gl Date|
       |       Existing Event Status = Incomplete             |
       +------------------------------------------------------*/
        ELSIF trx_status = 'I'
             AND dist_gl_date <> NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.02';

      /*-------------------------------------------------------+
       |1.03 - Current trx status    = Incomplete              |
       |       Current Gl date       = Existing Event Gl Date  |
       |       Existing Event Status = Unprocessed             |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'I'
             AND dist_gl_date = NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'U' THEN
             l_change_matrix := '1.03';

      /*-------------------------------------------------------+
       |1.04 - Current trx status    =  Incomplete             |
       |       Current Gl date       <> Existing Event Gl Date |
       |       Existing Event Status =  Unprocessed            |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'I'
             AND dist_gl_date <> NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'U' THEN
             l_change_matrix := '1.04';

      /*-------------------------------------------------------+
       |1.05 - Current trx status    =  Incomplete             |
       |       Existing Event Status =  Processed              |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'I'
             AND ev_match_status = 'P' THEN
             l_change_matrix := '1.05';

      /*-------------------------------------------------------+
       |1.06 - Current trx status     = Incomplete             |
       |       Existing Event Gl Date = NULL                   |
       |       Existing Event Status  = NULL                   |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'I'
             AND (to_char(ev_match_gl_date,'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
--{BUG#4414585 -- Meaning the GL_DATE has been defined
-- because in the case of signed BR a postable transaction can have no
-- gl_date defined at creation time but xla_event creation the gl_date is
-- required column, hence 1.06 for event creation should only be possible
-- if the gl_date has been provided
             AND to_char(dist_gl_date,'DD-MM-YYYY') <> '01-01-1900'
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.06';

-- In the case a postable transaction with gl_date is created, there are 2 options
-- either not create any event or create a event with a dummy gl date
-- testing not to create any event change matrix value is 3.01
        ELSIF trx_status = 'I'
             AND (to_char(ev_match_gl_date,'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND to_char(dist_gl_date,'DD-MM-YYYY') = '01-01-1900'
             AND ev_match_status = 'X' THEN
             l_change_matrix  := '3.01';
--}
      /*-------------------------------------------------------+
       |1.06 - Current trx status     = Incomplete             |
       |       Existing Event Gl Date = NULL                   |
       |       Existing Event Status  = NULL                   |
       +-------------------------------------------------------*/



      /*-------------------------------------------------------+
       |1.07 - Current trx status    = Complete                |
       |       Current Gl date       = Existing Event Gl Date  |
       |       Existing Event Status = Incomplete              |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND dist_gl_date = NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.07';

      /*-------------------------------------------------------+
       |1.08 - Current trx status    =  Complete               |
       |       Current Gl date       <> Existing Event Gl Date |
       |       Existing Event Status =  Incomplete             |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND dist_gl_date <> NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.08';

      /*-------------------------------------------------------+
       |1.09 - Current trx status    =  Complete               |
       |       Current Gl date       =  Existing Event Gl Date |
       |       Existing Event Status =  Unprocessed            |
       +-------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND dist_gl_date = NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'U' THEN
             l_change_matrix := '1.09';

      /*------------------------------------------------------+
       |1.10- Current trx status    =  Complete               |
       |      Current Gl date       <> Existing Event Gl Date |
       |      Existing Event Status =  Unprocessed            |
       +------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND dist_gl_date <> NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'U' THEN
             l_change_matrix := '1.10';

      /*------------------------------------------------------+
       |1.11- Current trx status    =  Complete               |
       |      Existing Event Status =  Processed              |
       +------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND ev_match_status = 'P' THEN
             l_change_matrix := '1.11';

      /*------------------------------------------------------+
       |1.12- Current trx status    =  Complete               |
       |      Existing Event Gl Date is null                  |
       |      Existing Event Status is null                   |
       +------------------------------------------------------*/
        ELSIF trx_status = 'C'
             AND (to_char(ev_match_gl_date,'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.12';

       --{BUG#3320427
       /*----------------------------------------------------+
        | 1.22 - Current trx status = Incomplete             |
        |      Current CL date is NOT NULL or <> (01-01-1900)|
        |      Exist Event date is NULL or (01-01-1900)      |
        |      Existing Event Status =  No Action            |
        +----------------------------------------------------*/
         ELSIF trx_status = 'I'
           AND ev_match_status = 'N'
           AND to_char(dist_gl_date, 'DD-MM-YYYY') <> '01-01-1900'
           AND (to_char(ev_match_gl_date,'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
         THEN
           l_change_matrix := '1.22';
         --}
        END IF; --change matrix setup for postable distributions

       ELSIF posttogl = 'N' THEN
         /*-------------------------------------------------------+
          |1.13 - Current trx status     =  Incomplete            |
          |       Current Gl date = null =  Existing Event Gl Date|
          |       Existing Event Status  =  Incomplete            |
          +-------------------------------------------------------*/
           IF trx_status = 'I'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date,'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.13';

         /*-------------------------------------------------------+
          |1.14 - Current trx status     =  Incomplete            |
          |       Current Gl date = null =  Existing Event Gl Date|
          |       Existing Event Status  =  Noaction              |
          +-------------------------------------------------------*/
           ELSIF trx_status = 'I'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date, 'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'N' THEN
             l_change_matrix := '1.14';

         /*-------------------------------------------------------+
          |1.15 - Current trx status     =  Incomplete            |
          |       Current Gl date = null =  Existing Event Gl Date|
          |       Existing Event Status  =  null                  |
          +-------------------------------------------------------*/
           ELSIF trx_status = 'I'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date, 'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.15';

         /*------------------------------------------------------+
          |1.16 - Current trx status    =  Complete              |
          |       Current Gl date = null = Existing Event Gl Date|
          |       Existing Event Status =  Incomplete            |
          +------------------------------------------------------*/
           ELSIF trx_status = 'C'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date, 'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.16';

         /*------------------------------------------------------+
          |1.17 - Current trx status    =  Complete              |
          |       Current Gl date = null = Existing Event Gl Date|
          |       Existing Event Status =  Noaction              |
          +------------------------------------------------------*/
           ELSIF trx_status = 'C'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date, 'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'N' THEN
             l_change_matrix := '1.17';

         /*------------------------------------------------------+
          |1.18 - Current trx status    =  Complete              |
          |       Current Gl date = null = Existing Event Gl Date|
          |       Existing Event Status =  NULL                  |
          +------------------------------------------------------*/
           ELSIF trx_status = 'C'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND (to_char(ev_match_gl_date, 'DD-MM-YYYY') = '01-01-1900' OR ev_match_gl_date IS NULL)
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.18';

         /*------------------------------------------------------+
          |1.19 - Current trx status    =  Complete              |
          |       Current Gl date <> Existing Event Gl Date      |
          |       Existing Event Status =  NULL                  |
          +------------------------------------------------------*/
           ELSIF trx_status = 'C'
             AND dist_gl_date <> NVL(ev_match_gl_date ,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.19';

         /*------------------------------------------------------+
          |1.20 - Current trx status    =  Incomplete            |
          |       Current Gl date <> Existing Event Gl Date      |
          |       Existing Event Status =  NULL                  |
          +------------------------------------------------------*/
           ELSIF trx_status = 'I'
             AND dist_gl_date <> NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'X' THEN
             l_change_matrix := '1.20';

         /*------------------------------------------------------+
          |1.21 - Current trx status    =  Complete              |
          |       Current Gl date = Existing Event Gl Date       |
          |       Existing Event Status =  Incomplete            |
          +------------------------------------------------------*/
           ELSIF trx_status = 'C'
             AND dist_gl_date = NVL(ev_match_gl_date,TO_DATE('01-01-1900','DD-MM-YYYY'))
             AND ev_match_status = 'I' THEN
             l_change_matrix := '1.21';

          --{BUG#3320427
          /*----------------------------------------------------+
           | 1.23 - Current trx status = Incomplete             |
           |        Current CL date is NULL or (01-01-1900)     |
           |        Exist Event date <> NULL or (01-01-1900)    |
           |        Existing Event Status =  Incomplete         |
           +----------------------------------------------------*/
           ELSIF trx_status = 'I'
             AND to_char(dist_gl_date, 'DD-MM-YYYY') = '01-01-1900'
             AND ev_match_status = 'I'
             AND to_char(ev_match_gl_date,'DD-MM-YYYY') <> '01-01-1900'
           THEN
             l_change_matrix := '1.23';
           --}

           END IF; --change matrix setup for non postable distributions

     END IF; --distributions cannot be posted

     RETURN(l_change_matrix);

     log('ARP_XLA_EVENTS.Change_Matrix()-');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.dump_bld_rec');
     RAISE;
END Change_Matrix;

/*========================================================================
 | PUBLIC FUNCTION dump_bld_rec
 |
 | DESCRIPTION
 |      Dump build record
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_bld_rec              Build Record
 |      p_i                    Index
 |      p_tag                  table name tag
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE dump_bld_rec(p_bld_rec IN OUT NOCOPY bld_ev_type,
                       p_i       IN BINARY_INTEGER        ,
                       p_tag     IN VARCHAR2                ) IS
BEGIN

   log('ARP_XLA_EVENTS.dump_bld_rec()+');

   IF p_bld_rec.bld_dml_flag.EXISTS(p_i) THEN

      log(p_tag ||'.bld_dml_flag('||p_i||') = '
                                    || p_bld_rec.bld_dml_flag(p_i));
  END IF;

  log('ARP_XLA_EVENTS.dump_bld_rec()-');
  log(' ');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.dump_bld_rec');
     RAISE;

END dump_bld_rec;

/*========================================================================
 | PUBLIC PROCEDURE dump_event_info
 |
 | DESCRIPTION
 |      Dump event info record
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_ev_info_tab          Build Record
 |      p_i                    Index
 |      p_tag                  table name tag
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 *=======================================================================*/
PROCEDURE dump_event_info
  (p_ev_info_tab IN OUT NOCOPY xla_events_pub_pkg.t_array_entity_event_info_s,
   p_i           IN BINARY_INTEGER        ,
   p_tag         IN VARCHAR2                ) IS
BEGIN

   log('ARP_XLA_EVENTS.dump_event_info()+');

   IF p_ev_info_tab.EXISTS(p_i) THEN

      log(p_tag ||'.p_ev_info_tab('||p_i||').event_id = '||
                         p_ev_info_tab(p_i).event_id );

      log(p_tag ||'.p_ev_info_tab('||p_i||').security_id_int_1 = '||
                         TO_CHAR(p_ev_info_tab(p_i).security_id_int_1));

      log(p_tag ||'.p_ev_info_tab('||p_i||').event_date = '||
                         p_ev_info_tab(p_i).event_date );

      log(p_tag ||'.p_ev_info_tab('||p_i||').event_type_code = '||
                         p_ev_info_tab(p_i).event_type_code);

      log(p_tag ||'.p_ev_info_tab('||p_i||').event_status_code = '||
                         p_ev_info_tab(p_i).event_status_code);

      log(p_tag ||'.p_ev_info_tab('||p_i||').transaction_number = '||
                         p_ev_info_tab(p_i).transaction_number );

   END IF;

   log('ARP_XLA_EVENTS.dump_event_info()-');
   log(' ');

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION: ARP_XLA_EVENTS.dump_event_info');
     RAISE;

END dump_event_info;

/*========================================================================
 | PUBLIC FUNCTION delete_event
 |
 | DESCRIPTION
 |   This procedure is a wrapper on the top of XLA delete_event API
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_document_id         document identifier
 |   p_doc_table           CT, APP, CMAPP, CRH, CR, ADJ, TRH
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-JAN-2003           Herve Yu          Create
 *=======================================================================*/
PROCEDURE delete_event( p_document_id  IN NUMBER,
                        p_doc_table    IN VARCHAR2)
IS
  l_event_source_info xla_events_pub_pkg.t_event_source_info;
  l_security          xla_events_pub_pkg.t_security;
  l_event_id          NUMBER;
  /*7229913 */
  l_invoicing_rule_id NUMBER;
  l_document_id       NUMBER;

  /*7229913 */
  CURSOR c_ct_rules is
  select xe.event_id event_id from
  ra_customer_trx ct,
  xla_transaction_entities_upg xte,
  xla_events xe
  where  ct.customer_trx_id  =  p_document_id
  and    ct.invoicing_rule_id in (-2,-3)
  and    ct.set_of_books_id  = xte.ledger_id
  and    nvl(xte.source_id_int_1,-99) = ct.customer_trx_id
  and    xte.entity_code     = 'TRANSACTIONS'
  and    xte.application_id  = 222
  and    xte.entity_id       = xe.entity_id
  and    xe.application_id   = 222
  and    xe.event_status_code  = 'I' ;

  CURSOR c_ct IS
  SELECT event_id
    FROM ra_cust_trx_line_gl_dist
   WHERE customer_trx_id = p_document_id;

  CURSOR c_app IS
  SELECT event_id
    FROM ar_receivable_applications
   WHERE receivable_application_id = p_document_id;

  CURSOR c_adj IS
  SELECT event_id
    FROM ar_adjustments
   WHERE adjustment_id = p_document_id;

  CURSOR c_crh IS
  SELECT event_id
    FROM ar_cash_receipt_history
   WHERE cash_receipt_id = p_document_id;

  CURSOR c_trh IS
  SELECT event_id, customer_trx_id
    FROM ar_transaction_history
   WHERE transaction_history_id = p_document_id;

BEGIN
    log('arp_xla_events.delete_event ()+');

    IF    p_doc_table = 'CT' THEN
      OPEN c_ct;
      FETCH c_ct INTO l_event_id;
      CLOSE c_ct;

     /*7229913*/
    select invoicing_rule_id into l_invoicing_rule_id  from ra_customer_trx
    where customer_trx_id =  p_document_id;

      IF l_invoicing_rule_id in (-2,-3) then
         OPEN c_ct_rules ;
         FETCH c_ct_rules INTO l_event_id;
         CLOSE c_ct_rules;
      END IF;

    ELSIF p_doc_table = 'ADJ' THEN
      OPEN c_adj;
      FETCH c_adj INTO l_event_id;
      CLOSE c_adj;
    ELSIF p_doc_table IN ('APP','CMAPP') THEN
      OPEN c_app;
      FETCH c_app INTO l_event_id;
      CLOSE c_app;
    ELSIF p_doc_table IN ('CR','CRH') THEN
      OPEN c_crh;
      FETCH c_crh INTO l_event_id;
      CLOSE c_crh;
    ELSIF p_doc_table = 'TRH' THEN
      OPEN c_trh;
      FETCH c_trh INTO l_event_id, l_document_id;
      CLOSE c_trh;
    END IF;

    IF l_event_id IS NOT NULL THEN
      l_event_source_info.entity_type_code:= entity_code(p_doc_table => p_doc_table);
      l_security.security_id_int_1        := arp_global.sysparam.org_id;
      l_event_source_info.application_id  := 222;
      l_event_source_info.ledger_id       := arp_standard.sysparm.set_of_books_id; --to be set
      l_event_source_info.source_id_int_1 := NVL(l_document_id, p_document_id);

      xla_events_pub_pkg.delete_event
      ( p_event_source_info => l_event_source_info,
        p_event_id          => l_event_id,
        p_valuation_method  => NULL,
        p_security_context  => l_security);
    END IF;

    log('arp_xla_events.delete_event ()-');
EXCEPTION
  WHEN OTHERS THEN
  log('EXCEPTION: arp_xla_events.delete_event'||SQLERRM);
  RAISE;
END delete_event;


/*========================================================================
 | PUBLIC FUNCTION delete_reverse_revrec_event
 |
 | DESCRIPTION
 |   This procedure is a wrapper on the top of XLA delete_event API.
 |   This procedure is used to delete the events from xla_events
 |   other than the REC event when a transaction with rule is incompleted.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_document_id         document identifier
 |   p_doc_table           CT, APP, CMAPP, CRH, CR, ADJ, TRH
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author             Description of Changes
 | 07-Mar-2008           Bharani Suri        Create
 *=======================================================================*/


PROCEDURE delete_reverse_revrec_event( p_document_id  IN NUMBER,
                                       p_doc_table    IN VARCHAR2)
IS

  l_event_source_info xla_events_pub_pkg.t_event_source_info;
  l_security          xla_events_pub_pkg.t_security;
  l_event_id          NUMBER;


   CURSOR c_ct IS
   SELECT  distinct event_id  event_id
   FROM ra_cust_trx_line_gl_dist gld
   WHERE customer_trx_id = p_document_id
   and  account_set_flag = 'N'
   AND  event_id is not null
   and   EXISTS
         ( select 'x' FROM ra_cust_trx_line_gl_dist gldin
           WHERE customer_trx_id = p_document_id
   	    and account_class='REC'
	    and  latest_rec_flag='Y'
	    AND  event_id IS NOT NULL
	    AND  event_id <> gld.event_id
         );


 BEGIN
    log('arp_xla_events.delete_reverse_revrec_event ()+');

   FOR c IN c_ct loop

      l_event_id  := c.event_id;

      l_event_source_info.entity_type_code:= entity_code(p_doc_table => p_doc_table);
      l_security.security_id_int_1        := arp_global.sysparam.org_id;
      l_event_source_info.application_id  := 222;
      l_event_source_info.ledger_id       := arp_standard.sysparm.set_of_books_id; --to be set
      l_event_source_info.source_id_int_1 := p_document_id;

      xla_events_pub_pkg.delete_event
      ( p_event_source_info => l_event_source_info,
        p_event_id          => l_event_id,
        p_valuation_method  => NULL,
        p_security_context  => l_security);

    END loop;

     log('arp_xla_events.delete_reverse_revrec_event ()-');
EXCEPTION
  WHEN OTHERS THEN
  log('EXCEPTION: arp_xla_events.delete_reverse_revrec_event'||SQLERRM);
  RAISE;
END delete_reverse_revrec_event;


/*========================================================================
 | PUBLIC PROCEDURE ar_xla_period_close
 |
 | DESCRIPTION
 |    Procedure to check any event records in XLA such that either
 |    headers are not transferred to GL, or events are Invalid
 |    or events are Incomplete and they do not belong to any Incomplete
 |    transactions in AR. In all such cases, user will not be allowed to
 |    close the AR Period.
 |    The exception here is if there are Incomplete transactions with
 |    Incomplete Events in XLA, user will be allowed to close the period
 |    and a warning notification will be shown to the user.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      1) p_application_id       IN      NUMBER   -- default 222
 |      2) p_ledger_id            IN      NUMBER
 |      3) p_period_name          IN      VARCHAR2
 |      4) p_cannot_close_period  OUT     BOOLEAN
 |      5) p_incomplete_events    OUT     BOOLEAN
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-JAN-2009           Anshu Kaushal     Created
 *=======================================================================*/


PROCEDURE ar_xla_period_close (p_application_id NUMBER DEFAULT 222,
                               p_ledger_id NUMBER,
                               p_period_name VARCHAR2,
                               p_cannot_close_period OUT NOCOPY BOOLEAN ,
                               p_incomplete_events OUT NOCOPY BOOLEAN )
IS

   -- Declare a record of XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_header%ROWTYPE as we need to fetch a single record
   ar_xla_period_close_header_rec XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_header%ROWTYPE;

   -- Declare a pl/sql table of XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_evt%ROWTYPE as we need to loop through the data
   TYPE ar_xla_period_close_evt_tab IS TABLE OF XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_evt%ROWTYPE
   INDEX BY BINARY_INTEGER;
   l_ar_xla_period_close_evt_tab ar_xla_period_close_evt_tab;

   i NUMBER := 0;
   l_trx_cnt Number := 0;

BEGIN
   log('ARP_XLA_EVENTS.ar_xla_period_close ()+');

   p_cannot_close_period := FALSE;
   p_incomplete_events   := FALSE;

 -- If application security context is not set, then xla cursors will not give data
   xla_security_pkg.set_security_context(p_application_id);

  -- If there are any headers in XLA which are not transferred to GL, user can not close the period
   OPEN xla_period_close_exp_pkg.period_close_cur_header(p_application_id,p_ledger_id,p_period_name);
   FETCH xla_period_close_exp_pkg.period_close_cur_header INTO ar_xla_period_close_header_rec;


   IF xla_period_close_exp_pkg.period_close_cur_header%FOUND THEN
       p_cannot_close_period := TRUE;
       RETURN;
   END IF;
   CLOSE xla_period_close_exp_pkg.period_close_cur_header;

   OPEN   XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_evt(p_application_id,p_ledger_id,p_period_name);
   FETCH  XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_evt BULK COLLECT INTO l_ar_xla_period_close_evt_tab LIMIT MAX_ARRAY_SIZE;
   LOOP
   IF l_ar_xla_period_close_evt_tab.count = 0 THEN
      EXIT;
   END IF;

   FOR i IN l_ar_xla_period_close_evt_tab.FIRST..l_ar_xla_period_close_evt_tab.LAST
   LOOP
   /*If there are Incomplete Events associated to Incomplete Transactions, user should be allowed to
    close the period with a warning issued. */
   IF l_ar_xla_period_close_evt_tab(i).EVENT_STATUS_CODE = 'I'
    AND l_ar_xla_period_close_evt_tab(i).PROCESS_STATUS_CODE = 'U'
    AND l_ar_xla_period_close_evt_tab(i).ENTITY_CODE = 'TRANSACTIONS' THEN
    BEGIN
     SELECT
     count(*) into l_trx_cnt
     FROM ra_customer_trx_all
     WHERE customer_trx_id = l_ar_xla_period_close_evt_tab(i).SOURCE_ID_INT_1 /* The trx id stored in XLA entities table */
     AND org_id = l_ar_xla_period_close_evt_tab(i).SECURITY_ID_INT_1  /* The Org_ID stored in XLA entities table */
     AND complete_flag = 'N'; /* Incomplete Transaction */

     IF l_trx_cnt = 1 THEN
      p_cannot_close_period := FALSE;
      p_incomplete_events   := TRUE;
     ELSE
      p_cannot_close_period := TRUE; /* Since the invoice is either not incomplete or the event is orphaned in XLA */
      EXIT; /* Exit the loop altogeather */
     END IF;

     EXCEPTION
      WHEN OTHERS THEN
      log('OTHERS EXCEPTION: ARP_XLA_EVENTS.ar_xla_period_close');
      RAISE;
     END;

   ELSE  /* Some other period exception raised by XLA hence period cannot be closed*/
     p_cannot_close_period := TRUE;
     EXIT;
   END IF;

   END LOOP;
   IF l_ar_xla_period_close_evt_tab.count < MAX_ARRAY_SIZE THEN
    EXIT;
   END IF;

   END LOOP;
   CLOSE XLA_PERIOD_CLOSE_EXP_PKG.period_close_cur_evt;

   log('ARP_XLA_EVENTS.ar_xla_period_close ()-');
EXCEPTION
   WHEN OTHERS THEN
   log('OTHERS EXCEPTION: ARP_XLA_EVENTS.ar_xla_period_close');
   RAISE;
END ar_xla_period_close;


FUNCTION entity_code( p_doc_table     IN VARCHAR2)
RETURN VARCHAR2
IS
  l_entity_code    VARCHAR2(20);
BEGIN
  IF p_doc_table IN ('CT','CMAPP', 'CTCMAPP','CTNORCM') THEN
     l_entity_code   := 'TRANSACTIONS';

  ELSIF p_doc_table IN ('CRH','APP','CRHMCD','CRHAPP') THEN
     l_entity_code   := 'RECEIPTS';

  ELSIF p_doc_table = 'ADJ' THEN
     l_entity_code   := 'ADJUSTMENTS';

  ELSIF p_doc_table = 'TRH' THEN
    l_entity_code   := 'BILLS_RECEIVABLE';
  END IF;
  RETURN l_entity_code;
END entity_code;

/*
PROCEDURE auto_invoice_events
(p_request_id   IN NUMBER,
 p_code         IN VARCHAR2)
IS
BEGIN
  IF p_code = 'CTADJ'  THEN
     -- arp_xla_events.create_events(p_request_id, 'CT');
     -- arp_xla_events.create_events(p_request_id, 'ADJ');
  ELSE
     -- arp_xla_events.create_events(p_request_id, 'CTCMAPP');
  END IF;

  IF p_code = 'CTADJ'  THEN
    INSERT INTO RA_INTERFACE_ERRORS
     ( interface_line_id,
       message_text,
       org_id )
     select l.interface_line_id,
            xgt.error_msg,
            l.org_id
     from   ra_interface_lines_gt l,
            xla_events_gt         xgt
     where  l.request_id         = p_request_id
     and    l.customer_trx_id    = xgt.source_id_int_1
     and    l.event_id           = -9999
	 and    xgt.event_class_code in ('INV_CREATE','DM_CREATE','CM_CREATE','ADJ_CREATE');
  ELSE
    INSERT INTO RA_INTERFACE_ERRORS
     ( interface_line_id,
       message_text,
       org_id )
     select l.interface_line_id,
            xgt.error_msg,
            l.org_id
     from   ra_interface_lines_gt l,
            xla_events_gt         xgt
     where  l.request_id         = p_request_id
     and    l.customer_trx_id    = xgt.source_id_int_1
     and    l.event_id           = -9999
	 and    xgt.event_class_code in ('CM_CREATE')
	 and    l.interface_line_id NOT IN (SELECT interface_line_id FROM RA_INTERFACE_ERRORS);
  END IF;
END;
*/

END ARP_XLA_EVENTS;

/
