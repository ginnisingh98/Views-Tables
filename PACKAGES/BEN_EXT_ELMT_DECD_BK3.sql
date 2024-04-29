--------------------------------------------------------
--  DDL for Package BEN_EXT_ELMT_DECD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ELMT_DECD_BK3" AUTHID CURRENT_USER as
/* $Header: bexddapi.pkh 120.1 2005/06/08 13:09:11 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_ELMT_DECD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_DECD_b
  (
   p_ext_data_elmt_decd_id          in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_ELMT_DECD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_DECD_a
  (
   p_ext_data_elmt_decd_id          in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_ELMT_DECD_bk3;

 

/
