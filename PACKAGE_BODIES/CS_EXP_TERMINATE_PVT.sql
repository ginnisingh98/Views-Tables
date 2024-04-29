--------------------------------------------------------
--  DDL for Package Body CS_EXP_TERMINATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_EXP_TERMINATE_PVT" as
/* $Header: csctexpb.pls 115.4 99/07/16 08:52:11 porting ship  $ */
TYPE RContract_Rec_Type IS RECORD (
    CONTRACT_ID                    CS_CONTRACTS_ALL.CONTRACT_ID%TYPE := NULL,
    CONTRACT_NUMBER                CS_CONTRACTS_ALL.CONTRACT_NUMBER%TYPE := NULL,
    PRICE_LIST_ID                  CS_CONTRACTS_ALL.PRICE_LIST_ID%TYPE := NULL,
    CURRENCY_CODE                  CS_CONTRACTS_ALL.CURRENCY_CODE%TYPE := NULL,
    INVOICING_RULE_ID              CS_CONTRACTS_ALL.INVOICING_RULE_ID%TYPE := NULL,
    ACCOUNTING_RULE_ID             CS_CONTRACTS_ALL.ACCOUNTING_RULE_ID%TYPE := NULL,
    BILL_TO_SITE_USE_ID            CS_CONTRACTS_ALL.BILL_TO_SITE_USE_ID%TYPE := NULL,
    CONTRACT_STATUS_ID             CS_CONTRACTS_ALL.CONTRACT_STATUS_ID%TYPE := NULL,
    CONTRACT_TYPE_ID               CS_CONTRACTS_ALL.CONTRACT_TYPE_ID%TYPE := NULL,
    CUSTOMER_ID                    CS_CONTRACTS_ALL.CUSTOMER_ID%TYPE := NULL,
    DURATION                       CS_CONTRACTS_ALL.DURATION%TYPE := NULL,
    PERIOD_CODE                    CS_CONTRACTS_ALL.PERIOD_CODE%TYPE := NULL,
    START_DATE_ACTIVE              CS_CONTRACTS_ALL.START_DATE_ACTIVE%TYPE := NULL,
    END_DATE_ACTIVE                CS_CONTRACTS_ALL.END_DATE_ACTIVE%TYPE := NULL,
    AGREEMENT_ID                   CS_CONTRACTS_ALL.AGREEMENT_ID%TYPE := NULL,
    BILLING_FREQUENCY_PERIOD       CS_CONTRACTS_ALL.BILLING_FREQUENCY_PERIOD%TYPE := NULL,
    BILL_ON                        CS_CONTRACTS_ALL.BILL_ON%TYPE  := NULL,
    FIRST_BILL_DATE                CS_CONTRACTS_ALL.FIRST_BILL_DATE%TYPE := NULL,
    NEXT_BILL_DATE                 CS_CONTRACTS_ALL.NEXT_BILL_DATE%TYPE := NULL,
    SALESPERSON_ID                 CS_CONTRACTS_ALL.SALESPERSON_ID%TYPE := NULL,
    ORDERED_BY_CONTACT_ID          CS_CONTRACTS_ALL.ORDERED_BY_CONTACT_ID%TYPE := NULL,
    CONTRACT_TEMPLATE_ID           CS_CONTRACTS_ALL.CONTRACT_TEMPLATE_ID%TYPE := NULL,
    CONTRACT_GROUP_ID              CS_CONTRACTS_ALL.CONTRACT_GROUP_ID%TYPE := NULL,
    WORKFLOW                       CS_CONTRACTS_ALL.WORKFLOW%TYPE := NULL,
    WORKFLOW_PROCESS_ID            CS_CONTRACTS_ALL.WORKFLOW_PROCESS_ID%TYPE := NULL,
    CREATE_SALES_ORDER             CS_CONTRACTS_ALL.CREATE_SALES_ORDER%TYPE := NULL,
    SHIP_TO_SITE_USE_ID            CS_CONTRACTS_ALL.SHIP_TO_SITE_USE_ID%TYPE := NULL,
    RENEWAL_RULE                   CS_CONTRACTS_ALL.RENEWAL_RULE%TYPE := NULL,
    TERMINATION_RULE               CS_CONTRACTS_ALL.TERMINATION_RULE%TYPE := NULL,
    CONVERSION_TYPE_CODE           CS_CONTRACTS_ALL.CONVERSION_TYPE_CODE%TYPE := NULL,
    CONVERSION_RATE                CS_CONTRACTS_ALL.CONVERSION_RATE%TYPE := NULL,
    CONVERSION_DATE                CS_CONTRACTS_ALL.CONVERSION_DATE%TYPE := NULL,
    SOURCE_CODE                    CS_CONTRACTS_ALL.SOURCE_CODE%TYPE := NULL,
    SOURCE_REFERENCE               CS_CONTRACTS_ALL.SOURCE_REFERENCE%TYPE := NULL,
    TERMS_ID                       CS_CONTRACTS_ALL.TERMS_ID%TYPE := NULL,
    PO_NUMBER                      CS_CONTRACTS_ALL.PO_NUMBER%TYPE := NULL,
    TAX_HANDLING                   CS_CONTRACTS_ALL.TAX_HANDLING%TYPE := NULL,
    TAX_EXEMPT_NUM                 CS_CONTRACTS_ALL.TAX_EXEMPT_NUM%TYPE := NULL,
    TAX_EXEMPT_REASON_CODE         CS_CONTRACTS_ALL.TAX_EXEMPT_REASON_CODE%TYPE := NULL,
    CONTRACT_AMOUNT                CS_CONTRACTS_ALL.CONTRACT_AMOUNT%TYPE := NULL,
    AUTO_RENEWAL_FLAG              CS_CONTRACTS_ALL.AUTO_RENEWAL_FLAG%TYPE := NULL,
    ORIGINAL_END_DATE              CS_CONTRACTS_ALL.ORIGINAL_END_DATE%TYPE := NULL,
    TERMINATE_REASON_CODE          CS_CONTRACTS_ALL.TERMINATE_REASON_CODE%TYPE := NULL,
    DISCOUNT_ID                    CS_CONTRACTS_ALL.DISCOUNT_ID%TYPE := NULL,
    ATTRIBUTE1                     CS_CONTRACTS_ALL.ATTRIBUTE1%TYPE := NULL,
    ATTRIBUTE2                     CS_CONTRACTS_ALL.ATTRIBUTE2%TYPE := NULL,
    ATTRIBUTE3                     CS_CONTRACTS_ALL.ATTRIBUTE3%TYPE := NULL,
    ATTRIBUTE4                     CS_CONTRACTS_ALL.ATTRIBUTE4%TYPE := NULL,
    ATTRIBUTE5                     CS_CONTRACTS_ALL.ATTRIBUTE5%TYPE := NULL,
    ATTRIBUTE6                     CS_CONTRACTS_ALL.ATTRIBUTE6%TYPE := NULL,
    ATTRIBUTE7                     CS_CONTRACTS_ALL.ATTRIBUTE7%TYPE := NULL,
    ATTRIBUTE8                     CS_CONTRACTS_ALL.ATTRIBUTE8%TYPE := NULL,
    ATTRIBUTE9                     CS_CONTRACTS_ALL.ATTRIBUTE9%TYPE := NULL,
    ATTRIBUTE10                    CS_CONTRACTS_ALL.ATTRIBUTE10%TYPE := NULL,
    ATTRIBUTE11                    CS_CONTRACTS_ALL.ATTRIBUTE11%TYPE := NULL,
    ATTRIBUTE12                    CS_CONTRACTS_ALL.ATTRIBUTE12%TYPE := NULL,
    ATTRIBUTE13                    CS_CONTRACTS_ALL.ATTRIBUTE13%TYPE := NULL,
    ATTRIBUTE14                    CS_CONTRACTS_ALL.ATTRIBUTE14%TYPE := NULL,
    ATTRIBUTE15                    CS_CONTRACTS_ALL.ATTRIBUTE15%TYPE := NULL,
    CONTEXT                        CS_CONTRACTS_ALL.CONTEXT%TYPE := NULL,
    OBJECT_VERSION_NUMBER          CS_CONTRACTS_ALL.OBJECT_VERSION_NUMBER%TYPE := NULL,
    PO_REQUIRED_TO_SERVICE         CS_CONTRACTS_ALL.PO_REQUIRED_TO_SERVICE%TYPE := NULL,
    PRE_PAYMENT_REQUIRED           CS_CONTRACTS_ALL.PRE_PAYMENT_REQUIRED%TYPE := NULL    );
  G_MISS_rcontract_rec                     RContract_Rec_Type;


 PROCEDURE Populate_Contracts(p_from        IN  RContract_Rec_Type ,
                               P_to          OUT CS_CONTRACT_PVT.Contract_Val_Rec_Type ,
                               p_status_id   IN  NUMBER) IS
  BEGIN
    p_to.contract_id                     := p_from.contract_id;
    p_to.contract_number                     := p_from.contract_number;
    p_to.workflow                            := p_from.workflow;
    p_to.workflow_process_id                 := p_from.workflow_process_id;
    p_to.agreement_id                        := p_from.agreement_id;
    p_to.price_list_id                       := p_from.price_list_id;
    p_to.currency_code                       := p_from.currency_code;
    p_to.conversion_type_code                := p_from.conversion_type_code;
    p_to.conversion_rate                     := p_from.conversion_rate;
    p_to.conversion_date                     := p_from.conversion_date;
    p_to.invoicing_rule_id                   := p_from.invoicing_rule_id;
    p_to.accounting_rule_id                  := p_from.accounting_rule_id;
    p_to.billing_frequency_period            := p_from.billing_frequency_period;
    p_to.bill_on                             := p_from.bill_on;
    p_to.first_bill_date                     := p_from.first_bill_date;
    p_to.next_bill_date                      := p_from.next_bill_date;
    p_to.create_sales_order                  := p_from.create_sales_order;
    p_to.renewal_rule                        := p_from.renewal_rule;
    p_to.termination_rule                    := p_from.termination_rule;
    p_to.bill_to_site_use_id                 := p_from.bill_to_site_use_id;
    p_to.contract_status_id                  := p_status_id;
    p_to.contract_type_id                    := p_from.contract_type_id;
    p_to.contract_template_id                := p_from.contract_template_id;
    p_to.contract_group_id                   := p_from.contract_group_id;
    p_to.customer_id                         := p_from.customer_id;
    p_to.duration                            := p_from.duration;
    p_to.period_code                         := p_from.period_code;
    p_to.ship_to_site_use_id                 := p_from.ship_to_site_use_id;
    p_to.salesperson_id                      := p_from.salesperson_id;
    p_to.ordered_by_contact_id               := p_from.ordered_by_contact_id;
    p_to.source_code                         := p_from.source_code;
    p_to.source_reference                    := p_from.source_reference;
    p_to.terms_id                            := p_from.terms_id;
    p_to.po_number                           := p_from.po_number;
    p_to.tax_handling                        := p_from.tax_handling;
    p_to.tax_exempt_num                      := p_from.tax_exempt_num;
    p_to.tax_exempt_reason_code              := p_from.tax_exempt_reason_code;
    p_to.contract_amount                     := p_from.contract_amount;
    p_to.auto_renewal_flag                   := p_from.auto_renewal_flag;
    p_to.original_end_date                   := p_from.original_end_date;
    p_to.terminate_reason_code               := p_from.terminate_reason_code;
    p_to.discount_id                         := p_from.discount_id;
    p_to.start_date_active                   := p_from.start_date_active;
    p_to.end_date_active                     := p_from.end_date_active;
    p_to.attribute1                          := p_from.attribute1;
    p_to.attribute2                          := p_from.attribute2;
    p_to.attribute3                          := p_from.attribute3;
    p_to.attribute4                          := p_from.attribute4;
    p_to.attribute5                          := p_from.attribute5;
    p_to.attribute6                          := p_from.attribute6;
    p_to.attribute7                          := p_from.attribute7;
    p_to.attribute8                          := p_from.attribute8;
    p_to.attribute9                          := p_from.attribute9;
    p_to.attribute10                         := p_from.attribute10;
    p_to.attribute11                         := p_from.attribute11;
    p_to.attribute12                         := p_from.attribute12;
    p_to.attribute13                         := p_from.attribute13;
    p_to.attribute14                         := p_from.attribute14;
    p_to.attribute15                         := p_from.attribute15;
    p_to.context                             := p_from.context;
    p_to.object_version_number               := p_from.object_version_number;
    p_to.po_required_to_service              := p_from.po_required_to_service;
    p_to.pre_payment_required                := p_from.pre_payment_required;

    TAPI_DEV_KIT.Get_Who_Info (
						 p_to.Creation_Date,
						 p_to.Created_By,
						 p_to.Last_Update_Date,
						 p_to.Last_Updated_By,
						 p_to.Last_Update_Login);
  END Populate_Contracts;


PROCEDURE exp_terminate_contract
			(
			exp_term_date in DATE
			)IS

---variables declared here

contract_rec  cs_contract_pvt.Contract_Val_Rec_Type := cs_contract_pvt.G_MISS_CONTRACT_VAL_REC;
lcontract_rec  RContract_Rec_Type;



LOOPING BOOLEAN := TRUE;
v_return_status VARCHAR2(1);
v_msg_count NUMBER;
v_msg_data VARCHAR2(2000);
v_contract_id NUMBER;
v_object_version_number	NUMBER;
x_object_version_number NUMBER;
msg1 VARCHAR2(240);
msg2 VARCHAR2(240);
v_counter NUMBER := 0;




v_status_id NUMBER;
v_expire_status_id NUMBER;
v_terminate_status_id NUMBER;
-- Global var holding the User Id
     user_id             NUMBER;

-- Global var to hold the ERROR value.
     ERROR                NUMBER := 1;

-- Global var to hold the SUCCESS value.
     SUCCESS           NUMBER := 0;

-- Global var holding the Current Error code for the error encountered
     Current_Error_Code   Varchar2(20) := NULL;

-- Global var to hold the Concurrent Process return values
   conc_ret_code          NUMBER := SUCCESS;
   v_retcode   NUMBER := SUCCESS;
CONC_STATUS BOOLEAN;




CURSOR C1 IS
   SELECT
           CONTRACT_ID                    ,
           CONTRACT_NUMBER                ,
           PRICE_LIST_ID                  ,
           CURRENCY_CODE                  ,
           INVOICING_RULE_ID              ,
           ACCOUNTING_RULE_ID             ,
           BILL_TO_SITE_USE_ID            ,
           CONTRACT_STATUS_ID             ,
           CONTRACT_TYPE_ID               ,
           CUSTOMER_ID                    ,
           DURATION                       ,
           PERIOD_CODE                    ,
           START_DATE_ACTIVE              ,
           END_DATE_ACTIVE                ,
           AGREEMENT_ID                   ,
           BILLING_FREQUENCY_PERIOD       ,
           BILL_ON                        ,
           FIRST_BILL_DATE                ,
           NEXT_BILL_DATE                 ,
           SALESPERSON_ID                 ,
           ORDERED_BY_CONTACT_ID          ,
           CONTRACT_TEMPLATE_ID           ,
           CONTRACT_GROUP_ID              ,
           WORKFLOW                       ,
           WORKFLOW_PROCESS_ID            ,
           CREATE_SALES_ORDER             ,
           SHIP_TO_SITE_USE_ID            ,
           RENEWAL_RULE                   ,
           TERMINATION_RULE               ,
           CONVERSION_TYPE_CODE           ,
           CONVERSION_RATE                ,
           CONVERSION_DATE                ,
           SOURCE_CODE                    ,
           SOURCE_REFERENCE               ,
           TERMS_ID                       ,
           PO_NUMBER                      ,
           TAX_HANDLING                   ,
           TAX_EXEMPT_NUM                 ,
           TAX_EXEMPT_REASON_CODE         ,
           CONTRACT_AMOUNT                ,
           AUTO_RENEWAL_FLAG              ,
           ORIGINAL_END_DATE              ,
           TERMINATE_REASON_CODE          ,
           DISCOUNT_ID                    ,
           ATTRIBUTE1                     ,
           ATTRIBUTE2                     ,
           ATTRIBUTE3                     ,
           ATTRIBUTE4                     ,
           ATTRIBUTE5                     ,
           ATTRIBUTE6                     ,
           ATTRIBUTE7                     ,
           ATTRIBUTE8                     ,
           ATTRIBUTE9                     ,
           ATTRIBUTE10                    ,
           ATTRIBUTE11                    ,
           ATTRIBUTE12                    ,
           ATTRIBUTE13                    ,
           ATTRIBUTE14                    ,
           ATTRIBUTE15                    ,
           CONTEXT                        ,
           OBJECT_VERSION_NUMBER          ,
           PO_REQUIRED_TO_SERVICE         ,
           PRE_PAYMENT_REQUIRED
    FROM   CS_CONTRACTS
where exp_term_date < cs_contracts.end_date_active
AND cs_contracts.next_bill_date IS NULL;




BEGIN
FND_FILE.PUT_NAMES('exp_term.log','expterm.out','/sqlcom/log');
   user_id    := FND_GLOBAL.USER_ID;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'User_Id ='||
                              to_char(user_id));

OPEN C1;
While LOOPING LOOP
FETCH C1 INTO  lcontract_rec;


IF C1%NOTFOUND THEN
	LOOPING := FALSE;
ELSE
	select count(*) into v_counter
	from cs_cp_services_all, cs_cp_service_transactions
	where lcontract_rec.contract_id = cs_cp_services_all.contract_id
	and cs_cp_services_all.cp_service_id = cs_cp_service_transactions.cp_service_id;


	IF v_counter = 0 THEN
		v_status_id := FND_PROFILE.VALUE('CS_CONTRACTS_EXPIRED_STATUS');
		else
		v_status_id := FND_PROFILE.VALUE('CS_CONTRACTS_TERMINATED_STATUS');
	END IF;


     IF v_status_id IS NULL THEN
          v_retcode := ERROR;
          Current_error_Code := to_Char(SQLCODE);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Update unsuccessful : The v_return_status is NULL');
          FND_FILE.PUT_LINE( FND_FILE.LOG, 'CONTRACT_ID = ' || TO_CHAR(lcontract_rec.contract_id));
     ELSE

	msg1 := 'StatusID = ' || TO_CHAR(v_status_id);
	msg2 := 'Contract_ID = ' || TO_CHAR(lcontract_rec.contract_id);


Populate_Contracts(lcontract_rec,
                       contract_rec,
                       v_status_id
                       );


  CS_CONTRACT_PVT.Update_Row
  (
    p_api_version                  => 1.0,
    p_init_msg_list                => 'T',
    p_validation_level             => 0,
    p_commit                       => 'T',
    x_return_status                => v_return_status,
    x_msg_count                    => v_msg_count,
    x_msg_data                     => v_msg_data,
    p_contract_val_rec             => contract_rec,
    x_object_version_number        => v_object_version_number
  );


        --dbms_output.put_line(v_status_id);


		IF v_return_status <> 'S' AND v_msg_count >= 1 THEN
       	         	v_retcode := ERROR;
          		Current_error_Code := to_Char(SQLCODE);
          		FND_FILE.PUT_LINE(FND_FILE.LOG,'Update unsuccessful : The v_return_status is' || v_return_status);
          		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLCODE );
          		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
       	        ELSE
	                v_retcode := SUCCESS;
          		Current_error_Code := to_Char(SQLCODE);
          		FND_FILE.PUT_LINE( FND_FILE.LOG, 'Update successfully completed' );
          		FND_FILE.PUT_LINE( FND_FILE.LOG, 'CONTRACT_ID = ' || TO_CHAR(lcontract_rec.contract_id));
          		FND_FILE.PUT_LINE( FND_FILE.LOG, 'Status Changed to ' || v_status_id );
                END IF;

     END IF;
END IF;


END LOOP;

CLOSE C1;

    IF v_retcode = SUCCESS THEN
        COMMIT;
        CONC_STATUS :=
               FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
               Current_Error_Code);
     ELSE
        CONC_STATUS :=
               FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
     END IF;

     FND_FILE.CLOSE;



END exp_terminate_contract;

END cs_exp_terminate_pvt;

/
