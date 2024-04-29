--------------------------------------------------------
--  DDL for Package DPP_BPEL_CREATECLAIMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_BPEL_CREATECLAIMS" AUTHID CURRENT_USER AS
/* $Header: dppvbccs.pls 120.1 2007/12/12 05:59:54 sdasan noship $ */
	-- Declare the conversion functions the PL/SQL type DPP_CLAIMS_PVT.DPP_TXN_HDR_REC_TYPE
	FUNCTION PL_TO_SQL3(aPlsqlItem DPP_CLAIMS_PVT.DPP_TXN_HDR_REC_TYPE)
 	RETURN DPP_CLAIMS_PVT_DPP_TXN_HDR_R1;
	FUNCTION SQL_TO_PL3(aSqlItem DPP_CLAIMS_PVT_DPP_TXN_HDR_R1)
	RETURN DPP_CLAIMS_PVT.DPP_TXN_HDR_REC_TYPE;
	-- Declare the conversion functions the PL/SQL type DPP_CLAIMS_PVT.DPP_TXN_LINE_REC_TYPE
	FUNCTION PL_TO_SQL4(aPlsqlItem DPP_CLAIMS_PVT.DPP_TXN_LINE_REC_TYPE)
 	RETURN DPP_CLAIMS_PVT_DPP_TXN_LINE_3;
	FUNCTION SQL_TO_PL5(aSqlItem DPP_CLAIMS_PVT_DPP_TXN_LINE_3)
	RETURN DPP_CLAIMS_PVT.DPP_TXN_LINE_REC_TYPE;
	-- Declare the conversion functions the PL/SQL type DPP_CLAIMS_PVT.DPP_TXN_LINE_TBL_TYPE
	FUNCTION PL_TO_SQL5(aPlsqlItem DPP_CLAIMS_PVT.DPP_TXN_LINE_TBL_TYPE)
 	RETURN DPP_CLAIMS_PVT_DPP_TXN_LINE_2;
	FUNCTION SQL_TO_PL4(aSqlItem DPP_CLAIMS_PVT_DPP_TXN_LINE_2)
	RETURN DPP_CLAIMS_PVT.DPP_TXN_LINE_TBL_TYPE;
   PROCEDURE DPP_CLAIMS_PVT$CREATE_CLAIMS (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,
   P_VALIDATION_LEVEL NUMBER,X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,X_MSG_DATA OUT NOCOPY VARCHAR2,
   P_TXN_HDR_REC DPP_CLAIMS_PVT_DPP_TXN_HDR_R1,P_TXN_LINE_TBL DPP_CLAIMS_PVT_DPP_TXN_LINE_2);
END DPP_BPEL_CREATECLAIMS;

/
