--------------------------------------------------------
--  DDL for Package Body ICX_SIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_SIG" AS
/* $Header: ICXSESIB.pls 120.1 2005/10/07 14:25:17 gjimenez noship $ */

procedure logo Is
begin
        htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
                cattributes => 'BORDER=0');
end;

function logo return varchar2 is
begin
        return htf.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
                       cattributes => 'BORDER=0');
end;

function background return varchar2 is
begin
	return '/OA_MEDIA/ICXBCKGR.jpg';
end;

procedure footer is
begin
/*
	htp.address('Please send any questions or comments to '
             ||htf.mailto('WebApps@us.oracle.com','WebApps@us.oracle.com'));
*/
	htp.bodyClose;
end;

function footer return varchar2 is
begin
	return	htf.line;
/*
		||
		htf.address('Please send any questions or comments to '||
		htf.mailto('WebApps@us.oracle.com','WebApps@us.oracle.com'));
*/

end;

end icx_sig;

/
