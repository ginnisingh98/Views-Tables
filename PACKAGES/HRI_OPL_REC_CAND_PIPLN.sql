--------------------------------------------------------
--  DDL for Package HRI_OPL_REC_CAND_PIPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_REC_CAND_PIPLN" AUTHID CURRENT_USER AS
/* $Header: hriprpipln.pkh 120.1.12000000.2 2007/04/12 13:28:13 smohapat noship $ */

FUNCTION get_merged_person_fk
      (p_vac_manager_irec   IN NUMBER,
       p_vac_recruiter   IN NUMBER,
       p_req_raised_by   IN NUMBER,
       p_vac_org_id      IN NUMBER,
       p_vac_bgr_id      IN NUMBER)
    RETURN NUMBER;

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

PROCEDURE process_assignment(p_asg_id    IN NUMBER);

END hri_opl_rec_cand_pipln;

 

/
