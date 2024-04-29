--------------------------------------------------------
--  DDL for Package PJM_COMMITMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_COMMITMENT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PJMCMTUS.pls 120.1 2006/07/10 23:13:25 yliou noship $ */

FUNCTION REQ_Type
( X_Org_Id   IN NUMBER
, X_Subtype  IN VARCHAR2
) return VARCHAR2;

FUNCTION BOM_RESOURCE
( X_resource_id IN NUMBER
) return VARCHAR2;

FUNCTION Item_Number
( X_Item_Id         IN NUMBER
, X_Organization_Id IN NUMBER
) return VARCHAR2;

FUNCTION PO_EXP_ORG
( X_org    IN NUMBER
, X_entity IN NUMBER
, X_seq    IN NUMBER
, X_dest   IN VARCHAR2
) return NUMBER;

FUNCTION PO_EXP_TYPE
( X_org     IN NUMBER
, X_project IN NUMBER
, X_item    IN NUMBER
, X_res     IN NUMBER
, X_dest    IN VARCHAR2
) return VARCHAR2;

FUNCTION PO_TASK_ID
( X_org     IN NUMBER
, X_project IN NUMBER
, X_dest    IN VARCHAR2
, X_item    IN NUMBER
, X_subinv  IN VARCHAR2
, X_task    IN NUMBER
, X_entity  IN NUMBER
, X_seq     IN NUMBER
) return NUMBER;

FUNCTION Uom_Conversion_Rate
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return NUMBER;

FUNCTION GET_UNIT
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2;

FUNCTION GET_UOM_CODE
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2;

FUNCTION GET_UOM_TL
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2;

FUNCTION Vendor_Name
( X_Vendor_Id  IN NUMBER
) return VARCHAR2;

FUNCTION People_Name
( X_Person_Id IN NUMBER
) return VARCHAR2;

FUNCTION PO_Type
( X_Org_Id   IN NUMBER
, X_Subtype  IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION PO_PROJECT_ID
( X_Org_ID         IN    NUMBER
, X_Project_ID     IN    NUMBER
) RETURN NUMBER;

FUNCTION MTL_EXPENDITURE_TYPE
( X_Org_ID         IN    NUMBER
, X_Item_ID        IN    NUMBER
) RETURN VARCHAR2;

FUNCTION RES_EXPENDITURE_TYPE
( X_Resource_ID    IN    NUMBER
) RETURN VARCHAR2;

FUNCTION OSP_EXPENDITURE_TYPE
( X_Org_ID         IN    NUMBER
, X_Project_ID     IN    NUMBER
, X_Resource_ID    IN    NUMBER
) RETURN VARCHAR2;

PROCEDURE CREATE_SYNONYMS;

END PJM_COMMITMENT_UTILS;

 

/
