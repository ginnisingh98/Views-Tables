--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_GETPODATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_GETPODATA" AS
/* $Header: dppvbufb.pls 120.3 2007/12/17 07:08:04 sdasan noship $ */
	FUNCTION PL_TO_SQL11(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_PO_ IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_PO_;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_PO_(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.VENDOR_ID := aPlsqlItem.VENDOR_ID;
		aSqlItem.VENDOR_SITE_ID := aPlsqlItem.VENDOR_SITE_ID;
		aSqlItem.VENDOR_NUMBER := aPlsqlItem.VENDOR_NUMBER;
		aSqlItem.VENDOR_NAME := aPlsqlItem.VENDOR_NAME;
		aSqlItem.VENDOR_SITE_CODE := aPlsqlItem.VENDOR_SITE_CODE;
		aSqlItem.OPERATING_UNIT := aPlsqlItem.OPERATING_UNIT;
		RETURN aSqlItem;
	END PL_TO_SQL11;
	FUNCTION SQL_TO_PL11(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_PO_)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_REC_TYPE;
	BEGIN
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.VENDOR_ID := aSqlItem.VENDOR_ID;
		aPlsqlItem.VENDOR_SITE_ID := aSqlItem.VENDOR_SITE_ID;
		aPlsqlItem.VENDOR_NUMBER := aSqlItem.VENDOR_NUMBER;
		aPlsqlItem.VENDOR_NAME := aSqlItem.VENDOR_NAME;
		aPlsqlItem.VENDOR_SITE_CODE := aSqlItem.VENDOR_SITE_CODE;
		aPlsqlItem.OPERATING_UNIT := aSqlItem.OPERATING_UNIT;
		RETURN aPlsqlItem;
	END SQL_TO_PL11;
	FUNCTION PL_TO_SQL13(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_P13 IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P13;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_P13(NULL, NULL, NULL, NULL);
		aSqlItem.DOCUMENT_NUMBER := aPlsqlItem.DOCUMENT_NUMBER;
		aSqlItem.DOCUMENT_TYPE := aPlsqlItem.DOCUMENT_TYPE;
		aSqlItem.PO_LINE_NUMBER := aPlsqlItem.PO_LINE_NUMBER;
		aSqlItem.AUTHORIZATION_STATUS := aPlsqlItem.AUTHORIZATION_STATUS;
		RETURN aSqlItem;
	END PL_TO_SQL13;
	FUNCTION SQL_TO_PL13(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P13)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_REC_TYPE;
	BEGIN
		aPlsqlItem.DOCUMENT_NUMBER := aSqlItem.DOCUMENT_NUMBER;
		aPlsqlItem.DOCUMENT_TYPE := aSqlItem.DOCUMENT_TYPE;
		aPlsqlItem.PO_LINE_NUMBER := aSqlItem.PO_LINE_NUMBER;
		aPlsqlItem.AUTHORIZATION_STATUS := aSqlItem.AUTHORIZATION_STATUS;
		RETURN aPlsqlItem;
	END SQL_TO_PL13;
	FUNCTION PL_TO_SQL14(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_TBL_TYPE)
 	RETURN DPPPURCHASEPRICEPVTDPPP11_DPP IS
	aSqlItem DPPPURCHASEPRICEPVTDPPP11_DPP;
	BEGIN
		-- initialize the table
		aSqlItem := DPPPURCHASEPRICEPVTDPPP11_DPP();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL13(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL14;
	FUNCTION SQL_TO_PL14(aSqlItem DPPPURCHASEPRICEPVTDPPP11_DPP)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_TBL_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_DETAILS_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL13(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL14;
	FUNCTION PL_TO_SQL15(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_REC_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_P11 IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P11;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_P11(NULL, NULL, NULL, NULL, NULL);
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.ITEM_NUMBER := aPlsqlItem.ITEM_NUMBER;
		aSqlItem.NEW_PRICE := aPlsqlItem.NEW_PRICE;
		aSqlItem.CURRENCY := aPlsqlItem.CURRENCY;
		aSqlItem.PO_DETAILS_TBL := PL_TO_SQL14(aPlsqlItem.PO_DETAILS_TBL);
		RETURN aSqlItem;
	END PL_TO_SQL15;
	FUNCTION SQL_TO_PL15(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_P11)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_REC_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_REC_TYPE;
	BEGIN
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.ITEM_NUMBER := aSqlItem.ITEM_NUMBER;
		aPlsqlItem.NEW_PRICE := aSqlItem.NEW_PRICE;
		aPlsqlItem.CURRENCY := aSqlItem.CURRENCY;
		aPlsqlItem.PO_DETAILS_TBL := SQL_TO_PL14(aSqlItem.PO_DETAILS_TBL);
		RETURN aPlsqlItem;
	END SQL_TO_PL15;
	FUNCTION PL_TO_SQL12(aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_TBL_TYPE)
 	RETURN DPP_PURCHASEPRICE_PVT_DPP_PO10 IS
	aSqlItem DPP_PURCHASEPRICE_PVT_DPP_PO10;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_PURCHASEPRICE_PVT_DPP_PO10();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL15(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL12;
	FUNCTION SQL_TO_PL12(aSqlItem DPP_PURCHASEPRICE_PVT_DPP_PO10)
	RETURN DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_TBL_TYPE IS
	aPlsqlItem DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL15(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL12;

   PROCEDURE DPP_PURCHASEPRICE_PVT$NOTIFY_ (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,
   P_VALIDATION_LEVEL NUMBER,X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,
   X_MSG_DATA OUT NOCOPY VARCHAR2,P_PO_NOTIFY_HDR_REC IN OUT NOCOPY DPP_PURCHASEPRICE_PVT_DPP_PO_,
   P_PO_NOTIFY_ITEM_TBL IN OUT NOCOPY DPP_PURCHASEPRICE_PVT_DPP_PO10) IS
      P_PO_NOTIFY_HDR_REC_ APPS.DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_REC_TYPE;
      P_PO_NOTIFY_ITEM_TBL_ APPS.DPP_PURCHASEPRICE_PVT.DPP_PO_NOTIFY_ITEM_TBL_TYPE;
   BEGIN
      P_PO_NOTIFY_HDR_REC_ := DPP_BPEL_GETPODATA.SQL_TO_PL11(P_PO_NOTIFY_HDR_REC);
      P_PO_NOTIFY_ITEM_TBL_ := DPP_BPEL_GETPODATA.SQL_TO_PL12(P_PO_NOTIFY_ITEM_TBL);
      APPS.DPP_PURCHASEPRICE_PVT.NOTIFY_PO(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,X_RETURN_STATUS,
      X_MSG_COUNT,X_MSG_DATA,P_PO_NOTIFY_HDR_REC_,P_PO_NOTIFY_ITEM_TBL_);
      P_PO_NOTIFY_HDR_REC := DPP_BPEL_GETPODATA.PL_TO_SQL11(P_PO_NOTIFY_HDR_REC_);
      P_PO_NOTIFY_ITEM_TBL := DPP_BPEL_GETPODATA.PL_TO_SQL12(P_PO_NOTIFY_ITEM_TBL_);
   END DPP_PURCHASEPRICE_PVT$NOTIFY_;

END DPP_BPEL_GETPODATA;

/