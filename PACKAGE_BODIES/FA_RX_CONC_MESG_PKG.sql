--------------------------------------------------------
--  DDL for Package Body FA_RX_CONC_MESG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_CONC_MESG_PKG" as
/* $Header: farxmsgb.pls 120.1.12010000.2 2009/07/19 13:41:38 glchen ship $ */


procedure log (
	buff	in	varchar2) is

begin
   fnd_file.put(FND_FILE.LOG,buff);
      fnd_file.new_line(FND_FILE.LOG,1);

exception when others then return;

end log;




procedure out (
	buff	in	varchar2) is

begin


   fnd_file.put(FND_FILE.OUTPUT,buff);
    fnd_file.new_line(FND_FILE.OUTPUT,1);


exception when others then return;

end out;

END FA_RX_CONC_MESG_PKG;

/
