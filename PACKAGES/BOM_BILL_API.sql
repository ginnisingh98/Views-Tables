--------------------------------------------------------
--  DDL for Package BOM_BILL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BILL_API" AUTHID CURRENT_USER AS
/* $Header: BOMOIBMS.pls 115.4 2002/06/14 22:12:46 rfarook ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOIBMS.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Bill of Material data in the                  |
|		 BOM_BILL_OF_MATLS_INTERFACE table.			    |
| Parameters:   org_id          organization_id                             |
|               all_org         process all orgs or just current org        |
|                               1 - all orgs                                |
|                               2 - only org_id                             |
|               prog_appid      program application_id                      |
|               prog_id         program id                                  |
|               req_id          request_id                                  |
|               user_id         user id                                     |
|               login_id        login id                                    |
| History:                                                                  |
|    03/10/97   Julie Maeyama   Created this new package		    |
+==========================================================================*/

G_Insert         CONSTANT VARCHAR2(10) := 'CREATE'; -- transaction type
G_Update         CONSTANT VARCHAR2(10) := 'UPDATE'; -- transaction type
G_Delete         CONSTANT VARCHAR2(10) := 'DELETE'; -- transaction type
G_NullChar       CONSTANT VARCHAR2(10) := fnd_global.local_chr(12);  -- null value
G_NullNum        CONSTANT NUMBER       := 9.99E125; -- null value
G_NullDate       CONSTANT DATE         := to_date('1','j'); -- null value
G_DeleteEntity   CONSTANT VARCHAR2(30) := 'BOM_BILL_OF_MTLS_INTERFACE';
G_ProductFamily	 CONSTANT NUMBER       := 5;
G_rows_to_commit CONSTANT NUMBER       := 500;


FUNCTION Import_Bill (
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

END Bom_Bill_Api;

 

/
