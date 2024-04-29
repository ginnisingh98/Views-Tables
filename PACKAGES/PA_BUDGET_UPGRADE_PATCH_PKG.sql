--------------------------------------------------------
--  DDL for Package PA_BUDGET_UPGRADE_PATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_UPGRADE_PATCH_PKG" AUTHID CURRENT_USER as
-- $Header: PAXBUUFS.pls 120.1 2005/08/19 17:10:53 mwasowic noship $

  type RLM_typ is table of number
  index by binary_integer;
  g_RLM_tbl                 RLM_typ ;

  Procedure Main (x_err_code  in out NOCOPY number, --File.Sql.39 bug 4440895
	       x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
	       x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  Function get_new_rlmi(x_old_rlmi in number) return number;
  pragma RESTRICT_REFERENCES (get_new_rlmi, WNDS,WNPS) ;

END;

 

/
