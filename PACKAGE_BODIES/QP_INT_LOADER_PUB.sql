--------------------------------------------------------
--  DDL for Package Body QP_INT_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_INT_LOADER_PUB" AS
/* $Header: QPXILDRB.pls 120.1 2005/06/14 05:36:31 appldev  $ */

-- When List_Type_Code is 'PRL' Process_Price_List is invoked
-- When List_Type Code is 'PLL' Process_Mofidiers is invoked

PROCEDURE Load_Int_List
(	p_process_id		IN	NUMBER,
	x_status		OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	x_errors		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS

 l_request_type_code varchar2(3):= NULL;
 gpr_return_status varchar2(30) := NULL;
 gpr_msg_count number := 0;
 gpr_msg_data varchar2(2000);
 l_operation VARCHAR2(30);
 l_process_type VARCHAR2(30);
 i number := 1;
 length number := 0;

 l_interface_action_code VARCHAR2(30);
 l_list_type_code VARCHAR2(30);
 l_name VARCHAR2(30);
 l_err_buffer VARCHAR2(240) :=NULL;
 l_list_header_id NUMBER := 0;
 l_list_line_id NUMBER := 0;
 l_count NUMBER :=0;

-- for fte_batch_jobs and fte_job_errors tables
 l_party_id NUMBER:=-1;
 l_party_name VARCHAR2(30);
 l_job_start_date DATE := SYSDATE;
 l_job_completion_date DATE := NULL;
 -- job status 0 = completed with success, 1 = completed with error, 2 = in process
 l_job_status VARCHAR2(30) := 2;

 l_region_id NUMBER :=NULL;
 l_is_prclst_exists BOOLEAN := NULL;

 null_interface_action_code EXCEPTION;
 invalid_interface_action_code EXCEPTION;
 null_list_type_code EXCEPTION;
 invalid_list_type_code EXCEPTION;
 boi_failed_exception EXCEPTION;
 origin_rid_failed EXCEPTION;
 destination_rid_failed EXCEPTION;
 prclst_not_exist EXCEPTION;
 party_id_failed EXCEPTION;
 qualifier_prclst_not_exist EXCEPTION;


 -- PRL, for Process_Price_List
 gpr_price_list_rec 		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 gpr_price_list_val_rec 	QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 gpr_price_list_line_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 gpr_price_list_line_val_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;

 gpr_qualifiers_tbl 		QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 gpr_qualifiers_val_tbl 	QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 gpr_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl 	QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

 ppr_price_list_rec 		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 ppr_price_list_val_rec 	QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
 ppr_price_list_line_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 ppr_price_list_line_val_tbl 	QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;

 ppr_qualifiers_tbl 		QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl 	QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl 	QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

-- SLT, for Process_Modifiers

 gpr_modifier_list_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
 gpr_modifier_list_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 gpr_modifiers_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
 gpr_modifiers_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;

 --gpr_qualifiers_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
 --gpr_qualifiers_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 gpr_pricing_mod_attr_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_mod_attr_val_tbl      QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

 ppr_modifier_list_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
 ppr_modifier_list_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 ppr_modifiers_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
 ppr_modifiers_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;

--ppr_qualifiers_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
--ppr_qualifiers_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 ppr_pricing_mod_attr_tbl           QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_mod_attr_val_tbl       QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;


-- Getting the data from the interface tables

 CURSOR l_qualifiers IS
 SELECT
    qual.interface_action_code,
    qual.excluder_flag,
    qual.comparison_operator_code,
    qual.qualifier_context,
    qual.qualifier_attribute,
    qual.qualifier_attr_value,
    qual.qualifier_grouping_no
 FROM
    qp_interface_qualifiers qual
 WHERE
    qual.process_id = p_process_id;

 CURSOR l_lines IS
 SELECT
    line.interface_action_code,
    line.list_header_id,
    line.list_line_id,
    line.list_line_type_code,
    line.automatic_flag,
    line.override_flag,
    line.modifier_level_code,
    line.operand,
    line.arithmetic_operator,
    line.product_precedence,
    line.comments,
    line.price_break_type_code,
    line.list_line_no,
    line.price_break_header_index
 FROM
    qp_interface_list_lines line
 WHERE
    line.process_id = p_process_id
 ORDER BY
    line.list_line_no;

-- SLT
 CURSOR l_mod_lines IS
 SELECT
    line.interface_action_code,
    line.list_header_id,
    line.list_line_id,
    line.list_line_type_code,
    line.automatic_flag,
    line.override_flag,
    line.modifier_level_code,
    line.operand,
    line.arithmetic_operator,
    line.product_precedence,
    line.pricing_group_sequence,
    line.pricing_phase_id,
    line.comments,
    line.price_break_type_code,
    line.list_line_no,
    line.charge_type_code,
    line.charge_subtype_code,
    line.price_break_header_index
 FROM
    qp_interface_list_lines line
 WHERE
    line.process_id = p_process_id
 ORDER BY
    line.list_line_no;

 -- PRL
 CURSOR l_pricing_attribs IS
 SELECT
    pa.interface_action_code,
    pa.list_line_id,
    pa.excluder_flag,
    pa.product_attribute_context,
    pa.product_attribute,
    pa.product_attr_value,
    pa.product_uom_code,
    pa.product_attribute_datatype,
    pa.pricing_attribute_datatype,
    pa.pricing_attribute_context,
    pa.pricing_attribute,
    pa.pricing_attr_value_from,
    pa.pricing_attr_value_to,
    pa.attribute_grouping_no,
    pa.comparison_operator_code,
--    pa.price_list_line_index,
    pa.list_line_no
 FROM
    qp_interface_pricing_attribs pa
 WHERE
    pa.process_id = p_process_id;

--SLT
 CURSOR l_pricing_mod_attribs IS
 SELECT
    pa.interface_action_code,
    pa.list_line_id,
    pa.excluder_flag,
    pa.product_attribute_context,
    pa.product_attribute,
    pa.product_attr_value,
    pa.product_uom_code,
    pa.product_attribute_datatype,
    pa.pricing_attribute_datatype,
    pa.pricing_attribute_context,
    pa.pricing_attribute,
    pa.pricing_attr_value_from,
    pa.pricing_attr_value_to,
    pa.attribute_grouping_no,
    pa.comparison_operator_code,
--    pa.price_list_line_index,
    pa.list_line_no
 FROM
    qp_interface_pricing_attribs pa
 WHERE
    pa.process_id = p_process_id;


BEGIN

--commit the interface table data
commit;

-- Transferring data into pl/sql tables used as input to the PriceList BOI
 x_status := 1;

 Get_Party_Id (p_process_id, l_party_id, l_err_buffer);
 	IF (l_party_id = -1) THEN
 		raise party_id_failed;
 	END IF;

 -- obtain values for validations
 SELECT process_type, list_type_code, interface_action_code, name, source_system_code
 INTO   l_process_type, l_list_type_code, l_interface_action_code, l_name, l_request_type_code
 FROM   qp_interface_list_headers
 WHERE  process_id = p_process_id;

 QP_INT_LOADER_PUB.G_PROCESS_LST_REQ_TYPE := nvl(l_request_type_code, 'FTE'); --shulin, used in BOI

 IF (l_interface_action_code IS NULL) THEN
	RAISE null_interface_action_code;

 ELSIF (l_interface_action_code <> 'C') AND (l_interface_action_code <> 'D') THEN
 	RAISE invalid_interface_action_code;

 ELSIF (l_list_type_code IS NULL) THEN
 	RAISE null_list_type_code;

 ELSIF (l_list_type_code <> 'PRL') AND (l_list_type_code <> 'SLT') THEN
 	RAISE invalid_list_type_code;

 END IF;

 IF (l_interface_action_code = 'D') THEN

 	-- see if data exists
 	SELECT count(1) INTO  l_count FROM qp_list_headers_tl qp_lhdr_tl where qp_lhdr_tl.name = l_name;
 	IF l_count > 0 THEN

 		-- obtain list_header_id
 		SELECT qp_lhdr_tl.list_header_id INTO l_list_header_id FROM qp_list_headers_tl qp_lhdr_tl WHERE qp_lhdr_tl.name = l_name AND qp_lhdr_tl.language='US' ;

 		delete from qp_pricing_attributes qp_prc_att where qp_prc_att.list_header_id  = l_list_header_id;
 		delete from qp_list_lines qp_ll where qp_ll.list_header_id  = l_list_header_id;
 		delete from qp_qualifiers qp_qual where qp_qual.list_header_id  = l_list_header_id;
 		delete from qp_list_headers_b qp_lhdr_b where qp_lhdr_b.list_header_id = l_list_header_id;
 		delete from qp_list_headers_tl qp_lhdr_tl where qp_lhdr_tl.list_header_id  = l_list_header_id;

 		/*
 		update fte_lanes set fte_lanes.pricelist_view_flag = NULL WHERE fte_lanes.pricelist_id = l_list_header_id;
 		update fte_lanes set fte_lanes.pricelist_name = NULL WHERE fte_lanes.pricelist_id = l_list_header_id;
 		update fte_lanes set fte_lanes.pricelist_id = NULL WHERE fte_lanes.pricelist_id = l_list_header_id;
 		*/
		commit;

		--extra for modifier
		IF (l_list_type_code = 'SLT') THEN
			select qp_ll.list_line_id INTO l_list_line_id from qp_list_lines qp_ll where qp_ll.list_header_id = l_list_header_id;
			delete from qp_rltd_modifiers where qp_rltd_modifiers.from_rltd_modifier_id = l_list_line_id;
			commit;
		END IF;

		/*
 		Insert_Job_Status  (p_process_id, -1, -1, -1, 1, -1, x_status, l_process_type, l_name, SYSDATE, SYSDATE);
 		*/
 	ELSE
 		raise prclst_not_exist;
 	END IF;
 END IF;

 IF (l_interface_action_code = 'C') THEN

 IF (l_process_type = 'XML') AND (l_list_type_code = 'PRL') THEN

  	SELECT
    		lhdr.list_header_id,
    		lhdr.name,
    		lhdr.description,
    		lhdr.interface_action_code,
    		lhdr.list_type_code,
    		lhdr.currency_code,
    		TO_DATE(lhdr.start_date_active,'YYYYMMDD HH24MISS'),
    		TO_DATE(lhdr.end_date_active,'YYYYMMDD HH24MISS'),
    		lhdr.automatic_flag
 	INTO
    		gpr_price_list_rec.list_header_id,
    		gpr_price_list_rec.name,
    		gpr_price_list_rec.description,
    		l_operation,
    		gpr_price_list_rec.list_type_code,
    		gpr_price_list_rec.currency_code,
    		gpr_price_list_rec.start_date_active,
    		gpr_price_list_rec.end_date_active,
    		gpr_price_list_rec.automatic_flag
 	FROM
    		qp_interface_list_headers lhdr
 	WHERE
    		lhdr.process_id = p_process_id
 	AND
    		rownum < 2;


 ELSIF (l_process_type = 'XML') AND (l_list_type_code = 'SLT') THEN

 	SELECT
    		lhdr.list_header_id,
    		lhdr.name,
    		lhdr.description,
    		lhdr.interface_action_code,
    		lhdr.list_type_code,
    		lhdr.currency_code,
    		TO_DATE(lhdr.start_date_active,'YYYYMMDD HH24MISS'),
    		TO_DATE(lhdr.end_date_active,'YYYYMMDD HH24MISS'),
    		lhdr.automatic_flag
 	INTO
    		gpr_modifier_list_rec.list_header_id,
    		gpr_modifier_list_rec.name,
    		gpr_modifier_list_rec.description,
    		l_operation,
    		gpr_modifier_list_rec.list_type_code,
    		gpr_modifier_list_rec.currency_code,
    		gpr_modifier_list_rec.start_date_active,
    		gpr_modifier_list_rec.end_date_active,
    		gpr_modifier_list_rec.automatic_flag
 	FROM
    		qp_interface_list_headers lhdr
 	WHERE
    		lhdr.process_id = p_process_id
 	AND
    		rownum < 2;

ELSIF (l_process_type = 'SSH') AND (l_list_type_code = 'PRL') THEN

 	SELECT
    		lhdr.list_header_id,
    		lhdr.name,
    		lhdr.description,
    		lhdr.interface_action_code,
    		lhdr.list_type_code,
    		lhdr.currency_code,
    		lhdr.start_date_active,
    		lhdr.end_date_active,
    		lhdr.automatic_flag
 	INTO
    		gpr_price_list_rec.list_header_id,
    		gpr_price_list_rec.name,
    		gpr_price_list_rec.description,
    		l_operation,
    		gpr_price_list_rec.list_type_code,
    		gpr_price_list_rec.currency_code,
    		gpr_price_list_rec.start_date_active,
    		gpr_price_list_rec.end_date_active,
    		gpr_price_list_rec.automatic_flag
 	FROM
    		qp_interface_list_headers lhdr
 	WHERE
    		lhdr.process_id = p_process_id
 	AND
    		rownum < 2;


 ELSIF (l_process_type = 'SSH') AND (l_list_type_code = 'SLT') THEN

	SELECT
    		lhdr.list_header_id,
    		lhdr.name,
    		lhdr.description,
    		lhdr.interface_action_code,
    		lhdr.list_type_code,
    		lhdr.currency_code,
    		lhdr.start_date_active,
    		lhdr.end_date_active,
   		lhdr.automatic_flag

 	INTO
    		gpr_modifier_list_rec.list_header_id,
    		gpr_modifier_list_rec.name,
    		gpr_modifier_list_rec.description,
    		l_operation,
    		gpr_modifier_list_rec.list_type_code,
    		gpr_modifier_list_rec.currency_code,
    		gpr_modifier_list_rec.start_date_active,
    		gpr_modifier_list_rec.end_date_active,
    		gpr_modifier_list_rec.automatic_flag
 	FROM
    		qp_interface_list_headers lhdr
 	WHERE
    		lhdr.process_id = p_process_id
 	AND
    		rownum < 2;

-- ELSE
-- 	dbms_output.put_line('Wrong process_type and list_type_code');

 END IF;

 IF (l_operation = 'C') AND (l_list_type_code = 'PRL') THEN
 	gpr_price_list_rec.list_header_id := FND_API.G_MISS_NUM;
	gpr_price_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;

	IF (gpr_price_list_rec.automatic_flag IS NULL) THEN
		gpr_price_list_rec.automatic_flag:= 'Y';
	END IF;

 ELSIF (l_operation = 'C') AND (l_list_type_code = 'SLT') THEN
	gpr_modifier_list_rec.list_header_id := FND_API.G_MISS_NUM;
	gpr_modifier_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;

	IF (gpr_modifier_list_rec.automatic_flag IS NULL) THEN
		gpr_modifier_list_rec.automatic_flag:= 'Y';
	END IF;

-- dbms_output.put_line('Header_id: ' || gpr_modifier_list_rec.list_header_id);
-- dbms_output.put_line('Name: ' || gpr_modifier_list_rec.name);
-- dbms_output.put_line('Description: ' || gpr_modifier_list_rec.description);
-- dbms_output.put_line('Operation: ' || gpr_modifier_list_rec.operation);
-- dbms_output.put_line('List_Type_Code: ' || gpr_modifier_list_rec.list_type_code);
-- dbms_output.put_line('Currency_Code: ' || gpr_modifier_list_rec.currency_code);
-- dbms_output.put_line('Start_Date_Active: ' || gpr_modifier_list_rec.start_date_active);
-- dbms_output.put_line('End_Date_Active: ' || gpr_modifier_list_rec.end_date_active);
-- dbms_output.put_line('Automatic_Flag: ' || gpr_modifier_list_rec.automatic_flag);

 END IF;


 i := 1;
 OPEN l_qualifiers;
 LOOP
	FETCH l_qualifiers INTO
        l_operation,
    	gpr_qualifiers_tbl(i).excluder_flag,
    	gpr_qualifiers_tbl(i).comparison_operator_code,
    	gpr_qualifiers_tbl(i).qualifier_context,
    	gpr_qualifiers_val_tbl(i).qualifier_attribute_desc,
    	gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc,
    	gpr_qualifiers_tbl(i).qualifier_grouping_no;
	EXIT WHEN l_qualifiers%NOTFOUND;

	gpr_qualifiers_tbl(i).qualifier_attribute := FND_API.G_MISS_CHAR;
	gpr_qualifiers_tbl(i).qualifier_attr_value := FND_API.G_MISS_CHAR;

	IF (l_operation = 'C') THEN

		gpr_qualifiers_tbl(i).list_header_id := FND_API.G_MISS_NUM;
		gpr_qualifiers_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

		IF (gpr_qualifiers_tbl(i).excluder_flag IS NULL) THEN
			IF (l_list_type_code = 'PRL') THEN
				gpr_qualifiers_tbl(i).excluder_flag:= FND_API.G_MISS_CHAR;
			ELSIF (l_list_type_code = 'SLT') THEN
				gpr_qualifiers_tbl(i).excluder_flag:= 'N';
			END IF;
		END IF;

		IF (gpr_qualifiers_tbl(i).qualifier_grouping_no IS NULL) THEN
			gpr_qualifiers_tbl(i).qualifier_grouping_no:= FND_API.G_MISS_NUM;
		END IF;

		/*
		-- region to id conversion
		IF (UPPER (gpr_qualifiers_val_tbl(i).qualifier_attribute_desc) = 'ORIGIN') THEN
			GetRegionId (gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc, l_region_id, l_err_buffer);
			IF (l_region_id = -1) THEN
				l_err_buffer := 'Origin region id conversion failed. ' || l_err_buffer;
				raise origin_rid_failed;
			ELSE
				gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc := l_region_id;
			END IF;

		ELSIF (UPPER (gpr_qualifiers_val_tbl(i).qualifier_attribute_desc) = 'DESTINATION') THEN
			GetRegionId (gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc, l_region_id, l_err_buffer);
			IF (l_region_id = -1) THEN
				l_err_buffer := 'Destination region id conversion failed. ' || l_err_buffer;
				raise destination_rid_failed;
			ELSE
				gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc := l_region_id;
			END IF;
		END IF;
		*/

		--check if specified price list to be a qualifier exists
		IF (UPPER (gpr_qualifiers_tbl(i).qualifier_context) = 'MODLIST' AND UPPER (gpr_qualifiers_val_tbl(i).qualifier_attribute_desc) = 'PRICE_LIST' ) THEN
			Is_Qualifier_Prclst_Exist (gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc, l_is_prclst_exists, l_err_buffer);
			IF l_is_prclst_exists = FALSE THEN
				raise qualifier_prclst_not_exist;
			END IF;
		END IF;
 	END IF;


--	dbms_output.put_line('*** Qualifier ***');
--	dbms_output.put_line('excluder_flag: ' || gpr_qualifiers_tbl(i).excluder_flag);
--	dbms_output.put_line('comparison_operator_code: ' || gpr_qualifiers_tbl(i).comparison_operator_code);
--	dbms_output.put_line('qualifier_context: ' || gpr_qualifiers_tbl(i).qualifier_context);
--	dbms_output.put_line('qualifier_attribute_desc: ' || gpr_qualifiers_val_tbl(i).qualifier_attribute_desc);
--	dbms_output.put_line('qualifier_attr_value_desc: ' || gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc);
--	dbms_output.put_line('qualifier_grouping_no: ' || gpr_qualifiers_tbl(i).qualifier_grouping_no);

	i := i + 1;

 END LOOP;
 CLOSE l_qualifiers;

IF (l_list_type_code = 'PRL') THEN

	i := 1;
 	OPEN l_lines;
 	LOOP
		FETCH l_lines INTO
    		l_operation,
    		gpr_price_list_line_tbl(i).list_header_id,
    		gpr_price_list_line_tbl(i).list_line_id,
    		gpr_price_list_line_tbl(i).list_line_type_code,
    		gpr_price_list_line_tbl(i).automatic_flag,
    		gpr_price_list_line_tbl(i).override_flag,
    		gpr_price_list_line_tbl(i).modifier_level_code,
    		gpr_price_list_line_tbl(i).operand,
     		gpr_price_list_line_tbl(i).arithmetic_operator,
    		gpr_price_list_line_tbl(i).product_precedence,
    		gpr_price_list_line_tbl(i).comments,
    		gpr_price_list_line_tbl(i).price_break_type_code,
    		gpr_price_list_line_tbl(i).list_line_no,
    		gpr_price_list_line_tbl(i).price_break_header_index;
		EXIT WHEN l_lines%NOTFOUND;

		IF (l_operation = 'C') THEN
			gpr_price_list_line_tbl(i).list_header_id := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).list_line_id := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).from_rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).to_rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).rltd_modifier_group_no := FND_API.G_MISS_NUM;
			gpr_price_list_line_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

			IF (gpr_price_list_line_tbl(i).automatic_flag IS NULL) THEN
				gpr_price_list_line_tbl(i).automatic_flag := FND_API.G_MISS_CHAR;
			END IF;

			IF (gpr_price_list_line_tbl(i).modifier_level_code IS NULL) THEN
				gpr_price_list_line_tbl(i).modifier_level_code := FND_API.G_MISS_CHAR;
			END IF;
 		END IF;

--	dbms_output.put_line('*** List Line ***');
--	dbms_output.put_line('operation: ' || gpr_price_list_line_tbl(i).operation);
--	dbms_output.put_line('Header_id: ' || gpr_price_list_line_tbl(i).list_header_id);
--	dbms_output.put_line('List_line_id: ' || gpr_price_list_line_tbl(i).list_line_id);
--	dbms_output.put_line('list_line_type_code: ' || gpr_price_list_line_tbl(i).list_line_type_code);
--	dbms_output.put_line('automatic_flag: ' || gpr_price_list_line_tbl(i).automatic_flag);
--	dbms_output.put_line('override_flag: ' || gpr_price_list_line_tbl(i).override_flag);
--	dbms_output.put_line('modifier_level_code: ' || gpr_price_list_line_tbl(i).modifier_level_code);
--	dbms_output.put_line('operand: ' || gpr_price_list_line_tbl(i).operand);
--	dbms_output.put_line('arithmetic_operator: ' || gpr_price_list_line_tbl(i).arithmetic_operator);
--	dbms_output.put_line('product_precedence: ' || gpr_price_list_line_tbl(i).product_precedence);
--	dbms_output.put_line('comments: ' || gpr_price_list_line_tbl(i).comments);
--	dbms_output.put_line('price_break_type_code: ' || gpr_price_list_line_tbl(i).price_break_type_code);
--	dbms_output.put_line('list_line_no: ' || gpr_price_list_line_tbl(i).list_line_no);
--	dbms_output.put_line('price_break_header_index: ' || gpr_price_list_line_tbl(i).price_break_header_index);

	i := i + 1;
	END LOOP;
 	CLOSE l_lines;

ELSIF (l_list_type_code = 'SLT') THEN

 	i := 1;
 	OPEN l_mod_lines;
 	LOOP
		FETCH l_mod_lines INTO
    		l_operation,
    		gpr_modifiers_tbl(i).list_header_id,
    		gpr_modifiers_tbl(i).list_line_id,
    		gpr_modifiers_tbl(i).list_line_type_code,
    		gpr_modifiers_tbl(i).automatic_flag,
    		gpr_modifiers_tbl(i).override_flag,
    		gpr_modifiers_tbl(i).modifier_level_code,
    		gpr_modifiers_tbl(i).operand,
        	gpr_modifiers_tbl(i).arithmetic_operator,
    		gpr_modifiers_tbl(i).product_precedence,
    		gpr_modifiers_tbl(i).pricing_group_sequence,
    		gpr_modifiers_tbl(i).pricing_phase_id,
    		gpr_modifiers_tbl(i).comments,
    		gpr_modifiers_tbl(i).price_break_type_code,
    		gpr_modifiers_tbl(i).list_line_no,
    		gpr_modifiers_tbl(i).charge_type_code,
    		gpr_modifiers_tbl(i).charge_subtype_code,
    		gpr_modifiers_tbl(i).modifier_parent_index;
		EXIT WHEN l_mod_lines%NOTFOUND;

		IF (l_operation = 'C') THEN
			gpr_modifiers_tbl(i).list_header_id := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).list_line_id := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).from_rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).to_rltd_modifier_id := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).rltd_modifier_grp_no := FND_API.G_MISS_NUM;
			gpr_modifiers_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

			IF (gpr_modifiers_tbl(i).automatic_flag IS NULL) THEN
				gpr_modifiers_tbl(i).automatic_flag := 'Y';
			END IF;

			IF (gpr_modifiers_tbl(i).override_flag IS NULL) THEN
				gpr_modifiers_tbl(i).override_flag := 'N';
			END IF;

			-- BUG FIX, phase_id should be 2 (line level adjustment)
			-- other values are in qp_pricing_phases table
			IF (gpr_modifiers_tbl(i).pricing_phase_id IS NULL) THEN
				gpr_modifiers_tbl(i).pricing_phase_id := 2;
			END IF;

			IF (gpr_modifiers_tbl(i).modifier_level_code IS NULL) THEN
				gpr_modifiers_tbl(i).modifier_level_code := FND_API.G_MISS_CHAR;
			END IF;

			IF (gpr_modifiers_tbl(i).pricing_group_sequence IS NULL) THEN
				gpr_modifiers_tbl(i).pricing_group_sequence := FND_API.G_MISS_NUM;
			END IF;

			-- add this 4/20/2001
			IF (gpr_modifiers_tbl(i).product_precedence IS NULL) THEN
				gpr_modifiers_tbl(i).product_precedence := 220;
			END IF;
 		END IF;


--	dbms_output.put_line('*** List Line ***');
--	dbms_output.put_line('operation: ' || gpr_modifiers_tbl(i).operation);
--	dbms_output.put_line('Header_id: ' || gpr_modifiers_tbl(i).list_header_id);
--	dbms_output.put_line('List_line_id: ' || gpr_modifiers_tbl(i).list_line_id);
--	dbms_output.put_line('list_line_type_code: ' || gpr_modifiers_tbl(i).list_line_type_code);
--	dbms_output.put_line('automatic_flag: ' || gpr_modifiers_tbl(i).automatic_flag);
--	dbms_output.put_line('override_flag: ' || gpr_modifiers_tbl(i).override_flag);
--	dbms_output.put_line('modifier_level_code: ' || gpr_modifiers_tbl(i).modifier_level_code);
--	dbms_output.put_line('operand: ' || gpr_modifiers_tbl(i).operand);
--	dbms_output.put_line('arithmetic_operator: ' || gpr_modifiers_tbl(i).arithmetic_operator);
--	dbms_output.put_line('product_precedence: ' || gpr_modifiers_tbl(i).product_precedence);
--	dbms_output.put_line('pricing_group_sequence: ' || gpr_modifiers_tbl(i).pricing_group_sequence);
--	dbms_output.put_line('pricing_phase_id: ' || gpr_modifiers_tbl(i).pricing_phase_id);
--	dbms_output.put_line('comments: ' || gpr_modifiers_tbl(i).comments);
--	dbms_output.put_line('price_break_type_code: ' || gpr_modifiers_tbl(i).price_break_type_code);
--	dbms_output.put_line('list_line_no: ' || gpr_modifiers_tbl(i).list_line_no);
--	dbms_output.put_line('modifier_parent_index: ' || gpr_modifiers_tbl(i).modifier_parent_index);
--      dbms_output.put_line('charge_type_code: ' || gpr_modifiers_tbl(i).charge_type_code);
--    	dbms_output.put_line('charge_subtype_code: ' ||	gpr_modifiers_tbl(i).charge_subtype_code);
	i := i + 1;

 	END LOOP;
 	CLOSE l_mod_lines;

 END IF;


 IF (l_list_type_code = 'PRL') THEN

	 i := 1;
 	OPEN l_pricing_attribs;
	LOOP
		FETCH l_pricing_attribs INTO
    		l_operation,
    		gpr_pricing_attr_tbl(i).list_line_id,
    		gpr_pricing_attr_tbl(i).excluder_flag,
    		gpr_pricing_attr_tbl(i).product_attribute_context,
    		gpr_pricing_attr_tbl(i).product_attribute,
    		gpr_pricing_attr_tbl(i).product_attr_value,
    		gpr_pricing_attr_tbl(i).product_uom_code,
    		gpr_pricing_attr_tbl(i).product_attribute_datatype,
    		gpr_pricing_attr_tbl(i).pricing_attribute_datatype,
    		gpr_pricing_attr_tbl(i).pricing_attribute_context,
    		gpr_pricing_attr_val_tbl(i).pricing_attribute_desc,
   		gpr_pricing_attr_val_tbl(i).pricing_attr_value_from_desc,
    		gpr_pricing_attr_val_tbl(i).pricing_attr_value_to_desc,
    		gpr_pricing_attr_tbl(i).attribute_grouping_no,
    		gpr_pricing_attr_tbl(i).comparison_operator_code,
    		gpr_pricing_attr_tbl(i).price_list_line_index;
		EXIT WHEN l_pricing_attribs%NOTFOUND;

		gpr_pricing_attr_tbl(i).pricing_attribute := FND_API.G_MISS_CHAR;
   		gpr_pricing_attr_tbl(i).pricing_attr_value_from := FND_API.G_MISS_CHAR;
    		gpr_pricing_attr_tbl(i).pricing_attr_value_to := FND_API.G_MISS_CHAR;

		IF (l_operation = 'C') THEN
			gpr_pricing_attr_tbl(i).list_line_id := FND_API.G_MISS_NUM;
			gpr_pricing_attr_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

			IF (gpr_pricing_attr_tbl(i).excluder_flag IS NULL) THEN
				gpr_pricing_attr_tbl(i).excluder_flag := FND_API.G_MISS_CHAR;
			END IF;

			IF (gpr_pricing_attr_tbl(i).attribute_grouping_no IS NULL) THEN
				gpr_pricing_attr_tbl(i).attribute_grouping_no := FND_API.G_MISS_NUM;
			END IF;


			IF (gpr_pricing_attr_tbl(i).product_attribute_datatype IS NULL) THEN
				--gpr_pricing_attr_tbl(i).product_attribute_datatype := FND_API.G_MISS_CHAR;
				gpr_pricing_attr_tbl(i).product_attribute_datatype := 'C';
			END IF;

			IF (gpr_pricing_attr_tbl(i).pricing_attribute_datatype IS NULL) THEN
				gpr_pricing_attr_tbl(i).pricing_attribute_datatype := FND_API.G_MISS_CHAR;
				--gpr_pricing_attr_tbl(i).pricing_attribute_datatype := 'C';
			END IF;

			-- the first pricing attribute (i.e. ALL, Pricingattribute3), comparison_operator_code should be '='
			-- since BOI default it to 'BETWEEN' when null, it causes problem.
			-- gpr_pricing_attr_tbl(1).comparison_operator_code := '=';
			IF (gpr_pricing_attr_val_tbl(i).pricing_attribute_desc IS NULL AND
			gpr_pricing_attr_val_tbl(i).pricing_attr_value_from_desc IS NULL) THEN
					gpr_pricing_attr_tbl(i).comparison_operator_code := '=';
			END IF;
 		END IF;

--	dbms_output.put_line('***Pricing Attribute***');
-- 	dbms_output.put_line('operation: ' || gpr_pricing_attr_tbl(i).operation);
-- 	dbms_output.put_line('excluder_flag: ' || gpr_pricing_attr_tbl(i).excluder_flag);
-- 	dbms_output.put_line('product_attribute_context: ' || gpr_pricing_attr_tbl(i).product_attribute_context);
-- 	dbms_output.put_line('product_attribute: ' || gpr_pricing_attr_tbl(i).product_attribute);
-- 	dbms_output.put_line('product_attr_value: ' || gpr_pricing_attr_tbl(i).product_attr_value);
--	dbms_output.put_line('product_uom_code: ' || gpr_pricing_attr_tbl(i).product_uom_code);
-- 	dbms_output.put_line('product_attribute_datatype: ' || gpr_pricing_attr_tbl(i).product_attribute_datatype);
-- 	dbms_output.put_line('pricing_attribute_datatype: ' || gpr_pricing_attr_tbl(i).pricing_attribute_datatype);
-- 	dbms_output.put_line('pricing_attribute_context: ' || gpr_pricing_attr_tbl(i).pricing_attribute_context);
-- 	dbms_output.put_line('pricing_attribute: ' || gpr_pricing_attr_val_tbl(i).pricing_attribute_desc);
-- 	dbms_output.put_line('pricing_attr_value_from: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_from_desc);
-- 	dbms_output.put_line('pricing_attr_value_to: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_to_desc);
-- 	dbms_output.put_line('attribute_grouping_no: ' || gpr_pricing_attr_tbl(i).attribute_grouping_no);
-- 	dbms_output.put_line('comparison_operator_code: ' || gpr_pricing_attr_tbl(i).comparison_operator_code);
-- 	dbms_output.put_line('price_list_line_index: ' || gpr_pricing_attr_tbl(i).price_list_line_index);

	i := i + 1;
 	END LOOP;

 	-- since only pricing_attr_value_from was inserted at the xml gateway level for price breaks,
 	-- therefore we need to calculate and insert the pricing_attr_value_to here when context is VOLUME
 	length := i-1;
-- 	dbms_output.put_line ('length: ' || length);

 	-- no need to calculate the last one since it does not have the next record to calculate
 	FOR i IN 1 .. length-1 LOOP
-- 		dbms_output.put_line('pricing_attr_value_from: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_from_desc);
 		IF (gpr_pricing_attr_tbl(i).comparison_operator_code = 'BETWEEN' AND gpr_pricing_attr_tbl(i).pricing_attribute_context = 'VOLUME') THEN
 			-- take next record's from value minus one to be current record's to value
 		gpr_pricing_attr_val_tbl(i).pricing_attr_value_to_desc := TO_CHAR(TO_NUMBER(gpr_pricing_attr_val_tbl(i+1).pricing_attr_value_from_desc) - 1);
 		END IF;
-- 		dbms_output.put_line('pricing_attr_value_to: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_to_desc);
 	END LOOP;
 	--default the last pricing_attr_value_to_desc to 999,999
 	gpr_pricing_attr_val_tbl(length).pricing_attr_value_to_desc := '999999';

 	CLOSE l_pricing_attribs;

 ELSIF (l_list_type_code = 'SLT') THEN

 	i := 1;
 	OPEN l_pricing_mod_attribs;
 	LOOP
		FETCH l_pricing_mod_attribs INTO
    		l_operation,
    		gpr_pricing_mod_attr_tbl(i).list_line_id,
    		gpr_pricing_mod_attr_tbl(i).excluder_flag,
    		gpr_pricing_mod_attr_tbl(i).product_attribute_context,
    		gpr_pricing_mod_attr_tbl(i).product_attribute,
    		gpr_pricing_mod_attr_tbl(i).product_attr_value,
    		gpr_pricing_mod_attr_tbl(i).product_uom_code,
    		gpr_pricing_mod_attr_tbl(i).product_attribute_datatype,
    		gpr_pricing_mod_attr_tbl(i).pricing_attribute_datatype,
    		gpr_pricing_mod_attr_tbl(i).pricing_attribute_context,
    		gpr_pricing_mod_attr_val_tbl(i).pricing_attribute_desc,
   		gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_from_desc,
    		gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_to_desc,
    		gpr_pricing_mod_attr_tbl(i).attribute_grouping_no,
    		gpr_pricing_mod_attr_tbl(i).comparison_operator_code,
    		gpr_pricing_mod_attr_tbl(i).modifiers_index;
		EXIT WHEN l_pricing_mod_attribs%NOTFOUND;

		gpr_pricing_mod_attr_tbl(i).pricing_attribute := FND_API.G_MISS_CHAR;
   		gpr_pricing_mod_attr_tbl(i).pricing_attr_value_from := FND_API.G_MISS_CHAR;
    		gpr_pricing_mod_attr_tbl(i).pricing_attr_value_to := FND_API.G_MISS_CHAR;

		IF (l_operation = 'C') THEN

			gpr_pricing_mod_attr_tbl(i).list_line_id := FND_API.G_MISS_NUM;
			gpr_pricing_mod_attr_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

 			IF (gpr_pricing_mod_attr_tbl(i).excluder_flag IS NULL) THEN
				--gpr_pricing_mod_attr_tbl(i).excluder_flag := FND_API.G_MISS_CHAR;
				gpr_pricing_mod_attr_tbl(i).excluder_flag := 'N';
			END IF;

			IF (gpr_pricing_mod_attr_tbl(i).attribute_grouping_no IS NULL) THEN
				gpr_pricing_mod_attr_tbl(i).attribute_grouping_no := FND_API.G_MISS_NUM;
			END IF;


			IF (gpr_pricing_mod_attr_tbl(i).product_attribute_datatype IS NULL) THEN
				--gpr_pricing_mod_attr_tbl(i).product_attribute_datatype := FND_API.G_MISS_CHAR;
				gpr_pricing_mod_attr_tbl(i).product_attribute_datatype := 'C';
			END IF;

			IF (gpr_pricing_mod_attr_tbl(i).pricing_attribute_datatype IS NULL) THEN
				--gpr_pricing_mod_attr_tbl(i).pricing_attribute_datatype := FND_API.G_MISS_CHAR;
				gpr_pricing_mod_attr_tbl(i).pricing_attribute_datatype := 'C';
			END IF;

			-- the first pricing attribute for each modifier line, comparison_operator_code should be null
			IF (gpr_pricing_mod_attr_val_tbl(i).pricing_attribute_desc IS NULL AND
				gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_from_desc IS NULL) THEN
					gpr_pricing_mod_attr_tbl(i).comparison_operator_code := NULL;
			END IF;

 		END IF;

--	dbms_output.put_line('***Pricing Mod Attribute***');
-- 	dbms_output.put_line('operation: ' || gpr_pricing_mod_attr_tbl(i).operation);
-- 	dbms_output.put_line('excluder_flag: ' || gpr_pricing_mod_attr_tbl(i).excluder_flag);
-- 	dbms_output.put_line('product_attribute_context: ' || gpr_pricing_mod_attr_tbl(i).product_attribute_context);
-- 	dbms_output.put_line('product_attribute: ' || gpr_pricing_mod_attr_tbl(i).product_attribute);
-- 	dbms_output.put_line('product_attr_value: ' || gpr_pricing_mod_attr_tbl(i).product_attr_value);
-- 	dbms_output.put_line('product_uom_code: ' || gpr_pricing_mod_attr_tbl(i).product_uom_code);
--	dbms_output.put_line('product_attribute_datatype: ' || gpr_pricing_mod_attr_tbl(i).product_attribute_datatype);
-- 	dbms_output.put_line('pricing_attribute_datatype: ' || gpr_pricing_mod_attr_tbl(i).pricing_attribute_datatype);
-- 	dbms_output.put_line('pricing_attribute_context: ' || gpr_pricing_mod_attr_tbl(i).pricing_attribute_context);
-- 	dbms_output.put_line('pricing_attribute: ' || gpr_pricing_mod_attr_val_tbl(i).pricing_attribute_desc);
-- 	dbms_output.put_line('pricing_attr_value_from: ' || gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_from_desc);
-- 	dbms_output.put_line('pricing_attr_value_to: ' || gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_to_desc);
-- 	dbms_output.put_line('attribute_grouping_no: ' || gpr_pricing_mod_attr_tbl(i).attribute_grouping_no);
-- 	dbms_output.put_line('comparison_operator_code: ' || gpr_pricing_mod_attr_tbl(i).comparison_operator_code);
-- 	dbms_output.put_line('modifiers_index: ' || gpr_pricing_mod_attr_tbl(i).modifiers_index);

	i := i + 1;
 	END LOOP;

 	-- since only pricing_attr_value_from was inserted at the xml gateway level,
 	-- therefore we need to calculate and insert the pricing_attr_value_to here
 	length := i-1;
-- 	dbms_output.put_line ('length: ' || length);

 	-- no need to calculate the last one since it does not have the next record to calculate
 	FOR i IN 1 .. length-1 LOOP
-- 		dbms_output.put_line('pricing_attr_value_from: ' || gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_from_desc);
 		IF (gpr_pricing_mod_attr_tbl(i).comparison_operator_code = 'BETWEEN') THEN
 			-- take next record's from value minus one to be current record's to value
 		gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_to_desc := TO_CHAR(TO_NUMBER(gpr_pricing_mod_attr_val_tbl(i+1).pricing_attr_value_from_desc) - 1);
 		END IF;
-- 		dbms_output.put_line('pricing_attr_value_to: ' || gpr_pricing_mod_attr_val_tbl(i).pricing_attr_value_to_desc);
 	END LOOP;

 	-- default the last pricing_attr_value_to to a large number
 	gpr_pricing_mod_attr_val_tbl(length).pricing_attr_value_to_desc := '999999';

 	CLOSE l_pricing_mod_attribs;

END IF;

--commit data to interface table
commit;

IF (l_list_type_code = 'PRL') THEN

-- process price list

QP_PRICE_LIST_PUB.Process_Price_List
 (   p_api_version_number            => 1
 ,   p_init_msg_list                 => FND_API.G_FALSE
 ,   p_return_values                 => FND_API.G_FALSE
 ,   p_commit                        => FND_API.G_FALSE
 ,   x_return_status                 => gpr_return_status
 ,   x_msg_count                     => gpr_msg_count
 ,   x_msg_data                      => gpr_msg_data
 ,   p_PRICE_LIST_rec                => gpr_price_list_rec
 ,   p_PRICE_LIST_LINE_tbl           => gpr_price_list_line_tbl
 ,   p_QUALIFIERS_tbl                => gpr_qualifiers_tbl
 ,   p_QUALIFIERS_val_tbl            => gpr_qualifiers_val_tbl
 ,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
 ,   p_PRICING_ATTR_val_tbl          => gpr_pricing_attr_val_tbl
 ,   x_PRICE_LIST_rec                => ppr_price_list_rec
 ,   x_PRICE_LIST_val_rec            => ppr_price_list_val_rec
 ,   x_PRICE_LIST_LINE_tbl           => ppr_price_list_line_tbl
 ,   x_PRICE_LIST_LINE_val_tbl       => ppr_price_list_line_val_tbl
 ,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
 ,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
 ,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
 ,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
 );

ELSIF (l_list_type_code = 'SLT') THEN

-- process modifier list

 QP_MODIFIERS_PUB.Process_Modifiers
 (   p_api_version_number            => 1
 ,   p_init_msg_list                 => FND_API.G_FALSE
 ,   p_return_values                 => FND_API.G_FALSE
 ,   p_commit                        => FND_API.G_FALSE
 ,   x_return_status                 => gpr_return_status
 ,   x_msg_count                     => gpr_msg_count
 ,   x_msg_data                      => gpr_msg_data
 ,   p_MODIFIER_LIST_rec             => gpr_modifier_list_rec
 ,   p_MODIFIER_LIST_val_rec         => gpr_modifier_list_val_rec
 ,   p_MODIFIERS_tbl           	     => gpr_modifiers_tbl
 ,   p_MODIFIERS_val_tbl             => gpr_modifiers_val_tbl
 ,   p_QUALIFIERS_tbl                => gpr_qualifiers_tbl
 ,   p_QUALIFIERS_val_tbl            => gpr_qualifiers_val_tbl
 ,   p_PRICING_ATTR_tbl              => gpr_pricing_mod_attr_tbl
 ,   p_PRICING_ATTR_val_tbl          => gpr_pricing_mod_attr_val_tbl
 ,   x_MODIFIER_LIST_rec             => ppr_modifier_list_rec
 ,   x_MODIFIER_LIST_val_rec         => ppr_modifier_list_val_rec
 ,   x_MODIFIERS_tbl                 => ppr_modifiers_tbl
 ,   x_MODIFIERS_val_tbl             => ppr_modifiers_val_tbl
 ,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
 ,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
 ,   x_PRICING_ATTR_tbl              => ppr_pricing_mod_attr_tbl
 ,   x_PRICING_ATTR_val_tbl          => ppr_pricing_mod_attr_val_tbl
 );

END IF;

-- get err msg from BOI
for k in 1 .. gpr_msg_count loop
        gpr_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );

           -- max length for err_msg is 240 char in fte_job_errors table
	   x_errors := x_errors || substr(gpr_msg_data,1,239) || ' , ';
--         dbms_output.put_line('Error msg: '|| x_errors);
end loop;

IF gpr_return_status = FND_API.G_RET_STS_SUCCESS THEN
	 x_status := 'COMPLETED';
	 l_job_status := 0;
	 l_job_completion_date := SYSDATE;

	 /*
	 -- job status 0 is success
	 --(JOB_ID, LINES_PROCESSED, LINES_FAILED, LINES_SUBMITTED, TOTAL_ERROR_NUMBER, SUPPLIER_ID, JOB_STATUS, JOB_TYPE, FILENAME, START_DATE, COMPLETION_DATE)
	 Insert_Job_Status  (p_process_id, 1, 0, 1, 0, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 */
--	 dbms_output.put_line('Successfully completed Pricelist BOI');
END IF;

IF gpr_return_status <> FND_API.G_RET_STS_SUCCESS THEN

	 x_status := 'FAILED';
--	 dbms_output.put_line('Error in BOI');
--	 dbms_output.put_line('X_STATUS : ' ||  x_status);
--	 dbms_output.put_line('X_ERRORS : ' ||  x_errors);

	 -- name must be unique for price list
	 IF ( substr(x_errors,1,22) = 'SO_NT_NOTE_NAME_IN_USE') THEN
		l_err_buffer := 'Duplicate Price List.';

	 -- combination of (name, version no, language) must be unique for modifier list
	 -- 4/25/2001, match BOI msg change
	 ELSIF ( substr(x_errors,1,51) = 'The Modifier Number that you entered already exists') THEN
	 	l_err_buffer := 'Duplicate Modifier List.';

	 ELSE
	 	-- 4/25/2001, give all BOI msg instead of 1st msg only
	 	l_err_buffer := SUBSTR(x_errors, 1,239);
--	 	dbms_output.put_line('ERRORS INSERT: ' ||  l_err_buffer);

	 END IF;
	 rollback;	-- do not insert to qp tables

	 l_job_status := 1;
	 l_job_completion_date := SYSDATE;

	 /*
	 Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 -- job status 1 is completed with error
	 --(JOB_ID, LINES_PROCESSED, LINES_FAILED, LINES_SUBMITTED, TOTAL_ERROR_NUMBER, SUPPLIER_ID, JOB_STATUS, JOB_TYPE, FILENAME, START_DATE, COMPLETION_DATE)
	 Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY:'||l_name, l_job_start_date, l_job_completion_date);
	 */
	 RAISE boi_failed_exception;


END IF;

END IF;  -- END IF (l_interface_action_code = 'C')

EXCEPTION

	WHEN party_id_failed THEN
		x_status := 'FAILED';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
		*/
	WHEN null_list_type_code THEN
		--rollback;
		x_status := 'FAILED';
		l_err_buffer := 'PRICELSTTYPE cannot be NULL. Please specify PRICELSTTYPE data as PRL for pricelist or SLT for modifier. ';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;

	 	/*
	 	-- (JOB_ID, LINE_NUMBER, FIELD_NAME, CREATION_DATE, ERROR_MESSAGE, LAST_UPDATE_DATE)
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);

	 	-- (JOB_ID, LINES_PROCESSED, LINES_FAILED, LINES_SUBMITTED, TOTAL_ERROR_NUMBER, SUPPLIER_ID, JOB_STATUS, JOB_TYPE, FILENAME, START_DATE, COMPLETION_DATE)
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/

	WHEN invalid_list_type_code THEN
		--rollback;
		x_status := 'FAILED';
		l_err_buffer := 'PRICELSTTYPE must be PRL or SLT. Please specify PRICELSTTYPE data as PRL for pricelist or SLT for modifier. ';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;

	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/
	WHEN null_interface_action_code THEN
		--rollback;
		x_status := 'FAILED';
		l_err_buffer := 'SYNCIND cannot be NULL. Please specify SYNCIND data as C for create or D for delete. ';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;

	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/
	WHEN invalid_interface_action_code THEN
		--rollback;
		x_status := 'FAILED';
		l_err_buffer := 'SYNCIND must be C or D. Please specify SYNCIND data as C for create or D for delete. ';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;

	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/
	WHEN origin_rid_failed THEN
		--rollback;
		x_status := 'FAILED';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/

	WHEN destination_rid_failed THEN
		--rollback;
		x_status := 'FAILED';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
		*/
	WHEN prclst_not_exist THEN
		--rollback;
		x_status := 'FAILED';
		l_err_buffer := 'Price list to be deleted does not exist. Please correct data for PRICELSTID. ';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/
	WHEN qualifier_prclst_not_exist THEN
		x_status := 'FAILED';
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
	 	*/
	WHEN  boi_failed_exception THEN
		x_status := 'FAILED';

	WHEN others THEN
		rollback;
		x_status := 'FAILED';
		-- error_message column in fte_job_errors only has width 240
		l_err_buffer := SUBSTR('Unexpected error occurred. '||SQLERRM , 1, 239);
		l_job_status := 1;
	 	l_job_completion_date := SYSDATE;
	 	/*
	 	Insert_Err_Msg (p_process_id, 1, l_name, SYSDATE, l_err_buffer, SYSDATE);
	 	Insert_Job_Status  (p_process_id, 1, 1, 1, 1, l_party_id, l_job_status, 'TARI', 'GATEWAY: '||l_name, l_job_start_date, l_job_completion_date);
		*/
END Load_Int_List;

--overload procedure
PROCEDURE LOAD_INT_LIST
(	p_process_id	IN	NUMBER,
	p_action_code	IN	VARCHAR2
)
IS

BEGIN

	Load_INT_List(p_process_id, G_temp_status, G_temp_errors);

END LOAD_INT_LIST;

/*
-- procedure to insert err message to FTE_JOB_ERRORS
	PROCEDURE Insert_Err_Msg
	(
		p_job_id		IN	NUMBER,
		p_line_num		IN	NUMBER,
		p_field_name		IN 	VARCHAR2,
		p_creation_date		IN 	DATE,
		p_err_msg		IN 	VARCHAR2,
		p_last_update_date	IN 	DATE
	)
	IS
	BEGIN
		INSERT INTO FTE_JOB_ERRORS (JOB_ID, LINE_NUMBER, FIELD_NAME, CREATION_DATE, ERROR_MESSAGE, LAST_UPDATE_DATE)
	 	VALUES (p_job_id, p_line_num, p_field_name, p_creation_date, p_err_msg, p_last_update_date);
	 	commit;

	END Insert_Err_Msg;

	PROCEDURE Insert_Job_Status
	(
		p_job_id		IN	NUMBER,
		p_lines_processed	IN	NUMBER,
		p_lines_failed		IN 	NUMBER,
		p_lines_submitted	IN 	NUMBER,
		p_total_error_number	IN 	NUMBER,
		p_supplier_id		IN 	NUMBER,
		p_job_status		IN	VARCHAR2,
		p_job_type		IN	VARCHAR2,
		p_file_name		IN	VARCHAR2,
		p_start_date		IN 	DATE,
		p_completion_date	IN	DATE
	)
	IS
	BEGIN
		-- job status 0 = completed with success, 1 = completed with error
		INSERT INTO FTE_BATCH_JOBS (JOB_ID, LINES_PROCESSED, LINES_FAILED, LINES_SUBMITTED, TOTAL_ERROR_NUMBER, SUPPLIER_ID, JOB_STATUS, JOB_TYPE, FILENAME, START_DATE, COMPLETION_DATE)
	 	VALUES (p_job_id, p_lines_processed, p_lines_failed, p_lines_submitted, p_total_error_number, p_supplier_id, p_job_status, p_job_type, p_file_name, p_start_date, p_completion_date);
	 	commit;
	END Insert_Job_Status;


	PROCEDURE GetRegionId (
		p_region_str IN VARCHAR2,
		x_region_id OUT NOCOPY NUMBER,
		x_rid_err_msg OUT NOCOPY VARCHAR2
	)
	IS

 	l_occurance NUMBER := 1;
 	l_width NUMBER:= 1;
 	l_token VARCHAR2(100) := NULL;
 	l_prev_width NUMBER:= 0;
 	l_tk_prev_width NUMBER := 0;
 	l_parse_str VARCHAR2(100) := NULL;
 	l_tk_str VARCHAR2(100) := NULL;
 	l_tk_attr VARCHAR2(50) := NULL;
 	l_tk_attr_val VARCHAR2(50) := NULL;
 	l_city VARCHAR2(100) := NULL;
 	l_state VARCHAR2(100) := NULL;
 	l_country VARCHAR2(100) := NULL;
 	l_zip VARCHAR2(100) := NULL;
 	l_zone VARCHAR2(100) := NULL;
 	invalid_key EXCEPTION;
 	no_regionid_found EXCEPTION;

	BEGIN

	-- append ',' to end city_state_country_str for tokenization reason
	l_parse_str := p_region_str || SUBSTR (',' , 1, 1);

	LOOP
		l_width := INSTR (l_parse_str, ',', 1,l_occurance);

		-- when no more tokens
		EXIT WHEN l_width = 0;

		-- trim off the white space at left, ',' at right
		l_token := LTRIM (SUBSTR (l_parse_str, l_prev_width + 1, l_width - l_prev_width -1));

		-- append '-' to end string for tokenization reason
		l_tk_str := l_token || SUBSTR ('-' , 1, 1);
		l_tk_prev_width := INSTR (l_tk_str, '-', 1, 1);		-- up to first '-'

		-- get key-value pair
		l_tk_attr := LTRIM (SUBSTR (l_tk_str, 1, l_tk_prev_width -1));		-- key
		l_tk_attr_val :=  LTRIM (SUBSTR (l_tk_str, l_tk_prev_width + 1, INSTR (l_tk_str, '-', 1, 2) - l_tk_prev_width-1)); --value
		-- dbms_output.put_line ('tk_attr ' || l_occurance || ': ' || l_tk_attr);
		-- dbms_output.put_line ('tk_attr_val ' || l_occurance || ': ' || l_tk_attr_val);

		IF UPPER(l_tk_attr) = 'CITY' THEN
			l_city := l_tk_attr_val;
		ELSIF UPPER(l_tk_attr) = 'STATE' THEN
			l_state := l_tk_attr_val;
		ELSIF UPPER(l_tk_attr) = 'COUNTRY' THEN
			l_country := l_tk_attr_val;
		ELSIF UPPER(l_tk_attr) = 'ZONE' THEN
			l_zone := l_tk_attr_val;
		ELSIF UPPER(l_tk_attr) = 'POSTAL CODE' THEN
			l_zip := l_tk_attr_val;
		ELSE
			raise invalid_key;
		END IF;

		l_prev_width := l_width;
		l_occurance := l_occurance + 1;

	END LOOP;


	-- use FTE_REGIONS_PKG.Get_Region_Id_TL (parent_region_type, country, country_region, state, city, postal_code, zone, lang_code, interface_flag, x_region_id);
	FTE_REGIONS_PKG.Get_Region_Id_TL(NULL, l_country, NULL, l_state, l_city, l_zip, l_zone, NULL, 'N', x_region_id);

	-- dbms_output.put_line('region id: ' || x_region_id);
	IF x_region_id = -1 THEN
		raise no_regionid_found;
	END IF;

	EXCEPTION
		WHEN invalid_key THEN
			x_region_id := -1;
			x_rid_err_msg := 'Please use City, State, Country, Zone, Postal Code to define the region. Please correct data for ATTRIBUTE_VALUE. ';
		WHEN no_regionid_found THEN
			x_region_id := -1;
			x_rid_err_msg := 'No region id found. Please correct data for ATTRIBUTE_VALUE. ';
		WHEN others THEN
			x_region_id := -1;
			x_rid_err_msg := SUBSTR('Upnexpected error occurred while obtaining region id. Please correct data for ATTRIBUTE_VALUE. '||SQLERRM , 1, 239);

	END GetRegionId;
*/

	PROCEDURE Get_Party_Id
	(
		p_process_id IN NUMBER,
		x_party_id OUT NOCOPY /* file.sql.39 change */ NUMBER,
		x_pid_err_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	)
	IS
		l_party_name VARCHAR2(360):= NULL;
	BEGIN

 		-- obtain party_name
 		SELECT q.qualifier_attr_value
 		INTO l_party_name
 		FROM qp_interface_qualifiers q
 		WHERE q.process_id = p_process_id AND q.qualifier_context = 'PARTY';

 		--obtain the party_id
 		SELECT hz_parties.party_id
 		INTO x_party_id
 		FROM hz_parties
 		WHERE hz_parties.party_name = l_party_name;

 		Exception

 		WHEN NO_DATA_FOUND THEN
 			x_party_id := -1;
 			x_pid_err_msg := 'No party id found for the specified party name. Please correct data for SUPPLIERID. ';
		WHEN others THEN
			x_party_id := -1;
			x_pid_err_msg := SUBSTR('Upnexpected error occurred while obtaining party id. Please correct data for SUPPLIERID. '||SQLERRM , 1, 239);


	END Get_Party_Id;

	PROCEDURE Is_Qualifier_Prclst_Exist
	(
		p_prclst_name IN VARCHAR2,
		x_prclst_exists OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
		x_prclst_exists_err_msg OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	)
	IS
		l_count NUMBER := NULL;
	BEGIN
		SELECT count(1) into l_count from qp_list_headers_tl where name = p_prclst_name;
		IF l_count = 0 THEN
			x_prclst_exists := FALSE;
			x_prclst_exists_err_msg := SUBSTR('Prclst specified as a qualifier does not exists. Please correct data for ATTRIBUTE_VALUE. ', 1,239);
		ELSE
			x_prclst_exists := TRUE;
		END IF;

	EXCEPTION

	WHEN others THEN
		x_prclst_exists := FALSE;
		x_prclst_exists_err_msg := SUBSTR('Upnexpected error occurred while obtaining the prclst specified as a qualifier. '||SQLERRM , 1, 239);
	END Is_Qualifier_Prclst_Exist;


END QP_INT_LOADER_PUB;

/
