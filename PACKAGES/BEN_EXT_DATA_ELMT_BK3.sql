--------------------------------------------------------
--  DDL for Package BEN_EXT_DATA_ELMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DATA_ELMT_BK3" AUTHID CURRENT_USER as
/* $Header: bexelapi.pkh 120.1 2005/06/08 13:17:09 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_DATA_ELMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DATA_ELMT_b
  (
   p_ext_data_elmt_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_DATA_ELMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DATA_ELMT_a
  (
   p_ext_data_elmt_id               in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_DATA_ELMT_bk3;

 

/
