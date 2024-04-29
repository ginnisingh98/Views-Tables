--------------------------------------------------------
--  DDL for Package BEN_ELIG_OBJ_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_OBJ_BK1" AUTHID CURRENT_USER as
/* $Header: bebeoapi.pkh 120.0 2005/05/28 00:38:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_OBJ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_OBJ_b
  (
   p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_OBJ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_OBJ_a
  (
   p_elig_obj_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_elig_obj_bk1;

 

/
