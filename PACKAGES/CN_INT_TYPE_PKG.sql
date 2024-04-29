--------------------------------------------------------
--  DDL for Package CN_INT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_INT_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: cntintvs.pls 120.1 2005/09/20 14:15:30 ymao noship $ */
--
-- Package Name
--   CN_INT_TYPE_PKG
-- Purpose
--   Table handler for CN_INTERVAL_TYPES
-- Form
--   CNINTTP
-- Block
--   INTERVAL_TYPES
--
-- History
--   16-Aug-99  Yonghong Mao  Created

--
-- global variables that represent missing values
--
g_last_update_date           DATE   := Sysdate;
g_last_updated_by            NUMBER := fnd_global.user_id;
g_creation_date              DATE   := Sysdate;
g_created_by                 NUMBER := fnd_global.user_id;
g_last_update_login          NUMBER := fnd_global.login_id;

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  get_interval_type_id
-- Purpose
--  Get the sequence number to create a new interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE get_interval_type_id( x_interval_type_id IN OUT NOCOPY NUMBER);

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER);
procedure LOCK_ROW (
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_ORG_ID in NUMBER
);
procedure UPDATE_ROW (
  X_INTERVAL_TYPE_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER
);
procedure DELETE_ROW (
  X_INTERVAL_TYPE_ID in NUMBER
);
procedure ADD_LANGUAGE;

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Post_Insert
-- Purpose
--  Populate the table cn_cal_per_int_types after creating an interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE post_insert
  ( x_interval_type_id        cn_interval_types.interval_type_id%TYPE,
    x_last_update_date        cn_interval_types.last_update_date%TYPE,
    x_last_updated_by         cn_interval_types.last_updated_by%TYPE,
    x_creation_date           cn_interval_types.creation_date%TYPE,
    x_created_by              cn_interval_types.created_by%TYPE,
    x_last_update_login       cn_interval_types.last_update_login%TYPE,
    x_org_id                  cn_interval_types.org_id%TYPE
    );

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  post_delete
-- Purpose
--  Delete the corresponding records in cn_cal_per_int_types after deleting an interval type
-- *--------------------------------------------------------------------------*/
PROCEDURE post_delete( x_interval_type_id cn_interval_types.interval_type_id%TYPE);

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_interval_type_id IN NUMBER,
    x_description IN VARCHAR2,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
	x_org_id IN NUMBER);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_interval_type_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

END CN_INT_TYPE_PKG;

 

/
