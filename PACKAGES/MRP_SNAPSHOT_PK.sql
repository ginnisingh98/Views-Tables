--------------------------------------------------------
--  DDL for Package MRP_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SNAPSHOT_PK" AUTHID CURRENT_USER AS
        /* $Header: MRPPSNPS.pls 115.0 99/07/16 12:34:41 porting ship $ */

    PROCEDURE   complete_task(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_task            NUMBER);
END mrp_snapshot_pk;

 

/
