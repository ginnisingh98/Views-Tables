--------------------------------------------------------
--  DDL for Package JS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JS" AUTHID CURRENT_USER as
/* $Header: ICXJAVAS.pls 120.2 2005/10/07 13:27:28 gjimenez noship $ */

procedure numeric_characters;

-- functions and procedure for the start and end of javascript
  function   scriptOpen
  	return varchar2;
  procedure  scriptOpen;
  function   scriptClose
	return varchar2;
  procedure  scriptClose;

-- function and proceduer for the start and end of a javascript form
  function formOpen
	return varchar2;
  procedure formOpen;

-- procedure for the DynamicButton
  procedure dynamicButton;

-- function and procedures for the button
  function button (name varchar2, value varchar2, onClick varchar2)
	return varchar2;
  procedure button (name varchar2, value varchar2, onClick varchar2);

-- function and procedure for the checkbox
  function checkbox (name varchar2, value varchar2, onClick varchar2,
		     checked boolean)
	return varchar2;
  procedure checkbox (name varchar2, value varchar2, onClick varchar2,
                     checked boolean);

-- function and procedure for the text area
  function text (name varchar2, value varchar2,
		 sizze integer, onBlur varchar2, onChange varchar2,
		 onFocus varchar2, onSelect varchar2)
	return varchar2;

  procedure text (name varchar2, value varchar2,
                 sizze integer, onBlur varchar2, onChange varchar2,
                 onFocus varchar2, onSelect varchar2);

-- The following procedure places a money_decimal script into the html
  procedure money_decimal(precision number);

-- The following procedure places a MakeArray script into the html
  procedure arrayCreate;

-- The following procedure places checkNumber into the html
  procedure checkNumber;

-- The following procedure will replace " with \" in any string
  procedure replaceDbQuote;

-- The following procedure places checkNumberValue into the html
  procedure checkValue;

-- The following procedure places checkNumberValue into the html
  procedure checkValuePos;

-- The following procedure places the null_alert function in the html
/* This is a generic function that displays a javascript alert
   and returns true if the value parameter is null, otherwise it
   returns false                                              */
  procedure null_alert;

-- The following procedure places the spaces_alert function in the html
/* This is a generic function that displays a javascript alert
   and returns true if the value parameter contains spaces, otherwise it
   returns false                                              */
  procedure spaces_alert;

-- equal_alert place a javascript function in the html header
-- This is a generic function that accepts two parameters
-- The function will display a javascript alert and return true
-- if the two parameters are equal
  procedure equal_alert;


  procedure format_number;

end js;

 

/
