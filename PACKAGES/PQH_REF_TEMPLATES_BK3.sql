--------------------------------------------------------
--  DDL for Package PQH_REF_TEMPLATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REF_TEMPLATES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrftapi.pkh 120.1 2005/10/02 02:27:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_REF_TEMPLATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_REF_TEMPLATE_b
  (
   p_ref_template_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_REF_TEMPLATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_REF_TEMPLATE_a
  (
   p_ref_template_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_REF_TEMPLATES_bk3;

 

/
