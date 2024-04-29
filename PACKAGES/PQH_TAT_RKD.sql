--------------------------------------------------------
--  DDL for Package PQH_TAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TAT_RKD" AUTHID CURRENT_USER as
/* $Header: pqtatrhi.pkh 120.2 2005/10/12 20:19:43 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_template_attribute_id          in number
 ,p_required_flag_o                in varchar2
 ,p_view_flag_o                    in varchar2
 ,p_edit_flag_o                    in varchar2
 ,p_attribute_id_o                 in number
 ,p_template_id_o                  in number
 ,p_object_version_number_o        in number
  );
--
end pqh_tat_rkd;

 

/
