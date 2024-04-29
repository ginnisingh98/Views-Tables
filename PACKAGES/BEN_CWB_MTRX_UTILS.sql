--------------------------------------------------------
--  DDL for Package BEN_CWB_MTRX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_MTRX_UTILS" AUTHID CURRENT_USER as
/* $Header: bencwbmtrxutils.pkh 120.0 2005/05/28 13:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< POP_TRG_AMTS >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This procedure is used to populate the target values for all employees
-- under a manager depending upon the criterion values entered in
-- Matrix through Budget Allocation Wizard in Compensation Workbench.
--
-- In Parameters:
--   Name                   Reqd   Type         Description
--   p_validate              No   boolean  If true, the database remains
--                                         unchanged. If false then the
--                                         person will be updated.
--   p_acting_mgr_pil_id     Yes  number   Acting Manager's GroupPerInLerId
--   p_mgr_pil_ids           Yes  varchar  List of Managers GroupPerInLerId
--                                         whose employees records needs to
--                                         be updated using the crit values
--   p_lvl_num               Yes  number   Level Number used to get the
--                                         population for a Manager
--   p_grp_pl_id             Yes  number   Group Plan Id
--   p_grp_oipl_id           Yes  number   Group Option Id
--   p_name_type             No   varchar  Display Employee Name Type
--   p_crit_cd1              Yes  varchar  First Criterion selected by
--                                         the user
--   p_crit_cd2              No   varchar  Second Criterion
--   p_crit_vals1            Yes  varchar  Values for First Criterion
--   p_crit_vals2            No   varchar  Values for Second Criterion
--   p_alct_by               No   varchar  Used for Populating Recommended
--                                         values either using % of EligSal
--                                         or Per Employee Amount
--   p_trg_val               Yes  varchar  Value either in Pct of Elig Sal
--                                         or in Per Emp Amt for the Crit Vals
--                                         depending on the p_alct_by field
--
-- Post Failure:
--  None
--
-- Access Status:
--  Public
--
-- {End Of Comments}
--
procedure pop_trg_amts
  (p_validate                      in     boolean
  ,p_acting_mgr_pil_id             in     number
  ,p_mgr_pil_ids                   in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_lvl_num                       in     number
  ,p_grp_pl_id                     in     number
  ,p_grp_oipl_id                   in     number
  ,p_name_type                     in     varchar2
  ,p_crit_cd1                      in     varchar2
  ,p_crit_cd2                      in     varchar2
  ,p_crit_vals1                    in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_crit_vals2                    in     BEN_CWB_ACCESS_STRING_ARRAY
  ,p_alct_by                       in     varchar2
  ,p_trg_val                       in     BEN_CWB_ACCESS_STRING_ARRAY
  );
--
end ben_cwb_mtrx_utils;

 

/
