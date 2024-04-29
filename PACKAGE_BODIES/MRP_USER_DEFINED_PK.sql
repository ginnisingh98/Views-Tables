--------------------------------------------------------
--  DDL for Package Body MRP_USER_DEFINED_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_USER_DEFINED_PK" AS
/* $Header: MRPPUDPB.pls 115.0 99/07/16 12:35:06 porting ship $ */

PROCEDURE mrp_user_defined_snapshot_task(
     arg_organization_id         IN NUMBER,
     arg_compile_designator      IN VARCHAR2) IS
        /*---------------------------+
         |  Variable delarations     |
         +---------------------------*/
    dummy_var       NUMBER;
BEGIN
                        /*  dummy initialization */
                        dummy_var :=1 ;
END mrp_user_defined_snapshot_task;

END MRP_USER_DEFINED_PK;

/
