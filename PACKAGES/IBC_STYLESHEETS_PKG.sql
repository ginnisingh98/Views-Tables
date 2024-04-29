--------------------------------------------------------
--  DDL for Package IBC_STYLESHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_STYLESHEETS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctstys.pls 120.3 2005/07/12 03:49:42 appldev ship $*/

-- Purpose: Table Handler for Ibc_Stylesheets table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW
-- sharma	     06/01/2005     initialization removed for GSCC mandate
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_default_stylesheet_flag IN VARCHAR2, -- DEFAULT 'F',
  p_CREATION_DATE IN DATE, --	DEFAULT NULL,
  p_CREATED_BY IN NUMBER, --DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE, --DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER, --DEFAULT NULL,
  p_LAST_UPDATE_LOGIN IN NUMBER --DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
);

PROCEDURE UPDATE_ROW (
  p_CONTENT_ITEM_ID    IN  NUMBER,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_default_stylesheet_flag IN VARCHAR2, -- DEFAULT NULL,
  p_LAST_UPDATED_BY    IN  NUMBER, -- DEFAULT  NULL,
  p_LAST_UPDATE_DATE    IN  DATE, -- DEFAULT  NULL,
  p_LAST_UPDATE_LOGIN    IN  NUMBER, -- DEFAULT  NULL,
  p_OBJECT_VERSION_NUMBER    IN  NUMBER -- DEFAULT  NULL
);

PROCEDURE DELETE_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER
);

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_ITEM_ID	 NUMBER,
  p_CONTENT_TYPE_CODE	  	  VARCHAR2,
  p_default_stylesheet_flag	  VARCHAR2, --DEFAULT 'F',
  p_OWNER 	VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_ITEM_ID	 NUMBER,
  p_CONTENT_TYPE_CODE	  	  VARCHAR2,
  p_default_stylesheet_flag	  VARCHAR2, --DEFAULT 'F',
  p_OWNER 	VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2);

END Ibc_Stylesheets_Pkg;

 

/
