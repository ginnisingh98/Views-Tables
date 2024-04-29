--------------------------------------------------------
--  DDL for Package PER_QTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QTT_RKI" AUTHID CURRENT_USER as
/* $Header: peqttrhi.pkh 120.0 2005/05/31 16:17:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_qualification_type_id        in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  );
end per_qtt_rki;

 

/
