--------------------------------------------------------
--  DDL for Package Body IGC_CC_MPFS_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_MPFS_PROCESS_PKG" as
/* $Header: IGCCMPSB.pls 120.23.12010000.3 2008/11/04 09:24:24 dramired ship $ */

 G_PKG_NAME CONSTANT 	VARCHAR2(30) := 'IGC_CC_MPFS_PROCESS_PKG';
 g_debug_flag 		VARCHAR2(1);

  g_line_num          NUMBER;

  --g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  g_debug_mode        VARCHAR2(1);
--Variables for ATG Central logging
  g_debug_level       NUMBER;
  g_state_level       NUMBER;
  g_proc_level        NUMBER;
  g_event_level       NUMBER;
  g_excep_level       NUMBER;
  g_error_level       NUMBER;
  g_unexp_level       NUMBER;
  g_path              VARCHAR2(255);


-- Write log
PROCEDURE WriteLog(p_mesg IN VARCHAR2) IS
BEGIN
--  FND_FILE.put_line(FND_FILE.log, p_mesg);
    null;
END WriteLog;
--
-- Generic Procedure for putting out debug information
--
PROCEDURE Output_Debug (p_path VARCHAR2,
   p_debug_msg        IN VARCHAR2
);

-- ==============================================================================
-- Generic procedure that will extract the fiscal year
-- for a given date (bug 2124595)
-- ==============================================================================

FUNCTION Get_Fiscal_Year(p_date IN DATE,
                         p_sob_id IN NUMBER)
    RETURN number IS

	-- Define cursor to extract the fiscal year for p_date
	CURSOR c_fiscal_year(p_sob_id NUMBER) IS
	SELECT period_year
	FROM gl_periods gp,
       	     gl_sets_of_books gsob
	WHERE gp.period_set_name = gsob.period_set_name
	AND   gp.period_type = gsob.accounted_period_type
	AND   trunc(p_date) BETWEEN trunc(gp.start_date)
       		             AND     trunc(gp.end_date)
	AND   gsob.set_of_books_id = p_sob_id;

	-- Define local variables
        l_fiscal_year            NUMBER;

        -- Define exceptions
        e_fiscal_year_not_found  EXCEPTION;

        l_full_path         VARCHAR2(255);

BEGIN

        l_full_path := g_path || 'Get_Fiscal_Year';

        -- Get the fiscal year
        OPEN c_fiscal_year(p_sob_id);

        IF (c_fiscal_year%NOTFOUND) THEN
            RAISE e_fiscal_year_not_found;
        END IF;

        FETCH c_fiscal_year INTO l_fiscal_year;

        CLOSE c_fiscal_year;

        RETURN l_fiscal_year;

EXCEPTION
	WHEN e_fiscal_year_not_found THEN
             IF (g_excep_level >=  g_debug_level ) THEN
                FND_LOG.STRING (g_excep_level,l_full_path,'e_fiscal_year_not_found Exception Raised');
             END IF;
             l_fiscal_year := '';
             Output_Debug(l_full_path, 'IGCCPSMB, procedure Get_Fiscal_Year, fiscal year not found');
             RETURN l_fiscal_year;

END Get_Fiscal_Year;

/*=================================================================================
			     Procedure Insert_Interface_Row
  =================================================================================*/

/* Inserts row into budgetary control interface table */

PROCEDURE Insert_Interface_Row(p_cc_interface_rec IN igc_cc_interface%ROWTYPE)
IS
  l_full_path         VARCHAR2(255);
BEGIN

    l_full_path := g_path || 'Insert_Interface_Row';
	INSERT INTO igc_cc_interface (
	batch_line_num,
	cc_header_id,
	cc_version_num,
	cc_acct_line_id,
	cc_det_pf_line_id,
	set_of_books_id,
	code_combination_id,
	cc_transaction_date,
	transaction_description,
	encumbrance_type_id,
	currency_code,
	cc_func_dr_amt,
	cc_func_cr_amt,
	je_source_name,
	je_category_name,
	actual_flag,
	budget_dest_flag,
	last_update_date,
	last_updated_by,
	last_update_login,
	creation_date,
	created_by,
	period_set_name,
	period_name,
	cbc_result_code,
	status_code,
	budget_version_id,
	budget_amt,
	commitment_encmbrnc_amt,
	obligation_encmbrnc_amt,
	funds_available_amt,
	document_type,
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
	cc_encmbrnc_date,
/* Bug No : 6341012. SLA uptake. Event_ID, Project_Line are added to IGC_CC_INTERFACE Table */
	event_id,
	project_line)
	VALUES
	(p_cc_interface_rec.batch_line_num,
	p_cc_interface_rec.cc_header_id,
	p_cc_interface_rec.cc_version_num,
	p_cc_interface_rec.cc_acct_line_id,
	p_cc_interface_rec.cc_det_pf_line_id,
	p_cc_interface_rec.set_of_books_id,
	p_cc_interface_rec.code_combination_id,
	p_cc_interface_rec.cc_transaction_date,
	p_cc_interface_rec.transaction_description,
	p_cc_interface_rec.encumbrance_type_id,
	p_cc_interface_rec.currency_code,
	p_cc_interface_rec.cc_func_dr_amt,
	p_cc_interface_rec.cc_func_cr_amt,
	p_cc_interface_rec.je_source_name,
	p_cc_interface_rec.je_category_name,
	p_cc_interface_rec.actual_flag,
	p_cc_interface_rec.budget_dest_flag,
	p_cc_interface_rec.last_update_date,
	p_cc_interface_rec.last_updated_by,
	p_cc_interface_rec.last_update_login,
	p_cc_interface_rec.creation_date,
	p_cc_interface_rec.created_by,
	p_cc_interface_rec.period_set_name,
	p_cc_interface_rec.period_name,
	p_cc_interface_rec.cbc_result_code,
	p_cc_interface_rec.status_code,
	p_cc_interface_rec.budget_version_id,
	p_cc_interface_rec.budget_amt,
	p_cc_interface_rec.commitment_encmbrnc_amt,
	p_cc_interface_rec.obligation_encmbrnc_amt,
	p_cc_interface_rec.funds_available_amt,
	p_cc_interface_rec.document_type,
	p_cc_interface_rec.reference_1,
	p_cc_interface_rec.reference_2,
	p_cc_interface_rec.reference_3,
	p_cc_interface_rec.reference_4,
	p_cc_interface_rec.reference_5,
	p_cc_interface_rec.reference_6,
	p_cc_interface_rec.reference_7,
	p_cc_interface_rec.reference_8,
	p_cc_interface_rec.reference_9,
	p_cc_interface_rec.reference_10,
	p_cc_interface_rec.cc_encmbrnc_date,
/* Bug No : 6341012. SLA uptake. Event_ID, Project_Line are added to IGC_CC_INTERFACE Table */
	p_cc_interface_rec.event_id,
	p_cc_interface_rec.project_line);


END Insert_Interface_Row;

/*=================================================================================
			     Procedure Process_Interface_Row
  =================================================================================*/

/* Populates the interface table for the budgetary control as per the process*/

PROCEDURE Process_Interface_Row(
        p_currency_code             IN VARCHAR2,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_Ids are not required*/
--	p_purch_encumbrance_type_id IN financials_system_params_all.purch_encumbrance_type_id%TYPE,
        p_cc_headers_rec            IN igc_cc_headers%ROWTYPE,
        p_cc_acct_lines_rec         IN igc_cc_acct_lines%ROWTYPE,
        p_cc_pmt_fcst_rec           IN igc_cc_det_pf_v%ROWTYPE,
	p_enc_type                  IN VARCHAR2,
  	p_enc_date                  IN DATE,
        p_enc_amt                   IN NUMBER,
        x_return_status             OUT NOCOPY      VARCHAR2,
        x_msg_count                 OUT NOCOPY      NUMBER,
        x_msg_data                  OUT NOCOPY      VARCHAR2)
IS

	l_cc_interface_rec igc_cc_interface%ROWTYPE;

        l_enc_amt          NUMBER;
        l_enc_tax_amt      NUMBER;
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(2000);
        l_return_status    VARCHAR2(1);
        l_full_path         VARCHAR2(255);
	P_Error_Code       VARCHAR2(32); /*EB Tax uptake - Bug No : 6472296*/
	l_taxable_flag     VARCHAR2(2);  /*Bug 6472296 EB Tax uptake - CC*/

BEGIN

        l_full_path := g_path || 'Process_Interface_Row';

        -- Bug 2409502, Calculate the non recoverable tax on the p_enc_amt
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_enc_amt := p_enc_amt;

       /*EB Tax uptake - Bug No : 6472296*/
        /*igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
		(p_api_version       => 1.0,
		p_init_msg_list     => FND_API.G_TRUE,
		p_commit            => FND_API.G_FALSE,
		p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
		x_return_status     => l_return_status,
		x_msg_count         => l_msg_count,
		x_msg_data          => l_msg_data,
		p_tax_id            => p_cc_acct_lines_rec.tax_id,
		p_amount            => l_enc_amt,
		p_tax_amount        => l_enc_tax_amt);
	*/
	l_taxable_flag := nvl(p_cc_acct_lines_rec.cc_acct_taxable_flag,'N');
	IF (l_taxable_flag = 'Y') THEN
		IGC_ETAX_UTIL_PKG.Calculate_Tax
			(P_CC_Header_Rec	=>p_cc_headers_rec,
			P_Calling_Mode		=>null,
			P_Amount		=>l_enc_amt,
			P_Line_Id		=>p_cc_acct_lines_rec.cc_acct_line_id,
			P_Tax_Amount		=>l_enc_tax_amt,
			P_Return_Status		=>l_return_status,
			P_Error_Code            =>P_Error_Code);
		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	/*EB Tax uptake - Bug No : 6472296 END*/
        l_enc_amt := l_enc_amt + Nvl(l_enc_tax_amt,0);
        -- Bug 2409502, End

	l_cc_interface_rec.cbc_result_code          := NULL;
	l_cc_interface_rec.status_code              := NULL;
	l_cc_interface_rec.budget_version_id        := NULL;
	l_cc_interface_rec.budget_amt               := NULL;
	l_cc_interface_rec.commitment_encmbrnc_amt  := NULL;
	l_cc_interface_rec.obligation_encmbrnc_amt  := NULL;
	l_cc_interface_rec.funds_available_amt      := NULL;
	l_cc_interface_rec.reference_1              := NULL;
	l_cc_interface_rec.reference_2              := NULL;
	l_cc_interface_rec.reference_3              := NULL;
	l_cc_interface_rec.reference_4              := NULL;
	l_cc_interface_rec.reference_5              := NULL;
	l_cc_interface_rec.reference_6              := NULL;
	l_cc_interface_rec.reference_7              := NULL;
	l_cc_interface_rec.reference_8              := NULL;
	l_cc_interface_rec.reference_9              := NULL;
	l_cc_interface_rec.reference_10             := NULL;
	l_cc_interface_rec.cc_encmbrnc_date         := NULL;
	l_cc_interface_rec.document_type            := 'CC';

	l_cc_interface_rec.cc_header_id             :=  p_cc_headers_rec.cc_header_id;
	l_cc_interface_rec.cc_version_num           :=  p_cc_headers_rec.cc_version_num + 1;
        l_cc_interface_rec.set_of_books_id          :=  p_cc_headers_rec.set_of_books_id;

	l_cc_interface_rec.code_combination_id      :=  p_cc_acct_lines_rec.cc_budget_code_combination_id;

	l_cc_interface_rec.currency_code            :=  p_currency_code;
/* Bug No : 6341012. SLA uptake. je_source_name will not be populated by this package*/
--	l_cc_interface_rec.je_source_name           := 'Contract Commitment';
	l_cc_interface_rec.actual_flag              :=  'E';
	l_cc_interface_rec.last_update_date         :=  sysdate;
	l_cc_interface_rec.last_updated_by          :=  -1;
	l_cc_interface_rec.last_update_login        :=  -1;
	l_cc_interface_rec.creation_date            :=  sysdate;
	l_cc_interface_rec.created_by               :=  -1;

	l_cc_interface_rec.transaction_description  :=  LTRIM(RTRIM(p_cc_headers_rec.cc_num))
						        || ' ' || rtrim(ltrim(p_cc_acct_lines_rec.cc_acct_desc));

/* Bug No : 6341012. SLA uptake. je_category_name will not be populated by this package*/
--	l_cc_interface_rec.je_category_name         :=  'Confirmed';

/* Bug No : 6341012. SLA uptake. Encumbrance_Type_Ids are not required */
--	l_cc_interface_rec.encumbrance_type_id      :=  p_purch_encumbrance_type_id;
	l_cc_interface_rec.encumbrance_type_id	    := Null;

/* Bug No : 6341012. SLA uptake. Acct_line_Id should be populated*/
	l_cc_interface_rec.cc_acct_line_id          :=  p_cc_acct_lines_rec.cc_acct_line_id; --NULL;
	l_cc_interface_rec.cc_det_pf_line_id        :=  p_cc_pmt_fcst_rec.cc_det_pf_line_id;
	l_cc_interface_rec.budget_dest_flag         :=  'S';
	l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.cc_header_id;
	l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.cc_acct_line_id;
	l_cc_interface_rec.reference_3              :=  p_cc_headers_rec.cc_version_num + 1;
/* Bug No : 6341012. SLA uptake. Reference4 Should be CC_Number*/
--	l_cc_interface_rec.reference_4		        :=  p_cc_pmt_fcst_rec.cc_det_pf_line_id;
	l_cc_interface_rec.reference_4			:= p_cc_headers_rec.cc_num;

/* Bug No : 6341012. SLA uptake. Event_id, Project_Line are new columns in Interface table*/
	l_cc_interface_rec.Event_id	:= Null;
	l_cc_interface_rec.Project_line	:= Null;



	g_line_num := g_line_num + 1;

	l_cc_interface_rec.cc_transaction_date      :=  p_enc_date;
	l_cc_interface_rec.batch_line_num           :=  g_line_num;

	IF (p_enc_type = 'DR')
	THEN
		l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
		l_cc_interface_rec.cc_func_dr_amt           :=  l_enc_amt;
	ELSIF (p_enc_type = 'CR')
	THEN
		l_cc_interface_rec.cc_func_cr_amt           :=  l_enc_amt;
		l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
	END IF;

	Insert_Interface_Row(l_cc_interface_rec);

        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
      				    p_data  => x_msg_data );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN
            x_return_status  := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data );
            IF (g_excep_level >=  g_debug_level ) THEN
                FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
            END IF;

            RETURN;

END Process_Interface_Row;

/*=================================================================================
			     Function Encumber_CC
  =================================================================================*/

FUNCTION Encumber_CC
( p_currency_code                 IN       VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_sbc_on                        IN       BOOLEAN,
  /* Bug No : 6341012. SLA uptake. Encumbrance_Type_Ids are not required*/
--  p_purch_encumbrance_type_id     IN       NUMBER,
  p_start_date                    IN       DATE,
  p_end_date                      IN       DATE,
  p_transfer_date                 IN       DATE,
  p_target_date                   IN       DATE
) RETURN VARCHAR2
IS
	l_interface_row_count		NUMBER;

	l_cc_headers_rec                igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec             igc_cc_acct_lines%ROWTYPE;
	l_cc_pmt_fcst_rec               igc_cc_det_pf_v%ROWTYPE;

	l_enc_amt                       NUMBER := 0;
        l_enc_date                      DATE;

        l_cc_det_pf_line_id             igc_cc_det_pf.cc_det_pf_line_id%TYPE;

	l_debug				            VARCHAR2(1);

	l_batch_result_code		        VARCHAR2(3);
	l_bc_return_status              VARCHAR2(2);
	l_bc_success                    BOOLEAN;

        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_return_status                 VARCHAR2(1);

	e_process_row                   EXCEPTION;
	e_bc_execution                  EXCEPTION;
	e_cc_not_found                  EXCEPTION;
	e_delete                        EXCEPTION;
	e_no_target_pf                  EXCEPTION;

	/* Contract Commitment detail payment forecast  */

	-- SELECT *
	-- FROM igc_cc_det_pf_v
	-- WHERE cc_acct_line_id =  t_cc_acct_line_id;

        --Replaced the above query with the one below.
        --Performance Tuning project. The record definition remains
        --the same , but only the relevant columns are selected.
	CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
	WHERE cc_acct_line_id =  t_cc_acct_line_id;

               /* Current year payment forecast lines only */

	/* Contract Commitment account lines  */

	CURSOR c_account_lines(t_cc_header_id NUMBER) IS
	SELECT *
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

          l_full_path         VARCHAR2(255);

BEGIN

    l_full_path := g_path || 'Encumber_CC';
	SAVEPOINT Execute_Budgetary_Ctrl1;

	g_line_num      := 0;


        BEGIN

		SELECT *
		INTO l_cc_headers_rec
		FROM igc_cc_headers
		WHERE cc_header_id = p_cc_header_id;

	EXCEPTION

		WHEN OTHERS
		THEN
            IF ( g_unexp_level >= g_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
            END IF;
			RAISE E_CC_NOT_FOUND;

	END;


	/* Delete existing interface rows */


	BEGIN

		DELETE igc_cc_interface
		WHERE cc_header_id = p_cc_header_id AND
		      actual_flag = 'E';
	EXCEPTION
		WHEN OTHERS
		THEN
			NULL;
	END;

	COMMIT;

	SAVEPOINT Execute_Budgetary_Ctrl2;

	/* Populate  interface rows with source pf  lines un_billed amounts*/


	OPEN c_account_lines(p_cc_header_id);

	LOOP
		FETCH c_account_lines INTO l_cc_acct_lines_rec;

		EXIT WHEN c_account_lines%NOTFOUND;


		OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

		LOOP
			FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

			EXIT WHEN c_payment_forecast%NOTFOUND;

			l_enc_amt := 0;

			/* check whether payment forecast belongs to yr-end processing year */
			IF ( (l_cc_pmt_fcst_rec.cc_det_pf_date <= p_end_date) AND
			     (l_cc_pmt_fcst_rec.cc_det_pf_date >= p_start_date)
			   )
			THEN
				l_enc_amt := l_cc_pmt_fcst_rec.cc_det_pf_func_amt - l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt;
				IF (p_transfer_date >= l_cc_pmt_fcst_rec.cc_det_pf_date)
				THEN
					l_enc_date := p_transfer_date;
				ELSE
					l_enc_date := l_cc_pmt_fcst_rec.cc_det_pf_date;
				END IF;

				IF (l_enc_amt > 0)
				THEN
					Process_Interface_Row(
                                                     p_currency_code, /* Bug 634102 commented the following parameter
				                             p_purch_encumbrance_type_id, */
        			                             l_cc_headers_rec,
        			                             l_cc_acct_lines_rec,
        			                             l_cc_pmt_fcst_rec,
                                                             'CR',
                                                             l_enc_date,
                                                             l_enc_amt,
		                                             l_return_status,
		                                             l_msg_count,
		                                             l_msg_data
              			                             );
                                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                                         THEN
                                             RAISE FND_API.G_EXC_ERROR;
                                         END IF;

				END IF;
			END IF;

		END LOOP;

		CLOSE c_payment_forecast;

		l_enc_amt := 0;
                l_cc_det_pf_line_id := 0;

		/* Get the target pf */

		BEGIN

			SELECT a.cc_det_pf_line_id
                	INTO   l_cc_det_pf_line_id
			FROM   igc_cc_det_pf a
			WHERE
                     	   a.cc_det_pf_line_num = (SELECT NVL(min(b.cc_det_pf_line_num) , -1)
                                             		FROM igc_cc_det_pf b
                                             		WHERE b.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id AND
                     		                        b.cc_det_pf_date = /* bug fix 1702768 */
                                                                            (SELECT min(c.cc_det_pf_date)
                                                                             FROM igc_cc_det_pf c
                                                                             WHERE c.cc_acct_line_id =
                                                                             l_cc_acct_lines_rec.cc_acct_line_id AND
                                                                             c.cc_det_pf_date >= p_target_date)
                                                       ) AND
                                a.cc_det_pf_date >= p_target_date AND
                     		a.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

                        -- Replaced the following sql with the one below to eliminate
                        -- the use of igc_cc_det_pf_v
			-- SELECT *
                	-- INTO  l_cc_pmt_fcst_rec
                	-- FROM igc_cc_det_pf_v
                	-- WHERE cc_det_pf_line_id = l_cc_det_pf_line_id;

                        SELECT ccdpf.ROWID,
                               ccdpf.cc_det_pf_line_id,
                               ccdpf.cc_det_pf_line_num,
                               NULL  cc_acct_line_num,
                               ccdpf.cc_acct_line_id,
                               NULL  parent_det_pf_line_num,
                               ccdpf.parent_det_pf_line_id,
                               ccdpf.parent_acct_line_id,
                               ccdpf.cc_det_pf_entered_amt,
                               ccdpf.cc_det_pf_func_amt,
                               ccdpf.cc_det_pf_date,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
                               ccdpf.cc_det_pf_unbilled_amt,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
                               ccdpf.cc_det_pf_encmbrnc_amt,
                               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
                               ccdpf.cc_det_pf_encmbrnc_date,
                               ccdpf.cc_det_pf_encmbrnc_status,
                               ccdpf.context,
                               ccdpf.attribute1,
                               ccdpf.attribute2,
                               ccdpf.attribute3,
                               ccdpf.attribute4,
                               ccdpf.attribute5,
                               ccdpf.attribute6,
                               ccdpf.attribute7,
                               ccdpf.attribute8,
                               ccdpf.attribute9,
                               ccdpf.attribute10,
                               ccdpf.attribute11,
                               ccdpf.attribute12,
                               ccdpf.attribute13,
                               ccdpf.attribute14,
                               ccdpf.attribute15,
                               ccdpf.last_update_date,
                               ccdpf.last_updated_by,
                               ccdpf.last_update_login,
                               ccdpf.creation_date,
                               ccdpf.created_by
                	INTO  l_cc_pmt_fcst_rec
                        FROM igc_cc_det_pf ccdpf
                	WHERE cc_det_pf_line_id = l_cc_det_pf_line_id;
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
                IF (g_excep_level >=  g_debug_level ) THEN
                    FND_LOG.STRING (g_excep_level,l_full_path,'NO_DATA_FOUND Exception Raised');
                END IF;
				RAISE E_NO_TARGET_PF;
		END;

		/* Get target pf encumbrance amt */

                -- Replaced igc_cc_det_pf_v with igc_cc_det_pf
                -- Also replaced the following line
		-- SELECT NVL(SUM(NVL(cc_det_pf_func_amt,0) - NVL(cc_det_pf_func_billed_amt,0)) ,0)
		SELECT NVL(SUM(NVL(a.cc_det_pf_func_amt,0) -
                               NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id),0)) ,0)
                INTO   l_enc_amt
		FROM   igc_cc_det_pf a
		WHERE a.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id
-- The check for det_pf_line is not correct.The amount calculated should not be from
-- the target payment forecast. Bug 2858425, 19 March 2003
--                AND cc_det_pf_line_id = l_cc_det_pf_line_id
                AND a.cc_det_pf_date >= p_start_date AND a.cc_det_pf_date <= p_end_date;


		IF (l_enc_amt > 0)
		THEN
			Process_Interface_Row(
                                              p_currency_code,
/* Bug No : 6341012. SLA uptake. Encumbrance_Type_Ids are not required*/
			             --      p_purch_encumbrance_type_id,
       			                      l_cc_headers_rec,
       			                      l_cc_acct_lines_rec,
       			                      l_cc_pmt_fcst_rec,
                                              'DR',
                                              l_cc_pmt_fcst_rec.cc_det_pf_date,
                                              l_enc_amt,
		                              l_return_status,
		                              l_msg_count,
		                              l_msg_data);

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                        THEN
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;
		END IF;

	END LOOP;

	CLOSE c_account_lines;

	COMMIT;

	l_interface_row_count := 0;

	SELECT count(*)
	INTO l_interface_row_count
	FROM igc_cc_interface
	WHERE cc_header_id = p_cc_header_id;

	SAVEPOINT Execute_Budgetary_Ctrl4;

	 /* Execute budgetary control */

	IF (l_interface_row_count <> 0)
	THEN
		l_batch_result_code := NULL;

--		l_debug := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--		IF (l_debug = 'Y')
                IF (g_debug_mode = 'Y')
		THEN
			l_debug := FND_API.G_TRUE;
		ELSE
			l_debug := FND_API.G_FALSE;
		END IF;

		BEGIN

                        -- The call to IGCFCK updated to IGCPAFCK for bug 1844214.
                        -- Bidisha S , 21 June 2001
--			l_bc_success := IGC_CBC_FUNDS_CHECKER.IGCFCK(
			l_bc_success := IGC_CBC_PA_BC_PKG.IGCPAFCK(
                                p_sobid       =>  l_cc_headers_rec.set_of_books_id,
					    p_header_id   =>  l_cc_headers_rec.cc_header_id,
			            p_mode        =>  'F',
						p_actual_flag =>  'E',
						p_ret_status  =>  l_bc_return_status,
						p_batch_result_code => l_batch_result_code,
						p_doc_type    =>  'CC',
						p_debug       =>   l_debug,
						p_conc_proc   =>   FND_API.G_FALSE);
		EXCEPTION
			WHEN OTHERS
			THEN
                        IF ( g_unexp_level >= g_debug_level ) THEN
                           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                           FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                           FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                           FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                        END IF;
         		    /*IF (g_debug_mode = 'Y') THEN
				   Output_Debug (l_full_path, ' SQLERRM ' || SQLERRM);
				END IF;*/
				RETURN 'F';

		END;

		IF (l_bc_success = TRUE)
		THEN
			IF ( (l_bc_return_status <> 'NA') AND
		     	     (l_bc_return_status <> 'AN') AND
		             (l_bc_return_status <> 'AA') AND
		             (l_bc_return_status <> 'AS') AND
		             (l_bc_return_status <> 'SA') AND
		             (l_bc_return_status <> 'SS') AND
		             (l_bc_return_status <> 'SN') AND
		             (l_bc_return_status <> 'NS') )
			THEN
				RETURN('F');
			ELSE
				RETURN('P');
			END IF;
		ELSE
			RETURN('F');
		END IF;
	ELSE
		RETURN('P');
	END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN
            IF (g_excep_level >=  g_debug_level ) THEN
                FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
            END IF;
	    RETURN('F');

	WHEN OTHERS
	THEN
           IF ( g_unexp_level >= g_debug_level ) THEN
              FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
              FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
              FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
              FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
           END IF;
/*	    IF (g_debug_mode = 'Y') THEN
               Output_Debug (l_full_path, ' SQLERRM ' || SQLERRM);
            END IF;*/
           RETURN('F');

END Encumber_CC;

/* This Function returns TRUE if the date which is passed as a parameter fall in a
   GL Period which is Open or Future Entry status */

/*=================================================================================
			     Function IS_GL_PERIOD_OPEN
  =================================================================================*/

FUNCTION IS_GL_PERIOD_OPEN	(p_date_to_check	IN DATE,
				     p_sob_id1		    IN NUMBER)

RETURN VARCHAR2 AS
	l_period_status  gl_period_statuses.closing_status%type;
        l_full_path         VARCHAR2(255);
BEGIN

        l_full_path := g_path || 'IS_GL_PERIOD_OPEN';

	SELECT  gps.closing_status
        INTO    l_period_status
        FROM    gl_period_statuses gps,
                gl_periods gp,
                gl_sets_of_books gb,
                gl_period_types gpt,
                fnd_application fa
        WHERE
                gb.set_of_books_id        = p_sob_id1 AND
                gp.period_set_name        = gb.period_set_name AND
                gp.period_type            = gb.accounted_period_type AND
                gp.adjustment_period_flag = 'N' AND
                gpt.period_type           = gp.period_type AND
                gps.set_of_books_id       = gb.set_of_books_id AND
                gps.period_name           = gp.period_name AND
                gps.application_id        = fa.application_id AND
                fa.application_short_name = 'SQLGL' AND
	        (gp.start_date <= p_date_to_check AND gp.end_date >= p_date_to_check);

	IF (l_period_status = NULL) OR ((NVL(l_period_status,'X') <> 'O') AND  (NVL(l_period_status,'X')<> 'F')) THEN
	RETURN (FND_API.G_FALSE);
	ELSE
	RETURN (FND_API.G_TRUE);
	END IF;


EXCEPTION

	WHEN NO_DATA_FOUND
	THEN
           IF ( g_unexp_level >= g_debug_level ) THEN
              FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
              FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
              FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
              FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
           END IF;
	   RETURN (FND_API.G_FALSE);
END IS_GL_PERIOD_OPEN;

-- Bug 1634159 Fixed
/*=================================================================================
			     Function IS_CC_PERIOD_OPEN
  =================================================================================*/


FUNCTION IS_CC_PERIOD_OPEN	(p_date_to_check	IN DATE,
				 p_sob_id2		IN NUMBER,
				 p_org_id		IN NUMBER)

RETURN VARCHAR2 AS
	l_cc_period_status  igc_cc_periods.cc_period_status%type;
        l_full_path         VARCHAR2(255);

BEGIN

        l_full_path := g_path || 'IS_CC_PERIOD_OPEN';
	SELECT ccp.cc_period_status
        INTO   l_cc_period_status
        FROM   igc_cc_periods   ccp,
               gl_periods       gp ,
               gl_sets_of_books gb
        WHERE
               ccp.period_set_name        = gp.period_set_name       AND
               gp.period_set_name         = gb.period_set_name       AND
               ccp.org_id                 = p_org_id                 AND
               ccp.period_name            = gp.period_name           AND
               gp.period_type             = gb.accounted_period_type AND
               gp.adjustment_period_flag  = 'N'                      AND
               gb.set_of_books_id         = p_sob_id2                 AND
               (gp.start_date <= p_date_to_check AND gp.end_date >= p_date_to_check);

	IF (l_cc_period_status = NULL) OR ((NVL(l_cc_period_status,'X') <> 'O') AND (NVL(l_cc_period_status,'X')<> 'F')) THEN
	RETURN (FND_API.G_FALSE);
	ELSE
	RETURN (FND_API.G_TRUE);
	END IF;


EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
            IF ( g_unexp_level >= g_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
            END IF;
	    RETURN (FND_API.G_FALSE);
END; /* End of IS_CC_PERIOD_OPEN Function */


/* This Procedure validates the parameter and return the result exception if any.
   Please refer to the technical design document for Mass Payment Forecast Shift
   for more detail explanation about the paramter validation. */

/*=================================================================================
			     Procedure  VALIDATE_PARAMS
  =================================================================================*/

PROCEDURE  VALIDATE_PARAMS	(p_process_phase	IN VARCHAR2,
				 p_start_date		IN DATE,
				 p_end_date		IN DATE,
				 p_transfer_date	IN DATE,
				 p_target_date		IN DATE,
				 p_sob_id		IN NUMBER,
				 p_org_id		IN NUMBER,
				 p_sbc_on		IN BOOLEAN,
				 p_result		OUT NOCOPY VARCHAR2,
				 p_exception		OUT NOCOPY VARCHAR2)
AS

l_gl_period_open VARCHAR2(1);
l_cc_period_open VARCHAR2(1);
l_validated 	 VARCHAR2(1);

l_sdate_fiscal_year     NUMBER;
l_edate_fiscal_year     NUMBER;
l_tdate_fiscal_year     NUMBER;

l_full_path         VARCHAR2(255);

BEGIN
   l_gl_period_open := FND_API.G_FALSE;
   l_cc_period_open := FND_API.G_FALSE;
   l_validated 	    := FND_API.G_FALSE;

   l_full_path := g_path || 'VALIDATE_PARAMS';

-- Get the fiscal years for the dates
-- Bug fix 2124595 start 1
   l_sdate_fiscal_year := Get_Fiscal_Year(p_start_date, p_sob_id);
   l_edate_fiscal_year := Get_Fiscal_Year(p_end_date, p_sob_id);
   l_tdate_fiscal_year := Get_Fiscal_Year(p_transfer_date, p_sob_id);

-- Bug fix 2124595 end 1

IF	(p_end_date >= p_start_date) THEN

-- Bug fix 2124595 start 2
/*	IF	(to_char(p_start_date,'YYYY') = to_char(p_end_date,'YYYY')) THEN
		IF (to_char(p_transfer_date,'YYYY')=to_char(p_start_date,'YYYY')) THEN */

	IF	(l_sdate_fiscal_year = l_edate_fiscal_year) THEN
		IF (l_sdate_fiscal_year = l_tdate_fiscal_year) THEN
-- Bug fix 2124595 end 2
			IF (p_transfer_date >= p_start_date) THEN
				IF (p_target_date >= p_transfer_date) THEN
					IF  (p_end_date < p_target_date ) THEN
						l_cc_period_open := FND_API.G_FALSE;
-- Bug 1634159 Fixed
						l_cc_period_open := IGC_CC_MPFS_PROCESS_PKG.IS_CC_PERIOD_OPEN(p_transfer_date,p_sob_id,p_org_id);
						IF FND_API.TO_BOOLEAN(l_cc_period_open) THEN

						IF (p_sbc_on) THEN
						    l_gl_period_open := IGC_CC_MPFS_PROCESS_PKG.IS_GL_PERIOD_OPEN(p_transfer_date,p_sob_id);
							IF FND_API.TO_BOOLEAN(l_gl_period_open )THEN
									l_validated := FND_API.G_TRUE;
							ELSE
								p_exception := NULL;
                                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_TX_DT_NOT_OPEN_GL_PRD');
                                        FND_MESSAGE.SET_TOKEN('TRANSFER_DT',TO_CHAR(p_transfer_date),TRUE);
                                        IF(g_excep_level >= g_debug_level) THEN
                                           FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                        END IF;
                                        p_exception  := FND_MESSAGE.GET;
							END IF;

						ELSE
						    l_validated := FND_API.G_TRUE;
						END IF;
						ELSE
                                    p_exception := NULL;
                                    FND_MESSAGE.SET_NAME('IGC','IGC_CC_TX_DT_NOT_OPEN_CC_PRD');
                                    FND_MESSAGE.SET_TOKEN('TRANSFER_DT',TO_CHAR(p_transfer_date),TRUE);
                                    IF(g_excep_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                                    END IF;
                                    p_exception  := FND_MESSAGE.GET;
						END IF;

					ELSE
                        p_exception := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_TG_NOT_IN_SELECT_DT');
                        FND_MESSAGE.SET_TOKEN('TARGET_DATE',TO_CHAR(p_target_date),TRUE);
                        IF(g_excep_level >= g_debug_level) THEN
                            FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                        END IF;
                        p_exception  := FND_MESSAGE.GET;
                    END IF;
				ELSE
                    p_exception := NULL;
                    FND_MESSAGE.SET_NAME('IGC','IGC_CC_TG_DT_LESS_TX_DT');
                    FND_MESSAGE.SET_TOKEN('TARGET_DATE',TO_CHAR(p_target_date),TRUE);
                    FND_MESSAGE.SET_TOKEN('TRANSFER_DATE',TO_CHAR(p_transfer_date),TRUE);
                    IF(g_excep_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                    END IF;
                    p_exception  := FND_MESSAGE.GET;
                END IF;
			ELSE
                p_exception := NULL;
                FND_MESSAGE.SET_NAME('IGC','IGC_CC_TX_DT_LESS_START_DT');
                FND_MESSAGE.SET_TOKEN('TRANSFER_DATE',TO_CHAR(p_transfer_date),TRUE);
                FND_MESSAGE.SET_TOKEN('START_DATE',TO_CHAR(p_start_date),TRUE);
                IF(g_excep_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                END IF;
                p_exception  := FND_MESSAGE.GET;
            END IF;
		ELSE
            p_exception := NULL;
            FND_MESSAGE.SET_NAME('IGC','IGC_CC_TX_DATE_NOT_IN_FISCAL');
            FND_MESSAGE.SET_TOKEN('TRANSFER_DATE',TO_CHAR(p_transfer_date),TRUE);
            IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
            END IF;
            p_exception  := FND_MESSAGE.GET;
        END IF;
	ELSE
        p_exception := NULL;
        FND_MESSAGE.SET_NAME('IGC','IGC_CC_START_DT_END_DT_FISCAL');
        FND_MESSAGE.SET_TOKEN('START_DATE',TO_CHAR(p_start_date),TRUE);
        FND_MESSAGE.SET_TOKEN('END_DATE',TO_CHAR(p_end_date),TRUE);
        IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
        END IF;
        p_exception  := FND_MESSAGE.GET;
	END IF;
ELSE
    p_exception := NULL;
    FND_MESSAGE.SET_NAME('IGC','IGC_CC_END_DT_LESS_START_DT');
    FND_MESSAGE.SET_TOKEN('START_DATE',TO_CHAR(p_start_date),TRUE);
    FND_MESSAGE.SET_TOKEN('END_DATE',TO_CHAR(p_end_date),TRUE);
    IF(g_excep_level >= g_debug_level) THEN
       FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
    END IF;
    p_exception  := FND_MESSAGE.GET;
END IF;

IF FND_API.TO_BOOLEAN(l_validated) THEN
	p_result := FND_API.G_TRUE;
ELSE
	p_result := FND_API.G_FALSE;

END IF;

END VALIDATE_PARAMS; /* End of Validate Params Procedure */


/* This Function returns 'P' if the Payment Forecast Update is successfull for the cc_header_id passed.
   If the update is failed then it returns 'F' along with the error_message */


/*==================================================================================
			     Function MPFS_UPDATE
  =================================================================================*/
FUNCTION MPFS_UPDATE    (p_cc_header_id         IN NUMBER,
			 p_request_id		IN NUMBER,
                         p_sob_id               IN NUMBER,
                         p_org_id               IN NUMBER,
                         p_start_date           IN DATE,
                         p_end_date             IN DATE,
                         p_target_date          IN DATE,
                         p_transfer_date        IN DATE,
                         l_error_message        OUT NOCOPY VARCHAR2
                       )
RETURN VARCHAR2
IS
    	l_cc_headers_rec              igc_cc_headers%ROWTYPE;
        l_cc_acct_lines_rec           igc_cc_acct_lines_v%ROWTYPE;
        l_cc_pmt_fcst_rec             igc_cc_det_pf_v%ROWTYPE;
        l_cc_pf_target                igc_cc_det_pf_v%ROWTYPE;
	l_rel_cc_headers_rec          igc_cc_headers%ROWTYPE;
	l_action_hist_msg             igc_cc_actions.cc_action_notes%TYPE;
	l_DUMMY			      VARCHAR2(1);

-- Cursors c_acct_lines and c_det_pf_lines
-- modified for bug 2876467
-- ccdpf.cc_det_pf_billed_amt changed to ccdpf.cc_det_pf_func_billed_amt
-- Performance Tuning project. Replaced selection from views
-- igc_cc_acct_lines_v with table igc_cc_acct_lines
-- and igc_cc_det_pf_v with igc_cc_det_pf
-- Replaced the following line as well
--   AND (NVL(ccdpf.cc_det_pf_func_amt,0) - NVL(ccdpf.cc_det_pf_func_billed_amt,0) ) > 0
 CURSOR c_acct_lines(p_cc_header_id NUMBER)
        IS
                -- SELECT *
                -- FROM   igc_cc_acct_lines_v ccal
                -- WHERE  ccal.cc_header_id = p_cc_header_id
                -- AND    exists
        -- ( Select 'x' FROM   igc_cc_det_pf_v ccdpf
        -- WHERE  ccdpf.cc_acct_line_id = ccal.cc_acct_line_id
	-- AND	ccdpf.cc_det_pf_date >= p_start_date AND   ccdpf.cc_det_pf_date <= p_end_date
        -- AND (ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) >0);

               SELECT ccal.ROWID,
                      ccal.cc_header_id,
                      NULL org_id,
                      NULL cc_type,
                      NULL cc_type_code,
                      NULL cc_num,
                      ccal.cc_acct_line_id,
                      ccal.cc_acct_line_num,
                      ccal.cc_acct_desc,
                      ccal.parent_header_id,
                      ccal.parent_acct_line_id,
                      NULL parent_cc_acct_line_num,
                      NULL cc_budget_acct_desc,
                      ccal.cc_budget_code_combination_id,
                      NULL cc_charge_acct_desc,
                      ccal.cc_charge_code_combination_id,
                      ccal.cc_acct_entered_amt,
                      ccal.cc_acct_func_amt,
                      IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                      IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt,
                      ccal.cc_acct_encmbrnc_amt,
                      ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id, NVL(ccal.cc_acct_entered_amt,0) ) - NVL(ccal.cc_acct_encmbrnc_amt,0) ) cc_acct_unencmrd_amt,
                      ccal.cc_acct_unbilled_amt,
                      IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id, NVL(ccal.cc_acct_entered_amt,0)) cc_acct_comp_func_amt,
                      NULL project_number ,
                      ccal.project_id,
                      NULL task_number,
                      ccal.task_id,
                      ccal.expenditure_type,
                      NULL expenditure_org_name,
                      ccal.expenditure_org_id,
                      ccal.expenditure_item_date,
                      ccal.cc_acct_taxable_flag,
                      NULL tax_name,
                      ccal.tax_id,
                      ccal.cc_acct_encmbrnc_status,
                      ccal.cc_acct_encmbrnc_date,
                      ccal.context,
                      ccal.attribute1,
                      ccal.attribute2,
                      ccal.attribute3,
                      ccal.attribute4,
                      ccal.attribute5,
                      ccal.attribute6,
                      ccal.attribute7,
                      ccal.attribute8,
                      ccal.attribute9,
                      ccal.attribute10,
                      ccal.attribute11,
                      ccal.attribute12,
                      ccal.attribute13,
                      ccal.attribute14,
                      ccal.attribute15,
                      ccal.created_by,
                      ccal.creation_date,
                      ccal.last_updated_by,
                      ccal.last_update_date,
                      ccal.last_update_login,
                      ccal.cc_func_withheld_amt,
                      ccal.cc_ent_withheld_amt,
		      IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id, NVL(ccal.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
		      ccal.tax_classif_code	 -- modified for Ebtax uptake (Bug No-6472296)
                FROM   igc_cc_acct_lines ccal
                WHERE  ccal.cc_header_id = p_cc_header_id
                AND    exists ( SELECT 'x'
                                FROM   igc_cc_det_pf ccdpf
                                WHERE  ccdpf.cc_acct_line_id = ccal.cc_acct_line_id
                                AND    ccdpf.cc_det_pf_date >= p_start_date
                                AND    ccdpf.cc_det_pf_date <= p_end_date
                                AND (ccdpf.cc_det_pf_func_amt -
                                     IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id)) >0);



CURSOR c_pf_lines(p_cc_acct_line_id NUMBER,p_start_date DATE, p_end_date DATE)
        IS

                -- Modified the following sql for performance tuning.
                -- SELECT *
                -- FROM   igc_cc_det_pf_v ccdpf
                -- WHERE  ccdpf.cc_acct_line_id = p_cc_acct_line_id
		-- AND	ccdpf.cc_det_pf_date >= p_start_date AND   ccdpf.cc_det_pf_date <= p_end_date
                -- AND    (ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) >0;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
        WHERE  ccdpf.cc_acct_line_id = p_cc_acct_line_id
        AND    ccdpf.cc_det_pf_date >= p_start_date
        AND    ccdpf.cc_det_pf_date <= p_end_date
        AND   (ccdpf.cc_det_pf_func_amt-IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id)) >0;

 CURSOR c_pf_amt_shift(p_cc_acct_line_id NUMBER,p_start_date DATE,p_end_date DATE)
        IS
        -- Performance Tuning, replaced the view igc_cc_det_pf_v
        -- igc_cc_det_pf. Also replaced the following 2 lines
        -- SELECT sum(ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) func_amt_shift, sum(ccdpf.cc_det_pf_entered_amt - ccdpf.cc_det_pf_billed_amt) amt_shift
        -- AND    (ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) >0;


        SELECT sum(ccdpf.cc_det_pf_func_amt-
                   IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id)) func_amt_shift,
               sum(ccdpf.cc_det_pf_entered_amt -
                   IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id)) amt_shift
        FROM    igc_cc_det_pf ccdpf
        WHERE   ccdpf.cc_acct_line_id = p_cc_acct_line_id
        AND	ccdpf.cc_det_pf_date >= p_start_date
        AND     ccdpf.cc_det_pf_date <= p_end_date
        AND    (ccdpf.cc_det_pf_func_amt -
                IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id)) >0;

-- Replaced view igc_cc_det_pf_v with igc_cc_det_pf
 CURSOR c_pf_target (p_cc_acct_line_id NUMBER,p_target_date DATE)
        IS
        -- SELECT *
        -- FROM  igc_cc_det_pf_v ccdpf

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
        WHERE ccdpf.cc_acct_line_id = p_cc_acct_line_id
        AND ccdpf.cc_det_pf_date >= p_target_date
        AND ccdpf.cc_det_pf_line_num =
                                        (SELECT min(ccdpf1.cc_det_pf_line_num)
                                         FROM   igc_cc_det_pf ccdpf1
                                         WHERE ccdpf1.cc_acct_line_id = p_cc_acct_line_id
                                         AND ccdpf1.cc_det_pf_date = /* bug fix 1702768 */
                                                                     (SELECT MIN(ccdpf2.cc_det_pf_date)
                                                                      FROM igc_cc_det_pf ccdpf2
                                                                      WHERE ccdpf2.cc_acct_line_id = p_cc_acct_line_id
                                                                            AND ccdpf2.cc_det_pf_date >= p_target_date)
                                        );

 	l_amt_shift_rec           c_pf_amt_shift%ROWTYPE;
	l_hdr_row_id              VARCHAR2(18);
	l_hist_hdr_row_id         VARCHAR2(18);
	l_acct_row_id             VARCHAR2(18);
	l_hist_acct_row_id        VARCHAR2(18);
	l_pf_row_id               VARCHAR2(18);
	l_hist_pf_row_id          VARCHAR2(18);
        l_action_row_id           VARCHAR2(18);
	l_new_cc_det_pf_func_amt  igc_cc_det_pf.cc_det_pf_func_amt%TYPE;
	l_new_cc_acct_func_amt    igc_cc_acct_lines.cc_acct_func_amt%TYPE;
	l_api_version             CONSTANT NUMBER  :=  1.0;
	l_init_msg_list           VARCHAR2(1);
	l_commit                  VARCHAR2(1);
	l_validation_level        NUMBER;
	l_return_status           VARCHAR2(1);
	l_msg_count               NUMBER;
	l_msg_data                VARCHAR2(2000);
	G_FLAG                    VARCHAR2(1);
	l_approval_status         igc_cc_process_data.old_approval_status%TYPE;
        l_Last_Updated_By         NUMBER;
        l_Last_Update_Login       NUMBER;
        l_Created_By              NUMBER;
        l_cc_version_num          igc_cc_headers.cc_version_num%TYPE;
        l_cc_apprvl_status        igc_cc_headers.cc_apprvl_status%TYPE;
        l_full_path         VARCHAR2(255);
BEGIN
   l_init_msg_list           := FND_API.G_FALSE;
   l_commit                  := FND_API.G_FALSE;
   l_validation_level        := FND_API.G_VALID_LEVEL_FULL;
   l_Last_Updated_By         := FND_GLOBAL.USER_ID;
   l_Last_Update_Login       := FND_GLOBAL.LOGIN_ID;
   l_Created_By              := FND_GLOBAL.USER_ID;

    l_full_path := g_path || 'MPFS_UPDATE';

    IF (g_debug_mode = 'Y') THEN
       Output_Debug (l_full_path, ' IGCCMPSB -- ************  Begin MPFS_UPDATE '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
    END IF;
	SELECT *
	INTO l_cc_headers_rec
	FROM igc_cc_headers
	WHERE cc_header_id = p_cc_header_id
	FOR UPDATE NOWAIT;

	SELECT  old_approval_status
      	INTO    l_approval_status
        FROM    igc_cc_process_data
        WHERE   cc_header_id  = p_cc_header_id AND
                request_id    = p_request_id ;

-- Fixed Bug 1633021 Removed the History Inserts for Header and Lines.

	OPEN c_acct_lines(l_cc_headers_rec.cc_header_id);
	LOOP
		FETCH c_acct_lines INTO l_cc_acct_lines_rec;
		EXIT WHEN c_acct_lines%NOTFOUND;
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  Fetch Account Row '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;


 OPEN c_pf_amt_shift(l_cc_acct_lines_rec.cc_acct_line_id,p_start_date,p_end_date);
        LOOP
        FETCH c_pf_amt_shift INTO l_amt_shift_rec;
        EXIT WHEN c_pf_amt_shift%NOTFOUND;
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  Fetch Payment Forecast Row '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
 END LOOP;
CLOSE c_pf_amt_shift;


 OPEN c_pf_target (l_cc_acct_lines_rec.cc_acct_line_id,p_target_date);
                LOOP
                FETCH c_pf_target  INTO l_cc_pf_target;
                EXIT WHEN c_pf_target%NOTFOUND;

                        /* Update PF Line History */
                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        IGC_CC_DET_PF_HISTORY_PKG.Insert_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_hist_pf_row_id,
                                        l_cc_pf_target.CC_Det_PF_Line_Id,
                                        l_cc_pf_target.CC_Det_PF_Line_Num,
                                        l_cc_pf_target.CC_Acct_Line_Id,
                                        l_cc_pf_target.Parent_Acct_Line_Id,
                                        l_cc_pf_target.Parent_Det_PF_Line_Id,
                                        l_cc_headers_rec.cc_version_num,
                                        'U',
                                        l_cc_pf_target.CC_Det_PF_Entered_Amt,
                                        l_cc_pf_target.CC_Det_PF_Func_Amt,
                                        l_cc_pf_target.CC_Det_PF_Date,
                                        l_cc_pf_target.CC_Det_PF_Billed_Amt,
                                        l_cc_pf_target.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pf_target.CC_Det_PF_Encmbrnc_Amt,
                                        l_cc_pf_target.CC_Det_PF_Encmbrnc_Date,
                                        l_cc_pf_target.CC_Det_PF_Encmbrnc_Status,
                                        l_cc_pf_target.Last_Update_Date,
                                        l_cc_pf_target.Last_Updated_By,
                                        l_cc_pf_target.Last_Update_Login,
                                        l_cc_pf_target.Creation_Date,
					            l_cc_pf_target.Created_By,
                                        l_cc_pf_target.Attribute1,
                                        l_cc_pf_target.Attribute2,
                                        l_cc_pf_target.Attribute3,
                                        l_cc_pf_target.Attribute4,
                                        l_cc_pf_target.Attribute5,
                                        l_cc_pf_target.Attribute6,
                                        l_cc_pf_target.Attribute7,
                                        l_cc_pf_target.Attribute8,
                                        l_cc_pf_target.Attribute9,
                                        l_cc_pf_target.Attribute10,
                                        l_cc_pf_target.Attribute11,
                                        l_cc_pf_target.Attribute12,
                                        l_cc_pf_target.Attribute13,
                                        l_cc_pf_target.Attribute14,
                                        l_cc_pf_target.Attribute15,
                                        l_cc_pf_target.Context,
                                        G_FLAG       );
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After Payment Forecast History Insert '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                        THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   Insert Payment Forecast History Failure '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
                l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_DET_PF_HST_INSERT');
                IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                END IF;
                l_error_message  := FND_MESSAGE.GET;
                        RETURN 'F';
                        END IF;
  l_cc_pf_target.cc_det_pf_entered_amt       := l_cc_pf_target.cc_det_pf_entered_amt +l_amt_shift_rec.amt_shift;
  l_cc_pf_target.cc_det_pf_func_amt         := l_cc_pf_target.cc_det_pf_func_amt+l_amt_shift_rec.func_amt_shift;
  l_cc_pf_target.cc_det_pf_encmbrnc_amt     :=  l_cc_pf_target.cc_det_pf_entered_amt * NVL(l_cc_headers_rec.CONVERSION_RATE,1);
  l_cc_pf_target.cc_det_pf_encmbrnc_date := l_cc_pf_target.cc_det_pf_date;

			SELECT rowid
                        INTO   l_pf_row_id
                        FROM   igc_cc_det_pf
                        WHERE  cc_det_pf_line_id = l_cc_pf_target.cc_det_pf_line_id;

                        IGC_CC_DET_PF_PKG.Update_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_pf_row_id,
                                        l_cc_pf_target.CC_Det_PF_Line_Id,
                                        l_cc_pf_target.CC_Det_PF_Line_Num,
                                        l_cc_pf_target.CC_Acct_Line_Id,
                                        l_cc_pf_target.Parent_Acct_Line_Id,
                                        l_cc_pf_target.Parent_Det_PF_Line_Id,
                                        l_cc_pf_target.CC_Det_PF_Entered_Amt,
                                        l_cc_pf_target.cc_det_pf_func_amt,
                                        l_cc_pf_target.cc_det_pf_date,
                                        l_cc_pf_target.CC_Det_PF_Billed_Amt,
                                        l_cc_pf_target.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pf_target.cc_det_pf_encmbrnc_amt,
                                        l_cc_pf_target.cc_det_pf_encmbrnc_date,
                                        l_cc_pf_target.CC_Det_PF_Encmbrnc_Status,
                                        l_cc_pf_target.Last_Update_Date,
                                        l_cc_pf_target.Last_Updated_By,
                                        l_cc_pf_target.Last_Update_Login,
                                        l_cc_pf_target.Creation_Date,
                                        l_cc_pf_target.Created_By,
                                        l_cc_pf_target.Attribute1,
                                        l_cc_pf_target.Attribute2,
                                        l_cc_pf_target.Attribute3,
                                        l_cc_pf_target.Attribute4,
                                        l_cc_pf_target.Attribute5,
                                        l_cc_pf_target.Attribute6,
                                        l_cc_pf_target.Attribute7,
                                        l_cc_pf_target.Attribute8,
                                        l_cc_pf_target.Attribute9,
                                        l_cc_pf_target.Attribute10,
                                        l_cc_pf_target.Attribute11,
                                        l_cc_pf_target.Attribute12,
                                        l_cc_pf_target.Attribute13,
                                        l_cc_pf_target.Attribute14,
                                        l_cc_pf_target.Attribute15,
                                        l_cc_pf_target.Context,
                                        G_FLAG       );
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   After Payment Forecast Update  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;

                    IF     (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   Update Payment Forecast Failure '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
			l_error_message := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_DET_PF_UPDATE');
                        IF(g_excep_level >= g_debug_level) THEN
                            FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                        END IF;
                        l_error_message  := FND_MESSAGE.GET;
                        RETURN 'F';
                    END IF;

                END LOOP;
                CLOSE c_pf_target;

		OPEN c_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id,p_start_date,p_end_date);
		LOOP
			FETCH c_pf_lines INTO l_cc_pmt_fcst_rec;
			EXIT WHEN c_pf_lines%NOTFOUND;

			/* Update PF Line History */
			l_return_status := FND_API.G_RET_STS_SUCCESS;
                      	IGC_CC_DET_PF_HISTORY_PKG.Insert_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_hist_pf_row_id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Num,
                                        l_cc_pmt_fcst_rec.CC_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Det_PF_Line_Id,
                                        l_cc_headers_rec.cc_version_num,
                                        'U',
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Entered_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Func_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Billed_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
                                        l_cc_pmt_fcst_rec.Last_Update_Date,
		                        l_cc_pmt_fcst_rec.Last_Updated_By,
		                        l_cc_pmt_fcst_rec.Last_Update_Login,
		                        l_cc_pmt_fcst_rec.Creation_Date,
                                        l_cc_pmt_fcst_rec.Created_By,
                                        l_cc_pmt_fcst_rec.Attribute1,
		                        l_cc_pmt_fcst_rec.Attribute2,
		                        l_cc_pmt_fcst_rec.Attribute3,
		                        l_cc_pmt_fcst_rec.Attribute4,
		                        l_cc_pmt_fcst_rec.Attribute5,
		                        l_cc_pmt_fcst_rec.Attribute6,
		                        l_cc_pmt_fcst_rec.Attribute7,
		                        l_cc_pmt_fcst_rec.Attribute8,
		                        l_cc_pmt_fcst_rec.Attribute9,
		                        l_cc_pmt_fcst_rec.Attribute10,
		                        l_cc_pmt_fcst_rec.Attribute11,
		                        l_cc_pmt_fcst_rec.Attribute12,
		                        l_cc_pmt_fcst_rec.Attribute13,
		                        l_cc_pmt_fcst_rec.Attribute14,
		                        l_cc_pmt_fcst_rec.Attribute15,
                                        l_cc_pmt_fcst_rec.Context,
                                        G_FLAG       );
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   After Insert Payment Forecast history  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;

			IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  Insert  Payment Forecast history Failure  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
		l_error_message := NULL;
		FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_DET_PF_HST_INSERT');
                IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                END IF;
               	l_error_message  := FND_MESSAGE.GET;
		RETURN 'F';
                   END IF;

  			IF (l_cc_pmt_fcst_rec.cc_det_pf_date < p_transfer_date)
                        THEN

                        l_cc_pmt_fcst_rec.cc_det_pf_date        := p_transfer_date;
                        l_cc_pmt_fcst_rec.cc_det_pf_entered_amt := l_cc_pmt_fcst_rec.cc_det_pf_billed_amt;
                        l_cc_pmt_fcst_rec.cc_det_pf_func_amt    := l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt;
                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt:= ( l_cc_pmt_fcst_rec.cc_det_pf_billed_amt* NVL(l_cc_headers_rec.CONVERSION_RATE,1));
                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date:= p_transfer_date;

                        END IF;

                        IF (l_cc_pmt_fcst_rec.cc_det_pf_date >= p_transfer_date)
                        THEN
                        l_cc_pmt_fcst_rec.cc_det_pf_entered_amt	:= l_cc_pmt_fcst_rec.cc_det_pf_billed_amt;
                        l_cc_pmt_fcst_rec.cc_det_pf_func_amt   	:= l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt;
                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt:= ( l_cc_pmt_fcst_rec.cc_det_pf_billed_amt* NVL(l_cc_headers_rec.CONVERSION_RATE,1));
                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date := p_transfer_date;
                        END IF;

			SELECT rowid
                        INTO   l_pf_row_id
                        FROM   igc_cc_det_pf
                        WHERE  cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

                        IGC_CC_DET_PF_PKG.Update_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_pf_row_id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Num,
                                        l_cc_pmt_fcst_rec.CC_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Entered_Amt,
                                        l_cc_pmt_fcst_rec.cc_det_pf_func_amt,
                                        l_cc_pmt_fcst_rec.cc_det_pf_date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Billed_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt,
                                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
                                        l_cc_pmt_fcst_rec.Last_Update_Date,
                                        l_cc_pmt_fcst_rec.Last_Updated_By,
                                        l_cc_pmt_fcst_rec.Last_Update_Login,
                                        l_cc_pmt_fcst_rec.Creation_Date,
                                        l_cc_pmt_fcst_rec.Created_By,
                                        l_cc_pmt_fcst_rec.Attribute1,
                                        l_cc_pmt_fcst_rec.Attribute2,
                                        l_cc_pmt_fcst_rec.Attribute3,
                                        l_cc_pmt_fcst_rec.Attribute4,
                                        l_cc_pmt_fcst_rec.Attribute5,
                                        l_cc_pmt_fcst_rec.Attribute6,
                                        l_cc_pmt_fcst_rec.Attribute7,
                                        l_cc_pmt_fcst_rec.Attribute8,
                                        l_cc_pmt_fcst_rec.Attribute9,
                                        l_cc_pmt_fcst_rec.Attribute10,
                                        l_cc_pmt_fcst_rec.Attribute11,
                                        l_cc_pmt_fcst_rec.Attribute12,
                                        l_cc_pmt_fcst_rec.Attribute13,
                                        l_cc_pmt_fcst_rec.Attribute14,
                                        l_cc_pmt_fcst_rec.Attribute15,
                                        l_cc_pmt_fcst_rec.Context,
                                        G_FLAG       );
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   After Update Payment Forecast  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
                    IF     (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************   Update Payment Forecast Failure  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
	    l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_DET_PF_UPDATE');
            IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
            END IF;
            l_error_message  := FND_MESSAGE.GET;
            RETURN 'F';
                    END IF;

		END LOOP;
		CLOSE c_pf_lines;

	END LOOP;
	CLOSE c_acct_lines;
		l_cc_apprvl_status     := l_approval_status;
		l_cc_version_num:= l_cc_headers_rec.CC_VERSION_NUM + 1;

                SELECT rowid
                INTO   l_hdr_row_id
                FROM   igc_cc_headers
                WHERE  CC_HEADER_ID = l_cc_headers_rec.cc_header_id;

 IGC_CC_HEADERS_PKG.Update_Row(
                         l_api_version,
                         l_init_msg_list,
                         l_commit,
                         l_validation_level,
                         l_return_status,
                         l_msg_count,
                         l_msg_data,
                         l_hdr_row_id,
                         l_cc_headers_rec.CC_HEADER_ID,
                         l_cc_headers_rec.ORG_ID,
                         l_cc_headers_rec.CC_TYPE,
                         l_cc_headers_rec.CC_NUM,
                         l_cc_version_num,
                         l_cc_headers_rec.PARENT_HEADER_ID,
                         l_cc_headers_rec.CC_STATE,
                         l_cc_headers_rec.CC_CTRL_STATUS,
                         l_cc_headers_rec.CC_ENCMBRNC_STATUS,
                         l_cc_apprvl_status,
                         l_cc_headers_rec.VENDOR_ID,
                         l_cc_headers_rec.VENDOR_SITE_ID,
                         l_cc_headers_rec.VENDOR_CONTACT_ID,
                         l_cc_headers_rec.TERM_ID,
                         l_cc_headers_rec.LOCATION_ID,
                         l_cc_headers_rec.SET_OF_BOOKS_ID,
                         l_cc_headers_rec.CC_ACCT_DATE,
                         l_cc_headers_rec.CC_DESC,
                         l_cc_headers_rec.CC_START_DATE,
                         l_cc_headers_rec.CC_END_DATE,
                         l_cc_headers_rec.CC_OWNER_USER_ID,
                         l_cc_headers_rec.CC_PREPARER_USER_ID,
                         l_cc_headers_rec.CURRENCY_CODE,
                         l_cc_headers_rec.CONVERSION_TYPE,
		  	     l_cc_headers_rec.CONVERSION_DATE,
                         l_cc_headers_rec.CONVERSION_RATE,
                         l_cc_headers_rec.LAST_UPDATE_DATE,
                         l_cc_headers_rec.LAST_UPDATED_BY,
                         l_cc_headers_rec.LAST_UPDATE_LOGIN,
                         l_cc_headers_rec.CREATED_BY,
                         l_cc_headers_rec.CREATION_DATE,
                         l_cc_headers_rec.CC_CURRENT_USER_ID,
                         l_cc_headers_rec.WF_ITEM_TYPE,
                         l_cc_headers_rec.WF_ITEM_KEY,
                         l_cc_headers_rec.ATTRIBUTE1,
                         l_cc_headers_rec.ATTRIBUTE2,
                         l_cc_headers_rec.ATTRIBUTE3,
			     l_cc_headers_rec.ATTRIBUTE4,
                         l_cc_headers_rec.ATTRIBUTE5,
                         l_cc_headers_rec.ATTRIBUTE6,
                         l_cc_headers_rec.ATTRIBUTE7,
                         l_cc_headers_rec.ATTRIBUTE8,
                         l_cc_headers_rec.ATTRIBUTE9,
                         l_cc_headers_rec.ATTRIBUTE10,
                         l_cc_headers_rec.ATTRIBUTE11,
                         l_cc_headers_rec.ATTRIBUTE12,
                         l_cc_headers_rec.ATTRIBUTE13,
                         l_cc_headers_rec.ATTRIBUTE14,
                         l_cc_headers_rec.ATTRIBUTE15,
                         l_cc_headers_rec.CONTEXT,
                         l_cc_headers_rec.CC_GUARANTEE_FLAG,  -- 2043221
                         G_FLAG);
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After  Header Update'|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;

                IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After  Header Update Failure '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
	    l_error_message := NULL;
            FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_HEADERS_UPDATE');
            IF(g_excep_level >= g_debug_level) THEN
               FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
            END IF;
            l_error_message  := FND_MESSAGE.GET;

                RETURN 'F';
                END IF;

        /* Update Corresponding PO */
-- Fixed the Bug  1632315
		IF l_approval_status = 'AP' THEN
                        BEGIN
                                -- Performance Tuning. Replaced the select with
                                -- the one below
                                -- SELECT  'Y'
                                -- INTO    l_DUMMY
                                -- FROM    po_headers pha1
                                -- WHERE   pha1.po_header_id =     (SELECT pha2.po_header_id
                                --                              FROM    igc_cc_headers cchd,
                                --                                    po_headers pha2
                                --                                 WHERE   cchd.org_id = p_org_id
                                --                                 AND     cchd.cc_header_id = l_cc_headers_rec.cc_header_id
                                --                                 AND     cchd.cc_num = pha2.segment1
                                --                                 AND     pha2.type_lookup_code = 'STANDARD');
                                SELECT  'Y'
                                INTO    l_dummy
                                FROM    po_headers_all pha1,
                                        igc_cc_headers cchd
                                WHERE   cchd.org_id = p_org_id
                                AND     cchd.cc_header_id = l_cc_headers_rec.cc_header_id
                                AND     cchd.cc_num = pha1.segment1
                                AND     pha1.type_lookup_code = 'STANDARD'
                                AND     pha1.org_id = p_org_id;

                		l_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  Before Update PO '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
                		IGC_CC_PO_INTERFACE_PKG.Convert_CC_TO_PO(1.0,
                                        FND_API.G_FALSE,
                                        FND_API.G_TRUE,
                                        FND_API.G_VALID_LEVEL_NONE,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_cc_headers_rec.cc_header_id);
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After Update PO '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
                		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                		THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After Update PO Failure '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
		l_error_message := NULL;
                FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_PO_UPDATE_FAILED');
                IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                END IF;
                l_error_message  := FND_MESSAGE.GET;

                		RETURN 'F';
				END IF;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                NULL;
                        END;

                        END IF;


	l_action_hist_msg := NULL;
-- Fixed Bug 1632552
/*
       	FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_ACT_HIST_MSG');
       	l_action_hist_msg := FND_MESSAGE.GET;

*/
        IGC_CC_ACTIONS_PKG.Insert_Row(
                                l_api_version,
                                l_init_msg_list,
                                l_commit,
                                l_validation_level,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_action_row_id,
                                l_cc_headers_rec.CC_HEADER_ID,
                                l_cc_version_num,
                                'MS',
                                l_cc_headers_rec.CC_STATE,
                                l_cc_headers_rec.CC_CTRL_STATUS,
                                l_cc_apprvl_status,
                                l_action_hist_msg,
                                Sysdate,
                                l_Last_Updated_By,
                                l_Last_Update_Login,
                                Sysdate,
                                l_Created_By);
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After Insert Action History  '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
	IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
        IF (g_debug_mode = 'Y') THEN
           Output_Debug (l_full_path, ' IGCCMPSB -- ************  After Insert Action History Failure '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
        END IF;
		l_error_message := NULL;
		FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_ACTION_HST_INSERT');
                IF(g_excep_level >= g_debug_level) THEN
                    FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                END IF;
               	l_error_message  := FND_MESSAGE.GET;
              RETURN 'F';
	END IF;

	/* Update validation status, in temporary table*/
	UPDATE igc_cc_process_data
	SET
		processed = 'Y'
	WHERE   request_id        = p_request_id AND
		cc_header_id      = P_cc_header_id ;
	RETURN 'P';
EXCEPTION
        WHEN OTHERS
        THEN
        /*        IF (g_debug_mode = 'Y') THEN
                    Output_Debug (l_full_path, ' SQLERRM ' || SQLERRM);
                END IF;*/
        IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
        END IF;
		l_error_message := NULL;
        FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_CC_UPDATE_FAILED');
        IF(g_excep_level >= g_debug_level) THEN
            FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
        END IF;
        l_error_message  := FND_MESSAGE.GET;
        RETURN 'F';
END  MPFS_UPDATE;

/* Formatted on 2004/07/15 16:25 (Formatter Plus v4.8.0) */
/*==================================================================================
                             Procedure MASS_PAYMENT_FORECAST_SHIFT_MAIN
  =================================================================================*/

PROCEDURE mpfs_main (
   errbuf              OUT NOCOPY      VARCHAR2,
   retcode             OUT NOCOPY      VARCHAR2,
   p_process_phase     IN              VARCHAR2,
   p_owner             IN              NUMBER,
   p_start_date        IN              VARCHAR2,
   p_end_date          IN              VARCHAR2,
   p_transfer_date     IN              VARCHAR2,
   p_target_date       IN              VARCHAR2,
   p_threshold_value   IN              NUMBER
)
AS
   l_request_id1                 NUMBER;
   l_request_idt_id2             NUMBER;
   l_process_type                igc_cc_process_data.process_type%TYPE;
   l_org_id                      NUMBER;
   l_sob_id                      NUMBER;
   l_start_date                  DATE;
   l_end_date                    DATE;
   l_transfer_date               DATE;
   l_target_date                 DATE;
-- 01/03/02, CC enabled in IGI
   l_option_name                 VARCHAR2 (80);
   lv_message                    VARCHAR2 (1000);
/* Bug No : 6341012. MOAC uptake. Local variable SOB_Name added*/
   l_sob_name			VARCHAR2(30);

-- Performance Tuning project. Replaced selection from views
-- igc_cc_acct_lines_v with table igc_cc_acct_lines
-- and igc_cc_det_pf_v with igc_cc_det_pf
-- Replaced the following 2 lines a well
--   sum (ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) tot_unbilled_amt
--   AND (NVL(ccdpf.cc_det_pf_func_amt,0) - NVL(ccdpf.cc_det_pf_func_billed_amt,0) ) > 0
   CURSOR c1 (
      p_org_id            NUMBER,
      p_set_of_books_id   NUMBER,
      p_owner_id          NUMBER,
      p_start_date        DATE,
      p_end_date          DATE,
      p_target_date       DATE
   )
   IS
      SELECT   cchd.cc_header_id, cchd.cc_apprvl_status,
               SUM
                  (  ccdpf.cc_det_pf_func_amt
                   - igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    )
                  ) tot_unbilled_amt
          FROM igc_cc_headers cchd,
               igc_cc_acct_lines ccal,
               igc_cc_det_pf ccdpf
         WHERE cchd.cc_header_id = ccal.cc_header_id
           AND ccal.cc_acct_line_id = ccdpf.cc_acct_line_id
           AND cchd.org_id = p_org_id
           AND cchd.set_of_books_id = p_set_of_books_id
           AND cchd.cc_type = 'S'
           AND cchd.cc_state = 'CM'
           AND cchd.cc_encmbrnc_status = 'C'
           AND cchd.cc_owner_user_id = p_owner_id
           AND ccdpf.cc_det_pf_date >= p_start_date
           AND ccdpf.cc_det_pf_date <= p_end_date
           AND (  NVL (ccdpf.cc_det_pf_func_amt, 0)
                - NVL
                     (igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    ),
                      0
                     )
               ) > 0
      GROUP BY cchd.cc_header_id, cchd.cc_apprvl_status;

-- Performance Tuning project. Replaced selection from views
-- igc_cc_acct_lines_v with table igc_cc_acct_lines
-- and igc_cc_det_pf_v with igc_cc_det_pf
-- Replaced the following 2 lines a well
--   sum (ccdpf.cc_det_pf_func_amt-ccdpf.cc_det_pf_func_billed_amt) tot_unbilled_amt
--   AND (NVL(ccdpf.cc_det_pf_func_amt,0) - NVL(ccdpf.cc_det_pf_func_billed_amt,0) ) > 0
   CURSOR c2 (
      p_org_id            NUMBER,
      p_set_of_books_id   NUMBER,
      p_start_date        DATE,
      p_end_date          DATE,
      p_target_date       DATE
   )
   IS
      SELECT   cchd.cc_header_id, cchd.cc_apprvl_status,
               SUM
                  (  ccdpf.cc_det_pf_func_amt
                   - igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    )
                  ) tot_unbilled_amt
          FROM igc_cc_headers cchd,
               igc_cc_acct_lines ccal,
               igc_cc_det_pf ccdpf
         WHERE cchd.cc_header_id = ccal.cc_header_id
           AND ccal.cc_acct_line_id = ccdpf.cc_acct_line_id
           AND cchd.org_id = p_org_id
           AND cchd.set_of_books_id = p_set_of_books_id
           AND cchd.cc_type = 'S'
           AND cchd.cc_state = 'CM'
           AND cchd.cc_encmbrnc_status = 'C'
           AND ccdpf.cc_det_pf_date >= p_start_date
           AND ccdpf.cc_det_pf_date <= p_end_date
           AND (  NVL (ccdpf.cc_det_pf_func_amt, 0)
                - NVL
                     (igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    ),
                      0
                     )
               ) > 0
      GROUP BY cchd.cc_header_id, cchd.cc_apprvl_status;

   CURSOR c3
   IS
      SELECT *
        FROM igc_cc_process_data ccpd
       WHERE ccpd.set_of_books_id = l_sob_id
         AND ccpd.request_id = l_request_id1
         AND ccpd.org_id = l_org_id
         AND ccpd.process_type = l_process_type
         AND (ccpd.processed <> 'Y' OR ccpd.processed IS NULL);

-- Performance Tuning project. Replaced selection from views
-- igc_cc_acct_lines_v with table igc_cc_acct_lines
-- and igc_cc_det_pf_v with igc_cc_det_pf
-- Replaced the following line as well
--   AND (NVL(ccdpf.cc_det_pf_func_amt,0) - NVL(ccdpf.cc_det_pf_func_billed_amt,0) ) > 0
   CURSOR c4 (
      p_org_id          NUMBER,
      p_sob_id          NUMBER,
      p_request_id1     NUMBER,
      p_process_type    VARCHAR2,
      p_start_date      DATE,
      p_end_date        DATE,
      p_transfer_date   DATE
   )
   IS
      SELECT cchd.cc_header_id, cchd.cc_num, ccdpf.cc_acct_line_id,
             ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_date
        FROM igc_cc_headers cchd,
             igc_cc_acct_lines ccal,
             igc_cc_det_pf ccdpf,
             igc_cc_process_data ccpd
       WHERE cchd.cc_header_id = ccpd.cc_header_id
         AND cchd.cc_header_id = ccal.cc_header_id
         AND ccal.cc_acct_line_id = ccdpf.cc_acct_line_id
         AND cchd.org_id = l_org_id
         AND cchd.set_of_books_id = l_sob_id
         AND ccpd.request_id = p_request_id1
         AND ccpd.process_type = p_process_type
         AND (ccpd.processed <> 'Y' OR ccpd.processed IS NULL)
         AND ccdpf.cc_det_pf_date >= p_start_date
         AND ccdpf.cc_det_pf_date <= p_end_date
         AND (  ccdpf.cc_det_pf_func_amt
              - igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    )
             ) > 0;


   CURSOR c4_1 (
      p_org_id          NUMBER,
      p_sob_id          NUMBER,
      p_request_id1     NUMBER,
      p_process_type    VARCHAR2
   )
   IS
      SELECT cchd.cc_header_id, cchd.cc_num
        FROM igc_cc_headers cchd,
             igc_cc_process_data ccpd
       WHERE cchd.cc_header_id = ccpd.cc_header_id
         AND cchd.org_id = l_org_id
         AND cchd.set_of_books_id = l_sob_id
         AND ccpd.request_id = p_request_id1
         AND ccpd.process_type = p_process_type
         AND (ccpd.processed <> 'Y' OR ccpd.processed IS NULL);

   CURSOR c4_2 (
	  p_cc_header_id    NUMBER,
      p_start_date      DATE,
      p_end_date        DATE,
      p_transfer_date   DATE
   )
   IS
      SELECT ccdpf.cc_acct_line_id, ccdpf.cc_det_pf_line_id,
      ccdpf.cc_det_pf_date
        FROM igc_cc_acct_lines ccal,
             igc_cc_det_pf ccdpf
       WHERE ccal.cc_header_id = p_cc_header_id
         AND ccal.cc_acct_line_id = ccdpf.cc_acct_line_id
         AND ccdpf.cc_det_pf_date >= p_start_date
         AND ccdpf.cc_det_pf_date <= p_end_date
         AND (  ccdpf.cc_det_pf_func_amt
              - igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                                                    (ccdpf.cc_det_pf_line_id,
                                                     ccdpf.cc_det_pf_line_num,
                                                     ccdpf.cc_acct_line_id
                                                    )
             ) > 0;


   CURSOR c5
   IS
      SELECT *
        FROM igc_cc_process_data ccpd
       WHERE ccpd.request_id = l_request_id1
         AND ccpd.org_id = l_org_id
         AND ccpd.process_type = l_process_type
         AND ccpd.validation_status = 'P'
         AND (ccpd.processed <> 'Y' OR ccpd.processed IS NULL);

/* This cursor is not used anywhere. The logic also seems incorrect. Commented it
   out so that it does not get picked out in scans for poor sqls.
*/
--CURSOR C6 (p_cc_header_id NUMBER,p_target_date DATE,p_org_id NUMBER,p_sob_id NUMBER)
--IS
-- SELECT cchd.cc_header_id
-- FROM  igc_cc_headers cchd
-- WHERE cchd.cc_header_id = p_cc_header_id
-- AND   cchd.org_id = p_org_id
-- AND   cchd.set_of_books_id = p_sob_id
-- AND   NOT EXISTS  (SELECT 'X'
--           FROM igc_cc_acct_lines_v ccal1
--           WHERE   ccal1.cc_header_id = cchd.cc_header_id
--           AND  NOT EXISTS  (SELECT   'X'
--                    FROM igc_cc_det_pf_v ccdpf1
--                    WHERE   ccdpf1.cc_acct_line_id = ccal1.cc_acct_line_id
--                    AND  ccdpf1.cc_det_pf_date >= p_target_date )
--          );
   CURSOR c7 (
      p_cc_acct_line_id   NUMBER,
      p_target_date       DATE,
      p_cc_header_id      NUMBER
   )
   IS
      -- SELECT *
      -- FROM  igc_cc_det_pf_v ccdpf
      SELECT ccdpf.ROWID, ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num,
             NULL cc_acct_line_num, ccdpf.cc_acct_line_id,
             NULL parent_det_pf_line_num, ccdpf.parent_det_pf_line_id,
             ccdpf.parent_acct_line_id, ccdpf.cc_det_pf_entered_amt,
             ccdpf.cc_det_pf_func_amt, ccdpf.cc_det_pf_date,
             igc_cc_comp_amt_pkg.compute_pf_billed_amt
                              (ccdpf.cc_det_pf_line_id,
                               ccdpf.cc_det_pf_line_num,
                               ccdpf.cc_acct_line_id
                              ) cc_det_pf_billed_amt,
             igc_cc_comp_amt_pkg.compute_pf_func_billed_amt
                         (ccdpf.cc_det_pf_line_id,
                          ccdpf.cc_det_pf_line_num,
                          ccdpf.cc_acct_line_id
                         ) cc_det_pf_func_billed_amt,
             ccdpf.cc_det_pf_unbilled_amt,
             igc_cc_comp_amt_pkg.compute_functional_amt
                   (p_cc_header_id,
                    NVL (ccdpf.cc_det_pf_entered_amt, 0)
                   ) cc_det_pf_comp_func_amt,
             ccdpf.cc_det_pf_encmbrnc_amt,
             (  igc_cc_comp_amt_pkg.compute_functional_amt
                                            (p_cc_header_id,
                                             NVL (ccdpf.cc_det_pf_entered_amt,
                                                  0
                                                 )
                                            )
              - NVL (ccdpf.cc_det_pf_encmbrnc_amt, 0)
             ) cc_det_pf_unencmbrd_amt,
             ccdpf.cc_det_pf_encmbrnc_date, ccdpf.cc_det_pf_encmbrnc_status,
             ccdpf.CONTEXT, ccdpf.attribute1, ccdpf.attribute2,
             ccdpf.attribute3, ccdpf.attribute4, ccdpf.attribute5,
             ccdpf.attribute6, ccdpf.attribute7, ccdpf.attribute8,
             ccdpf.attribute9, ccdpf.attribute10, ccdpf.attribute11,
             ccdpf.attribute12, ccdpf.attribute13, ccdpf.attribute14,
             ccdpf.attribute15, ccdpf.last_update_date, ccdpf.last_updated_by,
             ccdpf.last_update_login, ccdpf.creation_date, ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
       WHERE ccdpf.cc_acct_line_id = p_cc_acct_line_id
         AND ccdpf.cc_det_pf_date >= p_target_date
         AND ccdpf.cc_det_pf_line_num =
                (SELECT MIN (ccdpf1.cc_det_pf_line_num)
                   FROM igc_cc_det_pf ccdpf1
                  WHERE ccdpf1.cc_acct_line_id = p_cc_acct_line_id
                    AND ccdpf1.cc_det_pf_date =          /* bug fix 1702768 */
                           (SELECT MIN (ccdpf2.cc_det_pf_date)
                              FROM igc_cc_det_pf ccdpf2
                             WHERE ccdpf2.cc_acct_line_id = p_cc_acct_line_id
                               AND ccdpf2.cc_det_pf_date >= p_target_date));

   v1                            c1%ROWTYPE;
   v2                            c2%ROWTYPE;
   v3                            c3%ROWTYPE;
   v4                            c4%ROWTYPE;
   v4_1                          c4_1%ROWTYPE;
   v4_2                          c4_2%ROWTYPE;
   v5                            c5%ROWTYPE;
--V6        C6%ROWTYPE;
   v7                            c7%ROWTYPE;
/*************** ENCUMBRANCE CHECK DECLARATION ****************************/
   l_currency_code               gl_sets_of_books.currency_code%TYPE;
   l_sbc_on                      BOOLEAN;
   l_cbc_on                      BOOLEAN;
   l_prov_enc_on                 BOOLEAN;
   l_conf_enc_on                 BOOLEAN;
   l_req_encumbrance_type_id     NUMBER;
   l_purch_encumbrance_type_id   NUMBER;
   l_cc_prov_enc_type_id         NUMBER;
   l_cc_conf_enc_type_id         NUMBER;
/************** END ENCUMBRANCE CHECK PARAMS *****************************/
   l_debug                       VARCHAR2 (1);
   l_rec_found                   NUMBER;
   l_valid_params                VARCHAR2 (1);
   l_exception                   igc_cc_process_exceptions.exception_reason%TYPE;
   l_header_id                   igc_cc_headers.cc_header_id%TYPE;
   l_cc_num                      igc_cc_headers.cc_num%TYPE;
   l_lock_cc_status              BOOLEAN;
   l_lock_po_status              BOOLEAN;
   l_budg_status                 BOOLEAN;
   l_cc_inprocess                VARCHAR2 (1);
   l_gl_period_open              VARCHAR2 (1);
   l_cc_period_open              VARCHAR2 (1);
   l_validate_cc                 VARCHAR2 (1);
   l_source_pf_cc_prd            VARCHAR2 (1);
   l_source_pf_gl_prd            VARCHAR2 (1);
   l_target_pf_found             VARCHAR2 (1);
   l_tgt_gl_open                 VARCHAR2 (1);
   l_tgt_cc_open                 VARCHAR2 (1);
   l_previous_apprvl_status      igc_cc_headers.cc_apprvl_status%TYPE;
   l_dummy                       VARCHAR2 (1);
   l_result_of_reservation       igc_cc_process_data.reservation_status%TYPE;
   l_result_mpfs_update          VARCHAR2 (1);
   l_return_status               VARCHAR2 (1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2 (12000);
   l_error_text                  VARCHAR2 (12000);
   l_usr_msg                     igc_cc_process_exceptions.exception_reason%TYPE;
   l_err_mesg                    igc_cc_process_exceptions.exception_reason%TYPE;
   l_fail                        VARCHAR2 (1);
   l_full_path                   VARCHAR2 (255);
------Variables related to XML Report
   l_terr                      VARCHAR2(10):='US';
   l_lang                      VARCHAR2(10):='en';
   l_layout                    BOOLEAN;
BEGIN
   l_full_path := g_path || 'MPFS_MAIN';
   l_request_id1  := fnd_global.conc_request_id;
   l_process_type := 'M';
   l_rec_found    := 1;
   l_valid_params := fnd_api.g_false;
   l_cc_inprocess     := fnd_api.g_false;
   l_gl_period_open   := fnd_api.g_false;
   l_cc_period_open   := fnd_api.g_false;
   l_validate_cc      := fnd_api.g_true;
   l_source_pf_cc_prd := fnd_api.g_true;
   l_source_pf_gl_prd := fnd_api.g_true;
   l_target_pf_found  := fnd_api.g_false;
   l_tgt_gl_open      := fnd_api.g_false;
   l_tgt_cc_open      := fnd_api.g_false;
   l_result_of_reservation  := 'F';
   l_result_mpfs_update     := 'F';
   l_fail             := fnd_api.g_false;

   -- 01/03/02, check to see if CC is installed
   IF NOT igi_gen.is_req_installed ('CC')
   THEN
      SELECT meaning
        INTO l_option_name
        FROM igi_lookups
       WHERE lookup_code = 'CC' AND lookup_type = 'GCC_DESCRIPTION';

      fnd_message.set_name ('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      fnd_message.set_token ('OPTION_NAME', l_option_name);

      IF (g_error_level >= g_debug_level)
      THEN
         fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
      END IF;

      lv_message := fnd_message.get;
      errbuf := lv_message;
      retcode := 2;
      RETURN;
   END IF;

--
-- Setup debug information based upon profile setup options.
--
--        l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--        IF (l_debug = 'Y') THEN
   IF (g_debug_mode = 'Y')
   THEN
      l_debug := fnd_api.g_true;
   ELSE
      l_debug := fnd_api.g_false;
   END IF;

--        IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
   IF (g_debug_mode = 'Y')
   THEN
      output_debug
         (l_full_path,
             ' IGCCMPSB -- ************ Starting Mass Payment Forecast Shift  CC '
          || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
          || ' *************************'
         );
   END IF;

   -- Bug 1914745, clear any old records from the igc_cc_interface table
   DELETE FROM igc_cc_interface
         WHERE TO_DATE (creation_date, 'DD/MM/YYYY') <=
                                            TO_DATE (SYSDATE, 'DD/MM/YYYY')
                                            - 2;

   retcode := 0;
   l_start_date := TRUNC (TO_DATE (p_start_date, 'YYYY/MM/DD HH24:MI:SS'));
   l_end_date := TRUNC (TO_DATE (p_end_date, 'YYYY/MM/DD HH24:MI:SS'));
   l_transfer_date :=
                    TRUNC (TO_DATE (p_transfer_date, 'YYYY/MM/DD HH24:MI:SS'));
   l_target_date := TRUNC (TO_DATE (p_target_date, 'YYYY/MM/DD HH24:MI:SS'));

/* Bug No : 6341012. MOAC uptake. ORG_ID,SOB_ID are retrieved from packages rather than from profiles*/
--   l_org_id := TO_NUMBER (fnd_profile.VALUE ('ORG_ID'));
--   l_sob_id := TO_NUMBER (fnd_profile.VALUE ('GL_SET_OF_BKS_ID'));
      l_org_id := MO_GLOBAL.get_current_org_id;
      MO_UTILS.get_ledger_info(l_org_id,l_sob_id,l_sob_name);


 /* Begin bug fix 1576023 */
/* This procedure checks the Encumbrance setup for Standard and Commitment Budgets */
   l_msg_data := NULL;
   l_msg_count := 0;
   l_usr_msg := NULL;

   IF (g_debug_mode = 'Y')
   THEN
      output_debug
          (l_full_path,
              ' IGCCMPSB -- ************ Before getting budgetray ctrl info '
           || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
           || ' *************************'
          );
   END IF;

   l_budg_status :=
      igc_cc_rep_yep_pvt.get_budg_ctrl_params (l_sob_id,
                                               l_org_id,
                                               l_currency_code,
                                               l_sbc_on,
                                               l_cbc_on,
                                               l_prov_enc_on,
                                               l_conf_enc_on,
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required */
			           --	       l_req_encumbrance_type_id,
				   --         l_purch_encumbrance_type_id,
		                   --	       l_cc_prov_enc_type_id,
		                   --	       l_cc_conf_enc_type_id ,
                                               l_msg_data,
                                               l_msg_count,
                                               l_usr_msg
                                              );


   IF (g_debug_mode = 'Y')
   THEN
      output_debug
           (l_full_path,
               ' IGCCMPSB -- ************ After getting budgetray ctrl info '
            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
            || ' *************************'
           );
   END IF;

   IF (l_budg_status = FALSE) AND (l_usr_msg IS NOT NULL)
   THEN
      INSERT INTO igc_cc_process_exceptions
                  (process_type, process_phase, cc_header_id,
                   cc_acct_line_id, cc_det_pf_line_id, exception_reason,
                   org_id, set_of_books_id, request_id
                  )
           VALUES (l_process_type, p_process_phase, NULL,
                   NULL, NULL, l_usr_msg,
                   l_org_id, l_sob_id, l_request_id1
                  );

      COMMIT;
      /* Concurrent Program Request Id for generating Report */
/*Bug No : 6341012. MOAC Uptake. Set ORG_ID before submitting request */

      Fnd_request.set_org_id(l_org_id);

      l_request_idt_id2 :=
         fnd_request.submit_request ('IGC',
                                     'IGCCMPPR',
                                     NULL,
                                     NULL,
                                     FALSE,
                                     l_sob_id,
                                     l_org_id,
                                     p_process_phase,
                                     'M',
                                     l_request_id1
                                    );
   /* End of Concurrent Program Request Id for generating Report */


---------------------------
---Run XML Report
---------------------------
   IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCMPPR_XML',
                                            'IGC',
                                            'IGCCMPPR_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCMPPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
               IF l_layout then
                   Fnd_request.set_org_id(l_org_id);
               l_request_idt_id2 :=
                     fnd_request.submit_request (
                                     'IGC',
                                     'IGCCMPPR_XML',
                                     NULL,
                                     NULL,
                                     FALSE,
                                     l_sob_id,
                                     l_org_id,
                                     p_process_phase,
                                     'M',
                                     l_request_id1
                                    );
	         END IF;
       END IF;
---------------------------
---End Of Run XML Report
---------------------------

  END IF;

-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
   IF (l_budg_status = FALSE)
   THEN
      fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                 p_data       => l_msg_data);

      IF (l_msg_count > 0)
      THEN
         l_error_text := '';

         FOR l_cur IN 1 .. l_msg_count
         LOOP
            --l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
            l_error_text :=
                     l_cur || ' ' || fnd_msg_pub.get (l_cur, fnd_api.g_false);
            fnd_file.put_line (fnd_file.LOG, l_error_text);

            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.STRING (g_excep_level, l_full_path, l_error_text);
            END IF;
         END LOOP;
      END IF;
   END IF;

   IF (l_usr_msg IS NULL) AND (l_budg_status = FALSE)
   THEN
      retcode := 2;
   END IF;

   IF (l_budg_status = FALSE)
   THEN
      RETURN;
   END IF;

     /* End bug fix 1576023 */
/*Perform the clean-up operation of IGC_CC_PROCESS_DATA and IGC_CC_PROCESS_EXCEPTIONS */
   SAVEPOINT s1;               /*  Flag 1 Marked for the Complete Roll back */

/* Deletes from  IGC_CC_PROCESS_DATA with PHASE - Preliminary and TYPE - MPFS  */
   DELETE FROM igc_cc_process_data a
         WHERE a.process_type = l_process_type
           AND a.process_phase = 'P'
           AND a.org_id = l_org_id
           AND a.set_of_books_id = l_sob_id;

/* Deletes from IGC_CC_PROCESS_EXCEPTIONS with Type - MPFS */
   DELETE FROM igc_cc_process_exceptions b
         WHERE b.process_type = l_process_type
           AND b.org_id = l_org_id
           AND b.set_of_books_id = l_sob_id;

   IF p_process_phase = 'F'
   THEN
      /* Deletes Unprocessed lines for Final Phase */
      DELETE FROM igc_cc_process_data a
            WHERE a.process_type = l_process_type
              AND a.process_phase IN ('F', 'P')
              AND (a.processed <> 'Y' OR a.processed IS NULL)
              AND a.org_id = l_org_id
              AND a.set_of_books_id = l_sob_id;
   /* Updates with new Request ID to those which were processed */
/*
        UPDATE IGC_CC_PROCESS_DATA A
        SET    REQUEST_ID          = l_request_id1
        WHERE  A.PROCESS_TYPE      = l_process_type
        AND    A.PROCESS_PHASE     = 'F'
        AND    A.PROCESSED         = 'Y'
        AND    A.ORG_ID            =  l_org_id
        AND    A.SET_OF_BOOKS_ID   =  l_sob_id;
*/
   END IF;

/* This function checks the validity of the user entered parameters and raises exception which
   will end the Process, If successful then continue with the process. */
   IF (g_debug_mode = 'Y')
   THEN
      output_debug
                (l_full_path,
                    ' IGCCMPSB -- ************ Before validating parameters '
                 || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                 || ' *************************'
                );
   END IF;

   igc_cc_mpfs_process_pkg.validate_params (p_process_phase,
                                            l_start_date,
                                            l_end_date,
                                            l_transfer_date,
                                            l_target_date,
                                            l_sob_id,
                                            l_org_id,
                                            l_sbc_on,
                                            l_valid_params,
                                            l_exception
                                           );

   IF (g_debug_mode = 'Y')
   THEN
      output_debug
                 (l_full_path,
                     ' IGCCMPSB -- ************ After validating parameters '
                  || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                  || ' *************************'
                 );
   END IF;

   IF fnd_api.to_boolean (l_valid_params)
   THEN
/* Select the contracts based on the parameters */
/* Selection and Filteration Phase Starts */
      l_exception := NULL;

      IF p_owner IS NOT NULL
      THEN
         OPEN c1 (l_org_id,
                  l_sob_id,
                  p_owner,
                  l_start_date,
                  l_end_date,
                  l_target_date
                 );

         LOOP
            FETCH c1
             INTO v1;

            IF c1%ROWCOUNT = 0
            THEN
               l_exception := NULL;
               fnd_message.set_name ('IGC', 'IGC_CC_NO_RECORD_FOUND');

               IF (g_error_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
               END IF;

               l_exception := fnd_message.get;

               INSERT INTO igc_cc_process_exceptions
                           (process_type, process_phase, cc_header_id,
                            cc_acct_line_id, cc_det_pf_line_id,
                            exception_reason, org_id, set_of_books_id,
                            request_id
                           )
                    VALUES (l_process_type, p_process_phase, NULL,
                            NULL, NULL,
                            l_exception, l_org_id, l_sob_id,
                            l_request_id1
                           );

               l_fail := fnd_api.g_true;
            END IF;

            EXIT WHEN c1%NOTFOUND;

            IF     (v1.tot_unbilled_amt <= p_threshold_value)
               AND p_process_phase = 'F'
            THEN
               BEGIN
                  SELECT cc_header_id
                    INTO l_header_id
                    FROM igc_cc_process_data ccpd
                   WHERE ccpd.cc_header_id = v1.cc_header_id
                     AND ccpd.request_id = l_request_id1;

                  UPDATE igc_cc_process_data ccpd
                     SET old_approval_status = v1.cc_apprvl_status
                   WHERE ccpd.cc_header_id = v1.cc_header_id
                     AND ccpd.org_id = l_org_id
                     AND ccpd.set_of_books_id = l_sob_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     INSERT INTO igc_cc_process_data
                                 (process_type, process_phase,
                                  cc_header_id, validation_status,
                                  reservation_status, processed,
                                  old_approval_status, org_id,
                                  set_of_books_id, validate_only, request_id
                                 )
                          VALUES (l_process_type, p_process_phase,
                                  v1.cc_header_id, 'I',
                                  'F', 'N',
                                  v1.cc_apprvl_status, l_org_id,
                                  l_sob_id, NULL, l_request_id1
                                 );
               END;
            END IF;

            IF     (v1.tot_unbilled_amt <= p_threshold_value)
               AND p_process_phase = 'P'
            THEN
               INSERT INTO igc_cc_process_data
                           (process_type, process_phase,
                            cc_header_id, validation_status,
                            reservation_status, processed,
                            old_approval_status, org_id, set_of_books_id,
                            validate_only, request_id
                           )
                    VALUES (l_process_type, p_process_phase,
                            v1.cc_header_id, 'I',
                            'F', 'N',
                            v1.cc_apprvl_status, l_org_id, l_sob_id,
                            NULL, l_request_id1
                           );
            END IF;
         END LOOP;

         CLOSE c1;
      ELSE
         OPEN c2 (l_org_id, l_sob_id, l_start_date, l_end_date,
                  l_target_date);

         IF (g_debug_mode = 'Y')
         THEN
            output_debug (l_full_path,
                             ' IGCCMPSB -- ************ Open C2 '
                          || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                          || ' *************************'
                         );
         END IF;

         LOOP
            FETCH c2
             INTO v2;

            IF (g_debug_mode = 'Y')
            THEN
               output_debug (l_full_path,
                                ' IGCCMPSB -- ************ After fetch C2 '
                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                             || ' *************************'
                            );
            END IF;

            IF c2%ROWCOUNT = 0
            THEN
               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                          (l_full_path,
                              ' IGCCMPSB -- ************ Zero Rows Selected '
                           || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                           || ' *************************'
                          );
               END IF;

               l_exception := NULL;
               fnd_message.set_name ('IGC', 'IGC_CC_NO_RECORD_FOUND');

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               l_exception := fnd_message.get;

               INSERT INTO igc_cc_process_exceptions
                           (process_type, process_phase, cc_header_id,
                            cc_acct_line_id, cc_det_pf_line_id,
                            exception_reason, org_id, set_of_books_id,
                            request_id
                           )
                    VALUES (l_process_type, p_process_phase, NULL,
                            NULL, NULL,
                            l_exception, l_org_id, l_sob_id,
                            l_request_id1
                           );

               l_fail := fnd_api.g_true;
            END IF;

            EXIT WHEN c2%NOTFOUND;

            IF     (v2.tot_unbilled_amt <= p_threshold_value)
               AND p_process_phase = 'F'
            THEN
               BEGIN
                  SELECT cc_header_id
                    INTO l_header_id
                    FROM igc_cc_process_data ccpd
                   WHERE ccpd.cc_header_id = v2.cc_header_id
                     AND ccpd.request_id = l_request_id1;

                  UPDATE igc_cc_process_data ccpd
                     SET old_approval_status = v2.cc_apprvl_status
                   WHERE ccpd.cc_header_id = v2.cc_header_id
                     AND ccpd.org_id = l_org_id
                     AND ccpd.set_of_books_id = l_sob_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF (g_debug_mode = 'Y')
                     THEN
                        output_debug
                           (l_full_path,
                               ' IGCCMPSB -- ************ Insert data into igc_cc_process_data '
                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                            || ' *************************'
                           );
                     END IF;

                     INSERT INTO igc_cc_process_data
                                 (process_type, process_phase,
                                  cc_header_id, validation_status,
                                  reservation_status, processed,
                                  old_approval_status, org_id,
                                  set_of_books_id, validate_only, request_id
                                 )
                          VALUES (l_process_type, p_process_phase,
                                  v2.cc_header_id, 'I',
                                  'F', 'N',
                                  v2.cc_apprvl_status, l_org_id,
                                  l_sob_id, NULL, l_request_id1
                                 );
               END;
            END IF;

            IF     (v2.tot_unbilled_amt <= p_threshold_value)
               AND p_process_phase = 'P'
            THEN
               INSERT INTO igc_cc_process_data
                           (process_type, process_phase,
                            cc_header_id, validation_status,
                            reservation_status, processed,
                            old_approval_status, org_id, set_of_books_id,
                            validate_only, request_id
                           )
                    VALUES (l_process_type, p_process_phase,
                            v2.cc_header_id, 'I',
                            'F', 'N',
                            v2.cc_apprvl_status, l_org_id, l_sob_id,
                            NULL, l_request_id1
                           );
            END IF;
         END LOOP;

         CLOSE c2;
      END IF;

/* End of Contract Selection and Filteration  */
-- Flag Mark 2
      SELECT COUNT (ROWID)
        INTO l_rec_found
        FROM igc_cc_process_data
       WHERE request_id = l_request_id1
         AND set_of_books_id = l_sob_id
         AND org_id = l_org_id
         AND process_type = l_process_type;

      IF l_rec_found = 0 AND l_exception IS NULL
      THEN
         l_fail := fnd_api.g_true;
         fnd_message.set_name ('IGC', 'IGC_CC_NO_RECORD_FOUND');

         IF (g_excep_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
         END IF;

         l_exception := fnd_message.get;

         INSERT INTO igc_cc_process_exceptions
                     (process_type, process_phase, cc_header_id,
                      cc_acct_line_id, cc_det_pf_line_id, exception_reason,
                      org_id, set_of_books_id, request_id
                     )
              VALUES (l_process_type, p_process_phase, NULL,
                      NULL, NULL, l_exception,
                      l_org_id, l_sob_id, l_request_id1
                     );
      END IF;

      IF p_process_phase = 'P' AND NOT fnd_api.to_boolean (l_fail)
      THEN
         OPEN c4 (l_org_id,
                  l_sob_id,
                  l_request_id1,
                  l_process_type,
                  l_start_date,
                  l_end_date,
                  l_transfer_date
                 );

         LOOP
            FETCH c4
             INTO v4;

            EXIT WHEN c4%NOTFOUND;

            SELECT cc_apprvl_status
              INTO l_previous_apprvl_status
              FROM igc_cc_headers cchd
             WHERE cchd.cc_header_id = v4.cc_header_id;

-- Bug 1632539 Fixed
            IF l_previous_apprvl_status = 'IP'
            THEN
               l_cc_inprocess := fnd_api.g_true;

               BEGIN
                  SELECT 'X'
                    INTO l_dummy
                    FROM igc_cc_process_exceptions
                   WHERE cc_header_id = v4.cc_header_id
                     AND cc_acct_line_id IS NULL
                     AND cc_det_pf_line_id IS NULL
                     AND org_id = l_org_id
                     AND process_type = l_process_type
                     AND process_phase = p_process_phase
                     AND set_of_books_id = l_sob_id
                     AND request_id = l_request_id1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     l_exception := NULL;
                     fnd_message.set_name ('IGC',
                                           'IGC_CC_MPFS_CC_IN_PROCESS');
                     fnd_message.set_token ('NUMBER', v4.cc_num, TRUE);
                     fnd_message.set_token ('PROCESS_TYPE',
                                            l_process_type,
                                            TRUE
                                           );

                     IF (g_excep_level >= g_debug_level)
                     THEN
                        fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
                     END IF;

                     l_exception := fnd_message.get;

                     INSERT INTO igc_cc_process_exceptions
                                 (process_type, process_phase,
                                  cc_header_id, cc_acct_line_id,
                                  cc_det_pf_line_id, exception_reason,
                                  org_id, set_of_books_id, request_id
                                 )
                          VALUES (l_process_type, p_process_phase,
                                  v4.cc_header_id, NULL,
                                  NULL, l_exception,
                                  l_org_id, l_sob_id, l_request_id1
                                 );
               END;
            ELSE
               l_cc_inprocess := fnd_api.g_false;
            END IF;

            IF (v4.cc_det_pf_date > l_transfer_date)
            THEN
-- Bug 1634159 Fixed
               l_cc_period_open :=
                    is_cc_period_open (v4.cc_det_pf_date, l_sob_id, l_org_id);

               IF fnd_api.to_boolean (l_cc_period_open)
               THEN
                  l_source_pf_cc_prd := fnd_api.g_true;

                  IF (g_debug_mode = 'Y')
                  THEN
                     output_debug
                        (l_full_path,
                            ' IGCCMPSB -- ************ Source CC Period Open '
                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                         || ' *************************'
                        );
                  END IF;
               ELSE
                  l_source_pf_cc_prd := fnd_api.g_false;

                  IF (g_debug_mode = 'Y')
                  THEN
                     output_debug
                        (l_full_path,
                            ' IGCCMPSB -- ************ Source CC Period Not Open '
                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                         || ' *************************'
                        );
                  END IF;

                  l_exception := NULL;
                  fnd_message.set_name ('IGC',
                                        'IGC_CC_SOURCE_PF_DT_NOT_CC_PRD'
                                       );
                  fnd_message.set_token ('SOURCE_PF_DT',
                                         TO_CHAR (v4.cc_det_pf_date),
                                         TRUE
                                        );

                  IF (g_excep_level >= g_debug_level)
                  THEN
                     fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
                  END IF;

                  l_exception := fnd_message.get;

                  INSERT INTO igc_cc_process_exceptions
                              (process_type, process_phase,
                               cc_header_id, cc_acct_line_id,
                               cc_det_pf_line_id, exception_reason, org_id,
                               set_of_books_id, request_id
                              )
                       VALUES (l_process_type, p_process_phase,
                               v4.cc_header_id, v4.cc_acct_line_id,
                               v4.cc_det_pf_line_id, l_exception, l_org_id,
                               l_sob_id, l_request_id1
                              );
               END IF;

               IF (l_sbc_on)
               THEN
                  l_gl_period_open :=
                              is_gl_period_open (v4.cc_det_pf_date, l_sob_id);

                  IF fnd_api.to_boolean (l_gl_period_open)
                  THEN
                     l_source_pf_gl_prd := fnd_api.g_true;

                     IF (g_debug_mode = 'Y')
                     THEN
                        output_debug
                           (l_full_path,
                               ' IGCCMPSB -- ************ Source GL Period  Open '
                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                            || ' *************************'
                           );
                     END IF;
                  ELSE
                     l_source_pf_gl_prd := fnd_api.g_false;

                     IF (g_debug_mode = 'Y')
                     THEN
                        output_debug
                           (l_full_path,
                               ' IGCCMPSB -- ************ Source GL Period Not Open '
                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                            || ' *************************'
                           );
                     END IF;

                     l_exception := NULL;
                     fnd_message.set_name ('IGC',
                                           'IGC_CC_SOURCE_PF_DT_NOT_OPEN'
                                          );
                     fnd_message.set_token ('SOURCE_PF_DT',
                                            TO_CHAR (v4.cc_det_pf_date),
                                            TRUE
                                           );

                     IF (g_excep_level >= g_debug_level)
                     THEN
                        fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
                     END IF;

                     l_exception := fnd_message.get;

                     INSERT INTO igc_cc_process_exceptions
                                 (process_type, process_phase,
                                  cc_header_id, cc_acct_line_id,
                                  cc_det_pf_line_id, exception_reason,
                                  org_id, set_of_books_id, request_id
                                 )
                          VALUES (l_process_type, p_process_phase,
                                  v4.cc_header_id, v4.cc_acct_line_id,
                                  v4.cc_det_pf_line_id, l_exception,
                                  l_org_id, l_sob_id, l_request_id1
                                 );
                  END IF;
               END IF;
            END IF;

            OPEN c7 (v4.cc_acct_line_id, l_target_date, v4.cc_header_id);

            FETCH c7
             INTO v7;

            IF c7%ROWCOUNT = 0
            THEN
               l_target_pf_found := fnd_api.g_false;

               BEGIN
                  SELECT 'X'
                    INTO l_dummy
                    FROM igc_cc_process_exceptions
                   WHERE cc_header_id = v4.cc_header_id
                     AND cc_acct_line_id = v4.cc_acct_line_id
                     AND cc_det_pf_line_id IS NULL
                     AND org_id = l_org_id
                     AND process_type = l_process_type
                     AND process_phase = p_process_phase
                     AND set_of_books_id = l_sob_id
                     AND request_id = l_request_id1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     l_exception := NULL;
                     fnd_message.set_name ('IGC',
                                           'IGC_CC_MPFS_TGT_PF_NOT_FOUND'
                                          );
                     fnd_message.set_token ('CC_NUM', v4.cc_num, TRUE);

                     IF (g_excep_level >= g_debug_level)
                     THEN
                        fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
                     END IF;

                     l_exception := fnd_message.get;

                     INSERT INTO igc_cc_process_exceptions
                                 (process_type, process_phase,
                                  cc_header_id, cc_acct_line_id,
                                  cc_det_pf_line_id, exception_reason,
                                  org_id, set_of_books_id, request_id
                                 )
                          VALUES (l_process_type, p_process_phase,
                                  v4.cc_header_id, v4.cc_acct_line_id,
                                  NULL, l_exception,
                                  l_org_id, l_sob_id, l_request_id1
                                 );
               END;
            ELSE
-- Bug 1634159 Fixed
               l_target_pf_found := fnd_api.g_true;
               l_tgt_cc_open :=
                    is_cc_period_open (v7.cc_det_pf_date, l_sob_id, l_org_id);

               IF fnd_api.to_boolean (l_tgt_cc_open)
               THEN
                  l_tgt_cc_open := fnd_api.g_true;
               ELSE
                  l_tgt_cc_open := fnd_api.g_false;

                  BEGIN
                     SELECT 'X'
                       INTO l_dummy
                       FROM igc_cc_process_exceptions
                      WHERE cc_header_id = v4.cc_header_id
                        AND cc_acct_line_id = v4.cc_acct_line_id
                        AND cc_det_pf_line_id = v7.cc_det_pf_line_id
                        AND org_id = l_org_id
                        AND process_type = l_process_type
                        AND process_phase = p_process_phase
                        AND set_of_books_id = l_sob_id
                        AND request_id = l_request_id1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_exception := NULL;
                        fnd_message.set_name
                                            ('IGC',
                                             'IGC_CC_TARGET_PF_DT_NOT_CC_PRD'
                                            );
                        fnd_message.set_token ('TARGET_PF_DT',
                                               TO_CHAR (v7.cc_det_pf_date),
                                               TRUE
                                              );

                        IF (g_excep_level >= g_debug_level)
                        THEN
                           fnd_log.MESSAGE (g_excep_level, l_full_path,
                                            FALSE);
                        END IF;

                        l_exception := fnd_message.get;

                        INSERT INTO igc_cc_process_exceptions
                                    (process_type, process_phase,
                                     cc_header_id, cc_acct_line_id,
                                     cc_det_pf_line_id, exception_reason,
                                     org_id, set_of_books_id, request_id
                                    )
                             VALUES (l_process_type, p_process_phase,
                                     v4.cc_header_id, v4.cc_acct_line_id,
                                     v7.cc_det_pf_line_id, l_exception,
                                     l_org_id, l_sob_id, l_request_id1
                                    );
                  END;
               END IF;

-- Bug 1634218 Fixed
               l_tgt_gl_open :=
                               is_gl_period_open (v7.cc_det_pf_date, l_sob_id);

               IF fnd_api.to_boolean (l_tgt_gl_open)
               THEN
                  l_tgt_gl_open := fnd_api.g_true;
               ELSE
                  l_tgt_gl_open := fnd_api.g_false;

                  BEGIN
                     SELECT 'X'
                       INTO l_dummy
                       FROM igc_cc_process_exceptions
                      WHERE cc_header_id = v4.cc_header_id
                        AND cc_acct_line_id = v4.cc_acct_line_id
                        AND cc_det_pf_line_id = v7.cc_det_pf_line_id
                        AND org_id = l_org_id
                        AND process_type = l_process_type
                        AND process_phase = p_process_phase
                        AND set_of_books_id = l_sob_id
                        AND request_id = l_request_id1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_exception := NULL;
                        fnd_message.set_name
                                            ('IGC',
                                             'IGC_CC_TARGET_PF_DT_NOT_GL_PRD'
                                            );
                        fnd_message.set_token ('TARGET_PF_DT',
                                               TO_CHAR (v7.cc_det_pf_date),
                                               TRUE
                                              );

                        IF (g_excep_level >= g_debug_level)
                        THEN
                           fnd_log.MESSAGE (g_excep_level, l_full_path,
                                            FALSE);
                        END IF;

                        l_exception := fnd_message.get;

                        INSERT INTO igc_cc_process_exceptions
                                    (process_type, process_phase,
                                     cc_header_id, cc_acct_line_id,
                                     cc_det_pf_line_id, exception_reason,
                                     org_id, set_of_books_id, request_id
                                    )
                             VALUES (l_process_type, p_process_phase,
                                     v4.cc_header_id, v4.cc_acct_line_id,
                                     v7.cc_det_pf_line_id, l_exception,
                                     l_org_id, l_sob_id, l_request_id1
                                    );
                  END;
               END IF;
            END IF;

            CLOSE c7;

/*

         BEGIN
         SELECT 'X'
         INTO l_DUMMY
         FROM  igc_cc_process_exceptions
         WHERE cc_header_id = V4.cc_header_id
         AND   cc_acct_line_id  IS NULL
         AND   org_id = l_org_id
         AND   process_type = l_process_type
         AND   process_phase = p_process_phase
         AND   set_of_books_id = l_sob_id
         AND   request_id = l_request_id1;

         l_target_pf_found := FND_API.G_FALSE;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
         OPEN C6(V4.cc_header_id,l_target_date,l_org_id,l_sob_id);
         FETCH C6 INTO V6;
         IF C6%ROWCOUNT=0 THEN
            l_target_pf_found := FND_API.G_FALSE;
                        l_EXCEPTION := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_TGT_PF_NOT_FOUND');
                        FND_MESSAGE.SET_TOKEN('CC_NUM',V4.cc_num,TRUE);
                        l_EXCEPTION  := FND_MESSAGE.GET;
                        INSERT INTO igc_cc_process_exceptions
                      (PROCESS_TYPE      ,
                      PROCESS_PHASE     ,
                      CC_HEADER_ID      ,
                      CC_ACCT_LINE_ID   ,
                      CC_DET_PF_LINE_ID ,
                      EXCEPTION_REASON  ,
                      ORG_ID            ,
                      SET_OF_BOOKS_ID   ,
                      REQUEST_ID        )
                      values    (l_process_type,
                                                                        p_process_phase,
                                                                        V4.cc_header_id,
                                                                        NULL,
                                                                        NULL,
                                                                        l_EXCEPTION,
                                                                        l_org_id,
                                                                        l_sob_id,
                           l_request_id1);


         ELSE
            l_target_pf_found := FND_API.G_TRUE;
         END IF;

         CLOSE C6;
         END;
*/

            /* Changed  FND_API.TO_BOOLEAN(l_cc_inprocess) to NOT NOT FND_API.TO_BOOLEAN(l_cc_inprocess) in the following
                    Statement to fix bug  1689697 */
            IF     fnd_api.to_boolean (l_source_pf_cc_prd)
               AND fnd_api.to_boolean (l_source_pf_gl_prd)
               AND fnd_api.to_boolean (l_target_pf_found)
               AND NOT fnd_api.to_boolean (l_cc_inprocess)
               AND fnd_api.to_boolean (l_tgt_gl_open)
            THEN
               UPDATE igc_cc_process_data ccpd
                  SET ccpd.validation_status = 'P'
                WHERE ccpd.cc_header_id = v4.cc_header_id
                  AND ccpd.org_id = l_org_id
                  AND ccpd.set_of_books_id = l_sob_id
                  AND ccpd.request_id = l_request_id1
                  AND ccpd.process_type = l_process_type;
            ELSE
               l_fail := fnd_api.g_true;

               UPDATE igc_cc_process_data ccpd
                  SET ccpd.validation_status = 'F'
                WHERE ccpd.cc_header_id = v4.cc_header_id
                  AND ccpd.org_id = l_org_id
                  AND ccpd.set_of_books_id = l_sob_id
                  AND ccpd.request_id = l_request_id1
                  AND ccpd.process_type = l_process_type;
            END IF;
         END LOOP;

         CLOSE c4;
      END IF;

-- Mark Flag 1;
      COMMIT;

      IF (g_debug_mode = 'Y')
      THEN
         output_debug (l_full_path,
                          ' IGCCMPSB -- ************ Before lock CC and PO '
                       || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                       || ' *************************'
                      );
      END IF;

/* Locking CC and PO phase starts */
      IF p_process_phase = 'F' AND NOT fnd_api.to_boolean (l_fail)
      THEN
         OPEN c4_1 (l_org_id,
                   l_sob_id,
                   l_request_id1,
                   l_process_type
                   );

         LOOP
            IF (g_debug_mode = 'Y')
            THEN
               output_debug (l_full_path,
                                ' IGCCMPSB -- ************ Open C4 '
                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                             || ' *************************'
                            );
            END IF;

            FETCH c4_1
             INTO v4_1;

            EXIT WHEN c4_1%NOTFOUND;

            SELECT cc_num
              INTO l_cc_num
              FROM igc_cc_headers
             WHERE cc_header_id = v4_1.cc_header_id;

            IF (g_debug_mode = 'Y')
            THEN
               output_debug (l_full_path,
                                ' IGCCMPSB -- ************ Lock CC '
                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                             || ' *************************'
                            );
            END IF;

            l_lock_cc_status := igc_cc_rep_yep_pvt.lock_cc (v4_1.cc_header_id);

            IF l_lock_cc_status = FALSE
            THEN
               l_exception := NULL;
               fnd_message.set_name ('IGC', 'IGC_CC_MPFS_CC_LOCKED');
               fnd_message.set_token ('CC_NUMBER', l_cc_num, TRUE);

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               l_exception := fnd_message.get;

               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                     (l_full_path,
                         ' IGCCMPSB -- ************ Before Insert lock exception  '
                      || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                      || ' *************************'
                     );
               END IF;

               INSERT INTO igc_cc_process_exceptions
                           (process_type, process_phase, cc_header_id,
                            cc_acct_line_id, cc_det_pf_line_id,
                            exception_reason, org_id, set_of_books_id,
                            request_id
                           )
                    VALUES (l_process_type, p_process_phase, v4_1.cc_header_id,
                            NULL, NULL,
                            l_exception, l_org_id, l_sob_id,
                            l_request_id1
                           );

               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                     (l_full_path,
                         ' IGCCMPSB -- ************ After Insert lock exception  '
                      || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                      || ' *************************'
                     );
               END IF;
            END IF;

            IF (g_debug_mode = 'Y')
            THEN
               output_debug (l_full_path,
                                ' IGCCMPSB -- ************ Before PO Lock  '
                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                             || ' *************************'
                            );
            END IF;

            l_lock_po_status := igc_cc_rep_yep_pvt.lock_po (v4_1.cc_header_id);

            IF l_lock_po_status = FALSE
            THEN
               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                     (l_full_path,
                         ' IGCCMPSB -- ************ Before Insert PO Lock Exception  '
                      || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                      || ' *************************'
                     );
               END IF;

               l_exception := NULL;
               fnd_message.set_name ('IGC', 'IGC_CC_MPFS_PO_LOCKED');
               fnd_message.set_token ('CC_NUMBER', l_cc_num, TRUE);

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               l_exception := fnd_message.get;

               INSERT INTO igc_cc_process_exceptions
                           (process_type, process_phase, cc_header_id,
                            cc_acct_line_id, cc_det_pf_line_id,
                            exception_reason, org_id, set_of_books_id,
                            request_id
                           )
                    VALUES (l_process_type, p_process_phase, v4_1.cc_header_id,
                            NULL, NULL,
                            l_exception, l_org_id, l_sob_id,
                            l_request_id1
                           );

               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                     (l_full_path,
                         ' IGCCMPSB -- ************ After Insert PO Lock Exception  '
                      || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                      || ' *************************'
                     );
               END IF;
            END IF;

            IF     l_lock_po_status = TRUE
               AND l_lock_cc_status = TRUE
               AND p_process_phase = 'F'
            THEN
/*Check for the period open for the date at which the source lines are getting liquidated.*/
/* Validation Phase Starts */
               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                     (l_full_path,
                         ' IGCCMPSB -- ************ Update IGC_Process_Data  After successful Lock'
                      || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                      || ' *************************'
                     );
               END IF;

               SELECT cc_apprvl_status
                 INTO l_previous_apprvl_status
                 FROM igc_cc_headers cchd
                WHERE cchd.cc_header_id = v4_1.cc_header_id;

-- Bug 1632539 Fixed
               IF l_previous_apprvl_status = 'IP'
               THEN
                  l_cc_inprocess := fnd_api.g_true;

                  BEGIN
                     SELECT 'X'
                       INTO l_dummy
                       FROM igc_cc_process_exceptions
                      WHERE cc_header_id = v4_1.cc_header_id
                        AND cc_acct_line_id IS NULL
                        AND cc_det_pf_line_id IS NULL
                        AND org_id = l_org_id
                        AND process_type = l_process_type
                        AND process_phase = p_process_phase
                        AND set_of_books_id = l_sob_id
                        AND request_id = l_request_id1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_exception := NULL;
                        fnd_message.set_name ('IGC',
                                              'IGC_CC_MPFS_CC_IN_PROCESS'
                                             );
                        fnd_message.set_token ('NUMBER', v4_1.cc_num, TRUE);
                        fnd_message.set_token ('PROCESS_TYPE',
                                               l_process_type,
                                               TRUE
                                              );

                        IF (g_excep_level >= g_debug_level)
                        THEN
                           fnd_log.MESSAGE (g_excep_level, l_full_path,
                                            FALSE);
                        END IF;

                        l_exception := fnd_message.get;

                        INSERT INTO igc_cc_process_exceptions
                                    (process_type, process_phase,
                                     cc_header_id, cc_acct_line_id,
                                     cc_det_pf_line_id, exception_reason,
                                     org_id, set_of_books_id, request_id
                                    )
                             VALUES (l_process_type, p_process_phase,
                                     v4_1.cc_header_id, NULL,
                                     NULL, l_exception,
                                     l_org_id, l_sob_id, l_request_id1
                                    );
                  END;
               ELSE
                  l_cc_inprocess := fnd_api.g_false;
               END IF;


               IF NOT fnd_api.to_boolean (l_cc_inprocess) THEN
                  OPEN c4_2 (v4_1.cc_header_id,
                             l_start_date,
                   			 l_end_date,
                   			 l_transfer_date);
                  LOOP
                   	 FETCH c4_2 INTO v4_2;
                   	 EXIT WHEN c4_2%NOTFOUND;

		               IF (v4_2.cc_det_pf_date > l_transfer_date)
		               THEN
		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                        (l_full_path,
		                            ' IGCCMPSB -- ************ Before CC Period Validation'
		                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                         || ' *************************'
		                        );
		                  END IF;

		-- Bug 1634159 Fixed
		                  l_cc_period_open :=
		                     is_cc_period_open (v4_2.cc_det_pf_date, l_sob_id, l_org_id);

		                  IF fnd_api.to_boolean (l_cc_period_open)
		                  THEN
		                     l_source_pf_cc_prd := fnd_api.g_true;

		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Source CC Period Open '
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;
		                  ELSE
		                     l_source_pf_cc_prd := fnd_api.g_false;

		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Source CC Period Not Open '
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;

		                     l_exception := NULL;
		                     fnd_message.set_name ('IGC',
		                                           'IGC_CC_SOURCE_PF_DT_NOT_CC_PRD'
		                                          );
		                     fnd_message.set_token ('SOURCE_PF_DT',
		                                            TO_CHAR (v4_2.cc_det_pf_date),
		                                            TRUE
		                                           );
		                     l_exception := fnd_message.get;

		                     INSERT INTO igc_cc_process_exceptions
		                                 (process_type, process_phase,
		                                  cc_header_id, cc_acct_line_id,
		                                  cc_det_pf_line_id, exception_reason,
		                                  org_id, set_of_books_id, request_id
		                                 )
		                          VALUES (l_process_type, p_process_phase,
		                                  v4.cc_header_id, v4.cc_acct_line_id,
		                                  v4.cc_det_pf_line_id, l_exception,
		                                  l_org_id, l_sob_id, l_request_id1
		                                 );
		                  END IF;

		                  IF (l_sbc_on)
		                  THEN
		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Before GL Period Validation'
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;

		                     l_gl_period_open :=
		                               is_gl_period_open (v4_2.cc_det_pf_date, l_sob_id);

		                     IF fnd_api.to_boolean (l_gl_period_open)
		                     THEN
		                        l_source_pf_gl_prd := fnd_api.g_true;

		                        IF (g_debug_mode = 'Y')
		                        THEN
		                           output_debug
		                              (l_full_path,
		                                  ' IGCCMPSB -- ************ Source GL Period  Open '
		                               || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                               || ' *************************'
		                              );
		                        END IF;
		                     ELSE
		                        l_source_pf_gl_prd := fnd_api.g_false;

		                        IF (g_debug_mode = 'Y')
		                        THEN
		                           output_debug
		                              (l_full_path,
		                                  ' IGCCMPSB -- ************ Source GL Period  Not Open '
		                               || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                               || ' *************************'
		                              );
		                        END IF;

		                        l_exception := NULL;
		                        fnd_message.set_name ('IGC',
		                                              'IGC_CC_SOURCE_PF_DT_NOT_OPEN'
		                                             );
		                        fnd_message.set_token ('SOURCE_PF_DT',
		                                               TO_CHAR (v4_2.cc_det_pf_date),
		                                               TRUE
		                                              );

		                        IF (g_excep_level >= g_debug_level)
		                        THEN
		                           fnd_log.MESSAGE (g_excep_level, l_full_path,
		                                            FALSE);
		                        END IF;

		                        l_exception := fnd_message.get;

		                        INSERT INTO igc_cc_process_exceptions
		                                    (process_type, process_phase,
		                                     cc_header_id, cc_acct_line_id,
		                                     cc_det_pf_line_id, exception_reason,
		                                     org_id, set_of_books_id, request_id
		                                    )
		                             VALUES (l_process_type, p_process_phase,
		                                     v4_1.cc_header_id, v4_2.cc_acct_line_id,
		                                     v4_2.cc_det_pf_line_id, l_exception,
		                                     l_org_id, l_sob_id, l_request_id1
		                                    );
		                     END IF;
		                  END IF;
		               END IF;

		               OPEN c7 (v4_2.cc_acct_line_id, l_target_date, v4_1.cc_header_id);

		               IF (g_debug_mode = 'Y')
		               THEN
		                  output_debug (l_full_path,
		                                   ' IGCCMPSB -- ************ Open C7'
		                                || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                                || ' *************************'
		                               );
		               END IF;

		               FETCH c7
		                INTO v7;

		               IF c7%ROWCOUNT = 0
		               THEN
		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                            (l_full_path,
		                                ' IGCCMPSB -- ************No Target PF Found'
		                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                             || ' *************************'
		                            );
		                  END IF;

		                  l_target_pf_found := fnd_api.g_false;

		                  BEGIN
		                     SELECT 'X'
		                       INTO l_dummy
		                       FROM igc_cc_process_exceptions
		                      WHERE cc_header_id = v4_1.cc_header_id
		                        AND cc_acct_line_id = v4_2.cc_acct_line_id
		                        AND cc_det_pf_line_id IS NULL
		                        AND org_id = l_org_id
		                        AND process_type = l_process_type
		                        AND process_phase = p_process_phase
		                        AND set_of_books_id = l_sob_id
		                        AND request_id = l_request_id1;
		                  EXCEPTION
		                     WHEN NO_DATA_FOUND
		                     THEN
		                        l_exception := NULL;
		                        fnd_message.set_name ('IGC',
		                                              'IGC_CC_MPFS_TGT_PF_NOT_FOUND'
		                                             );
		                        fnd_message.set_token ('CC_NUM', v4_1.cc_num, TRUE);

		                        IF (g_excep_level >= g_debug_level)
		                        THEN
		                           fnd_log.MESSAGE (g_excep_level, l_full_path,
		                                            FALSE);
		                        END IF;

		                        l_exception := fnd_message.get;

		                        INSERT INTO igc_cc_process_exceptions
		                                    (process_type, process_phase,
		                                     cc_header_id, cc_acct_line_id,
		                                     cc_det_pf_line_id, exception_reason,
		                                     org_id, set_of_books_id, request_id
		                                    )
		                             VALUES (l_process_type, p_process_phase,
		                                     v4_1.cc_header_id, v4_2.cc_acct_line_id,
		                                     NULL, l_exception,
		                                     l_org_id, l_sob_id, l_request_id1
		                                    );
		                  END;
		               ELSE
		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                              (l_full_path,
		                                  ' IGCCMPSB -- ************ Target PF Found'
		                               || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                               || ' *************************'
		                              );
		                  END IF;

		-- Bug 1634159 Fixed
		                  l_target_pf_found := fnd_api.g_true;

		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                        (l_full_path,
		                            ' IGCCMPSB -- ************ Check CC Period Status of target PF'
		                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                         || ' *************************'
		                        );
		                  END IF;

		                  l_tgt_cc_open :=
		                     is_cc_period_open (v7.cc_det_pf_date, l_sob_id, l_org_id);

		                  IF fnd_api.to_boolean (l_tgt_cc_open)
		                  THEN
		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Target PF CC Period Open'
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;

		                     l_tgt_cc_open := fnd_api.g_true;
		                  ELSE
		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Target PF CC Period Not Open'
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;

		                     l_tgt_cc_open := fnd_api.g_false;

		                     BEGIN
		                        SELECT 'X'
		                          INTO l_dummy
		                          FROM igc_cc_process_exceptions
		                         WHERE cc_header_id = v4_1.cc_header_id
		                           AND cc_acct_line_id = v4_2.cc_acct_line_id
		                           AND cc_det_pf_line_id = v7.cc_det_pf_line_id
		                           AND org_id = l_org_id
		                           AND process_type = l_process_type
		                           AND process_phase = p_process_phase
		                           AND set_of_books_id = l_sob_id
		                           AND request_id = l_request_id1;
		                     EXCEPTION
		                        WHEN NO_DATA_FOUND
		                        THEN
		                           l_exception := NULL;
		                           fnd_message.set_name
		                                            ('IGC',
		                                             'IGC_CC_TARGET_PF_DT_NOT_CC_PRD'
		                                            );
		                           fnd_message.set_token ('TARGET_PF_DT',
		                                                  TO_CHAR (v7.cc_det_pf_date),
		                                                  TRUE
		                                                 );

		                           IF (g_excep_level >= g_debug_level)
		                           THEN
		                              fnd_log.MESSAGE (g_excep_level,
		                                               l_full_path,
		                                               FALSE
		                                              );
		                           END IF;

		                           l_exception := fnd_message.get;

		                           INSERT INTO igc_cc_process_exceptions
		                                       (process_type, process_phase,
		                                        cc_header_id, cc_acct_line_id,
		                                        cc_det_pf_line_id, exception_reason,
		                                        org_id, set_of_books_id, request_id
		                                       )
		                                VALUES (l_process_type, p_process_phase,
		                                        v4_1.cc_header_id, v4_2.cc_acct_line_id,
		                                        v7.cc_det_pf_line_id, l_exception,
		                                        l_org_id, l_sob_id, l_request_id1
		                                       );
		                     END;
		                  END IF;

		-- Bug 1634218 Fixed
		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                        (l_full_path,
		                            ' IGCCMPSB -- ************ Check GL Period Status of target PF'
		                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                         || ' *************************'
		                        );
		                  END IF;

		                  l_tgt_gl_open :=
		                               is_gl_period_open (v7.cc_det_pf_date, l_sob_id);

		                  IF fnd_api.to_boolean (l_tgt_gl_open)
		                  THEN
		                     l_tgt_gl_open := fnd_api.g_true;

		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Target GL Period Open '
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;
		                  ELSE
		                     IF (g_debug_mode = 'Y')
		                     THEN
		                        output_debug
		                           (l_full_path,
		                               ' IGCCMPSB -- ************ Target GL Period Closed  '
		                            || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                            || ' *************************'
		                           );
		                     END IF;

		                     l_tgt_gl_open := fnd_api.g_false;

		                     BEGIN
		                        SELECT 'X'
		                          INTO l_dummy
		                          FROM igc_cc_process_exceptions
		                         WHERE cc_header_id = v4_1.cc_header_id
		                           AND cc_acct_line_id = v4_2.cc_acct_line_id
		                           AND cc_det_pf_line_id = v7.cc_det_pf_line_id
		                           AND org_id = l_org_id
		                           AND process_type = l_process_type
		                           AND process_phase = p_process_phase
		                           AND set_of_books_id = l_sob_id
		                           AND request_id = l_request_id1;
		                     EXCEPTION
		                        WHEN NO_DATA_FOUND
		                        THEN
		                           l_exception := NULL;
		                           fnd_message.set_name
		                                            ('IGC',
		                                             'IGC_CC_TARGET_PF_DT_NOT_GL_PRD'
		                                            );
		                           fnd_message.set_token ('TARGET_PF_DT',
		                                                  TO_CHAR (v7.cc_det_pf_date),
		                                                  TRUE
		                                                 );

		                           IF (g_excep_level >= g_debug_level)
		                           THEN
		                              fnd_log.MESSAGE (g_excep_level,
		                                               l_full_path,
		                                               FALSE
		                                              );
		                           END IF;

		                           l_exception := fnd_message.get;

		                           INSERT INTO igc_cc_process_exceptions
		                                       (process_type, process_phase,
		                                        cc_header_id, cc_acct_line_id,
		                                        cc_det_pf_line_id, exception_reason,
		                                        org_id, set_of_books_id, request_id
		                                       )
		                                VALUES (l_process_type, p_process_phase,
		                                        v4_1.cc_header_id, v4_2.cc_acct_line_id,
		                                        v7.cc_det_pf_line_id, l_exception,
		                                        l_org_id, l_sob_id, l_request_id1
		                                       );
		                     END;
		                  END IF;
		               END IF;

		               CLOSE c7;

		/*

		         BEGIN
		         SELECT 'X'
		         INTO l_DUMMY
		         FROM  igc_cc_process_exceptions
		         WHERE cc_header_id = V4.cc_header_id
		         AND   cc_acct_line_id  IS NULL
		         AND   org_id = l_org_id
		         AND   process_type = l_process_type
		         AND   process_phase = p_process_phase
		         AND   set_of_books_id = l_sob_id
		         AND   request_id = l_request_id1;

		         l_target_pf_found := FND_API.G_FALSE;

		         EXCEPTION
		         WHEN NO_DATA_FOUND THEN
		         OPEN C6(V4.cc_header_id,l_target_date,l_org_id,l_sob_id);
		         FETCH C6 INTO V6;
		         IF C6%ROWCOUNT=0 THEN
		            l_target_pf_found := FND_API.G_FALSE;
		                        l_EXCEPTION := NULL;
		                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_MPFS_TGT_PF_NOT_FOUND');
		                        FND_MESSAGE.SET_TOKEN('CC_NUM',V4.cc_num,TRUE);
		                        l_EXCEPTION  := FND_MESSAGE.GET;
		                        INSERT INTO igc_cc_process_exceptions
		                      (PROCESS_TYPE      ,
		                      PROCESS_PHASE     ,
		                      CC_HEADER_ID      ,
		                      CC_ACCT_LINE_ID   ,
		                      CC_DET_PF_LINE_ID ,
		                      EXCEPTION_REASON  ,
		                      ORG_ID            ,
		                      SET_OF_BOOKS_ID   ,
		                      REQUEST_ID        )
		                     values    (l_process_type,
		                                                                        p_process_phase,
		                                                                        V4.cc_header_id,
		                                                                        NULL,
		                                                                        NULL,
		                                                                        l_EXCEPTION,
		                                                                        l_org_id,
		                                                                        l_sob_id,
		                           l_request_id1);


		         ELSE
		            l_target_pf_found := FND_API.G_TRUE;
		         END IF;

		         CLOSE C6;
		         END;
		*/

		               /* Changed  FND_API.TO_BOOLEAN(l_cc_inprocess) to NOT NOT FND_API.TO_BOOLEAN(l_cc_inprocess) in the following
		                       Statement to fix bug  1689697 */
		               IF     fnd_api.to_boolean (l_source_pf_cc_prd)
		                  AND fnd_api.to_boolean (l_source_pf_gl_prd)
		                  AND fnd_api.to_boolean (l_target_pf_found)
		                  AND NOT fnd_api.to_boolean (l_cc_inprocess)
		                  AND fnd_api.to_boolean (l_tgt_gl_open)
		               THEN
		                  IF (g_debug_mode = 'Y')
		                  THEN
		                     output_debug
		                        (l_full_path,
		                            ' IGCCMPSB -- ************ Successfull CC Validation '
		                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
		                         || ' *************************'
		                        );
		                  END IF;

		                  UPDATE igc_cc_process_data ccpd
		                     SET ccpd.validation_status = 'P'
		                   WHERE ccpd.cc_header_id = v4_1.cc_header_id
		                     AND ccpd.org_id = l_org_id
		                     AND ccpd.set_of_books_id = l_sob_id
		                     AND ccpd.request_id = l_request_id1
		                     AND ccpd.process_type = l_process_type;

		/* If contract passes the validation phase then change the status to IN-PROCESS */
		                  UPDATE igc_cc_headers cchd
		       	  		  SET cchd.cc_apprvl_status = 'IP'
		       	  		  WHERE cchd.cc_header_id = v4.cc_header_id;

		/*Change PO Status */
		                  IF l_previous_apprvl_status = 'AP'
		                  THEN
		                     BEGIN
		                                            -- Performance Tuning
		                                            -- Replaced the following select with the one below
		                        -- SELECT   'Y'
		                        -- INTO  l_DUMMY
		                        -- FROM  po_headers pha1
		                        -- WHERE pha1.po_header_id =  (SELECT pha2.po_header_id
		                        --             FROM  igc_cc_headers cchd,
		                        --                po_headers pha2
		                        --             WHERE cchd.org_id = l_org_id
		                        --             AND   cchd.cc_header_id = V4.cc_header_id
		                        --             AND   cchd.cc_num = pha2.segment1
		                        --             AND   pha2.type_lookup_code = 'STANDARD');
		                        SELECT 'Y'
		                          INTO l_dummy
		                          FROM po_headers_all pha1, igc_cc_headers cchd
		                         WHERE cchd.org_id = l_org_id
		                           AND cchd.cc_header_id = v4_1.cc_header_id
		                           AND cchd.cc_num = pha1.segment1
		                           AND pha1.type_lookup_code = 'STANDARD'
		                           AND pha1.org_id = l_org_id;

		                                            -- Performance Tuning
		                                            -- Replaced the following update with the one below
		                        -- UPDATE   po_headers pha1
		                        -- SET   pha1.approved_flag = 'N'
		                        -- WHERE (pha1.segment1,pha1.org_id,pha1.type_lookup_code) IN
		                        -- (SELECT pha2.segment1,pha2.org_id,pha2.type_lookup_code
		                        -- FROM  po_headers pha2, igc_cc_headers cchd
		                        -- WHERE cchd.cc_header_id = V4.cc_header_id
		                        -- AND   pha2.segment1 = cchd.cc_num
		                        -- AND   pha2.org_id = cchd.org_id
		                        -- AND   pha2.type_lookup_code = 'STANDARD');
		                        UPDATE po_headers_all pha1
		                           SET pha1.approved_flag = 'N'
		                         WHERE pha1.type_lookup_code = 'STANDARD'
		                           AND pha1.org_id = l_org_id
		                           AND pha1.segment1 =
		                                  (SELECT cchd.cc_num
		                                     FROM igc_cc_headers cchd
		                                    WHERE cchd.cc_header_id = v4_1.cc_header_id);
		                     EXCEPTION
		                        WHEN NO_DATA_FOUND
		                        THEN
		                           NULL;
		                     END;
		                  END IF;
		               ELSE
		                  l_fail := fnd_api.g_true;

		                  UPDATE igc_cc_process_data ccpd
		                     SET ccpd.validation_status = 'L'
		                   WHERE ccpd.cc_header_id = v4_1.cc_header_id
		                     AND ccpd.org_id = l_org_id
		                     AND ccpd.set_of_books_id = l_sob_id
		                     AND ccpd.request_id = l_request_id1
		                     AND ccpd.process_type = l_process_type;
		               END IF;
					END LOOP;
					CLOSE c4_2;
				END IF;
            ELSE
               l_fail := fnd_api.g_true;
            -- This ends the lock on PO and CC
            END IF;
         END LOOP;

         CLOSE c4_1;

-- Mark Flag 2;
         COMMIT;

         IF (g_debug_mode = 'Y')
         THEN
            output_debug
                        (l_full_path,
                            ' IGCCMPSB -- ************ After lock CC and PO '
                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                         || ' *************************'
                        );
         END IF;

         OPEN c5;

         LOOP
            FETCH c5
             INTO v5;

            EXIT WHEN c5%NOTFOUND;

            IF (g_debug_mode = 'Y')
            THEN
               output_debug (l_full_path,
                                ' IGCCMPSB -- ************ Before encumber '
                             || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                             || ' *************************'
                            );
            END IF;

            IF (l_sbc_on = TRUE AND l_conf_enc_on = TRUE)
            THEN
               l_result_of_reservation :=
                  igc_cc_mpfs_process_pkg.encumber_cc
                                                (l_currency_code,
                                                 v5.cc_header_id,
                                                 l_sbc_on,
/*Bug No : 6341012. SLA Uptake. Encumbrance Type IDs are not required */
		--                              l_purch_encumbrance_type_id,
                                                 l_start_date,
                                                 l_end_date,
                                                 l_transfer_date,
                                                 l_target_date
                                                );

               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                              (l_full_path,
                                  ' IGCCMPSB -- ************ After encumber '
                               || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                               || ' *************************'
                              );
               END IF;
            ELSE
               l_result_of_reservation := 'P';
            END IF;

            IF l_result_of_reservation = 'P'
            THEN
               UPDATE igc_cc_process_data ccpd
                  SET ccpd.reservation_status = 'P'
                WHERE ccpd.cc_header_id = v5.cc_header_id
                  AND ccpd.request_id = l_request_id1;

               COMMIT;
               SAVEPOINT s2;

               /* Call mpfs Update */
               IF (g_debug_mode = 'Y')
               THEN
                  output_debug (l_full_path,
                                   ' IGCCMPSB -- ************ Before Update '
                                || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                                || ' *************************'
                               );
               END IF;

               l_result_mpfs_update :=
                  mpfs_update (v5.cc_header_id,
                               l_request_id1,
                               l_sob_id,
                               l_org_id,
                               l_start_date,
                               l_end_date,
                               l_target_date,
                               l_transfer_date,
                               l_err_mesg
                              );

               IF (g_debug_mode = 'Y')
               THEN
                  output_debug (l_full_path,
                                   ' IGCCMPSB -- ************ After Update '
                                || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                                || ' *************************'
                               );
               END IF;

               IF (l_result_mpfs_update = 'F')
               THEN
                  IF (g_debug_mode = 'Y')
                  THEN
                     output_debug
                             (l_full_path,
                                 ' IGCCMPSB -- ************  Update Failure '
                              || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                              || ' *************************'
                             );
                  END IF;

                  ROLLBACK TO s2;

                  INSERT INTO igc_cc_process_exceptions
                              (process_type, process_phase,
                               cc_header_id, cc_acct_line_id,
                               cc_det_pf_line_id, exception_reason, org_id,
                               set_of_books_id, request_id
                              )
                       VALUES (l_process_type, p_process_phase,
                               v5.cc_header_id, NULL,
                               NULL, l_err_mesg, l_org_id,
                               l_sob_id, l_request_id1
                              );
               END IF;
            ELSE
               IF (g_debug_mode = 'Y')
               THEN
                  output_debug
                        (l_full_path,
                            ' IGCCMPSB -- ************  Encumbrance Failure '
                         || TO_CHAR (SYSDATE, 'DD-MON-YY:MI:SS')
                         || ' *************************'
                        );
               END IF;

               l_exception := NULL;
               fnd_message.set_name ('IGC', 'IGC_CC_FAILED_TO_ENCUMBER');
               fnd_message.set_token ('CC_NUM', v4.cc_num, TRUE);

               IF (g_error_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
               END IF;

               l_exception := fnd_message.get;

               INSERT INTO igc_cc_process_exceptions
                           (process_type, process_phase, cc_header_id,
                            cc_acct_line_id, cc_det_pf_line_id,
                            exception_reason, org_id, set_of_books_id,
                            request_id
                           )
                    VALUES (l_process_type, p_process_phase, v5.cc_header_id,
                            NULL, NULL,
                            l_exception, l_org_id, l_sob_id,
                            l_request_id1
                           );

               UPDATE igc_cc_process_data ccpd
                  SET ccpd.reservation_status = 'F'
                WHERE ccpd.cc_header_id = v5.cc_header_id
                  AND ccpd.set_of_books_id = l_sob_id
                  AND ccpd.request_id = l_request_id1
                  AND ccpd.org_id = l_org_id
                  AND ccpd.process_type = l_process_type;
            END IF;

            UPDATE igc_cc_headers cchd
               SET cchd.cc_apprvl_status = v5.old_approval_status
             WHERE cchd.cc_header_id = v5.cc_header_id;

            IF v5.old_approval_status = 'AP'
            THEN
               BEGIN
                                      -- Replaced the following query with the one below
                                      -- to tune the performance
                  -- SELECT   'Y'
                  -- INTO  l_DUMMY
                  -- FROM  po_headers pha1
                  -- WHERE pha1.po_header_id =  (SELECT pha2.po_header_id
                  --             FROM  igc_cc_headers cchd,
                  --                po_headers pha2
                  --             WHERE cchd.org_id = l_org_id
                  --             AND   cchd.cc_header_id = V5.cc_header_id
                  --             AND   cchd.cc_num = pha2.segment1
                  --             AND   pha2.type_lookup_code = 'STANDARD');
                  SELECT 'Y'
                    INTO l_dummy
                    FROM po_headers_all pha1, igc_cc_headers cchd
                   WHERE cchd.org_id = l_org_id
                     AND cchd.cc_header_id = v5.cc_header_id
                     AND cchd.cc_num = pha1.segment1
                     AND pha1.type_lookup_code = 'STANDARD'
                     AND pha1.org_id = l_org_id;

                                      -- Performance Tuning
                                      -- Replaced the following update with the one below
                  -- UPDATE   po_headers pha1
                  -- SET   pha1.approved_flag = 'Y'
                  -- WHERE (pha1.segment1,pha1.org_id,pha1.type_lookup_code) IN
                  --    (SELECT pha2.segment1,pha2.org_id,pha2.type_lookup_code
                  --    FROM  po_headers pha2, igc_cc_headers cchd
                  --    WHERE cchd.cc_header_id = V5.cc_header_id
                  --    AND   pha2.segment1 = cchd.cc_num
                  --    AND   pha2.org_id = cchd.org_id
                  --    AND   pha2.type_lookup_code = 'STANDARD');
                  UPDATE po_headers_all pha1
                     SET pha1.approved_flag = 'Y'
                   WHERE pha1.type_lookup_code = 'STANDARD'
                     AND pha1.org_id = l_org_id
                     AND pha1.segment1 =
                                  (SELECT cchd.cc_num
                                     FROM igc_cc_headers cchd
                                    WHERE cchd.cc_header_id = v5.cc_header_id);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;
            END IF;
         END LOOP;

         CLOSE c5;

-- Mark Flag 3
         COMMIT;
-- This ends the Final Mode Check
      END IF;
-- If Paramer Validation fails the program logic is jumped here.
   ELSE
      INSERT INTO igc_cc_process_exceptions
                  (process_type, process_phase, cc_header_id,
                   cc_acct_line_id, cc_det_pf_line_id, exception_reason,
                   org_id, set_of_books_id, request_id
                  )
           VALUES (l_process_type, p_process_phase, NULL,
                   NULL, NULL, l_exception,
                   l_org_id, l_sob_id, l_request_id1
                  );

      l_exception := NULL;
      fnd_message.set_name ('IGC', 'IGC_CC_PARAM_VALID_FAILED');

      IF (g_error_level >= g_debug_level)
      THEN
         fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
      END IF;

      l_exception := fnd_message.get;

      INSERT INTO igc_cc_process_exceptions
                  (process_type, process_phase, cc_header_id,
                   cc_acct_line_id, cc_det_pf_line_id, exception_reason,
                   org_id, set_of_books_id, request_id
                  )
           VALUES (l_process_type, p_process_phase, NULL,
                   NULL, NULL, l_exception,
                   l_org_id, l_sob_id, l_request_id1
                  );

      COMMIT;
   END IF;

/*Bug No : 6341012. MOAC Uptake. Set ORG_ID before submitting Request */

    fnd_request.set_org_id(l_org_id);

   l_request_idt_id2 :=
      fnd_request.submit_request ('IGC',
                                  'IGCCMPPR',
                                  NULL,
                                  NULL,
                                  FALSE,
                                  l_sob_id,
                                  l_org_id,
                                  p_process_phase,
                                  'M',
                                  l_request_id1
                                 );
---------------------------------
------Run XML Report
---------------------------------
     IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCMPPR_XML',
                                            'IGC',
                                            'IGCCMPPR_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCMPPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
               IF l_layout then
                   Fnd_request.set_org_id(l_org_id);
                     l_request_idt_id2 :=fnd_request.submit_request (
                                                        'IGC',
                                                        'IGCCMPPR_XML',
                                                         NULL,
                                                         NULL,
                                                         FALSE,
                                                         l_sob_id,
                                                         l_org_id,
                                                         p_process_phase,
                                                         'M',
                                                         l_request_id1);
               END IF;
    END IF;
--------------------
-- End of XML Report
--------------------


-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
   fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

   IF (l_msg_count > 0)
   THEN
      l_error_text := '';

      FOR l_cur IN 1 .. l_msg_count
      LOOP
         l_error_text :=
                     l_cur || ' ' || fnd_msg_pub.get (l_cur, fnd_api.g_false);

         IF (g_excep_level >= g_debug_level)
         THEN
            fnd_log.STRING (g_excep_level, l_full_path, l_error_text);
         END IF;

         fnd_file.put_line (fnd_file.LOG, l_error_text);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      /*IF (g_debug_mode = 'Y') THEN
         Output_Debug (l_full_path, ' SQLERRM ' || SQLERRM);
      END IF;*/
      l_exception := NULL;

      IF (fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error))
      THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, 'MPFS_MAIN');
      END IF;

      fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                 p_data       => l_msg_data);

      IF (l_msg_count > 0)
      THEN
         l_error_text := '';

         FOR l_cur IN 1 .. l_msg_count
         LOOP
            l_error_text :=
                  ' Mesg No : '
               || l_cur
               || ' '
               || fnd_msg_pub.get (l_cur, fnd_api.g_false);

            /*fnd_file.put_line (FND_FILE.LOG,
                               l_error_text);*/
            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.STRING (g_excep_level, l_full_path, l_error_text);
            END IF;
         END LOOP;
      ELSE
         l_error_text := 'Error Returned but Error stack has no data';

--           fnd_file.put_line (FND_FILE.LOG,
--                              l_error_text);
         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.STRING (g_error_level, l_full_path, l_error_text);
         END IF;
      END IF;
-- ROLLBACK TO S1;
END;                      /* Procedure MASS_PAYMENT_FORECAST_SHIFT_MAIN End */




--
-- Output_Debug Procedure is the Generic procedure designed for outputting debug
-- information that is required from this procedure.
--
-- Parameters :
--
-- p_debug_msg ==> Record to be output into the debug log file.
--
PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2
) IS

-- Constants :

   /*l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(6)           := 'CC_MPF';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

   --FND_FILE.put_line( FND_FILE.log, p_debug_msg );
   /*IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
  END IF;*/

  IF (g_state_level >=  g_debug_level ) THEN
      FND_LOG.STRING (g_state_level,p_path,p_debug_msg);
  END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

/*   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Output_Debug;
BEGIN
  g_debug_flag 		:= 'N';
  g_line_num        := 0;
  g_debug_mode      := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_debug_level     :=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level     :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level      :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level     :=	FND_LOG.LEVEL_EVENT;
  g_excep_level     :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level     :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level     :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path            := 'IGC.PLSQL.IGCCMPSB.IGC_CC_MPFS_PROCESS_PKG.';


END IGC_CC_MPFS_PROCESS_PKG; /* Package Ends */

/
