--------------------------------------------------------
--  DDL for Package HRI_OPL_BDGTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BDGTS" AUTHID CURRENT_USER AS
/* $Header: hriobdgt.pkh 120.1 2005/06/29 07:00:31 ddutta noship $ */
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
END HRI_OPL_BDGTS;

 

/
