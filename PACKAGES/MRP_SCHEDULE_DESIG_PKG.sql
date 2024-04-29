--------------------------------------------------------
--  DDL for Package MRP_SCHEDULE_DESIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SCHEDULE_DESIG_PKG" AUTHID CURRENT_USER AS
/* $Header: MRSDESIS.pls 115.0 99/07/16 12:44:46 porting ship $ */


PROCEDURE Check_Unique(X_organization_id NUMBER,
		       X_schedule_designator VARCHAR2);

PROCEDURE Update_Plans(X_organization_id NUMBER,
		       X_schedule_designator VARCHAR2);

FUNCTION Check_References(
    X_organization_id NUMBER,
    X_schedule_designator VARCHAR2) RETURN BOOLEAN;

FUNCTION Plans_Exist(
    X_organization_id NUMBER,
    X_schedule_designator VARCHAR2) RETURN BOOLEAN;

END MRP_SCHEDULE_DESIG_PKG;

 

/
