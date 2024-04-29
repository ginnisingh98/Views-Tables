--------------------------------------------------------
--  DDL for Package BSC_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: BSCUMSGS.pls 120.0 2005/06/01 16:26:21 appldev noship $ */

--
-- Initializes the message stack.  All the messages are deleted,
-- regardless of the message types.
--
Procedure Init (
	x_debug_flag	IN	Varchar2 := 'NO'
);

Procedure Reset (
	x_debug_flag	IN	Varchar2 := NULL
);

--
-- Function Count
-- x_type:
--   NULL: returns the number of all the messages on stack
--      0: returns the number of type 0 messages on stack(fatal error)
--      1: returns the number of type 1 messages on stack(error)
--      2: returns the number of type 2 messages on stack(warning)
--      3: returns the number of type 3 messages on stack(information)
--      4: returns the number of type 4 messages on stack(debug messages)
--
Function Count(
	x_type		IN	 Number := NULL
) Return Number;

Procedure Add (
	x_message	IN	Varchar2,
	x_source	IN	Varchar2,
	x_type		IN	Number := 0,
   	x_mode		IN	Varchar2 := 'N'
);

Procedure Flush;

Procedure Clean;

Procedure Show;

END BSC_MESSAGE;

 

/
