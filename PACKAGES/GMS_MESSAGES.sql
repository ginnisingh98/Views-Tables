--------------------------------------------------------
--  DDL for Package GMS_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_MESSAGES" AUTHID CURRENT_USER as
-- $Header: gmsawmss.pls 115.3 2002/08/01 09:42:38 gnema ship $
 function get_message(X_Index IN NUMBER,
		      X_Encoded IN VARCHAR2) RETURN VARCHAR2;
end gms_messages;

 

/
