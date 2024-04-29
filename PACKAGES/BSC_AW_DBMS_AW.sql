--------------------------------------------------------
--  DDL for Package BSC_AW_DBMS_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_DBMS_AW" AUTHID CURRENT_USER AS
/*$Header: BSCAWDBS.pls 120.2 2005/08/15 13:40 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
--procedures-------------------------------------------------------
procedure execute(p_stmt varchar2);
procedure execute_ne(p_stmt varchar2) ;
function interp(p_stmt varchar2) return varchar2;
--procedures-------------------------------------------------------
procedure init_all;
-------------------------------------------------------------------

END BSC_AW_DBMS_AW;

 

/
