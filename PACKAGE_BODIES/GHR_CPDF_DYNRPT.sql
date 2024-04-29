--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_DYNRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_DYNRPT" AS
/* $Header: ghrcpdfd.pkb 120.14.12010000.10 2010/01/11 10:14:24 vmididho ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ghr_cpdf_dynrpt.';  -- Global package name
--

--

  ---------------------------------------------------------------------------------------------
  -- This will delete all the dynamics report records for the current session and report type
  -- 'DYNAMICS'
  ---------------------------------------------------------------------------------------------
  PROCEDURE cleanup_table IS
  BEGIN
     DELETE FROM ghr_cpdf_temp
      WHERE report_type ='DYNAMICS'
        AND session_id = USERENV('SESSIONID');
     COMMIT;
  END;
  --
  ---------------------------------------------------------------------------------------------
  -- This function returns TRUE if we should exclude the agency
  -- since this function is to be used in a SQL where clause can not return a BOOLEAN
  -- so return the same thing in a VARCHAR2 field!
  -- this list come
  ---------------------------------------------------------------------------------------------
  --
  FUNCTION exclude_agency (p_agency_code IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_agency_code IN ('AMAD','ARCD','DD05','DD11','DD28','DD36','DD54','DD59')
      OR SUBSTR(p_agency_code,1,2) IN ('BJ','CI','FR','JL','LA','LB','LC','LD','LG'
                                      ,'LL','LQ','OV','PI','PJ','PO','TV','WH','ZG') THEN
      RETURN ('TRUE');
    ELSE
      RETURN ('FALSE');
    END IF;

  END exclude_agency;
  --
  ---------------------------------------------------------------------------------------------
  -- This function returns 'TRUE' if we should exclude the noac
  -- since this function is to be used in a SQL where clause can not return a BOOLEAN
  -- so return the same thing in a VARCHAR2 field!
  -- The Noac's to exclude are 900-999
  -- Note: we include the 4 character noa's though
  -- i.e. 100  include
  --      900  exclude
  --      A100 include
  --      A900 exclude
  -- assumes there are no dual actions with 900 in one NOA and a NOA we report in the other!!!
  --For title 38 changes, NOACs 850 and 855 are to be exclueded.
  ---------------------------------------------------------------------------------------------
  --
  FUNCTION exclude_noac (p_first_noac       IN VARCHAR2
                        ,p_second_noac      IN VARCHAR2
                        ,p_noa_family_code  IN VARCHAR2)
    RETURN VARCHAR2 IS
  l_noac   VARCHAR2(4);
  BEGIN
    IF p_noa_family_code IN ('CORRECT','CANCEL') THEN
      l_noac := format_noac(p_second_noac);
    ELSE
      l_noac := format_noac(p_first_noac);
    END IF;
--
-- The NOACs not to be printed as per OPM standards are added to the list
-- These NOACs are added under due to reference of NOACs as 7% and 8% under EHRI code changes.
--
    IF (l_noac BETWEEN '900' and '999') or
       (l_noac IN ( '850','855','750','782','800','805','806','880','881','882','883')) THEN
      RETURN ('TRUE');
    ELSE
      RETURN ('FALSE');
    END IF;

  END exclude_noac;
  --
  ---------------------------------------------------------------------------------------------
  -- This function returns TRUE if the info passed in means it is a non us citizen
  -- AND a foreign DS
  ---------------------------------------------------------------------------------------------
  FUNCTION  non_us_citizen_and_foreign_ds (p_citizenship       IN VARCHAR2
                                          ,p_duty_station_code IN VARCHAR2)
    RETURN BOOLEAN IS
  l_ds_2chars  VARCHAR2(2);
  BEGIN
    -- The definition of non us citizen is citizenship does not equal 1
    IF p_citizenship <> 1 THEN
      -- The deifnition of a 'foreign' duty staion is:
      -- If the first 2 positions of the duty station are alphabetic this means it is either
      --    1) foreign country
      -- or 2) US possesion
      -- or 3) US administritive area
      -- Since all we what is 1)'s we exclude 2) and 3)'s by the list GQ,RQ etc...
      l_ds_2chars := TRANSLATE(SUBSTR(p_duty_station_code,1,2),'0123456789','000000000');
      IF l_ds_2chars <> '00'
        AND l_ds_2chars NOT IN ('GQ','RQ','AQ','FM','JQ',
                                'CQ','MQ','RM','HQ','PS',
                                'BQ','WQ','VQ') THEN
        RETURN(TRUE);
      END IF;
    END IF;
    RETURN (FALSE);
  END non_us_citizen_and_foreign_ds;
  --
  ---------------------------------------------------------------------------------------------
  -- This function returns 'TRUE' if the for the position passed in on the given date
  -- it is not an Appopriated fund
  ---------------------------------------------------------------------------------------------
  FUNCTION exclude_position (p_position_id    IN NUMBER
                            ,p_effective_date IN DATE)
    RETURN BOOLEAN IS
  --
  l_pos_ei_grp2_data  per_position_extra_info%rowtype;
  l_position_type     VARCHAR2(150);
  --
  BEGIN
    -- first get the Position Type on Position Group 2
    ghr_history_fetch.fetch_positionei(
      p_position_id      => p_position_id,
      p_information_type => 'GHR_US_POS_GRP2',
      p_date_effective   => p_effective_date,
      p_pos_ei_data      => l_pos_ei_grp2_data);
    --
    l_position_type := l_pos_ei_grp2_data.poei_information17;
    --
    --8886374 removed APPR in NVL comparison and made '@#'
    IF NVL(l_position_type,'@#') <> 'APPR' THEN
      RETURN (TRUE);
    ELSE
      RETURN (FALSE);
    END IF;
  END exclude_position;
  --
  ---------------------------------------------------------------------------------------------
  -- B) This section includes any getting of extra data procedures
  ---------------------------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------------------------
  --  This one gets org component (also refered to as org structure id) for a given position
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_org_comp (p_position_id      IN  NUMBER
                         ,p_effective_date   IN  DATE
                         ,p_org_comp         OUT NOCOPY VARCHAR2) IS
  --
  l_pos_ei_grp1_data     per_position_extra_info%ROWTYPE;
  BEGIN
    ghr_history_fetch.fetch_positionei(p_position_id      => p_position_id
                                      ,p_information_type => 'GHR_US_POS_GRP1'
                                      ,p_date_effective   => p_effective_date
                                      ,p_pos_ei_data      => l_pos_ei_grp1_data);

    p_org_comp := l_pos_ei_grp1_data.poei_information5;
  EXCEPTION
     WHEN OTHERS THEN
      p_org_comp := NULL;
      raise;
  END get_org_comp;
  --
  ---------------------------------------------------------------------------------------------
  --  This one gets sex for a given person
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_sex (p_person_id      IN  NUMBER
                    ,p_effective_date IN  DATE
                    ,p_sex            OUT NOCOPY VARCHAR2) IS
  CURSOR cur_per_sex IS
    SELECT per.sex
    FROM   per_all_people_f per
    WHERE  per.person_id = p_person_id
    AND    p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date;
  BEGIN
    FOR cur_per_sex_rec IN cur_per_sex LOOP
      p_sex := cur_per_sex_rec.sex;
    END LOOP;
  EXCEPTION
      WHEN OTHERS THEN
      p_sex := NULL;
      raise;
  END get_sex;
  --
  ---------------------------------------------------------------------------------------------
  --  Returns the whole ghr_pa_request_extra_info (rei) record for a given info type
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_PAR_EI (p_pa_request_id            IN  NUMBER
                       ,p_noa_family_code          IN  VARCHAR2
                       ,p_information_type         IN  VARCHAR2
                       ,p_rei_rec                  OUT NOCOPY ghr_pa_request_extra_info%ROWTYPE) IS
  CURSOR c_par IS
    SELECT par.pa_request_id
    FROM   ghr_pa_requests par
    CONNECT BY par.pa_request_id = prior par.altered_pa_request_id
    START WITH par.pa_request_id = p_pa_request_id;
  --
  CURSOR cur_rei (cp_pa_request_id IN NUMBER) IS
    SELECT *
    FROM   ghr_pa_request_extra_info rei
    WHERE  rei.information_type = p_information_type
    AND    rei.pa_request_id    = cp_pa_request_id;
  --
   l_rei_rec ghr_pa_request_extra_info%ROWTYPE;
  BEGIN
    -- This extra info is actually on all NOAC's
    -- For corrections, need a different way to get the data form the original 52 being
    -- corrected since we do not populate the data for a correction!
    IF p_noa_family_code <> 'CORRECT' THEN
      FOR cur_rei_rec IN cur_rei(p_pa_request_id) LOOP
        p_rei_rec := cur_rei_rec;
      END LOOP;
    ELSE
      -- loop round all the pa_requests, picking up anything that is blank
      FOR c_par_rec IN c_par LOOP
        FOR cur_rei_rec IN cur_rei(c_par_rec.pa_request_id) LOOP
          IF l_rei_rec.rei_information1 IS NULL THEN
            l_rei_rec.rei_information1 := cur_rei_rec.rei_information1;
          END IF;
          IF l_rei_rec.rei_information2 IS NULL THEN
            l_rei_rec.rei_information2 := cur_rei_rec.rei_information2;
          END IF;
          IF l_rei_rec.rei_information3 IS NULL THEN
            l_rei_rec.rei_information3 := cur_rei_rec.rei_information3;
          END IF;
          IF l_rei_rec.rei_information4 IS NULL THEN
            l_rei_rec.rei_information4 := cur_rei_rec.rei_information4;
          END IF;
          IF l_rei_rec.rei_information5 IS NULL THEN
            l_rei_rec.rei_information5 := cur_rei_rec.rei_information5;
          END IF;
          IF l_rei_rec.rei_information6 IS NULL THEN
            l_rei_rec.rei_information6 := cur_rei_rec.rei_information6;
          END IF;
          IF l_rei_rec.rei_information7 IS NULL THEN
            l_rei_rec.rei_information7 := cur_rei_rec.rei_information7;
          END IF;
          IF l_rei_rec.rei_information8 IS NULL THEN
            l_rei_rec.rei_information8 := cur_rei_rec.rei_information8;
          END IF;
          IF l_rei_rec.rei_information9 IS NULL THEN
            l_rei_rec.rei_information9 := cur_rei_rec.rei_information9;
          END IF;
          IF l_rei_rec.rei_information10 IS NULL THEN
            l_rei_rec.rei_information10 := cur_rei_rec.rei_information10;
          END IF;
          IF l_rei_rec.rei_information11 IS NULL THEN
            l_rei_rec.rei_information11 := cur_rei_rec.rei_information11;
          END IF;
          IF l_rei_rec.rei_information12 IS NULL THEN
            l_rei_rec.rei_information12 := cur_rei_rec.rei_information12;
          END IF;
          IF l_rei_rec.rei_information13 IS NULL THEN
            l_rei_rec.rei_information13 := cur_rei_rec.rei_information13;
          END IF;
          IF l_rei_rec.rei_information14 IS NULL THEN
            l_rei_rec.rei_information14 := cur_rei_rec.rei_information14;
          END IF;
          IF l_rei_rec.rei_information15 IS NULL THEN
            l_rei_rec.rei_information15 := cur_rei_rec.rei_information15;
          END IF;
          IF l_rei_rec.rei_information16 IS NULL THEN
            l_rei_rec.rei_information16 := cur_rei_rec.rei_information16;
          END IF;
          IF l_rei_rec.rei_information17 IS NULL THEN
            l_rei_rec.rei_information17 := cur_rei_rec.rei_information17;
          END IF;
          IF l_rei_rec.rei_information18 IS NULL THEN
            l_rei_rec.rei_information18 := cur_rei_rec.rei_information18;
          END IF;
          IF l_rei_rec.rei_information19 IS NULL THEN
            l_rei_rec.rei_information19 := cur_rei_rec.rei_information19;
          END IF;
          IF l_rei_rec.rei_information20 IS NULL THEN
            l_rei_rec.rei_information20 := cur_rei_rec.rei_information20;
          END IF;
          IF l_rei_rec.rei_information21 IS NULL THEN
            l_rei_rec.rei_information21 := cur_rei_rec.rei_information21;
          END IF;
          IF l_rei_rec.rei_information22 IS NULL THEN
            l_rei_rec.rei_information22 := cur_rei_rec.rei_information22;
          END IF;
          IF l_rei_rec.rei_information23 IS NULL THEN
            l_rei_rec.rei_information23 := cur_rei_rec.rei_information23;
          END IF;
          IF l_rei_rec.rei_information24 IS NULL THEN
            l_rei_rec.rei_information24 := cur_rei_rec.rei_information24;
          END IF;
          IF l_rei_rec.rei_information25 IS NULL THEN
            l_rei_rec.rei_information25 := cur_rei_rec.rei_information25;
          END IF;
          IF l_rei_rec.rei_information26 IS NULL THEN
            l_rei_rec.rei_information26 := cur_rei_rec.rei_information26;
          END IF;
          IF l_rei_rec.rei_information27 IS NULL THEN
            l_rei_rec.rei_information27 := cur_rei_rec.rei_information27;
          END IF;
          IF l_rei_rec.rei_information28 IS NULL THEN
            l_rei_rec.rei_information28 := cur_rei_rec.rei_information28;
          END IF;
          IF l_rei_rec.rei_information29 IS NULL THEN
            l_rei_rec.rei_information29 := cur_rei_rec.rei_information29;
          END IF;
          IF l_rei_rec.rei_information30 IS NULL THEN
            l_rei_rec.rei_information30 := cur_rei_rec.rei_information30;
          END IF;
        END LOOP;
      END LOOP;
      p_rei_rec := l_rei_rec;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
      p_rei_rec := NULL;
      raise;
  END get_PAR_EI;
  --
  ---------------------------------------------------------------------------------------------
  --  This one gets the details from the PAR Extra info for Performance appraisal
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_per_sit_perf_appraisal(p_person_id                IN  NUMBER
                                      ,p_effective_date           IN  DATE
                                      ,p_rating_of_record_level   OUT NOCOPY VARCHAR2
                                      ,p_rating_of_record_pattern OUT NOCOPY VARCHAR2
                                      ,p_rating_of_record_period  OUT NOCOPY DATE) IS
  --
  l_special_info   ghr_api.special_information_type;
  l_emp_number     per_people_f.employee_number%TYPE;
  CURSOR c_per IS
    SELECT per.employee_number
      FROM per_people_f per
     WHERE per.person_id = p_person_id
       AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN per.effective_start_date
                                                     AND per.effective_end_date;
  BEGIN
    ghr_api.return_special_information(p_person_id, 'US Fed Perf Appraisal',
                                       p_effective_date, l_special_info);

    IF l_special_info.object_version_number IS NOT NULL THEN
      p_rating_of_record_level   := l_special_info.segment5;
      p_rating_of_record_pattern := l_special_info.segment4;
      p_rating_of_record_period  := fnd_date.canonical_to_date(l_special_info.segment6);
    ELSE -- Added select for bug# 1389262
      DECLARE
        l_effective_date DATE;
      BEGIN
        SELECT MAX(pan.date_from)
          INTO l_effective_date
          FROM per_person_analyses pan,
               fnd_id_flex_structures flx
         WHERE pan.id_flex_num = flx.id_flex_num
           AND flx.id_flex_code = 'PEA'
           AND flx.application_id = 800
           AND flx.id_flex_structure_code = 'US_FED_PERF_APPRAISAL'
           AND pan.person_id = p_person_id;
        ghr_api.return_special_information(p_person_id, 'US Fed Perf Appraisal',
                                           l_effective_date, l_special_info);
        IF l_special_info.object_version_number IS NOT NULL THEN
          p_rating_of_record_level   := l_special_info.segment5;
          p_rating_of_record_pattern := l_special_info.segment4;
          p_rating_of_record_period  := fnd_date.canonical_to_date(l_special_info.segment6);
	/* Pradeep commented this for the Bug 4005811
		  ELSE
          raise NO_DATA_FOUND;
   End of Bug 4005811*/
        END IF;
      /*EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Generate entry in PROCESS_LOG
          OPEN c_per;
          FETCH c_per INTO l_emp_number;
          CLOSE c_per;
          ghr_mto_int.log_message(p_procedure => 'No US Fed Perf Appraisal Info',
                                  p_message   => 'Employee number ' || l_emp_number ||
                                                 ' does not have US Fed Perf Appraisal ' ||
                                                 'on ' || TO_CHAR(p_effective_date, 'DD-MON-YYYY'));*/
      END;
    END IF;
 EXCEPTION
      WHEN OTHERS THEN
      p_rating_of_record_level   := NULL;
      p_rating_of_record_pattern := NULL;
      p_rating_of_record_period  := NULL;
      raise;
  END get_per_sit_perf_appraisal;
  --
  ---------------------------------------------------------------------------------------------
  --  This one gets the details from the PAR Extra info for NOAC specific
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_PAR_EI_noac (p_pa_request_id                IN  NUMBER
                            ,p_first_noa_id                 IN  NUMBER
                            ,p_second_noa_id                IN  NUMBER
                            ,p_noa_family_code              IN  VARCHAR2
                            ,p_person_id                    IN  NUMBER
                            ,p_effective_date               IN  DATE
                            ,p_creditable_military_service  OUT NOCOPY VARCHAR2
                            ,p_frozen_service               OUT NOCOPY VARCHAR2
                            ,p_from_retirement_coverage     OUT NOCOPY VARCHAR2
                            ,p_race_national_origin         OUT NOCOPY VARCHAR2
                            ,p_handicap_code                OUT NOCOPY VARCHAR2
                            ,p_ind_group_award              OUT NOCOPY VARCHAR2
                            ,p_benefit_award                OUT NOCOPY VARCHAR2
                            ,p_race_ethnic_info             OUT NOCOPY VARCHAR2) IS
  --
  -- Bug#5168568 Removed Information type GHR_US_PAR_ETHNICITY_RACE
  -- Having this EIT in the list is skipping the printing of Military service, frozen service.
  CURSOR c_rit IS
    SELECT rit.information_type
    FROM   ghr_noa_families          nfa
          ,ghr_pa_request_info_types rit
    WHERE  rit.noa_family_code = nfa.noa_family_code
    AND    (nfa.nature_of_action_id = p_first_noa_id
       OR   nfa.nature_of_action_id = p_second_noa_id)
    AND    rit.information_type IN ('GHR_US_PAR_AWARDS_BONUS'  ,'GHR_US_PAR_APPT_INFO'
                                   ,'GHR_US_PAR_APPT_TRANSFER' ,'GHR_US_PAR_CONV_APP'
                                   ,'GHR_US_PAR_RETURN_TO_DUTY','GHR_US_PAR_CHG_RETIRE_PLAN'
                                   ,'GHR_US_PAR_CHG_SCD');
  --
  l_information_type     ghr_pa_request_extra_info.information_type%TYPE;
  l_rei                  ghr_pa_request_extra_info%ROWTYPE;
  l_race_national_origin VARCHAR2(150);
  l_handicap_code        VARCHAR2(150);
  l_per_ei_grp1_data     per_people_extra_info%rowtype;

  BEGIN
    -- first get the information type for this NOA -- must only be one!!
    FOR c_rit_rec IN c_rit LOOP
      l_information_type := c_rit_rec.information_type;
    END LOOP;

    -- Only bother doing the rest if we got one we are interested in!
    IF l_information_type IS NOT NULL THEN
      get_PAR_EI (p_pa_request_id
                 ,p_noa_family_code
                 ,l_information_type
                 ,l_rei);
      --

      IF l_information_type = 'GHR_US_PAR_AWARDS_BONUS' THEN
        p_ind_group_award             := l_rei.rei_information6;
        p_benefit_award               := l_rei.rei_information7;
      ELSIF l_information_type = 'GHR_US_PAR_APPT_INFO' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information4,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information7,1,4);
        p_from_retirement_coverage     := l_rei.rei_information14;
        l_race_national_origin         := l_rei.rei_information16;
        l_handicap_code                := l_rei.rei_information8;
        --
      ELSIF l_information_type = 'GHR_US_PAR_APPT_TRANSFER' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information6,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information9,1,4);
        p_from_retirement_coverage     := l_rei.rei_information16;
        l_race_national_origin         := l_rei.rei_information18;
        l_handicap_code                := l_rei.rei_information10;
        --
      ELSIF l_information_type = 'GHR_US_PAR_CONV_APP' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information4,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information6,1,4);
        p_from_retirement_coverage     := l_rei.rei_information10;
        l_race_national_origin         := l_rei.rei_information12;
        l_handicap_code                := l_rei.rei_information7;
        --
      ELSIF l_information_type = 'GHR_US_PAR_RETURN_TO_DUTY' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information3,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information5,1,4);
        --
      ELSIF l_information_type = 'GHR_US_PAR_CHG_RETIRE_PLAN' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information3,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information5,1,4);
        p_from_retirement_coverage     := l_rei.rei_information6;
        --
      ELSIF l_information_type = 'GHR_US_PAR_CHG_SCD' THEN
        p_creditable_military_service  := SUBSTR(l_rei.rei_information5,1,4);
        p_frozen_service               := SUBSTR(l_rei.rei_information6,1,4);
        p_from_retirement_coverage     := l_rei.rei_information7;
       -- -- Bug 4724337 Race or National Origin changes
      ELSIF  l_information_type = 'GHR_US_PAR_ETHNICITY_RACE' THEN
      	IF l_rei.rei_information3 IS NOT NULL OR
		  	 l_rei.rei_information4 IS NOT NULL OR
		  	 l_rei.rei_information5 IS NOT NULL OR
		  	 l_rei.rei_information6 IS NOT NULL OR
		  	 l_rei.rei_information7 IS NOT NULL OR
		  	 l_rei.rei_information8 IS NOT NULL THEN
		  	 	p_race_ethnic_info := NVL(l_rei.rei_information3,'0') || NVL(l_rei.rei_information4,'0') || NVL(l_rei.rei_information5,'0') ||
		  	 							NVL(l_rei.rei_information6,'0') || NVL(l_rei.rei_information7,'0') || NVL(l_rei.rei_information8,'0');
       END IF; -- IF l_rei.rei_information3 IS NOT
      -- End Bug 4724337 Race or National Origin changes
      END IF; -- IF l_information_type = 'GHR_US_PAR_
   END IF;   -- IF l_information_type IS NOT NULL
    --
    -- bug 711711
    -- if RNO or Handicap code was not filled then get them from HR Person EI
    IF   l_race_national_origin IS NULL
      OR l_handicap_code IS NULL THEN
      ghr_history_fetch.fetch_peopleei(
        p_person_id        => p_person_id,
        p_information_type => 'GHR_US_PER_GROUP1',
        p_date_effective   => p_effective_date,
        p_per_ei_data      => l_per_ei_grp1_data);
      --
      IF l_race_national_origin IS NULL THEN
        l_race_national_origin := l_per_ei_grp1_data.pei_information5;
      END IF;
      --
      IF l_handicap_code IS NULL THEN
        l_handicap_code := l_per_ei_grp1_data.pei_information11;
      END IF;
    END IF;

    IF p_race_ethnic_info IS NULL THEN
    		-- Fetching Race and ethnicity category
		l_per_ei_grp1_data := NULL; -- Bug 4724337
	    ghr_history_fetch.fetch_peopleei
		  (p_person_id           =>  p_person_id,
		    p_information_type   =>  'GHR_US_PER_ETHNICITY_RACE',
		    p_date_effective     =>  p_effective_date,
	            p_per_ei_data    =>  l_per_ei_grp1_data
		  );
		  -- Populate Race only if atleast one data segment is entered.
		  IF l_per_ei_grp1_data.pei_information3 IS NOT NULL OR
		  	 l_per_ei_grp1_data.pei_information4 IS NOT NULL OR
		  	 l_per_ei_grp1_data.pei_information5 IS NOT NULL OR
		  	 l_per_ei_grp1_data.pei_information6 IS NOT NULL OR
		  	 l_per_ei_grp1_data.pei_information7 IS NOT NULL OR
		  	 l_per_ei_grp1_data.pei_information8 IS NOT NULL THEN
		  	 p_race_ethnic_info := NVL(l_per_ei_grp1_data.pei_information3,'0') || NVL(l_per_ei_grp1_data.pei_information4,'0') || NVL(l_per_ei_grp1_data.pei_information5,'0') ||
		  						  NVL(l_per_ei_grp1_data.pei_information6,'0') || NVL(l_per_ei_grp1_data.pei_information7,'0') || NVL(l_per_ei_grp1_data.pei_information8,'0');
		  END IF;
		  -- End Bug 4714292 EHRI Reports Changes for EOY 05
    END IF;

    p_race_national_origin := l_race_national_origin;
    p_handicap_code        := l_handicap_code;

  EXCEPTION
      WHEN OTHERS THEN
      p_creditable_military_service := NULL;
      p_frozen_service		    	:= NULL;
      p_from_retirement_coverage    := NULL;
      p_race_national_origin        := NULL;
      p_handicap_code               := NULL;
      p_ind_group_award             := NULL;
      p_benefit_award               := NULL;
      p_race_ethnic_info			:= NULL;
      raise;
  END get_PAR_EI_noac;
  --
  ---------------------------------------------------------------------------------------------
  -- This one gets the prior Work schedule and Pay Rate Determinant.
  -- As an enhancement we should add these columns as well as prior duty station to the PAR
  -- table since as is we have to go to history to get them!!
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_prior_ws_prd_ds (p_pa_request_id             IN  NUMBER
                                ,p_altered_pa_request_id     IN  NUMBER
                                ,p_first_noa_id              IN  NUMBER
                                ,p_second_noa_id             IN  NUMBER
                                ,p_person_id                 IN  NUMBER
                                ,p_employee_assignment_id    IN  NUMBER
                                ,p_from_position_id          IN  NUMBER
                                ,p_effective_date            IN  DATE
                                ,p_status                    IN  VARCHAR2
                                ,p_from_work_schedule        OUT NOCOPY VARCHAR2
                                ,p_from_pay_rate_determinant OUT NOCOPY VARCHAR2
                                ,p_from_duty_station_code    OUT NOCOPY VARCHAR2) IS
  --
  l_pa_request_id     NUMBER;
  l_noa_id            NUMBER;
  --
  l_asgei_data        per_assignment_extra_info%ROWTYPE;
  l_asgn_data         per_all_assignments_f%ROWTYPE;
  l_assignment_id     NUMBER;
  l_location_id       NUMBER;
  l_duty_station_id   NUMBER;
  l_duty_station_code ghr_duty_stations_f.duty_station_code%TYPE;
  l_dummy_varchar     VARCHAR2(2000);
  l_dummy_number      NUMBER;

  --8275231
  cursor get_first_noa_id
      is
      select first_noa_id
      from   ghr_pa_requests
      where pa_request_id = (select 	min(pa_request_id)
                             from 	ghr_pa_requests
                             connect by  pa_request_id = prior altered_pa_request_id
                             start with  pa_request_id = p_pa_request_id);

  cursor get_dual_det
      is
      select rpa_type,
             mass_action_id,
	     first_noa_code,
	     second_noa_code
      from   ghr_pa_requests
      where  pa_request_id = p_pa_request_id;
     --8275231

BEGIN
    -- If the PAR has happened then need to go to history to get it
    -- otherwise we can use the same procedure the form, update hr and edits uses
    IF p_status = 'UPDATE_HR_COMPLETE' THEN
      --
      IF p_altered_pa_request_id IS NULL THEN -- ie nothing is really being corrected
        l_pa_request_id := p_pa_request_id;
        l_noa_id        := p_first_noa_id;

	--8275231
	for rec_get_dual_det in get_dual_det
	loop
	   if rec_get_dual_det.second_noa_code is not null and
	       rec_get_dual_det.first_noa_code not in ('001','002') then
	      open get_first_noa_id;
 	      fetch get_first_noa_id into l_noa_id;
	      close get_first_noa_id;
	   end if;
	end loop;
	--8275231

      ELSE
        l_pa_request_id := p_altered_pa_request_id;
        l_noa_id        := p_second_noa_id;

	--8275231
	for rec_get_dual_det in get_dual_det
	loop
	   if rec_get_dual_det.rpa_type = 'DUAL' and rec_get_dual_det.mass_action_id is not null then
	      open get_first_noa_id;
 	      fetch get_first_noa_id into l_noa_id;
	      close get_first_noa_id;
	   end if;
	end loop;
	--8275231
      END IF;
      --
      -- Only need to even attempt to get these details is from position id is given!!
      -- This means we wills tive give values for 5__ NOAC's even though the guide says
      -- they are not needed?
      --
      IF p_from_position_id IS NOT NULL THEN
        GHR_HISTORY_FETCH.fetch_asgei_prior_root_sf50(p_assignment_id         => p_employee_assignment_id
                                                     ,p_information_type      => 'GHR_US_ASG_SF52'
                                                     ,p_altered_pa_request_id => l_pa_request_id
                                                     ,p_noa_id_corrected      => l_noa_id
                                                     ,p_date_effective        => p_effective_date
                                                     ,p_asgei_data            => l_asgei_data);
        --
        p_from_work_schedule        := l_asgei_data.aei_information7;
        p_from_pay_rate_determinant := l_asgei_data.aei_information6;
        --
        -- Now lets go get the location id which gives us the duty station
        GHR_HISTORY_FETCH.fetch_asgn_prior_root_sf50(p_assignment_id         => p_employee_assignment_id
                                                     ,p_altered_pa_request_id => l_pa_request_id
                                                     ,p_noa_id_corrected      => l_noa_id
                                                     ,p_date_effective        => p_effective_date
                                                     ,p_assignment_data       => l_asgn_data);
        --
        ghr_pa_requests_pkg.get_SF52_loc_ddf_details (l_asgn_data.location_id
                                                     ,l_duty_station_id);
        --
        ghr_pa_requests_pkg.get_duty_station_details (l_duty_station_id
                                                     ,p_effective_date
                                                     ,l_duty_station_code
                                                     ,l_dummy_varchar);
        p_from_duty_station_code := l_duty_station_code;
      END IF;
      --
    ELSE -- FUTURE_ACTION's
      IF p_from_position_id IS NOT NULL THEN
        l_assignment_id := p_employee_assignment_id;
        GHR_API.sf52_from_data_elements
                                 (p_person_id         => p_person_id
                                 ,p_assignment_id     => l_assignment_id
                                 ,p_effective_date    => p_effective_date
                                 ,p_altered_pa_request_id => null
                                 ,p_noa_id_corrected      => null
                                 ,p_pa_history_id         => null
                                 ,p_position_id       => l_dummy_number
                                 ,p_position_title    => l_dummy_varchar
                                 ,p_position_number   => l_dummy_varchar
                                 ,p_position_seq_no   => l_dummy_number
                                 ,p_pay_plan          => l_dummy_varchar
                                 ,p_job_id            => l_dummy_number
                                 ,p_occ_code          => l_dummy_varchar
                                 ,p_grade_id          => l_dummy_number
                                 ,p_grade_or_level    => l_dummy_varchar
                                 ,p_step_or_rate      => l_dummy_varchar
                                 ,p_total_salary      => l_dummy_number
                                 ,p_pay_basis         => l_dummy_varchar
				                 -- FWFA Changes Bug#4444609
				                 ,p_pay_table_identifier => l_dummy_number
				                 -- FWFA Changes
                                 ,p_basic_pay         => l_dummy_number
                                 ,p_locality_adj      => l_dummy_number
                                 ,p_adj_basic_pay     => l_dummy_number
                                 ,p_other_pay         => l_dummy_number
                                 ,p_au_overtime               => l_dummy_number
                                 ,p_auo_premium_pay_indicator => l_dummy_varchar
                                 ,p_availability_pay          => l_dummy_number
                                 ,p_ap_premium_pay_indicator  => l_dummy_varchar
                                 ,p_retention_allowance       => l_dummy_number
                                 ,p_retention_allow_percentage=> l_dummy_number
                                 ,p_supervisory_differential  => l_dummy_number
                                 ,p_supervisory_diff_percentage=> l_dummy_number
                                 ,p_staffing_differential     => l_dummy_number
                                 ,p_staffing_diff_percentage  => l_dummy_number
                                 ,p_organization_id           => l_dummy_number
                                 ,p_position_org_line1        => l_dummy_varchar
                                 ,p_position_org_line2        => l_dummy_varchar
                                 ,p_position_org_line3        => l_dummy_varchar
                                 ,p_position_org_line4        => l_dummy_varchar
                                 ,p_position_org_line5        => l_dummy_varchar
                                 ,p_position_org_line6        => l_dummy_varchar
                                 ,p_duty_station_location_id  => l_location_id
                                 ,p_pay_rate_determinant      => p_from_pay_rate_determinant
                                 ,p_work_schedule             => p_from_work_schedule);
        --
        ghr_pa_requests_pkg.get_SF52_loc_ddf_details (l_location_id
                                                     ,l_duty_station_id);

        ghr_pa_requests_pkg.get_duty_station_details (l_duty_station_id
                                                     ,p_effective_date
                                                     ,l_duty_station_code
                                                    ,l_dummy_varchar);
        p_from_duty_station_code := l_duty_station_code;
        --
      END IF;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
        p_from_work_schedule  := NULL;
        p_from_pay_rate_determinant := NULL;
        p_from_duty_station_code := NULL;
        raise;
  END get_prior_ws_prd_ds;
  --
  ---------------------------------------------------------------------------------------------
  -- For a 'Correction' record it gets the previous SSN if that is what is being corrected.
  ---------------------------------------------------------------------------------------------
  PROCEDURE get_prev_ssn (p_altered_pa_request_id        IN  NUMBER
                         ,p_employee_national_identifier IN  VARCHAR2
                         ,p_noa_family_code              IN  VARCHAR2
                         ,p_from_national_identifier     OUT NOCOPY VARCHAR2) IS
  --
  CURSOR cur_prev_ssn IS
    SELECT par.employee_national_identifier prev_ssn
    FROM   ghr_pa_requests par
    WHERE  par.pa_request_id = p_altered_pa_request_id;
  --
  BEGIN
    IF p_noa_family_code = 'CORRECT' THEN
      FOR cur_prev_ssn_rec IN cur_prev_ssn LOOP
        IF p_employee_national_identifier <> cur_prev_ssn_rec.prev_ssn THEN
          p_from_national_identifier := format_ni(cur_prev_ssn_rec.prev_ssn);
        END IF;
      END LOOP;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
      p_from_national_identifier := NULL;
      raise;
  END;
  --

  FUNCTION get_equivalent_pay_plan(p_pay_plan IN ghr_pay_plans.pay_plan%TYPE)
  RETURN VARCHAR2 IS
    l_result  ghr_pay_plans.equivalent_pay_plan%TYPE;
  BEGIN
    SELECT equivalent_pay_plan
      INTO l_result
      FROM ghr_pay_plans
     WHERE pay_plan = p_pay_plan;
    RETURN l_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_result := NULL;
      RETURN l_result;
  END get_equivalent_pay_plan;
  -- Function get_loc_pay_area_code returns the LOCALITY PAY AREA CODE attached to the Duty station.
  -- Bug# 3231946 Added parameter p_duty_station_code to fix the bug.
  -- With the addition of new parameter, this function can be used to find
  -- the locality pay area code by passing either duty_station_id or duty_station_code.
  FUNCTION get_loc_pay_area_code(
               p_duty_station_id IN ghr_duty_stations_f.duty_station_id%TYPE default NULL,
               p_duty_station_code IN ghr_duty_stations_f.duty_station_code%TYPE default NULL,
               p_effective_date  IN DATE)
  RETURN VARCHAR2 IS
    l_result     ghr_locality_pay_areas_f.locality_pay_area_code%TYPE;
  BEGIN

    IF p_duty_station_id is NOT NULL THEN
        SELECT lpa.locality_pay_area_code
          INTO l_result
          FROM ghr_locality_pay_areas_f lpa
              ,ghr_duty_stations_f      dst
         WHERE dst.duty_station_id = p_duty_station_id
           AND NVL(p_effective_date,TRUNC(sysdate))
                 BETWEEN dst.effective_start_date and dst.effective_end_date
           AND dst.locality_pay_area_id = lpa.locality_pay_area_id
           AND NVL(p_effective_date,TRUNC(sysdate))
                 BETWEEN lpa.effective_start_date and lpa.effective_end_date;
     ELSIF p_duty_station_code is NOT NULL THEN
          SELECT lpa.locality_pay_area_code
          INTO l_result
          FROM ghr_locality_pay_areas_f lpa
              ,ghr_duty_stations_f      dst
         WHERE dst.duty_station_code = p_duty_station_code
           AND NVL(p_effective_date,TRUNC(sysdate))
                 BETWEEN dst.effective_start_date and dst.effective_end_date
           AND dst.locality_pay_area_id = lpa.locality_pay_area_id
           AND NVL(p_effective_date,TRUNC(sysdate))
                 BETWEEN lpa.effective_start_date and lpa.effective_end_date;
     END IF;

     RETURN l_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_result := NULL;
      RETURN l_result;
    WHEN OTHERS THEN
      l_result := NULL;
      RETURN l_result;
  END get_loc_pay_area_code;

  ---------------------------------------------------------------------------------------------
  -- C) This section includes any formating needed for certain fields.
  -- Note: some formating is done in the report, but if possible it should be done here!
  ---------------------------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------------------------
  -- This function takes the standard ni format ie 999-99-9999
  -- and returns it without the -'s
  ---------------------------------------------------------------------------------------------
  FUNCTION format_ni(p_ni IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN(REPLACE(p_ni,'-') );
  END format_ni;
  --
  ---------------------------------------------------------------------------------------------
  -- This function takes the standard possibly 4 char noa code and
  -- if it is 4 long returns the last three chars!
  ---------------------------------------------------------------------------------------------
  FUNCTION format_noac(p_noac IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    IF LENGTH (p_noac) = 4 THEN
      RETURN(SUBSTR(p_noac,2,3) );
    END IF;
    RETURN(p_noac);
  END format_noac;
  --
  ---------------------------------------------------------------------------------------------
  -- This function takes the duty station code and if the first 2 positions
  -- are chars replaces the last 3 chars with zeros!
  -- i.e. the duty station is 1) foreign OR 2)US Possesion or 3) US administered Area
  ---------------------------------------------------------------------------------------------
  FUNCTION format_ds(p_duty_station_code IN VARCHAR2)
    RETURN VARCHAR2 IS
  l_ds_2chars  VARCHAR2(2);
  BEGIN
    l_ds_2chars := TRANSLATE(SUBSTR(upper(p_duty_station_code),1,2),
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ','**************************');
    IF l_ds_2chars = '**'  THEN
      RETURN(SUBSTR(p_duty_station_code,1,6)||'000' );
    ELSE
      RETURN(p_duty_station_code);
    END IF;
  END format_ds;
  --
  ---------------------------------------------------------------------------------------------
  -- This function takes the employees first last and middle names and puts them into the
  -- format: last name comma first name space middle names  - no longer than 23 chars
  ---------------------------------------------------------------------------------------------
  FUNCTION format_name (p_first_name  IN VARCHAR2
                       ,p_last_name   IN VARCHAR2
                       ,p_middle_name IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN(SUBSTR(p_last_name||','||p_first_name||' '||p_middle_name,1,23) );
  END format_name;
  ---------------------------------------------------------------------------------------------
  -- This function takes the any of the employees first, last or middle names and puts
  -- them back such that its not longer than 35 chars
  -- Added format_name_ehri for EHRI changes. The names cannot exceed more than 35 chars
  ---------------------------------------------------------------------------------------------
  FUNCTION format_name_ehri (p_name  IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN(SUBSTR(p_name,1,35) );
  END format_name_ehri;
  ---------------------------------------------------------------------------------------------
  -- This function will format the basic pay depending on the pay basis
  ---------------------------------------------------------------------------------------------
  FUNCTION format_basic_pay(p_basic_pay IN NUMBER
                           ,p_pay_basis IN VARCHAR2
                           ,p_size      IN NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_pay_basis IN ('PA','SY','PM','BW') THEN
      -- just report dollars
      IF p_basic_pay IS NOT NULL THEN
        RETURN ( LPAD(ROUND(p_basic_pay),p_size,'0') );
      ELSE
        RETURN(NULL);
      END IF;
    ELSIF p_pay_basis = 'WC' THEN
      -- report all zero's
      RETURN(SUBSTR('000000000000000000000',1,p_size) );
    ELSE
      -- report dollar and cents without decimal
      IF p_basic_pay IS NOT NULL THEN
        RETURN ( LPAD(ROUND(p_basic_pay,2) * 100,p_size,'0') );
      ELSE
        RETURN(NULL);
      END IF;
    END IF;
    --
  END format_basic_pay;
  --
  ---------------------------------------------------------------------------------------------
  -- This function is very simple just left pads the amount that was passed in with zero's to
  -- the size given
  ---------------------------------------------------------------------------------------------
  FUNCTION format_amount(p_amount IN NUMBER
                         ,p_size   IN NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_amount IS NOT NULL THEN
      RETURN ( LPAD(p_amount,p_size,'0') );
    ELSE
      RETURN(NULL);
    END IF;
    --
  END format_amount;
  --

  ---------------------------------------------------------------------------------------------
  -- Bug# 5417021 This function left pads the 100 multiplier of the amount(rounded to two places of decimal)
  -- that was passed in with zero's to the size given.
  -- This is used just for award_percentage field.
  ---------------------------------------------------------------------------------------------
  FUNCTION format_award_perc(p_amount IN NUMBER
                            ,p_size   IN NUMBER)
    RETURN VARCHAR2 IS
  BEGIN
    IF p_amount IS NOT NULL THEN
      RETURN ( LPAD((round(p_amount,2)*100),p_size,'0') );
    ELSE
     RETURN(NULL);
    END IF;
    --
  END format_award_perc;
  --

  ---------------------------------------------------------------------------------------------
  --  This will insert one record into the GHR_CPDF_TEMP
  ---------------------------------------------------------------------------------------------
  PROCEDURE insert_row (p_ghr_cpdf_temp_rec IN ghr_cpdf_temp%rowtype) IS
  BEGIN
    INSERT INTO ghr_cpdf_temp(
     			report_type,
     			session_id,
     			agency_code,
     			organizational_component,
     			personnel_office_id,
     			to_national_identifier,
     			employee_date_of_birth,
     			veterans_preference,
     			tenure,
     			service_comp_date,
     			retirement_plan,
                  creditable_military_service,
                  frozen_service,
                  from_retirement_coverage,
     			veterans_status,
     			sex,
     			race_national_origin,
     			handicap_code,
     			first_noa_code,
     			second_noa_code,
     			first_action_la_code1,
     			first_action_la_code2,
     			effective_date,
     			to_pay_plan,
     			to_occ_code,
     			to_grade_or_level,
     			to_step_or_rate,
     			to_basic_pay,
     			to_pay_basis,
     			to_work_schedule,
     			to_pay_rate_determinant,
     			position_occupied,
     			supervisory_status,
     			to_duty_station_code,
     			current_appointment_auth1,
     			current_appointment_auth2,
     			rating_of_record_level,
     			rating_of_record_pattern,
     			rating_of_record_period_ends,
     			individual_group_award,
     			award_amount,
     			benefit_amount,
     			employee_last_name,
     			from_pay_plan,
     			from_occ_code,
     			from_grade_or_level,
     			from_step_or_rate,
     			from_basic_pay,
     			from_pay_basis,
     			from_work_schedule,
     			from_pay_rate_determinant,
                  from_national_identifier,
     			from_locality_adj,
     			from_duty_station_code,
     			to_locality_adj,
     			to_staffing_differential,
     			to_supervisory_differential,
     			to_retention_allowance,
     			education_level,
     			academic_discipline,
     			year_degree_attained,
--			employee_last_name,
			employee_first_name,
			employee_middle_names,
			name_title,
			position_title,
			award_dollars,
			award_hours,
			award_percentage,
			SCD_retirement,
			SCD_rif ,
			race_ethnic_info
			)
    VALUES(
     			'DYNAMICS',
     			USERENV('SESSIONID'),
     			p_ghr_cpdf_temp_rec.agency_code,
     			p_ghr_cpdf_temp_rec.organizational_component,
     			p_ghr_cpdf_temp_rec.personnel_office_id,
     			p_ghr_cpdf_temp_rec.to_national_identifier,
    			p_ghr_cpdf_temp_rec.employee_date_of_birth,
     			p_ghr_cpdf_temp_rec.veterans_preference,
     			p_ghr_cpdf_temp_rec.tenure,
     			p_ghr_cpdf_temp_rec.service_comp_date,
     			p_ghr_cpdf_temp_rec.retirement_plan,
                  p_ghr_cpdf_temp_rec.creditable_military_service,
                  p_ghr_cpdf_temp_rec.frozen_service,
                  p_ghr_cpdf_temp_rec.from_retirement_coverage,
     			p_ghr_cpdf_temp_rec.veterans_status,
     			p_ghr_cpdf_temp_rec.sex,
     			p_ghr_cpdf_temp_rec.race_national_origin,
     			p_ghr_cpdf_temp_rec.handicap_code,
     			p_ghr_cpdf_temp_rec.first_noa_code,
     			p_ghr_cpdf_temp_rec.second_noa_code,
     			p_ghr_cpdf_temp_rec.first_action_la_code1,
     			p_ghr_cpdf_temp_rec.first_action_la_code2,
     			p_ghr_cpdf_temp_rec.effective_date,
     			p_ghr_cpdf_temp_rec.to_pay_plan,
     			p_ghr_cpdf_temp_rec.to_occ_code,
     			p_ghr_cpdf_temp_rec.to_grade_or_level,
     			p_ghr_cpdf_temp_rec.to_step_or_rate,
     			p_ghr_cpdf_temp_rec.to_basic_pay,
     			p_ghr_cpdf_temp_rec.to_pay_basis,
     			p_ghr_cpdf_temp_rec.to_work_schedule,
     			p_ghr_cpdf_temp_rec.to_pay_rate_determinant,
     			p_ghr_cpdf_temp_rec.position_occupied,
    			p_ghr_cpdf_temp_rec.supervisory_status,
     			p_ghr_cpdf_temp_rec.to_duty_station_code,
     			p_ghr_cpdf_temp_rec.current_appointment_auth1,
     			p_ghr_cpdf_temp_rec.current_appointment_auth2,
     			p_ghr_cpdf_temp_rec.rating_of_record_level,
     			p_ghr_cpdf_temp_rec.rating_of_record_pattern,
     			p_ghr_cpdf_temp_rec.rating_of_record_period_ends,
     			p_ghr_cpdf_temp_rec.individual_group_award,
    			p_ghr_cpdf_temp_rec.award_amount,
     			p_ghr_cpdf_temp_rec.benefit_amount,
     			p_ghr_cpdf_temp_rec.employee_last_name,
     			p_ghr_cpdf_temp_rec.from_pay_plan,
     			p_ghr_cpdf_temp_rec.from_occ_code,
     			p_ghr_cpdf_temp_rec.from_grade_or_level,
     			p_ghr_cpdf_temp_rec.from_step_or_rate,
     			p_ghr_cpdf_temp_rec.from_basic_pay,
     			p_ghr_cpdf_temp_rec.from_pay_basis,
     			p_ghr_cpdf_temp_rec.from_work_schedule,
     			p_ghr_cpdf_temp_rec.from_pay_rate_determinant,
     			p_ghr_cpdf_temp_rec.from_national_identifier,
     			p_ghr_cpdf_temp_rec.from_locality_adj,
     			p_ghr_cpdf_temp_rec.from_duty_station_code,
     			p_ghr_cpdf_temp_rec.to_locality_adj,
     			p_ghr_cpdf_temp_rec.to_staffing_differential,
     			p_ghr_cpdf_temp_rec.to_supervisory_differential,
     			p_ghr_cpdf_temp_rec.to_retention_allowance,
     			p_ghr_cpdf_temp_rec.education_level,
     			p_ghr_cpdf_temp_rec.academic_discipline,
     			p_ghr_cpdf_temp_rec.year_degree_attained,
--			p_ghr_cpdf_temp_rec.employee_last_name,
			p_ghr_cpdf_temp_rec.employee_first_name,
			p_ghr_cpdf_temp_rec.employee_middle_names,
			p_ghr_cpdf_temp_rec.name_title,
			p_ghr_cpdf_temp_rec.position_title,
			p_ghr_cpdf_temp_rec.award_dollars,
			p_ghr_cpdf_temp_rec.award_hours,
			p_ghr_cpdf_temp_rec.award_percentage,
			p_ghr_cpdf_temp_rec.SCD_retirement,
			p_ghr_cpdf_temp_rec.SCD_rif,
			p_ghr_cpdf_temp_rec.race_ethnic_info
			);

    COMMIT;

  END insert_row;


   PROCEDURE get_suffix_lname(p_last_name   in  varchar2,
                              p_report_date in  date,
                              p_suffix      out nocopy varchar2,
                              p_lname       out nocopy varchar2)
   IS
    l_suffix_pos number;
    l_total_len  number;
    l_proc       varchar2(30) := 'get_suffix_lname';

    CURSOR GET_SUFFIX IS
    SELECT INSTR(TRANSLATE(UPPER(p_last_name),',.','  '),' '||UPPER(LOOKUP_CODE),-1),
           LENGTH(p_last_name)
    FROM   HR_LOOKUPS
    WHERE  LOOKUP_TYPE = 'GHR_US_NAME_SUFFIX'
    AND    TRUNC(p_report_date) BETWEEN NVL(START_DATE_ACTIVE,p_report_date)
                                AND     NVL(END_DATE_ACTIVE,p_report_date)
    AND    RTRIM(SUBSTR(TRANSLATE(UPPER(p_last_name),',.','  '),
           INSTR(TRANSLATE(UPPER(p_last_name),',.','  '),' '||UPPER(LOOKUP_CODE),-1),
           LENGTH(p_last_name)),' ') = ' '||UPPER(LOOKUP_CODE)
    AND    ROWNUM = 1;
  BEGIN

  hr_utility.set_location('Entering:'||l_proc,5);

  IF GET_SUFFIX%ISOPEN THEN
     CLOSE GET_SUFFIX;
  END IF;

  OPEN GET_SUFFIX;
  --getting the position of a suffix appended in the lastname by comparing the lastname
  --  with the suffixes available in lookup*/
  FETCH GET_SUFFIX INTO l_suffix_pos, l_total_len;
  -- if the suffix is not found then returning the lastname by removing special characters
  IF GET_SUFFIX%NOTFOUND THEN
     p_lname  := RTRIM(p_last_name,' ,.');
     p_suffix := NULL;
   -- if the suffix is found then returning the lastname by removing special characters
   -- with suffix
  ELSE
     p_lname  := RTRIM(SUBSTR(p_last_name, 0, l_suffix_pos-1),' ,.');
     p_suffix := SUBSTR(p_last_name,l_suffix_pos+1,l_total_len);
  END IF;
  CLOSE GET_SUFFIX;
 END get_suffix_lname;

  --
   ---------------------------------------------------------------------------------------------
  -- This is the main procedure
  ---------------------------------------------------------------------------------------------
  PROCEDURE populate_ghr_cpdf_temp(p_agency     IN VARCHAR2
                                  ,p_start_date IN DATE
                                  ,p_end_date   IN DATE
                                  ,p_count_only IN BOOLEAN ) IS
      --
      l_proc 	              VARCHAR2(72)  := g_package||'populate_ghr_cpdf_temp';
      --
      l_info_type             VARCHAR2(200) := NULL;
      l_api_assignment_id     per_assignments.assignment_id%TYPE;
      --
      l_first_noa_id          ghr_pa_requests.first_noa_id%TYPE;
      l_first_noa_code        ghr_pa_requests.first_noa_code%TYPE;
      l_first_action_la_code1 ghr_pa_requests.first_action_la_code1%TYPE;
      l_first_action_la_code2 ghr_pa_requests.first_action_la_code2%TYPE;
      l_noa_family_code       ghr_pa_requests.noa_family_code%TYPE;
      l_multi_error_flag      boolean;
      --
      -- This cursor drives of the PAR table to first see which PA Requests had 'Update HR'
      -- selected by a user in the given period
      -- may as well select everyting from the PA Request table (saves going back!)

      -- 3/13/02 --  Joined the ghr_pa_requests table with per_people_f table to view the
      -- records based on business group id/security group id
      -- Not added outer join for per_people_f because we are expecting existence of person_id
      -- in ghr_pa_requests for the actions with status in ('UPDATE_HR_COMPLETE','FUTURE_ACTION')

      -- 24-OCT-2002 JH truncated sf50_approval_date because it does contain time on the db.
      -- which causes some rows to not be included on last day.

      CURSOR cur_get_pars IS
        SELECT par.*
        FROM   ghr_pa_requests par,
               per_people_f    per
        WHERE  NVL(par.agency_code,par.from_agency_code) LIKE p_agency
        AND    par.person_id = per.person_id
        AND    trunc(par.sf50_approval_date) BETWEEN per.effective_start_date
                                      AND     per.effective_end_date
        AND    trunc(par.sf50_approval_date) BETWEEN p_start_date AND p_end_date
	--bug #6976546 removed 'FUTURE_ACTION'
        AND    par.status IN ('UPDATE_HR_COMPLETE')
        AND    par.effective_date >= add_months(p_end_date,-24)
        AND    par.effective_date <= add_months(p_end_date,6)
        AND    exclude_agency(NVL(par.agency_code,par.from_agency_code)) <> 'TRUE'
        AND    exclude_noac(par.first_noa_code,par.second_noa_code,par.noa_family_code) <> 'TRUE';
      --

      --
      -- Note:
      --  1) The report calls this procedure in the before report trigger passing in the
      --     the two parameters the user actually passes in as agency code and subelement
      --     as one here called p_agency by concatanating the two and adding a %!!
      --  2) The AGENCY_CODE field should actually be thought of as the TO_AGENCY_CODE
      --     field as it is only populated if there is a TO position otherwise the FROM_AGENCY_CODE
      --     will be populated. When update HR is succesful we must have one of these.
      --     Bug 706585 has been raised to make sure it gets populated on UPDATE_HR and not UPDATE_HR_COMPLETE
      --     otherwise this will not be available to FUTURE_ACTIONS
      --  3) ordering of the records will be done in the report, by agency code then ssn

      l_ghr_cpdf_temp_rec    ghr_cpdf_temp%ROWTYPE;
      l_ghr_empty_cpdf_temp  ghr_cpdf_temp%ROWTYPE;
      l_ghr_pa_requests_rec  ghr_pa_requests%ROWTYPE;
      l_retained_grade_rec   ghr_pay_calc.retained_grade_rec_type;
      l_retained_pay_plan    ghr_pa_requests.to_pay_plan%type;
      l_retained_grade_or_level   ghr_pa_requests.to_grade_or_level%type;
      l_retained_step_or_rate     ghr_pa_requests.to_step_or_rate%type;
      l_sf52_rec1                 ghr_pa_requests%ROWTYPE;
      l_sf52_rec2                 ghr_pa_requests%ROWTYPE;
      l_dual_flg                  BOOLEAN:=FALSE;
      l_single_flg                BOOLEAN:=TRUE;
      l_loop                      NUMBER :=1;
      l_index                     NUMBER :=1;

      --Bug#2789704
      l_log_text                  ghr_process_log.log_text%type;
	  l_message_name           	  ghr_process_log.message_name%type;
	  l_log_date               	  ghr_process_log.log_date%type;

	-- Bug 	4542476
	l_locality_pay_area_code ghr_locality_pay_areas_f.locality_pay_area_code%type;
	l_equiv_plan ghr_pay_plans.equivalent_pay_plan%type;
	-- End Bug 	4542476


  CURSOR cur_per_details(p_person_id per_all_people_f.person_id%type)
  IS
  SELECT title,last_name
  FROM   per_all_people_f
  WHERE  person_id = p_person_id;

  CURSOR cur_scd_dates(p_pa_request_id   ghr_pa_requests.pa_request_id%type)
  IS
  SELECT REI_INFORMATION3 rif ,REI_INFORMATION8 ret
  FROM   ghr_pa_request_extra_info parei
  WHERE  parei.pa_request_id=p_pa_request_id
  AND    parei.information_type='GHR_US_PAR_CHG_SCD';

  --8275231
Cursor c_noa_family(p_noa_id in number,
                    p_effective_date in date)
        is
        Select fam.noa_family_code
        from   ghr_noa_families nof,
               ghr_families fam
        where  nof.nature_of_action_id =  p_noa_id
        and    fam.noa_family_code     = nof.noa_family_code
        and    nvl(fam.proc_method_flag,hr_api.g_varchar2) = 'Y'
        and    p_effective_date
        between nvl(fam.start_date_active,p_effective_date)
        and     nvl(fam.end_date_active,p_effective_date);


--8275231

 l_records_found	BOOLEAN;
 l_mesgbuff1            VARCHAR2(4000);
 l_scd_rif	        ghr_pa_request_extra_info.rei_information3%type;
 l_scd_ret	        ghr_pa_request_extra_info.rei_information8%type;
 ll_per_ei_data		per_people_extra_info%rowtype;
 l_last_name        per_all_people_f.last_name%type;
 l_suffix           per_all_people_f.title%type;

-- For Dual Actions PRD is becoming null so preserving it using a local variable.
 l_pay_rate_determinant ghr_pa_requests.pay_rate_determinant%TYPE;

  BEGIN
    --
l_records_found:=FALSE;
--    hr_utility.trace_on(null,'venkat');
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    ghr_mto_int.set_log_program_name('GHR_CPDF_DYNRPT');
    --
IF p_end_date > p_start_Date THEN

    FOR  cur_get_pars_rec IN cur_get_pars
    LOOP
        hr_utility.set_location(l_proc||' Get PA Request data', 20);
        -- 1) Get PA Request data
        l_ghr_pa_requests_rec := cur_get_pars_rec;

        l_sf52_rec1           := l_ghr_pa_requests_rec;
        l_sf52_rec2           := l_ghr_pa_requests_rec;

		-- Begin Bug# 5109841
		IF l_ghr_pa_requests_rec.second_noa_code IS NOT NULL
			AND l_ghr_pa_requests_rec.first_noa_code NOT IN ('001','002') THEN
			 l_loop       := 2;
            l_dual_flg   := TRUE;
            l_single_flg := FALSE;
        ELSE
            l_loop       := 1;
            l_single_flg := TRUE;
            l_dual_flg   := FALSE;
        END IF;

		/*
        If ( l_ghr_pa_requests_rec.first_noa_code like '3%'and
             l_ghr_pa_requests_rec.second_noa_code ='825' )  THEN
            l_loop       := 2;
            l_dual_flg   := TRUE;
            l_single_flg := FALSE;
        ELSE
            l_loop       := 1;
            l_single_flg := TRUE;
            l_dual_flg   := FALSE;
        END IF;
		*/
		-- End Bug# 5109841
        --
        /*    COMMENTED THE ENTIRE IF CONDITION TO FIX BUG 3212482
        -- For Correction record need to build the whole lot up!
        -- OK it appears this function creates the whole 52 again! i.e switches the
        -- second noa details into the first no details
        Bug # 2884948 With New Correction NPA changes, we are saving the all the to side pay data in
        ghr_pa_requests table.  So no need to call build_corrected_sf52
        IF l_ghr_pa_requests_rec.noa_family_code = 'CORRECT' THEN
        l_first_noa_id          := l_ghr_pa_requests_rec.first_noa_id;
        l_first_noa_code        := l_ghr_pa_requests_rec.first_noa_code;
        l_first_action_la_code1 := l_ghr_pa_requests_rec.first_action_la_code1;
        l_first_action_la_code2 := l_ghr_pa_requests_rec.first_action_la_code2;
        --

        ghr_corr_canc_sf52.build_corrected_sf52
        (p_pa_request_id    => l_ghr_pa_requests_rec.pa_request_id
        ,p_noa_code_correct => l_ghr_pa_requests_rec.second_noa_code
        ,p_sf52_data_result => l_ghr_pa_requests_rec);

        --
        l_ghr_pa_requests_rec.second_noa_id          := l_ghr_pa_requests_rec.first_noa_id;
        l_ghr_pa_requests_rec.second_noa_code        := l_ghr_pa_requests_rec.first_noa_code;
        l_ghr_pa_requests_rec.second_action_la_code1 := l_ghr_pa_requests_rec.first_action_la_code1;
        l_ghr_pa_requests_rec.second_action_la_code2 := l_ghr_pa_requests_rec.first_action_la_code2;

        l_ghr_pa_requests_rec.first_noa_id          := l_first_noa_id;
        l_ghr_pa_requests_rec.first_noa_code        := l_first_noa_code;
        l_ghr_pa_requests_rec.first_action_la_code1 := l_first_action_la_code1;
        l_ghr_pa_requests_rec.first_action_la_code2 := l_first_action_la_code2;
        l_ghr_pa_requests_rec.noa_family_code       := 'CORRECT';

        END IF;
        */
        --
        -- 2) Do any further checks to see if this PAR record should be included in the report:
        --
        FOR l_index in 1..l_loop
        LOOP
            BEGIN
					 -- Loop twice for dual action
                IF ( l_dual_flg = TRUE and l_index = 1 ) then
		--6850492 modified for dual action to assign pay rate determinant
		  /*  l_pay_rate_determinant := l_ghr_pa_requests_rec.pay_rate_determinant;
                    ghr_process_sf52.assign_new_rg( p_action_num  => 1,
                                            p_pa_req      => l_sf52_rec1);

                    l_ghr_pa_requests_rec := l_sf52_rec1;
		    if l_sf52_rec1.pay_rate_determinant is null then
		       l_ghr_pa_requests_rec.pay_rate_determinant := l_pay_rate_determinant;
		    end if; */
		    --8275231
		    ghr_process_sf52.null_2ndNoa_cols(l_sf52_rec1);
		    l_ghr_pa_requests_rec := l_sf52_rec1;
                ELSIF ( l_dual_flg = TRUE and l_index = 2 ) then
                     -- In case of Dual Actin assign_new_rg is nulling out the PRD.
		  /*l_pay_rate_determinant := l_ghr_pa_requests_rec.pay_rate_determinant;
	 	  ghr_process_sf52.assign_new_rg( p_action_num  => 2,
				                  p_pa_req      => l_sf52_rec2);

                   l_ghr_pa_requests_rec := l_sf52_rec2;
		   if l_sf52_rec2.pay_rate_determinant is null then
		     l_ghr_pa_requests_rec.pay_rate_determinant := l_pay_rate_determinant;
		   end if; */
		   --8275231
		   ghr_process_sf52.copy_2ndNoa_to_1stNoa(l_sf52_rec2);
	           ghr_process_sf52.null_2ndNoa_cols(l_sf52_rec2);
 		   for noa_family_rec in c_noa_family(l_sf52_rec2.first_noa_id,l_sf52_rec2.effective_date) loop --Bug# 8275231
                      l_sf52_rec2.noa_family_code :=  noa_family_rec.noa_family_code;
                   end loop;
		   --8275231
		    l_ghr_pa_requests_rec := l_sf52_rec2;
                   l_dual_flg := FALSE;
                ELSIF (l_single_flg = TRUE and l_dual_flg <> TRUE ) THEN
                    l_ghr_pa_requests_rec := cur_get_pars_rec;
                END IF;

		--- 8490723/8490327 formating the noac before doing any comparison
		--- 9184710 Modified the parameter of passing as second NOAC should be NULl for DUal Actions
		l_ghr_pa_requests_rec.first_noa_code  := format_noac(l_ghr_pa_requests_rec.first_noa_code);
      	        l_ghr_pa_requests_rec.second_noa_code := format_noac(l_ghr_pa_requests_rec.second_noa_code);

                -- Bug# 4648811getting the suffix from the Employee lastname and also removing suffix from lastname
                get_suffix_lname(l_ghr_pa_requests_rec.employee_last_name,
                                 l_ghr_pa_requests_rec.effective_date,
                                 l_suffix,
                                 l_last_name);
               --End Bug# 4648811

                l_ghr_pa_requests_rec.employee_last_name := l_last_name;

					 hr_utility.set_location(l_proc||' Check non_us_citizen_and_foreign_ds' ,30);
                --
                -- 2.1) Do not include PAR's for a non US Citizen in a foreign country
                IF non_us_citizen_and_foreign_ds (p_citizenship       => l_ghr_pa_requests_rec.citizenship
                                               ,p_duty_station_code => l_ghr_pa_requests_rec.duty_station_code) THEN
                    GOTO end_par_loop;  -- loop for the next one!
                END IF;
                --
                hr_utility.set_location(l_proc||' Customer exclusion hook' ,40);
                --
                -- Bug 714944 -- Added exclusion of NAF:
                IF exclude_position (p_position_id       => NVL(l_ghr_pa_requests_rec.to_position_id
                                                             ,l_ghr_pa_requests_rec.from_position_id)
                                  ,p_effective_date    => l_ghr_pa_requests_rec.effective_date) THEN
                    GOTO end_par_loop;  -- loop for the next one!
                END IF;

                -- Obtain Retained Grade information

                BEGIN
                    l_retained_pay_plan         := NULL;
                    l_retained_grade_or_level   := NULL;
                    l_retained_step_or_rate     := NULL;
                    l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details (
                                                             p_person_id        => l_ghr_pa_requests_rec.person_id,
                                                             p_effective_date   => l_ghr_pa_requests_rec.effective_date
                                                                                   );

                    l_retained_pay_plan         := l_retained_grade_rec.pay_plan;
                    l_retained_grade_or_level   := l_retained_grade_rec.grade_or_level;
                    l_retained_step_or_rate     := l_retained_grade_rec.step_or_rate;
                EXCEPTION
                    WHEN ghr_pay_calc.pay_calc_message THEN
                    NULL;
                END;

                -- Emptying GHR_CPDF_TEMP_REC... Added for bug# 1375342
                l_ghr_cpdf_temp_rec := l_ghr_empty_cpdf_temp;


                --
                -- 2.2) Add a cutomer hook to determine whether or not to include in report or not!!!!
                --      This maybe particuarly useful for excluding Non appropriated fund personnel (NAF) as currently
                --      we do not hold this infoamtion about a person or position, but apparently DoD hold it
                --      in the position kff
                --
                --
                -- 3) Now we have decided to keep this populate the ghr_cpdf_temp record group:
                --    First with all the information the PAR table itself and then go and get any more information needed
                --    If we are just doing a count, we do not need to do the second bit!
                --
                -- 3.1) Get all info from PAR table itself
                --
                hr_utility.set_location(l_proc||' populate cpdf temp from par' ,50);
                --
                l_ghr_cpdf_temp_rec.agency_code            := NVL(l_ghr_pa_requests_rec.agency_code,l_ghr_pa_requests_rec.from_agency_code);
                l_ghr_cpdf_temp_rec.to_national_identifier := format_ni(l_ghr_pa_requests_rec.employee_national_identifier);

                IF (l_ghr_pa_requests_rec.first_noa_code = '001' AND
                    NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') <> '350') OR
                   (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                    NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') <> '355') OR
                   (l_ghr_pa_requests_rec.first_noa_code NOT IN ('001', '002', '350', '355')) THEN
                    IF l_ghr_pa_requests_rec.first_noa_code = '002' THEN
                        l_ghr_cpdf_temp_rec.first_action_la_code1 := l_ghr_pa_requests_rec.second_action_la_code1;
                        l_ghr_cpdf_temp_rec.first_action_la_code2 := l_ghr_pa_requests_rec.second_action_la_code2;
                    ELSE
                        l_ghr_cpdf_temp_rec.first_action_la_code1 := l_ghr_pa_requests_rec.first_action_la_code1;
                        l_ghr_cpdf_temp_rec.first_action_la_code2 := l_ghr_pa_requests_rec.first_action_la_code2;
                    END IF;
                END IF;

                l_ghr_cpdf_temp_rec.effective_date         := l_ghr_pa_requests_rec.effective_date;     -- format in report
                l_ghr_cpdf_temp_rec.first_noa_code         := format_noac(l_ghr_pa_requests_rec.first_noa_code);
                l_ghr_cpdf_temp_rec.second_noa_code        := format_noac(l_ghr_pa_requests_rec.second_noa_code);-- Moved here for bug# 1399854

                -- IF Cancellation THEN no more data elements are needed. Bug# 1375323
                -- Insert_row in GHR_CPDF_TEMP, and continue in the LOOP for the next PAR row.
                IF l_ghr_pa_requests_rec.first_noa_code = '001' THEN
                    insert_row(l_ghr_cpdf_temp_rec);
     		    l_records_found:=TRUE;
                    GOTO end_par_loop;  -- loop for the next one!
                END IF;

                -- Obtain Family Code
                l_noa_family_code := l_ghr_pa_requests_rec.noa_family_code;
                IF l_noa_family_code = 'CORRECT' THEN
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                    /*GHR_PROCESS_SF52.get_family_code(l_ghr_pa_requests_rec.second_noa_id,
                                                     l_noa_family_code);*/

                    --Bug # 7507154 added this call to get the family code based on Effective date
                    l_noa_family_code := ghr_pa_requests_pkg.get_noa_pm_family
                                         (l_ghr_pa_requests_rec.second_noa_id,
                                          l_ghr_pa_requests_rec.effective_date);
                    EXCEPTION
                        WHEN OTHERS THEN
                        l_message_name := 'get_family_code';
                        l_log_text     := 'Error in getting family code for pa_request_id: '||
                                          l_ghr_pa_requests_rec.pa_request_id ||
                                          ' ;  SSN/employee last name' ||
                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                          ' ; first NOAC/Second NOAC: '||
                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                          l_ghr_pa_requests_rec.second_noa_code ||
                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                        Raise CPDF_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                END IF;

                -- Moved POI to this place for bug# 1402287 to not print for Cancellations.
                l_ghr_cpdf_temp_rec.personnel_office_id    := l_ghr_pa_requests_rec.personnel_office_id;
                l_ghr_cpdf_temp_rec.employee_date_of_birth := l_ghr_pa_requests_rec.employee_date_of_birth;  -- format in report
                l_ghr_cpdf_temp_rec.veterans_preference    := l_ghr_pa_requests_rec.veterans_preference;
                l_ghr_cpdf_temp_rec.veterans_preference    := l_ghr_pa_requests_rec.veterans_preference;
                l_ghr_cpdf_temp_rec.tenure                 := l_ghr_pa_requests_rec.tenure;
                l_ghr_cpdf_temp_rec.service_comp_date      := l_ghr_pa_requests_rec.service_comp_date;       -- format in report
                l_ghr_cpdf_temp_rec.retirement_plan        := l_ghr_pa_requests_rec.retirement_plan;
                l_ghr_cpdf_temp_rec.veterans_status        := l_ghr_pa_requests_rec.veterans_status;

               -- IF l_noa_family_code = 'AWARD' THEN bug#5328177
                IF l_noa_family_code IN ('AWARD','GHR_INCENTIVE') THEN
                    l_ghr_pa_requests_rec.to_pay_plan          := l_ghr_pa_requests_rec.from_pay_plan;
                    l_ghr_pa_requests_rec.to_occ_code          := l_ghr_pa_requests_rec.from_occ_code;
                    l_ghr_pa_requests_rec.to_grade_or_level    := l_ghr_pa_requests_rec.from_grade_or_level;
                    l_ghr_pa_requests_rec.to_step_or_rate      := l_ghr_pa_requests_rec.from_step_or_rate;
                    l_ghr_pa_requests_rec.to_basic_pay         := l_ghr_pa_requests_rec.from_basic_pay;
                    l_ghr_pa_requests_rec.to_pay_basis         := l_ghr_pa_requests_rec.from_pay_basis;
                    l_ghr_pa_requests_rec.to_locality_adj      := l_ghr_pa_requests_rec.from_locality_adj;
                END IF;

                l_ghr_cpdf_temp_rec.to_pay_plan            := l_ghr_pa_requests_rec.to_pay_plan;
                l_ghr_cpdf_temp_rec.to_occ_code            := l_ghr_pa_requests_rec.to_occ_code;
                l_ghr_cpdf_temp_rec.to_grade_or_level      := l_ghr_pa_requests_rec.to_grade_or_level;
                l_ghr_cpdf_temp_rec.to_step_or_rate        := l_ghr_pa_requests_rec.to_step_or_rate;
                l_ghr_cpdf_temp_rec.to_basic_pay           := l_ghr_pa_requests_rec.to_basic_pay;            -- format in report
                l_ghr_cpdf_temp_rec.to_pay_basis           := l_ghr_pa_requests_rec.to_pay_basis;

				IF l_noa_family_code <> 'AWARD' THEN
                    -- Added following 'IF' according to bug# 1375333
                    IF NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '3%' OR
                            l_ghr_pa_requests_rec.first_noa_code LIKE '4%' OR
                           (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                            (NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '3%' OR
                             NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '4%')
                            )
                           )  THEN
                        l_ghr_cpdf_temp_rec.to_pay_rate_determinant:= l_ghr_pa_requests_rec.pay_rate_determinant;
                    ELSE
                        l_ghr_cpdf_temp_rec.to_pay_rate_determinant := NULL;
                    END IF;
                END IF;

                -- Added following 'IF' according to bug# 1375333
                IF NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '3%' OR
                        l_ghr_pa_requests_rec.first_noa_code LIKE '4%' OR
                        (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                         (NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '3%' OR
                          NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '4%')
                          )
                         ) THEN
                    l_ghr_cpdf_temp_rec.to_work_schedule       := l_ghr_pa_requests_rec.work_schedule;
                    --- commented for bug# 2257630 as duty station code required for all NOA codes except for cancellation action
                    --        l_ghr_cpdf_temp_rec.to_duty_station_code   := format_ds(l_ghr_pa_requests_rec.duty_station_code);
                ELSE
                    l_ghr_cpdf_temp_rec.to_work_schedule := NULL;
                END IF;
                l_ghr_cpdf_temp_rec.to_duty_station_code := format_ds(l_ghr_pa_requests_rec.duty_station_code);
                l_ghr_cpdf_temp_rec.position_occupied      := l_ghr_pa_requests_rec.position_occupied;
                l_ghr_cpdf_temp_rec.supervisory_status     := l_ghr_pa_requests_rec.supervisory_status;
                l_ghr_cpdf_temp_rec.award_amount           := l_ghr_pa_requests_rec.award_amount;            -- format in report
                -- Do the formating here and put the 'whole' name to be reported in just last name column!
                l_ghr_cpdf_temp_rec.employee_last_name     := format_name(l_ghr_pa_requests_rec.employee_first_name
                                                                         ,l_ghr_pa_requests_rec.employee_last_name
                                                                         ,l_ghr_pa_requests_rec.employee_middle_names);

                -- Added IF for bug# 1375342
                IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                   (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '2%' AND
                    (l_ghr_pa_requests_rec.first_noa_code <> '002' OR
                     NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '2%'
                    )
                   ) THEN
                    l_ghr_cpdf_temp_rec.from_pay_plan          := l_ghr_pa_requests_rec.from_pay_plan;
                    l_ghr_cpdf_temp_rec.from_occ_code          := l_ghr_pa_requests_rec.from_occ_code;
                    l_ghr_cpdf_temp_rec.from_grade_or_level    := l_ghr_pa_requests_rec.from_grade_or_level;
                    l_ghr_cpdf_temp_rec.from_step_or_rate      := l_ghr_pa_requests_rec.from_step_or_rate;
                    l_ghr_cpdf_temp_rec.from_basic_pay         := l_ghr_pa_requests_rec.from_basic_pay;                 -- format in report
                    l_ghr_cpdf_temp_rec.from_pay_basis         := l_ghr_pa_requests_rec.from_pay_basis;
                END IF;

		IF get_loc_pay_area_code(p_duty_station_id => l_ghr_pa_requests_rec.duty_station_id,
                                         p_effective_date => l_ghr_pa_requests_rec.effective_date) <> '99'  THEN

		   --7507154   ADDED incentive family
		   IF l_noa_family_code <> 'GHR_INCENTIVE' then
                    IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                       l_ghr_pa_requests_rec.first_noa_code NOT LIKE '1%' AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '2%' AND
                         (NVL(l_ghr_pa_requests_rec.first_noa_code,'@#') <> '002' OR
                          NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') NOT LIKE '2%'
                         )
                        ) THEN

                        IF get_equivalent_pay_plan(NVL(l_retained_pay_plan, l_ghr_pa_requests_rec.from_pay_plan)) <> 'FW' THEN
                            l_ghr_cpdf_temp_rec.from_locality_adj := NVL(l_ghr_pa_requests_rec.from_locality_adj, 0);
                        ELSE
                            l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
                        END IF;
                    ELSE
                        l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
                    END IF;
		  END IF;

		  IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '3%' AND
                        (l_ghr_pa_requests_rec.first_noa_code <> '002' OR
                         NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '3%'
                        )
                       ) AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '4%' AND
                        (l_ghr_pa_requests_rec.first_noa_code = '002' OR
                          NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '4%'
                        )
                       ) THEN
                            IF get_equivalent_pay_plan(NVL(l_retained_pay_plan, l_ghr_pa_requests_rec.to_pay_plan)) <> 'FW' THEN
                                l_ghr_cpdf_temp_rec.to_locality_adj        := NVL(l_ghr_pa_requests_rec.to_locality_adj, 0);
                            ELSE
                                l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
                            END IF;
                    ELSE
                        l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
                    END IF;
	        ELSE --4163587 Loc pay is not reported for prior loc pay
		    -- NO NEED TO MAKE PRIOR LOC PAY ADJ NULL, as we are checking for current DS not prior DS
                    l_ghr_cpdf_temp_rec.to_locality_adj        := NULL;
                END IF;

                l_ghr_cpdf_temp_rec.to_staffing_differential   := l_ghr_pa_requests_rec.to_staffing_differential;   -- format in report
                l_ghr_cpdf_temp_rec.to_supervisory_differential:= l_ghr_pa_requests_rec.to_supervisory_differential;-- format in report
                l_ghr_cpdf_temp_rec.to_retention_allowance := l_ghr_pa_requests_rec.to_retention_allowance;         -- format in report

                IF l_noa_family_code IN ('AWARD', 'OTHER_PAY','GHR_INCENTIVE') THEN -- Bug# 1400486 --GHR_INCENTIVE added for bug #5328177
                    IF l_ghr_pa_requests_rec.first_noa_code IN ('818', '819') OR
                       (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                        l_ghr_pa_requests_rec.second_noa_code IN ('818', '819')) THEN
                        IF l_ghr_cpdf_temp_rec.award_amount IS NULL THEN
                            -- Bug# 1494916. By ENUNEZ. From 10.7 Dec2000 Patch release
                            IF l_ghr_pa_requests_rec.first_noa_code = '818' OR
                            (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                            l_ghr_pa_requests_rec.second_noa_code = '818')  THEN
                                -- Bug#2789704 Added Exception Handling

				BEGIN
                                    ghr_api.retrieve_element_entry_value (p_element_name    => 'AUO'
                                                       ,p_input_value_name      => 'Amount'
                                                       ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
                                                       ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
                                                       ,p_value                 => l_ghr_cpdf_temp_rec.award_amount
                                                       ,p_multiple_error_flag   => l_multi_error_flag);

                                   -- Added the if condition for Bug#5564750
                                   IF l_ghr_cpdf_temp_rec.award_amount IS NULL THEN
                                       l_ghr_cpdf_temp_rec.award_amount := 0;
                                   END IF;

                                EXCEPTION
                                    WHEN OTHERS THEN
                                        l_message_name := 'retrieve_element_entry_value';
                                        l_log_text     := 'Error in fetching AUO Amount for pa_request_id: '||
                                                          l_ghr_pa_requests_rec.pa_request_id ||
                                                          ' ;  SSN/employee last name' ||
                                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                                          ' ; first NOAC/Second NOAC: '||
                                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                                          l_ghr_pa_requests_rec.second_noa_code ||
                                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                                        Raise CPDF_DYNRPT_ERROR;
                                END;

                                -- Bug#2789704 Added Exception Handling
                            ELSE
                                -- Bug#2789704 Added Exception Handling
                                BEGIN
                                    ghr_api.retrieve_element_entry_value (p_element_name    => 'Availability Pay'
                                                       ,p_input_value_name      => 'Amount'
                                                       ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
                                                       ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
                                                       ,p_value                 => l_ghr_cpdf_temp_rec.award_amount
                                                       ,p_multiple_error_flag   => l_multi_error_flag);

                                    -- Added the if condition for Bug#5564750
                                    IF l_ghr_cpdf_temp_rec.award_amount IS NULL THEN
                                        l_ghr_cpdf_temp_rec.award_amount := 0;
                                    END IF;

                                EXCEPTION
                                    WHEN OTHERS THEN
                                        l_message_name := 'retrieve_element_entry_value';
                                        l_log_text     := 'Error in fetching Availability Pay Amount for pa_request_id: '||
                                                          l_ghr_pa_requests_rec.pa_request_id ||
                                                          ' ;  SSN/employee last name' ||
                                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                                          ' ; first NOAC/Second NOAC: '||
                                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                                          l_ghr_pa_requests_rec.second_noa_code ||
                                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                                        Raise CPDF_DYNRPT_ERROR;
                                END;
                                -- Bug#2789704 Added Exception Handling
                            END IF;
                        END IF;
                    ELSE
                        IF l_ghr_cpdf_temp_rec.to_supervisory_differential IS NULL THEN
                            -- Bug#2789704 Added Exception Handling
                            BEGIN
                                ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                                                     ,p_input_value_name      => 'Amount'
                                                     ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
                                                     ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
                                                     ,p_value                 => l_ghr_cpdf_temp_rec.to_supervisory_differential
                                                     ,p_multiple_error_flag   => l_multi_error_flag);
                            EXCEPTION
                                    WHEN OTHERS THEN
                                        l_message_name := 'retrieve_element_entry_value';
                                        l_log_text     := 'Error in fetching Supervisory Differential Amount for pa_request_id: '||
                                                          l_ghr_pa_requests_rec.pa_request_id ||
                                                          ' ;  SSN/employee last name' ||
                                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                                          ' ; first NOAC/Second NOAC: '||
                                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                                          l_ghr_pa_requests_rec.second_noa_code ||
                                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                                        Raise CPDF_DYNRPT_ERROR;
                            END;
                            -- Bug#2789704 Added Exception Handling

                        END IF;
                        IF l_ghr_cpdf_temp_rec.to_retention_allowance IS NULL THEN
                            -- Bug#2789704 Added Exception Handling
                            BEGIN
                                ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
                                                     ,p_input_value_name      => 'Amount'
                                                     ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
                                                     ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
                                                     ,p_value                 => l_ghr_cpdf_temp_rec.to_retention_allowance
                                                     ,p_multiple_error_flag   => l_multi_error_flag);
                            EXCEPTION
                                    WHEN OTHERS THEN
                                        l_message_name := 'retrieve_element_entry_value';
                                        l_log_text     := 'Error in fetching Retention Allowance Amount for pa_request_id: '||
                                                          l_ghr_pa_requests_rec.pa_request_id ||
                                                          ' ;  SSN/employee last name' ||
                                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                                          ' ; first NOAC/Second NOAC: '||
                                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                                          l_ghr_pa_requests_rec.second_noa_code ||
                                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                                        Raise CPDF_DYNRPT_ERROR;
                            END;
                            -- Bug#2789704 Added Exception Handling
                        END IF;
                    END IF;
                END IF;

				-- Changes for education
				-- Fix for 3958881 Madhuri
				ghr_api.return_education_details(p_person_id  => l_ghr_pa_requests_rec.person_id,
                                     p_effective_date       => l_ghr_pa_requests_rec.effective_date,
                                     p_education_level      => l_ghr_cpdf_temp_rec.education_level,
                                     p_academic_discipline  => l_ghr_cpdf_temp_rec.academic_discipline,
                                     p_year_degree_attained => l_ghr_cpdf_temp_rec.year_degree_attained);
				-- End changes for education Commented below code

		/* l_ghr_cpdf_temp_rec.education_level        := l_ghr_pa_requests_rec.education_level;
                -- academic_discipline is refered to as 'Instructional Program' in the dynamics report
                l_ghr_cpdf_temp_rec.academic_discipline    := l_ghr_pa_requests_rec.academic_discipline;
                l_ghr_cpdf_temp_rec.year_degree_attained   := l_ghr_pa_requests_rec.year_degree_attained;
                -- */

                -- Not worth getting any more detials if only counting!
                IF not p_count_only THEN
                    --
                    -- 3.2) Get Orgnaizational Component (Otherwise refered to as Org Structure ID)
                    --      Since this appears to be required for all NOA's reported in the dynamic report
                    --      it must come from to_position if there, if not from the from_position
                    --
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                        get_org_comp (NVL(l_ghr_pa_requests_rec.to_position_id
                                         ,l_ghr_pa_requests_rec.from_position_id)
                                         ,l_ghr_pa_requests_rec.effective_date
                                         ,l_ghr_cpdf_temp_rec.organizational_component);
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_org_comp';
                            l_log_text     := 'Error in fetching OPM Organizational Component for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise CPDF_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                    --
                    -- 3.3) Get Sex
                   -- Bug#2789704 Added Exception Handling
                    BEGIN
                        get_sex (l_ghr_pa_requests_rec.person_id
                                ,l_ghr_pa_requests_rec.effective_date
                                ,l_ghr_cpdf_temp_rec.sex);
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_sex';
                            l_log_text     := 'Error in fetching SEX for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise CPDF_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                    --
                    -- 3.4) Get person SIT - 'US Fed Perf Appraisal'
                    --
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                        get_per_sit_perf_appraisal(l_ghr_pa_requests_rec.person_id
                                                  ,l_ghr_pa_requests_rec.effective_date
                                                  ,l_ghr_cpdf_temp_rec.rating_of_record_level
                                                  ,l_ghr_cpdf_temp_rec.rating_of_record_pattern
                                                  ,l_ghr_cpdf_temp_rec.rating_of_record_period_ends);      -- format in report
                    EXCEPTION
                        WHEN OTHERS THEN
			                l_message_name := 'get_per_sit_perf_apprisal';
			                l_log_text     := 'Error in fetching Performance Apprisal details for pa_request_id: '||
                                              to_char(l_ghr_pa_requests_rec.pa_request_id) ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' /  '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ' ;  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
                             Raise CPDF_DYNRPT_ERROR;

                    END;
                    -- Bug#2789704 Added Exception Handling
                    --
                    -- 3.5) Get PAR Extra Info Noa specific
                    --
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                        get_PAR_EI_noac (l_ghr_pa_requests_rec.pa_request_id
                                        ,l_ghr_pa_requests_rec.first_noa_id
                                        ,l_ghr_pa_requests_rec.second_noa_id
                                        ,l_ghr_pa_requests_rec.noa_family_code
                                        ,l_ghr_pa_requests_rec.person_id
                                        ,l_ghr_pa_requests_rec.effective_date
                                        ,l_ghr_cpdf_temp_rec.creditable_military_service           -- no format assumed yymm?
                                        ,l_ghr_cpdf_temp_rec.frozen_service                        -- no format assumed yymm?
                                        ,l_ghr_cpdf_temp_rec.from_retirement_coverage              -- previous retirement coverage
                                        ,l_ghr_cpdf_temp_rec.race_national_origin
                                        ,l_ghr_cpdf_temp_rec.handicap_code
                                        ,l_ghr_cpdf_temp_rec.individual_group_award                -- format in report
                                        ,l_ghr_cpdf_temp_rec.benefit_amount							-- format in report
                                        ,l_ghr_cpdf_temp_rec.race_ethnic_info);            -- -- Bug 4724337 Race or National Origin changes
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_par_ei_noac';
                            l_log_text     := 'Error in fetching PA Record Extra Information for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise CPDF_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling

                    -- Bug# 1375342
                    IF (l_ghr_pa_requests_rec.first_noa_code LIKE '2%' OR
                        (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                       NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '2%')) THEN
                        l_ghr_cpdf_temp_rec.creditable_military_service := NULL;
 		        l_ghr_cpdf_temp_rec.from_retirement_coverage := NULL;
			-- for bug 3327389
                    END IF;

                    -- get current appointment auth codes.
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                        ghr_sf52_pre_update.get_auth_codes
                                (p_pa_req_rec		=>	l_ghr_pa_requests_rec
                                 ,p_auth_code1		=>	l_ghr_cpdf_temp_rec.current_appointment_auth1
                                 ,p_auth_code2		=>	l_ghr_cpdf_temp_rec.current_appointment_auth2);
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_auth_codes';
                            l_log_text     := 'Error in fetching Current Appointment Authority Codes for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise CPDF_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                    --
                    -- 3.6) Get PRIOR Work Schedule and Pay Rate Determinant
                    --
                    IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                    (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '2%' AND
                    (l_ghr_pa_requests_rec.first_noa_code <> '002' OR
                     NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '2%'))
                    THEN
                        -- Bug#2789704 Added Exception Handling
                        BEGIN
                            get_prior_ws_prd_ds (l_ghr_pa_requests_rec.pa_request_id
                                            ,l_ghr_pa_requests_rec.altered_pa_request_id
                                            ,l_ghr_pa_requests_rec.first_noa_id
                                            ,l_ghr_pa_requests_rec.second_noa_id
                                            ,l_ghr_pa_requests_rec.person_id
                                            ,l_ghr_pa_requests_rec.employee_assignment_id
                                            ,l_ghr_pa_requests_rec.from_position_id
                                            ,l_ghr_pa_requests_rec.effective_date
                                            ,l_ghr_pa_requests_rec.status
                                            ,l_ghr_cpdf_temp_rec.from_work_schedule
                                            ,l_ghr_cpdf_temp_rec.from_pay_rate_determinant
                                            ,l_ghr_cpdf_temp_rec.from_duty_station_code);
                        EXCEPTION
                            WHEN OTHERS THEN
                                l_message_name := 'get_prior_ws_prd_ds';
                                l_log_text     := 'Error in fetching prior work schedule,prg,duty station for pa_request_id: '||
                                                  l_ghr_pa_requests_rec.pa_request_id ||
                                                  ' ;  SSN/employee last name' ||
                                                  l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                                  l_ghr_pa_Requests_rec.employee_last_name ||
                                                  ' ; first NOAC/Second NOAC: '||
                                                  l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                                  l_ghr_pa_requests_rec.second_noa_code ||
                                                  ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                                Raise CPDF_DYNRPT_ERROR;
                        END;

                        --bug# 5328177 IF l_noa_family_code = 'AWARD' THEN
                        IF l_noa_family_code IN ('AWARD','GHR_INCENTIVE') THEN

                            l_ghr_cpdf_temp_rec.to_pay_rate_determinant   := l_ghr_cpdf_temp_rec.from_pay_rate_determinant;
                        END IF;
                        -- Added IF Condition to fix bug#3231946
                        IF get_loc_pay_area_code(p_duty_station_code => l_ghr_cpdf_temp_rec.from_duty_station_code,
                                               p_effective_date    => l_ghr_pa_requests_rec.effective_date) = '99'
                           AND l_ghr_pa_requests_rec.from_locality_adj = 0 THEN
                            l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
                        END IF;

                    END IF;
                    --
                    -- 3.7) Get prior ssn if it is being corrected.
                    --
                    -- Bug#2789704 Added Exception Handling
                    BEGIN
                        get_prev_ssn (l_ghr_pa_requests_rec.altered_pa_request_id
                                 ,l_ghr_pa_requests_rec.employee_national_identifier
                                 ,l_ghr_pa_requests_rec.noa_family_code
                                 ,l_ghr_cpdf_temp_rec.from_national_identifier);
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_prev_ssn';
                            l_log_text     := 'Error in fetching SSN for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise CPDF_DYNRPT_ERROR;
                    END;

                END IF; -- end of popluation of full record if not count_only
                --
                -- adding code for 817 NOAC
                IF (l_ghr_pa_requests_rec.first_noa_code='817' or l_ghr_pa_requests_rec.second_noa_code='817') THEN
                    l_ghr_cpdf_temp_rec                  := l_ghr_empty_cpdf_temp;
                    l_ghr_cpdf_temp_rec.agency_code      := NVL(l_ghr_pa_requests_rec.agency_code,l_ghr_pa_requests_rec.from_agency_code);
                    l_ghr_cpdf_temp_rec.to_national_identifier
                                                     := format_ni(l_ghr_pa_requests_rec.employee_national_identifier);
                    l_ghr_cpdf_temp_rec.effective_date   := l_ghr_pa_requests_rec.effective_date;
                    l_ghr_cpdf_temp_rec.first_noa_code   := l_ghr_pa_requests_rec.first_noa_code;
                    l_ghr_cpdf_temp_rec.second_noa_code  := l_ghr_pa_requests_rec.second_noa_code;
                    l_ghr_cpdf_temp_rec.to_occ_code      := l_ghr_pa_requests_rec.from_occ_code;
                    l_ghr_cpdf_temp_rec.award_amount     := l_ghr_pa_requests_rec.award_amount;
                    --        GOTO end_par_loop;
                END IF;

---
-- EHRI changes
--
		IF ((l_ghr_pa_requests_rec.first_noa_code ='002'
		    AND
		    (NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '1%' or NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '2%' or
		     NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '3%' or NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '4%' or
		     NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '5%' OR NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '6%' or
		     NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '7%' OR NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') like '8%' )
		     )  -- for 002
                       OR
		       (l_ghr_pa_requests_rec.first_noa_code like '1%' or l_ghr_pa_requests_rec.first_noa_code like '2%' or
			l_ghr_pa_requests_rec.first_noa_code like '3%' or l_ghr_pa_requests_rec.first_noa_code like '4%' or
			l_ghr_pa_requests_rec.first_noa_code like '5%' OR l_ghr_pa_requests_rec.first_noa_code like '6%' or
			l_ghr_pa_requests_rec.first_noa_code like '7%' OR l_ghr_pa_requests_rec.first_noa_code like '8%'
		       )
		    )
		THEN

		    IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '3%' AND
                        (l_ghr_pa_requests_rec.first_noa_code <> '002' OR
                         NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '3%'
                        )
                       ) AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '4%' AND
                        (l_ghr_pa_requests_rec.first_noa_code = '002' OR
                          NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') NOT LIKE '4%'
                        )
                       ) THEN
 		       l_ghr_cpdf_temp_rec.position_title     := l_ghr_pa_requests_rec.to_position_title;
		    ELSE
		       l_ghr_cpdf_temp_rec.position_title     := NULL;
		    END IF;

		    -- Bug#5328177 Added NOAC 827 in the NOAC list.
		    -- Bug # 8510442 Added 885 into the list to display award amount for 885 action
		    IF ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		          NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') in ('815','816','817','818','819','825','827',
				'840','841','842','843','844','845','846','847','848','849','878','879','885')
			  )
			OR
			l_ghr_pa_requests_rec.first_noa_code in ('815','816','817','818','819','825','827',
				'840','841','842','843','844','845','846','847','848','849','878','879','885')
			)
                    THEN

               -- Bug#3941541,5168358 Separation Incentive Changes.
               -- If the Award Dollars value is NOT NULL, Assume that 825 is processed as Award.
               -- Otherwise, it is processed as Incentive.
               IF ( l_ghr_pa_requests_rec.first_noa_code IN  ('825','815','816') OR
                   l_ghr_pa_requests_rec.second_noa_code IN  ('825','815','816')) AND
                   l_ghr_pa_requests_rec.award_amount IS NULL THEN
                   l_ghr_pa_requests_rec.award_amount := l_ghr_pa_requests_rec.to_total_salary;
                   l_ghr_cpdf_temp_rec.award_amount := l_ghr_pa_requests_rec.to_total_salary;
               END IF;
               -- End of Bug#3941541,5168358

		       IF NVL(l_ghr_pa_requests_rec.award_uom,'M')='M' THEN
			       l_ghr_cpdf_temp_rec.award_dollars := l_ghr_pa_requests_rec.award_amount;
		       END IF;
		       IF NVL(l_ghr_pa_requests_rec.award_uom,'M')='H' THEN
   			       l_ghr_cpdf_temp_rec.award_hours := l_ghr_pa_requests_rec.award_amount;
		       END IF;
		       IF l_ghr_pa_requests_rec.award_percentage IS NOT NULL THEN
			       l_ghr_cpdf_temp_rec.award_percentage := l_ghr_pa_requests_rec.award_percentage;
		       END IF;
               -- Bug#5328177 Added the following IF Condition
               IF  l_ghr_pa_requests_rec.first_noa_code = '827'  OR
                   l_ghr_pa_requests_rec.second_noa_code = '827' THEN
                    l_ghr_cpdf_temp_rec.award_percentage := l_ghr_pa_requests_rec.to_total_salary;
               END IF;


		    END IF;

		    IF ( (l_ghr_pa_requests_rec.first_noa_code='002' AND l_ghr_pa_requests_rec.second_noa_code='817')
		         OR
 		          l_ghr_pa_requests_rec.first_noa_code NOT IN ('817')) THEN
			l_ghr_cpdf_temp_rec.employee_last_name    := format_name_ehri(l_ghr_pa_requests_rec.employee_last_name);
    			l_ghr_cpdf_temp_rec.employee_first_name   := format_name_ehri(l_ghr_pa_requests_rec.employee_first_name);
    			l_ghr_cpdf_temp_rec.employee_middle_names := format_name_ehri(l_ghr_pa_requests_rec.employee_middle_names);
			-- Added format_name_ehri for EHRI changes.
			 FOR per_det IN cur_per_details(l_ghr_pa_requests_rec.person_id)
			 LOOP
               -- Bug# 4648811getting the suffix from the Employee lastname
               get_suffix_lname(per_det.last_name,
                                l_ghr_pa_requests_rec.effective_date,
                                l_suffix,
                                l_last_name);
              --End Bug# 4648811
			   l_ghr_cpdf_temp_rec.name_title	  := l_suffix;
 			 END LOOP;

			 FOR scd_dates IN cur_scd_dates(l_ghr_pa_requests_rec.pa_request_id)
			 LOOP
		            l_ghr_cpdf_temp_rec.SCD_rif := fnd_date.canonical_to_date(scd_dates.rif);
			    l_ghr_cpdf_temp_rec.SCD_retirement := fnd_date.canonical_to_date(scd_dates.ret);
			-- Added date conversion for bug#3808473-EHRI reports
			 END LOOP;

			 IF (l_ghr_cpdf_temp_rec.SCD_rif IS NULL
			    and l_ghr_cpdf_temp_rec.SCD_retirement IS NULL) THEN

	 		 BEGIN
				   ghr_history_fetch.fetch_peopleei
				  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
				    p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
				    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
			            p_per_ei_data        =>  ll_per_ei_data
				  );

				l_ghr_cpdf_temp_rec.SCD_rif:= fnd_date.canonical_to_date(ll_per_ei_data.pei_information5);
				l_ghr_cpdf_temp_rec.SCD_retirement:= fnd_date.canonical_to_date(ll_per_ei_data.pei_information7);

			 EXCEPTION
                         WHEN OTHERS THEN
                            l_message_name := 'fetch_peopleei';
                            l_log_text     := 'Error in fetching SCD Information for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                         Raise CPDF_DYNRPT_ERROR;
			 END;
			 END IF;

		       ELSE -- if NOAC is 817
			l_ghr_cpdf_temp_rec.employee_last_name    := NULL;
    			l_ghr_cpdf_temp_rec.employee_first_name   := NULL;
    			l_ghr_cpdf_temp_rec.employee_middle_names := NULL;
			l_ghr_cpdf_temp_rec.name_title		  := NULL;
			l_ghr_cpdf_temp_rec.SCD_rif		  := NULL;
 		        l_ghr_cpdf_temp_rec.SCD_retirement	  := NULL;
 		       END IF; -- not in 817
		END IF;
-- EHRI changes END
--

					--Pradeep start of Bug 3953500
					  /* In case of 825 instead of taking TO side values From side values are taken as
					   to side values are not populated.
					  in future in case to side values are populated  consider only the toside values.
					  */
					 IF l_ghr_pa_requests_rec.first_noa_code = '825'
					   OR ( l_ghr_pa_requests_rec.first_noa_code = '002' and
							  l_ghr_pa_requests_rec.first_noa_code = '825' ) THEN
						 l_ghr_cpdf_temp_rec.to_pay_plan            := l_ghr_pa_requests_rec.from_pay_plan;
						 l_ghr_cpdf_temp_rec.to_occ_code            := l_ghr_pa_requests_rec.from_occ_code;
						 l_ghr_cpdf_temp_rec.to_grade_or_level      := l_ghr_pa_requests_rec.from_grade_or_level;
						 l_ghr_cpdf_temp_rec.to_step_or_rate        := l_ghr_pa_requests_rec.from_step_or_rate;
						 l_ghr_cpdf_temp_rec.to_basic_pay           := l_ghr_pa_requests_rec.from_basic_pay;            -- format in report
						 l_ghr_cpdf_temp_rec.to_pay_basis           := l_ghr_pa_requests_rec.from_pay_basis;

						 l_ghr_cpdf_temp_rec.to_pay_rate_determinant:= l_ghr_pa_requests_rec.pay_rate_determinant;
						 l_ghr_cpdf_temp_rec.position_title         := l_ghr_pa_requests_rec.from_position_title;
					 END IF;

					IF l_ghr_cpdf_temp_rec.to_supervisory_differential IS NULL THEN

						 BEGIN
							  ghr_api.retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
														  ,p_input_value_name      => 'Amount'
														  ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
														  ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
														  ,p_value                 => l_ghr_cpdf_temp_rec.to_supervisory_differential
														  ,p_multiple_error_flag   => l_multi_error_flag);
						 EXCEPTION
									WHEN OTHERS THEN
										 l_message_name := 'retrieve_element_entry_value';
										 l_log_text     := 'Error in fetching Supervisory Differential Amount for pa_request_id: '||
																 l_ghr_pa_requests_rec.pa_request_id ||
																 ' ;  SSN/employee last name' ||
																 l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
																 l_ghr_pa_Requests_rec.employee_last_name ||
																 ' ; first NOAC/Second NOAC: '||
																 l_ghr_pa_requests_rec.first_noa_code || ' / '||
																 l_ghr_pa_requests_rec.second_noa_code ||
																 ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

										 Raise CPDF_DYNRPT_ERROR;
						 END;

					END IF;
					IF l_ghr_cpdf_temp_rec.to_retention_allowance IS NULL THEN

						 BEGIN
							  ghr_api.retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
														  ,p_input_value_name      => 'Amount'
														  ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
														  ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
														  ,p_value                 => l_ghr_cpdf_temp_rec.to_retention_allowance
														  ,p_multiple_error_flag   => l_multi_error_flag);
						 EXCEPTION
									WHEN OTHERS THEN
										 l_message_name := 'retrieve_element_entry_value';
										 l_log_text     := 'Error in fetching Retention Allowance Amount for pa_request_id: '||
																 l_ghr_pa_requests_rec.pa_request_id ||
																 ' ;  SSN/employee last name' ||
																 l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
																 l_ghr_pa_Requests_rec.employee_last_name ||
																 ' ; first NOAC/Second NOAC: '||
																 l_ghr_pa_requests_rec.first_noa_code || ' / '||
																 l_ghr_pa_requests_rec.second_noa_code ||
																 ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

										 Raise CPDF_DYNRPT_ERROR;
						 END;

					END IF;
					 --Pradeep end of Bug 3953500

-- 3327389 Bug fix start
-- CPDF Reporting changes to include Creditable Military Service, Frozen Service and Prev Retirement Coverage
-- including the NOACS 800 and 782 inspite they are optional for reporting
-- as they will be anyways filtered under exclude_noacs
		BEGIN
/*		IF ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		       NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') in ('280','292','293'))
		     OR l_ghr_pa_requests_rec.first_noa_code in ('280','292','293')
		   ) THEN
			   ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			  );
		  l_ghr_cpdf_temp_rec.from_retirement_coverage := ll_per_ei_data.pei_information4;
		  -- Cerditable mil serv, frozen serv are already picked up from get_PAR_EI_noac procedure
  		  -- information5 for Frozen service
		  ll_per_ei_data:=NULL;

		END IF; */
		IF ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		      NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') in ('702','703','713','721','781','782','790','800',
			'850','855','867','868','891','892','893','895','899'))
		     OR l_ghr_pa_requests_rec.first_noa_code in ('702','703','713','721','781','782','790','800',
			'850','855','867','868','891','892','893','895','899')
		   ) THEN

		     ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_UNIFORMED_SERVICES',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			  );

		    l_ghr_cpdf_temp_rec.creditable_military_service:= SUBSTR(ll_per_ei_data.pei_information5,1,4);
	 	    ll_per_ei_data :=NULL;

		    ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			  );
		   l_ghr_cpdf_temp_rec.from_retirement_coverage := ll_per_ei_data.pei_information4;
 		   l_ghr_cpdf_temp_rec.Frozen_service:= SUBSTR(ll_per_ei_data.pei_information5,1,4);

		   ll_per_ei_data:=NULL;
		END IF;

		-- If Ethnicity is reported, RNO should be null
	      IF l_ghr_cpdf_temp_rec.race_ethnic_info IS NOT NULL THEN
	      	l_ghr_cpdf_temp_rec.race_national_origin := NULL;
	      END IF;


		 -- Bug 4542476
		  l_locality_pay_area_code := get_loc_pay_area_code(p_duty_station_id => l_ghr_pa_requests_rec.duty_station_id,
                                         p_effective_date => l_ghr_pa_requests_rec.effective_date);
		  l_equiv_plan := get_equivalent_pay_plan(NVL(l_retained_pay_plan, l_ghr_pa_requests_rec.to_pay_plan));

		-- Bug# 8939586 added the bug fix 5011003 which is fixed for EHRI Dynamics report
		  IF l_ghr_cpdf_temp_rec.to_pay_rate_determinant IN ('3', 'J', 'K', 'U', 'V', '6', 'E', 'F') THEN
		     l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
		  ELSE
			IF l_ghr_cpdf_temp_rec.to_locality_adj = 0 AND l_locality_pay_area_code = 'ZZ'
				AND l_equiv_plan = 'GS' THEN
					l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
			ELSIF l_ghr_cpdf_temp_rec.to_locality_adj = 0 AND l_equiv_plan = 'GS'
				AND NVL(l_locality_pay_area_code,'-1') <> 'ZZ'	THEN
					l_ghr_cpdf_temp_rec.to_locality_adj := 0;
			ELSIF l_ghr_cpdf_temp_rec.to_locality_adj = 0 AND NVL(l_equiv_plan,'-1') <> 'GS' THEN
					l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
			END IF;
	          END IF;

		-- For Prior locality pay
		-- Bug 8939586
		  IF l_ghr_cpdf_temp_rec.from_pay_rate_determinant IN ('3', 'J', 'K', 'U', 'V', '6', 'E', 'F') THEN
		     l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
		  ELSE
				IF l_ghr_cpdf_temp_rec.from_locality_adj = 0 AND l_locality_pay_area_code = 'ZZ'
					AND l_equiv_plan = 'GS' THEN
						l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
				ELSIF l_ghr_cpdf_temp_rec.from_locality_adj = 0 AND l_equiv_plan = 'GS'
					AND NVL(l_locality_pay_area_code,'-1') <> 'ZZ'	THEN
						l_ghr_cpdf_temp_rec.from_locality_adj := 0;
				ELSIF l_ghr_cpdf_temp_rec.from_locality_adj = 0 AND NVL(l_equiv_plan,'-1') <> 'GS' THEN
						l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
				END IF;
		  -- End Bug 4542476
		  END IF;




		EXCEPTION
		WHEN OTHERS THEN
			   l_message_name := 'fetch_peopleei';
                            l_log_text     := 'Error in fetching SCD Information for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
		END;
-- End of changes for CPDF reports picking creditable mil serv, frozen serv and prev retirement coverage
-- 3327389 Bug fix end
                insert_row(l_ghr_cpdf_temp_rec);
		l_records_found:=TRUE;
                --
		<<end_par_loop>>
                NULL;
            EXCEPTION
                WHEN CPDF_DYNRPT_ERROR THEN
                    hr_utility.set_location('Inside CPDF_DYNRPT_ERROR exception ',30);
                    ghr_mto_int.log_message(p_procedure => l_message_name,
                                            p_message   => l_log_text
                                            );
                    COMMIT;
                WHEN OTHERS THEN
                    hr_utility.set_location('Inside WHEN_OTHERS exception ',40);
                    l_message_name := 'Unhandled Error';
                    l_log_text     := 'Unhandled Error for pa_request_id: '||
                                      l_ghr_pa_requests_rec.pa_request_id ||
                                      ' ;  SSN/employee last name' ||
                                      l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                      l_ghr_pa_Requests_rec.employee_last_name ||
                                      ' ; first NOAC/Second NOAC: '||
                                      l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                      l_ghr_pa_requests_rec.second_noa_code ||
                                      ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
                    ghr_mto_int.log_message(p_procedure => l_message_name,
                                            p_message   => l_log_text
                                            );
                    COMMIT;

            END;
        END LOOP; -- end of check for single flag or dual flag
    END LOOP;

    IF NOT l_records_found THEN
	l_message_name:='RECORDS_NOT_FOUND';
	l_log_text:= 'No Records found for the period '||p_start_Date||' - '||p_end_date;
        ghr_mto_int.log_message(p_procedure => l_message_name,
                                p_message   => l_log_text
                               );

       l_mesgbuff1:='No Records found for the period '||p_start_Date||' - '||p_end_date;
       fnd_file.put(fnd_file.log,l_mesgbuff1);
       fnd_file.new_line(fnd_file.log);
    END IF;

ELSE -- DATES are not proper
	l_message_name:= 'CHECK_REPORT_FROM_TO_DATES';
	l_log_text:='The Report To Date: '||p_end_date||' is less than the Report From Date: '||p_start_date||
                    '. Please enter a value for Report To Date greater than or equal to the Report Start Date';

	ghr_mto_int.log_message(p_procedure => l_message_name,
                        p_message   => l_log_text
                       );
END IF;

    --
    hr_utility.set_location('Leaving:'||l_proc, 99);
--    hr_utility.trace_off;
    --
END populate_ghr_cpdf_temp;
--
END ghr_cpdf_dynrpt;

/
