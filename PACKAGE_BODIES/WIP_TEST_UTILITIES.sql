--------------------------------------------------------
--  DDL for Package Body WIP_TEST_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_TEST_UTILITIES" as
  /* $Header: wiptestb.pls 115.7 2002/12/12 16:02:08 rmahidha ship $ */


procedure assert(condition boolean) is
begin
  if(not condition) then
    die('*** Assertion Failure ***') ;
  end if ;
end assert ;


procedure die is
begin
  raise PROGRAMMER_ERROR ;
end die ;


procedure die(message varchar2) is
begin
--  dbms_output.put_line(message) ;
  die ;
end die ;


end WIP_TEST_UTILITIES ;

/
