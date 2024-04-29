--------------------------------------------------------
--  DDL for Package DPP_BPEL_GETOUTBOUNDPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_BPEL_GETOUTBOUNDPL" AUTHID CURRENT_USER AS
/* $Header: dppvbons.pls 120.1 2007/12/12 06:00:57 sdasan noship $ */
	-- Declare the conversion functions the PL/SQL type DPP_PRICING_PVT.DPP_PL_NOTIFY_REC_TYPE
	FUNCTION PL_TO_SQL7(aPlsqlItem DPP_PRICING_PVT.DPP_PL_NOTIFY_REC_TYPE)
 	RETURN DPP_PRICING_PVT_DPP_PL_NOTIF6;
	FUNCTION SQL_TO_PL7(aSqlItem DPP_PRICING_PVT_DPP_PL_NOTIF6)
	RETURN DPP_PRICING_PVT.DPP_PL_NOTIFY_REC_TYPE;
	-- Declare the conversion functions the PL/SQL type DPP_PRICING_PVT.DPP_OBJECT_NAME_TBL_TYPE
	FUNCTION PL_TO_SQL9(aPlsqlItem DPP_PRICING_PVT.DPP_OBJECT_NAME_TBL_TYPE)
 	RETURN DPPPRICINGPVTDPPPLNOTIF8_DPP_;
	FUNCTION SQL_TO_PL9(aSqlItem DPPPRICINGPVTDPPPLNOTIF8_DPP_)
	RETURN DPP_PRICING_PVT.DPP_OBJECT_NAME_TBL_TYPE;
	-- Declare the conversion functions the PL/SQL type DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_REC_TYPE
	FUNCTION PL_TO_SQL10(aPlsqlItem DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_REC_TYPE)
 	RETURN DPP_PRICING_PVT_DPP_PL_NOTIF8;
	FUNCTION SQL_TO_PL10(aSqlItem DPP_PRICING_PVT_DPP_PL_NOTIF8)
	RETURN DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_REC_TYPE;
	-- Declare the conversion functions the PL/SQL type DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_TBL_TYPE
	FUNCTION PL_TO_SQL8(aPlsqlItem DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_TBL_TYPE)
 	RETURN DPP_PRICING_PVT_DPP_PL_NOTIF7;
	FUNCTION SQL_TO_PL8(aSqlItem DPP_PRICING_PVT_DPP_PL_NOTIF7)
	RETURN DPP_PRICING_PVT.DPP_PL_NOTIFY_LINE_TBL_TYPE;
   PROCEDURE DPP_PRICING_PVT$NOTIFY_OUTBOU (P_API_VERSION NUMBER,P_INIT_MSG_LIST VARCHAR2,P_COMMIT VARCHAR2,P_VALIDATION_LEVEL NUMBER,
   X_RETURN_STATUS OUT NOCOPY VARCHAR2,X_MSG_COUNT OUT NOCOPY NUMBER,X_MSG_DATA OUT NOCOPY VARCHAR2,
   P_PL_NOTIFY_HDR_REC IN OUT NOCOPY DPP_PRICING_PVT_DPP_PL_NOTIF6,P_PL_NOTIFY_LINE_TBL IN OUT NOCOPY DPP_PRICING_PVT_DPP_PL_NOTIF7);
END DPP_BPEL_GETOUTBOUNDPL;

/