--------------------------------------------------------
--  DDL for Package Body OKE_K_USER_ATTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_USER_ATTR_UTILS" AS
/* $Header: OKEKUAUB.pls 115.4 2002/08/28 19:00:49 alaw ship $ */

--
--  Name          : Form_Above_Prompt
--  Pre-reqs      : None
--  Function      : This function returns the concatenated form above
--                  prompt for a given user attribute group (desc flex
--                  context)
--
--  Parameters    :
--  IN            : X_USER_ATTRIBUTE_CONTEXT    VARCHAR2
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Form_Above_Prompt
( X_User_Attribute_Context    IN     VARCHAR2
) RETURN VARCHAR2 IS

  return_value    VARCHAR2(2000);
  frozen          VARCHAR2(1);
  delimiter       VARCHAR2(1);

  CURSOR dflex IS
    SELECT concatenated_segment_delimiter
    ,      freeze_flex_definition_flag
    FROM   fnd_descriptive_flexs
    WHERE  application_id = 777
    AND    descriptive_flexfield_name = 'OKE_K_USER_ATTRIBUTES'
    ;

  CURSOR flexcol IS
    SELECT form_left_prompt
    FROM   fnd_descr_flex_col_usage_vl
    WHERE  application_id = 777
    AND    descriptive_flexfield_name = 'OKE_K_USER_ATTRIBUTES'
    AND    descriptive_flex_context_code = X_User_Attribute_Context
    ORDER BY column_seq_num
    ;

BEGIN

  return_value := NULL;

  OPEN dflex;
  FETCH dflex INTO delimiter , frozen;
  CLOSE dflex;

  FOR crec IN flexcol LOOP
    IF ( return_value IS NULL ) THEN
      return_value := crec.form_left_prompt;
    ELSE
      return_value := return_value || delimiter || crec.form_left_prompt;
    END IF;
  END LOOP;

  RETURN ( return_value );

END Form_Above_Prompt;

END OKE_K_USER_ATTR_UTILS;

/
