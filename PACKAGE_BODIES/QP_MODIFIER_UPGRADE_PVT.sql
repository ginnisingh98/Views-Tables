--------------------------------------------------------
--  DDL for Package Body QP_MODIFIER_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIER_UPGRADE_PVT" AS
/* $Header: QPXVDISB.pls 120.2 2006/02/16 15:08:53 rchellam noship $ */

	-- Qualifier Context and Attribute Constants

    G_QUALIFIER_ATTRIBUTE1         CONSTANT VARCHAR2(20) := 'PRICE_LIST_ID';
    G_QUALIFIER_ATTRIBUTE2         CONSTANT VARCHAR2(20) := 'DISCOUNT_ID';
    G_QUALIFIER_ATTRIBUTE3         CONSTANT VARCHAR2(25) := 'CUSTOMER_CLASS_CODE';
    G_QUALIFIER_ATTRIBUTE4         CONSTANT VARCHAR2(20) := 'SITE_ORG_ID';
    G_QUALIFIER_ATTRIBUTE5         CONSTANT VARCHAR2(20) := 'SOLD_TO_ORG_ID';
    G_QUALIFIER_ATTRIBUTE6         CONSTANT NUMBER       := 1004; /*'Customer PO Number';*/
    G_NEW_QUALIFIER_ATTRIBUTE6     CONSTANT NUMBER       := 1053; /*'Customer PO Number';*/
    G_QUALIFIER_ATTRIBUTE7         CONSTANT NUMBER       := 1007; /*'Order Type';*/
    G_NEW_QUALIFIER_ATTRIBUTE7     CONSTANT NUMBER       := 1325; /*'Order Type';*/
    G_QUALIFIER_ATTRIBUTE8         CONSTANT NUMBER       := 1005; /*'Agreement Type';*/
    G_NEW_QUALIFIER_ATTRIBUTE8     CONSTANT NUMBER       := 1468; /*'Agreement Type';*/
    G_QUALIFIER_ATTRIBUTE9         CONSTANT NUMBER       := 1006; /*'Agreement Name';*/
    G_NEW_QUALIFIER_ATTRIBUTE9     CONSTANT NUMBER       := 1467; /*'Agreement Name';*/
    G_QUALIFIER_ATTRIBUTE10        CONSTANT VARCHAR2(30) := 'GSA_CUSTOMER'; /* GSA Customer*/
    G_PRODUCT_ATTRIBUTE1           CONSTANT NUMBER       := 1001; /*'Item Number';*/
    G_NEW_PRODUCT_ATTRIBUTE1       CONSTANT NUMBER       := 1208; /*'Item Number';*/
    G_PRODUCT_ATTRIBUTE2           CONSTANT NUMBER       := 1045; /*'Item Category';*/
    G_PRICING_ATTRIBUTE_UNITS      CONSTANT VARCHAR2(20) := 'UNITS';
    G_PRICING_ATTRIBUTE_DOLLARS    CONSTANT VARCHAR2(20) := 'DOLLARS';

    G_PRICING_ATTRIBUTE1	   		CONSTANT NUMBER       := 1010;
    G_PRICING_ATTRIBUTE2	   		CONSTANT NUMBER       := 1011;
    G_PRICING_ATTRIBUTE3	   		CONSTANT NUMBER       := 1012;
    G_PRICING_ATTRIBUTE4	   		CONSTANT NUMBER       := 1013;
    G_PRICING_ATTRIBUTE5	   		CONSTANT NUMBER       := 1014;
    G_PRICING_ATTRIBUTE6	   		CONSTANT NUMBER       := 1015;
    G_PRICING_ATTRIBUTE7	   		CONSTANT NUMBER       := 1016;
    G_PRICING_ATTRIBUTE8	   		CONSTANT NUMBER       := 1017;
    G_PRICING_ATTRIBUTE9	   		CONSTANT NUMBER       := 1018;
    G_PRICING_ATTRIBUTE10   		CONSTANT NUMBER       := 1019;
    G_PRICING_ATTRIBUTE11   		CONSTANT NUMBER       := 1040;
    G_PRICING_ATTRIBUTE12   		CONSTANT NUMBER       := 1041;
    G_PRICING_ATTRIBUTE13   		CONSTANT NUMBER       := 1042;
    G_PRICING_ATTRIBUTE14   		CONSTANT NUMBER       := 1043;
    G_PRICING_ATTRIBUTE15   		CONSTANT NUMBER       := 1044;

	-- Private Procedure

  PROCEDURE Get_Percent (p_percent 	  NUMBER ,
			p_amount  			  NUMBER,
			p_newprice 			  NUMBER,
			x_operand 	       OUT NOCOPY /* file.sql.39 change */  NUMBER,
			x_arithmetic_operator OUT NOCOPY /* file.sql.39 change */  VARCHAR2) AS
  BEGIN

    IF (p_percent IS NOT NULL) THEN
		    x_operand := p_percent;
		    x_arithmetic_operator := '%';
    ELSIF (p_amount IS NOT NULL) THEN
		    x_operand := p_amount;
              x_arithmetic_operator := 'AMT';
    ELSIF (p_newprice IS NOT NULL) THEN
		    x_operand := p_newprice;
		    x_arithmetic_operator := 'NEWPRICE';
    ELSE
		x_operand := 0;
		x_arithmetic_operator := '%';
    END IF;

  END Get_Percent;

  PROCEDURE Create_Discount_Mapping_Record(p_old_discount_id 	   NUMBER,
								   p_old_discount_line_id   NUMBER,
								   p_new_list_header_id 	   NUMBER,
								   p_new_list_line_id	   NUMBER,
								   p_pricing_context	   VARCHAR2,
								   p_new_type		 	   VARCHAR2,
								   p_old_pbl_low		   NUMBER,
								   p_old_pbl_high		   NUMBER,
								   p_old_method_type_code   VARCHAR2,
								   p_old_pb_percent	 	   NUMBER,
								   p_old_pb_amount		   NUMBER,
								   p_old_pb_price		   NUMBER) AS

  err_msg varchar2(2000);

  BEGIN

	INSERT INTO QP_DISCOUNT_MAPPING(OLD_DISCOUNT_ID,OLD_DISCOUNT_LINE_ID,
		 NEW_LIST_HEADER_ID,NEW_LIST_LINE_ID, OLD_PRICE_BREAK_LINES_LOW,
		 OLD_PRICE_BREAK_LINES_HIGH, OLD_METHOD_TYPE_CODE, OLD_PRICE_BREAK_PERCENT,
		 OLD_PRICE_BREAK_AMOUNT, OLD_PRICE_BREAK_PRICE, NEW_TYPE,PRICING_CONTEXT)
     VALUES (p_old_discount_id,p_old_discount_line_id,p_new_list_header_id,p_new_list_line_id,
		   p_old_pbl_low,p_old_pbl_high,p_old_method_type_code,p_old_pb_percent,
		   p_old_pb_amount,p_old_pb_price,p_new_type,p_pricing_context);
  EXCEPTION
   WHEN OTHERS THEN
    err_msg := SQLERRM;
    rollback;
    QP_Util.Log_Error(p_id1 => p_old_discount_id,
							p_id2 => p_old_discount_line_id,
							p_id3 => p_new_list_header_id,
							p_id4 => p_new_list_line_id,
							p_id5 => p_old_pbl_low,
							p_id6 => p_old_pbl_high,
							p_id7 => p_old_method_type_code,
							p_id8 => p_new_type,
							p_error_type => 'DISCOUNT_MAPPING',
							p_error_desc => err_msg,
							p_error_module => 'Create_Discount_Mapping_Record');
    raise;
  END ;

  PROCEDURE QP_Util_Get_Context_Attribute(p_entity_id	VARCHAR2,
								  x_context   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
								  x_attribute OUT NOCOPY /* file.sql.39 change */ VARCHAR2) AS
  v_context 		VARCHAR2(30);
  v_attribute		VARCHAR2(30);
  err_msg			VARCHAR2(2000);

  BEGIN
   QP_Util.get_context_attribute(p_entity_id,v_context,v_attribute);
   x_context := v_context;
   x_attribute := v_attribute;
  EXCEPTION
   WHEN OTHERS THEN
    err_msg := SQLERRM;
    rollback;
    QP_Util.Log_Error(p_id1 => p_entity_id,
							p_error_type => 'GET_CONTEXT_ATTRIBUTE',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util_Get_Context_Attribute');
    raise;
  END;

  PROCEDURE Get_Context_Attributes(
			     p_entity_id    	     NUMBER,
				x_context 		OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
				x_attribute 		OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
				x_product_flag 	OUT NOCOPY /* file.sql.39 change */  BOOLEAN,
				x_pricing_flag		OUT NOCOPY /* file.sql.39 change */  BOOLEAN,
				x_qualifier_flag 	OUT NOCOPY /* file.sql.39 change */  BOOLEAN) AS

  err_msg varchar2(2000);

  BEGIN

	-- Init the variables to null

		x_context 		:= NULL;
		x_attribute 		:= NULL;

		x_product_flag := FALSE;
		x_qualifier_flag := FALSE;
		x_pricing_flag := FALSE;

		QP_Util_Get_Context_Attribute(p_entity_id,x_context,x_attribute);

		IF (p_entity_id in (G_PRODUCT_ATTRIBUTE1,G_NEW_PRODUCT_ATTRIBUTE1,G_PRODUCT_ATTRIBUTE2)) THEN
		  -- Get the attribute and context for item or item category
			 x_product_flag := TRUE;
		ELSIF (p_entity_id in (G_QUALIFIER_ATTRIBUTE6,G_NEW_QUALIFIER_ATTRIBUTE6,
						   G_QUALIFIER_ATTRIBUTE7,G_NEW_QUALIFIER_ATTRIBUTE7,
						   G_QUALIFIER_ATTRIBUTE8,G_NEW_QUALIFIER_ATTRIBUTE8,
						   G_QUALIFIER_ATTRIBUTE9,G_NEW_QUALIFIER_ATTRIBUTE9)) THEN
		  -- Get the attribute and context for customer po,order type,agreement type
			 x_qualifier_flag := TRUE;
		ELSIF (p_entity_id in (G_PRICING_ATTRIBUTE1, G_PRICING_ATTRIBUTE2, G_PRICING_ATTRIBUTE3,
						   G_PRICING_ATTRIBUTE4, G_PRICING_ATTRIBUTE5, G_PRICING_ATTRIBUTE6,
						   G_PRICING_ATTRIBUTE7, G_PRICING_ATTRIBUTE8, G_PRICING_ATTRIBUTE9,
						   G_PRICING_ATTRIBUTE10, G_PRICING_ATTRIBUTE11, G_PRICING_ATTRIBUTE12,
						   G_PRICING_ATTRIBUTE13, G_PRICING_ATTRIBUTE14, G_PRICING_ATTRIBUTE15)) THEN
		  -- Get the attribute and context for all pricing attributes
			 x_pricing_flag := TRUE;
		END IF;

  EXCEPTION
    WHEN OTHERS THEN
     err_msg := SQLERRM;
	rollback;
     QP_Util.Log_Error(p_id1 => p_entity_id,
							p_error_type => 'GET_CONTEXT_ATTR',
							p_error_desc => err_msg,
							p_error_module => 'Get_Context_Attributes');
	raise;
  END Get_Context_Attributes;


  PROCEDURE  Create_Parallel_Slabs
                (l_workers IN NUMBER) --2422176
       		--(l_workers IN NUMBER := 5)
  IS
      v_type              	 CONSTANT VARCHAR2(3) := 'DLT';
      l_total_lines            NUMBER;
      l_min_line               NUMBER;
      l_max_line               NUMBER;
      l_counter                NUMBER;
      l_gap                    NUMBER;
      l_worker_count           NUMBER;
      l_worker_start           NUMBER;
      l_worker_end             NUMBER;
      l_price_list_line_id     NUMBER;
      l_start_flag             NUMBER;
      l_total_workers          NUMBER;

   BEGIN

      delete qp_upg_lines_distribution
	 where line_type = v_type;
      commit;

      BEGIN
                SELECT
                     NVL(MIN(DISCOUNT_ID),0),
                     NVL(MAX(DISCOUNT_ID),0)
                INTO
                     l_min_line,
                     l_max_line
                FROM
		           SO_DISCOUNTS;

      EXCEPTION
         when others then
         null;
      END;


      FOR i in 1..l_workers LOOP

          l_worker_start := l_min_line + trunc( (i-1) * (l_max_line-l_min_line)/l_workers);

          l_worker_end := l_min_line + trunc(i*(l_max_line - l_min_line)/l_workers);

          IF (i <> l_workers) then
             l_worker_end := l_worker_end - 1;
          END IF;

                QP_Modifier_Upgrade_Util_PVT.insert_line_distribution
                ( l_worker      => i,
                  l_start_line  => l_worker_start,
                  l_end_line    => l_worker_end,
                  l_type_var    => v_type);

       END LOOP;

       commit;

  END Create_Parallel_Slabs;


  PROCEDURE Create_Discounts(l_worker IN NUMBER := 1) AS

    CURSOR get_discounts(p_min_line NUMBER,
			 	     p_max_line NUMBER) IS

    SELECT sod.DISCOUNT_ID, sod.CREATION_DATE, sod.CREATED_BY, sod.LAST_UPDATE_DATE,
	   sod.LAST_UPDATED_BY, sod.LAST_UPDATE_LOGIN, sod.PROGRAM_APPLICATION_ID, sod.PROGRAM_ID,
	   sod.PROGRAM_UPDATE_DATE,sod.REQUEST_ID, sod.NAME, sod.DISCOUNT_TYPE_CODE, sod.PRICE_LIST_ID,
	   nvl(sod.AUTOMATIC_DISCOUNT_FLAG,'N') AUTOMATIC_DISCOUNT_FLAG, sod.OVERRIDE_ALLOWED_FLAG,
	   sod.GSA_INDICATOR, sod.PRORATE_FLAG, sod.PERCENT, sod.AMOUNT, sod.START_DATE_ACTIVE, sod.END_DATE_ACTIVE,
	   sod.DESCRIPTION, sod.DISCOUNT_LINES_FLAG, sopl.CURRENCY_CODE,sod.CONTEXT,
	   sod.ATTRIBUTE1, sod.ATTRIBUTE2, sod.ATTRIBUTE3,sod.ATTRIBUTE4,sod.ATTRIBUTE5,sod.ATTRIBUTE6,sod.ATTRIBUTE7,
	   sod.ATTRIBUTE8, sod.ATTRIBUTE9,sod.ATTRIBUTE10,sod.ATTRIBUTE11,sod.ATTRIBUTE12,sod.ATTRIBUTE13,
	   sod.ATTRIBUTE14, sod.ATTRIBUTE15
    FROM   SO_DISCOUNTS sod,QP_LIST_HEADERS_B sopl
    WHERE  sod.price_list_id = sopl.list_header_id
    AND    NOT EXISTS (SELECT 'x'
		             FROM QP_DISCOUNT_MAPPING a
		             WHERE a.OLD_DISCOUNT_ID = sod.DISCOUNT_ID
		             AND   a.NEW_TYPE in ('O','L','Q','X'))
    AND    sod.DISCOUNT_ID BETWEEN p_min_line and p_max_line;

    CURSOR get_discount_customers(p_discount_id NUMBER) IS
    SELECT CUSTOMER_CLASS_CODE ,CUSTOMER_ID , SITE_USE_ID,START_DATE_ACTIVE,END_DATE_ACTIVE,CONTEXT,ATTRIBUTE1,
    ATTRIBUTE2,ATTRIBUTE3, ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,
    ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
    FROM   SO_DISCOUNT_CUSTOMERS
    WHERE  DISCOUNT_ID = p_discount_id;

    CURSOR get_discount_lines(p_discount_id NUMBER)  IS
    SELECT DISCOUNT_LINE_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
	      REQUEST_ID, DISCOUNT_ID, ENTITY_ID, ENTITY_VALUE, PERCENT,
	      AMOUNT, PRICE, START_DATE_ACTIVE, END_DATE_ACTIVE,CONTEXT,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,
	      ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,
    		 ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
    FROM   SO_DISCOUNT_LINES_115
    WHERE  DISCOUNT_ID = p_discount_id;


    CURSOR get_price_break_lines(p_discount_line_id NUMBER) IS

    SELECT PRICE_BREAK_LINES_LOW_RANGE, PRICE_BREAK_LINES_HIGH_RANGE, DISCOUNT_LINE_ID,
	      METHOD_TYPE_CODE, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	      LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
           REQUEST_ID, PERCENT, AMOUNT, PRICE, UNIT_CODE, START_DATE_ACTIVE, END_DATE_ACTIVE,
	      CONTEXT,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3, ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,
		 ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
    FROM   SO_PRICE_BREAK_LINES
    WHERE  DISCOUNT_LINE_ID = p_discount_line_id;

    CURSOR get_discounts_not_migrated_cur IS
    SELECT a.DISCOUNT_ID,a.PRICE_LIST_ID
    FROM   SO_DISCOUNTS a
    WHERE  NOT EXISTS ( SELECT 'x'
		              FROM QP_LIST_HEADERS_B  b
		              WHERE  b.LIST_HEADER_ID = a.PRICE_LIST_ID);

    CURSOR get_contexts_for_pattrs_cur(p_entity_id NUMBER) IS
	SELECT nvl(a.DESCRIPTIVE_FLEX_CONTEXT_CODE,'Global Data Elements') descriptive_flex_context_code ,
		  b.ENTITY_CODE, a.COLUMN_SEQ_NUM, nvl(c.FORMAT_TYPE,'C') FORMAT_TYPE
	FROM   FND_DESCR_FLEX_COLUMN_USAGES a , SO_ENTITIES b, fnd_flex_value_sets c
	WHERE  a.DESCRIPTIVE_FLEXFIELD_NAME = 'PRICING_ATTRIBUTES'
	AND    a.APPLICATION_COLUMN_NAME = b.ENTITY_CODE
	AND    b.ENTITY_ID = p_entity_id
        AND    a.FLEX_VALUE_SET_ID = c.FLEX_VALUE_SET_ID(+);

    CURSOR get_uom_for_item_cur(p_price_list_id NUMBER,
						  p_entity_value  VARCHAR2) IS

	SELECT distinct a.UNIT_CODE
	FROM   SO_PRICE_LIST_LINES_115 a
	WHERE  a.PRICE_LIST_ID = p_price_list_id
	AND    a.INVENTORY_ITEM_ID = p_entity_value;


    x_list_header_id  		QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE;
    v_list_header_id  		QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE;
    x_list_line_id  		QP_LIST_LINES.LIST_LINE_ID%TYPE;
    v_list_line_id  		QP_LIST_LINES.LIST_LINE_ID%TYPE;
    v_price_break_line_id  	QP_LIST_LINES.LIST_LINE_ID%TYPE;
    x_pricing_attribute_id    QP_PRICING_ATTRIBUTES.PRICING_ATTRIBUTE_ID%TYPE;
    v_pricing_attribute_id    QP_PRICING_ATTRIBUTES.PRICING_ATTRIBUTE_ID%TYPE;
    x_operand 		          QP_LIST_LINES.OPERAND%TYPE;
    x_arithmetic_operator 	QP_LIST_LINES.ARITHMETIC_OPERATOR%TYPE;
    x_qualifier_grouping_no 	QP_QUALIFIERS.QUALIFIER_GROUPING_NO%TYPE;
    v_qualifier_grouping_no 	QP_QUALIFIERS.QUALIFIER_GROUPING_NO%TYPE := 0;
    v_cust_qualifier_grp_no 	QP_QUALIFIERS.QUALIFIER_GROUPING_NO%TYPE := 0;
    v_context		          VARCHAR2(30);
    v_attribute_name		VARCHAR2(30);
    v_pricing_context		VARCHAR2(30);
    v_pricing_attribute		VARCHAR2(30);
    v_pricing_flag		     BOOLEAN := FALSE;
    v_product_context		VARCHAR2(30);
    v_product_attribute		VARCHAR2(30);
    x_product_precedence      NUMBER;
    x_pricing_precedence      NUMBER;
    x_product_datatype        VARCHAR2(30);
    x_pricing_datatype		VARCHAR2(30);
    v_price_break_context	VARCHAR2(30);
    v_price_break_attribute	VARCHAR2(30);
    v_price_context	          VARCHAR2(30);
    v_price_attribute		VARCHAR2(30);
    v_operator_code	          VARCHAR2(30);
    v_qualifier_flag		BOOLEAN := FALSE;
    x_qualifier_precedence    NUMBER;
    x_qualifier_datatype      VARCHAR2(30);
    x_error_code	          NUMBER;
    v_product_flag	          BOOLEAN := FALSE;
    v_discount_level		VARCHAR2(20);
    v_line_type_code		VARCHAR2(10);
    v_pricing_phase_id        NUMBER;
    x_rltd_modifier_id		QP_RLTD_MODIFIERS.RLTD_MODIFIER_ID%TYPE;
    v_lines_flag		     BOOLEAN := FALSE;
    v_new_flag			     BOOLEAN := TRUE;
    v_seq_num			     NUMBER := 0;
    v_new_line_flag		     BOOLEAN := TRUE;
    v_line_seq_num		     NUMBER := 0;
    v_mapping_line_type		VARCHAR2(1);
    v_dummy			     VARCHAR2(1);
    l_precedence              NUMBER;
    err_msg 			     VARCHAR2(2000);
    v_old_discount_id	     NUMBER;
    v_old_discount_line_id	NUMBER;
    v_item_uom			     VARCHAR2(30) := NULL;
    v_price_datatype		VARCHAR2(30);
    v_break_count		     NUMBER := 0;
    v_unit_code			VARCHAR2(30);
    v_price_break_type_code	VARCHAR2(30);
    v_incomp_grp_code		VARCHAR2(30);
    v_pricing_group_sequence  NUMBER;
    v_min_line			     NUMBER;
    v_max_line			     NUMBER;
    v_contexts_flag           BOOLEAN := FALSE;
    v_entity_id			NUMBER;
    v_hqual_exists            BOOLEAN := FALSE;
    v_qualification_ind       NUMBER;
    v_precedence              NUMBER;
    are_there_discount_lines  VARCHAR2(1);
    number_discount_lines     NUMBER := 0;
   l_pricing_attr_value_from VARCHAR2(240);
   l_comparison_operator_code VARCHAR2(30);

	--  Other Constants

    G_COMPARATOR_CODE	CONSTANT VARCHAR2(1) := '=';
    G_ORDER			CONSTANT VARCHAR2(15) := 'ORDER_TOTAL';
    G_LINE			CONSTANT VARCHAR2(15) := 'LINE_ITEM';

  BEGIN

	-- Processing Header Level Discounts

  -- To bypass the flex validation set g_validate_flag to FALSE
  -- qp_util.validate_qp_flexfield() uses this flag.

	qp_util.g_validate_flag :=FALSE;

  begin

     select start_line_id,
            end_line_id
     into v_min_line,
          v_max_line
     from qp_upg_lines_distribution
     where worker = l_worker
     and line_type = G_LIST_TYPE_CODE;

  exception

      when no_data_found then

            /* log the error */
            v_min_line := 0;
            v_max_line := 0;
            commit;
            return;
  end;

--dbms_output.put_line('v_min_line : ' || v_min_line);
--dbms_output.put_line('v_max_line : ' || v_max_line);


  FOR i IN get_discounts(v_min_line,v_max_line)
  LOOP

      v_hqual_exists := FALSE;

	 v_old_discount_id := i.discount_id;

    -- If the Discount does not exist
	 QP_Modifier_Upgrade_Util_PVT.Create_List_Header(i.creation_date,
						      i.created_by,
			   			      i.last_update_date,
			   				 i.last_updated_by,
			   				 nvl(i.last_update_login,1),
			   				 G_LIST_TYPE_CODE,
			   				 i.start_date_active,
			   				 i.end_date_active,
			   				 nvl(i.automatic_discount_flag,'N'),
							 i.discount_lines_flag,
			   				 i.currency_code,
			   				 i.name,
			   				 i.description,
							 NULL,--version_no,
							 'N', -- ask_for_flag
							 'QP',--source_sys_code
							 'Y',--active_flag,
							 nvl(i.gsa_indicator,'N'),
							  i.context,
							  i.attribute1,
							  i.attribute2,
							  i.attribute3,
							  i.attribute4,
							  i.attribute5,
							  i.attribute6,
							  i.attribute7,
							  i.attribute8,
							  i.attribute9,
							  i.attribute10,
							  i.attribute11,
							  i.attribute12,
							  i.attribute13,
							  i.attribute14,
							  i.attribute15,
							  v_new_flag,
							  v_seq_num,
							  v_old_discount_id,
							  'DISCOUNTS',
							  x_list_header_id);

	-- Store the list header id
	v_list_header_id := x_list_header_id;
	v_seq_num := x_list_header_id;
	v_new_flag := FALSE;



    -- Create Qualifiers(For Price list) and attach it to the discount
    -- Get the context and attribute for the price list
    -- Price List and GSA Qualifiers are created with null grouping number

     IF (i.price_list_id IS NOT NULL) THEN

	  v_hqual_exists := TRUE;

	  QP_UTIL_Get_Context_Attribute(G_QUALIFIER_ATTRIBUTE1,v_context , v_attribute_name);

	  --dbms_output.put_line('Context for Price List Is ' || v_context);
	/* flex
           BEGIN

	   QP_UTIL.Get_Qual_Flex_Properties(v_context,
					v_attribute_name,
					i.price_list_id,
					x_qualifier_datatype,
					x_qualifier_precedence,
					x_error_code);

 	  IF (x_error_code <> 0 ) THEN
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE1,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_context || ' Attribute: ' || v_attribute_name,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
	  END IF;

	  EXCEPTION
	   WHEN OTHERS THEN
    		err_msg := SQLERRM;
    		rollback;
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE1,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		raise;
	  END;
              flex */

	   QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
			   							    i.created_by,
										    i.last_update_date,
									   	    i.last_updated_by,
									         i.last_update_login,
									         i.program_application_id,
									         i.program_id,
								              i.program_update_date,
									         i.request_id,
									 	    'N',
										    G_COMPARATOR_CODE,
										    v_context,
								   		    v_attribute_name,
								 	         i.price_list_id,
									         null,
									         v_list_header_id,
										    NULL,
--						    				    x_qualifier_precedence,
--						       			    nvl(x_qualifier_datatype,'C'),
						    				    140,
						       			            'C',
										    null, -- start_date_active
										    null, -- end_date_active
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
					   	    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    null,
						    				    v_old_discount_id,
						    				    'DISCOUNTS',
						    				    x_qualifier_grouping_no);
      END IF; -- i.price_list_id IS NOT NULL

	-- Create a GSA Qualifier
       IF (i.GSA_INDICATOR = 'Y') THEN

	  v_hqual_exists := TRUE;

       -- Get the context and attribute for the gsa qualifier
	   QP_UTIL_Get_Context_Attribute(G_QUALIFIER_ATTRIBUTE10,v_context , v_attribute_name);

        /* flex

	  BEGIN

	   QP_UTIL.Get_Qual_Flex_Properties(v_context,
					v_attribute_name,
					i.gsa_indicator,
					x_qualifier_datatype,
					x_qualifier_precedence,
					x_error_code);
 	  IF (x_error_code <> 0 ) THEN
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE10,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_context || ' Attribute: ' || v_attribute_name,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
	  END IF;

	  EXCEPTION
	   WHEN OTHERS THEN
    		err_msg := SQLERRM;
    		rollback;
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE10,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		raise;
	  END;

      flex */

	-- Create a GSA Qualifier
        QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
						    i.created_by,
						    i.last_update_date,
						    i.last_updated_by,
						    i.last_update_login,
						    i.program_application_id,
						    i.program_id,
						    i.program_update_date,
						    i.request_id,
						    'N',
						    G_COMPARATOR_CODE,
						    v_context,
						    v_attribute_name,
						    i.gsa_indicator,
						    -1,
						    v_list_header_id,
						    NULL,
--						    x_qualifier_precedence,
--						    nvl(x_qualifier_datatype,'C'),
						    100,
						    'C',
						    null, -- start_date_active
						    null, -- end_date_active
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
					   	    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    null,
						    v_old_discount_id,
						    'DISCOUNTS',
						    x_qualifier_grouping_no);
      END IF;

	--  Check other qualifiers from so_discount_customers like customer_class_code,site_use_id,
	--  customer_id create qualifiers
	--  There needs to be different group no for each record in so_discount_customers

     FOR l IN get_discount_customers(i.discount_id)
     LOOP

	 v_hqual_exists := TRUE;

      IF (l.customer_class_code IS NOT NULL) THEN

       -- Get the context and attribute for the customer class code
	   QP_UTIL_Get_Context_Attribute(G_QUALIFIER_ATTRIBUTE3,v_context , v_attribute_name);
     /* flex
	  BEGIN
	   QP_UTIL.Get_Qual_Flex_Properties(v_context,
					    v_attribute_name,
					    l.customer_class_code,
					    x_qualifier_datatype,
					    x_qualifier_precedence,
					    x_error_code);
 	  IF (x_error_code <> 0 ) THEN
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE3,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_context || ' Attribute: ' || v_attribute_name,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
	  END IF;
	   EXCEPTION
	    WHEN OTHERS THEN
    		err_msg := SQLERRM;
    		rollback;
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE3,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		raise;
	   END;
         flex */
	  -- Create the Qualifier for customer class code
        QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
						i.created_by,
						i.last_update_date,
						i.last_updated_by,
						i.last_update_login,
						i.program_application_id,
						i.program_id,
						i.program_update_date,
						i.request_id,
						'N',
						G_COMPARATOR_CODE,
						v_context,
						v_attribute_name,
						l.customer_class_code,
						v_cust_qualifier_grp_no,
						v_list_header_id,
						NULL,
--						x_qualifier_precedence,
--						nvl(x_qualifier_datatype,'C'),
						310,
						'C',
						l.start_date_active,
						l.end_date_active,
						l.context,
						l.attribute1,
						l.attribute2,
						l.attribute3,
						l.attribute4,
						l.attribute5,
						l.attribute6,
						l.attribute7,
						l.attribute8,
						l.attribute9,
						l.attribute10,
						l.attribute11,
						l.attribute12,
						l.attribute13,
						l.attribute14,
						l.attribute15,
					     v_old_discount_id,
					     'DISCOUNTS',
						x_qualifier_grouping_no);
	    v_cust_qualifier_grp_no := x_qualifier_grouping_no;
	  END IF; --l.customer_class_code IS NOT NULL

	  IF (l.site_use_id IS NOT NULL) THEN

           -- Get the context and attribute for the site_use_id
	   QP_UTIL_Get_Context_Attribute(G_QUALIFIER_ATTRIBUTE4,v_context , v_attribute_name);
      /* flex
       BEGIN
	   QP_UTIL.Get_Qual_Flex_Properties(v_context,
					v_attribute_name,
					l.site_use_id,
					x_qualifier_datatype,
					x_qualifier_precedence,
					x_error_code);
 	  IF (x_error_code <> 0 ) THEN
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE4,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_context || ' Attribute: ' || v_attribute_name,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
	  END IF;
	  EXCEPTION
	   WHEN OTHERS THEN
    		err_msg := SQLERRM;
    		rollback;
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE4,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		raise;
	   END;
     flex */
	   -- Create the qualifier for site_use_id
           QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
						i.created_by,
						i.last_update_date,
						i.last_updated_by,
						i.last_update_login,
						i.program_application_id,
						i.program_id,
						i.program_update_date,
						i.request_id,
						'N',
						G_COMPARATOR_CODE,
						v_context,
						v_attribute_name,
						l.site_use_id,
						v_cust_qualifier_grp_no,
						v_list_header_id,
						NULL,
--						x_qualifier_precedence,
--						nvl(x_qualifier_datatype,'C'),
						270,
						'N',
						l.start_date_active,
						l.end_date_active,
						l.context,
						l.attribute1,
						l.attribute2,
						l.attribute3,
						l.attribute4,
						l.attribute5,
						l.attribute6,
						l.attribute7,
						l.attribute8,
						l.attribute9,
						l.attribute10,
						l.attribute11,
						l.attribute12,
						l.attribute13,
						l.attribute14,
						l.attribute15,
					     v_old_discount_id,
						'DISCOUNTS',
						x_qualifier_grouping_no);
	   IF ( v_cust_qualifier_grp_no = 0 ) THEN
	    v_cust_qualifier_grp_no := x_qualifier_grouping_no;
	   END IF;
	  END IF; --Site Org Id

	  IF (l.customer_id IS NOT NULL) THEN

       -- Get the context and attribute for the customer_id
	   QP_UTIL_Get_Context_Attribute(G_QUALIFIER_ATTRIBUTE5,v_context , v_attribute_name);
    /* flex
       BEGIN
	   QP_UTIL.Get_Qual_Flex_Properties(v_context,
					v_attribute_name,
					l.customer_id,
					x_qualifier_datatype,
					x_qualifier_precedence,
					x_error_code);
 	  IF (x_error_code <> 0 ) THEN
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE5,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_context || ' Attribute: ' || v_attribute_name,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
	  END IF;
	  EXCEPTION
	   WHEN OTHERS THEN
    		err_msg := SQLERRM;
    		rollback;
    		QP_Util.Log_Error(p_id1 => G_QUALIFIER_ATTRIBUTE5,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		raise;
	   END;
      flex */
	  -- Create the qualifier for customer_id
           QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
					i.created_by,
					i.last_update_date,
					i.last_updated_by,
					i.last_update_login,
					i.program_application_id,
					i.program_id,
					i.program_update_date,
					i.request_id,
					'N',
					G_COMPARATOR_CODE,
					v_context,
					v_attribute_name,
					l.customer_id,
					v_cust_qualifier_grp_no,
					v_list_header_id,
					NULL,
--					x_qualifier_precedence,
--					nvl(x_qualifier_datatype,'C'),
					260,
					'N',
					l.start_date_active,
					l.end_date_active,
					l.context,
					l.attribute1,
					l.attribute2,
					l.attribute3,
					l.attribute4,
					l.attribute5,
					l.attribute6,
					l.attribute7,
					l.attribute8,
					l.attribute9,
					l.attribute10,
					l.attribute11,
					l.attribute12,
					l.attribute13,
					l.attribute14,
					l.attribute15,
					v_old_discount_id,
					'DISCOUNTS',
					x_qualifier_grouping_no);
	   IF ( v_cust_qualifier_grp_no = 0 ) THEN
	    v_cust_qualifier_grp_no := x_qualifier_grouping_no;
	   END IF;
	  END IF;  --l.customer_id IS NOT NULL
      v_cust_qualifier_grp_no := 0;
    END LOOP; -- Discount Customers

	--  Create List Line

	-- If discount_lines_flag = 'N'
	-- there are no discount lines in so_discount_lines
	-- Determine the Discount Level

	IF (i.discount_type_code = G_ORDER) THEN
		v_discount_level := G_ORDER_LEVEL;
		v_pricing_phase_id := 4;
	ELSE
		v_discount_level := G_LINE_LEVEL;
		v_pricing_phase_id := 2;
	END IF;

	IF (i.automatic_discount_flag = 'Y') THEN
	 v_pricing_group_sequence := 1;
	 v_incomp_grp_code := 'LVL 1';
	ELSE
	 v_pricing_group_sequence := NULL; -- Manual Discounts
	 v_incomp_grp_code := NULL;
	END IF;

     select count(*)
	into   number_discount_lines
	from   so_discount_lines_115
	where  discount_id = i.discount_id;

     if (number_discount_lines = 0 )
	then
	    are_there_discount_lines := 'N';
     else
	    are_there_discount_lines := 'Y';
     end if;


--   IF (i.discount_lines_flag = 'N' ) THEN  /* Order Level Discount */

  IF (are_there_discount_lines = 'N' ) THEN  /* Order Level Discount */


	--  Determine the Arthimetic Operator and Operand in qp_list_lines from Percent and Amount columns
	--  in so_discounts table

    Get_Percent(i.percent , i.amount , 0 , x_operand , x_arithmetic_operator);

    IF (x_arithmetic_operator = 'AMT') THEN
	IF (x_operand < 0) THEN
	 v_line_type_code := G_SURCHARGE_CODE;
	 x_operand := -(x_operand);
	ELSE
	 v_line_type_code := G_LIST_LINE_TYPE_CODE;
	END IF;
    ELSE
	v_line_type_code := G_LIST_LINE_TYPE_CODE;
    END IF;

    -- If Level = 'Order' , then there is no record in Pricing Attributes.
    -- So v_qualification_ind = 5
    -- If Level = 'Line' , then there is record in Pricing Attributes which has product.
    -- So v_qualification_ind = 1

    IF (v_discount_level = G_ORDER_LEVEL) THEN
     v_qualification_ind := 5;
    ELSE
	v_qualification_ind := 1;
    END IF;

-- mkarya for bug 1807828, product precedence must be populated for LINE LEVEL discounts as pricing attribute record is always created for LINE LEVEL discounts with ALL product and ALL pricing attribute
    v_precedence := NULL;
    IF (v_discount_level = G_LINE_LEVEL) THEN
       select a.COLUMN_SEQ_NUM
         INTO v_precedence
         FROM FND_DESCR_FLEX_COLUMN_USAGES a
        WHERE a.DESCRIPTIVE_FLEXFIELD_NAME = 'QP_ATTR_DEFNS_PRICING'
          AND a.APPLICATION_ID = 661 --(QP). Added for bug 5030757
          AND a.DESCRIPTIVE_FLEX_CONTEXT_CODE = 'ITEM'
          AND a.APPLICATION_COLUMN_NAME = 'PRICING_ATTRIBUTE3';
    END IF;
    -- Create the list line
    QP_Modifier_Upgrade_Util_PVT.Create_List_Line(i.creation_date,
					i.created_by,
					i.last_update_date,
					i.last_updated_by,
					i.last_update_login,
					i.program_application_id,
					i.program_id,
					i.program_update_date,
					i.request_id,
					v_list_header_id,
					v_line_type_code,
					i.start_date_active,
					i.end_date_active,
					i.automatic_discount_flag,
					v_discount_level,
					x_arithmetic_operator,
					x_operand,
					v_pricing_phase_id,
					v_incomp_grp_code, -- incomp_grp_code
					v_pricing_group_sequence, -- pricing_group_seq
					'N', -- accrual_flag
-- 					NULL, -- issue Can this be null
					v_precedence, -- for bug 1807828
					i.PRORATE_FLAG,
					'N', -- print on invoice flag
					nvl(i.override_allowed_flag,'N'), -- override flag
					null,
					i.context,
					i.attribute1,
					i.attribute2,
					i.attribute3,
					i.attribute4,
					i.attribute5,
					i.attribute6,
					i.attribute7,
					i.attribute8,
					i.attribute9,
					i.attribute10,
					i.attribute11,
					i.attribute12,
					i.attribute13,
					i.attribute14,
					i.attribute15,
					v_qualification_ind,
					v_new_line_flag,
					v_line_seq_num,
				     v_old_discount_id,
					v_old_discount_line_id,
				     'DISCOUNTS',
					x_list_line_id);
	-- Store the List Line Id
	v_list_line_id := x_list_line_id;
	v_line_seq_num := x_list_line_id;
	v_new_line_flag := FALSE;

     -- Insert a record into the mapping table

      Create_Discount_Mapping_Record(i.discount_id,NULL,v_list_header_id,v_list_line_id,null,'O',
							  null,null,null,null,null,null);

	-- Create a record in qp_pricing_attributes for ALL products and ALL pricing attributes only if
	-- LINE LEVEL Discounts with no actual discount lines
	-- Added after discounts upgrade review with Jay and Alison

       IF (v_discount_level = G_LINE_LEVEL) THEN


		-- Create the Product/Pricing Attribute
   		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute(i.creation_date,
									i.created_by,
									i.last_update_date,
									i.last_updated_by,
									i.last_update_login,
									i.program_application_id,
									i.program_id,
									i.program_update_date,
									i.request_id,
									v_list_line_id,
									'N',
									'N',
									'ITEM',
									'PRICING_ATTRIBUTE3',
									'ALL',
									NULL, --Product UOM Code
								     NULL,
									NULL,
									NULL,--Pricing attr value from
									NULL, --Pricing_attr_value_to
									NULL, -- changed to NULL from BETWEEN for bug 1872995
									'N', -- pricing datatype
									'C',
									v_old_discount_id,
									v_old_discount_line_id,
									'DISCOUNTS',
									x_pricing_attribute_id);
	  END IF;

 ELSE /* Line Level Discount */

	 -- Init the flag
	 v_lines_flag := FALSE;

	 IF (i.automatic_discount_flag = 'Y') THEN
		v_incomp_grp_code := 'LVL 1';
	 ELSE
		v_incomp_grp_code := NULL;
	 END IF;
      -- Need this init at header and line level.That is the reason this statement is there 2 times in this file
	 v_entity_id := NULL;



	 FOR j IN get_discount_lines(i.discount_id)
	 LOOP

       -- Need this init at header and line level.That is the reason this statement is there 2 times in this file
	  v_entity_id := NULL;

	  -- Check to see if there are any discount lines.

		v_old_discount_line_id := j.discount_line_id;

		IF (j.entity_id IN (G_PRICING_ATTRIBUTE1,G_PRICING_ATTRIBUTE2,G_PRICING_ATTRIBUTE3,
					     G_PRICING_ATTRIBUTE4,G_PRICING_ATTRIBUTE5,G_PRICING_ATTRIBUTE6,
					     G_PRICING_ATTRIBUTE7,G_PRICING_ATTRIBUTE8,G_PRICING_ATTRIBUTE9,
					     G_PRICING_ATTRIBUTE10,G_PRICING_ATTRIBUTE11,G_PRICING_ATTRIBUTE12,
					     G_PRICING_ATTRIBUTE13,G_PRICING_ATTRIBUTE14,G_PRICING_ATTRIBUTE15)) THEN

	      v_contexts_flag := FALSE;
		 v_entity_id := j.entity_id;

		 -- Create discount lines for different contexts of an entity id
		 FOR b in get_contexts_for_pattrs_cur(j.entity_id)
		 LOOP
          /* flex
		  BEGIN

			v_contexts_flag := TRUE;

	   		QP_UTIL.Get_Prod_Flex_Properties(b.descriptive_flex_context_code,
							 b.entity_code,
							 j.entity_value,
							 x_pricing_datatype,
							 x_pricing_precedence,
							 x_error_code);
 	  		IF (x_error_code <> 0 ) THEN
    				QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'PROD_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || b.descriptive_flex_context_code ||
							   ' Attribute: ' || b.entity_code ,
							p_error_module => 'QP_Util.Get_Prod_Flex_Properties');
	  		END IF;
			l_precedence := x_pricing_precedence;
		  EXCEPTION
	   	    WHEN OTHERS THEN
    		     err_msg := SQLERRM;
    		     rollback;
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'PROD_FLEX_PROPERTIES',
							p_error_desc => 'Pricing Entity ' || err_msg,
							p_error_module => 'QP_Util.Get_Prod_Flex_Properties');
    		     raise;
		  END;

           flex */

	     	-- Set the lines flag to TRUE indicating that there are discount lines
			v_lines_flag := TRUE;

			--  If percent or  amount or price is not null then it is a regular discount line
			--  If percent and amount and price is null , then it is a price break.
			--  Ex ecute this logic only if it is a product or qualifier. This is because we are not dealing
			--  with any entities other than those handled in Get_Context_Attributes procedure

		   --  Determine the Arthimetic Operator and Operand in qp_list_lines from Percent and Amount
	    	   Get_Percent(j.percent , j.amount , j.price , x_operand , x_arithmetic_operator);

		   IF (j.percent IS NOT NULL OR j.amount IS NOT NULL OR j.price IS NOT NULL) THEN
    			IF (x_arithmetic_operator = 'AMT') THEN
			 IF (x_operand < 0) THEN
	 			v_line_type_code := G_SURCHARGE_CODE;
	 			x_operand := -(x_operand);
			 ELSE
	 			v_line_type_code := G_LIST_LINE_TYPE_CODE;
			 END IF;
    			ELSE
				v_line_type_code := G_LIST_LINE_TYPE_CODE;
    			END IF;
			v_mapping_line_type := 'L'; -- Regular discount line
			v_price_break_type_code := NULL;
			v_price_context := null;
			v_price_attribute := null;
			v_operator_code := null;
	        ELSE
			v_line_type_code := G_PRICE_BREAK_LINE_TYPE_CODE;
			v_mapping_line_type := 'Q'; -- Indicates that this line has price breaks
			v_price_break_type_code := 'POINT';
			v_price_context := 'VOLUME';
			v_price_attribute := 'PRICING_ATTRIBUTE10';
			v_operator_code := 'BETWEEN';
	  	   END IF;

		   -- For entity ids related to Pricing Attributes
		   -- If Qualifier Exists then v_qualification_ind = 1 , there is ateast 1 qualifier

		    v_qualification_ind := 1;

		    /*IF (v_hqual_exists) THEN
			v_qualification_ind := 1;
              ELSE
		     v_qualification_ind := 3;
		    END IF;*/

		    /*-- If PBH , then qualification_ind is null because it will have everything
		    IF (v_line_type_code = G_PRICE_BREAK_LINE_TYPE_CODE) THEN
			v_qualification_ind := null;
		    END IF;*/

			-- Create the list line
    			QP_Modifier_Upgrade_Util_PVT.Create_List_Line(j.creation_date,
												j.created_by,
												j.last_update_date,
												j.last_updated_by,
												j.last_update_login,
												j.program_application_id,
												j.program_id,
												j.program_update_date,
												j.request_id,
												v_list_header_id,
												v_line_type_code,
						     					j.start_date_active,
												j.end_date_active,
												i.automatic_discount_flag,
												v_discount_level,
												x_arithmetic_operator,
												x_operand,
												v_pricing_phase_id,
												v_incomp_grp_code,
												v_pricing_group_sequence, -- pricing_group_seq
												'N', -- accrual_flag
--												l_precedence,
												b.COLUMN_SEQ_NUM,
												i.PRORATE_FLAG,
												'N', -- print on invoice flag
												nvl(i.override_allowed_flag,'N'), -- override flag
												v_price_break_type_code,
												j.context,
												j.attribute1,
												j.attribute2,
												j.attribute3,
												j.attribute4,
												j.attribute5,
												j.attribute6,
												j.attribute7,
												j.attribute8,
												j.attribute9,
												j.attribute10,
												j.attribute11,
												j.attribute12,
												j.attribute13,
												j.attribute14,
												j.attribute15,
												v_qualification_ind,
												v_new_line_flag,
												v_line_seq_num,
												v_old_discount_id,
												v_old_discount_line_id,
												'DISCOUNTS',
												x_list_line_id);

				-- Store the List Line Id
				v_list_line_id := x_list_line_id;
				v_line_seq_num := x_list_line_id;
				v_new_line_flag := FALSE;


			--  Create Product/Pricing Attributes
			-- Create the Product/Pricing Attribute

/* Changes for Bug# 1872995 - When the pricing_context and pricing_attribute are null, assign null to pricing_attr_value_from and comparison_operator_code */

                       l_pricing_attr_value_from := j.entity_value;
                       l_comparison_operator_code := G_COMPARATOR_CODE;

                 If b.descriptive_flex_context_code is NULL and b.entity_code is null then
                       l_pricing_attr_value_from := NULL;
                       l_comparison_operator_code := NULL;
                 end if;


	   		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute(j.creation_date,
									j.created_by,
									j.last_update_date,
									j.last_updated_by,
									j.last_update_login,
									j.program_application_id,
									j.program_id,
									j.program_update_date,
									j.request_id,
									v_list_line_id,
									'N',
									'N',
									'ITEM',
									'PRICING_ATTRIBUTE3',
									'ALL',
									NULL, --Product UOM Code
									b.descriptive_flex_context_code,-- Pricing Context
									b.entity_code,--Pricing Attribute
									l_pricing_attr_value_from,
									NULL, --Pricing_attr_value_to
									l_comparison_operator_code,
--									nvl(x_pricing_datatype,'C'),
									b.FORMAT_TYPE,
									'C', -- product datatype
									v_old_discount_id,
									v_old_discount_line_id,
									'DISCOUNTS',
									x_pricing_attribute_id);

		   -- After discussion with Sripriya

		   --IF (v_line_type_code = G_PRICE_BREAK_LINE_TYPE_CODE) THEN

	   		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute(j.creation_date,
									j.created_by,
									j.last_update_date,
									j.last_updated_by,
									j.last_update_login,
									j.program_application_id,
									j.program_id,
									j.program_update_date,
									j.request_id,
									v_list_line_id,
									'N',
									'N',
									'ITEM',
									'PRICING_ATTRIBUTE3',
									'ALL',
									NULL, --Product UOM Code
									v_price_context,-- Pricing Context
									v_price_attribute,--Pricing Attribute
									NULL , --Pricing attr value from
									NULL, --Pricing_attr_value_to
									v_operator_code,
									'N', -- pricing datatype
									'C', -- product_datatype
									v_old_discount_id,
									v_old_discount_line_id,
									'DISCOUNTS',
									x_pricing_attribute_id);

		   --END IF;

     		-- Insert a record into the mapping table
	    		Create_Discount_Mapping_Record(i.discount_id,j.discount_line_id,
			v_list_header_id,v_list_line_id,b.descriptive_flex_context_code,v_mapping_line_type,
			null,null,null,null,null,null);
		 END LOOP; -- get_contexts_for_pattrs_cur
		END IF;

		-- This code needs to be executed for products , qualifiers and pricing attributes
		IF (j.entity_id IS NOT NULL) THEN

			-- Determine the product/pricing contexts and attributes/qualifier context and attributes
			Get_Context_Attributes(j.entity_id,v_product_context,v_product_attribute,
							  v_product_flag,v_pricing_flag,v_qualifier_flag);

		  IF (v_product_flag = TRUE) THEN

    BEGIN

	SELECT a.COLUMN_SEQ_NUM, nvl(c.FORMAT_TYPE,'C')
        INTO   x_qualifier_precedence, x_product_datatype
        --INTO   l_precedence, x_product_datatype   				--modified by dhgupta for 2992566
	FROM   FND_DESCR_FLEX_COLUMN_USAGES a , fnd_flex_value_sets c
	WHERE  a.DESCRIPTIVE_FLEXFIELD_NAME = 'QP_ATTR_DEFNS_PRICING'
        AND    a.APPLICATION_ID = 661 --(QP). Added for bug 5030757
	AND    a.DESCRIPTIVE_FLEX_CONTEXT_CODE = v_product_context
	AND    a.APPLICATION_COLUMN_NAME = v_product_attribute
        AND    a.FLEX_VALUE_SET_ID = c.FLEX_VALUE_SET_ID(+);

                 /* flex

		   BEGIN
	   		QP_UTIL.Get_Prod_Flex_Properties(v_product_context,
							 v_product_attribute,
							 j.entity_value,
							 x_product_datatype,
							 x_product_precedence,
							 x_error_code);
 	  		IF (x_error_code <> 0 ) THEN
    				QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'PROD_FLEX_PROPERTIES',
							p_error_desc =>
							 'Please Check The  Context: ' || v_product_context ||
							   ' Attribute: ' || v_product_attribute,
							p_error_module => 'QP_Util.Get_Prod_Flex_Properties');
	  		END IF;
			l_precedence := x_product_precedence;
		   EXCEPTION
	   	    WHEN OTHERS THEN
    		     err_msg := SQLERRM;
    		     rollback;
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'PROD_FLEX_PROPERTIES',
							p_error_desc => 'Product Entity ' || err_msg,
							p_error_module => 'QP_Util.Get_Prod_Flex_Properties');
    		     raise;
		   END;

                flex */

		   EXCEPTION
	   	    WHEN OTHERS THEN
    		     err_msg := SQLERRM;
    		     rollback;
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'PROD_FLEX_PROPERTIES',
							p_error_desc => 'Product Entity ' || err_msg,
							p_error_module => 'Prod_Flex_Properties');
    		     raise;
		   END;

		 ELSIF (v_qualifier_flag = TRUE) THEN

        BEGIN

	SELECT a.COLUMN_SEQ_NUM, nvl(c.FORMAT_TYPE,'C')
        INTO   x_qualifier_precedence, x_qualifier_datatype
	FROM   FND_DESCR_FLEX_COLUMN_USAGES a , fnd_flex_value_sets c
	WHERE  a.DESCRIPTIVE_FLEXFIELD_NAME = 'QP_ATTR_DEFNS_QUALIFIER'
        AND    a.APPLICATION_ID = 661 --(QP). Added for bug 5030757
	AND    a.DESCRIPTIVE_FLEX_CONTEXT_CODE = v_product_context
	AND    a.APPLICATION_COLUMN_NAME = v_product_attribute
        AND    a.FLEX_VALUE_SET_ID = c.FLEX_VALUE_SET_ID(+);

           /* flex

		  BEGIN
	   		QP_UTIL.Get_Qual_Flex_Properties(v_product_context,
							 v_product_attribute,
							 j.entity_value,
							 x_qualifier_datatype,
							 x_qualifier_precedence,
							 x_error_code);
			l_precedence := x_qualifier_precedence;
		  EXCEPTION
	   	    WHEN OTHERS THEN
    		     err_msg := SQLERRM;
    		     rollback;
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => 'Qualifier Entity ' || err_msg,
							p_error_module => 'QP_Util.Get_Qual_Flex_Properties');
    		     raise;
		  END;

          flex */
		  EXCEPTION
	   	    WHEN OTHERS THEN
    		     err_msg := SQLERRM;
    		     rollback;
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'QUAL_FLEX_PROPERTIES',
							p_error_desc => 'Qualifier Entity ' || err_msg,
							p_error_module => 'Qual_Flex_Properties');
    		     raise;
		  END;


		 END IF;

	       -- Set the lines flag to TRUE indicating that there are discount lines
		  v_lines_flag := TRUE;

	       -- Entities other than that we are handling
		  IF (v_product_flag = FALSE AND v_qualifier_flag = FALSE AND v_pricing_flag = FALSE) THEN
    			-- Insert a record into the mapping table
    			Create_Discount_Mapping_Record(i.discount_id,NULL,v_list_header_id,NULL,null,'L',
						 null,null,null,null,null,null);

	          -- Added after discounts upgrade review by Jay,Alison and Ravi
    		     QP_Util.Log_Error(p_id1 => j.entity_id,
							p_error_type => 'ENTITY_NOT_HANDLED',
							p_error_desc => 'This entity is not handled by the Upgrade:' || j.entity_id,
							p_error_module => 'Create_Discounts');
	       END IF;
		END IF;

		--  If percent or  amount or price is not null then it is a regular discount line
		--  If percent and amount and price is null , then it is a price break.
		--  Execute this logic only if it is a product or qualifier. This is because we are not dealing
		--  with any entities other than those handled in Get_Context_Attributes procedure

		--  Determine the Arthimetic Operator and Operand in qp_list_lines from Percent and Amount
	     Get_Percent(j.percent , j.amount , j.price , x_operand , x_arithmetic_operator);

		IF (j.entity_id IS NOT NULL AND (v_product_flag = TRUE OR v_qualifier_flag = TRUE OR v_pricing_flag = TRUE))
		THEN
		   IF (j.percent IS NOT NULL OR j.amount IS NOT NULL OR j.price IS NOT NULL) THEN
    			IF (x_arithmetic_operator = 'AMT') THEN
		 	 IF (x_operand < 0) THEN
	 			v_line_type_code := G_SURCHARGE_CODE;
	 			x_operand := -(x_operand);
			 ELSE
	 			v_line_type_code := G_LIST_LINE_TYPE_CODE;
			 END IF;
    			ELSE
				v_line_type_code := G_LIST_LINE_TYPE_CODE;
    			END IF;
			v_price_context := NULL;
			v_price_attribute := NULL;
			v_price_datatype := NULL;
			v_operator_code := NULL;
			v_price_break_type_code := NULL;
			v_mapping_line_type := 'L'; -- Regular discount line
	        ELSE
			v_line_type_code := G_PRICE_BREAK_LINE_TYPE_CODE;
			v_price_context := 'VOLUME';
			v_price_attribute := 'PRICING_ATTRIBUTE10';
			v_operator_code := 'BETWEEN';
			v_price_datatype := 'N';
			v_price_break_type_code := 'POINT';
			v_mapping_line_type := 'Q'; -- Indicates that this line has price breaks
	  	   END IF;

		-- Find the uom for 'AMT' and 'NEWPRICE' , for PERCENT it is null
		IF(x_arithmetic_operator in ('AMT','NEWPRICE') and v_product_flag = TRUE) THEN
		   OPEN get_uom_for_item_cur(i.price_list_id,j.entity_value);
		   FETCH get_uom_for_item_cur INTO v_item_uom;
		   CLOSE get_uom_for_item_cur;
		END IF;

		-- Create the list line if product or qualifier, because pricing is already taken care of
		-- in get_contexts_for_pattrs_cur

         -- v_product_flag = TRUE
	    -- For entity ids related to Products
	    -- If Qualifier Exists then v_qualification_ind = 1, atleast there is 1 qualifier(Price list)
         -- For PBH parent line it is 1 , and not null because it is not there in the
	    -- from_rltd_modifier_id of the qp_rltd_modifiers table

         IF (v_product_flag = TRUE) THEN
	     v_qualification_ind := 1;
         END IF;

         /*IF (v_product_flag = TRUE) THEN
		IF (v_hqual_exists) THEN
		  v_qualification_ind := 1;
          ELSE
		  v_qualification_ind := 3;
		END IF;
         END IF;*/

          -- v_qualifier_flag = TRUE
		-- For entity id's relating to qualifiers(line level)

          IF (v_qualifier_flag = TRUE) THEN
		 IF (v_line_type_code = G_PRICE_BREAK_LINE_TYPE_CODE) THEN
		  v_qualification_ind := 1;
		 ELSE
		  v_qualification_ind := 5;
           END IF;
		END IF;

		/*-- If PBH , then qualification_ind is null because it will have everything
		IF (v_line_type_code = G_PRICE_BREAK_LINE_TYPE_CODE) THEN
		 v_qualification_ind := null;
		END IF;*/

		IF (v_product_flag = TRUE OR v_qualifier_flag = TRUE) THEN
    		 QP_Modifier_Upgrade_Util_PVT.Create_List_Line(j.creation_date,
											j.created_by,
											j.last_update_date,
											j.last_updated_by,
											j.last_update_login,
											j.program_application_id,
											j.program_id,
											j.program_update_date,
											j.request_id,
											v_list_header_id,
											v_line_type_code,
						        				j.start_date_active,
											j.end_date_active,
											i.automatic_discount_flag,
											v_discount_level,
											x_arithmetic_operator,
											x_operand,
											v_pricing_phase_id,
											v_incomp_grp_code,
											v_pricing_group_sequence, -- pricing_group_seq
											'N', -- accrual_flag
--											l_precedence,
											x_qualifier_precedence,
											i.PRORATE_FLAG,
											'N', -- print on invoice flag
										     nvl(i.override_allowed_flag,'N'), -- override flag
											v_price_break_type_code,
											j.context,
											j.attribute1,
											j.attribute2,
											j.attribute3,
											j.attribute4,
											j.attribute5,
											j.attribute6,
											j.attribute7,
											j.attribute8,
											j.attribute9,
											j.attribute10,
											j.attribute11,
											j.attribute12,
											j.attribute13,
											j.attribute14,
											j.attribute15,
											v_qualification_ind,
											v_new_line_flag,
											v_line_seq_num,
											v_old_discount_id,
											v_old_discount_line_id,
											'DISCOUNTS',
											x_list_line_id);

				-- Store the List Line Id
				v_list_line_id := x_list_line_id;
				v_line_seq_num := x_list_line_id;
				v_new_line_flag := FALSE;

     	  		-- Insert a record into the mapping table
	       	     Create_Discount_Mapping_Record(i.discount_id,j.discount_line_id,
				v_list_header_id,v_list_line_id,null,v_mapping_line_type, null,null,null,null,null,null);

		END IF; -- v_product_flag = TRUE or v_qualfier_flag = TRUE

		--  Create Product/Pricing Attributes

		-- If v_product_flag is TRUE it is a product attribute ex: Item , Item Category

	 	 IF (v_product_flag = TRUE) THEN

			-- Create the Product/Pricing Attribute
	   		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute(j.creation_date,
									j.created_by,
									j.last_update_date,
									j.last_updated_by,
									j.last_update_login,
									j.program_application_id,
									j.program_id,
									j.program_update_date,
									j.request_id,
									v_list_line_id,
									'N',
									'N',
									v_product_context,
									v_product_attribute,
									j.entity_value,
									v_item_uom, --Product UOM Code
									v_price_context	,
									v_price_attribute,
									NULL,--Pricing attr value from
									NULL, --Pricing_attr_value_to
									v_operator_code,
									v_price_datatype, -- pricing datatype
									nvl(x_product_datatype,'C'),
									v_old_discount_id,
									v_old_discount_line_id,
									'DISCOUNTS',
									x_pricing_attribute_id);
			v_item_uom := NULL; -- Re-init
	      END IF; -- v_product_flag = TRUE

		 -- If v_qualifier_flag= TRUE then create a Qualifier
		 -- Ex: Order Type , Customer PO , Agreement Type , Agreement Name
		 -- v_qualifier_flag = TRUE indicates that it is a Qualifier with one pricing attribute Units or
		 -- Dollars.
		 -- In this case , if it is a discount line , there will not be any pricing attributes for this
		 -- Qualifier. Ex: Give 2% discount where Order Type = 'Standard'. In this case Order Type will
		 -- be a Qualifier and there will be a discount line 2% in qp_list_lines.

		 IF (v_qualifier_flag = TRUE) THEN


		   -- Create the Qualifier
	        QP_Modifier_Upgrade_Util_PVT.Create_Qualifier(i.creation_date,
							i.created_by,
							i.last_update_date,
							i.last_updated_by,
							i.last_update_login,
							i.program_application_id,
							i.program_id,
							i.program_update_date,
							i.request_id,
							'N',
							G_COMPARATOR_CODE,
							v_product_context,
							v_product_attribute,
							j.entity_value,
							v_cust_qualifier_grp_no, --Initially 0 , so create new grp no
							v_list_header_id,
							v_list_line_id,
							x_qualifier_precedence,
							nvl(x_qualifier_datatype,'C'),
							null,-- start_date_active
							null,-- end_date_active
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							null,
							v_old_discount_id,
							'DISCOUNTS',
							x_qualifier_grouping_no);
		 END IF; -- v_qualifier_flag = TRUE

		-- Price Breaks for the Discount Line

		IF (j.amount IS NULL AND j.percent IS NULL AND j.price IS NULL) THEN

	 	 FOR k IN get_price_break_lines(j.discount_line_id)
		 LOOP

			--  Determine the Arthimetic Operator and Operand in qp_list_lines from Percent and Amount
			Get_Percent(k.percent,k.amount,k.price,x_operand , x_arithmetic_operator);

    			IF (x_arithmetic_operator = 'AMT') THEN
			 IF (x_operand < 0) THEN
	 		  v_line_type_code := G_SURCHARGE_CODE;
	 		  x_operand := -(x_operand);
			 ELSE
	 		  v_line_type_code := G_LIST_LINE_TYPE_CODE;
			 END IF;
    		     ELSE
	   		 v_line_type_code := G_LIST_LINE_TYPE_CODE;
    			END IF;

			-- Determine the pricing context and attribute
		   IF (UPPER(k.method_type_code) = G_PRICING_ATTRIBUTE_UNITS) THEN

			 -- Get the context and attribute for Units
			 QP_UTIL_Get_Context_Attribute(G_PRICING_ATTRIBUTE_UNITS,v_price_break_context,v_price_break_attribute);

		   ELSIF (UPPER(k.method_type_code) = G_PRICING_ATTRIBUTE_DOLLARS) THEN

			 -- Get the context and attribute for Dollars
			 QP_UTIL_Get_Context_Attribute(G_PRICING_ATTRIBUTE_DOLLARS,v_price_break_context,v_price_break_attribute);
		   END IF;

	          -- PBH Children
			v_qualification_ind := 2;

			-- Create a list line for each price break line
               QP_Modifier_Upgrade_Util_PVT.Create_List_Line(k.creation_date,
							k.created_by,
							k.last_update_date,
	 						k.last_updated_by,
							k.last_update_login,
							k.program_application_id,
							k.program_id,
							k.program_update_date,
							k.request_id,
							v_list_header_id,
							v_line_type_code,
	 						k.start_date_active,
							k.end_date_active,
							i.automatic_discount_flag,
							v_discount_level,
							x_arithmetic_operator,
							x_operand,
							v_pricing_phase_id,
							v_incomp_grp_code,
							v_pricing_group_sequence, -- pricing_group_seq
							'N', -- accrual_flag
--							l_precedence,
							x_qualifier_precedence,
							i.PRORATE_FLAG,
							'N', -- print on invoice flag
							nvl(i.override_allowed_flag,'N'), -- override flag
							'POINT',
							k.context,
							k.attribute1,
							k.attribute2,
							k.attribute3,
							k.attribute4,
							k.attribute5,
							k.attribute6,
							k.attribute7,
							k.attribute8,
							k.attribute9,
							k.attribute10,
							k.attribute11,
							k.attribute12,
							k.attribute13,
							k.attribute14,
							k.attribute15,
							v_qualification_ind,
							v_new_line_flag,
							v_line_seq_num,
							v_old_discount_id,
							v_old_discount_line_id,
							'DISCOUNTS',
							x_list_line_id);

			-- Store the List Line Id
			v_price_break_line_id := x_list_line_id;
			v_line_seq_num := x_list_line_id;
			v_new_line_flag := FALSE;

               -- Insert a record into related modifier table
			QP_Modifier_Upgrade_Util_PVT.Create_Related_Modifier(k.creation_date,
									k.created_by,
									k.last_update_date,
									k.last_updated_by,
									k.last_update_login,
									v_list_line_id,
									v_price_break_line_id,
									'PRICE BREAK',
							  		v_old_discount_id,
									v_old_discount_line_id,
							  		'DISCOUNTS',
									x_rltd_modifier_id);


		-- If is a product then there will be only 1 record in qp_pricing_attributes with both
		-- Product and Pricing info in 1 record

		   IF (v_product_flag = TRUE ) THEN

			-- Create the Product/Pricing Attribute

	  		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute_Break(k.creation_date,
										k.created_by,
										k.last_update_date,
										k.last_updated_by,
										k.last_update_login,
										k.program_application_id,
										k.program_id,
										k.program_update_date,
										k.request_id,
										v_price_break_line_id,
										'N',
										'N',
										v_product_context,
										v_product_attribute,
										j.entity_value,
										k.unit_code, /* Product UOM Code */
										v_price_break_context,
										v_price_break_attribute,
										k.price_break_lines_low_range,
										k.price_break_lines_high_range,
										'BETWEEN',
										'N', -- pricing_datatype
										'C', -- product datatype
							  			v_old_discount_id,
									     v_old_discount_line_id,
							  			'DISCOUNTS',
										x_pricing_attribute_id);
		   END IF; /* v_product_flag = TRUE */

		   -- This record is needed , if this is a break on qualifier
		   -- This record the product record in qp_pricing_attributes for PBH Line(Parent Line)
		   -- Insert only 1 record
		   IF (v_qualifier_flag = TRUE and v_break_count = 0 ) THEN
			-- Create the Product/Pricing Attribute
	   		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute(j.creation_date,
									j.created_by,
									j.last_update_date,
									j.last_updated_by,
									j.last_update_login,
									j.program_application_id,
									j.program_id,
									j.program_update_date,
									j.request_id,
									v_list_line_id,
									'N',
									'N',
									'ITEM',
									'PRICING_ATTRIBUTE3',
									'ALL',
									NULL, --Product UOM Code
								     v_price_break_context,
									v_price_break_attribute,
									NULL,--Pricing attr value from
									NULL, --Pricing_attr_value_to
									'BETWEEN',
									'N', -- pricing datatype
									'C',
									v_old_discount_id,
									v_old_discount_line_id,
									'DISCOUNTS',
									x_pricing_attribute_id);
		   END IF;

		   IF (v_qualifier_flag = TRUE OR v_pricing_flag = TRUE) THEN


			-- Create the Pricing Attribute
	  		QP_Modifier_Upgrade_Util_PVT.Create_Pricing_Attribute_Break(k.creation_date,
										k.created_by,
										k.last_update_date,
										k.last_updated_by,
										k.last_update_login,
										k.program_application_id,
										k.program_id,
										k.program_update_date,
										k.request_id,
										v_price_break_line_id,
										'N',
										'N',
										'ITEM',
										'PRICING_ATTRIBUTE3',
										'ALL',
										k.unit_code, /* Product UOM Code */
										v_price_break_context,
										v_price_break_attribute,
										k.price_break_lines_low_range,
										k.price_break_lines_high_range,
										'BETWEEN',
										'N', -- pricing datatype
										'C', -- product datatype
							  			v_old_discount_id,
										v_old_discount_line_id,
							  			'DISCOUNTS',
										x_pricing_attribute_id);
		     END IF; /* v_qualifier_flag = TRUE OR v_pricing_flag = TRUE */


			-- Insert a record into the mapping table
			-- Type = 'B' is the actual price break line

			Create_Discount_Mapping_Record(i.discount_id,j.discount_line_id,v_list_header_id,
				v_price_break_line_id,null,'B',k.price_break_lines_low_range,
				k.price_break_lines_high_range,k.method_type_code,
				k.percent,k.amount , k.price);


			-- Store the attribute id's
			v_pricing_attribute_id := x_pricing_attribute_id;
			v_break_count := v_break_count + 1;
			v_unit_code := k.unit_code;
		  END LOOP; -- Price Break Lines Cursor

		   -- Update the Unit Code on the PBH line(parent Line)
		   -- makes PRICING_ATTRIBUTE10 to PRICING_ATTRIBUTE12(if needed)
		   UPDATE QP_PRICING_ATTRIBUTES
		   SET PRODUCT_UOM_CODE = v_unit_code,
		       PRICING_ATTRIBUTE = v_price_break_attribute
		   WHERE LIST_LINE_ID = v_list_line_id;
		   v_break_count := 0; -- Re-init
	      END IF; -- if (j.percent IS NULL AND j.amount is NULL AND j.price is  NULL
      END IF; -- j.entity_id IS NOT NULL AND v_product_flag = TRUE or v_qualifier_flag = TRUE

	 -- Added after discounts upgrade review by Jay,Alison and Ravi
	 IF (v_contexts_flag = FALSE and v_entity_id IS NOT NULL) THEN
  		QP_Util.Log_Error(p_id1 => j.discount_line_id,
					   p_error_type => 'NO_PRICING_CONTEXTS_EXIST',
					   p_error_desc => 'There are no contexts for the entity id : ' || v_entity_id ||
								    ' of discount id: ' || i.discount_id || ' and discount line id: '||
								    j.discount_line_id,
					   p_error_module => 'Create_Discounts');
	 END IF;

    END LOOP; -- Discount Lines Cursor

	-- If there are no discount lines insert record into mapping table
	IF (v_lines_flag = FALSE ) THEN
    		-- Insert a record into the mapping table
    		Create_Discount_Mapping_Record(i.discount_id,NULL,v_list_header_id,NULL,null,'O',
						null,null,null,null,null,null);

	 -- Added after discounts upgrade review by Jay,Alison and Ravi
  		QP_Util.Log_Error(p_id1 => i.discount_id,
					   p_error_type => 'NO_DISCOUNT_LINES',
					   p_error_desc => 'There are no discount lines for this discount id:' || i.discount_id,
					   p_error_module => 'Create_Discounts');
	END IF;


   END IF; /* are_there_discount_lines = 'N' */
	-- Reinit the qualifier grouping no
	v_qualifier_grouping_no := 0;
     commit;
  END LOOP; /* Discounts cursor */

   -- Discounts Not Migrated
   FOR i in get_discounts_not_migrated_cur
   LOOP
    QP_Util.Log_Error(p_id1 => i.discount_id,
							p_id2 => i.price_list_id,
							p_error_type => 'DISCOUNTS_NOT_MIGRATED',
							p_error_desc =>
							'Discount Id ' || i.discount_id || ' is not migrated as there is problem with
										   Price List Id ' || i.price_list_id,
							p_error_module => 'Create_Discounts');
   END LOOP;


  EXCEPTION
   WHEN OTHERS THEN
    err_msg := SQLERRM;
    rollback;
    QP_Util.Log_Error(p_id1 => v_old_discount_id,
							p_id2 => v_old_discount_line_id,
							p_error_type => 'DISCOUNTS',
							p_error_desc => err_msg,
							p_error_module => 'Create_Discounts');

   -- Discounts Not Migrated
   FOR i in get_discounts_not_migrated_cur
   LOOP
    QP_Util.Log_Error(p_id1 => i.discount_id,
							p_id2 => i.price_list_id,
							p_error_type => 'DISCOUNTS_NOT_MIGRATED',
							p_error_desc =>
							'Discount Id ' || i.discount_id || ' is not migrated as there is problem with
										   Price List Id ' || i.price_list_id,
							p_error_module => 'Create_Discounts');
   END LOOP;

   -- commented the following raise statement for bug 2491781 as the calling program does not have
   -- any exception handling block to handle this raise statement.
   --raise;

  END  Create_Discounts;

END QP_Modifier_Upgrade_PVT;

/
