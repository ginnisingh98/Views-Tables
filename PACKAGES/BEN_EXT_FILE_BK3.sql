--------------------------------------------------------
--  DDL for Package BEN_EXT_FILE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_FILE_BK3" AUTHID CURRENT_USER as
/* $Header: bexfiapi.pkh 120.0 2005/05/28 12:33:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_FILE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_FILE_b
  (
   p_ext_file_id                    in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_EXT_FILE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_FILE_a
  (
   p_ext_file_id                    in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_EXT_FILE_bk3;

 

/
