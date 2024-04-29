--------------------------------------------------------
--  DDL for Package OKE_K_USER_ATTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_USER_ATTR_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEKUAUS.pls 115.3 2002/08/14 01:44:07 alaw ship $ */

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
) RETURN VARCHAR2;


END OKE_K_USER_ATTR_UTILS;

 

/
