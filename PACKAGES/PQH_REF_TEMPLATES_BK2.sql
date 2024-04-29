--------------------------------------------------------
--  DDL for Package PQH_REF_TEMPLATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_REF_TEMPLATES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrftapi.pkh 120.1 2005/10/02 02:27:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_REF_TEMPLATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_REF_TEMPLATE_b
  (
   p_ref_template_id                in  number
  ,p_base_template_id               in  number
  ,p_parent_template_id             in  number
  ,p_reference_type_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_REF_TEMPLATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_REF_TEMPLATE_a
  (
   p_ref_template_id                in  number
  ,p_base_template_id               in  number
  ,p_parent_template_id             in  number
  ,p_reference_type_cd              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_REF_TEMPLATES_bk2;

 

/
