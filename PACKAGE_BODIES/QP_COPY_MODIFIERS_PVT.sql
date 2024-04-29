--------------------------------------------------------
--  DDL for Package Body QP_COPY_MODIFIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_COPY_MODIFIERS_PVT" AS
/* $Header: QPXVCPMB.pls 120.14.12010000.2 2009/06/04 07:19:31 jputta ship $ */

-- GLOBAL Constant holding the package name

--G_PKG_NAME		CONSTANT	VARCHAR2(30):='QP_COPY_MODIFIERS_PVT';


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
/* Commented out for 2222562 */
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
/* Added for 2222562 */

CURSOR del_dup_cur(a_new_list_header_id  NUMBER)
IS
  SELECT distinct qll.list_line_id,qpa.product_attribute_context,qpa.product_attribute,qpa.product_attr_value
  FROM qp_list_lines qll,qp_pricing_attributes qpa
  WHERE qll.list_header_id=a_new_list_header_id
  AND qll.list_line_id=qpa.list_line_id(+);

l_status BOOLEAN := TRUE;
l_rows number := 0;
l_effdates boolean := FALSE;
l_qp_status           VARCHAR2(1);
l_gsa_indicator               VARCHAR2(1);

BEGIN

--If the Retain Effective Dates flag is not checked then copied price list
--lines will have null effective dates. This will mean that there is a
--possibility that lines may be duplicated. To prevent this, all but one
--duplicate lines are deleted here.

l_qp_status := QP_UTIL.GET_QP_STATUS;

--fix for bug 4673872
SELECT GSA_INDICATOR INTO l_gsa_indicator FROM QP_LIST_HEADERS_ALL_B
WHERE list_header_id=p_new_list_header_id;

IF (fnd_profile.value('QP_ALLOW_DUPLICATE_MODIFIERS') <> 'Y'
AND (l_qp_status = 'S' OR l_gsa_indicator = 'Y')) THEN

/* Modified for 2222562 */
  IF p_effective_dates_flag = 'N' THEN

    FOR l_del_dup_cur_rec IN del_dup_cur(p_new_list_header_id)
    LOOP

    l_status := QP_VALIDATE_PRICING_ATTR.Mod_Dup(NULL,
                                              NULL,
                                              l_del_dup_cur_rec.list_line_id,
                                              p_new_list_header_id,
                                              l_del_dup_cur_rec.product_attribute_context,
                                              l_del_dup_cur_rec.product_attribute,
                                              l_del_dup_cur_rec.product_attr_value,
                                              l_rows,
                                              l_effdates);

    IF l_status= FALSE THEN
	DELETE FROM qp_rltd_modifiers
	WHERE from_RLTD_MODIFIER_ID=l_del_dup_cur_rec.list_line_id;

	DELETE qp_pricing_Attributes
	where list_line_id=l_del_dup_cur_rec.list_line_id;

	delete qp_qualifiers
	where list_line_id=l_del_dup_cur_rec.list_line_id;

	DELETE qp_list_lines
	where list_line_id=l_del_dup_cur_rec.list_line_id;
    END IF;

    END LOOP;
  END IF; /* End of IF p_effective_dates_flag = 'N' */

/*
  IF p_effective_dates_flag = 'N' THEN

    FOR   l_del_dup_cur_rec IN del_dup_cur(p_new_list_header_id)
    LOOP

      DELETE qp_pricing_attributes pa
      WHERE  pa.list_line_id = l_del_dup_cur_rec.list_line_id;

      DELETE qp_list_lines
      WHERE  CURRENT OF del_dup_cur;

    END LOOP;

  END IF;
*/
END IF;
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
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_from_list_header_id 	 	 NUMBER,
 p_new_price_list_name  IN    VARCHAR2,
 p_description          IN 	VARCHAR2,
 p_start_date_active    IN    VARCHAR2, --DATE, 2752295
 p_end_date_active      IN    VARCHAR2, --DATE, 2752295
 p_rounding_factor      IN 	NUMBER,
 p_effective_dates_flag IN 	VARCHAR2,
--added for moac bug 4673872
 p_global_flag IN VARCHAR2,
 p_org_id IN NUMBER
)
IS

l_mapping_tbl                 mapping_tbl;

l_name 				     VARCHAR2(240);
l_description                 VARCHAR2(2000);
l_version_no                  VARCHAR2(30);
l_new_discount_header_id      NUMBER;
l_new_qualifier_id            NUMBER;
l_new_discount_line_id        NUMBER;
l_new_list_header_id          NUMBER;
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
---
l_conc_request_id			NUMBER := -1;
l_conc_program_application_id	NUMBER := -1;
l_conc_program_id			NUMBER := -1;
l_conc_login_id		   	NUMBER := -1;
l_user_id                       NUMBER := -1;
x_result                        varchar2(1);
l_qp_status           VARCHAR2(1);
insert_flag varchar2(1);
l_cnt number:=0;
l_line_id number;
l_min_list_line_id NUMBER;
l_max_list_line_id NUMBER;

--Continuous Price Breaks
l_non_cont_pbh_id_tbl         QP_UTIL.price_brk_attr_val_tab;
l_non_cont_count              NUMBER := 0;
l_return_status               VARCHAR2(1);

/*
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
			 FROM   qp_list_headers_ALL_b
			 WHERE  list_type_code = 'DLT');
*/
CURSOR qp_from_discounts_cur(p_from_list_header_id NUMBER)
IS
  SELECT list_header_id
--fix for bug 4673872
  FROM   qp_list_headers_ALL_b
  WHERE  list_header_id = p_from_list_header_id
  AND    list_type_code in ('DLT','DEL','CHARGES','PRO','SLT');

CURSOR qp_qualifiers_cur(p_from_discount_header_id    NUMBER)
IS
  SELECT *
  FROM   qp_qualifiers
  WHERE  list_header_id = p_from_discount_header_id  and
         list_line_id = -1;

CURSOR qp_line_qualifiers_cur(p_from_discount_header_id NUMBER,
                              p_from_discount_line_id NUMBER)
IS
  SELECT *
  FROM   qp_qualifiers
  WHERE  list_header_id = p_from_discount_header_id and
         list_line_id = p_from_discount_line_id ;

CURSOR qp_discount_lines_cur(p_from_discount_header_id    NUMBER)
IS
  SELECT *
  FROM   qp_list_lines
  WHERE  list_header_id = p_from_discount_header_id
  AND   ((end_date_active IS NULL) OR  (trunc(end_date_active) >= trunc(sysdate)));   --Added for 2476973

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


BEGIN
  l_conc_request_id := FND_GLOBAL.CONC_REQUEST_ID;
  l_conc_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
  l_user_id         := FND_GLOBAL.USER_ID;
  l_conc_login_id   := FND_GLOBAL.CONC_LOGIN_ID;
  l_conc_program_application_id := FND_GLOBAL.PROG_APPL_ID;
  l_qp_status := QP_UTIL.get_qp_status;

FOR qp_from_discounts_rec IN qp_from_discounts_cur(p_from_list_header_id)
LOOP
  /* For every old(from) discount, Copy discount header records */

  l_count := 0; --Reset the mapping table count for each discount header

  --Select next discount_header_id

  SELECT qp_list_headers_b_s.nextval
  INTO   l_new_discount_header_id
  FROM   dual;

  --Discount Header Information

  --if fnd_profile.value('QP_ATTRIBUTE_MANAGER_INSTALLED') = 'Y' then
  if QP_UTIL.Attrmgr_Installed = 'Y' then
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
     pte_code,
     global_flag,
     orig_org_id
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,ORIG_SYSTEM_HEADER_REF
    )

    SELECT
     l_new_discount_header_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_conc_login_id,
     l_conc_program_application_id,
     l_conc_program_id,
     sysdate,
     l_conc_request_id,
     list_type_code,
     --decode(p_start_date_active,null,start_date_active,p_start_date_active),
     --decode(p_end_date_active,null,end_date_active,p_end_date_active),
     --p_start_date_active,
     --p_end_date_active,
     fnd_date.canonical_to_date(p_start_date_active),	--2752295
     fnd_date.canonical_to_date(p_end_date_active),	--2752295
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
     --source_system_code,
     fnd_profile.value('QP_SOURCE_SYSTEM_CODE'),
     DECODE(l_qp_status,'S','Y','N'),  --2707484
     --active_flag, -- bug 2180582 Was harcoded to N earlier
     parent_list_header_id,
     start_date_active_first,
     end_date_active_first,
     --decode(p_start_date_active,null,null,start_date_active_first),
     --decode(p_end_date_active,null,null,end_date_active_first),
     active_date_first_type,
     start_date_active_second,
     end_date_active_second,
     --decode(p_start_date_active,null,null,start_date_active_second),
     --decode(p_end_date_active,null,null,end_date_active_second),
     active_date_second_type,
     ask_for_flag,
     fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY'),
     p_global_flag,
     --added for MOAC
     p_org_id
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,nvl(ORIG_SYSTEM_HEADER_REF,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(l_new_discount_header_id))
--fix for bug 4673872
    FROM  qp_list_headers_ALL_b
    WHERE list_header_id = qp_from_discounts_rec.list_header_id;
  else
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
     global_flag,
     orig_org_id
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,ORIG_SYSTEM_HEADER_REF
    )

    SELECT
     l_new_discount_header_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_conc_login_id,
     l_conc_program_application_id,
     l_conc_program_id,
     sysdate,
     l_conc_request_id,
     list_type_code,
     --decode(p_start_date_active,null,start_date_active,p_start_date_active),
     --decode(p_end_date_active,null,end_date_active,p_end_date_active),
     --p_start_date_active,
     --p_end_date_active,
     fnd_date.canonical_to_date(p_start_date_active),   --2752295
     fnd_date.canonical_to_date(p_end_date_active),	--2752295
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
     --source_system_code,
     fnd_profile.value('QP_SOURCE_SYSTEM_CODE'),
     --active_flag, -- bug 2180582 Was harcoded to N earlier
     DECODE(l_qp_status,'S','Y','N'), --2707484
     parent_list_header_id,
     start_date_active_first,
     end_date_active_first,
     --decode(p_start_date_active,null,null,start_date_active_first),
     --decode(p_end_date_active,null,null,end_date_active_first),
     active_date_first_type,
     start_date_active_second,
     end_date_active_second,
     --decode(p_start_date_active,null,null,start_date_active_second),
     --decode(p_end_date_active,null,null,end_date_active_second),
     active_date_second_type,
     ask_for_flag,
     p_global_flag,
     --added for MOAC
     p_org_id
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,nvl(ORIG_SYSTEM_HEADER_REF,QP_PRICE_LIST_UTIL.Get_Orig_Sys_Hdr(l_new_discount_header_id))
--fix for bug 4673872
    FROM  qp_list_headers_ALL_b
    WHERE list_header_id = qp_from_discounts_rec.list_header_id;
  end if;
  --
  SELECT version_no
  INTO   l_version_no
  FROM   qp_list_headers_tl
  WHERE  list_header_id = qp_from_discounts_rec.list_header_id
  AND LANGUAGE=USERENV('LANG');

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
   l_new_discount_header_id,
   l.language_code,
   userenv('LANG'),
   l_version_no
  FROM  fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND   NOT EXISTS (SELECT NULL
  			     FROM   qp_list_headers_tl t
			     WHERE  t.list_header_id = l_new_discount_header_id
			     AND    t.language  = l.language_code);



  /* Copy all qualifiers for the discount and in case of the qualifier
     being the from-pricelist replace it with the new pricelist*/

  --
  -- Calling Object Security to grant default grants to newly created modifier.
  QP_Security.create_default_grants( p_instance_type => QP_Security.G_MODIFIER_OBJECT,
                                     p_instance_pk1 => l_new_discount_header_id,
                                     x_return_status => x_result);
  --
  FOR l_qp_qualifiers_rec IN
			 qp_qualifiers_cur(qp_from_discounts_rec.list_header_id)
  LOOP

    --Get new qualifier_id
    SELECT qp_qualifiers_s.nextval
    INTO   l_new_qualifier_id
    FROM   dual;

    /*
    IF  l_qp_qualifiers_rec.qualifier_attr_value =
					   TO_CHAR(p_from_list_header_id) AND
        l_qp_qualifiers_rec.qualifier_context = p_context  AND
        l_qp_qualifiers_rec.qualifier_attribute = p_attribute
    THEN
      l_qp_qualifiers_rec.qualifier_attr_value :=
					   TO_CHAR(p_new_list_header_id);
    END IF;
    */

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
        qualify_hier_descendents_flag  -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,ORIG_SYS_QUALIFIER_REF
     --,ORIG_SYS_LINE_REF
     --,ORIG_SYS_HEADER_REF
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
     l_new_discount_header_id,
     --l_qp_qualifiers_rec.list_line_id,
     -1, ---l_qp_qualifiers_rec.list_line_id,
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
     --,to_char(l_new_qualifier_id)
     --,null
     --,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
    );

  END LOOP; /* For copying List qualifiers */


  /* Copy all lines for the discount */

  FOR l_qp_discount_lines_rec IN
			qp_discount_lines_cur (qp_from_discounts_rec.list_header_id)
  LOOP
	/* Added for 2734611.When modifier line is end dated,its related lines e.g. child lines
           are still active. Cursor qp_discount_lines_cur selects all active lines, therefore,
           orphaned child lines are also copied to new modifier list.The following logic
	   excludes such orphaned lines from being copied. */

	insert_flag :='N';
	BEGIN
		select from_rltd_modifier_id into l_line_id
		from qp_rltd_modifiers
		where to_rltd_modifier_id=l_qp_discount_lines_rec.list_line_id;
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

If insert_flag ='Y' then		--end 2734611 changes

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
     qualification_ind,
     net_amount_flag,
     accum_context,
     accum_attribute,
     accum_attr_run_src_flag,
     continuous_price_break_flag --Continuous Price Breaks
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,ORIG_SYS_LINE_REF
     --,ORIG_SYS_HEADER_REF
    )
    VALUES
    (
     l_new_discount_line_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_conc_login_id,
     l_conc_program_application_id,
     l_conc_program_id,
     sysdate,
     l_conc_request_id,
     l_new_discount_header_id,
     l_qp_discount_lines_rec.list_line_type_code,
     DECODE (p_effective_dates_flag,
	        'Y', l_qp_discount_lines_rec.start_date_active,
		   NULL), /* If flag='Y', retain start date from copied line */
				/* else default start date */
     DECODE (p_effective_dates_flag,
		   'Y', l_qp_discount_lines_rec.end_date_active,
		   NULL), /* If flag='Y', retain end date from copied line */
				/* else default end date */
     --l_qp_discount_lines_rec.start_date_active,
	--l_qp_discount_lines_rec.end_date_active,
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
     l_qp_discount_lines_rec.qualification_ind,
     l_qp_discount_lines_rec.net_amount_flag,
     l_qp_discount_lines_rec.accum_context,
     l_qp_discount_lines_rec.accum_attribute,
     l_qp_discount_lines_rec.accum_attr_run_src_flag,
     decode(l_qp_discount_lines_rec.list_line_type_code,'PBH','Y',
     l_qp_discount_lines_rec.continuous_price_break_flag) --Continuous Price Breaks
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,to_char(l_new_discount_line_id)
     --,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
    );

  /*  Insert line qualifiers  */
  If l_qp_discount_lines_rec.list_line_id is not null and
     l_qp_discount_lines_rec.list_line_id  <> -1 then
  FOR l_qp_line_qualifiers_rec IN
			 qp_line_qualifiers_cur(qp_from_discounts_rec.list_header_id,
                                                l_qp_discount_lines_rec.list_line_id)
  LOOP

    --Get new qualifier_id
    SELECT qp_qualifiers_s.nextval
    INTO   l_new_qualifier_id
    FROM   dual;

    /*
    IF  l_qp_line_qualifiers_rec.qualifier_attr_value =
					   TO_CHAR(p_from_list_header_id) AND
        l_qp_line_qualifiers_rec.qualifier_context = p_context  AND
        l_qp_line_qualifiers_rec.qualifier_attribute = p_attribute
    THEN
      l_qp_line_qualifiers_rec.qualifier_attr_value :=
					   TO_CHAR(p_new_list_header_id);
    END IF;
    */

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

    IF l_qp_line_qualifiers_rec.qualifier_datatype = 'N'
    then

    BEGIN

	    l_qual_attr_value_from_number :=
	    qp_number.canonical_to_number(l_qp_line_qualifiers_rec.qualifier_attr_value);

	    l_qual_attr_value_to_number :=
	    qp_number.canonical_to_number(l_qp_line_qualifiers_rec.qualifier_attr_value_to);

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
     --,ORIG_SYS_QUALIFIER_REF
     --,ORIG_SYS_LINE_REF
     --,ORIG_SYS_HEADER_REF
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
     l_qp_line_qualifiers_rec.excluder_flag,
     l_qp_line_qualifiers_rec.comparison_operator_code,
     l_qp_line_qualifiers_rec.qualifier_context,
     l_qp_line_qualifiers_rec.qualifier_attribute,
     l_qp_line_qualifiers_rec.context,
     l_qp_line_qualifiers_rec.attribute1,
     l_qp_line_qualifiers_rec.attribute2,
     l_qp_line_qualifiers_rec.attribute3,
     l_qp_line_qualifiers_rec.attribute4,
     l_qp_line_qualifiers_rec.attribute5,
     l_qp_line_qualifiers_rec.attribute6,
     l_qp_line_qualifiers_rec.attribute7,
     l_qp_line_qualifiers_rec.attribute8,
     l_qp_line_qualifiers_rec.attribute9,
     l_qp_line_qualifiers_rec.attribute10,
     l_qp_line_qualifiers_rec.attribute11,
     l_qp_line_qualifiers_rec.attribute12,
     l_qp_line_qualifiers_rec.attribute13,
     l_qp_line_qualifiers_rec.attribute14,
     l_qp_line_qualifiers_rec.attribute15,
     l_qp_line_qualifiers_rec.qualifier_rule_id,
     l_qp_line_qualifiers_rec.qualifier_grouping_no,
     l_qp_line_qualifiers_rec.qualifier_attr_value,
     l_new_discount_header_id,
     l_new_discount_line_id,
     --l_qp_line_qualifiers_rec.list_line_id,
     l_qp_line_qualifiers_rec.created_from_rule_id,
     l_qp_line_qualifiers_rec.start_date_active,
     l_qp_line_qualifiers_rec.end_date_active,
     l_qp_line_qualifiers_rec.qualifier_precedence,
     l_qp_line_qualifiers_rec.qualifier_datatype,
     l_qp_line_qualifiers_rec.qualifier_attr_value_to,
     l_active_flag,
     l_list_type_code,
     l_qual_attr_value_from_number,
     l_qual_attr_value_to_number,
     l_qp_line_qualifiers_rec.search_ind,
     l_qp_line_qualifiers_rec.distinct_row_count,
     l_qp_line_qualifiers_rec.qualifier_group_cnt,
     l_qp_line_qualifiers_rec.header_quals_exist_flag,
     l_qp_line_qualifiers_rec.qualify_hier_descendents_flag -- Added for TCA
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     --,to_char(l_new_qualifier_id)
     --,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_new_discount_line_id)
     --,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
    );

  END LOOP;
  end if;
  /* For copying Line qualifiers */

    /*If the discount_line_rec is a Price Break Parent Line or Price Break Line
    then store the old and new discountlineid in a mapping-array for later use*/

    ---IF l_qp_discount_lines_rec.list_line_type_code = 'PBH' OR
    IF l_qp_discount_lines_rec.list_line_type_code  in ('PBH','OID','PRG','CIE') OR
	  Price_Break_Line(l_qp_discount_lines_rec.list_line_id)
    THEN
	  l_count := l_count + 1;
	  l_mapping_tbl(l_count).list_line_type_code :=
						 l_qp_discount_lines_rec.list_line_type_code;
       l_mapping_tbl(l_count).old_list_line_id :=
   					      l_qp_discount_lines_rec.list_line_id;
       l_mapping_tbl(l_count).new_list_line_id := l_new_discount_line_id;
    END IF;

    IF l_qp_discount_lines_rec.list_line_type_code = 'PBH' AND
      (l_qp_discount_lines_rec.continuous_price_break_flag IS NULL OR l_qp_discount_lines_rec.continuous_price_break_flag <> 'Y')
    THEN
        l_non_cont_count := l_non_cont_count + 1;
        l_non_cont_pbh_id_tbl(l_non_cont_count).price_break_header_id := l_new_discount_line_id;
        l_non_cont_pbh_id_tbl(l_non_cont_count).list_line_no :=	l_qp_discount_lines_rec.list_line_no;

	IF p_effective_dates_flag = 'Y' THEN
	   l_non_cont_pbh_id_tbl(l_non_cont_count).start_date_active := l_qp_discount_lines_rec.start_date_active;
	   l_non_cont_pbh_id_tbl(l_non_cont_count).end_date_active := l_qp_discount_lines_rec.end_date_active;
	END IF;

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

    IF l_qp_discount_lines_rec.list_line_type_code = 'PBH' AND
      (l_qp_discount_lines_rec.continuous_price_break_flag IS NULL OR l_qp_discount_lines_rec.continuous_price_break_flag <> 'Y')
      AND l_qp_pricing_attributes_rec.list_line_id = l_qp_discount_lines_rec.list_line_id
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
     --,ORIG_SYS_PRICING_ATTR_REF
     --,ORIG_SYS_LINE_REF
     --,ORIG_SYS_HEADER_REF
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
     --,to_char(l_new_pricing_attribute_id)
     --,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=l_new_discount_line_id)
     --,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_new_discount_header_id)
	 );

    END LOOP; /* For copying pricing attributes for each discount line */
END IF;
  END LOOP; /* For copying discount lines*/

  /* Copy qp_rltd_modifiers for the Price Break Parent list_lines chosen
   above which are stored in the mapping table */

  IF l_mapping_tbl.COUNT > 0 THEN
    FOR l_count IN 1..l_mapping_tbl.COUNT
    LOOP

      --IF l_mapping_tbl(l_count).list_line_type_code = 'PBH' THEN
      IF l_mapping_tbl(l_count).list_line_type_code in ('PBH','OID','PRG','CIE') THEN

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

END LOOP; /* for copying discount headers*/
----
--Delete_Duplicate_Lines(p_effective_dates_flag, l_new_list_header_id);
Delete_Duplicate_Lines(p_effective_dates_flag, l_new_discount_header_id);  --for 2222562

/* This code will call the API to update the denormalized columns on QP_QUALIFIERS*/
  QP_MAINTAIN_DENORMALIZED_DATA.UPDATE_QUALIFIERS
			(ERR_BUFF => errbuf,
			 RETCODE => retcode,
			 --P_LIST_HEADER_ID => l_new_list_header_id);
			 P_LIST_HEADER_ID => l_new_discount_header_id);


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
       , p_param4                 => 'MODIFIER'
       , p_param5                 => l_non_cont_pbh_id_tbl(i).start_date_active
       , p_param6                 => l_non_cont_pbh_id_tbl(i).end_date_active
       , x_return_status          => l_return_status);

  END LOOP;
  QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , x_return_status          => l_return_status);

  END IF;

  fnd_file.put_line(FND_FILE.LOG,'Price list copy completed successfully');

  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
    select min(list_line_id), max(list_line_id)
    into   l_min_list_line_id, l_max_list_line_id
    from   qp_list_lines
    where  list_header_id = l_new_discount_header_id;

      QP_ATTR_GRP_PVT.Update_Qual_Segment_id(l_new_discount_header_id, null, -1, -1); -- Bug No 4331910
      QP_ATTR_GRP_PVT.Update_Qual_Segment_id(l_new_discount_header_id,
						null,
						l_min_list_line_id,
						l_max_list_line_id);
      QP_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_new_discount_header_id,
					l_min_list_line_id,l_max_list_line_id);
      QP_ATTR_GRP_PVT.generate_hp_atgrps(l_new_discount_header_id,null);
      QP_ATTR_GRP_PVT.generate_lp_atgrps(l_new_discount_header_id,null,
					l_min_list_line_id,l_max_list_line_id);
      QP_ATTR_GRP_PVT.update_pp_lines(l_new_discount_header_id,
					l_min_list_line_id,l_max_list_line_id);
  END IF;
--- jagan PL/SQL pattern engine
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	    select min(list_line_id), max(list_line_id)
	    into   l_min_list_line_id, l_max_list_line_id
	    from   qp_list_lines
	    where  list_header_id = l_new_list_header_id;
	      QP_PS_ATTR_GRP_PVT.Update_Qual_Segment_id(l_new_discount_header_id,
							null,
							l_min_list_line_id,
							l_max_list_line_id);
	      QP_PS_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(l_new_discount_header_id,
						l_min_list_line_id,l_max_list_line_id);
	      QP_PS_ATTR_GRP_PVT.generate_hp_atgrps(l_new_discount_header_id,null);
	      QP_PS_ATTR_GRP_PVT.generate_lp_atgrps(l_new_discount_header_id,null,
						l_min_list_line_id,l_max_list_line_id);
	      QP_PS_ATTR_GRP_PVT.update_pp_lines(l_new_discount_header_id,
						l_min_list_line_id,l_max_list_line_id);
	END IF;
   END IF;
  commit;

  errbuf := '';
  retcode := 0;


EXCEPTION

WHEN OTHERS THEN
	fnd_file.put_line(FND_FILE.LOG,'Error in Copy Price list Routine ');
       fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
		retcode := 2;

END Copy_Discounts;

END QP_COPY_MODIFIERS_PVT;

/
