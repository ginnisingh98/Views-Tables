--------------------------------------------------------
--  DDL for Package PJM_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_INQUIRY" AUTHID CURRENT_USER as
/* $Header: PJMWINQS.pls 120.4.12010000.2 2009/06/24 21:50:33 huiwan ship $ */

FUNCTION get_req_total
(p_header_id   number
) return number;

FUNCTION BR_Type
( X_Org_Id   IN NUMBER
, X_Sybtype  IN VARCHAR2
) return VARCHAR2;

FUNCTION Vendor_Contact
( X_Contact_Id  IN NUMBER
) return VARCHAR2;

FUNCTION OE_Lookup
( X_Lookup_Code IN VARCHAR2
, X_Lookup_Type IN VARCHAR2
) return VARCHAR2;

FUNCTION Item_Number
( X_Item_Id         IN NUMBER
, X_Organization_Id IN NUMBER
) return VARCHAR2;

FUNCTION Payment_Term
( X_Term_Id IN NUMBER
) return VARCHAR2;

FUNCTION People_Name
( X_Person_Id IN NUMBER
) return VARCHAR2;

FUNCTION Get_Lookup
( X_Lookup_Code IN VARCHAR2
, X_Lookup_Type IN VARCHAR2
) return VARCHAR2;

FUNCTION Location_Code
( X_Location_Id  IN NUMBER
) return VARCHAR2;

FUNCTION Vendor_Site
( X_Vendor_Id       IN NUMBER
, X_Vendor_Site_Id  IN NUMBER
) return VARCHAR2;

FUNCTION Vendor_Name
( X_Vendor_Id  IN NUMBER
) return VARCHAR2;

FUNCTION PO_Type
( X_Org_Id   IN NUMBER
) return VARCHAR2;

function OE_ORDER_TOTAL
( X_Header_ID      IN NUMBER,
  x_project_id  IN NUMBER DEFAULT NULL,
  x_task_id   IN NUMBER DEFAULT NULL,
  x_line_id   IN NUMBER DEFAULT NULL
) return number;

function OE_ORG_ADDRESS
( X_Org_ID         IN NUMBER
, X_Org_Type       IN VARCHAR2
) return varchar2;

function YES_NO
( X_Lookup_Code    IN VARCHAR2
) return varchar2;

function SYS_YES_NO
( X_Lookup_Code    IN NUMBER
) return varchar2;

function LOCATOR_CONTROL
( X_Lookup_Code    IN NUMBER
) return varchar2;

function COMPONENT_SERIAL
( X_Organization_ID  IN NUMBER
, X_Wip_Entity_ID    IN NUMBER
, X_Op_Seq_Num       IN NUMBER
, X_Item_ID          IN NUMBER
) return varchar2;

function TRANSACTION_SOURCE_NAME
( X_Trx_Src_Type_ID  IN NUMBER
, X_Trx_Source_ID    IN NUMBER
) return varchar2;

end PJM_INQUIRY;

/
