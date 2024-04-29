--------------------------------------------------------
--  DDL for Package Body MRP_SCHEDULE_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCHEDULE_CONS_PKG" AS
/* $Header: MRSCONSB.pls 115.0 99/07/16 12:44:24 porting ship $ */


PROCEDURE Get_PO( X_disposition_id 		NUMBER,
                  X_disposition    	IN OUT  VARCHAR2
) IS

 	disposition VARCHAR2(80);

BEGIN

  SELECT segment1
    INTO disposition
    FROM PO_HEADERS_ALL
   WHERE po_header_id = X_disposition_id;

  X_disposition := disposition;

END Get_PO;


PROCEDURE Get_POReq( X_disposition_id 		NUMBER,
                     X_disposition    	IN OUT  VARCHAR2
) IS

 	disposition VARCHAR2(80);

BEGIN

  SELECT segment1
    INTO disposition
    FROM PO_REQUISITION_HEADERS_ALL
   WHERE requisition_header_id = X_disposition_id;

  X_disposition := disposition;

END Get_POReq;


PROCEDURE Get_Ship( X_disposition_id 		NUMBER,
                    X_disposition    	IN OUT  VARCHAR2
) IS

 	disposition VARCHAR2(80);

BEGIN

  SELECT shipment_num
    INTO disposition
    FROM RCV_SHIPMENT_HEADERS
   WHERE shipment_header_id = X_disposition_id;

  X_disposition := disposition;

END Get_Ship;


FUNCTION Get_WIP( X_organization_id 		NUMBER,
                  X_disposition_id 		NUMBER,
                  X_disposition    	IN OUT  VARCHAR2) RETURN NUMBER IS

 	disposition VARCHAR2(80);

BEGIN

  --
  -- Returns: 1 - normal
  -- 	      2 - no data found
  --

  SELECT wip_entity_name
    INTO disposition
    FROM WIP_ENTITIES
   WHERE wip_entity_id = X_disposition_id
     AND organization_id = X_organization_id;

  X_disposition := disposition;

  RETURN(1);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN(2);

END Get_WIP;


END MRP_SCHEDULE_CONS_PKG;

/
