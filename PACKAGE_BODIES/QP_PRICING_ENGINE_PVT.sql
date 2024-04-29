--------------------------------------------------------
--  DDL for Package Body QP_PRICING_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICING_ENGINE_PVT" AS
/* $Header: QPXVDLNB.pls 115.3 1999/11/04 11:28:34 pkm ship     $ */

PROCEDURE Get_Discount_Lines
						(p_price_list_id 		NUMBER,
						 p_list_price    		NUMBER,
						 p_quantity			NUMBER,
						 p_unit_code			VARCHAR2,
					  	 p_attribute_id	 	NUMBER,
						 p_attribute_value 		VARCHAR2,
						 p_pricing_date		DATE,
						 p_customer_class_code	VARCHAR2,
						 p_sold_to_org_id		VARCHAR2,
						 p_ship_to_id			VARCHAR2,
						 p_invoice_to_id		VARCHAR2,
						 p_best_adj_percent		NUMBER,
						 p_gsa				VARCHAR2,
						 p_asc_desc_flag		VARCHAR2,
						 x_discount_line_rec	OUT l_discount_line_rec) AS
						 --x_discount_lines_tbl 	OUT l_discount_lines_tbl) AS


	v_discount_line_rec 	l_discount_line_rec;
	v_discount_lines_tbl	l_discount_lines_tbl;
	x_discount_rec 		l_discount_line_rec;

	cnt					NUMBER := 0;
	v_value				NUMBER;
	v_dummy				VARCHAR2(1);
	v_index				NUMBER;
	err_num				NUMBER;
	err_msg				VARCHAR2(100);

	v_product_context		QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE;
	v_product_attribute		QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE;
	v_qualifier_context		QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
	v_qualifier_attribute	QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
	v_customer_context		QP_QUALIFIERS.QUALIFIER_CONTEXT%TYPE;
	v_customer_class_attr	QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
	v_sold_to_org_attr		QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
	v_site_org_attr		QP_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE;
	v_lines_flag			VARCHAR2(1);


	CURSOR get_discount_headers(p_context VARCHAR2,p_attribute VARCHAR2,p_attr_value VARCHAR2,
					  	p_customer_context VARCHAR2 , p_customer_class_attr VARCHAR2,
					  	p_sold_to_org_attr VARCHAR2,  p_site_org_attr VARCHAR2) IS

	SELECT qph.list_header_id,qph.name,qpl.list_line_id,qpl.list_line_type_code,
	qpl.operand, qpl.arithmetic_operator,qph.discount_lines_flag
	FROM	 QP_LIST_HEADERS qph , QP_LIST_LINES qpl,QP_QUALIFIERS qpq
	WHERE qph.LIST_HEADER_ID = qpl.LIST_HEADER_ID
	AND	 qpl.LIST_LINE_TYPE_CODE IN ('DIS','PBH')
	AND   qph.LIST_HEADER_ID = qpq.LIST_HEADER_ID
	AND	 qph.AUTOMATIC_FLAG = 'Y'
	AND	 ((p_gsa = 'Y') OR nvl(qph.GSA_INDICATOR , 'N') = 'N')
	AND	 qpq.QUALIFIER_CONTEXT = p_context
	AND	 qpq.QUALIFIER_ATTRIBUTE = p_attribute
	AND	 qpq.QUALIFIER_ATTR_VALUE = p_attr_value
	AND	 trunc(p_pricing_date) BETWEEN nvl(qpl.START_DATE_ACTIVE,trunc(p_pricing_date))
						   AND nvl(qpl.END_DATE_ACTIVE,trunc(p_pricing_date))
	AND  ( not exists (select null
			  from qp_qualifiers qpq
			  where qpq.list_header_id = qph.list_header_id
			  and   qpq.qualifier_context = p_customer_context
			  and   qpq.qualifier_attribute in (p_customer_class_attr , p_sold_to_org_attr, p_site_org_attr))
		 or
	          (         exists(select null
		   		        from qp_qualifiers qpq
		   			   where qpq.list_header_id = qph.list_header_id
	           		   and (qpq.qualifier_context = p_customer_context
	           		   and qpq.qualifier_attribute = p_sold_to_org_attr
		   			   and nvl(qpq.qualifier_attr_value,p_sold_to_org_id) = p_sold_to_org_id))
	  		 or  exists(select null
		   			  from qp_qualifiers qpq
		   			  where qpq.list_header_id = qph.list_header_id
		   			  and (qpq.qualifier_context = p_customer_context
	              		  and qpq.qualifier_attribute = p_customer_class_attr
		   	    		  and nvl(qpq.qualifier_attr_value,p_customer_class_code) = p_customer_class_code))
	   		and  exists(select null
		   			from qp_qualifiers qpq
		   			where (qpq.qualifier_context = p_customer_context
	           		and qpq.qualifier_attribute = p_site_org_attr
		   	     	and (nvl(qpq.qualifier_attr_value,p_ship_to_id) = p_ship_to_id
			         or nvl(qpq.qualifier_attr_value,p_invoice_to_id) = p_invoice_to_id)))));

	CURSOR get_discount_lines
		(p_list_line_id NUMBER,p_product_attribute_context VARCHAR2,p_product_attribute VARCHAR2,
		p_qualifier_context VARCHAR2 , p_qualifier_attribute VARCHAR2 ) IS

	SELECT 'X'
	FROM	 QP_LIST_LINES qpl, QP_PRICING_ATTRIBUTES qpbl
	WHERE qpl.LIST_LINE_ID = p_list_line_id
	AND	 qpl.LIST_LINE_ID = qpbl.LIST_LINE_ID
	AND	 qpbl.PRODUCT_ATTRIBUTE_CONTEXT = p_product_attribute_context
	AND	 qpbl.PRODUCT_ATTRIBUTE = p_product_attribute
	AND	 qpbl.PRODUCT_ATTR_VALUE = p_attribute_value
	AND	 nvl(qpbl.PRODUCT_UOM_CODE,nvl(p_unit_code,'NULL')) = nvl(p_unit_code,'NULL')
	AND	 trunc(p_pricing_date) BETWEEN nvl(qpl.START_DATE_ACTIVE,trunc(p_pricing_date))
					 		  AND   nvl(qpl.END_DATE_ACTIVE,trunc(p_pricing_date))
	UNION
	SELECT 'Y'
	FROM	 QP_LIST_LINES qpl, QP_QUALIFIERS qpq
	WHERE qpl.LIST_LINE_ID = p_list_line_id
	AND	 qpl.LIST_LINE_ID = qpq.LIST_LINE_ID
	AND	 qpq.QUALIFIER_CONTEXT = p_qualifier_context
	AND	 qpq.QUALIFIER_ATTRIBUTE = p_qualifier_attribute
	AND	 qpq.QUALIFIER_ATTR_VALUE = p_attribute_value
	AND	 trunc(p_pricing_date) BETWEEN nvl(qpl.START_DATE_ACTIVE,trunc(p_pricing_date))
						   AND   nvl(qpl.END_DATE_ACTIVE,trunc(p_pricing_date));

	CURSOR get_price_break_lines
		(p_list_line_id NUMBER,p_product_attribute_context VARCHAR2,p_product_attribute VARCHAR2,
	      p_qualifier_context VARCHAR2 , p_qualifier_attribute VARCHAR2 ) IS

	SELECT qpbl.PRICING_ATTRIBUTE_ID,qpbl.LIST_LINE_ID,qpbl.PRICING_ATTRIBUTE_CONTEXT,qpbl.PRICING_ATTRIBUTE,
		  qpbl.PRICING_ATTR_VALUE_FROM, qpbl.PRICING_ATTR_VALUE_TO,qpl.OPERAND , qpl.ARITHMETIC_OPERATOR
	FROM	 QP_PRICING_ATTRIBUTES qpbl , QP_RLTD_MODIFIERS qprl, QP_LIST_LINES qpl
	WHERE qpl.LIST_LINE_ID = qpbl.LIST_LINE_ID
	AND	 qpbl.LIST_LINE_ID = qprl.TO_RLTD_MODIFIER_ID
	AND	 qpbl.PRODUCT_ATTRIBUTE_CONTEXT = p_product_attribute_context
	AND	 qpbl.PRODUCT_ATTRIBUTE = p_product_attribute
	AND	 qpbl.PRODUCT_ATTR_VALUE = p_attribute_value
	AND	 nvl(qpbl.PRODUCT_UOM_CODE,nvl(p_unit_code,'NULL')) = nvl(p_unit_code,'NULL')
	AND	 qprl.FROM_RLTD_MODIFIER_ID = p_list_line_id
	AND	 trunc(p_pricing_date) BETWEEN nvl(qpl.START_DATE_ACTIVE,trunc(p_pricing_date))
						   AND nvl(qpl.END_DATE_ACTIVE,trunc(p_pricing_date))
	UNION
	SELECT qpbl.PRICING_ATTRIBUTE_ID,qpbl.LIST_LINE_ID,qpbl.PRICING_ATTRIBUTE_CONTEXT,qpbl.PRICING_ATTRIBUTE,
		  qpbl.PRICING_ATTR_VALUE_FROM, qpbl.PRICING_ATTR_VALUE_TO,qpl.OPERAND , qpl.ARITHMETIC_OPERATOR
	FROM	 QP_PRICING_ATTRIBUTES qpbl , QP_LIST_LINES qpl, QP_QUALIFIERS qpq, QP_RLTD_MODIFIERS qprl
	WHERE qpq.LIST_LINE_ID = p_list_line_id
	AND	 qpq.QUALIFIER_CONTEXT = p_qualifier_context
	AND	 qpq.QUALIFIER_ATTRIBUTE = p_qualifier_attribute
	AND	 qpq.QUALIFIER_ATTR_VALUE = p_attribute_value
	AND	 qpbl.LIST_LINE_ID = qprl.TO_RLTD_MODIFIER_ID
	AND 	 qpl.LIST_LINE_ID = qpbl.LIST_LINE_ID
	AND 	 qpl.LIST_LINE_ID IN (	SELECT TO_RLTD_MODIFIER_ID
					      	FROM QP_RLTD_MODIFIERS qprl
				      		WHERE qprl.FROM_RLTD_MODIFIER_ID = p_list_line_id)
	AND	 trunc(p_pricing_date) BETWEEN nvl(qpl.START_DATE_ACTIVE,trunc(p_pricing_date))
						   AND nvl(qpl.END_DATE_ACTIVE,trunc(p_pricing_date));
BEGIN

	-- Get the contexts and attributes
	QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID',v_qualifier_context,v_qualifier_attribute);
	QP_UTIL.Get_Context_Attribute('CUSTOMER_CLASS_CODE',v_customer_context,v_customer_class_attr);
	QP_UTIL.Get_Context_Attribute('SOLD_TO_ORG_ID',v_customer_context,v_sold_to_org_attr);
	QP_UTIL.Get_Context_Attribute('SITE_ORG_ID',v_customer_context,v_site_org_attr);

	FOR i in get_discount_headers(v_qualifier_context,v_qualifier_attribute,p_price_list_id,
		v_customer_context,v_customer_class_attr,v_sold_to_org_attr,v_site_org_attr)
	LOOP
			--dbms_output.put_line('Inside the Loop');
			--dbms_output.put_line('Discount Lines Flag: ' || nvl(i.discount_lines_flag,'NO LINES'));
			--dbms_output.put_line('Discount Id: ' || i.list_header_id);
			--dbms_output.put_line('Discount Line Id: ' || i.list_line_id);

			IF (i.list_line_type_code = 'DIS') THEN

				BEGIN
				     SELECT 'x'
					INTO  v_dummy
					FROM QP_RLTD_MODIFIERS
					WHERE TO_RLTD_MODIFIER_ID = i.list_line_id;
				EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					v_dummy := NULL;
				END;

			--dbms_output.put_line('Dummy :' || v_dummy);

			-- if v_dummy is not null then it is a line related to a price break line . So ignore it.
			 IF (v_dummy IS NULL) THEN

				-- Get the context and attribute
				IF QP_UTIL.Is_qualifier(p_attribute_id) = 'T' THEN
					QP_UTIL.Get_Context_Attribute(p_attribute_id , v_qualifier_context , v_qualifier_attribute);
					v_product_context := NULL;
					v_product_attribute := NULL;
				ELSIF QP_UTIL.Is_PricingAttr(p_attribute_id) = 'T' THEN
					QP_UTIL.Get_Context_Attribute(p_attribute_id , v_product_context , v_product_attribute);
					v_qualifier_context := NULL;
					v_qualifier_attribute := NULL;
				END IF;

				--dbms_output.put_line('Product Context:' || v_product_context);
				--dbms_output.put_line('Product Attribute:' || v_product_attribute);
				--dbms_output.put_line('Qualifier Context:' || v_qualifier_context);
				--dbms_output.put_line('Qualifier Attribute:' || v_qualifier_attribute);
				--dbms_output.put_line('List Line Id:' || i.list_line_id);
				--dbms_output.put_line('Attribute Value:' || p_attribute_value);

				-- Reinit the lines flag
				v_lines_flag := null;

				-- Check to find a record with attribute id and value . If v_lines_flag is not null then match found
				OPEN get_discount_lines
				 (i.list_line_id,v_product_context,v_product_attribute,v_qualifier_context,v_qualifier_attribute);
				FETCH get_discount_lines INTO v_lines_flag;
				CLOSE get_discount_lines;

			   IF (v_lines_flag IS NOT NULL) THEN

				v_discount_line_rec.p_discount_id := i.list_header_id;
				v_discount_line_rec.p_discount_name := i.name;
				v_discount_line_rec.p_discount_line_id := i.list_line_id;

				IF (i.arithmetic_operator = 'AMT') THEN
					v_discount_line_rec.p_discount_percent := nvl(i.operand/p_list_price * 100,0);
				ELSIF (i.arithmetic_operator = '%') THEN
					v_discount_line_rec.p_discount_percent := nvl(i.operand,0);
				ELSIF (i.arithmetic_operator = 'NEWPRICE') THEN
					v_discount_line_rec.p_discount_percent := p_list_price - nvl(i.operand,0);
				END IF;

				IF (p_asc_desc_flag = 'A') THEN
					IF (v_discount_line_rec.p_discount_percent < p_best_adj_percent) THEN
						cnt := cnt + 1;
						v_discount_lines_tbl(cnt) := v_discount_line_rec;
					END IF;
				ELSE
					IF (v_discount_line_rec.p_discount_percent > p_best_adj_percent) THEN
						cnt := cnt + 1;
						v_discount_lines_tbl(cnt) := v_discount_line_rec;
					END IF;
				END IF;

			   END IF;
			 END IF;
			ELSIF (i.list_line_type_code = 'PBH') THEN
				--dbms_output.put_line('Discount Id: ' || i.list_header_id);
				--dbms_output.put_line('Discount Line Id: ' || i.list_line_id);
				--dbms_output.put_line('Discount Line Type Code : ' || 'PBH');

				-- Get the context and attribute
				IF QP_UTIL.Is_qualifier(p_attribute_id) = 'T' THEN
					QP_UTIL.Get_Context_Attribute(p_attribute_id , v_qualifier_context , v_qualifier_attribute);
					v_product_context := NULL;
					v_product_attribute := NULL;
				ELSIF QP_UTIL.Is_PricingAttr(p_attribute_id) = 'T' THEN
					QP_UTIL.Get_Context_Attribute(p_attribute_id , v_product_context , v_product_attribute);
					v_qualifier_context := NULL;
					v_qualifier_attribute := NULL;
				END IF;

				--dbms_output.put_line('Product Context:' || v_product_context);
				--dbms_output.put_line('Product Attribute:' || v_product_attribute);
				--dbms_output.put_line('Qualifier Context:' || v_qualifier_context);
				--dbms_output.put_line('Qualifier Attribute:' || v_qualifier_attribute);
				--dbms_output.put_line('List Line Id:' || i.list_line_id);
				--dbms_output.put_line('Attribute Value:' || p_attribute_value);


				-- This cursor will take care of both product and qualifier contexts. Only 1 Select in the UNION
				-- will be successful any time depending on whether it is a product or qualifier

				FOR j in get_price_break_lines
				 (i.list_line_id,v_product_context,v_product_attribute,v_qualifier_context,v_qualifier_attribute)
				LOOP
					--dbms_output.put_line('Inside the Price break Loop');

					IF (j.pricing_attribute_context = 'VOLUME' AND j.pricing_attribute = 'PRICING_ATTRIBUTE3') THEN
					   v_value := p_quantity;
					ELSE
					   v_value := p_quantity * p_list_price ;
					END IF;

					--dbms_output.put_line('Value is : ' || v_value);
					--dbms_output.put_line('Value From :' || j.pricing_attr_value_from);
					--dbms_output.put_line('Value To :' || j.pricing_attr_value_to);

					 IF  (v_value > nvl(j.pricing_attr_value_from , v_value) AND
					    v_value < nvl(j.pricing_attr_value_to, v_value)) THEN

					 	--dbms_output.put_line('Value1 is : ' || v_value);

						v_discount_line_rec.p_discount_id := i.list_header_id;
						v_discount_line_rec.p_discount_name := i.name;
						v_discount_line_rec.p_discount_line_id := j.list_line_id;

						--dbms_output.put_line('Arithmetic Operator: ' || j.arithmetic_operator);
						--dbms_output.put_line('Operand: ' || j.operand);

						IF (j.arithmetic_operator = 'AMT') THEN
							v_discount_line_rec.p_discount_percent := nvl(j.operand/p_list_price * 100,0);
						ELSIF (j.arithmetic_operator = '%') THEN
							v_discount_line_rec.p_discount_percent := nvl(j.operand,0);
						ELSIF (j.arithmetic_operator = 'NEWPRICE') THEN
							v_discount_line_rec.p_discount_percent := p_list_price - nvl(j.operand,0);
						END IF;

						IF (p_asc_desc_flag = 'A') THEN
							IF (v_discount_line_rec.p_discount_percent < p_best_adj_percent) THEN
								cnt := cnt + 1;
								v_discount_lines_tbl(cnt) := v_discount_line_rec;
							END IF;
						ELSE
							IF (v_discount_line_rec.p_discount_percent > p_best_adj_percent) THEN
								cnt := cnt + 1;
								v_discount_lines_tbl(cnt) := v_discount_line_rec;
							END IF;
						END IF;
					END IF;
				END LOOP;
			END IF;
	END LOOP;
	--x_discount_lines_tbl := v_discount_lines_tbl;

	--dbms_output.put_line('Hellooooo');
	IF (v_discount_lines_tbl.COUNT > 0) THEN

		--Delete all the records
		DELETE FROM QP_DISCOUNTS_UPG_TEMP;

		v_index := v_discount_lines_tbl.FIRST;
		LOOP
			--dbms_output.put_line('Discount Id : ' || v_discount_lines_tbl(v_index).p_discount_id);
			--dbms_output.put_line('Discount Line Id : ' || v_discount_lines_tbl(v_index).p_discount_line_id);
			--dbms_output.put_line('Discount Name : ' || v_discount_lines_tbl(v_index).p_discount_name);
			--dbms_output.put_line('Discount Percent : ' || v_discount_lines_tbl(v_index).p_discount_percent);


			INSERT INTO QP_DISCOUNTS_UPG_TEMP VALUES(v_discount_lines_tbl(v_index).p_discount_id,
							v_discount_lines_tbl(v_index).p_discount_name,
							v_discount_lines_tbl(v_index).p_discount_line_id,
							v_discount_lines_tbl(v_index).p_discount_percent);
		EXIT WHEN v_index = v_discount_lines_tbl.LAST;
		v_index := v_discount_lines_tbl.NEXT(v_index);
		END LOOP;

		-- Get the first best discount based on the p_asc_desc_flag 'A'- Ascending , 'D' - Descending
		IF (p_asc_desc_flag = 'A') THEN
	    	 SELECT discount_id , discount_name , discount_line_id, discount_percent
	    	 INTO   x_discount_rec.p_discount_id,
      		   x_discount_rec.p_discount_name,
	    		   x_discount_rec.p_discount_line_id,
      		   x_discount_rec.p_discount_percent
	      FROM QP_DISCOUNTS_UPG_TEMP
      	 WHERE DISCOUNT_PERCENT = (SELECT min(DISCOUNT_PERCENT) FROM QP_DISCOUNTS_UPG_TEMP)
	      AND ROWNUM = 1;
		ELSE
	    	 SELECT discount_id , discount_name , discount_line_id, discount_percent
	    	 INTO x_discount_rec.p_discount_id,
      	      x_discount_rec.p_discount_name,
	    	      x_discount_rec.p_discount_line_id,
      	      x_discount_rec.p_discount_percent
	    	 FROM QP_DISCOUNTS_UPG_TEMP
       	 WHERE DISCOUNT_PERCENT = (SELECT max(DISCOUNT_PERCENT) FROM QP_DISCOUNTS_UPG_TEMP)
	    	 AND ROWNUM = 1;
		END IF;
	ELSE
			x_discount_rec.p_discount_id := NULL;
			x_discount_rec.p_discount_name := NULL;
			x_discount_rec.p_discount_line_id := NULL;
			x_discount_rec.p_discount_percent := NULL;
	END IF;

		x_discount_line_rec := x_discount_rec;

     --dbms_output.put_line(x_discount_rec.p_discount_id);
     --dbms_output.put_line(x_discount_rec.p_discount_name);
     --dbms_output.put_line(x_discount_rec.p_discount_line_id);
     --dbms_output.put_line(x_discount_rec.p_discount_percent);

EXCEPTION
   WHEN OTHERS THEN
               err_num := SQLCODE;
               err_msg := SUBSTR(SQLERRM, 1, 100);
               --DBMS_OUTPUT.PUT_LINE('err_num ' || err_num);
               --DBMS_OUTPUT.PUT_LINE('err_msg ' || err_msg);


END Get_Discount_Lines;

END QP_Pricing_Engine_PVT;

/
