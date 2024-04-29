--------------------------------------------------------
--  DDL for Package BEN_CWB_XCHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_XCHG_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbxchg.pkh 120.2 2006/03/15 10:47 ddeb noship $ */
-- --------------------------------------------------------------------------
-- |--------------------< insert_into_ben_cwb_xchg >------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure contains calls for inserting records into xchg table once
-- benmingle has run, and also to upsert on refresh. If no value is passed for
-- effective_date, then lf_evt_ocrd_dt will be considered as the effective_date.
--
procedure insert_into_ben_cwb_xchg(p_group_pl_id    IN number,
                                   p_lf_evt_ocrd_dt IN date,
				   p_effective_date IN date,
				   p_refresh_always IN varchar2 default 'N',
                                   p_currency IN varchar2 default null,
                                   p_xchg_rate IN number default null);
-- --------------------------------------------------------------------------
-- |--------------------< refresh_xchg_rates >------------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure will refresh the exchange rates in ben_cwb_xchg table on
-- a given effective date, and, return p_all_xchg_rt_exists as 'N' for any
-- rates found to be null.
-- Input parameters
--  p_group_pl_id    : Group Plan Id
--  p_lf_evt_ocrd_dt : Life Event Occured Date
--  p_effective_date : Effective Date
--  p_refresh_always : Refresh Always flag
--  p_all_xchg_rt_exists : All Exchange Rates Exists
--
procedure refresh_xchg_rates(p_group_pl_id    IN number,
                                   p_lf_evt_ocrd_dt IN date,
				   p_effective_date IN date,
				   p_refresh_always IN varchar2 default 'N',
                                   p_all_xchg_rt_exists IN OUT NOCOPY varchar2);

end BEN_CWB_XCHG_PKG;


 

/
