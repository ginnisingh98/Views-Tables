--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_DATA_ELMT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_DATA_ELMT_BK2" AUTHID CURRENT_USER as
/* $Header: bexidapi.pkh 120.0 2005/05/28 12:36:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_INCL_DATA_ELMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_INCL_DATA_ELMT_b
  (
   p_ext_incl_data_elmt_id          in  number
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_INCL_DATA_ELMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_INCL_DATA_ELMT_a
  (
   p_ext_incl_data_elmt_id          in  number
  ,p_ext_rcd_in_file_id             in  number
  ,p_ext_data_elmt_id               in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_ext_data_elmt_in_rcd_id        in  number
  );
--
end ben_EXT_INCL_DATA_ELMT_bk2;

 

/
