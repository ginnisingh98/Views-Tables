--------------------------------------------------------
--  DDL for Package HRI_OPL_SUPH_HST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_SUPH_HST" AUTHID CURRENT_USER AS
/* $Header: hrioshh.pkh 120.0.12000000.2 2007/04/12 13:17:58 smohapat noship $ */

PROCEDURE pre_process(p_mthd_action_id   IN NUMBER,
                      p_sqlstr           OUT NOCOPY VARCHAR2);

PROCEDURE process_range(errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_mthd_action_id   IN NUMBER,
                        p_mthd_range_id    IN NUMBER,
                        p_start_object_id  IN NUMBER,
                        p_end_object_id    IN NUMBER);

PROCEDURE post_process(p_mthd_action_id  IN NUMBER);


PROCEDURE full_refresh_single;

PROCEDURE incremental_refresh_single;

PROCEDURE run_for_person(p_person_id  IN NUMBER);

END hri_opl_suph_hst;

 

/
