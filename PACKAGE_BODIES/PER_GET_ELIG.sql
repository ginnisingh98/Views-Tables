--------------------------------------------------------
--  DDL for Package Body PER_GET_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GET_ELIG" AS
  -- $Header: perellst.pkb 120.0 2005/05/31 17:34:47 appldev noship $

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Live evaluation version of get_elig_obj_for_per_asg()
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_elig_obj_for_per_asg_live
              ( p_person_id       IN         NUMBER
              , p_assignment_id   IN         NUMBER   DEFAULT NULL
              , p_effective_date  IN         DATE
              , p_table_name      IN         VARCHAR2
              , x_eligible_object OUT NOCOPY per_elig_obj_varray
              , x_return_status   OUT NOCOPY NUMBER
              , x_return_message  OUT NOCOPY VARCHAR2
              ) IS

    l_proc         VARCHAR2(50);
    l_per_elig_obj per_elig_obj;

    l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
    l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
    l_elig_obj_id        ben_elig_obj_f.elig_obj_id%TYPE;
    l_elig_obj_eff_st_dt ben_elig_obj_f.effective_start_date%TYPE;
    l_elig_obj_eff_en_dt ben_elig_obj_f.effective_end_date%TYPE;
    l_column_name        ben_elig_obj_f.column_name%TYPE;
    l_column_value       ben_elig_obj_f.column_value%TYPE;

    TYPE cur_type IS REF CURSOR;
    c_per_asg  cur_type;
    c_elig_obj cur_type;

  BEGIN
    l_proc := 'per_get_elig.get_elig_obj_for_per_asg_live';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_per_elig_obj := per_elig_obj(NULL,NULL,NULL,NULL,NULL,NULL);
    x_eligible_object := per_elig_obj_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Cursor to fetch all the effective assignments for the given person
    OPEN c_per_asg FOR ' SELECT assignment_id,'||
                              ' business_group_id'||
                       ' FROM per_all_assignments_f'||
                       ' WHERE person_id = :1'||
                       ' AND assignment_id = NVL(:2, assignment_id)'||
                       ' AND effective_start_date <= :3'||
                       ' AND effective_end_date >= :4'
                 USING p_person_id
                     , p_assignment_id
                     , p_effective_date
                     , p_effective_date;

    hr_utility.set_location(l_proc, 20);

    LOOP -- Loop for person assignments
      FETCH c_per_asg INTO l_assignment_id
                          ,l_business_group_id;
      EXIT WHEN c_per_asg%NOTFOUND;
      hr_utility.set_location('PerId '||p_person_id||
                             ' AsgId '||l_assignment_id,25);

      -- Cursor to fetch eligibility objects
      OPEN c_elig_obj FOR ' SELECT elig_obj_id,'||
                                 ' effective_start_date,'||
                                 ' effective_end_date,'||
                                 ' column_name,'||
                                 ' column_value'||
                          ' FROM ben_elig_obj_f'||
                          ' WHERE table_name = :1'||
                          ' AND effective_start_date <= :2'||
                          ' AND effective_end_date >= :3'||
                          ' AND business_group_id = :4'
                    USING p_table_name
                        , p_effective_date
                        , p_effective_date
                        , l_business_group_id;

      hr_utility.set_location(l_proc, 30);

      LOOP -- Loop for eligibility objects
        FETCH c_elig_obj INTO l_elig_obj_id
                             ,l_elig_obj_eff_st_dt
                             ,l_elig_obj_eff_en_dt
                             ,l_column_name
                             ,l_column_value;
        EXIT WHEN c_elig_obj%NOTFOUND;
        hr_utility.set_location('EligObjId '||l_elig_obj_id||
                               ' ColNm '||l_column_name||
                               ' ColVal '||l_column_value,33);

        -- Invoke BEN routine to test eligibility
        IF ben_per_asg_elig.eligible( p_person_id         => p_person_id
                                    , p_assignment_id     => l_assignment_id
                                    , p_elig_obj_id       => l_elig_obj_id
                                    , p_effective_date    => p_effective_date
                                    , p_business_group_id => l_business_group_id
                                    , p_save_results      => FALSE
                                    ) THEN

          hr_utility.set_location('Eligible', 36);

          -- Capture details of eligibile object
          l_per_elig_obj.elig_obj_id    := l_elig_obj_id;
          l_per_elig_obj.tab_name       := p_table_name;
          l_per_elig_obj.col_name       := l_column_name;
          l_per_elig_obj.col_value      := l_column_value;
          l_per_elig_obj.eff_start_date := l_elig_obj_eff_st_dt;
          l_per_elig_obj.eff_end_date   := l_elig_obj_eff_en_dt;

          -- Save eligibile object into array
          x_eligible_object.EXTEND(1);
          x_eligible_object(x_eligible_object.COUNT) := l_per_elig_obj;
        END IF;

      END LOOP; -- Loop for eligibility objects
      CLOSE c_elig_obj;

    END LOOP; -- Loop for person assignments
    CLOSE c_per_asg;

    hr_utility.set_location('Leaving: '|| l_proc, 40);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 50);
      hr_utility.set_location(SQLERRM, 55);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_elig_obj_for_per_asg_live;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Cache data version of get_elig_obj_for_per_asg()
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_elig_obj_for_per_asg_cache
              ( p_person_id       IN         NUMBER
              , p_assignment_id   IN         NUMBER   DEFAULT NULL
              , p_effective_date  IN         DATE
              , p_table_name      IN         VARCHAR2
              , x_eligible_object OUT NOCOPY per_elig_obj_varray
              , x_return_status   OUT NOCOPY NUMBER
              , x_return_message  OUT NOCOPY VARCHAR2
              ) IS

    l_proc         VARCHAR2(50);
    l_per_elig_obj per_elig_obj;

    -- Cursor to fetch all the eligibile objects for the given person
    CURSOR c_elig_obj ( cp_person_id      IN NUMBER
                      , cp_assignment_id  IN NUMBER
                      , cp_effective_date IN DATE
                      ) IS
      SELECT OBJ.elig_obj_id
            ,OBJ.table_name
            ,OBJ.column_name
            ,OBJ.column_value
            ,OBJ.effective_start_date
            ,OBJ.effective_end_date
      FROM ben_elig_rslt_f RSLT
          ,ben_elig_obj_f  OBJ
      WHERE RSLT.person_id = cp_person_id
      AND RSLT.assignment_id = NVL(cp_assignment_id, RSLT.assignment_id)
      AND RSLT.effective_start_date <= cp_effective_date
      AND RSLT.effective_end_date >= cp_effective_date
      AND RSLT.elig_flag = 'Y'
      AND RSLT.elig_obj_id = OBJ.elig_obj_id
      AND OBJ.effective_start_date <= cp_effective_date
      AND OBJ.effective_end_date >= cp_effective_date;

  BEGIN
    l_proc := 'per_get_elig.get_elig_obj_for_per_asg_cache';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_per_elig_obj := per_elig_obj(NULL,NULL,NULL,NULL,NULL,NULL);
    x_eligible_object := per_elig_obj_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Cursor to fetch all the eligibile objects for the given person
    OPEN c_elig_obj ( p_person_id
                    , p_assignment_id
                    , p_effective_date
                    );

    hr_utility.set_location(l_proc, 20);

    LOOP -- for eligibility objects
      FETCH c_elig_obj INTO l_per_elig_obj.elig_obj_id
                           ,l_per_elig_obj.tab_name
                           ,l_per_elig_obj.col_name
                           ,l_per_elig_obj.col_value
                           ,l_per_elig_obj.eff_start_date
                           ,l_per_elig_obj.eff_end_date;
      EXIT WHEN c_elig_obj%NOTFOUND;
      hr_utility.set_location('EligObjId '||l_per_elig_obj.elig_obj_id, 25);

      -- Save eligibile object into array
      x_eligible_object.EXTEND(1);
      x_eligible_object(x_eligible_object.COUNT) := l_per_elig_obj;

    END LOOP; -- for eligibility objects
    CLOSE c_elig_obj;

    hr_utility.set_location('Leaving: '|| l_proc, 30);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_elig_obj_for_per_asg_cache;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Live evaluation version of get_per_asg_for_elig_obj()
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_elig_obj_live
              ( p_table_name        IN         VARCHAR2
              , p_column_name       IN         VARCHAR2
              , p_column_value      IN         VARCHAR2
              , p_effective_date    IN         DATE
              , p_business_group_id IN         NUMBER
              , x_person_assignment OUT NOCOPY per_asg_varray
              , x_return_status     OUT NOCOPY NUMBER
              , x_return_message    OUT NOCOPY VARCHAR2
              ) IS

    l_proc        VARCHAR2(50);
    l_per_asg_obj per_asg_obj;

    l_elig_obj_id   ben_elig_obj_f.elig_obj_id%TYPE;
    l_person_id     per_all_people_f.person_id%TYPE;
    l_party_id      per_all_people_f.party_id%TYPE;
    l_assignment_id per_all_assignments_f.assignment_id%TYPE;
    l_asg_eff_st_dt per_all_assignments_f.effective_start_date%TYPE;
    l_asg_eff_en_dt per_all_assignments_f.effective_end_date%TYPE;

    -- Cursor to get the ID of the eligibility object
    CURSOR c_elig_obj ( cp_table_name        IN VARCHAR2
                      , cp_column_name       IN VARCHAR2
                      , cp_column_value      IN VARCHAR2
                      , cp_business_group_id IN NUMBER
                      , cp_effective_date    IN DATE
                      ) IS
      SELECT elig_obj_id
      FROM   ben_elig_obj_f
      WHERE  table_name = cp_table_name
      AND    column_name = cp_column_name
      AND    column_value = cp_column_value
      AND    business_group_id = cp_business_group_id
      AND    effective_start_date <= cp_effective_date
      AND    effective_end_date >= cp_effective_date;

    TYPE cur_type IS REF CURSOR;
    c_per cur_type;
    c_asg cur_type;

  BEGIN
    l_proc := 'per_get_elig.get_per_asg_for_elig_obj_live';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_per_asg_obj := per_asg_obj(NULL,NULL,NULL,NULL,NULL);
    x_person_assignment := per_asg_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Fetch the ID for the eligibility object
    OPEN c_elig_obj ( p_table_name
                    , p_column_name
                    , p_column_value
                    , p_business_group_id
                    , p_effective_date
                    );
    FETCH c_elig_obj INTO l_elig_obj_id;
    CLOSE c_elig_obj;

    hr_utility.set_location('EligObjId: '||l_elig_obj_id, 20);

    -- Cursor to fetch persons in the business group
    OPEN c_per FOR ' SELECT person_id,'||
                          ' party_id'||
                   ' FROM per_all_people_f'||
                   ' WHERE business_group_id = :1'||
                   ' AND effective_start_date <= :2'||
                   ' AND effective_end_date >= :3'
               USING p_business_group_id
                   , p_effective_date
                   , p_effective_date;

    hr_utility.set_location(l_proc, 30);

    LOOP -- Loop for persons in business group
      FETCH c_per INTO l_person_id
                      ,l_party_id;
      EXIT WHEN c_per%NOTFOUND;
      hr_utility.set_location('PersonId '||l_person_id||
                             ' PartyId '||l_party_id,33);

      -- Cursor to fetch assignments for a person
      OPEN c_asg FOR ' SELECT assignment_id,'||
                            ' effective_start_date,'||
                            ' effective_end_date'||
                     ' FROM per_all_assignments_f'||
                     ' WHERE person_id = :1'||
                     ' AND business_group_id = :2'||
                     ' AND effective_start_date <= :3'||
                     ' AND effective_end_date >= :4'
                 USING l_person_id
                     , p_business_group_id
                     , p_effective_date
                     , p_effective_date;

      hr_utility.set_location(l_proc, 40);

      LOOP -- Loop for assignments for the person
        FETCH c_asg INTO l_assignment_id
                        ,l_asg_eff_st_dt
                        ,l_asg_eff_en_dt;
        EXIT WHEN c_asg%NOTFOUND;
        hr_utility.set_location('AsgId '||l_assignment_id,43);

        -- Invoke BEN routine to test eligibility
        IF ben_per_asg_elig.eligible( p_person_id         => l_person_id
                                    , p_assignment_id     => l_assignment_id
                                    , p_elig_obj_id       => l_elig_obj_id
                                    , p_effective_date    => p_effective_date
                                    , p_business_group_id => p_business_group_id
                                    , p_save_results      => FALSE
                                    ) THEN

          hr_utility.set_location('Eligible', 46);

          -- Capture details of eligibile object
          l_per_asg_obj.person_id      := l_person_id;
          l_per_asg_obj.assignment_id  := l_assignment_id;
          l_per_asg_obj.party_id       := l_party_id;
          l_per_asg_obj.eff_start_date := l_asg_eff_st_dt;
          l_per_asg_obj.eff_end_date   := l_asg_eff_en_dt;

          -- Save eligibile object into array
          x_person_assignment.EXTEND(1);
          x_person_assignment(x_person_assignment.COUNT) := l_per_asg_obj;
        END IF;

      END LOOP; -- Loop for assignments for the person
      CLOSE c_asg;

    END LOOP; -- Loop for persons in business group
    CLOSE c_per;

    hr_utility.set_location('Leaving: '|| l_proc, 50);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 60);
      hr_utility.set_location(SQLERRM, 65);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_per_asg_for_elig_obj_live;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Cache data version of get_per_asg_for_elig_obj()
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_elig_obj_cache
              ( p_table_name        IN         VARCHAR2
              , p_column_name       IN         VARCHAR2
              , p_column_value      IN         VARCHAR2
              , p_effective_date    IN         DATE
              , p_business_group_id IN         NUMBER
              , x_person_assignment OUT NOCOPY per_asg_varray
              , x_return_status     OUT NOCOPY NUMBER
              , x_return_message    OUT NOCOPY VARCHAR2
              ) IS

    l_proc        VARCHAR2(50);
    l_per_asg_obj per_asg_obj;

    -- Cursor to fetch all the eligibile persons for the given object
    CURSOR c_elig_per_asg ( cp_table_name        IN VARCHAR2
                          , cp_column_name       IN VARCHAR2
                          , cp_column_value      IN VARCHAR2
                          , cp_effective_date    IN DATE
                          , cp_business_group_id IN NUMBER
                          ) IS
      SELECT RSLT.person_id
            ,RSLT.assignment_id
      FROM ben_elig_rslt_f RSLT
          ,ben_elig_obj_f  OBJ
      WHERE OBJ.table_name = cp_table_name
      AND   OBJ.column_name = cp_column_name
      AND   OBJ.column_value = cp_column_value
      AND   OBJ.effective_start_date <= cp_effective_date
      AND   OBJ.effective_end_date >= cp_effective_date
      AND   OBJ.elig_obj_id = RSLT.elig_obj_id
      AND   RSLT.effective_start_date <= cp_effective_date
      AND   RSLT.effective_end_date >= cp_effective_date
      AND   RSLT.business_group_id = cp_business_group_id
      AND   RSLT.elig_flag = 'Y';

    -- Cursor to fetch party id
    CURSOR c_party_id ( cp_person_id      IN NUMBER
                      , cp_effective_date IN DATE
                      ) IS
      SELECT party_id
      FROM   per_all_people_f
      WHERE  person_id = cp_person_id
      AND    effective_start_date <= cp_effective_date
      AND    effective_end_date >= cp_effective_date;

    -- Cursor to fetch assignment effective dates
    CURSOR c_asg_eff_dates ( cp_person_id      IN NUMBER
                           , cp_assignment_id  IN NUMBER
                           , cp_effective_date IN DATE
                           ) IS
      SELECT effective_start_date
            ,effective_end_date
      FROM   per_all_assignments_f
      WHERE  person_id = cp_person_id
      AND    assignment_id = cp_assignment_id
      AND    effective_start_date <= cp_effective_date
      AND    effective_end_date >= cp_effective_date;

  BEGIN
    l_proc := 'per_get_elig.get_per_asg_for_elig_obj_cache';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_per_asg_obj := per_asg_obj(NULL,NULL,NULL,NULL,NULL);
    x_person_assignment := per_asg_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Cursor to fetch all the eligibile objects for the given person
    OPEN c_elig_per_asg ( p_table_name
                        , p_column_name
                        , p_column_value
                        , p_effective_date
                        , p_business_group_id
                        );

    hr_utility.set_location(l_proc, 20);

    LOOP -- for result person assignments
      FETCH c_elig_per_asg INTO l_per_asg_obj.person_id
                               ,l_per_asg_obj.assignment_id;
      EXIT WHEN c_elig_per_asg%NOTFOUND;
      hr_utility.set_location('PerId '||l_per_asg_obj.person_id||
                             ' AsgId '||l_per_asg_obj.assignment_id,23);

      hr_utility.set_location(l_proc, 22);

      -- Get party id
      OPEN c_party_id (l_per_asg_obj.person_id
                      ,p_effective_date
                      );
      FETCH c_party_id INTO l_per_asg_obj.party_id;
      CLOSE c_party_id;

      hr_utility.set_location(l_proc, 24);

      -- Get assignment dates
      OPEN c_asg_eff_dates (l_per_asg_obj.person_id
                           ,l_per_asg_obj.assignment_id
                           ,p_effective_date
                           );
      FETCH c_asg_eff_dates INTO l_per_asg_obj.eff_start_date
                                ,l_per_asg_obj.eff_end_date;
      CLOSE c_asg_eff_dates;

      hr_utility.set_location(l_proc, 26);

      -- Save person assignments into array
      x_person_assignment.EXTEND(1);
      x_person_assignment(x_person_assignment.COUNT) := l_per_asg_obj;

    END LOOP; -- for result person assignments
    CLOSE c_elig_per_asg;

    hr_utility.set_location('Leaving: '|| l_proc, 30);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_per_asg_for_elig_obj_cache;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- List the Eligibility Objects that the given Person Assignment is eligible
  -- for. If the assignment id is supplied, the eligible objects will be for
  -- that assignment. Else if will be for all assignments.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_elig_obj_for_per_asg( p_person_id       IN         NUMBER
                                    , p_assignment_id   IN         NUMBER   DEFAULT NULL
                                    , p_effective_date  IN         DATE
                                    , p_table_name      IN         VARCHAR2
                                    , p_data_mode       IN         VARCHAR2 DEFAULT NULL
                                    , x_eligible_object OUT NOCOPY per_elig_obj_varray
                                    , x_return_status   OUT NOCOPY NUMBER
                                    , x_return_message  OUT NOCOPY VARCHAR2
                                    ) IS
    l_proc      VARCHAR2(50);
    l_data_mode VARCHAR2(1);
  BEGIN
    l_proc := 'per_get_elig.get_elig_obj_for_per_asg';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    CASE
      WHEN p_data_mode IS NULL THEN
        l_data_mode := 'L';
      WHEN p_data_mode = 'C' THEN
        l_data_mode := 'C';
      ELSE
        l_data_mode := 'L';
    END CASE;

    IF l_data_mode = 'L' THEN
      hr_utility.set_location(l_proc, 20);

      get_elig_obj_for_per_asg_live ( p_person_id       => p_person_id
                                    , p_assignment_id   => p_assignment_id
                                    , p_effective_date  => p_effective_date
                                    , p_table_name      => p_table_name
                                    , x_eligible_object => x_eligible_object
                                    , x_return_status   => x_return_status
                                    , x_return_message  => x_return_message
                                    );
    ELSE -- data mode is 'C'
      hr_utility.set_location(l_proc, 30);

      get_elig_obj_for_per_asg_cache ( p_person_id       => p_person_id
                                     , p_assignment_id   => p_assignment_id
                                     , p_effective_date  => p_effective_date
                                     , p_table_name      => p_table_name
                                     , x_eligible_object => x_eligible_object
                                     , x_return_status   => x_return_status
                                     , x_return_message  => x_return_message
                                     );
    END IF; -- data mode check

    hr_utility.set_location('Leaving: '|| l_proc, 40);
  END get_elig_obj_for_per_asg;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- List the Person Assignments that are eligible for the given
  -- Eligibility Object.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_elig_obj( p_table_name        IN         VARCHAR2
                                    , p_column_name       IN         VARCHAR2
                                    , p_column_value      IN         VARCHAR2
                                    , p_effective_date    IN         DATE
                                    , p_business_group_id IN         NUMBER
                                    , p_data_mode         IN         VARCHAR2 DEFAULT NULL
                                    , x_person_assignment OUT NOCOPY per_asg_varray
                                    , x_return_status     OUT NOCOPY NUMBER
                                    , x_return_message    OUT NOCOPY VARCHAR2
                                    ) IS
    l_proc      VARCHAR2(50);
    l_data_mode VARCHAR2(1);
  BEGIN
    l_proc := 'per_get_elig.get_per_asg_for_elig_obj';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    CASE
      WHEN p_data_mode IS NULL THEN
        l_data_mode := 'L';
      WHEN p_data_mode = 'C' THEN
        l_data_mode := 'C';
      ELSE
        l_data_mode := 'L';
    END CASE;

    IF l_data_mode = 'L' THEN
      hr_utility.set_location(l_proc, 20);

      get_per_asg_for_elig_obj_live ( p_table_name        => p_table_name
                                    , p_column_name       => p_column_name
                                    , p_column_value      => p_column_value
                                    , p_effective_date    => p_effective_date
                                    , p_business_group_id => p_business_group_id
                                    , x_person_assignment => x_person_assignment
                                    , x_return_status     => x_return_status
                                    , x_return_message    => x_return_message
                                    );
    ELSE -- data mode is 'C'
      hr_utility.set_location(l_proc, 30);

      get_per_asg_for_elig_obj_cache ( p_table_name        => p_table_name
                                     , p_column_name       => p_column_name
                                     , p_column_value      => p_column_value
                                     , p_effective_date    => p_effective_date
                                     , p_business_group_id => p_business_group_id
                                     , x_person_assignment => x_person_assignment
                                     , x_return_status     => x_return_status
                                     , x_return_message    => x_return_message
                                     );
    END IF; -- data mode check

    hr_utility.set_location('Leaving: '|| l_proc, 40);
  END get_per_asg_for_elig_obj;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- List the Work Schedules that the given Person Assignment
  -- is eligible for.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_sch_for_per_asg
              ( p_person_id      IN         NUMBER
              , p_assignment_id  IN         NUMBER   DEFAULT NULL
              , p_effective_date IN         DATE
              , p_data_mode      IN         VARCHAR2 DEFAULT NULL
              , x_schedule       OUT NOCOPY per_work_sch_varray
              , x_return_status  OUT NOCOPY NUMBER
              , x_return_message OUT NOCOPY VARCHAR2
              ) IS

    l_proc            VARCHAR2(50);
    l_elig_obj_varray per_elig_obj_varray;
    l_elig_obj        per_elig_obj;
    l_work_sch_obj    per_work_sch_obj;

    l_schedule_name     cac_sr_schedules_vl.schedule_name%TYPE;
    l_schedule_category cac_sr_schedules_vl.schedule_category%TYPE;

    -- Cursor to fetch schedule details
    CURSOR c_sch ( cp_schedule_id IN NUMBER
                 , cp_start_date  IN DATE
                 , cp_end_date    IN DATE
                 ) IS
      SELECT schedule_category
            ,schedule_name
      FROM   cac_sr_schedules_vl
      WHERE  schedule_id = cp_schedule_id
      AND    start_date_active = cp_start_date
      AND    end_date_active = cp_end_date;

  BEGIN
    l_proc := 'per_get_elig.get_sch_for_per_asg';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_elig_obj_varray := per_elig_obj_varray();
    l_elig_obj := per_elig_obj(NULL,NULL,NULL,NULL,NULL,NULL);
    l_work_sch_obj := per_work_sch_obj(NULL,NULL,NULL,NULL,NULL);
    x_schedule := per_work_sch_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Get eligible objects for the given person assignments
    get_elig_obj_for_per_asg( p_person_id       => p_person_id
                            , p_assignment_id   => p_assignment_id
                            , p_effective_date  => p_effective_date
                            , p_table_name      => 'CAC_SR_SCHEDULES_VL'
                            , p_data_mode       => p_data_mode
                            , x_eligible_object => l_elig_obj_varray
                            , x_return_status   => x_return_status
                            , x_return_message  => x_return_message
                            );

    hr_utility.set_location(l_proc, 20);

    -- Translate all the eligibility objects to work schedules
    FOR i IN l_elig_obj_varray.FIRST..l_elig_obj_varray.LAST LOOP
      l_elig_obj := l_elig_obj_varray(i);

      hr_utility.set_location('EligObjId: '||l_elig_obj.elig_obj_id||' ColVal: '||l_elig_obj.col_value, 23);

      -- Get the schedule details
      OPEN c_sch ( l_elig_obj.col_value
                 , l_elig_obj.eff_start_date
                 , l_elig_obj.eff_end_date
                 );
      FETCH c_sch INTO l_work_sch_obj.schedule_category
                      ,l_work_sch_obj.schedule_name;
      CLOSE c_sch;

      hr_utility.set_location('SchCat: '||l_work_sch_obj.schedule_category||' SchName: '||l_work_sch_obj.schedule_name, 26);

      -- Save schedule details
      l_work_sch_obj.schedule_id := l_elig_obj.col_value;
      l_work_sch_obj.start_date_active := l_elig_obj.eff_start_date;
      l_work_sch_obj.end_date_active := l_elig_obj.eff_end_date;
      x_schedule.EXTEND(1);
      x_schedule(x_schedule.COUNT) := l_work_sch_obj;

      hr_utility.set_location(l_proc, 29);
    END LOOP;

    hr_utility.set_location('Leaving: '|| l_proc, 30);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_sch_for_per_asg;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- List the Person Assignment that are eligible for the given
  -- Schedule.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_per_asg_for_sch
              ( p_schedule_category IN         VARCHAR2
              , p_schedule_name     IN         VARCHAR2
              , p_effective_date    IN         DATE
              , p_business_group_id IN         NUMBER
              , p_data_mode         IN         VARCHAR2 DEFAULT NULL
              , x_person_assignment OUT NOCOPY per_asg_varray
              , x_return_status     OUT NOCOPY NUMBER
              , x_return_message    OUT NOCOPY VARCHAR2
              ) IS

    l_proc        VARCHAR2(50);
    l_schedule_id cac_sr_schedules_vl.schedule_id%TYPE;

    -- Cursor to fetch schedule identifier
    CURSOR c_sch ( cp_schedule_category IN VARCHAR2
                 , cp_schedule_name     IN VARCHAR2
                 , cp_effective_date    IN DATE
                 ) IS
      SELECT schedule_id
      FROM   cac_sr_schedules_vl
      WHERE  schedule_category = cp_schedule_category
      AND    schedule_name = cp_schedule_name
      AND    start_date_active <= cp_effective_date
      AND    end_date_active >= cp_effective_date;

  BEGIN
    l_proc := 'per_get_elig.get_per_asg_for_sch';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    x_person_assignment := per_asg_varray(); -- initialize empty
    x_return_status := '0';
    x_return_message := '';

    -- Get the schedule identifier
    OPEN c_sch ( p_schedule_category
               , p_schedule_name
               , p_effective_date
               );
    FETCH c_sch INTO l_schedule_id;
    CLOSE c_sch;

    hr_utility.set_location('SchId: '||l_schedule_id, 20);

    -- Get the person assignments
    get_per_asg_for_elig_obj( p_table_name        => 'CAC_SR_SCHEDULES_VL'
                            , p_column_name       => 'SCHEDULE_ID'
                            , p_column_value      => l_schedule_id
                            , p_effective_date    => p_effective_date
                            , p_business_group_id => p_business_group_id
                            , p_data_mode         => p_data_mode
                            , x_person_assignment => x_person_assignment
                            , x_return_status     => x_return_status
                            , x_return_message    => x_return_message
                            );

    hr_utility.set_location('Leaving: '|| l_proc, 30);
  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_per_asg_for_sch;

END per_get_elig;

/
