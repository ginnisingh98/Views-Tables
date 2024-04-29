--------------------------------------------------------
--  DDL for Package Body CSTPPOHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPOHK" AS
/* $Header: CSTPOHKB.pls 115.2 2002/11/11 19:16:08 awwang ship $ */

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE    							     |
|  	get_max_rows            					     |
| This routine will be called by period cost manager to determine the        |
| max number of rows to assign to the period cost worker.                    |
*----------------------------------------------------------------------------*/
PROCEDURE get_max_rows (
 	x_max_rows		OUT NOCOPY	NUMBER,
	x_err_num		OUT NOCOPY	NUMBER,
	x_err_code		OUT NOCOPY 	VARCHAR2,
	x_err_msg		OUT NOCOPY	VARCHAR2)
IS

l_stmt_num			NUMBER;
l_err_num			NUMBER;
l_err_code			VARCHAR2(240);
l_err_msg			VARCHAR2(240);

BEGIN
	----------------------------------------------------------------------
	-- Initialize Variables
	----------------------------------------------------------------------

	l_err_num := 0;
	l_err_code := '';
	l_err_msg := '';
	l_stmt_num := 5;

	x_max_rows := 500;

EXCEPTION

	WHEN OTHERS THEN
		ROLLBACK;
		x_err_num := SQLCODE;
		x_err_code := NULL;
		x_err_msg := SUBSTR('CSTPPOHK.get_max_rows('
				|| to_char(l_stmt_num)
				|| '): '
				||SQLERRM,1,240);
END get_max_rows;
END CSTPPOHK;


/
