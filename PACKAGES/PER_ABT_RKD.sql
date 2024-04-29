--------------------------------------------------------
--  DDL for Package PER_ABT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABT_RKD" AUTHID CURRENT_USER as
/* $Header: peabtrhi.pkh 120.0 2005/05/31 04:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_absence_attendance_type_id   in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end per_abt_rkd;

 

/
