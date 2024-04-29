--------------------------------------------------------
--  DDL for Package Body HR_JAVA_CONV_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JAVA_CONV_UTIL_SS" AS
/* $Header: hrjcutls.pkb 115.6 2002/03/14 03:49:47 pkm ship     $*/

  -- Package scope global variables.

  /*
  ||===========================================================================
  || FUNCTION: get_boolean
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns boolean equivalent of the passed number.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_boolean (
    p_number IN NUMBER DEFAULT NULL
  )
  RETURN BOOLEAN
  IS

    -- Local variables.
    lb_temp BOOLEAN;

  BEGIN

    IF p_number IS NULL
    THEN
      lb_temp := NULL;
    ELSIF p_number = 1
    THEN
      lb_temp := TRUE;
    ELSE
      lb_temp := FALSE;
    END IF;

    RETURN (lb_temp);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;  -- Raise error here relevant to the new tech stack.

  END get_boolean;


  /*
  ||===========================================================================
  || FUNCTION: get_number
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Returns number equivalent of the passed boolean.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_number (
    p_boolean IN BOOLEAN DEFAULT NULL
  )
  RETURN NUMBER
  IS

    -- Local variables.
    ln_temp NUMBER;

  BEGIN

    IF p_boolean IS NULL
    THEN
      ln_temp := NULL;
    ELSIF p_boolean = TRUE
    THEN
      ln_temp := 1;
    ELSE
      ln_temp := 0;
    END IF;

    RETURN (ln_temp);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;  -- Raise error here relevant to the new tech stack.

  END get_number;


/*
  ||===========================================================================
  || FUNCTION: get_formatted_error_message
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||    Returns error message to be returned to the jave modules.
  ||    p_error_message is an exisiting formatted error message
  ||    p_single_error_message is the new message to be formatted and appended to
  ||    to p_error_message.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_formatted_error_message (
    p_error_message  IN VARCHAR2 DEFAULT null,
    p_attr_name      IN VARCHAR2 DEFAULT null,
    p_app_short_name IN VARCHAR2 DEFAULT null,
    p_message_name   IN VARCHAR2 DEFAULT null,
    p_single_error_message IN VARCHAR2 DEFAULT null
  )
  RETURN LONG
  IS

    -- Local variables.
    l_formatted_error_message LONG;

  BEGIN

    IF (p_single_error_message IS NOT NULL) THEN
     l_formatted_error_message :=
                              nvl(p_error_message,'') || '!' || '|' ||
                              nvl(p_attr_name,'Page') || '|' ||
                              nvl(p_app_short_name, 'ERR') || '|' ||
                              nvl(p_message_name, p_single_error_message) || '|' || '!';
    ELSE
     -- there are cases where error is not trapped by hr_utility.get_message,
     -- but by hr_message.get_message_text
     IF (hr_utility.get_message IS NOT NULL) THEN
        l_formatted_error_message :=
                              nvl(p_error_message,'') || '!' || '|' ||
                              nvl(p_attr_name,'Page') || '|' ||
                              nvl(p_app_short_name, 'ERR') || '|' ||
                              nvl(p_message_name,
                              'ORA' || hr_utility.hr_error_number || ' '||
                              hr_utility.get_message)  || '|' || '!';
     ELSE
        l_formatted_error_message :=
                              nvl(p_error_message,'') || '!' || '|' ||
                              nvl(p_attr_name,'Page') || '|' ||
                              nvl(p_app_short_name, 'ERR') || '|' ||
                              nvl(p_message_name, hr_message.get_message_text) || '|' || '!';
     END IF;
    END IF;

    RETURN (l_formatted_error_message);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;  -- Raise error here relevant to the new tech stack.

  END get_formatted_error_message;


END hr_java_conv_util_ss;

/
