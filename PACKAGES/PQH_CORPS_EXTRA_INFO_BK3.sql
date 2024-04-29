--------------------------------------------------------
--  DDL for Package PQH_CORPS_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pqceiapi.pkh 120.1 2005/10/02 02:26:26 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_corps_extra_info_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_corps_extra_info_b
  (
  p_corps_extra_info_id            in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_corps_extra_info_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_corps_extra_info_a
  (
  p_corps_extra_info_id            in  number
  ,p_object_version_number          in number
  );
--
end pqh_corps_extra_info_bk3;

 

/
