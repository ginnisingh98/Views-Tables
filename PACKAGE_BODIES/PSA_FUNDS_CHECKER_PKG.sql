--------------------------------------------------------
--  DDL for Package Body PSA_FUNDS_CHECKER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_FUNDS_CHECKER_PKG" AS
/* $Header: psafbcfb.pls 120.99.12010000.13 2010/01/28 19:09:35 sasukuma ship $ */



  /*=============================================================================+
   | SegNamArray           :    contains all Active Segments                     |
   | TokNameArray          :    contains names of all tokens                     |
   | TokValArray           :    contains values for all tokens                   |
   | g_delim               :    Used as a delimiter in the Debug Info String     |
   | seg_name              :    Active Segments                                  |
   | seg_val               :    Segment Values. This is typecast to the          |
   |                            definition in the Flex Package FND_FLEX_EXT      |
   | msg_tok_names         :    Message Token Name                               |
   | msg_tok_val           :    Message Token Value                              |
   | g_num_segs            :    Number of active segments                        |
   | g_acct_seg_index      :    Accounting Segment Index                         |
   | g_ledger_id           :    Ledger Id                                        |
   | g_packet_id           :    Packet ID for the Packet being processed         |
   | g_fcmode              :    Operation Mode. Valid Modes are :                |
   |                            'C' for Funds Check (partial),                   |
   |                            'R' for Funds Reservation,                       |
   |                            'A' for Funds Adjustment which is identical      |
   |                                to Funds Reservation except for the          |
   |                                difference in Messages,                      |
   |                            'F' for Force Pass                               |
   |                            'U' for Unreservation &                          |
   |                            'P' for Partial Reservation                      |
   |                            'M' for Funds Check (Full Mode)                  |
   | g_partial_resv_flag   :    Whether Partial Reservation is allowed           |
   | g_return_code         :    Funds Check Return Code for the Packet           |
   |                            processed. Valid Return Codes are :              |
   |                            'S' for Success,                                 |
   |                            'A' for Advisory,                                |
   |                            'F' for Failure,                                 |
   |                            'P' for Partial,                                 |
   |                            'F' for Force Pass &                             |
   |                            'T' for Fatal                                    |
   | gms_retcode           :    Funds Check Return code for grants processing    |
   | g_psa_grantcheck      :    Is GMS Enabled                                   |
   | g_psa_pacheck         :    Is PA Enabled                                    |
   | g_cbc_enabled         :    Is CBC Enabled                                   |
   | g_packet_id_ursvd     :    ID of the Packet being unreserved                |
   | g_ussgl_option_flag   :    Whether the USSGL Option is Enabled              |
   | g_budgetary_enc_flag  :    Whether to default Automatic Encumbrance Flag    |
   |                            to 'Y' for Budgetary Encumbrances Transactions   |
   | g_user_id             :    AOL User Id                                      |
   | g_resp_appl_id        :    Calling Application Id                           |
   | g_user_resp_id        :    User Responsibility Id                           |
   | g_conc_flag           :    Whether invoked from a concurrent process        |
   | g_calling_prog_flag   :    Which module invoked the call. Valid values :    |
   |                            'G' for General Ledger &                         |
   |                            'S' for Subledger via SLA                        |
   | g_override_flag       :    Override Transaction if it fails Funds Check     |
   | g_bc_option_id        :    Budgetary Control Option assigned to the User    |
   | g_coa_id              :    Flex Num for the Accounting Flexfield Structure  |
   | g_func_curr_code      :    Functional Currency Code                         |
   | g_append_je_flag      :    Whether there are associated Journal Entry lines |
   |                            to be appended, created or deleted               |
   | g_summarized_flag     :    Whether there are Summary Transactions in the    |
   |                            Packet                                           |
   | g_arrival_seq         :    Arrival Sequence Number of the Packet in process |
   | g_no_msg_tokens       :    Number of messages tokens                        |
   | g_reverse_tc_flag     :    Profile GL_REVERSE_TC_OPTION                     |
   | g_enable_efc_flag     :    Profile PSA_ENABLE_EFC                           |
   | g_fv_prepay_prof      :    FV profile option                                |
   | g_debug               :    Global Variable used for debugging purpose       |
   | g_xla_debug           :    Global Variable used for SLA debugging purpose   |
   | g_overlapping_budget  :    Check if  there are multiple overlapping budgets |
   |                            for the account                                  |
   | g_session_id          :    Current Session Identifier                       |
   | g_serial_id           :    Current Session Serial# Identifier               |
   +=============================================================================*/

  TYPE SegNamArray IS TABLE OF VARCHAR2(9) INDEX BY BINARY_INTEGER;

  TYPE TokNameArray IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  g_delim               CONSTANT VARCHAR2(1) := '[';

  seg_name              SegNamArray;

  seg_val               FND_FLEX_EXT.SegmentArray;

  msg_tok_names         TokNameArray;

  msg_tok_val           TokValArray;

  g_num_segs            NUMBER;

  g_acct_seg_index      NUMBER;

  g_ledger_id           gl_bc_packets.ledger_id%TYPE;

  g_packet_id           gl_bc_packets.packet_id%TYPE;

  g_fcmode              VARCHAR2(1);

  g_partial_resv_flag   VARCHAR2(1);

  g_return_code         gl_bc_packets.result_code%TYPE;

  gms_retcode            gl_bc_packets.result_code%TYPE;

  g_psa_grantcheck       BOOLEAN;

  g_psa_pacheck          BOOLEAN;

  g_cbc_enabled          BOOLEAN;

  g_cbc_retcode         NUMBER;

  g_packet_id_ursvd     gl_bc_packets.packet_id%TYPE;

  g_ussgl_option_flag   BOOLEAN;

  g_budgetary_enc_flag  VARCHAR2(1);

  g_user_id             fnd_user.user_id%TYPE;

  g_resp_appl_id        fnd_application.application_id%TYPE;

  g_user_resp_id        fnd_responsibility.responsibility_id%TYPE;

  g_conc_flag           BOOLEAN;

  g_calling_prog_flag   VARCHAR2(1);

  g_override_flag       BOOLEAN;

  g_bc_option_id        gl_bc_options.bc_option_id%TYPE;

  g_coa_id              gl_ledgers_public_v.chart_of_accounts_id%TYPE;

  g_func_curr_code      gl_ledgers_public_v.currency_code%TYPE;

  g_append_je_flag      BOOLEAN;

  g_summarized_flag     BOOLEAN;

  g_arrival_seq         gl_bc_packet_arrival_order.arrival_seq%TYPE;

  g_no_msg_tokens       NUMBER;

  g_requery_flag        BOOLEAN;

  g_reverse_tc_flag     VARCHAR2(1) := 'Y';

  g_enable_efc_flag     VARCHAR2(1) := 'N';

  g_fv_prepay_prof      BOOLEAN := FALSE;

  g_xla_debug      BOOLEAN := FALSE;

  g_overlapping_budget          BOOLEAN;

  g_session_id          NUMBER;

  g_serial_id           NUMBER;

  --===========================FND_LOG.START=====================================
  g_state_level NUMBER          :=    FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER          :=    FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER          :=    FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER          :=    FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER          :=    FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER          :=    FND_LOG.LEVEL_UNEXPECTED;
  g_path        VARCHAR2(50)    :=    'psa.plsql.psafbcfb.psa_funds_checker_pkg.';
  --===========================FND_LOG.END=======================================


  /*================================+
   |    Private Function Definition    |
   +================================*/

  FUNCTION glxfin(p_ledgerid          IN NUMBER,
                  p_packetid          IN NUMBER,
                  p_mode              IN VARCHAR2,
                  p_override          IN VARCHAR2,
                  p_conc_flag         IN VARCHAR2,
                  p_user_id           IN NUMBER,
                  p_user_resp_id      IN NUMBER,
                  p_calling_prog_flag IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION glxfcp RETURN BOOLEAN;

  FUNCTION glxfug RETURN BOOLEAN;

  FUNCTION glxfkf RETURN BOOLEAN;

  FUNCTION glxfiu RETURN BOOLEAN;

  FUNCTION glxfss RETURN BOOLEAN;

  FUNCTION glxfgb RETURN BOOLEAN;

  FUNCTION glxfrc RETURN BOOLEAN;

  FUNCTION glzcbc RETURN NUMBER;

  FUNCTION glzgchk RETURN BOOLEAN;

  FUNCTION glzpafck RETURN BOOLEAN;

  FUNCTION glxfor RETURN BOOLEAN;

  FUNCTION glxfrs RETURN BOOLEAN;

  FUNCTION glrchk(post_control IN gl_bc_packets.result_code%TYPE) RETURN BOOLEAN;

  FUNCTION glxfje RETURN BOOLEAN;

  FUNCTION glxfuf RETURN BOOLEAN;

  FUNCTION glxcon RETURN BOOLEAN;

  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2);

  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2);

  FUNCTION glxfar RETURN BOOLEAN;

  FUNCTION fv_prepay_pkg RETURN BOOLEAN;

  FUNCTION glurevd ( p_ledger_id NUMBER,
                     p_je_category     VARCHAR2,
                     p_je_source     VARCHAR2,
                     p_je_period     VARCHAR2,
                     p_je_date         DATE,
                     x_reversal_method  OUT NOCOPY    VARCHAR2,
                     p_balance_type VARCHAR2) RETURN BOOLEAN;

  PROCEDURE get_session_details(x_session_id OUT NOCOPY NUMBER,
                                x_serial_id  OUT NOCOPY NUMBER);

  PROCEDURE init
  IS
    l_path_name       VARCHAR2(500);
    l_file_info       VARCHAR2(2000);
  BEGIN
    l_path_name := g_path || '.init';
    l_file_info := '$Header: psafbcfb.pls 120.99.12010000.13 2010/01/28 19:09:35 sasukuma ship $';
    psa_utils.debug_other_string(g_state_level,l_path_name,  'PSA_FUNDS_CHECKER version = '||l_file_info);
  END;


/* ------------------------------------------------------------------------- */
/*                                                                           */
/*  Funds Check API for any process that needs to perform Funds Check and/or */
/*  Funds Reservation                                                        */
/*                                                                           */
/*  This routine returns TRUE if successful; otherwise, it returns FALSE     */
/*                                                                           */
/*  In case of failure, this routine will populate the global Message Stack  */
/*  using FND_MESSAGE. The calling routine will retrieve the message from    */
/*  the Stack                                                                */
/*                                                                           */
/*  When invoked from a Concurrent Process, the calling process has to       */
/*  initialize values for User ID, User Responsibility ID, Calling           */
/*  Application ID and Login ID. These values should be initialized, in the  */
/*  Global Stack by invoking FND_GLOBAL, prior to calling Funds Checker      */
/*                                                                           */
/*  External Packages which are being invoked include :                      */
/*                                                                           */
/*            FND_GLOBAL                                                     */
/*            FND_PROFILE                                                    */
/*            FND_INSTALLATION                                               */
/*            FND_MESSAGE                                                    */
/*            FND_FLEX_EXT                                                   */
/*            FND_FLEX_APIS                                                  */
/*                                                                           */
/*  GL Tables which are being used include :                                 */
/*                                                                           */
/*            GL_BC_PACKETS                                                  */
/*            GL_BC_PACKET_ARRIVAL_ORDER                                     */
/*            GL_BC_OPTIONS                                                  */
/*            GL_BC_OPTION_DETAILS                                           */
/*            GL_BC_PERIOD_MAP                                               */
/*            GL_BC_DUAL                                                     */
/*            GL_BC_DUAL2                                                    */
/*            GL_CONCURRENCY_CONTROL                                         */
/*            GL_PERIOD_STATUSES                                             */
/*            GL_LOOKUPS                                                     */
/*            GL_USSGL_TRANSACTION_CODES                                     */
/*            GL_USSGL_ACCOUNT_PAIRS                                         */
/*            GL_BALANCES                                                    */
/*            GL_BUDGETS                                                     */
/*            GL_BUDGET_VERSIONS                                             */
/*            GL_BUDGET_ASSIGNMENTS                                          */
/*            GL_BUDGET_PERIOD_RANGES                                        */
/*            GL_JE_BATCHES                                                  */
/*            GL_JE_HEADERS                                                  */
/*            GL_JE_LINES                                                    */
/*            GL_SETS_OF_BOOKS                                               */
/*            GL_CODE_COMBINATIONS                                           */
/*            GL_ACCOUNT_HIERARCHIES                                         */
/*                                                                           */
/*  AOL Tables which are being used include :                                */
/*                                                                           */
/*            FND_USER                                                       */
/*            FND_APPLICATION                                                */
/*            FND_RESPONSIBILITY                                             */
/*            FND_PROFILE_OPTION_VALUES                                      */
/*            FND_PRODUCT_INSTALLATIONS                                      */
/*                                                                           */
/* ------------------------------------------------------------------------- */

  -- Parameters :

  -- p_ledgerid : Set of Books ID

  -- p_packetid : Packet ID

  -- p_mode : Funds Checker Operation Mode. Defaults to 'C' (Checking)

  -- p_override : Whether to Override in case of Funds Reservation failure
  --              because of lack of Funds. Defaults to 'N' (No)

  -- p_conc_flag : Whether invoked from a Concurrent Process. Defaults to
  --               'N' (No)

  -- p_user_id : User ID for Override (from AP AutoApproval)

  -- p_user_resp_id : User Responsibility ID for Override (from AP AutoApproval)

  -- p_return_code : Return Status for the Packet

  --
  -- Overloaded Version of glxfck()
  -- This contains an additional OUT parameter p_unrsv_packet_id.
  -- This is to be used by General Ledger only.
  --

  FUNCTION glxfck(p_ledgerid          IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'G',
                  p_return_code       OUT NOCOPY   VARCHAR2,
                  p_unrsv_packet_id   OUT NOCOPY   NUMBER) RETURN BOOLEAN IS

    others  EXCEPTION;

        -- ========================= FND LOG ===========================
           l_full_path VARCHAR2(100);
        -- ========================= FND LOG ===========================
  BEGIN

          l_full_path := g_path || 'glxfck - public1';

    -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ledgerid          -> ' || p_ledgerid);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_packetid          -> ' || p_packetid);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_mode              -> ' || p_mode);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override          -> ' || p_override);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_conc_flag         -> ' || p_conc_flag);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_id           -> ' || p_user_id);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag -> ' || p_calling_prog_flag);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_resp_id      -> ' || p_user_resp_id);
         -- ========================= FND LOG ===========================

    IF NOT glxfck(    p_ledgerid          ,
                      p_packetid          ,
                      p_mode              ,
                      p_override          ,
                      p_conc_flag         ,
                      p_user_id           ,
                      p_user_resp_id      ,
                      p_calling_prog_flag ,
                      p_return_code       ) THEN

     -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfck --> FALSE goto gl_error');
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_return_code --> ' || p_return_code);
         -- ========================= FND LOG ===========================
         goto gl_error;

    END IF;

    IF (p_return_code = 'O') THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_return_code --> O goto normal_exit');
         -- ========================= FND LOG ===========================

        goto normal_exit;
    END IF;

    -- Set p_unrsv_packet_id if mode is UNRESERVATION
    -- and g_requery_flag is not set.

    IF (p_mode = 'U' AND NOT g_requery_flag) THEN
        p_unrsv_packet_id := p_packetid;
        -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' p_unrsv_packet_id --> ' ||  p_unrsv_packet_id );
            -- ========================= FND LOG ===========================
    END IF;

    -- If g_requery_flag is TRUE set p_return_code = "Q"
    -- for calling form (MJE) to requery instead of the
    -- regular commit. [p_return code "Q" => Success/Advisory]

    IF g_requery_flag THEN
       p_return_code := 'Q';
       -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' p_return_code --> Q => Success/Advisory ');
           -- ========================= FND LOG ===========================
    END IF;

    <<NORMAL_EXIT>>

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
        -- ========================= FND LOG ===========================

        RETURN(TRUE);

    <<GL_ERROR>>

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' reached gl_error label ');
        -- ========================= FND LOG ===========================

        if not glxfuf then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' Raise OTHERS ');
           -- ========================= FND LOG ===========================
           raise others;
        end if;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> FALSE ');
        -- ========================= FND LOG ===========================

        RETURN(FALSE);

  EXCEPTION

    WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
      -- ========================= FND LOG ===========================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN --> FALSE ');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glxfck;

 /* =========================== GLXFCK PRIVATE ================================= */

  FUNCTION glxfck(p_ledgerid          IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'S',
                  p_return_code       OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    cursor det_override_reqd IS
        select 'x'
        from gl_bc_packets bp
        where bp.packet_id = g_packet_id
             and bp.result_code between 'F00' and 'F19'
             and bp.ussgl_link_to_parent_id is null
             and bp.template_id is null
             and nvl(bp.override_amount, -1) >=
                 abs(nvl(bp.accounted_dr, 0) - nvl(bp.accounted_cr, 0))
             and not exists
          (
           select 'If Partial Resv disallowed then all non-generated ' ||
                  'detail lines that failed with any validation errors ' ||
                  'or because of Funds Availability'
             from gl_bc_packets pk
            where pk.packet_id = g_packet_id
              and pk.template_id is null
              and pk.result_code like 'F%'
              and ((g_partial_resv_flag = 'N'
                and pk.ussgl_link_to_parent_id is null
                and (pk.result_code between 'F20' and 'F29'
                  or nvl(pk.override_amount, -1) <
                     abs(nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0))))
                 or (pk.ussgl_link_to_parent_id = bp.ussgl_parent_id
                 and pk.result_code between 'F20' and 'F29'))
          );

    cursor ussgl_override_reqd is
        select 'x'
        from gl_bc_packets bp
         where bp.packet_id = g_packet_id
             and bp.result_code between 'F00' and 'F19'
             and bp.ussgl_link_to_parent_id is not null
             and exists
              (
                    select 'Corresp Original Transaction which was Overridden'
                 from  gl_bc_packets pk
                 where pk.packet_id = g_packet_id
                     and pk.ussgl_parent_id = bp.ussgl_link_to_parent_id
                     and pk.result_code = 'P21'
              );

    l_override_reqd    VARCHAR2(1);
    others          EXCEPTION;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

    l_full_path := g_path || 'glxfck - private';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFCK PRIVATE - START' );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ledgerid             -> ' || p_ledgerid);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_packetid          -> ' || p_packetid);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_mode              -> ' || p_mode);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override          -> ' || p_override);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_conc_flag         -> ' || p_conc_flag);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_id           -> ' || p_user_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_resp_id      -> ' || p_user_resp_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag -> ' || p_calling_prog_flag);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfin ');
    -- ========================= FND LOG =============================

    if (p_calling_prog_flag = 'S' and g_fcmode = 'U') then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling Program = S and mode = Unreservation so return without processing. RETURN -> TRUE.' );
       -- =========================== FND LOG ===========================
        -- Since we will not be supporting unreservation functionality for SLA
        -- return back.
        return true;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfin - initialization ' );
    -- =========================== FND LOG ===========================

    -- Initialize Global Variables
    if not glxfin(p_ledgerid            =>    p_ledgerid,
                  p_packetid            =>    p_packetid,
                  p_mode                =>    p_mode,
                  p_override            =>    p_override,
                  p_conc_flag           =>    p_conc_flag,
                  p_user_id             =>    p_user_id,
                  p_user_resp_id        =>    p_user_resp_id,
                  p_calling_prog_flag   =>    p_calling_prog_flag) then

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfin --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================

       goto fatal_error;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfcp - preprocessor ');
    -- ========================= FND LOG =============================

    -- Funds Check Processor
    if not glxfcp then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfcp --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================
      goto fatal_error;
    end if;


    if g_overlapping_budget=TRUE then
        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' return_code --> F');
        -- ========================= FND LOG =============================

        p_return_code := 'F';

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
        -- ========================= FND LOG =============================
        return(TRUE);

    end if ;


    -- Override Transactions
    if g_override_flag and g_calling_prog_flag = 'G' and not g_conc_flag then

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_override_flag --> TRUE ');
             psa_utils.debug_other_string(g_state_level,l_full_path, ' g_calling_prog_flag --> G ');
             psa_utils.debug_other_string(g_state_level,l_full_path, ' g_conc_flag --> FALSE ');
       -- ========================= FND LOG =============================

            open det_override_reqd;
            fetch det_override_reqd INTO l_override_reqd;

            if (det_override_reqd%NOTFOUND) then

                   -- =========================== FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' det_override_reqd%NOTFOUND ');
                   -- ========================= FND LOG =============================

                open ussgl_override_reqd;
                fetch ussgl_override_reqd INTO l_override_reqd;

                if (ussgl_override_reqd%FOUND) then

                       -- =========================== FND LOG ===========================
                          psa_utils.debug_other_string(g_state_level,l_full_path, ' ussgl_override_reqd%FOUND ');
                       -- ========================= FND LOG =============================

                    g_return_code := 'O';
                    goto normal_exit;
                end if;

            else

                   -- =========================== FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' det_override_reqd%FOUND ');
                   -- ========================= FND LOG =============================

                g_return_code := 'O';
                goto normal_exit;
            end if;

    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxcon ');
    -- ========================= FND LOG =============================

    -- Set Result Codes, Return Code, Append Journal Logic
    if not glxcon then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxcon --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================
       goto fatal_error;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glrchk ');
    -- ========================= FND LOG =============================

    if not glrchk('X') then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glrchk --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================
      goto fatal_error;
    end if;

    <<NORMAL_EXIT>>

        IF (det_override_reqd%ISOPEN) THEN
            close det_override_reqd;
        END IF;

        IF (ussgl_override_reqd%ISOPEN) THEN
            close ussgl_override_reqd;
        END IF;

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code --> ' || g_return_code);
        -- ========================= FND LOG =============================

        p_return_code := g_return_code;

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
        -- ========================= FND LOG =============================

        return(TRUE);


    <<fatal_error>>

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' Reached FATAL ERROR LABEL ');
        -- ========================= FND LOG =============================

        if not glxfuf then
               -- =========================== FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfuf --> RETURN FALSE -> RAISE OTHERS');
               -- ========================= FND LOG =============================
              raise others;
        end if;

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
        -- ========================= FND LOG =============================

        return(FALSE);

  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
      -- ========================= FND LOG =============================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      return(FALSE);

  END glxfck;

  /* ================================ GLXFIN ================================ */

  -- Initialize Global Variables

  FUNCTION glxfin(p_ledgerid          IN NUMBER,
                  p_packetid          IN NUMBER,
                  p_mode              IN VARCHAR2,
                  p_override          IN VARCHAR2,
                  p_conc_flag         IN VARCHAR2,
                  p_user_id           IN NUMBER,
                  p_user_resp_id      IN NUMBER,
                  p_calling_prog_flag IN VARCHAR2) RETURN BOOLEAN IS

    i                     BINARY_INTEGER;
    l_status              fnd_product_installations.status%TYPE;
    l_industry            fnd_profile_option_values.profile_option_value%TYPE;
    l_value               fnd_profile_option_values.profile_option_value%TYPE;
    l_reverse_tc_flag     fnd_profile_option_values.profile_option_value%TYPE;
    l_fv_prepay_prof      fnd_profile_option_values.profile_option_value%TYPE;
    l_fv_prepay_defined   BOOLEAN;
    l_defined             BOOLEAN;
    l_reverse_tc_defined  BOOLEAN;

    l_pa_status  VARCHAR2(1);
    l_pa_enabled INTEGER;

    l_gms_status  VARCHAR2(1);
    l_gms_enabled INTEGER;

    l_efc_status  VARCHAR2(1);
    l_efc_enabled VARCHAR2(1);
    l_cbc_enabled VARCHAR2(1);

    l_igi_status VARCHAR2(1);

    l_prepare_stmt VARCHAR2(2000);

    CURSOR set_of_books is
    SELECT chart_of_accounts_id,
           currency_code
    FROM   gl_ledgers_public_v
    WHERE  ledger_id = g_ledger_id;

    others                EXCEPTION;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

  l_full_path := g_path || 'glxfin';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFIN - START' );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ledgerid          -> ' || p_ledgerid);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_packetid          -> ' || p_packetid);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_mode              -> ' || p_mode);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override          -> ' || p_override);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_conc_flag         -> ' || p_conc_flag);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_id           -> ' || p_user_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_resp_id      -> ' || p_user_resp_id);
    -- ========================= FND LOG =============================

    g_psa_pacheck          := FALSE;
    g_psa_grantcheck       := FALSE;
    g_cbc_enabled          := FALSE;
    g_summarized_flag      := FALSE;
    g_append_je_flag       := FALSE;
    g_requery_flag         := FALSE;
    g_ussgl_option_flag    := FALSE;
    g_overlapping_budget   := FALSE;   -- Used When there are multiple overlapping budgets for the account


    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' SETTING VARIABLES ' );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_pacheck       -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_grantcheck    -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_enabled     -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_summarized_flag -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag  -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_requery_flag    -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ussgl_option_flag -> FALSE');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_overlapping_budget -> FALSE');
    -- ========================= FND LOG =============================

     /*===========================================+
      |    Assign Parameters to Global Variables      |
      +===========================================*/

    g_ledger_id         := p_ledgerid;
    g_packet_id         := p_packetid;
    g_fcmode            := p_mode;

    -- ========================= FND LOG =============================
       psa_utils.debug_other_string(g_state_level,l_full_path, 'Calling Get_Session_Details to fetch session variables');
    -- ========================= FND LOG =============================

    Get_Session_Details(g_session_id, g_serial_id);

    -- ========================= FND LOG =============================
       psa_utils.debug_other_string(g_state_level,l_full_path, 'Session_Id = '||g_session_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, 'Serial_Id = '||g_serial_id);
    -- ========================= FND LOG =============================

    IF p_calling_prog_flag IN ('P', 'H') THEN
      -- ========================= FND LOG =============================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag = P or H -> g_calling_prog_flag = S');
      -- ========================= FND LOG =============================

       g_calling_prog_flag := 'S';
    ELSE
      -- ========================= FND LOG =============================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag != P or H -> g_calling_prog_flag = ' || p_calling_prog_flag);
      -- ========================= FND LOG =============================

       g_calling_prog_flag := p_calling_prog_flag;
    END IF;

    IF g_fcmode ='C' THEN     -- Funds Check Partial Mode Check
      -- ========================= FND LOG =====================================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = C -> g_partial_resv_flag = Y');
      -- ========================= FND LOG =====================================

           g_partial_resv_flag := 'Y';
    ELSIF g_fcmode = 'M' THEN  -- Funds Check Full Mode Check
      -- ========================= FND LOG =====================================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = M -> g_partial_resv_flag = N');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = M -> g_fcmode = C');
      -- ========================= FND LOG =====================================

           g_partial_resv_flag := 'N';
           g_fcmode := 'C';
    ELSIF g_fcmode = 'P' THEN  -- Funds Reserve Partial Mode Check
      -- ========================= FND LOG =====================================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = P -> g_partial_resv_flag = Y');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = P -> g_fcmode = R');
      -- ========================= FND LOG =====================================
--Modified by sthota for Bug 9086735
           g_partial_resv_flag := 'N';
           g_fcmode := 'R';
    ELSE
      -- ========================= FND LOG =====================================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode != C, M and P -> g_partial_resv_flag = N');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> '||g_fcmode);
      -- ========================= FND LOG =====================================

           g_partial_resv_flag := 'N';
    END IF;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ledger_id    -> ' || g_ledger_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id -> ' || g_packet_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode    -> ' || g_fcmode);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_partial_resv_flag  -> '|| g_partial_resv_flag);
    -- ========================= FND LOG =============================

    /*========================+
     |    Set Overrides Flag  |
     +========================*/

    if (p_override = 'N') then
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override = N  -> g_override_flag = FALSE');
        -- =========================== FND LOG ===========================

      g_override_flag := FALSE;
    else
        -- =========================== FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override != N  -> g_override_flag = TRUE');
        -- =========================== FND LOG ===========================

      g_override_flag := TRUE;
    end if;

    /*========================+
     |    Get AOL User ID            |
     +========================*/

    if ((g_override_flag) and
        (p_user_id is not null)) then
      g_user_id := p_user_id;
    else
      g_user_id := FND_GLOBAL.USER_ID;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_user_id -> ' || g_user_id);
    -- ========================= FND LOG =============================

    if g_user_id = -1 then
      message_token('PROCEDURE', 'Funds Checker');
      add_message('SQLGL', 'GL_INVALID_USERID');
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE');
      -- ========================= FND LOG =============================
      g_debug := g_debug||' GLXFIN Failed : G_USER_ID = -1';
      return(FALSE);
    end if;

    /*==============================+
     |    Get Calling Application ID  |
     +==============================*/

    g_resp_appl_id := FND_GLOBAL.resp_appl_id;

    if g_resp_appl_id = -1 then
      g_resp_appl_id := 101;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_resp_appl_id -> ' || g_resp_appl_id);
    -- ========================= FND LOG =============================

    /*=========================+
     |    Get Responsibility ID  |
     +=========================*/

    if ((g_override_flag) and
        (p_user_resp_id is not null)) then
      g_user_resp_id := p_user_resp_id;
    else
      g_user_resp_id := FND_GLOBAL.RESP_ID;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_user_resp_id -> ' || g_user_resp_id);
    -- ========================= FND LOG =============================

    if g_user_resp_id = -1 then
      message_token('PROCEDURE', 'Funds Checker');
      add_message('SQLGL', 'GL_INVALID_RESPID');
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE');
      -- ========================= FND LOG =============================
      g_debug := g_debug||' GLXFIN Failed : G_USER_RESP_ID = -1';
      return(FALSE);
    end if;

    /*========================================+
     |    Whether invoked from a Batch Process  |
     +========================================*/


    if (p_conc_flag = 'N') then
      g_conc_flag := FALSE;
    else
      g_conc_flag := TRUE;
    end if;

    -- =========================== FND LOG ===========================
       IF (g_conc_flag) THEN
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_conc_flag -> TRUE');
       ELSE
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_conc_flag -> FALSE');
       END IF;
    -- ========================= FND LOG =============================

    IF g_calling_prog_flag = 'G' THEN

        -- Get GL Installation Info
        -- The installation info is now implemented as a profile option (INDUSTRY).

        FND_PROFILE.GET_SPECIFIC('INDUSTRY',
                                 g_user_id,
                                 g_user_resp_id,
                                 g_resp_appl_id,
                                 l_industry,
                                 l_defined);

        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' Getting INDUSTRY details ');
        -- ========================= FND LOG =============================

        if not l_defined then
            if not FND_INSTALLATION.GET(g_resp_appl_id,
                                        101,
                                        l_status,
                                        l_industry) then

                  message_token('ROUTINE', 'Funds Checker');
                  add_message('SQLGL', 'GL_CANT_GET_INSTALL_INDUSTRY');
                -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE');
                -- ========================= FND LOG =============================
                  g_debug := g_debug||' GLXFIN Failed : Oracle General Ledger
                          was unable to get installation industry from Funds Checker.
                        Contact your system administrator.';
                  return(FALSE);
            end if;
        end if;


        -- Check for Profiles if Government Install

        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_industry -> ' || l_industry);
        -- ========================= FND LOG =============================

        if l_industry = 'G' then

          FND_PROFILE.GET('USSGL_OPTION', l_value);

          if l_value is null then
             -- =========================== FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' RAISE OTHERS');
             -- ========================= FND LOG =============================
             raise others;
          end if;

        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' USSGL_OPTION, l_value -> ' || l_Value);
        -- ========================= FND LOG =============================

          if l_value = 'Y' then
           -- =========================== FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' G_USSGL_OPTION_FLAG -> TRUE ');
           -- ========================= FND LOG =============================
            g_ussgl_option_flag := TRUE;
          end if;

          if g_ussgl_option_flag then

             FND_PROFILE.GET_SPECIFIC('FV_SPLIT_INV_DISTRIBUTION_PREPAY',
                                       g_user_id,
                                       g_user_resp_id,
                                       g_resp_appl_id,
                                       l_fv_prepay_prof,
                                       l_fv_prepay_defined);

              -- =========================== FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path, ' l_fv_prepay_prof -> ' || l_fv_prepay_prof);
              -- ========================= FND LOG =============================

              if l_fv_prepay_prof = 'Y' then
                 g_fv_prepay_prof := TRUE;
              else
                 g_fv_prepay_prof := FALSE;
              end if;

            -- =========================== FND LOG ===========================
               IF (g_fv_prepay_prof) THEN
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fv_prepay_prof -> TRUE');
               ELSE
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fv_prepay_prof -> FALSE');
               END IF;
            -- ========================= FND LOG =============================

          end if;

          -- Bug 678604
          FND_PROFILE.GET_SPECIFIC('GL_REVERSE_TC_OPTION',
                                   g_user_id,
                                   g_user_resp_id,
                                   g_resp_appl_id,
                                   l_reverse_tc_flag,
                                   l_reverse_tc_defined);

          if not l_reverse_tc_defined then
            g_reverse_tc_flag := 'Y';
          else
            g_reverse_tc_flag := l_reverse_tc_flag;
          end if;

          -- =========================== FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path, ' g_reverse_tc_flag -> ' || g_reverse_tc_flag);
          -- ========================= FND LOG =============================

        end if;  -- l_industry = 'G'

    end if;        -- g_calling_prog_flag = 'G'


/*
    FND_PROFILE.GET('CREATE_BUDGETARY_ENCUMBRANCES', l_value);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' CBE - l_value -> ' || l_Value);
    -- ========================= FND LOG =============================

    if l_value is null then
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_value is null -> raise others');
        -- ========================= FND LOG =============================

       raise others;
    else
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_value not null -> g_budgetary_enc_flag = l_value = ' || l_value);
        -- ========================= FND LOG =============================

       g_budgetary_enc_flag := l_value;
    end if;

*/


    -- Get PSA Debug Mode profile value

    FND_PROFILE.GET('PSA_DEBUG_MODE', l_value);

    IF l_value = 'Y' THEN
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_value = Y -> g_xla_debug = TRUE');
        -- ========================= FND LOG =============================

        g_xla_debug := TRUE;
    ELSE
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_value != Y -> g_xla_debug = FALSE');
        -- ========================= FND LOG =============================

        g_xla_debug := FALSE;
    END IF;


    -- Get Budgetary Control Option

    if ((g_override_flag) and
        (p_user_id is not null) and
        (p_user_resp_id is not null)) then

      FND_PROFILE.GET_SPECIFIC('BUDGETARY_CONTROL_OPTION',
                               p_user_id,
                               p_user_resp_id,
                               g_resp_appl_id,
                               l_value,
                               l_defined);
    else
      FND_PROFILE.GET('BUDGETARY_CONTROL_OPTION', l_value);
    end if;

    g_bc_option_id := to_number(l_value);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_bc_option_id -> ' || g_bc_option_id);
    -- ========================= FND LOG =============================

    g_return_code := NULL;

    g_num_segs := 0;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code -> ' || g_return_code);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_num_segs -> ' || g_num_segs);
    -- ========================= FND LOG =============================

    for i in 1..30 loop
      seg_name(i) := null;
      seg_val(i) := null;
    end loop;


    /*============================+
    |    Check for PA enabled     |
    +=============================*/

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Check PA is enable or not ' );
    -- ========================= FND LOG =============================

    BEGIN
       l_industry     := NULL;
       l_prepare_stmt := NULL;
       l_pa_status    := 'N';

           IF FND_INSTALLATION.GET(275, 275, l_pa_status, l_industry) THEN

            IF l_pa_status ='I' THEN

                    l_pa_enabled := 0;
                    l_prepare_stmt := 'BEGIN IF PA_BUDGET_FUND_PKG.IS_PA_BC_ENABLED() THEN'||' :1 := 1; END IF; END;';

              -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_prepare_stmt -> ' || l_prepare_stmt );
              -- ========================= FND LOG =============================

                   EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_pa_enabled;

              -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_pa_enabled -> ' || l_pa_enabled );
              -- ========================= FND LOG =============================


                 IF l_pa_enabled = 1 THEN

                       g_psa_pacheck := TRUE;

                  -- =========================== FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_pacheck --> TRUE ' );
                  -- ========================= FND LOG =============================

                 END IF;
            END IF;
           END IF;

    EXCEPTION
        WHEN OTHERS THEN
            g_psa_pacheck := FALSE;

            -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_psa_pacheck --> FALSE ' );
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' ERROR: '||sqlerrm );
            -- ========================= FND LOG =============================
    END;


    /*============================+
    |    Check for GMS enabled    |
    +=============================*/

  -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Check GMS is enable or not ' );
  -- ========================= FND LOG =============================
    BEGIN
           l_industry     := NULL;
           l_prepare_stmt := NULL;
           l_gms_status   := 'N';

        IF FND_INSTALLATION.GET(8402, 8402, l_gms_status, l_industry) THEN

            IF l_gms_status ='I' THEN

                    l_gms_enabled  := 0;
                   l_prepare_stmt := 'BEGIN IF GMS_INSTALL.ENABLED() THEN'||' :1 := 1; END IF; END;';

              -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_prepare_stmt -> ' || l_prepare_stmt );
              -- ========================= FND LOG =============================

                   EXECUTE IMMEDIATE l_prepare_stmt USING OUT l_gms_enabled;

              -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_gms_enabled -> ' || l_gms_enabled );
              -- ========================= FND LOG =============================


                 IF l_gms_enabled = 1 THEN

                       g_psa_grantcheck := TRUE;

                      -- =========================== FND LOG ===========================
                           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_grantcheck --> TRUE ' );
                      -- ========================= FND LOG =============================

                 END IF;
            END IF;
           END IF;

    EXCEPTION
        WHEN OTHERS THEN
            g_psa_grantcheck := FALSE;

            -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_psa_grantcheck --> FALSE ' );
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' ERROR: '||sqlerrm );
            -- ========================= FND LOG =============================
    END;


    /*========================+
     |    Check CBC Enabled   |
     +========================*/

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' Check CBC is enabled or not' );
        -- ========================= FND LOG =============================

    BEGIN

          IF (l_igi_status = 'I') THEN

              l_prepare_stmt := 'SELECT cc_bc_enable_flag FROM igc_cc_bc_enable WHERE set_of_books_id = :1';
              -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' l_prepare_stmt -> ' || l_prepare_stmt );
              -- ========================= FND LOG =============================

              EXECUTE IMMEDIATE l_prepare_stmt INTO l_cbc_enabled USING g_ledger_id;

              IF (l_cbc_enabled = 'Y') THEN
                  g_cbc_enabled := TRUE;
              END IF;
          END IF;

      EXCEPTION
          WHEN OTHERS THEN
              g_cbc_enabled := FALSE;
            -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_cbc_enabled --> FALSE ' );
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' ERROR: '||sqlerrm );
            -- ========================= FND LOG =============================
      END;


    IF g_cbc_enabled THEN
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_enabled --> TRUE');
        -- ========================= FND LOG =============================
      ELSE
      -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_enabled --> FALSE');
        -- ========================= FND LOG =============================
      END IF;


    /*================================================================================+
     |    Get Chart of Accounts and Functional Currency Code for this Set of Books    |
     +================================================================================*/

    OPEN set_of_books;
    FETCH set_of_books INTO g_coa_id, g_func_curr_code;
    CLOSE set_of_books;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_coa_id -> ' || g_coa_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_func_curr_code -> ' || g_func_curr_code);
    -- ========================= FND LOG =============================

    -- ===============================================================
       psa_utils.debug_other_string(g_state_level,l_full_path,'Getting value of Profile PSA_ENABLE_EFC');
    -- ===============================================================

   FND_PROFILE.GET('PSA_ENABLE_EFC',g_enable_efc_flag);

   -- ================================================================
      psa_utils.debug_other_string(g_state_level,l_full_path,'Value of Profile PSA_ENABLE_EFC' || g_enable_efc_flag);
   -- ================================================================

   -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
   -- ========================= FND LOG =============================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
      -- ========================= FND LOG ===========================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN --> FALSE ');
      -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXFIN Failed : '||SQLERRM;

      return(FALSE);


  END glxfin;

 /* ============================ GLXFCP =============================== */

  -- Funds Check Processor
  FUNCTION glxfcp RETURN BOOLEAN IS

  PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR source_cat IS
    SELECT distinct je_source_name, je_category_name
    FROM gl_bc_packets
    WHERE packet_id = decode(g_fcmode, 'U', g_packet_id_ursvd, g_packet_id);

    l_option_selected NUMBER;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

       l_full_path := g_path || 'glxfcp';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFCP - START' );
    -- ========================= FND LOG =============================

    --
    -- If Mode is Unreservation, assign Packet ID to Unreservation Packet ID
    -- and initialize Packet ID to 0. This is done here to prevent the approved
    -- packet from accidentally being updated to status 'Fatal' in case a fatal
    -- error occurs before glxfiu()
    --

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
    -- ========================= FND LOG =============================

    if g_fcmode = 'U' then
       g_packet_id_ursvd := g_packet_id;
       g_packet_id := 0;
    else
       g_packet_id_ursvd := 0;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id_ursvd -> ' || g_packet_id_ursvd);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id -> ' || g_packet_id);
    -- ========================= FND LOG =============================

    IF g_cbc_enabled THEN

     -- =========================== FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling GLZCBC ');
     -- ========================= FND LOG =============================

       g_cbc_retcode := glzcbc;

        -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_retcode -> ' || g_cbc_retcode);
        -- ========================= FND LOG =============================

        IF g_cbc_retcode = -1 THEN

               -- =========================== FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' glzcbc RETURN -> FALSE');
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' ERROR: ROLLBACK, RETURN -> FALSE');
               -- ========================= FND LOG =============================

               g_debug := g_debug||' GLXFCP Failed : G_CBC_RETOCDE = -1';
               -- Bug 3214062
               rollback;
               RETURN FALSE;

        ELSIF g_cbc_retcode = 0 THEN

         -- =========================== FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfrc ');
         -- ========================= FND LOG =============================

             if not glxfrc then
                -- =========================== FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfrc RETURN -> FALSE');
                       psa_utils.debug_other_string(g_state_level,l_full_path, ' ERROR: ROLLBACK, RETURN -> FALSE');
                -- ========================= FND LOG =============================

                -- Bug 3214062
                rollback;
                RETURN FALSE;
            end if;

               -- Bug 3214062
               commit;

               -- =========================== FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
               -- ========================= FND LOG =============================

               RETURN TRUE;

        END IF;

    END IF;    -- g_cbc_enabled

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' resetting g_append_je_flag to FALSE ');
    -- ========================= FND LOG =============================

    -- Reset Append JE Flag
    g_append_je_flag := FALSE;


    -- If USSGL Option is enabled and Mode is not Unreservation, process
    -- USSGL transactions

    if ((g_ussgl_option_flag) and
        (g_fcmode <> 'U')) then

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ussgl_option_flag -> TRUE ');
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode <> U ');
          psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling fv_prepay_pkg ');
       -- ========================= FND LOG =============================

      if not fv_prepay_pkg then
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' fv_prepay_pkg - RETURN -> FALSE');
        -- ========================= FND LOG =============================
        g_debug := g_debug||' GLXFCP Failed : FV_PREPAY_PKG failed';
        rollback;
        return (FALSE);
      end if;

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfug ');
      -- ========================= FND LOG =============================

      if not glxfug then
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFUG - RETURN -> FALSE');
        -- ========================= FND LOG =============================
           rollback;
        return(FALSE);
      end if;

    end if;

    -- If Project Accounting Funds Check indicated, callout to allow
    -- for proper pre-processing.

    if g_psa_pacheck then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_pacheck -> TRUE');
       -- ========================= FND LOG =============================

      if not glzpafck then
         -- =========================== FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' glzpafck - RETURN -> FALSE');
         -- ========================= FND LOG =============================
         rollback;
         return(FALSE);
      end if;

    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Populating records in PSA_OPTION_DETAILS_GT ');
    -- ========================= FND LOG =============================

    FOR indx IN source_cat
    LOOP
        SELECT MIN(CASE)  INTO l_option_selected
        FROM (
            SELECT CASE
            WHEN (bc.je_source_name = indx.je_source_name) AND (bc.je_category_name = indx.je_category_name) THEN
                1
            WHEN (bc.je_source_name = indx.je_source_name) AND (bc.je_category_name = 'Other') THEN
                2
            WHEN (bc.je_category_name = indx.je_category_name) AND (bc.je_source_name = 'Other') THEN
                3
            WHEN (bc.je_source_name = 'Other' AND bc.je_category_name = 'Other') THEN
                4
            END CASE
            FROM gl_bc_option_details bc
            WHERE bc_option_id = g_bc_option_id);

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' l_option_selected -> '||l_option_selected);
      -- ========================= FND LOG =============================

            INSERT INTO psa_option_details_gt
            ( packet_id,
              je_source_name,
              je_category_name,
              gl_bc_option_source,
              gl_bc_option_category,
              funds_check_level_code,
              override_amount,
              tolerance_percentage,
              tolerance_amount
            )
            SELECT decode(g_fcmode, 'U', g_packet_id_ursvd, g_packet_id)
                  ,indx.je_source_name
                  ,indx.je_category_name
                  ,decode(l_option_selected,
                          1, indx.je_source_name,
                          2, indx.je_source_name,
                          'Other')
                  ,decode(l_option_selected,
                          1, indx.je_category_name,
                          3, indx.je_category_name,
                          'Other')
                  ,funds_check_level_code
                  ,override_amount
                  ,tolerance_percentage
                  ,tolerance_amount
            FROM gl_bc_option_details
            WHERE bc_option_id     = g_bc_option_id
            AND   je_source_name   = decode(l_option_selected,
                                            1, indx.je_source_name,
                                            2, indx.je_source_name,
                                            'Other')
            AND   je_category_name =  decode(l_option_selected,
                                             1, indx.je_category_name,
                                             3, indx.je_category_name,
                                             'Other');

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, sql%rowcount||' Rows Inserted into psa_option_details_gt ');
    -- ========================= FND LOG =============================


    END LOOP;

    -- If Mode is Unreservation, insert Unreservation Packet into the queue
    if g_fcmode = 'U' then

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = U ');
       -- ========================= FND LOG =============================

      if not glxfiu then
             -- =========================== FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfui - RETURN -> FALSE ');
             -- ========================= FND LOG =============================
        rollback;
        return(FALSE);
      end if;
      end if;

    if not glxfss then
     -- =========================== FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfss - RETURN -> FALSE ');
     -- ========================= FND LOG =============================
       rollback;
       return(FALSE);
    end if;

  if g_overlapping_budget=TRUE then
        commit;
        return(TRUE);
   end if;


    -- Check Grants, if extension enabled

    gms_retcode := '~';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' gms_retcode -> ' || gms_retcode);
    -- ========================= FND LOG =============================

    if g_psa_grantcheck then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glzgchk');
       -- ========================= FND LOG =============================
        g_psa_grantcheck := glzgchk;
    end if;

    -- Process Balances

    if (g_fcmode <> 'F') then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode <> F');
       -- ========================= FND LOG =============================

      if not glxfgb then
             -- =========================== FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfgb -> FALSE');
             -- ========================= FND LOG =============================
            rollback;
        return(FALSE);
      end if;

    end if;

    -- ## Update Result Codes
    -- ## TROBERTS: Removed Return Code expansion as this applied only
    -- ## to the Extended Funds Checker V2 and V3 functionality which
    -- ## is not supported in 11.5 and beyond.

       if not glxfrc then
          -- =========================== FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfrc -> FALSE');
          -- ========================= FND LOG =============================
          rollback;
          return(FALSE);
       end if;

    --
    -- Need to commit as we exit an autonomous function.
    --
    commit;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
    -- ========================= FND LOG =============================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
      -- ========================= FND LOG =============================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      g_debug := g_debug||' GLXFCP Failed : '||SQLERRM;
      -- Bug 3214062
      rollback;

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> TRUE');
      -- ========================= FND LOG =============================
      return(FALSE);

  END glxfcp;

  /* ============================== GLXFUG ================================ */

  -- Process USSGL Transactions

  -- This Module inserts Budgetary or Proprietary actual transactions into
  -- the queue table as needed and creates new Budgetary or Proprietary Code
  -- Combinations if they do not already exist in the Code Combinations table

  FUNCTION glxfug RETURN BOOLEAN IS

    l_tmpmsg           VARCHAR2(70);
    l_rowid            VARCHAR2(100);
    l_ccid_out         NUMBER;
    l_ccid             NUMBER;

    -- Maximum Length for this SQL Statement is 3708

    sql_ussgl          VARCHAR2(7000);
    cur_ussgl          INTEGER;
    num_ussgl          INTEGER;
    ignore             INTEGER;

    segment1           gl_code_combinations.segment1%TYPE;
    segment2           gl_code_combinations.segment2%TYPE;
    segment3           gl_code_combinations.segment3%TYPE;
    segment4           gl_code_combinations.segment4%TYPE;
    segment5           gl_code_combinations.segment5%TYPE;
    segment6           gl_code_combinations.segment6%TYPE;
    segment7           gl_code_combinations.segment7%TYPE;
    segment8           gl_code_combinations.segment8%TYPE;
    segment9           gl_code_combinations.segment9%TYPE;
    segment10          gl_code_combinations.segment10%TYPE;
    segment11          gl_code_combinations.segment11%TYPE;
    segment12          gl_code_combinations.segment12%TYPE;
    segment13          gl_code_combinations.segment13%TYPE;
    segment14          gl_code_combinations.segment14%TYPE;
    segment15          gl_code_combinations.segment15%TYPE;
    segment16          gl_code_combinations.segment16%TYPE;
    segment17          gl_code_combinations.segment17%TYPE;
    segment18          gl_code_combinations.segment18%TYPE;
    segment19          gl_code_combinations.segment19%TYPE;
    segment20          gl_code_combinations.segment20%TYPE;
    segment21          gl_code_combinations.segment21%TYPE;
    segment22          gl_code_combinations.segment22%TYPE;
    segment23          gl_code_combinations.segment23%TYPE;
    segment24          gl_code_combinations.segment24%TYPE;
    segment25          gl_code_combinations.segment25%TYPE;
    segment26          gl_code_combinations.segment26%TYPE;
    segment27          gl_code_combinations.segment27%TYPE;
    segment28          gl_code_combinations.segment28%TYPE;
    segment29          gl_code_combinations.segment29%TYPE;
    segment30          gl_code_combinations.segment30%TYPE;

    cursor ussgl is
      select 'USSGL Rows need to be created'
        from dual
       where exists
            (
             select 'Transaction with USSGL Code'
               from gl_bc_packets bp
              where bp.packet_id = g_packet_id
                and bp.ussgl_transaction_code is not null
            );

    cursor append_je is
      select 'Associated Generated JEs to be appended or inserted'
        from dual
       where exists
            (
             select 'Associated Generated Row from existing GL Batch'
               from gl_bc_packets bp
              where bp.packet_id = g_packet_id
                and bp.je_batch_id is not null
                and bp.je_batch_id >= 0
                and bp.ussgl_transaction_code is not null
            );

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

      l_full_path := g_path || 'glxfug';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFUG - START' );
    -- ========================= FND LOG =============================

    -- Check that USSGL transactions need to be created since the overhead for
    -- constructing and executing the Dynamic SQL for inserting USSGL
    -- Transactions is much higher than this check

    open ussgl;

    fetch ussgl into l_tmpmsg;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_tmpmsg -> ' || l_tmpmsg );
    -- ========================= FND LOG =============================

    -- No USSGL Transactions need to be created
    if ussgl%NOTFOUND then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' goto normal_exit label' );
       -- ========================= FND LOG =============================
       goto normal_exit;
    end if;

    close ussgl;

    -- Check if there are associated generated Journal Entry lines
    -- to be appended to an existing Actual Batch or if a separate
    -- Actual Batch would need to be created if the Originating
    -- source is an existing Encumbrance Batch

    open append_je;
    fetch append_je into l_tmpmsg;

    if append_je%FOUND then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag -> TRUE');
       -- ========================= FND LOG =============================
       g_append_je_flag := TRUE;
    else
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag -> FALSE');
       -- ========================= FND LOG =============================
       g_append_je_flag := FALSE;
    end if;

    close append_je;


    UPDATE  GL_BC_PACKETS BP
       SET  BP.ussgl_parent_id = GL_USSGL_PARENT_S.NEXTVAL
     WHERE
            BP.packet_id = g_packet_id
       AND  BP.ussgl_transaction_code IS NOT NULL;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets -> ' || SQL%ROWCOUNT );
    -- ========================= FND LOG =============================

    if g_append_je_flag then

        -- ## ----------------------------------------------------------+
        -- ## Bug: 1387967/2178715  Federal AR                          |
        -- ## Drill down of USSGL generated transactions to AR.         |
        -- ## ----------------------------------------------------------+

      UPDATE  GL_BC_PACKETS BP
         SET
             ( BP.reference1,
               BP.reference2,
               BP.reference3,
               BP.reference4,
               BP.reference5,
               BP.reference6,
               BP.reference7,
               BP.reference8,
               BP.reference9,
               BP.reference10) =
                         (SELECT GI.reference_1,
                                 GI.reference_2,
                                 GI.reference_3,
                                 GI.reference_4,
                                 GI.reference_5,
                                 GI.reference_6,
                                 GI.reference_7,
                                 GI.reference_8,
                                 GI.reference_9,
                                 GI.reference_10
                          FROM gl_import_references GI
                          WHERE GI.je_line_num = BP.je_line_num
                            AND GI.je_header_id= BP.je_header_id
                            AND GI.je_batch_id = BP.je_batch_id)
     WHERE
            BP.packet_id = g_packet_id
       AND  BP.ussgl_transaction_code IS NOT NULL;

   end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets -> ' || SQL%ROWCOUNT );
       psa_utils.debug_other_string(g_state_level,l_full_path, 'Calling glxfkf' );
    -- ========================= FND LOG =============================

    -- Retrieve Flex Info for the Flex Structure
    if not glxfkf then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfkf ->False --> RETURN FALSE' );
       -- ========================= FND LOG =============================
       return(FALSE);
    end if;


    -- Insertion of USSGL transactions into gl_bc_packets

    -- When the USSGL Option is set, this process is executed prior to setting
    -- up of the denormalized columns and this applies to Funds Check and
    -- Funds Reservation. For all packet transactions with a USSGL transaction
    -- code, this function creates all the required budgetary or proprietary
    -- actual transaction records depending on the USSGL transaction codes and
    -- the associated Debit and Credit Account Segment values pair defined in
    -- gl_ussgl_account_pairs

    -- The number of additional transactions generated for each originating
    -- transaction equals the number of Debit and Credit Account Segment
    -- values associated with the originating USSGL transaction code. For
    -- example, if there are 3 Proprietary transactions with non-null USSGL
    -- transaction codes in the packet, and for each of the codes, 2 Debit and
    -- Credit Account Pairs have been defined, then the number of additional
    -- transactions generated will be 12 (3 transactions * 2 acct pairs/code *
    -- 2 acct/pair). No Consolidation is done for multiple generated
    -- generated transactions with the same account

    -- The Entered and Accounted amount columns for the generated transactions
    -- are filled up as follows :
    --
    --    Originating                 Generated                Generated
    --    Transaction            Debit Transaction        Credit Transaction
    --    Account Type             DR         CR            DR          CR
    --    ------------           -----------------        ------------------
    --    'A', 'E', 'D'           O_DR       O_CR          O_CR        O_DR
    --
    --    'L', 'O', 'R', 'C'      O_CR       O_DR          O_DR        O_CR
    --
    --    O_DR : Entered/Accounted Debit Amount for Originating Transaction
    --    O_CR : Entered/Accounted Credit Amount for Originating Transaction

    --    Bug 3111554:
    --    If profile GL_REVERSE_TC_OPTION = 'N' then entered and accounted
    --    amounts are derived as follows.

    --  decode(nvl(PET.event_type, 'X'),
    --            lu.lookup_code, BP.entered_dr,
    --                'X', decode(CCO.account_type || LU.lookup_code,
    --                            'AD', BP.entered_dr,
    --                            'ED', BP.entered_dr,
    --                            'DD', BP.entered_dr,
    --                            'LC', BP.entered_dr,
    --                            'OC', BP.entered_dr,
    --                             'RC', BP.entered_dr,
    --                            'CC', BP.entered_dr,
    --                            BP.entered_cr),
    --                  BP.entered_cr),
    --  decode(nvl(PET.event_type, 'X'),
    --                 lu.lookup_code, BP.entered_cr,
    --                'X', decode(CCO.account_type  LU.lookup_code,
    --                            'AD', BP.entered_cr,
    --                            'ED', BP.entered_cr,
    --                            'DD', BP.entered_cr,
    --                            'LC', BP.entered_cr,
    --                            'OC', BP.entered_cr,
    --                            'RC', BP.entered_cr,
    --                            'CC', BP.entered_cr,
    --                            BP.entered_dr),
    --                BP.entered_dr)

    -- When the Code Combination for a generated transaction does not exist,
    -- the transaction is created and the CCID is initialized to the negative
    -- value of the originating transaction's CCID. These transactions are
    -- then inserted into the Code Combinations table with new CCIDs

    sql_ussgl := 'insert into gl_bc_packets (packet_id, ' ||
                                            'ledger_id, ' ||
                                            'je_source_name, ' ||
                                            'je_category_name, ' ||
                                            'code_combination_id, ' ||
                                            'actual_flag, ' ||
                                            'period_name, ' ||
                                            'period_year, ' ||
                                            'period_num, ' ||
                                            'quarter_num, ' ||
                                            'currency_code, ' ||
                                            'status_code, ' ||
                                            'last_update_date, ' ||
                                            'last_updated_by, ' ||
                                            'entered_dr, ' ||
                                            'entered_cr, ' ||
                                            'accounted_dr, ' ||
                                            'accounted_cr, ' ||
                                            'originating_rowid, ' ||
                                            'account_segment_value, ' ||
                                            'je_batch_name, ' ||
                                            'je_batch_id, ' ||
                                            'je_header_id, ' ||
                                            'je_line_num, '||
                                            'reference1, ' ||
                                            'reference2, ' ||
                                            'reference3, ' ||
                                            'reference4, ' ||
                                            'reference5, ' ||
                                            'reference6, ' ||
                                            'reference7, ' ||
                                            'reference8, ' ||
                                            'reference9, ' ||
                                            'reference10, '||
                                            'ussgl_link_to_parent_id, '||
                                            'session_id, '||
                                            'serial_id, ' ||
                                            'application_id) ';

    sql_ussgl := sql_ussgl ||
                 'select bp.packet_id, ' ||
                        'bp.ledger_id, ' ||
                        'bp.je_source_name, ' ||
                        'bp.je_category_name, ' ||
                        'decode(ccg.code_combination_id, ' ||
                               'cco.code_combination_id, ' ||
                               '-1 * cco.code_combination_id, ' ||
                               'ccg.code_combination_id), ' ||
                        '''A'', ' ||
                        'bp.period_name, ' ||
                        'bp.period_year, ' ||
                        'bp.period_num, ' ||
                        'bp.quarter_num, ' ||
                        'bp.currency_code, ' ||
                        'bp.status_code, ' ||
                        'bp.last_update_date, ' ||
                        'bp.last_updated_by, ';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_reverse_tc_flag -> ' || g_reverse_tc_flag );
    -- ========================= FND LOG =============================

    if g_reverse_tc_flag = 'N' then

    sql_ussgl := sql_ussgl ||
                     'decode(nvl(PET.event_type, ''X''), '                ||
                'lu.lookup_code, BP.entered_dr,'            ||
                '''X'', decode(CCO.account_type || LU.lookup_code,'    ||
                    '''AD'', BP.entered_dr, '            ||
                    '''ED'', BP.entered_dr, '            ||
                    '''DD'', BP.entered_dr, '            ||
                    '''LC'', BP.entered_dr, '            ||
                    '''OC'', BP.entered_dr, '            ||
                    '''RC'', BP.entered_dr, '            ||
                    '''CC'', BP.entered_dr, BP.entered_cr), '    ||
                'BP.entered_cr),'                    ||
                     'decode(nvl(PET.event_type, ''X''), '                ||
                'lu.lookup_code, BP.entered_cr,'            ||
                '''X'', decode(CCO.account_type || LU.lookup_code,'    ||
                    '''AD'', BP.entered_cr, '            ||
                    '''ED'', BP.entered_cr, '            ||
                    '''DD'', BP.entered_cr, '            ||
                    '''LC'', BP.entered_cr, '            ||
                    '''OC'', BP.entered_cr, '            ||
                    '''RC'', BP.entered_cr, '            ||
                    '''CC'', BP.entered_cr, BP.entered_dr),'    ||
                'BP.entered_dr),'                    ||
                     'decode(nvl(PET.event_type, ''X''),'                 ||
                'lu.lookup_code, BP.accounted_dr,'            ||
                '''X'', decode(CCO.account_type || LU.lookup_code,'    ||
                    '''AD'', BP.accounted_dr, '             ||
                    '''ED'', BP.accounted_dr, '             ||
                    '''DD'', BP.accounted_dr, '             ||
                    '''LC'', BP.accounted_dr, '             ||
                    '''OC'', BP.accounted_dr, '             ||
                    '''RC'', BP.accounted_dr, '             ||
                    '''CC'', BP.accounted_dr, BP.accounted_cr),'     ||
                'BP.accounted_cr),'                    ||
                     'decode(nvl(PET.event_type, ''X''),'                ||
                'lu.lookup_code, BP.accounted_cr,'            ||
                '''X'', decode(CCO.account_type || LU.lookup_code,'    ||
                    '''AD'', BP.accounted_cr, '             ||
                    '''ED'', BP.accounted_cr, '            ||
                    '''DD'', BP.accounted_cr, '            ||
                    '''LC'', BP.accounted_cr, '            ||
                    '''OC'', BP.accounted_cr, '            ||
                    '''RC'', BP.accounted_cr, '            ||
                    '''CC'', BP.accounted_cr, BP.accounted_dr),'    ||
                'BP.accounted_dr), ';
    else


    sql_ussgl := sql_ussgl ||
                        'decode(cco.account_type || lu.lookup_code, ' ||
                               '''AD'', bp.entered_dr, ' ||
                               '''ED'', bp.entered_dr, ' ||
                               '''DD'', bp.entered_dr, ' ||
                               '''LC'', bp.entered_dr, ' ||
                               '''OC'', bp.entered_dr, ' ||
                               '''RC'', bp.entered_dr, ' ||
                               '''CC'', bp.entered_dr, bp.entered_cr), ' ||
                        'decode(cco.account_type || lu.lookup_code, ' ||
                               '''AD'', bp.entered_cr, ' ||
                               '''ED'', bp.entered_cr, ' ||
                               '''DD'', bp.entered_cr, ' ||
                               '''LC'', bp.entered_cr, ' ||
                               '''OC'', bp.entered_cr, ' ||
                               '''RC'', bp.entered_cr, ' ||
                               '''CC'', bp.entered_cr, bp.entered_dr), ' ||
                        'decode(cco.account_type || lu.lookup_code, ' ||
                               '''AD'', bp.accounted_dr, ' ||
                               '''ED'', bp.accounted_dr, ' ||
                               '''DD'', bp.accounted_dr, ' ||
                               '''LC'', bp.accounted_dr, ' ||
                               '''OC'', bp.accounted_dr, ' ||
                               '''RC'', bp.accounted_dr, ' ||
                               '''CC'', bp.accounted_dr, bp.accounted_cr), ' ||
                        'decode(cco.account_type || lu.lookup_code, ' ||
                               '''AD'', bp.accounted_cr, ' ||
                               '''ED'', bp.accounted_cr, ' ||
                               '''DD'', bp.accounted_cr, ' ||
                               '''LC'', bp.accounted_cr, ' ||
                               '''OC'', bp.accounted_cr, ' ||
                               '''RC'', bp.accounted_cr, ' ||
                               '''CC'', bp.accounted_cr, bp.accounted_dr), ';
    end if;

    sql_ussgl := sql_ussgl ||
                        'bp.rowid, ' ||
                        'decode(ccg.code_combination_id, ' ||
                               'cco.code_combination_id, ' ||
                               'decode(lu.lookup_code, ' ||
                                     '''D'', guap.dr_account_segment_value, ' ||
                                     '''C'', guap.cr_account_segment_value), ' ||
                               'ccg.' || seg_name(g_acct_seg_index) || '), ' ||
                        'bp.je_batch_name, ' ||
                        'bp.je_batch_id, ' ||
                        'bp.je_header_id, ' ||
                        'bp.je_line_num, '||
                        'bp.reference1, ' ||
                        'bp.reference2, ' ||
                        'bp.reference3, ' ||
                        'bp.reference4, ' ||
                        'bp.reference5, ' ||
                        'bp.reference6, ' ||
                        'bp.reference7, ' ||
                        'bp.reference8, ' ||
                        'bp.reference9, ' ||
                        'bp.reference10, '||
                        'bp.ussgl_parent_id, '||
                        g_session_id||','||
                        g_serial_id||','||
                        g_resp_appl_id ;

    if g_reverse_tc_flag = 'N' then

    sql_ussgl := sql_ussgl ||
                        ' from gl_lookups lu, ' ||
                             'gl_ussgl_transaction_codes uc, ' ||
                             'gl_ussgl_account_pairs guap, ' ||
                             'gl_code_combinations ccg, ' ||
                             'gl_code_combinations cco, ' ||
                             'gl_bc_packets bp, ' ||
                 'psa_event_types pet ' ||
                        'where lu.lookup_type = ''DR_CR'' ' ||
              'and pet.je_source (+) = bp.je_source_name ' ||
                          -- modified for bug 4167009
                           'and pet.je_category (+) = ' ||
                           ' decode(bp.je_category_name, '|| '''Payments'','||
                           'decode(substr(bp.reference5, instr(bp.reference5,' ||'''-'', -1,1)+1, 3),'||
                           '''INT'' ,'|| '''Purchase Invoices'','||
                           'bp.je_category_name),  bp.je_category_name )' ||
                          'and uc.chart_of_accounts_id = ' ||
                              'guap.chart_of_accounts_id ' ||
                          'and uc.ussgl_transaction_code = ' ||
                              'bp.ussgl_transaction_code ' ||
                          'and sysdate between ' ||
                                      'nvl(uc.start_date_active, sysdate) ' ||
                                  'and nvl(uc.end_date_active, sysdate) ' ||
                          'and guap.chart_of_accounts_id = ' || g_coa_id || ' ' ||
                          'and guap.ussgl_transaction_code = ' ||
                              'bp.ussgl_transaction_code ' ||
                          'and ccg.code_combination_id = ' ||
                              '(' ||
                               'select nvl(min(ccg1.code_combination_id), ' ||
                                              'cco.code_combination_id) ' ||
                                 'from gl_code_combinations ccg1 ' ||
                                'where ccg1.chart_of_accounts_id = ' ||
                                g_coa_id;
    else

    sql_ussgl := sql_ussgl ||

                        ' from gl_lookups lu, ' ||
                             'gl_ussgl_transaction_codes uc, ' ||
                             'gl_ussgl_account_pairs guap, ' ||
                             'gl_code_combinations ccg, ' ||
                             'gl_code_combinations cco, ' ||
                             'gl_bc_packets bp ' ||
                        'where lu.lookup_type = ''DR_CR'' ' ||
                          'and uc.chart_of_accounts_id = ' ||
                              'guap.chart_of_accounts_id ' ||
                          'and uc.ussgl_transaction_code = ' ||
                              'bp.ussgl_transaction_code ' ||
                          'and sysdate between ' ||
                                      'nvl(uc.start_date_active, sysdate) ' ||
                                  'and nvl(uc.end_date_active, sysdate) ' ||
                          'and guap.chart_of_accounts_id = ' || g_coa_id || ' ' ||
                          'and guap.ussgl_transaction_code = ' ||
                              'bp.ussgl_transaction_code ' ||
                          'and ccg.code_combination_id = ' ||
                              '(' ||
                               'select nvl(min(ccg1.code_combination_id), ' ||
                                              'cco.code_combination_id) ' ||
                                 'from gl_code_combinations ccg1 ' ||
                                'where ccg1.chart_of_accounts_id = ' ||
                                g_coa_id;
    end if;


    for i in 1..g_num_segs loop

      if seg_name(i) is not null then

        if (i <> g_acct_seg_index) then
          sql_ussgl := sql_ussgl ||
                       ' and ccg1.' || seg_name(i) || ' = ' ||
                           'cco.' || seg_name(i);
        else
          sql_ussgl := sql_ussgl ||
                       ' and ccg1.' || seg_name(i) || ' = ' ||
                           'decode(lu.lookup_code, ' ||
                                   '''D'', guap.dr_account_segment_value, ' ||
                                   '''C'', guap.cr_account_segment_value)';
        end if;

      end if;

    end loop;

    sql_ussgl := sql_ussgl ||
                 ') ' ||
                 'and cco.code_combination_id = bp.code_combination_id ' ||
                 'and bp.packet_id = ' || g_packet_id || ' ' ||
                 'and bp.ussgl_transaction_code is not null';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' sql_ussgl -> ' || SUBSTR(sql_ussgl,1,3500));
       psa_utils.debug_other_string(g_state_level,l_full_path, ' sql_ussgl -> ' || SUBSTR(sql_ussgl,3500,7000));
    -- ========================= FND LOG =============================

    execute immediate sql_ussgl;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, 'USSGL Rows Inserted: '||sql%rowcount);
    -- ========================= FND LOG =============================

    -- Now that the USSGL Transactions have been generated in the queue, we
    -- pick up the Code Combinations which need to be created in the Code
    -- Combinations table

    sql_ussgl := 'select DISTINCT ';

    -- Call Flex API for inserting a new combination of Segment Values

    for i in 1..g_num_segs loop

      if (i <> g_acct_seg_index) then
        sql_ussgl := sql_ussgl ||
                     seg_name(i) || ', ';
      else
        sql_ussgl := sql_ussgl ||
                     'bp.account_segment_value, ';
      end if;

    end loop;

    sql_ussgl := sql_ussgl ||
                'bp.code_combination_id ' ||
                 'from gl_code_combinations cc, ' ||
                      'gl_bc_packets bp ' ||
                'where cc.code_combination_id = -1 * bp.code_combination_id ' ||
                  'and bp.packet_id = ' || g_packet_id || ' ' ||
                  'and bp.code_combination_id < 0 ' ||
                  'and bp.account_segment_value is not null';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' sql_ussgl1 -> ' || SUBSTR(sql_ussgl,1,3500));
       psa_utils.debug_other_string(g_state_level,l_full_path, ' sql_ussgl1 -> ' || SUBSTR(sql_ussgl,3500,7000));
    -- ========================= FND LOG =============================

    cur_ussgl := dbms_sql.open_cursor;
    dbms_sql.parse(cur_ussgl, sql_ussgl, dbms_sql.v7);

    for i in 1..g_num_segs loop
      dbms_sql.define_column(cur_ussgl, i, 'segment' || i, 30);
    end loop;

    dbms_sql.define_column(cur_ussgl, g_num_segs + 1, l_ccid);

    ignore := dbms_sql.execute(cur_ussgl);

    loop

      if dbms_sql.fetch_rows(cur_ussgl) > 0 then

        for i in 1..g_num_segs loop
          dbms_sql.column_value(cur_ussgl, i, seg_val(i));
        end loop;

        dbms_sql.column_value(cur_ussgl, g_num_segs + 1, l_ccid);

        if not FND_FLEX_EXT.GET_COMBINATION_ID('SQLGL', 'GL#', g_coa_id,
                                sysdate, g_num_segs, seg_val, l_ccid_out) then
          goto return_invalid;
        end if;


        -- Commit to allow other Users to create similar combinations on any
        -- flexfield

        commit;


        -- Update the CCID of the USSGL transaction in the Packet

        update gl_bc_packets bp
         set bp.code_combination_id = l_ccid_out
         where bp.code_combination_id = l_ccid
       and   bp.account_segment_value=seg_val(g_acct_seg_index);

        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets -> ' || SQL%ROWCOUNT);
        -- ========================= FND LOG =============================

      else
        exit;
      end if;

    end loop;

    dbms_sql.close_cursor(cur_ussgl);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
    -- ========================= FND LOG =============================

    -- Exit Function if Mode is Check
    if g_fcmode = 'C' then
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = C -> goto normal_exit label');
        -- ========================= FND LOG =============================
      goto normal_exit;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode != C -> RETURN TRUE');
    -- ========================= FND LOG =============================

    return(TRUE);

    <<normal_exit>>

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' reached normal_exit label ');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
    -- ========================= FND LOG =============================

    if ussgl%ISOPEN then
      close ussgl;
    end if;

    return(TRUE);

    <<return_invalid>>

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' reached return_invalid label ');
    -- ========================= FND LOG =============================

    if dbms_sql.is_open(cur_ussgl) then
      dbms_sql.close_cursor(cur_ussgl);
    end if;

    message_token('PROCEDURE', 'Funds Checker');
    message_token('EVENT', FND_MESSAGE.GET_ENCODED);
    add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
    -- ========================= FND LOG =============================

    g_debug := g_debug||' GLXFUG Failed : FND_FLEX_EXT.GET_COMBINATION_ID returned FALSE';

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path, ' WHEN OTHERS EXCEPTION ' || SQLERRM);
       -- ========================= FND LOG =============================

      if ussgl%ISOPEN then
        close ussgl;
      end if;

      if dbms_sql.is_open(cur_ussgl) then
        dbms_sql.close_cursor(cur_ussgl);
      end if;

      if append_je%ISOPEN then
        close append_je;
      end if;

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
    -- ========================= FND LOG =============================

      g_debug := g_debug||' GLXFUG Failed : '||SQLERRM;
      return(FALSE);

  END glxfug;

  /* =========================== GLXFKF ========================= */

  -- Retrieve Flex Info for the Flex Structure
  -- This Function retrieves Flex Info such as Active Segment Info and the
  -- Accounting Segment Index

  FUNCTION glxfkf RETURN BOOLEAN IS

    others      EXCEPTION;

    cursor seginfo(appl_id   NUMBER,
                   flex_code VARCHAR2,
                   flex_num  NUMBER) is
      select application_column_name
        from fnd_id_flex_segments
       where application_id = appl_id
         and id_flex_code = flex_code
         and id_flex_num = flex_num
         and enabled_flag = 'Y'
       order by segment_num;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

       l_full_path := g_path || 'glxfkf';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFUF - START' );
    -- ========================= FND LOG =============================

    -- Retrieve Active Segment Info
    for c_seginfo in seginfo(101, 'GL#', g_coa_id) loop
      g_num_segs := g_num_segs + 1;
      seg_name(g_num_segs) := c_seginfo.application_column_name;
    end loop;

    -- Get Cardinal Order or Index Number of the Account Segment
    if not FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(101,
                                              'GL#',
                                              g_coa_id,
                                              'GL_ACCOUNT',
                                              g_acct_seg_index) then
      message_token('ROUTINE', 'GL_FC_PKG');
      add_message('FND', 'FLEXGL-NO ACCT SEG');
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RAISE OTHERS ' );
      -- ========================= FND LOG =============================
      g_debug := g_debug||' GLXFKF Failed : FND_FLEX_APIS.GET_QUALIFIER_SEGNUM returned FALSE';
      raise others;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_acct_seg_index -> ' || g_acct_seg_index );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
    -- ========================= FND LOG =============================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS' || SQLERRM );
      -- ========================= FND LOG =============================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE' );
      -- ========================= FND LOG =============================

      g_debug := g_debug||' GLXFKF Failed : '||SQLERRM;
      return(FALSE);

  END glxfkf;

  /*  =========================== GLXFIU =============================== */

  -- Insert Unreservation Packet into the Queue

  -- All transactions including associated generated transactions are created
  -- out of the packet being unreserved by copying over most of the column
  -- values with the exception of the amount and denormalized column values.
  -- For the Amount columns, the Debit and Credit values are swapped to create
  -- a reversal effect while the denormalized columns like Tolerance and
  -- Override info are retrieved from the existing system settings. This is to
  -- facilitate cases where there is a need to overcome a Funds Reservation
  -- failure by modifying the Tolerance/Override Settings in the Budgetary
  -- Control Options. The tie-back mechanism for the originating and associated
  -- generated transactions, originating_rowid in the generated lines, are also
  -- preserved in the unreservation packet through a separate update SQL

  -- Summary transactions, as for normal Check/Reservation packets, are derived
  -- through the summarization logic in glxfss(). This is feasible because of
  -- the tightly coupled locking mechanism between the Funds Checker and the
  -- Add/Delete Summary Accounts program, and the packet resummarization
  -- logic in glxfrs(), which guarantees that all summary lines in all the
  -- approved packets will always reflect the most current summarization
  -- structures defined

  -- Validations normally performed for a Check/Reservation packet in glxfss()
  -- denormalization logic are ignored here. Any validation violations that
  -- that arise after the Original Packet has been successfully reserved are
  -- assumed to be insignificant as these reversal entries are only intended to
  -- back out Funds that have been Reserved but is not used for posting

  FUNCTION glxfiu RETURN BOOLEAN IS

    cursor pkt_id is
      select gl_bc_packets_s.nextval
        from dual;

    l_dummy    VARCHAR2(80);

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

    l_full_path         := g_path || 'glxfiu.';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFUI - START' );
    -- ========================= FND LOG =============================

    open pkt_id;
    fetch pkt_id into g_packet_id;
    close pkt_id;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id -> ' || g_packet_id );
    -- ========================= FND LOG =============================

    -- Insert Unreservation Packet into gl_bc_packets
    insert into gl_bc_packets
               (packet_id,
                ledger_id,
                je_source_name,
                je_category_name,
                code_combination_id,
                actual_flag,
                period_name,
                period_year,
                period_num,
                quarter_num,
                currency_code,
                status_code,
                last_update_date,
                last_updated_by,
                budget_version_id,
                encumbrance_type_id,
                entered_dr,
                entered_cr,
                accounted_dr,
                accounted_cr,
                ussgl_transaction_code,
                originating_rowid,
                automatic_encumbrance_flag,
                funding_budget_version_id,
                funds_check_level_code,
                amount_type,
                boundary_code,
                tolerance_percentage,
                tolerance_amount,
                override_amount,
                account_type,
                dr_cr_code,
                account_category_code,
                effect_on_funds_code,
                je_batch_id,
                je_header_id,
                je_line_num,
                ussgl_parent_id,
                ussgl_link_to_parent_id,
                session_id,
                serial_id,
                application_id)
         select g_packet_id,
                bp.ledger_id,
                bp.je_source_name,
                bp.je_category_name,
                bp.code_combination_id,
                bp.actual_flag,
                bp.period_name,
                bp.period_year,
                bp.period_num,
                bp.quarter_num,
                bp.currency_code,
                'P',
                sysdate,
                g_user_id,
                bp.budget_version_id,
                bp.encumbrance_type_id,
                bp.entered_cr,
                bp.entered_dr,
                bp.accounted_cr,
                bp.accounted_dr,
                bp.ussgl_transaction_code,
                nvl(bp.originating_rowid,
                    decode(bp.ussgl_transaction_code, NULL, NULL, bp.rowid)),
--                decode(bp.account_type, 'C', g_budgetary_enc_flag,
--                       'D', g_budgetary_enc_flag,
--                       nvl(ba.automatic_encumbrance_flag,
--                           bp.automatic_encumbrance_flag)),
                'Y',
                nvl(bo.funding_budget_version_id, bp.funding_budget_version_id),
                decode(bo.funds_check_level_code, null,
                       bp.funds_check_level_code,
                       'D', nvl(od.funds_check_level_code, 'D'),
                       bo.funds_check_level_code),
                nvl(bo.amount_type, bp.amount_type),
                nvl(bo.boundary_code, bp.boundary_code),
                od.tolerance_percentage,
                od.tolerance_amount,
                od.override_amount,
                bp.account_type,
                bp.dr_cr_code,
                bp.account_category_code,
                decode(
                        decode(bp.actual_flag || bp.dr_cr_code ||
                         bp.account_category_code, 'BCP', 'dec', 'ADP', 'dec',
                         'EDP', 'dec', 'ACB', 'dec', 'BCB', 'n/a', 'BDB', 'n/a',
                         'ECB', 'n/a', 'EDB', 'n/a',
                         'PDP', 'dec',
                        'PCB', 'dec', 'FDP', 'dec','FCB', 'n/a', 'FDB','n/a','inc'
                        ),
                  'dec', decode(sign(nvl(bp.accounted_cr, 0) -
                                     nvl(bp.accounted_dr, 0)), 1, 'D', 'I'),
                  'inc', decode(sign(nvl(bp.accounted_cr, 0) -
                                     nvl(bp.accounted_dr, 0)), -1, 'D', 'I'),
                  'n/a', 'I'),
                bp.je_batch_id,
                bp.je_header_id,
                bp.je_line_num,
                bp.ussgl_parent_id,
                bp.ussgl_link_to_parent_id,
                g_session_id,
                g_serial_id,
                g_resp_appl_id
           from psa_option_details_gt od,
                gl_budget_assignments ba,
                gl_bc_packets bp,
                gl_budorg_bc_options bo
          where (od.je_source_name  || ';' || od.je_category_name  =
                 bp.je_source_name     || ';' ||bp.je_category_name )
            and od.packet_id = bp.packet_id
            and ba.ledger_id (+) = g_ledger_id
            and ba.currency_code (+) = bp.currency_code
            and ba.code_combination_id (+) = bp.code_combination_id
            and bo.range_id(+) = ba.range_id
            and bo.funding_budget_version_id
                         in (select BV1.budget_version_id
                             from gl_budget_versions bv1, gl_budgets b,
                                  gl_period_statuses ps
                                 where ba.ledger_id = g_ledger_id
                                   and ba.currency_code = bp.currency_code
                                   and ba.code_combination_id = bp.code_combination_id
                                   and b.budget_name = bv1.budget_name
                                   and ((b.budget_type = 'payment'
                                     and bp.actual_flag in ('P', 'F'))
                                   or
                                       (b.budget_type = 'standard'
                                   and bp.actual_flag not in ('P', 'F')))
                                   and ps.application_id = 101
                                   and ps.ledger_id = g_ledger_id
                                   and ps.period_name = bp.period_name
                                   and ps.start_date
                                      >= (select p1.start_date
                                          from gl_period_statuses p1
                                          where p1.period_name = b.first_valid_period_name
                                            and p1.application_id = ps.application_id
                                            and p1.ledger_id = ps.ledger_id)
                                   and ps.end_date
                                      <= (select p2.end_date
                                          from gl_period_statuses p2
                                         where p2.period_name = b.last_valid_period_name
                                           and p2.application_id = ps.application_id
                                           and p2.ledger_id = ps.ledger_id))
            and bp.packet_id = g_packet_id_ursvd
            and bp.template_id is null
            and bp.status_code = 'A';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Insert gl_bc_packets -> ' || SQL%ROWCOUNT );
    -- ========================= FND LOG =============================

    BEGIN

         SELECT
                'There are USSGL rows in the packet'
         INTO
                l_dummy
         FROM
                DUAL
         WHERE  EXISTS
                (
                 SELECT
                        'Record with non-null USSGL transaction code'
                 FROM
                        GL_BC_PACKETS BP
                 WHERE
                        BP.packet_id = g_packet_id_ursvd
                    AND BP.ussgl_transaction_code IS NOT NULL
                );

        g_append_je_flag := TRUE;

        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_dummy -> ' || l_dummy );
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag -> TRUE');
        -- ========================= FND LOG =============================

    EXCEPTION
        WHEN OTHERS THEN

            -- =========================== FND LOG ===========================
               psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_append_je_flag -> FALSE');
            -- ========================= FND LOG =============================

            g_append_je_flag := FALSE;
    END;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ' );
    -- ========================= FND LOG =============================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS - ' || SQLERRM );
      -- ========================= FND LOG =============================

      if pkt_id%ISOPEN then
        close pkt_id;
      end if;

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE');
      -- ========================= FND LOG =============================

      g_debug := g_debug||'GLXFIU Failed : '||SQLERRM;

      return(FALSE);

  END glxfiu;

  /* ============================= GLXFSS ============================== */

  -- Setup and Summarization

  -- This Module sets up the denormalized columns in the queue such as
  -- Budgetary Control Options, Funds Check Level, Account Type, Transaction
  -- effect on Funds Available, etc. It also validates the Accounting
  -- Flexfield and Period info, inserts Summary Transactions into the queue
  -- and also inserts the arrival sequence of the packet

  FUNCTION glxfss RETURN BOOLEAN IS

    sql_bcp    VARCHAR2(5000);
    str_bc_option_id VARCHAR2(128);

    cursor arrseq is
      select gl_bc_packet_arrival_order_s.nextval
        from dual;

    cursor lock_gl_conc_ctrl is
      select 'Obtain Row Share Lock on the corresponding record for this Set of Books'
        from gl_concurrency_control ct
        where ct.concurrency_class = 'INSERT_PACKET_ARRIVAL'
          and ct.concurrency_entity_name = 'SET_OF_BOOKS'
          and ct.concurrency_entity_id = to_char(g_ledger_id)
        FOR UPDATE;

    l_dummy varchar2(100);

    OVERLAPPING_BUDGET EXCEPTION;
    PRAGMA EXCEPTION_INIT(OVERLAPPING_BUDGET,-1427);


    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

       l_full_path  := g_path || 'glxfss.';

  -- =========================== FND LOG ===========================
     psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFSS - START' );
  -- ========================= FND LOG =============================

    -- Denormalized Columns are not updated if mode is Unreservation since
    -- this is handled in glxfiu()

  -- ========================= FND LOG =============================
     psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
  -- ========================= FND LOG =============================

    if g_fcmode <> 'U' then

    -- Update denormalized columns for all detail transactions in the packet
    -- and perform Accounting Flexfield and Period validation as required. In
    -- case of error, set the result code to one of the following values :
    --
    --      Code      Explanation
    --      ----      ------------------------------------------------------
    --      F20       Accounting Flexfield does not exist
    --      F21       Accounting Flexfield is disabled or out-of-date
    --      F22       Accounting Flexfield does not allow detail posting
    --      F23       Accounting Flexfield does not allow detail budget
    --                posting
    --      F24       Accounting Period does not exist
    --      F25       Accounting Period is neither Open nor Future Enterable
    --      F26       Accounting Period is not within an Open budget year
    --      F27       Budget is Frozen
    --      F28       USSGL Transaction Code is out-of-date


          begin

            update  gl_bc_packets bp
            set     bp.funding_budget_version_id =
              (select decode(pk.actual_flag, 'B', pk.budget_version_id,
                             bo.funding_budget_version_id)
               from    gl_budget_assignments ba,
                       gl_budgets b,
                       gl_budget_versions bv,
                       gl_period_statuses ps,
                       gl_bc_packets pk,
                       gl_budorg_bc_options bo
               where
                    ba.ledger_id(+) = g_ledger_id
                and ba.currency_code(+) = decode(PK.currency_code,
                                                 'STAT', 'STAT',
                                                 g_func_curr_code)
                and ba.code_combination_id (+) = PK.code_combination_id
                and bo.range_id(+) = ba.range_id
                and bo.funding_budget_version_id = bv.budget_version_id
                and bv.budget_name = b.budget_name
                and ((b.budget_type = 'payment' and
                      pk.actual_flag IN ('P', 'F'))
                or
                       (b.budget_type = 'standard' and
                     pk.actual_flag not in ('P', 'F')))
                and ps.application_id = 101
                and ps.ledger_id = g_ledger_id
                and ps.period_name = pk.period_name
                and ps.start_date >= (select p1.start_date
                                      from gl_period_statuses p1
                                      where p1.period_name = b.first_valid_period_name
                                        and p1.application_id = ps.application_id
                                        and p1.ledger_id = ps.ledger_id)
                and ps.end_date <= (select p2.end_date
                                    from gl_period_statuses p2
                                    where p2.period_name = b.last_valid_period_name
                                      and p2.application_id = ps.application_id
                                      and p2.ledger_id = ps.ledger_id)
                  and pk.rowid = bp.rowid
               )
            where bp.packet_id = g_packet_id
              and bp.template_id is null
              and bp.funding_budget_version_id is null;

        EXCEPTION
        WHEN OVERLAPPING_BUDGET THEN

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' There are multiple overlapping budgets assigned to account');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets 1 updated  failed');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Updating the status code = F/R based on g_fcmode');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Updating the result code= F77/F80 based on overlapping budget');
     -- ========================= FND LOG =============================

             update gl_bc_packets bp
             set STATUS_CODE = DECODE(g_fcmode,'C','F','R'),
                 RESULT_CODE=
                 ( select  DECODE(count(bo.FUNDING_BUDGET_VERSION_ID),1,'F77','F80')
                   from
                            gl_bc_packets pk,
                            gl_budget_assignments ba,
                            gl_budorg_bc_options bo
                   where
                            pk.rowid=bp.rowid
                            and pk.code_combination_id=ba.code_combination_id
                            and pk.ledger_id = ba.ledger_id
                            and pk.currency_code = ba.currency_code
                            and ba.range_id = bo.range_id
                 )
              where
               bp.packet_id = g_packet_id;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Set g_overlapping_budget = TRUE, Return -> TRUE');
     -- ========================= FND LOG =============================
       g_overlapping_budget:=TRUE;
       return(TRUE);
      end;


    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets 1 updated -> ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

          update gl_bc_packets bp
         set (bp.automatic_encumbrance_flag,
              bp.funds_check_level_code,
              bp.tolerance_percentage,
              bp.tolerance_amount,
              bp.override_amount,
              bp.account_type,
              bp.dr_cr_code,
              bp.account_category_code,
              bp.effect_on_funds_code,
              bp.result_code) =
             (
              select 'Y',
                     decode(pk.funding_budget_version_id, NULL, 'N', NULL),
                     od.tolerance_percentage,
                     od.tolerance_amount,
                     od.override_amount,
                     cc.account_type,
                     decode(cc.account_type, 'A', 'D', 'E', 'D', 'D', 'D', 'C'),
                     decode(cc.account_type, 'D', 'B', 'C', 'B', 'P'),
                     decode(
                            decode(pk.actual_flag || cc.account_type,
                                   'BL', 'dec',
                                   'BO', 'dec',
                                   'BR', 'dec',
                                   'AA', 'dec',
                                   'AE', 'dec',
                                   'EA', 'dec',
                                   'EE', 'dec',
                                   'AC', 'dec',
                                   'BC', 'n/a',
                                   'BD', 'n/a',
                                   'EC', 'n/a',
                                   'ED', 'n/a',
                                   'inc'),
                            'dec',
                            decode(sign(nvl(pk.accounted_dr, 0)-
                                        nvl(pk.accounted_cr, 0)), 1, 'D', 'I'),
                            'inc',
                            decode(sign(nvl(pk.accounted_dr, 0)-
                                        nvl(pk.accounted_cr, 0)), -1, 'D', 'I'),
                            'n/a', 'I'),
                            decode(cc.code_combination_id, null, 'F20',
                             decode(cc.enabled_flag, 'N', 'F21',
                                decode(pk.actual_flag ||
                                       cc.detail_posting_allowed_flag,
                                       'AN', 'F22', 'EN', 'F22',
                                 decode(pk.actual_flag ||
                                        cc.detail_budgeting_allowed_flag,
                                        'BN', 'F23',
                                  decode(ps.period_name, null, 'F24',
                                   decode(pk.actual_flag || ps.closing_status,
                                          'AN', 'F25', 'AC', 'F25', 'AP', 'F25',
                                    decode(pk.actual_flag ||
                                           nvl(br.open_flag, 'N'), 'BN', 'F26',
                                     decode(pk.actual_flag || bv.status,
                                            'BF', 'F27',
                                      decode(sign(nvl(pk.bc_date, sysdate) -
                                             nvl(uc.start_date_active, nvl(pk.bc_date, sysdate))),
                                             -1, 'F28',
                                       decode(sign(nvl(uc.end_date_active,
                                              nvl(pk.bc_date, sysdate)) - nvl(pk.bc_date, sysdate)), -1, 'F28',
                                        decode(substr(pk.result_code,1,1),
                                               'X', 'F' || substr(pk.result_code,2),
                                         null)))))))))))
              from gl_ussgl_transaction_codes uc,
                   gl_budget_versions bv,
                   gl_budget_period_ranges br,
                   gl_period_statuses ps,
                   gl_code_combinations cc,
                   psa_option_details_gt od,
                   gl_bc_packets pk
             where uc.chart_of_accounts_id (+) = g_coa_id
               and uc.ussgl_transaction_code (+) =
                   nvl(pk.ussgl_transaction_code, -1)
               and bv.budget_version_id (+) = nvl(pk.budget_version_id, -1)
               and br.budget_version_id (+) = nvl(pk.budget_version_id, -1)
               and br.period_year (+) = pk.period_year
               and pk.period_num between br.start_period_num (+)
                                     and br.end_period_num (+)
               and ps.application_id (+) = 101
               and ps.ledger_id (+) = g_ledger_id
               and ps.period_name (+) = pk.period_name
               and cc.code_combination_id (+) = pk.code_combination_id
               and (od.je_source_name  || ';' || od.je_category_name  =
                    pk.je_source_name  || ';' || pk.je_category_name )
                  and od.packet_id = pk.packet_id
               and pk.rowid = bp.rowid
             )
           where bp.packet_id = g_packet_id
          and bp.template_id is null;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets 2 updated -> ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

          update gl_bc_packets bp
          set (funds_check_level_code,
               amount_type,
               boundary_code) = (select
                                    nvl(min(decode(bo.funds_check_level_code, 'D',
                                           nvl(od.funds_check_level_code, 'D'),
                                           nvl(bo.funds_check_level_code, 'N'))), 'N'),
                                    min(bo.amount_type),
                                    min(bo.boundary_code)
                                 from gl_bc_packets pk,
                                      psa_option_details_gt od,
                                      gl_budget_assignments ba,
                                      gl_budorg_bc_options bo
                                where pk.rowid = bp.rowid
                                  and (od.je_source_name  || ';' || od.je_category_name  =
                                       pk.je_source_name  || ';' || pk.je_category_name )
                                  and od.packet_id = pk.packet_id
                                  and ba.ledger_id = g_ledger_id
                                  and ba.currency_code = decode(pk.currency_code,
                                                                    'STAT', 'STAT',
                                                                    g_func_curr_code)
                                  and ba.code_combination_id = pk.code_combination_id
                                  and bo.range_id = ba.range_id
                                  and bo.funding_budget_version_id = pk.funding_budget_version_id)
          where bp.packet_id = g_packet_id
            and bp.funding_budget_version_id is not null;


    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets 3 updated -> ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================


    /*----------------------------------------------------------------------+
     | Bug 5242198 : When an account is assigned with different funds check |
     | level(say Absolute and Advisory) the account is assumed to have a    |
     | funds check level of absolute with no funding budget for preiods with|
     | no budget assignments...                                             |
     +----------------------------------------------------------------------*/

    if(nvl(g_enable_efc_flag,'N')='Y') THEN
      update gl_bc_packets bp
       set bp.funds_check_level_code = 'B'
        where bp.packet_id = g_packet_id
          and bp.template_id is null
          and bp.funds_check_level_code = 'N'
          and bp.funding_budget_version_id IS NULL
          and exists
                     (select null
                        from gl_budget_assignments ba
                       where ba.code_combination_id = bp.code_combination_id
                         and ba.ledger_id = bp.ledger_id
                         and ba.currency_code = bp.currency_code

                      );
    end if;
    end if;    -- g_fcmode <> 'U'


    -- Prior to inserting Summary Transactions for the packet, we lock the
    -- dummy table gl_bc_dual2 in row share mode to ensure data consistency
    -- between the Funds Checker Summarization and the Add/Delete Summary
    -- Accounts process. This ensures that that only one process will
    -- summarize the transactions in the queue

    -- When a lock on gl_bc_dual2 is not available then
    --
    --     if Funds Checker is invoked from a Concurrent Process, it waits
    --
    --     if Funds Checker is invoked from an Online Process, it exits with
    --     a fatal error


    if g_conc_flag then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Lock gl_bc_dual2 in row share mode' );
       -- ========================= FND LOG =============================
       LOCK TABLE gl_bc_dual2 IN ROW SHARE MODE;
    else
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Lock gl_bc_dual2 in row share mode nowait' );
       -- ========================= FND LOG =============================
       LOCK TABLE gl_bc_dual2 IN ROW SHARE MODE NOWAIT;
    end if;


    -- Insert Summary Transactions for the Packet. Summarization Grouping is
    -- based on Summary Code Combination, Balance Type, Period Name, Currency
    -- Code, Encumbrance Type, JE Source, JE Category and Budget Name

    -- The Join Condition
    --
    --     st.account_category_code = bp.account_category_code
    --
    -- ensures that if a template is Proprietary, Summarization ignore any
    -- Budgetary Detail Accounts that may fall into the same Rollup Structure,
    -- and vice-versa

       insert into gl_bc_packets (packet_id,
                    ledger_id,
                    je_source_name,
                    je_category_name,
                    code_combination_id,
                    actual_flag,
                    period_name,
                    period_year,
                    period_num,
                    quarter_num,
                    currency_code,
                    status_code,
                    last_update_date,
                    last_updated_by,
                    budget_version_id,
                    encumbrance_type_id,
                    template_id,
                    entered_dr,
                    entered_cr,
                    accounted_dr,
                    accounted_cr,
                    funding_budget_version_id,
                    funds_check_level_code,
                    amount_type,
                    boundary_code,
                    tolerance_percentage,
                    tolerance_amount,
                    override_amount,
                    dr_cr_code,
                    account_category_code,
                    effect_on_funds_code,
                    session_id,
                    serial_id,
                    application_id)
        select
           min(bp.packet_id),
           min(bp.ledger_id),
           min(bp.je_source_name),
           min(bp.je_category_name),
           min(ah.summary_code_combination_id),
           min(bp.actual_flag),
           min(bp.period_name),
           min(bp.period_year),
           min(bp.period_num),
           min(bp.quarter_num),
           min(bp.currency_code),
           min(bp.status_code),
           min(bp.last_update_date),
           min(bp.last_updated_by),
           min(decode(bp.actual_flag, 'B', bp.budget_version_id, null)),
           min(decode(bp.actual_flag, 'E', bp.encumbrance_type_id,null)),
           min(st.template_id),
           sum(nvl(bp.entered_dr, 0)),
           sum(nvl(bp.entered_cr, 0)),
           sum(nvl(bp.accounted_dr, 0)),
           sum(nvl(bp.accounted_cr, 0)),
           min(sb.funding_budget_version_id),
           min(decode(sb.funds_check_level_code, 'D',
                      nvl(od.funds_check_level_code, 'D'),
                      sb.funds_check_level_code)),
           min(sb.amount_type),
           min(sb.boundary_code),
           min(od.tolerance_percentage),
           min(od.tolerance_amount),
           min(od.override_amount),
           min(sb.dr_cr_code),
           min(st.account_category_code),
           decode(
           decode(min(bp.actual_flag) || min(sb.dr_cr_code)  ||
                  min(st.account_category_code),
               'BCP', 'dec', 'ADP', 'dec',
                       'EDP', 'dec', 'ACB', 'dec', 'BCB',
               'n/a', 'BDB', 'n/a',
                       'ECB', 'n/a', 'EDB', 'n/a', 'inc'),
                  'dec',
           decode(sign(sum(nvl(bp.accounted_dr, 0) -
                            nvl(bp.accounted_cr, 0))), 1, 'D', 'I'),
             'inc',
           decode(sign(sum(nvl(bp.accounted_dr, 0) -
                            nvl(bp.accounted_cr, 0))), -1, 'D', 'I'),
             'n/a', 'I'),
           min(bp.session_id),
           min(bp.serial_id),
           min(bp.application_id)
      from psa_option_details_gt od,
           gl_period_statuses ps,
           gl_summary_templates st,
           gl_account_hierarchies ah,
           gl_bc_packets bp,
           gl_summary_bc_options sb,
           gl_budgets b,
           gl_budget_versions bv,
           gl_period_statuses ps2
     where st.status = 'F'
       and sb.funds_check_level_code   || od.funds_check_level_code <> 'DN'
       and st.template_id = ah.template_id
       and sb.funding_budget_version_id = decode(bp.actual_flag,
                                                 'B', bp.budget_version_id,
                                                 sb.funding_budget_version_id)
       and st.account_category_code = bp.account_category_code
       and ps.ledger_id = g_ledger_id
       and ps.application_id = 101
       and ps.period_name = st.start_actuals_period_name
       and (ps.period_year * 10000 + ps.period_num) <=
           (bp.period_year * 10000 + bp.period_num)
       AND SB.template_id = ST.template_id
       AND SB.funding_budget_version_id = BV.budget_version_id
       AND BV.budget_name = B.budget_name
       AND  ((BV.budget_type = 'payment' AND BP.actual_flag in ('P', 'F'))
             OR (BV.budget_type = 'standard' AND BP.actual_flag in ('A', 'E'))
             OR (BP.actual_flag = 'B'))
       and ps2.ledger_id = g_ledger_id
       and ps2.application_id = 101
       AND PS2.period_name = BP.period_name
       AND PS2.start_date >= (select P1.start_date
                              from   GL_PERIOD_STATUSES P1
                              where  P1.application_id = ps2.application_id
                                and  P1.ledger_id = ps2.ledger_id
                                and  P1.period_name = B.first_valid_period_name)
       AND PS2.end_date <= (select P2.end_date
                            from   GL_PERIOD_STATUSES P2
                            where  P2.application_id = ps2.application_id
                              and  P2.ledger_id = ps2.ledger_id
                              and  P2.period_name = B.last_valid_period_name)
       and ah.ledger_id =   g_ledger_id
       and ah.detail_code_combination_id = bp.code_combination_id
       and od.packet_id =  bp.packet_id
       and od.je_source_name || ';' || od.je_category_name =
           bp.je_source_name || ';' || bp.je_category_name
       and (bp.je_batch_id is not null
         or bp.automatic_encumbrance_flag = 'Y'
         or bp.actual_flag <> 'E')
       and bp.packet_id =   g_packet_id
       and bp.result_code is null
     group by ah.summary_code_combination_id,
              bp.actual_flag,
              bp.period_name,
              bp.encumbrance_type_id,
              bp.period_num, -- Bug 3259452
              bp.currency_code,
              bp.je_source_name,
              bp.je_category_name,
              bp.budget_version_id
     having sum(nvl(bp.accounted_dr, 0) - nvl(bp.accounted_cr, 0)) <> 0;



    -- Set Summarized Flag if Summary Transactions were inserted into the queue

    if SQL%FOUND then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Insert gl_bc_packets - summ trans ' || SQL%ROWCOUNT );

          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' g_summarized_flag -> TRUE' );
       -- ========================= FND LOG =============================
       g_summarized_flag := TRUE;
    end if;


    -- Insert Arrival Sequence for the Packet. The Row Share Lock ensures that
    -- packets are assigned sequences strictly in order of arrival

    -- When a lock on gl_concurrency_control is not available then
    --
    --     if Funds Checker is invoked from a Concurrent Process, it waits
    --
    --     if Funds Checker is invoked from an Online Process, it exits with
    --     an error

   if g_conc_flag then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' g_conc_flag -> TRUE' );
       -- ========================= FND LOG =============================

      open lock_gl_conc_ctrl;
      fetch lock_gl_conc_ctrl into l_dummy;
      close lock_gl_conc_ctrl;

    end if;


    -- Get Arrival Sequence

    open arrseq;
    fetch arrseq into g_arrival_seq;
    close arrseq;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_arrival_seq -> ' || g_arrival_seq);
    -- ========================= FND LOG =============================

    insert into gl_bc_packet_arrival_order
               (packet_id,
                ledger_id,
                arrival_seq,
                affect_funds_flag,
                last_update_date,
                last_updated_by)
        values (g_packet_id,
                g_ledger_id,
                g_arrival_seq,
                decode(g_fcmode, 'C', 'N', 'Y'),
                sysdate,
                g_user_id);


    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' insert gl_bc_packet_arrival_order -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================

    -- Commit to release Lock on gl_concurrency_control
    commit;


    -- Since the previous Commit has also released the lock on gl_bc_dual2, we
    -- need to reestablish the lock to maintain data consistency between the
    -- Funds Checker Summarization and the Add/Delete Summary Accounts
    -- process

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' lock table gl_bc_dual2 in row share mode nowait');
    -- ========================= FND LOG =============================

    LOCK TABLE gl_bc_dual2 IN ROW SHARE MODE NOWAIT;

     -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' RETURN -> TRUE ');
    -- ========================= FND LOG =============================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN

     -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
     -- ========================= FND LOG =============================

     if arrseq%ISOPEN then
        close arrseq;
      end if;

      if SQLCODE = -54 then
        message_token('PROCEDURE', 'Funds Checker');
        message_token('EVENT', 'Table Locked by Add/Delete Summary Accounts Process');
        add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      else
        message_token('PROCEDURE', 'Funds Checker');
        message_token('EVENT', SQLERRM);
        add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      end if;

     -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE');
     -- ========================= FND LOG =============================
      g_debug := g_debug||'GLXFSS Failed : '||SQLERRM;

      return(FALSE);

  END glxfss;

  /* ============================= GLXFGB =========================== */

  -- Process Balances
  -- Find Pending and Approved Actual, Budget and Encumbrance transaction
  -- balances in the queue that would affect funds availability for the
  -- transactions in this packet
  -- Find the posted actual, budget and encumbrance balances in the balances
  -- table that would affect funds availability for the transactions in this
  -- packet

  FUNCTION glxfgb RETURN BOOLEAN IS

     -- Bug 3574935

     --Bug 6823089 ..
     --l_max_packet_id gl_bc_packets.packet_id%type;

     -- Bug 5644702
     l_effective_period_num gl_period_statuses.effective_period_num%TYPE;
     l_period_name          gl_period_statuses.period_name%TYPE;
     l_quarter_num          gl_period_statuses.quarter_num%TYPE;
     l_period_year          gl_period_statuses.period_year%TYPE;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

       l_full_path := g_path || 'glxfgb';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFGB - START' );
    -- ========================= FND LOG =============================


    -- Bug 3574935 .. Start
    -- Obtain the maximum packet_id less than the current arrival sequence from
    -- table gl_bc_packet_arrival_order. This will then be used in the following
    -- UPDATE statement to help improve performance of the query. Making use of
    -- packet_id condition in the subquery makes index gl_bc_packets_n2 more
    -- selective and reduces number of rows processed during access to the table
    -- gl_bc_packet_arrival_order

    -- Bug 4651919 .. Start
    -- Added ledger_id and affect_funds_flag conditions in WHERE clause

    -- Bug 6823089.
  --  SELECT max(packet_id) INTO l_max_packet_id
  --  FROM gl_bc_packet_arrival_order
  --  WHERE arrival_seq < g_arrival_seq
  --  AND  ledger_id = g_ledger_id;
--    AND  affect_funds_flag = 'Y';

    -- Bug 4651919 .. End

    -- Bug 3574935 .. End

    -- =========================== FND LOG ===========================
   --    psa_utils.debug_other_string(g_state_level,l_full_path, ' l_max_packet_id -> '|| l_max_packet_id );
    -- ========================= FND LOG =============================

    -- Lock dummy table gl_bc_dual in Row Share Mode to ensure Read Consistency
    -- between gl_bc_packets and gl_balances in the next two balance update
    -- SQLs. This scheme requires posting to lock gl_bc_dual in exclusive mode
    -- before it commits, and to wait in a sleep cycle of 15 seconds until all
    -- the Funds Check processes release the locks. This prevents the Funds
    -- Checker from counting the Balances twice, in case Posting Commits in
    -- between the two SQLs, and some of the pending balances got transferred
    -- to gl_balances, where the funds checker would mistakenly treat them as
    -- Posted Balances in the second SQL

    -- When a lock on gl_bc_dual is not available then
    --
    --     if Funds Checker is invoked from a Concurrent Process, it waits
    --
    --     if Funds Checker is invoked from an Online Process, it exits with
    --     a fatal error

    if g_conc_flag then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Lock table gl_bc_dual in exclusive  mode' );
       -- ========================= FND LOG =============================
      LOCK TABLE gl_bc_dual IN EXCLUSIVE MODE; --Bug 7476309
    else
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Lock table gl_bc_dual in exclusive mode NOWAIT' );
       -- ========================= FND LOG =============================
      LOCK TABLE gl_bc_dual IN EXCLUSIVE MODE NOWAIT; --Bug 7476309
    end if;


    -- Update Approved and Pending Balances in gl_bc_packets
    --
    -- Transactions in the gl_bc_packets that would affect the transactions in
    -- this packet are :
    --
    --   all approved packets, for the same Set of Books, that arrived earlier
    --
    --   all pending packets, for the same Set of Books, that arrived earlier
    --   and which reduce Funds Available
    --
    --   all rows in the current packet that have a lower combined score of
    --   Rank(Funds Check Level) || Rowid than the row currently being
    --   processed
    --
    --   all transactions in the current packet that would increase funds
    --   available

    -- Summary of Funds Check Level Rank :
    --
    --    Funds Check Level     Rank
    --    -----------------     ----
    --    None (N)               0
    --    Advisory (D)           1
    --    Absolute (B)           2
    --
    --    For example, when processing an Advisory Transaction, rows in the same
    --    packet that need to be considered in this category include all rows
    --    with Funds Check Level None, and all Advisory Transactions with a
    --    lower rowid than that of the row currently being processed

    -- Subquery needs to join to gl_budgets, gl_budget_versions and
    -- gl_period_statuses to get the last period in the latest open year of
    -- the Funding Budget for the Boundary Code 'project'

    -- Summary of WHERE clauses based on Amount Type and Boundary :
    --
    --    Amount Type   Where Clauses
    --    -----------   -------------
    --       PTD        where p2.period_year = p1.period_year
    --                    and p2.period_num =  p1.period_num
    --
    --       QTD        where p2.period_year = p1.period_year
    --                    and p2.quarter_num = p1.quarter_num
    --
    --       YTD        where p2.period_year = p1.period_year
    --
    --       PJTD       <no restriction>
    --
    --    Boundary      Where Clauses
    --    --------      -------------
    --    Period        and ((p2.period_year = p1.period_year
    --                   and  p2.period_num <= p1.period_num)
    --                    or (p2.period_year < p1.period_year))
    --
    --    Quarter       and ((p2.period_year = p1.period_year
    --                   and  p2.quarter_num <= p1.quarter_num)
    --                    or (p2.period_year < p1.period_year))
    --
    --    Year          and p2.period_year <= p1.period_year
    --
    --    Project       and ((p2.period_year = EOB.period_year
    --                   and  p2.period_num <= EOB.period_num)
    --                    or (p2.period_year < EOB.period_year))
    --    EOB = Last Period in Latest Open Year of Budget


    update
           gl_bc_packets bp
       set (bp.budget_approved_balance,
            bp.actual_approved_balance,
            bp.encumbrance_approved_balance,
            bp.budget_pending_balance,
            bp.actual_pending_balance,
            bp.encumbrance_pending_balance) =
           (
            select
                   sum(decode(pk.status_code || pk.actual_flag,
                                    'AB', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                                 0)
                      ),
                   sum(decode(pk.status_code || pk.actual_flag,
                                 'AA', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              0)
                      ),
                   sum(decode(pk.status_code || pk.actual_flag,
                                 'AE', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              0)
                      ),
                   sum(decode(pk.status_code || pk.actual_flag,
                                 'PB', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              'CB', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              0)
                      ),
                   sum(decode(pk.status_code || pk.actual_flag,
                                 'PA', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              'CA', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              0)
                      ),
                   sum(decode(pk.status_code || pk.actual_flag,
                                 'PE', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              'CE', nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0),
                              0)
                      )
              from gl_period_statuses ps,
                   gl_budgets bd,
                   gl_budget_versions bv,
                   gl_bc_packets pk,
                   gl_bc_packet_arrival_order ao
             where ps.application_id = 101
               and ps.ledger_id = g_ledger_id
               and ps.period_name = bd.last_valid_period_name
               and bd.budget_name = bv.budget_name
               and bd.budget_type = bv.budget_type
               and bv.budget_version_id = bp.funding_budget_version_id
               and pk.funding_budget_version_id = bp.funding_budget_version_id
               and pk.ledger_id = g_ledger_id
               and pk.code_combination_id = bp.code_combination_id
               and (pk.budget_version_id is null
                 or pk.budget_version_id = bp.funding_budget_version_id)
               and pk.period_year = decode(bp.amount_type, 'PJTD',
                                           pk.period_year, bp.period_year)
               and pk.period_num = decode(bp.amount_type, 'PTD',
                                          bp.period_num, pk.period_num)
               and pk.quarter_num = decode(bp.amount_type, 'QTD',
                                           bp.quarter_num, pk.quarter_num)
               and ((pk.period_year = decode(bp.boundary_code,
                                             'J', bd.latest_opened_year,
                                             bp.period_year)
                 and pk.period_num <= decode(bp.boundary_code, 'P',
                                             bp.period_num, 'J',
                                       decode(ps.period_year,
                                              bd.latest_opened_year,
                                              ps.period_num,
                                              pk.period_num), pk.period_num)
                 and pk.quarter_num <= decode(bp.boundary_code, 'Q',
                                              bp.quarter_num, pk.quarter_num))
                or pk.period_year < decode(bp.boundary_code, 'J',
                                           bd.latest_opened_year,
                                           bp.period_year))
               and pk.currency_code = decode(pk.actual_flag, 'B',
                                             g_func_curr_code, pk.currency_code)
               and pk.packet_id = ao.packet_id
               and ((pk.packet_id = g_packet_id            -- Bug 3574935
                 and (decode(pk.funds_check_level_code, 'N', '0', 'D', '1',
                             'B', '2') || pk.rowid <
                          decode(bp.funds_check_level_code, 'N', '0', 'D', '1',
                                 'B', '2') || bp.rowid
                  or pk.effect_on_funds_code = 'I'))

               --Bug 6823089.. Start
              --   or (pk.packet_id <= l_max_packet_id        -- Bug 3574935, Bug 4119217
                   or(pk.packet_id >=0 and pk.status_code = 'A') --Bug 7476309
                   or (pk.packet_id >= 0
               --Bug 6823089.. End

                  and ao.arrival_seq < g_arrival_seq
--                 and ao.affect_funds_flag = 'Y'
                 and ao.ledger_id = g_ledger_id
                 and nvl(pk.result_code, 'X') like
                         decode(pk.status_code, 'A', 'P%', 'P', 'P%', 'C', 'P%', 'X')      -- Bug 4630687
                 -- Bug 5046369 start
                 and (
                       (pk.status_code IN ('P', 'C')
                       and exists (select 'Packet is valid for the current session'
                                   from v$session s
                                   WHERE s.audsid = pk.session_id
                                   AND s.serial# = pk.serial_id)
                       )
                       OR
                       pk.status_code = 'A'
                     )))
                 -- rgopalan Bug 2799257
                 and EXISTS
                     (SELECT 'x' FROM fnd_currencies
                      WHERE currency_code = PK.currency_code
                      AND   currency_flag = 'Y')
           )
     where bp.packet_id = g_packet_id
       and bp.result_code is null
       and bp.effect_on_funds_code = 'D'
       and bp.funds_check_level_code <> 'N'
       and bp.currency_code = decode(bp.actual_flag, 'B', g_func_curr_code,
                                     bp.currency_code)
       and bp.funding_budget_version_id = decode(bp.actual_flag, 'B',
                                                 bp.budget_version_id,
                                                 bp.funding_budget_version_id)
       -- rgopalan Bug 27992557
       and exists
           (SELECT 'x' FROM fnd_currencies
            WHERE currency_code = BP.currency_code
            AND   currency_flag = 'Y');


       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Update approved and pending balance in gl_bc_packets ' || SQL%ROWCOUNT );
       -- ========================= FND LOG =============================


    -- Update Posted Balances in gl_bc_packets
    --
    -- For Actuals, we subtract the begin balances of the first period of the
    -- transaction year, i.e YTD Funds Available includes actual activities
    -- accumulated during the current transaction year
    --
    -- For Budgets and Encumbrances, we do not need to include the begin
    -- balances of the first period since these are encumbrances, encumbered
    -- budgets and/or unused funds that are carried forward from the previous
    -- year

    -- Subtraction of first period actual begin balance is done via special rows
    -- in gl_bc_period_map with boundary code 'S'. The PM.boundary_code AND
    -- clause in the correlated update query joins to these 'S' rows in addition
    -- to the regular PM rows for the case of YTD, and b/s or summary accounts,
    -- where they are eventually used in the 'AYTD' sum decode operation for the
    -- subtraction
    --
    -- Explain Plan :
    --
    -- OPERATION                            OPTIONS     OBJECT_NAME
    -- ------------------------------------ ----------- -------------------
    -- SORT                                 AGGREGATE
    --   NESTED LOOPS
    --     NESTED LOOPS
    --       TABLE ACCESS                   BY ROWID    GL_BC_PACKETS
    --         INDEX                        RANGE SCAN  GL_BC_PACKETS_N1
    --       INDEX                          RANGE SCAN  GL_BC_PERIOD_MAP_U2
    --     TABLE ACCESS                     BY ROWID    GL_BALANCES
    --       INDEX                          RANGE SCAN  GL_BALANCES_N1
    --

 -- Due to Bug 5644702 moved the fix of Bug 3243216 here.

    BEGIN
       SELECT  nvl(effective_period_num,0),  period_name,  NVL(quarter_num,0),  NVL(period_year,0)
       INTO   l_effective_period_num, l_period_name, l_quarter_num, l_period_year
       FROM   gl_period_statuses
       WHERE  ledger_id = g_ledger_id
       AND    application_id  = 101
       AND    closing_status  = 'O'
       AND    effective_period_num =
                (SELECT max(effective_period_num)
                 FROM   gl_period_statuses
                 WHERE  ledger_id = g_ledger_id
                 AND    application_id  = 101
                 AND    closing_status  = 'O');
    EXCEPTION
      WHEN no_data_found THEN
       l_effective_period_num := 0;
       l_period_name          := NULL;
       l_quarter_num          := 0;
       l_period_year          := 0;
    END;
          -- =========================== FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
             ' Picking up the lates OPEN period ' || SQL%ROWCOUNT );
             psa_utils.debug_other_string(g_state_level,l_full_path, ' l_effective_period_num -> ' || l_effective_period_num);
             psa_utils.debug_other_string(g_state_level,l_full_path, ' l_period_name -> ' || l_period_name);
             psa_utils.debug_other_string(g_state_level,l_full_path, ' l_quarter_num -> ' || l_quarter_num);
             psa_utils.debug_other_string(g_state_level,l_full_path, ' l_period_year -> ' || l_period_year);
          -- ========================= FND LOG =============================

    -- Bugfix 2231059

    update
           gl_bc_packets bp
       set (bp.budget_posted_balance,
            bp.actual_posted_balance,
            bp.encumbrance_posted_balance) =
           (
            select

                   sum(decode(gb.actual_flag || bp.amount_type, 'BPTD',
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0),
                       'BQTD', nvl(gb.quarter_to_date_dr, 0) -
                       nvl(gb.quarter_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0)- nvl(gb.period_net_cr, 0),
                       'BYTD', nvl(gb.begin_balance_dr, 0) -
                       nvl(gb.begin_balance_cr, 0) + nvl(gb.period_net_dr, 0) -
                       nvl(gb.period_net_cr, 0),
                       'BPJTD', nvl(gb.project_to_date_dr, 0) -
                       nvl(gb.project_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0), 0)),
                   sum(decode(gb.actual_flag || bp.amount_type, 'APTD',
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0),
                       'AQTD', nvl(gb.quarter_to_date_dr, 0) -
                       nvl(gb.quarter_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0),
                       'AYTD', decode(pm.boundary_code, 'S',
                       nvl(gb.begin_balance_cr, 0) -
                       nvl(gb.begin_balance_dr, 0),
                       nvl(gb.begin_balance_dr, 0) -
                       nvl(gb.begin_balance_cr, 0) + nvl(gb.period_net_dr, 0) -
                       nvl(gb.period_net_cr, 0)),
                       'APJTD', nvl(gb.project_to_date_dr, 0) -
                       nvl(gb.project_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0), 0)),
                   sum(decode(gb.actual_flag || bp.amount_type, 'EPTD',
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0),
                       'EQTD', nvl(gb.quarter_to_date_dr, 0) -
                       nvl(gb.quarter_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0),
                       'EYTD', nvl(gb.begin_balance_dr, 0) -
                       nvl(gb.begin_balance_cr, 0) + nvl(gb.period_net_dr, 0) -
                       nvl(gb.period_net_cr, 0),
                       'EPJTD', nvl(gb.project_to_date_dr, 0) -
                       nvl(gb.project_to_date_cr, 0) +
                       nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0), 0))
              from gl_bc_period_map pm,
                   gl_balances gb
                   -- ## selecting the latest open period
                   -- ## Changes made  For fix in Bug 3243216
                    /* (select effective_period_num e, period_name n,quarter_num q,
                      period_year y, ledger_id s, application_id a from gl_period_statuses
                      where
                         ledger_id= g_ledger_id and application_id =101 and closing_status='O'
                         and effective_period_num =
                             (select max(effective_period_num) from
                              gl_period_statuses where ledger_id= g_ledger_id and application_id =101 and
                              closing_status='O'))X*/ --Bug 5644702
            WHERE
---                    X.s = gb.ledger_id and x.a =101 and
                   -- ## changes for the bug 3243216
                   gb.ledger_id = g_ledger_id
               and gb.code_combination_id = bp.code_combination_id
               and gb.currency_code = g_func_curr_code
               and gb.actual_flag = pm.actual_flag
               and (gb.budget_version_id is null
                 or gb.budget_version_id = pm.budget_version_id)
                 -- ## Bug 3243216 replacement below
                       AND GB.period_name = PM.query_period_name
                    -- commented out below part as now we are selecting transaction period
                    -- based on latest open period and accordingly joining with gl_balances on query_period
                     /*  AND GB.period_name = decode (PM.boundary_code, 'S', PM.query_period_name,
                                             decode(GB.actual_flag,
                                                    'B', PM.query_period_name,
                                                    'A', decode(GREATEST(BP.period_year*10000+BP.period_num, l_effective_period_num),
                                                         BP.period_year*10000+BP.period_num,
                                                         decode(BP.amount_type,
                                                                'PTD', PM.query_period_Name,
                                                                'QTD', decode(BP.period_year,
                                                                              l_period_year, decode(BP.quarter_num,
                                                                                                   l_quarter_num, l_period_name,
                                                                                                   pm.query_period_name),
                                                                              PM.query_period_name),
                                                                'YTD', decode(BP.period_year,
                                                                              l_period_year, l_period_name,
                                                                              PM.query_Period_name),
                                                                'PJTD',decode(l_period_name,
                                                                               NULL, PM.query_Period_name, l_period_name),
                                                                PM.query_period_name),
                                                         PM.query_period_name),
                                                    'E', PM.query_period_name)
                                             ) */

               and pm.ledger_id = g_ledger_id
               -- and pm.transaction_period_name = bp.period_name
                and pm.transaction_period_name =  decode(pm.actual_flag,
                                                    'B', bp.period_name,
                                                    'A', decode(GREATEST(BP.period_year*10000+BP.period_num, l_effective_period_num),
                                                         BP.period_year*10000+BP.period_num,
                                                         decode(BP.amount_type,
                                                                'PTD', bp.period_name,
                                                                'QTD', decode(BP.period_year,
                                                                              l_period_year, decode(BP.quarter_num,
                                                                                                   l_quarter_num, l_period_name,
                                                                                                   bp.period_name),
                                                                              bp.period_name),
                                                                'YTD', decode(BP.period_year,
                                                                              l_period_year, l_period_name,
                                                                              bp.period_name),
                                                                'PJTD',decode(l_period_name,
                                                                               NULL, bp.period_name, l_period_name),
                                                                bp.period_name),
                                                         bp.period_name),
                                                    'E', bp.period_name)
               and pm.boundary_code between 'A' AND 'Z'
               and pm.boundary_code || '' in
                  (bp.boundary_code, decode(bp.amount_type, 'YTD',
                   decode(bp.template_id, null, decode(bp.account_type,
                          'A', 'S', 'L', 'S', 'O', 'S'), 'S')))
               and (pm.budget_version_id is null
                 or pm.budget_version_id = bp.funding_budget_version_id)
           )
     where bp.packet_id = g_packet_id
       and bp.result_code is null
       and bp.effect_on_funds_code = 'D'
       and bp.funds_check_level_code <> 'N'
       and bp.currency_code = decode(bp.actual_flag, 'B', g_func_curr_code,
                                     bp.currency_code)
       and bp.funding_budget_version_id = decode(bp.actual_flag, 'B',
                                                 bp.budget_version_id,
                                                 bp.funding_budget_version_id);


       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' Update posted balance in gl_bc_packets ' || SQL%ROWCOUNT );
       -- ========================= FND LOG =============================

       -- Commit to release Lock on gl_bc_dual
      -- commit; Commented for Bug 7476309


    -- Reestablish the Row Share Lock on gl_bc_dual2 to maintain data
    -- consistency between the Funds Checker Summarization and the Add/Delete
    -- Summary Accounts program

    -- =========================== FND LOG ===========================
     --  psa_utils.debug_other_string(g_state_level,l_full_path,
     --  ' Lock table gl_bc_dual2 in row share mode nowait' ); --Commented for Bug 7476309
    -- ========================= FND LOG =============================
   -- LOCK TABLE gl_bc_dual2 IN ROW SHARE MODE NOWAIT; --Commented for Bug 7476309

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE ' );
    -- ========================= FND LOG =============================
    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path,' EXCEPTION WHEN OTHERS '|| SQLERRM );
    -- ========================= FND LOG =============================

      if SQLCODE = -54 then
        message_token('PROCEDURE', 'Funds Checker');
        message_token('EVENT', 'Table Locked by another Process');
        add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      else
        message_token('PROCEDURE', 'Funds Checker');
        message_token('EVENT', SQLERRM);
        add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path,' RETURN -> FALSE ' );
    -- ========================= FND LOG =============================
      g_debug := g_debug||' GLXFGB Failed : '||SQLERRM;

      return(FALSE);

  END glxfgb;

  /* ================================ GLXFRC ============================ */

  -- Update Result Codes

  -- Set the Result Code for each transaction in the packet by computing funds
  -- availability
  --
  -- In case of Overrides, update the result codes for the detail transactions,
  -- generated transactions and summary transactions if the Transaction Amount
  -- is less than or equal to the Override Amount
  --
  -- Update the Result Code for each detail transaction that causes one or
  -- more of its corresponding summary transactions to fail Funds Check or
  -- Funds Reservation
  --
  -- Update the Result Code for each detail transaction that has one or more
  -- of its associated proprietary or Budgetary transactions that fail
  -- Funds Check or Funds Reservation (only when USSGL Option is set)

  -- Structure of the Result Codes :
  --
  --    Range     Meaning
  --  --------    ------------------------------------------------------------
  --  P00 - P09   Pass; Does not reduce FA / Does not require FC
  --  P10 - P14   Pass; Normal Pass - Proprietary
  --  P15 - P19   Pass; Normal Pass - Budgetary
  --  P20 - P24   Pass; Pass with Warnings - Proprietary
  --  P25 - P29   Pass; Pass with Warnings - Budgetary
  --  F00 - F09   Fail; Insufficient Funds - Proprietary
  --  F10 - F19   Fail; Insufficient Funds - Budgetary
  --  F20 - F29   Fail; Validation Errors

  --  Result Codes for Funds Reservation/Check :
  --
  --      Code  Explanation
  --      ----  --------------------------------------------------------
  --      P00   This transaction does not reduce Funds available
  --      P01   This account does not require Funds Check
  --      P02   This budget transaction applies to a budget other than your
  --            Funding Budget
  --      P03   This foreign currency budget transaction does not
  --            require Funds Check
  --      P04   This summary transaction is created by the Add Summary Accounts
  --            program
  --      P05   This transaction passes Funds Check in Force Pass mode
  --      P10   This transaction passes Funds Check
  --      P15   This budgetary transaction passes Funds Check
  --      P20   This transaction fails Funds Check; advisory checking is in
  --            force
  --      P21   This transaction fails Funds Check; you overrode the failure
  --      P22   This detail transaction causes a summary account to fail
  --            Funds Check (advisory)
  --      P23   This summary account fails Funds Check; you overrode
  --            the detail(s)
  --      P25   This budgetary transaction fails Funds Check; advisory checking
  --            is in force
  --      P26   This budgetary transaction fails Funds Check; you overrode the
  --            failure
  --      P27   This budgetary transaction causes a summary account to fail
  --            to fail Funds Check (advisory)
  --      F00   This detail transaction fails Funds Check
  --      F01   This detail transaction causes a summary account to fail
  --            Funds Check
  --      F02   This summary account fails Funds Check
  --      F03   One or more earlier pending transactions cause this
  --            transaction to fail
  --      F04   This detail transaction fails and causes a summary account to
  --            fail Funds Check
  --      F05   One or more associated generated transactions cause this
  --            transaction to fail
  --      F06   One or more associated transactions cause this proprietary
  --            transaction to fail
  --      F10   This budgetary detail transaction fails Funds Check
  --      F11   This budgetary detail transaction causes a summary account to
  --            fail Funds Check
  --      F12   This budgetary summary account fails Funds Check
  --      F13   One or more earlier pending transactions cause the budgetary
  --            transaction to fail
  --      F14   This budgetary transaction fails and also causes a summary
  --            account to fail
  --      F15   One or more associated transactions cause this budgetary
  --            transaction to fail
  --      F20   This Accounting Flexfield does not exist
  --      F21   This Accounting Flexfield is disabled or out-of-date
  --      F22   This Accounting Flexfield does not allow detail posting
  --      F23   This Accounting Flexfield does not allow detail budget posting
  --      F24   This accounting period does not exist
  --      F25   This accounting period is neither Open nor Future Enterable
  --      F26   This accounting period is not within an open budget year
  --      F27   This budget is frozen
  --      F28   This USSGL transaction code is out-of-date

  FUNCTION glxfrc RETURN BOOLEAN IS

    cursor retcode is
    select decode(count(*),
                  count(decode(substr(bp.result_code, 1, 1), 'P', 1)),
                  decode(sign(count(decode(bp.result_code, 'P20', 1,
                                                           'P22', 1,
                                                           'P25', 1,
                                                           'P27', 1,
                                                           'P31', 1,
                                                           'P35', 1,
                                                           'P36', 1,
                                                           'P37', 1,
                                                           'P38', 1,
                                                           'P39', 1))), 0, 'S', 1, 'A'),
                         count(decode(substr(bp.result_code, 1, 1), 'F', 1)),
                         'F', decode(g_partial_resv_flag, 'Y', 'P', 'F'))
     from gl_bc_packets bp
     where bp.packet_id = g_packet_id
     and bp.template_id is null;

    l_ret_code gl_bc_packets.result_code%type;

      -- Bug 5571064 .. Start

      CURSOR c_get_failed_distributions(p_packet_id IN NUMBER) IS
      SELECT distinct bc.source_distribution_id_num_1
      FROM gl_bc_packets bc
      WHERE bc.packet_id = p_packet_id
      AND bc.result_code like 'F%';

      TYPE source_dist_id_num_1_tbl_type IS TABLE OF   gl_bc_packets.source_distribution_id_num_1%type INDEX BY binary_integer;

      l_source_dist_id_num_1_tbl  source_dist_id_num_1_tbl_type;

      -- Bug 5571064 .. End

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

       l_full_path := g_path || 'glxfrc';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFRC - START' );
    -- ========================= FND LOG =============================

    -- Update Result Code for all transactions in Packet
    update gl_bc_packets bp
       set bp.result_code =
           decode(bp.actual_flag || decode(bp.currency_code, g_func_curr_code,
                                           null, '1'), 'B1', 'P03',
             decode(bp.actual_flag || decode(bp.budget_version_id,
                    bp.funding_budget_version_id, null, '1'), 'B1', 'P02',
               decode(bp.funds_check_level_code, 'N', 'P01',
                 decode(bp.effect_on_funds_code, 'I', 'P00',
                   decode(g_fcmode, 'F', 'P05', decode(bp.account_category_code,
                          'P',
                     decode(sign(
                                ((nvl(bp.budget_posted_balance, 0) -
                                  nvl(bp.actual_posted_balance, 0) -
                                  nvl(bp.encumbrance_posted_balance, 0) +
                                  nvl(bp.budget_approved_balance, 0) -
                                  nvl(bp.actual_approved_balance, 0) -
                                  nvl(bp.encumbrance_approved_balance, 0) +
                                  nvl(bp.budget_pending_balance, 0) -
                                  nvl(bp.actual_pending_balance, 0) -
                                  nvl(bp.encumbrance_pending_balance, 0)) -
                                  ((nvl(bp.accounted_dr, 0) -
                                    nvl(bp.accounted_cr, 0)) *
                                    decode(bp.actual_flag, 'B', -1, 1)) +
                                  decode(sign(
                                         (nvl(bp.budget_posted_balance, 0) +
                                          nvl(bp.budget_approved_balance, 0) +
                                          nvl(bp.budget_pending_balance, 0)) *
                                         decode(bp.dr_cr_code, 'D', 1, -1)),
                                         -1, nvl(bp.tolerance_amount, 0),
                                         decode(bp.tolerance_percentage ||
                                         ';' || bp.tolerance_amount, ';', 0,
                                         ';' || bp.tolerance_amount,
                                         bp.tolerance_amount,
                                         bp.tolerance_percentage || ';',
                                         abs(nvl(bp.budget_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) +
                                           nvl(bp.budget_pending_balance, 0)) *
                                         bp.tolerance_percentage/100,
                                         least(
                                         abs(nvl(bp.budget_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) +
                                           nvl(bp.budget_pending_balance, 0)) *
                                           bp.tolerance_percentage/100,
                                           bp.tolerance_amount))) *
                                  decode(bp.dr_cr_code, 'D', 1, -1)) *
                                decode(bp.dr_cr_code, 'D', 1, -1)), 1, 'P10',
                                0, 'P10', decode(bp.funds_check_level_code,
                                                 'D', 'P20',
                                           decode(sign(nvl(bp.template_id,
                                                       -1)), 1, 'F02',
                                            decode(sign(
                                           ((nvl(bp.budget_posted_balance, 0) -
                                             nvl(bp.actual_posted_balance, 0) -
                                        nvl(bp.encumbrance_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) -
                                           nvl(bp.actual_approved_balance, 0) -
                                     nvl(bp.encumbrance_approved_balance, 0)) -
                                    ((nvl(bp.accounted_dr, 0) -
                                      nvl(bp.accounted_cr, 0)) *
                                      decode(bp.actual_flag, 'B', -1, 1)) +
                                    decode(sign(
                                          (nvl(bp.budget_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) +
                                           nvl(bp.budget_pending_balance, 0)) *
                                           decode(bp.dr_cr_code, 'D', 1, -1)),
                                           -1, nvl(bp.tolerance_amount, 0),
                                    decode(bp.tolerance_percentage || ';' ||
                                           bp.tolerance_amount, ';', 0,
                                           ';' || bp.tolerance_amount,
                                           bp.tolerance_amount,
                                           bp.tolerance_percentage || ';',
                                       abs(nvl(bp.budget_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) +
                                           nvl(bp.budget_pending_balance, 0)) *
                                           bp.tolerance_percentage/100,
                                       least(
                                        abs(nvl(bp.budget_posted_balance, 0) +
                                           nvl(bp.budget_approved_balance, 0) +
                                           nvl(bp.budget_pending_balance, 0)) *
                                           bp.tolerance_percentage/100,
                                           bp.tolerance_amount))) *
                                    decode(bp.dr_cr_code, 'D', 1, -1)) *
                                    decode(bp.dr_cr_code, 'D', 1, -1)),
                                    -1, 'F00', 'F03')))),
                          'B',
                     decode(sign(
                                ((nvl(bp.actual_posted_balance, 0) +
                                  nvl(bp.actual_approved_balance, 0) +
                                  nvl(bp.actual_pending_balance, 0)) -
                                ((nvl(bp.accounted_cr, 0) -
                                  nvl(bp.accounted_dr, 0)))) *
                                decode(bp.dr_cr_code, 'D', 1, -1)), 1, 'P15',
                                0, 'P15',
                                 decode(bp.funds_check_level_code, 'D', 'P25',
                                  decode(sign(nvl(bp.template_id, -1)),
                                         1, 'F12',
                                   decode(sign(
                                          ((nvl(bp.actual_posted_balance, 0) +
                                          nvl(bp.actual_approved_balance, 0)) -
                                          ((nvl(bp.accounted_cr, 0) -
                                            nvl(bp.accounted_dr, 0)))) *
                                          decode(bp.dr_cr_code, 'D', 1, -1)),
                                          -1, 'F10', 'F13'))))))))))
     where bp.packet_id = g_packet_id
       and (bp.result_code is null
         or g_fcmode = 'F' );



    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update Result Code gl_bc_packets 1 updated -> ' || SQL%ROWCOUNT || ' rows');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
    -- ========================= FND LOG =============================

    /* -------------------------------------------------------------------+
       | Updating result code to F78 id funds check is failed and absolute|
       | Funds checking is done when there were no Budget Assignment      |
       | Bug 5242198                                                      |
       +-----------------------------------------------------------------*/

    if(nvl(g_enable_efc_flag,'N')='Y') THEN

      UPDATE gl_bc_packets bp
      set result_code='F78'
      WHERE bp.packet_id = g_packet_id
      AND bp.result_code like 'F%'
      AND bp.funding_budget_version_id IS NULL
      AND bp.funds_check_level_code = 'B';

   end if;
    -- If Mode is Force Pass, there is no need for detail/summary and
    -- originating/generated tie back logic

    if g_fcmode = 'F' then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode = F -> goto normal_exit');
       -- ========================= FND LOG =============================
      goto normal_exit;
    end if;


    if g_summarized_flag then

       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_summarized_flag -> TRUE ');
       -- ========================= FND LOG =============================

      -- Update Result Code for Detail Transactions when Summary Transactions
      -- fail Funds Check and Checking is Absolute

      update gl_bc_packets bp
         set bp.result_code =
             decode(bp.account_category_code || substr(bp.result_code, 1, 1),
                    'PP', 'F01', 'PF', 'F04', 'BP', 'F11', 'BF', 'F14')
       where bp.packet_id = g_packet_id
         and bp.template_id is null
         and (bp.result_code like 'P%'
           or bp.result_code in ('F00', 'F03', 'F10', 'F13'))
         and exists
            (
             select

                    'Summary Row exists and fails Funds Check; Absolute'
               from gl_bc_packets pk,
                    gl_account_hierarchies ah
              where ah.ledger_id = bp.ledger_id
                and ah.summary_code_combination_id = pk.code_combination_id
                and ah.detail_code_combination_id = bp.code_combination_id
                and pk.packet_id = bp.packet_id
                and pk.actual_flag = bp.actual_flag
                and pk.period_name = bp.period_name
                and pk.je_source_name = bp.je_source_name
                and pk.je_category_name = bp.je_category_name
                and (pk.budget_version_id is null
                  or pk.budget_version_id = bp.budget_version_id)
                and pk.account_category_code = bp.account_category_code
                and pk.funds_check_level_code = 'B'
                and pk.result_code in ('F02', 'F12')
            );

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 2 updated -> ' || SQL%ROWCOUNT || ' rows');
      -- ========================= FND LOG =============================

      -- Update Result Code for Detail Transactions when Summary Transactions
      -- fail Funds Check and Checking is Advisory

      update gl_bc_packets bp
         set bp.result_code =
             decode(bp.account_category_code, 'P', 'P22', 'B', 'P27')
       where bp.packet_id = g_packet_id
         and bp.template_id is null
         and bp.result_code like 'P%'
         and exists
            (
             select

                    'Summary Row exists and fails Funds Check; Advisory'
               from gl_account_hierarchies ah,
                    gl_bc_packets pk
              where ah.ledger_id = bp.ledger_id
                and ah.summary_code_combination_id = pk.code_combination_id
                and ah.detail_code_combination_id = bp.code_combination_id
                and pk.packet_id = bp.packet_id
                and pk.actual_flag = bp.actual_flag
                and pk.period_name = bp.period_name
                and pk.je_source_name = bp.je_source_name
                and pk.je_category_name = bp.je_category_name
                and (pk.budget_version_id is null
                  or pk.budget_version_id = bp.budget_version_id)
                and pk.account_category_code = bp.account_category_code
                and pk.funds_check_level_code = 'D'
                and pk.result_code in ('P20', 'P25')
            );

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 3 updated -> ' || SQL%ROWCOUNT || ' rows');
      -- ========================= FND LOG =============================

    end if;


    -- Update Result Code of Original Proprietary Transaction when one or
    -- more of the associated Generated Transactions fail Funds Check and
    -- vice versa

    if g_ussgl_option_flag then

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ussgl_option_flag -> TRUE');
      -- ========================= FND LOG =============================

      update gl_bc_packets bp
         set bp.result_code =
             decode(bp.ussgl_transaction_code, null,
                    decode(bp.account_category_code, 'P', 'F06', 'B', 'F15'),
                    'F05')
       where bp.packet_id = g_packet_id
         and bp.template_id is null
         and bp.result_code like 'P%'
         and (bp.ussgl_transaction_code is not null
           or bp.ussgl_link_to_parent_id is not null)
         and exists
             (
              select 'One or more Proprietary/Budgetary counterparts of ' ||
                     'this transaction exists and fails Funds Check'
                from gl_bc_packets pk
               where pk.packet_id = g_packet_id
                 and pk.template_id is null
                 and pk.result_code like 'F%'
                 and (pk.ussgl_parent_id = bp.ussgl_link_to_parent_id
                   or pk.ussgl_link_to_parent_id in (bp.ussgl_link_to_parent_id, bp.ussgl_parent_id))
             );

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 4 updated -> ' || SQL%ROWCOUNT || ' rows');
      -- ========================= FND LOG =============================

    end if;

    -- New logic added here for sub-ledger teams to populate full set of
    -- result codes. This is applicable to GL only if called from a
    -- concurrent program because in case of concurrent program the override
    -- functionality will be disabled even for GL.

    IF g_calling_prog_flag = 'S' OR g_conc_flag THEN

        IF g_override_flag THEN

            if not glxfor then
            -- =========================== FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfor --> RETURN FALSE -> goto fatal_error');
             -- ========================= FND LOG =============================
                return false;
              end if;
          END IF;

        open retcode;
        fetch retcode into l_ret_code;
        close retcode;

        if ((g_fcmode in ('R', 'U', 'A')) and
            (g_summarized_flag) and
            (l_ret_code in ('S', 'A'))) then

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' inside Ist IF ');
        -- ========================= FND LOG ===========================

          update gl_bc_packets bp
             set bp.result_code = 'P23'
             where bp.packet_id = g_packet_id
             and bp.result_code like 'F%'
             and bp.template_id is not null;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 5 updated -> ' || SQL%ROWCOUNT || ' rows');
        -- ========================= FND LOG ===========================

         end if;

           update gl_bc_packets bp
           set bp.status_code = decode(bp.status_code || l_ret_code,
                                       'PF', 'R',
                                          'CF', 'F',
                                           decode(bp.status_code || substr(bp.result_code, 1, 1),
                                                   'PF', 'R',
                                                'CF', 'F',
                                                bp.status_code)
                                    ),
              bp.last_update_date = sysdate
            where bp.packet_id = g_packet_id;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 6 updated -> ' || SQL%ROWCOUNT || ' rows');
        -- ========================= FND LOG ===========================

    END IF;

    -- Update all lines to failure in same packet and same distribution if any other line fails.
    -- Bug 5250753
    -- Bug 5571064

       OPEN c_get_failed_distributions (g_packet_id);
       FETCH c_get_failed_distributions  bulk collect into l_source_dist_id_num_1_tbl;

       FORALL I IN 1..l_source_dist_id_num_1_tbl.count
              UPDATE gl_bc_packets pk
                SET result_code ='F77'
                WHERE pk.packet_id = g_packet_id
                  AND pk.source_distribution_id_num_1 = l_source_dist_id_num_1_tbl(I)
                  AND pk.result_code like 'P%';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_bc_packets 6.1, result_code to F77 for same packet and same distribution updated -> ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG ===========================

      CLOSE  c_get_failed_distributions;

    -- Bug 3553142
    -- If there is an advisory warning on any row in gl_bc_packets, all passed rows should indicate
    -- that one or more related lines have advisory warnings.
    -- Created 2 new LOOKUP_CODEs P12, P17

    UPDATE gl_bc_packets pk
    SET result_code = 'P12'
    WHERE pk.packet_id = g_packet_id
      AND result_code = 'P10'
      AND exists (SELECT 'x'
                  FROM gl_bc_packets bc
                  WHERE bc.packet_id = pk.packet_id
                    AND bc.result_code = 'P20');

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 7 updated -> ' || SQL%ROWCOUNT || ' rows');
   -- ========================= FND LOG ===========================


    UPDATE gl_bc_packets pk
    SET result_code = 'P17'
    WHERE pk.packet_id = g_packet_id
      AND result_code = 'P15'
      AND exists (SELECT 'x'
                  FROM gl_bc_packets bc
                  WHERE bc.packet_id = pk.packet_id
                    AND bc.result_code = 'P25');

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets 8 updated -> ' || SQL%ROWCOUNT || ' rows');
   -- ========================= FND LOG ===========================


   -- =========================== FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
   -- ========================= FND LOG =============================

    return(TRUE);

    <<normal_exit>>
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' Reached label normal exit');
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
      -- ========================= FND LOG =============================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
      -- ========================= FND LOG =============================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE');
      -- ========================= FND LOG =============================
      g_debug := g_debug||' GLXFRC Failed : '||SQLERRM;
      return(FALSE);

  END glxfrc;

  /* ============================= GLZCBC =============================== */

  FUNCTION glzcbc RETURN NUMBER IS

     cbc_fck_stmt  VARCHAR2(2000);
     p_ledger_id   NUMBER(15);
     p_packet_id   NUMBER(15);
     p_conc_proc   VARCHAR2(1);
     p_mode        VARCHAR2(1);
     cbc_code      NUMBER(15);

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

       p_conc_proc    := 'F';
       l_full_path     := g_path || 'glzcbc.';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLZCBC - START' );
    -- ========================= FND LOG =============================

     cbc_fck_stmt :=
       'BEGIN  :ret_code := IGC_CBC_GL_FC_PKG.glzcbc(:packet_id,p_ledger_id,:mode,:conc_proc); END;';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' cbc_fck_stmt -> ' || cbc_fck_stmt );
    -- ========================= FND LOG =============================

     -- Assign parameter values before calling IGC

     p_ledger_id    := g_ledger_id;
     p_packet_id := g_packet_id;
     p_mode      := g_fcmode;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ledger_id    -> ' || g_ledger_id );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id -> ' || g_packet_id );
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode    -> ' || g_fcmode );
    -- ========================= FND LOG =============================

     execute immediate cbc_fck_stmt
       USING IN OUT cbc_code,IN p_packet_id,IN p_ledger_id,IN p_mode,IN p_conc_proc;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN cbc_code -> ' || cbc_code );
    -- ========================= FND LOG =============================

     RETURN cbc_code;

  EXCEPTION
     WHEN OTHERS THEN

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN  -> 1' );
    -- ========================= FND LOG =============================

        RETURN 1;

  END glzcbc;

  /* ================================ GLZGCHK ========================== */

  -- Callout to Grants Funds Check extension.  The resulting Return Code
  -- is returned back through an out parameter.  Any error in processing
  -- results in a return value from the function of FALSE.

  FUNCTION glzgchk RETURN BOOLEAN IS

  gms_stmt VARCHAR2(400);

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

       l_full_path := g_path || 'glzgchk';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLZGCHK - START' );
    -- ========================= FND LOG =============================

    gms_stmt :=
      'BEGIN '||
      ' GMS_UTILITY.GMS_UTIL_PC_FCK('||
         ':g_ledger_id, :g_packet_id, :g_fcmode, '||
     '''N'', :g_partial_resv_flag, '||
     'FND_GLOBAL.USER_ID, FND_GLOBAL.RESP_ID, '||
     '''N'', :gms_retcode); '||
      'END;';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' gms_stmt -> ' || gms_stmt );
    -- ========================= FND LOG =============================

    execute immediate gms_stmt using g_ledger_id, g_packet_id, g_fcmode,
        g_partial_resv_flag, in out gms_retcode;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' gms_retcode -> ' || gms_retcode );
    -- ========================= FND LOG =============================

    IF NOT gms_retcode = '~'
    AND gms_retcode IS NOT NULL THEN
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE' );
      -- ========================= FND LOG =============================
      RETURN(TRUE);
    END IF;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE' );
    -- ========================= FND LOG =============================
    RETURN(FALSE);

  EXCEPTION

    WHEN OTHERS THEN

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHER '|| SQLERRM );
    -- ========================= FND LOG =============================

      /* Even when an SQL exception is raised, if the gms_retcode */
      /* has been set, indicate that processing has completed.    */
      /* This ensures that any cleanup that needs to be done by   */
      /* the GMS_RETURN_CODE processor is at least attempted.     */

      IF NOT gms_retcode = '~'
      AND gms_retcode IS NOT NULL THEN
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> TRUE' );
        -- ========================= FND LOG =============================
    RETURN(TRUE);
      ELSE
        -- =========================== FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE' );
        -- ========================= FND LOG =============================
        RETURN(FALSE);
      END IF;

  END glzgchk;

  /* ================================ GLZPAFCK =========================== */

  -- Callout to Projects Funds Check extension.  The resulting Return Code
  -- is returned back through an out parameter.  Any error in processing
  -- results in a return value from the function of FALSE.

  FUNCTION glzpafck RETURN BOOLEAN IS

  pa_stmt VARCHAR2(400);
  cur_pa  INTEGER;
  ignore  INTEGER;

  pa_retcode   gl_bc_packets.result_code%TYPE;
  err_msg VARCHAR2(1024);
  err_stg VARCHAR2(1024);

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================
  BEGIN

        l_full_path  := g_path || 'glzpafck.';

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path, ' GLZPAFCK --> START ');
     -- ========================= FND LOG ===========================

    pa_stmt :=
      'BEGIN '||
      ' PA_FUNDS_CONTROL_PKG.PA_FUNDS_CHECK(:gl_var, :g_ledger_id_var, :g_packet_id_var, '||
      ':g_fcmode_var, :g_partial_resv_flag_var, NULL, NULL,:pa_retcode, :err_msg, :err_stg); '||
      'END;';

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level,l_full_path, ' pa_stmt -> ' || pa_stmt);
     -- ========================= FND LOG ===========================

      EXECUTE IMMEDIATE pa_stmt USING 'GL', g_ledger_id, g_packet_id, g_fcmode,
                                        g_partial_resv_flag, OUT pa_retcode,
                                        OUT err_msg, OUT err_stg;

      IF err_msg IS NOT NULL THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' pa_retcode -> ' || pa_retcode);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' err_msg    -> ' || err_msg);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' err_stg    -> ' || err_stg);
         -- ========================= FND LOG ===========================
      END IF;

      IF (pa_retcode IS NULL) OR (pa_retcode = 'T') THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
         -- ========================= FND LOG ===========================
         g_debug := g_debug||' GLZPAFCK Failed : (PA_RETCODE IS NULL OR PA_RETCODE = T)';
         RETURN(FALSE);
      END IF;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
      -- ========================= FND LOG ===========================

      RETURN(TRUE);

  EXCEPTION

    WHEN OTHERS THEN
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ');
       -- ========================= FND LOG ===========================

      /* Even when an SQL exception is raised, if the pa_retcode */
      /* has been set, indicate that processing has completed.    */

      IF pa_retcode = 'T' THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
         -- ========================= FND LOG ===========================
         g_debug := g_debug||' GLZPAFCK Failed : PA_RETCODE = T';
         RETURN(FALSE);
      END IF;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
      -- ========================= FND LOG ===========================

      RETURN(TRUE);

  END glzpafck;

  /* =========================== GLXFOR =================================== */

  -- Update the Result Codes for all Detail Transactions to 'P21' and the
  -- corresponding Generated Transactions to 'P26', if the Transaction Amount
  -- is less than or equal to the Override Amount for the Detail Transaction;
  -- Result Codes for Summary Transactions are updated in glxfrs()

  FUNCTION glxfor RETURN BOOLEAN IS
     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================
  BEGIN

          l_full_path := g_path || 'glxfor';

     -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_state_level, l_full_path, ' GLXFOR --> START ');
     -- ========================= FND LOG ===========================

    -- Update Result Code for Detail Transactions

    update gl_bc_packets bp
       set bp.result_code = 'P21'
     where bp.packet_id = g_packet_id
       and bp.result_code between 'F00' and 'F19'
       and bp.ussgl_link_to_parent_id is null
       and bp.template_id is null
       and nvl(bp.override_amount, -1) >=
           abs(nvl(bp.accounted_dr, 0) - nvl(bp.accounted_cr, 0))
       and not exists
          (
           select 'If Partial Resv disallowed then all non-generated ' ||
                  'detail lines that failed with any validation errors ' ||
                  'or because of Funds Availability'
             from gl_bc_packets pk
            where pk.packet_id = g_packet_id
              and pk.template_id is null
              and pk.result_code like 'F%'
              and ((g_partial_resv_flag = 'N'
                and pk.ussgl_link_to_parent_id is null
                and (pk.result_code between 'F20' and 'F29'
                  or nvl(pk.override_amount, -1) <
                     abs(nvl(pk.accounted_dr, 0) - nvl(pk.accounted_cr, 0))))
                 or (pk.ussgl_link_to_parent_id = bp.ussgl_parent_id
                 and pk.result_code between 'F20' and 'F29'))
          );

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets1 -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_calling_prog_flag -> ' || g_calling_prog_flag);
    -- ========================= FND LOG ===========================


    IF (g_calling_prog_flag = 'G') THEN

        -- Update Result Code for Generated Transactions

        update gl_bc_packets bp
           set bp.result_code = 'P26'
         where bp.packet_id = g_packet_id
           and bp.result_code between 'F00' and 'F19'
           and bp.ussgl_link_to_parent_id is not null
           and exists
              (
               select 'Corresp Original Transaction which was Overridden'
                 from gl_bc_packets pk
                where pk.packet_id = g_packet_id
                  and pk.ussgl_parent_id = bp.ussgl_link_to_parent_id
                  and pk.result_code = 'P21'
              );

    END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update gl_bc_packets2 -> ' || SQL%ROWCOUNT);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
    -- ========================= FND LOG ===========================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path, ' WHEN OTHERS EXCEPTION ' || SQLERRM);
         -- ========================= FND LOG ===========================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
         -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXFOR Failed : '||SQLERRM;
      return(FALSE);

  END glxfor;

/* ================================= GLXFRS ============================ */

  -- Get Return Status

  -- Return Code can be of one of the following values :
  --
  --     Code  Meaning   Description
  --     ----  -------   ----------------------------------------
  --      S    Success   All transactions in packet pass Funds
  --                     Check or Funds Reservation
  --
  --      A    Advisory  All transactions in packet pass Funds
  --                     Check or Funds Reservation; but some
  --                     with Advisory warnings
  --
  --      F    Failure   All transactions in packet fail Funds
  --                     Check or Funds Reservation (partial
  --                     reservation allowed)
  --                     OR
  --                     One or more transactions in packet fail
  --                     Funds Check or Funds Reservation
  --                     (partial reservation not allowed)
  --
  --      P    Partial   Only part of the transactions in packet
  --                     pass Funds Check or Funds Reservation
  --                     (partial reservation allowed only)
  --
  --      T    Fatal     Irrecoverable error detected that
  --                     prevents funds check or reservation
  --                     from proceeding
  --
  --   Decode count fragments :
  --   ------------------------
  --     count(*)
  --      - Total Number of Detail Transactions in packet
  --
  --     count(decode(substr(BP.result_code, 1, 1), 'P', 1))
  --      - Total Number of Detail Transactions with a pass Result Code
  --
  --     count(decode(BP.result_code,
  --       'P20', 1, 'P22', 1, 'P25', 1, 'P27', 1))
  --      - Total Number of Detail Transactions that pass with Advisory warnings
  --
  --     count(decode(substr(BP.result_code, 1, 1), 'F', 1))
  --      - Total Number of Detail Transactions with a fail Result Code

  FUNCTION glxfrs RETURN BOOLEAN IS

    cursor retcode is
      select decode(count(*),
                    count(decode(substr(bp.result_code, 1, 1), 'P', 1)),
                    decode(sign(count(decode(bp.result_code,
                                             'P20', 1,
                                             'P22', 1,
                                             'P25', 1,
                                             'P27', 1,
                                             'P31', 1,
                                             'P35', 1,
                                             'P36', 1,
                                             'P37', 1,
                                             'P38', 1,
                                             'P39', 1))), 0, 'S', 1, 'A'),
                           count(decode(substr(bp.result_code, 1, 1), 'F', 1)),
                           'F', decode(g_partial_resv_flag, 'Y', 'P', 'F'))
       from gl_bc_packets bp
       where bp.packet_id = g_packet_id
       and bp.template_id is null;

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

  BEGIN

          l_full_path := g_path || 'glxfrs';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFRS --> START ');
    -- ========================= FND LOG ===========================

    -- Return Code for the Packet

    open  retcode;
    fetch retcode  into g_return_code;
    close retcode;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code --> ' || g_return_code);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glrchk ');
    -- ========================= FND LOG ===========================

    if not glrchk(g_return_code) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glrchk --> FALSE ');
       -- ========================= FND LOG ===========================
      return(FALSE);
    end if;

    -- Update Status Code and Last Update Date for all transactions

    -- Status Codes for Funds Reservation / Check :
    --
    --  (I) For return codes S(Success), A(Advisory) or F(Failure) :
    --
    --   Process      Original Status  Return Code  Status Code
    --   -----------  ---------------  -----------  ---------------
    --   Reservation    P (Pending)    S (Success)  A (Approved)
    --   Reservation    P (Pending)    A (Advisory) A (Approved)
    --   Reservation    P (Pending)    F (Failure)  R (Rejected)
    --   Checking       C (Checking)   S (Success)  S (Passed Check)
    --   Checking       C (Checking)   A (Advisory) S (Passed Check)
    --   Checking       C (Checking)   F (Failure)  F (Failed Check)
    --
    --  NOTE: When Partial Reservation is not allowed, all transactions
    --        in a packet are updated to the same Status Code.
    --        e.g individual lines with Pxx result codes within a
    --        Failure packet get R (Rejected) Status Codes
    --
    --  (II) For return code P(Partial) :
    --
    --   Process      Original Status  Result Code  Status Code
    --   -----------  ---------------  -----------  ---------------
    --   Reservation    P (Pending)        Pxx      A (Approved)
    --   Reservation    P (Pending)        Fxx      R (Rejected)
    --   Checking       C (Checking)       Pxx      S (Passed Check)
    --   Checking       C (Checking)       Fxx      F (Failed Check)

    if g_calling_prog_flag = 'G' then
        update gl_bc_packets bp
           set bp.status_code = decode(bp.status_code || g_return_code, 'PS', 'A',
                                       'PA', 'A', 'PF', 'R', 'CS', 'S', 'CA', 'S',
                                       'CF', 'F',
                                       decode(bp.status_code ||
                                       substr(bp.result_code, 1, 1), 'PP', 'A',
                                       'PF', 'R', 'CP', 'S', 'CF', 'F', 'T')),
               bp.last_update_date = sysdate
         where bp.packet_id = g_packet_id;
    else
        update gl_bc_packets bp
           set bp.status_code = decode(bp.status_code || g_return_code, 'PS', 'A',
                                       'PA', 'A', 'PF', 'R', 'CS', 'S', 'CA', 'S',
                                       'CF', 'F',
                                       decode(bp.status_code ||
                                       substr(bp.result_code, 1, 1), 'PP', 'A',
                                       'PF', 'R', 'CP', 'S', 'CF', 'F',
                                               decode(bp.status_code, 'F', 'F', 'R', 'R', 'T'))),
               bp.last_update_date = sysdate
         where bp.packet_id = g_packet_id;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets --> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Update the Result Code of all Summary Transactions that fail Funds
    -- Reservation to 'P23', when each of their corresponding details got
    -- overridden in glxfor().  This Module executes this SQL only if
    -- all details in the packet PASS Funds (UN)RESERVATION, i.e. Return
    -- Code is 'S' (Success) or 'A' (Advisory); with at least one Summary
    -- Transaction present
    --
    --    Code  Explanation
    --    ----  --------------------------------------------------------
    --    P23   This summary account fails funds check; you overrode
    --          the detail(s)
    --

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode          --> ' || g_fcmode);
       IF (g_summarized_flag) THEN
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_summarized_flag --> TRUE ');
       ELSE
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_summarized_flag --> FALSE ');
       END IF;
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code     --> ' || g_return_code);
    -- ========================= FND LOG ===========================

    if ((g_fcmode in ('R', 'U', 'A')) and
        (g_summarized_flag) and
        (g_return_code in ('S', 'A'))) then

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' inside Ist IF ');
    -- ========================= FND LOG ===========================

      update gl_bc_packets bp
         set bp.result_code = 'P23'
       where bp.packet_id = g_packet_id
         and bp.result_code like 'F%'
         and bp.template_id is not null;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets --> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    end if;


    -- Resummarize Amounts for all Summary Transactions if the Return Code is
    -- Partial and Mode is Reservation

    -- This is necessary for partially reserved packets since for all approved
    -- Summary Transactions, the corresponding Detail Transactions may be
    -- rejected and the over-accounted Summary Amounts would affect Funds
    -- Check and/or Reservation for packets arriving later

    -- e.g : Detail Transactions D1 and D2 roll up to the same Summary
    --       Transaction S1
    --
    --       D1:   $10    (Approved)
    --       D2:   $20    (Rejected)
    --       -----------------------
    --       S1:   $30    (Approved)
    --
    --       However, since only $10 of D1 is actually approved but not the
    --       $20 of D2, we should update the amount approved in S1 to $10
    --
    -- This SQL also resummarizes for any Rejected Summary Transaction where one
    -- of more of its corresponding Details were Overridden in glxfor().
    -- In this case, it also updates the Status Code and Result Code of
    -- these Summary Transactions to 'A' (Approved) and 'P23' respectively
    --
    -- Note: If the subquery of the correlated update returns no row, the
    --       default action (thru' the nvls) will update all the columns
    --       back to their original values

    if ((g_fcmode in ('R', 'A', 'U')) and
        (g_summarized_flag) and
        (g_return_code = 'P')) then
    begin

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' inside IInd IF ');
    -- ========================= FND LOG ===========================

      update gl_bc_packets bp
         set (bp.entered_dr,
              bp.entered_cr,
              bp.accounted_dr,
              bp.accounted_cr,
              bp.status_code,
              bp.result_code) =
             (
              select nvl(sum(nvl(pk.entered_dr, 0)), bp.entered_dr),
                     nvl(sum(nvl(pk.entered_cr, 0)), bp.entered_cr),
                     nvl(sum(nvl(pk.accounted_dr, 0)), bp.accounted_dr),
                     nvl(sum(nvl(pk.accounted_cr, 0)), bp.accounted_cr),
                     nvl(max(pk.status_code), 'R'),
                     decode(max(pk.status_code), null, bp.result_code,
                            decode(bp.status_code, 'A', bp.result_code, 'P23'))
                from gl_account_hierarchies ah,
                     gl_bc_packets pk
               where ah.ledger_id = g_ledger_id
                 and ah.template_id = bp.template_id
                 and ah.summary_code_combination_id = bp.code_combination_id
                 and ah.detail_code_combination_id = pk.code_combination_id
                 and pk.packet_id = g_packet_id
                 and pk.status_code = 'A'
                 and pk.template_id is null
                 and pk.actual_flag = bp.actual_flag
                 and pk.period_name = bp.period_name
                 and pk.currency_code = bp.currency_code
                 and pk.je_source_name = bp.je_source_name
                 and pk.je_category_name = bp.je_category_name
                 and (pk.budget_version_id is null
                   or pk.budget_version_id = bp.budget_version_id)
                 and pk.account_category_code = bp.account_category_code
             )
       where bp.packet_id = g_packet_id
         and bp.template_id is not null;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' update gl_bc_packets --> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    end;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' calling glxfar ');
    -- ========================= FND LOG ===========================

    if not glxfar then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
    -- ========================= FND LOG ===========================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN

      if retcode%ISOPEN then
        close retcode;
      end if;

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEOPTION WHEN OTHERS '|| SQLERRM);
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN --> FALSE ');
    -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXFRS Failed : '||SQLERRM;
      return(FALSE);

  END glxfrs;

  /* ================================= GLRCHK ======================== */

  --
  -- Provide callout to reconcile Return Status and Posting results.
  --
  -- After computation of the General Ledger Funds Check overall status is
  -- completed within glxfrs(), other parties (Grants) need to have an
  -- opportunity to reconcile the status with their own computation.
  -- Additionally, other parties need confirmation that all Funds Check
  -- work is completed (to reflect this within their own systems) or that
  -- a Fatal Error has occurred.
  --
  -- glrchk() provides this centralize place to callout to these other parties.
  --
  -- Bug 2184578
  -- If Standard Budgetary Control failed, CBC Journals shoud not be committed.
  -- This is achieved by calling function IGC_CBC_GL_FC_PKG.reconcile_glzcbc
  --

  FUNCTION glrchk(post_control IN gl_bc_packets.result_code%TYPE)
  RETURN BOOLEAN IS

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

  BEGIN
          l_full_path  := g_path || 'glrchk.';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' glrchk --> START ');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' post_control --> ' || post_control);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_retcode --> ' || g_cbc_retcode);
    -- ========================= FND LOG ===========================

    /*========================+
     |    CBC Reconcile          |
     +========================*/

   -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_cbc_retcode-> '||g_cbc_retcode);
   -- ========================= FND LOG ===========================


    IF g_cbc_retcode = 1 then
       -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling CBC Reconcile ');
       -- ========================= FND LOG ===========================

       DECLARE
            cbc_recon_stmt VARCHAR2(2000);
             cbc_recon_code NUMBER(15);

       BEGIN
             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' GLRCHK(CBCRECONCILE) --> START ');
             -- ========================= FND LOG ===========================

             cbc_recon_stmt :=
                   'BEGIN  :ret_code := IGC_CBC_GL_FC_PKG.reconcile_glzcbc(:packet_id,:sob_id,:mode); END;';

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' cbc_recon_stmt --> ' || cbc_recon_stmt);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' g_ledger_id    --> ' || g_ledger_id);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' g_packet_id --> ' || g_packet_id);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' g_mode      --> ' || g_fcmode);
             -- ========================= FND LOG ===========================

             execute immediate cbc_recon_stmt
                   USING IN OUT cbc_recon_code,IN g_packet_id,IN g_ledger_id,IN g_fcmode;

            -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN cbc_recon_code --> ' || cbc_recon_code);
             -- ========================= FND LOG ===========================

            IF cbc_recon_code = -1 THEN
                g_debug := g_debug||' GLRCHK Failed : CBC_RECONC_CODE = -1';
                return false;
            END IF;

       EXCEPTION
          WHEN OTHERS THEN
             NULL;

       END;

    END IF;

    -- ========================= FND LOG ===========================
       IF (g_psa_grantcheck) THEN
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_grantcheck --> TRUE ');
       ELSE
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_grantcheck --> FALSE ');
       END IF;
    -- ========================= FND LOG ===========================

    /*========================+
     |    GMS Reconcile          |
     +========================*/

    IF g_psa_grantcheck THEN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling GMS Reconcile ');
       -- ========================= FND LOG ===========================

       DECLARE

            gms_stmt VARCHAR2(400);
              gl_retcode   gl_bc_packets.result_code%TYPE;
              gms_control  gl_bc_packets.result_code%TYPE;

         BEGIN
             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' GLRCHK(GMS Reconcile) --> START ');
                psa_utils.debug_other_string(g_state_level,l_full_path, ' post_control -> ' || post_control);
             -- ========================= FND LOG ===========================

            IF post_control = 'X' OR post_control = 'Z' THEN
                  gl_retcode  := g_return_code;
                  gms_control := post_control;
            ELSE
                  gl_retcode  := post_control;
                  gms_control := gms_retcode;
            END IF;

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' gl_retcode -> ' || gl_retcode);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' gms_control -> ' || gms_control);
             -- ========================= FND LOG ===========================

            gms_stmt :=
                  'BEGIN '||
                  ' GMS_UTILITY.GMS_UTIL_GL_RETURN_CODE(:g_packet_id, :g_fcmode, '||
                 ':gl_retcode, :gms_control, :g_partial_resv_flag); '||
                  'END;';

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' gms_stmt -> ' || gms_stmt);
             -- ========================= FND LOG ===========================

            execute immediate gms_stmt using g_packet_id, g_fcmode, in out gl_retcode,
                gms_control, g_partial_resv_flag;

            -- Given that the resulting return code makes sense, replace the
            -- context's return code with it.

            IF gl_retcode IS NOT NULL AND gl_retcode <> 'Z' THEN

              -- ========================= FND LOG ===========================
                 psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code -> ' || g_return_code);
                 psa_utils.debug_other_string(g_state_level,l_full_path, ' Goto -> GMS_RECONCILE_EXIT (Normal) ');
              -- ========================= FND LOG ===========================

                  g_return_code := gl_retcode;
                  goto gms_reconcile_exit;

            END IF;

            -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
            -- ========================= FND LOG ===========================
            g_debug := g_debug||' GLRCHK Failed';
            RETURN(FALSE);

      <<GMS_RECONCILE_EXIT>>
              null;
      EXCEPTION

        WHEN OTHERS THEN

              -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
                   psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
            -- ========================= FND LOG ===========================
            g_debug := g_debug||' GLRCHK Failed : '||SQLERRM;
              RETURN(FALSE);
      END;

    END IF;

    -- ========================= FND LOG ===========================
       IF (g_psa_pacheck) THEN
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_pacheck --> TRUE ');
       ELSE
           psa_utils.debug_other_string(g_state_level,l_full_path, ' g_psa_pacheck --> FALSE ');
       END IF;
    -- ========================= FND LOG ===========================

    /*========================+
     |    PA Reconcile          |
     +========================*/

    IF (g_psa_pacheck) AND (post_control = 'X') THEN
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' calling glzpacfm ');
       -- ========================= FND LOG ===========================

       DECLARE

            pa_stmt VARCHAR2(400);
              err_stg VARCHAR2(1024);

         BEGIN
             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' GLRCHK(GLZPAFCM) --> START ');
             -- ========================= FND LOG ===========================

            pa_stmt :=
              'BEGIN '||
              ' PA_FUNDS_CONTROL_PKG.PA_GL_CBC_CONFIRMATION(:gl_var, :g_packet_id_var, '||
              ':g_fcmode_var, :g_partial_resv_flag_var, NULL, NULL,:gl_retcode, :err_stg); '||
              'END;';

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' pa_stmt -> ' || pa_stmt);
             -- ========================= FND LOG ===========================

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
             -- ========================= FND LOG ===========================

             IF g_fcmode = 'U' THEN
                 EXECUTE IMMEDIATE pa_stmt USING 'GL', g_packet_id_ursvd, g_fcmode,
                     g_partial_resv_flag, IN OUT g_return_code, OUT err_stg;
             ELSE
                 EXECUTE IMMEDIATE pa_stmt USING 'GL', g_packet_id, g_fcmode,
                     g_partial_resv_flag, IN OUT g_return_code, OUT err_stg;
             END IF;

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code -> ' || g_return_code);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' err_stg -> ' || err_stg);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE');
             -- ========================= FND LOG ===========================

          EXCEPTION

            WHEN OTHERS THEN

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_excep_level,l_full_path, ' WHEN OTHERS EXCEPTION' );
             -- ========================= FND LOG ===========================

            /* Even when an SQL exception is raised, if the pa_retcode */
              /* has been set, indicate that processing has completed.   */

             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> TRUE ');
             -- ========================= FND LOG ===========================

        END;

    END IF;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
    -- ========================= FND LOG ===========================

    RETURN(TRUE);

  END glrchk;

  /* ================================ GLXFJE =========================== */

  -- Process Journal Entries
  -- If the Originating Batch is Actual, the associated generated Journal Lines
  -- are appended/deleted to/from the corresponding headers of the Batch; the
  -- Control and Running Totals of the Headers and the Batch are also updated
  -- If the Originating Batch is Encumbrance or Budget, a separate Actual Batch
  -- is created/deleted for the associated generated Journal Lines
  -- Assumption :
  --
  -- This Module assumes that the packet being processed only includes
  -- Transactions from 1 single GL Journal Batch for performance reasons.
  -- This is how we populate gl_bc_packets currently in all GL Implementations

  FUNCTION glxfje RETURN BOOLEAN IS

    l_je_batch_id   gl_bc_packets.je_batch_id%TYPE;
    l_gen_batch_id  gl_bc_packets.je_batch_id%TYPE;
    l_actual_flag   gl_bc_packets.actual_flag%TYPE;
    l_max_je_line_num gl_bc_packets.je_line_num%TYPE; -- bug 5139224


    cursor orig_bat is
      select max(bp.je_batch_id),
             max(bp.actual_flag),
             max(bp.je_line_num) -- bug 5139224
        from gl_bc_packets bp
       where bp.packet_id = g_packet_id
         and bp.template_id is null
         and bp.ussgl_link_to_parent_id is null;

    cursor generated_bat is
       select distinct bp.je_batch_id
       from gl_bc_packets bp
       where bp.packet_id = g_packet_id
         and bp.ussgl_link_to_parent_id is not null;

    cursor batch_id is
      select gl_je_batches_s.nextval
        from dual;

    cursor enable_approval is
       SELECT enable_je_approval_flag
         FROM gl_ledgers_public_v
        WHERE ledger_id = g_ledger_id;

    cursor je_source(c_orig_batch_id IN NUMBER) is
        SELECT JH.je_source je_source
          FROM GL_JE_HEADERS JH
         WHERE JH.je_header_id =
                (SELECT  min(JH1.je_header_id)
                   FROM  GL_JE_HEADERS JH1
                  WHERE  JH1.je_batch_id = c_orig_batch_id);

    cursor je_approval (c_je_source IN VARCHAR2) is
            SELECT journal_approval_flag
              FROM GL_JE_SOURCES
             WHERE je_source_name = c_je_source;

    cursor avoid_copy_dff_attr is
            SELECT 'Y'
              FROM FND_DESCRIPTIVE_FLEXS FD
             WHERE application_id = 101
               and descriptive_flexfield_name = 'GL_JE_LINES'
               and context_user_override_flag = 'N'
               and (UPPER(default_context_field_name) IN ('CONTEXT3', 'ACCOUNT_NUM'));


    l_je_source             je_source%rowtype;
    l_enable_app            enable_approval%rowtype;
    l_je_approval           je_approval%rowtype;
    l_approval_status_code  gl_je_batches.approval_status_code%type;
    l_reversal_method       VARCHAR2(1);
    l_seg_val_ret_code      NUMBER;
    l_avoid_copying_attr    VARCHAR2(1);

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

  BEGIN

        l_full_path := g_path || 'glxfje';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFJE --> START ');
    -- ========================= FND LOG ===========================

    -- Get Originating Batch ID and Actual Flag
    open orig_bat;
    fetch orig_bat into l_je_batch_id, l_actual_flag, l_max_je_line_num;
    close orig_bat;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_je_batch_id -> ' || l_je_batch_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_actual_flag -> ' || l_actual_flag);
    -- ========================= FND LOG ===========================

    -- Check whether we should avoid copying DFF information
    open avoid_copy_dff_attr;
    fetch avoid_copy_dff_attr into l_avoid_copying_attr;
    if (avoid_copy_dff_attr%notfound) then
       l_avoid_copying_attr := 'N';
    end if;
    close avoid_copy_dff_attr;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_avoid_copying_attr -> ' || l_avoid_copying_attr);
    -- ========================= FND LOG ===========================

    -- Create/Delete separate Actual Batch for the generated transactions
    -- if the Originating Batch is Budget/Encumbrance; else, append/delete
    -- the generated transactions to/from the Originating Actual Batch

    if l_actual_flag <> 'A' then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
       -- ========================= FND LOG ===========================

      if g_fcmode = 'U' then
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' goto delete_separate_batch label ');
        -- ========================= FND LOG ===========================
        goto delete_separate_batch;
      else
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' goto create_separate_batch label ');
        -- ========================= FND LOG ===========================
        goto create_separate_batch;
      end if;

    end if;

    -- Insert generated transactions in the packet into gl_je_lines for all
    -- headers of the originating batch

    if g_fcmode <> 'U' then

      if (l_avoid_copying_attr = 'Y') then

      insert into gl_je_lines
                 (je_header_id,
                  je_line_num,
                  last_update_date,
                  last_updated_by,
                  ledger_id,
                  code_combination_id,
                  period_name,
                  effective_date,
                  status,
                  creation_date,
                  created_by,
                  entered_dr,
                  entered_cr,
                  accounted_dr,
                  accounted_cr,
                  tax_code,
                  invoice_identifier,
                  no1,
                  ignore_rate_flag,
                  reference_1,
                  reference_10)
           select bp.je_header_id,
                  l_max_je_line_num + 10 * rownum, -- bug 5139224
                  sysdate,
                  g_user_id,
                  g_ledger_id,
                  bp.code_combination_id,
                  bp.period_name,
                  jh.default_effective_date,
                  'U',
                  sysdate,
                  g_user_id,
                  bp.entered_dr,
                  bp.entered_cr,
                  bp.accounted_dr,
                  bp.accounted_cr,
                  ' ',
                  ' ',
                  ' ',
                  'Y',
                  BP.ussgl_link_to_parent_id,
                  'glxfje() generated: ' || g_packet_id
             from gl_period_statuses ps,
                  gl_je_headers jh,
                  gl_bc_packets bp
            where ps.application_id = 101
              and ps.ledger_id = g_ledger_id
              and ps.period_name = bp.period_name
              and jh.je_header_id = bp.je_header_id
              and bp.packet_id = g_packet_id
              and bp.ussgl_link_to_parent_id is not null;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' gl_je_lines for originating batch ' || sql%ROWCOUNT);
        -- ========================= FND LOG ===========================

       else

        INSERT INTO GL_JE_LINES
                (je_header_id,
                je_line_num,
                last_update_date,
                last_updated_by,
                ledger_id,
                code_combination_id,
                period_name,
                effective_date,
                status,
                creation_date,
                created_by,
                entered_dr,
                entered_cr,
                accounted_dr,
                accounted_cr,
                tax_code,
                invoice_identifier,
                no1,
                ignore_rate_flag,
                reference_1,
                reference_2,
                reference_3,
                reference_4,
                reference_5,
                reference_6,
                reference_7,
                reference_8,
                reference_9,
                reference_10,
                context,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10)
        SELECT
                BP.je_header_id,
                JL.je_line_num + 10*rownum,
                SYSDATE,
                g_user_id,
                g_ledger_id,
                BP.code_combination_id,
                BP.period_name,
                JL.effective_date,
                'U',
                SYSDATE,
                g_user_id,
                BP.entered_dr,
                BP.entered_cr,
                BP.accounted_dr,
                BP.accounted_cr,
                ' ',
                ' ',
                ' ',
                'Y',
                BP.ussgl_link_to_parent_id,
                BP.reference2,
                BP.reference3,
                BP.reference4,
                BP.reference5,
                BP.reference6,
                BP.reference7,
                BP.reference8,
                BP.reference9,
                'glxfje() generated: ' || g_packet_id   /* for unrsv only */,
                decode(JL1.context,JL1.context3,null,JL1.context),
                decode(JL1.context,JL1.context3,null,JL1.attribute1),
                decode(JL1.context,JL1.context3,null,JL1.attribute2),
                decode(JL1.context,JL1.context3,null,JL1.attribute3),
                decode(JL1.context,JL1.context3,null,JL1.attribute4),
                decode(JL1.context,JL1.context3,null,JL1.attribute5),
                decode(JL1.context,JL1.context3,null,JL1.attribute6),
                decode(JL1.context,JL1.context3,null,JL1.attribute7),
                decode(JL1.context,JL1.context3,null,JL1.attribute8),
                decode(JL1.context,JL1.context3,null,JL1.attribute9),
                decode(JL1.context,JL1.context3,null,JL1.attribute10)
        FROM
                GL_PERIOD_STATUSES PS,
                GL_JE_LINES JL,
                GL_JE_LINES JL1,
                GL_BC_PACKETS BP
        WHERE
                PS.application_id = 101
            AND PS.ledger_id = g_ledger_id
            AND PS.period_name = BP.period_name
            AND JL.je_header_id = BP.je_header_id
            AND JL.je_line_num = (SELECT max(JL1.je_line_num)
                                  FROM   GL_JE_LINES JL1
                                  WHERE  JL1.je_header_id = BP.je_header_id)
            AND BP.packet_id = g_packet_id
            AND BP.ussgl_link_to_parent_id IS NOT NULL
            AND JL1.je_header_id = BP.je_header_id
            AND JL1.je_line_num = BP.je_line_num;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' Insert GL_JE_LINES -> ' || sql%ROWCOUNT);
        -- ========================= FND LOG ===========================

       end if;
    else

      -- For Unreservation, delete previously appended generated transactions
      -- from gl_je_lines

      delete from gl_je_lines jl
       where jl.je_header_id in
            (
             select distinct bp.je_header_id
               from gl_bc_packets bp
              where bp.packet_id = g_packet_id
                and bp.ussgl_link_to_parent_id IS NOT NULL
            )
         and jl.reference_10 = 'glxfje() generated: ' || g_packet_id_ursvd;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' delete gl_je_lines - Unreservation ' || sql%ROWCOUNT);
        -- ========================= FND LOG ===========================

    end if;


    -- Update Control Total and Running Totals of all headers with generated
    -- transactions appended/deleted

    update gl_je_headers jh
       set (jh.control_total,
            jh.running_total_dr,
            jh.running_total_cr,
            jh.running_total_accounted_dr,
            jh.running_total_accounted_cr) =
           (
            select decode(jh.control_total, null, null, jh.control_total +
                          sum(nvl(bp.entered_dr, 0)) *
                          decode(g_fcmode, 'U', -1, 1)),
                   nvl(jh.running_total_dr, 0) + sum(nvl(bp.entered_dr, 0)) *
                       decode(g_fcmode, 'U', -1, 1),
                   nvl(jh.running_total_cr, 0) + sum(nvl(bp.entered_cr, 0)) *
                       decode(g_fcmode, 'U', -1, 1),
                   nvl(jh.running_total_accounted_dr, 0) +
                       sum(nvl(bp.accounted_dr, 0)) *
                       decode(g_fcmode, 'U', -1, 1),
                   nvl(jh.running_total_accounted_cr, 0) +
                       sum(nvl(bp.accounted_cr, 0)) *
                       decode(g_fcmode, 'U', -1, 1)
              from gl_bc_packets bp
             where bp.packet_id = g_packet_id
               and bp.je_batch_id = jh.je_batch_id
               and bp.je_header_id = jh.je_header_id
               and bp.ussgl_link_to_parent_id is not null
           )
     where jh.je_header_id in
          (
           select distinct je_header_id
             from gl_bc_packets bp1
            where bp1.packet_id = g_packet_id
              and bp1.ussgl_link_to_parent_id is not null
          );

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' Update Control Total and Running Totals - gl_je_headers ' || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================


    -- Update Batch Control Total, Running Totals, Budgetary Control Status and
    -- Packet ID

    update gl_je_batches jb
       set (jb.control_total,
            jb.running_total_dr,
            jb.running_total_cr,
            jb.running_total_accounted_dr,
            jb.running_total_accounted_cr,
            jb.budgetary_control_status,
            jb.packet_id) =
           (
            select decode(jb.control_total, null, null, jb.control_total +
                          sum(nvl(bp.entered_dr, 0)) *
                          decode(g_fcmode, 'U', -1, 1)),
                   nvl(jb.running_total_dr, 0) + sum(nvl(bp.entered_dr, 0)) *
                                                 decode(g_fcmode, 'U', -1, 1),
                   nvl(jb.running_total_cr, 0) + sum(nvl(bp.entered_cr, 0)) *
                                                 decode(g_fcmode, 'U', -1, 1),
                   nvl(jb.running_total_accounted_dr, 0) +
                   sum(nvl(bp.accounted_dr, 0)) * decode(g_fcmode, 'U', -1, 1),
                   nvl(jb.running_total_accounted_cr, 0) +
                   sum(nvl(bp.accounted_cr, 0)) * decode(g_fcmode, 'U', -1, 1),
                   decode(g_fcmode, 'U', 'R', 'P'),
                   decode(g_fcmode, 'U', null, jb.packet_id)
              from gl_bc_packets bp
             where bp.packet_id = g_packet_id
               and bp.je_batch_id = jb.je_batch_id
               and bp.ussgl_link_to_parent_id is not null
           )
     where jb.je_batch_id = l_je_batch_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Update gl_je_batches - Batch Control Total, Running Totals, ' ||
       ' Budgetary Control Status ' || SQL%ROWCOUNT);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' goto normal_exit label ');
    -- ========================= FND LOG ===========================

    -- Invoke GL API to fix the GL_JE_SEGMENT_VALUES table.
    -- We invoke this API with batch_id parameter so that it works with both inserts/deletes

    l_seg_val_ret_code := gl_je_segment_values_pkg.insert_batch_segment_values(l_je_batch_id);

    -- Exit since Originating Batch is Actual
    goto normal_exit;

    <<create_separate_batch>>

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Reached create_separate_batch label ');
    -- ========================= FND LOG ===========================

    -- Get new Batch ID from Sequence
    open batch_id;
    fetch batch_id into l_gen_batch_id;
    close batch_id;

     open enable_approval;
    fetch enable_approval into l_enable_app;
    close enable_approval;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_gen_batch_id -> '|| l_gen_batch_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_enable_app   -> '|| l_enable_app.enable_je_approval_flag);
    -- ========================= FND LOG ===========================

    if l_enable_app.enable_je_approval_flag = 'Y' then

         open je_source(l_je_batch_id);
        fetch je_source into l_je_source;
        close je_source;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_je_source -> '|| l_je_source.je_source);
        -- ========================= FND LOG ===========================

         open je_approval(l_je_source.je_source);
        fetch je_approval into l_je_approval;
        close je_approval;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path, ' l_je_approval -> '|| l_je_approval.journal_approval_flag);
        -- ========================= FND LOG ===========================

        if l_je_approval.journal_approval_flag = 'Y' then
            l_approval_status_code := 'R';
        else
            l_approval_status_code := 'Z';
        end if;

    else
       l_approval_status_code := 'Z';
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' l_approval_status_code -> '|| l_approval_status_code);
    -- ========================= FND LOG ===========================

    -- Create new Actual Batch for the Generated Transactions
    insert into gl_je_batches
               (je_batch_id,
                last_update_date,
                last_updated_by,
                set_of_books_id_11i,
                name,
                status,
                status_verified,
                actual_flag,
                default_effective_date,
                creation_date,
                created_by,
                default_period_name,
                date_created,
                description,
                running_total_dr,
                running_total_cr,
                running_total_accounted_dr,
                running_total_accounted_cr,
                budgetary_control_status,
                packet_id,
                average_journal_flag,
                approval_status_code,
                chart_of_accounts_id,
                period_set_name,
                accounted_period_type)
         select l_gen_batch_id,
                sysdate,
                g_user_id,
                g_ledger_id,
                substrb('CJE: ' || min(jb.name) ||' '||
            to_char(sysdate)||
            to_char(sysdate,' HH24:MI:SS: ')||
                        'A', 1, 100),
                'U',
                'N',
                'A',
                min(jb.default_effective_date),
                sysdate,
                g_user_id,
                min(bp.period_name),
                sysdate,
                decode(min(jb.description), null, null,
                       substrb('CJE: ' || min(jb.description), 1, 240)),
                sum(nvl(bp.entered_dr, 0)),
                sum(nvl(bp.entered_cr, 0)),
                sum(nvl(bp.accounted_dr, 0)),
                sum(nvl(bp.accounted_cr, 0)),
                'P',
                null,    /* For Disabling Unreservation on Generated Batches */
                min(jb.average_journal_flag),
                l_approval_status_code,
                min(jb.chart_of_accounts_id),
                min(jb.period_set_name),
                min(jb.accounted_period_type)
           from gl_period_statuses ps,
                gl_bc_packets bp,
                gl_je_batches jb
          where ps.application_id = 101
            and ps.ledger_id = g_ledger_id
            and ps.period_name = bp.period_name
            and bp.packet_id = g_packet_id
            and bp.ussgl_link_to_parent_id is not null
            and jb.je_batch_id = l_je_batch_id;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Creating new actual bacth - gl_je_batches -> '|| SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glurevd ');
    -- ========================= FND LOG ===========================

    DECLARE

        CURSOR batch_sources IS
        SELECT je_header_id, je_category, je_source, period_name
        FROM   gl_je_headers
          WHERE  je_batch_id = l_je_batch_id;

    BEGIN
        FOR x IN batch_sources
        LOOP

            -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' x.je_header_id -> '|| x.je_header_id);
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' x.je_category -> '|| x.je_category);
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' x.je_source      -> '|| x.je_source);
                   psa_utils.debug_other_string(g_state_level,l_full_path, ' x.period_name   -> '|| x.period_name);
            -- ========================= FND LOG ===========================

            IF NOT ( glurevd(p_ledger_id         => g_ledger_id,
                             p_je_category        => x.je_category,
                                 p_je_source         => x.je_source,
                                p_je_period         => x.period_name,
                                p_je_date             => sysdate,
                                x_reversal_method    => l_reversal_method,
                                p_balance_type        => 'A')) THEN

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
                   -- ========================= FND LOG ===========================
                g_debug := g_debug||' GLXFJE Failed : glurevd returned FALSE';
                   return (FALSE);
             END IF;

            -- Create associated headers for the new Actual Batch
            insert into gl_je_headers
                       (je_header_id,
                        last_update_date,
                        last_updated_by,
                        ledger_id,
                        je_category,
                        je_source,
                        period_name,
                        name,
                        currency_code,
                        status,
                        date_created,
                        accrual_rev_flag,
                        multi_bal_seg_flag,
                        actual_flag,
                        conversion_flag,
                        default_effective_date,
                        creation_date,
                        created_by,
                        je_batch_id,
                        description,
                        currency_conversion_rate,
                        currency_conversion_type,
                        currency_conversion_date,
                        attribute1,
                        accrual_rev_change_sign_flag,
                        tax_status_code)
            select   gl_je_headers_s.nextval,
                        sysdate,
                        g_user_id,
                        g_ledger_id,
                        jh.je_category,
                        jh.je_source,
                        jh.period_name,
                        substrb('CJE: ' || jh.name ||' '||
                                   to_char(sysdate)||
                         to_char(sysdate,' HH24:MI:SS'),1,100),
                        jh.currency_code,
                        'U',
                        sysdate,
                        'N',
                        'N',
                        'A',
                        'N',
                        jh.default_effective_date,
                        sysdate,
                        g_user_id,
                        l_gen_batch_id,
                        decode(jh.description, null, null,
                               substrb('CJE: ' || jh.description, 1, 240)),
                        1,
                        'User',
                        sysdate,
                        to_char(jh.je_header_id),
                         l_reversal_method,
                     'N'
              from      gl_je_headers jh
             where  jh.je_batch_id  = l_je_batch_id
             and      jh.je_header_id = x.je_header_id
           and exists
                       (
                         select 'JE headers with associated generated transactions'
                           from gl_bc_packets bp
                          where bp.packet_id       = g_packet_id
                          and bp.je_batch_id  = l_je_batch_id
                          and bp.je_header_id = jh.je_header_id
                          and bp.ussgl_link_to_parent_id is not null
                       );


            -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   ' Insert gl_je_headers - Headers for Actual Batches ' || SQL%ROWCOUNT);
            -- ========================= FND LOG ===========================
        END LOOP;
    END;

    -- Update running totals of associated headers

    update gl_je_headers jh
       set (jh.running_total_dr,
            jh.running_total_cr,
            jh.running_total_accounted_dr,
            jh.running_total_accounted_cr) =
           (
            select sum(nvl(bp.entered_dr, 0)),
                   sum(nvl(bp.entered_cr, 0)),
                   sum(nvl(bp.accounted_dr, 0)),
                   sum(nvl(bp.accounted_cr, 0))
              from gl_bc_packets bp
             where bp.packet_id = g_packet_id
               and bp.je_batch_id = l_je_batch_id
               and bp.je_header_id = to_number(jh.attribute1)
               and bp.ussgl_link_to_parent_id is not null
           )
     where JH.je_batch_id = l_gen_batch_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_je_headers - running totals - ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Insert generated transactions in packet into gl_je_lines
    if (l_avoid_copying_attr = 'Y') then

        insert into gl_je_lines
               (je_header_id,
                je_line_num,
                last_update_date,
                last_updated_by,
                ledger_id,
                code_combination_id,
                period_name,
                effective_date,
                status,
                creation_date,
                created_by,
                entered_dr,
                entered_cr,
                accounted_dr,
                accounted_cr,
                tax_code,
                invoice_identifier,
                no1,
                ignore_rate_flag,
                reference_10)
         select jh.je_header_id,
                10 * row_number() over (partition by jh.je_header_id
                            order by jh.je_header_id),
                sysdate,
                g_user_id,
                g_ledger_id,
                bp.code_combination_id,
                bp.period_name,
                jh.default_effective_date,
                'U',
                sysdate,
                g_user_id,
                bp.entered_dr,
                bp.entered_cr,
                bp.accounted_dr,
                bp.accounted_cr,
                ' ',
                ' ',
                ' ',
                'Y',
                'glxfje() generated: ' || g_packet_id
           from gl_je_headers jh,
                gl_bc_packets bp
          where jh.je_batch_id = l_gen_batch_id
          and jh.attribute1      = to_char(bp.je_header_id)
          and bp.packet_id      = g_packet_id
          and bp.ussgl_link_to_parent_id is not null;

   else

       INSERT INTO GL_JE_LINES
            (je_header_id,
            je_line_num,
            last_update_date,
            last_updated_by,
            ledger_id,
            code_combination_id,
            period_name,
            effective_date,
            status,
            creation_date,
            created_by,
            entered_dr,
            entered_cr,
            accounted_dr,
            accounted_cr,
            tax_code,
            invoice_identifier,
            no1,
            ignore_rate_flag,
            reference_10,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10)
       SELECT
            min(JH.je_header_id),
            10*count(BP1.rowid),
            SYSDATE,
            g_user_id,
            g_ledger_id,
            min(BP.code_combination_id),
            min(BP.period_name),
            min(JH.default_effective_date),
            'U',
            SYSDATE,
            g_ledger_id,
            min(BP.entered_dr),
            min(BP.entered_cr),
            min(BP.accounted_dr),
            min(BP.accounted_cr),
            ' ',
            ' ',
            ' ',
            'Y',
            'glxfje() generated: ' || g_packet_id,   /* for unrsv only */
            decode(min(JL.context),min(JL.context3),null,min(JL.context)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute1)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute2)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute3)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute4)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute5)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute6)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute7)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute8)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute9)),
            decode(min(JL.context),min(JL.context3),null,min(JL.attribute10))
       FROM
            GL_JE_HEADERS JH,
            GL_BC_PACKETS BP1,
            GL_BC_PACKETS BP,
            GL_JE_LINES JL
       WHERE
            JH.je_batch_id = l_gen_batch_id
        AND JH.attribute1 = to_char(BP.je_header_id)
        AND BP1.packet_id = BP.packet_id
        AND BP1.je_batch_id = BP.je_batch_id
        AND BP1.je_header_id = BP.je_header_id
        AND BP1.rowid <= BP.rowid
        AND BP1.ussgl_link_to_parent_id IS NOT NULL
        AND BP.packet_id = g_packet_id
        AND BP.ussgl_link_to_parent_id IS NOT NULL
        AND JL.je_header_id = BP.je_header_id
        AND JL.je_line_num = BP.je_line_num
       GROUP BY BP.rowid;

    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Insert gl_je_lines - ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================


    -- Update je_batch_id of all associated generated transactions from the
    -- ID of the Originating Batch to that of the newly created batch so that
    -- posting deletes only these packet rows

    update gl_bc_packets bp
       set bp.je_batch_id = l_gen_batch_id
     where bp.packet_id = g_packet_id
       and bp.ussgl_link_to_parent_id is not null;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_bc_packets - je_bacth_id - ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Clean up attribute1 in gl_je_headers (contains header id of the
    -- originating line)

    update gl_je_headers jh
       set jh.attribute1 = null
     where jh.je_batch_id = l_gen_batch_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_je_headers -> ' || SQL%ROWCOUNT);
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' goto normal_exit label ');
    -- ========================= FND LOG ===========================

    -- Invoke GL API to fix the GL_JE_SEGMENT_VALUES table.

    l_seg_val_ret_code := gl_je_segment_values_pkg.insert_batch_segment_values(l_gen_batch_id);

    goto normal_exit;

    <<delete_separate_batch>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Reached delete_seperate_batch label ');
    -- ========================= FND LOG ===========================

    -- Delete all previously created associated generated transactions from
    -- gl_je_lines

    delete from gl_je_lines jl
     where jl.je_header_id in
          (
           select distinct jh.je_header_id
             from gl_je_headers jh,
                  gl_bc_packets bp
            where jh.je_batch_id = bp.je_batch_id
              and bp.packet_id = g_packet_id
              and bp.ussgl_link_to_parent_id is not null
          )
       and jl.reference_10 = 'glxfje() generated: ' || g_packet_id_ursvd;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Delete gl_je_lines - ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Delete all associated headers of the generated transactions

    delete from gl_je_headers jh
     where jh.je_batch_id in
          (
           select distinct bp.je_batch_id
             from gl_bc_packets bp
            where bp.packet_id = g_packet_id
              and bp.ussgl_link_to_parent_id is not null
          );

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Delete gl_je_headers - ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Delete the associated batch of the generated transactions

    FOR x IN generated_bat
    LOOP
        delete from gl_je_batches jb
         where jb.je_batch_id = x.je_batch_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Delete gl_je_batches - ' || SQL%ROWCOUNT);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN - TRUE ');
    -- ========================= FND LOG ===========================

        -- Invoke the GL API to fix the GL_JE_SEGMENT_VALUES table

        l_seg_val_ret_code := gl_je_segment_values_pkg.insert_batch_segment_values(x.je_batch_id);
    END LOOP;


    return(TRUE);

    <<normal_exit>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Reached normal_exit label');
    -- ========================= FND LOG ===========================

    if NOT g_conc_flag AND l_actual_flag = 'A' then
       COMMIT;
       g_requery_flag := TRUE;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN - TRUE ');
    -- ========================= FND LOG ===========================
    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if orig_bat%ISOPEN then
        close orig_bat;
      end if;

      if batch_id%ISOPEN then
        close batch_id;
      end if;

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN - FALSE ');
    -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXFJE Failed : '||SQLERRM;
      return(FALSE);

  END glxfje;

  /* ============================= GLXFPP ============================= */

  -- Purge Packets after Funds Check

  -- This Module provides a way for any external Funds Check implementation
  -- to rollback Funds Reserved after the Funds Checker call. This must be
  -- called before any commit that would otherwise confirm the final Funds
  -- Check Status of the packet

  -- This Module deletes all transaction lines of a packet in gl_bc_packets and
  -- the associated Arrival Order record in gl_bc_packet_arrival_order

  -- This Module also deletes the corresponding records for a packet being
  -- Unreserved

  -- This Function is invoked by any Module that needs to purge all packet
  -- related information after the Funds Checker call


  -- Parameters :
  -- p_packetid : Packet ID
  -- p_packetid_ursvd : Unreservation Packet ID. Defaults to 0

  PROCEDURE glxfpp(p_packetid       IN NUMBER,
                   p_packetid_ursvd IN NUMBER) IS

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

  BEGIN

          l_full_path := g_path || 'glxfpp1';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFPP1 --> START ');
    -- ========================= FND LOG ===========================

    -- Delete Packet Transactions
    delete from gl_bc_packets bp
     where bp.packet_id in (p_packetid, p_packetid_ursvd);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' delete from gl_bc_packets ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Delete Packet Arrival Order Record
    delete from gl_bc_packet_arrival_order ao
     where ao.packet_id in (p_packetid, p_packetid_ursvd);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' delete from gl_bc_packet_arrival_order ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
    -- ========================= FND LOG ===========================

  END glxfpp;

  PROCEDURE glxfpp(p_eventid       IN NUMBER) IS

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

  BEGIN

          l_full_path := g_path || 'glxfpp2';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFPP2 --> START ');
    -- ========================= FND LOG ===========================

    -- Delete Packet Transactions
    delete from gl_bc_packets bp
     where bp.event_id = p_eventid;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' delete from gl_bc_packets ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Delete Packet Arrival Order Record
    delete from gl_bc_packet_arrival_order ao
     where ao.packet_id in (select packet_id
                             from gl_bc_packets
                            where event_id = p_eventid);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' delete from gl_bc_packet_arrival_order ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

    -- Delete History Record
   delete from gl_bc_packets_hists bp
     where bp.event_id = p_eventid;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' delete from gl_bc_packets_hists ' || SQL%ROWCOUNT);
    -- ========================= FND LOG ===========================

  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
    -- ========================= FND LOG ===========================

  END glxfpp;

 /* ============================ GLXFUF ============================ */

  -- Update Status Code for Transactions to Fatal

  -- Updates Status Code for all transactions in the Packet to 'T'; it also
  -- updates affect_funds_flag in gl_bc_packet_arrival_order to 'N' so that
  -- the available Funds calculation of packets arriving later is not affected
  -- in case an irrecoverable error halts Funds Check. SQLs for updating the
  -- columns are not guaranteed to succeed in many drastic cases. However, this
  -- step tries to ensure that the current packet does not affect the Funds
  -- Available calculation for packets arriving later

  -- The final cleanup is done by the Sweeper program, which deletes all packets
  -- with Status 'T', as well as all packets with Status 'P' (Pending) which are
  -- older than a specific (relatively long) time interval. This remedies for
  -- cases where the update could not be done in this Module

  FUNCTION glxfuf RETURN BOOLEAN IS
    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================
  BEGIN

         l_full_path := g_path || 'glxfuf';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfuf -> START ');
    -- ========================= FND LOG ===========================

    -- Update Status Code for the Packet Transactions
    update gl_bc_packets bp
       set bp.status_code = 'T'
     where bp.packet_id = g_packet_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' g_packet_id -> ' || g_packet_id );
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_bc_packets with T -> ' || SQL%ROWCOUNT );
    -- ========================= FND LOG ===========================

    -- Update Affect Funds Flag
    update gl_bc_packet_arrival_order ao
       set ao.affect_funds_flag = 'N'
     where ao.packet_id = g_packet_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update gl_bc_packet_arrival_order to N -> ' || SQL%ROWCOUNT );
    -- ========================= FND LOG ===========================

    if not glrchk('Z') then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glrchk(Z) -> FALSE' );
       -- ========================= FND LOG ===========================
      null;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE' );
    -- ========================= FND LOG ===========================
    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM );
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN --> FALSE' );
    -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXFUF Failed : '||SQLERRM;
      return(FALSE);

  END glxfuf;

  /* =============================== MESSAGE_TOKEN ======================= */

  -- Add Token and Value to the Message Token array

  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2) IS

            l_full_path VARCHAR2(100);

  BEGIN

    l_full_path := g_path||'Message_Token';

    if g_no_msg_tokens is null then
      g_no_msg_tokens := 1;
    else
      g_no_msg_tokens := g_no_msg_tokens + 1;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_no_msg_tokens -> ' || g_no_msg_tokens );
    -- ========================= FND LOG ===========================

    msg_tok_names(g_no_msg_tokens) := tokname;
    msg_tok_val(g_no_msg_tokens) := tokval;

  END message_token;

 /* =========================== ADD_MESSAGE ============================== */

  -- Sets the Message Stack

  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2) IS

    i  BINARY_INTEGER;
    l_full_path VARCHAR2(100);

  BEGIN

    l_full_path := g_path||'Add_Message';

    if ((appname is not null) and
        (msgname is not null)) then

      FND_MESSAGE.SET_NAME(appname, msgname);

      if g_no_msg_tokens is not null then

        for i in 1..g_no_msg_tokens loop
          FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
        end loop;

      end if;

    end if;

    -- Clear Message Token stack
    g_no_msg_tokens := 0;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' g_no_msg_tokens -> ' || g_no_msg_tokens );
    -- ========================= FND LOG ===========================


  END add_message;


   /* ========================== FV_PREPAY_PKG ========================== */

 FUNCTION fv_prepay_pkg RETURN BOOLEAN IS

    -- Bug 3861686, added subquery to get the owner of the package.

    CURSOR c_fv_prepay_pkg is
       SELECT DISTINCT 'Y' status
     FROM ALL_OBJECTS
        WHERE object_name = 'FV_AP_PREPAY_PKG'
          AND object_type = 'PACKAGE'
          AND owner       = (SELECT oracle_username
                 FROM fnd_oracle_userid
                 WHERE read_only_flag = 'U')
          AND status      = 'VALID';

    CURSOR c_packet_count(c_packet_id IN NUMBER) is
    SELECT count(*) pkt_cnt
      FROM gl_bc_packets
     WHERE packet_id = c_packet_id;

    cursor c_batch_id (c_packet_id IN NUMBER) is
    SELECT 'Y' batch_id
      FROM GL_BC_PACKETS
     WHERE packet_id    = c_packet_id
       AND je_batch_id IS NOT NULL
       AND rownum       = 1;

    l_fv_prepay_pkg    c_fv_prepay_pkg%rowtype;
    l_packet_count    c_packet_count%rowtype;
    l_batch_id        c_batch_id%rowtype;

    fv_prepay_stmt VARCHAR2(2000);
    p_packet_id    gl_bc_packets.packet_id%type;
    p_status       NUMBER(15);
    l_full_path VARCHAR2(100);

  BEGIN

     l_full_path := g_path||'Fv_Prepay_pkg';
     if g_fv_prepay_prof then

     p_packet_id := g_packet_id;

         if g_fcmode IN ( 'C', 'R' ) then

            open c_fv_prepay_pkg;
           fetch c_fv_prepay_pkg
            into l_fv_prepay_pkg;
           close c_fv_prepay_pkg;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' l_fv_prepay_pkg.status -> ' || l_fv_prepay_pkg.status );
    -- ========================= FND LOG ===========================


           if l_fv_prepay_pkg.status = 'Y' then

          open c_packet_count(p_packet_id);
         fetch c_packet_count
          into l_packet_count;
         close c_packet_count;

         if l_packet_count.pkt_cnt IS NOT NULL then

                open c_batch_id(p_packet_id);
               fetch c_batch_id
                into l_batch_id;
               close c_batch_id;

               if l_batch_id.batch_id IS NULL then

                  fv_prepay_stmt :=
                          'BEGIN  FV_AP_PREPAY_PKG.CREATE_PREPAY_LINES(:p_packet_id, :p_status); END;';

                  execute immediate fv_prepay_stmt USING IN p_packet_id, OUT p_status;

                   -- 0 : Success 1 : Failure

                   if p_status = 1 then

                      message_token('PROCEDURE', 'FV_AP_PREPAY_PKG.CREATE_PREPAY_LINES Returned Failure');
                        message_token('EVENT', SQLERRM);
                        add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
                     g_debug := g_debug||' FV_PREPAY_PKG Failed : FV_AP_PREPAY_PKG.CREATE_PREPAY_LINES
                                             Returned Failure';
                      return(FALSE);

                   end if;
               end if;
         end if;
           end if;
         end if;
      end if;

     RETURN TRUE;

  EXCEPTION
     WHEN OTHERS THEN
      message_token('PROCEDURE', 'FV_AP_PREPAY_PKG.CREATE_PREPAY_LINES Returned Failure');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN FALSE');
    -- ========================= FND LOG ===========================

      g_debug := g_debug||' FV_PREPAY_PKG Failed : '||SQLERRM;
      return FALSE;

  END fv_prepay_pkg;



  /* ============================= GLXFAR ================================ */

  -- Update affect_funds_flag in gl_bc_packet_arrival
  --
  -- This is called from glxfrs() and is executed in an autonomous scope
  -- so that the calling programs work is not commited.
  --

  FUNCTION glxfar RETURN BOOLEAN IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

         l_full_path := g_path || 'glxfar';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFAR -> START ');
    -- ========================= FND LOG ===========================

    -- Update Affect Funds Flag to 'N' if Mode is Reservation and Return Code
    -- is Failure

    if ((g_fcmode <> 'C') and
        (g_return_code = 'F')) then
     begin

      update gl_bc_packet_arrival_order ao
         set ao.affect_funds_flag = 'N'
       where ao.packet_id = g_packet_id;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' update gl_bc_packet_arrival_order -> ' || SQL%ROWCOUNT);
      -- ========================= FND LOG ===========================

      -- Commit so that a later rollback does not reset this flag
      commit;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN - TRUE');
      -- ========================= FND LOG ===========================
      RETURN (TRUE);

     end;
    end if;

    commit;
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN - TRUE');
    -- ========================= FND LOG ===========================
    RETURN (TRUE);

  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker : glxfar');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN - FALSE');
    -- ========================= FND LOG ===========================

      g_debug := g_debug||' GLXFAR Failed : '||SQLERRM;
      -- bug 3471744
      rollback;
      return (FALSE);

  END;

  /* =============================== GLXCON ================================ */

  FUNCTION glxcon RETURN BOOLEAN IS
    others  EXCEPTION;
    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

       l_full_path  := g_path || 'glxcon.';

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXCON -> START ');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfrs .. ');
    -- ========================= FND LOG ===========================

    -- Get Return Status
    if not glxfrs then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFRS - RETURN FALSE ');
          psa_utils.debug_other_string(g_state_level,l_full_path, ' goto fatal_error label ');
       -- ========================= FND LOG ===========================
      goto fatal_error;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_fcmode -> ' || g_fcmode);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' g_return_code -> '|| g_return_code);
    -- ========================= FND LOG ===========================

    -- Process Journal Entries Module if all transactions pass Funds
    -- (Un)Reservation and Append JE Flag is set

    if ((g_fcmode in ('R', 'U', 'A', 'F')) and
        (g_return_code in ('S', 'A'))) then

      if g_append_je_flag then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag -> TRUE');
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfje ..');
         -- ========================= FND LOG ===========================

        if not glxfje then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFJE RETURN FALSE ');
              psa_utils.debug_other_string(g_state_level,l_full_path, ' goto fatal_error label ');
           -- ========================= FND LOG ===========================
          goto fatal_error;
        end if;

      end if;

      -- Delete the Packet being Unreserved and the generated Unreserved
      -- Packet if it passes Funds Unreservation

      if g_fcmode = 'U' then

         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfpp .. ');
         -- ========================= FND LOG ===========================
         glxfpp(g_packet_id, g_packet_id_ursvd);

        -- If Journal Entries were deleted then Commit
        if g_append_je_flag then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' g_append_je_flag -> TRUE ');
              psa_utils.debug_other_string(g_state_level,l_full_path, ' COMMIT ');
           -- ========================= FND LOG ===========================
          commit;
        end if;

      end if;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> TRUE ');
    -- ========================= FND LOG ===========================
    return(TRUE);

    <<fatal_error>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Reached fatal_error label ');
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxfuf .. ');
    -- ========================= FND LOG ===========================

    if not glxfuf then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' GLXFUF - RETURN FALSE ');
          psa_utils.debug_other_string(g_state_level,l_full_path, ' RASIE OTHERS ');
       -- ========================= FND LOG ===========================
       raise others;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
    -- ========================= FND LOG ===========================
    g_debug := g_debug||' GLXCON Failed';
    return(FALSE);

  EXCEPTION

    WHEN OTHERS THEN

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
      -- ========================= FND LOG ===========================
      g_debug := g_debug||' GLXCON Failed : '||SQLERRM;
      return(FALSE);

  END glxcon;

 /*=======================================================================+
  |    Function    : GLUREVD                                                    |
  | Description : This is a replica of function glurevd_default_reversal  |
  |                  in file $GL_TOP/src/utils/glurevd.lpc                      |
  +=======================================================================*/

  FUNCTION glurevd ( p_ledger_id NUMBER,
                     p_je_category     VARCHAR2,
                     p_je_source     VARCHAR2,
                     p_je_period     VARCHAR2,
                     p_je_date         DATE,
                     x_reversal_method  OUT NOCOPY     VARCHAR2,
                     p_balance_type VARCHAR2) RETURN BOOLEAN IS

    l_je_reversal_date DATE;
    l_reversal_method  VARCHAR2(1);
    l_reversal_period  VARCHAR2(15);
    l_reversal_date    DATE;
     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================
  BEGIN

          l_full_path := g_path || 'glurevd';

    -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ledger_id  -> ' || p_ledger_id);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_je_category  -> ' || p_je_category);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_je_source  -> ' || p_je_source);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_je_period  -> ' || p_je_period);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_je_date  -> '
                                    || to_char(p_je_date, 'DD-MON-YYYY'));
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_balance_type -> ' || p_balance_type);
         -- ========================= FND LOG ===========================

    IF (p_balance_type = 'A') THEN
        BEGIN
            GL_AUTOREVERSE_DATE_PKG.GET_REVERSAL_PERIOD_DATE(
                x_ledger_id => p_ledger_id,
                x_je_category => p_je_category,
                x_je_source => p_je_source,
                x_je_period_name => p_je_period,
                x_je_date => p_je_date,
                x_reversal_method => l_reversal_method,
                x_reversal_period => l_reversal_period,
                x_reversal_date => l_reversal_date);
        EXCEPTION
            WHEN OTHERS THEN
                -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_excep_level,l_full_path,
                        'Call to GL_AUTOREVERSE_DATE_PKG raised unhandled exception - '
                        ||sqlcode||' - '||sqlerrm);
                psa_utils.debug_unexpected_msg(l_full_path);
                -- ========================= FND LOG ===========================

                GL_AUTOREVERSE_DATE_PKG.get_default_reversal_method(
                            g_ledger_id, p_je_category, l_reversal_method);

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_excep_level,l_full_path,
                'l_reversal_method value returned by get_default_reversal_method : '||l_reversal_method);
                -- ========================= FND LOG ===========================

        END;

    ELSE

            GL_AUTOREVERSE_DATE_PKG.get_default_reversal_method(
                     g_ledger_id, p_je_category, l_reversal_method);

            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_excep_level,l_full_path,
            'l_reversal_method value returned by get_default_reversal_method : '||l_reversal_method);
            -- ========================= FND LOG ===========================

    END IF;

    IF (l_reversal_method IS NOT NULL) THEN

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,'x_reversal_method -> l_reversal_method');
           psa_utils.debug_other_string(g_excep_level,l_full_path,'Return -> True');
        -- ========================= FND LOG ===========================

        x_reversal_method := l_reversal_method;
        return TRUE;
    ELSE
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,'Return -> False');
        -- ========================= FND LOG ===========================

        return FALSE;
    END IF;

  EXCEPTION
       WHEN OTHERS THEN
    -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,
                'Exception raised in main body execution - '||sqlcode||' - '||sqlerrm);
              psa_utils.debug_unexpected_msg(l_full_path);
    -- ========================= FND LOG ===========================
    g_debug := g_debug||' GLUREVD Failed : '||SQLERRM;
    x_reversal_method := NULL;
    return FALSE;

  END glurevd;

 /*=======================================================================+
  | Function    : GL_CONFIRM_OVERRIDE                                     |
  | Description : Applicable on for GL. This function is added so that GL |
  |               can pop up a window for confirming override of the trx  |
  |               and once the user decides, GL invokes this function     |
  |               so that funds check can proceed accordingly.            |
  +=======================================================================*/

  FUNCTION gl_confirm_override(p_ledgerid          IN  NUMBER,
                  p_packetid          IN  NUMBER,
                  p_mode              IN  VARCHAR2 DEFAULT 'C',
                  p_override          IN  VARCHAR2 DEFAULT 'N',
                  p_conc_flag         IN  VARCHAR2 DEFAULT 'N',
                  p_user_id           IN  NUMBER   DEFAULT NULL,
                  p_user_resp_id      IN  NUMBER   DEFAULT NULL,
                  p_calling_prog_flag IN  VARCHAR2 DEFAULT 'G',
                  p_confirm_override  IN  VARCHAR2 DEFAULT 'Y',
                  p_return_code       OUT NOCOPY   VARCHAR2,
                  p_unrsv_packet_id   OUT NOCOPY   NUMBER) RETURN BOOLEAN IS


    cursor append_je is
      select 'Associated Generated JEs to be appended or inserted'
        from dual
       where exists
            (
             select 'Associated Generated Row from existing GL Batch'
               from gl_bc_packets bp
              where bp.packet_id = g_packet_id
                and bp.je_batch_id is not null
                and bp.je_batch_id >= 0
                and bp.ussgl_transaction_code is not null
            );

    OTHERS EXCEPTION;
    l_dummy VARCHAR2(100);
     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================
  BEGIN
         l_full_path := g_path || 'gl_confirm_override';

        -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_ledgerid          -> ' || p_ledgerid);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_packetid          -> ' || p_packetid);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_mode              -> ' || p_mode);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_override          -> ' || p_override);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_conc_flag         -> ' || p_conc_flag);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_id           -> ' || p_user_id);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag -> ' || p_calling_prog_flag);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_confirm_override  -> ' || p_confirm_override);
            psa_utils.debug_other_string(g_state_level,l_full_path, ' p_user_resp_id      -> ' || p_user_resp_id);
        -- ========================= FND LOG ===========================

         if p_calling_prog_flag <> 'G' then

            -- =========================== FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' p_calling_prog_flag <> G -> raise others');
            -- ========================= FND LOG =============================

             raise others;
         end if;

         -- Initialize Global Variables
         if not glxfin(p_ledgerid            =>    p_ledgerid,
                        p_packetid           =>    p_packetid,
                         p_mode              =>    p_mode,
                         p_override          =>    p_override,
                         p_conc_flag         =>    p_conc_flag,
                         p_user_id           =>    p_user_id,
                         p_user_resp_id      =>    p_user_resp_id,
                         p_calling_prog_flag =>    p_calling_prog_flag) then

           -- =========================== FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfin --> RETURN FALSE -> goto fatal_error');
              -- ========================= FND LOG =============================

           goto fatal_error;
        end if;

    -- Override Transactions
    if (g_override_flag) and (p_confirm_override = 'Y') then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_override_flag --> TRUE ');
       -- ========================= FND LOG =============================

      if not glxfor then
         -- =========================== FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfor --> RETURN FALSE -> goto fatal_error');
         -- ========================= FND LOG =============================
        goto fatal_error;
      end if;

    else
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' g_override_flag --> FALSE ');
       -- ========================= FND LOG =============================
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glxcon ');
    -- ========================= FND LOG =============================

    open append_je;
    fetch append_je into l_dummy;
    if (append_je%found) then
       g_append_je_flag := true;
    else
       g_append_je_flag := false;
    end if;
    close append_je;

    -- Set Result Codes, Return Code, Append Journal Logic
    if not glxcon then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxcon --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================
       goto fatal_error;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Calling glrchk ');
    -- ========================= FND LOG =============================

    if not glrchk('X') then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glrchk(X) --> RETURN FALSE -> goto fatal_error');
       -- ========================= FND LOG =============================
      goto fatal_error;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' p_return_code = g_return_code --> ' || g_return_code);
    -- ========================= FND LOG =============================

    p_return_code := g_return_code;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN --> TRUE ');
    -- ========================= FND LOG =============================

       IF (p_mode = 'U' AND NOT g_requery_flag) THEN
        p_unrsv_packet_id := p_packetid;
        -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path, ' p_unrsv_packet_id --> ' ||  p_unrsv_packet_id );
            -- ========================= FND LOG ===========================
    END IF;

    -- If g_requery_flag is TRUE set p_return_code = "Q"
    -- for calling form (MJE) to requery instead of the
    -- regular commit. [p_return code "Q" => Success/Advisory]

    IF g_requery_flag THEN
       p_return_code := 'Q';
       -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' p_return_code --> Q => Success/Advisory ');
           -- ========================= FND LOG ===========================
    END IF;

       -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' Return -> True');
       -- ========================= FND LOG ===========================

    return(TRUE);

    <<fatal_error>>

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Reached FATAL ERROR LABEL ');
    -- ========================= FND LOG =============================

    if not glxfuf then
       -- =========================== FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path, ' glxfuf --> RETURN FALSE -> RAISE OTHERS');
       -- ========================= FND LOG =============================
      raise others;
    end if;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' RETURN -> FALSE ');
    -- ========================= FND LOG =============================

    g_debug := g_debug||' GL_CONFIRM_OVERRIDE Failed';
    return(FALSE);

  EXCEPTION

    WHEN OTHERS THEN
      -- =========================== FND LOG ===========================
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
         psa_utils.debug_other_string(g_excep_level,l_full_path, ' RETURN -> FALSE ');
      -- ========================= FND LOG =============================

      message_token('PROCEDURE', 'Funds Checker');
      message_token('EVENT', SQLERRM);
      add_message('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         g_debug := g_debug||' GL_CONFIRM_OVERRIDE Failed : '||SQLERRM;
      return(FALSE);

  END gl_confirm_override;


 /*=======================================================================+
  | Function    : OPTIMIZE_PACKETS                                        |
  | Description : Invoked by bc_optimizer rountine. This acts as a pvt    |
  |               function. Function deletes rows from gl_bc_packets and  |
  |               inserts them in gl_bc_packets_hists. Only rows with     |
  |               status_code R, S, F, T, P, C are deleted.               |
  +=======================================================================*/

  PROCEDURE optimize_packets (p_ledger_id IN NUMBER, p_purge_days IN NUMBER) IS
    l_full_path VARCHAR2(100);
  BEGIN
    l_full_path := g_path||'Optimize_Packets';

     /*-----------------------------------------------------------------------+
       | New criteria for deleting rows from gl_bc_packets is as below:       |
       |                                                                      |
       | Status_Code:                                                         |
       | ===========                                                          |
       | R, S, F, T - All rows for the p_ledger_id                            |
       |            - These rows should get inserted in gl_bc_packets_hists   |
       |                                                                      |
       | P, C       - All rows for the p_ledger_id for which session has      |
       |              expired or which are older than 5 days (120 hours)      |
       |            - These rows should not be stored in gl_bc_packets_hists  |
       |                                                                      |
       +----------------------------------------------------------------------*/


      DELETE from gl_bc_packets Q
      where
                Q.status_code      IN ('P', 'C')
                and ((((sysdate - Q.last_update_date)*24) > 48) OR
                              (NOT EXISTS (SELECT 'x'
                                               FROM v$session
                                               WHERE audsid = Q.session_id
                                               and   Serial# = Q.serial_id)));

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete gl_bc_packets 1 deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================


      DELETE from gl_bc_packets Q
      where
               Q.ledger_id  = p_ledger_id
        and    Q.status_code     in ('R','S','F', 'T') returning
                 PACKET_ID,
                 LEDGER_ID,
                 JE_SOURCE_NAME,
                 JE_CATEGORY_NAME,
                 CODE_COMBINATION_ID,
                 ACTUAL_FLAG,
                 PERIOD_NAME,
                 PERIOD_YEAR,
                 PERIOD_NUM,
                 QUARTER_NUM,
                 CURRENCY_CODE,
                 STATUS_CODE,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 BUDGET_VERSION_ID,
                 ENCUMBRANCE_TYPE_ID,
                 TEMPLATE_ID,
                 ENTERED_DR,
                 ENTERED_CR,
                 ACCOUNTED_DR,
                 ACCOUNTED_CR,
                 USSGL_TRANSACTION_CODE,
                 ORIGINATING_ROWID,
                 ACCOUNT_SEGMENT_VALUE,
                 AUTOMATIC_ENCUMBRANCE_FLAG,
                 FUNDING_BUDGET_VERSION_ID,
                 FUNDS_CHECK_LEVEL_CODE,
                 AMOUNT_TYPE,
                 BOUNDARY_CODE,
                 TOLERANCE_PERCENTAGE,
                 TOLERANCE_AMOUNT,
                 OVERRIDE_AMOUNT,
                 DR_CR_CODE,
                 ACCOUNT_TYPE,
                 ACCOUNT_CATEGORY_CODE,
                 EFFECT_ON_FUNDS_CODE,
                 RESULT_CODE,
                 BUDGET_POSTED_BALANCE,
                 ACTUAL_POSTED_BALANCE,
                 ENCUMBRANCE_POSTED_BALANCE,
                 BUDGET_APPROVED_BALANCE,
                 ACTUAL_APPROVED_BALANCE,
                 ENCUMBRANCE_APPROVED_BALANCE,
                 BUDGET_PENDING_BALANCE,
                 ACTUAL_PENDING_BALANCE,
                 ENCUMBRANCE_PENDING_BALANCE,
                 REFERENCE1,
                 REFERENCE2,
                 REFERENCE3,
                 REFERENCE4,
                 REFERENCE5,
                 JE_BATCH_NAME,
                 JE_BATCH_ID,
                 JE_HEADER_ID,
                 JE_LINE_NUM,
                 JE_LINE_DESCRIPTION,
                 REFERENCE6,
                 REFERENCE7,
                 REFERENCE8,
                 REFERENCE9,
                 REFERENCE10,
                 REFERENCE11,
                 REFERENCE12,
                 REFERENCE13,
                 REFERENCE14,
                 REFERENCE15,
                 REQUEST_ID,
                 USSGL_PARENT_ID,
                 USSGL_LINK_TO_PARENT_ID,
                 EVENT_ID,
                 AE_HEADER_ID,
                 AE_LINE_NUM,
                 BC_DATE,
                 SOURCE_DISTRIBUTION_TYPE,
                 SOURCE_DISTRIBUTION_ID_CHAR_1,
                 SOURCE_DISTRIBUTION_ID_CHAR_2,
                 SOURCE_DISTRIBUTION_ID_CHAR_3,
                 SOURCE_DISTRIBUTION_ID_CHAR_4,
                 SOURCE_DISTRIBUTION_ID_CHAR_5,
                 SOURCE_DISTRIBUTION_ID_NUM_1,
                 SOURCE_DISTRIBUTION_ID_NUM_2,
                 SOURCE_DISTRIBUTION_ID_NUM_3,
                 SOURCE_DISTRIBUTION_ID_NUM_4,
                 SOURCE_DISTRIBUTION_ID_NUM_5,
                 SESSION_ID,
                 SERIAL_ID,
                 APPLICATION_ID,
                 ENTITY_ID,
                 GROUP_ID
      bulk collect into g_bc_pkts_hist;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete gl_bc_packets 2 deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================


      FORALL i IN 1..g_bc_pkts_hist.count
      insert into gl_bc_packets_hists
      values g_bc_pkts_hist(i);

      if p_purge_days > 0 then

        DELETE from psa_bc_accounting_errors
            where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_bc_accounting_errors deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

        DELETE from psa_xla_validation_lines_logs
             where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_xla_validation_lines_logs deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

        DELETE from psa_xla_events_logs
             where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_xla_events_logs deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

        DELETE from psa_xla_ae_lines_logs
             where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_xla_ae_lines_logs deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

        DELETE from psa_xla_ae_headers_logs
             where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_xla_ae_header_logs deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

    -- ========================= FND LOG =============================

        DELETE from psa_xla_dist_links_logs
             where (sysdate - creation_date) >= p_purge_days;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete psa_xla_dist_links_logs deleted ' || SQL%ROWCOUNT || ' rows');
    -- ========================= FND LOG =============================

    end if;

  END optimize_packets;


 /*=======================================================================+
  | Function    : BC_OPTIMIZER                                            |
  | Description : Invoked by SRS "Budgetary Control Optimizer"            |
  |               Optimize     GL_BC_PACKETS DATA                         |
  |               Delete unprocessed payables BC events                   |
  |               Delete processed orphan payables BC events              |
  +=======================================================================*/

  PROCEDURE bc_optimizer (err_buf           OUT NOCOPY VARCHAR2,
                          ret_code          OUT NOCOPY VARCHAR2,
                          p_ledger_id        IN NUMBER,
                          p_purge_days       IN NUMBER,
                          p_delete_mode      IN VARCHAR2) IS

  p_init_msg_list varchar2(1);
  l_r12_upgrade_date  date;
  p_calling_sequence varchar2(50);
  p_return_status varchar2(2);
  p_msg_count number;
  p_msg_data varchar2(50);
  l_path_name varchar2(500):= 'BC_Optimizer';


  BEGIN

    psa_utils.debug_other_string(g_state_level,l_path_name,'p_ledger_id = '||p_ledger_id);
    psa_utils.debug_other_string(g_state_level,l_path_name,'p_purge_days = '||p_purge_days);
    psa_utils.debug_other_string(g_state_level,l_path_name,'p_delete_mode = '||p_delete_mode);
    IF (NVL(p_delete_mode, 'B') IN ('B', 'P')) THEN
      optimize_packets(p_ledger_id, p_purge_days);
      psa_utils.debug_other_string(g_state_level,l_path_name,'Successfully optimized the gl_bc_packets data');
    END IF;

    IF (NVL(p_delete_mode, 'B') IN ('B', 'E')) THEN
      BEGIN
        -- R12 upgrade date fetch to delete all unprocessed events from R12 installation date to sysdate
        psa_utils.debug_other_string(g_state_level,l_path_name,'Fetch PSA: R12 Upgrade Date profile value');
        l_r12_upgrade_date :=to_date( Fnd_Profile.Value_Wnps('PSA_R12_UPGRADE_DATE'), 'MM/DD/YYYY HH24:MI:SS');  -- fetch the profile value

        psa_utils.debug_other_string(g_state_level,l_path_name,'Before calling delete_events');
        PSA_AP_BC_PVT.delete_events(
    		p_init_msg_list => 'F',
	    	p_ledger_id => p_ledger_id,
    		p_start_date => l_r12_upgrade_date,
    		p_end_date => sysdate,
    		p_calling_sequence => 'psa_funds_cecker_pkg.bc_optimizer',
    		x_return_status => p_return_status,
    		x_msg_count =>p_msg_count,
    		x_msg_data => p_msg_data);

        psa_utils.debug_other_string(g_state_level,l_path_name,'After calling delete_events');
      EXCEPTION
        WHEN others THEN
            psa_utils.debug_other_string(g_state_level,l_path_name,'Inside delete_event exception: '||SQLERRM);
            NULL;
     END;

      BEGIN
          psa_utils.debug_other_string(g_state_level,l_path_name,'Before calling delete_processed_orphan_events');
          psa_ap_bc_pvt.delete_processed_orphan_events
            ( p_init_msg_list => 'F',
              p_ledger_id => p_ledger_id,
              p_calling_sequence => 'psa_funds_cecker_pkg.bc_optimizer',
              p_return_status => p_return_status,
              p_msg_count =>p_msg_count,
              p_msg_data => p_msg_data);

 	      psa_utils.debug_other_string(g_state_level,l_path_name,'After calling delete_processed_orphan_events');
      EXCEPTION
        WHEN others THEN
            psa_utils.debug_other_string(g_state_level,l_path_name,'Inside delete_processed_orphan_events exception: '||SQLERRM);
            NULL;
      END;
    END IF;
    COMMIT;
  END bc_optimizer;


 /*=======================================================================+
  | Function    : BC_PURGE_HIST                                           |
  | Description : Invoked by SRS "Budgetary Control History Purge"        |
  |               Deletes rows from gl_bc_packets_hists depending upon    |
  |               the criteria selected by user while running SRS         |
  +=======================================================================*/

  PROCEDURE bc_purge_hist (err_buf           OUT NOCOPY VARCHAR2,
                           ret_code          OUT NOCOPY VARCHAR2,
                           p_ledger_id       IN NUMBER,
                           p_purge_mode      IN VARCHAR2,
                           p_purge_statuses  IN VARCHAR2,
                           p_purge_date      IN VARCHAR2) IS

    l_stmt        VARCHAR2(5000);
    l_status_code VARCHAR2(50);
    l_purge_date  DATE;
    l_full_path VARCHAR2(100);
  BEGIN
     l_full_path := g_path||'Bc_Purge_Hist';

     optimize_packets(p_ledger_id, 0);

     l_purge_date := TO_DATE(p_purge_date, 'YYYY/MM/DD HH24:MI:SS');

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_purge_date -> ' || TO_CHAR(l_purge_date, 'DD-MON-YYYY HH24:MI:SS'));
    -- ========================= FND LOG =============================


     l_stmt := 'delete from gl_bc_packets_hists '||
               'where (last_update_date < :purge_date) '||
               '  and ledger_id = :p_ledger_id ';

     l_status_code := CASE p_purge_mode||p_purge_statuses
                      WHEN 'CP' THEN '''S'''
                      WHEN 'CF' THEN '''F'''
                      WHEN 'CE' THEN '''T'''
                      WHEN 'CA' THEN '''S'', ''F'', ''T'''
                      WHEN 'RP' THEN '''A'''
                      WHEN 'RF' THEN '''R'''
                      WHEN 'RE' THEN '''T'''
                      WHEN 'RA' THEN '''A'', ''R'', ''T'''
                      WHEN 'AP' THEN '''S'', ''A'''
                      WHEN 'AF' THEN '''F'', ''R'''
                      WHEN 'AE' THEN '''T'''
                      WHEN 'AA' THEN '''S'', ''F'', ''A'', ''R'', ''T'''
                      END;

     l_stmt := l_stmt ||'and status_code IN ('||l_status_code||')';

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_stmt -> ' || l_stmt);
    -- ========================= FND LOG =============================


     execute immediate l_stmt using l_purge_date, p_ledger_id;

     commit;

  END bc_purge_hist;

   /*=======================================================================+
  | Function    : GET_PACKET_ID                                           |
  | Description : Returns the next packet_id using gl_bc_packets_s seq    |
  +=======================================================================*/

  FUNCTION get_packet_id RETURN NUMBER IS
    l_pkt_id gl_bc_packets.packet_id%type;
    l_full_path VARCHAR2(100);
  BEGIN

    l_full_path := g_path||'Get_Packet_Id';

    select gl_bc_packets_s.nextval into l_pkt_id
    from dual;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' l_pkt_id -> ' || l_pkt_id);
    -- ========================= FND LOG =============================

    return l_pkt_id;
  END get_packet_id;

   /*=======================================================================+
  | Function    : POPULATE_BC_PKTS                                        |
  | Description : Inserts data in gl_bc_packets using the plsql table     |
  |               passed as parameter. Commits in autonomous mode.        |
  +=======================================================================*/

  FUNCTION populate_bc_pkts  (p_bc_pkts IN BC_PKTS_REC) RETURN BOOLEAN IS

     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================
     pragma autonomous_transaction;

  BEGIN

     l_full_path := g_path||'Populate_Bc_pkts';

     -- Now that plsql table is  populated, insert data in gl_bc_packets.

     FORALL i IN 1..p_bc_pkts.count
        INSERT INTO gl_bc_packets
        VALUES p_bc_pkts(i);

    commit;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       psa_utils.debug_other_string(g_excep_level,l_full_path, ' BCTRL -> '||sqlerrm);
       rollback;
       RETURN FALSE;

  END populate_bc_pkts;


 /*=======================================================================+
  | Procedure   : GLXFMA                                                  |
  | Description : Invoked by Concurrent Program for Mass Funds Check,     |
  |               Reserve etc. Upgraded from 11i.                         |
  +=======================================================================*/
  PROCEDURE glxfma ( err_buf           OUT NOCOPY VARCHAR2,
                     ret_code          OUT NOCOPY VARCHAR2,
                     p_ledger_id       IN NUMBER,
                     p_check_flag      IN VARCHAR2,
                     p_autopost_set_id IN NUMBER) IS
        CURSOR sel1 is

                SELECT
                        B.actual_flag,
                        H.je_source,
                        B.default_period_name,
                        B.je_batch_id,
                        substrb(B.name,1,88)
                FROM
                        gl_je_headers H,
                        gl_je_batches B,
                        gl_automatic_posting_options O,
                        gl_automatic_posting_sets S
                WHERE
                         S.autopost_set_id = p_autopost_set_id
                AND      S.autopost_set_id = O.autopost_set_id
                AND      o.ledger_id = H.ledger_id
                AND      B.actual_flag = decode(O.actual_flag,
                              'L', B.actual_flag,
                               O.actual_flag)
                AND      B.default_period_name = decode(O.period_name,
                              'ALL', B.default_period_name,
                               O.period_name)
                AND      B.je_batch_id = H.je_batch_id
                AND      H.je_source = decode(O.je_source_name,
                              'ALL', H.je_source,
                               O.je_source_name)
                AND      B.status = 'U'
                AND      B.budgetary_control_status in ('R', 'F')
                AND      NOT EXISTS
                       ( SELECT 'Not all category match'
                         FROM   GL_JE_HEADERS H2
                         WHERE
                                H2.je_batch_id = B.je_batch_id
                         AND    H2.je_category <> decode(O.je_category_name,
                                      'ALL', H2.je_category,
                                      O.je_category_name) )
                AND      NOT EXISTS
                       ( SELECT 'Untaxed Journals'
                         FROM   GL_JE_HEADERS GLH
                         WHERE  GLH.tax_status_code = 'R'
                         AND    GLH.je_batch_id = B.je_batch_id
                         AND    B.actual_flag = 'A'
                         AND    GLH.currency_code <> 'STAT'
                         AND    GLH.je_source = 'Manual' )
                GROUP BY B.je_batch_id, B.actual_flag,
                         B.default_period_name,B.name,H.je_source
                ORDER BY B.default_period_name,B.actual_flag;

        CURSOR sel2 is

                SELECT
                        b.actual_flag,
                        h.je_source,
                        b.default_period_name,
                        b.je_batch_id,
                        substrb(b.name,1,88)
                FROM
                        gl_je_headers h,
                        gl_je_batches b,
                        gl_automatic_posting_options o,
                        gl_automatic_posting_sets s
                WHERE
                         s.autopost_set_id = p_autopost_set_id
                AND      s.autopost_set_id = o.autopost_set_id
                AND      o.ledger_id = H.ledger_id
                AND      b.actual_flag = decode(o.actual_flag,
                                   'L', b.actual_flag,
                                    o.actual_flag)
                AND      b.default_period_name = decode(o.period_name,
                                   'ALL', b.default_period_name,
                                    o.period_name)
                AND      b.je_batch_id = h.je_batch_id
                AND      h.je_source = decode(o.je_source_name,
                                   'ALL', h.je_source,
                                    o.je_source_name)
                AND      b.status = 'U'
                AND      b.budgetary_control_status in ('R', 'F')
                AND      NOT EXISTS
                           ( SELECT 'Not all category match'
                             FROM   gl_je_headers h2
                             WHERE
                                    h2.je_batch_id = b.je_batch_id
                             AND    h2.je_category <> decode(o.je_category_name,
                                          'ALL', h2.je_category,
                                           o.je_category_name) )
                GROUP BY b.je_batch_id, b.actual_flag,
                         b.default_period_name,b.name,h.je_source
                ORDER BY b.default_period_name,b.actual_flag;

        CURSOR c_seg_info (p_ledger_id NUMBER) IS

                SELECT
                        application_column_name
                FROM
                        fnd_id_flex_segments
                WHERE
                        id_flex_num = (SELECT
                                        chart_of_accounts_id
                                        FROM gl_ledgers
                                        WHERE ledger_id = p_ledger_id)
                AND     id_flex_code = 'GL#'
                AND     application_id = 101
                AND     enabled_flag = 'Y';

        TYPE je_ref_cursor IS REF CURSOR;
        l_je_lines                  je_ref_cursor;
        l_je_sum_lines              je_ref_cursor;
        l_je_bud_lines              je_ref_cursor;

        l_full_path VARCHAR2(100);
        l_bc_pkts                   bc_pkts_rec;
        l_bc_pkts_cnt               number;
        l_tmp_bc_pkts               bc_pkts_rec;
        l_failed_bc_pkts            bc_pkts_rec;
        l_failed_bc_pkts_cnt        number;
        l_sob_name                  gl_sets_of_books.name%TYPE;
        l_budgetary_control_flag    gl_sets_of_books.enable_budgetary_control_flag%TYPE;
        l_automatic_tax_flag        gl_sets_of_books.enable_automatic_tax_flag%TYPE;
        l_coa_id                    gl_sets_of_books.chart_of_accounts_id%TYPE;
        l_currency_code             gl_sets_of_books.currency_code%TYPE;
        l_autopost_set_name         gl_automatic_posting_sets.autopost_set_name%TYPE;
        l_appl_id                   fnd_application.application_id%TYPE;
        l_resp_id                   fnd_responsibility.responsibility_id%TYPE;
        l_user_id                   fnd_user.user_id%TYPE;
        l_actual_flag               gl_je_batches.actual_flag%TYPE;
        l_source_name               gl_je_headers.je_source%TYPE;
        l_period_name               gl_je_batches.default_period_name%TYPE;
        l_je_batch_id               gl_je_batches.je_batch_id%TYPE;
        l_batch_name                gl_je_batches.name%TYPE;
        l_packet_id                 gl_bc_packets.packet_id%TYPE;
        l_main_stmt                 varchar2(4000);
        l_tmp_stmt                  varchar2(4000);
        l_action_stmt               varchar2(4000);
        l_je_stmt                   varchar2(4000);
        l_bc_not_enabled_msg        varchar2(250);
        l_msg2                      varchar2(250);
        l_check_flag                varchar2(10);
        l_glxfck_return_status      boolean;
        l_glxfck_return_code        varchar2(10);
        l_calling_prog_flag         varchar2(10);
        l_fmeaning                  varchar2(50);
        l_jmeaning                  varchar2(50);
        l_date                      varchar2(50);
        l_header                    boolean;
        l_je_first                  boolean;
        l_ledger_id                 gl_automatic_posting_options.ledger_id%TYPE;
        l_session_id                gl_bc_packets.session_id%type;
        l_serial_id                 gl_bc_packets.serial_id%type;
        l_seg_ccid                  varchar2(200);
        l_je_header_name            gl_je_headers.name%TYPE;
        l_je_header_id              gl_je_headers.je_header_id%TYPE;
        l_je_line_num               gl_je_lines.je_line_num%TYPE;
        l_entered_dr                gl_je_lines.entered_dr%TYPE;
        l_entered_cr                gl_je_lines.entered_cr%TYPE;
        l_line_description          gl_lookups.description%TYPE;
        l_line_result_code          gl_bc_packets.result_code%TYPE;
        l_ccid                      gl_je_lines.code_combination_id%TYPE;
        l_rowid                     varchar2(100);
        l_priority                  gl_lookups.meaning%TYPE;
        l_je_seg_stmt               varchar2(4000);
        l_je_sum_flex               varchar2(4000);
        l_je_bud_stmt               varchar2(4000);
        l_je_bud_flex               varchar2(4000);
        l_je_bud_dr                 gl_bc_packets.entered_dr%TYPE;
        l_je_bud_cr                 gl_bc_packets.entered_cr%TYPE;
        l_je_bud_result_code        gl_bc_packets.result_code%TYPE;
        l_je_bud_desc               gl_lookups.description%TYPE;
        l_je_bud_ccid               gl_code_combinations.code_combination_id%TYPE;
        l_ussgl_parent_id           gl_bc_packets.ussgl_parent_id%TYPE;
        l_je_bud_seg_stmt           varchar2(4000);
        l_je_bud_sum_flex           varchar2(4000);

        -- XML variables
        l_xml_b_header              boolean;
        l_application_name          varchar2(300);
        l_report_name               varchar2(300);
        l_funds_action              varchar2(300);
        l_failure_warning           varchar2(500);
        l_xml_je_lines_header       boolean;
        l_xml_f_b_header            boolean;
        l_xml_f_l_header            boolean;
        l_xml_f_sum_header          boolean;
        l_xml_f_bud_header          boolean;
        l_xml_f_bud_sum_header      boolean;

   BEGIN

        l_full_path  := g_path || 'glxfma';
        l_check_flag := p_check_flag;
        l_ledger_id  := p_ledger_id;

        --Get the Application Name
        FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0031');
        l_application_name := FND_MESSAGE.GET();

        --Get the Report Name
        FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0030');
        l_report_name := FND_MESSAGE.GET();

        --Get the Funds Action
        IF (l_check_flag = 'C' OR l_check_flag = 'M') THEN
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0032');
        ELSIF (l_check_flag = 'R' OR l_check_flag = 'P') THEN
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0033');
        ELSE
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0032');
        END IF;
        l_funds_action := FND_MESSAGE.GET();

        --Get the Failure/Warning message
        IF (l_check_flag = 'C' OR l_check_flag = 'M') THEN
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0035');
        ELSIF (l_check_flag = 'R' OR l_check_flag = 'P') THEN
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0036');
        ELSE
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0035');
        END IF;
        l_failure_warning := FND_MESSAGE.GET();

        --Picking the date from the database
        SELECT
                TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')
        INTO
                l_date
        FROM
                dual;

        --The xml reporting variables.
        l_header               := true;
        l_xml_f_b_header       := true;
        l_xml_f_l_header       := true;
        l_xml_je_lines_header  := true;
        l_xml_b_header         := true;
        l_xml_f_sum_header     := true;
        l_xml_f_bud_header     := true;
        l_xml_f_bud_sum_header := true;

        --Start of xml report output
        -- =========================== XML OUT =============================
        fnd_file.put_line(fnd_file.output, '<?xml version = ''1.0'' encoding = ''ISO-8859-1''?>');
        fnd_file.put_line(fnd_file.output, '<REPORT_ROOT>');
        fnd_file.put_line(fnd_file.output, '    <PARAMETERS>');
        fnd_file.put_line(fnd_file.output, '    <APPLICATION_NAME>'||l_application_name||'</APPLICATION_NAME>');
        fnd_file.put_line(fnd_file.output, '    <REPORT_NAME>'||l_report_name||'</REPORT_NAME>');
        fnd_file.put_line(fnd_file.output, '    <DATE>'||l_date||'</DATE>');
        fnd_file.put_line(fnd_file.output, '    <FUNDS_ACTION>'||l_funds_action||'</FUNDS_ACTION>');
        fnd_file.put_line(fnd_file.output, '    </PARAMETERS>');
        -- =========================== XML OUT =============================

        BEGIN
                SELECT
                        name,
                        enable_budgetary_control_flag,
                        enable_automatic_tax_flag,
                        chart_of_accounts_id,
                        currency_code
                INTO
                        l_sob_name,
                        l_budgetary_control_flag,
                        l_automatic_tax_flag,
                        l_coa_id,
                        l_currency_code
                FROM
                        gl_sets_of_books
                WHERE
                        set_of_books_id = p_ledger_id;
        EXCEPTION
                WHEN OTHERS THEN
                    -- =========================== FND LOG ===========================
                       fnd_file.put_line(fnd_file.log, 'Funds C/R: Failed to fetch data from gl_sets_of_books');
                       psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                        'Funds C/R: Failed to fetch data from gl_sets_of_books');
                    -- ========================= FND LOG =============================
        END;

        -- =========================== FND LOG ===========================
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_sob_name               -> '||l_sob_name);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_budgetary_control_flag -> '||l_budgetary_control_flag);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_automatic_tax_flag     -> '||l_automatic_tax_flag);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_coa_id                 -> '||l_coa_id);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_currency_code          -> '||l_currency_code);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_check_flag             -> '||l_check_flag);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_sob_name               -> '||l_sob_name);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_budgetary_control_flag -> '||l_budgetary_control_flag);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_automatic_tax_flag     -> '||l_automatic_tax_flag);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_coa_id                 -> '||l_coa_id);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_currency_code          -> '||l_currency_code);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_check_flag             -> '||l_check_flag);
        -- =========================== FND LOG =============================

        IF (l_budgetary_control_flag = 'N') THEN
                FND_MESSAGE.SET_NAME('PSA', 'R_FCMA0037');
                l_bc_not_enabled_msg := FND_MESSAGE.GET();
                -- =========================== FND LOG ===========================
                psa_utils.debug_other_string(g_state_level, l_full_path,
                                                'Funds C/R: l_budgetary_control_flag -> '||l_budgetary_control_flag); --Need to finalize the debug level
                fnd_file.put_line(fnd_file.log, 'Funds C/R: '||l_bc_not_enabled_msg);
                -- ========================= FND LOG =============================

                -- =========================== XML OUT =============================
                fnd_file.put_line(fnd_file.output, '<BC_NOT_ENABLED>'||l_bc_not_enabled_msg||'</BC_NOT_ENABLED>');
                -- =========================== XML OUT =============================
                GOTO normal_exit;
        END IF;

        BEGIN
                SELECT
                        autopost_set_name
                INTO
                        l_autopost_set_name
                FROM
                        gl_automatic_posting_sets
                WHERE
                        autopost_set_id = p_autopost_set_id;
        EXCEPTION
                WHEN OTHERS THEN
                    -- =========================== FND LOG ===========================
                       psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                        'Funds C/R: Failed to fetch autopost_set_name from gl_automatic_posting_sets');
                       fnd_file.put_line(fnd_file.log,  'Funds C/R: Failed to fetch autopost_set_name from gl_automatic_posting_sets');
                    -- ========================= FND LOG =============================
        END;

        l_appl_id := 101;
        l_resp_id := FND_GLOBAL.resp_id;
        l_user_id := FND_GLOBAL.user_id;

        -- =========================== FND LOG ===========================
        fnd_file.put_line(fnd_file.log, 'Funds C/R: p_autopost_set_id   -> '||p_autopost_set_id);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_autopost_set_name -> '||l_autopost_set_name);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_appl_id           -> '||l_appl_id);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_resp_id           -> '||l_resp_id);
        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_user_id           -> '||l_user_id);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: p_autopost_set_id   -> '||p_autopost_set_id);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_autopost_set_name -> '||l_autopost_set_name);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_appl_id           -> '||l_appl_id);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_resp_id           -> '||l_resp_id);
        psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_user_id           -> '||l_user_id);
        -- =========================== FND LOG =============================

        IF (l_automatic_tax_flag = 'Y') AND (p_check_flag = 'R') THEN

                OPEN sel1;
        ELSE
                OPEN sel2;

        END IF;

        l_bc_pkts            := bc_pkts_rec();
        l_bc_pkts_cnt        := 0;
        l_failed_bc_pkts     := bc_pkts_rec();
        l_failed_bc_pkts_cnt := 0;

        LOOP
                IF sel1%ISOPEN THEN

                        FETCH
                                sel1
                        INTO
                                l_actual_flag,
                                l_source_name,
                                l_period_name,
                                l_je_batch_id,
                                l_batch_name;

                        EXIT WHEN sel1%NOTFOUND;

                ELSIF sel2%ISOPEN THEN

                        FETCH
                                sel2
                        INTO
                                l_actual_flag,
                                l_source_name,
                                l_period_name,
                                l_je_batch_id,
                                l_batch_name;

                        EXIT WHEN sel2%NOTFOUND;

                END IF;

                l_packet_id := get_packet_id;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: -------------------------------');
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_period_name -> '||l_period_name);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_actual_flag -> '||l_actual_flag);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_batch_id -> '||l_je_batch_id);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_packet_id   -> '||l_packet_id);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_batch_name  -> '||l_batch_name);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_source_name -> '||l_source_name);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: -------------------------------');
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_period_name -> '||l_period_name);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_actual_flag -> '||l_actual_flag);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_je_batch_id -> '||l_je_batch_id);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_packet_id   -> '||l_packet_id);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_batch_name  -> '||l_batch_name);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_source_name -> '||l_source_name);
                -- =========================== FND LOG =============================

                -- =========================== XML OUT =============================
                IF (l_xml_b_header <> FALSE) THEN
                        fnd_file.put_line(fnd_file.output, '    <LIST_G_JE_BATCH_NAME>');
                        l_xml_b_header := FALSE;
                END IF;
                -- =========================== XML OUT =============================


                -- Get the session_id and serial# for the current session
                -- These columns will then be inserted in gl_bc_packets.

                -- ====== FND LOG ======
                psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Invoking get_session_details() ');
                -- ====== FND LOG ======

                get_session_details(l_session_id, l_serial_id);

                -- ====== FND LOG ======
                psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Session_Id = '||l_session_id);
                psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Serial_Id = '||l_serial_id);
                -- ====== FND LOG ======

                l_main_stmt := '';

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_main_stmt -> '||l_main_stmt);
                psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: l_main_stmt -> '||l_main_stmt);
                -- =========================== FND LOG =============================

                l_tmp_stmt := 'SELECT '||
                                        l_packet_id||', '||
                                        l_ledger_id||', '||''''||
                                        l_source_name||''''||
                                        ', h.je_category'||
                                        ', l.code_combination_id, '||''''||
                                        l_actual_flag|| ''''||
                                        ', ps.period_name, ps.period_year, ps.period_num, ps.quarter_num, '||
                                        'h.currency_code, decode('||''''||l_check_flag||''''||',''C'',''C'',''M'',''C'',''P'',''P'',''R'',''P''), sysdate, '||
                                        l_user_id;

                l_action_stmt:= CASE l_actual_flag
                                WHEN 'B' THEN ', h.budget_version_id, NULL, NULL'
                                WHEN 'E' THEN ', NULL, h.encumbrance_type_id, NULL'
                                WHEN 'A' THEN ', NULL, NULL, NULL'
                                END;
                l_tmp_stmt := l_tmp_stmt || l_action_stmt;

                l_tmp_stmt := l_tmp_stmt || ', nvl(l.entered_dr, 0), nvl(l.entered_cr, 0), nvl(l.accounted_dr, 0), nvl(l.accounted_cr, 0), '||
                                            'l.ussgl_transaction_code, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||''''||
                                            l_batch_name||''''||', '||
                                            l_je_batch_id||
                                            ', l.je_header_id, l.je_line_num, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||
                                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '||
                                            l_session_id||', '||l_serial_id||', '||l_appl_id||', '||
                                            'NULL, NULL';

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_tmp_stmt -> '||l_tmp_stmt);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_tmp_stmt -> '||l_tmp_stmt);
                -- =========================== FND LOG =============================

                l_tmp_stmt  := l_tmp_stmt || ' FROM gl_je_lines l, gl_je_headers h, ';

                IF (l_actual_flag = 'B') THEN
                        l_tmp_stmt := l_tmp_stmt || 'gl_budget_versions bv, ';
                END IF;

                l_tmp_stmt := l_tmp_stmt || ' gl_period_statuses ps WHERE ps.application_id = '||l_appl_id||
                                            ' AND ps.ledger_id = '||l_ledger_id ||
                                            ' AND ps.period_name = '||''''||l_period_name||''''||' AND h.je_batch_id = '||l_je_batch_id ||
                                            ' AND l.je_header_id = h.je_header_id';

                l_action_stmt:= CASE l_actual_flag
                                WHEN 'B' THEN ' AND h.budget_version_id = bv.budget_version_id AND bv.status = ''O'''
                                WHEN 'E' THEN ' AND (ps.closing_status = ''O'' OR ps.closing_status = ''F'')'
                                WHEN 'A' THEN ''
                                END;

                l_tmp_stmt := l_tmp_stmt || l_action_stmt;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_tmp_stmt -> '||l_tmp_stmt);
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_tmp_stmt -> '||l_tmp_stmt);
                -- =========================== FND LOG =============================

                l_main_stmt := l_main_stmt || l_tmp_stmt;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_main_stmt -> '||l_main_stmt);
                fnd_file.put_line(fnd_file.log, 'Funds C/R: Executing l_main_stmt -> '||l_main_stmt||' using EXECUTE IMMEDIATE');
                psa_utils.debug_other_string(g_state_level, l_full_path, 'Funds C/R: l_main_stmt -> '||l_main_stmt);
                psa_utils.debug_other_string(g_state_level, l_full_path,
                                             'Funds C/R: Executing l_main_stmt -> '||l_main_stmt||' using EXECUTE IMMEDIATE');
                -- =========================== FND LOG =============================

                EXECUTE IMMEDIATE l_main_stmt BULK COLLECT INTO l_tmp_bc_pkts;

                l_bc_pkts.extend(l_tmp_bc_pkts.count);

                FOR x in 1..l_tmp_bc_pkts.count
                LOOP
                        l_bc_pkts_cnt := l_bc_pkts_cnt + 1;
                        l_bc_pkts(l_bc_pkts_cnt) := l_tmp_bc_pkts(x);

                END LOOP;

        END LOOP; --End of loop for all the batches

        IF NOT populate_bc_pkts (l_bc_pkts) THEN
                -- ====== FND LOG ======
                psa_utils.debug_other_string(g_error_level,l_full_path, 'Funds C/R: BCTRL -> populate_bc_pkts() failed. ');
                psa_utils.debug_other_string(g_error_level,l_full_path, 'Funds C/R: BCTRL -> ERROR: FATAL. ');
                -- ====== FND LOG ======
        END IF;

        -- Invoke funds checker per packet_id

        -- ====== FND LOG ======
        fnd_file.put_line(fnd_file.log, 'Funds C/R: BCTRL -> Invoking glxfck() per packet.');
        psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: BCTRL -> Invoking glxfck() per packet.');
        -- ====== FND LOG ======

        FOR x in 1..l_bc_pkts.count
        LOOP
                IF (x = 1 OR (l_bc_pkts(x).packet_id <> l_bc_pkts(x-1).packet_id)) THEN

                -- ====== FND LOG ======
                fnd_file.put_line(fnd_file.log, 'Funds C/R: BCTRL -> Invoking glxfck() for packet_id '||l_bc_pkts(x).packet_id);
                psa_utils.debug_other_string(g_state_level,l_full_path,
                                         'Funds C/R: BCTRL -> Invoking glxfck() for packet_id '||l_bc_pkts(x).packet_id);
                -- ====== FND LOG ======

                IF NOT glxfck(p_ledgerid           => l_ledger_id,
                              p_packetid           => l_bc_pkts(x).packet_id,
                              p_mode               => l_check_flag,
                              p_override           => 'N',
                              p_conc_flag          => 'Y',
                              p_user_id            => l_user_id,
                              p_user_resp_id       => l_resp_id,
                              p_calling_prog_flag  => 'G',
                              p_return_code        => l_glxfck_return_code) THEN
                        -- ====== FND LOG ======
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: BCTRL -> glxfck() failed ');
                        psa_utils.debug_other_string(g_error_level,l_full_path, 'Funds C/R: BCTRL -> glxfck() failed ');
                        -- ====== FND LOG ======

                        -- ============================== FND LOG =========================
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: BCTRL l_glxfck_return_code -> T ');
                        psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: BCTRL l_glxfck_return_code -> T ');
                        -- ============================== FND LOG =========================

                        l_glxfck_return_code := 'T';

                END IF;


                -- If the return code for this packet is Advisory, Failure, Partial,
                -- Fatal, we insert into failed packets table type.
                IF (l_glxfck_return_code <> 'S') THEN

                        -- ============================== FND LOG =========================
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_glxfck_return_code ->'||l_glxfck_return_code);
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: Inserting into l_failed_bc_pkts for packet_id->'||l_bc_pkts(x).packet_id);
                        psa_utils.debug_other_string(g_state_level,l_full_path,
                                                     'Funds C/R: l_glxfck_return_code ->'||l_glxfck_return_code);
                        psa_utils.debug_other_string(g_state_level,l_full_path,
                                                     'Funds C/R: Inserting into l_failed_bc_pkts for packet_id->'||l_bc_pkts(x).packet_id);
                        -- ============================== FND LOG =========================

                        l_failed_bc_pkts.extend(1);
                        l_failed_bc_pkts_cnt := l_failed_bc_pkts_cnt + 1;
                        l_failed_bc_pkts(l_failed_bc_pkts_cnt) := l_bc_pkts(x);

                END IF;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_glxfck_return_code -> '||l_glxfck_return_code);
                psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: l_glxfck_return_code -> '||l_glxfck_return_code);
                -- =========================== FND LOG =============================
                BEGIN
                        UPDATE
                                gl_je_batches
                        SET
                                budgetary_control_status = decode(l_check_flag, 'R',
                                                                  decode (l_glxfck_return_code,
                                                                          'S', 'P',
                                                                          'A', 'P',
                                                                          'F', 'F',
                                                                          'P', 'F',
                                                                          'T', 'R', l_glxfck_return_code),
                                                                  'P',
                                                                  decode (l_glxfck_return_code,
                                                                          'S', 'P',
                                                                          'A', 'P',
                                                                          'F', 'F',
                                                                          'P', 'F',
                                                                          'T', 'R', l_glxfck_return_code),
                                                                   budgetary_control_status),
                                packet_id = l_bc_pkts(x).packet_id
                        WHERE
                                je_batch_id = l_bc_pkts(x).je_batch_id;
                EXCEPTION
                        WHEN OTHERS THEN
                            -- =========================== FND LOG ===========================
                               psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                                'Funds C/R: Failed to update budgetary_control_status for gl_je_batches');
                               fnd_file.put_line(fnd_file.log,
                                                        'Funds C/R: Failed to update budgetary_control_status for gl_je_batches');
                            -- ========================= FND LOG =============================
                END;

                BEGIN
                        SELECT
                                meaning
                        INTO
                                l_fmeaning
                        FROM
                                gl_lookups
                        WHERE
                                lookup_code = l_glxfck_return_code
                                AND lookup_type = 'FUNDS_CHECK_RETURN_CODE';
                EXCEPTION
                        WHEN OTHERS THEN
                            -- =========================== FND LOG ===========================
                               psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                                'Funds C/R: Failed to fetch meaning from gl_lookups');
                               fnd_file.put_line(fnd_file.log,
                                                        'Funds C/R: Failed to fetch meaning from gl_lookups');
                            -- ========================= FND LOG =============================
                END;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: Return Code F Meaning l_fmeaning -> '||l_fmeaning);
                psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: Return Code F Meaning l_fmeaning -> '||l_fmeaning);
                -- =========================== FND LOG =============================

                BEGIN
                        SELECT
                                l.meaning
                        INTO
                                l_jmeaning
                        FROM
                                gl_lookups l, gl_je_batches b
                        WHERE
                                l.lookup_code = b.budgetary_control_status
                                AND l.lookup_type = 'JE_BATCH_BC_STATUS'
                                AND b.je_batch_id = l_bc_pkts(x).je_batch_id;

                EXCEPTION
                        WHEN OTHERS THEN
                            -- =========================== FND LOG ===========================
                               psa_utils.debug_other_string(g_excep_level,l_full_path,
                                                                'Funds C/R: Failed to fetch meaning from gl_je_batches');
                               fnd_file.put_line(fnd_file.log,
                                                        'Funds C/R: Failed to fetch meaning from gl_be_batches');
                            -- ========================= FND LOG =============================
                END;

                -- =========================== FND LOG ===========================
                fnd_file.put_line(fnd_file.log, 'Funds C/R: Return Code J Meaning l_jmeaning -> '||l_jmeaning);
                psa_utils.debug_other_string(g_state_level,l_full_path, 'Funds C/R: Return Code J Meaning l_jmeaning -> '||l_jmeaning);
                -- =========================== FND LOG =============================

                -- =========================== XML OUT =============================
                        fnd_file.put_line(fnd_file.output, '            <G_JE_BATCH_NAME>');
                        fnd_file.put_line(fnd_file.output, '                    <JE_BATCH_NAME>'||l_bc_pkts(x).je_batch_name||'</JE_BATCH_NAME>');
                        fnd_file.put_line(fnd_file.output, '                    <PERIOD_NAME>'||l_bc_pkts(x).period_name||'</PERIOD_NAME>');
                        fnd_file.put_line(fnd_file.output, '                    <FC_RESULT>'||l_fmeaning||'</FC_RESULT>');
                        fnd_file.put_line(fnd_file.output, '                    <JE_F_STATUS>'||l_jmeaning||'</JE_F_STATUS>');
                        fnd_file.put_line(fnd_file.output, '            </G_JE_BATCH_NAME>');
                -- =========================== XML OUT =============================

                END IF;

        END LOOP; --End of loop for all l_bc_pkts

	-- =========================== XML OUT =============================
	IF (l_xml_b_header <> TRUE) THEN
		fnd_file.put_line(fnd_file.output, '    </LIST_G_JE_BATCH_NAME>');
	END IF;
	-- =========================== XML OUT =============================

        -- =========================== FND LOG ===========================
        fnd_file.put_line(fnd_file.log, 'Funds C/R: -------------------------------');
        -- =========================== FND LOG ===========================

        --Now processing failed batches/packets.
        FOR x in 1..l_failed_bc_pkts.count
        LOOP
                fnd_file.put_line(fnd_file.log, 'Funds C/R: Failed Funds Check Packets Info');
                fnd_file.put_line(fnd_file.log, 'Funds C/R: -------------------------------');
                fnd_file.put_line(fnd_file.log, 'Funds C/R: Packet Id: '||
                                                  l_failed_bc_pkts(x).packet_id||
                                                  ' Batch Id: '||
                                                  l_failed_bc_pkts(x).je_batch_id||
                                                  ' Batch Name: '||l_failed_bc_pkts(x).je_batch_name);


                -- =========================== XML OUT =============================
                IF (l_xml_f_b_header <> FALSE) THEN
                        fnd_file.put_line(fnd_file.output, '    <FAILED_BATCHES_EXIST>YES</FAILED_BATCHES_EXIST>');
                        fnd_file.put_line(fnd_file.output, '    <LIST_G_FAILURE_JE_BATCH_NAME>');
                        l_xml_f_b_header := FALSE;
                END IF;
                -- =========================== XML OUT =============================

                -- =========================== XML OUT =============================
                        fnd_file.put_line(fnd_file.output, '            <G_FAILURE_JE_BATCH_NAME>');
                        fnd_file.put_line(fnd_file.output, '                    <FA_FAILURES_WARNINGS>'||l_failure_warning||'</FA_FAILURES_WARNINGS>');
                        fnd_file.put_line(fnd_file.output, '                    <F_JE_BATCH_NAME>'||l_failed_bc_pkts(x).je_batch_name||'</F_JE_BATCH_NAME>');
                -- =========================== XML OUT =============================


                l_je_stmt := 'SELECT ';
                l_je_first := TRUE;
                FOR a in c_seg_info(l_ledger_id)
                LOOP
                        IF (l_je_first <> FALSE) THEN
                                l_je_stmt := l_je_stmt||'c.'||a.application_column_name;
                                l_je_first := FALSE;
                        ELSE
                                l_je_stmt := l_je_stmt||'||''.''||'||'c.'||a.application_column_name;
                        END IF;

                END LOOP; --End of segments loop

                l_je_stmt := l_je_stmt||', SUBSTRB(h.name,1,20), h.je_header_id, l.je_line_num, l.entered_dr, '||
                                        'l.entered_cr, lk.description, p.result_code, l.code_combination_id, '||
                                        'p.rowid '||
                                        'FROM gl_je_lines l, gl_je_headers h, gl_code_combinations c, '||
                                        'gl_lookups lk, gl_bc_packets p '||
                                        'WHERE p.je_batch_id = '||l_failed_bc_pkts(x).je_batch_id||
                                        ' and p.packet_id = '||l_failed_bc_pkts(x).packet_id||
                                        ' and p.ledger_id = '||l_ledger_id||
                                        ' and p.je_header_id = h.je_header_id'||
                                        ' and h.je_header_id = l.je_header_id'||
                                        ' and p.je_line_num = l.je_line_num'||
                                        ' and p.result_code = lk.lookup_code'||
                                        ' and lk.lookup_type = ''FUNDS_CHECK_RESULT_CODE'''||
                                        ' and p.code_combination_id = c.code_combination_id (+)'||
                                        ' and nvl(p.template_id,-1) = -1'||
                                        ' and p.ussgl_link_to_parent_id is null'||
                                        ' and (p.result_code like ''F%'' or p.result_code like ''P2%'') '||
                                        ' order by l.je_header_id, l.je_line_num';

                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_stmt -> '|| l_je_stmt);

                l_xml_je_lines_header := TRUE;

                OPEN l_je_lines FOR l_je_stmt;

                LOOP
                        FETCH l_je_lines INTO l_seg_ccid, l_je_header_name, l_je_header_id, l_je_line_num, l_entered_dr,
                                              l_entered_cr, l_line_description, l_line_result_code, l_ccid, l_rowid;

                        -- =========================== FND LOG ===========================
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: '|| l_seg_ccid||' '||l_je_header_name||' '||l_je_header_id
                                                        ||' '||l_je_line_num||' '||l_entered_dr||' '||l_entered_cr||
                                                        ' '||l_line_description||' '||l_line_result_code||' '||l_ccid||
                                                        ' '||l_rowid);
                        -- =========================== FND LOG ===========================
                        EXIT WHEN l_je_lines%NOTFOUND;

                        BEGIN
                                SELECT
                                        l.meaning
                                INTO
                                        l_priority
                                FROM
                                        gl_lookups l
                                WHERE
                                        l.lookup_type = 'BC_SEVERITY_FLAG'
                                AND     l.lookup_code = upper(substr(l_line_result_code,1,1));

                        EXCEPTION
                                WHEN OTHERS THEN
                                        -- =========================== FND LOG ===========================
                                        psa_utils.debug_other_string(g_excep_level,l_full_path, 'Funds C/R: Failed to fetch meaning from gl_lookups');
                                        fnd_file.put_line(fnd_file.log, 'Funds C/R: Failed to fetch meaning from gl_lookups');
                                        -- ========================= FND LOG =============================
                        END;


                        -- =========================== FND LOG ===========================
                        fnd_file.put_line(fnd_file.log, 'Funds C/R: '||l_failed_bc_pkts(x).je_batch_name||
                                                        l_je_header_name||' '||l_seg_ccid||' '||
                                                        l_entered_dr||' '||l_entered_cr||
                                                        ' '||l_priority);
                        -- =========================== FND LOG ===========================

                        -- =========================== XML OUT =============================
                        IF (l_xml_je_lines_header <> FALSE) THEN
                                fnd_file.put_line(fnd_file.output, '                    <F_JE_HEADER_NAME>'||l_je_header_name||'</F_JE_HEADER_NAME>');
                                fnd_file.put_line(fnd_file.output, '                    <LIST_G_JE_LINE>');
                                l_xml_je_lines_header := FALSE;
                        END IF;
                        -- =========================== XML OUT =============================

                        -- =========================== XML OUT =============================
                        fnd_file.put_line(fnd_file.output, '                            <G_JE_LINE>');
                        fnd_file.put_line(fnd_file.output, '                                    <JE_LINE>'||l_je_line_num||'</JE_LINE>');
                        fnd_file.put_line(fnd_file.output, '                                    <ACCT_FLEX_FIELD>'||l_seg_ccid||'</ACCT_FLEX_FIELD>');
                        fnd_file.put_line(fnd_file.output, '                                    <JE_DR>'||l_entered_dr||'</JE_DR>');
                        fnd_file.put_line(fnd_file.output, '                                    <JE_CR>'||l_entered_cr||'</JE_CR>');
                        fnd_file.put_line(fnd_file.output, '                                    <F_W>'||l_priority||'</F_W>');
                        fnd_file.put_line(fnd_file.output, '                                    <G_DESC>');
                        fnd_file.put_line(fnd_file.output, '                                    <DESC>'||l_line_description||'</DESC>');
                        -- =========================== XML OUT =============================


                        l_xml_f_sum_header     := true;

                        --Start of Report Summary
                        IF ( l_line_result_code = 'P22' OR
                             l_line_result_code = 'P27' OR
                             l_line_result_code = 'F01' OR
                             l_line_result_code = 'F04' OR
                             l_line_result_code = 'F11' OR
                             l_line_result_code = 'F14') THEN

                                l_je_seg_stmt := 'SELECT distinct ';
                                l_je_first := TRUE;
                                FOR a in c_seg_info(l_ledger_id)
                                LOOP
                                        IF (l_je_first <> FALSE) THEN
                                                l_je_seg_stmt := l_je_seg_stmt||'c.'||a.application_column_name;
                                                l_je_first := FALSE;
                                        ELSE
                                                l_je_seg_stmt := l_je_seg_stmt||'||''.''||'||'c.'||a.application_column_name;
                                        END IF;

                                END LOOP; --End of segments loop

                                l_je_seg_stmt := l_je_seg_stmt||' FROM gl_code_combinations c, gl_account_hierarchies h, '||
                                                                ' gl_bc_packets p where  h.detail_code_combination_id = '||
                                                                l_ccid||' and p.code_combination_id = h.summary_code_combination_id '||
                                                                ' and p.packet_id = '||l_failed_bc_pkts(x).packet_id||
                                                                ' and c.code_combination_id = p.code_combination_id';

                                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_seg_stmt -> '||l_je_seg_stmt);

                                OPEN l_je_sum_lines for l_je_seg_stmt;
                                LOOP
                                        FETCH l_je_sum_lines into l_je_sum_flex;
                                        EXIT WHEN l_je_sum_lines%NOTFOUND;

                                        -- =========================== XML OUT =============================
                                        IF (l_xml_f_sum_header <> FALSE) THEN
                                                fnd_file.put_line(fnd_file.output, '                                    <LIST_DESC_SUM>');
                                                fnd_file.put_line(fnd_file.output, '                                    <DESC_SUM_EXISTS>YES</DESC_SUM_EXISTS>');
                                                l_xml_f_sum_header := FALSE;
                                        END IF;
                                        -- =========================== XML OUT =============================

                                        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_sum_flex -> '||l_je_sum_flex);

                                        -- =========================== XML OUT =============================
                                        fnd_file.put_line(fnd_file.output, '                                    <DESC_SUM>');
                                        fnd_file.put_line(fnd_file.output, '                                    <SUM_FLEX>'||l_je_sum_flex||'</SUM_FLEX>');
                                        fnd_file.put_line(fnd_file.output, '                                    </DESC_SUM>');
                                        -- =========================== XML OUT =============================

                                END LOOP; --End of l_je_sum_lines cursor

                                CLOSE l_je_sum_lines;
                                -- =========================== XML OUT =============================
                                IF (l_xml_f_sum_header <> TRUE) THEN
                                        fnd_file.put_line(fnd_file.output, '                                    </LIST_DESC_SUM>');
                                        l_xml_f_sum_header := TRUE;
                                END IF;
                                -- =========================== XML OUT =============================


                        END IF; --Summary Report End

                        --Budgetary Report Start
                        l_xml_f_bud_header := true;
                        l_je_bud_stmt := 'SELECT ';
                        l_je_first := TRUE;
                        FOR a in c_seg_info(l_ledger_id)
                        LOOP
                                IF (l_je_first <> FALSE) THEN
                                        l_je_bud_stmt := l_je_bud_stmt||'c.'||a.application_column_name;
                                        l_je_first := FALSE;
                                ELSE
                                        l_je_bud_stmt := l_je_bud_stmt||'||''.''||'||'c.'||a.application_column_name;
                                END IF;

                        END LOOP; --End of segments loop

                        BEGIN
                                SELECT
                                        nvl(ussgl_parent_id, 0)
                                INTO
                                        l_ussgl_parent_id
                                FROM
                                       gl_bc_packets
                                WHERE
                                       rowid = l_rowid;
                        EXCEPTION
                                WHEN OTHERS THEN
                                        -- =========================== FND LOG ===========================
                                        psa_utils.debug_other_string(g_excep_level,l_full_path, 'Funds C/R: Failed to fetch ussgl_parent_id from gl_bc_packets');
                                        fnd_file.put_line(fnd_file.log, 'Funds C/R: Failed to fetch ussgl_parent_id from gl_bc_packets');
                                        -- ========================= FND LOG =============================
                        END;

                        l_je_bud_stmt := l_je_bud_stmt||' , p.entered_dr, p.entered_cr, p.result_code, l.description, '||
                                                        ' c.code_combination_id FROM gl_code_combinations c, gl_bc_packets p, '||
                                                        ' gl_lookups l WHERE  p.ussgl_link_to_parent_id = '||l_ussgl_parent_id||
                                                        ' and p.packet_id = '||l_failed_bc_pkts(x).packet_id||
                                                        ' and c.code_combination_id = p.code_combination_id'||
                                                        ' and p.result_code between ''F00'' AND ''F30'' and '||
                                                        ' p.result_code = l.lookup_code and l.lookup_type = ''FUNDS_CHECK_RESULT_CODE'' '||
                                                        ' order by p.code_combination_id';

                        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_bud_stmt -> '||l_je_bud_stmt);

                        OPEN l_je_bud_lines for l_je_bud_stmt;
                        LOOP
                                FETCH l_je_bud_lines into l_je_bud_flex, l_je_bud_dr, l_je_bud_cr, l_je_bud_result_code,
                                                          l_je_bud_desc, l_je_bud_ccid;

                                EXIT WHEN l_je_bud_lines%NOTFOUND;
                                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_bud_flex -> '||l_je_bud_flex
                                                                ||'l_je_bud_dr ->' ||l_je_bud_dr
                                                                ||'l_je_bud_cr ->' ||l_je_bud_cr
                                                                ||'l_je_bud_result_code ->' ||l_je_bud_result_code
                                                                ||'l_je_bud_desc ->' ||l_je_bud_desc
                                                                ||'l_je_bud_ccid ->' ||l_je_bud_ccid
                                                                );

                                -- =========================== XML OUT =============================
                                IF (l_xml_f_bud_header <> FALSE) THEN
                                        fnd_file.put_line(fnd_file.output, '                                    <LIST_DESC_BUD>');
                                        fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_EXISTS>YES</DESC_BUD_EXISTS>');
                                        l_xml_f_bud_header := FALSE;
                                END IF;
                                -- =========================== XML OUT =============================

                                -- =========================== XML OUT =============================
                                fnd_file.put_line(fnd_file.output, '                                    <G_DESC_BUD>');
                                fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_FLEX>'||l_je_bud_flex||'</DESC_BUD_FLEX>');
                                fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_DR>'||l_je_bud_dr||'</DESC_BUD_DR>');
                                fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_CR>'||l_je_bud_cr||'</DESC_BUD_CR>');
                                fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_DESC>'||l_je_bud_desc||'</DESC_BUD_DESC>');
                                fnd_file.put_line(fnd_file.output, '                                    </G_DESC_BUD>');
                                -- =========================== XML OUT =============================

                                l_xml_f_bud_sum_header := true;

                                IF ( l_je_bud_result_code = 'F11' OR
                                     l_je_bud_result_code = 'F14' OR
                                     l_je_bud_result_code = 'F01' OR
                                     l_je_bud_result_code = 'F04')THEN

                                     --Summary Report with the l_je_bud_ccid
                                        l_je_bud_seg_stmt := 'SELECT distinct ';
                                        l_je_first := TRUE;
                                        FOR a in c_seg_info(l_ledger_id)
                                        LOOP
                                                IF (l_je_first <> FALSE) THEN
                                                        l_je_bud_seg_stmt := l_je_bud_seg_stmt||'c.'||a.application_column_name;
                                                        l_je_first := FALSE;
                                                ELSE
                                                        l_je_bud_seg_stmt := l_je_bud_seg_stmt||'||''.''||'||'c.'||a.application_column_name;
                                                END IF;

                                        END LOOP; --End of segments loop

                                        l_je_bud_seg_stmt := l_je_bud_seg_stmt||' FROM gl_code_combinations c, gl_account_hierarchies h, '||
                                                                        ' gl_bc_packets p where  h.detail_code_combination_id = '||
                                                                        l_je_bud_ccid||' and p.code_combination_id = h.summary_code_combination_id '||
                                                                        ' and p.packet_id = '||l_failed_bc_pkts(x).packet_id||
                                                                        ' and c.code_combination_id = p.code_combination_id';

                                        fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_bud_seg_stmt -> '||l_je_bud_seg_stmt);

                                        OPEN l_je_sum_lines for l_je_bud_seg_stmt;
                                        LOOP
                                                FETCH l_je_sum_lines into l_je_bud_sum_flex;
                                                EXIT WHEN l_je_sum_lines%NOTFOUND;
                                                fnd_file.put_line(fnd_file.log, 'Funds C/R: l_je_bud_sum_flex -> '||l_je_bud_sum_flex);

                                                -- =========================== XML OUT =============================
                                                IF (l_xml_f_bud_sum_header  <> FALSE) THEN
                                                        fnd_file.put_line(fnd_file.output, '                                    <LIST_DESC_BUD_SUM>');
                                                        fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_SUM_EXISTS>YES</DESC_BUD_SUM_EXISTS>');
                                                        l_xml_f_bud_sum_header  := FALSE;
                                                END IF;
                                                -- =========================== XML OUT =============================
                                                -- =========================== XML OUT =============================
                                                fnd_file.put_line(fnd_file.output, '                                    <DESC_BUD_SUM>');
                                                fnd_file.put_line(fnd_file.output, '                                    <BUD_SUM_FLEX>'||l_je_bud_sum_flex||'</BUD_SUM_FLEX>');
                                                fnd_file.put_line(fnd_file.output, '                                    </DESC_BUD_SUM>');
                                                -- =========================== XML OUT =============================



                                        END LOOP; --End of l_je_sum_lines cursor
                                        CLOSE l_je_sum_lines;
                                        -- =========================== XML OUT =============================
                                        IF (l_xml_f_bud_sum_header <> TRUE) THEN
                                                fnd_file.put_line(fnd_file.output, '                                    </LIST_DESC_BUD_SUM>');
                                                l_xml_f_bud_sum_header := TRUE;
                                        END IF;
                                        -- =========================== XML OUT =============================


                                END IF; --End Report Summary

                        END LOOP; --End of l_je_bud_lines cursor

                        -- =========================== XML OUT =============================
                        IF (l_xml_f_bud_header <> TRUE) THEN
                                fnd_file.put_line(fnd_file.output, '                                    </LIST_DESC_BUD>');
                                l_xml_f_bud_header := TRUE;
                        END IF;
                        -- =========================== XML OUT =============================

                        CLOSE l_je_bud_lines;

                        -- =========================== XML OUT =============================
                        fnd_file.put_line(fnd_file.output, '                                    </G_DESC>');
                        fnd_file.put_line(fnd_file.output, '                            </G_JE_LINE>');
                        -- =========================== XML OUT =============================


                END LOOP;

                CLOSE l_je_lines;
                -- =========================== XML OUT =============================
                IF (l_xml_je_lines_header <> TRUE) THEN
                        fnd_file.put_line(fnd_file.output, '                    </LIST_G_JE_LINE>');
                END IF;
                fnd_file.put_line(fnd_file.output, '            </G_FAILURE_JE_BATCH_NAME>');
                -- =========================== XML OUT =============================

        END LOOP; -- End of failed pkts loop
        -- =========================== XML OUT =============================
        IF (l_xml_f_b_header <> TRUE) THEN
                fnd_file.put_line(fnd_file.output, '    </LIST_G_FAILURE_JE_BATCH_NAME>');
        END IF;
        -- =========================== XML OUT =============================

        <<NORMAL_EXIT>>
        -- =========================== XML OUT =============================
        fnd_file.put_line(fnd_file.output, '</REPORT_ROOT>');
        -- =========================== XML OUT =============================


        IF sel1%ISOPEN THEN
                CLOSE sel1;

        ELSIF sel2%ISOPEN THEN
                CLOSE sel2;

        END IF;

        COMMIT;

   END;


 /*=======================================================================+
  | Function    : GET_DEBUG                                               |
  | Description : Returns value stored in g_debug variable.               |
  |               This was used by some sub-ledger team in 11i. Not sure  |
  |               if its still applicable for R12. Will check and remove. |
  +=======================================================================*/
  FUNCTION get_debug RETURN VARCHAR2 IS
  BEGIN
      return g_debug;
  END get_debug;


 /*=======================================================================+
  | Function    : GLSIBC                                                  |
  | Description : Procedure added by Abhishek                             |
  +=======================================================================*/

  PROCEDURE glsibc (p_last_updated_by NUMBER,
                    p_new_template_id NUMBER,
                    p_ledger_id NUMBER) IS

    l_full_path VARCHAR2(100);
  BEGIN
    l_full_path := g_path||'Glsibc';

    INSERT INTO GL_BC_PACKETS
            (packet_id,
            ledger_id,
            je_source_name,
            je_category_name,
            code_combination_id,
            actual_flag,
            period_name,
            period_year,
            period_num,
            quarter_num,
            currency_code,
            status_code,
            last_update_date,
            last_updated_by,
            budget_version_id,
            encumbrance_type_id,
            template_id,
            entered_dr,
            entered_cr,
            accounted_dr,
            accounted_cr,
            funding_budget_version_id,
            funds_check_level_code,
            amount_type,
            boundary_code,
            dr_cr_code,
            account_category_code,
            effect_on_funds_code,
            result_code,
            session_id,
            serial_id,
            application_id)
    SELECT
            min(BP.packet_id),
            min(BP.ledger_id),
            min(BP.je_source_name),
            min(BP.je_category_name),
            min(AH.summary_code_combination_id),
            min(BP.actual_flag),
            min(BP.period_name),
            min(BP.period_year),
            min(BP.period_num),
            min(BP.quarter_num),
            min(BP.currency_code),
            'A',   /* approved */
            SYSDATE,
            p_last_updated_by,
            min(decode(BP.actual_flag, 'B', BP.budget_version_id, NULL)),
            min(decode(BP.actual_flag, 'E', BP.encumbrance_type_id, NULL)),
            p_new_template_id,
            sum(nvl(BP.entered_dr,0)),
            sum(nvl(BP.entered_cr,0)),
            sum(nvl(BP.accounted_dr,0)),
            sum(nvl(BP.accounted_cr,0)),
            SB.funding_budget_version_id,
            SB.funds_check_level_code,
            SB.amount_type,
            SB.boundary_code,
            SB.dr_cr_code,
            min(ST.account_category_code),
            decode(
             decode(min(BP.actual_flag) || SB.dr_cr_code ||
                    min(ST.account_category_code),
             'BCP', 'dec',
             'ADP', 'dec',
             'EDP', 'dec',
             'ACB', 'dec',
             'inc'),
             'dec',                     /* +ve net dr => decreasing fa */
              decode(sign(sum(nvl(BP.accounted_dr,0) - nvl(BP.accounted_cr,0))),
               1, 'D', 'I'),
             'inc',                     /* +ve net dr => increasing fa */
              decode(sign(sum(nvl(BP.accounted_dr,0) - nvl(BP.accounted_cr,0))),
               -1, 'D', 'I')),
            'P04',   /* P04 - This summary transaction generated does not */
                    /*       require funds check */
            min(BP.session_id),
            min(BP.serial_id),
            min(BP.application_id)
    FROM
            GL_ACCOUNT_HIERARCHIES AH,
            GL_BC_PACKETS BP,
            GL_BC_PACKET_ARRIVAL_ORDER AO,
            GL_SUMMARY_TEMPLATES ST,
            GL_SUMMARY_BC_OPTIONS SB,
            GL_BUDGETS B,
            GL_BUDGET_VERSIONS BV,
            GL_PERIOD_STATUSES PS

    WHERE
            AH.ledger_id = p_ledger_id
        AND AH.detail_code_combination_id = BP.code_combination_id
        AND AH.template_id = p_new_template_id
        AND BP.status_code = 'A'
        AND BP.ledger_id = p_ledger_id
        AND BP.template_id IS NULL
        AND BP.packet_id = AO.packet_id
        AND BP.account_category_code = ST.account_category_code
        AND nvl(BP.budget_version_id, -1) = decode(BP.actual_flag, 'B',
                                                   SB.funding_budget_version_id, -1)
        AND AO.ledger_id = p_ledger_id
        AND AO.affect_funds_flag = 'Y'
        AND ST.template_id = p_new_template_id
        AND SB.template_id = ST.template_id
        AND SB.funding_budget_version_id = BV.budget_version_id
        AND BV.budget_name = B.budget_name
        AND PS.application_id = 101
        AND PS.ledger_id = p_ledger_id
        AND PS.period_name = BP.period_name
        AND PS.effective_period_num >= (SELECT P1.effective_period_num
                                          FROM GL_PERIOD_STATUSES P1
                                         WHERE P1.period_name = B.first_valid_period_name
                                           AND P1.application_id = 101
                                           AND P1.ledger_id = p_ledger_id)
        AND PS.effective_period_num <= (SELECT P2.effective_period_num
                                          FROM GL_PERIOD_STATUSES P2
                                         WHERE P2.period_name = B.last_valid_period_name
                                           AND P2.application_id = 101
                                           AND P2.ledger_id = p_ledger_id)
    GROUP BY
            BP.packet_id,
            AH.summary_code_combination_id,
            BP.actual_flag,
            BP.period_name,
            BP.currency_code,
            BP.je_source_name,
            BP.je_category_name,
            BP.budget_version_id,
            BP.encumbrance_type_id,
            SB.funding_budget_version_id,
            SB.funds_check_level_code,
            SB.amount_type,
            SB.boundary_code,
            SB.dr_cr_code
     HAVING
            sum(nvl(BP.accounted_dr,0)-nvl(BP.accounted_cr,0)) <> 0;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Insert GL_BC_PACKETS -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================

  END glsibc;

 /*=======================================================================+
  | Function    : GLSFBC                                                  |
  | Description : Procedure added by Abhishek                             |
  +=======================================================================*/

  PROCEDURE glsfbc (p_curr_temp_id IN NUMBER,
                    p_ledger_id IN NUMBER,
                    p_last_updated_by IN NUMBER) IS

    l_full_path VARCHAR2(100);
  BEGIN
    l_full_path := g_path||'Glsfbc';

    -- =========================== FND LOG ===========================
       fnd_file.put_line(fnd_file.log, 'p_curr_temp_id = '||p_curr_temp_id);
       fnd_file.put_line(fnd_file.log, 'p_ledger_id = '||p_ledger_id);
       fnd_file.put_line(fnd_file.log, 'SHRD0114 ' || '1 ' || 'stmt ' || 'Inserting into GL_BC_PACKETS ...');
    -- =========================== FND LOG =============================

    INSERT INTO GL_BC_PACKETS
            (packet_id,
             ledger_id,
             je_source_name,
             je_category_name,
             code_combination_id,
             actual_flag,
             period_name,
             period_year,
             period_num,
             quarter_num,
             currency_code,
             status_code,
             last_update_date,
             last_updated_by,
             budget_version_id,
             encumbrance_type_id,
             template_id,
             entered_dr,
             entered_cr,
             accounted_dr,
             accounted_cr,
             funding_budget_version_id,
             funds_check_level_code,
             amount_type,
             boundary_code,
             dr_cr_code,
             account_category_code,
             effect_on_funds_code,
             result_code,
             session_id,
             serial_id,
             application_id)
      SELECT
             BP.packet_id,
             min(BP.ledger_id),
             BP.je_source_name,
             BP.je_category_name,
             AH.summary_code_combination_id,
             BP.actual_flag,
             BP.period_name,
             min(BP.period_year),
             min(BP.period_num),
             min(BP.quarter_num),
             BP.currency_code,
             'A',   /* approved */
             SYSDATE,
             p_last_updated_by,
             min(decode(BP.actual_flag, 'B',
                        BP.budget_version_id, NULL)),
             min(decode(BP.actual_flag, 'E',
                        BP.encumbrance_type_id, NULL)),
             p_curr_temp_id,
             0, 0, 0, 0,
             SB.funding_budget_version_id,
             SB.funds_check_level_code,
             SB.amount_type,
             SB.boundary_code,
             SB.dr_cr_code,
             min(ST.account_category_code),
             'I',
             'P04',   /* P04 - This summary transaction generated */
                      /*       does not require funds check */
             min(BP.session_id),
             min(BP.serial_id),
             min(BP.application_id)
        FROM
             GL_ACCOUNT_HIERARCHIES AH,
             GL_BC_PACKETS BP,
             GL_BC_PACKET_ARRIVAL_ORDER AO,
             GL_SUMMARY_TEMPLATES ST,
             GL_SUMMARY_BC_OPTIONS SB,
             GL_BUDGETS B,
             GL_BUDGET_VERSIONS BV,
             GL_PERIOD_STATUSES PS
       WHERE AH.ledger_id = p_ledger_id
         AND AH.detail_code_combination_id = BP.code_combination_id
         AND AH.template_id = p_curr_temp_id
         AND BP.status_code = 'A'
         AND BP.ledger_id = p_ledger_id
         AND BP.template_id IS NULL
         AND BP.packet_id = AO.packet_id
         AND BP.account_category_code = ST.account_category_code
         AND nvl(BP.budget_version_id, -1) =
                 decode(BP.actual_flag, 'B',
                        SB.funding_budget_version_id, -1)
         AND AO.ledger_id = p_ledger_id
         AND AO.affect_funds_flag = 'Y'
         AND ST.template_id = p_curr_temp_id
         AND NOT EXISTS
             ( Select 'Y'
                 From GL_BC_PACKETS BP2
                Where BP2.ledger_id = p_ledger_id
                And   BP2.template_id = p_curr_temp_id
                And   BP2.code_combination_id = AH.summary_code_combination_id
                And   BP2.packet_id = BP.packet_id
                And   BP2.actual_flag = BP.actual_flag
                And   BP2.period_name = BP.period_name
                And   BP2.currency_code = BP.currency_code
                And   BP2.je_source_name = BP.je_source_name
                And   BP2.je_category_name = BP.je_category_name
                And   nvl(BP2.encumbrance_type_id,-1) = nvl(BP.encumbrance_type_id,-1)
                And   nvl(BP2.budget_version_id,-1) = nvl(BP.budget_version_id,-1))
         AND SB.template_id = p_curr_temp_id
         AND SB.funding_budget_version_id = BV.budget_version_id
         AND BV.budget_name = B.budget_name
         AND PS.application_id = 101
         AND PS.ledger_id = p_ledger_id
         AND PS.period_name = BP.period_name
         AND PS.effective_period_num >=
             ( Select P1.effective_period_num
                 From GL_PERIOD_STATUSES P1
                Where P1.period_name = B.first_valid_period_name
                And   P1.application_id = 101
                And   P1.ledger_id = p_ledger_id)
         AND PS.effective_period_num <=
             ( Select P2.effective_period_num
                 From GL_PERIOD_STATUSES P2
                Where P2.period_name = B.last_valid_period_name
                And   P2.application_id = 101
                And   P2.ledger_id = p_ledger_id)
    GROUP BY
            BP.packet_id,
            AH.summary_code_combination_id,
            BP.actual_flag,
            BP.period_name,
            BP.currency_code,
            BP.je_source_name,
            BP.je_category_name,
            BP.budget_version_id,
            BP.encumbrance_type_id,
            SB.funding_budget_version_id,
            SB.funds_check_level_code,
            SB.amount_type,
            SB.boundary_code,
            SB.dr_cr_code

    HAVING
            sum(nvl(BP.accounted_dr,0)-nvl(BP.accounted_cr,0)) <> 0;

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Insert GL_BC_PACKETS -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================


    -- =========================== FND LOG ===========================
       fnd_file.put_line(fnd_file.log, 'GL_BC_PACKETS');
       fnd_file.put_line(fnd_file.log, 'SHRD0114 ' || '1 ' || 'stmt ' || 'Updating GL_BC_PACKETS ...');
    -- =========================== FND LOG =============================

    UPDATE gl_bc_packets bp2
        SET (entered_dr, entered_cr, accounted_dr, accounted_cr,
             effect_on_funds_code) =
              (SELECT SUM (NVL (bp.entered_dr, 0)), SUM (NVL (bp.entered_cr,0)),
                      SUM (NVL (bp.accounted_dr, 0)),
                      SUM (NVL (bp.accounted_cr, 0)),
                      DECODE (DECODE (   MIN (bp.actual_flag)
                                      || MIN(sb.dr_cr_code)
                                      || MIN (st.account_category_code),
                                      'BCP', 'dec',
                                      'ADP', 'dec',
                                      'EDP', 'dec',
                                      'ACB', 'dec',
                                      'inc'
                                     ),
                              'dec',             /* +ve net dr => decreasing fa */
                              DECODE (SIGN (SUM (  NVL (bp.accounted_dr, 0)
                                                 - NVL (bp.accounted_cr, 0)
                                                )
                                           ),
                                      1, 'D',
                                      'I'
                                      ),
                              'inc',             /* +ve net dr => increasing fa */
                              DECODE (SIGN (SUM (  NVL (bp.accounted_dr, 0)
                                                 - NVL (bp.accounted_cr, 0)
                                                )
                                           ),
                                      -1, 'D',
                                      'I'
                                     )
                             )
                 FROM gl_bc_packets bp,
                      gl_account_hierarchies ah,
                      gl_bc_packet_arrival_order ao,
                      gl_summary_templates st,
                      gl_summary_bc_options sb,
                      gl_budgets b,
                      gl_budget_versions bv,
                      gl_period_statuses ps
                WHERE ah.ledger_id = p_ledger_id
                  AND ah.template_id = p_curr_temp_id
                  AND ah.summary_code_combination_id = bp2.code_combination_id
                  AND st.template_id = p_curr_temp_id
                  AND bp.status_code = 'A'
                  AND bp.ledger_id = p_ledger_id
                  AND bp.template_id IS NULL
                  AND bp.code_combination_id = ah.detail_code_combination_id
                  AND bp.account_category_code = st.account_category_code
                  AND bp.packet_id  = bp2.packet_id
                  AND bp.actual_flag = bp2.actual_flag
                  AND bp.period_name = bp2.period_name
                  AND bp.currency_code = bp2.currency_code
                  AND bp.je_source_name = bp2.je_source_name
                  AND bp.je_category_name = bp2.je_category_name
                  AND nvl(BP.encumbrance_type_id, -1) = nvl(BP2.encumbrance_type_id, -1)
                  AND nvl(BP.budget_version_id,-1) = nvl(BP2.budget_version_id,-1)
                  AND sb.template_id = p_curr_temp_id
                  AND sb.funding_budget_version_id = bv.budget_version_id
                  AND bv.budget_name = b.budget_name
                  AND ps.application_id = 101
                  AND ps.ledger_id = p_ledger_id
                  AND ps.period_name = bp.period_name
                  AND ps.effective_period_num >=
                         (SELECT p1.effective_period_num
                            FROM gl_period_statuses p1
                           WHERE p1.period_name = b.first_valid_period_name
                             AND p1.application_id = 101
                             AND p1.ledger_id = p_ledger_id)
                  AND ps.effective_period_num <=
                         (SELECT p2.effective_period_num
                            FROM gl_period_statuses p2
                           WHERE p2.period_name = b.last_valid_period_name
                             AND p2.application_id = 101
                             AND p2.ledger_id = p_ledger_id)
                  AND NVL (bp.budget_version_id, -1) =
                         DECODE (bp.actual_flag,
                                 'B', sb.funding_budget_version_id,
                                 -1
                                )
                 AND ao.ledger_id = p_ledger_id
                 AND ao.affect_funds_flag = 'Y'
                 AND ao.packet_id = bp2.packet_id)
      WHERE bp2.ledger_id = p_ledger_id
        AND bp2.template_id = p_curr_temp_id
        AND bp2.code_combination_id IN (SELECT code_combination_id
                                          FROM gl_code_combinations
                                         WHERE template_id = p_curr_temp_id);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update GL_BC_PACKETS -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================



    /*---------------------------------------------------+
     | The Delete statement will be executed here ALWAYS |
     +---------------------------------------------------*/

    -- =========================== FND LOG ===========================
       fnd_file.put_line(fnd_file.log, 'SHRD0114 ' || '1 ' || 'stmt ' || 'Deleting from GL_BC_PACKETS ...');
    -- =========================== FND LOG =============================


    DELETE FROM gl_bc_packets bp
          WHERE bp.ledger_id = p_ledger_id
            AND bp.template_id = p_curr_temp_id
            AND bp.packet_id IN (
                     SELECT ao.packet_id
                       FROM gl_bc_packet_arrival_order ao
                      WHERE ao.ledger_id = p_ledger_id
                           AND ao.affect_funds_flag = 'Y')
            AND NOT EXISTS (
                   SELECT 'Y'
                     FROM gl_account_hierarchies ah
                    WHERE ah.ledger_id = p_ledger_id
                      AND ah.template_id = p_curr_temp_id
                      AND ah.summary_code_combination_id = bp.code_combination_id);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Delete GL_BC_PACKETS -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================

    -- =========================== FND LOG ===========================
       fnd_file.put_line(fnd_file.log, 'GL_BC_PACKETS');
    -- =========================== FND LOG =============================

  END glsfbc;

 /*=======================================================================+
  | Function    : GET_SESSION_DETAILS                                     |
  | Description : Returns the session_id and serial_id of current session |
  +=======================================================================*/

  PROCEDURE get_session_details(x_session_id OUT NOCOPY NUMBER,
                                x_serial_id  OUT NOCOPY NUMBER) IS

        l_full_path VARCHAR2(100);
  BEGIN

        l_full_path := g_path||'get_session_details';

     select s.audsid,  s.serial#   into x_session_id, x_serial_id
     from v$session s, v$process p
     where s.paddr = p.addr
     and   s.audsid = USERENV('SESSIONID');

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' x_session_id -> ' || x_session_id);
       psa_utils.debug_other_string(g_state_level,l_full_path, ' x_serial_id -> ' || x_serial_id);
    -- ========================= FND LOG =============================

  EXCEPTION
     WHEN others THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path, ' EXCEPTION WHEN OTHERS ' || SQLERRM);
           psa_utils.debug_other_string(g_excep_level,l_full_path, ' raise');
        -- ========================= FND LOG ===========================

        raise;
  END get_session_details;


 /*=======================================================================+
  | Function    : POPULATE_GROUP_ID                                       |
  | Description : Invoked by SLA during transfer to GL                    |
  +=======================================================================*/

  PROCEDURE populate_group_id (p_grp_id         IN NUMBER,
                               p_application_id IN NUMBER,
                               p_je_batch_name  IN VARCHAR2 DEFAULT NULL) IS
    l_full_path VARCHAR2(100);
  BEGIN
    l_full_path := g_path||'Populate_Group_Id';

    UPDATE gl_bc_packets
    SET group_id = p_grp_id,
       je_batch_name = p_je_batch_name
    WHERE ae_header_id IN (SELECT ae_header_id
                           FROM xla_ae_headers
                           WHERE group_id = p_grp_id
                           and application_id = p_application_id);

    -- =========================== FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path, ' Update GL_BC_PACKETS -> ' || SQL%ROWCOUNT);
    -- ========================= FND LOG =============================

  END populate_group_id;


 /*===========================================================================================+
  | Function    : DEBUG_XLA_INSERT                              |
  | Description : This Procedure inserts data from global temporary SLA tables  |
  |                      to PSA tables as shown below:                          |
  |                                     |
  |                      SLA Table              PSA Table               |
  |                      ========               ========                |
  |                      xla_events_gt          psa_xla_events_logs     |
  |                      xla_validation_lines_gt        psa_xla_validation_lines_logs   |
  |                      xla_ae_lines_gt                psa_xla_ae_lines_logs   |
  |                      xla_ae_headers_gt      psa_xla_ae_headers_logs |
  |                                     |
  +===========================================================================================*/

  PROCEDURE debug_xla_insert ( xla_events  IN  xla_events_table ,
                               xla_validation_lines  IN  xla_validation_lines_table ,
                               xla_ae_lines  IN  xla_ae_lines_table ,
                               xla_ae_headers  IN  xla_ae_headers_table ,
                                xla_distribution_links IN xla_distribution_links_table)  IS

  PRAGMA autonomous_transaction;
  i       NUMBER;

  BEGIN

     FORALL i IN 1 .. xla_events.count
        INSERT INTO psa_xla_events_logs
        VALUES xla_events(i);

     FORALL i IN 1 .. xla_validation_lines.count
        INSERT INTO psa_xla_validation_lines_logs
        VALUES xla_validation_lines(i);

     FORALL i IN 1 .. xla_ae_lines.count
        INSERT INTO psa_xla_ae_lines_logs
        VALUES xla_ae_lines(i);

     FORALL i IN 1 .. xla_ae_headers.count
        INSERT INTO psa_xla_ae_headers_logs
        VALUES xla_ae_headers(i);


     FORALL i IN 1 .. xla_distribution_links.count
        INSERT INTO psa_xla_dist_links_logs
        VALUES xla_distribution_links(i);
    COMMIT;

  END debug_xla_insert ;


 /*===========================================================================================+
  | Function    : DEBUG_XLA                             |
  | Description : This Procedure is used for SLA debugging purpose.     |
  |                      It calls DEBUG_XLA_INSERT procedure to transfer data   |
  |                      from global temporary SLA tables to PSA tables.                |
  |                                     |
  +===========================================================================================*/

  PROCEDURE debug_xla (phase IN VARCHAR2) IS

  l_xla_events          xla_events_table;
  l_xla_validation_lines        xla_validation_lines_table;
  l_xla_ae_lines                xla_ae_lines_table;
  l_xla_ae_headers      xla_ae_headers_table;
  l_xla_distribution_links xla_distribution_links_table;

  BEGIN

       IF g_xla_debug THEN

             SELECT  line_number,
          entity_id,
          application_id,
          ledger_id,
          entity_code,
          source_id_int_1,
          source_id_char_1,
          event_id,
          event_class_code,
          event_status_code,
          process_status_code,
          reference_num_1,
          reference_char_1,
          on_hold_flag,
          transaction_date,
          budgetary_control_flag,
          phase,
          sysdate
             BULK COLLECT INTO l_xla_events
             FROM xla_events_gt ;


             SELECT event_id,
          entity_id,
          ae_header_id,
          ae_line_num,
          accounting_date,
          balance_type_code,
          je_category_name,
          budget_version_id,
          ledger_id,
          entered_currency_code,
          entered_dr,
          entered_cr,
          accounted_dr,
          accounted_cr,
          code_combination_id,
          balancing_line_type,
          encumbrance_type_id,
          accounting_entry_status_code,
          period_name,
          phase,
          sysdate
             BULK COLLECT INTO l_xla_validation_lines
             FROM xla_validation_lines_gt ;


             SELECT ae_header_id,
          ae_line_num,
          source_distribution_id_char_1,
          source_distribution_id_char_2,
          source_distribution_id_char_3,
          source_distribution_id_char_4,
          source_distribution_id_char_5,
          source_distribution_id_num_1,
          source_distribution_id_num_2,
          source_distribution_id_num_3,
          source_distribution_id_num_4,
          source_distribution_id_num_5,
          source_distribution_type,
          bflow_application_id,
          bflow_entity_code,
          bflow_source_id_num_1,
          bflow_source_id_num_2,
          bflow_source_id_num_3,
          bflow_source_id_num_4,
          bflow_source_id_char_1,
          bflow_source_id_char_2,
          bflow_source_id_char_3,
          bflow_source_id_char_4,
          bflow_distribution_type,
          bflow_dist_id_num_1,
          bflow_dist_id_num_2,
          bflow_dist_id_num_3,
          bflow_dist_id_num_4,
          bflow_dist_id_num_5,
          bflow_dist_id_char_1,
          bflow_dist_id_char_2,
          bflow_dist_id_char_3,
          bflow_dist_id_char_4,
          bflow_dist_id_char_5,
          phase,
          sysdate
             BULK COLLECT INTO l_xla_ae_lines
             FROM xla_ae_lines_gt ;


             SELECT ae_header_id,
          ledger_id,
          event_id,
          event_type_code,
          accounting_entry_status_code  ,
          balance_type_code,
          funds_status_code,
          phase,
          sysdate
             BULK COLLECT INTO l_xla_ae_headers
             FROM xla_ae_headers_gt ;

        Select application_id ,
        event_id,
        ae_header_id,
        ae_line_num  ,
        source_distribution_type ,
        source_distribution_id_char_1,
        source_distribution_id_char_2,
        source_distribution_id_char_3,
        source_distribution_id_char_4,
        source_distribution_id_char_5,
        source_distribution_id_num_1 ,
        source_distribution_id_num_2 ,
        source_distribution_id_num_3 ,
        source_distribution_id_num_4 ,
        source_distribution_id_num_5 ,
        tax_line_ref_id ,
        tax_summary_line_ref_id ,
        tax_rec_nrec_dist_ref_id ,
        statistical_amount,
        ref_ae_header_id ,
        ref_temp_line_num ,
        accounting_line_code,
        accounting_line_type_code,
        merge_duplicate_code ,
        temp_line_num ,
        ref_event_id  ,
        line_definition_owner_code ,
        line_definition_code ,
        event_class_code ,
        event_type_code ,
        upg_batch_id  ,
        calculate_acctd_amts_flag,
        calculate_g_l_amts_flag ,
         gain_or_loss_ref,
       rounding_class_code  ,
        document_rounding_level,
        unrounded_entered_dr,
        unrounded_entered_cr ,
        doc_rounding_entered_amt,
        doc_rounding_acctd_amt,
        unrounded_accounted_cr ,
        unrounded_accounted_dr ,
        alloc_to_application_id,
        alloc_to_entity_code,
        alloc_to_source_id_num_1,
        alloc_to_source_id_num_2,
        alloc_to_source_id_num_3,
        alloc_to_source_id_num_4,
        alloc_to_source_id_char_1,
        alloc_to_source_id_char_2,
        alloc_to_source_id_char_3,
        alloc_to_source_id_char_4,
        alloc_to_distribution_type,
        alloc_to_dist_id_num_1,
        alloc_to_dist_id_num_2,
        alloc_to_dist_id_num_3,
        alloc_to_dist_id_num_4,
        alloc_to_dist_id_num_5,
        alloc_to_dist_id_char_1,
        alloc_to_dist_id_char_2,
        alloc_to_dist_id_char_3,
        alloc_to_dist_id_char_4,
        alloc_to_dist_id_char_5,
        applied_to_application_id,
        applied_to_entity_code ,
        applied_to_entity_id  ,
        applied_to_source_id_num_1,
        applied_to_source_id_num_2,
        applied_to_source_id_num_3 ,
        applied_to_source_id_num_4 ,
        applied_to_source_id_char_1,
        applied_to_source_id_char_2,
        applied_to_source_id_char_3,
        applied_to_source_id_char_4,
        applied_to_distribution_type,
        applied_to_dist_id_num_1,
        applied_to_dist_id_num_2,
        applied_to_dist_id_num_3,
        applied_to_dist_id_num_4,
        applied_to_dist_id_num_5,
        applied_to_dist_id_char_1,
        applied_to_dist_id_char_2,
        applied_to_dist_id_char_3,
        applied_to_dist_id_char_4,
        applied_to_dist_id_char_5,
        phase,
        sysdate
         BULK COLLECT INTO l_xla_distribution_links
         FROM xla_distribution_links
         where event_id IN (SELECT event_id from psa_bc_xla_events_gt)
        and application_id = psa_bc_xla_pvt.g_application_id;



             DEBUG_XLA_INSERT ( l_xla_events, l_xla_validation_lines, l_xla_ae_lines, l_xla_ae_headers ,        l_xla_distribution_links);

     ELSE
             return;

      END IF;

  END debug_xla;

  PROCEDURE check_for_xla_errors
  (
    p_error_type IN VARCHAR2 DEFAULT NULL,
    p_return_code OUT NOCOPY VARCHAR2
  )
  IS
    l_full_path VARCHAR2(100);
    l_message VARCHAR2(2000);
  BEGIN
    l_full_path := g_path||'check_for_xla_errors';
    p_return_code := 'N';
    psa_utils.debug_other_string(g_state_level,l_full_path, 'Inside Program');
    psa_utils.debug_other_string(g_state_level,l_full_path, 'p_error_type='||p_error_type);
    IF (p_error_type = 'BFLOW') THEN
      psa_utils.debug_other_string(g_state_level,l_full_path, 'Checking for BFLOW Errors');
      FOR bflow_rec IN (SELECT l.*,
                               e.entity_id event_entiity_id
                          FROM xla_ae_lines_gt l,
                               xla_events_gt e
                         WHERE l.event_id = e.event_id
                           AND business_method_code = 'PRIOR_ENTRY'
                           AND code_combination_status_code = 'INVALID'
                           AND NVL(bflow_prior_entry_status_code, 'N') <> 'F') LOOP
        l_message := 'Related BC Accounting Missing for '||
                     ' Event id: '||bflow_rec.event_id||
                     ' Event Type Code: '||bflow_rec.event_type_code ||
                     ' Distribution Id: '||bflow_rec.source_distribution_id_num_1||
                     ' Related Application Id: '||bflow_rec.bflow_application_id||
                     ' Related Entity Code: '||bflow_rec.bflow_entity_code||
                     ' Related Source identifier Num 1: '||bflow_rec.bflow_source_id_num_1||
                     ' Related Distribution Type: '||bflow_rec.bflow_distribution_type||
                     ' Related Distribution Identifier Num 1: '||bflow_rec.bflow_dist_id_num_1;
       Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
       Fnd_Message.Set_Token('PARAM_NAME',l_message);
  --     Fnd_Msg_Pub.ADD;
        psa_bc_xla_pvt.psa_xla_error
        (
          p_message_code => 'PSA_BC_XLA_ERROR',
          p_event_id => bflow_rec.event_id
        );
        p_return_code := 'Y';
      END LOOP;
    ELSIF (p_error_type = 'EVENTS_NOT_PROCESSED') THEN
      psa_utils.debug_other_string(g_state_level,l_full_path, 'Checking for Events Not Processed');
      FOR events_rec IN (SELECT *
                           FROM xla_events_gt e
                          WHERE NOT EXISTS (SELECT 1
                                              FROM xla_ae_lines_gt l
                                             WHERE l.event_id = e.event_id)) LOOP
        l_message := 'Event '||events_rec.event_id||' is not processed.';
        Fnd_message.set_name('PSA','PSA_BC_XLA_ERROR');
        Fnd_Message.Set_Token('PARAM_NAME',l_message);
        psa_bc_xla_pvt.psa_xla_error
        (
          p_message_code => 'PSA_BC_XLA_ERROR',
          p_event_id => events_rec.event_id
        );
        p_return_code := 'Y';
      END LOOP;
    ELSIF (p_error_type = 'GL_BC_PACKETS_EMPTY') THEN
      psa_utils.debug_other_string(g_state_level,l_full_path, 'Checking for Events Not Processed');
      FOR events_rec IN (SELECT *
                           FROM xla_events_gt e
                          WHERE NOT EXISTS (SELECT 1
                                              FROM xla_psa_bc_lines_v l
                                             WHERE l.event_id = e.event_id)) LOOP
        l_message := 'Event '||events_rec.event_id||' is not processed.';
        Fnd_message.set_name('PSA','PSA_GL_BC_PACKETS_EMPTY');
        Fnd_Message.Set_Token('PARAM_NAME',l_message);
        psa_bc_xla_pvt.psa_xla_error
        (
          p_message_code => 'PSA_GL_BC_PACKETS_EMPTY',
          p_event_id => events_rec.event_id
        );
        p_return_code := 'Y';
      END LOOP;
    END IF;
  END;



/*===========================================================================================+
  | Function    : BUDGETARY_CONTROL                                                           |
  | Description : BC API is invoked by SLA in package XLA_JE_VALIDATION_PKG.BUDGETARY_CONTROL |
  +===========================================================================================*/

  FUNCTION budgetary_control (p_ledgerid    IN  NUMBER,
                              p_return_code OUT NOCOPY VARCHAR2) return BOOLEAN IS

     l_session_id gl_bc_packets.session_id%type;
     l_serial_id  gl_bc_packets.serial_id%type;

     l_packet_id gl_bc_packets.packet_id%type;
     l_bc_pkts bc_pkts_rec;
     l_packets num_rec;
     l_ret_code     VARCHAR2(1);
     l_bc_ret_code  VARCHAR2(1);
     l_s_status_cnt NUMBER(5);
     l_a_status_cnt NUMBER(5);
     l_f_status_cnt NUMBER(5);
     l_p_status_cnt NUMBER(5);
     l_t_status_cnt NUMBER(5);
     l_je_source_name xla_subledgers.je_source_name%type;
     invalid_je_source_name EXCEPTION;
     gl_bc_packets_empty EXCEPTION;
     l_xla_return_code VARCHAR2(1);


     -- ========================= FND LOG ===========================
        l_full_path VARCHAR2(100);
     -- ========================= FND LOG ===========================

     CURSOR get_je_source_name (p_application_id IN NUMBER) IS
     SELECT je_source_name
     FROM xla_subledgers
     WHERE application_id = p_application_id;

     CURSOR get_status_per_header (p_packet_id IN NUMBER) IS
     SELECT ae_header_id,
            count(*) total_cnt,
            sum(decode(status_code, 'S', 1, 0)) success_cnt,
            sum(decode(status_code, 'A', 1, 0)) approved_cnt,
            sum(decode(status_code, 'F', 1, 0)) failed_cnt,
            sum(decode(status_code, 'R', 1, 0)) rejected_cnt
     FROM gl_bc_packets
     WHERE packet_id = p_packet_id
     GROUP BY ae_header_id;

     CURSOR get_ledger_category (p_ledgerid IN NUMBER) IS
     SELECT ledger_category_code
     FROM gl_ledgers
     WHERE ledger_id = p_ledgerid;

     CURSOR debug_xla_ae_headers_gt IS
     SELECT ae_header_id, ledger_id, entity_id, event_id,
            event_type_code, funds_status_code, accounting_entry_status_code,
            balance_type_code
     FROM xla_ae_headers_gt;

     CURSOR debug_xla_ae_lines_gt IS
     SELECT event_id, ae_header_id, ae_line_num
     FROM xla_ae_lines_gt;

     CURSOR debug_xla_val_lines_gt IS
     SELECT event_id, ae_header_id, ae_line_num, period_name,
            accounting_entry_status_code, balancing_line_type
     FROM xla_validation_lines_gt;

     CURSOR debug_xla_events_gt IS
     SELECT application_id, event_id, event_date, event_type_code,
            reference_num_1
     FROM xla_events_gt;

     CURSOR debug_xla_psa_bc_v IS
     SELECT event_id,  ae_header_id, ae_line_num, entity_id, ledger_id,
            period_name
     FROM xla_psa_bc_lines_v;

     CURSOR debug_psa_bc_alloc_gt IS
     SELECT hierarchy_id, ae_header_id, ae_line_num, event_id,
            status_code
     FROM psa_bc_alloc_gt;

     -- Check whether all the events from XLA_EVENTS_GT have come to
     -- XLA_AE_LINES_GT.
     /* If any event is missed we will treat it as
        FATAL error because there was some setup problem in SLA. */
     CURSOR c_cnt_events IS
     SELECT (SELECT COUNT (*)
               FROM xla_events_gt) event_count,
            (SELECT COUNT (DISTINCT (event_id))
               FROM xla_ae_lines_gt) ae_event_count
       FROM DUAL;

     -- check whether allocation attributes are used or not
     /* This is to avoid additional processing for allocation attributes
        if they are NOT used. */
     CURSOR c_chk_alloc_used is
     SELECT
         'Allocation attributes are used'
     FROM DUAL
     WHERE EXISTS
         (
         SELECT
             'Related transaction allocation setup exists'
         FROM psa_bc_alloc_v a,
             psa_bc_alloc_v b
         WHERE a.ROW_ID <> b.ROW_ID
             AND NVL (b.alloc_to_entity_code, 'X') = NVL (a.entity_code, 'X')
             AND NVL (b.alloc_to_source_id_num_1, -99) = NVL (a.source_id_int_1, -99)
             AND NVL (b.alloc_to_source_id_num_2, -99) = NVL (a.source_id_int_2, -99)
             AND NVL (b.alloc_to_source_id_num_3, -99) = NVL (a.source_id_int_3, -99)
             AND NVL (b.alloc_to_source_id_num_4, -99) = NVL (a.source_id_int_4, -99)
             AND NVL (b.alloc_to_source_id_char_1, 'X') = NVL (a.source_id_char_1, 'X')
             AND NVL (b.alloc_to_source_id_char_2, 'X') = NVL (a.source_id_char_2, 'X')
             AND NVL (b.alloc_to_source_id_char_3, 'X') = NVL (a.source_id_char_3, 'X')
             AND NVL (b.alloc_to_source_id_char_4, 'X') = NVL (a.source_id_char_4, 'X')
             AND NVL (b.alloc_to_application_id, -99) = NVL (a.application_id, -99)
             AND NVL (b.alloc_to_distribution_type, 'X') = NVL (a.source_distribution_type, 'X')
             AND NVL (b.alloc_to_dist_id_num_1, -99) = NVL (a.source_distribution_id_num_1, -99)
             AND NVL (b.alloc_to_dist_id_num_2, -99) = NVL (a.source_distribution_id_num_2, -99)
             AND NVL (b.alloc_to_dist_id_num_3, -99) = NVL (a.source_distribution_id_num_3, -99)
             AND NVL (b.alloc_to_dist_id_num_4, -99) = NVL (a.source_distribution_id_num_4, -99)
             AND NVL (b.alloc_to_dist_id_num_5, -99) = NVL (a.source_distribution_id_num_5, -99)
             AND NVL (b.alloc_to_dist_id_char_1, 'X') = NVL (a.source_distribution_id_char_1, 'X')
             AND NVL (b.alloc_to_dist_id_char_2, 'X') = NVL (a.source_distribution_id_char_2, 'X')
             AND NVL (b.alloc_to_dist_id_char_3, 'X') = NVL (a.source_distribution_id_char_3, 'X')
             AND NVL (b.alloc_to_dist_id_char_4, 'X') = NVL (a.source_distribution_id_char_4, 'X')
             AND NVL (b.alloc_to_dist_id_char_5, 'X') = NVL (a.source_distribution_id_char_5, 'X')
         )
       AND EXISTS
         (
         SELECT
             'Parent transaction allocation setup exists'
         FROM psa_bc_alloc_v a,
             psa_bc_alloc_v b
         WHERE a.ROW_ID = b.ROW_ID
             AND NVL (b.alloc_to_entity_code, 'X') = NVL (a.entity_code, 'X')
             AND NVL (b.alloc_to_source_id_num_1, -99) = NVL (a.source_id_int_1, -99)
             AND NVL (b.alloc_to_source_id_num_2, -99) = NVL (a.source_id_int_2, -99)
             AND NVL (b.alloc_to_source_id_num_3, -99) = NVL (a.source_id_int_3, -99)
             AND NVL (b.alloc_to_source_id_num_4, -99) = NVL (a.source_id_int_4, -99)
             AND NVL (b.alloc_to_source_id_char_1, 'X') = NVL (a.source_id_char_1, 'X')
             AND NVL (b.alloc_to_source_id_char_2, 'X') = NVL (a.source_id_char_2, 'X')
             AND NVL (b.alloc_to_source_id_char_3, 'X') = NVL (a.source_id_char_3, 'X')
             AND NVL (b.alloc_to_source_id_char_4, 'X') = NVL (a.source_id_char_4, 'X')
             AND NVL (b.alloc_to_application_id, -99) = NVL (a.application_id, -99)
             AND NVL (b.alloc_to_distribution_type, 'X') = NVL (a.source_distribution_type, 'X')
             AND NVL (b.alloc_to_dist_id_num_1, -99) = NVL (a.source_distribution_id_num_1, -99)
             AND NVL (b.alloc_to_dist_id_num_2, -99) = NVL (a.source_distribution_id_num_2, -99)
             AND NVL (b.alloc_to_dist_id_num_3, -99) = NVL (a.source_distribution_id_num_3, -99)
             AND NVL (b.alloc_to_dist_id_num_4, -99) = NVL (a.source_distribution_id_num_4, -99)
             AND NVL (b.alloc_to_dist_id_num_5, -99) = NVL (a.source_distribution_id_num_5, -99)
             AND NVL (b.alloc_to_dist_id_char_1, 'X') = NVL (a.source_distribution_id_char_1, 'X')
             AND NVL (b.alloc_to_dist_id_char_2, 'X') = NVL (a.source_distribution_id_char_2, 'X')
             AND NVL (b.alloc_to_dist_id_char_3, 'X') = NVL (a.source_distribution_id_char_3, 'X')
             AND NVL (b.alloc_to_dist_id_char_4, 'X') = NVL (a.source_distribution_id_char_4, 'X')
             AND NVL (b.alloc_to_dist_id_char_5, 'X') = NVL (a.source_distribution_id_char_5, 'X')
         )
     ;

     -- Find out the base transactions
     /* Base transaction (e.g. PO) will be identified as their base
        transaction attributes will be same as allocation attributes */
     CURSOR c_get_parent_trx IS
     SELECT
       DISTINCT
         ENTITY_CODE ,
         SOURCE_ID_INT_1 ,
         SOURCE_ID_INT_2 ,
         SOURCE_ID_INT_3 ,
         SOURCE_ID_INT_4 ,
         SOURCE_ID_CHAR_1 ,
         SOURCE_ID_CHAR_2 ,
         SOURCE_ID_CHAR_3 ,
         SOURCE_ID_CHAR_4 ,
         APPLICATION_ID,
         SOURCE_DISTRIBUTION_ID_NUM_1 ,
         SOURCE_DISTRIBUTION_ID_NUM_2 ,
         SOURCE_DISTRIBUTION_ID_NUM_3 ,
         SOURCE_DISTRIBUTION_ID_NUM_4 ,
         SOURCE_DISTRIBUTION_ID_NUM_5 ,
         SOURCE_DISTRIBUTION_TYPE,
         SOURCE_DISTRIBUTION_ID_CHAR_1 ,
         SOURCE_DISTRIBUTION_ID_CHAR_2 ,
         SOURCE_DISTRIBUTION_ID_CHAR_3 ,
         SOURCE_DISTRIBUTION_ID_CHAR_4 ,
         SOURCE_DISTRIBUTION_ID_CHAR_5
     FROM psa_bc_alloc_v a
     WHERE EXISTS
         (
         SELECT
             'Accounting line is allocated to itself'
         FROM psa_bc_alloc_v b
         WHERE b.ROW_ID = a.ROW_ID
             AND NVL(b.ALLOC_TO_ENTITY_CODE, 'X') = NVL(a.ENTITY_CODE, 'X')
             AND NVL(b.ALLOC_TO_SOURCE_ID_NUM_1, -99)= NVL(a.SOURCE_ID_INT_1, -99)
             AND NVL(b.ALLOC_TO_SOURCE_ID_NUM_2, -99) = NVL(a.SOURCE_ID_INT_2, -99)
             AND NVL(b.ALLOC_TO_SOURCE_ID_NUM_3, -99) = NVL(a.SOURCE_ID_INT_3, -99)
             AND NVL(b.ALLOC_TO_SOURCE_ID_NUM_4, -99) = NVL(a.SOURCE_ID_INT_4, -99)
             AND NVL(b.ALLOC_TO_SOURCE_ID_CHAR_1, 'X') = NVL(a.SOURCE_ID_CHAR_1, 'X')
             AND NVL(b.ALLOC_TO_SOURCE_ID_CHAR_2, 'X') = NVL(a.SOURCE_ID_CHAR_2, 'X')
             AND NVL(b.ALLOC_TO_SOURCE_ID_CHAR_3, 'X') = NVL(a.SOURCE_ID_CHAR_3, 'X')
             AND NVL(b.ALLOC_TO_SOURCE_ID_CHAR_4, 'X') = NVL(a.SOURCE_ID_CHAR_4, 'X')
             AND NVL(b.alloc_to_application_id, -99) = NVL (a.application_id, -99)
             AND NVL(b.alloc_to_distribution_type, 'X') = NVL(a.source_distribution_type, 'X')
             AND NVL(b.alloc_to_dist_id_num_1, -99) = NVL(a.source_distribution_id_num_1, -99)
             AND NVL(b.alloc_to_dist_id_num_2, -99) = NVL(a.source_distribution_id_num_2, -99)
             AND NVL(b.alloc_to_dist_id_num_3, -99) = NVL(a.source_distribution_id_num_3, -99)
             AND NVL(b.alloc_to_dist_id_num_4, -99) = NVL(a.source_distribution_id_num_4, -99)
             AND NVL(b.alloc_to_dist_id_num_5, -99) = NVL(a.source_distribution_id_num_5, -99)
             AND NVL(b.alloc_to_dist_id_char_1, 'X') = NVL(a.source_distribution_id_char_1, 'X')
             AND NVL(b.alloc_to_dist_id_char_2, 'X') = NVL(a.source_distribution_id_char_2, 'X')
             AND NVL(b.alloc_to_dist_id_char_3, 'X') = NVL(a.source_distribution_id_char_3, 'X')
             AND NVL(b.alloc_to_dist_id_char_4, 'X') = NVL(a.source_distribution_id_char_4, 'X')
             AND NVL(b.alloc_to_dist_id_char_5, 'X') = NVL(a.source_distribution_id_char_5, 'X')
         )
         ;

     -- For each base transactions find out its child transactions
     CURSOR c_get_child_trx (P_ENTITY_CODE VARCHAR2 ,
                             P_SOURCE_ID_INT_1 NUMBER ,
                             P_SOURCE_ID_INT_2 NUMBER,
                             P_SOURCE_ID_INT_3 NUMBER,
                             P_SOURCE_ID_INT_4 NUMBER,
                             P_SOURCE_ID_CHAR_1 VARCHAR2,
                             P_SOURCE_ID_CHAR_2 VARCHAR2,
                             P_SOURCE_ID_CHAR_3 VARCHAR2,
                             P_SOURCE_ID_CHAR_4 VARCHAR2,
                             P_APPLICATION_ID VARCHAR2,
                             P_SOURCE_DIST_ID_NUM_1 NUMBER,
                             P_SOURCE_DIST_ID_NUM_2 NUMBER,
                             P_SOURCE_DIST_ID_NUM_3 NUMBER,
                             P_SOURCE_DIST_ID_NUM_4 NUMBER,
                             P_SOURCE_DIST_ID_NUM_5 NUMBER,
                             P_SOURCE_DIST_TYPE VARCHAR2,
                             P_SOURCE_DIST_ID_CHAR_1 VARCHAR2,
                             P_SOURCE_DIST_ID_CHAR_2 VARCHAR2,
                             P_SOURCE_DIST_ID_CHAR_3 VARCHAR2,
                             P_SOURCE_DIST_ID_CHAR_4 VARCHAR2,
                             P_SOURCE_DIST_ID_CHAR_5 VARCHAR2)
     IS
     SELECT
         ae_header_id,
         ae_line_num,
         event_id
     FROM psa_bc_alloc_v
     WHERE NVL(ALLOC_TO_ENTITY_CODE, 'X') = NVL(p_entity_code, 'X')
         AND NVL(ALLOC_TO_SOURCE_ID_NUM_1, -99) = NVL(p_source_id_int_1, -99)
         AND NVL(ALLOC_TO_SOURCE_ID_NUM_2, -99) = NVL(p_source_id_int_2, -99)
         AND NVL(ALLOC_TO_SOURCE_ID_NUM_3, -99) = NVL(p_source_id_int_3, -99)
         AND NVL(ALLOC_TO_SOURCE_ID_NUM_4, -99) = NVL(p_source_id_int_4, -99)
         AND NVL(ALLOC_TO_SOURCE_ID_CHAR_1, 'X') = NVL(p_source_id_char_1, 'X')
         AND NVL(ALLOC_TO_SOURCE_ID_CHAR_2, 'X') = NVL(p_source_id_char_2, 'X')
         AND NVL(ALLOC_TO_SOURCE_ID_CHAR_3, 'X') = NVL(p_source_id_char_3, 'X')
         AND NVL(ALLOC_TO_SOURCE_ID_CHAR_4, 'X') = NVL(p_source_id_char_4, 'X')
         AND NVL(ALLOC_TO_APPLICATION_ID, -99) = NVL(p_application_id, -99)
         AND NVL(ALLOC_TO_DIST_ID_NUM_1 , -99) = NVL(p_source_dist_id_num_1 , -99)
         AND NVL(ALLOC_TO_DIST_ID_NUM_2 , -99) = NVL(p_source_dist_id_num_2 , -99)
         AND NVL(ALLOC_TO_DIST_ID_NUM_3 , -99) = NVL(p_source_dist_id_num_3 , -99)
         AND NVL(ALLOC_TO_DIST_ID_NUM_4 , -99) = NVL(p_source_dist_id_num_4 , -99)
         AND NVL(ALLOC_TO_DIST_ID_NUM_5 , -99) = NVL(p_source_dist_id_num_5 , -99)
         AND NVL(ALLOC_TO_DISTRIBUTION_TYPE, 'X') = NVL(p_source_dist_type, 'X')
         AND NVL(ALLOC_TO_DIST_ID_CHAR_1 , 'X') = NVL(p_source_dist_id_char_1 , 'X')
         AND NVL(ALLOC_TO_DIST_ID_CHAR_2 , 'X') = NVL(p_source_dist_id_char_2 , 'X')
         AND NVL(ALLOC_TO_DIST_ID_CHAR_3 , 'X') = NVL(p_source_dist_id_char_3 , 'X')
         AND NVL(ALLOC_TO_DIST_ID_CHAR_4 , 'X') = NVL(p_source_dist_id_char_4 , 'X')
         AND NVL(ALLOC_TO_DIST_ID_CHAR_5 , 'X') = NVL(p_source_dist_id_char_5 , 'X')
     ;

     -- Get the hierarchy id
     CURSOR c_get_hierarchy_id
     IS
     SELECT
         DISTINCT(hierarchy_id)
     FROM psa_bc_alloc_gt;

     -- Check whether for a hierarchy events funds check/reserve is
     -- failed/rejected.
     CURSOR c_chk_funds_hier(p_hierarchy_id NUMBER,
                             p_session_id NUMBER,
                             p_serial_id NUMBER)
     IS
     SELECT 'Funds Failure for hierarchy'
      FROM DUAL
      WHERE EXISTS
      (SELECT 'X' FROM GL_BC_PACKETS
       WHERE (ae_header_id, ae_line_num, event_id)
             IN (select ae_header_id, ae_line_num, event_id
                      from psa_bc_alloc_gt
                      where hierarchy_id = p_hierarchy_id
                        and status_code = 'P'
                )
         AND status_code IN ('F', 'R')
         AND session_id = p_session_id
         AND serial_id  = p_serial_id) ;

     CURSOR c_pkt_retcode (p_packet_id NUMBER)
     IS
     SELECT DECODE (COUNT (*),
                    COUNT (DECODE (SUBSTR (bp.result_code, 1, 1), 'P', 1)), DECODE
                                             (SIGN (COUNT (DECODE (bp.result_code,
                                                                   'P20', 1,
                                                                   'P22', 1,
                                                                   'P25', 1,
                                                                   'P27', 1,
                                                                   'P31', 1,
                                                                   'P35', 1,
                                                                   'P36', 1,
                                                                   'P37', 1,
                                                                   'P38', 1,
                                                                   'P39', 1
                                                                  )
                                                          )
                                                   ),
                                              0, 'S',
                                              1, 'A'
                                             ),
                    COUNT (DECODE (SUBSTR (bp.result_code, 1, 1), 'F', 1)), 'F',
                    DECODE (DECODE (psa_bc_xla_pvt.g_bc_mode,
                                    'C', 'Y',
                                    'M', 'N',
                                    'P', 'Y',
                                    'N'
                                   ),
                            'Y', 'P',
                            'F'
                           )
                   )
       FROM gl_bc_packets bp
      WHERE bp.packet_id = p_packet_id AND bp.template_id IS NULL;

     -- Bug 5397349 .. Start
     CURSOR c_get_result_codes (p_packet_id IN NUMBER) IS
     SELECT result_code, ae_header_id, ae_line_num
     FROM   gl_bc_packets
     WHERE  packet_id = p_packet_id;

     TYPE result_code_tbl_type IS TABLE OF gl_bc_packets.result_code%type INDEX BY binary_integer;
     TYPE xla_hdr_tbl_type IS TABLE OF gl_bc_packets.ae_header_id%type INDEX BY binary_integer;
     TYPE xla_line_tbl_type IS TABLE OF gl_bc_packets.ae_line_num%type INDEX BY binary_integer;

     l_result_code_tbl result_code_tbl_type;
     l_xla_hdr_tbl xla_hdr_tbl_type;
     l_xla_line_tbl xla_line_tbl_type;
     -- Bug 5397349 .. End

     l_var_1 number;
     l_var_2 number;
     l_xla_hdr_status VARCHAR2(1);
     l_ae_lines_gt ae_lines_gt_rec;
     l_validation_lines_gt validation_lines_gt_rec;
     l_ledger_category gl_ledgers.ledger_category_code%type;
     l_event_cnt NUMBER;
     l_ae_event_cnt NUMBER;

     -- Allocation Attributes related variables
     l_parent_trx c_get_parent_trx%ROWTYPE;
     l_child_trx c_get_child_trx%ROWTYPE;
     dummy VARCHAR2(100);
     l_alloc_used VARCHAR2(1);
     l_alloc_event_cnt NUMBER;
     l_xla_event_cnt NUMBER;
     l_parent_cnt NUMBER;

  BEGIN

    l_full_path := g_path || 'budgetary_control';

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' BCTRL -> P_LEDGERID = '||p_ledgerid);
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' BCTRL -> MODE = '||PSA_BC_XLA_PVT.G_BC_MODE);
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' BCTRL -> OVERRIDE = '||PSA_BC_XLA_PVT.G_OVERRIDE_FLAG);
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' BCTRL -> USER_ID = '||PSA_BC_XLA_PVT.G_USER_ID);
        psa_utils.debug_other_string(g_state_level,l_full_path,
                                     ' BCTRL -> RESP_ID = '||PSA_BC_XLA_PVT.G_USER_RESP_ID);
     -- ====== FND LOG ======
     check_for_xla_errors ('BFLOW', l_xla_return_code);
     IF (l_xla_return_code = 'Y') THEN
        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> Bflow failed ');
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> ERROR: FATAL ');
        -- ====== FND LOG ======

        p_return_code := 'T';
        return FALSE;
     END IF;


     -- First invoke GLXFIN and assign values to global variables.

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Invoking glxfin() ');
     -- ====== FND LOG ======

     if not glxfin     (p_ledgerid          =>    p_ledgerid,
                        p_packetid          =>    0,
                        p_mode              =>    PSA_BC_XLA_PVT.G_BC_MODE,
                        p_override          =>    PSA_BC_XLA_PVT.G_OVERRIDE_FLAG,
                        p_conc_flag         =>    'N',
                        p_user_id           =>    PSA_BC_XLA_PVT.G_USER_ID,
                        p_user_resp_id      =>    PSA_BC_XLA_PVT.G_USER_RESP_ID,
                        p_calling_prog_flag =>    'S') then

        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> glxfin failed ');
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> ERROR: FATAL ');
        -- ====== FND LOG ======

        p_return_code := 'T';
        return FALSE;
     end if;

     -- Invoke the DEBUG_XLA procedure to transfer data from XLA global temporary tables to
     -- PSA regular tables.

     debug_xla ( 'BUDGETARY_CONTROL_START' );

     -- Check whether all the events in XLA_EVENTS_GT
     -- are available in XLA_AE_LINES_GT.
     /* If some events are missing that means that there is some issue in SLA
        setup for the event, that's why SLA didn't put that event to be
        considered for accounting. In this case Funds Checker API
        will treat this as an FATAL situation and will not process further. */
     OPEN c_cnt_events;
     FETCH c_cnt_events INTO l_event_cnt, l_ae_event_cnt;
     CLOSE c_cnt_events;

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_error_level,l_full_path,
        ' BCTRL -> Count of events in XLA_EVENTS_GT: '||l_event_cnt);
        psa_utils.debug_other_string(g_error_level,l_full_path,
        ' BCTRL -> Count of events in XLA_AE_LINES_GT: '||l_ae_event_cnt);
     -- ====== FND LOG ======

           fnd_file.put_line(fnd_file.log,'The following are the invalid accounting errrors');
           fnd_file.put_line(fnd_file.log,'=============================================== ');
          for acc_error in ( select  document_reference , encoded_message
                               from psa_bc_accounting_errors b
			where event_id in (select event_id from xla_events_gt))
           loop
           fnd_file.put_line(fnd_file.log , ' document_referece ' || acc_error.document_reference);
           fnd_file.put_line(fnd_file.log ,   acc_error.encoded_message);
           End loop;

     IF NOT(NVL(l_ae_event_cnt, 0) = l_event_cnt) THEN
        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> Budgetary_Control failed ');
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> ERROR: FATAL ');
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL p_return_code -> T');
           psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL Return False ');

           check_for_xla_errors ('EVENTS_NOT_PROCESSED', l_xla_return_code);

           fnd_file.put_line(fnd_file.log,'The following entities have not been processed');
           fnd_file.put_line(fnd_file.log,'======================================= ');
	for missing_entity in
	 ( select e.entity_id,g.event_id,g.source_id_int_2,e.transaction_number
             from xla_transaction_entities_upg e , xla_events_gt g
          where g.entity_id = e.entity_id
          and g.event_id not in (select  event_id from xla_ae_lines_gt) )
        loop
           fnd_file.put_line(fnd_file.log , ' BC_Event_id ' || missing_entity.event_id  || '  Transaction Number ' || missing_entity.transaction_number || ' Distribution id ' || missing_entity.source_id_int_2 );
        end loop;


        -- ====== FND LOG ======

        p_return_code := 'T';
        return FALSE;
     END IF;

     -- Initialize the collection variables

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Initializing collection ');
     -- ====== FND LOG ======

     l_packets := num_rec();

     -- Get the session_id and serial# for the current session
     -- These columns will then be inserted in gl_bc_packets.

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Invoking get_session_details() ');
     -- ====== FND LOG ======

     get_session_details(l_session_id, l_serial_id);

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Session_Id = '||l_session_id);
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Serial_Id = '||l_serial_id);
     -- ====== FND LOG ======

     -- Get the JE_SOURCE_NAME for current application

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Get Je_Source_name ');
     -- ====== FND LOG ======

     open get_je_source_name(PSA_BC_XLA_PVT.G_APPLICATION_ID);
     fetch get_je_source_name into l_je_source_name;
     if get_je_source_name%notfound then
        raise invalid_je_source_name;
     end if;
     close get_je_source_name;


     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> JE_SOURCE_NAME = '||l_je_source_name);
     -- ====== FND LOG ======

     --================== Allocation Attributes first level of validation Logic Start ======================
     /* First level of validation for allocation attributes is two fold:
        1) We check whether transaction lines are related with allocation attributes or not.
           If allocation attributes are NOT used we do the normal processing.
        2) Using allocation attributes we find out the relationship amongst trx lines and
           store this information into PSA_BC_ALLOC_GT. Events stored in this table are sampled with
           events of XLA_PSA_BC_LINES_V. If any event is missing we disallow the group of related
           transaction rows to go in for funds operation. */

     -- Preliminary check for allocation attributes usage.
     OPEN c_chk_alloc_used;
     FETCH c_chk_alloc_used INTO dummy;

     IF c_chk_alloc_used%FOUND THEN
        CLOSE c_chk_alloc_used;
        l_alloc_used := 'Y';
     ELSE
        CLOSE c_chk_alloc_used;
        l_alloc_used := 'N';
     END IF;

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path,
        ' BCTRL -> Allocation Attributes used (Y/N) = '||l_alloc_used);
     -- ====== FND LOG ======

     IF (l_alloc_used = 'Y') THEN
        -- Initialize Parent counter;
        l_parent_cnt := 1;
        -- Find parent transactions;
        OPEN c_get_parent_trx;
        LOOP
           FETCH c_get_parent_trx INTO l_parent_trx;
           EXIT WHEN c_get_parent_trx%NOTFOUND;
           -- Find child transactions
           OPEN c_get_child_trx(l_parent_trx.ENTITY_CODE ,
                                l_parent_trx.SOURCE_ID_INT_1 ,
                                l_parent_trx.SOURCE_ID_INT_2 ,
                                l_parent_trx.SOURCE_ID_INT_3 ,
                                l_parent_trx.SOURCE_ID_INT_4 ,
                                l_parent_trx.SOURCE_ID_CHAR_1 ,
                                l_parent_trx.SOURCE_ID_CHAR_2 ,
                                l_parent_trx.SOURCE_ID_CHAR_3 ,
                                l_parent_trx.SOURCE_ID_CHAR_4 ,
                                l_parent_trx.APPLICATION_ID,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_NUM_1 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_NUM_2 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_NUM_3 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_NUM_4 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_NUM_5 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_TYPE,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_CHAR_1 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_CHAR_2 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_CHAR_3 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_CHAR_4 ,
                                l_parent_trx.SOURCE_DISTRIBUTION_ID_CHAR_5
                               );
           LOOP
              FETCH c_get_child_trx INTO l_child_trx;
              EXIT WHEN c_get_child_trx%NOTFOUND;
              -- now insert parent and child transactions in psa_bc_alloc_gt
              -- with a initial status of 'U' (Unprocessed)
              INSERT INTO psa_bc_alloc_gt (
                      hierarchy_id,
                      ae_header_id,
                      ae_line_num,
                      event_id,
                      status_code
                     ) VALUES (
                      l_parent_cnt,
                      l_child_trx.ae_header_id,
                      l_child_trx.ae_line_num,
                      l_child_trx.event_id,
                      'U'
              );
           END LOOP;
           CLOSE c_get_child_trx;
           -- Increase the parent counter;
           l_parent_cnt := l_parent_cnt + 1;
        END LOOP;
        CLOSE c_get_parent_trx;

        -- Now we will check that which hierarchy events should be
        -- allowed to go in funds checker by setting their
        -- status_code to 'P'(Passed) or 'F'(Failed)
        FOR h IN c_get_hierarchy_id
        LOOP
           SELECT
               COUNT(DISTINCT(event_id))
           INTO l_alloc_event_cnt
           FROM psa_bc_alloc_gt
           WHERE hierarchy_id = h.hierarchy_id;

           -- ======================== FND LOG =============================
           psa_utils.debug_other_string(g_state_level, l_full_path, ' l_alloc_event_cnt -> '||l_alloc_event_cnt);
           -- ======================== FND LOG =============================

           SELECT
               COUNT(DISTINCT(xv.event_id))
           INTO l_xla_event_cnt
           FROM xla_psa_bc_lines_v xv
           WHERE xv.event_id IN
               (
                   (
                   SELECT
                       pa1.event_id
                   FROM psa_bc_alloc_gt pa1
                   WHERE pa1.hierarchy_id = h.hierarchy_id
                   )
                   MINUS
                   (
                   SELECT
                       pa2.event_id
                   FROM psa_bc_alloc_gt pa2
                   WHERE pa2.event_id = xv.event_id
                     AND pa2.status_code = 'F'
                   )
               );

           -- ======================== FND LOG =============================
           psa_utils.debug_other_string(g_state_level, l_full_path, ' l_xla_event_cnt -> '||l_xla_event_cnt);
           -- ======================== FND LOG =============================

           -- Compare both the counts. if they are equal
           -- then the hierarchy events are eligible for funds check
           IF (l_alloc_event_cnt = NVL(l_xla_event_cnt, 0)) THEN
              UPDATE
                  psa_bc_alloc_gt
                  SET status_code = 'P'
              WHERE hierarchy_id = h.hierarchy_id;
              -- ====== FND LOG ======
                 psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated '||sql%rowcount||
                                              ' rows.');
              -- ====== FND LOG ======
           ELSE
              UPDATE
                  psa_bc_alloc_gt
                  SET status_code = 'F'
              WHERE hierarchy_id = h.hierarchy_id;
              -- ====== FND LOG ======
                 psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated '||sql%rowcount||
                                              ' rows.');
              -- ====== FND LOG ======
           END IF;
        END LOOP;
     END IF;
     --=================== Allocation Attributes first level of validation Logic End ===========================


     -- Now select the event_id and other information to be inserted
     -- in gl_bc_packets in plsql table. We will select all event_id
     -- to be inserted at one go for performance reasons. I have selected all columns
     -- from gl_bc_packets and put NULL for columns which should not be populated. This is to
     -- overcome a limitation with FORALL clause later in the code.


     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Populate l_bc_pkts pl/sql table ');
     -- ====== FND LOG ======

     SELECT NULL,                             -- Packet_id is initially NULL. Populated later in the code
            p_ledgerid,                       -- Since XLA view does not provide this column, use parameter
            nvl(l_je_source_name, 'Manual'),
            xv.je_category_name,
            xv.code_combination_id,
            xv.balance_type_code,
            xv.period_name,
            ps.period_year,
            ps.period_num,
            ps.quarter_num,
            xv.entered_currency_code,
     --       decode(psa_bc_xla_pvt.g_bc_mode, 'C', 'C', 'P'), Bug 6452856.
            decode(psa_bc_xla_pvt.g_bc_mode, 'C', 'C','M', 'C', 'P'),
            sysdate,
            g_user_id,
            xv.budget_version_id,              -- BUDGET_VERSION_ID
            xv.encumbrance_type_id,
            NULL,                              -- TEMPLATE_ID
            xv.entered_dr,
            xv.entered_cr,
            xv.accounted_dr,
            xv.accounted_cr,
            NULL,                              -- USSGL_TRANSACTION_CODE
            NULL,                              -- ORIGINATING_ROWID
            NULL,                              -- ACCOUNT_SEGMENT_VALUE
            NULL,                              -- AUTOMATIC_ENCUMBRANCE_FLAG
            NULL,                              -- FUNDING_BUDGET_VERSION_ID
            NULL,                              -- FUNDS_CHECK_LEVEL_CODE
            NULL,                              -- AMOUNT_TYPE
            NULL,                              -- BOUNDARY_CODE
            NULL,                              -- TOLERANCE_PERCENTAGE
            NULL,                              -- TOLERANCE_AMOUNT
            NULL,                              -- OVERRIDE_AMOUNT
            NULL,                              -- DR_CR_CODE
            NULL,                              -- ACCOUNT_TYPE
            NULL,                              -- ACCOUNT_CATEGORY_CODE
            NULL,                              -- EFFECT_ON_FUNDS_CODE
            NULL,                              -- RESULT_CODE
            NULL,                              -- BUDGET_POSTED_BALANCE
            NULL,                              -- ACTUAL_POSTED_BALANCE
            NULL,                              -- ENCUMBRANCE_POSTED_BALANCE
            NULL,                              -- BUDGET_APPROVED_BALANCE
            NULL,                              -- ACTUAL_APPROVED_BALANCE
            NULL,                              -- ENCUMBRANCE_APPROVED_BALANCE
            NULL,                              -- BUDGET_PENDING_BALANCE
            NULL,                              -- ACTUAL_PENDING_BALANCE
            NULL,                              -- ENCUMBRANCE_PENDING_BALANCE
            NULL,                              -- REFERENCE1
            NULL,                              -- REFERENCE2
            NULL,                              -- REFERENCE3
            NULL,                              -- REFERENCE4
            NULL,                              -- REFERENCE5
            NULL,                              -- JE_BATCH_NAME
            -1,                                -- JE_BATCH_ID
            NULL,                              -- JE_HEADER_ID
            NULL,                              -- JE_LINE_NUM
            NULL,                              -- JE_LINE_DESCRIPTION
            NULL,                              -- REFERENCE6
            NULL,                              -- REFERENCE7
            NULL,                              -- REFERENCE8
            NULL,                              -- REFERENCE9
            NULL,                              -- REFERENCE10
            NULL,                              -- REFERENCE11
            NULL,                              -- REFERENCE12
            NULL,                              -- REFERENCE13
            NULL,                              -- REFERENCE14
            NULL,                              -- REFERENCE15
            NULL,                              -- REQUEST_ID
            NULL,                              -- USSGL_PARENT_ID
            NULL,                              -- USSGL_LINK_TO_PARENT_ID
            xv.event_id,
            xv.ae_header_id,
            xv.ae_line_num,
            NULL,                              -- BC_DATE
            xv.source_distribution_type,
            xv.source_distribution_id_char_1,
            xv.source_distribution_id_char_2,
            xv.source_distribution_id_char_3,
            xv.source_distribution_id_char_4,
            xv.source_distribution_id_char_5,
            xv.source_distribution_id_num_1,
            xv.source_distribution_id_num_2,
            xv.source_distribution_id_num_3,
            xv.source_distribution_id_num_4,
            xv.source_distribution_id_num_5,
            l_session_id,
            l_serial_id,
            psa_bc_xla_pvt.g_application_id,
            xv.entity_id,
            NULL                               -- GROUP_ID
            BULK COLLECT INTO l_bc_pkts
     FROM xla_psa_bc_lines_v xv,
          gl_period_statuses ps
     WHERE ps.ledger_id = p_ledgerid and
           xv.period_name = ps.period_name and
           ps.application_id = 101 and
           -- Bug 4778812 start
           (
             (l_alloc_used = 'Y' and
              xv.event_id IN (
                 SELECT event_id
                 FROM psa_bc_alloc_gt
                 WHERE status_code = 'P')
             )
             OR
             (l_alloc_used = 'N')
           )
           -- Bug 4778812 end
     ORDER BY xv.entity_id, (nvl(entered_dr, 0)-nvl(entered_cr, 0)), source_distribution_id_num_1;

     IF SQL%NOTFOUND THEN

        check_for_xla_errors ('GL_BC_PACKETS_EMPTY', l_xla_return_code);

        OPEN get_ledger_category(p_ledgerid);
        FETCH get_ledger_category INTO l_ledger_category;
        CLOSE get_ledger_category;

        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Ledger Category: '||l_ledger_category);
           psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Application Id: '||psa_bc_xla_pvt.g_application_id);
        -- ====== FND LOG ======

        IF (l_ledger_category = 'PRIMARY') OR (psa_bc_xla_pvt.g_application_id = 602) THEN
               -- ==================== FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path, ' l_ledger_category = PRIMARY OR (psa_bc_xla_pvt.g_application_id = 602 --> raise gl_bc_packets_empty');
               -- ==================== FND LOG ===========================

           raise gl_bc_packets_empty;
        ELSE

           -- ====== FND LOG ======
              psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Do not process for Secondary Ledger ');
              psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Return True');
              psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL p_return_code -> S ');
           -- ====== FND LOG ======
           p_return_code := 'S';
           return true;
        END IF;

     ELSE

        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Populated '||sql%rowcount||' rows. ');
        -- ====== FND LOG ======
     END IF;

     -- Note above that the packet_id column was assigned a NULL value.
     -- Since packet_id will be unique per entity_id, we will use the
     -- following plsql logic to assign packet_id for each row above.
     -- Logic: Check if this is the first packet_id to be processed.
     --        If First_Packet_id then => assign new packet_id
     --        Elsif (Current Entity Id <> Previous Entity Id) then => assign new packet_id
     --        Else assign earlier packet_id.

     FOR x in 1..l_bc_pkts.count
     LOOP

        if (x = 1) then
           l_packet_id := get_packet_id;
           l_packets.extend(1);
           l_packets(l_packets.count) := l_packet_id;
        elsif (l_bc_pkts(x).entity_id <> l_bc_pkts(x-1).entity_id) then
           l_packet_id := get_packet_id;
           l_packets.extend(1);
           l_packets(l_packets.count) := l_packet_id;
        end if;

        l_bc_pkts(x).packet_id := l_packet_id;

        -- ====== FND LOG ======
           psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Row '||x||' assigned packet_id '||l_packet_id);
        -- ====== FND LOG ======

     END LOOP;

     -- Insert autonomous procedure populate_bc_pkts to insert data in gl_bc_packets

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Invoking populate_bc_pkts() ');
     -- ====== FND LOG ======

     IF NOT populate_bc_pkts (l_bc_pkts) THEN
     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> populate_bc_pkts() failed. ');
        psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> ERROR: FATAL. ');
        psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> p_return_code -> T');
        psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> Return false ');
     -- ====== FND LOG ======
        p_return_code := 'T';
        return FALSE;
     END IF;

     -- Invoke funds checker per packet_id. Update the relevant SLA tables.

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Invoking glxfck() per packet.');
     -- ====== FND LOG ======

     FOR i IN 1..l_packets.count
     LOOP

         -- ====== FND LOG ======
            psa_utils.debug_other_string(g_state_level,l_full_path,
                                         ' BCTRL -> Invoking glxfck() for packet_id '||l_packets(i));
         -- ====== FND LOG ======

         IF NOT glxfck(    p_ledgerid                     ,
                           l_packets(i)                   ,
                           PSA_BC_XLA_PVT.G_BC_MODE       ,
                           PSA_BC_XLA_PVT.G_OVERRIDE_FLAG ,
                           'N'                            ,
                           PSA_BC_XLA_PVT.G_USER_ID       ,
                           PSA_BC_XLA_PVT.G_USER_RESP_ID  ,
                           'S'                            ,
                           l_ret_code       ) THEN

         -- ====== FND LOG ======
            psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> glxfck() failed ');
         -- ====== FND LOG ======

          -- ============================== FND LOG =========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL l_ret_code -> T ');
          -- ============================== FND LOG =========================

            l_ret_code := 'T';
         END IF;

         -- Update Funds_Status_Code column in XLA_AE_HEADERS_GT

         -- ====== FND LOG ======
            psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Update funds_status_code '||
                                         'of xla_ae_headers_gt ');
         -- ====== FND LOG ======

         IF (PSA_BC_XLA_PVT.G_BC_MODE = 'P') AND (l_ret_code <> 'T') THEN
             FOR y IN get_status_per_header(l_packets(i))
             LOOP
                 -- ====== FND LOG ======
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> GET_STATUS_PER_HEADER DETAILS ');
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> ----------------------------- ');
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.AE_HEADER_ID = '||y.ae_header_id);
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.SUCCESS_CNT = '||y.success_cnt);
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.APPROVED_CNT = '||y.approved_cnt);
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.FAILED_CNT = '||y.failed_cnt);
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.REJECTED_CNT = '||y.rejected_cnt);
                    psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Y.TOTAL_CNT = '||y.total_cnt);
                 -- ====== FND LOG ======

                 IF (y.success_cnt = y.total_cnt) OR (y.approved_cnt = y.total_cnt) THEN
                    SELECT nvl(min('A'), 'S') into l_xla_hdr_status
                    FROM gl_bc_packets
                    WHERE   packet_id = l_packets(i) and
                         ae_header_id = y.ae_header_id and
                          result_code IN ('P20', 'P22', 'P25', 'P27', 'P31', 'P35', 'P36', 'P37',
                                          'P38', 'P39');
                 ELSIF (y.failed_cnt = y.total_cnt) OR (y.rejected_cnt = y.total_cnt) THEN
                    l_xla_hdr_status := 'F';
                 ELSE
                    l_xla_hdr_status := 'P';
                 END IF;

          -- ============================== FND LOG =========================
              psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL l_xla_hdr_status -> '||l_xla_hdr_status);
          -- ============================== FND LOG =========================

                 UPDATE xla_ae_headers_gt
                 SET funds_status_code = l_xla_hdr_status
                 WHERE ae_header_id = y.ae_header_id and
                       ledger_id = p_ledgerid;

                 IF SQL%FOUND THEN
                    -- ====== FND LOG ======
                       psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> XLA Header '||y.ae_header_id||
                                                 ', Status updated to '||l_xla_hdr_status);
                    -- ====== FND LOG ======
                 END IF;

             END LOOP;
         ELSE
             UPDATE xla_ae_headers_gt
             SET funds_status_code = l_ret_code
             WHERE ae_header_id IN (SELECT ae_header_id
                                    FROM gl_bc_packets
                                    WHERE packet_id = l_packets(i)) and
                   ledger_id = p_ledgerid;

             -- ====== FND LOG ======
                psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated funds_status_code of '||
                                             sql%rowcount||' rows successfully. ');
             -- ====== FND LOG ======
         END IF;

         -- Update the l_*_status_cnt variables.

         IF (l_ret_code IN ('S','A')) THEN
           l_s_status_cnt := nvl(l_s_status_cnt, 0) + 1;
         ELSIF (l_ret_code = 'F') THEN
           l_f_status_cnt := nvl(l_f_status_cnt, 0) + 1;
         ELSIF (l_ret_code = 'P') THEN
           l_p_status_cnt := nvl(l_p_status_cnt, 0) + 1;
         ELSIF (l_ret_code = 'T') OR (l_ret_code IS NULL) THEN
           l_t_status_cnt := nvl(l_t_status_cnt, 0) + 1;
         END IF;

     END LOOP;

     -- Update Funds_Status_Code column in XLA_VALIDATION_LINES_GT

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Update funds_status_code '||
                                     'of xla_validation_lines_gt');
     -- ====== FND LOG ======

     -- Bug 5397349 .. Start

     FOR i IN 1..l_packets.count
     LOOP

        OPEN c_get_result_codes (l_packets(i));

        LOOP
           FETCH c_get_result_codes bulk collect into l_result_code_tbl, l_xla_hdr_tbl, l_xla_line_tbl LIMIT 5000;

           FORALL x IN 1..l_result_code_tbl.count
              UPDATE xla_validation_lines_gt vl
              SET vl.funds_status_code = l_result_code_tbl(x)
              WHERE vl.ae_header_id = l_xla_hdr_tbl(x) AND
                    vl.ae_line_num  = l_xla_line_tbl(x) AND
                    vl.ledger_id    = p_ledgerid;

           -- ====== FND LOG ======
              psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated '||sql%rowcount||
                                           ' rows.');
           -- ====== FND LOG ======

           EXIT when c_get_result_codes%notfound;
        END LOOP;

        CLOSE c_get_result_codes;
     END LOOP;

     -- Bug 5397349 .. End

     -- Update PSA_BC_XLA_EVENTS_GT table with result_code

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Update result_code '||
                                     'of psa_bc_xla_events_gt');
     -- ====== FND LOG ======

     -- this update will ensure that only valid xla events
     -- provided for FUNDS CHECK (meant xla_ae_headers rows updated with funds_status_code)
     -- are updated with appropiate status. Events NOT picked by funds checker will be updated with XLA_ERROR.
     UPDATE psa_bc_xla_events_gt eg
        SET result_code = (SELECT decode(min(funds_status_code),
                                         'T', 'FATAL',
                                         'S', 'SUCCESS',
                                         'A', 'ADVISORY',
                                         'F', 'FAIL',
                                         'P', 'PARTIAL',
                                         'XLA_ERROR')
                           FROM xla_ae_headers_gt hg
                           WHERE hg.event_id = eg.event_id)
        where eg.event_id in (select event_id from xla_ae_headers_gt);

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated valid funds check '||sql%rowcount||
                                     ' rows.');
     -- ====== FND LOG ======

     -- Update global variable for packet_id to the first packet_id

       PSA_BC_XLA_PVT.G_PACKET_ID := l_packets(1);

       -- ====== FND LOG ======
          psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated '||
                                       ' PSA_BC_XLA_PVT.G_PACKET_ID to '||PSA_BC_XLA_PVT.G_PACKET_ID);
       -- ====== FND LOG ======

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> l_t_status_cnt = '||l_t_status_cnt);
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> l_s_status_cnt = '||l_s_status_cnt);
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> l_a_status_cnt = '||l_a_status_cnt);
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> l_f_status_cnt = '||l_f_status_cnt);
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> l_p_status_cnt = '||l_p_status_cnt);
     -- ====== FND LOG ======

     -- Bug 4918234
     /* We need to update the related events stauses which were NOT picked up by funds checker.
        e.g. PA BURDEN lines failed XLA validation but corresponding PO RAW passed XLA validation
        or PO RAW line failed XLA validation but corresponding PA BURDEN lines passed XLA validation.
     */

     -- Update Funds_Status_Code column in XLA_AE_HEADERS_GT
     UPDATE xla_ae_headers_gt
        SET funds_status_code = 'F'
      WHERE event_id IN (
                        SELECT event_id
                          FROM psa_bc_alloc_gt
                         WHERE status_code <> 'P');

    IF(SQL%ROWCOUNT<> 0) THEN
        -- ====== FND LOG ======
            psa_utils.debug_other_string(g_state_level,l_full_path, ' BCTRL -> Updated '||sql%rowcount||' rows of XLA_AE_HEADERS_GT with fail status.');
        -- ====== FND LOG ======
    END IF;

    -- Update Funds_Status_Code column in XLA_VALIDATION_LINES_GT
    UPDATE xla_validation_lines_gt vl
       SET vl.funds_status_code = 'F76'
     WHERE event_id IN (
                        SELECT event_id
                          FROM psa_bc_alloc_gt
                         WHERE status_code <> 'P');

    IF(SQL%ROWCOUNT<> 0) THEN
        -- ====== FND LOG ======
            psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated ' ||sql%rowcount||' rows of XLA_VALIDATION_LINES_GT with F76 status code.');
        -- ====== FND LOG ======
    END IF;

    --================== Allocation Attributes second level of validation Logic start =================
    /* Now we need to check that the transaction rows which are put for funds operation,
       have been successfully processed by funds checker. If atleast one transaction row
       for a hierarchy fails funds operation, we will fail all the related transaction rows in
       GL_BC_PACKETS with the status F77. */

    IF (l_alloc_used = 'Y') THEN
       FOR h in c_get_hierarchy_id
       LOOP
           OPEN c_chk_funds_hier(h.hierarchy_id,
                                 l_session_id,
                                 l_serial_id);
           FETCH c_chk_funds_hier INTO dummy;
           IF (c_chk_funds_hier%FOUND) THEN
              CLOSE c_chk_funds_hier;
              -- update the statuses of gl_bc_packets
              -- related rows to 'F' Failed or 'R' Rejected.
              UPDATE gl_bc_packets
              SET status_code = decode(PSA_BC_XLA_PVT.G_BC_MODE, 'C', 'F',
                                                                 'M', 'F',
                                                                 'R', 'R',
                                                                 'P', 'R')
                  ,result_code = 'F77'
              WHERE (ae_header_id, ae_line_num, event_id)
                 IN (SELECT ae_header_id, ae_line_num, event_id
                     FROM psa_bc_alloc_gt
                     WHERE hierarchy_id = h.hierarchy_id
              )
                AND status_code NOT IN ('F', 'R')
                AND session_id = l_session_id
                AND serial_id  = l_serial_id;
              -- ====== FND LOG ======
                 psa_utils.debug_other_string(g_state_level, l_full_path, 'BCTRL -> Updated '
                                              ||sql%rowcount||' rows of GL_BC_PACKETS with F77 status.');
              -- ====== FND LOG ======

           ELSE
              CLOSE c_chk_funds_hier;
           END IF;
       END LOOP;

       UPDATE xla_ae_headers_gt
       SET funds_status_code = decode(PSA_BC_XLA_PVT.G_BC_MODE, 'C', 'F',
                                                                'M', 'F',
                                                                'R', 'F',
                                                                'P', 'F')
       WHERE ae_header_id IN (SELECT ae_header_id
                              FROM gl_bc_packets
                              WHERE result_code = 'F77'
                                AND session_id = l_session_id
                                AND serial_id  =  l_serial_id) and
             ledger_id = p_ledgerid;
       -- ====== FND LOG ======
          psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated funds_status_code of '||
                                       sql%rowcount||' rows successfully of XLA_AE_HEADERS_GT. ');
       -- ====== FND LOG ======

       UPDATE xla_validation_lines_gt vl
       SET vl.funds_status_code = 'F77'
       WHERE vl.ae_header_id IN (SELECT ae_header_id
                                 FROM gl_bc_packets
                                 WHERE result_code = 'F77'
                                 AND session_id = l_session_id
                                 AND serial_id  =  l_serial_id) and
             vl.ledger_id = p_ledgerid;
       -- ====== FND LOG ======
          psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated '||sql%rowcount||
                                       ' rows of XLA_VALIDATION_LINES_GT with F77 status.');
       -- ====== FND LOG ======

       -- Reinitialize all the count variables
       l_s_status_cnt := 0;
       l_a_status_cnt := 0;
       l_f_status_cnt := 0;
       l_p_status_cnt := 0;
       l_t_status_cnt := 0;
       l_ret_code := NULL;

       -- Now for each packet evaluate the return_code
       FOR i IN 1..l_packets.COUNT
       LOOP
          OPEN c_pkt_retcode(l_packets(i));
          FETCH c_pkt_retcode INTO l_ret_code;
          CLOSE c_pkt_retcode;
          IF (l_ret_code IN ('S', 'A')) THEN
            l_s_status_cnt := nvl(l_s_status_cnt, 0) + 1;
          ELSIF (l_ret_code = 'F') THEN
            l_f_status_cnt := nvl(l_f_status_cnt, 0) + 1;
          ELSIF (l_ret_code = 'P') THEN
            l_p_status_cnt := nvl(l_p_status_cnt, 0) + 1;
          ELSIF (l_ret_code = 'T') OR (l_ret_code IS NULL) THEN
            l_t_status_cnt := nvl(l_t_status_cnt, 0) + 1;
          END IF;
          l_ret_code := NULL;
       END LOOP;

    END IF;

    --================== Allocation Attributes second level of validation Logic end =================

     -- Set the return code
     IF nvl(l_t_status_cnt , 0) > 0 THEN
       p_return_code := 'T';
     ELSIF (nvl(l_p_status_cnt, 0) > 0) OR (nvl(l_f_status_cnt, 0) > 0 AND nvl(l_s_status_cnt, 0) > 0) THEN
       p_return_code := 'P';
     ELSIF nvl(l_f_status_cnt, 0) > 0 THEN
       p_return_code := 'F';
     ELSE
       p_return_code := 'S';
     END IF;

     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Return_code = '||p_return_code);
        psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Return TRUE');
     -- ====== FND LOG ======

     -- Invoke the DEBUG_XLA procedure to transfer data from XLA global temporary tables to
     -- PSA regular tables.

     debug_xla ( 'BUDGETARY_CONTROL_END' );

     psa_utils.debug_other_string(g_state_level,l_full_path,'Cleaning up psa_bc_alloc_gt Table');
     DELETE FROM psa_bc_alloc_gt;  --For bug 7607496
     psa_utils.debug_other_string(g_state_level,l_full_path, ' Deleted Rows -> ' || SQL%ROWCOUNT);

     return TRUE;

  EXCEPTION
    WHEN GL_BC_PACKETS_EMPTY THEN
    IF (NOT g_xla_debug) THEN
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> XLA_AE_HEADERS_GT DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' -------------------- ');

       -- ====== FND LOG ======
      FOR h IN debug_xla_ae_headers_gt
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' EVENT_ID = '||h.event_id||' , '||
                                                                 ' AE_HEADER_ID = '||h.ae_header_id||' , '||
                                                                 ' LEDGER_ID = '||h.ledger_id||' , '||
                                                                 ' EVENT_TYPE_CODE = '||h.event_type_code||' , '||
                                                                 ' FUNDS_STATUS_CODE = '||h.funds_status_code||' , '||
                                                                 ' ACCOUNTING_ENTRY_STATUS_CODE = '||h.accounting_entry_status_code||' , '||
                                                                 ' BALANCE_TYPE_CODE = '||h.balance_type_code);
      -- ====== FND LOG ======
      END LOOP;
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> XLA_AE_LINES_GT DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' -------------------- ');


       -- ====== FND LOG ======
      FOR x IN debug_xla_ae_lines_gt
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' EVENT_ID = '||x.event_id||' , '||
                                                                 ' AE_HEADER_ID = '||x.ae_header_id||' , '||
                                                                 ' AE_LINE_NUM = '||x.ae_line_num);
       -- ====== FND LOG ======
      END LOOP;

      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> XLA_VALIDATION_LINES_GT DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' ---------------------------- ');
       -- ====== FND LOG ======
      FOR y IN debug_xla_val_lines_gt
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' AE_HEADER_ID = '||y.ae_header_id||' , '||
                                                 ' AE_LINE_NUM = '||y.ae_line_num||' , '||
                                                 ' PERIOD_NAME = '||y.period_name||' , '||
                                                 ' ACCOUNTING_ENTRY_STATUS_CODE = '||y.accounting_entry_status_code||' , '||
                                                 ' BALANCING_LINE_TYPE = '||y.balancing_line_type);
       -- ====== FND LOG ======
      END LOOP;

      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> XLA_EVENTS_GT DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' ---------------------------- ');
       -- ====== FND LOG ======
      FOR z in debug_xla_events_gt
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' APPLICATION_ID = '||z.application_id||' , '||
                                                                 ' EVENT_ID = '||z.event_id||' , '||
                                                                 ' EVENT_DATE = '||z.event_date||' , '||
                                                                 ' EVENT_TYPE_CODE = '||z.event_type_code||' , '||
                                                                 ' REFERENCE_NUM_1 = '||z.reference_num_1);
      -- ====== FND LOG ======
      END LOOP;
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> XLA_PSA_BC_LINES_V DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path,' --------------------------------------- ');
       -- ====== FND LOG ======
      FOR v in debug_xla_psa_bc_v
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' EVENT_ID = '||v.event_id||' , '||
                                                                 ' AE_HEADER_ID = '||v.ae_header_id||' , '||
                                                                 ' AE_LINE_NUM = '||v.ae_line_num||' , '||
                                                                 ' ENTITY_ID = '||v.entity_id||' , '||
                                                                 ' PERIOD_NAME = '||v.period_name);
      -- ====== FND LOG ======
      END LOOP;

      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' BCTRL -> PSA_BC_ALLOC_GT DUMP');
         psa_utils.debug_other_string(g_error_level,l_full_path,' --------------------------------------- ');
       -- ====== FND LOG ======
      FOR p in debug_psa_bc_alloc_gt
      LOOP
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' HIERARCHY_ID = '||p.hierarchy_id||' , '||
                                                                 ' EVENT_ID = '||p.event_id||' , '||
                                                                 ' AE_HEADER_ID = '||p.ae_header_id||' , '||
                                                                 ' AE_LINE_NUM = '||p.ae_line_num||' , '||
                                                                 ' STATUS_CODE = '||p.status_code);
      -- ====== FND LOG ======
      END LOOP;


      select count(*) into l_var_1
      from xla_psa_bc_lines_v;
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_error_level,l_full_path, ' XLA_PSA_BC_LINES_V returns '||l_var_1||' rows. ');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' Error: Populated 0 rows in gl_bc_packets.');
         psa_utils.debug_other_string(g_error_level,l_full_path, ' RETURN -> FALSE');
       -- ====== FND LOG ======
   END IF;
   p_return_code := 'T';
   return FALSE;
    WHEN OTHERS THEN
     -- ====== FND LOG ======
        psa_utils.debug_other_string(g_excep_level, l_full_path, ' BCTRL -> Exception Raised: '||sqlerrm);
        psa_utils.debug_other_string(g_excep_level, l_full_path, ' BCTRL -> Return_code = T');
        psa_utils.debug_other_string(g_excep_level, l_full_path, ' BCTRL -> Return FALSE');
     -- ====== FND LOG ======
       p_return_code := 'T';
       return FALSE;

  END budgetary_control;

 /*===========================================================================================+
  | Procedure    : SYNC_XLA_ERRORS                                                            |
  | Description  : This API is invoked by SLA in package                                      |
  |                XLA_JE_VALIDATION_PKG.UNDO_FUNDS_RESERVE to synchronize budgetary control  |
  |                errors in secondary/reporting ledgers reported by SLA.                     |
  +===========================================================================================*/

  PROCEDURE sync_xla_errors (p_failed_ldgr_array IN num_rec,
                             p_failed_evnt_array IN num_rec)
  IS


    CURSOR c_success_evt_exists IS
    SELECT 'Successful event exists in the current packet'
    FROM gl_bc_packets
    WHERE event_id IN (SELECT event_id
                       FROM psa_bc_xla_events_gt
                      )
      AND application_id = PSA_BC_XLA_PVT.g_application_id
      AND status_code = 'A';

    dummy               VARCHAR2(100);
    l_success_evt_exist VARCHAR2(1);
    l_f81_cnt           NUMBER;
    l_f82_cnt           NUMBER;

    -- ========================= FND LOG ===========================
       l_full_path VARCHAR2(100);
    -- ========================= FND LOG ===========================

  BEGIN

    l_f81_cnt := 0;
    l_f82_cnt := 0;
    l_full_path := g_path || 'sync_xla_errors';

    -- ====== FND LOG ======
    psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> p_failed_ldgr_array.COUNT: '|| p_failed_ldgr_array.COUNT);
    psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> p_failed_evnt_array.COUNT: '|| p_failed_evnt_array.COUNT);
    -- ====== FND LOG ======

    FORALL i IN 1..p_failed_ldgr_array.COUNT
      UPDATE gl_bc_packets
      SET status_code = decode(PSA_BC_XLA_PVT.G_BC_MODE, 'C', 'F',
                                                         'M', 'F',
                                                         'R', 'R',
                                                         'P', 'R')
         ,result_code = 'F81'
      WHERE event_id = p_failed_evnt_array(i)
        AND application_id = PSA_BC_XLA_PVT.g_application_id
        AND ledger_id = p_failed_ldgr_array(i)
        AND status_code NOT IN ('F', 'R');

    l_f81_cnt := SQL%ROWCOUNT;

    -- ====== FND LOG ======
       psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated GL_BC_PACKETS '||l_f81_cnt||
                                    ' rows to F81 status.');
    -- ====== FND LOG ======


    FORALL j IN 1..p_failed_evnt_array.COUNT
      UPDATE gl_bc_packets
      SET status_code =  decode(PSA_BC_XLA_PVT.G_BC_MODE, 'C', 'F',
                                                          'M', 'F',
                                                          'R', 'R',
                                                          'P', 'R')
         ,result_code = 'F82'
      WHERE event_id = p_failed_evnt_array(j)
        AND application_id = PSA_BC_XLA_PVT.g_application_id
        AND status_code NOT IN ('F', 'R');

    l_f82_cnt := SQL%ROWCOUNT;

    -- ====== FND LOG ======
       psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated GL_BC_PACKETS '||l_f82_cnt||
                                    ' rows to F82 status.');
    -- ====== FND LOG ======

    -- This check is to ensure that if we have not updated any GL_BC_PACKETS
    -- row/s to failure then there was a genuine failure in GL_BC_PACKETS
    -- and we should not overwrite that failure with XLA_ERROR for the event.
    -- We need to retain the original failure status reported and inform the same
    -- back to the calling transaction.

    IF (l_f81_cnt <> 0 OR l_f82_cnt <> 0) THEN
       FORALL k IN 1..p_failed_evnt_array.COUNT
          UPDATE psa_bc_xla_events_gt
          SET result_code = 'XLA_ERROR'
          WHERE event_id = p_failed_evnt_array(k)
            AND result_code <> 'XLA_ERROR';

       -- ====== FND LOG ======
          psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated PSA_BC_XLA_EVENTS_GT '||sql%rowcount||
                                       ' rows to XLA_ERROR status.');
       -- ====== FND LOG ======

    END IF;

    OPEN c_success_evt_exists;
    FETCH c_success_evt_exists INTO dummy;
    IF (c_success_evt_exists%FOUND) THEN
      l_success_evt_exist := 'Y';
      CLOSE c_success_evt_exists;
    ELSE
      l_success_evt_exist := 'N';
      CLOSE c_success_evt_exists;
    END IF;

    IF (l_success_evt_exist = 'N') THEN

      UPDATE gl_bc_packet_arrival_order
      SET affect_funds_flag = 'N'
      WHERE affect_funds_flag = 'Y'
      AND packet_id IN ( SELECT packet_id
                         FROM gl_bc_packets bc
                         WHERE event_id IN ( SELECT event_id
                                          FROM psa_bc_xla_events_gt
                                        )
                           AND application_id = PSA_BC_XLA_PVT.g_application_id
                           AND result_code IN ('F81', 'F82')
                        ) ;

      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_state_level, l_full_path, ' BCTRL -> Updated GL_BC_PACKET_ARRIVAL_ORDER '||sql%rowcount||
                                      ' rows.');
      -- ====== FND LOG ======


    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      -- ====== FND LOG ======
         psa_utils.debug_other_string(g_excep_level, l_full_path, ' BCTRL -> Exception Raised: '||sqlerrm);
      -- ====== FND LOG ======
      IF (c_success_evt_exists%ISOPEN) THEN
         CLOSE c_success_evt_exists;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END sync_xla_errors;
BEGIN
  init;
END PSA_FUNDS_CHECKER_PKG;


/
