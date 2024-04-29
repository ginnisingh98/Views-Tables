--------------------------------------------------------
--  DDL for Package Body IBY_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_UTILITY_PVT" AS
/* $Header: ibyvutlb.pls 120.13.12010000.22 2010/09/02 06:21:27 gmaheswa ship $ */


  -- Added for encoding/decoding in Base64.
  TYPE vc2_table IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  TYPE t_psr_record_type IS RECORD(
  psr_status  VARCHAR2(30),
  payment_status_flag  VARCHAR2(1)
   );

  TYPE psr_table_type IS TABLE OF t_psr_record_type INDEX BY BINARY_INTEGER;

  g_psr_table psr_table_type;

  TYPE t_psr_snapshot_record_type IS RECORD(
  psr_snapshot_count  NUMBER
   );

  TYPE psr_snapshot_table_type IS TABLE OF t_psr_snapshot_record_type INDEX BY varchar2(30);

  g_psr_snapshot_table psr_snapshot_table_type;

  TYPE t_instr_access_record_type IS RECORD(
  instruction_id  Number,
  access_flag  VARCHAR2(1)
   );

  TYPE instr_access_table_type IS TABLE OF t_instr_access_record_type INDEX BY BINARY_INTEGER;

  g_instr_access_table instr_access_table_type;

  map vc2_table;

  --
  -- UTILITY PROCEDURE #1: INIT_MAP
  --  This procedure maps the numbers from 0 through 63 to character literals
  --  for Base64 encoding. Initializes the Base64 mapping.
  --
  PROCEDURE init_map IS
  BEGIN
      -- do not initialize it more than once
      IF (map.count > 0) THEN
        RETURN;
      END IF;

      map(0) :='A'; map(1) :='B'; map(2) :='C'; map(3) :='D'; map(4) :='E';
      map(5) :='F'; map(6) :='G'; map(7) :='H'; map(8) :='I'; map(9):='J';
      map(10):='K'; map(11):='L'; map(12):='M'; map(13):='N'; map(14):='O';
      map(15):='P'; map(16):='Q'; map(17):='R'; map(18):='S'; map(19):='T';
      map(20):='U'; map(21):='V'; map(22):='W'; map(23):='X'; map(24):='Y';
      map(25):='Z'; map(26):='a'; map(27):='b'; map(28):='c'; map(29):='d';
      map(30):='e'; map(31):='f'; map(32):='g'; map(33):='h'; map(34):='i';
      map(35):='j'; map(36):='k'; map(37):='l'; map(38):='m'; map(39):='n';
      map(40):='o'; map(41):='p'; map(42):='q'; map(43):='r'; map(44):='s';
      map(45):='t'; map(46):='u'; map(47):='v'; map(48):='w'; map(49):='x';
      map(50):='y'; map(51):='z'; map(52):='0'; map(53):='1'; map(54):='2';
      map(55):='3'; map(56):='4'; map(57):='5'; map(58):='6'; map(59):='7';
      map(60):='8'; map(61):='9'; map(62):='+'; map(63):='/';
  END init_map;


  --
  -- UTILITY FUNCTION#1: GET_MAP
  --  This function returns the Base64 number equivalent for a character
  --  literal passed.  It returns values 0 through 63 for all the values that
  --  are mapped. When it does not find the character in the table it returns
  --  the value 64.
  --
  FUNCTION get_map( t IN VARCHAR2 ) RETURN NUMBER IS
   temp NUMBER;
  BEGIN
      temp := 0;
      WHILE temp < 64 LOOP
            EXIT WHEN ( map(temp) = t );
            temp := temp + 1;
      END LOOP;
      RETURN temp;
  END get_map;

  FUNCTION to_num( p_str IN VARCHAR2 ) RETURN NUMBER
  IS
  BEGIN
    RETURN to_number( p_str );
  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;
  END to_num;

  FUNCTION isNumeric (p_input IN VARCHAR2) RETURN VARCHAR2
  IS
    l_number NUMBER;
  BEGIN
    l_number := p_input;
      RETURN 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';
  END isNumeric;

  PROCEDURE handle_exceptions
  (
  p_api_name        IN  VARCHAR2,
  p_pkg_name        IN  VARCHAR2,
  p_rollback_point  IN  VARCHAR2,
  p_exception_type  IN  VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name                          VARCHAR2(30);
    l_ora_err_code                      NUMBER;
    -- the maximum length of Oracle error msg is 512
    -- make it longer for future enh
    l_ora_err_msg                       VARCHAR2(2000);
    l_error_reason                      VARCHAR2(80);
  BEGIN

    iby_debug_pub.add('entered IBY_UTILITY_PVT.handle_exceptions()');

    l_api_name := UPPER(p_api_name);

    -- rollback to the savepoint
    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(p_rollback_point);

    IF p_exception_type = iby_utility_pvt.g_expt_err
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_error_reason  := 'FND_API.G_RET_STS_ERROR';
    ELSIF p_exception_type = iby_utility_pvt.g_expt_unexp_err
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_error_reason  := 'FND_API.G_RET_STS_UNEXP_ERROR';
    ELSIF p_exception_type = iby_utility_pvt.g_expt_otr_err
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_error_reason  := 'G_EXC_OTHERS';

        l_ora_err_code := SQLCODE;
        l_ora_err_msg  := SQLERRM;

        iby_debug_pub.add('Oracle error in ' || p_pkg_name || '.' || p_api_name || ', code: '|| l_ora_err_code);
        iby_debug_pub.add('Oracle error in ' || p_pkg_name || '.' || p_api_name || ', msg : '|| l_ora_err_msg);
--dbms_output.put_line('Oracle error, code: '|| l_ora_err_code);
--dbms_output.put_line('Oracle error, msg : '|| l_ora_err_msg);

        fnd_message.set_name('IBY', 'IBY_G_SQL_ERR');
        fnd_message.set_token('API', p_pkg_name || '.' || p_api_name);
        fnd_message.set_token('SQLCODE', l_ora_err_code);
        fnd_message.set_token('SQLERRM', l_ora_err_msg);
        FND_MSG_PUB.ADD;

    END IF;

    FND_MSG_PUB.Count_And_Get(
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data);

    iby_debug_pub.add('x_msg_count: ' || x_msg_count);
    iby_debug_pub.add('x_msg_data: ' || x_msg_data);
    iby_debug_pub.add('x_return_status: ' || x_return_status);

    -- finally add the exception msg to debug log
/*
    iby_debug_pub.add_return_messages(
      p_count    => x_msg_count,
      p_data     => x_msg_data,
      p_reason   => l_error_reason
    );
*/

  END Handle_Exceptions;

  PROCEDURE handleException
        (
        p_err_msg IN VARCHAR2,
        p_err_code IN VARCHAR2
        )
  IS
        l_ibycode_start NUMBER;
        l_ibycode_end NUMBER;
        l_index NUMBER;
        l_msg_len NUMBER;
        l_val_concat NUMBER;
        l_tok_concat NUMBER;

        l_err_code VARCHAR2(200);
        l_token_name VARCHAR2(200);
        l_token_val VARCHAR2(200);
  BEGIN
        l_msg_len := LENGTH(p_err_msg);
        --
        -- check if 'IBY_' is present in the error message; if so
        -- then the exception was internally generated
        --
        l_ibycode_start := INSTR(p_err_msg,iby_utility_pvt.C_ERRCODE_PREFIX);

        IF (l_ibycode_start > 0) THEN

          l_ibycode_end:=INSTR(p_err_msg,iby_utility_pvt.C_TOKEN_CONCATENATOR)-1;
          IF (l_ibycode_end < 1) THEN
            l_ibycode_end := l_msg_len;
          END IF;
          l_err_code := SUBSTR(p_err_msg,l_ibycode_start,l_ibycode_end-l_ibycode_start+1);
          FND_MESSAGE.SET_NAME('IBY',l_err_code);

          -- +1 to go the position of the token concatenator; +1 again to
          -- to go past it to the beginning of the token name
          --
          l_index:= l_ibycode_end+1+1;
          WHILE l_index < l_msg_len LOOP
            l_val_concat := INSTR(p_err_msg,iby_utility_pvt.C_TOKEN_VAL_CONCATENATOR,l_index);
            IF (l_val_concat < 1) THEN
              EXIT;
            END IF;
            l_tok_concat := INSTR(p_err_msg,iby_utility_pvt.C_TOKEN_CONCATENATOR,l_index);
            IF (l_tok_concat < 1) THEN
              -- the error message is usually of the form:
              --
              -- ORA-2000: IBY_XXXX#TOKENNAME=TOKENVAL#...<new line>
              -- ORA-06512 ...
              --
              -- we wish to ignore the text after the
              -- last token on the first line
              --

              -- note the -1 is for the newline character after the last
              -- token value
              --
              l_tok_concat := INSTR(p_err_msg,'ORA',l_index)-1;
              IF (l_tok_concat < 1) THEN
                -- +1 so that the last character of the token value is
                -- included
                l_tok_concat := l_msg_len +1;
              END IF;
            END IF;

            l_token_name := SUBSTR(p_err_msg,l_index,(l_val_concat-1)-l_index+1);
            l_token_val := SUBSTR(p_err_msg,l_val_concat+1,(l_tok_concat-1)-(l_val_concat+1)+1);
            FND_MESSAGE.SET_TOKEN(l_token_name,l_token_val);
            --
            -- go +1 character past the token concatenator
            --
            l_index := l_tok_concat + 1;
          END LOOP;
          FND_MSG_PUB.ADD;
        --
        -- no IBY message found; simply put the exact text of
        -- the exception into the FND_MSG stack
        --
        ELSE
	  FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
	  FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT',p_err_msg);
	  FND_MSG_PUB.ADD;
        END IF;
  END handleException;


  PROCEDURE get_property
	(
	p_name      IN  VARCHAR2,
	x_val       OUT NOCOPY VARCHAR2
	)
  IS
  BEGIN
	FND_PROFILE.get(p_name,x_val);
  END get_property;


  PROCEDURE set_property
	(
	p_name      IN  VARCHAR2,
	p_val       IN  VARCHAR2
	)
  IS
	l_rtn_sts   BOOLEAN;
  BEGIN

	l_rtn_sts := FND_PROFILE.save(p_name,p_val,'SITE');
	--
	-- 2nd put is so that the value is visible in the
	-- current session
	--
	FND_PROFILE.put(p_name,p_val);
	COMMIT;

  END set_property;



--
-- Name: get_jtf_property
-- Args: p_name => property name
-- Outs: x_val => property value
--
-- Notes: gets an IBY property from old JTF Property manager tables.
--        only the first element of the value list is returned.
--        this function is used by ibyprupg.sql
--
FUNCTION get_jtf_property(p_name IN  VARCHAR2)
RETURN VARCHAR2 IS

    p_api_version_number   NUMBER := 1.0;
    p_init_msg_list        VARCHAR2(2000) := FND_API.G_FALSE;
    p_application_id       NUMBER := 673;
    p_profile_id           NUMBER;
    p_profile_name         VARCHAR2(2000) := 'JTF_PROPERTY_MANAGER_DEFAULT_1';
    p_perz_data_id         NUMBER;
    p_perz_data_type       VARCHAR2(2000) := 'JTF';

    x_return_status VARCHAR2(2000);
    x_msg_count NUMBER := 0;
    x_msg_data  VARCHAR2(2000);
    x_perz_data_id         NUMBER;
    x_perz_data_name       VARCHAR2(2000);
    x_perz_data_type       VARCHAR2(2000);
    x_perz_data_desc       VARCHAR2(2000);
    x_data_attrib_tbl      JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE;

    p_temp_var             VARCHAR2(2);
    x_val                  VARCHAR2(2000);

  BEGIN

    JTF_PERZ_DATA_PUB.GET_PERZ_DATA( p_api_version_number,
                                     p_init_msg_list,
                                     p_application_id,
                                     p_profile_id,
                                     p_profile_name,
                                     p_perz_data_id,
                                     p_name,
                                     p_perz_data_type,
                                     x_perz_data_id,
                                     x_perz_data_name,
                                     x_perz_data_type,
                                     x_perz_data_desc,
                                     x_data_attrib_tbl,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data
                                     );

    IF ((x_return_status IS NULL OR
         x_return_status <> FND_API.G_RET_STS_SUCCESS) OR
       (x_data_attrib_tbl.count<1)) THEN
      x_val := NULL;
    ELSE
      x_val := x_data_attrib_tbl(1).attribute_value;
    END IF;

    return x_val;

END get_jtf_property;


  --
  --
  FUNCTION encode64(s IN VARCHAR2) RETURN VARCHAR2 IS
     r RAW(32767);
     i pls_integer;
     x pls_integer;
     y pls_integer;
     v VARCHAR2(32767);
  BEGIN

      init_map;
      r := UTL_RAW.CAST_TO_RAW( s );

      -- For every 3 bytes, split them into 4 6-bit units and map them to
      -- the Base64 characters
      i := 1;
      WHILE ( i + 2 <= utl_raw.length(r) ) LOOP
	 x := to_number(utl_raw.substr(r, i, 1), '0X') * 65536 +
	      to_number(utl_raw.substr(r, i + 1, 1), '0X') * 256 +
	      to_number(utl_raw.substr(r, i + 2, 1), '0X');
	 y := floor(x / 262144); v := v || map(y); x := x - y * 262144;
	 y := floor(x / 4096);	 v := v || map(y); x := x - y * 4096;
	 y := floor(x / 64);	 v := v || map(y); x := x - y * 64;
	                         v := v || map(x);
	 i := i + 3;
      END LOOP;

      -- Process the remaining bytes that has fewer than 3 bytes.
      --when last two bytes are '='
      IF ( utl_raw.length(r) - i = 0) THEN
	 x := to_number(utl_raw.substr(r, i, 1), '0X');
	 y := floor(x / 4);	 v := v || map(y); x := x - y * 4;
	 x := x * 16;            v := v || map(x);
         v := v || '==';
      --when last one byte is '='
      ELSIF ( utl_raw.length(r) - i = 1) THEN
	 x := to_number(utl_raw.substr(r, i, 1), '0X') * 256 +
  	      to_number(utl_raw.substr(r, i + 1, 1), '0X');
	 y := floor(x / 1024);	 v := v || map(y); x := x - y * 1024;
	 y := floor(x / 16);	 v := v || map(y); x := x - y * 16;
	 x := x * 4;             v := v || map(x);
         v := v || '=';
      END IF;

      RETURN v;

  END encode64;

  --
  --
  FUNCTION decode64(s IN VARCHAR2) RETURN VARCHAR2 IS
     i pls_integer;
     x pls_integer;
     y pls_integer;
     iTh pls_integer;
     iPlusOne pls_integer;
     iPlusTwo pls_integer;
     iPlusThree pls_integer;
     v VARCHAR2(32767);
  BEGIN
      init_map;
      i := 1;
      v := '';
      --Processing 4 bytes at a time. For every 4 bytes, convert them into 3 bytes.
      WHILE ( i + 3 <= LENGTH(s) ) LOOP
         iTh := get_map( SUBSTR( s, i, 1) );
         iPlusOne := get_map( SUBSTR( s, i + 1, 1) );
         iPlusTwo := get_map( SUBSTR( s, i + 2, 1) );
         iPlusThree := get_map( SUBSTR( s, i + 3, 1) );

         --when the last two bytes equal '='
         IF( iPlusTwo = 64 ) THEN
            x := iTh * 64 + iPlusOne;
            x := floor(x/16);
            v := v || fnd_global.local_chr( x );

         --when the last byte equals '='
         ELSIF( iPlusThree = 64 ) THEN
            x := iTh * 4096 + iPlusOne * 64 + iPlusTwo;
            y := floor(x/1024);
            v := v || fnd_global.local_chr( y );
            x := x - y * 1024;
            x := floor(x/4);
            v := v || fnd_global.local_chr( x );

         --when all the bytes hold values to be converted.
         ELSE
            x := iTh * 262144 + iPlusOne * 4096 + iPlusTwo * 64 + iPlusThree;
            y := floor(x/65536);
            v := v || fnd_global.local_chr( y );
            x := x - y * 65536;
            y := floor(x/256);
            v := v || fnd_global.local_chr( y );
            x := x - y * 256;
            v := v || fnd_global.local_chr( x );
         END IF;
         i := i + 4;
      END LOOP;

      RETURN v;

  END decode64;

  --
  --
  FUNCTION get_local_nls
  RETURN VARCHAR2
  IS
  BEGIN

    return userenv('LANGUAGE');

  EXCEPTION WHEN others THEN
    return NULL;
  END get_local_nls;

  --
  --
  FUNCTION get_nls_charset( p_nls VARCHAR2 )
  RETURN VARCHAR2
  IS
    l_charset_index INTEGER;

    -- charset value seperator in NLSLang parameters
    --
    c_charset_seperator CONSTANT VARCHAR2(1) := '.';
  BEGIN

  IF (p_nls IS NULL) THEN
    return null;
  END IF;

  l_charset_index := INSTR(p_nls,c_charset_seperator);

  IF ( l_charset_index > 0 ) THEN
    return SUBSTR(p_nls,l_charset_index+1);
  ELSE
    return NULL;
  END IF;

  END get_nls_charset;


/* ========================================================================
-- Function Name:   MAKE_ASCII
--
-- Purpose:         Function to convert a string with possibly
--                  non-ASCII characters to ASCII. Internally, this
--                  function calls the SQL CONVERT function.
--
--                  The usage of this function will be to
--                  substitute certain 8-bit chars in European
--                  languages by their closest ASCII (7-bit)
--                  equivalent.
--
--                  Example:
--                  {a with various accent marks}  -> a
--                  {e with various accent marks}  -> e
--                  and so on.
--
--                  Sometimes, no straightforward conversion is possible
--                  because there is no equivalent in ASCII for a
--                  particular character. In this case the SQL CONVERT
--                  function will substitute a '?' for that character.
--
--                  MAKE_ASCII("Senaj(o with two dots)ki") returns "Senajoki"
--                  MAKE_ASCII("Senaj(o with a slash)ki") returns "Senaj?ki"
--
-- Parameters:
-- IN               1) p_from_text  VARCHAR2
--                  The raw text which might contain accented
--                    or otherwise non-ASCII characters.
--
-- OUT              None
--
-- RETURN           VARCHAR2 - The converted text with only ASCII characters.
-- =======================================================================*/

 FUNCTION MAKE_ASCII(
              p_from_text IN VARCHAR2
 ) RETURN VARCHAR2 IS

 l_converted_text VARCHAR2(300);

 BEGIN

     --
     -- Call the SQL CONVERT method to convert given string
     -- to US ASCII format.
     --
     -- See http://st-doc/8.0/817/server.817/a85397/function.htm#77039
     -- for CONVERT syntax
     --
     l_converted_text := convert(p_from_text, 'US7ASCII');

 RETURN l_converted_text;

 EXCEPTION
    WHEN OTHERS THEN
       RETURN p_from_text;

 END MAKE_ASCII;

FUNCTION get_call_exec
(
p_pkg_name VARCHAR2,
p_function_name VARCHAR2,
p_params JTF_VARCHAR2_TABLE_200
)
RETURN VARCHAR2
IS
  l_call VARCHAR2(3000);
  l_bind_counter NUMBER := 1;
BEGIN

  l_call :='CALL '|| p_pkg_name || '.' || p_function_name || '(';

  FOR i IN p_params.FIRST..p_params.LAST LOOP
    IF (NOT (i = p_params.FIRST)) THEN
      l_call := l_call || ',';
    END IF;

    IF (p_params(i) IS NULL) THEN
      l_call := l_call || ':' || TO_CHAR(l_bind_counter);
      l_bind_counter := l_bind_counter+1;
    ELSE
      l_call := l_call || p_params(i);
    END IF;
  END LOOP;

  l_call := l_call || ')';

  return l_call;
END get_call_exec;

PROCEDURE set_view_param
(
p_name iby_view_parameters_gt.name%TYPE,
p_val iby_view_parameters_gt.value%TYPE
)
IS
BEGIN

  INSERT INTO iby_view_parameters_gt
  (name,value,created_by,creation_date,last_updated_by,last_update_date,
   last_update_login,object_version_number)
  VALUES
  (p_name,p_val,fnd_global.user_id,sysdate,fnd_global.user_id,
  sysdate,fnd_global.login_id,1);

  -- no commit, as data deleted at the end of the current
  -- transaction
END set_view_param;

FUNCTION get_view_param( p_name iby_view_parameters_gt.name%TYPE )
RETURN iby_view_parameters_gt.value%TYPE
IS
  l_val iby_view_parameters_gt.value%TYPE;

  CURSOR c_param_val
  (ci_name iby_view_parameters_gt.name%TYPE)
  IS
  SELECT value
  FROM iby_view_parameters_gt
  WHERE (name=ci_name);

BEGIN

  IF (c_param_val%ISOPEN) THEN
    CLOSE c_param_val;
  END IF;

  OPEN c_param_val(p_name);
  FETCH c_param_val INTO l_val;

  IF (c_param_val%NOTFOUND) THEN
    l_val := NULL;
  END IF;
  CLOSE c_param_val;

  RETURN l_val;

END get_view_param;

FUNCTION check_lookup_val( p_val IN VARCHAR2, p_lookup IN VARCHAR2 )
RETURN BOOLEAN
IS
  l_count  NUMBER;
BEGIN

  SELECT count(lookup_code)
  INTO l_count
  FROM fnd_lookups
  WHERE (lookup_type = p_lookup)
    AND (lookup_code = p_val)
    AND (enabled_flag = 'Y')
    AND (NVL(end_date_active,SYSDATE-10) < SYSDATE);

  IF (l_count<1) THEN
    RETURN false;
  ELSE
    RETURN true;
  END IF;

END check_lookup_val;

FUNCTION validate_party_id(p_party_id IN hz_parties.party_id%TYPE)
RETURN BOOLEAN
IS
  l_count  NUMBER;

  CURSOR c_party(ci_party_id IN hz_parties.party_id%TYPE)
  IS
    SELECT COUNT(party_id)
    INTO l_count
    FROM hz_parties
    WHERE party_id = ci_party_id;
BEGIN
  IF (c_party%ISOPEN) THEN CLOSE c_party; END IF;

  OPEN c_party(p_party_id);
  FETCH c_party INTO l_count;
  CLOSE c_party;

  RETURN (l_count>0);
END validate_party_id;

FUNCTION validate_app_id(p_app_id IN fnd_application.application_id%TYPE)
RETURN BOOLEAN
IS
  l_count NUMBER;

  CURSOR c_app(ci_app_id IN fnd_application.application_id%TYPE)
  IS
    SELECT count(*)
    FROM fnd_application
    WHERE (application_id = ci_app_id);

BEGIN
  IF (c_app%ISOPEN) THEN CLOSE c_app; END IF;

  OPEN c_app(p_app_id);
  FETCH c_app INTO l_count;
  CLOSE c_app;

  IF (l_count<1) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END validate_app_id;


FUNCTION validate_territory
( p_territory IN fnd_territories.territory_code%TYPE )
RETURN BOOLEAN
IS

  l_territory   fnd_territories.territory_code%TYPE;

  CURSOR c_terr( ci_code IN fnd_territories.territory_code%TYPE )
  IS
    SELECT territory_code
    FROM fnd_territories
    WHERE (territory_code = ci_code)
    AND (NVL(obsolete_flag,'N') = 'N');

BEGIN
  IF (c_terr%ISOPEN) THEN CLOSE c_terr; END IF;

  OPEN c_terr(p_territory);
  FETCH c_terr INTO l_territory;
  CLOSE c_terr;

  RETURN (NOT l_territory IS NULL);
END validate_territory;


FUNCTION is_trivial(p_string VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
  IF (p_string IS NULL) THEN RETURN TRUE;
  ELSIF (RTRIM(LTRIM(p_string)) IS NULL) THEN RETURN TRUE;
  ELSE RETURN FALSE; END IF;
END is_trivial;

FUNCTION validate_organization(p_org_id   IN iby_trxn_summaries_all.org_id%TYPE,
                               p_org_type IN iby_trxn_summaries_all.org_type%TYPE)
RETURN VARCHAR2
IS

  l_org_id       NUMBER;
  l_return_value VARCHAR2(1) := 'N';

BEGIN

  BEGIN
    SELECT organization_id
      INTO l_org_id
      FROM hr_operating_units
     WHERE organization_id = p_org_id;

  EXCEPTION
    WHEN no_data_found THEN
      l_org_id := NULL;

  END;

  IF (l_org_id IS NOT NULL) THEN
    l_return_value := 'Y';
  END IF;

  RETURN l_return_value;

END validate_organization;


PROCEDURE validate_pmt_channel_code(p_instrument_type IN iby_creditcard.instrument_type%TYPE,
                                    p_payment_channel_code IN OUT NOCOPY iby_trxn_summaries_all.payment_channel_code%TYPE,
                                    p_valid OUT NOCOPY VARCHAR2)
IS
  l_payment_channel_code iby_trxn_summaries_all.payment_channel_code%TYPE;
  l_return_value VARCHAR2(1) := 'N';

BEGIN

  BEGIN
    SELECT payment_channel_code
      INTO l_payment_channel_code
      FROM iby_fndcpt_pmt_chnnls_b
     WHERE instrument_type = p_instrument_type
       AND (payment_channel_code = p_payment_channel_code
            OR p_payment_channel_code is null);

  EXCEPTION
    WHEN no_data_found THEN
      l_payment_channel_code := NULL;

    WHEN too_many_rows THEN
      IF (p_instrument_type = 'BANKACCOUNT') THEN
        l_payment_channel_code := 'BANK_ACCT_XFER';

      ELSIF (p_instrument_type = 'MANUAL') THEN
        l_payment_channel_code := 'CHECK';

      ELSE
        l_payment_channel_code := NULL;
      END IF;

  END;

  IF (l_payment_channel_code IS NOT NULL AND
      l_payment_channel_code = NVL(p_payment_channel_code, l_payment_channel_code)) THEN
    l_return_value := 'Y';
  END IF;

  p_payment_channel_code := l_payment_channel_code;
  p_valid := l_return_value;

END validate_pmt_channel_code;

-- This function is moved from appayutb.pls to provide the count of requests in 'Processing', 'Terminated' in Payments Dashboard.
FUNCTION get_psr_snapshot_count(p_snapshot_code      IN     VARCHAR2)
RETURN NUMBER IS

l_status_code         FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;

l_ret_val             NUMBER;
l_count1              NUMBER;
l_count2              NUMBER;
l_count3              NUMBER;
l_count4              NUMBER;
BEGIN
 IF(g_psr_snapshot_table.EXISTS(p_snapshot_code) AND g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count IS NOT NULL) THEN
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'IBY_UTILITY_PVT.get_psr_snapshot_count :Getting from the cache',
			      debug_level => FND_LOG.LEVEL_STATEMENT,
			      module => 'IBY_UTILITY_PVT.get_psr_snapshot_count');
                     END IF;
     l_ret_val:= g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count;
 ELSE
    IF (p_snapshot_code = 'NEED_ACTION_BY_ME') THEN

            SELECT
                count(*)
                INTO l_count1
            FROM iby_pay_service_requests iby
            WHERE iby.calling_app_id = 200
                AND iby.process_type = 'STANDARD'
                AND
                ( iby.payment_service_request_status IN (
                                    'INFORMATION_REQUIRED',
                                    'PENDING_REVIEW_DOC_VAL_ERRORS',
                                    'PENDING_REVIEW_PMT_VAL_ERRORS',
                                    'PENDING_REVIEW')
                    OR
                    (
                        iby.payment_service_request_status = 'PAYMENTS_CREATED'
                        AND EXISTS
                        (
                          select  'NEED_ACTION_BY_ME'
                          from iby_payments_all pmt, iby_pay_instructions_all instr
                          where iby.payment_service_request_id = pmt.payment_service_request_id
                           and instr.payment_instruction_id = pmt.payment_instruction_id
                           and (instr.payment_instruction_status IN ('CREATION_ERROR',
                                                         'FORMATTED_READY_TO_TRANSMIT',
                                                         'TRANSMISSION_FAILED',
                                                         'FORMATTED_READY_FOR_PRINTING',
                                                         'SUBMITTED_FOR_PRINTING',
                                                         'CREATED_READY_FOR_PRINTING',
                                                         'CREATED_READY_FOR_FORMATTING',
                                                         'FORMATTED',
                                                         'CREATED')
			   or (instr.payment_instruction_status = 'TRANSMITTED' and IBY_FD_USER_API_PUB.Is_transmitted_Pmt_Inst_Compl(instr.PAYMENT_INSTRUCTION_ID) = 'N'))
                           and check_user_access(instr.payment_instruction_id) = 'Y'
                        )
                    )
                );



           SELECT count(*)
             INTO l_count2
             FROM ap_inv_selection_criteria_all ap
            WHERE ap.status  IN ('REVIEW', 'MISSING RATES' )
              AND NOT EXISTS ( SELECT 'NEED_ACTION_BY_ME'
                          FROM iby_pay_service_requests iby
                         WHERE iby.calling_app_id  = 200
                           AND iby.call_app_pay_service_req_code =
                                                     ap.checkrun_name);


            l_ret_val :=   l_count1 + l_count2;
	    g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count := l_ret_val;

     ELSIF p_snapshot_code = 'PROCESSING' THEN
       /*Modified the query for the Bug 7560766
       Added a condition to identify the PPRs which
       are waiting for the user action*/
            SELECT
                 count(*)
                INTO l_count1
            FROM iby_pay_service_requests iby
            WHERE iby.calling_app_id = 200
                AND iby.process_type = 'STANDARD'
                AND
                (
                    iby.payment_service_request_status IN ('INSERTED', 'SUBMITTED',
                                                           'ASSIGNMENT_COMPLETE',
                                                           'DOCUMENTS_VALIDATED',
                                                           'RETRY_DOCUMENT_VALIDATION',
                                                           'RETRY_PAYMENT_CREATION')
                    OR
                    (
                        iby.payment_service_request_status IN ('PAYMENTS_CREATED')
                        AND EXISTS
                        (SELECT 'PROCESSING'
                         FROM iby_payments_all pmt
                         WHERE
                        pmt.payment_service_request_id = iby.payment_service_request_id
                        AND pmt.payment_status NOT IN('REMOVED',    'VOID',    'VOID_BY_SETUP',    'VOID_BY_OVERFLOW',    'REMOVED_PAYMENT_STOPPED',
                        'REMOVED_DOCUMENT_SPOILED',    'REMOVED_INSTRUCTION_TERMINATED',    'REMOVED_REQUEST_TERMINATED', 'ISSUED', 'TRANSMITTED',  'REJECTED',
			'FAILED_VALIDATION', 'FAILED_BY_CALLING_APP', 'FAILED_BY_REJECTION_LEVEL')
                        AND pmt.payments_complete_flag <> 'Y'
                        AND NOT EXISTS
                        (SELECT 'NEED_ACTION'
                         FROM iby_pay_instructions_all inst
                         WHERE pmt.payment_instruction_id = inst.payment_instruction_id
                         AND inst.payment_instruction_status IN('CREATION_ERROR',
                                                                'FORMATTED_READY_TO_TRANSMIT',
                                                                'TRANSMISSION_FAILED',
                                                                'FORMATTED_READY_FOR_PRINTING',
                                                                'SUBMITTED_FOR_PRINTING',
                                                                'CREATED_READY_FOR_PRINTING',
                                                                'CREATED_READY_FOR_FORMATTING',
                                                                'FORMATTED',
                                                                'CREATED',
                                                                'FORMATTED_ELECTRONIC'))
                         )
                    )
                );


           SELECT count(*)
             INTO l_count2
             FROM ap_inv_selection_criteria_all ap
            WHERE ap.status  IN ('UNSTARTED', 'SELECTING', 'CANCELING',
                                 'CALCULATING', 'SELECTED')
              AND NOT EXISTS ( SELECT 'PROCESSING'
                          FROM iby_pay_service_requests iby
                         WHERE iby.calling_app_id  = 200
                           AND iby.call_app_pay_service_req_code =
                                                     ap.checkrun_name);

            l_ret_val :=   l_count1 + l_count2;
	    g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count := l_ret_val;

    ELSIF p_snapshot_code = 'USER_TERMINATED' THEN
      SELECT count(*)
         INTO l_count1
         FROM ap_inv_selection_criteria_all ap
        WHERE EXISTS ( SELECT 'IBY USER_TERMINATED'
                         FROM iby_pay_service_requests iby
                        WHERE iby.calling_app_id  = 200
                          AND iby.call_app_pay_service_req_code =
                                                        ap.checkrun_name
                          AND iby.payment_service_request_status  IN
                                                     ('TERMINATED'))
         AND  ap.creation_date BETWEEN TRUNC(SYSDATE)  AND (TRUNC(SYSDATE) + 0.99999);

        SELECT count(*)
             INTO l_count2
             FROM ap_inv_selection_criteria_all ap
            WHERE ap.status  IN ('CANCELED', 'CANCELLED NO PAYMENTS')
              AND TRUNC(ap.creation_date) =TRUNC(sysdate)
              AND NOT EXISTS ( SELECT 'AP USER_TERMINATED'
                          FROM iby_pay_service_requests iby
                         WHERE iby.calling_app_id  = 200
                           AND iby.call_app_pay_service_req_code =
                                                     ap.checkrun_name)
             AND  ap.creation_date BETWEEN TRUNC(SYSDATE)  AND (TRUNC(SYSDATE) + 0.99999);

       l_ret_val :=   l_count1 + l_count2;
       g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count := l_ret_val;

     ELSIF p_snapshot_code = 'PROGRAM_ERRORS' THEN

       SELECT count(*)
         INTO l_count1
        FROM  ap_inv_selection_criteria_all ap
        WHERE EXISTS ( SELECT 'PROGRAM ERRORS'
                         FROM iby_pay_service_requests iby
                        WHERE iby.calling_app_id  = 200
                          AND iby.call_app_pay_service_req_code =
                                                   ap.checkrun_name
                          AND iby.payment_service_request_status  IN
                                        ('PENDING_REVIEW_DOC_VAL_ERRORS',
                                         'PENDING_REVIEW_PMT_VAL_ERRORS'))
         AND  ap.creation_date BETWEEN TRUNC(SYSDATE)  AND (TRUNC(SYSDATE) + 0.99999);

         l_ret_val :=   l_count1;
	 g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count := l_ret_val;

    ELSIF p_snapshot_code = 'COMPLETED' THEN

       SELECT count(*)
         INTO l_count1
        FROM  ap_inv_selection_criteria_all ap
        WHERE EXISTS ( SELECT 'COMPLETED'
                         FROM iby_pay_service_requests iby
                        WHERE iby.calling_app_id  = 200
                          AND iby.call_app_pay_service_req_code =
                                                      ap.checkrun_name
                          AND iby.payment_service_request_status  IN
                                                     ('PAYMENTS_CREATED','COMPLETED')
                          AND AP_PAYMENT_UTIL_PKG.get_payment_status_flag(iby.payment_service_request_id) = 'Y')
         AND  ap.creation_date BETWEEN TRUNC(SYSDATE)  AND (TRUNC(SYSDATE) + 0.99999);

       l_ret_val :=   l_count1;
       g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count := l_ret_val;

    ELSIF p_snapshot_code = 'TOTAL' THEN

      -- The total value is calculated in the UI
      NULL;

    END IF;
  END IF;
    RETURN l_ret_val;

END;

-- This function is moved from appayutb.pls to provide the count of requests in 'Processing', 'Terminated' in Payments Dashboard.
/* Bug Number: 7279395
 * Caching is implemented based on the psr id. Hence pages or procedures
 * which are accessing this function should take the responsibility to
 * initialize g_psr_table by calling the initialize procedure
 *
 *Bug 8883966: Added new input parameter p_from_cache.
 */
FUNCTION get_payment_status_flag(p_psr_id      IN         NUMBER,
                                 p_from_cache  IN         VARCHAR2 DEFAULT 'FALSE')
RETURN VARCHAR2 IS

l_payment_status_flag  VARCHAR2(1);
l_total_pmt_count      NUMBER;
l_pmt_complete_count   NUMBER;


BEGIN

   IF ( p_psr_id  IS NOT NULL ) THEN

         IF(g_psr_table.EXISTS(p_psr_id) AND g_psr_table(p_psr_id).payment_status_flag IS NOT NULL
	    AND p_from_cache = 'TRUE') THEN
	             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'IBY_UTILITY_PVT.get_payment_status_flag :Getting from the cache',
			      debug_level => FND_LOG.LEVEL_STATEMENT,
			      module => 'IBY_UTILITY_PVT.get_payment_status_flag');
                     END IF;
             l_payment_status_flag:= g_psr_table(p_psr_id).payment_status_flag;
         ELSE

              /*Bug 7248943*/
              select  count (*) total_pmt_count,
              count(case when PAYMENTS_COMPLETE_FLAG = 'Y'  then 1 else null
                 end) pmt_complete_count
	     into l_total_pmt_count, l_pmt_complete_count  /*Bug 7248943*/
	     FROM iby_payments_all
             WHERE payment_service_request_id = p_psr_id
             AND payment_status NOT IN ('REMOVED', 'VOID_BY_SETUP',
                                   'VOID_BY_OVERFLOW', 'REMOVED_PAYMENT_STOPPED',
                                   'REMOVED_DOCUMENT_SPOILED',
                                   'REMOVED_INSTRUCTION_TERMINATED',
                                   'REMOVED_REQUEST_TERMINATED',
                                   'REJECTED', -- Bug 6897223- new statuses added
		                   'FAILED_BY_CALLING_APP',
		 	           'FAILED_BY_REJECTION_LEVEL',
				   'FAILED_VALIDATION',
		                   'INSTRUCTION_FAILED_VALIDATION'); --Bug 6686639

	   IF  l_total_pmt_count > 0  THEN
	   --
            /*Removed query for Bug 7248943*/

	     IF ( l_total_pmt_count =  l_pmt_complete_count) THEN
	        l_payment_status_flag := 'Y';
		g_psr_table(p_psr_id).payment_status_flag := l_payment_status_flag;
	     ELSIF ((l_total_pmt_count > l_pmt_complete_count) AND
	              (l_pmt_complete_count <> 0))THEN
	        l_payment_status_flag := 'P';
		g_psr_table(p_psr_id).payment_status_flag := l_payment_status_flag;
	     ELSIF ((l_total_pmt_count > l_pmt_complete_count) AND
	              (l_pmt_complete_count = 0)) THEN
	            l_payment_status_flag := 'N';
		    g_psr_table(p_psr_id).payment_status_flag := l_payment_status_flag;
	     END IF;
	   --
	   ELSE
	   --

	     l_payment_status_flag := 'N';
	     g_psr_table(p_psr_id).payment_status_flag := l_payment_status_flag;

	   END IF;
	END IF;
   ELSE
      l_payment_status_flag := 'N';

   END IF;


   RETURN l_payment_status_flag;

END get_payment_status_flag;

-- This function is moved from appayutb.pls to provide the count of requests in 'Processing', 'Terminated' in Payments Dashboard.
/* Bug Number: 7279395
 * Caching is implemented based on the psr id. Hence pages or procedures
 * which are accessing this function should take the responsibility to
 * initialize g_psr_table by calling the initialize procedure
 *
 * Bug 8883966: Added new input parameter p_from_cache.
 */
FUNCTION get_psr_status(p_psr_id      IN   NUMBER,
                        p_psr_status  IN   VARCHAR2,
			p_from_cache  IN         VARCHAR2 DEFAULT 'FALSE')
RETURN VARCHAR2 IS

l_psr_status          VARCHAR2(30);
l_total_pmt_count     NUMBER;
l_instr_count         NUMBER;
l_pmt_terminate_count NUMBER;
l_pmt_spoil_skip      NUMBER;
l_valid_completed_pmt NUMBER;

BEGIN
     IF(g_psr_table.EXISTS(p_psr_id) AND g_psr_table(p_psr_id).psr_status IS NOT NULL
        AND p_from_cache = 'TRUE') THEN
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'IBY_UTILITY_PVT.get_psr_status :Getting from the cache',
			      debug_level => FND_LOG.LEVEL_STATEMENT,
			      module => 'IBY_UTILITY_PVT.get_psr_status');
         END IF;
         l_psr_status:= g_psr_table(p_psr_id).psr_status;
     ELSE

       IF p_psr_status <> 'PAYMENTS_CREATED' AND p_psr_status <> 'COMPLETED' THEN

         IF p_psr_status IN ('INSERTED', 'SUBMITTED',
                             'ASSIGNMENT_COMPLETE',
                              'DOCUMENTS_VALIDATED',
                              'RETRY_DOCUMENT_VALIDATION',
                              'RETRY_PAYMENT_CREATION') THEN

              l_psr_status := 'BUILDING';
	      g_psr_table(p_psr_id).psr_status := l_psr_status;
              RETURN l_psr_status;
         --
         END IF;
         --
         RETURN p_psr_status;
       ELSIF p_psr_status = 'COMPLETED'  THEN
          BEGIN
		  select 1
		  into l_valid_completed_pmt
		  from dual
		  where exists(select 'VALID_PAYMENT'
		  from iby_payments_all
		  where payment_service_request_id = p_psr_id
		  and payments_complete_flag = 'Y'
		  and payment_status in ('INSTRUCTION_CREATED', 'ISSUED', 'FORMATTED', 'TRANSMITTED'));

		   l_psr_status := 'CONFIRMED';
	 EXCEPTION
	   WHEN no_data_found then
             l_psr_status := 'TERMINATED';
	 END;

          RETURN l_psr_status;
       END IF;

         /*Bug 7248943*/
         select  count (*) total_pmt_count,
                 count(case when payment_instruction_id IS NOT NULL then 1
                                            else null end) instr_count,
                 count(case when PAYMENT_STATUS IN ('REMOVED_INSTRUCTION_TERMINATED',
                                                    'REMOVED_REQUEST_TERMINATED',
						    'VOID',
				                    'REMOVED',
		                                    'REMOVED_PAYMENT_STOPPED',
		                                    'VOID_BY_SETUP',
		                                    'VOID_BY_OVERFLOW',
		                                    'REMOVED_DOCUMENT_SPOILED',
		                                    'REJECTED',
						    'FAILED_BY_CALLING_APP',
		                                    'FAILED_BY_REJECTION_LEVEL',
		                                    'FAILED_VALIDATION',
		                                    'INSTRUCTION_FAILED_VALIDATION') then 1
					    else null end) pmt_terminate_count,
                 count(case when PAYMENT_STATUS IN ('REMOVED_DOCUMENT_SPOILED',
	                                            'REMOVED_DOCUMENT_SKIPPED') then 1
                                            else null end) pmt_spoil_skip
         into l_total_pmt_count, l_instr_count, l_pmt_terminate_count, l_pmt_spoil_skip
         from iby_payments_all
         WHERE payment_service_request_id = p_psr_id ;
         /*Bug 7248943*/

        IF  (l_instr_count = 0 AND p_psr_status = 'PAYMENTS_CREATED') THEN

         l_psr_status := 'BUILT';
	 g_psr_table(p_psr_id).psr_status := l_psr_status;
         RETURN l_psr_status;

        END IF;


	if (l_pmt_spoil_skip > 0) THEN

        	l_psr_status := 'CONFIRMED';
		g_psr_table(p_psr_id).psr_status := l_psr_status;
	ELSE


		   IF  l_total_pmt_count > 0  THEN
		   --

		     IF ( l_total_pmt_count =  l_pmt_terminate_count) THEN
			l_psr_status := 'TERMINATED';
			g_psr_table(p_psr_id).psr_status := l_psr_status;
		     ELSIF get_payment_status_flag(p_psr_id, p_from_cache) = 'Y' THEN
			l_psr_status := 'CONFIRMED';
			g_psr_table(p_psr_id).psr_status := l_psr_status;
		     ELSE
			l_psr_status := 'FORMATTING';
			g_psr_table(p_psr_id).psr_status := l_psr_status;
		     END IF;
		   ELSE
		       l_psr_status := p_psr_status;
		       g_psr_table(p_psr_id).psr_status := l_psr_status;

		   END IF;
	END IF;

      END IF;

   RETURN l_psr_status;

END get_psr_status;

/* Bug Number: 7279395
 * This procedure is used to initialize the table type variable
 * g_psr_table.
 * The pages which are accessing the functions get_psr_status and
 * get_payment_status_flag should take the responsibility of initializing
 * g_psr_table by calling this procedure.
 */
PROCEDURE initialize
IS
BEGIN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER: '  || 'IBY_UTILITY_PVT.initialize',
			      debug_level => FND_LOG.LEVEL_STATEMENT,
			      module => 'IBY_UTILITY_PVT.initialize');
    END IF;
   g_psr_table.DELETE;
   g_psr_snapshot_table.DELETE;
   g_instr_access_table.DELETE;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || 'IBY_UTILITY_PVT.initialize',
			      debug_level => FND_LOG.LEVEL_STATEMENT,
			      module => 'IBY_UTILITY_PVT.initialize');
    END IF;
END initialize;


Function check_user_access(p_pay_instruction_id IN Number) RETURN VARCHAR2 IS
l_access varchar2(1) := 'Y';
BEGIN
    IF(g_instr_access_table.EXISTS(p_pay_instruction_id) AND g_instr_access_table(p_pay_instruction_id).access_flag IS NOT NULL)
    THEN
       l_access := g_instr_access_table(p_pay_instruction_id).access_flag;
    ELSE
          begin
          select 'N' into l_access from dual where exists ( select 'Inaccessible org' from iby_payments_all where
          payment_instruction_id = p_pay_instruction_id and   MO_GLOBAL.CHECK_ACCESS(org_id) = 'N');

          Exception
                  when NO_DATA_FOUND
                  then
                  l_access := 'Y';
          end;
              g_instr_access_table(p_pay_instruction_id).access_flag := l_access;
    END IF;
return l_access;
END check_user_access;



FUNCTION get_format_program_name(p_pay_instruction_id IN NUMBER) RETURN VARCHAR2 IS

l_conc_prog varchar2(100);

BEGIN

SELECT  decode(decode(template_type_code,
        'RTF','PDF',
        'ETEXT','ETEXT',
        'XSL-XML','XML',
        'PDF','PDF'),'PDF', 'IBY_FD_PAYMENT_FORMAT','IBY_FD_PAYMENT_FORMAT_TEXT')
            into
         l_conc_prog
	FROM iby_pay_instructions_all ins,
	     iby_payment_profiles pp,
	     iby_formats_b format,
	     XDO_TEMPLATES_B temp
	 WHERE ins.payment_instruction_id  = p_pay_instruction_id
	 AND ins.payment_profile_id        = pp.payment_profile_id
	 AND format.FORMAT_CODE            = pp.PAYMENT_FORMAT_CODE
	 AND format.FORMAT_TEMPLATE_CODE   = temp.template_code;


return l_conc_prog;

END get_format_program_name;

/*-----------------------------------------------------------------------------------------
 |  FUNCTION     - get_psr_snapshot_count PIPELINED.
 |
 |
 |  DESCRIPTION  - This function is designed for the Payables Payment Manager
 |                 Home Page . The function returns the total count of Payment
 |                 Process Requests with a particular Status or a combination
 |                 of Payment Process Request Statuses that map to a particular
 |                 snapshot code
 |
 |   SNAPSHOT CODE           STATUS
 |   -------------           ------------------------------------------------
 |   NEED_ACTION_BY_ME       AP:
 |                             'REVIEW', 'MISSING RATES'
 |                            IBY:
 |                              'INFORMATION_REQUIRED'
 |                              'PENDING_REVIEW_DOC_VAL_ERRORS',
 |                              'PENDING_REVIEW_PMT_VAL_ERRORS',
 |                              'PENDING_REVIEW'
 |
 |   PROCESSING              AP:
 |                             'UNSTARTED', 'SELECTING', 'CANCELING',
 |                             'CALCULATING', 'SELECTED'
 |                           IBY:
 |                             'INSERTED', 'SUBMITTED',
 |                             'ASSIGNMENT_COMPLETE','DOCUMENTS_VALIDATED',
 |                             'RETRY_DOCUMENT_VALIDATION',
 |                             'RETRY_PAYMENT_CREATION'
 |
 |   USER_TERMINATED         AP:
 |                             'CANCELED' , 'CANCELLED NO PAYMENTS'
 |                           IBY:
 |                             'TERMINATED'
 |
 |   PROGRAM_ERRORS          IBY:
 |                             'PENDING_REVIEW_DOC_VAL_ERRORS'
 |                             'PENDING_REVIEW_PMT_VAL_ERRORS'
 |
 |   COMPLETED               IBY:
 |                           'PAYMENTS_CREATED'
 |
 |   TOTAL                   COUNT(*) IN AP
 |
 |===========================================================================================
 |Understanding PIPELINED FUNCTION:
 |-----------------------------------
 |PIPELINED functions are piece of code that can be used for querying SQL.
 |Basically, when you would like a PLSQL routine to be the source
 |of data -- instead of a table -- you would use a pipelined function.
 |PIPELINED functions will operate like a table.
 |Using PL/SQL table functions can significantly lower the over-head of
 |doing such transformations. PL/SQL table functions accept and return
 |multiple rows, delivering them as they are ready rather than all at once,
 |and can be made to execute as parallel operations.
 |
  -----------------------------------------------------------------------------------------
 */

 FUNCTION get_psr_snapshot_pipe RETURN snapshot_count_t PIPELINED
  IS

    p_snapshot_code VARCHAR2(100) := 'Test';
    l_ret_val snapshot_count_type;
    l_status_code FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;
    --l_ret_val NUMBER;
    l_count1  NUMBER;
    l_count2  NUMBER;
    l_count3  NUMBER;
    l_count4  NUMBER;
    -- Variables for count
    l_need_action     NUMBER;
    l_processing      NUMBER;
    l_terminated NUMBER;
    l_errors          NUMBER;
    l_completed       NUMBER;
    l_process_count   NUMBER;
    l_access      VARCHAR2(1);
    --Loop For every ppr
    CURSOR c_psr_snapshot
    IS
      SELECT ipsr.payment_service_request_id ,
        ipsr.payment_service_request_status ,
        aisc.status ,
        aisc.checkrun_id ,
        aisc.checkrun_name ,
        aisc.creation_date
      FROM iby_pay_service_requests ipsr ,
        ap_inv_selection_criteria_all aisc
      WHERE ipsr.call_app_pay_service_req_code(+) = aisc.checkrun_name;
      --AND process_type                            = 'STANDARD' ;
  BEGIN
    IF(g_psr_snapshot_table.EXISTS(p_snapshot_code) AND g_psr_snapshot_table(p_snapshot_code).psr_snapshot_count IS NOT NULL) THEN

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        iby_debug_pub.add(debug_msg => 'IBY_UTILITY_PVT.get_psr_snapshot_count :Getting from the cache', debug_level => FND_LOG.LEVEL_STATEMENT, module => 'IBY_UTILITY_PVT.get_psr_snapshot_count');
        END IF ;
      ELSE
        -- Initialize the variables.
        l_need_action     :=0;
        l_processing      :=0;
        l_terminated :=0;
        l_errors          :=0;
        l_completed       :=0;
        FOR c_rec_snap IN c_psr_snapshot
        LOOP

          /* IBY NEED ACTION */
          --Handling everything with iby_pay_service_requests first.
          --For IBY_PAY_SERVICE_REQUESTS.
          IF c_rec_snap.payment_service_request_status IN ('INFORMATION_REQUIRED' , 'PENDING_REVIEW_DOC_VAL_ERRORS','PENDING_REVIEW_PMT_VAL_ERRORS', 'PENDING_REVIEW') THEN
            l_need_action := l_need_action + 1;
            --For records in ap_inv_selection_criteria_all but not in iby_pay_service_request. For PPR which are still before build.
          ELSIF c_rec_snap.payment_service_request_status IS NULL AND c_rec_snap.status IN ('REVIEW', 'MISSING RATES' ) THEN
            l_need_action := l_need_action + 1;
            /* IBY NEED ACTION */
            /* IBY IN PROCESS. */
          ELSIF c_rec_snap.payment_service_request_status IN ('INSERTED', 'SUBMITTED','ASSIGNMENT_COMPLETE','DOCUMENTS_VALIDATED','RETRY_DOCUMENT_VALIDATION','RETRY_PAYMENT_CREATION') THEN
            l_processing := l_processing + 1;
          ELSIF c_rec_snap.payment_service_request_status IS NULL AND c_rec_snap.status IN ('UNSTARTED', 'SELECTING', 'CANCELING','CALCULATING', 'SELECTED') THEN
            l_processing := l_processing + 1;
            /* IBY IN PROCESS. */
            /* PAYMENTS_CREATED and it can be in either processing or need action group */
            --Special case Payment Created
          ELSIF c_rec_snap.payment_service_request_status IN ('PAYMENTS_CREATED') THEN
            -- Need to check the payment instruction and individual payments.
            l_access := 'N';
            --Check org access also verifies the Payment Instruction statuses that are valid.
            l_access := check_org_access(c_rec_snap.payment_service_request_id);
            IF l_access = 'Y'
              THEN
              l_need_action := l_need_action + 1;
            ELSE
              -- For Processing Action.
              BEGIN
                SELECT 'Y'
                INTO l_process_count
                FROM dual
                WHERE EXISTS
                  (SELECT 'PROCESSING'
                  FROM iby_payments_all pmt
                  WHERE pmt.payment_service_request_id =c_rec_snap.payment_service_request_id
                  AND pmt.payment_status NOT IN('REMOVED', 'VOID', 'VOID_BY_SETUP', 'VOID_BY_OVERFLOW', 'REMOVED_PAYMENT_STOPPED', 'REMOVED_DOCUMENT_SPOILED', 'REMOVED_INSTRUCTION_TERMINATED',
		                                'REMOVED_REQUEST_TERMINATED', 'ISSUED', 'TRANSMITTED', 'REJECTED')
                  AND pmt.payments_complete_flag      <> 'Y'
                  AND NOT EXISTS
                    (SELECT 'NEED_ACTION'
                    FROM iby_pay_instructions_all inst
                    WHERE pmt.payment_instruction_id = inst.payment_instruction_id
                    AND (inst.payment_instruction_status IN('CREATION_ERROR', 'FORMATTED_READY_TO_TRANSMIT', 'TRANSMISSION_FAILED', 'FORMATTED_READY_FOR_PRINTING', 'SUBMITTED_FOR_PRINTING',
		                              'CREATED_READY_FOR_PRINTING', 'CREATED_READY_FOR_FORMATTING', 'FORMATTED', 'CREATED', 'FORMATTED_ELECTRONIC')
			OR (inst.payment_instruction_status = 'TRANSMITTED' AND IBY_FD_USER_API_PUB.Is_transmitted_Pmt_Inst_Compl(inst.PAYMENT_INSTRUCTION_ID) = 'N'))
                    )
                  );
                -- If it comes here then it is in processing status
                l_processing := l_processing + 1;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL; -- Do Nothing.
              WHEN OTHERS THEN
                iby_debug_pub.add(debug_msg => 'IBY_UTILITY_PVT.get_psr_snapshot_count :Error in processing count', debug_level => FND_LOG.LEVEL_STATEMENT, module => 'IBY_UTILITY_PVT.get_psr_snapshot_count');
              END;
            END IF;
              /* PAYMENTS_CREATED and it can be in either processing or need action group */
              /* IBY Terminated */
            ELSIF c_rec_snap.payment_service_request_status IN ('TERMINATED') AND (c_rec_snap.creation_date BETWEEN TRUNC(SYSDATE) AND (TRUNC(SYSDATE) + 0.99999))THEN
              l_terminated := l_terminated + 1;
            ELSIF c_rec_snap.payment_service_request_status IS NULL AND (c_rec_snap.status IN('CANCELED', 'CANCELLED NO PAYMENTS'))
	               AND (c_rec_snap.creation_date BETWEEN TRUNC(SYSDATE) AND (TRUNC(SYSDATE) + 0.99999)) THEN
              l_terminated := l_terminated + 1;
              /* IBY Terminated */
              /* IBY Errors */
            ELSIF c_rec_snap.payment_service_request_status IN ('PENDING_REVIEW_DOC_VAL_ERRORS', 'PENDING_REVIEW_PMT_VAL_ERRORS') AND
	                     (c_rec_snap.creation_date BETWEEN TRUNC(SYSDATE) AND (TRUNC(SYSDATE) + 0.99999)) THEN
              l_errors := l_errors + 1;
              /* IBY Errors */
              /* IBY Completed */
            ELSIF c_rec_snap.payment_service_request_status IN ('PAYMENTS_CREATED','COMPLETED') AND
	           (c_rec_snap.creation_date BETWEEN TRUNC(SYSDATE) AND (TRUNC(SYSDATE) + 0.99999)) AND
		   (AP_PAYMENT_UTIL_PKG.get_payment_status_flag(c_rec_snap.payment_service_request_id) = 'Y') THEN
              l_completed := l_completed + 1;
              /* IBY Completed */
            END IF;
          END LOOP;

      END IF;
    --  dbms_output.put_line('Outputs:: Action::'||l_need_action ||' Processing::'||l_processing||' Terminated::'||l_terminated||' Errors::'||l_errors||' Completed::'|| l_completed);

    SELECT l_need_action,l_processing,l_terminated,l_errors,l_completed
    INTO l_ret_val
    FROM DUAL;
    --INSERTING INTO PIPE SO IT CAN BE QUERIED.
    PIPE ROW( l_ret_val);
    RETURN ;
    END get_psr_snapshot_pipe;

 FUNCTION check_org_access(
      p_payment_service_request_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_instr_id NUMBER;
    l_access   VARCHAR2(1);
    CURSOR c_org_access
    IS
      SELECT pmt_all.INSTR_ID,
        pmt_all.ORG_ID
      FROM
        (SELECT DISTINCT pmt.payment_instruction_id INSTR_ID,
          pmt.org_id ORG_ID
        FROM iby_payments_all pmt,
          iby_pay_instructions_all instr
        WHERE p_payment_service_request_id    = pmt.payment_service_request_id
        AND instr.payment_instruction_id      = pmt.payment_instruction_id
        AND (instr.payment_instruction_status IN ('CREATION_ERROR', 'FORMATTED_READY_TO_TRANSMIT', 'TRANSMISSION_FAILED', 'FORMATTED_READY_FOR_PRINTING',
	'SUBMITTED_FOR_PRINTING', 'CREATED_READY_FOR_PRINTING', 'CREATED_READY_FOR_FORMATTING', 'FORMATTED', 'CREATED')
	OR (instr.payment_instruction_status = 'TRANSMITTED' AND IBY_FD_USER_API_PUB.Is_transmitted_Pmt_Inst_Compl(instr.PAYMENT_INSTRUCTION_ID) = 'N'))
        ) pmt_all;
  BEGIN
    -- Initialize all variables.
    l_instr_id       := NULL;
    l_access         := 'N';
   FOR i_org_access IN c_org_access
    LOOP
      IF l_instr_id IS NOT NULL AND l_access = 'N' THEN
        RETURN 'N';
      END IF;
      l_access                                      := 'Y'; -- Initialize for new instruction
      l_instr_id                                    := i_org_access.INSTR_ID;
      IF MO_GLOBAL.check_access(i_org_access.ORG_ID) = 'N' THEN
        l_access                                    := 'N';
      END IF;
    END LOOP;

     -- Take care of the last instruction here.
      IF l_access = 'Y' THEN -- User has access to this last instruction, hence PPR
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
  END check_org_access;

END IBY_UTILITY_PVT;

/
