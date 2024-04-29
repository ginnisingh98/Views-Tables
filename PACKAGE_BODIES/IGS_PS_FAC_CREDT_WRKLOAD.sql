--------------------------------------------------------
--  DDL for Package Body IGS_PS_FAC_CREDT_WRKLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FAC_CREDT_WRKLOAD" AS
 /* $Header: IGSPS74B.pls 120.1 2006/02/16 08:47:08 sommukhe noship $
   CHANGE HISTORY
   WHO               : jbegum
   WHEN              : 02-June-2003
   WHAT              : modified functions calc_total_work_load_lecture,calc_total_work_load_lab
                       and calc_total_work_load as part of bug#2972950
   WHO               : ayedubat
   WHEN              : 24-MAY-2001
   WHAT              : Added two new Functions ,calc_total_work_load_lab and
                       calc_total_work_load_lecture
   CHANGE HISTORY
   WHO               : pradhakr
   WHEN              : 05-Jun-2001
   WHAT              : Added one new Function ,calc_teach_work_load
   Who       When         What
   smvk      29-Apr-2004  Bug # 3568858. Created the function validate_workload and get_validation_type.
  ***********************************************************************************************/



  FUNCTION prgp_get_lead_instructor(
   p_uoo_id IN NUMBER)
   RETURN VARCHAR2
  IS

  /*************************************************************
  Created By : venagara
  Date Created By : 10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  sommukhe  14-FEB-2006  Bug #3104276, replaced igs_pe_person with igs_pe_person_base_v for cursor cur_lead_instructor
  ***************************************************************/

  CURSOR cur_lead_instructor IS
  SELECT     pe.last_name  || ',  ' || pe.title  || '  ' || NVL(pe.known_as,pe.first_name) instructor_name
  FROM   igs_ps_usec_tch_resp utr,
         igs_pe_person_base_v pe,
         igs_pe_person_id_typ ppi,
         igs_pe_alt_pers_id pit
  WHERE  utr.instructor_id = pe.person_id AND
         utr.uoo_id = p_uoo_id  AND
         pe.person_id = pit.pe_person_id (+) AND
         pit.person_id_type = ppi.person_id_type AND
         ppi.preferred_ind  = 'Y' AND
         utr.lead_instructor_flag = 'Y';
 /* In this query, the IGS_PE_PERSON_V was demormalised to prevent pragma
    restriction error */

  lv_instructor_name VARCHAR2(30) DEFAULT NULL;

  BEGIN
    FOR cur_leads IN cur_lead_instructor LOOP
      lv_instructor_name := cur_leads.instructor_name;
    END LOOP;

    RETURN lv_instructor_name;

  END prgp_get_lead_instructor;


  FUNCTION calc_total_credit_point (
    p_instructor_id IN NUMBER)
  RETURN NUMBER IS

  /*************************************************************
  Created By : venagara
  Date Created By : 10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When    /        What
  sarakshi     24-Jun-2003   Enh#2930935,removed the cursor cur_unit_version ad modified
                             cursor cur_cp and the usage of the cursor accordingly
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_uoo (cp_instructor_id IN NUMBER) IS
    SELECT   DISTINCT (uoo_id) uoo_id
    FROM     igs_ps_usec_tch_resp utr
    WHERE    instructor_id = cp_instructor_id;

  CURSOR cur_cp (cp_uoo_id IN VARCHAR2) IS
    SELECT  NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points
    FROM    igs_ps_unit_ver uv,
            igs_ps_unit_ofr_opt uoo,
            igs_ps_usec_cps cps
    WHERE   uoo.uoo_id=cps.uoo_id(+)
    AND     uoo.unit_cd=uv.unit_cd
    AND     uoo.version_number=uv.version_number
    AND     uoo.uoo_id=cp_uoo_id;

  lv_credit_points       NUMBER DEFAULT 0;
  lv_total_credit_points NUMBER DEFAULT 0;

  BEGIN

    FOR cur_uoos IN cur_uoo (p_instructor_id) LOOP
        FOR cur_cps IN cur_cp (cur_uoos.uoo_id) LOOP
          lv_total_credit_points := lv_total_credit_points + cur_cps.enrolled_credit_points;
        END LOOP;
    END LOOP;

    RETURN lv_total_credit_points;

 END calc_total_credit_point;

 FUNCTION calc_total_work_load (
    p_instructor_id IN NUMBER)
 RETURN NUMBER IS

  /*************************************************************
  Created By : venagara
  Date Created By : 10-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  jbegum       02-June-2003    Enh#2972950,modified the cursor cur_wl

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_wl (cp_instructor_id IN NUMBER) IS
    SELECT   SUM(instructional_load) total_work_load
    FROM     igs_ps_usec_tch_resp utr
    WHERE    utr.confirmed_flag='Y'
    AND      utr.instructor_id = cp_instructor_id;

  lv_total_work_load NUMBER := 0;
  BEGIN
    FOR cur_wls IN cur_wl(p_instructor_id) LOOP
      lv_total_work_load := cur_wls.total_work_load;
    END LOOP;
    RETURN lv_total_work_load;
  END calc_total_work_load;

  FUNCTION calc_total_work_load_lab (
    p_instructor_id IN NUMBER)
  RETURN NUMBER IS

  /*************************************************************
  Created By : ayedubat
  Date Created By : 24-May-2001
  Purpose :According to the enhancements proposed in PSP001-US DLD.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  jbegum       02-June-2003    Enh#2972950,modified the cursor cur_wl_lab

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_wl_lab (cp_instructor_id IN NUMBER) IS
    SELECT   SUM(instructional_load_lab) total_work_load_lab
    FROM     igs_ps_usec_tch_resp utr
    WHERE    utr.confirmed_flag='Y'
    AND      utr.instructor_id = cp_instructor_id;

  lv_total_work_load_lab NUMBER := 0;
  BEGIN
    -- caluculating the total lab work load
    FOR cur_wls_lab IN cur_wl_lab(p_instructor_id) LOOP
      lv_total_work_load_lab := cur_wls_lab.total_work_load_lab;
    END LOOP;
    RETURN lv_total_work_load_lab;
  END calc_total_work_load_lab;

 FUNCTION calc_total_work_load_lecture (
    p_instructor_id IN NUMBER)
 RETURN NUMBER IS

  /*************************************************************
  Created By : ayedubat
  Date Created By : 24-May-2001
  Purpose :According to the enhancements proposed in PSP001-US DLD.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  jbegum       02-June-2003    Enh#2972950,modified the cursor cur_wl_lecture

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_wl_lecture (cp_instructor_id IN NUMBER) IS
    SELECT   SUM(instructional_load_lecture) total_work_load_lecture
    FROM     igs_ps_usec_tch_resp utr
    WHERE    utr.confirmed_flag='Y'
    AND      utr.instructor_id = cp_instructor_id;

  lv_total_work_load_lecture NUMBER DEFAULT 0;
 BEGIN
   -- caluculating the total lab work lecture
   FOR cur_wls_lecture IN cur_wl_lecture(p_instructor_id) LOOP
     lv_total_work_load_lecture := cur_wls_lecture.total_work_load_lecture;
   END LOOP;
   RETURN lv_total_work_load_lecture;
 END calc_total_work_load_lecture;

  PROCEDURE calculate_teach_work_load (
  				   p_uoo_id 		 IN   igs_ps_usec_tch_resp_v.uoo_id%TYPE,
  				   p_percent_allocation  IN   igs_ps_usec_tch_resp_v.percentage_allocation%TYPE,
  				   p_wl_lab 		 OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load_lab%TYPE,
  				   p_wl_lecture 	 OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load_lecture%TYPE,
  				   p_wl_other 		 OUT NOCOPY  igs_ps_usec_tch_resp_v.instructional_load%TYPE
                         	 ) IS

 ------------------------------------------------------------------
  --Created by  : pradhakr, Oracle IDC
  --Date created: 05/06/2001
  --
  --Purpose:
  --   This procedure calculates the workload if there is any
  --    change in the percentage allocation.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk        01-Oct-2003     Bug # 3164752. Added the cursor c_unit_workload and it usage.
  -------------------------------------------------------------------

  CURSOR cur_workload IS
  SELECT work_load_cp_lecture,
  	 work_load_cp_lab,
  	 work_load_other
  FROM   igs_ps_usec_cps uscp
  WHERE  uscp.uoo_id = p_uoo_id;

 CURSOR c_unit_workload (cp_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT work_load_cp_lecture,
  	 work_load_cp_lab,
  	 work_load_other
  FROM   igs_ps_unit_ver_all unit,
         igs_ps_unit_ofr_opt_all usec
  WHERE  unit.unit_cd = usec.unit_cd
  AND    unit.version_number = usec.version_number
  AND    usec.uoo_id = cp_n_uoo_id;

  l_cur_workload_row cur_workload%ROWTYPE;
  rec_unit_workload c_unit_workload%ROWTYPE;

  BEGIN
   OPEN cur_workload;
   FETCH cur_workload INTO l_cur_workload_row;
   IF cur_workload%FOUND THEN
      p_wl_lecture := ((p_percent_allocation/100) * l_cur_workload_row.work_load_cp_lecture);
      p_wl_lab     := ((p_percent_allocation/100) * l_cur_workload_row.work_load_cp_lab);
      p_wl_other   := ((p_percent_allocation/100) * l_cur_workload_row.work_load_other);
   ELSE -- Added as a part of
      OPEN c_unit_workload(p_uoo_id);
      FETCH c_unit_workload INTO rec_unit_workload;
      IF c_unit_workload%FOUND THEN
         p_wl_lecture := ((p_percent_allocation/100) * rec_unit_workload.work_load_cp_lecture);
         p_wl_lab     := ((p_percent_allocation/100) * rec_unit_workload.work_load_cp_lab);
         p_wl_other   := ((p_percent_allocation/100) * rec_unit_workload.work_load_other);
      END IF;
      CLOSE c_unit_workload;
   END IF;
   CLOSE cur_workload;

  END calculate_teach_work_load;

  FUNCTION validate_workload(p_n_uoo_id IN NUMBER,
			     p_n_tot_wl_lec OUT NOCOPY NUMBER,
			     p_n_tot_wl_lab OUT NOCOPY NUMBER,
			     p_n_tot_wl OUT NOCOPY NUMBER) RETURN BOOLEAN IS

  /***********************************************************************************************

  Created By:         smvk
  Date Created By:    29-Apr-2004
  Purpose:            This procedure validates the workload defined for the instructors in unit section teaching responsibilites
                      should match with the workload defined for the unit section in unit section credit points.
		      if the unit section credit points is not defined it should match with workload defined at unit level(As per Inheritance logic).
		      Procedure returns true if the values matches otherwise false.

  Known limitations,enhancements,remarks:

  Change History
  sarakshi  14-May-2004  bug#3629483, added NVL to the cursor c_usec_workload and c_unit_workload
  Who       When         What
  ***********************************************************************************************/

  -- Cursor to pick up lecture / laboratory / Other workload from unit section level
  CURSOR c_usec_workload (cp_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT NVL(work_load_cp_lecture,-999),
  	 NVL(work_load_cp_lab,-999),
  	 NVL(work_load_other,-999)
  FROM   igs_ps_usec_cps uscp
  WHERE  uscp.uoo_id = cp_n_uoo_id;

  -- Cursor to pick up lecture / laboratory / Other workload from unit section level
 CURSOR c_unit_workload (cp_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
  SELECT NVL(work_load_cp_lecture,-999),
  	 NVL(work_load_cp_lab,-999),
  	 NVL(work_load_other,-999)
  FROM   igs_ps_unit_ver_all unit,
         igs_ps_unit_ofr_opt_all usec
  WHERE  unit.unit_cd = usec.unit_cd
  AND    unit.version_number = usec.version_number
  AND    usec.uoo_id = cp_n_uoo_id;

  -- Cursor to pick up lecture / laboratory / other workload defined at unit section teaching responsibility.
  CURSOR c_tr_workload(cp_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT NVL(SUM (instructional_load_lecture),-999) lecture_workload,
           NVL(SUM (instructional_load_lab),-999) laboratory_workload,
	   NVL(SUM (instructional_load),-999) other_workload
    FROM   igs_ps_usec_tch_resp
    WHERE  uoo_id = cp_n_uoo_id
    AND    confirmed_flag = 'Y';

  rec_tr_workload c_tr_workload%ROWTYPE;

  BEGIN
    -- get the workloads defined at unit section level (igs_ps_usec_cps).
    OPEN c_usec_workload (p_n_uoo_id);
    FETCH c_usec_workload INTO p_n_tot_wl_lec, p_n_tot_wl_lab, p_n_tot_wl;
    IF c_usec_workload%NOTFOUND THEN
      -- get the workloads defined at unit level (igs_ps_unit_ver_all) as per inheritance logic.
      OPEN c_unit_workload (p_n_uoo_id);
      FETCH c_unit_workload INTO p_n_tot_wl_lec, p_n_tot_wl_lab, p_n_tot_wl;
      CLOSE c_unit_workload;
    END IF;
    CLOSE c_usec_workload;

    -- get the confirmed workloads defined at unit section teaching responsibilities.
    OPEN c_tr_workload (p_n_uoo_id);
    FETCH c_tr_workload INTO rec_tr_workload;
    CLOSE c_tr_workload;

    /* Returns true if the workload defined at unit section teaching responsibilites matches
    -- with workload defined at unit section credit points( As per inheritance if unit section
    -- credit points is not defined at unit section then pick up the workload defined at unit version).
    -- Retuns false if the workloads doesn't match. */
    IF (rec_tr_workload.lecture_workload    =   p_n_tot_wl_lec AND
        rec_tr_workload.laboratory_workload =   p_n_tot_wl_lab AND
        rec_tr_workload.other_workload      =   p_n_tot_wl    ) THEN
      RETURN TRUE;
    END IF;

    RETURN FALSE;

  END validate_workload;

  FUNCTION get_validation_type(p_c_unit_cd IN VARCHAR2,
                               p_n_ver_num IN NUMBER) RETURN VARCHAR2 IS
  /***********************************************************************************************

  Created By:         smvk
  Date Created By:    29-Apr-2004
  Purpose:            This procedure get the unit section teaching responsibility validation type.
                      if the validation type is overriden at unit version level then returns the validation type set at unit level.
		      if the validation type is not overriden at unit version level then returns the validation type set in the site level profile "IGS: Unit Section Teaching Responsibility Validation".
		      if the validation type is not overriden at unit version level, as well as the profile is not set it retuns 'DENY' as validation type.

  Known limitations,enhancements,remarks:

  Change History

  Who       When         What
  ***********************************************************************************************/

    CURSOR c_workload_val (cp_c_unit_cd igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
                           cp_n_version_num igs_ps_unit_ofr_opt_all.version_number%TYPE) IS
    SELECT workload_val_code
    FROM   igs_ps_unit_ver_all
    WHERE  unit_cd = cp_c_unit_cd
    AND    version_number = cp_n_version_num
    AND    ovrd_wkld_val_flag = 'Y'
    AND    ROWNUM <2;

    l_c_validation_type igs_ps_unit_ver_all.workload_val_code%TYPE;

  BEGIN
     OPEN c_workload_val(p_c_unit_cd, p_n_ver_num);
     FETCH c_workload_val INTO l_c_validation_type;
     IF c_workload_val%NOTFOUND THEN
       l_c_validation_type := fnd_profile.value('IGS_PS_WKLD_VAL');
     END IF;
     CLOSE c_workload_val;
     return NVL(l_c_validation_type,'DENY');
  END get_validation_type;


END igs_ps_fac_credt_wrkload;

/
