--------------------------------------------------------
--  DDL for Package PA_MULTI_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MULTI_CURRENCY" AUTHID CURRENT_USER AS
--$Header: PAXTMCTS.pls 120.1 2005/08/11 10:56:38 eyefimov noship $

--pragma RESTRICT_REFERENCES (pa_multi_currency,WNDS,WNPS);

-- Package Global Variables.

G_accounting_currency_code    VARCHAR2(15);
G_rate_date_code              VARCHAR2(1);
G_rate_type                   VARCHAR2(30);
no_rate                  EXCEPTION ;
invalid_currency         EXCEPTION ;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : check_rate_date_code
-- Type          : Public
-- Pre-Reqs      : None
-- Function      :Returns the value of the default_rate_date_code from
--                PA_IMPLEMENTATIONS
-- Purity        : WNDS, WNPS.
-- Parameters    :
-- IN            : None
-- RETURNS       : VARCHAR2
-- End of Comments
/*---------------------------------------------------------------------------*/


FUNCTION check_rate_date_code
RETURN VARCHAR2;
--pragma RESTRICT_REFERENCES(check_rate_date_code,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_acct_rate_type
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns the value of default rate_type from the
--                 pa_implemantations table
-- Parameters    :
--         IN    : None
--        OUT    : VARCHAR2
/*----------------------------------------------------------------------------*/
FUNCTION get_rate_type
RETURN varchar2;
--pragma RESTRICT_REFERENCES (get_rate_type,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_acct_currency_code
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : returns the Accounting Currency Code based on the set of
--                 books id of the user's responsibility.
-- Parameters    :
--         IN    : None
--        OUT    : VARCHAR2
/*----------------------------------------------------------------------------*/

FUNCTION get_acct_currency_code
RETURN VARCHAR2;
--pragma RESTRICT_REFERENCES(get_acct_currency_code,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : is_user_rate_type_allowed
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns 'Y' if 'USER' rate type is allowed.
--                 Returns 'N' otherwise.
-- Parameters    :
-- IN              Task_Id          NUMBER
--                 From Currency    VARCHAR2,
--                 To Currency      VARCHAR2,
--                 Conversion Date  DATE DEFAULT SYSDATE
-- OUT             VARCHAR2
/*----------------------------------------------------------------------------*/

FUNCTION  is_user_rate_type_allowed (P_from_currency    VARCHAR2,
                                     P_to_currency      VARCHAR2,
                                     P_conversion_date  DATE DEFAULT SYSDATE)
RETURN VARCHAR2 ;
--pragma RESTRICT_REFERENCES(is_user_rate_type_allowed,WNDS,WNPS );


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : convert_amount
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the converted amount based on the currency
--                 attributes. also, returns the exchange rate as well
--                 as error messages, if any.
-- Parameters    :
-- IN
--                          P_from_currency      VARCHAR2,
--		            P_to_currency        VARCHAR2,
--		            P_amount             NUMBER
--                          P_user_validate_flag VARCHAR2
--                          P_handle_exception_flag VARCHAR2
-- IN/OUT

--		            P_conversion_date    DATE DEFAULT SYSDATE,
--		            P_conversion_type    VARCHAR2,
--		            P_converted_amount   NUMBER,
--		            P_denominator        NUMBER,
--		            P_numerator          NUMBER,
--		            P_rate               NUMBER,
--                          X_status(OUT ONLY)   VARCHAR2

/*----------------------------------------------------------------------------*/
PROCEDURE convert_amount (
                    P_from_currency         IN       VARCHAR2,
		            P_to_currency           IN       VARCHAR2,
		            P_conversion_date       IN OUT NOCOPY DATE ,
		            P_conversion_type       IN OUT NOCOPY VARCHAR2,
		            P_amount                IN NUMBER,
			        P_user_validate_flag    IN VARCHAR2,
			        P_handle_exception_flag IN VARCHAR2 DEFAULT 'Y',
		            P_converted_amount      IN OUT NOCOPY NUMBER,
		            P_denominator           IN OUT NOCOPY NUMBER,
		            P_numerator             IN OUT NOCOPY NUMBER,
		            P_rate                  IN OUT NOCOPY NUMBER,
                    X_status                OUT NOCOPY VARCHAR2) ;

--pragma RESTRICT_REFERENCES(convert_amount,WNDS,WNPS);
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : convert_amount_sql
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : returns the converted amount based on the currency
--                 attributes.
-- Parameters    :
-- IN
--                          P_from_currency      VARCHAR2,
--		            P_to_currency        VARCHAR2,
--                          P_conversion_date    DATE,
--			    P_conversion_type	 VARCHAR2,
--		            P_Rate               NUMBER,
--		            P_amount             NUMBER
/*----------------------------------------------------------------------------*/
FUNCTION convert_amount_sql (
                             P_from_currency         VARCHAR2,
                             P_to_currency           VARCHAR2,
                             P_conversion_date       DATE,
                             P_conversion_type       VARCHAR2 DEFAULT NULL,
                             P_Rate                  NUMBER,
                             P_amount                NUMBER ) RETURN NUMBER;

--PRAGMA   RESTRICT_REFERENCES(convert_amount_sql,WNDS,WNPS);

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : convert_closest_amount
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : returns the converted amount based on the currency
--                 attributes. also, returns the exchange rate as well
--                 as error messages, if any.
--                 Makes use of the maxroll_days to get the rate if not
--                 found for the particular date.
-- Parameters    :
-- IN
--                          P_from_currency      VARCHAR2,
--                          P_to_currency        VARCHAR2,
--                          P_amount             NUMBER
--                          P_user_validate_flag VARCHAR2
--                          P_handle_exception_flag VARCHAR2
--                          P_maxroll_days	 NUMBER DEFAULT 0
-- IN/OUT

--                          P_conversion_date    DATE DEFAULT SYSDATE,
--                          P_conversion_type    VARCHAR2,
--                          P_converted_amount   NUMBER,
--                          P_denominator        NUMBER,
--                          P_numerator          NUMBER,
--                          P_rate               NUMBER,
--                          X_status(OUT ONLY)   VARCHAR2

PROCEDURE convert_closest_amount
                         (  P_from_currency         IN VARCHAR2,
                            P_to_currency           IN VARCHAR2,
                            P_conversion_date       IN OUT NOCOPY DATE ,
                            P_conversion_type       IN OUT NOCOPY VARCHAR2,
                            P_amount                IN NUMBER,
                            P_user_validate_flag    IN VARCHAR2,
                            P_handle_exception_flag IN VARCHAR2 DEFAULT 'Y',
			                P_maxroll_days          IN NUMBER   DEFAULT 0,
                            P_converted_amount      IN OUT NOCOPY NUMBER,
                            P_denominator           IN OUT NOCOPY NUMBER,
                            P_numerator             IN OUT NOCOPY NUMBER,
                            P_rate                  IN OUT NOCOPY NUMBER,
                            X_status                OUT NOCOPY VARCHAR2) ;


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : format_amount
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns the formatted amount based on the Currency Code
-- Parameters    :
-- IN              P_currency          IN   VARCHAR2
--                 P_amount            IN   NUMBER
--                 P_field_length      IN   NUMBER
--                 P_formatted_amount MUST be a VARCHAR2 field and MUST be
--		   atleast 10 characters longer than the field_length
-- OUT             P_formatted_amount  OUT  VARCHAR2
/*----------------------------------------------------------------------------*/
PROCEDURE format_amount (P_currency IN VARCHAR2,
			             P_amount   IN NUMBER,
			             P_field_length  IN NUMBER,
                         P_formatted_amount OUT NOCOPY VARCHAR2 );

/*------------------------------------------------------------------------------
 The following table is created to store The Currency Code and its associated
 Format Mask so that the FND API need not be called repeatedly. The procedure
 Format_amount first searches the table for the Currency Code and Format Mask
 and the FND API is called only if it is not found in this table. The new
 Currency and format msak is then stored in the table as well.
------------------------------------------------------------------------------*/

TYPE curr_mask IS RECORD (
     currency_code  VARCHAR2(15),
     format_mask    VARCHAR2(2000));
TYPE format is TABLE of curr_mask
 INDEX BY BINARY_INTEGER;
FormatMaskTab     format;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : validate_rate_type
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns 'Y' if valid rate type. returns 'N' otherwise
-- Parameters    :
-- IN              P_Rate_type          IN   VARCHAR2     Required
-- OUT             VARCHAR2
/*----------------------------------------------------------------------------*/
FUNCTION validate_rate_type ( P_rate_type VARCHAR2 )
RETURN varchar2 ;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : validate_currency_code
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns 'Y' if valid currency code. returns 'N' otherwise
-- Parameters    :
-- IN              P_currency_code          IN   VARCHAR2     Required
-- OUT             VARCHAR2
/*----------------------------------------------------------------------------*/
FUNCTION validate_currency_code ( P_Currency_code VARCHAR2,
                                  P_EI_date        DATE )
RETURN varchar2 ;
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : init
-- Type          : Public
-- Function      : Initializes the global variables by calling the
--                 appropriate functions.
-- Pre-Reqs      : None
-- Type          : Procedure
/*----------------------------------------------------------------------------*/

PROCEDURE init ;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : get_conversion_type
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Returns conversion rate type
-- Parameters    :
-- IN              P_User_Rate_type          IN   VARCHAR2     Required
-- OUT             VARCHAR2
/*----------------------------------------------------------------------------*/
FUNCTION get_conversion_type ( P_user_rate_type VARCHAR2 )
RETURN varchar2 ;

--PA-K Performance Improvement Changes
     G_PrevRateType      pa_conversion_types_v.conversion_type%TYPE;
     G_PrevUserRateType  pa_conversion_types_v.user_conversion_type%TYPE;
     G_CurrValid         VARCHAR2(1);
     G_PrevCurr          fnd_currencies_vl.currency_code%TYPE;
     G_PrevEiDate        DATE;


------------------------------------------------------------------------------
-- Function to get User_Conversion_Type value
------------------------------------------------------------------------------
FUNCTION Get_User_Conversion_Type ( P_Conversion_Type VARCHAR2 )
RETURN VARCHAR2;

END pa_multi_currency;

 

/
