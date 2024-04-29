--------------------------------------------------------
--  DDL for Package BEN_CWB_PL_DSGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PL_DSGN_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbpl.pkh 120.0 2005/05/28 04:00:19 appldev noship $ */
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_actual_flag >---------------------------|
-- --------------------------------------------------------------------------
--
-- This function checks whether the given plan is an actual plan or part of
-- a group plan.
--
function get_actual_flag(p_pl_id number
                        ,p_group_pl_id number
			,p_effective_date date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |----------------------------< get_exchg_rate >---------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure computes the exchange reate between the from_currency and
-- to_currency by calling hr_currency_pkg. If no exchange rate information is
-- found, '1' will returned.
function get_exchg_rate(p_from_currency     varchar2
                       ,p_to_currency       varchar2
		       ,p_effective_date    date
		       ,p_business_group_id number)
return number;
--
-- --------------------------------------------------------------------------
-- |--------------------------< refresh_pl_dsgn >----------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure refreshes the ben_cwb_pl_dsgn table.
-- Input parameters
--  p_group_pl_id    : Group Plan Id
--  p_lf_evt_ocrd_dt : Life Event Occured Date
--  p_effective_date : Effective date. This will be used while fetching the
--  data from date tracked tables, if the data_freeze_date in ben_enrt_perd
--  is null.
--
procedure refresh_pl_dsgn(p_group_pl_id    in number
                         ,p_lf_evt_ocrd_dt in date
                         ,p_effective_date in date
                         ,p_refresh_always in varchar2 default 'N');

--
-- --------------------------------------------------------------------------
-- |--------------------------< delete_pl_dsgn >----------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure deletes the ben_cwb_pl_dsgn table when no cwb data exists.
-- Input parameters
--  p_group_pl_id    : Group Plan Id
--  p_lf_evt_ocrd_dt : Life Event Occured Date
--
procedure delete_pl_dsgn(p_group_pl_id    in number
                        ,p_lf_evt_ocrd_dt in date);
end BEN_CWB_PL_DSGN_PKG;


 

/
