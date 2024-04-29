--------------------------------------------------------
--  DDL for Package CN_DIMENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DIMENSIONS_PKG" AUTHID CURRENT_USER as
-- $Header: cndidims.pls 120.3 2005/12/13 01:48:38 hanaraya noship $


  --+
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Procedure determining whether an event is valid based upon the current
  --   status of an object and whether a
  --   states.
  -- History
  --   12/28/93		Paul Mitchell		Created
--
--  old insert_row before MLS change
--  PROCEDURE insert_row(
--	X_rowid			IN OUT	varchar2,
--        X_dimension_id          IN OUT  number,
--        X_name				varchar2,
--        X_description			varchar2	default	NULL);

  procedure INSERT_ROW (
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SOURCE_TABLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID	in NUMBER
--R12 MOAC Changes--End
);

  --+
  -- Procedure Name
  --   update_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --+
--  PROCEDURE update_row(
--	X_rowid                         varchar2,
--        X_dimension_id                  number,
--        X_name                          varchar2,
--        X_Description                   varchar2	default NULL);

  procedure UPDATE_ROW (
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SOURCE_TABLE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID	in NUMBER,
  X_OBJECT_VERSION_NUMBER in out NOCOPY  CN_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE);
--R12 MOAC Changes--End


  --+
  -- Procedure Name
  --   delete_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --+
-- old delete_row before MLS change
  --  PROCEDURE delete_row(X_rowid		 varchar2);

procedure DELETE_ROW (X_DIMENSION_ID in NUMBER,X_ORG_ID in NUMBER);


procedure add_language;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_dimension_id IN NUMBER,
    x_org_id in NUMBER, -- R12 change
    x_description IN VARCHAR2,
    x_source_table_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_dimension_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

FUNCTION New_Dimension RETURN NUMBER;

END CN_DIMENSIONS_PKG;
 

/
