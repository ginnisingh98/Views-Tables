--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_QUALIFIERS" AS
/* $Header: QPXLQPQB.pls 120.2.12010000.2 2009/04/28 17:07:10 dnema ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Qualifiers';

/*
   Function added for bug8359572.
   It will return true if a qualifier already exist at the same level, having same context,
   attribute, comparison operator, value from and value to as the input qualifier.
*/

Function Check_Duplicate_Qualifier (
  p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
  )
RETURN BOOLEAN
IS
l_count                       NUMBER := 0;
BEGIN

   IF p_QUALIFIERS_rec.qualifier_rule_id <> FND_API.G_MISS_NUM
     OR p_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL
   THEN
       SELECT 1 INTO l_count
       FROM DUAL
       WHERE EXISTS( SELECT qualifier_id
                     FROM qp_qualifiers
                     WHERE qualifier_rule_id = p_QUALIFIERS_rec.qualifier_rule_id
                       AND qualifier_grouping_no = p_QUALIFIERS_rec.qualifier_grouping_no
          	       AND qualifier_context = p_QUALIFIERS_rec.qualifier_context
		       AND qualifier_attribute = p_QUALIFIERS_rec.qualifier_attribute
		       AND qualifier_attr_value = p_QUALIFIERS_rec.qualifier_attr_value
		       AND COMPARISON_OPERATOR_CODE = p_QUALIFIERS_rec.comparison_operator_code
		       AND nvl(QUALIFIER_ATTR_VALUE_TO,FND_API.G_MISS_NUM) =
		                    nvl(p_QUALIFIERS_rec.qualifier_attr_value_to,FND_API.G_MISS_NUM)
		       AND qualifier_id <> p_QUALIFIERS_rec.qualifier_id );
   ELSE
      SELECT 1 INTO l_count
      FROM DUAL
      WHERE EXISTS ( SELECT qualifier_id
                     FROM qp_qualifiers
                     WHERE list_header_id = p_QUALIFIERS_rec.list_header_id
                        AND qualifier_grouping_no = p_QUALIFIERS_rec.qualifier_grouping_no
            	        AND qualifier_context = p_QUALIFIERS_rec.qualifier_context
                        AND qualifier_attribute =  p_QUALIFIERS_rec.qualifier_attribute
	                AND qualifier_attr_value = p_QUALIFIERS_rec.qualifier_attr_value
                        AND COMPARISON_OPERATOR_CODE = p_QUALIFIERS_rec.comparison_operator_code
                        AND nvl(QUALIFIER_ATTR_VALUE_TO,FND_API.G_MISS_NUM) =
			        nvl(p_QUALIFIERS_rec.qualifier_attr_value_to,FND_API.G_MISS_NUM)
                        AND qualifier_rule_id is null
	                AND list_line_id = p_QUALIFIERS_rec.list_line_id
	                AND qualifier_id <> p_QUALIFIERS_rec.qualifier_id );
   END IF;

   RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

       RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Duplicate_Qualifier'
            );
        END IF;

	RAISE FND_API.G_EXC_ERROR;

END Check_Duplicate_Qualifier;


FUNCTION Check_Duplicate_Start_date(p_qualifier_grouping_no  IN number,
							p_start_date  IN  date,
							p_qualifier_rule_id  IN number,
							p_qualifier_id IN number)RETURN BOOLEAN IS
CURSOR c_QualifierStartDate(p_qualifier_grouping_no  number,
					   p_start_date    date,
                            p_qualifier_rule_id  number,
					   p_qualifier_id  number) is
         SELECT 'CHANGED'
	    FROM  QP_QUALIFIERS
	    WHERE  qualifier_rule_id     =    p_qualifier_rule_id
	    AND    qualifier_grouping_no =    p_qualifier_grouping_no
	    AND    start_date_active    <>   p_start_date
	    AND    qualifier_id         <>   p_qualifier_id;


l_status VARCHAR2(30);

BEGIN

         OPEN c_QualifierStartDate(p_qualifier_grouping_no,
							p_start_date,
							p_qualifier_rule_id,
							p_qualifier_id);
         FETCH c_QualifierStartDate INTO l_status;
	    CLOSE c_QualifierStartDate;

	    IF l_status = 'CHANGED' then

		  RETURN TRUE;

         ELSE

		  RETURN FALSE;

         End If;

END check_duplicate_start_date;


FUNCTION Check_Duplicate_End_Date(p_qualifier_grouping_no  IN number,
							p_end_date  IN  date,
							p_qualifier_rule_id  IN number,
							p_qualifier_id  IN number)RETURN BOOLEAN IS
CURSOR c_QualifierEndDate(p_qualifier_grouping_no  number,
					   p_end_date    date,
                            p_qualifier_rule_id  number,
					   p_qualifier_id number ) is
         SELECT 'CHANGED'
	    FROM  QP_QUALIFIERS
	    WHERE  qualifier_rule_id     =    p_qualifier_rule_id
	    AND    qualifier_grouping_no =    p_qualifier_grouping_no
	    AND    end_date_active    <>   p_end_date
	    AND    qualifier_id <> p_qualifier_id;


l_status VARCHAR2(30);

BEGIN

         OPEN c_QualifierEndDate(p_qualifier_grouping_no,
							p_end_date,
							p_qualifier_rule_id,
							p_qualifier_id);
         FETCH c_QualifierEndDate INTO l_status;
	    CLOSE c_QualifierEndDate;

	    IF l_status = 'CHANGED' then

		  RETURN TRUE;

         ELSE

		  RETURN FALSE;

         End If;

END check_duplicate_end_date;


--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_qualifier_id                NUMBER;
l_qualifier_rule_id           NUMBER;
l_comparison_operator_code    VARCHAR2(30);
l_error_code                  NUMBER;
l_precedence                   NUMBER;
l_datatype                    FND_FLEX_VALUE_SETS.Format_type%TYPE;
l_value_error                 VARCHAR2(1);
l_context_error               VARCHAR2(1);
l_attribute_error             VARCHAR2(1);
l_list_header_id              NUMBER;
l_list_line_id                NUMBER;
l_gsa_indicator               VARCHAR2(1);
l_customer_gsa_indicator      VARCHAR2(1);
l_list_type_code              VARCHAR2(30) := '';

l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

l_modifier_level_code         VARCHAR2(30);
l_segment_level               VARCHAR2(30);
x_attribute_code              VARCHAR2(80);
x_segment_name                VARCHAR2(30);

-- start 2091362
p_attr_count number;
p_product_attribute_context VARCHAR2(30);
p_product_attribute VARCHAR2(240);
p_product_attr_value VARCHAR2(240);
l_qp_status VARCHAR2(1);
l_start_date_active DATE;
l_end_date_active DATE;
l_list_header_id_1 NUMBER;
-- end bug2091362

BEGIN

    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_QUALIFIERS_rec.list_header_id,
                             p_list_line_id   => p_QUALIFIERS_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Check required attributes.


   --dbms_output.put_line('entity validation for qualifier id');
   oe_debug_pub.add('entity validation for qualifier id');
   oe_debug_pub.add('entity validation for qualifier id'||p_QUALIFIERS_rec.qualifier_id);




    IF  p_QUALIFIERS_rec.qualifier_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

   --dbms_output.put_line('entity validation for qualifier id status '|| l_return_status);
   oe_debug_pub.add('entity null validation for qualifier id status '|| l_return_status);
   --dbms_output.put_line('entity validation for qualifier grouping no');
   oe_debug_pub.add('entity validation for qualifier grouping no');




    --
    --  Check rest of required attributes here.
    --



    IF  p_QUALIFIERS_rec.qualifier_grouping_no IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_GROUPING_NO'));  -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

        END IF;

    END IF;


   --oe_debug_pub.add('entity  null validation for qualifier group id status '|| l_return_status);
--dbms_output.put_line('entity validation for qualifier group id status '|| l_return_status);

   --dbms_output.put_line('entity validation for qualifier attr_value');

   --oe_debug_pub.add('entity validation for attr_value with value as  '
	--				|| p_QUALIFIERS_rec.qualifier_attr_value);


    -- qualifier_attr_value can be null when the operator is
    --'Between'.This is to proivde 'less than ' functionality
    -- using 'between ' operator.
    --fix for the bug 1253121.

    IF  p_QUALIFIERS_rec.comparison_operator_code <> 'BETWEEN' AND
        p_QUALIFIERS_rec.qualifier_attr_value IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_ATTR_VALUE'));  -- Fix FOr Bug-1974413
            OE_MSG_PUB.Add;

        END IF;

    END IF;




   --dbms_output.put_line('entity validation for qualifier attr value  '|| l_return_status);
   oe_debug_pub.add('entity validation for qualifier attr value  '|| l_return_status);


   --dbms_output.put_line('entity validation for qualifier attribute');




    IF  p_QUALIFIERS_rec.qualifier_attribute IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Attribute');
            OE_MSG_PUB.Add;

        END IF;

    END IF;



    --dbms_output.put_line('entity validation for qualifier attr   '|| l_return_status);
    oe_debug_pub.add('entity  null validation for qualifier attr   '|| l_return_status);



   --dbms_output.put_line('entity validation for qualifier context');



   IF  p_QUALIFIERS_rec.qualifier_context IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_CONTEXT'));  -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    --dbms_output.put_line('entity  null validation for qualifier context   '|| l_return_status);
    oe_debug_pub.add('entity validation for qualifier context   '|| l_return_status);
   --dbms_output.put_line('entity validation for comparison operator ');




    IF  p_QUALIFIERS_rec.comparison_operator_code IS NULL

    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE'));  -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

        END IF;

    END IF;




   --dbms_output.put_line('entity validation for compari '|| l_return_status);
   oe_debug_pub.add('entity validation for compari '|| l_return_status);
   --dbms_output.put_line('entity validation for excluder flag operator ');

/* Added for bug2368511 */

    IF  p_QUALIFIERS_rec.list_line_id IS NULL

    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Line Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

   oe_debug_pub.add('entity validation for List Line Id '|| l_return_status);


    IF  p_QUALIFIERS_rec.excluder_flag IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('EXCLUDER_FLAG'));  -- FIx For Bug-1974413
            OE_MSG_PUB.Add;

        END IF;

    END IF;




   --dbms_output.put_line('entity validation for excluder '|| l_return_status);
   oe_debug_pub.add('entity validation for excluder '|| l_return_status);
    --  Return Error if a required attribute is missing.



    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    -- Check for duplicate qualifier bug8359572

    IF Check_Duplicate_Qualifier(p_QUALIFIERS_rec)
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_DUPL_QUAL_EXISTS');

            FND_MESSAGE.SET_TOKEN('CONTEXT',
               QP_UTIL.Get_Context('QP_ATTR_DEFNS_QUALIFIER',p_QUALIFIERS_rec.qualifier_context));

            QP_UTIL.Get_Attribute_Code('QP_ATTR_DEFNS_QUALIFIER',
                             p_QUALIFIERS_rec.qualifier_context,
                             p_QUALIFIERS_rec.qualifier_attribute,
                             x_attribute_code,
                             x_segment_name);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',x_attribute_code);
            FND_MESSAGE.SET_TOKEN('QUAL_GRPNG_NO',p_QUALIFIERS_rec.qualifier_grouping_no);

            OE_MSG_PUB.Add;

        END IF;
    END IF;

    -- Changes for bug 8359572 ends.

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --
     IF p_QUALIFIERS_rec.list_header_id IS NOT NULL
	THEN
	  BEGIN
         select list_type_code
	    into   l_list_type_code
	    from   qp_list_headers_b
	    where  list_header_id = p_QUALIFIERS_rec.list_header_id;
       EXCEPTION
         WHEN OTHERS THEN
	      l_list_type_code := '';
	  END;
     END IF;

     IF p_QUALIFIERS_rec.qualifier_context = 'VOLUME' AND
	   p_QUALIFIERS_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE10'  AND
	   l_list_type_code in ('PRL', 'AGR')
	   -- Qualifier Attr 'Order Amount' under the 'Volume' Qualfier context
	THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier Attribute');
           OE_MSG_PUB.Add;
         END IF;
	END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    --  Validate start_date active and end_date active
	   --end date active must be greater than start date active

   --dbms_output.put_line('entity validation for start-date ');



        /*IF nvl(p_QUALIFIERS_rec.end_date_active,
			  TO_DATE('01-01-1999','MM-DD-YYYY')) <
           nvl(p_QUALIFIERS_rec.start_date_active,
			  TO_DATE('01-01-1955','MM-DD-YYYY'))*/
        IF nvl(p_QUALIFIERS_rec.end_date_active,
			p_QUALIFIERS_rec.start_date_active ) <
           nvl(p_QUALIFIERS_rec.start_date_active,
			  p_QUALIFIERS_rec.end_date_active)
        THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

             FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
             --FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Start Date active');
             OE_MSG_PUB.Add;

           END IF;

        END IF;


   --dbms_output.put_line('entity validation for start_date '||l_return_status);
   oe_debug_pub.add('entity validation for start_date '||l_return_status);
   --dbms_output.put_line('entity validation for value to ');



    --Validate Qualifier_attr_value_to and Qualifier_attr_value
      -- if comparison operator code is BETWEEN then both
	 --qualifier attr_value _to or qualifier_attr_value are required
	 -- for all other operators ,qualifier_attr_value_to  must be null.

      IF UPPER(p_QUALIFIERS_rec.comparison_operator_code) = 'BETWEEN' AND
		    (p_QUALIFIERS_rec.qualifier_attr_value_to IS NULL OR
		     p_QUALIFIERS_rec.qualifier_attr_value IS NULL)
      THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

             FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_ATTR_VALUE_TO')||'/'||
                                            QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_ATTR_VALUE'));   -- Fix For Bug-1974413
             OE_MSG_PUB.Add;

           END IF;

      END IF;


   --validation for canonical form for value to

     l_error_code:=QP_UTIL.validate_num_date(p_QUALIFIERS_rec.qualifier_datatype,
								     p_QUALIFIERS_rec.qualifier_attr_value_to);
	IF l_error_code  <> 0  THEN

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To ');
               OE_MSG_PUB.Add;
            END IF;

     END IF;

   -- End of validation for canonical form on value to



   --dbms_output.put_line('entity validation for value to '||l_return_status);
   oe_debug_pub.add('entity validation for value to '||l_return_status);



    --Other Validations


    --validate for start_date active to the same within a group for a qualifier rule id

      If Check_Duplicate_start_date(p_QUALIFIERS_rec.qualifier_grouping_no,
							 p_QUALIFIERS_rec.start_date_active,
							 p_QUALIFIERS_rec.qualifier_rule_id,
							 p_QUALIFIERS_rec.qualifier_id) THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    Then
              FND_MESSAGE.SET_NAME('QP','QP_DATE_WITHIN_GRPNO_REQ_SAME');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Start Date Active');
		    OE_MSG_PUB.Add;
         END IF;
	  END IF;


      If Check_Duplicate_end_date(p_QUALIFIERS_rec.qualifier_grouping_no,
							 p_QUALIFIERS_rec.end_date_active,
							 p_QUALIFIERS_rec.qualifier_rule_id,
							 p_QUALIFIERS_rec.qualifier_id) THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	    Then
              FND_MESSAGE.SET_NAME('QP','QP_DATE_WITHIN_GRPNO_REQ_SAME');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'End Date Active');
		    OE_MSG_PUB.Add;
         END IF;
	  END IF;

















    --Validate Qualifier Id for duplicate values.


   --dbms_output.put_line('entity validation for duplicate id' ||p_QUALIFIERS_rec.qualifier_id);



     /* SELECT  qualifier_id
      INTO    l_qualifier_id
	 FROM    QP_QUALIFIERS
      WHERE   qualifier_id = p_QUALIFIERS_rec.qualifier_id;

   If  SQL%NOTFOUND
	 Then
            null;
   Else
		  l_return_status := FND_API.G_RET_STS_ERROR;
        --dbms_output.put_line('entity validation for duplicaet id '||l_return_status);

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
              -- FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier Id');
               OE_MSG_PUB.Add;
            END IF;

   End If;*/

   --dbms_output.put_line('entity validation for duplicaet id '||l_return_status);
   oe_debug_pub.add('entity validation for duplicaet id '||l_return_status);




     --Validate Comparison Operator Code for Valid Values.

     --dbms_output.put_line('entity validation for compar 2 ');



      SELECT  lookup_code
	 INTO    l_comparison_operator_code
	 FROM    QP_LOOKUPS
      WHERE   LOOKUP_TYPE = 'COMPARISON_OPERATOR'
	 AND     LOOKUP_CODE = UPPER(p_QUALIFIERS_rec.comparison_operator_code);

      If SQL%NOTFOUND
	 Then

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE'));  -- Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;

       End If;


    --dbms_output.put_line('entity validation for compa2 '||l_return_status);
    oe_debug_pub.add('entity validation for compa2 '||l_return_status);



     --Validate Qualifier_Context , Qualifier_attribute ,Qualifier_Attr Value
	--qualifier_datatype,qualifier_precedence


      --dbms_output.put_line('for context ,attribute,value,datatype,precedence');

 if  (p_QUALIFIERS_rec.qualifier_datatype = 'X'  and  p_QUALIFIERS_rec.comparison_operator_code = 'BETWEEN'  )  THEN

  IF  fnd_date.canonical_to_date(p_QUALIFIERS_rec.qualifier_attr_value_to) <
                          fnd_date.canonical_to_date(p_QUALIFIERS_rec.qualifier_attr_value)
        THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;

                     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                            FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
                           OE_MSG_PUB.Add;

                     END IF;

   END IF;

END IF;

       QP_UTIL.validate_qp_flexfield(flexfield_name       =>'QP_ATTR_DEFNS_QUALIFIER'
						 ,context                   =>p_QUALIFIERS_rec.qualifier_context
						 ,attribute                 =>p_QUALIFIERS_rec.qualifier_attribute
						 ,value                =>p_QUALIFIERS_rec.qualifier_attr_value
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_error
						 ,attribute_flag                 =>l_attribute_error
						 ,value_flag                     =>l_value_error
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

       If (l_context_error = 'N'  AND l_error_code = 7)       --  invalid context
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_CONTEXT'));  -- Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;

       End If;


       --dbms_output.put_line('for context '||l_return_status);

        --dbms_output.put_line('for context ,attribute,value,datatype,precedence');



       If l_attribute_error = 'N'   AND l_error_code = 8    --  invalid Attribute
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Attribute');
               OE_MSG_PUB.Add;
            END IF;

       End If;


       --dbms_output.put_line('for attributr '||l_return_status);
       oe_debug_pub.add('for context '||l_return_status);


      --- validate qualifier_attr_value only if comparison operator is
	 --  '='

       IF p_QUALIFIERS_rec.comparison_operator_code = '=' Then

       If l_value_error = 'N'  AND l_error_code = 9      --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Value From ');
               --OE_MSG_PUB.Add;
               OE_MSG_PUB.Add;
            END IF;
       End If;
       END IF;

      --- Validation for GSA Discounts - Customer must be GSA

       IF  p_QUALIFIERS_rec.qualifier_context = 'CUSTOMER'
       AND p_QUALIFIERS_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE2'
       AND p_QUALIFIERS_rec.list_header_id IS NOT NULL
	  THEN

		oe_debug_pub.add('attcching');
          BEGIN

  	       select gsa_indicator
	       into   l_gsa_indicator
	       from   qp_list_headers_b
	       where  list_header_id = p_QUALIFIERS_rec.list_header_id;

		  IF nvl(l_gsa_indicator,'N') = 'Y'
		  THEN

		oe_debug_pub.add('GSA = Y');
  	          select decode(party.party_type,'ORGANIZATION',party.gsa_indicator_flag,'N')
	          into   l_customer_gsa_indicator
	          from   hz_cust_accounts cust_acct,hz_parties party
	          where  cust_acct.party_id = party.party_id and
                    cust_acct.cust_account_id = to_number(p_QUALIFIERS_rec.qualifier_attr_value);

               IF SQL%NOTFOUND
			THEN

		oe_debug_pub.add('customer GSA not found');
		         l_return_status := FND_API.G_RET_STS_ERROR;

                   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN

                      FND_MESSAGE.SET_NAME('QP','QP_INVALID_GSA_CUSTOMER');
                      OE_MSG_PUB.Add;

                   END IF;

               ELSIF nvl(l_customer_gsa_indicator,'N') <> 'Y'
			THEN

		oe_debug_pub.add('customer GSA = '||l_customer_gsa_indicator);
		         l_return_status := FND_API.G_RET_STS_ERROR;

                   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN

                      FND_MESSAGE.SET_NAME('QP','QP_INVALID_GSA_CUSTOMER');
                      OE_MSG_PUB.Add;

                   END IF;

		     END IF;

		   END IF;

          EXCEPTION
	       when no_data_found then
		oe_debug_pub.add('exception GSA indicator in header is null');
	       null;

          END;

	   END IF;

       --dbms_output.put_line('for value,'||l_return_status);
       oe_debug_pub.add('for value,'||l_return_status);

      --dbms_output.put_line('org precede '||p_QUALIFIERS_rec.qualifier_precedence);
      --dbms_output.put_line('n precede '||l_precedence);
        oe_debug_pub.add('org precede '||p_QUALIFIERS_rec.qualifier_precedence);
        oe_debug_pub.add('n precede '||l_precedence);

       /*If p_QUALIFIERS_rec.qualifier_precedence <>  l_precedence  ---  invalid  precedence
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               --FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('QUALIFIER_PRECEDENCE'));  -- Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;


       End If;*/



        --dbms_output.put_line('for precedence'||l_return_status);



       If p_QUALIFIERS_rec.qualifier_datatype <> l_datatype   ---  invalid qualifier datatype
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               --FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier Datatype ');
               OE_MSG_PUB.Add;
            END IF;

       End If;



       --dbms_output.put_line('for datatype,'||l_return_status);
        oe_debug_pub.add('qualifier datatype,'||l_return_status);



   --validation for canonical form

     l_error_code:=QP_UTIL.validate_num_date(p_QUALIFIERS_rec.qualifier_datatype,
								     p_QUALIFIERS_rec.qualifier_attr_value);
	IF l_error_code  <> 0  THEN

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From ');
               OE_MSG_PUB.Add;
            END IF;

     END IF;
     --dbms_output.put_line('for cano of value from ,'||l_return_status);

   -- End of validation for canonical form on value from


    --  Validate qualifier rule id when not null



       /* IF p_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL
	   THEN
             SELECT    qualifier_rule_id
	        INTO      l_qualifier_rule_id
	        FROM      QP_QUALIFIER_RULES
	        WHERE     qualifier_rule_id = p_QUALIFIERS_rec.qualifier_rule_id;

             If  SQL%NOTFOUND
             Then
		          l_return_status := FND_API.G_RET_STS_ERROR;

                    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                      -- FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier qualifier rule id ');
                       OE_MSG_PUB.Add;
                    END IF;
             End If;
         END IF;*/




    --  Validate created from rule id when not null

  /*      IF p_QUALIFIERS_rec.created_from_rule_id IS NOT NULL
	   THEN
             SELECT    qualifier_rule_id
	        INTO      l_qualifier_rule_id
	        FROM      QP_QUALIFIER_RULES
	        WHERE     qualifier_rule_id = p_QUALIFIERS_rec.created_from_rule_id;

             If  SQL%NOTFOUND
             Then
		          l_return_status := FND_API.G_RET_STS_ERROR;

                    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                       --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created from  rule id ');
                       OE_MSG_PUB.Add;
                    END IF;
             End If;
         END IF;*/



    --  Validate list header  id when not null

   /*     IF p_QUALIFIERS_rec.list_header_id IS NOT NULL
	   THEN
             SELECT    list_header_id
	        INTO      l_list_header_id
	        FROM      QP_LIST_HEADERS_B
	        WHERE     list_header_id = p_QUALIFIERS_rec.list_header_id;

             If  SQL%NOTFOUND
             Then
		          l_return_status := FND_API.G_RET_STS_ERROR;

                    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                       --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Header id ');
                       OE_MSG_PUB.Add;
                    END IF;
             End If;
         END IF;  */



    --  Validate list line  id when not null

/*        IF p_QUALIFIERS_rec.list_line_id IS NOT NULL
	   THEN
             SELECT    list_line_id
	        INTO      l_list_line_id
	        FROM      QP_LIST_LINES
	        WHERE     list_line_id = p_QUALIFIERS_rec.list_line_id;

             If  SQL%NOTFOUND
             Then
		          l_return_status := FND_API.G_RET_STS_ERROR;

                    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
                       FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                       --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
                       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Line id ');
                       OE_MSG_PUB.Add;
                    END IF;
             End If;
         END IF;  */


    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

--- start bug2091362
l_qp_status := QP_UTIL.GET_QP_STATUS;

IF (fnd_profile.value('QP_ALLOW_DUPLICATE_MODIFIERS') <> 'Y'
    and p_qualifiers_rec.list_line_id <> -1
    and l_qp_status = 'S') THEN

select start_date_active, end_date_active , list_header_id
into l_start_date_active, l_end_date_active, l_list_header_id_1
from qp_list_lines
where list_line_id = p_qualifiers_rec.list_line_id;

   OE_Debug_Pub.add ( 'Value Set 1' || l_start_date_active || l_end_date_active );

--   oe_debug_pub.add('about to delete a request to check duplicate modifier list lines without product attribute');

QP_delayed_requests_pvt.Delete_Request
(   p_entity_code => QP_GLOBALS.G_ENTITY_ALL
,   p_entity_id    =>  p_qualifiers_rec.list_line_id
,   p_request_Type =>  QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

/* After deleting request if any log a new request to check duplicate modifier list lines with product attribute */

   oe_debug_pub.add('about to log a request to check duplicate modifier list lines with product attribute');

select count(*) into p_attr_count
from qp_pricing_attributes
where list_line_id = p_qualifiers_rec.list_line_id;

 IF p_attr_count = 0 THEN

    QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> p_qualifiers_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_ALL
,   p_requesting_entity_id	=> p_qualifiers_rec.list_line_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   p_param1			=> l_list_header_id_1
,   p_param2			=> fnd_date.date_to_canonical(l_start_date_active)		--2752265
,   p_param3			=> fnd_date.date_to_canonical(l_end_date_active)		--2752265
,   p_param4            => NULL
,   p_param5            => NULL
,   p_param6            => NULL
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

 ELSE

 Select product_attribute_context, product_attribute, product_attr_value
 into p_product_attribute_context, p_product_attribute, p_product_attr_value
 from qp_pricing_attributes
 where list_line_id =  p_qualifiers_rec.list_line_id
 and rownum < 2;

       QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> p_qualifiers_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_ALL
,   p_requesting_entity_id	=> p_qualifiers_rec.list_line_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   p_param1			=> l_list_header_id_1
,   p_param2			=> fnd_date.date_to_canonical(l_start_date_active)		--2752265
,   p_param3			=> fnd_date.date_to_canonical(l_end_date_active)		--2752265
,   p_param4            => p_product_attribute_context
,   p_param5            => p_product_attribute
,   p_param6            => p_product_attr_value
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request for duplicate modifiers');

        RAISE FND_API.G_EXC_ERROR;

    END IF;
 END IF;
  oe_debug_pub.add('after logging delayed request from qualfiers ');
END IF;



  --- end bug2091362


    --Raise a warning if the Qualifier Attribute being used in setup
    --has a sourcing method of 'ATTRIBUTE MAPPING' but is not sourcing-enabled
    --or if its sourcing_status is not 'Y', i.e., the build sourcing conc.
    --program has to be run.

  IF qp_util.attrmgr_installed = 'Y' THEN

    IF p_Qualifiers_rec.qualifier_context IS NOT NULL AND
       p_Qualifiers_rec.qualifier_attribute IS NOT NULL
    THEN
      QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_QUALIFIER',
                               p_Qualifiers_rec.qualifier_context,
                               l_context_type,
                               l_error_code);

      IF l_error_code = 0 THEN --successfully returned context_type

        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Qualifiers_rec.qualifier_context,
                                  p_Qualifiers_rec.qualifier_attribute,
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

          IF l_sourcing_enabled <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Qualifiers_rec.qualifier_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Qualifiers_rec.qualifier_attribute);
            OE_MSG_PUB.Add;

          END IF;

          IF l_sourcing_status <> 'Y' THEN

            IF NOT (
               p_qualifiers_rec.qualifier_context= 'MODLIST' AND
               p_qualifiers_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE10')
            THEN
              FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
              FND_MESSAGE.SET_TOKEN('CONTEXT',
                                    p_Qualifiers_rec.qualifier_context);
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                    p_Qualifiers_rec.qualifier_attribute);
              OE_MSG_PUB.Add;
            END IF;

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

      END IF; --l_error_code = 0

    END IF;--If qualifier_context and qualifier_attribute are NOT NULL

    -- Giri, validate that qualifiers attached to Price Lists are or type LINE/BOTH
    IF p_qualifiers_rec.list_header_id is not null and
       l_list_type_code in ('PRL', 'AGR') THEN
       IF p_Qualifiers_rec.qualifier_context IS NOT NULL AND
          p_Qualifiers_rec.qualifier_attribute IS NOT NULL THEN
          l_segment_level := qp_util.get_segment_level(p_qualifiers_rec.list_header_id
                                                      ,p_Qualifiers_rec.qualifier_context
                                                      ,p_Qualifiers_rec.qualifier_attribute
                                                      );
          IF l_segment_level = 'ORDER' THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                qp_util. Get_Attribute_Code(p_FlexField_Name => 'QP_ATTR_DEFNS_QUALIFIER',
                         p_Context_Name      =>  p_Qualifiers_rec.qualifier_context,
                         p_attribute         =>  p_Qualifiers_rec.qualifier_attribute,
                         x_attribute_code    =>  x_attribute_code,
                         x_segment_name      =>  x_segment_name);
                 -- The level of attribute (?) ? is not compatible for Price Lists
                 FND_MESSAGE.SET_NAME('QP','QP_SEGMENT_NOT_ALLOWED_FOR_PL');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE', x_attribute_code);
                 FND_MESSAGE.SET_TOKEN('SEGMENT_LEVEL', l_segment_level);
                 OE_MSG_PUB.Add;
             END IF;
          END IF;
       END IF;
    END IF;

    -- mkarya, validate that line level qualifiers attached to modifier match the modifier level
    -- Changes for attribute manager

      if p_qualifiers_rec.list_header_id is not null and
         p_qualifiers_rec.list_line_id <> -1 and
         l_list_type_code not in ('PRL', 'AGR') then

           IF p_Qualifiers_rec.qualifier_context IS NOT NULL AND
              p_Qualifiers_rec.qualifier_attribute IS NOT NULL
           THEN
              select modifier_level_code
                into l_modifier_level_code
                from qp_list_lines
               where list_header_id = p_qualifiers_rec.list_header_id
                 and list_line_id = p_qualifiers_rec.list_line_id;

              l_segment_level := qp_util.get_segment_level(p_qualifiers_rec.list_header_id
                                                           ,p_Qualifiers_rec.qualifier_context
                                                           ,p_Qualifiers_rec.qualifier_attribute
                                                           );
              if ((l_modifier_level_code in ('LINE', 'LINEGROUP') and l_segment_level = 'ORDER')
                   OR
                  (l_modifier_level_code = 'ORDER' and l_segment_level = 'LINE')) then

		l_return_status := FND_API.G_RET_STS_ERROR;
                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    qp_util. Get_Attribute_Code(p_FlexField_Name => 'QP_ATTR_DEFNS_QUALIFIER',
                             p_Context_Name      =>  p_Qualifiers_rec.qualifier_context,
                             p_attribute         =>  p_Qualifiers_rec.qualifier_attribute,
                             x_attribute_code    =>  x_attribute_code,
                             x_segment_name      =>  x_segment_name);
                    -- The level of attribute (?) ? is not compatible with modifier level ?.
                    FND_MESSAGE.SET_NAME('QP','QP_SEGMENT_NOT_ALLOWED');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', x_attribute_code);
                    FND_MESSAGE.SET_TOKEN('SEGMENT_LEVEL', l_segment_level);
                    FND_MESSAGE.SET_TOKEN('MODIFIER_LEVEL', l_modifier_level_code);
                    OE_MSG_PUB.Add;
                END IF; -- check_msg_level

              end if; -- compare modifier_level and segment_level

           END IF;--If qualifier_context and qualifier_attribute are NOT NULL

      end if; -- if line level qualifier attached to modifier

  END IF; -- attribute manager installed

    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate QUALIFIERS attributes


    --dbms_output.put_line('comparison operator');
    --dbms_output.put_line('comparison operators is '||nvl(p_QUALIFIERS_rec.comparison_operator_code,'c'));


    IF  p_QUALIFIERS_rec.comparison_operator_code IS NOT NULL AND
        (   p_QUALIFIERS_rec.comparison_operator_code <>
            p_old_QUALIFIERS_rec.comparison_operator_code OR
            p_old_QUALIFIERS_rec.comparison_operator_code IS NULL )
    THEN

    --dbms_output.put_line(' inside if not null comparison operator');
        IF NOT QP_Validate.Comparison_Operator(p_QUALIFIERS_rec.comparison_operator_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('comparison status is '||x_return_status);


    --dbms_output.put_line('created_by ');

    IF  p_QUALIFIERS_rec.created_by IS NOT NULL AND
        (   p_QUALIFIERS_rec.created_by <>
            p_old_QUALIFIERS_rec.created_by OR
            p_old_QUALIFIERS_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_QUALIFIERS_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('create from rule ');

    IF  p_QUALIFIERS_rec.created_from_rule_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.created_from_rule_id <>
            p_old_QUALIFIERS_rec.created_from_rule_id OR
            p_old_QUALIFIERS_rec.created_from_rule_id IS NULL )
    THEN
        IF NOT QP_Validate.Created_From_Rule(p_QUALIFIERS_rec.created_from_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --dbms_output.put_line(' created from status is '||x_return_status);



    --dbms_output.put_line('validating creation date');

    IF  p_QUALIFIERS_rec.creation_date IS NOT NULL AND
        (   p_QUALIFIERS_rec.creation_date <>
            p_old_QUALIFIERS_rec.creation_date OR
            p_old_QUALIFIERS_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_QUALIFIERS_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating end date');

    IF  p_QUALIFIERS_rec.end_date_active IS NOT NULL AND
        (   p_QUALIFIERS_rec.end_date_active <>
            p_old_QUALIFIERS_rec.end_date_active OR
            p_old_QUALIFIERS_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_QUALIFIERS_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('end adate status is '||x_return_status);



    --dbms_output.put_line('validating excluder flag ');

    IF  p_QUALIFIERS_rec.excluder_flag IS NOT NULL AND
        (   p_QUALIFIERS_rec.excluder_flag <>
            p_old_QUALIFIERS_rec.excluder_flag OR
            p_old_QUALIFIERS_rec.excluder_flag IS NULL )
    THEN
        IF NOT QP_Validate.Excluder(p_QUALIFIERS_rec.excluder_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' excluder flag status is '||x_return_status);



    --dbms_output.put_line('validating lat_updated by ');

    IF  p_QUALIFIERS_rec.last_updated_by IS NOT NULL AND
        (   p_QUALIFIERS_rec.last_updated_by <>
            p_old_QUALIFIERS_rec.last_updated_by OR
            p_old_QUALIFIERS_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_QUALIFIERS_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating lat_update date ');

    IF  p_QUALIFIERS_rec.last_update_date IS NOT NULL AND
        (   p_QUALIFIERS_rec.last_update_date <>
            p_old_QUALIFIERS_rec.last_update_date OR
            p_old_QUALIFIERS_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_QUALIFIERS_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating lat_update login ');

    IF  p_QUALIFIERS_rec.last_update_login IS NOT NULL AND
        (   p_QUALIFIERS_rec.last_update_login <>
            p_old_QUALIFIERS_rec.last_update_login OR
            p_old_QUALIFIERS_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_QUALIFIERS_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating list_header_id ');

    IF  p_QUALIFIERS_rec.list_header_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.list_header_id <>
            p_old_QUALIFIERS_rec.list_header_id OR
            p_old_QUALIFIERS_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_QUALIFIERS_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating list_line id  ');

    IF  p_QUALIFIERS_rec.list_line_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.list_line_id <>
            p_old_QUALIFIERS_rec.list_line_id OR
            p_old_QUALIFIERS_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_QUALIFIERS_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);




    --dbms_output.put_line('validating program application id  ');

    IF  p_QUALIFIERS_rec.program_application_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.program_application_id <>
            p_old_QUALIFIERS_rec.program_application_id OR
            p_old_QUALIFIERS_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_QUALIFIERS_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);




    --dbms_output.put_line('validating program  id  ');

    IF  p_QUALIFIERS_rec.program_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.program_id <>
            p_old_QUALIFIERS_rec.program_id OR
            p_old_QUALIFIERS_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_QUALIFIERS_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating update date  ');

    IF  p_QUALIFIERS_rec.program_update_date IS NOT NULL AND
        (   p_QUALIFIERS_rec.program_update_date <>
            p_old_QUALIFIERS_rec.program_update_date OR
            p_old_QUALIFIERS_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_QUALIFIERS_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating qualifier_attribute  ');

    IF  p_QUALIFIERS_rec.qualifier_attribute IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_attribute <>
            p_old_QUALIFIERS_rec.qualifier_attribute OR
            p_old_QUALIFIERS_rec.qualifier_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Attribute(p_QUALIFIERS_rec.qualifier_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' attribute status is '||x_return_status);



    --dbms_output.put_line('validating qualifier_attribute val ');

    IF  p_QUALIFIERS_rec.qualifier_attr_value IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_attr_value <>
            p_old_QUALIFIERS_rec.qualifier_attr_value OR
            p_old_QUALIFIERS_rec.qualifier_attr_value IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Attr_Value(p_QUALIFIERS_rec.qualifier_attr_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' attr value status is '||x_return_status);



    --dbms_output.put_line('validating qualifier_attribute valto  ');

    IF  p_QUALIFIERS_rec.qualifier_attr_value_to IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_attr_value_to <>
            p_old_QUALIFIERS_rec.qualifier_attr_value_to OR
            p_old_QUALIFIERS_rec.qualifier_attr_value_to IS NULL )
    THEN
       IF NOT QP_Validate.Qualifier_Attr_Value_to(p_QUALIFIERS_rec.qualifier_attr_value_to) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' attr_value to status is '||x_return_status);




    --dbms_output.put_line('validating qualifier_context  ');

    IF  p_QUALIFIERS_rec.qualifier_context IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_context <>
            p_old_QUALIFIERS_rec.qualifier_context OR
            p_old_QUALIFIERS_rec.qualifier_context IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Context(p_QUALIFIERS_rec.qualifier_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' context status is '||x_return_status);



    --dbms_output.put_line('validating qualifier_datatype  ');

    IF  p_QUALIFIERS_rec.qualifier_datatype IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_datatype <>
            p_old_QUALIFIERS_rec.qualifier_datatype OR
            p_old_QUALIFIERS_rec.qualifier_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Datatype(p_QUALIFIERS_rec.qualifier_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' data type status is '||x_return_status);

    /*IF  p_QUALIFIERS_rec.qualifier_date_format IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_date_format <>
            p_old_QUALIFIERS_rec.qualifier_date_format OR
            p_old_QUALIFIERS_rec.qualifier_date_format IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Date_Format(p_QUALIFIERS_rec.qualifier_date_format) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;*/




    --dbms_output.put_line('validating qualifier_gruouping  ');



    IF  p_QUALIFIERS_rec.qualifier_grouping_no <> -1 AND
        (   p_QUALIFIERS_rec.qualifier_grouping_no <>
            p_old_QUALIFIERS_rec.qualifier_grouping_no OR
            p_old_QUALIFIERS_rec.qualifier_grouping_no = -1 )
    THEN
        IF NOT QP_Validate.Qualifier_Grouping_No(p_QUALIFIERS_rec.qualifier_grouping_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' gropuing status is '||x_return_status);



    --dbms_output.put_line('validating qualifier_id  ');

    IF  p_QUALIFIERS_rec.qualifier_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_id <>
            p_old_QUALIFIERS_rec.qualifier_id OR
            p_old_QUALIFIERS_rec.qualifier_id IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier(p_QUALIFIERS_rec.qualifier_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' qualiifer id status is '||x_return_status);




    /*IF  p_QUALIFIERS_rec.qualifier_number_format IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_number_format <>
            p_old_QUALIFIERS_rec.qualifier_number_format OR
            p_old_QUALIFIERS_rec.qualifier_number_format IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Number_Format(p_QUALIFIERS_rec.qualifier_number_format) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;*/



    --dbms_output.put_line('validating qualifier_precedence  ');

    IF  p_QUALIFIERS_rec.qualifier_precedence IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_precedence <>
            p_old_QUALIFIERS_rec.qualifier_precedence OR
            p_old_QUALIFIERS_rec.qualifier_precedence IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Precedence(p_QUALIFIERS_rec.qualifier_precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' precedence status is '||x_return_status);




    --dbms_output.put_line('validating qualifier rule id  ');



    IF  p_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualifier_rule_id <>
            p_old_QUALIFIERS_rec.qualifier_rule_id OR
            p_old_QUALIFIERS_rec.qualifier_rule_id IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Rule(p_QUALIFIERS_rec.qualifier_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line(' qualifier rule  id status is '||x_return_status);


    --dbms_output.put_line('validating request id  ');

    IF  p_QUALIFIERS_rec.request_id IS NOT NULL AND
        (   p_QUALIFIERS_rec.request_id <>
            p_old_QUALIFIERS_rec.request_id OR
            p_old_QUALIFIERS_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_QUALIFIERS_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating date active   ');

    IF  p_QUALIFIERS_rec.start_date_active IS NOT NULL AND
        (   p_QUALIFIERS_rec.start_date_active <>
            p_old_QUALIFIERS_rec.start_date_active OR
            p_old_QUALIFIERS_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_QUALIFIERS_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    --dbms_output.put_line('status is '||x_return_status);
-- Added for TCA
    IF  p_QUALIFIERS_rec.qualify_hier_descendent_flag IS NOT NULL AND
        (   p_QUALIFIERS_rec.qualify_hier_descendent_flag <>
            p_old_QUALIFIERS_rec.qualify_hier_descendent_flag OR
            p_old_QUALIFIERS_rec.qualify_hier_descendent_flag IS NULL )
    THEN
        IF NOT QP_Validate.Qualify_Hier_Descendent_Flag(p_QUALIFIERS_rec.qualify_hier_descendent_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  (p_QUALIFIERS_rec.attribute1 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute1 <>
            p_old_QUALIFIERS_rec.attribute1 OR
            p_old_QUALIFIERS_rec.attribute1 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute10 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute10 <>
            p_old_QUALIFIERS_rec.attribute10 OR
            p_old_QUALIFIERS_rec.attribute10 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute11 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute11 <>
            p_old_QUALIFIERS_rec.attribute11 OR
            p_old_QUALIFIERS_rec.attribute11 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute12 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute12 <>
            p_old_QUALIFIERS_rec.attribute12 OR
            p_old_QUALIFIERS_rec.attribute12 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute13 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute13 <>
            p_old_QUALIFIERS_rec.attribute13 OR
            p_old_QUALIFIERS_rec.attribute13 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute14 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute14 <>
            p_old_QUALIFIERS_rec.attribute14 OR
            p_old_QUALIFIERS_rec.attribute14 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute15 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute15 <>
            p_old_QUALIFIERS_rec.attribute15 OR
            p_old_QUALIFIERS_rec.attribute15 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute2 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute2 <>
            p_old_QUALIFIERS_rec.attribute2 OR
            p_old_QUALIFIERS_rec.attribute2 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute3 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute3 <>
            p_old_QUALIFIERS_rec.attribute3 OR
            p_old_QUALIFIERS_rec.attribute3 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute4 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute4 <>
            p_old_QUALIFIERS_rec.attribute4 OR
            p_old_QUALIFIERS_rec.attribute4 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute5 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute5 <>
            p_old_QUALIFIERS_rec.attribute5 OR
            p_old_QUALIFIERS_rec.attribute5 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute6 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute6 <>
            p_old_QUALIFIERS_rec.attribute6 OR
            p_old_QUALIFIERS_rec.attribute6 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute7 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute7 <>
            p_old_QUALIFIERS_rec.attribute7 OR
            p_old_QUALIFIERS_rec.attribute7 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute8 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute8 <>
            p_old_QUALIFIERS_rec.attribute8 OR
            p_old_QUALIFIERS_rec.attribute8 IS NULL ))
    OR  (p_QUALIFIERS_rec.attribute9 IS NOT NULL AND
        (   p_QUALIFIERS_rec.attribute9 <>
            p_old_QUALIFIERS_rec.attribute9 OR
            p_old_QUALIFIERS_rec.attribute9 IS NULL ))
    OR  (p_QUALIFIERS_rec.context IS NOT NULL AND
        (   p_QUALIFIERS_rec.context <>
            p_old_QUALIFIERS_rec.context OR
            p_old_QUALIFIERS_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_QUALIFIERS_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_QUALIFIERS_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_QUALIFIERS_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_QUALIFIERS_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_QUALIFIERS_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_QUALIFIERS_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_QUALIFIERS_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_QUALIFIERS_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_QUALIFIERS_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_QUALIFIERS_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_QUALIFIERS_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_QUALIFIERS_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_QUALIFIERS_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_QUALIFIERS_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_QUALIFIERS_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_QUALIFIERS_rec.context
        );
*/

        --  Validate descriptive flexfield.

    --dbms_output.put_line('validating flex   ');
        IF NOT QP_Validate.Desc_Flex( 'QP_QUALIFIERS' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    --dbms_output.put_line('status is '||x_return_status);

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;
    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_QUALIFIERS_rec.list_header_id,
                             p_list_line_id   => p_QUALIFIERS_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END QP_Validate_Qualifiers;

/
