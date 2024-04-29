--------------------------------------------------------
--  DDL for Package Body MSC_USER_DEFINED_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_USER_DEFINED_PK" AS
/* $Header: MSCPUDPB.pls 120.1 2005/07/06 13:24:00 pabram noship $ */

PROCEDURE msc_user_defined_snapshot_task(
     arg_plan_id         IN NUMBER) IS
        /*---------------------------+
         |  Variable delarations     |
         +---------------------------*/
    dummy_var       NUMBER;
BEGIN
                        /*  dummy initialization */
                        dummy_var :=1 ;
END msc_user_defined_snapshot_task;

END MSC_USER_DEFINED_PK;

/
