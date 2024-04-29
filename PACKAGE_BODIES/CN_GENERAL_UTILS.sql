--------------------------------------------------------
--  DDL for Package Body CN_GENERAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GENERAL_UTILS" AS
-- $Header: cnsygutb.pls 120.1 2005/08/10 03:46:43 hithanki noship $
/*
 Package Body Name
   cn_general_utils
 Purpose
   This package consists of general utilities used throughout commissions.
 History
   06-SEP-94 P Cook          Created by removing the non-generation specific
                             procedures and functions from cn_utils.
   17-JUL-95 P Cook	     No longer raise app_exception when no rows found
			     in from period packages
   06-NOV-95 P Cook	     Bug:320828. get_currency. Return an error message
			     when no sob in cn_repositories.
   04-APR-96 A Saxena	     Added function get_set_of_books_id
   03-JUN-96 A Saxena	     Added function get_currency_CODE
*/

  --
  -- Function Name
  --   get_set_of_books_id
  -- Purpose
  --   Get set of books id for current instance of CN
  --   Assumes always will be exactly 1 record in CN_REPOSITORIES

  FUNCTION get_set_of_books_id RETURN NUMBER is
        SOB_ID  number;
  begin
        select SET_OF_BOOKS_ID
        into    SOB_ID
        from    CN_REPOSITORIES;
        return(SOB_ID);
  end;


  --
  -- Function Name
  --   get_currency
  -- Purpose
  --   Get currency code for the current set of books
  --

  FUNCTION get_currency(p_org_id NUMBER) RETURN VARCHAR2 IS x_currency_code VARCHAR2(15);

  BEGIN
   SELECT  s.currency_code
     INTO  x_currency_code
     FROM  gl_sets_of_books s
	  ,cn_repositories_all  r
    WHERE r.set_of_books_id = s.set_of_books_id
      AND r.application_id  = 283
      AND r.org_id = p_org_id
    ;

    RETURN x_currency_code;

    EXCEPTION

      WHEN no_data_found THEN
        fnd_message.set_name('CN','ALL_NO_INSTANCE_INFO');
        app_exception.raise_exception;

  END get_currency;

  --
  -- Function Name
  --   get_currency_code
  -- Purpose
  --   Get currency code for the current set of books
  --   Differs from above in that it is guaranteed not to update database
  --   I.e., can be selected from sys.dual
  --

  FUNCTION get_currency_code RETURN VARCHAR2 IS x_currency_code VARCHAR2(15);

  BEGIN
   SELECT  s.currency_code
     INTO  x_currency_code
     FROM  gl_sets_of_books s
	  ,cn_repositories  r
    WHERE r.set_of_books_id = s.set_of_books_id
      AND r.application_id  = 283
    ;

    RETURN x_currency_code;

  END get_currency_code;

  --
  -- Procedure Name
  --   get_period_id
  -- Purpose
  --   Get period for given date
  --

  FUNCTION get_period_id (X_period_date DATE)
	RETURN NUMBER IS X_period_id NUMBER;
  BEGIN
   SELECT period_id
   INTO   X_period_id
   FROM   cn_periods
   WHERE  X_period_date BETWEEN trunc(start_date)
                        AND trunc(end_date)
   ;
   RETURN X_period_id;

  EXCEPTION
   WHEN no_data_found THEN
	RETURN null;
--      fnd_message.set_name('CN','ALL_NO_PERIOD_FOUND');
--      app_exception.raise_exception;

  END get_period_id;

  --
  -- Procedure Name
  --   get_period_info
  -- Purpose
  --
  --

  PROCEDURE get_period_info ( x_period_date   IN     DATE
			     ,x_period_id     IN OUT NOCOPY NUMBER
			     ,x_period_name   IN OUT NOCOPY VARCHAR2
			     ,x_period_status    OUT NOCOPY VARCHAR2
			     ,x_start_date       OUT NOCOPY DATE
			     ,x_end_date         OUT NOCOPY DATE) IS

  BEGIN

   IF (   x_period_date IS NOT NULL
       OR x_period_name IS NOT NULL
       OR x_period_id   IS NOT NULL) THEN

     SELECT  p.period_id
	    ,p.period_status
	    ,p.period_name
	    ,p.start_date
	    ,p.end_date
       INTO  x_period_id
	    ,x_period_status
	    ,x_period_name
	    ,x_start_date
	    ,x_end_date
       FROM cn_periods p
      WHERE (   x_period_date IS NULL
	     OR x_period_date  BETWEEN trunc(p.start_date)
             			   AND trunc(p.end_date) )
        AND (   x_period_name IS NULL
	     OR x_period_name = p.period_name)
        AND (   x_period_id IS NULL
	     OR x_period_id = p.period_id)
    ;

   END IF;

    EXCEPTION
      WHEN no_data_found THEN
	null; -- The calling routine must decide what to do in this case
         --fnd_message.set_name('CN','ALL_NO_PERIOD_FOUND');
         --app_exception.raise_exception;


  END get_period_info;

  -- Procedure Name
  --   get_period_name
  -- Purpose
  --   Get period name for given period_id
  --

  FUNCTION get_period_name (X_period_id NUMBER)
          RETURN VARCHAR2 IS X_period_name VARCHAR2(30);
  BEGIN
   SELECT period_name
   INTO   X_period_name
   FROM   cn_periods
   WHERE  period_id = X_period_id
   ;
   RETURN X_period_name;

  EXCEPTION
   WHEN no_data_found THEN
	RETURN null;
--      fnd_message.set_name('CN','ALL_NO_PERIOD_FOUND');
--      app_exception.raise_exception;

  END get_period_name;


  --
  -- Procedure Name
  --   get_meaning
  -- Purpose
  --    Get meaning for given lookup type and code

  FUNCTION get_meaning (X_lookup_code VARCHAR2,
 		       X_lookup_type VARCHAR2)
	   RETURN varchar2 IS X_meaning VARCHAR2(80);

   BEGIN
    SELECT meaning
    INTO   X_meaning
    FROM   cn_lookups
    WHERE  lookup_code = X_lookup_code
    AND    lookup_type = X_lookup_type;

    RETURN X_meaning;

 EXCEPTION
   WHEN no_data_found THEN
      RAISE no_data_found;

 END get_meaning;


  --
  -- Procedure Name
  --   Get_Salesrep_info
  -- Purpose
  --

  PROCEDURE get_salesrep_info ( X_Salesrep_id 	       NUMBER
          		       ,X_Name    	   IN OUT NOCOPY VARCHAR2
			       ,X_employee_number  IN OUT NOCOPY NUMBER) IS
  BEGIN

   SELECT  name
	  ,employee_number
   INTO   x_name
	 ,x_employee_number
   FROM   cn_salesreps
   WHERE  salesrep_id = X_Salesrep_id
   ;

  EXCEPTION
   WHEN no_data_found THEN
	RAISE no_data_found;

  END get_salesrep_info;

  --
  -- Procedure Name
  --
  -- Purpose
  --

 FUNCTION get_username (X_userid number) RETURN varchar2 IS
   X_username VARCHAR2(100);
 BEGIN

  SELECT user_name
  INTO   X_username
  FROM   fnd_user
  WHERE  user_id = X_userid;

  return X_username;

 EXCEPTION
   when no_data_found then
      raise no_data_found;

 END get_username;

END cn_general_utils;

/
