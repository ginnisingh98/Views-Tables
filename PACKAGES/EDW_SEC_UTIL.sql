--------------------------------------------------------
--  DDL for Package EDW_SEC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SEC_UTIL" AUTHID CURRENT_USER as
/* $Header: EDWSUTLS.pls 115.5 2002/12/06 02:57:48 tiwang noship $*/
procedure refresh_sec_metadata(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2);
procedure log_error(x_object_name varchar2, x_object_type varchar2, x_resp_id number, x_conc_id number, x_message varchar2);
procedure upgrade_sec_access_data;
END edw_sec_util;

 

/
