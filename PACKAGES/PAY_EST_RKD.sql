--------------------------------------------------------
--  DDL for Package PAY_EST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EST_RKD" AUTHID CURRENT_USER as
/* $Header: pyestrhi.pkh 120.0 2005/09/27 03:37 shisriva noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_element_set_id               in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_element_set_name_o           in varchar2
  );
--
end pay_est_rkd;

 

/
