--------------------------------------------------------
--  DDL for Package BEN_EXT_WHERE_CLAUSE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_WHERE_CLAUSE_BK2" AUTHID CURRENT_USER as
/* $Header: bexwcapi.pkh 120.1 2005/10/11 06:34:58 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ext_where_clause_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ext_where_clause_b
  (
   p_ext_where_clause_id            in  number
  ,p_seq_num                        in  number
  ,p_oper_cd                        in  varchar2
  ,p_val                            in  varchar2
  ,p_and_or_cd                      in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_cond_ext_data_elmt_id          in  number
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ext_where_clause_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ext_where_clause_a
  (
   p_ext_where_clause_id            in  number
  ,p_seq_num                        in  number
  ,p_oper_cd                        in  varchar2
  ,p_val                            in  varchar2
  ,p_and_or_cd                      in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_cond_ext_data_elmt_id          in  number
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_cond_ext_data_elmt_in_rcd_id   in  number
  ,p_effective_date                 in  date
  );
--
end ben_ext_where_clause_bk2;

 

/
