--------------------------------------------------------
--  DDL for Package HR_TTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TTL_RKU" AUTHID CURRENT_USER as
/* $Header: hrttlrhi.pkh 120.0 2005/05/31 03:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_topic_id                  in number
  ,p_name                         in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_ttl_rku;

 

/
