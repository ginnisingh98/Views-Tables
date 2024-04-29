--------------------------------------------------------
--  DDL for Package Body QP_ARCHIVE_ENTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ARCHIVE_ENTITY_PVT" AS
/* $Header: QPXARCVB.pls 120.2.12010000.2 2008/08/18 11:47:52 kdurgasi ship $ */

--GLOBAL Constant holding the package name

--G_PKG_NAME	       CONSTANT	VARCHAR2(30):='QP_ARCHIVE_ENTITY_PVT';
g_count_header_b                NUMBER := 0;
g_count_header_tl               NUMBER := 0;
g_count_pricing_att             NUMBER := 0;
g_count_qualifier               NUMBER := 0;
g_count_rldt                    NUMBER := 0;
g_count_list_line               NUMBER := 0;


/***********************************************************************
* Function to check if a list_line is a benefit line for a coupon line *
************************************************************************/

FUNCTION  LINE_EXISTS_IN_RLTD(p_list_line_id IN NUMBER)
RETURN BOOLEAN
IS

l_return               BOOLEAN :=  FALSE;
l_to_rltd_modifier_id  NUMBER;

CURSOR  coupon_line_cur(a_list_line_id NUMBER)
IS
  SELECT to_rltd_modifier_id
  FROM   qp_rltd_modifiers
  WHERE  to_rltd_modifier_id = a_list_line_id
  AND    rltd_modifier_grp_type = 'COUPON';

BEGIN

  OPEN  coupon_line_cur(p_list_line_id);
  FETCH coupon_line_cur
  INTO  l_to_rltd_modifier_id;

  IF coupon_line_cur%FOUND THEN
    l_return := TRUE;
  ELSE
    l_return := FALSE;
  END IF;

  CLOSE coupon_line_cur;

  RETURN l_return;

END LINE_EXISTS_IN_RLTD;

/***************************************************************
* Procedure to insert records into the criteria tables *
****************************************************************/

Procedure INSERT_CRITERIA
(
 p_archive_name                       VARCHAR2,
 p_entity_type                        VARCHAR2,
 p_source_system_code                 VARCHAR2,
 p_entity                             NUMBER,
 p_all_lines                          VARCHAR2,
 p_product_context                    VARCHAR2,
 p_product_attribute                  VARCHAR2,
 p_product_attr_value_from            VARCHAR2,
 p_product_attr_value_to              VARCHAR2,
 p_start_date_active                  VARCHAR2,
 p_end_date_active                    VARCHAR2,
 p_creation_date                      VARCHAR2,
 p_created_by                         NUMBER,
 p_user_id                            NUMBER,
 p_conc_request_id                    NUMBER,
 p_result_status                      VARCHAR2
)
IS
BEGIN

insert into QP_ARCH_CRITERIA_HEADERS
(REQUEST_ID,
REQUEST_NAME,
REQUEST_TYPE,
SOURCE_SYSTEM,
CREATION_DATE,
CREATED_BY,
REQUEST_STATUS,
purge_flag)
values
(p_conc_request_id,
p_archive_name,
'ARCHIVE',
p_source_system_code,
sysdate,
p_user_id,
p_result_status,
'N');

insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values
(p_conc_request_id,
'ENTITY_TYPE',
p_entity_type);

insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values
(p_conc_request_id,
'ENTITY',
p_entity);

IF nvl(p_all_lines,'N') = 'Y' THEN

insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values
(p_conc_request_id,
'ALL_LINES',
p_all_lines);


ELSE --All Lines not checked

  IF p_product_context is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
   'PRODUCT_CONTEXT',
    p_product_context);

  END IF;

  IF p_product_attribute is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
   'PRODUCT_ATTRIBUTE',
    p_product_attribute);

  END IF;

  IF p_product_attr_value_from is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
   'PRODUCT_ATTR_VALUE_FROM',
    p_product_attr_value_from);

  END IF;

  IF p_product_attr_value_to is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
    'PRODUCT_ATTR_VALUE_TO',
    p_product_attr_value_to);

  END IF;

  IF p_start_date_active is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
    'START_DATE_ACTIVE',
    fnd_date.canonical_to_date(p_start_date_active));

  END IF;

  IF p_end_date_active is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
    'END_DATE_ACTIVE',
    fnd_date.canonical_to_date(p_end_date_active));

  END IF;

  IF p_created_by is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
    'CREATED_BY',
    p_created_by);

  END IF;

  IF p_creation_date is not null THEN

  insert into QP_ARCH_CRITERIA_LINES
  (request_id,
   parameter_name,
   parameter_value)
   values
   (p_conc_request_id,
    'CREATION_DATE',
    fnd_date.canonical_to_date(p_creation_date));

  END IF;

END IF; -- all lines check

END INSERT_CRITERIA;


/**********************************************************************
* Procedure to delete the non endated child lines of PBH/PRG/OID
  parent lines because these are not selected by the archive criteria
  if the end date is specified in the archive criteria              *
***********************************************************************/


Procedure DELETE_CHILD
(
p_to_rltd_modifier_id NUMBER,
p_conc_request_id     NUMBER
)
IS

l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER   := NULL;


CURSOR qp_pricing_attributes_cur(p_from_list_line_id NUMBER)
IS
    SELECT *
    FROM   qp_pricing_attributes
    WHERE  list_line_id = p_from_list_line_id;

BEGIN

--Insert into QP_ARCH_LIST_LINES

INSERT INTO QP_ARCH_LIST_LINES
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
     recurring_value,
     LIST_PRICE_UOM_CODE,
     BASE_QTY,
     BASE_UOM_CODE,
     ACCRUAL_QTY,
     ACCRUAL_UOM_CODE,
     RECURRING_FLAG,
     LIMIT_EXISTS_FLAG,
     GROUP_COUNT,
     NET_AMOUNT_FLAG,
     CUSTOMER_ITEM_ID
     ,ACCUM_CONTEXT
     ,ACCUM_ATTRIBUTE
     ,ACCUM_ATTR_RUN_SRC_FLAG
     ,BREAK_UOM_CODE
     ,BREAK_UOM_CONTEXT
     ,BREAK_UOM_ATTRIBUTE
     ,PATTERN_ID
     ,PRODUCT_UOM_CODE
     ,PRICING_ATTRIBUTE_COUNT
     ,HASH_KEY
     ,CACHE_KEY
     ,ARCH_PURG_REQUEST_ID
    )
    SELECT
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
     recurring_value,
     LIST_PRICE_UOM_CODE,
     BASE_QTY,
     BASE_UOM_CODE,
     ACCRUAL_QTY,
     ACCRUAL_UOM_CODE,
     RECURRING_FLAG,
     LIMIT_EXISTS_FLAG,
     GROUP_COUNT,
     NET_AMOUNT_FLAG,
     CUSTOMER_ITEM_ID
     ,ACCUM_CONTEXT
     ,ACCUM_ATTRIBUTE
     ,ACCUM_ATTR_RUN_SRC_FLAG
     ,BREAK_UOM_CODE
     ,BREAK_UOM_CONTEXT
     ,BREAK_UOM_ATTRIBUTE
     ,PATTERN_ID
     ,PRODUCT_UOM_CODE
     ,PRICING_ATTRIBUTE_COUNT
     ,HASH_KEY
     ,CACHE_KEY
     ,p_conc_request_id
FROM QP_LIST_LINES
WHERE list_line_id = p_to_rltd_modifier_id;
g_count_list_line:=g_count_list_line + sql%rowcount;

--Delete from QP_LIST_LINES

DELETE FROM QP_LIST_LINES WHERE list_line_id = p_to_rltd_modifier_id;

--Archive the pricing attributes

FOR l_qp_pricing_attributes_rec IN qp_pricing_attributes_cur (p_to_rltd_modifier_id)
    LOOP
IF l_qp_pricing_attributes_rec.pricing_attribute_datatype = 'N'
    THEN

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

END IF;

--Insert into QP_ARCH_PRICING_ATTRIBUTES

INSERT INTO QP_ARCH_PRICING_ATTRIBUTES
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
 	   pricing_attr_value_to_number,
           DISTINCT_ROW_COUNT,
           SEARCH_IND,
           PATTERN_VALUE_FROM_POSITIVE,
           PATTERN_VALUE_TO_POSITIVE,
           PATTERN_VALUE_FROM_NEGATIVE,
           PATTERN_VALUE_TO_NEGATIVE,
           PRODUCT_SEGMENT_ID,
           PRICING_SEGMENT_ID,
           ARCH_PURG_REQUEST_ID
      )
      VALUES
      (l_qp_pricing_attributes_rec.pricing_attribute_id,
  	 l_qp_pricing_attributes_rec.creation_date,
 	 l_qp_pricing_attributes_rec.created_by,
	 l_qp_pricing_attributes_rec.last_update_date,
	 l_qp_pricing_attributes_rec.last_updated_by,
 	 l_qp_pricing_attributes_rec.last_update_login,
 	 l_qp_pricing_attributes_rec.program_application_id,
 	 l_qp_pricing_attributes_rec.program_id,
 	 l_qp_pricing_attributes_rec.program_update_date,
 	 l_qp_pricing_attributes_rec.request_id,
 	 l_qp_pricing_attributes_rec.list_line_id,
	 l_qp_pricing_attributes_rec.list_header_id,
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
	 l_pric_attr_value_to_number,
         l_qp_pricing_attributes_rec.DISTINCT_ROW_COUNT,
         l_qp_pricing_attributes_rec.SEARCH_IND,
         l_qp_pricing_attributes_rec.PATTERN_VALUE_FROM_POSITIVE,
         l_qp_pricing_attributes_rec.PATTERN_VALUE_TO_POSITIVE,
         l_qp_pricing_attributes_rec.PATTERN_VALUE_FROM_NEGATIVE,
         l_qp_pricing_attributes_rec.PATTERN_VALUE_TO_NEGATIVE,
         l_qp_pricing_attributes_rec.PRODUCT_SEGMENT_ID,
         l_qp_pricing_attributes_rec.PRICING_SEGMENT_ID,
         p_conc_request_id
	 );
g_count_pricing_att := g_count_pricing_att + sql%rowcount;

--Delete the records from qp_pricing_attributes table

DELETE FROM QP_PRICING_ATTRIBUTES WHERE pricing_attribute_id = l_qp_pricing_attributes_rec.pricing_attribute_id
and list_line_id = l_qp_pricing_attributes_rec.list_line_id
and list_header_id = l_qp_pricing_attributes_rec.list_header_id;

    END LOOP; /* Cursor qp_pricing_attributes_cur LOOP */

END DELETE_CHILD;


/************************************************************************
*Procedure to Archive The Price list or the Modifier List  *
*************************************************************************/


PROCEDURE ARCHIVE_ENTITY
(
 errbuf                    OUT  NOCOPY  VARCHAR2,
 retcode                   OUT  NOCOPY  NUMBER,
 p_archive_name    	   IN      	VARCHAR2,
 p_entity_type     	   IN      	VARCHAR2,
 p_source_system_code	   IN      	VARCHAR2,
 p_entity     		   IN      	NUMBER,
 p_all_lines		   IN		VARCHAR2,
 p_product_context	   IN      	VARCHAR2,
 p_product_attribute       IN      	VARCHAR2,
 p_product_attr_value_from IN		VARCHAR2,
 p_product_attr_value_to   IN     	VARCHAR2,
 p_start_date_active	   IN      	VARCHAR2,
 p_end_date_active         IN   	VARCHAR2,
 p_creation_date           IN      	VARCHAR2,
 p_created_by	           IN		NUMBER,
 p_segment1_lohi           IN		VARCHAR2,
 p_segment2_lohi           IN		VARCHAR2,
 p_segment3_lohi           IN		VARCHAR2,
 p_segment4_lohi           IN		VARCHAR2,
 p_segment5_lohi           IN		VARCHAR2,
 p_segment6_lohi           IN		VARCHAR2,
 p_segment7_lohi           IN		VARCHAR2,
 p_segment8_lohi           IN		VARCHAR2,
 p_segment9_lohi           IN		VARCHAR2,
 p_segment10_lohi          IN		VARCHAR2,
 p_segment11_lohi          IN		VARCHAR2,
 p_segment12_lohi          IN		VARCHAR2,
 p_segment13_lohi          IN		VARCHAR2,
 p_segment14_lohi          IN		VARCHAR2,
 p_segment15_lohi          IN		VARCHAR2,
 p_segment16_lohi          IN		VARCHAR2,
 p_segment17_lohi          IN		VARCHAR2,
 p_segment18_lohi          IN		VARCHAR2,
 p_segment19_lohi          IN		VARCHAR2,
 p_segment20_lohi          IN		VARCHAR2
)
IS

l_conc_request_id		NUMBER := -1;
l_conc_program_application_id	NUMBER := -1;
l_conc_program_id		NUMBER := -1;
l_conc_login_id		   	NUMBER := -1;
l_user_id			NUMBER := -1;

l_insert_flag varchar2(1);
l_cnt number:=0;
l_err_count number:=0;

TYPE qp_list_lines_rec IS RECORD (
list_line_id				QP_LIST_LINES.list_line_id%TYPE,
creation_date				QP_LIST_LINES.creation_date%TYPE,
created_by				QP_LIST_LINES.created_by%TYPE,
last_update_date			QP_LIST_LINES.last_update_date%TYPE,
last_updated_by				QP_LIST_LINES.last_updated_by%TYPE,
last_update_login			QP_LIST_LINES.last_update_login%TYPE,
program_application_id			QP_LIST_LINES.program_application_id%TYPE,
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
organization_id				QP_LIST_LINES.organization_id%TYPE,
related_item_id				QP_LIST_LINES.related_item_id%TYPE,
relationship_type_id			QP_LIST_LINES.relationship_type_id%TYPE,
substitution_context			QP_LIST_LINES.substitution_context%TYPE,
substitution_attribute			QP_LIST_LINES.substitution_attribute%TYPE,
substitution_value			QP_LIST_LINES.substitution_value%TYPE,
revision				QP_LIST_LINES.revision%TYPE,
revision_date				QP_LIST_LINES.revision_date%TYPE,
revision_reason_code			QP_LIST_LINES.revision_reason_code%TYPE,
context					QP_LIST_LINES.context%TYPE,
attribute1				QP_LIST_LINES.attribute1%TYPE,
attribute2				QP_LIST_LINES.attribute2%TYPE,
comments				QP_LIST_LINES.comments%TYPE,
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
price_break_type_code			QP_LIST_LINES.price_break_type_code%TYPE,
percent_price				QP_LIST_LINES.percent_price%TYPE,
price_by_formula_id			QP_LIST_LINES.price_by_formula_id%TYPE,
number_effective_periods		QP_LIST_LINES.number_effective_periods%TYPE,
effective_period_uom			QP_LIST_LINES.effective_period_uom%TYPE,
arithmetic_operator			QP_LIST_LINES.arithmetic_operator%TYPE,
operand					QP_LIST_LINES.operand%TYPE,
override_flag				QP_LIST_LINES.override_flag%TYPE,
print_on_invoice_flag			QP_LIST_LINES.print_on_invoice_flag%TYPE,
rebate_transaction_type_code		QP_LIST_LINES.rebate_transaction_type_code%TYPE,
estim_accrual_rate			QP_LIST_LINES.estim_accrual_rate%TYPE,
generate_using_formula_id		QP_LIST_LINES.generate_using_formula_id%TYPE,
start_date_active			QP_LIST_LINES.start_date_active%TYPE,
end_date_active				QP_LIST_LINES.end_date_active%TYPE,
reprice_flag				QP_LIST_LINES.reprice_flag%TYPE,
accrual_flag                  		QP_LIST_LINES.accrual_flag%TYPE,
pricing_group_sequence        		QP_LIST_LINES.pricing_group_sequence%TYPE,
incompatibility_grp_code      		QP_LIST_LINES.incompatibility_grp_code%TYPE,
list_line_no                  		QP_LIST_LINES.list_line_no%TYPE,
product_precedence            		QP_LIST_LINES.product_precedence%TYPE,
pricing_phase_id              		QP_LIST_LINES.pricing_phase_id%TYPE,
expiration_period_start_date  		QP_LIST_LINES.expiration_period_start_date%TYPE,
number_expiration_periods     		QP_LIST_LINES.number_expiration_periods%TYPE,
expiration_period_uom         		QP_LIST_LINES.expiration_period_uom%TYPE,
expiration_date               		QP_LIST_LINES.expiration_date%TYPE,
estim_gl_value                		QP_LIST_LINES.estim_gl_value%TYPE,
accrual_conversion_rate       		QP_LIST_LINES.accrual_conversion_rate%TYPE,
benefit_price_list_line_id    		QP_LIST_LINES.benefit_price_list_line_id%TYPE,
proration_type_code           		QP_LIST_LINES.proration_type_code%TYPE,
benefit_qty                   		QP_LIST_LINES.benefit_qty%TYPE,
benefit_uom_code              		QP_LIST_LINES.benefit_uom_code%TYPE,
charge_type_code              		QP_LIST_LINES.charge_type_code%TYPE,
charge_subtype_code           		QP_LIST_LINES.charge_subtype_code%TYPE,
benefit_limit                		QP_LIST_LINES.benefit_limit%TYPE,
include_on_returns_flag       		QP_LIST_LINES.include_on_returns_flag%TYPE,
qualification_ind             		QP_LIST_LINES.qualification_ind%TYPE,
recurring_value               	 	QP_LIST_LINES.recurring_value%TYPE,
LIST_PRICE_UOM_CODE           		QP_LIST_LINES.LIST_PRICE_UOM_CODE%TYPE,
BASE_QTY                      		QP_LIST_LINES.BASE_QTY%TYPE,
BASE_UOM_CODE                 		QP_LIST_LINES.BASE_UOM_CODE%TYPE,
ACCRUAL_QTY                   		QP_LIST_LINES.ACCRUAL_QTY%TYPE,
ACCRUAL_UOM_CODE              		QP_LIST_LINES.ACCRUAL_UOM_CODE%TYPE,
RECURRING_FLAG                		QP_LIST_LINES.RECURRING_FLAG%TYPE,
LIMIT_EXISTS_FLAG             		QP_LIST_LINES.LIMIT_EXISTS_FLAG%TYPE,
GROUP_COUNT                   		QP_LIST_LINES.GROUP_COUNT%TYPE
,NET_AMOUNT_FLAG            		QP_LIST_LINES.NET_AMOUNT_FLAG%TYPE
,CUSTOMER_ITEM_ID              		QP_LIST_LINES.CUSTOMER_ITEM_ID%TYPE
,ACCUM_CONTEXT              		QP_LIST_LINES.ACCUM_CONTEXT%TYPE
,ACCUM_ATTRIBUTE            		QP_LIST_LINES.ACCUM_ATTRIBUTE%TYPE
,ACCUM_ATTR_RUN_SRC_FLAG    		QP_LIST_LINES.ACCUM_ATTR_RUN_SRC_FLAG%TYPE
,BREAK_UOM_CODE             		QP_LIST_LINES.BREAK_UOM_CODE%TYPE
,BREAK_UOM_CONTEXT          		QP_LIST_LINES.BREAK_UOM_CONTEXT%TYPE
,BREAK_UOM_ATTRIBUTE        		QP_LIST_LINES.BREAK_UOM_ATTRIBUTE%TYPE
,PATTERN_ID                             QP_LIST_LINES.PATTERN_ID%TYPE
,PRODUCT_UOM_CODE                       QP_LIST_LINES.PRODUCT_UOM_CODE%TYPE
,PRICING_ATTRIBUTE_COUNT                QP_LIST_LINES.PRICING_ATTRIBUTE_COUNT%TYPE
,HASH_KEY                               QP_LIST_LINES.HASH_KEY%TYPE
,CACHE_KEY                              QP_LIST_LINES.CACHE_KEY%TYPE
);

l_mapping_tbl                 mapping_tbl;
l_select_stmt	 	      VARCHAR2(9000);
l_qp_list_lines_rec	      QP_LIST_LINES_REC;
l_context		      VARCHAR2(30);
l_attribute		      VARCHAR2(30);
l_count                       NUMBER := 0;

l_pric_attr_value_from_number NUMBER := NULL;
l_pric_attr_value_to_number NUMBER := NULL;

l_list_type_code VARCHAR2(30) := '';
l_qual_attr_value_from_number NUMBER := NULL;
l_qual_attr_value_to_number NUMBER := NULL;
l_min_date date := to_date('01/01/1900','DD/MM/YYYY');
l_max_date date := to_date('31/12/9999','DD/MM/YYYY');

TYPE lines_cur_typ IS REF CURSOR;
qp_list_lines_cv 		     lines_cur_typ;

CURSOR qp_pricing_attributes_cur(p_from_list_line_id NUMBER)
IS
    SELECT *
    FROM   qp_pricing_attributes
    WHERE  list_line_id = p_from_list_line_id;

CURSOR qp_headers_qualifiers_cur(p_from_discount_header_id    NUMBER)
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


 /* First part of cursor qp_qualifiers_cur selects qualifiers while the second part
    selects secondary price list */

CURSOR qp_qualifiers_cur(p_from_list_header_id NUMBER, p_context VARCHAR2,
					p_attribute VARCHAR2)
IS
    SELECT *
    FROM   qp_qualifiers q
    WHERE (q.list_header_id = p_from_list_header_id AND
           q.qualifier_attribute <> p_attribute AND
          Exists (Select Null
                From   qp_list_headers_b a
                Where  a.list_header_id = p_from_list_header_id
                And    a.list_type_code = 'PRL'
                   )
           )
           OR
          (q.qualifier_context = p_context AND
           q.qualifier_attribute = p_attribute AND
           q.qualifier_attr_value = TO_CHAR(p_from_list_header_id) AND
           EXISTS (select null from qp_list_headers_b a
           where a.list_header_id =q.list_header_id
           And    a.list_type_code = 'PRL')
          );

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

/* Validate number of list lines selected. If there are zero lines selected for the given search criteria, throw error message. */

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
        q.recurring_value,
        q.LIST_PRICE_UOM_CODE,
        q.BASE_QTY,
        q.BASE_UOM_CODE,
        q.ACCRUAL_QTY,
        q.ACCRUAL_UOM_CODE,
        q.RECURRING_FLAG,
        q.LIMIT_EXISTS_FLAG,
        q.GROUP_COUNT
        ,q.NET_AMOUNT_FLAG
        ,q.CUSTOMER_ITEM_ID
        ,q.ACCUM_CONTEXT
        ,q.ACCUM_ATTRIBUTE
        ,q.ACCUM_ATTR_RUN_SRC_FLAG
        ,q.BREAK_UOM_CODE
        ,q.BREAK_UOM_CONTEXT
        ,q.BREAK_UOM_ATTRIBUTE
        ,q.PATTERN_ID
        ,q.PRODUCT_UOM_CODE
        ,q.PRICING_ATTRIBUTE_COUNT
        ,q.HASH_KEY
        ,q.CACHE_KEY
    FROM qp_list_lines q
    WHERE  q.list_header_id = :hdr
    and nvl(trunc(q.start_date_active),fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(l_min_date)||'''))
    >=nvl(trunc(fnd_date.canonical_to_date(:sdat)),
    nvl(trunc(q.start_date_active),fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(l_min_date)||''')))
    and nvl(trunc(q.end_date_active),fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(l_max_date)||'''))
    <=nvl(trunc(fnd_date.canonical_to_date(:edat)),
    nvl(trunc(q.end_date_active),fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(l_max_date)||''')))
    and q.created_by=nvl(:usr,q.created_by)
    and trunc(q.creation_date)=nvl(trunc(fnd_date.canonical_to_date(:cdat)),trunc(q.creation_date))';

/* Check whether all_lines check box is checked if yes then archive all the lines in the pricing entity */
IF nvl(p_all_lines,'N') = 'N' THEN
   IF p_product_context is not NULL THEN
      l_select_stmt := l_select_stmt || 'AND    q.list_line_id IN
    	(SELECT DISTINCT a.list_line_id
	FROM   qp_pricing_attributes a
	WHERE  a.list_line_id = q.list_line_id
        and EXCLUDER_FLAG =''N''';   --This would take care of Exculded Items.

      IF p_product_attribute = 'PRICING_ATTRIBUTE1' THEN
         IF (p_segment1_lohi <> ''''' AND ''''') OR (p_segment2_lohi <> ''''' AND ''''')
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
               l_select_stmt := l_select_stmt ||
                               'AND a.product_attribute_context = ''ITEM''
                                AND a.product_attribute = ''PRICING_ATTRIBUTE1''
                                AND EXISTS
                   	           (SELECT ''X''
	                            FROM  mtl_system_items m
	                            WHERE  (m.inventory_item_id = TO_NUMBER(a.product_attr_value)) ';

               IF (p_segment1_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment1   BETWEEN ' || p_segment1_lohi || ') ';
               END IF;
               IF (p_segment2_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment2   BETWEEN ' || p_segment2_lohi || ') ';
               END IF;
               IF (p_segment3_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment3   BETWEEN ' || p_segment3_lohi || ') ';
               END IF;
               IF (p_segment4_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                  'AND (m.segment4   BETWEEN ' || p_segment4_lohi || ') ';
               END IF;
               IF (p_segment5_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment5   BETWEEN ' || p_segment5_lohi || ') ';
               END IF;
               IF (p_segment6_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment6   BETWEEN ' || p_segment6_lohi || ') ';
               END IF;
               IF (p_segment7_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment7   BETWEEN ' || p_segment7_lohi || ') ';
               END IF;
               IF (p_segment8_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment8   BETWEEN ' || p_segment8_lohi || ') ';
               END IF;
               IF (p_segment9_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment9   BETWEEN ' || p_segment9_lohi || ') ';
               END IF;
               IF (p_segment10_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment10   BETWEEN ' || p_segment10_lohi || ') ';
               END IF;
               IF (p_segment11_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment10   BETWEEN ' || p_segment11_lohi || ') ';
               END IF;
               IF (p_segment12_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment12   BETWEEN ' || p_segment12_lohi || ') ';
               END IF;
               IF (p_segment13_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment13   BETWEEN ' || p_segment13_lohi || ') ';
               END IF;
               IF (p_segment14_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment14   BETWEEN ' || p_segment14_lohi || ') ';
               END IF;
               IF (p_segment15_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment15   BETWEEN ' || p_segment15_lohi || ') ';
               END IF;
               IF (p_segment16_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment16   BETWEEN ' || p_segment16_lohi || ') ';
               END IF;
               IF (p_segment17_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment17   BETWEEN ' || p_segment17_lohi || ') ';
               END IF;
               IF (p_segment18_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment18   BETWEEN ' || p_segment18_lohi || ') ';
               END IF;
               IF (p_segment19_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment19   BETWEEN ' || p_segment19_lohi || ') ';
               END IF;
               IF (p_segment20_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment20   BETWEEN ' || p_segment20_lohi || ') ';
               END IF;

               l_select_stmt := l_select_stmt || ') )';
         ELSE
               l_select_stmt := l_select_stmt || ') ';
         END IF;

      ELSIF p_product_attribute = 'PRICING_ATTRIBUTE2' THEN
         IF (p_product_attr_value_from <> ''''' AND ''''')  THEN
         --IF (p_product_attr_value_from is not null)  THEN
               l_select_stmt := l_select_stmt ||
                                'AND a.product_attribute_context = ''ITEM''
                                 AND a.product_attribute = ''PRICING_ATTRIBUTE2''
                                 AND a.product_attr_value = ''' || p_product_attr_value_from || ''') ';
         END IF;
         /*
         IF (p_segment1_lohi <> ''''' AND ''''') OR (p_segment2_lohi <> ''''' AND ''''')
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

               l_select_stmt := l_select_stmt ||
                                'AND a.product_attribute_context = ''ITEM''
                                 AND a.product_attribute = ''PRICING_ATTRIBUTE2''
                                 AND EXISTS
                                     (SELECT ''X''
                                      FROM  MTL_CATEGORIES m
                                      WHERE  (m.CATEGORY_ID = TO_NUMBER(a.product_attr_value)) ';

               IF (p_segment1_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment1   BETWEEN ' || p_segment1_lohi || ') ';
               END IF;
               IF (p_segment2_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment2   BETWEEN ' || p_segment2_lohi || ') ';
               END IF;
               IF (p_segment3_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment3   BETWEEN ' || p_segment3_lohi || ') ';
               END IF;
               IF (p_segment4_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment4   BETWEEN ' || p_segment4_lohi || ') ';
               END IF;
               IF (p_segment5_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment5   BETWEEN ' || p_segment5_lohi || ') ';
               END IF;
               IF (p_segment6_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment6   BETWEEN ' || p_segment6_lohi || ') ';
               END IF;
               IF (p_segment7_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment7   BETWEEN ' || p_segment7_lohi || ') ';
               END IF;
               IF (p_segment8_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment8   BETWEEN ' || p_segment8_lohi || ') ';
               END IF;
               IF (p_segment9_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment9   BETWEEN ' || p_segment9_lohi || ') ';
               END IF;
               IF (p_segment10_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment10   BETWEEN ' || p_segment10_lohi || ') ';
               END IF;
               IF (p_segment11_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment10   BETWEEN ' || p_segment11_lohi || ') ';
               END IF;
               IF (p_segment12_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment12   BETWEEN ' || p_segment12_lohi || ') ';
               END IF;
               IF (p_segment13_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment13   BETWEEN ' || p_segment13_lohi || ') ';
               END IF;
               IF (p_segment14_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment14   BETWEEN ' || p_segment14_lohi || ') ';
               END IF;
               IF (p_segment15_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment15   BETWEEN ' || p_segment15_lohi || ') ';
               END IF;
               IF (p_segment16_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment16   BETWEEN ' || p_segment16_lohi || ') ';
               END IF;
               IF (p_segment17_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                  'AND (m.segment17   BETWEEN ' || p_segment17_lohi || ') ';
               END IF;
               IF (p_segment18_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment18   BETWEEN ' || p_segment18_lohi || ') ';
               END IF;
               IF (p_segment19_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment19   BETWEEN ' || p_segment19_lohi || ') ';
               END IF;
               IF (p_segment20_lohi <> ''''' AND ''''') THEN
                  l_select_stmt := l_select_stmt ||
                                   'AND (m.segment20   BETWEEN ' || p_segment20_lohi || ') ';
               END IF;

               l_select_stmt := l_select_stmt || ') )';
         ELSE
               l_select_stmt := l_select_stmt || ') ';
         END IF;
               */
     ELSE
        l_select_stmt := l_select_stmt ||
                         'AND a.product_attribute_context = ''ITEM''
                          AND (a.product_attribute = ''' || p_product_attribute|| ''')
                          AND (a.product_attr_value = ''' || p_product_attr_value_from|| ''') ';
        l_select_stmt := l_select_stmt || ') ';
     END IF; --Pricing Attribute end
   ELSE --Product_context is null
   -- changed the not in condition to in for the bug 7315038
     l_select_stmt := l_select_stmt || 'AND q.list_line_id in  (SELECT DISTINCT a.list_line_id
   	                                                            FROM qp_pricing_attributes a
	                                                            WHERE  a.list_line_id = q.list_line_id)';
   END IF; -- Product_context end
ELSE
   l_select_stmt := l_select_stmt || 'AND q.list_line_id not in  (SELECT DISTINCT a.to_rltd_modifier_id
                                                                  FROM   qp_rltd_modifiers a
                                                                  WHERE  a.to_rltd_modifier_id = q.list_line_id)';
END IF;  --all_lines end

OPEN qp_list_lines_cv FOR l_select_stmt USING p_entity,p_start_date_active,p_end_date_active,p_created_by,p_creation_date;
FETCH qp_list_lines_cv INTO l_qp_list_lines_rec;
if(qp_list_lines_cv%NOTFOUND) THEN -- No list lines found satisfying the search criteria entered.
    CLOSE qp_list_lines_cv;
    RAISE NO_DATA_FOUND;
end if;
CLOSE qp_list_lines_cv;

/** Following code inserts pricing entity list header information into QP_ARCH_LIST_HEADERS_B **/

INSERT INTO QP_ARCH_LIST_HEADERS_B
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
 currency_header_id,
 pte_code,
 global_flag,
 orig_org_id,
 LIMIT_EXISTS_FLAG,
 MOBILE_DOWNLOAD,
 LIST_SOURCE_CODE,
 ORIG_SYSTEM_HEADER_REF,
 SHAREABLE_FLAG,
 SOLD_TO_ORG_ID,
 ARCH_PURG_REQUEST_ID
)
SELECT
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
 currency_header_id,
 pte_code,
 global_flag,
 orig_org_id,
 LIMIT_EXISTS_FLAG,
 MOBILE_DOWNLOAD,
 LIST_SOURCE_CODE,
 ORIG_SYSTEM_HEADER_REF,
 SHAREABLE_FLAG,
 SOLD_TO_ORG_ID,
 l_conc_request_id
FROM  qp_list_headers_b
WHERE list_header_id = p_entity;

--Insert the count of records from QP_ARCH_LIST_HEADERS_B into QP_ARCH_ROW_COUNTS
g_count_header_b:=sql%rowcount;
insert into QP_ARCH_ROW_COUNTS (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_LIST_HEADERS_B',g_count_header_b);

/** Following code inserts pricing entity list header information into QP_ARCH_LIST_HEADERS_TL **/
INSERT INTO QP_ARCH_LIST_HEADERS_TL
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
 version_no,
 ARCH_PURG_REQUEST_ID
)
SELECT
last_update_login,
name,
description,
creation_date,
created_by,
last_update_date,
last_updated_by,
list_header_id,
language,
source_lang,
version_no,
l_conc_request_id
FROM  qp_list_headers_tl
WHERE list_header_id = p_entity;

--Insert the count of records from QP_ARCH_LIST_HEADERS_TL into QP_ARCH_ROW_COUNTS
g_count_header_tl:=sql%rowcount;
insert into QP_ARCH_ROW_COUNTS (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_LIST_HEADERS_TL',g_count_header_tl);

/** Following code inserts pricing entity header qualifier information **/
BEGIN
SELECT LIST_TYPE_CODE
       INTO    l_list_type_code
FROM   QP_LIST_HEADERS_B
WHERE  LIST_HEADER_ID = p_entity;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;

--Following code archives Price List header qualifier information
IF l_list_type_code = 'PRL' THEN
   IF QP_UTIL.Attrmgr_Installed = 'Y' THEN
      QP_UTIL.Get_Context_Attribute('PRICE_LIST', l_context, l_attribute);
   ELSE
      QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);
   END IF;

   FOR l_qp_qualifiers_rec IN qp_qualifiers_cur(p_entity, l_context,l_attribute)
   LOOP
      IF l_qp_qualifiers_rec.qualifier_datatype = 'N' THEN
      BEGIN
         l_qual_attr_value_from_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);
         l_qual_attr_value_to_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);
      EXCEPTION
         WHEN VALUE_ERROR THEN
 	    NULL;
         WHEN OTHERS THEN
            NULL;
      END;
      END IF;

      --Insert into QP_ARCH_QUALIFIERS
     INSERT INTO QP_ARCH_QUALIFIERS
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
      OTHERS_GROUP_CNT,
      SEGMENT_ID,
      ARCH_PURG_REQUEST_ID
     )
     VALUES
     (
      l_qp_qualifiers_rec.qualifier_id,
      l_qp_qualifiers_rec.creation_date,
      l_qp_qualifiers_rec.created_by,
      l_qp_qualifiers_rec.last_update_date,
      l_qp_qualifiers_rec.last_updated_by,
      l_qp_qualifiers_rec.last_update_login,
      l_qp_qualifiers_rec.program_application_id,
      l_qp_qualifiers_rec.program_id,
      l_qp_qualifiers_rec.program_update_date,
      l_qp_qualifiers_rec.request_id,
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
      l_qp_qualifiers_rec.active_flag,
      l_qp_qualifiers_rec.list_type_code,
      l_qual_attr_value_from_number,
      l_qual_attr_value_to_number,
      l_qp_qualifiers_rec.search_ind,
      l_qp_qualifiers_rec.distinct_row_count,
      l_qp_qualifiers_rec.qualifier_group_cnt,
      l_qp_qualifiers_rec.header_quals_exist_flag,
      l_qp_qualifiers_rec.others_group_cnt,
      l_qp_qualifiers_rec.segment_id,
      l_conc_request_id
   );

   g_count_qualifier := g_count_qualifier + sql%rowcount;
   END LOOP;

ELSE --Modifier and agreement price list
   --Following code archives the Modifier header qualifier information
   FOR l_qp_qualifiers_rec IN qp_headers_qualifiers_cur(p_entity)
   LOOP
      IF l_qp_qualifiers_rec.qualifier_datatype = 'N' THEN
      BEGIN
         l_qual_attr_value_from_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);
         l_qual_attr_value_to_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);
      EXCEPTION
         WHEN VALUE_ERROR THEN
            NULL;
         WHEN OTHERS THEN
            NULL;
      END;
      END IF;

      --Insert into QP_ARCH_QUALIFIERS
      INSERT INTO QP_ARCH_QUALIFIERS
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
       OTHERS_GROUP_CNT,
       segment_id,
       ARCH_PURG_REQUEST_ID
      )
      VALUES
      (
       l_qp_qualifiers_rec.qualifier_id,
       l_qp_qualifiers_rec.creation_date,
       l_qp_qualifiers_rec.created_by,
       l_qp_qualifiers_rec.last_update_date,
       l_qp_qualifiers_rec.last_updated_by,
       l_qp_qualifiers_rec.last_update_login,
       l_qp_qualifiers_rec.program_application_id,
       l_qp_qualifiers_rec.program_id,
       l_qp_qualifiers_rec.program_update_date,
       l_qp_qualifiers_rec.request_id,
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
       l_qp_qualifiers_rec.active_flag,
       l_qp_qualifiers_rec.list_type_code,
       l_qual_attr_value_from_number,
       l_qual_attr_value_to_number,
       l_qp_qualifiers_rec.search_ind,
       l_qp_qualifiers_rec.distinct_row_count,
       l_qp_qualifiers_rec.qualifier_group_cnt,
       l_qp_qualifiers_rec.header_quals_exist_flag,
       l_qp_qualifiers_rec.others_group_cnt,
       l_qp_qualifiers_rec.segment_id,
       l_conc_request_id
      );

      g_count_qualifier := g_count_qualifier + sql%rowcount;
   END LOOP;

END IF;

/** Following code Archives price list lines information.**/
OPEN qp_list_lines_cv FOR l_select_stmt USING p_entity,p_start_date_active,p_end_date_active,p_created_by,p_creation_date;
LOOP
   FETCH qp_list_lines_cv INTO l_qp_list_lines_rec;
   EXIT WHEN qp_list_lines_cv%NOTFOUND;

   l_insert_flag := 'N'; --Reset the flag

   --Check if limit exists
   IF nvl(l_qp_list_lines_rec.LIMIT_EXISTS_FLAG,'N') = 'N' THEN
      l_insert_flag :='Y';

      -- Check if line part of a formula
      SELECT count(*) into l_cnt
      FROM QP_PRICE_FORMULA_LINES
      WHERE PRICE_FORMULA_LINE_TYPE_CODE = 'PLL'
      AND PRICE_LIST_LINE_ID=l_qp_list_lines_rec.list_line_id;

      IF l_cnt=0 THEN
         l_insert_flag :='Y';
      ELSE
         l_insert_flag :='N';
         fnd_file.put_line(FND_FILE.LOG,'Price List line used in formula.Do not archive : '||l_qp_list_lines_rec.list_line_id);
	 l_err_count := l_err_count+1;
      END IF;

      IF l_insert_flag ='Y' THEN
         --Check if line a Coupon or a Benefit line or a parent to the same
	 IF l_list_type_code = 'PRO' or l_list_type_code = 'DEL' THEN
            IF (l_qp_list_lines_rec.list_line_type_code = 'CIE') OR
                LINE_EXISTS_IN_RLTD(l_qp_list_lines_rec.list_line_id) THEN
	 	l_insert_flag :='N';
                fnd_file.put_line(FND_FILE.LOG,'COUPON or related BENEFIT line.Do not archive : '||l_qp_list_lines_rec.list_line_id);
                l_err_count := l_err_count+1;
       	    END IF;
	 END IF;
      END IF;

      IF l_insert_flag ='Y' THEN
         INSERT INTO QP_ARCH_LIST_LINES
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
          recurring_value,
          LIST_PRICE_UOM_CODE,
          BASE_QTY,
          BASE_UOM_CODE,
          ACCRUAL_QTY,
          ACCRUAL_UOM_CODE,
          RECURRING_FLAG,
          LIMIT_EXISTS_FLAG,
          GROUP_COUNT,
          NET_AMOUNT_FLAG,
          CUSTOMER_ITEM_ID
          ,ACCUM_CONTEXT
          ,ACCUM_ATTRIBUTE
          ,ACCUM_ATTR_RUN_SRC_FLAG
          ,BREAK_UOM_CODE
          ,BREAK_UOM_CONTEXT
          ,BREAK_UOM_ATTRIBUTE
          ,PATTERN_ID
          ,PRODUCT_UOM_CODE
          ,PRICING_ATTRIBUTE_COUNT
          ,HASH_KEY
          ,CACHE_KEY
          ,ARCH_PURG_REQUEST_ID
         )
         VALUES
         (
          l_qp_list_lines_rec.list_line_id,
          l_qp_list_lines_rec.creation_date,
          l_qp_list_lines_rec.created_by,
          l_qp_list_lines_rec.last_update_date,
          l_qp_list_lines_rec.last_updated_by,
          l_qp_list_lines_rec.last_update_login,
          l_qp_list_lines_rec.program_application_id,
          l_qp_list_lines_rec.program_id,
          l_qp_list_lines_rec.program_update_date,
          l_qp_list_lines_rec.request_id,
          p_entity,
          l_qp_list_lines_rec.list_line_type_code,
          l_qp_list_lines_rec.start_date_active,
          l_qp_list_lines_rec.end_date_active,
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
          l_qp_list_lines_rec.recurring_value,
          l_qp_list_lines_rec.LIST_PRICE_UOM_CODE,
          l_qp_list_lines_rec.BASE_QTY,
          l_qp_list_lines_rec.BASE_UOM_CODE,
          l_qp_list_lines_rec.ACCRUAL_QTY,
          l_qp_list_lines_rec.ACCRUAL_UOM_CODE,
          l_qp_list_lines_rec.RECURRING_FLAG,
          l_qp_list_lines_rec.LIMIT_EXISTS_FLAG,
          l_qp_list_lines_rec.GROUP_COUNT,
          l_qp_list_lines_rec.NET_AMOUNT_FLAG,
          l_qp_list_lines_rec.CUSTOMER_ITEM_ID,
          l_qp_list_lines_rec.ACCUM_CONTEXT,
          l_qp_list_lines_rec.ACCUM_ATTRIBUTE,
          l_qp_list_lines_rec.ACCUM_ATTR_RUN_SRC_FLAG,
          l_qp_list_lines_rec.BREAK_UOM_CODE,
          l_qp_list_lines_rec.BREAK_UOM_CONTEXT,
          l_qp_list_lines_rec.BREAK_UOM_ATTRIBUTE,
          l_qp_list_lines_rec.PATTERN_ID  ,
          l_qp_list_lines_rec.PRODUCT_UOM_CODE,
          l_qp_list_lines_rec.PRICING_ATTRIBUTE_COUNT,
          l_qp_list_lines_rec.HASH_KEY ,
          l_qp_list_lines_rec.CACHE_KEY,
          l_conc_request_id
         );

         g_count_list_line:=g_count_list_line + sql%rowcount;

         /*If the list_line_rec is a Price Break Parent Line or a promotional or other item discount parent line then
	 store the list line id in a mapping-array for later use*/

         IF l_qp_list_lines_rec.list_line_type_code = 'PBH' OR
            l_qp_list_lines_rec.list_line_type_code = 'OID' OR
            l_qp_list_lines_rec.list_line_type_code = 'PRG' THEN

	    l_count := l_count + 1;
	    l_mapping_tbl(l_count).list_line_type_code := l_qp_list_lines_rec.list_line_type_code;
            l_mapping_tbl(l_count).list_line_id := l_qp_list_lines_rec.list_line_id;
         END IF;

         DELETE FROM QP_LIST_LINES WHERE list_line_id = l_qp_list_lines_rec.list_line_id and list_header_id = p_entity;

         /*Insert line level qualifiers in case of Modifiers */
         IF l_list_type_code NOT IN ('PRL','AGR') THEN
	    IF l_qp_list_lines_rec.list_line_id is not null AND
     	       l_qp_list_lines_rec.list_line_id  <> -1 THEN

               FOR l_qp_qualifiers_rec IN qp_line_qualifiers_cur(p_entity,l_qp_list_lines_rec.list_line_id)
               LOOP
                  IF l_qp_qualifiers_rec.qualifier_datatype = 'N' then
                  BEGIN
                     l_qual_attr_value_from_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value);
                     l_qual_attr_value_to_number := qp_number.canonical_to_number(l_qp_qualifiers_rec.qualifier_attr_value_to);
                  EXCEPTION
                     WHEN VALUE_ERROR THEN
                        NULL;
                     WHEN OTHERS THEN
                        NULL;
                  END;
                  END IF;

                  --Insert into qp_qualifiers
                  INSERT INTO QP_ARCH_QUALIFIERS
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
                   OTHERS_GROUP_CNT,
                   segment_id,
                   ARCH_PURG_REQUEST_ID
                  )
                  VALUES
                  (
                   l_qp_qualifiers_rec.qualifier_id,
                   l_qp_qualifiers_rec.creation_date,
                   l_qp_qualifiers_rec.created_by,
                   l_qp_qualifiers_rec.last_update_date,
                   l_qp_qualifiers_rec.last_updated_by,
                   l_qp_qualifiers_rec.last_update_login,
                   l_qp_qualifiers_rec.program_application_id,
                   l_qp_qualifiers_rec.program_id,
                   l_qp_qualifiers_rec.program_update_date,
                   l_qp_qualifiers_rec.request_id,
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
                   l_qp_qualifiers_rec.active_flag,
                   l_qp_qualifiers_rec.list_type_code,
                   l_qual_attr_value_from_number,
                   l_qual_attr_value_to_number,
                   l_qp_qualifiers_rec.search_ind,
                   l_qp_qualifiers_rec.distinct_row_count,
                   l_qp_qualifiers_rec.qualifier_group_cnt,
                   l_qp_qualifiers_rec.header_quals_exist_flag,
                   l_qp_qualifiers_rec.others_group_cnt,
                   l_qp_qualifiers_rec.segment_id,
                   l_conc_request_id
                  );

                  g_count_qualifier := g_count_qualifier + sql%rowcount;

                  DELETE FROM qp_qualifiers
                  WHERE qualifier_id = l_qp_qualifiers_rec.qualifier_id
                  and list_header_id = l_qp_qualifiers_rec.list_header_id
                  and list_line_id   = l_qp_qualifiers_rec.list_line_id;
               END LOOP;

            END IF;
          END IF; -- List type code end

          /* Archive List lines pricing attributes */
          FOR l_qp_pricing_attributes_rec IN qp_pricing_attributes_cur (l_qp_list_lines_rec.list_line_id) LOOP
             IF l_qp_pricing_attributes_rec.pricing_attribute_datatype = 'N' then
             BEGIN
	        l_pric_attr_value_from_number := qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_from);
	        l_pric_attr_value_to_number := qp_number.canonical_to_number(l_qp_pricing_attributes_rec.pricing_attr_value_to);
             EXCEPTION
	        WHEN VALUE_ERROR THEN
	           NULL;
	        WHEN OTHERS THEN
	           NULL;
             END;
             END IF;

             -- Insert into QP_ARCH_PRICING_ATTRIBUTES
	     INSERT INTO QP_ARCH_PRICING_ATTRIBUTES
             (
	      pricing_attribute_id,
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
 	      pricing_attr_value_to_number,
              DISTINCT_ROW_COUNT,
              SEARCH_IND,
              PATTERN_VALUE_FROM_POSITIVE,
              PATTERN_VALUE_TO_POSITIVE,
              PATTERN_VALUE_FROM_NEGATIVE,
              PATTERN_VALUE_TO_NEGATIVE,
              PRODUCT_SEGMENT_ID,
              PRICING_SEGMENT_ID,
              ARCH_PURG_REQUEST_ID
            )
            VALUES
            (
              l_qp_pricing_attributes_rec.pricing_attribute_id,
  	      l_qp_pricing_attributes_rec.creation_date,
 	      l_qp_pricing_attributes_rec.created_by,
	      l_qp_pricing_attributes_rec.last_update_date,
	      l_qp_pricing_attributes_rec.last_updated_by,
 	      l_qp_pricing_attributes_rec.last_update_login,
 	      l_qp_pricing_attributes_rec.program_application_id,
 	      l_qp_pricing_attributes_rec.program_id,
 	      l_qp_pricing_attributes_rec.program_update_date,
 	      l_qp_pricing_attributes_rec.request_id,
 	      l_qp_list_lines_rec.list_line_id,
	      p_entity,
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
	      l_pric_attr_value_to_number,
              l_qp_pricing_attributes_rec.DISTINCT_ROW_COUNT,
              l_qp_pricing_attributes_rec.SEARCH_IND,
              l_qp_pricing_attributes_rec.PATTERN_VALUE_FROM_POSITIVE,
              l_qp_pricing_attributes_rec.PATTERN_VALUE_TO_POSITIVE,
              l_qp_pricing_attributes_rec.PATTERN_VALUE_FROM_NEGATIVE,
              l_qp_pricing_attributes_rec.PATTERN_VALUE_TO_NEGATIVE,
              l_qp_pricing_attributes_rec.PRODUCT_SEGMENT_ID,
              l_qp_pricing_attributes_rec.PRICING_SEGMENT_ID,
              l_conc_request_id
	     );

             g_count_pricing_att := g_count_pricing_att + sql%rowcount;

             DELETE FROM qp_pricing_attributes
             WHERE pricing_attribute_id = l_qp_pricing_attributes_rec.pricing_attribute_id
             AND list_line_id = l_qp_list_lines_rec.list_line_id and list_header_id = p_entity;

          END LOOP; /* Cursor qp_pricing_attributes_cur LOOP */

       END IF; --Insert flag
   ELSE --Limit exists
      fnd_file.put_line(FND_FILE.LOG,'Limit exists for this line and it cannot be archived : '||l_qp_list_lines_rec.list_line_id);
      l_err_count := l_err_count+1;
   END IF;
END LOOP; /* Cursor qp_list_lines_cv LOOP */

CLOSE qp_list_lines_cv;

/* Archive the qp_rltd_modifiers for the Price Break Parent list_lines chosen
   above which are stored in the mapping table */

IF l_mapping_tbl.COUNT > 0 THEN
   FOR l_count IN 1..l_mapping_tbl.COUNT
   LOOP
      IF l_mapping_tbl(l_count).list_line_type_code = 'PBH' OR
         l_mapping_tbl(l_count).list_line_type_code = 'OID' OR
         l_mapping_tbl(l_count).list_line_type_code = 'PRG' THEN

         FOR l_qp_rltd_modifiers_rec IN qp_rltd_modifiers_cur(l_mapping_tbl(l_count).list_line_id)
         LOOP
            INSERT INTO QP_ARCH_RLTD_MODIFIERS
            (
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
             rltd_modifier_id,
             rltd_modifier_grp_no,
             from_rltd_modifier_id,
             to_rltd_modifier_id,
             rltd_modifier_grp_type,
             ARCH_PURG_REQUEST_ID
            )
            VALUES
            (
             l_qp_rltd_modifiers_rec.creation_date,
	     l_qp_rltd_modifiers_rec.created_by,
	     l_qp_rltd_modifiers_rec.last_update_date,
	     l_qp_rltd_modifiers_rec.last_updated_by,
	     l_qp_rltd_modifiers_rec.last_update_login,
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
	     l_qp_rltd_modifiers_rec.rltd_modifier_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_no,
	     l_qp_rltd_modifiers_rec.from_rltd_modifier_id,
	     l_qp_rltd_modifiers_rec.to_rltd_modifier_id,
             l_qp_rltd_modifiers_rec.rltd_modifier_grp_type,
             l_conc_request_id
	    );
            g_count_rldt:=g_count_rldt+sql%rowcount;

            DELETE_CHILD(l_qp_rltd_modifiers_rec.to_rltd_modifier_id,l_conc_request_id);

            DELETE FROM QP_RLTD_MODIFIERS
            WHERE rltd_modifier_id = l_qp_rltd_modifiers_rec.rltd_modifier_id;
         END LOOP; -- Loop through rltd modifiers records
      END IF; --For lines that are Parent Price Break lines
   END LOOP; --Loop through l_mapping_tbl
END IF; --If l_mapping_tbl has any records

/* Insert the count of records inserted into QP_ARCH_LIST_LINES,QP_ARCH_PRICING_ATTRIBUTES,QP_ARCH_QUALIFIERS,QP_ARCH_RLTD_MODIFIERS
   into QP_ARCH_ROW_COUNTS
*/
insert into QP_ARCH_ROW_COUNTS (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_LIST_LINES',g_count_list_line);
insert into QP_ARCH_ROW_COUNTS (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_PRICING_ATTRIBUTES',g_count_pricing_att);
insert into QP_ARCH_ROW_COUNTS (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_QUALIFIERS',g_count_qualifier);
insert into QP_ARCH_ROW_COUNTS  (request_id,table_name,row_count) values (l_conc_request_id,'QP_ARCH_RLTD_MODIFIERS',g_count_rldt);

fnd_file.put_line(FND_FILE.LOG, 'Number of list header records inserted into QP_ARCH_LIST_HEADERS_B: '|| g_count_header_b);
fnd_file.put_line(FND_FILE.LOG, 'Number of list header translation records inserted into QP_ARCH_LIST_HEADERS_TL: '|| g_count_header_tl);
fnd_file.put_line(FND_FILE.LOG, 'Number of list header and line qualifiers inserted into QP_ARCH_QUALIFIERS: '|| g_count_qualifier);
fnd_file.put_line(FND_FILE.LOG, 'Number of list lines archived into QP_ARCH_LIST_LINES: '|| g_count_list_line);
fnd_file.put_line(FND_FILE.LOG, 'Number of list line pricing attributes archived into QP_ARCH_PRICING_ATTRIBUTES: '|| g_count_pricing_att);
fnd_file.put_line(FND_FILE.LOG, 'Number of related lines archived into QP_ARCH_RLTD_MODIFIERS: '|| g_count_rldt);

IF (g_count_list_line > 0) THEN   -- Invoke update_qualifiers only if number of list lines archived > 0.
   fnd_file.put_line(FND_FILE.LOG, 'Before calling QP_MAINTAIN_DENORMALIZED_DATA.UPDATE_QUALIFIERS.');
   /* This code will call the API to update the denormalized columns on QP_QUALIFIERS*/
   QP_MAINTAIN_DENORMALIZED_DATA.UPDATE_QUALIFIERS( ERR_BUFF => errbuf,
   			                            RETCODE => retcode,
			                            P_LIST_HEADER_ID => p_entity);
   fnd_file.put_line(FND_FILE.LOG, 'After calling QP_MAINTAIN_DENORMALIZED_DATA.UPDATE_QUALIFIERS. Return code: '|| retcode);

   IF retcode = 2 THEN
      fnd_file.put_line(FND_FILE.LOG,'Error in Update of denormalized columns in QP_Qualifiers');
   ELSE
      fnd_file.put_line(FND_FILE.LOG,'Update of denormalized columns in QP_Qualifiers completed successfully');
   END IF;
END IF;

COMMIT;

fnd_file.put_line(FND_FILE.LOG, 'Number of list lines errored out and not processed: '|| l_err_count);

IF l_err_count = 0 THEN
   fnd_file.put_line(FND_FILE.LOG,'Pricing entity archive completed successfully');

   errbuf := '';
   retcode := 0;

   --Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES
   INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,p_all_lines,p_product_context,
                   p_product_attribute,p_product_attr_value_from,p_product_attr_value_to,p_start_date_active,
                   p_end_date_active,p_creation_date,p_created_by,l_user_id,l_conc_request_id,'S');
ELSE
   fnd_file.put_line(FND_FILE.LOG,'Pricing entity archive completed successfully');
   fnd_file.put_line(FND_FILE.LOG,'A few lines matching the archive criteria were not archived');

   errbuf := 'Few lines matching the criteria were not Archived';
   retcode := 0;

   --Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES
   INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,p_all_lines,p_product_context,
                   p_product_attribute,p_product_attr_value_from,p_product_attr_value_to,p_start_date_active,
                   p_end_date_active,p_creation_date,p_created_by,l_user_id,l_conc_request_id,'S');
END IF; --l_err_count

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(FND_FILE.LOG,'Pricing entity archive completed with Warnings');
      fnd_file.put_line(FND_FILE.LOG,'No Data Found - 0 Records Archived');

      errbuf := 'No Data Found - 0 Records Archived';
      retcode := 1;

      --Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES
      INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,p_all_lines,p_product_context,
                      p_product_attribute,p_product_attr_value_from,p_product_attr_value_to,p_start_date_active,
                      p_end_date_active,p_creation_date,p_created_by,l_user_id,l_conc_request_id,'W');
   WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG,'Error in Pricing entity archive Routine ');
      fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));

      retcode := 2;

      --Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES
      INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,p_all_lines,p_product_context,
                      p_product_attribute,p_product_attr_value_from,p_product_attr_value_to,p_start_date_active,
                      p_end_date_active,p_creation_date,p_created_by,l_user_id,l_conc_request_id,'F');
END ARCHIVE_ENTITY;
END QP_ARCHIVE_ENTITY_PVT;

/
