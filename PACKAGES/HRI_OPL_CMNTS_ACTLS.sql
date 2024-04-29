--------------------------------------------------------
--  DDL for Package HRI_OPL_CMNTS_ACTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_CMNTS_ACTLS" AUTHID CURRENT_USER AS
/* $Header: hriocact.pkh 120.1 2005/06/29 07:01:17 ddutta noship $ */
--
-- Process Procedure called from Concurrent Program
--
PROCEDURE process(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_full_refresh_flag              IN        VARCHAR2);
--
-- Test Harness
--
PROCEDURE load_table;
--
END HRI_OPL_CMNTS_ACTLS;

 

/
