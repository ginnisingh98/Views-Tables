--------------------------------------------------------
--  DDL for Package Body PER_ABS_SHADOW_BOOKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_SHADOW_BOOKING_PKG" AS
  -- $Header: peabsbkg.pkb 120.0 2005/05/31 04:44:57 appldev noship $

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Validate the parameters passed in depending on the mode.
  --
  -----------------------------------------------------------------------------
  FUNCTION validate_params( p_mode          IN VARCHAR2
                          , p_person_id     IN NUMBER
                          , p_assignment_id IN NUMBER
                          , p_absence_id    IN NUMBER
                          , p_start_date    IN DATE
                          , p_end_date      IN DATE
                          ) RETURN BOOLEAN IS

    l_proc           VARCHAR2(50);
    e_invalid_params EXCEPTION;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.validate_params';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    IF p_mode IN ('CRE','UPD','DEL','GET') THEN
      -- Check that either person id or assignment id is supplied
      IF p_person_id IS NULL AND p_assignment_id IS NULL THEN
        RAISE e_invalid_params;
      END IF;
    END IF;

    hr_utility.set_location(l_proc, 20);

    IF p_mode IN ('CRE','UPD','DEL') THEN
      -- Check that absence id is supplied
      IF p_absence_id IS NULL THEN
        RAISE e_invalid_params;
      END IF;
    END IF;

    hr_utility.set_location(l_proc, 30);

    IF p_mode IN ('CRE') THEN
      -- Check that start date is supplied
      IF p_start_date IS NULL THEN
        RAISE e_invalid_params;
      END IF;
    END IF;

    hr_utility.set_location('Leaving: '|| l_proc, 40);

    RETURN TRUE;

  EXCEPTION

    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 50);
      RETURN FALSE;

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 60);
      hr_utility.set_location(SQLERRM, 65);
      RETURN FALSE;

  END validate_params;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Get the primary assignment for the given person identifier.
  --
  -----------------------------------------------------------------------------
  FUNCTION get_primary_asg(p_person_id  IN NUMBER
                          ,p_start_date IN DATE
                          ,p_end_date   IN DATE
                          ) RETURN NUMBER IS

    l_proc          VARCHAR2(50);
    l_assignment_id NUMBER;

    CURSOR c_prim_asg (cp_person_id  IN NUMBER
                      ,cp_start_date IN DATE
                      ,cp_end_date   IN DATE
                      ) IS
      SELECT assignment_id
      FROM   per_all_assignments_f
      WHERE  person_id = cp_person_id
      AND    primary_flag = 'Y'
      AND    effective_start_date <= NVL(cp_end_date, SYSDATE)
      AND    effective_end_date >= NVL(cp_start_date, SYSDATE);

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.get_primary_asg';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    OPEN c_prim_asg ( p_person_id
                    , p_start_date
                    , p_end_date
                    );
    FETCH c_prim_asg INTO l_assignment_id;
    CLOSE c_prim_asg;

    hr_utility.set_location('PerId:'||p_person_id||
                            ' AsgId:'||l_assignment_id, 20);

    RETURN l_assignment_id;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RETURN NULL;

  END get_primary_asg;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Get the booking type id for the booking type 'General'
  --
  -----------------------------------------------------------------------------
  FUNCTION get_bkg_type_id(p_bkg_type IN VARCHAR2) RETURN NUMBER IS

    l_proc        VARCHAR2(50);
    l_bkg_type_id NUMBER;

    CURSOR c_bkg_type_id (cp_bkg_type IN VARCHAR2) IS
      SELECT task_type_id
      FROM   jtf_task_types_vl
      WHERE  name = cp_bkg_type;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.get_bkg_type_id';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    OPEN c_bkg_type_id ( p_bkg_type
                       );
    FETCH c_bkg_type_id INTO l_bkg_type_id;
    CLOSE c_bkg_type_id;

    hr_utility.set_location('BkgTypId:'||l_bkg_type_id, 20);

    RETURN l_bkg_type_id;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RETURN NULL;

  END get_bkg_type_id;

  -----------------------------------------------------------------------------
  --
  -- Scope: PRIVATE
  --
  -- Get the booking id for the absence id.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_bkg_id(p_abs_id  IN         NUMBER
                      ,p_bkg_id  OUT NOCOPY NUMBER
                      ,p_bkg_ovn OUT NOCOPY NUMBER
                      ) IS

    l_proc    VARCHAR2(50);
    l_bkg_id  NUMBER;
    l_bkg_ovn NUMBER;

    CURSOR c_bkg_id (cp_abs_id IN NUMBER) IS
      SELECT task_type_id
            ,object_version_number
      FROM   jtf_tasks_vl
      WHERE  source_object_type_code = 'ABSENCE'
      AND    source_object_id = cp_abs_id;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.get_bkg_id';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    OPEN c_bkg_id ( p_abs_id );
    FETCH c_bkg_id INTO l_bkg_id
                       ,l_bkg_ovn;
    CLOSE c_bkg_id;

    hr_utility.set_location('BkgId:'||l_bkg_id||' BkgOVN:'||l_bkg_ovn, 20);

    p_bkg_id := l_bkg_id;
    p_bkg_ovn := l_bkg_ovn;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);

  END get_bkg_id;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- Create a shadow booking for the absence record against the primary
  -- assignment.
  --
  -----------------------------------------------------------------------------
  PROCEDURE create_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , p_start_date     IN         DATE
                                 , p_end_date       IN         DATE   DEFAULT NULL
                                 , x_booking_id     OUT NOCOPY NUMBER
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 ) IS

    l_proc           VARCHAR2(50);
    l_assignment_id  NUMBER;
    lr_new_booking   cac_bookings_pub.booking_type;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    e_invalid_params EXCEPTION;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.create_shadow_booking';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    x_booking_id := NULL;
    x_return_status := '0';
    x_return_message := '';

    IF NOT validate_params('CRE' -- Mode
                          ,p_person_id
                          ,p_assignment_id
                          ,p_absence_id
                          ,p_start_date
                          ,p_end_date
                          ) THEN
      RAISE e_invalid_params;
    END IF;

    hr_utility.set_location(l_proc, 20);

    IF p_person_id IS NOT NULL AND p_assignment_id IS NULL THEN
      l_assignment_id := get_primary_asg( p_person_id
                                        , p_start_date
                                        , p_end_date
                                        );
    END IF;

    hr_utility.set_location(l_proc, 30);

    -- Setup up the booking record details
    lr_new_booking.booking_id := NULL;
    lr_new_booking.resource_type_code := 'PERSON_ASSIGNMENT';
    IF p_assignment_id IS NULL THEN
      lr_new_booking.resource_id := l_assignment_id;
    ELSE
      lr_new_booking.resource_id := p_assignment_id;
    END IF;
    lr_new_booking.start_date := p_start_date;
    lr_new_booking.end_date := p_end_date;
    lr_new_booking.booking_type_id := get_bkg_type_id('General');
    lr_new_booking.booking_status_id := NULL;
    lr_new_booking.source_object_type_code := 'ABSENCE';
    lr_new_booking.source_object_id := p_absence_id;
    lr_new_booking.booking_subject := 'ABSENCE BOOKING';
    lr_new_booking.freebusytype := 'BUSY';

    hr_utility.set_location(l_proc, 40);

    -- Invoke JTF Bookings API
    cac_bookings_pub.create_booking
    ( p_api_version   => 1.0
    , p_init_msg_list => 'T'
    , p_commit        => 'T'
    , p_booking_rec   => lr_new_booking
    , x_booking_id    => x_booking_id
    , x_return_status => l_return_status
    , x_msg_count     => l_msg_count
    , x_msg_data      => l_msg_data
    );

    hr_utility.set_location(l_proc, 50);

    CASE l_return_status
      WHEN 'S' THEN
        x_return_status := '0';
      ELSE -- 'E', 'U', unknown
        x_return_status := '2';
        x_return_message := l_msg_data;
    END CASE;

    hr_utility.set_location('Leaving: '|| l_proc, 60);

  EXCEPTION

    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 70);
      x_return_status := '2';

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 80);
      hr_utility.set_location(SQLERRM, 85);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END create_shadow_booking;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- Update an existing shadow booking correcponding to changes to the
  -- absence record.
  --
  -----------------------------------------------------------------------------
  PROCEDURE update_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , p_start_date     IN         DATE
                                 , p_end_date       IN         DATE
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 ) IS

    l_proc           VARCHAR2(50);
    l_assignment_id  NUMBER;
    l_booking_ovn    NUMBER;
    lr_booking       cac_bookings_pub.booking_type;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    e_invalid_params EXCEPTION;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.update_shadow_booking';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    x_return_status := '0';
    x_return_message := '';

    IF NOT validate_params('UPD' -- Mode
                          ,p_person_id
                          ,p_assignment_id
                          ,p_absence_id
                          ,p_start_date
                          ,p_end_date
                          ) THEN
      RAISE e_invalid_params;
    END IF;

    hr_utility.set_location(l_proc, 20);

    IF p_person_id IS NOT NULL AND p_assignment_id IS NULL THEN
      l_assignment_id := get_primary_asg( p_person_id
                                        , p_start_date
                                        , p_end_date
                                        );
    END IF;

    hr_utility.set_location(l_proc, 30);

    -- Get the booking details
    get_bkg_id( p_absence_id
              , lr_booking.booking_id
              , l_booking_ovn
              );

    hr_utility.set_location(l_proc, 40);

    -- Setup up the booking record details
    lr_booking.resource_type_code := 'PERSON_ASSIGNMENT';
    IF p_assignment_id IS NULL THEN
      lr_booking.resource_id := l_assignment_id;
    ELSE
      lr_booking.resource_id := p_assignment_id;
    END IF;
    lr_booking.start_date := p_start_date;
    lr_booking.end_date := p_end_date;
    lr_booking.booking_type_id := get_bkg_type_id('General');
    lr_booking.booking_status_id := NULL;
    lr_booking.source_object_type_code := 'ABSENCE';
    lr_booking.source_object_id := p_absence_id;
    lr_booking.booking_subject := 'ABSENCE BOOKING';
    lr_booking.freebusytype := 'BUSY';

    hr_utility.set_location(l_proc, 50);

    -- Invoke JTF Bookings API
    cac_bookings_pub.update_booking
    ( p_api_version           => 1.0
    , p_init_msg_list         => 'T'
    , p_commit                => 'T'
    , p_booking_rec           => lr_booking
    , p_object_version_number => l_booking_ovn
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    hr_utility.set_location(l_proc, 60);

    CASE l_return_status
      WHEN 'S' THEN
        x_return_status := '0';
      ELSE -- 'E', 'U', unknown
        x_return_status := '2';
        x_return_message := l_msg_data;
    END CASE;

    hr_utility.set_location('Leaving: '|| l_proc, 70);

  EXCEPTION

    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 80);
      x_return_status := '2';

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 90);
      hr_utility.set_location(SQLERRM, 95);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END update_shadow_booking;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- Delete an existing shadow booking correcponding to delete of the
  -- absence record.
  --
  -----------------------------------------------------------------------------
  PROCEDURE delete_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                                 , p_assignment_id  IN         NUMBER DEFAULT NULL
                                 , p_absence_id     IN         NUMBER
                                 , x_return_status  OUT NOCOPY NUMBER
                                 , x_return_message OUT NOCOPY VARCHAR2
                                 ) IS

    l_proc           VARCHAR2(50);
    l_assignment_id  NUMBER;
    l_booking_id     NUMBER;
    l_booking_ovn    NUMBER;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    e_invalid_params EXCEPTION;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.delete_shadow_booking';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    x_return_status := '0';
    x_return_message := '';

    IF NOT validate_params('DEL' -- Mode
                          ,p_person_id
                          ,p_assignment_id
                          ,p_absence_id
                          ,NULL -- Start Date
                          ,NULL -- End Date
                          ) THEN
      RAISE e_invalid_params;
    END IF;

    hr_utility.set_location(l_proc, 20);

    IF p_person_id IS NOT NULL AND p_assignment_id IS NULL THEN
      l_assignment_id := get_primary_asg( p_person_id
                                        , NULL -- start date
                                        , NULL -- end date
                                        );
    END IF;

    hr_utility.set_location(l_proc, 30);

    -- Get the booking details
    get_bkg_id( p_absence_id
              , l_booking_id
              , l_booking_ovn
              );

    hr_utility.set_location(l_proc, 40);

    -- Invoke JTF Bookings API
    cac_bookings_pub.delete_booking
    ( p_api_version           => 1.0
    , p_init_msg_list         => 'T'
    , p_commit                => 'T'
    , p_booking_id            => l_booking_id
    , p_object_version_number => l_booking_ovn
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    hr_utility.set_location(l_proc, 50);

    CASE l_return_status
      WHEN 'S' THEN
        x_return_status := '0';
      ELSE -- 'E', 'U', unknown
        x_return_status := '2';
        x_return_message := l_msg_data;
    END CASE;

    hr_utility.set_location('Leaving: '|| l_proc, 60);

  EXCEPTION

    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 70);
      x_return_status := '2';

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 80);
      hr_utility.set_location(SQLERRM, 85);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END delete_shadow_booking;

  -----------------------------------------------------------------------------
  --
  -- Scope: PUBLIC
  --
  -- Retrieve absences as shadow bookings for the given person assignment.
  --
  -----------------------------------------------------------------------------
  PROCEDURE get_shadow_booking( p_person_id      IN         NUMBER DEFAULT NULL
                              , p_assignment_id  IN         NUMBER DEFAULT NULL
                              , p_start_date     IN         DATE   DEFAULT NULL
                              , p_end_date       IN         DATE   DEFAULT NULL
                              , x_bookings       OUT NOCOPY per_abs_booking_varray
                              , x_return_status  OUT NOCOPY NUMBER
                              , x_return_message OUT NOCOPY VARCHAR2
                              ) IS

    l_proc           VARCHAR2(50);
    l_booking_obj    per_abs_booking_obj;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    e_invalid_params EXCEPTION;

    TYPE cur_type IS REF CURSOR;
    c_bkgs cur_type;

  BEGIN

    l_proc := 'per_abs_shadow_booking_pkg.get_shadow_booking';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_booking_obj := per_abs_booking_obj(NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL);
    x_bookings := per_abs_booking_varray();
    x_return_status := '0';
    x_return_message := '';

    IF NOT validate_params('GET' -- Mode
                          ,p_person_id
                          ,p_assignment_id
                          ,NULL -- Absence Id
                          ,p_start_date
                          ,p_end_date
                          ) THEN
      RAISE e_invalid_params;
    END IF;

    hr_utility.set_location(l_proc, 20);

    -- Cursor to fetch bookings
    OPEN c_bkgs FOR ' SELECT T.task_id'||
                           ',T.source_object_id'||
                           ',T.task_name'||
                           ',TA.booking_start_date'||
                           ',TA.booking_end_date'||
                           ',TA.free_busy_type'||
                    ' FROM jtf_tasks_vl T'||
                         ',jtf_task_assignments TA'||
                    ' WHERE T.entity = "BOOKING"'||
                    ' AND T.task_id = TA.task_id'||
                    ' AND T.source_object_type_code = "ABSENCE"'||
                    ' AND TA.resource_type_code = "PERSON_ASSIGNMENT"'||
                    ' AND TA.resource_id = :1'||
                    ' AND TA.booking_start_date <= NVL(:2, TA.booking_start_date)'||
                    ' AND TA.booking_end_date >= NVL(:3, TA.booking_end_date)'
                    USING p_assignment_id
                         ,p_start_date
                         ,p_end_date;

    hr_utility.set_location(l_proc, 30);

    LOOP -- loop for bookings
      FETCH c_bkgs INTO l_booking_obj.booking_id
                       ,l_booking_obj.absence_id
                       ,l_booking_obj.booking_name
                       ,l_booking_obj.start_date
                       ,l_booking_obj.end_date
                       ,l_booking_obj.free_busy;
      EXIT WHEN c_bkgs%NOTFOUND;

      hr_utility.set_location('BkgId:'||l_booking_obj.booking_id||
                             ' AbsId:'||l_booking_obj.absence_id, 35);

      -- Save object to array
      x_bookings.EXTEND(1);
      x_bookings(x_bookings.COUNT) := l_booking_obj;

    END LOOP; -- loop for bookings
    CLOSE c_bkgs;

    hr_utility.set_location('Leaving: '|| l_proc, 40);

  EXCEPTION

    WHEN e_invalid_params THEN
      hr_utility.set_location('Leaving: '|| l_proc, 50);
      x_return_status := '2';

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 60);
      hr_utility.set_location(SQLERRM, 65);
      x_return_status := '2';
      x_return_message := SQLERRM;

  END get_shadow_booking;

END per_abs_shadow_booking_pkg;

/
