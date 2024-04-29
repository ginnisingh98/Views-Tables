--------------------------------------------------------
--  DDL for Package PQH_TEMPLATE_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATE_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqtatapi.pkh 120.1 2005/10/02 02:28:15 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TEMPLATE_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TEMPLATE_ATTRIBUTE_b
  (
   p_template_attribute_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TEMPLATE_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TEMPLATE_ATTRIBUTE_a
  (
   p_template_attribute_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_TEMPLATE_ATTRIBUTES_bk3;

 

/
