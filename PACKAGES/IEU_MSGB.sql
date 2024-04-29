--------------------------------------------------------
--  DDL for Package IEU_MSGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_MSGB" AUTHID CURRENT_USER AS
/* $Header: IEUVMDTS.pls 120.0 2005/06/02 15:41:22 appldev noship $ */


TYPE msgVariableRecord IS RECORD (
  msg_VAR_NAME    varchar2(4000),
  msg_VAR_VALUE   varchar2(4000)
  );

TYPE msgVariableRecordList IS
  TABLE OF msgVariableRecord INDEX BY BINARY_INTEGER;

FUNCTION SET_MSG_VAR_DATA(P_msgDataList IN msgVariableRecordList)
  RETURN VARCHAR2;

END IEU_MSGB;

 

/
