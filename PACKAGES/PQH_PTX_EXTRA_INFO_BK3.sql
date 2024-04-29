--------------------------------------------------------
--  DDL for Package PQH_PTX_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pqpteapi.pkh 120.0 2005/05/29 02:20:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptx_extra_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_extra_info_b
  (
   p_ptx_extra_info_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ptx_extra_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_extra_info_a
  (
   p_ptx_extra_info_id              in  number
  ,p_object_version_number          in  number
  );
--
end pqh_ptx_extra_info_bk3;

 

/
