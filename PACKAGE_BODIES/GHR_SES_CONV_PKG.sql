--------------------------------------------------------
--  DDL for Package Body GHR_SES_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SES_CONV_PKG" 
/* $Header: ghsescon.pkb 115.5 2004/02/05 21:37:03 asubrahm noship $ */
AS
g_proc_name  VARCHAR2(200) := 'GHR_SES_PAY_CONVERSION';

--
-- ---------------------------------------------------------------------------
--  |--------------------< ghr_ses_pay_cal_conv >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Used with Concurrent Program - Process SES Pay Conversion
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE ghr_ses_pay_cal_conv
(
    errbuf              OUT NOCOPY VARCHAR2 ,
    retcode             OUT NOCOPY NUMBER   ,
    p_business_group_id            NUMBER   DEFAULT NULL
)
IS

l_mesgbuff               VARCHAR2(4000);
l_prog_name              ghr_process_log.program_name%type;
l_effective_date         ghr_pa_requests.effective_date%type := to_date('2004/01/11','YYYY/MM/DD');

l_user_tab_name          pay_user_tables.user_table_name%type
        := 'ESSL Oracle Federal Standard Pay Table (EP, ES, IE, IP, FE, SL and ST) No. ESSL';

l_position_id                per_assignments_f.position_id%type;
l_essl_tab_id                pay_user_tables.user_table_id%type;
l_user_tab_id                pay_user_tables.user_table_id%type;

CURSOR cur_user_pay_tab (l_user_table_name IN pay_user_tables.user_table_name%type)
is
SELECT user_table_id
FROM   pay_user_tables
WHERE  user_table_name=l_user_table_name;
--
--
CURSOR cur_user_pay_tab_name IS
SELECT substr(user_table_name,1,4) user_table_name
FROM   pay_user_tables
WHERE  user_table_id = l_user_tab_id;
--
--
CURSOR cur_pos_ei(l_essl_tab_id NUMBER)
IS
SELECT pei.position_id,
       pei.position_extra_info_id,
       pei.poei_information3            grade_id,
       to_number(pei.poei_information5) user_tab_id
FROM   per_position_extra_info pei
WHERE  pei.information_type = 'GHR_US_POS_VALID_GRADE'
AND    to_number(pei.poei_information5) <> l_essl_tab_id
AND    pei.position_id in
       (SELECT position_id
        from   hr_positions_f pos
        WHERE  pos.position_id = pei.position_id
        AND    business_group_id = p_business_group_id)
FOR UPDATE OF poei_information5;
--
--
CURSOR cur_hist_rows(l_essl_tab_id NUMBER)
IS

SELECT pah.pa_history_id,
       pah.information4 , -- position_id
       pah.information9 , -- grade_id
       to_number(pah.information11) user_tab_id,
       pah.effective_date
FROM   ghr_pa_history pah
WHERE  pah.table_name    = 'PER_POSITION_EXTRA_INFO'
AND    pah.information5  = 'GHR_US_POS_VALID_GRADE'
AND    to_number(pah.information11) <> l_essl_tab_id
AND    to_number(pah.information4) in
       (SELECT position_id
        from   hr_positions_f pos
        WHERE  pos.position_id = to_number(pah.information4)
        AND    business_group_id = p_business_group_id
        AND    pah.effective_date
               between pos.effective_start_date and pos.effective_end_date
        AND    HR_GENERAL.DECODE_AVAILABILITY_STATUS(pos.availability_status_id)
                      NOT IN ('Eliminated','Deleted'));
--
--
CURSOR cur_grd(l_grade_id NUMBER) IS
  SELECT gdf.segment1 pay_plan
	,gdf.segment2 grade_or_level
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id		= l_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;

--
CURSOR cur_pos_valid IS
SELECT 1
FROM  hr_positions_f pos1
WHERE position_id       = l_position_id
AND   l_effective_date between effective_start_date and effective_end_date
AND   business_group_id = p_business_group_id
AND   HR_GENERAL.DECODE_AVAILABILITY_STATUS(pos1.availability_status_id)
                      NOT IN ('Eliminated','Deleted');

---
---
CURSOR cur_his_cut_off_date IS
SELECT 1
FROM  ghr_pa_history pah1
WHERE table_name     = 'PER_POSITION_EXTRA_INFO'
AND   information5   = 'GHR_US_POS_VALID_GRADE'
and   effective_date = l_effective_date
AND   to_number(information4)   = l_position_id
AND   to_number(information11)  = l_essl_tab_id;

l_proc                       varchar2(72) := 'ghr_ses_pay_cal_conv';

l_his_match                  BOOLEAN := FALSE;
l_pos_valid                  BOOLEAN := FALSE;
l_pos_ei_data                per_position_extra_info%rowtype;
l_pay_plan                   per_grade_definitions.segment1%type;
l_grade_or_level             per_grade_definitions.segment2%type;
l_posei_id                   per_position_extra_info.position_extra_info_id%type;
l_grd_id                     per_position_extra_info.poei_information5%type;
l_hist_id		     ghr_pa_history.pa_history_id%type;
l_his_eff_date               ghr_pa_requests.effective_date%type;
l_counter                    NUMBER := 0;
l_counter1                   NUMBER := 0;
--
--
-- Process Log Extention --
--
l_check_date                 date;
l_log_text                   varchar2(2000);
l_from_user_tab_name         pay_user_tables.user_table_name%type;
l_name                       per_people_f.full_name%type;
l_ssn                        per_people_f.national_identifier%type;
--
--
CURSOR cur_emp_det IS
SELECT per.full_name            full_name
      ,per.national_identifier  national_identifier
from   per_people_f      per
      ,per_assignments_f paf
where  paf.person_id = per.person_id
and    l_check_date
       between paf.effective_start_date and paf.effective_end_date
and    l_check_date
       between per.effective_start_date and per.effective_end_date
and    paf.position_id = l_position_id;

BEGIN

     hr_utility.set_location( 'Entering : ' || l_proc, 10);
     l_prog_name := Fnd_profile.value('CONC_REQUEST_ID');
     hr_utility.set_location('l_prog_name conc_request_id :' || l_prog_name ,11);

      if l_prog_name = '-1' then
         l_prog_name := NULL;
      else
         g_proc_name := g_proc_name || '_' || l_prog_name;
      end if;

     FOR c_user_paytab in cur_user_pay_tab(l_user_tab_name)
     LOOP
       	 l_essl_tab_id := c_user_paytab.user_table_id;
     END LOOP;

---
--- 1. Update position extra information for ES equivalent pay plans with the pay table id
---    of ESSL a open pay range pay table.
---    i) Here available status is not checked because there is no date concept.
---    ii)Also date is not checked because the per position extra is not a date track table.
---

     FOR c_pos IN cur_pos_ei(l_essl_tab_id)
     LOOP

	l_position_id	:= c_pos.position_id;
        l_posei_id      := c_pos.position_extra_info_id;
	l_grd_id	:= c_pos.grade_id;
        l_user_tab_id   := c_pos.user_tab_id;
---
--- Fetch the pay plan to compare with ES equivalent
---
	FOR c_grd in cur_grd(l_grd_id)

	LOOP
	   l_pay_plan       := c_grd.pay_plan;
	   l_grade_or_level := c_grd.grade_or_level;
	END LOOP;
---
--- Compare the pay plans with ES equivalent
---

      IF l_pay_plan in  ('ES','EP','IE','FE') THEN

        UPDATE PER_POSITION_EXTRA_INFO
	SET    poei_information5      = to_char(l_essl_tab_id)
	WHERE  current of cur_pos_ei;

        FOR tab_name IN cur_user_pay_tab_name
        LOOP
            l_from_user_tab_name := tab_name.user_table_name;
        END LOOP;
---
--- Log Message
---
        l_log_text := '  Position Title : ' || ghr_api.get_position_title_pos(l_position_id,p_business_group_id);
        l_log_text := substr(l_log_text || ', Position Number: ' ||
                        ghr_api.get_position_desc_no_pos(l_position_id,p_business_group_id),1,2000);
        l_log_text := substr(l_log_text || ', Sequence Number: ' ||
                        ghr_api.get_position_sequence_no_pos(l_position_id,p_business_group_id),1,2000);
        l_log_text := substr(l_log_text || ', From Pay Table : ' || l_from_user_tab_name,1,2000);
        l_log_text := substr(l_log_text || ', To Pay Table   : ' || 'ESSL',1,2000);

         IF SQL%NOTFOUND then
---
--- Update failed then capture the error and Enter the log.
---
               l_log_text := substr(l_log_text || ', Message        : ' || 'ERROR NOT UPDATED ,',1,2000);
  	       ghr_wgi_pkg.create_ghr_errorlog(
		  p_program_name => g_proc_name,
	          p_message_name => 'ERR-PER_POSITION_EXTRA_INFO',
	          p_log_text     =>  substr(l_log_text || 'DB ERROR is : ' || SQLERRM,1,2000),
	          p_log_date     => sysdate);
	 ELSE
	       l_counter       := l_counter + 1;

---
--- Update Successful - Enter log.
---
               l_log_text := substr(l_log_text || ', Message        : ' || 'Updated Successful ',1,2000);
  	       ghr_wgi_pkg.create_ghr_errorlog(
		  p_program_name => g_proc_name,
	          p_message_name => 'PER_POSITION_EXTRA_INFO',
	          p_log_text     => l_log_text,
	          p_log_date     => sysdate);
	 END IF;


       END IF;  --- for the condtion of  ('ES','EP','IE','FE').

     END LOOP;

 	 IF l_counter = 0 THEN
---
--- No Records in PER_POSITION_EXTRA_INFO - so Enter log.
---
		ghr_wgi_pkg.create_ghr_errorlog(
		  p_program_name => g_proc_name,
		  p_message_name => 'NO-PER_POSITION_EXTRA_INFO',
	          p_log_text     => 'Error : NO Valid Extra Position Info records found for Update' ,
		  p_log_date     => sysdate);
         ELSE
---
--- All Records in PER_POSITION_EXTRA_INFO updated - so Enter log.
---
		ghr_wgi_pkg.create_ghr_errorlog(
		  p_program_name => g_proc_name,
		  p_message_name => 'TOT-PER_POSITION_EXTRA_INFO',
	          p_log_text     => 'Total Records updated with SES equivalent plans are ' || to_char(l_counter),
		  p_log_date     => sysdate);
 	 END IF;


--
-- 2. Start fetching Positions records on history table
--    i) Check for the Available status id for the effective date of the history table.
--   ii) Check for the row on the date of 11-JAN-2004 and if not exists create one provided the
--       date of creation of the position is less than 11-JAN-2004.
--   iii)Update the rows for the effective_date > 11-JAN-2004.
--
        l_counter := 0;

	FOR hist_rec IN cur_hist_rows(l_essl_tab_id)
	LOOP


            l_hist_id	    := hist_rec.pa_history_id;
            l_position_id   := hist_rec.information4;
            l_grd_id	    := hist_rec.information9;
            l_his_eff_date  := hist_rec.effective_date;
            l_user_tab_id   := hist_rec.user_tab_id;

            FOR c_grd in cur_grd(l_grd_id)
            LOOP
                l_pay_plan       := c_grd.pay_plan;
                l_grade_or_level := c_grd.grade_or_level;
            END LOOP;

            IF l_pay_plan in  ('ES','EP','IE','FE') THEN


               IF l_effective_date >= l_his_eff_date  THEN

                  l_pos_valid := FALSE;
                  l_his_match := FALSE;

                  FOR cur_pos_valid_rec IN cur_pos_valid
                  LOOP
                      l_pos_valid := TRUE;
                  END LOOP;

                  if l_pos_valid then
                     FOR cur_his_cut_off_date_rec IN cur_his_cut_off_date
                     LOOP
                         l_his_match := TRUE;
                     END LOOP;
                  end if;

                  if l_pos_valid AND not l_his_match then

                     Begin
                        ghr_history_fetch.fetch_positionei
                         (p_position_id           => l_position_id
                         ,p_information_type      => 'GHR_US_POS_VALID_GRADE'
                         ,p_date_effective        => l_effective_date
                         ,p_pos_ei_data           => l_pos_ei_data);

                        if l_pos_ei_data.poei_information3 is not null then
                           FOR c_grd in cur_grd(to_number(l_pos_ei_data.poei_information3))
                           LOOP
                               l_pay_plan       := c_grd.pay_plan;
                               l_grade_or_level := c_grd.grade_or_level;
                           END LOOP;
                        end if;

                        IF l_pay_plan in  ('ES','EP','IE','FE') THEN
---
--- Process Log
---
                           l_check_date := l_effective_date;
                           l_name       := null;
                           l_ssn        := null;
                           FOR cur_emp_det_rec IN cur_emp_det
                           LOOP
                               l_name  := cur_emp_det_rec.full_name;
                               l_ssn   := cur_emp_det_rec.national_identifier;
                           EXIT;
                           END LOOP;

                           FOR tab_name IN cur_user_pay_tab_name
                           LOOP
                               l_from_user_tab_name := tab_name.user_table_name;
                           END LOOP;

                           if l_name is not null then
                              l_log_text := ' Name : ' || l_name || ', SSN : ' || l_ssn;
                           else
                              l_log_text := ' Name : Vacant Position';
                           end if;
                           l_log_text := substr(l_log_text || ', Position Title : ' ||
                                          ghr_api.get_position_title_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                           l_log_text := substr(l_log_text || ', Position Number: ' ||
                                          ghr_api.get_position_desc_no_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                           l_log_text := substr(l_log_text || ', Sequence Number: ' ||
                                          ghr_api.get_position_sequence_no_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                           l_log_text := substr(l_log_text || ', From Pay Table : ' || l_from_user_tab_name,1,2000);
                           l_log_text := substr(l_log_text || ', To Pay Table   : ' || 'ESSL',1,2000);
                           l_log_text := substr(l_log_text || ', Effective Date : ' || to_char(l_check_date,'DD-MON-YYYY'),1,2000);

                        g_do_not_cascade := 'Y';
                        ghr_position_extra_info_api.update_position_extra_info
                        ( p_position_extra_info_id   =>    l_pos_ei_data.position_extra_info_id
                        , p_effective_date           =>    l_effective_date
                        , p_object_version_number    =>    l_pos_ei_data.object_version_number
                        , p_poei_information3        =>    l_pos_ei_data.poei_information3
                        , p_poei_information5        =>    to_char(l_essl_tab_id));
                        g_do_not_cascade := 'N';

                           l_log_text := substr(l_log_text || ', Message : ' || 'Record Inserted',1,2000);

                        ghr_validate_perwsdpo.validate_perwsdpo(l_position_id,l_effective_date);
                        ghr_validate_perwsdpo.update_posn_status(l_position_id,l_effective_date);

                        l_counter1 := l_counter1 + 1;
       		        ghr_wgi_pkg.create_ghr_errorlog(
		          p_program_name => g_proc_name,
	                  p_message_name => 'INS-GHR_PA_HISTORY',
	                  p_log_text     => l_log_text,
	                  p_log_date     => sysdate);

                        END IF;
	             Exception when others then
                           l_log_text := substr(l_log_text || ', Message : ' || 'Record Not Inserted',1,2000);
       		        ghr_wgi_pkg.create_ghr_errorlog(
		          p_program_name => g_proc_name,
	                  p_message_name => 'INSERR-GHR_PA_HISTORY',
	                  p_log_text     => substr(l_log_text || 'DB ERROR is : ' || SQLERRM,1,2000),
	                  p_log_date     => sysdate);
                     End;

                  end if;
               ELSE
---
--- Process Log
---
                   l_check_date := l_his_eff_date;
                   l_name       := null;
                   l_ssn        := null;
                   FOR cur_emp_det_rec IN cur_emp_det
                   LOOP
                       l_name  := cur_emp_det_rec.full_name;
                       l_ssn   := cur_emp_det_rec.national_identifier;
                   EXIT;
                   END LOOP;

                   FOR tab_name IN cur_user_pay_tab_name
                   LOOP
                       l_from_user_tab_name := tab_name.user_table_name;
                   END LOOP;

                   if l_name is not null then
                      l_log_text := ' Name : ' || l_name || ', SSN : ' || l_ssn;
                   else
                      l_log_text := ' Name : Vacant Position';
                   end if;
                   l_log_text := substr(l_log_text || ', Position Title : ' ||
                                    ghr_api.get_position_title_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                   l_log_text := substr(l_log_text || ', Position Number: ' ||
                                    ghr_api.get_position_desc_no_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                   l_log_text := substr(l_log_text || ', Sequence Number: ' ||
                                    ghr_api.get_position_sequence_no_pos(l_position_id,p_business_group_id,l_check_date),1,2000);
                   l_log_text := substr(l_log_text || ', From Pay Table : ' || l_from_user_tab_name,1,2000);
                   l_log_text := substr(l_log_text || ', To Pay Table   : ' || 'ESSL',1,2000);
                   l_log_text := substr(l_log_text || ', Effective Date : ' || to_char(l_check_date,'DD-MON-YYYY'),1,2000);

	  	  UPDATE GHR_PA_HISTORY
		  SET    information11 = to_char(l_essl_tab_id)
		  WHERE  pa_history_id = l_hist_id;

                  IF SQL%NOTFOUND THEN
                       l_log_text := substr(l_log_text || ', Message        : ' || 'ERROR NOT UPDATED ,',1,2000);
       		       ghr_wgi_pkg.create_ghr_errorlog(
		         p_program_name => g_proc_name,
	                 p_message_name => 'UPDERR-GHR_PA_HISTORY',
	                 p_log_text     => substr(l_log_text || 'DB ERROR is : ' || SQLERRM,1,2000),
	                 p_log_date     => sysdate);
                  ELSE
                       l_counter := l_counter + 1;
                       l_log_text := substr(l_log_text || ', Message        : ' || 'Updated Successful ',1,2000);
       		       ghr_wgi_pkg.create_ghr_errorlog(
		         p_program_name => g_proc_name,
	                 p_message_name => 'UPD-GHR_PA_HISTORY',
	                 p_log_text     => l_log_text,
	                 p_log_date     => sysdate);

                  END IF;

    	       END IF;

	    END IF;
	END LOOP; -- Hist records cursor

        IF l_counter1 = 0 AND l_counter = 0 THEN
               ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => g_proc_name,
                    p_message_name => 'GHR_PA_HISTORY',
                    p_log_text     => 'Error : NO Valid History Position Records found for Update',
                    p_log_date     => sysdate);
        ELSE
               ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => g_proc_name,
                    p_message_name => 'TOT-GHR_PA_HISTORY',
                    p_log_text     => 'Total Records inserted with SES equivalent plans are ' ||
                    to_char(l_counter1) || ' and Updates are ' || to_char(l_counter),
                    p_log_date     => sysdate);
        END IF;

END; -- End of Procedure

END; -- End of Package

/
