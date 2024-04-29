--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_VARIABLEMAP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_VARIABLEMAP_BK2" AUTHID CURRENT_USER as
/* $Header: hravmapi.pkh 120.0 2005/05/30 23:00:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_VARIABLEMAP_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_VARIABLEMAP_b
  (p_ath_variablemap_id            in     number
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_VARIABLEMAP_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_VARIABLEMAP_a
  (p_ath_variablemap_id            in     number
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_object_version_number         in     number
  );
--
--
end HR_AUTHORIA_VARIABLEMAP_BK2;

 

/
