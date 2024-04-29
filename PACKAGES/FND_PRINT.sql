--------------------------------------------------------
--  DDL for Package FND_PRINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PRINT" AUTHID CURRENT_USER as
/* $Header: AFPRGPIS.pls 120.2 2005/08/19 20:14:19 ckclark ship $ */


    /*
    **  AOL Internal use only.
    **  INITIALIZE - initialize printer, type, and style tables.
    **
    **  procedure INITIALIZE;
    */

    /*
    **  AOL Internal use only.
    **  STYLE_INFORMATION - returns TRUE if a style with the same name
    **                      is found. Returns width and length too.
    **
    **    function STYLE_INFORMATION(STYLE in varchar2,
    **			 	WIDTH out nocopy number, LENGTH out nocopy number)
    **				return boolean;
    */

    /*
    **  AOL Internal use only.
    **  PRINTER_INFORMATION - returns TRUE if a printer's type has a
    **                        style that is assigned to it.
    **
    **    function PRINTER_INFORMATION(PRINTER in varchar2,
    **			 STYLE in varchar2) return boolean;
    */

    /*
    **  GET_STYLE - returns the value of a valid style that matches
    **              the dimensions passed in, and that matches the
    **              printer specifications.
    ** 		    returns TRUE if successful.
    */
    function GET_STYLE(STYLE in  varchar2,
 		        MINWIDTH  in number, MAXWIDTH  in number,
			MINLENGTH in number, MAXLENGTH in number,
			REQUIRED in boolean, PRINTER in varchar2,
			VALIDSTYLE out nocopy varchar2) return boolean;

end FND_PRINT;

 

/
