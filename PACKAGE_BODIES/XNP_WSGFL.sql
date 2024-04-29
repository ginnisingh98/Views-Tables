--------------------------------------------------------
--  DDL for Package Body XNP_WSGFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WSGFL" as
/* $Header: XNPWSFLB.pls 120.0 2005/05/30 11:50:07 appldev noship $ */


---------------------
   function Black (Param in varchar2) return varchar2 is
   begin
        return '<font color="#000000">'||Param||'</font>';
   end;
---------------------
   function Blue (Param in varchar2) return varchar2 is
   begin
        return '<font color="#0000FF">'||Param||'</font>';
   end;
---------------------
   function Cyan (Param in varchar2) return varchar2 is
   begin
        return '<font color="#00FFFF">'||Param||'</font>';
   end;
---------------------
   function Green (Param in varchar2) return varchar2 is
   begin
        return '<font color="#00FF00">'||Param||'</font>';
   end;
---------------------
   function Grey (Param in varchar2) return varchar2 is
   begin
        return '<font color="#999999">'||Param||'</font>';
   end;
---------------------
   function Magenta (Param in varchar2) return varchar2 is
   begin
        return '<font color="#FF00FF">'||Param||'</font>';
   end;
---------------------
   function Red (Param in varchar2) return varchar2 is
   begin
        return '<font color="#FF0000">'||Param||'</font>';
   end;
---------------------
   function White (Param in varchar2) return varchar2 is
   begin
        return '<font color="#999999">'||Param||'</font>';
   end;
---------------------
   function Yellow (Param in varchar2) return varchar2 is
   begin
        return '<font color="#FFFF00">'||Param||'</font>';
   end;
---------------------
end;

/
