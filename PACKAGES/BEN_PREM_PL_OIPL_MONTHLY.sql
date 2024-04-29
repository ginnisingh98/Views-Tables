--------------------------------------------------------
--  DDL for Package BEN_PREM_PL_OIPL_MONTHLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREM_PL_OIPL_MONTHLY" AUTHID CURRENT_USER as
/* $Header: benprplo.pkh 115.6 2003/01/01 00:00:48 mmudigon ship $ */
--
type g_person_rec is record
 (person_id                  number
 ,pgm_id                     number
 ,bnft_amt                   number);

type g_person_table is table of g_person_rec
  index by binary_integer;

  g_rec         ben_type.g_report_rec ;
-- ----------------------------------------------------------------------------
-- |---------------------< get_comp_object_info >-----------------------------|
-- ----------------------------------------------------------------------------
-- This procedure is called from main and from ben_premium_plan_concurrent
-- to get premium comp object ids.
procedure get_comp_object_info
             (p_oipl_id       in number default null
             ,p_pl_id         in number default null
             ,p_pgm_id        in number default null
             ,p_effective_date in date
             ,p_out_pgm_id    out nocopy number
             ,p_out_pl_typ_id out nocopy number
             ,p_out_pl_id     out nocopy number
             ,p_out_opt_id    out nocopy number);

-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all the 'PROC' type premiums for
-- the month.
procedure main
  (p_validate                 in varchar2 default 'N',
   p_actl_prem_id             in number,
   p_business_group_id        in number,
   p_mo_num                   in number,
   p_yr_num                   in number,
   p_first_day_of_month       in date,
   p_effective_date           in date)  ;
--   p_pl_typ_id                in number,
--   p_pl_id                    in number,
--   p_opt_id                   in number
end ben_prem_pl_oipl_monthly;

 

/
