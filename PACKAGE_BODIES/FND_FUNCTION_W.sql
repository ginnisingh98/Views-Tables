--------------------------------------------------------
--  DDL for Package Body FND_FUNCTION_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FUNCTION_W" AS
/* $Header: hrfndwrs.pkb 115.1 2001/12/18 21:02:22 pkm ship        $*/
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
  || Out Arguments:
  ||     result       - 'Y' - if the function is accessible
  ||                    'N' - if the function is not accessible.
  ||
  || In Out Arguments:
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

  procedure TEST (p_function_name in  varchar2,
                 p_result        out varchar2) is

  lc_out_result varchar2(1);
  lb_out_result boolean;

  begin
    lc_out_result := 'N';

    lb_out_result := FND_FUNCTION.TEST(p_function_name);

    if lb_out_result then
      lc_out_result := 'Y';
    end if;
    p_result := lc_out_result;
  exception
    when others then
      raise;  -- Raise error here relevant to the new tech stack.
  end;


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
  || Out Arguments:
  ||     result       - 'Y' - if the function is accessible
  ||                    'N' - if the function is not accessible.
  ||
  || In Out Arguments:
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

  procedure TEST_ID (p_function_id in  number,
                    p_result      out varchar2)  is
  lc_out_result varchar2(1);
  lb_out_result boolean;

  begin
    lc_out_result := 'N';
    lb_out_result := FND_FUNCTION.TEST_ID(p_function_id);

    if lb_out_result then
      lc_out_result := 'Y';
    end if;

    p_result := lc_out_result;
  exception
    when others then
      raise;  -- Raise error here relevant to the new tech stack.
  end;



END fnd_function_w;

/
