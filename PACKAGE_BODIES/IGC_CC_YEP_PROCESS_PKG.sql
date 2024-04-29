--------------------------------------------------------
--  DDL for Package Body IGC_CC_YEP_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_YEP_PROCESS_PKG" as
/* $Header: IGCCYEPB.pls 120.16.12010000.3 2008/11/04 09:43:17 dramired ship $  */

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_YEP_PROCESS_PKG';
 g_debug_flag        VARCHAR2(1) := 'N' ;
--following variables added for bug 3199488: fnd logging changes: sdixit
   g_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level number	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level number	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path varchar2(500) :=      'igc.plsql.igccyepb.igc_cc_yep_process_pkg.';




/*==================================================================================
                              Procedure YEAR_END_UPDATE
  =================================================================================*/


 FUNCTION YEAR_END_UPDATE ( p_CC_HEADER_ID IN NUMBER,
                           p_YEAR          IN NUMBER,
			   p_SOB_ID        IN NUMBER,
                           p_REQUEST_ID    IN NUMBER,
                           p_yr_start_date IN DATE,
                           p_yr_end_date   IN DATE,
                           p_sbc_on        IN BOOLEAN,
                           p_cbc_on        IN BOOLEAN,
                           p_prov_enc_on   IN BOOLEAN,
                           p_conf_enc_on   IN BOOLEAN)
RETURN VARCHAR2  AS

CURSOR C14 IS
          SELECT  *
          FROM    IGC_CC_HEADERS
          WHERE   IGC_CC_HEADERS.CC_HEADER_ID = p_CC_HEADER_ID;

CURSOR C15(p_cc_header_id NUMBER, p_yr_start_date DATE, p_yr_end_date DATE) IS
          SELECT  *
          FROM    IGC_CC_ACCT_LINES A
          WHERE   A.CC_HEADER_ID = p_cc_header_id AND
                  EXISTS (SELECT 'X'
                          FROM IGC_CC_DET_PF B
                          WHERE B.CC_ACCT_LINE_ID = A.CC_ACCT_LINE_ID AND
                                ( B.CC_DET_PF_DATE >= p_yr_start_date AND B.CC_DET_PF_DATE <= p_yr_end_date) );

CURSOR C16(p_cc_acct_line_id NUMBER) IS
          SELECT  *
          FROM    IGC_CC_DET_PF B
          WHERE   B.CC_ACCT_LINE_ID = p_cc_acct_line_id;



l_HEADER_HISTORY_ROWID           VARCHAR2(18);
l_DET_PF_LINE_HISTORY_ROWID       VARCHAR2(18);
l_ACCT_HISTORY_ROWID              VARCHAR2(18);
l_ACTION_ROWID            VARCHAR2(18);
l_HEADERS_ROWID           VARCHAR2(18);
l_DET_PF_LINE_ROWID       VARCHAR2(18);
l_ACCT_ROWID              VARCHAR2(18);
l_CC_STATE                IGC_CC_HEADERS.CC_STATE%TYPE;
l_next_yr_start_date      DATE;
l_min_period_num          gl_periods.period_num%TYPE;
V14                       C14%ROWTYPE;
V15                       C15%ROWTYPE;
V16                       C16%ROWTYPE;
l_api_version             CONSTANT NUMBER  := 1.0;
l_init_msg_list           VARCHAR2(1)      := FND_API.G_FALSE;
l_commit                  VARCHAR2(1)      := FND_API.G_FALSE;
l_validation_level        NUMBER           := FND_API.G_VALID_LEVEL_FULL;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
G_FLAG                    VARCHAR2(1);
l_CC_VERSION_NUM          IGC_CC_HEADERS.CC_VERSION_NUM%TYPE;
l_application_id          fnd_application.application_id%TYPE;
l_APPROVAL_STATUS         IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE;
l_PROVISIONAL_COUNTER     NUMBER;
l_CC_ACCT_DATE            DATE;
l_cc_acct_encmbrnc_date   igc_cc_acct_lines.cc_acct_encmbrnc_date%TYPE;
l_cc_det_pf_encmbrnc_date igc_cc_det_pf.cc_det_pf_encmbrnc_date%TYPE;
l_Last_Updated_By         NUMBER := FND_GLOBAL.USER_ID;
l_Last_Update_Login       NUMBER := FND_GLOBAL.LOGIN_ID;
l_Created_By              NUMBER := FND_GLOBAL.USER_ID;
l_EXCEPTION               igc_cc_process_exceptions.exception_reason%TYPE := NULL;
l_action_hist_msg         igc_cc_actions.cc_action_notes%TYPE:= NULL;
l_CC_ENCMBRNC_STATUS      IGC_CC_HEADERS.CC_ENCMBRNC_STATUS%TYPE;

l_func_amt          NUMBER;
l_func_billed_amt   NUMBER;
l_unbilled_amt      NUMBER;
l_full_path                   VARCHAR2(500);

BEGIN

l_full_path := g_path||'Year_End_Update';--bug 3199488

    SAVEPOINT S1;

    SELECT application_id
    INTO   l_application_id
    FROM   fnd_application
    WHERE  application_short_name = 'SQLGL';


    SELECT CC_STATE,CC_ENCMBRNC_STATUS
    INTO   l_CC_STATE,l_CC_ENCMBRNC_STATUS
    FROM   IGC_CC_HEADERS A
    WHERE  A.CC_HEADER_ID = p_CC_HEADER_ID;


    SELECT  min(gp.period_num)
		INTO l_min_period_num
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id        = p_SOB_ID AND
       		gp.period_set_name        = gb.period_set_name AND
		gp.period_type            = gb.accounted_period_type AND
		gps.set_of_books_id       = gb.set_of_books_id AND
		gps.period_name           = gp.period_name AND
		gps.application_id        = l_application_id AND
		gp.period_year            = p_year+1 AND
		gp.adjustment_period_flag = 'N';


    SELECT      gps.start_date INTO
                l_next_yr_start_date
    FROM        gl_period_statuses gps,
                gl_periods gp,
                gl_sets_of_books gb
    WHERE       gb.set_of_books_id    = p_SOB_ID  AND
                gp.period_set_name    = gb.period_set_name AND
                gp.period_type        = gb.accounted_period_type AND
                gps.set_of_books_id   = gb.set_of_books_id AND
                gps.period_name       = gp.period_name AND
                gps.application_id    = l_application_id AND
                gp.period_year        = p_year+1 AND
                gp.period_num         = l_min_period_num;

      SELECT  OLD_APPROVAL_STATUS
      INTO    l_APPROVAL_STATUS
      FROM    IGC_CC_PROCESS_DATA
      WHERE   CC_HEADER_ID = p_CC_HEADER_ID
      AND     REQUEST_ID   = p_REQUEST_ID;


      OPEN C14;

      FETCH C14 INTO V14;

      SELECT ROWID INTO l_HEADERS_ROWID
      FROM   IGC_CC_HEADERS A
      WHERE  A.CC_HEADER_ID = V14.CC_HEADER_ID;

      l_CC_VERSION_NUM := V14.CC_VERSION_NUM;


      l_PROVISIONAL_COUNTER := 0;

      IF    l_CC_STATE = 'PR' OR (  l_CC_STATE = 'CL' AND l_CC_ENCMBRNC_STATUS = 'P')
      THEN
            l_PROVISIONAL_COUNTER := l_PROVISIONAL_COUNTER + 1;

      END IF; /* Provisional CC */


               l_return_status := FND_API.G_RET_STS_SUCCESS;

               IGC_CC_HEADER_HISTORY_PKG.Insert_Row(
                                             l_api_version,
                                             l_init_msg_list,
                                             l_commit,
                                             l_validation_level,
                                             l_return_status,
                                             l_msg_count,
                                             l_msg_data,
                                             l_HEADER_HISTORY_ROWID,
                                             V14.CC_HEADER_ID,
					     V14.ORG_ID,
                                             V14.CC_TYPE,
                                             V14.CC_NUM,
                                             l_CC_VERSION_NUM,
                                             'U',
                                             V14.CC_STATE,
                                             V14.PARENT_HEADER_ID,
                                             V14.CC_CTRL_STATUS,
                                             V14.CC_ENCMBRNC_STATUS,
                                             l_APPROVAL_STATUS,
                                             V14.VENDOR_ID,
                                             V14.VENDOR_SITE_ID,
                                             V14.VENDOR_CONTACT_ID,
                                             V14.TERM_ID,
                                             V14.LOCATION_ID,
                                             V14.SET_OF_BOOKS_ID,
                                             V14.CC_ACCT_DATE,
                                             V14.CC_DESC,
                                             V14.CC_START_DATE,
                                             V14.CC_END_DATE,
                                             V14.CC_OWNER_USER_ID,
                                             V14.CC_PREPARER_USER_ID,
                                             V14.CURRENCY_CODE,
                                             V14.CONVERSION_TYPE,
                                             V14.CONVERSION_DATE,
                                             V14.CONVERSION_RATE,
                                             V14.LAST_UPDATE_DATE,
                                             V14.LAST_UPDATED_BY,
                                             V14.LAST_UPDATE_LOGIN,
                                             V14.CREATED_BY,
                                             V14.CREATION_DATE,
                                             V14.WF_ITEM_TYPE,
                                             V14.WF_ITEM_KEY,
                                             V14.CC_CURRENT_USER_ID,
                                             V14.ATTRIBUTE1,
                                             V14.ATTRIBUTE2,
                                             V14.ATTRIBUTE3,
                                             V14.ATTRIBUTE4,
                                             V14.ATTRIBUTE5,
                                             V14.ATTRIBUTE6,
                                             V14.ATTRIBUTE7,
                                             V14.ATTRIBUTE8,
                                             V14.ATTRIBUTE9,
                                             V14.ATTRIBUTE10,
                                             V14.ATTRIBUTE11,
                                             V14.ATTRIBUTE12,
                                             V14.ATTRIBUTE13,
                                             V14.ATTRIBUTE14,
                                             V14.ATTRIBUTE15,
                                             V14.CONTEXT,
                                             V14.CC_GUARANTEE_FLAG,
                                             G_FLAG);

            	      IF   (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                      THEN
                              ROLLBACK TO S1;
                              l_EXCEPTION := NULL;
                              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADER_HST_INSERT');
                              IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                              END IF;
                              l_EXCEPTION := FND_MESSAGE.GET;
                              INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
								(PROCESS_TYPE,
								PROCESS_PHASE,
								CC_HEADER_ID,
								CC_ACCT_LINE_ID,
								CC_DET_PF_LINE_ID,
								EXCEPTION_REASON,
								ORG_ID,
								SET_OF_BOOKS_ID,
								REQUEST_ID)
								VALUES(
                                                                            'Y',
                                                                            'F',
                                                                            V14.CC_HEADER_ID,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
                                                                            V14.ORG_ID,
                                                                            p_SOB_ID,
                                                                            p_REQUEST_ID);

                              RETURN 'N';
                      END IF;



     OPEN C15(V14.cc_header_id, p_yr_start_date, p_yr_end_date);

     LOOP
	 FETCH C15 INTO V15;
	 EXIT WHEN C15%NOTFOUND;

		/* Update Account Line History*/

		l_return_status := FND_API.G_RET_STS_SUCCESS;

		IGC_CC_ACCT_LINE_HISTORY_PKG.Insert_Row(
                       l_api_version ,
                       l_init_msg_list,
                       l_commit,
                       l_validation_level,
                       l_return_status,
                       l_msg_count,
                       l_msg_data,
                       l_acct_history_rowid,
                       V15.CC_Acct_Line_Id,
                       V15.CC_Header_Id,
                       V15.Parent_Header_Id,
                       V15.Parent_Acct_Line_Id ,
                       V15.CC_Acct_Line_Num,
                       l_CC_VERSION_NUM,
                       'U',
                       V15.CC_Charge_Code_Combination_Id,
                       V15.CC_Budget_Code_Combination_Id,
                       V15.CC_Acct_Entered_Amt ,
                       V15.CC_Acct_Func_Amt,
                       V15.CC_Acct_Desc ,
                       V15.CC_Acct_Billed_Amt ,
                       V15.CC_Acct_Unbilled_Amt,
                       V15.CC_Acct_Taxable_Flag,
                       Null,-- tax_id Bug 6472296 EB Tax uptake
                       V15.CC_Acct_Encmbrnc_Amt,
                       V15.CC_Acct_Encmbrnc_Date,
                       V15.CC_Acct_Encmbrnc_Status,
                       V15.Project_Id,
                       V15.Task_Id,
                       V15.Expenditure_Type,
                       V15.Expenditure_Org_Id,
                       V15.Expenditure_Item_Date,
                       V15.Last_Update_Date,
                       V15.Last_Updated_By,
                       V15.Last_Update_Login ,
                       V15.Creation_Date ,
                       V15.Created_By ,
                       V15.Attribute1,
                       V15.Attribute2,
                       V15.Attribute3,
                       V15.Attribute4,
                       V15.Attribute5,
                       V15.Attribute6,
                       V15.Attribute7,
                       V15.Attribute8,
                       V15.Attribute9,
                       V15.Attribute10,
                       V15.Attribute11,
                       V15.Attribute12,
                       V15.Attribute13,
                       V15.Attribute14,
                       V15.Attribute15,
                       V15.Context,
                       V15.CC_FUNC_WITHHELD_AMT,
                       V15.CC_ENT_WITHHELD_AMT,
                       G_FLAG,
		       V15.tax_classif_code--Bug 6472296 EB Tax uptake
		       );

                 IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                 THEN
                          ROLLBACK TO S1;
                          l_EXCEPTION := NULL;
                          FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINE_HST_INSERT');
                          IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                          END IF;
                          l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                          'Y',
                                                          'F',
                                                           V14.CC_HEADER_ID,
                                                           V15.CC_ACCT_LINE_ID,
                                                           NULL,
                                                           l_EXCEPTION,
                                                           V14.ORG_ID,
                                                           p_SOB_ID,
                                                           p_REQUEST_ID);

                          RETURN 'N';
                 END IF;


                SELECT ROWID INTO l_ACCT_ROWID
                FROM   IGC_CC_ACCT_LINES B
                WHERE  B.CC_HEADER_ID    = V14.CC_HEADER_ID
                AND    B.CC_ACCT_LINE_ID = V15.CC_ACCT_LINE_ID;

       		IF ( ( l_cc_state = 'PR' OR l_cc_state = 'CL')
                      AND p_cbc_on = TRUE  AND p_prov_enc_on = TRUE
                    )
       		OR ( ( l_cc_state = 'CM' OR l_cc_state = 'CT')
                      AND p_cbc_on = TRUE  AND p_conf_enc_on = TRUE
                    )
                THEN

                       l_cc_acct_encmbrnc_date := l_next_yr_start_date;
		ELSE
                       l_cc_acct_encmbrnc_date := v15.cc_acct_encmbrnc_date;

		END IF;

                IGC_CC_ACCT_LINES_PKG.Update_Row(
                       l_api_version ,
                       l_init_msg_list,
                       l_commit,
                       l_validation_level,
                       l_return_status,
                       l_msg_count,
                       l_msg_data,
                       l_acct_rowid,
                       V15.CC_Acct_Line_Id,
                       V15.CC_Header_Id,
                       V15.Parent_Header_Id,
                       V15.Parent_Acct_Line_Id ,
                       V15.CC_Charge_Code_Combination_Id,
                       V15.CC_Acct_Line_Num,
                       V15.CC_Budget_Code_Combination_Id,
                       V15.CC_Acct_Entered_Amt ,
                       V15.CC_Acct_Func_Amt,
                       V15.CC_Acct_Desc ,
                       V15.CC_Acct_Billed_Amt ,
                       V15.CC_Acct_Unbilled_Amt,
                       V15.CC_Acct_Taxable_Flag,
                       Null,--tax_id Bug 6472296 EB Tax uptake
                       V15.CC_Acct_Encmbrnc_Amt,
                       l_cc_acct_encmbrnc_date,
                       V15.CC_Acct_Encmbrnc_Status,
                       V15.Project_Id,
                       V15.Task_Id,
                       V15.Expenditure_Type,
                       V15.Expenditure_Org_Id,
                       V15.Expenditure_Item_Date,
                       V15.Last_Update_Date,
                       V15.Last_Updated_By,
                       V15.Last_Update_Login ,
                       V15.Creation_Date ,
                       V15.Created_By ,
                       V15.Attribute1,
                       V15.Attribute2,
                       V15.Attribute3,
                       V15.Attribute4,
                       V15.Attribute5,
                       V15.Attribute6,
                       V15.Attribute7,
                       V15.Attribute8,
                       V15.Attribute9,
                       V15.Attribute10 ,
                       V15.Attribute11,
                       V15.Attribute12,
                       V15.Attribute13,
                       V15.Attribute14,
                       V15.Attribute15,
                       V15.Context,
                       V15.CC_FUNC_WITHHELD_AMT,
                       V15.CC_ENT_WITHHELD_AMT,
                       G_FLAG,
			V15.tax_classif_code -- Bug 6472296 EB Tax uptake
		       );


                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                        ROLLBACK TO S1;
                        l_EXCEPTION := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINES_UPDATE');
                        IF(g_excep_level >= g_debug_level) THEN
                              FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                        END IF;
                        l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                          'Y',
                                                          'F',
                                                           V14.CC_HEADER_ID,
                                                           V15.CC_ACCT_LINE_ID,
                                                           NULL,
                                                           l_EXCEPTION,
                                                           V14.ORG_ID,
                                                           p_SOB_ID,
                                                           p_REQUEST_ID);

                        RETURN 'N';
                END IF;


      	 OPEN C16(V15.CC_ACCT_LINE_ID);
         LOOP

            FETCH C16 INTO V16;

            EXIT WHEN C16%NOTFOUND;

            l_return_status := FND_API.G_RET_STS_SUCCESS;

            -- 2251118, Check that the line is not fully billed
            -- Bidisha S, 12 Mar 2002
            SELECT cc_det_pf_func_amt,
                   cc_det_pf_func_billed_amt
            INTO   l_func_amt,
                   l_func_billed_amt
            FROM   igc_cc_det_pf_v
            WHERE  cc_det_pf_line_id = V16.cc_det_pf_line_id;

            l_unbilled_amt       :=  l_func_amt - l_func_billed_amt;

            IF V16.CC_DET_PF_DATE  >= p_yr_start_date
               AND V16.CC_DET_PF_DATE <= p_yr_end_date
               AND l_unbilled_amt > 0
            THEN

              IGC_CC_DET_PF_HISTORY_PKG.Insert_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_DET_PF_LINE_HISTORY_ROWID,
                                        V16.CC_Det_PF_Line_Id,
                                        V16.CC_Det_PF_Line_Num,
                                        V16.CC_Acct_Line_Id,
                                        V16.Parent_Acct_Line_Id,
                                        V16.Parent_Det_PF_Line_Id,
                                        l_CC_VERSION_NUM,
                                        'U',
                                        V16.CC_Det_PF_Entered_Amt,
                                        V16.CC_Det_PF_Func_Amt,
                                        V16.CC_Det_PF_Date,
                                        V16.CC_Det_PF_Billed_Amt,
                                        V16.CC_Det_PF_Unbilled_Amt,
                                        V16.CC_Det_PF_Encmbrnc_Amt,
                                        V16.CC_Det_PF_Encmbrnc_Date,
                                        V16.CC_Det_PF_Encmbrnc_Status,
                                        V16.Last_Update_Date,
		                        V16.Last_Updated_By,
		                        V16.Last_Update_Login,
		                        V16.Creation_Date,
                                        V16.Created_By,
                                        V16.Attribute1,
		                        V16.Attribute2,
		                        V16.Attribute3,
		                        V16.Attribute4,
		                        V16.Attribute5,
		                        V16.Attribute6,
		                        V16.Attribute7,
		                        V16.Attribute8,
		                        V16.Attribute9,
		                        V16.Attribute10,
		                        V16.Attribute11,
		                        V16.Attribute12,
		                        V16.Attribute13,
		                        V16.Attribute14,
		                        V16.Attribute15,
                                        V16.Context,
                                        G_FLAG       );
                       IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                       THEN
                               ROLLBACK TO S1;
                               l_EXCEPTION := NULL;
                               FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_DET_PF_HST_INSERT');
                               IF(g_excep_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                               END IF;
                               l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                          'Y',
                                                          'F',
                                                           V14.CC_HEADER_ID,
                                                           V15.CC_ACCT_LINE_ID,
                                                           V16.CC_Det_PF_Line_Id,
                                                           l_EXCEPTION,
                                                           V14.ORG_ID,
                                                           p_SOB_ID,
                                                           p_REQUEST_ID);

                               RETURN 'N';
                       END IF;


                       SELECT ROWID INTO l_DET_PF_LINE_ROWID
                       FROM   IGC_CC_DET_PF D
                       WHERE  D.CC_DET_PF_LINE_ID = V16.CC_DET_PF_LINE_ID
                       AND    D.CC_ACCT_LINE_ID   = V15.CC_ACCT_LINE_ID;

			IF ( (l_cc_state = 'PR') OR (l_cc_state = 'CL') )
                              AND (p_sbc_on = TRUE) AND (p_prov_enc_on = TRUE)
			   OR
                           ( (l_cc_state = 'CM') OR (l_cc_state = 'CT') )
                              AND (p_sbc_on = TRUE) AND (p_conf_enc_on = TRUE)
                        THEN

                       		l_cc_det_pf_encmbrnc_date := l_next_yr_start_date;
			ELSE
                        	l_cc_det_pf_encmbrnc_date := v16.cc_det_pf_encmbrnc_date;

		        END IF;


                       IGC_CC_DET_PF_PKG.Update_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_DET_PF_LINE_ROWID,
                                        V16.CC_Det_PF_Line_Id,
                                        V16.CC_Det_PF_Line_Num,
                                        V16.CC_Acct_Line_Id,
                                        V16.Parent_Acct_Line_Id,
                                        V16.Parent_Det_PF_Line_Id,
                                        V16.CC_Det_PF_Entered_Amt,
                                        V16.CC_Det_PF_Func_Amt,
                                        l_next_yr_start_date,
                                        V16.CC_Det_PF_Billed_Amt,
                                        V16.CC_Det_PF_Unbilled_Amt,
                                        V16.CC_Det_PF_Encmbrnc_Amt,
                                        l_cc_det_pf_encmbrnc_date,
                                        V16.CC_Det_PF_Encmbrnc_Status,
                                        V16.Last_Update_Date,
                                        V16.Last_Updated_By,
                                        V16.Last_Update_Login,
                                        V16.Creation_Date,
                                        V16.Created_By,
                                        V16.Attribute1,
                                        V16.Attribute2,
                                        V16.Attribute3,
                                        V16.Attribute4,
                                        V16.Attribute5,
                                        V16.Attribute6,
                                        V16.Attribute7,
                                        V16.Attribute8,
                                        V16.Attribute9,
                                        V16.Attribute10,
                                        V16.Attribute11,
                                        V16.Attribute12,
                                        V16.Attribute13,
                                        V16.Attribute14,
                                        V16.Attribute15,
                                        V16.Context,
                                        G_FLAG       );


                    IF     (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
                           ROLLBACK TO S1;
                           l_EXCEPTION := NULL;
                           FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_DET_PF_UPDATE');
                           IF(g_excep_level >= g_debug_level) THEN
                           	FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                           END IF;
                           l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                          'Y',
                                                          'F',
                                                           V14.CC_HEADER_ID,
                                                           V15.CC_ACCT_LINE_ID,
                                                           V16.CC_Det_PF_Line_Id,
                                                           l_EXCEPTION,
                                                           V14.ORG_ID,
                                                           p_SOB_ID,
                                                           p_REQUEST_ID);

                           RETURN 'N';
                    END IF;

                END IF;
             END LOOP;
             CLOSE C16; /* PF lines */

       END LOOP;  /* Account lines */
       CLOSE C15;

       IF ( (l_cc_state = 'PR') OR (l_cc_state = 'CL') )
          AND (p_cbc_on = TRUE ) AND (p_prov_enc_on = TRUE)
       THEN

              IF     l_PROVISIONAL_COUNTER > 0
              THEN
                      l_CC_ACCT_DATE := l_next_yr_start_date;
              ELSE
                      l_CC_ACCT_DATE := V14.CC_ACCT_DATE;
              END IF;
       ELSE
       		l_CC_ACCT_DATE := V14.CC_ACCT_DATE;

       END IF;


      SELECT ROWID INTO l_HEADERS_ROWID
      FROM   IGC_CC_HEADERS A
      WHERE  A.CC_HEADER_ID = V14.CC_HEADER_ID;


      IGC_CC_HEADERS_PKG.Update_Row(
                         l_api_version,
                         l_init_msg_list,
                         l_commit,
                         l_validation_level,
                         l_return_status,
                         l_msg_count,
                         l_msg_data,
                         l_HEADERS_ROWID,
                         V14.CC_HEADER_ID,
                         V14.ORG_ID,
                         V14.CC_TYPE,
                         V14.CC_NUM,
                         l_CC_VERSION_NUM + 1 ,
                         V14.PARENT_HEADER_ID,
                         V14.CC_STATE,
                         V14.CC_CTRL_STATUS,
                         V14.CC_ENCMBRNC_STATUS,
                         l_APPROVAL_STATUS,
                         V14.VENDOR_ID,
                         V14.VENDOR_SITE_ID,
                         V14.VENDOR_CONTACT_ID,
                         V14.TERM_ID,
                         V14.LOCATION_ID,
                         V14.SET_OF_BOOKS_ID,
                         l_CC_ACCT_DATE,
                         V14.CC_DESC,
                         V14.CC_START_DATE,
                         V14.CC_END_DATE,
                         V14.CC_OWNER_USER_ID,
                         V14.CC_PREPARER_USER_ID,
                         V14.CURRENCY_CODE,
                         V14.CONVERSION_TYPE,
                         V14.CONVERSION_DATE,
                         V14.CONVERSION_RATE,
                         V14.LAST_UPDATE_DATE,
                         V14.LAST_UPDATED_BY,
                         V14.LAST_UPDATE_LOGIN,
                         V14.CREATED_BY,
                         V14.CREATION_DATE,
                         V14.CC_CURRENT_USER_ID,
                         V14.WF_ITEM_TYPE,
                         V14.WF_ITEM_KEY,
                         V14.ATTRIBUTE1,
                         V14.ATTRIBUTE2,
                         V14.ATTRIBUTE3,
                         V14.ATTRIBUTE4,
                         V14.ATTRIBUTE5,
                         V14.ATTRIBUTE6,
                         V14.ATTRIBUTE7,
                         V14.ATTRIBUTE8,
                         V14.ATTRIBUTE9,
                         V14.ATTRIBUTE10,
                         V14.ATTRIBUTE11,
                         V14.ATTRIBUTE12,
                         V14.ATTRIBUTE13,
                         V14.ATTRIBUTE14,
                         V14.ATTRIBUTE15,
                         V14.CONTEXT,
                         V14.CC_GUARANTEE_FLAG,
                         G_FLAG);

      IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
              ROLLBACK TO S1;
              l_EXCEPTION := NULL;
              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADERS_UPDATE');
              IF(g_excep_level >= g_debug_level) THEN
                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
              END IF;
              l_EXCEPTION := FND_MESSAGE.GET;


         	  INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
						(PROCESS_TYPE,
						PROCESS_PHASE,
						CC_HEADER_ID,
						CC_ACCT_LINE_ID,
						CC_DET_PF_LINE_ID,
						EXCEPTION_REASON,
						ORG_ID,
						SET_OF_BOOKS_ID,
						REQUEST_ID)
						VALUES(
                                                         'Y',
                                                         'F',
                                                          V14.CC_HEADER_ID,
                                                          NULL,
                                                          NULL,
                                                          l_EXCEPTION,
                                                          V14.ORG_ID,
                                                          p_SOB_ID,
                                                          p_REQUEST_ID);

              RETURN 'N';
      END IF;


     /* Insert into Action History */

      l_init_msg_list          := FND_API.G_FALSE;
      l_commit                 := FND_API.G_FALSE;
      l_validation_level       := FND_API.G_VALID_LEVEL_FULL;

      l_return_status          := '';

      /* added following code to remove hard coded message reference */
      /* change begin */

      l_action_hist_msg := NULL;

      /* change end */

      IGC_CC_ACTIONS_PKG.Insert_Row(
                                1.0,
                                l_init_msg_list,
                                l_commit,
                                l_validation_level,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_ACTION_ROWID,
                                V14.CC_HEADER_ID,
                                NVL(l_CC_VERSION_NUM,0) + 1,
                                'YP',
                                V14.CC_STATE,
                                V14.CC_CTRL_STATUS,
                                l_APPROVAL_STATUS,
                                l_action_hist_msg,
                                Sysdate,
                                l_Last_Updated_By,
                                l_Last_Update_Login,
                                Sysdate,
                                l_Created_By);

      IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
              ROLLBACK TO S1;
              l_EXCEPTION := NULL;
              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACTION_HST_INSERT');
              IF(g_excep_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
              END IF;
              l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                         'Y',
                                                         'F',
                                                          V14.CC_HEADER_ID,
                                                          NULL,
                                                          NULL,
                                                          l_EXCEPTION,
                                                          V14.ORG_ID,
                                                          p_SOB_ID,
                                                          p_REQUEST_ID);

              RETURN 'N';
      END IF;


       CLOSE C14;  /* Header */

       RETURN 'Y';

EXCEPTION
	WHEN OTHERS
        THEN
                ROLLBACK TO S1;
       		RETURN 'N';

END  YEAR_END_UPDATE;


/*==================================================================================
                             End of UPDATE_CC Procedure
  =================================================================================*/

/*==================================================================================
                             Procedure YEAR_END_MAIN
  =================================================================================*/


PROCEDURE YEAR_END_MAIN (  errbuf                OUT NOCOPY  VARCHAR2,
                           retcode               OUT NOCOPY  VARCHAR2,
/* Bug No : 6341012. MOAC uptake. SOB_ID, ORG_ID are no more retrieved from profile values in R12 */
	--                p_SOB_ID              IN   NUMBER,
	--                p_ORG_ID              IN   NUMBER,
                           p_PROCESS_PHASE       IN   VARCHAR2,
                           p_YEAR                IN   NUMBER)
AS

l_REQUEST_ID1                 NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
-- Bug No : 6341012. MOAC uptake. Local variables for SOB_ID,SOB_NAME,ORG_ID
l_sob_id		NUMBER;
l_sob_name	VARCHAR2(30);
l_org_id		NUMBER;

CURSOR C1(START_DATE DATE,
          END_DATE   DATE,
          c_SOB_ID     NUMBER,
          c_ORG_ID     NUMBER) IS
                      -- Performance tuning, replaced the following
                      -- query with the one below.
                      -- SELECT  *
                      -- FROM    IGC_CC_HEADERS
                      -- WHERE   CC_HEADER_ID IN
                      --               (
                      --                SELECT  IGC_CC_HEADERS.CC_HEADER_ID
                      --                FROM    IGC_CC_HEADERS, IGC_CC_ACCT_LINES, IGC_CC_DET_PF
                      --                WHERE   IGC_CC_DET_PF. CC_ACCT_LINE_ID = IGC_CC_ACCT_LINES. CC_ACCT_LINE_ID
                      --                AND     IGC_CC_ACCT_LINES.CC_HEADER_ID = IGC_CC_HEADERS.CC_HEADER_ID
                      --                AND     IGC_CC_HEADERS.SET_OF_BOOKS_ID = c_SOB_ID
                      --                AND     IGC_CC_HEADERS.ORG_ID          = c_ORG_ID
                      --                AND     CC_DET_PF_DATE   BETWEEN  START_DATE AND END_DATE  )
                      --
                      -- AND    (       (  CC_STATE = 'PR' )
                      --          OR    (  CC_STATE = 'CM' )
                      --          OR    (  CC_STATE = 'CT' AND CC_APPRVL_STATUS <> 'AP' )
                      --          OR    (  CC_STATE = 'CL' AND CC_APPRVL_STATUS <> 'AP' )   )

                      -- AND    ( CC_END_DATE > END_DATE OR CC_END_DATE IS NULL);


                      SELECT  *
                      FROM    IGC_CC_HEADERS A
                      WHERE   ((  A.CC_STATE = 'PR' )
                               OR    (  A.CC_STATE = 'CM' )
                               OR    (  A.CC_STATE = 'CT' AND A.CC_APPRVL_STATUS <> 'AP' )
                               OR    (  A.CC_STATE = 'CL' AND A.CC_APPRVL_STATUS <> 'AP' )   )
                      AND    ( A.CC_END_DATE > END_DATE OR A.CC_END_DATE IS NULL)
                      AND     A.SET_OF_BOOKS_ID = c_SOB_ID
                      AND     A.ORG_ID          = c_ORG_ID
                      AND     EXISTS
                                    (
                                     SELECT  'X'
                                     FROM    IGC_CC_ACCT_LINES B,
                                             IGC_CC_DET_PF C
                                     WHERE   B.CC_ACCT_LINE_ID = C.CC_ACCT_LINE_ID
                                     AND     B.CC_HEADER_ID = A.CC_HEADER_ID
                                     AND     C.CC_DET_PF_DATE   BETWEEN  START_DATE AND END_DATE  );


CURSOR C2 IS
       SELECT   *
       FROM     IGC_CC_PROCESS_DATA X
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
       WHERE    X.SET_OF_BOOKS_ID = l_sob_id
       AND      REQUEST_ID        = l_REQUEST_ID1
       AND      X.ORG_ID          = l_org_id
       AND      X.PROCESS_TYPE    = 'Y'
       AND      (X.PROCESSED     <> 'Y' OR X.PROCESSED IS NULL);

CURSOR C6 IS
          SELECT        B.PERIOD_NUM, B.PERIOD_NAME , A.CC_PERIOD_STATUS
          FROM          IGC_CC_PERIODS A,
                        GL_PERIODS_V B,
                        GL_SETS_OF_BOOKS C
          WHERE         B.PERIOD_YEAR             =    p_YEAR
          AND           A.PERIOD_SET_NAME         =    B.PERIOD_SET_NAME
          AND           B.PERIOD_SET_NAME         =    C.PERIOD_SET_NAME
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
	  AND           C.SET_OF_BOOKS_ID         =    l_sob_id
	  AND           B.PERIOD_TYPE             =    C.ACCOUNTED_PERIOD_TYPE
          AND           A.ORG_ID                  =    l_org_id
          AND           A.PERIOD_NAME             =    B.PERIOD_NAME
          AND           ADJUSTMENT_PERIOD_FLAG    =   'N';


CURSOR C7 IS
          SELECT        B.PERIOD_NUM, B.PERIOD_NAME , A.CC_PERIOD_STATUS
          FROM          IGC_CC_PERIODS A,
                        GL_PERIODS_V B,
                        GL_SETS_OF_BOOKS C
          WHERE         B.PERIOD_YEAR             =   p_YEAR+1
          AND           A.PERIOD_SET_NAME         =   B.PERIOD_SET_NAME
          AND           B.PERIOD_SET_NAME         =   C.PERIOD_SET_NAME
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
	  AND           C.SET_OF_BOOKS_ID         =   l_sob_id
	  AND           B.PERIOD_TYPE             =   C.ACCOUNTED_PERIOD_TYPE
          AND           A.ORG_ID                  =   l_org_id
          AND           A.PERIOD_NAME             =   B.PERIOD_NAME
          AND           ADJUSTMENT_PERIOD_FLAG    =   'N';

-- Added parameters p_year and p_period_num for Bug 3464401
-- This makes cursor C9 redundant.
CURSOR C8 (p_year         NUMBER,
           p_period_num   NUMBER) IS
          SELECT      PERIOD_NAME, PERIOD_NUM, CLOSING_STATUS
          FROM        GL_PERIOD_STATUSES
          WHERE       APPLICATION_ID         = (SELECT APPLICATION_ID
                                                FROM  FND_APPLICATION
                                                WHERE  APPLICATION_SHORT_NAME = 'SQLGL')
-- Bug No : 6341012. MOAC Uptake. p_sob_id is  changed to l_sob_id
          AND         SET_OF_BOOKS_ID        =  l_sob_id
          AND         ADJUSTMENT_PERIOD_FLAG = 'N'
          AND         PERIOD_YEAR            =  p_year
          AND         PERIOD_NUM             =  p_period_num;

--        AND         PERIOD_YEAR            =  p_YEAR+1
--        AND         PERIOD_NUM             =  1;

/*
CURSOR C9 IS
          SELECT      PERIOD_NAME, PERIOD_NUM, CLOSING_STATUS
          FROM        GL_PERIOD_STATUSES
          WHERE       APPLICATION_ID         =  (SELECT APPLICATION_ID
                                                 FROM  FND_APPLICATION
                                                 WHERE  APPLICATION_SHORT_NAME = 'SQLGL')

          AND         PERIOD_YEAR            =  p_YEAR
-- Bug No : 6341012. MOAC Uptake. p_sob_id is  changed to l_sob_id
          AND         SET_OF_BOOKS_ID        =  l_sob_id
          AND         ADJUSTMENT_PERIOD_FLAG = 'N'
          AND         PERIOD_NUM             =  12;

*/

CURSOR C11(H_ID NUMBER) IS
           SELECT *
           FROM   IGC_CC_HEADERS
           WHERE  CC_HEADER_ID IN (SELECT IGC_CC_HEADERS.CC_HEADER_ID
                                   FROM   IGC_CC_HEADERS,IGC_CC_PROCESS_DATA
                                   WHERE  IGC_CC_HEADERS.PARENT_HEADER_ID           = H_ID
                                   AND    IGC_CC_HEADERS.CC_HEADER_ID               = IGC_CC_PROCESS_DATA.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                   AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID       = l_sob_id
                                   AND    IGC_CC_PROCESS_DATA.REQUEST_ID            = l_REQUEST_ID1
                                   AND    IGC_CC_PROCESS_DATA.ORG_ID                = l_org_id);


V1                              C1%ROWTYPE;
V2                              C2%ROWTYPE;
V6                              C6%ROWTYPE;
V7                              C7%ROWTYPE;
V8                              C8%ROWTYPE;
--V9                              C9%ROWTYPE;
V11                             C11%ROWTYPE;
l_PERIOD_COUNTER                NUMBER := 0;
l_STATUS_COUNTER                NUMBER :=0;
l_LOCK_CC_STATUS                BOOLEAN;
l_LOCK_PO_STATUS                BOOLEAN;
l_budg_status                   BOOLEAN;
l_PROCESS_TYPE                  IGC_CC_PROCESS_DATA.PROCESS_TYPE%TYPE;
l_RESULT_OF_VALIDATION          IGC_CC_PROCESS_DATA.VALIDATION_STATUS%TYPE;
l_RESULT_OF_RESERVATION         IGC_CC_PROCESS_DATA.RESERVATION_STATUS%TYPE;
l_RESULT_OF_YEAR_END_UPDATE     IGC_CC_PROCESS_DATA.PROCESSED%TYPE;
l_VALIDATION_COUNTER            NUMBER;
l_PROCESSED_COUNTER             NUMBER;
l_CC_APPROVAL_STATUS            IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE;
l_CC_TYPE                       IGC_CC_HEADERS.CC_TYPE%TYPE;
l_CONTRACT_COUNTER              NUMBER := 0;
l_CC_CTRL_STATUS                IGC_CC_HEADERS.CC_CTRL_STATUS%TYPE;
l_APPROVED_FLAG                 PO_HEADERS_ALL.APPROVED_FLAG%TYPE;
l_HEADER_ID                     IGC_CC_HEADERS.CC_HEADER_ID%TYPE;
RELEASE_YEAR_END_COUNTER        NUMBER;
l_api_version                   CONSTANT NUMBER  := 1.0;
l_init_msg_list                 VARCHAR2(1)      := FND_API.G_FALSE;
l_commit                        VARCHAR2(1)      := FND_API.G_FALSE;
l_validation_level              NUMBER           := FND_API.G_VALID_LEVEL_FULL;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(12000);
l_usr_msg                       igc_cc_process_exceptions.exception_reason%TYPE;
l_EXCEPTION                     igc_cc_process_exceptions.exception_reason%TYPE := NULL;
l_error_text                    VARCHAR2(12000);
l_CC_NUM                        IGC_CC_HEADERS.CC_NUM%TYPE;
l_invalid_counter               NUMBER;

/********************** ENCUMBRANCE DECLARATION *******************/

l_application_id              fnd_application.application_id%TYPE;
l_yr_start_date               DATE;
l_yr_start_date_next          DATE;
l_yr_end_date                 DATE;
l_yr_end_cr_date              DATE;
l_yr_end_dr_date              DATE;
l_min_period_num              gl_periods.period_num%TYPE;
l_max_period_num              gl_periods.period_num%TYPE;

l_currency_code               gl_sets_of_books.currency_code%TYPE;
l_sbc_on                      BOOLEAN;
l_cbc_on                      BOOLEAN;
l_prov_enc_on                 BOOLEAN;
l_conf_enc_on                 BOOLEAN;

/* Bug No : 6341012. SLA uptake. Encumbrance Type IDs are not required */
--	l_req_encumbrance_type_id     NUMBER;
--	l_purch_encumbrance_type_id   NUMBER;
--	l_cc_prov_enc_type_id         NUMBER;
--	l_cc_conf_enc_type_id         NUMBER;

l_COUNTER                     NUMBER := 0;
l_REQUEST_ID                  NUMBER;
l_Type                        IGC_CC_HEADERS.CC_TYPE%TYPE;
l_STATE                       IGC_CC_HEADERS.CC_STATE%TYPE;
l_PREVIOUS_APPRVL_STATUS      IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE;
l_DUMMY                       VARCHAR2(1);


/******************** END OF ENCUMBRANCE DECLARATION ********************/

l_option_name                 VARCHAR2(80);
lv_message                    VARCHAR2(800);
l_full_path                   VARCHAR2(500);
   -- Varibles used for xml report
l_terr                     VARCHAR2(10):='US';
l_lang                     VARCHAR2(10):='en';
l_layout                   BOOLEAN;

   BEGIN

l_full_path := g_path||'Year_End_Main';--bug 3199488

   -- 01/03/02, check to see if CBC is installed
   -- code will remain commented out for now

   IF NOT igi_gen.is_req_installed('CC') THEN

      SELECT meaning
      INTO l_option_name
      FROM igi_lookups
      WHERE lookup_code = 'CC'
      AND lookup_type = 'GCC_DESCRIPTION';

      FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
      IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
      END IF;
      lv_message := fnd_message.get;
      errbuf := lv_message;
      retcode := 2;
      return;
   END IF;

    retcode := 0;

   -- Bug 1914745, clear any old records from the igc_cc_interface table
   -- DELETE FROM igc_cc_interface
   -- WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date((sysdate - interval '2' day), 'DD/MM/YYYY');

   -- Bug 2872060. Above Delete command commented out, was causing compilation probs in Oracle8i.
   DELETE FROM igc_cc_interface
   WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date(sysdate ,'DD/MM/YYYY') - 2;

    /* Begin fix for bug 1576023 */
    l_msg_data  := NULL;
    l_msg_count := 0;
    l_usr_msg   := NULL;

/* Bug No : 6341012. MOAC Uptake. SOB_ID,ORG_ID values are retrieved */
	l_org_id := MO_GLOBAL.get_current_org_id;
	MO_UTILS.get_ledger_info(l_org_id,l_sob_id,l_sob_name);

    l_budg_status := IGC_CC_REP_YEP_PVT.get_budg_ctrl_params(
/* Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                            l_sob_id,
                                            l_org_id,
                                            l_currency_code,
                                            l_sbc_on,
                                            l_cbc_on,
                                            l_prov_enc_on,
                                            l_conf_enc_on,
/*Bug No : 6341012. R12 SLA Uptake. Encumbrance Type IDs are not required */
--                                            l_req_encumbrance_type_id,
--                                            l_purch_encumbrance_type_id,
--                                            l_cc_prov_enc_type_id,
--                                            l_cc_conf_enc_type_id,
                                            l_msg_data,
                                            l_msg_count,
                                            l_usr_msg
                                             ) ;


	IF (l_budg_status = FALSE) AND (l_usr_msg IS NOT NULL)
        THEN
		INSERT INTO
		igc_cc_process_exceptions
		(process_type,
	 	process_phase,
	 	cc_header_id,
	 	cc_acct_line_id,
	 	cc_det_pf_line_id,
	 	exception_reason,
	 	org_id,
	 	set_of_books_id,
                request_id)
		VALUES
                ( 'Y',
	 	p_process_phase,
		NULL,
		NULL,
		NULL,
		l_usr_msg,
/* Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		l_org_id,
		l_sob_id,
                l_request_id1);

		COMMIT;

		/* Concurrent Program Request Id for generating Report */

/*Bug No : 6341012. MOAC Uptake. Need to set ORG_ID before submitting request */
	        Fnd_request.set_org_id(l_org_id);
                l_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                                                         'IGC',
                                                         'IGCCYRPR',
                                                          NULL,
                                                          NULL,
                                                          FALSE,
/* Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                          l_sob_id,
                                                          l_org_id,
                                                          p_PROCESS_PHASE,
                                                          'Y',
                                                          l_REQUEST_ID1);
-----------------------
-- Start of XML Report
-----------------------
          IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCYRPR_XML',
                                            'IGC',
                                            'IGCCYRPR_XML' );

                 l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCYRPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

                 IF l_layout then
                     Fnd_request.set_org_id(l_org_id);
                    l_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                                                         'IGC',
                                                         'IGCCYRPR_XML',
                                                          NULL,
                                                          NULL,
                                                          FALSE,
                                                          l_sob_id,
                                                          l_org_id,
                                                          p_PROCESS_PHASE,
                                                          'Y',
                                                          l_REQUEST_ID1);
                 END IF;
            END IF;

--------------------
-- End of XML Report
--------------------

          /* End of Concurrent Program Request Id for generating Report */
	END IF;

	-- ------------------------------------------------------------------------------------
	-- Ensure that any exceptions raised are output into the log file to be reported to
	-- the user if any are present.
	-- ------------------------------------------------------------------------------------

	IF (l_budg_status = FALSE)
	THEN
   		FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
       	       		             	    p_data  => l_msg_data );

   		IF (l_msg_count > 0)
		THEN
      			l_error_text := '';
      			FOR l_cur IN 1..l_msg_count
			LOOP
          			l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);

                                IF (g_excep_level >= g_debug_level) then
				fnd_log.string(g_excep_level,l_full_path,l_error_text);
                                END IF;

          			fnd_file.put_line (FND_FILE.LOG,
               	        		           l_error_text);
      			END LOOP;
   		END IF;
	END IF;

	IF (l_usr_msg IS NULL) AND (l_budg_status = FALSE)
	THEN
		RETCODE := 2;
	END IF;

	IF (l_budg_status = FALSE)
	THEN
		RETURN;
	END IF;


    /* End fix for bug 1576023 */

     /******************** ENCUMBRANCE CODE *******************/

        SELECT application_id
        INTO   l_application_id
	FROM   fnd_application
	WHERE  application_short_name = 'SQLGL';


	l_min_period_num := NULL;

	l_max_period_num := NULL;

        l_COUNTER := 0;

        SELECT  min(gp.period_num)
		INTO l_min_period_num
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id        = l_sob_id AND /*p_sob_id => l_sob_id by Bug 6341012 */
       		gp.period_set_name        = gb.period_set_name AND
		gp.period_type            = gb.accounted_period_type AND
		gps.set_of_books_id       = gb.set_of_books_id AND
		gps.period_name           = gp.period_name AND
		gps.application_id        = l_application_id AND
		gp.period_year            = p_year+1 AND
		gp.adjustment_Period_flag = 'N';


        SELECT  max(gp.period_num)
		INTO l_max_period_num
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id    = l_sob_id AND  /* p_sob_id => l_sob_id by Bug 6341012 */
       		gp.period_set_name    = gb.period_set_name AND
		gp.period_type        = gb.accounted_period_type AND
		gps.set_of_books_id   = gb.set_of_books_id AND
		gps.period_name       = gp.period_name AND
		gps.application_id    = l_application_id AND
		gp.period_year        = p_year AND
		gp.adjustment_Period_flag = 'N';



        SELECT	gps.end_date,gps.end_date INTO
		l_yr_end_cr_date,l_yr_end_date
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id    = l_sob_id AND /* p_sob_id => l_sob_id by Bug 6341012 */
       		gp.period_set_name    = gb.period_set_name AND
		gp.period_type        = gb.accounted_period_type AND
		gps.set_of_books_id   = gb.set_of_books_id AND
		gps.period_name       = gp.period_name AND
		gps.application_id    = l_application_id AND
		gp.period_year        = p_year AND
		gp.period_num         = l_max_period_num;


        SELECT	gps.start_date, gps.start_date INTO
		l_yr_end_dr_date, l_yr_start_date_next
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id    = l_sob_id AND /* p_sob_id => l_sob_id by Bug 6341012 */
       		gp.period_set_name    = gb.period_set_name AND
		gp.period_type        = gb.accounted_period_type AND
		gps.set_of_books_id   = gb.set_of_books_id AND
		gps.period_name       = gp.period_name AND
		gps.application_id    = l_application_id AND
		gp.period_year        = p_year+1 AND
		gp.period_num         = l_min_period_num;


        SELECT	gps.start_date INTO
		l_yr_start_date
	FROM    gl_period_statuses gps,
	        gl_periods gp,
	        gl_sets_of_books gb
	WHERE
		gb.set_of_books_id    = l_sob_id AND /* p_sob_id => l_sob_id by Bug 6341012 */
       		gp.period_set_name    = gb.period_set_name AND
		gp.period_type        = gb.accounted_period_type AND
		gps.set_of_books_id   = gb.set_of_books_id AND
		gps.period_name       = gp.period_name AND
		gps.application_id    = l_application_id AND
		gp.period_year        = p_year AND
		gp.period_num         = l_min_period_num;


     /******************* END ENCUMBRANCE CODE ************************/


      /* Fetching Rows from IGC_CC_HEADERS into IGC_CC_PROCESS_DATA depending upon Parameters */

      l_PROCESS_TYPE := 'Y';

      DELETE FROM IGC_CC_PROCESS_DATA A
      WHERE  A.PROCESS_TYPE      = 'Y'
      AND    A.PROCESS_PHASE     = 'P'
/* Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
      AND    A.ORG_ID            =  l_org_id
      AND    A.SET_OF_BOOKS_ID   =  l_sob_id;

      DELETE FROM IGC_CC_PROCESS_EXCEPTIONS B
      WHERE  B.PROCESS_TYPE      =  'Y'
/* Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
      AND    B.ORG_ID            =  l_org_id
      AND    B.SET_OF_BOOKS_ID   =  l_sob_id;

      COMMIT;

      IF    p_PROCESS_PHASE = 'F'
      THEN

/* Bug 1866742, Year end not running for 2 consecutive years
   -- Commented the following out as it did not make sense.

   -- Because the records are left behind with status processed
   -- in IGC_CC_PROCESS_DATA, they do not get picked up for subsequent runs.
   -- Hence cleaning the table off like is being done for Preliminary mode
   -- Bidisha S, 24 July 2001

            DELETE FROM IGC_CC_PROCESS_DATA A
            WHERE  A.PROCESS_TYPE      = 'Y'
            AND    A.PROCESS_PHASE     IN ('F','P')
            AND   ( A.PROCESSED        <> 'Y' OR A.PROCESSED IS NULL)
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
            AND    A.ORG_ID            =  l_org_id
            AND    A.SET_OF_BOOKS_ID   =  l_sob_id;

	    UPDATE IGC_CC_PROCESS_DATA A
	    SET    REQUEST_ID          = l_REQUEST_ID1
            WHERE  A.PROCESS_TYPE      = 'Y'
            AND    A.PROCESS_PHASE     = 'F'
            AND    A.PROCESSED         = 'Y'
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
            AND    A.ORG_ID            =  l_org_id
            AND    A.SET_OF_BOOKS_ID   =  l_sob_id;
*/


          -- Added for 1866742, Bidisha S, 24 July 2001
          -- Delete all records that have been processed
          -- Updation of request id has been moved below.
          DELETE FROM IGC_CC_PROCESS_DATA A
          WHERE  A.PROCESS_TYPE      = 'Y'
          AND    A.PROCESS_PHASE     = 'F'
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
          AND    A.ORG_ID            =  l_org_id
          AND    A.SET_OF_BOOKS_ID   =  l_sob_id
          AND    A.PROCESSED         = 'Y';

      END IF;

      COMMIT;

      OPEN C1( l_yr_start_date,
               l_yr_end_date,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
               l_sob_id,
               l_org_id);

           LOOP
               FETCH C1 INTO V1;
               IF C1%ROWCOUNT = 0
               THEN
                  l_EXCEPTION := NULL;
                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CC_EXIST');
                  FND_MESSAGE.SET_TOKEN('YEP_YEAR',p_YEAR,TRUE);
                  IF(g_excep_level >= g_debug_level) THEN
                  	FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                  END IF;
                  l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                               l_PROCESS_TYPE,
                                                               p_PROCESS_PHASE,
                                                               NULL,
                                                               NULL,
                                                               NULL,
                                                               l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                               l_org_id,
                                                               l_sob_id,
                                                               l_REQUEST_ID1);
                  l_CONTRACT_COUNTER := 1;

               END IF;

               EXIT WHEN C1%NOTFOUND;

               IF    p_PROCESS_PHASE = 'F'
               THEN
                  BEGIN
                     SELECT   CC_HEADER_ID
                     INTO     l_HEADER_ID
                     FROM     IGC_CC_PROCESS_DATA A
                     WHERE    A.CC_HEADER_ID = V1.CC_HEADER_ID
                     AND      A.PROCESS_PHASE = 'F'
                     AND      A.PROCESS_TYPE  = 'Y';
--                   AND      A.REQUEST_ID   =  l_REQUEST_ID1;

	             UPDATE IGC_CC_PROCESS_DATA A
	                SET OLD_APPROVAL_STATUS  = V1.CC_APPRVL_STATUS,
	                    REQUEST_ID           = l_REQUEST_ID1
                      WHERE  A.CC_HEADER_ID      = V1.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                        AND  A.ORG_ID            = l_org_id
                        AND  A.SET_OF_BOOKS_ID   = l_sob_id
                        AND  A.PROCESS_PHASE     = 'F'
                        AND  A.PROCESS_TYPE      = 'Y';

                     EXCEPTION
                              WHEN  NO_DATA_FOUND
                              THEN

                          INSERT INTO IGC_CC_PROCESS_DATA
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							VALIDATION_STATUS,
							RESERVATION_STATUS,
							PROCESSED,
							OLD_APPROVAL_STATUS,
                                                        ORG_ID,
							SET_OF_BOOKS_ID,
                                                        VALIDATE_ONLY,
							REQUEST_ID)
							VALUES(l_PROCESS_TYPE,
                                                                            p_PROCESS_PHASE,
                                                                            V1.CC_HEADER_ID,
                                                                            NULL,
                                                                            NULL,
                                                                            NULL,
                                                                            V1.CC_APPRVL_STATUS,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                            l_org_id,
                                                                            l_sob_id,
                                                                            NULL,
                                                                            l_REQUEST_ID1);
                 END;
              END IF;

              IF    p_PROCESS_PHASE = 'P'
              THEN

                          INSERT INTO IGC_CC_PROCESS_DATA
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							VALIDATION_STATUS,
							RESERVATION_STATUS,
							PROCESSED,
							OLD_APPROVAL_STATUS,
                                                        ORG_ID,
							SET_OF_BOOKS_ID,
                                                        VALIDATE_ONLY,
							REQUEST_ID)
							VALUES(l_PROCESS_TYPE,
                                                            p_PROCESS_PHASE,
                                                            V1.CC_HEADER_ID,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            V1.CC_APPRVL_STATUS,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                            l_org_id,
                                                            l_sob_id,
                                                            NULL,
                                                            l_REQUEST_ID1);
              END IF;

          END LOOP;
      CLOSE C1;
      COMMIT;


  IF l_CONTRACT_COUNTER = 0  /* IF CONTRACT EXIST IN THAT YEAR */
  THEN

         /* **** Preliminary Mode *****/

       IF    p_PROCESS_PHASE = 'P'
       THEN  OPEN C2;

             LOOP

                FETCH C2 INTO V2;

                EXIT WHEN C2%NOTFOUND;

                SELECT   CC_TYPE
                INTO     l_Type
                FROM     IGC_CC_HEADERS
                WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;

                IF l_type = 'S' OR l_Type = 'C'
                THEN

                /* Validation Phase */

                l_RESULT_OF_VALIDATION := IGC_CC_REP_YEP_PVT.VALIDATE_CC( V2.CC_HEADER_ID,
                                                                          l_PROCESS_TYPE,
                                                                          p_PROCESS_PHASE,
                                                                          p_YEAR,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                          l_sob_id,
                                                                          l_org_id,
                                                                          l_prov_enc_on,
                                                                          l_REQUEST_ID1);

                UPDATE  IGC_CC_PROCESS_DATA
                SET     VALIDATION_STATUS                =   l_RESULT_OF_VALIDATION
                WHERE   IGC_CC_PROCESS_DATA.CC_HEADER_ID =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                AND     SET_OF_BOOKS_ID                  =   l_sob_id
                AND     IGC_CC_PROCESS_DATA.ORG_ID       =   l_org_id
                AND     IGC_CC_PROCESS_DATA.PROCESS_TYPE =   l_PROCESS_TYPE
                AND     IGC_CC_PROCESS_DATA.REQUEST_ID   =   l_REQUEST_ID1;

                END IF;

            END LOOP;

          CLOSE C2;

      END IF;

     /**** End of Preliminary Mode ****/



     /****** Final Mode ******/

     IF    p_PROCESS_PHASE = 'F'
     THEN  OPEN C2;
             LOOP
               FETCH C2 INTO V2;
               EXIT WHEN C2%NOTFOUND;

               SELECT CC_NUM
               INTO   l_CC_NUM
               FROM   IGC_CC_HEADERS
               WHERE  CC_HEADER_ID = V2.CC_HEADER_ID;

               l_LOCK_CC_STATUS     := IGC_CC_REP_YEP_PVT.LOCK_CC(V2.CC_HEADER_ID);

               IF    l_LOCK_CC_STATUS  = FALSE
               THEN
                     l_EXCEPTION := NULL;
                     FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADER_LOCK');
                     FND_MESSAGE.SET_TOKEN('NUMBER',l_CC_NUM,TRUE);
                     IF(g_excep_level >= g_debug_level) THEN
                          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                     END IF;
                     l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                               l_PROCESS_TYPE,
                                                               p_PROCESS_PHASE,
                                                               V2.CC_HEADER_ID,
                                                               NULL,
                                                               NULL,
                                                               l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                               l_org_id,
                                                               l_sob_id,
                                                               l_REQUEST_ID1);
               END IF;


               SELECT   CC_TYPE
               INTO     l_Type
               FROM     IGC_CC_HEADERS
               WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;

               IF l_type <> 'C'
               THEN

                   l_LOCK_PO_STATUS    := IGC_CC_REP_YEP_PVT.LOCK_PO(V2.CC_HEADER_ID);

                   IF   l_LOCK_PO_STATUS = FALSE
                   THEN
                   l_EXCEPTION := NULL;
                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_PO_LOCKED');
                   FND_MESSAGE.SET_TOKEN('NUMBER',l_CC_NUM,TRUE);
                   IF(g_excep_level >= g_debug_level) THEN
                          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                   END IF;
                   l_EXCEPTION := FND_MESSAGE.GET;

                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
							      l_PROCESS_TYPE,
                                                              p_PROCESS_PHASE,
                                                              V2.CC_HEADER_ID,
                                                              NULL,
                                                              NULL,
                                                              l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                              l_org_id,
                                                              l_sob_id,
                                                              l_REQUEST_ID1);
                   END IF;
               END IF;

               IF    l_LOCK_CC_STATUS = FALSE  OR l_LOCK_PO_STATUS = FALSE
               THEN
                     l_COUNTER := l_COUNTER + 1;

               END IF;

             END LOOP;

           CLOSE C2;


           IF     l_COUNTER = 0 AND p_PROCESS_PHASE = 'F'    /* If LOcks are Successful */
           THEN
                  /* Checking Period Status For CC and GL in FINAL MODE */

                  OPEN C6;

                       LOOP
              		  FETCH C6 INTO V6;
                          EXIT WHEN C6%NOTFOUND;

                          -- Bug 3464401, Removed hardcoding of period numbers.
                          -- IF     (V6.PERIOD_NUM BETWEEN  1 AND 11)
                          -- AND V6.CC_PERIOD_STATUS NOT IN ('C','P','N')
                          IF  (V6.PERIOD_NUM < l_max_period_num)
                          AND V6.CC_PERIOD_STATUS NOT IN ('C','P','N')
                          THEN
                                 l_EXCEPTION := NULL;
                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CC_PERIOD_STATUS');
                                 FND_MESSAGE.SET_TOKEN('PERIOD_NAME',V6.PERIOD_NAME,TRUE);
                                 IF(g_excep_level >= g_debug_level) THEN
                                     FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                 END IF;
                                 l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                               l_PROCESS_TYPE,
                                                               p_PROCESS_PHASE,
                                                               NULL,
                                                               NULL,
                                                               NULL,
                                                               l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                               l_org_id,
                                                               l_sob_id,
                                                               l_REQUEST_ID1);

                                 l_STATUS_COUNTER := l_STATUS_COUNTER + 1;
                                 l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                          END IF;

                          -- Bug 3464401, Removed hardcoding of period numbers.
                          --IF       V6.PERIOD_NUM = 12 AND V6.CC_PERIOD_STATUS <> 'O'
                          IF  V6.PERIOD_NUM = l_max_period_num
                          AND V6.CC_PERIOD_STATUS <> 'O'
                          THEN
                                   l_EXCEPTION := NULL;
                                   FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CC_LAST_PERIOD');
                                   FND_MESSAGE.SET_TOKEN('PERIOD_NAME',V6.PERIOD_NAME,TRUE);
                                   IF(g_excep_level >= g_debug_level) THEN
                                      FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                   END IF;
                                   l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
										  l_PROCESS_TYPE,
                                                                                  p_PROCESS_PHASE,
                                                                                  NULL,
                                                                                  NULL,
                                                                                  NULL,
                                                                                  l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                                  l_org_id,
                                                                                  l_sob_id,
                                                                                  l_REQUEST_ID1);
                                   l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;

                          END IF;

                       END LOOP;

                     CLOSE C6;

                     OPEN C7;
                       LOOP
                          FETCH C7 INTO V7;
                          EXIT WHEN C7%NOTFOUND;
                          IF      C7%ROWCOUNT = 0
                          THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CC_PERIOD_EXISTS');
                                  IF(g_excep_level >= g_debug_level) THEN
                                      FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                  END IF;
                                  l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                         l_PROCESS_TYPE,
                                                                         p_PROCESS_PHASE,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                         l_org_id,
                                                                         l_sob_id,
                                                                         l_REQUEST_ID1);

                                  l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                                  EXIT;
                          END IF;

                          -- Bug 3464401, Removed hardcoding of period numbers.
                          --IF      V7.PERIOD_NUM = 1 AND  V7.CC_PERIOD_STATUS NOT IN ('O','F')
                          IF      V7.PERIOD_NUM = l_min_period_num
                          AND  V7.CC_PERIOD_STATUS NOT IN ('O','F')
                          THEN
                                  l_EXCEPTION := NULL;
                                  FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_CC_FUTURE_PERIOD');
                                  FND_MESSAGE.SET_TOKEN('PERIOD_NAME',V7.PERIOD_NAME,TRUE);
                              	  IF(g_excep_level >= g_debug_level) THEN
                                      FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                  END IF;
                                  l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                               l_PROCESS_TYPE,
                                                                               p_PROCESS_PHASE,
                                                                               NULL,
                                                                               NULL,
                                                                               NULL,
                                                                               l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                               l_org_id,
                                                                               l_sob_id,
                                                                               l_REQUEST_ID1);
                                        l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                           END IF;

                       END LOOP;
                     CLOSE C7;

                     -- Added parameters into C8 for Bug 3464401
                     -- Fetch the details of the first period in the new year
                     OPEN C8 (p_year + 1,
                              l_min_period_num);
                        FETCH C8 INTO V8;
                        IF   C8%ROWCOUNT = 0
                        THEN
                             l_EXCEPTION := NULL;
                             FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_GL_PERIOD_EXISTS');
                             IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                             END IF;
                             l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                            l_PROCESS_TYPE,
                                                                            p_PROCESS_PHASE,
                                                                            NULL,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                            l_org_id,
                                                                            l_sob_id,
                                                                            l_REQUEST_ID1);
                             l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                        END IF;

                        IF    V8.CLOSING_STATUS NOT IN ('F','O')
                        THEN
                              l_EXCEPTION := NULL;
                              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_GL_FIRST_PERIOD');
                              FND_MESSAGE.SET_TOKEN('PERIOD_NAME',V8.PERIOD_NAME,TRUE);
                              IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                              END IF;
                              l_EXCEPTION := FND_MESSAGE.GET;

                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                            l_PROCESS_TYPE,
                                                                            p_PROCESS_PHASE,
                                                                            NULL,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                            l_org_id,
                                                                            l_sob_id,
                                                                            l_REQUEST_ID1);
                                   l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                            END IF;

                      CLOSE C8;

                      -- Added parameters into C8 for Bug 3464401
                      -- Fetch the details of the last period in the current year
                      -- With the parameters being used, the cursor C9 is
                      -- redundant and C8 can be used
                      OPEN C8 (p_year,
                              l_max_period_num);
--                      OPEN C9;
                        FETCH C8 INTO V8;
                        IF   C8%ROWCOUNT = 0
                        THEN
                             l_EXCEPTION := NULL;
                             FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_GL_LAST_PRD_EXISTS');
                             IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                             END IF;
                             l_EXCEPTION := FND_MESSAGE.GET;

                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                            l_PROCESS_TYPE,
                                                                            p_PROCESS_PHASE,
                                                                            NULL,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                            l_org_id,
                                                                            l_sob_id,
                                                                            l_REQUEST_ID1);
                             l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                        END IF;

                        IF    V8.CLOSING_STATUS <> 'O'
                        THEN
                              l_EXCEPTION := NULL;
                              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_GL_LAST_PERIOD');
                              FND_MESSAGE.SET_TOKEN('PERIOD_NAME',V8.PERIOD_NAME,TRUE);
                              IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                              END IF;
                              l_EXCEPTION := FND_MESSAGE.GET;

                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                            l_PROCESS_TYPE,
                                                                            p_PROCESS_PHASE,
                                                                            NULL,
                                                                            NULL,
                                                                            NULL,
                                                                            l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                            l_org_id,
                                                                            l_sob_id,
                                                                            l_REQUEST_ID1);
                                   l_PERIOD_COUNTER := l_PERIOD_COUNTER + 1;
                        END IF;

                      CLOSE C8;

                    /*  End of Final Mode PERIOD_STATUS Checking */


          IF l_PERIOD_COUNTER = 0
          THEN
            OPEN C2;
              LOOP
                FETCH C2 INTO V2;
                EXIT WHEN C2%NOTFOUND;

                   SELECT   CC_TYPE,CC_STATE,CC_APPRVL_STATUS
                   INTO     l_TYPE,l_STATE,l_PREVIOUS_APPRVL_STATUS
                   FROM     IGC_CC_HEADERS
                   WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;

                   IF    l_type = 'S' OR l_Type = 'C'
                   THEN

                         /* Validation Phase for Final MOde */

                         l_RESULT_OF_VALIDATION := IGC_CC_REP_YEP_PVT.VALIDATE_CC(
                                                                        V2.CC_HEADER_ID,
                                                                        l_PROCESS_TYPE,
                                                                        p_PROCESS_PHASE,
                                                                        p_YEAR,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                        l_sob_id,
                                                                        l_org_id,
                                                                        l_prov_enc_on,
                                                                        l_REQUEST_ID1);

                         IF     l_RESULT_OF_VALIDATION = 'P'
                         THEN
                                UPDATE  IGC_CC_PROCESS_DATA A
                                SET     VALIDATION_STATUS                =  'P'
                                WHERE   A.CC_HEADER_ID                   =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                AND     A.ORG_ID                         =   l_org_id
                                AND     A.SET_OF_BOOKS_ID                =   l_sob_id
				AND     A.REQUEST_ID                     =   l_REQUEST_ID1
                                AND     A.PROCESS_TYPE                   =   l_PROCESS_TYPE;


                                /* Changing IGC_CC_HEADERS.APPRVL_STATUS => IN PROCESS */


                                UPDATE IGC_CC_HEADERS
                                SET    CC_APPRVL_STATUS                  = 'IP'
                                WHERE  IGC_CC_HEADERS.CC_HEADER_ID       =  V2.CC_HEADER_ID;

                                IF l_TYPE = 'S' AND l_STATE = 'CM' AND l_PREVIOUS_APPRVL_STATUS = 'AP'
                                THEN

                                  BEGIN
                                    SELECT  'Y'
                                    INTO    l_DUMMY
                                    FROM    PO_HEADERS_ALL A
                                    WHERE
                                    A.PO_HEADER_ID =  (SELECT C.PO_HEADER_ID
                                    FROM   IGC_CC_HEADERS B,
                                           PO_HEADERS_ALL C
                                    WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                           B.CC_NUM            =  C.SEGMENT1  AND
                                           C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                           B.CC_HEADER_ID      =  V2.CC_HEADER_ID  );

                                     UPDATE PO_HEADERS_ALL
                                     SET    APPROVED_FLAG  = 'N'
                                     WHERE  (SEGMENT1,ORG_ID,TYPE_LOOKUP_CODE) IN ( SELECT SEGMENT1,a.ORG_ID,TYPE_LOOKUP_CODE
                                                                                    FROM   PO_HEADERS_ALL a, IGC_CC_HEADERS b
                                                                                    WHERE  a.SEGMENT1         =  b.CC_NUM
                                                                                    AND    a.ORG_ID           =  b.ORG_ID
                                                                                    AND    a.TYPE_LOOKUP_CODE = 'STANDARD'
                                                                                    AND    b.CC_HEADER_ID     = V2.CC_HEADER_ID);

                                    EXCEPTION
                                     WHEN NO_DATA_FOUND
                                     THEN
                                          NULL;
                                 END;
                                END IF;

                        END IF;

                        IF     l_RESULT_OF_VALIDATION = 'F'
                        THEN
                               UPDATE  IGC_CC_PROCESS_DATA
                               SET     VALIDATION_STATUS                =   'F'
                               WHERE   IGC_CC_PROCESS_DATA.CC_HEADER_ID =   V2.CC_HEADER_ID
			       AND     REQUEST_ID                       = l_REQUEST_ID1;
                        END IF;

                   END IF;

                END LOOP;

            CLOSE C2;

--            COMMIT;     /*  COMMIT Releases Database Lock on Contract Commitments and POs   */
-- Comented out COMMIT. Locks should not be released untill the end of the process.
-- This is to make sure no other process updates cc_headers while this process is running
-- Bidisha S , 1825957


/*
           -- Bug 1886713, Process should continue even if CC's have failed validation
           -- CC's which have failed validation should of course not be processed.
           -- Bidisha S, 23 July 2001

           -- check for all Contract Commitments get passed through Validation Phase
           SELECT     COUNT(*)
           INTO       l_VALIDATION_COUNTER
           FROM       IGC_CC_PROCESS_DATA
           WHERE      VALIDATION_STATUS = 'F'
	   AND        REQUEST_ID        = l_REQUEST_ID1
           AND        PROCESS_TYPE      = 'Y'
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
           AND        SET_OF_BOOKS_ID   =  l_sob_id
           AND        ORG_ID            =  l_org_id;


           IF         l_VALIDATION_COUNTER = 0
           THEN

*/
           OPEN C2;
           LOOP
                FETCH C2 INTO V2;
                EXIT WHEN C2%NOTFOUND;

                -- Check if the CC has passed validation.
                -- Bug 1866713

                l_invalid_counter := 0;

                SELECT  COUNT(*)
                INTO    l_invalid_counter
                FROM    IGC_CC_PROCESS_DATA
                WHERE   validation_status = 'F'
                AND     request_id        = l_REQUEST_ID1
                AND     process_type      = 'Y'
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                AND     set_of_books_id   =  l_sob_id
                AND     org_id            =  l_org_id
                AND     cc_header_id      = V2.cc_header_id;


                IF l_invalid_counter = 0
                THEN
                               SELECT   CC_STATE
                               INTO     l_STATE
                               FROM     IGC_CC_HEADERS
                               WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;

                               /* Reservation_Phase OR Encumberence Check */

				IF (  (l_State = 'PR' OR l_State = 'CL' )
                                     AND l_sbc_on = TRUE AND l_prov_enc_on = TRUE
                                    )
                                   OR
				   ( (l_State = 'CM' OR l_State = 'CT' )
                                     AND l_sbc_on = TRUE AND l_conf_enc_on = TRUE
                                    )
				THEN


                                	l_RESULT_OF_RESERVATION := IGC_CC_REP_YEP_PVT.Encumber_CC(
                                                               p_process_type                  => 'Y',
                                                               p_cc_header_id                  => V2.CC_HEADER_ID,
                                                               p_sbc_on                        => l_sbc_on,
                                                               p_cbc_on                        => l_cbc_on,
		       /*Bug No : 6341012. R12 SLA Uptake*/
--                                                               p_cc_prov_enc_type_id           => l_cc_prov_enc_type_id,
--                                                               p_cc_conf_enc_type_id           => l_cc_conf_enc_type_id,
--                                                               p_req_encumbrance_type_id       => l_req_encumbrance_type_id,
--                                                               p_purch_encumbrance_type_id     => l_purch_encumbrance_type_id,
                                                               p_currency_code                 => l_currency_code,
                                                               p_yr_start_date                 => l_yr_start_date,
                                                               p_yr_end_date                   => l_yr_end_date,
                                                               p_yr_end_cr_date                => l_yr_end_cr_date,
                                                               p_yr_end_dr_date                => l_yr_end_dr_date,
                                                               p_rate_date                     => NULL,
                                                               p_rate                          => NULL,
                                                               p_revalue_fix_date              => NULL );
				ELSE
					l_result_of_reservation := 'P';
				END IF;

                               IF     l_RESULT_OF_RESERVATION = 'P'
                               THEN
                                      UPDATE  IGC_CC_PROCESS_DATA
                                      SET     RESERVATION_STATUS ='P'
                                      WHERE   IGC_CC_PROCESS_DATA.CC_HEADER_ID =   V2.CC_HEADER_ID
                                      AND     REQUEST_ID                       = l_REQUEST_ID1;


                                      SELECT CC_TYPE
                                      INTO   l_CC_TYPE
                                      FROM   IGC_CC_HEADERS
                                      WHERE  IGC_CC_HEADERS.CC_HEADER_ID = V2.CC_HEADER_ID;


                                     /* Perform Year End Processing on Contract Commitment */


                                      IF     l_CC_TYPE = 'S'   /* Year End processing for Standard Contracts */

                                      THEN
                                             l_RESULT_OF_YEAR_END_UPDATE := YEAR_END_UPDATE(V2.CC_HEADER_ID,
                                                                                            p_YEAR,
-- Bug No : 6341012. MOAC Uptake. p_sob_id is changed to l_sob_id
                                                                                            l_sob_id,
                                                                                            l_REQUEST_ID1,
                                                                                            l_yr_start_date,
                                                                                            l_yr_end_date,
                                                                                            l_sbc_on,
                                                                                            l_cbc_on,
                                                                                            l_prov_enc_on,
                                                                                            l_conf_enc_on);




                                             IF         l_RESULT_OF_YEAR_END_UPDATE  = 'Y'
                                             THEN
                                                        UPDATE IGC_CC_PROCESS_DATA
                                                        SET    PROCESSED                           = 'Y'
                                                        WHERE  CC_HEADER_ID                        =  V2.CC_HEADER_ID
                                                        AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                        AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                        AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                        AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                                                        UPDATE IGC_CC_HEADERS
                                                        SET    CC_APPRVL_STATUS = V2.OLD_APPROVAL_STATUS
                                                        WHERE  CC_HEADER_ID     = V2.CC_HEADER_ID;


                                             SELECT   CC_STATE
                                             INTO     l_STATE
                                             FROM     IGC_CC_HEADERS
                                             WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;


                                             IF  l_STATE = 'CM'
                                             THEN

                                               BEGIN
                                                 SELECT  'Y'
                                                 INTO    l_DUMMY
                                                 FROM    PO_HEADERS_ALL A
                                                 WHERE
                                                 A.PO_HEADER_ID =  (SELECT C.PO_HEADER_ID
                                                 FROM   IGC_CC_HEADERS B,
                                                 PO_HEADERS_ALL C
                                                 WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                 B.CC_NUM            =  C.SEGMENT1  AND
                                                 C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                 B.CC_HEADER_ID      =  V2.CC_HEADER_ID  );

                                                 IGC_CC_PO_INTERFACE_PKG.convert_cc_to_po
                                                                        ( 1.0,
                                                                          FND_API.G_FALSE,
                                                                          FND_API.G_FALSE,
                                                                          FND_API.G_VALID_LEVEL_FULL,
                                                                          l_return_status,
                                                                          l_msg_count,
                                                                          l_msg_data,
                                                                          V2.CC_HEADER_ID);

                                               EXCEPTION
                                               WHEN NO_DATA_FOUND
                                               THEN
                                                    NULL;
                                               END;
                                             END IF;

                                             ELSE
                                                        UPDATE IGC_CC_PROCESS_DATA
                                                        SET    PROCESSED                           =  'N',
                                                               VALIDATION_STATUS                   =  'F',
                                                               RESERVATION_STATUS                  =  'F'
                                                        WHERE  CC_HEADER_ID                        =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                        AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =   l_sob_id
                                                        AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =   l_REQUEST_ID1
                                                        AND    IGC_CC_PROCESS_DATA.ORG_ID          =   l_org_id
                                                        AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =   l_PROCESS_TYPE ;

                                                        UPDATE IGC_CC_HEADERS
                                                        SET    CC_APPRVL_STATUS                    =   V2.OLD_APPROVAL_STATUS
                                                        WHERE  CC_HEADER_ID                        =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                        AND    IGC_CC_HEADERS.SET_OF_BOOKS_ID      =   l_sob_id
                                                        AND    IGC_CC_HEADERS.ORG_ID               =   l_org_id;

                                            END IF;
                                       END IF;

                                       IF    l_CC_TYPE = 'C'   /* Year End processing for Cover Contracts */

                                       THEN
                                             l_RESULT_OF_YEAR_END_UPDATE := YEAR_END_UPDATE(V2.CC_HEADER_ID,
                                                                                            p_YEAR,
-- Bug No : 6341012. MOAC Uptake. p_sob_id is changed to l_sob_id
                                                                                            l_sob_id,
                                                                                            l_REQUEST_ID1,
                                                                                            l_yr_start_date,
                                                                                            l_yr_end_date,
                                                                                            l_sbc_on,
                                                                                            l_cbc_on,
                                                                                            l_prov_enc_on,
                                                                                            l_conf_enc_on);


                                           IF         l_RESULT_OF_YEAR_END_UPDATE  = 'Y'
                                           THEN
                                                      UPDATE IGC_CC_PROCESS_DATA
                                                      SET    PROCESSED                           = 'Y'
                                                      WHERE  CC_HEADER_ID                        =  V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                      AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                      AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                                      AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                      AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                                                      OPEN C11(V2.CC_HEADER_ID);

                                                      RELEASE_YEAR_END_COUNTER := 0;

                                                         LOOP

                                                           FETCH C11 INTO V11;
                                                           EXIT WHEN C11%NOTFOUND;

                                                           l_RESULT_OF_YEAR_END_UPDATE := YEAR_END_UPDATE(V11.CC_HEADER_ID,
                                                                                                          p_YEAR,
-- Bug No : 6341012. MOAC Uptake. p_sob_id is changed to l_sob_id
                                                                                                          l_sob_id,
                                                                                                          l_REQUEST_ID1,
                                                                                                          l_yr_start_date,
                                                                                                          l_yr_end_date,
                                                                                                          l_sbc_on,
                                                                                                          l_cbc_on,
                                                                                                          l_prov_enc_on,
                                                                                                          l_conf_enc_on);
                                                           IF   l_RESULT_OF_YEAR_END_UPDATE  = 'N'
                                                           THEN
                                                                RELEASE_YEAR_END_COUNTER := RELEASE_YEAR_END_COUNTER +1;
                                                           END IF;

                                                           UPDATE   IGC_CC_PROCESS_DATA
                                                           SET    PROCESSED                           =  l_RESULT_OF_YEAR_END_UPDATE
                                                           WHERE  CC_HEADER_ID                        =  V11.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                           AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                           AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                                           AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                           AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                                                          END LOOP;
                                                        CLOSE C11;

                                                          IF    RELEASE_YEAR_END_COUNTER > 0
                                                          THEN
                                                                 UPDATE IGC_CC_PROCESS_DATA
                                                                 SET    PROCESSED                           = 'N'
                                                                 WHERE  CC_HEADER_ID                        =  V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                 AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                                 AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                                                 AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                                 AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                                                                 l_EXCEPTION := NULL;
                                                                 FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_COVER_REL_INSERT');
                              					 IF(g_excep_level >= g_debug_level) THEN
				                                      FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                              					 END IF;
                                                                 l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                                     l_PROCESS_TYPE,
                                                                                     p_PROCESS_PHASE,
                                                                                     V2.CC_HEADER_ID,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                                     l_org_id,
                                                                                     l_sob_id,
                                                                                     l_REQUEST_ID1);

                                                          ELSE
                                                             OPEN C11(V2.CC_HEADER_ID);
                                                             LOOP
                                                                     FETCH C11 INTO V11;
                                                                     EXIT WHEN C11%NOTFOUND;

                                                                     UPDATE IGC_CC_HEADERS
                                                                     SET    CC_APPRVL_STATUS = V2.OLD_APPROVAL_STATUS
                                                                     WHERE  CC_HEADER_ID     = V2.CC_HEADER_ID;

                                                                     SELECT   CC_STATE
                                                                     INTO     l_STATE
                                                                     FROM     IGC_CC_HEADERS
                                                                     WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;


                                                                     IF  l_STATE = 'CM'
                                                                     THEN

                                                                     BEGIN
                                                                       SELECT  'Y'
                                                                       INTO    l_DUMMY
                                                                       FROM    PO_HEADERS_ALL A
                                                                       WHERE
                                                                          A.PO_HEADER_ID =
                                                                                  (SELECT C.PO_HEADER_ID
                                                                                   FROM   IGC_CC_HEADERS B,
                                                                                          PO_HEADERS_ALL C
                                                                                    WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                                                           B.CC_NUM            =  C.SEGMENT1  AND
                                                                                           C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                                                           B.CC_HEADER_ID      =  V11.CC_HEADER_ID  );

                                                                       IGC_CC_PO_INTERFACE_PKG.convert_cc_to_po
                                                                                                       ( 1.0,
                                                                                                         FND_API.G_FALSE,
                                                                                                         FND_API.G_FALSE,
                                                                                                         FND_API.G_VALID_LEVEL_FULL,
                                                                                                         l_return_status,
                                                                                                         l_msg_count,
                                                                                                         l_msg_data,
                                                                                                         V11.CC_HEADER_ID);

                                                                       EXCEPTION
                                                                       WHEN NO_DATA_FOUND
                                                                       THEN
                                                                            NULL;
                                                                 END;
                                                               END IF;
                                                             END LOOP;
                                                            CLOSE C11;
                                                            END IF;


                                           ELSE       UPDATE IGC_CC_PROCESS_DATA
                                                      SET    PROCESSED           =  'N',
                                                             VALIDATION_STATUS   =  'F',
                                                             RESERVATION_STATUS  =  'F'
                                                      WHERE  CC_HEADER_ID        =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                      AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                      AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                                      AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                      AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;


                                                      UPDATE IGC_CC_HEADERS
                                                      SET    CC_APPRVL_STATUS                    =   V2.OLD_APPROVAL_STATUS
                                                      WHERE  CC_HEADER_ID                        =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                      AND    IGC_CC_HEADERS.SET_OF_BOOKS_ID      =   l_sob_id
                                                      AND    IGC_CC_HEADERS.ORG_ID               =   l_org_id;

                                                      OPEN C11(V2.CC_HEADER_ID);
                                                             LOOP

                                                                FETCH C11 INTO V11;
                                                                EXIT WHEN C11%NOTFOUND;

                                                                UPDATE IGC_CC_PROCESS_DATA
                                                                SET    PROCESSED                           = 'N'
                                                                WHERE  CC_HEADER_ID                        =  V11.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                                                AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                                                AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                                                AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                                                             END LOOP;
                                                      CLOSE C11;
                                           END IF;
                                        END IF;
                                ELSE

                                      SELECT CC_NUM
                                      INTO   l_CC_NUM
                                      FROM   IGC_CC_HEADERS
                                      WHERE  CC_HEADER_ID = V2.CC_HEADER_ID;

                                      l_EXCEPTION := NULL;
                                      FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_VAL_DUE_TO_ENC_FAIL');
                                      FND_MESSAGE.SET_TOKEN('NUMBER',l_CC_NUM,TRUE);
                                      IF(g_excep_level >= g_debug_level) THEN
                                          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                      END IF;
                                      l_EXCEPTION := FND_MESSAGE.GET;

                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
						                                    l_PROCESS_TYPE ,
                                                                                    p_PROCESS_PHASE,
                                                                                    V2.CC_HEADER_ID,
                                                                                    NULL,
                                                                                    NULL,
                                                                                    l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                                    l_org_id,
                                                                                    l_sob_id,
                                                                                    l_REQUEST_ID1);


                                       UPDATE IGC_CC_PROCESS_DATA
                                       SET    VALIDATION_STATUS                   = 'F',
                                              PROCESSED                           = 'N',
                                              RESERVATION_STATUS                  = 'F'
                                       WHERE  CC_HEADER_ID                        =  V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                       AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =  l_sob_id
                                       AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =  l_REQUEST_ID1
                                       AND    IGC_CC_PROCESS_DATA.ORG_ID          =  l_org_id
                                       AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =  l_PROCESS_TYPE;

                               END IF;

                ELSE -- CC has not passed validation, Bug 1866713

			UPDATE IGC_CC_PROCESS_DATA
			SET    PROCESSED                           =  'N',
			       VALIDATION_STATUS                   =  'F',
			       RESERVATION_STATUS                  =  'F'
			WHERE  CC_HEADER_ID                        =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
			AND    IGC_CC_PROCESS_DATA.SET_OF_BOOKS_ID =   l_sob_id
			AND    IGC_CC_PROCESS_DATA.REQUEST_ID      =   l_REQUEST_ID1
			AND    IGC_CC_PROCESS_DATA.ORG_ID          =   l_org_id
			AND    IGC_CC_PROCESS_DATA.PROCESS_TYPE    =   l_PROCESS_TYPE ;

-- bug 2043221 ssmales - bug found during testing of topic 46 - approval status needs resetting
-- update added below to process this

                        UPDATE IGC_CC_HEADERS
                        SET CC_APPRVL_STATUS                       =   V2.OLD_APPROVAL_STATUS
                        WHERE CC_HEADER_ID                         =   V2.CC_HEADER_ID
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
			AND    IGC_CC_HEADERS.SET_OF_BOOKS_ID      =   l_sob_id
			AND    IGC_CC_HEADERS.ORG_ID               =   l_org_id ;

                END IF; -- CC has passed validation , Bug 1866713

           END LOOP; -- C2

           CLOSE C2;


/*
-- Bug 1866713
-- Processing should continue in final mode even if a CC has failed validation.
        ELSE
                      l_EXCEPTION := NULL;
                      FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_VALIDATE_ALL');
                      l_EXCEPTION := FND_MESSAGE.GET;


                          INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES(
                                                                    l_PROCESS_TYPE,
                                                                    p_PROCESS_PHASE,
                                                                    NULL,
                                                                    NULL,
                                                                    NULL,
                                                                    l_EXCEPTION,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                                    l_org_id,
                                                                    l_sob_id,
                                                                    l_REQUEST_ID1);
        END IF;
*/ -- 1866713 , End

         /* Reset the Values in IGC_CC_HEADERS AND PO_HEADERS_ALL When all Contracts are processed */
         l_PROCESSED_COUNTER := 0;

         SELECT    COUNT(*)
         INTO      l_PROCESSED_COUNTER
         FROM      IGC_CC_PROCESS_DATA
         WHERE     PROCESSED        = 'N'
         AND       PROCESS_TYPE     = l_PROCESS_TYPE
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
         AND       ORG_ID           = l_org_id
         AND       REQUEST_ID       = l_REQUEST_ID1
         AND       SET_OF_BOOKS_ID  = l_sob_id ;

--         IF        l_PROCESSED_COUNTER = 0
--  Bidisha S, should the check not be count > 0
--  Cause if all records have been processed, then cursor C2 will not return any rows anyway.

         IF        l_PROCESSED_COUNTER > 0
         THEN      OPEN C2;
                      LOOP
                         FETCH C2 INTO V2;
                         EXIT WHEN C2%NOTFOUND;

                        /* Restoring Original Values to IGC_CC_HAEDERS */

                         UPDATE IGC_CC_HEADERS
                         SET    CC_APPRVL_STATUS = V2.OLD_APPROVAL_STATUS
                         WHERE  CC_HEADER_ID     = V2.CC_HEADER_ID;

                        /* Fetching value for PO_HEADERS_ALL => APPROVED_FLAG from IGC_CC_HEADERS => CC_CTRL_STATUS */

                         SELECT CC_CTRL_STATUS
                         INTO   l_CC_CTRL_STATUS
                         FROM   IGC_CC_HEADERS
                         WHERE  CC_HEADER_ID = V2.CC_HEADER_ID;

                         IF     l_CC_CTRL_STATUS = 'O'
                         THEN
                                l_APPROVED_FLAG := 'Y';
                         ELSE
                                l_APPROVED_FLAG := 'N';
                         END IF;

                        /* Restoring Original Values to PO_HEADERS_ALL */

                         SELECT   CC_TYPE,CC_STATE,CC_APPRVL_STATUS
                         INTO     l_TYPE,l_STATE,l_PREVIOUS_APPRVL_STATUS
                         FROM     IGC_CC_HEADERS
                         WHERE    CC_HEADER_ID = V2.CC_HEADER_ID;

                         IF (l_TYPE = 'S' OR l_TYPE = 'R') AND l_STATE = 'CM' AND l_PREVIOUS_APPRVL_STATUS = 'AP'
                         THEN

                           BEGIN
                             SELECT  'Y'
                             INTO    l_DUMMY
                             FROM    PO_HEADERS_ALL A
                             WHERE
                                    A.PO_HEADER_ID =  (SELECT C.PO_HEADER_ID
                                                       FROM   IGC_CC_HEADERS B,
                                                              PO_HEADERS_ALL C
                                                       WHERE  B.ORG_ID            =  C.ORG_ID    AND
                                                              B.CC_NUM            =  C.SEGMENT1  AND
                                                              C.TYPE_LOOKUP_CODE  = 'STANDARD'   AND
                                                              B.CC_HEADER_ID      =  V2.CC_HEADER_ID  );

                              UPDATE PO_HEADERS_ALL
                              SET    APPROVED_FLAG  = l_APPROVED_FLAG
                              WHERE  (SEGMENT1,ORG_ID,TYPE_LOOKUP_CODE) IN ( SELECT SEGMENT1,a.ORG_ID,TYPE_LOOKUP_CODE
                                                                            FROM   PO_HEADERS_ALL a, IGC_CC_HEADERS b
                                                                            WHERE  a.SEGMENT1         =  b.CC_NUM
                                                                            AND    a.ORG_ID           =  b.ORG_ID
                                                                            AND    a.TYPE_LOOKUP_CODE = 'STANDARD'
                                                                            AND    b.CC_HEADER_ID     =  V2.CC_HEADER_ID);
                              EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                         NULL;
                            END;
                          END IF;
                   END LOOP;
                CLOSE C2;

         END IF;  /* END IF of Processed_Counter */

   END IF;  /* END IF of Period_counter */

  COMMIT;
END IF;   /* End of CC and GL Period Counter    */
END IF;   /* End of Lock CC and Lock PO Counter */
END IF;   /* End of Final Mode IF statement     */


         /* Concurrent Program Request Id for generating Report */

/*Bug No : 6341012. MOAC Uptake. Set ORG_ID before submitting request */
      	      Fnd_request.set_org_id(l_org_id);
              l_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                                                         'IGC',
                                                         'IGCCYRPR',
                                                          NULL,
                                                          NULL,
                                                          FALSE,
-- Bug No : 6341012. MOAC Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id
                                                          l_sob_id,
                                                          l_org_id,
                                                          p_PROCESS_PHASE,
                                                          l_PROCESS_TYPE,
                                                          l_REQUEST_ID1);
-----------------------
-- Start of XML Report
-----------------------
         IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCYRPR_XML',
                                            'IGC',
                                            'IGCCYRPR_XML' );

               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCYRPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

                   IF l_layout then
                       Fnd_request.set_org_id(l_org_id);
                       l_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST(
                                                         'IGC',
                                                         'IGCCYRPR_XML',
                                                          NULL,
                                                          NULL,
                                                          FALSE,
                                                          l_sob_id,
                                                          l_org_id,
                                                          p_PROCESS_PHASE,
                                                          'Y',
                                                          l_REQUEST_ID1);
                      END IF;
            END IF;

--------------------
-- End of XML Report
--------------------

         /* End of Concurrent Program Request Id for generating Report */

-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN
      l_error_text := '';
      FOR l_cur IN 1..l_msg_count LOOP
          l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);

          IF (g_excep_level >= g_debug_level) then
	  fnd_log.string(g_excep_level,l_full_path,l_error_text);
          END IF;

          fnd_file.put_line (FND_FILE.LOG,
                             l_error_text);
      END LOOP;
   END IF;

RETURN;

EXCEPTION
        WHEN OTHERS THEN
        IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
           FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'YEAR_END_MAIN');
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                    p_data  => l_msg_data );
        IF (l_msg_count > 0) THEN

           l_error_text := '';
           FOR l_cur IN 1..l_msg_count LOOP
              l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);

              IF (g_excep_level >= g_debug_level) then

              fnd_log.string(g_excep_level,l_full_path,l_error_text);
              END IF;

	      fnd_file.put_line(fnd_file.log,l_error_text);
           END LOOP;
        ELSE
           l_error_text := 'Error Returned but Error stack has no data';

              IF (g_excep_level >= g_debug_level) then

              fnd_log.string(g_excep_level,l_full_path,l_error_text);
              END IF;

	      fnd_file.put_line(fnd_file.log,l_error_text);
        END IF;
        IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
        END IF;

END YEAR_END_MAIN;


/*==================================================================================
                            End of YEAR_END_MAIN Procedure
  =================================================================================*/

END IGC_CC_YEP_PROCESS_PKG;

/
