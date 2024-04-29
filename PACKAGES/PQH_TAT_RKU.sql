--------------------------------------------------------
--  DDL for Package PQH_TAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TAT_RKU" AUTHID CURRENT_USER as
/* $Header: pqtatrhi.pkh 120.2 2005/10/12 20:19:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_required_flag                  in varchar2
 ,p_view_flag                      in varchar2
 ,p_edit_flag                      in varchar2
 ,p_template_attribute_id          in number
 ,p_attribute_id                   in number
 ,p_template_id                    in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_required_flag_o                in varchar2
 ,p_view_flag_o                    in varchar2
 ,p_edit_flag_o                    in varchar2
 ,p_attribute_id_o                 in number
 ,p_template_id_o                  in number
 ,p_object_version_number_o        in number
  );
--
end pqh_tat_rku;

 

/
