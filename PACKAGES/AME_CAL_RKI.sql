--------------------------------------------------------
--  DDL for Package AME_CAL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CAL_RKI" AUTHID CURRENT_USER as
/* $Header: amcalrhi.pkh 120.0 2005/09/02 03:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_application_id               in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_application_name             in varchar2
  );
end ame_cal_rki;

 

/
