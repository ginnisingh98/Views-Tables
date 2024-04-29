--------------------------------------------------------
--  DDL for Package Body PO_NEGOTIATIONS4_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NEGOTIATIONS4_PVT" AS
/* $Header: POXVNG4B.pls 120.13.12010000.8 2011/11/15 06:56:16 dtoshniw ship $ */

TYPE auction_header_id_tbl_type is TABLE OF
     po_req_split_lines_gt.auction_header_id%type INDEX BY BINARY_INTEGER;
TYPE bid_number_tbl_type is TABLE OF
     po_req_split_lines_gt.bid_number%type INDEX BY BINARY_INTEGER;
TYPE bid_line_number_tbl_type is TABLE OF
     po_req_split_lines_gt.bid_line_number%type INDEX BY BINARY_INTEGER;
TYPE requisition_header_id_tbl_type is TABLE OF
     po_req_split_lines_gt.requisition_header_id%type INDEX BY BINARY_INTEGER;
TYPE requisition_line_id_tbl_type is TABLE OF
     po_req_split_lines_gt.requisition_line_id%type INDEX BY BINARY_INTEGER;
TYPE allocated_qty_tbl_type is TABLE OF
     po_req_split_lines_gt.allocated_qty%type INDEX BY BINARY_INTEGER;
TYPE new_req_line_id_tbl_type is TABLE OF
     po_req_split_lines_gt.new_req_line_id%type INDEX BY BINARY_INTEGER;
TYPE new_line_num_tbl_type is TABLE OF
     po_req_split_lines_gt.new_line_num%type INDEX BY BINARY_INTEGER;
TYPE totallc_req_line_qty_tbl_type is TABLE OF
   po_req_split_lines_gt.total_alloc_req_line_qty%type INDEX BY BINARY_INTEGER;
TYPE requisition_line_qty_tbl_type is TABLE OF
     po_req_split_lines_gt.requisition_line_qty%type INDEX BY BINARY_INTEGER;
TYPE min_bid_number_tbl_type is TABLE OF
     po_req_split_lines_gt.min_bid_number%type INDEX BY BINARY_INTEGER;
TYPE record_status_tbl_type is TABLE OF
     po_req_split_lines_gt.record_status%type INDEX BY BINARY_INTEGER;
TYPE row_id_tbl_type is TABLE OF rowid INDEX BY BINARY_INTEGER;
TYPE min_dist_id_tbl_type is TABLE OF
     po_req_distributions.distribution_id%type INDEX BY BINARY_INTEGER;
TYPE org_id_tbl_type is TABLE OF
     po_headers.org_id%type INDEX BY BINARY_INTEGER;
TYPE round_tax_tbl_type is TABLE OF
     po_req_distributions.recoverable_tax%type INDEX BY BINARY_INTEGER;
-- Bug 4723367 START
TYPE encumbrance_flag_tbl_type is TABLE OF
     financials_system_parameters.req_encumbrance_flag%type
     INDEX BY BINARY_INTEGER;
-- Bug 4723367 END

G_PKG_NAME CONSTANT varchar2(30) := 'PO_NEGOTIATIONS4_PVT';
G_MODULE_PREFIX CONSTANT VARCHAR2(60) := 'po.plsql.' || G_PKG_NAME || '.';
G_FND_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_FND_DEBUG_LEVEL VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_LEVEL'),'0');

PROCEDURE Print_Global_Table(p_module IN VARCHAR2) IS
  requisition_header_id_dbg_tbl   requisition_header_id_tbl_type;
  requisition_line_id_dbg_tbl   requisition_line_id_tbl_type;
  bid_number_dbg_tbl      bid_number_tbl_type;
  bid_line_number_dbg_tbl   bid_line_number_tbl_type;
  allocated_qty_dbg_tbl     allocated_qty_tbl_type;
  requisition_line_qty_dbg_tbl    requisition_line_qty_tbl_type;
  auction_header_id_dbg_tbl   auction_header_id_tbl_type;
  new_req_line_id_dbg_tbl   new_req_line_id_tbl_type;
  new_line_num_dbg_tbl      new_line_num_tbl_type;
  totalloc_req_line_qty_dbg_tbl   totallc_req_line_qty_tbl_type;
  min_bid_number_dbg_tbl    min_bid_number_tbl_type;
  record_status_dbg_tbl     record_status_tbl_type;


BEGIN

  SELECT prs.requisition_header_id,
         prs.requisition_line_id,
         prs.auction_header_id,
         prs.bid_number,
         prs.bid_line_number,
         prs.allocated_qty,
     prs.requisition_line_qty,
     prs.new_req_line_id,
     prs.new_line_num,
     prs.total_alloc_req_line_qty,
     prs.min_bid_number,
     prs.record_status
    BULK COLLECT INTO
         requisition_header_id_dbg_tbl,
         requisition_line_id_dbg_tbl,
   auction_header_id_dbg_tbl,
         bid_number_dbg_tbl,
         bid_line_number_dbg_tbl,
         allocated_qty_dbg_tbl,
     requisition_line_qty_dbg_tbl,
     new_req_line_id_dbg_tbl,
     new_line_num_dbg_tbl,
     totalloc_req_line_qty_dbg_tbl,
     min_bid_number_dbg_tbl,
     record_status_dbg_tbl
    FROM po_req_split_lines_gt prs
   ORDER BY prs.requisition_header_id,prs.requisition_line_id;

  FOR l_dbg_index in 1.. requisition_line_id_dbg_tbl.COUNT loop
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, p_module,
                 'auction_header_id:'||to_char(auction_header_id_dbg_tbl(l_dbg_index))||','
     ||'bid_number:'||to_char(bid_number_dbg_tbl(l_dbg_index))||','
     ||'bid_line_number:'||to_char(bid_line_number_dbg_tbl(l_dbg_index))||','
     ||'requisition_header_id:'||to_char(requisition_header_id_dbg_tbl(l_dbg_index))||','
     ||'requisition_line_id:'||to_char(requisition_line_id_dbg_tbl(l_dbg_index))||','
     ||'allocated_qty:'||to_char(allocated_qty_dbg_tbl(l_dbg_index))||','
     ||'requisition_line_qty:'||to_char(requisition_line_qty_dbg_tbl(l_dbg_index))||','
     ||'new_req_line_id:'||to_char(new_req_line_id_dbg_tbl(l_dbg_index))||','
     ||'new_line_num:'||to_char(new_line_num_dbg_tbl(l_dbg_index))||','
     ||'total_alloc_req_line_qty:'||to_char(totalloc_req_line_qty_dbg_tbl(l_dbg_index))||','
     ||'min_bid_number:'||to_char(min_bid_number_dbg_tbl(l_dbg_index))||','
     ||'record_status:'||record_status_dbg_tbl(l_dbg_index));
  END IF;
  END LOOP;
END;

/**
 * Private Procedure: Split_RequisitionLines
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: Inserts new req lines and their distributions, For parent
 *   req lines, update requisition_lines table to modified_by_agent_flag='Y'.
 *   Also sets prevent encumbrace flag to 'Y' in the po_req_distributions table.
 * Effects: This api split the requisition lines, if needed, depending on the
 *   allocation done by the sourcing user. This api uses a global temp. table
 *   to massage the input given by sourcing and inserts records into
 *   po_requisition_lines_all and po_req_distributions_all table. This api also
 *   handles the encumbrace effect of splitting requisition lines. This api would
 *   be called from ORacle sourcing workflow.
 *
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if action succeeds
 *                     FND_API.G_RET_STS_ERROR if  action fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *                     x_msg_count returns count of messages in the stack.
 *                     x_msg_data returns message only if 1 message.
 *
 * Possible values for PO_REQ_SPLIT_LINES_GT.record_status:
 *   'S' - Split;
 *   'N' - New Line(for the remainder which will go back to pool);
 *   'C' - Cancelled, finally closed, withdrawn, and Req lines with 0 quantity;
 *   'E' - Equal Allocation;
 *   'I' - No Allocation;
 *   'T' - Line type with value basis 'RATE' and 'FIXED PRICE'
 *
 */

PROCEDURE Split_RequisitionLines
(   p_api_version   IN    NUMBER          ,
    p_init_msg_list   IN        VARCHAR2  :=FND_API.G_FALSE ,
    p_commit      IN        VARCHAR2  :=FND_API.G_FALSE ,
    x_return_status   OUT NOCOPY    VARCHAR2          ,
    x_msg_count     OUT NOCOPY    NUMBER              ,
    x_msg_data      OUT NOCOPY    VARCHAR2        ,
    p_auction_header_id   IN      NUMBER
)
IS

 l_api_name             CONSTANT varchar2(30) := 'SPLIT_REQUISITIONLINES';
 l_log_head             CONSTANT VARCHAR2(100) :=  G_MODULE_PREFIX||l_api_name;
 l_api_version          CONSTANT NUMBER       := 1.0;

 l_module               VARCHAR2(100);
 l_progress     VARCHAR2(3);

 requisition_line_id_tbl requisition_line_id_tbl_type;
 min_bid_number_tbl min_bid_number_tbl_type;
 total_alloc_req_line_qty_tbl totallc_req_line_qty_tbl_type;



 --declare the result tables.
 auction_header_id_rslt_tbl  auction_header_id_tbl_type;
 bid_number_rslt_tbl  bid_number_tbl_type;
 bid_line_number_rslt_tbl  bid_line_number_tbl_type;
 requisition_header_id_rslt_tbl  requisition_header_id_tbl_type;
 requisition_line_id_rslt_tbl  requisition_line_id_tbl_type;
 allocated_qty_rslt_tbl  allocated_qty_tbl_type;
 new_req_line_id_rslt_tbl  new_req_line_id_tbl_type;
 new_line_num_rslt_tbl  new_line_num_tbl_type;
 totallc_req_line_qty_rslt_tbl  totallc_req_line_qty_tbl_type;
 requisition_line_qty_rslt_tbl  requisition_line_qty_tbl_type;
 min_bid_number_rslt_tbl  min_bid_number_tbl_type;
 record_status_rslt_tbl  record_status_tbl_type;
 encumbrance_flag_rslt_tbl  encumbrance_flag_tbl_type; -- Bug 4723367

 --define table type variables for requisition line num calculation.
 requisition_header_id_lnm_tbl requisition_header_id_tbl_type;
 requisition_line_id_lnm_tbl requisition_line_id_tbl_type;
 bid_number_lnm_tbl bid_number_tbl_type;
 bid_line_number_lnm_tbl bid_line_number_tbl_type;
 new_line_num_lnm_tbl new_line_num_tbl_type;
 row_id_lnm_tbl row_id_tbl_type;

 --define table type variables for distribution qty rounding.
 req_line_id_round_tbl new_line_num_tbl_type;
 min_dist_id_round_tbl min_dist_id_tbl_type;
 sum_req_line_qty_round_tbl allocated_qty_tbl_type;
 req_line_qty_round_tbl requisition_line_qty_tbl_type;

 l_return_status VARCHAR2(1);
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(2000);

 -- SQL What:This cursor Locks the requisition lines the api is going to process
 -- SQL Why :This locking ensures that the records are not touched by any other
 --          transactions.Opening the cursor keeps the records locked till the
 --          transaction control happens.
 CURSOR LockReqLines_Cursor IS
 SELECT prl.requisition_line_id,quantity
   FROM po_requisition_lines_all prl, --<Sourcing 11.5.10+>
        po_req_split_lines_gt prs
  WHERE prl.requisition_line_id = prs.requisition_line_id
    FOR UPDATE OF prl.quantity NOWAIT;

 old_requisition_header_id po_req_split_lines_gt.requisition_header_id%type:=0;
 l_serial_num number;
 l_line_num_index number;
 l_req_encumbrance_flag financials_system_parameters.req_encumbrance_flag%type;

 -- <FPI JFMIP Req Split>
 l_online_report_id PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;

 --<Sourcing 11.5.10+> Define variables needed for context switching
 l_old_line_requesting_ou_id PO_REQUISITION_LINES_ALL.org_id%TYPE;
 l_line_requesting_ou_id     PO_REQUISITION_LINES_ALL.org_id%TYPE;
 l_current_ou_id             PO_REQUISITION_LINES_ALL.org_id%TYPE;
 l_org_context_changed       VARCHAR2(1) := 'N';

 -- bug 5249299 <variable addition START>
 l_project_id		 po_req_distributions_all.project_id%TYPE;
 l_task_id		 po_req_distributions_all.task_id%TYPE;
 l_award_id		 po_req_distributions_all.award_id%TYPE;
 l_expenditure_type	 po_req_distributions_all.expenditure_type%TYPE;
 l_expenditure_item_date  po_req_distributions_all.expenditure_item_date%TYPE;
 l_distribution_id        po_req_distributions_all.distribution_id%TYPE;
 l_award_set_id           po_req_distributions_all.award_id%TYPE;
 l_status		 VARCHAR2(1);

 CURSOR l_req_dist_proj_csr(l_req_line_id number) IS
 SELECT distribution_id,
        project_id,
        task_id,
        award_id,
        expenditure_type,
        expenditure_item_date
 FROM  po_req_distributions_all
 WHERE requisition_line_id = l_req_line_id;

 l_req_dist_proj_rec l_req_dist_proj_csr%ROWTYPE;
 -- bug 5249299 <variable addition END>

 --<R12 eTax Integration> Cursor to find requisition_header_id's of all
 -- requisition lines being processed
 CURSOR req_header_id_csr IS
 SELECT DISTINCT prs.requisition_header_id
 FROM po_req_split_lines_gt prs;

 l_recrt_req_bal             VARCHAR2(1); -- <Bug 6962281>

BEGIN

  l_progress :='000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'000'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Entering');
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
           'Entering ' || G_PKG_NAME || '.' || l_api_name);
  END IF;

  SAVEPOINT Split_RequisitionLines_PVT;

  l_progress :='010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'010'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Compatible_API_Call ');
  END IF;

  IF NOT FND_API.Compatible_API_Call
         (
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME
       )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  l_progress :='020';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'020'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'OPEN LockReqLines_Cursor ');
  END IF;
  -- Lock the requisition lines the api is going to process
  OPEN LockReqLines_Cursor;
       NULL;
  CLOSE LockReqLines_Cursor;



  -- SQL What:update the temp table with requisition line quantity and
  --          mark the lines which have been cancelled
  -- SQL Why :Requsition line quantity is required later in the process.
  --          especially to help bulk processing.
  BEGIN

    l_progress :='030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'030'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'before update po_req_split_lines_gt for quantity and
                    status ');
    END IF;

    --bug# 2729465 mark finally closed lines also with a status 'C'
    --Code impact is minimal when all these lines to be discarded are marked
    --with a single status.
    --Also removed an unnecessary join using requisition_header_id
    UPDATE po_req_split_lines_gt prs
       SET (prs.requisition_line_qty,
            prs.record_status)=
              (SELECT quantity,
         --decode(cancel_flag,'Y','C',null)
               decode(cancel_flag,'Y','C',decode(closed_code,'FINALLY CLOSED',
     'C',NULL))
                 FROM po_requisition_lines_all prl --<Sourcing 11.5.10+>
                WHERE prl.requisition_line_id=prs.requisition_line_id
        );

    l_progress :='031';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'031'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'after update po_req_split_lines_gt for quantity and
        status; updated '||sql%rowcount||' rows');
    END IF;


  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
                           l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                  'Exception: update po_req_split_lines_gt for
             quantity and status ');
   END IF;
   RAISE;

  END;

  --do the dump of input values if the log level is statement.
  l_progress :='032';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'032'||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL=FND_LOG.LEVEL_STATEMENT THEN
    Print_Global_Table(l_module);
  END IF;

  --<BEGIN bug# 2729465> withdrawn lines also with a status 'C'
  --Code impact is minimal when all these lines to be discarded are marked
  --with a single status.
  BEGIN

    l_progress :='035';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'035'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'before update po_req_split_lines_gt for withdrawn lines');
    END IF;

    -- SQL What:update the withdrawn lines in the temp table as 'C'
    -- SQL Why :These lines are not processed.
    UPDATE po_req_split_lines_gt prs
       SET prs.record_status='C'
     WHERE NOT EXISTS
     (SELECT requisition_line_id
        FROM po_requisition_lines_all prl --<Sourcing 11.5.10+>
       WHERE prl.requisition_line_id= prs.requisition_line_id
     );

    l_progress :='036';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'036'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'after update po_req_split_lines_gt for withdrawn lines;
        updated '||sql%rowcount||' rows');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
                           l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                  'Exception: update po_req_split_lines_gt for
             withdrawn lines ');
   END IF;
   RAISE;

  END;
  --<END bug# 2729465>


  -- <SERVICES FPJ START> Mark all Services Lines with a status of 'T'.
  -- ( These lines are bypassed during the split, but will still be considered
  --   during the bid association. )
  --
  BEGIN

    l_progress :='037';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'037'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'before update po_req_split_lines_gt for Services lines');
    END IF;

    -- SQL What: Update Services Lines in the Global Temp Table as 'T'.
    -- SQL Why : Services Lines are bypassed during the splitting.
    --
    UPDATE po_req_split_lines_gt PRS
    SET    ( PRS.record_status
           , PRS.new_req_line_id ) = ( SELECT 'T'
                                       ,      PRL.requisition_line_id
                                       FROM   po_requisition_lines_all PRL
                                       ,      po_line_types_b          PLT
                                       WHERE  PRL.requisition_line_id = PRS.requisition_line_id
                                       AND    PRL.line_type_id = PLT.line_type_id
                                       AND    PLT.order_type_lookup_code IN ('RATE','FIXED PRICE')
                                     )
    -- Bug 3345861: without the following WHERE clause, lines with record_status 'C'
    -- will be overwritten
    WHERE nvl(PRS.record_status, 'NOVAL') <> 'C';

    l_progress :='038';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'038'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'after update po_req_split_lines_gt for Services lines;
        updated '||sql%rowcount||' rows');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
        po_message_s.sql_error('Exception of Split_requisitionLines()', l_progress , sqlcode);
        FND_MSG_PUB.Add;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module, 'Exception: update po_req_split_lines_gt for Services lines');
        END IF;
        RAISE;

  END;
  -- <SERVICES FPJ END>


  BEGIN

    l_progress :='040';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'040'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'before select sum of allocated_qty and min of bid_number
       ');
    END IF;

    -- SQL What: Select to populate the temp table with total allocated qty for
    --           a requisition line and the minimum bid number
    --           ( Do not include Services Lines ).           -- <SERVICES FPJ>
    -- SQL Why : This is required later in the process.
    --           especially to help bulk processing.
    --Bug#2728152 added nvl around sum(allocated_qty)
    SELECT requisition_line_id,nvl(sum(allocated_qty),0),min(bid_number)
      BULK COLLECT INTO
           requisition_line_id_tbl,
           total_alloc_req_line_qty_tbl,
           min_bid_number_tbl
      FROM po_req_split_lines_gt
     WHERE nvl(record_status,'NOVAL') NOT IN ('C','T')        -- <SERVICES FPJ>
     GROUP BY requisition_line_id;

    l_progress :='041';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'041'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'after select sum of allocated_qty and min of bid_number;
        selected '||requisition_line_id_tbl.COUNT||' rows');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
               l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
            'Exception: select sum of allocated_qty and min of
             bid_number ');
   END IF;

   RAISE;

  END;


  BEGIN

    l_progress :='050';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'050'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'before updating po_req_split_lines_gt with sum of
        allocated_qty and min of bid_number etc..
       ');
    END IF;

    -- SQL What:Populate the temp table with total allocated qty for a
    --          requisition line and the minimum bid number
    -- SQL Why :This is required later in the process.
    --          especially to help bulk processing.

    FORALL qty_rollup_index in 1.. requisition_line_id_tbl.COUNT
    UPDATE po_req_split_lines_gt
       SET min_bid_number= min_bid_number_tbl(qty_rollup_index),
           total_alloc_req_line_qty=
             total_alloc_req_line_qty_tbl(qty_rollup_index),
           record_status =decode(nvl(allocated_qty,0),requisition_line_qty,
       'E',0,'I',
             -- Bug 3345861: Do not split lines where requisition_line_qty is 0
             -- Assign 'C' as the record_status to such lines
             decode(requisition_line_qty, 0, 'C', 'S')),
           new_req_line_id=decode(nvl(allocated_qty,0),requisition_line_qty,
       requisition_line_id,0,null,po_requisition_lines_s.nextval)
     WHERE requisition_line_id = requisition_line_id_tbl(qty_rollup_index);

    l_progress :='051';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'050'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'after updating po_req_split_lines_gt with sum of
        allocated_qty and min of bid_number etc..; updated '
        || sql%rowcount ||' rows');
    END IF;


  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
                           l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
          'Exception: updating po_req_split_lines_gt with sum of
           allocated_qty and min of bid_number etc.. ');
   END IF;
   RAISE;

  END;


  BEGIN

    l_progress :='060';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'060'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'before inserting remainder req lines into
        po_req_split_lines_gt ');
    END IF;

    -- <Bug 6962281>
    -- Get the value of profile PO_RECRT_POST_AWRD_AMT_REQ_BAL, i.e.
    -- "PO: Recreate Post Award Amount Based Req Line Balance"
    FND_PROFILE.get('PO_RECRT_POST_AWRD_AMT_REQ_BAL', l_recrt_req_bal);

    -- SQL What: Make entry for the new remainder req lines in the temp table
    --           ( which are not consumed or Services Lines )
    -- SQL Why : These rows stand for the remainder req lines to be created
    --           in the po_requisition_lines_all table.
    -- <Bug 6962281>
    -- For Amount based lines, new req line should be created only if profile
    -- PO_RECRT_POST_AWRD_AMT_REQ_BAL value is Y.
    -- Added join conditions with tables po_requisition_lines_all and
    -- po_line_types_b.
    INSERT INTO po_req_split_lines_gt
       ( auction_header_id,
         bid_number,
         bid_line_number,
         requisition_header_id,
         requisition_line_id,
         allocated_qty,
         new_req_line_id,
         total_alloc_req_line_qty,
         requisition_line_qty,
         min_bid_number,
         record_status
        )
    SELECT prsl.auction_header_id,
           NULL,
           prsl.bid_line_number,
           prsl.requisition_header_id,
           prsl.requisition_line_id,
           (prsl.requisition_line_qty - prsl.total_alloc_req_line_qty),
           po_requisition_lines_s.nextval,
           NULL,
           prsl.requisition_line_qty,
           NULL,
           'N'
      FROM po_req_split_lines_gt prsl,
           po_requisition_lines_all prl,
           po_line_types_b plt
     WHERE prsl.total_alloc_req_line_qty < prsl.requisition_line_qty
       AND prsl.record_status NOT IN ('I','T')                     -- <SERVICES FPJ>
       AND prsl.bid_number = prsl.min_bid_number
       AND prsl.requisition_line_id = prl.requisition_line_id
       AND prl.line_type_id = plt.line_type_id
       AND DECODE(plt.order_type_lookup_code,
                  'AMOUNT', l_recrt_req_bal,
                  'Y') = 'Y';

    l_progress :='061';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'060'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'after inserting remainder req lines into
        po_req_split_lines_gt inserted '||sql%rowcount||' rows');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
             l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                  'Exception: inserting remainder req lines into
             po_req_split_lines_gt ');
   END IF;
   RAISE;
  END;


  BEGIN

    l_progress :='070';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'070'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'before stamping bid info for equal allocation ');
    END IF;

    -- SQL What:update the po_requisition_lines_all table to stamp bid info for
    --          lines with Equal allocation (include Services Lines)
    -- SQL Why :We need this update only for equal award. For other cases
    --          we pass in the bid info through the insert statement.
    UPDATE po_requisition_lines_all prl --<Sourcing 11.5.10+>
       SET (bid_number,
            bid_line_number)=
     (SELECT prs.bid_number,
             prs.bid_line_number
        FROM po_req_split_lines_gt prs
       WHERE prl.requisition_line_id=prs.requisition_line_id
         AND prs.record_status IN ('E','T')                 -- <SERVICES FPJ>
     )
     WHERE prl.requisition_line_id in
     (SELECT prs1.requisition_line_id
        FROM po_req_split_lines_gt prs1
       WHERE prs1.record_status IN ('E','T') );             -- <SERVICES FPJ>

    l_progress :='071';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'071'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
      'before stamping bid info for equal allocation updated'
       || sql%rowcount||' requisition lines ');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
   po_message_s.sql_error('Exception of Split_requisitionLines()',
             l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
            'Exception: stamping bid info for equal allocation
      ');
   END IF;
   RAISE;

  END;


  BEGIN

    l_progress :='080';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'080'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'before updating po_req_split_lines_gt with max linenum');
    END IF;

    --SQL What:update the temp table with the max line number for each
    --         requisition_header_id
    --SQL Why :This is required to calculate the line numbers when creating
    --         the new requisition lines
    UPDATE po_req_split_lines_gt prs
       SET prs.new_line_num=
     (SELECT max(prl.line_num)
        FROM po_requisition_lines_all prl --<Sourcing 11.5.10+>
             WHERE prl.requisition_header_id=prs.requisition_header_id)
     WHERE prs.record_status in ('S','N');

    l_progress :='081';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'081'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
             'after updating po_req_split_lines_gt with max linenum;
        Updated '|| sql%rowcount||' rows ');
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
         po_message_s.sql_error('Exception of Split_requisitionLines()',
                           l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                  'Exception: updating po_req_split_lines_gt with max
             line num');
   END IF;
   RAISE;

  END;


  BEGIN

    l_progress :='090';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'090'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'before selecting rowid and new_line_num to memory ');
    END IF;

    -- SQL What:Add incremental numbers to the new_line_num resetting at
    --      requisition_header_id level
    -- SQL Why :This is required to calculate the line numbers when creating
    --          the new requisition lines. We already have max(line_num) in
    --          new_line_num column. Add incremental numbers to make the
    --          new_line_num unique.
    --          We could not achieve this through a single update as more
    --          than one new requisition lines could have the same
    --          requisition_line_id as its parent.
    SELECT prs.requisition_header_id,
           prs.requisition_line_id,
           prs.bid_number,
           prs.bid_line_number,
           prs.new_line_num,
         prs.rowid
      BULK COLLECT INTO
           requisition_header_id_lnm_tbl,
           requisition_line_id_lnm_tbl,
           bid_number_lnm_tbl,
           bid_line_number_lnm_tbl,
           new_line_num_lnm_tbl,
         row_id_lnm_tbl
      FROM po_req_split_lines_gt prs
     WHERE prs.record_status in ('S','N')
     ORDER BY prs.requisition_header_id,prs.requisition_line_id;

    l_progress :='091';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'091'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                  'after selecting rowid and new_line_num to memory;
       selected '||row_id_lnm_tbl.COUNT||' rows');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

         po_message_s.sql_error('Exception of Split_requisitionLines()',
               l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
            'Exception: selecting rowid and new_line_num to memory '
      );
   END IF;
   RAISE;

  END;


  BEGIN

    l_progress :='100';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'100'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       'before loop: Assign incremental numbers to line num  ');
    END IF;

    FOR l_line_num_index in 1.. requisition_line_id_lnm_tbl.COUNT
        LOOP

    IF requisition_header_id_lnm_tbl(l_line_num_index)
         <>old_requisition_header_id
    THEN
             l_serial_num :=1;
    ELSE
             l_serial_num:=l_serial_num+1;
    END IF;

          new_line_num_lnm_tbl(l_line_num_index)
      :=new_line_num_lnm_tbl(l_line_num_index)+l_serial_num;

          l_progress :='105';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'105'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                  'Inside loop: Requisition_header_id = '
      ||requisition_header_id_lnm_tbl(l_line_num_index)
      ||'Requisition_line_id = '
      ||requisition_line_id_lnm_tbl(l_line_num_index)
      ||'New line num = '
      ||new_line_num_lnm_tbl(l_line_num_index));
    END IF;

    old_requisition_header_id:=
      requisition_header_id_lnm_tbl(l_line_num_index);

        END LOOP;

        l_progress :='109';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'109'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
          'After loop: Assign incremental numbers to line num  ');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

         po_message_s.sql_error('Exception of Split_requisitionLines()',
                           l_progress , sqlcode);
   FND_MSG_PUB.Add;
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
     FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                 'Exception: Assign incremental numbers to line num  ');
   END IF;
   RAISE;
  END;


        BEGIN

          l_progress :='110';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'110'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: update po_req_split_lines_gt toset new_line_num');
    END IF;

          FORALL l_line_num_upd_index in 1.. requisition_line_id_lnm_tbl.COUNT
          UPDATE po_req_split_lines_gt
       SET new_line_num=new_line_num_lnm_tbl(l_line_num_upd_index)
     WHERE rowid=row_id_lnm_tbl(l_line_num_upd_index);
          l_progress :='111';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'110'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
          'After: update po_req_split_lines_gt toset new_line_num;
           Updated '||sql%rowcount||' rows');
    END IF;

        EXCEPTION
    WHEN OTHERS THEN

         po_message_s.sql_error('Exception of Split_requisitionLines()',
           l_progress , sqlcode);
         FND_MSG_PUB.Add;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
                 'Exception: update po_req_split_lines_gt to set
            new_line_num');
         END IF;
         RAISE;

  END;


        -- SQL What:Bulk collect all the requisition lines which are eligible
        --      to be split,which are record_status in ('S','N').
        -- SQL Why :proceed only if there is at least one requisition line to
  --      be split and it also helped to merged multiple DMLs.
  BEGIN

        l_progress :='120';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'120'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Collect all the req lines which are eligible to split ');
    Print_Global_Table(l_module);
  END IF;

  SELECT prs.auction_header_id,
         prs.bid_number,
         prs.bid_line_number,
         prs.requisition_header_id,
         prs.requisition_line_id,
         prs.allocated_qty,
         prs.new_req_line_id,
         prs.new_line_num,
         prs.total_alloc_req_line_qty,
         prs.requisition_line_qty,
         prs.min_bid_number,
         prs.record_status,
         NVL(fsp.req_encumbrance_flag, 'N') -- Bug 4723367
  BULK COLLECT INTO
         auction_header_id_rslt_tbl,
         bid_number_rslt_tbl,
         bid_line_number_rslt_tbl,
         requisition_header_id_rslt_tbl,
         requisition_line_id_rslt_tbl,
         allocated_qty_rslt_tbl,
         new_req_line_id_rslt_tbl,
         new_line_num_rslt_tbl,
         totallc_req_line_qty_rslt_tbl,
         requisition_line_qty_rslt_tbl,
         min_bid_number_rslt_tbl,
         record_status_rslt_tbl,
         encumbrance_flag_rslt_tbl -- Bug 4723367
    FROM po_req_split_lines_gt prs,
         po_requisition_lines_all prl, --<Sourcing 11.5.10+>
         financials_system_parameters fsp -- Bug 4723367
         -- Bug 5467617: Removed the joins to PO_VENDORS and PO_VENDOR_SITES_ALL
         -- These are not required anymore because they we used to fetch the
         -- rounding rule from the site level. Now the tax rounding is done by
         -- recalculating the tax at the end of this flow.
   WHERE record_status in ('S','N')
     AND prs.requisition_line_id = prl.requisition_line_id
     AND nvl(prl.org_id, -99) = nvl(fsp.org_id, -99); -- Bug 4723367

        l_progress :='121';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'121'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Collect all the req lines which are eligible to ' ||
         'split; Selected '||requisition_line_id_rslt_tbl.COUNT
          ||' rows');
  END IF;

        EXCEPTION
    WHEN OTHERS THEN

         po_message_s.sql_error('Exception of Split_requisitionLines()',
         l_progress , sqlcode);
         FND_MSG_PUB.Add;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
           FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
         'Exception: Collect all the req lines which are eligible to split ');
         END IF;
         RAISE;

  END;


         IF requisition_line_id_rslt_tbl.COUNT >= 1 THEN
      --Create new requisition lines
      -- <SERVICES FPJ>
      -- Added order_type_lookup_code, purchase_basis and matching_basis
      BEGIN

            l_progress :='130';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'130'||'.';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Create all the new requisition lines ');
      END IF;

      FORALL l_insert_line_index IN
       1.. requisition_line_id_rslt_tbl.COUNT
      INSERT INTO po_requisition_lines_all  --<Sourcing 11.5.10+>
                   (
                   requisition_line_id,
                   requisition_header_id,
                   line_num,
                   line_type_id,
                   category_id,
                   item_description,
                   unit_meas_lookup_code,
                   unit_price,
                   quantity,
                   deliver_to_location_id,
                   to_person_id,
                   last_update_date,
                   last_updated_by,
                   source_type_code,
                   last_update_login,
                   creation_date,
                   created_by,
                   item_id,
                   item_revision,
                   quantity_delivered,
                   suggested_buyer_id,
                   encumbered_flag,
                   rfq_required_flag,
                   need_by_date,
                   line_location_id,
                   modified_by_agent_flag,
                   parent_req_line_id,
                   justification,
                   note_to_agent,
                   note_to_receiver,
                   purchasing_agent_id,
                   document_type_code,
                   blanket_po_header_id,
                   blanket_po_line_num,
                   currency_code,
                   rate_type,
                   rate_date,
                   rate,
                   currency_unit_price,
                   suggested_vendor_name,
                   suggested_vendor_location,
                   suggested_vendor_contact,
                   suggested_vendor_phone,
                   suggested_vendor_product_code,
                   un_number_id,
                   hazard_class_id,
                   must_use_sugg_vendor_flag,
                   reference_num,
                   on_rfq_flag,
                   urgent_flag,
                   cancel_flag,
                   source_organization_id,
                   source_subinventory,
                   destination_type_code,
                   destination_organization_id,
                   destination_subinventory,
                   quantity_cancelled,
                   cancel_date,
                   cancel_reason,
                   closed_code,
                   agent_return_note,
                   changed_after_research_flag,
                   vendor_id,
                   vendor_site_id,
                   vendor_contact_id,
                   research_agent_id,
                   on_line_flag,
                   wip_entity_id,
                   wip_line_id,
                   wip_repetitive_schedule_id,
                   wip_operation_seq_num,
                   wip_resource_seq_num,
                   attribute_category,
                   destination_context,
                   inventory_source_context,
                   vendor_source_context,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   bom_resource_id,
                   government_context,
                   closed_reason,
                   closed_date,
                   transaction_reason_code,
                   quantity_received,
                 tax_code_id,
                 tax_user_override_flag,
                 oke_contract_header_id,
                 oke_contract_version_id,
                   secondary_unit_of_measure,
                   secondary_quantity,
                   preferred_grade,
                 secondary_quantity_received,
                 secondary_quantity_cancelled,
                 auction_header_id,
                 auction_display_number,
                 auction_line_number,
                 reqs_in_pool_flag,
                 vmi_flag,
             bid_number,
             bid_line_number,
                   order_type_lookup_code,
                   purchase_basis,
                   matching_basis,
                   org_id, --<Sourcing 11.5.10+>
                   tax_attribute_update_code --<R12 eTax Integration>
                   )
            SELECT new_req_line_id_rslt_tbl(l_insert_line_index),
                   prl.requisition_header_id,
                   new_line_num_rslt_tbl(l_insert_line_index),
                   prl.line_type_id,
                   prl.category_id,
                   prl.item_description,
                   prl.unit_meas_lookup_code,
                   prl.unit_price,
                   allocated_qty_rslt_tbl(l_insert_line_index),
                   prl.deliver_to_location_id,
                   prl.to_person_id,
                   prl.last_update_date,
                   prl.last_updated_by,
                   prl.source_type_code,
                   prl.last_update_login,
                   prl.creation_date,
                   prl.created_by,
                   prl.item_id,
                   prl.item_revision,
                   prl.quantity_delivered,
                   prl.suggested_buyer_id,
                   prl.encumbered_flag,
                   prl.rfq_required_flag,
                   prl.need_by_date,
                   prl.line_location_id,
                   prl.modified_by_agent_flag,
                   prl.requisition_line_id,
/* Bug 13387472: parent_req_line_id of the new req line created should be requisition line id of the
                 original req line. It was wrongly assigned as prl.parent_req_line_id. */

                   prl.justification,
                   prl.note_to_agent,
                   prl.note_to_receiver,
                   prl.purchasing_agent_id,
                   prl.document_type_code,
                   prl.blanket_po_header_id,
                   prl.blanket_po_line_num,
                   prl.currency_code,
                   prl.rate_type,
                   prl.rate_date,
                   prl.rate,
                   prl.currency_unit_price,
                   prl.suggested_vendor_name,
                   prl.suggested_vendor_location,
                   prl.suggested_vendor_contact,
                   prl.suggested_vendor_phone,
                   prl.suggested_vendor_product_code,
                   prl.un_number_id,
                   prl.hazard_class_id,
                   prl.must_use_sugg_vendor_flag,
                   prl.reference_num,
                   prl.on_rfq_flag,
                   prl.urgent_flag,
                   prl.cancel_flag,
                   prl.source_organization_id,
                   prl.source_subinventory,
                   prl.destination_type_code,
                   prl.destination_organization_id,
                   prl.destination_subinventory,
                   prl.quantity_cancelled,
                   prl.cancel_date,
                   prl.cancel_reason,
                   prl.closed_code,
                   prl.agent_return_note,
                   prl.changed_after_research_flag,
                   prl.vendor_id,
                   prl.vendor_site_id,
                   prl.vendor_contact_id,
                   prl.research_agent_id,
                   prl.on_line_flag,
                   prl.wip_entity_id,
                   prl.wip_line_id,
                   prl.wip_repetitive_schedule_id,
                   prl.wip_operation_seq_num,
                   prl.wip_resource_seq_num,
                   prl.attribute_category,
                   prl.destination_context,
                   prl.inventory_source_context,
                   prl.vendor_source_context,
                   prl.attribute1,
                   prl.attribute2,
                   prl.attribute3,
                   prl.attribute4,
                   prl.attribute5,
                   prl.attribute6,
                   prl.attribute7,
                   prl.attribute8,
                   prl.attribute9,
                   prl.attribute10,
                   prl.attribute11,
                   prl.attribute12,
                   prl.attribute13,
                   prl.attribute14,
                   prl.attribute15,
                   prl.bom_resource_id,
                   prl.government_context,
                   prl.closed_reason,
                   prl.closed_date,
                   prl.transaction_reason_code,
                   prl.quantity_received,
                 prl.tax_code_id,
                 prl.tax_user_override_flag,
                 prl.oke_contract_header_id,
                 prl.oke_contract_version_id,
                   prl.secondary_unit_of_measure,
                   prl.secondary_quantity,
                   prl.preferred_grade,
                 prl.secondary_quantity_received,
                 prl.secondary_quantity_cancelled,
                 prl.auction_header_id,
                 prl.auction_display_number,
                 prl.auction_line_number,
                 'Y',  --new reqs are placed back in pool after splitting
                 prl.vmi_flag,
               bid_number_rslt_tbl(l_insert_line_index),
               decode(record_status_rslt_tbl(l_insert_line_index),'N',NULL,
                     bid_line_number_rslt_tbl(l_insert_line_index)),
                   prl.order_type_lookup_code,
                   prl.purchase_basis,
                   prl.matching_basis,
                   prl.org_id, --<Sourcing 11.5.10+>
                   'CREATE' --<R12 eTax Integration>
        FROM po_requisition_lines_all  prl  --<Sourcing 11.5.10+>
       WHERE prl.requisition_line_id=
       requisition_line_id_rslt_tbl(l_insert_line_index);

            l_progress :='131';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'131'||'.';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Create all the new requisition lines; Inserted '
         ||sql%rowcount||' requisition lines');
      END IF;

            EXCEPTION
        WHEN OTHERS THEN

             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
             FND_MSG_PUB.Add;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module,
         'Exception: Create all the new requisition lines ');
             END IF;
             RAISE;

      END;


            -- SQL What:Mark all the parent requisition lines which are split
            --          with modified_by_agent_flag setting 'Y'. Eligible lines
      --    are the ones with the record status 'S'
            -- SQL Why :This indicates that this requisition lines have been
      --    modified by the buyer and no longer available for any
      --    operations.
      BEGIN

              l_progress :='140';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'140'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Mark parent req lines as modified by agent');
        END IF;

              -- <REQINPOOL>: added update of reqs_in_pool_flag and of
              -- WHO columns.
              FORALL l_mod_buyer_index in 1.. requisition_line_id_rslt_tbl.COUNT
              UPDATE po_requisition_lines_all --<Sourcing 11.5.10+>
                 SET modified_by_agent_flag = 'Y',
                     reqs_in_pool_flag = NULL,    --<REQINPOOL>
               last_update_date       = SYSDATE,
                     last_updated_by        = FND_GLOBAL.USER_ID,
                     last_update_login      = FND_GLOBAL.LOGIN_ID
               WHERE requisition_line_id =
               requisition_line_id_rslt_tbl(l_mod_buyer_index)
           AND record_status_rslt_tbl(l_mod_buyer_index)='S';

              l_progress :='141';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'141'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Mark parent req lines as modified by agent;Updated'
         ||sql%rowcount||' requisition lines ');
        END IF;

            EXCEPTION
        WHEN OTHERS THEN

             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
             FND_MSG_PUB.Add;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Exception: Mark parent req lines as modified by agent');
             END IF;
             RAISE;

      END;

            --<Bug 2752584 mbhargav START>
            --
            -- SQL What: Doing two bulk statements. One to delete from
      --           mtl_supply entries for old req lines. Second for
      --           inserting into mtl_supply newly created lines
            -- SQL Why : To take care of update to MTL_SUPPLY tables in case of
      --           req-split

      --<CLM INTG - PLANNING>
      -- Mark exclude_from_planning as 'Y' for CLM Documents
      --<CLM INTG - PLANNING>

      BEGIN

              l_progress :='145';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'145'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Update MTL_SUPPLY');
        END IF;

              FORALL l_update_mtl_supply_index in 1.. new_req_line_id_rslt_tbl.COUNT
                  -- Insert New Supply for each new Line created by the Reqsplit
                  INSERT INTO mtl_supply(supply_type_code,
                           supply_source_id,
                           last_updated_by,
                           last_update_date,
                           last_update_login,
                           created_by,
                           creation_date,
                           req_header_id,
                           req_line_id,
                           item_id,
                           item_revision,
                           quantity,
                           unit_of_measure,
                           receipt_date,
                           need_by_date,
                           destination_type_code,
                           location_id,
                           from_organization_id,
                           from_subinventory,
                           to_organization_id,
                           to_subinventory,
                           change_flag,
                           to_org_primary_quantity,
                           change_type,
                           to_org_primary_uom,
                           expected_delivery_date,
			   exclude_from_planning  --<CLM INTG - PLANNING>
			   )
                    SELECT       'REQ',
                           prl.requisition_line_id,
                           prl.last_updated_by,
                           prl.last_update_date,
                           prl.last_update_login,
                           prl.created_by,
                           prl.creation_date,
                           prl.requisition_header_id,
                           prl.requisition_line_id,
                           prl.item_id,
                           prl.item_revision,
                           prl.quantity - (nvl(prl.quantity_cancelled, 0) +
                                           nvl(prl.quantity_delivered, 0)),
                           prl.unit_meas_lookup_code,
                           prl.need_by_date,
                           prl.need_by_date,
                           prl.destination_type_code,
                           prl.deliver_to_location_id,
                           prl.source_organization_id,
                           prl.source_subinventory,
                           prl.destination_organization_id,
                           prl.destination_subinventory,
                           null,
                           prl.quantity - (nvl(prl.quantity_cancelled, 0) +
                                           nvl(prl.quantity_delivered, 0)),
                           null,
                           prl.unit_meas_lookup_code,
                           decode(prl.item_id, null, null, prl.need_by_date + nvl(msi.postprocessing_lead_time,0)),
                           DECODE(PO_CLM_INTG_GRP.IS_CLM_DOCUMENT('REQUISITION',prl.Requisition_header_id),'Y','Y','N',NULL,NULL) --<CLM INTG - PLANNING>
                     FROM po_requisition_lines_all prl, --<Sourcing 11.5.10+>
                          mtl_system_items msi
                    WHERE prl.requisition_line_id =
          new_req_line_id_rslt_tbl(l_update_mtl_supply_index)
                      AND prl.destination_organization_id = msi.organization_id(+)
                      AND prl.item_id =  msi.inventory_item_id(+)
                      AND EXISTS
                           (select 'Supply Exists'
                             from mtl_supply
                            where supply_type_code = 'REQ'
                              AND supply_source_id =
           requisition_line_id_rslt_tbl(l_update_mtl_supply_index));

              --Delete the entry in mtl_supply for original req line
              FORALL l_delete_mtl_supply_index in
         1.. requisition_line_id_rslt_tbl.COUNT
               DELETE FROM mtl_supply
               WHERE supply_type_code = 'REQ'
               AND supply_source_id =
         requisition_line_id_rslt_tbl(l_delete_mtl_supply_index);

              l_progress :='146';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'146'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Update MTL_SUPPLY;Updated'
         ||sql%rowcount||' requisition lines ');
        END IF;

            EXCEPTION
        WHEN OTHERS THEN

             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
             FND_MSG_PUB.Add;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Exception: Update MTL_SUPPLY');
             END IF;
             RAISE;

      END;
            --<Bug 2752584 mbhargav END>


            l_progress :='150';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'150'||'.';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Copy all the attachments');
      END IF;


            FOR l_copy_attach_index in 1.. requisition_line_id_rslt_tbl.COUNT
              LOOP
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
    'requisition_line_id_rslt_tbl='
    ||to_char(requisition_line_id_rslt_tbl(l_copy_attach_index))
    ||' to- new_req_line_id_rslt_tbl='
    ||to_char(new_req_line_id_rslt_tbl(l_copy_attach_index)));
        END IF;

                fnd_attached_documents2_pkg.copy_attachments
            (X_from_entity_name        => 'REQ_LINES'  ,
           X_from_pk1_value=>
       requisition_line_id_rslt_tbl(l_copy_attach_index),
           X_from_pk2_value          =>   NULL    ,
           X_from_pk3_value          =>   NULL    ,
           X_from_pk4_value          =>   NULL    ,
           X_from_pk5_value          =>   NULL,
           X_to_entity_name          =>   'REQ_LINES'   ,
           X_to_pk1_value =>new_req_line_id_rslt_tbl(l_copy_attach_index),
           X_to_pk2_value            =>   NULL  ,
           X_to_pk3_value            =>   NULL  ,
           X_to_pk4_value            =>   NULL  ,
           X_to_pk5_value            =>   NULL    ,
           X_created_by              =>   NULL  ,
           X_last_update_login       =>   NULL    ,
           X_program_application_id  =>   NULL    ,
           X_program_id              =>   NULL    ,
           X_request_id              => NULL    ,
           X_automatically_added_flag=>   NULL
          );

            END LOOP;

            l_progress :='159';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'159'||'.';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Copy all the attachments');
      END IF;

            -- Retrieve the current operating unit from the environment
            l_current_ou_id := PO_GA_PVT.get_current_org;

            -- Take care of single-org instance
            IF l_current_ou_id IS NULL THEN
               l_current_ou_id := -99;
            END IF;

            -- Initialize l_old_line_requesting_ou_id to be the same as
            -- the current ou id
            l_old_line_requesting_ou_id := l_current_ou_id;
            --<Sourcing 11.5.10+ End>


            BEGIN

              l_progress :='160';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'160'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Create distributions lines For all the ' ||
          'newly created requisition lines');
        END IF;
              --<Sourcing 11.5.10+ Start>
              FOR l_create_dist_index
           IN 1.. requisition_line_id_rslt_tbl.COUNT
              LOOP
                -- Set org context to the ou where the current requisition line
                -- is raised, because AP's tax rounding API needs to be called
                -- in the Requesting OU's org context

                -- SQL What: Retrieves the value of org_id from the current
                --           requisition line
                -- SQL Why: Need to set org context to the OU where the
                --          requisition line is raised
                SELECT nvl(org_id, -99)
                INTO   l_line_requesting_ou_id
                FROM   po_requisition_lines_all
                WHERE  requisition_line_id = requisition_line_id_rslt_tbl(l_create_dist_index);

                IF l_line_requesting_ou_id <> l_old_line_requesting_ou_id THEN
       PO_MOAC_UTILS_PVT.set_org_context(l_line_requesting_ou_id) ;         -- <R12 MOAC>
                   l_org_context_changed := 'Y';
                   l_old_line_requesting_ou_id := l_line_requesting_ou_id;
              END IF;

              INSERT INTO po_req_distributions_all --<Sourcing 11.5.10+>
                     (DISTRIBUTION_ID     ,
                      LAST_UPDATE_DATE      ,
                      LAST_UPDATED_BY     ,
                      REQUISITION_LINE_ID   ,
                      SET_OF_BOOKS_ID     ,
                      CODE_COMBINATION_ID   ,
                      REQ_LINE_QUANTITY     ,
                      LAST_UPDATE_LOGIN     ,
                      CREATION_DATE     ,
                      CREATED_BY      ,
                      ENCUMBERED_FLAG     ,
                      GL_ENCUMBERED_DATE    ,
                      GL_ENCUMBERED_PERIOD_NAME   ,
                      GL_CANCELLED_DATE     ,
                      FAILED_FUNDS_LOOKUP_CODE    ,
                      ENCUMBERED_AMOUNT           ,
                      BUDGET_ACCOUNT_ID               ,
                      ACCRUAL_ACCOUNT_ID              ,
                      ORG_ID                          ,
                      VARIANCE_ACCOUNT_ID             ,
                      PREVENT_ENCUMBRANCE_FLAG        ,
                      ATTRIBUTE_CATEGORY              ,
                      ATTRIBUTE1                      ,
                      ATTRIBUTE2                      ,
                      ATTRIBUTE3                      ,
                      ATTRIBUTE4                      ,
                      ATTRIBUTE5                      ,
                      ATTRIBUTE6                      ,
                      ATTRIBUTE7                      ,
                      ATTRIBUTE8                      ,
                      ATTRIBUTE9                      ,
                      ATTRIBUTE10                     ,
                      ATTRIBUTE11                     ,
                      ATTRIBUTE12                     ,
                      ATTRIBUTE13                     ,
                      ATTRIBUTE14                     ,
                      ATTRIBUTE15                     ,
                      GOVERNMENT_CONTEXT              ,
                      REQUEST_ID                      ,
                      PROGRAM_APPLICATION_ID          ,
                      PROGRAM_ID                      ,
                      PROGRAM_UPDATE_DATE             ,
                      PROJECT_ID                      ,
                      TASK_ID                         ,
                      EXPENDITURE_TYPE                ,
                      PROJECT_ACCOUNTING_CONTEXT      ,
                      EXPENDITURE_ORGANIZATION_ID     ,
                      GL_CLOSED_DATE                  ,
                      SOURCE_REQ_DISTRIBUTION_ID      ,
                      DISTRIBUTION_NUM                ,
                      PROJECT_RELATED_FLAG            ,
                      EXPENDITURE_ITEM_DATE           ,
                      ALLOCATION_TYPE                 ,
                      ALLOCATION_VALUE                ,
                      END_ITEM_UNIT_NUMBER            ,
                      RECOVERABLE_TAX                 ,
                      NONRECOVERABLE_TAX              ,
                      RECOVERY_RATE                   ,
                      TAX_RECOVERY_OVERRIDE_FLAG      ,
                      AWARD_ID                        ,
                      OKE_CONTRACT_LINE_ID            ,
                      OKE_CONTRACT_DELIVERABLE_ID
         )
            SELECT   po_req_distributions_s.nextval,
                     LAST_UPDATE_DATE     ,
                     LAST_UPDATED_BY      ,
                     new_req_line_id_rslt_tbl(l_create_dist_index),
                     SET_OF_BOOKS_ID      ,
                     CODE_COMBINATION_ID    ,
                     round(((req_line_quantity/requisition_line_qty_rslt_tbl(l_create_dist_index))* allocated_qty_rslt_tbl(l_create_dist_index)),13),
         --enter req form, dist screen uses 13 places to round.
         --suggested by PM.
                     LAST_UPDATE_LOGIN      ,
                     CREATION_DATE      ,
                     CREATED_BY       ,
         --purposely encumbered flag is copied from the parent dist
         --line instead of assigning a null values. This is required
         --as there is no parent dist id on the distributions table.
                     ENCUMBERED_FLAG      ,
                     GL_ENCUMBERED_DATE     ,
                     GL_ENCUMBERED_PERIOD_NAME    ,
                     GL_CANCELLED_DATE      ,
                     FAILED_FUNDS_LOOKUP_CODE         ,
         --bug#2728152, the new lines should have 0 encumbered amt.
         --as encumbrance api is looking at this value.
                     --ENCUMBERED_AMOUNT                ,
         0,
                     BUDGET_ACCOUNT_ID                ,
                     ACCRUAL_ACCOUNT_ID               ,
                     ORG_ID                           ,
                     VARIANCE_ACCOUNT_ID              ,
                     PREVENT_ENCUMBRANCE_FLAG         ,
                     ATTRIBUTE_CATEGORY               ,
                     ATTRIBUTE1                       ,
                     ATTRIBUTE2                       ,
                     ATTRIBUTE3                       ,
                     ATTRIBUTE4                       ,
                     ATTRIBUTE5                       ,
                     ATTRIBUTE6                       ,
                     ATTRIBUTE7                       ,
                     ATTRIBUTE8                       ,
                     ATTRIBUTE9                       ,
                     ATTRIBUTE10                      ,
                     ATTRIBUTE11                      ,
                     ATTRIBUTE12                      ,
                     ATTRIBUTE13                      ,
                     ATTRIBUTE14                      ,
                     ATTRIBUTE15                      ,
                     GOVERNMENT_CONTEXT               ,
                     REQUEST_ID                       ,
                     PROGRAM_APPLICATION_ID           ,
                     PROGRAM_ID                       ,
                     PROGRAM_UPDATE_DATE              ,
                     PROJECT_ID                       ,
                     TASK_ID                          ,
                     EXPENDITURE_TYPE                 ,
                     PROJECT_ACCOUNTING_CONTEXT       ,
                     EXPENDITURE_ORGANIZATION_ID      ,
                     GL_CLOSED_DATE                   ,
                     SOURCE_REQ_DISTRIBUTION_ID       ,
                     DISTRIBUTION_NUM                 ,
                     PROJECT_RELATED_FLAG             ,
                     EXPENDITURE_ITEM_DATE            ,
                     ALLOCATION_TYPE                  ,
                     ALLOCATION_VALUE                 ,
                     END_ITEM_UNIT_NUMBER             ,
                     --<R12 eTax Integration> recoverable and nonrecoverable
                     -- tax is recalculated instead of being prorated
                     null,
                     null,
                     RECOVERY_RATE                    ,
                     TAX_RECOVERY_OVERRIDE_FLAG       ,
                     AWARD_ID                         ,
                     OKE_CONTRACT_LINE_ID             ,
                     OKE_CONTRACT_DELIVERABLE_ID
    FROM po_req_distributions_all --<Sourcing 11.5.10+>
         WHERE requisition_line_id=
           requisition_line_id_rslt_tbl(l_create_dist_index);

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
  		 PO_DEBUG.debug_stmt(l_log_head,l_progress,
			  'Created '||sql%rowcount||' distributions lines, requisition_line_id= '|| new_req_line_id_rslt_tbl(l_create_dist_index) );
      END IF;
     -- bug 5249299 start: Need to call GMS api to maintain the adls data since these are
     -- new distributions.
     FOR l_req_dist_proj_rec IN
       l_req_dist_proj_csr(requisition_line_id_rslt_tbl(l_create_dist_index))
     LOOP

     l_distribution_id       := l_req_dist_proj_rec.distribution_id;
     l_project_id            := l_req_dist_proj_rec.project_id;
     l_task_id               := l_req_dist_proj_rec.task_id;
     l_award_id              := l_req_dist_proj_rec.award_id ;
     l_expenditure_type      := l_req_dist_proj_rec.expenditure_type ;
     l_expenditure_item_date := l_req_dist_proj_rec.expenditure_item_date;

      l_progress :='159';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'159'||'.';
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
		 PO_DEBUG.debug_stmt(l_log_head,l_progress,
			  'calling GMS_POR_API.when_insert_line :'||
			  'l_distribution_id '||l_distribution_id||
			  'l_project_id '||l_project_id||
			  'l_task_id '||l_task_id ||
			  'l_award_id '||l_award_id ||
			  'l_expenditure_type '||l_expenditure_type ||
		          'l_expenditure_item_date '||
			   to_char(l_expenditure_item_date,'DD-MON-YYYY'));
	 END IF;

      IF (l_award_id is not null) THEN

        l_award_id := GMS_POR_API.get_award_id(
					X_award_set_id => l_award_id,
					X_award_number => NULL,
					X_req_distribution_id => NULL);

	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  PO_DEBUG.debug_stmt(l_log_head,l_progress,
		'After calling GMS_POR_API.get_award_id :'||
		'l_award_id'||l_award_id);
        END IF;

        GMS_POR_API.when_insert_line (
		         X_distribution_id	=> l_distribution_id,
			 X_project_id	        => l_project_id,
			 X_task_id		=> l_task_id,
			 X_award_id		=> l_award_id,
			 X_expenditure_type	=> l_expenditure_type,
		         X_expenditure_item_date=> l_expenditure_item_date,
			 X_award_set_id		=> l_award_set_id,  --OUT
			 X_status	        => l_status) ;


	l_progress :='160';
	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
	  PO_DEBUG.debug_stmt(l_log_head,l_progress,
				 'After when insert line : Out values '||
				'l_award_set_id '||l_award_set_id ||
				 'l_status '||l_status );
	END IF;


     END IF; -- if (l_award_id is NOT NULL)

    END LOOP; -- req_dist_proj_cursor
    -- bug 5249299 end

   END LOOP; --<Sourcing 11.5.10+>

            l_progress :='161';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||'161'||'.';
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Create distributions lines for all the
          newly created requisition lines; Created '
          ||sql%rowcount||' distributions lines ' );
      END IF;
            EXCEPTION
        WHEN OTHERS THEN

             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
             FND_MSG_PUB.Add;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Excption: Create distributions lines for all the
          newly created requisition lines');
             END IF;

                   -- Switch the org context back to the current OU if it has been changed
                   IF (l_org_context_changed = 'Y') THEN
          PO_MOAC_UTILS_PVT.set_org_context(l_current_ou_id) ;         -- <R12 MOAC>
                      l_org_context_changed := 'N';
                   END IF;

             RAISE;

            END;

            -- Switch the org context back to the current OU if it has been changed
            IF (l_org_context_changed = 'Y') THEN
         PO_MOAC_UTILS_PVT.set_org_context(l_current_ou_id) ;         -- <R12 MOAC>
               l_org_context_changed := 'N';
            END IF;
            --<Sourcing 11.5.10+ End>

            --<R12 eTax Integration> Calculate recoverable and nonrecoverable
            -- tax amounts
            FOR i IN req_header_id_csr LOOP
              PO_TAX_INTERFACE_PVT.calculate_tax_requisition(
                p_requisition_header_id => i.requisition_header_id,
                p_calling_program       => 'PO_NEGOTIATIONS',
                x_return_status         => l_return_status
              );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_MESSAGE.set_name('PO','PO_PDOI_TAX_CALCULATION_ERR');
                FND_MSG_PUB.add;

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.g_exc_error;
                ELSE
                  RAISE FND_API.g_exc_unexpected_error;
                END IF;
              END IF;
            END LOOP;

            --take care of rounding here...
            BEGIN

              l_progress :='170';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'170'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: Collect the info to take care of rounding ');
        END IF;

        --sql what: Select min distribution id, sum of req line quantity
        --          from dist lines and max allocated qty frm temp table.
        --sql why : This information is required for the update to take
        --          care of the rounding issue which is the next step.
              SELECT prd.requisition_line_id,
                     MIN(prd.distribution_id),
                 SUM(prd.req_line_quantity),
                 MAX(prs.allocated_qty)  --this would be always one record.
                BULK COLLECT INTO
                   req_line_id_round_tbl,
                     min_dist_id_round_tbl,
                     sum_req_line_qty_round_tbl,
                 req_line_qty_round_tbl
            FROM po_req_distributions_all prd, --<Sourcing 11.5.10+>
                     po_req_split_lines_gt prs
               WHERE prd.requisition_line_id = prs.new_req_line_id
                 AND prs.record_status in ('S','N')
               GROUP BY prd.requisition_line_id;

              l_progress :='171';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'171'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: Collect the info to take care of rounding ');
        END IF;

            EXCEPTION
        WHEN OTHERS THEN

             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
             FND_MSG_PUB.Add;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Exception: Collect the info to take care of rounding ');
             END IF;
             RAISE;

            END;

            BEGIN

              l_progress :='180';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'180'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Before: update to take care of rounding ');
        END IF;

        --sql what: Update one of the distributions(which has min dist_id)
        --          with the excess/less of the sum of quantities of all
        --          the distribution lines.
        --sql why : To take care of rounding issue.
              FORALL l_qty_rounding_index in 1.. req_line_id_round_tbl.COUNT
              UPDATE po_req_distributions_all --<Sourcing 11.5.10+>
                 SET req_line_quantity = req_line_quantity+
             (req_line_qty_round_tbl(l_qty_rounding_index)-
                  sum_req_line_qty_round_tbl(l_qty_rounding_index))
               WHERE distribution_id=
           min_dist_id_round_tbl(l_qty_rounding_index);

              l_progress :='181';
        l_module := G_MODULE_PREFIX||l_api_name||'.'||'181'||'.';
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'After: update to take care of rounding; Updated '
         ||sql%rowcount||' rows');
        END IF;

            EXCEPTION
        WHEN OTHERS THEN
             po_message_s.sql_error
         ('Exception of Split_requisitionLines()', l_progress ,
           sqlcode);
         FND_MSG_PUB.Add;
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
         'Exception: update to take care of rounding ');
         END IF;
         RAISE;
            END;

            -- JFMIP, support for Req Modify when encumbrance is enabled START
            l_progress :='195';
            l_module := G_MODULE_PREFIX||l_api_name||'.'||'195'||'.';
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Before: Calling HANDLE_TAX_ADJUSTMENTS; Status is '||
                           l_return_status);
            END IF;

            handle_tax_adjustments
      (   p_api_version   =>1.0, -- Bug 4029136
          p_commit    =>p_commit, -- Bug 3152161
                x_return_status   =>l_return_status,
                x_msg_count   =>l_msg_count,
                x_msg_data    =>l_msg_data
            );

            l_progress :='196';
            l_module := G_MODULE_PREFIX||l_api_name||'.'||'196'||'.';
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'After: Calling HANDLE_TAX_ADJUSTMENTS; Status is
                           '||l_return_status);
            END IF;

            IF (l_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
            ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
             RAISE FND_API.g_exc_unexpected_error;
            END IF;
            -- JFMIP, support for Req Modify when encumbrance is enabled END

            -- Bug 4723367 START
            -- Added encumbrance table which stores the encumbrance flag for
            -- each requesting OU. The following code loops through the table
            -- and sets the encumbrance flag to 'Y' if any of the requesting
            -- OUs have encumbrance flag of 'Y'. Otherwise, it remains 'N'.

        --Determine whether encumbrance is enabled
            l_progress :='190';
            l_module := G_MODULE_PREFIX||l_api_name||'.'||'190'||'.';
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT)
            THEN
              FND_LOG.string(
                FND_LOG.LEVEL_STATEMENT,
                l_module,
                'Before: select req_encumbrance_flag '
              );
            END IF;

            -- Default encumbrance flag to 'N'
            l_req_encumbrance_flag := 'N';

            -- If any of the requesting OUs have encumbrance flag of 'Y', set
            -- encumbrance flag to 'Y' and exit the loop
            FOR l_index in 1..encumbrance_flag_rslt_tbl.COUNT
            LOOP
              IF (encumbrance_flag_rslt_tbl(l_index) = 'Y')
              THEN
                l_req_encumbrance_flag := 'Y';
                EXIT;
              END IF;
            END LOOP;

            l_progress :='191';
            l_module := G_MODULE_PREFIX||l_api_name||'.'||'191'||'.';
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT)
            THEN
              FND_LOG.string(
                FND_LOG.LEVEL_STATEMENT,
                l_module,
                'After: select req_encumbrance_flag '
              );
            END IF;
            -- Bug 4723367 END

      --Select all the distribution lines which are to be reserved and
      --unreserved into a plsql table
      IF l_req_encumbrance_flag = 'Y' THEN
                           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                             -- <FPI JFMIP Req Split START>
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Before: Calling handle_funds_reversal');
                           END IF;

         handle_funds_reversal
         (   p_api_version  =>1.0, -- Bug 4029136
             p_commit   =>p_commit, -- Bug 3152161
             x_return_status  =>l_return_status,
             x_msg_count    =>l_msg_count,
             x_msg_data   =>l_msg_data,
             x_online_report_id =>l_online_report_id
         );

         l_progress :='211';
         l_module := G_MODULE_PREFIX||l_api_name||'.'||'211'||'.';
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'After: Calling encumbrance api; Status is '||l_return_status);
         END IF;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'After: Calling handle_funds_reversal; Status is
                        '||l_return_status);
           END IF;


         IF (l_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
         END IF;
               -- <FPI JFMIP Req Split END>

           END IF; -- if l_encumbrance_flag..

         END IF; -- requisition_line_id_rslt_tbl.COUNT>1

        IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (   p_count         =>      x_msg_count       ,
    p_data          =>      x_msg_data
  );

        l_progress :='230';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'230'||'.';
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'Before: Setting success status to x_return_status');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
       ROLLBACK TO Split_RequisitionLines_PVT;
       x_msg_data := FND_MSG_PUB.GET();
       x_return_status := FND_API.g_ret_sts_unexp_error;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
               'Exception: UnexpectedError '||x_msg_data||sqlerrm);
       END IF;

  WHEN FND_API.g_exc_error THEN
       ROLLBACK TO Split_RequisitionLines_PVT;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.Count_And_Get
       (  p_count  =>  x_msg_count ,
    p_data   =>  x_msg_data
       );
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
               'Exception: ExpectedError '||x_msg_data||sqlerrm);
       END IF;

WHEN OTHERS THEN
BEGIN

   -- Log a debug message, add the error the the API message list.
   PO_DEBUG.handle_unexp_error(g_pkg_name,l_api_name,l_progress);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count
   ,  p_data   => x_msg_data
   );

   ROLLBACK TO Split_RequisitionLines_PVT;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;

END Split_RequisitionLines;


/**
 * Private Procedure: Consume_ReqDemandYesNo
 * Requires: Std. workflow input parameters
 * Modifies: NA.
 *
 * Effects: This procedure checks whether sourcing user wanted to consume the
 *   req demand by looking up the consume_Req_demand_flag from po_headers
 *
 * Returns: std. workflow out parameters
 */
PROCEDURE Consume_ReqDemandYesNo
(   itemtype            IN    VARCHAR2  ,
    itemkey             IN    VARCHAR2  ,
    actid               IN    NUMBER    ,
    funcmode            IN    VARCHAR2  ,
    resultout           OUT NOCOPY  VARCHAR2
)
IS

 l_orgid       number;
 l_create_sr_asl     varchar2(2);
 x_progress    varchar2(300);

 l_doc_string varchar2(200);
 l_preparer_user_name varchar2(100);
 l_document_id po_headers.po_header_id%type;
 l_document_type po_document_types_all.document_type_code%type;
 l_document_subtype po_document_types_all.document_subtype%type;
 l_consume_req_demand_flag po_headers.consume_req_demand_flag%type := NULL;

 l_resp_id     number;
 l_user_id     number;
 l_appl_id     number;

 --bug2829163
 l_po_revision po_headers.revision_num%type;

BEGIN
  x_progress := 'PO_NEGOTIATIONS4_PVT.Consume_ReqDemandYesNo: 01';
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;


  l_document_id := PO_WF_UTIL_PKG.GetItemAttrText
       ( itemtype => itemtype,
                     itemkey => itemkey,
                     aname => 'DOCUMENT_ID'
       );
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText
         ( itemtype => itemtype,
                       itemkey => itemkey,
                       aname => 'DOCUMENT_TYPE'
         );
  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText
      ( itemtype =>itemtype,
                          itemkey => itemkey,
                          aname => 'DOCUMENT_SUBTYPE'
      );

  IF l_document_type = 'PA'  AND l_document_subtype = 'BLANKET' THEN

     --bug2829163
     SELECT NVL(REVISION_NUM,0)
       INTO l_po_revision
       FROM po_headers
      WHERE PO_HEADER_ID = l_document_id;

  END IF;

  --bug2829163 added the check l_po_revision=0
  IF l_document_type = 'PA'  AND l_document_subtype = 'BLANKET'
     AND l_po_revision=0
  THEN
     -- SQL What:Select consume req demang flag
     -- SQL Why :If sourcing buyer wanted to consume the req demand then
     --          place the sourcing info on the requisition. So this
     --          information is set in the workflow.
     SELECT NVL(consume_req_demand_flag,'N')
       INTO l_consume_req_demand_flag
       FROM po_headers
      WHERE po_header_id = l_document_id;

  END IF;

  resultout := wf_engine.eng_completed || ':' || nvl(l_consume_req_demand_flag, 'N');

  x_progress := 'PO_NEGOTIATIONS4_PVT.Consume_ReqDemandYesNo: 02. Result= '
    || l_consume_req_demand_flag;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);

EXCEPTION
  WHEN OTHERS THEN
    l_consume_req_demand_flag := 'N';
    resultout := wf_engine.eng_completed || ':' || l_consume_req_demand_flag;
END Consume_ReqDemandYesNo;


/**
 * Private Procedure: Place_SourcingInfoOnReq
 * Requires: Std. workflow input parameters
 * Modifies: See Effects.
 * Effects: This procedure updates
 *   suggested_vendor_name, suggested_vendor_location,
 *   document_type_code, blanket_po_header_id and  blanket_po_line_num on
 *   po_requisition_lines if the user wanted to consume the req demand based
 *   on the bid and auction information on the blanket which is undergoing
 *   approval.
 * Returns: std. workflow out parameters
 */
procedure Place_SourcingInfoOnReq
(   itemtype            IN    VARCHAR2  ,
    itemkey             IN    VARCHAR2  ,
    actid               IN    NUMBER    ,
    funcmode            IN    VARCHAR2  ,
    resultout           OUT NOCOPY  VARCHAR2
) IS

 l_orgid       number;
 l_create_sr_asl     varchar2(2);
 x_progress    varchar2(300);

 l_doc_string varchar2(200);
 l_preparer_user_name varchar2(100);
 l_document_id po_headers.po_header_id%type;
 l_document_type PO_DOCUMENT_TYPES_ALL.DOCUMENT_TYPE_CODE%TYPE;
 l_document_subtype PO_DOCUMENT_TYPES_ALL.DOCUMENT_SUBTYPE%TYPE;
 l_vendor_id PO_VENDORS.VENDOR_ID%TYPE;
 l_vendor_name PO_VENDORS.VENDOR_NAME%TYPE;
 l_vendor_site_id PO_VENDOR_SITES.VENDOR_SITE_ID%TYPE;
 l_vendor_site_code PO_VENDOR_SITES.VENDOR_SITE_CODE%TYPE;

 l_resp_id     number;
 l_user_id     number;
 l_appl_id     number;

 -- SQL What:Bring all the lines for the blanket we have approved.
 -- SQL Why :Requires later down in the process to update all the
 --          req lines with the matching auction and bid information for
 --          each of these blanket lines.
 CURSOR document_lines_cursor is
 SELECT line_num,auction_header_id,auction_line_number,
  bid_number,bid_line_number
   FROM po_lines
  WHERE po_header_id=l_document_id;

BEGIN

  x_progress := 'PO_NEGOTIATIONS4_PVT.Place_SourcingInfoOnReq: 01';
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2846210
  ** Desc: Setting application context as this wf api will be executed
  ** after the background engine is run.
  */

  -- Context Setting revamp
  -- PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);


  l_document_id := PO_WF_UTIL_PKG.GetItemAttrText
       ( itemtype => itemtype,
                     itemkey => itemkey,
                     aname => 'DOCUMENT_ID'
       );
  l_document_type := PO_WF_UTIL_PKG.GetItemAttrText
         ( itemtype => itemtype,
                       itemkey => itemkey,
                       aname => 'DOCUMENT_TYPE'
         );
  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText
      ( itemtype =>itemtype,
                          itemkey => itemkey,
                          aname => 'DOCUMENT_SUBTYPE'
      );

  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_document_id'
                 ||to_char(l_document_id)||'l_document_type='||l_document_type
     ||'l_vendor_id='||to_char(l_vendor_id)||'l_supplier='
     ||l_vendor_name||'l_vendor_site_id='
     ||to_char(l_vendor_site_id));

  BEGIN

    -- SQL What:Select vendor information
    -- SQL Why :These are not already available from WF. hence the select
    SELECT poh.vendor_id,
     pov.vendor_name,
     poh.vendor_site_id,
     povs.vendor_site_code
      INTO l_vendor_id,l_vendor_name,l_vendor_site_id,l_vendor_site_code
      FROM po_headers poh ,po_vendors pov,po_vendor_sites povs
     WHERE po_header_id = l_document_id
       AND poh.vendor_id=pov.vendor_id
       AND poh.vendor_site_id=povs.vendor_site_id;

  EXCEPTION
    WHEN OTHERS THEN
         x_progress:='PO_NEGOTIATIONS4_PVT.Place_SourcingInfoOnReq: 02.';
   RAISE;
  END;


  FOR l_document_lines_index in document_lines_cursor
  LOOP

  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
     'before placing info on req- l_document_id='
     ||to_char(l_document_id)||'blanket_po_line_num='
     ||to_char(l_document_lines_index.line_num)
     ||'auction_header_id='
     ||to_char(l_document_lines_index.auction_header_id)
     ||'bid_line_number='
     ||to_char(l_document_lines_index.bid_line_number)
     ||'bid_number='||to_char(l_document_lines_index.bid_number));

      -- SQL What:Place the sourcing information on the AVAILABLE backing reqs.
      -- SQL Why :Next step is to launch the create doc wf to create a release
      --          based on this blanket which we just approved. Here we
      --          require this sourcing information.
      UPDATE po_requisition_lines
         SET suggested_vendor_name=l_vendor_name,
       suggested_vendor_location = l_vendor_site_code,
       document_type_code=l_document_subtype,
       blanket_po_header_id= l_document_id,
       blanket_po_line_num=l_document_lines_index.line_num
         -- suggested_vendor_id = l_vendor_id,
   -- suggested_vendor_site_id=l_vendor_site_id
       WHERE auction_header_id = l_document_lines_index.auction_header_id
   AND bid_line_number=l_document_lines_index.bid_line_number
   AND bid_number =l_document_lines_index.bid_number--placed on anotherneg
   AND line_location_id is null                --placed on another po doc
   AND nvl(cancel_flag,'N')= 'N'               --Cancelled
   AND nvl(closed_code,'OPEN') <> 'FINALLY CLOSED' --finally closed
   AND nvl(modified_by_agent_flag,'N') <> 'Y';  --buyer modified the req.

  END LOOP;


  resultout:=wf_engine.eng_completed || ':' || 'Y';

  x_progress:='PO_NEGOTIATIONS4_PVT.Place_SourcingInfoOnReq: 02. Result= '||'Y';
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress||sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    resultout := wf_engine.eng_completed || ':' || 'N';
END Place_SourcingInfoOnReq;


/**
 * Private Procedure: Launch_CreateDocWF
 * Requires: Std. workflow input parameters
 * Modifies: NA.
 * Effects: This procedure Launches create document workflow to automatically
 *   create a release based on the blaket the po approval workflow just
 *   approved.
 * Returns: std. workflow out parameters
 */
PROCEDURE Launch_CreateDocWF
(   ItemType                    IN    VARCHAR2  ,
    ItemKey                     IN    VARCHAR2  ,
    actid               IN    NUMBER    ,
    funcmode            IN    VARCHAR2  ,
    resultout           OUT NOCOPY  VARCHAR2
) IS

x_progress              varchar2(200);

l_ItemType varchar2(8);
l_ItemKey  varchar2(80);
l_workflow_process varchar2(30);
l_dummy  varchar2(38);
l_orgid number;
l_interface_source  varchar2(30);
l_document_id po_headers.po_header_id%type;

l_user_id number;
l_resp_id number;
l_appl_id number;

cursor C1 is
  select WF_CREATEDOC_ITEMTYPE,WF_CREATEDOC_PROCESS
  from po_document_types
  where DOCUMENT_TYPE_CODE= 'REQUISITION'
  and   DOCUMENT_SUBTYPE  = 'PURCHASE';

BEGIN

  /*Bug 7517077, assigning value to the resultout parameter, since the next activity gets driven based on this*/
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  -- Get the org context
  l_orgid := PO_WF_UTIL_PKG.GetItemAttrNumber
       (itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'ORG_ID');
  l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber
         (itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'USER_ID');
  l_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber
        (itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'RESPONSIBILITY_ID');
  l_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber
        (itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'APPLICATION_ID');
  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber
        (itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'DOCUMENT_ID');

  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_orgid='||to_char(l_orgid)||'l_user_id='||to_char(l_user_id)||'l_resp_id='||to_char(l_resp_id)||'l_appl_id='||to_char(l_appl_id)||'l_document_id='||to_char(l_document_id));

  /* Since the call may be started from background engine (new seesion),
   * need to ensure the fnd context is correct
   */

  if (l_user_id is not null and
      l_resp_id is not null and
      l_appl_id is not null )then

  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'apps_init');
      fnd_global.APPS_INITIALIZE(l_user_id, l_resp_id, l_appl_id);
  end if;

  IF l_orgid is NOT NULL THEN
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'setting org');
     PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;         -- <R12 MOAC>
  END IF;

  x_progress :=  'PO_NEGOTIATIONS4_PVT.Launch_CreateDocWF:01';
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);

  /* Create the ItemKey: Use the PO workflow sequence */
  select to_char(PO_WF_ITEMKEY_S.nextval) into l_dummy from sys.dual;

  OPEN C1;
  FETCH C1 into l_ItemType, l_workflow_process;

  IF C1%NOTFOUND THEN
    close C1;
    raise  NO_DATA_FOUND;
  END IF;

  CLOSE C1;

  l_ItemKey := to_char(l_document_id) || '-' || l_dummy;

  x_progress :=  'PO_NEGOTIATIONS4_PVT.Launch_CreateDocWF:02 ItemType=' ||
                 l_ItemType || ' ItemKey=' || l_ItemKey;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);

  x_progress := '30: Launch_CreateDocWF:  Called with following parameters:' ||
    'ItemType = ' || l_ItemType || '/ ' ||
    'ItemKey = '  || l_ItemKey  || '/ ' ||
    'workflow_process = ' || l_workflow_process;

  po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);

  IF  ( l_ItemType is NOT NULL )   AND
      ( l_ItemKey is NOT NULL)     THEN
        wf_engine.CreateProcess
  (itemtype => l_itemtype,
         itemkey  => l_itemkey,
         process  => l_workflow_process );

        x_progress:= '40: Launch_CreateDocWF: Just after CreateProcess';
        po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);

        PO_WF_UTIL_PKG.SetItemAttrNumber
  (itemtype   => l_itemtype,
         itemkey    => l_itemkey,
         aname      => 'ORG_ID',
         avalue     => l_orgid);

        PO_WF_UTIL_PKG.SetItemAttrNumber
  (itemtype   => l_itemtype,
         itemkey    => l_itemkey,
         aname      => 'CONSUME_REQ_DEMAND_DOC_ID',
         avalue     => l_DOCUMENT_ID);

        /* Kick off the process */

  x_progress :=  '40: Launch_CreateDocWF: Kicking off StartProcess ';
  po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);

        wf_engine.StartProcess(itemtype => l_itemtype,
                               itemkey  => l_itemkey );
    END IF;
    /*Bug 7517077, assigning value 'ACTIVITY PERFORMED' to the resultout parameter, since the next activity gets driven based on this*/
    resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
EXCEPTION
     WHEN OTHERS THEN
        wf_core.context('PO_NEGOTIATIONS4_PVT','Launch_CreateDocWF',
                              x_progress);
        raise;
END Launch_CreateDocWF;


-- <FPI JFMIP Req Split START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: handle_funds_reversal
--Pre-reqs:
--  None.
--Modifies:
--  PO_REQ_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  Make a call to encumbrance api to reverse the funds reservation
--  for the parent and reserve the funds for the children in force mode.
--Parameters:
--OUT:
--x_online_report_id
--  Specify the online report ID
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_funds_reversal
(   p_api_version   IN    NUMBER,
    p_commit      IN        VARCHAR2,
    x_return_status   OUT NOCOPY    VARCHAR2,
    x_msg_count     OUT NOCOPY    NUMBER,
    x_msg_data      OUT NOCOPY    VARCHAR2
)
IS
  l_online_report_id  PO_ONLINE_REPORT_TEXT.online_report_id%TYPE;
BEGIN
  handle_funds_reversal(p_api_version   => p_api_version,
        p_commit    => p_commit,
        x_return_status   => x_return_status,
        x_msg_count   => x_msg_count,
        x_msg_data    => x_msg_data,
        x_online_report_id  => l_online_report_id);
END handle_funds_reversal;

PROCEDURE handle_funds_reversal
(   p_api_version   IN    NUMBER,
    p_commit      IN        VARCHAR2,
    x_return_status   OUT NOCOPY    VARCHAR2,
    x_msg_count     OUT NOCOPY    NUMBER,
    x_msg_data      OUT NOCOPY    VARCHAR2,
    x_online_report_id    OUT NOCOPY  NUMBER
)
IS

  l_api_name             CONSTANT varchar2(30) := 'HANDLE_FUNDS_REVERSAL';
  l_api_version          CONSTANT NUMBER       := 1.0;

  l_module               VARCHAR2(100);
  l_progress             VARCHAR2(3);

  --define object type variable for calling encumbrance api.
  l_before_dist_ids_tbl po_tbl_number;
  l_after_dist_ids_tbl  po_tbl_number;
  l_po_return_code  VARCHAR2(20);
  l_req_org_id po_tbl_number; --Bug 5666854
  l_orig_org_id number; --Bug 5666854
  l_org_context_changed VARCHAR2(1) := 'N';--Bug 5666854

BEGIN

  l_progress :='000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  l_orig_org_id := PO_MOAC_UTILS_PVT.GET_CURRENT_ORG_ID;
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Entering ' || G_PKG_NAME || '.' || l_api_name);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   ' current org = ' ||l_orig_org_id);
    END IF;
  END IF;

  SAVEPOINT HANDLE_FUNDS_REVERSAL_PVT;

  l_progress :='010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Compatible_API_Call ');
    END IF;
  END IF;

  IF NOT FND_API.Compatible_API_Call
         (
          l_api_version,
          p_api_version,
          l_api_name,
          G_PKG_NAME
         )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --do the dump of input values if the log level is statement.
  l_progress :='015';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL=FND_LOG.LEVEL_STATEMENT THEN
    Print_Global_Table(l_module);
  END IF;

  l_progress :='020';

  --Bug 5666854 START
  -- Set org context to the Org where the current requisition line
  -- is raised, because handle_funds_reversal needs to operate
  -- in the Requesting OU's org context

  -- SQL What: Find out the distinct OrgIds to which the requisitions
  --           belong to
  -- SQL Why: Need to set org context to the OU where the
  --          requisition line is raised
  SELECT distinct org_id bulk collect
  INTO l_req_org_id
  FROM po_requisition_headers_all
  WHERE requisition_header_id IN
    (SELECT DISTINCT requisition_header_id
     FROM po_req_split_lines_gt);

  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                   'Number of distinct orgs to be considered = '||l_req_org_id.count);
    END IF;
  END IF;
  for l_index IN 1..l_req_org_id.count
  LOOP
    --Set Org Context to the Requisition OrgId
	--Bug 10131290.Added l_orig_org_id is null
    IF (l_orig_org_id is null) or (l_req_org_id(l_index) <> l_orig_org_id) THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_req_org_id(l_index)) ;
      l_org_context_changed := 'Y';
    END IF;
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
                     'Current org id = '||l_req_org_id(l_index));
      END IF;
    END IF;
    BEGIN
      --Select all the distribution lines which are to be reserved and
      --unreserved into a plsql table

      l_progress :='030';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'Before: select BEFORE req distributions for encumb. adjustmnets');
        END IF;
      END IF;

      SELECT prd.distribution_id
        BULK COLLECT INTO
             l_before_dist_ids_tbl
        FROM po_req_distributions prd,
             po_req_split_lines_gt prs
       WHERE prd.requisition_line_id = prs.requisition_line_id
         AND (prs.bid_number = prs.min_bid_number
             OR
             -- when called from autocreate req modify bid number
             -- would be null
             prs.bid_number IS NULL
             )
         AND prs.record_status = 'S'
         AND nvl(prd.prevent_encumbrance_flag,'N') <> 'Y'
         AND nvl(prd.encumbered_flag,'N') ='Y';

      l_progress :='040';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';

      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'l_before_dist_ids_tbl, count= '||l_before_dist_ids_tbl.count);
        END IF;
        FOR l_log_index IN 1.. l_before_dist_ids_tbl.COUNT
        LOOP
          -- Bug 4618614: Workaround GSCC error for checking logging statement.
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                    'l_before_dist_ids_tbl('||to_char(l_log_index)||')='
                    ||l_before_dist_ids_tbl(l_log_index));
          END IF;
        END LOOP;
      END IF;    --if g_fnd_debug='Y'

      l_progress :='050';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'Before: select AFTER req distributions for encumb. adjustmnets');
        END IF;
      END IF;

      SELECT prd.distribution_id
        BULK COLLECT INTO
             l_after_dist_ids_tbl
        FROM po_req_distributions prd,
             po_req_split_lines_gt prs
       WHERE prd.requisition_line_id = prs.new_req_line_id
         AND prs.record_status in ('S','N')
         AND nvl(prd.prevent_encumbrance_flag,'N') <> 'Y'
         AND nvl(prd.encumbered_flag,'N') ='Y';

      l_progress :='060';
      l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'l_after_dist_ids_tbl, count= '||l_after_dist_ids_tbl.count);
        END IF;
        FOR l_log_index IN 1.. l_after_dist_ids_tbl.COUNT
        LOOP
          -- Bug 4618614: Workaround GSCC error for checking logging statement.
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
              'l_after_dist_ids_tbl('||to_char(l_log_index)||')='
              ||l_after_dist_ids_tbl(l_log_index));
          END IF;
        END LOOP;
      END IF;    --if g_fnd_debug='Y'

      EXCEPTION
        WHEN OTHERS THEN
          po_message_s.sql_error
            ('Exception of HANDLE_FUNDS_REVERSAL()', l_progress ,
              sqlcode);
          FND_MSG_PUB.Add;
          IF G_FND_DEBUG = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                 'Exception:  select req distributions for encumb. adjustmnets');
            END IF;
          END IF;
          RAISE;
    END;

    --call the encumbrance api
    l_progress :='070';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'Before: Calling encumbrance api');
      END IF;
    END IF;

   PO_DOCUMENT_FUNDS_PVT.do_req_split(
       x_return_status         => x_return_status
    ,  p_before_dist_ids_tbl   => l_before_dist_ids_tbl
    ,  p_after_dist_ids_tbl    => l_after_dist_ids_tbl
    ,  p_employee_id           => NULL
    ,  p_override_funds        => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE
    ,  p_override_date         => SYSDATE
    ,  x_po_return_code        => l_po_return_code
    ,  x_online_report_id      => x_online_report_id
    );

    l_progress :='080';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';

    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'After: Calling encumbrance api; Status is '||x_return_status);
      END IF;
    END IF;

    IF (x_return_status = FND_API.g_ret_sts_error) OR
       (x_return_status = FND_API.g_ret_sts_unexp_error) THEN

      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
          'online_report_id = '||to_char(x_online_report_id)
          ||', po_return_code = '||l_po_return_code);
        END IF;
      END IF;


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF; /*IF (x_return_status = FND_API.g_ret_sts_error)*/
  END LOOP;

  -- Switch the org context back to the current OU if it has been changed
  IF (l_org_context_changed = 'Y') THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orig_org_id);
    l_org_context_changed := 'N';
  END IF;
  --Bug 5666854 END

    --bug 3537764: removed code to update the prevent enc flag
    --this is handled within the encumbrance call now
    --(in po_document_funds_pvt.do_req_split)


    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count         =>      x_msg_count             ,
          p_data          =>      x_msg_data
  );

  l_progress :='200';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Before: Setting success status to x_return_status');
    END IF;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO HANDLE_FUNDS_REVERSAL_PVT;
      x_msg_data := FND_MSG_PUB.GET();
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                       'Exception: UnexpectedError '||x_msg_data||sqlerrm);
        END IF;
      END IF;
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO HANDLE_FUNDS_REVERSAL_PVT;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get
      (  p_count  =>  x_msg_count ,
         p_data   =>  x_msg_data
      );
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                       'Exception: ExpectedError '||x_msg_data||sqlerrm);
        END IF;
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO HANDLE_FUNDS_REVERSAL_PVT;
      --x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
      (  p_count  =>  x_msg_count ,
         p_data   =>  x_msg_data
      );
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                       'Exception: UnExpectedError '||x_msg_data||sqlerrm);
        END IF;
      END IF;

END handle_funds_reversal;


-------------------------------------------------------------------------------
--Start of Comments
--Name: handle_tax_adjustments
--Pre-reqs:
--  None.
--Modifies:
--  PO_REQ_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  Handle tax adjustments.
--Parameters:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE handle_tax_adjustments
(   p_api_version   IN    NUMBER,
    p_commit      IN        VARCHAR2,
    x_return_status   OUT NOCOPY    VARCHAR2,
    x_msg_count     OUT NOCOPY    NUMBER,
    x_msg_data      OUT NOCOPY    VARCHAR2
)
IS

 l_api_name             CONSTANT varchar2(30) := 'HANDLE_TAX_ADJUSTMENTS';
 l_api_version          CONSTANT NUMBER       := 1.0;

 l_module               VARCHAR2(100);
 l_progress             VARCHAR2(3);

 sum_new_line_r_tax_tbl round_tax_tbl_type;
 sum_new_line_nr_tax_tbl round_tax_tbl_type;
 min_dist_id_tax_tbl min_dist_id_tbl_type;
 req_line_id_tax_tbl requisition_line_id_tbl_type;
 sum_orig_line_r_tax_tbl round_tax_tbl_type;
 sum_orig_line_nr_tax_tbl round_tax_tbl_type;

BEGIN

  l_progress :='000';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_module,
      'Entering ' || G_PKG_NAME || '.' || l_api_name);
    END IF;
  END IF;

  SAVEPOINT HANDLE_TAX_ADJUSTMENTS_PVT;

  l_progress :='010';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Compatible_API_Call ');
    END IF;
  END IF;

  IF NOT FND_API.Compatible_API_Call
         (
          l_api_version,
          p_api_version,
          l_api_name,
          G_PKG_NAME
         )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --do the dump of input values if the log level is statement.
  l_progress :='015';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||'015'||'.';
  IF G_FND_DEBUG = 'Y' AND G_FND_DEBUG_LEVEL=FND_LOG.LEVEL_STATEMENT THEN
    Print_Global_Table(l_module);
  END IF;

  l_progress :='020';

  BEGIN

    l_progress :='030';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||'030'||'.';
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'Before: Collect the info to take care of TAX rounding ');
      END IF;
    END IF;

    --The tax info collection for new req lines, this will be needed
    --for update of tax later
    SELECT   SUM(prd.recoverable_tax),
             SUM(prd.nonrecoverable_tax),
             MIN(prd.distribution_id)
    BULK COLLECT INTO
             sum_new_line_r_tax_tbl,
             sum_new_line_nr_tax_tbl,
             min_dist_id_tax_tbl
    FROM     po_req_distributions prd, po_req_split_lines_gt prs
    WHERE    prd.requisition_line_id = prs.new_req_line_id
    AND      prs.record_status in ('S','N')
    GROUP BY prs.requisition_line_id,
             prd.code_combination_id;

    IF G_FND_DEBUG = 'Y' THEN
      FOR i in 1..sum_new_line_r_tax_tbl.COUNT LOOP
        -- Bug 4618614: Workaround GSCC error for checking logging statement.
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN

          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
            'sum_new_line_r_tax_tbl('||i||'): '||sum_new_line_r_tax_tbl(i)||','||
            'sum_new_line_nr_tax_tbl('||i||'): '||sum_new_line_nr_tax_tbl(i)||','||
            'min_dist_id_tax_tbl('||i||'): '||min_dist_id_tax_tbl(i));
        END IF;
      END LOOP;
    END IF;

    l_progress :='040';
    --The tax info collection for original req lines, this will be needed
    --for update of tax later
    SELECT   prs.requisition_line_id,
             SUM(prd.recoverable_tax),
             SUM(prd.nonrecoverable_tax)
    BULK COLLECT INTO
             req_line_id_tax_tbl,
             sum_orig_line_r_tax_tbl,
             sum_orig_line_nr_tax_tbl
    FROM     po_req_distributions prd, po_req_split_lines_gt prs
    WHERE    prd.requisition_line_id = prs.requisition_line_id
    AND     (prs.bid_number = prs.min_bid_number OR
             -- when called from autocreate req modify bid number would be null
             prs.bid_number IS NULL)
    AND      prs.record_status = 'S'
    GROUP BY prs.requisition_line_id,
             prd.code_combination_id;

    l_progress :='050';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';

    IF G_FND_DEBUG = 'Y' THEN
      FOR i in 1..req_line_id_tax_tbl.COUNT LOOP
        -- Bug 4618614: Workaround GSCC error for checking logging statement.
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN

          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
            'req_line_id_tax_tbl('||i||'): '||req_line_id_tax_tbl(i)||','||
            'sum_orig_line_r_tax_tbl('||i||'): '||sum_orig_line_r_tax_tbl(i)||','||
            'sum_orig_line_nr_tax_tbl('||i||'): '||sum_orig_line_nr_tax_tbl(i));
        END IF;
      END LOOP;
    END IF;

    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'After: Collect the info to take care of TAX rounding ');
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error
        ('Exception of HANDLE_TAX_ADJUSTMENTS()', l_progress ,
          sqlcode);
      FND_MSG_PUB.Add;
      IF G_FND_DEBUG = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
          'Exception: Collect the info to take care of TAX rounding ');
        END IF;
      END IF;
      RAISE;
  END;


  BEGIN

    l_progress :='100';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'Before: update to take care of TAX rounding ');
      END IF;
    END IF;

    --sql what: Update one of the distributions(which has min dist_id)
    --          with the excess/less of the sum of RECOVERABLE and
    --          NONRECOVERABLE TAX of all
    --          the distribution lines.
    --sql why : To take care of TAX rounding issue.
    FORALL l_tax_rounding_index in 1.. req_line_id_tax_tbl.COUNT
    UPDATE PO_REQ_DISTRIBUTIONS
       SET recoverable_tax = recoverable_tax+
           (sum_orig_line_r_tax_tbl(l_tax_rounding_index) -
                    sum_new_line_r_tax_tbl(l_tax_rounding_index)),
           nonrecoverable_tax = nonrecoverable_tax+
           (sum_orig_line_nr_tax_tbl(l_tax_rounding_index) -
                    sum_new_line_nr_tax_tbl(l_tax_rounding_index))
     WHERE distribution_id=
           min_dist_id_tax_tbl(l_tax_rounding_index);

    l_progress :='110';
    l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'After: update to take care of TAX rounding; Updated '
           ||sql%rowcount||' rows');
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
         po_message_s.sql_error
           ('Exception of HANDLE_TAX_ADJUSTMENTS()', l_progress ,
             sqlcode);
     FND_MSG_PUB.Add;
     IF G_FND_DEBUG = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
         FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
           'Exception: update to take care of TAX rounding ');
       END IF;
     END IF;
     RAISE;
  END;

  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'Before Commit');
    END IF;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
           'After Commit');
    END IF;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count         =>      x_msg_count             ,
          p_data          =>      x_msg_data
  );

  l_progress :='200';
  l_module := G_MODULE_PREFIX||l_api_name||'.'||l_progress||'.';
  IF G_FND_DEBUG = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Before: Setting success status to x_return_status');
    END IF;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO HANDLE_TAX_ADJUSTMENTS_PVT;
    x_msg_data := FND_MSG_PUB.GET();
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                     'Exception: UnexpectedError '||x_msg_data||sqlerrm);
      END IF;
    END IF;

  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO HANDLE_TAX_ADJUSTMENTS_PVT;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get
    (  p_count  =>  x_msg_count ,
       p_data   =>  x_msg_data
    );
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                     'Exception: ExpectedError '||x_msg_data||sqlerrm);
      END IF;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO HANDLE_TAX_ADJUSTMENTS_PVT;
    --x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get
    (  p_count  =>  x_msg_count ,
       p_data   =>  x_msg_data
    );
    IF G_FND_DEBUG = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module,
                     'Exception: UnExpectedError '||x_msg_data||sqlerrm);
      END IF;
    END IF;

END handle_tax_adjustments;

-- <FPI JFMIP Req Split END>

END PO_NEGOTIATIONS4_PVT;

/
