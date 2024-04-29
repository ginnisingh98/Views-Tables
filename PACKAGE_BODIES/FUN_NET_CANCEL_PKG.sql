--------------------------------------------------------
--  DDL for Package Body FUN_NET_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_CANCEL_PKG" AS
/* $Header: funntcrb.pls 120.7.12010000.5 2009/12/14 14:36:54 ychandra ship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

	--Declare all required global variables
    g_user_id               NUMBER;
    g_login_id              NUMBER;
    g_today                 DATE;
    g_batch_status          fun_net_batches.batch_status_code%TYPE;

 /*  Selects the Batch Status of the given Batch ids */

    PROCEDURE get_batch_status(
	   p_batch_id      IN fun_net_batches_all.batch_id%TYPE,
	   x_return_status OUT NOCOPY VARCHAR2)
    IS
    BEGIN
	x_return_status := FND_API.G_TRUE;

	SELECT  batch_status_code
	INTO	g_batch_status
	FROM
		fun_net_batches
	WHERE
		batch_id = p_batch_id;
    EXCEPTION

 	WHEN OTHERS THEN
	       x_return_status :=  FND_API.G_FALSE;
    END get_batch_status;

   /* Validates Batch Status :
   If mode = Cancel , then the batch should be in the following statuses
   'SELECTED','SUSPENDED','CANCELLED','REJECTED','ERROR'
   If mode = Reverse , then the batch should be in status 'COMPLETE' */

   PROCEDURE Validate_Batch_Status
		(p_mode 	 IN VARCHAR2,
		 p_batch_id 	 IN fun_net_batches.batch_id%TYPE,
		 x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status VARCHAR2(1);
  BEGIN
	x_return_status := FND_API.G_TRUE;
	IF p_mode IS NULL or p_batch_id IS NULL THEN
		x_return_status := FND_API.G_FALSE;
		RETURN;
	END IF;

	get_batch_status(
		p_batch_id	=> p_batch_id,
	        x_return_status => l_return_status);

	IF l_return_status = FND_API.G_TRUE THEN
       		 IF p_mode = 'CANCEL'  THEN
			  IF g_batch_status  NOT IN ('SELECTED','SUSPENDED',
                      		 'CANCELLED','REJECTED','ERROR') THEN
				x_return_status := FND_API.G_FALSE;
				RETURN;
			 END IF;
        	 ELSIF p_mode = 'REVERSE' THEN
                 	IF g_batch_status <> 'COMPLETE' THEN
				x_return_status := FND_API.G_FALSE;
				RETURN;
			END IF;
		END IF;

	ELSE
		x_return_status := FND_API.G_FALSE;
	END IF;
  EXCEPTION
	WHEN OTHERS THEN
	 x_return_status := FND_API.G_FALSE;
  END Validate_Batch_Status;

/* Unlocks AP Payment Schedule lines for the given batch if  the batch status is
 'SELECTED' or 'SUSPENDED' or 'ERROR' and deletes Netting AP Invoices in FUN_NET_AP_INVS given a Batch Id */

PROCEDURE delete_ap_invs (
		p_batch_id 	IN fun_net_batches.batch_id%TYPE,
		x_return_status OUT NOCOPY VARCHAR2)
IS
TYPE l_inv_tab_type IS TABLE OF fun_net_ap_invs.invoice_id%TYPE;
l_inv_tab l_inv_tab_type;

BEGIN
      x_return_status := FND_API.G_TRUE;

 /* Unlock AP Transactions if the Batch Status = SELECTED OR SUSPENDED OR ERROR
	   AR Transactions are not locked at this point */
   --Bug: 8342419
    IF (g_batch_status = 'SELECTED') OR (g_batch_status='ERROR') OR (g_batch_status='SUSPENDED')THEN
	    FUN_NET_ARAP_PKG.unlock_ap_pymt_schedules(
    		p_batch_id 	=> p_batch_id,
		x_return_status => x_return_status);
    END IF;

    IF x_return_status = FND_API.G_FALSE THEN
    	RETURN;
    END IF;

	SELECT invoice_id
	BULK COLLECT INTO l_inv_tab
	FROM  fun_net_ap_invs
	WHERE batch_id = p_batch_id;

	IF l_inv_tab.EXISTS(1) THEN

	FOR i IN l_inv_tab.FIRST..l_inv_tab.LAST
	LOOP
		FUN_NET_AP_INVS_PKG.Delete_Row(
			x_batch_id	 => p_batch_id,
			x_invoice_id	 => l_inv_tab(i));
	END LOOP;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
END delete_ap_invs;

/* Deletes Netting AR transactions for the given batch */

PROCEDURE delete_ar_txns (
		x_batch_id 	IN fun_net_batches.batch_id%TYPE,
		x_return_status OUT NOCOPY VARCHAR2)
IS
TYPE l_txn_tab_type IS TABLE OF fun_net_ar_txns.customer_trx_id%TYPE;
l_txn_tab l_txn_tab_type;

BEGIN
	x_return_status := FND_API.G_TRUE;
	SELECT customer_trx_id
	BULK COLLECT INTO l_txn_tab
	FROM  fun_net_ar_txns
	WHERE batch_id = x_batch_id;

	IF l_txn_tab.EXISTS(1) THEN

	FOR i IN l_txn_tab.FIRST..l_txn_tab.LAST
	LOOP
		FUN_NET_AR_TXNS_PKG.Delete_Row(
			x_batch_id		 => x_batch_id,
			x_customer_trx_id	 => l_txn_tab(i));
	END LOOP;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
END delete_ar_txns;

/* Gets the Agreement id for a given batch */

PROCEDURE get_agreement(
	p_batch_id	 IN fun_net_batches.batch_id%TYPE,
	x_agreement_id   OUT NOCOPY fun_net_agreements.agreement_id%TYPE,
	x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN
    	x_return_status := FND_API.G_TRUE;
	SELECT agreement_id
	INTO x_agreement_id
	FROM fun_net_batches
	WHERE batch_id = p_batch_id;
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
END get_agreement;


/* Deletes a Batch and all the transactions in a batch
   that is not in COMPLETE Status. Unlocks AP Transaction
   if the Batch Status  is 'SELECTED' */

    PROCEDURE cancel_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER) IS

        -- ***** local variables *****
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_agreement_id         fun_net_agreements.agreement_id%TYPE;



    BEGIN
        x_msg_count		:=	NULL;
        x_msg_data		:=	NULL;
        g_user_id               := fnd_global.user_id;
        g_login_id              := fnd_global.login_id;

        -- ****   Standard start of API savepoint  ****
        SAVEPOINT cancel_net_batch_SP;

        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- ****  Initialize return status to SUCCESS   *****
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

        /* Check for mandatory parameters */

	IF p_batch_id IS NULL THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

        IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Check the batch status before deleting */

        Validate_Batch_Status(
		p_mode 		=> 'CANCEL',
		p_batch_id 	=> p_batch_id,
		x_return_status => l_return_status);

	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;
        /* Get Agreement Id of the Batch */

        get_agreement(
        p_batch_id => p_batch_id,
        x_agreement_id => l_agreement_id,
        x_return_status => x_return_status);

         IF l_return_status = FND_API.G_FALSE THEN
	    	RAISE FND_API.G_EXC_ERROR;
	    END IF;

        /* Check Agreement Status and unset the in process flag so that
          agreement can be used again */

	 FUN_NET_ARAP_PKG.Set_Agreement_Status(
	    x_batch_id    => p_batch_id,
            x_agreement_id => l_agreement_id,
            x_mode	   => 'UNSET',
	    x_return_status => l_return_status);

	    IF l_return_status = FND_API.G_FALSE THEN
	    	RAISE FND_API.G_EXC_ERROR;
	    END IF;


      /* Delete  AP Invoices belonging to the Batch */

	 delete_ap_invs(
		p_batch_id 	=> p_batch_id,
		x_return_status => l_return_status);


	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	/* Delete AR Transactions belonging to the Batch */
 	  delete_ar_txns(
		x_batch_id	=> p_batch_id,
		x_return_status => l_return_status);

	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	/* Delete the Batch */

        FUN_NET_BATCHES_PKG.Delete_Row(
		x_batch_id => p_batch_id);

 	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO cancel_net_batch_SP;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
		p_data	   =>  x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO cancel_net_batch_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO Cancel_Net_Batch_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'cancel_net_batch');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );

    END cancel_net_batch;

    PROCEDURE Validate_Settlement_Period(
	x_appln_id       IN fnd_application.application_id%TYPE,
	p_batch_id       IN fun_net_batches_all.batch_id%TYPE,
	p_reversal_date  IN DATE,            -- Bug # 9196412
	x_period_name    OUT NOCOPY VARCHAR2,
        x_return_status  OUT NOCOPY VARCHAR2,
	x_return_msg	  OUT NOCOPY VARCHAR2)

    IS

    CURSOR c_get_batch_details IS
    SELECT org_id,
            gl_date,
            settlement_date
    FROM fun_net_batches_all
    WHERE batch_id = p_batch_id;

        l_ledger_id         gl_ledgers.ledger_id%TYPE;
        l_ledger_name       gl_ledgers.name%TYPE;
	x_closing_status	gl_period_statuses.closing_status%TYPE;
	x_period_year		gl_period_statuses.period_year%TYPE;
    	x_period_num		gl_period_statuses.period_num%TYPE;
    	x_period_type		gl_period_statuses.period_type%TYPE;
    l_org_id    fun_net_batches_all.org_id%TYPE;
    l_gl_date   fun_net_batches_all.gl_date%TYPE;
    l_settlement_date fun_net_batches_all.settlement_date%TYPE;

    l_path  VARCHAR2(100);
	BEGIN
        l_path := g_path || 'Validate_Settlement_period';

      /* Check if GL Period is open*/
         x_return_status := FND_API.G_TRUE;
        OPEN c_get_batch_details;
        FETCH c_get_batch_details INTO l_org_id,l_gl_date,l_settlement_date;
        CLOSE c_get_batch_details;

        fun_net_util.Log_String(g_state_level,l_path,'Fetching ledger for org_id :'|| l_org_id);
        MO_Utils.Get_Ledger_Info(
                    l_org_id,
                    l_ledger_id,
                    l_ledger_name);

         /*SELECT set_of_books_id
    	 	 INTO l_ledger_id
		 FROM hr_operating_units
		 WHERE organization_id = g_batch_details.org_id; */
        fun_net_util.Log_String(g_state_level,l_path,'Ledger_id :'||l_ledger_id);
                -- Bug: 8509936.
		GL_PERIOD_STATUSES_PKG.get_period_by_date(
		   x_appln_id,
		   l_ledger_id,
		  --nvl(l_gl_date,l_settlement_date),
		  trunc(p_reversal_date),                 -- Bug # 9196412
		  x_period_name,
		  x_closing_status,
 	          x_period_year,
		  x_period_num,
	          x_period_type);
        fun_net_util.Log_String(g_state_level,l_path,'After getting period status');
		IF (x_period_name IS NULL and x_closing_status IS NULL) OR
		   x_closing_status not in ('O','F') THEN
			x_return_status := FND_API.G_FALSE;
			fun_net_util.Log_String(g_state_level,l_path,'Period not open');
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;
	END Validate_Settlement_Period;

 /* Validates the GL Period before reversing AP Checks created for the batch.
   Calls AP Reverse API to reverse a check */

    PROCEDURE reverse_ap_checks(
	p_batch_id	 IN fun_net_batches.batch_id%TYPE,
	x_return_status OUT NOCOPY VARCHAR2)
    IS
	CURSOR ap_reverse_cur(p_batch_id IN NUMBER) IS
	SELECT 	DISTINCT check_id AS check_id
	FROM 	fun_net_ap_invs_all
	WHERE 	batch_id = p_batch_id
        AND     check_id is not null;

	CURSOR c_get_batch_details IS                                -- Bug # 8904763
	SELECT gl_date,
	settlement_date
	FROM fun_net_batches_all
	WHERE batch_id = p_batch_id;

	l_return_status VARCHAR2(1);
	l_return_msg VARCHAR2(1000);
	l_period_name gl_period_statuses.period_name%TYPE;
	l_num_cancelled NUMBER;
	l_num_not_cancelled NUMBER;
	l_msg_count	NUMBER;
	l_msg_data VARCHAR2(1000);
	l_path VARCHAR2(100);
	l_gl_date   fun_net_batches_all.gl_date%TYPE;                -- Bug # 8904763
	l_settlement_date fun_net_batches_all.settlement_date%TYPE;  -- Bug # 8904763
	l_reversal_date DATE;            -- Bug # 8904763

    BEGIN
    l_path := g_path || 'reverse_ap_checks';
	x_return_status := FND_API.G_TRUE;


	OPEN c_get_batch_details;                                        -- Bug # 8904763
	FETCH c_get_batch_details INTO l_gl_date,l_settlement_date;
	CLOSE c_get_batch_details;

	IF l_gl_date IS NULL THEN                                           -- Bug # 8904763
		l_reversal_date:=l_settlement_date;
	Else
		l_reversal_date:=l_gl_date;
	END IF;

	SELECT GREATEST(SYSDATE,l_reversal_date) INTO l_reversal_date FROM dual;   -- Bug # 9196412


	/* Validate GL Period */
    fun_net_util.Log_String(g_state_level,l_path,'Validating settlement period');
     Validate_Settlement_Period(
	x_appln_id       => 200,
	p_batch_id       => p_batch_id,
	p_reversal_date => l_reversal_date,
	x_period_name	 => l_period_name,
        x_return_status  => l_return_status,
	x_return_msg	 => l_return_msg);

	IF l_return_status = FND_API.G_FALSE THEN
		x_return_status := FND_API.G_FALSE;
		RETURN;
	END IF;


	FOR ap_reverse_rec IN ap_reverse_cur(p_batch_id)
	LOOP
    fun_net_util.Log_String(g_state_level,l_path,'Reversing check for batch:'||p_batch_id);

    fun_net_util.Log_String(g_state_level,l_path,'Reversing check for check :'||ap_reverse_rec.check_id);

  	AP_VOID_PKG.Ap_Reverse_Check(
          P_Check_Id                    => ap_reverse_rec.check_id,
          P_Replace_Flag                => 'N',
          P_Reversal_Date               =>  l_reversal_date,              -- Bug # 8904763
          P_Reversal_Period_Name        =>  l_period_name,
          P_Checkrun_Name               =>  '',
          P_Invoice_Action              => 'NONE',
          P_Hold_Code                   => '',
          P_Hold_Reason                 => '',
          P_Sys_Auto_Calc_Int_Flag      => 'N',
          P_Vendor_Auto_Calc_Int_Flag   => 'N',
          P_Last_Updated_By             => g_user_id,
          P_Last_Update_Login           => g_login_id,
          P_Num_Cancelled               => l_num_cancelled,
          P_Num_Not_Cancelled           => l_num_not_cancelled,
          P_Calling_Sequence            => 'Netting Batch - Reversing',
          X_return_status               => l_return_status,
          X_msg_count                   => l_msg_count,
          X_msg_data                    => l_msg_data);


	  IF l_return_status = FND_API.G_FALSE THEN
		x_return_status := FND_API.G_FALSE;
		RETURN;
	  END IF;

	END LOOP;
    fun_net_util.Log_String(g_state_level,l_path,'Successfully reversed AP invoices');
    EXCEPTION
    	WHEN OTHERS THEN
    		x_return_status := FND_API.G_FALSE;
    END reverse_ap_checks;

/* Validates the GL Period for the Reversal Date. If the Period is not 'Open'
  or 'Future' then raises an error.
  Calls AR Reverse API to reverse the receipts created for the batch        */

    PROCEDURE reverse_ar_receipts(
	p_batch_id	IN fun_net_batches.batch_id%TYPE,
	x_return_status OUT NOCOPY VARCHAR2)
    IS
	l_period_name GL_PERIOD_STATUSES.period_name%TYPE;

  	CURSOR ar_txn_cur(p_batch_id IN NUMBER) IS
	SELECT	DISTINCT txn.cash_receipt_id,
		cr.receipt_number,
		cr.receipt_date,
		txn.org_id
	FROM
		fun_net_ar_txns txn,
		ar_cash_receipts_all cr
	WHERE	txn.batch_id = p_batch_id
	AND	txn.cash_receipt_id = cr.cash_receipt_id
    AND txn.org_id = cr.org_id;

   /* p_receipt_gl_date should be populated as the max(gl_date) from CRH */
    CURSOR c_get_reverse_gl_date(p_cr_id IN NUMBER) IS
    SELECT max(crh.gl_date)
    FROM   ar_cash_receipt_history crh
    WHERE  crh.cash_receipt_id = p_cr_id;

	l_msg_data	VARCHAR2(1000);
	l_msg_count	NUMBER;
	l_return_status VARCHAR2(1);
	l_reverse_gl_date DATE;
	l_reversal_date    DATE;
    l_path  VARCHAR2(100);
    BEGIN
    l_path := g_path || 'reverse_ar_receipts';
	x_return_status := FND_API.G_TRUE;


	FOR ar_txn_rec IN ar_txn_cur(p_batch_id)
	LOOP
        fun_net_util.Log_String(g_state_level,l_path,'Reversing transactions for batch:'||p_batch_id);
        l_reversal_date := ar_txn_rec.receipt_date;
        IF TRUNC(SYSDATE) >= l_reversal_date THEN
            l_reversal_date := TRUNC(SYSDATE);
        END IF;

        OPEN c_get_reverse_gl_date(ar_txn_rec.cash_receipt_id);
        FETCH c_get_reverse_gl_date INTO l_reverse_gl_date;
        CLOSE c_get_reverse_gl_date;

        IF TRUNC(SYSDATE) >= l_reverse_gl_date THEN
            l_reverse_gl_date := TRUNC(SYSDATE);
        END IF;

	fun_net_util.Log_String(g_state_level,l_path,'Validating AR period');
	Validate_Settlement_Period(
		x_appln_id       => 222,
		p_batch_id       => p_batch_id,
		p_reversal_date => l_reverse_gl_date,                        -- Bug # 9196412
		x_period_name	 => l_period_name,
 		x_return_status  => x_return_status,
		x_return_msg	 => l_msg_data);

	IF x_return_status = FND_API.G_FALSE THEN
		RETURN;
	END IF;

	   AR_RECEIPT_API_PUB.Reverse(
	-- Standard API parameters.
	      p_api_version             => 1.0,
	      p_init_msg_list           => FND_API.G_TRUE,
	      p_commit                  => FND_API.G_FALSE,
	      p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
	      x_return_status           => l_return_status,
	      x_msg_count               => l_msg_count,
	      x_msg_data                => l_msg_data,
	-- Receipt reversal related parameters
	      p_cash_receipt_id         => ar_txn_rec.cash_receipt_id,
	      --p_receipt_number          => ar_txn_rec.receipt_number,
	      p_reversal_category_code  => 'REV',
	      p_reversal_gl_date        => l_reverse_gl_date,
	      p_reversal_date           => l_reversal_date,
	      p_reversal_reason_code    => 'PAYMENT REVERSAL',
	      p_org_id                  => ar_txn_rec.org_id
	      );


         FND_MSG_PUB.Count_And_Get (
                    p_count    =>  l_msg_count,
                    p_data     =>  l_msg_data );

        fun_net_util.Log_String(g_event_level,l_path
                ,'apply cash receipt package after       AR_RECEIPT_API_PUB.Reverse:' ||l_msg_data);

           IF l_msg_count > 1 THEN



                FOR x IN 1..l_msg_count LOOP

                  l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  fun_net_util.Log_String(g_event_level,l_path
                        ,'Reverse package Error message  AR_RECEIPT_API_PUB.Reverse' ||l_msg_data||'  '||'  '||x);

                END LOOP;


            END IF;
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			fun_net_util.Log_String(g_state_level,l_path,'Error in reversing AR transactions');
            x_return_status := FND_API.G_FALSE;
			RETURN;
		END IF;
 	END LOOP;
    fun_net_util.Log_String(g_state_level,l_path,'Successfully reversed AR transactions');
    EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_FALSE;

    END reverse_ar_receipts;

    PROCEDURE Update_Amounts(
    	p_batch_id IN fun_net_batches.batch_id%TYPE,
    	x_return_status OUT NOCOPY VARCHAR2)
    IS
    BEGIN
    	BEGIN
	    	UPDATE FUN_NET_AP_INVS
    		SET netted_amt = 0
    		WHERE batch_id = p_batch_id;
    	EXCEPTION
    		WHEN OTHERS THEN
    		x_return_status := FND_API.G_FALSE;
    		RETURN;
    	END;
    	BEGIN
    	UPDATE FUN_NET_AR_TXNS
    	SET netted_amt = 0
    	WHERE batch_id = p_batch_id;
    	EXCEPTION
    		WHEN OTHERS THEN
    		x_return_status := FND_API.G_FALSE;
    		RETURN;
    	END;
    	BEGIN
    	UPDATE FUN_NET_BATCHES
    	SET total_netted_amt = 0
    	WHERE batch_id = p_batch_id;
    	EXCEPTION
    		WHEN OTHERS THEN
    		x_return_status := FND_API.G_FALSE;
    		RETURN;
    	END;
    EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_FALSE;

    END;

    PROCEDURE reverse_net_batch(
            -- ***** Standard API Parameters *****
            p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
            p_commit        IN VARCHAR2 := FND_API.G_FALSE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count     OUT NOCOPY NUMBER,
            x_msg_data      OUT NOCOPY VARCHAR2,
            -- ***** Netting batch input parameters *****
            p_batch_id      IN NUMBER) IS

        -- ***** local variables *****
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

	l_agreement_id 	FUN_NET_AGREEMENTS.AGREEMENT_ID%TYPE;
    l_path  VARCHAR2(100);
    BEGIN
        l_path := g_path || 'reverse_net_batch';
        x_msg_count		:=	NULL;
        x_msg_data		:=	NULL;
        g_user_id               := fnd_global.user_id;
        g_login_id              := fnd_global.login_id;

        -- ****   Standard start of API savepoint  ****
        SAVEPOINT reverse_net_batch_SP;
        fun_net_util.Log_String(g_state_level,l_path,'Set the savepoint');
        -- ****  Initialize message list if p_init_msg_list is set to TRUE. ****
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- ****  Initialize return status to SUCCESS   *****
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        /*-----------------------------------------------+
        |   ========  START OF API BODY  ============   |
        +-----------------------------------------------*/

        /* Check for mandatory parameters */

	IF p_batch_id IS NULL THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

        IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Check the batch status before reversing */
        fun_net_util.Log_String(g_state_level,l_path,'Validating batch status');
        Validate_Batch_Status(
		p_mode 		=> 'REVERSE',
		p_batch_id 	=> p_batch_id,
		x_return_status => l_return_status);

	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Update Batch Status to Reversing */
        fun_net_util.Log_String(g_state_level,l_path,'Updating batch status');
	IF NOT FUN_NET_ARAP_PKG.update_batch_status('REVERSING') THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

        /* Reverse the Checks for the AP Invoices in the given batch */
        fun_net_util.Log_String(g_state_level,l_path,'Reversing AP checks');
           reverse_ap_checks(
		p_batch_id 	=> p_batch_id,
		x_return_status => l_return_status);

	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	/* Reverse the Receipts created for the AR Txns in the batch */
        fun_net_util.Log_String(g_state_level,l_path,'Reversing AR receipts');
	    reverse_ar_receipts(
		p_batch_id	=> p_batch_id,
		x_return_status => l_return_status);

	IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

       /* Update Agreement Status */
    fun_net_util.Log_String(g_state_level,l_path,'Get agreement');
    get_agreement(
	   p_batch_id	 => p_batch_id,
	   x_agreement_id   => l_agreement_id,
	   x_return_status => l_return_status);

    IF l_return_status = FND_API.G_FALSE THEN
	   RAISE FND_API.G_EXC_ERROR;
    END IF;
    fun_net_util.Log_String(g_state_level,l_path,'Updating agreement status to N');
    FUN_NET_ARAP_PKG.Set_Agreement_Status(
            x_batch_id  => p_batch_id,
            x_agreement_id => l_agreement_id,
            x_mode	    => 'UNSET',
	    x_return_status => l_return_status);

   IF l_return_status = FND_API.G_FALSE THEN
   	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	/* Update Amounts */
        fun_net_util.Log_String(g_state_level,l_path,'Updating batch amounts');
	 Update_amounts(
	 	p_batch_id => p_batch_id,
	 	x_return_status => l_return_status);

	 	IF l_return_status = FND_API.G_FALSE THEN
   	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	/* Update Batch Status */
        fun_net_util.Log_String(g_state_level,l_path,'Updating batch status to REVERSED');
	   UPDATE fun_net_batches
       SET batch_status_code = 'REVERSED'
       WHERE batch_id = p_batch_id;

    /*IF NOT FUN_NET_ARAP_PKG.update_batch_status('REVERSED') THEN

	   RAISE FND_API.G_EXC_ERROR;
	END IF; */

 	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;

        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'Successfully batch reversal');
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Reverse_net_batch_SP;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO reverse_net_batch_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO reverse_Net_Batch_SP;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               --FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
            FND_MSG_PUB.Add_Exc_Msg( 'FUN_ARAP_NET_PKG', 'reverse_net_batch');
            END IF;
            FND_MSG_PUB.Count_And_Get (
                p_count    =>  x_msg_count,
                p_data     =>  x_msg_data );
	END reverse_net_batch;

BEGIN
    g_today := TRUNC(sysdate);
 --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        :=    'FUN.PLSQL.funntcrb.FUN_NET_CANCEL_PKG.';

--===========================FND_LOG.END=======================================

END FUN_NET_CANCEL_PKG;

/
