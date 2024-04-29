--------------------------------------------------------
--  DDL for Package IBC_CITEM_KEYWORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CITEM_KEYWORDS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctkwds.pls 115.2 2003/06/23 21:14:25 srrangar noship $*/

-- Purpose: Table Handler for Ibc_Citem_Keywords table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Edward Nunez      06/12/2003  Created Package

PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_KEYWORD IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE 	  		DEFAULT NULL,
  p_CREATED_BY IN NUMBER	  		DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE  		DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER 		DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_KEYWORD IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER
);

PROCEDURE UPDATE_ROW (
   p_CONTENT_ITEM_ID		IN  NUMBER,
   p_KEYWORD	IN  VARCHAR2,
   px_OBJECT_VERSION_NUMBER	IN OUT NOCOPY NUMBER
   ,p_last_update_date                IN DATE          DEFAULT NULL
   ,p_last_updated_by                 IN NUMBER        DEFAULT NULL
);

PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_KEYWORD IN VARCHAR2
);

PROCEDURE LOAD_ROW (
  p_CONTENT_ITEM_ID	IN	NUMBER,
  p_KEYWORD	IN	VARCHAR2,
  p_OWNER IN VARCHAR2
);

END Ibc_citem_keywords_Pkg;

 

/
