--------------------------------------------------------
--  DDL for Package HRI_BPL_REC_PIPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_REC_PIPLN" AUTHID CURRENT_USER AS
/* $Header: hribrec.pkh 120.1.12000000.2 2007/04/12 12:07:32 smohapat noship $ */

FUNCTION get_stage_code(p_event_code      IN VARCHAR2)
        RETURN VARCHAR2;

FUNCTION get_event_seq(p_event_code      IN VARCHAR2)
        RETURN NUMBER;

FUNCTION get_stage_code
      (p_system_status   IN VARCHAR2,
       p_user_status     IN VARCHAR2,
       p_status_id       IN NUMBER)
     RETURN VARCHAR2;

FUNCTION get_event_code
      (p_system_status   IN VARCHAR2,
       p_user_status     IN VARCHAR2,
       p_status_id       IN NUMBER)
     RETURN VARCHAR2;

FUNCTION get_appl_term_type(p_appl_term_rsn IN VARCHAR2)
     RETURN VARCHAR2;

END hri_bpl_rec_pipln;

 

/
