--------------------------------------------------------
--  DDL for Package Body PER_FR_WORK_CERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_WORK_CERT" AS
/* $Header: pefrwkct.pkb 120.0 2005/05/31 09:08:26 appldev noship $ */
--
-- Cursor To Fetch Employee Job Details
--
CURSOR c_get_jobs(p_person_id NUMBER
                 ,p_period_of_service_id NUMBER) IS
--
SELECT job.job_id,
       job.job_definition_id,
       to_char(asg.effective_start_date, 'DD-MON-YYYY'),
       to_char(asg.effective_end_date, 'DD-MON-YYYY')
FROM   per_jobs job,
       per_all_assignments_f asg
WHERE  asg.person_id = p_person_id
AND    asg.job_id = job.job_id
AND    asg.period_of_service_id = p_period_of_service_id
AND    asg.primary_flag = 'Y'
ORDER BY asg.effective_start_date;
--
-- Function To Return Employees Job Details
--
FUNCTION get_job_details(p_person_id NUMBER
                        ,p_period_of_service_id NUMBER) RETURN VARCHAR2 IS
--
l_job_name1 per_jobs_tl.name%TYPE;
l_job_name2 per_jobs_tl.name%TYPE;
l_job_name3 per_jobs_tl.name%TYPE;
l_job_name4 per_jobs_tl.name%TYPE;
l_job_name5 per_jobs_tl.name%TYPE;
--
l_job_name6 per_jobs_tl.name%TYPE;
l_job_name7 per_jobs_tl.name%TYPE;
l_job_name8 per_jobs_tl.name%TYPE;
l_job_name9 per_jobs_tl.name%TYPE;
l_job_name10 per_jobs_tl.name%TYPE;
--
l_job_start_date1 VARCHAR2(11);
l_job_start_date2 VARCHAR2(11);
l_job_start_date3 VARCHAR2(11);
l_job_start_date4 VARCHAR2(11);
l_job_start_date5 VARCHAR2(11);
--
l_job_start_date6 VARCHAR2(11);
l_job_start_date7 VARCHAR2(11);
l_job_start_date8 VARCHAR2(11);
l_job_start_date9 VARCHAR2(11);
l_job_start_date10 VARCHAR2(11);
--
l_job_end_date1 VARCHAR2(11);
l_job_end_date2 VARCHAR2(11);
l_job_end_date3 VARCHAR2(11);
l_job_end_date4 VARCHAR2(11);
l_job_end_date5 VARCHAR2(11);
--
l_job_end_date6 VARCHAR2(11);
l_job_end_date7 VARCHAR2(11);
l_job_end_date8 VARCHAR2(11);
l_job_end_date9 VARCHAR2(11);
l_job_end_date10 VARCHAR2(11);
-- 3815632
l_job_id1 per_jobs.job_id%TYPE;
l_job_id2 per_jobs.job_id%TYPE;
l_job_id3 per_jobs.job_id%TYPE;
l_job_id4 per_jobs.job_id%TYPE;
l_job_id5 per_jobs.job_id%TYPE;
--
l_job_id6 per_jobs.job_id%TYPE;
l_job_id7 per_jobs.job_id%TYPE;
l_job_id8 per_jobs.job_id%TYPE;
l_job_id9 per_jobs.job_id%TYPE;
l_job_id10 per_jobs.job_id%TYPE;
--
l_job_definition_id1 per_jobs.job_definition_id%TYPE;
l_job_definition_id2 per_jobs.job_definition_id%TYPE;
l_job_definition_id3 per_jobs.job_definition_id%TYPE;
l_job_definition_id4 per_jobs.job_definition_id%TYPE;
l_job_definition_id5 per_jobs.job_definition_id%TYPE;
--
l_job_definition_id6 per_jobs.job_definition_id%TYPE;
l_job_definition_id7 per_jobs.job_definition_id%TYPE;
l_job_definition_id8 per_jobs.job_definition_id%TYPE;
l_job_definition_id9 per_jobs.job_definition_id%TYPE;
l_job_definition_id10 per_jobs.job_definition_id%TYPE;
-- 3815632

l_concat_job_details VARCHAR2(3000);
l_prev_job_end_date DATE;
--
BEGIN
--
-- Find all Employee Job Information
--
OPEN c_get_jobs(p_person_id
               ,p_period_of_service_id);
--
-- Job 1 Details
--
FETCH c_get_jobs into l_job_id1, l_job_definition_id1, l_job_start_date1, l_job_end_date1;
if l_job_definition_id1 is not null then
   l_job_name1 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id1,
                                          p_job_definition_id => l_job_definition_id1,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name1 := null;
end if;

--
-- Job 2 Details
--
FETCH c_get_jobs into l_job_id2, l_job_definition_id2, l_job_start_date2, l_job_end_date2;
if l_job_definition_id2 is not null then
   l_job_name2 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id2,
                                          p_job_definition_id => l_job_definition_id2,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name2 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job2 is found and bypass loop.
--
IF l_job_name2 = l_job_name1 THEN
  LOOP
     EXIT when l_job_name2 <> l_job_name1 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date2;
     FETCH c_get_jobs into l_job_id2, l_job_definition_id2, l_job_start_date2, l_job_end_date2;
     if l_job_definition_id2 is not null then
        l_job_name2 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id2,
                                               p_job_definition_id => l_job_definition_id2,
	      				       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name2 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date1 := l_job_end_date2;
        l_job_name2 := null;
        l_job_start_date2 := null;
        l_job_end_date2 := null;
     ELSE
        l_job_end_date1 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
-- Job 3 Details
--
FETCH c_get_jobs into l_job_id3, l_job_definition_id3, l_job_start_date3, l_job_end_date3;
if l_job_definition_id3 is not null then
   l_job_name3 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id3,
                                          p_job_definition_id => l_job_definition_id3,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name3 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job3 is found and bypass loop.
--
IF l_job_name3 = l_job_name2 THEN
  LOOP
     EXIT when l_job_name3 <> l_job_name2 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date3;
     FETCH c_get_jobs into l_job_id3, l_job_definition_id3, l_job_start_date3, l_job_end_date3;
     if l_job_definition_id3 is not null then
        l_job_name3 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id3,
                                               p_job_definition_id => l_job_definition_id3,
		   			       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name3 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date2 := l_job_end_date3;
        l_job_name3 := null;
        l_job_start_date3 := null;
        l_job_end_date3 := null;
     ELSE
        l_job_end_date2 := l_prev_job_end_date;
     END IF;
  END Loop;
END IF;
--
-- Job 4 Details
--
FETCH c_get_jobs into l_job_id4, l_job_definition_id4, l_job_start_date4, l_job_end_date4;
if l_job_definition_id4 is not null then
   l_job_name4 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id4,
                                          p_job_definition_id => l_job_definition_id4,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name4 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job4 is found and bypass loop.
--
IF l_job_name4 = l_job_name3 THEN
  LOOP
     EXIT when l_job_name4 <> l_job_name3 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date4;
     FETCH c_get_jobs into l_job_id4, l_job_definition_id4, l_job_start_date4, l_job_end_date4;
     if l_job_definition_id4 is not null then
        l_job_name4 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id4,
                                               p_job_definition_id => l_job_definition_id4,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name4 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date3 := l_job_end_date4;
        l_job_name4 := null;
        l_job_start_date4 := null;
        l_job_end_date4 := null;
     ELSE
        l_job_end_date3 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
-- Job 5 Details
--
FETCH c_get_jobs into l_job_id5, l_job_definition_id5, l_job_start_date5, l_job_end_date5;
if l_job_definition_id5 is not null then
   l_job_name5 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id5,
                                          p_job_definition_id => l_job_definition_id5,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name5 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job5 is found and bypass loop.
--
IF l_job_name5 = l_job_name4 THEN
  LOOP
     EXIT when l_job_name5 <> l_job_name4 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date5;
     FETCH c_get_jobs into l_job_id5, l_job_definition_id5, l_job_start_date5, l_job_end_date5;
     if l_job_definition_id5 is not null then
        l_job_name5 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id5,
                                               p_job_definition_id => l_job_definition_id5,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name5 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date4 := l_job_end_date5;
        l_job_name5 := null;
        l_job_start_date5 := null;
        l_job_end_date5 := null;
     ELSE
        l_job_end_date4 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
--
-- Job 6 Details
--
FETCH c_get_jobs into l_job_id6, l_job_definition_id6, l_job_start_date6, l_job_end_date6;
if l_job_definition_id6 is not null then
   l_job_name6 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id6,
                                          p_job_definition_id => l_job_definition_id6,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name6 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job6 is found and bypass loop.
--
IF l_job_name6 = l_job_name5 THEN
  LOOP
     EXIT when l_job_name6 <> l_job_name5 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date6;
     FETCH c_get_jobs into l_job_id6, l_job_definition_id6, l_job_start_date6, l_job_end_date6;
     if l_job_definition_id6 is not null then
        l_job_name6 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id6,
                                               p_job_definition_id => l_job_definition_id6,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name6 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date5 := l_job_end_date6;
        l_job_name6 := null;
        l_job_start_date6 := null;
        l_job_end_date6 := null;
     ELSE
        l_job_end_date5 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
--
--
-- Job 7 Details
--
FETCH c_get_jobs into l_job_id7, l_job_definition_id7, l_job_start_date7, l_job_end_date7;
if l_job_definition_id7 is not null then
   l_job_name7 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id7,
                                          p_job_definition_id => l_job_definition_id7,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name7 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job7 is found and bypass loop.
--
IF l_job_name7 = l_job_name6 THEN
  LOOP
     EXIT when l_job_name7 <> l_job_name6 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date7;
     FETCH c_get_jobs into l_job_id7, l_job_definition_id7, l_job_start_date7, l_job_end_date7;
     if l_job_definition_id7 is not null then
        l_job_name7 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id7,
                                               p_job_definition_id => l_job_definition_id7,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name7 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date6 := l_job_end_date7;
        l_job_name7 := null;
        l_job_start_date7 := null;
        l_job_end_date7 := null;
     ELSE
        l_job_end_date6 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
--
--
--
-- Job 8 Details
--
FETCH c_get_jobs into l_job_id8, l_job_definition_id8, l_job_start_date8, l_job_end_date8;
if l_job_definition_id8 is not null then
   l_job_name8 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id8,
                                          p_job_definition_id => l_job_definition_id8,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name8 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job8 is found and bypass loop.
--
IF l_job_name8 = l_job_name7 THEN
  LOOP
     EXIT when l_job_name8 <> l_job_name7 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date8;
     FETCH c_get_jobs into l_job_id8, l_job_definition_id8, l_job_start_date8, l_job_end_date8;
     if l_job_definition_id8 is not null then
        l_job_name8 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id8,
                                               p_job_definition_id => l_job_definition_id8,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name8 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date7 := l_job_end_date8;
        l_job_name8 := null;
        l_job_start_date8 := null;
        l_job_end_date8 := null;
     ELSE
        l_job_end_date7 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
--
--
--
--
-- Job 9 Details
--
FETCH c_get_jobs into l_job_id9, l_job_definition_id9, l_job_start_date9, l_job_end_date9;
if l_job_definition_id9 is not null then
   l_job_name9 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id9,
                                          p_job_definition_id => l_job_definition_id9,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name9 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job9 is found and bypass loop.
--
IF l_job_name9 = l_job_name8 THEN
  LOOP
     EXIT when l_job_name9 <> l_job_name8 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date9;
     FETCH c_get_jobs into l_job_id9, l_job_definition_id9, l_job_start_date9, l_job_end_date9;
     if l_job_definition_id9 is not null then
        l_job_name9 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id9,
                                               p_job_definition_id => l_job_definition_id9,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name9 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date8 := l_job_end_date9;
        l_job_name9 := null;
        l_job_start_date9 := null;
        l_job_end_date9 := null;
     ELSE
        l_job_end_date8 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
--
--
--
--
--
-- Job 10 Details
--
FETCH c_get_jobs into l_job_id10, l_job_definition_id10, l_job_start_date10, l_job_end_date10;
if l_job_definition_id10 is not null then
   l_job_name10 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id10,
                                          p_job_definition_id => l_job_definition_id10,
					  p_report_name => 'WORK_CERTIFICATE');
else
   l_job_name10 := null;
end if;
--
-- If the job names are equal, a change in the assignment has occurred but
-- not a change of job.  Therefore enter loop to find the next job. If
-- the job names do not equal, job10 is found and bypass loop.
--
IF l_job_name10 = l_job_name9 THEN
  LOOP
     EXIT when l_job_name10 <> l_job_name9 or c_get_jobs%NOTFOUND;
     l_prev_job_end_date := l_job_end_date10;
     FETCH c_get_jobs into l_job_id10, l_job_definition_id10, l_job_start_date10, l_job_end_date10;
     if l_job_definition_id10 is not null then
        l_job_name10 := per_fr_report_utilities.get_job_names(p_job_id => l_job_id10,
                                               p_job_definition_id => l_job_definition_id10,
					       p_report_name => 'WORK_CERTIFICATE');
     else
        l_job_name10 := null;
     end if;
     IF c_get_jobs%NOTFOUND THEN
        l_job_end_date9 := l_job_end_date10;
        l_job_name10 := null;
        l_job_start_date10 := null;
        l_job_end_date10 := null;
     ELSE
        l_job_end_date9 := l_prev_job_end_date;
     END IF;
  END LOOP;
END IF;
--
CLOSE c_get_jobs;
--
-- Concatenate The Job Details
--
l_concat_job_details := 'JN1,' || l_job_name1 || ',JSD1,' || l_job_start_date1 || ',JED1,'
                        || l_job_end_date1 || ',JN2,' || l_job_name2 || ',JSD2,' || l_job_start_date2
                        || ',JED2,' || l_job_end_date2 || ',JN3,' || l_job_name3 || ',JSD3,'
                        || l_job_start_date3 || ',JED3,' || l_job_end_date3 || ',JN4,' || l_job_name4
                        || ',JSD4,' || l_job_start_date4 || ',JED4,' || l_job_end_date4 || ',JN5,'
                        || l_job_name5 || ',JSD5,' || l_job_start_date5 || ',JED5,' || l_job_end_date5
                        || ',JN6,' || l_job_name6 || ',JSD6,' || l_job_start_date6 || ',JED6,'
                        || l_job_end_date6 || ',JN7,' || l_job_name7 || ',JSD7,' || l_job_start_date7
                        || ',JED7,' || l_job_end_date7 || ',JN8,' || l_job_name8 || ',JSD8,'
                        || l_job_start_date8 || ',JED8,' || l_job_end_date8 || ',JN9,' || l_job_name9
                        || ',JSD9,' || l_job_start_date9 || ',JED9,' || l_job_end_date9 || ',JN10,'
                        || l_job_name10 || ',JSD10,' || l_job_start_date10 || ',JED10,' || l_job_end_date10
                        || ',END';
--
RETURN l_concat_job_details;
--
END get_job_details;

END per_fr_work_cert;

/
