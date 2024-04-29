--------------------------------------------------------
--  DDL for Package Body CS_EST_APPLY_CONTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_EST_APPLY_CONTRACT_PKG" as
/* $Header: csxchcob.pls 120.2 2005/08/18 16:48:38 mviswana noship $ */
/*******************************************************************************
	--
	--Private global variables and functions
	--
*******************************************************************************/


PROCEDURE Apply_Contract (
  p_coverage_id	  IN  NUMBER,
  p_coverage_txn_group_id IN  NUMBER,
  p_txn_billing_type_id   IN  NUMBER,
  p_business_process_id   IN  NUMBER,
  p_request_date          IN  DATE,
  p_amount                IN  NUMBER,
  p_discount_amount       OUT NOCOPY     NUMBER,
  X_RETURN_STATUS         OUT NOCOPY     VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY     NUMBER,
  X_MSG_DATA              OUT NOCOPY     VARCHAR2) IS

  l_contracts_in_tbl    OKS_CON_COVERAGE_PUB.ser_tbl_type ;
  l_contracts_out_tbl   OKS_CON_COVERAGE_PUB.cov_tbl_type ;

  j 			NUMBER := 0;

  l_return_status      VARCHAR2(1);
  l_msg_data           VARCHAR2(2000) ;
  l_msg_count          NUMBER ;

  x_discount_price    NUMBER;
  e_contracts_warning  EXCEPTION;


BEGIN

     l_contracts_in_tbl(1).contract_line_id    := P_coverage_id;
     l_contracts_in_tbl(1).txn_group_id        := null;
     l_contracts_in_tbl(1).billing_type_id     := P_txn_billing_type_id;
     l_contracts_in_tbl(1).business_process_id := P_business_process_id;
     l_contracts_in_tbl(1).request_date        := P_request_date;
     l_contracts_in_tbl(1).charge_amount       := P_Amount;

    IF  l_contracts_in_tbl(1).contract_line_id IS NOT NULL
    and l_contracts_in_tbl(1).billing_type_id IS NOT NULL
    and l_contracts_in_tbl(1).business_process_id IS NOT NULL
    and l_contracts_in_tbl(1).request_date IS NOT NULL
    and l_contracts_in_tbl(1).charge_amount IS NOT NULL THEN

	OKS_CON_COVERAGE_PUB.APPLY_CONTRACT_COVERAGE (
                        P_API_VERSION             =>  1.0,
                        P_INIT_MSG_LIST           =>  'T',
                        P_EST_amt_TBL             =>  l_contracts_in_tbl,
                        X_RETURN_STATUS           =>  l_return_status,
                        X_MSG_COUNT               =>  l_msg_count,
                        X_MSG_DATA                =>  l_msg_data,
                        X_est_DISCounted_amt_TBL  =>  l_contracts_out_tbl);

        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN

	    FOR k in 1..l_contracts_out_tbl.count LOOP

		IF l_contracts_out_tbl(1).discounted_amount IS NULL THEN
		p_discount_amount := l_contracts_in_tbl(1).charge_amount;
		ELSE
                p_discount_amount := l_contracts_out_tbl(1).discounted_amount;

                x_return_status := l_return_status;
                END IF;
            END LOOP;


       ELSIF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_msg_data  := l_msg_data;
              x_msg_count := l_msg_count;
              x_return_status  := l_return_status;

      END IF;

END IF;

      EXCEPTION

        WHEN e_contracts_warning THEN
            -- x_result_flag := 'F' ;
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
            FND_MESSAGE.Set_Token('REASON', l_msg_data);
            app_exception.raise_exception ;

        WHEN OTHERS  THEN
            -- x_result_flag := 'F' ;
            FND_MESSAGE.Set_Name('CS', 'CS_CHG_APPLY_CONTRACT_WARNING');
            FND_MESSAGE.Set_Token('REASON', 'Apply Contracts Failed.');
            app_exception.raise_exception ;

END Apply_Contract ;
--
--
PROCEDURE Update_Estimate_Details (
		  p_Estimate_Detail_Id  IN  NUMBER,
		  p_discount_price      IN  NUMBER) IS
																	BEGIN
	  	 UPDATE CS_ESTIMATE_DETAILS
		 SET    after_warranty_cost  = p_discount_price
	      WHERE Estimate_Detail_Id = p_estimate_detail_id;

	 EXCEPTION
      WHEN NO_DATA_FOUND THEN
      Raise  No_Data_Found;

END  Update_Estimate_Details;
--
--
PROCEDURE GET_CONTRACT_LINES(
   P_API_VERSION		IN      NUMBER ,
   P_INIT_MSG_LIST		IN      VARCHAR2,
   P_CUSTOMER_ID		IN      NUMBER,
   P_CUSTOMER_ACCOUNT_ID	IN	   NUMBER,
   P_SERVICE_LINE_ID		IN	   NUMBER DEFAULT NULL,
   P_CUSTOMER_PRODUCT_ID	IN      NUMBER DEFAULT NULL,
   p_system_id			IN  number default null, -- Fix bug 3040124
   p_inventory_item_id		IN  number default null, -- Fix bug 3040124
   P_REQUEST_DATE		IN      DATE,
   P_BUSINESS_PROCESS_ID	IN      NUMBER DEFAULT NULL,
   P_CALC_RESPTIME_FLAG		IN      VARCHAR2 DEFAULT NULL,
   P_VALIDATE_FLAG		IN      VARCHAR2,
   X_ENT_CONTRACTS		OUT NOCOPY     ENT_CONTRACT_TAB,
   -- X_ENT_COVERAGE		OUT NOCOPY     CONTTAB,
   X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT			OUT NOCOPY     NUMBER,
   X_MSG_DATA			OUT NOCOPY     VARCHAR2) IS

   l_return_status      varchar2(1);
   l_api_name           varchar2(30) := 'GET_CONTRACT_LINES';
   l_inp_rec            OKS_ENTITLEMENTS_PUB.get_contin_rec;
   G_PKG_NAME           CONSTANT VARCHAR2(30) := 'CS_Est_Apply_Contract_PKG';

   L_CONTTAB CONTTAB;
   l_rec_count  number;
   i  number := 0;
   j  number := 0;

BEGIN

   SAVEPOINT Get_contract_lines;

   -- Since the Entitlements API expects input parameters as a record
   -- copy all the input parameter values into a record before passing
   -- it to the API

   l_inp_rec.party_id := p_customer_id;
   l_inp_rec.cust_acct_id := p_customer_account_id;
   l_inp_rec.service_line_id := p_service_line_id;
   l_inp_rec.system_id := p_system_id;  -- Fix bug 3040124
   l_inp_rec.item_id := p_inventory_item_id;  -- Fix bug 3040124
   l_inp_rec.product_id := p_customer_product_id;
   l_inp_rec.request_date := p_request_date;
   l_inp_rec.business_process_id := p_business_process_id;
   l_inp_rec.calc_resptime_flag := p_calc_resptime_flag;
   l_inp_rec.validate_flag := p_validate_flag;

   --If Validate_flag is 'Y' then only the valid contracts as of
   -- 'request_date' are returned. If the validate_flag is 'N' then
   -- all the contract lines - valid and invalid- are returned.
   -- Charges is passing validate flag as 'Y'.

   OKS_ENTITLEMENTS_PUB.GET_CONTRACTS(
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_inp_rec => l_inp_rec,
      x_return_status => l_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_ent_contracts => x_ent_contracts);

   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;
   x_return_status := l_return_status;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO  Get_contract_lines;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                    p_data => x_msg_data ,
                                    p_encoded => fnd_api.g_false );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO  Get_contract_lines;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.COUNT_AND_GET (p_count =>x_msg_count ,
                                    p_data => x_msg_data ,
                                    p_encoded => fnd_api.g_false );

      WHEN OTHERS THEN
         ROLLBACK TO  Get_contract_lines;
         x_return_status := FND_API.G_RET_STS_unexp_error ;
         IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
         END IF;
         fnd_msg_pub.count_and_get ( p_count =>x_msg_count ,p_data => x_msg_data ,p_encoded => fnd_api.g_false );

END Get_Contract_Lines;

END  CS_Est_Apply_Contract_PKG;

/
