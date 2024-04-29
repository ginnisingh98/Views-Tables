--------------------------------------------------------
--  DDL for Package Body IBY_AMOUNT_IN_WORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_AMOUNT_IN_WORDS" AS
/* $Header: ibyamtwb.pls 120.4.12010000.15 2009/10/27 09:05:30 bkjain ship $ */

  -- code from JEES_NTW pacakge 120.3
  FUNCTION JEES_NTW_CONV_NUM_FRAGMENT (P_NUM INTEGER,       /* integer version of number */
                            P_FEM BOOLEAN)       /* masculine or feminine */
                            RETURN VARCHAR2;   /* word version of integer */

  -- code from JEES_NTW pacakge 120.3
  FUNCTION JEES_NTW_NUM_TO_WORDS (P_ENTERED NUMBER,
                     P_PRECISION INTEGER)
                     RETURN VARCHAR2;

  -- code from APXPBFOR.rdf 115.7
  APXPBFOR_P_UNIT_SINGULAR CONSTANT VARCHAR2(100) := 'Dollar';
  APXPBFOR_P_UNIT_PLURAL CONSTANT VARCHAR2(100) := 'Dollars';
  APXPBFOR_P_SUB_UNIT_SINGULAR CONSTANT VARCHAR2(100) := 'Cent';
  APXPBFOR_P_SUB_UNIT_PLURAL CONSTANT VARCHAR2(100) := 'Cents';
  APXPBFOR_P_UNIT_RATIO CONSTANT NUMBER := 100;

  c_zero              ap_lookup_codes.displayed_field%TYPE;
  c_thousand          ap_lookup_codes.displayed_field%TYPE;
  c_million           ap_lookup_codes.displayed_field%TYPE;
  c_millions           ap_lookup_codes.displayed_field%TYPE;
  c_billion           ap_lookup_codes.displayed_field%TYPE;
  c_and          ap_lookup_codes.displayed_field%TYPE;
  g_user_lang         fnd_languages.nls_language%TYPE := 'junk';

  TYPE num_lookupTab IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  g_numlookup num_lookupTab;

  -- look up a word text for a number under 1000
  FUNCTION Lookup_num (p_num NUMBER) RETURN VARCHAR2;

  -- code from APXPBFOR.rdf 115.7
  function APXPBFOR_C_WORD_AMOUNTFormula(p_amount IN NUMBER,
                                         p_currency_code IN VARCHAR2,
                                         p_precision IN NUMBER)
    return VARCHAR2;

  -- code from APXPBFOR.rdf 115.7
  function APXPBFOR_get_word_value (
          p_amount              number,
          p_unit_singular       varchar2,
          p_unit_plural         varchar2,
          p_sub_unit_singular   varchar2,
          p_sub_unit_plural     varchar2,
          p_unit_ratio          number
  ) return varchar2;


  -- code from AP_AMOUNT_UTILITIES_PKG 120.3
  function apamtutb_ap_convert_number (in_numeral IN NUMBER) return varchar2;

  -- code from JLBRPCFP.rdf 115.14 2006/08/22 08:54
  FUNCTION AMOUNT_WORDS_SPANISH (Chk_Amt number) RETURN VARCHAR2;

 -- code from JLBRPCFP.rdf 115.14 2006/08/22 08:54
  FUNCTION AMOUNT_WORDS_MEXICAN (P_ENTERED NUMBER,
                       P_PRECISION INTEGER)
                       RETURN VARCHAR2;

  -- main API
  FUNCTION Get_Amount_In_Words(p_amount IN NUMBER,
                               p_currency_code IN VARCHAR2 := NULL,
                               p_precision IN NUMBER := NULL,
                               p_country_code IN VARCHAR2 := NULL)
  RETURN VARCHAR2
  IS
    l_api_name                CONSTANT  VARCHAR2(30) := 'Get_Amount_In_Words';
    l_Debug_Module                      VARCHAR2(255):= G_DEBUG_MODULE || '.' || l_api_name;

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                   debug_level => FND_LOG.LEVEL_PROCEDURE,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_amount: ' || p_amount,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_currency_code: ' || p_currency_code,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_precision: ' || p_precision,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'p_country_code: ' || p_country_code,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    IF p_currency_code ='MXN' THEN
      RETURN AMOUNT_WORDS_MEXICAN (p_amount, nvl(p_precision, 0));
    ELSIF p_country_code = 'ES' THEN
      RETURN JEES_NTW_NUM_TO_WORDS(p_amount, nvl(p_precision, 0));
    -- bug 5511781: 'ARS', 'BRL', 'CLP', 'COP'
    ELSIF p_currency_code IN ('BRL') THEN
      RETURN AMOUNT_WORDS_PORTUGESE(p_amount);
    ELSIF p_currency_code IN ('ARS', 'CLP', 'COP') THEN
      RETURN AMOUNT_WORDS_SPANISH (p_amount);
    ELSE
      RETURN APXPBFOR_C_WORD_AMOUNTFormula(p_amount, p_currency_code, p_precision);
    END IF;

  END Get_Amount_In_Words;


  -- code from APXPBFOR.rdf 115.7
  function APXPBFOR_C_WORD_AMOUNTFormula(p_amount IN NUMBER,
                                         p_currency_code IN VARCHAR2,
                                         p_precision IN NUMBER)
    return VARCHAR2
    is

    l_word_text varchar2(240);
    l_width number := 58;  -- Width of word amount field
    l_unit_singular_msg_name  varchar2(30) := 'IBY_AMT_IN_WORD_US_';
    l_unit_plural_msg_name  varchar2(30) := 'IBY_AMT_IN_WORD_UP_';
    l_unit_sub_singular_msg_name  varchar2(30) := 'IBY_AMT_IN_WORD_SUS_';
    l_unit_sub_plural_msg_name  varchar2(30) := 'IBY_AMT_IN_WORD_SUP_';
    l_unit_singular_str  varchar2(80);
    l_unit_plural_str  varchar2(80);
    l_unit_sub_singular_str  varchar2(80);
    l_unit_sub_plural_str  varchar2(80);
    l_precision NUMBER;
    l_unit_ratio NUMBER;

    l_api_name                CONSTANT  VARCHAR2(30) := 'Get_Amount_In_Words';
    l_Debug_Module                      VARCHAR2(255):= G_DEBUG_MODULE || l_api_name;

    CURSOR l_precision_csr (p_currency_code IN VARCHAR2) IS
    SELECT precision
      FROM fnd_currencies
     WHERE currency_code = p_currency_code;

  begin

    -- 'USD', 'EUR', 'JPY', 'CNY', 'CHF', 'DKK', 'FIM', 'NOK', 'SEK'
    l_unit_singular_msg_name  := l_unit_singular_msg_name || p_currency_code;
    l_unit_plural_msg_name  := l_unit_plural_msg_name || p_currency_code;
    l_unit_sub_singular_msg_name  := l_unit_sub_singular_msg_name || p_currency_code;
    l_unit_sub_plural_msg_name  := l_unit_sub_plural_msg_name || p_currency_code;

    iby_debug_pub.add(debug_msg => 'formulated message names: ',
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_unit_singular_msg_name: ' || l_unit_singular_msg_name,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_unit_plural_msg_name: ' || l_unit_plural_msg_name,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_unit_sub_singular_msg_name: ' || l_unit_sub_singular_msg_name,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'l_unit_sub_plural_msg_name: ' || l_unit_sub_plural_msg_name,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    BEGIN
    fnd_message.set_name('IBY', l_unit_singular_msg_name);
    l_unit_singular_str := fnd_message.get;

    IF l_unit_singular_str = l_unit_singular_msg_name THEN
      l_unit_singular_str := NULL;
    END IF;

    iby_debug_pub.add(debug_msg => 'Got translated text for ' || l_unit_singular_msg_name
                      || ': ' || l_unit_singular_str,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;


    BEGIN
    fnd_message.set_name('IBY', l_unit_plural_msg_name);
    l_unit_plural_str := fnd_message.get;

    IF l_unit_plural_str = l_unit_plural_msg_name THEN
      l_unit_plural_str := NULL;
    END IF;

    iby_debug_pub.add(debug_msg => 'Got translated text for ' || l_unit_plural_msg_name
                      || ': ' || l_unit_plural_str,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;

    BEGIN
    fnd_message.set_name('IBY', l_unit_sub_singular_msg_name);
    l_unit_sub_singular_str := fnd_message.get;

    IF l_unit_sub_singular_str = l_unit_sub_singular_msg_name THEN
      l_unit_sub_singular_str := NULL;
    END IF;

    iby_debug_pub.add(debug_msg => 'Got translated text for ' || l_unit_sub_singular_msg_name
                      || ': ' || l_unit_sub_singular_str,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;

    BEGIN
    fnd_message.set_name('IBY', l_unit_sub_plural_msg_name);
    l_unit_sub_plural_str := fnd_message.get;

    IF l_unit_sub_plural_str = l_unit_sub_plural_msg_name THEN
      l_unit_sub_plural_str := NULL;
    END IF;

    iby_debug_pub.add(debug_msg => 'Got translated text for ' || l_unit_sub_plural_msg_name
                      || ': ' || l_unit_sub_plural_str,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;

    BEGIN
      IF p_precision IS NULL THEN

        IF p_currency_code IS NULL THEN
          iby_debug_pub.add(debug_msg => 'Warning: p_precision and p_currency_code are both null! ',
                         debug_level => FND_LOG.LEVEL_STATEMENT,
                         module => l_Debug_Module);
        ELSE

         OPEN l_precision_csr (p_currency_code);
        FETCH l_precision_csr INTO l_precision;
        CLOSE l_precision_csr;

        END IF;

      ELSE
        l_precision := p_precision;
      END IF;

      iby_debug_pub.add(debug_msg => 'l_precision: ' || l_precision,
                     debug_level => FND_LOG.LEVEL_STATEMENT,
                     module => l_Debug_Module);

      IF l_precision = 1 THEN
        l_unit_ratio := 10;
      ELSIF l_precision = 2 THEN
        l_unit_ratio := 100;
      ELSIF l_precision = 3 THEN
        l_unit_ratio := 1000;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;

      l_word_text :=
         APXPBFOR_get_word_value (
           p_amount              => p_amount,
           p_unit_singular       => l_unit_singular_str,
           p_unit_plural         => l_unit_plural_str,
           p_sub_unit_singular   => l_unit_sub_singular_str,
           p_sub_unit_plural     => l_unit_sub_plural_str,
           p_unit_ratio          => l_unit_ratio);
      -- Format the output to have asterisks on right-hand side
      if NVL(length(l_word_text), 0) <= l_width then
        l_word_text := rpad(l_word_text,l_width,'*');
      elsif NVL(length(l_word_text), 0) <= l_width*2 then
        -- Allow for word wrapping
	-- Removed the logic for word wrapping for Bug 7433132
       -- l_word_text := rpad(l_word_text,l_width*2 -
  	--  (l_width-instr(substr(l_word_text,1,l_width+1),' ',-1)),'*');
	l_word_text := rpad(l_word_text,l_width*2,'*');
      elsif NVL(length(l_word_text), 0) <= l_width*3 then
        l_word_text := rpad(l_word_text,l_width*3,'*');
      end if;

      iby_debug_pub.add(debug_msg => 'Amount text: ' || l_word_text,
                     debug_level => FND_LOG.LEVEL_STATEMENT,
                     module => l_Debug_Module);

    return(l_word_text);

  EXCEPTION
    WHEN OTHERS THEN
      iby_debug_pub.add(debug_msg => 'Error in getting amount text. Returning null.',
                     debug_level => FND_LOG.LEVEL_STATEMENT,
                     module => l_Debug_Module);
    RETURN NULL;

  END APXPBFOR_C_WORD_AMOUNTFormula;


  -- code from APXPBFOR.rdf 115.7
  function APXPBFOR_get_word_value (
          p_amount              number,
          p_unit_singular       varchar2,
          p_unit_plural         varchar2,
          p_sub_unit_singular   varchar2,
          p_sub_unit_plural     varchar2,
          p_unit_ratio          number
                          ) return varchar2 is
    l_word_amount varchar2(240) := apamtutb_ap_convert_number(trunc(p_amount));

    --  Removed the convert_amount and added the package call ap_amount_utilities_pkg
    --  which handles this word conversion from number.
    --  For bug 2569922

    l_currency_word varchar2(240);
    l_part_amount_word varchar2(240);
    l_log integer;
    session_language    fnd_languages.nls_language%TYPE;

    /* This is a workaround until bug #165793 is fixed */
    function my_log (a integer, b integer) return number is
      begin
        if a <> 10 then return(null);
        elsif b > 0 and b <= 10 then return(1);
        elsif b > 10 and b <= 100 then return(2);
        elsif b > 100 and b <= 1000 then return(3);
        else return(null);
        end if;
      RETURN NULL; end;

  begin
    l_log := my_log(10,p_unit_ratio);

       select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
       into   session_language
       from   dual;

    if p_unit_ratio in (0,1) or p_unit_ratio is null or (p_amount-trunc(p_amount) = 0 and session_language = 'ARABIC') then
       select  initcap(lower(
                    l_word_amount||' '||
                    decode(trunc(p_amount),
                          1,p_unit_singular,
                            p_unit_plural)
                  ))
       into    l_currency_word
       from    dual;
    else

    --  Added the package call ap_amount_utilities_pkg
    --  which handles the word conversion for decimal digits
    --  For bug 2569922
    l_part_amount_word := apamtutb_ap_convert_number(lpad(to_char(trunc((p_amount-trunc(p_amount))*p_unit_ratio)),
                          ceil(l_log),'0'));
       select  initcap(lower(
                    l_word_amount||' '||
                    decode(trunc(p_amount),
                          1,p_unit_singular,
                            p_unit_plural)||' '||displayed_field||' '||l_part_amount_word
                    ||' '||
                    decode(trunc((p_amount-trunc(p_amount))*p_unit_ratio),
                          1,p_sub_unit_singular,
                            p_sub_unit_plural)
                  ))
       into    l_currency_word
       from    ap_lookup_codes
       where   lookup_code = 'AND'
       and     lookup_type = 'NLS TRANSLATION';
    end if;

    return(l_currency_word);
  END APXPBFOR_get_word_value;


  FUNCTION Lookup_num (p_num NUMBER) RETURN VARCHAR2 IS
  BEGIN

    RETURN g_numlookup(p_num);

  exception
    when no_data_found then

      select description
      into   g_numlookup(p_num)
      from   ap_lookup_codes
      where  lookup_code = to_char(p_num)
      and    lookup_type = 'NUMBERS';

      iby_debug_pub.add(debug_msg => 'Adding to lookup cache ' || p_num || ': ' || g_numlookup(p_num),
                     debug_level => FND_LOG.LEVEL_STATEMENT,
                     module => G_DEBUG_MODULE || '.Lookup_num');

      RETURN g_numlookup(p_num);
  END;

  -- code from AP_AMOUNT_UTILITIES_PKG 120.3
  function apamtutb_ap_convert_number (in_numeral IN NUMBER) return varchar2  is
    number_too_large    exception;
    numeral             integer := abs(in_numeral);
    max_digit           integer := 12;  -- for numbers less than a trillion
    number_text         varchar2(240) := '';
    billion_segN        number;
    million_segN        number;
    thousand_segN       number;
    units_segN          number;
    thousand_lookup     varchar2(80);
    units_lookup        varchar2(80);
    session_language    fnd_languages.nls_language%TYPE;
    thousand            number      := power(10,3);
    million             number      := power(10,6);
    billion             number      := power(10,9);
    l_Debug_Module      VARCHAR2(255):= G_DEBUG_MODULE || '.apamtutb_ap_convert_number';

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                   debug_level => FND_LOG.LEVEL_PROCEDURE,
                   module => l_Debug_Module);

    if numeral >= power(10,max_digit) then
       raise number_too_large;
    end if;

    select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
    into   session_language
    from   dual;

    iby_debug_pub.add(debug_msg => 'numeral: ' || numeral,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'session_language: ' || session_language,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    IF g_user_lang <> session_language THEN

      iby_debug_pub.add(debug_msg => 'g_user_lang <> session_language, caching lookups ',
                     debug_level => FND_LOG.LEVEL_STATEMENT,
                     module => l_Debug_Module);

      g_user_lang := session_language;

      select ' '||lc1.displayed_field||' ',
             ' '||lc2.displayed_field||' ',
	     ' '||lc6.displayed_field||' ',
             ' '||lc3.displayed_field||' ',
             ' '||lc4.displayed_field,
             lc5.displayed_field
      into   c_billion,
             c_million,
	     c_millions,
             c_thousand,
             c_zero,
	     c_and
      from   ap_lookup_codes lc1,
             ap_lookup_codes lc2,
             ap_lookup_codes lc3,
             ap_lookup_codes lc4,
	     ap_lookup_codes lc5,
             ap_lookup_codes lc6
      where  lc1.lookup_code = 'BILLION'
      and    lc1.lookup_type = 'NLS TRANSLATION'
      and    lc2.lookup_code = 'MILLION'
      and    lc2.lookup_type = 'NLS TRANSLATION'
      and    lc3.lookup_code = 'THOUSAND'
      and    lc3.lookup_type = 'NLS TRANSLATION'
      and    lc4.lookup_code = 'ZERO'
      and    lc4.lookup_type = 'NLS TRANSLATION'
      and    lc5.lookup_code = 'AND'
      and    lc5.lookup_type = 'NLS TRANSLATION'
      and    lc6.lookup_code = 'MILLIONS'
      and    lc6.lookup_type = 'NLS TRANSLATION';

      g_numlookup.DELETE;

    END IF;

    --For Bug459665
    if numeral = 0 then
      RETURN c_zero;
    end if;


    billion_segN := trunc(numeral/billion);

    numeral := numeral - (billion_segN * billion);
    million_segN := trunc(numeral/million);

    numeral := numeral - (million_segN * million);
    thousand_segN := trunc(numeral/thousand);

    units_segN := mod(numeral,thousand);

    iby_debug_pub.add(debug_msg => 'billion_segN: ' || billion_segN,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'million_segN: ' || million_segN,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'thousand_segN: ' || thousand_segN,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'units_segN: ' || units_segN,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    if billion_segN <> 0 then
      number_text := number_text||Lookup_num(billion_segN) ||c_billion;
    end if;

    if million_segN <> 0 then
       if (session_language = 'ARABIC' and Length(number_text) > 0) THEN
       number_text := number_text||c_and||' '||Lookup_num(million_segN)||c_million;
       else
	       if(million_segN > 1 AND session_language = 'SPANISH') THEN
	       number_text := number_text||Lookup_num(million_segN)||c_millions;
	       else
	       number_text := number_text||Lookup_num(million_segN)||c_million;
	       end if;
       end if;
    end if;

    if thousand_segN <> 0 then
      --Bug 335063 fix.
     --Portugese, SPANISH added for bug 8319904
      if (session_language = 'FRENCH' or session_language = 'CANADIAN FRENCH' or session_language = 'PORTUGUESE'
      or session_language = 'SPANISH' or session_language = 'ARABIC')
         and thousand_segN = 1 then
         thousand_lookup := null;
      ELSE
        thousand_lookup := Lookup_num(thousand_segN);
      end if;

	       if (session_language = 'ARABIC' and Length(number_text) > 0) THEN
	       number_text := number_text||c_and||' '||thousand_lookup||c_thousand;
	       else
	       number_text := number_text||thousand_lookup||c_thousand;
	       end if;

    end if;

    if units_segN <> 0 then
       if (session_language = 'ARABIC' and Length(number_text) > 0) THEN
       number_text := number_text||c_and||' '||Lookup_num(units_segN);
       ELSE
       number_text := number_text||Lookup_num(units_segN);
       END IF;
    end if;

    number_text := ltrim(number_text);
    number_text := upper(substr(number_text,1,1)) ||
                   rtrim(lower(substr(number_text,2,length(number_text))));

    iby_debug_pub.add(debug_msg => 'returning number_text: ' || number_text,
                   debug_level => FND_LOG.LEVEL_STATEMENT,
                   module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
                   debug_level => FND_LOG.LEVEL_PROCEDURE,
                   module => l_Debug_Module);

    return(number_text);

  exception
    when number_too_large then
          return(null);
    when others then
          return(null);
  END apamtutb_ap_convert_number;


  -- code from JEES_NTW pacakge 120.3
  FUNCTION JEES_NTW_CONV_NUM_FRAGMENT (P_NUM INTEGER,       /* integer version of number */
                              P_FEM BOOLEAN)       /* masculine or feminine */
                              RETURN VARCHAR2 IS   /* word version of integer */

    LOC_LONGI   NUMBER(2);
    LOC_DIV1    NUMBER(2);
    LOC_DIV2    NUMBER(12);
    LOC_MOD     NUMBER(2);
    LOC_CAMPO   VARCHAR2(13);
    LOC_RESTO   NUMBER(3);
    LOC_SW1     VARCHAR2(1);
    LOC_SW2     VARCHAR2(1);
    LOC_PASO    NUMBER(12);
    LOC_NUMERO1 NUMBER(12);
    LOC_UNO     NUMBER(1);
    LOC_DOS     NUMBER(1);
    LOC_TRES    NUMBER(1);
    LOC_LETRAS  VARCHAR2(240);
    LOC_NUMERO  NUMBER(12);
    LOC_FEMININE BOOLEAN;
  BEGIN
    LOC_CAMPO := '1000000000000';
    LOC_NUMERO := P_NUM;
    LOC_FEMININE := P_FEM;
    LOC_SW1 := 'N';
    LOC_SW2 := 'N';
    LOC_LETRAS := NULL;
    IF LOC_NUMERO = 0 THEN
       LOC_LETRAS := 'CERO';
    ELSE
       WHILE LOC_NUMERO > 0 LOOP
          IF LOC_SW1 = 'S' AND LOC_SW2 = 'N' AND LOC_PASO = 1
             AND LOC_NUMERO < 999999 THEN
             LOC_LETRAS := LOC_LETRAS||' MILLONES';
             LOC_PASO := NULL;
             LOC_SW1 := 'N';
          END IF;
          LOC_LONGI := TO_NUMBER(LENGTH(TO_CHAR(LOC_NUMERO)));
          LOC_MOD := MOD(LOC_LONGI,3);
          LOC_DIV1 := LOC_LONGI - LOC_MOD;
          IF LOC_MOD = 0 THEN
             LOC_DIV1 := LOC_DIV1 - 3;
          END IF;
          LOC_DIV2 := TO_NUMBER(SUBSTR(LOC_CAMPO,1,LOC_DIV1+1));
          LOC_NUMERO1 := TRUNC(LOC_NUMERO/LOC_DIV2);

          IF LOC_NUMERO >= 100 THEN
             LOC_UNO := TRUNC(LOC_NUMERO1/100);
             IF LOC_UNO = 1 THEN
                IF LOC_NUMERO1 = 100 THEN
                   LOC_LETRAS := LOC_LETRAS||' CIEN';
                ELSE
                   LOC_LETRAS := LOC_LETRAS||' CIENTO';
                END IF;
             ELSIF LOC_UNO = 2 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' DOSCIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' DOSCIENTAS';
                   END IF;
             ELSIF LOC_UNO = 3 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' TRESCIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' TRESCIENTAS';
                   END IF;
             ELSIF LOC_UNO = 4 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' CUATROCIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' CUATROCIENTAS';
                   END IF;
             ELSIF LOC_UNO = 5 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' QUINIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' QUINIENTAS';
                   END IF;
             ELSIF LOC_UNO = 6 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' SEISCIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' SEISCIENTAS';
                   END IF;
             ELSIF LOC_UNO = 7 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' SETECIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' SETECIENTAS';
                   END IF;
             ELSIF LOC_UNO = 8 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' OCHOCIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' OCHOCIENTAS';
                   END IF;
             ELSIF LOC_UNO = 9 THEN
                   IF LOC_NUMERO > 999999
  /* NMR - bug 839444 */
                   OR NOT LOC_FEMININE THEN
                      LOC_LETRAS := LOC_LETRAS||' NOVECIENTOS';
                   ELSE
                      LOC_LETRAS := LOC_LETRAS||' NOVECIENTAS';
                   END IF;
             END IF;
          ELSE
             LOC_UNO := 0;
          END IF;
          LOC_DOS := TRUNC((LOC_NUMERO1-(LOC_UNO*100))/10);

          IF LOC_DOS < 3
          AND (LOC_DOS > 0
               OR LOC_NUMERO > 999999)
          /*
          Added by NMR because it wasn't recognising the final number under
          certain circumtances
          */
          OR LOC_DOS = 0
          THEN

             LOC_RESTO := LOC_NUMERO1-(LOC_UNO*100);

             IF LOC_RESTO = 1 THEN

                IF LOC_FEMININE AND LOC_NUMERO < 1000000
                THEN
  /* NMR - bug 1135045 capture 1000000000 */
                IF LOC_LONGI NOT IN (4,10) THEN
                      LOC_LETRAS := LOC_LETRAS||' UNA';
                   END IF;
                ELSIF LOC_LONGI IN (1,2,3)
                THEN
                   LOC_LETRAS := LOC_LETRAS||' UNO';
                ELSE
  /* NMR - bug 1135045 capture 1000000000 */
                IF LOC_LONGI NOT IN (4,10) THEN
                      LOC_LETRAS := LOC_LETRAS||' UN';
                   END IF;
                END IF;

             ELSIF LOC_RESTO = 2 THEN
                LOC_LETRAS := LOC_LETRAS||' DOS';
             ELSIF LOC_RESTO = 3 THEN
                LOC_LETRAS := LOC_LETRAS||' TRES';
             ELSIF LOC_RESTO = 4 THEN
                LOC_LETRAS := LOC_LETRAS||' CUATRO';
             ELSIF LOC_RESTO = 5 THEN
                LOC_LETRAS := LOC_LETRAS||' CINCO';
             ELSIF LOC_RESTO = 6 THEN
                LOC_LETRAS := LOC_LETRAS||' SEIS';
             ELSIF LOC_RESTO = 7 THEN
                LOC_LETRAS := LOC_LETRAS||' SIETE';
             ELSIF LOC_RESTO = 8 THEN
                LOC_LETRAS := LOC_LETRAS||' OCHO';
             ELSIF LOC_RESTO = 9 THEN
                LOC_LETRAS := LOC_LETRAS||' NUEVE';
             ELSIF LOC_RESTO = 10 THEN
                LOC_LETRAS := LOC_LETRAS||' DIEZ';
             ELSIF LOC_RESTO = 11 THEN
                LOC_LETRAS := LOC_LETRAS||' ONCE';
             ELSIF LOC_RESTO = 12 THEN
                LOC_LETRAS := LOC_LETRAS||' DOCE';
             ELSIF LOC_RESTO = 13 THEN
                LOC_LETRAS := LOC_LETRAS||' TRECE';
             ELSIF LOC_RESTO = 14 THEN
                LOC_LETRAS := LOC_LETRAS||' CATORCE';
             ELSIF LOC_RESTO = 15 THEN
                LOC_LETRAS := LOC_LETRAS||' QUINCE';
             ELSIF LOC_RESTO = 16 THEN
                LOC_LETRAS := LOC_LETRAS||' DIECISEIS';
             ELSIF LOC_RESTO = 17 THEN
                LOC_LETRAS := LOC_LETRAS||' DIECISIETE';
             ELSIF LOC_RESTO = 18 THEN
                LOC_LETRAS := LOC_LETRAS||' DIECIOCHO';
             ELSIF LOC_RESTO = 19 THEN
                LOC_LETRAS := LOC_LETRAS||' DIECINUEVE';
             ELSIF LOC_RESTO = 20 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTE';
             ELSIF LOC_RESTO = 21 THEN
                IF LOC_FEMININE AND LOC_NUMERO < 1000000
                THEN
                  LOC_LETRAS := LOC_LETRAS||' VEINTIUNA';
                ELSIF LOC_LONGI IN (1,2,3)
                THEN
                   LOC_LETRAS := LOC_LETRAS||' VEINTIUNO';
                ELSE
                   LOC_LETRAS := LOC_LETRAS||' VEINTIUN';
                END IF;
             ELSIF LOC_RESTO = 22 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTIDOS';
             ELSIF LOC_RESTO = 23 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTITRES';
             ELSIF LOC_RESTO = 24 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTICUATRO';
             ELSIF LOC_RESTO = 25 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTICINCO';
             ELSIF LOC_RESTO = 26 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTISEIS';
             ELSIF LOC_RESTO = 27 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTISIETE';
             ELSIF LOC_RESTO = 28 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTIOCHO';
             ELSIF LOC_RESTO = 29 THEN
                LOC_LETRAS := LOC_LETRAS||' VEINTINUEVE';
             END IF;

          ELSIF LOC_DOS >= 3 THEN
             IF LOC_DOS = 3 THEN
                LOC_LETRAS := LOC_LETRAS||' TREINTA';
             ELSIF LOC_DOS = 4 THEN
                   LOC_LETRAS := LOC_LETRAS||' CUARENTA';
             ELSIF LOC_DOS = 5 THEN
                   LOC_LETRAS := LOC_LETRAS||' CINCUENTA';
             ELSIF LOC_DOS = 6 THEN
                   LOC_LETRAS := LOC_LETRAS||' SESENTA';
             ELSIF LOC_DOS = 7 THEN
                   LOC_LETRAS := LOC_LETRAS||' SETENTA';
             ELSIF LOC_DOS = 8 THEN
                   LOC_LETRAS := LOC_LETRAS||' OCHENTA';
             ELSIF LOC_DOS = 9 THEN
                   LOC_LETRAS := LOC_LETRAS||' NOVENTA';
             END IF;
             LOC_TRES := LOC_NUMERO1-(LOC_UNO*100) - (LOC_DOS*10);

             IF LOC_TRES = 1 THEN
                IF LOC_FEMININE AND LOC_NUMERO < 1000000
                THEN
                  LOC_LETRAS := LOC_LETRAS||' Y UNA';
                ELSIF LOC_LONGI IN (1,2,3)
                THEN
                   LOC_LETRAS := LOC_LETRAS||' Y UNO';
                ELSE
                   LOC_LETRAS := LOC_LETRAS||' Y UN';
                END IF;

             ELSIF LOC_TRES = 2 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y DOS';
             ELSIF LOC_TRES = 3 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y TRES';
             ELSIF LOC_TRES = 4 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y CUATRO';
             ELSIF LOC_TRES = 5 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y CINCO';
             ELSIF LOC_TRES = 6 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y SEIS';
             ELSIF LOC_TRES = 7 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y SIETE';
             ELSIF LOC_TRES = 8 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y OCHO';
             ELSIF LOC_TRES = 9 THEN
                   LOC_LETRAS := LOC_LETRAS||' Y NUEVE';
             END IF;
          END IF;
          IF LOC_LONGI BETWEEN 4 AND 6 AND LOC_NUMERO1 > 0 THEN
             LOC_LETRAS := LOC_LETRAS||' MIL';
          ELSIF LOC_LONGI BETWEEN 7 AND 9 AND LOC_NUMERO1 > 0 THEN
                IF LOC_NUMERO1 = 1 THEN
                   LOC_LETRAS := LOC_LETRAS||' MILLON';
                ELSE
                   LOC_LETRAS := LOC_LETRAS||' MILLONES';
                END IF;
                LOC_SW2 := 'S';
          ELSIF LOC_LONGI BETWEEN 10 AND 12 AND LOC_NUMERO1 > 0 THEN
                LOC_PASO := 1;
                LOC_SW1 := 'S';
                LOC_LETRAS := LOC_LETRAS||' MIL';
          END IF;
          LOC_NUMERO := LOC_NUMERO - (LOC_NUMERO1 * LOC_DIV2);
       END LOOP;
       IF LOC_SW1 = 'S' AND LOC_SW2 = 'N' THEN
          LOC_LETRAS := LOC_LETRAS||' MILLONES';
       END IF;
    END IF;
    RETURN LOC_LETRAS;

  END JEES_NTW_CONV_NUM_FRAGMENT;


  -- code from JEES_NTW pacakge 120.3
  /*
  Public function which splits the number into two parts (the decimals and the
  number without decimals) and calls the con_num_fragment for the two parts
  */
  FUNCTION JEES_NTW_NUM_TO_WORDS (P_ENTERED NUMBER,
                       P_PRECISION INTEGER)
                       RETURN VARCHAR2 IS
    LOC_NUM       NUMBER(12);
    LOC_FEM       BOOLEAN;
    LOC_WORD1     VARCHAR2(240);
    LOC_WORD2     VARCHAR2(240);
    LOC_ENTERED   NUMBER(14,2);
    LOC_PRECISION NUMBER(2);

  BEGIN
    LOC_ENTERED := P_ENTERED;
    LOC_PRECISION := P_PRECISION;

    IF TRUNC(LOC_ENTERED) <> LOC_ENTERED
    THEN

       /* It has decimals - extract them */
       LOC_NUM := 100 * (LOC_ENTERED - TRUNC(LOC_ENTERED));

       /* centimos are always masculine */
       LOC_FEM := FALSE;

       LOC_WORD1 := JEES_NTW_CONV_NUM_FRAGMENT(LOC_NUM, LOC_FEM);
  /* NMR - bug 1135045 add cero if between 1 and 9 */
       IF  LOC_NUM < 10 THEN
  /* bug 1735767 */
           LOC_WORD1 := ' CON CERO'||LOC_WORD1;
       ELSE
  /* bug 1735767 */
           LOC_WORD1 := ' CON'||LOC_WORD1;
       END IF;
    END IF;

    /* Convert the main part of the number */
    LOC_NUM := TRUNC(LOC_ENTERED);

    /*
    Guess whether the currency is masculine or feminine (this information isn't
    stored in Financials). Given that the Peseta is feminine and the Euro is
    masculine I am going to assume that if the currency's precision is 0 that it
    is feminine, if more (ie 2) that it is masculine
    */

    IF LOC_PRECISION = 0
    THEN
       LOC_FEM := TRUE;
    ELSE
       LOC_FEM := FALSE;
    END IF;

    LOC_WORD2 := JEES_NTW_CONV_NUM_FRAGMENT (LOC_NUM, LOC_FEM);

    LOC_WORD1 := LOC_WORD2||LOC_WORD1;

    RETURN LOC_WORD1;

  END JEES_NTW_NUM_TO_WORDS;


  -- code from JLBRPCFP.rdf 115.14 2006/08/22 08:54
  FUNCTION AMOUNT_WORDS_SPANISH (Chk_Amt number) RETURN varchar2 IS

     l_amt_spanish1 	varchar2(200) := '';
     l_amt_spanish2	varchar2(200) := '';
     check_amount		number;

  BEGIN

     SELECT
        decode(.00000000001*(mod(abs(Chk_Amt),1000000000000)-mod(abs(Chk_Amt),100000000000)),
                1,decode(mod(trunc(Chk_Amt/1000000000),1000)-100, 0,'Cien ','Ciento '),
       		2,'Doscientos ',
       		3,'Trescientos ',
       		4,'Cuatrocientos ',
       		5,'Quinientos ',
       		6,'Seiscientos ',
       		7,'Setecientos ',
       		8,'Ochocientos ',
       		9,'Novecientos ',
       		0,null,
  		'ERROR ') ||
        decode(.0000000001*(mod(abs(Chk_Amt),100000000000)-mod(abs(Chk_Amt),10000000000)),
  		1,(decode(.000000001*(mod(abs(Chk_Amt),10000000000)-mod(abs(Chk_Amt),1000000000)),
  			0,'Diez ',
  			1,'Once ',
  			2,'Doce ',
  			3,'Trece ',
   			4,'Catorce ',
  			5,'Quince ',
  			6,'Dieciseis ',
   			7,'Diecisiete ',
  			8,'Dieciocho ',
  			9,'Diecinueve ',
  			'ERROR ')),
   		2,(decode(.000000001*(mod(abs(Chk_Amt),10000000000)-mod(abs(Chk_Amt),1000000000)),
   			0,'Veinte ',
  			1,'Veintiun ',
  			2,'Veintidos ',
  			3,'Veintitres ',
   			4,'Veinticuatro ',
  			5,'Veinticinco ',
  			6,'Veintiseis ',
   			7,'Veintisiete ',
  			8,'Veintiocho ',
  			9,'Veintinueve ',
  			'ERROR')),
   		3,'Treinta ',
  		4,'Cuarenta ',
   		5,'Cincuenta ',
  		6,'Sesenta ',
  		7,'Setenta ',
  	 	8,'Ochenta ',
  		9,'Noventa ',
  		NULL) ||
        decode(.000000001*(mod(abs(Chk_Amt),10000000000)-mod(abs(Chk_Amt),1000000000)),
  		0,NULL,
  		(decode(.0000000001*(mod(abs(Chk_Amt),100000000000)-mod(abs(Chk_Amt),10000000000)),
   			0,NULL,
  			1,NULL,
  			2,NULL,
  			'y '))) ||
  	decode(.0000000001*(mod(abs(Chk_Amt),100000000000)-mod(abs(Chk_Amt),10000000000)),
  		1,NULL,
  		2,NULL,
  		(decode(.000000001*(mod(abs(Chk_Amt),10000000000)-mod(abs(Chk_Amt),1000000000)),
   			1,'Un ',
  			2,'Dos ',
  			3,'Tres ',
  			4,'Cuatro ',
  			5,'Cinco ',
   			6,'Seis ',
  			7,'Siete ',
  			8,'Ocho ',
  			9,'Nueve ',
   			0,NULL,
  			'ERROR '))) ||
   	decode(SIGN(abs(Chk_Amt)-999.99),
  		1,decode(.00000000001*(mod(abs(Chk_Amt),1000000000000)-mod(abs(Chk_Amt),100000000000)),
  			0,decode(.0000000001*(mod(abs(Chk_Amt),100000000000)-mod(abs(Chk_Amt),10000000000)),
  				0,decode(.000000001*(mod(abs(Chk_Amt),10000000000)-mod(abs(Chk_Amt),1000000000)),
  					0,NULL,
  					'Mil '),
  				'Mil '),
   			'Mil '),
  		NULL) ||
  	decode(.00000001*(mod(abs(Chk_Amt),1000000000)-mod(abs(Chk_Amt),100000000)),
                1,decode(mod(trunc(Chk_Amt/1000000),1000)-100, 0,'Cien ','Ciento '),
  		2,'Doscientos ',
  		3,'Trescientos ',
   		4,'Cuatrocientos ',
  		5,'Quinientos ',
  		6,'Seiscientos ',
  	 	7,'Setecientos ',
  		8,'Ochocientos ',
  		9,'Novecientos ',
   		0,null,
  		'ERROR ') ||
  	decode(.0000001*(mod(abs(Chk_Amt),100000000)-mod(abs(Chk_Amt),10000000)),
   		1,(decode(.000001*(mod(abs(Chk_Amt),10000000)-mod(abs(Chk_Amt),1000000)),
   			0,'Diez ',
  			1,'Once ',
  			2,'Doce ',
  			3,'Trece ',
   			4,'Catorce ',
  			5,'Quince ',
  			6,'Dieciseis ',
   			7,'Diecisiete ',
  			8,'Dieciocho ',
  			9,'Diecinueve ',
  			'ERROR ')),
   		2,(decode(.000001*(mod(abs(Chk_Amt),10000000)-mod(abs(Chk_Amt),1000000)),
   			0,'Veinte ',
  			1,'Veintiun ',
  			2,'Veintidos ',
  			3,'Veintitres ',
   			4,'Veinticuatro ',
  			5,'Veinticinco ',
  			6,'Veintiseis ',
   			7,'Veintisiete ',
  			8,'Veintiocho ',
  			9,'Veintinueve ',
  			'ERROR ')),
   		3,'Treinta ',
  		4,'Cuarenta ',
   		5,'Cincuenta ',
  		6,'Sesenta ',
  		7,'Setenta ',
   		8,'Ochenta ',
  		9,'Noventa ',
  		NULL) ||
  	decode(.000001*(mod(abs(Chk_Amt),10000000)-mod(abs(Chk_Amt),1000000)),
  		0,NULL,
  		(decode(.0000001*(mod(abs(Chk_Amt),100000000)-mod(abs(Chk_Amt),10000000)),
   			0,NULL,
  			1,NULL,
  			2,NULL,
  			'y '))) ||
  	decode(.0000001*(mod(abs(Chk_Amt),100000000)-mod(abs(Chk_Amt),10000000)),
   		1,NULL,
  		2,NULL,
  		(decode(.000001*(mod(abs(Chk_Amt),10000000)-mod(abs(Chk_Amt),1000000)),
   			1,'Un ',
  			2,'Dos ',
  			3,'Tres ',
  			4,'Cuatro ',
  			5,'Cinco ',
   			6,'Seis ',
  			7,'Siete ',
  			8,'Ocho ',
  			9,'Nueve ',
   			0,NULL,
  			'ERROR '))) ||
   	decode(trunc(Chk_amt/1000000),
  		0,NULL,
  		1,'Millon ',
  		'Millones ') ||
   	decode(.00001*(mod(abs(Chk_Amt),1000000)-mod(abs(Chk_Amt),100000)),
                1,decode(mod(trunc(Chk_Amt/1000),1000)-100, 0,'Cien ','Ciento '),
  		2,'Doscientos ',
  		3,'Trescientos ',
   		4,'Cuatrocientos ',
  		5,'Quinientos ',
  		6,'Seiscientos ',
   		7,'Setecientos ',
  		8,'Ochocientos ',
  		9,'Novecientos ',
   		0,null,
  		'ERROR ') ||
   	decode(.0001*(mod(abs(Chk_Amt),100000)-mod(abs(Chk_amt),10000)),
   		1,(decode(.001*(mod(abs(Chk_Amt),10000)-mod(abs(Chk_Amt),1000)),
   			0,'Diez ',
  			1,'Once ',
  			2,'Doce ',
  			3,'Trece ',
   			4,'Catorce ',
  			5,'Quince ',
  			6,'Dieciseis ',
   			7,'Diecisiete ',
  			8,'Dieciocho ',
  			9,'Diecinueve ',
  			'ERROR')),
   		2,(decode(.001*(mod(abs(Chk_Amt),10000)-mod(abs(Chk_Amt),1000)),
   			0,'Veinte ',
  			1,'Veintiun ',
  			2,'Veintidos ',
  			3,'Veintitres ',
   			4,'Veinticuatro ',
  			5,'Veinticinco ',
  			6,'Veintiseis ',
   			7,'Veintisiete ',
  			8,'Veintiocho ',
  			9,'Veintinueve ',
  			'ERROR ')),
   		3,'Treinta ',
  		4,'Cuarenta ',
   		5,'Cincuenta ',
  		6,'Sesenta ',
  		7,'Setenta ',
   		8,'Ochenta ',
  		9,'Noventa ',
  		NULL) ||
   	decode(.001*(mod(abs(Chk_Amt),10000)-mod(abs(Chk_Amt),1000)),
  		0,NULL,
   		(decode(.0001*(mod(abs(Chk_Amt),100000)-mod(abs(Chk_Amt),10000)),
   			0,NULL,
  			1,NULL,
  			2,NULL,
  			'y '))) ||
   	decode(.0001*(mod(abs(Chk_Amt),100000)-mod(abs(Chk_Amt),10000)),
  		1,NULL,
  		2,NULL,
  		(decode(.001*(mod(abs(Chk_Amt),10000)-mod(abs(Chk_Amt),1000)),
   			1,'Un ',
  			2,'Dos ',
  			3,'Tres ',
  			4,'Cuatro ',
  			5,'Cinco ',
   			6,'Seis ',
  			7,'Siete ',
  			8,'Ocho ',
  			9,'Nueve ',
   			0,NULL,
  			'ERROR '))) ||
   	decode(SIGN(abs(Chk_Amt)-999.99),
  		1,decode(.00001*(mod(abs(Chk_Amt),1000000)-mod(abs(Chk_Amt),100000)),
  			0,decode (.0001*(mod(abs(Chk_Amt),100000)-mod(abs(Chk_Amt),10000)),
  				0,decode(.001*(mod(abs(Chk_Amt),10000)-mod(abs(Chk_Amt),1000)),
  					0,NULL,
  					'Mil '),
   				'Mil '),
   			'Mil '),
    		NULL) ||
   	decode(.01*(mod(abs(Chk_Amt),1000)-mod(abs(Chk_Amt),100)),
                  1,decode(mod(trunc(Chk_Amt),1000)-100, 0,'Cien ','Ciento '),
  		2,'Doscientos ',
  		3,'Trescientos ',
   		4,'Cuatrocientos ',
  		5,'Quinientos ',
  		6,'Seiscientos ',
   		7,'Setecientos ',
  		8,'Ochocientos ',
  		9,'Novecientos ',
   		NULL) ||
   	decode(.1*(mod(abs(Chk_Amt),100)-mod(abs(Chk_Amt),10)),
   		1,(decode(trunc(mod(abs(Chk_Amt),10)),
   			0,'Diez ',
  			1,'Once ',
  			2,'Doce ',
  			3,'Trece ',
   			4,'Catorce ',
  			5,'Quince ',
  			6,'Dieciseis ',
   			7,'Diecisiete ',
  			8,'Dieciocho ',
  			9,'Diecinueve ',
  			'ERROR ')),
   		2,(decode(trunc(mod(abs(Chk_Amt),10)),
   			0,'Veinte ',
  			1,'Veintiun ',
  			2,'Veintidos ',
  			3,'Veintitres ',
   			4,'Veinticuatro ',
  			5,'Veinticinco ',
  			6,'Veintiseis ',
   			7,'Veintisiete ',
  			8,'Veintiocho ',
  			9,'Veintinueve ',
  			'ERROR ')),
   		2,'Veinte ',
  		3,'Treinta ',
  		4,'Cuarenta ',
   		5,'Cincuenta ',
  		6,'Sesenta ',
  		7,'Setenta ',
   		8,'Ochenta ',
  		9,'Noventa ',
  		NULL) ||
   	decode(trunc(mod(abs(Chk_Amt),10)),
  		0,NULL,
   		(decode(.1*(mod(abs(Chk_Amt),100)-mod(abs(Chk_Amt),10)),
   			0,NULL,
  			1,NULL,
  			2,NULL,
  			'y '))) ||
   	decode(.1*(mod(abs(Chk_Amt),100)-mod(abs(Chk_Amt),10)),
   		1,NULL,
  		2,NULL,
  		(decode(trunc(mod(abs(Chk_Amt),10)),
   			1,'Un ',
  			2,'Dos ',
  			3,'Tres ',
   			4,'Cuatro ',
  			5,'Cinco ',
  			6,'Seis ',
   			7,'Siete ',
  			8,'Ocho ',
  			9,'Nueve ',
   			0,null,
  			'ERROR '))) ||
   	decode(trunc(abs(Chk_Amt)),
  		0, 'Cero ',
  		null) ||
   	decode(100*(abs(Chk_Amt)-trunc(abs(Chk_Amt))),
   		0,'pesos', 'pesos con ' || TO_CHAR(ABS(100*(abs(Chk_Amt)-trunc(abs(Chk_Amt))))) || ' Centavos ')
     INTO l_amt_spanish1
     FROM dual;

     return(l_amt_spanish1);

  END AMOUNT_WORDS_SPANISH;


 FUNCTION AMOUNT_WORDS_MEXICAN(P_ENTERED NUMBER,
                       P_PRECISION INTEGER)
                       RETURN VARCHAR2 IS
    LOC_NUM       NUMBER(12);
    LOC_FEM       BOOLEAN;
    LOC_WORD1     VARCHAR2(240);
    LOC_WORD2     VARCHAR2(240);
    LOC_ENTERED   NUMBER(14,2);
    LOC_PRECISION NUMBER(2);

  BEGIN
    LOC_ENTERED := P_ENTERED;
    LOC_PRECISION := P_PRECISION;

    IF TRUNC(LOC_ENTERED) <> LOC_ENTERED
    THEN

       /* It has decimals - extract them */
       LOC_NUM := 100 * (LOC_ENTERED - TRUNC(LOC_ENTERED));

       /* centimos are always masculine */
       LOC_FEM := TRUE;
       IF  LOC_NUM < 10 THEN
         LOC_WORD1 := ' 0'||LOC_NUM||'/100 M.N.';
       ELSE
         LOC_WORD1 := ' '||LOC_NUM||'/100 M.N.';
       END IF;
    ELSE

     LOC_WORD1 := ' 00/100 M.N.';

    END IF;

    /* Convert the main part of the number */
    LOC_NUM := TRUNC(LOC_ENTERED);

    /*
    Guess whether the currency is masculine or feminine (this information isn't
    stored in Financials). Given that the Peseta is feminine and the Euro is
    masculine I am going to assume that if the currency's precision is 0 that it
    is feminine, if more (ie 2) that it is masculine
    */

       LOC_FEM := FALSE;


    LOC_WORD2 := JEES_NTW_CONV_NUM_FRAGMENT (LOC_NUM, LOC_FEM);

    LOC_WORD1 := LOC_WORD2||' PESOS CON'||LOC_WORD1;

    RETURN LOC_WORD1;

  END AMOUNT_WORDS_MEXICAN;

FUNCTION amount_words_portugese(valor NUMBER) RETURN VARCHAR2 IS
first_line_len constant NUMBER(2) := 55;
second_line_len constant NUMBER(3) := 70;
amount_total_len constant NUMBER(3) := 201;
valor_extenso VARCHAR2(350) := '';
valor_temp VARCHAR2(350) := '';
v_first_line VARCHAR2(55);
v_first_line_len NUMBER;
v_i binary_integer;
b1 NUMBER(1);
b2 NUMBER(1);
b3 NUMBER(1);
b4 NUMBER(1);
b5 NUMBER(1);
b6 NUMBER(1);
b7 NUMBER(1);
b8 NUMBER(1);
b9 NUMBER(1);
b10 NUMBER(1);
b11 NUMBER(1);
b12 NUMBER(1);
b13 NUMBER(1);
b14 NUMBER(1);
l1 VARCHAR2(12);
l2 VARCHAR2(3);
l3 VARCHAR2(9);
l4 VARCHAR2(3);
l5 VARCHAR2(6);
l6 VARCHAR2(8);
l7 VARCHAR2(12);
l8 VARCHAR2(3);
l9 VARCHAR2(9);
l10 VARCHAR2(3);
l11 VARCHAR2(6);
l12 VARCHAR2(8);
l13 VARCHAR2(12);
l14 VARCHAR2(3);
l15 VARCHAR2(9);
l16 VARCHAR2(3);
l17 VARCHAR2(6);
l18 VARCHAR2(8);
l19 VARCHAR2(12);
l20 VARCHAR2(3);
l21 VARCHAR2(9);
l22 VARCHAR2(3);
l23 VARCHAR2(6);
l24 VARCHAR2(7);
l25 VARCHAR2(3);
l26 VARCHAR2(9);
l27 VARCHAR2(3);
l28 VARCHAR2(6);
l29 VARCHAR2(10);
virgula_bi VARCHAR2(4);
virgula_mi VARCHAR2(4);
virgula_mil VARCHAR2(4);
virgula_cr VARCHAR2(4);
valor1 VARCHAR2(14);
--
-- Table of hundreds --
centenas VARCHAR2(108) := '       CENTO    DUZENTOS   TREZENTOS' ||
'QUATROCENTOS  QUINHENTOS  SEISCENTOS' ||
'  SETECENTOS  OITOCENTOS  NOVECENTOS';

-- Table of Dozens --
dezenas VARCHAR2(81) := '      DEZ    VINTE   TRINTA QUARENTA' ||
'CINQUENTA SESSENTA  SETENTA  OITENTA' ||
'NOVENTA';

-- Table of  Units --
unidades VARCHAR2(54) := '    UM  DOIS  TRESQUATRO CINCO  SEIS' ||
'  SETE  OITO  NOVE';

-- Table of units of Dozens 10 --
unid10 VARCHAR2(81) := '     ONZE     DOZE    TREZE QUATORZE' ||
'   QUINZEDEZESSEISDEZESSETE  DEZOITO' ||
' DEZENOVE';


BEGIN

    valor1 := lpad(to_char(valor * 100),   14,   '0');
    b1 := SUBSTR(valor1,   1,   1);
    b2 := SUBSTR(valor1,   2,   1);
    b3 := SUBSTR(valor1,   3,   1);
    b4 := SUBSTR(valor1,   4,   1);
    b5 := SUBSTR(valor1,   5,   1);
    b6 := SUBSTR(valor1,   6,   1);
    b7 := SUBSTR(valor1,   7,   1);
    b8 := SUBSTR(valor1,   8,   1);
    b9 := SUBSTR(valor1,   9,   1);
    b10 := SUBSTR(valor1,   10,   1);
    b11 := SUBSTR(valor1,   11,   1);
    b12 := SUBSTR(valor1,   12,   1);
    b13 := SUBSTR(valor1,   13,   1);
    b14 := SUBSTR(valor1,   14,   1);

    IF valor <> 0 THEN

      IF b1 <> 0 THEN

        IF b1 = 1 THEN

          IF b2 = 0
           AND b3 = 0 THEN
            l5 := 'CEM';
          ELSE
            l1 := SUBSTR(centenas,   b1 * 12 -11,   12);
          END IF;

        ELSE
          l1 := SUBSTR(centenas,   b1 * 12 -11,   12);
        END IF;

      END IF;

      IF b2 <> 0 THEN

        IF b2 = 1 THEN

          IF b3 = 0 THEN
            l5 := 'DEZ';
          ELSE
            l3 := SUBSTR(unid10,   b3 * 9 -8,   9);
          END IF;

        ELSE
          l3 := SUBSTR(dezenas,   b2 * 9 -8,   9);
        END IF;

      END IF;

      IF b3 <> 0 THEN

        IF b2 <> 1 THEN
          l5 := SUBSTR(unidades,   b3 * 6 -5,   6);
        END IF;

      END IF;

      IF b1 <> 0 OR b2 <> 0 OR b3 <> 0 THEN

        IF(b1 = 0
         AND b2 = 0)
         AND b3 = 1 THEN
          l5 := 'HUM';
          l6 := ' BILHAO';
        ELSE
          l6 := ' BILHOES';
        END IF;

        IF valor > 999999999 THEN
          --  if trunc(valor,0) = 1000000000 then

          IF SUBSTR(valor1,   4,   9) = '000000000' THEN
            virgula_bi := ' DE ';
          ELSE
            virgula_bi := ' E ';
          END IF;

        ELSE
          virgula_bi := ' ';
        END IF;

        l1 := LTRIM(l1);
        l3 := LTRIM(l3);
        l5 := LTRIM(l5);

        IF b2 > 1
         AND b3 > 0 THEN
          l4 := ' E ';
        END IF;

        IF b1 <> 0
         AND(b2 <> 0 OR b3 <> 0) THEN
          l2 := ' E ';
        END IF;

      END IF;

      --  ROTINA DOS MILHOES  ------------
      amount_words_portgse_milhares(valor,   b4,   b5,   b6,   b7,   b8,   b9,   l7,   l8,   l9,   l10,   l11,   l12,   virgula_mi);
      --
      --  ROTINA DAS CENTENAS --
      amount_words_portgse_centos(valor,   b7,   b8,   b9,   b10,   b11,   b12,   l13,   l14,   l15,   l16,   l17,   l18,   virgula_mil);
      --
      --  ROTINA DAS DEZENAS --
      amount_words_portgse_dezena(valor,   b10,   b11,   b12,   l19,   l20,   l21,   l22,   l23,   l24,   virgula_cr);
      --
      --  TRATA CENTAVOS  --
      amount_words_portgse_centavos(valor,   b13,   b14,   l25,   l26,   l27,   l28,   l29);
      --
      --  CONCATENAR O LITERAL  --
      valor_temp := l1 || l2 || l3 || l4 || l5 || l6 || virgula_bi || l7 || l8 || l9 || l10 || l11 || l12 || virgula_mi || l13 || l14 || l15 || l16 || l17 || l18 || virgula_mil || l19 || l20 ;
      valor_extenso := valor_temp || l21 || l22 || l23 || l24 || virgula_cr || l25 || l26 || l27 || l28 || l29;

      --Commented out by Usha on 14-MAy-99 to test the layout problem

      /*          FOR v_i IN REVERSE 1..83 LOOP
      FOR v_i IN REVERSE 1 .. 56
      LOOP

        IF SUBSTR(valor_extenso,   v_i,   1) = ' ' THEN
          v_first_line_len := v_i -1;
          EXIT;
        END IF;

      END LOOP;
      valor_extenso := rpad(SUBSTR(valor_extenso,   1,   v_first_line_len),   first_line_len,   ' ') || rpad(' ',   second_line_len + 1,   ' ') || SUBSTR(valor_extenso,   v_first_line_len + 1,   120);
      */

    ELSE
      --if not setup and check_amount is 0, print 'Z E R O'
      valor_extenso := 'ZERO REAIS';
    END IF;

  --valor_extenso := rpad(' ',   10,   ' ') || valor_extenso;
  --valor_extenso := SUBSTR(valor_extenso,   1,   amount_total_len);

  RETURN(valor_extenso);
END;

PROCEDURE amount_words_portgse_milhares(valor NUMBER, b4 NUMBER, b5 NUMBER, b6 NUMBER, b7 NUMBER, b8 NUMBER, b9 NUMBER, l7 OUT NOCOPY VARCHAR2, l8 OUT NOCOPY VARCHAR2, l9 OUT NOCOPY VARCHAR2, l10 OUT NOCOPY VARCHAR2,
l11 OUT NOCOPY VARCHAR2, l12 OUT NOCOPY VARCHAR2, virgula_mi OUT NOCOPY VARCHAR2) IS
      --
      -- TABELA DE CENTENAS --
      centenas VARCHAR2(108) := '       CENTO    DUZENTOS   TREZENTOS' || 'QUATROCENTOS  QUINHENTOS  SEISCENTOS' || '  SETECENTOS  OITOCENTOS  NOVECENTOS';
      -- TABELA DE DEZENAS --
      dezenas VARCHAR2(81) := '      DEZ    VINTE   TRINTA QUARENTA' || 'CINQUENTA SESSENTA  SETENTA  OITENTA' || 'NOVENTA';
      -- TABELA DE UNIDADES --
      unidades VARCHAR2(54) := '    UM  DOIS  TRESQUATRO CINCO  SEIS' || '  SETE  OITO  NOVE';
      -- TABELA DE UNIDADES DA DEZENA 10 --
      unid10 VARCHAR2(81) := '     ONZE     DOZE    TREZE QUATORZE' || '   QUINZEDEZESSEISDEZESSETE  DEZOITO' || ' DEZENOVE';
      --
      valor1 VARCHAR2(14);
      BEGIN
        valor1 := lpad(to_char(valor * 100),   14,   '0');

        IF b4 <> 0 THEN

          IF b4 = 1 THEN

            IF b5 = 0
             AND b6 = 0 THEN
              l7 := 'CEM';
            ELSE
              l7 := SUBSTR(centenas,   b4 * 12 -11,   12);
            END IF;

          ELSE
            l7 := SUBSTR(centenas,   b4 * 12 -11,   12);
          END IF;

        END IF;

        IF b5 <> 0 THEN

          IF b5 = 1 THEN

            IF b6 = 0 THEN
              l11 := 'DEZ';
            ELSE
              l9 := SUBSTR(unid10,   b6 * 9 -8,   9);
            END IF;

          ELSE
            l9 := SUBSTR(dezenas,   b5 * 9 -8,   9);
          END IF;

        END IF;

        IF b6 <> 0 THEN

          IF b5 <> 1 THEN
            l11 := SUBSTR(unidades,   b6 * 6 -5,   6);
          END IF;

        END IF;

        IF b4 <> 0 OR b5 <> 0 OR b6 <> 0 THEN

          IF(b4 = 0
           AND b5 = 0)
           AND b6 = 1 THEN
            l11 := 'HUM';
            l12 := ' MILHAO';
          ELSE
            l12 := ' MILHOES';
          END IF;

          IF valor > 999999 THEN
            -- if trunc(valor,0) = 1000000 then

            IF SUBSTR(valor1,   7,   6) = '000000' THEN
              virgula_mi := ' DE ';
            ELSE
              virgula_mi := ' E ';
            END IF;

          ELSE
            virgula_mi := ' ';
          END IF;

          l7 := LTRIM(l7);
          l9 := LTRIM(l9);
          l11 := LTRIM(l11);

          IF b5 > 1
           AND b6 > 0 THEN
            l10 := ' E ';
          END IF;

          IF b4 <> 0
           AND(b5 <> 0 OR b6 <> 0) THEN
            l8 := ' E ';
          END IF;

        END IF;

      END;

PROCEDURE amount_words_portgse_centos(valor NUMBER, b7 NUMBER, b8 NUMBER, b9 NUMBER, b10 NUMBER, b11 NUMBER, b12 NUMBER, l13 OUT NOCOPY VARCHAR2, l14 OUT NOCOPY VARCHAR2, l15 OUT NOCOPY VARCHAR2, l16 OUT NOCOPY VARCHAR2,
l17 OUT NOCOPY VARCHAR2, l18 OUT NOCOPY VARCHAR2, virgula_mil OUT NOCOPY VARCHAR2) IS
--
-- TABELA DE CENTENAS --
centenas VARCHAR2(108) := '       CENTO    DUZENTOS   TREZENTOS' || 'QUATROCENTOS  QUINHENTOS  SEISCENTOS' || '  SETECENTOS  OITOCENTOS  NOVECENTOS';
-- TABELA DE DEZENAS --
dezenas VARCHAR2(81) := '      DEZ    VINTE   TRINTA QUARENTA' || 'CINQUENTA SESSENTA  SETENTA  OITENTA' || 'NOVENTA';
-- TABELA DE UNIDADES --
unidades VARCHAR2(54) := '    UM  DOIS  TRESQUATRO CINCO  SEIS' || '  SETE  OITO  NOVE';
-- TABELA DE UNIDADES DA DEZENA 10 --
unid10 VARCHAR2(81) := '     ONZE     DOZE    TREZE QUATORZE' || '   QUINZEDEZESSEISDEZESSETE  DEZOITO' || ' DEZENOVE';
--

BEGIN

  IF b7 <> 0 THEN

    IF b7 = 1 THEN

      IF b8 = 0
       AND b9 = 0 THEN
        l17 := 'CEM';
      ELSE
        l13 := SUBSTR(centenas,   b7 * 12 -11,   12);
      END IF;

    ELSE
      l13 := SUBSTR(centenas,   b7 * 12 -11,   12);
    END IF;

  END IF;

  IF b8 <> 0 THEN

    IF b8 = 1 THEN

      IF b9 = 0 THEN
        l17 := 'DEZ';
      ELSE
        l15 := SUBSTR(unid10,   b9 * 9 -8,   9);
      END IF;

    ELSE
      l15 := SUBSTR(dezenas,   b8 * 9 -8,   9);
    END IF;

  END IF;

  IF b9 <> 0 THEN

    IF b8 <> 1 THEN
      l17 := SUBSTR(unidades,   b9 * 6 -5,   6);
    END IF;

  END IF;

  IF b7 <> 0 OR b8 <> 0 OR b9 <> 0 THEN

    IF(b7 = 0
     AND b8 = 0)
     AND b9 = 1 THEN
      l17 := 'HUM';
      l18 := ' MIL';
    ELSE
      l18 := ' MIL';
    END IF;

    IF valor > 999 THEN
      --   if trunc(valor,0) = 1000 then

      IF b10 = 0
       AND b11 = 0
       AND b12 = 0 THEN
        --     virgula_mil := ' DE ';
        -- Fix for Bug 854014
        virgula_mil := ' ';
      ELSE
        virgula_mil := ' E ';
      END IF;

      --   else
      --    if b10 = 0 and b11 = 0 and b12 = 0 then
      --     virgula_mil  := ' ';
      --    else
      --     virgula_mil  := ' E ';
      --    end if;
      --  end if;
    ELSE
      virgula_mil := ' ';
    END IF;

    l13 := LTRIM(l13);
    l15 := LTRIM(l15);
    l17 := LTRIM(l17);

    IF b8 > 1
     AND b9 > 0 THEN
      l16 := ' E ';
    END IF;

    IF b7 <> 0
     AND(b8 <> 0 OR b9 <> 0) THEN
      l14 := ' E ';
    END IF;

  END IF;

END;

PROCEDURE amount_words_portgse_dezena(valor IN NUMBER,   b10 IN NUMBER,   b11 IN NUMBER,   b12 IN NUMBER,   l19 OUT NOCOPY VARCHAR2,   l20 OUT NOCOPY VARCHAR2,   l21 OUT NOCOPY VARCHAR2,   l22 OUT NOCOPY VARCHAR2,
l23 OUT NOCOPY VARCHAR2,   l24 OUT NOCOPY VARCHAR2,   virgula_cr OUT NOCOPY VARCHAR2) IS
--
-- TABELA DE CENTENAS --
centenas VARCHAR2(108) := '       CENTO    DUZENTOS   TREZENTOS' || 'QUATROCENTOS  QUINHENTOS  SEISCENTOS' || '  SETECENTOS  OITOCENTOS  NOVECENTOS';
-- TABELA DE DEZENAS --
dezenas VARCHAR2(81) := '      DEZ    VINTE   TRINTA QUARENTA' || 'CINQUENTA SESSENTA  SETENTA  OITENTA' || 'NOVENTA';
-- TABELA DE UNIDADES --
unidades VARCHAR2(54) := '    UM  DOIS  TRESQUATRO CINCO  SEIS' || '  SETE  OITO  NOVE';
-- TABELA DE UNIDADES DA DEZENA 10 --
unid10 VARCHAR2(81) := '     ONZE     DOZE    TREZE QUATORZE' || '   QUINZEDEZESSEISDEZESSETE  DEZOITO' || ' DEZENOVE';
--
BEGIN

  IF b10 <> 0 THEN

    IF b10 = 1 THEN

      IF b11 = 0
       AND b12 = 0 THEN
        l19 := 'CEM';
      ELSE
        l19 := SUBSTR(centenas,   b10 * 12 -11,   12);
      END IF;

    ELSE
      l19 := SUBSTR(centenas,   b10 * 12 -11,   12);
    END IF;

  END IF;

  IF b11 <> 0 THEN

    IF b11 = 1 THEN

      IF b12 = 0 THEN
        l23 := 'DEZ';
      ELSE
        l21 := SUBSTR(unid10,   b12 * 9 -8,   9);
      END IF;

    ELSE
      l21 := SUBSTR(dezenas,   b11 * 9 -8,   9);
    END IF;

  END IF;

  IF b12 <> 0 THEN

    IF b11 <> 1 THEN
      l23 := SUBSTR(unidades,   b12 * 6 -5,   6);
    END IF;

  END IF;

  IF b10 <> 0 OR b11 <> 0 OR b12 <> 0 THEN
    -- if valor > 99 and valor < 200 then
    --    l23 :=  'TRES';
    -- end if;
    l19 := LTRIM(l19);
    l21 := LTRIM(l21);
    l23 := LTRIM(l23);

    IF b11 > 1
     AND b12 > 0 THEN
      l22 := ' E ';
    END IF;

    IF b10 <> 0
     AND(b11 <> 0 OR b12 <> 0) THEN
      l20 := ' E ';
    END IF;

  ELSE
    virgula_cr := ' ';
  END IF;

  IF valor < 1 THEN
    l24 := ' ';
    ELSIF valor < 2 THEN
      l24 := ' REAL ';
    ELSE
      l24 := ' REAIS ';
      --else
      --   if valor > 199 then
      --     l24 := ' REAIS';
      --  end if;
    END IF;

  END;

  PROCEDURE amount_words_portgse_centavos(valor IN NUMBER,   b13 IN NUMBER,   b14 IN NUMBER,   l25 OUT NOCOPY VARCHAR2,   l26 OUT NOCOPY VARCHAR2,   l27 OUT NOCOPY VARCHAR2,   l28 OUT NOCOPY VARCHAR2,   l29 OUT NOCOPY VARCHAR2) IS
  --
  -- Table of Dozens
  dezenas VARCHAR2(81) := '      DEZ    VINTE   TRINTA QUARENTA' || 'CINQUENTA SESSENTA  SETENTA  OITENTA' || 'NOVENTA';
  -- Table of Units --
  unidades VARCHAR2(54) := '    UM  DOIS  TRESQUATRO CINCO  SEIS' || '  SETE  OITO  NOVE';
  -- Table of Units of Dozens 10  --
  unid10 VARCHAR2(81) := '     ONZE     DOZE    TREZE QUATORZE' || '   QUINZEDEZESSEISDEZESSETE  DEZOITO' || ' DEZENOVE';
  --
  BEGIN

    IF b13 <> 0 OR b14 <> 0 THEN

      IF valor > 99 THEN
        l25 := ' E ';
      END IF;

      IF b13 <> 0 THEN

        IF b13 = 1 THEN

          IF b14 = 0 THEN
            l28 := 'DEZ';
          ELSE
            l26 := SUBSTR(unid10,   b14 * 9 -8,   9);
          END IF;

        ELSE
          l26 := SUBSTR(dezenas,   b13 * 9 -8,   9);
        END IF;

      END IF;

      IF b14 <> 0 THEN

        IF b13 <> 1 THEN
          l28 := SUBSTR(unidades,   b14 * 6 -5,   6);
        END IF;

      END IF;

      IF b13 <> 0 OR b14 <> 0 THEN

        IF valor = 1 THEN
          l28 := 'HUM';
        END IF;

        l26 := LTRIM(l26);
        l28 := LTRIM(l28);

        IF b13 > 1
         AND b14 > 0 THEN
          l27 := ' E ';
        END IF;

      END IF;

      IF b13 = 0
       AND b14 = 1 THEN

        /* Bug 1074379 included a space towards the end of the string CENTAVO */ l29 := ' CENTAVO ';
      ELSE

        /* Bug 1074379 included a space towards the end of the string CENTAVOS */ l29 := ' CENTAVOS ';
      END IF;

    END IF;

  END;
-- end of package
END IBY_AMOUNT_IN_WORDS;


/
