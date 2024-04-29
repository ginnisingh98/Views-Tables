--------------------------------------------------------
--  DDL for Package Body AP_CREDIT_CARD_TRXN_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CREDIT_CARD_TRXN_LOADER_PKG" AS
/* $Header: apwccldb.pls 115.3 2002/12/26 10:10:39 srinvenk ship $ */

/*
  Written by:
    Ron Langi

  Purpose:
    Due to limitations in SQL*Loader certain file formats of
    card issuers need to be preformatted prior to loading of the
    transaction records

  Input:
    p_indatafilename - input of preformat
    p_outdatafilename - output of preformat
    p_cardbrand - card brand of input file

  Output:
    errbuf - contains error message; required by Concurrent Manager
    retcode - contains return code; required by Concurrent Manager

  Input/Output:

  Assumption:
    If datafile to be preformatted is from GE Capitol MasterCard,
    the datafile must be of format 5000 financial transaction record.

    If datafile to be preformatted is from US Bank Visa,
    the datafile must be of US Bank Visa transaction record.

*/
PROCEDURE Preformat(errbuf out nocopy varchar2,
               retcode out nocopy number,
               p_indatafilename in varchar2,
               p_outdatafilename in varchar2,
               p_cardbrand in varchar2) IS

l_indatapathname varchar2(240);
l_indatafilename varchar2(240);
l_indatafileptr utl_file.file_type;
l_outdatapathname varchar2(240);
l_outdatafilename varchar2(240);
l_outdatafileptr utl_file.file_type;
l_ntdir number;
l_unixdir number;
l_line varchar2(1000);
l_numrecs number;

BEGIN

  --
  -- Parse the indatafilename for the path and filename
  --
  fnd_file.put_line(fnd_file.log, 'Parsing p_indatafilename '|| p_indatafilename);
  l_ntdir := instrb(p_indatafilename, '\', -1);
  l_unixdir := instrb(p_indatafilename, '/', -1);
  if (l_ntdir > 0) then
    l_indatapathname := substrb(p_indatafilename, 0, l_ntdir-1);
    l_indatafilename := substrb(p_indatafilename, l_ntdir+1);
  elsif (l_unixdir > 0) then
    l_indatapathname := substrb(p_indatafilename, 0, l_unixdir-1);
    l_indatafilename := substrb(p_indatafilename, l_unixdir+1);
  else
    l_indatapathname := '';
    l_indatafilename := p_indatafilename;
  end if;
  fnd_file.put_line(fnd_file.log, 'l_ntdir '|| to_char(l_ntdir));
  fnd_file.put_line(fnd_file.log, 'l_unixdir '|| to_char(l_unixdir));
  fnd_file.put_line(fnd_file.log, 'l_indatapathname '|| l_indatapathname);
  fnd_file.put_line(fnd_file.log, 'l_indatafilename '|| l_indatafilename);

  --
  -- Parse the outdatafilename for the path and filename
  --
  fnd_file.put_line(fnd_file.log, 'Parsing p_outdatafilename '|| p_outdatafilename);
  l_ntdir := instrb(p_outdatafilename, '\', -1);
  l_unixdir := instrb(p_outdatafilename, '/', -1);
  if (l_ntdir > 0) then
    l_outdatapathname := substrb(p_outdatafilename, 0, l_ntdir-1);
    l_outdatafilename := substrb(p_outdatafilename, l_ntdir+1);
  elsif (l_unixdir > 0) then
    l_outdatapathname := substrb(p_outdatafilename, 0, l_unixdir-1);
    l_outdatafilename := substrb(p_outdatafilename, l_unixdir+1);
  else
    l_outdatapathname := '';
    l_outdatafilename := p_outdatafilename;
  end if;
  fnd_file.put_line(fnd_file.log, 'l_ntdir '|| to_char(l_ntdir));
  fnd_file.put_line(fnd_file.log, 'l_unixdir '|| to_char(l_unixdir));
  fnd_file.put_line(fnd_file.log, 'l_outdatapathname '|| l_outdatapathname);
  fnd_file.put_line(fnd_file.log, 'l_outdatafilename '|| l_outdatafilename);

  --
  -- Open the in/outdatafiles for read/write
  --
  fnd_file.put_line(fnd_file.log, 'Opening p_indatafilename '|| p_indatafilename);
  l_indatafileptr := utl_file.fopen(l_indatapathname, l_indatafilename, 'r');
  fnd_file.put_line(fnd_file.log, 'Opening p_outdatafilename '|| p_outdatafilename);
  l_outdatafileptr := utl_file.fopen(l_outdatapathname, l_outdatafilename, 'w');

  fnd_file.put_line(fnd_file.log, 'p_cardbrand '|| p_cardbrand);
  l_numrecs := 0;
  --
  -- Preformat MasterCard by duplicating the addendum type which
  -- is stored in position(44-46) in the transaction record
  --
  if (p_cardbrand = 'MasterCard') then
    loop
      begin
        utl_file.get_line(l_indatafileptr, l_line);
        utl_file.put_line(l_outdatafileptr, substrb(l_line, 0, 43) || substrb(l_line, 44, 3) || substrb(l_line, 44, 3) || substrb(l_line, 47));
        l_numrecs := l_numrecs + 1;
      exception
        when no_data_found then
          exit;
      end;
    end loop;
  --
  -- Preformat Visa by duplicating position(1-2) in the transaction record
  --
  elsif (p_cardbrand = 'Visa') then
    loop
      begin
        utl_file.get_line(l_indatafileptr, l_line);
        utl_file.put_line(l_outdatafileptr, substrb(l_line, 0, 2) || l_line);
        l_numrecs := l_numrecs + 1;
      exception
        when no_data_found then
          exit;
      end;
    end loop;
  end if;
  fnd_file.put_line(fnd_file.log, 'Number of records preformatted  '|| to_char(l_numrecs));

  --
  -- Close the in/outdatafiles
  --
  fnd_file.put_line(fnd_file.log, 'Closing p_indatafilename '|| p_indatafilename);
  utl_file.fclose(l_indatafileptr);
  fnd_file.put_line(fnd_file.log, 'Closing p_outdatafilename '|| p_outdatafilename);
  utl_file.fclose(l_outdatafileptr);

  EXCEPTION
    WHEN OTHERS THEN
      utl_file.fclose_all;
      fnd_message.set_name('AK', 'AK_INVALID_FILE_OPERATION');
      errbuf := fnd_message.get;
      retcode := 2;

END Preformat;

END AP_CREDIT_CARD_TRXN_LOADER_PKG;

/
