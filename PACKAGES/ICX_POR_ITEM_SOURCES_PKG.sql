--------------------------------------------------------
--  DDL for Package ICX_POR_ITEM_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_ITEM_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: ICXSRCS.pls 115.4 2004/03/31 18:47:17 vkartik ship $ */

procedure INSERT_ROW (
  X_ROWID               in out NOCOPY VARCHAR2,
  X_ITEM_SOURCE_ID      in NUMBER,
  X_TYPE                in VARCHAR2,
  X_PROTOCOL_SUPPORTED  in VARCHAR2,
  X_URL                 in VARCHAR2,
  X_IMAGE_URL           in VARCHAR2,
  X_ITEM_SOURCE_NAME    in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CREATION_DATE       in DATE,
  X_CREATED_BY          in NUMBER,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER);

procedure UPDATE_ROW (
  X_ITEM_SOURCE_ID      in NUMBER,
  X_TYPE                in VARCHAR2,
  X_PROTOCOL_SUPPORTED  in VARCHAR2,
  X_URL                 in VARCHAR2,
  X_IMAGE_URL           in VARCHAR2,
  X_ITEM_SOURCE_NAME    in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LAST_UPDATE_DATE    in DATE,
  X_LAST_UPDATED_BY     in NUMBER,
  X_LAST_UPDATE_LOGIN   in NUMBER);

procedure TRANSLATE_ROW(
  X_ITEM_SOURCE_ID      in VARCHAR2,
  X_OWNER               in VARCHAR2,
  X_ITEM_SOURCE_NAME    in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2);

procedure LOAD_ROW(
  X_ITEM_SOURCE_ID      in VARCHAR2,
  X_OWNER		            in VARCHAR2,
  X_ITEM_SOURCE_NAME    in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_TYPE                in VARCHAR2,
  X_PROTOCOL_SUPPORTED  in VARCHAR2,
  X_URL                 in VARCHAR2,
  X_IMAGE_URL           in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2);

procedure ADD_LANGUAGE;

end ICX_POR_ITEM_SOURCES_PKG;

 

/
