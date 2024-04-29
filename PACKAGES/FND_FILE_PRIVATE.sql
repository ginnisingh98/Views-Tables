--------------------------------------------------------
--  DDL for Package FND_FILE_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FILE_PRIVATE" AUTHID CURRENT_USER as
/* $Header: AFCPPPRS.pls 120.2 2005/08/22 06:55:12 aweisber ship $ */


procedure OPEN(LOGFILE in out NOCOPY varchar2, OUTFILE in out NOCOPY varchar2);

procedure LOGFILE_GET(STATUS in out NOCOPY varchar2,
			TEXT in out NOCOPY varchar2);

procedure OUTFILE_GET(STATUS in out NOCOPY varchar2,
			TEXT in out NOCOPY varchar2);

procedure PUT_NAMES(P_LOG in varchar2, P_OUT in varchar2, P_DIR in varchar2);

procedure CLOSE;


end FND_FILE_PRIVATE;

 

/
