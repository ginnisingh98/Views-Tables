--------------------------------------------------------
--  DDL for Package Body QP_BULK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_UTIL" AS
/* $Header: QPXBUTLB.pls 120.12.12010000.3 2009/05/07 07:11:30 dnema ship $ */

PROCEDURE LOAD_INS_HEADER
( P_REQUEST_ID	IN		NUMBER
 ,X_HEADER_REC	OUT NOCOPY	QP_BULK_LOADER_PUB.HEADER_REC_TYPE
)
IS

CURSOR C_PL_HEADER IS
SELECT list_header_id
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,program_application_id
       ,program_id
       ,program_update_date
       ,request_id
       ,list_type_code
       --,fnd_date.date_to_canonical(start_date_active) -- rnayani 5138015 -- gtippire 4440794
       --,fnd_date.date_to_canonical(end_date_active) -- rnayani 5138015 -- gtippire 4440794
       ,start_date_active -- rnayani 5138015
       ,end_date_active -- rnayani 5138015
       ,source_lang
       ,automatic_flag
       ,name
       ,description
       ,currency_code
       ,version_no
       ,rounding_factor
       ,ship_method_code
       ,freight_terms_code
       ,terms_id
       ,comments
       ,discount_lines_flag
       ,gsa_indicator
       ,prorate_flag
       ,source_system_code
       ,ask_for_flag
       ,active_flag
       ,parent_list_header_id
       ,active_date_first_type
       ,start_date_active_first
       ,end_date_active_first
       ,active_date_second_type
       ,start_date_active_second
       ,end_date_active_second
       ,context
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,language
       ,process_id
       ,process_type
       ,interface_action_code
       ,lock_flag
       ,process_flag
       ,delete_flag
       ,process_status_flag
       ,mobile_download
       ,currency_header_id
       ,pte_code
       ,list_source_code
       ,orig_sys_header_ref
       ,orig_org_id
       ,global_flag
FROM   qp_interface_list_headers
WHERE  request_id = p_request_id
AND    process_status_flag = 'P' --IS NULL
AND    interface_action_code='INSERT';

   BEGIN
      qp_bulk_loader_pub.write_log('Entering Loading Ins Header');
      OPEN C_PL_HEADER;
      FETCH C_PL_HEADER BULK COLLECT
      INTO x_header_rec.list_header_id
	   ,x_header_rec.creation_date
	   ,x_header_rec.created_by
	   ,x_header_rec.last_update_date
	   ,x_header_rec.last_updated_by
	   ,x_header_rec.last_update_login
	   ,x_header_rec.program_application_id
	   ,x_header_rec.program_id
	   ,x_header_rec.program_update_date
	   ,x_header_rec.request_id
	   ,x_header_rec.list_type_code
	   ,x_header_rec.start_date_active
	   ,x_header_rec.end_date_active
	   ,x_header_rec.source_lang
	   ,x_header_rec.automatic_flag
	   ,x_header_rec.name
	   ,x_header_rec.description
	   ,x_header_rec.currency_code
	   ,x_header_rec.version_no
	   ,x_header_rec.rounding_factor
	   ,x_header_rec.ship_method_code
	   ,x_header_rec.freight_terms_code
	   ,x_header_rec.terms_id
	   ,x_header_rec.comments
	   ,x_header_rec.discount_lines_flag
	   ,x_header_rec.gsa_indicator
	   ,x_header_rec.prorate_flag
	   ,x_header_rec.source_system_code
	   ,x_header_rec.ask_for_flag
	   ,x_header_rec.active_flag
	   ,x_header_rec.parent_list_header_id
	   ,x_header_rec.active_date_first_type
	   ,x_header_rec.start_date_active_first
	   ,x_header_rec.end_date_active_first
	   ,x_header_rec.active_date_second_type
	   ,x_header_rec.start_date_active_second
	   ,x_header_rec.end_date_active_second
	   ,x_header_rec.context
	   ,x_header_rec.attribute1
	   ,x_header_rec.attribute2
	   ,x_header_rec.attribute3
	   ,x_header_rec.attribute4
	   ,x_header_rec.attribute5
	   ,x_header_rec.attribute6
	   ,x_header_rec.attribute7
	   ,x_header_rec.attribute8
	   ,x_header_rec.attribute9
	   ,x_header_rec.attribute10
	   ,x_header_rec.attribute11
	   ,x_header_rec.attribute12
	   ,x_header_rec.attribute13
	   ,x_header_rec.attribute14
	   ,x_header_rec.attribute15
	   ,x_header_rec.language
	   ,x_header_rec.process_id
	   ,x_header_rec.process_type
	   ,x_header_rec.interface_action_code
	   ,x_header_rec.lock_flag
	   ,x_header_rec.process_flag
	   ,x_header_rec.delete_flag
	   ,x_header_rec.process_status_flag
	   ,x_header_rec.mobile_download
	   ,x_header_rec.currency_header_id
	   ,x_header_rec.pte_code
	   ,x_header_rec.list_source_code
	   ,x_header_rec.orig_sys_header_ref
	   ,x_header_rec.orig_org_id
	   ,x_header_rec.global_flag;

      CLOSE C_PL_HEADER;

       qp_bulk_loader_pub.write_log('Leaving Loading Ins Header');

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.LOAD_INS_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.LOAD_INS_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END LOAD_INS_HEADER;

PROCEDURE LOAD_UDT_HEADER
( P_REQUEST_ID	IN		NUMBER
 ,X_HEADER_REC	OUT NOCOPY	QP_BULK_LOADER_PUB.HEADER_REC_TYPE
)
IS


CURSOR C_PL_HEADER IS
SELECT /*+ LEADING(a) */ --bug8359604
       a.list_header_id,
       a.creation_date,
       a.created_by,
       a.last_update_date,
       a.last_updated_by,
       a.last_update_login,
       a.program_application_id,
       a.program_id,
       a.program_update_date,
       a.request_id,
       a.list_type_code,
       a.start_date_active,
       a.end_date_active,
       a.source_lang,
       a.automatic_flag,
       a.name,
       a.description,
       a.currency_code,
       a.version_no,
       a.rounding_factor,
       a.ship_method_code,
       a.freight_terms_code,
       a.terms_id,
       a.comments,
       a.discount_lines_flag,
       a.gsa_indicator,
       a.prorate_flag,
       a.source_system_code,
       a.ask_for_flag,
       a.active_flag,
       a.parent_list_header_id,
       a.active_date_first_type,
       a.start_date_active_first,
       a.end_date_active_first,
       a.active_date_second_type,
       a.start_date_active_second,
       a.end_date_active_second,
       a.context,
       a.attribute1,
       a.attribute2,
       a.attribute3,
       a.attribute4,
       a.attribute5,
       a.attribute6,
       a.attribute7,
       a.attribute8,
       a.attribute9,
       a.attribute10,
       a.attribute11,
       a.attribute12,
       a.attribute13,
       a.attribute14,
       a.attribute15,
       a.language,
       process_id,
       process_type,
       interface_action_code,
       lock_flag,
       process_flag,
       delete_flag,
       process_status_flag,
       a.mobile_download,
       a.currency_header_id,
       a.pte_code,
       a.list_source_code,
       a.orig_sys_header_ref,
       a.orig_org_id,
       a.global_flag
FROM   qp_interface_list_headers a, qp_list_headers_vl b
-- ENH undo alcoa changes RAVI
/**
The key between interface and qp tables is only orig_sys_hdr_ref
(not list_header_id)
**/
WHERE  a.orig_sys_header_ref = b.orig_system_header_ref
AND    a.request_id = p_request_id
AND    a.process_status_flag = 'P' --IS NULL
AND    a.interface_action_code='UPDATE';

   BEGIN
      qp_bulk_loader_pub.write_log('Entering Loading Udt Header');

      OPEN C_PL_HEADER;
      FETCH C_PL_HEADER BULK COLLECT
      INTO x_header_rec.list_header_id
	   ,x_header_rec.creation_date
	   ,x_header_rec.created_by
	   ,x_header_rec.last_update_date
	   ,x_header_rec.last_updated_by
	   ,x_header_rec.last_update_login
	   ,x_header_rec.program_application_id
	   ,x_header_rec.program_id
	   ,x_header_rec.program_update_date
	   ,x_header_rec.request_id
	   ,x_header_rec.list_type_code
	   ,x_header_rec.start_date_active
	   ,x_header_rec.end_date_active
	   ,x_header_rec.source_lang
	   ,x_header_rec.automatic_flag
	   ,x_header_rec.name
	   ,x_header_rec.description
	   ,x_header_rec.currency_code
	   ,x_header_rec.version_no
	   ,x_header_rec.rounding_factor
	   ,x_header_rec.ship_method_code
	   ,x_header_rec.freight_terms_code
	   ,x_header_rec.terms_id
	   ,x_header_rec.comments
	   ,x_header_rec.discount_lines_flag
	   ,x_header_rec.gsa_indicator
	   ,x_header_rec.prorate_flag
	   ,x_header_rec.source_system_code
	   ,x_header_rec.ask_for_flag
	   ,x_header_rec.active_flag
	   ,x_header_rec.parent_list_header_id
	   ,x_header_rec.active_date_first_type
	   ,x_header_rec.start_date_active_first
	   ,x_header_rec.end_date_active_first
	   ,x_header_rec.active_date_second_type
	   ,x_header_rec.start_date_active_second
	   ,x_header_rec.end_date_active_second
	   ,x_header_rec.context
	   ,x_header_rec.attribute1
	   ,x_header_rec.attribute2
	   ,x_header_rec.attribute3
	   ,x_header_rec.attribute4
	   ,x_header_rec.attribute5
	   ,x_header_rec.attribute6
	   ,x_header_rec.attribute7
	   ,x_header_rec.attribute8
	   ,x_header_rec.attribute9
	   ,x_header_rec.attribute10
	   ,x_header_rec.attribute11
	   ,x_header_rec.attribute12
	   ,x_header_rec.attribute13
	   ,x_header_rec.attribute14
	   ,x_header_rec.attribute15
	   ,x_header_rec.language
	   ,x_header_rec.process_id
	   ,x_header_rec.process_type
	   ,x_header_rec.interface_action_code
	   ,x_header_rec.lock_flag
	   ,x_header_rec.process_flag
	   ,x_header_rec.delete_flag
	   ,x_header_rec.process_status_flag
	   ,x_header_rec.mobile_download
	   ,x_header_rec.currency_header_id
	   ,x_header_rec.pte_code
	   ,x_header_rec.list_source_code
	   ,x_header_rec.orig_sys_header_ref
	   ,x_header_rec.orig_org_id
	   ,x_header_rec.global_flag;

      CLOSE C_PL_HEADER;

      qp_bulk_loader_pub.write_log('Leaving Loading Udt Header');

   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.LOAD_UDT_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.LOAD_UDT_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END LOAD_UDT_HEADER;


PROCEDURE INSERT_HEADER
   (p_header_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.HEADER_REC_TYPE)
IS
x_result varchar2(1);
BEGIN
   qp_bulk_loader_pub.write_log('Entering Insert Header');
   FORALL I IN
      P_HEADER_REC.list_header_id.FIRST..P_HEADER_REC.list_header_id.LAST

	INSERT INTO qp_list_headers_b
		    ( LIST_HEADER_ID
		      ,CREATION_DATE
		      ,CREATED_BY
		      ,LAST_UPDATE_DATE
		      ,LAST_UPDATED_BY
		      ,LAST_UPDATE_LOGIN
		      ,PROGRAM_APPLICATION_ID
		      ,PROGRAM_ID
		      ,PROGRAM_UPDATE_DATE
		      ,REQUEST_ID
		      ,LIST_TYPE_CODE
		      ,START_DATE_ACTIVE
		      ,END_DATE_ACTIVE
		      ,AUTOMATIC_FLAG
		      ,CURRENCY_CODE
		      ,ROUNDING_FACTOR
		      ,SHIP_METHOD_CODE
		      ,FREIGHT_TERMS_CODE
		      ,TERMS_ID
		      ,COMMENTS
		      ,DISCOUNT_LINES_FLAG
		      ,GSA_INDICATOR
		      ,PRORATE_FLAG
		      ,SOURCE_SYSTEM_CODE
		      ,ASK_FOR_FLAG
		      ,ACTIVE_FLAG
		      ,PARENT_LIST_HEADER_ID
		      ,START_DATE_ACTIVE_FIRST
		      ,END_DATE_ACTIVE_FIRST
		      ,ACTIVE_DATE_FIRST_TYPE
		      ,START_DATE_ACTIVE_SECOND
		      ,END_DATE_ACTIVE_SECOND
		      ,ACTIVE_DATE_SECOND_TYPE
		      ,CONTEXT
		      ,ATTRIBUTE1
		      ,ATTRIBUTE2
		      ,ATTRIBUTE3
		      ,ATTRIBUTE4
		      ,ATTRIBUTE5
		      ,ATTRIBUTE6
		      ,ATTRIBUTE7
		      ,ATTRIBUTE8
		      ,ATTRIBUTE9
		      ,ATTRIBUTE10
		      ,ATTRIBUTE11
		      ,ATTRIBUTE12
		      ,ATTRIBUTE13
		      ,ATTRIBUTE14
		      ,ATTRIBUTE15
		      ,MOBILE_DOWNLOAD
		      ,CURRENCY_HEADER_ID
		      ,PTE_CODE
		      ,LIST_SOURCE_CODE
		      ,ORIG_SYSTEM_HEADER_REF
		      ,ORIG_ORG_ID
		      ,GLOBAL_FLAG
		      )
-- Bug 4615792 RAVI
/**
Do not insert if process status flag for the record is null.
**/
       SELECT
	   P_HEADER_REC.list_header_id(I)
	  ,SYSDATE
	  ,FND_GLOBAL.USER_ID
	  ,SYSDATE
	  ,FND_GLOBAL.USER_ID
	  ,FND_GLOBAL.CONC_LOGIN_ID
	  ,660
	  ,NUll
	  ,NULL
	  ,P_HEADER_REC.Request_Id(I)
	  ,P_HEADER_REC.LIST_TYPE_CODE(I)
	   ,fnd_date.canonical_to_date(p_header_rec.start_date_active(I))
	   ,fnd_date.canonical_to_date(p_header_rec.end_date_active(I))
--	  ,P_HEADER_REC.START_DATE_ACTIVE(I)
--	  ,P_HEADER_REC.END_DATE_ACTIVE(I)
	  ,P_HEADER_REC.AUTOMATIC_FLAG(I)
	  ,P_HEADER_REC.CURRENCY_CODE(I)
	  ,P_HEADER_REC.ROUNDING_FACTOR(I)
	  ,P_HEADER_REC.SHIP_METHOD_CODE(I)
	  ,P_HEADER_REC.FREIGHT_TERMS_CODE(I)
	  ,P_HEADER_REC.TERMS_ID(I)
	  ,P_HEADER_REC.COMMENTS(I)
	  ,P_HEADER_REC.DISCOUNT_LINES_FLAG(I)
	  ,P_HEADER_REC.GSA_INDICATOR(I)
	  ,P_HEADER_REC.PRORATE_FLAG(I)
	  ,P_HEADER_REC.SOURCE_SYSTEM_CODE(I)
	  ,P_HEADER_REC.ASK_FOR_FLAG(I)
	  ,P_HEADER_REC.ACTIVE_FLAG(I)
	  ,P_HEADER_REC.PARENT_LIST_HEADER_ID(I)
	  ,P_HEADER_REC.START_DATE_ACTIVE_FIRST(I)
	  ,P_HEADER_REC.END_DATE_ACTIVE_FIRST(I)
	  ,P_HEADER_REC.ACTIVE_DATE_FIRST_TYPE(I)
	  ,P_HEADER_REC.START_DATE_ACTIVE_SECOND(I)
	  ,P_HEADER_REC.END_DATE_ACTIVE_SECOND(I)
	  ,P_HEADER_REC.ACTIVE_DATE_SECOND_TYPE(I)
	  ,P_HEADER_REC.CONTEXT(I)
	  ,P_HEADER_REC.ATTRIBUTE1(I)
	  ,P_HEADER_REC.ATTRIBUTE2(I)
	  ,P_HEADER_REC.ATTRIBUTE3(I)
	  ,P_HEADER_REC.ATTRIBUTE4(I)
	  ,P_HEADER_REC.ATTRIBUTE5(I)
	  ,P_HEADER_REC.ATTRIBUTE6(I)
	  ,P_HEADER_REC.ATTRIBUTE7(I)
	  ,P_HEADER_REC.ATTRIBUTE8(I)
	  ,P_HEADER_REC.ATTRIBUTE9(I)
	  ,P_HEADER_REC.ATTRIBUTE10(I)
	  ,P_HEADER_REC.ATTRIBUTE11(I)
	  ,P_HEADER_REC.ATTRIBUTE12(I)
	  ,P_HEADER_REC.ATTRIBUTE13(I)
	  ,P_HEADER_REC.ATTRIBUTE14(I)
	  ,P_HEADER_REC.ATTRIBUTE15(I)
	  ,P_HEADER_REC.MOBILE_DOWNLOAD(I)
	  ,P_HEADER_REC.CURRENCY_HEADER_ID(I)
	  ,P_HEADER_REC.PTE_CODE(I)
	  ,P_HEADER_REC.LIST_SOURCE_CODE(I)
	  ,P_HEADER_REC.ORIG_SYS_HEADER_REF(I)
          --added for MOAC
	  ,P_HEADER_REC.ORIG_ORG_ID(I)
--	  ,P_HEADER_REC.ORIG_ORG_ID(I)
	  ,P_HEADER_REC.GLOBAL_FLAG(I)
      FROM DUAL
      WHERE P_HEADER_REC.process_status_flag(I) IS NOT NULL;


     qp_bulk_loader_pub.write_log('Inserted Header records: '|| SQL%ROWCOUNT);

   FORALL I IN
      P_HEADER_REC.list_header_id.FIRST..P_HEADER_REC.list_header_id.LAST

     INSERT INTO QP_LIST_HEADERS_TL
		 ( LIST_HEADER_ID
		   ,CREATION_DATE
		   ,CREATED_BY
		   ,LAST_UPDATE_DATE
		   ,LAST_UPDATED_BY
		   ,LAST_UPDATE_LOGIN
		   ,LANGUAGE
		   ,SOURCE_LANG
		   ,NAME
		   ,DESCRIPTION
		   ,VERSION_NO)
       select P_HEADER_REC.LIST_HEADER_ID(I)
           ,SYSDATE
           ,FND_GLOBAL.USER_ID
           ,SYSDATE
           ,FND_GLOBAL.USER_ID
           ,FND_GLOBAL.CONC_LOGIN_ID
           ,L.LANGUAGE_CODE
           ,nvl(P_HEADER_REC.SOURCE_LANG(I),userenv('LANG'))
           ,P_HEADER_REC.NAME(I)
           ,P_HEADER_REC.DESCRIPTION(I)
           ,P_HEADER_REC.VERSION_NO(I)
     from FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
-- Bug 4615792 RAVI
/**
Do not insert if process status flag for the record is null.
**/
     AND P_HEADER_REC.process_status_flag(I) IS NOT NULL
     and not exists
       (select NULL
       from QP_LIST_HEADERS_TL T
       where T.LIST_HEADER_ID =  P_HEADER_REC.LIST_HEADER_ID(I)
       and T.LANGUAGE = L.LANGUAGE_CODE);

    IF QP_SECURITY.SECURITY_ON = 'Y' THEN
    FOR I IN 1..p_header_rec.orig_sys_header_ref.COUNT
    LOOP
	QP_security.create_default_grants( p_instance_type => QP_security.G_PRICELIST_OBJECT,
					   p_instance_pk1  => p_header_rec.list_header_id(I),
					   x_return_status => x_result);
    END LOOP;
    END IF;

    qp_bulk_loader_pub.write_log('Leaving Insert Header');

   COMMIT;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END INSERT_HEADER;

PROCEDURE INSERT_LINE
   (p_line_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.LINE_REC_TYPE)
IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Insert Line');
      FORALL I IN
	 P_LINE_REC.orig_sys_line_ref.FIRST..P_LINE_REC.orig_sys_line_ref.LAST

	 INSERT INTO qp_list_lines
	 (   LIST_LINE_ID
	    ,CREATION_DATE
	    ,CREATED_BY
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,PROGRAM_APPLICATION_ID
	    ,PROGRAM_ID
	    ,PROGRAM_UPDATE_DATE
	    ,REQUEST_ID
	    ,LIST_HEADER_ID
	    ,LIST_LINE_TYPE_CODE
	    ,START_DATE_ACTIVE
	    ,END_DATE_ACTIVE
	    ,AUTOMATIC_FLAG
	    ,MODIFIER_LEVEL_CODE
	    ,PRICE_BY_FORMULA_ID
	    ,LIST_PRICE
	    ,LIST_PRICE_UOM_CODE
	    ,PRIMARY_UOM_FLAG
	    ,INVENTORY_ITEM_ID
	    ,ORGANIZATION_ID
	    ,RELATED_ITEM_ID
	    ,RELATIONSHIP_TYPE_ID
	    ,SUBSTITUTION_CONTEXT
	    ,SUBSTITUTION_ATTRIBUTE
	    ,SUBSTITUTION_VALUE
	    ,REVISION
	    ,REVISION_DATE
	    ,REVISION_REASON_CODE
	    ,PRICE_BREAK_TYPE_CODE
	    ,PERCENT_PRICE
	    ,NUMBER_EFFECTIVE_PERIODS
	    ,EFFECTIVE_PERIOD_UOM
	    ,ARITHMETIC_OPERATOR
	    ,OPERAND
	    ,OVERRIDE_FLAG
	    ,PRINT_ON_INVOICE_FLAG
	    ,REBATE_TRANSACTION_TYPE_CODE
	    ,BASE_QTY
	    ,BASE_UOM_CODE
	    ,ACCRUAL_QTY
	    ,ACCRUAL_UOM_CODE
	    ,ESTIM_ACCRUAL_RATE
	    ,COMMENTS
	    ,GENERATE_USING_FORMULA_ID
	    ,REPRICE_FLAG
	    ,LIST_LINE_NO
	    ,ESTIM_GL_VALUE
	    ,BENEFIT_PRICE_LIST_LINE_ID
	    ,EXPIRATION_PERIOD_START_DATE
	    ,NUMBER_EXPIRATION_PERIODS
	    ,EXPIRATION_PERIOD_UOM
	    ,EXPIRATION_DATE
	    ,ACCRUAL_FLAG
	    ,PRICING_PHASE_ID
	    ,PRICING_GROUP_SEQUENCE
	    ,INCOMPATIBILITY_GRP_CODE
	    ,PRODUCT_PRECEDENCE
	    ,PRORATION_TYPE_CODE
	    ,ACCRUAL_CONVERSION_RATE
	    ,BENEFIT_QTY
	    ,BENEFIT_UOM_CODE
	    ,RECURRING_FLAG
	    ,BENEFIT_LIMIT
	    ,CHARGE_TYPE_CODE
	    ,CHARGE_SUBTYPE_CODE
	    ,CONTEXT
	    ,ATTRIBUTE1
	    ,ATTRIBUTE2
	    ,ATTRIBUTE3
	    ,ATTRIBUTE4
	    ,ATTRIBUTE5
	    ,ATTRIBUTE6
	    ,ATTRIBUTE7
	    ,ATTRIBUTE8
	    ,ATTRIBUTE9
	    ,ATTRIBUTE10
	    ,ATTRIBUTE11
	    ,ATTRIBUTE12
	    ,ATTRIBUTE13
	    ,ATTRIBUTE14
	    ,ATTRIBUTE15
	    ,INCLUDE_ON_RETURNS_FLAG
	    ,QUALIFICATION_IND
	    ,RECURRING_VALUE
	    ,NET_AMOUNT_FLAG
	    ,ORIG_SYS_LINE_REF
	    ,ORIG_SYS_HEADER_REF
	    --Bug#5359974 RAVI
            ,CONTINUOUS_PRICE_BREAK_FLAG
	    )
	  --VALUES
	  -- (
      --changes made for bug no 6028305
      SELECT
         P_LINE_REC.LIST_LINE_ID(I)
	    ,sysdate
	    ,FND_GLOBAL.USER_ID
	    ,sysdate
	    ,FND_GLOBAL.USER_ID
	    ,FND_GLOBAL.CONC_LOGIN_ID
	    ,NULL
	    ,NULL
	    ,NULL
	    ,P_LINE_REC.REQUEST_ID(I)
	    ,P_LINE_REC.LIST_HEADER_ID(I)
	    ,P_LINE_REC.LIST_LINE_TYPE_CODE(I)
	    ,P_LINE_REC.START_DATE_ACTIVE(I)
	    ,P_LINE_REC.END_DATE_ACTIVE(I)
	    ,P_LINE_REC.AUTOMATIC_FLAG(I)
	    ,P_LINE_REC.MODIFIER_LEVEL_CODE(I)
	    ,P_LINE_REC.PRICE_BY_FORMULA_ID(I)
	    ,P_LINE_REC.LIST_PRICE(I)
	    ,P_LINE_REC.LIST_PRICE_UOM_CODE(I)
	    ,P_LINE_REC.PRIMARY_UOM_FLAG(I)
	    ,P_LINE_REC.INVENTORY_ITEM_ID(I)
	    ,P_LINE_REC.ORGANIZATION_ID(I)
	    ,P_LINE_REC.RELATED_ITEM_ID(I)
	    ,P_LINE_REC.RELATIONSHIP_TYPE_ID(I)
	    ,P_LINE_REC.SUBSTITUTION_CONTEXT(I)
	    ,P_LINE_REC.SUBSTITUTION_ATTRIBUTE(I)
	    ,P_LINE_REC.SUBSTITUTION_VALUE(I)
	    ,P_LINE_REC.REVISION(I)
	    ,P_LINE_REC.REVISION_DATE(I)
	    ,P_LINE_REC.REVISION_REASON_CODE(I)
	    ,P_LINE_REC.PRICE_BREAK_TYPE_CODE(I)
	    ,P_LINE_REC.PERCENT_PRICE(I)
	    ,P_LINE_REC.NUMBER_EFFECTIVE_PERIODS(I)
	    ,P_LINE_REC.EFFECTIVE_PERIOD_UOM(I)
	    ,P_LINE_REC.ARITHMETIC_OPERATOR(I)
	    ,P_LINE_REC.OPERAND(I)
	    ,P_LINE_REC.OVERRIDE_FLAG(I)
	    ,P_LINE_REC.PRINT_ON_INVOICE_FLAG(I)
	    ,P_LINE_REC.REBATE_TRANSACTION_TYPE_CODE(I)
	    ,P_LINE_REC.BASE_QTY(I)
	    ,P_LINE_REC.BASE_UOM_CODE(I)
	    ,P_LINE_REC.ACCRUAL_QTY(I)
	    ,P_LINE_REC.ACCRUAL_UOM_CODE(I)
	    ,P_LINE_REC.ESTIM_ACCRUAL_RATE(I)
	    ,P_LINE_REC.COMMENTS(I)
	    ,P_LINE_REC.GENERATE_USING_FORMULA_ID(I)
	    ,P_LINE_REC.REPRICE_FLAG(I)
	    ,P_LINE_REC.LIST_LINE_NO(I)
	    ,P_LINE_REC.ESTIM_GL_VALUE(I)
	    ,P_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID(I)
	    ,P_LINE_REC.EXPIRATION_PERIOD_START_DATE(I)
	    ,P_LINE_REC.NUMBER_EXPIRATION_PERIODS(I)
	    ,P_LINE_REC.EXPIRATION_PERIOD_UOM(I)
	    ,P_LINE_REC.EXPIRATION_DATE(I)
	    ,P_LINE_REC.ACCRUAL_FLAG(I)
	    ,P_LINE_REC.PRICING_PHASE_ID(I)
	    ,P_LINE_REC.PRICING_GROUP_SEQUENCE(I)
	    ,P_LINE_REC.INCOMPATIBILITY_GRP_CODE(I)
	    ,P_LINE_REC.PRODUCT_PRECEDENCE(I)
	    ,P_LINE_REC.PRORATION_TYPE_CODE(I)
	    ,P_LINE_REC.ACCRUAL_CONVERSION_RATE(I)
	    ,P_LINE_REC.BENEFIT_QTY(I)
	    ,P_LINE_REC.BENEFIT_UOM_CODE(I)
	    ,P_LINE_REC.RECURRING_FLAG(I)
	    ,P_LINE_REC.BENEFIT_LIMIT(I)
	    ,P_LINE_REC.CHARGE_TYPE_CODE(I)
	    ,P_LINE_REC.CHARGE_SUBTYPE_CODE(I)
	    ,P_LINE_REC.CONTEXT(I)
	    ,P_LINE_REC.ATTRIBUTE1(I)
	    ,P_LINE_REC.ATTRIBUTE2(I)
	    ,P_LINE_REC.ATTRIBUTE3(I)
	    ,P_LINE_REC.ATTRIBUTE4(I)
	    ,P_LINE_REC.ATTRIBUTE5(I)
	    ,P_LINE_REC.ATTRIBUTE6(I)
	    ,P_LINE_REC.ATTRIBUTE7(I)
	    ,P_LINE_REC.ATTRIBUTE8(I)
	    ,P_LINE_REC.ATTRIBUTE9(I)
	    ,P_LINE_REC.ATTRIBUTE10(I)
	    ,P_LINE_REC.ATTRIBUTE11(I)
	    ,P_LINE_REC.ATTRIBUTE12(I)
	    ,P_LINE_REC.ATTRIBUTE13(I)
	    ,P_LINE_REC.ATTRIBUTE14(I)
	    ,P_LINE_REC.ATTRIBUTE15(I)
	    ,P_LINE_REC.INCLUDE_ON_RETURNS_FLAG(I)
	    ,P_LINE_REC.QUALIFICATION_IND(I)
	    ,P_LINE_REC.RECURRING_VALUE(I)
	    ,P_LINE_REC.NET_AMOUNT_FLAG(I)
	    ,P_LINE_REC.ORIG_SYS_LINE_REF(I)
	    ,P_LINE_REC.ORIG_SYS_HEADER_REF(I)
	    --Bug#5359974 RAVI
            ,P_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG(I)
	    --);
         --6028305
        FROM DUAL
        WHERE exists
        (Select 'Y' from qp_interface_list_lines
        WHERE orig_sys_line_ref=P_LINE_REC.ORIG_SYS_LINE_REF(I)
        AND request_id=P_LINE_REC.REQUEST_ID(I)
        AND process_status_flag is not null);

       qp_bulk_loader_pub.write_log('Line Insert Count: '|| sql%rowcount);
	   qp_bulk_loader_pub.write_log('Leaving Insert Line');

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END INSERT_LINE;


-- New procedure 6028305
PROCEDURE UPDATE_LINE_TO_OLD
   (p_line_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.LINE_REC_TYPE)
IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Update Line'||'entered'||  p_line_rec.orig_sys_line_ref.count);
      FOR I IN
	 P_LINE_REC.orig_sys_line_ref.FIRST..P_LINE_REC.orig_sys_line_ref.LAST
     loop
      --qp_bulk_loader_pub.write_log('count'|| i);
      UPDATE qp_list_lines
	 SET LAST_UPDATE_DATE             =sysdate
	    ,LAST_UPDATED_BY              =FND_GLOBAL.USER_ID
	    ,LAST_UPDATE_LOGIN            =FND_GLOBAL.CONC_LOGIN_ID
	    ,PROGRAM_APPLICATION_ID       =NULL
	    ,PROGRAM_ID                   =NULL
	    ,PROGRAM_UPDATE_DATE          =NULL
	    ,REQUEST_ID                   =P_LINE_REC.REQUEST_ID(I)
	    ,LIST_HEADER_ID               =P_LINE_REC.LIST_HEADER_ID(I)
	    ,LIST_LINE_TYPE_CODE          =P_LINE_REC.LIST_LINE_TYPE_CODE(I)
	    ,START_DATE_ACTIVE            =P_LINE_REC.START_DATE_ACTIVE(I)
	    ,END_DATE_ACTIVE              =P_LINE_REC.END_DATE_ACTIVE(I)
	    ,AUTOMATIC_FLAG               =P_LINE_REC.AUTOMATIC_FLAG(I)
	    ,MODIFIER_LEVEL_CODE          =P_LINE_REC.MODIFIER_LEVEL_CODE(I)
	    ,PRICE_BY_FORMULA_ID          =P_LINE_REC.PRICE_BY_FORMULA_ID(I)
	    ,LIST_PRICE                   =P_LINE_REC.LIST_PRICE(I)
	    ,LIST_PRICE_UOM_CODE          =P_LINE_REC.LIST_PRICE_UOM_CODE(I)
	    ,PRIMARY_UOM_FLAG             =P_LINE_REC.PRIMARY_UOM_FLAG(I)
	    ,INVENTORY_ITEM_ID            =P_LINE_REC.INVENTORY_ITEM_ID(I)
	    ,ORGANIZATION_ID              =P_LINE_REC.ORGANIZATION_ID(I)
	    ,RELATED_ITEM_ID              =P_LINE_REC.RELATED_ITEM_ID(I)
	    ,RELATIONSHIP_TYPE_ID         =P_LINE_REC.RELATIONSHIP_TYPE_ID(I)
	    ,SUBSTITUTION_CONTEXT         =P_LINE_REC.SUBSTITUTION_CONTEXT(I)
	    ,SUBSTITUTION_ATTRIBUTE       =P_LINE_REC.SUBSTITUTION_ATTRIBUTE(I)
	    ,SUBSTITUTION_VALUE           =P_LINE_REC.SUBSTITUTION_VALUE(I)
	    ,REVISION			  =P_LINE_REC.REVISION(I)
	    ,REVISION_DATE             	  =P_LINE_REC.REVISION_DATE(I)
	    ,REVISION_REASON_CODE	  =P_LINE_REC.REVISION_REASON_CODE(I)
	    ,PRICE_BREAK_TYPE_CODE	  =P_LINE_REC.PRICE_BREAK_TYPE_CODE(I)
	    ,PERCENT_PRICE             	  =P_LINE_REC.PERCENT_PRICE(I)
	    ,NUMBER_EFFECTIVE_PERIODS  	  =P_LINE_REC.NUMBER_EFFECTIVE_PERIODS(I)
	    ,EFFECTIVE_PERIOD_UOM      	  =P_LINE_REC.EFFECTIVE_PERIOD_UOM(I)
	    ,ARITHMETIC_OPERATOR      	  =P_LINE_REC.ARITHMETIC_OPERATOR(I)
	    ,OPERAND                  	  =P_LINE_REC.OPERAND(I)
	    ,OVERRIDE_FLAG            	  =P_LINE_REC.OVERRIDE_FLAG(I)
	    ,PRINT_ON_INVOICE_FLAG    	  =P_LINE_REC.PRINT_ON_INVOICE_FLAG(I)
	    ,REBATE_TRANSACTION_TYPE_CODE =P_LINE_REC.REBATE_TRANSACTION_TYPE_CODE(I)
	    ,BASE_QTY                     =P_LINE_REC.BASE_QTY(I)
	    ,BASE_UOM_CODE                =P_LINE_REC.BASE_UOM_CODE(I)
	    ,ACCRUAL_QTY                  =P_LINE_REC.ACCRUAL_QTY(I)
	    ,ACCRUAL_UOM_CODE             =P_LINE_REC.ACCRUAL_UOM_CODE(I)
	    ,ESTIM_ACCRUAL_RATE           =P_LINE_REC.ESTIM_ACCRUAL_RATE(I)
	    ,COMMENTS                     =P_LINE_REC.COMMENTS(I)
	    ,GENERATE_USING_FORMULA_ID    =P_LINE_REC.GENERATE_USING_FORMULA_ID(I)
	    ,REPRICE_FLAG                 =P_LINE_REC.REPRICE_FLAG(I)
	    ,LIST_LINE_NO                 =P_LINE_REC.LIST_LINE_NO(I)
	    ,ESTIM_GL_VALUE               =P_LINE_REC.ESTIM_GL_VALUE(I)
	    ,BENEFIT_PRICE_LIST_LINE_ID   =P_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID(I)
	    ,EXPIRATION_PERIOD_START_DATE =P_LINE_REC.EXPIRATION_PERIOD_START_DATE(I)
	    ,NUMBER_EXPIRATION_PERIODS    =P_LINE_REC.NUMBER_EXPIRATION_PERIODS(I)
	    ,EXPIRATION_PERIOD_UOM        =P_LINE_REC.EXPIRATION_PERIOD_UOM(I)
	    ,EXPIRATION_DATE              =P_LINE_REC.EXPIRATION_DATE(I)
	    ,ACCRUAL_FLAG                 =P_LINE_REC.ACCRUAL_FLAG(I)
	    ,PRICING_PHASE_ID             =P_LINE_REC.PRICING_PHASE_ID(I)
	    ,PRICING_GROUP_SEQUENCE       =P_LINE_REC.PRICING_GROUP_SEQUENCE(I)
	    ,INCOMPATIBILITY_GRP_CODE     =P_LINE_REC.INCOMPATIBILITY_GRP_CODE(I)
	    ,PRODUCT_PRECEDENCE           =P_LINE_REC.PRODUCT_PRECEDENCE(I)
	    ,PRORATION_TYPE_CODE          =P_LINE_REC.PRORATION_TYPE_CODE(I)
	    ,ACCRUAL_CONVERSION_RATE      =P_LINE_REC.ACCRUAL_CONVERSION_RATE(I)
	    ,BENEFIT_QTY                  =P_LINE_REC.BENEFIT_QTY(I)
	    ,BENEFIT_UOM_CODE             =P_LINE_REC.BENEFIT_UOM_CODE(I)
	    ,RECURRING_FLAG               =P_LINE_REC.RECURRING_FLAG(I)
	    ,BENEFIT_LIMIT                =P_LINE_REC.BENEFIT_LIMIT(I)
	    ,CHARGE_TYPE_CODE             =P_LINE_REC.CHARGE_TYPE_CODE(I)
	    ,CHARGE_SUBTYPE_CODE          =P_LINE_REC.CHARGE_SUBTYPE_CODE(I)
	    ,CONTEXT                      =P_LINE_REC.CONTEXT(I)
	    ,ATTRIBUTE1                   =P_LINE_REC.ATTRIBUTE1(I)
	    ,ATTRIBUTE2                   =P_LINE_REC.ATTRIBUTE2(I)
	    ,ATTRIBUTE3                   =P_LINE_REC.ATTRIBUTE3(I)
	    ,ATTRIBUTE4                   =P_LINE_REC.ATTRIBUTE4(I)
	    ,ATTRIBUTE5                   =P_LINE_REC.ATTRIBUTE5(I)
	    ,ATTRIBUTE6                   =P_LINE_REC.ATTRIBUTE6(I)
	    ,ATTRIBUTE7                   =P_LINE_REC.ATTRIBUTE7(I)
	    ,ATTRIBUTE8                   =P_LINE_REC.ATTRIBUTE8(I)
	    ,ATTRIBUTE9                   =P_LINE_REC.ATTRIBUTE9(I)
	    ,ATTRIBUTE10                  =P_LINE_REC.ATTRIBUTE10(I)
	    ,ATTRIBUTE11                  =P_LINE_REC.ATTRIBUTE11(I)
	    ,ATTRIBUTE12                  =P_LINE_REC.ATTRIBUTE12(I)
	    ,ATTRIBUTE13                  =P_LINE_REC.ATTRIBUTE13(I)
	    ,ATTRIBUTE14                  =P_LINE_REC.ATTRIBUTE14(I)
	    ,ATTRIBUTE15                  =P_LINE_REC.ATTRIBUTE15(I)
	    ,INCLUDE_ON_RETURNS_FLAG      =P_LINE_REC.INCLUDE_ON_RETURNS_FLAG(I)
	    ,QUALIFICATION_IND            =P_LINE_REC.QUALIFICATION_IND(I)
	    ,RECURRING_VALUE              =P_LINE_REC.RECURRING_VALUE(I)
	    ,NET_AMOUNT_FLAG              =P_LINE_REC.NET_AMOUNT_FLAG(I)
	    ,ORIG_SYS_LINE_REF		  =P_LINE_REC.ORIG_SYS_LINE_REF(I)
	    ,ORIG_SYS_HEADER_REF 	  =P_LINE_REC.ORIG_SYS_HEADER_REF(I)
      WHERE  ORIG_SYS_LINE_REF = P_LINE_REC.ORIG_SYS_LINE_REF(I)
        AND  ORIG_SYS_HEADER_REF = P_LINE_REC.ORIG_SYS_HEADER_REF(I)
        AND  P_LINE_REC.PROCESS_STATUS_FLAG(I) = 'P'
        AND  P_LINE_REC.interface_Action_code(I) = 'UPDATE'
        AND  request_id=P_LINE_REC.REQUEST_ID(I)
        AND (orig_sys_header_Ref,orig_Sys_line_ref) IN
            (select orig_sys_header_Ref,orig_Sys_line_ref
             from qp_interface_pricing_Attribs
             where process_Status_flag is NULL
             AND request_id=P_LINE_REC.REQUEST_ID(I)); -- updating for erred records
	end loop;
           qp_bulk_loader_pub.write_log('Lines Records Updated: '|| sql%rowcount);
	   qp_bulk_loader_pub.write_log('Leaving Update Line old');

    EXCEPTION
    when no_data_found then
    qp_bulk_loader_pub.write_log( 'NO data found QP_BULK_UTIL.UPDATE_LINE_TO_OLD');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_LINE_TO_OLD:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_LINE_TO_OLD:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END UPDATE_LINE_TO_OLD;
-- End New procedure 6028305


PROCEDURE INSERT_QUALIFIER
(P_QUALIFIER_REC IN OUT NOCOPY  QP_BULK_LOADER_PUB.Qualifier_Rec_Type)
IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Insert Qualifier');
      FORALL I IN
      P_QUALIFIER_REC.orig_sys_qualifier_ref.FIRST..P_QUALIFIER_REC.orig_sys_qualifier_ref.LAST

	INSERT INTO qp_qualifiers
	 (  QUALIFIER_ID
	    ,CREATION_DATE
	    ,CREATED_BY
	    ,LAST_UPDATE_DATE
	    ,LAST_UPDATED_BY
	    ,REQUEST_ID
	    ,PROGRAM_APPLICATION_ID
	    ,PROGRAM_ID
	    ,PROGRAM_UPDATE_DATE
	    ,LAST_UPDATE_LOGIN
	    ,QUALIFIER_GROUPING_NO
	    ,QUALIFIER_CONTEXT
	    ,QUALIFIER_ATTRIBUTE
	    ,QUALIFIER_ATTR_VALUE
	    ,COMPARISON_OPERATOR_CODE
	    ,EXCLUDER_FLAG
	    ,QUALIFIER_RULE_ID
	    ,START_DATE_ACTIVE
	    ,END_DATE_ACTIVE
	    ,CREATED_FROM_RULE_ID
	    ,QUALIFIER_PRECEDENCE
	    ,LIST_HEADER_ID
	    ,LIST_LINE_ID
	    ,QUALIFIER_DATATYPE
	    ,QUALIFIER_ATTR_VALUE_TO
	    ,CONTEXT
	    ,ATTRIBUTE1
	    ,ATTRIBUTE2
	    ,ATTRIBUTE3
	    ,ATTRIBUTE4
	    ,ATTRIBUTE5
	    ,ATTRIBUTE6
	    ,ATTRIBUTE7
	    ,ATTRIBUTE8
	    ,ATTRIBUTE9
	    ,ATTRIBUTE10
	    ,ATTRIBUTE11
	    ,ATTRIBUTE12
	    ,ATTRIBUTE13
	    ,ATTRIBUTE14
	    ,ATTRIBUTE15
	    ,ACTIVE_FLAG
	    ,LIST_TYPE_CODE
	    ,QUAL_ATTR_VALUE_FROM_NUMBER
	    ,QUAL_ATTR_VALUE_TO_NUMBER
	    ,QUALIFIER_GROUP_CNT
	    ,HEADER_QUALS_EXIST_FLAG
	    ,ORIG_SYS_QUALIFIER_REF
	    ,ORIG_SYS_HEADER_REF
	    ,ORIG_SYS_LINE_REF
            ,QUALIFY_HIER_DESCENDENTS_FLAG
	    )
        VALUES
	 (P_QUALIFIER_REC.QUALIFIER_ID(I)
	 ,SYSDATE
	 ,FND_GLOBAL.USER_ID
	 ,SYSDATE
	 ,FND_GLOBAL.USER_ID
	 ,P_QUALIFIER_REC.request_id(I)
	 ,660
	 ,NULL
	 ,NULL
	 ,FND_GLOBAL.CONC_LOGIN_ID
	 ,P_QUALIFIER_REC.QUALIFIER_GROUPING_NO(I)
	 ,P_QUALIFIER_REC.QUALIFIER_CONTEXT(I)
	 ,P_QUALIFIER_REC.QUALIFIER_ATTRIBUTE(I)
	 ,P_QUALIFIER_REC.QUALIFIER_ATTR_VALUE(I)
	 ,P_QUALIFIER_REC.COMPARISON_OPERATOR_CODE(I)
	 ,P_QUALIFIER_REC.EXCLUDER_FLAG(I)
	 ,P_QUALIFIER_REC.QUALIFIER_RULE_ID(I)
	 ,P_QUALIFIER_REC.START_DATE_ACTIVE(I)
	 ,P_QUALIFIER_REC.END_DATE_ACTIVE(I)
	 ,P_QUALIFIER_REC.CREATED_FROM_RULE_ID(I)
	 ,P_QUALIFIER_REC.QUALIFIER_PRECEDENCE(I)
	 ,P_QUALIFIER_REC.LIST_HEADER_ID(I)
	 ,nvl(P_QUALIFIER_REC.LIST_LINE_ID(I), -1)
	 ,P_QUALIFIER_REC.QUALIFIER_DATATYPE(I)
	 ,P_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO(I)
	 ,P_QUALIFIER_REC.CONTEXT(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE1(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE2(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE3(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE4(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE5(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE6(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE7(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE8(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE9(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE10(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE11(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE12(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE13(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE14(I)
	 ,P_QUALIFIER_REC.ATTRIBUTE15(I)
	 ,P_QUALIFIER_REC.ACTIVE_FLAG (I)
	 ,P_QUALIFIER_REC.LIST_TYPE_CODE(I)
	 ,P_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER(I)
	 ,P_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER(I)
	 ,P_QUALIFIER_REC.QUALIFIER_GROUP_CNT(I)
	 ,P_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG(I)
	 ,P_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF(I)
	 ,P_QUALIFIER_REC.ORIG_SYS_HEADER_REF(I)
	 ,P_QUALIFIER_REC.ORIG_SYS_LINE_REF(I)
         ,P_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG(I)
	 );
          qp_bulk_loader_pub.write_log('Inserted Qualifier Count: '|| sql%rowcount);
          qp_bulk_loader_pub.write_log('Leaving Insert Qualifier');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_QUALIFIER;

PROCEDURE INSERT_PRICING_ATTR
(P_PRICING_ATTR_REC IN OUT NOCOPY  QP_BULK_LOADER_PUB.Pricing_Attr_Rec_Type)
IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Insert Pricing Attribute');
      FORALL I IN
      P_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.FIRST
	 ..P_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.LAST

	INSERT INTO qp_pricing_attributes
	 ( PRICING_ATTRIBUTE_ID
	   ,CREATION_DATE
	   ,CREATED_BY
	   ,LAST_UPDATE_DATE
	   ,LAST_UPDATED_BY
	   ,LAST_UPDATE_LOGIN
	   ,PROGRAM_APPLICATION_ID
	   ,PROGRAM_ID
	   ,PROGRAM_UPDATE_DATE
	   ,REQUEST_ID
	   ,LIST_LINE_ID
	   ,EXCLUDER_FLAG
	   ,ACCUMULATE_FLAG
	   ,PRODUCT_ATTRIBUTE_CONTEXT
	   ,PRODUCT_ATTRIBUTE
	   ,PRODUCT_ATTR_VALUE
	   ,PRODUCT_UOM_CODE
	   ,PRICING_ATTRIBUTE_CONTEXT
	   ,PRICING_ATTRIBUTE
	   ,PRICING_ATTR_VALUE_FROM
	   ,PRICING_ATTR_VALUE_TO
	   ,ATTRIBUTE_GROUPING_NO
	   ,PRODUCT_ATTRIBUTE_DATATYPE
	   ,PRICING_ATTRIBUTE_DATATYPE
	   ,COMPARISON_OPERATOR_CODE
	   ,CONTEXT
	   ,ATTRIBUTE1
	   ,ATTRIBUTE2
	   ,ATTRIBUTE3
	   ,ATTRIBUTE4
	   ,ATTRIBUTE5
	   ,ATTRIBUTE6
	   ,ATTRIBUTE7
	   ,ATTRIBUTE8
	   ,ATTRIBUTE9
	   ,ATTRIBUTE10
	   ,ATTRIBUTE11
	   ,ATTRIBUTE12
	   ,ATTRIBUTE13
	   ,ATTRIBUTE14
	   ,ATTRIBUTE15
	   ,LIST_HEADER_ID
	   ,PRICING_PHASE_ID
	   ,QUALIFICATION_IND
	   ,PRICING_ATTR_VALUE_FROM_NUMBER
	   ,PRICING_ATTR_VALUE_TO_NUMBER
	   ,ORIG_SYS_LINE_REF
	   ,ORIG_SYS_HEADER_REF
	   ,ORIG_SYS_PRICING_ATTR_REF
	   )
	 --VALUES
	 --(
     -- Bug No 6028305
     SELECT
     QP_PRICING_ATTRIBUTES_S.nextval
	   ,sysdate
	   ,FND_GLOBAL.USER_ID
	   ,sysdate
	   ,FND_GLOBAL.USER_ID
	   ,FND_GLOBAL.CONC_LOGIN_ID
	   ,null
	   ,null
	   ,null
	   ,P_PRICING_ATTR_REC.REQUEST_ID(I)
	   ,P_PRICING_ATTR_REC.LIST_LINE_ID(I)
	   ,P_PRICING_ATTR_REC.EXCLUDER_FLAG(I)
	   ,P_PRICING_ATTR_REC.ACCUMULATE_FLAG(I)
	   ,P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT(I)
	   ,P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE(I)
	   ,P_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE(I)
	   ,P_PRICING_ATTR_REC.PRODUCT_UOM_CODE(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTRIBUTE(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO(I)
	   ,P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE(I)
	   ,P_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE(I)
	   ,P_PRICING_ATTR_REC.CONTEXT(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE1(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE2(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE3(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE4(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE5(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE6(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE7(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE8(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE9(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE10(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE11(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE12(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE13(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE14(I)
	   ,P_PRICING_ATTR_REC.ATTRIBUTE15(I)
	   ,P_PRICING_ATTR_REC.LIST_HEADER_ID(I)
	   ,P_PRICING_ATTR_REC.PRICING_PHASE_ID(I)
	   ,P_PRICING_ATTR_REC.QUALIFICATION_IND(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER(I)
	   ,P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER(I)
	   ,P_PRICING_ATTR_REC.ORIG_SYS_LINE_REF(I)
	   ,P_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF(I)
	   ,P_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF(I)
	  --);
      --6028305
       FROM DUAL
        WHERE exists (SELECT 'Y' from qp_interface_pricing_Attribs
                      WHERE ORIG_SYS_PRICING_ATTR_REF=P_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF(I)
                      AND request_id=P_PRICING_ATTR_REC.REQUEST_ID(I)
                      AND process_status_flag is not null);

          qp_bulk_loader_pub.write_log('Pricing Attr Insertcount: '|| sql%rowcount);
	  qp_bulk_loader_pub.write_log('Leaving Insert Pricing Attribute');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.INSERT_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_PRICING_ATTR;

PROCEDURE UPDATE_HEADER
 (p_header_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.HEADER_REC_TYPE)
IS
 BEGIN

 qp_bulk_loader_pub.write_log('Entering Update Header');
 FORALL I IN
      P_HEADER_REC.list_header_id.FIRST..P_HEADER_REC.list_header_id.LAST

	UPDATE  qp_list_headers_b
	SET  	        LAST_UPDATE_DATE	 =SYSDATE
		       ,LAST_UPDATED_BY		 =FND_GLOBAL.USER_ID
		       ,LAST_UPDATE_LOGIN	 =FND_GLOBAL.CONC_LOGIN_ID
		       ,PROGRAM_APPLICATION_ID 	 =661
		       ,PROGRAM_ID		 =NUll
		       ,PROGRAM_UPDATE_DATE	 =NULL
		       ,REQUEST_ID		 =P_HEADER_REC.Request_Id(I)
		       ,LIST_TYPE_CODE 		 =P_HEADER_REC.LIST_TYPE_CODE(I)
		       ,START_DATE_ACTIVE	 = fnd_date.canonical_to_date(p_header_rec.start_date_active(I))
		       ,END_DATE_ACTIVE		 = fnd_date.canonical_to_date(p_header_rec.end_date_active(I))
		       ,AUTOMATIC_FLAG 		 =P_HEADER_REC.AUTOMATIC_FLAG(I)
		       ,CURRENCY_CODE		 =P_HEADER_REC.CURRENCY_CODE(I)
		       ,ROUNDING_FACTOR		 =P_HEADER_REC.ROUNDING_FACTOR(I)
		       ,SHIP_METHOD_CODE	 =P_HEADER_REC.SHIP_METHOD_CODE(I)
		       ,FREIGHT_TERMS_CODE	 =P_HEADER_REC.FREIGHT_TERMS_CODE(I)
		       ,TERMS_ID		 =P_HEADER_REC.TERMS_ID(I)
		       ,COMMENTS		 =P_HEADER_REC.COMMENTS(I)
		       ,DISCOUNT_LINES_FLAG	 =P_HEADER_REC.DISCOUNT_LINES_FLAG(I)
		       ,GSA_INDICATOR		 =P_HEADER_REC.GSA_INDICATOR(I)
		       ,PRORATE_FLAG		 =P_HEADER_REC.PRORATE_FLAG(I)
		       ,SOURCE_SYSTEM_CODE	 =P_HEADER_REC.SOURCE_SYSTEM_CODE(I)
		       ,ASK_FOR_FLAG		 =P_HEADER_REC.ASK_FOR_FLAG(I)
		       ,ACTIVE_FLAG		 =P_HEADER_REC.ACTIVE_FLAG(I)
		       ,PARENT_LIST_HEADER_ID	 =P_HEADER_REC.PARENT_LIST_HEADER_ID(I)
		       ,START_DATE_ACTIVE_FIRST	 =P_HEADER_REC.START_DATE_ACTIVE_FIRST(I)
		       ,END_DATE_ACTIVE_FIRST	 =P_HEADER_REC.END_DATE_ACTIVE_FIRST(I)
		       ,ACTIVE_DATE_FIRST_TYPE 	 =P_HEADER_REC.ACTIVE_DATE_FIRST_TYPE(I)
		       ,START_DATE_ACTIVE_SECOND =P_HEADER_REC.START_DATE_ACTIVE_SECOND(I)
		       ,END_DATE_ACTIVE_SECOND 	 =P_HEADER_REC.END_DATE_ACTIVE_SECOND(I)
		       ,ACTIVE_DATE_SECOND_TYPE	 =P_HEADER_REC.ACTIVE_DATE_SECOND_TYPE(I)
		       ,CONTEXT			 =P_HEADER_REC.CONTEXT(I)
		       ,ATTRIBUTE1		 =P_HEADER_REC.ATTRIBUTE1(I)
		       ,ATTRIBUTE2		 =P_HEADER_REC.ATTRIBUTE2(I)
		       ,ATTRIBUTE3		 =P_HEADER_REC.ATTRIBUTE3(I)
		       ,ATTRIBUTE4		 =P_HEADER_REC.ATTRIBUTE4(I)
		       ,ATTRIBUTE5		 =P_HEADER_REC.ATTRIBUTE5(I)
		       ,ATTRIBUTE6		 =P_HEADER_REC.ATTRIBUTE6(I)
		       ,ATTRIBUTE7		 =P_HEADER_REC.ATTRIBUTE7(I)
		       ,ATTRIBUTE8		 =P_HEADER_REC.ATTRIBUTE8(I)
		       ,ATTRIBUTE9		 =P_HEADER_REC.ATTRIBUTE9(I)
		       ,ATTRIBUTE10		 =P_HEADER_REC.ATTRIBUTE10(I)
		       ,ATTRIBUTE11		 =P_HEADER_REC.ATTRIBUTE11(I)
		       ,ATTRIBUTE12		 =P_HEADER_REC.ATTRIBUTE12(I)
		       ,ATTRIBUTE13		 =P_HEADER_REC.ATTRIBUTE13(I)
		       ,ATTRIBUTE14		 =P_HEADER_REC.ATTRIBUTE14(I)
		       ,ATTRIBUTE15		 =P_HEADER_REC.ATTRIBUTE15(I)
		       ,MOBILE_DOWNLOAD		 =P_HEADER_REC.MOBILE_DOWNLOAD(I)
		       ,CURRENCY_HEADER_ID	 =P_HEADER_REC.CURRENCY_HEADER_ID(I)
		       ,PTE_CODE		 =P_HEADER_REC.PTE_CODE(I)
		       ,LIST_SOURCE_CODE	 =P_HEADER_REC.LIST_SOURCE_CODE(I)
		       ,ORIG_SYSTEM_HEADER_REF 	 =P_HEADER_REC.ORIG_SYS_HEADER_REF(I)
		       ,ORIG_ORG_ID		 =P_HEADER_REC.ORIG_ORG_ID(I)
		       ,GLOBAL_FLAG		 =P_HEADER_REC.GLOBAL_FLAG(I)
                      -- ENH undo alcoa changes RAVI
                      /**
                      The key between interface and qp tables is only orig_sys_hdr_ref
                      (not list_header_id)
                      **/
		      WHERE ORIG_SYSTEM_HEADER_REF = P_HEADER_REC.ORIG_SYS_HEADER_REF(I)
	              AND   P_HEADER_REC.process_status_flag(I) = 'P'; --IS NULL;

   FORALL I IN
      P_HEADER_REC.list_header_id.FIRST..P_HEADER_REC.list_header_id.LAST

      UPDATE QP_LIST_HEADERS_TL
	SET 	    LAST_UPDATE_DATE    =SYSDATE
		   ,LAST_UPDATED_BY     =FND_GLOBAL.USER_ID
		   ,LAST_UPDATE_LOGIN   =FND_GLOBAL.CONC_LOGIN_ID
		   ,LANGUAGE	        =nvl(P_HEADER_REC.LANGUAGE(I),LANGUAGE)
		   ,SOURCE_LANG	        =nvl(P_HEADER_REC.SOURCE_LANG(I),SOURCE_LANG)
		   ,NAME	        =P_HEADER_REC.NAME(I)
		   ,DESCRIPTION	        =P_HEADER_REC.DESCRIPTION(I)
		   ,VERSION_NO	        =P_HEADER_REC.VERSION_NO(I)
      WHERE  list_header_id = (SELECT list_header_id FROM QP_LIST_HEADERS_B
                                -- ENH undo alcoa changes RAVI
            			/**
            			The key between interface and qp tables is only orig_sys_hdr_ref
            			(not list_header_id)
            			**/
				WHERE ORIG_SYSTEM_HEADER_REF = P_HEADER_REC.ORIG_SYS_HEADER_REF(I)
				)
        AND  LANGUAGE = P_HEADER_REC.LANGUAGE(I)
        AND  SOURCE_LANG = P_HEADER_REC.SOURCE_LANG(I)
	AND   P_HEADER_REC.process_status_flag(I) = 'P'; --IS NULL;

   qp_bulk_loader_pub.write_log('Header Records Updated: '|| sql%rowcount);
   qp_bulk_loader_pub.write_log('Leaving Update Header');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_HEADER;

PROCEDURE UPDATE_LINE
   (p_line_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.LINE_REC_TYPE)
IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Update Line');
      FORALL I IN
	 P_LINE_REC.orig_sys_line_ref.FIRST..P_LINE_REC.orig_sys_line_ref.LAST

      UPDATE qp_list_lines
	 SET LAST_UPDATE_DATE             =sysdate
	    ,LAST_UPDATED_BY              =FND_GLOBAL.USER_ID
	    ,LAST_UPDATE_LOGIN            =FND_GLOBAL.CONC_LOGIN_ID
	    ,PROGRAM_APPLICATION_ID       =NULL
	    ,PROGRAM_ID                   =NULL
	    ,PROGRAM_UPDATE_DATE          =NULL
	    ,REQUEST_ID                   =P_LINE_REC.REQUEST_ID(I)
	    ,LIST_HEADER_ID               =P_LINE_REC.LIST_HEADER_ID(I)
	    ,LIST_LINE_TYPE_CODE          =P_LINE_REC.LIST_LINE_TYPE_CODE(I)
	    ,START_DATE_ACTIVE            =P_LINE_REC.START_DATE_ACTIVE(I)
	    ,END_DATE_ACTIVE              =P_LINE_REC.END_DATE_ACTIVE(I)
	    ,AUTOMATIC_FLAG               =P_LINE_REC.AUTOMATIC_FLAG(I)
	    ,MODIFIER_LEVEL_CODE          =P_LINE_REC.MODIFIER_LEVEL_CODE(I)
	    ,PRICE_BY_FORMULA_ID          =P_LINE_REC.PRICE_BY_FORMULA_ID(I)
	    ,LIST_PRICE                   =P_LINE_REC.LIST_PRICE(I)
	    ,LIST_PRICE_UOM_CODE          =P_LINE_REC.LIST_PRICE_UOM_CODE(I)
	    ,PRIMARY_UOM_FLAG             =P_LINE_REC.PRIMARY_UOM_FLAG(I)
	    ,INVENTORY_ITEM_ID            =P_LINE_REC.INVENTORY_ITEM_ID(I)
	    ,ORGANIZATION_ID              =P_LINE_REC.ORGANIZATION_ID(I)
	    ,RELATED_ITEM_ID              =P_LINE_REC.RELATED_ITEM_ID(I)
	    ,RELATIONSHIP_TYPE_ID         =P_LINE_REC.RELATIONSHIP_TYPE_ID(I)
	    ,SUBSTITUTION_CONTEXT         =P_LINE_REC.SUBSTITUTION_CONTEXT(I)
	    ,SUBSTITUTION_ATTRIBUTE       =P_LINE_REC.SUBSTITUTION_ATTRIBUTE(I)
	    ,SUBSTITUTION_VALUE           =P_LINE_REC.SUBSTITUTION_VALUE(I)
	    ,REVISION			  =P_LINE_REC.REVISION(I)
	    ,REVISION_DATE             	  =P_LINE_REC.REVISION_DATE(I)
	    ,REVISION_REASON_CODE	  =P_LINE_REC.REVISION_REASON_CODE(I)
	    ,PRICE_BREAK_TYPE_CODE	  =P_LINE_REC.PRICE_BREAK_TYPE_CODE(I)
	    ,PERCENT_PRICE             	  =P_LINE_REC.PERCENT_PRICE(I)
	    ,NUMBER_EFFECTIVE_PERIODS  	  =P_LINE_REC.NUMBER_EFFECTIVE_PERIODS(I)
	    ,EFFECTIVE_PERIOD_UOM      	  =P_LINE_REC.EFFECTIVE_PERIOD_UOM(I)
	    ,ARITHMETIC_OPERATOR      	  =P_LINE_REC.ARITHMETIC_OPERATOR(I)
	    ,OPERAND                  	  =P_LINE_REC.OPERAND(I)
	    ,OVERRIDE_FLAG            	  =P_LINE_REC.OVERRIDE_FLAG(I)
	    ,PRINT_ON_INVOICE_FLAG    	  =P_LINE_REC.PRINT_ON_INVOICE_FLAG(I)
	    ,REBATE_TRANSACTION_TYPE_CODE =P_LINE_REC.REBATE_TRANSACTION_TYPE_CODE(I)
	    ,BASE_QTY                     =P_LINE_REC.BASE_QTY(I)
	    ,BASE_UOM_CODE                =P_LINE_REC.BASE_UOM_CODE(I)
	    ,ACCRUAL_QTY                  =P_LINE_REC.ACCRUAL_QTY(I)
	    ,ACCRUAL_UOM_CODE             =P_LINE_REC.ACCRUAL_UOM_CODE(I)
	    ,ESTIM_ACCRUAL_RATE           =P_LINE_REC.ESTIM_ACCRUAL_RATE(I)
	    ,COMMENTS                     =P_LINE_REC.COMMENTS(I)
	    ,GENERATE_USING_FORMULA_ID    =P_LINE_REC.GENERATE_USING_FORMULA_ID(I)
	    ,REPRICE_FLAG                 =P_LINE_REC.REPRICE_FLAG(I)
	    ,LIST_LINE_NO                 =P_LINE_REC.LIST_LINE_NO(I)
	    ,ESTIM_GL_VALUE               =P_LINE_REC.ESTIM_GL_VALUE(I)
	    ,BENEFIT_PRICE_LIST_LINE_ID   =P_LINE_REC.BENEFIT_PRICE_LIST_LINE_ID(I)
	    ,EXPIRATION_PERIOD_START_DATE =P_LINE_REC.EXPIRATION_PERIOD_START_DATE(I)
	    ,NUMBER_EXPIRATION_PERIODS    =P_LINE_REC.NUMBER_EXPIRATION_PERIODS(I)
	    ,EXPIRATION_PERIOD_UOM        =P_LINE_REC.EXPIRATION_PERIOD_UOM(I)
	    ,EXPIRATION_DATE              =P_LINE_REC.EXPIRATION_DATE(I)
	    ,ACCRUAL_FLAG                 =P_LINE_REC.ACCRUAL_FLAG(I)
	    ,PRICING_PHASE_ID             =P_LINE_REC.PRICING_PHASE_ID(I)
	    ,PRICING_GROUP_SEQUENCE       =P_LINE_REC.PRICING_GROUP_SEQUENCE(I)
	    ,INCOMPATIBILITY_GRP_CODE     =P_LINE_REC.INCOMPATIBILITY_GRP_CODE(I)
	    ,PRODUCT_PRECEDENCE           =P_LINE_REC.PRODUCT_PRECEDENCE(I)
	    ,PRORATION_TYPE_CODE          =P_LINE_REC.PRORATION_TYPE_CODE(I)
	    ,ACCRUAL_CONVERSION_RATE      =P_LINE_REC.ACCRUAL_CONVERSION_RATE(I)
	    ,BENEFIT_QTY                  =P_LINE_REC.BENEFIT_QTY(I)
	    ,BENEFIT_UOM_CODE             =P_LINE_REC.BENEFIT_UOM_CODE(I)
	    ,RECURRING_FLAG               =P_LINE_REC.RECURRING_FLAG(I)
	    ,BENEFIT_LIMIT                =P_LINE_REC.BENEFIT_LIMIT(I)
	    ,CHARGE_TYPE_CODE             =P_LINE_REC.CHARGE_TYPE_CODE(I)
	    ,CHARGE_SUBTYPE_CODE          =P_LINE_REC.CHARGE_SUBTYPE_CODE(I)
	    ,CONTEXT                      =P_LINE_REC.CONTEXT(I)
	    ,ATTRIBUTE1                   =P_LINE_REC.ATTRIBUTE1(I)
	    ,ATTRIBUTE2                   =P_LINE_REC.ATTRIBUTE2(I)
	    ,ATTRIBUTE3                   =P_LINE_REC.ATTRIBUTE3(I)
	    ,ATTRIBUTE4                   =P_LINE_REC.ATTRIBUTE4(I)
	    ,ATTRIBUTE5                   =P_LINE_REC.ATTRIBUTE5(I)
	    ,ATTRIBUTE6                   =P_LINE_REC.ATTRIBUTE6(I)
	    ,ATTRIBUTE7                   =P_LINE_REC.ATTRIBUTE7(I)
	    ,ATTRIBUTE8                   =P_LINE_REC.ATTRIBUTE8(I)
	    ,ATTRIBUTE9                   =P_LINE_REC.ATTRIBUTE9(I)
	    ,ATTRIBUTE10                  =P_LINE_REC.ATTRIBUTE10(I)
	    ,ATTRIBUTE11                  =P_LINE_REC.ATTRIBUTE11(I)
	    ,ATTRIBUTE12                  =P_LINE_REC.ATTRIBUTE12(I)
	    ,ATTRIBUTE13                  =P_LINE_REC.ATTRIBUTE13(I)
	    ,ATTRIBUTE14                  =P_LINE_REC.ATTRIBUTE14(I)
	    ,ATTRIBUTE15                  =P_LINE_REC.ATTRIBUTE15(I)
	    ,INCLUDE_ON_RETURNS_FLAG      =P_LINE_REC.INCLUDE_ON_RETURNS_FLAG(I)
	    ,QUALIFICATION_IND            =P_LINE_REC.QUALIFICATION_IND(I)
	    ,RECURRING_VALUE              =P_LINE_REC.RECURRING_VALUE(I)
	    ,NET_AMOUNT_FLAG              =P_LINE_REC.NET_AMOUNT_FLAG(I)
	    ,ORIG_SYS_LINE_REF		  =P_LINE_REC.ORIG_SYS_LINE_REF(I)
	    ,ORIG_SYS_HEADER_REF 	  =P_LINE_REC.ORIG_SYS_HEADER_REF(I)
	    --Bug#5359974 RAVI
            ,CONTINUOUS_PRICE_BREAK_FLAG  =P_LINE_REC.CONTINUOUS_PRICE_BREAK_FLAG(I)
      WHERE  ORIG_SYS_LINE_REF = P_LINE_REC.ORIG_SYS_LINE_REF(I)
        AND  ORIG_SYS_HEADER_REF = P_LINE_REC.ORIG_SYS_HEADER_REF(I)
        AND  P_LINE_REC.PROCESS_STATUS_FLAG(I) = 'P' --IS NULL;
        -- 6028305
         AND EXISTS (Select ORIG_SYS_LINE_REF
        from qp_interface_list_lines
        where ORIG_SYS_LINE_REF = P_LINE_REC.ORIG_SYS_LINE_REF(I)
        AND  ORIG_SYS_HEADER_REF = P_LINE_REC.ORIG_SYS_HEADER_REF(I)
        AND  PROCESS_STATUS_FLAG is not null
        AND  REQUEST_ID=P_LINE_REC.REQUEST_ID(I)) ;

           qp_bulk_loader_pub.write_log('Lines Records Updated: '|| sql%rowcount);
	   qp_bulk_loader_pub.write_log('Leaving Update Line');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END UPDATE_LINE;

PROCEDURE UPDATE_QUALIFIER
(P_QUALIFIER_REC IN OUT NOCOPY  QP_BULK_LOADER_PUB.Qualifier_Rec_Type)

IS
   BEGIN

      qp_bulk_loader_pub.write_log('Entering Update Qualifier');
      FORALL I IN
      P_QUALIFIER_REC.orig_sys_qualifier_ref.FIRST..P_QUALIFIER_REC.orig_sys_qualifier_ref.LAST

	UPDATE  qp_qualifiers
	SET  LAST_UPDATE_DATE          =SYSDATE
	    ,LAST_UPDATED_BY	       =FND_GLOBAL.USER_ID
	    ,REQUEST_ID		       =P_QUALIFIER_REC.request_id(I)
	    ,PROGRAM_APPLICATION_ID    =660
	    ,PROGRAM_ID		       =NULL
	    ,PROGRAM_UPDATE_DATE       =NULL
	    ,LAST_UPDATE_LOGIN	       =FND_GLOBAL.CONC_LOGIN_ID
	    ,QUALIFIER_GROUPING_NO     =P_QUALIFIER_REC.QUALIFIER_GROUPING_NO(I)
	    ,QUALIFIER_CONTEXT	       =P_QUALIFIER_REC.QUALIFIER_CONTEXT(I)
	    ,QUALIFIER_ATTRIBUTE       =P_QUALIFIER_REC.QUALIFIER_ATTRIBUTE(I)
	    ,QUALIFIER_ATTR_VALUE      =P_QUALIFIER_REC.QUALIFIER_ATTR_VALUE(I)
	    ,COMPARISON_OPERATOR_CODE  =P_QUALIFIER_REC.COMPARISON_OPERATOR_CODE(I)
	    ,EXCLUDER_FLAG	       =P_QUALIFIER_REC.EXCLUDER_FLAG(I)
	    ,QUALIFIER_RULE_ID	       =P_QUALIFIER_REC.QUALIFIER_RULE_ID(I)
	    ,START_DATE_ACTIVE	       =P_QUALIFIER_REC.START_DATE_ACTIVE(I)
	    ,END_DATE_ACTIVE	       =P_QUALIFIER_REC.END_DATE_ACTIVE(I)
	    ,CREATED_FROM_RULE_ID      =P_QUALIFIER_REC.CREATED_FROM_RULE_ID(I)
	    ,QUALIFIER_PRECEDENCE      =P_QUALIFIER_REC.QUALIFIER_PRECEDENCE(I)
	    ,LIST_HEADER_ID	       =P_QUALIFIER_REC.LIST_HEADER_ID(I)
	    ,LIST_LINE_ID	       =P_QUALIFIER_REC.LIST_LINE_ID(I)
	    ,QUALIFIER_DATATYPE	       =P_QUALIFIER_REC.QUALIFIER_DATATYPE(I)
	    ,QUALIFIER_ATTR_VALUE_TO   =P_QUALIFIER_REC.QUALIFIER_ATTR_VALUE_TO(I)
	    ,CONTEXT		       =P_QUALIFIER_REC.CONTEXT(I)
	    ,ATTRIBUTE1		       =P_QUALIFIER_REC.ATTRIBUTE1(I)
	    ,ATTRIBUTE2		       =P_QUALIFIER_REC.ATTRIBUTE2(I)
	    ,ATTRIBUTE3		       =P_QUALIFIER_REC.ATTRIBUTE3(I)
	    ,ATTRIBUTE4		       =P_QUALIFIER_REC.ATTRIBUTE4(I)
	    ,ATTRIBUTE5		       =P_QUALIFIER_REC.ATTRIBUTE5(I)
	    ,ATTRIBUTE6		       =P_QUALIFIER_REC.ATTRIBUTE6(I)
	    ,ATTRIBUTE7		       =P_QUALIFIER_REC.ATTRIBUTE7(I)
	    ,ATTRIBUTE8		       =P_QUALIFIER_REC.ATTRIBUTE8(I)
	    ,ATTRIBUTE9		       =P_QUALIFIER_REC.ATTRIBUTE9(I)
	    ,ATTRIBUTE10	       =P_QUALIFIER_REC.ATTRIBUTE10(I)
	    ,ATTRIBUTE11	       =P_QUALIFIER_REC.ATTRIBUTE11(I)
	    ,ATTRIBUTE12	       =P_QUALIFIER_REC.ATTRIBUTE12(I)
	    ,ATTRIBUTE13	       =P_QUALIFIER_REC.ATTRIBUTE13(I)
	    ,ATTRIBUTE14	       =P_QUALIFIER_REC.ATTRIBUTE14(I)
	    ,ATTRIBUTE15	       =P_QUALIFIER_REC.ATTRIBUTE15(I)
	    ,ACTIVE_FLAG 	       =P_QUALIFIER_REC.ACTIVE_FLAG (I)
	    ,LIST_TYPE_CODE	       =P_QUALIFIER_REC.LIST_TYPE_CODE(I)
	    ,QUAL_ATTR_VALUE_FROM_NUMBER =P_QUALIFIER_REC.QUAL_ATTR_VALUE_FROM_NUMBER(I)
            ,QUAL_ATTR_VALUE_TO_NUMBER =P_QUALIFIER_REC.QUAL_ATTR_VALUE_TO_NUMBER(I)
	    ,QUALIFIER_GROUP_CNT       =P_QUALIFIER_REC.QUALIFIER_GROUP_CNT(I)
	    ,HEADER_QUALS_EXIST_FLAG   =P_QUALIFIER_REC.HEADER_QUALS_EXIST_FLAG(I)
	    ,ORIG_SYS_QUALIFIER_REF    =P_QUALIFIER_REC.ORIG_SYS_QUALIFIER_REF(I)
	    ,ORIG_SYS_HEADER_REF       =P_QUALIFIER_REC.ORIG_SYS_HEADER_REF(I)
	    ,ORIG_SYS_LINE_REF	       =P_QUALIFIER_REC.ORIG_SYS_LINE_REF(I)
            ,QUALIFY_HIER_DESCENDENTS_FLAG=P_QUALIFIER_REC.QUALIFY_HIER_DESCENDENTS_FLAG(I)
        WHERE  orig_sys_qualifier_ref = P_QUALIFIER_REC.orig_sys_qualifier_ref(I)
        AND orig_sys_header_ref = P_QUALIFIER_REC.orig_sys_header_ref(I)
        AND P_QUALIFIER_REC.process_status_flag(I) = 'P'; --IS NULL;

	 qp_bulk_loader_pub.write_log('Qualifier Records Updated: '|| sql%rowcount);
         qp_bulk_loader_pub.write_log('Leaving Update Qualifier');

   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_QUALIFIER;

PROCEDURE UPDATE_PRICING_ATTR
(P_PRICING_ATTR_REC IN OUT NOCOPY  QP_BULK_LOADER_PUB.Pricing_Attr_Rec_Type)
IS
   BEGIN
      qp_bulk_loader_pub.write_log('Entering Update Pricing Attribute');
      FORALL I IN
      P_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.FIRST
	 ..P_PRICING_ATTR_REC.orig_sys_pricing_attr_ref.LAST

     UPDATE qp_pricing_attributes
        SET LAST_UPDATE_DATE                 =sysdate
	   ,LAST_UPDATED_BY                  =FND_GLOBAL.USER_ID
	   ,LAST_UPDATE_LOGIN                =FND_GLOBAL.CONC_LOGIN_ID
	   ,PROGRAM_APPLICATION_ID           =null
	   ,PROGRAM_ID                       =null
	   ,PROGRAM_UPDATE_DATE              =null
	   ,REQUEST_ID                       =P_PRICING_ATTR_REC.REQUEST_ID(I)
	   ,LIST_LINE_ID                     =P_PRICING_ATTR_REC.LIST_LINE_ID(I)
	   ,EXCLUDER_FLAG                    =P_PRICING_ATTR_REC.EXCLUDER_FLAG(I)
	   ,ACCUMULATE_FLAG                  =P_PRICING_ATTR_REC.ACCUMULATE_FLAG(I)
	   ,PRODUCT_ATTRIBUTE_CONTEXT        =P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_CONTEXT(I)
	   ,PRODUCT_ATTRIBUTE                =P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE(I)
	   ,PRODUCT_ATTR_VALUE               =P_PRICING_ATTR_REC.PRODUCT_ATTR_VALUE(I)
	   ,PRODUCT_UOM_CODE                 =P_PRICING_ATTR_REC.PRODUCT_UOM_CODE(I)
	   ,PRICING_ATTRIBUTE_CONTEXT        =P_PRICING_ATTR_REC.PRICING_ATTRIBUTE_CONTEXT(I)
	   ,PRICING_ATTRIBUTE                =P_PRICING_ATTR_REC.PRICING_ATTRIBUTE(I)
	   ,PRICING_ATTR_VALUE_FROM          =P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM(I)
	   ,PRICING_ATTR_VALUE_TO            =P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO(I)
--	   ,ATTRIBUTE_GROUPING_NO            =P_PRICING_ATTR_REC.ATTRIBUTE_GROUPING_NO(I)
	   ,PRODUCT_ATTRIBUTE_DATATYPE       =P_PRICING_ATTR_REC.PRODUCT_ATTRIBUTE_DATATYPE(I)
	   ,PRICING_ATTRIBUTE_DATATYPE       =P_PRICING_ATTR_REC.PRICING_ATTRIBUTE_DATATYPE(I)
	   ,COMPARISON_OPERATOR_CODE         =P_PRICING_ATTR_REC.COMPARISON_OPERATOR_CODE(I)
	   ,CONTEXT                          =P_PRICING_ATTR_REC.CONTEXT(I)
	   ,ATTRIBUTE1                       =P_PRICING_ATTR_REC.ATTRIBUTE1(I)
	   ,ATTRIBUTE2                       =P_PRICING_ATTR_REC.ATTRIBUTE2(I)
	   ,ATTRIBUTE3                       =P_PRICING_ATTR_REC.ATTRIBUTE3(I)
	   ,ATTRIBUTE4                       =P_PRICING_ATTR_REC.ATTRIBUTE4(I)
	   ,ATTRIBUTE5                       =P_PRICING_ATTR_REC.ATTRIBUTE5(I)
	   ,ATTRIBUTE6                       =P_PRICING_ATTR_REC.ATTRIBUTE6(I)
	   ,ATTRIBUTE7                       =P_PRICING_ATTR_REC.ATTRIBUTE7(I)
	   ,ATTRIBUTE8                       =P_PRICING_ATTR_REC.ATTRIBUTE8(I)
	   ,ATTRIBUTE9                       =P_PRICING_ATTR_REC.ATTRIBUTE9(I)
	   ,ATTRIBUTE10                      =P_PRICING_ATTR_REC.ATTRIBUTE10(I)
	   ,ATTRIBUTE11                      =P_PRICING_ATTR_REC.ATTRIBUTE11(I)
	   ,ATTRIBUTE12                      =P_PRICING_ATTR_REC.ATTRIBUTE12(I)
	   ,ATTRIBUTE13                      =P_PRICING_ATTR_REC.ATTRIBUTE13(I)
	   ,ATTRIBUTE14                      =P_PRICING_ATTR_REC.ATTRIBUTE14(I)
	   ,ATTRIBUTE15                      =P_PRICING_ATTR_REC.ATTRIBUTE15(I)
	   ,LIST_HEADER_ID                   =P_PRICING_ATTR_REC.LIST_HEADER_ID(I)
	   ,PRICING_PHASE_ID                 =P_PRICING_ATTR_REC.PRICING_PHASE_ID(I)
	   ,QUALIFICATION_IND                =P_PRICING_ATTR_REC.QUALIFICATION_IND(I)
	   ,PRICING_ATTR_VALUE_FROM_NUMBER   =P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_FROM_NUMBER(I)
	   ,PRICING_ATTR_VALUE_TO_NUMBER     =P_PRICING_ATTR_REC.PRICING_ATTR_VALUE_TO_NUMBER(I)
	   ,ORIG_SYS_LINE_REF		     =P_PRICING_ATTR_REC.ORIG_SYS_LINE_REF(I)
	   ,ORIG_SYS_HEADER_REF		     =P_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF(I)
	   ,ORIG_SYS_PRICING_ATTR_REF	     =P_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF(I)
           WHERE ORIG_SYS_PRICING_ATTR_REF = P_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF(I)
         AND  ORIG_SYS_LINE_REF = p_pricing_attr_rec.orig_sys_line_ref(I)
         AND  ORIG_SYS_HEADER_REF = p_pricing_attr_rec.orig_sys_header_ref(I)
         AND  P_PRICING_ATTR_REC.PROCESS_STATUS_FLAG(I) = 'P'
         -- 6028305
         AND EXISTS (Select ORIG_SYS_PRICING_ATTR_REF
         from qp_interface_pricing_Attribs
         where ORIG_SYS_PRICING_ATTR_REF = P_PRICING_ATTR_REC.ORIG_SYS_PRICING_ATTR_REF(I)
         AND ORIG_SYS_LINE_REF = P_PRICING_ATTR_REC.ORIG_SYS_LINE_REF(I)
         AND  ORIG_SYS_HEADER_REF =P_PRICING_ATTR_REC.ORIG_SYS_HEADER_REF(I)
         AND  REQUEST_ID= P_PRICING_ATTR_REC.REQUEST_ID(I)
         AND  PROCESS_STATUS_FLAG is not null) ;

          qp_bulk_loader_pub.write_log('Pricing Attr Records Updated: '|| sql%rowcount);
	   qp_bulk_loader_pub.write_log('Leaving Update Pricing Attribute');

     EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.UPDATE_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_PRICING_ATTR;

PROCEDURE DELETE_HEADER
          (p_request_id NUMBER)
IS
   l_msg_txt VARCHAR2(2000);

   BEGIN

        qp_bulk_loader_pub.write_log('Entering Delete Header');

        FND_MESSAGE.SET_NAME('QP', 'HDR_NOT_ALLOWED_TO_DLT');
	l_msg_txt := FND_MESSAGE.GET;

	INSERT INTO QP_INTERFACE_ERRORS
	 (error_id,last_update_date, last_updated_by, creation_date,
	  created_by, last_update_login, request_id, program_application_id,
	  program_id, program_update_date, entity_type, table_name, column_name,
	  orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	  orig_sys_pricing_attr_ref,error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS',  NULL,
	 orig_sys_header_ref,null,null, null,l_msg_txt
	  FROM QP_INTERFACE_LIST_HEADERS
	 WHERE  request_id = p_request_id
	   AND  interface_action_code = 'DELETE';

         UPDATE qp_interface_list_headers
	    SET process_status_flag = NULL --'E'
	  WHERE request_id = p_request_id
	    AND interface_action_code = 'DELETE';

       qp_bulk_loader_pub.write_log('Leaving Delete Header');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_HEADER;

PROCEDURE DELETE_QUALIFIER
          (P_REQUEST_ID NUMBER)
IS
   l_msg_txt VARCHAR2(2000);

   BEGIN

      qp_bulk_loader_pub.write_log('Entering Delete Qualifier');

      FND_MESSAGE.SET_NAME('QP', 'NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD' , 'QUALIFIER');
      l_msg_txt := FND_MESSAGE.GET;

     --check for existance of the record
     INSERT INTO QP_INTERFACE_ERRORS
	 (error_id,last_update_date, last_updated_by, creation_date,
	  created_by, last_update_login, request_id, program_application_id,
	  program_id, program_update_date, entity_type, table_name, column_name,
	   orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	  orig_sys_pricing_attr_ref,  error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS',  NULL,
	 orig_sys_header_ref,null,orig_sys_qualifier_ref,null, l_msg_txt
	  FROM  QP_INTERFACE_QUALIFIERS qpiq
	 WHERE  request_id = p_request_id
	   AND  interface_action_code = 'DELETE'
	   AND  NOT EXISTS
                    (SELECT 'Y' FROM QP_QUALIFIERS qpq
                     WHERE qpq.orig_sys_qualifier_ref = qpiq.orig_sys_qualifier_ref
                        AND qpq.orig_sys_header_ref = qpiq.orig_sys_header_ref) ;

     --set process status flag

     QP_BULK_VALIDATE.MARK_ERRORED_INTERFACE_RECORD
      ('QUALIFIER',
       p_request_id);

      --delete the records
       DELETE FROM QP_QUALIFIERS
	WHERE rowid IN
	(SELECT q.rowid
	   FROM QP_INTERFACE_QUALIFIERS iq, QP_QUALIFIERS q
	  WHERE iq.request_id = p_request_id
	    AND iq.interface_action_code = 'DELETE'
	    AND iq.process_status_flag = 'P' --IS NULL
            AND iq.orig_sys_qualifier_ref = q.orig_sys_qualifier_ref
            AND iq.orig_sys_header_ref = q.orig_sys_header_ref);

     qp_bulk_loader_pub.write_log('Qualifier Records Deleted: '|| sql%rowcount);

     --Set process_status_flag of sucessfully deleted records
       UPDATE qp_interface_qualifiers
	  SET process_status_flag ='I'
	WHERE process_status_flag = 'P' --IS NULL
	  AND request_id = p_request_id
	  AND interface_action_code  = 'DELETE';

    qp_bulk_loader_pub.write_log('Leaving Delete Qualifier');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_QUALIFIER;

PROCEDURE DELETE_LINE
     (p_request_id NUMBER)
IS

 l_msg_txt VARCHAR2(2000);

 BEGIN

      qp_bulk_loader_pub.write_log('Entering Delete Line');

      FND_MESSAGE.SET_NAME('QP', 'NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD' , 'LINE');
      l_msg_txt := FND_MESSAGE.GET;

     --check for existance of the record
     INSERT INTO QP_INTERFACE_ERRORS
	 (error_id,last_update_date, last_updated_by, creation_date,
	  created_by, last_update_login, request_id, program_application_id,
	  program_id, program_update_date, entity_type, table_name, column_name,
	   orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	  orig_sys_pricing_attr_ref,error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_LINES',  NULL,
	 orig_sys_header_ref,orig_sys_line_ref,null,null, l_msg_txt
	  FROM  QP_INTERFACE_LIST_LINES qpil
	 WHERE  request_id = p_request_id
	   AND  interface_action_code = 'DELETE'
	   AND  NOT EXISTS
                    (SELECT 'Y' FROM QP_LIST_LINES qpl
                    WHERE qpl.orig_sys_line_ref = qpil.orig_sys_line_ref
                      AND   qpl.orig_sys_header_ref = qpil.orig_sys_header_ref  ) ;

     --set process status flag
     QP_BULK_VALIDATE.MARK_ERRORED_INTERFACE_RECORD
      ('LINE',
       p_request_id);


        --delete if any PBH child lines
        DELETE FROM QP_PRICING_ATTRIBUTES
	WHERE  list_line_id IN
	(SELECT ll.list_line_id
	   FROM QP_INTERFACE_LIST_LINES il, QP_RLTD_MODIFIERS r,
		QP_LIST_LINES l, QP_LIST_LINES ll
	  WHERE il.request_id = p_request_id
	    AND il.process_status_flag = 'P' --IS NULL
	    AND il.interface_action_code = 'DELETE'
            AND l.orig_sys_line_ref = il.orig_sys_line_ref
            AND l.orig_sys_header_ref = il.orig_sys_header_ref
            AND r.from_rltd_modifier_id = l.list_line_id
            AND r.to_rltd_modifier_id = ll.list_line_id );

        DELETE FROM QP_LIST_LINES
	WHERE   list_line_id IN
	(SELECT ll.list_line_id
	   FROM QP_INTERFACE_LIST_LINES il, QP_RLTD_MODIFIERS r,
		QP_LIST_LINES l, QP_LIST_LINES ll
	  WHERE il.request_id = p_request_id
	    AND il.process_status_flag = 'P' --IS NULL
	    AND il.interface_action_code = 'DELETE'
            AND l.orig_sys_line_ref = il.orig_sys_line_ref
            AND l.orig_sys_header_ref = il.orig_sys_header_ref
            AND r.from_rltd_modifier_id = l.list_line_id
            AND r.to_rltd_modifier_id = ll.list_line_id );

        DELETE FROM QP_RLTD_MODIFIERS
	 WHERE from_rltd_modifier_id IN
	 (SELECT l.list_line_id FROM QP_LIST_LINES l, QP_INTERFACE_LIST_LINES il
	   WHERE il.request_id = p_request_id
	     AND il.process_status_flag = 'P' --IS NULL
	     AND il.interface_action_code = 'DELETE'
             AND il.orig_sys_line_ref = l.orig_sys_line_ref
             AND l.orig_sys_header_ref = il.orig_sys_header_ref);

       --end

	DELETE FROM QP_PRICING_ATTRIBUTES
	WHERE list_line_id IN
	(SELECT l.list_line_id
	   FROM QP_INTERFACE_LIST_LINES il,QP_LIST_LINES l
	  WHERE il.request_id = p_request_id
	    AND il.process_status_flag = 'P' --IS NULL
	    AND il.interface_action_code = 'DELETE'
            AND il.orig_sys_line_ref = l.orig_sys_line_ref
            AND il.orig_sys_header_ref = l.orig_sys_header_ref);


	DELETE FROM QP_LIST_LINES
	WHERE list_line_id IN
	(SELECT l.list_line_id
	   FROM QP_INTERFACE_LIST_LINES il,QP_LIST_LINES l
	  WHERE il.request_id = p_request_id
	    AND il.process_status_flag = 'P' --IS NULL
	    AND il.interface_action_code = 'DELETE'
            AND il.orig_sys_line_ref = l.orig_sys_line_ref
            AND il.orig_sys_header_ref = l.orig_sys_header_ref);

  --Set process_status_flag of sucessfully deleted records
       UPDATE qp_interface_list_lines
	  SET process_status_flag ='I'
	WHERE process_status_flag = 'P' --IS NULL
	  AND request_id = p_request_id
	  AND interface_action_code  = 'DELETE';

    qp_bulk_loader_pub.write_log('Leaving Delete Line');

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_LINE;

PROCEDURE DELETE_PRICING_ATTR
     (p_request_id NUMBER)
IS
 l_msg_txt VARCHAR2(2000);

   BEGIN

      qp_bulk_loader_pub.write_log('Entering Delete Pricing Attribute');
      FND_MESSAGE.SET_NAME('QP', 'NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD' , 'PRICING ATTRIBUTE');
      l_msg_txt := FND_MESSAGE.GET;

     --check for existance of the record
     INSERT INTO QP_INTERFACE_ERRORS
	 (error_id,last_update_date, last_updated_by, creation_date,
	  created_by, last_update_login, request_id, program_application_id,
	  program_id, program_update_date, entity_type, table_name, column_name,
	  orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	  orig_sys_pricing_attr_ref,error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_PRICING_ATTRIBS',  NULL,
	 orig_sys_header_ref,orig_sys_line_ref,null,orig_sys_pricing_attr_ref, l_msg_txt
	  FROM  QP_INTERFACE_PRICING_ATTRIBS qpip
	 WHERE  request_id = p_request_id
	   AND  process_status_flag = 'P' --is null
	   AND  interface_action_code = 'DELETE'
	   AND  NOT EXISTS
                    (SELECT 'Y' FROM QP_PRICING_ATTRIBUTES qpp
                      WHERE qpp.orig_sys_pricing_attr_ref = qpip.orig_sys_pricing_attr_ref
                      AND   qpp.pricing_attribute_context IS NOT NULL
                      AND   qpp.request_id = p_request_id
                      AND   qpp.orig_sys_line_ref = qpip.orig_sys_line_ref
                      AND   qpp.orig_sys_header_ref = qpip.orig_sys_header_ref)
           -- Bug# 5236656
           -- If the Line is being deleted then the pricing record is automatically deleted.
           -- An other attempt to delete the Pricing attribute is not necessary.
           -- Check if the Line is also being deleted in this request.
           -- If so do not thrown an error that the pricing record is not found as it has already been deleted.
          AND NOT EXISTS (SELECT 'Y' FROM QP_INTERFACE_LIST_LINES qpil
                      WHERE qpil.orig_sys_line_ref = qpip.orig_sys_line_ref
                      AND   qpil.orig_sys_header_ref = qpip.orig_sys_header_ref
                      AND   qpil.request_id = p_request_id
                      AND   qpil.interface_action_code = 'DELETE');

     --Bug# 5253114 RAVI START

      qp_bulk_loader_pub.write_log('Cannot delete a Price Break child line if it is not the highest break.');
      FND_MESSAGE.SET_NAME('QP', 'QP_NO_DELETE_PB_CHILD_LINE');
      l_msg_txt := FND_MESSAGE.GET;

     INSERT INTO QP_INTERFACE_ERRORS
	 (error_id,last_update_date, last_updated_by, creation_date,
	  created_by, last_update_login, request_id, program_application_id,
	  program_id, program_update_date, entity_type, table_name, column_name,
	  orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
	  orig_sys_pricing_attr_ref,error_message)
	SELECT
	 qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	 NULL,NULL, 'PRL', 'QP_INTERFACE_PRICING_ATTRIBS',  NULL,
	 orig_sys_header_ref,orig_sys_line_ref,null,orig_sys_pricing_attr_ref, l_msg_txt
	  FROM  QP_INTERFACE_PRICING_ATTRIBS qpip
	 WHERE  request_id = p_request_id
	   AND  process_status_flag = 'P' --is null
	   AND  interface_action_code = 'DELETE'
       AND  EXISTS  (SELECT 'PRICE BREAK CHILD LINE'
                     FROM qp_list_lines la, qp_rltd_modifiers ra
                     WHERE la.orig_sys_line_ref = qpip.orig_sys_line_ref
                       AND ra.to_rltd_modifier_id = la.list_line_id
                       AND ra.rltd_modifier_grp_type = 'PRICE BREAK'
                     )
	   AND  pricing_attr_value_to <>
                    (SELECT max(to_number(pb.pricing_attr_value_to))
                     FROM qp_list_lines la, qp_rltd_modifiers ra,
                          qp_rltd_modifiers rb, qp_pricing_attributes pb
                     WHERE la.orig_sys_line_ref = qpip.orig_sys_line_ref
                       AND ra.to_rltd_modifier_id = la.list_line_id
                       AND ra.rltd_modifier_grp_type = 'PRICE BREAK'
                       AND ra.from_rltd_modifier_id = rb.from_rltd_modifier_id
                       AND rb.to_rltd_modifier_id = pb.list_line_id) ;
     --Bug# 5253114 RAVI END


     --set process status flag
     QP_BULK_VALIDATE.MARK_ERRORED_INTERFACE_RECORD
      ('PRICING_ATTRIBS',
        p_request_id);


      --delete the records
       DELETE FROM QP_PRICING_ATTRIBUTES
	WHERE pricing_attribute_id IN
	(SELECT pa.pricing_attribute_id
	   FROM QP_INTERFACE_PRICING_ATTRIBS ipa, QP_PRICING_ATTRIBUTES pa
	  WHERE ipa.request_id = p_request_id
	    AND ipa.interface_action_code = 'DELETE'
	    AND ipa.process_status_flag = 'P' --IS NULL
            AND ipa.orig_sys_line_ref = pa.orig_sys_line_ref
            AND ipa.orig_sys_header_ref = pa.orig_sys_header_ref
            AND ipa.orig_sys_pricing_attr_ref = pa.orig_sys_pricing_attr_ref);

       qp_bulk_loader_pub.write_log('Number of PA deleted: '||to_char(SQL%ROWCOUNT));
     --Set process_status_flag of sucessfully deleted records
       UPDATE qp_interface_pricing_attribs
	  SET process_status_flag ='I'
	WHERE process_status_flag = 'P' --IS NULL
	  AND request_id = p_request_id
	  AND interface_action_code  = 'DELETE';

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXPECTED ERROR IN QP_BULK_UTIL.DELETE_PRICING_ATTR:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       qp_bulk_loader_pub.write_log('Leaving Delete Pricing Attribute');

END  DELETE_PRICING_ATTR;


END QP_BULK_UTIL;

/
