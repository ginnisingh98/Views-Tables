--------------------------------------------------------
--  DDL for Package PQH_TEMPLATE_ATTRIBUTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TEMPLATE_ATTRIBUTES_BK2" AUTHID CURRENT_USER as
/* $Header: pqtatapi.pkh 120.1 2005/10/02 02:28:15 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_TEMPLATE_ATTRIBUTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_TEMPLATE_ATTRIBUTE_b
  (
   p_required_flag                  in  varchar2
  ,p_view_flag                      in  varchar2
  ,p_edit_flag                      in  varchar2
  ,p_template_attribute_id          in  number
  ,p_attribute_id                   in  number
  ,p_template_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_TEMPLATE_ATTRIBUTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_TEMPLATE_ATTRIBUTE_a
  (
   p_required_flag                  in  varchar2
  ,p_view_flag                      in  varchar2
  ,p_edit_flag                      in  varchar2
  ,p_template_attribute_id          in  number
  ,p_attribute_id                   in  number
  ,p_template_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end pqh_TEMPLATE_ATTRIBUTES_bk2;

 

/
