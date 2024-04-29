--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_PRICING_ATTR" AS
/* $Header: QPXLPRAB.pls 120.8 2006/09/07 10:08:10 rbagri noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Pricing_Attr';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;
l_primary_list_line_type_code VARCHAR2(30);
l_organization_id             VARCHAR2(30);
l_dummy_2                     VARCHAR2(3);
l_dummy_3                     NUMBER;
l_count                       NUMBER;
l_qp_status                   VARCHAR2(1);
l_no_pricing_attr             NUMBER;

l_start_date_active DATE;
l_end_date_active DATE;
l_list_header_id NUMBER;

l_uom_list_header_id NUMBER;

CURSOR list_line_type_code_cur(a_list_line_id NUMBER)
IS
  SELECT *
  FROM   qp_list_lines
  WHERE  list_line_id = a_list_line_id;

CURSOR gsa_cur(a_list_header_id NUMBER)
IS
  SELECT gsa_indicator
  FROM   qp_list_headers_b
  WHERE  list_header_id = a_list_header_id;

CURSOR to_rltd_modifier_id_cur(a_list_line_id NUMBER,
                               a_rltd_modifier_grp_type VARCHAR2)
IS
  select to_rltd_modifier_id
  from   qp_rltd_modifiers
  where  to_rltd_modifier_id = a_list_line_id
  and    rltd_modifier_grp_type = a_rltd_modifier_grp_type;

--  SELECT list_line_type_code
l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

l_pte_code                    VARCHAR2(30);
l_ss_code                     VARCHAR2(30);
l_fna_name                    VARCHAR2(4000);
l_fna_desc                    VARCHAR2(489);
l_fna_valid                   BOOLEAN;

BEGIN

oe_debug_pub.add('BEGIN Entity in QPXLPRAB');

    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    --dbms_output.put_line('Manoj - QPXLPRAB - list_header_id = ' || p_PRICING_ATTR_rec.list_header_id);
    --dbms_output.put_line('Manoj - QPXLPRAB - list_line_id = ' || p_PRICING_ATTR_rec.list_line_id);
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_PRICING_ATTR_rec.list_header_id,
                             p_list_line_id   => p_PRICING_ATTR_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Check required attributes.

    IF  p_PRICING_ATTR_rec.pricing_attribute_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

/*
    IF  p_PRICING_ATTR_rec.list_header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Header Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_PRICING_ATTR_rec.pricing_phase_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Phase Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;
*/

    --
    --  Check rest of required attributes .
    --


    IF p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    THEN

       IF  p_old_PRICING_ATTR_rec.product_attribute IS NOT NULL
       AND p_old_PRICING_ATTR_rec.product_attribute <> FND_API.G_MISS_CHAR
       AND p_old_PRICING_ATTR_rec.product_attribute <> p_PRICING_ATTR_rec.product_attribute        THEN
       DECLARE
       count_attr NUMBER;
       BEGIN
       Select count(*) into count_attr
       from qp_pricing_attributes
       where list_line_id = p_PRICING_ATTR_rec.list_line_id;
       if count_attr > 1 THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_PROD_ATTR');
        OE_MSG_PUB.Add;
       ELSE
        NULL;
       END IF;
       END;

       END IF;

       IF  p_old_PRICING_ATTR_rec.product_attr_value IS NOT NULL
       AND p_old_PRICING_ATTR_rec.product_attr_value <> FND_API.G_MISS_CHAR
       AND p_old_PRICING_ATTR_rec.product_attr_value <> p_PRICING_ATTR_rec.product_attr_value
	  THEN

               DECLARE
	       count_attr NUMBER;
	       BEGIN
	       Select count(*) into count_attr
	       from qp_pricing_attributes
	       where list_line_id = p_PRICING_ATTR_rec.list_line_id;
	       if count_attr > 1 AND  p_PRICING_ATTR_rec.excluder_flag = 'N' THEN
	        l_return_status := FND_API.G_RET_STS_ERROR;

	        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_PROD_VALUE');
	        OE_MSG_PUB.Add;
	       ELSE
	        NULL;
	       END IF;
	       END;
       END IF;

    END IF;




 FOR list_line in list_line_type_code_cur(p_PRICING_ATTR_rec.list_line_id)
 LOOP

/* Bug2069685 Start */

IF (list_line.price_break_type_code = 'RECURRING' AND
   p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME' AND --bug#4261068
    p_PRICING_ATTR_rec.pricing_attr_value_from <= 0) then

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_RECUR_VAL_FROM_CHECK');

          OE_MSG_PUB.Add;

END IF;

/* Bug2069685 End */

oe_debug_pub.add('excluder flag = '||p_PRICING_ATTR_rec.excluder_flag);

    IF  list_line.list_line_type_code <> 'PMR' THEN
      IF  p_PRICING_ATTR_rec.excluder_flag IS NULL
       THEN

oe_debug_pub.add('excluder flag null');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('EXCLUDER_FLAG'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

      ELSIF  ( p_PRICING_ATTR_rec.excluder_flag <> 'Y' AND
              p_PRICING_ATTR_rec.excluder_flag <> 'N' )
      THEN

oe_debug_pub.add('excluder flag invalid');
         l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_EXCLD_FLAG_Y_OR_N');
         OE_MSG_PUB.Add;

      END IF;
    END IF; --list_line_type_code not 'PMR'

oe_debug_pub.add(p_PRICING_ATTR_rec.Comparison_operator_code);

    IF   list_line.list_line_type_code <> 'PBH'
    THEN

      IF   p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL
      AND  p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
      THEN

         IF  p_PRICING_ATTR_rec.comparison_operator_code IS NULL
         THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE'));  -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

         END IF;

         IF  ( p_PRICING_ATTR_rec.comparison_operator_code <> '=' AND
              p_PRICING_ATTR_rec.comparison_operator_code <> 'BETWEEN' )
          THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

             FND_MESSAGE.SET_NAME('QP','QP_INVALID_COMP_OPERATOR');
             OE_MSG_PUB.Add;

         END IF;

         -- Do not check for value to null. This change is to avoid an error being thrown
         -- when a null value to is entered for the last price break (infinite value)
         IF   p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
         --AND  p_PRICING_ATTR_rec.pricing_attr_value_to IS NULL
         THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

             FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')||'/'||
                                            QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO'));  --Fix For Bug-1974413
             OE_MSG_PUB.Add;

            -- Do not check for value to null. This change is to avoid an error being thrown
            -- when a null value to is entered for the last price break (infinite value)
	    ELSIF p_PRICING_ATTR_rec.comparison_operator_code = 'BETWEEN'
	    AND p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
	    --AND (p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
	    --OR   p_PRICING_ATTR_rec.pricing_attr_value_to IS NULL)
            AND list_line.price_break_type_code <> 'RECURRING' THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

             FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')||'/'||
                                          QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO'));  --Fix For Bug-1974413
             OE_MSG_PUB.Add;

            ELSIF p_PRICING_ATTR_rec.comparison_operator_code = 'BETWEEN'
            AND   p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
            AND list_line.price_break_type_code = 'RECURRING' THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

             FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM'));  -- Fix For Bug-1974413
             OE_MSG_PUB.Add;
         END IF;



	END IF;

/*commented out this validation and included the else condition that follows -spgopal
    ELSIF  p_PRICING_ATTR_rec.pricing_attribute IS NULL
    THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Volume Type');
          OE_MSG_PUB.Add;
		*/

    ELSE


		IF p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL THEN

				IF p_PRICING_ATTR_rec.pricing_attribute IS NULL THEN

          			l_return_status := FND_API.G_RET_STS_ERROR;

          			FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          			FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Volume Type');
          			OE_MSG_PUB.Add;

				ELSIF p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
					AND p_PRICING_ATTR_rec.pricing_attribute_context
								= 'VOLUME'
					AND p_PRICING_ATTR_rec.comparison_operator_code
								= 'BETWEEN'
					AND (p_PRICING_ATTR_rec.pricing_attr_value_from
								IS NOT NULL
					OR p_PRICING_ATTR_rec.pricing_attr_value_to
								IS NOT NULL) THEN
				--when value from/to entered for PBH record volume context

          				l_return_status := FND_API.G_RET_STS_ERROR;

          				FND_MESSAGE.SET_NAME('QP','QP_PBH_NO_VALUE_FROM_TO');
          				OE_MSG_PUB.Add;

				ELSIF p_PRICING_ATTR_rec.pricing_attribute_context
								<> 'VOLUME'
					AND p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
					AND p_PRICING_ATTR_rec.comparison_operator_code = 'BETWEEN'
					AND (p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
					OR p_PRICING_ATTR_rec.pricing_attr_value_to IS NULL) THEN

				--when value from/to NOT entered for PBH rec context<>VOLUME

             				l_return_status := FND_API.G_RET_STS_ERROR;

             				FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
             				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')||'/'||
                                                QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO')); -- Fix For Bug-1974413
             				OE_MSG_PUB.Add;

				ELSIF p_PRICING_ATTR_rec.pricing_attribute_context
								<> 'VOLUME'
					AND p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
					AND p_PRICING_ATTR_rec.comparison_operator_code = '='
					AND (p_PRICING_ATTR_rec.pricing_attr_value_from IS NULL
					AND p_PRICING_ATTR_rec.pricing_attr_value_to IS NULL) THEN

				--when value from/to NOT entered for PBH rec context<>VOLUME

             				l_return_status := FND_API.G_RET_STS_ERROR;

             				FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
             				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')||'/'||                                                          QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO')); --Fix For Bug-1974413
             				OE_MSG_PUB.Add;


				END IF;

		END IF;


    END IF;

/* The Pricing Context for a Price Break Header record must be VOLUME

    IF   list_line.list_line_type_code = 'PBH'
    AND  p_PRICING_ATTR_rec.pricing_attribute_context <> 'VOLUME'
    THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_PBH_PRICING_CONTEXT_VOLUME');
          OE_MSG_PUB.Add;


    END IF;

*/

/* If Value From or Value To or Comparison Operator is entered, it is mandatory to enter pricing attribute */


    IF   list_line.list_line_type_code <> 'PBH'
    THEN

      IF   p_PRICING_ATTR_rec.pricing_attribute_context IS NULL
      AND  p_PRICING_ATTR_rec.pricing_attribute IS NULL
      THEN

        IF   (p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
        OR   p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL
        OR   (p_PRICING_ATTR_rec.comparison_operator_code IS NOT NULL
        AND   list_line.list_line_type_code <> 'RLTD'))
        THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Volume Type');
            OE_MSG_PUB.Add;

        END IF;

      END IF;

    END IF;


/* Added validation by dhgupta to fix bug # 1859923 */

    IF   p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
    THEN

     l_error_code := QP_UTIL.validate_num_date(p_PRICING_ATTR_rec.pricing_attribute_datatype,
                                               p_PRICING_ATTR_rec.pricing_attr_value_from);

       If (l_error_code <> 0)       --  invalid value
          Then
                  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From');
               OE_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
       End If;

    END IF;




    IF   p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL
    THEN

     l_error_code := QP_UTIL.validate_num_date(p_PRICING_ATTR_rec.pricing_attribute_datatype,
                                               p_PRICING_ATTR_rec.pricing_attr_value_to);

       If (l_error_code <> 0)       --  invalid value
          Then
                  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To');
               OE_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
       End If;

    END IF;

/* End validation added by dhgupta to fix bug 1859923 */



    IF   p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
    AND  p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL
    AND  p_PRICING_ATTR_rec.pricing_attribute_datatype = 'N'
    THEN

     IF  QP_NUMBER.CANONICAL_TO_NUMBER(p_PRICING_ATTR_rec.pricing_attr_value_from) >
         QP_NUMBER.CANONICAL_TO_NUMBER(p_PRICING_ATTR_rec.pricing_attr_value_to)
     THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_FROM_MUST_LESS_THAN_TO');
           OE_MSG_PUB.Add;

     END IF;

    END IF;

    IF list_line.list_line_type_code <> 'PMR' THEN

      FOR gsa_ind_cur in gsa_cur(list_line.list_header_id)
	 LOOP

/* The only Product Attribute allowed for GSA Discounts is Item Number   */

       IF    gsa_ind_cur.gsa_indicator = 'Y'
       AND   p_PRICING_ATTR_rec.product_attribute_context <> 'ITEM'
       THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

	        FND_MESSAGE.SET_NAME('QP','QP_GSA_PROD_ATTR_ITEM');
             OE_MSG_PUB.Add;

       END IF;

/* Exclude flag cannot be 'Y' for GSA Discounts   */

       IF    gsa_ind_cur.gsa_indicator = 'Y'
       AND   p_PRICING_ATTR_rec.excluder_flag = 'Y'
       THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

	        FND_MESSAGE.SET_NAME('QP','QP_NO_EXCLUDE_FOR_GSA');
             OE_MSG_PUB.Add;

       END IF;

/* Pricing Attributes are not allowed for GSA Discounts   */

       IF    gsa_ind_cur.gsa_indicator = 'Y'
       AND   (p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL
       OR    p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
       OR    p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
       OR    p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL)
       THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

	        FND_MESSAGE.SET_NAME('QP','QP_NO_PRICING_ATTR_FOR_GSA');
             OE_MSG_PUB.Add;

       END IF;

--- start bug2091362, bug2119287

l_qp_status := QP_UTIL.GET_QP_STATUS;

IF (fnd_profile.value('QP_ALLOW_DUPLICATE_MODIFIERS') <> 'Y' AND
(l_qp_status = 'S' or gsa_ind_cur.gsa_indicator = 'Y')) THEN
select start_date_active, end_date_active , list_header_id
    into l_start_date_active, l_end_date_active, l_list_header_id
    from qp_list_lines
    where list_line_id = p_PRICING_ATTR_rec.list_line_id;

   OE_Debug_Pub.add ( ' Value Set 1' || l_start_date_active || l_end_date_active );

   oe_debug_pub.add('about to delete a request to check duplicate modifier list lines without product attribute');
QP_delayed_requests_pvt.Delete_Request
(   p_entity_code => QP_GLOBALS.G_ENTITY_ALL
,   p_entity_id    =>  p_PRICING_ATTR_rec.list_line_id
,   p_request_Type =>  QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   x_return_status		=> l_return_status
);

IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in deleting a delayed request for duplicate Modifier');

        RAISE FND_API.G_EXC_ERROR;

END IF;
/* After deleting the first one for modifier lines without pricing attributes, log a new request
   to check duplicate modifier list lines with product attribute */
   oe_debug_pub.add('about to log a request to check duplicate modifier list lines with product attribute');
   QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> p_PRICING_ATTR_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_ALL
,   p_requesting_entity_id	=> p_PRICING_ATTR_rec.list_line_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   p_param1			=> l_list_header_id
,   p_param2			=> fnd_date.date_to_canonical(l_start_date_active)		--2752265
,   p_param3			=> fnd_date.date_to_canonical(l_end_date_active)		--2752265
,   p_param4                    =>  p_PRICING_ATTR_rec.product_attribute_context
,   p_param5                    => p_PRICING_ATTR_rec.product_attribute
,   p_param6                    =>p_PRICING_ATTR_rec.product_attr_value
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

  oe_debug_pub.add('after logging delayed request for duplicate modifiers');

END IF;

  --- end 2091362


     END LOOP;

/*       IF    p_PRICING_ATTR_rec.product_attribute_context = 'ITEM'
       AND   p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE1' */

       IF    list_line.list_line_type_code <> 'RLTD'
       AND   list_line.price_break_type_code IS NOT NULL
       AND   p_PRICING_ATTR_rec.excluder_flag = 'N'
       AND   p_PRICING_ATTR_rec.product_uom_code IS NULL
       THEN
        IF ((list_line.LIST_LINE_TYPE_CODE in ('IUE','PRG','OID')  AND
             p_PRICING_ATTR_rec.PRICING_ATTRIBUTE NOT IN
                      ('PRICING_ATTRIBUTE12','PRICING_ATTRIBUTE13',
                       'PRICING_ATTRIBUTE14','PRICING_ATTRIBUTE15')) OR -- Bug#2828308
             p_PRICING_ATTR_rec.PRICING_ATTRIBUTE = 'PRICING_ATTRIBUTE10') THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_UOM_CODE')); -- Fix For Bug-1974413
        OE_MSG_PUB.Add;
        END IF;
       END IF;


      IF   p_PRICING_ATTR_rec.product_attribute_context IS NULL
      OR   p_PRICING_ATTR_rec.product_attribute IS NULL
      OR   p_PRICING_ATTR_rec.product_attr_value IS NULL
--      OR   p_PRICING_ATTR_rec.product_uom_code IS NULL
      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTRIBUTE')||'/'||
                                     QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTR_VALUE'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

	 ELSE

/* Order level discounts cannot have Products  */

	   IF list_line.modifier_level_code = 'ORDER'
	   THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

	      FND_MESSAGE.SET_NAME('QP','QP_ORDER_LEVEL_NO_PRODUCT');
           OE_MSG_PUB.Add;

	   END IF;

       QP_UTIL.validate_qp_flexfield(flexfield_name     =>'QP_ATTR_DEFNS_PRICING'
						 ,context    =>p_PRICING_ATTR_rec.product_attribute_context
						 ,attribute  =>p_PRICING_ATTR_rec.product_attribute
						 ,value      =>p_PRICING_ATTR_rec.product_attr_value
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_flag
						 ,attribute_flag                 =>l_attribute_flag
						 ,value_flag                     =>l_value_flag
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

oe_debug_pub.add('error code = '|| to_char(l_error_code));
       If (l_context_flag = 'N'  AND l_error_code = 7)       --  invalid context
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_CONTEXT'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;

       If (l_attribute_flag = 'N'  AND l_error_code = 8)       --  invalid attribute
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_ATTR'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;

       If (l_value_flag = 'N'  AND l_error_code = 9)       --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_VALUE'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;


       END IF;

--        p_PRICING_ATTR_rec.product_attribute_datatype := l_datatype;

           -- Functional Area Validation for Hierarchical Categories (sfiresto)
         IF p_PRICING_ATTR_rec.product_attribute_context = 'ITEM' AND
            p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE2' THEN
           BEGIN

             -- We have to use list_line_id here because list_header_id has not been populated yet.
             SELECT h.pte_code, h.source_system_code
             INTO l_pte_code, l_ss_code
             FROM qp_list_headers_b h, qp_list_lines l
             WHERE l.list_line_id = p_PRICING_ATTR_rec.list_line_id
               AND l.list_header_id = h.list_header_id;

             QP_UTIL.Get_Item_Cat_Info(
                p_PRICING_ATTR_rec.product_attr_value,
                l_pte_code,
                l_ss_code,
                l_fna_name,
                l_fna_desc,
                l_fna_valid);

             IF NOT l_fna_valid THEN

               l_return_status := FND_API.G_RET_STS_ERROR;

               IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                 FND_MESSAGE.set_name('QP', 'QP_INVALID_CAT_FUNC_PTE');
                 FND_MESSAGE.set_token('CATID', p_pricing_attr_rec.product_attr_value);
                 FND_MESSAGE.set_token('PTE', l_pte_code);
                 FND_MESSAGE.set_token('SS', l_ss_code);
                 OE_MSG_PUB.Add;
               END IF;

             END IF;

           END;
         END IF;

oe_debug_pub.add('end attribute ');

--fix for bug 5507953
 l_return_status := QP_UTIL.Validate_Item(p_PRICING_ATTR_rec.product_attribute_context,
                      p_PRICING_ATTR_rec.product_attribute,
                      p_PRICING_ATTR_rec.product_attr_value);

      IF  p_PRICING_ATTR_rec.product_uom_code IS NOT NULL
      THEN

         IF    p_PRICING_ATTR_rec.product_attribute_context = 'ITEM'    -- Item Number
         AND   p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE1'
         THEN
oe_debug_pub.add('IIIITTTTEEEEMMMM');
            l_organization_id := QP_UTIL.Get_Item_Validation_Org;

     	    BEGIN

     	     select distinct uom_code
     	     into   l_dummy_2
     	     from   mtl_item_uoms_view
     	     where  ( organization_id = l_organization_id
			or       l_organization_id is NULL )
     	     and    uom_code =  p_PRICING_ATTR_rec.product_uom_code
     	     and    inventory_item_id =  to_number(p_PRICING_ATTR_rec.product_attr_value);

              EXCEPTION
	          WHEN NO_DATA_FOUND THEN
               l_return_status := FND_API.G_RET_STS_ERROR;

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
               OE_MSG_PUB.Add;

              END;

	   END IF;

         IF    p_PRICING_ATTR_rec.product_attribute_context = 'ITEM'  -- Item Category
         AND   p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE2'
         THEN

oe_debug_pub.add('CCCCAAAATTTT');

           -- the validation code that was here has been abstracted out to
           -- package QP_CATEGORY_MAPPING_RULE for 11i10 Product Catalog

           -- Get the list_header_id from the list_line_id, since the list_header_id is not set in
           --  the p_PRICING_ATTR_rec.list_header_id yet.
           select list_header_id into l_uom_list_header_id
           from qp_list_lines
           where list_line_id = p_PRICING_ATTR_rec.list_line_id;

           IF NOT QP_VALIDATE.Product_Uom(p_PRICING_ATTR_rec.product_uom_code, -- sfiresto 4753707
                                          to_number(p_PRICING_ATTR_rec.product_attr_value),
                                          l_uom_list_header_id)
           THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
             OE_MSG_PUB.Add;
           END IF;

         END IF;

         IF    p_PRICING_ATTR_rec.product_attribute_context = 'ITEM' -- All Items
         AND   p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE3'
         THEN

oe_debug_pub.add('AAAAAAALLLLLLL');
     	    BEGIN

     	     select distinct uom_code
     	     into   l_dummy_2
     	     from   mtl_units_of_measure_vl
     	     where  uom_code =  p_PRICING_ATTR_rec.product_uom_code;

              EXCEPTION
	          WHEN NO_DATA_FOUND THEN
               l_return_status := FND_API.G_RET_STS_ERROR;

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
               OE_MSG_PUB.Add;

              END;

	   END IF;

	  END IF;

/* Product is mandatory for Item Upgrade, Other Item Discount, Promotional Goods, Related Products and Price Break Header */

      IF    list_line.list_line_type_code = 'IUE'
      OR    list_line.list_line_type_code = 'OID'
      OR    list_line.list_line_type_code = 'PRG'
      OR    list_line.list_line_type_code = 'RLTD'
      OR    list_line.list_line_type_code = 'PBH'
      OR    list_line.list_line_type_code = 'TSN'
	 THEN

         IF    p_PRICING_ATTR_rec.product_attribute_context IS NULL
         OR    p_PRICING_ATTR_rec.product_attribute IS NULL
         OR    p_PRICING_ATTR_rec.product_attr_value IS NULL
         THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTRIBUTE_CONTEXT')||'/'||
                                        QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTRIBUTE')||'/'||
                                     QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTR_VALUE'));  -- Fix For Bug-1974413
           OE_MSG_PUB.Add;

	    END IF;

	  END IF;

/* Item Number is mandatory for Item Upgrade - cannot be category or ALL */

      IF    list_line.list_line_type_code = 'IUE'
      AND   p_PRICING_ATTR_rec.product_attribute_context = 'ITEM'
      AND   p_PRICING_ATTR_rec.product_attribute <> 'PRICING_ATTRIBUTE1'
      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ITEM_MAND_FOR_IUE');
        OE_MSG_PUB.Add;

	 END IF;

/* Item Number is mandatory for Get Products - cannot be category or ALL */

             -- julin [3754832]: using cursor to reuse sql
             l_dummy_3 := null;
             OPEN to_rltd_modifier_id_cur(p_PRICING_ATTR_rec.list_line_id, 'BENEFIT');
             FETCH to_rltd_modifier_id_cur INTO l_dummy_3;
             CLOSE to_rltd_modifier_id_cur;

             IF l_dummy_3 is not null THEN
                IF   p_PRICING_ATTR_rec.product_attribute_context = 'ITEM'
                AND  p_PRICING_ATTR_rec.product_attribute <> 'PRICING_ATTRIBUTE1'
                THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;

	             FND_MESSAGE.SET_NAME('QP','QP_ITEM_MAND_FOR_GET');
                  OE_MSG_PUB.Add;

	           END IF;

/* Get record must be of the type Discount (DIS) for Other Item Discount and Promotional Goods  */

                IF    list_line.list_line_type_code <> 'DIS'
                THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;

                  FND_MESSAGE.SET_NAME('QP','QP_GET_MUST_BE_DISCOUNT');
                  OE_MSG_PUB.Add;

	           END IF;

            END IF;

/* Additional products must be of the type Related (RLTD) for Other Item Discount and Promotional Goods  */

             -- julin [3754832]: using cursor to reuse sql
             l_dummy_3 := null;
             OPEN to_rltd_modifier_id_cur(p_PRICING_ATTR_rec.list_line_id, 'QUALIFIER');
             FETCH to_rltd_modifier_id_cur INTO l_dummy_3;
             CLOSE to_rltd_modifier_id_cur;

             IF l_dummy_3 is not null THEN
                IF    list_line.list_line_type_code <> 'RLTD'
                THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;

                  FND_MESSAGE.SET_NAME('QP','QP_ADD_MUST_BE_RELATED');
                  OE_MSG_PUB.Add;

	           END IF;

            END IF;

    END IF; --list_line_type_code <> 'PMR'

  /* Product precedence is mandatory on a Modifier line if a product exists in the pricing attributes */


    IF  list_line.list_line_type_code = 'DIS'
    OR   list_line.list_line_type_code = 'SUR'
    OR   list_line.list_line_type_code = 'FREIGHT_CHARGE'
    OR  list_line.list_line_type_code = 'PRG'
    THEN

      BEGIN

  	   select count(*)
	   into   l_count
	   from   qp_rltd_modifiers
	   where  to_rltd_modifier_id = p_PRICING_ATTR_rec.list_line_id;

      EXCEPTION
	   when no_data_found then
	   l_count := 0;

      END;

    END IF;

oe_debug_pub.add('prod line id '|| to_char(p_PRICING_ATTR_rec.list_line_id));
oe_debug_pub.add('line id '|| to_char(list_line.list_line_id));
oe_debug_pub.add('list line type '|| list_line.list_line_type_code);
oe_debug_pub.add('prece '|| to_char(list_line.product_precedence));


    IF   (((list_line.list_line_type_code = 'DIS'
    OR   list_line.list_line_type_code = 'SUR'
    OR   list_line.list_line_type_code = 'FREIGHT_CHARGE'
    OR   list_line.list_line_type_code = 'PRG')
    AND  l_count = 0 )
    OR   (list_line.list_line_type_code = 'TSN'))
    AND   list_line.product_precedence IS NULL
    THEN

oe_debug_pub.add('prece 22 ');
		--changes by spgopal for bug 1466254
		--precedence is mandatory for pricing attribute records to exclude product
		if p_PRICING_ATTR_rec.excluder_flag = 'N' then
        		l_return_status := FND_API.G_RET_STS_ERROR;

        		FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_PRECEDENCE'));  -- Fix For Bug-1974413
        		OE_MSG_PUB.Add;
		end if;

    END IF;

  /* Recurring must have comparison operator as =

    IF list_line.list_line_type_code <> 'PMR' THEN
      IF   list_line.price_break_type_code = 'RECURRING'
      AND  p_PRICING_ATTR_rec.comparison_operator_code <> '='
      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_RECUR_OPER_MUST_BE_EQUL');
        OE_MSG_PUB.Add;

      END IF;

 Point or Range must have comparison operator as Between

     IF  (list_line.price_break_type_code = 'POINT'
     OR   list_line.price_break_type_code = 'RANGE')
     AND  p_PRICING_ATTR_rec.comparison_operator_code <> 'BETWEEN'
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_POINT_RANGE_OPER_BETWEEN');
        OE_MSG_PUB.Add;

     END IF;  */

     oe_debug_pub.add('pric context = '||p_PRICING_ATTR_rec.pricing_attribute_context);
     oe_debug_pub.add('comp oper = '|| p_PRICING_ATTR_rec.comparison_operator_code);
     oe_debug_pub.add('list type = '|| list_line.list_line_type_code);

    IF list_line.list_line_type_code <> 'PMR' THEN
     IF   p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME'
     AND  (p_PRICING_ATTR_rec.comparison_operator_code <> 'BETWEEN'
     OR   p_PRICING_ATTR_rec.comparison_operator_code IS NULL )
     THEN

     oe_debug_pub.add('I am herrrrr');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_BETW_MAND_FOR_VOLUME');
        OE_MSG_PUB.Add;

     END IF;

  /* Select the Primary line type of the current record   */

      BEGIN

	    SELECT LIST_LINE_TYPE_CODE
	    INTO   l_primary_list_line_type_code
	    FROM   QP_LIST_LINES
	    WHERE  LIST_LINE_ID = ( select from_rltd_modifier_id
							 from qp_rltd_modifiers
	                               where to_rltd_modifier_id
							 = p_PRICING_ATTR_rec.list_line_id);

      EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    l_primary_list_line_type_code := NULL;

      END;

/*    Not to be done - discussed with Alison - If the Primary line is a Coupon Issue and the Child lines are DIS or PRG, and if the product is entered, product precedence is mandatory

     IF   l_primary_list_line_type_code = 'CIE'
     AND  ( list_line.list_line_type_code = 'DIS'
     OR   list_line.list_line_type_code = 'PRG')
     AND   list_line.product_precedence IS NULL
     THEN

oe_debug_pub.add('prece 33 ');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Precedence');
        OE_MSG_PUB.Add;

    END IF;  */

/*   If the Primary line is a OID or PRG, and if the product is entered, proration type code is mandatory */

     IF   (l_primary_list_line_type_code = 'OID'
     OR   l_primary_list_line_type_code = 'PRG')
     AND   list_line.proration_type_code IS NULL
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

    END IF;

/*   If the Primary line is a Price Break Header and the Child lines are DIS or SUR, and if the product is entered, proration type code is mandatory  */

     IF   l_primary_list_line_type_code = 'PBH'
     AND  ( list_line.list_line_type_code = 'DIS'
     OR   list_line.list_line_type_code = 'SUR')
     AND   list_line.proration_type_code IS NULL
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;

oe_debug_pub.add('end uom ');
   END IF; --If list_line_type_code <> 'PMR'

   IF   p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL
   THEN

        QP_UTIL.validate_context_code(p_flexfield_name => 'QP_ATTR_DEFNS_PRICING'
                     ,p_application_short_name  => 'QP'
 	                ,p_context_name            => p_PRICING_ATTR_rec.pricing_attribute_context
  		 	      ,p_error_code              => l_error_code);

       IF (l_error_code <> 0 )       --  invalid context
	  THEN
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICING_CONTEXT'  );
               OE_MSG_PUB.Add;
            END IF;

       END IF;
    END IF;

  /* If pricing context is VOLUME, price break is mandatory   */

    IF list_line.list_line_type_code <> 'PMR' THEN
      IF   p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME'
      AND  list_line.price_break_type_code IS NULL
      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_BREAK_MAND_FOR_VOLUME');
        OE_MSG_PUB.Add;

      END IF;

      IF   p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL
      AND  p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
	 THEN

         QP_UTIL.validate_attribute_name(p_application_short_name => 'QP'
                         ,p_flexfield_name    => 'QP_ATTR_DEFNS_PRICING'
                         ,p_context_name      => p_PRICING_ATTR_rec.pricing_attribute_context
                         ,p_attribute_name    => p_PRICING_ATTR_rec.pricing_attribute
  		 	          ,p_error_code        => l_error_code);

         IF (l_error_code <> 0 )       --  invalid context
	    THEN
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICING_ATTR'  );
               OE_MSG_PUB.Add;
            END IF;

         END IF;

  /* If pricing attribute is VOLUME, for RLTD record, comparison operator must be BETWEEN */

         IF   p_PRICING_ATTR_rec.pricing_attribute_context = 'VOLUME'
         AND  list_line.list_line_type_code = 'RLTD'
         AND  p_PRICING_ATTR_rec.comparison_operator_code <> 'BETWEEN'
         THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_BREAK_MAND_FOR_VOLUME');
           OE_MSG_PUB.Add;

         END IF;

     END IF; --If Pricing Attribute and Context are not null

/* Call this procedure to validate pricing_attr_value_from since it may have valid values from the LOV like color as 'BLUE'. This procedure also checks for invalid canonical format  */

    IF   p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
    AND  p_PRICING_ATTR_rec.comparison_operator_code = '='
    THEN

       QP_UTIL.validate_qp_flexfield(flexfield_name     =>'QP_ATTR_DEFNS_PRICING'
						 ,context    =>p_PRICING_ATTR_rec.pricing_attribute_context
						 ,attribute  =>p_PRICING_ATTR_rec.pricing_attribute
						 ,value      =>p_PRICING_ATTR_rec.pricing_attr_value_from
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_flag
						 ,attribute_flag                 =>l_attribute_flag
						 ,value_flag                     =>l_value_flag
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

       If (l_context_flag = 'N'  AND l_error_code = 9)       --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From');
               OE_MSG_PUB.Add;
            END IF;

       End If;
oe_debug_pub.add('pricing attr value from = '|| p_PRICING_ATTR_rec.pricing_attr_value_from);
oe_debug_pub.add('from datatype = '||l_datatype);
oe_debug_pub.add('from error  = '||to_char(l_error_code));

    END IF;

/* Value To cannot be given with Recurring break type   */
/*commenting this validation, value_to is mandatory, so we will default a huge no for value_to with recurring - spgopal for bug 1566429*/
/*
    IF   p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL
    AND  list_line.price_break_type_code = 'RECURRING'
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_VALUE_TO_NOT_WITH_RECUR');
        OE_MSG_PUB.Add;

    END IF;
    */

/* Call this procedure to validate pricing_attr_value_to for invalid canonical format  */

    IF   p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL
    AND  p_PRICING_ATTR_rec.comparison_operator_code = 'BETWEEN'
    THEN

oe_debug_pub.add('pricing attr value to = '|| p_PRICING_ATTR_rec.pricing_attr_value_to);
oe_debug_pub.add('pricing attr datatype = '|| p_PRICING_ATTR_rec.pricing_attribute_datatype);

     l_error_code := QP_UTIL.validate_num_date(p_PRICING_ATTR_rec.pricing_attribute_datatype,
                                               p_PRICING_ATTR_rec.pricing_attr_value_to);

oe_debug_pub.add('to error  = '||to_char(l_error_code));
       If (l_error_code = 9)       --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To');
               OE_MSG_PUB.Add;
            END IF;

       End If;

    END IF;

     l_qp_status := QP_UTIL.GET_QP_STATUS;

-- For bug 2363065, raise the error in basic pricing if not called from FTE
    IF   (p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL
    AND  p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL
    AND  (p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL
    OR   p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL )
    AND  l_qp_status = 'S'
    AND  QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE <> 'FTE')
    THEN

        BEGIN

		 SELECT COUNT(*)
		 INTO   l_no_pricing_attr
		 FROM   QP_PRICING_ATTRIBUTES
		 WHERE  LIST_LINE_ID = p_PRICING_ATTR_rec.list_line_id
		 AND    PRICING_ATTRIBUTE_CONTEXT <> 'VOLUME';

		 IF nvl(l_no_pricing_attr,0) = 1
		 THEN
               l_return_status := FND_API.G_RET_STS_ERROR;

               FND_MESSAGE.SET_NAME('QP','QP_1_PRICING_ATTR_FOR_BASIC');
               OE_MSG_PUB.Add;

           END IF;

	   EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		 null;

        END;

     END IF;

   END IF; -- list_line_type_code <> 'PMR'

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

END LOOP;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --
    --Raise a warning if the Pricing/Product Attribute being used in setup
    --has a sourcing method of 'ATTRIBUTE MAPPING' but is not sourcing-enabled
    --or if its sourcing_status is not 'Y', i.e., the build sourcing conc.
    --program has to be run.

    oe_debug_pub.add('Here 0000');
  IF qp_util.attrmgr_installed = 'Y' THEN
    oe_debug_pub.add('Here 1111');
    IF p_Pricing_Attr_rec.product_attribute_context IS NOT NULL AND
       p_Pricing_Attr_rec.product_attribute IS NOT NULL
    THEN
    oe_debug_pub.add('Here 2222');
      QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                               p_Pricing_Attr_rec.product_attribute_context,
                               l_context_type,
                               l_error_code);

      IF l_error_code = 0 THEN --successfully returned context_type

    oe_debug_pub.add('Here 3333');
        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Pricing_Attr_rec.product_attribute_context,
                                  p_Pricing_Attr_rec.product_attribute,
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

    oe_debug_pub.add('Here 4444');
          IF l_sourcing_enabled <> 'Y' THEN

    oe_debug_pub.add('Here 5555');
            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.product_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.product_attribute);
            OE_MSG_PUB.Add;

          END IF;

          IF l_sourcing_status <> 'Y' THEN

    oe_debug_pub.add('Here 6666');
            FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.product_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.product_attribute);
            OE_MSG_PUB.Add;

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

      END IF; --l_error_code = 0

    END IF;--If product_attribute_context and product_attribute are NOT NULL

    IF p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL AND
       p_Pricing_Attr_rec.pricing_attribute IS NOT NULL
    THEN
      QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                               p_Pricing_Attr_rec.pricing_attribute_context,
                               l_context_type,
                               l_error_code);

      IF l_error_code = 0 THEN --successfully returned context_type

        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Pricing_Attr_rec.pricing_attribute_context,
                                  p_Pricing_Attr_rec.pricing_attribute,
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

          IF l_sourcing_enabled <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.pricing_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute);
            OE_MSG_PUB.Add;

          END IF;

          IF l_sourcing_status <> 'Y' THEN

            FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.pricing_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute);
            OE_MSG_PUB.Add;

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

      END IF; --l_error_code = 0

    END IF;--If pricing_attribute_context and pricing_attribute are NOT NULL

  END IF; --qp_util.attrmgr_installed = 'Y'

    --  Done validating entity

    x_return_status := l_return_status;

oe_debug_pub.add('END Entity in QPXLPRAB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
oe_debug_pub.add('EXP error');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

oe_debug_pub.add('EXP unexpect error');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

oe_debug_pub.add('EXP others');
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
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
)
IS
BEGIN

oe_debug_pub.add('BEGIN Attributes in QPXLPRAB');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PRICING_ATTR attributes

    IF  p_PRICING_ATTR_rec.accumulate_flag IS NOT NULL AND
        (   p_PRICING_ATTR_rec.accumulate_flag <>
            p_old_PRICING_ATTR_rec.accumulate_flag OR
            p_old_PRICING_ATTR_rec.accumulate_flag IS NULL )
    THEN
        IF NOT QP_Validate.Accumulate(p_PRICING_ATTR_rec.accumulate_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.attribute_grouping_no IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute_grouping_no <>
            p_old_PRICING_ATTR_rec.attribute_grouping_no OR
            p_old_PRICING_ATTR_rec.attribute_grouping_no IS NULL )
    THEN
        IF NOT QP_Validate.Attribute_Grouping_No(p_PRICING_ATTR_rec.attribute_grouping_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.created_by IS NOT NULL AND
        (   p_PRICING_ATTR_rec.created_by <>
            p_old_PRICING_ATTR_rec.created_by OR
            p_old_PRICING_ATTR_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_PRICING_ATTR_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.creation_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.creation_date <>
            p_old_PRICING_ATTR_rec.creation_date OR
            p_old_PRICING_ATTR_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_PRICING_ATTR_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.excluder_flag IS NOT NULL AND
        (   p_PRICING_ATTR_rec.excluder_flag <>
            p_old_PRICING_ATTR_rec.excluder_flag OR
            p_old_PRICING_ATTR_rec.excluder_flag IS NULL )
    THEN
        IF NOT QP_Validate.Excluder(p_PRICING_ATTR_rec.excluder_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_updated_by IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_updated_by <>
            p_old_PRICING_ATTR_rec.last_updated_by OR
            p_old_PRICING_ATTR_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_PRICING_ATTR_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_update_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_update_date <>
            p_old_PRICING_ATTR_rec.last_update_date OR
            p_old_PRICING_ATTR_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_PRICING_ATTR_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_update_login IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_update_login <>
            p_old_PRICING_ATTR_rec.last_update_login OR
            p_old_PRICING_ATTR_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_PRICING_ATTR_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.list_line_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.list_line_id <>
            p_old_PRICING_ATTR_rec.list_line_id OR
            p_old_PRICING_ATTR_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_PRICING_ATTR_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute <>
            p_old_PRICING_ATTR_rec.pricing_attribute OR
            p_old_PRICING_ATTR_rec.pricing_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute(p_PRICING_ATTR_rec.pricing_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute_context <>
            p_old_PRICING_ATTR_rec.pricing_attribute_context OR
            p_old_PRICING_ATTR_rec.pricing_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute_Context(p_PRICING_ATTR_rec.pricing_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute_id <>
            p_old_PRICING_ATTR_rec.pricing_attribute_id OR
            p_old_PRICING_ATTR_rec.pricing_attribute_id IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute(p_PRICING_ATTR_rec.pricing_attribute_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attr_value_from <>
            p_old_PRICING_ATTR_rec.pricing_attr_value_from OR
            p_old_PRICING_ATTR_rec.pricing_attr_value_from IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attr_Value_From(p_PRICING_ATTR_rec.pricing_attr_value_from) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attr_value_to <>
            p_old_PRICING_ATTR_rec.pricing_attr_value_to OR
            p_old_PRICING_ATTR_rec.pricing_attr_value_to IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attr_Value_To(p_PRICING_ATTR_rec.pricing_attr_value_to) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attribute <>
            p_old_PRICING_ATTR_rec.product_attribute OR
            p_old_PRICING_ATTR_rec.product_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attribute(p_PRICING_ATTR_rec.product_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute_context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attribute_context <>
            p_old_PRICING_ATTR_rec.product_attribute_context OR
            p_old_PRICING_ATTR_rec.product_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attribute_Context(p_PRICING_ATTR_rec.product_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attr_value IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attr_value <>
            p_old_PRICING_ATTR_rec.product_attr_value OR
            p_old_PRICING_ATTR_rec.product_attr_value IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attr_Value(p_PRICING_ATTR_rec.product_attr_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_uom_code IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_uom_code <>
            p_old_PRICING_ATTR_rec.product_uom_code OR
            p_old_PRICING_ATTR_rec.product_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Product_Uom(p_PRICING_ATTR_rec.product_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_application_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_application_id <>
            p_old_PRICING_ATTR_rec.program_application_id OR
            p_old_PRICING_ATTR_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_PRICING_ATTR_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_id <>
            p_old_PRICING_ATTR_rec.program_id OR
            p_old_PRICING_ATTR_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_PRICING_ATTR_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_update_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_update_date <>
            p_old_PRICING_ATTR_rec.program_update_date OR
            p_old_PRICING_ATTR_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_PRICING_ATTR_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.request_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.request_id <>
            p_old_PRICING_ATTR_rec.request_id OR
            p_old_PRICING_ATTR_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_PRICING_ATTR_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute_datatype IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attribute_datatype <>
            p_old_PRICING_ATTR_rec.product_attribute_datatype OR
            p_old_PRICING_ATTR_rec.product_attribute_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attribute_Datatype(p_PRICING_ATTR_rec.product_attribute_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_datatype IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute_datatype <>
            p_old_PRICING_ATTR_rec.pricing_attribute_datatype OR
            p_old_PRICING_ATTR_rec.pricing_attribute_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute_Datatype(p_PRICING_ATTR_rec.pricing_attribute_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.comparison_operator_code IS NOT NULL AND
        (   p_PRICING_ATTR_rec.comparison_operator_code <>
            p_old_PRICING_ATTR_rec.comparison_operator_code OR
            p_old_PRICING_ATTR_rec.comparison_operator_code IS NULL )
    THEN
        IF NOT QP_Validate.Comparison_Operator(p_PRICING_ATTR_rec.comparison_operator_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_PRICING_ATTR_rec.attribute1 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute1 <>
            p_old_PRICING_ATTR_rec.attribute1 OR
            p_old_PRICING_ATTR_rec.attribute1 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute10 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute10 <>
            p_old_PRICING_ATTR_rec.attribute10 OR
            p_old_PRICING_ATTR_rec.attribute10 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute11 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute11 <>
            p_old_PRICING_ATTR_rec.attribute11 OR
            p_old_PRICING_ATTR_rec.attribute11 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute12 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute12 <>
            p_old_PRICING_ATTR_rec.attribute12 OR
            p_old_PRICING_ATTR_rec.attribute12 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute13 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute13 <>
            p_old_PRICING_ATTR_rec.attribute13 OR
            p_old_PRICING_ATTR_rec.attribute13 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute14 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute14 <>
            p_old_PRICING_ATTR_rec.attribute14 OR
            p_old_PRICING_ATTR_rec.attribute14 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute15 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute15 <>
            p_old_PRICING_ATTR_rec.attribute15 OR
            p_old_PRICING_ATTR_rec.attribute15 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute2 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute2 <>
            p_old_PRICING_ATTR_rec.attribute2 OR
            p_old_PRICING_ATTR_rec.attribute2 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute3 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute3 <>
            p_old_PRICING_ATTR_rec.attribute3 OR
            p_old_PRICING_ATTR_rec.attribute3 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute4 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute4 <>
            p_old_PRICING_ATTR_rec.attribute4 OR
            p_old_PRICING_ATTR_rec.attribute4 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute5 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute5 <>
            p_old_PRICING_ATTR_rec.attribute5 OR
            p_old_PRICING_ATTR_rec.attribute5 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute6 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute6 <>
            p_old_PRICING_ATTR_rec.attribute6 OR
            p_old_PRICING_ATTR_rec.attribute6 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute7 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute7 <>
            p_old_PRICING_ATTR_rec.attribute7 OR
            p_old_PRICING_ATTR_rec.attribute7 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute8 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute8 <>
            p_old_PRICING_ATTR_rec.attribute8 OR
            p_old_PRICING_ATTR_rec.attribute8 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute9 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute9 <>
            p_old_PRICING_ATTR_rec.attribute9 OR
            p_old_PRICING_ATTR_rec.attribute9 IS NULL ))
    OR  (p_PRICING_ATTR_rec.context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.context <>
            p_old_PRICING_ATTR_rec.context OR
            p_old_PRICING_ATTR_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_PRICING_ATTR_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'PRICING_ATTR' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

oe_debug_pub.add('END Attributes in QPXLPRAB');

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
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

oe_debug_pub.add('BEGIN Entity_Delete in QPXLPRAB');

    --  Validate entity delete.

    NULL;
    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_PRICING_ATTR_rec.list_header_id,
                             p_list_line_id   => p_PRICING_ATTR_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Done.

    x_return_status := l_return_status;

oe_debug_pub.add('END Entity_Delete in QPXLPRAB');

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

-- start bug2091362
FUNCTION MOD_DUP(p_Start_Date_Active IN DATE
                                   , p_End_Date_Active IN DATE
                                           , p_List_Line_ID IN NUMBER
                                           , p_List_Header_ID IN NUMBER
                                           , p_product_attribute_context IN VARCHAR2
                                           , p_product_attribute IN VARCHAR2
                                           , p_product_attr_value IN VARCHAR2
                                           , p_x_rows OUT NOCOPY NUMBER
                                           , p_x_effdates OUT NOCOPY BOOLEAN
                                           )
RETURN BOOLEAN
is
        l_x_list_line_id NUMBER ;
        l_y_list_line_id NUMBER;

CURSOR get_rec(l_List_Line_ID NUMBER ) is
select a.list_line_id col1, b.list_line_id col2
from qp_pricing_attributes a, qp_pricing_attributes b, qp_list_lines c,
        qp_list_lines c1
where   a.list_line_id = l_List_Line_ID
and b.list_line_id <> l_List_Line_ID
and b.product_attribute_context = a.product_attribute_context
and b.product_attribute = a.product_attribute
and b.product_attr_value = a.product_attr_value
and b.pricing_attr_value_from Is Null
and a.pricing_attr_value_from Is Null
and nvl(Decode(b.pricing_attribute_context,'VOLUME',null),' ') =
                nvl(Decode(a.pricing_attribute_context,'VOLUME',null),' ')
and (nvl( b.product_uom_code,' ') = nvl(a.product_uom_code,' ')
        Or (a.pricing_attribute_context = 'VOLUME' Or b.pricing_attribute_context = 'VOLUME' ))
and (nvl(b.pricing_attribute,' ') = nvl(a.pricing_attribute,' ')
        Or (a.pricing_attribute_context = 'VOLUME' Or b.pricing_attribute_context = 'VOLUME' ))
and (nvl(b.pricing_attr_value_from,0) = nvl(a.pricing_attr_value_from,0)
        Or (a.pricing_attribute_context = 'VOLUME' Or b.pricing_attribute_context = 'VOLUME' ))
and (nvl(b.pricing_attr_value_to,0) = nvl(a.pricing_attr_value_to,0)
        Or (a.pricing_attribute_context = 'VOLUME' Or b.pricing_attribute_context = 'VOLUME' ))
and (nvl(b.comparison_operator_code,' ') = nvl(a.comparison_operator_code,' ')
        Or (a.pricing_attribute_context = 'VOLUME' Or b.pricing_attribute_context = 'VOLUME' ))
and a.list_line_id = c.list_line_id
and b.list_line_id = c1.list_line_id
and c.modifier_level_code = c1.modifier_level_code
and c.automatic_flag = c1.automatic_flag
and c1.list_header_id = p_List_Header_ID
and c.list_header_id = p_List_Header_ID
group by a.list_line_id, b.list_line_id
having count(b.list_line_id ) = ( select count(*)
                                                        from qp_pricing_attributes
                                                        where list_line_id = l_List_Line_ID)
and count(b.list_line_id) = ( select count(*)
                                             from qp_pricing_attributes
                                                where list_line_id = b.list_line_id)  ;


CURSOR get_rec_no_attr(l_List_Line_ID NUMBER ) is
select c.list_line_id col1, c1.list_line_id col2
from qp_list_lines c, qp_list_lines c1
where   c.list_line_id = l_List_Line_ID
and c1.list_line_id <> l_List_Line_ID
and c.list_line_type_code = c1.list_line_type_code
and c.modifier_level_code = c1.modifier_level_code
and c.automatic_flag = c1.automatic_flag
and c1.list_header_id = p_List_Header_ID
and c.list_header_id = p_List_Header_ID
and not exists (select list_line_id
                from qp_pricing_attributes
                where list_line_id = c1.list_line_id)
group by c.list_line_id, c1.list_line_id;

l_min_date date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date date := to_date('12/31/9999', 'MM/DD/YYYY');
l_sdate DATE;
l_edate DATE;
DUPLI_QUAL BOOLEAN := FALSE;
l_org_line NUMBER;
l_other_line NUMBER;
CT_DUPLI_QUAL NUMBER;
l_Attr_present NUMBER;
BEGIN


if p_product_attribute_context is null  then
oe_debug_pub.add('No attribute');
for rec in get_rec_no_attr(p_List_Line_ID)
    loop
  oe_debug_pub.add('No attribute in for loop');
  oe_debug_pub.add('col2 list_line_id' || rec.col2 );
l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');

CT_DUPLI_QUAL := 1;
DUPLI_QUAL  := FALSE;

Select count(*) into l_org_line from qp_qualifiers where list_line_id = rec.col1;

Select count(*) into l_other_line from qp_qualifiers where list_line_id = rec.col2;

if (l_org_line = 0 and l_other_line = 0) then

 DUPLI_QUAL := TRUE;

elsif(l_org_line = l_other_line) then

    Declare
       Cursor get_same_quals(l_list_id in Number) is
       select qualifier_id qual_id, list_header_id hdr_id from qp_qualifiers
       where list_line_id = l_list_id;
       CT_DUPLI_QUAL NUMBER;

    begin
       for rec1 in get_same_quals(rec.col1)
       loop

       Select count(*) into CT_DUPLI_QUAL
       from qp_qualifiers q1, qp_qualifiers q2
       where q1.qualifier_id = rec1.qual_id
         and q2.list_line_id = rec.col2
         and nvl(q1.qualifier_grouping_no, 0) = nvl(q2.qualifier_grouping_no, 0)
         and q1.qualifier_context = q2.qualifier_context
         and q1.qualifier_attribute = q2.qualifier_attribute
         and nvl(q1.qualifier_attr_value,' ') = nvl(q2.qualifier_attr_value,' ')
         and nvl(q1.qualifier_attr_value_to,' ') = nvl(q2.qualifier_attr_value_to,' ')
         and nvl(q1.comparison_operator_code,' ') = nvl(q2.comparison_operator_code,' ');

       oe_debug_pub.add('The count of duplicate qualifiers is '||CT_DUPLI_QUAL);

        if (CT_DUPLI_QUAL = 0) then -- the qualifiers are not same.

           oe_debug_pub.add('Count equal to zero');
          DUPLI_QUAL := FALSE;
            exit;
        end if;
        DUPLI_QUAL := TRUE;
        end loop;
   end;
end if;
if (DUPLI_QUAL = TRUE) then

l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');

        begin
            SELECT start_date_active, end_date_active
            into  l_sdate, l_edate
            from qp_list_lines
            where list_line_id = rec.col2;
        exception
            when no_data_found then null;
        end;


      IF ( nvl(p_Start_Date_Active, l_min_date) <= nvl(l_sdate, l_min_date))
        THEN
            l_min_date := nvl(p_Start_Date_Active, l_min_date);
        ELSE
            l_min_date := nvl(l_sdate, l_min_date);
      END IF;

     IF ( nvl(p_End_Date_Active, l_max_date) >= nvl(l_edate, l_max_date))
        THEN
            l_max_date := nvl(p_End_Date_Active, l_max_date);
        ELSE
            l_max_date := nvl(l_edate, l_max_date);
      END IF;

       IF ( trunc(nvl(l_sdate, l_min_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
                and trunc(nvl(p_End_Date_Active, l_max_date)) )
          OR
          ( trunc(nvl(l_edate, l_max_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
             and trunc(nvl(p_End_Date_Active, l_max_date)) )

          OR
          ( trunc(nvl(l_sdate, l_min_date)) <=
                   nvl(p_Start_Date_Active,l_min_date)
            AND
            trunc(nvl(l_edate, l_max_date)) >=
                   nvl(p_End_Date_Active,l_max_date) )

         THEN

                          oe_debug_pub.add('Found a Modifier line duplicate...' );
                                p_x_effdates := FALSE;
                                RETURN FALSE;


      END IF; --- Overlapping Dates.

end if; --- Qual dupli check
    end loop;

Else
oe_debug_pub.add('Attribute present');
    for rec in get_rec(p_List_Line_ID)
    loop

l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');
CT_DUPLI_QUAL := 1;
DUPLI_QUAL  := FALSE;

Select count(*) into l_org_line from qp_qualifiers where list_line_id = rec.col1;

Select count(*) into l_other_line from qp_qualifiers where list_line_id = rec.col2;

if (l_org_line = 0 and l_other_line = 0) then

 DUPLI_QUAL := TRUE;

elsif(l_org_line = l_other_line) then

    Declare
       Cursor get_same_quals(l_list_id in Number) is
       select qualifier_id qual_id, list_header_id hdr_id from qp_qualifiers
       where list_line_id = l_list_id;
       CT_DUPLI_QUAL NUMBER := 0;

    begin
      for rec1 in get_same_quals(rec.col1)
      loop

      Select count(*) into CT_DUPLI_QUAL
      from qp_qualifiers q1, qp_qualifiers q2
      where q1.qualifier_id = rec1.qual_id
         and q2.list_line_id = rec.col2
         and nvl(q1.qualifier_grouping_no, 0) = nvl(q2.qualifier_grouping_no, 0)
         and q1.qualifier_context = q2.qualifier_context
         and q1.qualifier_attribute = q2.qualifier_attribute
         and nvl(q1.qualifier_attr_value,' ') = nvl(q2.qualifier_attr_value,' ')
         and nvl(q1.qualifier_attr_value_to,' ') = nvl(q2.qualifier_attr_value_to,' ')
         and nvl(q1.comparison_operator_code,' ') = nvl(q2.comparison_operator_code,' ');

      oe_debug_pub.add('The count of duplicate qualifiers is '||CT_DUPLI_QUAL);

        if (CT_DUPLI_QUAL = 0) then -- the qualifiers are not same.

          oe_debug_pub.add('Count equal to zero');
          DUPLI_QUAL := FALSE;
            exit;
        end if;
        DUPLI_QUAL := TRUE;
      end loop;
   end;

end if;
if (DUPLI_QUAL = TRUE) then

l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');

        begin
            SELECT start_date_active, end_date_active
            into  l_sdate, l_edate
            from qp_list_lines
            where list_line_id = rec.col2;
        exception
            when no_data_found then null;
        end;


      IF ( nvl(p_Start_Date_Active, l_min_date) <= nvl(l_sdate, l_min_date))
        THEN
            l_min_date := nvl(p_Start_Date_Active, l_min_date);
        ELSE
            l_min_date := nvl(l_sdate, l_min_date);
      END IF;

     IF ( nvl(p_End_Date_Active, l_max_date) >= nvl(l_edate, l_max_date))
        THEN
            l_max_date := nvl(p_End_Date_Active, l_max_date);
        ELSE
            l_max_date := nvl(l_edate, l_max_date);
      END IF;

       IF ( trunc(nvl(l_sdate, l_min_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
                and trunc(nvl(p_End_Date_Active, l_max_date)) )
          OR
          ( trunc(nvl(l_edate, l_max_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
             and trunc(nvl(p_End_Date_Active, l_max_date)) )

          OR
          ( trunc(nvl(l_sdate, l_min_date)) <=
                   nvl(p_Start_Date_Active,l_min_date)
            AND
            trunc(nvl(l_edate, l_max_date)) >=
                   nvl(p_End_Date_Active,l_max_date) )

         THEN

                          oe_debug_pub.add('Found a Modifier line p attr duplicate...' );
                                p_x_effdates := FALSE;
                                RETURN FALSE;


      END IF; --- Overlapping Dates.

end if; --- Qual dupli check
    end loop;

 end if;


    p_x_rows := sql%rowcount;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_x_rows := sql%rowcount;
                p_x_effdates := TRUE;
          RETURN TRUE;

    WHEN OTHERS THEN
       p_x_rows := sql%rowcount;
                p_x_effdates := FALSE;
          RETURN FALSE;

END Mod_Dup;

-- end bug2091362

END QP_Validate_Pricing_Attr;

/
