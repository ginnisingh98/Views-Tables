--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_WRKFRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_WRKFRC" AUTHID CURRENT_USER AS
/* $Header: hriovwrk.pkh 120.2 2006/10/26 14:14:10 jtitmas noship $ */
--
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_bmt_code       IN VARCHAR2,
                  p_effective_date    IN DATE)
          RETURN NUMBER;
--
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_bmt_code       IN VARCHAR2,
                  p_effective_date    IN DATE,
                  p_primary_flag      IN VARCHAR2)
          RETURN NUMBER;
--
FUNCTION get_sup_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_mgrsc_fk(p_assignment_id   IN NUMBER,
                      p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_org_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_job_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_loc_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_grd_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_pos_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER;
--
FUNCTION get_hire_hdc(p_assignment_id        IN NUMBER,
                      p_effective_start_date IN DATE,
                      p_effective_end_date IN DATE)
        RETURN NUMBER;
--
FUNCTION get_hire_fte(p_assignment_id        IN NUMBER,
                      p_effective_start_date IN DATE,
                      p_effective_end_date IN DATE)
        RETURN NUMBER;
--
FUNCTION get_prmtn_hdc(p_assignment_id        IN NUMBER,
                       p_effective_start_date IN DATE,
                       p_effective_end_date IN DATE)
        RETURN NUMBER;
--
FUNCTION get_prmtn_fte(p_assignment_id        IN NUMBER,
                       p_effective_start_date IN DATE,
                       p_effective_end_date IN DATE)
        RETURN NUMBER;
--
END HRI_OLTP_VIEW_WRKFRC;

/
