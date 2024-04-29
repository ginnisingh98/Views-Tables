--------------------------------------------------------
--  DDL for Package Body CS_GET_CONTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_GET_CONTRACTS_PUB" AS
/* $Header: csctglcb.pls 115.12 99/07/16 08:52:46 porting ship $ */

  -- Start of comments
  -- API name            : Get_List_of_Contracts
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This procedure gets a list of contracts for the
  --                       specified customer/customer product/site/system
  --
  -- Parameters          :
  -- IN                  :
  --                         p_api_version             NUMBER    Required
  --                         p_init_msg_list           VARCHAR2  Required
  --                         p_commit                  VARCHAR2  Required
  --                         p_Customer_Product_id     NUMBER
  --                         p_Business_Process_Id     NUMBER    Required
  --                         p_Charge_Date_Time        DATE      Required
  --                         p_Time_Zone_Id            NUMBER    Required
  --                         p_Exception_coverage_flag VARCHAR2  Required
  -- OUT                 :
  --
  --          VARCHAR2
  --                         x_Overlap_flag            VARCHAR2
  --                         x_return_status           VARCHAR2
  --                         x_msg_count               NUMBER
  --                         x_msg_data                VARCHAR2
  --End of comments

  PROCEDURE Get_List_Of_Contracts (
               p_api_version             	IN	NUMBER,
               p_init_msg_list           	IN	VARCHAR2  ,
               p_commit                  	IN	VARCHAR2  ,
			p_Customer_Product_Id		IN	OUT 	NUMBER,
			p_Business_Process_Id		IN 	NUMBER,
			p_charge_date_time			IN	DATE,
			p_time_zone_id				IN	NUMBER,
			p_exception_coverage_flag	IN	VARCHAR2,
			x_contract_rec_type			OUT	CONTRACTS_REC_TYPE,
			x_Contract_Id				OUT	NUMBER,
			x_Contract_Number			OUT	NUMBER,
			x_Contract_Status			OUT	VARCHAR2,
			x_Contract_Type			OUT	VARCHAR2,
			x_Contract_Group			OUT	VARCHAR2,
			x_Contract_Duration			OUT	NUMBER,
			x_Contract_Period			OUT	VARCHAR2,
			x_Contract_Start_Date		OUT	DATE,
			x_Contract_End_Date			OUT	DATE,
			x_Contract_Agreement		OUT	VARCHAR2,
			x_Contract_Price_List		OUT	VARCHAR2,
			x_Currency_Code			OUT	VARCHAR2,
			x_Invoicing_Rule			OUT	VARCHAR2,
			x_Accounting_Rule			OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On					OUT	NUMBER,
			x_First_Bill_Date			OUT	DATE,
			x_Next_Bill_Date			OUT	DATE,
			x_Workflow_Process_Id		OUT	NUMBER,
			x_Renewal_Rule				OUT	VARCHAR2,
			x_Termination_Rule			OUT	VARCHAR2,
			x_Contract_Amount			OUT	NUMBER,
			x_discount				OUT	VARCHAR2,
			x_Service_Id				OUT	NUMBER,
			x_Service					OUT	VARCHAR2,
			x_Service_Start_Date		OUT	DATE,
			x_Service_End_Date			OUT	DATE,
			x_Coverage_Id				OUT	NUMBER,
			x_coverage				OUT	VARCHAR2,
			p_rec_count				IN OUT	NUMBER,
               x_return_status          	OUT 	VARCHAR2,
               x_msg_count              	OUT 	NUMBER,
               x_msg_data               	OUT 	VARCHAR2  )IS

	/** Cursor for getting list of contracts when customer
	product is specified **/
	CURSOR Get_Contracts IS
	SELECT  	CONT.Contract_Id,
			CONT.Contract_Number,
			STAT.Name				Status,
			CONT.Start_Date_Active	START_DATE_ACTIVE,
			CONT.End_Date_Active	END_DATE_ACTIVE,
			CONT.Duration			DURATION,
			CONT.Currency_Code		CURRENCY_CODE,
			CONT.Bill_On			BILL_ON,
			CONT.First_Bill_Date	FIRST_BILL_DATE,
			CONT.Next_Bill_Date		NEXT_BILL_DATE,
			CONT.Workflow_Process_Id	WORKFLOW_PROCESS_ID,
			CONT.Renewal_Rule		RENEWAL_RULE,
			CONT.Termination_Rule	TERMINATION_RULE,
			CONT.Contract_Amount	CONTRACT_AMOUNT,
			SERV.Service_Inventory_Item_Id	SERVICE_INVENTORY_ITEM_ID,
			MTL.Concatenated_Segments		SERVICE,
			SERV.Start_Date_Active	SERVICE_START_DATE,
			SERV.End_Date_Active	SERVICE_END_DATE,
			COV2.Coverage_Id		COVERAGE_ID,
			COV2.Name		COVERAGE
	FROM     	CS_Contracts			CONT,
			Cs_Coverages			COV,
			Cs_Coverages			COV2,
			Cs_Coverage_Txn_Groups	CTG,
			CS_Contract_Statuses	STAT,
			Cs_Covered_Products		COVPROD,
			Cs_Contract_Cov_Levels	CL,
			Mtl_System_Items_Kfv	MTL,
			CS_Contract_Statuses	STAT2,
			Cs_Cp_Services			SERV
WHERE	COVPROD.Customer_Product_Id		= P_Customer_Product_Id
    		AND  COVPROD.Coverage_Level_Id	= CL.Coverage_Level_Id
    		AND  CL.Cp_Service_Id			= SERV.Cp_Service_Id
		AND  SERV.Contract_Id			= CONT.Contract_Id
		AND	SERV.Coverage_Schedule_Id 	= COV.Coverage_Id
		AND  CTG.Business_Process_Id = P_Business_Process_Id
		AND (( COV.Coverage_Id		= COV2.Coverage_Id
			 AND  COV.Coverage_Id		= CTG.Coverage_Id
		    	 AND	P_Exception_Coverage_Flag 	= 'N')
		     OR ( COV.Exception_Coverage_Id = COV2.Coverage_Id
			 AND COV.Exception_Coverage_Id = CTG.Coverage_Id
			 AND	P_Exception_Coverage_Flag = 'Y'))
	AND  SERV.Contract_Line_Status_Id		= STAT2.Contract_Status_Id
	AND  STAT2.Eligible_For_Entitlements	= 'Y'
	AND	trunc(to_date(P_Charge_Date_Time))
     		BETWEEN SERV.Start_Date_Active AND
				   SERV.End_Date_Active
    	AND 	SERV.Service_Inventory_Item_Id	= MTL.Inventory_Item_Id
    	AND 	MTL.Organization_Id				=
						FND_Profile.Value_Specific('SO_ORGANIZATION_ID')
    	AND	CONT.Contract_Status_Id			= STAT.Contract_Status_Id
	AND  STAT.Eligible_for_Entitlements	= 'Y';


	l_covered_Yes_No	VARCHAR2(1);
	l_coverage_id		NUMBER;
	l_api_name		VARCHAR2(30)	:= G_PKG_NAME;
	l_api_version		NUMBER		:= G_API_VERSION;
	l_contract_rec_type	CONTRACTS_REC_TYPE;

	BEGIN

	OPEN Get_Contracts;

	LOOP

	--DBMS_Output.Put_Line('Parameters: Business Process='||
	--					to_char(p_business_process_id));
	--DBMS_Output.Put_Line('Charge Date='|| to_char(p_charge_date_time));
	--DBMS_Output.Put_Line('CP Id='|| to_char(p_customer_product_Id));
	--DBMS_Output.Put_Line('Exception='|| p_exception_coverage_flag);

		FETCH Get_Contracts
		INTO	x_Contract_Rec_Type;

	--DBMS_Output.Put_Line('Fetched Record');

		EXIT WHEN Get_Contracts%NOTFOUND;

		l_coverage_id	:= x_contract_rec_type.V_Coverage_Id;

--DBMS_Output.Put_Line('Coverage id='|| to_char(l_coverage_id));
--DBMS_Output.PUt_Line('Time zone id='|| to_char(p_time_zone_id));

		CS_Coverage_Service_PUB.Validate_Coverage_Times(
				p_api_version,
				p_init_msg_list,
				p_commit,
				l_Coverage_Id,
				P_Business_Process_Id,
				P_Charge_Date_Time,
				P_Time_Zone_Id,
				P_Exception_Coverage_Flag,
				l_Covered_Yes_No,
				x_return_status,
				x_msg_count,
				x_msg_data);

--	DBMS_Output.Put_Line('Validate Coverage covered='|| l_covered_yes_no);

		l_covered_yes_no := 'Y';

		IF (l_covered_yes_no = 'Y') THEN
			migrate_to_table(
              			p_api_version,
              			p_init_msg_list,
              			p_commit,
					x_contract_rec_type,
					p_rec_count,
              			x_return_status,
              			x_msg_count,
              			x_msg_data );

			IF (p_rec_count = 1) THEN
				Migrate_to_Out_Variables(
               		p_api_version            	,
               		p_init_msg_list          	,
               		p_commit                 	,
					x_contract_rec_type			,
					x_Contract_Id				,
					x_Contract_Number			,
					x_Contract_Status			,
					x_Contract_Type			,
					x_Contract_Group			,
					x_Contract_Duration			,
					x_Contract_Period			,
					x_Contract_Start_Date		,
					x_Contract_End_Date			,
					x_Contract_Agreement		,
					x_Contract_Price_List		,
					x_Currency_Code			,
					x_Invoicing_Rule					,
					x_Accounting_Rule			,
					x_Billing_Frequency_Period	,
					x_Bill_On					,
					x_First_Bill_Date			,
					x_Next_Bill_Date			,
					x_Workflow_Process_Id				,
					x_Renewal_Rule				,
					x_Termination_Rule			,
					x_Contract_Amount			,
					x_discount				,
					x_Service_Id				,
					x_Service					,
					x_Service_Start_Date		,
					x_Service_End_Date			,
					x_Coverage_Id				,
					x_coverage				,
               		x_return_status          	,
               		x_msg_count              	,
               		x_msg_data               	);
				END IF;

				p_rec_count := p_rec_count + 1;
		END IF;
	END LOOP;

	CLOSE Get_Contracts;

	p_rec_count := p_rec_count -1;

	TAPI_DEV_KIT.END_ACTIVITY(	p_commit,
							x_msg_count,
							x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END 	Get_List_Of_Contracts;


PROCEDURE Get_List_Of_Contracts (
               p_api_version             IN  NUMBER,
               p_init_msg_list           IN  VARCHAR2  ,
               p_commit                  IN  VARCHAR2  ,
			p_Coverage_Level_Value	IN NUMBER,
			p_coverage_level_code	IN	VARCHAR2,
			p_Business_Process_Id	IN 	NUMBER,
			p_charge_date_time			IN	DATE,
			p_time_zone_id			IN	NUMBER,
			p_exception_coverage_flag IN	VARCHAR2,
			x_contract_rec_type		OUT	CONTRACTS_REC_TYPE,
			x_Contract_Id			OUT	NUMBER,
			x_Contract_Number		OUT	NUMBER,
			x_Contract_Status		OUT	VARCHAR2,
			x_Contract_Type		OUT	VARCHAR2,
			x_Contract_Group		OUT	VARCHAR2,
			x_Contract_Duration		OUT	NUMBER,
			x_Contract_Period		OUT	VARCHAR2,
			x_Contract_Start_Date	OUT	DATE,
			x_Contract_End_Date		OUT	DATE,
			x_Contract_Agreement	OUT	VARCHAR2,
			x_Contract_Price_List	OUT	VARCHAR2,
			x_Currency_Code		OUT	VARCHAR2,
			x_Invoicing_Rule		OUT	VARCHAR2,
			x_Accounting_Rule		OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On				OUT	NUMBER,
			x_First_Bill_Date		OUT	DATE,
			x_Next_Bill_Date		OUT	DATE,
			x_Workflow_Process_Id	OUT	NUMBER,
			x_Renewal_Rule			OUT	VARCHAR2,
			x_Termination_Rule		OUT	VARCHAR2,
			x_Contract_Amount		OUT	NUMBER,
			x_discount			OUT	VARCHAR2,
			x_Service_Id			OUT	NUMBER,
			x_Service				OUT	VARCHAR2,
			x_Service_Start_Date	OUT	DATE,
			x_Service_End_Date		OUT	DATE,
			x_Coverage_Id			OUT	NUMBER,
			x_coverage			OUT	VARCHAR2,
			p_rec_count			IN OUT	NUMBER,
               x_return_status          OUT 	VARCHAR2,
               x_msg_count              OUT 	NUMBER,
               x_msg_data               OUT 	VARCHAR2  )IS

	/** Cursor for getting list of contracts when customer
	product is specified **/
	CURSOR Get_Contracts IS
	SELECT  	CONT.Contract_Id,
			CONT.Contract_Number,
			STAT.Name						Status,
			CONT.Start_Date_Active			START_DATE_ACTIVE,
			CONT.End_Date_Active			END_DATE_ACTIVE,
			CONT.Duration					DURATION,
			CONT.Currency_Code				CURRENCY_CODE,
			CONT.Bill_On					BILL_ON,
			CONT.First_Bill_Date			FIRST_BILL_DATE,
			CONT.Next_Bill_Date				NEXT_BILL_DATE,
			CONT.Workflow_Process_Id			WORKFLOW_PROCESS_ID,
			CONT.Renewal_Rule				RENEWAL_RULE,
			CONT.Termination_Rule			TERMINATION_RULE,
			CONT.Contract_Amount			CONTRACT_AMOUNT,
			SERV.Service_Inventory_Item_Id	SERVICE_INVENTORY_ITEM_ID,
			MTL.Concatenated_Segments		SERVICE,
			SERV.Start_Date_Active			SERVICE_START_DATE,
			SERV.End_Date_Active			SERVICE_END_DATE,
			COV2.Coverage_Id		COVERAGE_ID,
			COV2.Name		COVERAGE
	FROM     	CS_Contracts			CONT,
			Cs_Coverages			COV,
			Cs_Coverages			COV2,
			Cs_Coverage_Txn_Groups	CTG,
			CS_Contract_Statuses	STAT,
			Cs_Contract_Cov_Levels	CL,
			Mtl_System_Items_Kfv	MTL,
			CS_Contract_Statuses	STAT2,
			Cs_Cp_Services			SERV
	WHERE	CL.Coverage_Level_Value		= P_Coverage_level_value
    	  AND  	CL.Cp_Service_Id			= SERV.Cp_Service_Id
	  AND  	SERV.Contract_Id			= CONT.Contract_Id
	  AND	SERV.Coverage_Schedule_Id 	= COV.Coverage_Id
   	  AND	 CTG.Business_Process_Id	= P_Business_Process_ID
		    AND (( COV.Coverage_Id		= COV2.Coverage_Id
    	  		  AND     COV.Coverage_Id		= CTG.Coverage_Id
			  AND	P_Exception_Coverage_Flag 	= 'N')
		     OR ( COV.Exception_Coverage_Id = COV2.Coverage_Id
			 AND  P_Exception_Coverage_Flag = 'Y'
			 AND COV.Exception_Coverage_Id = CTG.Coverage_Id))
	  AND  	SERV.Contract_Line_Status_Id		= STAT2.Contract_Status_Id
	  AND  	STAT2.Eligible_For_Entitlements	= 'Y'
	AND	trunc(p_charge_date_time)
     		BETWEEN SERV.Start_Date_Active AND
				   SERV.End_Date_Active
    	  AND 	SERV.Service_Inventory_Item_Id = MTL.Inventory_Item_Id
    	  AND 	MTL.Organization_Id			=
						FND_Profile.Value_Specific('SO_ORGANIZATION_ID')
    	  AND	CONT.COntract_Status_Id		 =	STAT.Contract_Status_Id
	  AND  	STAT.Eligible_for_Entitlements =    'Y';

	l_covered_Yes_No	VARCHAR2(1);
	l_coverage_id		NUMBER;
	l_api_name		VARCHAR2(30)	:= G_PKG_NAME;
	l_api_version		NUMBER		:= G_API_VERSION;

BEGIN

	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

	OPEN Get_Contracts;

	LOOP

		FETCH Get_Contracts
		INTO	x_contract_rec_type;

--DBMS_OUtput.Put_Line('After fetch');

		EXIT WHEN Get_Contracts%NOTFOUND;

--DBMS_OUtput.Put_Line('not exited');

		l_coverage_id := x_Contract_Rec_Type.V_coverage_id;

		CS_Coverage_Service_PUB.Validate_Coverage_Times(
				p_api_version,
				p_init_msg_list,
				p_commit,
				l_Coverage_Id,
				P_Business_Process_Id,
				P_Charge_Date_Time,
				P_Time_Zone_Id,
				P_Exception_Coverage_Flag,
				l_Covered_Yes_No,
				x_return_status,
				x_msg_count,
				x_msg_data);

--	DBMS_OUtput.Put_LIne('Covered='|| l_covered_yes_no);

--		l_covered_yes_no := 'Y';
		IF (l_Covered_Yes_No = 'Y') THEN

			migrate_to_table(
              			p_api_version,
              			p_init_msg_list,
              			p_commit,
					x_contract_rec_type,
					p_rec_count,
              			x_return_status,
              			x_msg_count,
              			x_msg_data );

			IF (p_rec_count = 1) THEN
				Migrate_to_Out_Variables(
               			p_api_version           	,
               			p_init_msg_list         	,
               			p_commit                	,
						x_contract_rec_Type		,
						x_Contract_Id			,
						x_Contract_Number		,
						x_Contract_Status		,
						x_Contract_Type		,
						x_Contract_Group		,
						x_Contract_Duration		,
						x_Contract_Period		,
						x_Contract_Start_Date	,
						x_Contract_End_Date		,
						x_Contract_Agreement	,
						x_Contract_Price_List	,
						x_Currency_Code		,
						x_Invoicing_Rule		,
						x_Accounting_Rule		,
						x_Billing_Frequency_Period	,
						x_Bill_On				,
						x_First_Bill_Date		,
						x_Next_Bill_Date		,
						x_Workflow_Process_Id	,
						x_Renewal_Rule			,
						x_Termination_Rule		,
						x_Contract_Amount		,
						x_discount			,
						x_Service_Id			,
						x_Service				,
						x_Service_Start_Date	,
						x_Service_End_Date		,
						x_Coverage_Id			,
						x_coverage			,
               			x_return_status         	,
               			x_msg_count             	,
               			x_msg_data              	);
			END IF;

			p_rec_count := p_rec_count + 1;
		END IF;

	END LOOP;

	CLOSE Get_Contracts;

	p_rec_count := p_rec_count -1;

	--DBMS_Output.Put_Line('Rec Count='|| to_char(p_rec_count));

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END 	Get_List_Of_Contracts;

PROCEDURE Get_List_Of_Contracts (
               p_api_version             IN  NUMBER,
               p_init_msg_list           IN  VARCHAR2  ,
               p_commit                  IN  VARCHAR2  ,
			p_System_Id			IN 	NUMBER,
			p_site_use_Id			IN	NUMBER,
			p_Business_Process_Id	IN 	NUMBER,
			p_charge_date_time			IN	DATE,
			p_time_zone_id			IN	NUMBER,
			p_exception_coverage_flag IN	VARCHAR2,
			x_contract_rec_type		OUT	CONTRACTS_REC_TYPE,
			x_Contract_Id			OUT	NUMBER,
			x_Contract_Number		OUT	NUMBER,
			x_Contract_Status		OUT	VARCHAR2,
			x_Contract_Type		OUT	VARCHAR2,
			x_Contract_Group		OUT	VARCHAR2,
			x_Contract_Duration		OUT	NUMBER,
			x_Contract_Period		OUT	VARCHAR2,
			x_Contract_Start_Date	OUT	DATE,
			x_Contract_End_Date		OUT	DATE,
			x_Contract_Agreement	OUT	VARCHAR2,
			x_Contract_Price_List	OUT	VARCHAR2,
			x_Currency_Code		OUT	VARCHAR2,
			x_Invoicing_Rule		OUT	VARCHAR2,
			x_Accounting_Rule		OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On				OUT	NUMBER,
			x_First_Bill_Date		OUT	DATE,
			x_Next_Bill_Date		OUT	DATE,
			x_Workflow_Process_Id	OUT	NUMBER,
			x_Renewal_Rule			OUT	VARCHAR2,
			x_Termination_Rule		OUT	VARCHAR2,
			x_Contract_Amount		OUT	NUMBER,
			x_discount			OUT	VARCHAR2,
			x_Service_Id			OUT	NUMBER,
			x_Service				OUT	VARCHAR2,
			x_Service_Start_Date	OUT	DATE,
			x_Service_End_Date		OUT	DATE,
			x_Coverage_Id			OUT	NUMBER,
			x_coverage			OUT	VARCHAR2,
			p_rec_count			IN OUT	NUMBER,
               x_return_status          OUT 	VARCHAR2,
               x_msg_count              OUT 	NUMBER,
               x_msg_data               OUT 	VARCHAR2  )IS

	/** Cursor for getting list of contracts when customer
	product is specified **/
	CURSOR Get_Contracts IS
	SELECT  	CONT.Contract_Id,
			CONT.Contract_Number,
			STAT.Name						Status,
			CONT.Start_Date_Active			START_DATE_ACTIVE,
			CONT.End_Date_Active			END_DATE_ACTIVE,
			CONT.Duration					DURATION,
			CONT.Currency_Code				CURRENCY_CODE,
			CONT.Bill_On					BILL_ON,
			CONT.First_Bill_Date			FIRST_BILL_DATE,
			CONT.Next_Bill_Date				NEXT_BILL_DATE,
			CONT.Workflow_Process_Id			WORKFLOW_PROCESS_ID,
			CONT.Renewal_Rule				RENEWAL_RULE,
			CONT.Termination_Rule			TERMINATION_RULE,
			CONT.Contract_Amount			CONTRACT_AMOUNT,
			SERV.Service_Inventory_Item_Id	SERVICE_INVENTORY_ITEM_ID,
			MTL.Concatenated_Segments		SERVICE,
			SERV.Start_Date_Active			SERVICE_START_DATE,
			SERV.End_Date_Active			SERVICE_END_DATE,
			COV2.Coverage_Id		COVERAGE_ID,
			COV2.Name		COVERAGE
	FROM     	CS_Contracts			CONT,
			CS_Contract_Statuses	STAT,
			Cs_Coverages			COV,
			Cs_Coverages			COV2,
			Cs_Coverage_Txn_Groups	CTG,
			Cs_Contract_Cov_Levels	CL,
			Mtl_System_Items_Kfv	MTL,
			CS_Contract_Statuses	STAT2,
			Cs_Cp_Services			SERV
WHERE	CL.Coverage_Level_Value	IN (P_System_Id, P_Site_Use_Id)
    		AND  CL.Cp_Service_Id			= SERV.Cp_Service_Id
		AND  SERV.Contract_Id			= CONT.Contract_Id
		AND	SERV.Coverage_Schedule_Id 	= COV.Coverage_Id
	     AND	CTG.Business_Process_Id	= P_Business_Process_Id
		AND     (( COV.Coverage_Id		= COV2.Coverage_Id
			 AND  COV.Coverage_Id		= CTG.Coverage_Id
			 AND	 P_Exception_Coverage_Flag 	= 'N')
		     OR ( COV.Exception_Coverage_Id = COV2.Coverage_Id
			 AND COV.Exception_Coverage_Id = CTG.Coverage_Id
			 AND  P_Exception_Coverage_Flag = 'Y'))
	AND  SERV.Contract_Line_Status_Id		= STAT2.Contract_Status_Id
	AND  STAT2.Eligible_For_Entitlements	= 'Y'
	AND	trunc(p_charge_date_time)
     		BETWEEN SERV.Start_Date_Active AND
				   SERV.End_Date_Active
    	AND 	SERV.Service_Inventory_Item_Id	= MTL.Inventory_Item_Id
    	AND 	MTL.Organization_Id				=
						FND_Profile.Value_Specific('SO_ORGANIZATION_ID')
    	AND	CONT.Contract_Status_Id			=	STAT.Contract_Status_Id
	AND  STAT.Eligible_for_Entitlements	=    'Y';

		l_covered_Yes_No	VARCHAR2(1);
		l_coverage_id		NUMBER;
		l_api_name		VARCHAR2(30) := G_PKG_NAME;
		l_api_version		NUMBER	:= G_API_VERSION;

	BEGIN

	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

--DBMS_Output.Put_Line('Procedure 4');

	OPEN Get_Contracts;

	LOOP

		FETCH Get_Contracts
		INTO	x_contract_rec_type;

		EXIT WHEN Get_Contracts%NOTFOUND;


		l_coverage_id := x_Contract_Rec_Type.V_coverage_id;
--DBMS_Output.Put_Line('Procedure 4 fetched record');

		CS_Coverage_Service_PUB.Validate_Coverage_Times(
					p_api_version,
					p_init_msg_list,
					p_commit,
					l_Coverage_Id,
					P_Business_Process_Id,
					P_Charge_Date_Time,
					P_Time_Zone_Id,
					P_Exception_Coverage_Flag,
					l_Covered_Yes_No,
					x_return_status,
					x_msg_count,
					x_msg_data);

--DBMS_Output.Put_Line('Covered=' || l_covered_yes_no);

--		l_covered_yes_no := 'Y';
		IF (l_Covered_Yes_No = 'Y') THEN
			migrate_to_table(
    	          			p_api_version,
    	          			p_init_msg_list,
    	          			p_commit,
						x_contract_rec_type,
						p_rec_count,
    	          			x_return_status,
    	          			x_msg_count,
    	          			x_msg_data );

			Migrate_to_Out_Variables(
						p_api_version            	,
						p_init_msg_list          	,
						p_commit                 	,
						x_contract_rec_Type			,
						x_Contract_Id				,
						x_Contract_Number			,
						x_Contract_Status			,
						x_Contract_Type			,
						x_Contract_Group			,
						x_Contract_Duration			,
						x_Contract_Period			,
						x_Contract_Start_Date		,
						x_Contract_End_Date			,
						x_Contract_Agreement		,
						x_Contract_Price_List		,
						x_Currency_Code			,
						x_Invoicing_Rule			,
						x_Accounting_Rule			,
						x_Billing_Frequency_Period	,
						x_Bill_On					,
						x_First_Bill_Date			,
						x_Next_Bill_Date			,
						x_Workflow_Process_Id		,
						x_Renewal_Rule				,
						x_Termination_Rule			,
						x_Contract_Amount			,
						x_discount				,
						x_Service_Id				,
						x_Service					,
						x_Service_Start_Date		,
						x_Service_End_Date			,
						x_Coverage_Id				,
						x_coverage				,
               			x_return_status          	,
               			x_msg_count              	,
               			x_msg_data               	);

				p_rec_count := p_rec_count + 1;

			END IF;
	END LOOP;

	CLOSE Get_Contracts;

	p_rec_count := p_rec_count -1;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END 	Get_List_Of_Contracts;

PROCEDURE Get_List_Of_Contracts (
               p_api_version            	IN	NUMBER,
               p_init_msg_list          	IN	VARCHAR2  ,
               p_commit                 	IN	VARCHAR2  ,
			p_Customer_Product_Id		IN	OUT NUMBER,
			p_Customer_Id				IN	OUT NUMBER,
			p_site_use_Id				IN	OUT NUMBER,
			p_system_Id				IN	OUT NUMBER,
			p_inventory_Item_Id			IN	OUT NUMBER,
			p_Business_Process_Id		IN 	NUMBER,
			p_charge_date_time			IN	DATE,
			p_time_zone_id				IN	NUMBER,
			p_exception_coverage_flag	IN	VARCHAR2,
			x_Contract_Id				OUT	NUMBER,
			x_Contract_Number			OUT	NUMBER,
			x_Contract_Status			OUT	VARCHAR2,
			x_Contract_Type			OUT	VARCHAR2,
			x_Contract_Group			OUT	VARCHAR2,
			x_Contract_Duration			OUT	NUMBER,
			x_Contract_Period			OUT	VARCHAR2,
			x_Contract_Start_Date		OUT	DATE,
			x_Contract_End_Date			OUT	DATE,
			x_Contract_Agreement		OUT	VARCHAR2,
			x_Contract_Price_List		OUT	VARCHAR2,
			x_Currency_Code			OUT	VARCHAR2,
			x_Invoicing_Rule			OUT	VARCHAR2,
			x_Accounting_Rule			OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On					OUT	NUMBER,
			x_First_Bill_Date			OUT	DATE,
			x_Next_Bill_Date			OUT	DATE,
			x_Workflow_Process_Id		OUT	NUMBER,
			x_Renewal_Rule				OUT	VARCHAR2,
			x_Termination_Rule			OUT	VARCHAR2,
			x_Contract_Amount			OUT	NUMBER,
			x_discount				OUT	VARCHAR2,
			x_Service_Id				OUT	NUMBER,
			x_Service					OUT	VARCHAR2,
			x_Service_Start_Date		OUT	DATE,
			x_Service_End_Date			OUT	DATE,
			x_Coverage_Id				OUT	NUMBER,
			x_coverage				OUT	VARCHAR2,
			p_rec_count				IN OUT	NUMBER,
               x_return_status          	OUT 	VARCHAR2,
               x_msg_count              	OUT 	NUMBER,
               x_msg_data               	OUT 	VARCHAR2  )IS

		l_api_name		VARCHAR2(30)	:= G_PKG_NAME;
		l_api_version		NUMBER		:= G_API_VERSION;
		l_contract_rec_type	CONTRACTS_REC_TYPE;
BEGIN

	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);

	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	IF (P_Customer_Product_Id IS NOT NULL) THEN
--DBMS_Output.Put_line('Cust. prod id is not null');
  		Get_List_Of_Contracts (
               p_api_version            ,
               p_init_msg_list          ,
               p_commit                 ,
			p_customer_product_id	,
			p_business_process_id	,
			p_charge_date_time		,
			p_time_zone_id			,
			p_exception_coverage_flag ,
			l_contract_rec_type		,
			x_Contract_Id			,
			x_Contract_Number		,
			x_Contract_Status		,
			x_Contract_Type		,
			x_Contract_Group		,
			x_Contract_Duration		,
			x_Contract_Period		,
			x_Contract_Start_Date	,
			x_Contract_End_Date		,
			x_Contract_Agreement	,
			x_Contract_Price_List	,
			x_Currency_Code		,
			x_Invoicing_Rule		,
			x_Accounting_Rule		,
			x_Billing_Frequency_Period	,
			x_Bill_On				,
			x_First_Bill_Date		,
			x_Next_Bill_Date		,
			x_Workflow_Process_Id	,
			x_Renewal_Rule			,
			x_Termination_Rule		,
			x_Contract_Amount		,
			x_discount			,
			x_Service_Id			,
			x_Service				,
			x_Service_Start_Date	,
			x_Service_End_Date		,
			x_Coverage_Id			,
			x_coverage			,
			p_rec_count			,
               x_return_status          ,
               x_msg_count              ,
               x_msg_data               );

	END IF;


	IF	(P_Site_Use_Id IS NOT NULL ) THEN
--DBMS_Output.Put_line('Site use id is not null');
  		Get_List_Of_Contracts (
               p_api_version            ,
               p_init_msg_list          ,
               p_commit                 ,
			p_system_id			,
			p_site_use_id			,
			p_Business_Process_Id	,
			p_charge_date_time		,
			p_time_zone_id			,
			p_exception_coverage_flag ,
			l_contract_rec_type		,
			x_Contract_Id			,
			x_Contract_Number		,
			x_Contract_Status		,
			x_Contract_Type		,
			x_Contract_Group		,
			x_Contract_Duration		,
			x_Contract_Period		,
			x_Contract_Start_Date	,
			x_Contract_End_Date		,
			x_Contract_Agreement	,
			x_Contract_Price_List	,
			x_Currency_Code		,
			x_Invoicing_Rule		,
			x_Accounting_Rule		,
			x_Billing_Frequency_Period	,
			x_Bill_On				,
			x_First_Bill_Date		,
			x_Next_Bill_Date		,
			x_Workflow_Process_Id	,
			x_Renewal_Rule			,
			x_Termination_Rule		,
			x_Contract_Amount		,
			x_discount			,
			x_Service_Id			,
			x_Service				,
			x_Service_Start_Date	,
			x_Service_End_Date		,
			x_Coverage_Id			,
			x_coverage			,
			p_rec_count			,
               x_return_status          ,
               x_msg_count              ,
               x_msg_data               );
	END IF;

	IF	(P_System_ID IS NOT NULL ) THEN
--DBMS_Output.Put_line('System id is not null');
  		Get_List_Of_Contracts (
               p_api_version            ,
               p_init_msg_list          ,
               p_commit                 ,
			p_system_id			,
			p_site_use_id			,
			p_Business_Process_Id	,
			p_charge_date_time		,
			p_time_zone_id			,
			p_exception_coverage_flag ,
			l_contract_rec_type		,
			x_Contract_Id			,
			x_Contract_Number		,
			x_Contract_Status		,
			x_Contract_Type		,
			x_Contract_Group		,
			x_Contract_Duration		,
			x_Contract_Period		,
			x_Contract_Start_Date	,
			x_Contract_End_Date		,
			x_Contract_Agreement	,
			x_Contract_Price_List	,
			x_Currency_Code		,
			x_Invoicing_Rule		,
			x_Accounting_Rule		,
			x_Billing_Frequency_Period	,
			x_Bill_On				,
			x_First_Bill_Date		,
			x_Next_Bill_Date		,
			x_Workflow_Process_Id	,
			x_Renewal_Rule			,
			x_Termination_Rule		,
			x_Contract_Amount		,
			x_discount			,
			x_Service_Id			,
			x_Service				,
			x_Service_Start_Date	,
			x_Service_End_Date		,
			x_Coverage_Id			,
			x_coverage			,
			p_rec_count			,
               x_return_status          ,
               x_msg_count              ,
               x_msg_data               );
	END IF;

	IF (P_Inventory_Item_Id IS NOT NULL ) THEN
--DBMS_Output.Put_line('Item id is not null');
  		Get_List_Of_Contracts (
               p_api_version            ,
               p_init_msg_list          ,
               p_commit                 ,
			p_inventory_item_id	,
			'ITEM',
			p_Business_Process_Id	,
			p_charge_date_time		,
			p_time_zone_id			,
			p_exception_coverage_flag ,
			l_contract_rec_type		,
			x_Contract_Id			,
			x_Contract_Number		,
			x_Contract_Status		,
			x_Contract_Type		,
			x_Contract_Group		,
			x_Contract_Duration		,
			x_Contract_Period		,
			x_Contract_Start_Date	,
			x_Contract_End_Date		,
			x_Contract_Agreement	,
			x_Contract_Price_List	,
			x_Currency_Code		,
			x_Invoicing_Rule		,
			x_Accounting_Rule		,
			x_Billing_Frequency_Period	,
			x_Bill_On				,
			x_First_Bill_Date		,
			x_Next_Bill_Date		,
			x_Workflow_Process_Id	,
			x_Renewal_Rule			,
			x_Termination_Rule		,
			x_Contract_Amount		,
			x_discount			,
			x_Service_Id			,
			x_Service				,
			x_Service_Start_Date	,
			x_Service_End_Date		,
			x_Coverage_Id			,
			x_coverage			,
			p_rec_count			,
               x_return_status          ,
               x_msg_count              ,
               x_msg_data               );
		END IF;

	IF (P_Customer_Id IS NOT NULL ) THEN
--DBMS_Output.Put_line('Cust. id is not null');
  		Get_List_Of_Contracts (
               p_api_version            ,
               p_init_msg_list          ,
               p_commit                 ,
			p_customer_Id	,
			'CUSTOMER',
			p_Business_Process_Id	,
			p_charge_date_time		,
			p_time_zone_id			,
			p_exception_coverage_flag ,
			l_contract_rec_type		,
			x_Contract_Id			,
			x_Contract_Number		,
			x_Contract_Status		,
			x_Contract_Type		,
			x_Contract_Group		,
			x_Contract_Duration		,
			x_Contract_Period		,
			x_Contract_Start_Date	,
			x_Contract_End_Date		,
			x_Contract_Agreement	,
			x_Contract_Price_List	,
			x_Currency_Code		,
			x_Invoicing_Rule		,
			x_Accounting_Rule		,
			x_Billing_Frequency_Period	,
			x_Bill_On				,
			x_First_Bill_Date		,
			x_Next_Bill_Date		,
			x_Workflow_Process_Id	,
			x_Renewal_Rule			,
			x_Termination_Rule		,
			x_Contract_Amount		,
			x_discount			,
			x_Service_Id			,
			x_Service				,
			x_Service_Start_Date	,
			x_Service_End_Date		,
			x_Coverage_Id			,
			x_coverage			,
			p_rec_count			,
               x_return_status          ,
               x_msg_count              ,
               x_msg_data               );
	END IF;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END Get_List_Of_Contracts;

Procedure migrate_to_table(
               p_api_version			IN	NUMBER,
               p_init_msg_list		IN	VARCHAR2  ,
               p_commit				IN	VARCHAR2  ,
			p_contract_rec_type		IN	CONTRACTS_REC_TYPE,
			p_rec_index			IN	NUMBER,
               x_return_status          OUT	VARCHAR2,
               x_msg_count              OUT	NUMBER,
               x_msg_data               OUT	VARCHAR2  ) IS

		l_api_name 	VARCHAR2(30)	:= G_PKG_NAME;
		l_api_version	NUMBER		:= G_API_VERSION;
Begin

--DBMS_Output.Put_Line('In Migrate to table');

	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

--DBMS_Output.Put_Line('After start');
	G_Contracts_Tab_Type(p_rec_index).V_Contract_Id
				:= p_contract_rec_type.V_Contract_Id;
--DBMS_OUTPUT.Put_Line('Global tab contract id='||
--			to_char(G_Contracts_Tab_Type(p_rec_index).V_CONTRACT_ID));
	G_Contracts_Tab_Type(p_rec_index).V_Contract_Number
				:= p_contract_rec_type.V_Contract_Number;
	G_Contracts_Tab_Type(p_rec_index).V_Contract_Status
				:= p_contract_rec_type.V_Contract_Status;
	G_Contracts_Tab_Type(p_rec_index).V_contract_Duration
				:= p_contract_rec_type.V_contract_duration;
	G_Contracts_Tab_Type(p_rec_index).V_Contract_Start_Date
				:= p_contract_rec_type.V_Contract_Start_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Contract_End_Date
				:= p_contract_rec_type.V_contract_end_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Currency_Code
				:= p_contract_rec_type.V_Currency_Code;
	G_Contracts_Tab_Type(p_rec_index).V_Bill_On
				:= p_contract_rec_type.V_Bill_ON;
	G_Contracts_Tab_Type(p_rec_index).V_First_Bill_Date
				:= p_contract_rec_type.V_First_Bill_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Next_Bill_Date
				:= p_contract_rec_type.V_Next_Bill_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Workflow_Process_Id
				:= p_contract_rec_type.V_Workflow_Process_Id;
	G_Contracts_Tab_Type(p_rec_index).V_Renewal_Rule
				:= p_contract_rec_type.V_Renewal_Rule;
	G_Contracts_Tab_Type(p_rec_index).V_Termination_Rule
				:= p_contract_rec_type.V_Termination_Rule;
	G_Contracts_Tab_Type(p_rec_index).V_Contract_Amount
				:= p_contract_rec_type.V_Contract_Amount;
	G_Contracts_Tab_Type(p_rec_index).V_Service_Id
				:= p_contract_rec_type.V_Service_Id;
	G_Contracts_Tab_Type(p_rec_index).V_Service
				:= p_contract_rec_type.V_Service;
	G_Contracts_Tab_Type(p_rec_index).V_Service_Start_Date
				:= p_contract_rec_type.V_Service_Start_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Service_End_Date
				:= p_contract_rec_type.V_Service_End_Date;
	G_Contracts_Tab_Type(p_rec_index).V_Coverage_Id
				:= p_contract_rec_type.V_Coverage_Id;
	G_Contracts_Tab_Type(p_rec_index).V_Coverage
				:= p_contract_rec_type.V_Coverage;

--DBMS_Output.Put_Line('Before end activity');

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

--DBMS_Output.Put_Line('After end activity');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --DBMS_Output.Put_Line('Expected Error');
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --DBMS_Output.Put_Line('UnExpected Error');
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
	--DBMS_Output.Put_Line('Others');
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END migrate_to_table;

Procedure count_and_get(
              	p_api_version			IN	NUMBER,
              	p_init_msg_list		IN	VARCHAR2  ,
              	p_commit				IN	VARCHAR2  ,
			p_rec_index			IN	NUMBER,
			x_Contract_Id			OUT	NUMBER,
			x_Contract_Number		OUT	NUMBER,
			x_Contract_Status		OUT	VARCHAR2,
			x_Contract_Type		OUT	VARCHAR2,
			x_Contract_Group		OUT	VARCHAR2,
			x_Contract_Duration		OUT	NUMBER,
			x_Contract_Period		OUT	VARCHAR2,
			x_Contract_Start_Date	OUT	DATE,
			x_Contract_End_Date		OUT	DATE,
			x_Contract_Agreement	OUT	VARCHAR2,
			x_Contract_Price_List	OUT	VARCHAR2,
			x_Currency_Code		OUT	VARCHAR2,
			x_Invoicing_Rule		OUT	VARCHAR2,
			x_Accounting_Rule		OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On				OUT	NUMBER	,
			x_First_Bill_Date		OUT	DATE,
			x_Next_Bill_Date		OUT	DATE,
			x_Workflow_Process_Id	OUT	NUMBER,
			x_Renewal_Rule			OUT	VARCHAR2,
			x_Termination_Rule		OUT	VARCHAR2,
			x_Contract_Amount		OUT	NUMBER,
			x_discount			OUT	VARCHAR2,
			x_Service_Id			OUT	NUMBER,
			x_Service				OUT	VARCHAR2,
			x_Service_Start_Date	OUT	DATE,
			x_Service_End_Date		OUT	DATE,
			x_Coverage_Id			OUT	NUMBER,
			x_coverage			OUT	VARCHAR2,
			p_rec_count			IN OUT	NUMBER,
               x_return_status          OUT	VARCHAR2,
               x_msg_count              OUT	NUMBER,
               x_msg_data               OUT	VARCHAR2  ) IS

		l_api_name 		VARCHAR2(30)	:= G_PKG_NAME;
		l_api_version		NUMBER		:= G_API_VERSION;
		l_contract_rec_type	CONTRACTS_REC_TYPE;
Begin

	--DBMS_Output.Put_Line('In count and get');

	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	--DBMS_Output.Put_Line('Count and get unexpected error');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

	--DBMS_Output.Put_Line('Count and get error');
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	--DBMS_Output.Put_Line('After start');

	x_contract_id := G_Contracts_Tab_Type(p_rec_index).V_Contract_Id;

	--DBMS_Output.Put_Line('Contract Id='|| to_char(x_contract_id));

	l_contract_rec_type.v_contract_id := G_Contracts_Tab_Type(p_rec_index).V_Contract_Id;

	x_contract_number :=
			G_Contracts_Tab_Type(p_rec_index).V_Contract_Number ;
	x_contract_status :=
			G_Contracts_Tab_Type(p_rec_index).V_Contract_Status;
	x_contract_duration :=
			G_Contracts_Tab_Type(p_rec_index).V_contract_Duration ;
	x_contract_start_date :=
			G_Contracts_Tab_Type(p_rec_index).V_Contract_Start_Date;
	x_contract_end_date :=
			G_Contracts_Tab_Type(p_rec_index).V_Contract_End_Date;
	x_currency_code :=
			G_Contracts_Tab_Type(p_rec_index).V_Currency_Code;
	x_bill_on := G_Contracts_Tab_Type(p_rec_index).V_Bill_On;
	x_first_bill_date :=
			G_Contracts_Tab_Type(p_rec_index).V_First_Bill_Date;
	x_next_bill_date :=
			G_Contracts_Tab_Type(p_rec_index).V_Next_Bill_Date	;
	x_workflow_process_id :=
			G_Contracts_Tab_Type(p_rec_index).V_Workflow_Process_Id;
	x_renewal_rule :=
			G_Contracts_Tab_Type(p_rec_index).V_Renewal_Rule	;
	x_termination_rule :=
			G_Contracts_Tab_Type(p_rec_index).V_Termination_Rule;
	x_contract_amount :=
			G_Contracts_Tab_Type(p_rec_index).V_Contract_Amount;
	x_service_id :=
			G_Contracts_Tab_Type(p_rec_index).V_Service_Id;
	x_service := G_Contracts_Tab_Type(p_rec_index).V_Service	;
	x_service_start_date :=
			G_Contracts_Tab_Type(p_rec_index).V_Service_Start_Date;
	x_service_end_date :=
			G_Contracts_Tab_Type(p_rec_index).V_Service_End_Date;
	x_coverage_id :=
			G_Contracts_Tab_Type(p_rec_index).V_Coverage_Id;
	x_coverage :=
			G_Contracts_Tab_Type(p_rec_index).V_Coverage;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

END count_and_get;

Procedure  Migrate_to_Out_Variables(
               p_api_version            	IN  	NUMBER,
               p_init_msg_list          	IN  	VARCHAR2  := FND_API.G_FALSE,
               p_commit                 	IN  	VARCHAR2  := FND_API.G_TRUE,
			x_contract_rec_Type			IN	CONTRACTS_REC_TYPE,
			x_Contract_Id				OUT	NUMBER,
			x_Contract_Number			OUT	NUMBER,
			x_Contract_Status			OUT	VARCHAR2,
			x_Contract_Type			OUT	VARCHAR2,
			x_Contract_Group			OUT	VARCHAR2,
			x_Contract_Duration			OUT	NUMBER,
			x_Contract_Period			OUT	VARCHAR2,
			x_Contract_Start_Date		OUT	DATE,
			x_Contract_End_Date			OUT	DATE,
			x_Contract_Agreement		OUT	VARCHAR2,
			x_Contract_Price_List		OUT	VARCHAR2,
			x_Currency_Code			OUT	VARCHAR2,
			x_Invoicing_Rule			OUT	VARCHAR2,
			x_Accounting_Rule			OUT	VARCHAR2,
			x_Billing_Frequency_Period	OUT	VARCHAR2,
			x_Bill_On					OUT	NUMBER,
			x_First_Bill_Date			OUT	DATE,
			x_Next_Bill_Date			OUT	DATE,
			x_Workflow_Process_Id		OUT	NUMBER,
			x_Renewal_Rule				OUT	VARCHAR2,
			x_Termination_Rule			OUT	VARCHAR2,
			x_Contract_Amount			OUT	NUMBER,
			x_discount				OUT	VARCHAR2,
			x_Service_Id				OUT	NUMBER,
			x_Service					OUT	VARCHAR2,
			x_Service_Start_Date		OUT	DATE,
			x_Service_End_Date			OUT	DATE,
			x_Coverage_Id				OUT	NUMBER,
			x_coverage				OUT	VARCHAR2,
               x_return_status          	OUT 	VARCHAR2,
               x_msg_count              	OUT 	NUMBER,
               x_msg_data               	OUT 	VARCHAR2  ) IS

		l_api_name 		VARCHAR2(30)	:= G_PKG_NAME;
		l_api_version		NUMBER		:= G_API_VERSION;
BEGIN
	x_return_status := TAPI_DEV_KIT.START_ACTIVITY(
									l_api_name,
                                             G_PKG_NAME,
                                             l_api_version,
                                             p_api_version,
                                             p_init_msg_list,
                                             '_Pvt',
                                             x_return_status);
	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	x_Contract_Id			:= x_contract_rec_type.V_Contract_Id;
	x_Contract_Number		:= x_contract_rec_type.V_Contract_Number;
	x_Contract_Status		:= x_contract_rec_type.V_COntract_Status;
	x_Contract_Duration		:= x_contract_rec_type.v_Contract_Duration;
	x_Contract_Start_Date	:= x_contract_rec_type.V_Contract_Start_Date;
	x_Contract_End_Date		:= x_contract_rec_type.V_Contract_End_Date;
	x_Currency_Code		:= x_contract_rec_type.V_Currency_code;
	x_Bill_On				:= x_contract_rec_type.V_Bill_On;
	x_First_Bill_Date		:= x_contract_rec_type.V_First_Bill_Date;
	x_Next_Bill_Date		:= x_contract_rec_type.V_Next_Bill_Date;
	x_Workflow_Process_Id	:= x_contract_rec_type.V_Workflow_Process_Id;
	x_Renewal_Rule			:= x_contract_rec_type.V_Renewal_Rule;
	x_Termination_Rule		:= x_contract_rec_type.V_Termination_Rule;
	x_Contract_Amount		:= x_contract_rec_type.V_Contract_Amount;
	x_Service_Id			:= x_contract_rec_type.V_Service_id;
	x_Service				:= x_contract_rec_type.V_Service;
	x_Service_Start_Date	:= x_contract_rec_type.V_Service_start_date;
	x_Service_End_Date		:= x_contract_rec_type.V_Service_End_Date;
	x_Coverage_Id			:= x_contract_rec_type.V_Coverage_Id;
	x_coverage			:= x_contract_rec_type.V_Coverage;

	TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
	);
	WHEN OTHERS THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_Pvt',
        SQLERRM
      );

End 	Migrate_to_Out_Variables;

END CS_GET_CONTRACTS_PUB;

/
