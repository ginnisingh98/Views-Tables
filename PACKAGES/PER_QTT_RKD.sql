--------------------------------------------------------
--  DDL for Package PER_QTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QTT_RKD" AUTHID CURRENT_USER as
/* $Header: peqttrhi.pkh 120.0 2005/05/31 16:17:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_qualification_type_id        in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end per_qtt_rkd;

 

/
