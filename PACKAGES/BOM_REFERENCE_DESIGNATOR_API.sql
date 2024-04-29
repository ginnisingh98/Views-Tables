--------------------------------------------------------
--  DDL for Package BOM_REFERENCE_DESIGNATOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_REFERENCE_DESIGNATOR_API" AUTHID CURRENT_USER AS
/* $Header: BOMOIRDS.pls 115.4 2002/06/14 22:13:15 rfarook ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOIRDS.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Reference Designator data in the              |
|		 BOM_REF_DESGS_INTERFACE table.				    |
| Parameters:   org_id          organization_id                             |
|               all_org         process all orgs or just current org        |
|                               1 - all orgs                                |
|                               2 - only org_id                             |
|               user_id         user id                                     |
|               login_id        login id                                    |
|               prog_appid      program application_id                      |
|               prog_id         program id                                  |
|               req_id      	request_id                                  |
|		del_rec_flag	1 - Delete records w/ process_flag =7	    |
|				2 - Do no delete these records		    |
| History:                                                                  |
|    03/06/97   Julie Maeyama   Created this new package		    |
+==========================================================================*/

G_Insert         CONSTANT VARCHAR2(10) := 'CREATE'; -- transaction type
G_Update         CONSTANT VARCHAR2(10) := 'UPDATE'; -- transaction type
G_Delete         CONSTANT VARCHAR2(10) := 'DELETE'; -- transaction type
G_NullChar       CONSTANT VARCHAR2(10) := fnd_global.local_chr(12);  -- null value
G_NullNum        CONSTANT NUMBER       := 9.99E125; -- null value
G_NullDate       CONSTANT DATE         := to_date('1','j'); -- null value
G_rows_to_commit CONSTANT  NUMBER      := 500;


FUNCTION Import_Reference_Designator (
    org_id              NUMBER,
    all_org             NUMBER := 1,
    user_id             NUMBER := -1,
    login_id            NUMBER := -1,
    prog_appid          NUMBER := -1,
    prog_id             NUMBER := -1,
    req_id              NUMBER := -1,
    del_rec_flag        NUMBER := 1,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER;

END Bom_Reference_Designator_Api;

 

/
