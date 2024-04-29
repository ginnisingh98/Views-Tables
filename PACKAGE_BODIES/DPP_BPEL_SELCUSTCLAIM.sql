--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_SELCUSTCLAIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_SELCUSTCLAIM" AS
/* $Header: dppvbscb.pls 120.4 2008/02/12 09:47:23 vdewan noship $ */
	FUNCTION PL_TO_SQL1(aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUST_HDR_REC_TYPE)
 	RETURN DPP_CUSTOMERCLAIMS_PVT_DPP_CU IS
	aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_CU;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_CUSTOMERCLAIMS_PVT_DPP_CU(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_HEADER_ID := aPlsqlItem.TRANSACTION_HEADER_ID;
		aSqlItem.EFFECTIVE_START_DATE := aPlsqlItem.EFFECTIVE_START_DATE;
		aSqlItem.EFFECTIVE_END_DATE := aPlsqlItem.EFFECTIVE_END_DATE;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.EXECUTION_DETAIL_ID := aPlsqlItem.EXECUTION_DETAIL_ID;
		aSqlItem.OUTPUT_XML := aPlsqlItem.OUTPUT_XML;
		aSqlItem.PROVIDER_PROCESS_ID := aPlsqlItem.PROVIDER_PROCESS_ID;
		aSqlItem.PROVIDER_PROCESS_INSTANCE_ID := aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.CURRENCY_CODE := aPlsqlItem.CURRENCY_CODE;
		RETURN aSqlItem;
	END PL_TO_SQL1;
	FUNCTION SQL_TO_PL0(aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_CU)
	RETURN DPP_CUSTOMERCLAIMS_PVT.DPP_CUST_HDR_REC_TYPE IS
	aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUST_HDR_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_HEADER_ID := aSqlItem.TRANSACTION_HEADER_ID;
		aPlsqlItem.EFFECTIVE_START_DATE := aSqlItem.EFFECTIVE_START_DATE;
		aPlsqlItem.EFFECTIVE_END_DATE := aSqlItem.EFFECTIVE_END_DATE;
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.EXECUTION_DETAIL_ID := aSqlItem.EXECUTION_DETAIL_ID;
		aPlsqlItem.OUTPUT_XML := aSqlItem.OUTPUT_XML;
		aPlsqlItem.PROVIDER_PROCESS_ID := aSqlItem.PROVIDER_PROCESS_ID;
		aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID := aSqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.CURRENCY_CODE := aSqlItem.CURRENCY_CODE;
		RETURN aPlsqlItem;
	END SQL_TO_PL0;
	FUNCTION PL_TO_SQL2(aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_REC_TYPE)
 	RETURN DPP_CUSTOMERCLAIMS_PVT_DPP_C4 IS
	aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C4;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_CUSTOMERCLAIMS_PVT_DPP_C4(NULL, NULL, NULL);
		aSqlItem.CUST_ACCOUNT_ID := aPlsqlItem.CUST_ACCOUNT_ID;
		aSqlItem.LAST_PRICE := aPlsqlItem.LAST_PRICE;
		aSqlItem.INVOICE_CURRENCY_CODE := aPlsqlItem.INVOICE_CURRENCY_CODE;
		RETURN aSqlItem;
	END PL_TO_SQL2;
	FUNCTION SQL_TO_PL2(aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C4)
	RETURN DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_REC_TYPE IS
	aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_REC_TYPE;
	BEGIN
		aPlsqlItem.CUST_ACCOUNT_ID := aSqlItem.CUST_ACCOUNT_ID;
		aPlsqlItem.LAST_PRICE := aSqlItem.LAST_PRICE;
		aPlsqlItem.INVOICE_CURRENCY_CODE := aSqlItem.INVOICE_CURRENCY_CODE;
		RETURN aPlsqlItem;
	END SQL_TO_PL2;
	FUNCTION PL_TO_SQL3(aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_TBL_TYPE)
 	RETURN DPPCUSTOMERCLAIMSPVTDPPC2_DPP IS
	aSqlItem DPPCUSTOMERCLAIMSPVTDPPC2_DPP;
	BEGIN
		-- initialize the table
		aSqlItem := DPPCUSTOMERCLAIMSPVTDPPC2_DPP();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL2(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL3;
	FUNCTION SQL_TO_PL3(aSqlItem DPPCUSTOMERCLAIMSPVTDPPC2_DPP)
	RETURN DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_TBL_TYPE IS
	aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_PRICE_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL2(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL3;
	FUNCTION PL_TO_SQL4(aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_REC_TYPE)
 	RETURN DPP_CUSTOMERCLAIMS_PVT_DPP_C2 IS
	aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C2;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_CUSTOMERCLAIMS_PVT_DPP_C2(NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_LINE_ID := aPlsqlItem.TRANSACTION_LINE_ID;
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.UOM_CODE := aPlsqlItem.UOM_CODE;
		aSqlItem.CUSTOMER_PRICE_TBL := PL_TO_SQL3(aPlsqlItem.CUSTOMER_PRICE_TBL);
		RETURN aSqlItem;
	END PL_TO_SQL4;
	FUNCTION SQL_TO_PL4(aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C2)
	RETURN DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_REC_TYPE IS
	aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_LINE_ID := aSqlItem.TRANSACTION_LINE_ID;
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.UOM_CODE := aSqlItem.UOM_CODE;
		aPlsqlItem.CUSTOMER_PRICE_TBL := SQL_TO_PL3(aSqlItem.CUSTOMER_PRICE_TBL);
		RETURN aPlsqlItem;
	END SQL_TO_PL4;
	FUNCTION PL_TO_SQL0(aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_TBL_TYPE)
 	RETURN DPP_CUSTOMERCLAIMS_PVT_DPP_C1 IS
	aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C1;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_CUSTOMERCLAIMS_PVT_DPP_C1();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL4(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL0;
	FUNCTION SQL_TO_PL1(aSqlItem DPP_CUSTOMERCLAIMS_PVT_DPP_C1)
	RETURN DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_TBL_TYPE IS
	aPlsqlItem DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL4(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL1;

   PROCEDURE DPP_CUSTOMERCLAIMS_PVT$SELECT (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,P_VALIDATION_LEVEL NUMBER,X_RETURN_STATUS OUT NOCOPY VARCHAR2,
   X_MSG_COUNT OUT NOCOPY NUMBER,X_MSG_DATA OUT NOCOPY VARCHAR2,P_CUST_HDR_REC DPP_CUSTOMERCLAIMS_PVT_DPP_CU,
   P_CUSTOMER_TBL IN OUT NOCOPY DPP_CUSTOMERCLAIMS_PVT_DPP_C1) IS
      P_CUST_HDR_REC_ APPS.DPP_CUSTOMERCLAIMS_PVT.DPP_CUST_HDR_REC_TYPE;
      P_CUSTOMER_TBL_ APPS.DPP_CUSTOMERCLAIMS_PVT.DPP_CUSTOMER_TBL_TYPE;
   BEGIN
      P_CUST_HDR_REC_ := DPP_BPEL_SELCUSTCLAIM.SQL_TO_PL0(P_CUST_HDR_REC);
      P_CUSTOMER_TBL_ := DPP_BPEL_SELCUSTCLAIM.SQL_TO_PL1(P_CUSTOMER_TBL);
      APPS.DPP_CUSTOMERCLAIMS_PVT.SELECT_CUSTOMERPRICE(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,
      X_RETURN_STATUS,X_MSG_COUNT,X_MSG_DATA,P_CUST_HDR_REC_,P_CUSTOMER_TBL_);
      P_CUSTOMER_TBL := DPP_BPEL_SELCUSTCLAIM.PL_TO_SQL0(P_CUSTOMER_TBL_);
   END DPP_CUSTOMERCLAIMS_PVT$SELECT;

END DPP_BPEL_SELCUSTCLAIM;

/