--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_CTXSTRING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_CTXSTRING_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPCSS.pls 120.2 2006/05/18 11:44 sbgeorge noship $*/

PROCEDURE populateCtxCatgAtt
(       p_internal_request_id    IN      NUMBER
);

/*
Procedure to re-populate the dtls for a particular source and internal_request_id,
The calling procedure should make sure to remove all the dtls for the source and internal_request_id
Commenting out for the moment
PROCEDURE populateCtxString
(       p_doc_source            IN      VARCHAR2                ,
        p_internal_request_id   IN      NUMBER                  ,
        p_mode                  IN      VARCHAR2                ,
        p_batch_size            IN      NUMBER
);
*/
------------------------------------------------------
---- Procedures called from loader and authoring
---- for schema changes
------------------------------------------------------

PROCEDURE rePopulateCategoryAttributes
(       p_category_id   IN      NUMBER
);

PROCEDURE rePopulateBaseAttributes
(       p_attribute_key IN      VARCHAR2        ,
        p_searchable    IN      NUMBER
);

PROCEDURE handleSearchableFlagChange
(       p_attribute_id  IN      NUMBER          ,
        p_attribute_key IN      VARCHAR2        ,
        p_category_id   IN      NUMBER          ,
        p_searchable    IN      NUMBER
);

PROCEDURE handleCategoryRename
(       p_category_id   IN      NUMBER          ,
        p_category_name IN      VARCHAR2        ,
        p_language      IN      VARCHAR2
);

END ICX_CAT_POPULATE_CTXSTRING_PVT;

 

/
