--------------------------------------------------------
--  DDL for Package Body PER_AE_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AE_MIGRATE_PKG" AS
/* $Header: peaemigr.pkb 120.0 2006/04/09 22:35:00 abppradh noship $ */

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure update_scl_from_ddf
  -- This procedure is used to migrate the data of Accomodation and Transportation provided
  -- segments from ddf to scl
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------

  PROCEDURE update_scl_from_ddf
    (errbuf                      OUT NOCOPY VARCHAR2
    ,retcode                    OUT NOCOPY VARCHAR2
    ,p_business_group_id IN NUMBER) IS

  l_acco_provided             VARCHAR2(30);
  l_trans_provided            VARCHAR2(30);
  l_comment_id                NUMBER;
  l_soft_key_flex_id          NUMBER;
  l_effective_start_date      DATE;
  l_effective_end_date        DATE;
  l_concatenated_segments     VARCHAR2(1000);
  l_no_manager_warning        BOOLEAN;
  l_other_manager_warning     BOOLEAN;
  l_business_group_id         NUMBER;
  l_person_id                 NUMBER;
  l_prev_person_id            NUMBER;
  l_assignment_id             NUMBER;
  l_object_version_number     NUMBER;
  l_effective_date            date;
  l_segment1                  VARCHAR2(30);
  l_segment2                  VARCHAR2(30);
  l_segment3                  VARCHAR2(30);
  l_segment4                  VARCHAR2(30);
  l_segment5                  VARCHAR2(30);
  l_title                     per_all_assignments_f.title%TYPE;
  l_same_person               NUMBER;
  i                           NUMBER;
  j                           NUMBER;
  k                           NUMBER;
  l_ov_update                 NUMBER;
  l_datetrack_mode            VARCHAR2(30);
  l_eff_date                  DATE;
  l_default_employer            VARCHAR2(30);
  l_migration_processed     VARCHAR2(30);


  TYPE rec_person IS RECORD
  (person_id            NUMBER
  ,per_information14     VARCHAR2(240)
  ,per_information15    VARCHAR2(240)
  ,effective_start_date DATE
  ,effective_end_date   DATE);

  TYPE t_type_rec_person IS TABLE OF rec_person INDEX BY BINARY_INTEGER;

  tab_rec_person     t_type_rec_person;

  /*Cursor for checking if default employer is set*/
  CURSOR csr_get_bg_det IS
  SELECT org_information2 def_emp
                ,NVL(org_information3,'N') mig_indicator
  FROM   hr_organization_information hoi
  WHERE  hoi.organization_id = p_business_group_id
  AND    hoi.org_information_context = 'AE_BG_DETAILS';
  rec_get_bg_det        csr_get_bg_det%ROWTYPE;


  /*Cursor for fetching business groups in AE LEGISLATION */
  CURSOR csr_get_business_group_id IS
  SELECT business_group_id
  FROM   per_business_groups
  WHERE  legislation_code = 'AE';
  rec_get_business_group_id      csr_get_business_group_id%ROWTYPE;

  /* Cursor for fetching employee details*/
  CURSOR csr_get_person IS
  SELECT person_id
         ,per_information14 acco_provided
         ,per_information15 trans_provided
         ,effective_start_date
         ,effective_end_date
  FROM   per_all_people_f ppf
         ,per_person_types ppt
  WHERE  ppf.business_group_id = l_business_group_id
  AND    ppt.person_type_id = ppf.person_type_id
  AND    ppt.business_group_id = ppf.business_group_id
  AND    ppt.system_person_type LIKE 'EMP%'
  ORDER BY person_id, effective_start_date, effective_end_date;
  rec_get_person              csr_get_person%ROWTYPE;

  /*Cursor for fetching the data for assignments of each employee selected by the above cursor.
 This cursor will be used for selecting the asignments for updating the scl segments. */
  CURSOR csr_get_assignment_det (p_start_date DATE, p_end_date DATE, p_person_id NUMBER) IS
  SELECT assignment_id
         ,paa.object_version_number
         ,paa.title
         ,hsc.segment1
         ,hsc.segment2
         ,hsc.segment3
         ,hsc.segment4
         ,hsc.segment5
         ,paa.effective_start_date
         ,paa.effective_end_date
         ,0 indicator
  FROM   per_all_assignments_f paa
         ,hr_soft_coding_keyflex hsc
  WHERE  person_id = p_person_id
  AND    paa.primary_flag = 'Y'
  AND    hsc.soft_coding_keyflex_id(+) = paa.soft_coding_keyflex_id
  AND    ((paa.effective_start_date BETWEEN p_start_date AND p_end_date ))
  UNION
  SELECT assignment_id
         ,paa.object_version_number
         ,paa.title
         ,hsc.segment1
         ,hsc.segment2
         ,hsc.segment3
         ,hsc.segment4
         ,hsc.segment5
         ,paa.effective_start_date
         ,paa.effective_end_date
         ,1 indicator
  FROM   per_all_assignments_f paa
         ,hr_soft_coding_keyflex hsc
  WHERE  person_id = p_person_id
  AND    paa.primary_flag = 'Y'
  AND    hsc.soft_coding_keyflex_id(+) = paa.soft_coding_keyflex_id
  AND     ((paa.effective_start_date < p_start_date AND paa.effective_end_date >= p_end_date))
  ORDER BY effective_start_date;
  rec_get_assignment_det  csr_get_assignment_det%ROWTYPE;
BEGIN

  l_default_employer := NULL;
  l_migration_processed := NULL;

  OPEN csr_get_bg_det;
  FETCH csr_get_bg_det INTO rec_get_bg_det;
  l_default_employer := rec_get_bg_det.def_emp;
  l_migration_processed  := rec_get_bg_det.mig_indicator;
  CLOSE csr_get_bg_det;

  IF l_default_employer IS NULL THEN
   -- fnd_file.put_line(fnd_file.log, 'Default Employer is not defined at the business group level');
    hr_utility.set_message(800, 'HR_377438_AE_DEF_EMP');
    hr_utility.raise_error;
  END IF;

  IF l_migration_processed = 'Y' THEN
    --fnd_file.put_line(fnd_file.log, 'Migration of Accomodation Provided and Transportation Provided segments from Person DDF to Assignment SCL have already been completed');
    hr_utility.set_message(800, 'HR_377439_AE_MIG_RUN');
    hr_utility.raise_error;
  ELSE
  --OPEN csr_get_business_group_id;
  --LOOP
    --FETCH csr_get_business_group_id INTO rec_get_business_group_id;
    --EXIT WHEN csr_get_business_group_id%NOTFOUND;
    l_business_group_id := p_business_group_id ; --rec_get_business_group_id.business_group_id;
    l_prev_person_id := 0;
    l_same_person    := 0;
    i := 0;
    OPEN csr_get_person;
    LOOP
      FETCH csr_get_person INTO rec_get_person;
      EXIT WHEN csr_get_person%NOTFOUND;
      hr_utility.trace('Person ID : '||rec_get_person.person_id);

      /*Populate a table type record with the values and effective dates*/
      IF l_prev_person_id = rec_get_person.person_id THEN
        l_same_person := 1;
        IF (NVL(rec_get_person.acco_provided,'~') = NVL(tab_rec_person(i).per_information14,'~'))
          AND (NVL(rec_get_person.trans_provided,'~') = NVL(tab_rec_person(i).per_information15,'~')) THEN
          tab_rec_person(i).effective_end_date := rec_get_person.effective_end_date;
        ELSE
          i := i + 1;
          tab_rec_person(i).person_id := rec_get_person.person_id;
          tab_rec_person(i).per_information14 := rec_get_person.acco_provided;
          tab_rec_person(i).per_information15 := rec_get_person.trans_provided;
          tab_rec_person(i).effective_start_date := rec_get_person.effective_start_date;
          tab_rec_person(i).effective_end_date := rec_get_person.effective_end_date;
        END IF;
      ELSE
        /*Code for updating assignments */
        /*All assignments are updated with the details of the current person before the next person is fetched*/
        ------------------------------------------
        IF tab_rec_person.COUNT > 0 THEN
          j := tab_rec_person.COUNT;
          k := 1;
          WHILE k <= j LOOP
            l_ov_update := 0;
            /*Fetch assignments for the period in which person ddf has changed*/
            OPEN csr_get_assignment_det(tab_rec_person(k-1).effective_start_date
                                       ,tab_rec_person(k-1).effective_end_date
                                       ,tab_rec_person(k-1).person_id);
            LOOP
              FETCH csr_get_assignment_det INTO rec_get_assignment_det;
              EXIT WHEN csr_get_assignment_det%NOTFOUND;
              l_assignment_id := rec_get_assignment_det.assignment_id;
              --IF l_ov_update = 0 THEN
              --l_object_version_number := rec_get_assignment_det.object_version_number;
              --END IF;
              l_title := rec_get_assignment_det.title;
              l_segment1 := NVL(rec_get_assignment_det.segment1,l_default_employer);
              l_segment2 := rec_get_assignment_det.segment2;
              l_segment3 := rec_get_assignment_det.segment3;
              l_segment4 := rec_get_assignment_det.segment4;
              l_segment5 := rec_get_assignment_det.segment5;
              /*If the start date matches, update the asignment in 'CORRECTION' mode*/
              IF rec_get_assignment_det.effective_start_date = tab_rec_person(k-1).effective_start_date THEN
                l_datetrack_mode := 'CORRECTION';
                l_eff_date := tab_rec_person(k-1).effective_start_date;
                l_object_version_number := rec_get_assignment_det.object_version_number;
              ELSE
                /*If start date do not match, check if any assignment has already been updated for the person within the same period
                 If there has been an UPDATe, then the next record should be updated in 'COREECTION mode*/
                IF l_ov_update = 1 THEN
                  l_datetrack_mode := 'CORRECTION';
                  l_eff_date := rec_get_assignment_det.effective_start_date;
                  l_object_version_number := rec_get_assignment_det.object_version_number;
                ELSE
                  /* If there exists future rows in assignment that are date tracked, UPDATE_CHANGE_INSERT mode should be used*/
                  IF (rec_get_assignment_det.effective_end_date < TO_DATE('31-12-4712','DD-MM-YYYY')
                     OR rec_get_assignment_det.effective_start_date > tab_rec_person(k-1).effective_start_date) THEN
                    l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
                    l_eff_date := tab_rec_person(k-1).effective_start_date;
                  ELSE
                    l_datetrack_mode := 'UPDATE';
                    l_eff_date := tab_rec_person(k-1).effective_start_date;
                  END IF;
                END IF;
              END IF;
              l_comment_id := NULL;
              l_soft_key_flex_id := NULL;
              l_effective_start_date := NULL;
              l_effective_end_date := NULL;
              l_concatenated_segments := NULL;
              l_no_manager_warning := NULL;
              l_other_manager_warning := NULL;

              hr_assignment_api.update_emp_asg
                (p_validate                 => FALSE
                ,p_effective_date           => l_eff_date --tab_rec_person(k-1).effective_start_date
                ,p_datetrack_update_mode    => l_datetrack_mode
                ,p_assignment_id            => l_assignment_id
                ,p_object_version_number    => l_object_version_number
                ,p_title => 'AE_STATUTORY_INFO' --l_title
                ,p_segment1   => l_segment1
                ,p_segment2  => l_segment2
                ,p_segment3   => l_segment3
                ,p_segment4  => l_segment4
                ,p_segment5  => l_segment5
                ,p_segment7   => tab_rec_person(k-1).per_information14 --l_acco_provided
                ,p_segment8  => tab_rec_person(k-1).per_information15 --l_trans_provided
                ,p_comment_id               => l_comment_id
                ,p_soft_coding_keyflex_id   => l_soft_key_flex_id
                ,p_effective_start_date     => l_effective_start_date
                ,p_effective_end_date       => l_effective_end_date
                ,p_concatenated_segments    => l_concatenated_segments
                ,p_no_managers_warning      => l_no_manager_warning
                ,p_other_manager_warning    => l_other_manager_warning);


              IF rec_get_assignment_det.indicator = 0 THEN
              /*If a record was updated with UPDATE_CHANGE_INSERT mode, the next
              assignments within the same person ddf periods should be updated in CORRECTION mode*/
                IF l_datetrack_mode = 'UPDATE_CHANGE_INSERT' THEN
                  l_comment_id := NULL;
                  l_soft_key_flex_id := NULL;
                  l_effective_start_date := NULL;
                  l_effective_end_date := NULL;
                  l_concatenated_segments := NULL;
                  l_no_manager_warning := NULL;
                  l_other_manager_warning := NULL;
                  l_object_version_number := rec_get_assignment_det.object_version_number;

                  hr_assignment_api.update_emp_asg
                    (p_validate                 => FALSE
                    ,p_effective_date           => rec_get_assignment_det.effective_start_date
                    ,p_datetrack_update_mode    => 'CORRECTION'
                    ,p_assignment_id            => l_assignment_id
                    ,p_object_version_number    => l_object_version_number
                    ,p_title => 'AE_STATUTORY_INFO' --l_title
                    ,p_segment1   => l_segment1
                    ,p_segment2  => l_segment2
                    ,p_segment3   => l_segment3
                    ,p_segment4  => l_segment4
                    ,p_segment5  => l_segment5
                    ,p_segment7   => tab_rec_person(k-1).per_information14 --l_acco_provided
                    ,p_segment8  => tab_rec_person(k-1).per_information15 --l_trans_provided
                    ,p_comment_id               => l_comment_id
                    ,p_soft_coding_keyflex_id   => l_soft_key_flex_id
                    ,p_effective_start_date     => l_effective_start_date
                    ,p_effective_end_date       => l_effective_end_date
                    ,p_concatenated_segments    => l_concatenated_segments
                    ,p_no_managers_warning      => l_no_manager_warning
                    ,p_other_manager_warning    => l_other_manager_warning);

                END IF;

              END IF;

              l_ov_update := 1;

            END LOOP;
            CLOSE csr_get_assignment_det;

            k := k + 1;
          END LOOP;
        END IF;
        ------------------------------------------

        /*Once the assignments of the previous person have been updated continue with the next person*/
        l_same_person := 0;
        l_prev_person_id := rec_get_person.person_id;
        i := 0;
        tab_rec_person.DELETE;
        tab_rec_person(i).person_id := rec_get_person.person_id;
        tab_rec_person(i).per_information14 := rec_get_person.acco_provided;
        tab_rec_person(i).per_information15 := rec_get_person.trans_provided;
        tab_rec_person(i).effective_start_date := rec_get_person.effective_start_date;
        tab_rec_person(i).effective_end_date := rec_get_person.effective_end_date;
      END IF;

    END LOOP;
    CLOSE csr_get_person;

    /*Code for updating assignments */
    ------------------------------------------
    IF tab_rec_person.COUNT > 0 THEN
      j := tab_rec_person.COUNT;
      k := 1;
      WHILE k <= j LOOP
        l_ov_update := 0;

        OPEN csr_get_assignment_det(tab_rec_person(k-1).effective_start_date
                                   ,tab_rec_person(k-1).effective_end_date
                                   ,tab_rec_person(k-1).person_id);
        LOOP
          FETCH csr_get_assignment_det INTO rec_get_assignment_det;
          EXIT WHEN csr_get_assignment_det%NOTFOUND;
          l_assignment_id := rec_get_assignment_det.assignment_id;
          --IF l_ov_update = 0 THEN
          --l_object_version_number := rec_get_assignment_det.object_version_number;
          --END IF;
          l_title := rec_get_assignment_det.title;
          l_segment1 := NVL(rec_get_assignment_det.segment1,l_default_employer);
          l_segment2 := rec_get_assignment_det.segment2;
          l_segment3 := rec_get_assignment_det.segment3;
          l_segment4 := rec_get_assignment_det.segment4;
          l_segment5 := rec_get_assignment_det.segment5;
          IF rec_get_assignment_det.effective_start_date = tab_rec_person(k-1).effective_start_date THEN
            l_datetrack_mode := 'CORRECTION';
            l_eff_date := tab_rec_person(k-1).effective_start_date;
            l_object_version_number := rec_get_assignment_det.object_version_number;
          ELSE
            IF l_ov_update = 1 THEN
              l_datetrack_mode := 'CORRECTION';
              l_eff_date := rec_get_assignment_det.effective_start_date;
              l_object_version_number := rec_get_assignment_det.object_version_number;
            ELSE
              IF (rec_get_assignment_det.effective_end_date < TO_DATE('31-12-4712','DD-MM-YYYY')
                 OR rec_get_assignment_det.effective_start_date > tab_rec_person(k-1).effective_start_date) THEN
                l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
                l_eff_date := tab_rec_person(k-1).effective_start_date;
              ELSE
                l_datetrack_mode := 'UPDATE';
                l_eff_date := tab_rec_person(k-1).effective_start_date;
              END IF;
            END IF;
          END IF;
          l_comment_id := NULL;
          l_soft_key_flex_id := NULL;
          l_effective_start_date := NULL;
          l_effective_end_date := NULL;
          l_concatenated_segments := NULL;
          l_no_manager_warning := NULL;
          l_other_manager_warning := NULL;

          hr_assignment_api.update_emp_asg
            (p_validate                 => FALSE
            ,p_effective_date           => l_eff_date --tab_rec_person(k-1).effective_start_date
            ,p_datetrack_update_mode    => l_datetrack_mode
            ,p_assignment_id            => l_assignment_id
            ,p_object_version_number    => l_object_version_number
            ,p_title => 'AE_STATUTORY_INFO' --l_title
            ,p_segment1   => l_segment1
            ,p_segment2  => l_segment2
            ,p_segment3   => l_segment3
            ,p_segment4  => l_segment4
            ,p_segment5  => l_segment5
            ,p_segment7   => tab_rec_person(k-1).per_information14 --l_acco_provided
            ,p_segment8  => tab_rec_person(k-1).per_information15 --l_trans_provided
            ,p_comment_id               => l_comment_id
            ,p_soft_coding_keyflex_id   => l_soft_key_flex_id
            ,p_effective_start_date     => l_effective_start_date
            ,p_effective_end_date       => l_effective_end_date
            ,p_concatenated_segments    => l_concatenated_segments
            ,p_no_managers_warning      => l_no_manager_warning
            ,p_other_manager_warning    => l_other_manager_warning);


          IF rec_get_assignment_det.indicator = 0 THEN

            IF l_datetrack_mode = 'UPDATE_CHANGE_INSERT' THEN
              l_comment_id := NULL;
              l_soft_key_flex_id := NULL;
              l_effective_start_date := NULL;
              l_effective_end_date := NULL;
              l_concatenated_segments := NULL;
              l_no_manager_warning := NULL;
              l_other_manager_warning := NULL;
              l_object_version_number := rec_get_assignment_det.object_version_number;

              hr_assignment_api.update_emp_asg
                (p_validate                 => FALSE
                ,p_effective_date           => rec_get_assignment_det.effective_start_date
                ,p_datetrack_update_mode    => 'CORRECTION'
                ,p_assignment_id            => l_assignment_id
                ,p_object_version_number    => l_object_version_number
                ,p_title => 'AE_STATUTORY_INFO' --l_title
                ,p_segment1   => l_segment1
                ,p_segment2  => l_segment2
                ,p_segment3   => l_segment3
                ,p_segment4  => l_segment4
                ,p_segment5  => l_segment5
                ,p_segment7   => tab_rec_person(k-1).per_information14 --l_acco_provided
                ,p_segment8  => tab_rec_person(k-1).per_information15 --l_trans_provided
                ,p_comment_id               => l_comment_id
                ,p_soft_coding_keyflex_id   => l_soft_key_flex_id
                ,p_effective_start_date     => l_effective_start_date
                ,p_effective_end_date       => l_effective_end_date
                ,p_concatenated_segments    => l_concatenated_segments
                ,p_no_managers_warning      => l_no_manager_warning
                ,p_other_manager_warning    => l_other_manager_warning);

            END IF;

          END IF;
          l_ov_update := 1;
        END LOOP;
        CLOSE csr_get_assignment_det;

        k := k + 1;
      END LOOP;

    END IF;

  --END LOOP;
  --CLOSE csr_get_business_group_id;
    /*Update the org_information to indicate the migration is complete*/
    UPDATE hr_organization_information
    SET    org_information3 = 'Y'
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'AE_BG_DETAILS';
  END IF;

  END update_scl_from_ddf;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------

END per_ae_migrate_pkg;

/
