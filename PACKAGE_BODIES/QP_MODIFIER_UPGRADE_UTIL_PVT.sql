--------------------------------------------------------
--  DDL for Package Body QP_MODIFIER_UPGRADE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIER_UPGRADE_UTIL_PVT" AS
/* $Header: QPXVUTLB.pls 120.2 2006/03/21 11:16:40 rnayani noship $ */

  PROCEDURE  Create_List_Header(
				 p_creation_date 		DATE,
				 p_created_by    		NUMBER,
				 p_last_update_date     	DATE,
				 p_last_updated_by      	NUMBER,
				 p_last_update_login 	NUMBER,
				 p_list_type_code  		VARCHAR2,
				 p_start_date_effective 	DATE,
				 p_end_date_effective   	DATE,
				 p_automatic_flag       	VARCHAR2,
				 p_discount_lines_flag	VARCHAR2,
				 p_currency_code        	VARCHAR2,
				 p_name                 	VARCHAR2,
				 p_description          	VARCHAR2,
				 p_version_no            NUMBER,
				 p_ask_for_flag          VARCHAR2,
				 p_source_system_code    VARCHAR2,
				 p_active_flag           VARCHAR2,
				 p_gsa_indicator		VARCHAR2,
				 p_context               VARCHAR2,
				 p_attribute1			VARCHAR2,
				 p_attribute2			VARCHAR2,
				 p_attribute3			VARCHAR2,
				 p_attribute4			VARCHAR2,
				 p_attribute5			VARCHAR2,
				 p_attribute6			VARCHAR2,
				 p_attribute7			VARCHAR2,
				 p_attribute8			VARCHAR2,
				 p_attribute9			VARCHAR2,
				 p_attribute10			VARCHAR2,
				 p_attribute11			VARCHAR2,
				 p_attribute12			VARCHAR2,
				 p_attribute13			VARCHAR2,
				 p_attribute14			VARCHAR2,
				 p_attribute15			VARCHAR2,
				 p_new_flag			BOOLEAN,
				 p_seq_num			NUMBER,
				 p_id1				VARCHAR2,
				 p_type				VARCHAR2,
				 x_list_header_id OUT NOCOPY /* file.sql.39 change */    NUMBER)  IS

    err_num         NUMBER;
    err_msg         VARCHAR2(2000);
    v_seq_num	    NUMBER;
    v_name          VARCHAR2(240);

  CURSOR get_duplicate_name_cur IS
  SELECT distinct name
  FROM   qp_list_headers_tl
  WHERE  name = p_name;

  BEGIN

	 IF (p_new_flag = TRUE) THEN
		SELECT SO_PRICE_LISTS_S.nextval
		INTO v_seq_num
		FROM DUAL;
		v_seq_num := v_seq_num + 5000;
	 ELSE
		v_seq_num := p_seq_num + 1;
	 END IF;

      INSERT INTO QP_LIST_HEADERS_B (
      LIST_HEADER_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN, LIST_TYPE_CODE, START_DATE_ACTIVE, END_DATE_ACTIVE,
      AUTOMATIC_FLAG,DISCOUNT_LINES_FLAG, CURRENCY_CODE,ASK_FOR_FLAG,
	 SOURCE_SYSTEM_CODE, ACTIVE_FLAG,GSA_INDICATOR,CONTEXT,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
	 ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
	 ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15)

	 VALUES(
	 QP_LIST_HEADERS_B_S.nextval,p_creation_date, p_created_by,p_last_update_date,p_last_updated_by,
	 p_last_update_login,p_list_type_code,p_start_date_effective,p_end_date_effective,
	 p_automatic_flag,p_discount_lines_flag,p_currency_code,p_ask_for_flag,
	 p_source_system_code,p_active_flag,p_gsa_indicator,p_context,p_attribute1,p_attribute2,p_attribute3,p_attribute4,
	 p_attribute5,p_attribute6,p_attribute7,p_attribute8,p_attribute9,p_attribute10,
	 p_attribute11,p_attribute12,p_attribute13,p_attribute14,p_attribute15);

--   Store the current list header id
	SELECT QP_LIST_HEADERS_B_S.currval
	INTO   x_list_header_id
	FROM   DUAL;

	--x_list_header_id := v_seq_num;

	v_name := p_name;

     OPEN   get_duplicate_name_cur;
     FETCH  get_duplicate_name_cur INTO v_name;
     CLOSE  get_duplicate_name_cur;

     IF (v_name IS NOT NULL) THEN
      v_name := v_name || ' ' || p_id1;
	ELSE
	 v_name := p_name;
     END IF;

     INSERT INTO QP_LIST_HEADERS_TL (
 	LIST_HEADER_ID, LANGUAGE, SOURCE_LANG, NAME, DESCRIPTION,
 	CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	VERSION_NO)

	SELECT
		x_list_header_id, l.LANGUAGE_CODE, userenv('LANG'), v_name, p_description,
		  p_creation_date, p_created_by, p_last_update_date, p_last_updated_by, p_last_update_login,
		  p_version_no
     FROM FND_LANGUAGES l
	WHERE l.INSTALLED_FLAG in ('I', 'B')
	AND NOT EXISTS
		(SELECT NULL
		FROM QP_LIST_HEADERS_TL t
		WHERE t.LIST_HEADER_ID = x_list_header_id
		AND t.LANGUAGE = l.LANGUAGE_CODE);

  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							p_error_type =>p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_List_Header');
	raise;

  END Create_List_Header;

  PROCEDURE  Create_List_Line(
  			   p_creation_date			DATE,
   			   p_created_by			NUMBER,
    			   p_last_update_date		DATE,
			   p_last_updated_by		NUMBER,
	 		   p_last_update_login		NUMBER,
	  		   p_program_application_id	NUMBER,
	   		   p_program_id			NUMBER,
	    		   p_program_update_date		DATE,
			   p_request_id			NUMBER,
		 	   p_list_header_id			NUMBER,
		  	   p_list_line_type_code		VARCHAR2,
		  	   p_start_date_effective	DATE,
		    	   p_end_date_effective		DATE,
			   p_automatic_flag			VARCHAR2,
			   p_modifier_level_code		VARCHAR2,
			   p_arithmetic_operator		VARCHAR2,
			   p_operand				NUMBER,
			   p_pricing_phase_id         NUMBER,
			   p_incomp_grp_code          VARCHAR2,
			   p_pricing_grp_seq          NUMBER,
			   p_accrual_flag             VARCHAR2,
			   p_product_precedence       NUMBER,
			   p_proration_type_code      VARCHAR2,
			   p_print_on_invoice_flag    VARCHAR2,
			   p_override_flag			VARCHAR2,
			   p_price_break_type_code	VARCHAR2,
		    	   p_context                  VARCHAR2,
			   p_attribute1			VARCHAR2,
			   p_attribute2			VARCHAR2,
			   p_attribute3			VARCHAR2,
			   p_attribute4			VARCHAR2,
			   p_attribute5			VARCHAR2,
			   p_attribute6			VARCHAR2,
			   p_attribute7			VARCHAR2,
			   p_attribute8			VARCHAR2,
			   p_attribute9			VARCHAR2,
			   p_attribute10			VARCHAR2,
			   p_attribute11			VARCHAR2,
			   p_attribute12			VARCHAR2,
			   p_attribute13			VARCHAR2,
			   p_attribute14			VARCHAR2,
			   p_attribute15			VARCHAR2,
                           p_qualification_ind          NUMBER,  		--2422176
			   --p_qualification_ind        NUMBER := null,
			   p_new_flag				BOOLEAN,
			   p_seq_num				NUMBER,
			   p_id1					VARCHAR2,
			   p_id2					VARCHAR2 := null,
			   p_type					VARCHAR2,
			   x_list_line_id OUT NOCOPY /* file.sql.39 change */         NUMBER) IS

	err_num 		NUMBER;
	err_msg 		VARCHAR(100);
	v_seq_num 	NUMBER;
	v_list_line_seq NUMBER;

   BEGIN
		IF (p_new_flag = TRUE) THEN
			SELECT SO_PRICE_LIST_LINES_S.nextval
			INTO v_seq_num
			FROM DUAL;
			v_seq_num := v_seq_num + 5000;
		ELSE
			v_seq_num := p_seq_num + 1;
		END IF;

			SELECT QP_LIST_LINES_S.nextval
			INTO v_list_line_seq
			FROM DUAL;

     INSERT INTO QP_LIST_LINES (
	 LIST_LINE_ID,LIST_LINE_NO, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID,
	 LIST_HEADER_ID, LIST_LINE_TYPE_CODE, START_DATE_ACTIVE, END_DATE_ACTIVE,
	 AUTOMATIC_FLAG, MODIFIER_LEVEL_CODE, ARITHMETIC_OPERATOR, OPERAND,PRICING_PHASE_ID,
	 INCOMPATIBILITY_GRP_CODE,PRICING_GROUP_SEQUENCE,ACCRUAL_FLAG,PRODUCT_PRECEDENCE,QUALIFICATION_IND,
	 PRORATION_TYPE_CODE,PRINT_ON_INVOICE_FLAG,OVERRIDE_FLAG , PRICE_BREAK_TYPE_CODE ,
	 CONTEXT,ATTRIBUTE1,ATTRIBUTE2, ATTRIBUTE3,ATTRIBUTE4, ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,
	 ATTRIBUTE9,ATTRIBUTE10, ATTRIBUTE11,ATTRIBUTE12, ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,ORIG_SYS_LINE_REF
         ,ORIG_SYS_HEADER_REF
     )

	 VALUES (
	 v_list_line_seq, v_list_line_seq, p_creation_date,p_created_by,p_last_update_date,p_last_updated_by,
	 p_last_update_login, p_program_application_id,p_program_id,p_program_update_date,p_request_id,
	 p_list_header_id,p_list_line_type_code,p_start_date_effective,p_end_date_effective,
	 p_automatic_flag,p_modifier_level_code,p_arithmetic_operator,p_operand,p_pricing_phase_id,
	 p_incomp_grp_code,p_pricing_grp_seq,p_accrual_flag,p_product_precedence, p_qualification_ind,
	 p_proration_type_code, p_print_on_invoice_flag,p_override_flag , p_price_break_type_code ,
	 p_context, p_attribute1,p_attribute2, p_attribute3,p_attribute4, p_attribute5, p_attribute6,
	 p_attribute7, p_attribute8,p_attribute9,p_attribute10, p_attribute11,p_attribute12, p_attribute13,
	 p_attribute14, p_attribute15
         --ENH Upgrade BOAPI for orig_sys...ref RAVI
         ,to_char(v_list_line_seq)
         ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_list_header_id)
         );

	 -- Store the new list line id

	 SELECT QP_LIST_LINES_S.currval
	 INTO   x_list_line_id
	 FROM   DUAL;

	 --x_list_line_id := v_seq_num;


  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							 p_id2 => p_id2,
							p_error_type => p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_List_Line');
	raise;

   END Create_List_Line;

   PROCEDURE Create_Qualifier (
				p_creation_date               DATE,
				p_created_by                  NUMBER,
				p_last_update_date            DATE,
				p_last_updated_by             NUMBER,
				p_last_update_login           NUMBER,
				p_program_application_id      NUMBER,
				p_program_id                  NUMBER,
				p_program_update_date         DATE,
				p_request_id                  NUMBER,
				p_excluder_flag		      VARCHAR2,
				p_comparision_operator_code   VARCHAR2,
				p_qualifier_context           VARCHAR2,
				p_qualifier_attribute         VARCHAR2,
				p_qualifier_attr_value        VARCHAR2,
				p_qualifier_grouping_no       NUMBER,
				p_list_header_id			NUMBER,
				p_list_line_id				NUMBER,
				p_qualifier_precedence        NUMBER,
				p_qualifier_datatype          VARCHAR2,
				p_start_date_active			DATE,
				p_end_date_active			DATE,
		    	     p_context                  	VARCHAR2,
			     p_attribute1				VARCHAR2,
			     p_attribute2				VARCHAR2,
			     p_attribute3				VARCHAR2,
			     p_attribute4				VARCHAR2,
			     p_attribute5				VARCHAR2,
			     p_attribute6				VARCHAR2,
			     p_attribute7				VARCHAR2,
			     p_attribute8				VARCHAR2,
			     p_attribute9				VARCHAR2,
			     p_attribute10				VARCHAR2,
			     p_attribute11				VARCHAR2,
			     p_attribute12				VARCHAR2,
			     p_attribute13				VARCHAR2,
			     p_attribute14				VARCHAR2,
			     p_attribute15				VARCHAR2,
			     p_id1					VARCHAR2,
			     p_type					VARCHAR2,
				x_qualifier_grouping_no OUT NOCOPY /* file.sql.39 change */   NUMBER)  AS
   err_num NUMBER;
   err_msg VARCHAR2(100);

   BEGIN


	--   Create new grouping no
	IF (p_qualifier_grouping_no = 0) THEN
		SELECT QP.QP_QUALIFIER_GROUP_NO_S.nextval
		INTO   x_qualifier_grouping_no
		FROM   DUAL;
	ELSE
		x_qualifier_grouping_no := p_qualifier_grouping_no;
	END IF;

 -- mkarya for bug 1955867, the order of p_context, p_start_date_active,p_end_date_active in the VALUES
 -- clause have been arranged to populate these columns properly
	-- Create a record in  qp_qualifiers
	INSERT INTO QP_QUALIFIERS (
		QUALIFIER_ID,CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN, LIST_HEADER_ID, LIST_LINE_ID,COMPARISON_OPERATOR_CODE, QUALIFIER_CONTEXT,
		QUALIFIER_ATTRIBUTE, QUALIFIER_ATTR_VALUE, QUALIFIER_GROUPING_NO,EXCLUDER_FLAG,
		QUALIFIER_PRECEDENCE,QUALIFIER_DATATYPE,START_DATE_ACTIVE,END_DATE_ACTIVE,CONTEXT,ATTRIBUTE1,ATTRIBUTE2,
		ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,
		ATTRIBUTE11,ATTRIBUTE12, ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF)
     VALUES (
		QP_QUALIFIERS_S.nextval,p_creation_date,p_created_by,p_last_update_date,p_last_updated_by,
		p_last_update_login,p_list_header_id,p_list_line_id,p_comparision_operator_code,
		p_qualifier_context, p_qualifier_attribute,p_qualifier_attr_value,x_qualifier_grouping_no,
		p_excluder_flag,p_qualifier_precedence,p_qualifier_datatype, p_start_date_active,p_end_date_active, p_context,
	     p_attribute1,p_attribute2,p_attribute3,p_attribute4, p_attribute5,p_attribute6,p_attribute7,
		p_attribute8,p_attribute9,p_attribute10, p_attribute11,p_attribute12,p_attribute13,
		p_attribute14,p_attribute15
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_QUALIFIERS_S.currval)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_list_header_id)
        );
  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							p_error_type => p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_Qualifier');
	raise;

   END Create_Qualifier;

   PROCEDURE  Create_Pricing_Attribute(

				 	p_creation_date               DATE,
					p_created_by                  NUMBER,
					p_last_update_date            DATE,
					p_last_updated_by             NUMBER,
					p_last_update_login           NUMBER,
					p_program_application_id      NUMBER,
					p_program_id                  NUMBER,
					p_program_update_date         DATE,
					p_request_id                  NUMBER,
					p_list_line_id                NUMBER,
					p_excluder_flag               VARCHAR2,
					p_accumulate_flag             VARCHAR2,
					p_product_attribute_context   VARCHAR2,
					p_product_attribute           VARCHAR2,
					p_product_attr_value          VARCHAR2,
					p_product_uom_code            VARCHAR2,
					p_pricing_attribute_context   VARCHAR2,
					p_pricing_attribute           VARCHAR2,
					p_pricing_attr_value_from     VARCHAR2,
					p_pricing_attr_value_to       VARCHAR2,
					p_comparision_operator_code   VARCHAR2,
					p_pricing_attr_datatype       VARCHAR2,
					p_product_attr_datatype       VARCHAR2,
			   		p_id1					VARCHAR2,
					p_id2					VARCHAR2 := null,
			   		p_type					VARCHAR2,
				     x_pricing_attribute_id   OUT NOCOPY /* file.sql.39 change */  NUMBER) AS
     err_num NUMBER;
   	err_msg VARCHAR2(100);

    BEGIN

			INSERT INTO QP_PRICING_ATTRIBUTES
				(PRICING_ATTRIBUTE_ID, CREATION_DATE, CREATED_BY,
				LAST_UPDATE_DATE, LAST_UPDATED_BY,LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
				PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID, LIST_LINE_ID, EXCLUDER_FLAG,
				ACCUMULATE_FLAG, PRODUCT_ATTRIBUTE_CONTEXT,PRODUCT_ATTRIBUTE,
				PRODUCT_ATTR_VALUE, PRODUCT_UOM_CODE, PRICING_ATTRIBUTE_CONTEXT,
				PRICING_ATTRIBUTE, PRICING_ATTR_VALUE_FROM, PRICING_ATTR_VALUE_TO,
				ATTRIBUTE_GROUPING_NO,COMPARISON_OPERATOR_CODE,PRICING_ATTRIBUTE_DATATYPE,
				PRODUCT_ATTRIBUTE_DATATYPE
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF)
			VALUES (
				QP_PRICING_ATTRIBUTES_S.nextval,p_creation_date, p_created_by,
				p_last_update_date, p_last_updated_by, p_last_update_login, p_program_application_id,
				p_program_id, p_program_update_date, p_request_id, p_list_line_id, p_excluder_flag,
				p_accumulate_flag, p_product_attribute_context, p_product_attribute,
				p_product_attr_value, p_product_uom_code, p_pricing_attribute_context,
				p_pricing_attribute, p_pricing_attr_value_from, p_pricing_attr_value_to,
				1 , p_comparision_operator_code,
				p_pricing_attr_datatype, p_product_attr_datatype
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_PRICING_ATTRIBUTES_S.currval)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     ,(select l.ORIG_SYS_HEADER_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     );


			/* SELECT QP_PRICING_ATTRIBUTES_S.currval
			INTO   x_pricing_attribute_id
			FROM   DUAL; */
			 x_pricing_attribute_id :=1;


  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							 p_id2 => p_id2,
							p_error_type => p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_Pricing_Attribute');
	raise;

    END Create_Pricing_Attribute;

   PROCEDURE  Create_Pricing_Attribute_Break(

				 	p_creation_date               DATE,
					p_created_by                  NUMBER,
					p_last_update_date            DATE,
					p_last_updated_by             NUMBER,
					p_last_update_login           NUMBER,
					p_program_application_id      NUMBER,
					p_program_id                  NUMBER,
					p_program_update_date         DATE,
					p_request_id                  NUMBER,
					p_list_line_id                NUMBER,
					p_excluder_flag               VARCHAR2,
					p_accumulate_flag             VARCHAR2,
					p_product_attribute_context   VARCHAR2,
					p_product_attribute           VARCHAR2,
					p_product_attr_value          VARCHAR2,
					p_product_uom_code            VARCHAR2,
					p_pricing_attribute_context   VARCHAR2,
					p_pricing_attribute           VARCHAR2,
					p_pricing_attr_value_from     NUMBER,
					p_pricing_attr_value_to       NUMBER,
					p_comparision_operator_code   VARCHAR2,
					p_pricing_attr_datatype       VARCHAR2,
					p_product_attr_datatype       VARCHAR2,
			   		p_id1					VARCHAR2,
			   		p_id2					VARCHAR2 := null,
			   		p_type					VARCHAR2,
				     x_pricing_attribute_id   OUT NOCOPY /* file.sql.39 change */  NUMBER) AS
     err_num NUMBER;
   	err_msg VARCHAR2(100);

    BEGIN

			INSERT INTO QP_PRICING_ATTRIBUTES
				(PRICING_ATTRIBUTE_ID, CREATION_DATE, CREATED_BY,
				LAST_UPDATE_DATE, LAST_UPDATED_BY,LAST_UPDATE_LOGIN, PROGRAM_APPLICATION_ID,
				PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID, LIST_LINE_ID, EXCLUDER_FLAG,
				ACCUMULATE_FLAG, PRODUCT_ATTRIBUTE_CONTEXT,PRODUCT_ATTRIBUTE,
				PRODUCT_ATTR_VALUE, PRODUCT_UOM_CODE, PRICING_ATTRIBUTE_CONTEXT,
				PRICING_ATTRIBUTE, PRICING_ATTR_VALUE_FROM, PRICING_ATTR_VALUE_TO,
				ATTRIBUTE_GROUPING_NO,COMPARISON_OPERATOR_CODE,PRICING_ATTRIBUTE_DATATYPE,
				PRODUCT_ATTRIBUTE_DATATYPE
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF)
			VALUES (
				QP_PRICING_ATTRIBUTES_S.nextval,p_creation_date, p_created_by,
				p_last_update_date, p_last_updated_by, p_last_update_login, p_program_application_id,
				p_program_id, p_program_update_date, p_request_id, p_list_line_id, p_excluder_flag,
				p_accumulate_flag, p_product_attribute_context, p_product_attribute,
				p_product_attr_value, p_product_uom_code, p_pricing_attribute_context,
				p_pricing_attribute, qp_number.number_to_canonical(p_pricing_attr_value_from),
				qp_number.number_to_canonical(p_pricing_attr_value_to), 1 ,
				p_comparision_operator_code,p_pricing_attr_datatype, p_product_attr_datatype
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_PRICING_ATTRIBUTES_S.currval)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     ,(select l.ORIG_SYS_HEADER_REF from qp_list_lines l where l.list_line_id=p_list_line_id)
     );

			SELECT QP_PRICING_ATTRIBUTES_S.currval
			INTO   x_pricing_attribute_id
			FROM   DUAL;


  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							 p_id2 => p_id2,
							p_error_type => p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_Pricing_Attribute_Break');
	raise;

    END Create_Pricing_Attribute_Break;

    PROCEDURE Create_Related_Modifier (

				p_creation_date			DATE,
				p_created_by				NUMBER,
				p_last_update_date			DATE,
				p_last_updated_by			NUMBER,
				p_last_update_login			NUMBER,
				p_from_rltd_modifier_id		NUMBER,
				p_to_rltd_modifier_id		NUMBER,
				p_rltd_modifier_grp_type      VARCHAR2,
			   	p_id1					VARCHAR2,
			   	p_id2					VARCHAR2 := null,
			   	p_type					VARCHAR2,
				x_rltd_modifier_id	  OUT NOCOPY /* file.sql.39 change */	NUMBER)  AS

	 err_num 	NUMBER;
	 err_msg  VARCHAR2(100);

    BEGIN

		INSERT INTO QP_RLTD_MODIFIERS
		(    RLTD_MODIFIER_ID,CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
			LAST_UPDATED_BY, LAST_UPDATE_LOGIN,RLTD_MODIFIER_GRP_NO,
			FROM_RLTD_MODIFIER_ID, TO_RLTD_MODIFIER_ID,RLTD_MODIFIER_GRP_TYPE)
		VALUES(
			QP_RLTD_MODIFIERS_S.nextval,p_creation_date,p_created_by,p_last_update_date,
			p_last_updated_by, p_last_update_login,QP_RLTD_MODIFIER_GRP_NO_S.nextval,
			p_from_rltd_modifier_id,p_to_rltd_modifier_id,p_rltd_modifier_grp_type);

		SELECT QP_RLTD_MODIFIERS_S.currval
		INTO	  x_rltd_modifier_id
		FROM   DUAL;


    EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
	rollback;
    	QP_Util.Log_Error(p_id1 => p_id1,
							 p_id2 => p_id2,
							p_error_type => p_type,
							p_error_desc => err_msg,
							p_error_module => 'Create_Related_Modifier');
	raise;

    END Create_Related_Modifier;

procedure insert_line_distribution
(
l_worker in number,
l_start_line  IN  Number,
l_end_line    IN  Number,
l_type_var    IN  Varchar2
)
is
Begin

       insert into qp_upg_lines_distribution
       (
           worker,
           start_line_id,
           end_line_id,
           alloted_flag,
           line_type,
           creation_date
       )
       values
       (
           l_worker,
           l_start_line,
           l_end_line,
           'N',
           l_type_var,
           sysdate
       );

end insert_line_distribution;

END QP_Modifier_Upgrade_Util_PVT;

/
