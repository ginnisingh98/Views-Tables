--------------------------------------------------------
--  DDL for Package HRI_OPL_CMNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_CMNTS" AUTHID CURRENT_USER AS
/* $Header: hriocmnt.pkh 120.2 2005/08/11 06:51:35 ddutta noship $ */
--
-- Pre Processor Procedure require for HRI Multithreading
--
PROCEDURE pre_process(
  p_mthd_action_id             IN             NUMBER,
  p_sqlstr                         OUT NOCOPY VARCHAR2);
--
-- Process Range Procedure require for HRI Multithreading
--
PROCEDURE process_range(
   errbuf                          OUT NOCOPY VARCHAR2
  ,retcode                         OUT NOCOPY NUMBER
  ,p_mthd_action_id            IN             NUMBER
  ,p_mthd_range_id             IN             NUMBER
  ,p_start_object_id           IN             NUMBER
  ,p_end_object_id             IN             NUMBER);
--
-- Post Processor Procedure require for HRI Multithreading
--
PROCEDURE post_process (p_mthd_action_id NUMBER);
--
-- Test Harness
--
PROCEDURE load_table;
--
END HRI_OPL_CMNTS;

 

/
