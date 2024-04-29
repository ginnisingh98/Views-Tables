--------------------------------------------------------
--  DDL for Package JTF_DBSTREAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DBSTREAM_UTILS" AUTHID CURRENT_USER AS
/* $Header: JTFSTRMS.pls 115.4 2002/04/09 10:49:33 pkm ship      $ */

--
-- THIS PACKAGE MUST BE KEPT IN SYNCH WITH ITS CLIENT EQUIVALENT

type streamType is table of jtf_dbstring_utils.maxString%TYPE
  index by binary_integer;

type int_table is table of number index by binary_integer;


procedure setLongInputStream(stream in streamType);
procedure setInputStream(stream in varchar2);
procedure setReaderPosition(i in pls_integer);
function  endOfInputStream return boolean;
function  readString   return varchar2;
function  readDate     return date;
function  readDateTime return date;
function  readBoolean  return boolean;
function  readInt      return integer;
function  readNumber   return number;
function  readCurrency(currencyCode in varchar2) return number;

function   getLongOutputStream return streamType;
function   getOutputStream return varchar2;
function   isLongOutputStream return boolean;
procedure  clearOutputStream;
procedure  writeString(s in varchar2);
procedure  writeDate(d in date);
procedure  writeDateTime(d in date);
procedure  writeBoolean(b in boolean);
procedure  writeInt(i in integer);
procedure  writeNumber(n in number);
procedure  writeCurrency(c in number,currencyCode in varchar2);

FUNCTION getVersion RETURN VARCHAR2;

function addNumberToString(inputList in number,
                           inputStream in varchar2)
  return varchar2;

function addNumberToString(inputList in int_table,
                        inputStream in varchar2 := null)
  return varchar2;

function readFromString(inputStream in varchar2)
  return int_table;

function checkNumberExists(inputStream in varchar2,
                        value       in number)
  return boolean;

function removeFromString(inputStream in varchar2,
                          value       in number)
  return varchar2;

END JTF_DBSTREAM_UTILS;

 

/
