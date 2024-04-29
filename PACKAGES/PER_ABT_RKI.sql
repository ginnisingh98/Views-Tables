--------------------------------------------------------
--  DDL for Package PER_ABT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABT_RKI" AUTHID CURRENT_USER as
/* $Header: peabtrhi.pkh 120.0 2005/05/31 04:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_absence_attendance_type_id   in number
  ,p_name                         in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end per_abt_rki;

 

/
