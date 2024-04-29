--------------------------------------------------------
--  DDL for Package Body CN_GLOBAL_VAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GLOBAL_VAR" AS
-- $Header: cnsygin1b.pls 120.2 2005/07/13 16:37:03 appldev ship $

/*
 Package Name
   cn_global_var
 Purpose
   This package is used to initialize global variables for the 'current'
   commissions instance

 History
  16-JUN-94 P Cook   	Created
  08-MAY-95 P Cook   	Added srp_batch_size
  08-JUN-95 P Cook      Hardcode repository schema join to 'cn_global_var' instead of
                        user pseudo column. Caused problem in demo db
  26-JUN-95 A Erickson  cn_periods.period_name  column name update.
  30-JUN-95 P Cook	Added set_of_books_id and replaced join to schema
			with join to application_id.
			Adding it to procedure will break code. revisit when
			required.
  12-JUL-95 P Cook	No longer using concept of current period as a sys
			parameter. Removed initialization of current period
			effective srp and revclass hierachies. Retaining
			parameters to reduce impact of change.
  19-SEP-95 P Cook	Added currency code
  22-APR-01 N Kodkani   Made g_currency_code a function for JSP app use
  05-Mar-02 S Venkat    Included new Function g_srp_batch_size
            		Removed existing global variable g_srp_batch_size from query
  30-May-02 S Venkat    Bring g_salesrep_batch_size/package name change(cn_global_var) in sync
*/

PROCEDURE initialize_instance_info(p_org_id IN NUMBER) IS
BEGIN
    SELECT  r.repository_id
           ,r.current_period_id
           ,p.period_name
           ,trunc(p.start_date)
           ,trunc(p.end_date)
           ,r.rev_class_hierarchy_id
           ,r.srp_rollup_hierarchy_id
           ,system_batch_size
           ,transfer_batch_size
           ,r.srp_rollup_flag
--           ,r.srp_batch_size
           ,r.cls_package_size
--           ,r.salesrep_batch_size
           ,r.system_start_period_id
           ,r.system_start_date
	   ,r.set_of_books_id
	   ,s.currency_code
    INTO    g_repository_id
           ,g_curr_period_id
           ,g_curr_period_name
           ,g_curr_period_start_date
           ,g_curr_period_end_date
           ,g_rev_class_hierarchy_id
           ,g_srp_rollup_hierarchy_id
           ,g_system_batch_size
           ,g_transfer_batch_size
           ,g_srp_rollup_flag
--           ,g_srp_batch_size
           ,g_cls_package_size
--           ,g_salesrep_batch_size
           ,g_system_start_period_id
           ,g_system_start_date
	       ,g_set_of_books_id
	       ,gl_currency_code
    FROM    cn_period_statuses_all  p
           ,cn_repositories  r
           ,gl_sets_of_books s
    WHERE  r.current_period_id	= p.period_id(+)
      AND  r.org_id = p.org_id(+)
      AND  r.application_id     = 283
      AND  r.org_id = p_org_id
      AND  r.set_of_books_id    = s.set_of_books_id;

  fnd_currency.get_info(gl_currency_code,
   		                g_precision,
                        g_ext_precision,
                        g_min_acct_unit);
EXCEPTION
   WHEN no_data_found THEN
      fnd_message.set_name('CN','ALL_NO_INSTANCE_INFO');
      app_exception.raise_exception;
END initialize_instance_info;

 FUNCTION get_currency_code(p_org_id IN NUMBER) RETURN VARCHAR2
 IS
   l_currency_code VARCHAR2(30);
 BEGIN

	SELECT  s.currency_code
	INTO  l_currency_code
     FROM  gl_sets_of_books s
           ,cn_repositories  r
	WHERE r.set_of_books_id = s.set_of_books_id
     AND r.application_id  = 283
     AND r.org_id = p_org_id
	;


    RETURN l_currency_code;

 EXCEPTION
    WHEN no_data_found THEN
		fnd_message.set_name('CN','ALL_NO_INSTANCE_INFO');
		app_exception.raise_exception;
 END;


--Function added by Sundar Venkat on 05 Mar 2002
--This is done to fetch batch size from the database
--This is used in the procedure posting_details
FUNCTION get_srp_batch_size(p_org_id IN NUMBER) RETURN NUMBER
 IS
   l_srp_batch_size number;
 BEGIN
 SELECT srp_batch_size
   INTO l_srp_batch_size
   FROM cn_repositories
  WHERE org_id = p_org_id  ;
  RETURN l_srp_batch_size;
 EXCEPTION
    WHEN no_data_found THEN
  fnd_message.set_name('CN','ALL_NO_INSTANCE_INFO');
  app_exception.raise_exception;
 END;


-- a change was made by Sundar Venkat on 05 Mar 2002 in the following section
-- the global variable g_srp_batch_size was removed

 FUNCTION get_salesrep_batch_size(p_org_id IN NUMBER) RETURN NUMBER
 IS
   l_salesrep_batch_size NUMBER;
 BEGIN

	SELECT  r.salesrep_batch_size
	INTO  l_salesrep_batch_size
     FROM   cn_repositories  r
    WHERE r.org_id = p_org_id;


    RETURN l_salesrep_batch_size;

 EXCEPTION
    WHEN no_data_found THEN
		fnd_message.set_name('CN','ALL_NO_INSTANCE_INFO');
		app_exception.raise_exception;
 END;

END cn_global_var;

/
