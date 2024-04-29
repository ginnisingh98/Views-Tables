--------------------------------------------------------
--  DDL for Package Body OE_UPGRADE_MISC_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPGRADE_MISC_NEW" AS
/* $Header: OEXNUMSB.pls 120.0 2005/06/01 02:21:56 appldev noship $ */

-- Procedure to convert the passed in Freight Amount to the specified
-- currency.

 PROCEDURE CONVERT_CURRENCY
 (   p_freight_amount           IN  NUMBER
 ,   p_from_currency            IN  VARCHAR2
 ,   p_to_currency              IN  VARCHAR2
 ,   p_conversion_date          IN  DATE
 ,   p_conversion_rate          IN  NUMBER
 ,   p_conversion_type          IN  VARCHAR2
 ,   x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,   x_freight_amount           OUT NOCOPY /* file.sql.39 change */ NUMBER
 )IS
     l_conversion_type          VARCHAR2(30);
	l_rate_exists              VARCHAR2(1);
	l_converted_amount         NUMBER;
	l_max_roll_days            NUMBER;
	l_denominator              NUMBER;
	l_numerator                NUMBER;
	l_rate                     NUMBER;
	No_User_Defined_Rate       EXCEPTION;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
 BEGIN
	x_return_status := 'S';
     l_max_roll_days := 300;
     l_conversion_type := NVL(p_conversion_type, 'Corporate');

     IF (GL_CURRENCY_API.Is_Fixed_Rate( p_from_currency,
                           p_to_currency, p_conversion_date) = 'Y')
     THEN
         x_freight_amount := GL_CURRENCY_API.convert_amount(
                                  p_from_currency,
                                  p_to_currency,
                                  NVL(p_conversion_date,sysdate),
                                  l_conversion_type,
                                  p_freight_amount
                                  );
     ELSIF (l_conversion_type = 'User')
     THEN
         IF (p_conversion_rate IS NOT NULL) THEN
             x_freight_amount := p_freight_amount * p_conversion_rate;
         ELSE
             RAISE No_User_Defined_Rate;
         END IF;
     ELSE
         l_rate_exists := GL_CURRENCY_API.Rate_Exists(
                           x_from_currency   => p_from_currency,
                           x_to_currency     => p_to_currency,
                           x_conversion_date => NVL(p_conversion_date,sysdate),
                           x_conversion_type => l_conversion_type
                           );
         IF (l_rate_exists = 'Y') THEN
             x_freight_amount := GL_CURRENCY_API.convert_amount(
                                        p_from_currency,
                                        p_to_currency,
                                        NVL(p_conversion_date,sysdate),
                                        l_conversion_type,
                                        p_freight_amount
                                        );
         ELSE
             GL_CURRENCY_API.convert_closest_amount(
                   x_from_currency   => p_from_currency,
                   x_to_currency     => p_to_currency,
                   x_conversion_date => NVL(p_conversion_date,sysdate),
                   x_conversion_type => l_conversion_type,
                   x_user_rate       => p_conversion_rate,
                   x_amount          => p_freight_amount,
                   x_max_roll_days   => l_max_roll_days,
                   x_converted_amount=> l_converted_amount,
                   x_denominator     => l_denominator,
                   x_numerator       => l_numerator,
                   x_rate            => l_rate);
             x_freight_amount := l_converted_amount;
         END IF;

     END IF;
 EXCEPTION
	WHEN OTHERS THEN
	    x_return_status := 'E';

 END CONVERT_CURRENCY;


 PROCEDURE CREATE_FREIGHT_RECORD
 (
     p_header_id                 IN  NUMBER
 ,   p_line_id                   IN  NUMBER
 ,   p_freight_charge_id         IN  NUMBER
 ,   p_currency_code             IN  VARCHAR2
 ,   p_charge_type_code          IN  VARCHAR2
 ,   p_adjusted_amount           IN  VARCHAR2
 ,   p_creation_date             IN  DATE
 ,   p_created_by                IN  NUMBER
 ,   p_last_update_date          IN  DATE
 ,   p_last_updated_by           IN  NUMBER
 ,   p_last_update_login         IN  NUMBER
 ,   p_context                   IN  VARCHAR2
 ,   p_attribute1                IN  VARCHAR2
 ,   p_attribute2                IN  VARCHAR2
 ,   p_attribute3                IN  VARCHAR2
 ,   p_attribute4                IN  VARCHAR2
 ,   p_attribute5                IN  VARCHAR2
 ,   p_attribute6                IN  VARCHAR2
 ,   p_attribute7                IN  VARCHAR2
 ,   p_attribute8                IN  VARCHAR2
 ,   p_attribute9                IN  VARCHAR2
 ,   p_attribute10               IN  VARCHAR2
 ,   p_attribute11               IN  VARCHAR2
 ,   p_attribute12               IN  VARCHAR2
 ,   p_attribute13               IN  VARCHAR2
 ,   p_attribute14               IN  VARCHAR2
 ,   p_attribute15               IN  VARCHAR2
 ,   p_ac_context                IN  VARCHAR2
 ,   p_ac_attribute1             IN  VARCHAR2
 ,   p_ac_attribute2             IN  VARCHAR2
 ,   p_ac_attribute3             IN  VARCHAR2
 ,   p_ac_attribute4             IN  VARCHAR2
 ,   p_ac_attribute5             IN  VARCHAR2
 ,   p_ac_attribute6             IN  VARCHAR2
 ,   p_ac_attribute7             IN  VARCHAR2
 ,   p_ac_attribute8             IN  VARCHAR2
 ,   p_ac_attribute9             IN  VARCHAR2
 ,   p_ac_attribute10            IN  VARCHAR2
 ,   p_ac_attribute11            IN  VARCHAR2
 ,   p_ac_attribute12            IN  VARCHAR2
 ,   p_ac_attribute13            IN  VARCHAR2
 ,   p_ac_attribute14            IN  VARCHAR2
 ,   p_ac_attribute15            IN  VARCHAR2
 ,   p_invoice_status            IN  VARCHAR2
 ,   x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ) IS

    l_price_adjustment_id    NUMBER;
    l_list_header_id         NUMBER;
    l_list_line_id           NUMBER;
    l_count                  NUMBER;
    l_pricing_phase_id       NUMBER;
    l_pricing_group_sequence NUMBER;

    ERROR_IN_GETTING_SETUP   EXCEPTION;
    ERROR_IN_MAPPING_FREIGHT EXCEPTION;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    x_return_status := 'S';
    l_count := 0;
    SELECT count(*)
    INTO  l_count
    FROM  OE_PRICE_ADJUSTMENTS
    WHERE header_id = p_header_id
    AND   NVL(line_id,-99) = NVL(p_line_id,-99)
    AND   cost_id = p_freight_charge_id;

    IF l_count = 0 THEN

    -- Get the Setup details for the Freight record.
        BEGIN
        SELECT DISTINCT b.list_header_id,
		     a.list_line_id,
		     a.pricing_phase_id,
		     a.pricing_group_sequence
        INTO   l_list_header_id,
	    	     l_list_line_id,
		     l_pricing_phase_id,
		     l_pricing_group_sequence
        FROM   qp_list_lines a,
		     qp_list_headers_b b,
		     qp_list_headers_tl tl
        WHERE  b.currency_code = p_currency_code
        AND    tl.list_header_id = b.list_header_id
        AND    b.list_type_code = 'CHARGES'
        AND    tl.name = 'FREIGHTUPGIN'||p_currency_code
        AND    b.list_header_id = a.list_header_id
        AND    a.list_line_type_code = 'FREIGHT_CHARGE'
        AND    a.charge_type_code = p_charge_type_code
        AND    a.modifier_level_code = 'ORDER'
        AND    ROWNUM = 1;
        EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		      raise ERROR_IN_GETTING_SETUP;
        END;


    -- Get the price_adjustment_id
        SELECT OE_PRICE_ADJUSTMENTS_S.nextval INTO l_price_adjustment_id FROM DUAL;

        INSERT INTO OE_PRICE_ADJUSTMENTS
        (
            PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       HEADER_ID
    ,       AUTOMATIC_FLAG
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_TYPE_CODE
    ,       UPDATED_FLAG
    ,       UPDATE_ALLOWED
    ,       APPLIED_FLAG
    ,       CHANGE_REASON_CODE
    ,       CHANGE_REASON_TEXT
    ,       OPERAND
    ,       ARITHMETIC_OPERATOR
    ,       INVOICED_FLAG
    ,       ESTIMATED_FLAG
    ,       INC_IN_SALES_PERFORMANCE
    ,       SPLIT_ACTION_CODE
    ,       ADJUSTED_AMOUNT
    ,       PRICING_PHASE_ID
    ,       PRICING_GROUP_SEQUENCE
    ,       CHARGE_TYPE_CODE
    ,       CHARGE_SUBTYPE_CODE
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       COST_ID
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15

        )
        VALUES
        (
            l_price_adjustment_id
    ,       p_creation_date
    ,       p_created_by
    ,       p_LAST_UPDATE_DATE
    ,       p_LAST_UPDATED_BY
    ,       p_LAST_UPDATE_LOGIN
    ,       p_HEADER_ID
    ,       'Y'
    ,       p_LINE_ID
    ,       p_CONTEXT
    ,       p_ATTRIBUTE1
    ,       p_ATTRIBUTE2
    ,       p_ATTRIBUTE3
    ,       p_ATTRIBUTE4
    ,       p_ATTRIBUTE5
    ,       p_ATTRIBUTE6
    ,       p_ATTRIBUTE7
    ,       p_ATTRIBUTE8
    ,       p_ATTRIBUTE9
    ,       p_ATTRIBUTE10
    ,       p_ATTRIBUTE11
    ,       p_ATTRIBUTE12
    ,       p_ATTRIBUTE13
    ,       p_ATTRIBUTE14
    ,       p_ATTRIBUTE15
    ,       l_LIST_HEADER_ID
    ,       l_LIST_LINE_ID
    ,       'FREIGHT_CHARGE'
    ,       'Y'
    ,       'Y'
    ,       'Y'
    ,       'MISC'
    ,       'Upgraded Freight Charge'
    ,       p_adjusted_amount
    ,       'LUMPSUM'
    ,       DECODE(p_invoice_status,NULL,'N','Y')
    ,       'N'
    ,       NULL
    ,       NULL
    ,       p_adjusted_amount
    ,       l_PRICING_PHASE_ID
    ,       l_PRICING_GROUP_SEQUENCE
    ,       P_CHARGE_TYPE_CODE
    ,       NULL
    ,       'D'
    ,       'Y'
    ,       p_freight_charge_id
    ,       p_AC_CONTEXT
    ,       p_AC_ATTRIBUTE1
    ,       p_AC_ATTRIBUTE2
    ,       p_AC_ATTRIBUTE3
    ,       p_AC_ATTRIBUTE4
    ,       p_AC_ATTRIBUTE5
    ,       p_AC_ATTRIBUTE6
    ,       p_AC_ATTRIBUTE7
    ,       p_AC_ATTRIBUTE8
    ,       p_AC_ATTRIBUTE9
    ,       p_AC_ATTRIBUTE10
    ,       p_AC_ATTRIBUTE11
    ,       p_AC_ATTRIBUTE12
    ,       p_AC_ATTRIBUTE13
    ,       p_AC_ATTRIBUTE14
    ,       p_AC_ATTRIBUTE15
        );
    END IF;
EXCEPTION
    WHEN ERROR_IN_GETTING_SETUP THEN
	   x_return_status := 'N';
    WHEN ERROR_IN_MAPPING_FREIGHT THEN
	   x_return_status := 'C';
    WHEN OTHERS THEN
	   x_return_status := 'E';

END CREATE_FREIGHT_RECORD;

PROCEDURE Round_Amount(
  p_Amount                       IN  NUMBER
, p_Currency_Code                IN  VARCHAR2
, x_Round_Amount                 OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_precision                      NUMBER;
l_minimum_accountable_unit       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     x_return_status := 'S';
     SELECT precision, nvl(minimum_accountable_unit, 0)
     INTO l_precision, l_minimum_accountable_unit
     FROM fnd_currencies
     WHERE currency_code = p_Currency_Code;

     x_Round_Amount := Round(p_Amount, l_precision);
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'E';
END Round_Amount;

FUNCTION GET_SOB_CURRENCY(p_org_id IN NUMBER)
RETURN VARCHAR2
IS
l_curr_code           VARCHAR2(15);
l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_sob_id              NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF oe_code_control.code_release_level < '110510' THEN
      SELECT b.currency_code
      INTO l_curr_code
      FROM ar_system_parameters_all a,
    	    GL_SETS_OF_BOOKS b
      WHERE NVL(a.org_id,-99) = NVL(p_org_id,-99)
      AND a.set_of_books_id = b.set_of_books_id
      AND ROWNUM =1;
      RETURN l_curr_code;
  ELSE
     l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params(p_org_id);
     l_sob_id           := l_AR_Sys_Param_Rec.set_of_books_id;
     SELECT b.currency_code
     INTO l_curr_code
     FROM     GL_SETS_OF_BOOKS b
     WHERE b.set_of_books_id = l_sob_id
     AND ROWNUM =1;
     RETURN l_curr_code;
  END IF;


EXCEPTION
    WHEN OTHERS THEN
	   RETURN NULL;
END GET_SOB_CURRENCY;

END OE_Upgrade_Misc_New;

/
