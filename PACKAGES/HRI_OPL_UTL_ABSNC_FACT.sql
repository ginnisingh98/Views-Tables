--------------------------------------------------------
--  DDL for Package HRI_OPL_UTL_ABSNC_FACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_UTL_ABSNC_FACT" AUTHID CURRENT_USER AS
/* $Header: hriouabf.pkh 120.0 2005/09/20 01:19:10 jtitmas noship $ */

PROCEDURE pre_process(p_mthd_action_id  IN NUMBER,
                      p_sqlstr          OUT NOCOPY VARCHAR2);

PROCEDURE post_process(p_mthd_action_id  IN NUMBER);

PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2
                       ,retcode            OUT NOCOPY NUMBER
                       ,p_mthd_action_id   IN NUMBER
                       ,p_mthd_range_id    IN NUMBER
                       ,p_start_object_id  IN NUMBER
                       ,p_end_object_id    IN NUMBER);

PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2);

END hri_opl_utl_absnc_fact;

 

/
