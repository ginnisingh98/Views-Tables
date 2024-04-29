--------------------------------------------------------
--  DDL for Package PQH_PTX_INFO_TYPES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_INFO_TYPES_BK3" AUTHID CURRENT_USER as
/* $Header: pqptiapi.pkh 120.0 2005/05/29 02:21:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptx_info_type_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_info_type_b
  (
   p_information_type               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptx_info_type_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_info_type_a
  (
   p_information_type               in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_ptx_info_types_bk3;

 

/
