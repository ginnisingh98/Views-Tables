--------------------------------------------------------
--  DDL for Package BEN_ORG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ORG_OBJECT" AUTHID CURRENT_USER as
/* $Header: benorgch.pkh 120.0.12010000.2 2008/08/05 14:49:06 ubhat ship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      09-Aug-99  GPERRY     Created.
  115.1      16-Aug-99  GPERRY     Added nocopy compiler directive.
  115.2      06 May 00  RChase     Added additional NOCOPY compiler directives
  115.3      12 Dec 01  Tmathers   dos2unix for 2128462.
  -----------------------------------------------------------------------------
*/
--
type g_cache_bus_table is table of per_business_groups%rowtype index
  by binary_integer;
--
type g_cache_org_table is table of hr_all_organization_units%rowtype index
  by binary_integer;
--
type g_cache_pay_table is table of pay_all_payrolls_f%rowtype index
  by binary_integer;
--
type g_cache_ben_table is table of ben_benfts_grp%rowtype index
  by binary_integer;
--
g_cache_bus_rec         g_cache_bus_table;
g_cache_last_bus_rec    per_business_groups%rowtype;
g_cache_org_rec         g_cache_org_table;
g_cache_last_org_rec    hr_all_organization_units%rowtype;
g_cache_pay_rec         g_cache_pay_table;
g_cache_last_pay_rec    pay_all_payrolls_f%rowtype;
g_cache_ben_rec         g_cache_ben_table;
g_cache_last_ben_rec    ben_benfts_grp%rowtype;
--
-- Set object routines
--
procedure set_object
  (p_rec in out NOCOPY per_business_groups%rowtype);
--
procedure set_object
  (p_rec in out NOCOPY hr_all_organization_units%rowtype);
--
procedure set_object
  (p_rec in out NOCOPY pay_all_payrolls_f%rowtype);
--
procedure set_object
  (p_rec in out NOCOPY ben_benfts_grp%rowtype);
--
procedure set_bus_object
  (p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_business_groups%rowtype);
--
procedure set_org_object
  (p_organization_id   in number,
   p_effective_date    in date,
   p_rec               in out nocopy hr_all_organization_units%rowtype);
--
procedure set_pay_object
  (p_payroll_id        in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy pay_all_payrolls_f%rowtype);
--
procedure set_ben_object
  (p_benfts_grp_id     in number,
   p_business_group_id in number,
   p_rec               in out nocopy ben_benfts_grp%rowtype);
--
-- Get object routines
--
procedure get_object
  (p_business_group_id in  number,
   p_rec               in out nocopy per_business_groups%rowtype);
--
procedure get_object
  (p_organization_id in  number,
   p_rec             in out nocopy hr_all_organization_units%rowtype);
--
procedure get_object
  (p_payroll_id      in  number,
   p_rec             in out nocopy pay_all_payrolls_f%rowtype);
--
procedure get_object
  (p_benfts_grp_id   in  number,
   p_rec             in out nocopy ben_benfts_grp%rowtype);
--
procedure clear_down_cache;
--
end ben_org_object;

/
