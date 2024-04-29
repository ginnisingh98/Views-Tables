--------------------------------------------------------
--  DDL for Package Body CS_CALCULATE_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CALCULATE_CREDIT" as
/* $Header: csxstsvb.pls 115.2 99/07/16 09:09:11 porting ship  $ */

procedure CS_CALCULATE_CREDIT(x_cp_service_id		   IN  NUMBER,
				x_terminate_effective_date IN  DATE,
				x_first_cp_service_txn_id  IN OUT NUMBER,
				x_first_amount		   IN OUT NUMBER,
				x_total_credit_amount      IN OUT NUMBER,
				x_total_credit_percent     IN OUT NUMBER,
				x_multi_txns		   In OUT VARCHAR2) IS

    days_in_original_service   NUMBER;
    days_in_terminated_service NUMBER;
    first_txn_credit	      NUMBER;
    first_cp_service_txn_id    NUMBER;
    txn_end		           DATE;
    current_end		      DATE;
    available_credit	      NUMBER;
    term_cp_serv_txn_id	      NUMBER;
    remain_credit_amount       NUMBER;
    first_amount	           NUMBER;
    total_serv_amount	      NUMBER;
    x_service_start_date       DATE;
    x_precision                NUMBER;
    x_ext_precision            NUMBER;
    x_Min_acct_unit            NUMBER;

  BEGIN

/* Why not INVOICED transactions only ?  */

    SELECT MAX(t.cp_service_transaction_id)
      INTO x_first_cp_service_txn_id
      FROM cs_cp_service_transactions   t
     WHERE t.cp_service_id = x_cp_service_id
       AND t.effective_start_date <= x_terminate_effective_date
       AND t.effective_end_date >= x_terminate_effective_date
       AND t.transaction_type_code in ('RENEW', 'ORDER');

    SELECT (t.current_end_date) - (t.effective_start_date),
	   (t.current_end_date) - (x_terminate_effective_date),
	    t.effective_end_date, t.current_end_date
      INTO days_in_original_service,
           days_in_terminated_service,
           txn_end,
           current_end
      FROM cs_cp_service_transactions t
     WHERE t.cp_service_transaction_id = x_first_cp_service_txn_id;

    SELECT (MAX(t.service_selling_price * cp.quantity) -
            SUM(NVL(t2.credit_amount,0)))
      INTO available_credit
      FROM cs_cp_service_transactions  t,
           cs_cp_service_transactions  t2,
           cs_cp_services s,
           cs_customer_products cp
     WHERE t.cp_service_transaction_id = x_first_cp_service_txn_id
       AND t.cp_service_transaction_id = t2.terminated_transaction_id(+)
       AND t.cp_service_id = s.cp_service_id
       AND s.customer_product_id = cp.customer_product_id;

    IF (current_end IS NOT NULL) THEN
       term_cp_serv_txn_id := x_first_cp_service_txn_id;
    ELSE
       SELECT MAX(cp_service_transaction_id)
         INTO term_cp_serv_txn_id
	 FROM cs_cp_service_transactions
	WHERE transaction_type_code = 'TERMINATE'
	  AND terminated_transaction_id = x_first_cp_service_txn_id
	  AND cp_service_id = x_cp_service_id;
    END IF;

    SELECT NVL(SUM(NVL(t.service_selling_price * cp.quantity , 0)) -
	       SUM(NVL(t.credit_amount, 0)),0)
      INTO remain_credit_amount
      FROM cs_cp_service_transactions  t,
	   cs_cp_services s,
	   cs_customer_products cp
     WHERE t.cp_service_transaction_id > term_cp_serv_txn_id
       AND t.cp_service_id = s.cp_service_id
       AND t.cp_service_id = x_cp_service_id
       AND t.ra_interface_status = 'INV'
       AND t.transaction_type_code in ('ORDER', 'RENEW', 'TERMINATE')
       AND s.customer_product_id = cp.customer_product_id;

    IF (remain_credit_amount = 0) THEN
      x_multi_txns := 'N';
    ELSE
      x_multi_txns := 'Y';
    END IF;

	IF (days_in_original_service <> 0) THEN
    		x_total_credit_amount := (available_credit *
			    (days_in_terminated_service /
			     days_in_original_service)) +
			    (remain_credit_amount);

    		x_first_amount := (available_credit *
			  (days_in_terminated_service /
			   days_in_original_service));

	ELSE
		 x_total_credit_amount := 0;
	END IF;

    total_serv_amount := available_credit + remain_credit_amount;

	IF (total_serv_amount <> 0) THEN
    		x_total_credit_percent := (((x_first_amount +
			               remain_credit_amount) * 100) /
			               total_serv_amount);
	ELSE
		x_total_credit_percent := 0 ;
	END IF ;


    EXCEPTION
	when NO_DATA_FOUND then
	  FND_MESSAGE.Set_Name('CS', 'CS_CALCULATE_CREDIT_FAILED');
	  APP_EXCEPTION.Raise_Exception;

  END;


PROCEDURE CREATE_INTERACTION_FROM_FORM(control_user_id        IN NUMBER,
                                       cp_cp_service_id       IN NUMBER,
							    parent_interaction_id  IN VARCHAR2,
							    cp_last_update_login   IN NUMBER,
							    cp_bill_to_contact_id  IN NUMBER,
							    return_status          OUT VARCHAR2,
							    return_msg             OUT VARCHAR2) IS

    l_ret_status                      VARCHAR2(1);
    l_msg_count                       NUMBER;
    l_interaction_id                  NUMBER;
    l_msg_data                        VARCHAR2(1000);
    l_ineraction_id                   NUMBER;
    l_customer_id                     NUMBER;
    l_employee_id                     NUMBER;
    l_validation_level                NUMBER;


BEGIN

    SELECT employee_id
    INTO   l_employee_id
    FROM   FND_USER
    WHERE  user_id = control_user_id;


    SELECT customer_id
    INTO   l_customer_id
    FROM   cs_customer_products
    WHERE  customer_product_id = (SELECT customer_product_id
						    FROM   cs_cp_services
						    WHERE  cp_service_id = cp_cp_service_id);

    return_status := NULL;
    return_msg    := NULL;
    IF l_customer_id IS NOT NULL THEN

	   CS_Interaction_PVT.Create_Interaction
		    (p_api_version                     => 1.0,
			p_init_msg_list                   => FND_API.G_TRUE,
			p_commit                          => FND_API.G_FALSE,
			p_validation_level                => FND_API.G_VALID_LEVEL_NONE,
			x_return_status                   => l_ret_status,
			x_msg_count                       => l_msg_count,
			x_msg_data                        => l_msg_data,
			p_resp_appl_id                    => NULL,
			p_resp_id                         => NULL,
			p_user_id                         => control_user_id,
			p_login_id                        => cp_last_update_login,
			p_org_id                          => FND_PROFILE.Value('ORG_ID'),
			p_customer_id                     => l_customer_id,
			p_contact_id                      => cp_bill_to_contact_id,
			p_contact_lastname                => NULL,
			p_contact_firstname               => NULL,
			p_phone_area_code                 => NULL,
			p_phone_number                    => NULL,
			p_phone_extension                 => NULL,
			p_fax_area_code                   => NULL,
			p_fax_number                      => NULL,
			p_email_address                   => NULL,
			p_interaction_type_code           => 'SRV_TER',
			p_interaction_category_code       => 'CS',
			p_interaction_method_code         => 'SYSTEM',
			p_interaction_date                => SYSDATE,
			p_interaction_document_code       => NULL,
			p_source_document_id              => NULL,
			p_source_document_name            => NULL,
			p_reference_form                  => NULL,
			p_source_document_status          => NULL,
			p_employee_id                     => l_employee_id,
			p_public_flag                     => NULL,
			p_follow_up_action                => NULL,
               p_notes                           => NULL,
			p_parent_interaction_id           => parent_interaction_id,
			p_attribute1                      => NULL,
			p_attribute2                      => NULL,
			p_attribute3                      => NULL,
			p_attribute4                      => NULL,
			p_attribute5                      => NULL,
			p_attribute6                      => NULL,
			p_attribute7                      => NULL,
			p_attribute8                      => NULL,
			p_attribute9                      => NULL,
			p_attribute10                     => NULL,
			p_attribute11                     => NULL,
			p_attribute12                     => NULL,
			p_attribute13                     => NULL,
			p_attribute14                     => NULL,
			p_attribute15                     => NULL,
               p_attribute_category              => NULL,
			x_interaction_id                  => l_interaction_id);
       return_status := l_ret_status;
	  return_msg := l_msg_data;
    END IF;

    IF (return_status = FND_API.G_RET_STS_ERROR OR
	   return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  -- 1 meaning error, 0 meaning OK
       return_status := '1';
    END IF;


  END CREATE_INTERACTION_FROM_FORM;

END CS_CALCULATE_CREDIT;


/
