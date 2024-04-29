--------------------------------------------------------
--  DDL for Package AME_CAL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CAL_RKD" AUTHID CURRENT_USER as
/* $Header: amcalrhi.pkh 120.0 2005/09/02 03:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_application_id               in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_application_name_o           in varchar2
  );
--
end ame_cal_rkd;

 

/
