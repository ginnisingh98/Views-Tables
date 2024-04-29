--------------------------------------------------------
--  DDL for Package BEN_XRF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRF_RKI" AUTHID CURRENT_USER as
/* $Header: bexrfrhi.pkh 120.2 2005/06/21 18:31:55 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ext_rcd_in_file_id             in number
 ,p_seq_num                        in number
 ,p_sprs_cd                        in varchar2
 ,p_sort1_data_elmt_in_rcd_id      in number
 ,p_sort2_data_elmt_in_rcd_id      in number
 ,p_sort3_data_elmt_in_rcd_id      in number
 ,p_sort4_data_elmt_in_rcd_id      in number
 ,p_ext_rcd_id                     in number
 ,p_ext_file_id                    in number
 ,p_business_group_id              in number
 ,p_legislation_code		   in varchar2
 ,p_object_version_number          in number
 ,p_any_or_all_cd                  in varchar2
 ,p_hide_flag                      in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_chg_rcd_upd_flag               in varchar2
 ,p_effective_date                 in date
  );
end ben_xrf_rki;

 

/
