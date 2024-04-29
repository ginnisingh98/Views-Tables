--------------------------------------------------------
--  DDL for Package HR_JAVA_CONV_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JAVA_CONV_UTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrjcutls.pkh 115.4 2002/02/28 19:03:30 pkm ship        $*/

  /*
  ||===========================================================================
  || FUNCTION: get_boolean
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||    Returns boolean equivalent of the passed number.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_number  --  The number value that needs to be converted into boolean.
  ||
  || Out Arguments:
  ||
  || In Out Arguments:
  ||
  || Post Success:
  ||     Returns boolean equivalent of the passed number.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_boolean (
    p_number IN NUMBER DEFAULT NULL
  )
  RETURN BOOLEAN;


  /*
  ||===========================================================================
  || FUNCTION: get_number
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||    Returns number equivalent of the passed boolean.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_boolean --  The boolean value that needs to be converted into number.
  ||
  || Out Arguments:
  ||
  || In Out Arguments:
  ||
  || Post Success:
  ||     Returns number equivalent of the passed boolean.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_number (
    p_boolean IN BOOLEAN DEFAULT NULL
  )
  RETURN NUMBER;


 /*
  ||===========================================================================
  || FUNCTION: get_formatted_error_message
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||    Returns error message to be returned to the jave modules.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||  p_error_message  -- Input error message that needs to be formatted.
  ||  p_attr_name      -- VO attribute name.
  ||  p_app_short_name -- Application Id for the fnd_new_message.
  ||  p_message_name   -- fnd_new_message name
  ||
  || Out Arguments:
  ||
  || In Out Arguments:
  ||
  || Post Success:
  ||     Returns formatted error message to be passed to Java modules.
  ||
  || Post Failure:
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
  RETURN LONG;



END hr_java_conv_util_ss;

 

/
