--------------------------------------------------------
--  DDL for Package HR_AVM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AVM_RKD" AUTHID CURRENT_USER as
/* $Header: hravmrhi.pkh 120.0 2005/05/30 23:02:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_ath_variablemap_id           in number
  ,p_ath_dsn_o                    in varchar2
  ,p_ath_tablename_o              in varchar2
  ,p_ath_columnname_o             in varchar2
  ,p_ath_varname_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_avm_rkd;

 

/
