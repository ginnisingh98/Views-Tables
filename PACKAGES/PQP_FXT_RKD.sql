--------------------------------------------------------
--  DDL for Package PQP_FXT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FXT_RKD" AUTHID CURRENT_USER as
/* $Header: pqfxtrhi.pkh 120.0 2006/04/26 23:49 pbhure noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_flxdu_xml_tag_id             in number
  ,p_flxdu_column_id_o            in number
  ,p_flxdu_xml_tag_name_o         in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqp_fxt_rkd;

 

/
