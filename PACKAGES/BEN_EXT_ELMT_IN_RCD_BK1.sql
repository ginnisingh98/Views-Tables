--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_IN_RCD_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_IN_RCD_BK1" AUTHID CURRENT_USER as
/* $Header: bexerapi.pkh 120.0 2005/05/28 12:32:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_ELMT_IN_RCD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_ELMT_IN_RCD_b
  (
   p_seq_num                        in  number
  ,p_strt_pos                       in  number
  ,p_dlmtr_val                      in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_sprs_cd                        in  varchar2
  ,p_any_or_all_cd                  in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_ext_rcd_id                     in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_hide_flag                      in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_ELMT_IN_RCD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_ELMT_IN_RCD_a
  (
   p_ext_data_elmt_in_rcd_id        in  number
  ,p_seq_num                        in  number
  ,p_strt_pos                       in  number
  ,p_dlmtr_val                      in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_sprs_cd                        in  varchar2
  ,p_any_or_all_cd                  in  varchar2
  ,p_ext_data_elmt_id               in  number
  ,p_ext_rcd_id                     in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_hide_flag                      in  varchar2
  ,p_effective_date                 in  date
  );
--
end ben_EXT_ELMT_IN_RCD_bk1;

 

/
