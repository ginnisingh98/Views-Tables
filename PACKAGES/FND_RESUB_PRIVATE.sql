--------------------------------------------------------
--  DDL for Package FND_RESUB_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RESUB_PRIVATE" AUTHID CURRENT_USER as
/* $Header: AFCPRSPS.pls 120.1.12010000.2 2014/05/27 18:32:59 tkamiya ship $ */


procedure process_increment(req_id in number, new_req_start in varchar2,
		 new_req_id in number, errnum out nocopy number, errbuf out nocopy varchar2);

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

procedure default_increment_proc;

end;

/
