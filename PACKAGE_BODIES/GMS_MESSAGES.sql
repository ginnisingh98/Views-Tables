--------------------------------------------------------
--  DDL for Package Body GMS_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_MESSAGES" as
-- $Header: gmsawmsb.pls 120.1 2005/07/26 14:20:48 appldev ship $

function get_message(X_Index IN NUMBER,
		       X_Encoded IN VARCHAR2) RETURN VARCHAR2 IS
  St_Msg_Txt varchar2(2000);
 Begin
   St_Msg_Txt := fnd_msg_pub.get(p_msg_index => X_Index,
				 p_encoded => X_Encoded );
      return St_Msg_Txt;
 end get_message;
end gms_messages;

/
