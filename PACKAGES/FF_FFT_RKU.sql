--------------------------------------------------------
--  DDL for Package FF_FFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FFT_RKU" AUTHID CURRENT_USER as
/* $Header: fffftrhi.pkh 120.0 2005/05/27 23:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_formula_id                   in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_formula_name                 in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_formula_name_o               in varchar2
  ,p_description_o                in varchar2
  );
--
end ff_fft_rku;

 

/
