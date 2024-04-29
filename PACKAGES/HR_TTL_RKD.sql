--------------------------------------------------------
--  DDL for Package HR_TTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TTL_RKD" AUTHID CURRENT_USER as
/* $Header: hrttlrhi.pkh 120.0 2005/05/31 03:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_topic_id                  in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hr_ttl_rkd;

 

/
