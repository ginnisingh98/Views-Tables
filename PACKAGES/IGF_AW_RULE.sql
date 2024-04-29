--------------------------------------------------------
--  DDL for Package IGF_AW_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_RULE" AUTHID CURRENT_USER AS
/* $Header: IGFAW04S.pls 115.7 2002/11/28 14:11:39 nsidana ship $ */

-- History :
--Bug ID   :2613546
--adhawan             28-OCT-2002     The Run procedure has been modified with the new parameters
--                                    p_grp_code for  Target Group assignment
--                                    p_pergrp_id for processing of all students belonging to the Person ID Group
--                                    p_base_id has been removed
--                                    The process RUN would be used for Assignment of Target Groups and not Cost of attendace groups
--                                    The process tgroup_rule has been modified to have p_pergrp_id instead of p_base_id and p_grp_code added
--                                    All the processing associated with the Rules has been obsoleted.
-- Bug ID  : 1818617
-- who                 when            what
------------------------------------------------------------------------
-- sjadhav             24-jul-2001     added parameter p_get_recent_info
--
------------------------------------------------------------------------
--

PROCEDURE run   ( errbuf              OUT NOCOPY VARCHAR2,
                 retcode              OUT NOCOPY NUMBER,
                 l_award_year         IN  VARCHAR2 ,
                 p_grp_code           IN  igf_aw_target_grp.group_cd%TYPE,
                 p_pergrp_id          IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                 p_org_id             IN  NUMBER
                       );


 PROCEDURE tgroup_rule(p_ci_cal_type        in igf_aw_target_grp.cal_type%TYPE ,
                       p_ci_sequence_number in igf_aw_target_grp.sequence_number%TYPE,
                       p_pergrp_id          IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                       p_grp_code           IN  igf_aw_target_grp.group_cd%TYPE) ;

END IGF_AW_RULE;

 

/
