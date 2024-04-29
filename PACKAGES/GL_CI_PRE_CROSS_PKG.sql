--------------------------------------------------------
--  DDL for Package GL_CI_PRE_CROSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CI_PRE_CROSS_PKG" AUTHID CURRENT_USER as
/* $Header: gluciprs.pls 120.5 2005/12/08 10:31:45 mikeward noship $ */
--+ a place to keep COA attributes

function Get_Source_Group_ID(
  cons_id                 IN number,
  cons_run_id             IN number) return number;
procedure pre_run_CI_transfer(
   errbuf                 in out NOCOPY varchar2,
   retcode                in out NOCOPY varchar2,
   p_resp_name            IN varchar2,
   p_cons_request_id      IN number,
   consolidation_id       IN number,
   run_id                 IN number,
   to_period_token        IN varchar2,
   to_sob_id              IN number,
   p_user_name            IN varchar2,
   p_dblink               IN varchar2,
   from_group_id          IN number,
   from_sob_id            IN number,
   p_pd_name              IN varchar2,
   p_budget_name          IN varchar2,
   p_j_import             IN VARCHAR2,
   p_j_post               IN varchar2,
   p_actual_flag          IN varchar2,
   p_request_id           IN number,
   p_csj_flag             IN varchar2,
   p_debug                IN varchar2);

end GL_CI_PRE_CROSS_PKG;

 

/
