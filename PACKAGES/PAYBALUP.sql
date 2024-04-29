--------------------------------------------------------
--  DDL for Package PAYBALUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYBALUP" AUTHID CURRENT_USER AS
/* $Header: paybalup.pkh 120.0 2005/05/29 02:33 appldev noship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991-1995 All rights reserved.
--
--
/*
   NAME
      paybalup.pkh      -- Create a structure for balance upload.
--
   USAGE
      See package body.
--
   DESCRIPTION
      See package body.
--
   MODIFIED   (DD-MON-YYYY)
   T Grisco    14-SEP-1995	Created.
   T Grisco    03-OCT-1995	Removed a parameter from procedure call.
   J ALLOUN    30-JUL-1996      Added error handling.
   T Habara    15-JUL-2004 115.1   Added nocopy. GSCC standards.
*/

   PROCEDURE create_bal_upl_struct (errbuf		OUT nocopy varchar2,
				    retcode		OUT nocopy number,
				    p_input_value_limit	number,
				    p_batch_id		number);

END paybalup;

 

/
