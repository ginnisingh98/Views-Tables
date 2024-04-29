--------------------------------------------------------
--  DDL for Package PER_STT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STT_RKD" AUTHID CURRENT_USER as
/* $Header: pesttrhi.pkh 120.0 2005/05/31 22:08:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_shared_type_id                 in number
 ,p_language_o                     in varchar2
 ,p_source_lang_o                  in varchar2
 ,p_shared_type_name_o             in varchar2
  );
--
end per_stt_rkd;

 

/
