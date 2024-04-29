--------------------------------------------------------
--  DDL for Package QLTTRAMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTTRAMB" AUTHID CURRENT_USER as
/* $Header: qlttramb.pls 115.8 2002/11/28 00:24:28 jezheng ship $ */

-- 1/23/96 - CREATED
-- Paul Mishkin

-- Added Argument4 for "Gather Statistics" Parameter.
-- bug2141009. kabalakr 4 feb 2002.

   PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                     RETCODE OUT NOCOPY NUMBER,
                     ARGUMENT1 IN VARCHAR2,
		     ARGUMENT2 IN VARCHAR2,
		     ARGUMENT3 IN VARCHAR2,
		     ARGUMENT4 IN VARCHAR2);

   PROCEDURE TRANSACTION_MANAGER(WORKER_ROWS NUMBER,
                     ARGUMENT2 VARCHAR2,
		     ARGUMENT3 VARCHAR2,
                     ARGUMENT4 VARCHAR2);

END QLTTRAMB;


 

/
