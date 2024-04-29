--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_UPDATEPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_UPDATEPO" AS
/* $Header: dppvbudb.pls 120.3 2007/12/18 13:18:00 assoni noship $ */
	FUNCTION PL_TO_SQL14(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_TXN_HDR_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_TXN IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_TXN;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_TXN(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_HEADER_ID := aPlsqlItem.TRANSACTION_HEADER_ID;
		aSqlItem.TRANSACTION_NUMBER := aPlsqlItem.TRANSACTION_NUMBER;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.VENDOR_ID := aPlsqlItem.VENDOR_ID;
		aSqlItem.EXECUTION_DETAIL_ID := aPlsqlItem.EXECUTION_DETAIL_ID;
		aSqlItem.PROVIDER_PROCESS_ID := aPlsqlItem.PROVIDER_PROCESS_ID;
		aSqlItem.PROVIDER_PROCESS_INSTANCE_ID := aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.ATTRIBUTE_CATEGORY := aPlsqlItem.ATTRIBUTE_CATEGORY;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		RETURN aSqlItem;
	END PL_TO_SQL14;
	FUNCTION SQL_TO_PL14(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_TXN)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_TXN_HDR_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_TXN_HDR_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_HEADER_ID := aSqlItem.TRANSACTION_HEADER_ID;
		aPlsqlItem.TRANSACTION_NUMBER := aSqlItem.TRANSACTION_NUMBER;
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.VENDOR_ID := aSqlItem.VENDOR_ID;
		aPlsqlItem.EXECUTION_DETAIL_ID := aSqlItem.EXECUTION_DETAIL_ID;
		aPlsqlItem.PROVIDER_PROCESS_ID := aSqlItem.PROVIDER_PROCESS_ID;
		aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID := aSqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.ATTRIBUTE_CATEGORY := aSqlItem.ATTRIBUTE_CATEGORY;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		RETURN aPlsqlItem;
	END SQL_TO_PL14;
	FUNCTION PL_TO_SQL15(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_P20 IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P20;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_P20(NULL, NULL, NULL, NULL);
		aSqlItem.DOCUMENT_NUMBER := aPlsqlItem.DOCUMENT_NUMBER;
		aSqlItem.DOCUMENT_TYPE := aPlsqlItem.DOCUMENT_TYPE;
		aSqlItem.LINE_NUMBER := aPlsqlItem.LINE_NUMBER;
		aSqlItem.REASON_FOR_FAILURE := aPlsqlItem.REASON_FOR_FAILURE;
		RETURN aSqlItem;
	END PL_TO_SQL15;
	FUNCTION SQL_TO_PL16(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P20)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_REC_TYPE;
	BEGIN
		aPlsqlItem.DOCUMENT_NUMBER := aSqlItem.DOCUMENT_NUMBER;
		aPlsqlItem.DOCUMENT_TYPE := aSqlItem.DOCUMENT_TYPE;
		aPlsqlItem.LINE_NUMBER := aSqlItem.LINE_NUMBER;
		aPlsqlItem.REASON_FOR_FAILURE := aSqlItem.REASON_FOR_FAILURE;
		RETURN aPlsqlItem;
	END SQL_TO_PL16;
	FUNCTION PL_TO_SQL16(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_TBL_TYPE)
 	RETURN DPPPURCHASEPRICEPVTDPPIT9_DPP IS
	aSqlItem DPPPURCHASEPRICEPVTDPPIT9_DPP;
	BEGIN
		-- initialize the table
		aSqlItem := DPPPURCHASEPRICEPVTDPPIT9_DPP();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL15(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL16;
	FUNCTION SQL_TO_PL17(aSqlItem DPPPURCHASEPRICEPVTDPPIT9_DPP)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_TBL_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_LINE_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL16(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL17;
	FUNCTION PL_TO_SQL17(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_IT9 IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_IT9;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_IT9(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_LINE_ID := aPlsqlItem.TRANSACTION_LINE_ID;
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.ITEM_NUMBER := aPlsqlItem.ITEM_NUMBER;
		aSqlItem.NEW_PRICE := aPlsqlItem.NEW_PRICE;
		aSqlItem.CURRENCY := aPlsqlItem.CURRENCY;
		aSqlItem.UOM := aPlsqlItem.UOM;
		aSqlItem.PO_LINE_TBL := PL_TO_SQL16(aPlsqlItem.PO_LINE_TBL);
		aSqlItem.ATTRIBUTE_CATEGORY := aPlsqlItem.ATTRIBUTE_CATEGORY;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.UPDATE_STATUS := aPlsqlItem.UPDATE_STATUS;
		RETURN aSqlItem;
	END PL_TO_SQL17;
	FUNCTION SQL_TO_PL18(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_IT9)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_LINE_ID := aSqlItem.TRANSACTION_LINE_ID;
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.ITEM_NUMBER := aSqlItem.ITEM_NUMBER;
		aPlsqlItem.NEW_PRICE := aSqlItem.NEW_PRICE;
		aPlsqlItem.CURRENCY := aSqlItem.CURRENCY;
		aPlsqlItem.UOM := aSqlItem.UOM;
		aPlsqlItem.PO_LINE_TBL := SQL_TO_PL17(aSqlItem.PO_LINE_TBL);
		aPlsqlItem.ATTRIBUTE_CATEGORY := aSqlItem.ATTRIBUTE_CATEGORY;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.UPDATE_STATUS := aSqlItem.UPDATE_STATUS;
		RETURN aPlsqlItem;
	END SQL_TO_PL18;
	FUNCTION PL_TO_SQL18(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_TBL_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_ITE IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_ITE;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_ITE();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL17(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL18;
	FUNCTION SQL_TO_PL15(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_ITE)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_TBL_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL18(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL15;

   PROCEDURE DPP_PURCHASEPRICE_PVT$UPDATE_ (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,
   P_VALIDATION_LEVEL NUMBER,X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,
   X_MSG_DATA OUT NOCOPY VARCHAR2,P_ITEM_PRICE_REC DPP_PURCHASEPRICE_PVT_DPP_TXN,P_ITEM_COST_TBL DPP_PURCHASEPRICE_PVT_DPP_ITE) IS
      P_ITEM_PRICE_REC_ DPP_PURCHASEPRICE_PVT.DPP_TXN_HDR_REC_TYPE;
      P_ITEM_COST_TBL_ DPP_PURCHASEPRICE_PVT.DPP_ITEM_COST_TBL_TYPE;
   BEGIN
      P_ITEM_PRICE_REC_ := DPP_BPEL_UPDATEPO.SQL_TO_PL14(P_ITEM_PRICE_REC);
      P_ITEM_COST_TBL_ := DPP_BPEL_UPDATEPO.SQL_TO_PL15(P_ITEM_COST_TBL);
      DPP_PURCHASEPRICE_PVT.UPDATE_PURCHASEPRICE(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,X_RETURN_STATUS,X_MSG_COUNT,X_MSG_DATA,P_ITEM_PRICE_REC_,P_ITEM_COST_TBL_);
   END DPP_PURCHASEPRICE_PVT$UPDATE_;

END DPP_BPEL_UPDATEPO;

/