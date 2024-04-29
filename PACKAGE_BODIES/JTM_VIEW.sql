--------------------------------------------------------
--  DDL for Package Body JTM_VIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_VIEW" AS
/* $Header: jtmviewb.pls 120.1 2005/08/24 02:19:05 saradhak noship $ */

/* declaration of private global variables */
-- simple cache
g_key1 VARCHAR2(80) := null; -- profile_option_name in fnd_profile_options_tl
g_col1_1 VARCHAR2(240) := null; -- user_profile_option_name
g_col1_2 VARCHAR2(240) := null; -- description
g_key2_1 VARCHAR2(30) := null; -- lookup_type in fnd_lookup_types_tl
g_key2_2 NUMBER(15) := null; -- security_group_id
g_key2_3 NUMBER(15) := null; -- view_application_id
g_col2_1 VARCHAR2(80) := null; -- meaning
g_col2_2 VARCHAR2(240) := null; -- description
g_key3_1 NUMBER(10) := null; -- application_id in fnd_descriptive_flexs_tl
g_key3_2 VARCHAR2(40) := null; -- descriptive_flexfield_name
g_col3_1 VARCHAR2(60) := null; -- title
g_col3_2 VARCHAR2(45) := null; -- form_context_prompt
g_col3_3 VARCHAR2(240) := null; -- description

/* declaration of private procedures and functions */
PROCEDURE do_fnd_profile_options_tl (p_profile_option_name VARCHAR2);
PROCEDURE do_fnd_lookup_types_tl (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER);
PROCEDURE do_fnd_descriptive_flexs_tl (p_application_id NUMBER, p_descriptive_flexfield_name VARCHAR2);

FUNCTION get_fnd_profile_options_name (p_profile_option_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    do_fnd_profile_options_tl(p_profile_option_name);
    RETURN g_col1_1;
END get_fnd_profile_options_name;

FUNCTION get_fnd_profile_options_desc (p_profile_option_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    do_fnd_profile_options_tl(p_profile_option_name);
    RETURN g_col1_2;
END get_fnd_profile_options_desc;

FUNCTION get_fnd_lookup_types_mean (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER) RETURN VARCHAR2 IS
BEGIN
    do_fnd_lookup_types_tl(p_lookup_type, p_security_group_id, p_view_application_id);
    RETURN g_col2_1;
END get_fnd_lookup_types_mean;

FUNCTION get_fnd_lookup_types_desc (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER) RETURN VARCHAR2 IS
BEGIN
    do_fnd_lookup_types_tl(p_lookup_type, p_security_group_id, p_view_application_id);
    RETURN g_col2_2;
END get_fnd_lookup_types_desc;

FUNCTION get_fnd_descriptive_flexs_titl (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    do_fnd_descriptive_flexs_tl(p_application_id, p_descriptive_flexfield_name);
    RETURN g_col3_1;
END get_fnd_descriptive_flexs_titl;

FUNCTION get_fnd_descriptive_flexs_prom (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    do_fnd_descriptive_flexs_tl(p_application_id, p_descriptive_flexfield_name);
    RETURN g_col3_2;
END get_fnd_descriptive_flexs_prom;

FUNCTION get_fnd_descriptive_flexs_desc (p_application_id VARCHAR2, p_descriptive_flexfield_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    do_fnd_descriptive_flexs_tl(p_application_id, p_descriptive_flexfield_name);
    RETURN g_col3_3;
END get_fnd_descriptive_flexs_desc;

PROCEDURE do_fnd_profile_options_tl (p_profile_option_name VARCHAR2) IS
    CURSOR c_profile_option IS
        SELECT user_profile_option_name, description
        FROM fnd_profile_options_tl
        WHERE profile_option_name = p_profile_option_name
        AND language = USERENV('LANG');
BEGIN
    IF g_key1 IS NULL OR g_key1 <> p_profile_option_name THEN
        g_col1_1 := NULL;
        g_col1_2 := NULL;
        OPEN c_profile_option;
        FETCH c_profile_option INTO g_col1_1, g_col1_2;
        CLOSE c_profile_option;
        g_key1 := p_profile_option_name;
    END IF;
END do_fnd_profile_options_tl;

PROCEDURE do_fnd_lookup_types_tl (p_lookup_type VARCHAR2, p_security_group_id NUMBER, p_view_application_id NUMBER) IS
    CURSOR c_lookup_type IS
        SELECT meaning, description
        FROM fnd_lookup_types_tl
        WHERE lookup_type = p_lookup_type
        AND security_group_id = p_security_group_id
        AND view_application_id = p_view_application_id
        AND language = USERENV('LANG');
BEGIN
    IF g_key2_1 IS NULL OR g_key2_1 <> p_lookup_type OR
       g_key2_2 IS NULL OR g_key2_2 <> p_security_group_id OR
       g_key2_3 IS NULL OR g_key2_3 <> p_view_application_id THEN
        g_col2_1 := NULL;
        g_col2_2 := NULL;
        OPEN c_lookup_type;
        FETCH c_lookup_type INTO g_col2_1, g_col2_2;
        CLOSE c_lookup_type;
        g_key2_1 := p_lookup_type;
        g_key2_2 := p_security_group_id;
        g_key2_3 := p_view_application_id;
    END IF;
END do_fnd_lookup_types_tl;

PROCEDURE do_fnd_descriptive_flexs_tl (p_application_id NUMBER, p_descriptive_flexfield_name VARCHAR2) IS
    CURSOR c_desc_flex IS
        SELECT title, form_context_prompt, description
        FROM fnd_descriptive_flexs_tl
        WHERE application_id = p_application_id
        AND descriptive_flexfield_name = p_descriptive_flexfield_name
        AND language = USERENV('LANG');
BEGIN
    IF g_key3_1 IS NULL OR g_key3_1 <> p_application_id OR
       g_key3_2 IS NULL OR g_key3_2 <> p_descriptive_flexfield_name THEN
        g_col3_1 := NULL;
        g_col3_2 := NULL;
        g_col3_3 := NULL;
        OPEN c_desc_flex;
        FETCH c_desc_flex INTO g_col3_1, g_col3_2, g_col3_3;
        CLOSE c_desc_flex;
        g_key3_1 := p_application_id;
        g_key3_2 := p_descriptive_flexfield_name;
    END IF;
END do_fnd_descriptive_flexs_tl;

END jtm_view;

/
