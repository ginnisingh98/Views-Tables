--------------------------------------------------------
--  DDL for Package HR_FWT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FWT_RKI" AUTHID CURRENT_USER as
/* $Header: hrfwtrhi.pkh 120.0 2005/05/31 00:35:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_window_id               in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_window_name             in varchar2
  ,p_description                  in varchar2
  );
end hr_fwt_rki;

 

/
