--------------------------------------------------------
--  DDL for Package FF_FGT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FGT_RKU" AUTHID CURRENT_USER as
/* $Header: fffgtrhi.pkh 120.0 2005/05/27 23:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_global_id                    in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_global_name                  in varchar2
  ,p_global_description           in varchar2
  ,p_source_lang_o                in varchar2
  ,p_global_name_o                in varchar2
  ,p_global_description_o         in varchar2
  );
--
end ff_fgt_rku;

 

/
