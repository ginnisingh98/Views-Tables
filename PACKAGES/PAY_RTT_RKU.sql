--------------------------------------------------------
--  DDL for Package PAY_RTT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RTT_RKU" AUTHID CURRENT_USER as
/* $Header: pyrttrhi.pkh 120.0 2005/05/29 08:28:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_run_type_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_shortname                    in varchar2
  ,p_source_lang_o                in varchar2
  ,p_run_type_name_o              in varchar2
  ,p_shortname_o                  in varchar2
  );
--
end pay_rtt_rku;

 

/
