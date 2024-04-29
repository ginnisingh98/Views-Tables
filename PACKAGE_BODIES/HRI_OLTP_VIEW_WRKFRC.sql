--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_WRKFRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_WRKFRC" AS
/* $Header: hriovwrk.pkb 120.2 2006/10/26 14:13:47 jtitmas noship $ */
--
  TYPE g_wrkfc_fk_rec_type IS RECORD
   (per_person_mgr_fk  NUMBER
   ,mgr_mngrsc_fk      NUMBER
   ,org_organztn_fk    NUMBER
   ,job_job_fk         NUMBER
   ,grd_grade_fk       NUMBER
   ,pos_position_fk    NUMBER
   ,geo_location_fk    NUMBER);
--
/******************************************************************************/
/* Calculates the ABV given a BMT code, business group and assignment         */
/******************************************************************************/
--
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_bmt_code          IN VARCHAR2,
                  p_effective_date    IN DATE)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN (hri_bpl_abv.calc_abv
           (p_assignment_id => p_assignment_id,
            p_business_group_id => p_business_group_id,
            p_budget_type => p_bmt_code,
            p_effective_date => p_effective_date));
  --
EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);
END calc_abv;
--
/******************************************************************************/
/* Calculates the ABV given a BMT code, business group and assignment         */
/******************************************************************************/
--
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_bmt_code       IN VARCHAR2,
                  p_effective_date    IN DATE,
                  p_primary_flag      IN VARCHAR2)
          RETURN NUMBER IS
  --
BEGIN
  --
  RETURN (hri_bpl_abv.calc_abv
           (p_assignment_id => p_assignment_id,
            p_business_group_id => p_business_group_id,
            p_budget_type => p_bmt_code,
            p_effective_date => p_effective_date,
            p_primary_flag => p_primary_flag));
  --
EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);
END calc_abv;
--
PROCEDURE get_wrkfc_fks(p_assignment_id   IN NUMBER,
                        p_effective_date  IN DATE,
                        p_wrkfc_fk_rec    OUT NOCOPY g_wrkfc_fk_rec_type) IS

  CURSOR wrkfc_fk_csr IS
  SELECT
   fct.per_person_mgr_fk
  ,fct.mgr_mngrsc_fk
  ,fct.org_organztn_fk
  ,fct.job_job_fk
  ,fct.grd_grade_fk
  ,fct.pos_position_fk
  ,fct.geo_location_fk
  FROM hri_mds_wrkfc_mnth_ct  fct
  WHERE fct.asg_assgnmnt_fk = p_assignment_id
  AND fct.time_month_snp_fk = to_number(to_char(p_effective_date, 'YYYYQMM'));

BEGIN

  OPEN wrkfc_fk_csr;
  FETCH wrkfc_fk_csr INTO
   p_wrkfc_fk_rec.per_person_mgr_fk,
   p_wrkfc_fk_rec.mgr_mngrsc_fk,
   p_wrkfc_fk_rec.org_organztn_fk,
   p_wrkfc_fk_rec.job_job_fk,
   p_wrkfc_fk_rec.grd_grade_fk,
   p_wrkfc_fk_rec.pos_position_fk,
   p_wrkfc_fk_rec.geo_location_fk;
  CLOSE wrkfc_fk_csr;

END get_wrkfc_fks;

FUNCTION get_sup_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.per_person_mgr_fk;

END get_sup_fk;
--
FUNCTION get_mgrsc_fk(p_assignment_id   IN NUMBER,
                      p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.mgr_mngrsc_fk;

END get_mgrsc_fk;
--
FUNCTION get_org_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.org_organztn_fk;

END get_org_fk;
--
FUNCTION get_job_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.job_job_fk;

END get_job_fk;
--
FUNCTION get_loc_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.geo_location_fk;

END get_loc_fk;
--
FUNCTION get_grd_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.grd_grade_fk;

END get_grd_fk;
--
FUNCTION get_pos_fk(p_assignment_id   IN NUMBER,
                    p_effective_date  IN DATE)
        RETURN NUMBER IS

  l_wrkfc_fk_rec       g_wrkfc_fk_rec_type;

BEGIN

  get_wrkfc_fks
   (p_assignment_id    => p_assignment_id,
    p_effective_date   => p_effective_date,
    p_wrkfc_fk_rec     => l_wrkfc_fk_rec);

  RETURN l_wrkfc_fk_rec.pos_position_fk;

END get_pos_fk;
--
FUNCTION get_hire_info(p_assignment_id        IN NUMBER,
                       p_effective_start_date IN DATE,
                       p_effective_end_date   IN DATE,
                       p_budget_type          IN VARCHAR2)
        RETURN NUMBER IS

  CURSOR hire_csr IS
  SELECT
   NVL(SUM(headcount_hire), 0)
  ,NVL(SUM(fte_hire), 0)
  FROM hri_mds_wrkfc_mnth_ct
  WHERE asg_assgnmnt_fk = p_assignment_id
  AND time_month_snp_fk BETWEEN to_number(to_char(p_effective_start_date, 'YYYYQMM'))
                        AND to_number(to_char(p_effective_end_date, 'YYYYQMM'));

  l_hdc  NUMBER;
  l_fte  NUMBER;

BEGIN

  OPEN hire_csr;
  FETCH hire_csr INTO l_hdc, l_fte;
  CLOSE hire_csr;

  IF p_budget_type = 'HEADCOUNT' THEN
    RETURN l_hdc;
  ELSIF p_budget_type = 'FTE' THEN
    RETURN l_fte;
  END IF;

  RETURN to_number(null);

END get_hire_info;

FUNCTION get_prmtn_info(p_assignment_id        IN NUMBER,
                        p_effective_start_date IN DATE,
                        p_effective_end_date   IN DATE,
                        p_budget_type          IN VARCHAR2)
        RETURN NUMBER IS

  CURSOR prmtn_csr IS
  SELECT
   NVL(SUM(headcount_prmtn), 0)
  ,NVL(SUM(fte_prmtn), 0)
  FROM hri_mds_wrkfc_mnth_ct
  WHERE asg_assgnmnt_fk = p_assignment_id
  AND time_month_snp_fk BETWEEN to_number(to_char(p_effective_start_date, 'YYYYQMM'))
                        AND to_number(to_char(p_effective_end_date, 'YYYYQMM'));

  l_hdc  NUMBER;
  l_fte  NUMBER;

BEGIN

  OPEN prmtn_csr;
  FETCH prmtn_csr INTO l_hdc, l_fte;
  CLOSE prmtn_csr;

  IF p_budget_type = 'HEADCOUNT' THEN
    RETURN l_hdc;
  ELSIF p_budget_type = 'FTE' THEN
    RETURN l_fte;
  END IF;

  RETURN to_number(null);

END get_prmtn_info;

FUNCTION get_hire_hdc(p_assignment_id        IN NUMBER,
                      p_effective_start_date IN DATE,
                      p_effective_end_date IN DATE)
        RETURN NUMBER IS

BEGIN

  RETURN get_hire_info
          (p_assignment_id => p_assignment_id,
           p_effective_start_date => p_effective_start_date,
           p_effective_end_date => p_effective_end_date,
           p_budget_type => 'HEADCOUNT');

END get_hire_hdc;
--
FUNCTION get_hire_fte(p_assignment_id        IN NUMBER,
                      p_effective_start_date IN DATE,
                      p_effective_end_date IN DATE)
        RETURN NUMBER IS

BEGIN

  RETURN get_hire_info
          (p_assignment_id => p_assignment_id,
           p_effective_start_date => p_effective_start_date,
           p_effective_end_date => p_effective_end_date,
           p_budget_type => 'FTE');

END get_hire_fte;
--
FUNCTION get_prmtn_hdc(p_assignment_id        IN NUMBER,
                       p_effective_start_date IN DATE,
                       p_effective_end_date IN DATE)
        RETURN NUMBER IS

BEGIN

  RETURN get_prmtn_info
          (p_assignment_id => p_assignment_id,
           p_effective_start_date => p_effective_start_date,
           p_effective_end_date => p_effective_end_date,
           p_budget_type => 'HEADCOUNT');

END get_prmtn_hdc;
--
FUNCTION get_prmtn_fte(p_assignment_id        IN NUMBER,
                       p_effective_start_date IN DATE,
                       p_effective_end_date IN DATE)
        RETURN NUMBER IS

BEGIN

  RETURN get_prmtn_info
          (p_assignment_id => p_assignment_id,
           p_effective_start_date => p_effective_start_date,
           p_effective_end_date => p_effective_end_date,
           p_budget_type => 'FTE');

END get_prmtn_fte;
--
END HRI_OLTP_VIEW_WRKFRC;

/
