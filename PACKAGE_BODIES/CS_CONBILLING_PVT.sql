--------------------------------------------------------
--  DDL for Package Body CS_CONBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONBILLING_PVT" AS
/* $Header: csctarfb.pls 115.4 99/07/16 08:48:17 porting ship  $ */

  -- Start of comments
  -- API name            : Update Billing API
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This API to write invoice details to
  -- 			       cs_contracts_billing
  -- Parameters          :
  -- IN                  :
  --                       p_api_version             NUMBER     Required
  --                       p_contract_id             NUMBER
  --			   		  p_cp_service_trx_id 	     NUMBER
  --			   		  p_contract_id             NUMBER
  --					  p_trx_type_id 		   NUMBER
  --					  p_trx_number 		   NUMBER
  --					  p_trx_date 			   DATE
  --					  p_trx_amount 		   NUMBER
  --					  p_contract_billing_id 	   NUMBER
  --					  p_obj_version_number      NUMBER
  --                       p_cp_service_id           NUMBER
  --                       p_init_msg_list           VARCHAR2
  --                       p_commit                  VARCHAR2
  -- OUT                 :
  --                       x_return_status           VARCHAR2
  --                       x_msg_count               NUMBER
  --                       x_msg_data                VARCHAR2
  --End of comments
/*************************************************************************/


 PROCEDURE update_billing(
			p_api_version  		IN NUMBER,
			p_init_msg_list 		IN VARCHAR2 := FND_API.G_FALSE,
			p_commit 				IN VARCHAR2 := FND_API.G_FALSE,
			p_cp_service_trx_id 	IN NUMBER,
			p_contract_id 			IN NUMBER,
			p_trx_type_id 			IN NUMBER,
			p_trx_number 			IN NUMBER,
			p_trx_date 			IN DATE,
			p_tot_trx_amount 		IN NUMBER,
		     p_trx_pre_tax_amount 	IN NUMBER,
			p_contract_billing_id 	IN NUMBER,
			p_obj_version_number  	IN NUMBER,
			x_return_status 		OUT VARCHAR2,
			x_msg_count 			OUT NUMBER,
			x_msg_data 			OUT NUMBER) IS

l_api_name 	 CONSTANT VARCHAR2(30):='Update_Billing_Api';
l_api_version   CONSTANT NUMBER 	  := 1;
l_return_status VARCHAR2(1) 		  := FND_API.G_RET_STS_SUCCESS;
l_msg_data 	 VARCHAR2(2000);

transaction_class   VARCHAR2(4);
v_return_status	VARCHAR2(1);
v_msg_count		NUMBER;
v_msg_data		VARCHAR2(2000);
p_obj_ver_num 	  	NUMBER;


BEGIN

	l_return_status:=TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
									G_PKG_NAME,
									l_api_version,
									p_api_version,
									p_init_msg_list,
									'_pvt',
									x_return_status);


     IF  (l_return_status=FND_API.G_RET_STS_UNEXP_ERROR) then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	SELECT type INTO transaction_class
	FROM ra_cust_trx_types
	WHERE cust_trx_type_id=p_trx_type_id;

	IF SQL%NOTFOUND THEN
	fnd_message.set_name('CS','CS_CONTRACTS_CLASS_NOT_FOUND');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF;

	/* update inv details in cs_contract_billing*/

	IF (transaction_class = 'INV') THEN

/*		UPDATE cs_contracts_billing
		SET trx_number=p_trx_number,
		    trx_date=p_trx_date,
		    trx_amount=p_tot_trx_amount,
		    trx_pre_tax_amount=p_trx_pre_tax_amount,
		    trx_class='INV'
		WHERE contract_billing_id=p_contract_billing_id;

*/

		 CS_CONTRACTBILLING_PVT.Update_Row(
				p_api_version			=>  1.0,
				p_init_msg_list		=>  'T',
				p_validation_level		=>  100,
				p_commit				=>  'F',
				x_return_status		=>	v_return_status,
				x_msg_count			=>	v_msg_count,
			     x_msg_data			=>	v_msg_data,
				p_contract_billing_id	=>	p_contract_billing_id,
		     	p_object_version_number	=>   p_obj_version_number,
				p_trx_date			=>	p_trx_date,
				p_trx_number			=>	p_trx_number,
				p_trx_amount			=>	p_tot_trx_amount,
			     p_trx_pre_tax_amount	=>   p_trx_pre_tax_amount,
				p_trx_class			=>	'INV',
				x_object_version_number  =>   p_obj_ver_num
				);


	ELSE
/*
		UPDATE cs_contracts_billing
		SET trx_number=p_trx_number,
		    trx_date=p_trx_date,
		    trx_amount=p_tot_trx_amount,
		    trx_pre_tax_amount=p_trx_pre_tax_amount,
		    trx_class='CM'
		WHERE contract_billing_id=p_contract_billing_id;
*/

     	CS_CONTRACTBILLING_PVT.Update_Row(
				p_api_version			=>  1.0,
				p_init_msg_list		=>  'T',
				p_validation_level		=>  100,
				p_commit				=>  'F',
				x_return_status		=>	v_return_status,
				x_msg_count			=>	v_msg_count,
			     x_msg_data			=>	v_msg_data,
				p_contract_billing_id	=>	p_contract_billing_id,
				p_trx_date			=>	p_trx_date,
				p_object_version_number	=>   p_obj_version_number,
				p_trx_number			=>	p_trx_number,
				p_trx_amount			=>	p_tot_trx_amount,
			     p_trx_pre_tax_amount	=>   p_trx_pre_tax_amount,
				p_trx_class			=>	'CM',
				x_object_version_number	=> p_obj_ver_num
				);

	END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      fnd_message.set_name('CS','CS_CONTRACTS_ERR_UPD_BILL');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
      fnd_message.set_name('CS','CS_CONTRACTS_ERR_UPD_BILL');
        	   RAISE FND_API.G_EXC_ERROR;
      END IF;

	 IF (v_return_status <>'S' and v_msg_count >=1) then
   		     fnd_file.put_line(fnd_file.log , 'message '|| v_msg_data);
 	 END IF;


	TAPI_DEV_KIT.END_ACTIVITY(p_commit,
						 x_msg_count,
						 x_msg_data);

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

--COMMIT;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
				(	l_api_name,
					G_PKG_NAME,
					'FND_API.G_RET_STS_ERROR',
					x_msg_count,
					x_msg_data,
					'_pvt');

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
				(	l_api_name,
					G_PKG_NAME,
					'FND_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_pvt');

	WHEN OTHERS THEN
		x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
				(	l_api_name,
					G_PKG_NAME,
			    		'OTHERS',
					x_msg_count,
					x_msg_data,
					'_pvt');


END update_billing;

END CS_CONBILLING_PVT;

/
