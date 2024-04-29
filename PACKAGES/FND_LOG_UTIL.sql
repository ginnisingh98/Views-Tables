--------------------------------------------------------
--  DDL for Package FND_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFUTLBES.pls 115.6 2002/12/04 20:20:00 rmohan noship $ */


  /*
   **  MTERIC_EVENT_PENDING_METRICS
   **  Description:
   **  Concurrent program to post event for crashed components metrics.
   **
   **  Arguments:
   **
   **  Returns:
   **      errbuf - CPM error message
   **      retcode - CPM return code (0 = success, 1 = warning, 2 = error)
   **
   */
 procedure METRIC_EVENT_PENDING_METRICS(errbuf OUT NOCOPY VARCHAR2
      , retcode OUT NOCOPY VARCHAR2);





 --Testers
--- procedure SYNC_EXP_DATA;
--- procedure TEST_PURGE(age in varchar2);

 END FND_LOG_UTIL;

 

/
