--------------------------------------------------------
--  DDL for Package FND_PUB_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PUB_MESSAGE" AUTHID DEFINER as
/* $Header: AFCPPMSS.pls 115.2 99/07/16 23:12:40 porting ship  $ */
procedure set_name(	app in varchar2,
			name in varchar2);

procedure set_token(	token in varchar2,
			value in varchar2,
			xlate in boolean default FALSE);

procedure set_integer_token(	token in varchar2,
				value in number);

procedure get(		buff in out varchar2);

end;

 

/

  GRANT EXECUTE ON "APPS"."FND_PUB_MESSAGE" TO "APPLSYSPUB";
