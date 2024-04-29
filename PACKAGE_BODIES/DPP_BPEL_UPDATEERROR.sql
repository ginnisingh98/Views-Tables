--------------------------------------------------------
--  DDL for Package Body DPP_BPEL_UPDATEERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_BPEL_UPDATEERROR" AS
/* $Header: dppvburb.pls 120.5 2007/12/18 13:16:38 assoni noship $ */
	FUNCTION PL_TO_SQL0(aPlsqlItem DPP_ERROR_PVT.DPP_ERROR_REC_TYPE)
 	RETURN DPP_ERROR_PVT_DPP_ERROR_REC_T IS
	aSqlItem DPP_ERROR_PVT_DPP_ERROR_REC_T;
	BEGIN
		-- initialize the object
		aSqlItem := DPP_ERROR_PVT_DPP_ERROR_REC_T(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.TRANSACTION_HEADER_ID := aPlsqlItem.TRANSACTION_HEADER_ID;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.EXECUTION_DETAIL_ID := aPlsqlItem.EXECUTION_DETAIL_ID;
		aSqlItem.OUTPUT_XML := aPlsqlItem.OUTPUT_XML;
		aSqlItem.PROVIDER_PROCESS_ID := aPlsqlItem.PROVIDER_PROCESS_ID;
		aSqlItem.PROVIDER_PROCESS_INSTANCE_ID := aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		RETURN aSqlItem;
	END PL_TO_SQL0;
	FUNCTION SQL_TO_PL0(aSqlItem DPP_ERROR_PVT_DPP_ERROR_REC_T)
	RETURN DPP_ERROR_PVT.DPP_ERROR_REC_TYPE IS
	aPlsqlItem DPP_ERROR_PVT.DPP_ERROR_REC_TYPE;
	BEGIN
		aPlsqlItem.TRANSACTION_HEADER_ID := aSqlItem.TRANSACTION_HEADER_ID;
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.EXECUTION_DETAIL_ID := aSqlItem.EXECUTION_DETAIL_ID;
		aPlsqlItem.OUTPUT_XML := aSqlItem.OUTPUT_XML;
		aPlsqlItem.PROVIDER_PROCESS_ID := aSqlItem.PROVIDER_PROCESS_ID;
		aPlsqlItem.PROVIDER_PROCESS_INSTANCE_ID := aSqlItem.PROVIDER_PROCESS_INSTANCE_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		RETURN aPlsqlItem;
	END SQL_TO_PL0;
	FUNCTION PL_TO_SQL1(aPlsqlItem DPP_ERROR_PVT.DPP_LINES_TBL_TYPE)
 	RETURN DPP_ERROR_PVT_DPP_LINES_TBL_T IS
	aSqlItem DPP_ERROR_PVT_DPP_LINES_TBL_T;
	BEGIN
		-- initialize the table
		aSqlItem := DPP_ERROR_PVT_DPP_LINES_TBL_T();
		aSqlItem.EXTEND(aPlsqlItem.COUNT);
		FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := aPlsqlItem(I);
		END LOOP;
		RETURN aSqlItem;
	END PL_TO_SQL1;
	FUNCTION SQL_TO_PL1(aSqlItem DPP_ERROR_PVT_DPP_LINES_TBL_T)
	RETURN DPP_ERROR_PVT.DPP_LINES_TBL_TYPE IS
	aPlsqlItem DPP_ERROR_PVT.DPP_LINES_TBL_TYPE;
	BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := aSqlItem(I);
		END LOOP;
		RETURN aPlsqlItem;
	END SQL_TO_PL1;

   PROCEDURE DPP_ERROR_PVT$UPDATE_ERROR (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,
   P_VALIDATION_LEVEL NUMBER,X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,
   X_MSG_DATA OUT NOCOPY VARCHAR2,P_EXE_UPDATE_REC DPP_ERROR_PVT_DPP_ERROR_REC_T,P_LINES_TBL DPP_ERROR_PVT_DPP_LINES_TBL_T) IS
      P_EXE_UPDATE_REC_ DPP_ERROR_PVT.DPP_ERROR_REC_TYPE;
      P_LINES_TBL_ DPP_ERROR_PVT.DPP_LINES_TBL_TYPE;
   BEGIN
      P_EXE_UPDATE_REC_ := DPP_BPEL_UPDATEERROR.SQL_TO_PL0(P_EXE_UPDATE_REC);
      P_LINES_TBL_ := DPP_BPEL_UPDATEERROR.SQL_TO_PL1(P_LINES_TBL);
      DPP_ERROR_PVT.UPDATE_ERROR(P_API_VERSION,P_INIT_MSG_LIST,P_COMMIT,P_VALIDATION_LEVEL,X_RETURN_STATUS,X_MSG_COUNT,X_MSG_DATA,P_EXE_UPDATE_REC_,P_LINES_TBL_);
   END DPP_ERROR_PVT$UPDATE_ERROR;

END DPP_BPEL_UPDATEERROR;

/