--------------------------------------------------------
--  DDL for Package EDW_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SEC_PKG" AUTHID CURRENT_USER as
/* $Header: EDWSPKGS.pls 115.4 2002/12/06 02:51:07 tiwang ship $*/

ses_resp_id     number;
procedure set_context;
procedure set_default_context;
procedure link_aol_user;
function dim_sec (obj_schema varchar2,obj_name varchar2) return varchar2;
function default_sec (obj_schema varchar2,obj_name varchar2) return varchar2;
END edw_sec_pkg;

 

/
