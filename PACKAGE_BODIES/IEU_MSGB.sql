--------------------------------------------------------
--  DDL for Package Body IEU_MSGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_MSGB" AS
/* $Header: IEUVMDTB.pls 120.0 2005/06/02 15:54:42 appldev noship $ */



FUNCTION SET_MSG_VAR_DATA( P_msgDataList IN msgVariableRecordList)
  RETURN VARCHAR2 IS

  msg_String Varchar2(4000);

BEGIN

  for i in P_msgDataList.first .. P_msgDataList.Last
  loop

     msg_String := msg_String ||fnd_global.local_chr(020)||P_msgDataList(i).msg_var_name
                              ||fnd_global.local_chr(031)||P_msgDataList(i).msg_var_value
                              ||fnd_global.local_chr(028);

  end loop;

  return msg_String;
END;

END IEU_MSGB;

/
