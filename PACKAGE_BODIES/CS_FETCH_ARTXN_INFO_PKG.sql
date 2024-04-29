--------------------------------------------------------
--  DDL for Package Body CS_FETCH_ARTXN_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_FETCH_ARTXN_INFO_PKG" AS
/* $Header: csctfchb.pls 115.3 99/07/16 08:52:24 porting ship $ */
PROCEDURE fetch_trx_information (
						ERRBUF     OUT  VARCHAR2,
						RETCODE    OUT  NUMBER
					)  IS

CURSOR cur_contracts_billing IS
		SELECT *
		FROM CS_CONTRACTS_BILLING
		WHERE trx_number is NULL
		FOR UPDATE OF contract_billing_id ;

cur_record 			cur_contracts_billing%ROWTYPE;
conc_status 			BOOLEAN;
v_retcode 			NUMBER;
trx_class 			VARCHAR2(20);
tax_amount 			NUMBER;
trx_type_id 			NUMBER;
trx_number 			NUMBER;
trx_date 				DATE;
trx_amount 			NUMBER;
temp_cp_service_trx_id 	NUMBER;
v_return_status 		VARCHAR2(1);
v_msg_count 			NUMBER;
v_msg_data 			VARCHAR2(2000);

SUCCESS                  NUMBER := 0;
ERROR                    NUMBER := 1;
ret_status               NUMBER;
BEGIN

--  FND_GLOBAL.APPS_INITIALIZE(1001,170,20638);

--  FND_FILE.PUT_NAMES('bk.log','bk.out','/sqlcom/log');

	OPEN cur_contracts_billing;
	LOOP
	  FETCH cur_contracts_billing INTO cur_record;
	  EXIT WHEN cur_contracts_billing%NOTFOUND;

       BEGIN
		SELECT
	          lines.interface_line_attribute10,
	    		trx.cust_trx_type_id,
			trx.trx_number,
			lines.extended_amount,
			trtypes.type,
			trx.trx_date
    		INTO
	    		 temp_cp_service_trx_id,
			 trx_type_id,
		      trx_number,
			 trx_amount,
			 trx_class,
		      trx_date
		FROM  ra_customer_trx trx,
          	 ra_customer_trx_lines lines,
	     	 ra_cust_trx_types trtypes
     	WHERE lines.line_type='LINE'
		AND lines.interface_line_attribute1=to_char(cur_record.contract_id)
     	AND lines.interface_line_attribute2=to_char(cur_record.cp_service_id)
     	AND lines.interface_line_attribute4=to_char(cur_record.contract_billing_id)
     	AND trx.customer_trx_id=lines.customer_trx_id
     	AND trtypes.cust_trx_type_id=trx.cust_trx_type_id ;

 		EXCEPTION
		 WHEN NO_DATA_FOUND THEN
			ret_status  := ERROR;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'No line in ra_customer_trx_lines for Contract ID : ' ||
						to_char(cur_record.contract_id));
			FND_FILE.PUT_LINE(FND_FILE.LOG,'SErvice ID : ' ||
						to_char(cur_record.cp_service_id));
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Contract_Billing ID : ' ||
						to_char(cur_record.contract_billing_id));

        END;

        IF (ret_status = ERROR ) THEN
			ret_status  := SUCCESS;
	   ELSE
		BEGIN
			SELECT 	extended_amount
     		INTO      tax_amount
			FROM 	ra_customer_trx_lines
			WHERE 	line_type='TAX'
			AND interface_line_attribute1=to_char(cur_record.contract_id)
			AND interface_line_attribute2=to_char(cur_record.cp_service_id)
			AND interface_line_attribute4=to_char(cur_record.contract_billing_id);
 		EXCEPTION
		 WHEN NO_DATA_FOUND THEN
			tax_amount := 0;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'No tax amount for Contract ID : ' ||
						to_char(cur_record.contract_id));
			FND_FILE.PUT_LINE(FND_FILE.LOG,'SErvice ID : ' ||
						to_char(cur_record.cp_service_id));
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Contract_Billing ID : ' ||
						to_char(cur_record.contract_billing_id));

	     END;

  --call API  to write invoice details

	CS_CONBILLING_PVT.Update_Billing(
				p_api_version    	    => 1.0,
				p_init_msg_list         => 'T',
				p_commit			    => 'F',
				p_cp_service_trx_id     => temp_cp_service_trx_id,
			     p_contract_id 		    => cur_record.contract_id,
			     p_trx_type_id	         => trx_type_id,
				p_trx_number		    => trx_number,
				p_trx_date              => trx_date,
			     p_trx_pre_tax_amount    => trx_amount,
				p_tot_trx_amount        => trx_amount+tax_amount,
				p_contract_billing_id   => cur_record.contract_billing_id,
				p_obj_version_number    => cur_record.object_version_number,
				x_return_status         => v_return_status,
				x_msg_count             => v_msg_count,
				x_msg_data              => v_msg_data);


	IF (v_return_status  <>'S'and v_msg_count>=1) THEN
	     FND_FILE.PUT_LINE(FND_FILE.LOG,
				'Error in  updating contracts billing');
     	FND_FILE.PUT_LINE(FND_FILE.LOG,' MESSAGE : ' ||v_msg_data);
     ELSE
	     FND_FILE.PUT_LINE(FND_FILE.LOG,
				'Successfully updated contracts billing');
	     COMMIT;
	END IF ;

   END IF;


END LOOP;
CLOSE cur_contracts_billing;

   COMMIT;
   IF v_return_status = 'S' THEN
		conc_status:=
    			 FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',v_return_status);
   ELSE
	 	conc_status:=
			FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',v_return_status);
   END IF;

--FND_FILE.CLOSE;
EXCEPTION
	WHEN OTHERS THEN
    	     CLOSE cur_contracts_billing;
		v_msg_data := fnd_message.get;
          FND_FILE.PUT_LINE(FND_FILE.LOG,
				'Exception in fetch_trx_information :'||v_msg_data);
		--IF (v_return_status  <>'S'and v_msg_count>=1) THEN
          --	FND_FILE.PUT_LINE(FND_FILE.LOG,
		--			'Exception in fetch_trx_information :'||sqlerrm);
		--END IF ;

END fetch_trx_information;

END CS_FETCH_ARTXN_INFO_PKG;

/
