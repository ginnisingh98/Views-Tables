--------------------------------------------------------
--  DDL for Package Body OE_BIS_SALESPERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BIS_SALESPERSON" AS
--$Header: OEXBISPB.pls 120.0.12000000.3 2008/12/24 12:43:14 kshashan ship $

FUNCTION GET_SALESPERSON_NAME
(p_salesrep_id IN number)
return varchar2  is
x_salesperson varchar2(100);

begin
  select name
  into x_salesperson
  from ra_salesreps
  where salesrep_id = p_salesrep_id;

  return x_salesperson;

exception
when others then
  x_salesperson := null;
  return x_salesperson;

end GET_SALESPERSON_NAME;


/*
NAME :
       Get_salesperson_name
BRIEF DESCRIPTION  :
       This API is called to retrieve the salesperson name
       from the salesperson ID.
CALLER :
       1. Definition of view OEFG_ORDER_LINES.
RELEASE LEVEL :
       12.0.5 and higher.
PARAMETERS :
       p_salesrep_id         Salesperson ID
       p_org_id              Org context
*/

FUNCTION GET_SALESPERSON_NAME
(p_salesrep_id IN number,
 p_org_id      IN number)
return varchar2  is
l_org_id      number;
x_salesperson varchar2(100);

begin

  -- Save the context information
  l_org_id := mo_global.get_current_org_id;

  -- Set the policy context explicitly so that
  -- all synonyms work even if this function is
  -- called from outside the application where
  -- org context is not initialized.

  mo_global.set_policy_context('S', p_org_id);

  select name
  into x_salesperson
  from ra_salesreps
  where salesrep_id = p_salesrep_id;

  -- Reset the org context
  IF l_org_id IS NOT NULL THEN
	mo_global.set_policy_context('S', l_org_id);
  ELSE
	mo_global.set_policy_context(NULL, NULL);
  END IF;

  return x_salesperson;

exception
when others then
  mo_global.set_policy_context(NULL, NULL);
  x_salesperson := null;
  return x_salesperson;

end GET_SALESPERSON_NAME;


END OE_BIS_SALESPERSON;

/
