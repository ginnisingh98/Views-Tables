--------------------------------------------------------
--  DDL for Package HRI_OPL_BDGTS_LBRCST_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BDGTS_LBRCST_ORGMGR" AUTHID CURRENT_USER AS
/* $Header: hrioblom.pkh 120.1 2005/06/29 07:02:21 ddutta noship $ */
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
END HRI_OPL_BDGTS_LBRCST_ORGMGR;

 

/