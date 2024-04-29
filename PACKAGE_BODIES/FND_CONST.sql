--------------------------------------------------------
--  DDL for Package Body FND_CONST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONST" as
  /* $Header: AFSCCONB.pls 120.0.12000000.1 2007/01/18 13:25:53 appldev ship $ */

  --
  -- local_chr
  --   Return specified character in current codeset
  -- IN
  --   ascii_chr - chr number in US7ASCII
  --
  function local_chr(ascii_chr in number) return varchar2 is
    lang varchar2(255);
  begin
    lang := userenv('LANGUAGE');
    return(convert(chr(ascii_chr),
                   substr(lang, instr(lang,'.') + 1), 'US7ASCII'));
  end local_chr;

  function NEWLINE return varchar2 is begin return(local_chr(10)); end;
  function TAB return varchar2 is begin return(local_chr(9)); end;

  function BOOL(v boolean default true) return varchar2 is begin
    if v then return 'true'; else return 'false'; end if; end;

  function BOOL(v varchar2 default 'true') return boolean is begin
    if lower(v) in ('t','true','y','yes') then return true;
    else return false; end if; end;

  function BOOL(v number default 1) return boolean is begin
    if v = 1 then return true; else return false; end if; end;

end fnd_const;

/
