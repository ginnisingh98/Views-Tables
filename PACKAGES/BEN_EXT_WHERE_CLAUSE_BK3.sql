--------------------------------------------------------
--  DDL for Package BEN_EXT_WHERE_CLAUSE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_WHERE_CLAUSE_BK3" AUTHID CURRENT_USER as
/* $Header: bexwcapi.pkh 120.1 2005/10/11 06:34:58 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ext_where_clause_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ext_where_clause_b
  (
   p_ext_where_clause_id            in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ext_where_clause_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ext_where_clause_a
  (
   p_ext_where_clause_id            in  number
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ext_where_clause_bk3;

 

/
