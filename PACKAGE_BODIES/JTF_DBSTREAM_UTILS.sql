--------------------------------------------------------
--  DDL for Package Body JTF_DBSTREAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DBSTREAM_UTILS" AS
/* $Header: JTFSTRMB.pls 115.10 2002/12/04 17:53:06 pseo ship $ */

  inputStream           streamType;
  readerPosition        pls_integer;
  readerCharIndex       pls_integer;
  readerRowIndex        pls_integer := 1;
  outputStream          streamType;
  writerRowIndex        pls_integer;

  leadingDelimiter      constant varchar2(5) := '[';
  trailingDelimiter     constant varchar2(5) := ']';

  INVALID_DELIMITER     exception;
  INVALID_STRING_LENGTH exception;
  INVALID_READER_POS	  exception;
  INVALID_STREAM    	  exception;
  NULL_STREAM    	      exception;
  UNSUPPORTED_OPERATION exception;
  END_OF_STREAM         exception;

  STREAM_OVERHEAD       constant pls_integer := 100;
  MAX_STREAM_LENGTH     constant pls_integer := jtf_dbstring_utils.getMaxStringLength - STREAM_OVERHEAD;
  MAX_STRING_LENGTH     constant pls_integer := 32767;

  INT_SEPARATOR         constant varchar2(1) := ':';

------------------------------------------------------------------------------
--  PRIVATE METHODS
-----------------------------------------------------------------------------

procedure initInputStreamVariables is
begin
  readerPosition  := 1;
  readerCharIndex := 1;
  readerRowIndex  := inputStream.FIRST;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.initInputStreamVariables :'||SQLERRM);
	  app_exception.raise_exception;
end initInputStreamVariables;
-----------------------------------------------------------------------------

procedure clearInputStream is
begin
	inputStream.DELETE;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.clearInputStream :'||SQLERRM);
	  app_exception.raise_exception;
end clearInputStream;

-----------------------------------------------------------------------------

function getTrailingDelimiterPos(rowIndex in pls_integer
                                ,leadingDelimiterPos in pls_integer) return pls_integer is
begin
 	return instr(inputStream(rowIndex),trailingDelimiter,leadingDelimiterPos);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.getTrailingDelimiterPos :'||SQLERRM);
	  app_exception.raise_exception;
end getTrailingDelimiterPos;
------------------------------------------------------------------------------

function getStringLength(rowIndex in pls_integer
                        ,leadingDelimiterPos in pls_integer
                        ,trailingDelimiterPos in pls_integer) return integer is
begin
  return to_number(substr(inputStream(rowIndex),leadingDelimiterPos + 1,trailingDelimiterPos - leadingDelimiterPos - 1));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.getStringLength :'||SQLERRM);
	  app_exception.raise_exception;
end getStringLength;
------------------------------------------------------------------------------

procedure checkForCommonErrors is
begin
	if inputStream.COUNT = 0 then
		raise NULL_STREAM;
	elsif inputStream.COUNT > 2 then
		raise UNSUPPORTED_OPERATION;
	end if;
exception
  when NULL_STREAM then
    fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
    fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_dbstream_utils.checkForCommonErrors: No input stream has been set.');
    app_exception.raise_exception;
  when UNSUPPORTED_OPERATION then
    fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
    fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_dbstream_utils.checkForCommonErrors: Streams made up of multiple rows are not supported in this release.'
    ||jtf_dbstring_utils.getLineFeed||jtf_dbstring_utils.getLineFeed||'rows: <'||nvl(to_char(inputStream.COUNT),jtf_dbstring_utils.getNullString)||'>');
    app_exception.raise_exception;
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.checkForCommonErrors :'||SQLERRM);
	  app_exception.raise_exception;
end checkForCommonErrors;
------------------------------------------------------------------------------

function readNextString return varchar2 is
  leadingDelimiterPos   pls_integer := readerCharIndex;
  trailingDelimiterPos  pls_integer;
  stringLength          integer;
begin
  checkForCommonErrors;
  if leadingDelimiterPos > length(inputStream(readerRowIndex))
  and readerRowIndex >= inputStream.COUNT then
    raise END_OF_STREAM;
  elsif leadingDelimiterPos > length(inputStream(readerRowIndex))
  and readerRowIndex < inputStream.COUNT then
    readerRowIndex := inputStream.NEXT(readerRowIndex);
    readerCharIndex := 1;
    leadingDelimiterPos := 1;
  end if;
  if instr(inputStream(readerRowIndex),leadingDelimiter,leadingDelimiterPos) <> leadingDelimiterPos then
    raise INVALID_DELIMITER;
  end if;
  trailingDelimiterPos := getTrailingDelimiterPos(readerRowIndex,leadingDelimiterPos);
  if trailingDelimiterPos is null then
    raise INVALID_STREAM;
  end if;
  stringLength := getStringLength(readerRowIndex,leadingDelimiterPos,trailingDelimiterPos);
  readerCharIndex := trailingDelimiterPos + stringLength + 1;
  readerPosition := readerPosition + 1;
  return substr(inputStream(readerRowIndex),trailingDelimiterPos + 1,stringLength);
exception
  when END_OF_STREAM then
    fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
    fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_dbstream_utils.readNextString: The end of the stream has been reached.');
    app_exception.raise_exception;
  when INVALID_DELIMITER then
    fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
    fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_dbstream_utils.readNextString: Invalid delimiter at:'
    ||jtf_dbstring_utils.getLineFeed||jtf_dbstring_utils.getLineFeed||'position: <'||nvl(to_char(leadingDelimiterPos),jtf_dbstring_utils.getNullString)||'>'
    ||jtf_dbstring_utils.getLineFeed||'row: <'||nvl(to_char(readerRowIndex),jtf_dbstring_utils.getNullString)||'>'
    ||jtf_dbstring_utils.getLineFeed||jtf_dbstring_utils.getLineFeed||'in stream <'||inputStream(readerRowIndex)||'>');
    app_exception.raise_exception;
  when INVALID_STREAM then
    fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
    fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_dbstream_utils.readNextString: Invalid readerPositition:'
    ||jtf_dbstring_utils.getLineFeed||jtf_dbstring_utils.getLineFeed||'readerPosition: <'||nvl(to_char(readerPosition),jtf_dbstring_utils.getNullString)||'>'
    ||jtf_dbstring_utils.getLineFeed||'row: <'||nvl(to_char(readerRowIndex),jtf_dbstring_utils.getNullString)||'>'
    ||jtf_dbstring_utils.getLineFeed||jtf_dbstring_utils.getLineFeed||'for stream <'||inputStream(readerRowIndex)||'>');
    app_exception.raise_exception;
--	when others then
--	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
--	  fnd_message.set_token('MSG','jtf_dbstream_utils.readNextString :'||SQLERRM);
--	  app_exception.raise_exception;
end readNextString;


------------------------------------------------------------------------------
--  update the readerIndexes. Should be called when the
--  readerPosition is manually changed.
--
--   NOTE: THE READER AND WRITER UTILS ONLY SUPPORT STREAMS UP TO 32767 BYTES
--         AND ONE ROW IN THE STREAM IN THIS VERSION.
-----------------------------------------------------------------------------
procedure updateReaderIndexes(newReaderPos in pls_integer) is
  i integer := 1;
  dummy jtf_dbstring_utils.maxString%TYPE;
begin
  initInputStreamVariables;
  while i < newReaderPos loop
  	dummy := readNextString;
  	i := i + 1;
  end loop;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.updateReaderIndexes :'||SQLERRM);
	  app_exception.raise_exception;
end updateReaderIndexes;


procedure writeNextString(s in varchar2) is
  stringLength integer := nvl(length(s),0);
  newString    jtf_dbstring_utils.maxString%TYPE := leadingDelimiter || to_char(stringLength) || trailingDelimiter || s;
begin
	if outputStream.COUNT = 0 then
		writerRowIndex := 1;
		outputStream(writerRowIndex) := null;
	end if;
	-- if (length(outputStream(writerRowIndex)) + length(newString)) > jtf_dbstring_utils.getMaxStringLength then

        --The length method is changed to lengthb to fix bug#2613658
        if (lengthb(outputStream(writerRowIndex)) + lengthb(newString)) > MAX_STREAM_LENGTH then
		writerRowIndex := writerRowIndex + 1;
		outputStream(writerRowIndex) := null;
	end if;
  outputStream(writerRowIndex) := outputStream(writerRowIndex) || newString;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeNextString :'||SQLERRM);
	  app_exception.raise_exception;
end writeNextString;

------------------------------------------------------------------------------
--  PUBLIC METHODS
-----------------------------------------------------------------------------


procedure setLongInputStream(stream in streamType) is
begin
	clearInputStream;
	inputStream := stream;
	initInputStreamVariables;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.setLongInputStream :'||SQLERRM);
	  app_exception.raise_exception;
end setLongInputStream;

-----------------------------------------------------------------------------
procedure setInputStream(stream in varchar2) is
begin
	clearInputStream;
	inputStream(1) := stream;
	initInputStreamVariables;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.setInputStream :'||SQLERRM);
	  app_exception.raise_exception;
end setInputStream;
-----------------------------------------------------------------------------
procedure setReaderPosition(i in pls_integer) is
begin
 updateReaderIndexes(i);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.setReaderPosition :'||SQLERRM);
	  app_exception.raise_exception;
end setReaderPosition;
-----------------------------------------------------------------------------
function endOfInputStream return boolean is
begin
  if  readerRowIndex <= inputStream.COUNT
  and	readerCharIndex < length(inputStream(readerRowIndex)) then
  	return false;
  else
  	return true;
  end if;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.endOfInputStream :'||SQLERRM);
	  app_exception.raise_exception;
end endOfInputStream;
-----------------------------------------------------------------------------
function  readString   return varchar2 is
begin
	return readNextString;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readString :'||SQLERRM);
	  app_exception.raise_exception;
end readString;
-----------------------------------------------------------------------------
function  readDate     return date is
begin
  return fnd_date.displaydate_to_date(readNextString);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readDate :'||SQLERRM);
	  app_exception.raise_exception;
end readDate;
-----------------------------------------------------------------------------
function  readDateTime return date is
begin
 	return fnd_date.displayDT_to_date(readNextString);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readDateTime :'||SQLERRM);
	  app_exception.raise_exception;
end readDateTime;
-----------------------------------------------------------------------------
function  readBoolean  return boolean is
begin
  return jtf_dbstring_utils.getBoolean(readNextString);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readBoolean :'||SQLERRM);
	  app_exception.raise_exception;
end readBoolean;
-----------------------------------------------------------------------------
function  readInt      return integer is
begin
	return to_number(readNextString);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readInt :'||SQLERRM);
	  app_exception.raise_exception;
end readInt;
-----------------------------------------------------------------------------
function  readNumber   return number is
begin
	return to_number(readNextString);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readNumber :'||SQLERRM);
	  app_exception.raise_exception;
end readNumber;

-----------------------------------------------------------------------------
function  readCurrency(currencyCode in varchar2) return number is
begin
  return to_number(readNextString,fnd_currency.get_format_mask(currencyCode,jtf_dbstring_utils.getCurrencyFormatLength));
end readCurrency;

-----------------------------------------------------------------------------
function   getLongOutputStream return streamType is
begin
	return outPutStream;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.getLongOutputStream :'||SQLERRM);
	  app_exception.raise_exception;
end getLongOutputStream;
-----------------------------------------------------------------------------
function   getOutputStream return varchar2 is
begin
	return outputStream(outPutStream.FIRST);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.getOutputStream :'||SQLERRM);
	  app_exception.raise_exception;
end getOutputStream;
-----------------------------------------------------------------------------
function   isLongOutputStream return boolean is
begin
	if outputStream.COUNT > 1 then
		return true;
	else
		return false;
	end if;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.isLongOutputStream :'||SQLERRM);
	  app_exception.raise_exception;
end isLongOutputStream;
-----------------------------------------------------------------------------

procedure  clearOutputStream is
begin
	outPutStream.DELETE;
	writerRowIndex := null;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.clearOutputStream :'||SQLERRM);
	  app_exception.raise_exception;
end clearOutputStream;
-----------------------------------------------------------------------------
procedure  writeString(s in varchar2) is
begin
	writeNextString(s);
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeString :'||SQLERRM);
	  app_exception.raise_exception;
end writeString;
-----------------------------------------------------------------------------
procedure  writeDate(d in date) is
begin
  writeNextString(fnd_date.date_to_displayDate(d));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeDate :'||SQLERRM);
	  app_exception.raise_exception;
end writeDate;
-----------------------------------------------------------------------------
procedure  writeDateTime(d in date) is
begin
  writeNextString(fnd_date.date_to_displayDT(d));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeDateTime :'||SQLERRM);
	  app_exception.raise_exception;
end writeDateTime;
-----------------------------------------------------------------------------
procedure  writeBoolean(b in boolean) is
begin
	writeNextString(jtf_dbstring_utils.getBooleanString(b));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeBoolean :'||SQLERRM);
	  app_exception.raise_exception;
end writeBoolean;
-----------------------------------------------------------------------------
procedure  writeInt(i in integer) is
begin
	writeNextString(to_char(i));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeInt :'||SQLERRM);
	  app_exception.raise_exception;
end writeInt;
-----------------------------------------------------------------------------
procedure  writeNumber(n in number) is
begin
	writeNextString(to_char(n));
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.writeNumber :'||SQLERRM);
	  app_exception.raise_exception;
end writeNumber;
-----------------------------------------------------------------------------

procedure  writeCurrency(c in number, currencyCode in varchar2) is
begin
  writeNextString(to_char(c,fnd_currency.get_format_mask(currencyCode,jtf_dbstring_utils.getCurrencyFormatLength)));
end writeCurrency;

----------------------------------------------------------------------------
FUNCTION getVersion RETURN VARCHAR2 IS
  BEGIN
    RETURN('$Header: JTFSTRMB.pls 115.10 2002/12/04 17:53:06 pseo ship $');  END getVersion;
-----------------------------------------------------------------------------

/** appends  inputList to the inputStream and returns the inputStream */
function addNumberToString(inputList in number,
                        inputStream in varchar2)
  return varchar2 is
begin
  if inputStream is not NULL then
     return inputStream||INT_SEPARATOR||to_char(inputList);
  else
     return to_char(inputList);
  end if;

exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.addNumberToString :'||SQLERRM);
	  app_exception.raise_exception;
end;
-----------------------------------------------------------------------------
/** appends all integers in inputList to the inputStream and returns the inputStream */
function addNumberToString(inputList in int_table,
                        inputStream in varchar2 := null)
  return varchar2 is

l_inputStream varchar2(32767) := inputStream;
begin
  for i in 1..inputList.count loop
    l_inputStream := addNumberToString(inputList(i), l_inputStream);
  end loop;

  return l_inputStream;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.addIntToString :'||SQLERRM);
	  app_exception.raise_exception;
end;
-----------------------------------------------------------------------------

/** returns an table of integers from a string */
function readFromString(inputStream in varchar2)
  return int_table is

l_number_list int_table;
l_inputStream varchar2(32767) := inputStream;
pos  pls_integer;
begin
  null;

  if l_inputStream is not NULL then
      pos := instr(l_inputStream,INT_SEPARATOR,1);
      while pos > 0 loop
       l_number_list(nvl(l_number_list.LAST,0) + 1) := to_number(substr(l_inputStream, 1, pos-1));
       l_inputStream := substr(l_inputStream, pos+1);
       pos := instr(l_inputStream,INT_SEPARATOR,1);
      end loop;
      l_number_list(nvl(l_number_list.LAST,0) + 1) := l_inputStream;
  end if;

  return l_number_list;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.readFromString :'||SQLERRM);
	  app_exception.raise_exception;
end;
-----------------------------------------------------------------------------


/** checks if an integer exists in the stream */
function checkNumberExists(inputStream in varchar2,
                           value       in number)
  return boolean is
l_inputStream varchar2(32767) := inputStream;
begin
  -- the current string is of the format 123:456:789
  -- we change it to :123:456:789: and look for the value we want
  -- this method is used so that the first and last numbers can be
  -- treated just like the any other number in the string.
  -- also, we need to test for :value: so that we do not return true
  -- for numbers that form a subset of the string e.g., 23

  l_inputStream := INT_SEPARATOR||l_inputStream||INT_SEPARATOR;
  if (INSTR(l_inputStream, INT_SEPARATOR||to_char(value)||INT_SEPARATOR) > 0) then
    return true;
  else
    return false;
  end if;

exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.checkNumberExists :'||SQLERRM);
	  app_exception.raise_exception;
end;
-----------------------------------------------------------------------------
/** removes the all occurances of the number from the string */
function removeFromString(inputStream in varchar2,
                          value       in number)
return varchar2 is

l_inputStream varchar2(32767) := inputStream;
begin

  -- the current string is of the format 123:456:789
  -- we change it to :123:456:789: and look for the value we want
  -- this method is used so that the first and last numbers can be
  -- treated just like the any other number in the string.
  -- also, we need to replace :value: with :

  l_inputStream := INT_SEPARATOR||l_inputStream||INT_SEPARATOR;
  l_inputStream := REPLACE(l_inputStream, INT_SEPARATOR||value||INT_SEPARATOR, INT_SEPARATOR);

  -- removing : at the beginning and end of the string

  l_inputStream := SUBSTR(l_inputStream, 2, length(l_inputStream)-2);

  return l_inputStream;
exception
	when others then
	  fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
	  fnd_message.set_token('SOURCE','JTF_DBSTREAM_UTILS');
	  fnd_message.set_token('MSG','jtf_dbstream_utils.removeFromString :'||SQLERRM);
	  app_exception.raise_exception;
end;



-----------------------------------------------------------------------------
END JTF_DBSTREAM_UTILS;

/
