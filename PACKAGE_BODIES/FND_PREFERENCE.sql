--------------------------------------------------------
--  DDL for Package Body FND_PREFERENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PREFERENCE" AS
/* $Header: AFTCPRFB.pls 120.1 2005/07/02 04:19:42 appldev ship $ */


-- Saves information for one preference.




-- Get the value of the given preference.

FUNCTION get(p_user_name IN VARCHAR2,
	     p_module_name IN VARCHAR2,
	     p_pref_name IN VARCHAR2) RETURN VARCHAR2
  IS
     l_pref_value fnd_user_preferences.preference_value%TYPE;
BEGIN
   SELECT preference_value INTO l_pref_value
     FROM fnd_user_preferences
     WHERE user_name=p_user_name
     AND module_name=p_module_name
     AND preference_name=p_pref_name;
   RETURN l_pref_value;
EXCEPTION WHEN no_data_found THEN
   RETURN NULL;
END;

 -- Get the value of the given encrypted preference.
 --    Note: length of p_key value must be an exact multiple of 8.

FUNCTION eget(p_user_name   in varchar2,
              p_module_name in varchar2,
              p_pref_name   in varchar2,
              p_key         in varchar2) return varchar2 is
  eval varchar2(240);
  val  varchar2(240);
begin
  if (mod(length(p_key), 8) <> 0) then
    return null;
  end if;

  eval := fnd_preference.get(p_user_name, p_module_name, p_pref_name);
  if (eval is null) then
    -- Don't decrypt, dbms_obfuscation_toolkit can't handle nulls --
    return null;
  else
    dbms_obfuscation_toolkit.desdecrypt(input_string     => eval,
                                        key_string       => p_key,
                                        decrypted_string => val);
    return rtrim(val, ' ');
  end if;
end;

-- Updates the value of the preference if it exists, otherwise creates it.

PROCEDURE put(p_user_name	IN VARCHAR2,
			  p_module_name	IN VARCHAR2,
			  p_pref_name	IN VARCHAR2,
			  p_pref_value	IN VARCHAR2)
IS
BEGIN

	UPDATE	fnd_user_preferences
	SET		preference_value=p_pref_value
	WHERE	user_name=p_user_name
	AND		module_name=p_module_name
	AND		preference_name=p_pref_name;

	IF SQL%notfound THEN

		INSERT INTO	fnd_user_preferences
		(
			user_name,
			module_name,
			preference_name,
			preference_value
		)
		VALUES
		(
			p_user_name,
			p_module_name,
			p_pref_name,
			p_pref_value
		);

    END IF;

    -- Bug 3203225
    IF ((UPPER(p_pref_name) = 'MAILTYPE') and (UPPER(p_module_name) = 'WF')) then
		FND_USER_PKG.User_synch(p_user_name);
    END IF;

END;


 -- Updates the value of the encrypted preference if it exists,
 -- otherwise creates it.
 --    Note: length of p_key value must be an exact multiple of 8.
 --          This routine ensures pref_value is also exact multiple of 8
 --          and encrypts.

PROCEDURE eput(p_user_name   in varchar2,
               p_module_name in varchar2,
	       p_pref_name   in varchar2,
	       p_pref_value  in varchar2,
               p_key         in varchar2) is
  mymod  number;
  padval varchar2(240);
  eval   varchar2(240);
begin
  if (mod(length(p_key), 8) <> 0) then
    return;
  end if;

  if (p_pref_value is null) then
    -- Don't encrypt it, dbms_obfuscation_toolkit can't handle nulls --
    eval := p_pref_value;
  else
    -- Pad the value and encrypt --
    mymod := mod(length(p_pref_value), 8);

    if (mymod = 0) then
      padval := p_pref_value;
    else
      padval := rpad(p_pref_value, length(p_pref_value) + 8 - mymod, ' ');
    end if;

    dbms_obfuscation_toolkit.desencrypt(input_string     => padval,
                                        key_string       => p_key,
                                        encrypted_string => eval);
  end if;

  fnd_preference.put(p_user_name, p_module_name, p_pref_name, eval);
end;


FUNCTION exists(p_user_name IN VARCHAR2,
		p_module_name IN VARCHAR2,
		p_pref_name IN VARCHAR2) RETURN BOOLEAN
  IS
     l_count INTEGER ;
BEGIN
   SELECT COUNT(1) INTO l_count
     FROM fnd_user_preferences
     WHERE user_name=p_user_name
     AND module_name=p_module_name
     AND preference_name=p_pref_name;
   IF(l_count=0) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
   END IF;
END;

PROCEDURE remove(p_user_name IN VARCHAR2,
		 p_module_name IN VARCHAR2,
		 p_pref_name IN VARCHAR2)
  IS
BEGIN
    DELETE FROM fnd_user_preferences
      WHERE user_name=p_user_name
      AND  module_name=p_module_name
      AND  preference_name=p_pref_name;

END;

PROCEDURE save_change(p_user_name IN VARCHAR2,
		      p_module_name IN VARCHAR2,
		      p_preference_name IN VARCHAR2,
		      p_preference_value IN VARCHAR2,
		      p_action IN VARCHAR2)
  IS
BEGIN


   IF(p_action='D') THEN
      remove (p_user_name,p_module_name,p_preference_name);

    ELSIF((p_action='I')OR(p_action='U')) THEN
      put(p_user_name,
	  p_module_name,
	  p_preference_name,
	  p_preference_value);

    ELSIF (p_action='C') THEN
      delete_all(p_user_name,p_module_name);

   END IF;

END;


PROCEDURE save_changes(p_user_name IN VARCHAR2,
		       p_module_name IN VARCHAR2,
		       p_prefs_tab IN prefs_tab_type)
  IS
BEGIN

   FOR i IN 1..p_prefs_tab.COUNT LOOP
      save_change(p_user_name,p_module_name,p_prefs_tab(i).name,p_prefs_tab(i).value,p_prefs_tab(i).action);
   END LOOP;
END;

PROCEDURE delete_all(p_user_name IN VARCHAR2,
		     p_module_name IN VARCHAR2)
  IS
BEGIN
   DELETE FROM fnd_user_preferences
     WHERE user_name=p_user_name
     AND  module_name=p_module_name;
END;

 -- Get the value of a preference.
 --    Note: Returns *NULL* for blank preferences
 --                  *UNKNOWN* for missing preferences

FUNCTION GetDefined(p_user_name   IN VARCHAR2,
                    p_module_name IN VARCHAR2,
                    p_pref_name   IN VARCHAR2) RETURN VARCHAR2 IS
  l_pref_value fnd_user_preferences.preference_value%TYPE;
begin
  select nvl(preference_value,'*NULL*') into l_pref_value
  from   fnd_user_preferences
  where  user_name = p_user_name
  and    module_name = p_module_name
  and    preference_name = p_pref_name;

  return l_pref_value;
exception when no_data_found then
  return '*UNKNOWN*';
end;

 -- Updates the value of the preference if it exists, otherwise creates it
 --    If pref_value is *NULL*, blanks out value
 --    If pref_value is *UNKNOWN*, does nothing

PROCEDURE putDefined(p_user_name   IN VARCHAR2,
                     p_module_name IN VARCHAR2,
                     p_pref_name   IN VARCHAR2,
                     p_pref_value  IN VARCHAR2) is
begin
  if (p_pref_value = '*UNKNOWN*') then
    return;
  end if;

  update fnd_user_preferences
  set    preference_value = decode(p_pref_value, '*NULL*', null, p_pref_value)
  where  user_name = p_user_name
  and    module_name = p_module_name
  and    preference_name = p_pref_name;

  if SQL%notfound then
    insert into fnd_user_preferences (
      user_name,
      module_name,
      preference_name,
      preference_value)
        values
     (p_user_name,
      p_module_name,
      p_pref_name,
      decode(p_pref_value, '*NULL*', null, p_pref_value));
  end if;
end;
------------------------------
END;

/

  GRANT EXECUTE ON "APPS"."FND_PREFERENCE" TO "EM_OAM_MONITOR_ROLE";
