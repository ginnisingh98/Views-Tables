--------------------------------------------------------
--  DDL for Package DOM_DOC_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_DOC_TEXT_UTIL" AUTHID DEFINER AS
/* $Header: DOMUIMTS.pls 120.1 2006/07/18 23:57:03 apenmatc noship $ */

-- -----------------------------------------------------------------------------
--  				Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME		CONSTANT  VARCHAR2(12)  :=  'DOMUIMTS.pls';

g_Internal_Type		CONSTANT  VARCHAR2(30)  :=  '$$INTERNAL$$';
g_Customer_Type		CONSTANT  VARCHAR2(30)  :=  '$$CUSTOMER$$';

-- -----------------------------------------------------------------------------
--  				Set_Context
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 );

-- -----------------------------------------------------------------------------
--  				Get_Doc_Text
-- -----------------------------------------------------------------------------



PROCEDURE Get_Doc_Text
(
   p_rowid          IN             ROWID
,  p_output_type    IN             VARCHAR2
,  x_tlob           IN OUT NOCOPY  CLOB
,  x_tchar          IN OUT NOCOPY  VARCHAR2
);

-- -----------------------------------------------------------------------------
--  				  Print_Lob
-- -----------------------------------------------------------------------------

PROCEDURE Print_Lob ( p_tlob_loc  IN  CLOB );

-- -----------------------------------------------------------------------------
--  				Sync_Index
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL );

-- -----------------------------------------------------------------------------
--  				Sync_Index_For_Forms
-- -----------------------------------------------------------------------------

PROCEDURE Sync_Index_For_Forms ( p_idx_name  IN  VARCHAR2    DEFAULT  NULL );

-- -----------------------------------------------------------------------------
--  				Optimize_Index
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
--				  get_Prod_Schema
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--				get_DB_Version_Num
-- -----------------------------------------------------------------------------

FUNCTION get_DB_Version_Num
RETURN NUMBER;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--				Insert_Update_Doc
-- -----------------------------------------------------------------------------

PROCEDURE Insert_Update_Doc
(
   p_doc_id            IN  NUMBER      DEFAULT  FND_API.G_MISS_NUM
);

END DOM_DOC_TEXT_UTIL;

 

/

  GRANT EXECUTE ON "APPS"."DOM_DOC_TEXT_UTIL" TO "CTXSYS";
