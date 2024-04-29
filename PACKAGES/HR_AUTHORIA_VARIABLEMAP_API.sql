--------------------------------------------------------
--  DDL for Package HR_AUTHORIA_VARIABLEMAP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTHORIA_VARIABLEMAP_API" AUTHID CURRENT_USER as
/* $Header: hravmapi.pkh 120.0 2005/05/30 23:00:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_VARIABLEMAP >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow creation of new entries within the
--   HR_ATH_VARIABLEMAP table.
--
-- Prerequisites:
--   none
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_ath_dsn                      Yes  varchar2 The dsn
--   p_ath_tablename                Yes  varchar2 The table name
--   p_ath_columnname               Yes  varchar2 The column name
--   p_ath_varname                  Yes  varchar2 The variable name
--
-- Post Success:
--   When the mapping has been sucessfully been inserted the following
--   parameters are set:
--
--   Name                           Type     Description
--   p_ath_variablemap_id           number   PK of HR_ATH_VARIABLEMAP
--   p_object_version_number        number   Set to 1
--
-- Post Failure:
--   The API does not create the mapping and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure CREATE_VARIABLEMAP
  (p_validate                      in     boolean  default false
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_ath_variablemap_id               out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<UPDATE_VARIABLEMAP>--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow updating of entries within the
--   HR_ATH_VARIABLEMAP table.
--
-- Prerequisites:
--   (i)  The ATH_VARIABLEMAP_ID  must exist within the HR_ATH_VARIABLEMAP
--   table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  Commit or rollback
--   p_ath_dsn                      Yes  varchar2 The dsn
--   p_ath_tablename                Yes  varchar2 The table name
--   p_ath_columnname               Yes  varchar2 The column name
--   p_ath_varname                  Yes  varchar2 The variable name
--   p_ath_variablemap_id           Yes  number   The PK of HR_ATH_VARIABLEMAP
--   p_object_version_number        Yes  number   The version of the row
--
-- Post Success:
--   When the document has been sucessfully been updated the following
--   parameters are set:
--
--   Name                           Type     Description
--   p_object_version_number        number   Set to OVN++
--
-- Post Failure:
--   The API does not update the mapping for the party and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_variablemap
  (p_validate                      in     boolean  default false
  ,p_ath_dsn                       in     varchar2
  ,p_ath_tablename                 in     varchar2
  ,p_ath_columnname                in     varchar2
  ,p_ath_varname                   in     varchar2
  ,p_ath_variablemap_id            in     number
  ,p_object_version_number         in out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_VARIABLEMAP >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow deletion of mappings within the
--   HR_ATH_VARIABLEMAP table.
--
-- Prerequisites:
--   (i)  The ATH_VARIABLEMAP_ID  must exist within the HR_ATH_VARIABLEMAP
--   table.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_ath_variablemap_id           Yes  number   The PK of HR_ATH_VARIABLEMAP
--   p_object_version_number        Yes  number   The version of the row
--
-- Post Success:
--   The record will cease to exist.
--
-- Post Failure:
--   The record will exist, and an error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure DELETE_VARIABLEMAP
  (p_validate                      in     boolean  default false
  ,p_ath_variablemap_id            in     number
  ,p_object_version_number         in     number
  );
--
--
end HR_AUTHORIA_VARIABLEMAP_API;

 

/
