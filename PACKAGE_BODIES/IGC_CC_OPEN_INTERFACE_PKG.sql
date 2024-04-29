--------------------------------------------------------
--  DDL for Package Body IGC_CC_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_OPEN_INTERFACE_PKG" AS
/* $Header: IGCCOPIB.pls 120.15.12010000.3 2008/11/13 04:53:57 schakkin ship $ */

     --Bug 3199488 Start Block
    l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_state_level number:=FND_LOG.LEVEL_STATEMENT;
    l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
    l_event_level number:=FND_LOG.LEVEL_EVENT;
    l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
    l_error_level number:=FND_LOG.LEVEL_ERROR;
    l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;
    --Bug 3199488 End Block

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_OPEN_INTERFACE_PKG';

  -- The flag determines whether to print debug information or not.
    g_debug_flag VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
    g_high_date         DATE := Add_Months(Sysdate, 1200);

    g_process_phase  VARCHAR2(1);
    g_batch_id       NUMBER;

    g_cc_bc_enable_flag           VARCHAR2(1);
    g_sbc_enable_flag             VARCHAR2(1);
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--    g_cc_prov_encmbrnc_flag       VARCHAR2(1);
--    g_cc_conf_encmbrnc_flag       VARCHAR2(1);
    g_sb_prov_encmbrnc_flag       VARCHAR2(1);
    g_sb_conf_encmbrnc_flag       VARCHAR2(1);

    g_cc_state                    igc_cc_headers.cc_state%TYPE;
    g_cc_apprvl_status            igc_cc_headers.cc_apprvl_status%TYPE;


    -- Bug 2871052, created the following PLSQL tables for inserting into
    -- the pa_bc_packets table.
    -- We use PA PLSQL table definition PA_CC_ENC_IMPORT_FCK.FC_Rec_Table, which has
    -- the following structure :-
    -- TYPE fc_rec_table IS RECORD (
    --      packet_id                    pa_bc_packets.packet_id%type,
    --      bc_packet_id                 pa_bc_packets.bc_packet_id%type,
    --      parent_bc_packet_id          pa_bc_packets.parent_bc_packet_id%type,
    --      ext_budget_type              varchar2(100),
    --      bc_commitment_id             pa_bc_packets.bc_commitment_id%type,
    --      project_id                   pa_bc_packets.project_id%type,
    --      task_id                      pa_bc_packets.task_id%type,
    --      expenditure_type             pa_bc_packets.expenditure_type%type,
    --      expenditure_item_date        pa_bc_packets.expenditure_item_date%type,
    --      set_of_books_id              pa_bc_packets.set_of_books_id%type,
    --      je_category_name             pa_bc_packets.je_category_name%type,
    --      je_source_name               pa_bc_packets.je_source_name%type,
    --      status_code                  pa_bc_packets.status_code%type,
    --      document_type                pa_bc_packets.document_type%type,
    --      funds_process_mode           pa_bc_packets.funds_process_mode%type ,
    --      expenditure_organization_id  pa_bc_packets.expenditure_organization_id%type,
    --      document_header_id           pa_bc_packets.document_header_id%type,
    --      document_distribution_id     pa_bc_packets.document_distribution_id%type,
    --      budget_version_id            pa_bc_packets.budget_version_id%type,
    --      burden_cost_flag             pa_bc_packets.burden_cost_flag%type ,
    --      balance_posted_flag          pa_bc_packets.balance_posted_flag%type,
    --      actual_flag                  pa_bc_packets.actual_flag%type,
    --      gl_date                      pa_bc_packets.gl_date%type,
    --      period_name                  pa_bc_packets.period_name%type,
    --      period_year                  pa_bc_packets.period_year%type,
    --      period_num                   pa_bc_packets.period_num%type,
    --      encumbrance_type_id          pa_bc_packets.encumbrance_type_id%type,
    --      proj_encumbrance_type_id     pa_bc_packets.proj_encumbrance_type_id%type,
    --      top_task_id                  pa_bc_packets.top_task_id%type,
    --      parent_resource_id           pa_bc_packets.parent_resource_id%type,
    --      resource_list_member_id      pa_bc_packets.resource_list_member_id%type,
    --      entered_dr                   pa_bc_packets.entered_dr%type,
    --      entered_cr                   pa_bc_packets.entered_cr%type,
    --      accounted_dr                 pa_bc_packets.accounted_dr%type,
    --      accounted_cr                 pa_bc_packets.accounted_cr%type,
    --      result_code                  pa_bc_packets.result_code%type,
    --      old_budget_ccid              pa_bc_packets.old_budget_ccid%type,
    --      txn_ccid                     pa_bc_packets.txn_ccid%type,
    --      org_id                       pa_bc_packets.org_id%type,
    --      last_update_date             pa_bc_packets.last_update_date%type,
    --      last_updated_by              pa_bc_packets.last_updated_by%type,
    --      created_by                   pa_bc_packets.created_by%type,
    --      creation_date                pa_bc_packets.creation_date%type,
    --      last_update_login            pa_bc_packets.last_update_login%type );

    -- This is a table of records to check funds in the commitment budget.
    g_pa_fc_com_rec_tab                 PA_CC_ENC_IMPORT_FCK.FC_Rec_Table;

    -- This is a table of records to check funds in the payment budget.
    g_pa_fc_pay_rec_tab                 PA_CC_ENC_IMPORT_FCK.FC_Rec_Table;

    g_pa_fc_com_counter                  NUMBER := 0;
    g_pa_fc_pay_counter                  NUMBER := 0;
    g_bc_packet_id_com                   NUMBER;
    g_bc_packet_id_pay                   NUMBER;
    g_pa_cb_funds_check_required         BOOLEAN := FALSE;
    g_pa_sb_funds_check_required         BOOLEAN := FALSE;

/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--    g_prov_encumbrance_type_id           NUMBER;
--    g_conf_encumbrance_type_id           NUMBER;
--    g_req_encumbrance_type_id            NUMBER;
--    g_purch_encumbrance_type_id          NUMBER;
--    g_inv_encumbrance_type_id            NUMBER;
    -- Bug 2871052, End
--
--
-- Generic Procedure for putting out debug information
--
/* Commented out as per bug 3199488
PROCEDURE Output_Debug (
   p_debug_msg        IN VARCHAR2
);
*/
/***************************************************************************/
-- Get the value for Header_Id
/***************************************************************************/
  PROCEDURE HEADER_INTERFACE_DERIVE
     ( P_Header_Id OUT NOCOPY NUMBER)
     IS
     BEGIN
        SELECT igc_cc_headers_s.nextval
            INTO P_Header_Id FROM DUAL;
      END;

/***************************************************************************/
-- Get the value for Acct_Line_Id
/***************************************************************************/
  PROCEDURE ACCT_LINE_INTERFACE_DERIVE
     ( P_Acct_Line_Id OUT NOCOPY NUMBER)
    IS
    BEGIN
        SELECT igc_cc_acct_lines_s.nextval
            INTO P_Acct_Line_Id FROM DUAL;
    END;

/***************************************************************************/
-- Get the value for Det_Pf_Line_Id
/***************************************************************************/
  PROCEDURE DET_PF_INTERFACE_DERIVE
     ( P_Det_Pf_Line_Id OUT NOCOPY NUMBER)
    IS
    BEGIN
        SELECT igc_cc_det_pf_s.nextval
            INTO P_Det_Pf_Line_Id FROM DUAL;
    END;

/***************************************************************************/
-- Insert the errors into the error table
/***************************************************************************/
  PROCEDURE INTERFACE_HANDLE_ERRORS
     ( P_Interface_Header_Id 		IN NUMBER,
       P_Interface_Acct_Line_Id 	IN NUMBER,
       P_Interface_Det_Pf_Line_Id 	IN NUMBER,
       P_Org_Id 			IN NUMBER,
       P_Set_of_Books_Id 		IN NUMBER,
       P_Error_Message 			IN VARCHAR2,
       P_X_Error_Status 		IN OUT NOCOPY VARCHAR2)
     IS
     BEGIN
        IF P_X_Error_Status = 'N' THEN
           ROLLBACK;
           P_X_Error_Status := 'E';
        END IF;
        INSERT INTO IGC_CC_INTERFACE_ERRORS
                      ( batch_id,
                        interface_header_id,
                        interface_acct_line_id,
                        interface_det_pf_line_id,
                        org_id,
                        set_of_books_id,
                        error_message )
              VALUES  ( g_batch_id,
                        P_Interface_Header_Id,
                        P_Interface_Acct_Line_Id,
                        P_Interface_Det_Pf_Line_Id,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        P_Error_Message);
      END;

/***************************************************************************/
-- Insert the Acct Line and Det Pf records into igc_cc_interface_errors
-- for which the header or acct line record does not exists in the batch.
/***************************************************************************/
  PROCEDURE INSERT_ORPHAN_RECORDS
      ( P_X_Error_Status IN OUT NOCOPY VARCHAR2 )
      IS
        l_interface_header_id   NUMBER;
        l_interface_acct_line_id    NUMBER;
        l_interface_det_pf_id   NUMBER;
	l_error_message		igc_cc_interface_errors.error_message%TYPE;

        CURSOR c_interface_orphan_acct_lines IS
            SELECT ICALI.interface_header_id,
                   ICALI.interface_acct_line_id
              FROM igc_cc_acct_lines_interface ICALI
             WHERE ICALI.batch_id = g_batch_Id
               AND NOT EXISTS (SELECT ICALI1.interface_header_id
                                 FROM igc_cc_headers_interface ICALI1
                                WHERE ICALI1.batch_id           = g_batch_id
                                  AND ICALI.interface_header_id = ICALI1.interface_header_id);

        CURSOR c_interface_orphan_det_pf IS
            SELECT ICDPI.interface_acct_line_id,
                   ICDPI.interface_det_pf_line_id
              FROM igc_cc_det_pf_interface ICDPI
             WHERE ICDPI.batch_id = g_batch_id
               AND NOT EXISTS (SELECT ICALI.interface_acct_line_id
                                 FROM igc_cc_headers_interface    ICHI,
                                      igc_cc_acct_lines_interface ICALI
                                WHERE ICHI.batch_id                = g_batch_id
                                  AND ICHI.batch_id                = ICALI.batch_id
                                  AND ICHI.interface_header_id     = ICALI.interface_header_id
                                  AND ICDPI.interface_acct_line_id = ICALI.interface_acct_line_id);

      BEGIN
        OPEN c_interface_orphan_acct_lines;
        LOOP
          FETCH c_interface_orphan_acct_lines INTO l_interface_header_id, l_interface_acct_line_id;
          EXIT WHEN c_interface_orphan_acct_lines%NOTFOUND;

          IF P_X_Error_Status = 'N' THEN
            ROLLBACK;
            P_X_Error_Status := 'E';
          END IF;

	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_HDR_REC_NOT_FOUND');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
              ( l_interface_header_id,
                l_interface_acct_line_id,
                NULL,
                NULL,
                NULL,
		l_error_message,
                P_X_Error_Status);
        END LOOP;
        CLOSE c_interface_orphan_acct_lines;

        OPEN c_interface_orphan_det_pf;
        LOOP
          FETCH c_interface_orphan_det_pf INTO l_interface_acct_line_id, l_interface_det_pf_id;
          EXIT WHEN c_interface_orphan_det_pf%NOTFOUND;

          IF P_X_Error_Status = 'N' THEN
            ROLLBACK;
            P_X_Error_Status := 'E';
          END IF;

	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_HDR_NOT_FOUND');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
              ( NULL,
                l_interface_acct_line_id,
                l_interface_det_pf_id,
                NULL,
                NULL,
		l_error_message,
                P_X_Error_Status);
        END LOOP;
        CLOSE c_interface_orphan_det_pf;
      END;

/***************************************************************************/
-- Get the Parent Ids
/***************************************************************************/
  PROCEDURE GET_PARENT_ID
      ( P_Interface_Parent_Header_Id 		IN NUMBER,
        P_Interface_Parent_AcctLine_Id 		IN NUMBER,
        P_Interface_Parent_Det_Pf_Id 		IN NUMBER,
        P_Parent_Header_Id 		        IN OUT NOCOPY NUMBER,
        P_Parent_Acct_Line_Id 		        IN OUT NOCOPY NUMBER,
        P_Parent_Det_Pf_Id                      OUT NOCOPY NUMBER)
      IS

      BEGIN
        IF P_Interface_Parent_Header_Id IS NOT NULL AND P_Parent_Header_Id IS NULL THEN
            BEGIN
                SELECT cch.cc_header_id INTO P_Parent_Header_Id
                FROM igc_cc_headers cch, igc_cc_headers_interface cchi
                WHERE cchi.interface_header_id = P_Interface_Parent_Header_Id
                AND cchi.cc_num = cch.cc_num
                AND cchi.org_id = cch.org_id;
            EXCEPTION WHEN OTHERS THEN RAISE;
            END;
         END IF;
        IF P_Interface_Parent_AcctLine_Id IS NOT NULL AND P_Parent_Acct_Line_Id IS NULL THEN
            BEGIN
                SELECT cca.cc_acct_line_id INTO P_Parent_Acct_Line_Id
                FROM igc_cc_acct_lines cca, igc_cc_acct_lines_interface ccai
                WHERE ccai.interface_acct_line_id = P_Interface_Parent_AcctLine_Id
                AND cca.cc_header_id = P_Parent_Header_Id
                AND ccai.cc_acct_line_num = cca.cc_acct_line_num;
            EXCEPTION WHEN OTHERS THEN RAISE;
            END;
         END IF;
        IF P_Interface_Parent_Det_Pf_Id IS NOT NULL AND P_Parent_Det_Pf_Id IS NULL THEN
            BEGIN
                SELECT ccd.cc_det_pf_line_id INTO P_Parent_Det_Pf_Id
                FROM igc_cc_det_pf ccd, igc_cc_det_pf_interface ccdi
                WHERE ccdi.interface_det_pf_line_id = P_Interface_Parent_Det_Pf_Id
                AND ccd.cc_acct_line_id = P_Parent_Acct_Line_Id
                AND ccdi.cc_det_pf_line_num = ccd.cc_det_pf_line_num;
            EXCEPTION WHEN OTHERS THEN RAISE;
            END;
         END IF;
      END;

    -- 1833267, Additional Date Validations changes
    -- Bidisha S , 23 Aug 2001 - Start

    -- This procedure gets the setup flags
    -- Added the 5 encumbrance_type_ids for bug 2871052
     PROCEDURE get_setup_flags (p_set_of_books_id             IN NUMBER,
                               p_org_id                      IN NUMBER,
                               p_cc_bc_enable_flag           IN OUT NOCOPY VARCHAR2,
                               p_sbc_enable_flag             IN OUT NOCOPY VARCHAR2,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                            p_cc_prov_encmbrnc_flag       IN OUT NOCOPY VARCHAR2,
--                            p_cc_conf_encmbrnc_flag       IN OUT NOCOPY VARCHAR2,
                               p_sb_prov_encmbrnc_flag       IN OUT NOCOPY VARCHAR2,
                               p_sb_conf_encmbrnc_flag       IN OUT NOCOPY VARCHAR2
--			       ,
--                            p_prov_encumbrance_type_id    IN OUT NOCOPY NUMBER,
--                            p_conf_encumbrance_type_id    IN OUT NOCOPY NUMBER,
--                            p_req_encumbrance_type_id     IN OUT NOCOPY NUMBER,
--                            p_purch_encumbrance_type_id   IN OUT NOCOPY NUMBER,
--                            p_inv_encumbrance_type_id     IN OUT NOCOPY NUMBER
				)
    IS

    l_ap_req_encmbrnc_type_id           NUMBER;
    l_ap_purch_encmbrnc_type_id           NUMBER;

    BEGIN

        BEGIN
            SELECT  Nvl(cc_bc_enable_flag,'N')
            INTO    p_cc_bc_enable_flag
            FROM    igc_cc_bc_enable
            WHERE   set_of_books_id = p_set_of_books_id;

        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_cc_bc_enable_flag := 'N';
        END ;

        BEGIN
             SELECT  NVL(enable_budgetary_control_flag,'N')
             INTO    p_sbc_enable_flag
             FROM    gl_sets_of_books
             WHERE   set_of_books_id = p_set_of_books_id;

        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_sbc_enable_flag := 'N';
        END;

        p_sb_prov_encmbrnc_flag  := 'N';
        p_sb_conf_encmbrnc_flag  := 'N';

        IF (NVL(p_sbc_enable_flag,'N') = 'Y')
        THEN
            BEGIN
/* Bug No : 6341012. SLA uptake. Encumbrance_flag can be directly retrieved from the table and Encumbrance_type_ids are not required*/
		 SELECT
--		          req_encumbrance_type_id,
--                       purch_encumbrance_type_id,
--                       inv_encumbrance_type_id,
			  req_encumbrance_flag,
			  purch_encumbrance_flag
                 INTO
--		          l_ap_req_encmbrnc_type_id,
--                       l_ap_purch_encmbrnc_type_id,
--                       p_inv_encumbrance_type_id,
			  p_sb_prov_encmbrnc_flag,
			  p_sb_conf_encmbrnc_flag
                 FROM     financials_system_parameters;

/*                 IF l_ap_req_encmbrnc_type_id IS NOT NULL
                 THEN
                     p_req_encumbrance_type_id  := l_ap_req_encmbrnc_type_id;
                 END IF;

                 IF l_ap_purch_encmbrnc_type_id IS NOT NULL
                 THEN
                     p_purch_encumbrance_type_id   := l_ap_purch_encmbrnc_type_id;
                 END IF;
*/

            EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                 p_sb_prov_encmbrnc_flag  := 'N';
                 p_sb_conf_encmbrnc_flag  := 'N';
            END;

        END IF;
    END get_setup_flags;

    -- This function validates that the date is within an Open or Future Entry
    FUNCTION date_in_valid_period (p_date            IN DATE,
                                   p_org_id          IN NUMBER,
                                   p_set_of_books_id IN NUMBER)
             RETURN BOOLEAN
    IS

    l_count              NUMBER;

    BEGIN
        -- Validate that the date is within an Open or Future Entry
        -- GL / CC Period
        -- Performance Tuning, replaced gl_period_statuses_v
        --      gl_period_statuses_v gl,
        SELECT  count(*)
        INTO    l_COUNT
        FROM    fnd_application      app,
                gl_sets_of_books     sob,
                gl_period_statuses gl,
                igc_cc_periods       cp
        WHERE   sob.set_of_books_id        = p_set_of_books_id
        AND     gl.set_of_books_id         = sob.set_of_books_id
        AND     gl.application_id          = app.application_id
        AND     app.application_short_name = 'SQLGL'
        AND     cp.org_id                  = p_org_id
        AND     cp.period_set_name         = sob.period_set_name
        AND     cp.period_name             = gl.period_name
        AND     cp.cc_period_status        IN ('O', 'F')
        AND     gl.closing_status          IN ('O', 'F')
        AND     gl.adjustment_period_flag  = 'N'
        AND     (p_date BETWEEN gl.start_date AND gl.end_date);

        IF l_count = 0
        THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
    END  date_in_valid_period;

    -- This procedure Validates Start Date
    PROCEDURE validate_start_date (p_interface_header_id    IN NUMBER,
/* Bug No : 6341012. p_interface_parent_header_id, p_cc_encmbrnc_status,p_sbc_enable_flag,p_cbc_enable_flag, are not used in this procedure*/
--				   p_interface_parent_header_id    IN NUMBER,
                                   p_org_id                 IN NUMBER,
                                   p_set_of_books_id        IN NUMBER,
                                   p_cc_type                IN igc_cc_headers.cc_type%TYPE,
--                                p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                                p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                                p_cc_conf_encmbrnc_flag  IN VARCHAR2,
--				   p_sbc_enable_flag        IN VARCHAR2,
--                                p_cbc_enable_flag        IN VARCHAR2,
                                   p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                   p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                   p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;
    l_min_rel_start_date         DATE;

    BEGIN

        -- Start Date cannot be null
        IF p_cc_start_date IS NULL
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_START_DATE_REQD');
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        NULL,
                        NULL,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);

        END IF; -- start date cannot be null

        -- Start Date must be lesser than End Date
        IF  p_cc_end_date IS NOT NULL
        AND p_cc_start_date > p_cc_end_date
        AND l_valid
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_START_DT_GREATER_END_DT');
            FND_MESSAGE.SET_TOKEN('START_DT', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
            FND_MESSAGE.SET_TOKEN('END_DT', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
        END IF;  -- Start Date must be lesser than End Date

        -- Start Date must be within open/ future entry CC / GL Period
        IF NOT date_in_valid_period (p_cc_start_date,
                                     p_org_id,
                                     p_set_of_books_id)
        AND p_cc_type <> 'R'
        AND l_valid
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_START_DATE_OF');
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);

        END IF; -- date not in valid period


        -- For Cover CC's
        -- Start >= Start Date of related CC's
        IF  p_cc_type = 'C'
        AND l_valid
        THEN
            SELECT MIN(cc_start_date)
            INTO   l_min_rel_start_date
            FROM   igc_cc_headers_interface
            WHERE  interface_parent_header_id = p_interface_header_id;

            -- Check Start date of cover < earliest release start date
            IF NVL(l_min_rel_start_date, p_cc_start_date) < p_cc_start_date
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_SD_COV_GT_SD_REL');
                FND_MESSAGE.SET_TOKEN('START_DATE_REL',
                                      TO_CHAR(l_min_rel_start_date, 'DD-MON-YYYY'), TRUE);
                FND_MESSAGE.SET_TOKEN('START_DATE_COV',
                                      TO_CHAR(p_cc_start_date, 'DD-MON-YYYY'), TRUE);
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;
        END IF; -- Start date for Cover CC

        -- For Release CC's
        -- Start >= Start Date of Cover CC's
        -- This is done in the header_interface_validate procedure

    END validate_start_date;


    -- This procedure Validates End Date
    PROCEDURE validate_end_date (p_interface_header_id    IN NUMBER,
/* Bug No : 6341012. p_interface_parent_header_id, p_cc_encmbrnc_status,p_sbc_enable_flag,
p_cbc_enable_flag,p_cbc_start_date are not used in this procedure*/
--                              p_interface_parent_header_id    IN NUMBER,
                                 p_org_id                 IN NUMBER,
                                 p_set_of_books_id        IN NUMBER,
                                 p_cc_type                IN igc_cc_headers.cc_type%TYPE,
--                              p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                              p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                              p_cc_conf_encmbrnc_flag  IN VARCHAR2,
--                              p_sbc_enable_flag        IN VARCHAR2,
--                              p_cbc_enable_flag        IN VARCHAR2,
--                              p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                 p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;
    l_max_rel_end_date           DATE;

    BEGIN

        -- For release commitments,
        -- end date >= date of related cover commitment
        -- Done in main procedure

        -- For cover commitments,
        -- end date >= date of related release commitment
        IF p_cc_type = 'C'
        THEN
            SELECT MAX(cc_end_date)
            INTO   l_max_rel_end_date
            FROM   igc_cc_headers_interface
            WHERE  interface_parent_header_id = p_interface_header_id;

            -- Check End date of cover > latest release end date
            IF NVL(l_max_rel_end_date, p_cc_end_date) > p_cc_end_date
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ED_COV_LESS_ED_REL');
                FND_MESSAGE.SET_TOKEN('END_DATE_REL',
                                      TO_CHAR(l_max_rel_end_date, 'DD-MON-YYYY'), TRUE);
                FND_MESSAGE.SET_TOKEN('END_DATE_COV',
                                      TO_CHAR(p_cc_end_date, 'DD-MON-YYYY'), TRUE);
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF; -- End Date Check
        END IF; -- CC Type

    END validate_end_date;


    -- This procedure Validates Accountant Date
    PROCEDURE validate_acct_date(p_interface_header_id    IN NUMBER,
                                 p_interface_parent_header_id    IN NUMBER,
                                 p_interface_acct_line_id IN NUMBER,
                                 p_org_id                 IN NUMBER,
                                 p_set_of_books_id        IN NUMBER,
                                 p_cc_type                IN igc_cc_headers.cc_type%TYPE,
                                 p_cc_state               IN igc_cc_headers.cc_state%TYPE,
                                 p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
                                 p_cc_apprvl_status       IN igc_cc_headers.cc_apprvl_status%TYPE,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                              p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                              p_cc_conf_encmbrnc_flag  IN VARCHAR2,
                                 p_sbc_enable_flag        IN VARCHAR2,
                                 p_cbc_enable_flag        IN VARCHAR2,
                                 p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_acct_date           IN DATE,
                                 p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;
    BEGIN

        IF  p_cc_apprvl_status = 'AP'
        AND p_sbc_enable_flag = 'Y'    AND p_cbc_enable_flag = 'Y'
        AND ((
	--    p_cc_conf_encmbrnc_flag  = 'Y'   Bug No : 6341012. SLA uptake. CC_CONF_ENCUMBRANCE_FLAG no more exists
                        p_cc_state           = 'CM'
              AND p_cc_encmbrnc_status = 'C')
        OR  (
	--    p_cc_prov_encmbrnc_flag = 'Y'   Bug No : 6341012. SLA uptake. CC_PROV_ENCUMBRANCE_FLAG no more exists
                       p_cc_state = 'PR'
              AND p_cc_encmbrnc_status = 'P'))
        AND p_cc_type <> 'R'
        THEN
            -- Account date must not be null if Approved and encumbered
            IF p_cc_acct_date IS NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCT_DATE_NULL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;
        END IF; -- Account Date must not be null

        -- For others
        -- Accounting Date should be null

        IF Nvl(p_cbc_enable_flag,'N') = 'N'
        OR p_cc_type = 'R'
/*  Bug No : 6341012. SLA uptake. CC_PROV_ENCUMBRANCE_FLAG,CC_PROV_ENCUMBRANCE_FLAG no more exists
        OR (p_cc_state = 'CM' AND Nvl(p_cc_conf_encmbrnc_flag,'N') = 'N')
        OR (p_cc_state = 'PR' AND Nvl(p_cc_prov_encmbrnc_flag,'N') = 'N')  */
        THEN
            -- Accounting Date must be null
            IF p_cc_acct_date IS NOT NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCT_DATE_NOT_NULL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;
        END IF ; -- Accounting Date Must be null


        IF p_cc_acct_date IS NOT NULL
        AND l_valid
        THEN
            -- Acct Date should be between Start Date and End Date
            IF p_cc_acct_date NOT BETWEEN p_cc_start_date
               AND Nvl(p_cc_end_date, g_high_date)
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCOUNT_DT_OUT_OF_RANGE');
                FND_MESSAGE.SET_TOKEN('ACCT_DT',
                                      TO_CHAR(p_cc_acct_date, 'DD-MON-YYYY'), TRUE);
                FND_MESSAGE.SET_TOKEN('START_DATE',
                                      TO_CHAR(p_cc_start_date, 'DD-MON-YYYY'), TRUE);
                FND_MESSAGE.SET_TOKEN('END_DATE',
                                      TO_CHAR(p_cc_end_date, 'DD-MON-YYYY'), TRUE);
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END IF; -- acct date within start and end dates


            -- Acct Date should be within Open / Future Entry CC / GL Period
            IF NOT date_in_valid_period (p_cc_acct_date,
                                         p_org_id,
                                         p_set_of_books_id)
            AND l_valid
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCT_DATE_OF');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF; -- date not in valid period

         End IF ; -- Acct Date not null


    END validate_acct_date;


    PROCEDURE validate_enc_acct_date (
                                 p_interface_header_id    IN NUMBER,
                                 p_interface_acct_Line_Id IN NUMBER,
                                 p_org_id                 IN NUMBER,
                                 p_set_of_books_id        IN NUMBER,
                                 p_cc_type                IN igc_cc_headers.cc_type%TYPE,
                                 p_cc_state               IN igc_cc_headers.cc_state%TYPE,
                                 p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
                                 p_cc_apprvl_status       IN igc_cc_headers.cc_apprvl_status%TYPE,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                              p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                              p_cc_conf_encmbrnc_flag  IN VARCHAR2,
                                 p_sbc_enable_flag        IN VARCHAR2,
                                 p_cbc_enable_flag        IN VARCHAR2,
                                 p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_acct_date           IN DATE,
                                 p_cc_encmbrnc_acct_date  IN DATE,
                                 p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;
    BEGIN

        IF  p_cc_apprvl_status = 'AP'
        AND p_sbc_enable_flag = 'Y'    AND p_cbc_enable_flag = 'Y'
        AND ((
	--    p_cc_conf_encmbrnc_flag  = 'Y'   Bug No : 6341012. SLA uptake. CC_CONF_ENCUMBRANCE_FLAG no more exists
                        p_cc_state           = 'CM'
              AND p_cc_encmbrnc_status = 'C')
        OR  (
	--    p_cc_prov_encmbrnc_flag = 'Y'   Bug No : 6341012. SLA uptake. CC_PROV_ENCUMBRANCE_FLAG no more exists
                        p_cc_state = 'PR'
              AND p_cc_encmbrnc_status = 'P'))
        AND p_cc_type <> 'R'
        THEN
            -- Encumbrance Account date must not be null
            IF p_cc_encmbrnc_acct_date IS NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACNT_ENCUM_DT_IS_NULL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;
        END IF; -- Enc Account Date must not be null

        -- For others
        -- Encumbrance Accounting Date should be null
        IF Nvl(p_cbc_enable_flag,'N') = 'N'
        OR p_cc_type = 'R'
/*  Bug No : 6341012. SLA uptake. CC_PROV_ENCUMBRANCE_FLAG,CC_PROV_ENCUMBRANCE_FLAG no more exists
        OR (p_cc_state = 'CM' AND Nvl(p_cc_conf_encmbrnc_flag,'N') = 'N')
        OR (p_cc_state = 'PR' AND Nvl(p_cc_prov_encmbrnc_flag,'N') = 'N')    */
        THEN
            -- Accounting Date must be null
            IF p_cc_encmbrnc_acct_date IS NOT NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENC_ACCT_DATE_NOT_NULL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;
        END IF ; -- Enc Accounting Date Must be null


        IF p_cc_encmbrnc_acct_date IS NOT NULL
        AND l_valid
        THEN
            -- Enc Acct Date must be <= Acct Date
            IF p_cc_encmbrnc_acct_date > p_cc_acct_date
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENC_DT_GT_ACCT_DT');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END IF; -- acct date > Enc acct date

         End IF ; -- Acct Date not null

    END validate_enc_acct_date;


    -- This procedure validates the Payment Forecast Date
     PROCEDURE validate_pf_date(
                                 p_interface_header_id    IN NUMBER,
                                 p_org_id                 IN NUMBER,
                                 p_set_of_books_id        IN NUMBER,
                                 p_cc_type                IN igc_cc_headers.cc_type%TYPE,
                                 p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
 /* Bug No : 6341012. SLA uptake. cc_flags no more exists  */
--                              p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                              p_cc_conf_encmbrnc_flag  IN VARCHAR2,
                                 p_sbc_enable_flag        IN VARCHAR2,
                                 p_cbc_enable_flag        IN VARCHAR2,
                                 p_interface_acct_line_id IN VARCHAR2,
                                 p_interface_det_pf_id    IN VARCHAR2,
                                 p_interface_parent_det_pf_id IN NUMBER,
                                 p_cc_det_pf_date         IN DATE,
                                 p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                 p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_cover_cc_det_pf_date       DATE;
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;
    BEGIN

        -- Pf Date cannot be null
        IF p_cc_det_pf_date IS NULL
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PF_DATE_NULL');
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                P_Interface_Acct_Line_Id,
                P_Interface_Det_Pf_Id,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
        END IF; -- PF Date cannot be null

        -- PF Date should be between Start Date and End Date
        IF p_cc_det_pf_date NOT BETWEEN p_cc_start_date
           AND Nvl(p_cc_end_date, g_high_date)
        AND l_valid
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_FRCT_DT_NOT_IN_START_DT');
            FND_MESSAGE.SET_TOKEN('PF_DATE',
                                  TO_CHAR(p_cc_det_pf_date, 'DD-MON-YYYY'), TRUE);
            FND_MESSAGE.SET_TOKEN('START_DT',
                                  TO_CHAR(p_cc_start_date, 'DD-MON-YYYY'), TRUE);
            FND_MESSAGE.SET_TOKEN('END_DT',
                                  TO_CHAR(p_cc_end_date, 'DD-MON-YYYY'), TRUE);
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                P_Interface_Acct_Line_Id,
                P_Interface_Det_Pf_Id,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
        END IF; -- acct date within start and end dates


        -- PF Date should be within Open / Future Entry CC / GL Period
        IF  p_cc_type <> 'R'
        AND l_valid
        AND NOT date_in_valid_period (p_cc_det_pf_date,
                                     p_org_id,
                                     p_set_of_books_id)
        THEN
            l_valid := FALSE;
            l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PAY_FRCT_DT_NOT_IN_LMT');
	    FND_MESSAGE.SET_TOKEN('DET_PF_DATE',
                                  TO_CHAR(p_cc_det_pf_date, 'DD-MON-YYYY'), TRUE);
            l_error_message := FND_MESSAGE.GET;

            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                P_Interface_Acct_Line_Id,
                P_Interface_Det_Pf_Id,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);

        END IF; -- date not in valid period

        IF p_cc_type = 'R'
        AND l_valid
        THEN
            -- Get the PF date of the Cover CC
            BEGIN
                SELECT cc_det_pf_date
                INTO   l_cover_cc_det_pf_date
                FROM   igc_cc_det_pf_interface
                WHERE  interface_det_pf_line_id = p_interface_parent_det_pf_id;

            EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_cover_cc_det_pf_date := NULL;
            END;

            IF l_cover_cc_det_pf_date <> p_cc_det_pf_date
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PAY_FCT_REL_DIFFERS_COV');
	        FND_MESSAGE.SET_TOKEN('REL_PF_DATE',
                                     TO_CHAR(P_Cc_Det_Pf_Date, 'DD-MON-YYYY'), TRUE);
	        FND_MESSAGE.SET_TOKEN('COV_PF_DATE',
                                      TO_CHAR(l_cover_cc_det_pf_date, 'DD-MON-YYYY'), TRUE);
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;

        END IF;

    END validate_pf_date;


    -- This procedure validates the encumbrance payment forecast date.
     PROCEDURE validate_enc_pf_date (
                                 p_interface_header_id    IN NUMBER,
                                 p_org_id                 IN NUMBER,
                                 p_set_of_books_id        IN NUMBER,
                                 p_cc_type                IN igc_cc_headers.cc_type%TYPE,
                                 p_cc_state               IN igc_cc_headers.cc_state%TYPE,
                                 p_cc_encmbrnc_status     IN igc_cc_headers.cc_encmbrnc_status%TYPE,
                                 p_cc_apprvl_status       IN igc_cc_headers.cc_apprvl_status%TYPE,
/* Bug No : 6341012. SLA uptake. cc_flags no more exists */
--                              p_cc_prov_encmbrnc_flag  IN VARCHAR2,
--                              p_cc_conf_encmbrnc_flag  IN VARCHAR2,
                                 p_sb_prov_encmbrnc_flag  IN VARCHAR2,
                                 p_sb_conf_encmbrnc_flag  IN VARCHAR2,
                                 p_sbc_enable_flag        IN VARCHAR2,
                                 p_cbc_enable_flag        IN VARCHAR2,
                                 p_interface_acct_line_id IN VARCHAR2,
                                 p_interface_det_pf_id    IN VARCHAR2,
                                 p_interface_parent_det_pf_id IN NUMBER,
                                 p_cc_det_pf_date         IN DATE,
                                 p_cc_det_pf_encmbrnc_date   IN DATE,
                                 p_cc_start_date          IN igc_cc_headers.cc_start_date%TYPE,
                                 p_cc_end_date            IN igc_cc_headers.cc_start_date%TYPE,
                                 p_x_error_status         IN OUT NOCOPY VARCHAR2)
    IS
    l_error_message              VARCHAR2(2000);
    l_valid                      BOOLEAN := TRUE;

    BEGIN

        IF  p_cc_apprvl_status = 'AP'
        AND ((p_sbc_enable_flag = 'Y'    AND p_cbc_enable_flag = 'Y' -- Dual Bdgt Control
        AND ((
	--    p_cc_conf_encmbrnc_flag  = 'Y'   Bug No : 6341012. SLA uptake. CC_CONF_ENCUMBRANCE_FLAG no more exists
                        p_cc_state           = 'CM'
              AND p_cc_encmbrnc_status = 'C')
        OR  (
	--    p_cc_prov_encmbrnc_flag = 'Y'   Bug No : 6341012. SLA uptake. CC_PROV_ENCUMBRANCE_FLAG no more exists
                        p_cc_state = 'PR'
              AND p_cc_encmbrnc_status = 'P')))
        OR
        (p_sbc_enable_flag = 'Y'    AND p_cbc_enable_flag = 'N' -- Single Bdgt Control
        AND ((p_sb_conf_encmbrnc_flag  = 'Y'  AND p_cc_state           = 'CM' )
        OR  ( p_sb_prov_encmbrnc_flag = 'Y'   AND p_cc_state = 'PR' ))))

        THEN

            -- CC Det Pf Enc date cannot be null
            IF p_cc_det_pf_encmbrnc_date IS NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DTL_PAY_FRCT_ENC_DT_NUL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;


            IF p_cc_det_pf_encmbrnc_date IS NOT NULL
            AND p_cc_det_pf_encmbrnc_date <> p_cc_det_pf_date
            AND l_valid
            THEN

                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DT_PF_ENC_DT_DIFF_PFDT');
	        FND_MESSAGE.SET_TOKEN('PF_ENCUM_DT', p_cc_det_pf_encmbrnc_date, TRUE);
	        FND_MESSAGE.SET_TOKEN('PF_DATE', p_cc_det_pf_date, TRUE);
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END IF; -- PF date <> PF Enc Date

        ELSE
            -- Enc Pf Date must be null
            IF p_cc_det_pf_encmbrnc_date IS NOT NULL
            THEN
                l_valid := FALSE;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DTL_PF_ENC_DT_NOT_NUL');
                l_error_message := FND_MESSAGE.GET;

                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);

            END IF;

        END IF; -- Check for state of CC

    END validate_enc_pf_date;


  -- 1833267, Additional Date Validations changes
  -- Bidisha S , 23 Aug 2001 - End


    -- Bug 2871052, Bidisha S Start
    -- Populate the PA plsql tables for Commitment bduget
    PROCEDURE populate_pa_table
      (p_budget_type            IN VARCHAR2,
       p_cc_header_id           IN igc_cc_headers.cc_header_id%TYPE,
       p_cc_acct_line_id        IN igc_cc_acct_lines.cc_acct_line_id%TYPE,
       p_cc_det_pf_line_id      IN igc_cc_det_pf.cc_det_pf_line_id%TYPE,
       p_cc_state               IN igc_cc_headers.cc_state%TYPE,
       p_project_id             IN igc_cc_acct_lines.project_id%TYPE,
       p_task_id                IN igc_cc_acct_lines.task_id%TYPE,
       p_expenditure_type       IN igc_cc_acct_lines.expenditure_type%TYPE,
       p_expenditure_item_date  IN igc_cc_acct_lines.expenditure_item_date%TYPE,
       p_expenditure_org_id     IN igc_cc_acct_lines.expenditure_org_id%TYPE,
       p_transaction_date       IN DATE,
       p_encumbered_amt         IN NUMBER,
       p_billed_amt             IN NUMBER,
       p_txn_ccid               IN NUMBER,
       p_sob_id                 IN NUMBER,
       p_org_id                 IN NUMBER)
    IS

    CURSOR c_period_details (p_date    DATE,
                             p_sob_id  NUMBER)
    IS
    SELECT gp.period_name,
           gp.period_num,
           gp.period_year
    FROM   gl_periods gp,
           gl_sets_of_books sob
    WHERE  gp.period_set_name       = sob.period_set_name
    AND    gp.period_type           = sob.accounted_period_type
    AND    sob.set_of_books_id     = p_sob_id
    AND    p_date BETWEEN gp.start_date AND gp.end_date
    AND    gp.adjustment_period_flag = 'N';

    l_index      NUMBER;

    BEGIN
       IF p_budget_type = 'CBC'
       THEN
           g_pa_fc_com_counter := g_pa_fc_com_counter + 1;
           l_index :=  g_pa_fc_com_counter;
       ELSE -- p_budget_type = 'GL'
           g_pa_fc_pay_counter := g_pa_fc_pay_counter + 1;
           l_index :=  g_pa_fc_pay_counter;
       END IF;

       -- Set variables for Commitment Budget.
       IF p_budget_type = 'CBC'
       THEN
           g_pa_fc_com_rec_tab( l_index ).packet_id := g_bc_packet_id_com;
           g_pa_fc_com_rec_tab( l_index ).ext_budget_type := 'CC';

           IF p_cc_state = 'PR' -- Provisional
           THEN
               g_pa_fc_com_rec_tab( l_index ).document_type := 'CC_P_CO';
               g_pa_fc_com_rec_tab( l_index ).je_category_name := 'Provisional';
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs not required*/
               g_pa_fc_com_rec_tab( l_index ).encumbrance_type_id := null; --g_prov_encumbrance_type_id;
               g_pa_fc_com_rec_tab( l_index ).entered_dr := p_encumbered_amt;
               g_pa_fc_com_rec_tab( l_index ).accounted_dr := p_encumbered_amt;
           ELSIF p_cc_state = 'CM' -- Confirmed
           THEN
               g_pa_fc_com_rec_tab( l_index ).document_type := 'CC_C_CO';
               g_pa_fc_com_rec_tab( l_index ).je_category_name := 'Confirmed';
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs not required*/
               g_pa_fc_com_rec_tab( l_index ).encumbrance_type_id := null; --g_conf_encumbrance_type_id;
               g_pa_fc_com_rec_tab( l_index ).entered_dr := p_encumbered_amt;
               g_pa_fc_com_rec_tab( l_index ).accounted_dr := p_encumbered_amt;
           END IF;

           g_pa_fc_com_rec_tab( l_index ).document_distribution_id := p_cc_acct_line_id;
           OPEN c_period_details (p_transaction_date,
                                  p_sob_id);
           FETCH c_period_details INTO
                     g_pa_fc_com_rec_tab( l_index ).period_name,
                     g_pa_fc_com_rec_tab( l_index ).period_num,
                     g_pa_fc_com_rec_tab( l_index ).period_year;
           CLOSE c_period_details;

           g_pa_fc_com_rec_tab( l_index ).project_id                  := p_project_id;
           g_pa_fc_com_rec_tab( l_index ).task_id                     := p_task_id;
           g_pa_fc_com_rec_tab( l_index ).expenditure_type            := p_expenditure_type;
           g_pa_fc_com_rec_tab( l_index ).expenditure_item_date       := p_expenditure_item_date;
           g_pa_fc_com_rec_tab( l_index ).expenditure_organization_id := p_expenditure_org_id;
           g_pa_fc_com_rec_tab( l_index ).set_of_books_id             := p_sob_id;
           g_pa_fc_com_rec_tab( l_index ).je_source_name              := 'Contract Commitment';
           g_pa_fc_com_rec_tab( l_index ).status_code                 := 'P';
           g_pa_fc_com_rec_tab( l_index ).funds_process_mode          := 'T';
           g_pa_fc_com_rec_tab( l_index ).document_header_id          := p_cc_header_id;
           g_pa_fc_com_rec_tab( l_index ).burden_cost_flag            := 'N';
           g_pa_fc_com_rec_tab( l_index ).balance_posted_flag         := 'N';
           g_pa_fc_com_rec_tab( l_index ).actual_flag                 := 'E';
           g_pa_fc_com_rec_tab( l_index ).accounted_cr                := 0;
           g_pa_fc_com_rec_tab( l_index ).entered_cr                  := 0;
           g_pa_fc_com_rec_tab( l_index ).txn_ccid                    := p_txn_ccid;
           g_pa_fc_com_rec_tab( l_index ).org_id                      := p_org_id;
           g_pa_fc_com_rec_tab( l_index ).last_update_date            := SYSDATE;
           g_pa_fc_com_rec_tab( l_index ).last_updated_by             := FND_GLOBAL.user_id;
           g_pa_fc_com_rec_tab( l_index ).created_by                  := FND_GLOBAL.user_id;
           g_pa_fc_com_rec_tab( l_index ).creation_date               := SYSDATE;
           g_pa_fc_com_rec_tab( l_index ).last_update_login           := FND_GLOBAL.login_id;

       END IF; -- Commitment Budget

       -- Set variables for Standard Budget.
       IF p_budget_type = 'GL'
       THEN
           g_pa_fc_pay_rec_tab( l_index ).packet_id := g_bc_packet_id_pay;
           g_pa_fc_pay_rec_tab( l_index ).ext_budget_type := 'GL';

           IF p_cc_state = 'PR' -- Provisional
           THEN
               g_pa_fc_pay_rec_tab( l_index ).document_type := 'CC_P_PAY';
               g_pa_fc_pay_rec_tab( l_index ).je_category_name := 'Provisional';
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs not required*/
               g_pa_fc_pay_rec_tab( l_index ).encumbrance_type_id := null; --g_req_encumbrance_type_id;
               g_pa_fc_pay_rec_tab( l_index ).entered_dr := p_encumbered_amt;
               g_pa_fc_pay_rec_tab( l_index ).accounted_dr := p_encumbered_amt;
           ELSIF p_cc_state = 'CM' -- Confirmed
           THEN
               g_pa_fc_pay_rec_tab( l_index ).document_type := 'CC_C_PAY';
               g_pa_fc_pay_rec_tab( l_index ).je_category_name := 'Confirmed';
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs not required*/
               g_pa_fc_pay_rec_tab( l_index ).encumbrance_type_id := null; --g_purch_encumbrance_type_id;
/*               IF g_purch_encumbrance_type_id = g_inv_encumbrance_type_id
               THEN
                   g_pa_fc_pay_rec_tab( l_index ).entered_dr := p_encumbered_amt;
                   g_pa_fc_pay_rec_tab( l_index ).accounted_dr := p_encumbered_amt;
               ELSE */
                   g_pa_fc_pay_rec_tab( l_index ).entered_dr := Nvl(p_encumbered_amt,0)-
                                                                Nvl(p_billed_amt,0);
                   g_pa_fc_pay_rec_tab( l_index ).accounted_dr := Nvl(p_encumbered_amt,0)-
                                                                Nvl(p_billed_amt,0);
--               END IF;
           END IF;

           g_pa_fc_pay_rec_tab( l_index ).document_distribution_id := p_cc_det_pf_line_id;
           OPEN c_period_details (p_transaction_date,
                                  p_sob_id);
           FETCH c_period_details INTO
                     g_pa_fc_pay_rec_tab( l_index ).period_name,
                     g_pa_fc_pay_rec_tab( l_index ).period_num,
                     g_pa_fc_pay_rec_tab( l_index ).period_year;
           CLOSE c_period_details;

           g_pa_fc_pay_rec_tab( l_index ).project_id                  := p_project_id;
           g_pa_fc_pay_rec_tab( l_index ).task_id                     := p_task_id;
           g_pa_fc_pay_rec_tab( l_index ).expenditure_type            := p_expenditure_type;
           g_pa_fc_pay_rec_tab( l_index ).expenditure_item_date       := p_expenditure_item_date;
           g_pa_fc_pay_rec_tab( l_index ).expenditure_organization_id := p_expenditure_org_id;
           g_pa_fc_pay_rec_tab( l_index ).set_of_books_id             := p_sob_id;
           g_pa_fc_pay_rec_tab( l_index ).je_source_name              := 'Contract Commitment';
           g_pa_fc_pay_rec_tab( l_index ).status_code                 := 'P';
           g_pa_fc_pay_rec_tab( l_index ).funds_process_mode          := 'T';
           g_pa_fc_pay_rec_tab( l_index ).document_header_id          := p_cc_header_id;
           g_pa_fc_pay_rec_tab( l_index ).burden_cost_flag            := 'N';
           g_pa_fc_pay_rec_tab( l_index ).balance_posted_flag         := 'N';
           g_pa_fc_pay_rec_tab( l_index ).actual_flag                 := 'E';
           g_pa_fc_pay_rec_tab( l_index ).accounted_cr                := 0;
           g_pa_fc_pay_rec_tab( l_index ).entered_cr                  := 0;
           g_pa_fc_pay_rec_tab( l_index ).txn_ccid                    := p_txn_ccid;
           g_pa_fc_pay_rec_tab( l_index ).org_id                      := p_org_id;
           g_pa_fc_pay_rec_tab( l_index ).last_update_date            := SYSDATE;
           g_pa_fc_pay_rec_tab( l_index ).last_updated_by             := FND_GLOBAL.user_id;
           g_pa_fc_pay_rec_tab( l_index ).created_by                  := FND_GLOBAL.user_id;
           g_pa_fc_pay_rec_tab( l_index ).creation_date               := SYSDATE;
           g_pa_fc_pay_rec_tab( l_index ).last_update_login           := FND_GLOBAL.login_id;

--Output_Debug('Project Id  ' || g_pa_fc_pay_rec_tab( l_index ).project_id);
--Output_Debug('task Id  ' ||  g_pa_fc_pay_rec_tab( l_index ).task_id);
--OUtput_Debug('Exp Type ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_type);
--Output_debug('Ecp date ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_item_date);
--Output_Debug('Exp Org ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_organization_id);

-- bug 3199488, start block
IF (l_state_level >= l_debug_level) THEN
    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.populate_pa_table.Msg1',
                                  'Project Id  ' || g_pa_fc_pay_rec_tab( l_index ).project_id);
    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.populate_pa_table.Msg2',
                                  'task Id  ' ||  g_pa_fc_pay_rec_tab( l_index ).task_id);
    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.populate_pa_table.Msg3',
                                  'Exp Type ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_type);
    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.populate_pa_table.Msg4',
                                  'Ecp date ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_item_date);
    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.populate_pa_table.Msg5',
                                  'Exp Org ' || g_pa_fc_pay_rec_tab( l_index ).expenditure_organization_id);
END IF;
-- bug 3199488, end block

       END IF; -- Standard Budget.

    END populate_pa_table;

    -- Bug 2871052, Bidisha S End

/***************************************************************************/
-- Main program which selects all the records from Header Interface table
-- and calls other programs for processing
/***************************************************************************/
  PROCEDURE HEADER_INTERFACE_MAIN
     ( ERRBUF    OUT NOCOPY VARCHAR2,
       RETCODE   OUT NOCOPY VARCHAR2,
       P_Process_Phase IN VARCHAR2,
       P_Batch_Id IN NUMBER)
     IS
     l_error_status         VARCHAR2(1) DEFAULT 'N';
     l_current_org_id       NUMBER;
     l_current_user_id      NUMBER;
     l_current_login_id     NUMBER;
     l_current_set_of_books_id NUMBER;
    /* Bug No : 6341012. MOAC uptake. Local variable for Set_of_books name*/
     l_sob_name VARCHAR2(30);
     l_row_id               VARCHAR2(18);
     l_flag                 VARCHAR2(1);
     l_header_id            NUMBER;
     l_parent_header_id     NUMBER;
     l_parent_acct_line_id  NUMBER;
     l_parent_det_pf_id     NUMBER;
     l_cbc_enable_flag      VARCHAR2(1);
     l_func_currency_code   VARCHAR2(15);
     l_return_status        VARCHAR2(1);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(12000);
     l_error_text           VARCHAR2(12000);
     l_msg_buf              VARCHAR2(2000);
     l_request_id	    NUMBER;
     l_interface_header_record igc_cc_headers_interface%ROWTYPE;
     l_start_date              gl_periods.start_date%TYPE;
     l_end_date                gl_periods.end_date%TYPE;
     l_curr_year_pf_lines      NUMBER;
     l_error_message	       igc_cc_interface_errors.error_message%TYPE;
     l_history_message	       VARCHAR2(240);
     l_wait_for_request	       BOOLEAN;
     l_phase		       VARCHAR2(240);
     l_status		       VARCHAR2(240);
     l_dev_phase	       VARCHAR2(240);
     l_dev_status	       VARCHAR2(240);
     l_message		       VARCHAR2(240);

     -- 01/03/02, CC enabled in IGI
     l_option_name             VARCHAR2(80);
     lv_message                VARCHAR2(1000);

     -- For Bug 2871052
     l_cbc_return_code         VARCHAR2(1) := 'S';
     l_pa_cb_funds_check_pass  BOOLEAN := TRUE;
     l_pa_sb_funds_check_pass  BOOLEAN := TRUE;
     l_error_msg               VARCHAR2(2000);

     --variables related to XML Report
     l_terr                      VARCHAR2(10):='US';
     l_lang                      VARCHAR2(10):='en';
     l_layout                    BOOLEAN;

     CURSOR c_interface_header_records IS
            SELECT * FROM igc_cc_headers_interface
            WHERE batch_id = P_Batch_Id
            ORDER BY cc_type DESC;

-- Start Date and End Date of current fiscal year for set of books
-- indicated by P_Sob_Id

     CURSOR c_fiscal_year_dates(P_Sob_Id NUMBER)
        IS
        SELECT MIN(start_date) start_date, MAX(end_date) end_date
        FROM    GL_PERIODS GP,
                GL_SETS_OF_BOOKS GB
        WHERE
              GP.period_set_name          = GB.period_set_name       AND
              GP.period_type              = GB.accounted_period_type AND
              GB.set_of_books_id          = P_Sob_Id                 AND
              TO_CHAR(start_date, 'YYYY') = to_char(sysdate, 'YYYY') AND
              TO_CHAR(end_date, 'YYYY')   = to_char(sysdate, 'YYYY') AND
              GP.adjustment_period_flag   = 'N';

     CURSOR c_cur_packet IS
        SELECT gl_bc_packets_s.nextval
        FROM dual;

     BEGIN

   -- 01/03/02, check to see if CC is installed
   IF NOT igi_gen.is_req_installed('CC') THEN

      SELECT meaning
      INTO l_option_name
      FROM igi_lookups
      WHERE lookup_code = 'CC'
      AND lookup_type = 'GCC_DESCRIPTION';

      FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
      lv_message := fnd_message.get;
      errbuf := lv_message;
      retcode := 2;
      return;
   END IF;


--
--        IF g_debug_flag = 'Y'
--        THEN
--              Output_Debug('Starting Open Interface Import process');
              -- bug 3199488, start block
              IF (l_state_level >= l_debug_level) THEN
                 FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg1',
                                             'Starting Open Interface Import process');
              END IF;
              -- bug 3199488, end block
--        END IF;
	RETCODE := '0';
        g_process_phase := P_Process_Phase;
        g_batch_id := P_Batch_Id;

-- Delete all the old records from IGC_CC_INTERFACE_ERRORS
        DELETE IGC_CC_INTERFACE_ERRORS;

        COMMIT;

        -- Bug 2871052
        -- Clear out the PLSQL tables
        g_pa_fc_com_rec_tab.DELETE;
        g_pa_fc_pay_rec_tab.DELETE;

        -- Generate 2 gl bc packet sequence
        -- 1 packet will contain all the records for the commitment budget
        -- The other packet will contain all records for the standard budget.
        OPEN  c_cur_packet;
        FETCH c_cur_packet INTO g_bc_packet_id_com;
        CLOSE c_cur_packet;

        OPEN  c_cur_packet;
        FETCH c_cur_packet INTO g_bc_packet_id_pay;
        CLOSE c_cur_packet;
        -- 2871052, End

-- Get the profile values
/* Bug No : 6341012. MOAC uptake. ORG_ID,SOB_ID are retrieved from packages rather than from profiles*/
--     l_current_org_id := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
	l_current_org_id := MO_GLOBAL.get_current_org_id;
        l_current_user_id := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));
        l_current_login_id := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));
--     l_current_set_of_books_id := TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID'));
	MO_UTILS.get_ledger_info(l_current_org_id,l_current_set_of_books_id,l_sob_name);


-- Get the Dual Budgetary Control Enable Flag
      BEGIN
        SELECT NVL(cc_bc_enable_flag,'N') INTO l_cbc_enable_flag
        FROM igc_cc_bc_enable
        WHERE set_of_books_id = l_current_set_of_books_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN l_cbc_enable_flag := 'N';
      END;

-- Get the Functional Currency Code
      BEGIN
        SELECT currency_code INTO l_func_currency_code
        FROM gl_sets_of_books
        WHERE set_of_books_id = l_current_set_of_books_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;

-- Get the start date and end date of current fiscal year
      OPEN c_fiscal_year_dates(l_current_set_of_books_id);
      FETCH c_fiscal_year_dates INTO l_start_date, l_end_date;
      CLOSE c_fiscal_year_dates;

      -- get the setup flags. 1833267
      -- Added the 5 encumbrance type ids for 2871052
      get_setup_flags (p_set_of_books_id        => l_current_set_of_books_id,
                       p_org_id                 => l_current_org_id,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
                       p_cc_bc_enable_flag      => g_cc_bc_enable_flag,
                       p_sbc_enable_flag        => g_sbc_enable_flag,
--                    p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                    p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag,
                       p_sb_prov_encmbrnc_flag  => g_sb_prov_encmbrnc_flag,
                       p_sb_conf_encmbrnc_flag  => g_sb_conf_encmbrnc_flag
--		       ,
--                    p_prov_encumbrance_type_id  => g_prov_encumbrance_type_id,
--                    p_conf_encumbrance_type_id  => g_conf_encumbrance_type_id,
--                    p_req_encumbrance_type_id   => g_req_encumbrance_type_id,
--                    p_purch_encumbrance_type_id => g_purch_encumbrance_type_id,
--                    p_inv_encumbrance_type_id   => g_inv_encumbrance_type_id
			);

-- Process the header records one by one
        OPEN c_interface_header_records;
        LOOP
          FETCH c_interface_header_records INTO l_interface_header_record;
          EXIT WHEN c_interface_header_records%NOTFOUND;

          HEADER_INTERFACE_VALIDATE
              ( l_interface_header_record.Interface_Header_Id,
                l_interface_header_record.Org_Id,
                l_interface_header_record.Cc_Type,
                l_interface_header_record.Cc_Num,
                l_interface_header_record.Cc_Version_Num,
                l_interface_header_record.Interface_Parent_Header_Id,
                l_interface_header_record.Cc_State,
                l_interface_header_record.Cc_Ctrl_Status,
                l_interface_header_record.Cc_Encmbrnc_Status,
                l_interface_header_record.Cc_Apprvl_Status,
                l_interface_header_record.Vendor_Id,
                l_interface_header_record.Vendor_Site_Id,
                l_interface_header_record.Vendor_Contact_Id,
                l_interface_header_record.Term_Id,
                l_interface_header_record.Location_Id,
                l_interface_header_record.Set_of_Books_Id,
                l_interface_header_record.Cc_Acct_Date,
                l_interface_header_record.Cc_Start_Date,
                l_interface_header_record.Cc_End_Date,
                l_interface_header_record.Cc_Owner_User_Id,
                l_interface_header_record.Cc_Preparer_User_Id,
                l_interface_header_record.Currency_Code,
                l_interface_header_record.Conversion_Type,
                l_interface_header_record.Conversion_Rate,
                l_interface_header_record.Conversion_Date,
                l_interface_header_record.Created_By,
                l_interface_header_record.CC_Guarantee_Flag,
                l_interface_header_record.cc_current_user_id,
--Bug 2373685   l_current_user_id,
                l_error_status,
                l_current_org_id,
                l_current_set_of_books_id,
		l_func_currency_code,
		l_cbc_enable_flag);

 -- If validation succeeds, get the derived values and insert header record.
        IF UPPER(g_process_phase) = 'F' AND UPPER(l_error_status) = 'N' THEN

            HEADER_INTERFACE_DERIVE( l_header_id );

            -- fix bug 2197872 start(1),
            -- l_parent_header_id, l_parent_acct_line_id and l_parent_det_pf_id should be
            -- null before procedure GET_PARENT_ID is called else their values will
            -- always remain the same

	    l_parent_header_id := NULL;
	    l_parent_acct_line_id := NULL;
	    l_parent_det_pf_id := NULL;

            -- fix bug 2197872 end (1)

            IF (l_interface_header_record.Cc_Type = 'R') THEN
              GET_PARENT_ID( l_interface_header_record.Interface_Parent_Header_Id,
                             NULL,
                             NULL,
                             l_parent_header_id,
                             l_parent_acct_line_id,
                             l_parent_det_pf_id);

            -- fix bug 2197872 start(2)
	     -- ELSE
	     --   l_parent_header_id := NULL;
	     --   l_parent_acct_line_id := NULL;
	     --   l_parent_det_pf_id := NULL;
            -- fix bug 2197872 end(2)

            END IF;

            IGC_CC_HEADERS_PKG.Insert_Row(
                       1.0,
                       FND_API.G_TRUE,
                       FND_API.G_FALSE,
                       FND_API.G_VALID_LEVEL_FULL,
                       l_return_status,
                       l_msg_count,
                       l_msg_data,
                       l_row_id,
                       l_header_id,
                       l_interface_header_record.Org_Id,
                       l_interface_header_record.CC_Type,
                       l_interface_header_record.CC_Num,
                       NVL(l_interface_header_record.CC_Version_num, 0) + 1,
                       l_parent_header_id,
                       l_interface_header_record.CC_State,
                       l_interface_header_record.CC_Ctrl_status,
                       l_interface_header_record.CC_Encmbrnc_Status,
                       l_interface_header_record.CC_Apprvl_Status,
                       l_interface_header_record.Vendor_Id,
                       l_interface_header_record.Vendor_Site_Id,
                       l_interface_header_record.Vendor_Contact_Id,
                       l_interface_header_record.Term_Id,
                       l_interface_header_record.Location_Id,
                       l_interface_header_record.Set_Of_Books_Id,
                       l_interface_header_record.CC_Acct_Date,
                       l_interface_header_record.CC_Desc,
                       l_interface_header_record.CC_Start_Date,
                       l_interface_header_record.CC_End_Date,
                       l_interface_header_record.CC_Owner_User_Id,
                       l_interface_header_record.CC_Preparer_User_Id,
                       l_interface_header_record.Currency_Code,
                       l_interface_header_record.Conversion_Type,
                       l_interface_header_record.Conversion_Date,
                       l_interface_header_record.Conversion_Rate,
                       sysdate,
                       l_current_user_id,
                       l_current_login_id,
                       NVL(l_interface_header_record.Created_By, l_current_user_id),
                       NVL(l_interface_header_record.Creation_Date, sysdate),
                       l_interface_header_record.CC_Current_User_Id,
                       l_interface_header_record.Wf_Item_Type,
                       l_interface_header_record.Wf_Item_Key,
                       l_interface_header_record.Attribute1,
                       l_interface_header_record.Attribute2,
                       l_interface_header_record.Attribute3,
                       l_interface_header_record.Attribute4,
                       l_interface_header_record.Attribute5,
                       l_interface_header_record.Attribute6,
                       l_interface_header_record.Attribute7,
                       l_interface_header_record.Attribute8,
                       l_interface_header_record.Attribute9,
                       l_interface_header_record.Attribute10,
                       l_interface_header_record.Attribute11,
                       l_interface_header_record.Attribute12,
                       l_interface_header_record.Attribute13,
                       l_interface_header_record.Attribute14,
                       l_interface_header_record.Attribute15,
                       l_interface_header_record.Context,
                       Nvl(l_interface_header_record.CC_Guarantee_Flag,'N'),
                       l_flag);
            IF l_return_status IN ('E','U') THEN
		l_msg_buf := ' ';
              	FOR j IN 1..NVL(l_msg_count,0) LOOP
	          BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_header_record.Interface_Header_id,
                	  NULL,
                	  NULL,
                          l_interface_header_record.Org_Id,
                          l_interface_header_record.Set_Of_Books_Id,
                          l_msg_buf,
                	  l_error_status);
                  END;
                END LOOP;
            END IF;
          END IF;

          g_cc_state :=  l_interface_header_record.Cc_State;
          g_cc_apprvl_status :=  l_interface_header_record.Cc_apprvl_status;

-- Process the corresponding acct line records for the header record.
          ACCT_LINE_INTERFACE_MAIN
                  ( l_interface_header_record.Interface_Header_Id,
                    l_header_id,
                    l_interface_header_record.Interface_Parent_Header_Id,
                    l_parent_header_id,
                    l_interface_header_record.Org_Id,
                    l_interface_header_record.Set_of_Books_Id,
                    l_interface_header_record.Cc_Type,
                    l_interface_header_record.Cc_Encmbrnc_Status,
                    l_interface_header_record.Cc_Start_Date,
                    l_interface_header_record.Cc_End_Date,
                    l_interface_header_record.Cc_Acct_Date,
                    l_current_user_id,
                    l_current_login_id,
                    l_interface_header_record.CC_State,
                    l_interface_header_record.CC_Apprvl_Status,
                    l_error_status);

-- Create PO if all the reqd conditions are met.
          IF UPPER(g_process_phase) = 'F' AND UPPER(l_error_status) = 'N'
                AND l_interface_header_record.CC_State = 'CM'
                AND l_interface_header_record.CC_Apprvl_Status = 'AP'
		AND l_interface_header_record.CC_Type IN ('S','R') THEN

            l_curr_year_pf_lines := 0;

-- Check whether current fiscal year payment forecast lines exist in CC

            BEGIN
                        -- Bug 2124447, payment forecast records for date < current fiscal year.
                        -- Need not be only for current year
--                      WHERE  ( b.cc_det_pf_date >= l_start_date
--			AND b.cc_det_pf_date <= l_end_date)


                        SELECT count(interface_det_pf_line_id)
                        INTO   l_curr_year_pf_lines
                        FROM   igc_cc_det_pf_interface b
                        WHERE b.cc_det_pf_date <= l_end_date
			AND b.interface_acct_line_id IN (SELECT interface_acct_line_id
                                                  FROM igc_cc_acct_lines_interface a
                                                  WHERE a.interface_header_id = l_interface_header_record.Interface_Header_Id);
            EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                             l_curr_year_pf_lines := 0;
            END;

            IF (l_curr_year_pf_lines > 0) THEN

              IGC_CC_PO_INTERFACE_PKG.CONVERT_CC_TO_PO
                    ( 1.0,
                       FND_API.G_TRUE,
                       FND_API.G_FALSE,
                       FND_API.G_VALID_LEVEL_FULL,
                       l_return_status,
                       l_msg_count,
                       l_msg_data,
                       l_header_id);
              IF l_return_status IN ('E','U') THEN
		l_msg_buf := ' ';
              	FOR j IN 1..NVL(l_msg_count,0) LOOP
	          BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_header_record.Interface_Header_id,
                	  NULL,
                	  NULL,
                          l_interface_header_record.Org_Id,
                          l_interface_header_record.Set_Of_Books_Id,
                          l_msg_buf,
                	  l_error_status);
                  END;
                END LOOP;
              END IF;

	      IF l_interface_header_record.CC_Ctrl_Status = 'O' AND UPPER(l_error_status) = 'N' THEN
                IGC_CC_PO_INTERFACE_PKG.UPDATE_PO_APPROVED_FLAG
                    ( 1.0,
                       FND_API.G_TRUE,
                       FND_API.G_FALSE,
                       FND_API.G_VALID_LEVEL_FULL,
                       l_return_status,
                       l_msg_count,
                       l_msg_data,
                       l_header_id);
                IF l_return_status IN ('E','U') THEN
		  l_msg_buf := ' ';
              	  FOR j IN 1..NVL(l_msg_count,0) LOOP
	            BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_header_record.Interface_Header_id,
                	  NULL,
                	  NULL,
                          l_interface_header_record.Org_Id,
                          l_interface_header_record.Set_Of_Books_Id,
                          l_msg_buf,
                	  l_error_status);
                    END;
                  END LOOP;
                END IF;
	      END IF;
	    END IF;
          END IF;

-- Insert record into table IGC_CC_ACTIONS
          IF UPPER(g_process_phase) = 'F' AND UPPER(l_error_status) = 'N' THEN
	  	l_history_message := NULL;
	  	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENTERED_THRU_CCOI_PROG');
	  	l_history_message := FND_MESSAGE.GET;
		IGC_CC_ACTIONS_PKG.Insert_Row(
                        1.0,
                        FND_API.G_TRUE,
                        FND_API.G_FALSE,
                        FND_API.G_VALID_LEVEL_FULL,
                        l_return_status,
                        l_msg_count,
                        l_msg_data,
                        l_row_id,
              	        l_header_id,
	                NVL(l_interface_header_record.CC_Version_num, 0) + 1,
	                'EN',
	                l_interface_header_record.CC_State,
	                l_interface_header_record.CC_ctrl_status,
	                l_interface_header_record.CC_Apprvl_Status,
			l_history_message,
	                sysdate,
	                l_current_user_id,
	                l_current_login_id,
	                sysdate,
	                l_current_user_id );
                IF l_return_status IN ('E','U') THEN
		  l_msg_buf := ' ';
              	  FOR j IN 1..NVL(l_msg_count,0) LOOP
	            BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_header_record.Interface_Header_id,
                	  NULL,
                	  NULL,
                          l_interface_header_record.Org_Id,
                          l_interface_header_record.Set_Of_Books_Id,
                          l_msg_buf,
			  l_error_status);
		    END;
                  END LOOP;
                END IF;

            IF UPPER(l_interface_header_record.CC_Encmbrnc_Status) IN ('P', 'C') AND UPPER(l_error_status) = 'N' THEN
	  	l_history_message := NULL;
	  	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENCMBRED_THRU_CCOI_PROG');
	  	l_history_message := FND_MESSAGE.GET;
		IGC_CC_ACTIONS_PKG.Insert_Row(
                        1.0,
                        FND_API.G_TRUE,
                        FND_API.G_FALSE,
                        FND_API.G_VALID_LEVEL_FULL,
                        l_return_status,
                        l_msg_count,
                        l_msg_data,
                        l_row_id,
              	        l_header_id,
	                NVL(l_interface_header_record.CC_Version_num, 0) + 1,
	                'EC',
	                l_interface_header_record.CC_State,
	                l_interface_header_record.CC_ctrl_status,
	                l_interface_header_record.CC_Apprvl_Status,
			l_history_message,
	                sysdate,
	                l_current_user_id,
	                l_current_login_id,
	                sysdate,
	                l_current_user_id );
                IF l_return_status IN ('E','U') THEN
		  l_msg_buf := ' ';
              	  FOR j IN 1..NVL(l_msg_count,0) LOOP
	            BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_header_record.Interface_Header_id,
                	  NULL,
                	  NULL,
                          l_interface_header_record.Org_Id,
                          l_interface_header_record.Set_Of_Books_Id,
                          l_msg_buf,
			  l_error_status);
		    END;
                  END LOOP;
                END IF;

	    END IF;
	  END IF;

        END LOOP;
        CLOSE c_interface_header_records;

-- Insert the orphan interface acct lines and det pf lines into
-- igc_cc_interface_errors, if any.
        INSERT_ORPHAN_RECORDS
                ( l_error_status );

        -- If process phase is final and no errors encountered
        -- then call the PA funds checker to check funds in PA Budget
        -- Bug 2871052
        IF UPPER(g_process_phase) = 'F' AND UPPER(l_error_status) = 'N'
        THEN
            IF g_pa_cb_funds_check_required
            THEN
                 l_pa_cb_funds_check_pass := TRUE;

--                 IF g_debug_flag = 'Y'
--                 THEN
--                     Output_Debug('Calling PA_cc_enc_import_fck.Load_pkts for ' ||
--                                  ' packet id '|| to_char( g_bc_packet_id_com) ||
--                                  ' for commitment budget');
--                 END IF;

                   -- bug 3199488, start block
                   IF (l_state_level >= l_debug_level) THEN
                      FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg2',
                                                    'Calling PA_cc_enc_import_fck.Load_pkts for ' ||
                                                    ' packet id '|| to_char( g_bc_packet_id_com) ||
                                                    ' for commitment budget');
                   END IF;
                   -- bug 3199488, end block

                 -- Call PA API to insert rows in pa_bc_packets
                 -- This API loads the rows in an autonomous mode.
                 PA_cc_enc_import_fck.Load_pkts(
                      p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'CC',
                      p_packet_id        => g_bc_packet_id_com,
                      p_fc_rec_tab       => g_pa_fc_com_rec_tab,
                      x_return_status    => l_return_status,
                      x_error_msg        => l_error_msg);

                 IF l_return_status = 'S'
                 THEN
--                     IF g_debug_flag = 'Y'
--                     THEN
--                         Output_Debug('Calling PA_cc_enc_import_fck.Pa_enc_import_fck for ' ||
--                                      ' packet id '|| to_char( g_bc_packet_id_com) ||
--                                      ' for commitment budget');
--                     END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg3',
                                                         'Calling PA_cc_enc_import_fck.Pa_enc_import_fck for ' ||
                                                         ' packet id '|| to_char( g_bc_packet_id_com) ||
                                                         ' for commitment budget');
                        END IF;
                        -- bug 3199488, end block

                     -- Call PA Funds checker for all commitment records.
                     pa_cc_enc_import_fck.Pa_enc_import_fck(
                         p_calling_module  => 'CCTRXIMPORT',
                         p_ext_budget_type => 'CC',
                         p_conc_flag       => 'Y',
                         p_set_of_book_id  => l_current_set_of_books_id,
                         p_packet_id       => g_bc_packet_id_com,
                         p_mode            =>'R',
                         p_partial_flag    => 'N',
                         x_return_status   => l_return_status,
                         x_error_msg       => l_error_msg);


                     IF l_return_status <> 'S'
                     THEN
                         l_pa_cb_funds_check_pass := FALSE;

--                         IF g_debug_flag = 'Y'
--                         THEN
--                             Output_Debug('PA_cc_enc_import_fck.Pa_enc_import_fck ' ||
--                                          ' failed for packet id '||
--                                          to_char( g_bc_packet_id_com) ||
--                                          ' for commitment budget with error - ' ||
--                                          l_error_msg);
--                         END IF;

                          -- bug 3199488, start block
                          IF (l_state_level >= l_debug_level) THEN
                             FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg4',
                                                           'PA_cc_enc_import_fck.Pa_enc_import_fck ' ||
                                                           ' failed for packet id '||
                                                           ' for commitment budget with error - ' ||
                                                           l_error_msg);
                          END IF;
                          -- bug 3199488, end block

                         Fnd_Message.Set_Name('IGC', 'IGC_OPI_FAIL_PA_FC_COM');
                         Fnd_Message.Set_Token('ERROR',l_error_msg);
                         l_msg_buf := Fnd_Message.Get;
                         -- Log Interface error
            		 INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);
                     END IF;
                 ELSE -- insert into pa_bc_packet unsuccessfull.
                     l_pa_cb_funds_check_pass := FALSE;
--                     IF g_debug_flag = 'Y'
--                     THEN
--                         Output_Debug('PA_cc_enc_import_fck.Load_Pkt ' ||
--                                      ' failed for packet id '||
--                                      to_char( g_bc_packet_id_com) ||
--                                      ' for commitment budget with error - ' ||
--                                      l_error_msg);
--                     END IF;

                     -- bug 3199488, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg5',
                                                      'PA_cc_enc_import_fck.Load_Pkt ' ||
                                                      ' failed for packet id '||
                                                      ' for commitment budget with error - ' ||
                                                      l_error_msg);
                     END IF;
                     -- bug 3199488, end block

                     -- Log Interface error
                     Fnd_Message.Set_Name('IGC', 'IGC_OPI_ERR_INS_PA_COM');
                     Fnd_Message.Set_Token('ERROR',l_error_msg);
                     l_msg_buf := Fnd_Message.Get;
                     INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);

                 END IF;
            END IF ; -- PA funds check required in CBC budget

            -- If the funds check in commitment budget was successfull
            -- then call the PA funds checker for the standard budget.
            IF g_pa_sb_funds_check_required
            AND l_pa_cb_funds_check_pass
            THEN
                 l_pa_sb_funds_check_pass := TRUE;
--                 IF g_debug_flag = 'Y'
--                 THEN
--                     Output_Debug('Calling PA_cc_enc_import_fck.Load_pkts for ' ||
--                                  ' packet id '|| to_char( g_bc_packet_id_pay) ||
--                                  ' for standard budget');
--                 END IF;

                 -- bug 3199488, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg6',
                                                       'Calling PA_cc_enc_import_fck.Load_pkts for ' ||
                                                       ' packet id '|| to_char( g_bc_packet_id_pay) ||
                                                       ' for standard budget');
                     END IF;
                 -- bug 3199488, end block

                 -- Call PA API to insert rows in pa_bc_packets
                 -- This is done in autonomous mode
                 PA_cc_enc_import_fck.Load_pkts(
                      p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'GL',
                      p_packet_id        => g_bc_packet_id_pay,
                      p_fc_rec_tab       => g_pa_fc_pay_rec_tab,
                      x_return_status    => l_return_status,
                      x_error_msg        => l_error_msg);

                 IF l_return_status = 'S'
                 THEN
--                     IF g_debug_flag = 'Y'
--                     THEN
--                         Output_Debug('Calling PA_cc_enc_import_fck.Pa_enc_import_fck for ' ||
--                                      ' packet id '|| to_char( g_bc_packet_id_pay) ||
--                                      ' for standard budget');
--                     END IF;

                 -- bug 3199488, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg7',
                                                       'Calling PA_cc_enc_import_fck.Pa_enc_import_fck for ' ||
                                                       ' packet id '|| to_char( g_bc_packet_id_pay) ||
                                                       ' for standard budget');
                     END IF;
                 -- bug 3199488, end block

                     -- Call PA Funds checker for all payment records.
                     pa_cc_enc_import_fck.Pa_enc_import_fck(
                         p_calling_module  => 'CCTRXIMPORT',
                         p_ext_budget_type => 'GL',
                         p_conc_flag       => 'Y',
                         p_set_of_book_id  => l_current_set_of_books_id,
                         p_packet_id       => g_bc_packet_id_pay,
                         p_mode            =>'R',
                         p_partial_flag    => 'N',
                         x_return_status   => l_return_status,
                         x_error_msg       => l_error_msg);

                     IF l_return_status <> 'S'
                     THEN
                         l_pa_sb_funds_check_pass := FALSE;

--                         IF g_debug_flag = 'Y'
--                         THEN
--                             Output_Debug('PA_cc_enc_import_fck.Pa_enc_import_fck ' ||
--                                          ' failed for packet id '||
--                                          to_char( g_bc_packet_id_pay) ||
--                                          ' for standard budget with error - ' ||
--                                          l_error_msg);
--                         END IF;

                         -- bug 3199488, start block
                         IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg8',
                                                          'PA_cc_enc_import_fck.Pa_enc_import_fck ' ||
                                                          ' failed for packet id '||
                                                          to_char( g_bc_packet_id_pay) ||
                                                          ' for standard budget with error - ' ||
                                                          l_error_msg);
                         END IF;
                         -- bug 3199488, end block

                         -- Log Interface error
                         Fnd_Message.Set_Name('IGC', 'IGC_OPI_FAIL_PA_FC_STD');
                         Fnd_Message.Set_Token('ERROR',l_error_msg);
                         l_msg_buf := Fnd_Message.Get;
            		 INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);

                     END IF;
                 ELSE -- insert into pa_bc_packet unsuccessfull.
                     -- Log Interface error;
                     l_pa_sb_funds_check_pass := FALSE;

--                     IF g_debug_flag = 'Y'
--                     THEN
--                         Output_Debug('PA_cc_enc_import_fck.Load_Pkt ' ||
--                                      ' failed for packet id '||
--                                      to_char( g_bc_packet_id_pay) ||
--                                      ' for standard budget with error - ' ||
--                                      l_error_msg);
--                     END IF;

                     -- bug 3199488, start block
                     IF (l_state_level >= l_debug_level) THEN
                        FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg9',
                                                      'PA_cc_enc_import_fck.Load_Pkt ' ||
                                                      ' failed for packet id '||
                                                      to_char( g_bc_packet_id_pay) ||
                                                      ' for standard budget with error - ' ||
                                                      l_error_msg);
                     END IF;
                     -- bug 3199488, end block

                     Fnd_Message.Set_Name('IGC', 'IGC_OPI_ERR_INS_PA_STD');
                     Fnd_Message.Set_Token('ERROR',l_error_msg);
                     l_msg_buf := Fnd_Message.Get;
                     INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);
                 END IF;
            END IF; -- PA funds check required in Standard Budget

            -- Check if any of the funds check failed.
            -- If so, records need to be updated accordingly
            IF NOT l_pa_cb_funds_check_pass
            OR NOT l_pa_sb_funds_check_pass
            THEN
                l_error_status := 'Y';
                l_cbc_return_code := 'F';
            ELSE
                l_cbc_return_code := 'S';
            END IF;

            -- Call PA tie back API for the commitment budget
            -- whether sucessfull or fail, it needs to be called.
            IF g_pa_cb_funds_check_required
            THEN
--                IF g_debug_flag = 'Y'
--                THEN
--                     Output_Debug('Calling PA_cc_enc_import_fck.Pa_enc_import_fck_tieback for ' ||
--                                  ' packet id '|| to_char( g_bc_packet_id_com) ||
--                                  ' for commitment budget');
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg10',
                                                 'Calling PA_cc_enc_import_fck.Pa_enc_import_fck_tieback for ' ||
                                                 ' packet id '|| to_char( g_bc_packet_id_com) ||
                                                 ' for commitment budget');
                END IF;
                -- bug 3199488, end block

                PA_CC_enc_import_fck.Pa_enc_import_fck_tieback
                     (p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'CC',
                      p_packet_id        => g_bc_packet_id_com,
                      p_mode             => 'R',
                      p_partial_flag     => 'N',
                      p_cbc_return_code  => l_cbc_return_code,
                      x_return_status    => l_return_status);

                IF l_return_status <> 'S'
                THEN
--                    IF g_debug_flag = 'Y'
--                    THEN
--                         Output_Debug('PA_cc_enc_import_fck.Pa_enc_import_fck_tieback '||
--                                      ' failed for ' ||
--                                      ' packet id '|| to_char( g_bc_packet_id_com) ||
--                                      ' for commitment budget');
--                    END IF;

                     -- bug 3199488, start block
                     IF (l_state_level >= l_debug_level) THEN
                        FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg11',
                                                      'PA_cc_enc_import_fck.Pa_enc_import_fck_tieback '||
                                                      ' failed for ' ||
                                                      ' packet id '|| to_char( g_bc_packet_id_com) ||
                                                      ' for commitment budget');
                     END IF;
                     -- bug 3199488, end block

                    Fnd_Message.Set_Name('IGC', 'IGC_OPI_ERR_COM_TIEBACK');
                    l_msg_buf := Fnd_Message.Get;
                    INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);
                END IF;
            END IF; -- Call PA API for commitment budget tieback

            IF g_pa_sb_funds_check_required
            THEN
--                IF g_debug_flag = 'Y'
--                THEN
--                    Output_Debug('Calling PA_cc_enc_import_fck.Pa_enc_import_fck_tieback for ' ||
--                                  ' packet id '|| to_char( g_bc_packet_id_pay) ||
--                                  ' for standard budget');
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg12',
                                                 'Calling PA_cc_enc_import_fck.Pa_enc_import_fck_tieback for ' ||
                                                 ' packet id '|| to_char( g_bc_packet_id_pay) ||
                                                 ' for standard budget');
                END IF;
                -- bug 3199488, end block

                PA_CC_enc_import_fck.Pa_enc_import_fck_tieback
                     (p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'GL',
                      p_packet_id        => g_bc_packet_id_pay,
                      p_mode             => 'R',
                      p_partial_flag     => 'N',
                      p_cbc_return_code  => l_cbc_return_code,
                      x_return_status    => l_return_status);

                IF l_return_status <> 'S'
                THEN
--                    IF g_debug_flag = 'Y'
--                    THEN
--                         Output_Debug('PA_cc_enc_import_fck.Pa_enc_import_fck_tieback '||
--                                      ' failed for ' ||
--                                      ' packet id '|| to_char( g_bc_packet_id_pay) ||
--                                      ' for payment budget');
--                    END IF;

                    -- bug 3199488, start block
                    IF (l_state_level >= l_debug_level) THEN
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg13',
                                                     'PA_cc_enc_import_fck.Pa_enc_import_fck_tieback '||
                                                     ' failed for ' ||
                                                     ' packet id '|| to_char( g_bc_packet_id_pay) ||
                                                     ' for payment budget');
                    END IF;
                    -- bug 3199488, end block

                    Fnd_Message.Set_Name('IGC', 'IGC_OPI_ERR_STD_TIEBACK');
                    Fnd_Message.Set_Token('ERROR',l_error_msg);
                    l_msg_buf := Fnd_Message.Get;
                    INTERFACE_HANDLE_ERRORS
               	      	    (NULL,
                    	     NULL,
                	     NULL,
                             l_current_org_id,
                             l_current_set_of_books_id,
                             l_msg_buf,
			     l_error_status);
                END IF;
            END IF ; -- Call API to tie back Standard budget
        END IF ; -- call PA funds checker , Bug 2871052

-- Submit the request for running the errors report.
/*Bug No : 6341012. MOAC Uptake. Set ORG_ID before submitting request */

      Fnd_request.set_org_id(l_current_org_id);
	l_request_id := FND_REQUEST.SUBMIT_REQUEST
				('IGC',
				 'IGCCLDER',
				 NULL,
				 NULL,
				 FALSE,
				 l_current_set_of_books_id,
				 l_current_org_id,
				 P_Process_Phase,
				 P_Batch_Id);
	IF l_request_id = 0 THEN
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ERR_SUBMIT_EXCPTION_RPT');
	  l_error_message := FND_MESSAGE.GET;
	  ERRBUF := ERRBUF || l_error_message;
	ELSE
	  COMMIT;
	  l_wait_for_request := FND_CONCURRENT.WAIT_FOR_REQUEST(l_request_id,
								5,
								0,
								l_phase,
								l_status,
								l_dev_phase,
								l_dev_status,
								l_message);
	END IF;
---------------------
-- Run the xml report
---------------------

        IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCLDER_XML',
                                            'IGC',
                                            'IGCCLDER_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCLDER_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
              IF l_layout then
                   Fnd_request.set_org_id(l_current_org_id);
                   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
		                       'IGC',
				       'IGCCLDER_XML',
                                        NULL,
                                        NULL,
				        FALSE,
				        l_current_set_of_books_id,
				        l_current_org_id,
				        P_Process_Phase,
                                        P_Batch_Id);
	                   IF l_request_id = 0 THEN
	                          l_error_message := NULL;
	                          FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ERR_SUBMIT_EXCPTION_RPT');
	                          l_error_message := FND_MESSAGE.GET;
	                          ERRBUF := ERRBUF || l_error_message;
                           ELSE
                           COMMIT;
	                         l_wait_for_request := FND_CONCURRENT.WAIT_FOR_REQUEST(
				                          l_request_id,
							  5,
							  0,
							  l_phase,
                                                          l_status,
							  l_dev_phase,
							  l_dev_status,
							  l_message);
                         END IF;
             END IF;

    END IF;
-----------------------------
-- End Of Run the xml report
-----------------------------


-- If all the records are inserted into CC tables without errors,
-- Delete all the successfully processed records from Interface Tables
        IF UPPER(g_process_phase) = 'F' AND UPPER(l_error_status) = 'N' THEN

          --IF g_debug_flag = 'Y'
          --THEN
          --    Output_Debug('Deleting rows from interface tables ..');
          --END IF;

          -- bug 3199488, start block
          IF (l_state_level >= l_debug_level) THEN
              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Msg14',
                                            'Deleting rows from interface tables ..');
          END IF;
          -- bug 3199488, end block

/*
          DELETE IGC.igc_cc_headers_interface
                WHERE batch_id = P_Batch_Id;
          DELETE IGC.igc_cc_acct_lines_interface
                WHERE batch_id = P_Batch_Id;
          DELETE IGC.igc_cc_det_pf_interface
                WHERE batch_id = P_Batch_Id;

*/
        END IF;

-- Make sure that if there are any messages on the stack that they are written out
-- to the concurrent request log.
        FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                    p_data  => l_msg_data );

        IF (l_msg_count > 0) THEN

           l_error_text := '';
           FOR l_cur IN 1..l_msg_count LOOP
              l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--              fnd_file.put_line (FND_FILE.LOG,
--                                 l_error_text);
              -- bug 3199488 start block
              IF (l_state_level >= l_debug_level) THEN
                  FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Excp1',
                                                 l_error_text);
              END IF;
              -- bug 3199488, end block
           END LOOP;

        END IF;

        COMMIT;

      EXCEPTION WHEN OTHERS THEN
        IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
           FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'HEADER_INTERFACE_MAIN');
        END IF;

        -- bug 3199488, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
           FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
           FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Unexp1',TRUE);
        END IF;
        -- bug 3199488, end block

        FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                    p_data  => l_msg_data );

        IF (l_msg_count > 0) THEN

           l_error_text := '';
           FOR l_cur IN 1..l_msg_count LOOP
              l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--              fnd_file.put_line (FND_FILE.LOG,
--                                 l_error_text);
              -- bug 3199488 start block
              IF (l_state_level >= l_debug_level) THEN
                  FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_open_interface_pkg.header_interface_main.Excp2',
                                                 l_error_text);
              END IF;
              -- bug 3199488, end block
           END LOOP;

        END IF;
	ROLLBACK;
	l_error_status := 'U';
        l_msg_data := TO_CHAR(SQLCODE)||': '||SQLERRM;

        -- Call the PA tieback API to make sure we revert all our changes
        -- Bug 2871052
        IF g_pa_cb_funds_check_required
        THEN
            -- Call PA tieback API.
            PA_CC_enc_import_fck.Pa_enc_import_fck_tieback
                     (p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'CC',
                      p_packet_id        => g_bc_packet_id_com,
                      p_mode             => 'R',
                      p_partial_flag     => 'N',
                      p_cbc_return_code  => 'T',
                      x_return_status    => l_return_status);
        END IF;

        IF g_pa_sb_funds_check_required
        THEN
            PA_CC_enc_import_fck.Pa_enc_import_fck_tieback
                     (p_calling_module   => 'CCTRXIMPORT',
                      p_ext_budget_type  => 'GL',
                      p_packet_id        => g_bc_packet_id_pay,
                      p_mode             => 'R',
                      p_partial_flag     => 'N',
                      p_cbc_return_code  => 'T',
                      x_return_status    => l_return_status);

        END IF;

	RETCODE := '2';
	ERRBUF := l_msg_data;

      END;

/***************************************************************************/
-- Validate the interface header record and return the result
/***************************************************************************/
   PROCEDURE HEADER_INTERFACE_VALIDATE
     ( P_Interface_Header_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Num IN VARCHAR2,
       P_Cc_Version_Num IN NUMBER,
       P_Interface_Parent_Header_Id IN NUMBER,
       P_Cc_State IN VARCHAR2,
       P_Cc_Ctrl_Status IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Apprvl_Status IN VARCHAR2,
       P_Vendor_Id IN NUMBER,
       P_Vendor_Site_Id IN NUMBER,
       P_Vendor_Contact_Id IN NUMBER,
       P_Term_Id IN NUMBER,
       P_Location_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Acct_Date IN DATE,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Cc_Owner_User_Id IN NUMBER,
       P_Cc_Preparer_User_Id IN NUMBER,
       P_Currency_Code IN VARCHAR2,
       P_Conversion_Type IN VARCHAR2,
       P_Conversion_Rate IN NUMBER,
       P_Conversion_Date IN DATE,
       P_Created_By IN NUMBER,
       P_CC_Guarantee_Flag IN VARCHAR2,
       P_CC_Current_User_Id IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2,
       P_Current_Org_Id IN  NUMBER,
       P_Current_Set_of_Books_Id IN  NUMBER,
       P_Func_Currency_Code IN VARCHAR2,
       P_Cbc_Enable_Flag IN VARCHAR2)
     IS
     l_error_message igc_cc_interface_errors.error_message%TYPE;
     l_count NUMBER;
     l_interface_parent_header_id    NUMBER;
     l_vendor_id    NUMBER;
     l_vendor_site_id   NUMBER;
     l_vendor_contact_id    NUMBER;
     l_term_id  NUMBER;
     l_location_id  NUMBER;
     l_currency_code    VARCHAR2(15);
     l_curr_code    VARCHAR2(15);
     l_conversion_type VARCHAR2(30);
     l_conversion_rate NUMBER;
     l_conversion_date DATE;
     l_set_of_books_id  NUMBER;
     l_user_id  NUMBER;
     l_start_date   DATE;
     l_end_date     DATE;
     BEGIN

-- Check the combination of CC_Type, CC_State, CC_Encmbrnc_Status,
-- Cc_Apprvl_Status and Cc_Ctrl_Status is valid

        IF P_Cbc_Enable_Flag = 'N' THEN
          IF ((P_CC_State         = 'PR' AND P_CC_Encmbrnc_Status = 'C') OR
              (P_CC_State         = 'PR' AND P_CC_Encmbrnc_Status = 'P') OR
              (P_CC_State         = 'PR' AND P_Cc_Ctrl_Status     = 'O') OR
              (P_CC_State         = 'CT' AND P_Cc_Ctrl_Status     = 'O') OR
              (P_Cc_Apprvl_Status = 'IN' AND P_Cc_Ctrl_Status     = 'O'))  THEN

	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_COMBINATION');
	    FND_MESSAGE.SET_TOKEN('CC_TYPE', P_Cc_Type, TRUE);
	    FND_MESSAGE.SET_TOKEN('CC_STATE', P_Cc_State, TRUE);
	    FND_MESSAGE.SET_TOKEN('CC_ENCUM_STATUS', P_Cc_Encmbrnc_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('APPR_STATUS', P_Cc_Apprvl_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('CTRL_STATUS', P_Cc_Ctrl_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
          END IF;
        ELSE
          IF ((P_CC_State         = 'PR' AND P_CC_Encmbrnc_Status = 'C') OR
              (P_CC_State         = 'CM' AND P_CC_Encmbrnc_Status = 'P') OR
              (P_CC_State         = 'PR' AND P_Cc_Ctrl_Status     = 'O') OR
              (P_CC_State         = 'CT' AND P_Cc_Ctrl_Status     = 'O') OR
              (P_Cc_Apprvl_Status = 'IN' AND P_Cc_Ctrl_Status     = 'O'))  THEN


	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_COMBINATION');
	    FND_MESSAGE.SET_TOKEN('CC_TYPE', P_Cc_Type, TRUE);
	    FND_MESSAGE.SET_TOKEN('CC_STATE', P_Cc_State, TRUE);
	    FND_MESSAGE.SET_TOKEN('CC_ENCUM_STATUS', P_Cc_Encmbrnc_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('APPR_STATUS', P_Cc_Apprvl_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('CTRL_STATUS', P_Cc_Ctrl_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
          END IF;
        END IF;

-- Validate the Org Id.
        IF P_Org_Id <> P_Current_Org_Id THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ORGID_NO_MATCH');
	    FND_MESSAGE.SET_TOKEN('ORGID', TO_CHAR(P_Org_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('CURR_ORGID', TO_CHAR(P_Current_Org_Id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

-- Validate the CC type.
        IF UPPER(P_Cc_Type) NOT IN ('S', 'C', 'R') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CCTYPE_INVALID');
	    FND_MESSAGE.SET_TOKEN('CC_TYPE', P_Cc_Type, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

-- Validate that the guarantee flag is not set for a Cover or a Release CC
-- 2043221, Bidisha S, 24 Oct 2001
        IF  UPPER(P_Cc_Type) <> 'S'
        AND Nvl(P_CC_Guarantee_Flag,'N') = 'Y'
        THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_OPI_INV_TYPE_FOR_GCC');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

-- Check whether the CC Number already exists in the database.
         SELECT COUNT(*) INTO l_count
         FROM igc_cc_headers
         WHERE org_id = P_Org_Id
         AND cc_num = P_Cc_Num;

         IF l_count > 0 THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DUP_CC_NUMBER');
	     FND_MESSAGE.SET_TOKEN('CC_NUMBER', P_Cc_Num);
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
         END IF;

        -- 1833267, 23 Aug 2001
       validate_start_date (p_interface_header_id    => p_interface_header_id,
/* Bug No : 6341012. p_interface_parent_header_id, p_cc_encmbrnc_status,p_sbc_enable_flag,
p_cbc_enable_flag, are not used in this procedure*/
--                         p_interface_parent_header_id =>  p_interface_parent_header_id,
                            p_org_id                 => p_org_id,
                            p_set_of_books_id        => p_set_of_books_id,
                            p_cc_type                => p_cc_type,
--                         p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                         p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                         p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag,
--                         p_sbc_enable_flag        => g_sbc_enable_flag ,
--                         p_cbc_enable_flag        => g_cc_bc_enable_flag,
                            p_cc_start_date          => p_cc_start_date,
                            p_cc_end_date            => p_cc_end_date,
                            p_x_error_status         => p_x_error_status);

    -- This procedure Validates End Date
    validate_end_date (p_interface_header_id    => p_interface_header_id,
/* Bug No : 6341012. p_interface_parent_header_id, p_cc_encmbrnc_status,p_sbc_enable_flag,
p_cbc_enable_flag,p_cbc_start_date are not used in this procedure*/
--		       p_interface_parent_header_id  => p_interface_parent_header_id,
                       p_org_id                 => p_org_id,
                       p_set_of_books_id        => p_set_of_books_id,
                       p_cc_type                => p_cc_type,
--                    p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                    p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                    p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag,
--                    p_sbc_enable_flag        => g_sbc_enable_flag ,
--                    p_cbc_enable_flag        => g_cc_bc_enable_flag,
--                    p_cc_start_date          => p_cc_start_date,
                       p_cc_end_date            => p_cc_end_date,
                       p_x_error_status         => p_x_error_status);
        -- End , 1833267

-- Interface_parent_header_id should not be null and should be a valid value
-- for CC type 'R'

      IF P_Cc_Type = 'R' THEN
        IF P_Interface_Parent_Header_Id IS NULL THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_PARENT_HDR_ID_REQD');
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
            BEGIN
                SELECT interface_header_id, cc_start_date, cc_end_date, currency_code, conversion_type, conversion_rate, conversion_date
                INTO l_interface_parent_header_id, l_start_date, l_end_date, l_curr_code, l_conversion_type, l_conversion_rate, l_conversion_date
                FROM igc_cc_headers_interface
                WHERE interface_header_id = P_Interface_Parent_Header_Id
		AND cc_type = 'C';
                IF P_Cc_Start_Date < l_start_date THEN
		    l_error_message := NULL;
		    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_SD_REL_LESS_SD_COV');
		    FND_MESSAGE.SET_TOKEN('START_DATE_REL', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
		    FND_MESSAGE.SET_TOKEN('START_DATE_COV', TO_CHAR(l_start_date, 'DD-MON-YYYY'), TRUE);
		    l_error_message := FND_MESSAGE.GET;
                    INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        NULL,
                        NULL,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
                END IF;
                IF P_Cc_End_Date > l_end_date THEN
		    l_error_message := NULL;
		    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ED_REL_GRET_ED_COV');
		    FND_MESSAGE.SET_TOKEN('END_DATE_REL', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
		    FND_MESSAGE.SET_TOKEN('END_DATE_COV', TO_CHAR(l_end_date, 'DD-MON-YYYY'), TRUE);
		    l_error_message := FND_MESSAGE.GET;
                    INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        NULL,
                        NULL,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
                END IF;
            EXCEPTION WHEN NO_DATA_FOUND THEN
		l_error_message := NULL;
		FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_NOT_VALID_COV');
	        FND_MESSAGE.SET_TOKEN('PARENT_HEADER_ID', TO_CHAR(P_Interface_Parent_Header_Id), TRUE);
		l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END;
        END IF;
      ELSE
        IF P_Interface_Parent_Header_Id IS NOT NULL THEN
       	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;

 -- Valid CC States are PR - Provisional, CM - Confirmed and CT- Completed
        IF UPPER(P_Cc_State) NOT IN ('PR', 'CM', 'CT') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_STATE');
	    FND_MESSAGE.SET_TOKEN('CC_STATE', P_Cc_State, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

 -- Validate CC Control Status
        IF UPPER(P_Cc_Ctrl_Status) NOT IN ('C', 'E', 'O') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CONTROL_STATUS');
	    FND_MESSAGE.SET_TOKEN('CTRL_STATUS', P_Cc_Ctrl_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

 -- Validate CC Encumbrace Status
        IF UPPER(P_Cc_Encmbrnc_Status) NOT IN ('C', 'N', 'P') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_ENCUM_STATUS');
	    FND_MESSAGE.SET_TOKEN('ENCUMBRANCE_STATUS', P_Cc_Encmbrnc_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

 -- Validate CC Approval Status
        IF UPPER(P_Cc_Apprvl_Status) NOT IN ('IN', 'AP') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_APPROVAL_STATUS');
	    FND_MESSAGE.SET_TOKEN('APPRVL_STATUS', P_Cc_Apprvl_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

 -- Validate Vendor Id
        IF UPPER(P_Cc_State) = 'CM' AND
           P_Vendor_Id IS NULL      AND
           UPPER(P_CC_Type) <> 'C' -- Added for 2119450
        THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NULL_VENDOR_ID');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         ELSIF P_Vendor_Id IS NOT NULL THEN
            BEGIN
                SELECT vendor_id INTO l_vendor_id
                FROM po_vendors
                WHERE vendor_id = P_Vendor_Id
                AND enabled_flag = 'Y'
                AND sysdate BETWEEN NVL(start_date_active, sysdate-1)
                                AND NVL(end_date_active, sysdate+1);
            EXCEPTION WHEN NO_DATA_FOUND THEN
	    	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VENDOR_ID');
	    	FND_MESSAGE.SET_TOKEN('VENDOR_ID', TO_CHAR(P_Vendor_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
         END IF;

-- Validate Vendor Site Id
        IF UPPER(P_Cc_State) = 'CM' AND
           UPPER(P_CC_Type) <> 'C'  AND -- Added for 2119450
           P_Vendor_Site_Id IS NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_NULL_VENDOR_SITE_ID');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         ELSIF P_Vendor_Site_Id IS NOT NULL THEN
            BEGIN
                SELECT vendor_site_id INTO l_vendor_site_id
                FROM po_vendor_sites_all
                WHERE vendor_site_id = P_Vendor_Site_Id
                AND vendor_id = P_Vendor_Id
                AND purchasing_site_flag = 'Y'
                AND NVL(inactive_date, sysdate+1) > sysdate;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	    	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VENDOR_SITE_ID');
	    	FND_MESSAGE.SET_TOKEN('VENDOR_SITE_ID', TO_CHAR(P_Vendor_Site_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
         END IF;

-- Validate Vendor Contact Id
        IF P_Vendor_Id IS NULL AND P_Vendor_Contact_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_VENDOR_CONTACT_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         ELSIF P_Vendor_Id IS NOT NULL AND P_Vendor_Contact_Id IS NOT NULL THEN
            BEGIN
                SELECT vendor_contact_id INTO l_vendor_contact_id
                FROM po_vendor_contacts
                WHERE vendor_site_id = P_Vendor_Site_Id
                AND vendor_contact_id = P_Vendor_Contact_Id
                AND NVL(inactive_date, sysdate+1) > sysdate;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	    	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_VEDR_CONTACT_ID');
	    	FND_MESSAGE.SET_TOKEN('VENDOR_CONTACT_ID', TO_CHAR(P_Vendor_Contact_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
         END IF;

-- Validate Term Id
        IF P_Term_Id IS NOT NULL THEN
            BEGIN
                SELECT term_id INTO l_term_id
                FROM ap_terms_val_v
                WHERE term_id = P_Term_Id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	    	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_TERM_ID');
	    	FND_MESSAGE.SET_TOKEN('TERM_ID', TO_CHAR(P_Term_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
         END IF;

-- Validate Location Id
        IF P_Vendor_Id IS NULL AND P_Location_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_LOCATION_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         ELSIF P_Vendor_Id IS NOT NULL AND P_Location_Id IS NOT NULL THEN
            BEGIN
                SELECT location_id INTO l_location_id
                FROM hr_locations
                WHERE location_id = P_location_Id
                AND bill_to_site_flag = 'Y'
                AND NVL(inactive_date, sysdate+1) > sysdate;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	    	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_LOCATION_ID');
	    	FND_MESSAGE.SET_TOKEN('LOCATION_ID', TO_CHAR(P_Location_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
         END IF;

-- Validate Set of Books Id
            IF P_Set_of_Books_Id <> P_Current_Set_of_Books_Id THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_SOB_NO_MATCH_USER_SOB');
	    FND_MESSAGE.SET_TOKEN('SOB_ID', TO_CHAR(P_Set_of_Books_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('CURRENT_SOB_ID', TO_CHAR(P_Current_Set_of_Books_Id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
              ( P_Interface_Header_Id,
                NULL,
                NULL,
                P_Org_Id,
                P_Set_of_Books_Id,
                l_error_message,
                P_X_Error_Status);
         END IF;

-- Validate Cc Acct Date
        IF P_Cc_Acct_Date IS NOT NULL THEN
            IF (P_Cc_Acct_Date < P_Cc_Start_Date) OR (P_Cc_Acct_Date > P_Cc_End_Date) THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCOUNT_DT_OUT_OF_RANGE');
	    	FND_MESSAGE.SET_TOKEN('ACCT_DT', TO_CHAR(P_Cc_Acct_Date, 'DD-MON-YYYY'), TRUE);
	    	FND_MESSAGE.SET_TOKEN('START_DATE', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
	    	FND_MESSAGE.SET_TOKEN('END_DATE', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        NULL,
                        NULL,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
            ELSE
                BEGIN
                    SELECT 1 INTO l_count
                    FROM igc_cc_periods ccp, gl_sets_of_books sob, gl_periods glp
                    WHERE sob.set_of_books_id = P_Set_of_Books_Id
                    AND sob.period_set_name = glp.period_set_name
                    AND sob.accounted_period_type = glp.period_type
                    AND glp.adjustment_period_flag = 'N'
                    AND ccp.period_set_name = glp.period_set_name
                    AND ccp.period_name = glp.period_name
                    AND ccp.org_id = P_Org_Id
                    AND P_Cc_Acct_Date BETWEEN glp.start_date AND glp.end_date
                    AND ccp.cc_period_status IN ('O','F');
                EXCEPTION WHEN NO_DATA_FOUND THEN
	      	    l_error_message := NULL;
	    	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACCT_DT_NOTIN_OPEN_PRD');
	    	    FND_MESSAGE.SET_TOKEN('ACCT_DT', TO_CHAR(P_Cc_Acct_Date, 'DD-MON-YYYY'), TRUE);
	    	    l_error_message := FND_MESSAGE.GET;
                    INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        NULL,
                        NULL,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
                    WHEN TOO_MANY_ROWS THEN NULL;
                END;
            END IF;
        END IF;

-- Validate Cc Owner User Id
            BEGIN
                -- Performance Tuning, Replaced the following query
                -- with the one below.
                -- SELECT fu.user_id INTO l_user_id
                -- FROM fnd_user fu, hr_employees he
                -- WHERE fu.user_id = P_Cc_Owner_User_Id
                -- AND sysdate BETWEEN NVL(fu.start_date, sysdate)
                --             AND NVL(fu.end_date, sysdate)
                -- AND fu.employee_id IS NOT NULL
                -- AND fu.employee_id = he.employee_id;

                SELECT fu.user_id
                INTO l_user_id
                FROM   fnd_user fu,
                       per_all_people_f p,
                       per_all_assignments_f a,
                       per_assignment_status_types past
                WHERE fu.user_id =  P_Cc_Owner_User_Id
                AND   sysdate BETWEEN NVL(fu.start_date, sysdate)
                AND   NVL(fu.end_date, sysdate)
                AND   fu.employee_id IS NOT NULL
                AND   fu.employee_id = p.person_id
/*                AND   p.business_group_id = (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp) */
		AND   p.business_group_id = (Decode (FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP') , 'Y' , p.business_group_id , (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp)))
                AND   p.employee_number is not null
                AND   trunc(sysdate) between p.effective_start_date and p.effective_end_date
                AND   a.person_id = p.person_id
                AND   a.primary_flag = 'Y'
                AND   trunc(sysdate) between a.effective_start_date
                AND   a.effective_end_date
                AND   a.assignment_status_type_id = past.assignment_status_type_id
                AND   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
                AND   a.assignment_type = 'E';

            EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_OWNER_UID_INVALID');
		FND_MESSAGE.SET_TOKEN('OWNER_UID', FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP'), TRUE);
/*		FND_MESSAGE.SET_TOKEN('OWNER_UID', TO_CHAR(P_Cc_Owner_User_Id), TRUE);*/
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;

-- Validate Cc Preparer User Id
            BEGIN
                -- SELECT fu.user_id INTO l_user_id
                -- FROM fnd_user fu, hr_employees he
                -- WHERE fu.user_id = P_Cc_Preparer_User_Id
                -- AND sysdate BETWEEN NVL(fu.start_date, sysdate)
                --             AND NVL(fu.end_date, sysdate)
                -- AND fu.employee_id IS NOT NULL
                -- AND fu.employee_id = he.employee_id;

                SELECT fu.user_id
                INTO l_user_id
                FROM   fnd_user fu,
                       per_all_people_f p,
                       per_all_assignments_f a,
                       per_assignment_status_types past
                WHERE fu.user_id =  P_Cc_Preparer_User_Id
                AND   sysdate BETWEEN NVL(fu.start_date, sysdate)
                AND   NVL(fu.end_date, sysdate)
                AND   fu.employee_id IS NOT NULL
                AND   fu.employee_id = p.person_id
/*                AND   p.business_group_id = (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp) */
		AND   p.business_group_id = (Decode (FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP') , 'Y' , p.business_group_id , (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp)))
                AND   p.employee_number is not null
                AND   trunc(sysdate) between p.effective_start_date and p.effective_end_date
                AND   a.person_id = p.person_id
                AND   a.primary_flag = 'Y'
                AND   trunc(sysdate) between a.effective_start_date
                AND   a.effective_end_date
                AND   a.assignment_status_type_id = past.assignment_status_type_id
                AND   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
                AND   a.assignment_type = 'E';

            EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PREPARER_UID_INVALID');
	    	FND_MESSAGE.SET_TOKEN('PREPARER_UID', TO_CHAR(P_Cc_Preparer_User_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;

-- Validate Currency Code and the conversion columns
        IF P_Currency_Code IS NULL THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CODE_REQD');
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
	 ELSE
	    BEGIN
		SELECT currency_code INTO l_currency_code
		FROM fnd_currencies_vl
		WHERE enabled_flag = 'Y'
		AND currency_flag = 'Y'
		AND currency_code = P_Currency_Code;

	        IF P_Currency_Code <> P_Func_Currency_Code AND
		  (P_Conversion_Type IS NULL OR P_Conversion_Rate IS NULL OR P_Conversion_Date IS NULL) THEN
	      	  l_error_message := NULL;
	    	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CONV_TYPE_RATE_DT_REQD');
	    	  l_error_message := FND_MESSAGE.GET;
                  INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
		END IF;
	 	IF l_curr_code <> P_Func_Currency_Code AND P_Cc_Type = 'R' AND
			(P_Currency_Code <> l_curr_code OR P_Conversion_Type <> l_conversion_type OR P_Conversion_Rate <> l_conversion_rate OR P_Conversion_Date <> l_conversion_date) THEN
	      	  l_error_message := NULL;
	    	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CD_CT_CR_CD_SAME');
	    	  l_error_message := FND_MESSAGE.GET;
                  INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
         	END IF;

	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CURR_CODE_INVALID');
	    	FND_MESSAGE.SET_TOKEN('CURR_CODE', P_Currency_Code, TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
		WHEN TOO_MANY_ROWS THEN NULL;
	    END;
         END IF;

-- Validate Created By
        IF P_Created_By IS NOT NULL THEN
            BEGIN
                SELECT user_id INTO l_user_id
                FROM fnd_user
                WHERE user_id = P_Created_By;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CREATED_BY');
	    	FND_MESSAGE.SET_TOKEN('CREATED_BY', TO_CHAR(P_Created_By), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
        END IF;

-- Validate Cc Current User Id
        IF P_Cc_Current_User_Id IS NOT NULL THEN
            BEGIN
                -- SELECT fu.user_id INTO l_user_id
                -- FROM fnd_user fu, hr_employees he
                -- WHERE fu.user_id = P_Cc_Current_User_Id
                -- AND sysdate BETWEEN NVL(fu.start_date, sysdate)
                --             AND NVL(fu.end_date, sysdate)
                -- AND fu.employee_id IS NOT NULL
                -- AND fu.employee_id = he.employee_id;

                SELECT fu.user_id
                INTO l_user_id
                FROM   fnd_user fu,
                       per_all_people_f p,
                       per_all_assignments_f a,
                       per_assignment_status_types past
                WHERE fu.user_id =  P_Cc_Current_User_Id
                AND   sysdate BETWEEN NVL(fu.start_date, sysdate)
                AND   NVL(fu.end_date, sysdate)
                AND   fu.employee_id IS NOT NULL
                AND   fu.employee_id = p.person_id
/*                AND   p.business_group_id = (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp) */
		AND   p.business_group_id = (Decode (FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP') , 'Y' , p.business_group_id , (select nvl(max(fsp.business_group_id),0) from financials_system_parameters fsp)))
                AND   p.employee_number is not null
                AND   trunc(sysdate) between p.effective_start_date and p.effective_end_date
                AND   a.person_id = p.person_id
                AND   a.primary_flag = 'Y'
                AND   trunc(sysdate) between a.effective_start_date
                AND   a.effective_end_date
                AND   a.assignment_status_type_id = past.assignment_status_type_id
                AND   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
                AND   a.assignment_type = 'E';

            EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_USER_ID');
	    	FND_MESSAGE.SET_TOKEN('CURR_UID', TO_CHAR(P_Cc_Current_User_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    NULL,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
        END IF;

      EXCEPTION WHEN OTHERS THEN RAISE;

      END;

/***************************************************************************/
-- Program which selects all the records from Acct Lines Interface table for
-- a particular Header record and calls other programs for processing
/***************************************************************************/
  PROCEDURE ACCT_LINE_INTERFACE_MAIN
     ( P_Interface_Header_Id IN NUMBER,
       P_Header_Id IN NUMBER,
       P_Int_Head_Parent_Header_Id IN NUMBER,
       P_Parent_Header_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Cc_Acct_Date IN DATE,
       P_User_Id IN NUMBER,
       P_Login_Id IN NUMBER,
       P_CC_State IN VARCHAR2,
       P_CC_Apprvl_Status IN VARCHAR2,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2)
    IS
     l_acct_line_id         NUMBER;
     l_parent_header_id     NUMBER;
     l_parent_acct_line_id  NUMBER;
     l_parent_det_pf_id     NUMBER;
     l_row_id               VARCHAR2(18);
     l_flag                 VARCHAR2(1);
     l_return_status        VARCHAR2(1);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(2000);
     l_msg_buf              VARCHAR2(2000);
     l_interface_acct_line_record igc_cc_acct_lines_interface%ROWTYPE;

     CURSOR c_interface_acct_line_records IS
            SELECT * FROM igc_cc_acct_lines_interface
            WHERE batch_id = g_batch_id
            AND interface_header_id = P_Interface_Header_Id;
     BEGIN
-- Process the acct line records one by one
        l_parent_header_id := P_Parent_Header_Id;

        OPEN c_interface_acct_line_records;
        LOOP
          FETCH c_interface_acct_line_records INTO l_interface_acct_line_record;
          EXIT WHEN c_interface_acct_line_records%NOTFOUND;

          ACCT_LINE_INTERFACE_VALIDATE
              ( l_interface_acct_line_record.Interface_Header_Id,
                P_Int_Head_Parent_Header_Id,
                l_interface_acct_line_record.Interface_Acct_Line_Id,
                P_Org_Id,
                P_Set_of_Books_Id,
                P_Cc_Type,
       		P_Cc_Encmbrnc_Status,
		P_Cc_Start_Date,
		P_Cc_End_Date,
                P_Cc_Acct_Date,
                l_interface_acct_line_record.Interface_Parent_Header_Id,
                l_interface_acct_line_record.Interface_Parent_Acct_Line_Id,
                l_interface_acct_line_record.Cc_Charge_Code_Combination_Id,
                l_interface_acct_line_record.Cc_Budget_Code_Combination_Id,
                l_interface_acct_line_record.CC_Acct_Entered_Amt,
                l_interface_acct_line_record.CC_Acct_Func_Amt,
                l_interface_acct_line_record.CC_Acct_Encmbrnc_Amt,
                l_interface_acct_line_record.CC_Acct_Encmbrnc_Date,
                l_interface_acct_line_record.CC_Acct_Encmbrnc_Status,
                l_interface_acct_line_record.Project_Id,
                l_interface_acct_line_record.Task_Id,
                l_interface_acct_line_record.Expenditure_Type,
                l_interface_acct_line_record.Expenditure_Org_Id,
                l_interface_acct_line_record.Expenditure_Item_Date,
                l_interface_acct_line_record.Created_By,
                l_interface_acct_line_record.cc_ent_withheld_amt,
                l_interface_acct_line_record.cc_func_withheld_amt,
                P_CC_State,
                P_CC_Apprvl_Status,
                P_X_Error_Status);

 -- If validation succeeds, get the derived values and insert acct line record.
          IF UPPER(g_process_phase) = 'F' AND UPPER(P_X_Error_Status) = 'N' THEN

            ACCT_LINE_INTERFACE_DERIVE( l_acct_line_id );

            IF P_Cc_Type = 'R' THEN
              GET_PARENT_ID( NULL,
                           l_interface_acct_line_record.Interface_Parent_Acct_Line_Id,
                           NULL,
                           l_parent_header_id,
                           l_parent_acct_line_id,
                           l_parent_det_pf_id );
	    ELSE
	      l_parent_header_id := NULL;
	      l_parent_acct_line_id := NULL;
	      l_parent_det_pf_id := NULL;
            END IF;

            IGC_CC_ACCT_LINES_PKG.Insert_Row(
                1.0,
                FND_API.G_TRUE,
                FND_API.G_FALSE,
                FND_API.G_VALID_LEVEL_FULL,
                l_return_status,
                l_msg_count,
                l_msg_data,
                l_row_id,
                l_acct_line_id,
                P_Header_Id,
                P_Parent_Header_Id,
                l_parent_acct_line_id,
                l_interface_acct_line_record.CC_Charge_Code_Combination_Id,
                l_interface_acct_line_record.CC_Acct_Line_Num,
                l_interface_acct_line_record.CC_Budget_Code_Combination_Id,
                l_interface_acct_line_record.CC_Acct_Entered_Amt,
                l_interface_acct_line_record.CC_Acct_Func_Amt,
                l_interface_acct_line_record.CC_Acct_Desc,
	        l_interface_acct_line_record.CC_Acct_Billed_Amt,
	        l_interface_acct_line_record.CC_Acct_Unbilled_Amt,
	        l_interface_acct_line_record.CC_Acct_Taxable_Flag,
		NULL,-- modified for Ebtax uptake for CC (Bug No-6472296)   l_interface_acct_line_record.Tax_Id
	        l_interface_acct_line_record.CC_Acct_Encmbrnc_Amt,
                l_interface_acct_line_record.CC_Acct_Encmbrnc_Date,
                l_interface_acct_line_record.CC_Acct_Encmbrnc_Status,
                l_interface_acct_line_record.Project_Id,
                l_interface_acct_line_record.Task_Id,
                l_interface_acct_line_record.Expenditure_Type,
                l_interface_acct_line_record.Expenditure_Org_Id,
                l_interface_acct_line_record.Expenditure_Item_Date,
	        sysdate,
                P_User_Id,
                P_Login_Id,
	        NVL(l_interface_acct_line_record.Creation_Date, sysdate),
                NVL(l_interface_acct_line_record.Created_By, P_User_Id),
                l_interface_acct_line_record.Attribute1,
                l_interface_acct_line_record.Attribute2,
                l_interface_acct_line_record.Attribute3,
                l_interface_acct_line_record.Attribute4,
                l_interface_acct_line_record.Attribute5,
                l_interface_acct_line_record.Attribute6,
                l_interface_acct_line_record.Attribute7,
                l_interface_acct_line_record.Attribute8,
                l_interface_acct_line_record.Attribute9,
                l_interface_acct_line_record.Attribute10,
                l_interface_acct_line_record.Attribute11,
                l_interface_acct_line_record.Attribute12,
                l_interface_acct_line_record.Attribute13,
                l_interface_acct_line_record.Attribute14,
                l_interface_acct_line_record.Attribute15,
                l_interface_acct_line_record.Context,
                Nvl(l_interface_acct_line_record.CC_Func_Withheld_Amt,0),
                Nvl(l_interface_acct_line_record.CC_Ent_Withheld_Amt,0),
                l_flag,
		l_interface_acct_line_record.tax_classif_code); -- modified for Ebtax uptake (Bug No-6472296)

            IF l_return_status IN ('E','U') THEN
		  l_msg_buf := ' ';
              	  FOR j IN 1..NVL(l_msg_count,0) LOOP
	            BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( l_interface_acct_line_record.Interface_Header_Id,
                	  l_interface_acct_line_record.Interface_Acct_Line_Id,
                	  NULL,
                          P_Org_Id,
                          P_Set_Of_Books_Id,
                          l_msg_buf,
                	  P_X_Error_Status);
		    END;
                  END LOOP;

            ELSE -- Insert was successfull.
                -- The insert into igc_cc_acct_lines has been sucessfull
                -- Call procedure to populate PLSQL table for PA
                -- The call should be made -
                -- If budgetary control is enabled in the commitment budget
                -- And ((CC is provisIonal,
                --       CC is already encumbered,
                --       Provisional CCs are being encumbered)
                -- Or  (CC is confirmed,
                --      CC is already encumbered,
                --      Confirmed CCs are being encumbered))
                -- And (CC acct line is attached to a project
                -- And project is budgetary controlled)
                -- And cc is of type Cover or Standard
                -- Bug 2871052
                IF g_cc_bc_enable_flag = 'Y'
                AND ((g_cc_state = 'PR'
                    AND l_interface_acct_line_record.CC_Acct_Encmbrnc_Status = 'P'
                     /* Bug No : 6341012. SLA uptake. cc_flags no more exists  AND g_cc_prov_encmbrnc_flag = 'Y' */    )
                OR  (g_cc_state = 'CM'
                    AND l_interface_acct_line_record.CC_Acct_Encmbrnc_Status = 'C'
                     /* Bug No : 6341012. SLA uptake. cc_flags no more exists  AND g_cc_conf_encmbrnc_flag = 'Y' */
		     ))
                AND p_cc_type IN ('C', 'S')
                AND (l_interface_acct_line_record.project_id IS NOT NULL
                    AND PA_BUDGET_FUND_PKG.Is_bdgt_intg_enabled
                           (p_project_id =>  l_interface_acct_line_record.project_id,
                            p_mode       => 'C' ))
                THEN
                    g_pa_cb_funds_check_required := TRUE;

                    -- Call procedure to populate the PA plsql table
                    populate_pa_table
                        (p_budget_type            => 'CBC',
                         p_cc_header_id           => p_header_id,
                         p_cc_acct_line_id        => l_acct_line_id,
                         p_cc_det_pf_line_id      => NULL,
                         p_cc_state               => g_cc_state,
                         p_project_id             => l_interface_acct_line_record.project_id,
                         p_task_id                => l_interface_acct_line_record.task_id,
                         p_expenditure_type       => l_interface_acct_line_record.expenditure_type,
                         p_expenditure_item_date  => l_interface_acct_line_record.expenditure_item_date,
                         p_expenditure_org_id     => l_interface_acct_line_record.expenditure_org_id,
                         p_transaction_date       => l_interface_acct_line_record.cc_acct_encmbrnc_date,
                         p_encumbered_amt         => l_interface_acct_line_record.cc_acct_encmbrnc_amt,
                         p_billed_amt             => l_interface_acct_line_record.cc_acct_billed_amt,
                         p_txn_ccid               => l_interface_acct_line_record.cc_budget_code_combination_id,
                         p_sob_id                 => p_set_of_books_id,
                         p_org_id                 => p_org_id);

                END IF; -- PA funds check required
            END IF; -- insert into igc_cc_acct_line successfull
          END IF; -- Process phase is final and no errors encountered.

-- Process the corresponding det pf line records for the acct line record.
          DET_PF_INTERFACE_MAIN
              ( l_interface_acct_line_record.Interface_Header_Id,
                l_interface_acct_line_record.Interface_Acct_Line_Id,
                l_acct_line_id,
                l_interface_acct_line_record.Interface_Parent_Acct_Line_Id,
                l_parent_acct_line_id,
                P_Org_Id,
                P_Set_of_Books_Id,
                P_Cc_Type,
		P_Cc_Encmbrnc_Status,
                P_Cc_Start_Date,
                P_Cc_End_Date,
                P_User_Id,
                P_Login_Id,
                p_header_id,
                l_interface_acct_line_record.project_id,
                l_interface_acct_line_record.task_id,
                l_interface_acct_line_record.expenditure_type,
                l_interface_acct_line_record.expenditure_item_date,
                l_interface_acct_line_record.expenditure_org_id,
                l_interface_acct_line_record.cc_budget_code_combination_id,
                P_X_Error_Status );
        END LOOP;
        CLOSE c_interface_acct_line_records;

      EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
        l_msg_data := TO_CHAR(SQLCODE)||': '||SQLERRM;
        -- bug 3199488, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
           FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
           FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_open_interface_pkg.acct_line_interface_main.Unexp1',TRUE);
        END IF;
        -- bug 3199488, end block
	P_X_Error_Status := 'U';

      END;

/***************************************************************************/
-- Validate the interface acct line record and return the result
/***************************************************************************/
 PROCEDURE ACCT_LINE_INTERFACE_VALIDATE
     ( P_Interface_Header_Id                    IN NUMBER,
       P_Int_Head_Parent_Header_Id              IN NUMBER,
       P_Interface_Acct_Line_Id                 IN NUMBER,
       P_Org_Id                                 IN NUMBER,
       P_Set_of_Books_Id                        IN NUMBER,
       P_Cc_Type                                IN VARCHAR2,
       P_Cc_Encmbrnc_Status                     IN VARCHAR2,
       P_Cc_Start_Date                          IN DATE,
       P_Cc_End_Date                            IN DATE,
       P_Cc_Acct_Date                           IN DATE,
       P_Interface_Parent_Header_Id             IN NUMBER,
       P_Interface_Parent_AcctLine_Id           IN NUMBER,
       P_Charge_Code_Combination_Id             IN NUMBER,
       P_Budget_Code_Combination_Id             IN NUMBER,
       P_Cc_Acct_Entered_Amt                    IN NUMBER,
       P_Cc_Acct_Func_Amt                       IN NUMBER,
       P_Cc_Acct_Encmbrnc_Amt                   IN NUMBER,
       P_Cc_Acct_Encmbrnc_Date                  IN DATE,
       P_Cc_Acct_Encmbrnc_Status                IN VARCHAR2,
       P_Project_Id                             IN NUMBER,
       P_Task_Id                                IN NUMBER,
       P_Expenditure_Type                       IN VARCHAR2,
       P_Expenditure_Org_Id                     IN NUMBER,
       P_Expenditure_Item_Date                  IN DATE,
       P_Created_By                             IN NUMBER,
       P_CC_Ent_Withheld_Amt                    IN NUMBER,
       P_CC_Func_Withheld_Amt                   IN NUMBER,
       P_CC_State                               IN VARCHAR2,
       P_CC_Apprvl_Status                       IN VARCHAR2,
       P_X_Error_Status                         IN OUT NOCOPY VARCHAR2)
    IS
       l_interface_parent_header_id       NUMBER;
       l_interface_parent_acctline_id     NUMBER;
       l_error_message                  igc_cc_interface_errors.error_message%TYPE;
       l_code_combination_id NUMBER;
       l_entered_amt NUMBER;
       l_func_amt NUMBER;
       l_project_id NUMBER;
       l_task_id NUMBER;
       l_expenditure_type VARCHAR2(30);
       l_expenditure_org_id NUMBER;
       l_charge_ccid	NUMBER;
       l_budget_ccid	NUMBER;
       l_cov_project_id	NUMBER;
       l_cov_task_id	NUMBER;
       l_cov_expenditure_type	VARCHAR2(30);
       l_cov_expenditure_org_id	NUMBER;
       l_cov_expenditure_item_date	DATE;
       l_user_id NUMBER;
    BEGIN

-- Validate Interface Parent Header Id. Should not be null and should be a valid
-- valid one for CC type 'R'
      IF P_Cc_Type = 'R' THEN
        IF P_Interface_Parent_Header_Id IS NULL THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_PARENT_HDR_ID_NULL');
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
            IF P_Int_Head_Parent_Header_Id IS NOT NULL AND
                    P_Int_Head_Parent_Header_Id <> P_Interface_Parent_Header_Id THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_PARENT_HDR_ID_INVLD');
	    	FND_MESSAGE.SET_TOKEN('INT_HDR_PARENT_ID', TO_CHAR(P_Interface_Parent_Header_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END IF;
        END IF;
      ELSE
        IF P_Interface_Parent_Header_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_HDR_ID_NUL_CC_REL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;

-- Validate Interface Parent Acct Line Id. Should not be null and should be a valid
-- one for CC type 'R'
      IF P_Cc_Type = 'R' THEN
        IF P_Interface_Parent_AcctLine_Id IS NULL THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_PRNT_ACNT_LINE_NULL');
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
            BEGIN
                SELECT interface_acct_line_id
                INTO l_interface_parent_acctline_id
                FROM igc_cc_acct_lines_interface
                WHERE interface_acct_line_id = P_Interface_Parent_AcctLine_Id
		AND interface_header_id = P_Interface_Parent_Header_Id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	      	l_error_message := NULL;
	    	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_PRNT_ACNT_LINE_INVL');
	    	FND_MESSAGE.SET_TOKEN('INT_PRNT_ACNT_LINE_ID', TO_CHAR(P_Interface_Parent_AcctLine_Id), TRUE);
	    	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END;
        END IF;
      ELSE
        IF P_Interface_Parent_AcctLine_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INT_LINE_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;


      -- Start, 1833267
      validate_acct_date(p_interface_header_id    => p_interface_header_id,
                         p_interface_parent_header_id   =>  p_interface_parent_header_id,
                         p_interface_acct_line_id => p_interface_acct_line_id,
                         p_org_id                 => p_org_id,
                         p_set_of_books_id        => p_set_of_books_id,
                         p_cc_type                => p_cc_type ,
                         p_cc_state               => g_cc_state,
                         p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
                         p_cc_apprvl_status       => g_cc_apprvl_status,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                      p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                      p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag,
                         p_sbc_enable_flag        => g_sbc_enable_flag,
                         p_cbc_enable_flag        => g_cc_bc_enable_flag,
                         p_cc_start_date          => p_cc_start_date ,
                         p_cc_end_date            => p_cc_end_date,
                         p_cc_acct_date           => p_cc_acct_date,
                         p_x_error_status         => p_x_error_status);

      validate_enc_acct_date (
                         p_interface_header_id    => p_interface_header_id,
                         p_interface_acct_line_id => p_interface_acct_line_id,
                         p_org_id                 => p_org_id,
                         p_set_of_books_id        => p_set_of_books_id,
                         p_cc_type                => p_cc_type ,
                         p_cc_state               => g_cc_state,
                         p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
                         p_cc_apprvl_status       => g_cc_apprvl_status,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_IDs and cc_flags are not required*/
--                      p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                      p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag,
                         p_sbc_enable_flag        => g_sbc_enable_flag,
                         p_cbc_enable_flag        => g_cc_bc_enable_flag,
                         p_cc_start_date          => p_cc_start_date ,
                         p_cc_end_date            => p_cc_end_date,
                         p_cc_acct_date           => p_cc_acct_date,
                         p_cc_encmbrnc_acct_date  => p_cc_acct_encmbrnc_date,
                         p_x_error_status         => p_x_error_status);
      -- End, 1833267

-- Validate the Charge Code Combination Id
      BEGIN
       IF P_Cc_Acct_Date IS NOT NULL THEN
        SELECT code_combination_id INTO l_code_combination_id
        FROM gl_code_combinations
        WHERE code_combination_id = P_Charge_Code_Combination_Id
        AND enabled_flag = 'Y'
        AND P_Cc_Acct_Date BETWEEN NVL(start_date_active, P_Cc_Acct_Date)
                               AND NVL(end_date_active, P_Cc_Acct_Date);
       ELSE
        SELECT code_combination_id INTO l_code_combination_id
        FROM gl_code_combinations
        WHERE code_combination_id = P_Charge_Code_Combination_Id
        AND enabled_flag = 'Y';
       END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CHARGE_CCID_NOT_VALID');
	    FND_MESSAGE.SET_TOKEN('CHARGE_CCID', TO_CHAR(P_Charge_Code_Combination_Id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
      END;

-- Validate the Budget Code Combination Id
      BEGIN
       IF P_Cc_Acct_Date IS NOT NULL THEN
        SELECT code_combination_id INTO l_code_combination_id
        FROM gl_code_combinations
        WHERE code_combination_id = P_Budget_Code_Combination_Id
        AND enabled_flag = 'Y'
        AND P_Cc_Acct_Date BETWEEN NVL(start_date_active, P_Cc_Acct_Date)
                               AND NVL(end_date_active, P_Cc_Acct_Date);
       ELSE
        SELECT code_combination_id INTO l_code_combination_id
        FROM gl_code_combinations
        WHERE code_combination_id = P_Budget_Code_Combination_Id
        AND enabled_flag = 'Y';
       END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_BUD_CCID_NOT_VALID');
	    FND_MESSAGE.SET_TOKEN('BUD_CCID', TO_CHAR(P_Budget_Code_Combination_Id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
      END;

      -- Validate that the withheld amount exists only for
      -- Standard CC's.
      -- 2043221, Bidisha , 24 Oct 2001
      IF  UPPER(P_CC_Type) <> 'S'
      AND Nvl(P_CC_Ent_Withheld_Amt,0) <> 0
      THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_OPI_INV_TYPE_FOR_WHAMT');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
      END IF;

      -- Validate that the withheld amount is positive
      -- 2043221, Bidisha , 24 Oct 2001
      IF Nvl(P_CC_Ent_Withheld_Amt,0) < 0
      THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_WHLD_AMT_NEGATIVE');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
      END IF;

      -- Validate that the withheld amount is set to 0 for status CT
      -- 2043221, Bidisha S , 25 Oct 2001
      IF  UPPER(P_CC_State) = 'CT'
      AND UPPER(P_CC_Apprvl_Status) = 'AP'
      AND Nvl(P_CC_Ent_Withheld_Amt,0) <> 0
      THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INV_WHLD_AMT_FOR_CT');
	    FND_MESSAGE.SET_TOKEN('WHLD_AMT', to_char(p_cc_ent_withheld_amt),TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
      END IF;
-- Validate Acct Entered Amt. Sum of Det_Pf_Entered_Amt + Withheld Amount should be
-- equal to Acct Entered Amt.
      BEGIN
        SELECT NVL(SUM(cc_det_pf_entered_amt), 0) INTO l_entered_amt
        FROM igc_cc_det_pf_interface
        WHERE interface_acct_line_id = P_Interface_Acct_Line_Id;

        -- Validation changed for 2043221, Bidisha S , 24 Oct 2001
        -- Ent Amount = SUM (PF Amount) + Withheld Amount
        IF NVL(P_Cc_Acct_Entered_Amt, 0) <> (NVL(l_entered_amt, 0)
                               + Nvl(P_CC_Func_Withheld_Amt,0))
        THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENT_AMT_DIFFERS');
	    FND_MESSAGE.SET_TOKEN('ACCT_ENT_AMOUNT', TO_CHAR(P_Cc_Acct_Entered_Amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('ENT_AMOUNT', TO_CHAR(l_entered_amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('WHLD_AMOUNT', TO_CHAR(P_CC_Ent_Withheld_Amt), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END;

-- If Cc Type is 'C' (Cover), then the Acct_Func_Amt of Cover should not
-- be less than the sum of Acct_Func_Amt of its Releases.
      BEGIN
      IF P_Cc_Type = 'C' THEN
        SELECT NVL(SUM(cc_acct_func_amt), 0) INTO l_func_amt
        FROM igc_cc_acct_lines_interface
        WHERE interface_parent_acct_line_id = P_Interface_Acct_Line_Id;
        IF NVL(P_Cc_Acct_Func_Amt, 0) < NVL(l_func_amt, 0) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_FUNC_AMT_COV_DIFFERS');
	    FND_MESSAGE.SET_TOKEN('FUNC_AMT', TO_CHAR(P_Cc_Acct_Func_Amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('FUNC_REL_AMT', TO_CHAR(l_func_amt), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;
      END;

-- Validate the Encumbrance Status
      IF NVL(P_Cc_Encmbrnc_Status, 'N') <> NVL(P_Cc_Acct_Encmbrnc_Status, 'N') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENCU_STATUS_DIFFERS');
	    FND_MESSAGE.SET_TOKEN('ACCT_ENCUM_STATUS', P_Cc_Acct_Encmbrnc_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('ENCUM_STATUS', P_Cc_Encmbrnc_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
      END IF;

-- Validate the Encumbrance colunmns
      IF NVL(P_Cc_Acct_Encmbrnc_Status,'N') IN ('C','P') THEN
	IF NVL(P_Cc_Acct_Func_Amt, 0) <> NVL(P_Cc_Acct_Encmbrnc_Amt, 0) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENC_AMT_EQUAL_FUNC_AMT');
	    FND_MESSAGE.SET_TOKEN('ENC_AMT', TO_CHAR(P_Cc_Acct_Encmbrnc_Amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('FUNC_AMT', TO_CHAR(P_Cc_Acct_Func_Amt), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;

	IF P_Cc_Acct_Encmbrnc_Date IS NOT NULL
        THEN

	    IF NVL(P_Cc_Start_Date, P_Cc_Acct_Encmbrnc_Date) > P_Cc_Acct_Encmbrnc_Date OR
	       NVL(P_Cc_End_Date, P_Cc_Acct_Encmbrnc_Date) < P_Cc_Acct_Encmbrnc_Date THEN
	       l_error_message := NULL;
	       FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ACNT_ENCUM_DT_NOT_LMT');
	       FND_MESSAGE.SET_TOKEN('ACNT_ENCUM_DT', TO_CHAR(P_Cc_Acct_Encmbrnc_Date, 'DD-MON-YYYY'), TRUE);
	       FND_MESSAGE.SET_TOKEN('START_DT', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
	       FND_MESSAGE.SET_TOKEN('END_DT', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
	       l_error_message := FND_MESSAGE.GET;
               INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
	    END IF;
        END IF;
      END IF;

-- Validate the Project related columns
      IF P_Project_Id IS NOT NULL OR P_Task_Id IS NOT NULL OR P_Expenditure_Type IS NOT NULL OR
         P_Expenditure_Org_Id IS NOT NULL OR P_Expenditure_Item_Date IS NOT NULL THEN

-- Validate the Project Id
        IF P_Project_Id IS NOT NULL THEN
          BEGIN
            -- Performance Tuning, replaced view pa_projects_v
            -- FROM pa_projects_expend_v
            SELECT project_id INTO l_project_id
            FROM pa_projects
            WHERE project_id = P_Project_Id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_PROJECT_ID');
	        FND_MESSAGE.SET_TOKEN('PROJECT_ID', TO_CHAR(P_Project_Id), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
          END;
	ELSE
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PROJECT_ID_REQD');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;

-- Validate the Task Id
        IF P_Task_Id is NULL THEN
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_TASK_ID_REQD');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSIF P_Project_Id IS NOT NULL AND P_Task_Id IS NOT NULL THEN
          BEGIN
            -- Performance Tuning, Replaced pa_tasks_expend_v
            -- FROM pa_tasks_expend_v
            SELECT task_id INTO l_task_id
            FROM pa_tasks
            WHERE task_id = P_Task_Id
            AND project_id = P_Project_Id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_TASK_ID');
	        FND_MESSAGE.SET_TOKEN('TASK_ID', TO_CHAR(P_Task_Id), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
          END;
        END IF;

-- Validate the Expenditure_Type
        IF P_Expenditure_Type is NULL THEN
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPENDITURE_TYPE_REQD');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSIF P_Project_Id IS NOT NULL AND P_Expenditure_Type IS NOT NULL THEN
          BEGIN
            -- Performance Tuning, Replaced he following query
            -- with the one below.
            -- SELECT expenditure_type INTO l_expenditure_type
            -- FROM pa_expenditure_types_expend_v
            -- WHERE expenditure_type IN ( select expenditure_type from pa_expenditure_types_expend_v et
				--	where system_linkage_function = 'VI'
				--	and et.project_id = P_Project_Id
				--	and et.expenditure_type = P_Expenditure_Type
				--	and (sysdate between expnd_typ_start_date_active and
				--			nvl(expnd_typ_end_date_active, sysdate))
				--	and (sysdate between sys_link_start_date_active and
				--			nvl(sys_link_end_date_active,sysdate))
				--	union
				--	select expenditure_type from pa_expenditure_types_expend_v et
				--	where system_linkage_function = 'VI'
				--	and et.project_id is null
				--	and et.expenditure_type = P_Expenditure_Type
				--	and (sysdate between expnd_typ_start_date_active and
				--			nvl(expnd_typ_end_date_active, sysdate))
				--	and (sysdate between sys_link_start_date_active and
				--			nvl(sys_link_end_date_active,sysdate))
				 --    );


               SELECT expenditure_type
               INTO   l_expenditure_type
               FROM   pa_expenditure_types_expend_v et
               WHERE  system_linkage_function = 'VI'
               AND    (sysdate between expnd_typ_start_date_active
                      AND nvl(expnd_typ_end_date_active, sysdate))
               AND    (sysdate between sys_link_start_date_active
                      AND nvl(sys_link_end_date_active,sysdate))
               AND    expenditure_type = p_expenditure_type;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXP_TYPE_INVALID');
	        FND_MESSAGE.SET_TOKEN('EXP_TYPE', P_Expenditure_Type, TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
          END;
        END IF;

-- Validate the Expenditure Org Id
        IF P_Expenditure_Org_Id is NULL THEN
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPENDITURE_ORG_ID_REQD');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
          BEGIN
            -- Performance Tuning, replaced the query
            -- with the one below
	    -- SELECT organization_id INTO l_expenditure_org_id
	    -- FROM pa_organizations_expend_v
	    -- WHERE active_flag = 'Y'
	    -- AND organization_id = P_Expenditure_Org_Id
	    -- AND sysdate between date_from and nvl(date_to, sysdate);

	    SELECT a.organization_id INTO l_expenditure_org_id
            FROM   hr_all_organization_units a,
                   pa_all_organizations b
            WHERE  a.organization_id = b.organization_id
	    AND    sysdate between a.date_from and nvl(a.date_to, sysdate)
            AND    b.pa_org_use_type = 'EXPENDITURES'
            AND    b.inactive_date IS NULL
            AND    b.organization_id = P_Expenditure_Org_Id;

            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXP_ORG_ID_INVALID');
	        FND_MESSAGE.SET_TOKEN('EXP_ORG_ID', TO_CHAR(P_Expenditure_Org_Id), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
          END;
        END IF;

-- Validate Expenditure Item Date
        IF P_Expenditure_Item_Date is NULL THEN
	  l_error_message := NULL;
	  FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPENDITURE_ITEM_DT_REQ');
	  l_error_message := FND_MESSAGE.GET;
          INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
	  IF NVL(P_Cc_Start_Date, P_Expenditure_Item_Date) > P_Expenditure_Item_Date OR
             NVL(P_Cc_End_Date, P_Expenditure_Item_Date) < P_Expenditure_Item_Date THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXP_ITEM_DT_NOT_IN_LMT');
	        FND_MESSAGE.SET_TOKEN('EXP_ITEM_DATE', TO_CHAR(P_Expenditure_Item_Date, 'DD-MON-YYYY'), TRUE);
	        FND_MESSAGE.SET_TOKEN('START_DATE', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
	        FND_MESSAGE.SET_TOKEN('END_DATE', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
	  END IF;
        END IF;

      END IF;

-- Validate Charge CCID, Budget CCID, Project ID, Task ID, Expenditure Type,
-- Expenditure Org ID and Expenditure Item Date of Release with Cover.
      BEGIN
      IF P_Cc_Type = 'R' THEN
        SELECT cc_charge_code_combination_id, cc_budget_code_combination_id,
	       project_id, task_id, expenditure_type,
	       expenditure_org_id, expenditure_item_date
 	INTO l_charge_ccid, l_budget_ccid, l_cov_project_id, l_cov_task_id,
	     l_cov_expenditure_type, l_cov_expenditure_org_id, l_cov_expenditure_item_date
        FROM igc_cc_acct_lines_interface
        WHERE interface_acct_line_id = P_Interface_Parent_AcctLine_Id;
        IF (P_Charge_Code_Combination_Id IS NULL AND l_charge_ccid IS NOT NULL) OR
	   (P_Charge_Code_Combination_Id IS NOT NULL AND l_charge_ccid IS NULL) OR
	   (P_Charge_Code_Combination_Id <> l_charge_ccid) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_CCCID_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_CHARGE_CCID', TO_CHAR(P_Charge_Code_Combination_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_CHARGE_CCID', TO_CHAR(l_charge_ccid), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Budget_Code_Combination_Id IS NULL AND l_budget_ccid IS NOT NULL) OR
	   (P_Budget_Code_Combination_Id IS NOT NULL AND l_budget_ccid IS NULL) OR
	   (P_Budget_Code_Combination_Id <> l_budget_ccid) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_BCCID_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_BUDGET_CCID', TO_CHAR(P_Budget_Code_Combination_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_BUDGET_CCID', TO_CHAR(l_budget_ccid), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Project_Id IS NULL AND l_cov_project_id IS NOT NULL) OR
	   (P_Project_Id IS NOT NULL AND l_cov_project_id IS NULL) OR
	   (P_Project_Id <> l_cov_project_id) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PROJECT_ID_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_PROJECT_ID', TO_CHAR(P_Project_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_PROJECT_ID', TO_CHAR(l_cov_project_id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Task_Id IS NULL AND l_cov_task_id IS NOT NULL) OR
	   (P_Task_Id IS NOT NULL AND l_cov_task_id IS NULL) OR
	   (P_Task_Id <> l_cov_task_id) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_TASK_ID_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_TASK_ID', TO_CHAR(P_Task_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_TASK_ID', TO_CHAR(l_cov_task_id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Expenditure_Type IS NULL AND l_cov_expenditure_type IS NOT NULL) OR
	   (P_Expenditure_Type IS NOT NULL AND l_cov_expenditure_type IS NULL) OR
	   (P_Expenditure_Type <> l_cov_expenditure_type) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPEND_TYPE_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_EXPEND_TYPE', P_Expenditure_Type, TRUE);
	    FND_MESSAGE.SET_TOKEN('C_EXPEND_TYPE', l_cov_expenditure_type, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Expenditure_Org_Id IS NULL AND l_cov_expenditure_org_id IS NOT NULL) OR
	   (P_Expenditure_Org_Id IS NOT NULL AND l_cov_expenditure_org_id IS NULL) OR
	   (P_Expenditure_Org_Id <> l_cov_expenditure_org_id) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPEND_ORG_ID_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_EXPEND_ORG_ID', TO_CHAR(P_Expenditure_Org_Id), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_EXPEND_ORG_ID', TO_CHAR(l_cov_expenditure_org_id), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
        IF (P_Expenditure_Item_Date IS NULL AND l_cov_expenditure_item_date IS NOT NULL) OR
	   (P_Expenditure_Item_Date IS NOT NULL AND l_cov_expenditure_item_date IS NULL) OR
	   (P_Expenditure_Item_Date <> l_cov_expenditure_item_date) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_EXPEND_ITEM_DT_MISMATCH');
	    FND_MESSAGE.SET_TOKEN('R_EXPEND_ITEM_DT', TO_CHAR(P_Expenditure_Item_Date, 'DD-MON-YYYY'), TRUE);
	    FND_MESSAGE.SET_TOKEN('C_EXPEND_ITEM_DT', TO_CHAR(l_cov_expenditure_item_date, 'DD-MON-YYYY'), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;

-- Validate Created By
        IF P_Created_By IS NOT NULL THEN
            BEGIN
                SELECT user_id INTO l_user_id
                FROM fnd_user
                WHERE user_id = P_Created_By;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CREATED_BY');
	        FND_MESSAGE.SET_TOKEN('CREATED_BY', TO_CHAR(P_Created_By), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    NULL,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
        END IF;

    END;
/***************************************************************************/
-- Program which selects all the records from Det Pf Interface table for
-- a particular acct line and calls other programs for processing
/***************************************************************************/
 PROCEDURE DET_PF_INTERFACE_MAIN
     ( P_Interface_Header_Id IN NUMBER,
       P_Interface_Acct_Line_Id IN NUMBER,
       P_Acct_Line_Id IN NUMBER,
       P_Int_Acct_Parent_AcctLine_Id IN NUMBER,
       P_Parent_Acct_Line_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_User_Id IN NUMBER,
       P_Login_Id IN NUMBER,
       P_header_id IN NUMBER,
       P_Project_Id IN NUMBER,
       p_task_id               IN NUMBER,
       p_expenditure_type      IN VARCHAR2,
       p_expenditure_item_date IN DATE,
       p_expenditure_org_id    IN NUMBER,
       p_cc_budget_ccid IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2)
     IS
        l_parent_header_id     NUMBER;
        l_parent_acct_line_id  NUMBER;
        l_parent_det_pf_id     NUMBER;
        l_det_pf_id            NUMBER;
        l_row_id               VARCHAR2(18);
        l_flag                 VARCHAR2(1);
        l_return_status        VARCHAR2(1);
        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(2000);
        l_msg_buf              VARCHAR2(2000);
        l_interface_det_pf_record igc_cc_det_pf_interface%ROWTYPE;

     CURSOR c_interface_det_pf_records IS
            SELECT * FROM igc_cc_det_pf_interface
            WHERE batch_id = g_batch_id
            AND interface_acct_line_id = P_Interface_Acct_Line_Id;
     BEGIN
-- Process the det pf line records one by one
        l_parent_acct_line_id := P_Parent_Acct_Line_Id;

        OPEN c_interface_det_pf_records;
        LOOP
          FETCH c_interface_det_pf_records INTO l_interface_det_pf_record;
          EXIT WHEN c_interface_det_pf_records%NOTFOUND;

          DET_PF_INTERFACE_VALIDATE
              ( P_Interface_Header_Id,
                l_interface_det_pf_record.Interface_Acct_Line_Id,
                P_Int_Acct_Parent_AcctLine_Id,
                l_interface_det_pf_record.Interface_Det_Pf_Line_Id,
                P_Org_Id,
                P_Set_of_Books_Id,
                P_Cc_Type,
		P_Cc_Encmbrnc_Status,
                P_Cc_Start_Date,
                P_Cc_End_Date,
                l_interface_det_pf_record.Interface_Parent_Acct_Line_Id,
                l_interface_det_pf_record.Interface_Par_Det_Pf_Line_Id,
                l_interface_det_pf_record.Cc_Det_Pf_Date,
                l_interface_det_pf_record.Cc_Det_Pf_Entered_Amt,
                l_interface_det_pf_record.Cc_Det_Pf_Func_Amt,
                l_interface_det_pf_record.Cc_Det_Pf_Encmbrnc_Amt,
                l_interface_det_pf_record.Cc_Det_Pf_Encmbrnc_Date,
                l_interface_det_pf_record.Cc_Det_Pf_Encmbrnc_Status,
                l_interface_det_pf_record.Created_By,
                P_X_Error_Status);

 -- If validation succeeds, get the derived values and insert det pf line record.
          IF UPPER(g_process_phase) = 'F' AND UPPER(P_X_Error_Status) = 'N' THEN

            DET_PF_INTERFACE_DERIVE( l_det_pf_id );

            IF P_Cc_Type = 'R' THEN
              GET_PARENT_ID( NULL,
                           NULL,
                           l_interface_det_pf_record.Interface_Par_Det_Pf_Line_Id,
                           l_parent_header_id,
                           l_parent_acct_line_id,
                           l_parent_det_pf_id );
            END IF;

            IGC_CC_DET_PF_PKG.Insert_Row(
                1.0,
                FND_API.G_TRUE,
                FND_API.G_FALSE,
                FND_API.G_VALID_LEVEL_FULL,
                l_return_status,
                l_msg_count,
                l_msg_data,
                l_row_id,
                l_det_pf_id,
                l_interface_det_pf_record.CC_Det_PF_Line_Num,
                P_Acct_Line_Id,
                l_parent_acct_line_id,
                l_parent_det_pf_id ,
                l_interface_det_pf_record.CC_Det_PF_Entered_Amt,
                l_interface_det_pf_record.CC_Det_PF_Func_Amt,
                l_interface_det_pf_record.CC_Det_PF_Date,
                l_interface_det_pf_record.CC_Det_PF_Billed_Amt,
                l_interface_det_pf_record.CC_Det_PF_Unbilled_Amt,
                l_interface_det_pf_record.CC_Det_PF_Encmbrnc_Amt,
                l_interface_det_pf_record.CC_Det_PF_Encmbrnc_Date,
                l_interface_det_pf_record.CC_Det_PF_Encmbrnc_Status,
	        sysdate,
                P_User_Id,
                P_Login_Id,
	        NVL(l_interface_det_pf_record.Creation_Date, sysdate),
                NVL(l_interface_det_pf_record.Created_By, P_User_Id),
                l_interface_det_pf_record.Attribute1,
                l_interface_det_pf_record.Attribute2,
                l_interface_det_pf_record.Attribute3,
                l_interface_det_pf_record.Attribute4,
                l_interface_det_pf_record.Attribute5,
                l_interface_det_pf_record.Attribute6,
                l_interface_det_pf_record.Attribute7,
                l_interface_det_pf_record.Attribute8,
                l_interface_det_pf_record.Attribute9,
                l_interface_det_pf_record.Attribute10,
                l_interface_det_pf_record.Attribute11,
                l_interface_det_pf_record.Attribute12,
                l_interface_det_pf_record.Attribute13,
                l_interface_det_pf_record.Attribute14,
                l_interface_det_pf_record.Attribute15,
                l_interface_det_pf_record.Context,
                l_flag);

            IF l_return_status IN ('E','U') THEN
		  l_msg_buf := ' ';
              	  FOR j IN 1..NVL(l_msg_count,0) LOOP
	            BEGIN
			l_msg_buf := FND_MSG_PUB.Get(p_msg_index => j,
		                                     p_encoded   => 'F');
            		INTERFACE_HANDLE_ERRORS
               	      	( P_Interface_Header_Id,
                	  l_interface_det_pf_record.Interface_Acct_Line_Id,
                	  l_interface_det_pf_record.Interface_Det_Pf_Line_Id,
                          P_Org_Id,
                          P_Set_Of_Books_Id,
                          l_msg_buf,
                	  P_X_Error_Status);
		    END;
                  END LOOP;
            ELSE -- Insert was successfull.
                -- The insert into igc_cc_acct_lines has been sucessfull
                -- Call procedure to populate PLSQL table for PA
                -- The call should be made -
                -- If budgetary control is enabled in the standard budget
                -- And ((CC is provisIonal,
                --       CC is already encumbered,
                --       Provisional CCs are being encumbered)
                -- Or  (CC is confirmed,
                --      CC is already encumbered,
                --      Confirmed CCs are being encumbered))
                -- And (CC acct line is attached to a project
                -- And project is budgetary controlled)
                -- And cc is of type Cover or Standard
                -- Bug 2871052
                IF g_sbc_enable_flag = 'Y'
                AND ((g_cc_state = 'PR' AND l_interface_det_pf_record.CC_Det_PF_Encmbrnc_Status = 'P')
                     /* Bug No : 6341012. SLA uptake. cc_flags no more exists  AND g_cc_prov_encmbrnc_flag = 'Y' */
                      OR  (g_cc_state = 'CM'  AND l_interface_det_pf_record.CC_Det_PF_Encmbrnc_Status = 'C'))
                     /* Bug No : 6341012. SLA uptake. cc_flags no more exists  AND g_cc_conf_encmbrnc_flag = 'Y' */
                AND p_cc_type IN ('C', 'S')
                AND (p_project_id IS NOT NULL
                    AND PA_BUDGET_FUND_PKG.Is_bdgt_intg_enabled
                           (p_project_id =>  p_project_id,
                            p_mode       => 'S' ))
                THEN
                    g_pa_sb_funds_check_required := TRUE;

                    -- Call procedure to populate PA tables for the standard budget
                    populate_pa_table
                        (p_budget_type            => 'GL',
                         p_cc_header_id           => p_header_id,
                         p_cc_acct_line_id        => NULL,
                         p_cc_det_pf_line_id      => l_det_pf_id,
                         p_cc_state               => g_cc_state,
                         p_project_id             => p_project_id,
                         p_task_id                => p_task_id,
                         p_expenditure_type       => p_expenditure_type,
                         p_expenditure_item_date  => p_expenditure_item_date,
                         p_expenditure_org_id     => p_expenditure_org_id,
                         p_transaction_date       => l_interface_det_pf_record.cc_det_pf_date,
                         p_encumbered_amt         => l_interface_det_pf_record.cc_det_pf_encmbrnc_amt,
                         p_billed_amt             => l_interface_det_pf_record.cc_det_pf_billed_amt,
                         p_txn_ccid               => p_cc_budget_ccid,
                         p_sob_id                 => p_set_of_books_id,
                         p_org_id                 => p_org_id);

                END IF; -- PA Funds check required
              END IF; -- Insert into igc_cc_det_pf was sucessfull.
          END IF; -- Phase is final and no validation errors were found
        END LOOP;
        CLOSE c_interface_det_pf_records;

     EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
        l_msg_data := TO_CHAR(SQLCODE)||': '||SQLERRM;
        -- bug 3199488, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
           FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
           FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_open_interface_pkg.det_pf_interface_main.Unexp1',TRUE);
        END IF;
        -- bug 3199488, end block
	P_X_Error_Status := 'U';
     END;


/***************************************************************************/
-- Validate the interface det pf record and return the result
/***************************************************************************/
  PROCEDURE DET_PF_INTERFACE_VALIDATE
     ( P_Interface_Header_Id IN NUMBER,
       P_Interface_Acct_Line_Id IN NUMBER,
       P_Int_Acct_Parent_AcctLine_Id IN NUMBER,
       P_Interface_Det_Pf_Id IN NUMBER,
       P_Org_Id IN NUMBER,
       P_Set_of_Books_Id IN NUMBER,
       P_Cc_Type IN VARCHAR2,
       P_Cc_Encmbrnc_Status IN VARCHAR2,
       P_Cc_Start_Date IN DATE,
       P_Cc_End_Date IN DATE,
       P_Interface_Parent_AcctLine_Id IN NUMBER,
       P_Interface_Parent_Det_Pf_Id IN NUMBER,
       P_Cc_Det_Pf_Date IN DATE,
       P_Cc_Det_Pf_Entered_Amt IN NUMBER,
       P_Cc_Det_Pf_Func_Amt IN NUMBER,
       P_Cc_Det_Pf_Encmbrnc_Amt IN NUMBER,
       P_Cc_Det_Pf_Encmbrnc_Date IN DATE,
       P_Cc_Det_Pf_Encmbrnc_Status IN VARCHAR2,
       P_Created_By IN NUMBER,
       P_X_Error_Status IN OUT NOCOPY VARCHAR2)
     IS
        l_interface_parent_det_pf_id NUMBER;
        l_error_message igc_cc_interface_errors.error_message%TYPE;
        l_count NUMBER;
	l_func_amt NUMBER;
        l_det_pf_date DATE;
        l_user_id NUMBER;
        l_gl_application_id    fnd_application.application_id%TYPE;

     BEGIN

-- --------------------------------------------------------------------
-- Obtain the application ID that will be used throughout this process.
-- --------------------------------------------------------------------
   SELECT application_id
     INTO l_gl_application_id
     FROM fnd_application
    WHERE application_short_name = 'SQLGL';

-- Validate Interface Parent Acct Line Id. Should not be null and should be a valid
-- valid one for CC type 'R'
      IF P_Cc_Type = 'R' THEN
        IF P_Interface_Parent_AcctLine_Id IS NULL THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PARENT_ACNT_ID_NULL');
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
            IF P_Int_Acct_Parent_AcctLine_Id IS NOT NULL AND
                	P_Int_Acct_Parent_AcctLine_Id <> P_Interface_Parent_AcctLine_Id THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PRENT_ACCT_LINE_ID_INV');
	        FND_MESSAGE.SET_TOKEN('INT_PAR_ACCT_LINE_INVALID', TO_CHAR(P_Interface_Parent_AcctLine_Id), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END IF;
        END IF;
      ELSE
        IF P_Interface_Parent_AcctLine_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PRENT_ACCT_LINE_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;

-- Validate Interface Parent Det Pf Line Id. Should not be null and should be a valid
-- valid one for CC type 'R'
      IF P_Cc_Type = 'R' THEN
        IF P_Interface_Parent_Det_Pf_Id IS NULL THEN
	     l_error_message := NULL;
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PRENT_DET_PF_ID_NULL');
	     l_error_message := FND_MESSAGE.GET;
             INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        ELSE
            BEGIN
                SELECT interface_det_pf_line_id
                INTO l_interface_parent_det_pf_id
                FROM igc_cc_det_pf_interface
                WHERE interface_det_pf_line_id = P_Interface_Parent_Det_Pf_Id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	        l_error_message := NULL;
	        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DET_PF_LINE_NOT_EXISTS');
	        FND_MESSAGE.SET_TOKEN('INT_PARENT_DET_PF_LINE_ID', TO_CHAR(P_Interface_Parent_Det_Pf_Id), TRUE);
	        l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
            END;
        END IF;
      ELSE
        IF P_Interface_Parent_Det_Pf_Id IS NOT NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DET_PF_LINE_ID_NULL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;

    -- Validate the Cc_Det_Pf_Date
    -- Start, 1833267
     validate_pf_date( p_interface_header_id   => p_interface_header_id,
                      p_org_id                 => p_org_id,
                      p_set_of_books_id        => p_set_of_books_id,
                      p_cc_type                => p_cc_type,
                      p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
/* Bug No : 6341012. SLA uptake. cc_flags no more exists */
--                   p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                   p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag ,
                      p_sbc_enable_flag        => g_sbc_enable_flag,
                      p_cbc_enable_flag        => g_cc_bc_enable_flag,
                      p_interface_acct_line_id => p_interface_acct_line_id,
                      p_interface_det_pf_id    => p_interface_det_pf_id ,
                      p_interface_parent_det_pf_id => p_interface_parent_det_pf_id,
                      p_cc_det_pf_date         => p_cc_det_pf_date,
                      p_cc_start_date          => p_cc_start_date,
                      p_cc_end_date            => p_cc_end_date,
                      p_x_error_status         => p_x_error_status);

    validate_enc_pf_date ( p_interface_header_id   => p_interface_header_id,
                      p_org_id                 => p_org_id,
                      p_set_of_books_id        => p_set_of_books_id,
                      p_cc_type                => p_cc_type,
                      p_cc_state               => g_cc_state,
                      p_cc_encmbrnc_status     => p_cc_encmbrnc_status,
                      p_cc_apprvl_status       => g_cc_apprvl_status,
/* Bug No : 6341012. SLA uptake. cc_flags no more exists */
--                   p_cc_prov_encmbrnc_flag  => g_cc_prov_encmbrnc_flag,
--                   p_cc_conf_encmbrnc_flag  => g_cc_conf_encmbrnc_flag ,
                      p_sb_prov_encmbrnc_flag  => g_sb_prov_encmbrnc_flag,
                      p_sb_conf_encmbrnc_flag  => g_sb_conf_encmbrnc_flag ,
                      p_sbc_enable_flag        => g_sbc_enable_flag,
                      p_cbc_enable_flag        => g_cc_bc_enable_flag,
                      p_interface_acct_line_id => p_interface_acct_line_id,
                      p_interface_det_pf_id    => p_interface_det_pf_id ,
                      p_interface_parent_det_pf_id => p_interface_parent_det_pf_id,
                      p_cc_det_pf_date         => p_cc_det_pf_date,
                      p_cc_det_pf_encmbrnc_date  => p_cc_det_pf_encmbrnc_date,
                      p_cc_start_date          => p_cc_start_date,
                      p_cc_end_date            => p_cc_end_date,
                      p_x_error_status         => p_x_error_status);
     -- End, 1833267


-- If Cc Type is 'C' (Cover), then the Det_Pf_Func_Amt of Cover should not
-- be less than the sum of Det_Pf_Func_Amt of its Releases.
      BEGIN
      IF P_Cc_Type = 'C' THEN
        SELECT NVL(SUM(cc_det_pf_func_amt), 0) INTO l_func_amt
        FROM igc_cc_det_pf_interface
        WHERE interface_par_det_pf_line_id = P_Interface_Det_Pf_Id;
        IF NVL(P_Cc_Det_Pf_Func_Amt, 0) < NVL(l_func_amt, 0) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_FUNC_AMT_COV_DIFFERS');
	    FND_MESSAGE.SET_TOKEN('FUNC_AMT', TO_CHAR(P_Cc_Det_Pf_Func_Amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('FUNC_REL_AMT', TO_CHAR(l_func_amt), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;
      END;

-- Validate the Encumbrance Status
      IF NVL(P_Cc_Encmbrnc_Status, 'N') <> NVL(P_Cc_Det_Pf_Encmbrnc_Status, 'N') THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENCUM_STATUS_DIFFERS');
	    FND_MESSAGE.SET_TOKEN('LINE_ENCUM_STATUS', P_Cc_Det_Pf_Encmbrnc_Status, TRUE);
	    FND_MESSAGE.SET_TOKEN('HDR_ENCUM_STATUS', P_Cc_Encmbrnc_Status, TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
      END IF;

-- Validate the Encumbrance colunmns
      IF NVL(P_Cc_Det_Pf_Encmbrnc_Status,'N') IN ('C','P') THEN
	IF NVL(P_Cc_Det_Pf_Func_Amt, 0) <> NVL(P_Cc_Det_Pf_Encmbrnc_Amt, 0) THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_ENC_AMT_EQUAL_FUNC_AMT');
	    FND_MESSAGE.SET_TOKEN('ENC_AMT', TO_CHAR(P_Cc_Det_Pf_Encmbrnc_Amt), TRUE);
	    FND_MESSAGE.SET_TOKEN('FUNC_AMT', TO_CHAR(P_Cc_Det_Pf_Func_Amt), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;

	IF P_Cc_Det_Pf_Encmbrnc_Date IS NULL THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DTL_PAY_FRCT_ENC_DT_NUL');
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
	ELSIF P_Cc_Det_Pf_Encmbrnc_Date <> P_Cc_Det_Pf_Date THEN
	    l_error_message := NULL;
	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_DT_PF_ENC_DT_DIFF_PFDT');
	    FND_MESSAGE.SET_TOKEN('PF_ENCUM_DT', TO_CHAR(P_Cc_Det_Pf_Encmbrnc_Date, 'DD-MON-YYYY'), TRUE);
	    FND_MESSAGE.SET_TOKEN('PF_DATE', TO_CHAR(P_Cc_Det_Pf_Date, 'DD-MON-YYYY'), TRUE);
	    l_error_message := FND_MESSAGE.GET;
            INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
        END IF;
      END IF;

-- Validate the Cc_Det_Pf_Encmbrnc_Date
      IF P_Cc_Det_Pf_Encmbrnc_Date IS NOT NULL THEN
        BEGIN
           SELECT 1 INTO l_count
           FROM igc_cc_periods ccp, gl_sets_of_books sob, gl_period_statuses glp
           WHERE sob.set_of_books_id = P_Set_of_Books_Id
           AND sob.set_of_books_id = glp.set_of_books_id
           AND sob.accounted_period_type = glp.period_type
           AND sob.period_set_name = ccp.period_set_name
           AND glp.adjustment_period_flag = 'N'
           AND glp.application_id = l_gl_application_id
           AND ccp.period_name = glp.period_name
           AND ccp.org_id = P_Org_Id
           AND P_Cc_Det_Pf_Encmbrnc_Date BETWEEN glp.start_date AND glp.end_date
           AND ccp.cc_period_status IN ('O','F')
           AND glp.closing_status IN ('O','F');
         EXCEPTION WHEN NO_DATA_FOUND THEN
	   l_error_message := NULL;
	   FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PAY_FRCT_ENCUM_DT_LMT');
	   FND_MESSAGE.SET_TOKEN('PF_ENCUM_DT', TO_CHAR(P_Cc_Det_Pf_Encmbrnc_Date, 'DD-MON-YYYY'), TRUE);
	   l_error_message := FND_MESSAGE.GET;
           INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        P_Interface_Acct_Line_Id,
                        P_Interface_Det_Pf_Id,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
            WHEN TOO_MANY_ROWS THEN NULL;
         END;

         IF P_Cc_Type = 'R' THEN
           IF P_Interface_Parent_Det_Pf_Id IS NOT NULL THEN
              BEGIN
                SELECT cc_det_pf_encmbrnc_date INTO l_det_pf_date
                FROM igc_cc_det_pf_interface
                WHERE interface_det_pf_line_id = P_Interface_Parent_Det_Pf_Id;
                IF l_det_pf_date <> P_Cc_Det_Pf_Encmbrnc_Date THEN
	   	    l_error_message := NULL;
	   	    FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PF_ENC_RELDT_MORE_COVDT');
	   	    FND_MESSAGE.SET_TOKEN('REL_DATE', TO_CHAR(P_Cc_Det_Pf_Encmbrnc_Date, 'DD-MON-YYYY'), TRUE);
	   	    FND_MESSAGE.SET_TOKEN('COV_DATE', TO_CHAR(l_det_pf_date, 'DD-MON-YYYY'), TRUE);
	   	    l_error_message := FND_MESSAGE.GET;
                    INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        P_Interface_Acct_Line_Id,
                        P_Interface_Det_Pf_Id,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
                END IF;
              EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
              END;
           END IF;
         ELSE
           IF P_Cc_Det_Pf_Encmbrnc_Date < P_Cc_Start_Date OR P_Cc_Det_Pf_Encmbrnc_Date > P_Cc_End_Date THEN
	   	l_error_message := NULL;
	   	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_PF_ENC_DT_NOTIN_SD_ED');
	   	FND_MESSAGE.SET_TOKEN('PF_ENCUM_DT', TO_CHAR(P_Cc_Det_Pf_Encmbrnc_Date, 'DD-MON-YYYY'), TRUE);
	   	FND_MESSAGE.SET_TOKEN('START_DT', TO_CHAR(P_Cc_Start_Date, 'DD-MON-YYYY'), TRUE);
	   	FND_MESSAGE.SET_TOKEN('END_DT', TO_CHAR(P_Cc_End_Date, 'DD-MON-YYYY'), TRUE);
	   	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                      ( P_Interface_Header_Id,
                        P_Interface_Acct_Line_Id,
                        P_Interface_Det_Pf_Id,
                        P_Org_Id,
                        P_Set_of_Books_Id,
                        l_error_message,
                        P_X_Error_Status);
           END IF;
         END IF;
       END IF;

-- Validate Created By
        IF P_Created_By IS NOT NULL THEN
            BEGIN
                SELECT user_id INTO l_user_id
                FROM fnd_user
                WHERE user_id = P_Created_By;
            EXCEPTION WHEN NO_DATA_FOUND THEN
	   	l_error_message := NULL;
	   	FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_INVALID_CREATED_BY');
	   	FND_MESSAGE.SET_TOKEN('CREATED_BY', TO_CHAR(P_Created_By), TRUE);
	   	l_error_message := FND_MESSAGE.GET;
                INTERFACE_HANDLE_ERRORS
                  ( P_Interface_Header_Id,
                    P_Interface_Acct_Line_Id,
                    P_Interface_Det_Pf_Id,
                    P_Org_Id,
                    P_Set_of_Books_Id,
                    l_error_message,
                    P_X_Error_Status);
                  WHEN TOO_MANY_ROWS THEN NULL;
            END;
        END IF;
     EXCEPTION WHEN OTHERS THEN RAISE;
     END;

/* Commented out as per bug 3199488
PROCEDURE Output_Debug (
   p_debug_msg      IN VARCHAR2
) IS

-- Constants :

   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(6)           := 'CC_OIP';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;

       RETURN;

END Output_Debug;
*/
END IGC_CC_OPEN_INTERFACE_PKG;

/
