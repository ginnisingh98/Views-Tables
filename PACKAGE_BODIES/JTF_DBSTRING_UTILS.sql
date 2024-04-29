--------------------------------------------------------
--  DDL for Package Body JTF_DBSTRING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DBSTRING_UTILS" AS
/* $Header: JTFSTRGB.pls 115.5 2002/02/14 12:09:25 pkm ship     $ */
  maxStringLength       constant integer := 32767;
  boolean_true_string   constant varchar2(5) := 'T';
  boolean_false_string  constant varchar2(5) := 'F';
  lineFeed              constant varchar2(10) := fnd_global.newline;
  nullString            constant varchar2(10) := 'null';
  currencyFormatLength  constant integer := 60;

------------------------------------------------------------------------------
--  PUBLIC METHODS
-----------------------------------------------------------------------------


------------------------------------------------------------------------------
--  Methods dealing with mnemonics
-----------------------------------------------------------------------------

function getMnemonicChar(label in varchar2) return varchar2 is
  pos number := instr(label,'&');
begin
  if pos > 0 then
    return substr(label,pos + 1,1);
  else
    return null;
  end if;
end getMnemonicChar;

-----------------------------------------------------------------------------

function stripMnemonic(label in varchar2) return varchar2 is
begin
  return replace(label,'&');
end stripMnemonic;

function getLineFeed   return varchar2 is
begin
	return lineFeed;
end getLineFeed;
-----------------------------------------------------------------------------

function getNullString return varchar2 is
begin
	return nullString;
end getNullString;

-----------------------------------------------------------------------------
function getBooleanString(thisBoolean in boolean) return varchar2 is
begin
  if thisBoolean then
    return boolean_true_string;
  else
   return boolean_false_string;
  end if;
end getBooleanString;

-----------------------------------------------------------------------------
function getBoolean(thisBoolean in varchar2) return boolean is
begin
  if thisBoolean  = boolean_true_string then
    return true;
  else
   return false;
  end if;
end getBoolean;

function getMaxStringLength return integer is
begin
  return maxStringLength;
end getMaxStringLength;


function getCurrencyFormatLength return integer is
begin
  return currencyFormatLength;
end getCurrencyFormatLength;

FUNCTION getVersion RETURN VARCHAR2 IS
  BEGIN
    RETURN('$Header: JTFSTRGB.pls 115.5 2002/02/14 12:09:25 pkm ship     $');
  END getVersion;

END JTF_DBSTRING_UTILS;

/
