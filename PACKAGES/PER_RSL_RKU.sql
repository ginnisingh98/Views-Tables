--------------------------------------------------------
--  DDL for Package PER_RSL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RSL_RKU" AUTHID CURRENT_USER as
/* $Header: perslrhi.pkh 120.0 2005/05/31 19:50:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_rating_scale_id              in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  );
--
end per_rsl_rku;

 

/
