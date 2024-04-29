--------------------------------------------------------
--  DDL for Package OKC_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CURRENCY_API" AUTHID CURRENT_USER AS
/* $Header: OKCPCURS.pls 120.0 2005/05/25 22:51:33 appldev noship $ */

-- Exceptions used.
NO_RATE EXCEPTION;

INVALID_CURRENCY EXCEPTION;

-- Function Get_OU_Currency ( Org_ID IN NUMBER DEFAULT NULL )
-- Returns  Currency code
-- Parameters - If Org_ID IS NULL, then determines the functional currency
--              for the operating unit, using FND_Profile Org_ID.

FUNCTION GET_OU_CURRENCY ( p_ORG_ID IN NUMBER DEFAULT NULL )
RETURN VARCHAR2;


-- Function Get_SOB_Currency ( SOB_ID IN NUMBER )
-- Returns  Currency Code
-- Parameters - Set of Books ID needed.

FUNCTION GET_SOB_CURRENCY ( p_SOB_ID IN NUMBER )
RETURN VARCHAR2;


-- Function Get_OU_SOB ( ORG_ID IN NUMBER DEFAULT NULL )
-- Returns  SOB_ID
-- Parameters - If Org_ID is not provided, then determines the set of books for
--			 the current OU.

FUNCTION GET_OU_SOB ( p_ORG_ID IN NUMBER DEFAULT NULL )
RETURN NUMBER;


-- Function Get_OU_SOB_Name ( ORG_ID IN NUMBER DEFAULT NULL )
-- Returns  SOB Name
-- Parameters - If Org_ID is not provided, then determines the set of books for
--			 the current OU.

FUNCTION GET_OU_SOB_NAME ( p_ORG_ID IN NUMBER DEFAULT NULL )
RETURN VARCHAR2;


-- Function IS_User_Rate_Allowed ( From_Currency, To_Currency, Effective_Date )`
-- Returns  BOOLEAN
-- Parameters - Needs From currency, To currency and Effective date.
--              Effective date defaults to sysdate.
-- Desc     If there is a fixed relationship between the two currencies,
--          then USER rate type is not allowed.

FUNCTION IS_USER_RATE_ALLOWED ( p_FROM_CURRENCY IN VARCHAR2,
					       p_TO_CURRENCY   IN VARCHAR2,
					       p_EFFECTIVE_DATE IN DATE DEFAULT SYSDATE )
RETURN BOOLEAN;


-- Function Get_Rate ( From_Currency, To_currency, Conversion_date,
--                     Conversion_type, Conversion_Rate DEFAULT NULL )
-- Returns  Exchage Rate between the two currencies.
-- Parameters - All are needed. Conversion rate is expected only if the conversion
--              conversion type is USER. If USER is applicable, then the
--              conversion rate provided is returned, else obtained from
--              the system.

FUNCTION GET_RATE ( p_FROM_CURRENCY IN VARCHAR2,
				p_TO_CURRENCY   IN VARCHAR2,
				p_CONVERSION_DATE IN DATE,
				p_CONVERSION_TYPE IN VARCHAR2,
				p_CONVERSION_RATE IN NUMBER DEFAULT NULL )
RETURN NUMBER;


-- Procedure Get_Rate ( From_Currency, To_Currency, Conversion_Date,
--                     Conversion_type, Conversion_Rate, Euro_Rate );
-- Returns   Conversion_Rate and Euro_Rate.
-- Parameters - All parameters are needed. Conversion_rate is IN OUT,
--              and Euro_rate is OUT.
-- Desc      Conversion_rate is the exchange rate between the two currencies.
--           If the To currency is EMU, then the From currency to EURO rate
--           is also obtained.

PROCEDURE GET_RATE ( p_FROM_CURRENCY IN VARCHAR2,
				 p_TO_CURRENCY   IN VARCHAR2,
				 p_CONVERSION_DATE IN DATE,
				 p_CONVERSION_TYPE IN VARCHAR2,
				 x_CONVERSION_RATE IN OUT NOCOPY NUMBER,
				 x_EURO_RATE     OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2);

-- Procedure Validate_Conversion_Attribs ( From_Currency, To_Currency,
--                                         Conversion_date, Conversion_type,
--                                         Conversion_rate, Status, Message )
-- Parameters - All currency conversion parameters are needed.
-- Desc         Validates the currency conversion attributes.
--              The return status and message are set accordingly.

PROCEDURE VALIDATE_CONVERSION_ATTRIBS ( p_FROM_CURRENCY IN VARCHAR2,
                                        p_TO_CURRENCY   IN VARCHAR2,
                                        p_CONVERSION_DATE IN DATE,
                                        p_CONVERSION_TYPE IN VARCHAR2,
                                        p_CONVERSION_RATE IN NUMBER,
                                        x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
                                        x_MESSAGE        OUT NOCOPY VARCHAR2 );


-- Procedure Convert_Amount ( From_Currency, To_Currency, Conversion_Date,
--                            Conversion_Type, Amount, Conversion_Rate, Converted_Amount);
-- Parameters - From Currency, To Currency, Rate Type, Conversion Date,
--              Conversion rate needed if User rate type used and Converted amount
--              is returned.
-- Desc      Provides the converted amount.

PROCEDURE CONVERT_AMOUNT ( p_FROM_CURRENCY IN VARCHAR2,
					  p_TO_CURRENCY   IN VARCHAR2,
					  p_CONVERSION_DATE IN DATE,
					  p_CONVERSION_TYPE IN VARCHAR2,
					  p_AMOUNT          IN     NUMBER,
					  x_CONVERSION_RATE IN OUT NOCOPY NUMBER,
					  x_CONVERTED_AMOUNT   OUT NOCOPY NUMBER );

-- Procedure Get_Info ( Currency, Effective_Date, Rate. MAU, Type )
-- Parameters - Currency and effective date are needed.
-- Returns      The Derive Type, Derive Factor for Euro related currencies,
--              and the Minimum Accountable Unit.

PROCEDURE GET_INFO( p_currency  VARCHAR2,
	            p_eff_date  DATE,
	            x_conversion_rate   IN OUT NOCOPY    NUMBER,
		    x_mau               IN OUT NOCOPY    NUMBER,
		    x_currency_type     IN OUT NOCOPY    VARCHAR2 ) ;


-- Function Get_Currency_Type ( Currency, Effective Date)
-- Returns  Derive Type for the currency
-- Parameters are needed.
-- Desc     Provides the type of currency whether EURO, EMU or OTHER.

FUNCTION GET_CURRENCY_TYPE( p_currency  VARCHAR2,
			    p_eff_date  DATE )
RETURN VARCHAR2;


-- Bug# 2155930 Euro Conversion

-- Function GET_EURO_CURRENCY_CODE ( Currency )
-- Returns  Equivalent Euro Code for the Currency, if applicable,
--          Else returns the Currency itslef.
-- Parameters are needed.
-- Desc     Provides the Euro currency code if EMU currency.
--          Needed for Post-EFC after 01-Jan-2002
--          And if SoB is already switched to EUR, using EFC.
--          Assumes the OKC Context is set, so it can call the
--          Get_OU_Currency api using the OKC Context.
--          Primarily intended for OKS Billing program.


FUNCTION GET_EURO_CURRENCY_CODE( p_currency VARCHAR2 )
RETURN VARCHAR2;


-- Function IS_EURO_CONVERSION_NEEDED ( Currency )
-- Returns  Y if Euro conversion needed - for EMU Currencies
-- Parameters are needed.
-- Desc     Y if Euro conversion needed.

FUNCTION IS_EURO_CONVERSION_NEEDED( p_currency VARCHAR2 )
RETURN VARCHAR2;

END OKC_CURRENCY_API;

 

/
