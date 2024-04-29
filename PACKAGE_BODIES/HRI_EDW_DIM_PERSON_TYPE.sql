--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_PERSON_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_PERSON_TYPE" AS
/* $Header: hriedpty.pkb 120.1 2006/03/29 02:55:20 anmajumd noship $ */

g_employee           hri_person_type_cmbns.employee%TYPE;
g_applicant          hri_person_type_cmbns.applicant%TYPE;
g_permanent          hri_person_type_cmbns.permanent%TYPE;
g_fixed_term_lower   hri_person_type_cmbns.fixed_term_lower%TYPE;
g_fixed_term_upper   hri_person_type_cmbns.fixed_term_upper%TYPE;
g_intern             hri_person_type_cmbns.intern%TYPE;
g_ex_employee        hri_person_type_cmbns.ex_employee%TYPE;
g_ex_applicant       hri_person_type_cmbns.ex_applicant%TYPE;
g_dependent          hri_person_type_cmbns.dependent%TYPE;
g_beneficiary        hri_person_type_cmbns.beneficiary%TYPE;
g_retiree            hri_person_type_cmbns.retiree%TYPE;
g_contact            hri_person_type_cmbns.contact%TYPE;
g_srvivng_fmly_mbr   hri_person_type_cmbns.surviving_family_member%TYPE;
g_srvivng_spouse     hri_person_type_cmbns.surviving_spouse%TYPE;
g_former_fmly_mbr    hri_person_type_cmbns.former_family_member%TYPE;
g_former_spouse      hri_person_type_cmbns.former_spouse%TYPE;
g_other              hri_person_type_cmbns.other%TYPE;
g_participant        hri_person_type_cmbns.participant%TYPE;
g_employee_student   hri_person_type_cmbns.employee_student%TYPE;
g_consultant         hri_person_type_cmbns.consultant%TYPE;
g_agency             hri_person_type_cmbns.agency%TYPE;
g_self_employed      hri_person_type_cmbns.self_employed%TYPE;


/******************************************************************************/
/* This procedure is used to build up a person type combination for a person. */
/* It takes a user person type and corresponding system person type belonging */
/* to a person, and populates global variables appropriately. User defined    */
/* combinations are held in the table hri_edw_user_person_types               */
/******************************************************************************/
PROCEDURE test_person_type( p_system_person_type   IN VARCHAR2,
                            p_user_person_type     IN VARCHAR2) IS

  l_map_to_type         VARCHAR2(30);

  CURSOR user_type_cur IS
  SELECT map_to_type
  FROM hri_edw_user_person_types
  WHERE system_person_type = p_system_person_type
  AND user_person_type = p_user_person_type;

BEGIN

  OPEN user_type_cur;
  FETCH user_type_cur INTO l_map_to_type;
  IF (user_type_cur%NOTFOUND OR user_type_cur%NOTFOUND IS NULL) THEN
  /* Person Type not mapped so split out system person types */
    IF p_system_person_type = 'APL' THEN
      g_applicant := p_user_person_type;
    ELSIF p_system_person_type = 'APL_EX_APL' THEN
      g_applicant := p_user_person_type;
      g_ex_applicant := p_user_person_type;
    ELSIF p_system_person_type = 'BNF' THEN
      g_beneficiary := p_user_person_type;
    ELSIF p_system_person_type = 'DPNT' THEN
      g_dependent := p_user_person_type;
    ELSIF p_system_person_type = 'EMP' THEN
      g_employee := p_user_person_type;
    ELSIF p_system_person_type = 'EMP_APL' THEN
      g_applicant := p_user_person_type;
      g_employee := p_user_person_type;
    ELSIF p_system_person_type = 'EX_APL' THEN
      g_ex_applicant := p_user_person_type;
    ELSIF p_system_person_type = 'EX_EMP' THEN
      g_ex_employee := p_user_person_type;
    ELSIF p_system_person_type = 'EX_EMP_APL' THEN
      g_applicant := p_user_person_type;
      g_ex_employee := p_user_person_type;
    ELSIF p_system_person_type = 'FRMR_FMLY_MMBR' THEN
      g_former_fmly_mbr := p_user_person_type;
    ELSIF p_system_person_type = 'FRMR_SPS' THEN
      g_former_spouse := p_user_person_type;
    ELSIF p_system_person_type = 'OTHER' THEN
      g_other := p_user_person_type;
    ELSIF p_system_person_type = 'PRTN' THEN
      g_participant := p_user_person_type;
    ELSIF p_system_person_type = 'RETIREE' THEN
      g_retiree := p_user_person_type;
    ELSIF p_system_person_type = 'SRVNG_FMLY_MMBR' THEN
      g_srvivng_fmly_mbr := p_user_person_type;
    ELSIF p_system_person_type = 'SRVNG_SPS' THEN
      g_srvivng_spouse := p_user_person_type;
    END IF;
  ELSE
    IF (l_map_to_type = 'AGENCY_CONTRACTOR') THEN
      g_agency := p_user_person_type;
    ELSIF (l_map_to_type = 'CONSULTANT') THEN
      g_consultant := p_user_person_type;
    ELSIF (l_map_to_type = 'SELF_EMP_CONTRACTOR') THEN
      g_self_employed := p_user_person_type;
    ELSIF (l_map_to_type = 'FIX_TERM_UPPER') THEN
      g_fixed_term_upper := p_user_person_type;
    ELSIF (l_map_to_type = 'FIX_TERM_LOWER') THEN
      g_fixed_term_lower := p_user_person_type;
    ELSIF (l_map_to_type = 'INTERN') THEN
      g_intern := p_user_person_type;
    ELSIF (l_map_to_type = 'PERMANENT') THEN
      g_permanent := p_user_person_type;
    END IF;
  END IF;
  CLOSE user_type_cur;

END test_person_type;


/******************************************************************************/
/* Function to identify the person type combination of a given person at a    */
/* given time                                                                 */
/******************************************************************************/
FUNCTION construct_person_type_pk( p_person_id   IN NUMBER,
                             p_effective_date  IN DATE)
                   RETURN VARCHAR2 IS

  l_person_type_pk       VARCHAR2(2000);

  /* Retrieves all the person types associated with the person for the date */
  CURSOR type_usages_cur IS
  /* Person type usages includes basic person type */
  SELECT ppt.system_person_type, ppt.user_person_type
  FROM per_person_type_usages_f ptu
  ,per_person_types ppt
  WHERE ptu.person_id = p_person_id
  AND TRUNC(p_effective_date)
      BETWEEN ptu.effective_start_date AND ptu.effective_end_date
  AND ptu.person_type_id = ppt.person_type_id;

  /* Student status flag */
  CURSOR student_cur IS
  SELECT DECODE(student_status,null,null,'Y')
  FROM per_all_people_f
  WHERE TRUNC(p_effective_date)
        BETWEEN effective_start_date AND effective_end_date
  AND p_person_id = person_id;

BEGIN

  /* Reset all global variables */
  g_employee         := NULL;
  g_applicant        := NULL;
  g_permanent        := NULL;
  g_fixed_term_lower := NULL;
  g_fixed_term_upper := NULL;
  g_intern           := NULL;
  g_ex_employee      := NULL;
  g_ex_applicant     := NULL;
  g_dependent        := NULL;
  g_beneficiary      := NULL;
  g_retiree          := NULL;
  g_contact          := NULL;
  g_srvivng_fmly_mbr := NULL;
  g_srvivng_spouse   := NULL;
  g_former_fmly_mbr  := NULL;
  g_former_spouse    := NULL;
  g_other            := NULL;
  g_participant      := NULL;
  g_employee_student := NULL;
  g_consultant       := NULL;
  g_agency           := NULL;
  g_self_employed    := NULL;

  /* Loop through person types */
  FOR usage_record IN type_usages_cur LOOP

    /* Populate global variables corresponding to person type */
    test_person_type(usage_record.system_person_type,usage_record.user_person_type);

    /* Populate global variable with student status if person is an employee */
    IF (usage_record.system_person_type = 'EMP') THEN
      OPEN student_cur;
      FETCH student_cur INTO g_employee_student;
      CLOSE student_cur;
    END IF;

  END LOOP;

  /* Compose person type pk */
  l_person_type_pk :=
     g_employee         || '-' ||
     g_applicant        || '-' ||
     g_permanent        || '-' ||
     g_fixed_term_lower || '-' ||
     g_fixed_term_upper || '-' ||
     g_intern           || '-' ||
     g_ex_employee      || '-' ||
     g_ex_applicant     || '-' ||
     g_dependent        || '-' ||
     g_beneficiary      || '-' ||
     g_retiree          || '-' ||
     g_contact          || '-' ||
     g_srvivng_fmly_mbr || '-' ||
     g_srvivng_spouse   || '-' ||
     g_former_fmly_mbr  || '-' ||
     g_former_spouse    || '-' ||
     g_other            || '-' ||
     g_participant      || '-' ||
     g_employee_student || '-' ||
     g_agency           || '-' ||
     g_consultant       || '-' ||
     g_self_employed;

  /* Return it */
  RETURN l_person_type_pk;

END construct_person_type_pk;


/******************************************************************************/
/* Procedure to populate the person type combinations table prior             */
/******************************************************************************/
PROCEDURE populate_person_types IS

  /* Cursor to hold people and the effective dates on which their person type */
  /* combination could change */
  CURSOR person_types_cur IS
  SELECT distinct person_id, effective_date
  FROM
  (SELECT person_id   person_id
  ,effective_start_date  effective_date
  FROM per_all_people_f
  UNION
  SELECT person_id
  ,effective_start_date
  FROM per_person_type_usages_f
  UNION
  SELECT person_id
  ,effective_end_date + 1
  FROM per_person_type_usages_f );

  /* Cursor to return a row if the given person type combination already */
  /* exists in the person type combinations table */
  CURSOR row_exists_cur
  (v_primary_key  VARCHAR2) IS
  SELECT 1
  FROM hri_person_type_cmbns
  WHERE person_type_pk = v_primary_key;

  /* Variable to hold the constructed person type primary key */
  l_person_type_pk  hri_person_type_cmbns.person_type_pk%TYPE;

  /* Variables to hold information from cursors */
  l_person_id       per_all_people_f.person_id%TYPE;
  l_effective_date  per_all_people_f.effective_start_date%TYPE;
  l_row_exists      NUMBER;  -- Whether or not a row already exists

BEGIN

  FOR person_type_rec IN person_types_cur LOOP

    l_person_id := person_type_rec.person_id;
    l_effective_date := person_type_rec.effective_date;

    l_person_type_pk := construct_person_type_pk(l_person_id, l_effective_date);

    OPEN row_exists_cur(l_person_type_pk);
    FETCH row_exists_cur INTO l_row_exists;

    IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN

      INSERT INTO hri_person_type_cmbns
      ( person_type_pk
      , person_id
      , effective_date
      , employee
      , applicant
      , permanent
      , fixed_term_upper
      , fixed_term_lower
      , intern
      , ex_employee
      , ex_applicant
      , dependent
      , beneficiary
      , retiree
      , contact
      , surviving_family_member
      , surviving_spouse
      , former_family_member
      , former_spouse
      , other
      , participant
      , employee_student
      , consultant
      , agency
      , self_employed )
      VALUES
        ( l_person_type_pk
        , l_person_id
        , l_effective_date
        , g_employee
        , g_applicant
        , g_permanent
        , g_fixed_term_upper
        , g_fixed_term_lower
        , g_intern
        , g_ex_employee
        , g_ex_applicant
        , g_dependent
        , g_beneficiary
        , g_retiree
        , g_contact
        , g_srvivng_fmly_mbr
        , g_srvivng_spouse
        , g_former_fmly_mbr
        , g_former_spouse
        , g_other
        , g_participant
        , g_employee_student
        , g_consultant
        , g_agency
        , g_self_employed );

    END IF;

    CLOSE row_exists_cur;

  END LOOP;

END populate_person_types;


/******************************************************************************/
/* Procedure to insert a row into the user person types table                 */
/******************************************************************************/
PROCEDURE insert_user_row( p_system_person_type      IN VARCHAR2,
                           p_user_person_type        IN VARCHAR2,
                           p_map_to_type             IN VARCHAR2 )
IS

  l_map_to_type        VARCHAR2(30);  -- Existing type to map to

/* Selects the map to type for the row if it exists */
  CURSOR row_exists_cur IS
  SELECT map_to_type
  FROM hri_edw_user_person_types
  WHERE system_person_type = p_system_person_type
  AND user_person_type = p_user_person_type;

BEGIN

/* Check that the input type is valid, reject if invalid */
  IF ( p_map_to_type <> 'AGENCY_CONTRACTOR' AND
       p_map_to_type <> 'CONSULTANT' AND
       p_map_to_type <> 'SELF_EMP_CONTRACTOR' AND
       p_map_to_type <> 'FIX_TERM_UPPER' AND
       p_map_to_type <> 'FIX_TERM_LOWER' AND
       p_map_to_type <> 'INTERN' AND
       p_map_to_type <> 'PERMANENT') THEN
  /* Return doing nothing */
    RETURN;
  END IF;

/* Check if a row already exists */
  OPEN row_exists_cur;
  FETCH row_exists_cur INTO l_map_to_type;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
  /* If no row already exists for the given type combination, insert */
    INSERT INTO hri_edw_user_person_types
      ( system_person_type
      , user_person_type
      , map_to_type )
      VALUES
        ( p_system_person_type
        , p_user_person_type
        , p_map_to_type );
  ELSIF (p_map_to_type <> l_map_to_type) THEN
  /* Otherwise, if the map to type is different, update */
    UPDATE hri_edw_user_person_types
    SET map_to_type = p_map_to_type
    WHERE system_person_type = p_system_person_type
    AND user_person_type = p_user_person_type;
  END IF;

END insert_user_row;


/******************************************************************************/
/* Procedure to remove a row from the user person types table                 */
/******************************************************************************/
PROCEDURE remove_user_row( p_system_person_type      IN VARCHAR2,
                           p_user_person_type        IN VARCHAR2)
IS

BEGIN

/* Delete the row if it exists */
  DELETE FROM hri_edw_user_person_types
  WHERE system_person_type = p_system_person_type
  AND user_person_type = p_user_person_type;

END remove_user_row;


/******************************************************************************/
/* The load row procedure calls the insert row API.                           */
/******************************************************************************/
PROCEDURE load_row(  p_system_person_type      IN VARCHAR2,
                     p_user_person_type        IN VARCHAR2,
                     p_map_to_type             IN VARCHAR2,
                     p_owner                   IN VARCHAR2 )
IS

BEGIN

/* Call to the insert row procedure above, which handles updates */
  insert_user_row( p_system_person_type, p_user_person_type, p_map_to_type);

END load_row;

END hri_edw_dim_person_type;

/
