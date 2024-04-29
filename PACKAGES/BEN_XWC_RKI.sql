--------------------------------------------------------
--  DDL for Package BEN_XWC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XWC_RKI" AUTHID CURRENT_USER as
/* $Header: bexwcrhi.pkh 120.0 2005/05/28 12:43:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end ben_xwc_rki;

 

/
