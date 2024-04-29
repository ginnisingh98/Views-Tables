--------------------------------------------------------
--  DDL for Package BEN_XWC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XWC_RKU" AUTHID CURRENT_USER as
/* $Header: bexwcrhi.pkh 120.0 2005/05/28 12:43:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_where_clause_id            in number
 ,p_seq_num                        in number
 ,p_oper_cd                        in varchar2
 ,p_val                            in varchar2
 ,p_and_or_cd                      in varchar2
 ,p_ext_data_elmt_id               in number
 ,p_cond_ext_data_elmt_id          in number
 ,p_ext_rcd_in_file_id             in number
 ,p_ext_data_elmt_in_rcd_id        in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_object_version_number          in number
 ,p_cond_ext_data_elmt_in_rcd_id   in number
 ,p_effective_date                 in date
 ,p_seq_num_o                      in number
 ,p_oper_cd_o                      in varchar2
 ,p_val_o                          in varchar2
 ,p_and_or_cd_o                    in varchar2
 ,p_ext_data_elmt_id_o             in number
 ,p_cond_ext_data_elmt_id_o        in number
 ,p_ext_rcd_in_file_id_o           in number
 ,p_ext_data_elmt_in_rcd_id_o      in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_object_version_number_o        in number
 ,p_cond_ext_data_elmt_in_rcd__o in number
  );
--
end ben_xwc_rku;

 

/