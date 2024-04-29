--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_CATG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_CATG_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPCS.pls 120.0 2005/11/09 10:40:25 sbgeorge noship $*/

--Global constants
g_DML_TYPE              VARCHAR2(10);
g_DML_INSERT_TYPE       CONSTANT VARCHAR2(10)   := 'CREATE';
g_DML_UPDATE_TYPE       CONSTANT VARCHAR2(10)   := 'UPDATE';
g_DML_DELETE_TYPE       CONSTANT VARCHAR2(10)   := 'DELETE';

g_auto_create_shop_catg VARCHAR2(1) := 'N';

PROCEDURE populateCategoryChange
(       P_CATEGORY_NAME         IN      VARCHAR2        ,
        P_CATEGORY_ID           IN      NUMBER
);

PROCEDURE populateValidCategorySetInsert
(       P_CATEGORY_ID	        IN	NUMBER
);

PROCEDURE populateValidCategorySetUpdate
(       P_OLD_CATEGORY_ID	IN	NUMBER          ,
        P_NEW_CATEGORY_ID	IN	NUMBER
);

PROCEDURE populateValidCategorySetDelete
(       P_CATEGORY_ID	        IN	NUMBER
);

PROCEDURE setAutoCreateShopCatg
;

END ICX_CAT_POPULATE_CATG_PVT;

 

/
