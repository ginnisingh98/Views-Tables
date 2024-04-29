--------------------------------------------------------
--  DDL for Package BEN_EXT_INCL_CHG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_INCL_CHG_BK3" AUTHID CURRENT_USER as
/* $Header: bexicapi.pkh 120.1 2005/06/08 13:23:38 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_INCL_CHG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_INCL_CHG_b
  (
   p_ext_incl_chg_id                in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_INCL_CHG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_INCL_CHG_a
  (
   p_ext_incl_chg_id                in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_INCL_CHG_bk3;

 

/
