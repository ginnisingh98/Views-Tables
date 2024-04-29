--------------------------------------------------------
--  DDL for Package HR_PFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PFT_RKD" AUTHID CURRENT_USER as
/* $Header: hrpftrhi.pkh 120.0 2005/05/31 02:07:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_position_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end hr_pft_rkd;

 

/
