--------------------------------------------------------
--  DDL for Package PQH_ROLES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrlsapi.pkh 120.1 2005/10/02 02:27:36 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_role_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role_b
  (
   p_role_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_role_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role_a
  (
   p_role_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_roles_bk3;

 

/
