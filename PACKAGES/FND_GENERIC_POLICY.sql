--------------------------------------------------------
--  DDL for Package FND_GENERIC_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_GENERIC_POLICY" AUTHID CURRENT_USER AS
/* $Header: AFSCGPLS.pls 115.1 2003/08/01 21:43:31 tmorrow noship $ */


/*
**  FND_GENERIC_POLICY.GET_PREDICATE-
**
**  Returns the data security predicate for a given synonym.
**  In order to use this function as the data security policy function,
**  the name of the synonym or view object that this is attached to
**  needs to be exactly the same as the function name that will be
**  used to get the data security predicate.  And that function needs
**  to have its object_id properly set in the FND_FORM_FUNCTIONS table.
**
**  In other words this routine will do the following when attached as a
**  policy function to the synonym MY_FUNC_NAME:
**  - Look up the object out of FND_FORM_FUNCTIONS for function
**    MY_FUNC_NAME.  That object must be the underlying object
**    behind the synonym.
**  - Call FND_DATA_SECURITY.GET_SECURITY_PREDICATE to get a security
**    predicate ("Where clause") that restricts the rows to the ones
**    that are accessible for that object, that function, for the current
**    user.
**
**  This routine should never need to be called directly by apps code.
**  Rather its name is passed to the add_policy() routine when vpd
**  policies are created, so that it will be called back by the
**  database upon access to the synonym or view.
*/
FUNCTION GET_PREDICATE(    p_schema IN VARCHAR2,
                           p_object IN VARCHAR2)
                           RETURN VARCHAR2;

END FND_GENERIC_POLICY;

 

/
