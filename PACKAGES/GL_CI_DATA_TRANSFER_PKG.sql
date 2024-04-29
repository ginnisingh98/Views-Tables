--------------------------------------------------------
--  DDL for Package GL_CI_DATA_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CI_DATA_TRANSFER_PKG" AUTHID CURRENT_USER as
/* $Header: glucitrs.pls 120.8.12010000.2 2010/03/12 09:39:32 sommukhe ship $ */

procedure Get_Domain_Name(
  l_dblink                IN varchar2);
procedure Get_Schema_Name(
  l_dblink                IN varchar2);
--+ a place to keep COA attributes
function Get_Source_Group_ID(
  cons_id                 IN number,
  cons_run_id             IN number) return number;
function Get_Ledger_ID(
  user_id                 IN number,
  resp_id                 IN number,
  app_id                  IN number,
  dblink                  IN varchar2,
  access_set_id           OUT NOCOPY number,
  access_set              OUT NOCOPY varchar2,
  access_code             OUT NOCOPY varchar2,
  l_to_ledger_name        IN VARCHAR2) return number;
function Get_Budget_Version_ID(
  user_id                 IN number,
  resp_id                 IN number,
  app_id                  IN number,
  dblink                  IN varchar2,
  budget_name             IN varchar2) return number;
FUNCTION Remote_Data_Validation(
  dblink                  IN varchar2,
  p_resp_name             IN varchar2,
  p_pd_name               IN varchar2,
  p_ledger                IN number,
  p_j_import              IN varchar2,
  p_j_post                IN varchar2) RETURN varchar2;
procedure Remote_Data_Map(
  p_name                  IN varchar2,
  p_resp_name             IN OUT NOCOPY varchar2,
  p_user_name             IN OUT NOCOPY varchar2,
  p_db_name               IN OUT NOCOPY varchar2);
procedure Remote_Data_Map_Set(
  p_name                  IN varchar2,
  p_resp_name             IN OUT NOCOPY varchar2,
  p_user_name             IN OUT NOCOPY varchar2,
  p_db_name               IN OUT NOCOPY varchar2);
function Remote_Data_transfer(
  actual_flag             IN varchar2,
  user_id                 IN number,
  resp_id                 IN number,
  app_id                  IN number,
  dblink                  IN varchar2,
  source_ledger_id        IN number,
  pd_name                 IN varchar2,
  budget_name             IN varchar2,
  group_id                IN number,
  request_id              IN number,
  p_dblink                IN varchar2,
  p_target_ledger_id      IN number,
  avg_flag                IN OUT NOCOPY varchar2,
  balanced_flag           IN OUT NOCOPY varchar2,
  errbuf                  IN OUT NOCOPY varchar2
) return number;
procedure run_CI_transfer(
   errbuf                 in out NOCOPY varchar2,
   retcode                in out NOCOPY varchar2,
   p_resp_name            IN varchar2,
   p_user_name            IN varchar2,
   p_dblink               IN varchar2,
   from_group_id          IN number,
   from_ledger_id         IN number,
   p_pd_name              IN varchar2,
   p_budget_name          IN varchar2,
   p_j_import             IN VARCHAR2,
   p_j_post               IN varchar2,
   p_actual_flag          IN varchar2,
   p_request_id           IN number,
   p_csj_flag             IN VARCHAR2,
   p_debug                IN varchar2);

   procedure initialize_over_dblink(
    user_id           IN NUMBER,
    resp_id           IN NUMBER,
    app_id            IN NUMBER,
    v_temp_db         IN VARCHAR2);
end GL_CI_DATA_TRANSFER_PKG;

/
