--------------------------------------------------------
--  DDL for Package Body ASG_OA_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_OA_BASE" as
/* $Header: asgoabaseb.pls 120.2 2005/07/26 01:56:52 ravir noship $ */

FUNCTION getRealTime(sec in number) return varchar2
is
   h varchar2(10);
   m varchar2(10);
   s varchar2(10);
   temp number;
begin
    select to_char(lpad(trunc(sec/3600),2,'0')) into h from dual;
    select  mod(sec, 3600) into temp from dual;
    select to_char(lpad(trunc(temp/60),2,'0')) into m from dual;
    select  mod(temp, 60) into s from dual;
    return h || ':' || m ||':' || s;
end getRealTime;

FUNCTION getEnabled (code in VARCHAR2,
                    sign1 in number,
                    status_code in varchar,
                    sign2 in number) return varchar2
is
l_enabled varchar2(1);
begin
    if ((code = 'END') and (status_code = 'Y' )and (sign1 = -1) and (sign2 = -1)) then
        l_enabled := 'Y';
    else
        l_enabled := 'N';
    end if;
    return l_enabled;
end getEnabled;

end asg_oa_base;

/
