--------------------------------------------------------
--  DDL for Package CN_HEAD_HIERARCHIES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_HEAD_HIERARCHIES_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: cnmlhhs.pls 120.3 2005/12/13 01:45:15 hanaraya noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_HEAD_HIERARCHY_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  --R12 MOAC Changes--Start
  X_ORG_ID in NUMBER);
  --R12 MOAC Changes--End


procedure UPDATE_ROW (
  X_HEAD_HIERARCHY_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
    --R12 MOAC Changes--Start
  X_ORG_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in out NOCOPY CN_HEAD_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE);
  --R12 MOAC Changes--End

procedure DELETE_ROW (
  X_HEAD_HIERARCHY_ID in NUMBER,
    --R12 MOAC Changes--Start
  X_ORG_ID in NUMBER);
  --R12 MOAC Changes--End

procedure ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_head_hierarchy_id IN NUMBER,
    x_dimension_id IN NUMBER,
    x_org_id in NUMBER, -- R12 change
    x_name IN VARCHAR2,
    x_description IN VARCHAR2,
    x_owner IN VARCHAR2);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_head_hierarchy_id IN NUMBER,
    x_dimension_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);


FUNCTION Default_Header RETURN NUMBER;

end CN_HEAD_HIERARCHIES_ALL_PKG;

 

/
