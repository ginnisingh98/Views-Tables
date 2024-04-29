--------------------------------------------------------
--  DDL for Package PER_STT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_STT_RKI" AUTHID CURRENT_USER as
/* $Header: pesttrhi.pkh 120.0 2005/05/31 22:08:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_shared_type_id                 in number
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
 ,p_shared_type_name               in varchar2
  );
end per_stt_rki;

 

/
