--------------------------------------------------------
--  DDL for Package Body QP_COPY_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_COPY_PRICELIST_PVT" AS
/* $Header: QPXVCPLB.pls 120.15.12010000.4 2009/06/04 07:16:00 jputta ship $ */

-- GLOBAL Constant holding the package name

--G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_COPY_PRICELIST_PVT';


/***************************************************************
* Function to check if a list_line is a Price Break Line       *
****************************************************************/

FUNCTION  Price_Break_Line(p_list_line_id IN NUMBER)
RETURN BOOLEAN
IS

l_return               BOOLEAN :=  FALSE;
l_to_rltd_modifier_id  NUMBER;

CURSOR  price_break_line_cur(a_list_line_id NUMBER)
IS
  SELECT to_rltd_modifier_id
  FROM   qp_rltd_modifiers
  WHERE  to_rltd_modifier_id = a_list_line_id;

BEGIN

  OPEN  price_break_line_cur(p_list_line_id);
  FETCH price_break_line_cur
  INTO  l_to_rltd_modifier_id;

  IF price_break_line_cur%FOUND THEN
    l_return := TRUE;
  ELSE
    l_return := FALSE;
  END IF;

  CLOSE price_break_line_cur;

  RETURN l_return;

END Price_Break_Line;


/************************************************************************
*Function to Get New Id for an Old list_line_id from the mapping table  *
*************************************************************************/

FUNCTION Get_New_Id (a_list_line_id IN NUMBER,
				 a_mapping_tbl  IN mapping_tbl)
RETURN NUMBER
IS
l_return        NUMBER := 0;

BEGIN
	FOR i IN 1..a_mapping_tbl.COUNT
	LOOP

       IF a_mapping_tbl(i).old_list_line_id = a_list_line_id THEN
	    l_return := a_mapping_tbl(i).new_list_line_id;
	    EXIT;
       END IF;

	END LOOP;

	RETURN l_return;

END Get_New_Id;


/***********************************************************************/
/* Procedure to Delete Duplicate Lines potentially created effective   */
/* dates not retained while copying lines from one price list to       */
/* another.                                                            */
/***********************************************************************/

PROCEDURE Delete_Duplicate_Lines (p_effective_dates_flag    VARCHAR2,
						    p_new_list_header_id		NUMBER)
IS


/*  Commented out bu dhgupta for bug 2100785 */
/*
CURSOR del_dup_cur (a_new_list_header_id   	NUMBER)
IS
  SELECT *
  FROM   qp_list_lines a
  WHERE EXISTS (SELECT NULL
    		     FROM   qp_list_lines b
		     WHERE  a.inventory_item_id   = 	b.inventory_item_id
		     AND    a.list_line_type_code = 	b.list_line_type_code
		     AND    a.list_header_id      = 	b.list_header_id
		     AND    a.list_header_id      = 	a_new_list_header_id
               AND    a.list_line_id        < 	b.list_line_id
    		     AND    nvl(a.automatic_flag,'x') = nvl(b.automatic_flag,'x')
    		     AND  	nvl(a.modifier_level_code,'x') =
	    							nvl(b.modifier_level_code,'x')
    		     AND    nvl(a.list_price,-1)      = nvl(b.list_price,-1)
   	          AND    nvl(a.primary_uom_flag,'x') =
								nvl(b.primary_uom_flag,'x')
    		     AND    nvl(a.organization_id,-1) = nvl(b.organization_id,-1)
    		     AND    nvl(a.related_item_id,-1) = nvl(b.related_item_id,-1)
    		     AND    nvl(a.relationship_type_id,-1) =
								nvl(b.relationship_type_id,-1)
    		     AND 	  nvl(a.substitution_context,'x') =
								nvl(b.substitution_context,'x')
    		     AND 	  nvl(a.substitution_attribute,'x') =
								nvl(b.substitution_attribute,'x')
    		     AND 	  nvl(a.substitution_value,'x') =
								nvl(b.substitution_value,'x')
    		     AND 	  nvl(a.context,'x') 		= nvl(b.context,'x')
    		     AND 	  nvl(a.attribute1,'x')   = nvl(b.attribute1, 'x')
    		     AND 	nvl(a.attribute2,'x')   = nvl(b.attribute2, 'x')
    		     AND 	nvl(a.comments,'x')    = nvl(b.comments,'x')
    		     AND 	nvl(a.attribute3,'x')   = nvl(b.attribute3,'x')
    		     AND 	nvl(a.attribute4,'x')   = nvl(b.attribute4,'x')
    		     AND 	nvl(a.attribute5,'x')   = nvl(b.attribute5,'x')
    		     AND 	nvl(a.attribute6,'x')   = nvl(b.attribute6,'x')
    		     AND 	nvl(a.attribute7,'x')   = nvl(b.attribute7,'x')
    		     AND 	nvl(a.attribute8,'x')   = nvl(b.attribute8,'x')
    		     AND 	nvl(a.attribute9,'x')   = nvl(b.attribute9,'x')
    		     AND 	nvl(a.attribute10,'x')  = nvl(b.attribute10,'x')
    		     AND 	nvl(a.attribute11,'x')  = nvl(b.attribute11,'x')
    		     AND 	nvl(a.attribute12,'x')  = nvl(b.attribute12,'x')
    		     AND 	nvl(a.attribute13,'x')  = nvl(b.attribute13,'x')
    		     AND 	nvl(a.attribute14,'x')  = nvl(b.attribute14,'x')
    		     AND 	nvl(a.attribute15,'x')  = nvl(b.attribute15,'x')
    		     AND 	nvl(a.price_break_type_code,'x') =
	  							 nvl(b.price_break_type_code,'x')
    		     AND 	nvl(a.percent_price,-1) = nvl(b.percent_price,-1)
    		     AND 	nvl(a.price_by_formula_id,-1) =
								 nvl(b.price_by_formula_id,-1)
    		     AND 	nvl(a.number_effective_periods,-1) =
    		   					   nvl(b.number_effective_periods,-1)
    		     AND 	nvl(a.effective_period_uom,'x') =
    		   					      nvl(b.effective_period_uom,'x')
    		     AND 	nvl(a.arithmetic_operator,'x') =
    		   						 nvl(b.arithmetic_operator,'x')
    		     AND 	nvl(a.operand,-1) = nvl(b.operand,-1)
    		     AND 	nvl(a.override_flag,'x') = nvl(b.override_flag,'x')
    		     AND 	nvl(a.print_on_invoice_flag,'x') =
								nvl(b.print_on_invoice_flag,'x')
    		     AND 	nvl(a.rebate_transaction_type_code,'x') =
						  nvl(b.rebate_transaction_type_code,'x')
    		     AND 	nvl(a.estim_accrual_rate,-1) =
								nvl(b.estim_accrual_rate,-1)
    		     AND 	nvl(a.generate_using_formula_id,-1) =
							nvl(b.generate_using_formula_id,-1)
		     AND 	nvl(a.reprice_flag,'x') = nvl(b.reprice_flag,'x')
               AND nvl(a.accrual_flag, 'x') = nvl(b.accrual_flag, 'x')
               AND nvl(a.pricing_group_sequence, -1) =
						    nvl(b.pricing_group_sequence, -1)
               AND nvl(a.incompatibility_grp_code, 'x') =
						    nvl(b.incompatibility_grp_code, 'x')
               AND nvl(a.list_line_no, 'x') = nvl(b.list_line_no, 'x')
               AND nvl(a.product_precedence, -1) =
						    nvl(b.product_precedence, -1)
               AND nvl(a.pricing_phase_id, -1) = nvl(b.pricing_phase_id, -1)
               AND nvl(a.number_expiration_periods, -1) =
						    nvl(b.number_expiration_periods, -1)
               AND nvl(a.expiration_period_uom, 'x') =
						    nvl(b.expiration_period_uom, 'x')
               AND nvl(a.estim_gl_value, -1) = nvl(b.estim_gl_value, -1)
               AND nvl(a.accrual_conversion_rate, -1) =
						    nvl(b.accrual_conversion_rate, -1)
               AND nvl(a.benefit_price_list_line_id, -1) =
						    nvl(b.benefit_price_list_line_id, -1)
               AND nvl(a.proration_type_code, 'x') =
						    nvl(b.proration_type_code, 'x')
               AND nvl(a.benefit_qty, -1) = nvl(b.benefit_qty, -1)
               AND nvl(a.benefit_uom_code, 'x') = nvl(b.benefit_uom_code, 'x')
               AND nvl(a.charge_type_code, 'x') = nvl(b.charge_type_code, 'x')
               AND nvl(a.charge_subtype_code, 'x') =
						    nvl(b.charge_subtype_code, 'x')
               AND nvl(a.benefit_limit, -1) = nvl(b.benefit_limit, -1)
               AND nvl(a.include_on_returns_flag, 'x') =
						    nvl(b.include_on_returns_flag, 'x')
               AND nvl(a.qualification_ind, -1) = nvl(b.qualification_ind, -1)
		   ) FOR UPDATE;

*/

 /* Added by dhgupta for 2100785 */

CURSOR list_lines_cur (a_new_list_header_id  NUMBER)
IS
  SELECT list_line_id
  FROM qp_list_lines
  WHERE list_header_id=a_new_list_header_id;

l_status BOOLEAN := TRUE;
l_rows number := 0;
l_revision boolean := FALSE;
l_effdates boolean := FALSE;
l_dup_sdate DATE := NULL;
l_dup_edate DATE := NULL;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
x_msg_count                   NUMBER:=0;
x_msg_data                    VARCHAR2(2000);
K                             NUMBER:=1;

BEGIN

--If the Retain Effective Dates flag is not checked then copied price list
--lines will have null effective dates. This will mean that there is a
--possibility that lines may be duplicated. To prevent this, all but one
--duplicate lines are deleted here.

  IF p_effective_dates_flag = 'N' THEN

    /* Added by dhgupta for 2100785 */

    FOR l_list_lines_id IN list_lines_cur(p_new_list_header_id)
    LOOP
    l_status := QP_VALIDATE_PLL_PRICING_ATTR.Check_Dup_Pra(NULL,
                                              NULL,
                                              NULL,
                                              l_list_lines_id.list_line_id,
                                              p_new_list_header_id,
                                              l_rows,
                                              l_revision,
                                              l_effdates,
                                              l_dup_sdate,
                                              l_dup_edate);
    IF NVL(l_rows,0) = 0 THEN

      /* Added for 2397463 */

      l_PRICE_LIST_LINE_tbl(K).list_line_id := l_list_lines_id.list_line_id;
      l_PRICE_LIST_LINE_tbl(K).operation := QP_GLOBALS.G_OPR_DELETE;

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

      /* Commented out for 2397463 */
/*
      DELETE qp_pricing_attributes pa
      WHERE  pa.list_line_id = l_list_lines_id.list_line_id;

      DELETE qp_list_lines
      WHERE  list_line_id = l_list_lines_id.list_line_id;
*/
    END IF;

    END LOOP;

    /* Commented out by dhgupta for 2100785 */
/*
    FOR   l_del_dup_cur_rec IN del_dup_cur(p_new_list_header_id)
    LOOP

      DELETE qp_pricing_attributes pa
      WHERE  pa.list_line_id = l_del_dup_cur_rec.list_line_id;

      DELETE qp_list_lines
      WHERE  CURRENT OF del_dup_cur;

    END LOOP;
*/
  END IF; /* End of IF p_effective_dates_flag = 'N' */

EXCEPTION

  WHEN OTHERS THEN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Error in Deleting Duplicate Lines');
   END IF;

   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Duplicate_Lines;


/***********************************************************************/
/* Procedure to copy discounts - headers, lines, attributes, qualifiers*/
/***********************************************************************/

PROCEDURE Copy_Discounts
(
 p_from_list_header_id 	 	 NUMBER,
 p_new_list_header_id          NUMBER,
 p_context                     VARCHAR2,
 p_attribute				 VARCHAR2,
 p_user_id                     NUMBER,
 p_conc_login_id               NUMBER,
 p_conc_program_application_id NUMBER,
 p_conc_program_id             NUMBER,
 p_conc_request_id             NUMBER,
 x_new_discount_header_id      OUT  NOCOPY NUMBER   -- Added for bug 8326619
)
IS

l_mapping_tbl                 mapping_tbl;

l_name 				     VARCHAR2(240);
l_description                 VARCHAR2(2000);
l_version_no                  VARCHAR2(30);
l_new_discount_header_id      NUMBER;
l_new_qualifier_id            NUMBER;
l_new_discount_line_id        NUMBER;
l_new_pricing_attribute_id    NUMBER;
l_new_rltd_modifier_id        NUMBER;

l_count                       NUMBER := 0;
l_new_from_id                 NUMBER;
l_new_to_id                   NUMBER;

l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;

l_list_type_code VARCHAR2(30) := '';
l_active_flag VARCHAR2(1) := '';
l_qual_attr_value_from_number NUMBER := NULL;
l_qual_attr_value_to_number NUMBER := NULL;

x_result                      VARCHAR2(1);

--bug#6636843
l_new_orig_system_hrd_Ref   VARCHAR2(50);

CURSOR qp_from_discounts_cur(p_from_list_header_id NUMBER, p_context VARCHAR2,
					    p_attribute  VARCHAR2)
IS
  SELECT list_header_id
  FROM   qp_qualifiers a
  WHERE  a.qualifier_context   =  p_context
  AND    a.qualifier_attribute =  p_attribute
  AND    a.qualifier_attr_value = TO_CHAR(p_from_list_header_id)
  AND    a.list_header_id       IN
			(SELECT list_header_id
                         --fix for bug 4673872
			 FROM   qp_list_headers_all_b
			 WHERE  list_type_code = 'DLT');

CURSOR qp_hdr_qualifiers_cur(p_from_discount_header_id    NUMBER) -- Name changed for cursor for bug 8326619 and an extra condition added
IS
  SELECT *
  FROM   qp_qualifiers
  WHERE  list_header_id = p_from_discount_header_id
  AND list_line_id = -1;

CURSOR qp_lin_qualifiers_cur(p_from_discount_header_id    NUMBER)  -- Added cursor for bug 8326619
IS
  SELECT *
  FROM   qp_qualifiers
  WHERE  list_header_id = p_from_discount_header_id
  AND list_line_id <> -1;

CURSOR qp_discount_lines_cur(p_from_discount_header_id    NUMBER)
IS
  SELECT *
  FROM   qp_list_lines
  WHERE  list_header_id = p_from_discount_header_id;

CURSOR qp_pricing_attributes_cur(p_from_discount_line_id      NUMBER)
IS
  SELECT *
  FROM   qp_pricing_attributes
  WHERE  list_line_id = p_from_discount_line_id;

CURSOR qp_rltd_modifiers_cur(a_list_line_id NUMBER)
IS
    SELECT *
    FROM   qp_rltd_modifiers
    WHERE  from_rltd_modifier_id = a_list_line_id;

--bug#6636843
CURSOR qp_list_headers_tl_cur(a_list_hdr_id qp_list_headers_tl.list_header_id%TYPE)
IS
  SELECT name, description, version_no
  FROM   qp_list_headers_tl
  WHERE  list_header_id = a_list_hdr_id;


BEGIN

FOR qp_from_discounts_rec IN qp_from_discounts_cur(p_from_list_header_id,
										     p_context,
										     p_attribute)
LOOP
  /* For every old(from) discount, Copy discount header records */

  l_count := 0; --Reset the mapping table count for each discount header

  --Select next discount_header_id

  SELECT qp_list_headers_b_s.nextval
  INTO   l_new_discount_header_id
  FROM   dual;

  --bug#6636843
  l_new_orig_system_hrd_Ref := QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(l_new_discount_header_id);

  --Discount Header Information

  INSERT INTO qp_list_headers_all_b
  (
   list_header_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   program_application_id,
   program_id,
   program_update_date,
   request_id,
   list_type_code,
   start_date_active,
   end_date_active,
   automatic_flag,
-- exclusive_flag,
   currency_code,
   rounding_factor,
   ship_method_code,
   freight_terms_code,
   terms_id,
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
   comments,
   discount_lines_flag,
   gsa_indicator,
   prorate_flag,
   source_system_code,
   active_flag,
   parent_list_header_id,
   start_date_active_first,
   end_date_active_first,
   active_date_first_type,
   start_date_active_second,
   end_date_active_second,
   active_date_second_type,
   ask_for_flag,
   currency_header_id,   -- Multi-Currency SunilPandey
   pte_code   -- Attribute Manager, Giri
   --ENH Upgrade BOAPI for orig_sys...ref RAVI
   ,ORIG_SYSTEM_HEADER_REF
  )

  SELECT
   l_new_discount_header_id,
   sysdate,
   p_user_id,
   sysdate,
   p_user_id,
   p_conc_login_id,
   p_conc_program_application_id,
   p_conc_program_id,
   sysdate,
   p_conc_request_id,
   list_type_code,
   start_date_active,
   end_date_active,
   automatic_flag,
--   exclusive_flag,
   currency_code,
   rounding_factor,
   ship_method_code,
   freight_terms_code,
   terms_id,
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
   comments,
   discount_lines_flag,
   gsa_indicator,
   prorate_flag,
   source_system_code,
   active_flag,
   parent_list_header_id,
   start_date_active_first,
   end_date_active_first,
   active_date_first_type,
   start_date_active_second,
   end_date_active_second,
   active_date_second_type,
   ask_for_flag,
   currency_header_id,  -- Multi-Currency SunilPandey
   pte_code   -- Attribute Manager, Giri
   --ENH Upgrade BOAPI for orig_sys...ref RAVI
   --,nvl(ORIG_SYSTEM_HEADER_REF,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(l_new_discount_header_id))
   -- Bug 5201918
   --bug#6636843. Moving this function call to before the query and storing the value in a
   --variable and then using it.
   --,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(l_new_discount_header_id)
     ,l_new_orig_system_hrd_Ref
--fix for bug 4673872
  FROM  qp_list_headers_b
  WHERE list_header_id = qp_from_discounts_rec.list_header_id;


  -- Object Security - sfiresto
  QP_security.create_default_grants( p_instance_type => QP_security.G_MODIFIER_OBJECT,
                                     p_instance_pk1  => l_new_discount_header_id,
                                     x_return_status => x_result);
  -- End addition for Object Security

 --bug#6636843. Loop is added to traverse through table qp_list_headers_tl
 -- for the list being copied since there might be multiple rows in this
 -- table for that list header.
 FOR l_qp_list_headers_tl_rec IN
			 qp_list_headers_tl_cur(qp_from_discounts_rec.list_header_id)
 LOOP

 -- query is commented to fix bug 6636843
 -- SELECT name, description, version_no
 -- INTO   l_name, l_description, l_version_no
--fix for bug 4673872
  --FROM   qp_list_headers_tl
  --WHERE  list_header_id = qp_from_discounts_rec.list_header_id;

  INSERT INTO qp_list_headers_tl
  (last_update_login,
   name,
   description,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   list_header_id,
   language,
   source_lang,
   version_no
  )
  SELECT
   p_conc_login_id,
   --l_name || to_char(l_new_discount_header_id),
   l_qp_list_headers_tl_rec.name || to_char(l_new_discount_header_id), --bug#6636843.
   --l_description,
   l_qp_list_headers_tl_rec.description, --bug#6636843.
   sysdate,
   p_user_id,
   sysdate,
   p_user_id,
   l_new_discount_header_id,
   l.language_code,
   userenv('LANG'),
   --l_version_no
   l_qp_list_headers_tl_rec.version_no --bug#6636843.
  FROM  fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND   NOT EXISTS (SELECT NULL
  			     FROM   qp_list_headers_tl t
			     WHERE  t.list_header_id = l_new_discount_header_id
			     AND    t.language  = l.language_code);


  END LOOP;

  /* Copy all qualifiers for the discount and in case of the qualifier
     being the from-pricelist replace it with the new pricelist*/

  FOR l_qp_qualifiers_rec IN
			 qp_hdr_qualifiers_cur(qp_from_discounts_rec.list_header_id) --- cursor changed for bug 8326619
  LOOP

    --Get new qualifier_id
    SELECT qp_qualifiers_s.nextval
    INTO   l_new_qualifier_id
    FROM   dual;

    IF  l_qp_qualifiers_rec.qualifier_attr_value =
					   TO_CHAR(p_from_list_header_id) AND
        l_qp_qualifiers_rec.qualifier_context = p_context  AND
        l_qp_qualifiers_rec.qualifier_attribute = p_attribute
    THEN
      l_qp_qualifiers_rec.qualifier_attr_value :=
					   TO_CHAR(p_new_list_header_id);
    END IF;

    BEGIN

	 SELECT ACTIVE_FLAG, LIST_TYPE_CODE
	 INTO   l_active_flag, l_list_type_code
         --fix for bug 4673872
	 FROM   QP_LIST_HEADERS_ALL_B
	 WHERE  LIST_HEADER_ID = l_new_discount_header_id;

     EXCEPTION
	    WHEN OTHERS THEN
		  NULL;
     END;

    IF l_qp_qualifiers_rec.qualifier_datatype = 'N'
    then

    BEGIN

	    l_qual_attr_value_from_number :=
	    qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);

	    l_qual_attr_value_to_number :=
	    qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;

    --Insert new qualifier
    INSERT INTO qp_qualifiers
    (
     qualifier_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     program_application_id,
     program_id,
     program_update_date,
     request_id,
	excluder_flag,
     comparison_operator_code,
     qualifier_context,
     qualifier_attribute,
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
     qualifier_rule_id,
     qualifier_grouping_no,
     qualifier_attr_value,
     list_header_id,
     list_line_id,
     created_from_rule_id,
     start_date_active,
     end_date_active,
     qualifier_precedence,
	qualifier_datatype,
	qualifier_attr_value_to,
	active_flag,
	list_type_code,
	qual_attr_value_from_number,
	qual_attr_value_to_number,
	search_ind,
	distinct_row_count,
	qualifier_group_cnt,
	header_quals_exist_flag,
        qualify_hier_descendents_flag -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (
     l_new_qualifier_id,
     sysdate,
     p_user_id,
     sysdate,
     p_user_id,
     p_conc_login_id,
     p_conc_program_application_id,
     p_conc_program_id,
     sysdate,
     p_conc_request_id,
	l_qp_qualifiers_rec.excluder_flag,
     l_qp_qualifiers_rec.comparison_operator_code,
     l_qp_qualifiers_rec.qualifier_context,
     l_qp_qualifiers_rec.qualifier_attribute,
     l_qp_qualifiers_rec.context,
     l_qp_qualifiers_rec.attribute1,
     l_qp_qualifiers_rec.attribute2,
     l_qp_qualifiers_rec.attribute3,
     l_qp_qualifiers_rec.attribute4,
     l_qp_qualifiers_rec.attribute5,
     l_qp_qualifiers_rec.attribute6,
     l_qp_qualifiers_rec.attribute7,
     l_qp_qualifiers_rec.attribute8,
     l_qp_qualifiers_rec.attribute9,
     l_qp_qualifiers_rec.attribute10,
     l_qp_qualifiers_rec.attribute11,
     l_qp_qualifiers_rec.attribute12,
     l_qp_qualifiers_rec.attribute13,
     l_qp_qualifiers_rec.attribute14,
     l_qp_qualifiers_rec.attribute15,
     l_qp_qualifiers_rec.qualifier_rule_id,
     l_qp_qualifiers_rec.qualifier_grouping_no,
     l_qp_qualifiers_rec.qualifier_attr_value,
     l_new_discount_header_id,
     l_qp_qualifiers_rec.list_line_id,
     l_qp_qualifiers_rec.created_from_rule_id,
     l_qp_qualifiers_rec.start_date_active,
     l_qp_qualifiers_rec.end_date_active,
     l_qp_qualifiers_rec.qualifier_precedence,
	l_qp_qualifiers_rec.qualifier_datatype,
	l_qp_qualifiers_rec.qualifier_attr_value_to,
	l_active_flag,
	l_list_type_code,
     l_qual_attr_value_from_number,
     l_qual_attr_value_to_number,
	l_qp_qualifiers_rec.search_ind,
	l_qp_qualifiers_rec.distinct_row_count,
	l_qp_qualifiers_rec.qualifier_group_cnt,
	l_qp_qualifiers_rec.header_quals_exist_flag,
        l_qp_qualifiers_rec.qualify_hier_descendents_flag -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_new_qualifier_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_qp_qualifiers_rec.list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
    );

  END LOOP; /* For copying qualifiers */


  /* Copy all lines for the discount */

  FOR l_qp_discount_lines_rec IN
			qp_discount_lines_cur (qp_from_discounts_rec.list_header_id)
  LOOP

  --Get New Discount Line Id
    SELECT qp_list_lines_s.nextval
    INTO   l_new_discount_line_id
    FROM   dual;

  --Insert Discount Line
    INSERT INTO qp_list_lines
    (
     list_line_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     program_application_id,
     program_id,
     program_update_date,
     request_id,
     list_header_id,
     list_line_type_code,
     start_date_active,
     end_date_active,
     automatic_flag,
     modifier_level_code,
     list_price,
     primary_uom_flag,
     inventory_item_id,
     organization_id,
     related_item_id,
     relationship_type_id,
     substitution_context,
     substitution_attribute,
     substitution_value,
     revision,
     revision_date,
     revision_reason_code,
     context,
     attribute1,
     attribute2,
     comments,
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
     price_break_type_code,
     percent_price,
     price_by_formula_id,
     number_effective_periods,
     effective_period_uom,
     arithmetic_operator,
     operand,
     override_flag,
     print_on_invoice_flag,
     rebate_transaction_type_code,
     estim_accrual_rate,
     generate_using_formula_id,
	reprice_flag,
     accrual_flag,
     pricing_group_sequence,
     incompatibility_grp_code,
     list_line_no,
     product_precedence,
     pricing_phase_id,
     expiration_period_start_date,
     number_expiration_periods,
     expiration_period_uom,
     expiration_date,
     estim_gl_value,
     accrual_conversion_rate,
     benefit_price_list_line_id,
     proration_type_code,
     benefit_qty,
     benefit_uom_code,
     charge_type_code,
     charge_subtype_code,
     benefit_limit,
     include_on_returns_flag,
     qualification_ind
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (
     l_new_discount_line_id,
     sysdate,
     p_user_id,
     sysdate,
     p_user_id,
     p_conc_login_id,
     p_conc_program_application_id,
     p_conc_program_id,
     sysdate,
     p_conc_request_id,
     l_new_discount_header_id,
     l_qp_discount_lines_rec.list_line_type_code,
     l_qp_discount_lines_rec.start_date_active,
	l_qp_discount_lines_rec.end_date_active,
     l_qp_discount_lines_rec.automatic_flag,
     l_qp_discount_lines_rec.modifier_level_code,
     l_qp_discount_lines_rec.list_price,
     l_qp_discount_lines_rec.primary_uom_flag,
     l_qp_discount_lines_rec.inventory_item_id,
     l_qp_discount_lines_rec.organization_id,
     l_qp_discount_lines_rec.related_item_id,
     l_qp_discount_lines_rec.relationship_type_id,
     l_qp_discount_lines_rec.substitution_context,
     l_qp_discount_lines_rec.substitution_attribute,
     l_qp_discount_lines_rec.substitution_value,
     l_qp_discount_lines_rec.revision,
     l_qp_discount_lines_rec.revision_date,
     l_qp_discount_lines_rec.revision_reason_code,
     l_qp_discount_lines_rec.context,
     l_qp_discount_lines_rec.attribute1,
     l_qp_discount_lines_rec.attribute2,
     l_qp_discount_lines_rec.comments,
     l_qp_discount_lines_rec.attribute3,
     l_qp_discount_lines_rec.attribute4,
     l_qp_discount_lines_rec.attribute5,
     l_qp_discount_lines_rec.attribute6,
     l_qp_discount_lines_rec.attribute7,
     l_qp_discount_lines_rec.attribute8,
     l_qp_discount_lines_rec.attribute9,
     l_qp_discount_lines_rec.attribute10,
     l_qp_discount_lines_rec.attribute11,
     l_qp_discount_lines_rec.attribute12,
     l_qp_discount_lines_rec.attribute13,
     l_qp_discount_lines_rec.attribute14,
     l_qp_discount_lines_rec.attribute15,
     l_qp_discount_lines_rec.price_break_type_code,
     l_qp_discount_lines_rec.percent_price,
     l_qp_discount_lines_rec.price_by_formula_id,
     l_qp_discount_lines_rec.number_effective_periods,
     l_qp_discount_lines_rec.effective_period_uom,
     l_qp_discount_lines_rec.arithmetic_operator,
     l_qp_discount_lines_rec.operand,
     l_qp_discount_lines_rec.override_flag,
     l_qp_discount_lines_rec.print_on_invoice_flag,
     l_qp_discount_lines_rec.rebate_transaction_type_code,
     l_qp_discount_lines_rec.estim_accrual_rate,
     l_qp_discount_lines_rec.generate_using_formula_id,
	l_qp_discount_lines_rec.reprice_flag,
     l_qp_discount_lines_rec.accrual_flag,
     l_qp_discount_lines_rec.pricing_group_sequence,
     l_qp_discount_lines_rec.incompatibility_grp_code,
     l_qp_discount_lines_rec.list_line_no,
     l_qp_discount_lines_rec.product_precedence,
     l_qp_discount_lines_rec.pricing_phase_id,
     l_qp_discount_lines_rec.expiration_period_start_date,
     l_qp_discount_lines_rec.number_expiration_periods,
     l_qp_discount_lines_rec.expiration_period_uom,
     l_qp_discount_lines_rec.expiration_date,
     l_qp_discount_lines_rec.estim_gl_value,
     l_qp_discount_lines_rec.accrual_conversion_rate,
     l_qp_discount_lines_rec.benefit_price_list_line_id,
     l_qp_discount_lines_rec.proration_type_code,
     l_qp_discount_lines_rec.benefit_qty,
     l_qp_discount_lines_rec.benefit_uom_code,
     l_qp_discount_lines_rec.charge_type_code,
     l_qp_discount_lines_rec.charge_subtype_code,
     l_qp_discount_lines_rec.benefit_limit,
     l_qp_discount_lines_rec.include_on_returns_flag,
     l_qp_discount_lines_rec.qualification_ind
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_new_discount_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
    );


    /*If the discount_line_rec is a Price Break Parent Line or Price Break Line
    then store the old and new discountlineid in a mapping-array for later use*/

    IF l_qp_discount_lines_rec.list_line_type_code = 'PBH' OR
	  Price_Break_Line(l_qp_discount_lines_rec.list_line_id)
    THEN
	  l_count := l_count + 1;
	  l_mapping_tbl(l_count).list_line_type_code :=
						 l_qp_discount_lines_rec.list_line_type_code;
       l_mapping_tbl(l_count).old_list_line_id :=
   					      l_qp_discount_lines_rec.list_line_id;
       l_mapping_tbl(l_count).new_list_line_id := l_new_discount_line_id;
    END IF;


    /* Copy the qp_pricing_attributes records for each discount line being
	  copied */

    FOR l_qp_pricing_attributes_rec IN qp_pricing_attributes_cur
					    (l_qp_discount_lines_rec.list_line_id)
					    -- basically the from_discount_list_line_id
    LOOP

      -- Get next pricing_attribute_id
      SELECT qp_pricing_attributes_s.nextval
      INTO   l_new_pricing_attribute_id
      FROM   dual;


    IF l_qp_pricing_attributes_rec.pricing_attribute_datatype = 'N'
    then

    BEGIN

	    l_pric_attr_value_from_number :=
	    qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_from);

	    l_pric_attr_value_to_number :=
	    qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;


      INSERT INTO qp_pricing_attributes
       (pricing_attribute_id,
  	   creation_date,
 	   created_by,
	   last_update_date,
	   last_updated_by,
 	   last_update_login,
 	   program_application_id,
 	   program_id,
 	   program_update_date,
 	   request_id,
 	   list_line_id,
	   list_header_id,
	   pricing_phase_id,
	   qualification_ind,
	   excluder_flag,
	   accumulate_flag,
 	   product_attribute_context,
 	   product_attribute,
 	   product_attr_value,
 	   product_uom_code,
 	   pricing_attribute_context,
 	   pricing_attribute,
 	   pricing_attr_value_from,
 	   pricing_attr_value_to,
 	   attribute_grouping_no,
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
        product_attribute_datatype,
        pricing_attribute_datatype,
        comparison_operator_code,
 	   pricing_attr_value_from_number,
 	   pricing_attr_value_to_number
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
      )
      VALUES
      (l_new_pricing_attribute_id,
  	 sysdate,
 	 p_user_id,
	 sysdate,
	 p_user_id,
 	 p_conc_login_id,
 	 p_conc_program_application_id,
 	 p_conc_program_id,
 	 sysdate,
 	 p_conc_request_id,
 	 l_new_discount_line_id, /* new discount line id */
	 l_new_discount_header_id,
	 l_qp_pricing_attributes_rec.pricing_phase_id,
	 l_qp_pricing_attributes_rec.qualification_ind,
	 l_qp_pricing_attributes_rec.excluder_flag,
	 l_qp_pricing_attributes_rec.accumulate_flag,
 	 l_qp_pricing_attributes_rec.product_attribute_context,
 	 l_qp_pricing_attributes_rec.product_attribute,
 	 l_qp_pricing_attributes_rec.product_attr_value,
 	 l_qp_pricing_attributes_rec.product_uom_code,
 	 l_qp_pricing_attributes_rec.pricing_attribute_context,
 	 l_qp_pricing_attributes_rec.pricing_attribute,
 	 l_qp_pricing_attributes_rec.pricing_attr_value_from,
 	 l_qp_pricing_attributes_rec.pricing_attr_value_to,
 	 l_qp_pricing_attributes_rec.attribute_grouping_no,
 	 l_qp_pricing_attributes_rec.context,
 	 l_qp_pricing_attributes_rec.attribute1,
 	 l_qp_pricing_attributes_rec.attribute2,
 	 l_qp_pricing_attributes_rec.attribute3,
 	 l_qp_pricing_attributes_rec.attribute4,
 	 l_qp_pricing_attributes_rec.attribute5,
 	 l_qp_pricing_attributes_rec.attribute6,
 	 l_qp_pricing_attributes_rec.attribute7,
 	 l_qp_pricing_attributes_rec.attribute8,
 	 l_qp_pricing_attributes_rec.attribute9,
 	 l_qp_pricing_attributes_rec.attribute10,
 	 l_qp_pricing_attributes_rec.attribute11,
 	 l_qp_pricing_attributes_rec.attribute12,
 	 l_qp_pricing_attributes_rec.attribute13,
 	 l_qp_pricing_attributes_rec.attribute14,
 	 l_qp_pricing_attributes_rec.attribute15,
      l_qp_pricing_attributes_rec.product_attribute_datatype,
      l_qp_pricing_attributes_rec.pricing_attribute_datatype,
      l_qp_pricing_attributes_rec.comparison_operator_code,
	 l_pric_attr_value_from_number,
	 l_pric_attr_value_to_number
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_new_pricing_attribute_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_new_discount_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
	 );

    END LOOP; /* For copying pricing attributes for each discount line */
-------------------bug 8326619--------------------------------
/* Copy all qualifiers for the discount and in case of the qualifier
         being the from-pricelist replace it with the new pricelist*/---Added for bug 8326619

      FOR l_qp_qualifiers_rec IN
                             qp_lin_qualifiers_cur(qp_from_discounts_rec.list_header_id)
      LOOP

        --Get new qualifier_id
        SELECT qp_qualifiers_s.nextval
        INTO   l_new_qualifier_id
        FROM   dual;

        IF  l_qp_qualifiers_rec.qualifier_attr_value =
                                               TO_CHAR(p_from_list_header_id) AND
            l_qp_qualifiers_rec.qualifier_context = p_context  AND
            l_qp_qualifiers_rec.qualifier_attribute = p_attribute
        THEN
          l_qp_qualifiers_rec.qualifier_attr_value :=
                                               TO_CHAR(p_new_list_header_id);
        END IF;

        BEGIN

             SELECT ACTIVE_FLAG, LIST_TYPE_CODE
             INTO   l_active_flag, l_list_type_code
             FROM   QP_LIST_HEADERS_B
             WHERE  LIST_HEADER_ID = l_new_discount_header_id;

         EXCEPTION
                WHEN OTHERS THEN
                      NULL;
         END;

        IF l_qp_qualifiers_rec.qualifier_datatype = 'N'
        then

        BEGIN

                l_qual_attr_value_from_number :=
                fnd_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);

                l_qual_attr_value_to_number :=
                fnd_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);

         EXCEPTION
                WHEN VALUE_ERROR THEN
                      NULL;
                WHEN OTHERS THEN
                      NULL;
         END;

         end if;

        --Insert new qualifier
        INSERT INTO qp_qualifiers
        (
         qualifier_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
            excluder_flag,
         comparison_operator_code,
         qualifier_context,
         qualifier_attribute,
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
         qualifier_rule_id,
         qualifier_grouping_no,
         qualifier_attr_value,
         list_header_id,
         list_line_id,
         created_from_rule_id,
         start_date_active,
         end_date_active,
         qualifier_precedence,
            qualifier_datatype,
            qualifier_attr_value_to,
            active_flag,
            list_type_code,
            qual_attr_value_from_number,
            qual_attr_value_to_number,
            search_ind,
            distinct_row_count,
            qualifier_group_cnt,
            header_quals_exist_flag,
	    qualify_hier_descendents_flag -- Added for TCA
	     --ENH Upgrade BOAPI for orig_sys...ref RAVI
	     ,ORIG_SYS_QUALIFIER_REF
	     ,ORIG_SYS_LINE_REF
	     ,ORIG_SYS_HEADER_REF
        )
        VALUES
        (
         l_new_qualifier_id,
         sysdate,
         p_user_id,
         sysdate,
         p_user_id,
         p_conc_login_id,
         p_conc_program_application_id,
         p_conc_program_id,
         sysdate,
         p_conc_request_id,
            l_qp_qualifiers_rec.excluder_flag,
         l_qp_qualifiers_rec.comparison_operator_code,
         l_qp_qualifiers_rec.qualifier_context,
         l_qp_qualifiers_rec.qualifier_attribute,
         l_qp_qualifiers_rec.context,
         l_qp_qualifiers_rec.attribute1,
         l_qp_qualifiers_rec.attribute2,
         l_qp_qualifiers_rec.attribute3,
         l_qp_qualifiers_rec.attribute4,
         l_qp_qualifiers_rec.attribute5,
         l_qp_qualifiers_rec.attribute6,
         l_qp_qualifiers_rec.attribute7,
         l_qp_qualifiers_rec.attribute8,
         l_qp_qualifiers_rec.attribute9,
         l_qp_qualifiers_rec.attribute10,
         l_qp_qualifiers_rec.attribute11,
         l_qp_qualifiers_rec.attribute12,
         l_qp_qualifiers_rec.attribute13,
         l_qp_qualifiers_rec.attribute14,
         l_qp_qualifiers_rec.attribute15,
         l_qp_qualifiers_rec.qualifier_rule_id,
         l_qp_qualifiers_rec.qualifier_grouping_no,
         l_qp_qualifiers_rec.qualifier_attr_value,
         l_new_discount_header_id,
         l_new_discount_line_id,
         --l_qp_qualifiers_rec.list_line_id,       changed for bug 8326619
         l_qp_qualifiers_rec.created_from_rule_id,
         l_qp_qualifiers_rec.start_date_active,
         l_qp_qualifiers_rec.end_date_active,
         l_qp_qualifiers_rec.qualifier_precedence,
            l_qp_qualifiers_rec.qualifier_datatype,
            l_qp_qualifiers_rec.qualifier_attr_value_to,
            l_active_flag,
            l_list_type_code,
         l_qual_attr_value_from_number,
         l_qual_attr_value_to_number,
            l_qp_qualifiers_rec.search_ind,
            l_qp_qualifiers_rec.distinct_row_count,
            l_qp_qualifiers_rec.qualifier_group_cnt,
            l_qp_qualifiers_rec.header_quals_exist_flag,
		l_qp_qualifiers_rec.qualify_hier_descendents_flag -- Added for TCA
	     --ENH Upgrade BOAPI for orig_sys...ref RAVI
	     ,to_char(l_new_qualifier_id)
	     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_qp_qualifiers_rec.list_line_id)
	     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
        );

      END LOOP; /* For copying qualifiers */---Added for bug 8326619
-------------------bug 8326619--------------------------------
  END LOOP; /* For copying discount lines*/

  /* Copy qp_rltd_modifiers for the Price Break Parent list_lines chosen
   above which are stored in the mapping table */

  IF l_mapping_tbl.COUNT > 0 THEN
    FOR l_count IN 1..l_mapping_tbl.COUNT
    LOOP

      IF l_mapping_tbl(l_count).list_line_type_code = 'PBH' THEN

          FOR l_qp_rltd_modifiers_rec IN qp_rltd_modifiers_cur(
					  l_mapping_tbl(l_count).old_list_line_id)
          LOOP

	       SELECT qp_rltd_modifiers_s.nextval
	       INTO   l_new_rltd_modifier_id
	       FROM   dual;

             l_new_from_id := Get_New_Id(
						l_qp_rltd_modifiers_rec.from_rltd_modifier_id,
				          l_mapping_tbl);
             l_new_to_id   := Get_New_Id(
						l_qp_rltd_modifiers_rec.to_rltd_modifier_id,
				          l_mapping_tbl);
            INSERT INTO qp_rltd_modifiers
	       (creation_date,
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
             rltd_modifier_id,
             rltd_modifier_grp_no,
             from_rltd_modifier_id,
             to_rltd_modifier_id,
             rltd_modifier_grp_type
	       )
	       VALUES
	       (sysdate,
	        p_user_id,
	        sysdate,
	        p_user_id,
	        p_conc_login_id,
	        l_qp_rltd_modifiers_rec.context,
	        l_qp_rltd_modifiers_rec.attribute1,
	        l_qp_rltd_modifiers_rec.attribute2,
	        l_qp_rltd_modifiers_rec.attribute3,
	        l_qp_rltd_modifiers_rec.attribute4,
	        l_qp_rltd_modifiers_rec.attribute5,
	        l_qp_rltd_modifiers_rec.attribute6,
	        l_qp_rltd_modifiers_rec.attribute7,
	        l_qp_rltd_modifiers_rec.attribute8,
	        l_qp_rltd_modifiers_rec.attribute9,
	        l_qp_rltd_modifiers_rec.attribute10,
	        l_qp_rltd_modifiers_rec.attribute11,
	        l_qp_rltd_modifiers_rec.attribute12,
	        l_qp_rltd_modifiers_rec.attribute13,
	        l_qp_rltd_modifiers_rec.attribute14,
	        l_qp_rltd_modifiers_rec.attribute15,
	        l_new_rltd_modifier_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_no,
		   l_new_from_id,
		   l_new_to_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_type
	       );

        END LOOP; -- Loop through rltd modifiers records
	 END IF; --For lines that are Parent Price Break lines

    END LOOP; --Loop through l_mapping_tbl
  END IF; --If l_mapping_tbl has any records

END LOOP; /* for copying discount headers*/
x_new_discount_header_id:=l_new_discount_header_id; --for bug 8326619
END Copy_Discounts;



PROCEDURE Copy_Price_List
(
-- p_api_version_number   IN	NUMBER,
-- p_init_msg_list        IN	VARCHAR2 := FND_API.G_FALSE,
-- p_commit		         IN	VARCHAR2 := FND_API.G_FALSE,
-- x_return_status	    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
-- x_msg_count		    OUT NOCOPY /* file.sql.39 change */	NUMBER,
-- x_msg_data		    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_from_list_header_id  IN    NUMBER,
 p_new_price_list_name  IN    VARCHAR2,
 p_description          IN 	VARCHAR2,
 p_start_date_active    IN    VARCHAR2, --DATE,  2752276
 p_end_date_active      IN    VARCHAR2, --DATE,  2752276
 p_discount_flag        IN 	VARCHAR2,
 p_segment1_lohi        IN	VARCHAR2,
 p_segment2_lohi        IN	VARCHAR2,
 p_segment3_lohi        IN	VARCHAR2,
 p_segment4_lohi        IN	VARCHAR2,
 p_segment5_lohi        IN	VARCHAR2,
 p_segment6_lohi        IN	VARCHAR2,
 p_segment7_lohi        IN	VARCHAR2,
 p_segment8_lohi        IN	VARCHAR2,
 p_segment9_lohi        IN	VARCHAR2,
 p_segment10_lohi       IN	VARCHAR2,
 p_segment11_lohi       IN	VARCHAR2,
 p_segment12_lohi       IN	VARCHAR2,
 p_segment13_lohi       IN	VARCHAR2,
 p_segment14_lohi       IN	VARCHAR2,
 p_segment15_lohi       IN	VARCHAR2,
 p_segment16_lohi       IN	VARCHAR2,
 p_segment17_lohi       IN	VARCHAR2,
 p_segment18_lohi       IN	VARCHAR2,
 p_segment19_lohi       IN	VARCHAR2,
 p_segment20_lohi       IN	VARCHAR2,
-- p_org_id			    IN	NUMBER,
 p_category_id          IN    NUMBER,
 p_category_set_id		IN	NUMBER,	 	-- bug 4127037
 p_rounding_factor      IN 	NUMBER,
 p_effective_dates_flag IN 	VARCHAR2,
--added for moac bug 4673872
 p_global_flag IN VARCHAR2,
 p_org_id IN NUMBER
)
IS

--l_api_version_number		CONSTANT	NUMBER		:= 1.0;
--l_api_name				CONSTANT	VARCHAR2(30)	:= 'Copy_Price_List';
--l_return_status			VARCHAR2(1);
--l_msg_count				NUMBER;
--l_msg_buf					VARCHAR2(2000);
l_conc_request_id			NUMBER := -1;
l_conc_program_application_id	NUMBER := -1;
l_conc_program_id			NUMBER := -1;
l_conc_login_id		   	NUMBER := -1;
l_user_id					NUMBER := -1;
l_new_list_header_id          NUMBER;
l_new_discount_header_id      NUMBER;  -- for bug 8326619
l_new_qualifier_id            NUMBER;
l_new_list_line_id            NUMBER;
l_new_pricing_attribute_id    NUMBER;
l_new_rltd_modifier_id        NUMBER;
x_result                      VARCHAR2(1);
insert_flag varchar2(1);
l_cnt number:=0;
l_line_id number:=null;
l_min_list_line_id NUMBER;
l_max_list_line_id NUMBER;



TYPE qp_list_lines_rec IS RECORD (
list_line_id				QP_LIST_LINES.list_line_id%TYPE,
creation_date				QP_LIST_LINES.creation_date%TYPE,
created_by				QP_LIST_LINES.created_by%TYPE,
last_update_date			QP_LIST_LINES.last_update_date%TYPE,
last_updated_by			QP_LIST_LINES.last_updated_by%TYPE,
last_update_login			QP_LIST_LINES.last_update_login%TYPE,
program_application_id		QP_LIST_LINES.program_application_id%TYPE,
program_id				QP_LIST_LINES.program_id%TYPE,
program_update_date			QP_LIST_LINES.program_update_date%TYPE,
request_id				QP_LIST_LINES.request_id%TYPE,
list_header_id				QP_LIST_LINES.list_header_id%TYPE,
list_line_type_code			QP_LIST_LINES.list_line_type_code%TYPE,
automatic_flag				QP_LIST_LINES.automatic_flag%TYPE,
modifier_level_code			QP_LIST_LINES.modifier_level_code%TYPE,
list_price				QP_LIST_LINES.list_price%TYPE,
primary_uom_flag			QP_LIST_LINES.primary_uom_flag%TYPE,
inventory_item_id			QP_LIST_LINES.inventory_item_id%TYPE,
organization_id			QP_LIST_LINES.organization_id%TYPE,
related_item_id			QP_LIST_LINES.related_item_id%TYPE,
relationship_type_id		QP_LIST_LINES.relationship_type_id%TYPE,
substitution_context		QP_LIST_LINES.substitution_context%TYPE,
substitution_attribute		QP_LIST_LINES.substitution_attribute%TYPE,
substitution_value			QP_LIST_LINES.substitution_value%TYPE,
revision					QP_LIST_LINES.revision%TYPE,
revision_date				QP_LIST_LINES.revision_date%TYPE,
revision_reason_code		QP_LIST_LINES.revision_reason_code%TYPE,
context					QP_LIST_LINES.context%TYPE,
attribute1				QP_LIST_LINES.attribute1%TYPE,
attribute2				QP_LIST_LINES.attribute2%TYPE,
comments					QP_LIST_LINES.comments%TYPE,
attribute3				QP_LIST_LINES.attribute3%TYPE,
attribute4				QP_LIST_LINES.attribute4%TYPE,
attribute5				QP_LIST_LINES.attribute5%TYPE,
attribute6				QP_LIST_LINES.attribute6%TYPE,
attribute7				QP_LIST_LINES.attribute7%TYPE,
attribute8				QP_LIST_LINES.attribute8%TYPE,
attribute9				QP_LIST_LINES.attribute9%TYPE,
attribute10				QP_LIST_LINES.attribute10%TYPE,
attribute11				QP_LIST_LINES.attribute11%TYPE,
attribute12				QP_LIST_LINES.attribute12%TYPE,
attribute13				QP_LIST_LINES.attribute13%TYPE,
attribute14				QP_LIST_LINES.attribute14%TYPE,
attribute15				QP_LIST_LINES.attribute15%TYPE,
price_break_type_code		QP_LIST_LINES.price_break_type_code%TYPE,
percent_price				QP_LIST_LINES.percent_price%TYPE,
price_by_formula_id			QP_LIST_LINES.price_by_formula_id%TYPE,
number_effective_periods		QP_LIST_LINES.number_effective_periods%TYPE,
effective_period_uom		QP_LIST_LINES.effective_period_uom%TYPE,
arithmetic_operator			QP_LIST_LINES.arithmetic_operator%TYPE,
operand					QP_LIST_LINES.operand%TYPE,
override_flag				QP_LIST_LINES.override_flag%TYPE,
print_on_invoice_flag		QP_LIST_LINES.print_on_invoice_flag%TYPE,
rebate_transaction_type_code	QP_LIST_LINES.rebate_transaction_type_code%TYPE,
estim_accrual_rate			QP_LIST_LINES.estim_accrual_rate%TYPE,
generate_using_formula_id	QP_LIST_LINES.generate_using_formula_id%TYPE,
start_date_active			QP_LIST_LINES.start_date_active%TYPE,
end_date_active			QP_LIST_LINES.end_date_active%TYPE,
reprice_flag				QP_LIST_LINES.reprice_flag%TYPE,
accrual_flag                  QP_LIST_LINES.accrual_flag%TYPE,
pricing_group_sequence        QP_LIST_LINES.pricing_group_sequence%TYPE,
incompatibility_grp_code      QP_LIST_LINES.incompatibility_grp_code%TYPE,
list_line_no                  QP_LIST_LINES.list_line_no%TYPE,
product_precedence            QP_LIST_LINES.product_precedence%TYPE,
pricing_phase_id              QP_LIST_LINES.pricing_phase_id%TYPE,
expiration_period_start_date  QP_LIST_LINES.expiration_period_start_date%TYPE,
number_expiration_periods     QP_LIST_LINES.number_expiration_periods%TYPE,
expiration_period_uom         QP_LIST_LINES.expiration_period_uom%TYPE,
expiration_date               QP_LIST_LINES.expiration_date%TYPE,
estim_gl_value                QP_LIST_LINES.estim_gl_value%TYPE,
accrual_conversion_rate       QP_LIST_LINES.accrual_conversion_rate%TYPE,
benefit_price_list_line_id    QP_LIST_LINES.benefit_price_list_line_id%TYPE,
proration_type_code           QP_LIST_LINES.proration_type_code%TYPE,
benefit_qty                   QP_LIST_LINES.benefit_qty%TYPE,
benefit_uom_code              QP_LIST_LINES.benefit_uom_code%TYPE,
charge_type_code              QP_LIST_LINES.charge_type_code%TYPE,
charge_subtype_code           QP_LIST_LINES.charge_subtype_code%TYPE,
benefit_limit                 QP_LIST_LINES.benefit_limit%TYPE,
include_on_returns_flag       QP_LIST_LINES.include_on_returns_flag%TYPE,
qualification_ind             QP_LIST_LINES.qualification_ind%TYPE,
recurring_value               QP_LIST_LINES.recurring_value%TYPE, -- block pricing
continuous_price_break_flag       QP_LIST_LINES.continuous_price_break_flag%TYPE
							--Continuous Price Breaks
);

l_non_cont_pbh_id_tbl         QP_UTIL.price_brk_attr_val_tab; --Continuous Price Breaks
l_non_cont_count              NUMBER := 0; --Continuous Price Breaks
l_return_status               VARCHAR2(1);

l_mapping_tbl                 mapping_tbl;

l_select_stmt				VARCHAR2(9000);
l_qp_list_lines_rec		     qp_list_lines_rec;
l_context					VARCHAR2(30);
l_attribute				VARCHAR2(30);

l_exists                      NUMBER := 0;
l_count                       NUMBER := 0;
l_new_from_id                 NUMBER;
l_new_to_id                   NUMBER;

l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;

l_list_type_code VARCHAR2(30) := '';
v_list_type_code VARCHAR2(30) := '';
v_pte_code VARCHAR2(30) := '';
v_source_system_code VARCHAR2(30) := '';
l_active_flag VARCHAR2(1) := '';
l_qual_attr_value_from_number NUMBER := NULL;
l_qual_attr_value_to_number NUMBER := NULL;

TYPE lines_cur_typ IS REF CURSOR;
qp_list_lines_cv 		     lines_cur_typ;

CURSOR qp_pricing_attributes_cur(p_from_list_line_id NUMBER)
IS
    SELECT *
    FROM   qp_pricing_attributes
    WHERE  list_line_id = p_from_list_line_id;

 /* First part of cursor qp_qualifiers_cur selects qualifiers while the second part
    selects secondary price list */

CURSOR qp_qualifiers_cur(p_from_list_header_id NUMBER, p_context VARCHAR2,
					p_attribute VARCHAR2, p_discount_flag VARCHAR2)
IS
    SELECT *
    FROM   qp_qualifiers q
    WHERE (q.list_header_id = p_from_list_header_id AND
           q.qualifier_attribute <> p_attribute AND     --Added for 2200425
          Exists (Select Null
                --fix for bug 4673872
                From   qp_list_headers_all_b a
                Where  a.list_header_id = p_from_list_header_id
                And    a.list_type_code = 'PRL'
                   )
           )
           OR
          (q.qualifier_context = p_context AND
           q.qualifier_attribute = p_attribute AND
           q.qualifier_attr_value = TO_CHAR(p_from_list_header_id) AND
           --fix for bug 4673872
           EXISTS (select null from qp_list_headers_all_b a                    --Added for 2200425
           where a.list_header_id =q.list_header_id
           And    a.list_type_code = 'PRL')
/*  and									--Commented out for 2200425
          Exists (Select Null
                From   qp_list_headers_b a
                Where  a.list_header_id = p_from_list_header_id
                And    a.list_type_code = 'PRL'
                   )*/
          );

CURSOR qp_rltd_modifiers_cur(a_list_line_id NUMBER)
IS
    SELECT *
    FROM   qp_rltd_modifiers
    WHERE  from_rltd_modifier_id = a_list_line_id;

BEGIN

IF MO_GLOBAL.get_access_mode is null THEN
    MO_GLOBAL.Init('QP');
END IF;--MO_GLOBAL

l_conc_request_id := FND_GLOBAL.CONC_REQUEST_ID;
l_conc_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
l_user_id         := FND_GLOBAL.USER_ID;
l_conc_login_id   := FND_GLOBAL.CONC_LOGIN_ID;
l_conc_program_application_id := FND_GLOBAL.PROG_APPL_ID;

-- Standard call to check for API compatibility

/*IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                    p_api_version_number,
                                    l_api_name,
                                    G_PKG_NAME
                                   )
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
*/

-- Initialize message list if p_init_msg_list is set to TRUE;

/*IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
END IF;*/

-- Initialize x_return_status

/*x_return_status := FND_API.G_RET_STS_SUCCESS;*/

--Check if a pricelist with requested new price list name already exists

SELECT COUNT(*) INTO l_exists
--fix for bug 4673872
FROM   qp_secu_list_headers_vl plh
/* WHERE  plh.list_type_code = 'PRL' */
/* Commented the above line for bug 1343801 */
WHERE  plh.list_type_code in ('PRL' , 'AGR')
AND    plh.name = p_new_price_list_name;

IF (l_exists > 0) THEN
-- Error Message that a Price List with the name already exists
NULL;
END IF;


/** Following code inserts price list header information **/

-- Get next list_header_id

SELECT qp_list_headers_b_s.nextval
INTO   l_new_list_header_id
FROM   dual;

-- Insert Price List Header information

INSERT INTO qp_list_headers_all_b
(
 list_header_id,
 creation_date,
 created_by,
 last_update_date,
 last_updated_by,
 last_update_login,
 program_application_id,
 program_id,
 program_update_date,
 request_id,
 list_type_code,
 start_date_active,
 end_date_active,
 automatic_flag,
-- exclusive_flag,
 currency_code,
 rounding_factor,
 ship_method_code,
 freight_terms_code,
 terms_id,
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
 comments,
 discount_lines_flag,
 gsa_indicator,
 prorate_flag,
 source_system_code,
 active_flag,
 parent_list_header_id,
 start_date_active_first,
 end_date_active_first,
 active_date_first_type,
 start_date_active_second,
 end_date_active_second,
 active_date_second_type,
 ask_for_flag,
 currency_header_id,   -- Multi-Currency SunilPandey
 pte_code,  -- Attribute Manager, Giri
 global_flag,          -- sfiresto 2853767
 orig_org_id          -- sfiresto 2853767
 --ENH Upgrade BOAPI for orig_sys...ref RAVI
 ,ORIG_SYSTEM_HEADER_REF
)

SELECT
 l_new_list_header_id,
 sysdate,
 l_user_id,
 sysdate,
 l_user_id,
 l_conc_login_id,
 l_conc_program_application_id,
 l_conc_program_id,
 sysdate,
 l_conc_request_id,
 list_type_code, /* can be changed to 'PRL' but is implicit */
 fnd_date.canonical_to_date(p_start_date_active),	--2735911
 fnd_date.canonical_to_date(p_end_date_active),		--2735911
 automatic_flag,
-- exclusive_flag,
 currency_code,
 rounding_factor,
 ship_method_code,
 freight_terms_code,
 terms_id,
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
 comments,
 discount_lines_flag,
 gsa_indicator,
 prorate_flag,
 source_system_code,
 active_flag,
 parent_list_header_id,
 start_date_active_first,
 end_date_active_first,
 active_date_first_type,
 start_date_active_second,
 end_date_active_second,
 active_date_second_type,
 ask_for_flag,
 currency_header_id,  -- Multi-Currency SunilPandey
 pte_code,  -- Attribute Manager, Giri
 p_global_flag,          -- sfiresto 2853767
 p_org_id          -- sfiresto 2853767
 --ENH Upgrade BOAPI for orig_sys...ref RAVI
 --,nvl(ORIG_SYSTEM_HEADER_REF,to_char(l_new_list_header_id))
 -- Bug 5201918
 ,to_char(list_header_id)  --7309992

--fix for bug 4673872
FROM  qp_list_headers_all_b
WHERE list_header_id = p_from_list_header_id;

  -- Object Security - sfiresto

  SELECT list_type_code,pte_code,source_system_code
    INTO v_list_type_code,v_pte_code,v_source_system_code
    --fix for bug 4673872
    FROM qp_list_headers_all_b
    WHERE list_header_id = p_from_list_header_id;

  IF v_list_type_code = 'AGR' THEN
    QP_security.create_default_grants( p_instance_type => QP_security.G_AGREEMENT_OBJECT,
                                       p_instance_pk1  => l_new_list_header_id,
                                       x_return_status => x_result);

  ELSE
    QP_security.create_default_grants( p_instance_type => QP_security.G_PRICELIST_OBJECT,
                                       p_instance_pk1  => l_new_list_header_id,
                                       x_return_status => x_result);
  END IF;
  -- End addition for Object Security



INSERT INTO qp_list_headers_tl
(last_update_login,
 name,
 description,
 creation_date,
 created_by,
 last_update_date,
 last_updated_by,
 list_header_id,
 language,
 source_lang,
 version_no
)
SELECT
l_conc_login_id,
p_new_price_list_name,
p_description,
sysdate,
l_user_id,
sysdate,
l_user_id,
l_new_list_header_id,
l.language_code,
userenv('LANG'),
'1'

FROM  fnd_languages l
WHERE l.installed_flag IN ('I', 'B')
AND   NOT EXISTS (SELECT NULL
			   FROM   qp_list_headers_tl t
			   WHERE  t.list_header_id = l_new_list_header_id
			   AND    t.language  = l.language_code);


/* Copy all qualifiers having a code of PRICE_LIST_ID and price_list_id =
   from_list_header_id. This will copy secondary list as well as
   Self-Qualifier for the 'from' price list */

--Added the IF condition below for Attrmrg_Installed = 'Y' for bug 2434362.
IF QP_UTIL.Attrmgr_Installed = 'Y' THEN
  QP_UTIL.Get_Context_Attribute('PRICE_LIST', l_context, l_attribute);
ELSE
  QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);
END IF;

FOR l_qp_qualifiers_rec IN qp_qualifiers_cur(p_from_list_header_id, l_context,
									l_attribute, p_discount_flag)
LOOP

  --Get new qualifier_id
  SELECT qp_qualifiers_s.nextval
  INTO   l_new_qualifier_id
  FROM   dual;

  --To associate newly copied qualifiers (including secondary pricelists)
  --to the new price list
  IF p_from_list_header_id = l_qp_qualifiers_rec.list_header_id THEN
   l_qp_qualifiers_rec.list_header_id := l_new_list_header_id;
  END IF;

  --If From PriceList is  Self-Qualifier
  IF  l_qp_qualifiers_rec.qualifier_context   = l_context   AND
	 l_qp_qualifiers_rec.qualifier_attribute = l_attribute AND
	 l_qp_qualifiers_rec.qualifier_attr_value = TO_CHAR(p_from_list_header_id)
  THEN
    l_qp_qualifiers_rec.qualifier_attr_value := TO_CHAR(l_new_list_header_id);
  END IF;

    BEGIN

	 SELECT ACTIVE_FLAG, LIST_TYPE_CODE
	 INTO   l_active_flag, l_list_type_code
         --fix for bug 4673872
	 FROM   QP_LIST_HEADERS_ALL_B
	 WHERE  LIST_HEADER_ID = l_qp_qualifiers_rec.list_header_id;

     EXCEPTION
	    WHEN OTHERS THEN
		  NULL;
     END;

    IF l_qp_qualifiers_rec.qualifier_datatype = 'N'
    then

    BEGIN

	    l_qual_attr_value_from_number :=
	    qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);

	    l_qual_attr_value_to_number :=
	    qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;

  --Insert into qp_qualifiers
  INSERT INTO qp_qualifiers
  (
   qualifier_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   program_application_id,
   program_id,
   program_update_date,
   request_id,
   excluder_flag,
   comparison_operator_code,
   qualifier_context,
   qualifier_attribute,
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
   qualifier_rule_id,
   qualifier_grouping_no,
   qualifier_attr_value,
   list_header_id,
   list_line_id,
   created_from_rule_id,
   start_date_active,
   end_date_active,
   qualifier_precedence,
   qualifier_datatype,
   qualifier_attr_value_to,
   active_flag,
   list_type_code,
   qual_attr_value_from_number,
   qual_attr_value_to_number,
   search_ind,
   distinct_row_count,
   qualifier_group_cnt,
   header_quals_exist_flag,
  qualify_hier_descendents_flag -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
  )
  VALUES
  (
   l_new_qualifier_id,
   sysdate,
   l_user_id,
   sysdate,
   l_user_id,
   l_conc_login_id,
   l_conc_program_application_id,
   l_conc_program_id,
   sysdate,
   l_conc_request_id,
   l_qp_qualifiers_rec.excluder_flag,
   l_qp_qualifiers_rec.comparison_operator_code,
   l_qp_qualifiers_rec.qualifier_context,
   l_qp_qualifiers_rec.qualifier_attribute,
   l_qp_qualifiers_rec.context,
   l_qp_qualifiers_rec.attribute1,
   l_qp_qualifiers_rec.attribute2,
   l_qp_qualifiers_rec.attribute3,
   l_qp_qualifiers_rec.attribute4,
   l_qp_qualifiers_rec.attribute5,
   l_qp_qualifiers_rec.attribute6,
   l_qp_qualifiers_rec.attribute7,
   l_qp_qualifiers_rec.attribute8,
   l_qp_qualifiers_rec.attribute9,
   l_qp_qualifiers_rec.attribute10,
   l_qp_qualifiers_rec.attribute11,
   l_qp_qualifiers_rec.attribute12,
   l_qp_qualifiers_rec.attribute13,
   l_qp_qualifiers_rec.attribute14,
   l_qp_qualifiers_rec.attribute15,
   l_qp_qualifiers_rec.qualifier_rule_id,
   l_qp_qualifiers_rec.qualifier_grouping_no,
   l_qp_qualifiers_rec.qualifier_attr_value,
   l_qp_qualifiers_rec.list_header_id,
   l_qp_qualifiers_rec.list_line_id,
   l_qp_qualifiers_rec.created_from_rule_id,
   l_qp_qualifiers_rec.start_date_active,
   l_qp_qualifiers_rec.end_date_active,
   l_qp_qualifiers_rec.qualifier_precedence,
   l_qp_qualifiers_rec.qualifier_datatype,
   l_qp_qualifiers_rec.qualifier_attr_value_to,
   l_active_flag,
   l_list_type_code,
   l_qual_attr_value_from_number,
   l_qual_attr_value_to_number,
   l_qp_qualifiers_rec.search_ind,
   l_qp_qualifiers_rec.distinct_row_count,
   l_qp_qualifiers_rec.qualifier_group_cnt,
   l_qp_qualifiers_rec.header_quals_exist_flag,
   l_qp_qualifiers_rec.qualify_hier_descendents_flag -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_new_qualifier_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_qp_qualifiers_rec.list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_qp_qualifiers_rec.list_header_id)
  );


END LOOP;

/* If p_discount_flag = 'Y' then Copy Discounts */

IF  p_discount_flag = 'Y' THEN

  Copy_Discounts(p_from_list_header_id, l_new_list_header_id,
			  l_context, l_attribute, l_user_id,
			  l_conc_login_id, l_conc_program_application_id,
			  l_conc_program_id, l_conc_request_id, l_new_discount_header_id);  ---Added 1 more parameter for bug 8326619);

END IF;


/** Following code inserts price list lines information **/

  --copy only price list lines

  /* Need to copy only those price list lines whose end-date is not less than
  sysdate */

  l_select_stmt :=
   'SELECT
      	q.list_line_id,
     	q.creation_date,
     	q.created_by,
     	q.last_update_date,
     	q.last_updated_by,
     	q.last_update_login,
     	q.program_application_id,
     	q.program_id,
     	q.program_update_date,
     	q.request_id,
     	q.list_header_id,
     	q.list_line_type_code,
     	q.automatic_flag,
     	q.modifier_level_code,
     	q.list_price,
     	q.primary_uom_flag,
     	q.inventory_item_id,
     	q.organization_id,
     	q.related_item_id,
     	q.relationship_type_id,
     	q.substitution_context,
     	q.substitution_attribute,
     	q.substitution_value,
     	q.revision,
     	q.revision_date,
     	q.revision_reason_code,
     	q.context,
     	q.attribute1,
     	q.attribute2,
     	q.comments,
     	q.attribute3,
     	q.attribute4,
     	q.attribute5,
     	q.attribute6,
     	q.attribute7,
     	q.attribute8,
     	q.attribute9,
     	q.attribute10,
     	q.attribute11,
     	q.attribute12,
     	q.attribute13,
     	q.attribute14,
     	q.attribute15,
     	q.price_break_type_code,
     	q.percent_price,
     	q.price_by_formula_id,
     	q.number_effective_periods,
     	q.effective_period_uom,
     	q.arithmetic_operator,
     	q.operand,
     	q.override_flag,
     	q.print_on_invoice_flag,
     	q.rebate_transaction_type_code,
     	q.estim_accrual_rate,
     	q.generate_using_formula_id,
     	q.start_date_active,
     	q.end_date_active,
		q.reprice_flag,
          q.accrual_flag,
          q.pricing_group_sequence,
          q.incompatibility_grp_code,
          q.list_line_no,
          q.product_precedence,
          q.pricing_phase_id,
          q.expiration_period_start_date,
          q.number_expiration_periods,
          q.expiration_period_uom,
          q.expiration_date,
          q.estim_gl_value,
          q.accrual_conversion_rate,
          q.benefit_price_list_line_id,
          q.proration_type_code,
          q.benefit_qty,
          q.benefit_uom_code,
          q.charge_type_code,
          q.charge_subtype_code,
          q.benefit_limit,
          q.include_on_returns_flag,
          q.qualification_ind,
          q.recurring_value, -- block pricing
	  q.continuous_price_break_flag --Continuous Price Breaks

    FROM   qp_list_lines q
    WHERE  q.list_header_id = :frm
    AND   (q.end_date_active IS NULL OR  trunc(q.end_date_active) >= trunc(sysdate))   --Modified by dhgupta for 2100785
    AND    q.list_line_id IN
    (SELECT DISTINCT a.list_line_id
	FROM   qp_pricing_attributes a
	WHERE  a.list_line_id = q.list_line_id ';

IF (nvl(p_category_id, 0) <> 0 OR nvl(p_category_set_id, 0) <> 0) -- bug 4127037
OR (p_segment1_lohi <> ''''' AND ''''') OR (p_segment2_lohi <> ''''' AND ''''')
OR (p_segment3_lohi <> ''''' AND ''''') OR (p_segment4_lohi <> ''''' AND ''''')
OR (p_segment5_lohi <> ''''' AND ''''') OR (p_segment6_lohi <> ''''' AND ''''')
OR (p_segment7_lohi <> ''''' AND ''''') OR (p_segment8_lohi <> ''''' AND ''''')
OR (p_segment9_lohi <> ''''' AND ''''') OR (p_segment10_lohi <> ''''' AND ''''')
OR (p_segment11_lohi <> ''''' AND ''''')
OR (p_segment12_lohi <> ''''' AND ''''')
OR (p_segment13_lohi <> ''''' AND ''''')
OR (p_segment14_lohi <> ''''' AND ''''')
OR (p_segment15_lohi <> ''''' AND ''''')
OR (p_segment16_lohi <> ''''' AND ''''')
OR (p_segment17_lohi <> ''''' AND ''''')
OR (p_segment18_lohi <> ''''' AND ''''')
OR (p_segment19_lohi <> ''''' AND ''''')
OR (p_segment20_lohi <> ''''' AND ''''') THEN
/* Commented the following statement and replaced it with a new statement to fix the bug 1586265 */
/*
   l_select_stmt := l_select_stmt ||
    'AND    TO_NUMBER(a.product_attr_value) IN
		 (SELECT  inventory_item_id
		  FROM 	mtl_system_items m
		  WHERE   (m.inventory_item_id = TO_NUMBER(a.product_attr_value)) ';
		  */

   l_select_stmt := l_select_stmt ||
    'AND a.product_attribute_context = ''ITEM''
     AND a.product_attribute = ''PRICING_ATTRIBUTE1''
     AND EXISTS
	  (SELECT ''X''
	   FROM  mtl_system_items m
	   WHERE  (m.inventory_item_id = TO_NUMBER(a.product_attr_value)) ';


   IF (p_segment1_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment1   BETWEEN ' || p_segment1_lohi || ') ';
   END IF;

   IF (p_segment2_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment2   BETWEEN ' || p_segment2_lohi || ') ';
   END IF;

   IF (p_segment3_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment3   BETWEEN ' || p_segment3_lohi || ') ';
   END IF;

   IF (p_segment4_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment4   BETWEEN ' || p_segment4_lohi || ') ';
   END IF;

   IF (p_segment5_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment5   BETWEEN ' || p_segment5_lohi || ') ';
   END IF;

   IF (p_segment6_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment6   BETWEEN ' || p_segment6_lohi || ') ';
   END IF;

   IF (p_segment7_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment7   BETWEEN ' || p_segment7_lohi || ') ';
   END IF;

   IF (p_segment8_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment8   BETWEEN ' || p_segment8_lohi || ') ';
   END IF;

   IF (p_segment9_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment9   BETWEEN ' || p_segment9_lohi || ') ';
   END IF;

   IF (p_segment10_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment10   BETWEEN ' || p_segment10_lohi || ') ';
   END IF;

   IF (p_segment11_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment10   BETWEEN ' || p_segment11_lohi || ') ';
   END IF;

   IF (p_segment12_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment12   BETWEEN ' || p_segment12_lohi || ') ';
   END IF;

   IF (p_segment13_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment13   BETWEEN ' || p_segment13_lohi || ') ';
   END IF;

   IF (p_segment14_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment14   BETWEEN ' || p_segment14_lohi || ') ';
   END IF;

   IF (p_segment15_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment15   BETWEEN ' || p_segment15_lohi || ') ';
   END IF;

   IF (p_segment16_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment16   BETWEEN ' || p_segment16_lohi || ') ';
   END IF;

   IF (p_segment17_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment17   BETWEEN ' || p_segment17_lohi || ') ';
   END IF;

   IF (p_segment18_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment18   BETWEEN ' || p_segment18_lohi || ') ';
   END IF;

   IF (p_segment19_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment19   BETWEEN ' || p_segment19_lohi || ') ';
   END IF;

   IF (p_segment20_lohi <> ''''' AND ''''') THEN
     l_select_stmt := l_select_stmt ||
           'AND    (m.segment20   BETWEEN ' || p_segment20_lohi || ') ';
   END IF;

   -- begin fix bug 4127037
   -- debug
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>category_set_id: '||nvl(p_category_set_id, 0));
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>category_id: '||nvl(p_category_id, 0));

   IF  ( nvl(p_category_id, 0) <> 0 AND nvl(p_category_set_id, 0) <> 0) THEN
     l_select_stmt := l_select_stmt ||
		 'AND    m.inventory_item_id IN
		 ( SELECT ic.inventory_item_id
		   FROM   mtl_item_categories ic
		   WHERE  ic.inventory_item_id = m.inventory_item_id
		   AND    ic.organization_id   = m.organization_id
		   AND    (ic.category_id  = :category_id or ic.category_id in ( select parent_id
    FROM   eni_denorm_hierarchies
    WHERE  child_id = :category_id and
           organization_id = ic.organization_id and
           exists (select ''Y'' from QP_SOURCESYSTEM_FNAREA_MAP A, qp_pte_source_systems B ,
                                       mtl_default_category_sets c, mtl_category_sets d
                       where A.PTE_SOURCE_SYSTEM_ID = B.PTE_SOURCE_SYSTEM_ID and
                             B.PTE_CODE = :pte_code and
                             B.APPLICATION_SHORT_NAME = :source_system_code and
                             A.FUNCTIONAL_AREA_ID = c.FUNCTIONAL_AREA_ID and
                             c.CATEGORY_SET_ID = d.CATEGORY_SET_ID and
                             d.HIERARCHY_ENABLED = ''Y'' and
                             A.ENABLED_FLAG = ''Y'' and B.ENABLED_FLAG = ''Y'')))
		   AND    ic.category_set_id  = :category_set_id
		 ) ';
   END IF;
   IF ( nvl(p_category_id, 0) = 0 AND nvl(p_category_set_id, 0) <> 0) THEN
       l_select_stmt := l_select_stmt ||
		 'AND    m.inventory_item_id IN
		 ( SELECT ic.inventory_item_id
		   FROM   mtl_item_categories ic
		   WHERE  ic.inventory_item_id = m.inventory_item_id
		   AND    ic.organization_id   = m.organization_id
		   AND    ic.category_set_id  = :category_set_id
		 ) ';
   END IF;
-- end fix bug 4127037

   l_select_stmt := l_select_stmt || ') )';
ELSE
   l_select_stmt := l_select_stmt || ') ';
END IF;

-- debug
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||l_select_stmt);

IF (p_category_id is null) and (p_category_set_id is null) then
   OPEN qp_list_lines_cv FOR l_select_stmt USING p_from_list_header_id;
end if;
IF  ( nvl(p_category_id, 0) <> 0 AND nvl(p_category_set_id, 0) <> 0) THEN
    OPEN qp_list_lines_cv FOR l_select_stmt USING p_from_list_header_id,p_category_id,p_category_id,v_pte_code,v_source_system_code,p_category_set_id;
END IF;
IF ( nvl(p_category_id, 0) = 0 AND nvl(p_category_set_id, 0) <> 0) THEN
    OPEN qp_list_lines_cv FOR l_select_stmt USING p_from_list_header_id,p_category_set_id;
END IF;
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'opened list_lines cursor');

  --This is the fetch loop
  LOOP
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'inside loop ');

    --Insert each fetched record(Price List Line without Discount Line)
    --of the from_price_list into qp_list_lines(for the New Price List)
    --provided the segment values of the lines lie in the input ranges.

    FETCH qp_list_lines_cv INTO l_qp_list_lines_rec;
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'after fetch ');
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'row count ' || qp_list_lines_cv%ROWCOUNT);

    EXIT WHEN qp_list_lines_cv%NOTFOUND;
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'row count ' || qp_list_lines_cv%ROWCOUNT);


       /* Added for 3067774.When price listr line is end dated,its related lines e.g. child lines
           are still active. Cursor qp_list_lines_cv selects all active lines, therefore,
           orphaned child lines are also copied to new price list.The following logic
           excludes such orphaned lines from being copied. */


        insert_flag :='N';
        BEGIN
                select from_rltd_modifier_id into l_line_id
                from qp_rltd_modifiers
                where to_rltd_modifier_id=l_qp_list_lines_rec.list_line_id;
        Exception
                when no_data_found then
                l_line_id:=null;
        End;

        If l_line_id is null then
                insert_flag :='Y';
        Else
                Begin
                         select count(*) into l_cnt from qp_list_lines where list_line_id=l_line_id
                           AND   ((end_date_active IS NULL) OR  (trunc(end_date_active) >= trunc(sysdate)));
                Exception
                        when no_data_found then
                        l_cnt:=0;
                End;

                If l_cnt > 0 then
                        insert_flag :='Y';
                End if;
        End if;
fnd_file.put_line(FND_FILE.LOG,'>>>>>>>>>>>>>>>>'||'insert flag is ' || insert_flag);

If insert_flag ='Y' then                /* end changes for bug3067774 */



    -- Get next list_line_id

    SELECT qp_list_lines_s.nextval
    INTO   l_new_list_line_id
    FROM   dual;

    INSERT INTO qp_list_lines
    (
     list_line_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     program_application_id,
     program_id,
     program_update_date,
     request_id,
     list_header_id,
     list_line_type_code,
     start_date_active,
     end_date_active,
     automatic_flag,
     modifier_level_code,
     list_price,
     primary_uom_flag,
     inventory_item_id,
     organization_id,
     related_item_id,
     relationship_type_id,
     substitution_context,
     substitution_attribute,
     substitution_value,
     revision,
     revision_date,
     revision_reason_code,
     context,
     attribute1,
     attribute2,
     comments,
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
     price_break_type_code,
     percent_price,
     price_by_formula_id,
     number_effective_periods,
     effective_period_uom,
     arithmetic_operator,
     operand,
     override_flag,
     print_on_invoice_flag,
     rebate_transaction_type_code,
     estim_accrual_rate,
     generate_using_formula_id,
	reprice_flag,
     accrual_flag,
     pricing_group_sequence,
     incompatibility_grp_code,
     list_line_no,
     product_precedence,
     pricing_phase_id,
     expiration_period_start_date,
     number_expiration_periods,
     expiration_period_uom,
     expiration_date,
     estim_gl_value,
     accrual_conversion_rate,
     benefit_price_list_line_id,
     proration_type_code,
     benefit_qty,
     benefit_uom_code,
     charge_type_code,
     charge_subtype_code,
     benefit_limit,
     include_on_returns_flag,
     qualification_ind,
     recurring_value, -- block pricing
	 continuous_price_break_flag --Continuous Price Breaks
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (
     l_new_list_line_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_conc_login_id,
     l_conc_program_application_id,
     l_conc_program_id,
     sysdate,
     l_conc_request_id,
     l_new_list_header_id,
     l_qp_list_lines_rec.list_line_type_code,
     DECODE (p_effective_dates_flag,
	        'Y', l_qp_list_lines_rec.start_date_active,
		   NULL), /* If flag='Y', retain start date from copied line */
				/* else default start date */
     DECODE (p_effective_dates_flag,
		   'Y', l_qp_list_lines_rec.end_date_active,
		   NULL), /* If flag='Y', retain end date from copied line */
				/* else default end date */
     l_qp_list_lines_rec.automatic_flag,
     l_qp_list_lines_rec.modifier_level_code,
     l_qp_list_lines_rec.list_price,
     l_qp_list_lines_rec.primary_uom_flag,
     l_qp_list_lines_rec.inventory_item_id,
     l_qp_list_lines_rec.organization_id,
     l_qp_list_lines_rec.related_item_id,
     l_qp_list_lines_rec.relationship_type_id,
     l_qp_list_lines_rec.substitution_context,
     l_qp_list_lines_rec.substitution_attribute,
     l_qp_list_lines_rec.substitution_value,
     l_qp_list_lines_rec.revision,
     l_qp_list_lines_rec.revision_date,
     l_qp_list_lines_rec.revision_reason_code,
     l_qp_list_lines_rec.context,
     l_qp_list_lines_rec.attribute1,
     l_qp_list_lines_rec.attribute2,
     l_qp_list_lines_rec.comments,
     l_qp_list_lines_rec.attribute3,
     l_qp_list_lines_rec.attribute4,
     l_qp_list_lines_rec.attribute5,
     l_qp_list_lines_rec.attribute6,
     l_qp_list_lines_rec.attribute7,
     l_qp_list_lines_rec.attribute8,
     l_qp_list_lines_rec.attribute9,
     l_qp_list_lines_rec.attribute10,
     l_qp_list_lines_rec.attribute11,
     l_qp_list_lines_rec.attribute12,
     l_qp_list_lines_rec.attribute13,
     l_qp_list_lines_rec.attribute14,
     l_qp_list_lines_rec.attribute15,
     l_qp_list_lines_rec.price_break_type_code,
     l_qp_list_lines_rec.percent_price,
     l_qp_list_lines_rec.price_by_formula_id,
     l_qp_list_lines_rec.number_effective_periods,
     l_qp_list_lines_rec.effective_period_uom,
     l_qp_list_lines_rec.arithmetic_operator,
     l_qp_list_lines_rec.operand,
     l_qp_list_lines_rec.override_flag,
     l_qp_list_lines_rec.print_on_invoice_flag,
     l_qp_list_lines_rec.rebate_transaction_type_code,
     l_qp_list_lines_rec.estim_accrual_rate,
     l_qp_list_lines_rec.generate_using_formula_id,
	l_qp_list_lines_rec.reprice_flag,
     l_qp_list_lines_rec.accrual_flag,
     l_qp_list_lines_rec.pricing_group_sequence,
     l_qp_list_lines_rec.incompatibility_grp_code,
     l_qp_list_lines_rec.list_line_no,
     l_qp_list_lines_rec.product_precedence,
     l_qp_list_lines_rec.pricing_phase_id,
     l_qp_list_lines_rec.expiration_period_start_date,
     l_qp_list_lines_rec.number_expiration_periods,
     l_qp_list_lines_rec.expiration_period_uom,
     l_qp_list_lines_rec.expiration_date,
     l_qp_list_lines_rec.estim_gl_value,
     l_qp_list_lines_rec.accrual_conversion_rate,
     l_qp_list_lines_rec.benefit_price_list_line_id,
     l_qp_list_lines_rec.proration_type_code,
     l_qp_list_lines_rec.benefit_qty,
     l_qp_list_lines_rec.benefit_uom_code,
     l_qp_list_lines_rec.charge_type_code,
     l_qp_list_lines_rec.charge_subtype_code,
     l_qp_list_lines_rec.benefit_limit,
     l_qp_list_lines_rec.include_on_returns_flag,
     l_qp_list_lines_rec.qualification_ind,
     l_qp_list_lines_rec.recurring_value, -- block pricing
	 decode(l_qp_list_lines_rec.list_line_type_code,'PBH','Y',
     l_qp_list_lines_rec.continuous_price_break_flag) -- Continuous Price Breaks
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_qp_list_lines_rec.list_line_id)   --7309992
     ,to_char(l_qp_list_lines_rec.list_header_id)  --7309992
	 --(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_list_header_id)
    );
     fnd_file.put_line(FND_FILE.LOG,'Inserted line');
     fnd_file.put_line(FND_FILE.LOG,'list_line_id ' || l_new_list_line_id);
     fnd_file.put_line(FND_FILE.LOG,'list_line_type_code ' || l_qp_list_lines_rec.list_line_type_code);


    /*If the list_line_rec is a Price Break Parent Line or Price Break Line then
	 store the old and new list line id in a mapping-array for later use*/

    IF l_qp_list_lines_rec.list_line_type_code = 'PBH' OR
	  Price_Break_Line(l_qp_list_lines_rec.list_line_id)
    THEN
	  l_count := l_count + 1;
	  l_mapping_tbl(l_count).list_line_type_code :=
						 l_qp_list_lines_rec.list_line_type_code;
       l_mapping_tbl(l_count).old_list_line_id :=
   					      l_qp_list_lines_rec.list_line_id;
       l_mapping_tbl(l_count).new_list_line_id := l_new_list_line_id;
    END IF;

    IF l_qp_list_lines_rec.list_line_type_code = 'PBH' AND
      (l_qp_list_lines_rec.continuous_price_break_flag IS NULL OR l_qp_list_lines_rec.continuous_price_break_flag <> 'Y')
    THEN
	l_non_cont_count := l_non_cont_count + 1;
        l_non_cont_pbh_id_tbl(l_non_cont_count).price_break_header_id := l_new_list_line_id;
        l_non_cont_pbh_id_tbl(l_non_cont_count).list_line_no := l_qp_list_lines_rec.list_line_no;

	IF p_effective_dates_flag = 'Y' THEN
	   l_non_cont_pbh_id_tbl(l_non_cont_count).start_date_active := l_qp_list_lines_rec.start_date_active;
	   l_non_cont_pbh_id_tbl(l_non_cont_count).end_date_active := l_qp_list_lines_rec.end_date_active;
	END IF;

    END IF;


    /*Also copy the Pricing Attributes for the copied line of the
	 from_price_list to the new pricelist and associate it with the
	 new_list_line_id*/

    /* Select qp_pricing_attributes records for the 'from' list_line_id */
    FOR l_qp_pricing_attributes_rec IN qp_pricing_attributes_cur (
							    l_qp_list_lines_rec.list_line_id)
    LOOP

      -- Get next pricing_attribute_id
      SELECT qp_pricing_attributes_s.nextval
      INTO   l_new_pricing_attribute_id
      FROM   dual;

    IF l_qp_list_lines_rec.list_line_type_code = 'PBH' AND
      (l_qp_list_lines_rec.continuous_price_break_flag IS NULL OR l_qp_list_lines_rec.continuous_price_break_flag <> 'Y')
      AND l_qp_pricing_attributes_rec.list_line_id = l_qp_list_lines_rec.list_line_id
    THEN
        l_non_cont_pbh_id_tbl(l_non_cont_count).product_attribute :=
					l_qp_pricing_attributes_rec.product_attribute;
        l_non_cont_pbh_id_tbl(l_non_cont_count).product_attr_value:=
					l_qp_pricing_attributes_rec.product_attr_value;
    END IF;

    IF l_qp_pricing_attributes_rec.pricing_attribute_datatype = 'N'
    then

    BEGIN

	    l_pric_attr_value_from_number :=
	    qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_from);

	    l_pric_attr_value_to_number :=
	    qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_to);

     EXCEPTION
	    WHEN VALUE_ERROR THEN
		  NULL;
	    WHEN OTHERS THEN
		  NULL;
     END;

     end if;


      INSERT INTO qp_pricing_attributes
       (pricing_attribute_id,
  	   creation_date,
 	   created_by,
	   last_update_date,
	   last_updated_by,
 	   last_update_login,
 	   program_application_id,
 	   program_id,
 	   program_update_date,
 	   request_id,
 	   list_line_id,
	   list_header_id,
	   pricing_phase_id,
	   qualification_ind,
	   excluder_flag,
	   accumulate_flag,
 	   product_attribute_context,
 	   product_attribute,
 	   product_attr_value,
 	   product_uom_code,
 	   pricing_attribute_context,
 	   pricing_attribute,
 	   pricing_attr_value_from,
 	   pricing_attr_value_to,
 	   attribute_grouping_no,
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
        product_attribute_datatype,
        pricing_attribute_datatype,
        comparison_operator_code,
 	   pricing_attr_value_from_number,
 	   pricing_attr_value_to_number
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
      )
      VALUES
      (l_new_pricing_attribute_id,
  	 sysdate,
 	 l_user_id,
	 sysdate,
	 l_user_id,
 	 l_conc_login_id,
 	 l_conc_program_application_id,
 	 l_conc_program_id,
 	 sysdate,
 	 l_conc_request_id,
 	 l_new_list_line_id, /* new list line id */
	 l_new_list_header_id,
	 l_qp_pricing_attributes_rec.pricing_phase_id,
	 l_qp_pricing_attributes_rec.qualification_ind,
	 l_qp_pricing_attributes_rec.excluder_flag,
	 l_qp_pricing_attributes_rec.accumulate_flag,
 	 l_qp_pricing_attributes_rec.product_attribute_context,
 	 l_qp_pricing_attributes_rec.product_attribute,
 	 l_qp_pricing_attributes_rec.product_attr_value,
 	 l_qp_pricing_attributes_rec.product_uom_code,
 	 l_qp_pricing_attributes_rec.pricing_attribute_context,
 	 l_qp_pricing_attributes_rec.pricing_attribute,
 	 l_qp_pricing_attributes_rec.pricing_attr_value_from,
 	 l_qp_pricing_attributes_rec.pricing_attr_value_to,
 	 l_qp_pricing_attributes_rec.attribute_grouping_no,
 	 l_qp_pricing_attributes_rec.context,
 	 l_qp_pricing_attributes_rec.attribute1,
 	 l_qp_pricing_attributes_rec.attribute2,
 	 l_qp_pricing_attributes_rec.attribute3,
 	 l_qp_pricing_attributes_rec.attribute4,
 	 l_qp_pricing_attributes_rec.attribute5,
 	 l_qp_pricing_attributes_rec.attribute6,
 	 l_qp_pricing_attributes_rec.attribute7,
 	 l_qp_pricing_attributes_rec.attribute8,
 	 l_qp_pricing_attributes_rec.attribute9,
 	 l_qp_pricing_attributes_rec.attribute10,
 	 l_qp_pricing_attributes_rec.attribute11,
 	 l_qp_pricing_attributes_rec.attribute12,
 	 l_qp_pricing_attributes_rec.attribute13,
 	 l_qp_pricing_attributes_rec.attribute14,
 	 l_qp_pricing_attributes_rec.attribute15,
      l_qp_pricing_attributes_rec.product_attribute_datatype,
      l_qp_pricing_attributes_rec.pricing_attribute_datatype,
      l_qp_pricing_attributes_rec.comparison_operator_code,
	 l_pric_attr_value_from_number,
	 l_pric_attr_value_to_number
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(l_new_pricing_attribute_id)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_new_list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_list_header_id)
	 );
         fnd_file.put_line(FND_FILE.LOG,'Inserted pricing attribute');
         fnd_file.put_line(FND_FILE.LOG,'product_attribute_context ' || l_qp_pricing_attributes_rec.product_attribute_context);
         fnd_file.put_line(FND_FILE.LOG,'product_attribute ' || l_qp_pricing_attributes_rec.product_attribute);
         fnd_file.put_line(FND_FILE.LOG,'product_attr_value ' || l_qp_pricing_attributes_rec.product_attr_value);
         fnd_file.put_line(FND_FILE.LOG,'product_uom_code ' || l_qp_pricing_attributes_rec.product_uom_code);

    END LOOP; /* Cursor qp_pricing_attributes_cur LOOP */
end if;  --bug3067774
  END LOOP; /* Cursor qp_list_lines_cv LOOP */

  CLOSE qp_list_lines_cv;


/* Copy qp_rltd_modifiers for the Price Break Parent list_lines chosen
   above which are stored in the mapping table */
  IF l_mapping_tbl.COUNT > 0 THEN
    FOR l_count IN 1..l_mapping_tbl.COUNT
    LOOP

      IF l_mapping_tbl(l_count).list_line_type_code = 'PBH' THEN

          FOR l_qp_rltd_modifiers_rec IN qp_rltd_modifiers_cur(
					  l_mapping_tbl(l_count).old_list_line_id)
          LOOP

	       SELECT qp_rltd_modifiers_s.nextval
	       INTO   l_new_rltd_modifier_id
	       FROM   dual;

             l_new_from_id := Get_New_Id(
						l_qp_rltd_modifiers_rec.from_rltd_modifier_id,
				          l_mapping_tbl);
             l_new_to_id   := Get_New_Id(
						l_qp_rltd_modifiers_rec.to_rltd_modifier_id,
				          l_mapping_tbl);
            INSERT INTO qp_rltd_modifiers
	       (creation_date,
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
             rltd_modifier_id,
             rltd_modifier_grp_no,
             from_rltd_modifier_id,
             to_rltd_modifier_id,
             rltd_modifier_grp_type
	       )
	       VALUES
	       (sysdate,
	        l_user_id,
	        sysdate,
	        l_user_id,
	        l_conc_login_id,
	        l_qp_rltd_modifiers_rec.context,
	        l_qp_rltd_modifiers_rec.attribute1,
	        l_qp_rltd_modifiers_rec.attribute2,
	        l_qp_rltd_modifiers_rec.attribute3,
	        l_qp_rltd_modifiers_rec.attribute4,
	        l_qp_rltd_modifiers_rec.attribute5,
	        l_qp_rltd_modifiers_rec.attribute6,
	        l_qp_rltd_modifiers_rec.attribute7,
	        l_qp_rltd_modifiers_rec.attribute8,
	        l_qp_rltd_modifiers_rec.attribute9,
	        l_qp_rltd_modifiers_rec.attribute10,
	        l_qp_rltd_modifiers_rec.attribute11,
	        l_qp_rltd_modifiers_rec.attribute12,
	        l_qp_rltd_modifiers_rec.attribute13,
	        l_qp_rltd_modifiers_rec.attribute14,
	        l_qp_rltd_modifiers_rec.attribute15,
	        l_new_rltd_modifier_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_no,
		   l_new_from_id,
		   l_new_to_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_type
	       );

        END LOOP; -- Loop through rltd modifiers records
	 END IF; --For lines that are Parent Price Break lines

    END LOOP; --Loop through l_mapping_tbl
  END IF; --If l_mapping_tbl has any records


  Delete_Duplicate_Lines(p_effective_dates_flag, l_new_list_header_id);

/* This code will call the API to update the denormalized columns on QP_QUALIFIERS*/
  QP_MAINTAIN_DENORMALIZED_DATA.UPDATE_QUALIFIERS
			(ERR_BUFF => errbuf,
			 RETCODE => retcode,
			 P_LIST_HEADER_ID => l_new_list_header_id,
                         p_List_Header_Id_high => l_new_discount_header_id,
                         p_UPDATE_TYPE => 'ALL'); ---Added 2 more parameters for bug 8326619;


			 if retcode = 2 then
				--error from update denormalized columns
				fnd_file.put_line(FND_FILE.LOG,'Error in Update of denormalized columns in QP_Qualifiers');
			 else
				fnd_file.put_line(FND_FILE.LOG,'Update of denormalized columns in QP_Qualifiers completed successfully');
			 end if;


  --Upgrade Non-Continuous Price Breaks

  IF l_non_cont_pbh_id_tbl.COUNT > 0 THEN
      fnd_file.put_line(FND_FILE.LOG,'New List Name : '||p_new_price_list_name);

  FOR i IN l_non_cont_pbh_id_tbl.FIRST..l_non_cont_pbh_id_tbl.LAST
  LOOP

      fnd_file.put_line(FND_FILE.LOG,'Upgrading non-continuous price breaks to continuous price breaks for the product : '||l_non_cont_pbh_id_tbl(i).product_attr_value);

      qp_delayed_requests_PVT.log_request
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_entity_id              => l_non_cont_pbh_id_tbl(i).price_break_header_id
       , p_requesting_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_requesting_entity_id   => l_non_cont_pbh_id_tbl(i).price_break_header_id
       , p_request_type           => QP_Globals.G_UPGRADE_PRICE_BREAKS
       , p_param1                 => l_non_cont_pbh_id_tbl(i).list_line_no
       , p_param2                 => l_non_cont_pbh_id_tbl(i).product_attribute
       , p_param3                 => l_non_cont_pbh_id_tbl(i).product_attr_value
       , p_param4                 => 'PRICELIST'
       , p_param5                 => l_non_cont_pbh_id_tbl(i).start_date_active
       , p_param6                 => l_non_cont_pbh_id_tbl(i).end_date_active
       , x_return_status          => l_return_status);

  END LOOP;
  QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , x_return_status          => l_return_status);

  END IF;
  commit;

   fnd_file.put_line(FND_FILE.LOG,'Price list copy completed successfully');
   IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	select min(list_line_id), max(list_line_id)
	into   l_min_list_line_id, l_max_list_line_id
	from   qp_list_lines
	where  list_header_id = l_new_list_header_id;


      QP_ATTR_GRP_PVT.Update_Qual_Segment_id(l_new_list_header_id,
						null,
						l_min_list_line_id,
						l_max_list_line_id);
      QP_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_new_list_header_id,
					l_min_list_line_id,l_max_list_line_id);
      QP_ATTR_GRP_PVT.generate_hp_atgrps(l_new_list_header_id,null);
      QP_ATTR_GRP_PVT.update_pp_lines(l_new_list_header_id,
					l_min_list_line_id,l_max_list_line_id);
   END IF;
--- jagan PL/SQL pattern engine
    IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	  for l_list_header_id in l_new_list_header_id..NVL(l_new_discount_header_id,l_new_list_header_id)
		     loop
			begin

				select min(list_line_id), max(list_line_id)
				into   l_min_list_line_id, l_max_list_line_id
				from   qp_list_lines
				where  list_header_id = l_list_header_id;


			      QP_PS_ATTR_GRP_PVT.Update_Qual_Segment_id(l_new_list_header_id,
									null,
									l_min_list_line_id,
									l_max_list_line_id);
			      QP_PS_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_new_list_header_id,
								l_min_list_line_id,l_max_list_line_id);
			      QP_PS_ATTR_GRP_PVT.generate_hp_atgrps(l_new_list_header_id,null);
			      QP_PS_ATTR_GRP_PVT.update_pp_lines(l_new_list_header_id,
								l_min_list_line_id,l_max_list_line_id);
			exception
			when others then
				null;
			end;
	   END LOOP;





	END IF;
   END IF;
  errbuf := '';
  retcode := 0;

EXCEPTION

WHEN OTHERS THEN


	fnd_file.put_line(FND_FILE.LOG,'Error in Copy Price list Routine ');
       fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
		retcode := 2;

END Copy_Price_List;

END QP_COPY_PRICELIST_PVT;

/
