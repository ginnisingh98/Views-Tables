--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_DATA_ELMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_DATA_ELMT_BK3" AUTHID CURRENT_USER as
/* $Header: bexidapi.pkh 120.0 2005/05/28 12:36:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_INCL_DATA_ELMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_INCL_DATA_ELMT_b
  (
   p_ext_incl_data_elmt_id          in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_INCL_DATA_ELMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_INCL_DATA_ELMT_a
  (
   p_ext_incl_data_elmt_id          in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_INCL_DATA_ELMT_bk3;

 

/
