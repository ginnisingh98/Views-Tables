--------------------------------------------------------
--  DDL for Package FND_RESUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RESUB" AUTHID CURRENT_USER as
/* $Header: AFCPRSBS.pls 120.2 2005/08/19 20:49:03 jtoruno ship $ */


FUNCTION GET_PARAM_INFO(Param_num in number, Name out nocopy varchar2) return number;

FUNCTION GET_PARAM_NUMBER(name in varchar2, Param_num out nocopy number) return number;

FUNCTION GET_PARAM_TYPE(Param_num in number, Param_type out nocopy varchar2) return number;

FUNCTION GET_REQUESTED_START_DATE return date;
pragma restrict_references (GET_REQUESTED_START_DATE, WNDS);

FUNCTION GET_RUSUB_COUNT return number;
pragma restrict_references (GET_RUSUB_COUNT, WNDS);

FUNCTION GET_RUSUB_DELTA return number;
pragma restrict_references (GET_RUSUB_DELTA, WNDS);

FUNCTION GET_INCREMENT_FLAG return varchar2;
pragma restrict_references (GET_INCREMENT_FLAG, WNDS);

PROCEDURE GET_PROGRAM(PROG_NAME out nocopy VARCHAR2, PROG_APP_NAME out nocopy varchar2);
pragma restrict_references (GET_PROGRAM, WNDS);

PROCEDURE GET_SCHEDULE(TYPE out nocopy VARCHAR2, APP_ID out nocopy number,
	ID out nocopy number, Name out nocopy varchar2);
pragma restrict_references (GET_SCHEDULE, WNDS);

PROCEDURE SET_PARAMETER(param_num in number, param_value in varchar2);

FUNCTION GET_PARAMETER(param_num in number) return varchar2;
pragma restrict_references (GET_PARAMETER, WNDS);

PROCEDURE RETURN_INFO(errcode in number, errbuf in varchar2);
end;

 

/
