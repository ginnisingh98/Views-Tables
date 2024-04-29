--------------------------------------------------------
--  DDL for Package Body IGI_CIS_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_GET_PROFILE" AS
/* $Header: igicisab.pls 115.5 2002/08/29 15:06:45 sbrewer ship $ */

    FUNCTION Cis_Tax_Code RETURN VARCHAR2 IS
        l_profile_option_value fnd_profile_option_values.profile_option_value%TYPE;
    BEGIN

        SELECT profile_option_value
        INTO   l_profile_option_value
        FROM   fnd_profile_option_values fpov
              ,fnd_profile_options       fpo
        WHERE  UPPER(fpo.profile_option_name) = 'IGI_CIS_TAX_CODE'
        AND    fpov.profile_option_id = fpo.profile_option_id
        AND    fpov.level_id = 10001;

        RETURN l_profile_option_value;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
        WHEN TOO_MANY_ROWS THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
        WHEN OTHERS THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
    END Cis_Tax_Code;

    FUNCTION Cis_Tax_Group RETURN VARCHAR2 IS
        l_profile_option_value fnd_profile_option_values.profile_option_value%TYPE;
    BEGIN

        SELECT profile_option_value
        INTO   l_profile_option_value
        FROM   fnd_profile_option_values fpov
              ,fnd_profile_options       fpo
        WHERE  UPPER(fpo.profile_option_name) = 'IGI_CIS_TAX_GROUP'
        AND    fpov.profile_option_id = fpo.profile_option_id
        AND    fpov.level_id = 10001;

        RETURN l_profile_option_value;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
        WHEN TOO_MANY_ROWS THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
        WHEN OTHERS THEN
            l_profile_option_value := 'CIS';
            RETURN l_profile_option_value;
    END Cis_Tax_Group;

END IGI_CIS_GET_PROFILE;

/
