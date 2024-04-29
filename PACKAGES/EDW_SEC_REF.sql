--------------------------------------------------------
--  DDL for Package EDW_SEC_REF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SEC_REF" AUTHID CURRENT_USER as
/* $Header: EDWSREFS.pls 115.2 2002/12/06 02:55:37 tiwang noship $*/

procedure disable_security(application_short_name varchar2, responsibility_key varchar2,
				fact_physical_name varchar2, fk_column_physical_name varchar2);

procedure enable_security(application_short_name varchar2, responsibility_key varchar2,
                                fact_physical_name varchar2, fk_column_physical_name varchar2);

END edw_sec_ref;

 

/
