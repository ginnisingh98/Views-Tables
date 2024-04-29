--------------------------------------------------------
--  DDL for Package Body ICX_LOAD_REQ_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_LOAD_REQ_INTERFACE" as
/* $Header: ICXLREQB.pls 115.3 99/07/17 03:18:29 porting ship $ */

Procedure Load_ShopCart_To_Interface(l_cart_id IN NUMBER) as

   l_org_id number;
   l_dist_seq_id number;
   l_trans_id number;

   cursor get_cart_line_id(l_cart_id number,l_org_id number) is
     select cart_line_id
   from icx_shopping_cart_lines
   where cart_id = l_cart_id
   and nvl(org_id,-9999) = nvl(l_org_id,-9999);

Begin

-- Check if session is valid
  if (icx_sec.validatesession('ICX_REQS')) then

 l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
-- fnd_client_info.set_org_context(to_char(l_org_id));

 for prec in get_cart_line_id(l_cart_id,l_org_id) loop

     select po_ri_dist_sequence_s.nextval into l_dist_seq_id from dual;
     select po_requisitions_interface_s.nextval into l_trans_id from dual;

     insert into po_requisitions_interface
     (TRANSACTION_ID 		,
      INTERFACE_SOURCE_CODE		,
      SOURCE_TYPE_CODE		,
      REQUISITION_TYPE		,
      DESTINATION_TYPE_CODE		,
      ITEM_DESCRIPTION		,
      QUANTITY			,
      UNIT_PRICE			,
      AUTHORIZATION_STATUS		,
      APPROVER_ID			,
      NOTE_TO_APPROVER		,
      PREPARER_ID			,
      AUTOSOURCE_FLAG		,
      REQ_NUMBER_SEGMENT1		,
      NOTE_TO_BUYER			,
      ITEM_ID			,
      ITEM_REVISION			,
      CATEGORY_ID			,
      UNIT_OF_MEASURE		,
      LINE_TYPE_ID			,
      DESTINATION_ORGANIZATION_ID	,
      DELIVER_TO_LOCATION_ID 	,
      DELIVER_TO_REQUESTOR_ID	,
      SUGGESTED_BUYER_ID,
      SUGGESTED_VENDOR_NAME		,
      SUGGESTED_VENDOR_SITE		,
      SUGGESTED_VENDOR_CONTACT,
      SUGGESTED_VENDOR_PHONE,
      SUGGESTED_VENDOR_ITEM_NUM	,
      NEED_BY_DATE			,
      AUTOSOURCE_DOC_HEADER_ID	,
      AUTOSOURCE_DOC_LINE_NUM	,
      DOCUMENT_TYPE_CODE		,
      HEADER_DESCRIPTION,
      HEADER_ATTRIBUTE_CATEGORY,
      HEADER_ATTRIBUTE1,
      HEADER_ATTRIBUTE2,
      HEADER_ATTRIBUTE3,
      HEADER_ATTRIBUTE4,
      HEADER_ATTRIBUTE5,
      HEADER_ATTRIBUTE6,
      HEADER_ATTRIBUTE7,
      HEADER_ATTRIBUTE8,
      HEADER_ATTRIBUTE9,
      HEADER_ATTRIBUTE10,
      HEADER_ATTRIBUTE11,
      HEADER_ATTRIBUTE12,
      HEADER_ATTRIBUTE13,
      HEADER_ATTRIBUTE14,
      HEADER_ATTRIBUTE15,
      LINE_ATTRIBUTE_CATEGORY,
      LINE_ATTRIBUTE1,
      LINE_ATTRIBUTE2,
      LINE_ATTRIBUTE3,
      LINE_ATTRIBUTE4,
      LINE_ATTRIBUTE5,
      LINE_ATTRIBUTE6,
      LINE_ATTRIBUTE7,
      LINE_ATTRIBUTE8,
      LINE_ATTRIBUTE9,
      LINE_ATTRIBUTE10,
      LINE_ATTRIBUTE11,
      LINE_ATTRIBUTE12,
      LINE_ATTRIBUTE13,
      LINE_ATTRIBUTE14,
      LINE_ATTRIBUTE15,
      MULTI_DISTRIBUTIONS,
      REQ_DIST_SEQUENCE_ID,
      ORG_ID,
      REQUISITION_HEADER_ID,
      REQUISITION_LINE_ID,
      EMERGENCY_PO_NUM)
    select
    l_trans_id,
    'ICX',
    'VENDOR',
    'PURCHASE',
    rtrim(isc.DESTINATION_TYPE_CODE, ' '),
    rtrim(ici.ITEM_DESCRIPTION, ' ')		,
    ici.QUANTITY			,
    round(ici.UNIT_PRICE,5)			,
    'INCOMPLETE',
    isc.APPROVER_ID,
    rtrim(isc.NOTE_TO_APPROVER, ' ')		,
    hrev.employee_id,
    'N',
    rtrim(isc.REQ_NUMBER_SEGMENT1, ' '),
    rtrim(isc.NOTE_TO_BUYER, ' ')			,
    ici.ITEM_ID			,
    rtrim(ici.ITEM_REVISION, ' ')		,
-- nvl(ici.acct_id,nvl(msi.expense_account,hrev.default_code_combination_id)),
    ici.CATEGORY_ID		,
    rtrim(ici.UNIT_OF_MEASURE, ' ')		,
    ici.LINE_TYPE_ID		,
    ici.DESTINATION_ORGANIZATION_ID,
    ici.DELIVER_TO_LOCATION_ID,
    isc.DELIVER_TO_REQUESTOR_ID,
    nvl(ici.suggested_buyer_id,nvl(msi.buyer_id,poh.agent_id)),
    rtrim(ici.SUGGESTED_VENDOR_NAME, ' '),
    rtrim(ici.SUGGESTED_VENDOR_SITE, ' '),
    rtrim(ici.SUGGESTED_VENDOR_CONTACT, ' '),
    rtrim(ici.SUGGESTED_VENDOR_PHONE, ' '),
    rtrim(ici.SUGGESTED_VENDOR_ITEM_NUM, ' '),
    -- nvl(isc.need_by_date,sysdate),
    -- The above is commented. The need by date at the line level need to
    -- updated with the line level need by date. Sai 8/6/97.
    nvl(trunc(ici.need_by_date),trunc(sysdate)),
    ici.autosource_doc_header_id,
    ici.autosource_doc_line_num,
    poh.type_lookup_code,
    rtrim(isc.header_description, ' '),
    rtrim(isc.HEADER_ATTRIBUTE_CATEGORY, ' '),
    rtrim(isc.HEADER_ATTRIBUTE1, ' '),
    rtrim(isc.HEADER_ATTRIBUTE2, ' '),
    rtrim(isc.HEADER_ATTRIBUTE3, ' '),
    rtrim(isc.HEADER_ATTRIBUTE4, ' '),
    rtrim(isc.HEADER_ATTRIBUTE5, ' '),
    rtrim(isc.HEADER_ATTRIBUTE6, ' '),
-- isc.HEADER_ATTRIBUTE7,
-- The following has been commedted. The Header attribute 7 will be updated
-- with reserved_po_num if the customer has emergency po or with header
-- attribute 7 if there is no emergency PO. Sai 8/6/97.
    -- isc.RESERVED_PO_NUM,
    NVL(rtrim(isc.RESERVED_PO_NUM, ' '), rtrim(isc.HEADER_ATTRIBUTE7, ' ')),
    rtrim(isc.HEADER_ATTRIBUTE8, ' '),
    rtrim(isc.HEADER_ATTRIBUTE9, ' '),
    rtrim(isc.HEADER_ATTRIBUTE10, ' '),
    rtrim(isc.HEADER_ATTRIBUTE11, ' '),
    rtrim(isc.HEADER_ATTRIBUTE12, ' '),
    rtrim(isc.HEADER_ATTRIBUTE13, ' '),
    rtrim(isc.HEADER_ATTRIBUTE14, ' '),
    rtrim(isc.HEADER_ATTRIBUTE15, ' '),
    rtrim(ici.LINE_ATTRIBUTE_CATEGORY, ' '),
    rtrim(ici.LINE_ATTRIBUTE1, ' '),
    rtrim(ici.LINE_ATTRIBUTE2, ' '),
    rtrim(ici.LINE_ATTRIBUTE3, ' '),
    rtrim(ici.LINE_ATTRIBUTE4, ' '),
    rtrim(ici.LINE_ATTRIBUTE5, ' '),
    rtrim(ici.LINE_ATTRIBUTE6, ' '),
    rtrim(ici.LINE_ATTRIBUTE7, ' '),
    rtrim(ici.LINE_ATTRIBUTE8, ' '),
    rtrim(ici.LINE_ATTRIBUTE9, ' '),
    rtrim(ici.LINE_ATTRIBUTE10, ' '),
    rtrim(ici.LINE_ATTRIBUTE11, ' '),
    rtrim(ici.LINE_ATTRIBUTE12, ' '),
    rtrim(ici.LINE_ATTRIBUTE13, ' '),
    rtrim(ici.LINE_ATTRIBUTE14, ' '),
    rtrim(ici.LINE_ATTRIBUTE15, ' '),
    'Y',
    l_dist_seq_id,
    l_org_id,
    isc.cart_id,
    ici.cart_line_id,
    rtrim(isc.RESERVED_PO_NUM, ' ')
    from icx_shopping_carts isc,
       icx_shopping_cart_lines ici,
       mtl_system_items msi,
       po_headers poh,
       hr_employees_current_v hrev,
       FND_USER fwu
   where isc.shopper_id = fwu.user_id
   and   isc.saved_flag = '0'
   and   ici.cart_id = isc.cart_id
   and   ici.autosource_doc_header_id = poh.po_header_id (+)
   and   ici.item_id = msi.inventory_item_id (+)
   and   ici.destination_organization_id = msi.organization_id (+)
   and   fwu.employee_id = hrev.employee_id
   and   isc.cart_id = l_cart_id
   and   ici.cart_line_id = prec.cart_line_id
   and   nvl(isc.org_id, -9999)  = nvl(l_org_id, -9999);


   insert into po_req_dist_interface (
-- ? DIST_ATTRIBUTE_CATEGORY,
    TRANSACTION_ID,
    CHARGE_ACCOUNT_ID,
    CHARGE_ACCOUNT_SEGMENT1,
    CHARGE_ACCOUNT_SEGMENT2,
    CHARGE_ACCOUNT_SEGMENT3,
    CHARGE_ACCOUNT_SEGMENT4,
    CHARGE_ACCOUNT_SEGMENT5,
    REQ_NUMBER_SEGMENT1,
-- ? EXPENDITURE_TYPE,
    DESTINATION_ORGANIZATION_ID,
    DISTRIBUTION_ATTRIBUTE1,
    DISTRIBUTION_ATTRIBUTE2,
    DISTRIBUTION_ATTRIBUTE3,
    DISTRIBUTION_ATTRIBUTE4,
    DISTRIBUTION_ATTRIBUTE5,
    DISTRIBUTION_ATTRIBUTE6,
    DISTRIBUTION_ATTRIBUTE7,
    DISTRIBUTION_ATTRIBUTE8,
    DISTRIBUTION_ATTRIBUTE9,
    DISTRIBUTION_ATTRIBUTE10,
    DISTRIBUTION_ATTRIBUTE11,
    DISTRIBUTION_ATTRIBUTE12,
    DISTRIBUTION_ATTRIBUTE13,
    DISTRIBUTION_ATTRIBUTE14,
    DISTRIBUTION_ATTRIBUTE15,
    ACCRUAL_ACCOUNT_ID,
    VARIANCE_ACCOUNT_ID,
    BUDGET_ACCOUNT_ID,
-- ? PROCESS_FLAG,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    INTERFACE_SOURCE_CODE,
-- ? INTERFACE_SOURCE_LINE_ID,
    -- REQ_DISTRIBUTION_ID,
    DESTINATION_TYPE_CODE,
-- ? QUANTITY,
    CHARGE_ACCOUNT_SEGMENT6,
    CHARGE_ACCOUNT_SEGMENT7,
    CHARGE_ACCOUNT_SEGMENT8,
    CHARGE_ACCOUNT_SEGMENT9,
    CHARGE_ACCOUNT_SEGMENT10,
    CHARGE_ACCOUNT_SEGMENT11,
    CHARGE_ACCOUNT_SEGMENT12,
    CHARGE_ACCOUNT_SEGMENT13,
    CHARGE_ACCOUNT_SEGMENT14,
    CHARGE_ACCOUNT_SEGMENT15,
    CHARGE_ACCOUNT_SEGMENT16,
    CHARGE_ACCOUNT_SEGMENT17,
    CHARGE_ACCOUNT_SEGMENT18,
    CHARGE_ACCOUNT_SEGMENT19,
    CHARGE_ACCOUNT_SEGMENT20,
    CHARGE_ACCOUNT_SEGMENT21,
    CHARGE_ACCOUNT_SEGMENT22,
    CHARGE_ACCOUNT_SEGMENT23,
    CHARGE_ACCOUNT_SEGMENT24,
    CHARGE_ACCOUNT_SEGMENT25,
    CHARGE_ACCOUNT_SEGMENT26,
    CHARGE_ACCOUNT_SEGMENT27,
    CHARGE_ACCOUNT_SEGMENT28,
    CHARGE_ACCOUNT_SEGMENT29,
    CHARGE_ACCOUNT_SEGMENT30,
    ORG_ID,
    DIST_SEQUENCE_ID,
    ITEM_ID,
    ALLOCATION_TYPE,
    ALLOCATION_VALUE,
    DISTRIBUTION_NUMBER)
  SELECT
    po_req_dist_interface_s.nextval,
    icd.CHARGE_ACCOUNT_ID,
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT1, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT2, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT3, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT4, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT5, ' '),
    rtrim(isc.REQ_NUMBER_SEGMENT1, ' '),
    ici.DESTINATION_ORGANIZATION_ID,
    rtrim(icd.DISTRIBUTION_ATTRIBUTE1, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE2, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE3, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE4, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE5, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE6, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE7, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE8, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE9, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE10, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE11, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE12, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE13, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE14, ' '),
    rtrim(icd.DISTRIBUTION_ATTRIBUTE15, ' '),
    icd.ACCRUAL_ACCOUNT_ID,
    icd.VARIANCE_ACCOUNT_ID,
    icd.BUDGET_ACCOUNT_ID,
    icd.LAST_UPDATED_BY,
    icd.LAST_UPDATE_DATE,
    icd.LAST_UPDATE_LOGIN,
    icd.CREATION_DATE,
    icd.CREATED_BY,
    'ICX',
    -- icd.DISTRIBUTION_ID,
    rtrim(isc.DESTINATION_TYPE_CODE, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT6, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT7, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT8, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT9, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT10, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT11, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT12, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT13, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT14, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT15, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT16, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT17, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT18, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT19, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT20, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT21, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT22, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT23, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT24, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT25, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT26, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT27, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT28, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT29, ' '),
    rtrim(icd.CHARGE_ACCOUNT_SEGMENT30, ' '),
    icd.ORG_ID,
    l_dist_seq_id,
    ici.ITEM_ID,
    icd.ALLOCATION_TYPE,
    icd.ALLOCATION_VALUE,
    icd.DISTRIBUTION_NUM
   from icx_shopping_carts isc,
     icx_shopping_cart_lines ici,
     icx_cart_line_distributions icd
   where isc.saved_flag = '0'
    and  isc.cart_id = ici.cart_id
    and  ici.cart_id = icd.cart_id
    and  ici.cart_line_id = icd.cart_line_id
    and  isc.cart_id = l_cart_id
    and  ici.cart_line_id = prec.cart_line_id
    and  nvl(isc.org_id,-9999) = nvl(l_org_id,-9999);

  end loop;

end if;

EXCEPTION
    When Others Then
       po_message_s.sql_error('Load_ShopCart_To_Interface', 1, sqlcode);
       RAISE;

End Load_ShopCart_TO_Interface;

End ICX_LOAD_REQ_INTERFACE;

/
