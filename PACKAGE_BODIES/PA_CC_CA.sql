--------------------------------------------------------
--  DDL for Package Body PA_CC_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_CA" AS
/* $Header: PAICPCAB.pls 120.3 2005/08/19 16:34:34 mwasowic noship $ */
  PROCEDURE identify_ca_project
      (  p_project_id               IN    NUMBER,
         x_cost_accrual_flag       OUT   NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS

--   l_cost_accrual_flag         Varchar2(1);
--   l_funding_flag              Varchar2(1);
--   l_ca_event_type             Varchar2(30);
--   l_ca_contra_event_type      Varchar2(30);
--   l_ca_wip_event_type         Varchar2(30);
--   l_ca_budget_type            Varchar2(30);

  BEGIN

    x_cost_accrual_flag := 'N';

--    pa_rev_ca.Check_if_Cost_Accrual
--                      ( p_project_id               => p_project_id,
--                        x_cost_accrual_flag        => l_cost_accrual_flag,
--                        x_funding_flag             => l_funding_flag,
--                        x_ca_event_type            => l_ca_event_type,
--                        x_ca_contra_event_type     => l_ca_contra_event_type,
--                        x_ca_wip_event_type        => l_ca_wip_event_type,
--                        x_ca_budget_type           => l_ca_budget_type );

--   x_cost_accrual_flag := l_cost_accrual_flag;

  END identify_ca_project;

END pa_cc_ca;

/
