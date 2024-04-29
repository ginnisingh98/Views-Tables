--------------------------------------------------------
--  DDL for Package Body IGW_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_MESSAGES" as
--$Header: igwprmsb.pls 115.4 2002/03/28 19:13:41 pkm ship    $

function get_message(X_Index IN NUMBER,
                       X_Encoded IN VARCHAR2) RETURN VARCHAR2 IS
  St_Msg_Txt varchar2(2000);
 Begin
   St_Msg_Txt := fnd_msg_pub.get(p_msg_index => X_Index,
                                 p_encoded => X_Encoded );
      return St_Msg_Txt;
 end get_message;
end igw_messages;

/
