--------------------------------------------------------
--  DDL for Package PER_STT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STT_RKU" AUTHID CURRENT_USER as
/* $Header: pesttrhi.pkh 120.0 2005/05/31 22:08:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_shared_type_id                 in number
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
 ,p_shared_type_name               in varchar2
 ,p_language_o                     in varchar2
 ,p_source_lang_o                  in varchar2
 ,p_shared_type_name_o             in varchar2
  );
--
end per_stt_rku;

 

/
