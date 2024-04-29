--------------------------------------------------------
--  DDL for Package PER_RTX_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RTX_RKI" AUTHID CURRENT_USER as
/* $Header: pertxrhi.pkh 120.0 2005/05/31 20:01:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_rating_level_id              in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  ,p_behavioural_indicator        in varchar2
  );
end per_rtx_rki;

 

/
