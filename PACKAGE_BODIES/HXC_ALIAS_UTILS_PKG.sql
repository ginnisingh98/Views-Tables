--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_UTILS_PKG" as
/* $Header: hxcaliutl.pkb 120.2 2005/09/23 08:03:38 sechandr noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hxc_alias_utils_pkg
  Purpose
    Used by HXCALIAS (Define Alternate Names) for the hxc_alias_definitions
    and the hxc_alias_values blocks.
  Notes

  History
    01-Nov-00  RAMURTHY   115.0         Date created.
    09-JUN-02  MHANDA     115.4         added  SET VERIFY OFF
    09-Sep-05  sechandr	  115.6	4573414	Conditionally enabling hr_utility calls
 ============================================================================*/

g_debug	boolean	:=hr_utility.debug_enabled;
--------------------------------------------------------------------------------
PROCEDURE validate_defn_translation (p_alias_definition_id   IN    number,
                                     p_language              IN    varchar2,
                                     p_alias_definition_name IN    varchar2,
                                     p_description           IN    varchar2) IS

/*

This procedure fails if an alias definition name translation is already
present in the table for a given language.  Otherwise, no action is performed.
It is used to ensure uniqueness of translated alias definition names.

*/

--
-- This cursor implements the validation we require.
--


     cursor c_translation(p_language                 IN VARCHAR2,
                          p_alias_definition_name    IN VARCHAR2,
                          p_alias_definition_id      IN NUMBER) IS
     SELECT  1
         FROM  hxc_alias_definitions_tl adtl,
               hxc_alias_definitions    ad
         WHERE upper(adtl.alias_definition_name) =
			upper(translate(p_alias_definition_name, '_',' '))
         AND   adtl.alias_definition_id = ad.alias_definition_id
         AND   adtl.language = p_language
         AND   (ad.alias_definition_id <> p_alias_definition_id OR
                p_alias_definition_id IS NULL );

l_package_name VARCHAR2(80);
l_name hxc_alias_definitions.alias_definition_name%type
       := p_alias_definition_name;
l_dummy varchar2(100);
l_dummy_number number;

BEGIN
    g_debug:=hr_utility.debug_enabled;
    if g_debug then
	l_package_name := 'hxc_alias_utils_pkg.validate_defn_translation';
	hr_utility.set_location (l_package_name,1);
    end if;

/*
    BEGIN
        hr_chkfmt.checkformat (l_name,
                              'PAY_NAME',
                              l_dummy, null, null, 'N', l_dummy, null);
        if g_debug then
		hr_utility.set_location (l_package_name,2);
	end if;

    EXCEPTION
        when app_exception.application_exception then
            if g_debug then
		hr_utility.set_location (l_package_name,3);
	    end if;
            fnd_message.set_name ('PAY','PAY_6365_ELEMENT_NO_DB_NAME'); -- check
format failure
            fnd_message.raise_error;
    END;

    if g_debug then
	hr_utility.set_location (l_package_name,10);
    end if;
*/
    OPEN c_translation(p_language
                      ,p_alias_definition_name
                      ,p_alias_definition_id);

    if g_debug then
	hr_utility.set_location (l_package_name,20);
    end if;

    FETCH c_translation INTO l_dummy_number;
    if g_debug then
	hr_utility.set_location (l_package_name,25);
    end if;

    IF c_translation%NOTFOUND THEN
        if g_debug then
		hr_utility.set_location (l_package_name,30);
	end if;
        CLOSE c_translation;
    ELSE
        if g_debug then
		hr_utility.set_location (l_package_name,40);
	end if;
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;

    if g_debug then
	hr_utility.set_location ('Leaving: '||l_package_name,140);
    end if;
END validate_defn_translation;


PROCEDURE validate_name_translation (p_alias_value_id    IN    number,
                                     p_language          IN    varchar2,
                                     p_alias_value_name  IN    varchar2) IS

/*

This procedure fails if an alias value name translation is already
present in the table for a given language.  Otherwise, no action is performed.
It is used to ensure uniqueness of translated alias value names.

*/

--
-- This cursor implements the validation we require.
--


     cursor c_translation(p_language            IN VARCHAR2,
                          p_alias_value_name    IN VARCHAR2,
                          p_alias_value_id      IN NUMBER) IS
     SELECT  1
         FROM  hxc_alias_values_tl avtl,
               hxc_alias_values    av
         WHERE upper(avtl.alias_value_name) =
                        upper(translate(p_alias_value_name, '_',' '))
         AND   avtl.alias_value_id = av.alias_value_id
         AND   avtl.language = p_language
         AND   (av.alias_value_id <> p_alias_value_id OR
                p_alias_value_id IS NULL );

l_package_name VARCHAR2(80);
l_name hxc_alias_values.alias_value_name%type := p_alias_value_name;
l_dummy varchar2(100);
l_dummy_number number;

BEGIN
    g_debug:=hr_utility.debug_enabled;
    if g_debug then
	l_package_name := 'hxc_alias_utils_pkg.validate_name_translation';
	hr_utility.set_location (l_package_name,1);
    end if;

/*
    BEGIN
        hr_chkfmt.checkformat (l_name,
                              'PAY_NAME',
                              l_dummy, null, null, 'N', l_dummy, null);
        if g_debug then
		hr_utility.set_location (l_package_name,2);
	end if;

    EXCEPTION
        when app_exception.application_exception then
            if g_debug then
		hr_utility.set_location (l_package_name,3);
	    end if;
            fnd_message.set_name ('PAY','PAY_6365_ELEMENT_NO_DB_NAME'); -- check
format failure
            fnd_message.raise_error;
    END;

    if g_debug then
	hr_utility.set_location (l_package_name,10);
    end if;
*/
    OPEN c_translation(p_language
                      ,p_alias_value_name
                      ,p_alias_value_id);

    if g_debug then
	hr_utility.set_location (l_package_name,20);
    end if;

    FETCH c_translation INTO l_dummy_number;
    if g_debug then
	hr_utility.set_location (l_package_name,25);
    end if;

    IF c_translation%NOTFOUND THEN
        if g_debug then
		hr_utility.set_location (l_package_name,30);
	end if;
        CLOSE c_translation;
    ELSE
        if g_debug then
		hr_utility.set_location (l_package_name,40);
	end if;
        CLOSE c_translation;
        fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
        fnd_message.raise_error;
    END IF;

    if g_debug then
	hr_utility.set_location ('Leaving: '||l_package_name,140);
    end if;
END validate_name_translation;


END hxc_alias_utils_pkg;

/
