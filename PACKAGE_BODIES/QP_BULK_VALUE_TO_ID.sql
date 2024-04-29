--------------------------------------------------------
--  DDL for Package Body QP_BULK_VALUE_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BULK_VALUE_TO_ID" AS
/* $Header: QPXBVIDB.pls 120.3.12010000.5 2009/04/03 21:05:18 rbadadar ship $ */

PROCEDURE HEADER
             (p_request_id  IN NUMBER)

IS
BEGIN

   qp_bulk_loader_pub.write_log( 'Entering Value to ID Header');

   -- 1. Currency Header

    -- If Multi Currency Option is Set to Yes then process_status_flag should  be set to 'E'
    -- Fix for bug# 3570115

    If (NVL(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED'),'N') = 'Y') THEN
     Update qp_interface_list_headers ih
	set    (currency_header_id, process_status_flag, attribute_status)=
      (select  c.currency_header_id,
	       	decode(c.currency_header_id, null, null, 'P'),
		decode(c.currency_header_id, null, ih.attribute_status||'001', ih.attribute_status)
          from     qp_currency_lists_vl c,
                        qp_interface_list_headers iih
          where  iih.currency_header = c.name(+)
          and    iih.currency_code = c.base_currency_code(+)
          and    ih.rowid  = iih.rowid
          )
      Where       ih.request_id = p_request_id
      and	  ih.process_status_flag = 'P' --IS NOT NULL
      and         ih.currency_header is not null
      --Bug# 5412029
      --Don't do conversion if Value is G_NULL_CHAR
      and         ih.currency_header <> QP_BULK_LOADER_PUB.G_NULL_CHAR
      and         ih.currency_header_id is null
      and         ih.interface_action_code in ('INSERT','UPDATE');
     End If;

   --2. Freight Terms Code
     Update qp_interface_list_headers ih
	set    (freight_terms_code, process_status_flag, attribute_status)=
        (select  c.freight_terms_code,
	decode(c.freight_terms_code, null, null, 'P'),
        decode(c.freight_terms_code, null, ih.attribute_status||'002', ih.attribute_status)
          from     OE_FRGHT_TERMS_ACTIVE_V c,
                   qp_interface_list_headers iih
          where  iih.freight_terms = c.freight_terms(+)
	  and    sysdate between nvl(c.start_date_active, sysdate)
			 and     nvl(c.end_date_active, sysdate)
          and    ih.rowid  = iih.rowid
        )
      Where         ih.request_id = p_request_id
        and	  ih.process_status_flag = 'P' --IS NOT NULL
	and         ih.freight_terms is not null
        --Bug# 5412029
        --Don't do conversion if Value is G_NULL_CHAR
        and         ih.freight_terms <> QP_BULK_LOADER_PUB.G_NULL_CHAR
	and         ih.freight_terms_code is null
	and         ih.interface_action_code in ('INSERT','UPDATE');

  -- 3. Ship Method Code

     Update qp_interface_list_headers ih
	set    (ship_method_code, process_status_flag, attribute_status)=
        (select  c.lookup_code,
	decode(c.lookup_code, null, null, 'P'),
        decode(c.lookup_code, null, ih.attribute_status||'003', ih.attribute_status)
          from   OE_SHIP_METHODS_V c,
                 qp_interface_list_headers iih
          where  iih.ship_method = c.meaning(+)
	  and    c.lookup_type(+) = 'SHIP_METHOD'
	  and    sysdate between nvl(c.start_date_active, sysdate)
			 and     nvl(c.end_date_active, sysdate)
          and    ih.rowid  = iih.rowid
        )
      Where         ih.request_id = p_request_id
        and	  ih.process_status_flag = 'P' --IS NOT NULL
	and         ih.ship_method is not null
        --Bug# 5412029
        --Don't do conversion if Value is G_NULL_CHAR
        and         ih.ship_method <> QP_BULK_LOADER_PUB.G_NULL_CHAR
	and         ih.ship_method_code is null
	and         ih.interface_action_code in ('INSERT','UPDATE');

  -- 4. Terms Id

     Update qp_interface_list_headers ih
	set  (terms_id, process_status_flag, attribute_status)=
        (select  c.term_id,
	decode(c.term_id, null, null, 'P'),
        decode(c.term_id, null, ih.attribute_status||'004', ih.attribute_status)
          from   RA_TERMS  c,
                 qp_interface_list_headers iih
          where  iih.terms = c.name(+)
	  and    sysdate between nvl(c.start_date_active, sysdate)
			 and     nvl(c.end_date_active, sysdate)
          and    ih.rowid  = iih.rowid
        )
      Where         ih.request_id = p_request_id
        and	  ih.process_status_flag = 'P' --IS NOT NULL
	and         ih.terms is not null
        --Bug# 5412029
        --Don't do conversion if Value is G_NULL_CHAR
        and         ih.terms <> QP_BULK_LOADER_PUB.G_NULL_CHAR
	and         ih.terms_id is null
	and         ih.interface_action_code in ('INSERT','UPDATE');

   qp_bulk_loader_pub.write_log( 'Leaving Value to ID Header');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.HEADER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END HEADER;

PROCEDURE QUALIFIER
          (p_request_id  IN NUMBER)
IS

BEGIN

   qp_bulk_loader_pub.write_log( 'Entering Value to ID Qualifier');
   -- 1. CREATED_FROM_RULE
   UPDATE QP_INTERFACE_QUALIFIERS a
   SET(CREATED_FROM_RULE_ID, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT b.QUALIFIER_RULE_ID,
	DECODE(b.QUALIFIER_RULE_ID, NULL, null, 'P'),
   	DECODE(b.QUALIFIER_RULE_ID,NULL, a.ATTRIBUTE_STATUS||'001', a.ATTRIBUTE_STATUS)
	FROM  QP_QUALIFIER_RULES b, QP_INTERFACE_QUALIFIERS c
	WHERE c.CREATED_FROM_RULE = b.NAME(+)
	AND   a.rowid = c.rowid
	)
   WHERE a.REQUEST_ID = P_REQUEST_ID
   and	 a.process_status_flag = 'P' --IS NOT NULL
   AND   a.CREATED_FROM_RULE_ID IS NULL
   --Bug# 5456164
   --Don't do conversion if Value is G_NULL_CHAR
   AND   a.CREATED_FROM_RULE <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   a.CREATED_FROM_RULE IS NOT NULL
   AND   a.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

   -- 2.QUALIFIER_RULE

   UPDATE QP_INTERFACE_QUALIFIERS a
   SET(QUALIFIER_RULE_ID, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT b.QUALIFIER_RULE_ID,
	DECODE(b.QUALIFIER_RULE_ID, NULL, null, 'P'),
   	DECODE(b.QUALIFIER_RULE_ID,NULL, a.ATTRIBUTE_STATUS||'002', a.ATTRIBUTE_STATUS)
	FROM  QP_QUALIFIER_RULES b, QP_INTERFACE_QUALIFIERS c
	WHERE c.QUALIFIER_RULE = b.NAME(+)
	AND   a.rowid = c.rowid
	)
   WHERE a.REQUEST_ID = P_REQUEST_ID
   and	 a.process_status_flag = 'P' --IS NOT NULL
   AND   a.QUALIFIER_RULE_ID IS NULL
   --Bug# 5456164
   --Don't do conversion if Value is G_NULL_CHAR
   AND   a.QUALIFIER_RULE <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   a.QUALIFIER_RULE IS NOT NULL
   AND   a.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

  --3.Qualifier Attribute

   UPDATE QP_INTERFACE_QUALIFIERS qiq
   SET(QUALIFIER_ATTRIBUTE, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT a.segment_mapping_column,
         DECODE(a.segment_mapping_column, NULL, null, 'P'),
         DECODE(a.segment_mapping_column, NULL, qiq.ATTRIBUTE_STATUS||'003',qiq.ATTRIBUTE_STATUS)
	FROM qp_segments_v a, qp_prc_contexts_b b, qp_interface_qualifiers c
	WHERE b.prc_context_id = a.prc_context_id
	AND   b.prc_context_code = c.QUALIFIER_CONTEXT
	AND   a.segment_code = c.QUALIFIER_ATTRIBUTE_CODE
	AND   a.segment_mapping_column like 'QUALIFIER%'
	AND   qiq.rowid = c.rowid)
   WHERE qiq.REQUEST_ID = P_REQUEST_ID
   and	 qiq.process_status_flag = 'P' --IS NOT NULL
   AND   qiq.QUALIFIER_ATTRIBUTE IS NULL
   --Bug# 5456164
   --Don't do conversion if Value is G_NULL_CHAR
   AND   qiq.QUALIFIER_ATTRIBUTE_CODE <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   qiq.QUALIFIER_ATTRIBUTE_CODE IS NOT NULL
   AND   qiq.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');


 qp_bulk_loader_pub.write_log( 'Leaving Value to ID Qualifier');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.QUALIFIER:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


 END QUALIFIER;


PROCEDURE LINE
          (p_request_id  IN NUMBER)
IS

CURSOR c_price_attr IS
SELECT orig_sys_pricing_attr_ref,
       orig_sys_header_ref,
       orig_sys_line_ref,
       product_attribute_context,
       product_attribute,
       product_attr_code,
       product_attr_value,
       product_attr_val_disp,
       pricing_attribute_context,
       pricing_attribute,
       pricing_attr_code,
       pricing_attr_value_from,
       pricing_attr_value_from_disp,
       pricing_attr_value_to,
       pricing_attr_value_to_disp
FROM   qp_interface_pricing_attribs pa
WHERE  pa.request_id = p_request_id
AND    pa.process_status_flag = 'P'
AND    pa.interface_action_code IN ('INSERT','UPDATE');

l_product_attribute VARCHAR2(50);
l_product_attr_value VARCHAR2(50);
l_pricing_attribute  VARCHAR2(50);
l_pricing_attr_value_from VARCHAR2(50);
l_pricing_attr_value_to  VARCHAR2(50);
l_segment_name             VARCHAR2(240);
x_value                    VARCHAR2(240);
x_id                       VARCHAR2(150);
x_format_type              VARCHAR2(1);
l_orig_sys_line_ref	   VARCHAR2(50):=NULL;
l_context_error VARCHAR2(1);
l_attribute_error VARCHAR2(1);
l_value_error VARCHAR2(1);
l_datatype VARCHAR2(1);
l_precedence NUMBER;
l_error_code NUMBER;

 vset   FND_VSET.valueset_r;
 fmt    FND_VSET.valueset_dr;
 found  BOOLEAN;
 row    NUMBER;
 value  FND_VSET.value_dr;
x_vsid            NUMBER;
 x_validation_type VARCHAR2(1);

BEGIN
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines');
    -- 1.PRICE_BY_FORMULA

   UPDATE QP_INTERFACE_LIST_LINES a
   SET(PRICE_BY_FORMULA_ID, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT b.PRICE_FORMULA_ID,
	DECODE(b.PRICE_FORMULA_ID, NULL, null, 'P'),
   	DECODE(b.PRICE_FORMULA_ID,NULL, a.ATTRIBUTE_STATUS||'001', a.ATTRIBUTE_STATUS)
	FROM  QP_PRICE_FORMULAS_VL b, QP_INTERFACE_LIST_LINES c
	WHERE c.PRICE_BY_FORMULA = b.NAME(+)
	AND   a.rowid = c.rowid
	)
   WHERE a.REQUEST_ID = P_REQUEST_ID
   AND   a.PRICE_BY_FORMULA_ID IS NULL
   AND   a.PRICE_BY_FORMULA IS NOT NULL
   --Bug# 5412029
   --Don't do conversion if Value is G_NULL_CHAR
   and   a.PRICE_BY_FORMULA <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   a.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

   -- 2.GENERATE_USING_FORMULA
   UPDATE QP_INTERFACE_LIST_LINES a
   SET(GENERATE_USING_FORMULA_ID, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT b.PRICE_FORMULA_ID,
	DECODE(b.PRICE_FORMULA_ID, NULL, null, 'P'),
   	DECODE(b.PRICE_FORMULA_ID,NULL, a.ATTRIBUTE_STATUS||'002', a.ATTRIBUTE_STATUS)
	FROM  QP_PRICE_FORMULAS_VL b, QP_INTERFACE_LIST_LINES c
	WHERE c.GENERATE_USING_FORMULA = b.NAME(+)
	AND   a.rowid = c.rowid
	)
   WHERE a.REQUEST_ID = P_REQUEST_ID
   AND   a.GENERATE_USING_FORMULA_ID IS NULL
   AND   a.GENERATE_USING_FORMULA IS NOT NULL
   --Bug# 5412029
   --Don't do conversion if Value is G_NULL_CHAR
   and   a.GENERATE_USING_FORMULA <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   a.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

  -- 3.Product Attribute
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines Product Attribute');
   UPDATE QP_INTERFACE_PRICING_ATTRIBS qipa
   SET (PRODUCT_ATTRIBUTE, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
        (SELECT a.segment_mapping_column,
         DECODE(a.segment_mapping_column, NULL, null, 'P'),
         DECODE(a.segment_mapping_column, NULL, qipa.ATTRIBUTE_STATUS||'003',qipa.ATTRIBUTE_STATUS)
        FROM qp_segments_v a, qp_prc_contexts_b b, qp_interface_pricing_attribs c
        WHERE b.prc_context_id = a.prc_context_id
        AND   b.prc_context_code = c.PRODUCT_ATTRIBUTE_CONTEXT
        AND   a.segment_code = c.PRODUCT_ATTR_CODE
        AND   a.segment_mapping_column like 'PRICING%'
        AND   qipa.rowid = c.rowid)
   WHERE qipa.REQUEST_ID = P_REQUEST_ID
   AND   qipa.process_status_flag = 'P' --IS NOT NULL
   AND   qipa.PRODUCT_ATTRIBUTE IS NULL
   --Bug# 5456164
   --Don't do conversion if Value is G_NULL_CHAR
   AND   qipa.PRODUCT_ATTR_CODE <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   qipa.PRODUCT_ATTR_CODE IS NOT NULL
   AND   qipa.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

  -- 5.Product Precedence.
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines Product Precedence');
   UPDATE QP_INTERFACE_LIST_LINES qill
   SET PRODUCT_PRECEDENCE=
	(SELECT  NVL(a.USER_PRECEDENCE, a.SEEDED_PRECEDENCE)
        FROM qp_segments_v a, qp_prc_contexts_b b, qp_interface_pricing_attribs c
        WHERE b.prc_context_id = a.prc_context_id
        AND   b.prc_context_code = c.PRODUCT_ATTRIBUTE_CONTEXT
        AND   a.segment_code = c.PRODUCT_ATTR_CODE
        AND   a.segment_mapping_column like 'PRICING%'
        AND   qill.orig_sys_line_ref = c.orig_sys_line_ref
	AND   c.PRICING_ATTRIBUTE_CONTEXT is NULL
	AND   c.PRICING_ATTRIBUTE is NULL
	AND   c.PROCESS_STATUS_FLAG = 'P'
	AND   c.request_id = p_request_id ) --Bug No 6235177
  WHERE qill.REQUEST_ID = P_REQUEST_ID
   AND   qill.process_status_flag = 'P' --IS NOT NULL
   AND   qill.PRODUCT_PRECEDENCE IS NULL
   AND   qill.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');


  -- 4.Pricing Attribute
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines Pricing Attribute');
   UPDATE QP_INTERFACE_PRICING_ATTRIBS qipa
   SET (PRICING_ATTRIBUTE, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
        (SELECT a.segment_mapping_column,
         DECODE(a.segment_mapping_column, NULL, null, 'P'),
         DECODE(a.segment_mapping_column, NULL, qipa.ATTRIBUTE_STATUS||'005',qipa.ATTRIBUTE_STATUS)
        FROM qp_segments_v a, qp_prc_contexts_b b, qp_interface_pricing_attribs c
        WHERE b.prc_context_id = a.prc_context_id
        AND   b.prc_context_code = c.PRICING_ATTRIBUTE_CONTEXT
        AND   a.segment_code = c.PRICING_ATTR_CODE
        AND   a.segment_mapping_column like 'PRICING%'
        AND   qipa.rowid = c.rowid)
   WHERE qipa.REQUEST_ID = P_REQUEST_ID
   AND   qipa.process_status_flag = 'P' --IS NOT NULL
   AND   qipa.PRICING_ATTRIBUTE IS NULL
   --Bug# 5456164
   --Don't do conversion if Value is G_NULL_CHAR
   AND   qipa.PRICING_ATTR_CODE <> QP_BULK_LOADER_PUB.G_NULL_CHAR
   AND   qipa.PRICING_ATTR_CODE IS NOT NULL
   AND   qipa.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

   --5. Product_Attr_Value
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines Product Attribute Value1');
   UPDATE /*+ index(qipa QP_INTERFACE_PRCNG_ATTRIBS_N1) */ QP_INTERFACE_PRICING_ATTRIBS qipa --7323577
   SET (PRODUCT_ATTR_VALUE, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT a.inventory_item_id,
        DECODE(a.inventory_item_id, NULL, null, 'P'),
        DECODE(a.inventory_item_id, NULL, qipa.ATTRIBUTE_STATUS||'004',qipa.ATTRIBUTE_STATUS)
	FROM   mtl_system_items_vl a, qp_interface_pricing_attribs c
	WHERE (c.product_attr_value IS NULL and
		a.concatenated_segments= c.product_attr_val_disp
		OR c.product_attr_value IS NOT NULL and
		a.inventory_item_id = c.product_attr_value)
	AND a.ORGANIZATION_ID = FND_PROFILE.VALUE('QP_ORGANIZATION_ID') --8402384
        AND   qipa.rowid = c.rowid
	AND rownum <2)
   WHERE qipa.REQUEST_ID = P_REQUEST_ID
   AND   qipa.process_status_flag = 'P' --IS NOT NULL
   AND   qipa.product_attribute_context='ITEM'
   AND   qipa.product_attribute = 'PRICING_ATTRIBUTE1'
   AND   qipa.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

   --6. Product_Attr_Value
   qp_bulk_loader_pub.write_log( 'Entering Value to ID Lines Product Attribute Value2');
   UPDATE QP_INTERFACE_PRICING_ATTRIBS qipa
   SET (PRODUCT_ATTR_VALUE, PROCESS_STATUS_FLAG, ATTRIBUTE_STATUS)=
	(SELECT a.category_id,
        DECODE(a.category_id, NULL, null, 'P'),
        DECODE(a.category_id, NULL, qipa.ATTRIBUTE_STATUS||'004',qipa.ATTRIBUTE_STATUS)
	FROM   qp_item_categories_v a, qp_interface_pricing_attribs c
	WHERE (c.product_attr_value IS NULL and
		a.category_name = c.product_attr_val_disp
		OR c.product_attr_value IS NOT NULL and
		a.category_id = c.product_attr_value)
        AND   qipa.rowid = c.rowid
	AND rownum <2)
   WHERE qipa.REQUEST_ID = P_REQUEST_ID
   AND   qipa.process_status_flag = 'P' --IS NOT NULL
   AND   qipa.product_attribute_context='ITEM'
   AND   qipa.product_attribute = 'PRICING_ATTRIBUTE2'
   AND   qipa.INTERFACE_ACTION_CODE IN ('INSERT','UPDATE');

 FOR rec IN c_price_attr
 LOOP
    qp_bulk_loader_pub.write_log('In the Pricing attr value to id loop');
    qp_bulk_loader_pub.write_log('product_attr_code: '|| rec.product_attr_code);
    qp_bulk_loader_pub.write_log('product_attribute: '|| rec.product_attribute);
      --PRODUCT_ATTRIBUTE
      --PRODUCT_ATTR_VALUE

    l_product_attr_value := null; --bug7315184

	      qp_bulk_loader_pub.write_log('Product_attribute_context/product attribute'||rec.product_attribute_context||l_product_attribute);
     	      IF rec.product_attribute_context='ITEM'
	       and rec.product_attribute='PRICING_ATTRIBUTE1' THEN
		NULL;
	      ELSIF rec.product_attribute_context='ITEM'
	      and rec.product_attribute='PRICING_ATTRIBUTE2' THEN
		NULL;
	      ELSE
		 qp_bulk_loader_pub.write_log('Product context/attribute is not Item nor category');
		 if rec.product_attr_val_disp is not NULL and
		    rec.product_attr_value is NULL then
		 BEGIN
		    l_segment_name :=QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name
                        ('QP_ATTR_DEFNS_PRICING',
                          rec.product_attribute_context,
                          rec.product_attribute);

		    qp_bulk_loader_pub.write_log('getting segment name'||l_segment_name);
/*
		    QP_Value_To_ID.Flex_Meaning_To_Value_Id(
                    p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
                    p_context => rec.product_attribute_context,
                    p_segment => l_segment_name,
                    p_meaning => rec.product_attr_val_disp,
                    x_value => x_value,
                    x_id => x_id,
                    x_format_type => x_format_type);
*/
		    QP_UTIL.Get_Valueset_Id('QP_ATTR_DEFNS_PRICING',
					rec.product_attribute_context,
					l_segment_name,
			  		x_vsid, x_format_type, x_validation_type);
		    qp_bulk_loader_pub.write_log('vsid: '||to_char(x_vsid));
		    FND_VSET.get_valueset(x_vsid, vset, fmt);
		    FND_VSET.get_value_init(vset, TRUE);
		    FND_VSET.get_value(vset, row, found, value);

		    WHILE (found) LOOP
			qp_bulk_loader_pub.write_log('meaning: '||value.meaning);
			IF  (fmt.has_meaning AND
			    ltrim(rtrim(value.meaning))=ltrim(rtrim(rec.product_attr_val_disp))
			    ) OR
			    ltrim(rtrim(value.value)) = ltrim(rtrim(rec.product_attr_val_disp))
			THEN
			    qp_bulk_loader_pub.write_log('success: ');

			    IF fmt.has_id THEN
				qp_bulk_loader_pub.write_log('fmt.has_id');
				x_id := value.id;
				x_value := value.value;
			    ELSE
				x_value := value.value;
			    END IF;

			    EXIT;

			END IF; -- If value.meaning or value.value matches with p_meaning

		    FND_VSET.get_value(vset, row, found, value);
		    END LOOP;

		    FND_VSET.get_value_end(vset);

		    qp_bulk_loader_pub.write_log('x_value/x_id: ' || x_value || '/' || x_id);
		    if x_value is NULL then
			x_value := rec.product_attr_val_disp;
			--If a match is not found in the valueset.
		    end if;

		    qp_bulk_loader_pub.write_log('getting product_attr_value using flex_meaning_to_value_id');
		    qp_bulk_loader_pub.write_log('product_attr_val_disp '||rec.product_attr_val_disp);

		    IF x_id IS NOT NULL THEN
		       l_product_attr_value := x_id;
		    ELSE
		       l_product_attr_value := x_value;
		    END IF;

		    qp_bulk_loader_pub.write_log('product_attr_value is '||l_product_attr_value);
		    IF l_product_attr_value IS NULL THEN
		     qp_bulk_loader_pub.write_log('product_attr_value is NULL - ERROR');
		     UPDATE QP_INTERFACE_PRICING_ATTRIBS
		     SET    PROCESS_STATUS_FLAG=NULL, ATTRIBUTE_STATUS=ATTRIBUTE_STATUS||'004'
		     WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		     AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		     AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;
	           ELSE
		     UPDATE QP_INTERFACE_PRICING_ATTRIBS
  		     SET    PRODUCT_ATTR_VALUE = l_product_attr_value
		     WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		     AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		     AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;
		   END IF;
            EXCEPTION
              WHEN OTHERS THEN
		   UPDATE QP_INTERFACE_PRICING_ATTRIBS
		   SET    PROCESS_STATUS_FLAG=NULL, ATTRIBUTE_STATUS=ATTRIBUTE_STATUS||'004'
		   WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		   AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		   AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;
	      qp_bulk_loader_pub.write_log('Exception Error caused'||sqlerrm);
           END;
          END IF; -- product_attr_val is NULL
          END IF;

	if rec.product_attribute_context='ITEM' and
	     (rec.product_attribute='PRICING_ATTRIBUTE1' or
	     rec.product_attribute='PRICING_ATTRIBUTE2') THEN
		-- Precedence is already determined.
		NULL;
	else
	  if rec.product_attr_value is not null
		 and l_product_attr_value is NULL then
		l_product_attr_value := rec.product_attr_value;
	  end if;
	  if l_orig_sys_line_ref IS NULL or
	     l_orig_sys_line_ref <> REC.orig_sys_line_ref then
   		l_orig_sys_line_ref := REC.ORIG_SYS_LINE_REF;
		qp_bulk_loader_pub.write_log('default line precedence once for a line');
		qp_bulk_loader_pub.write_log('Context/Attribute/Value'||rec.product_attribute_context||'/'||l_product_attribute||'/'||l_product_attr_value);
		QP_UTIL.validate_qp_flexfield(
                           flexfield_name=> 'QP_ATTR_DEFNS_PRICING'
			   ,context        =>rec.product_attribute_context
			   ,attribute      =>rec.product_attribute
			   ,value          =>l_product_attr_value
			    ,application_short_name         => 'QP'
				     ,context_flag           =>l_context_error
				     ,attribute_flag         =>l_attribute_error
				     ,value_flag             =>l_value_error
				     ,datatype               =>l_datatype
				     ,precedence              =>l_precedence
				     ,error_code             =>l_error_code
				     );

		qp_bulk_loader_pub.write_log('line ref'||rec.orig_sys_line_ref||'error_code'||to_char(l_error_code));
		If l_error_code = 0 Then
			UPDATE QP_INTERFACE_LIST_LINES
			SET    PRODUCT_PRECEDENCE = l_precedence
			WHERE  ORIG_SYS_LINE_REF = REC.ORIG_SYS_LINE_REF
			AND    PROCESS_STATUS_FLAG = 'P'
			AND    PRODUCT_PRECEDENCE IS NULL;
		else
			UPDATE QP_INTERFACE_LIST_LINES
			SET    PROCESS_STATUS_FLAG = NULL,
				ATTRIBUTE_STATUS=ATTRIBUTE_STATUS||'004'
			WHERE  ORIG_SYS_LINE_REF = REC.ORIG_SYS_LINE_REF
			AND    PROCESS_STATUS_FLAG = 'P'; --IS NULL;
		end if;
	 end if;
	end if;
      --PRICING_ATTRIBUTE
         qp_bulk_loader_pub.write_log('Value to ID for Pricing Attribute');
	 qp_bulk_loader_pub.write_log('Pricing_attr_code: '|| rec.pricing_attr_code);
	 qp_bulk_loader_pub.write_log('Pricing_attribute: '|| rec.pricing_attribute);
      --PRICING_ATTR_VALUE_FROM
	      qp_bulk_loader_pub.write_log('Value to ID for Pricing Attr value from');
	      qp_bulk_loader_pub.write_log('Pricing_attr_value_from : '|| rec.pricing_attr_value_from);
	      qp_bulk_loader_pub.write_log('Pricing_attr_value_from_disp: '|| rec.pricing_attr_value_from_disp);
	      IF rec.pricing_attr_value_from IS NULL and
	 	rec.pricing_attr_value_from_disp IS NOT NULL THEN
	      BEGIN
		    l_segment_name :=QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name
                        ('QP_ATTR_DEFNS_PRICING',
                          rec.pricing_attribute_context,
                          rec.pricing_attribute);
		    qp_bulk_loader_pub.write_log('getting segment name'||l_segment_name);

		    qp_bulk_loader_pub.write_log('getting pricing_attr_value_from_disp using flex_meaning_to_value_id');
              QP_Value_To_ID.Flex_Meaning_To_Value_Id(
                    p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
                    p_context => rec.pricing_attribute_context,
                    p_segment => l_segment_name,
                    p_meaning => rec.pricing_attr_value_from_disp,
                    x_value => x_value,
                    x_id => x_id,
                    x_format_type => x_format_type);


              IF x_id IS NOT NULL THEN
              l_pricing_attr_value_from := x_id;
              ELSE
              l_pricing_attr_value_from := x_value;
              END IF;

		   qp_bulk_loader_pub.write_log('pricing_attr_value_from is '||l_pricing_attr_value_from);
		   UPDATE QP_INTERFACE_PRICING_ATTRIBS
		   SET    PRICING_ATTR_VALUE_FROM = l_pricing_attr_value_from
		   WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		   AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		   AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;

           EXCEPTION
              WHEN OTHERS THEN
		   UPDATE QP_INTERFACE_PRICING_ATTRIBS
		      SET    PROCESS_STATUS_FLAG=NULL, ATTRIBUTE_STATUS=ATTRIBUTE_STATUS||'006'
		    WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		      AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		      AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;
	      qp_bulk_loader_pub.write_log('Exception Error caused'||sqlerrm);
           END;
	   END IF;

      --PRICING_ATTR_VALUE_TO
	      qp_bulk_loader_pub.write_log('Value to ID for Pricing Attr value to');
	      qp_bulk_loader_pub.write_log('Pricing_attr_value_to : '|| rec.pricing_attr_value_to);
	      qp_bulk_loader_pub.write_log('Pricing_attr_value_to_disp: '|| rec.pricing_attr_value_to_disp);
	      IF rec.pricing_attr_value_to IS NULL and
	 	rec.pricing_attr_value_to_disp IS NOT NULL THEN
	      BEGIN
		    l_segment_name :=QP_PRICE_LIST_LINE_UTIL.Get_Segment_Name
                        ('QP_ATTR_DEFNS_PRICING',
                          rec.pricing_attribute_context,
                          rec.pricing_attribute);

		    qp_bulk_loader_pub.write_log('getting segment name'||l_segment_name);

		    qp_bulk_loader_pub.write_log('getting pricing_attr_value_to_disp using flex_meaning_to_value_id');
              QP_Value_To_ID.Flex_Meaning_To_Value_Id(
                    p_flexfield_name => 'QP_ATTR_DEFNS_PRICING',
                    p_context => rec.pricing_attribute_context,
                    p_segment => l_segment_name,
                    p_meaning => rec.pricing_attr_value_to_disp,
                    x_value => x_value,
                    x_id => x_id,
                    x_format_type => x_format_type);

              IF x_id IS NOT NULL THEN
              l_pricing_attr_value_to := x_id;
              ELSE
              l_pricing_attr_value_to := x_value;
              END IF;

		   qp_bulk_loader_pub.write_log('pricing_attr_value_to is '||l_pricing_attr_value_to);
		   UPDATE QP_INTERFACE_PRICING_ATTRIBS
		   SET    PRICING_ATTR_VALUE_TO = l_pricing_attr_value_to
		   WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
	 	   AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		   AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;

           EXCEPTION
              WHEN OTHERS THEN
		   UPDATE QP_INTERFACE_PRICING_ATTRIBS
		      SET    PROCESS_STATUS_FLAG=NULL, ATTRIBUTE_STATUS=ATTRIBUTE_STATUS||'007'
		    WHERE  ORIG_SYS_PRICING_ATTR_REF = REC.ORIG_SYS_PRICING_ATTR_REF
		      AND    ORIG_SYS_HEADER_REF = REC.ORIG_SYS_HEADER_REF
		      AND    ORIG_SYS_LINE_REF   = REC.ORIG_SYS_LINE_REF;
	      qp_bulk_loader_pub.write_log('Exception Error caused'||sqlerrm);
           END;
	   END IF;

 END LOOP;
 qp_bulk_loader_pub.write_log( 'Leaving Value to ID Lines');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log( 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.LINE:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LINE;


PROCEDURE INSERT_HEADER_ERROR_MESSAGES
   (p_request_id   NUMBER)
IS
   CURSOR c_error_records IS
     SELECT orig_sys_header_ref,
	    attribute_status
       FROM   qp_interface_list_headers
      WHERE  request_id = p_request_id
	AND    process_status_flag is null
	AND    attribute_status IS NOT NULL;

l_counter   NUMBER:=0;
l_first     NUMBER:=0;
l_attribute VARCHAR2(30);
l_attr_code VARCHAR2(3);
l_msg_data  VARCHAR2(2000);
l_msg_txt   VARCHAR2(2000);

BEGIN

   qp_bulk_loader_pub.write_log( 'Entering Insert Header Error Messages');

   l_msg_data := FND_MESSAGE.GET_STRING('QP','QP_BULK_VALUE_TO_ID_ERROR');

   FOR l_err in c_error_records LOOP

      l_counter := length(l_err.attribute_status)/3;
      IF l_counter < 1
      THEN
	 GOTO END_OF_LOOP;
      END IF;

      l_first:=1;

      FOR i IN 1..l_counter LOOP

	 l_attr_code := SUBSTR(l_err.attribute_status,l_first,3);

	 IF l_attr_code = '001' THEN
	    l_attribute := 'CURRENCY HEADER';
	 ELSIF l_attr_code = '002' THEN
	    l_attribute := 'FREIGHT TERMS';
	 ELSIF l_attr_code = '003' THEN
	    l_attribute := 'SHIP METHOD';
	 ELSIF l_attr_code = '004' THEN
	    l_attribute :=  'TERMS';
	 END IF;

	 l_msg_txt:=l_msg_data||' '||l_attribute;

	  INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
			orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref,error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_LIST_HEADERS', NULL,
	     l_err.orig_sys_header_ref,null,null,null,l_msg_txt);

	 l_first:=l_first+3;

      END LOOP;
      <<END_OF_LOOP>>
      NULL;
   END LOOP;

   qp_bulk_loader_pub.write_log( 'Leaving Insert Header Error Messages');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
		 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_HEADER_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
		 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_HEADER_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_HEADER_ERROR_MESSAGES;

PROCEDURE INSERT_QUAL_ERROR_MESSAGE
             (p_request_id     NUMBER)
IS
   CURSOR c_error_records IS
     SELECT orig_sys_qualifier_ref,
	    orig_sys_header_ref,
	    attribute_status
       FROM   qp_interface_qualifiers
      WHERE  request_id = p_request_id
	AND    process_status_flag is null;
--	AND    attribute_status IS NOT NULL;

l_counter   NUMBER:=0;
l_first     NUMBER:=0;
l_attribute VARCHAR2(30);
l_attr_code VARCHAR2(3);
l_msg_data  VARCHAR2(2000);
l_msg_txt   VARCHAR2(2000);

BEGIN

   qp_bulk_loader_pub.write_log( 'Entering Insert Qualifier Error Messages');

   l_msg_data := FND_MESSAGE.GET_STRING('QP','QP_BULK_VALUE_TO_ID_ERROR');

   FOR l_err in c_error_records LOOP

      IF l_err.attribute_status is not NULL then
	  l_counter := length(l_err.attribute_status)/3;
      ELSE
	  l_counter := 0;
      END if;
      IF l_counter < 1
      THEN
	 GOTO END_OF_LOOP;
      END IF;

      l_first:=1;

      FOR i IN 1..l_counter LOOP

	 l_attr_code := SUBSTR(l_err.attribute_status,l_first,3);

	 IF l_attr_code = '001' THEN
	    l_attribute := 'CREATED_FROM_RULE';
	 ELSIF l_attr_code = '002' THEN
	    l_attribute := 'QUALIFIER_RULE';
	 END IF;

	 l_msg_txt:=l_msg_data||' '||l_attribute;

	   INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
	                orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref, error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS', NULL,
	     l_err.orig_sys_header_ref,null,l_err.orig_sys_qualifier_ref,null,l_msg_txt);

	 l_first:=l_first+3;

      END LOOP;
      <<END_OF_LOOP>>
      IF l_err.attribute_status is NULL then
	    l_attribute := 'QUALIFIER_ATTRIBUTE';
	    l_msg_txt:=l_msg_data||' '||l_attribute;

	   INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
	                orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref, error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	     NULL,NULL, 'PRL', 'QP_INTERFACE_QUALIFIERS', NULL,
	     l_err.orig_sys_header_ref,null,l_err.orig_sys_qualifier_ref,null,l_msg_txt);
      END IF;
      NULL;
   END LOOP;

   qp_bulk_loader_pub.write_log( 'Leaving Insert Qualifier Error Messages');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_QUAL_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_QUAL_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_QUAL_ERROR_MESSAGE;


PROCEDURE INSERT_LINE_ERROR_MESSAGE
             (p_request_id  NUMBER)
IS
   CURSOR c_error_records IS
     SELECT orig_sys_header_ref orig_header_ref,
	    orig_sys_line_ref orig_line_ref,
	    null orig_attr_ref,
	    attribute_status, null pac, null pa, null pcac, null pca, null pav, null pavd,
	    'QP_INTERFACE_LIST_LINES' table_name
       FROM   qp_interface_list_lines
      WHERE  request_id = p_request_id
	AND    process_status_flag is null
	AND    attribute_status IS NOT NULL
   UNION
     SELECT orig_sys_header_ref orig_header_ref,
	    orig_sys_line_ref orig_line_ref,
	    orig_sys_pricing_attr_ref orig_attr_ref,
	    attribute_status, product_attr_code pac, product_attribute pa,
	    pricing_attr_code pcac, pricing_attribute pca,
	    product_attr_value pav, product_attr_val_disp pavd,
	    'QP_INTERFACE_PRICING_ATTRIBS' table_name
       FROM   qp_interface_pricing_attribs
      WHERE  request_id = p_request_id
	AND    process_status_flag is null;
--	AND    attribute_status IS NOT NULL;

l_counter   NUMBER:=0;
l_first     NUMBER:=0;
l_attribute VARCHAR2(30);
l_attr_code VARCHAR2(3);
l_msg_data  VARCHAR2(2000);
l_msg_txt   VARCHAR2(2000);

BEGIN
   qp_bulk_loader_pub.write_log( 'Entering Insert Line Error Messages');

   l_msg_data := FND_MESSAGE.GET_STRING('QP','QP_BULK_VALUE_TO_ID_ERROR');

   FOR l_err in c_error_records LOOP
    IF l_err.attribute_status is NULL then
	if l_err.pac is not NULL and l_err.pa is NULL then
	    l_attribute := 'PRODUCT_ATTRIBUTE';
	     l_msg_txt:=l_msg_data||' '||l_attribute;
	       INSERT INTO QP_INTERFACE_ERRORS
			   (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref,error_message)
	       VALUES
		(qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
		 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
		 NULL,NULL, 'PRL',l_err.table_name, NULL,
		 l_err.orig_header_ref,l_err.orig_line_ref,null,l_err.orig_attr_ref,l_msg_txt);
	end if;
	if l_err.pcac is not NULL and l_err.pca is NULL then
	    l_attribute := 'PRICING_ATTRIBUTE';
	     l_msg_txt:=l_msg_data||' '||l_attribute;
	       INSERT INTO QP_INTERFACE_ERRORS
			   (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref,error_message)
	       VALUES
		(qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
		 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
		 NULL,NULL, 'PRL',l_err.table_name, NULL,
		 l_err.orig_header_ref,l_err.orig_line_ref,null,l_err.orig_attr_ref,l_msg_txt);
	end if;
	if l_err.pavd is not NULL and l_err.pav is NULL then
	    l_attribute := 'PRODUCT_ATTRIBUTE_VALUE';
	    l_msg_txt:=l_msg_data||' '||l_attribute;
	       INSERT INTO QP_INTERFACE_ERRORS
			   (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref,error_message)
	       VALUES
		(qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
		 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
		 NULL,NULL, 'PRL',l_err.table_name, NULL,
		 l_err.orig_header_ref,l_err.orig_line_ref,null,l_err.orig_attr_ref,l_msg_txt);
	end if;
	if l_err.pavd is NULL and l_err.pav is NULL then
	    l_msg_txt := FND_MESSAGE.GET_STRING('QP','QP_INVALID_PROD_VALUE');
	       INSERT INTO QP_INTERFACE_ERRORS
			   (error_id,last_update_date, last_updated_by, creation_date,
			    created_by, last_update_login, request_id, program_application_id,
			    program_id, program_update_date, entity_type, table_name, column_name,
			    orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			    orig_sys_pricing_attr_ref,error_message)
	       VALUES
		(qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
		 FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
		 NULL,NULL, 'PRL',l_err.table_name, NULL,
		 l_err.orig_header_ref,l_err.orig_line_ref,null,l_err.orig_attr_ref,l_msg_txt);
	end if;
    ELSE
      l_counter := length(l_err.attribute_status)/3;
      IF l_counter < 1
      THEN
	 GOTO END_OF_LOOP;
      END IF;

      l_first:=1;

      FOR i IN 1..l_counter LOOP

	 l_attr_code := SUBSTR(l_err.attribute_status,l_first,3);

	 IF l_attr_code = '001' THEN
	    l_attribute := 'PRICE_BY_FORMULA';
	 ELSIF l_attr_code = '002' THEN
	    l_attribute := 'GENERATE_USING_FORMULA';
	 ELSIF l_attr_code = '003' THEN
	    l_attribute := 'PRODUCT_ATTRIBUTE';
	 ELSIF l_attr_code = '004' THEN
	    l_attribute := 'PRODUCT_ATTRIBUTE_VALUE';
	 ELSIF l_attr_code = '005' THEN
	    l_attribute := 'PRICING_ATTRIBUTE';
	 ELSIF l_attr_code = '006' THEN
	    l_attribute := 'PRICING_ATTRIBUTE_VALUE_FROM';
	 ELSIF l_attr_code = '007' THEN
	    l_attribute := 'PRICING_ATTRIBUTE_VALUE_TO';

	 END IF;
	 IF l_attr_code = '008' THEN
	    l_msg_data := FND_MESSAGE.GET_STRING('QP','QP_INVALID_PROD_VALUE');
	    l_attribute := ' ';
	 END IF;

	 l_msg_txt:=l_msg_data||' '||l_attribute;

	   INSERT INTO QP_INTERFACE_ERRORS
		       (error_id,last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, request_id, program_application_id,
			program_id, program_update_date, entity_type, table_name, column_name,
			orig_sys_header_ref,orig_sys_line_ref,orig_sys_qualifier_ref,
			orig_sys_pricing_attr_ref,error_message)
	   VALUES
	    (qp_interface_errors_s.nextval, sysdate ,FND_GLOBAL.USER_ID, sysdate,
	     FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, p_request_id, 660,
	     NULL,NULL, 'PRL',l_err.table_name, NULL,
	     l_err.orig_header_ref,l_err.orig_line_ref,null,l_err.orig_attr_ref,l_msg_txt);

	 l_first:=l_first+3;

      END LOOP;
    END IF;
    <<END_OF_LOOP>>
      NULL;
   END LOOP;

 qp_bulk_loader_pub.write_log( 'Leaving Insert Line Error Messages');

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_LINE_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       qp_bulk_loader_pub.write_log(
			 'UNEXCPECTED ERROR IN QP_BULK_VALUE_TO_ID.INSERT_LINE_ERROR_MESSAGES:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_LINE_ERROR_MESSAGE;

END QP_BULK_VALUE_TO_ID;

/
