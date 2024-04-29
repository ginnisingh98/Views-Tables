--------------------------------------------------------
--  DDL for Package PQH_ROLE_TEMPLATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLE_TEMPLATES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrtmapi.pkh 120.1 2005/10/02 02:27:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_role_template_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role_template_b
  (
   p_role_template_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_role_template_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role_template_a
  (
   p_role_template_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end PQH_ROLE_TEMPLATES_bk3;

 

/
