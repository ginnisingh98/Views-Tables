--------------------------------------------------------
--  DDL for Package BEN_EXT_RCD_IN_FILE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RCD_IN_FILE_BK3" AUTHID CURRENT_USER as
/* $Header: bexrfapi.pkh 120.1 2005/06/21 16:54:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RCD_IN_FILE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RCD_IN_FILE_b
  (
   p_ext_rcd_in_file_id             in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_RCD_IN_FILE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RCD_IN_FILE_a
  (
   p_ext_rcd_in_file_id             in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RCD_IN_FILE_bk3;

 

/
