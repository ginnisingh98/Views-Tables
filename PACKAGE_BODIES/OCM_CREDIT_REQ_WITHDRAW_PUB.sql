--------------------------------------------------------
--  DDL for Package Body OCM_CREDIT_REQ_WITHDRAW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_CREDIT_REQ_WITHDRAW_PUB" AS
/*$Header: OCMPWIDB.pls 120.1 2005/08/23 23:45:14 bsarkar noship $  */

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.OCM_CREDIT_REQUEST_WITHDRAW_PUB' );
END;

PROCEDURE WITHDRAW_REQUEST (
		p_api_version                    IN 	NUMBER,
    	p_init_msg_list                  IN 	VARCHAR2 ,
    	p_commit                         IN 	VARCHAR2,
       	p_validation_level               IN 	VARCHAR2,
       	x_return_status                  OUT 	NOCOPY VARCHAR2,
       	x_msg_count                      OUT	NOCOPY NUMBER,
       	x_msg_data                       OUT 	NOCOPY VARCHAR2,
		p_credit_request_id				 IN	 	NUMBER,
		p_withdrawl_reason_code			 IN	 	VARCHAR2 ) IS

		l_ctr								VARCHAr2(1);
		l_status							VARCHAR2(30);
BEGIN
	IF pg_debug = 'Y'
	THEN
		debug ( 'Withdraw Request (+)');
		debug ( 'p_credit_request_id ' ||p_credit_request_id );
		debug ( 'p_withdraw_reason_code ' ||p_withdrawl_reason_code );
	END IF;

	x_return_status  := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT WITHDRAW_REQUEST;

    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
    	FND_MSG_PUB.initialize;
    END IF;

    -- validate whether the credit request is valid or not
	BEGIN
		SELECT 'X'
		INTO   l_status
		FROM   ar_cmgt_credit_requests
		WHERE  credit_request_id = p_credit_request_id
		AND    status NOT IN ('WITHDRAW', 'PROCESSED');

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_count   := 1;
			x_msg_data := 'OCM_INVALID_WITHDRAW_REQUEST';
			return;
		WHEN OTHERS THEN
			x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_count   := 1;
			x_msg_data := sqlerrm;
			return;
	END;
	BEGIN
		SELECT 'X'
		INTO   l_ctr
		FROM   ar_lookups
		WHERE  lookup_type = 'AR_CMGT_APP_WITHDRAW_REASONS'
		AND    lookup_code = p_withdrawl_reason_code;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_count   := 1;
			x_msg_data := 'OCM_INVALID_WITHDRAW_REASON';
			return;
		WHEN OTHERS THEN
			x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_count   := 1;
			x_msg_data := sqlerrm;
			return;
	END;

	-- Now update the status of credit request and case folder
	UPDATE ar_cmgt_credit_requests
	  SET  status = 'WITHDRAW'
	WHERE credit_request_id = p_credit_request_id;

	UPDATE ar_cmgt_case_folders
	  SET  status = 'WITHDRAW'
	WHERE credit_request_id = p_credit_request_id;

	IF l_status <> ( 'SAVE' )
	THEN
		WF_ENGINE.AbortProcess (
			itemtype => 'ARCMGTAP',
			itemkey => p_credit_request_id );
	END IF;

	IF pg_debug = 'Y'
	THEN
		debug ( 'Withdraw Request (-)');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			rollback to WITHDRAW_REQUEST;
			x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_data := sqlerrm;

END WITHDRAW_REQUEST;

END OCM_CREDIT_REQ_WITHDRAW_PUB;

/
