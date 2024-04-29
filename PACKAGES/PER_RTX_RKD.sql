--------------------------------------------------------
--  DDL for Package PER_RTX_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RTX_RKD" AUTHID CURRENT_USER as
/* $Header: pertxrhi.pkh 120.0 2005/05/31 20:01:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rating_level_id              in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  ,p_behavioural_indicator_o      in varchar2
  );
--
end per_rtx_rkd;

 

/
