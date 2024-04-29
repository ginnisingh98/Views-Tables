--------------------------------------------------------
--  DDL for Package JTF_DBSTRING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DBSTRING_UTILS" AUTHID CURRENT_USER as
/* $Header: JTFSTRGS.pls 115.5 2002/02/14 12:09:26 pkm ship     $ */

-- THIS PACKAGE MUST BE KEPT IN SYNCH WITH ITS CLIENT EQUIVALENT

maxString  varchar2(32767);

-----------------------------------------------------------------------------
-- Description:
--
-- Get the mnemomic character in a given string.
--
-- @param label the string to parse.
-- @return the mnemonic access key, null if there is none.
-----------------------------------------------------------------------------
function getMnemonicChar(label in varchar2) return varchar2;

-----------------------------------------------------------------------------
-- Description:
--
-- Strip the mnemonic from a given string.
--
-- @param label the string to parse.
-- @return the strippped string (without the ampersand).
-----------------------------------------------------------------------------
function stripMnemonic(label in varchar2) return varchar2;

function getLineFeed   return varchar2;
function getNullString return varchar2;


-----------------------------------------------------------------------------
-- Description:
--
-- Returns the short string representation for a boolean value.
--
-- Notes:
--
-- This function must stay in synch with the boolean representation as defined
-- in oracle.apps.jtf.util.DelimitedStringInput and
--    oracle.apps.jtf.util.DelimitedStringOutput
--
-- @param thisBoolean The boolean value.
-- @return true returns 'T', false returns 'F'
-----------------------------------------------------------------------------
function getBooleanString(thisBoolean in boolean) return varchar2;
-----------------------------------------------------------------------------
-- Description:
--
-- Returns the boolean value for the short string representation of the same.
--
-- Notes:
--
-- This function must stay in synch with the boolean representation as defined
-- in oracle.apps.jtf.util.DelimitedStringInput and
--    oracle.apps.jtf.util.DelimitedStringOutput
--
-- @param thisBoolean The boolean value.
-- @return 'T' return true, 'F' returns false
-----------------------------------------------------------------------------
function getBoolean(thisBoolean in varchar2) return boolean;

function getMaxStringLength return integer;

function getCurrencyFormatLength return integer;

FUNCTION getVersion RETURN VARCHAR2;
end JTF_DBSTRING_UTILS;

 

/
