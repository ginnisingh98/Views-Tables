--------------------------------------------------------
--  DDL for Package BEN_XRS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRS_RKU" AUTHID CURRENT_USER as
/* $Header: bexrsrhi.pkh 120.1 2005/06/08 14:22:14 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_rslt_id                    in number
 ,p_run_strt_dt                    in date
 ,p_run_end_dt                     in date
 ,p_ext_stat_cd                    in varchar2
 ,p_tot_rec_num                    in number
 ,p_tot_per_num                    in number
 ,p_tot_err_num                    in number
 ,p_eff_dt                         in date
 ,p_ext_strt_dt                    in date
 ,p_ext_end_dt                     in date
 ,p_output_name                    in varchar2
 ,p_drctry_name                    in varchar2
 ,p_ext_dfn_id                     in number
 ,p_business_group_id              in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_request_id                     in number
 ,p_output_type                    in varchar2
 ,p_xdo_template_id                in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_run_strt_dt_o                  in date
 ,p_run_end_dt_o                   in date
 ,p_ext_stat_cd_o                  in varchar2
 ,p_tot_rec_num_o                  in number
 ,p_tot_per_num_o                  in number
 ,p_tot_err_num_o                  in number
 ,p_eff_dt_o                       in date
 ,p_ext_strt_dt_o                  in date
 ,p_ext_end_dt_o                   in date
 ,p_output_name_o                  in varchar2
 ,p_drctry_name_o                  in varchar2
 ,p_ext_dfn_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_request_id_o                   in number
 ,p_output_type_o                  in varchar2
 ,p_xdo_template_id_o              in number
 ,p_object_version_number_o        in number
  );
--
end ben_xrs_rku;

 

/
