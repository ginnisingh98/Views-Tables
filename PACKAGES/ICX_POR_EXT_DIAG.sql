--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_DIAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_DIAG" AUTHID CURRENT_USER AS
/* $Header: ICXEXTDS.pls 115.8 2004/03/31 18:46:15 vkartik ship $*/

INVALID_BUSINESS_GROUP		PLS_INTEGER := -1;
INVALID_OPERATING_UNIT		PLS_INTEGER := -2;
INVALID_TYPE			PLS_INTEGER := -3;
INVALID_CATEGORY		PLS_INTEGER := -4;
INVALID_TEMPLATE_HEADER		PLS_INTEGER := -5;
INVALID_TEMPLATE_LINE		PLS_INTEGER := -6;
INVALID_BLANKET_LINE		PLS_INTEGER := -7;
INVALID_QUOTATION_LINE		PLS_INTEGER := -8;
INVALID_ASL			PLS_INTEGER := -9;
INVALID_ITEM			PLS_INTEGER := -10;

VALID_FOR_EXTRACT		PLS_INTEGER := 0;
/* Diagnostic messages for not extracted item
 1. The following item was not extracted from the requisition template
    because the inactive date of the template is earlier than today:
    [ITEM_NUMBER]. To extract this item, the date must be tomorrow or
    later. The item exists on the following template: [TEMPLATE_NAME].
    The template exists in the following operating unit:
    [OPERATING_UNIT_NAME].
 2. The following item was not extracted from the requisition template
    because the template was copied from an unapproved, cancelled, closed,
    finally closed, or frozen blanket purchase agreement: [ITEM_NUMBER].
    The item exists on the following template: [TEMPLATE_NAME]. The
    template exists in the following operating unit: [OPERATING_UNIT_NAME].
 3. The following item was not extracted from the requisition template
    because the template was copied from a blanket purchase agreements
    whose header effective dates do not include today: [ITEM_NUMBER]. The
    item exists on the following template: [TEMPLATE_NAME]. The template
    exists in the following operating unit: [OPERATING_UNIT_NAME].
 4. The following item was not extracted from the requisition template
    because the blanket purchase agreement line from which the template was
    copied is expired, cancelled, closed, or finally closed: [ITEM_NUMBER].
    The item exists on the following template: [TEMPLATE_NAME]. The template
    exists in the following operating unit: [OPERATING_UNIT_NAME].
 5. The following item was not extracted from the requisition template
    because the line type of the blanket purchase agreement line from which
    the template was copied is for outside processing: [ITEM_NUMBER]. The
    item exists on the following template: [TEMPLATE_NAME]. The template
    exists in the following operating unit: [OPERATING_UNIT_NAME].
 6. The following item was not extracted from the blanket purchase agreement
    because the agreement is unapproved, cancelled, closed, finally closed,
    or frozen: [ITEM_NUMBER]. The agreement number is [AGREEMENT_NUMBER].
    The agreement exists in the following operating unit:
    [OPERATING_UNIT_NAME].
 7. The following item was not extracted from the blanket purchase agreement
    because the header effective dates do not include today: [ITEM_NUMBER].
    The agreement number is [AGREEMENT_NUMBER]. The agreement exists in the
    following operating unit: [OPERATING_UNIT_NAME].
 8. The following item was not extracted from the blanket purchase agreement
    because the agreement line is expired, cancelled, closed, or finally
    closed: [ITEM_NUMBER]. The agreement number is [AGREEMENT_NUMBER]. The
    agreement exists in the following operating unit: [OPERATING_UNIT_NAME].
 9. The following item was not extracted from the blanket purchase agreement
    because the agreement line type is for outside processing: [ITEM_NUMBER].
    The agreement number is [AGREEMENT_NUMBER]. The agreement exists in the
    following operating unit: [OPERATING_UNIT_NAME].
10. The following item was not extracted from the quotation because the
    quotation is not a catalog quotation with an active status: [ITEM_NUMBER].
    The quotation number is [QUOTATION_NUMBER]. The quotation exists in the
    following operating unit: [OPERATING_UNIT_NAME].
11. The following item was not extracted from the quotation because the
    quotation is not approved for requisitions: [ITEM_NUMBER]. To extract
    the item, the quotation must have an effective price break that is
    approved for 'All Orders' or 'Requisitions'. The quotation number is
    [QUOTATION_NUMBER]. The quotation exists in the following operating
    unit: [OPERATING_UNIT_NAME].
12. The following item was not extracted from the quotation because the
    header effective dates do not include today: [ITEM_NUMBER]. The
    quotation number is [QUOTATION_NUMBER].  The quotation exists in the
    following operating unit:  [OPERATING_UNIT_NAME].
13. The following item was not extracted from the approved supplier list(ASL)
    because the ASL entry is disabled for the supplier: [ITEM_NUMBER].
    The inventory organization for the item is: [INVENTORY_ORGANIZATION].
    The supplier is: [SUPPLIER_NAME].
14. The following item was not extracted from the approved supplier list(ASL)
    because the ASL entry for the item indicates the supplier is not allowed
    to source the item: [ITEM_NUMBER]. To extract the item from the ASL,
    the status and business rules for the entry need to indicate the supplier
    is allowed to source the item. The inventory organization for the item is:
    [INVENTORY_ORGANIZATION]. The supplier is: [SUPPLIER_NAME].
15. The following item was not extracted from the approved supplier list
    because there is no list price defined for the item: [ITEM_NUMBER].
    The item exists in the following inventory organization:
    [INVENTORY_ORGANIZATION]. The supplier is: [SUPPLIER_NAME].
16. The following item was not extracted because the item is either not
    defined as purchasable or is an outside processing item: [ITEM_NUMBER].
    The item exists in the following inventory organization:
    [INVENTORY_ORGANIZATION].
17. The following item was not extracted because the item is not defined
    as internally orderable: [ITEM_NUMBER].  The item exists in the
    following inventory organization: [INVENTORY_ORGANIZATION].
18. The following item was not extracted because the item is not defined
    as purchasable or internally orderable: [ITEM_NUMBER].  The item exists
    in the following inventory organization: [INVENTORY_ORGANIZATION].
19. The following item was not extracted because there is no list price
    defined for the item: [ITEM_NUMBER]. The item exists in the following
    inventory organization: [INVENTORY_ORGANIZATION].
20. The following item was not extracted because the category to which
    it belongs has not yet been extracted: [ITEM_NUMBER]. Extract the
    following category first: [ITEM_CATEGORY]. Then extract the item.
    The item exists in the following operating unit:
    [OPERATING_UNIT_NAME].
21. The following item was not extracted from the requisition template
    because the template header has not yet been extracted: [ITEM_NUMBER].
    Extract the following template header first: [TEMPLATE_NAME]. Then
    extract the item. The template exists in the following operating unit:
    [OPERATING_UNIT_NAME].
22. The following item was not extracted from the global agreement:
    [ITEM_NUMBER], because the agreement is not enabled in the following
    operating unit: [OPERATING_UNIT_NAME]. The agreement number is
    [AGREEMENT_NUMBER].
23. The following item was not extracted from the global agreement:
    [ITEM_NUMBER], because the supplier site [SUPPLIER_SITE_CODE] is
    invalid in the following operating unit:
    [OPERATING_UNIT_NAME]. The agreement number is [AGREEMENT_NUMBER].
24. The following item was not extracted from the global agreement:
    [ITEM_NUMBER], because the item is invalid in the following operating
    unit: [OPERATING_UNIT_NAME]. The agreement number is [AGREEMENT_NUMBER].
*/
INACTIVE_TEMPLATE		PLS_INTEGER := 1;
TEMPLATE_INACTIVE_BLANKET	PLS_INTEGER := 2;
TEMPLATE_INEFFECTIVE_BLANKET	PLS_INTEGER := 3;
TEMPLATE_INACTIVE_BLANKET_LINE	PLS_INTEGER := 4;
TEMPLATE_OUTSIDE_BLANKET	PLS_INTEGER := 5;
INACTIVE_BLANKET		PLS_INTEGER := 6;
INEFFECTIVE_BLANKET		PLS_INTEGER := 7;
INACTIVE_BLANKET_LINE		PLS_INTEGER := 8;
OUTSIDE_BLANKET			PLS_INTEGER := 9;
INACTIVE_QUOTATION		PLS_INTEGER := 10;
QUOTATION_NO_EFFECTIVE_PRICE	PLS_INTEGER := 11;
INEFFECTIVE_QUOTATION		PLS_INTEGER := 12;
DISABLED_ASL			PLS_INTEGER := 13;
UNALLOWED_ASL			PLS_INTEGER := 14;
ASL_NO_PRICE			PLS_INTEGER := 15;
UNPURCHASABLE_OUTSIDE		PLS_INTEGER := 16;
NOTINTERNAL			PLS_INTEGER := 17;
UNPURCHASABLE_NOTINTERNAL	PLS_INTEGER := 18;
ITEM_NO_PRICE			PLS_INTEGER := 19;
CATEGORY_NOT_EXTRACTED		PLS_INTEGER := 20;
TEMPLATE_HEADER_NOT_EXTRACTED	PLS_INTEGER := 21;
GLOBAL_AGREEMENT_DISABLED	PLS_INTEGER := 22;
GLOBAL_AGREEMENT_INVALID_SITE	PLS_INTEGER := 23;
GLOBAL_AGREEMENT_INVALID_ITEM	PLS_INTEGER := 24;
GLOBAL_AGREEMENT_INVALID_UOM 	PLS_INTEGER := 25;

-- Not Extracted Category
NOT_WEBENABLED_CATEGORY		PLS_INTEGER := 30;
INACTIVE_CATEGORY		PLS_INTEGER := 31;
INVALID_CATEGORY_SET		PLS_INTEGER := 32;
INACTIVE_TEMPLATE_HEADER	PLS_INTEGER := 33;

--------------------------------------------------------------
--                  Construct Message Procedures            --
--------------------------------------------------------------
-- Get operating unit name
FUNCTION getOperatingUnit(pOperatingUnitId	IN NUMBER)
  RETURN VARCHAR2;

-- Get inventory organization name
FUNCTION getInventoryOrg(pInventoryOrgId	IN NUMBER)
  RETURN VARCHAR2;

-- Construct message, usually pOrgName carries Operating Unit or
-- Inventory Organization, pDocName carries document number, and
-- pExtraValue carries line number, item number or description,
-- or supplier site code.
FUNCTION constructMessage(pStatus		IN NUMBER,
			  pOrgName		IN VARCHAR2,
			  pDocName		IN VARCHAR2,
			  pExtraValue		IN VARCHAR2,
			  pExtraValue2		IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

FUNCTION getPriceReport(p_document_type		IN VARCHAR2,
                        p_org_id		IN NUMBER,
                        p_inventory_organization_id IN NUMBER,
                        p_status		IN NUMBER,
                        p_contract_num		IN VARCHAR2,
                        p_internal_item_num	IN VARCHAR2,
                        p_description		IN VARCHAR2,
                        p_supplier_site_code	IN VARCHAR2,
                        p_template_id		IN VARCHAR2,
                        p_supplier		IN VARCHAR2,
                        p_supplier_part_num	IN VARCHAR2)
  RETURN VARCHAR2;
--------------------------------------------------------------
--                     Main Check Procedures                --
--------------------------------------------------------------
-- Check classification status
FUNCTION checkClassStatus(pType			IN  VARCHAR2,
                          pValue		IN  VARCHAR2,
                          pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER;

FUNCTION checkClassStatus(pType			IN  VARCHAR2,
                          pValue		IN  VARCHAR2)
  RETURN VARCHAR2;

-- Check item status
FUNCTION checkItemStatus(pOperatingUnitId	IN  NUMBER,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2,
                         pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER;

FUNCTION checkItemStatus(pBusinessGroup		IN  VARCHAR2,
                         pOperatingUnit		IN  VARCHAR2,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2,
                         pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER;
FUNCTION checkItemStatus(pOperatingUnitId	IN  NUMBER,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2)
  RETURN VARCHAR2;

FUNCTION checkItemStatus(pBusinessGroup		IN  VARCHAR2,
                         pOperatingUnit		IN  VARCHAR2,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2)
  RETURN VARCHAR2;

FUNCTION getStatusString(pStatus		IN NUMBER)
  RETURN VARCHAR2;

FUNCTION getContractLineStatus(p_contract_line_id		IN NUMBER,
                               p_test_mode			IN VARCHAR2)
  RETURN NUMBER;

-- Centralized Procurement Impacts project # pcreddy
-- Pass the values for purchasing_org's purchasing_enabled flag,
-- outside_operation flag and uom_code
FUNCTION getGlobalAgreementStatus(p_enabled_flag		IN VARCHAR2,
                                  p_purchasing_site		IN VARCHAR2,
                                  p_inactive_date		IN DATE,
                                  p_local_purchasing_enabled	IN VARCHAR2,
                                  p_local_outside_operation	IN VARCHAR2,
                                  p_local_uom_code		IN VARCHAR2,
                                  p_purchasing_enabled		IN VARCHAR2,
                                  p_outside_operation		IN VARCHAR2,
                                  p_uom_code			IN VARCHAR2,
                                  p_purchasing_uom_code		IN VARCHAR2,
                                  p_test_mode			IN VARCHAR2)
  RETURN NUMBER;

--Bug#3464695
FUNCTION getTemplateLineStatus(p_template_id		IN VARCHAR2,
                               p_template_line_id	IN NUMBER,
                               p_org_id			IN NUMBER,
                               p_inactive_date		IN DATE,
                               p_contract_line_id	IN NUMBER,
                               p_test_mode		IN VARCHAR2)
  RETURN NUMBER;

--Bug#3464695
FUNCTION getASLStatus(p_asl_id			IN NUMBER,
                      p_disable_flag		IN VARCHAR2,
                      p_asl_status_id		IN NUMBER,
                      p_item_price		IN NUMBER,
                      p_test_mode		IN VARCHAR2)
  RETURN NUMBER;
FUNCTION getPurchasingItemStatus(p_purchasing_enabled_flag	IN VARCHAR2,
                                 p_outside_operation_flag	IN VARCHAR2,
                                 p_list_price_per_unit		IN NUMBER,
                                 p_test_mode			IN VARCHAR2)
  RETURN NUMBER;
FUNCTION getInternalItemStatus(p_internal_order_enabled_flag 	IN VARCHAR2,
                               p_test_mode 		  	IN VARCHAR2)
  RETURN NUMBER;
FUNCTION getPriceStatus(p_price_type		IN VARCHAR2,
                        p_row_id		IN ROWID,
                        p_test_mode		IN VARCHAR2)
  RETURN NUMBER;
FUNCTION isValidExtPrice(pDocumentType		IN NUMBER,
                         pStatus		IN NUMBER,
                         pLoadContract		IN VARCHAR2,
                         pLoadTemplateLine	IN VARCHAR2,
                         pLoadItemMaster	IN VARCHAR2,
                         pLoadInternalItem	IN VARCHAR2)
  RETURN NUMBER;

END ICX_POR_EXT_DIAG;

 

/
