--------------------------------------------------------
--  DDL for Package Body QP_PRICE_FORMULA_UPG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_FORMULA_UPG_UTIL_PVT" AS
/* $Header: QPXVUPFB.pls 120.2 2006/03/21 11:15:55 rnayani noship $ */

/***********************************************************************
 Type Definition for a table of varchar2 to hold multiple contexts
************************************************************************/
TYPE contexts_tbl IS TABLE OF VARCHAR2(30)
   INDEX BY BINARY_INTEGER;

err_msg   VARCHAR2(240);
G_Context VARCHAR2(40);

/***********************************************************************
 Procedure to Insert a row into the Formula Header tables.
************************************************************************/

PROCEDURE Insert_Price_Formula(
 p_price_formula_id      NUMBER,
 p_creation_date 		DATE,
 p_created_by    		NUMBER,
 p_last_update_date     	DATE,
 p_last_updated_by      	NUMBER,
 p_last_update_login 	NUMBER,
 p_context               VARCHAR2,
 p_attribute1            VARCHAR2,
 p_attribute2            VARCHAR2,
 p_attribute3            VARCHAR2,
 p_attribute4            VARCHAR2,
 p_attribute5            VARCHAR2,
 p_attribute6            VARCHAR2,
 p_attribute7            VARCHAR2,
 p_attribute8            VARCHAR2,
 p_attribute9            VARCHAR2,
 p_attribute10           VARCHAR2,
 p_attribute11           VARCHAR2,
 p_attribute12           VARCHAR2,
 p_attribute13           VARCHAR2,
 p_attribute14           VARCHAR2,
 p_attribute15           VARCHAR2,
 p_formula               VARCHAR2,
 p_start_date_active     DATE,
 p_end_date_active       DATE,
 p_name                  VARCHAR2,
 p_description           VARCHAR2
)
IS

BEGIN

  INSERT INTO qp_price_formulas_b
  ( price_formula_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    context,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    formula,
    start_date_active,
    end_date_active
  )
  VALUES
  ( p_price_formula_id,
    nvl(p_creation_date, sysdate),
    nvl(p_created_by, -1),
    nvl(p_last_update_date, sysdate),
    nvl(p_last_updated_by, -1),
    nvl(p_last_update_login,-1),
    p_context,
    p_attribute1,
    p_attribute2,
    p_attribute3,
    p_attribute4,
    p_attribute5,
    p_attribute6,
    p_attribute7,
    p_attribute8,
    p_attribute9,
    p_attribute10,
    p_attribute11,
    p_attribute12,
    p_attribute13,
    p_attribute14,
    p_attribute15,
    p_formula,
    p_start_date_active,
    p_end_date_active
  );

  INSERT INTO qp_price_formulas_tl
  ( price_formula_id,
    language,
    source_lang,
    name,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  SELECT
    p_price_formula_id,
    l.LANGUAGE_CODE,
    userenv('LANG'),
    p_name,
    p_description,
    nvl(p_creation_date, sysdate),
    nvl(p_created_by, -1),
    nvl(p_last_update_date, sysdate),
    nvl(p_last_updated_by, -1),
    nvl(p_last_update_login,-1)
  FROM  FND_LANGUAGES l
  WHERE l.INSTALLED_FLAG in ('I', 'B')
  AND NOT EXISTS (SELECT NULL
	             FROM   qp_price_formulas_tl t
		        WHERE  t.price_formula_id = p_price_formula_id
	 	        AND    t.language = l.LANGUAGE_CODE);

EXCEPTION

  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'Price Formula Id' || to_char(p_price_formula_id),
	p_id2 => 'Formula Name' || p_name,
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Insert_Price_Formula');
    raise;

END Insert_Price_Formula;



/***********************************************************************
 Procedure to Insert a row into the Formula Lines table.
************************************************************************/

PROCEDURE Insert_Price_Formula_Line(
 p_price_formula_line_id         NUMBER,
 p_creation_date                 DATE,
 p_created_by                    NUMBER,
 p_last_update_date              DATE,
 p_last_updated_by               NUMBER,
 p_last_update_login             NUMBER,
 p_price_formula_id              NUMBER,
 p_price_formula_line_type_code  VARCHAR2,
 p_price_list_line_id            NUMBER,
 p_price_modifier_list_id        NUMBER,
 p_pricing_attribute_context     VARCHAR2,
 p_pricing_attribute             VARCHAR2,
 p_context                       VARCHAR2,
 p_attribute1                    VARCHAR2,
 p_attribute2                    VARCHAR2,
 p_attribute3                    VARCHAR2,
 p_attribute4                    VARCHAR2,
 p_attribute5                    VARCHAR2,
 p_attribute6                    VARCHAR2,
 p_attribute7                    VARCHAR2,
 p_attribute8                    VARCHAR2,
 p_attribute9                    VARCHAR2,
 p_attribute10                   VARCHAR2,
 p_attribute11                   VARCHAR2,
 p_attribute12                   VARCHAR2,
 p_attribute13                   VARCHAR2,
 p_attribute14                   VARCHAR2,
 p_attribute15                   VARCHAR2,
 p_start_date_active             DATE,
 p_end_date_active               DATE,
 p_step_number                   NUMBER,
 p_numeric_constant              NUMBER
)
IS

BEGIN

  INSERT  INTO qp_price_formula_lines
  (        price_formula_line_id
   ,       creation_date
   ,       created_by
   ,       last_update_date
   ,       last_updated_by
   ,       last_update_login
   ,       price_formula_id
   ,       price_formula_line_type_code
   ,       price_list_line_id
   ,       price_modifier_list_id
   ,       pricing_attribute_context
   ,       pricing_attribute
   ,       context
   ,       attribute1
   ,       attribute2
   ,       attribute3
   ,       attribute4
   ,       attribute5
   ,       attribute6
   ,       attribute7
   ,       attribute8
   ,       attribute9
   ,       attribute10
   ,       attribute11
   ,       attribute12
   ,       attribute13
   ,       attribute14
   ,       attribute15
   ,       start_date_active
   ,       end_date_active
   ,       step_number
   ,       numeric_constant
   )
   VALUES
   (       p_price_formula_line_id
   ,       p_creation_date
   ,       p_created_by
   ,       p_last_update_date
   ,       p_last_updated_by
   ,       p_last_update_login
   ,       p_price_formula_id
   ,       p_price_formula_line_type_code
   ,       p_price_list_line_id
   ,       p_price_modifier_list_id
   ,       p_pricing_attribute_context
   ,       p_pricing_attribute
   ,       p_context
   ,       p_attribute1
   ,       p_attribute2
   ,       p_attribute3
   ,       p_attribute4
   ,       p_attribute5
   ,       p_attribute6
   ,       p_attribute7
   ,       p_attribute8
   ,       p_attribute9
   ,       p_attribute10
   ,       p_attribute11
   ,       p_attribute12
   ,       p_attribute13
   ,       p_attribute14
   ,       p_attribute15
   ,       p_start_date_active
   ,       p_end_date_active
   ,       p_step_number
   ,       p_numeric_constant
   );

EXCEPTION

  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'Price Formula Id' || to_char(p_price_formula_id),
	p_id2 => 'Price Formula Line Id' || to_char(p_price_formula_line_id),
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Insert_Price_Formula_Line');
    raise;

END Insert_Price_Formula_Line;


/***********************************************************************
 Procedure to Insert a row into the List Header tables.
************************************************************************/

PROCEDURE Insert_List_Header(
 p_list_header_id       NUMBER,
 p_creation_date        DATE,
 p_created_by           NUMBER,
 p_last_update_date     DATE,
 p_last_updated_by      NUMBER,
 p_last_update_login    NUMBER,
 p_list_type_code       VARCHAR2,
 p_automatic_flag       VARCHAR2,
 p_currency_code        VARCHAR2,
 p_context              VARCHAR2,
 p_attribute1           VARCHAR2,
 p_attribute2           VARCHAR2,
 p_attribute3           VARCHAR2,
 p_attribute4           VARCHAR2,
 p_attribute5           VARCHAR2,
 p_attribute6           VARCHAR2,
 p_attribute7           VARCHAR2,
 p_attribute8           VARCHAR2,
 p_attribute9           VARCHAR2,
 p_attribute10          VARCHAR2,
 p_attribute11          VARCHAR2,
 p_attribute12          VARCHAR2,
 p_attribute13          VARCHAR2,
 p_attribute14          VARCHAR2,
 p_attribute15          VARCHAR2,
 p_source_system_code   VARCHAR2,
 p_active_flag          VARCHAR2,
 p_ask_for_flag         VARCHAR2,
 p_name                 VARCHAR2,
 p_description          VARCHAR2,
 p_version_no           VARCHAR2
)
IS
BEGIN

      INSERT INTO qp_list_headers_b (
        list_header_id,
	   creation_date,
	   created_by,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   list_type_code,
        automatic_flag,
	   currency_code,
	   source_system_code,
	   active_flag,
	   ask_for_flag,
	   context, attribute1, attribute2, attribute3, attribute4,
	   attribute5, attribute6, attribute7, attribute8, attribute9,
	   attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
           --ENH Upgrade BOAPI for orig_sys...ref RAVI
           ,ORIG_SYSTEM_HEADER_REF
	   )
	 VALUES(
	   p_list_header_id,
	   p_creation_date,
	   p_created_by,
	   p_last_update_date,
	   p_last_updated_by,
	   p_last_update_login,
	   p_list_type_code,
	   p_automatic_flag,
	   p_currency_code,
	   p_source_system_code,
	   p_active_flag,
	   p_ask_for_flag,
	   p_context, p_attribute1, p_attribute2, p_attribute3, p_attribute4,
	   p_attribute5, p_attribute6, p_attribute7, p_attribute8, p_attribute9,
	   p_attribute10, p_attribute11, p_attribute12, p_attribute13, p_attribute14,
	   p_attribute15
           --ENH Upgrade BOAPI for orig_sys...ref RAVI
           ,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(p_list_header_id)
	  );

     INSERT INTO qp_list_headers_tl (
 	   list_header_id,
	   language,
	   source_lang,
	   name,
	   description,
 	   creation_date,
	   created_by,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   version_no
	  )
	SELECT
		p_list_header_id,
		l.LANGUAGE_CODE,
		userenv('LANG'),
		p_name,
		p_description,
		p_creation_date,
		p_created_by,
		p_last_update_date,
		p_last_updated_by,
		p_last_update_login,
		p_version_no
     FROM FND_LANGUAGES l
	WHERE l.INSTALLED_FLAG in ('I', 'B')
	AND NOT EXISTS (SELECT NULL
		           FROM   qp_list_headers_tl t
		           WHERE  t.list_header_id = p_list_header_id
		           AND    t.language = l.LANGUAGE_CODE);
EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'List Header Id' || to_char(p_list_header_id),
	p_id2 => 'Price Modifier List Name' || p_name,
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Insert_List_Header');
    raise;

END Insert_List_Header;


/***********************************************************************
 Procedure to Insert a row into the List Lines table.
************************************************************************/

PROCEDURE Insert_List_Line(
 p_list_line_id              NUMBER,
 p_creation_date             DATE,
 p_created_by                NUMBER,
 p_last_update_date          DATE,
 p_last_updated_by           NUMBER,
 p_last_update_login         NUMBER,
 p_list_header_id            NUMBER,
 p_list_line_type_code       VARCHAR2,
 p_automatic_flag            VARCHAR2,
 p_modifier_level_code       VARCHAR2,
 p_arithmetic_operator       VARCHAR2,
 p_operand                   NUMBER,
 p_pricing_phase_id          NUMBER,
 p_incompatibility_grp_code  VARCHAR2,
 p_pricing_group_sequence    NUMBER,
 p_accrual_flag              VARCHAR2,
 p_product_precedence        NUMBER,
 p_base_qty                  NUMBER,
 p_base_uom_code             VARCHAR2,
 p_recurring_flag            VARCHAR2,
 p_proration_type_code       VARCHAR2,
 p_print_on_invoice_flag     VARCHAR2,
 p_context                   VARCHAR2,
 p_attribute1                VARCHAR2,
 p_attribute2                VARCHAR2,
 p_attribute3                VARCHAR2,
 p_attribute4                VARCHAR2,
 p_attribute5                VARCHAR2,
 p_attribute6                VARCHAR2,
 p_attribute7                VARCHAR2,
 p_attribute8                VARCHAR2,
 p_attribute9                VARCHAR2,
 p_attribute10               VARCHAR2,
 p_attribute11               VARCHAR2,
 p_attribute12               VARCHAR2,
 p_attribute13               VARCHAR2,
 p_attribute14               VARCHAR2,
 p_attribute15               VARCHAR2
)
IS
BEGIN

     INSERT INTO qp_list_lines (
	 list_line_id,
	 list_line_no,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 list_header_id,
	 list_line_type_code,
	 automatic_flag,
	 modifier_level_code,
	 arithmetic_operator,
	 operand,
	 pricing_phase_id,
	 incompatibility_grp_code,
	 pricing_group_sequence,
	 accrual_flag,
	 product_precedence,
	 base_qty,
	 base_uom_code,
	 recurring_flag,
	 proration_type_code,
	 print_on_invoice_flag,
	 context, attribute1, attribute2, attribute3, attribute4, attribute5,
	 attribute6, attribute7, attribute8, attribute9, attribute10,
	 attribute11, attribute12, attribute13, attribute14, attribute15
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_HEADER_REF
	)
	VALUES (
	 p_list_line_id,
	 p_list_line_id,
	 p_creation_date,
	 p_created_by,
	 p_last_update_date,
	 p_last_updated_by,
	 p_last_update_login,
	 p_list_header_id,
	 p_list_line_type_code,
	 p_automatic_flag,
	 p_modifier_level_code,
	 p_arithmetic_operator,
	 p_operand,
	 p_pricing_phase_id,
	 p_incompatibility_grp_code,
	 p_pricing_group_sequence,
	 p_accrual_flag,
	 p_product_precedence,
	 p_base_qty,
	 p_base_uom_code,
	 p_recurring_flag,
	 p_proration_type_code,
	 p_print_on_invoice_flag,
	 p_context,
	 p_attribute1, p_attribute2, p_attribute3, p_attribute4, p_attribute5,
	 p_attribute6, p_attribute7, p_attribute8, p_attribute9, p_attribute10,
	 p_attribute11, p_attribute12, p_attribute13, p_attribute14, p_attribute15
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,to_char(p_list_line_id)
         ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_list_header_id)
	);

EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'List Header Id' || to_char(p_list_header_id),
	p_id2 => 'List Line Id' || to_char(p_list_line_id),
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Insert_List_List');
    raise;

END Insert_List_Line;


/***********************************************************************
 Procedure to Insert a row into the Pricing Attributes table.
************************************************************************/

PROCEDURE Insert_Pricing_Attribute(
 p_creation_date               DATE,
 p_created_by                  NUMBER,
 p_last_update_date            DATE,
 p_last_updated_by             NUMBER,
 p_last_update_login           NUMBER,
 p_list_line_id                NUMBER,
 p_excluder_flag               VARCHAR2,
 p_accumulate_flag             VARCHAR2,
 p_pricing_attribute_context   VARCHAR2,
 p_pricing_attribute           VARCHAR2,
 p_pricing_attr_value_from     VARCHAR2,
 p_pricing_attr_value_to       VARCHAR2,
 p_pricing_attribute_datatype  VARCHAR2,
 p_comparison_operator_code    VARCHAR2
)
IS
l_pricing_attribute_id    NUMBER;
l_attribute_grouping_no   NUMBER;

BEGIN

     SELECT QP_PRICING_ATTRIBUTES_S.nextval
  	INTO   l_pricing_attribute_id
	FROM   DUAL;

     SELECT QP_PRICING_ATTR_GROUP_NO_S.nextval
  	INTO   l_attribute_grouping_no
	FROM   DUAL;

	INSERT INTO qp_pricing_attributes(
	 pricing_attribute_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 list_line_id,
	 excluder_flag,
	 accumulate_flag,
	 pricing_attribute_context,
	 pricing_attribute,
	 pricing_attr_value_from,
	 pricing_attr_value_to,
	 attribute_grouping_no,
	 pricing_attribute_datatype,
	 comparison_operator_code
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
     )
	VALUES
	(
	 l_pricing_attribute_id,
	 p_creation_date,
	 p_created_by,
	 p_last_update_date,
	 p_last_updated_by,
	 p_last_update_login,
      p_list_line_id,
	 p_excluder_flag,
	 p_accumulate_flag,
      p_pricing_attribute_context,
	 p_pricing_attribute,
	 p_pricing_attr_value_from,
	 p_pricing_attr_value_to,
	 l_attribute_grouping_no,
	 p_pricing_attribute_datatype,
	 p_comparison_operator_code
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_pricing_attribute_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     ,(select l.ORIG_SYS_HEADER_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
	);

EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'List Line Id' || to_char(p_list_line_id),
	p_id2 => 'Pricing Attribute Id' || to_char(l_pricing_attribute_id),
	p_id3 => 'Pricing Attribute Value' || p_pricing_attr_value_from,
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Insert_Pricing_Attribute');
    raise;

END Insert_Pricing_Attribute;


/***********************************************************************
 Procedure to Upgrade unused Pricing Rule Components to Factors tables.
************************************************************************/

PROCEDURE Upgrade_Unused_Components
IS

l_exists          VARCHAR2(1);
l_list_header_id  NUMBER;
l_list_line_id    NUMBER;

CURSOR unused_components_cur
IS
  SELECT *
  FROM   so_rule_formula_components c
  WHERE  c.formula_component_id NOT IN
	    (SELECT b.formula_component_id
	     FROM   so_pricing_rule_lines b);

BEGIN

 FOR l_comp_rec IN unused_components_cur
 LOOP
   BEGIN -- block around all the code in the components loop
   l_exists := NULL;

   BEGIN
     SELECT 'Y'
     INTO   l_exists
     FROM   qp_list_headers_vl v
     WHERE  v.name = l_comp_rec.name;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     	  l_exists := NULL;
   END;

   IF l_exists IS NULL THEN  -- Price Modifier List Id does not already exist

         SELECT QP_LIST_HEADERS_B_S.nextval
	    INTO   l_list_header_id
	    FROM   DUAL;

         QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_List_Header(
                                        l_list_header_id,
                                        l_comp_rec.creation_date,
                                        l_comp_rec.created_by,
                                        l_comp_rec.last_update_date,
                                        l_comp_rec.last_updated_by,
                                        l_comp_rec.last_update_login,
                                        'PML', --list_type_code
                                        'N',   --automatic_flag
                                        null,  --currency_code
                                        l_comp_rec.context,
                                        l_comp_rec.attribute1,
                                        l_comp_rec.attribute2,
                                        l_comp_rec.attribute3,
                                        l_comp_rec.attribute4,
                                        l_comp_rec.attribute5,
                                        l_comp_rec.attribute6,
                                        l_comp_rec.attribute7,
                                        l_comp_rec.attribute8,
                                        l_comp_rec.attribute9,
                                        l_comp_rec.attribute10,
                                        l_comp_rec.attribute11,
                                        l_comp_rec.attribute12,
                                        l_comp_rec.attribute13,
                                        l_comp_rec.attribute14,
                                        l_comp_rec.attribute15,
                                        'QP',  --source_system_code
                                        'Y',   --active_flag
                                        'N',   --ask_for_flag
								l_comp_rec.name,
								l_comp_rec.description,
								'1'    --version_no
	                                  );


         SELECT QP_LIST_LINES_S.nextval
	    INTO   l_list_line_id
	    FROM   DUAL;

         QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_List_Line(
	                                   l_list_line_id,
	                                   l_comp_rec.creation_date,
	                                   l_comp_rec.created_by,
	                                   l_comp_rec.last_update_date,
	                                   l_comp_rec.last_updated_by,
	                                   l_comp_rec.last_update_login,
	                                   l_list_header_id,
	                                   'PMR', --list_line_type_code
	                                   'N',   --automatic_flag
	                                   'NONE',--modifier_level_code
	                                   null,  --arithmetic_operator
	                                   0,    --operand
	                                   null, --pricing_phase_id
	                                   null, --incompatibility_grp_code
	                                   1,    --pricing_group_sequence
	                                   'N',  --accrual_flag
	                                   null, --product_precedence
	                                   1,    --base_qty
	                                   null, --base_uom_code
	                                   'Y',  --recurring_flag
	                                   null, --proration_type_code,
	                                   'N',  --print_on_invoice_flag
	                                   null, --context and 15 attributes
						          null, null, null, null, null,
	                                   null, null, null, null, null,
	                                   null, null, null, null, null );

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
            nvl(l_comp_rec.creation_date,sysdate), nvl(l_comp_rec.created_by, -1),
		  nvl(l_comp_rec.last_update_date,sysdate), nvl(l_comp_rec.last_updated_by,-1),
            nvl(l_comp_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		  null, null, null, null, 'C', '=');

   END IF;
   EXCEPTION
	WHEN OTHERS THEN
	 err_msg := substr(sqlerrm, 1, 240);
      rollback;
      QP_UTIL.Log_Error (
	  p_id1 => 'Modifier List Id ' || to_char(l_list_header_id) ,
	  p_error_type => 'FORMULA',
	  p_error_desc => err_msg,
	  p_error_module => 'Upgrade_Unused_Components');
   END; -- Block around all the code in the components loop

   commit; -- for each successful component
 END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'Modifier List Id ' || to_char(l_list_header_id),
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Upgrade_Unused_Components');
    raise;

END Upgrade_Unused_Components;


/**********************************************************************
 Procedure to get database Attribute Value for a given Display Attribute
 Value.
************************************************************************/

FUNCTION Get_Attr_Value(p_context            IN  VARCHAR2,
					p_attribute          IN  VARCHAR2,
					p_attr_display_value IN  VARCHAR2)
RETURN VARCHAR2
IS
l_attr_value VARCHAR2(40);

BEGIN
  IF p_context   = 'ITEM' AND p_attribute = 'PRICING_ATTRIBUTE1' THEN
  -- If display value is an Item Number

    BEGIN
      SELECT TO_CHAR(inventory_item_id)
      INTO   l_attr_value
      FROM   mtl_system_items_vl
      WHERE  organization_id = FND_PROFILE.value('SO_ORGANIZATION_ID')
      AND    rtrim(ltrim(concatenated_segments)) =
			    rtrim(ltrim(p_attr_display_value));
    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
        l_attr_value := p_attr_display_value;
    END;

    RETURN l_attr_value;

  ELSIF p_context   = 'ITEM' AND p_attribute = 'PRICING_ATTRIBUTE2' THEN
  -- If display value is an Item Category

    BEGIN
      SELECT TO_CHAR(category_id)
      INTO   l_attr_value
      FROM   mtl_categories_kfv
      WHERE  rtrim(ltrim(concatenated_segments)) =
		         rtrim(ltrim(p_attr_display_value));


    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
        l_attr_value := p_attr_display_value;
    END;

    RETURN l_attr_value;

  ELSE
  --If Others

    l_attr_value := p_attr_display_value;

    RETURN l_attr_value;

  END IF; --If Item Number, Item Category or Other

EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => 'Attribute Display Value' || p_attr_display_value,
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Get_Attr_Value');
    raise;
END Get_Attr_Value;


/**************************************************************************
 Procedure to Get Context and Attribute given the entity id, and entity code
***************************************************************************/

PROCEDURE Get_Ctx_Attr(p_price_formula_id   IN   NUMBER,
				   p_entity_id          IN   NUMBER,
				   x_contexts           OUT NOCOPY /* file.sql.39 change */  CONTEXTS_TBL,
				   x_attribute          OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_ctx_var   VARCHAR2(40);
l_attribute VARCHAR2(40);
l_count     NUMBER := 0;

CURSOR context_cur(a_price_formula_id NUMBER)
IS
  SELECT DISTINCT nvl(pricing_context, 'Upgrade Context')
  FROM   so_price_list_lines_115
  WHERE  pricing_rule_id = a_price_formula_id;

CURSOR flex_context_cur(a_pricing_attribute VARCHAR2)
IS
  SELECT decode(descriptive_flex_context_code, 'Global Data Elements',
			 'Upgrade Context', descriptive_flex_context_code)
  FROM   fnd_descr_flex_column_usages
  WHERE  descriptive_flexfield_name = 'PRICING_ATTRIBUTES'
  AND    application_column_name = a_pricing_attribute;

BEGIN
  IF to_char(p_entity_id) IN ('1001','1045','1208','1020', '1021','1022',
				   '1023','1024','1025','1026','1027','1028',
				   '1029','1030','1031','1032','1033','1034',
				   '1035','1036','1037','1038','1039')
  THEN
     --For Item related entity-codes get the Context and Attribute using API
     QP_UTIL.Get_Context_Attribute( p_entity_id,
						      l_ctx_var,
							 l_attribute);
	--dbms_output.put_line('In get_ctx..');
	x_contexts(1) := l_ctx_var;
	x_attribute   := l_attribute;

  ELSE -- If entity id not in list above

	--dbms_output.put_line('In get_ctx..1');
    SELECT entity_code
    INTO   l_attribute
    FROM   so_entities
    WHERE  entity_id = p_entity_id;

    x_attribute := l_attribute;

    IF G_Context IS NOT NULL THEN
       x_contexts(1) := G_Context;

    ELSE

    --Context is not known, So get context from Price List Line to
    --which formula attached or if not found on any Price List Line
    --get any one Context and attribute from fnd descr flex table

      OPEN context_cur(p_price_formula_id);
      FETCH context_cur INTO l_ctx_var;

      IF context_cur%FOUND THEN
        l_count := l_count + 1;           -- Do this only for one context. Not
        x_contexts(l_count) := l_ctx_var; -- in a loop. Loop may be in future.
      END IF;

      CLOSE context_cur;

	--dbms_output.put_line('In get_ctx..2');
      IF l_count = 0 THEN
	    OPEN  flex_context_cur(l_attribute);
	    FETCH flex_context_cur
	    INTO  l_ctx_var;

	--dbms_output.put_line('In get_ctx..3');
         IF flex_context_cur%NOTFOUND THEN
	       raise NO_DATA_FOUND;
	    END IF;

         x_contexts(1) := l_ctx_var;

         CLOSE flex_context_cur;
      END IF; --If l_count = 0

    END IF; -- If G_Context is not null

  END IF; -- If entity_id not in list

EXCEPTION
  WHEN OTHERS THEN
	 err_msg := substr(sqlerrm, 1, 240);
      rollback;
      QP_UTIL.Log_Error (
	  p_id1 => 'Entity Id ' || to_char(p_entity_id),
	  p_error_type => 'FORMULA',
	  p_error_desc => err_msg,
	  p_error_module => 'Get_Ctx_Attr');
	 raise;

END Get_Ctx_Attr;


/**************************************************************************
 Procedure to Get Attribute given the entity id. This procedure is meant
 mainly for those Entity Ids whose Contexts are not Item.
***************************************************************************/

PROCEDURE Get_Attribute(p_entity_id          IN   NUMBER,
				    x_attribute          OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_attribute  VARCHAR2(40);

BEGIN

  SELECT entity_code
  INTO   l_attribute
  FROM   so_entities
  WHERE  entity_id = p_entity_id;

  x_attribute := l_attribute;
EXCEPTION
  WHEN OTHERS THEN
	 err_msg := substr(sqlerrm, 1, 240);
      rollback;
      QP_UTIL.Log_Error (
	  p_id1 => 'Entity Id ' || to_char(p_entity_id),
	  p_error_type => 'FORMULA',
	  p_error_desc => err_msg,
	  p_error_module => 'Get_Attribute');
	 raise;

END Get_Attribute;

/**************************************************************************
 Procedure to divide the pricing rules into partitions that will aid in
 parallel processing of the upgrade.
***************************************************************************/

--PROCEDURE  Create_Parallel_Slabs (l_workers   IN NUMBER := 5)  --2422176
PROCEDURE  Create_Parallel_Slabs (l_workers   IN NUMBER)
IS
l_min_line            NUMBER;
l_max_line            NUMBER;
l_worker_start        NUMBER;
l_worker_end          NUMBER;

BEGIN

  DELETE qp_upg_lines_distribution
  WHERE  line_type = 'PRF'; --line_type for Pricing Formulas

  COMMIT;

  BEGIN
    SELECT nvl(min(pricing_rule_id),0),
           nvl(max(pricing_rule_id),0)
    INTO   l_min_line, l_max_line
    FROM   so_pricing_rules_vl;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FOR i IN 1..l_workers LOOP
    l_worker_start :=
	   l_min_line + trunc( (i-1) * (l_max_line-l_min_line)/l_workers);
    l_worker_end :=
	   l_min_line + trunc(i*(l_max_line-l_min_line)/l_workers);

    IF i <> l_workers THEN
      l_worker_end := l_worker_end - 1;
    END IF;

    qp_modifier_upgrade_util_pvt.insert_line_distribution
			(l_worker      => i,
                l_start_line  => l_worker_start,
                l_end_line    => l_worker_end,
                l_type_var    => 'PRF');

  END LOOP;

  COMMIT;


END Create_Parallel_Slabs;


/***********************************************************************
 Procedure to Upgrade from Pricing Rules to Price Formula tables.
************************************************************************/

--PROCEDURE  Upgrade_Price_Formulas (l_worker  IN NUMBER := 1)  --2422176
PROCEDURE  Upgrade_Price_Formulas (l_worker  IN NUMBER)
IS

l_item_context_flag      BOOLEAN := TRUE;
l_exists                 VARCHAR2(1);
l_price_formula_line_id  NUMBER;
l_list_header_id         NUMBER;
l_list_line_id           NUMBER;

l_entity1                VARCHAR2(30);
l_entity2                VARCHAR2(30);
l_entity3                VARCHAR2(30);
l_entity4                VARCHAR2(30);
l_entity5                VARCHAR2(30);

l_contexts               CONTEXTS_TBL;
l_context1               VARCHAR2(30);
l_context2               VARCHAR2(30);
l_context3               VARCHAR2(30);
l_context4               VARCHAR2(30);
l_context5               VARCHAR2(30);

l_attribute1             VARCHAR2(40);
l_attribute2             VARCHAR2(40);
l_attribute3             VARCHAR2(40);
l_attribute4             VARCHAR2(40);
l_attribute5             VARCHAR2(40);

l_attr_value             VARCHAR2(240);

l_min_line               NUMBER;
l_max_line               NUMBER;

x_context_flag           VARCHAR2(1);
x_attribute_flag         VARCHAR2(1);
x_value_flag             VARCHAR2(1);
x_datatype               VARCHAR2(1);
x_precedence             NUMBER;
x_error_code             NUMBER;

CURSOR so_pricing_rules_cur (a_min_line    NUMBER,
					    a_max_line    NUMBER)
IS
  SELECT *
  FROM   so_pricing_rules_vl
  WHERE  pricing_rule_id BETWEEN a_min_line AND a_max_line;

CURSOR so_pricing_rule_lines_cur (a_pricing_rule_id  NUMBER)
IS
  SELECT *
  FROM   so_pricing_rule_lines l
  WHERE  l.pricing_rule_id = a_pricing_rule_id;

CURSOR so_rule_line_comp_values_cur(a_pricing_rule_id   NUMBER,
						      a_step_number       NUMBER)
IS
  SELECT l.pricing_rule_id,
	    v.amount,
	    v.creation_date, v.created_by, v.last_update_date,
	    v.last_updated_by, v.last_update_login,
         v.context, v.attribute1, v.attribute2, v.attribute3,
         v.attribute4, v.attribute5, v.attribute6, v.attribute7,
         v.attribute8, v.attribute9, v.attribute10, v.attribute11,
         v.attribute12, v.attribute13, v.attribute14, v.attribute15,
         c.name, c.description,
	    c.creation_date c_creation_date, c.created_by c_created_by,
	    c.last_update_date c_last_update_date, c.last_updated_by c_last_updated_by,
	    c.last_update_login c_last_update_login,
	    c.entity_id_1, c.entity_id_2, c.entity_id_3, c.entity_id_4,
	    c.entity_id_5, v.value1, v.value2, v.value3, v.value4, v.value5,
         c.context c_context, c.attribute1 c_attribute1, c.attribute2 c_attribute2,
	    c.attribute3 c_attribute3, c.attribute4 c_attribute4,
	    c.attribute5 c_attribute5, c.attribute6 c_attribute6,
	    c.attribute7 c_attribute7, c.attribute8 c_attribute8,
	    c.attribute9 c_attribute9, c.attribute10 c_attribute10,
	    c.attribute11 c_attribute11, c.attribute12 c_attribute12,
	    c.attribute13 c_attribute13, c.attribute14 c_attribute14,
	    c.attribute15 c_attribute15

  FROM   so_pricing_rule_lines l, so_pricing_rule_line_values v,
	    so_rule_formula_components c
  WHERE  l.pricing_rule_id      = v.pricing_rule_id(+)
  AND    l.step_number          = v.step_number(+)
  AND    l.formula_component_id = c.formula_component_id
  AND    l.pricing_rule_id      = a_pricing_rule_id
  AND    l.step_number          = a_step_number;

BEGIN

  BEGIN
    SELECT start_line_id, end_line_id
    INTO   l_min_line, l_max_line
    FROM   qp_upg_lines_distribution
    WHERE  line_type = 'PRF'
    AND    worker = l_worker;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      l_min_line := 0;
      l_max_line := 0;

  END;

  FOR l_rec IN so_pricing_rules_cur(l_min_line, l_max_line)
  LOOP

   BEGIN -- Block around all code in the Pricing Rules Loop
   l_exists := NULL;

   BEGIN
     SELECT 'Y'
     INTO   l_exists
     FROM   qp_price_formulas_b b
     WHERE  b.price_formula_id = l_rec.pricing_rule_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     	  l_exists := NULL;
   END;

   IF l_exists IS NULL THEN  -- Formula Id does not already exist

     QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Price_Formula(
                                   l_rec.pricing_rule_id, --price_formula_id
                                   l_rec.creation_date,
                                   l_rec.created_by,
                                   l_rec.last_update_date,
                                   l_rec.last_updated_by,
                                   l_rec.last_update_login,
                                   l_rec.context,
                                   l_rec.attribute1,
                                   l_rec.attribute2,
                                   l_rec.attribute3,
                                   l_rec.attribute4,
                                   l_rec.attribute5,
                                   l_rec.attribute6,
                                   l_rec.attribute7,
                                   l_rec.attribute8,
                                   l_rec.attribute9,
                                   l_rec.attribute10,
                                   l_rec.attribute11,
                                   l_rec.attribute12,
                                   l_rec.attribute13,
                                   l_rec.attribute14,
                                   l_rec.attribute15,
                                   l_rec.formula,
                                   l_rec.start_date_active,
                                   l_rec.end_date_active,
							l_rec.name,
							l_rec.description);


     FOR l_lines_rec IN
  	  so_pricing_rule_lines_cur(l_rec.pricing_rule_id)
     LOOP

       SELECT QP_PRICE_FORMULA_LINES_S.nextval
	  INTO   l_price_formula_line_id
	  FROM   DUAL;

       --Before inserting the formula line record, insert a Modifier List
	  --(Factor List), Modifier(Factor) and Modifier attributes
	  --(Factor Pricing Attributes). Need to get contexts first.

	  SELECT entity_id_1, entity_id_2, entity_id_3, entity_id_4, entity_id_5
	  INTO   l_entity1, l_entity2, l_entity3, l_entity4, l_entity5
	  FROM   so_rule_formula_components
	  WHERE  formula_component_id = l_lines_rec.formula_component_id;

       --Function to get Context and Attribute based on entity_code.
       --If entity_code is not an item-context then fetch contexts from
	  --price list lines or descriptive flexfield setup

	  l_contexts.delete; --Empty the plsql table of contexts each time
	  l_attribute1 := '';-- Reset the attribute values
	  G_Context := '';

       IF l_entity1 IS NOT NULL THEN
         Get_Ctx_Attr(l_rec.pricing_rule_id, l_entity1,
				  l_contexts, l_attribute1);
	    l_context1   := l_contexts(1);
         IF l_context1 <> 'ITEM' THEN
            G_Context := l_context1;
	    END IF;
	  END IF;

	  l_contexts.delete; --Empty the plsql table of contexts each time
	  l_attribute2 := '';-- Reset the attribute values

       IF l_entity2 IS NOT NULL THEN
         Get_Ctx_Attr(l_rec.pricing_rule_id, l_entity2,
				  l_contexts, l_attribute2);
	    l_context2   := l_contexts(1);
         IF l_context2 <> 'ITEM' THEN
		 IF G_Context IS NULL THEN
              G_Context := l_context2;
	      END IF;
	    END IF;
	  END IF;

	  l_contexts.delete; --Empty the plsql table of contexts each time
	  l_attribute3 := '';-- Reset the attribute values

       IF l_entity3 IS NOT NULL THEN
         Get_Ctx_Attr(l_rec.pricing_rule_id, l_entity3,
				  l_contexts, l_attribute3);
	    l_context3   := l_contexts(1);
         IF l_context3 <> 'ITEM' THEN
		 IF G_Context IS NULL THEN
              G_Context := l_context3;
	      END IF;
	    END IF;
	  END IF;

	  l_contexts.delete; --Empty the plsql table of contexts each time
	  l_attribute4 := '';-- Reset the attribute values

       IF l_entity4 IS NOT NULL THEN
         Get_Ctx_Attr(l_rec.pricing_rule_id, l_entity4,
				  l_contexts, l_attribute4);
	    l_context4   := l_contexts(1);
         IF l_context4 <> 'ITEM' THEN
		 IF G_Context IS NULL THEN
              G_Context := l_context4;
	      END IF;
	    END IF;
	  END IF;

	  l_contexts.delete; --Empty the plsql table of contexts each time
	  l_attribute5 := '';-- Reset the attribute values

       IF l_entity5 IS NOT NULL THEN
         Get_Ctx_Attr(l_rec.pricing_rule_id, l_entity5,
				  l_contexts, l_attribute5);
	    l_context5   := l_contexts(1);
         IF l_context5 <> 'ITEM' THEN
		 IF G_Context IS NULL THEN
              G_Context := l_context5;
	      END IF;
	    END IF;
	  END IF;

	  FOR l_value_rec IN so_rule_line_comp_values_cur(l_lines_rec.pricing_rule_id,
									     	l_lines_rec.step_number)
	  LOOP

	  IF so_rule_line_comp_values_cur%ROWCOUNT = 1 THEN

         SELECT QP_LIST_HEADERS_B_S.nextval
	    INTO   l_list_header_id
	    FROM   DUAL;

     --dbms_output.put_line(' list header '||l_list_header_id);
	--dbms_output.put_line(l_value_rec.name || to_char(l_price_formula_line_id));
	--dbms_output.put_line(l_lines_rec.pricing_rule_id);
	--dbms_output.put_line(l_lines_rec.step_number);


         QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_List_Header(
                                        l_list_header_id,
                                        l_value_rec.c_creation_date,
                                        l_value_rec.c_created_by,
                                        l_value_rec.c_last_update_date,
                                        l_value_rec.c_last_updated_by,
                                        l_value_rec.c_last_update_login,
                                        'PML', --list_type_code
                                        'N',   --automatic_flag
                                        null,  --currency_code
                                        l_value_rec.c_context,
                                        l_value_rec.c_attribute1,
                                        l_value_rec.c_attribute2,
                                        l_value_rec.c_attribute3,
                                        l_value_rec.c_attribute4,
                                        l_value_rec.c_attribute5,
                                        l_value_rec.c_attribute6,
                                        l_value_rec.c_attribute7,
                                        l_value_rec.c_attribute8,
                                        l_value_rec.c_attribute9,
                                        l_value_rec.c_attribute10,
                                        l_value_rec.c_attribute11,
                                        l_value_rec.c_attribute12,
                                        l_value_rec.c_attribute13,
                                        l_value_rec.c_attribute14,
                                        l_value_rec.c_attribute15,
                                        'QP',  --source_system_code
                                        'Y',   --active_flag
                                        'N',   --ask_for_flag
								l_value_rec.name || to_char(l_price_formula_line_id),
								l_value_rec.description,
								'1'    --version_no
	                                  );

	  END IF; --If rowcount = 1

         SELECT QP_LIST_LINES_S.nextval
	    INTO   l_list_line_id
	    FROM   DUAL;

         QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_List_Line(
	                                   l_list_line_id,
	                                   nvl(l_value_rec.creation_date,sysdate),
	                                   nvl(l_value_rec.created_by,-1),
	                                   nvl(l_value_rec.last_update_date, sysdate),
	                                   nvl(l_value_rec.last_updated_by,-1),
	                                   nvl(l_value_rec.last_update_login, -1),
	                                   l_list_header_id,
	                                   'PMR', --list_line_type_code
	                                   'N',   --automatic_flag
	                                   'NONE',--modifier_level_code
	                                   null,  --arithmetic_operator
	                                   nvl(l_value_rec.amount, 0), --operand
	                                   null, --pricing_phase_id
	                                   null, --incompatibility_grp_code
	                                   1,    --pricing_group_sequence
	                                   'N',  --accrual_flag
	                                   null, --product_precedence
	                                   1,    --base_qty
	                                   null, --base_uom_code
	                                   'Y',  --recurring_flag
	                                   null, --proration_type_code,
	                                   'N',  --print_on_invoice_flag
	                                   l_value_rec.context, l_value_rec.attribute1,
								l_value_rec.attribute2, l_value_rec.attribute3,
								l_value_rec.attribute4, l_value_rec.attribute5,
	                                   l_value_rec.attribute6, l_value_rec.attribute7,
								l_value_rec.attribute8, l_value_rec.attribute9,
								l_value_rec.attribute10,l_value_rec.attribute11,
								l_value_rec.attribute12,l_value_rec.attribute13,
								l_value_rec.attribute14,l_value_rec.attribute15
	                                  );

	    IF l_value_rec.entity_id_1 IS NOT NULL THEN

           l_attr_value :=
		        Get_Attr_Value(l_context1, l_attribute1, l_value_rec.value1);

           QP_UTIL.validate_qp_flexfield(
				    flexfield_name => 'QP_ATTR_DEFNS_PRICING',
				    context  => l_context1, attribute => l_attribute1,
				    value => l_attr_value, application_short_name => 'QP',
				    context_flag => x_context_flag,
				    attribute_flag => x_attribute_flag,
				    value_flag => x_value_flag, datatype => x_datatype,
                        precedence => x_precedence, error_code => x_error_code);

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
              nvl(l_value_rec.creation_date,sysdate), nvl(l_value_rec.created_by, -1),
		    nvl(l_value_rec.last_update_date,sysdate), nvl(l_value_rec.last_updated_by,-1),
              nvl(l_value_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		    l_context1, l_attribute1, l_attr_value, null,
		    x_datatype, '=');

	    END IF;


	    IF l_value_rec.entity_id_2 IS NOT NULL THEN

           l_attr_value :=
			   Get_Attr_Value(l_context2, l_attribute2, l_value_rec.value2);

           QP_UTIL.validate_qp_flexfield(
				    flexfield_name => 'QP_ATTR_DEFNS_PRICING',
				    context => l_context2, attribute =>  l_attribute2,
				    value => l_attr_value, application_short_name => 'QP',
				    context_flag => x_context_flag,
				    attribute_flag => x_attribute_flag,
				    value_flag => x_value_flag, datatype => x_datatype,
				    precedence => x_precedence, error_code => x_error_code);

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
              nvl(l_value_rec.creation_date,sysdate), nvl(l_value_rec.created_by, -1),
		    nvl(l_value_rec.last_update_date,sysdate), nvl(l_value_rec.last_updated_by,-1),
              nvl(l_value_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		    l_context2, l_attribute2, l_attr_value, null,
		    x_datatype, '=');
	    END IF;


	    IF l_value_rec.entity_id_3 IS NOT NULL THEN

           l_attr_value :=
			   Get_Attr_Value(l_context3, l_attribute3, l_value_rec.value3);

           QP_UTIL.validate_qp_flexfield(
				    flexfield_name => 'QP_ATTR_DEFNS_PRICING',
				    context => l_context3, attribute => l_attribute3,
				    value => l_attr_value,
				    application_short_name => 'QP',
				    context_flag => x_context_flag,
				    attribute_flag => x_attribute_flag,
				    value_flag => x_value_flag, datatype => x_datatype,
				    precedence => x_precedence, error_code => x_error_code);

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
              nvl(l_value_rec.creation_date,sysdate), nvl(l_value_rec.created_by, -1),
		    nvl(l_value_rec.last_update_date,sysdate), nvl(l_value_rec.last_updated_by,-1),
              nvl(l_value_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		    l_context3, l_attribute3, l_attr_value, null,
		    x_datatype, '=');
	    END IF;


	    IF l_value_rec.entity_id_4 IS NOT NULL THEN

           l_attr_value :=
			   Get_Attr_Value(l_context4, l_attribute4, l_value_rec.value4);

           QP_UTIL.validate_qp_flexfield(
				    flexfield_name => 'QP_ATTR_DEFNS_PRICING',
				    context => l_context4, attribute => l_attribute4,
				    value => l_attr_value,
				    application_short_name => 'QP',
				    context_flag => x_context_flag,
				    attribute_flag => x_attribute_flag,
				    value_flag => x_value_flag, datatype => x_datatype,
				    precedence => x_precedence, error_code => x_error_code);

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
              nvl(l_value_rec.creation_date,sysdate), nvl(l_value_rec.created_by, -1),
		    nvl(l_value_rec.last_update_date,sysdate), nvl(l_value_rec.last_updated_by,-1),
              nvl(l_value_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		    l_context4, l_attribute4, l_attr_value, null,
		    x_datatype, '=');
	    END IF;


	    IF l_value_rec.entity_id_5 IS NOT NULL THEN

           l_attr_value :=
			   Get_Attr_Value(l_context5, l_attribute5, l_value_rec.value5);

           QP_UTIL.validate_qp_flexfield(
				    flexfield_name => 'QP_ATTR_DEFNS_PRICING',
				    context => l_context5, attribute => l_attribute5,
				    value => l_attr_value,
				    application_short_name => 'QP',
				    context_flag => x_context_flag,
				    attribute_flag => x_attribute_flag,
				    value_flag => x_value_flag, datatype => x_datatype,
				    precedence => x_precedence, error_code => x_error_code);

		 QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Pricing_Attribute(
              nvl(l_value_rec.creation_date,sysdate), nvl(l_value_rec.created_by, -1),
		    nvl(l_value_rec.last_update_date,sysdate), nvl(l_value_rec.last_updated_by,-1),
              nvl(l_value_rec.last_update_login,-1), l_list_line_id, 'N', 'N',
		    l_context5, l_attribute5, l_attr_value, null,
		    x_datatype, '=');
	    END IF;

       END LOOP; -- Loop through rule lines values


       QP_PRICE_FORMULA_UPG_UTIL_PVT.Insert_Price_Formula_Line(
                     l_price_formula_line_id, --price_formula_line_id
                     l_lines_rec.creation_date,
                     l_lines_rec.created_by,
		           l_lines_rec.last_update_date,
				 l_lines_rec.last_updated_by,
				 l_lines_rec.last_update_login,
				 l_lines_rec.pricing_rule_id, --price_formula_id
				 'ML', --price_formula_line_type_code
                     null, --price_list_line_id
                     l_list_header_id, --price_modifier_list_id
                     null, --pricing_attribute_context
                     null, --pricing_attribute
                     l_lines_rec.context,
                     l_lines_rec.attribute1,
                     l_lines_rec.attribute2,
                     l_lines_rec.attribute3,
                     l_lines_rec.attribute4,
                     l_lines_rec.attribute5,
                     l_lines_rec.attribute6,
                     l_lines_rec.attribute7,
                     l_lines_rec.attribute8,
                     l_lines_rec.attribute9,
                     l_lines_rec.attribute10,
                     l_lines_rec.attribute11,
                     l_lines_rec.attribute12,
                     l_lines_rec.attribute13,
                     l_lines_rec.attribute14,
                     l_lines_rec.attribute15,
                     l_lines_rec.start_date_active,
                     l_lines_rec.end_date_active,
                     l_lines_rec.step_number,
                     null --numeric_constant
				 );

     END LOOP; -- Loop through Pricing Rule Lines

   END IF; -- If formula does not already exist

  EXCEPTION
    WHEN NO_DATA_FOUND OR DUP_VAL_ON_INDEX OR VALUE_ERROR THEN
	 err_msg := substr(sqlerrm, 1, 240);
      rollback;
      QP_UTIL.Log_Error (
	  p_id1 => 'Price Formula Id' || to_char(l_rec.pricing_rule_id),
	  p_error_type => 'FORMULA',
	  p_error_desc => err_msg,
	  p_error_module => 'Upgrade_Price_Formulas');

    WHEN OTHERS THEN
	 err_msg := substr(sqlerrm, 1, 240);
      rollback;
      QP_UTIL.Log_Error (
	  p_id1 => 'Price Formula Id' || to_char(l_rec.pricing_rule_id),
	  p_error_type => 'FORMULA',
	  p_error_desc => err_msg,
	  p_error_module => 'Upgrade_Price_Formulas');
	 raise;

  END; --Block around all the code in the Pricing Rule Loop

  commit; --For each successful Pricing Rule
  END LOOP; --Loop through Pricing Rules

  Upgrade_Unused_Components; -- Call Proc. to upgrade unused rule components

-- Flexfield Merging
-- Run the utility procedure to upgrade Descriptive Flexfields
-- from Pricing to Price Formulas
--  QP_UTIL.qp_upgrade_context('OE', 'QP', 'SO_PRICING_RULES', 'QP_PRICE_FORMULAS_B');
--  QP_UTIL.qp_upgrade_context('OE', 'QP', 'SO_PRICING_RULE_LINES', 'QP_PRICE_FORMULA_LINES');
--  QP_UTIL.qp_upgrade_context('OE', 'QP', 'SO_RULE_FORMULA_COMPONENTS', 'QP_LIST_HEADERS');
--  QP_UTIL.qp_upgrade_context('OE', 'QP', 'SO_PRICING_RULE_LINE_VALUES', 'QP_LIST_LINES');
  commit;

EXCEPTION
  WHEN OTHERS THEN
    err_msg := substr(sqlerrm, 1, 240);
    rollback;
    QP_UTIL.Log_Error (
	p_id1 => null,
	p_error_type => 'FORMULA',
	p_error_desc => err_msg,
	p_error_module => 'Upgrade_Price_Formulas');
    raise;

END Upgrade_Price_Formulas;


END QP_PRICE_FORMULA_UPG_UTIL_PVT;

/
