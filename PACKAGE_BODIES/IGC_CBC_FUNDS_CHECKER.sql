--------------------------------------------------------
--  DDL for Package Body IGC_CBC_FUNDS_CHECKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_FUNDS_CHECKER" AS
/* $Header: IGCBEFCB.pls 120.30.12010000.5 2010/01/06 12:06:49 schakkin ship $ */
-- Types :

/*R12 Uptake Refer Bug No : 6341012 - Start*/

TYPE g_cc_interface_head_rec_type IS RECORD
(CC_HEADER_ID igc_cc_interface.cc_header_id%TYPE,
 DOCUMENT_TYPE igc_cc_interface.DOCUMENT_TYPE%TYPE,
 BUDGET_DEST_FLAG igc_cc_interface.BUDGET_DEST_FLAG%TYPE,
 REFERENCE_4 igc_cc_interface.REFERENCE_4%TYPE,
 CC_TRANSACTION_DATE igc_cc_interface.CC_TRANSACTION_DATE%TYPE,
 EVENT_ID igc_cc_interface.EVENT_ID%TYPE,
 CC_DET_PF_LINE_ID igc_cc_interface.CC_DET_PF_LINE_ID%TYPE
);
TYPE g_cc_interface_head_tbl_type IS TABLE OF g_cc_interface_head_rec_type;
g_cc_interface_head_tbl g_cc_interface_head_tbl_type;

TYPE g_xla_events_gt_rec_type IS RECORD
(
 EVENT_ID psa_bc_xla_events_gt.event_id%TYPE,
 RESULT_CODE psa_bc_xla_events_gt.result_code%TYPE
);
TYPE g_xla_events_gt_tbl_type IS TABLE OF g_xla_events_gt_rec_type;
g_xla_events_gt_tbl g_xla_events_gt_tbl_type;

TYPE g_num_rec IS TABLE OF NUMBER;

/*R12 Uptake Refer Bug No : 6341012 - End*/

-- Private Global Variables :
G_PKG_NAME             CONSTANT VARCHAR2(30) := 'IGC_CBC_FUNDS_CKECKER';
g_debug          VARCHAR2(10000);
g_conc_proc            BOOLEAN := FALSE;
g_mode                 VARCHAR2(1);

g_cc_header_id         igc_cc_interface.cc_header_id%TYPE;
/*
g_set_of_books_id      gl_sets_of_books.set_of_books_id%TYPE;
*/
/*R12 Uptake Refer Bug No : 6341012 - Start*/
g_set_of_books_id      gl_ledgers.ledger_id%TYPE;
g_cbc_ledger_id        gl_ledgers.ledger_id%TYPE;
g_cbc_ledger_name      VARCHAR2(50);
/*R12 Uptake Refer Bug No : 6341012 - End*/
g_actual_flag          VARCHAR2(1);
g_update_login         igc_cc_interface.last_update_login%TYPE;
g_update_by            igc_cc_interface.last_updated_by%TYPE;
g_resp_id              NUMBER;
g_maxloops             NUMBER(10) := 50;
g_seconds              NUMBER(10) := 2;
g_cbc_flag             BOOLEAN :=TRUE;
g_sbc_flag             BOOLEAN :=TRUE;
g_sbc_status         VARCHAR2(1);
g_cbc_status         VARCHAR2(1);
g_date1                NUMBER;
g_date2                NUMBER;
/*Need to comment*/
--Encumbrance  types are seeded through SLA Bug No 6341012
g_summary_line_num     IGC_CBC_JE_LINES.cbc_je_line_num%TYPE;
g_com_enc_id           IGC_CBC_JE_LINES.encumbrance_type_id%TYPE;
g_obl_enc_id           IGC_CBC_JE_LINES.encumbrance_type_id%TYPE;

g_cbc_enabled          VARCHAR2(1);
g_doc_type             IGC_CC_INTERFACE.document_type%TYPE;
g_validation_error     BOOLEAN;
g_batch_result_code    VARCHAR2(4); --Global maximum rank
g_efc_enabled          VARCHAR2(1);
g_prod                 VARCHAR2(3)           := 'IGC';
g_sub_comp             VARCHAR2(3)           := 'CBC';
g_profile_name         VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
g_group_severity_level VARCHAR2(1);
g_source               VARCHAR2(255) ;
g_category             VARCHAR2(255) ;
g_packet_id            NUMBER;
g_gl_application_id    fnd_application.application_id%TYPE;
g_cc_application_id    fnd_application.application_id%TYPE; --R12 Uptake Refer Bug No 6341012
-- Variables for logging levels
--bug 3199488
g_debug_level          NUMBER :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level          NUMBER :=  FND_LOG.LEVEL_STATEMENT;
g_proc_level           NUMBER :=  FND_LOG.LEVEL_PROCEDURE;
g_event_level          NUMBER :=  FND_LOG.LEVEL_EVENT;
g_excep_level          NUMBER :=  FND_LOG.LEVEL_EXCEPTION;
g_error_level          NUMBER :=  FND_LOG.LEVEL_ERROR;
g_unexp_level          NUMBER :=  FND_LOG.LEVEL_UNEXPECTED;
g_path                 VARCHAR2(255) := 'IGC.PLSQL.IGCBEFCB.IGC_CBC_FUNDS_CHECKER.';

--bug 3199488
-- ssmales 25/01/02 bug 2201905 - added g_p_packet_id
g_p_packet_id          NUMBER(15) ;
g_called_from_PO       BOOLEAN := FALSE;
--bug 3199488
--g_debug_mode  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--g_legal_entity_id      NUMBER;  --R12 Uptake Refer Bug No 6341012

g_ledger_tbl PSA_FUNDS_CHECKER_PKG.num_rec;
g_event_tbl PSA_FUNDS_CHECKER_PKG.num_rec;

g_event_ind NUMBER;
g_ledger_ind NUMBER;

-- Private Function Definition:

/*R12 Uptake. Bug No 6341012 - Start*/

FUNCTION Get_Max_Result_Code(x_sev_rank OUT NOCOPY NUMBER) RETURN VARCHAR2;

PROCEDURE POPULATE_INTERFACE_TBL(
  p_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE PROCESS_CC_INT_LINES(
  p_budget_dest_flag IN VARCHAR2,
  p_mode IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE GET_EVENT_DETAILS(
  x_entity_type OUT NOCOPY VARCHAR2,
  x_event_type_code OUT NOCOPY VARCHAR2,
  p_org_id IN OUT NOCOPY NUMBER
);

PROCEDURE PROCESS_RESULTS(
  x_ret_status    OUT NOCOPY VARCHAR2,
  x_batch_result_code OUT NOCOPY VARCHAR2
);

PROCEDURE UNDO_GL_BC_PACKETS(
  p_ledger_array     IN PSA_FUNDS_CHECKER_PKG.num_rec,
  p_event_array      IN PSA_FUNDS_CHECKER_PKG.num_rec,
  p_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Status(
  x_sev_rank  OUT NOCOPY NUMBER
);

PROCEDURE Update_Event_ID;

PROCEDURE Restore_events_gt;

PROCEDURE Set_Batch_Result_Code(
  p_code IN VARCHAR2) ;

/*R12 Uptake. Bug No 6341012 - End*/

--Procedure, for registering time of execution of any operation
PROCEDURE Register_time(
   p_name  VARCHAR2,
   p_mode  BOOLEAN
);

PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

-- bug# 9231941: Procedure to delete the draft XLA entries that were
-- created due to funds checking.

PROCEDURE del_draft_xla_entries ;

/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Funds Check API for CC and PSB whenever Funds Check and/or Funds         */
/*  Funds Reservation need to be performed.                                  */
/*                                                                           */
/*  This routine returns TRUE if successful; otherwise, it returns FALSE     */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_*                                                           */
/*                                                                           */
/*  AOL Tables which are being used include :                                */
/*                                                                           */
/*            FND_*                                                          */
/*                                                                           */
/*  Return status two characters. First one for CBC, second for SBC          */
/*                'S' Success,                                               */
/*                'A' Advisory,                                              */
/*                'F' Failure                                                */
/*                'T' Fatal                                                  */
/*                'N' No records                                             */
/*                'U' Unreservation failed                                   */
/* ------------------------------------------------------------------------- */
-- Parameters   :
-- p_sobid      : set of books ID
-- p_header_id  : CC header ID
-- p_mode       : funds check mode - 'C', 'R' or 'F'
-- p_ret_status : return status of funds checking/reservation
-- p_actual_flag: 'E' for CC or 'B' for PSB
-- ssmales 25/01/02 bug 2201905 - added parameter p_packet_id
FUNCTION IGCFCK(
   p_sobid             IN  NUMBER,
   p_header_id         IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_actual_flag       IN  VARCHAR2,
   p_doc_type          IN  VARCHAR2,
   p_ret_status        OUT NOCOPY VARCHAR2,
   p_batch_result_code OUT NOCOPY VARCHAR2,
   p_debug             IN  VARCHAR2:=FND_API.G_FALSE,
   p_conc_proc         IN  VARCHAR2:=FND_API.G_FALSE
-- p_packet_id         IN  NUMBER
) RETURN BOOLEAN IS
   CURSOR c_cc_interface IS  --All records for CBC from interface table
     SELECT cc_header_id,
            cc_version_num,
            cc_acct_line_id,
            cc_det_pf_line_id,
            code_combination_id,
            batch_line_num,
            cc_transaction_date,
            cc_func_dr_amt ,
            cc_func_cr_amt ,
            je_source_name,
            je_category_name,
            actual_flag,
            set_of_books_id,
            encumbrance_type_id,
            budget_version_id,
            currency_code,
            transaction_description,
            reference_1,
            reference_2 ,
            reference_3 ,
            reference_4 ,
            reference_5 ,
            reference_6 ,
            reference_7 ,
            reference_8 ,
            reference_9 ,
            reference_10
       FROM igc_cc_interface_v a
      WHERE cc_header_id     = g_cc_header_id
--        AND budget_dest_flag = 'C'  /*R12 Uptake. Need to process for both Commitment and Standard budget*/
        AND actual_flag      = g_actual_flag
        AND document_type    = g_doc_type
   ORDER BY cc_transaction_date;

   l_api_name         CONSTANT VARCHAR2(30)   := 'IGCFCK';
   l_ccid             GL_CODE_COMBINATIONS.code_combination_id%TYPE;
   l_period_name      GL_PERIODS.period_name%TYPE;
   l_return_status    VARCHAR2(1);
   l_fc_return_status VARCHAR2(2);
   l_result_code      VARCHAR2(3);
   l_status_code      VARCHAR2(1);
   l_cbc_status       VARCHAR2(1);
   l_sbc_status       VARCHAR2(1);
   l_res              BOOLEAN;
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR(2000);
   l_cbc_flag         VARCHAR2(1);
   l_sbc_flag         VARCHAR2(1);
   l_rank               NUMBER(4);
   l_cbc_ret_status VARCHAR2(4);
   l_sbc_ret_status VARCHAR2(4);
   l_pop_ret_status VARCHAR2(4);
   l_pro_ret_status VARCHAR2(4);
   l_undo_ret_status  VARCHAR2(4);
-- ssmales 28/01/02 bug 2201905 - added variables below
   l_cc_header_rec    IGC_CC_INTERFACE%ROWTYPE ;
   l_full_path            VARCHAR2(255);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT     IGCFCK;
   l_full_path := g_path || 'IGCFCK';
   -- Initialize message list
   -- Unreserve Mode does not exist in R12. R12 Uptake Bug No 6341012
--   IF p_mode <> 'U' THEN
      FND_MSG_PUB.initialize;
--   END IF;

   /*TO DO: Get CBC Ledger ID from GL tables based on p_sobid*/

   /*Initialize the Ledger and Event Tables*/
   g_event_tbl := PSA_FUNDS_CHECKER_PKG.num_rec();
   g_ledger_tbl := PSA_FUNDS_CHECKER_PKG.num_rec();
   --Initialize global variables
   -- If packet id is not null, it means the call has come from outside
   -- CC module, primarily from the PO Funds Checker.
   -- Bidisha S, 28 Nov 2002

   g_cbc_flag                := TRUE;
   g_sbc_flag                := TRUE;
--   l_batch_status            := 'A';
   l_cbc_status              := 'N';
   l_sbc_status              := 'N';
   g_validation_error        := FALSE;
   g_mode                    := p_mode;
   g_resp_id                 := FND_GLOBAL.RESP_ID;
   g_update_login            := FND_GLOBAL.LOGIN_ID;
   g_update_by               := FND_GLOBAL.USER_ID;
   g_actual_flag             := p_actual_flag;
   g_cc_header_id            := p_header_id;
   g_set_of_books_id         := p_sobid ;
--   g_cbc_ledger_id       := 2599; /*Get from GL table based on p_sobid TO DO*/
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(p_debug);
   g_conc_proc               := FND_API.TO_BOOLEAN(p_conc_proc);
   /*Bug No 6341012. Need to modify the below procedure*/
   g_doc_type                := p_doc_type;
   g_batch_result_code       := 9999;
   g_validation_error        := FALSE;
   g_event_ind               := 0;
   g_ledger_ind              := 0;

-- ssmales 25/01/02 bug 2201905 - added line below
-- g_p_packet_id             := p_packet_id ;
-- --------------------------------------------------------------------
-- Obtain the application ID that will be used throughout this process.
-- --------------------------------------------------------------------
   SELECT application_id
     INTO g_gl_application_id
     FROM fnd_application
    WHERE application_short_name = 'SQLGL';

/*R12 Uptake Bug No 6341012. Obtain the IGC Application ID*/

   SELECT application_id
    INTO g_cc_application_id
    FROM fnd_application
    WHERE application_short_name = 'IGC';

   IGC_LEDGER_UTILS.get_cbc_ledger(p_primary_ledger_id => p_sobid,  p_cbc_ledger_id => g_cbc_ledger_id, p_cbc_ledger_Name => g_cbc_ledger_name);
   IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Secondary Ledger obtained based on primary Ledger: ' || g_cbc_ledger_id);
   END IF;
   g_cbc_enabled := IGC_LEDGER_UTILS.is_dual_bc_enabled(g_set_of_books_id);
   IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'CBC Enabled Flag: ' || g_cbc_enabled);
   END IF;
   IF (g_debug_mode <> 'Y') AND (p_debug = FND_API.G_TRUE)
   THEN
      g_debug_mode := 'Y';
   END IF;
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, SUBSTR('**************************************************************************************************',1,70));
      Put_Debug_Msg(l_full_path, SUBSTR('*********Starting CBC Funds Checker '||TO_CHAR(SYSDATE,'DD-MON-YY:MI:SS')||' *********************',1,70));
      Put_Debug_Msg(l_full_path, SUBSTR('**************************************************************************************************',1,70));
      Put_Debug_Msg(l_full_path, 'Parameters SOB:' || p_sobid ||' Mode: ' || p_mode || ' HeaderID ' ||p_header_id);
   END IF;

   /*Get the Rank for entries that already have CBC_RESULT_CODE. Based on the Rank set the Batch Result Code*/
   SELECT MIN(Get_Rank(cbc_result_code))
       INTO l_rank
       FROM igc_cc_interface_v a
       WHERE cc_header_id     = g_cc_header_id
           AND budget_dest_flag = 'C'
           AND actual_flag      = g_actual_flag
           AND document_type    = g_doc_type
           AND cbc_result_code IS NOT NULL;

       IF l_rank IS NOT NULL THEN
          IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg(l_full_path, 'The most severe found in the batch: '||l_rank);
          END IF;
          Set_Batch_Result_Code ( Get_Result_By_Rank(l_rank));
       END IF;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Validating interface table..');
      Register_time('',TRUE);
   END IF;

-- Commented Packet ID, as it is no longer used in R12. Bug No 6341012

   IGC_CBC_VALIDATIONS_PKG.Validate_CC_Interface
   (
          p_api_version               => 1.0,
          p_return_status             => l_return_status,
          p_msg_count                 => l_msg_count,
          p_msg_data                  => l_msg_data,
          p_sob_id                    => g_set_of_books_id,
          p_cbc_enabled               => g_cbc_enabled,
          p_cc_head_id                => g_cc_header_id,
          p_actl_flag                 => g_actual_flag,
          p_documt_type               => g_doc_type,
--          p_sum_line_num              => g_summary_line_num,
          p_cbc_flag                  => l_cbc_flag,
          p_sbc_flag                  => l_sbc_flag
--          p_packet_id                 => g_p_packet_id
       ) ;
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   g_cbc_flag  := FND_API.TO_BOOLEAN(l_cbc_flag);
   g_sbc_flag  := FND_API.TO_BOOLEAN(l_sbc_flag);
   IF NOT(g_cbc_flag) AND NOT(g_sbc_flag) THEN
     --No rows - return success.
     IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg(l_full_path, 'Now rows found - return success');
     END IF;
     p_ret_status := 'SN';
     p_batch_result_code:=NULL;
     RETURN(TRUE);
   END IF;
   IF (g_debug_mode = 'Y') THEN
      Register_time('Validate interface ',FALSE);
   END IF;

  -- bug# 9231941: Invoke the Procedure to delete the draft XLA entries that were
  -- created due to funds checking.

  del_draft_xla_entries;

/*R12 SLA Uptake Bug No 6341012 - Start*/
  /*PO will do Fund check*/
  IF g_doc_type IN ('REQ', 'PO', 'REL') THEN
    g_called_from_PO := TRUE;
    g_sbc_flag := FALSE;
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Called from PO - Standard Budget Fund Checker is disabled');
    END IF;
  END IF;

  /*Clearing previous entries if any*/
  g_event_tbl.DELETE;
  g_ledger_tbl.DELETE;

  POPULATE_INTERFACE_TBL(p_return_status => l_pop_ret_status);

  IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg(l_full_path, 'Populated Interface Table');
  END IF;

  IF (l_pop_ret_status = 'Y') THEN

    IF (g_cbc_flag) THEN
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'CBC records found');
            END IF;
      /*Fetch CBC Ledger ID from GL. SLA Uptake. Bug No 6341012*/
      /*GL need to provide table and column details*/
      /*Hard Coded as of now TO DO - At the Start of IGCFCK*/
      PROCESS_CC_INT_LINES(p_budget_dest_flag => 'C', p_mode => g_mode, x_return_status => l_cbc_ret_status);
      IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg(l_full_path, 'CBC Return Status: ' || l_cbc_ret_status);
      END IF;
                ELSE
                        l_cbc_ret_status := 'Y';
                        g_cbc_status := 'N';
    END IF;

    IF (l_cbc_ret_status = 'N' AND p_mode = 'F') THEN
      g_mode := 'C';
    END IF;

    IF (g_sbc_flag) THEN
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'SBC records found');
            END IF;
      PROCESS_CC_INT_LINES(p_budget_dest_flag => 'S', p_mode => g_mode, x_return_status => l_sbc_ret_status);
      IF (g_debug_mode = 'Y') THEN
              Put_Debug_Msg(l_full_path, 'SBC Return Status: ' || l_sbc_ret_status);
      END IF;
                ELSE
                        l_sbc_ret_status := 'Y';
                        g_sbc_status := 'N';
    END IF;
  END IF;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'CBC Status: ' || g_cbc_status || ' SBC Status: ' || g_sbc_status);
  END IF;

  IF g_sbc_status <> 'T' AND g_cbc_status <> 'T' AND l_cbc_ret_status = 'Y' AND l_sbc_ret_status = 'Y' THEN

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Processing Results...');
    END IF;

    PROCESS_RESULTS(
      x_ret_status => l_pro_ret_status,
      x_batch_result_code => g_batch_result_code
    );

    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Processed results - l_pro_ret_status has a value of ' || l_pro_ret_status);
      Put_Debug_Msg(l_full_path, 'Processed results. Updated Batch Result Code: ' || g_batch_result_code);
    END IF;

  END IF;


  IF (l_sbc_ret_status = 'N' OR l_cbc_ret_status = 'N') THEN
    ROLLBACK TO SAVEPOINT IGCFCK;
    Update_Event_ID;
    p_ret_status := g_cbc_status || g_sbc_status;
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Return Status: ' || p_ret_status);
    END IF;
    IF g_sbc_status <> 'T' AND g_cbc_status <> 'T' THEN
      PROCESS_RESULTS(
        x_ret_status => l_pro_ret_status,
        x_batch_result_code => g_batch_result_code
      );
      p_batch_result_code := g_batch_result_code;
    ELSE
      p_batch_result_code := NULL;
    END IF;
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Roll backed to Save point IGCFCK due to Funds Check failure');
      Put_Debug_Msg(l_full_path, 'Processed Results Status - l_pro_ret_status ' || l_pro_ret_status);
      Put_Debug_Msg(l_full_path, 'SBC Return Status: ' || l_sbc_ret_status || ' CBC Return Status: ' || l_cbc_ret_status );
    END IF;
    UNDO_GL_BC_PACKETS (
      p_ledger_array => g_ledger_tbl,
      p_event_array => g_event_tbl,
      p_return_status => l_undo_ret_status);
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'GL_BC_PACKETS Rollbacked Status: ' ||l_undo_ret_status);
    END IF;

    Restore_events_gt;

    RETURN FALSE;
  END IF;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'CBC Status: ' || g_cbc_status || ' SBC Status: ' || g_sbc_status);
  END IF;

  p_ret_status := g_cbc_status || g_sbc_status;

  p_batch_result_code := g_batch_result_code;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, 'Return Status: ' || p_ret_status || ' Batch Result Code: ' || p_batch_result_code);
  END IF;

  Restore_events_gt;

  RETURN (TRUE);

  EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK TO SAVEPOINT IGCFCK;
    p_ret_status := g_cbc_status || g_sbc_status;
    p_batch_result_code := NULL;
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Exception Occured ' || SQLERRM);
    END IF;

    UNDO_GL_BC_PACKETS (
      p_ledger_array => g_ledger_tbl,
      p_event_array => g_event_tbl,
      p_return_status => l_undo_ret_status);
    IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Exception Occured - Rollbacked GL_BC_PACKETS Status: ' || l_undo_ret_status);
    END IF;
    RETURN (FALSE);

  /*R12 SLA Uptake Bug No 6341012 - End*/

END IGCFCK;

FUNCTION Get_Batch_Result_Code (
  p_mode              VARCHAR2,
  p_batch_result_code VARCHAR2 )
RETURN VARCHAR2
IS
l_batch_result_code VARCHAR2(3);
l_ranked_result_code VARCHAR2(3);
-- 1947176, Aug 21 2001
CURSOR c_get_msg IS
    SELECT DISTINCT popup_messg_code
    FROM   igc_cc_result_code_ranks
    WHERE  action        = DECODE(p_mode,'F','R',p_mode)
    AND    severity_rank = p_batch_result_code;

   l_full_path            VARCHAR2(255);
BEGIN
   l_full_path := g_path || 'Get_Batch_Result_Code';
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'The most severe rank is: '||p_batch_result_code);
   END IF;
    -- The values now stored in table IGC_CC_RESULT_CODE_RANKS
    -- 1947176, Aug 21 2001
    OPEN  c_get_msg;
    FETCH c_get_msg INTO l_batch_result_code;
    CLOSE c_get_msg;
    RETURN l_batch_result_code;
    EXCEPTION
    WHEN OTHERS
    THEN
        RETURN NULL;
END Get_Batch_Result_Code;


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

PROCEDURE Register_time(
   p_name  VARCHAR2,
   p_mode  BOOLEAN
) IS
   l_full_path            VARCHAR2(255);
BEGIN
   l_full_path := g_path || 'Register_time';
   IF (p_mode) THEN
      g_date1:=DBMS_UTILITY.GET_TIME;
   ELSE
      g_date2 := DBMS_UTILITY.GET_TIME;
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path, 'Time ' || p_name || ': ' || TO_CHAR(g_date2-g_date1));
      END IF;
   END IF;
END Register_time;

FUNCTION Get_Rank(
  p_code IN VARCHAR2)
RETURN NUMBER
IS
l_batch_result_code NUMBER(4);
-- 1947176, Aug 21 2001
CURSOR c_get_rank IS
    SELECT DISTINCT severity_rank
    FROM   igc_cc_result_code_ranks
    WHERE  funds_checker_code = p_code;

   l_full_path            VARCHAR2(255);
BEGIN
   l_full_path := g_path || 'Get_Rank';
    --Selecting the Sevirity rank for result_code
    -- The values now stored in table IGC_CC_RESULT_CODE_RANKS
    -- 1947176, Aug 21 2001
    OPEN  c_get_rank;
    FETCH c_get_rank INTO l_batch_result_code;
    CLOSE c_get_rank;
    RETURN l_batch_result_code;
    EXCEPTION
    WHEN OTHERS
    THEN
         RETURN NULL;
END Get_Rank;

/* function determines status code, using result code */
FUNCTION Get_Status_By_Result(
   p_result_code   IN VARCHAR2)
RETURN VARCHAR2 IS
l_status_code VARCHAR2(1);
-- 1947176, Aug 21 2001
CURSOR c_get_result IS
    SELECT DISTINCT result_status_code
    FROM   igc_cc_result_code_ranks
    WHERE  funds_checker_code = p_result_code
    AND    action             = DECODE(g_mode, 'F', 'R', g_mode);

   l_full_path            VARCHAR2(255);
BEGIN
    l_full_path := g_path || 'Get_Status_By_Result';
      IF p_result_code IS NULL THEN
         RETURN '';
     ELSE
         -- The values now stored in table IGC_CC_RESULT_CODE_RANKS
         -- 1947176, Aug 21 2001
         OPEN  c_get_result;
         FETCH c_get_result INTO l_status_code;
         CLOSE c_get_result;
      END IF;
      RETURN l_status_code;
      EXCEPTION
      WHEN OTHERS
      THEN
          RETURN NULL;
END Get_Status_By_Result;

FUNCTION Get_Result_By_Rank(
 p_rank NUMBER )
RETURN VARCHAR2
IS
l_result_code VARCHAR2(3);
-- 1947176, Aug 21 2001
CURSOR c_get_result IS
    SELECT DISTINCT funds_checker_code
    FROM   igc_cc_result_code_ranks
    WHERE  severity_rank = p_rank;

   l_full_path            VARCHAR2(255);
BEGIN
   l_full_path := g_path || 'Get_Result_By_Rank';
    --Selecting the result_code, using the Sevirity rank
    -- Selecting the ranked result code, using result_code
    -- The values now stored in table IGC_CC_RESULT_CODE_RANKS
    -- 1947176, Aug 21 2001
    OPEN  c_get_result;
    FETCH c_get_result INTO l_result_code;
    CLOSE c_get_result;
    RETURN l_result_code;
    EXCEPTION
    WHEN OTHERS
    THEN
        RETURN NULL;
END Get_Result_By_Rank;

PROCEDURE Set_Batch_Result_Code(
  p_code IN VARCHAR2)
IS
l_batch_result_code NUMBER(4);
l_full_path            VARCHAR2(255);
BEGIN
  --Selecting the Sevirity rank for result_code
  l_full_path := g_path || 'Set_Batch_Result_Code';
  l_batch_result_code := Get_Rank (p_code);
  IF g_batch_result_code >  l_batch_result_code THEN
     g_batch_result_code := l_batch_result_code;
  END IF;
END Set_Batch_Result_Code;


/*R12 Uptake. Bug No 6341012 - Start*/

PROCEDURE POPULATE_INTERFACE_TBL(
  p_return_status OUT NOCOPY VARCHAR2
) IS
CURSOR c_pop_interface_tbl IS
SELECT DISTINCT cc_header_id,
  DOCUMENT_TYPE,
  BUDGET_DEST_FLAG,
  REFERENCE_4,
  CC_TRANSACTION_DATE,
  EVENT_ID,
  CC_DET_PF_LINE_ID
FROM IGC_CC_INTERFACE
WHERE event_id IS NULL
AND cc_header_id = g_cc_header_id;

l_full_path VARCHAR2(255);
l_err_code NUMBER;
l_err_msg  VARCHAR2(200);

BEGIN

l_full_path := g_path || 'POPULATE_INTERFACE_TBL';
OPEN c_pop_interface_tbl;
FETCH c_pop_interface_tbl BULK COLLECT INTO g_cc_interface_head_tbl;
CLOSE c_pop_interface_tbl;

p_return_status := 'Y';

EXCEPTION

WHEN OTHERS THEN

  p_return_status := 'N';
  l_err_code := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM,1,200);
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg (l_full_path,  'SQL Code: ' || l_err_code );
    Put_Debug_Msg (l_full_path,  'SQL Error Message: ' || l_err_msg);
  END IF;
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg (l_full_path,  'Failed to populate Data from Interface Table' );
  END IF;

END POPULATE_INTERFACE_TBL;

PROCEDURE PROCESS_CC_INT_LINES(
  p_budget_dest_flag IN VARCHAR2,
  p_mode IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
) IS

    l_entity_type VARCHAR2(100);
    l_event_type_code VARCHAR2(100);
    l_event_status_code VARCHAR2(1);
    l_event_number NUMBER;
    l_reference_info XLA_EVENTS_PUB_PKG.T_EVENT_REFERENCE_INFO;
    l_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
    l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
    l_event_id XLA_EVENTS_GT.EVENT_ID%TYPE;
    l_budget_dest_flag VARCHAR2(1);
    l_valuation_method VARCHAR2(3);

    l_err_code NUMBER;
    l_err_msg  VARCHAR2(200);

    /*Variables for PSA_BC_XLA_PUB.Budgetary_control - Start*/

    l_return_status VARCHAR2(100);
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(4000);
    l_status_code VARCHAR2(100);
    l_packet_id NUMBER;

    /*Variables for PSA_BC_XLA_PUB.Budgetary_control - End*/

    l_ledger_id NUMBER;
    l_application_id NUMBER;

    l_full_path VARCHAR2(255);
    l_sev_rank NUMBER;
    l_status_flag VARCHAR2(2);
    l_bud_cntrl VARCHAR2(1);
    l_bc_mode VARCHAR2(2);
    l_org_id NUMBER;

    CURSOR c_xla_events_gt IS
    SELECT * FROM psa_bc_xla_events_gt;

BEGIN

        l_full_path := g_path || 'PROCESS_CC_INT_LINES';
        x_return_status := 'Y';

        IF p_budget_dest_flag = 'C' THEN
          l_ledger_id := g_cbc_ledger_id;
                l_valuation_method := 'CBC';

                l_application_id := g_cc_application_id;
                IF (g_debug_mode = 'Y') THEN
                        Put_Debug_Msg (l_full_path,  'Processing Interface lines for Secondary Ledger (Commitment Budget)' );
                END IF;
        ELSIF p_budget_dest_flag = 'S' THEN
                l_ledger_id := g_set_of_books_id;
                l_valuation_method := 'SBC';

                l_application_id := g_cc_application_id;
                IF (g_debug_mode = 'Y') THEN
                        Put_Debug_Msg (l_full_path,  'Processing Interface lines for Primary Ledger (Standard Budget)' );
                END IF;
        END IF;

        /*Extend the Vector and add the Ledger ID. This is used for reversing the GL_BC_PACKETS in case the funds check fails*/
        g_ledger_tbl.EXTEND;
        g_ledger_ind := g_ledger_ind+1;
        g_ledger_tbl(g_ledger_ind) := l_ledger_id;

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Ledger ID: ' || l_ledger_id || ' Valuation Method: ' || l_valuation_method);
                Put_Debug_Msg (l_full_path,  'Getting Event Type Code and Entity Type' );
        END IF;

  l_org_id := MO_GLOBAL.get_current_org_id;

  IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Org ID: ' || l_org_id);
        END IF;

        GET_EVENT_DETAILS(
                x_entity_type => l_entity_type,
                x_event_type_code => l_event_type_code,
    p_org_id => l_org_id
        );

  l_security_context.security_id_int_1 := l_org_id;

  IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Security Context Set to: ' || l_security_context.security_id_int_1);
        END IF;

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Obtained Event Type Code and Entity Type' );
                Put_Debug_Msg (l_full_path,  'Entity Type Code: ' || l_entity_type || ' Event Type Code: ' || l_event_type_code);
        END IF;

	/*Backup records in psa_bc_xla_events_gt before deletion - May be required by calling module after FC call*/

	OPEN c_xla_events_gt;
	FETCH c_xla_events_gt BULK COLLECT INTO g_xla_events_gt_tbl;
	CLOSE c_xla_events_gt;

        DELETE FROM psa_bc_xla_events_gt pgt ;

/*
Commented due to issues during baselining - GT table has PA Events and IGC Events. This will cause PSA Funds Checker to fail with XLA-ERROR
PSA fails to fetch the correct Ledger due to Events from 2 different Applications i.e PA and IGC
*/
/*
  WHERE pgt.event_id IN
  (SELECT event_id FROM xla_events xe WHERE application_id = 8407 AND pgt.event_id = xe.event_id);
*/

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Deleted all Event entries from psa_bc_xla_events_gt' );
        END IF;

        FOR i IN 1..g_cc_interface_head_tbl.COUNT
        LOOP

                IF g_cc_interface_head_tbl(i).budget_dest_flag = p_budget_dest_flag THEN

                        l_event_source_info.source_application_id := NULL;
                        l_event_source_info.application_id        := l_application_id;
                        l_event_source_info.legal_entity_id       := NULL;
                        l_event_source_info.ledger_id             := l_ledger_id;
                        l_event_source_info.entity_type_code    := l_entity_type;
                        l_event_source_info.transaction_number    := g_cc_interface_head_tbl(i).reference_4;
                        l_event_source_info.source_id_int_1       := g_cc_interface_head_tbl(i).CC_HEADER_ID;
      /*
      Not Required as we have seperate Entity Codes for CC, Projects, PO and Requisition
                        l_event_source_info.source_id_char_1      := g_cc_interface_head_tbl(i).DOCUMENT_TYPE;
      */

                        l_event_status_code := XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED;

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg (l_full_path,  'Calling Create Event API...' );
                        END IF;

                        l_event_id := Xla_Events_Pub_Pkg.Create_Event
                        (
                        p_event_source_info => l_event_source_info,
                        p_event_type_code   => l_event_type_code,
                        p_event_date        => g_cc_interface_head_tbl(i).CC_TRANSACTION_DATE,
                        p_event_status_code => l_event_status_code,
                        p_event_number      => NULL,
                        p_reference_info    => l_reference_info,
                        p_valuation_method  => l_valuation_method,
                        p_security_context  => l_security_context,
                        p_budgetary_control_flag => 'Y'
                        );

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg (l_full_path,  'Completed Create Event' );
                        END IF;

                        /*Extend the Vector and add the Event ID. This is used for reversing the GL_BC_PACKETS in case the funds check fails*/
                        g_event_tbl.EXTEND;
                        g_event_ind := g_event_ind + 1;
                        g_event_tbl(g_event_ind) := l_event_id;

      g_cc_interface_head_tbl(i).event_id := l_event_id;

                        INSERT
                        INTO psa_bc_xla_events_gt(event_id,   result_code)
                        VALUES(l_event_id,   'XLA_ERROR');

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg (l_full_path,  'Inserted Event ID :' || l_event_id || ' into psa_bc_xla_events_gt' );
                        END IF;


                        UPDATE igc_cc_interface
                        SET event_id = l_event_id
                        WHERE cc_header_id = g_cc_interface_head_tbl(i).cc_header_id
                         AND document_type = g_cc_interface_head_tbl(i).document_type
                         AND budget_dest_flag = g_cc_interface_head_tbl(i).budget_dest_flag
                         AND reference_4 = g_cc_interface_head_tbl(i).reference_4
			 AND nvl(cc_det_pf_line_id, 1) = nvl(g_cc_interface_head_tbl(i).cc_det_pf_line_id, 1)
                         AND cc_transaction_date = g_cc_interface_head_tbl(i).cc_transaction_date;

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg (l_full_path,  'Inserted Event ID: ' || l_event_id || ' into psa_bc_xla_events_gt' );
                                Put_Debug_Msg (l_full_path,  'Update Event ID: ' || l_event_id || ' in IGC_CC_INTERFACE' );
                        END IF;

                END IF;

        END LOOP;

  IF p_mode = 'C' THEN
    l_bc_mode := 'M';
  ELSIF p_mode in ('R', 'F') THEN
    l_bc_mode := 'R';
  END IF;

  IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'BC Mode: ' || l_bc_mode);
        END IF;

        PSA_BC_XLA_PUB.Budgetary_control
        ( p_api_version  => 1.0,
         p_init_msg_list  => NULL,
         x_return_status  => l_return_status,
         x_msg_count      => l_msg_count,
         x_msg_data   => l_msg_data,
         p_application_id => l_application_id,
         p_bc_mode        => l_bc_mode,
         p_override_flag  => 'Y',
         P_user_id       => NULL,
         P_user_resp_id  => NULL,
         x_status_code  => l_status_code,
         x_Packet_ID    => l_packet_id
        );

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,
                        'Return Status: ' || l_return_status ||
                        ' Msg Count: ' || l_msg_count ||
                        ' Msg Data: ' || l_msg_data ||
                        ' Packet Id: ' || l_packet_id ||
                        ' Status Code: ' || l_status_code);
        END IF;

        select decode(l_status_code, 'ADVISORY' , 'SUCCESS', 'PARTIAL', 'FAIL', 'XLA_ERROR', 'FATAL', l_status_code)
        INTO l_status_code
        FROM DUAL;

        CASE l_status_code
                WHEN 'SUCCESS' THEN
                        x_return_status := 'Y';
                        Get_Status(x_sev_rank => l_sev_rank);

                        IF (g_debug_mode = 'Y') THEN
                                Put_Debug_Msg (l_full_path, 'Status Rank: ' || l_sev_rank);
                        END IF;

                        SELECT result_status_code INTO l_status_flag
                        FROM igc_cc_result_code_ranks
                        WHERE severity_rank = l_sev_rank
                                AND action = decode(g_mode, 'F', 'R', g_mode);

                        IF (p_budget_dest_flag = 'S') THEN
                                g_sbc_status := l_status_flag;
                        ELSE
                                g_cbc_status := l_status_flag;
                        END IF;
                WHEN 'FAIL' THEN
                        x_return_status := 'N';
                        IF (p_budget_dest_flag = 'S') THEN
                                g_sbc_status := 'F';
                        ELSE
                                g_cbc_status := 'F';
                        END IF;
                WHEN 'FATAL' THEN
                        x_return_status := 'N';
                        IF (p_budget_dest_flag = 'S') THEN
                                g_sbc_status := 'T';
                        ELSE
                                g_cbc_status := 'T';
                        END IF;
                WHEN 'XLA_NO_JOURNAL' THEN
                        x_return_status := 'N';
                        IF (p_budget_dest_flag = 'S') THEN
                                g_sbc_status := 'N';
                        ELSE
                                g_cbc_status := 'N';
                        END IF;
        END CASE;

EXCEPTION

WHEN OTHERS THEN
  x_return_status := 'N';
  l_err_code := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM,1,200);
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg (l_full_path,  'SQL Code: ' || l_err_code );
    Put_Debug_Msg (l_full_path,  'SQL Error Message: ' || l_err_msg);
  END IF;

END PROCESS_CC_INT_LINES;

PROCEDURE Get_Status(
  x_sev_rank  OUT NOCOPY NUMBER
) IS

l_max_sev_rank NUMBER;

BEGIN

        SELECT min(severity_rank) INTO l_max_sev_rank
        FROM igc_cc_result_code_ranks
        WHERE funds_checker_code IN(SELECT distinct(result_code)
                                        FROM GL_BC_PACKETS
                                        WHERE event_id IN (SELECT event_id
                                                                FROM
                                                                psa_bc_xla_events_gt));
        x_sev_rank := l_max_sev_rank;
END Get_Status;

PROCEDURE UNDO_GL_BC_PACKETS(
  p_ledger_array     IN PSA_FUNDS_CHECKER_PKG.num_rec,
  p_event_array      IN PSA_FUNDS_CHECKER_PKG.num_rec,
  p_return_status    OUT NOCOPY VARCHAR2

) IS

PRAGMA AUTONOMOUS_TRANSACTION;

l_err_code NUMBER;
l_err_msg VARCHAR2(200);
l_full_path VARCHAR2(255);

BEGIN

        l_full_path := g_path || 'UNDO_GL_BC_PACKETS';
        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Switching to Autonomous Transaction Mode' );
                Put_Debug_Msg (l_full_path,  'Undoing GL_BC_PACKETS by calling sync_xla_errors' );
        END IF;

        PSA_FUNDS_CHECKER_PKG.sync_xla_errors(
                p_failed_ldgr_array => p_ledger_array,
                p_failed_evnt_array => p_event_array
                );

        p_return_status := 'Y';

        COMMIT;

EXCEPTION

WHEN OTHERS THEN

  ROLLBACK;
  p_return_status := 'N';
  l_err_code := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM,1,200);
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg (l_full_path,  'SQL Code: ' || l_err_code );
    Put_Debug_Msg (l_full_path,  'SQL Error Message: ' || l_err_msg);
  END IF;

END UNDO_GL_BC_PACKETS;

PROCEDURE PROCESS_RESULTS(
  x_ret_status    OUT NOCOPY VARCHAR2,
  x_batch_result_code OUT NOCOPY VARCHAR2
)
IS

l_batch_result_code VARCHAR2(4);
l_sev_rank NUMBER;

l_err_code NUMBER;
l_err_msg VARCHAR2(200);
l_full_path VARCHAR2(255);

BEGIN
        -- Bug 8424832 : Added the save point to ensure all updates are
        --               reversed in case of any errors
        SAVEPOINT IGC_PROCESS_RESULTS;

        l_batch_result_code := NULL;
        l_full_path := g_path || 'PROCESS_RESULTS';
        x_ret_status := 'Y';


        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Updating Batch Result Code for CC Header ID: '|| g_cc_header_id);
        END IF;

        UPDATE igc_cc_interface int
        SET (batch_id,
            cbc_result_code,
            status_code,
            budget_version_id,
	    period_name,
	    encumbrance_type_id
      )
        =
        (
		SELECT distinct pac.je_batch_id,
                        pac.result_code,
                        pac.status_code,
                        pac.funding_budget_version_id,
			pac.period_name,
			pac.encumbrance_type_id
                FROM gl_bc_packets pac
                WHERE int.event_id = pac.event_id
                AND int.cc_acct_line_id = pac.source_distribution_id_num_1
--		Commented as it is causing issues with result updation Refer Bug 6628196
--                AND (nvl(pac.accounted_dr,   0) = nvl(INT.cc_func_dr_amt,   -1) OR nvl(pac.accounted_cr,   0) = nvl(INT.cc_func_cr_amt,   -1))
--      Bug 8424832 : Commented the following condition and replaced it with the one below
                --AND (sign(nvl(pac.accounted_dr,   0)) = sign(nvl(INT.cc_func_dr_amt,   -1)) OR sign(nvl(pac.accounted_cr,   0)) = sign(nvl(INT.cc_func_cr_amt,   -1)))
                AND (DECODE(pac.accounted_dr,NULL,'1','DR') = DECODE(int.cc_func_dr_amt,NULL,'2','DR') OR
                     DECODE (pac.accounted_cr,NULL,'1','CR') = DECODE(INT.cc_func_cr_amt,NULL,'2','CR'))
        )
        WHERE
        int.cbc_result_code IS NULL AND
        int.cc_header_id = g_cc_header_id;

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Number of rows updated: ' || SQL%ROWCOUNT);
                Put_Debug_Msg (l_full_path,  'Calling Get Maximum Result Code');
        END IF;

        l_batch_result_code := Get_Max_Result_Code(l_sev_rank);

	/*Gets Pop up Message Code. This has to be returned to Wrapper package*/

        x_batch_result_code := Get_Batch_Result_Code(g_mode, l_sev_rank);

        x_ret_status := 'Y';

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'Process Results Return Status: ' || x_ret_status || ' Batch Result Code: ' || x_batch_result_code);
        END IF;

EXCEPTION

WHEN OTHERS THEN
  -- Bug 8424832 : Blank rollback resulted in rollback of PSA updates
  ROLLBACK TO IGC_PROCESS_RESULTS;
  x_ret_status := 'N';
  x_batch_result_code := NULL;
  l_err_code := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM,1,200);
  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg (l_full_path,  'SQL Code: ' || l_err_code );
    Put_Debug_Msg (l_full_path,  'SQL Error Message: ' || l_err_msg);
  END IF;

END PROCESS_RESULTS;

PROCEDURE GET_EVENT_DETAILS(
  x_entity_type OUT NOCOPY VARCHAR2,
  x_event_type_code OUT NOCOPY VARCHAR2,
  p_org_id IN OUT NOCOPY NUMBER
) IS

CURSOR c_igc_head IS
SELECT cc_state
FROM igc_cc_headers
WHERE cc_header_id = g_cc_header_id;

l_doc_type VARCHAR2(100);
l_cc_state VARCHAR2(2);
l_full_path VARCHAR2(255);

/*Added for CBC Upgrade - Start*/

l_reference_8 VARCHAR2(5);
l_je_category_name	VARCHAR2(100);

/*Added for CBC Upgrade - End*/

BEGIN

  l_full_path := g_path || 'Get Event Details';

  OPEN c_igc_head;
  FETCH c_igc_head INTO l_cc_state;
  CLOSE c_igc_head;

  l_doc_type := g_cc_interface_head_tbl(1).document_type;

  IF l_doc_type = 'CC' THEN
   /*Added for CBC Upgrade - Start*/
   SELECT distinct reference_8
   INTO l_reference_8
   FROM igc_cc_interface
   WHERE cc_header_id = g_cc_header_id;
   IF (l_reference_8 IS NULL) THEN
   /*Added for CBC Upgrade - End*/
    IF (p_org_id IS NULL) THEN
      SELECT org_id INTO p_org_id
      FROM igc_cc_headers_all
      WHERE cc_header_id = g_cc_header_id;
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'Org ID: '|| p_org_id || ' obtained from igc_cc_headers_all');
      END IF;
    END IF;
    x_entity_type := 'CC_CONTRACTS';
    IF l_cc_state = 'PR' THEN
      x_event_type_code := 'CC_CONTRACT_PRO_RESERVE';
    ELSIF l_cc_state = 'CL' THEN
      x_event_type_code := 'CC_CONTRACT_PRO_CANCEL';
    ELSIF l_cc_state = 'CM' THEN
      x_event_type_code := 'CC_CONTRACT_CMT_RESERVE';
    ELSIF l_cc_state = 'CT' THEN
      x_event_type_code := 'CC_CONTRACT_CMT_COMPLETE';
    END IF;
   /*Added for CBC Upgrade - Start*/
   ELSIF (l_reference_8 = 'MIG') THEN
    SELECT distinct je_category_name INTO l_je_category_name
    FROM igc_cc_interface
    WHERE cc_header_id = g_cc_header_id;
    IF (l_je_category_name = 'Provisional') THEN
	x_entity_type := 'CC_CONTRACTS';
	x_event_type_code := 'CC_CONTRACT_PRO_RESERVE';
    ELSIF (l_je_category_name = 'Confirmed') THEN
	x_entity_type := 'CC_CONTRACTS';
	x_event_type_code := 'CC_CONTRACT_CMT_RESERVE';
    END IF;
   END IF;
   /*Added for CBC Upgrade - End*/
  ELSIF l_doc_type = 'REQ' THEN
    IF (p_org_id IS NULL) THEN
      SELECT org_id INTO p_org_id
      FROM po_requisition_headers_all
      WHERE requisition_header_id = g_cc_header_id;
            IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'Org ID: '|| p_org_id || ' obtained from po_requisition_headers_all' );
            END IF;
    END IF;
    x_entity_type := 'CC_REQUISITIONS';
    x_event_type_code := 'CC_REQUISITION_EVENT';
  ELSIF l_doc_type in ('PO', 'REL') THEN
    IF (p_org_id IS NULL) THEN
      SELECT org_id INTO p_org_id
      FROM po_headers_all
      WHERE po_header_id = g_cc_header_id;
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'Org ID: '|| p_org_id || ' obtained from po_headers_all' );
      END IF;
    END IF;
    x_entity_type := 'CC_PURCHASE_ORDERS';
    x_event_type_code := 'CC_PURCHASE_ORDER_EVENT';
  ELSIF l_doc_type = 'PA' THEN
    IF (p_org_id IS NULL) THEN
      SELECT proj.org_id INTO p_org_id
      FROM pa_budget_versions BUD,
      pa_projects_all PROJ
      WHERE proj.project_id = bud.project_id
      AND bud.budget_version_id = g_cc_header_id;
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'Org ID: '|| p_org_id || ' obtained from pa_budget_versions' );
      END IF;
    END IF;
    x_entity_type := 'CC_PROJECTS';
    x_event_type_code := 'CC_PROJECT_BUDGET_BASELINE';
  END IF;

END GET_EVENT_DETAILS;

PROCEDURE Restore_events_gt IS

BEGIN

	FOR i IN 1..g_xla_events_gt_tbl.COUNT
	LOOP
		INSERT INTO psa_bc_xla_events_gt (event_id, result_code)
		VALUES (g_xla_events_gt_tbl(i).event_id, g_xla_events_gt_tbl(i).result_code);
	END LOOP;

END Restore_events_gt;

PROCEDURE Update_Event_ID IS

BEGIN

  FOR i IN 1..g_cc_interface_head_tbl.COUNT
  LOOP

    UPDATE igc_cc_interface SET event_id = g_cc_interface_head_tbl(i).event_id
    WHERE
    cc_header_id = g_cc_interface_head_tbl(i).cc_header_id AND
    document_type = g_cc_interface_head_tbl(i).document_type AND
    budget_dest_flag = g_cc_interface_head_tbl(i).budget_dest_flag AND
    cc_transaction_date = g_cc_interface_head_tbl(i).cc_transaction_date AND
    nvl(cc_det_pf_line_id, 1) = nvl(g_cc_interface_head_tbl(i).cc_det_pf_line_id, 1) AND
    reference_4 = g_cc_interface_head_tbl(i).reference_4;

  END LOOP;

END Update_Event_ID;

FUNCTION Get_Max_Result_Code(x_sev_rank OUT NOCOPY NUMBER) RETURN VARCHAR2
IS

l_batch_result_code igc_cc_result_code_ranks.funds_checker_code%TYPE;
l_err_code NUMBER;
l_err_msg VARCHAR2(200);
l_full_path VARCHAR2(255);

BEGIN

l_batch_result_code := NULL;
l_full_path := g_path || 'Get Max Result Code';

        IF (g_debug_mode = 'Y') THEN
                Put_Debug_Msg (l_full_path,  'CC Header ID: '|| g_cc_header_id );
        END IF;

        SELECT distinct funds_checker_code, severity_rank INTO l_batch_result_code, x_sev_rank
        FROM igc_cc_result_code_ranks
        WHERE severity_rank =
        (
                SELECT min(severity_rank)
                FROM igc_cc_result_code_ranks
                WHERE funds_checker_code IN
                (
                        SELECT TRIM(cbc_result_code)
                        FROM igc_cc_interface
                        WHERE cc_header_id = g_cc_header_id
                )
        );

        RETURN l_batch_result_code;

END Get_Max_Result_Code;

/*R12 Uptake. Bug No 6341012 - End*/

-- bug# 9231941: Procedure to delete the draft XLA entries that were
-- created due to funds checking.

PROCEDURE del_draft_xla_entries IS

  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_security_context XLA_EVENTS_PUB_PKG.T_SECURITY;
  l_org_id NUMBER;
  l_full_path VARCHAR2(255);
  l_err_code NUMBER;
  l_err_msg  VARCHAR2(200);

  CURSOR c_del_events is
    SELECT
      eve.event_id, xle.valuation_method, xle.ledger_id, igch.cc_num,
      igch.org_id
    FROM igc_cc_headers_all igch,
    xla_transaction_entities xle,
    xla_events eve
    WHERE xle.source_id_int_1 = igch.cc_header_id
    AND xle.entity_id = eve.entity_id
    AND igch.cc_header_id = g_cc_header_id
    AND eve.event_status_code = 'U'
    AND eve.process_status_code = 'D'
    AND xle.entity_code = 'CC_CONTRACTS'
    AND xle.application_id = eve.application_id
    AND eve.application_id = 8407;

BEGIN
    l_full_path := g_path || 'del_draft_xla_entries';
    Put_Debug_Msg (l_full_path,  'Entering Procedure del_draft_xla_entries ');
    l_event_source_info.source_application_id := NULL;
    l_event_source_info.application_id        := g_cc_application_id;
    l_event_source_info.legal_entity_id       := NULL;
    l_event_source_info.entity_type_code      := 'CC_CONTRACTS';
    l_event_source_info.source_id_int_1       := g_cc_header_id;


    FOR j IN c_del_events LOOP
      l_event_source_info.ledger_id  := j.ledger_id;
      l_event_source_info.transaction_number    := j.cc_num;
      l_security_context.security_id_int_1 := j.org_id;

      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'l_event_source_info.application_id: ' ||l_event_source_info.application_id);
        Put_Debug_Msg (l_full_path,  'l_event_source_info.source_id_int_1: ' ||l_event_source_info.source_id_int_1);
        Put_Debug_Msg (l_full_path,  'l_event_source_info.ledger_id: ' ||l_event_source_info.ledger_id );
        Put_Debug_Msg (l_full_path,  'l_event_source_info.transaction_number: ' ||l_event_source_info.transaction_number);
        Put_Debug_Msg (l_full_path,  'l_security_context.security_id_int_1: ' ||l_security_context.security_id_int_1);
        Put_Debug_Msg (l_full_path,  'j.valuation_method: ' ||j.valuation_method);
        Put_Debug_Msg (l_full_path,  'Invoking XLA_EVENTS_PUB_PKG.DELETE_EVENT API for event_id: ' ||j.event_id);
      END IF;

      XLA_EVENTS_PUB_PKG.DELETE_EVENT(
        p_event_source_info => l_event_source_info,
        p_event_id          => j.event_id,
        p_valuation_method  => j.valuation_method,
        p_security_context  => l_security_context);
        IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,  'event_id: ' ||j.event_id ||' successfully deleted ');
      END IF;
    END LOOP;

    Put_Debug_Msg (l_full_path,  'Exiting Procedure del_draft_xla_entries ');

    EXCEPTION
    WHEN OTHERS THEN

      l_err_code := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM,1,200);
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'SQL Code: ' || l_err_code );
        Put_Debug_Msg (l_full_path,  'SQL Error Message: ' || l_err_msg);
      END IF;
      IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg (l_full_path,  'Failed to delete event' );
      END IF;
      RAISE;

END del_draft_xla_entries;

END IGC_CBC_FUNDS_CHECKER;

/
