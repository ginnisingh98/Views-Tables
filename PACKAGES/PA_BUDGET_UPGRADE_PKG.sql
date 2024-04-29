--------------------------------------------------------
--  DDL for Package PA_BUDGET_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_UPGRADE_PKG" AUTHID CURRENT_USER as
--  $Header: PAXBUUPS.pls 120.1 2005/08/19 17:10:57 mwasowic noship $

  type id_name is record (
      resource_list_id    number,
      resource_list_name varchar2(240) );
  type id_name_tbl is table of id_name
    index by binary_integer;


  V3BTypeTab    pa_utils.Char30TabTyp;
  BudTypeTab    pa_utils.Char30TabTyp;
  VerNumTab     pa_utils.IdTabTyp;
  BudStTab      pa_utils.Char30TabTyp;
  CurFlagTab    pa_utils.Char1TabTyp;
  OrigFlagTab   pa_utils.Char1TabTyp;
  CurOrigTab    pa_utils.Char1TabTyp;
  BaseByTab     pa_utils.IdTabTyp;
  BaseDateTab   pa_utils.DateTabTyp;
  CreateByTab   pa_utils.IdTabTyp;
  CreateDateTab pa_utils.DateTabTyp;
  LastUpdatedByTab   pa_utils.IdTabTyp;
  LastUpdatedDateTab    pa_utils.DateTabTyp;
  LastUpdatedLoginTab   pa_utils.IdTabTyp;

  g_uncat_rec    pa_resource_list_members%ROWTYPE;
  g_cat_rec      id_name_tbl;
  g_uncla_rec    pa_resources%ROWTYPE;
  g_project_id   number;
  g_budget_type_code  varchar2(30);
  g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
  g_last_update_date        DATE       := trunc(sysdate);
  g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;


--  Derive Project_id
 FUNCTION Get_Project_id RETURN NUMBER;
 pragma RESTRICT_REFERENCES  ( Get_Project_id, WNDS, WNPS );

--  Derive Budget_type_code
 FUNCTION Get_Budget_Type_Code RETURN VARCHAR2;
 pragma RESTRICT_REFERENCES  ( Get_Budget_Type_Code, WNDS, WNPS );

 Procedure Initialize (x_err_code  in out NOCOPY number, --File.Sql.39 bug 4440895
                       x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                       x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

 Procedure Create_Setup_data(x_err_code  in out NOCOPY number, --File.Sql.39 bug 4440895
                    x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                    x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

 Procedure Main(x_min_project_id in number,
                x_max_project_id in number,
                x_err_code  in out NOCOPY number, --File.Sql.39 bug 4440895
                x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

END PA_BUDGET_UPGRADE_PKG ;

 

/
