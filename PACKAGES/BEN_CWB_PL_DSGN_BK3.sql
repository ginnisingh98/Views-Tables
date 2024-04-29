--------------------------------------------------------
--  DDL for Package BEN_CWB_PL_DSGN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PL_DSGN_BK3" AUTHID CURRENT_USER as
/* $Header: becpdapi.pkh 120.3.12010000.4 2010/03/12 06:07:31 sgnanama ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_plan_or_option_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_or_option_b
  (p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_lf_evt_ocrd_dt               in     date
  ,p_object_version_number        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_plan_or_option_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_or_option_a
  (p_pl_id                        in     number
  ,p_oipl_id                      in     number
  ,p_lf_evt_ocrd_dt               in     date
  ,p_object_version_number        in     number
  );
--
end BEN_CWB_PL_DSGN_BK3;

/
