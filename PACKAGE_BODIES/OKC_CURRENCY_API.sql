--------------------------------------------------------
--  DDL for Package Body OKC_CURRENCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CURRENCY_API" AS
/* $Header: OKCPCURB.pls 120.1 2006/02/27 14:17:38 hvaladip noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Function Get_OU_Currency ( Org_ID IN NUMBER )
-- Returns  Currency code
-- Parameters - If Org_ID IS NULL, then determines the functional currency
--              for the operating unit, using FND_Profile Org_ID.

G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

FUNCTION GET_OU_CURRENCY ( p_ORG_ID IN NUMBER )
RETURN VARCHAR2
IS

  l_org_id number;
  l_curr_code varchar2(10);

Begin
  l_org_id := p_org_id;

  IF l_org_id IS NULL then
     fnd_profile.get('ORG_ID',l_org_id);
  END IF;

  /****
    commented to avoid OKX and performance issue
    bug# 5030628

  select gl.currency_code
  into   l_curr_code
  from   okx_set_of_books_v gl,
	    okx_organization_defs_v ou
  where  ou.id1 = l_org_id
  and    ou.organization_type = 'OPERATING_UNIT'
  and    ou.information_type = 'Operating Unit Information'
  and    gl.set_of_books_id = ou.set_of_books_id ;
  ***/

  select gl.currency_code
  into   l_curr_code
  from   HR_ORGANIZATION_INFORMATION OI2,
         HR_ORGANIZATION_INFORMATION OI1,
	    HR_ALL_ORGANIZATION_UNITS OU,
	    GL_SETS_OF_BOOKS gl
  where oi1.organization_id = ou.organization_id
  and   oi2.organization_id = ou.organization_id
  and   oi1.org_information_context = 'CLASS'
  and   oi1.org_information1 = 'OPERATING_UNIT'
  and   oi2.org_information_context =  'Operating Unit Information'
  and   oi2.ORG_INFORMATION3 = gl.set_of_books_id
  and   ou.organization_id = l_org_id;


  Return l_curr_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

    return NULL;

END GET_OU_CURRENCY;


-- Function Get_SOB_Currency ( SOB_ID IN NUMBER )
-- Returns  Currency Code
-- Parameters - Set of Books ID needed.

FUNCTION GET_SOB_CURRENCY ( p_SOB_ID IN NUMBER )
RETURN VARCHAR2
IS

  l_curr_code varchar2(10);

BEGIN

  select currency_code
  into   l_curr_code
  from   okx_set_of_books_v
  where  set_of_books_id = p_sob_id;

  Return l_curr_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    return NULL;

END GET_SOB_CURRENCY  ;


-- Function Get_OU_SOB ( ORG_ID IN NUMBER  )
-- Returns  SOB_ID
-- Parameters - If Org_ID is not provided, then determines the set of books for
--			 the current OU.

FUNCTION GET_OU_SOB ( p_ORG_ID IN NUMBER )
RETURN NUMBER
IS

  l_org_id number;
  l_sob_id number;

BEGIN

  l_org_id := p_org_id;

  IF p_org_id IS NULL then
	fnd_profile.get('ORG_ID',l_org_id);
  END IF;

  /*****
    commented to avoid OKX and performance issue
    bug# 5030628

  select ou.set_of_books_id
  into   l_sob_id
  from   okx_organization_defs_v ou where  ou.id1 = l_org_id and    ou.organization_type = 'OPERATING_UNIT'
  and    ou.information_type = 'Operating Unit Information';
  *******/

  select oi2.ORG_INFORMATION3
  into   l_sob_id
  from   HR_ORGANIZATION_INFORMATION OI2,
         HR_ORGANIZATION_INFORMATION OI1,
	    HR_ALL_ORGANIZATION_UNITS OU
  where oi1.organization_id = ou.organization_id
  and   oi2.organization_id = ou.organization_id
  and   oi1.org_information_context = 'CLASS'
  and   oi1.org_information1 = 'OPERATING_UNIT'
  and   oi2.org_information_context =  'Operating Unit Information'
  and   ou.organization_id = l_org_id;

  Return l_sob_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    return NULL;

END GET_OU_SOB;


-- Function Get_OU_SOB_Name ( ORG_ID IN NUMBER )
-- Returns  SOB Name
-- Parameters - If Org_ID is not provided, then determines the set of books for
--			 the current OU.

FUNCTION GET_OU_SOB_NAME ( p_ORG_ID IN NUMBER )
RETURN VARCHAR2
IS

  l_org_id number;
  l_sob_name varchar2(30);

BEGIN

  l_org_id := p_org_id;

  IF p_org_id IS NULL then
     fnd_profile.get('ORG_ID',l_org_id);
  END IF;

  /****
    commented to avoid OKX and performance issue
    bug# 5030628

  select gl.name
  into   l_sob_name
  from   okx_organization_defs_v ou,
	    okx_set_of_books_v gl
  where  ou.id1 = l_org_id
  and    ou.organization_type = 'OPERATING_UNIT'
  and    ou.information_type = 'Operating Unit Information'
  and    gl.set_of_books_id = ou.set_of_books_id;
  ****/

  select gl.name
  into   l_sob_name
  from   HR_ORGANIZATION_INFORMATION OI2,
         HR_ORGANIZATION_INFORMATION OI1,
	    HR_ALL_ORGANIZATION_UNITS OU,
	    GL_SETS_OF_BOOKS gl
  where oi1.organization_id = ou.organization_id
  and   oi2.organization_id = ou.organization_id
  and   oi1.org_information_context = 'CLASS'
  and   oi1.org_information1 = 'OPERATING_UNIT'
  and   oi2.org_information_context =  'Operating Unit Information'
  and   oi2.ORG_INFORMATION3 = gl.set_of_books_id
  and   ou.organization_id = l_org_id;


  Return l_sob_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    return NULL;

END GET_OU_SOB_NAME;


-- Function IS_User_Rate_Allowed ( From_Currency, To_Currency, Effective_Date )`
-- Returns  BOOLEAN
-- Parameters - Needs From currency, To currency and Effective date.
--              Effective date defaults to sysdate.
-- Desc     If there is a fixed relationship between the two currencies,
--          then USER rate type is not allowed.

FUNCTION IS_USER_RATE_ALLOWED ( p_FROM_CURRENCY IN VARCHAR2,
				p_TO_CURRENCY   IN VARCHAR2,
				p_EFFECTIVE_DATE IN DATE )
RETURN BOOLEAN
IS

BEGIN

  IF gl_currency_api.is_fixed_rate( p_from_currency, p_to_currency,
							 p_effective_date ) = 'Y' then
     Return FALSE;
  ELSE Return TRUE;
  END IF;

END IS_USER_RATE_ALLOWED;


-- Function Get_Rate ( From_Currency, To_currency, Conversion_date,
--                     Conversion_type, Conversion_Rate )
-- Returns  Exchage Rate between the two currencies.
-- Parameters - All are needed. Conversion rate is expected only if the conversion
--              conversion type is USER. If USER is applicable, then the
--              conversion rate provided is returned, else obtained from
--              the system.

FUNCTION GET_RATE ( p_FROM_CURRENCY IN VARCHAR2,
	            p_TO_CURRENCY   IN VARCHAR2,
		    p_CONVERSION_DATE IN DATE,
		    p_CONVERSION_TYPE IN VARCHAR2,
		    p_CONVERSION_RATE IN NUMBER  )
RETURN NUMBER
IS

  l_rate number;

BEGIN

  IF p_conversion_type = 'User' then
	IF IS_User_Rate_Allowed(p_from_currency, p_to_currency, p_conversion_date) then
	   Return p_conversion_rate;
     Else
	   Return -1;
     End IF;
  ELSE
	Return gl_currency_api.get_rate(p_from_currency, p_to_currency,
					 p_conversion_date, p_conversion_type);
  END IF;

END GET_RATE;

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
		     x_EURO_RATE     OUT NOCOPY NUMBER ,
                     x_return_status OUT NOCOPY VARCHAR2)
IS

  l_rate number;
  l_euro_rate number;
  l_fixed_rate boolean;
  l_relation varchar2(15);
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  l_rate := get_rate(p_from_currency, p_to_currency, p_conversion_date, p_conversion_type,x_conversion_rate);

  IF l_rate = -1 then
    l_return_status  := OKC_API.G_RET_STS_ERROR; -- 'user' conversion type is not allowed
    OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_USER_CONVERSION');
  ELSE
	gl_currency_api.get_relation(p_from_currency, p_to_currency, p_conversion_date, l_fixed_rate, l_relation);
     IF l_relation in ('OTHER-EMU','EMU-EMU','EURO-EMU') then
	   IF p_conversion_type = 'User' then

		 l_euro_rate := x_conversion_rate / get_rate(gl_currency_api.get_euro_code, p_to_currency, p_conversion_date, p_conversion_type);
        ELSE
	      l_euro_rate := get_rate(p_from_currency,gl_currency_api.get_euro_code, p_conversion_date, p_conversion_type);
        END IF;
     END IF;
  END IF;
  x_euro_rate := l_euro_rate;
  x_conversion_rate := l_rate;
  x_return_status := l_return_status;

EXCEPTION
  WHEN gl_currency_api.no_rate THEN
   x_return_status  := OKC_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_NO_CONVERSION_RATE');
   --RAISE no_rate;
  WHEN gl_currency_api.invalid_currency THEN
   x_return_status  := OKC_API.G_RET_STS_ERROR;
   OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_INVALID_CURRENCY');
 --  RAISE invalid_currency;
  WHEN OTHERS THEN
     x_return_status :=  OKC_API.G_RET_STS_UNEXP_ERROR;
END GET_RATE;

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
                                        x_MESSAGE        OUT NOCOPY VARCHAR2 )
IS

  l_rate number;
  l_euro_rate number;
  l_fixed_rate boolean;
  l_relation varchar2(15);

BEGIN

  x_return_status := 'S';

  gl_currency_api.get_relation(p_from_currency, p_to_currency, p_conversion_date,
                				    l_fixed_rate, l_relation);

  IF p_conversion_type IS NULL then
     x_return_status := 'E';
     x_message := 'OKC_CONV_TYPE_NEEDED';
     return;
  ELSIF p_conversion_date IS NULL then
     x_return_status := 'E';
     x_message := 'OKC_CONV_DATE_NEEDED';
     return;
  ELSIF p_conversion_rate IS NULL then
     x_return_status := 'E';
     x_message := 'OKC_CONV_RATE_NEEDED';
     return;
  END IF;

  IF IS_User_Rate_Allowed( p_from_currency, p_to_currency, p_conversion_date) then
     IF p_conversion_type = 'User' and p_conversion_rate IS NULL then
        x_return_status := 'E';
        x_message := 'OKC_CONV_RATE_NEEDED';
        return;
     END IF;
  ELSE
     IF p_conversion_type = 'User' then
        x_return_status := 'E';
        x_message := 'OKC_CONV_TYPE_USER_NOT_ALLOWED';
        return;
     END IF;
  END IF;

END VALIDATE_CONVERSION_ATTRIBS;


-- Procedure Convert_Amount ( From_Currency, To_Currency, Conversion_Date,
--                            Conversion_Type, Conversion_Rate, Converted_Amount);
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
			   x_CONVERTED_AMOUNT   OUT NOCOPY NUMBER )
IS
  l_converted_amount number;
  l_conversion_rate  number;
  l_denom_rate       number;
  l_num_rate         number;

BEGIN

  gl_currency_api.convert_closest_amount(p_from_currency, p_to_currency,
					 p_conversion_date, p_conversion_type,
					 x_conversion_rate, p_amount, 0,
					 l_converted_amount, l_denom_rate,
					 l_num_rate, l_conversion_rate);

  x_converted_amount := l_converted_amount;
  x_conversion_rate  := l_conversion_rate;

END CONVERT_AMOUNT;


-- Procedure Get_Info ( Currency, Effective_Date, Rate. MAU, Type )
-- Parameters - Currency and effective date are needed.
-- Returns      The Derive Type, Derive Factor for Euro related currencies,
--              and the Minimum Accountable Unit.

PROCEDURE GET_INFO( p_currency  VARCHAR2,
	            p_eff_date  DATE,
	            x_conversion_rate   IN OUT NOCOPY    NUMBER,
		    x_mau               IN OUT NOCOPY    NUMBER,
		    x_currency_type     IN OUT NOCOPY    VARCHAR2 ) IS

BEGIN
-- Get currency information from FND_CURRENCIES table
   SELECT decode( derive_type,
    		'EURO', 'EURO',
     		'EMU', decode( sign( trunc(p_eff_date) - trunc(derive_effective)),
			                -1, 'OTHER', 'EMU'),
		      'OTHER' ),
		 decode( derive_type,
		        'EURO', 1,
		        'EMU', derive_factor,
			'OTHER', -1 ),
	     nvl( minimum_accountable_unit, power( 10, (-1 * precision)))
   INTO   x_currency_type, x_conversion_rate, x_mau
   FROM   FND_CURRENCIES
   WHERE  currency_code = p_currency;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN

    x_conversion_rate := null;
    x_mau := null;
    x_currency_type := null;
END GET_INFO;

-- Function Get_Currency_Type ( Currency, Effective Date)
-- Returns  Derive Type for the currency
-- Parameters are needed.
-- Desc     Provides the type of currency whether EURO, EMU or OTHER.

FUNCTION GET_CURRENCY_TYPE( p_currency  VARCHAR2,
			    p_eff_date  DATE )
RETURN VARCHAR2
IS
   l_currency_type varchar2(10);

BEGIN
-- Get currency information from FND_CURRENCIES table

   SELECT decode( derive_type,
    		'EURO', 'EURO',
     		'EMU', decode( sign( trunc(p_eff_date) - trunc(derive_effective)),
			                -1, 'OTHER', 'EMU'),
		      'OTHER' )
   INTO   l_currency_type
   FROM   FND_CURRENCIES
   WHERE  currency_code = p_currency;

   Return l_currency_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    return NULL;


END GET_CURRENCY_TYPE;

-- Bug# 2155930 Euro conversion

-- Function GET_EURO_CURRENCY_CODE ( Currency )
-- Returns  Equivalent Euro Code for the Currency, if applicable,
--          Else returns the Currency itslef.
-- Parameters are needed.
-- Desc     Provides the Euro currency code if EMU currency.
--          Needed for Post-EFC scenario after 01-Jan-2002.
--          And if SoB is already switched to EUR, using EFC.
--          Assumes the OKC Context is set, so it can call the
--          Get_OU_Currency api using the OKC Context.
--          Primarily intended for OKS Billing program.

FUNCTION GET_EURO_CURRENCY_CODE( p_currency VARCHAR2 )
RETURN VARCHAR2
IS
   l_currency_type varchar2(10);
   l_curr_euro varchar2(5);
BEGIN

   l_currency_type := GET_CURRENCY_TYPE( p_currency, sysdate );
--   l_curr_euro := gl_currency_api.get_euro_code; /* Bugfix 2256060 - This line is moved after checking the currency_type */


/* If the OKC Context is not set  then Org_ID would be returned as NULL
   and the fnd_profile would be used.
   If the context returns -99, then get_ou_curr api will return NULL */

-- commented out sysdate check for testing.

   IF (l_currency_type = 'EMU' ) then
      l_curr_euro := gl_currency_api.get_euro_code; /* Bugfix 2256060 - moved this line from above */
--       and sysdate >= to_date('01-jan-2002','dd-mon-yyyy')
      IF (get_ou_currency(okc_context.get_okc_org_id) = l_curr_euro )    then
         return l_curr_euro;
      ELSE
         return p_currency;
      END IF;
   ELSE
	 return p_currency;
   END IF;

EXCEPTION
   /* Bugfix 2256060 - Added the exception from GL to give a proper message */
   WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
	 OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_NO_EURO_CURR'); /* Bugfix 2256060 - added new message */
	 raise;
   WHEN OTHERS THEN
      raise;

END GET_EURO_CURRENCY_CODE;


-- Function IS_EURO_CONVERSION_NEEDED ( Currency )
-- Returns  Y if Euro conversion needed - for EMU Currencies
-- Parameters are needed.
-- Desc     Y if Euro conversion needed.
--          Needed for Post-EFC scenario after 01-Jan-2002.

FUNCTION IS_EURO_CONVERSION_NEEDED( p_currency VARCHAR2 )
RETURN VARCHAR2
IS
   l_currency_type varchar2(10);

BEGIN

   l_currency_type := GET_CURRENCY_TYPE( p_currency, sysdate );

-- commented out sysdate check for testing.

   IF (l_currency_type = 'EMU' ) then
 --      and sysdate >= to_date('01-jan-2002','dd-mon-yyyy') ) then
      return  'Y';
   ELSE
      return 'N';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;

END IS_EURO_CONVERSION_NEEDED;

END OKC_CURRENCY_API;

/
