--------------------------------------------------------
--  DDL for Package QLTACTWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTACTWB" AUTHID CURRENT_USER as
/* $Header: qltactwb.pls 115.4 2004/02/18 14:57:18 suramasw ship $ */

-- 2/8/95 - CREATED
-- Kevin Wiggen

--  This is a wrapper for DO_ACTIONS.  It is needed for the concurrent
--  manager to run

  -- Added ARGUMENT2 in the signature of WRAPPER.
  -- Bug 3273447. suramasw

  PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
		    RETCODE OUT NOCOPY NUMBER,
		    ARGUMENT1 IN NUMBER,
                    ARGUMENT2 IN VARCHAR2 DEFAULT NULL);


END QLTACTWB;


 

/
