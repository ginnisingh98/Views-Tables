--------------------------------------------------------
--  DDL for Package IRC_IRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IRT_RKU" AUTHID CURRENT_USER as
/* $Header: irirtrhi.pkh 120.0 2005/07/26 15:10 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_recruiting_site_id           in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_site_name                    in varchar2
  ,p_redirection_url              in varchar2
  ,p_posting_url                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_site_name_o                  in varchar2
  ,p_redirection_url_o            in varchar2
  ,p_posting_url_o                in varchar2
  );
--
end irc_irt_rku;

 

/
