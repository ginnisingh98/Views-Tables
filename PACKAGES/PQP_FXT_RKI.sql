--------------------------------------------------------
--  DDL for Package PQP_FXT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FXT_RKI" AUTHID CURRENT_USER as
/* $Header: pqfxtrhi.pkh 120.0 2006/04/26 23:49 pbhure noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_flxdu_xml_tag_id             in number
  ,p_flxdu_column_id              in number
  ,p_flxdu_xml_tag_name           in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end pqp_fxt_rki;

 

/
