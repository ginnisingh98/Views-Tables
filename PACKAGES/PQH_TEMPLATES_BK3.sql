--------------------------------------------------------
--  DDL for Package PQH_TEMPLATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATES_BK3" AUTHID CURRENT_USER as
/* $Header: pqtemapi.pkh 120.1 2005/10/02 02:28:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GENERIC_TEMPLATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENERIC_TEMPLATE_b
  (
   p_template_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GENERIC_TEMPLATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENERIC_TEMPLATE_a
  (
   p_template_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
--
end pqh_TEMPLATES_bk3;

 

/
