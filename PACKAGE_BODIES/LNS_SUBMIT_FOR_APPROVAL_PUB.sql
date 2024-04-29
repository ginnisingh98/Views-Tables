--------------------------------------------------------
--  DDL for Package Body LNS_SUBMIT_FOR_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_SUBMIT_FOR_APPROVAL_PUB" as
/* $Header: LNS_SUBMIT_FOR_APPROVAL_PUB_B.pls 120.0.12000000.4 2007/05/09 11:35:07 mbolli noship $ */
/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                 CONSTANT VARCHAR2(30):= 'LNS_SUBMIT_FOR_APPROVAL_PUB';
    G_LOG_ENABLED              varchar2(5);
    G_MSG_LEVEL                NUMBER;
    g_errors_rec               Loan_Sub_For_Appr_err_type := Loan_Sub_For_Appr_err_type();
    g_error_count              number := 0;
    PROCEDURE IS_LOAN_AMOUNT_VALID(P_LOAN_ID IN NUMBER, P_STATUS OUT NOCOPY VARCHAR2);
    PROCEDURE IS_LOAN_TO_VALUE_MET(P_LOAN_ID IN NUMBER, P_STATUS OUT NOCOPY VARCHAR2);
    PROCEDURE VALIDATE_LOAN(P_LOAN_ID IN NUMBER, P_VALID OUT NOCOPY VARCHAR2);
    PROCEDURE IS_COLLATERAL_EXIST(P_LOAN_ID IN NUMBER, P_EXIST OUT NOCOPY VARCHAR2);
    PROCEDURE GET_LOAN_APPROVAL_ACCESS(P_LOAN_ID IN NUMBER, P_ACCESS OUT NOCOPY VARCHAR2);
    PROCEDURE ARE_CONDITIONS_MET(P_LOAN_ID IN NUMBER,
			    P_LOAN_STATUS IN VARCHAR2,
			    P_LOAN_PHASE IN VARCHAR2,
			    P_OPEN_TO_TERM_EVENT IN VARCHAR2,
                            P_COND_MET OUT NOCOPY VARCHAR2
		           );
/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Mar-2007           MBOLLI          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;
/*========================================================================
 | PRIVATE PROCEDURE LogErrors
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      This procedure builds the error message and stores it (alongwith
 |      other columns in LNS_LOAN_API_ERRORS_GT) in g_errors_rec.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Mar-2007           MBOLLI          Created
 |
 *=======================================================================*/
Procedure LogErrors( p_message_name IN VARCHAR2
                     ,p_line_number IN NUMBER DEFAULT NULL
                     ,p_token1 IN VARCHAR2 DEFAULT NULL
		     ,p_token2 IN VARCHAR2 DEFAULT NULL
		     ,p_token3 IN VARCHAR2 DEFAULT NULL
		     ,p_loan_id IN VARCHAR2 DEFAULT NULL
		     ,p_api_name IN VARCHAR2 DEFAULT NULL
		     ,p_err_msg IN VARCHAR2 DEFAULT NULL)
IS
l_text LNS_LOAN_API_ERRORS_GT.MESSAGE_TEXT%TYPE;
BEGIN
   fnd_message.set_name('LNS', p_message_name);
   if p_token1 is NOT NULL THEN
   fnd_message.set_token('TOKEN1',p_token1);
   end if;
   IF p_token2 is NOT NULL THEN
   fnd_message.set_token('TOKEN2',p_token2);
   END IF;
   IF p_token3 is NOT NULL THEN
   fnd_message.set_token('TOKEN3',p_token3);
   END IF;
   IF p_loan_id is NOT NULL THEN
   fnd_message.set_token('LOANNUMBER',p_loan_id);
   END IF;
   IF p_api_name is NOT NULL THEN
   fnd_message.set_token('APINAME',p_api_name);
   END IF;
   IF p_err_msg is NOT NULL THEN
   fnd_message.set_token('ERRMSG',p_err_msg);
   END IF;

   l_text := substrb(fnd_message.get,1,2000);
   g_error_count := g_error_count+1;
   g_errors_rec.extend(1);
   g_errors_rec(g_error_count).ERROR_NUMBER := g_error_count;
   g_errors_rec(g_error_count).MESSAGE_NAME := p_message_name;
   g_errors_rec(g_error_count).MESSAGE_TEXT := l_text;
   g_errors_rec(g_error_count).LINE_NUMBER  := p_line_number;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;
/*========================================================================
 | PRIVATE PROCEDURE InsertErrors
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-Mar-2007           MBOLLI          Created
 |
 *=======================================================================*/
Procedure InsertErrors
IS
BEGIN
   FORALL i in 1..g_errors_rec.COUNT
      insert into LNS_LOAN_API_ERRORS_GT
      VALUES
      g_errors_rec(i);
EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



PROCEDURE SUBMIT_FOR_APPROVAL(
    P_API_VERSION           IN		NUMBER,
    P_COMMIT                IN		VARCHAR2,
    P_APPROVAL_ACTION_REC   IN		LNS_APPROVAL_ACTION_PUB.APPROVAL_ACTION_REC_TYPE,
    P_AUTO_FUNDING_FLAG	    IN		VARCHAR2,
    X_ACTION_ID             OUT NOCOPY  NUMBER,
    X_RETURN_STATUS         OUT NOCOPY	VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY	NUMBER) IS
/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

   l_api_name                      CONSTANT VARCHAR2(30) := 'SUBMIT_FOR_APPROVAL';
   l_api_version                   CONSTANT NUMBER := 1.0;
   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(32767);
   l_loan_id			   NUMBER;
   l_loan_class			   LNS_LOAN_HEADERS.LOAN_CLASS_CODE%TYPE;
   l_loan_status		   LNS_LOAN_HEADERS.LOAN_STATUS%TYPE;
   l_sec_status			   LNS_LOAN_HEADERS.SECONDARY_STATUS%TYPE;
   l_credit_review_flag		   LNS_LOAN_HEADERS.CREDIT_REVIEW_FLAG%TYPE;
   l_curr_phase			   LNS_LOAN_HEADERS.CURRENT_PHASE%TYPE;
   l_open_to_term_event		   LNS_LOAN_HEADERS.OPEN_TO_TERM_EVENT%TYPE;
   l_are_conditions_met		   VARCHAR2(1);
   l_loan_approval_access	   VARCHAR2(1);
   l_validate_loan                 VARCHAR2(1);
   l_amount_valid                  VARCHAR2(10);
   l_loan_value_met                VARCHAR2(1);
   l_collateral_exist              VARCHAR2(1);
   l_ready_for_submit_approval	   VARCHAR2(1);
   l_apply_submit_for_approval     VARCHAR2(1);
--   l_auto_funding_flag		   VARCHAR2(1);
   l_approval_action_rec	   LNS_APPROVAL_ACTION_PUB.APPROVAL_ACTION_REC_TYPE;
   l_action_id			   NUMBER;
   l_collateral_percent		   VARCHAR2(3);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

  CURSOR Cur_loan_details(p_loan_id NUMBER) IS
  SELECT
	loan_class_code, loan_status, secondary_status, credit_review_flag, current_phase, open_to_term_event
  FROM
	lns_loan_headers
  WHERE
	loan_id = p_loan_id;

BEGIN
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

   l_loan_id := P_APPROVAL_ACTION_REC.loan_id;

   IF ((l_loan_id IS NULL) OR (trim(l_loan_id) = '')) THEN
	      LogErrors(p_message_name=>'LNS_LCREATE_NULL_VALUE'
	               ,p_token1=>' loan_Id is '||l_loan_id);
   END IF;

   OPEN Cur_loan_details(l_loan_id);


   FETCH Cur_loan_details into
	 l_loan_class, l_loan_status, l_sec_status, l_credit_review_flag, l_curr_phase, l_open_to_term_event;

   IF Cur_loan_details%NOTFOUND THEN
	      LogErrors(p_message_name=>'LNS_LCREATE_INVALID_ATTRIBUTE'
	               ,p_token1=> 'Loan ID = '||l_loan_id);
	      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE Cur_loan_details;

   IF l_loan_status = 'INCOMPLETE' THEN
	IF (l_credit_review_flag = 'Y' AND ( l_sec_status IS NULL OR l_sec_status NOT IN ('IN_CREDIT_REVIEW', 'CREDIT_REVIEW_COMPLETE'))) THEN
	      LogErrors(p_message_name=>'LNS_CREDIT_REVIEW_REQUIRED'
			,p_loan_id=>l_loan_id);
	ELSIF (l_credit_review_flag = 'Y' AND ( l_sec_status IS NULL OR l_sec_status = 'CREDIT_REVIEW_COMPLETE')) THEN
	      LogErrors(p_message_name=>'LNS_LOAN_UNFREEZE'
	               ,p_loan_id=>l_loan_id);
	ELSIF (l_sec_status NOT IN ('IN_CREDIT_REVIEW') OR l_sec_status IS NULL) THEN
		ARE_CONDITIONS_MET(l_loan_id, l_loan_status, l_curr_phase, l_open_to_term_event, l_are_conditions_met);
		IF  l_are_conditions_met = 'N' THEN
		      LogErrors(p_message_name=>'LNS_NOT_ALL_COND_MET');
		ELSE
			GET_LOAN_APPROVAL_ACCESS(l_loan_id, l_loan_approval_access);
			IF (l_loan_approval_access = 'N') THEN
				l_ready_for_submit_approval := 'Y';
			ELSE
			      LogErrors(p_message_name=>'LNS_LOAN_APPROVAL_NOT_REQUIRED'
			               ,p_loan_id=>l_loan_id);
			END IF;

		END IF;

	END IF;
   END IF;

   IF g_error_count = 0 THEN
	l_apply_submit_for_approval := 'Y';
   ELSE
	RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_ready_for_submit_approval = 'Y') THEN
	l_apply_submit_for_approval := 'N';

	--SELECT VALIDATE_LOAN(l_loan_id)		into l_validate_loan	FROM DUAL;
	--SELECT IS_LOAN_AMOUNT_VALID(l_loan_id)	into l_amount_valid	FROM DUAL;
	--SELECT IS_LOAN_TO_VALUE_MET(l_loan_id)	into l_loan_value_met	FROM DUAL;
	--SELECT IS_COLLATERAL_EXIST(l_loan_id)	into l_collateral_exist FROM DUAL;

        VALIDATE_LOAN(l_loan_id,l_validate_loan);
	IS_LOAN_AMOUNT_VALID(l_loan_id,l_amount_valid);
        IS_LOAN_TO_VALUE_MET(l_loan_id,l_loan_value_met);
        IS_COLLATERAL_EXIST(l_loan_id,l_collateral_exist);

	IF l_validate_loan = 'N' THEN
	      LogErrors(p_message_name=>'LNS_FEE_INSTLMNT_ERROR'
			,p_token1=>' for loan ID '||l_loan_id);
	ELSIF  ((l_loan_class = 'ERS') AND (NOT l_amount_valid = 'VALID')) THEN
	      LogErrors(p_message_name=>'LNS_LOAN_AMOUNT_ERROR'
			,p_token1=>' for loan ID '||l_loan_id);

	ELSIF l_loan_value_met = 'N' THEN
	      SELECT
		to_char(loan.collateral_percent) || '%' into l_collateral_percent
	      FROM
		lns_loan_headers loan
	      WHERE
		loan.loan_id = l_loan_id;

	      LogErrors(p_message_name=>'LNS_LOAN_TO_VALUE_ERROR'
			,p_token1=>'#COLLATERAL_PERCENT'
			,p_token2=>l_collateral_percent);

	ELSIF l_collateral_exist = 'N' THEN
	      LogErrors(p_message_name=>'LNS_MISSING_COLLATERAL_ERROR'
			,p_token1=>' for loan ID '||l_loan_id);
	ELSIF l_loan_class = 'DIRECT' THEN
		lns_funding_pub.validate_disb_for_appr(
						    P_API_VERSION		    => 1.0,
						    P_INIT_MSG_LIST		    => FND_API.G_TRUE,
						    P_COMMIT			    => FND_API.G_FALSE,
						    P_VALIDATION_LEVEL		    => FND_API.G_VALID_LEVEL_FULL,
						    P_LOAN_ID			    => l_loan_id,
						    X_RETURN_STATUS		    => l_return_status,
						    X_MSG_COUNT			    => l_msg_count,
						    X_MSG_DATA	    		    => l_msg_data
						    );
		IF l_return_status <> 'S' THEN
		    LogErrors(p_message_name=>'LNS_PLSQL_API_ERROR'
			     ,p_api_name    => 'lns_funding_pub.validate_disb_for_app()'
			     ,p_err_msg	    => l_msg_data);
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF g_error_count = 0 THEN
		l_apply_submit_for_approval := 'Y';
	ELSE
		RAISE FND_API.G_EXC_ERROR;
	END IF;
   END IF;

   IF l_apply_submit_for_approval = 'Y' THEN

		IF (l_loan_class = 'DIRECT') THEN
			lns_funding_pub.set_autofunding(
						P_API_VERSION		=> 1.0,
						P_INIT_MSG_LIST		=> FND_API.G_TRUE,
						P_COMMIT		=> FND_API.G_FALSE,
						P_VALIDATION_LEVEL	=> FND_API.G_VALID_LEVEL_FULL,
						P_LOAN_ID		=> l_loan_id,
						P_AUTOFUNDING_FLAG	=> p_auto_funding_flag,
						X_RETURN_STATUS		=> l_return_status,
						X_MSG_COUNT		=> l_msg_count,
						X_MSG_DATA	    	=> l_msg_data
						);
		END IF;

                IF l_return_status <> 'S' THEN
		    LogErrors(p_message_name=>'LNS_PLSQL_API_ERROR'
			     ,p_api_name    => 'lns_funding_pub.set_autofunding()'
			     ,p_err_msg	    => l_msg_data);
		    RAISE FND_API.G_EXC_ERROR;
                END IF;


		LNS_APPROVAL_ACTION_PUB.create_approval_action (p_init_msg_list => FND_API.G_TRUE,
							p_approval_action_rec => p_approval_action_rec,
							x_action_id => l_action_id,
							X_RETURN_STATUS => l_return_status,
							X_MSG_COUNT => l_msg_count,
							X_MSG_DATA => l_msg_data
							);

                IF l_return_status <> 'S' THEN
		    LogErrors(p_message_name=>'LNS_PLSQL_API_ERROR'
			     ,p_api_name    => 'LNS_APPROVAL_ACTION_PUB.create_approval_action()'
			     ,p_err_msg	    => l_msg_data);
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
   END IF;

   IF g_error_count > 0 THEN
      InsertErrors;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_MSG_COUNT := g_error_count;
   ELSE
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      X_MSG_COUNT := 0;
   END IF;
   LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         InsertErrors;
	 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
	 X_MSG_COUNT := g_error_count;

      WHEN OTHERS THEN
         InsertErrors;
	 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
	 X_MSG_COUNT := g_error_count;
	-- raise;

END SUBMIT_FOR_APPROVAL;



 /*========================================================================
 | PROCEDURE VALIDATE_LOAN
 |
 | DESCRIPTION
 |      This procedure checks whether the fee installment has any error
 |	in table lns_fee_assignments.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |      P_VALID                     IN          Valid Status
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE VALIDATE_LOAN(P_LOAN_ID IN NUMBER, P_VALID OUT NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_LOAN';
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_count			    NUMBER := -1;

BEGIN

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

	SELECT
		count(1) into l_count
	FROM
		lns_fee_assignments
	WHERE
		loan_id = p_loan_id
		and end_installment_number > lns_fin_utils.getnumberinstallments(p_loan_id);

	IF l_count > 0 THEN
            p_valid := 'N';
        ELSE
            p_valid := 'Y';
        END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END VALIDATE_LOAN;



 /*========================================================================
 | PROCEDURE IS_LOAN_TO_VALUE_MET
 |
 | DESCRIPTION
 |      This procedure returns 'Y' if the loan amount value meets the assets.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |      P_STATUS                    IN          Value Met Status
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE IS_LOAN_TO_VALUE_MET(P_LOAN_ID IN NUMBER, P_STATUS OUT NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
   l_api_name                      CONSTANT VARCHAR2(30) := 'IS_LOAN_TO_VALUE_MET';
   l_count			   NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

   CURSOR Cur_Loan_Value_Met(p_loan_id IN NUMBER) IS
	SELECT
		count(1)
	FROM
		lns_loan_headers loan
	WHERE
		loan.loan_id = p_loan_id
		and (loan.loan_subtype <> 'SECURED'
		     OR loan.collateral_percent <=
		      (SELECT
				nvl(sum(a.pledged_amount)/loan.requested_amount,0) * 100
		       FROM
				lns_asset_assignments a
		       WHERE
				a.loan_id = loan.loan_id
				and ( a.end_date_active is null OR trunc(a.end_date_active) >= trunc(loan.loan_maturity_date) )
			)
		      );
BEGIN

        p_status := 'N';
	l_count := -1;
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');


	IF (NOT((p_loan_id IS NULL) OR (trim(p_loan_id) = ''))) THEN
            OPEN Cur_Loan_Value_Met(p_loan_id);
            FETCH Cur_Loan_Value_Met into l_count;
            CLOSE Cur_Loan_Value_Met;

            IF l_count > 0 THEN
                    p_status := 'Y';
            END IF;
	END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END IS_LOAN_TO_VALUE_MET;


 /*========================================================================
 | PROCEDURE IS_COLLATERAL_EXIST
 |
 | DESCRIPTION
 |      This procedure returns 'Y' if the secured loan contains atleast
 |	one asset.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |      P_EXIST                     OUT         Exist status
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE IS_COLLATERAL_EXIST(P_LOAN_ID IN NUMBER, P_EXIST OUT NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
   l_api_name                      CONSTANT VARCHAR2(30) := 'IS_COLLATERAL_EXIST';
   l_count			   NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

   CURSOR Cur_Collateral_Exist(p_loan_id IN NUMBER) IS
	SELECT
		COUNT(1)
	FROM
		lns_loan_headers l
	WHERE
		l.loan_Id = p_loan_id
		and (l.loan_subtype <> 'SECURED'
		     OR exists
		            (SELECT
				1
			     FROM
				lns_asset_assignments a
			     WHERE
				a.loan_id = l.loan_id
			     )
		     );
BEGIN

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

        p_exist := 'N';
	l_count := -1;
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

	IF (NOT ((p_loan_id IS NULL) OR (trim(p_loan_id) = ''))) THEN
            OPEN Cur_Collateral_Exist(p_loan_id);
            FETCH Cur_Collateral_Exist into l_count;
            CLOSE Cur_Collateral_Exist;

            IF l_count > 0 THEN
                    p_exist := 'Y';
            END IF;
	END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END IS_COLLATERAL_EXIST;

 /*========================================================================
 | PROCEDURE ARE_CONDITIONS_MET
 |
 | DESCRIPTION
 |      This procedure returns 'Y' if this loan meets all the conditions
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |	P_LOAN_STATUS		    IN		Loan Status
 |	P_LOAN_PHASE		    IN		Loan Current Phase
 |	P_OPEN_TO_TERM_EVENT	    IN		Open to Term Event
 |      P_COND_MET                  OUT         Conditions Met
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE ARE_CONDITIONS_MET(P_LOAN_ID IN NUMBER,
			    P_LOAN_STATUS IN VARCHAR2,
			    P_LOAN_PHASE IN VARCHAR2,
			    P_OPEN_TO_TERM_EVENT IN VARCHAR2,
                            P_COND_MET OUT NOCOPY VARCHAR2
		           )
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
   l_api_name                      CONSTANT VARCHAR2(30) := 'ARE_CONDITIONS_MET';
   l_condition_type		   VARCHAR2(30);
   l_count			   NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

        p_cond_met := 'Y';
	l_condition_type := '-';
	l_count := -1;

	IF ( p_loan_phase = 'OPEN' AND p_open_to_term_event = 'MANUAL' AND p_loan_status = 'INCOMPLETE' ) THEN
		l_condition_type := 'CONVERSION';
	ELSIF ( p_loan_phase = 'OPEN' AND p_open_to_term_event = 'MANUAL' AND p_loan_status = 'ACTIVE' ) THEN
		l_condition_type := 'APPROVAL';
	END IF;

	SELECT
		count(1) into l_count
	FROM
		lns_cond_assignments
	WHERE
		loan_id = p_loan_id
		and mandatory_flag = 'Y'
		and (condition_met_flag is NULL OR condition_met_flag = 'N')
		and (end_date_active is null or end_date_active > sysdate)
		and condition_id NOT IN
		                   (SELECT
					condition_id
				    FROM
					lns_conditions
				    WHERE
					condition_type = l_condition_type
				    );


	IF l_count > 0  THEN
		p_cond_met := 'N';
	END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
END ARE_CONDITIONS_MET;

 /*========================================================================
 | PROCEDURE GET_LOAN_APPROVAL_ACCESS
 |
 | DESCRIPTION
 |      This procedure checks if the loan agent has access to approve the loan
 |	based on the loan product settings.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |      P_ACCESS                    OUT         Access status
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE GET_LOAN_APPROVAL_ACCESS(P_LOAN_ID IN NUMBER, P_ACCESS OUT NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
   l_api_name                      CONSTANT VARCHAR2(30) := 'GET_LOAN_APPROVAL_ACCESS';
   l_appr_req_flag		   VARCHAR2(1);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

BEGIN
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

	SELECT
		NVL(LOAN_APPR_REQ_FLAG,'Y') into l_appr_req_flag
	FROM
		lns_loan_products_all prod, lns_loan_headers_all loan
	WHERE
		prod.loan_product_id = loan.product_id
		and loan.loan_id = p_loan_id;

	IF l_appr_req_flag = 'Y' THEN
		p_access := 'N';
	ELSE
		p_access := 'y';
	END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');


END GET_LOAN_APPROVAL_ACCESS;




 /*========================================================================
 | PROCEDURE IS_LOAN_AMOUNT_VALID
 |
 | DESCRIPTION
 |      This procedure returns valid if invoice amount >= loan amount
 |	otherwise returns description of invoice amount
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |	P_LOAN_ID		    IN		Loan Id
 |      P_STATUS                    IN          Valid status
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Mar-2007           Mbolli            Created
 |
 *=======================================================================*/

PROCEDURE IS_LOAN_AMOUNT_VALID(P_LOAN_ID IN NUMBER, P_STATUS OUT NOCOPY VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_api_name                      CONSTANT VARCHAR2(30) := 'IS_LOAN_AMOUNT_VALID';
    l_inv_amt			    NUMBER;
    l_req_amt			    NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR Csr_Loan_Amounts(p_loan_id IN NUMBER) IS
    SELECT
	nvl(sum(pmt_sch.AMOUNT_DUE_REMAINING),0) invoice_balance_amount, nvl(sum(lines.requested_amount),0) requested_amount
    FROM
	ar_payment_schedules pmt_sch, lns_Loan_Lines lines
    WHERE
	nvl(lines.installment_number, 1) = pmt_sch.terms_sequence_number
	and pmt_sch.customer_trx_id = lines.reference_id
	and lines.loan_Id = p_loan_id
	and lines.end_date is null
	and lines.reference_type = 'RECEIVABLE';

BEGIN
	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');
        p_status := 'INVALID';
	IF( NOT((p_loan_id IS NULL) OR (trim(p_loan_id) = ''))) THEN
          p_status := 'INVALID';
          OPEN Csr_Loan_Amounts(p_loan_id);
          FETCH Csr_Loan_Amounts into l_inv_amt, l_req_amt;
          CLOSE Csr_Loan_Amounts;
          IF (l_inv_amt >= l_req_amt) THEN
                  p_status := 'VALID';
          END IF;
	END IF;

	LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');
END IS_LOAN_AMOUNT_VALID;

BEGIN
   G_LOG_ENABLED := 'N';
   G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

   /* getting msg logging info */
   G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
   if (G_LOG_ENABLED = 'N') then
      G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
   else
      G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
   end if;

   LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
END LNS_SUBMIT_FOR_APPROVAL_PUB;

/
