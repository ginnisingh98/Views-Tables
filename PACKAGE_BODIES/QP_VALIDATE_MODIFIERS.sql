--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_MODIFIERS" AS
/* $Header: QPXLMLLB.pls 120.4.12010000.3 2009/06/23 06:46:49 smuhamme ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Modifiers';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_organization_id             NUMBER;
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_dummy_1                     VARCHAR2(1);
l_dummy_3                     VARCHAR2(1);
l_charge_type_subtype         VARCHAR2(1);
l_dummy_2                     VARCHAR2(3);
l_dummy_4                     VARCHAR2(3);
l_dummy_5                     NUMBER;
l_error_code                  NUMBER;
l_uom_code                    VARCHAR2(3);
l_list_type_code              VARCHAR2(30);
l_ask_for_flag                VARCHAR2(1);
l_start_date_active           DATE;
l_end_date_active             DATE;
l_phase_sequence              NUMBER;
l_primary_list_line_type_code VARCHAR2(30);
l_qp_accrual_uom_class        VARCHAR2(10);
l_qp_status                   VARCHAR2(1);
l_gsa_indicator               VARCHAR2(1);
l_arithmetic_operator         VARCHAR2(30);
l_list_line_type_code         VARCHAR2(30); -- Bug 2862465
l_qualification_ind           NUMBER; -- Bug 2862465
l_phase_price_evt             VARCHAR2(1):='N'; --Bug 2724502
l_phase_freeze_set            VARCHAR2(1):='N'; --Bug 1748272
l_modifier_level_code	      VARCHAR2(30); --Bug 2835156
l_rltd_exist                  VARCHAR2(1); --Bug 2835156
l_profile_pte_code            qp_list_headers_b.pte_code%type:=fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY');
l_profile_source_system_code  qp_list_headers_b.source_system_code%type := fnd_profile.value('QP_SOURCE_SYSTEM_CODE');
benefit_qty_t                             VARCHAR2(240); --Bug 8474533

BEGIN

oe_debug_pub.add('BEGIN Entity in QPXLMLLB');

    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_MODIFIERS_rec.list_header_id,
                             p_list_line_id   => p_MODIFIERS_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Check required attributes.

    IF  p_MODIFIERS_rec.list_line_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list line id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    IF p_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    THEN

       IF  p_old_MODIFIERS_rec.list_line_type_code IS NOT NULL
       AND p_old_MODIFIERS_rec.list_line_type_code <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIERS_rec.list_line_type_code <> p_MODIFIERS_rec.list_line_type_code
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_LIST_LINE_TYP');
        OE_MSG_PUB.Add;

       END IF;

       IF  p_old_MODIFIERS_rec.modifier_level_code IS NOT NULL
       AND p_old_MODIFIERS_rec.modifier_level_code <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIERS_rec.modifier_level_code <> p_MODIFIERS_rec.modifier_level_code
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_MOD_LVL');
        OE_MSG_PUB.Add;

       END IF;

       IF  p_old_MODIFIERS_rec.list_line_no IS NOT NULL
       AND p_old_MODIFIERS_rec.list_line_no <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIERS_rec.list_line_no <> p_MODIFIERS_rec.list_line_no
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_LIST_LINE_NO');
        OE_MSG_PUB.Add;

       END IF;
       IF  (p_old_MODIFIERS_rec.proration_type_code IS NOT NULL  OR
            p_old_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE')
       AND nvl(p_old_MODIFIERS_rec.proration_type_code,'X') <> nvl(p_MODIFIERS_rec.proration_type_code,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Proration Type Code');

        OE_MSG_PUB.Add;

       END IF;
     END IF;


	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN

        BEGIN


	    SELECT LIST_TYPE_CODE, ASK_FOR_FLAG, START_DATE_ACTIVE, END_DATE_ACTIVE,GSA_INDICATOR
	    INTO   l_list_type_code, l_ask_for_flag, l_start_date_active, l_end_date_active, l_gsa_indicator
         FROM   QP_LIST_HEADERS_B
         WHERE  LIST_HEADER_ID = p_MODIFIERS_rec.list_header_id;

         EXCEPTION
          WHEN NO_DATA_FOUND THEN
          null;

       END;

     END IF;


oe_debug_pub.add('11');

/*   List Line Type Code is mandatory and these are the types applicable for Modifiers  */

     IF  p_MODIFIERS_rec.list_line_type_code IS NULL
     THEN

oe_debug_pub.add('list line type code manda');
        l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('LIST_LINE_TYPE_CODE'));  -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

     END IF;

  IF  l_gsa_indicator IS NULL
  THEN

     l_qp_status := QP_UTIL.GET_QP_STATUS;

     IF     ( l_qp_status = 'I' AND
              p_MODIFIERS_rec.list_line_type_code <> 'DIS' AND
              p_MODIFIERS_rec.list_line_type_code <> 'CIE' AND
              p_MODIFIERS_rec.list_line_type_code <> 'OID' AND
              p_MODIFIERS_rec.list_line_type_code <> 'PRG' AND
              p_MODIFIERS_rec.list_line_type_code <> 'RLTD' AND
              p_MODIFIERS_rec.list_line_type_code <> 'TSN' AND
              p_MODIFIERS_rec.list_line_type_code <> 'SUR' AND
              p_MODIFIERS_rec.list_line_type_code <> 'PBH' AND
              p_MODIFIERS_rec.list_line_type_code <> 'PMR' AND
              p_MODIFIERS_rec.list_line_type_code <> 'FREIGHT_CHARGE' AND
              p_MODIFIERS_rec.list_line_type_code <> 'IUE' )
     THEN


oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_LINE_TYPE');
        OE_MSG_PUB.Add;

     END IF;

-- For bug 2363065, raise the error in basic pricing if not called from FTE
	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
       IF     ( l_qp_status = 'S' AND
                QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE <> 'FTE' AND
                 p_MODIFIERS_rec.list_line_type_code <> 'DIS' AND
                 p_MODIFIERS_rec.list_line_type_code <> 'PBH' AND
                 p_MODIFIERS_rec.list_line_type_code <> 'SUR' AND
                 p_MODIFIERS_rec.list_line_type_code <> 'FREIGHT_CHARGE')
       THEN


oe_debug_pub.add('list line type code invalid');
           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_LINE_TYPE');
           OE_MSG_PUB.Add;

        END IF;
      END IF;

  END IF;

   IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
    IF    l_gsa_indicator = 'Y'
    AND   p_MODIFIERS_rec.list_line_type_code <> 'DIS'
    THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_LINE_TYPE');
           OE_MSG_PUB.Add;

    END IF;
   END IF;


	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
       IF  p_MODIFIERS_rec.from_rltd_modifier_id IS NOT NULL
       AND  p_MODIFIERS_rec.to_rltd_modifier_id IS NOT NULL
	  THEN

         BEGIN
	      SELECT LIST_LINE_TYPE_CODE
	      INTO   l_primary_list_line_type_code
	      FROM   QP_LIST_LINES
	      WHERE  LIST_LINE_ID = p_MODIFIERS_rec.from_rltd_modifier_id;

         EXCEPTION
	      WHEN NO_DATA_FOUND THEN
           null;

         END;

       END IF;

/*   Validate that the Modifier type period is within the the Modifier period */

       IF    l_start_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.start_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.start_date_active < l_start_date_active
	  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_MOD_DATES_WITHIN_MODLIST');
            OE_MSG_PUB.Add;

       END IF;

       IF    l_end_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.end_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.end_date_active > l_end_date_active
	  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_MOD_DATES_WITHIN_MODLIST');
            OE_MSG_PUB.Add;

       END IF;

       IF    l_start_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.end_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.end_date_active < l_start_date_active
	  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_MOD_DATES_WITHIN_MODLIST');
            OE_MSG_PUB.Add;

       END IF;

       IF    l_end_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.start_date_active IS NOT NULL
       AND   p_MODIFIERS_rec.start_date_active > l_end_date_active
	  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_MOD_DATES_WITHIN_MODLIST');
            OE_MSG_PUB.Add;

       END IF;
	END IF; -- list_line_type_code <> 'PMR'


/*   The only list_line_type_code applicable for CHARGES is FREIGHT_CHARGE  */

     IF   (l_list_type_code = 'CHARGES'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'FREIGHT_CHARGE')
     OR   (p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE'
     AND  l_list_type_code <> 'CHARGES')
	THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_FRT_CHRG_ALLOW_CHRGS');
            OE_MSG_PUB.Add;

     END IF;

/*   If Ask_For_Flag is entered, list_line_no is mandatory for these list types  */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'IUE' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.list_line_no IS NULL AND
          l_ask_for_flag = 'Y'

     THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_LIST_NO_MAND_IF_ASK_FOR');
            OE_MSG_PUB.Add;

	END IF;

/*   List_line_no is mandatory for Coupon Issue  */

     IF   p_MODIFIERS_rec.list_line_type_code = 'CIE'  AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.list_line_no IS NULL

     THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_LIST_NO_MAND_FOR_CIE');
            OE_MSG_PUB.Add;

	END IF;

--dbms_output.put_line('1');
oe_debug_pub.add('22');

/*   Automatic Flag is mandatory for these Modifier types */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'CIE' OR
          p_MODIFIERS_rec.list_line_type_code = 'IUE' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN' OR
          p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.automatic_flag is NULL

     THEN
oe_debug_pub.add('auto flag mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('AUTOMATIC_FLAG'));   -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

	END IF;

	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
       IF  p_MODIFIERS_rec.automatic_flag IS NOT NULL
       AND  p_MODIFIERS_rec.automatic_flag <> 'Y'
	  AND  p_MODIFIERS_rec.automatic_flag <> 'N'
       THEN

oe_debug_pub.add('auto flag invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_AUTO_FLAG_Y_OR_N');
          OE_MSG_PUB.Add;

	  END IF;

/* Automatic flag is mandatory for all Benefit lines   */

       IF   p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
       AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL
       AND  p_MODIFIERS_rec.automatic_flag IS NULL
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('AUTOMATIC_FLAG'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

       END IF;

/*   Automatic Flag must be Y for OID, PRG, CIE and PBH   */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          --p_MODIFIERS_rec.list_line_type_code = 'PBH' OR -- changes made by spgopal to allow manual breaks bug 1407684
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'CIE' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.automatic_flag <> 'Y'

     THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_AUTO_FLAG_MUST_BE_Y');
            OE_MSG_PUB.Add;

	END IF;

/*   Only Discount, Surcharge and Freight Charge can be manual or automatic. Other Discount types can always be automatic   */
/* changes by spgopal bug 1407648 manual overrideable price breaks are allowed R11 functionality*/

     IF ( p_MODIFIERS_rec.list_line_type_code <> 'DIS' AND
          p_MODIFIERS_rec.list_line_type_code <> 'SUR' AND
          p_MODIFIERS_rec.list_line_type_code <> 'PBH' AND
          p_MODIFIERS_rec.list_line_type_code <> 'FREIGHT_CHARGE' AND
          p_MODIFIERS_rec.automatic_flag = 'N' )

     THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_DIS_SUR_FREIGHT_MANUAL');
            OE_MSG_PUB.Add;

	END IF;

     END IF; -- list_line_type_code <> 'PMR'

--dbms_output.put_line('2');
oe_debug_pub.add('33');

/*   Modifier Level Code is mandatory for all list lines except for Price Modifier and related*/

	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR'
	AND  p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
	THEN
       IF  p_MODIFIERS_rec.modifier_level_code IS NULL
       THEN

oe_debug_pub.add('modifier level manda');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('MODIFIER_LEVEL_CODE')); --Fix For Bug-1974413
            OE_MSG_PUB.Add;


	  ELSIF (p_MODIFIERS_rec.modifier_level_code = 'ORDER'
			AND p_MODIFIERS_rec.pricing_group_sequence IS NOT NULL
                           AND QP_UTIL.get_qp_status = 'I') THEN
 		--Order level modifiers must have null pricing group sequence(bucket)
		--added on request by jholla due to invoicing problems in OM for orde
		--level modifiers
               /* Bug 1957062 Check Bypassed for Basic Pricing */

          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_ORD_LVL_NULL_BUCKET');
          OE_MSG_PUB.Add;


/*   Modifier Level Code can be LINE, ORDER or LINEGROUP  */

       ELSIF  ( p_MODIFIERS_rec.modifier_level_code <> 'LINE'  AND
                p_MODIFIERS_rec.modifier_level_code <> 'ORDER' AND
                p_MODIFIERS_rec.modifier_level_code <> 'LINEGROUP' )
       THEN

oe_debug_pub.add('modifier level invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN_LNGRP_OR_ORD');
          OE_MSG_PUB.Add;

	  END IF;

/*   Modifier Level Code can be LINE or ORDER for list line type of Freight Charge and Terms Substitution */

       IF   ( p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE'
	  OR     p_MODIFIERS_rec.list_line_type_code = 'TSN')
	  AND    p_MODIFIERS_rec.modifier_level_code <> 'LINE'
	  AND    p_MODIFIERS_rec.modifier_level_code <> 'ORDER'
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN_OR_ORD');
          OE_MSG_PUB.Add;

	  END IF;

/*   Modifier Level Code can be LINE or LINEGROUP for list line type of Price Break Header and Other Item Discount */

       IF     ( p_MODIFIERS_rec.list_line_type_code = 'PBH'
	  OR       p_MODIFIERS_rec.list_line_type_code = 'OID')
       AND      p_MODIFIERS_rec.modifier_level_code <> 'LINE'
	  AND      p_MODIFIERS_rec.modifier_level_code <> 'LINEGROUP'
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          IF QP_UTIL.get_qp_status = 'I' THEN
	      FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN_OR_LNGRP');
	  ELSE
	      FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN');
	  END IF;
          OE_MSG_PUB.Add;

	  END IF;

/*   Modifier Level Code can be LINE for list line type of Item Upgrade  */

       IF       p_MODIFIERS_rec.list_line_type_code = 'IUE'
       AND      p_MODIFIERS_rec.modifier_level_code <> 'LINE'
			 THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN');
          OE_MSG_PUB.Add;

	  END IF;

/*   Modifier Level Code can be LINE for GSA discounts */

       IF  l_gsa_indicator = 'Y'
       AND p_MODIFIERS_rec.modifier_level_code <> 'LINE'
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_MOD_LVL_LN');
          OE_MSG_PUB.Add;

	  END IF;

    END IF; -- list_line_type_code <> 'PMR' and list_line_type_code <> 'RLTD'


    IF  (p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
         p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
         p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE') AND
         p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
         p_MODIFIERS_rec.operand IS NULL AND
         p_MODIFIERS_rec.price_by_formula_id IS NULL
    THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICE_BY_FORMULA_ID')); -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

    END IF;

/* Arithmetic Operator is mandatory for these Qualifier list lines */

oe_debug_pub.add('44');
	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
       IF  (p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
            p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
            p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE') AND
            p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
            p_MODIFIERS_rec.arithmetic_operator IS NULL
       THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('ARITHMETIC_OPERATOR')); -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

       END IF;

/* Arithmetic Operator is mandatory for these Benefit list lines */

            oe_debug_pub.add('list line = '||p_MODIFIERS_rec.list_line_type_code);
            oe_debug_pub.add('group type = '||p_MODIFIERS_rec.rltd_modifier_grp_type);
            oe_debug_pub.add('arithme oper = '||p_MODIFIERS_rec.arithmetic_operator);


       IF   p_MODIFIERS_rec.list_line_type_code <> 'PRG'  AND
            p_MODIFIERS_rec.list_line_type_code <> 'RLTD' AND
            p_MODIFIERS_rec.list_line_type_code <> 'CIE' AND
            p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL AND
            p_MODIFIERS_rec.arithmetic_operator IS NULL
       THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('ARITHMETIC_OPERATOR')); -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

       END IF;

/* For Order level discounts, only lumpsum is allowed for Freight Charge     */

       IF   p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE'  AND
            p_MODIFIERS_rec.modifier_level_code = 'ORDER' AND
            p_MODIFIERS_rec.arithmetic_operator <> 'LUMPSUM'
       THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_LUMPSUM_FOR_ORDER');
            OE_MSG_PUB.Add;

       END IF;

/*   Arithmetic Operators applicable  for list line type FREIGHT_CHARGE are % and AMT modified by spgopal also lumpsum for freight charge at line level*/

       IF  ( p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
            p_MODIFIERS_rec.modifier_level_code <> 'ORDER' AND
                p_MODIFIERS_rec.arithmetic_operator <> '%' AND
                p_MODIFIERS_rec.arithmetic_operator <> 'LUMPSUM' AND
                p_MODIFIERS_rec.arithmetic_operator <> 'AMT' )
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_DIS_PERCNT_OR_AMT');
          OE_MSG_PUB.Add;

       END IF;

/* For Order level discounts, only % is allowed for all discounts except for Freight Charge     */

       IF   p_MODIFIERS_rec.list_line_type_code <> 'FREIGHT_CHARGE'  AND
            p_MODIFIERS_rec.modifier_level_code = 'ORDER' AND
            p_MODIFIERS_rec.arithmetic_operator <> '%'
       THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_PERCENT_FOR_ORDER');
            OE_MSG_PUB.Add;

       END IF;

/* Operand is mandatory for these Benefit list lines */

            oe_debug_pub.add('list line = '||p_MODIFIERS_rec.list_line_type_code);
            oe_debug_pub.add('group type = '||p_MODIFIERS_rec.rltd_modifier_grp_type);
            oe_debug_pub.add('operand = '||to_char(p_MODIFIERS_rec.operand));
            oe_debug_pub.add('formula = '||to_char(p_MODIFIERS_rec.price_by_formula_id));

       IF   p_MODIFIERS_rec.list_line_type_code <> 'PRG' AND
            p_MODIFIERS_rec.list_line_type_code <> 'RLTD' AND
            p_MODIFIERS_rec.list_line_type_code <> 'CIE' AND
            p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL AND
            p_MODIFIERS_rec.operand IS NULL AND
            p_MODIFIERS_rec.price_by_formula_id IS NULL
       THEN

oe_debug_pub.add('arith op mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICE_BY_FORMULA_ID')); -- Fix For Bug-1974413
            OE_MSG_PUB.Add;

       END IF;


/*   Arithmetic Operator can only be NEWPRICE for GSA Discounts   */

       IF  l_gsa_indicator = 'Y'
       AND p_MODIFIERS_rec.arithmetic_operator <> 'NEWPRICE'
	  THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_GSA_NEWPRICE_ONLY');
          OE_MSG_PUB.Add;

       END IF;

/*   Arithmetic Operator can be %, AMT or NEWPRICE  */

       IF  ( p_MODIFIERS_rec.arithmetic_operator IS NOT NULL AND
                p_MODIFIERS_rec.arithmetic_operator <> '%'  AND
                p_MODIFIERS_rec.arithmetic_operator <> 'AMT' AND
                p_MODIFIERS_rec.arithmetic_operator <> 'NEWPRICE' AND
		p_MODIFIERS_rec.arithmetic_operator <> 'BREAKUNIT_PRICE' AND
		p_MODIFIERS_rec.arithmetic_operator <> 'BLOCK_PRICE' AND
                p_MODIFIERS_rec.arithmetic_operator <> 'LUMPSUM' )
       THEN

oe_debug_pub.add('arith op invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_DIS_PERCNT_AMT_OR_NEWPRICE');
          OE_MSG_PUB.Add;

        END IF;
	END IF; -- list_line_type_code <> 'PMR'

--dbms_output.put_line('4');

/* Override Flag is mandatory for these Qualifier list lines */

	IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN

     IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'IUE' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN' OR
          p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.override_flag is NULL

     THEN


oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('OVERRIDE_FLAG')); -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;

/*   Override Flag can be Y or N   */

     IF  ( p_MODIFIERS_rec.override_flag IS NOT NULL AND
           p_MODIFIERS_rec.override_flag <> 'Y' AND
           p_MODIFIERS_rec.override_flag <> 'N' )
     THEN

oe_debug_pub.add('override flag invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_OVERRIDE_FLAG_Y_OR_N');
          OE_MSG_PUB.Add;

	END IF;

/* Override flag is mandatory for all Benefit lines   */

     IF   p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
     AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL
     AND  p_MODIFIERS_rec.override_flag IS NULL
     THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('OVERRIDE_FLAG'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

     END IF;

/*   Override Flag must be N for OID, PRG, CIE */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'OID' OR
        --  p_MODIFIERS_rec.list_line_type_code = 'PBH' OR -- changed by spgopal
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'CIE' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.override_flag <> 'N'

     THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_OVERRIDE_FLAG_MUST_BE_N');
            OE_MSG_PUB.Add;


	END IF;


/* PBH modifiers can be manual and overrideable
   changes made by spgopal for bug 1407684	*/

/* Print on invoice Flag is mandatory for these Qualifier list lines */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH' ) AND
	     p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.print_on_invoice_flag is NULL

     THEN


oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRINT_ON_INVOICE_FLAG'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;

/*   Prine on Invoice Flag can be Y or N   */

     IF  ( p_MODIFIERS_rec.print_on_invoice_flag IS NOT NULL AND
           p_MODIFIERS_rec.print_on_invoice_flag <> 'Y' AND
           p_MODIFIERS_rec.print_on_invoice_flag <> 'N' )
     THEN

oe_debug_pub.add('print flag invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_PRNT_INV_FLAG_Y_OR_N');
          OE_MSG_PUB.Add;

	END IF;


	END IF; --If list_line_type_code <> 'PMR'

--dbms_output.put_line('5');

/*   End Date must be after the Start Date    */

      IF  nvl( p_MODIFIERS_rec.start_date_active,to_date('01/01/1951','mm/dd/yyyy')) >
          nvl( p_MODIFIERS_rec.end_date_active,to_date('12/31/9999','mm/dd/yyyy'))
      THEN

oe_debug_pub.add('start date after end date');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
        OE_MSG_PUB.Add;

      END IF;

--dbms_output.put_line('6');

/*   Substitution Context, Attribute and Value is mandatory for list line type of Term Substitution  */

    IF  p_MODIFIERS_rec.list_line_type_code = 'TSN'
    THEN

      IF  p_MODIFIERS_rec.substitution_context IS NULL
      OR  p_MODIFIERS_rec.substitution_attribute IS NULL
      OR  p_MODIFIERS_rec.substitution_value IS NULL
      THEN

oe_debug_pub.add('sub con, attr, value mand');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Terms Attr and Terms Value');
        OE_MSG_PUB.Add;

      END IF;

oe_debug_pub.add('before valida subs');
 oe_debug_pub.add('context = '||p_MODIFIERS_rec.substitution_context);
 oe_debug_pub.add('attr = '||p_MODIFIERS_rec.substitution_attribute);
 oe_debug_pub.add('value = '||p_MODIFIERS_rec.substitution_value);

/*   Validating the Substitution Context, Attribute and Value  */

       QP_UTIL.validate_qp_flexfield(flexfield_name     =>'QP_ATTR_DEFNS_QUALIFIER'
						 ,context         =>p_MODIFIERS_rec.substitution_context
						 ,attribute       =>p_MODIFIERS_rec.substitution_attribute
						 ,value           =>p_MODIFIERS_rec.substitution_value
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_flag
						 ,attribute_flag                 =>l_attribute_flag
						 ,value_flag                     =>l_value_flag
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

oe_debug_pub.add('error code = '||to_char(l_error_code));

       If (l_context_flag = 'N'  AND l_error_code = 7)       --  invalid context
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_SUBSTITUTION_CONT'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;

       If (l_attribute_flag = 'N'  AND l_error_code = 8)       --  invalid attribute
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_SUBSTITUTION_ATTR'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;

       If (l_value_flag = 'N'  AND l_error_code = 9)       --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_SUBSTITUTION_VALUE'  );
               OE_MSG_PUB.Add;
            END IF;

       End If;

    END IF; --list_line_type_code = 'TSN'

--dbms_output.put_line('7');

/*   Inventory Item Id, Organization Id, Related Item Id and Relationship Type are mandatory for list line typr of Item Upgrade */

oe_debug_pub.add('inven item = '|| p_MODIFIERS_rec.inventory_item_id);
oe_debug_pub.add('org = '|| p_MODIFIERS_rec.organization_id);
oe_debug_pub.add('related item = '|| p_MODIFIERS_rec.related_item_id);
oe_debug_pub.add('relate = '|| p_MODIFIERS_rec.relationship_type_id);

    IF  p_MODIFIERS_rec.list_line_type_code = 'IUE'
    THEN

      IF  p_MODIFIERS_rec.inventory_item_id IS NULL
      OR  p_MODIFIERS_rec.organization_id IS NULL
      OR  p_MODIFIERS_rec.related_item_id IS NULL
      OR  p_MODIFIERS_rec.relationship_type_id IS NULL
      THEN

oe_debug_pub.add('itm , org, related item and rrelationship type manda');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Prod Attr Value and Upgrade Item');
        OE_MSG_PUB.Add;

      ELSE

	   BEGIN

/*   Validating Inventory Item Id, Organization Id, Related Item Id and Relationship Type */

	   select 'X'
	   into   l_dummy_3
	   from   mtl_related_items_all_v
        where  inventory_item_id = p_MODIFIERS_rec.inventory_item_id
        and    organization_id = p_MODIFIERS_rec.organization_id
        and    related_item_id = p_MODIFIERS_rec.related_item_id
        and    relationship_type_id = 14;

        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
oe_debug_pub.add('item upgrade data is invalid');

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_INVALID_ITEM_UPGRD');
        OE_MSG_PUB.Add;

        END;

      END IF;

    END IF; --list_line_type_code = 'IUE'

oe_debug_pub.add('55');
--dbms_output.put_line('55');

--dbms_output.put_line('8');

/*  THE CODE BELOW CHANGED BY SPGOPAL === 05/15/00  FOR REASONS AS MENTIONED  */

/*   Formula is applicable only at line level for list line type of Discount, Surcharge and Freight Charge*/
/*Formula is applicable for order level freight charge, fix for bug 1527285*/

    IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
      IF  p_MODIFIERS_rec.price_by_formula_id IS NOT NULL
	 THEN
        IF p_MODIFIERS_rec.modifier_level_code IN ('ORDER', 'LINE')
	   AND p_MODIFIERS_rec.list_line_type_code NOT IN ('DIS', 'SUR', 'FREIGHT_CHARGE') THEN

	   --dbms_output.put_line('formula id is applicable with DIS,SUR ');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_DIS_SUR_OR_FRT_FOR_FORMULA');
        OE_MSG_PUB.Add;

        END IF;

  /* The Get Condition of OID and PRG cannot have formula attached to it  */

        IF   ((l_primary_list_line_type_code = 'OID'
        OR   l_primary_list_line_type_code = 'PRG')
        AND  p_MODIFIERS_rec.rltd_modifier_grp_type = 'BENEFIT')
        THEN

           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_FORMULA_NOT_IN_GET');
           OE_MSG_PUB.Add;

       END IF;

/*  THE CODE BELOW CHANGED BY SPGOPAL === 05/15/00  FOR REASONS AS MENTIONED  */


/*   The Arithmetic Operators applicable when a Formula is given are % and AMT and new price. New price was added to fix bug 1530483
There is a problem with Freight Charge set up. Freight Charge modifier type requires arithmetic operator LUMPSUM in addition to % and AMT
*/

        IF  p_MODIFIERS_rec.arithmetic_operator <> '%'
        AND p_MODIFIERS_rec.arithmetic_operator <> 'AMT'
        AND p_MODIFIERS_rec.arithmetic_operator <> 'LUMPSUM'
	   AND p_MODIFIERS_rec.arithmetic_operator <> 'NEWPRICE'
        THEN

	   --dbms_output.put_line('arith op can be % or AMT with formula');
oe_debug_pub.add('arith oper % or AMT invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_DIS_PERCNT_OR_AMT');
          OE_MSG_PUB.Add;

        END IF;

--dbms_output.put_line('9');

	   BEGIN

/*   Validating the Formula   */

	   select 'X'
	   into   l_dummy_1
	   from   qp_price_formulas_b
	   where  price_formula_id = p_MODIFIERS_rec.price_by_formula_id;
-- mkarya for bug 1906545, formula and operand are no more mutually exclusive
-- also formula having a line with line type 'LP' is also allowed
/*
	   and    not exists ( select price_formula_line_type_code
					   from   qp_price_formula_lines
					   where  price_formula_id = p_MODIFIERS_rec.price_by_formula_id
					   and    price_formula_line_type_code = 'LP' );
*/
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   --dbms_output.put_line('invalid formula id');
oe_debug_pub.add('formula id is invalid');

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_FORMULA_NOT_FOUND');
        OE_MSG_PUB.Add;

        END;
      END IF; --price_by_formula_id IS NOT NULL

/*   Operand is not allowed when a Formula is given     */
-- mkarya for bug 1906545, formula and operand are no more mutually exclusive
/*
      IF  p_MODIFIERS_rec.price_by_formula_id IS NOT NULL
      AND  p_MODIFIERS_rec.operand IS NOT NULL
	 THEN

	   --dbms_output.put_line('no operand if formula is given = '|| to_char(p_MODIFIERS_rec.operand));
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_OPERAND_OR_FORMULA');
          OE_MSG_PUB.Add;
      END IF;
*/

oe_debug_pub.add('77');
    END IF; --If list_line_type_code <> 'PMR'

/*   Price Break Type Code is mandatory for list line type of Price Break Header */

    IF  p_MODIFIERS_rec.list_line_type_code = 'PBH'
    THEN

      IF  p_MODIFIERS_rec.price_break_type_code IS NULL
      THEN

oe_debug_pub.add('price brek type is manda');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICE_BREAK_TYPE_CODE'));  --Fix For Bug-1974413
        OE_MSG_PUB.Add;

      END IF;

    END IF; --list_line_type_code = 'PBH'
--dbms_output.put_line('10');

/*   Valid values of Price Break Type Code are Point,Range and RECURRING     */

    IF p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
      IF  p_MODIFIERS_rec.price_break_type_code IS NOT NULL
      AND p_MODIFIERS_rec.price_break_type_code <> 'POINT'
      AND p_MODIFIERS_rec.price_break_type_code <> 'RANGE'
      AND p_MODIFIERS_rec.price_break_type_code <> 'RECURRING'
      THEN

oe_debug_pub.add('price brek type can be point or range');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_PRCBRK_POINT_OR_RANGE');
        OE_MSG_PUB.Add;

      END IF;


/* Recurring allowed only for these Qualifier list line types  */

      IF  p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL THEN
        IF ( p_MODIFIERS_rec.list_line_type_code <> 'DIS' AND
          p_MODIFIERS_rec.list_line_type_code <> 'SUR' AND
          p_MODIFIERS_rec.list_line_type_code <> 'PRG' AND
          p_MODIFIERS_rec.list_line_type_code <> 'CIE') AND
          p_MODIFIERS_rec.price_break_type_code = 'RECURRING'

        THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_RECURRING_NOT_ALLOWED');
          OE_MSG_PUB.Add;

        END IF;
      END IF;

/* Lumpsum is mandatory for DIS and SUR Qualifier list lines if they are recurring */

      IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
           p_MODIFIERS_rec.list_line_type_code = 'SUR') AND
           p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
           p_MODIFIERS_rec.price_break_type_code = 'RECURRING' AND
           p_MODIFIERS_rec.arithmetic_operator <> 'LUMPSUM'

      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_LUMPSUM_RECUR_DIS_SUR');
        OE_MSG_PUB.Add;

      END IF;

/* The only price break types allowed for a Qualifier list line are Point and Recurring */

      IF   p_MODIFIERS_rec.price_break_type_code IS NOT NULL
	 THEN
        IF p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
           p_MODIFIERS_rec.list_line_type_code <> 'PBH' AND
           p_MODIFIERS_rec.price_break_type_code <> 'POINT' AND
           p_MODIFIERS_rec.price_break_type_code <> 'RECURRING'

        THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_BREAK_TYPE_POINT_OR_RECUR');
          OE_MSG_PUB.Add;

        END IF;
      END IF;

/* The only price break types allowed for Price Break child lines are Point and Range */

      IF   p_MODIFIERS_rec.price_break_type_code IS NOT NULL
	 THEN
        IF l_primary_list_line_type_code = 'PBH'AND
           p_MODIFIERS_rec.price_break_type_code <> 'POINT' AND
           p_MODIFIERS_rec.price_break_type_code <> 'RANGE'

        THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_BREAK_TYPE_POINT_OR_RANGE');
          OE_MSG_PUB.Add;

        END IF;
      END IF;

/* Recurring not allowed on Benefit list line  Except Coupons (Bug - 2037842)  */

      IF p_MODIFIERS_rec.list_line_type_code <> 'RLTD' AND
         (p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL AND
        p_MODIFIERS_rec.rltd_modifier_grp_type <> 'COUPON') -- Bug 2037842
         AND
         p_MODIFIERS_rec.price_break_type_code = 'RECURRING'

      THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_RECURRING_NOT_ALLOWED');
          OE_MSG_PUB.Add;

      END IF;
    END IF; --list_line_type_code <> 'PMR'

--dbms_output.put_line('11');
oe_debug_pub.add('88');

/*   Product Precedence is mandatory for the  Primary discount lines of type Other Item Discount, Price Break Header and Item Upgrade */

    IF    p_MODIFIERS_rec.list_line_type_code <> 'PMR'
    AND   p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
    THEN
      IF   p_MODIFIERS_rec.list_line_type_code = 'OID'
      OR   p_MODIFIERS_rec.list_line_type_code = 'PBH'
      OR   p_MODIFIERS_rec.list_line_type_code = 'IUE'
      THEN

        IF   p_MODIFIERS_rec.product_precedence IS NULL
        THEN

oe_debug_pub.add('prece 11 ');
	   --dbms_output.put_line('product precedence is mandatory for primary');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_PRECEDENCE'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

        END IF;

      END IF;

    END IF;

oe_debug_pub.add('99');

/* Benefit Price List is mandatory for the benefit DIS line of PRG    */
oe_debug_pub.add('benefit = '||to_char( p_MODIFIERS_rec.benefit_price_list_line_id));

    IF   p_MODIFIERS_rec.list_line_type_code = 'DIS'
    AND  l_primary_list_line_type_code = 'PRG'
    AND  p_MODIFIERS_rec.benefit_price_list_line_id IS NULL
    THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Get Price');
          OE_MSG_PUB.Add;

    END IF;

/* JULIN (2738479): PRG benefit price list lines cannot be based on lines whose arithmetic_operator is BLOCK_PRICE or PERCENT_PRICE. */
/* jhkuo (2853657,2862465): PRG benefit price list lines now cannot be based on any service items
   or any price break headers (and child lines).
*/

oe_debug_pub.add('benefit = '||to_char( p_MODIFIERS_rec.benefit_price_list_line_id));

    IF   l_primary_list_line_type_code = 'PRG'
    AND  p_MODIFIERS_rec.benefit_price_list_line_id IS NOT NULL
    THEN

      select arithmetic_operator, list_line_type_code, qualification_ind
      into   l_arithmetic_operator, l_list_line_type_code, l_qualification_ind
      from   qp_list_lines
      where  list_line_id = p_MODIFIERS_rec.benefit_price_list_line_id;

      IF l_arithmetic_operator = 'PERCENT_PRICE' OR
         l_list_line_type_code = 'PBH' OR
         (l_list_line_type_code <> 'PBH' AND l_qualification_ind NOT IN (2,4,6,8,10,12,14,20,22,28,30))
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_GET_PRICE_LIST_LINE');
        OE_MSG_PUB.Add;
      END IF;


    END IF;

--dbms_output.put_line('12');

/*   If a Price Break Header,Coupon Issue and Discount is accrued, it is mandatory to give Expiration Date or both Number of Expiration Periods and Expiration Period UOM  */

    IF   p_MODIFIERS_rec.list_line_type_code = 'CIE'
    OR  (p_MODIFIERS_rec.list_line_type_code = 'DIS'
    AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL )
    THEN

 	 IF   p_MODIFIERS_rec.accrual_flag = 'Y'
	 THEN


        IF   p_MODIFIERS_rec.expiration_date IS NOT NULL
	   THEN

         IF   p_MODIFIERS_rec.number_expiration_periods IS NOT NULL
         OR   p_MODIFIERS_rec.expiration_period_uom IS NOT NULL
	    THEN

	   --dbms_output.put_line('either exp date or other 2 values');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_EXP_DATE_OR_EXP_PERIODS');
          OE_MSG_PUB.Add;

         END IF;
        END IF;

/*   Number Expiratiob Periods and Expiration Peirod UOM must both be entered */

        IF   ((p_MODIFIERS_rec.number_expiration_periods IS NOT NULL
        AND   p_MODIFIERS_rec.expiration_period_uom IS NULL )
	   OR
             ( p_MODIFIERS_rec.number_expiration_periods IS NULL
        AND   p_MODIFIERS_rec.expiration_period_uom IS NOT NULL ))
	   THEN

	   --dbms_output.put_line('all these 3 values are mandatory');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_EXP_UOM_NUM_STRTDT_MAND');
          OE_MSG_PUB.Add;

        END IF;

        IF p_MODIFIERS_rec.expiration_period_uom IS NOT NULL
	   THEN

	    BEGIN

/*   Validating Expiration Period UOM */

      	   select uom_code
	        into   l_uom_code
	        from   mtl_units_of_measure
	        where  uom_class = 'Time'
	        and    uom_code  = p_MODIFIERS_rec.expiration_period_uom;

         EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	   --dbms_output.put_line('invalid exp uom');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_INVALID_PERIOD_UOM');
          OE_MSG_PUB.Add;

         END;

        END IF;
      END IF; --Accrual_flag = 'Y'
   END IF;

--dbms_output.put_line('13');

/*   Estimated GL value is applicable only for Coupons, Item Upgrade, Terms Substitution and Other Item Discount */
     IF p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
       IF   p_MODIFIERS_rec.list_line_type_code <> 'CIE'
       AND   p_MODIFIERS_rec.list_line_type_code <> 'IUE'
       AND   p_MODIFIERS_rec.list_line_type_code <> 'TSN'
       AND   p_MODIFIERS_rec.list_line_type_code <> 'OID'   --Added for the bug 2589815
       AND  p_MODIFIERS_rec.estim_gl_value IS NOT NULL

       THEN

	   --dbms_output.put_line('estim gl value only for coupons');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_GL_VAL_FOR_CIE_IUE_TSN');
          OE_MSG_PUB.Add;

       END IF;
     END IF; -- list_line_type_code <> 'PMR'


/*   For Accruals, it is mandatory to give Estimated Accrual Rate  */

      IF    p_MODIFIERS_rec.accrual_flag = 'Y'
      AND   p_MODIFIERS_rec.estim_accrual_rate IS NULL

      THEN

	   --dbms_output.put_line('estim accrual rate is mand for coupons or accrual');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('ESTIM_ACCRUAL_RATE'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

      END IF;

/*   Charge Type and Charge Subtype are mandatory for list line type of Freight Charge */

      IF    p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE'
	 THEN

        IF    p_MODIFIERS_rec.charge_type_code IS NULL
	   THEN

	   --dbms_output.put_line('charge tyep and subtype mand for freight charge');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Charge Name');
          OE_MSG_PUB.Add;

        END IF;

	    BEGIN

/*    Validating Charge Type and Charge Subtype
      Added the validation for freight and spl. charges Bug#4562869   */
        IF (l_profile_pte_code = 'PO' and l_profile_source_system_code = 'PO') THEN

                        SELECT'X'
                        INTO l_charge_type_subtype
                        FROM pon_cost_factors_vl
                        WHERE  price_element_type_id > 0
                        AND nvl(enabled_flag,'Y') <> 'N'
                        AND to_char(price_element_type_id) =  p_MODIFIERS_rec.charge_type_code;

        else
      	    select 'X'
	        into   l_charge_type_subtype
	        from   fnd_lookup_values lkp1, qp_lookups lkp2
	        where  lkp1.lookup_code = lkp2.lookup_type(+)
		   and    lkp1.enabled_flag = 'Y'
		   and    TRUNC(sysdate)
		   between TRUNC(nvl(lkp1.start_date_active, sysdate))
		   and     TRUNC(nvl(lkp1.end_date_active, sysdate))
		   and    (lkp2.enabled_flag = 'Y' or lkp2.enabled_flag IS NULL)
		   and     TRUNC(sysdate)
		   between TRUNC(nvl(lkp2.start_date_active, sysdate))
		   and     TRUNC(nvl(lkp2.end_date_active, sysdate))
		   and     lkp1.lookup_code = p_MODIFIERS_rec.charge_type_code
		   and     NVL(decode(lkp1.lookup_type,'FREIGHT_COST_TYPE',NULL,
		           lkp2.lookup_code),'o')
				 = NVL(p_MODIFIERS_rec.charge_subtype_code,'o')
	                             and     lkp1.language = userenv('LANG')
		   and     lkp1.security_group_id = 0
		   and     ((lkp1.view_application_id = 661 and lkp1.lookup_type = 'FREIGHT_CHARGES_TYPE')
				or (lkp1.view_application_id = 665 and lkp1.lookup_type = 'FREIGHT_COST_TYPE'));
        end if;

         EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	   --dbms_output.put_line('invalid charge and subcharge type');
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_INVALID_CHARGE_TYPE_SUBTYPE');
          OE_MSG_PUB.Add;

         END;

      END IF;

/*    For Primary list line types of Price Break Header and Discount, if it is an Accrual and Benefit UOM is given, Accrual Conversion Rate is mandatory  */

	IF  (p_MODIFIERS_rec.list_line_type_code = 'PBH')
	OR  (p_MODIFIERS_rec.list_line_type_code = 'DIS'
	AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL)
	THEN
      IF    p_MODIFIERS_rec.benefit_uom_code IS NOT NULL
      AND   p_MODIFIERS_rec.accrual_flag = 'Y'
	 THEN

        IF   p_MODIFIERS_rec.accrual_conversion_rate IS NULL

        THEN

	   --dbms_output.put_line('accru conv rate mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('ACCRUAL_CONVERSION_RATE'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

        END IF;

      END IF;

     END IF;

oe_debug_pub.add('here9');
/* If Discount is a Primary line with accrual, then if benefit quantity is entered, benefit UOM must be enetered and vice-versa */

       IF   ((p_MODIFIERS_rec.list_line_type_code = 'DIS'
       OR   p_MODIFIERS_rec.list_line_type_code = 'CIE' )
	  AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL
	  AND  p_MODIFIERS_rec.accrual_flag = 'Y')
	  THEN

         IF   (p_MODIFIERS_rec.benefit_uom_code IS NOT NULL
         AND  p_MODIFIERS_rec.benefit_qty IS NULL )
         OR   (p_MODIFIERS_rec.benefit_uom_code IS NULL
         AND  p_MODIFIERS_rec.benefit_qty IS NOT NULL )
         THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          --FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_QTY')||'/'||
          --                            QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_UOM_CODE')); -- Fix For Bug-1974413
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Quantity/UOM'); --Bug No 6010792
          OE_MSG_PUB.Add;

         END IF;

       END IF;

/* Benefit qty is mandatory for the benefit DIS line of PRG    */

       IF   p_MODIFIERS_rec.list_line_type_code = 'DIS'
	  AND  l_primary_list_line_type_code = 'PRG'
       AND  (p_MODIFIERS_rec.benefit_qty IS NULL
       OR    p_MODIFIERS_rec.benefit_uom_code IS NULL )
       THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          --FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_QTY')||'/'||
           --                          QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_UOM_CODE'));  -- Fix For Bug-1974413
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Quantity/UOM'); --Bug No 6010792
          OE_MSG_PUB.Add;

       END IF;

/* Benefit qty is mandatory if benefit uom is entered, for the benefit DIS line of PBH    */

       IF   ((p_MODIFIERS_rec.list_line_type_code = 'DIS'
       OR   p_MODIFIERS_rec.list_line_type_code = 'SUR')
	  AND  p_MODIFIERS_rec.accrual_flag = 'Y'
	  AND  l_primary_list_line_type_code = 'PBH')
	  THEN

         IF   (p_MODIFIERS_rec.benefit_uom_code IS NOT NULL
         AND  p_MODIFIERS_rec.benefit_qty IS NULL )
         OR   (p_MODIFIERS_rec.benefit_uom_code IS NULL
         AND  p_MODIFIERS_rec.benefit_qty IS NOT NULL )
         THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          --FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_QTY')||'/'||
          --                                QP_PRC_UTIL.Get_Attribute_Name('BENEFIT_UOM_CODE')); -- Fix For Bug-1974413
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Quantity/UOM'); --Bug No 6010792
          OE_MSG_PUB.Add;

         END IF;

      END IF;

      IF p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
        IF  p_MODIFIERS_rec.benefit_uom_code IS NOT NULL
        THEN

          IF  p_MODIFIERS_rec.accrual_flag = 'Y'
          THEN

	      BEGIN

 /*   Validating the Benefit UOM Code   */

    	      FND_PROFILE.GET('QP_ACCRUAL_UOM_CLASS',l_qp_accrual_uom_class);

	       select uom_code
	       into   l_dummy_4
	       from   mtl_units_of_measure
	       where  uom_code =  p_MODIFIERS_rec.benefit_uom_code
		  and    uom_class = l_qp_accrual_uom_class;

           EXCEPTION
	       WHEN NO_DATA_FOUND THEN
	     --dbms_output.put_line('invalid bene uom');
            l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_BENEFIT_UOM');
            OE_MSG_PUB.Add;

          END;

         ELSE

	      BEGIN

/*    Validating the Benefit UOM Code  */

	       select count(*)
	       into   l_dummy_5
	       from   mtl_units_of_measure
	       where  uom_code =  p_MODIFIERS_rec.benefit_uom_code;

           EXCEPTION
	       WHEN NO_DATA_FOUND THEN
	     --dbms_output.put_line('invalid bene uom');
            l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_BENEFIT_UOM');
            OE_MSG_PUB.Add;

          END;

        END IF;
       END IF;
     END IF; --list_line_type_code <> 'PMR'
     	 /* Added for bug 7394226 */
	 benefit_qty_t := 'Benefit quantity';
 	 IF p_MODIFIERS_rec.benefit_qty <= 0 THEN
 	   FND_MESSAGE.SET_NAME('QP','QP_NONZERO_QUANTITY_REQD');
 	   FND_MESSAGE.SET_TOKEN('QUANTITY',benefit_qty_t);
 	   OE_MSG_PUB.Add;
 	 END IF;

/* Phase is mandatory for these Primary Modifier types */

oe_debug_pub.add('here95');
     IF ( p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN' OR
          p_MODIFIERS_rec.list_line_type_code = 'CIE' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH' OR
          p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' OR
          p_MODIFIERS_rec.list_line_type_code = 'IUE' ) AND
          p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.pricing_phase_id IS NULL
		THEN

	   --dbms_output.put_line('phase is mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Phase');
          OE_MSG_PUB.Add;

      END IF;

/* Phase is mandatory for all benefit list lines, except for RLTD  */

      IF    p_MODIFIERS_rec.list_line_type_code <> 'PMR' THEN
        IF    p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
        AND   p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL
	   AND   p_MODIFIERS_rec.pricing_phase_id IS NULL
        THEN

	     --dbms_output.put_line('phase is mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Phase');
          OE_MSG_PUB.Add;

        END IF;

/* Validate the Phase from qp_pricing_phases table  */

     IF  p_MODIFIERS_rec.pricing_phase_id IS NOT NULL
     THEN
	     BEGIN
	  	  SELECT phase_sequence, nvl(modifier_level_code,'*')
		  INTO   l_phase_sequence, l_modifier_level_code
		  FROM   QP_PRICING_PHASES
		  WHERE  nvl(LIST_TYPE_CODE,l_list_type_code) = l_list_type_code
		  AND    nvl(LIST_LINE_TYPE_CODE,p_MODIFIERS_rec.list_line_type_code) =
		         p_MODIFIERS_rec.list_line_type_code
		  AND    nvl(MODIFIER_LEVEL_CODE,p_MODIFIERS_rec.modifier_level_code) =
		         p_MODIFIERS_rec.modifier_level_code
		  AND	((p_MODIFIERS_rec.LIST_LINE_TYPE_CODE = 'OID' and nvl(MODIFIER_LEVEL_CODE, '*') <> 'LINE')
			 or p_MODIFIERS_rec.LIST_LINE_TYPE_CODE <> 'OID')
		  AND    PRICING_PHASE_ID = p_MODIFIERS_rec.pricing_phase_id;

          EXCEPTION
	       WHEN NO_DATA_FOUND THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_PHASE');
            OE_MSG_PUB.Add;

          END;

/* Additional buy products are not allowed for a PRG, with line phase*/

	  IF p_MODIFIERS_rec.LIST_LINE_TYPE_CODE = 'RLTD' AND
	     p_MODIFIERS_rec.RLTD_MODIFIER_GRP_TYPE = 'QUALIFIER' AND
	     l_modifier_level_code = 'LINE' THEN
	 /*    BEGIN
	  	  SELECT phase_sequence
		  INTO   l_phase_sequence
		  FROM   QP_PRICING_PHASES
		  WHERE  PRICING_PHASE_ID = p_MODIFIERS_rec.pricing_phase_id
		  AND	 nvl(MODIFIER_LEVEL_CODE, '*') <> 'LINE';
             EXCEPTION
	       WHEN NO_DATA_FOUND THEN */
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_INVALID_PHASE_RLTD');
                  OE_MSG_PUB.Add;
	  --   END;
	  END IF;

/* If Additional buy products exists for a PRG,the phase cannot be changed to line phase*/

	 IF p_MODIFIERS_rec.LIST_LINE_TYPE_CODE = 'PRG' AND
	    l_modifier_level_code = 'LINE' THEN
		BEGIN
		  select  'Y'
		  into    l_rltd_exist
		  from    qp_rltd_modifiers
		  where   from_rltd_modifier_id = p_MODIFIERS_rec.list_line_id
		  and     rltd_modifier_grp_type = 'QUALIFIER'
		  and     rownum = 1;
		EXCEPTION
		 WHEN NO_DATA_FOUND THEN
			l_rltd_exist := 'N';
		END;
		IF l_rltd_exist = 'Y' THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_INVALID_PHASE_RLTD');
                  OE_MSG_PUB.Add;
		END IF;
	 END IF;

/* Phase with event PRICING should not be attached to modifier types PRG/IUE/OID/TSN/CIE -- Bug#2724502 */

          IF (p_MODIFIERS_rec.list_line_type_code IN ('PRG','IUE','OID','CIE','TSN')) THEN
           begin
             select 'Y' into l_phase_price_evt
              from qp_event_phases
             where pricing_event_code = 'PRICE'
               and pricing_phase_id = p_MODIFIERS_rec.PRICING_PHASE_ID;
           exception
             WHEN no_data_found THEN
                  NULL;
           end;

           IF l_phase_price_evt = 'Y' THEN
              l_return_status := FND_API.G_RET_STS_ERROR;

              FND_MESSAGE.SET_NAME('QP','QP_PHASE_PRICE_EVT_ERROR');
              OE_MSG_PUB.Add;

           END IF;
          END IF;

/* Phase with FREE_OVERRIDE_FLAG set to 'Y' should not be attached to modifier type PRG -- Bug#1748272 */

          IF (p_MODIFIERS_rec.list_line_type_code = 'PRG') THEN
           begin
             select 'Y' into l_phase_freeze_set
              from qp_pricing_phases
             where nvl(user_freeze_override_flag,freeze_override_flag) = 'Y'
               and pricing_phase_id = p_MODIFIERS_rec.PRICING_PHASE_ID;
           exception
             WHEN no_data_found THEN
                  NULL;
           end;

           IF l_phase_freeze_set = 'Y' THEN
              l_return_status := FND_API.G_RET_STS_ERROR;

              FND_MESSAGE.SET_NAME('QP','QP_PHASE_FREEZE_ERROR');
              OE_MSG_PUB.Add;

           END IF;
          END IF;

/* Only Phase 10 is allowed for GSA Discounts    */

          IF   l_gsa_indicator = 'Y'
	     AND  l_phase_sequence <> 10
          THEN

             l_return_status := FND_API.G_RET_STS_ERROR;

             FND_MESSAGE.SET_NAME('QP','QP_INVALID_PHASE');
             OE_MSG_PUB.Add;

          END IF;

     END IF;


/* Accrual not allowed for these Modifier types */

          oe_debug_pub.add('line type = '||p_MODIFIERS_rec.list_line_type_code);
          oe_debug_pub.add('accrual flag = '||p_MODIFIERS_rec.accrual_flag);

     IF ( p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'RLTD' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN' OR
          p_MODIFIERS_rec.list_line_type_code = 'PMR' OR
          p_MODIFIERS_rec.list_line_type_code = 'FREIGHT_CHARGE' OR
          p_MODIFIERS_rec.list_line_type_code = 'IUE' ) AND
          p_MODIFIERS_rec.accrual_flag = 'Y'

     THEN


oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ACCRUALS_NOT_ALLOWED');
        OE_MSG_PUB.Add;

     END IF;

/* Accruals not allowed for GSA Discounts   */

     IF   l_gsa_indicator = 'Y'
     AND  p_MODIFIERS_rec.accrual_flag = 'Y'
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ACCRUALS_NOT_ALLOWED');
        OE_MSG_PUB.Add;

     END IF;

/* Accrual is mandatory for Coupon issue */

     IF   p_MODIFIERS_rec.list_line_type_code = 'CIE'
	AND  p_MODIFIERS_rec.accrual_flag <> 'Y'

     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ACCRUALS_MAND_FOR_CIE');
        OE_MSG_PUB.Add;

     END IF;

/* Accrual flag must be Y when accrual related fields are entered

oe_debug_pub.add('HERE');
oe_debug_pub.add('exp date = '||to_char(p_MODIFIERS_rec.expiration_date));

	IF  (( p_MODIFIERS_rec.benefit_qty IS NOT NULL
	OR  p_MODIFIERS_rec.benefit_uom_code IS NOT NULL
	OR  p_MODIFIERS_rec.expiration_date IS NOT NULL
	OR  p_MODIFIERS_rec.expiration_period_start_date IS NOT NULL
	OR  p_MODIFIERS_rec.number_expiration_periods IS NOT NULL
	OR  p_MODIFIERS_rec.expiration_period_uom IS NOT NULL
	OR  p_MODIFIERS_rec.rebate_trxn_type_code IS NOT NULL
	OR  p_MODIFIERS_rec.estim_accrual_rate IS NOT NULL
	OR  p_MODIFIERS_rec.accrual_conversion_rate IS NOT NULL )
	AND  p_MODIFIERS_rec.accrual_flag = 'N')
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ACCRUAL_COLUMNS');
        OE_MSG_PUB.Add;

     END IF;

*/

/* Accrual is allowed only if the benefit line type of Price Break is a Discount */

     IF   p_MODIFIERS_rec.rltd_modifier_grp_type = 'PRICE BREAK' AND
          p_MODIFIERS_rec.accrual_flag = 'Y' AND
          p_MODIFIERS_rec.list_line_type_code <> 'DIS'

     THEN

oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ACCRUALS_FOR_DIS_ONLY');

        OE_MSG_PUB.Add;

     END IF;

/* Proration is mandatory for these Primary Modifier types */

     IF ( p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'OID') AND
          p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.proration_type_code  IS NULL

     THEN


oe_debug_pub.add('proration 11111');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE')); -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;

/* Proration type code must be 'N' for GSA Discounts   */

     IF   l_gsa_indicator = 'Y'
	AND  p_MODIFIERS_rec.proration_type_code <> 'N'
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_GSA_PRORATION_ALWAYS_N');
        OE_MSG_PUB.Add;

     END IF;

     IF ( p_MODIFIERS_rec.list_line_type_code = 'IUE' OR
          p_MODIFIERS_rec.list_line_type_code = 'TSN') AND
          p_MODIFIERS_rec.estim_gl_value IS NOT NULL AND
          p_MODIFIERS_rec.proration_type_code  IS NULL

     THEN


oe_debug_pub.add('list line type code invalid');
        l_return_status := FND_API.G_RET_STS_ERROR;

	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE')); -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;


  /* If the Primary line is a CIE, OID or PRG, proration type code is mandatory  */

     IF  (l_primary_list_line_type_code = 'CIE'
     OR   l_primary_list_line_type_code = 'OID'
     OR   l_primary_list_line_type_code = 'PRG')
     AND   p_MODIFIERS_rec.proration_type_code IS NULL
     THEN

oe_debug_pub.add('proration 22222');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

    END IF;

  /* If the Primary line is a Price Break Header and the Child lines are DIS or SUR, proration type code is mandatory  */

     IF   l_primary_list_line_type_code = 'PBH'
     AND  ( p_MODIFIERS_rec.list_line_type_code = 'DIS'
     OR   p_MODIFIERS_rec.list_line_type_code = 'SUR')
     AND  p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL
     AND   p_MODIFIERS_rec.proration_type_code IS NULL
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRORATION_TYPE_CODE')); -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

    END IF;

  /* If the Primary line is a Coupon Issue, the Child lines must be DIS or PRG  */

     IF   l_primary_list_line_type_code = 'CIE'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'DIS'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'PRG'
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CIE_CHILD_DIS_OR_PRG');
        OE_MSG_PUB.Add;

    END IF;

  /* If the Primary line is a Price Break Header, the child lines must be DIS or SUR */

--dbms_output.put_line('BUY = '||l_primary_list_line_type_code);
--dbms_output.put_line('GET = '||p_MODIFIERS_rec.list_line_type_code);

     IF   l_primary_list_line_type_code = 'PBH'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'PBH'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'DIS'
     AND  p_MODIFIERS_rec.list_line_type_code <> 'SUR'
     THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_PBH_CHILD_DIS_OR_SUR');
        OE_MSG_PUB.Add;

    END IF;

/* Pricing Group Sequence is --not-- mandatory for these Primary Modifier types */
/*commented out this validation as the engine does not need this to be mandatory11.5.3+  spgopal*/

/*
     IF ( p_MODIFIERS_rec.list_line_type_code = 'OID' OR
          p_MODIFIERS_rec.list_line_type_code = 'SUR' OR
          p_MODIFIERS_rec.list_line_type_code = 'PRG' OR
          p_MODIFIERS_rec.list_line_type_code = 'DIS' OR
          p_MODIFIERS_rec.list_line_type_code = 'PBH') AND
          p_MODIFIERS_rec.rltd_modifier_grp_type IS NULL AND
          p_MODIFIERS_rec.modifier_level_code <> 'ORDER' AND
          p_MODIFIERS_rec.automatic_flag = 'Y' AND
          p_MODIFIERS_rec.pricing_group_sequence IS NULL
		THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Bucket');
          OE_MSG_PUB.Add;

      END IF;
	 */

/* Pricing Group Sequence must be 1 for GSA Discounts   */

      IF    l_gsa_indicator = 'Y'
	 AND   p_MODIFIERS_rec.pricing_group_sequence <> 1
      THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_GSA_BUCKET_VALUE_1');
          OE_MSG_PUB.Add;

      END IF;

/* Pricing Group Sequence is --not-- mandatory for all Benefit list lines   */
/*commented out this validation as the engine does not need this to be mandatory11.5.3+  spgopal*/

/*
      IF    p_MODIFIERS_rec.list_line_type_code <> 'RLTD'
      AND   p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL
	 AND   p_MODIFIERS_rec.rltd_modifier_grp_type <> 'PRICE BREAK'
	 AND   p_MODIFIERS_rec.pricing_group_sequence IS NULL
      THEN

	   --dbms_output.put_line('phase is mand');
          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Bucket');
          OE_MSG_PUB.Add;

      END IF;
	 */

/* Pricing Group Sequence must be NULL for manual discounts before packJ and for basic pricing     */


	 IF    p_MODIFIERS_rec.automatic_flag = 'N'
	 AND   p_MODIFIERS_rec.pricing_group_sequence IS NOT NULL
	 AND   (QP_Code_Control.Get_Code_Release_Level < '110510'
                OR
		QP_UTIL.get_qp_status <> 'I'
		OR
		fnd_profile.value ('QP_MANUAL_MODIFIER_BUCKET') <> 'Y'
	        )
         THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_MANUAL_DIS_BUCKET_NULL');
          OE_MSG_PUB.Add;

      END IF;


/* Incompatibility Group Code must be Level 1 for GSA Discounts   */

      IF    l_gsa_indicator = 'Y'
	 AND   p_MODIFIERS_rec.incompatibility_grp_code IS NOT NULL
	 AND   p_MODIFIERS_rec.incompatibility_grp_code <> 'LVL 1'
      THEN

          l_return_status := FND_API.G_RET_STS_ERROR;

	     FND_MESSAGE.SET_NAME('QP','QP_GSA_INCOMP_ALWAYS_LVL1');
          OE_MSG_PUB.Add;

      END IF;


oe_debug_pub.add('here10');
    END IF; -- If list_line_type_code <> 'PMR'
    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

oe_debug_pub.add('before raise');
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF  p_MODIFIERS_rec.accum_attribute IS NOT NULL THEN
        QP_UTIL.validate_attribute_name(p_application_short_name => 'QP'
                         ,p_flexfield_name    => 'QP_ATTR_DEFNS_PRICING'
                         ,p_context_name      => 'VOLUME'
                         ,p_attribute_name    => p_MODIFIERS_rec.accum_attribute
  		 	          ,p_error_code        => l_error_code);

        IF (l_error_code <> 0 )       --  invalid context
	    THEN
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ACCUM_ATTRIBUTE');
               OE_MSG_PUB.Add;
            END IF;
	END IF;
    END IF;


    --
    --  Check conditionally required attributes here.
    --

    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

-- Start Bug 2091362, bug2119287

l_qp_status := QP_UTIL.GET_QP_STATUS;

IF (fnd_profile.value('QP_ALLOW_DUPLICATE_MODIFIERS') <> 'Y'
AND (l_qp_status = 'S' OR l_gsa_indicator = 'Y')) THEN

   oe_debug_pub.add('about to log a request to check duplicate modifier list lines ');

   QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> p_modifiers_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_ALL
,   p_requesting_entity_id	=> p_modifiers_rec.list_line_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
,   p_param1			=> p_modifiers_rec.list_header_id
,   p_param2			=> fnd_date.date_to_canonical(p_modifiers_rec.start_date_active)	--2752265
,   p_param3			=> fnd_date.date_to_canonical(p_modifiers_rec.end_date_active)		--2752265
,   p_param4            => NULL
,   p_param5            => NULL
,   p_param6            => NULL
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging delayed request for Duplicate Modifiers ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

  oe_debug_pub.add('after logging delayed request ');

END IF;

-- end bug2091362


oe_debug_pub.add('END Entity in QPXLMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

oe_debug_pub.add('EXP error');
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

oe_debug_pub.add('EXP unexpected');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

oe_debug_pub.add('EXP others');
oe_debug_pub.add('error =' || sqlerrm);
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
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
)
IS
BEGIN

oe_debug_pub.add('BEGIN Attributes in QPXLMLLB');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* changes to fix bug # 1724169 */

       IF  p_MODIFIERS_rec.list_line_type_code <> 'PMR' --Bug No: 8609021,
					--we don't have to check operand value for factor list
 			AND FND_PROFILE.VALUE('QP_NEGATIVE_PRICING') = 'N' AND p_MODIFIERS_rec.operand < 0
       THEN
            FND_MESSAGE.SET_NAME('QP','OE_PR_NEGATIVE_AMOUNT');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;



    --  Validate MODIFIERS attributes

    IF  p_MODIFIERS_rec.arithmetic_operator IS NOT NULL AND
        (   p_MODIFIERS_rec.arithmetic_operator <>
            p_old_MODIFIERS_rec.arithmetic_operator OR
            p_old_MODIFIERS_rec.arithmetic_operator IS NULL )
    THEN
        IF NOT QP_Validate.Arithmetic_Operator(p_MODIFIERS_rec.arithmetic_operator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
oe_debug_pub.add('here3');

    IF  p_MODIFIERS_rec.automatic_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.automatic_flag <>
            p_old_MODIFIERS_rec.automatic_flag OR
            p_old_MODIFIERS_rec.automatic_flag IS NULL )
    THEN
        IF NOT QP_Validate.Automatic(p_MODIFIERS_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.base_qty IS NOT NULL AND
        (   p_MODIFIERS_rec.base_qty <>
            p_old_MODIFIERS_rec.base_qty OR
            p_old_MODIFIERS_rec.base_qty IS NULL )
    THEN
        IF NOT QP_Validate.Base_Qty(p_MODIFIERS_rec.base_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.pricing_phase_id IS NOT NULL AND
        (   p_MODIFIERS_rec.pricing_phase_id <>
            p_old_MODIFIERS_rec.pricing_phase_id OR
            p_old_MODIFIERS_rec.pricing_phase_id IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Phase(p_MODIFIERS_rec.pricing_phase_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here4');
/*    IF  p_MODIFIERS_rec.base_uom_code IS NOT NULL AND
        (   p_MODIFIERS_rec.base_uom_code <>
            p_old_MODIFIERS_rec.base_uom_code OR
            p_old_MODIFIERS_rec.base_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Base_Uom(p_MODIFIERS_rec.base_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.comments IS NOT NULL AND
        (   p_MODIFIERS_rec.comments <>
            p_old_MODIFIERS_rec.comments OR
            p_old_MODIFIERS_rec.comments IS NULL )
    THEN
        IF NOT QP_Validate.Comments(p_MODIFIERS_rec.comments) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.created_by IS NOT NULL AND
        (   p_MODIFIERS_rec.created_by <>
            p_old_MODIFIERS_rec.created_by OR
            p_old_MODIFIERS_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_MODIFIERS_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.creation_date IS NOT NULL AND
        (   p_MODIFIERS_rec.creation_date <>
            p_old_MODIFIERS_rec.creation_date OR
            p_old_MODIFIERS_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_MODIFIERS_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.effective_period_uom IS NOT NULL AND
        (   p_MODIFIERS_rec.effective_period_uom <>
            p_old_MODIFIERS_rec.effective_period_uom OR
            p_old_MODIFIERS_rec.effective_period_uom IS NULL )
    THEN
        IF NOT QP_Validate.Effective_Period_Uom(p_MODIFIERS_rec.effective_period_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.end_date_active IS NOT NULL AND
        (   p_MODIFIERS_rec.end_date_active <>
            p_old_MODIFIERS_rec.end_date_active OR
            p_old_MODIFIERS_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_MODIFIERS_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.estim_accrual_rate IS NOT NULL AND
        (   p_MODIFIERS_rec.estim_accrual_rate <>
            p_old_MODIFIERS_rec.estim_accrual_rate OR
            p_old_MODIFIERS_rec.estim_accrual_rate IS NULL )
    THEN
        IF NOT QP_Validate.Estim_Accrual_Rate(p_MODIFIERS_rec.estim_accrual_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.generate_using_formula_id IS NOT NULL AND
        (   p_MODIFIERS_rec.generate_using_formula_id <>
            p_old_MODIFIERS_rec.generate_using_formula_id OR
            p_old_MODIFIERS_rec.generate_using_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Generate_Using_Formula(p_MODIFIERS_rec.generate_using_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.gl_class_id IS NOT NULL AND
        (   p_MODIFIERS_rec.gl_class_id <>
            p_old_MODIFIERS_rec.gl_class_id OR
            p_old_MODIFIERS_rec.gl_class_id IS NULL )
    THEN
        IF NOT QP_Validate.Gl_Class(p_MODIFIERS_rec.gl_class_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.inventory_item_id IS NOT NULL AND
        (   p_MODIFIERS_rec.inventory_item_id <>
            p_old_MODIFIERS_rec.inventory_item_id OR
            p_old_MODIFIERS_rec.inventory_item_id IS NULL )
    THEN
        IF NOT QP_Validate.Inventory_Item(p_MODIFIERS_rec.inventory_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.last_updated_by IS NOT NULL AND
        (   p_MODIFIERS_rec.last_updated_by <>
            p_old_MODIFIERS_rec.last_updated_by OR
            p_old_MODIFIERS_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_MODIFIERS_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.last_update_date IS NOT NULL AND
        (   p_MODIFIERS_rec.last_update_date <>
            p_old_MODIFIERS_rec.last_update_date OR
            p_old_MODIFIERS_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_MODIFIERS_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.last_update_login IS NOT NULL AND
        (   p_MODIFIERS_rec.last_update_login <>
            p_old_MODIFIERS_rec.last_update_login OR
            p_old_MODIFIERS_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_MODIFIERS_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here5');
    IF  p_MODIFIERS_rec.list_header_id IS NOT NULL AND
        (   p_MODIFIERS_rec.list_header_id <>
            p_old_MODIFIERS_rec.list_header_id OR
            p_old_MODIFIERS_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_MODIFIERS_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.list_line_id IS NOT NULL AND
        (   p_MODIFIERS_rec.list_line_id <>
            p_old_MODIFIERS_rec.list_line_id OR
            p_old_MODIFIERS_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_MODIFIERS_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.list_line_type_code IS NOT NULL AND
        (   p_MODIFIERS_rec.list_line_type_code <>
            p_old_MODIFIERS_rec.list_line_type_code OR
            p_old_MODIFIERS_rec.list_line_type_code IS NULL )
    THEN
        IF NOT QP_Validate.List_Line_Type(p_MODIFIERS_rec.list_line_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.list_price IS NOT NULL AND
        (   p_MODIFIERS_rec.list_price <>
            p_old_MODIFIERS_rec.list_price OR
            p_old_MODIFIERS_rec.list_price IS NULL )
    THEN
        IF NOT QP_Validate.List_Price(p_MODIFIERS_rec.list_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.list_price_uom_code IS NOT NULL AND
        (   p_MODIFIERS_rec.list_price_uom_code <>
            p_old_MODIFIERS_rec.list_price_uom_code OR
            p_old_MODIFIERS_rec.list_price_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.List_Price_Uom(p_MODIFIERS_rec.list_price_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.modifier_level_code IS NOT NULL AND
        (   p_MODIFIERS_rec.modifier_level_code <>
            p_old_MODIFIERS_rec.modifier_level_code OR
            p_old_MODIFIERS_rec.modifier_level_code IS NULL )
    THEN
        IF NOT QP_Validate.Modifier_Level(p_MODIFIERS_rec.modifier_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.new_price IS NOT NULL AND
        (   p_MODIFIERS_rec.new_price <>
            p_old_MODIFIERS_rec.new_price OR
            p_old_MODIFIERS_rec.new_price IS NULL )
    THEN
        IF NOT QP_Validate.New_Price(p_MODIFIERS_rec.new_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.number_effective_periods IS NOT NULL AND
        (   p_MODIFIERS_rec.number_effective_periods <>
            p_old_MODIFIERS_rec.number_effective_periods OR
            p_old_MODIFIERS_rec.number_effective_periods IS NULL )
    THEN
        IF NOT QP_Validate.Number_Effective_Periods(p_MODIFIERS_rec.number_effective_periods) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here6');
    IF  p_MODIFIERS_rec.operand IS NOT NULL AND
        (   p_MODIFIERS_rec.operand <>
            p_old_MODIFIERS_rec.operand OR
            p_old_MODIFIERS_rec.operand IS NULL )
    THEN
oe_debug_pub.add('here7');
        IF NOT QP_Validate.Operand(p_MODIFIERS_rec.operand) THEN
oe_debug_pub.add('here8');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here9');
    IF  p_MODIFIERS_rec.organization_id IS NOT NULL AND
        (   p_MODIFIERS_rec.organization_id <>
            p_old_MODIFIERS_rec.organization_id OR
            p_old_MODIFIERS_rec.organization_id IS NULL )
    THEN
        IF NOT QP_Validate.Organization(p_MODIFIERS_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here10');
    IF  p_MODIFIERS_rec.override_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.override_flag <>
            p_old_MODIFIERS_rec.override_flag OR
            p_old_MODIFIERS_rec.override_flag IS NULL )
    THEN
        IF NOT QP_Validate.Override(p_MODIFIERS_rec.override_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here11');
    IF  p_MODIFIERS_rec.percent_price IS NOT NULL AND
        (   p_MODIFIERS_rec.percent_price <>
            p_old_MODIFIERS_rec.percent_price OR
            p_old_MODIFIERS_rec.percent_price IS NULL )
    THEN
        IF NOT QP_Validate.Percent_Price(p_MODIFIERS_rec.percent_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.price_break_type_code IS NOT NULL AND
        (   p_MODIFIERS_rec.price_break_type_code <>
            p_old_MODIFIERS_rec.price_break_type_code OR
            p_old_MODIFIERS_rec.price_break_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Price_Break_Type(p_MODIFIERS_rec.price_break_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.price_by_formula_id IS NOT NULL AND
        (   p_MODIFIERS_rec.price_by_formula_id <>
            p_old_MODIFIERS_rec.price_by_formula_id OR
            p_old_MODIFIERS_rec.price_by_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_By_Formula(p_MODIFIERS_rec.price_by_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.primary_uom_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.primary_uom_flag <>
            p_old_MODIFIERS_rec.primary_uom_flag OR
            p_old_MODIFIERS_rec.primary_uom_flag IS NULL )
    THEN
        IF NOT QP_Validate.Primary_Uom(p_MODIFIERS_rec.primary_uom_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.print_on_invoice_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.print_on_invoice_flag <>
            p_old_MODIFIERS_rec.print_on_invoice_flag OR
            p_old_MODIFIERS_rec.print_on_invoice_flag IS NULL )
    THEN
        IF NOT QP_Validate.Print_On_Invoice(p_MODIFIERS_rec.print_on_invoice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.program_application_id IS NOT NULL AND
        (   p_MODIFIERS_rec.program_application_id <>
            p_old_MODIFIERS_rec.program_application_id OR
            p_old_MODIFIERS_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_MODIFIERS_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.program_id IS NOT NULL AND
        (   p_MODIFIERS_rec.program_id <>
            p_old_MODIFIERS_rec.program_id OR
            p_old_MODIFIERS_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_MODIFIERS_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.program_update_date IS NOT NULL AND
        (   p_MODIFIERS_rec.program_update_date <>
            p_old_MODIFIERS_rec.program_update_date OR
            p_old_MODIFIERS_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_MODIFIERS_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.rebate_subtype_code IS NOT NULL AND
        (   p_MODIFIERS_rec.rebate_subtype_code <>
            p_old_MODIFIERS_rec.rebate_subtype_code OR
            p_old_MODIFIERS_rec.rebate_subtype_code IS NULL )
    THEN
        IF NOT QP_Validate.Rebate_Subtype(p_MODIFIERS_rec.rebate_subtype_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.rebate_trxn_type_code IS NOT NULL AND
        (   p_MODIFIERS_rec.rebate_trxn_type_code <>
            p_old_MODIFIERS_rec.rebate_trxn_type_code OR
            p_old_MODIFIERS_rec.rebate_trxn_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Rebate_Transaction_Type(p_MODIFIERS_rec.rebate_trxn_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.related_item_id IS NOT NULL AND
        (   p_MODIFIERS_rec.related_item_id <>
            p_old_MODIFIERS_rec.related_item_id OR
            p_old_MODIFIERS_rec.related_item_id IS NULL )
    THEN
        IF NOT QP_Validate.Related_Item(p_MODIFIERS_rec.related_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.relationship_type_id IS NOT NULL AND
        (   p_MODIFIERS_rec.relationship_type_id <>
            p_old_MODIFIERS_rec.relationship_type_id OR
            p_old_MODIFIERS_rec.relationship_type_id IS NULL )
    THEN
        IF NOT QP_Validate.Relationship_Type(p_MODIFIERS_rec.relationship_type_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.reprice_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.reprice_flag <>
            p_old_MODIFIERS_rec.reprice_flag OR
            p_old_MODIFIERS_rec.reprice_flag IS NULL )
    THEN
        IF NOT QP_Validate.Reprice(p_MODIFIERS_rec.reprice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.request_id IS NOT NULL AND
        (   p_MODIFIERS_rec.request_id <>
            p_old_MODIFIERS_rec.request_id OR
            p_old_MODIFIERS_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_MODIFIERS_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.revision IS NOT NULL AND
        (   p_MODIFIERS_rec.revision <>
            p_old_MODIFIERS_rec.revision OR
            p_old_MODIFIERS_rec.revision IS NULL )
    THEN
        IF NOT QP_Validate.Revision(p_MODIFIERS_rec.revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.revision_date IS NOT NULL AND
        (   p_MODIFIERS_rec.revision_date <>
            p_old_MODIFIERS_rec.revision_date OR
            p_old_MODIFIERS_rec.revision_date IS NULL )
    THEN
        IF NOT QP_Validate.Revision_Date(p_MODIFIERS_rec.revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.revision_reason_code IS NOT NULL AND
        (   p_MODIFIERS_rec.revision_reason_code <>
            p_old_MODIFIERS_rec.revision_reason_code OR
            p_old_MODIFIERS_rec.revision_reason_code IS NULL )
    THEN
        IF NOT QP_Validate.Revision_Reason(p_MODIFIERS_rec.revision_reason_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.start_date_active IS NOT NULL AND
        (   p_MODIFIERS_rec.start_date_active <>
            p_old_MODIFIERS_rec.start_date_active OR
            p_old_MODIFIERS_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_MODIFIERS_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.substitution_attribute IS NOT NULL AND
        (   p_MODIFIERS_rec.substitution_attribute <>
            p_old_MODIFIERS_rec.substitution_attribute OR
            p_old_MODIFIERS_rec.substitution_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Attribute(p_MODIFIERS_rec.substitution_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.substitution_context IS NOT NULL AND
        (   p_MODIFIERS_rec.substitution_context <>
            p_old_MODIFIERS_rec.substitution_context OR
            p_old_MODIFIERS_rec.substitution_context IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Context(p_MODIFIERS_rec.substitution_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.substitution_value IS NOT NULL AND
        (   p_MODIFIERS_rec.substitution_value <>
            p_old_MODIFIERS_rec.substitution_value OR
            p_old_MODIFIERS_rec.substitution_value IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Value(p_MODIFIERS_rec.substitution_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.accrual_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.accrual_flag <>
            p_old_MODIFIERS_rec.accrual_flag OR
            p_old_MODIFIERS_rec.accrual_flag IS NULL )
    THEN
        IF NOT QP_Validate.Accrual_Flag(p_MODIFIERS_rec.accrual_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.pricing_group_sequence IS NOT NULL AND
        (   p_MODIFIERS_rec.pricing_group_sequence <>
            p_old_MODIFIERS_rec.pricing_group_sequence OR
            p_old_MODIFIERS_rec.pricing_group_sequence IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Group_Sequence(p_MODIFIERS_rec.pricing_group_sequence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
oe_debug_pub.add('here12');
    IF  p_MODIFIERS_rec.incompatibility_grp_code IS NOT NULL AND
        (   p_MODIFIERS_rec.incompatibility_grp_code <>
            p_old_MODIFIERS_rec.incompatibility_grp_code OR
            p_old_MODIFIERS_rec.incompatibility_grp_code IS NULL )
    THEN
        IF NOT QP_Validate.Incompatibility_Grp_Code(p_MODIFIERS_rec.incompatibility_grp_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here13');
    IF  p_MODIFIERS_rec.list_line_no IS NOT NULL AND
        (   p_MODIFIERS_rec.list_line_no <>
            p_old_MODIFIERS_rec.list_line_no OR
            p_old_MODIFIERS_rec.list_line_no IS NULL )
    THEN
        IF NOT QP_Validate.List_Line_No(p_MODIFIERS_rec.list_line_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.product_precedence IS NOT NULL AND
        (   p_MODIFIERS_rec.product_precedence <>
            p_old_MODIFIERS_rec.product_precedence OR
            p_old_MODIFIERS_rec.product_precedence IS NULL )
    THEN
        IF NOT QP_Validate.Product_Precedence(p_MODIFIERS_rec.product_precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.expiration_period_start_date IS NOT NULL AND
        (   p_MODIFIERS_rec.expiration_period_start_date <>
            p_old_MODIFIERS_rec.expiration_period_start_date OR
            p_old_MODIFIERS_rec.expiration_period_start_date IS NULL )
    THEN
        IF NOT QP_Validate.Exp_Period_Start_Date(p_MODIFIERS_rec.expiration_period_start_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.number_expiration_periods IS NOT NULL AND
        (   p_MODIFIERS_rec.number_expiration_periods <>
            p_old_MODIFIERS_rec.number_expiration_periods OR
            p_old_MODIFIERS_rec.number_expiration_periods IS NULL )
    THEN
        IF NOT QP_Validate.Number_Expiration_Periods(p_MODIFIERS_rec.number_expiration_periods) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.number_expiration_periods IS NOT NULL AND
        (   p_MODIFIERS_rec.number_expiration_periods <>
            p_old_MODIFIERS_rec.number_expiration_periods OR
            p_old_MODIFIERS_rec.number_expiration_periods IS NULL )
    THEN
        IF NOT QP_Validate.Number_Expiration_Periods(p_MODIFIERS_rec.number_expiration_periods) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.expiration_period_uom IS NOT NULL AND
        (   p_MODIFIERS_rec.expiration_period_uom <>
            p_old_MODIFIERS_rec.expiration_period_uom OR
            p_old_MODIFIERS_rec.expiration_period_uom IS NULL )
    THEN
        IF NOT QP_Validate.Expiration_Period_Uom(p_MODIFIERS_rec.expiration_period_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.expiration_date IS NOT NULL AND
        (   p_MODIFIERS_rec.expiration_date <>
            p_old_MODIFIERS_rec.expiration_date OR
            p_old_MODIFIERS_rec.expiration_date IS NULL )
    THEN
        IF NOT QP_Validate.Expiration_Date(p_MODIFIERS_rec.expiration_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.estim_gl_value IS NOT NULL AND
        (   p_MODIFIERS_rec.estim_gl_value <>
            p_old_MODIFIERS_rec.estim_gl_value OR
            p_old_MODIFIERS_rec.estim_gl_value IS NULL )
    THEN
        IF NOT QP_Validate.Estim_Gl_Value(p_MODIFIERS_rec.estim_gl_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.benefit_price_list_line_id IS NOT NULL AND
        (   p_MODIFIERS_rec.benefit_price_list_line_id <>
            p_old_MODIFIERS_rec.benefit_price_list_line_id OR
            p_old_MODIFIERS_rec.benefit_price_list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.Ben_Price_List_Line(p_MODIFIERS_rec.benefit_price_list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_MODIFIERS_rec.recurring_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.recurring_flag <>
            p_old_MODIFIERS_rec.recurring_flag OR
            p_old_MODIFIERS_rec.recurring_flag IS NULL )
    THEN
        IF NOT QP_Validate.Recurring(p_MODIFIERS_rec.recurring_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/
    IF  p_MODIFIERS_rec.benefit_limit IS NOT NULL AND
        (   p_MODIFIERS_rec.benefit_limit <>
            p_old_MODIFIERS_rec.benefit_limit OR
            p_old_MODIFIERS_rec.benefit_limit IS NULL )
    THEN
        IF NOT QP_Validate.Benefit_Limit(p_MODIFIERS_rec.benefit_limit) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.charge_type_code IS NOT NULL AND
        (   p_MODIFIERS_rec.charge_type_code <>
            p_old_MODIFIERS_rec.charge_type_code OR
            p_old_MODIFIERS_rec.charge_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Charge_Type(p_MODIFIERS_rec.charge_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.charge_subtype_code IS NOT NULL AND
        (   p_MODIFIERS_rec.charge_subtype_code <>
            p_old_MODIFIERS_rec.charge_subtype_code OR
            p_old_MODIFIERS_rec.charge_subtype_code IS NULL )
    THEN
        IF NOT QP_Validate.Charge_Subtype(p_MODIFIERS_rec.charge_subtype_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.benefit_qty IS NOT NULL AND
        (   p_MODIFIERS_rec.benefit_qty <>
            p_old_MODIFIERS_rec.benefit_qty OR
            p_old_MODIFIERS_rec.benefit_qty IS NULL )
    THEN
        IF NOT QP_Validate.Benefit_Qty(p_MODIFIERS_rec.benefit_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.benefit_uom_code IS NOT NULL AND
        (   p_MODIFIERS_rec.benefit_uom_code <>
            p_old_MODIFIERS_rec.benefit_uom_code OR
            p_old_MODIFIERS_rec.benefit_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Benefit_Uom(p_MODIFIERS_rec.benefit_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.accrual_conversion_rate IS NOT NULL AND
        (   p_MODIFIERS_rec.accrual_conversion_rate <>
            p_old_MODIFIERS_rec.accrual_conversion_rate OR
            p_old_MODIFIERS_rec.accrual_conversion_rate IS NULL )
    THEN
        IF NOT QP_Validate.Accrual_Conversion_Rate(p_MODIFIERS_rec.accrual_conversion_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.proration_type_code IS NOT NULL AND
        (   p_MODIFIERS_rec.proration_type_code <>
            p_old_MODIFIERS_rec.proration_type_code OR
            p_old_MODIFIERS_rec.proration_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Proration_Type(p_MODIFIERS_rec.proration_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.from_rltd_modifier_id IS NOT NULL AND
        (   p_MODIFIERS_rec.from_rltd_modifier_id <>
            p_old_MODIFIERS_rec.from_rltd_modifier_id OR
            p_old_MODIFIERS_rec.from_rltd_modifier_id IS NULL )
    THEN
        IF NOT QP_Validate.From_Rltd_Modifier(p_MODIFIERS_rec.from_rltd_modifier_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.to_rltd_modifier_id IS NOT NULL AND
        (   p_MODIFIERS_rec.to_rltd_modifier_id <>
            p_old_MODIFIERS_rec.to_rltd_modifier_id OR
            p_old_MODIFIERS_rec.to_rltd_modifier_id IS NULL )
    THEN
        IF NOT QP_Validate.To_Rltd_Modifier(p_MODIFIERS_rec.to_rltd_modifier_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.rltd_modifier_grp_no IS NOT NULL AND
        (   p_MODIFIERS_rec.rltd_modifier_grp_no <>
            p_old_MODIFIERS_rec.rltd_modifier_grp_no OR
            p_old_MODIFIERS_rec.rltd_modifier_grp_no IS NULL )
    THEN
        IF NOT QP_Validate.Rltd_Modifier_Grp_No(p_MODIFIERS_rec.rltd_modifier_grp_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL AND
        (   p_MODIFIERS_rec.rltd_modifier_grp_type <>
            p_old_MODIFIERS_rec.rltd_modifier_grp_type OR
            p_old_MODIFIERS_rec.rltd_modifier_grp_type IS NULL )
    THEN
        IF NOT QP_Validate.Rltd_Modifier_Grp_Type(p_MODIFIERS_rec.rltd_modifier_grp_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

--Item Amount
    IF  p_MODIFIERS_rec.net_amount_flag IS NOT NULL AND
        (   p_MODIFIERS_rec.net_amount_flag <>
            p_old_MODIFIERS_rec.net_amount_flag OR
            p_old_MODIFIERS_rec.net_amount_flag IS NULL )
    THEN
        IF NOT QP_Validate.Net_Amount(p_MODIFIERS_rec.net_amount_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

-- Accumulation of range breaks
    IF  p_MODIFIERS_rec.accum_attribute IS NOT NULL AND
        (   p_MODIFIERS_rec.accum_attribute <>
            p_old_MODIFIERS_rec.accum_attribute OR
            p_old_MODIFIERS_rec.accum_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Accum_Attribute(p_MODIFIERS_rec.accum_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;



oe_debug_pub.add('here14');
    IF  (p_MODIFIERS_rec.attribute1 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute1 <>
            p_old_MODIFIERS_rec.attribute1 OR
            p_old_MODIFIERS_rec.attribute1 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute10 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute10 <>
            p_old_MODIFIERS_rec.attribute10 OR
            p_old_MODIFIERS_rec.attribute10 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute11 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute11 <>
            p_old_MODIFIERS_rec.attribute11 OR
            p_old_MODIFIERS_rec.attribute11 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute12 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute12 <>
            p_old_MODIFIERS_rec.attribute12 OR
            p_old_MODIFIERS_rec.attribute12 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute13 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute13 <>
            p_old_MODIFIERS_rec.attribute13 OR
            p_old_MODIFIERS_rec.attribute13 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute14 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute14 <>
            p_old_MODIFIERS_rec.attribute14 OR
            p_old_MODIFIERS_rec.attribute14 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute15 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute15 <>
            p_old_MODIFIERS_rec.attribute15 OR
            p_old_MODIFIERS_rec.attribute15 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute2 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute2 <>
            p_old_MODIFIERS_rec.attribute2 OR
            p_old_MODIFIERS_rec.attribute2 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute3 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute3 <>
            p_old_MODIFIERS_rec.attribute3 OR
            p_old_MODIFIERS_rec.attribute3 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute4 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute4 <>
            p_old_MODIFIERS_rec.attribute4 OR
            p_old_MODIFIERS_rec.attribute4 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute5 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute5 <>
            p_old_MODIFIERS_rec.attribute5 OR
            p_old_MODIFIERS_rec.attribute5 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute6 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute6 <>
            p_old_MODIFIERS_rec.attribute6 OR
            p_old_MODIFIERS_rec.attribute6 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute7 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute7 <>
            p_old_MODIFIERS_rec.attribute7 OR
            p_old_MODIFIERS_rec.attribute7 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute8 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute8 <>
            p_old_MODIFIERS_rec.attribute8 OR
            p_old_MODIFIERS_rec.attribute8 IS NULL ))
    OR  (p_MODIFIERS_rec.attribute9 IS NOT NULL AND
        (   p_MODIFIERS_rec.attribute9 <>
            p_old_MODIFIERS_rec.attribute9 OR
            p_old_MODIFIERS_rec.attribute9 IS NULL ))
    OR  (p_MODIFIERS_rec.context IS NOT NULL AND
        (   p_MODIFIERS_rec.context <>
            p_old_MODIFIERS_rec.context OR
            p_old_MODIFIERS_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_MODIFIERS_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_MODIFIERS_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_MODIFIERS_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_MODIFIERS_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_MODIFIERS_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_MODIFIERS_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_MODIFIERS_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_MODIFIERS_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_MODIFIERS_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_MODIFIERS_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_MODIFIERS_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_MODIFIERS_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_MODIFIERS_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_MODIFIERS_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_MODIFIERS_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_MODIFIERS_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'MODIFIERS' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

oe_debug_pub.add('END Attributes in QPXLMLLB');

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

oe_debug_pub.add('EXP Attributes in QPXLMLLB');
END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

oe_debug_pub.add('BEGIN Entity_Delete in QPXLMLLB');

    --  Validate entity delete.

    NULL;
    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_MODIFIERS_rec.list_header_id,
                             p_list_line_id   => p_MODIFIERS_rec.list_line_id,
                             x_return_status  => l_return_status
                            );

    --  Done.

    x_return_status := l_return_status;

oe_debug_pub.add('BEGIN Entity_Delete in QPXLMLLB');

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

END QP_Validate_Modifiers;

/
