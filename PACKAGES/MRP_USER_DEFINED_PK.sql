--------------------------------------------------------
--  DDL for Package MRP_USER_DEFINED_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_USER_DEFINED_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPUDPS.pls 115.0 99/07/16 12:35:11 porting ship $ */
PROCEDURE MRP_USER_DEFINED_SNAPSHOT_TASK(
                                arg_organization_id         IN NUMBER,
                                arg_compile_designator      IN VARCHAR2);
END MRP_USER_DEFINED_PK;

 

/
