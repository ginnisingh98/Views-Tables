--------------------------------------------------------
--  DDL for Package ARRX_BSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_BSS" AUTHID CURRENT_USER AS
/* $Header: ARRXBSS.pls 115.2 2002/11/15 03:09:27 anukumar ship $ */

  PROCEDURE arrxbss_report(p_request_id                  IN NUMBER
                          ,p_user_id                     IN NUMBER
                          ,p_reporting_level             IN VARCHAR2
                          ,p_reporting_entity_id         IN NUMBER
                          ,p_as_of_date                  IN DATE
                          ,retcode                       OUT NOCOPY NUMBER
                          ,errbuf                        OUT NOCOPY VARCHAR2);


END arrx_bss;

 

/
