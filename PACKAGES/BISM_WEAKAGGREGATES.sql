--------------------------------------------------------
--  DDL for Package BISM_WEAKAGGREGATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_WEAKAGGREGATES" AUTHID CURRENT_USER as
/* $Header: bibascts.pls 120.2 2006/04/03 05:20:13 akbansal noship $ */
type myrctype is ref cursor;
procedure associate(fid raw, a_srcpath varchar2,a_tgtpath varchar2,name varchar2,value varchar2, myid raw);
procedure dissociate(fid raw, a_srcpath varchar2, a_name varchar2, a_value varchar2,myid raw);
function get_associate(fid raw,a_srcpath varchar2,a_attrname varchar2,a_attrvalue varchar2,myid raw) return myrctype;
function object_load (objid raw) return myrctype;
procedure get(fid raw,path varchar2,a_objname out nocopy varchar2,a_objid out nocopy raw,a_typeid out nocopy number,myid raw,startpos in out nocopy integer,folderid out nocopy raw) ;
function verify_source(fid raw,a_srcpath varchar2,myid raw,folderid out nocopy raw) return raw;
end;

 

/
