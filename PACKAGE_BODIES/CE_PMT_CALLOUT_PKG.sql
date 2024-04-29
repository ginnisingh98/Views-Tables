--------------------------------------------------------
--  DDL for Package Body CE_PMT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_PMT_CALLOUT_PKG" AS
/* $Header: cepmtcob.pls 120.3 2005/12/30 11:26:54 svali noship $ */
PROCEDURE documents_payable_rejected(p_api_version NUMBER,
							 p_init_msg_list VARCHAR2,
							 p_commit VARCHAR2,
							 x_return_status OUT NOCOPY VARCHAR2,
							 x_msg_count OUT NOCOPY NUMBER,
							 x_msg_data OUT NOCOPY VARCHAR2,
							 p_rejected_docs_group_id NUMBER)
IS
	CURSOR c_rejected_transfers (cs_rejected_docs_group_id NUMBER)
	IS
	SELECT docs.calling_app_doc_ref_number
	FROM iby_fd_docs_payable_v docs
	WHERE docs.rejected_docs_group_id = cs_rejected_docs_group_id;

	l_trxn_reference_number CE_PAYMENT_TRANSACTIONS.trxn_reference_number%TYPE;
	l_result varchar2(100);
BEGIN
	OPEN c_rejected_transfers(p_rejected_docs_group_id);
	LOOP
		FETCH c_rejected_transfers into
		      l_trxn_reference_number;
		EXIT WHEN c_rejected_transfers%NOTFOUND or
					c_rejected_transfers%NOTFOUND is NULL;

		CE_BAT_API.reject_transfer(l_trxn_reference_number,
					   l_result);
		UPDATE ce_payment_transactions
		SET		trxn_status_code = 'FAILED'
		WHERE 	trxn_reference_number = l_trxn_reference_number;
	END LOOP;
	CLOSE c_rejected_transfers;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
RAISE;
END documents_payable_rejected;


PROCEDURE payments_completed(p_api_version NUMBER,
					 p_init_msg_list VARCHAR2,
					 p_commit VARCHAR2,
					 x_return_status OUT NOCOPY VARCHAR2,
					 x_msg_count OUT NOCOPY NUMBER,
					 x_msg_data OUT NOCOPY VARCHAR2,
					 p_completed_pmts_group_id NUMBER)
IS
	CURSOR c_completed_transfers (cs_completed_pmts_group_id NUMBER)
	IS
	SELECT docs.calling_app_doc_ref_number,
	       pmts.payment_reference_number
	FROM iby_fd_docs_payable_v docs,
	     iby_fd_payments_v pmts
	WHERE docs.completed_pmts_group_id = cs_completed_pmts_group_id
	AND   docs.payment_id = pmts.payment_id;

	l_trxn_reference_number CE_PAYMENT_TRANSACTIONS.trxn_reference_number%TYPE;
	l_payment_reference_number IBY_FD_PAYMENTS_V.payment_reference_number%TYPE;
BEGIN
	OPEN c_completed_transfers(p_completed_pmts_group_id);
	LOOP
		FETCH c_completed_transfers into
		      l_trxn_reference_number,
			  l_payment_reference_number;
		EXIT WHEN c_completed_transfers%NOTFOUND or
				  c_completed_transfers%NOTFOUND is NULL;

		CE_BAT_API.settle_transfer('MANUAL',
					   l_trxn_reference_number,
					   l_payment_reference_number,
					   NULL,
					   NULL);
	END LOOP;
	CLOSE c_completed_transfers;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
RAISE;
END payments_completed;


PROCEDURE payment_voided(p_api_version	NUMBER,
				 p_payment_id	NUMBER,
				 p_void_date	DATE,
				 p_init_msg_list	VARCHAR2,
				 p_commit	VARCHAR2,
				 x_return_status OUT NOCOPY	VARCHAR2,
				 x_msg_count	OUT NOCOPY NUMBER,
				 x_msg_data	OUT NOCOPY VARCHAR2)
IS
	CURSOR c_voided_transfers (cs_payment_id NUMBER)
	IS
	SELECT docs.calling_app_doc_ref_number
	FROM iby_fd_docs_payable_v docs
	WHERE docs.payment_id = cs_payment_id;

	l_trxn_reference_number CE_PAYMENT_TRANSACTIONS.trxn_reference_number%TYPE;

BEGIN
	OPEN c_voided_transfers(p_payment_id);
	LOOP
		FETCH c_voided_transfers into
		      l_trxn_reference_number;
		EXIT WHEN c_voided_transfers%NOTFOUND or
					c_voided_transfers%NOTFOUND is NULL;

		UPDATE ce_payment_transactions
		SET trxn_status_code = 'CANCELED'
		WHERE trxn_reference_number = l_trxn_reference_number;

	END LOOP;
	CLOSE c_voided_transfers;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
RAISE;
END payment_voided;


END CE_PMT_CALLOUT_PKG;

/
