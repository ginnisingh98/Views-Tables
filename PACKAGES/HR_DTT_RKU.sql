--------------------------------------------------------
--  DDL for Package HR_DTT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DTT_RKU" AUTHID CURRENT_USER as
/* $Header: hrdttrhi.pkh 120.0 2005/05/30 23:52:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_document_type_id             in number
  ,p_language                     in varchar2
  ,p_source_language              in varchar2
  ,p_document_type                in varchar2
  ,p_description                  in varchar2
  ,p_source_language_o            in varchar2
  ,p_document_type_o              in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_dtt_rku;

 

/
