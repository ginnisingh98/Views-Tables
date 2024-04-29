--------------------------------------------------------
--  DDL for Package CZ_IMP_SINGLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_SINGLE" AUTHID CURRENT_USER AS
/*	$Header: czisngs.pls 120.4 2007/11/26 12:26:46 kdande ship $		*/
--------------------------------------
RP_ROOT_FOLDER      CONSTANT NUMBER:=0;
--------------------------------------

/* Raised when cz_refs.delete_node returns error */
CZ_REFS_DELNODE_EXCP          EXCEPTION;

FUNCTION ExtractPsNode(inRunId           IN NUMBER,
                       inOrgId           IN NUMBER,
                       inTopId           IN NUMBER,
                       inExplType        IN VARCHAR2,
                       inServerId        IN NUMBER,
                       inRunExploder     IN PLS_INTEGER,
                       inRevDate         IN DATE,
                       inDateFormat      IN VARCHAR2,
                       inRefreshModelId  IN NUMBER,
                       inCopyRootModel   IN VARCHAR2,
                       inCopyChildModels IN VARCHAR2,
                       inGenStatistics   IN PLS_INTEGER)
RETURN NUMBER;
------------------------------------------------------------------------------------------
PROCEDURE ImportSingleBill(nOrg_ID IN NUMBER,
                           nTop_ID IN NUMBER,
                           COPY_CHILD_MODELS IN VARCHAR2,
                           REFRESH_MODEL_ID  IN NUMBER,
                           COPY_ROOT_MODEL   IN VARCHAR2,
                           sExpl_type IN VARCHAR2,
                           dRev_date IN DATE,
                           x_run_id OUT NOCOPY NUMBER); -- sselahi: added x_run_id
------------------------------------------------------------------------------------------
FUNCTION isAppsVersion11i(fndLinkName IN VARCHAR2)
RETURN BOOLEAN;
------------------------------------------------------------------------------------------
FUNCTION importChildModel(inRunId           IN NUMBER,
                          inOrgId           IN NUMBER,
                          inTopId           IN NUMBER,
                          inExplType        IN VARCHAR2)
RETURN BOOLEAN;
------------------------------------------------------------------------------------------
/* Constant Declarations */
cnOracleToMerlinOffset		CONSTANT NUMBER:=256;				/*Conversion Const*/
cnProduct				CONSTANT NUMBER:=cnOracleToMerlinOffset+2;/*Product Type*/
cnComponent				CONSTANT NUMBER:=cnOracleToMerlinOffset+3;/*Component Type*/
cnFeature				CONSTANT NUMBER:=cnOracleToMerlinOffset+5;/*Feature Type*/
cnOption				CONSTANT NUMBER:=cnOracleToMerlinOffset+6;/*Option Type*/
cnModel				CONSTANT NUMBER:=1;                       /*Oracle Model Type*/
cnOptionClass			CONSTANT NUMBER:=2;                       /*Oracle Option Class Type*/
cnStandard				CONSTANT NUMBER:=4;                       /*Oracle Standard Type*/
cnReference                   CONSTANT NUMBER:=263;
bomModel                      CONSTANT NUMBER:=436; /*BOM Item Model type*/
bomOptionClass                CONSTANT NUMBER:=437; /*BOM Item OptionClass type*/
bomStandard                   CONSTANT NUMBER:=438; /*BOM Item Standard type*/
/* BOM_TREATMENT values */
cnNormal				CONSTANT NUMBER:=0;
cnSkip				CONSTANT NUMBER:=1;
cnLeaf                        CONSTANT NUMBER:=2;
cnFlatten                     CONSTANT NUMBER:=3;
/* Oracle Yes/No values */
OraYes                        CONSTANT NUMBER:=1;
OraNo                         CONSTANT NUMBER:=2;
G_CAPTION_RULE_DESC           CONSTANT PLS_INTEGER := 802;
G_CAPTION_RULE_NAME           CONSTANT PLS_INTEGER := 801;
------------------------------------------------------------------------------------------
importUnchangedChildModels    NUMBER := 1;
------------------------------------------------------------------------------------------
-- this global table stores the item_ids of any models found in a top model during extr_devl_project
-- and will be used by extr_intl_text procedure
TYPE tModelItemId_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
gModelItemId_tbl              tModelItemId_tbl;

FUNCTION get_ItemCatalogTable RETURN SYSTEM.CZ_ITEM_CATALOG_TBL;

END CZ_IMP_SINGLE;

/
