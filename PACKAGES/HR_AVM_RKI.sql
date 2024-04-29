--------------------------------------------------------
--  DDL for Package HR_AVM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AVM_RKI" AUTHID CURRENT_USER as
/* $Header: hravmrhi.pkh 120.0 2005/05/30 23:02:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_ath_variablemap_id           in number
  ,p_ath_dsn                      in varchar2
  ,p_ath_tablename                in varchar2
  ,p_ath_columnname               in varchar2
  ,p_ath_varname                  in varchar2
  ,p_object_version_number        in number
  );
end hr_avm_rki;

 

/
