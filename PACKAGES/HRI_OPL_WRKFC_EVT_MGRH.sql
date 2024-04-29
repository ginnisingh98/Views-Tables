--------------------------------------------------------
--  DDL for Package HRI_OPL_WRKFC_EVT_MGRH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_WRKFC_EVT_MGRH" AUTHID CURRENT_USER AS
/* $Header: hriowevtmgr.pkh 120.1.12000000.2 2007/04/12 13:23:35 smohapat noship $ */

PROCEDURE pre_process(p_mthd_action_id  IN NUMBER,
                      p_sqlstr          OUT NOCOPY VARCHAR2);

PROCEDURE post_process(p_mthd_action_id  IN NUMBER);

PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2
                       ,retcode            OUT NOCOPY NUMBER
                       ,p_mthd_action_id   IN NUMBER
                       ,p_mthd_range_id    IN NUMBER
                       ,p_mthd_range_lvl   IN NUMBER
                       ,p_start_object_id  IN NUMBER
                       ,p_end_object_id    IN NUMBER);

PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2);

END hri_opl_wrkfc_evt_mgrh;

 

/
