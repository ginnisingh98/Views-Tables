--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_VARIABLEMAP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_VARIABLEMAP_BK1" AUTHID CURRENT_USER as
/* $Header: hravmapi.pkh 120.0 2005/05/30 23:00:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_VARIABLEMAP_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLEMAP_b
  (
   p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_VARIABLEMAP_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLEMAP_a
  (
   p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  );
--
--
end HR_AUTHORIA_VARIABLEMAP_BK1;

 

/
