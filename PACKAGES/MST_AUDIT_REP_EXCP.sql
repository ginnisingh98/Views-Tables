--------------------------------------------------------
--  DDL for Package MST_AUDIT_REP_EXCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_AUDIT_REP_EXCP" AUTHID CURRENT_USER AS
/* $Header: MSTEARES.pls 115.10 2004/05/05 21:40:00 jansanch noship $ */

	PROCEDURE MissingLatLongCoordExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE MissingDistanceDataExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE DL_with_zero_values (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE DimensionViolForPieceExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE WgtVolViolForPieceExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE WgtVolViolForDLExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE WgtVolViolForFirmDelivExcptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE InsufficientIntransitTimeExptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE PastDueOrdersExptn (plan_idIn NUMBER, userIdIn NUMBER);

	PROCEDURE FacCalViolForPickUpExptn (plan_idIn NUMBER, userIdIn NUMBER);
	PROCEDURE FacCalViolForDeliveryExptn (plan_idIn NUMBER, userIdIn NUMBER);

	PROCEDURE runAuditReport(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER, plan_idIn IN NUMBER, snapshotIsCaller IN NUMBER DEFAULT 2);
	FUNCTION getExceptionThreshold (exceptionType NUMBER, userIdIn NUMBER) RETURN NUMBER;
  PROCEDURE initializeGlobalVariables(plan_idIn IN NUMBER, user_idIn IN NUMBER);

	PROCEDURE testConv (source varchar2, dest varchar2);
	PROCEDURE GET_UOM_CONVERSION_RATES(p_uom_code IN VARCHAR2,p_dest_uom_code IN VARCHAR2,p_inventory_item_id IN NUMBER DEFAULT 0,p_conv_found OUT NOCOPY BOOLEAN,p_conv_rate OUT NOCOPY NUMBER);
	FUNCTION GET_MINIMUM_TRANSIT_TIME(ship_from NUMBER, ship_to NUMBER, plan_idIn NUMBER) RETURN NUMBER;
	FUNCTION CONV_TO_UOM(src_value NUMBER, src_uom_code VARCHAR2, dest_uom_code VARCHAR2, inventory_item_id NUMBER DEFAULT 0) RETURN NUMBER;


	PROCEDURE debug_output(p_str in varchar2);
END MST_AUDIT_REP_EXCP;

 

/
