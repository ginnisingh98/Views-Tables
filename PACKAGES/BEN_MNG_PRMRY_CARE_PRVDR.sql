--------------------------------------------------------
--  DDL for Package BEN_MNG_PRMRY_CARE_PRVDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MNG_PRMRY_CARE_PRVDR" AUTHID CURRENT_USER as
/* $Header: benmnppr.pkh 120.0.12000000.1 2007/01/19 18:34:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< recycle_ppr >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure inherits primary care providers for the enrollment result
--   from the set of primary care providers previously selected for this plan
--   (in another result id) according to the set of rules.
--
-- Prerequisites:
--
-- Post Success:
--
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure recycle_ppr(p_validate                       in boolean default false,
                           p_new_prtt_enrt_rslt_id          in number,
                           p_old_prtt_enrt_rslt_id          in number,
                           p_business_group_id              in number,
                           p_effective_date                 in date,
                           p_datetrack_mode                 in varchar2
                           );

end ben_mng_prmry_care_prvdr;

 

/
