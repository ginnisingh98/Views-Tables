--------------------------------------------------------
--  DDL for Package FND_OAM_TESTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_TESTER" AUTHID CURRENT_USER AS
/* $Header: AFOAMTESTERS.pls 115.1 2003/01/07 17:21:54 rmohan noship $ */

---Common Constants

  /*
   ** Test transaction times for transaction manager.
   **
   **  Arguments:
   **
   **  Returns:
   **      oSessionId - Database Session Id,
   **      oTestDuration - time to complete test in mili sec,
   **      oerr1 - error message 1 if any(message from send request to servere)
   **      oerr2 - error message 2 if any(message from get parameters from server
   **
   */
   procedure test_tm_debug(oSessionId out NOCOPY number
      , oTestDuration out NOCOPY number, oerr1 out NOCOPY varchar2
      , oerr2 out NOCOPY varchar2 );




 END FND_OAM_TESTER;

 

/
