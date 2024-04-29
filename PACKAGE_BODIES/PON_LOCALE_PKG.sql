--------------------------------------------------------
--  DDL for Package Body PON_LOCALE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_LOCALE_PKG" as
/*$Header: PONLOCB.pls 120.5.12010000.2 2012/12/10 11:07:37 sgulkota ship $ */

/**
 * This procedure takes a first name and last name of a person.
 * It also takes in the desired name format and the party id of
 * the person who is receiving the email notification. It formats
 * the name according to the locale settings of the person receiving
 * the email.
 */

PROCEDURE retrieve_party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_mid_name       IN VARCHAR2
, p_prefix         IN  VARCHAR2
, p_suffix         IN  VARCHAR2
, p_party_id       IN NUMBER
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS
  l_first_name hz_parties.PERSON_FIRST_NAME%TYPE;
  l_last_name hz_parties.PERSON_LAST_NAME%TYPE;
  l_mid_name hz_parties.PERSON_MIDDLE_NAME%TYPE;
  l_prefix hz_parties.PERSON_TITLE%TYPE;
  l_suffix hz_parties.PERSON_NAME_SUFFIX%TYPE;
  l_prefix_space VARCHAR2(1);
  l_prefix_comma VARCHAR2(2);
  l_first_name_space VARCHAR2(1);
  l_suffix_space VARCHAR2(1);
  l_middle_name_space VARCHAR2(1);
  l_first_name_comma VARCHAR2(2);
  l_prefix_first_name_comma VARCHAR2(1);
BEGIN

      IF ( p_first_name is null or p_last_name is null) THEN
          IF (p_party_id is null) THEN
            x_display_name := '';
            x_exception_msg := 'Party Id can not be null if first name is missing';
            x_status := 'E';
          ELSE
           select person_first_name , person_last_name, person_title,
                person_name_suffix ,PERSON_MIDDLE_NAME
            into l_first_name, l_last_name, l_prefix, l_suffix, l_mid_name
           from hz_parties
            where party_id = p_party_id;
         END IF;
     ELSE
         l_first_name := p_firsT_name;
         l_last_name := p_last_name;
         l_mid_name := p_mid_name;
         l_suffix := p_suffix;
         l_prefix := p_prefix;
      END IF;

	SELECT nvl2(l_prefix,' ',''),
            nvl2(l_prefix,', ',''),
            nvl2(l_first_name, ' ',''),
            nvl2(l_suffix, ' ', ''),
            nvl2(l_mid_name, ' ',''),
            nvl2(l_first_name, ', ',''),
            nvl2(l_prefix,',', nvl2(l_first_name,',',''))
	INTO
          l_prefix_space,
          l_prefix_comma,
          l_first_name_space,
          l_suffix_space,
          l_middle_name_space,
          l_first_name_comma,
          l_prefix_first_name_comma

	FROM dual;

	-- Format the name according to the language preferences
        -- of the person receiving the email.
        IF (x_status = 'E') THEN
                x_display_name := '';
	ELSIF (p_language = 'JA' or p_language = 'ZHS' or p_language = 'ZHT' or p_language = 'KO') THEN
		-- Name is Japanese, Chinese, or Korean
		IF (p_name_format = NAME_LAST or  -- last name alone is not allowed here
		    p_name_format = NAME_LAST_FIRST or
		    p_name_format = NAME_FIRST_LAST or
		    p_name_format = NAME_F_M_L_SUFFIX or
		    p_name_format = NAME_FIRST_M_LAST) THEN
			x_display_name := l_last_name || l_first_name;

		ELSIF (p_name_format = NAME_TITLE_LAST_FIRST or
		       p_name_format = NAME_LAST_TITLE_FIRST or
              	       p_name_format = NAME_TITLE_FIRST_LAST or
                       p_name_format = NAME_TITLE_FIRST or
              	       p_name_format = NAME_PREFIX_F_M_L_SUFFIX) THEN
			x_display_name := l_last_name || l_first_name || l_prefix_space || l_prefix;

		ELSIF (p_name_format = NAME_TITLE_LAST) THEN
			x_display_name := l_last_name || l_prefix;
		ELSIF (p_name_format = NAME_FIRST) THEN
		   IF (p_language = 'JA' or p_language = 'ZHS') THEN
			x_display_name := l_last_name || l_first_name;
		   ELSE
			x_display_name := l_first_name;
		   END IF;

		END IF;

        ELSIF p_language = 'HU' THEN
                -- Name is Hungarian

                IF p_name_format = NAME_LAST THEN
                        x_display_name := l_last_name;
		ELSIF p_name_format = NAME_TITLE_LAST THEN
			x_display_name := l_prefix || l_prefix_space || l_last_name;
                ELSIF (p_name_format = NAME_TITLE_LAST_FIRST or
                       p_name_format = NAME_LAST_TITLE_FIRST or
		       p_name_format = NAME_TITLE_FIRST_LAST or
	               p_name_format = NAME_TITLE_FIRST) THEN
                        x_display_name := l_prefix || l_prefix_space || l_last_name || l_first_name_space || l_first_name;
		ELSIF p_name_format = NAME_F_M_L_SUFFIX THEN
			x_display_name := l_suffix || l_suffix_space || l_last_name || l_first_name_space || l_first_name || l_middle_name_space || l_mid_name;
		ELSIF p_name_format = NAME_FIRST_M_LAST THEN
			x_display_name := l_last_name || l_first_name_space || l_first_name || l_middle_name_space || l_mid_name;
		ELSIF p_name_format = NAME_PREFIX_F_M_L_SUFFIX THEN
			x_display_name := l_prefix || l_prefix_space ||l_suffix || l_suffix_space || l_last_name || l_first_name_space || l_first_name || l_middle_name_space || l_mid_name;
		ELSE
			x_display_name := l_last_name || l_first_name_space || l_first_name;
                END IF;

	ELSE
		-- Name is in other languages
		IF p_name_format = NAME_LAST_FIRST THEN
			x_display_name := l_last_name || l_first_name_comma || l_first_name;
		ELSIF p_name_format = NAME_FIRST_M_LAST THEN
			x_display_name := l_first_name || l_first_name_space || l_mid_name || l_middle_name_space || l_last_name;
		ELSIF p_name_format = NAME_TITLE_LAST_FIRST THEN
			x_display_name := l_prefix || l_prefix_space || l_last_name || l_first_name_comma || l_first_name;
	        ELSIF p_name_format = NAME_LAST_TITLE_FIRST THEN
		        x_display_name := l_last_name || ',' || l_prefix_space ||  l_prefix || l_first_name_space || l_first_name;
		ELSIF p_name_format = NAME_PREFIX_F_M_L_SUFFIX THEN
			x_display_name := l_prefix || l_prefix_space || l_first_name || l_first_name_space || l_mid_name || l_middle_name_space || l_last_name || l_suffix_space || l_suffix;
		ELSIF p_name_format = NAME_TITLE_FIRST_LAST THEN
			x_display_name := l_prefix || l_prefix_space || l_first_name || l_first_name_space || l_last_name;
		ELSIF p_name_format = NAME_TITLE_FIRST THEN
			x_display_name := l_prefix || l_prefix_space || l_first_name;
		ELSIF p_name_format = NAME_TITLE_LAST THEN
			x_display_name := l_prefix || l_prefix_space || l_last_name;
		ELSIF p_name_format = NAME_F_M_L_SUFFIX THEN
			x_display_name := l_first_name || l_first_name_space || l_mid_name || l_middle_name_space|| l_last_name || l_suffix_space || l_suffix;
		ELSIF p_name_format = NAME_FIRST THEN
			x_display_name := l_first_name;
		ELSIF p_name_format = NAME_LAST THEN
			x_display_name := l_last_name;
		ELSE
			x_display_name := l_first_name || l_first_name_space || l_last_name;
		END IF;
	END IF;
  x_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_status := 'E';
END retrieve_party_display_name;

PROCEDURE party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name   IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS
BEGIN
   retrieve_party_display_name (p_first_name,
				p_last_name,
				p_middle_name,
				p_prefix,
				p_suffix,
				null,
				p_name_format,
                                p_language,
				x_display_name,
				x_status,
				x_exception_msg);

END party_display_name;


PROCEDURE party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS
BEGIN

   party_display_name (p_first_name,
                       p_last_name,
			'',
			'',
                        '',
		        p_name_format,
                        p_language,
		        x_display_name,
			x_status,
			x_exception_msg);
END party_display_name;


/**
 * This procedure takes in the party id and returns the display name
 * according to the desired format and the persons locale preferences
 */

PROCEDURE retrieve_party_display_name (
  p_party_id       IN NUMBER
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS

  l_first_name hz_parties.PERSON_FIRST_NAME%TYPE;
  l_last_name hz_parties.PERSON_LAST_NAME%TYPE;
  l_mid_name hz_parties.PERSON_MIDDLE_NAME%TYPE;
  l_prefix hz_parties.PERSON_PRE_NAME_ADJUNCT%TYPE;
  l_suffix hz_parties.PERSON_NAME_SUFFIX%TYPE;

BEGIN

        -- Get the First Name and the Last Name
        select PERSON_FIRST_NAME, PERSON_LAST_NAME , PERSON_MIDDLE_NAME,PERSON_NAME_SUFFIX, FL.MEANING
        into l_first_name, l_last_name ,l_mid_name,l_suffix,l_prefix
        from hz_parties, fnd_lookup_values fl
	where PARTY_ID = p_party_id
	AND fl.lookup_type(+) = 'CONTACT_TITLE'
	AND fl.lookup_code(+) = person_pre_name_adjunct
        AND fl.view_application_id(+) = 222
        AND fl.security_group_id(+) = 0
	AND fl.language(+) = userenv('lang');

	retrieve_party_display_name(p_first_name  	=> l_first_name,
				    p_last_name		=> l_last_name,
				    p_mid_name 		=> l_mid_name,
				    p_prefix 		=> l_prefix,
				    p_suffix 		=> l_suffix,
				    p_party_id 		=> p_party_id,
				    p_name_format 	=> p_name_format,
                                    p_language          => p_language,
				    x_display_name 	=> x_display_name,
  				    x_status 		=> x_status,
				    x_exception_msg 	=> x_exception_msg);
EXCEPTION
  WHEN OTHERS THEN BEGIN
    x_status := 'E';
    x_exception_msg := 'exception in retreiving the name';
  END;
END retrieve_party_display_name;

FUNCTION get_party_display_name(
  p_party_id NUMBER
, p_name_format NUMBER
, p_language VARCHAR2)
                     RETURN VARCHAR2
IS
  v_display_name VARCHAR2(240):=null;
  v_status       VARCHAR2(240) := null;
  v_msg          VARCHAR2(240) := null;
BEGIN
   retrieve_party_display_name(p_party_id , p_name_format, p_language, v_display_name,v_status, v_msg);
   RETURN v_display_name;
END get_party_display_name;


FUNCTION get_party_display_name(p_party_id NUMBER)
                     RETURN VARCHAR2
IS
BEGIN
   RETURN get_party_display_name(p_party_id ,
                                 name_last_title_first,
                                 userenv('LANG')
                                );
END get_party_display_name;

/**
  Retrieves Party display name according to the given Name format.
  Wrapper on the procedure retrieve_party_display_name
*/
FUNCTION party_display_name(
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name    IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_language       IN VARCHAR2)
RETURN VARCHAR2
IS
  v_display_name VARCHAR2(240):=null;
  v_status       VARCHAR2(240) := null;
  v_msg          VARCHAR2(240) := null;
BEGIN

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(
          log_level => fnd_log.level_statement,
          module    =>'PON_LOCALE_PKG',
          message   =>'Entered the function with parameters -- ' ||
                      ' p_first_name : ' || p_first_name ||
                      ' p_last_name : ' || p_last_name ||
                      ' p_middle_name : ' || p_middle_name ||
                      ' p_prefix : ' || p_prefix ||
                      ' p_suffix : ' || p_suffix ||
                      ' p_language : ' || p_language
          );
   end if;

   retrieve_party_display_name (p_first_name,
				p_last_name,
				p_middle_name,
				p_prefix,
				p_suffix,
				null, -- no need of party id
				default_name_display_pattern,
        p_language,
				v_display_name,
				v_status,
				v_msg);

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(
          log_level => fnd_log.level_statement,
          module    =>'PON_LOCALE_PKG',
          message   =>'v_status : ' || v_status || '; v_status : ' || v_status || ' ;Returning the value v_display_name : '||v_display_name);
   end if;
   RETURN v_display_name;
END party_display_name;

--Fix for bug 14831857
--Overloading function with party_id
FUNCTION party_display_name(
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name    IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_language       IN VARCHAR2
, p_party_id       IN NUMBER)
RETURN VARCHAR2
IS
  v_display_name VARCHAR2(240):=null;
  v_status       VARCHAR2(240) := null;
  v_msg          VARCHAR2(240) := null;
BEGIN

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(
          log_level => fnd_log.level_statement,
          module    =>'PON_LOCALE_PKG',
          message   =>'Entered the function with parameters -- ' ||
                      ' p_first_name : ' || p_first_name ||
                      ' p_last_name : ' || p_last_name ||
                      ' p_middle_name : ' || p_middle_name ||
                      ' p_prefix : ' || p_prefix ||
                      ' p_suffix : ' || p_suffix ||
                      ' p_language : ' || p_language ||
                      'p_party_id : ' || p_party_id);
   end if;

   retrieve_party_display_name (p_first_name,
				p_last_name,
				p_middle_name,
				p_prefix,
				p_suffix,
				p_party_id,
				default_name_display_pattern,
        p_language,
				v_display_name,
				v_status,
				v_msg);

   if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(
          log_level => fnd_log.level_statement,
          module    =>'PON_LOCALE_PKG',
          message   =>'v_status : ' || v_status || '; v_status : ' || v_status || ' ;Returning the value v_display_name : '||v_display_name);
   end if;
   RETURN v_display_name;
END party_display_name;

END PON_LOCALE_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_LOCALE_PKG" TO "EBSBI";
