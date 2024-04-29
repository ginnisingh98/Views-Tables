--------------------------------------------------------
--  DDL for Package Body DPP_XLA_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_XLA_EVENT_PUB" AS
/* $Header: dppxlaeb.pls 120.2.12010000.4 2008/08/05 08:12:13 sanagar ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'DPP_XLA_EVENT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(14) := 'dppxlaeb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


PROCEDURE CreateAccounting(	errbuf  OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER,
				p_org_id IN NUMBER,
				p_source_application_id IN NUMBER,
				p_application_id IN NUMBER,
				p_dummy IN VARCHAR2,
				p_ledger_id IN NUMBER,
				P_PROCESS_CATEGORY_CODE IN VARCHAR2,
				P_END_DATE IN VARCHAR2,
				P_CREATE_ACCOUNTING_FLAG IN VARCHAR2,
				P_DUMMY_PARAM_1 IN VARCHAR2,
				P_ACCOUNTING_MODE IN VARCHAR2,
				P_DUMMY_PARAM_2 IN VARCHAR2,
				P_ERRORS_ONLY_FLAG IN VARCHAR2,
				P_REPORT_STYLE IN VARCHAR2,
				P_TRANSFER_TO_GL_FLAG IN VARCHAR2,
				P_DUMMY_PARAM_3 IN VARCHAR2,
				P_POST_IN_GL_FLAG IN VARCHAR2,
				P_GL_BATCH_NAME IN VARCHAR2,
				P_MIN_PRECISION IN NUMBER,
				P_INCLUDE_ZERO_AMOUNT_LINES IN VARCHAR2,
				P_REQUEST_ID IN NUMBER,
				P_ENTITY_ID IN NUMBER,
				P_SOURCE_APPLICATION_NAME IN VARCHAR2,
				P_APPLICATION_NAME IN VARCHAR2,
				P_LEDGER_NAME IN VARCHAR2,
				P_PROCESS_CATEGORY_NAME IN VARCHAR2,
				P_CREATE_ACCOUNTING IN VARCHAR2,
				P_ACCOUNTING_MODE_NAME IN VARCHAR2,
				P_ERRORS_ONLY IN VARCHAR2,
				P_ACCOUNTING_REPORT_LEVEL IN VARCHAR2,
				P_TRANSFER_TO_GL IN VARCHAR2,
				P_POST_IN_GL IN VARCHAR2,
				P_INCLUDE_ZERO_AMT_LINES IN VARCHAR2,
				P_VALUATION_METHOD_CODE IN VARCHAR2,
				P_SECURITY_INT_1 IN NUMBER,
				P_SECURITY_INT_2 IN NUMBER,
				P_SECURITY_INT_3 IN NUMBER,
				P_SECURITY_CHAR_1 IN VARCHAR2,
				P_SECURITY_CHAR_2 IN VARCHAR2,
				P_SECURITY_CHAR_3 IN VARCHAR2,
				P_CONC_REQUEST_ID IN NUMBER,
				P_INCLUDE_USER_TRX_ID_FLAG IN VARCHAR2,
				P_INCLUDE_USER_TRX_IDENTIFIERS IN VARCHAR2,
				P_DebugFlag   IN VARCHAR2,
				P_USER_ID IN NUMBER -- Bug#7280169
			       )
IS
--Cursor to get eligible header records from the DPP extract table
CURSOR get_eligible_header_csr IS
	SELECT
		PSEH.TRANSACTION_HEADER_ID,
		PSEH.BASE_TRANSACTION_HEADER_ID,
		PSEH.PP_TRANSACTION_TYPE,
		DTH.ORG_ID,
		DTH.VENDOR_ID,
		DTH.VENDOR_SITE_ID,
		TO_NUMBER(hou.default_legal_context_id) legal_entity,   --Bug#7280169
		TO_NUMBER(hou.set_of_books_id) ledger_id,   --Bug#7280169
		DTH.TRANSACTION_NUMBER,
		PSEH.CREATION_DATE,
		DXE.ENTITY_CODE,
		DXE.EVENT_CLASS_CODE,
		DXE.EVENT_TYPE_CODE
	FROM
		DPP_XLA_HEADERS PSEH,
		DPP_TRANSACTION_HEADERS_ALL DTH,
		hr_operating_units hou,
		DPP_XLA_EVENT_MAP DXE
	WHERE   NVL(PSEH.PROCESSED_FLAG,'N')	IN ('N','E')
	AND	PSEH.TRANSACTION_HEADER_ID=DTH.TRANSACTION_HEADER_ID
	AND     DTH.org_id =to_char(hou.organization_id)   --Bug#7280169
	AND     hou.organization_id=p_org_id   --Bug#7280169
	AND     DXE.PP_TRANSACTION_TYPE=PSEH.PP_TRANSACTION_TYPE;
rec_get_eligible_headers	get_eligible_header_csr%ROWTYPE;

l_return_status			VARCHAR2(1);
l_msg_description		VARCHAR2(500);
l_cost_accounted_rec_count	NUMBER;
l_reqid				NUMBER;
l_prev_ledger_id		NUMBER:=NULL;
l_sysdate			VARCHAR2(20);
l_api_message			VARCHAR2(500);
l_event_source_info   xla_events_pub_pkg.t_event_source_info;
l_reference_info        xla_events_pub_pkg.t_event_reference_info;
l_security_context      xla_events_pub_pkg.t_security;
l_event_id			NUMBER:=0;
l_event_date			DATE;
l_transactions_not_costed_flag	NUMBER:=0;
l_api_name			VARCHAR2(50);
l_event_count			NUMBER:=0;
BEGIN

l_sysdate:=to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');
l_api_name:='DPP_XLA_EVENT_PUB.CreateAccounting';
SAVEPOINT CREATE_Accounting;
FOR rec_get_eligible_headers IN get_eligible_header_csr
LOOP

    BEGIN
    l_event_id:=0;
    SAVEPOINT CREATE_EVENT;
	l_return_status:=NULL;
	--Set variables for getting CCID, to NULL

	l_msg_description:=NULL;

	IF rec_get_eligible_headers.PP_TRANSACTION_TYPE='COST_UPDATE' THEN
		l_transactions_not_costed_flag:=0;

		SELECT COUNT(*)
		INTO   l_transactions_not_costed_flag
		FROM DPP_XLA_LINES DXL
		WHERE 	DXL.TRANSACTION_HEADER_ID=rec_get_eligible_headers.transaction_header_id
		AND     DXL.BASE_TRANSACTION_HEADER_ID=rec_get_eligible_headers.base_transaction_header_id
		AND NOT	 EXISTS
			(
			SELECT 'X'
			 FROM	MTL_TRANSACTION_ACCOUNTS MTA
			 WHERE  MTA.TRANSACTION_ID=DXL.BASE_TRANSACTION_LINE_ID
			);

		IF l_transactions_not_costed_flag>0 THEN
			fnd_file.put_line(fnd_file.log, 'One or more items in Price Protection transaction ID= '||rec_get_eligible_headers.transaction_header_id
			                  ||'and execution detail ID= '|| rec_get_eligible_headers.base_transaction_header_id||' has not been accounted in Oracle costing');
			retcode:=1;

			UPDATE DPP_XLA_HEADERS PSEH
			SET    PROCESSED_FLAG='E',
			       ERROR_DESCRIPTION='One or more items in Price Protection transaction ID= '||rec_get_eligible_headers.transaction_header_id
			                       ||'and execution detail ID= '|| rec_get_eligible_headers.base_transaction_header_id||' has not been accounted in Oracle costing'
			WHERE  TRANSACTION_HEADER_ID= rec_get_eligible_headers.transaction_header_id
			AND    BASE_TRANSACTION_HEADER_ID=rec_get_eligible_headers.base_transaction_header_id
			AND    PROCESSED_FLAG IN ('N','E');

		END IF;

	END IF;

	IF (

		 (rec_get_eligible_headers.ENTITY_CODE='COST_UPDATE' AND	l_transactions_not_costed_flag=0) OR
		 (rec_get_eligible_headers.ENTITY_CODE<>'COST_UPDATE')
	    )
	THEN
	l_event_date:=rec_get_eligible_headers.creation_date;
	IF G_DEBUG = TRUE THEN
		fnd_file.put_line(fnd_file.log, ' going to create accounting Event');
	END IF;

		 -- Set source_info
			  l_event_source_info.application_id       := 9000;
			  l_event_source_info.legal_entity_id      := rec_get_eligible_headers.legal_entity;
			  l_event_source_info.ledger_id            := rec_get_eligible_headers.ledger_id;
			  l_event_source_info.entity_type_code     := rec_get_eligible_headers.ENTITY_CODE;
			  l_event_source_info.transaction_number   := rec_get_eligible_headers.transaction_number;
			  l_event_source_info.source_id_int_1      := rec_get_eligible_headers.transaction_header_id;
			  l_event_source_info.source_id_int_2      := rec_get_eligible_headers.base_transaction_header_id;

		 -- Set security_context
		 l_security_context.security_id_int_1     := p_org_id;


		 l_event_id := XLA_EVENTS_PUB_PKG.create_event(
			      p_event_source_info => l_event_source_info             ,
			      p_event_type_code   => rec_get_eligible_headers.event_type_code ,
			      p_event_date        => l_event_date        ,
			      p_event_status_code => xla_events_pub_pkg.c_event_unprocessed,
			      p_event_number      => NULL                            ,
			      p_reference_info    => l_reference_info                ,
			      p_valuation_method  => ''                              ,
			      p_transaction_date  => INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(trunc(sysdate),p_org_id)  ,
			      p_security_context  => l_security_context               );
		 fnd_file.put_line(fnd_file.log, ' event ID is: '||l_event_id);




		  IF NVL(l_event_id,0) <=0  THEN
		       l_api_message := 'Error Accounting for Event in SLA';
		       IF G_DEBUG = TRUE THEN
		         IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_PKG_NAME ,'Create_AccountingEntry: '||'txn ID : '||rec_get_eligible_headers.transaction_header_id||' Base txn ID :'||rec_get_eligible_headers.base_transaction_header_id);
		         END IF;
		       END IF;
		       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		           FND_MESSAGE.set_name('XLA', 'XLA_ONLINE_ACCTG_ERROR');
		         END IF;
		    FND_MSG_PUB.ADD;
		    RAISE FND_API.g_exc_unexpected_error;
		   ELSE
		   	l_event_count:=l_event_count+1;
		   END IF;

  		 IF NVL(l_event_id,-1)>0 THEN
			 UPDATE DPP_XLA_HEADERS PSEH
		 	 SET    PROCESSED_FLAG='P',
		 	 	ERROR_DESCRIPTION=NULL
			 WHERE  TRANSACTION_HEADER_ID= rec_get_eligible_headers.transaction_header_id
			 AND    BASE_TRANSACTION_HEADER_ID=rec_get_eligible_headers.base_transaction_header_id
			 AND    PROCESSED_FLAG IN ('N','E');
		 END IF;

      END IF;
      EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         retcode:=1;
         ROLLBACK TO CREATE_EVENT;
         errbuf:= FND_API.G_RET_STS_ERROR;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode:=1;
         ROLLBACK TO CREATE_EVENT;
         errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;
      WHEN OTHERS THEN
      retcode:=1;
         ROLLBACK TO CREATE_EVENT;
   	errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;
    END;
END LOOP;




	--submit accounting program only if events have been successfully raised.
	 IF l_event_count>0 THEN
	 		l_reqid := fnd_request.submit_request('XLA',                  -- Module
							       'XLAACCPB',               -- Short Name
							       '',   -- Long Name
								'',
								FALSE,
								p_source_application_id,
								p_application_id,
								p_dummy,--P_dummy
								p_ledger_id,
							        p_process_category_code,
								p_end_date,
								p_create_accounting_flag,
								p_dummy_param_1,
								p_accounting_mode,
								p_dummy_param_2,
								p_errors_only_flag,
								p_report_style,
								p_transfer_to_gl_flag,
								p_dummy_param_3,
								p_post_in_gl_flag,
								p_gl_batch_name,
								p_min_precision,
								p_include_zero_amount_lines,
								p_request_id,
								p_entity_id,
								p_source_application_name,
								p_application_name,
								p_ledger_name,
								p_process_category_name,
								p_create_accounting,
								p_accounting_mode_name,
								p_errors_only,
								p_accounting_report_level,
								p_transfer_to_gl,
								p_post_in_gl,
								p_include_zero_amt_lines,
								p_valuation_method_code,
								p_security_int_1,
								p_security_int_2,
								p_security_int_3,
								p_security_char_1,
								p_security_char_2,
								p_security_char_3,
								p_conc_request_id,
								p_include_user_trx_id_flag,
								p_include_user_trx_identifiers,
								p_debugflag,
								p_user_id --Bug#7280169
							      );


		END IF;
		IF l_reqid=0 THEN
			fnd_file.put_line(fnd_file.log,'Could not launch Create Accounting Request');
			retcode:=1;
		END IF;

if retcode<>1 then
retcode:=0;
end if;
COMMIT;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   retcode:=2;
   ROLLBACK TO CREATE_Accounting;
   errbuf:= FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
retcode:=2;
   ROLLBACK TO CREATE_Accounting;
   errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
retcode:=2;
   ROLLBACK TO CREATE_Accounting;
   errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;

END;



FUNCTION get_pp_accrual_ccid(p_org_id IN NUMBER,
			      p_vendor_id IN NUMBER,
			      p_vendor_site_id IN NUMBER
			      ) RETURN NUMBER IS
x_pp_accrual_ccid 	NUMBER;
BEGIN
	x_pp_accrual_ccid:=NULL;
	SELECT gl_pp_accrual_acct
	INTO x_pp_accrual_ccid
	FROM ozf_sys_parameters_all
	where org_id=p_org_id;
	RETURN(x_pp_accrual_ccid);


EXCEPTION WHEN NO_DATA_FOUND THEN
	RETURN(-1);

END;

FUNCTION get_pp_cost_adjustment_ccid(p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER
			      	      ) RETURN NUMBER IS
x_cost_adj_ccid		NUMBER;
	--Change to pick from trade profile table..if doesnt exist there, pick
	--from sys parameters

	BEGIN
	x_cost_adj_ccid:=NULL;
		SELECT gl_cost_adjustment_acct
		INTO x_cost_adj_ccid
		FROM ozf_supp_trd_prfls_all
		WHERE supplier_id=p_vendor_id
		AND   supplier_site_id=p_vendor_site_id
		AND   org_id=p_org_id;
		RETURN(x_cost_adj_ccid);
	EXCEPTION WHEN NO_DATA_FOUND THEN
		BEGIN
			SELECT gl_cost_adjustment_acct
			INTO x_cost_adj_ccid
			FROM ozf_sys_parameters_all
			where org_id=p_org_id;
			RETURN(x_cost_adj_ccid);
		EXCEPTION WHEN NO_DATA_FOUND THEN
			RETURN(-1);
		END;
	END;

FUNCTION get_pp_ap_clearing_ccid(
				      p_claim_id IN NUMBER,
				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER
			      	) RETURN NUMBER IS

x_ap_clearing_ccid	NUMBER;
	BEGIN
		x_ap_clearing_ccid:=NULL;
		SELECT GL_ID_DED_CLEARING
			INTO x_ap_clearing_ccid
			FROM ozf_claims_all oca,
			     ozf_claim_types_all_b oct
			where oca.org_id=p_org_id
			and   oct.org_id=p_org_id
			and   oca.claim_id=p_claim_id
			and   oca.claim_type_id=oct.claim_type_id;
			RETURN(x_ap_clearing_ccid);
	EXCEPTION WHEN NO_DATA_FOUND THEN
		BEGIN
			SELECT GL_ID_DED_CLEARING
			INTO x_ap_clearing_ccid
			FROM ozf_sys_parameters_all osp
			where osp.org_id=p_org_id;
			RETURN(x_ap_clearing_ccid);
		EXCEPTION WHEN NO_DATA_FOUND THEN
			RETURN(-1);
		END;
	END;

FUNCTION get_pp_ar_clearing_ccid(
				      p_claim_id IN NUMBER,
				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER
			      	    ) RETURN NUMBER IS

x_ar_clearing_ccid		NUMBER;
	BEGIN
		x_ar_clearing_ccid:=NULL;
		SELECT GL_ID_DED_ADJ_CLEARING
			INTO x_ar_clearing_ccid
			FROM ozf_claims_all oca,
			     ozf_claim_types_all_b oct
			where oca.org_id=p_org_id
			and   oct.org_id=p_org_id
			and   oca.claim_id=p_claim_id
			and   oca.claim_type_id=oct.claim_type_id;
			RETURN(x_ar_clearing_ccid);

	EXCEPTION WHEN NO_DATA_FOUND THEN
		BEGIN
			SELECT GL_ID_DED_ADJ_CLEARING
			INTO x_ar_clearing_ccid
			FROM ozf_sys_parameters_all osp
			where osp.org_id=p_org_id;
			RETURN(x_ar_clearing_ccid);
		EXCEPTION WHEN NO_DATA_FOUND THEN
			RETURN(-1);
		END;
	END get_pp_ar_clearing_ccid;

FUNCTION get_pp_contra_liab_ccid(

				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER
			      	  ) RETURN NUMBER IS


x_contra_liab_ccid		NUMBER;
		--Change to pick from trade profile table..if doesnt exist there, pick
		--from sys parameters

		BEGIN
			x_contra_liab_ccid:=NULL;
			SELECT gl_contra_liability_acct
			INTO x_contra_liab_ccid
			FROM ozf_supp_trd_prfls_all
			WHERE supplier_id=p_vendor_id
			AND   supplier_site_id=p_vendor_site_id
			AND   org_id=p_org_id;
			return(x_contra_liab_ccid);


		EXCEPTION WHEN NO_DATA_FOUND THEN
			BEGIN
				SELECT gl_contra_liability_acct
				INTO x_contra_liab_ccid
				FROM ozf_sys_parameters_all
				where org_id=p_org_id;
				return(x_contra_liab_ccid);
			EXCEPTION WHEN NO_DATA_FOUND THEN
				x_contra_liab_ccid:=-1;
				return(x_contra_liab_ccid);
			END;
		END get_pp_contra_liab_ccid;

END DPP_XLA_EVENT_PUB;

/
