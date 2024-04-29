--------------------------------------------------------
--  DDL for Package Body QP_UPDATE_FORMULAPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UPDATE_FORMULAPRICE_PVT" AS
/* $Header: QPXVUFPB.pls 120.8.12010000.4 2009/04/21 07:13:01 smbalara ship $ */


PROCEDURE Update_Formula_Price
(
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_update_flagged_items IN    VARCHAR2,
 p_retrieve_all_flag    IN    VARCHAR2,
 p_price_formula_id     IN    NUMBER
)
IS
l_conc_request_id			NUMBER := -1;
l_conc_program_application_id	NUMBER := -1;
l_conc_program_id			NUMBER := -1;
l_conc_login_id		   	NUMBER := -1;
l_user_id					NUMBER := -1;
l_price_formula_id            NUMBER;
l_name                        VARCHAR2(1000);
l_formula                     VARCHAR2(1000);
l_sysdate                     DATE;
l_step_count                  NUMBER := 0;
l_req_line_attrs_tbl          Qp_Formula_Price_Calc_Pvt.req_line_attrs_tbl;

x_return_status               VARCHAR2(30) := '';
l_error_message               VARCHAR2(240) := '';
l_list_price                  NUMBER := 0;
l_rounding_factor             NUMBER := -2;
l_price_rounding              VARCHAR2(50):='';
NEGATIVE_VALUE                EXCEPTION;

CURSOR qp_price_formulas_cur(a_price_formula_id  NUMBER,
					    a_retrieve_all_flag VARCHAR2)
IS
  SELECT *
  FROM   qp_price_formulas_vl
  WHERE  price_formula_id = DECODE (a_retrieve_all_flag,
							 'Y', price_formula_id, a_price_formula_id)
  AND   (start_date_active IS NULL OR start_date_active <= SYSDATE)
  AND   (end_date_active   IS NULL OR end_date_active   >= SYSDATE);

/*
CURSOR qp_list_lines_cur(a_price_formula_id     NUMBER,
					a_update_flagged_items VARCHAR2)
IS
  SELECT *
  FROM   qp_list_lines
  WHERE  generate_using_formula_id = a_price_formula_id
  AND    NVL(reprice_flag, 'N')    = DECODE (a_update_flagged_items,
									'Y', 'Y', NVL(reprice_flag, 'N'))
  FOR UPDATE;
*/

CURSOR qp_pricing_attributes_cur(a_list_line_id NUMBER)
IS
  SELECT *
  FROM   qp_pricing_attributes
  WHERE  list_line_id = a_list_line_id;

TYPE QpListLinesCurTyp IS REF CURSOR;
qp_list_lines_cursor QpListLinesCurTyp;

l_lines_rec QP_LIST_LINES%ROWTYPE;

BEGIN

-- Bug#4968517 - Turn Debug ON.
Qp_Preq_Grp.Set_QP_Debug;

l_conc_request_id := Fnd_Global.CONC_REQUEST_ID;
l_conc_program_id := Fnd_Global.CONC_PROGRAM_ID;
l_user_id         := Fnd_Global.USER_ID;
l_conc_login_id   := Fnd_Global.CONC_LOGIN_ID;
l_conc_program_application_id := Fnd_Global.PROG_APPL_ID;

l_sysdate := SYSDATE;

--Change flexible mask to mask below for formula pattern use.
Qp_Number.canonical_mask :=
    '00999999999999999999999.99999999999999999999999999999999999999';

/*  Select the Price Formulas which are to be used to update list prices. */
/*  Select all or a specific formula depending on the option selected.    */

  --dbms_output.put_line('looping through the qp_price_formulas_cur');

FOR l_formulas_rec IN qp_price_formulas_cur(p_price_formula_id,
				            p_retrieve_all_flag)
LOOP
  --dbms_output.put_line('inside qp_price_formulas_cur formula_id: '||l_formulas_rec.price_formula_id);

  Qp_Formula_Price_Calc_Pvt.Parse_Formula(l_formulas_rec.formula,
					  x_return_status);

  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
        l_error_message := Fnd_Message.GET;
        Fnd_File.put_line(Fnd_File.LOG,l_error_message);
  --dbms_output.put_line('error in formula parsing ' || l_error_message);
  END IF;
--modified where condition for cursor below for fix 8429665
  IF p_update_flagged_items = 'Y' THEN
        OPEN qp_list_lines_cursor FOR
        SELECT *
        FROM   qp_list_lines
        WHERE  generate_using_formula_id = l_formulas_rec.price_formula_id
        AND    reprice_flag = 'Y'
        FOR UPDATE;
  ELSE
        OPEN qp_list_lines_cursor FOR
        SELECT *
        FROM   qp_list_lines
        WHERE  generate_using_formula_id = l_formulas_rec.price_formula_id
        FOR UPDATE;
  END IF;

  FETCH qp_list_lines_cursor INTO l_lines_rec;
  WHILE qp_list_lines_cursor%FOUND LOOP

--DBMS_OUTPUT.PUT_LINE ('>>>>>>>>>>>> inside qp_list_lines_cursor loop list_line_id: '||l_lines_rec.list_line_id);


Qp_Number.canonical_mask :=
    '00999999999999999999999.99999999999999999999999999999999999999';    --Added for 2884567
    l_req_line_attrs_tbl.DELETE; /* Empty the plsql table for each list line */

    --Delete already existing rows from formula tmp table
    --DELETE FROM qp_preq_line_attrs_formula_tmp;
  --dbms_output.put_line('deleted rows from qp_preq_line_attrs_formula_tmp');

    FOR l_attributes_rec IN qp_pricing_attributes_cur(l_lines_rec.list_line_id)
    LOOP

      /* Get the Product Info from any one pricing attribute of a list line*/
      IF qp_pricing_attributes_cur%ROWCOUNT = 1 THEN

        --Insert the product information record into the temp table since
        --the formula processing code has been changed(bug 1806928) to look
        --into temp tables for factor processing due to performance reasons.

       -- IF l_attributes_rec.pricing_attribute_datatype = 'N' THEN
       -- bug2425851

          IF l_attributes_rec.product_attribute_datatype = 'N' THEN
          --Insert request line attrs with datatype = 'N'
          INSERT INTO qp_preq_line_attrs_formula_tmp
          (
           line_index,
           attribute_type,
           context,
           attribute,
           value_from,
           pricing_status_code
          )
          VALUES
          (
           0,
           'PRODUCT',
	   l_attributes_rec.product_attribute_context,
	   l_attributes_rec.product_attribute,
           Qp_Number.number_to_canonical(TO_NUMBER(l_attributes_rec.product_attr_value)),
           Qp_Preq_Grp.G_STATUS_UNCHANGED
          );


        --ELSIF l_attributes_rec.pricing_attribute_datatype IN ('X','Y','C') THEN
        -- bug 2425851

           ELSIF l_attributes_rec.product_attribute_datatype IN ('X','Y','C') THEN
          --Insert request line attrs with datatype 'X', 'Y', 'C'
          INSERT INTO qp_preq_line_attrs_formula_tmp
          (
           line_index,
           attribute_type,
           context,
           attribute,
           value_from,
           pricing_status_code
          )
          VALUES
          (
           0,
           'PRODUCT',
	   l_attributes_rec.product_attribute_context,
	   l_attributes_rec.product_attribute,
	   l_attributes_rec.product_attr_value,
           Qp_Preq_Grp.G_STATUS_UNCHANGED
          );

        END IF; --If datatype is 'N'

      END IF; --If cur%rowcount = 1

      --If pricing_attribute_context, pricing_attribute and
      --pricing_attr_value_from are not null, only then insert into plsql
      --table and temp table.
      IF l_attributes_rec.pricing_attribute_context IS NOT NULL AND
         l_attributes_rec.pricing_attribute IS NOT NULL AND
         l_attributes_rec.pricing_attr_value_from IS NOT NULL
      THEN

        --Insert the pricing attr info into the temp table since the formula
        --processing code has been changed(bug 1806928) to look into temp
        --tables for factor processing due to performance reasons.

        IF l_attributes_rec.pricing_attribute_datatype = 'N' THEN

          --Insert request line attrs with datatype = 'N'
          INSERT INTO qp_preq_line_attrs_formula_tmp
          (
           line_index,
           attribute_type,
           context,
           attribute,
           value_from,
           pricing_status_code
          )
          VALUES
          (
           0,
           'PRICING',
	   l_attributes_rec.pricing_attribute_context,
	   l_attributes_rec.pricing_attribute,
           Qp_Number.number_to_canonical(TO_NUMBER(l_attributes_rec.pricing_attr_value_from)),
           Qp_Preq_Grp.G_STATUS_UNCHANGED
          );


        ELSIF l_attributes_rec.pricing_attribute_datatype IN ('X','Y','C') THEN

          --Insert request line attrs with datatype 'X', 'Y', 'C'
          INSERT INTO qp_preq_line_attrs_formula_tmp
          (
           line_index,
           attribute_type,
           context,
           attribute,
           value_from,
           pricing_status_code
          )
          VALUES
          (
           0,
           'PRICING',
	   l_attributes_rec.pricing_attribute_context,
	   l_attributes_rec.pricing_attribute,
           l_attributes_rec.pricing_attr_value_from,
           Qp_Preq_Grp.G_STATUS_UNCHANGED
          );

        END IF; --If datatype is 'N'

      END IF; -- If pricing context, attribute and value_from are not null

    END LOOP; /* loop through l_attributes_rec */


    --Added 2 parameters p_line_index and p_list_line_type_code and removed
    --parameter p_req_line_attrs_tmp for Calculate function (POSCO Changes).
    --Added paramter p_modifier_value (mkarya bug 1906545 for Tropicana).

    l_list_price := Qp_Formula_Price_Calc_Pvt.Calculate(
                         p_price_formula_id => l_formulas_rec.price_formula_id,
		         p_list_price => l_lines_rec.operand,
                         p_price_effective_date => l_sysdate,
			 --p_req_line_attrs_tmp => l_req_line_attrs_tbl,
                         p_line_index => 0,
                         p_list_line_type_code => 'PLL',
	                 x_return_status => x_return_status,
                         p_modifier_value => NULL);
  --dbms_output.put_line('value returned by the formula calculation engine ' || l_list_price);

    --Delete the temp table records inserted above
    DELETE FROM qp_preq_line_attrs_formula_tmp;    -- no need since it is done at the beginning of processing each line
  --dbms_output.put_line('deleted rows from qp_preq_line_attrs_formula_tmp');

  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	l_error_message := Fnd_Message.GET;
        Fnd_File.put_line(Fnd_File.LOG,l_error_message);
  END IF;
-- Added negative price validation for 2483391

 IF Fnd_Profile.VALUE('QP_NEGATIVE_PRICING') = 'N' AND l_list_price < 0 THEN
	errbuf := Fnd_Message.GET_STRING('QP','SO_PR_NEGATIVE_LIST_PRICE');
	RAISE NEGATIVE_VALUE;
 ELSE

  l_price_rounding := Fnd_Profile.value('QP_PRICE_ROUNDING');  --Added for Enhancement 1732601
  IF l_price_rounding IS NOT NULL THEN

    BEGIN
      SELECT rounding_factor
      INTO   l_rounding_factor
      FROM   qp_list_headers_b
      WHERE  list_header_id = l_lines_rec.list_header_id;
    EXCEPTION
	 WHEN OTHERS THEN
	   l_rounding_factor := -2;
    END;

    l_list_price := ROUND(l_list_price, -1 * l_rounding_factor);


  END IF;

    UPDATE qp_list_lines
    SET    reprice_flag = NULL,
  	      request_id   = l_conc_request_id,
  	      program_application_id = l_conc_program_application_id,
	      program_id   = l_conc_program_id,
	      last_update_date  = l_sysdate,
	      last_update_login = l_conc_login_id,
	      operand      = l_list_price
    WHERE list_line_id = l_lines_rec.list_line_id;
  --dbms_output.put_line('updated qp_list_lines ');
 END IF;
	-- further fix 4090315 retrieve the next row,
	-- the %found condition will be checked bfe the loop continues again
	FETCH qp_list_lines_cursor INTO l_lines_rec;
  END LOOP; /* loop through lines cur */
  CLOSE qp_list_lines_cursor; -- further fix 4090315

END LOOP; /* loop through formulas cur */

--Change mask back to flexible mask.
Qp_Number.canonical_mask :=
    'FM999999999999999999999.9999999999999999999999999999999999999999';

COMMIT;

errbuf := '';
retcode := 0;

EXCEPTION
  WHEN NEGATIVE_VALUE THEN
    Fnd_File.put_line(Fnd_File.LOG,errbuf);
    retcode := 2;


  WHEN OTHERS THEN
    Fnd_File.put_line(Fnd_File.LOG, SUBSTR(SQLERRM, 1, 300));
    retcode := 2;

END Update_Formula_Price;

END Qp_Update_Formulaprice_Pvt;

/
