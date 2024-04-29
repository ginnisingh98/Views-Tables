--------------------------------------------------------
--  DDL for Package CSTPPOHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPOHK" AUTHID CURRENT_USER AS
/* $Header: CSTPOHKS.pls 115.2 2002/11/11 19:16:22 awwang ship $ */

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
	x_err_msg		OUT NOCOPY	VARCHAR2);

END CSTPPOHK;

 

/
