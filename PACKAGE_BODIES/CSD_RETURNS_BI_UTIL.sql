--------------------------------------------------------
--  DDL for Package Body CSD_RETURNS_BI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RETURNS_BI_UTIL" AS
    /* $Header: csdurbib.pls 120.0.12010000.1 2010/04/14 23:22:25 swai noship $ */

    /*--------------------------------------------------------*/
    /* function name: CONVERT_INV_UOM                         */
    /* description : function used to convert quantities from */
    /*               one inventory UOM to another             */
    /* Called from : Depot Repair Returns BI dashboard        */
    /* Input Parm  :                                          */
    /*   p_qty               NUMBER    qty to convert         */
    /*   p_from_uom          VARCHAR2  From UOM code          */
    /*   p_to_uom            VARCHAR2  To UOM code            */
    /*   p_error_val         NUMBER    Value to return if qty */
    /*                                 is null or conversion  */
    /*                                 errored out            */
    /* Output:                                                */
    /*        NUMBER  Converted currency amount               */
    /*                Returns null if there is an error       */
    /* Change Hist :                                          */
    /*--------------------------------------------------------*/
    FUNCTION CONVERT_INV_UOM (p_qty       IN NUMBER,
                              p_from_uom  IN VARCHAR2,
                              p_to_uom    IN VARCHAR2,
                              p_error_val IN NUMBER) RETURN NUMBER
    IS
        l_converted_value NUMBER := NULL;
    BEGIN
        if (p_qty is null) then
            l_converted_value := p_error_val;
        else
            l_converted_value := inv_convert.inv_um_convert(
                                            item_id       => 0,
                                            precision     => 38,
                                            from_quantity => p_qty,
                                            from_unit     => p_from_uom,
                                            to_unit       => p_to_uom ,
                                            from_name     => NULL,
                                            to_name       => NULL);

            if (l_converted_value = -99999) then
                l_converted_value := p_error_val;
            end if;
        end if;
        return l_converted_value;
    END CONVERT_INV_UOM;


    /*--------------------------------------------------------*/
    /* function name: CONVERT_CURRENCY                        */
    /* description : function used to convert currency -      */
    /* Called from : Depot Repair Returns BI dashboard        */
    /* Input Parm  :                                          */
    /*   p_amount            NUMBER    Amount to convert      */
    /*   p_from_currency     VARCHAR2  From currency code     */
    /*   p_to_currency       VARCHAR2  To Currency code       */
    /*   p_error_val         NUMBER    Value to return if amt */
    /*                                 is null or conversion  */
    /*                                 errored out            */
    /* Output:                                                */
    /*        NUMBER  Converted currency amount               */
    /*                Returns null if there is an error       */
    /* Change Hist :                                          */
    /*--------------------------------------------------------*/
    FUNCTION CONVERT_CURRENCY( p_amount          IN   NUMBER,
                               p_from_currency   IN   VARCHAR2,
                               p_to_currency     IN   VARCHAR2,
                               p_conversion_date IN   DATE,
                               p_error_val       IN   NUMBER
    ) RETURN NUMBER
    IS
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
        l_conv_amount NUMBER;
        l_conversion_type          VARCHAR2(30);
        l_max_roll_days            NUMBER;
    BEGIN
        -- Check if conversion type profile is set. If not then raise error.
        l_conversion_type := FND_PROFILE.value('CSD_CURRENCY_CONVERSION_TYPE');
        IF (l_conversion_type IS NULL) THEN
           l_conversion_type := 'User';
        END IF;

        --Get the max roll days from the profile.
        l_max_roll_days := FND_PROFILE.value('CSD_CURRENCY_MAX_ROLL');


        if (p_amount is null) then
            l_conv_amount := p_error_val;
        else
            l_conv_amount := gl_currency_api.convert_closest_amount_sql (
                    x_from_currency     => p_from_currency,
                    x_to_currency       => p_to_currency,
                    x_conversion_date   => p_conversion_date,
                    x_conversion_type   => l_conversion_type,
                    x_user_rate         => null,
                    x_amount            => p_amount,
                    x_max_roll_days     => l_max_roll_days);
            if l_conv_amount = -1 then     -- NO_RATE
                l_conv_amount := p_error_val;
            elsif l_conv_amount = -2 then  -- INVALID_CURRENCY
                l_conv_amount := p_error_val;
            end if;
        end if;
        return l_conv_amount;
    END CONVERT_CURRENCY;

END CSD_RETURNS_BI_UTIL;

/
