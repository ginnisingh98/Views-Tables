--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_SELCOVINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_SELCOVINV" AS
/* $Header: dppvbsib.pls 120.2 2007/12/12 06:28:17 sdasan noship $ */
	FUNCTION PL_TO_SQL1(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_HDR_REC_TYPE)
 	RETURN DPP_COVEREDINVENTORY_PVT_DPP_ IS
	aSqlItem DPP_COVEREDINVENTORY_PVT_DPP_;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_COVEREDINVENTORY_PVT_DPP_(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_HEADER_ID := aPlsqlItem.TRANSACTION_HEADER_ID;
		aSqlItem.EFFECTIVE_START_DATE := aPlsqlItem.EFFECTIVE_START_DATE;
		aSqlItem.EFFECTIVE_END_DATE := aPlsqlItem.EFFECTIVE_END_DATE;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.EXECUTION_DETAIL_ID := aPlsqlItem.EXECUTION_DETAIL_ID;
		aSqlItem.OUTPUT_XML := aPlsqlItem.OUTPUT_XML;
		aSqlItem.PROVIDER_PROCESS_ID := aPlsqlItem.PROVIDER_PROCESS_ID;
		aSqlItem.PROVIDER_PROCESS_INSTANCE_ID := aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		RETURN aSqlItem;
	END PL_TO_SQL1;
	FUNCTION SQL_TO_PL0(aSqlItem DPP_COVEREDINVENTORY_PVT_DPP_)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_HDR_REC_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_HDR_REC_TYPE;
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
		RETURN aPlsqlItem;
	END SQL_TO_PL0;
	FUNCTION PL_TO_SQL2(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_REC_TYPE)
 	RETURN DPP_COVEREDINVENTORY_PVT_DPP6 IS
	aSqlItem DPP_COVEREDINVENTORY_PVT_DPP6;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_COVEREDINVENTORY_PVT_DPP6(NULL, NULL);
		aSqlItem.DATE_RECEIVED := aPlsqlItem.DATE_RECEIVED;
		aSqlItem.ONHAND_QUANTITY := aPlsqlItem.ONHAND_QUANTITY;
		RETURN aSqlItem;
	END PL_TO_SQL2;
	FUNCTION SQL_TO_PL2(aSqlItem DPP_COVEREDINVENTORY_PVT_DPP6)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_REC_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_REC_TYPE;
	BEGIN
		aPlsqlItem.DATE_RECEIVED := aSqlItem.DATE_RECEIVED;
		aPlsqlItem.ONHAND_QUANTITY := aSqlItem.ONHAND_QUANTITY;
		RETURN aPlsqlItem;
	END SQL_TO_PL2;
	FUNCTION PL_TO_SQL3(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_TBL_TYPE)
 	RETURN DPPCOVEREDINVENTORYPVTDPP4_DP IS
	aSqlItem DPPCOVEREDINVENTORYPVTDPP4_DP;
	BEGIN
		-- initialize the table
		aSqlItem := DPPCOVEREDINVENTORYPVTDPP4_DP();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL2(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL3;
	FUNCTION SQL_TO_PL3(aSqlItem DPPCOVEREDINVENTORYPVTDPP4_DP)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_TBL_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_RCT_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL2(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL3;
	FUNCTION PL_TO_SQL4(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_REC_TYPE)
 	RETURN DPP_COVEREDINVENTORY_PVT_DPP4 IS
	aSqlItem DPP_COVEREDINVENTORY_PVT_DPP4;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_COVEREDINVENTORY_PVT_DPP4(NULL, NULL, NULL, NULL);
		aSqlItem.WAREHOUSE_ID := aPlsqlItem.WAREHOUSE_ID;
		aSqlItem.WAREHOUSE_NAME := aPlsqlItem.WAREHOUSE_NAME;
		aSqlItem.COVERED_QUANTITY := aPlsqlItem.COVERED_QUANTITY;
		aSqlItem.RCT_LINE_TBL := PL_TO_SQL3(aPlsqlItem.RCT_LINE_TBL);
		RETURN aSqlItem;
	END PL_TO_SQL4;
	FUNCTION SQL_TO_PL4(aSqlItem DPP_COVEREDINVENTORY_PVT_DPP4)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_REC_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_REC_TYPE;
	BEGIN
		aPlsqlItem.WAREHOUSE_ID := aSqlItem.WAREHOUSE_ID;
		aPlsqlItem.WAREHOUSE_NAME := aSqlItem.WAREHOUSE_NAME;
		aPlsqlItem.COVERED_QUANTITY := aSqlItem.COVERED_QUANTITY;
		aPlsqlItem.RCT_LINE_TBL := SQL_TO_PL3(aSqlItem.RCT_LINE_TBL);
		RETURN aPlsqlItem;
	END SQL_TO_PL4;
	FUNCTION PL_TO_SQL5(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_TBL_TYPE)
 	RETURN DPPCOVEREDINVENTORYPVTDPP2_DP IS
	aSqlItem DPPCOVEREDINVENTORYPVTDPP2_DP;
	BEGIN
		-- initialize the table
		aSqlItem := DPPCOVEREDINVENTORYPVTDPP2_DP();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL4(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL5;
	FUNCTION SQL_TO_PL5(aSqlItem DPPCOVEREDINVENTORYPVTDPP2_DP)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_TBL_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_WH_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL4(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL5;
	FUNCTION PL_TO_SQL6(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_REC_TYPE)
 	RETURN DPP_COVEREDINVENTORY_PVT_DPP2 IS
	aSqlItem DPP_COVEREDINVENTORY_PVT_DPP2;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_COVEREDINVENTORY_PVT_DPP2(NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_LINE_ID := aPlsqlItem.TRANSACTION_LINE_ID;
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.UOM_CODE := aPlsqlItem.UOM_CODE;
		aSqlItem.ONHAND_QUANTITY := aPlsqlItem.ONHAND_QUANTITY;
		aSqlItem.COVERED_QUANTITY := aPlsqlItem.COVERED_QUANTITY;
		aSqlItem.WH_LINE_TBL := PL_TO_SQL5(aPlsqlItem.WH_LINE_TBL);
		RETURN aSqlItem;
	END PL_TO_SQL6;
	FUNCTION SQL_TO_PL6(aSqlItem DPP_COVEREDINVENTORY_PVT_DPP2)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_REC_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_LINE_ID := aSqlItem.TRANSACTION_LINE_ID;
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.UOM_CODE := aSqlItem.UOM_CODE;
		aPlsqlItem.ONHAND_QUANTITY := aSqlItem.ONHAND_QUANTITY;
		aPlsqlItem.COVERED_QUANTITY := aSqlItem.COVERED_QUANTITY;
		aPlsqlItem.WH_LINE_TBL := SQL_TO_PL5(aSqlItem.WH_LINE_TBL);
		RETURN aPlsqlItem;
	END SQL_TO_PL6;
	FUNCTION PL_TO_SQL0(aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_TBL_TYPE)
 	RETURN DPP_COVEREDINVENTORY_PVT_DPP1 IS
	aSqlItem DPP_COVEREDINVENTORY_PVT_DPP1;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_COVEREDINVENTORY_PVT_DPP1();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL6(aPlsqlItem(I));
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL0;
	FUNCTION SQL_TO_PL1(aSqlItem DPP_COVEREDINVENTORY_PVT_DPP1)
	RETURN DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_TBL_TYPE IS
	aPlsqlItem DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL6(aSqlItem(I));
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL1;

   PROCEDURE DPP_COVEREDINVENTORY_PVT$SELE (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,P_VALIDATION_LEVEL NUMBER,
   X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,X_MSG_DATA OUT NOCOPY VARCHAR2,
   P_INV_HDR_REC DPP_COVEREDINVENTORY_PVT_DPP_,P_COVERED_INV_TBL IN OUT NOCOPY DPP_COVEREDINVENTORY_PVT_DPP1) IS
      P_INV_HDR_REC_ APPS.DPP_COVEREDINVENTORY_PVT.DPP_INV_HDR_REC_TYPE;
      P_COVERED_INV_TBL_ APPS.DPP_COVEREDINVENTORY_PVT.DPP_INV_COV_TBL_TYPE;
   BEGIN
      P_INV_HDR_REC_ := DPP_BPEL_SELCOVINV.SQL_TO_PL0(P_INV_HDR_REC);
      P_COVERED_INV_TBL_ := DPP_BPEL_SELCOVINV.SQL_TO_PL1(P_COVERED_INV_TBL);
      APPS.DPP_COVEREDINVENTORY_PVT.SELECT_COVEREDINVENTORY(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,X_RETURN_STATUS,X_MSG_COUNT,X_MSG_DATA,P_INV_HDR_REC_,P_COVERED_INV_TBL_);
      P_COVERED_INV_TBL := DPP_BPEL_SELCOVINV.PL_TO_SQL0(P_COVERED_INV_TBL_);
   END DPP_COVEREDINVENTORY_PVT$SELE;

END DPP_BPEL_SELCOVINV;

/
