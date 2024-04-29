--------------------------------------------------------
--  DDL for Package HR_BIS_ORG_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BIS_ORG_PERF" AUTHID CURRENT_USER AS
/* $Header: hrbisorg.pkh 115.5 2002/04/17 03:43:55 pkm ship     $ */

TYPE OrgPerfTableType is record
  (start_val NUMBER
  ,end_val NUMBER
  ,gains NUMBER
  ,ended NUMBER
  ,transfered_out NUMBER
  ,suspended NUMBER
  ,sep_reason NUMBER
  ,others NUMBER
  ,name VARCHAR2(200));
--
TYPE OrgPerfTable is TABLE of OrgPerfTableType
Index by binary_integer;
--
OrgPerfData OrgPerfTable;
--
function get_start(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_start,WNDS,WNPS);
--
function get_end(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_end,WNDS,WNPS);
--
function get_increase(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_increase,WNDS,WNPS);
--
function get_pct_increase(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_pct_increase,WNDS,WNPS);
--
function get_gains(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_gains,WNDS,WNPS);
--
function get_ended(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_ended,WNDS,WNPS);
--
function get_transfered_out(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_transfered_out,WNDS,WNPS);
--
function get_suspended(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_suspended,WNDS,WNPS);
--
function get_sep_reason(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_sep_reason,WNDS,WNPS);
--
function get_others(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_others,WNDS,WNPS);
--
function get_sep_pct_increase(p_organization_id NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_sep_pct_increase,WNDS,WNPS);
--
procedure populate_manpower_table
  ( p_org_param_id      IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_business_group_id IN     NUMBER
  , p_top_org           IN     NUMBER
  , p_start_date        IN     DATE
  , p_end_date          IN     DATE);
--
procedure populate_separations_table
  ( p_org_param_id      IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_business_group_id IN     NUMBER
  , p_top_org           IN     NUMBER
  , p_start_date        IN     DATE
  , p_end_date          IN     DATE
  , p_leaving_reason    IN     VARCHAR2);
--
procedure populate_budget_table
  ( p_budget_id         IN     NUMBER
  , p_business_group_id IN     NUMBER
  , p_report_date       IN     DATE);
--

-- cbridge, 28/06/2001 added for pqh budget reports
procedure populate_pqh_budget_table
  ( p_budget_id         IN     NUMBER
  , p_business_group_id IN     NUMBER
  , p_budget_metric     IN     VARCHAR2
  , p_budget_unit       IN     NUMBER
  , p_report_date       IN     DATE);
--




END HR_BIS_ORG_PERF;

 

/
