--------------------------------------------------------
--  DDL for Package PER_CNT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNT_RKU" AUTHID CURRENT_USER as
/* $Header: pecntrhi.pkh 120.0 2005/05/31 06:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_configuration_code           in varchar2
  ,p_configuration_name           in varchar2
  ,p_configuration_description    in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_configuration_name_o         in varchar2
  ,p_configuration_description_o  in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_cnt_rku;

 

/
