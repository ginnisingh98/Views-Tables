--------------------------------------------------------
--  DDL for Package Body EDW_HR_PRSN_TYP_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PRSN_TYP_M_SIZING" AS
/* $Header: hriezpty.pkb 120.1 2005/06/08 02:49:16 anmajumd noship $ */
/******************************************************************************/
/* Sets p_row_count to the number of rows which would be collected between    */
/* the given dates                                                            */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Cursor description */
  CURSOR row_count_cur IS
  SELECT count(person_type_pk) total
  FROM hri_person_type_cmbns
  WHERE NVL(last_update_date, to_date('01-01-2000','DD-MM-YYYY'))
  BETWEEN p_from_date AND p_to_date;

BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;

/******************************************************************************/
/* Estimates row lengths.                                                     */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date        IN  DATE,
                               p_to_date          IN  DATE,
                               p_avg_row_length   OUT NOCOPY NUMBER )

IS

  x_date                NUMBER :=7;

  x_total_pty           NUMBER;

x_person_type_pk             NUMBER:=0;
x_name                       NUMBER:=0;
x_person_type_dp             NUMBER:=0;
x_instance                   NUMBER:=0;
x_pw_employee_type           NUMBER:=0;
x_dh_permanent_type          NUMBER:=0;
x_dh_intern_type             NUMBER:=0;
x_dh_fxd_trm_lower_type      NUMBER:=0;
x_dh_fxd_trm_upper_type      NUMBER:=0;
x_cw_agncy_cntrctr_type      NUMBER:=0;
x_cw_self_employed_type      NUMBER:=0;
x_cw_consultant_type         NUMBER:=0;
x_pw_ex_employee_type        NUMBER:=0;
x_pw_applicant_type          NUMBER:=0;
x_nw_dependent_type          NUMBER:=0;
x_nw_retiree_type            NUMBER:=0;
x_nw_beneficiary_type        NUMBER:=0;
x_srviving_fmly_mbr_type     NUMBER:=0;
x_srviving_spouse_type       NUMBER:=0;
x_ex_applicant_type          NUMBER:=0;
x_other_type                 NUMBER:=0;
x_participant_type           NUMBER:=0;
x_former_spouse_type         NUMBER:=0;
x_former_fmly_mbr_type       NUMBER:=0;
x_last_update_date           NUMBER:=x_date;
x_creation_date              NUMBER:=x_date;

x_avg_flag                   NUMBER:=0;

x_yes			     NUMBER :=0;
x_no                         NUMBER :=0;

/* Select the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl( vsize(instance_code),0 ))
  FROM edw_local_instance;


/* Get lengths of person type attributes */
  CURSOR pty_cur IS
  SELECT
   avg(nvl(vsize(person_type_pk),0))
  ,avg(nvl(vsize(employee),0))
  ,avg(nvl(vsize(permanent),0))
  ,avg(nvl(vsize(intern),0))
  ,avg(nvl(vsize(fixed_term_lower),0))
  ,avg(nvl(vsize(fixed_term_upper),0))
  ,avg(nvl(vsize(agency),0))
  ,avg(nvl(vsize(self_employed),0))
  ,avg(nvl(vsize(consultant),0))
  ,avg(nvl(vsize(ex_employee),0))
  ,avg(nvl(vsize(applicant),0))
  ,avg(nvl(vsize(dependent),0))
  ,avg(nvl(vsize(retiree),0))
  ,avg(nvl(vsize(beneficiary),0))
  ,avg(nvl(vsize(surviving_family_member),0))
  ,avg(nvl(vsize(surviving_spouse),0))
  ,avg(nvl(vsize(ex_applicant),0))
  ,avg(nvl(vsize(other),0))
  ,avg(nvl(vsize(participant),0))
  ,avg(nvl(vsize(former_spouse),0))
  ,avg(nvl(vsize(former_family_member),0))
  FROM hri_person_type_cmbns
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

CURSOR yes_no_cur IS
SELECT
  avg(nvl(vsize(hr_general.decode_lookup('YES_NO','Y')),0))
 ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO','N')),0))
FROM dual;

BEGIN

  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

OPEN pty_cur;
  FETCH pty_cur INTO
   x_person_type_pk
  ,x_pw_employee_type
  ,x_dh_permanent_type
  ,x_dh_intern_type
  ,x_dh_fxd_trm_lower_type
  ,x_dh_fxd_trm_upper_type
  ,x_cw_agncy_cntrctr_type
  ,x_cw_self_employed_type
  ,x_cw_consultant_type
  ,x_pw_ex_employee_type
  ,x_pw_applicant_type
  ,x_nw_dependent_type
  ,x_nw_retiree_type
  ,x_nw_beneficiary_type
  ,x_srviving_fmly_mbr_type
  ,x_srviving_spouse_type
  ,x_ex_applicant_type
  ,x_other_type
  ,x_participant_type
  ,x_former_spouse_type
  ,x_former_fmly_mbr_type;
  CLOSE pty_cur;

  OPEN yes_no_cur;
  FETCH yes_no_cur INTO x_yes, x_no;
  CLOSE yes_no_cur;

  x_person_type_pk := x_person_type_pk + x_instance;
  x_name           := x_person_type_pk;
  x_person_type_dp := x_person_type_pk;

  x_avg_flag := ((x_yes+x_no)/2);

  x_total_pty:=

    NVL(ceil(x_person_type_pk + 1), 0)
  + NVL(ceil(x_name + 1), 0)
  + NVL(ceil(x_person_type_dp + 1), 0)
  + NVL(ceil(x_instance + 1), 0)
  + NVL(ceil(x_pw_employee_type + 1), 0)
  + NVL(ceil(x_dh_permanent_type + 1), 0)
  + NVL(ceil(x_dh_intern_type + 1), 0)
  + NVL(ceil(x_dh_fxd_trm_lower_type + 1), 0)
  + NVL(ceil(x_dh_fxd_trm_upper_type + 1), 0)
  + NVL(ceil(x_cw_agncy_cntrctr_type + 1), 0)
  + NVL(ceil(x_cw_self_employed_type + 1), 0)
  + NVL(ceil(x_cw_consultant_type + 1), 0)
  + NVL(ceil(x_pw_ex_employee_type + 1), 0)
  + NVL(ceil(x_pw_applicant_type + 1), 0)
  + NVL(ceil(x_nw_dependent_type + 1), 0)
  + NVL(ceil(x_nw_retiree_type + 1), 0)
  + NVL(ceil(x_nw_beneficiary_type + 1), 0)
  + NVL(ceil(x_srviving_fmly_mbr_type + 1), 0)
  + NVL(ceil(x_srviving_spouse_type + 1), 0)
  + NVL(ceil(x_ex_applicant_type + 1), 0)
  + NVL(ceil(x_other_type + 1), 0)
  + NVL(ceil(x_participant_type + 1), 0)
  + NVL(ceil(x_former_spouse_type + 1), 0)
  + NVL(ceil(x_former_fmly_mbr_type + 1), 0)
  + NVL(ceil(x_last_update_date + 1), 0)
  + NVL(ceil(x_creation_date + 1), 0)
  + (26 * NVL(ceil(x_avg_flag + 1), 0));

/* TOTAL */

  p_avg_row_length :=  x_total_pty;

  END estimate_row_length;

END edw_hr_prsn_typ_m_sizing;

/
