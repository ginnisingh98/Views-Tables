--------------------------------------------------------
--  DDL for Package Body QP_MOD_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MOD_LOADER_PUB" AS
/* $Header: QPXMLDRB.pls 120.1 2005/06/10 02:45:43 appldev  $ */


PROCEDURE Load_Mod_List
(	p_process_id	IN	NUMBER,
	p_req_type_code	IN	VARCHAR2,
	x_status		OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_errors		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS

 gpr_return_status varchar2(30) := NULL;
 gpr_msg_count number := 0;
 gpr_msg_data varchar2(2000);
 x_error varchar2(2000);
 l_operation VARCHAR2(30);
 l_process_type VARCHAR2(30);
 l_line_index VARCHAR2(30);
 i number := 1;

 gpr_modifier_list_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
 gpr_modifier_list_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 gpr_modifiers_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
 gpr_modifiers_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
 gpr_qualifiers_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
 gpr_qualifiers_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 gpr_pricing_attr_tbl              QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 gpr_pricing_attr_val_tbl          QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

 ppr_modifier_list_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
 ppr_modifier_list_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
 ppr_modifiers_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
 ppr_modifiers_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
 ppr_qualifiers_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
 ppr_qualifiers_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
 ppr_pricing_attr_tbl              QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
 ppr_pricing_attr_val_tbl          QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;


-- Getting the data from the interface tables

 CURSOR l_qualifiers IS
 SELECT
    qual.interface_action_code,
    qual.qualifier_id,
    qual.list_header_id,
    qual.excluder_flag,
    qual.comparison_operator_code,
    qual.qualifier_context,
    qual.qualifier_attribute,
    qual.qualifier_attr_value,
    qual.qualifier_datatype,
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
    line.start_date_active,
    line.end_date_active,
    line.automatic_flag,
    line.override_flag,
    line.modifier_level_code,
    line.price_by_formula_id,
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
    line.price_break_header_index,
    line.attribute1
 FROM
    qp_interface_list_lines line
 WHERE
    line.process_id = p_process_id
 ORDER BY
    TO_NUMBER(line.list_line_no);

 CURSOR l_pricing_attribs IS
 SELECT
    pa.interface_action_code,
    pa.pricing_attribute_id,
    pa.list_header_id,
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
    --pa.price_list_line_index
    pa.list_line_no
 FROM
    qp_interface_pricing_attribs pa
 WHERE
    pa.process_id = p_process_id
 ORDER BY
    TO_NUMBER(pa.list_line_no);


BEGIN

-- Transferring data into pl/sql tables used as input to the PriceList BOI
 QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE := p_req_type_code;
 x_status := 1;

 SELECT process_type
 INTO   l_process_type
 FROM   qp_interface_list_headers
 WHERE  process_id = p_process_id;


 IF (l_process_type = 'XML') THEN

        SELECT
                lhdr.list_header_id,
                lhdr.name,
                lhdr.description,
                lhdr.interface_action_code,
                lhdr.list_type_code,
                lhdr.currency_code,
                TO_DATE(lhdr.start_date_active,'YYYYMMDD HHMISS'),
                TO_DATE(lhdr.end_date_active,'YYYYMMDD HHMISS'),
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
 ELSE

 SELECT
    lhdr.list_header_id,
    lhdr.name,
    lhdr.description,
    lhdr.interface_action_code,
    lhdr.list_type_code,
    lhdr.currency_code,
    lhdr.start_date_active,
    lhdr.end_date_active,
    'LOGSTX',
    lhdr.automatic_flag,
    lhdr.attribute1
--    lhdr.source_system_code,
--    lhdr.active_flag
 INTO
    gpr_modifier_list_rec.list_header_id,
    gpr_modifier_list_rec.name,
    gpr_modifier_list_rec.description,
    l_operation,
    gpr_modifier_list_rec.list_type_code,
    gpr_modifier_list_rec.currency_code,
    gpr_modifier_list_rec.start_date_active,
    gpr_modifier_list_rec.end_date_active,
    gpr_modifier_list_rec.pte_code,
    gpr_modifier_list_rec.automatic_flag,
    gpr_modifier_list_rec.attribute1
 FROM
    qp_interface_list_headers lhdr
 WHERE
    lhdr.process_id = p_process_id
 AND
    rownum < 2;

 END IF;

 IF (l_operation = 'C') THEN
	gpr_modifier_list_rec.list_header_id := FND_API.G_MISS_NUM;
	gpr_modifier_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;
 END IF;

 IF (l_operation = 'U') THEN
        gpr_modifier_list_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
        --dbms_output.put_line('Setting operation to update');
 END IF;

 IF (l_operation = 'D') THEN
        gpr_modifier_list_rec.operation := QP_GLOBALS.G_OPR_DELETE;
        --dbms_output.put_line('Setting operation to update');
 END IF;


 --dbms_output.put_line('Header_id: ' || gpr_modifier_list_rec.list_header_id);
 --dbms_output.put_line('Name: ' || gpr_modifier_list_rec.name);
 --dbms_output.put_line('Description: ' || gpr_modifier_list_rec.description);
 --dbms_output.put_line('Operation: ' || gpr_modifier_list_rec.operation);
 --dbms_output.put_line('List_Type_Code: ' || gpr_modifier_list_rec.list_type_code);
 --dbms_output.put_line('Currency_Code: ' || gpr_modifier_list_rec.currency_code);
 --dbms_output.put_line('Start_Date_Active: ' || gpr_modifier_list_rec.start_date_active);
 --dbms_output.put_line('End_Date_Active: ' || gpr_modifier_list_rec.end_date_active);
 --dbms_output.put_line('Attribute1: ' || gpr_modifier_list_rec.attribute1);
 --dbms_output.put_line('Automatic_Flag: ' || gpr_modifier_list_rec.automatic_flag);



 i := 1;
 OPEN l_qualifiers;
 LOOP
	FETCH l_qualifiers INTO
        l_operation,
        gpr_qualifiers_tbl(i).qualifier_id,
        gpr_qualifiers_tbl(i).list_header_id,
    	gpr_qualifiers_tbl(i).excluder_flag,
    	gpr_qualifiers_tbl(i).comparison_operator_code,
    	gpr_qualifiers_tbl(i).qualifier_context,
    	gpr_qualifiers_val_tbl(i).qualifier_attribute_desc,
	gpr_qualifiers_tbl(i).qualifier_attr_value,
    	--gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc,
    	gpr_qualifiers_tbl(i).qualifier_datatype,
    	gpr_qualifiers_tbl(i).qualifier_grouping_no;
	EXIT WHEN l_qualifiers%NOTFOUND;

	gpr_qualifiers_tbl(i).qualifier_attribute := FND_API.G_MISS_CHAR;
	--gpr_qualifiers_tbl(i).qualifier_attr_value := FND_API.G_MISS_CHAR;

	IF (l_operation = 'C') THEN
		gpr_qualifiers_tbl(i).list_header_id := FND_API.G_MISS_NUM;
		gpr_qualifiers_tbl(i).qualifier_id := FND_API.G_MISS_NUM;
		gpr_qualifiers_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;

                IF (gpr_qualifiers_tbl(i).excluder_flag IS NULL) THEN
                        gpr_qualifiers_tbl(i).excluder_flag:= FND_API.G_MISS_CHAR;
                END IF;

                IF (gpr_qualifiers_tbl(i).qualifier_grouping_no IS NULL) THEN
                        gpr_qualifiers_tbl(i).qualifier_grouping_no:= FND_API.G_MISS_NUM;
                END IF;


 	END IF;

        IF (l_operation = 'U') THEN
                gpr_qualifiers_tbl(i).operation := QP_GLOBALS.G_OPR_UPDATE;
        END IF;

        IF (l_operation = 'D') THEN
                gpr_qualifiers_tbl(i).operation := QP_GLOBALS.G_OPR_DELETE;
        END IF;


	--dbms_output.put_line('*** Qualifier ***');
        --dbms_output.put_line('Qualifier Id: ' || gpr_qualifiers_tbl(i).qualifier_id);
        --dbms_output.put_line('List_header_id: ' || gpr_qualifiers_tbl(i).list_header_id);
        --dbms_output.put_line('Operation: ' || gpr_qualifiers_tbl(i).operation);
	--dbms_output.put_line('excluder_flag: ' || gpr_qualifiers_tbl(i).excluder_flag);
	--dbms_output.put_line('comparison_operator_code: ' || gpr_qualifiers_tbl(i).comparison_operator_code);
	--dbms_output.put_line('qualifier_context: ' || gpr_qualifiers_tbl(i).qualifier_context);
	--dbms_output.put_line('qualifier_attribute_desc: ' || gpr_qualifiers_val_tbl(i).qualifier_attribute_desc);
	--dbms_output.put_line('qualifier_attr_value_desc: ' || gpr_qualifiers_val_tbl(i).qualifier_attr_value_desc);
	--dbms_output.put_line('qualifier_datatype: ' || gpr_qualifiers_tbl(i).qualifier_datatype);
	--dbms_output.put_line('qualifier_grouping_no: ' || gpr_qualifiers_tbl(i).qualifier_grouping_no);

	i := i + 1;

 END LOOP;

 i := 1;
 OPEN l_lines;
 LOOP
	FETCH l_lines INTO
    	l_operation,
    	gpr_modifiers_tbl(i).list_header_id,
    	gpr_modifiers_tbl(i).list_line_id,
    	gpr_modifiers_tbl(i).list_line_type_code,
    	gpr_modifiers_tbl(i).start_date_active,
    	gpr_modifiers_tbl(i).end_date_active,
    	gpr_modifiers_tbl(i).automatic_flag,
    	gpr_modifiers_tbl(i).override_flag,
    	gpr_modifiers_tbl(i).modifier_level_code,
    	gpr_modifiers_tbl(i).price_by_formula_id,
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
    	gpr_modifiers_tbl(i).modifier_parent_index,
    	l_line_index;
	EXIT WHEN l_lines%NOTFOUND;

	IF (l_operation = 'C') THEN
                IF (gpr_modifiers_tbl(i).list_header_id IS NULL) THEN
                        gpr_modifiers_tbl(i).list_header_id := FND_API.G_MISS_NUM;
                END IF;

                IF (gpr_modifiers_tbl(i).list_line_no IS NULL) THEN
                        gpr_modifiers_tbl(i).list_line_no := FND_API.G_MISS_CHAR;
                END IF;

		--dbms_output.put_line('Here is modifier_parent_index : ' || gpr_modifiers_tbl(i).modifier_parent_index);
		IF (gpr_modifiers_tbl(i).modifier_parent_index IS NOT NULL) THEN
			gpr_modifiers_tbl(i).rltd_modifier_grp_type := 'PRICE BREAK';
		END IF;

		gpr_modifiers_tbl(i).list_line_id := FND_API.G_MISS_NUM;
		gpr_modifiers_tbl(i).rltd_modifier_id := FND_API.G_MISS_NUM;
		gpr_modifiers_tbl(i).from_rltd_modifier_id := FND_API.G_MISS_NUM;
		gpr_modifiers_tbl(i).to_rltd_modifier_id := FND_API.G_MISS_NUM;
		gpr_modifiers_tbl(i).rltd_modifier_grp_no := 10;
		gpr_modifiers_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;
 	END IF;

        IF (l_operation = 'U') THEN
                gpr_modifiers_tbl(i).operation := QP_GLOBALS.G_OPR_UPDATE;
        END IF;

        IF (l_operation = 'D') THEN
                gpr_modifiers_tbl(i).operation := QP_GLOBALS.G_OPR_DELETE;
        END IF;


	--dbms_output.put_line('*** Mod Line ***');
	--dbms_output.put_line('operation: ' || gpr_modifiers_tbl(i).operation);
	--dbms_output.put_line('Header_id: ' || gpr_modifiers_tbl(i).list_header_id);
	--dbms_output.put_line('List_line_id: ' || gpr_modifiers_tbl(i).list_line_id);
	--dbms_output.put_line('list_line_type_code: ' || gpr_modifiers_tbl(i).list_line_type_code);
	--dbms_output.put_line('start_date_active: ' || gpr_modifiers_tbl(i).start_date_active);
	--dbms_output.put_line('end_date_active: ' || gpr_modifiers_tbl(i).end_date_active);
	--dbms_output.put_line('automatic_flag: ' || gpr_modifiers_tbl(i).automatic_flag);
	--dbms_output.put_line('override_flag: ' || gpr_modifiers_tbl(i).override_flag);
	--dbms_output.put_line('modifier_level_code: ' || gpr_modifiers_tbl(i).modifier_level_code);
	--dbms_output.put_line('price_by_formula_id: ' || gpr_modifiers_tbl(i).price_by_formula_id);
	--dbms_output.put_line('operand: ' || gpr_modifiers_tbl(i).operand);
	--dbms_output.put_line('arithmetic_operator: ' || gpr_modifiers_tbl(i).arithmetic_operator);
	--dbms_output.put_line('product_precedence: ' || gpr_modifiers_tbl(i).product_precedence);
	--dbms_output.put_line('pricing_group_sequence: ' || gpr_modifiers_tbl(i).pricing_group_sequence);
	--dbms_output.put_line('pricing_phase_id: ' || gpr_modifiers_tbl(i).pricing_phase_id);
	--dbms_output.put_line('comments: ' || gpr_modifiers_tbl(i).comments);
	--dbms_output.put_line('price_break_type_code: ' || gpr_modifiers_tbl(i).price_break_type_code);
	--dbms_output.put_line('list_line_no: ' || gpr_modifiers_tbl(i).list_line_no);
	--dbms_output.put_line('charge_type_code: ' || gpr_modifiers_tbl(i).charge_type_code);
	--dbms_output.put_line('charge_subtype_code: ' || gpr_modifiers_tbl(i).charge_subtype_code);
	--dbms_output.put_line('modifier_parent_index: ' || gpr_modifiers_tbl(i).modifier_parent_index);
	--dbms_output.put_line('rltd_modifier_grp_type: ' || gpr_modifiers_tbl(i).rltd_modifier_grp_type);
        --dbms_output.put_line('mod_line_index: ' ||  l_line_index);

	i := i + 1;

 END LOOP;


 i := 1;
 OPEN l_pricing_attribs;
 LOOP
	FETCH l_pricing_attribs INTO
    	l_operation,
        gpr_pricing_attr_tbl(i).pricing_attribute_id,
        gpr_pricing_attr_tbl(i).list_header_id,
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
    	gpr_pricing_attr_tbl(i).modifiers_index;
	EXIT WHEN l_pricing_attribs%NOTFOUND;

	IF (l_operation = 'C') THEN

                IF (gpr_pricing_attr_tbl(i).list_header_id IS NULL) THEN
                        gpr_pricing_attr_tbl(i).list_header_id := FND_API.G_MISS_NUM;
                END IF;

                gpr_pricing_attr_tbl(i).pricing_attribute_id := FND_API.G_MISS_NUM;
                gpr_pricing_attr_tbl(i).list_line_id := FND_API.G_MISS_NUM;
                gpr_pricing_attr_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;
                gpr_pricing_attr_tbl(i).pricing_attribute := FND_API.G_MISS_CHAR;
                gpr_pricing_attr_tbl(i).pricing_attr_value_from := FND_API.G_MISS_CHAR;
                gpr_pricing_attr_tbl(i).pricing_attr_value_to := FND_API.G_MISS_CHAR;

	END IF;

        IF (l_operation = 'U') THEN
                gpr_pricing_attr_tbl(i).operation := QP_GLOBALS.G_OPR_UPDATE;
        END IF;

        IF (l_operation = 'D') THEN
                gpr_pricing_attr_tbl(i).operation := QP_GLOBALS.G_OPR_DELETE;
        END IF;

	--dbms_output.put_line('***Pricing Attribute***');
        --dbms_output.put_line('Pricing Attribute Id: ' || gpr_pricing_attr_tbl(i).pricing_attribute_id);
        --dbms_output.put_line('List Header Id: ' || gpr_pricing_attr_tbl(i).list_header_id);
        --dbms_output.put_line('List Line Id: ' || gpr_pricing_attr_tbl(i).list_line_id);
 	--dbms_output.put_line('operation: ' || gpr_pricing_attr_tbl(i).operation);
 	--dbms_output.put_line('excluder_flag: ' || gpr_pricing_attr_tbl(i).excluder_flag);
 	--dbms_output.put_line('product_attribute_context: ' || gpr_pricing_attr_tbl(i).product_attribute_context);
 	--dbms_output.put_line('product_attribute: ' || gpr_pricing_attr_tbl(i).product_attribute);
 	--dbms_output.put_line('product_attr_value: ' || gpr_pricing_attr_tbl(i).product_attr_value);
 	--dbms_output.put_line('product_uom_code: ' || gpr_pricing_attr_tbl(i).product_uom_code);
 	--dbms_output.put_line('product_attribute_datatype: ' || gpr_pricing_attr_tbl(i).product_attribute_datatype);
 	--dbms_output.put_line('pricing_attribute_datatype: ' || gpr_pricing_attr_tbl(i).pricing_attribute_datatype);
 	--dbms_output.put_line('pricing_attribute_context: ' || gpr_pricing_attr_tbl(i).pricing_attribute_context);
 	--dbms_output.put_line('pricing_attribute: ' || gpr_pricing_attr_val_tbl(i).pricing_attribute_desc);
 	--dbms_output.put_line('pricing_attr_value_from: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_from_desc);
 	--dbms_output.put_line('pricing_attr_value_to: ' || gpr_pricing_attr_val_tbl(i).pricing_attr_value_to_desc);
 	--dbms_output.put_line('attribute_grouping_no: ' || gpr_pricing_attr_tbl(i).attribute_grouping_no);
 	--dbms_output.put_line('comparison_operator_code: ' || gpr_pricing_attr_tbl(i).comparison_operator_code);
 	--dbms_output.put_line('modifiers_index: ' || gpr_pricing_attr_tbl(i).modifiers_index);

	i := i + 1;
 END LOOP;



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
 ,   p_PRICING_ATTR_tbl              => gpr_pricing_attr_tbl
 ,   p_PRICING_ATTR_val_tbl          => gpr_pricing_attr_val_tbl
 ,   x_MODIFIER_LIST_rec             => ppr_modifier_list_rec
 ,   x_MODIFIER_LIST_val_rec         => ppr_modifier_list_val_rec
 ,   x_MODIFIERS_tbl                 => ppr_modifiers_tbl
 ,   x_MODIFIERS_val_tbl             => ppr_modifiers_val_tbl
 ,   x_QUALIFIERS_tbl                => ppr_qualifiers_tbl
 ,   x_QUALIFIERS_val_tbl            => ppr_qualifiers_val_tbl
 ,   x_PRICING_ATTR_tbl              => ppr_pricing_attr_tbl
 ,   x_PRICING_ATTR_val_tbl          => ppr_pricing_attr_val_tbl
 );

IF gpr_return_status = FND_API.G_RET_STS_SUCCESS THEN
	 x_status := 'COMPLETED';
END IF;

IF gpr_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        x_status := 'FAILED';
        for k in 1 .. gpr_msg_count loop
                gpr_msg_data := oe_msg_pub.get( p_msg_index => k, p_encoded => 'F');
                x_error :=  substr(gpr_msg_data,1,2000);
                IF (x_error = 'SO_NT_NOTE_NAME_IN_USE') THEN
                   x_error := 'Pricelist name already in use';
                END IF;
                x_errors := x_errors || x_error || ' , ';
                --dbms_output.put_line('Error msg: '||substr(gpr_msg_data,1,2000));
        end loop;

         --dbms_output.put_line('Error in BOI');
         --dbms_output.put_line('error_count : ' ||  gpr_msg_count);
         --dbms_output.put_line('X_STATUS : ' ||  x_status);
         --dbms_output.put_line('X_ERRORS : ' ||  x_errors);

        rollback;
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;


 --dbms_output.put_line('after process mod list ');
EXCEPTION
WHEN OTHERS THEN
x_status := 'FAILED';
x_error := 'Exception';


END LOAD_MOD_LIST;


END QP_MOD_LOADER_PUB;

/
