--------------------------------------------------------
--  DDL for Package Body IGC_CBC_GL_FC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_GL_FC_PKG" AS
/*$Header: IGCBGFCB.pls 120.23.12000000.10 2007/12/07 14:24:00 dvjoshi ship $*/

  G_PATH CONSTANT VARCHAR2(100):= 'IGC.PLSQL.IGCBGFCB.IGC_CBC_GL_FC_PKG.';

  -- The flag determines whether to print debug information or not.
  g_debug_mode        VARCHAR2(1);

  g_line_num          NUMBER := 0;

  g_debug_msg         VARCHAR2(10000) := NULL;

  g_debug_level          NUMBER :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level          NUMBER :=  FND_LOG.LEVEL_STATEMENT;
  g_proc_level           NUMBER :=  FND_LOG.LEVEL_PROCEDURE;
  g_event_level          NUMBER :=  FND_LOG.LEVEL_EVENT;
  g_excep_level          NUMBER :=  FND_LOG.LEVEL_EXCEPTION;
  g_error_level          NUMBER :=  FND_LOG.LEVEL_ERROR;
  g_unexp_level          NUMBER :=  FND_LOG.LEVEL_UNEXPECTED;

  /* This variable contains constant number which can be added to batch_line_number
  */
  g_batch_line_const    NUMBER := 100000;

  CURSOR c_igc_cc_int(p_doc_id in NUMBER, p_doc_type IN VARCHAR2) IS
  SELECT * from IGC_CC_INTERFACE
  WHERE  cc_header_id = p_doc_id
  AND    document_type =  p_doc_type;
  TYPE  t_tbl_igc_cc_int    IS TABLE OF c_igc_cc_int%ROWTYPE index by PLS_INTEGER;
  g_tbl_igc_cc_int t_tbl_igc_cc_int;

  CURSOR c_gl_bc_packets(p_event_id NUMBER, p_ledger_id in NUMBER,p_document_type IN VARCHAR2) IS
  SELECT
  xte.source_id_int_1 CC_HEADER_ID
  ,pck.source_distribution_id_num_1 CC_ACCT_LINE_ID
  ,pck.code_combination_id CODE_COMBINATION_ID
  ,xah.accounting_date  CC_TRANSACTION_DATE
  ,pck.accounted_dr CC_FUNC_DR_AMT
  ,pck.accounted_cr CC_FUNC_CR_AMT
  ,pck.period_name PERIOD_NAME
  ,'E' ACTUAL_FLAG
  ,pck.ledger_id SET_OF_BOOKS_ID
  ,pck.encumbrance_type_id ENCUMBRANCE_TYPE_ID
  ,pck.result_code CBC_RESULT_CODE
  ,pck.status_code STATUS_CODE
  ,pck.funding_budget_version_id BUDGET_VERSION_ID
  ,pck.currency_code CURRENCY_CODE
  ,p_document_type DOCUMENT_TYPE
  ,xal.description TRANSACTION_DESCRIPTION
  ,p_document_type REFERENCE_1
  ,xte.source_id_int_1 REFERENCE_2
  /*Bug 6650138 set to null. We can use it for Version number.
    I am not changing it at present as code changes large and hence testing
  */
  ,NULL REFERENCE_3
  ,xte.transaction_number REFERENCE_4
  ,xah.description REFERENCE_5
  ,pck.packet_id REFERENCE_6
  ,pck.event_id EVENT_ID
  ,xah.last_update_date LAST_UPDATE_DATE
  ,xah.creation_date CREATION_DATE
  FROM xla_ae_headers xah
    ,xla_ae_lines   xal
    ,xla_transaction_entities xte
    ,gl_bc_packets  pck
  WHERE   xah.ae_header_id = pck.ae_header_id
  AND     xal.ae_header_id = pck.ae_header_id
  AND     xal.ae_line_num = pck.ae_line_num
  AND     xte.entity_id = xah.entity_id
  AND     pck.event_id = p_event_id
  AND     pck.ledger_id = p_ledger_id
  Order by pck.event_id,pck.source_distribution_id_num_1;

  TYPE  t_tbl_gl_bc_packets   IS TABLE OF c_gl_bc_packets%ROWTYPE index by PLS_INTEGER;

  g_gl_pck_count  NUMBER;


PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

PROCEDURE purge_igc_cc_int (
p_document_type IN VARCHAR2, p_document_id IN NUMBER
);

PROCEDURE populate_sbc_records(
p_t_tbl_gl_pck IN t_tbl_gl_bc_packets
);

PROCEDURE populate_igc_cc_int (
p_tbl_igc_cc_int IN t_tbl_igc_cc_int
);


PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS
BEGIN
   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;
   RETURN;
-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
     NULL;
       RETURN;
END Put_Debug_Msg;


PROCEDURE purge_igc_cc_int (
      p_document_type IN VARCHAR2, p_document_id IN NUMBER
      ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_full_path            VARCHAR2(255);
BEGIN
  l_full_path := g_path || 'PURGE_IGC_CC_INT';

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Start of purge_igc_cc_int');
  END IF;

  DELETE  FROM IGC_CC_INTERFACE
  WHERE   cc_header_id = p_document_id
  AND     document_type = p_document_type;

  COMMIT;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Completed purge_igc_cc_int');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Error in purge_igc_cc_int :'||SQLERRM);
  END IF;
  ROLLBACK;
  RAISE;
END;


PROCEDURE populate_sbc_records(
p_t_tbl_gl_pck IN t_tbl_gl_bc_packets
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_batch_line_num NUMBER := g_gl_pck_count;
l_user_id NUMBER := fnd_global.user_id ;
l_full_path            VARCHAR2(255);
BEGIN
  l_full_path := g_path || 'POPULATE_SBC_RECORDS';
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Start of populate_sbc_records');
  END IF;
  FOR i in p_t_tbl_gl_pck.FIRST..p_t_tbl_gl_pck.LAST
  LOOP
    l_batch_line_num := l_batch_line_num+1;
    INSERT INTO igc_cc_interface
    (
     CC_HEADER_ID
    ,CC_ACCT_LINE_ID
    ,CODE_COMBINATION_ID
    ,BATCH_LINE_NUM
    ,CC_TRANSACTION_DATE
    ,CC_FUNC_DR_AMT
    ,CC_FUNC_CR_AMT
    ,ACTUAL_FLAG
    ,PERIOD_NAME
    ,BUDGET_DEST_FLAG
    ,SET_OF_BOOKS_ID
    ,ENCUMBRANCE_TYPE_ID
    ,CBC_RESULT_CODE
    ,STATUS_CODE
    ,BUDGET_VERSION_ID
    ,CURRENCY_CODE
    ,DOCUMENT_TYPE
    ,TRANSACTION_DESCRIPTION
    ,REFERENCE_1
    ,REFERENCE_2
    ,REFERENCE_3
    ,REFERENCE_4
    ,REFERENCE_5
    ,REFERENCE_6
    ,EVENT_ID
    ,PROJECT_LINE
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    )
    VALUES
    (
     p_t_tbl_gl_pck(i).CC_HEADER_ID
    ,p_t_tbl_gl_pck(i).CC_ACCT_LINE_ID
    ,p_t_tbl_gl_pck(i).CODE_COMBINATION_ID
    ,l_batch_line_num
    ,p_t_tbl_gl_pck(i).CC_TRANSACTION_DATE
    ,p_t_tbl_gl_pck(i).CC_FUNC_DR_AMT
    ,p_t_tbl_gl_pck(i).CC_FUNC_CR_AMT
    ,p_t_tbl_gl_pck(i).ACTUAL_FLAG
    ,p_t_tbl_gl_pck(i).PERIOD_NAME
    ,'S'
    ,p_t_tbl_gl_pck(i).SET_OF_BOOKS_ID
    ,p_t_tbl_gl_pck(i).ENCUMBRANCE_TYPE_ID
    ,p_t_tbl_gl_pck(i).CBC_RESULT_CODE
    ,p_t_tbl_gl_pck(i).STATUS_CODE
    ,p_t_tbl_gl_pck(i).BUDGET_VERSION_ID
    ,p_t_tbl_gl_pck(i).CURRENCY_CODE
    ,p_t_tbl_gl_pck(i).DOCUMENT_TYPE
    ,p_t_tbl_gl_pck(i).TRANSACTION_DESCRIPTION
    ,p_t_tbl_gl_pck(i).REFERENCE_1
    ,p_t_tbl_gl_pck(i).REFERENCE_2
    ,p_t_tbl_gl_pck(i).REFERENCE_3
    ,p_t_tbl_gl_pck(i).REFERENCE_4
    ,p_t_tbl_gl_pck(i).REFERENCE_5
    ,p_t_tbl_gl_pck(i).REFERENCE_6
    ,p_t_tbl_gl_pck(i).EVENT_ID
    ,'N'
    ,p_t_tbl_gl_pck(i).LAST_UPDATE_DATE
    ,l_user_id
    ,p_t_tbl_gl_pck(i).CREATION_DATE
    ,l_user_id
    ) ;
  END LOOP;
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'populate_sbc_records Completed');
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Error in populate_sbc_records :'||SQLERRM);
  END IF;
  ROLLBACK;
  RAISE;
END;

PROCEDURE populate_igc_cc_int (
      p_tbl_igc_cc_int IN t_tbl_igc_cc_int
      ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_full_path            VARCHAR2(255);
BEGIN
  l_full_path := g_path || 'POP_IGC_CC_INT';
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Start of populate_igc_cc_int');
  END IF;
  FOR i IN p_tbl_igc_cc_int.FIRST..p_tbl_igc_cc_int.LAST
  LOOP
    Insert into igc_cc_interface
    (
     CC_HEADER_ID
    ,CC_ACCT_LINE_ID
    ,CODE_COMBINATION_ID
    ,BATCH_LINE_NUM
    ,CC_TRANSACTION_DATE
    ,CC_FUNC_DR_AMT
    ,CC_FUNC_CR_AMT
    ,ACTUAL_FLAG
    ,PERIOD_NAME
    ,BUDGET_DEST_FLAG
    ,SET_OF_BOOKS_ID
    ,ENCUMBRANCE_TYPE_ID
    ,CBC_RESULT_CODE
    ,STATUS_CODE
    ,BUDGET_VERSION_ID
    ,CURRENCY_CODE
    ,DOCUMENT_TYPE
    ,TRANSACTION_DESCRIPTION
    ,REFERENCE_1
    ,REFERENCE_2
    ,REFERENCE_3
    ,REFERENCE_4
    ,REFERENCE_5
    ,REFERENCE_6
    ,EVENT_ID
    ,PROJECT_LINE
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    )
    VALUES
    (
     p_tbl_igc_cc_int(i).CC_HEADER_ID
    ,p_tbl_igc_cc_int(i).CC_ACCT_LINE_ID
    ,p_tbl_igc_cc_int(i).CODE_COMBINATION_ID
    ,i
    ,p_tbl_igc_cc_int(i).CC_TRANSACTION_DATE
    ,p_tbl_igc_cc_int(i).CC_FUNC_DR_AMT
    ,p_tbl_igc_cc_int(i).CC_FUNC_CR_AMT
    ,p_tbl_igc_cc_int(i).ACTUAL_FLAG
    ,p_tbl_igc_cc_int(i).PERIOD_NAME
    ,p_tbl_igc_cc_int(i).BUDGET_DEST_FLAG
    ,p_tbl_igc_cc_int(i).SET_OF_BOOKS_ID
    ,p_tbl_igc_cc_int(i).ENCUMBRANCE_TYPE_ID
    ,p_tbl_igc_cc_int(i).CBC_RESULT_CODE
    ,p_tbl_igc_cc_int(i).STATUS_CODE
    ,p_tbl_igc_cc_int(i).BUDGET_VERSION_ID
    ,p_tbl_igc_cc_int(i).CURRENCY_CODE
    ,p_tbl_igc_cc_int(i).DOCUMENT_TYPE
    ,p_tbl_igc_cc_int(i).TRANSACTION_DESCRIPTION
    ,p_tbl_igc_cc_int(i).REFERENCE_1
    ,p_tbl_igc_cc_int(i).REFERENCE_2
    ,p_tbl_igc_cc_int(i).REFERENCE_3
    ,p_tbl_igc_cc_int(i).REFERENCE_4
    ,p_tbl_igc_cc_int(i).REFERENCE_5
    ,p_tbl_igc_cc_int(i).REFERENCE_6
    ,p_tbl_igc_cc_int(i).EVENT_ID
    ,p_tbl_igc_cc_int(i).PROJECT_LINE
    ,p_tbl_igc_cc_int(i).LAST_UPDATE_DATE
    ,p_tbl_igc_cc_int(i).LAST_UPDATED_BY
    ,p_tbl_igc_cc_int(i).CREATION_DATE
    ,p_tbl_igc_cc_int(i).CREATED_BY
    );
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Record Inserted :'||SQL%ROWCOUNT);
  END IF;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Error in populate_igc_cc_int :'||SQLERRM);
  END IF;
  ROLLBACK;
  RAISE;
END Populate_IGC_CC_INT;



FUNCTION  glzcbc
(
  p_mode                          IN       VARCHAR2,
  p_conc_proc                     IN       VARCHAR2 := FND_API.G_FALSE
) RETURN NUMBER AS

CURSOR c_event_details
is
Select event_id, application_id, event_type_code, event_status_code, entity_id
from   xla_events xla
where  xla.event_id in
       (
       Select psa.event_id
       from    psa_bc_xla_events_gt psa
       )
and   application_id = 201;

TYPE t_event_details IS TABLE OF c_event_details%ROWTYPE index by PLS_INTEGER;

CURSOR  c_entity_details(p_entity_id IN NUMBER) IS
SELECT  Source_id_int_1
FROM    xla_transaction_entities
WHERE   entity_id = p_entity_id;



l_event_details t_event_details;

CURSOR c_ledger_details(p_event_id in NUMBER) is
Select distinct ledger_id,  nvl(cbc_po_enable, 'N') cbc_enable
From   gl_bc_packets pck,
       igc_cc_bc_enable cbc
where  event_id = p_event_id
and    actual_flag = 'E'
and    pck.ledger_id = cbc.set_of_books_id(+)
and    exists
       (select 1 from gl_ledgers l
       where l.ledger_id = pck.ledger_id
       and   l.ledger_category_code = 'PRIMARY');

l_return NUMBER := 1;
l_user_id NUMBER;
l_rec_count NUMBER;

cursor c_psa_events is
SELECT event_id,result_code from psa_bc_xla_events_gt;
Type tbl_psa_event is TABLE OF c_psa_events%ROWTYPE INDEX BY PLS_INTEGER;
l_tbl_psa_event tbl_psa_event;

l_cbc_mode              VARCHAR2(1) ;

l_full_path            VARCHAR2(255);

l_debug_count NUMBER;

l_year_end              BOOLEAN;


BEGIN
  SAVEPOINT IGC_GLZCBC;
  l_full_path := g_path || 'GLZCBC';
  g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  l_user_id := fnd_global.user_id ;
  l_year_end := FALSE ;
  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Start of glzcbc');
  END IF;
  /* Bug 6650138. Coverered all modes as used in PSA funds checker */
  IF p_mode in ('R','P','F','A') THEN
    l_cbc_mode := 'R' ;
  ELSIF p_mode in ('C', 'M') THEN
    l_cbc_mode := 'C' ;
  ELSE
    l_cbc_mode := 'R';
  END IF ;

  open c_psa_events;
  FETCH c_psa_events
  BULK COLLECT INTO l_tbl_psa_event;
  CLOSE c_psa_events;


  Open c_event_details;
  FETCH c_event_details
    BULK COLLECT INTO l_event_details;
  CLOSE c_event_details;

  delete from psa_bc_xla_events_gt;

  -- nvl(l_event_details.LAST,0)
  FOR i_evt in 1..nvl(l_event_details.LAST,0)
  LOOP
    DECLARE
      CURSOR  c_po_det(p_document_id IN NUMBER) IS
      SELECT  poh.type_lookup_code po_type
      FROM    po_headers_all poh
      where   po_header_id = p_document_id;

      l_document_type VARCHAR2(3);
      l_document_subtype  VARCHAR2(25) ;
      l_document_id NUMBER;
      l_main_doc_id           NUMBER := NULL;
      l_main_type             VARCHAR2(25) := null ;
      l_ledger_id NUMBER;
      l_cbc_enable VARCHAR2(1) := 'N';
      l_bc_success            BOOLEAN ;
      l_bc_return_status      VARCHAR2(2) := null ;
      l_batch_result_code     VARCHAR2(3) ;
      l_tbl_igc_cc_int t_tbl_igc_cc_int;

      l_t_gl_bc_packets_sbc t_tbl_gl_bc_packets;

      l_process_record VARCHAR2(1) := 'N';
      l_return_status         VARCHAR2(1) ;
      l_msg_count             NUMBER ;
      l_msg_data              VARCHAR2(2000) ;
      l_accounting_date       DATE ;
      l_packet_accounting_date DATE ;
      l_count NUMBER;

    BEGIN
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'Event Found '||l_event_details(i_evt).event_id||':'||l_event_details(i_evt).event_type_code);
      END IF;

      OPEN c_ledger_details(l_event_details(i_evt).event_id);
      FETCH c_ledger_details INTO l_ledger_id, l_cbc_enable;
      CLOSE c_ledger_details;

      l_year_end := FALSE;

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'Ledger Found '||l_ledger_id);
      END IF;

      /* To check if this procedure called for year end */

      SELECT SUM(INSTR(UPPER(xal.description), UPPER(b.description)))
      INTO   l_count
      FROM   po_lookup_codes b,xla_ae_lines xal,xla_ae_headers xah
      WHERE  xah.event_id = l_event_details(i_evt).event_id
      AND    xah.ae_header_id = xal.ae_header_id
      AND    b.lookup_code IN ('IGC YEAR END RESERVE',
                              'IGC YEAR END UNRESERVE')
      AND    b.lookup_type = 'CONTROL ACTIONS';

      --       IF UPPER(l_bc_packets_rec.je_line_description) LIKE '%YEAR%END%'
      IF NVL(l_count,0) > 0
      THEN
        l_year_end := TRUE ;
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Called for IGC Year End : '||l_count);
        END IF;
      END IF ;

      IF (l_cbc_enable = 'N') or (l_ledger_id is NULL)  or (l_year_end = TRUE) THEN
        l_process_record := 'N';
        l_return := 1;
      ELSE
        OPEN c_entity_details(l_event_details(i_evt).entity_id);
        FETCH c_entity_details INTO l_document_id;
        CLOSE c_entity_details;
        l_process_record:= 'Y';
        IF l_event_details(i_evt).event_type_code like 'PO%' THEN
          l_document_type := 'PO';
          OPEN c_po_det(l_document_id);
          FETCH c_po_det INTO l_document_subtype;
          CLOSE c_po_det;
          IF l_document_subtype NOT IN ('STANDARD','PLANNED')
          THEN
             l_process_record := 'N';
             l_return := 1;
          END IF ;
        ELSIF l_event_details(i_evt).event_type_code like 'REQ%' THEN
          l_document_type := 'REQ';
          SELECT type_lookup_code
          INTO l_document_subtype
          FROM po_requisition_headers_all
          WHERE requisition_header_id = l_document_id ;
        ELSIF l_event_details(i_evt).event_type_code like 'REL%' THEN
          l_document_type := 'REL';
          /* Get PO details for a release */
          SELECT release_type, po_header_id
          INTO l_document_subtype, l_main_doc_id
          FROM po_releases_all
          WHERE po_release_id = l_document_id ;

          l_main_type := 'PO' ;

        END IF;

        IF l_process_record = 'Y' THEN

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Document details are '||l_document_type||' : '||l_document_id);
          END IF;

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Before determining l_accounting_date');
          END IF;
          -- Get accounting date
          igc_cbc_po_grp.get_cbc_acct_date
             (
              p_api_version       => 1.0
             ,p_init_msg_list     => FND_API.G_FALSE
             ,p_commit            => FND_API.G_FALSE
             ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status     => l_return_status
             ,x_msg_count         => l_msg_count
             ,x_msg_data          => l_msg_data
             ,p_document_id       => l_document_id
             ,p_document_type     => l_document_type
             ,p_document_sub_type => l_document_subtype
             ,p_default           => 'Y'
             ,x_cbc_acct_date     => l_packet_accounting_date
             ) ;

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Returned from igc_cbc_po_grp.get_cbc_acct_date '||l_return_status||' : '||l_packet_accounting_date );
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_packet_accounting_date IS NULL
          THEN
            ROLLBACK TO IGC_GLZCBC ;
            RETURN(0) ;
          END IF;

           IF l_packet_accounting_date IS NULL
           THEN
              --Get the accounting date from the database
              igc_cbc_po_grp.get_cbc_acct_date
                  (
                   p_api_version => 1.0
                  ,p_init_msg_list     => FND_API.G_FALSE
                  ,p_commit            => FND_API.G_FALSE
                  ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                  ,x_return_status     => l_return_status
                  ,x_msg_count         => l_msg_count
                  ,x_msg_data          => l_msg_data
                  ,p_document_id       => l_document_id
                  ,p_document_type     => l_document_type
                  ,p_document_sub_type => l_document_subtype
                  ,p_default           => 'N'
                  ,x_cbc_acct_date     => l_accounting_date
                  ) ;

              -- This section would normally be executed when called from
              -- Doc Import with automatic funds reservation.
              -- It would not get executed if invoked from the front
              -- end forms.
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS
              OR l_accounting_date IS NULL
              THEN
                  --Default the accounting date
                  igc_cbc_po_grp.get_cbc_acct_date
                      (
                       p_api_version => 1.0
                      ,p_init_msg_list     => FND_API.G_FALSE
                      ,p_commit            => FND_API.G_FALSE
                      ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                      ,x_return_status     => l_return_status
                      ,x_msg_count         => l_msg_count
                      ,x_msg_data          => l_msg_data
                      ,p_document_id       => l_document_id
                      ,p_document_type     => l_document_type
                      ,p_document_sub_type => l_document_subtype
                      ,p_default           => 'Y'
                      ,x_cbc_acct_date     => l_accounting_date
                      ) ;

                  -- If there were any errors or if a valid accounting date was not found, return error
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_accounting_date IS NULL
                  THEN

                      ROLLBACK TO IGC_GLZCBC ;
                      RETURN(0) ;
                   END IF ;

                   -- A valid accounting date was obtained. Therefore update the document.
                   igc_cbc_po_grp.update_cbc_acct_date
                       (
                       p_api_version => 1.0
                      ,p_init_msg_list     => FND_API.G_FALSE
                      ,p_commit            => FND_API.G_FALSE
                      ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                      ,x_return_status     => l_return_status
                      ,x_msg_count         => l_msg_count
                      ,x_msg_data          => l_msg_data
                      ,p_document_id       => l_document_id
                      ,p_document_type     => l_document_type
                      ,p_document_sub_type => l_document_subtype
                      ,p_cbc_acct_date     => l_accounting_date
                      ) ;

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                     ROLLBACK TO IGC_GLZCBC ;
                     RETURN(0) ;
                  END IF ;
            END IF; -- Accounting date found from db

          ELSIF l_packet_accounting_date IS NOT NULL
          THEN
            l_accounting_date := l_packet_accounting_date ;
          END IF; -- l_packet_accounting_date null

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'After determining l_accounting_date :'||l_accounting_date);
          END IF;

          l_main_type   := Nvl(l_main_type, l_document_type);
          l_main_doc_id := Nvl(l_main_doc_id, l_document_id);

          /* Delete old records from IGC_CC_INTERFACE table */
          purge_igc_cc_int(l_main_type, l_main_doc_id);

          open c_gl_bc_packets(l_event_details(i_evt).event_id, l_ledger_id, l_document_type);
          FETCH c_gl_bc_packets
          BULK COLLECT INTO l_t_gl_bc_packets_sbc;
          CLOSE c_gl_bc_packets;

          g_gl_pck_count := l_t_gl_bc_packets_sbc.LAST;

          /* Number of records in gl_bc_packets */

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Document Id'||l_main_doc_id || ' Records in gl_bc_packets '||l_t_gl_bc_packets_sbc.LAST);
          END IF;

          FOR l_ind IN l_t_gl_bc_packets_sbc.FIRST..l_t_gl_bc_packets_sbc.LAST
          LOOP
            IF l_document_type = 'REL' THEN
              l_t_gl_bc_packets_sbc(l_ind).CC_HEADER_ID := l_main_doc_id;
              l_t_gl_bc_packets_sbc(l_ind).DOCUMENT_TYPE := l_main_type ;
            END IF;
            Insert into igc_cc_interface
            (
             CC_HEADER_ID
            ,CC_ACCT_LINE_ID
            ,CODE_COMBINATION_ID
            ,BATCH_LINE_NUM
            ,CC_TRANSACTION_DATE
            ,CC_FUNC_DR_AMT
            ,CC_FUNC_CR_AMT
            ,ACTUAL_FLAG
            ,BUDGET_DEST_FLAG
            ,SET_OF_BOOKS_ID
            ,CURRENCY_CODE
            ,DOCUMENT_TYPE
            ,TRANSACTION_DESCRIPTION
            ,REFERENCE_1
            ,REFERENCE_2
            ,REFERENCE_3
            ,REFERENCE_4
            ,REFERENCE_5
            ,REFERENCE_6
            ,PROJECT_LINE
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            )
            Values
            (
             l_t_gl_bc_packets_sbc(l_ind).CC_HEADER_ID
            ,l_t_gl_bc_packets_sbc(l_ind).CC_ACCT_LINE_ID
            ,l_t_gl_bc_packets_sbc(l_ind).CODE_COMBINATION_ID
            ,g_batch_line_const + l_ind
            ,l_accounting_date
            ,l_t_gl_bc_packets_sbc(l_ind).CC_FUNC_DR_AMT
            ,l_t_gl_bc_packets_sbc(l_ind).CC_FUNC_CR_AMT
            ,l_t_gl_bc_packets_sbc(l_ind).ACTUAL_FLAG
            ,'C'
            ,l_t_gl_bc_packets_sbc(l_ind).SET_OF_BOOKS_ID
            ,l_t_gl_bc_packets_sbc(l_ind).CURRENCY_CODE
            ,l_t_gl_bc_packets_sbc(l_ind).DOCUMENT_TYPE
            ,l_t_gl_bc_packets_sbc(l_ind).TRANSACTION_DESCRIPTION
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_1
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_2
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_3
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_4
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_5
            ,l_t_gl_bc_packets_sbc(l_ind).REFERENCE_6
            ,'N'
            ,l_t_gl_bc_packets_sbc(l_ind).LAST_UPDATE_DATE
            ,l_user_id
            ,l_t_gl_bc_packets_sbc(l_ind).CREATION_DATE
            ,l_user_id
            );
          END LOOP;


          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Calling PSA Budgetary Control : '||l_t_gl_bc_packets_sbc.LAST);
          END IF;

          l_bc_success := igc_cbc_pa_bc_pkg.igcpafck(
                                                           l_ledger_id,
                                                           l_main_doc_id,
                                                           l_cbc_mode,
                                                           'E',
                                                           l_main_type,
                                                           l_bc_return_status,
                                                           l_batch_result_code,
                                                           g_debug_mode,
                                                           p_conc_proc
                                                );
          -- We are not performing SBC funds check through IGCFCK, therefore do not
          -- need to check for its success or failure.

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'PSA Budgetary Control completed '||l_bc_return_status||' : '||l_batch_result_code);
          END IF;

          IF l_bc_success = TRUE
            AND SUBSTR(l_bc_return_status,1,1) IN ('N', 'S', 'A')   -- cbc successful
            AND l_return = 1   THEN
            l_return := 1;    --  Success ! Funds check passed
          ELSIF l_bc_success = FALSE
            OR SUBSTR(l_bc_return_status,1,1) = 'T'  --  cbc fatal error
               THEN
            l_return := -1;
          ELSIF l_return <> -1 THEN   -- Successful completion but failed funds check
            l_return := 0;
          END IF;

          IF (g_debug_mode = 'Y') THEN
             Put_Debug_Msg(l_full_path, 'Populating PL-SQL table');
          END IF;

          /* Populate PL-SQL table with igc_cc_interface data */
          open c_igc_cc_int(l_main_doc_id, l_main_type);
          FETCH c_igc_cc_int
          BULK COLLECT INTO l_tbl_igc_cc_int;
          CLOSE c_igc_cc_int;
          /* Delete records from IGC_CC_INTERFACE table */
          DELETE  FROM igc_cc_interface
          WHERE   cc_header_id = l_main_doc_id
          AND     document_type = l_main_type;

          /* Now, populate back IGC_CC_INTERFACE table from PL-SQL table.
          This procedure will be called in autonomous transaction mode
          */
          populate_igc_cc_int(l_tbl_igc_cc_int);

          populate_sbc_records(l_t_gl_bc_packets_sbc);

          IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg(l_full_path, 'Call to populate_igc_cc_int is successful');
          END IF;

        END IF; -- l_doc_type


      END IF; --cbc_enable
    END;
   END LOOP;

  FOR Idx IN l_tbl_psa_event.FIRST .. l_tbl_psa_event.LAST
  LOOP
    INSERT INTO psa_bc_xla_events_gt(event_id,result_code )
    VALUES
    (l_tbl_psa_event(Idx).event_id,l_tbl_psa_event(Idx).result_code );
  END LOOP;

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Returning Value : '||l_return);
    END IF;
   return l_return;

EXCEPTION
   WHEN OTHERS THEN
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Error in GLZCBC :'||SQLERRM);
    END IF;
    ROLLBACK TO IGC_IGCFCK ;
    RETURN(-1) ;

END glzcbc ;

/* ------------------------------------------------------------------------
RECONCILE_GLZCBC gets called from glzfrs() to give the CBC funds checker
a chance to reconcile with the GL funds  check result. It will be used to
rollback the CBC journals which might have already been created in case GL
funds check has failed.
If we dont rollback the CBC journals,they get committed by the PO
processes even if the Standard budget funds check fails.
 ------------------------------------------------------------------------ */

FUNCTION RECONCILE_GLZCBC
(
   p_mode               IN   VARCHAR2
) RETURN NUMBER IS
BEGIN

Return(1);

End RECONCILE_GLZCBC;



END IGC_CBC_GL_FC_PKG;

/
