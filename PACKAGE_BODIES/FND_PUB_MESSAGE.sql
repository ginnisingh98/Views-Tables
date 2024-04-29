--------------------------------------------------------
--  DDL for Package Body FND_PUB_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PUB_MESSAGE" as
/* $Header: AFCPPMSB.pls 115.1 99/07/16 23:12:37 porting sh $ */
procedure set_name(	app in varchar2,
			name in varchar2)
is
begin
	fnd_message.set_name(app, name);
end set_name;

procedure set_integer_token(	token in varchar2,
				value in number)
is
begin
	fnd_message.set_token(token, to_char(value), FALSE);
end set_integer_token;

procedure set_token(	token in varchar2,
			value in varchar2,
			xlate in boolean default FALSE)
is
begin
	fnd_message.set_token(token, value, xlate);
end set_token;

procedure get(		buff in out varchar2)
is
begin
	buff := fnd_message.get;
end get;

end;

/

  GRANT EXECUTE ON "APPS"."FND_PUB_MESSAGE" TO "APPLSYSPUB";
