--------------------------------------------------------
--  DDL for Package PQH_RFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RFT_RKD" AUTHID CURRENT_USER as
/* $Header: pqrftrhi.pkh 120.2 2005/10/12 20:19:08 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ref_template_id                in number
 ,p_base_template_id_o             in number
 ,p_parent_template_id_o           in number
 ,p_reference_type_cd_o            in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_rft_rkd;

 

/
