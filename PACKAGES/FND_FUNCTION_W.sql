--------------------------------------------------------
--  DDL for Package FND_FUNCTION_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FUNCTION_W" AUTHID CURRENT_USER AS
/* $Header: hrfndwrs.pkh 115.3 2002/12/11 10:50:50 hjonnala noship $*/
/*
  ||===========================================================================
  || PROCEDURE: test
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API - fnd_function.test() which
  ||     does the following ;
  ||       Test if function is accessible under current responsibility.
  ||       Only checks static function security, not data security.
  ||       This is here for cases where performance is important,
  ||       and for backwards compatibility, but in general new code
  ||       should use TEST_INSTANCE instead if acting on a particular
  ||       object instance (database row).
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     function_name - function to test
  ||
  || out nocopy Arguments:
  ||     result       - 'Y' - if the function is accessible
  ||                    'N' - if the function is not accessible.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure TEST
                (p_function_name in  varchar2,
                 p_result        out nocopy varchar2) ;

  /*
  ||===========================================================================
  || PROCEDURE: test_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API - fnd_function.test() which
  ||     does the following ;
  ||       Test if function is accessible under current responsibility.
  ||
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     function_id - function id to test
  ||
  || out nocopy Arguments:
  ||     result       - 'Y' - if the function is accessible
  ||                    'N' - if the function is not accessible.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure TEST_ID
                (p_function_id   in  number,
                 p_result        out nocopy varchar2) ;

END fnd_function_w;

 

/
