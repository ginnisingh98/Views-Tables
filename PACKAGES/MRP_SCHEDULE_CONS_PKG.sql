--------------------------------------------------------
--  DDL for Package MRP_SCHEDULE_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCHEDULE_CONS_PKG" AUTHID CURRENT_USER AS
/* $Header: MRSCONSS.pls 115.0 99/07/16 12:44:28 porting ship $ */

PROCEDURE Get_PO( X_disposition_id 		NUMBER,
                  X_disposition    	IN OUT  VARCHAR2);

PROCEDURE Get_POReq( X_disposition_id 		NUMBER,
                     X_disposition    	IN OUT  VARCHAR2);

PROCEDURE Get_Ship( X_disposition_id 		NUMBER,
                    X_disposition    	IN OUT  VARCHAR2);

FUNCTION Get_WIP( X_organization_id 		NUMBER,
                  X_disposition_id 		NUMBER,
                  X_disposition    	IN OUT  VARCHAR2) RETURN NUMBER;

END MRP_SCHEDULE_CONS_PKG;

 

/
