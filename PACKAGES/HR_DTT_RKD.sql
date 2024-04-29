--------------------------------------------------------
--  DDL for Package HR_DTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DTT_RKD" AUTHID CURRENT_USER as
/* $Header: hrdttrhi.pkh 120.0 2005/05/30 23:52:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_document_type_id             in number
  ,p_language                     in varchar2
  ,p_source_language_o            in varchar2
  ,p_document_type_o              in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_dtt_rkd;

 

/
