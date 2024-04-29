--------------------------------------------------------
--  DDL for Package HRI_BPL_ASG_SUMMARIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_ASG_SUMMARIZATION" AUTHID CURRENT_USER AS
/* $Header: hribasum.pkh 120.0 2005/10/05 22:31:43 anmajumd noship $ */
--
g_warning_flag VARCHAR2(30);
--
FUNCTION ff_exists_and_compiled(p_business_group_id     IN NUMBER
			       ,p_date                  IN DATE
			       ,p_ff_name               IN VARCHAR2)
RETURN NUMBER;
--
FUNCTION is_summarization_rqd(p_assignment_id IN NUMBER,
                              p_effective_date IN DATE)
RETURN VARCHAR2;
--
END hri_bpl_asg_summarization;

 

/
