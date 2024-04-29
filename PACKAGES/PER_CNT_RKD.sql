--------------------------------------------------------
--  DDL for Package PER_CNT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNT_RKD" AUTHID CURRENT_USER as
/* $Header: pecntrhi.pkh 120.0 2005/05/31 06:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_configuration_code           in varchar2
  ,p_language                     in varchar2
  ,p_configuration_name_o         in varchar2
  ,p_configuration_description_o  in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_cnt_rkd;

 

/
