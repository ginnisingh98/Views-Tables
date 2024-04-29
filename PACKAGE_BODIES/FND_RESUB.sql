--------------------------------------------------------
--  DDL for Package Body FND_RESUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RESUB" as
/* $Header: AFCPRSBB.pls 120.2 2005/08/19 20:48:39 jtoruno ship $ */


FUNCTION GET_PARAM_INFO(Param_num in number, Name out nocopy varchar2) return number is
begin
 return (FND_RESUB_PRIVATE.GET_PARAM_INFO(Param_num,Name));
end;

FUNCTION GET_PARAM_NUMBER(name in varchar2, Param_num out nocopy number) return number is
begin
 return (FND_RESUB_PRIVATE.GET_PARAM_NUMBER(name,Param_num));
end;

FUNCTION GET_PARAM_TYPE(Param_num in number, Param_type out nocopy varchar2) return number is
begin
 return (FND_RESUB_PRIVATE.GET_PARAM_TYPE(Param_num, Param_type));
end;

FUNCTION GET_REQUESTED_START_DATE return date is
begin
 return (FND_RESUB_PRIVATE.GET_REQUESTED_START_DATE);
end;

FUNCTION GET_RUSUB_COUNT return number is
begin
 return (FND_RESUB_PRIVATE.GET_RUSUB_COUNT);
end;

FUNCTION GET_RUSUB_DELTA return number is
begin
 return (FND_RESUB_PRIVATE.GET_RUSUB_DELTA);
end;

FUNCTION GET_INCREMENT_FLAG return varchar2 is
begin
 return (FND_RESUB_PRIVATE.GET_INCREMENT_FLAG);
end;

PROCEDURE GET_PROGRAM(PROG_NAME out nocopy VARCHAR2, PROG_APP_NAME out nocopy varchar2) is
begin
 FND_RESUB_PRIVATE.GET_PROGRAM(PROG_NAME,PROG_APP_NAME);
end;

PROCEDURE GET_SCHEDULE(TYPE out nocopy VARCHAR2, APP_ID out nocopy number,
	ID out nocopy number, Name out nocopy varchar2) is
begin
 FND_RESUB_PRIVATE.GET_SCHEDULE(TYPE,APP_ID,ID,Name);
end;

PROCEDURE SET_PARAMETER(param_num in number, param_value in varchar2) is
begin
 FND_RESUB_PRIVATE.SET_PARAMETER(param_num,param_value);
end;

FUNCTION GET_PARAMETER(param_num in number) return varchar2 is
begin
 return (FND_RESUB_PRIVATE.GET_PARAMETER(param_num));
end;

PROCEDURE RETURN_INFO(errcode in number, errbuf in varchar2) is
begin
 FND_RESUB_PRIVATE.RETURN_INFO(errcode,errbuf);
end;


end;

/
