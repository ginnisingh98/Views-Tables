--------------------------------------------------------
--  DDL for Package Body PO_CURRENCY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CURRENCY_SV" AS
/* $Header: POXDOCUB.pls 120.0.12010000.2 2010/07/30 07:20:19 dashah ship $*/

g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

/*===========================================================================

 FUNCTION NAME :  val_currency()

===========================================================================*/
g_pkg_name CONSTANT VARCHAR2(20) := 'PO_CURRENCY_SV'; --<Shared Proc FPJ>

FUNCTION  val_currency(X_currency_code IN VARCHAR2) return BOOLEAN IS

  X_progress 	     varchar2(3)  := NULL;
  X_currency_code_v  varchar2(15) := NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Currency is active */

  SELECT  currency_code
  INTO    X_currency_code_v
  FROM    fnd_currencies
  WHERE   enabled_flag = 'Y'
  AND	  sysdate between nvl(start_date_active, sysdate - 1)
  AND	  nvl(end_date_active, sysdate + 1)
  AND	  currency_code = X_currency_code;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
    po_message_s.sql_error('val_currency',X_progress,sqlcode);
    raise;

END val_currency;

/*===========================================================================

   PROCEDURE NAME:	get_rate()

===========================================================================*/

PROCEDURE get_rate(x_set_of_books_id              IN     NUMBER,
                   x_currency_code                IN     VARCHAR2,
                   x_rate_type                    IN     VARCHAR2,
                   x_rate_date                    IN     DATE,
                   x_inverse_rate_display_flag    IN     VARCHAR2,
                   x_rate                         IN OUT NOCOPY NUMBER,
                   x_display_rate                 IN OUT NOCOPY NUMBER) IS


x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   -- the check for X_inverse_rate_display_flag is done here
   -- decode if X_inverse_rate_display_flag (in parameter from the client)
   -- Y then x_ display_rate  1/conversion_rate else x_ display_rate
   -- conversion rate

   x_rate := gl_currency_api.get_rate(x_set_of_books_id,
				      x_currency_code,
				      x_rate_date,
				      x_rate_type);

   IF (x_inverse_rate_display_flag = 'Y') THEN

       x_display_rate := 1/x_rate;

   ELSE

       x_display_rate := x_rate;

   END IF;

   x_rate := ROUND(x_rate, 15);
   x_display_rate := ROUND(x_display_rate, 15);

   RETURN;


   EXCEPTION

/* DEBUG: Once no_rate is defined by gl then put this exception
   handling back in
   WHEN NO_RATE THEN
    RETURN;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_rate', x_progress, sqlcode);
   RAISE;
*/
    when gl_currency_api.no_rate then
         -- dbms_output.put_line('No Rate');
         return;
    when gl_currency_api.invalid_currency then
         -- dbms_output.put_line('Invalid Currency');
         return;
    WHEN OTHERS THEN
      po_message_s.sql_error('get_rate', x_progress, sqlcode);
      RAISE;

END get_rate;

/*===========================================================================

  PROCEDURE NAME:	test_get_rate()

===========================================================================*/
PROCEDURE test_get_rate(x_set_of_books_id         IN     NUMBER,
                   x_currency_code                IN     VARCHAR2,
                   x_rate_type                    IN     VARCHAR2,
                   x_rate_date                    IN     DATE,
                   x_inverse_rate_display_flag    IN     VARCHAR2) IS



x_progress VARCHAR2(3)      := NULL;
x_display_rate                 NUMBER;
x_rate                         NUMBER;
xx_inverse_rate_display_flag   VARCHAR2(3) := '';


BEGIN


   -- DBMS_OUTPUT.PUT_LINE('x_set_of_books_id = ' || x_set_of_books_id);
   -- DBMS_OUTPUT.PUT_LINE('x_currency_code   = ' || x_currency_code  );
   -- DBMS_OUTPUT.PUT_LINE('x_rate_type       = ' || x_rate_type      );
   -- DBMS_OUTPUT.PUT_LINE('x_rate_date       = ' || x_rate_date      );
   -- DBMS_OUTPUT.PUT_LINE('x_inverse_rate_display_flag =' ||
   -- Bug 155260     x_inverse_rate_display_flag);

   xx_inverse_rate_display_flag := x_inverse_rate_display_flag;

   po_currency_sv.get_rate (x_set_of_books_id, x_currency_code,
		x_rate_type, x_rate_date, x_inverse_rate_display_flag,
                x_rate,  x_display_rate);



   -- DBMS_OUTPUT.PUT_LINE ('X_RATE = ' || x_rate);
   -- DBMS_OUTPUT.PUT_LINE ('X_DISPLAY_RATE = ' || x_display_rate);


   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_rate', x_progress, sqlcode);
   RAISE;


END test_get_rate;



/*===========================================================================

  PROCEDURE NAME:	get_rate_type_disp()

===========================================================================*/
PROCEDURE get_rate_type_disp(x_rate_type	IN     VARCHAR2,
			     x_rate_type_disp   IN OUT NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3)      := NULL;

BEGIN

   x_progress := '010';

   SELECT dct.user_conversion_type
   INTO   x_rate_type_disp
   FROM   gl_daily_conversion_types  dct
   WHERE  dct.conversion_type = x_rate_type;



   EXCEPTION
   when no_data_found then
   x_rate_type_disp := null;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_rate_type_disp', x_progress, sqlcode);
   RAISE;


END get_rate_type_disp;

/*===========================================================================

  PROCEDURE NAME:	validate_currency_info()

===========================================================================*/

 PROCEDURE validate_currency_info(
       p_cur_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.CurRecType) IS


 cursor C is SELECT start_date_active, end_date_active,
                   enabled_flag
             FROM fnd_currencies
             WHERE fnd_currencies.currency_code = p_cur_record.currency_code;

 X_cur_record  C%ROWTYPE;
 X_sysdate     DATE := sysdate;

 BEGIN

    OPEN C;
    FETCH C INTO X_cur_record;

    IF C%NOTFOUND THEN

       p_cur_record.error_record.error_status  := 'E';
       p_cur_record.error_record.error_message := 'CURRENCY_INVALID';
       RETURN;

    ELSE

       IF not (nvl(X_cur_record.enabled_flag,'N') = 'Y' and
              (X_sysdate between
                  nvl(X_cur_record.start_date_active, X_sysdate - 1) and
                  nvl(X_cur_record.end_date_active, X_sysdate + 1))) THEN

           p_cur_record.error_record.error_status := 'E';
           p_cur_record.error_record.error_message := 'CURRENCY_DISABLED';
           RETURN;

       END IF;

      FETCH C INTO X_cur_record;

      IF C%NOTFOUND THEN

         p_cur_record.error_record.error_status := 'S';
         p_cur_record.error_record.error_message := NULL;
         return;

      ELSE

         p_cur_record.error_record.error_status := 'E';
         p_cur_record.error_record.error_message := 'TOOMANYROWS';
         RETURN;

      END IF;

    END IF;

 EXCEPTION
   WHEN others THEN

         p_cur_record.error_record.error_status := 'U';
         p_cur_record.error_record.error_message := sqlerrm;

 END validate_currency_info;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_FUNCTIONAL_CURRENCY_CODE
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure gets the Functional Currency assocaited with an Operating Unit
--Parameters:
--IN:
--p_org_id
--  The Operating Unit Id
--OUT:
--x_functional_currency_code
--  The functioanl currency assocaited with an Operating Unit
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_functional_currency_code(
         p_org_id                   IN NUMBER,
         x_functional_currency_code OUT NOCOPY VARCHAR2) IS

l_progress  VARCHAR2(3) := '001';
BEGIN

       SELECT sob.currency_code
       INTO  x_functional_currency_code
       FROM  gl_sets_of_books sob, financials_system_params_all fsp
       WHERE nvl(fsp.org_id, -99) = nvl(p_org_id, -99)
       AND  fsp.set_of_books_id = sob.set_of_books_id;

EXCEPTION
 WHEN OTHERS THEN
      po_message_s.sql_error('get_functional_currency_code', l_progress, sqlcode);
   RAISE;
END get_functional_currency_code;

  --
  -- Function
  --   rate_exists
  --
  -- Purpose
  --    Returns 'Y' if there is a conversion rate between the two currencies
  --                for a given conversion date and conversion type;
  --            'N' otherwise.
  --
  -- History
  --   04-SEP-03  M Bhargava        Created
  --
  -- Arguments
  --   p_from_currency          From currency
  --   p_to_currency            To currency
  --   p_conversion_date        Conversion date
  --   p_conversion_type        Conversion type
  --
FUNCTION rate_exists (
                p_from_currency         VARCHAR2,
                p_to_currency           VARCHAR2,
                p_conversion_date       DATE,
                p_conversion_type       VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2 IS
is_rate_defined  VARCHAR2(1);
l_api_name CONSTANT VARCHAR2(30) := 'rate_exists';
l_progress  VARCHAR2(3) := '000';
BEGIN
    is_rate_defined := gl_currency_api.rate_exists(
                             x_from_currency => p_from_currency,
                             x_to_currency => p_to_currency,
                             x_conversion_date => p_conversion_date,
                             x_conversion_type => p_conversion_type);
   return is_rate_defined;
EXCEPTION
 WHEN OTHERS THEN
      po_message_s.sql_error('rate_exists', l_progress, sqlcode);
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name,
              SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
      END IF;
      RAISE;
END rate_exists;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_RATE
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--   Returns the rate between the two currencies for a given conversion
--   date and conversion type.
--Parameters:
--IN:
--  p_from_currency
--     The currency that needs to be converted (generally PO's currency)
--  p_to_currency
--     The currency in which to convert (generally POU's functional currency)
--  p_rate_type
--     The rate type to use
--  p_rate_date
--     The rate date to use
--  p_inverse_rate_display_flag
--     Flag indicating whether the displayed value of rate is inverse of actual value
--OUT:
--  x_rate
--     Rate obtained from the API. Will be NULL if none is obtained
--  x_display_rate
--     Display rate depending of the value of p_inverse_rate_display_flag. Will
--     be NULL if none is obtained
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_rate(p_from_currency                IN     VARCHAR2,
                   p_to_currency                  IN     VARCHAR2,
                   p_rate_type                    IN     VARCHAR2,
                   p_rate_date                    IN     DATE,
                   p_inverse_rate_display_flag    IN     VARCHAR2,
                   x_rate                         OUT NOCOPY NUMBER,
                   x_display_rate                 OUT NOCOPY NUMBER,
                   x_return_status                OUT NOCOPY VARCHAR2,
                   x_error_message_name           OUT NOCOPY VARCHAR2)
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_rate';
l_progress VARCHAR2(3) := '000';

BEGIN

   l_progress := '010';

   -- the check for X_inverse_rate_display_flag is done here
   -- decode if X_inverse_rate_display_flag (in parameter from the client)
   -- Y then x_ display_rate  1/conversion_rate else x_ display_rate
   -- conversion rate

   x_rate := gl_currency_api.get_rate(p_from_currency,
				      p_to_currency,
				      p_rate_date,
				      p_rate_type);
   l_progress := '020';

   IF (p_inverse_rate_display_flag = 'Y') THEN

       x_display_rate := 1/x_rate;

   ELSE

       x_display_rate := x_rate;

   END IF;
   l_progress := '030';

   x_rate := ROUND(x_rate, 15);
   x_display_rate := ROUND(x_display_rate, 15);
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  when gl_currency_api.no_rate then
         -- dbms_output.put_line('No Rate');
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message_name := 'PO_CPO_NO_DEFAULT_RATE';
         return;
  when gl_currency_api.invalid_currency then
         -- dbms_output.put_line('Invalid Currency');
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_message_name := 'PO_INVALID_CURRENCY_CODE';
         return;
  WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name,
              SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
         END IF;
END get_rate;
--<Shared Proc FPJ END>

-- bug3294883 START

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_currency_precision
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--   Returns currency precision given the currency.
--Parameters:
--IN:
--p_currency
--  The currency code
--OUT:
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_currency_precision ( p_currency IN  VARCHAR2 )
RETURN NUMBER IS

l_precision     FND_CURRENCIES.precision%TYPE;
l_ext_precision FND_CURRENCIES.extended_precision%TYPE;
l_min_acct_unit FND_CURRENCIES.minimum_accountable_unit%TYPE;

BEGIN
    FND_CURRENCY.get_info ( p_currency,
                            l_precision,
                            l_ext_precision,
                            l_min_acct_unit );

    RETURN l_precision;
END get_currency_precision;

-- bug3294883 END

-- <HTMLAC START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_cross_ou_rate
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the conversion rate between the functional currencies of
--  2 operating units, using the To OU's default rate type and the current
--  date as the rate date.
--Parameters:
--IN:
--  p_from_ou_id
--     Operating unit to convert from
--  p_to_ou_id
--     Operating unit to convert to
--Returns:
--  Conversion rate; NULL if no conversion exists between the currencies
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_cross_ou_rate ( p_from_ou_id IN NUMBER, p_to_ou_id IN NUMBER )
RETURN NUMBER IS
  l_api_name CONSTANT varchar2(30) := 'GET_CROSS_OU_RATE';

  l_from_ou_currency GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_to_ou_currency   GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_rate_type        PO_SYSTEM_PARAMETERS_ALL.default_rate_type%TYPE;
  l_rate             NUMBER;
  l_display_rate     NUMBER;
  l_return_status    VARCHAR2(1);
  l_message_name     VARCHAR2(100);
  l_progress         VARCHAR2(3);
BEGIN
  l_progress := '000';

  -- If the operating units are the same, the rate is just 1.0.
  IF (NVL(p_from_ou_id,-1) = NVL(p_to_ou_id,-1)) THEN
    RETURN 1.0;
  END IF;

  -- Get the From OU's functional currency.
  get_functional_currency_code (
    p_org_id => p_from_ou_id,
    x_functional_currency_code => l_from_ou_currency
  );

  -- Get the To OU's functional currency.
  get_functional_currency_code (
    p_org_id => p_to_ou_id,
    x_functional_currency_code => l_to_ou_currency
  );

  -- If the currencies are the same, the rate is just 1.0.
  IF (l_from_ou_currency = l_to_ou_currency) THEN
    RETURN 1.0;
  END IF;

  l_progress := '010';

  -- Get the default rate type from the To OU.
  select default_rate_type
  into  l_rate_type
  from  po_system_parameters_all psp
  where nvl(psp.org_id, -99) = nvl(p_to_ou_id, -99);

  l_progress := '020';

  -- Get the conversion rate.
  get_rate (
    p_from_currency => l_from_ou_currency,
    p_to_currency => l_to_ou_currency,
    p_rate_type => l_rate_type,
    p_rate_date => SYSDATE,
    p_inverse_rate_display_flag => 'N',
    x_rate => l_rate,
    x_display_rate => l_display_rate,
    x_return_status => l_return_status,
    x_error_message_name => l_message_name
  );

  l_progress := '030';

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt (
        p_log_head => g_pkg_name||'.'||l_api_name,
        p_token => l_progress,
        p_message => 'Currency conversion error: '
          ||l_from_ou_currency||','||l_to_ou_currency||': '||
          FND_MESSAGE.get_string('PO', l_message_name) );
    END IF;
    RETURN null;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp (
        p_log_head => g_pkg_name||'.'||l_api_name,
        p_progress => l_progress );
    END IF;
    RETURN null;
  END IF;

  RETURN l_rate;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error (
      p_pkg_name => g_pkg_name,
      p_proc_name => l_api_name,
      p_progress => l_progress );

    RAISE;
END get_cross_ou_rate;
-- <HTMLAC END>
--Bug 9929991 When Function curruncey is differnt then PO curruncey we need to convert From Function to PO curruncey

FUNCTION get_converted_unit_price
(
  p_list_unit_price IN NUMBER ,
  p_rate IN NUMBER ,
  p_currency_code VARCHAR2



) RETURN NUMBER IS

x_precision     NUMBER  := null;
x_ext_precision NUMBER  := null;
x_currency_code VARCHAR2(15) := NULL;
x_min_acct_unit         NUMBER  := null;
x_currency_unit_price NUMBER := null;
BEGIN




fnd_currency.get_info (p_currency_code,
 	                     x_precision,
 	                     x_ext_precision,
 	                     x_min_acct_unit);

x_currency_unit_price := round(p_list_unit_price / nvl(p_rate,1), x_ext_precision);

RETURN  x_currency_unit_price;

END  get_converted_unit_price;

--Bug 9929991 When Function curruncey is differnt then PO curruncey we need to convert From Function to PO curruncey

END po_currency_sv;

/
