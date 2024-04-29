--------------------------------------------------------
--  DDL for Package MSC_X_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_SECURITY" AUTHID CURRENT_USER as
/*$Header: MSCXSECS.pls 115.2 2002/03/01 16:43:43 pkm ship       $ */

  /**
    Sets the session variables to sys_context('MSC', 'COMPANY_ID')
    and sys_context('MSC', 'COMPANY_NAME')
  */

  procedure set_context;

end msc_x_security;

 

/
