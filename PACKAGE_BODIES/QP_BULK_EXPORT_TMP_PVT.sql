--------------------------------------------------------
--  DDL for Package Body QP_BULK_EXPORT_TMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_EXPORT_TMP_PVT" AS
/* $Header: QPXBTEXB.pls 120.2 2005/11/07 01:45:05 srashmi noship $ */
PROCEDURE EXPORT_TMP_PRICING_DATA
(
  err_buff     OUT NOCOPY  VARCHAR2
 ,retcode      OUT NOCOPY  NUMBER
 ,list_from                NUMBER
 ,list_to                  NUMBER
 ,p_entity_name            VARCHAR2
 ,interface_action	   VARCHAR2
)
IS
CURSOR C_PRIC_HEADER IS
select	unique list_header_id
from 	qp_list_headers_b
where	list_header_id between list_from and list_to;

l_list_header_id number;

BEGIN

     fnd_file.put_line(fnd_file.log, 'Start the export of Pricelists to the Interface table');
     fnd_file.put_line(fnd_file.log, 'Price List ID From: '||to_char(list_from));
     fnd_file.put_line(fnd_file.log, 'Price List ID TO  : '||to_char(list_to));

     fnd_file.put_line(fnd_file.log, 'Interface Action Code: '||interface_action);
     if interface_action is not NULL and
	(interface_action = 'INSERT' or
	 interface_action = 'UPDATE' or
	 interface_action = 'DELETE') then
		g_interface_action := interface_action;
     else
		g_interface_action := 'INSERT';
     end if;
     fnd_file.put_line(fnd_file.log, 'G Interface Action Code: '||g_interface_action);
     OPEN C_PRIC_HEADER;
     LOOP
       FETCH C_PRIC_HEADER into l_list_header_id;

     EXIT WHEN C_PRIC_HEADER%NOTFOUND;

       fnd_file.put_line(fnd_file.log, 'Processing Price List : '||to_char(l_list_header_id));
	export_tmp_lists(
		list_from => l_list_header_id,
		p_entity_name => p_entity_name);
	commit;
       fnd_file.put_line(fnd_file.log, 'END Processing Price List : '||to_char(l_list_header_id));
     END LOOP;
     fnd_file.put_line(fnd_file.log, 'END Processing ');
END;

PROCEDURE EXPORT_TMP_LISTS
(
        list_from                      NUMBER
        ,p_entity_name                  VARCHAR2
)
IS
l_PRICE_LIST_rec  QP_Price_List_PUB.Price_List_Rec_Type;

CURSOR C_PRIC_QUALIFIERS IS
SELECT	QUALIFIER_ID
FROM	QP_QUALIFIERS
WHERE	LIST_HEADER_ID=LIST_FROM;

CURSOR C_PRIC_LINES IS
SELECT LIST_LINE_ID
FROM	QP_LIST_LINES
WHERE	LIST_HEADER_ID=LIST_FROM;

CURSOR C_PRIC_ATTRIBS IS
SELECT PRICING_ATTRIBUTE_ID
FROM QP_PRICING_ATTRIBUTES
WHERE LIST_HEADER_ID = LIST_FROM;

l_list_line_id number;
l_list_qualifier_id number;
l_list_attrib_id number;
l_orig_sys_header_ref varchar2(50);

BEGIN
      fnd_file.put_line(fnd_file.log, 'In EXPORT_TMP_LISTS ');
      l_PRICE_LIST_rec := QP_Price_List_Util.Query_Row
        (   p_list_header_id        => list_from
        );
      fnd_file.put_line(fnd_file.log, 'Inserting Pricelist '||l_PRICE_LIST_rec.name);
      if g_interface_action = 'INSERT' then
	 l_orig_sys_header_ref := p_entity_name || l_PRICE_LIST_rec.list_header_id;
      else
	begin
	select orig_system_header_ref
	into	l_orig_sys_header_ref
	from	qp_list_headers_b
	where 	list_header_id = l_PRICE_LIST_rec.list_header_id;
	exception
		when others then
			null;
	end;
      end if;
      INSERT INTO qp_interface_list_headers
	(list_header_id
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
       ,start_date_active
       ,end_date_active
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
       ,global_flag)
	values
	(l_PRICE_LIST_rec.list_header_id
       ,l_PRICE_LIST_rec.creation_date
       ,l_PRICE_LIST_rec.created_by
       ,l_PRICE_LIST_rec.last_update_date
       ,l_PRICE_LIST_rec.last_updated_by
       ,l_PRICE_LIST_rec.last_update_login
       ,l_PRICE_LIST_rec.program_application_id
       ,l_PRICE_LIST_rec.program_id
       ,l_PRICE_LIST_rec.program_update_date
       ,NULL
       ,l_PRICE_LIST_rec.list_type_code
       ,fnd_date.date_to_canonical(l_PRICE_LIST_rec.start_date_active)
       ,fnd_date.date_to_canonical(l_PRICE_LIST_rec.end_date_active)
       ,'US'
       ,l_PRICE_LIST_rec.automatic_flag
       ,(p_entity_name || l_PRICE_LIST_rec.name)
       ,l_PRICE_LIST_rec.description
       ,l_PRICE_LIST_rec.currency_code
       ,l_PRICE_LIST_rec.version_no
       ,l_PRICE_LIST_rec.rounding_factor
       ,l_PRICE_LIST_rec.ship_method_code
       ,l_PRICE_LIST_rec.freight_terms_code
       ,l_PRICE_LIST_rec.terms_id
       ,l_PRICE_LIST_rec.comments
       ,l_PRICE_LIST_rec.discount_lines_flag
       ,l_PRICE_LIST_rec.gsa_indicator
       ,l_PRICE_LIST_rec.prorate_flag
       ,l_PRICE_LIST_rec.source_system_code
       ,NULL --l_PRICE_LIST_rec.ask_for_flag
       ,l_PRICE_LIST_rec.active_flag
       ,NULL --l_PRICE_LIST_rec.parent_list_header_id
       ,NULL --l_PRICE_LIST_rec.active_date_first_type
       ,NULL --l_PRICE_LIST_rec.start_date_active_first
       ,NULL --l_PRICE_LIST_rec.end_date_active_first
       ,NULL --l_PRICE_LIST_rec.active_date_second_type
       ,NULL --l_PRICE_LIST_rec.start_date_active_second
       ,NULL --l_PRICE_LIST_rec.end_date_active_second
       ,l_PRICE_LIST_rec.context
       ,l_PRICE_LIST_rec.attribute1
       ,l_PRICE_LIST_rec.attribute2
       ,l_PRICE_LIST_rec.attribute3
       ,l_PRICE_LIST_rec.attribute4
       ,l_PRICE_LIST_rec.attribute5
       ,l_PRICE_LIST_rec.attribute6
       ,l_PRICE_LIST_rec.attribute7
       ,l_PRICE_LIST_rec.attribute8
       ,l_PRICE_LIST_rec.attribute9
       ,l_PRICE_LIST_rec.attribute10
       ,l_PRICE_LIST_rec.attribute11
       ,l_PRICE_LIST_rec.attribute12
       ,l_PRICE_LIST_rec.attribute13
       ,l_PRICE_LIST_rec.attribute14
       ,l_PRICE_LIST_rec.attribute15
       ,'US'
       ,NULL
       ,NULL
       ,DECODE( g_interface_action, 'DELETE', 'UPDATE', g_interface_action) --,'INSERT'
       ,NULL
       ,'Y'
       ,NULL
       ,'P' --NULL
       ,l_PRICE_LIST_rec.mobile_download
       ,l_PRICE_LIST_rec.currency_header_id
       ,l_PRICE_LIST_rec.pte_code
       ,l_PRICE_LIST_rec.list_source_code
       ,l_orig_sys_header_ref
       --added for MOAC - uncommented below for MOAC
       ,l_PRICE_LIST_rec.org_id
       ,l_PRICE_LIST_rec.global_flag);

     fnd_file.put_line(fnd_file.log, 'Inserted Pricelist ORIG_SYS_HEADER_REF'|| p_entity_name || l_PRICE_LIST_rec.list_header_id);

     OPEN C_PRIC_QUALIFIERS;
     LOOP
       FETCH C_PRIC_QUALIFIERS into l_list_qualifier_id;
     EXIT WHEN C_PRIC_QUALIFIERS%NOTFOUND;
       fnd_file.put_line(fnd_file.log, 'Processing Qualifier : '||to_char(l_list_qualifier_id));
	export_tmp_qualifiers(
		list_from => l_list_qualifier_id,
		p_entity_name => p_entity_name);

     END LOOP;
       fnd_file.put_line(fnd_file.log, 'END Processing Qualifier : '||to_char(l_list_qualifier_id));

     OPEN C_PRIC_LINES;
     LOOP
       FETCH C_PRIC_LINES into l_list_line_id;
     EXIT WHEN C_PRIC_LINES%NOTFOUND;
       fnd_file.put_line(fnd_file.log, 'Processing Price List line : '||to_char(l_list_line_id));
	export_tmp_lines(
		list_from => l_list_line_id,
		p_entity_name => p_entity_name);

     END LOOP;
       fnd_file.put_line(fnd_file.log, 'END Processing Price List Line: '||to_char(l_list_line_id));

     OPEN C_PRIC_ATTRIBS;
     LOOP
       FETCH C_PRIC_ATTRIBS into l_list_attrib_id;
     EXIT WHEN C_PRIC_ATTRIBS%NOTFOUND;
       fnd_file.put_line(fnd_file.log, 'Processing Product/Price Attribs : '||to_char(l_list_attrib_id));
	export_tmp_attribs(
		list_from => l_list_attrib_id,
		p_entity_name => p_entity_name);

     END LOOP;
       fnd_file.put_line(fnd_file.log, 'END Processing Product/Price Attribs : '||to_char(l_list_attrib_id));
END ;

PROCEDURE EXPORT_TMP_QUALIFIERS
(
        list_from                      NUMBER
        ,p_entity_name                  VARCHAR2
)
IS
l_QUALIFIER_rec  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_orig_sys_header_ref varchar2(50);
l_orig_sys_line_ref	varchar2(50);
l_orig_sys_qualifier_ref	varchar2(50);

Begin
      fnd_file.put_line(fnd_file.log, 'In EXPORT_TMP_QUALIFIERS ');
      l_QUALIFIER_rec := QP_QUALIFIERS_UTIL.Query_Row
        (   p_qualifier_id        => list_from
        );
      fnd_file.put_line(fnd_file.log, 'Inserting Qualifier '||to_char(l_QUALIFIER_rec.qualifier_id));
      if g_interface_action = 'INSERT' then
	 l_orig_sys_qualifier_ref := p_entity_name || l_QUALIFIER_rec.qualifier_id;
	 l_orig_sys_header_ref := p_entity_name || l_QUALIFIER_rec.list_header_id;
      else
	begin
	select orig_sys_qualifier_ref, orig_sys_header_ref
	into	l_orig_sys_qualifier_ref, l_orig_sys_header_ref
	from	qp_qualifiers
	where 	qualifier_id = l_QUALIFIER_rec.qualifier_id;
	exception
		when others then
			null;
	end;
      end if;
	INSERT INTO QP_INTERFACE_QUALIFIERS
     	    (QUALIFIER_ID
	    ,REQUEST_ID
	    ,QUALIFIER_GROUPING_NO
            ,QUALIFIER_CONTEXT
	    ,QUALIFIER_ATTRIBUTE
	    ,QUALIFIER_ATTR_VALUE
	    ,QUALIFIER_ATTR_VALUE_TO
	    ,QUALIFIER_DATATYPE
	    ,QUALIFIER_PRECEDENCE
	    ,COMPARISON_OPERATOR_CODE
	    ,EXCLUDER_FLAG
	    ,START_DATE_ACTIVE
	    ,END_DATE_ACTIVE
	    ,LIST_HEADER_ID
	    ,LIST_LINE_ID
	    ,QUALIFIER_RULE_ID
	    ,CREATED_FROM_RULE_ID
	    ,ACTIVE_FLAG
	    ,LIST_TYPE_CODE
	    ,QUAL_ATTR_VALUE_FROM_NUMBER
	    ,QUAL_ATTR_VALUE_TO_NUMBER
	    ,QUALIFIER_GROUP_CNT
	    ,HEADER_QUALS_EXIST_FLAG
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
	    ,PROCESS_ID
	    ,PROCESS_TYPE
	    ,INTERFACE_ACTION_CODE
	    ,LOCK_FLAG
	    ,PROCESS_FLAG
	    ,DELETE_FLAG
	    ,PROCESS_STATUS_FLAG
	    ,LIST_LINE_NO
	    ,CREATED_FROM_RULE
	    ,QUALIFIER_RULE
	    ,QUALIFIER_ATTRIBUTE_CODE
	    ,QUALIFIER_ATTR_VALUE_CODE
	    ,QUALIFIER_ATTR_VALUE_TO_CODE
	    ,ATTRIBUTE_STATUS
	    ,ORIG_SYS_HEADER_REF
	    ,ORIG_SYS_QUALIFIER_REF
	    ,ORIG_SYS_LINE_REF
            ,QUALIFY_HIER_DESCENDENTS_FLAG)
	values
     	    (l_Qualifier_Rec.QUALIFIER_ID
	    ,l_Qualifier_Rec.REQUEST_ID
	    ,l_Qualifier_Rec.QUALIFIER_GROUPING_NO
            ,l_Qualifier_Rec.QUALIFIER_CONTEXT
	    ,l_Qualifier_Rec.QUALIFIER_ATTRIBUTE
	    ,l_Qualifier_Rec.QUALIFIER_ATTR_VALUE
	    ,l_Qualifier_Rec.QUALIFIER_ATTR_VALUE_TO
	    ,l_Qualifier_Rec.QUALIFIER_DATATYPE
	    ,l_Qualifier_Rec.QUALIFIER_PRECEDENCE
	    ,l_Qualifier_Rec.COMPARISON_OPERATOR_CODE
	    ,l_Qualifier_Rec.EXCLUDER_FLAG
	    ,l_Qualifier_Rec.START_DATE_ACTIVE
	    ,l_Qualifier_Rec.END_DATE_ACTIVE
	    ,l_Qualifier_Rec.LIST_HEADER_ID
	    ,l_Qualifier_Rec.LIST_LINE_ID
	    ,l_Qualifier_Rec.QUALIFIER_RULE_ID
	    ,l_Qualifier_Rec.CREATED_FROM_RULE_ID
	    ,l_Qualifier_Rec.ACTIVE_FLAG
	    ,l_Qualifier_Rec.LIST_TYPE_CODE
	    ,l_Qualifier_Rec.QUAL_ATTR_VALUE_FROM_NUMBER
	    ,l_Qualifier_Rec.QUAL_ATTR_VALUE_TO_NUMBER
	    ,l_Qualifier_Rec.QUALIFIER_GROUP_CNT
	    ,l_Qualifier_Rec.HEADER_QUALS_EXIST_FLAG
	    ,l_Qualifier_Rec.CONTEXT
	    ,l_Qualifier_Rec.ATTRIBUTE1
	    ,l_Qualifier_Rec.ATTRIBUTE2
	    ,l_Qualifier_Rec.ATTRIBUTE3
	    ,l_Qualifier_Rec.ATTRIBUTE4
	    ,l_Qualifier_Rec.ATTRIBUTE5
	    ,l_Qualifier_Rec.ATTRIBUTE6
	    ,l_Qualifier_Rec.ATTRIBUTE7
	    ,l_Qualifier_Rec.ATTRIBUTE8
	    ,l_Qualifier_Rec.ATTRIBUTE9
	    ,l_Qualifier_Rec.ATTRIBUTE10
	    ,l_Qualifier_Rec.ATTRIBUTE11
	    ,l_Qualifier_Rec.ATTRIBUTE12
	    ,l_Qualifier_Rec.ATTRIBUTE13
	    ,l_Qualifier_Rec.ATTRIBUTE14
	    ,l_Qualifier_Rec.ATTRIBUTE15
	    ,NULL
	    ,NULL
	    ,g_interface_action  --,'INSERT'
	    ,NULL
            ,'Y'
	    ,NULL
	    ,'P' --NULL
	    ,NULL --l_Qualifier_Rec.LIST_LINE_NO
	    ,NULL
	    ,NULL
	    ,NULL
	    ,NULL
	    ,NULL
	    ,NULL
	    ,l_orig_sys_header_ref --(p_entity_name || to_char(l_Qualifier_Rec.list_header_id))
	    ,l_orig_sys_qualifier_ref --(p_entity_name || to_char(l_Qualifier_Rec.qualifier_id))
	    ,NULL
            ,l_Qualifier_Rec.QUALIFY_HIER_DESCENDENT_FLAG);
      fnd_file.put_line(fnd_file.log, 'Inserted Qualifier '|| (p_entity_name || to_char(l_Qualifier_Rec.qualifier_id)));
end;

PROCEDURE EXPORT_TMP_LINES
(
        list_from                      NUMBER
        ,p_entity_name                  VARCHAR2
)
IS
l_LINE_rec  QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_orig_sys_header_ref varchar2(50);
l_orig_sys_line_ref	varchar2(50);
l_orig_sys_pricing_attr_ref	varchar2(50);
l_price_break_header_ref	varchar2(50);
Begin
      fnd_file.put_line(fnd_file.log, 'In EXPORT_TMP_LINES ');
      l_LINE_rec := QP_Price_List_Line_Util.Query_Row
        (   p_list_line_id        => list_from
        );
      fnd_file.put_line(fnd_file.log, 'Inserting Line '||to_char(l_LINE_rec.list_line_id));
      if g_interface_action = 'INSERT' then
	 l_orig_sys_line_ref := p_entity_name || l_LINE_rec.list_line_id;
	 l_orig_sys_header_ref := p_entity_name || l_LINE_rec.list_header_id;
	if l_LINE_Rec.from_rltd_modifier_id is not NULL then
	 l_price_break_header_ref := p_entity_name ||  l_LINE_Rec.from_rltd_modifier_id;
	end if;
      else
	begin
	select orig_sys_line_ref, orig_sys_header_ref
	into	l_orig_sys_line_ref, l_orig_sys_header_ref
	from	qp_list_lines
	where 	list_line_id = l_LINE_rec.list_line_id;
	exception
		when others then
			null;
	end;
	if l_LINE_Rec.from_rltd_modifier_id is not NULL then
	    begin
	    select orig_sys_line_ref
	    into	l_price_break_header_ref
	    from	qp_list_lines
	    where 	list_line_id = l_LINE_rec.from_rltd_modifier_id;
	    exception
		    when others then
			    null;
	    end;
	end if;
      end if;
	INSERT into qp_interface_list_lines
  	   (LIST_LINE_ID
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
	   ,PROCESS_ID
	   ,PROCESS_TYPE
	   ,INTERFACE_ACTION_CODE
	   ,LOCK_FLAG
	   ,PROCESS_FLAG
	   ,DELETE_FLAG
	   ,PROCESS_STATUS_FLAG
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
	   ,INCLUDE_ON_RETURNS_FLAG
	   ,QUALIFICATION_IND
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
	   ,RLTD_MODIFIER_GRP_NO
	   ,RLTD_MODIFIER_GRP_TYPE
	   ,PRICE_BREAK_HEADER_REF
	   ,PRICING_PHASE_NAME
	   ,PRICE_BY_FORMULA
	   ,GENERATE_USING_FORMULA
	   ,ATTRIBUTE_STATUS
	   ,ORIG_SYS_LINE_REF
	   ,ORIG_SYS_HEADER_REF
	   ,RECURRING_VALUE
	   ,NET_AMOUNT_FLAG)
	values
  	   (l_LINE_Rec.LIST_LINE_ID
	   , l_LINE_Rec.PROGRAM_APPLICATION_ID
	   , l_LINE_Rec.PROGRAM_ID
	   , l_LINE_Rec.PROGRAM_UPDATE_DATE
	   , NULL
	   , l_LINE_Rec.LIST_HEADER_ID
	   , l_LINE_Rec.LIST_LINE_TYPE_CODE
	   , l_LINE_Rec.START_DATE_ACTIVE
	   , l_LINE_Rec.END_DATE_ACTIVE
	   , l_LINE_Rec.AUTOMATIC_FLAG
	   , l_LINE_Rec.MODIFIER_LEVEL_CODE
	   , l_LINE_Rec.PRICE_BY_FORMULA_ID
	   , l_LINE_Rec.LIST_PRICE
	   , NULL --l_LINE_Rec.LIST_PRICE_UOM_CODE
	   , l_LINE_Rec.PRIMARY_UOM_FLAG
	   , l_LINE_Rec.INVENTORY_ITEM_ID
	   , l_LINE_Rec.ORGANIZATION_ID
	   , l_LINE_Rec.RELATED_ITEM_ID
	   , l_LINE_Rec.RELATIONSHIP_TYPE_ID
	   , l_LINE_Rec.SUBSTITUTION_CONTEXT
	   , l_LINE_Rec.SUBSTITUTION_ATTRIBUTE
	   , l_LINE_Rec.SUBSTITUTION_VALUE
	   , l_LINE_Rec.REVISION
	   , l_LINE_Rec.REVISION_DATE
	   , l_LINE_Rec.REVISION_REASON_CODE
	   , l_LINE_Rec.PRICE_BREAK_TYPE_CODE
	   , l_LINE_Rec.PERCENT_PRICE
	   , l_LINE_Rec.NUMBER_EFFECTIVE_PERIODS
	   , l_LINE_Rec.EFFECTIVE_PERIOD_UOM
	   , l_LINE_Rec.ARITHMETIC_OPERATOR
	   , l_LINE_Rec.OPERAND
	   , l_LINE_Rec.OVERRIDE_FLAG
	   , l_LINE_Rec.PRINT_ON_INVOICE_FLAG
	   , NULL --l_LINE_Rec.REBATE_TRANSACTION_TYPE_CODE
	   , l_LINE_Rec.BASE_QTY
	   , l_LINE_Rec.BASE_UOM_CODE
	   , l_LINE_Rec.ACCRUAL_QTY
	   , l_LINE_Rec.ACCRUAL_UOM_CODE
	   , l_LINE_Rec.ESTIM_ACCRUAL_RATE
	   , NULL
	   , NULL
	   , g_interface_action  --, 'INSERT'
	   , NULL
            ,'Y'
	   , NULL
	   ,'P' -- NULL
	   , l_LINE_Rec.COMMENTS
	   , l_LINE_Rec.GENERATE_USING_FORMULA_ID
	   , l_LINE_Rec.REPRICE_FLAG
	   , l_LINE_Rec.LIST_LINE_NO
	   , NULL --l_LINE_Rec.ESTIM_GL_VALUE
	   , NULL --l_LINE_Rec.BENEFIT_PRICE_LIST_LINE_ID
	   , NULL --l_LINE_Rec.EXPIRATION_PERIOD_START_DATE
	   , NULL --l_LINE_Rec.NUMBER_EXPIRATION_PERIODS
	   , NULL --l_LINE_Rec.EXPIRATION_PERIOD_UOM
	   , NULL --l_LINE_Rec.EXPIRATION_DATE
	   , NULL --l_LINE_Rec.ACCRUAL_FLAG
	   , NULL --l_LINE_Rec.PRICING_PHASE_ID
	   , NULL --l_LINE_Rec.PRICING_GROUP_SEQUENCE
	   , NULL --l_LINE_Rec.INCOMPATIBILITY_GRP_CODE
	   , l_LINE_Rec.PRODUCT_PRECEDENCE
	   , NULL --l_LINE_Rec.PRORATION_TYPE_CODE
	   , NULL --l_LINE_Rec.ACCRUAL_CONVERSION_RATE
	   , NULL --l_LINE_Rec.BENEFIT_QTY
	   , NULL --l_LINE_Rec.BENEFIT_UOM_CODE
	   , NULL --l_LINE_Rec.RECURRING_FLAG
	   , NULL --l_LINE_Rec.BENEFIT_LIMIT
	   , NULL -- l_LINE_Rec.CHARGE_TYPE_CODE
	   , NULL --l_LINE_Rec.CHARGE_SUBTYPE_CODE
	   , NULL --l_LINE_Rec.INCLUDE_ON_RETURNS_FLAG
	   , l_LINE_Rec.QUALIFICATION_IND
	   , l_LINE_Rec.CONTEXT
	   , l_LINE_Rec.ATTRIBUTE1
	   , l_LINE_Rec.ATTRIBUTE2
	   , l_LINE_Rec.ATTRIBUTE3
	   , l_LINE_Rec.ATTRIBUTE4
	   , l_LINE_Rec.ATTRIBUTE5
	   , l_LINE_Rec.ATTRIBUTE6
	   , l_LINE_Rec.ATTRIBUTE7
	   , l_LINE_Rec.ATTRIBUTE8
	   , l_LINE_Rec.ATTRIBUTE9
	   , l_LINE_Rec.ATTRIBUTE10
	   , l_LINE_Rec.ATTRIBUTE11
	   , l_LINE_Rec.ATTRIBUTE12
	   , l_LINE_Rec.ATTRIBUTE13
	   , l_LINE_Rec.ATTRIBUTE14
	   , l_LINE_Rec.ATTRIBUTE15
	   , l_LINE_Rec.RLTD_MODIFIER_GROUP_NO
	   , l_LINE_Rec.RLTD_MODIFIER_GRP_TYPE
	   , l_price_break_header_ref	--PRICE_BREAK_HEADER_REF
	   , NULL --l_LINE_Rec.PRICING_PHASE_NAME
	   , NULL --l_LINE_Rec.PRICE_BY_FORMULA
	   , NULL --l_LINE_Rec.GENERATE_USING_FORMULA
	   , NULL
	   ,l_ORIG_SYS_LINE_REF
	   ,l_ORIG_SYS_HEADER_REF
	   --, p_entity_name || to_char(l_LINE_Rec.list_line_id)
	   --, p_entity_name || to_char(l_LINE_Rec.list_header_id)
	   , l_LINE_Rec.RECURRING_VALUE
	   , NULL); --l_LINE_Rec.NET_AMOUNT_FLAG);

      fnd_file.put_line(fnd_file.log, 'Inserted Line '|| p_entity_name || to_char(l_LINE_Rec.list_line_id));

end;

PROCEDURE EXPORT_TMP_ATTRIBS
(
        list_from                      NUMBER
        ,p_entity_name                  VARCHAR2
)
IS
l_attribs_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_orig_sys_header_ref varchar2(50);
l_orig_sys_line_ref	varchar2(50);
l_orig_sys_pricing_attr_ref	varchar2(50);
begin
      fnd_file.put_line(fnd_file.log, 'In EXPORT_TMP_ATTRIBS ');
      l_attribs_rec := Qp_pll_pricing_attr_Util.Query_Row
        (   p_pricing_attribute_id        => list_from
        );
      fnd_file.put_line(fnd_file.log, 'Inserting Attribs '||to_char(l_attribs_rec.pricing_attribute_id));
      if g_interface_action = 'INSERT' then
	 l_orig_sys_pricing_attr_ref := p_entity_name || l_attribs_rec.pricing_attribute_id;
	 l_orig_sys_line_ref := p_entity_name || l_attribs_rec.list_line_id;
	 l_orig_sys_header_ref := p_entity_name || l_attribs_rec.list_header_id;
      else
	begin
	select orig_sys_line_ref, orig_sys_header_ref, orig_sys_pricing_attr_ref
	into	l_orig_sys_line_ref, l_orig_sys_header_ref, l_orig_sys_pricing_attr_ref
	from	qp_pricing_attributes
	where 	pricing_attribute_id = l_attribs_rec.pricing_attribute_id;
	exception
		when others then
			null;
	end;
      end if;
	insert into qp_interface_pricing_attribs
             ( PRICING_ATTRIBUTE_ID
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
	     ,LIST_HEADER_ID
	     ,PRICING_PHASE_ID
	     ,QUALIFICATION_IND
	     ,PRICING_ATTR_VALUE_FROM_NUMBER
	     ,PRICING_ATTR_VALUE_TO_NUMBER
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
	     ,PROCESS_ID
	     ,PROCESS_TYPE
	     ,INTERFACE_ACTION_CODE
	     ,LOCK_FLAG
	     ,PROCESS_FLAG
	     ,DELETE_FLAG
	     ,PROCESS_STATUS_FLAG
	     ,PRICE_LIST_LINE_INDEX
	     ,LIST_LINE_NO
	     ,ORIG_SYS_PRICING_ATTR_REF
	     ,PRODUCT_ATTR_CODE
	     ,PRODUCT_ATTR_VAL_DISP
	     ,PRICING_ATTR_CODE
	     ,PRICING_ATTR_VALUE_FROM_DISP
	     ,PRICING_ATTR_VALUE_TO_DISP
	     ,ATTRIBUTE_STATUS
	     ,ORIG_SYS_LINE_REF
	     ,ORIG_SYS_HEADER_REF)
	values
              ( l_attribs_rec.PRICING_ATTRIBUTE_ID
	     ,l_attribs_rec.PROGRAM_APPLICATION_ID
	     ,l_attribs_rec.PROGRAM_ID
	     ,l_attribs_rec.PROGRAM_UPDATE_DATE
	     , NULL --l_attribs_rec.REQUEST_ID
	     ,l_attribs_rec.LIST_LINE_ID
	     ,l_attribs_rec.EXCLUDER_FLAG
	     ,l_attribs_rec.ACCUMULATE_FLAG
	     ,l_attribs_rec.PRODUCT_ATTRIBUTE_CONTEXT
	     ,l_attribs_rec.PRODUCT_ATTRIBUTE
	     ,l_attribs_rec.PRODUCT_ATTR_VALUE
	     ,l_attribs_rec.PRODUCT_UOM_CODE
	     ,l_attribs_rec.PRICING_ATTRIBUTE_CONTEXT
	     ,l_attribs_rec.PRICING_ATTRIBUTE
	     ,l_attribs_rec.PRICING_ATTR_VALUE_FROM
	     ,l_attribs_rec.PRICING_ATTR_VALUE_TO
	     ,l_attribs_rec.ATTRIBUTE_GROUPING_NO
	     ,l_attribs_rec.PRODUCT_ATTRIBUTE_DATATYPE
	     ,l_attribs_rec.PRICING_ATTRIBUTE_DATATYPE
	     ,l_attribs_rec.COMPARISON_OPERATOR_CODE
	     ,l_attribs_rec.LIST_HEADER_ID
	     ,l_attribs_rec.PRICING_PHASE_ID
	     ,l_attribs_rec.QUALIFICATION_IND
	     ,l_attribs_rec.PRICING_ATTR_VALUE_FROM_NUMBER
	     ,l_attribs_rec.PRICING_ATTR_VALUE_TO_NUMBER
	     ,l_attribs_rec.CONTEXT
	     ,l_attribs_rec.ATTRIBUTE1
	     ,l_attribs_rec.ATTRIBUTE2
	     ,l_attribs_rec.ATTRIBUTE3
	     ,l_attribs_rec.ATTRIBUTE4
	     ,l_attribs_rec.ATTRIBUTE5
	     ,l_attribs_rec.ATTRIBUTE6
	     ,l_attribs_rec.ATTRIBUTE7
	     ,l_attribs_rec.ATTRIBUTE8
	     ,l_attribs_rec.ATTRIBUTE9
	     ,l_attribs_rec.ATTRIBUTE10
	     ,l_attribs_rec.ATTRIBUTE11
	     ,l_attribs_rec.ATTRIBUTE12
	     ,l_attribs_rec.ATTRIBUTE13
	     ,l_attribs_rec.ATTRIBUTE14
	     ,l_attribs_rec.ATTRIBUTE15
	     , NULL --_attribs_rec.PROCESS_ID
	     , NULL --_attribs_rec.PROCESS_TYPE
	     , g_interface_action --,'INSERT' --l_attribs_rec.INTERFACE_ACTION_CODE
	     , NULL --_attribs_rec.LOCK_FLAG
             ,'Y'   --_attribs_rec.PROCESS_FLAG
	     , NULL --_attribs_rec.DELETE_FLAG
	     ,'P' -- NULL --_attribs_rec.PROCESS_STATUS_FLAG
	     ,l_attribs_rec.PRICE_LIST_LINE_INDEX
	     , NULL  --l_attribs_rec.LIST_LINE_NO
	     --,(p_entity_name || l_attribs_rec.pricing_attribute_id)
	     ,l_ORIG_SYS_PRICING_ATTR_REF
	     , NULL --_attribs_rec.PRODUCT_ATTR_CODE
	     , NULL --_attribs_rec.PRODUCT_ATTR_VAL_DISP
	     , NULL --_attribs_rec.PRICING_ATTR_CODE
	     , NULL --_attribs_rec.PRICING_ATTR_VALUE_FROM_DISP
	     , NULL --_attribs_rec.PRICING_ATTR_VALUE_TO_DISP
	     , NULL --_attribs_rec.ATTRIBUTE_STATUS
	     ,l_ORIG_SYS_LINE_REF
	     ,l_ORIG_SYS_HEADER_REF);
	     --,(p_entity_name || to_char(l_attribs_rec.list_line_id)) --ORIG_SYS_LINE_REF
	     --,(p_entity_name || to_char(l_attribs_rec.list_header_id))); --ORIG_SYS_HEADER_REF);
      fnd_file.put_line(fnd_file.log, 'Inserting Attribs '||(p_entity_name || to_char(l_attribs_rec.pricing_attribute_id)));

end;

END QP_BULK_EXPORT_TMP_PVT;

/
