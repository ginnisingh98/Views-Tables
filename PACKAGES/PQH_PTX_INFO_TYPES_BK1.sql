--------------------------------------------------------
--  DDL for Package PQH_PTX_INFO_TYPES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_INFO_TYPES_BK1" AUTHID CURRENT_USER as
/* $Header: pqptiapi.pkh 120.0 2005/05/29 02:21:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ptx_info_type_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptx_info_type_b
  (
   p_active_inactive_flag           in  varchar2
  ,p_description                    in  varchar2
  ,p_multiple_occurences_flag       in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ptx_info_type_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptx_info_type_a
  (
   p_information_type               in  varchar2
  ,p_active_inactive_flag           in  varchar2
  ,p_description                    in  varchar2
  ,p_multiple_occurences_flag       in  varchar2
  ,p_legislation_code               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ptx_info_types_bk1;

 

/
