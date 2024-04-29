--------------------------------------------------------
--  DDL for Package BEN_XER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XER_RKU" AUTHID CURRENT_USER as
/* $Header: bexerrhi.pkh 120.0 2005/05/28 12:32:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_data_elmt_in_rcd_id        in number
 ,p_seq_num                        in number
 ,p_strt_pos                       in number
 ,p_dlmtr_val                      in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_sprs_cd                        in varchar2
 ,p_any_or_all_cd                  in varchar2
 ,p_ext_data_elmt_id               in number
 ,p_ext_rcd_id                     in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_hide_flag                      in varchar2
 ,p_effective_date                 in date
 ,p_seq_num_o                      in number
 ,p_strt_pos_o                     in number
 ,p_dlmtr_val_o                    in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_sprs_cd_o                      in varchar2
 ,p_any_or_all_cd_o                in varchar2
 ,p_ext_data_elmt_id_o             in number
 ,p_ext_rcd_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
 ,p_hide_flag_o                    in varchar2
  );
--
end ben_xer_rku;

 

/
