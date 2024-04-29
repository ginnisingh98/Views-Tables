--------------------------------------------------------
--  DDL for Package Body GMF_GLCOMMON_DB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GLCOMMON_DB" AS
/*       $Header: gmfglcob.pls 115.1 2002/11/11 00:37:55 rseshadr ship $ */
/*    Returns the rate between the two currencies for a given rate*/
/*    date and rate type.*/
/**/
/*    If such a rate is not defined for the specified rate_date, it*/
/*    searches backward for a rate defined for the same currencies and*/
/*    conversion type.  It searches backward up to GL$MAX_ROLL_DAYS prior*/
/*    to the specified x_exchange_rate_date.*/
FUNCTION get_other_closest_rate (
                x_from_currency_code         VARCHAR2,
                x_to_currency_code           VARCHAR2,
                x_exchange_rate_date         Date,
                x_rate_type_code             VARCHAR2,
                x_max_roll_days              NUMBER ,
                x_mul_div_sign               OUT NOCOPY NUMBER ,
                error_status                 IN OUT NOCOPY NUMBER) RETURN NUMBER;

FUNCTION get_closest_rate (
                x_from_currency_code         VARCHAR2,
                x_to_currency_code           VARCHAR2,
                x_exchange_rate_date         DATE,
                x_rate_type_code             VARCHAR2 DEFAULT NULL,
                x_mul_div_sign               OUT NOCOPY NUMBER,
                error_status                 IN OUT NOCOPY NUMBER) RETURN NUMBER IS

CURSOR C_get_euro_code IS
SELECT currency_code
FROM gl_curr_mst
WHERE derive_type = 1 and
      delete_mark = 0;


    euro_code           VARCHAR2(15);
    to_type             VARCHAR2(8);
    from_type           VARCHAR2(8);
    to_rate             NUMBER;
    from_rate           NUMBER;
    other_rate          NUMBER;
    x_max_roll_days     NUMBER;
    mau                 NUMBER;
  BEGIN
	error_status := 0;
	x_mul_div_sign := 0;
     /* Check for the null parameters*/
     IF (x_from_currency_code is null or x_to_currency_code is null
        or x_exchange_rate_date is null or x_rate_type_code is null )
     THEN
        error_status := 100;
        return(-1);
     END IF;
     /* Check if both currencies are identical*/
     IF ( x_from_currency_code = x_to_currency_code ) THEN
        return( 1 );
     END IF;
     /* Get currency information from the x_from_currency_code*/
     get_info ( x_from_currency_code, x_exchange_rate_date, from_rate, mau,
                from_type,error_status );
     If (error_status = 100 ) THEN
        return(-1);
     END IF;
     /* Get currency information from the x_to_currency_code*/
     get_info ( x_to_currency_code, x_exchange_rate_date, to_rate, mau, to_type ,error_status);
     If (error_status = 100 ) THEN
        return(-1);
     END IF;
     /* Get the Max rollback days.*/
     x_max_roll_days := nvl(fnd_profile.value('GL$MAX_ROLL_DAYS'),-1);

	 /* Get the euro code */
	 OPEN C_get_euro_code;
	 FETCH C_get_euro_code INTO euro_code;
	 CLOSE C_get_euro_code;
     /* Calculate the conversion rate according to both currency types*/
     IF ( from_type = 'EMU' ) THEN
        IF ( to_type = 'EMU' ) THEN
                return( to_rate / from_rate );
        ELSIF ( to_type = 'EURO' ) THEN
                return( 1 / from_rate );
        ELSIF ( to_type = 'OTHER' ) THEN
/* Find out conversion rate from EURO to x_to_currency_code*/
           other_rate := get_other_closest_rate( euro_code,
                                        x_to_currency_code,
                                        x_exchange_rate_date,
                                        x_rate_type_code,
                                        x_max_roll_days,
                                        x_mul_div_sign,
                                        error_status );

                /* Get conversion rate by converting  EMU -> EURO -> OTHER*/
                return( other_rate / from_rate );
        END IF;
     ELSIF ( from_type = 'EURO' ) THEN
        IF ( to_type = 'EMU' ) THEN
                return( to_rate );
        ELSIF ( to_type = 'EURO' ) THEN
                /* We should never comes to this case as it should be*/
                /* caught when we check if both to and from currency*/
                /* is the same at the beginning of this function*/
                return( 1 );
        ELSIF ( to_type = 'OTHER' ) THEN
                other_rate := get_other_closest_rate( x_from_currency_code,
                                                      x_to_currency_code,
                                                      x_exchange_rate_date,
                                                      x_rate_type_code,
                                                      x_max_roll_days,
                                                      x_mul_div_sign,
                                                      error_status );
                return( other_rate );
        END IF;
ELSIF ( from_type = 'OTHER' ) THEN
        IF ( to_type = 'EMU' ) THEN
                /* Find out conversion rate from x_from_currency_code to EURO*/
  other_rate := get_other_closest_rate( x_from_currency_code,
                                                      euro_code,
                                                      x_exchange_rate_date,
                                                      x_rate_type_code,
                                                      x_max_roll_days,
                                                      x_mul_div_sign,
                                                      error_status );

                /* Get conversion rate by converting OTHER -> EURO -> EMU*/
                return( other_rate * to_rate );
        ELSIF ( to_type = 'EURO' ) THEN
                other_rate := get_other_closest_rate( x_from_currency_code,
                                                      x_to_currency_code,
                                                      x_exchange_rate_date,
                                                      x_rate_type_code,
                                                      x_max_roll_days,
                                                      x_mul_div_sign,
                                                      error_status );
                return( other_rate );
        ELSIF ( to_type = 'OTHER' ) THEN
                other_rate := get_other_closest_rate( x_from_currency_code,
                                                      x_to_currency_code,
                                                      x_exchange_rate_date,
                                                      x_rate_type_code,
                                                      x_max_roll_days,
                                                      x_mul_div_sign,
                                                      error_status );
                return( other_rate );
        END IF;
     END IF;
     return (-1);
  END get_closest_rate;

/*    Returns conversion rate between two currencies where both currencies*/
/*    are not the EURO, or EMU currencies.*/
FUNCTION get_other_closest_rate (
                x_from_currency_code         VARCHAR2,
                x_to_currency_code           VARCHAR2,
                x_exchange_rate_date         Date,
                x_rate_type_code             VARCHAR2,
                x_max_roll_days              NUMBER ,
                x_mul_div_sign               OUT NOCOPY NUMBER,
                error_status                 IN OUT NOCOPY NUMBER) RETURN NUMBER IS
    /* This cursor finds the latest rate defined between the given two*/
    /* currencies using x_rate_type_code within the period between*/
    /* x_max_roll_days prior to x_exchange_rate_date AND x_exchange_rate_date.*/
    CURSOR closest_rate_curr IS
      SELECT exchange_rate,mul_div_sign
      FROM   GL_XCHG_RTE
      WHERE  from_currency_code   = x_from_currency_code
      AND    to_currency_code     = x_to_currency_code
      AND    rate_type_code = x_rate_type_code
      AND    exchange_rate_date BETWEEN
                decode( sign (x_max_roll_days),
                        -1, trunc(to_date('1000/01/01', 'YYYY/MM/DD')),
                        trunc(x_exchange_rate_date - x_max_roll_days))
                AND x_exchange_rate_date
		and delete_mark = 0
      ORDER BY exchange_rate_date DESC;
    rate NUMBER;
  BEGIN
   /* Search backwards for a conversion rate with the given currencies*/
           /* and conversion type.*/
          OPEN closest_rate_curr;
          FETCH closest_rate_curr INTO rate,x_mul_div_sign;
          IF NOT closest_rate_curr%FOUND THEN
	    close closest_rate_curr;
            raise NO_RATE;
          ELSE
	 	error_status := 0;
		close closest_rate_curr;
            	return( rate );
          END IF;
EXCEPTION
     /* No conversion rate was found on the given conversion date.*/
     /* Try to search for the latest conversion rate with a prior conversion*/
     /* date then x_exchange_rate_date.*/
     WHEN NO_RATE THEN
        error_status := 100;
        return(-1);
        /*  raise NO_RATE;*/
END get_other_closest_rate;

/*    Gets the currency type information about given currency.*/
/*    Also set the x_invalid_currency flag if the given currency is invalid.*/
PROCEDURE get_info(
                x_currency                      VARCHAR2,
                x_eff_date                      DATE,
                x_exchange_rate                 IN OUT  NOCOPY NUMBER,
                x_mau                           IN OUT  NOCOPY NUMBER,
                x_currency_type                 IN OUT  NOCOPY VARCHAR2,
                error_status                    IN OUT  NOCOPY NUMBER ) IS
  BEGIN
     error_status := 0;
     /* Get currency information from GL_CURR_MST table*/
     SELECT decode( derive_type,
                    1, 'EURO',
                    2, decode( sign( trunc(x_eff_date) -
                                         trunc(derive_effective)),
                                   -1, 'OTHER',
                                   'EMU'),
                    'OTHER' ),
            decode( derive_type, 1, 1,
                                 2, derive_factor,
                                 0, -1 ),
            nvl( decimal_precision, power( 10, (-1 * decimal_precision)))
     INTO   x_currency_type,
            x_exchange_rate,
            x_mau
     FROM   gl_curr_mst
     WHERE  currency_code = x_currency;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          error_status := 100;
/*        raise INVALID_CURRENCY;*/
  END get_info;

/*    Returns if there is a fixed rate between the two currencies.*/
FUNCTION is_fixed_rate (
                x_from_currency         VARCHAR2,
                x_to_currency           VARCHAR2,
                x_effective_date        DATE    ,
                error_status            IN OUT NOCOPY NUMBER  ) RETURN VARCHAR2 IS

    to_type             VARCHAR2(8);
    from_type           VARCHAR2(8);
    rate                NUMBER;      /* Value ignored in this function*/
    mau                 NUMBER;      /* Value ignored in this function*/
  BEGIN
     error_status := 0;
     /* Check for the null parameters*/
     IF (x_from_currency is null or x_to_currency is null
        or x_effective_date is null )
     THEN
        error_status := 100;
        return 'N';
     END IF;
     /* Check if both currencies are identical*/
     IF ( x_from_currency = x_to_currency ) THEN
        return 'Y';
     END IF;
     /* Get currency information of the x_from_currency*/
     get_info( x_from_currency, x_effective_date, rate, mau, from_type,error_status );
     If (error_status = 100 ) THEN
        return 'N';
     END IF;
     /* Get currency information of the x_to_currency*/
     get_info( x_to_currency, x_effective_date, rate, mau, to_type,error_status );
     If (error_status = 100 ) THEN
        return 'N';
     END IF;
     /* Check if there is a fixed rate between the two given currencies*/
     IF (( from_type IN ('EMU', 'EURO')) AND
         ( to_type IN ('EMU', 'EURO'))) THEN
        return 'Y';
     ELSE
        return 'N';
     END IF;
  END is_fixed_rate;

  PROCEDURE proc_get_closest_rate(
                x_from_currency_code         VARCHAR2,
                x_to_currency_code           VARCHAR2,
                x_exchange_rate_date         DATE,
                x_rate_type_code             VARCHAR2 DEFAULT NULL,
                x_exchange_rate              OUT NOCOPY NUMBER,
                x_mul_div_sign               OUT NOCOPY NUMBER,
                error_status                 IN OUT NOCOPY NUMBER) is
  BEGIN
         x_exchange_rate := get_closest_rate(
				x_from_currency_code,
				x_to_currency_code,
				x_exchange_rate_date,
				x_rate_type_code,
                                x_mul_div_sign,
				error_status);
  END;

  PROCEDURE proc_is_fixed_rate(
                x_from_currency         VARCHAR2,
                x_to_currency           VARCHAR2,
                x_effective_date        DATE    ,
                x_fixed_check           OUT NOCOPY VARCHAR2,
                error_status            IN OUT NOCOPY NUMBER) is
  BEGIN
	x_fixed_check := is_fixed_rate(
				x_from_currency,
				x_to_currency,
				x_effective_date,
				error_status);
  END;

END GMF_GLCOMMON_DB;

/
