--------------------------------------------------------
--  DDL for Package Body PER_GB_ABSENCE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_ABSENCE_RULES" AS
/* $Header: pegbabsr.pkb 120.8.12010000.8 2008/12/15 11:27:54 npannamp ship $ */


-------------------------------------------------------------------------------
-- CHECK_ABS_OVERLAP
---------------------------------------------------------------------------------
-- Bug 6708992
-- Procedure to raise error if overlapping absences of same type are present
/*
-- Bug 7447080
-- The below procedure is commented as c_abs_overlap_another cursor errors for different NLS calendar settings.
-- The cursor is modified so that the to_date and to_char functions are removed and handled in for loop of the cursor.
PROCEDURE check_abs_overlap( p_person_id  IN NUMBER
                               ,p_date_start IN DATE
                               ,p_date_end   IN DATE
                               ,p_time_start IN VARCHAR2
                               ,p_time_end IN VARCHAR2
                               ,p_absence_attendance_id IN NUMBER
                               --,p_absence_attendance_type_id IN NUMBER) IS    --Absence category instead of Absence type 6888892
                              ,p_absence_category IN VARCHAR2) IS

-- 6888892 Changed this cursor, so that the check is based on Absence Categories
     cursor c_abs_overlap_another is
     select 1
     from   per_absence_attendances abs, per_absence_attendance_types paat
     where  paat.absence_category = p_absence_category
     and    paat.absence_attendance_type_id = abs.absence_attendance_type_id
     and    abs.person_id = p_person_id
     and    (p_absence_attendance_id is null or
             p_absence_attendance_id <> abs.absence_attendance_id)
     and    abs.date_start is not null
     and    p_date_start is not null
     and   ((
            to_date(to_char(abs.date_start,'YYYY-MM-DD')|| ' ' ||
            nvl(abs.time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
            between
            to_date(to_char(p_date_start,'YYYY-MM-DD')|| ' ' ||
            nvl(p_time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
            AND
            to_date(to_char(nvl(p_date_end,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
            nvl(p_time_end,'23:59'),'YYYY-MM-DD HH24:MI:SS'))
          OR
            (
             to_date(to_char(p_date_start,'YYYY-MM-DD')|| ' ' ||
             nvl(p_time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
            between
            to_date(to_char(abs.date_start,'YYYY-MM-DD')|| ' ' ||
            nvl(abs.time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
            AND
            to_date(to_char(nvl(abs.date_end,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
            nvl(abs.time_end,'23:59'),'YYYY-MM-DD HH24:MI:SS')
       )
       );

       l_exists NUMBER ;
BEGIN
       open c_abs_overlap_another;
       fetch c_abs_overlap_another INTO l_exists;
       if c_abs_overlap_another%found then
            close c_abs_overlap_another;
    		hr_utility.set_message(804,'SSP_35084_SIMILAR_ABS_OVERLAP');
    		hr_utility.raise_error;
       else
	        close c_abs_overlap_another;
       end if ;
END check_abs_overlap;
*/
PROCEDURE check_abs_overlap( p_person_id  IN NUMBER
                               ,p_date_start IN DATE
                               ,p_date_end   IN DATE
                               ,p_time_start IN VARCHAR2
                               ,p_time_end IN VARCHAR2
                               ,p_absence_attendance_id IN NUMBER
                               --,p_absence_attendance_type_id IN NUMBER) IS    --Absence category instead of Absence type 6888892
                              ,p_absence_category IN VARCHAR2) IS

cursor c_abs_overlap_another is
select nvl(abs.time_start,'00:00') start_time, nvl(abs.time_end,'23:59') end_time
from   per_absence_attendances abs, per_absence_attendance_types paat
where  paat.absence_category = p_absence_category
and    paat.absence_attendance_type_id = abs.absence_attendance_type_id
and    abs.person_id = p_person_id
and    (p_absence_attendance_id is null or
     p_absence_attendance_id <> abs.absence_attendance_id)
and    abs.date_start is not null
and    p_date_start is not null
and   (abs.date_start between p_date_start AND nvl(p_date_end,hr_api.g_eot)
       OR
    p_date_start between abs.date_start and nvl(abs.date_end,hr_api.g_eot) )
order by 1;

b_over_lap boolean := false;

begin
hr_utility.trace('Entering check_abs_overlap ');
hr_utility.trace('check_abs_overlap p_person_id:'||p_person_id);
hr_utility.trace('check_abs_overlap p_date_start:'||p_date_start);
hr_utility.trace('check_abs_overlap p_date_end:'||p_date_end);
hr_utility.trace('check_abs_overlap p_time_start:'||nvl(p_time_start,'NULL'));
hr_utility.trace('check_abs_overlap p_time_end:'||nvl(p_time_end,'NULL'));
hr_utility.trace('check_abs_overlap p_absence_attendance_id:'||p_absence_attendance_id);
hr_utility.trace('check_abs_overlap hr_api.g_eot:'||hr_api.g_eot);

for i in c_abs_overlap_another
loop
hr_utility.trace('check_abs_overlap i.end_time:'||i.end_time);
if nvl(p_time_start,'00:00') <= i.end_time then
	b_over_lap := true;
	exit;
end if;
end loop;

if b_over_lap then
	hr_utility.trace('check_abs_overlap Overlapping Exists');
	hr_utility.set_message(804,'SSP_35084_SIMILAR_ABS_OVERLAP');
	hr_utility.raise_error;
else
    hr_utility.trace('check_abs_overlap No Overlap');
end if;
hr_utility.trace('check_abs_overlap  Completed.');
exception
when others then
hr_utility.trace('check_abs_overlap  Exception:'||sqlerrm);
raise;
end check_abs_overlap;
--
--

PROCEDURE sickness_date_update
  (p_absence_attendance_id        IN    NUMBER
  ) IS
--
l_proc VARCHAR2(30) ;
--
CURSOR get_abs_category IS
SELECT paat.absence_category
FROM   per_absence_attendance_types paat,
       per_absence_attendances paa
WHERE  paa.absence_attendance_id = p_absence_attendance_id
AND    paa.absence_attendance_type_id = paat.absence_attendance_type_id;
--
l_abs_category per_absence_attendance_types.absence_category%TYPE;
--
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   --
   l_proc := 'PER_GB_ABSENCE_RULES';

   hr_utility.set_location('Entering:'|| l_proc, 10);
   hr_utility.trace(l_proc||': Opening get_abs_category'||
                      ', p_absence_attendance_id='||p_absence_attendance_id);
   --
   -- Get absence_category
   --
   OPEN get_abs_category;
   FETCH get_abs_category INTO l_abs_category;
   CLOSE get_abs_category;
   --
   hr_utility.trace(l_proc||': Closed get_abs_category'||
                      ', l_abs_category='||l_abs_category);
   --
--7157943 when this procedure is called from after delete hook l_abs_category will be NULL
   --IF l_abs_category = 'S' THEN
    IF nvl(l_abs_category,'S') = 'S' THEN
      -- call recalculate_SSP_and_SMP to create/update stoppages and/or element entries.

      ssp_smp_support_pkg.recalculate_SSP_and_SMP(p_deleting=>FALSE);

   END IF;
   --
 END IF;
 --
 hr_utility.set_location('Leaving:'|| l_proc, 200);
 --
END sickness_date_update;
--

-------------------------------------------------------------------------------
-- VALIDATE_ABS_CREATE
-------------------------------------------------------------------------------
PROCEDURE validate_abs_create(p_business_group_id            IN NUMBER
                             ,p_person_id                    IN NUMBER
			                 ,p_date_start                   IN DATE
			                 ,p_date_end                     IN DATE -- Bug 6708992
                             ,p_time_start IN VARCHAR2     -- Bug 6708992
                             ,p_time_end IN VARCHAR2       -- Bug 6708992
			                 ,p_absence_attendance_type_id   IN NUMBER
                            ) IS

    CURSOR get_abs_category IS
    SELECT paat.absence_category
    FROM   per_absence_attendance_types paat
    WHERE  paat.absence_attendance_type_id = p_absence_attendance_type_id
    AND    paat.business_group_id = p_business_group_id;

    CURSOR csr_absences
    IS
    SELECT 1
    FROM   per_absence_attendances PAA
    WHERE  PAA.person_id           = p_person_id
    and    PAA.business_group_id   = p_business_group_id
    AND    PAA.sickness_start_date is not null
    AND    p_date_start          <  (select max(ABS.sickness_start_date)
                                     from per_absence_attendances ABS
		                     where ABS.business_group_id   = p_business_group_id
		                     and   ABS.person_id           = p_person_id);

    l_absence       NUMBER;
    l_abs_category per_absence_attendance_types.absence_category%TYPE;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  hr_utility.trace(' Entering PER_GB_ABSENCE_RULES.VALIDATE_ABS_CREATE ');
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   --
   -- Get absence_category
   --
   OPEN get_abs_category;
   FETCH get_abs_category INTO l_abs_category;
   CLOSE get_abs_category;
   --
   --
   IF l_abs_category = 'S' THEN

        OPEN csr_absences;
        FETCH csr_absences INTO l_absence;
        if  csr_absences%found then
	        close csr_absences;
		hr_utility.set_message(804,'SSP_35037_PIW_BROKEN');
		hr_utility.raise_error;
        else
	        close csr_absences;
        end if;
    END IF;

  -- Bug 6708992
  -- Raise error if overlapping absences of same type are present
  -- Bug 6888892 begin
  -- To check only in case below mentioned absence categories also
  -- changed the check to be based on Absence Category
  if l_abs_category in ('S','M','GB_ADO','GB_PAT_BIRTH','GB_PAT_ADO') then
  check_abs_overlap( p_person_id, p_date_start, p_date_end
                    ,p_time_start, p_time_end, null
                    --,p_absence_attendance_type_id) ;
                    ,l_abs_category);
  end if;
 -- Bug 6888892 begin

  END IF;
  hr_utility.trace(' Leaving PER_GB_ABSENCE_RULES.VALIDATE_ABS_CREATE ');
END validate_abs_create;

-------------------------------------------------------------------------------
-- VALIDATE_ABS_UPDATE
-------------------------------------------------------------------------------
PROCEDURE validate_abs_update(p_date_start            IN DATE,
                              p_date_end              IN DATE,
                              p_time_start IN VARCHAR2,  -- Bug 6708992
                              p_time_end IN VARCHAR2,    -- Bug 6708992
                              p_absence_attendance_id IN NUMBER) IS

    cursor csr_abs_details is
    select absence_attendance_type_id,
           business_group_id,
           person_id,
           sickness_start_date,
           sickness_end_date
--7287548 begin
	,date_start,time_start,date_end,time_end
--7287548 End
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_attendance_id;

    CURSOR get_abs_category(p_abs_type_id number,
                            p_bus_group   number) IS
    SELECT paat.absence_category
    FROM   per_absence_attendance_types paat
    WHERE  paat.absence_attendance_type_id = p_abs_type_id
    AND    paat.business_group_id = p_bus_group;

    CURSOR csr_absences(p_person_id number,
                        p_business_group_id number,
                        p_start     date)IS
    SELECT 1
    FROM   per_absence_attendances PAA
    WHERE  PAA.person_id           = p_person_id
    and    PAA.business_group_id   = p_business_group_id
    AND    PAA.sickness_start_date is not null
    AND    PAA.sickness_start_date > p_start
    AND    PAA.absence_attendance_id <> p_absence_attendance_id;

    l_absence            number;
    l_business_group_id  number;
    l_person_id          number;
    l_abs_type_id        number;
    l_param_start        date;
    l_current_start      date;
    l_current_end        date;
    l_abs_category per_absence_attendance_types.absence_category%TYPE;
--7287548 begin
l_date_start   date;
l_time_start   varchar2(5);
l_date_end	   date;
l_time_end     varchar2(5);
v_date_start   date;
v_time_start   varchar2(5);
v_date_end	   date;
v_time_end     varchar2(5);
--7287548 End

BEGIN
  --
  hr_utility.trace(' Entering PER_GB_ABSENCE_RULES.VALIDATE_ABS_UPDATE ');
  hr_utility.trace(' p_date_start '||p_date_start  );
  hr_utility.trace(' p_date_end '|| p_date_end );
  hr_utility.trace(' p_time_start '||p_time_start);
  hr_utility.trace(' p_time_end '|| p_time_end);
  hr_utility.trace(' p_absence_attendance_id '||p_absence_attendance_id);
 /* Commented the debugging message with to_date function.
  hr_utility.trace('  From date '|| to_date(to_char(p_date_start,'YYYY-MM-DD')|| ' ' ||nvl(p_time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS'));
  hr_utility.trace(' to date '   || to_date(to_char(nvl(p_date_end,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||nvl(p_time_end,'23:59'),'YYYY-MM-DD HH24:MI:SS'));
*/
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
   -- Get absence details
   hr_utility.trace(' before opening cursor csr_abs_details');
   open csr_abs_details;
   fetch csr_abs_details into l_abs_type_id,
                              l_business_group_id,
                              l_person_id,
                              l_current_start,
                              l_current_end
				--7287548 begin
					,l_date_start
					,l_time_start
					,l_date_end
					,l_time_end;
				--7287548 End
   close csr_abs_details;
   --
   hr_utility.trace(' after closing cursor csr_abs_details');

   -- Check if default date is passed in for start/end date
   -- logic
   -- if not updating start or end date then skip
   -- if not updating start or end date, but date is pass in then skip
   -- if updating start/end and exists a future absence then error
   if trunc(p_date_start) = trunc(hr_api.g_date) and
      trunc(p_date_end) = trunc(hr_api.g_date) then
      -- not updating sickness start/end date so skip
      hr_utility.trace('Satisified IF');
      null;
   else
      hr_utility.trace('Satisfied ELSE');
      if trunc(l_current_start) = trunc(p_date_start) and
         trunc(l_current_end) = trunc(p_date_end) then
         -- not updating sickness start/end date so skip
         hr_utility.trace(' not updating sickness start/end date so skip ');
         null;
      else
         -- going to update start or end date, check for future absence
         -- Get absence_category
         --
         hr_utility.trace(' going to update start or end date, check for future absence ');

         OPEN get_abs_category(l_abs_type_id, l_business_group_id);
         FETCH get_abs_category INTO l_abs_category;
         CLOSE get_abs_category;
         --
         --
         hr_utility.trace(' after fetching abs category '||l_abs_category);

         IF l_abs_category = 'S' THEN
            hr_utility.trace(' for sickness S');
            if trunc(p_date_start) = trunc(hr_api.g_date) then
               l_param_start := trunc(l_current_start);
            else
               l_param_start := trunc(p_date_start);
            end if;
            hr_utility.trace(' before csr_absences open');
            OPEN csr_absences(l_person_id, l_business_group_id,l_param_start);
            FETCH csr_absences INTO l_absence;
            if  csr_absences%found then
                close csr_absences;
                hr_utility.set_message(804,'SSP_35037_PIW_BROKEN');
                hr_utility.raise_error;
            else
                hr_utility.trace('csr_absences not found');
                close csr_absences;
            end if;
         END IF;
      end if;
    end if;

--7287548 begin
 If (p_date_start = hr_api.g_date) then
hr_utility.trace(' p_date_start value is defaulted '||p_date_start||' Repl by'||l_date_start);
    v_date_start := l_date_start;
 else
    v_date_start := p_date_start;
 End If;

 If (p_date_end = hr_api.g_date) then
hr_utility.trace(' p_date_end value is defaulted '||p_date_end||' Repl by'||l_date_end);
    v_date_end := l_date_end;
 else
    v_date_end := p_date_end;
 End If;

 If (p_time_start = hr_api.g_varchar2) then
hr_utility.trace(' p_time_start value is defaulted '||p_time_start||' Repl by'||l_time_start);
    v_time_start := l_time_start;
 else
    v_time_start := p_time_start;
 End If;

 If (p_time_end = hr_api.g_varchar2) then
hr_utility.trace(' p_time_end value is defaulted '||p_time_end||' Repl by'||l_time_end);
    v_time_end := l_time_end;
 else
    v_time_end := p_time_end;
 End If;

--7287548 end


    -- Bug 6708992
    -- Raise error if overlapping absences of same type are present
  -- Bug 6888892 begin
  -- To check only in case below mentioned absence categories also
  -- changed the check to be based on Absence Category
    if l_abs_category in ('S','M','GB_ADO','GB_PAT_BIRTH','GB_PAT_ADO') then
    hr_utility.trace(' calling check_abs_overlap');
    check_abs_overlap( l_person_id, v_date_start, v_date_end
                    ,v_time_start, v_time_end, p_absence_attendance_id
                   -- ,l_abs_type_id) ;
                    ,l_abs_category);
    hr_utility.trace(' After check_abs_overlap ');
    end if;
  -- Bug 6888892 begin

  END IF;
hr_utility.trace('Leaving  validate_abs_update ');
END validate_abs_update;

-------------------------------------------------------------------------------
-- VALIDATE_ABS_DELETE
-------------------------------------------------------------------------------
PROCEDURE validate_abs_delete(p_absence_attendance_id   IN NUMBER
                            ) IS



CURSOR get_abs_category IS
SELECT paat.absence_category
FROM   per_absence_attendance_types paat,
       per_absence_attendances paa
WHERE  paa.absence_attendance_id = p_absence_attendance_id
AND    paa.absence_attendance_type_id = paat.absence_attendance_type_id;


    CURSOR csr_absences IS
    SELECT 1
    FROM   per_absence_attendances PAA
    WHERE  PAA.absence_attendance_id  = p_absence_attendance_id
    AND    PAA.sickness_start_date is not null
    AND    PAA.sickness_start_date <   (select max(ABS.sickness_start_date)
                                        from per_absence_attendances ABS
				        where ABS.person_id =PAA.person_id);

    l_absence       NUMBER;
    l_abs_category per_absence_attendance_types.absence_category%TYPE;

    --
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  hr_utility.trace(' Entering PER_GB_ABSENCE_RULES.VALIDATE_ABS_DELETE ');
  IF hr_utility.chk_product_install('Oracle Human Resources', 'GB') THEN
     --
     -- Get absence_category
     --
     hr_utility.trace('PER_GB_ABSENCE_RULES.VALIDATE_ABS_DELETE : Fetching absence category');
     OPEN get_abs_category;
     FETCH get_abs_category INTO l_abs_category;
     CLOSE get_abs_category;
     hr_utility.trace('PER_GB_ABSENCE_RULES.VALIDATE_ABS_DELETE : absence category :'||l_abs_category);

   IF l_abs_category = 'S' THEN
        OPEN csr_absences;
        FETCH csr_absences INTO l_absence;
        if  csr_absences%found then
	        close csr_absences;
		hr_utility.set_message(804,'SSP_35037_PIW_BROKEN');
		hr_utility.raise_error;
        else
	    close csr_absences;
       end if;
  END IF;
 END IF;
 hr_utility.trace(' Leaving PER_GB_ABSENCE_RULES.VALIDATE_ABS_DELETE ');
END validate_abs_delete;
--
END per_gb_absence_rules;

/
