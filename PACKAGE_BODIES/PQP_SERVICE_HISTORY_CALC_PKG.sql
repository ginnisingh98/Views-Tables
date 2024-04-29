--------------------------------------------------------
--  DDL for Package Body PQP_SERVICE_HISTORY_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SERVICE_HISTORY_CALC_PKG" as
/* $Header: pqshpcal.pkb 120.0 2005/05/29 02:11:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< calculate_period >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE calculate_period (p_start_date in     date
                           ,p_end_date   in     date
                           ,p_days          out nocopy number
                           ) IS
  --
  -- Calculate the number of days for given dates
  --
  l_proc       VARCHAR2(60) := 'pqp_service_history_calc_pkg.calculate_period';
  l_start_date DATE         := trunc(p_start_date);
  l_end_date   DATE         := trunc(p_end_date);
  l_days       NUMBER(12);
  --
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  SELECT l_end_date - l_start_date
  INTO   l_days
  FROM   dual;
  --
  l_days := l_days + 1;
  p_days := l_days;
  --
  hr_utility.set_location('Leaving: '||l_proc, 20);


-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
       p_days := 0;
       raise;

  --
END calculate_period;
--
-- ----------------------------------------------------------------------------
-- |---------------------< calculate_current_service >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_current_service (p_calculation_date   in     date
                                   ,p_assignment_id      in     number
                                   ,p_continuous_service in     varchar2
                                   ) RETURN number IS
  --
  -- Calculate the current service period for a given assignment
  --
  CURSOR c_curr_serv IS
  SELECT pps.date_start
  FROM   per_periods_of_service pps
        ,per_all_assignments_f  asg
  WHERE  pps.period_of_service_id = asg.period_of_service_id
    AND  trunc(p_calculation_date) BETWEEN trunc(asg.effective_start_date)
                                                         AND trunc(asg.effective_end_date)
    AND  asg.assignment_id  = p_assignment_id
    AND  not exists (SELECT 1 FROM pqp_service_history_periods shp
                     WHERE  trunc(pps.date_start) BETWEEN trunc(shp.start_date)
                                                      AND trunc(shp.end_date)
                       AND  shp.assignment_id      = p_assignment_id
                       AND  shp.continuous_service = NVL(p_continuous_service, shp.continuous_service));
  --
  l_func       VARCHAR2(60) := 'pqp_service_history_calc_pkg.calculate_current_service';
  l_days       NUMBER(12) := 0 ;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_func, 10);
  --
  FOR c_curr_serv_rec IN c_curr_serv LOOP
      --
      -- Calculate the service period
      --
      calculate_period (p_start_date => c_curr_serv_rec.date_start
                       ,p_end_date   => p_calculation_date
                       ,p_days       => l_days
                       );
      --
      hr_utility.set_location(l_func, 20);
  END LOOP;
  --
  return l_days;
  --
  hr_utility.set_location('Leaving: '||l_func, 30);
  --
END calculate_current_service;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< convert_years_to_days >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE convert_years_to_days (p_start_date    in     date
                                ,p_period_years  in     number
                                ,p_days             out nocopy number) IS
  --
  l_proc       VARCHAR2(60) := 'pqp_service_history_calc_pkg.convert_years_to_days';
  l_days       NUMBER(12) := 0 ;
  l_end_date   DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  SELECT ADD_MONTHS(p_start_date,(p_period_years * 12))
  INTO l_end_date
  FROM dual;

  hr_utility.set_location(l_proc, 20);
  SELECT l_end_date - p_start_date
  INTO l_days
  FROM dual;

  p_days := l_days;

  hr_utility.set_location('Leaving: '||l_proc, 30);
  --
END convert_years_to_days;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_overlap_curr_serv >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE check_overlap_curr_serv (p_start_date       in     date
                                  ,p_end_date         in     date
                                  ,p_period_years     in     number
                                  ,p_period_days      in     number
                                  ,p_assignment_id    in     number
                                  ,p_calculation_date in     date
                                  ,p_days                out nocopy number) IS

  --
  -- Check whether this service history period overlaps
  -- with the current service period
  --
  CURSOR c_overlap_serv2 IS
  SELECT NULL
  FROM   per_periods_of_service pps
        ,per_all_assignments_f  asg
  WHERE  pps.period_of_service_id = asg.period_of_service_id
    AND  trunc(pps.date_start) between trunc(p_start_date)
                                   and trunc(p_end_date)
    AND  trunc(p_calculation_date) between trunc(asg.effective_start_date)
                                       and trunc(asg.effective_end_date)
    AND  asg.assignment_id = p_assignment_id ;
  --
  l_proc       VARCHAR2(60) := 'pqp_service_history_calc_pkg.check_overlap_curr_serv';
  l_days       NUMBER(12) := 0 ;
  l_exists     VARCHAR2(1);
  --
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  OPEN c_overlap_serv2;
  FETCH c_overlap_serv2 INTO l_exists;
  hr_utility.set_location (l_proc, 20);
  If c_overlap_serv2%FOUND THEN

     --
     -- Reset the end_date to calculation_date
     -- Calculate the service period
     --
     calculate_period (p_start_date => p_start_date
                      ,p_end_date   => p_calculation_date
                      ,p_days       => l_days
                      );
  Else
     --
     -- Pass the end date value
     -- Calculate the service period
     --
     -- Check period years or period days have a value
     -- PS Bug 2028104 for details
     --

     If p_period_years Is Null And
        p_period_days  Is Null Then

        calculate_period (p_start_date => p_start_date
                         ,p_end_date   => p_end_date
                         ,p_days       => l_days
                         );

     Else

        -- The following conversion of years to days
        -- is incorrect as 365 days for a year will be incorrect
        -- for leap years
        -- See Bug 4318334 for details

        -- l_days := nvl(p_period_years,0) * 365;
        l_days := 0;
        IF NVL(p_period_years, 0) <> 0 THEN
          hr_utility.set_location(l_proc, 25);
          convert_years_to_days (p_start_date   => p_start_date
                                ,p_period_years => p_period_years
                                ,p_days         => l_days
                                );
        END IF; -- End if of period years is not zero...
        l_days := l_days + nvl(p_period_days,0);


     End If; -- End of of period check...

  End If;
  CLOSE c_overlap_serv2;
  --
  p_days := l_days;
  hr_utility.set_location('Leaving: '||l_proc, 30);
  --

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
       p_days := 0;
       raise;

END check_overlap_curr_serv;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_service_history >----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_service_history (p_assignment_id    in number
                                   ,p_calculation_date in date
                                   ) RETURN number IS
  --
  -- This function should query back every period of service for the given
  -- assignment, and add them together, finally adding on the length of the
  -- current period of service, up to and including p_calculation_date.
  -- The result should be returned in days.
  --
  -- Select years and days as we need not calculate period if they have a value
  -- PS bug # for details
  --
  CURSOR c_serv_hist IS
  SELECT start_date
        ,LEAST(trunc(end_date), trunc(p_calculation_date)) end_date
        ,DECODE(LEAST(trunc(end_date), trunc(p_calculation_date)), trunc(end_date),
                                      period_years, NULL) period_years
        ,DECODE(LEAST(trunc(end_date), trunc(p_calculation_date)), trunc(end_date),
                                      period_days, NULL) period_days
  FROM   pqp_service_history_periods shp1
  WHERE  shp1.assignment_id      = p_assignment_id
    AND  trunc(shp1.start_date) <= trunc(p_calculation_date)
    AND  not exists (SELECT 1 FROM pqp_service_history_periods shp2
                     WHERE  shp2.assignment_id              = shp1.assignment_id
                       AND  shp2.service_history_period_id <> shp1.service_history_period_id
                       AND  (trunc(shp2.start_date) between trunc(shp1.start_date)
                                                                 and trunc(shp1.end_date)
                             or trunc(shp2.end_date) between trunc(shp1.start_date)
                                                                  and trunc(shp1.end_date)
                             or trunc(shp1.start_date) between trunc(shp2.start_date)
                                                                 and trunc(shp2.end_date)
                             or trunc(shp1.end_date) between trunc(shp2.start_date)
                                                                  and trunc(shp2.end_date)));
  --
  CURSOR c_overlap_serv IS
  SELECT MIN(shp1.start_date) start_date
        ,LEAST(trunc(MAX(shp1.end_date)),trunc(p_calculation_date)) end_date
  FROM   pqp_service_history_periods shp1
  WHERE  shp1.assignment_id      = p_assignment_id
    AND  trunc(shp1.start_date) <= trunc(p_calculation_date)
    AND  exists (SELECT 1 FROM pqp_service_history_periods shp2
                     WHERE  shp2.assignment_id              = shp1.assignment_id
                       AND  shp2.service_history_period_id <> shp1.service_history_period_id
                       AND  (trunc(shp2.start_date) between trunc(shp1.start_date)
                                                                 and trunc(shp1.end_date)
                             or trunc(shp2.end_date) between trunc(shp1.start_date)
                                                                  and trunc(shp1.end_date)
                             or trunc(shp1.start_date) between trunc(shp2.start_date)
                                                                 and trunc(shp2.end_date)
                             or trunc(shp1.end_date) between trunc(shp2.start_date)
                                                                  and trunc(shp2.end_date)));
  --
  l_func     VARCHAR2(60) := 'pqp_service_history_calc_pkg.calculate_service_history';
  l_days     NUMBER(12);
  l_tot_days NUMBER(12)   := 0;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_func, 10);
  --
  FOR c_serv_hist_rec in c_serv_hist LOOP

     If c_serv_hist_rec.start_date IS NOT NULL And
        c_serv_hist_rec.end_date   IS NOT NULL Then
        --
        -- Before calculating check whether this date
        -- overlaps with current service period
        --
        hr_utility.set_location(l_func, 20);
        check_overlap_curr_serv (p_start_date       => c_serv_hist_rec.start_date
                                ,p_end_date         => c_serv_hist_rec.end_date
                                ,p_period_years     => c_serv_hist_rec.period_years
                                ,p_period_days      => c_serv_hist_rec.period_days
                                ,p_assignment_id    => p_assignment_id
                                ,p_calculation_date => p_calculation_date
                                ,p_days             => l_days
                                );
        --
        l_tot_days := l_tot_days + l_days;
        --
     End If;
     --
     hr_utility.set_location(l_func, 30);
  END LOOP;
  --
  FOR c_overlap_rec IN c_overlap_serv LOOP
      If c_overlap_rec.start_date IS NOT NULL And
         c_overlap_rec.end_date   IS NOT NULL Then
         --
         -- Before calculating check whether this date
         -- overlaps with current service period
         --
         hr_utility.set_location(l_func, 40);
         check_overlap_curr_serv (p_start_date       => c_overlap_rec.start_date
                                 ,p_end_date         => c_overlap_rec.end_date
                                 ,p_period_years     => NULL
                                 ,p_period_days      => NULL
                                 ,p_assignment_id    => p_assignment_id
                                 ,p_calculation_date => p_calculation_date
                                 ,p_days             => l_days
                                 );
         --
         l_tot_days := l_tot_days + l_days;
         --
      End If;
      --
      hr_utility.set_location(l_func, 50);
  END LOOP;
  --
  --
  -- Calculate the current service period
  --
  l_days := calculate_current_service (p_calculation_date   => p_calculation_date
                                      ,p_assignment_id      => p_assignment_id
                                      ,p_continuous_service => NULL
                                      );
  l_tot_days := l_tot_days + l_days;
  --
  hr_utility.set_location(l_func, 60);
  --
  return l_tot_days;
  --
  hr_utility.set_location('Leaving: '||l_func, 70);
  --
END calculate_service_history;
--
-- Added this new function
-- PS Bug 2028104 for details
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_all_service_history >----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_all_service_history (p_assignment_id    in number
                                       ) RETURN number IS
  --
  -- This function should query back every period of service for the given
  -- assignment, and add them together, finally adding on the length of the
  -- current period of service
  -- The result should be returned in days.
  --

  CURSOR c_all_serv_hist IS
  SELECT start_date
        ,end_date
        ,period_years
        ,period_days
  FROM pqp_service_history_periods shp1
  WHERE  shp1.assignment_id = p_assignment_id;
  --
  l_func     VARCHAR2(80) := 'pqp_service_history_calc_pkg.calculate_all_service_history';
  l_days     NUMBER(12);
  l_tot_days NUMBER(12)   := 0;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_func, 10);
  --
  FOR c_all_serv_hist_rec in c_all_serv_hist LOOP

      --
      -- Calculate period if period_years and period_days do not have values
      --
      hr_utility.set_location(l_func, 20);

      If c_all_serv_hist_rec.period_years Is Null And
         c_all_serv_hist_rec.period_days Is Null Then

         calculate_period (p_start_date => c_all_serv_hist_rec.start_date
                          ,p_end_date   => c_all_serv_hist_rec.end_date
                          ,p_days       => l_days
                          );

      Else

        -- The following conversion of years to days
        -- is incorrect as 365 days for a year will be incorrect
        -- for leap years
        -- See Bug 4318334 for details

        -- l_days := nvl(c_all_serv_hist_rec.period_years,0) * 365;;
        l_days := 0;
        IF NVL(c_all_serv_hist_rec.period_years, 0) <> 0 THEN
          hr_utility.set_location(l_func, 25);
          convert_years_to_days (p_start_date   => c_all_serv_hist_rec.start_date
                                ,p_period_years => c_all_serv_hist_rec.period_years
                                ,p_days         => l_days
                                );
        END IF; -- End if of period years is not zero...
        l_days := l_days + nvl(c_all_serv_hist_rec.period_days,0);

      End If; -- End if of period check...

      --
      l_tot_days := l_tot_days + l_days;
      --

  END LOOP;

  --
  hr_utility.set_location(l_func, 30);
  --
  return l_tot_days;
  --
  hr_utility.set_location('Leaving: '||l_func, 40);
  --
END calculate_all_service_history;
--
-- ----------------------------------------------------------------------------
-- |---------------------< calculate_continuous_service >---------------------|
-- ----------------------------------------------------------------------------
FUNCTION calculate_continuous_service (p_assignment_id    in number
                                      ,p_calculation_date in date
                                      ) RETURN number IS
  --
  -- This function should query back every period of service for the given
  -- assignment, where the continuous service flag has been checked, and add
  -- them together, finally adding on the length of the current period of
  -- service, up to and including p_calculation_date.
  -- The result should be returned in days.
  --
  -- Select years and days as we need not calculate period if they have a value
  -- PS bug # for details
  --

  CURSOR c_cont_serv IS
  SELECT start_date
        ,LEAST(trunc(end_date), trunc(p_calculation_date)) end_date
        ,DECODE(LEAST(trunc(end_date), trunc(p_calculation_date)), trunc(end_date),
                                      period_years, NULL) period_years
        ,DECODE(LEAST(trunc(end_date), trunc(p_calculation_date)), trunc(end_date),
                                      period_days, NULL) period_days
  FROM   pqp_service_history_periods shp1
  WHERE  shp1.assignment_id      = p_assignment_id
    AND  trunc(shp1.start_date) <= trunc(p_calculation_date)
    AND  shp1.continuous_service = 'Y'
    AND  not exists (SELECT 1 FROM pqp_service_history_periods shp2
                     WHERE  shp2.assignment_id              = shp1.assignment_id
                       AND  shp2.continuous_service         = 'Y'
                       AND  shp2.service_history_period_id <> shp1.service_history_period_id
                       AND  (trunc(shp2.start_date) between trunc(shp1.start_date)
                                                                 and trunc(shp1.end_date)
                             or trunc(shp2.end_date) between trunc(shp1.start_date)
                                                                  and trunc(shp1.end_date)
                             or trunc(shp1.start_date) between trunc(shp2.start_date)
                                                                 and trunc(shp2.end_date)
                             or trunc(shp1.end_date) between trunc(shp2.start_date)
                                                                  and trunc(shp2.end_date)));
  --
  CURSOR c_cont_overlap_serv IS
  SELECT MIN(shp1.start_date) start_date
        ,LEAST(trunc(MAX(shp1.end_date)), trunc(p_calculation_date)) end_date
  FROM   pqp_service_history_periods shp1
  WHERE  shp1.assignment_id      = p_assignment_id
    AND  trunc(shp1.start_date) <= trunc(p_calculation_date)
    AND  shp1.continuous_service = 'Y'
    AND  exists (SELECT 1 FROM pqp_service_history_periods shp2
                     WHERE  shp2.assignment_id              = shp1.assignment_id
                       AND  shp2.continuous_service         = 'Y'
                       AND  shp2.service_history_period_id <> shp1.service_history_period_id
                       AND  (trunc(shp2.start_date) between trunc(shp1.start_date)
                                                                 and trunc(shp1.end_date)
                             or trunc(shp2.end_date) between trunc(shp1.start_date)
                                                                  and trunc(shp1.end_date)
                             or trunc(shp1.start_date) between trunc(shp2.start_date)
                                                                 and trunc(shp2.end_date)
                             or trunc(shp1.end_date) between trunc(shp2.start_date)
                                                                  and trunc(shp2.end_date)));
  --
  l_func     VARCHAR2(60) := 'pqp_service_history_calc_pkg.calculate_continuous_service';
  l_days     NUMBER(12);
  l_tot_days NUMBER(12)   := 0;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_func, 10);
  --
  FOR c_cont_serv_rec IN c_cont_serv LOOP
      If c_cont_serv_rec.start_date IS NOT NULL And
         c_cont_serv_rec.end_date   IS NOT NULL Then
         --
         -- Before calculating check whether this date
         -- overlaps with current service period
         --
         hr_utility.set_location(l_func, 20);
         check_overlap_curr_serv (p_start_date       => c_cont_serv_rec.start_date
                                 ,p_end_date         => c_cont_serv_rec.end_date
                                 ,p_period_years     => c_cont_serv_rec.period_years
                                 ,p_period_days      => c_cont_serv_rec.period_days
                                 ,p_assignment_id    => p_assignment_id
                                 ,p_calculation_date => p_calculation_date
                                 ,p_days             => l_days
                                 );
         --
         l_tot_days := l_tot_days + l_days;
         --
      End If;
  END LOOP;
  hr_utility.set_location(l_func, 30);
  --
  FOR c_cont_overlap_rec IN c_cont_overlap_serv LOOP
      If c_cont_overlap_rec.start_date IS NOT NULL And
         c_cont_overlap_rec.end_date   IS NOT NULL Then
         --
         -- Before calculating check whether this date
         -- overlaps with current service period
         --
         hr_utility.set_location(l_func, 40);
         check_overlap_curr_serv (p_start_date       => c_cont_overlap_rec.start_date
                                 ,p_end_date         => c_cont_overlap_rec.end_date
                                 ,p_period_years     => NULL
                                 ,p_period_days      => NULL
                                 ,p_assignment_id    => p_assignment_id
                                 ,p_calculation_date => p_calculation_date
                                 ,p_days             => l_days
                                 );
         --
         l_tot_days := l_tot_days + l_days;
         --
      End If;
  END LOOP;
  hr_utility.set_location(l_func, 50);
  --
  -- Calculate the current service period
  --
  l_days := calculate_current_service (p_calculation_date   => p_calculation_date
                                      ,p_assignment_id      => p_assignment_id
                                      ,p_continuous_service => 'Y'
                                      );
  l_tot_days := l_tot_days + l_days;
  --
  hr_utility.set_location(l_func, 60);
  --
  return l_tot_days;
  --
  hr_utility.set_location('Leaving: '||l_func, 70);
  --
END calculate_continuous_service;
--
-- Added this new function
-- PS Bug 2028104 for details
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_all_continuous_serv >------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_all_continuous_serv (p_assignment_id    in number
                                       ) RETURN number IS
  --
  -- This function should query back every period of service that is continuous for the given
  -- assignment, and add them together, finally adding on the length of the
  -- current period of service
  -- The result should be returned in days.
  --

  CURSOR c_all_cont_serv IS
  SELECT start_date
        ,end_date
        ,period_years
        ,period_days
  FROM pqp_service_history_periods shp1
  WHERE  shp1.assignment_id      = p_assignment_id
    AND  shp1.continuous_service = 'Y';
  --
  l_func     VARCHAR2(80) := 'pqp_service_history_calc_pkg.calculate_all_continuous_serv';
  l_days     NUMBER(12);
  l_tot_days NUMBER(12)   := 0;
  --
BEGIN
  hr_utility.set_location('Entering: '||l_func, 10);
  --
  FOR c_all_cont_serv_rec in c_all_cont_serv LOOP

      --
      -- Calculate period if period_years and period_days do not have values
      --
      hr_utility.set_location(l_func, 20);

      If c_all_cont_serv_rec.period_years Is Null And
         c_all_cont_serv_rec.period_days Is Null Then

         calculate_period (p_start_date => c_all_cont_serv_rec.start_date
                          ,p_end_date   => c_all_cont_serv_rec.end_date
                          ,p_days       => l_days
                          );

      Else

        -- The following conversion of years to days
        -- is incorrect as 365 days for a year will be incorrect
        -- for leap years
        -- See Bug 4318334 for details

        -- l_days := nvl(c_all_cont_serv_rec.period_years,0) * 365;
        l_days := 0;
        IF NVL(c_all_cont_serv_rec.period_years, 0) <> 0 THEN
          hr_utility.set_location(l_func, 25);
          convert_years_to_days (p_start_date   => c_all_cont_serv_rec.start_date
                                ,p_period_years => c_all_cont_serv_rec.period_years
                                ,p_days         => l_days
                                );
        END IF; -- End if of period years is not zero...
        l_days := l_days + nvl(c_all_cont_serv_rec.period_days,0);

      End If; -- End if of period check...

      --
      l_tot_days := l_tot_days + l_days;
      --

  END LOOP;

  --
  hr_utility.set_location(l_func, 30);
  --
  return l_tot_days;
  --
  hr_utility.set_location('Leaving: '||l_func, 40);
  --
END calculate_all_continuous_serv;
--
-- ----------------------------------------------------------------------------
-- |-------------------< calculate_service_hist_period >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE calculate_service_hist_period (p_start_date in     date
                                        ,p_end_date   in     date
                                        ,p_years         out nocopy number
                                        ,p_days          out nocopy number
                                        ) IS
  --
  -- This procedure should calculate the duration of a particular period of
  -- service history.
  -- The result should be returned in years and days.
  --
  l_proc           VARCHAR2(60) := 'pqp_service_history_calc_pkg.calculate_service_hist_period';
  l_start_date     DATE         := trunc(p_start_date);
  l_new_start_date DATE;
  -- include the end date so set the date to +1
  l_end_date       DATE         := trunc(p_end_date) + 1;
  l_tot_days       NUMBER(12);
  l_years          NUMBER(12);
  l_days           NUMBER(12);
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  SELECT (l_end_date - l_start_date)
  INTO   l_tot_days
  FROM   dual;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- The following conversion of days to years
  -- is incorrect as 365 days for a year will be incorrect
  -- for leap years
  -- See Bug 4318334 for details

  -- l_years := trunc(l_tot_days/365);
  --
  -- hr_utility.set_location(l_proc, 40);
  --

--   SELECT MOD(l_tot_days,365)
--   INTO   l_days
--   FROM   dual;
--
--   l_days  := l_days + 1 ;
--   --
--   IF l_days = 365 THEN
--      l_days  := 0;
--      l_years := l_years + 1;
--   END IF;

  -- Get the number of years based on date using MONTHS_BETWEEN function
  SELECT TRUNC(MONTHS_BETWEEN(l_end_date, l_start_date)/12)
  INTO l_years
  FROM dual;

  -- Get the new start date based on the l_years figure from the start date

  hr_utility.set_location(l_proc, 40);
  SELECT ADD_MONTHS(l_start_date, l_years * 12)
  INTO l_new_start_date
  FROM dual;

  -- Get the number of days based on this new start date

  hr_utility.set_location(l_proc, 50);
  SELECT l_end_date - l_new_start_date
  INTO l_days
  FROM dual;


  --
  p_years := l_years;
  p_days  := l_days;
  --
  hr_utility.set_location('Leaving: '||l_proc, 60);
  --

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
       p_years := 0;
       p_days  := 0;
       raise;


END calculate_service_hist_period;
--
END pqp_service_history_calc_pkg;

/
