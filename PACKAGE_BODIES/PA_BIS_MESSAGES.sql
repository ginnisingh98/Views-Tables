--------------------------------------------------------
--  DDL for Package Body PA_BIS_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BIS_MESSAGES" AS
/* $Header: PABISMEB.pls 115.2 99/10/28 14:12:04 porting ship    $ */

--------------------------------------
-- FUNCTION/PROCEDURE IMPLEMENTATIONS
--
Function GET_MESSAGE(p_prod_code IN VARCHAR2,
                     p_msg_code IN VARCHAR2)
RETURN VARCHAR2 AS
l_msg_name VARCHAR2(2000);
Begin
    FND_MESSAGE.SET_NAME (p_prod_code,p_msg_code);
l_msg_name := FND_MESSAGE.GET;
    RETURN l_msg_name;
END GET_MESSAGE;
END PA_BIS_MESSAGES;

/
