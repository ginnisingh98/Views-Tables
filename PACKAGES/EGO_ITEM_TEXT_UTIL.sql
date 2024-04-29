--------------------------------------------------------
--  DDL for Package EGO_ITEM_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_TEXT_UTIL" AUTHID DEFINER AS
/* $Header: EGOUIMTS.pls 120.2 2005/07/20 23:56:50 vkeerthi noship $ */

-- -----------------------------------------------------------------------------
--          Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME   CONSTANT  VARCHAR2(12)  :=  'EGOUIMTS.pls';

g_Internal_Type   CONSTANT  VARCHAR2(30)  :=  '$$INTERNAL$$';
g_Customer_Type   CONSTANT  VARCHAR2(30)  :=  '$$CUSTOMER$$';

-- -----------------------------------------------------------------------------
--          Set_Context
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 );

-- -----------------------------------------------------------------------------
--          Get_Item_Text
-- -----------------------------------------------------------------------------

PROCEDURE Get_Item_Text
(
   p_rowid          IN             ROWID
,  p_output_type    IN             VARCHAR2
,  x_tlob           IN OUT NOCOPY  CLOB
,  x_tchar          IN OUT NOCOPY  VARCHAR2
);

-- -----------------------------------------------------------------------------
--            Print_Lob
-- -----------------------------------------------------------------------------

PROCEDURE Print_Lob ( p_tlob_loc  IN  CLOB );

-- -----------------------------------------------------------------------------
--          Sync_Index
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL );

-- -----------------------------------------------------------------------------
--          Optimize_Index
-- -----------------------------------------------------------------------------

-- Start : Concurrent Program for Optimize iM index
PROCEDURE Optimize_Index
(
   ERRBUF      OUT NOCOPY VARCHAR2
,  RETCODE     OUT NOCOPY NUMBER
,  p_optlevel  IN         VARCHAR2 DEFAULT  AD_CTX_DDL.Optlevel_Full
,  p_dummy     IN         VARCHAR2 DEFAULT  NULL
,  p_maxtime   IN         NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
);
-- End : Concurrent Program for Optimize iM index

-- -----------------------------------------------------------------------------
--          Process_Source_Table_Event (wrapper)
-- -----------------------------------------------------------------------------

PROCEDURE Process_Source_Table_Event
(
   p_table_name           IN  VARCHAR2
,  p_event                IN  VARCHAR2
,  p_scope                IN  VARCHAR2
,  p_manufacturer_id   IN NUMBER
,  p_old_item_id         IN NUMBER
,  p_item_id              IN  NUMBER
,  p_org_id               IN  NUMBER
,  p_language             IN  VARCHAR2
,  p_source_lang          IN  VARCHAR2
,  p_last_update_date     IN  VARCHAR2
,  p_last_updated_by      IN  VARCHAR2
,  p_last_update_login    IN  VARCHAR2
,  p_id_type                 IN  VARCHAR2
,  p_item_code               IN  VARCHAR2
,  p_item_catalog_group_id   IN  VARCHAR2
);
-- -----------------------------------------------------------------------------
--          Process_Source_Table_Event
-- -----------------------------------------------------------------------------

PROCEDURE Process_Source_Table_Event
(
   p_table_name           IN  VARCHAR2
,  p_event                IN  VARCHAR2
,  p_scope                IN  VARCHAR2
,  p_item_id              IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
,  p_org_id               IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
,  p_language             IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_source_lang          IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_last_update_date     IN  VARCHAR2    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_id_type                 IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_item_code               IN  VARCHAR2    DEFAULT  FND_API.G_MISS_CHAR
,  p_item_catalog_group_id   IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
);


-- -----------------------------------------------------------------------------
--          get_Prod_Schema
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--        get_DB_Version_Num
-- -----------------------------------------------------------------------------

FUNCTION get_DB_Version_Num
RETURN NUMBER;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2;
-- -----------------------------------------------------------------------------
--        get_DB_Version_Num
-- -----------------------------------------------------------------------------

END EGO_ITEM_TEXT_UTIL;

 

/

  GRANT EXECUTE ON "APPS"."EGO_ITEM_TEXT_UTIL" TO "CTXSYS";
