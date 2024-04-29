--------------------------------------------------------
--  DDL for Package PSP_PFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PFT_RKU" AUTHID CURRENT_USER as
/* $Header: PSPFTRHS.pls 120.0 2005/06/02 15:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_period_frequency_id          in number
  ,p_language                     in varchar2
  ,p_period_frequency             in varchar2
  ,p_source_language              in varchar2
  ,p_period_frequency_o           in varchar2
  ,p_source_language_o            in varchar2
  );
--
end psp_pft_rku;

 

/
