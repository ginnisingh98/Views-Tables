--------------------------------------------------------
--  DDL for Package Body PJM_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_INQUIRY" as
/* $Header: PJMWINQB.pls 120.6.12010000.2 2009/06/24 21:54:47 huiwan ship $ */

--
-- Private Global Variables
--
G_Yes           VARCHAR2(80)                    := NULL;
G_No            VARCHAR2(80)                    := NULL;

FUNCTION get_req_total
        (p_header_id   number) return number is
         X_req_total     number;

  BEGIN
    SELECT nvl(SUM(decode(quantity,
                          null,
                          amount,
                          (quantity * unit_price)
                         )
           ), 0)
           into X_req_total
    FROM   po_requisition_lines_all
    WHERE  requisition_header_id = p_header_id and
           nvl(cancel_flag,'N') <> 'Y' and    -- Bug 554452 Ignore cancelled lines
           nvl(MODIFIED_BY_AGENT_FLAG, 'N') = 'N' and   -- Bug 574676
           nvl(CLOSED_CODE, 'OPEN') <> 'FINALLY CLOSED';  -- Bug 574676

    RETURN (X_req_total);

  EXCEPTION
    WHEN OTHERS then
       X_req_total := 0;
END get_req_total;


FUNCTION BR_Type
( X_Org_Id   IN NUMBER
, X_Sybtype  IN VARCHAR2
) return VARCHAR2 IS

L_Type_Name VARCHAR2(80);

BEGIN

SELECT T.TYPE_NAME into L_Type_Name
from PO_DOCUMENT_TYPES_ALL_TL T
WHERE T.LANGUAGE = userenv('LANG')
   and T.DOCUMENT_TYPE_CODE = 'RELEASE'
AND  T.DOCUMENT_SUBTYPE  = X_Sybtype
and T.org_id = X_Org_Id;

  RETURN ( L_Type_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END BR_Type;


FUNCTION Vendor_Contact
( X_Contact_Id  IN NUMBER
) return VARCHAR2 IS

L_Contact_Name VARCHAR2(360);

BEGIN

  SELECT DECODE(VC.LAST_NAME, NULL, NULL, VC.LAST_NAME||', '||VC.FIRST_NAME)
  into L_Contact_Name
  from PO_VENDOR_CONTACTS VC
  where VC.VENDOR_CONTACT_ID = X_Contact_id;

  RETURN ( L_Contact_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Vendor_Contact;


FUNCTION Item_Number
( X_Item_Id         IN NUMBER
, X_Organization_Id IN NUMBER
) return VARCHAR2 IS

L_Item_Number VARCHAR2(40);

BEGIN

  SELECT segment1 into L_Item_Number
  from mtl_system_items_b
  where inventory_item_id = X_Item_Id
  and organization_id = X_Organization_Id;

  RETURN ( L_Item_Number );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Item_Number;


FUNCTION Payment_Term
( X_Term_Id IN NUMBER
) return VARCHAR2 IS

L_Payment_Term VARCHAR2(50);

BEGIN

  SELECT NAME into L_Payment_Term
  from AP_TERMS_TL B
  WHERE term_id = X_Term_Id
  AND   LANGUAGE = userenv('LANG');

  RETURN ( L_Payment_Term );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Payment_Term;


FUNCTION People_Name
( X_Person_Id IN NUMBER
) return VARCHAR2 IS

L_Full_Name VARCHAR2(240);

BEGIN

  SELECT full_name into L_Full_Name
  from PER_ALL_PEOPLE_F
  where person_id = X_Person_Id
  AND   TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE
  AND   EFFECTIVE_END_DATE;

  RETURN ( L_Full_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END People_Name;


FUNCTION OE_Lookup
( X_Lookup_Code IN VARCHAR2
, X_Lookup_Type IN VARCHAR2
) return VARCHAR2 IS

L_meaning VARCHAR2(80);

BEGIN

  SELECT meaning into L_meaning
  from OE_LOOKUPS
  where Lookup_Code = X_Lookup_Code
  and   Lookup_Type = X_Lookup_Type;

  RETURN ( L_meaning );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END OE_Lookup;


FUNCTION Get_Lookup
( X_Lookup_Code IN VARCHAR2
, X_Lookup_Type IN VARCHAR2
) return VARCHAR2 IS

L_Displayed_Filed VARCHAR2(80);

BEGIN

  SELECT DISPLAYED_FIELD into L_Displayed_filed
  from po_lookup_codes
  where Lookup_Code = X_Lookup_Code
  and   Lookup_Type = X_Lookup_Type;

  RETURN ( L_Displayed_Filed );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Get_Lookup;


FUNCTION Location_Code
( X_Location_Id  IN NUMBER
) return VARCHAR2 IS

L_Location_Code VARCHAR2(60);

BEGIN

  SELECT location_code into L_Location_Code
  from hr_locations_all_tl
  where location_id = X_Location_Id
  and language = userenv('LANG');

  RETURN ( L_Location_Code );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Location_Code;


FUNCTION Vendor_Site
( X_Vendor_Id       IN NUMBER
, X_Vendor_Site_Id  IN NUMBER
) return VARCHAR2 IS

L_Vendor_Site VARCHAR2(15);

BEGIN

  SELECT VENDOR_SITE_CODE into L_Vendor_Site
  from PO_VENDOR_SITES_ALL
  where vendor_id = X_Vendor_id
  and vendor_site_id = X_Vendor_Site_Id;

  RETURN ( L_Vendor_Site );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Vendor_Site;


FUNCTION Vendor_Name
( X_Vendor_Id  IN NUMBER
) return VARCHAR2 IS

L_Vendor_Name VARCHAR2(360);

BEGIN

  SELECT vendor_name into L_Vendor_Name
  from po_vendors
  where vendor_id = X_Vendor_id;

  RETURN ( L_Vendor_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Vendor_Name;


FUNCTION PO_Type
( X_Org_Id   IN NUMBER
) return VARCHAR2 IS

L_Type_Name VARCHAR2(80);

BEGIN

SELECT T.TYPE_NAME into L_Type_Name
from PO_DOCUMENT_TYPES_ALL_TL T
WHERE T.LANGUAGE = userenv('LANG')
   and T.DOCUMENT_TYPE_CODE IN ('PO', 'PA')
AND  T.DOCUMENT_SUBTYPE  = 'STANDARD'
and T.org_id = X_Org_Id;

  RETURN ( L_Type_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END PO_Type;


FUNCTION OE_Order_Total
( X_Header_ID      IN NUMBER,
  x_project_id  IN NUMBER DEFAULT NULL,
  x_task_id   IN NUMBER DEFAULT NULL,
  x_line_id   IN NUMBER DEFAULT NULL
) return number IS
/* Refer to FP bug 8525770, add project id, task id and line id as parameters */
L_Order_Total number;

BEGIN

  -- Bug 5465876: RMA order should show negative amount
  SELECT SUM( decode(line_category_code,'RETURN',
                     (-1)*(NVL(ordered_quantity,0)-NVL(cancelled_quantity,0)),
                          (NVL(ordered_quantity,0)-NVL(cancelled_quantity,0))
                    )
              * NVL(unit_selling_price , 0) )
  INTO   L_Order_Total
  FROM   oe_order_lines_all
  WHERE  header_id = X_Header_ID
   AND   project_id = NVL(x_project_id, project_id)
   AND   task_id = NVL(x_task_id,  task_id)
   AND   line_id = x_line_id;
/* Refer to FP bug 8525770 */


  RETURN ( L_Order_Total );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END OE_Order_Total;


FUNCTION OE_Org_Address
( X_Org_ID         IN NUMBER
, X_Org_Type       IN VARCHAR2
) return varchar2 IS

L_Org_Address varchar2(2000);

BEGIN

  IF ( X_Org_Type = 'BILL TO' ) THEN

    SELECT decode(loc.city , null , null , loc.city || ', ')
        || decode(loc.postal_code ,  null , null , loc.postal_code || ', ')
        || decode(loc.country ,      null , null , loc.country)
    INTO   L_Org_Address
    FROM   hz_cust_site_uses_all site
	, hz_locations loc
	, hz_party_sites party_site
        , hz_cust_acct_sites_all acct_site
    WHERE  site.site_use_id = X_Org_ID
    AND  site.cust_acct_site_id = acct_site.cust_acct_site_id
    AND  acct_site.party_site_id = party_site.party_site_id
    AND  party_site.location_id = loc.location_id
    AND  nvl(site.org_id, -99 )  = nvl( acct_site.org_id, -99 );

  ELSIF ( X_Org_Type = 'SHIP TO' ) THEN

    SELECT decode(loc.city , null , null , loc.city || ', ')
        || decode(loc.postal_code ,  null , null , loc.postal_code || ', ')
        || decode(loc.country ,      null , null , loc.country)
    INTO   L_Org_Address
    FROM   hz_cust_site_uses_all site
	, hz_locations loc
	, hz_party_sites party_site
        , hz_cust_acct_sites_all acct_site
    WHERE  site.site_use_id = X_Org_ID
    AND  site.cust_acct_site_id = acct_site.cust_acct_site_id
    AND  acct_site.party_site_id = party_site.party_site_id
    AND  party_site.location_id = loc.location_id
    AND  nvl(site.org_id, -99 )  = nvl( acct_site.org_id, -99 );
  END IF;

  RETURN ( L_Org_Address );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END OE_Org_Address;

--
--  Note : The cached values are shared between Yes_No and
--         Sys_Yes_No as the text is extremely unlikely to
--         differ between the two lookups.
--
FUNCTION Yes_No
( X_Lookup_Code    IN VARCHAR2
) return varchar2 IS

CURSOR c IS
  SELECT meaning
  FROM   fnd_lookups
  WHERE  lookup_type = 'YES_NO'
  AND    lookup_code = X_Lookup_Code;

BEGIN

  IF ( X_Lookup_Code = 'Y' ) THEN
    IF ( G_Yes IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_Yes;
      CLOSE c;
    END IF;
    RETURN ( G_Yes );
  ELSIF ( X_Lookup_Code = 'N' ) THEN
    IF ( G_No IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_No;
      CLOSE c;
    END IF;
    RETURN ( G_No );
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF ( c%ISOPEN ) THEN
    CLOSE c;
  END IF;
  RETURN ( NULL );

END Yes_No;


FUNCTION Sys_Yes_No
( X_Lookup_Code    IN NUMBER
) return varchar2 IS

CURSOR c IS
  SELECT meaning
  FROM   mfg_lookups
  WHERE  lookup_type = 'SYS_YES_NO'
  AND    lookup_code = X_Lookup_Code;

BEGIN

  IF ( X_Lookup_Code = 'Y' ) THEN
    IF ( G_Yes IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_Yes;
      CLOSE c;
    END IF;
    RETURN ( G_Yes );
  ELSIF ( X_Lookup_Code = 'N' ) THEN
    IF ( G_No IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_No;
      CLOSE c;
    END IF;
    RETURN ( G_No );
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF ( c%ISOPEN ) THEN
    CLOSE c;
  END IF;
  RETURN ( NULL );

END Sys_Yes_No;


FUNCTION Locator_Control
( X_Lookup_Code    IN NUMBER
) return varchar2 IS

L_Return_Value   VARCHAR2(80);

BEGIN

  SELECT meaning
  INTO   L_Return_Value
  FROM   mfg_lookups
  WHERE  lookup_type = 'MTL_LOCATION_CONTROL'
  AND    lookup_code = X_Lookup_Code;

  RETURN ( L_Return_Value );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Locator_Control;


FUNCTION Component_Serial
( X_Organization_ID  IN NUMBER
, X_Wip_Entity_ID    IN NUMBER
, X_Op_Seq_Num       IN NUMBER
, X_Item_ID          IN NUMBER
) return varchar2 is

L_Return_Value  VARCHAR2(4000);

CURSOR c IS
  SELECT mut.serial_number
  FROM   mtl_unit_transactions mut
  ,      mtl_material_transactions mmt
  WHERE  mmt.inventory_item_id          = X_Item_ID
  AND    mmt.organization_id            = X_Organization_ID
  AND    mmt.transaction_source_type_id = 5
  AND    mmt.transaction_source_id      = X_Wip_Entity_ID
  AND    mmt.operation_seq_num          = X_Op_Seq_Num
  AND    mmt.transaction_type_id in (35 , 38 , 43 , 48)
  AND    mut.transaction_id             = mmt.transaction_id
  AND    mut.inventory_item_id          = X_Item_ID
  AND    mut.organization_id            = X_Organization_ID
  AND    mut.transaction_source_type_id = 5
  AND    mut.transaction_source_id      = X_Wip_Entity_ID
  GROUP BY mut.serial_number
  HAVING sum(sign(mmt.primary_quantity)) < 0
  ORDER BY mut.serial_number;

BEGIN

  L_Return_Value := NULL;

  FOR crec IN c LOOP
    IF L_Return_Value IS NULL THEN
      L_Return_Value := crec.serial_number;
    ELSE
      L_Return_Value := L_Return_Value || ' , ' || crec.serial_number;
    END IF;
  END LOOP;

  RETURN( L_Return_Value );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Component_Serial;


function TRANSACTION_SOURCE_NAME
( X_Trx_Src_Type_ID  IN NUMBER
, X_Trx_Source_ID    IN NUMBER
) return varchar2 is

CURSOR c1 IS
  SELECT segment1
  FROM   po_headers_all
  WHERE  po_header_id = X_Trx_Source_ID;

CURSOR c2 IS
  SELECT substr(concatenated_segments , 1 , 240)
  FROM   mtl_sales_orders_kfv
  WHERE  sales_order_id = X_Trx_Source_ID;

CURSOR c3 IS
  SELECT k_number_disp
  FROM   oke_k_headers_v
  WHERE  k_header_id = X_Trx_Source_ID;

Trx_Source_Name   VARCHAR2(4000);

BEGIN

  IF ( X_Trx_Src_Type_ID = 1 ) THEN
    OPEN c1;
    FETCH c1 INTO Trx_Source_Name;
    CLOSE c1;
  ELSIF ( X_Trx_Src_Type_ID in ( 2 , 8 , 12 ) ) THEN
    OPEN c2;
    FETCH c2 INTO Trx_Source_Name;
    CLOSE c2;
  ELSIF ( X_Trx_Src_Type_ID = 16 ) THEN
    OPEN c3;
    FETCH c3 INTO Trx_Source_Name;
    CLOSE c3;
  ELSE
    Trx_Source_Name := NULL;
  END IF;

  RETURN( Trx_Source_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN( NULL );
END TRANSACTION_SOURCE_NAME;


end PJM_INQUIRY;

/
