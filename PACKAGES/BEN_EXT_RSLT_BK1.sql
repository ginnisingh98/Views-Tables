--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_BK1" AUTHID CURRENT_USER as
/* $Header: bexrsapi.pkh 120.1 2005/06/08 14:27:02 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_RSLT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RSLT_b
  (
   p_run_strt_dt                    in  date
  ,p_run_end_dt                     in  date
  ,p_ext_stat_cd                    in  varchar2
  ,p_tot_rec_num                    in  number
  ,p_tot_per_num                    in  number
  ,p_tot_err_num                    in  number
  ,p_eff_dt                         in  date
  ,p_ext_strt_dt                    in  date
  ,p_ext_end_dt                     in  date
  ,p_output_name                    in  varchar2
  ,p_drctry_name                    in  varchar2
  ,p_ext_dfn_id                     in  number
  ,p_business_group_id              in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_request_id                     in  number
  ,p_output_type                    in  varchar2
  ,p_xdo_template_id                in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_RSLT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RSLT_a
  (
   p_ext_rslt_id                    in  number
  ,p_run_strt_dt                    in  date
  ,p_run_end_dt                     in  date
  ,p_ext_stat_cd                    in  varchar2
  ,p_tot_rec_num                    in  number
  ,p_tot_per_num                    in  number
  ,p_tot_err_num                    in  number
  ,p_eff_dt                         in  date
  ,p_ext_strt_dt                    in  date
  ,p_ext_end_dt                     in  date
  ,p_output_name                    in  varchar2
  ,p_drctry_name                    in  varchar2
  ,p_ext_dfn_id                     in  number
  ,p_business_group_id              in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_request_id                     in  number
  ,p_output_type                    in  varchar2
  ,p_xdo_template_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RSLT_bk1;

 

/
