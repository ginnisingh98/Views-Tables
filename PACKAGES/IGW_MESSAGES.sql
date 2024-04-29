--------------------------------------------------------
--  DDL for Package IGW_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_MESSAGES" AUTHID CURRENT_USER as
--$Header: igwprmss.pls 115.3 2002/03/28 19:13:42 pkm ship    $
 function get_message(X_Index IN NUMBER,
                      X_Encoded IN VARCHAR2) RETURN VARCHAR2;
end igw_messages;

 

/
