--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_UPDATELISTPRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_UPDATELISTPRICE" AS
/* $Header: dppvbulb.pls 120.1 2007/12/12 05:57:15 sdasan noship $ */
	FUNCTION PL_TO_SQL22(aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_HDR_REC_TYPE)
 	RETURN DPP_LISTPRICE_PVT_DPP_TXN_H12 IS
	aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_H12;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_LISTPRICE_PVT_DPP_TXN_H12(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
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
	END PL_TO_SQL22;
	FUNCTION SQL_TO_PL22(aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_H12)
	RETURN DPP_LISTPRICE_PVT.DPP_TXN_HDR_REC_TYPE IS
	aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_HDR_REC_TYPE;
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
	END SQL_TO_PL22;
	FUNCTION PL_TO_SQL23(aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_LINE_REC_TYPE)
 	RETURN DPP_LISTPRICE_PVT_DPP_TXN_L14 IS
	aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_L14;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_LISTPRICE_PVT_DPP_TXN_L14(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_LINE_ID := aPlsqlItem.TRANSACTION_LINE_ID;
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.ITEM_NUMBER := aPlsqlItem.ITEM_NUMBER;
		aSqlItem.NEW_PRICE := aPlsqlItem.NEW_PRICE;
		aSqlItem.CURRENCY := aPlsqlItem.CURRENCY;
		aSqlItem.UOM := aPlsqlItem.UOM;
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
		aSqlItem.REASON_FOR_FAILURE := aPlsqlItem.REASON_FOR_FAILURE;
		RETURN aSqlItem;
	END PL_TO_SQL23;
	FUNCTION SQL_TO_PL24(aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_L14)
	RETURN DPP_LISTPRICE_PVT.DPP_TXN_LINE_REC_TYPE IS
	aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_LINE_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_LINE_ID := aSqlItem.TRANSACTION_LINE_ID;
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.ITEM_NUMBER := aSqlItem.ITEM_NUMBER;
		aPlsqlItem.NEW_PRICE := aSqlItem.NEW_PRICE;
		aPlsqlItem.CURRENCY := aSqlItem.CURRENCY;
		aPlsqlItem.UOM := aSqlItem.UOM;
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
		aPlsqlItem.REASON_FOR_FAILURE := aSqlItem.REASON_FOR_FAILURE;
		RETURN aPlsqlItem;
	END SQL_TO_PL24;
	FUNCTION PL_TO_SQL24(aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_LINE_TBL_TYPE)
 	RETURN DPP_LISTPRICE_PVT_DPP_TXN_L13 IS
	aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_L13;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_LISTPRICE_PVT_DPP_TXN_L13();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL23(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL24;
	FUNCTION SQL_TO_PL23(aSqlItem DPP_LISTPRICE_PVT_DPP_TXN_L13)
	RETURN DPP_LISTPRICE_PVT.DPP_TXN_LINE_TBL_TYPE IS
	aPlsqlItem DPP_LISTPRICE_PVT.DPP_TXN_LINE_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL24(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL23;

   PROCEDURE DPP_LISTPRICE_PVT$UPDATE_LIST (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,P_VALIDATION_LEVEL NUMBER,
   X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,X_MSG_DATA OUT NOCOPY VARCHAR2,
   P_TXN_HDR_REC DPP_LISTPRICE_PVT_DPP_TXN_H12,P_ITEM_COST_TBL DPP_LISTPRICE_PVT_DPP_TXN_L13) IS
      P_TXN_HDR_REC_ APPS.DPP_LISTPRICE_PVT.DPP_TXN_HDR_REC_TYPE;
      P_ITEM_COST_TBL_ APPS.DPP_LISTPRICE_PVT.DPP_TXN_LINE_TBL_TYPE;
   BEGIN
      P_TXN_HDR_REC_ := DPP_BPEL_UPDATELISTPRICE.SQL_TO_PL22(P_TXN_HDR_REC);
      P_ITEM_COST_TBL_ := DPP_BPEL_UPDATELISTPRICE.SQL_TO_PL23(P_ITEM_COST_TBL);
      APPS.DPP_LISTPRICE_PVT.UPDATE_LISTPRICE(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,X_RETURN_STATUS,X_MSG_COUNT,X_MSG_DATA,P_TXN_HDR_REC_,P_ITEM_COST_TBL_);
   END DPP_LISTPRICE_PVT$UPDATE_LIST;

END DPP_BPEL_UPDATELISTPRICE;

/