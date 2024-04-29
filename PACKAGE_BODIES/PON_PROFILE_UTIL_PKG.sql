--------------------------------------------------------
--  DDL for Package Body PON_PROFILE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_PROFILE_UTIL_PKG" as
/*$Header: PONPRUTB.pls 120.7 2006/03/31 05:49:41 rpatel noship $ */

PROCEDURE update_organization_start_date(
  p_party_id IN NUMBER
, x_status		OUT NOCOPY VARCHAR2
, x_exception_msg          OUT NOCOPY VARCHAR2
)
IS
BEGIN
  UPDATE hz_organization_profiles
  SET effective_start_date=trunc(SYSDATE)
  WHERE party_id=p_party_id;

  x_exception_msg :=NULL;
EXCEPTION

    WHEN OTHERS THEN
      --dbms_output.put_line('Other failure -- '||x_exception_msg);
      raise;

END update_organization_start_date;

FUNCTION get_update_date_from_party (
  p_party_id IN NUMBER
) RETURN DATE
IS
  l_date DATE;
BEGIN
  SELECT last_update_date
  INTO l_date
  FROM hz_parties
  WHERE party_id = p_party_id;
  return l_date;
END get_update_date_from_party;


FUNCTION get_update_date_from_location (
  p_location_id IN NUMBER
) RETURN DATE
IS
  l_date DATE;
BEGIN
  SELECT last_update_date
  INTO l_date
  FROM hz_locations
  WHERE location_id = p_location_id;
  return l_date;
END get_update_date_from_location;

FUNCTION get_update_date_from_contact (
  p_contact_id IN NUMBER
) RETURN DATE
IS
  l_date DATE;
BEGIN
  SELECT last_update_date
  INTO l_date
  FROM hz_contact_points
  WHERE contact_point_id = p_contact_id;
  return l_date;
END get_update_date_from_contact;

PROCEDURE update_ins_party_pref_cover(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, p_pref_value        in VARCHAR2
, p_pref_meaning      in VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
)
IS
  att1 VARCHAR2(150):= NULL;
  att2 VARCHAR2(150):= NULL;
  att3 VARCHAR2(150):= NULL;
  att4 VARCHAR2(150):= NULL;
  att5 VARCHAR2(150):= NULL;
BEGIN
  update_or_insert_party_pref(
    p_party_id
  , p_app_short_name
  , p_pref_name
  , p_pref_value
  , p_pref_meaning
  , att1, att2, att3, att4, att5
  , x_status
  , x_exception_msg
  );
  x_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_status := 'E';
END;

PROCEDURE UPDATE_OR_INSERT_PARTY_PREF(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, p_pref_value        in VARCHAR2
, p_pref_meaning        in VARCHAR2
, p_attribute1        in VARCHAR2
, p_attribute2        in VARCHAR2
, p_attribute3        in VARCHAR2
, p_attribute4        in VARCHAR2
, p_attribute5        in VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
)
IS
 l_count   NUMBER;
BEGIN
 x_exception_msg :='entering update_or_insert_party_perference';
  select count(*)
  into l_count
  from PON_PARTY_PREFERENCES
  where party_id = p_party_id
  AND preference_name = p_pref_name
  AND APP_SHORT_NAME = p_app_short_name;

if l_count > 0 then
  -- do an update because row exists
  x_exception_msg :='updating party_perference';
  UPDATE PON_PARTY_PREFERENCES
  SET PREFERENCE_VALUE = p_pref_value
  , PREFERENCE_MEANING = p_pref_meaning
  , ATTRIBUTE1 = p_attribute1
  , ATTRIBUTE2 = p_attribute2
  , ATTRIBUTE3 = p_attribute3
  , ATTRIBUTE4 = p_attribute4
  , ATTRIBUTE5 = p_attribute5
  WHERE party_id = p_party_id
  AND preference_name = p_pref_name
  AND app_short_name = p_app_short_name;
ELSE
  x_exception_msg :='inserting party_perference';
  -- insert a new row because it doesn't exist
  insert into PON_PARTY_PREFERENCES
  (
     party_id
   , APP_SHORT_NAME
   , preference_name
   , PREFERENCE_VALUE
   , PREFERENCE_MEANING
   , ATTRIBUTE1
   , ATTRIBUTE2
   , ATTRIBUTE3
   , ATTRIBUTE4
   , ATTRIBUTE5
  )
  VALUES
(
    p_party_id
  , p_app_short_name
  , p_pref_name
  , p_pref_value
  , p_pref_meaning
  , p_attribute1
  , p_attribute2
  , p_attribute3
  , p_attribute4
  , p_attribute5
);
END IF;

  x_exception_msg :='';
  x_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_status := 'E';

END UPDATE_OR_INSERT_PARTY_PREF;

-- hzheng
PROCEDURE DELETE_PARTY_PREF(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
)
IS

 l_count   NUMBER;
BEGIN
  x_exception_msg :='entering DELETE_PARTY_PREF';

  SELECT count(*)
  INTO l_count
  FROM PON_PARTY_PREFERENCES
  WHERE party_id = p_party_id
        AND preference_name = p_pref_name
        AND APP_SHORT_NAME = p_app_short_name;

  IF l_count > 0 THEN

    DELETE FROM PON_PARTY_PREFERENCES
    WHERE party_id = p_party_id
          AND preference_name = p_pref_name
          AND APP_SHORT_NAME = p_app_short_name;

  END IF;

  x_exception_msg :='';
  x_status := 'S';

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    x_status := 'E';
    x_exception_msg := x_exception_msg||' ' ||SQLERRM;

END DELETE_PARTY_PREF;



PROCEDURE retrieve_party_pref_cover(
  p_party_id          IN NUMBER
, p_app_short_name    IN VARCHAR2
, p_pref_name         IN VARCHAR2
, x_pref_value        OUT NOCOPY VARCHAR2
, x_pref_meaning      OUT NOCOPY VARCHAR2
, x_status            OUT NOCOPY VARCHAR2
, x_exception_msg     OUT NOCOPY VARCHAR2
)
IS
  meaning VARCHAR2(150);
  att1 VARCHAR2(150);
  att2 VARCHAR2(150);
  att3 VARCHAR2(150);
  att4 VARCHAR2(150);
  att5 VARCHAR2(150);
BEGIN
  retrieve_party_preference(p_party_id, p_app_short_name, p_pref_name,
    x_pref_value, x_pref_meaning, att1,att2,att3,att4,att5, x_status,
    x_exception_msg);

END;


PROCEDURE RETRIEVE_PARTY_PREFERENCE(
  p_party_id          in NUMBER
, p_app_short_name    in VARCHAR2
, p_pref_name         in VARCHAR2
, x_pref_value        out nocopy VARCHAR2
, x_pref_meaning      out nocopy VARCHAR2
, x_attribute1        out nocopy VARCHAR2
, x_attribute2        out nocopy VARCHAR2
, x_attribute3        out nocopy VARCHAR2
, x_attribute4        out nocopy VARCHAR2
, x_attribute5        out nocopy VARCHAR2
, x_status            out nocopy VARCHAR2
, x_exception_msg     out nocopy VARCHAR2
)
IS
BEGIN
 x_exception_msg :='entering retrieve_party_perference';
 x_status := 'S';

  -- Since now sourcing is hosted for one buyer company, no need to
  -- check for party id. This will simply code so that when supplier
  -- tries to retrieve a party preference, he doesn't need to pass
  -- buyer company's party id
  SELECT preference_value, preference_meaning, attribute1, attribute2,
        attribute3, attribute4, attribute5
  INTO x_pref_value,x_pref_meaning,x_attribute1,x_attribute2,x_attribute3,
       x_attribute4, x_attribute5
  FROM PON_PARTY_PREFERENCES
  WHERE app_short_name= p_app_short_name
  AND preference_name=p_pref_name
  AND rownum = 1;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_status := 'E';
       -- default value of N for BEST_PRICE_VISIBLE_BLIND flag
       IF (p_pref_name = 'BEST_PRICE_VISIBLE_BLIND') THEN
          x_pref_value := 'N';
          x_status := 'S';
       END IF;

     WHEN OTHERS THEN
       x_status := 'U';
       x_exception_msg := 'unexpected error retrieving preference  : ' || p_pref_name || ' party id: ' ||p_party_id;


END RETRIEVE_PARTY_PREFERENCE;

PROCEDURE get_party_url(party_id IN NUMBER
, url OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2)
IS
  attribute1 VARCHAR2(150);
  attribute2 VARCHAR2(150);
  attribute3 VARCHAR2(150);
  attribute4 VARCHAR2(150);
  attribute5 VARCHAR2(150);
  meaning VARCHAR2(150);
BEGIN
  retrieve_party_preference(p_party_id => party_id,
    p_app_short_name => 'PON',
    p_pref_name => 'PON_URL',
    x_pref_value => url,
    x_pref_meaning => meaning,
    x_attribute1 => attribute1,
    x_attribute2 => attribute2,
    x_attribute3 => attribute3,
    x_attribute4 => attribute4,
    x_attribute5 => attribute5,
    x_status => x_status,
    x_exception_msg => x_exception_msg);
END GET_PARTY_URL;

PROCEDURE get_party_slogan(party_id IN NUMBER
, slogan OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2)
IS
  attribute1 VARCHAR2(150);
  attribute2 VARCHAR2(150);
  attribute3 VARCHAR2(150);
  attribute4 VARCHAR2(150);
  attribute5 VARCHAR2(150);
  meaning VARCHAR2(150);
BEGIN
  retrieve_party_preference(p_party_id => party_id,
    p_app_short_name => 'PON',
    p_pref_name => 'PON_SLOGAN',
    x_pref_value => slogan,
    x_pref_meaning => meaning,
    x_attribute1 => attribute1,
    x_attribute2 => attribute2,
    x_attribute3 => attribute3,
    x_attribute4 => attribute4,
    x_attribute5 => attribute5,
    x_status => x_status,
    x_exception_msg => x_exception_msg);
END GET_PARTY_SLOGAN;

PROCEDURE get_party_port(party_id IN NUMBER
, port OUT NOCOPY VARCHAR2
, x_status OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2)
IS
  attribute1 VARCHAR2(150);
  attribute2 VARCHAR2(150);
  attribute3 VARCHAR2(150);
  attribute4 VARCHAR2(150);
  attribute5 VARCHAR2(150);
  meaning VARCHAR2(150);
BEGIN
  retrieve_party_preference(p_party_id => party_id,
    p_app_short_name => 'PON',
    p_pref_name => 'PON_PORT',
    x_pref_value => port,
    x_pref_meaning => meaning,
    x_attribute1 => attribute1,
    x_attribute2 => attribute2,
    x_attribute3 => attribute3,
    x_attribute4 => attribute4,
    x_attribute5 => attribute5,
    x_status => x_status,
    x_exception_msg => x_exception_msg);
END GET_PARTY_PORT;

--
-- Obsoleted. Please do not use.
--
PROCEDURE SET_WF_LANGUAGE(p_user_name IN VARCHAR2,p_language_code IN VARCHAR2)
 IS
  l_language VARCHAR2(150);
BEGIN
  SELECT NLS_LANGUAGE
  INTO l_language
  FROM FND_LANGUAGES
  WHERE LANGUAGE_CODE = p_language_code;

  fnd_preference.put(upper(p_user_name), 'WF', 'LANGUAGE', l_language);
END SET_WF_LANGUAGE;

--
-- don't be confused with the procedure name (it's a legacy)
-- this procedure actually get the ICX_LANGUAGE of the user.
-- a temporary workaround for bug 2354113.
--
PROCEDURE GET_WF_LANGUAGE(p_user_name IN VARCHAR2,x_language_code OUT NOCOPY VARCHAR2)
IS
  l_language VARCHAR2(150);
  ln_user_id NUMBER;
BEGIN
  BEGIN
    SELECT user_id
    INTO   ln_user_id
    FROM   fnd_user
    WHERE  user_name = upper(p_user_name);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     ln_user_id := null;
  END;

  l_language := fnd_profile.value_specific('ICX_LANGUAGE', ln_user_id, NULL, NULL);
  SELECT LANGUAGE_CODE
  INTO x_language_code
  FROM FND_LANGUAGES
  WHERE NLS_LANGUAGE = l_language;
END GET_WF_LANGUAGE;

--
-- don't be confused with the procedure name (it's a legacy)
-- this procedure actually get the ICX_LANGUAGE of the user.
-- a temporary workaround for bug 2354113.
--
PROCEDURE GET_WF_LANGUAGE(p_user_id IN NUMBER,x_language_code OUT NOCOPY VARCHAR2)
IS
  l_language VARCHAR2(150);
BEGIN

  l_language := fnd_profile.value_specific('ICX_LANGUAGE', p_user_id, NULL, NULL);
  SELECT LANGUAGE_CODE
  INTO x_language_code
  FROM FND_LANGUAGES
  WHERE NLS_LANGUAGE = l_language;
END GET_WF_LANGUAGE;

--
-- obsolete. no more valid. please do not use.
-- use ICX preferences instead
--
PROCEDURE SET_WF_TERRITORY(p_user_name IN VARCHAR2,p_territory_code IN VARCHAR2)
 IS
  l_territory VARCHAR2(150);
  BEGIN

  SELECT NLS_TERRITORY
  INTO l_territory
  FROM FND_TERRITORIES
  WHERE TERRITORY_CODE = p_territory_code;

  fnd_preference.put(upper(p_user_name), 'WF', 'TERRITORY', l_territory);

END SET_WF_TERRITORY;

--
-- bug fix for 2668483
--
PROCEDURE GET_WF_TERRITORY(p_user_name IN VARCHAR2,x_territory_code OUT NOCOPY VARCHAR2)
IS
  l_territory VARCHAR2(150);
  ln_user_id fnd_user.user_id%TYPE;
BEGIN

  SELECT user_id
  INTO   ln_user_id
  FROM   fnd_user
  WHERE  user_name = upper(p_user_name);

  l_territory  := fnd_profile.value_specific('ICX_TERRITORY', ln_user_id, NULL, NULL);

  SELECT TERRITORY_CODE
  INTO x_territory_code
  FROM FND_TERRITORIES
  WHERE NLS_TERRITORY = l_territory;

END GET_WF_TERRITORY;

--
-- obsolete. no more valid. please do not use.
-- use ICX preferences instead
--
PROCEDURE SET_WF_PREFERENCES( p_user_name IN VARCHAR2,
                              p_language_code IN VARCHAR2,
                              p_territory_code IN VARCHAR2)
 IS
  l_language VARCHAR2(150);
  l_territory VARCHAR2(150);
  BEGIN

  SELECT NLS_LANGUAGE
  INTO   l_language
  FROM   FND_LANGUAGES
  WHERE  LANGUAGE_CODE = p_language_code;

  SELECT NLS_TERRITORY
  INTO   l_territory
  FROM   FND_TERRITORIES
  WHERE  TERRITORY_CODE = p_territory_code;

  fnd_preference.put(upper(p_user_name), 'WF', 'LANGUAGE', l_language);
  fnd_preference.put(upper(p_user_name), 'WF', 'TERRITORY', l_territory);

END SET_WF_PREFERENCES;

--
-- bug fix for 2668483
--
PROCEDURE GET_WF_PREFERENCES( p_user_name IN VARCHAR2,
                              x_language_code OUT NOCOPY VARCHAR2,
                              x_territory_code OUT NOCOPY VARCHAR2)
 IS
  BEGIN
    get_wf_language(p_user_name, x_language_code);
    get_wf_territory(p_user_name, x_territory_code);

END GET_WF_PREFERENCES;

-- GET_STRING- get a particular translated message
--             from the message dictionary database.
--   This is a one-call interface for when you just want to get a
--   message without doing any token substitution.
--   Returns NAMEIN (Msg name)  if the message cannot be found.
FUNCTION get_string(appin IN VARCHAR2,
		    namein IN VARCHAR2,
		    langin IN VARCHAR2)
  RETURN VARCHAR2
  IS
     MSG  varchar2(2000) := NULL;


     CURSOR c1(name_arg VARCHAR2) IS SELECT message_text
       FROM fnd_new_messages m, fnd_application a
       WHERE name_arg = m.message_name
       AND m.language_code = langin
       AND appin = a.application_short_name
       AND m.application_id = a.application_id;

     CURSOR c2(name_arg VARCHAR2) IS SELECT message_text
       FROM fnd_new_messages m, fnd_application a
       WHERE name_arg = m.message_name
       AND 'US' = m.language_code
       AND appin = a.application_short_name
       AND m.application_id = a.application_id;
BEGIN
   /* get the message text out of the table */
      OPEN c1(upper(namein));
      FETCH c1 INTO msg;
      IF c1%notfound THEN
	 OPEN c2(Upper(namein));
	 FETCH c2 INTO msg;
	 IF c2%notfound THEN
	    msg := namein;
	 END IF;
	 CLOSE c2;
      END IF;
      CLOSE c1;
      /* double ampersands don't have anything to do with tokens, they */
      /* represent access keys.  So we translate them to single ampersands*/
      /* so that the access key code will recognize them. */
      msg := substrb(REPLACE(msg, '&&', '&'),1,2000);
   RETURN msg;
END get_string;

FUNCTION SET_PRINT_OPTIONS  RETURN VARCHAR2
  IS

     l_printer_state boolean;
     l_status VARCHAR2(3);

  BEGIN

     /* Change printer options, as work around to
     concurrent manager bug 1880369 */

     l_printer_state := FND_REQUEST.SET_PRINT_OPTIONS(printer=>'noprint',copies => 0);

     IF l_printer_state = TRUE THEN
	l_status := 'Y';
     ELSE
	l_status := 'N';
     END IF;

     RETURN l_status;

END set_print_options;

FUNCTION save_profile_option(p_option_name IN VARCHAR2,
			     p_option_value IN VARCHAR2,
			     p_level_name IN VARCHAR2)  RETURN VARCHAR2
  IS

     l_saved boolean;
     l_status VARCHAR2(3);

  BEGIN

     l_saved := FND_PROFILE.SAVE(p_option_name, p_option_value, p_level_name, null, null);


     IF l_saved = TRUE THEN
	l_status := 'Y';
     ELSE
	l_status := 'N';
     END IF;

     RETURN l_status;

END save_profile_option;


FUNCTION relationship_exists(
  p_subject_id         IN NUMBER
, p_object_id          IN NUMBER
, p_relationship_type  IN VARCHAR2
, p_relationship_code  IN VARCHAR2
) RETURN VARCHAR2
IS

  l_count NUMBER;

BEGIN

  SELECT count(*)
  INTO   l_count
  FROM   hz_relationships
  WHERE  subject_id = p_subject_id
  AND    object_id = p_object_id
  AND    relationship_type = p_relationship_type
  AND    relationship_code = p_relationship_code
  AND    status = 'A'
  AND    start_date <= sysdate
  AND    end_date  >= sysdate
  AND    ROWNUM < 2;

  IF l_count > 0 THEN
    return 'Y';
  ELSE
    return 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    raise;
END relationship_exists;


PROCEDURE lines_more_than_threshold(
        p_number_of_lines IN NUMBER,
        p_party_id IN NUMBER,
        x_is_super_large_neg OUT NOCOPY VARCHAR2)
is
l_pref_value VARCHAR2(240);
l_pref_meaning VARCHAR2(240);
l_status VARCHAR2(240);
l_exception_msg VARCHAR2(240);
l_attribute VARCHAR2(240);
l_super_large_lines_threshold VARCHAR2(30);
l_meaning VARCHAR2(240);
BEGIN
        RETRIEVE_PARTY_PREFERENCE (
                p_party_id => p_party_id,
                p_app_short_name => 'PON',
                p_pref_name => 'CONCURRENT_PROCESS_LINE_START',
                x_pref_value => l_super_large_lines_threshold,
                x_pref_meaning => l_meaning,
                x_attribute1 => l_attribute,
                x_attribute2 =>l_attribute,
                x_attribute3 => l_attribute,
                x_attribute4 => l_attribute,
                x_attribute5 => l_attribute,
                x_status => l_status,
                x_exception_msg => l_exception_msg);

                IF (l_super_large_lines_threshold IS NULL) THEN
                    l_super_large_lines_threshold := PON_LARGE_AUCTION_UTIL_PKG.g_default_lines_threshold;
                END IF;

                IF (p_number_of_lines > l_super_large_lines_threshold) THEN
                    x_is_super_large_neg := 'Y';
                ELSE
                    x_is_super_large_neg := 'N';
                END IF;


END lines_more_than_threshold;

END PON_PROFILE_UTIL_PKG;

/
