--------------------------------------------------------
--  DDL for Package BEN_PREM_PRTT_CREDITS_MO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREM_PRTT_CREDITS_MO" AUTHID CURRENT_USER as
/* $Header: benprprc.pkh 120.0.12010000.2 2008/08/05 14:49:44 ubhat ship $ */
--
type g_vrbl_prfl_rec is record
(vrbl_rt_prfl_id             number,
 match_cnt                   number,
 val                         number);
--
type g_vrbl_prfl_table is table of g_vrbl_prfl_rec
  index by binary_integer;

g_rec         ben_type.g_report_rec ;

-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all the premiums credits for
-- prior months.
procedure main
  (p_validate                 in varchar2 default 'N',
   p_person_id                in number default null,
   p_pl_id                    in number default null,
   p_person_selection_rule_id in number default null,
   p_comp_selection_rule_id   in number default null,
   p_pgm_id                   in number default null,
   p_pl_typ_id                in number default null,
   p_organization_id          in number default null,
   p_legal_entity_id          in number default null,
   p_business_group_id        in number,
   p_mo_num                   in number,
   p_yr_num                   in number,
   p_first_day_of_month       in date,
   p_effective_date           in date) ;
end ben_prem_prtt_credits_mo;

/
