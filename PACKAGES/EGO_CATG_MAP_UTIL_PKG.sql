--------------------------------------------------------
--  DDL for Package EGO_CATG_MAP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CATG_MAP_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOUCMS.pls 120.2 2007/08/22 10:36:25 ysireesh noship $ */

/*
 * ACC to ACC Mapping
 * Used in Data Orchestration.
 * GPC i.e One alternate catalog category code is passed to the API as input and the
 * API in turn will return us APC ACC(Alternate catalog category) Id and the
 * alternate catalog category associated with it.
 * param P_GPC_ID - GPC Code
 * param X_ACC_CATEGORY_ID - Alternate Catalog Category Id
 * param X_ACC_CATALOG_ID - Alternate Catalog Id.
 */
 	 PROCEDURE Get_Alt_Catalog_Ctgr_Mapping
 	 (
 	       P_GPC_ID  IN NUMBER,
 	       X_ACC_CATEGORY_ID OUT NOCOPY NUMBER,
 	       X_ACC_CATALOG_ID OUT NOCOPY NUMBER
 	 );


/*
 * ACC to ICC Mapping
 * Used in Data Orchestration.
 * GPC i.e One alternate catalog category code is passed to the API as input and the
 * API in turn will return us APC ICC(Primary catalog category) Id associated
 * with it.
 * param P_GPC_ID - GPC Code
 * param X_ICC_CATEGORY_ID - Primary Catalog Category Id
 */
 	 PROCEDURE Get_Item_Catalog_Ctgr_Mapping
 	 (
 	       P_GPC_ID  IN VARCHAR2,
 	       X_ICC_CATEGORY_ID OUT NOCOPY NUMBER
 	 );

END EGO_CATG_MAP_UTIL_PKG;

/
