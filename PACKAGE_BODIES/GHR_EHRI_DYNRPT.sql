--------------------------------------------------------
--  DDL for Package Body GHR_EHRI_DYNRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_EHRI_DYNRPT" AS
/* $Header: ghrehrid.pkb 120.31.12010000.14 2009/12/15 05:56:11 vmididho ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ghr_ehri_dynrpt.';  -- Global package name
g_eff_seq_no number := 1;

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
  -- BUG # 7229419 commented the NOAC's related to 8XX and 7XX as these
   -- need to be reported in EHRI Dynamics Report
    IF (l_noac BETWEEN '900' and '999')
        /*or
       (l_noac IN ( '850','855','750','782','800','805','806','880','881','882','883'))*/
    THEN
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

  --------------------------------------------------------------------------------------------
  --- This one picks the appropriation code 1 for a position -- NEW EHRI CHANGES
  --------------------------------------------------------------------------------------------
    PROCEDURE get_appr_code (p_position_id      IN  NUMBER
                            ,p_effective_date   IN  DATE
                            ,p_appr_code        OUT NOCOPY VARCHAR2) IS
  --
  l_pos_ei_grp1_data     per_position_extra_info%ROWTYPE;
  l_appr_code		 per_position_extra_info.POEI_INFORMATION13%TYPE;
  BEGIN
    ghr_history_fetch.fetch_positionei(p_position_id      => p_position_id
                                      ,p_information_type => 'GHR_US_POS_GRP2'
                                      ,p_date_effective   => p_effective_date
                                      ,p_pos_ei_data      => l_pos_ei_grp1_data);

    l_appr_code := l_pos_ei_grp1_data.POEI_INFORMATION13;

    --
    p_appr_code := l_appr_code;
  EXCEPTION
     WHEN OTHERS THEN
      p_appr_code := NULL;
      raise;
  END get_appr_code;
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
                                      ,p_rating_of_record_period  OUT NOCOPY DATE
				      ,p_rating_of_rec_period_starts OUT NOCOPY DATE)
IS
  --
  l_special_info   ghr_api.special_information_type;
  l_emp_number     per_people_f.employee_number%TYPE;
  CURSOR c_per IS
    SELECT per.employee_number
      FROM per_all_people_f per   -- Bug 4349372
     WHERE per.person_id = p_person_id
       AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN per.effective_start_date
                                                     AND per.effective_end_date;
  BEGIN
    ghr_api.return_special_information(p_person_id, 'US Fed Perf Appraisal',
                                       p_effective_date, l_special_info);

    IF l_special_info.object_version_number IS NOT NULL THEN
      p_rating_of_record_level		:= l_special_info.segment5;
      p_rating_of_record_pattern	:= l_special_info.segment4;
      p_rating_of_record_period		:= fnd_date.canonical_to_date(l_special_info.segment6);
      --Bug# 4753117 08-MAR-07	Veeramani  adding Appraisal start date
      p_rating_of_rec_period_starts     := fnd_date.canonical_to_date(l_special_info.segment17);
      --
      -- added for NEW EHRI CHANGES Madhuri

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
          p_rating_of_record_level		:= l_special_info.segment5;
          p_rating_of_record_pattern		:= l_special_info.segment4;
          p_rating_of_record_period		:= fnd_date.canonical_to_date(l_special_info.segment6);
       --Bug# 4753117 07-MAR-07	Veeramani  adding Appraisal start date
          p_rating_of_rec_period_starts		:= fnd_date.canonical_to_date(l_special_info.segment17);

	  --KFF - Personal Analysis Flexfield, US_FED_PERF_APPRAISAL
	  --
	  -- added for NEW EHRI CHANGES MADHURI
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
      p_rating_of_rec_period_starts := NULL;
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
			     -- Added for new EHRI changes Madhuri 21-Jan-2005
			    ,p_leave_scd		    		OUT NOCOPY DATE
			    ,p_scd_ses			    		OUT NOCOPY DATE
			    ,p_scd_spcl_retire              OUT NOCOPY DATE
			    ,p_ehri_employee_id		    	OUT NOCOPY ghr_cpdf_temp.ehri_employee_id%TYPE --NUMBER
			    ,p_tsp_scd			    		OUT NOCOPY DATE
			    ,p_scd_rif			  		  	OUT NOCOPY DATE
			    ,p_scd_retirement		    	OUT NOCOPY DATE
			    ,p_agency_use_code_field	    OUT NOCOPY VARCHAR2
			    ,p_agency_use_text_field	    OUT NOCOPY VARCHAR2
			    ,p_agency_data1		   			OUT NOCOPY VARCHAR2
			    ,p_agency_data2		    		OUT NOCOPY VARCHAR2
			    ,p_agency_data3		    		OUT NOCOPY VARCHAR2
			    ,p_agency_data4		    		OUT NOCOPY VARCHAR2
			    ,p_agency_data5		    		OUT NOCOPY VARCHAR2
			    ,p_race_ethnic_info             OUT NOCOPY VARCHAR2
			    --Bug# 6158983
			    ,p_world_citizenship              OUT NOCOPY VARCHAR2
			    -- 6312144 RPA-EIT Benefits
			    ,p_special_population_code        OUT NOCOPY VARCHAR2
                            ,p_csrs_exc_appts                 OUT NOCOPY VARCHAR2
                            ,p_fers_exc_appts                 OUT NOCOPY VARCHAR2
                            ,p_fica_coverage_ind1             OUT NOCOPY VARCHAR2
                            ,p_fica_coverage_ind2             OUT NOCOPY VARCHAR2
                            ,p_fegli_assg_indicator           OUT NOCOPY VARCHAR2
                            ,p_fegli_post_elc_basic_ins_amt   OUT NOCOPY VARCHAR2
                            ,p_fegli_court_ord_ind            OUT NOCOPY VARCHAR2
                            ,p_fegli_benf_desg_ind            OUT NOCOPY VARCHAR2
                            ,p_fehb_event_code                OUT NOCOPY VARCHAR2
			   ) IS
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

CURSOR rpa_eit_ben
    IS
    SELECT rit.information_type
    FROM   ghr_noa_families          nfa
          ,ghr_pa_request_info_types rit
    WHERE  rit.noa_family_code = nfa.noa_family_code
    AND    (nfa.nature_of_action_id = p_first_noa_id
       OR   nfa.nature_of_action_id = p_second_noa_id)
    AND    rit.information_type IN ('GHR_US_PAR_BENEFIT_INFO'  ,'GHR_US_PAR_RETIRMENT_SYS_INFO');
  --
  l_information_type     ghr_pa_request_extra_info.information_type%TYPE;
  l_rei                  ghr_pa_request_extra_info%ROWTYPE;
  l_race_national_origin VARCHAR2(150);
  l_handicap_code        VARCHAR2(150);
  l_per_ei_grp1_data     per_people_extra_info%rowtype;

  l_leave_scd		 DATE;
  l_tsp_scd		 DATE;
  l_ehri_employee_id	 ghr_cpdf_temp.ehri_employee_id%TYPE;
  --- Data records retrieval bug 4284244
  -- EHRI ID type problem
  --

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
        p_creditable_military_service  := l_rei.rei_information4;
        p_frozen_service               := l_rei.rei_information7;
        p_from_retirement_coverage     := l_rei.rei_information14;
        l_race_national_origin         := l_rei.rei_information16;
        l_handicap_code                := l_rei.rei_information8;
	-- Disability Code
        --
      ELSIF l_information_type = 'GHR_US_PAR_APPT_TRANSFER' THEN
        p_creditable_military_service  := l_rei.rei_information6;
        p_frozen_service               := l_rei.rei_information9;
        p_from_retirement_coverage     := l_rei.rei_information16;
        l_race_national_origin         := l_rei.rei_information18;
        l_handicap_code                := l_rei.rei_information10;
	-- Disability Code
        --
      ELSIF l_information_type = 'GHR_US_PAR_CONV_APP' THEN
        p_creditable_military_service  := l_rei.rei_information4;
        p_frozen_service               := l_rei.rei_information6;
        p_from_retirement_coverage     := l_rei.rei_information10;
        l_race_national_origin         := l_rei.rei_information12;
        l_handicap_code                := l_rei.rei_information7;
        --
      ELSIF l_information_type = 'GHR_US_PAR_RETURN_TO_DUTY' THEN
        p_creditable_military_service  := l_rei.rei_information3;
        p_frozen_service               := l_rei.rei_information5;
        --
      ELSIF l_information_type = 'GHR_US_PAR_CHG_RETIRE_PLAN' THEN
        p_creditable_military_service  := l_rei.rei_information3;
        p_frozen_service               := l_rei.rei_information5;
        p_from_retirement_coverage     := l_rei.rei_information6;
        --
      ELSIF l_information_type = 'GHR_US_PAR_CHG_SCD' THEN
        p_creditable_military_service  := l_rei.rei_information5;
        p_frozen_service               := l_rei.rei_information6;
        p_from_retirement_coverage     := l_rei.rei_information7;
	-- NEW EHRI DYNAMICS MADHURI
		p_scd_ses			:= fnd_date.canonical_to_date(l_rei.rei_information10);
		p_scd_spcl_retire		:= fnd_date.canonical_to_date(l_rei.rei_information11);
		p_tsp_scd			:= fnd_date.canonical_to_date(l_rei.rei_information9);
		p_scd_rif			:= fnd_date.canonical_to_date(l_rei.REI_INFORMATION3);
		p_scd_retirement		:= fnd_date.canonical_to_date(l_rei.REI_INFORMATION8);
	--
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
	      	END IF; -- IF l_rei.rei_informat
      END IF;
    END IF;  -- IF l_information_type IS NOT
    --
    IF p_race_ethnic_info IS NULL THEN
    	-- Fetching Race and ethnicity category
		l_per_ei_grp1_data := NULL;
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
    END IF; -- IF p_race_ethnic_info IS NULL THEN

    --Incase the SCD's above are NULL then pick values from GHR_US_PER_SCD_INFORMATION
    -- New EHRI changes Madhuri
	ghr_history_fetch.fetch_peopleei
           (p_person_id          =>  p_person_id,
            p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
            p_date_effective     =>  nvl(p_effective_date,trunc(sysdate)),
            p_per_ei_data        =>  l_per_ei_grp1_data
           );

   l_leave_scd	:= fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information3);
   p_leave_scd	:= l_leave_scd;
   --
   IF p_scd_rif IS NULL THEN
	p_scd_rif := fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information5);
   END IF;
   --
   IF p_tsp_scd IS NULL THEN
	p_tsp_scd := fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information6);
   END IF;
   --
   IF p_scd_retirement IS NULL THEN
	p_scd_retirement := fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information7);
   END IF;
   --
   IF p_scd_ses IS NULL THEN
	p_scd_ses := fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information8);
   END IF;
   --
   IF p_scd_spcl_retire IS NULL THEN
	p_scd_spcl_retire := fnd_date.canonical_to_date(l_per_ei_grp1_data.pei_information9);
   END IF;
   --
   -- bug 711711
   -- if RNO or Handicap code was not filled then get them from HR Person EI

   IF p_from_retirement_coverage IS NULL THEN
      ghr_history_fetch.fetch_peopleei(
        p_person_id        => p_person_id,
        p_information_type => 'GHR_US_PER_SEPARATE_RETIRE',
        p_date_effective   => p_effective_date,
        p_per_ei_data      => l_per_ei_grp1_data);

    p_from_retirement_coverage	:= l_per_ei_grp1_data.PEI_INFORMATION4;
   END IF;
--
   IF p_ehri_employee_id IS NULL THEN
    ghr_history_fetch.fetch_peopleei(
        p_person_id        => p_person_id,
        p_information_type => 'GHR_US_PER_GROUP1',
        p_date_effective   => p_effective_date,
        p_per_ei_data      => l_per_ei_grp1_data);

    l_ehri_employee_id	:= l_per_ei_grp1_data.pei_information18;
   END IF;
--

--Bug #6158983 code modified to person group1 information without checking any NULL
-- as same can be used to fetch world citizenship

--    IF   l_race_national_origin IS NULL
  --    OR l_handicap_code IS NULL THEN
  --Bug#6158983

      ghr_history_fetch.fetch_peopleei(
        p_person_id        => p_person_id,
        p_information_type => 'GHR_US_PER_GROUP1',
        p_date_effective   => p_effective_date,
        p_per_ei_data      => l_per_ei_grp1_data);

      IF l_race_national_origin IS NULL THEN
        l_race_national_origin := l_per_ei_grp1_data.pei_information5;
	-- Race and National Origin Code
      END IF;
      --
      IF l_handicap_code IS NULL THEN
        l_handicap_code := l_per_ei_grp1_data.pei_information11;
      END IF;

--Bug#6158983
      p_world_citizenship := l_per_ei_grp1_data.pei_information10;
--Endof Bug#6158983


      --
      --

--    END IF;

-- Fetch The agency related details under this
-- since US Fed Agency data isnt EIT of any particular NOAC and is associated with
-- call get_PAR_EI again for GHR_US_PAR_GEN_AGENCY_DATA

	BEGIN
	get_PAR_EI
		(p_pa_request_id
                 ,p_noa_family_code
                 ,'GHR_US_PAR_GEN_AGENCY_DATA'
                 ,l_rei);

	p_agency_use_code_field         := l_rei.rei_information3;
	p_agency_use_text_field         := l_rei.rei_information3;
	p_agency_data1			:= l_rei.rei_information4;
	p_agency_data2			:= l_rei.rei_information5;
	p_agency_data3			:= l_rei.rei_information6;
	p_agency_data4			:= l_rei.rei_information7;
	p_agency_data5			:= l_rei.rei_information8;
	END;

	 --6312144 RPA EIT Benefits
  FOR c_rpa_eit_rec IN rpa_eit_ben
  LOOP
   l_rei := NULL;
   l_information_type := c_rpa_eit_rec.information_type;
   get_PAR_EI (p_pa_request_id
                 ,p_noa_family_code
                 ,l_information_type
                 ,l_rei);

      IF l_information_type = 'GHR_US_PAR_RETIRMENT_SYS_INFO' THEN
        p_special_population_code := l_rei.rei_information1;
        p_csrs_exc_appts          := l_rei.rei_information2;
        p_fers_exc_appts          := l_rei.rei_information3;
        p_fica_coverage_ind1      := l_rei.rei_information4;
        p_fica_coverage_ind2      := l_rei.rei_information5;

      ELSIF l_information_type = 'GHR_US_PAR_BENEFIT_INFO' THEN
            p_fegli_assg_indicator        := l_rei.rei_information1;
            p_fegli_post_elc_basic_ins_amt:= l_rei.rei_information2;
            p_fegli_court_ord_ind         := l_rei.rei_information3;
            p_fegli_benf_desg_ind         := l_rei.rei_information4;
            p_fehb_event_code             := l_rei.rei_information5;
      END IF; -- IF l_information_type = 'GHR_US_P
   END LOOP;
    -- ENd of 6312144
    p_race_national_origin := l_race_national_origin;
    p_handicap_code        := l_handicap_code;
    p_ehri_employee_id     := l_ehri_employee_id;
    p_leave_scd		   := l_leave_scd;




  EXCEPTION
      WHEN OTHERS THEN
      p_creditable_military_service := NULL;
      p_frozen_service		    := NULL;
      p_from_retirement_coverage    := NULL;
      p_race_national_origin        := NULL;
      p_handicap_code               := NULL;
      p_ind_group_award             := NULL;
      p_benefit_award               := NULL;
      -- New eHRI changes Madhuri
      p_leave_scd		    := NULL;
      p_scd_ses			    := NULL;
      p_scd_spcl_retire 	    := NULL;
      p_ehri_employee_id	    := NULL;
      p_tsp_scd			    := NULL;
      p_scd_rif			    := NULL;
      p_scd_retirement		    := NULL;
      p_agency_use_code_field	    := NULL;
      p_agency_use_text_field	    := NULL;
      p_agency_data1		    := NULL;
      p_agency_data2		    := NULL;
      p_agency_data3		    := NULL;
      p_agency_data4		    := NULL;
      p_agency_data5		    := NULL;
      p_world_citizenship           := NULL;
      p_special_population_code     := NULL;
      p_csrs_exc_appts              := NULL;
      p_fers_exc_appts              := NULL;
      p_fica_coverage_ind1          := NULL;
      p_fica_coverage_ind2          := NULL;
      p_fegli_assg_indicator        := NULL;
      p_fegli_post_elc_basic_ins_amt:= NULL;
      p_fegli_court_ord_ind         := NULL;
      p_fegli_benf_desg_ind         := NULL;
      p_fehb_event_code             := NULL;
      raise;
  END get_PAR_EI_noac;
--
--
PROCEDURE get_asg_details(p_pa_request_id                IN  NUMBER
                         ,p_person_id                    IN  NUMBER
                         ,p_effective_date               IN  DATE
			 ,p_appt_nte_date	         OUT NOCOPY DATE)
IS
  --
  l_information_type     ghr_pa_request_extra_info.information_type%TYPE;
  l_rei                  ghr_pa_request_extra_info%ROWTYPE;
  l_per_ei_grp1_data     per_people_extra_info%rowtype;
  l_appt_nte_date	 DATE;
			--per_assignment_extra_info.aei_information4%TYPE;
--
CURSOR get_asg_id(p_request_id NUMBER,
		  p_person_id  NUMBER)
IS
SELECT employee_assignment_id
FROM   ghr_pa_requests
WHERE  pa_request_id=p_request_id
AND    person_id=p_person_id;
--
l_asg_id	per_assignments_f.assignment_id%TYPE;
l_asg_ei_data   per_assignment_extra_info%rowtype;

BEGIN
--
FOR get_asg_rec IN get_asg_id(p_pa_request_id, p_person_id)
LOOP
	l_asg_id   :=  get_asg_rec.employee_assignment_id;
END LOOP;

ghr_history_fetch.fetch_asgei
	( p_assignment_id => l_asg_id,
	  p_information_type  => 'GHR_US_ASG_NTE_DATES',
          p_date_effective    => p_effective_date,
          p_asg_ei_data       => l_asg_ei_data
        );

l_appt_nte_date  := fnd_date.canonical_to_date(l_asg_ei_data.AEI_INFORMATION4);
--
p_appt_nte_date  := l_appt_nte_date;

EXCEPTION
      WHEN OTHERS THEN
      p_appt_nte_date		:= NULL;
      raise;
END get_asg_details;
--
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
  --  This will insert one record into the GHR_CPDF_TEMP
  ---------------------------------------------------------------------------------------------
  --
  PROCEDURE insert_row (p_ghr_cpdf_temp_rec IN ghr_cpdf_temp%rowtype) IS
  BEGIN

    INSERT INTO ghr_cpdf_temp(
     			report_type,
     			session_id,
     			to_national_identifier,
     			employee_date_of_birth,
			ehri_employee_id,
			agency_code,
     			effective_date,
     			first_noa_code,
     			first_action_la_code1,
     			first_action_la_code2,
     			second_noa_code,
			NOA_CORRECTED, -- THIS IS NOT SUPPORTED, REPORT BLANK
			EFFECTIVE_DATE_CORRECTED, -- THIS IS NOT SUPPORTED, REPORT BLANK
     			current_appointment_auth1,
     			current_appointment_auth2,
			APPOINTMENT_NTE_DATE,
     			personnel_office_id,
			organizational_component,
     			sex,
     			race_national_origin,
     			handicap_code,
			SSN_CORRECTED,
     			veterans_preference,
     			tenure,
			AGENCY_USE_CODE_FIELD,
			AGENCY_USE_TEXT_FIELD,
			VETERANS_PREF_FOR_RIF,
			FEGLI,
			annuitant_indicator,
     			retirement_plan,
			leave_SCD,
			SCD_retirement,
			SCD_rif,
			SCD_SES,
			SCD_SPCL_RETIRE,
			TSP_SCD,
			position_occupied,
			FLSA_category,
			appropriation_code, -- New
			bargaining_unit_status,
			supervisory_status,
                  creditable_military_service,
                  frozen_service,
                  from_retirement_coverage,
     			veterans_status,
     			education_level,
     			academic_discipline,
     			year_degree_attained,
     			rating_of_record_level,
     			rating_of_record_pattern,
			RATING_OF_RECORD_PERIOD_STARTS, -- New
     			rating_of_record_period_ends,
			PRIOR_FAMILY_NAME,	--
			PRIOR_GIVEN_NAME,	  --
			PRIOR_MIDDLE_NAME,	     --
			PRIOR_NAME_SUFFIX,		-- New
			PRIOR_POSITION_TITLE,	     --
			PRIOR_POSITION_NUMBER,	  --
			PRIOR_POSITION_ORG,	--
     			from_pay_plan,
     			from_occ_code,
     			from_grade_or_level,
     			from_step_or_rate,
     			from_pay_basis,
			from_TOTAL_SALARY,
     			from_basic_pay,
			from_ADJ_BASIC_PAY,
     			from_locality_adj,
     			from_work_schedule,
			from_pay_rate_determinant,
     			from_duty_station_code,
     			employee_last_name,
			employee_first_name,
			employee_middle_names,
			name_title,
			position_title,
			POSITION_NUMBER,
			POSITION_ORG,
			to_pay_plan,
     			to_occ_code,
     			to_grade_or_level,
			to_step_or_rate,
			to_pay_basis,
			to_TOTAL_SALARY,
			to_basic_pay,
			to_ADJ_BASIC_PAY,
     			to_locality_adj,
     			to_supervisory_differential,
     			to_retention_allowance,
			award_dollars,
			award_hours,
			award_percentage,
     			to_work_schedule,
			PART_TIME_HOURS, --- can v have this as to_part_time_hours ?
			to_pay_rate_determinant,
     			to_duty_station_code,
			AGENCY_DATA1,
			AGENCY_DATA2,
			AGENCY_DATA3,
			AGENCY_DATA4,
			AGENCY_DATA5,
			ACTION_APPROVAL_DATE,
			ACTION_AUTHR_FAMILY_NAME,
			ACTION_AUTHR_GIVEN_NAME,
			ACTION_AUTHR_MIDDLE_NAME,
			ACTION_AUTHR_NAME_SUFFIX,
			ACTION_AUTHR_TITLE,
			REMARKS_TEXT,
			race_ethnic_info,
			from_spl_rate_supplement,
			to_spl_rate_supplement,
			--Bug# 6158983
			world_citizenship,
			health_plan,
			special_population_code,
			csrs_exc_appts,
			fers_exc_appts,
			fica_coverage_ind1,
			fica_coverage_ind2,
			hyp_full_reg_duty_part_emp,
			fegli_assg_indicator,
			fegli_post_elc_basic_ins_amt,
                        fegli_court_ord_ind,
			fegli_benf_desg_ind,
			fehb_event_code,
			pareq_last_updated_date,
			fehb_elect_eff_date,
			--Bug# 6158983
			noac_order_of_processing
			)
    VALUES(
     			'DYNAMICS',
     			USERENV('SESSIONID'),
     			p_ghr_cpdf_temp_rec.to_national_identifier,
    			p_ghr_cpdf_temp_rec.employee_date_of_birth,
				p_ghr_cpdf_temp_rec.ehri_employee_id,	-- new
     			p_ghr_cpdf_temp_rec.agency_code,
     			p_ghr_cpdf_temp_rec.effective_date,
     			p_ghr_cpdf_temp_rec.first_noa_code,
     			p_ghr_cpdf_temp_rec.first_action_la_code1,
     			p_ghr_cpdf_temp_rec.first_action_la_code2,
				p_ghr_cpdf_temp_rec.second_noa_code,
				p_ghr_cpdf_temp_rec.NOA_CORRECTED, -- new
				p_ghr_cpdf_temp_rec.EFFECTIVE_DATE_CORRECTED, --new
     			p_ghr_cpdf_temp_rec.current_appointment_auth1,
     			p_ghr_cpdf_temp_rec.current_appointment_auth2,
				p_ghr_cpdf_temp_rec.APPOINTMENT_NTE_DATE, -- New
     			p_ghr_cpdf_temp_rec.personnel_office_id,
     			p_ghr_cpdf_temp_rec.organizational_component,
     			p_ghr_cpdf_temp_rec.sex,
     			p_ghr_cpdf_temp_rec.race_national_origin,
     			p_ghr_cpdf_temp_rec.handicap_code,
				p_ghr_cpdf_temp_rec.SSN_CORRECTED, --new
     			p_ghr_cpdf_temp_rec.veterans_preference,
     			p_ghr_cpdf_temp_rec.tenure,
				p_ghr_cpdf_temp_rec.AGENCY_USE_CODE_FIELD,
				p_ghr_cpdf_temp_rec.AGENCY_USE_TEXT_FIELD,
				p_ghr_cpdf_temp_rec.VETERANS_PREF_FOR_RIF,
				p_ghr_cpdf_temp_rec.FEGLI,	-- existing but not coded
				p_ghr_cpdf_temp_rec.annuitant_indicator,  -- existing but nt coded
     			p_ghr_cpdf_temp_rec.retirement_plan,
				p_ghr_cpdf_temp_rec.LEAVE_SCD,		--new
				p_ghr_cpdf_temp_rec.SCD_retirement,
				p_ghr_cpdf_temp_rec.SCD_RIF,
				p_ghr_cpdf_temp_rec.SCD_SES, -- NEW
				p_ghr_cpdf_temp_rec.SCD_spcl_retire, -- NEW
				p_ghr_cpdf_temp_rec.TSP_SCD, -- NEW
     			p_ghr_cpdf_temp_rec.position_occupied,
     			p_ghr_cpdf_temp_rec.FLSA_category,	-- existing but not coded
     			p_ghr_cpdf_temp_rec.appropriation_code,		-- NEW
				p_ghr_cpdf_temp_rec.bargaining_unit_status,	-- existing but not coded
				p_ghr_cpdf_temp_rec.supervisory_status,
                p_ghr_cpdf_temp_rec.creditable_military_service,
                p_ghr_cpdf_temp_rec.frozen_service,
                p_ghr_cpdf_temp_rec.from_retirement_coverage,
				p_ghr_cpdf_temp_rec.veterans_status,
     			p_ghr_cpdf_temp_rec.education_level,
     			p_ghr_cpdf_temp_rec.academic_discipline,
				p_ghr_cpdf_temp_rec.year_degree_attained,
     			p_ghr_cpdf_temp_rec.rating_of_record_level,
     			p_ghr_cpdf_temp_rec.rating_of_record_pattern,
     			p_ghr_cpdf_temp_rec.rating_of_record_period_starts, -- NEW
     			p_ghr_cpdf_temp_rec.rating_of_record_period_ends,
				p_ghr_cpdf_temp_rec.PRIOR_FAMILY_NAME,	--
				p_ghr_cpdf_temp_rec.PRIOR_GIVEN_NAME,	  --
				p_ghr_cpdf_temp_rec.PRIOR_MIDDLE_NAME,	     --
				p_ghr_cpdf_temp_rec.PRIOR_NAME_SUFFIX,		-- New
				p_ghr_cpdf_temp_rec.PRIOR_POSITION_TITLE,     --
				p_ghr_cpdf_temp_rec.PRIOR_POSITION_NUMBER,  --
				p_ghr_cpdf_temp_rec.PRIOR_POSITION_ORG,	--
     			p_ghr_cpdf_temp_rec.from_pay_plan,
     			p_ghr_cpdf_temp_rec.from_occ_code,
     			p_ghr_cpdf_temp_rec.from_grade_or_level,
     			p_ghr_cpdf_temp_rec.from_step_or_rate,
     			p_ghr_cpdf_temp_rec.from_pay_basis,
				p_ghr_cpdf_temp_rec.from_total_salary,	-- existing but not coded
     			p_ghr_cpdf_temp_rec.from_basic_pay,
				p_ghr_cpdf_temp_rec.from_adj_basic_pay,
     			p_ghr_cpdf_temp_rec.from_locality_adj,
     			p_ghr_cpdf_temp_rec.from_work_schedule,
				p_ghr_cpdf_temp_rec.from_pay_rate_determinant,
     			p_ghr_cpdf_temp_rec.from_duty_station_code,
     			p_ghr_cpdf_temp_rec.employee_last_name,
				p_ghr_cpdf_temp_rec.employee_first_name,
				p_ghr_cpdf_temp_rec.employee_middle_names,
				p_ghr_cpdf_temp_rec.name_title,
				p_ghr_cpdf_temp_rec.position_title,
				p_ghr_cpdf_temp_rec.POSITION_NUMBER,	-- NEW
				p_ghr_cpdf_temp_rec.POSITION_ORG,	-- NEW
     			p_ghr_cpdf_temp_rec.to_pay_plan,
     			p_ghr_cpdf_temp_rec.to_occ_code,
     			p_ghr_cpdf_temp_rec.to_grade_or_level,
     			p_ghr_cpdf_temp_rec.to_step_or_rate,
     			p_ghr_cpdf_temp_rec.to_pay_basis,
				p_ghr_cpdf_temp_rec.to_total_salary,	-- existing but not coded
     			p_ghr_cpdf_temp_rec.to_basic_pay,
				p_ghr_cpdf_temp_rec.TO_ADJ_BASIC_PAY,	-- NEW
     			p_ghr_cpdf_temp_rec.to_locality_adj,
     			p_ghr_cpdf_temp_rec.to_supervisory_differential,
     			p_ghr_cpdf_temp_rec.to_retention_allowance,
				p_ghr_cpdf_temp_rec.award_dollars,
				p_ghr_cpdf_temp_rec.award_hours,
				p_ghr_cpdf_temp_rec.award_percentage,
     			p_ghr_cpdf_temp_rec.to_work_schedule,
				p_ghr_cpdf_temp_rec.PART_TIME_HOURS,	--NEW
				p_ghr_cpdf_temp_rec.to_pay_rate_determinant,
     			p_ghr_cpdf_temp_rec.to_duty_station_code,
				p_ghr_cpdf_temp_rec.AGENCY_DATA1,	-- NEW
				p_ghr_cpdf_temp_rec.AGENCY_DATA2,	-- NEW
				p_ghr_cpdf_temp_rec.AGENCY_DATA3,	--NEW
				p_ghr_cpdf_temp_rec.AGENCY_DATA4,	-- NEW
				p_ghr_cpdf_temp_rec.AGENCY_DATA5,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_APPROVAL_DATE,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_AUTHR_FAMILY_NAME,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_AUTHR_GIVEN_NAME,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_AUTHR_MIDDLE_NAME,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_AUTHR_NAME_SUFFIX,	--NEW
				p_ghr_cpdf_temp_rec.ACTION_AUTHR_TITLE,		--NEW
				p_ghr_cpdf_temp_rec.REMARKS_TEXT,		--NEW
				p_ghr_cpdf_temp_rec.race_ethnic_info,
				p_ghr_cpdf_temp_rec.from_spl_rate_supplement,
				p_ghr_cpdf_temp_rec.to_spl_rate_supplement,
				--Bug# 6158983
				p_ghr_cpdf_temp_rec.world_citizenship,
                                p_ghr_cpdf_temp_rec.health_plan,
				p_ghr_cpdf_temp_rec.special_population_code,
                                p_ghr_cpdf_temp_rec.csrs_exc_appts,
 			        p_ghr_cpdf_temp_rec.fers_exc_appts,
 			        p_ghr_cpdf_temp_rec.fica_coverage_ind1,
 			        p_ghr_cpdf_temp_rec.fica_coverage_ind2,
                                p_ghr_cpdf_temp_rec.hyp_full_reg_duty_part_emp,
				p_ghr_cpdf_temp_rec.fegli_assg_indicator,
                                p_ghr_cpdf_temp_rec.fegli_post_elc_basic_ins_amt,
                                p_ghr_cpdf_temp_rec.fegli_court_ord_ind,
                                p_ghr_cpdf_temp_rec.fegli_benf_desg_ind,
                                p_ghr_cpdf_temp_rec.fehb_event_code,
				p_ghr_cpdf_temp_rec.pareq_last_updated_date,
				p_ghr_cpdf_temp_rec.fehb_elect_eff_date,
				--Bug# 6158983
				--added the below column for dual actions
				p_ghr_cpdf_temp_rec.noac_order_of_processing
			);

    COMMIT;

  END insert_row;
  --
---------------------------------------------------------------------------
--- THIS IS PROC TO GENERATE THE ASCII and XML file
---------------------------------------------------------------------------
  --
  PROCEDURE WritetoFile (p_input_file_name IN VARCHAR2,
						p_gen_xml_file IN VARCHAR2,
						p_gen_txt_file IN VARCHAR2
						)
	IS
		p_xml_fp UTL_FILE.FILE_TYPE;
		p_ascii_fp  UTL_FILE.FILE_TYPE;
		l_audit_log_dir varchar2(500);
		l_xml_file_name varchar2(500);
		l_ascii_file_name varchar2(500);
		l_output_xml_fname varchar2(500);
		l_output_ascii_fname varchar2(500);
		v_tags t_tags;
		l_count NUMBER;
		l_session_id NUMBER;
		l_request_id NUMBER;
		l_temp VARCHAR2(500);


        --6158983
	prev_national_identifier GHR_CPDF_TEMP.to_national_identifier%type := null;
	prev_effective_date      GHR_CPDF_TEMP.effective_date%type := null;
	prev_agency_code         GHR_CPDF_TEMP.agency_code%type := null;
	eff_seq_no               number;
        --6158983

	--6850492 order of processing in the order by clause to handle dual actions
	CURSOR c_cpdf_dynamic(c_session_id NUMBER) IS
	SELECT *
	FROM  GHR_CPDF_TEMP
	WHERE SESSION_ID = c_session_id
	AND   report_type='DYNAMICS'
	ORDER BY agency_code,to_national_identifier,effective_date,pareq_last_updated_date,noac_order_of_processing;
	--6850492


	--
	CURSOR c_out_dir(c_request_id fnd_concurrent_requests.request_id%type) IS
		SELECT outfile_name
		FROM FND_CONCURRENT_REQUESTS
		WHERE request_id = c_request_id;
	--
	BEGIN
		-- Assigning the File name.
		l_xml_file_name :=  p_input_file_name || '.xml';
		l_ascii_file_name := p_input_file_name || '.txt';
		l_count := 1;
		l_session_id := USERENV('SESSIONID');

	/*	l_request_id := fnd_profile.VALUE('CONC_REQUEST_ID');
		FOR l_out_dir IN c_out_dir(l_request_id) LOOP
			l_temp := l_out_dir.outfile_name;
		END LOOP;
		l_audit_log_dir := SUBSTR(l_temp,1,INSTR(l_temp,'o'||l_request_id)-1); */
		--
		select value
		into l_audit_log_dir
		from    v$parameter
		where   name = 'utl_file_dir';
		-- Check whether more than one util file directory is found
		IF INSTR(l_audit_log_dir,',') > 0 THEN
		   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
		END IF;

		-- Find out whether the OS is MS or Unix/Linux based
		-- If it's greater than 0, it's Unix/Linux based environment
		IF INSTR(l_audit_log_dir,'/') > 0 THEN
			l_output_xml_fname := l_audit_log_dir || '/' || l_xml_file_name;
			l_output_ascii_fname := l_audit_log_dir || '/' || l_ascii_file_name;
		ELSE
			l_output_xml_fname := l_audit_log_dir || '\' || l_xml_file_name;
			l_output_ascii_fname := l_audit_log_dir || '\' || l_ascii_file_name;
		END IF;

		--	fnd_file.put_line(fnd_file.log,'-----'||l_audit_log_dir);
		p_ascii_fp := utl_file.fopen(l_audit_log_dir,l_ascii_file_name,'w',32767);

		IF p_gen_xml_file = 'Y' THEN
			p_xml_fp := utl_file.fopen(l_audit_log_dir,l_xml_file_name,'w',32767);
			utl_file.put_line(p_xml_fp,'<?xml version="1.0" encoding="UTF-8"?>');
			-- Writing from and to dates
			utl_file.put_line(p_xml_fp,'<Records>');

			-- Loop through cursor and write the values into the XML and ASCII File.


			FOR ctr_table IN c_cpdf_dynamic(l_session_id) LOOP

                                if nvl(prev_national_identifier,'XXX')   <> ctr_table.to_national_identifier or
		                   nvl(prev_agency_code,'X')             <> ctr_table.agency_code or
				   nvl(prev_effective_date,TO_DATE('01/01/1951','DD/MM/RRRR')) <> ctr_table.effective_date
				   then
		                           g_eff_seq_no := 1;
                     		           prev_national_identifier := ctr_table.to_national_identifier;
                        		   prev_agency_code         := ctr_table.agency_code;
                         		   prev_effective_date      := ctr_table.effective_date;
                      		else
                     	        	   g_eff_seq_no := g_eff_seq_no + 1;
                         	end if;

				WriteTagValues(ctr_table,v_tags);
				utl_file.put_line(p_xml_fp,'<Record' || l_count || '>');
				WriteXMLvalues(p_xml_fp,v_tags);
				utl_file.put_line(p_xml_fp,'</Record' || l_count || '>');
				WriteAsciivalues(p_ascii_fp,v_tags,p_gen_txt_file);
				l_count := l_count + 1;
			END LOOP;

			-- Write the end tag and close the XML File.
			utl_file.put_line(p_xml_fp,'</Records>');
			utl_file.fclose(p_xml_fp);
		ELSE

		 prev_national_identifier:= null;
		 prev_agency_code := null;
                 prev_effective_date := null;

			-- Loop through cursor and write the values into the XML and ASCII File.
			FOR ctr_table IN c_cpdf_dynamic(l_session_id) LOOP
			    if nvl(prev_national_identifier,'XXX') <> ctr_table.to_national_identifier or
		               nvl(prev_agency_code,'XX')         <> ctr_table.agency_code or
				   nvl(prev_effective_date,TO_DATE('01/01/1951','DD/MM/RRRR')) <> ctr_table.effective_date THEN
		                      g_eff_seq_no := 1;
                     		      prev_national_identifier := ctr_table.to_national_identifier;
                        	      prev_agency_code         := ctr_table.agency_code;
                         	      prev_effective_date      := ctr_table.effective_date;
                      	    else
                     	       	   g_eff_seq_no := nvl(g_eff_seq_no,0) + 1;
                            end if;
				WriteTagValues(ctr_table,v_tags);
				WriteAsciivalues(p_ascii_fp,v_tags,p_gen_txt_file);
				l_count := l_count + 1;
			END LOOP;
		END IF; -- IF p_gen_xml_file = 'Y' THEN

			l_count := l_count - 1;
			fnd_file.put_line(fnd_file.log,'------------------------------------------------');
			fnd_file.put_line(fnd_file.log,'Total Records : ' || l_count );
			fnd_file.put_line(fnd_file.log,'------------------------------------------------');

		IF p_gen_xml_file = 'Y' OR p_gen_txt_file = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'------------Path of output file----------------');
			IF p_gen_xml_file = 'Y' THEN
				fnd_file.put_line(fnd_file.log,'XML  file : ' || l_output_xml_fname);
			END IF;
			IF p_gen_txt_file = 'Y' THEN
				fnd_file.put_line(fnd_file.log,'Text file : ' || l_output_ascii_fname);
			END IF;
			fnd_file.put_line(fnd_file.log,'-------------------------------------------');
		END IF;

	END WritetoFile;

  ---------------------------------------------------------------------------------------------
  -- This Procedure writes one record from the temporary table GHR_CPDF_TEMP
  -- to a PL/SQL table p_tags at a time. This PL/SQL table p_tags is used to write to file.
  ---------------------------------------------------------------------------------------------

	PROCEDURE WriteTagValues(p_cpdf_dynamic GHR_CPDF_TEMP%rowtype,p_tags OUT NOCOPY t_tags)
	IS
	l_count NUMBER;


	BEGIN
		l_count := 1;
		-- Writing to Tags
		p_tags(l_count).tagname := 'Social_Security_Number';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.to_national_identifier,1,3) || '-' ||SUBSTR(p_cpdf_dynamic.to_national_identifier,4,2) || '-' ||SUBSTR(p_cpdf_dynamic.to_national_identifier,6) ;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Birth_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.employee_date_of_birth,'YYYY-MM-DD');
		l_count := l_count+1;

		-- Check this
		p_tags(l_count).tagname := 'EHRI_Employee_ID';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.EHRI_employee_id;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Subelement_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Effective_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.effective_date,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Nature_of_Action_Code_1';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.first_noa_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Legal_Authority_Code_1';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.first_action_la_code1;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Legal_Authority_Code_2';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.first_action_la_code2;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Nature_of_Action_Code_2';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.second_noa_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Nature_of_Action_Being_Corrected';
		p_tags(l_count).tagvalue := NULL;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Effective_Date_of_Personnel_Action_Being_Corrected';
		p_tags(l_count).tagvalue := NULL;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Current_Appointment_Authority_Code_1';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.current_appointment_auth1;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Current_Appointment_Authority_Code_2';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.current_appointment_auth2;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Appointment_Not_to_Exceed_NTE_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.appointment_nte_date,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Office_Identifier_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.personnel_office_id;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Organizational_Component_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.organizational_component;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Gender_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.sex;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Race_and_National_Origin_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.race_national_origin;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Disability_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.handicap_code;
		l_count := l_count+1;

		-- Check
		p_tags(l_count).tagname := 'Social_Security_Number_Being_Corrected';
		IF p_cpdf_dynamic.ssn_corrected IS NOT NULL THEN
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.ssn_corrected,1,3) || '-' ||SUBSTR(p_cpdf_dynamic.ssn_corrected,4,2) || '-' ||SUBSTR(p_cpdf_dynamic.ssn_corrected,6) ;
		ELSE
		p_tags(l_count).tagvalue := p_cpdf_dynamic.ssn_corrected;
		END IF;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Veterans_Preference_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.veterans_preference;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Tenure_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.tenure;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Use_Code_Field';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_use_code_field;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Use_Text_Field';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_use_text_field;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Veterans_Preference_for_RIF_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.VETERANS_PREF_FOR_RIF;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'FEGLI_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fegli;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Annuitant_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.annuitant_indicator;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Retirement_System_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.retirement_plan;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Leave_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.leave_scd,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Retirement_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.scd_retirement,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'RIF_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.scd_rif,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'SES_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.scd_ses,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Special_Retirement_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.scd_spcl_retire,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Thrift_Savings_Plan_Service_Computation_Date';
		p_tags(l_count).tagvalue := to_char(p_cpdf_dynamic.tsp_scd,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Position_Occupied_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.position_occupied;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'FLSA_Category_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.flsa_category;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Appropriation_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.appropriation_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Bargaining_Unit_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.bargaining_unit_status;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Supervisory_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.supervisory_status;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Creditable_Military_Service_Years';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.creditable_military_service,1,2);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Creditable_Military_Service_Months';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.creditable_military_service,3,2);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Creditable_Military_Service_Days';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.creditable_military_service,5);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Frozen_Service_Years';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.frozen_service,1,2);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Frozen_Service_Months';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.frozen_service,3,2);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Frozen_Service_Days';
		p_tags(l_count).tagvalue := SUBSTR(p_cpdf_dynamic.frozen_service,5);
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Retirement_Previous_Coverage_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_retirement_coverage;

		/*IF p_cpdf_dynamic.first_noa_code <> '001' THEN
		  IF p_cpdf_dynamic.from_retirement_coverage IS NOT NULL THEN
			p_tags(l_count).tagvalue := p_cpdf_dynamic.from_retirement_coverage;
		  ELSE
			p_tags(l_count).tagvalue := NVL(p_cpdf_dynamic.from_retirement_coverage,'NA');
		  END IF;
                ELSE
			p_tags(l_count).tagvalue := NULL;
		END If;*/
		l_count := l_count+1;
-- changed the column name from retirement_prev_covr to from_retirement_coverage

		p_tags(l_count).tagname := 'Veterans_Status_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.veterans_status;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Education_Level_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.education_level;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Instructional_Program_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.academic_discipline;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Degree_Year';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.year_degree_attained;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Rating_of_Record_Level_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.rating_of_record_level;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Rating_of_Record_Pattern_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.rating_of_record_pattern;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Rating_of_Record_Period_Start_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.rating_of_record_period_starts,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Rating_of_Record_Period_End_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.rating_of_record_period_ends,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Family_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_family_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Given_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_given_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Middle_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_middle_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Name_Suffix';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_name_suffix;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Position_Title';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_position_title;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Position_Number';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_position_number;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Position_Organization';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.prior_position_org;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Pay_Plan_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_pay_plan;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Occupational_Series_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_occ_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Grade_Level_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_grade_or_level;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Step_or_Rate_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_step_or_rate;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Pay_Basis_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_pay_basis;
		l_count := l_count+1;

		-- Begin Bug# 5562815
		IF p_cpdf_dynamic.from_pay_basis <> 'PA' THEN

			p_tags(l_count).tagname := 'Prior_Total_Pay_Rate';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.from_total_salary,'99999999.99'));
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Prior_Basic_Pay';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.from_basic_pay,'99999999.99'));
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Prior_Adjusted_Basic_Pay_Amount';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.from_adj_basic_pay,'99999999.99'));
			l_count := l_count+1;
		ELSE
			p_tags(l_count).tagname := 'Prior_Total_Pay_Rate';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.from_total_salary;
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Prior_Basic_Pay';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.from_basic_pay;
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Prior_Adjusted_Basic_Pay_Amount';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.from_adj_basic_pay;
			l_count := l_count+1;
		END IF;
		-- End Bug# 5562815

		p_tags(l_count).tagname := 'Prior_Locality_Pay_Amount';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_locality_adj;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Work_Schedule_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_work_schedule;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Pay_Rate_Determinant_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_pay_rate_determinant;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Prior_Duty_Station_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_duty_station_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Family_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.employee_last_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Given_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.employee_first_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Middle_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.employee_middle_names;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Name_Suffix';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.name_title;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Position_Title';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.position_title;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Position_Number';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.position_number;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Position_Organization';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.position_org;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Pay_Plan_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_pay_plan;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Occupational_Series_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_occ_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Grade_Level_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_grade_or_level;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Step_or_Rate_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_step_or_rate;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Pay_Basis_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_pay_basis;
		l_count := l_count+1;

		-- Begin Bug# 5562815
		IF p_cpdf_dynamic.to_pay_basis <> 'PA' THEN
			p_tags(l_count).tagname := 'Total_Pay_Rate';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.to_total_salary,'99999999.99'));
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Basic_Pay_Amount';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.to_basic_pay,'99999999.99'));
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Adjusted_Basic_Pay_Amount';
			p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_dynamic.to_adj_basic_pay,'99999999.99'));
			l_count := l_count+1;
		ELSE
			p_tags(l_count).tagname := 'Total_Pay_Rate';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.to_total_salary;
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Basic_Pay_Amount';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.to_basic_pay;
			l_count := l_count+1;

			p_tags(l_count).tagname := 'Adjusted_Basic_Pay_Amount';
			p_tags(l_count).tagvalue := p_cpdf_dynamic.to_adj_basic_pay;
			l_count := l_count+1;
		END IF;
		-- End Bug# 5562815

		p_tags(l_count).tagname := 'Locality_Pay_Amount';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_locality_adj;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Supervisor_Differential_Amount';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_supervisory_differential;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Retention_Allowance_Amount';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_retention_allowance;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Award_Dollars';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.award_dollars;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Award_Hours';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.award_hours;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Award_Percent';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.award_percentage;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Work_Schedule_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_work_schedule;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Part_Time_Hours';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.part_time_hours;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Pay_Rate_Determinant_Type_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_pay_rate_determinant;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Duty_Station_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_duty_station_code;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Data_1';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_data1;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Data_2';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_data2;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Data_3';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_data3;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Data_4';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_data4;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Agency_Data_5';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.agency_data5;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Approval_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.action_approval_date,'YYYY-MM-DD');
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Authorizer_Family_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.action_authr_family_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Authorizer_Given_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.action_authr_given_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Authorizer_Middle_Name';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.action_authr_middle_name;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Authorizer_Name_Suffix';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.action_authr_name_suffix;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Personnel_Action_Authorizer_Title';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.action_authr_title;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Remarks_Text';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.remarks_text;
		l_count := l_count+1;

		-- Bug 4714292 EHRI Reports Changes for EOY 05
		p_tags(l_count).tagname := 'Prior_Special_Rate_Supplement';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.from_spl_rate_supplement;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Special_Rate_Supplement';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.to_spl_rate_supplement;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Ethnicity_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.race_ethnic_info;
		l_count := l_count+1;
		-- End Bug 4714292 EHRI Reports Changes for EOY 05


		-- Bug 6158983
                p_tags(l_count).tagname := 'Citizenship_Country_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.world_citizenship;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Special_Population_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.special_population_code;
		l_count := l_count+1;

                p_tags(l_count).tagname := 'Appointment_Excluded_From_CSRS_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.csrs_exc_appts;
		l_count := l_count+1;

                p_tags(l_count).tagname := 'Appointment_Excluded_From_FERS_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fers_exc_appts;
		l_count := l_count+1;

                p_tags(l_count).tagname := 'FICA_Coverage_Indicator_1';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fica_coverage_ind1;
		l_count := l_count+1;

                p_tags(l_count).tagname := 'FICA_Coverage_Indicator_2';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fica_coverage_ind2;
		l_count := l_count+1;




		p_tags(l_count).tagname := 'Person_Action_Effective_Sequence';
		p_tags(l_count).tagvalue := nvl(g_eff_seq_no,1);
		l_count := l_count+1;



		p_tags(l_count).tagname := 'Hypothetical_Fulltime_Reg_Tour_Duty_Part_time_Employees';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.hyp_full_reg_duty_part_emp;
		l_count := l_count+1;

  	        p_tags(l_count).tagname := 'FEGLI_Assignment_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fegli_assg_indicator;
		l_count := l_count+1;

  	        p_tags(l_count).tagname := 'FEGLI_Post_Election_Basic_Insurance_Amount';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fegli_post_elc_basic_ins_amt;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Court_Orders_for_FEGLI_Purposes_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fegli_court_ord_ind;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Designation_FEGLI_Beneficiaries_Indicator';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fegli_benf_desg_ind;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Federal_Employees_Health_Benefits_FEHB_Plan_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.health_plan;
		l_count := l_count+1;

   	        p_tags(l_count).tagname := 'Federal_Employees_Health_Benefits_FEHB_Event_Code';
		p_tags(l_count).tagvalue := p_cpdf_dynamic.fehb_event_code;
		l_count := l_count+1;

                p_tags(l_count).tagname := 'Federal_Employees_Health_Benefits_Effective_Date';
		p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_dynamic.fehb_elect_eff_date,'YYYY-MM-DD');
		l_count := l_count+1;


		--End Bug 6158983


	END WriteTagValues;

	-----------------------------------------------------------------------------
	-- Writing the records from PL/SQL table p_tags into XML File
	-----------------------------------------------------------------------------
	PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type, p_tags t_tags )
	IS
	BEGIN
		FOR l_tags IN p_tags.FIRST .. p_tags.LAST LOOP
			utl_file.put_line(p_l_fp,'<' || p_tags(l_tags).tagname || '>' || p_tags(l_tags).tagvalue || '</' || p_tags(l_tags).tagname || '>');
		END LOOP;
	END WriteXMLvalues;

	-----------------------------------------------------------------------------
	-- Writing the records from PL/SQL table p_tags into Text and FND Output File
	-----------------------------------------------------------------------------
	PROCEDURE WriteAsciivalues(p_l_fp utl_file.file_type,
								p_tags t_tags,
								p_gen_txt_file IN VARCHAR2)
	IS
	l_temp VARCHAR2(4000);
	l_tot NUMBER;
	BEGIN
	   l_tot := p_tags.COUNT;
	   IF l_tot > 0 THEN
	       FOR l_tags IN p_tags.FIRST .. p_tags.LAST LOOP
	           IF l_tags = l_tot THEN
  	               l_temp := p_tags(l_tags).tagvalue;
				   IF p_gen_txt_file = 'Y' THEN
		               utl_file.put_line(p_l_fp,l_temp);
					END IF;
			       fnd_file.put_line(fnd_file.output,l_temp);
	            ELSE
		 	       l_temp := p_tags(l_tags).tagvalue || '|';
				   IF p_gen_txt_file = 'Y' THEN
		               utl_file.put(p_l_fp,l_temp);
				   END IF;
			       fnd_file.put(fnd_file.output,l_temp);
				END IF;
  	       END LOOP;
  	    END IF;

	END WriteAsciivalues;

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
    AND    TRUNC(p_report_date) BETWEEN NVL(START_DATE_ACTIVE ,p_report_date)
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
  IF GET_SUFFIX%NOTFOUND THEN
     p_lname  := RTRIM(p_last_name,' ,.');
     p_suffix := NULL;
  ELSE
     p_lname  := RTRIM(SUBSTR(p_last_name, 0, l_suffix_pos-1),' ,.');
     p_suffix := SUBSTR(p_last_name,l_suffix_pos+1,l_total_len);
  END IF;
  CLOSE GET_SUFFIX;

 END get_suffix_lname;


 --8486208 Added new procedure
 PROCEDURE get_agencies_from_group(p_agency_group IN VARCHAR2,
                                  p_agencies_with_se OUT NOCOPY VARCHAR2,
				  p_agencies_without_se OUT NOCOPY VARCHAR2)
 IS
l_agencies_with_se varchar2(240);
l_agencies_without_se varchar2(240);
l_prev NUMBER;
l_next NUMBER;
l_no_of_char NUMBER;

BEGIN
  l_agencies_with_se := NULL;
  l_agencies_without_se := NULL;
  l_prev :=1;

  loop
  l_next := instr(p_agency_group,',',l_prev);
    if l_next = 0 then
       l_next := length(p_agency_group)+1;
    end if;
  l_no_of_char := l_next -l_prev;

  if l_no_of_char > 2 then
     if l_agencies_with_se is NULL then
        l_agencies_with_se := substr(p_agency_group,l_prev,l_no_of_char);
     else
        l_agencies_with_se := l_agencies_with_se||','||substr(p_agency_group,l_prev,l_no_of_char);
     end if;
  else
     if l_agencies_without_se is NULL then
        l_agencies_without_se := substr(p_agency_group,l_prev,l_no_of_char);
     else
        l_agencies_without_se := l_agencies_without_se||','||substr(p_agency_group,l_prev,l_no_of_char);
     end if;
  end if;
  if l_next > length(p_agency_group) then
     exit;
  end if;
  l_prev := l_next+1;
  end loop;

  p_agencies_with_se := l_agencies_with_se;
  p_agencies_without_se := l_agencies_without_se;

END;



	---------------------------------------------------------------------------------------------
	-- This is the procedure to populate values into the temporary table GHR_CPDF_TEMP
	---------------------------------------------------------------------------------------------
	--8486208 added new parameter Agency group
	PROCEDURE populate_ghr_cpdf_temp(p_agency     IN VARCHAR2
               	                  ,p_agency_group IN VARCHAR2
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

      -- Bug 4349372 changed per_people_f to per_all_people_f.

      --8486208
      l_agencies_with_se VARCHAR2(240);
      l_agencies_without_se VARCHAR2(240);

      CURSOR cur_get_pars(p_agencies_with_se in varchar2,
                          p_agencies_without_se in varchar2) IS
        SELECT par.*
        FROM   ghr_pa_requests par,
               per_all_people_f    per
	        --8486208 added for new parameter
        WHERE  ((p_agency is not null and NVL(par.agency_code,par.from_agency_code) LIKE p_agency)
	        OR
 	        (p_agencies_with_se is not null and INSTR(p_agencies_with_se,NVL(par.agency_code,par.from_agency_code),1) > 0)
		OR
		(p_agencies_without_se is not null and INSTR(p_agencies_without_se,substr(NVL(par.agency_code,par.from_agency_code),1,2),1) > 0)
	        )
        AND    par.person_id = per.person_id
        AND    trunc(par.sf50_approval_date) BETWEEN per.effective_start_date
                                      AND     per.effective_end_date
        AND    trunc(par.sf50_approval_date) BETWEEN p_start_date AND p_end_date
	--bug #6976546 removed 'FUTURE_ACTION'
        AND    par.status IN ('UPDATE_HR_COMPLETE')
        AND    par.effective_date >= add_months(p_end_date,-24)
        AND    par.effective_date <= add_months(p_end_date,6)
        AND    exclude_agency(NVL(par.agency_code,par.from_agency_code)) <> 'TRUE'
        AND    exclude_noac(par.first_noa_code,par.second_noa_code,par.noa_family_code) <> 'TRUE'
	AND    decode(hr_general.get_xbg_profile,'Y',per.business_group_id , hr_general.get_business_group_id) = per.business_group_id;
      --
      -- Cross Business Group if set to Yes, the pick all the records else pick BG related records.
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
--      l_ghr_cpdf_cancel_rec  ghr_cpdf_temp%ROWTYPE;

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

	-- Bug 	5011003
	l_locality_pay_area_code ghr_locality_pay_areas_f.locality_pay_area_code%type;
	l_equiv_plan ghr_pay_plans.equivalent_pay_plan%type;
	-- End Bug 	5011003
-- the following cursor can be used for dual purposes
-- can pass the exact eff date or the eff_date-1 to pick the prior details
--
  CURSOR cur_per_details( p_person_id per_all_people_f.person_id%type,
 			  p_eff_date  ghr_pa_requests.effective_date%TYPE)
  IS
  SELECT last_name, middle_names, first_name,title,business_group_id
  FROM   per_all_people_f
  WHERE  person_id = p_person_id
  AND    p_eff_date between effective_start_date and effective_end_date;

-- Bug 5010844
-- Cursor for getting authorization person details
CURSOR cur_approver_id(c_pa_request_id ghr_pa_requests.pa_request_id%type)
IS
SELECT user_name_employee_id approver_id
FROM ghr_pa_routing_history
WHERE pa_request_id = c_pa_request_id
AND approval_status = 'APPROVE'
AND action_taken IN ('UPDATE_HR','FUTURE_ACTION');

l_approver_id ghr_pa_routing_history.user_name_employee_id%type;
-- End Bug 5010844

-- Bug#5209089 Created the cursor.
CURSOR cur_poid_approver (c_poid VARCHAR2)
IS
SELECT person_id
FROM   ghr_pois
WHERE  personnel_office_id = c_poid;

--
-- This cursor can be used to pick the prior num, org details of that pos
--
CURSOR cur_prior_pos_org(p_position_id	hr_positions_f.position_id%TYPE,
			 p_eff_date	ghr_pa_requests.effective_date%TYPE)
IS
SELECT name
FROM   hr_organization_units
WHERE  organization_id = ( SELECT organization_id
			   FROM   hr_positions_f
			   WHERE  position_id=p_position_id
	  		   AND    p_eff_date between effective_start_date and effective_end_date);
--
CURSOR cur_pos_org(p_org_id	hr_organization_units.organization_id%TYPE,
  		   p_eff_date	ghr_pa_requests.effective_date%TYPE)
IS
SELECT name
FROM   hr_organization_units
WHERE  organization_id = p_org_id
AND    p_eff_date between date_from and NVL(date_to,to_Date('31/12/4712','DD/MM/YYYY'));
--
-- added date cond and other fields for ENW EHRI changes
--
  CURSOR cur_scd_dates(p_pa_request_id   ghr_pa_requests.pa_request_id%type)
  IS
  SELECT REI_INFORMATION3 rif ,REI_INFORMATION8 ret
  FROM   ghr_pa_request_extra_info parei
  WHERE  parei.pa_request_id=p_pa_request_id
  AND    parei.information_type='GHR_US_PAR_CHG_SCD';

    --BUG# 6458070 -- ssn corrected issue
  cursor cur_ssn_corr(p_altered_pa_request_id  ghr_pa_requests.altered_pa_request_id%type,
                      p_to_national_identifier ghr_pa_requests.employee_national_identifier%type)
      is
  SELECT employee_national_identifier
  FROM   ghr_pa_requests
  WHERE  pa_request_id = p_altered_pa_request_id
  AND    employee_national_identifier <> p_to_national_identifier;

 l_records_found	BOOLEAN;
 l_mesgbuff1            VARCHAR2(4000);
 l_scd_rif	        ghr_pa_request_extra_info.rei_information3%type;
 l_scd_retirement	ghr_pa_request_extra_info.rei_information8%type;
 l_scd_tsp		ghr_pa_request_extra_info.rei_information8%type;
 l_scd_leave 	        ghr_pa_request_extra_info.rei_information8%type;
 l_ehri_id              ghr_cpdf_temp.ehri_employee_id%TYPE;
 ll_per_ei_data		per_people_extra_info%rowtype;
 l_last_name        per_all_people.last_name%type;
 l_suffix           ghr_cpdf_temp.prior_name_suffix%type;

-- For Dual Actions PRD is becoming null so preserving it using a local variable.
l_pay_rate_determinant ghr_pa_requests.pay_rate_determinant%TYPE;
--
CURSOR cur_rem(p_pa_request_id	ghr_pa_requests.pa_request_id%TYPE)
IS
SELECT Description
FROM   ghr_pa_remarks
WHERE pa_request_id=p_pa_request_id;

l_dummy		VARCHAR2(250);
--
-- Bug# 6158983
l_value                VARCHAR2(250);
l_effective_start_date  date;
l_business_group_id    per_all_people.business_group_id%type;

-- Bug# 6158983

--6850492
cursor get_ord_of_proc(p_noa_code in varchar2,
                       p_effective_date in date)
    is
    select order_of_processing
    from   ghr_nature_of_actions
    where  code = p_noa_code
    and    p_effective_date between nvl(date_from, p_effective_date)
                            and     nvl(date_to,p_effective_date);
--6850492

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

BEGIN
    --
    l_records_found:=FALSE;
    -- hr_utility.trace_on(null,'venkat');
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    ghr_mto_int.set_log_program_name('ghr_ehri_dynrpt');
    --
IF p_end_date > p_start_Date THEN
    --8486208 added fot the ne wparameter
    if p_agency_group is not null then
      get_agencies_from_group(UPPER(p_agency_group),l_agencies_with_se, l_agencies_without_se);
    end if;
    FOR  cur_get_pars_rec IN cur_get_pars(p_agencies_with_se   => l_agencies_with_se,
                                          p_agencies_without_se => l_agencies_without_se)
    LOOP
        -- 1) Get PA Request data
        l_ghr_pa_requests_rec := cur_get_pars_rec;


        l_sf52_rec1           := l_ghr_pa_requests_rec;
        l_sf52_rec2           := l_ghr_pa_requests_rec;

	IF   l_ghr_pa_requests_rec.second_noa_code IS NOT NULL
	 AND l_ghr_pa_requests_rec.first_noa_code NOT IN ('001','002') THEN
	    l_loop       := 2;
            l_dual_flg   := TRUE;
            l_single_flg := FALSE;
        ELSE
            l_loop       := 1;
            l_single_flg := TRUE;
            l_dual_flg   := FALSE;
        END IF;

        /* If ( l_ghr_pa_requests_rec.first_noa_code like '3%'and
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

                -- Bug# 4648811 getting the suffix from the lastname and also removing suffix from lastname
                get_suffix_lname(l_ghr_pa_requests_rec.employee_last_name,
                                 l_ghr_pa_requests_rec.effective_date,
                                 l_suffix,
                                 l_last_name);

                l_ghr_pa_requests_rec.employee_last_name := l_last_name;
                --End Bug# 4648811

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
		-- Agency Subelement Code
		l_ghr_cpdf_temp_rec.to_national_identifier := format_ni(l_ghr_pa_requests_rec.employee_national_identifier);
		-- SSN
		-- SSN corrected
		IF (l_ghr_pa_requests_rec.first_noa_code = '002' AND
		    NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '1%') THEN
				--Bug# 6458070 added the below cursor to check whether ssn is corrected
		    --Bug# 6458070 added the below cursor to check whether ssn is corrected
		    for cur_ssn_corr_rec in cur_ssn_corr(l_ghr_pa_requests_rec.altered_pa_request_id,
		                                         l_ghr_pa_requests_rec.employee_national_identifier)
		    loop
		      l_ghr_cpdf_temp_rec.SSN_CORRECTED	:= format_ni(cur_ssn_corr_rec.employee_national_identifier);
		    end loop;
		END IF;
		--

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

 		-- All NOACS need to report details regarding the approval date, authorizer details etc.
		--7610341 added the following to consider effective date if approval date is greater than effective date
		IF l_ghr_pa_requests_rec.APPROVAL_DATE > l_ghr_pa_requests_rec.effective_date and l_ghr_pa_requests_rec.first_noa_code not in ('001','002') then
		   l_ghr_cpdf_temp_rec.ACTION_APPROVAL_DATE	 := l_ghr_pa_requests_rec.effective_date;
		else
		   l_ghr_cpdf_temp_rec.ACTION_APPROVAL_DATE	 := l_ghr_pa_requests_rec.APPROVAL_DATE;
		end if;

		-- 	5010844
        -- Setting l_approver_id to NULL to find the proper approver's name.
        l_approver_id := NULL;
		FOR l_cur_auth_id IN cur_approver_id(l_ghr_pa_requests_rec.pa_request_id) LOOP
			l_approver_id := l_cur_auth_id.approver_id;
		END LOOP;
        -- Bug#5209089 If Approver's ID is NULL in the pa_routing, the action may be a mass action.
        -- For mass actions pick the approver's ID from the approver name attached to the Personnel Office.
        IF l_approver_id IS NULL THEN
            FOR l_approver_rec IN cur_poid_approver(l_ghr_pa_requests_rec.personnel_office_id)
            LOOP
                l_approver_id := l_approver_rec.person_id;
            END LOOP;
        END IF;

		FOR auth_det IN cur_per_details(l_approver_id,
					   l_ghr_pa_requests_rec.effective_date)
		LOOP
		-- End Bug 	5010844
        -- Bug# 4648811 extracting suffix from the lastname and removing suffix from the lastname
            get_suffix_lname(auth_det.last_name,
                             l_ghr_pa_requests_rec.effective_date,
                             l_suffix,
                             l_last_name);
			l_ghr_cpdf_temp_rec.ACTION_AUTHR_FAMILY_NAME := l_last_name;
			l_ghr_cpdf_temp_rec.ACTION_AUTHR_GIVEN_NAME	 := auth_det.first_name;
			l_ghr_cpdf_temp_rec.ACTION_AUTHR_MIDDLE_NAME := auth_det.middle_names;
			l_ghr_cpdf_temp_rec.ACTION_AUTHR_NAME_SUFFIX := l_suffix;
        -- End Bug 	4648811


		END LOOP;

		l_ghr_cpdf_temp_rec.ACTION_AUTHR_TITLE	:= l_ghr_pa_requests_rec.sf50_approving_ofcl_work_title;

		-- Restricting Remarks to 2000 characters.
	    FOR rem_rec IN cur_rem(l_ghr_pa_requests_rec.pa_request_id)	LOOP
			l_ghr_cpdf_temp_rec.remarks_text := SUBSTR(l_ghr_cpdf_temp_rec.remarks_text||rem_rec.description,1,2000);
			IF LENGTH(l_ghr_cpdf_temp_rec.remarks_text) = 2000 THEN
				EXIT;
			END IF;
		END LOOP;
		--Begin Bug# 5444553
	l_ghr_cpdf_temp_rec.remarks_text := REPLACE(l_ghr_cpdf_temp_rec.remarks_text,fnd_global.local_chr(10),' ');
		--End Bug# 5444553

		---

		--- EHRI_EMPLOYEE_ID IS TO BE REPORTED FOR ALL THE EMPLOYEES AND FOR ALL RPA's
		---
                -- IF Cancellation THEN no more data elements are needed. Bug# 1375323
                -- Insert_row in GHR_CPDF_TEMP, and continue in the LOOP for the next PAR row.
    	        --- EHRI_EMPLOYEE_ID IS TO BE REPORTED FOR ALL THE EMPLOYEES AND FOR ALL RPA's
		--- esp for 001 action
		    BEGIN
                        get_PAR_EI_noac (l_ghr_pa_requests_rec.pa_request_id
                                        ,l_ghr_pa_requests_rec.first_noa_id
                                        ,l_ghr_pa_requests_rec.second_noa_id
                                        ,l_ghr_pa_requests_rec.noa_family_code
                                        ,l_ghr_pa_requests_rec.person_id
                                        ,l_ghr_pa_requests_rec.effective_date
                                        ,l_dummy
                                        ,l_dummy
                                        ,l_dummy
                                        ,l_dummy
                                        ,l_dummy
                                        ,l_dummy
                                        ,l_dummy
				        -- Added for new EHRI changes Madhuri 21-Jan-2005
					,l_dummy
					,l_dummy
		 		        ,l_dummy
				        ,l_ghr_cpdf_temp_rec.ehri_employee_id
					,l_dummy
					,l_dummy
	 			        ,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy
					,l_dummy);

                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_par_ei_noac';
                            l_log_text     := 'Error in fetching EHRI Employee id for pa_request_id: '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                            Raise EHRI_DYNRPT_ERROR;
                    END;

				-- Bug 5063301
		        --Birth Date
				l_ghr_cpdf_temp_rec.employee_date_of_birth := l_ghr_pa_requests_rec.employee_date_of_birth;  -- format in report
				-- End Bug 5063301

                IF l_ghr_pa_requests_rec.first_noa_code = '001' THEN
		    		insert_row(l_ghr_cpdf_temp_rec);
     		    	l_records_found:=TRUE;
                    GOTO end_par_loop;  -- loop for the next one!
                END IF;

                -- Obtain Family Code
                l_noa_family_code := l_ghr_pa_requests_rec.noa_family_code;
                IF l_noa_family_code = 'CORRECT' THEN
                    -- Bug#2789704 Added Exception Handling
                    -- Bug#5172710 Modified the function to determine the noa family code.
                    BEGIN
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

                        Raise EHRI_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                END IF;

			-- Moved POI to this place for bug# 1402287 to not print for Cancellations.
	        l_ghr_cpdf_temp_rec.personnel_office_id    := l_ghr_pa_requests_rec.personnel_office_id;
			-- Personnel Office Identifier Code
	        l_ghr_cpdf_temp_rec.employee_date_of_birth := l_ghr_pa_requests_rec.employee_date_of_birth;  -- format in report
		    --Birth Date
			l_ghr_cpdf_temp_rec.FEGLI		   := l_ghr_pa_requests_rec.FEGLI;
			l_ghr_cpdf_temp_rec.annuitant_indicator	   := l_ghr_pa_requests_rec.annuitant_indicator;
		    l_ghr_cpdf_temp_rec.veterans_preference    := l_ghr_pa_requests_rec.veterans_preference;
			l_ghr_cpdf_temp_rec.tenure                 := l_ghr_pa_requests_rec.tenure;
	        l_ghr_cpdf_temp_rec.service_comp_date      := l_ghr_pa_requests_rec.service_comp_date;       -- format in report
		    l_ghr_cpdf_temp_rec.retirement_plan        := l_ghr_pa_requests_rec.retirement_plan;
			-- Retirement System Type Code (retierment plan)


                   --Start of Bug #6158983
		        --start of Bug #6522440 adding one more validation of showing the hyp_full_reg_duty_part_emp
			-- only for part time employees
                    if l_ghr_pa_requests_rec.part_time_hours is not null then
		       if l_ghr_cpdf_temp_rec.retirement_plan in ('E','M','T') then
                         l_ghr_cpdf_temp_rec.hyp_full_reg_duty_part_emp := 72.00;
                       else
                         l_ghr_cpdf_temp_rec.hyp_full_reg_duty_part_emp := 80.00;
                       end if;
		    end if;

		   -- End of Bug #6158983




	        l_ghr_cpdf_temp_rec.veterans_status        := l_ghr_pa_requests_rec.veterans_status;
			l_ghr_cpdf_temp_rec.FLSA_category	   := l_ghr_pa_requests_rec.FLSA_category;

			IF (l_ghr_pa_requests_rec.VETERANS_PREF_FOR_RIF in ('P','R') ) THEN
				l_ghr_cpdf_temp_rec.VETERANS_PREF_FOR_RIF  := 'Y';
			ELSIF (l_ghr_pa_requests_rec.VETERANS_PREF_FOR_RIF = 'N') THEN
				l_ghr_cpdf_temp_rec.VETERANS_PREF_FOR_RIF  := 'N';
			ELSE
				l_ghr_cpdf_temp_rec.VETERANS_PREF_FOR_RIF  := 'NA';
			END IF;

		 --  APPOINTMENT_NTE_DATE
		 BEGIN

		 get_asg_details( l_ghr_pa_requests_rec.pa_request_id,
		 	          l_ghr_pa_requests_rec.person_id,
			          l_ghr_pa_requests_rec.effective_date,
				  l_ghr_cpdf_temp_rec.appointment_nte_date);

		 EXCEPTION
		 WHEN OTHERS THEN
		 l_message_name := 'get_asg_details';
                        l_log_text     := 'Error in getting appointment_nte_date for pa_request_id: '||
                                          l_ghr_pa_requests_rec.pa_request_id ||
                                          ' ;  SSN/employee last name' ||
                                          l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                          l_ghr_pa_Requests_rec.employee_last_name ||
                                          ' ; first NOAC/Second NOAC: '||
                                          l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                          l_ghr_pa_requests_rec.second_noa_code ||
                                          ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                        Raise EHRI_DYNRPT_ERROR;
		 END;

		--
              --Bug#5328177 Added the following conditions to report the incentive percentage, amount
              -- in the Award percentage(for noac 827) and award amount(for noacs 815,816,825) fields.
              IF l_ghr_pa_requests_rec.first_noa_code = '827' OR
                 l_ghr_pa_requests_rec.second_noa_code = '827' THEN
                  l_ghr_cpdf_temp_rec.award_percentage := l_ghr_pa_requests_rec.to_total_salary;
              ELSIF (l_ghr_pa_requests_rec.first_noa_code IN ('815','816','825') OR
                     l_ghr_pa_requests_rec.second_noa_code IN ('815','816','825')) AND
                     l_ghr_pa_requests_rec.award_amount IS NULL THEN
                 l_ghr_pa_requests_rec.award_amount   :=  l_ghr_pa_requests_rec.to_total_salary;
              END IF;


              --  IF l_noa_family_code = 'AWARD' THEN --BUG#5328177
	          IF l_noa_family_code IN ('AWARD','GHR_INCENTIVE') THEN

                    l_ghr_pa_requests_rec.to_pay_plan          := l_ghr_pa_requests_rec.from_pay_plan;
                    l_ghr_pa_requests_rec.to_occ_code          := l_ghr_pa_requests_rec.from_occ_code;
                    l_ghr_pa_requests_rec.to_grade_or_level    := l_ghr_pa_requests_rec.from_grade_or_level;
                    l_ghr_pa_requests_rec.to_step_or_rate      := l_ghr_pa_requests_rec.from_step_or_rate;
                    l_ghr_pa_requests_rec.to_basic_pay         := l_ghr_pa_requests_rec.from_basic_pay;
                    l_ghr_pa_requests_rec.to_pay_basis         := l_ghr_pa_requests_rec.from_pay_basis;
                    l_ghr_pa_requests_rec.to_locality_adj      := l_ghr_pa_requests_rec.from_locality_adj;
		            l_ghr_pa_requests_rec.to_total_salary      := l_ghr_pa_requests_rec.from_total_salary;
 	                l_ghr_pa_requests_rec.to_adj_basic_pay     := l_ghr_pa_requests_rec.from_adj_basic_pay;

                END IF;

                l_ghr_cpdf_temp_rec.to_pay_plan            := l_ghr_pa_requests_rec.to_pay_plan;
		        l_ghr_cpdf_temp_rec.to_occ_code            := l_ghr_pa_requests_rec.to_occ_code;
                l_ghr_cpdf_temp_rec.to_grade_or_level      := l_ghr_pa_requests_rec.to_grade_or_level;
                l_ghr_cpdf_temp_rec.to_step_or_rate        := l_ghr_pa_requests_rec.to_step_or_rate;
                l_ghr_cpdf_temp_rec.to_basic_pay           := l_ghr_pa_requests_rec.to_basic_pay;            -- format in report
                l_ghr_cpdf_temp_rec.to_pay_basis           := l_ghr_pa_requests_rec.to_pay_basis;
                l_ghr_cpdf_temp_rec.to_locality_adj        := l_ghr_pa_requests_rec.to_locality_adj;
		        l_ghr_cpdf_temp_rec.to_total_salary        := l_ghr_pa_requests_rec.to_total_salary;            -- format in report
	            l_ghr_cpdf_temp_rec.to_adj_basic_pay       := l_ghr_pa_requests_rec.to_adj_basic_pay;


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
	                    l_ghr_cpdf_temp_rec.to_occ_code            := l_ghr_pa_requests_rec.to_occ_code;
                    ELSE
                        l_ghr_cpdf_temp_rec.to_pay_rate_determinant := NULL;
                        l_ghr_cpdf_temp_rec.to_occ_code             := NULL;
                --
                        l_ghr_cpdf_temp_rec.to_pay_plan            := NULL;
                        l_ghr_cpdf_temp_rec.to_occ_code            := NULL;
                        l_ghr_cpdf_temp_rec.to_grade_or_level      := NULL;
                        l_ghr_cpdf_temp_rec.to_step_or_rate        := NULL;
                        l_ghr_cpdf_temp_rec.to_basic_pay           := NULL;
                        l_ghr_cpdf_temp_rec.to_pay_basis           := NULL;
                        l_ghr_cpdf_temp_rec.to_locality_adj        := NULL;
                        l_ghr_cpdf_temp_rec.to_total_salary        := NULL;
                        l_ghr_cpdf_temp_rec.to_adj_basic_pay       := NULL;
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
		            l_ghr_cpdf_temp_rec.part_time_hours        := l_ghr_pa_requests_rec.part_time_hours;
                    --- commented for bug# 2257630 as duty station code required for all NOA codes except for cancellation action
                    --        l_ghr_cpdf_temp_rec.to_duty_station_code   := format_ds(l_ghr_pa_requests_rec.duty_station_code);

                ELSE
                    l_ghr_cpdf_temp_rec.to_work_schedule := NULL;
       	            l_ghr_cpdf_temp_rec.part_time_hours  := NULL;
                END IF;

		--Start of BUG# 6631879

                  IF l_ghr_cpdf_temp_rec.to_work_schedule in ('I','J') then
               	      l_ghr_cpdf_temp_rec.part_time_hours := NULL;
                   ELSIF l_ghr_cpdf_temp_rec.to_work_schedule in ('F','G','B') then
                     IF l_ghr_cpdf_temp_rec.retirement_plan in ('E','M','T') then
              	        l_ghr_cpdf_temp_rec.part_time_hours := 144;
          	     ELSE
               	        l_ghr_cpdf_temp_rec.part_time_hours := 80;
               	     END IF;
                   END IF;
                   --End of BUG# 6631879

                l_ghr_cpdf_temp_rec.to_duty_station_code := format_ds(l_ghr_pa_requests_rec.duty_station_code);
                l_ghr_cpdf_temp_rec.position_occupied      := l_ghr_pa_requests_rec.position_occupied;
                l_ghr_cpdf_temp_rec.supervisory_status     := l_ghr_pa_requests_rec.supervisory_status;
		-- Supervisory Status

                l_ghr_cpdf_temp_rec.award_amount           := l_ghr_pa_requests_rec.award_amount;            -- format in report

                -- Added IF for bug# 1375342
		    IF NOT ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		          NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') in ('815','816','817','825','826','827',
				'840','841','842','843','844','845','846','847','848','849','878','879')
			     )
			OR
			l_ghr_pa_requests_rec.first_noa_code in ('815','816','817','825','826','827',
				'840','841','842','843','844','845','846','847','848','849','878','879')
			   )
		AND
                   NOT ( (l_ghr_pa_requests_rec.first_noa_code LIKE '2%' ) OR
		         (l_ghr_pa_requests_rec.first_noa_code ='002' and
                           NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '2%'
                          )
		       )
		THEN

                    l_ghr_cpdf_temp_rec.from_pay_plan          := l_ghr_pa_requests_rec.from_pay_plan;
                    l_ghr_cpdf_temp_rec.from_occ_code          := l_ghr_pa_requests_rec.from_occ_code;
                    l_ghr_cpdf_temp_rec.from_grade_or_level    := l_ghr_pa_requests_rec.from_grade_or_level;
                    l_ghr_cpdf_temp_rec.from_step_or_rate      := l_ghr_pa_requests_rec.from_step_or_rate;
                    l_ghr_cpdf_temp_rec.from_basic_pay         := l_ghr_pa_requests_rec.from_basic_pay;                 -- format in report
                    l_ghr_cpdf_temp_rec.from_pay_basis         := l_ghr_pa_requests_rec.from_pay_basis;
		    l_ghr_cpdf_temp_rec.from_total_salary      := l_ghr_pa_requests_rec.from_total_salary;
		    l_ghr_cpdf_temp_rec.from_adj_basic_pay     := l_ghr_pa_requests_rec.from_adj_basic_pay;
		END IF;

		-- NEW EHRI changes need these prior details
		-- Madhuri

                IF get_loc_pay_area_code(p_duty_station_id => l_ghr_pa_requests_rec.duty_station_id,
                                         p_effective_date => l_ghr_pa_requests_rec.effective_date) <> '99'  THEN
                    IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                       l_ghr_pa_requests_rec.first_noa_code NOT LIKE '1%' AND
                       (l_ghr_pa_requests_rec.first_noa_code NOT LIKE '2%' AND
                         (NVL(l_ghr_pa_requests_rec.first_noa_code,'@#') <> '002' OR
                          NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') NOT LIKE '2%'
                         )
                        ) THEN

			--7507154 added Incentive Family
                        IF ( l_noa_family_code NOT IN ('AWARD','GHR_INCENTIVE') or
                             (l_ghr_pa_requests_rec.first_noa_code ='885' or
                              NVL(l_ghr_pa_requests_rec.second_noa_code, '@#')='885') )
                        THEN
                                      --
                                      IF get_equivalent_pay_plan(NVL(l_retained_pay_plan, l_ghr_pa_requests_rec.from_pay_plan)) <> 'FW' THEN
                                          l_ghr_cpdf_temp_rec.from_locality_adj := NVL(l_ghr_pa_requests_rec.from_locality_adj, 0);
                                      ELSE
                                          l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
                                      END IF;
                          --

                        END IF;
                    ELSE
                        l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
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
                            END IF;
                    ELSE
                        l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
                    END IF;
                ELSE
		    -- 4163587 Loc pay is not reported for prior loc pay
		    -- NO NEED TO MAKE PRIOR LOC PAY ADJ NULL, as we are checking for current DS not prior DS
		    -- l_ghr_cpdf_temp_rec.from_locality_adj      := NULL;
                    l_ghr_cpdf_temp_rec.to_locality_adj        := NULL;
                END IF;

                IF NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '3%' OR
                         (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                          NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '3%'
                         )
                       ) AND
                   NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '4%' AND
                         (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                          NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '4%'
                         )
		       )
                THEN  -- Issue 20 4257213
	                l_ghr_cpdf_temp_rec.to_staffing_differential    := l_ghr_pa_requests_rec.to_staffing_differential;   -- format in report
		        l_ghr_cpdf_temp_rec.to_supervisory_differential := l_ghr_pa_requests_rec.to_supervisory_differential;-- format in report
			l_ghr_cpdf_temp_rec.to_retention_allowance      := l_ghr_pa_requests_rec.to_retention_allowance;         -- format in report
		ELSE
	                l_ghr_cpdf_temp_rec.to_staffing_differential    := NULL;
		        l_ghr_cpdf_temp_rec.to_supervisory_differential := NULL;
			l_ghr_cpdf_temp_rec.to_retention_allowance      := NULL;
		END IF;

                IF l_noa_family_code IN ('AWARD', 'OTHER_PAY','GHR_INCENTIVE') THEN -- Bug# 1400486  --GHR_INCENTIVE added for bug # 5328177
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

                                        Raise EHRI_DYNRPT_ERROR;
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

                                        Raise EHRI_DYNRPT_ERROR;
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

                                        Raise EHRI_DYNRPT_ERROR;
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

                                        Raise EHRI_DYNRPT_ERROR;
                            END;
                            -- Bug#2789704 Added Exception Handling
                        END IF;
                    END IF;
                END IF;

				-- Sundar Changes for education
				ghr_api.return_education_details(p_person_id  => l_ghr_pa_requests_rec.person_id,
                                     p_effective_date       => l_ghr_pa_requests_rec.effective_date,
                                     p_education_level      => l_ghr_cpdf_temp_rec.education_level,
                                     p_academic_discipline  => l_ghr_cpdf_temp_rec.academic_discipline,
                                     p_year_degree_attained => l_ghr_cpdf_temp_rec.year_degree_attained);
				-- End Sundar changes for education Commented below code

                -- Not worth getting any more detials if only counting!
--                IF not p_count_only THEN
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
					 -- Organizational Component Code
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

                            Raise EHRI_DYNRPT_ERROR;
                    END;
		    -- Getting appropriation code new EHRI CHanges.
		    BEGIN
			    get_appr_code(NVL(l_ghr_pa_requests_rec.to_position_id
                                         ,l_ghr_pa_requests_rec.from_position_id)
                                         ,l_ghr_pa_requests_rec.effective_date
                                         ,l_ghr_cpdf_temp_rec.APPROPRIATION_CODE);
					 -- Organizational Component Code
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_message_name := 'get_appr_code';
                            l_log_text     := 'Error in fetching Appropriation code for the position of : '||
                                              l_ghr_pa_requests_rec.pa_request_id ||
                                              ' ;  SSN/employee last name' ||
                                              l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
                                              l_ghr_pa_Requests_rec.employee_last_name ||
                                              ' ; first NOAC/Second NOAC: '||
                                              l_ghr_pa_requests_rec.first_noa_code || ' / '||
                                              l_ghr_pa_requests_rec.second_noa_code ||
                                              ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);

                        Raise EHRI_DYNRPT_ERROR;
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

                            Raise EHRI_DYNRPT_ERROR;
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
						  ,l_ghr_cpdf_temp_rec.rating_of_record_period_ends
                                                  ,l_ghr_cpdf_temp_rec.rating_of_record_period_starts);      -- format in report
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
                             Raise EHRI_DYNRPT_ERROR;

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
                                        ,l_ghr_cpdf_temp_rec.benefit_amount	                     -- format in report
				        -- Added for new EHRI changes Madhuri 21-Jan-2005
					,l_ghr_cpdf_temp_rec.leave_scd
					,l_ghr_cpdf_temp_rec.scd_ses
		 		        ,l_ghr_cpdf_temp_rec.scd_spcl_retire
				        ,l_ghr_cpdf_temp_rec.ehri_employee_id
					,l_ghr_cpdf_temp_rec.tsp_scd
					,l_ghr_cpdf_temp_rec.scd_rif
	 			        ,l_ghr_cpdf_temp_rec.scd_retirement
					,l_ghr_cpdf_temp_rec.AGENCY_USE_CODE_FIELD
					,l_ghr_cpdf_temp_rec.AGENCY_USE_TEXT_FIELD
					,l_ghr_cpdf_temp_rec.AGENCY_DATA1
					,l_ghr_cpdf_temp_rec.AGENCY_DATA2
					,l_ghr_cpdf_temp_rec.AGENCY_DATA3
					,l_ghr_cpdf_temp_rec.AGENCY_DATA4
					,l_ghr_cpdf_temp_rec.AGENCY_DATA5
					,l_ghr_cpdf_temp_rec.race_ethnic_info
					,l_ghr_cpdf_temp_rec.world_citizenship
					,l_ghr_cpdf_temp_rec.SPECIAL_POPULATION_CODE  -- 6312144 RPA - EIT Benefits related modifications
					,l_ghr_cpdf_temp_rec.CSRS_EXC_APPTS
					,l_ghr_cpdf_temp_rec.FERS_EXC_APPTS
                                        ,l_ghr_cpdf_temp_rec.FICA_COVERAGE_IND1
                                        ,l_ghr_cpdf_temp_rec.FICA_COVERAGE_IND2
                                        ,l_ghr_cpdf_temp_rec.fegli_assg_indicator
                                        ,l_ghr_cpdf_temp_rec.fegli_post_elc_basic_ins_amt
                                        ,l_ghr_cpdf_temp_rec.fegli_court_ord_ind
                                        ,l_ghr_cpdf_temp_rec.fegli_benf_desg_ind
                                        ,l_ghr_cpdf_temp_rec.fehb_event_code ); -- Bug 4724337 Race or National Origin changes
                                          --Bug#6158983 World Citizenship
					l_ehri_id  := l_ghr_cpdf_temp_rec.ehri_employee_id;


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

                            Raise EHRI_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling

                    -- Bug# 1375342
                    IF (l_ghr_pa_requests_rec.first_noa_code LIKE '2%' OR
                        (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                       NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '2%')) THEN

                        l_ghr_cpdf_temp_rec.creditable_military_service := NULL;
                        l_ghr_cpdf_temp_rec.from_retirement_coverage    := NULL;
                        l_ghr_cpdf_temp_rec.from_pay_plan               := NULL;
                        l_ghr_cpdf_temp_rec.from_occ_code               := NULL;
                        l_ghr_cpdf_temp_rec.from_grade_or_level    := NULL;
                        l_ghr_cpdf_temp_rec.from_step_or_rate      := NULL;
                        l_ghr_cpdf_temp_rec.from_basic_pay         := NULL;                 -- format in report
                        l_ghr_cpdf_temp_rec.from_pay_basis         := NULL;
                        l_ghr_cpdf_temp_rec.from_total_salary      := NULL;
                        l_ghr_cpdf_temp_rec.from_adj_basic_pay     := NULL;
                        l_ghr_cpdf_temp_rec.from_locality_adj      := NULL;

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

                            Raise EHRI_DYNRPT_ERROR;
                    END;
                    -- Bug#2789704 Added Exception Handling
                    --
                    -- 3.6) Get PRIOR Work Schedule and Pay Rate Determinant
                    --
                    IF NOT ( (l_ghr_pa_requests_rec.first_noa_code = '002' AND
		              NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '2%')
			      OR
			     l_ghr_pa_requests_rec.first_noa_code LIKE '2%'
			   )
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

		    IF (l_ghr_pa_requests_rec.first_noa_code IN ('817') OR
                          (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                           NVL(l_ghr_pa_requests_rec.second_noa_code, '@#')= '817')
			)
		    THEN
			l_ghr_cpdf_temp_rec.from_work_schedule := NULL;
			l_ghr_cpdf_temp_rec.from_pay_rate_determinant := NULL;
			l_ghr_cpdf_temp_rec.from_duty_station_code := NULL;
		    END IF;

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

                                Raise EHRI_DYNRPT_ERROR;
                        END;

                        -- bug#5328177 IF l_noa_family_code = 'AWARD' THEN
			IF l_noa_family_code IN ('AWARD','GHR_INCENTIVE') THEN
                            l_ghr_cpdf_temp_rec.to_pay_rate_determinant   := l_ghr_cpdf_temp_rec.from_pay_rate_determinant;
                            l_ghr_cpdf_temp_rec.from_work_schedule := NULL;
                            l_ghr_cpdf_temp_rec.from_pay_rate_determinant := NULL;
                            l_ghr_cpdf_temp_rec.from_duty_station_code := NULL;

                             -- NULL OUT THESE FIELDS FOR AWARDS
                            l_ghr_cpdf_temp_rec.from_pay_plan          := NULL;
                            l_ghr_cpdf_temp_rec.from_occ_code          := NULL;
                            l_ghr_cpdf_temp_rec.from_grade_or_level    := NULL;
                            l_ghr_cpdf_temp_rec.from_step_or_rate      := NULL;
                            l_ghr_cpdf_temp_rec.from_basic_pay         := NULL;                 -- format in report
                            l_ghr_cpdf_temp_rec.from_pay_basis         := NULL;
                            l_ghr_cpdf_temp_rec.from_total_salary      := NULL;
                            l_ghr_cpdf_temp_rec.from_adj_basic_pay     := NULL;

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

                            Raise EHRI_DYNRPT_ERROR;
                    END;

--                END IF; -- end of popluation of full record if not count_only
                --

--
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
		    l_ghr_cpdf_temp_rec.ehri_employee_id	:= l_ehri_id;
			-- Bug 	5010784
-- 		    l_ghr_cpdf_temp_rec.bargaining_unit_status  := l_ghr_pa_requests_rec.bargaining_unit_status;
 		    l_ghr_cpdf_temp_rec.bargaining_unit_status  := SUBSTR(l_ghr_pa_requests_rec.bargaining_unit_status,
															LENGTH(l_ghr_pa_requests_rec.bargaining_unit_status)-3);
		    --	End Bug 5010784

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
		    l_ghr_cpdf_temp_rec.ehri_employee_id := l_ehri_id;
--                    l_ghr_cpdf_temp_rec.employee_date_of_birth := NULL;
                    --        GOTO end_par_loop;
                END IF;

		    IF l_ghr_pa_requests_rec.first_noa_code <> '001' AND
                       NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '3%' AND
                             (l_ghr_pa_requests_rec.first_noa_code = '002' AND
                               NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '3%'
                             )
                           ) AND
                       NOT (l_ghr_pa_requests_rec.first_noa_code LIKE '4%' AND
                             (l_ghr_pa_requests_rec.first_noa_code = '002' OR
                               NVL(l_ghr_pa_requests_rec.second_noa_code, '@#') LIKE '4%'
                             )
			    ) THEN

 		       l_ghr_cpdf_temp_rec.position_title      := l_ghr_pa_requests_rec.to_position_title;
     		       l_ghr_cpdf_temp_rec.position_number     := l_ghr_pa_requests_rec.to_position_number;

  		        /*    FOR pos_org IN cur_pos_org(l_ghr_pa_requests_rec.to_organization_id,
		                                       l_ghr_pa_requests_rec.effective_date)
			    LOOP
			    l_ghr_cpdf_temp_rec.POSITION_ORG    := pos_org.name;
			    END LOOP;

				*/
				l_ghr_cpdf_temp_rec.POSITION_ORG := SUBSTR(l_ghr_pa_requests_rec.to_position_org_line1 ||
													' ' || l_ghr_pa_requests_rec.to_position_org_line2 ||
													' ' || l_ghr_pa_requests_rec.to_position_org_line3 ||
													' ' || l_ghr_pa_requests_rec.to_position_org_line4 ||
													' ' || l_ghr_pa_requests_rec.to_position_org_line5 ||
													' ' || l_ghr_pa_requests_rec.to_position_org_line6,1,500);
		    ELSE
     		       l_ghr_cpdf_temp_rec.position_title	:= NULL;
     		       l_ghr_cpdf_temp_rec.position_number	:= NULL;
					l_ghr_cpdf_temp_rec.POSITION_ORG	:= NULL;
			--
					l_ghr_cpdf_temp_rec.position_title	        	:= NULL;
                    l_ghr_cpdf_temp_rec.creditable_military_service	:= NULL;
 	                l_ghr_cpdf_temp_rec.from_retirement_coverage	:= NULL;
       	            l_ghr_cpdf_temp_rec.frozen_service		        := NULL;
		    END IF;

                     -- Bug # 8510442 Added 885 into the list to display award amount for 885 action

		    IF ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		          NVL(l_ghr_pa_requests_rec.second_noa_code,'@#') in ('815','816','817','818','819','825',
				'840','841','842','843','844','845','846','847','848','849','878','879','885')
			  )
			OR
			l_ghr_pa_requests_rec.first_noa_code in ('815','816','817','818','819','825',
				'840','841','842','843','844','845','846','847','848','849','878','879','885')
			)
                    THEN

		       IF NVL(l_ghr_pa_requests_rec.award_uom,'M')='M' THEN
			        l_ghr_cpdf_temp_rec.award_dollars := l_ghr_pa_requests_rec.award_amount;
		       END IF;
		       IF NVL(l_ghr_pa_requests_rec.award_uom,'M')='H' THEN
			        l_ghr_cpdf_temp_rec.award_hours := l_ghr_pa_requests_rec.award_amount;
		       END IF;
		       IF l_ghr_pa_requests_rec.award_percentage IS NOT NULL THEN
			        l_ghr_cpdf_temp_rec.award_percentage := l_ghr_pa_requests_rec.award_percentage;
		       END IF;

               /* COMMENTED this code as the similar code is added at line 2545 to resolve the
               issue of non-printing the to total salary.
               -- Bug#5328177 Added NOA Codes 815,816 as they also belongs to the same category.
               -- Bug#3941541,5168358 Separation Incentive Changes.
               -- If the Award Dollars value is NOT NULL, Assume that 825 is processed as Award.
               -- Otherwise, it is processed as Incentive.
               IF (l_ghr_pa_requests_rec.first_noa_code IN ('815','816','825') OR
                   l_ghr_pa_requests_rec.second_noa_code IN ('815','816', '825')) AND
                   l_ghr_cpdf_temp_rec.award_dollars IS NULL THEN
                   l_ghr_cpdf_temp_rec.award_dollars := l_ghr_pa_requests_rec.to_total_salary;
                  l_ghr_cpdf_temp_rec.to_total_salary := NULL;
               END IF;
               -- End of Bug#3941541,5168358
                */
			-- DONT report if AWARD or 3xx,4xx actions
                l_ghr_cpdf_temp_rec.creditable_military_service := NULL;
 		        l_ghr_cpdf_temp_rec.from_retirement_coverage	:= NULL;
       	        l_ghr_cpdf_temp_rec.frozen_service		:= NULL;

		    END IF;

		    -- New EHRI changes MADHURI
		    IF (
		        NOT( (l_ghr_pa_requests_rec.first_noa_code='002' and
		           l_ghr_pa_requests_rec.second_noa_code LIKE '1%')
			    OR
			   l_ghr_pa_requests_rec.first_noa_code  LIKE '1%' )
		        AND
			NOT ( (l_ghr_pa_requests_rec.first_noa_code='002' and
		           l_ghr_pa_requests_rec.second_noa_code  LIKE '2%')
			    OR
			   l_ghr_pa_requests_rec.first_noa_code  LIKE '2%' )
		       )
		     THEN

		     IF ( (l_ghr_pa_requests_rec.first_noa_code='002' and
   		          l_ghr_pa_requests_rec.second_noa_code = '780')
			  OR
			  l_ghr_pa_requests_rec.first_noa_code='780'
			 ) THEN
			--
			-- Prior Names  ONLY FOR NAME CHANGE


			FOR prior_per_rec IN cur_per_details(l_ghr_pa_requests_rec.person_id,
							     (l_ghr_pa_requests_rec.effective_date-1) )
			LOOP
           -- Bug# 4648811 extracting suffix from the lastname and removing suffix from the lastname
             get_suffix_lname(prior_per_rec.last_name,
                              l_ghr_pa_requests_rec.effective_date-1,
                              l_suffix,
                              l_last_name);
			 l_ghr_cpdf_temp_rec.PRIOR_FAMILY_NAME     := l_last_name;
			 l_ghr_cpdf_temp_rec.PRIOR_GIVEN_NAME      := prior_per_rec.first_name;
			 l_ghr_cpdf_temp_rec.PRIOR_MIDDLE_NAME     := prior_per_rec.middle_names;
			 l_ghr_cpdf_temp_rec.PRIOR_NAME_SUFFIX     := l_suffix;
           --End Bug# 4648811
			END LOOP;

            END IF;

		    IF NOT ( (l_ghr_pa_requests_rec.first_noa_code='002' and
   		              l_ghr_pa_requests_rec.second_noa_code = '817')
			  OR
			     l_ghr_pa_requests_rec.first_noa_code='817'
			   ) THEN
			-- Dont report these items for 817 action
			--
    			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_TITLE  := l_ghr_pa_requests_rec.from_position_title;
			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_NUMBER := l_ghr_pa_requests_rec.from_position_number;
			    --
/*	                    FOR prior_pos_org IN cur_prior_pos_org(l_ghr_pa_requests_rec.from_position_id,
			                                           (l_ghr_pa_requests_rec.effective_date-1) )
			    LOOP
			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_ORG    := prior_pos_org.name;
			    END LOOP; */
				l_ghr_cpdf_temp_rec.PRIOR_POSITION_ORG := SUBSTR(l_ghr_pa_requests_rec.from_position_org_line1 ||
													' ' || l_ghr_pa_requests_rec.from_position_org_line2 ||
													' ' || l_ghr_pa_requests_rec.from_position_org_line3 ||
													' ' || l_ghr_pa_requests_rec.from_position_org_line4 ||
													' ' || l_ghr_pa_requests_rec.from_position_org_line5 ||
													' ' || l_ghr_pa_requests_rec.from_position_org_line6,1,500);

		    ELSE
			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_TITLE  := NULL;
			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_NUMBER := NULL;
			    l_ghr_cpdf_temp_rec.PRIOR_POSITION_ORG    := NULL;
 		    END IF;
		    --
		    END IF; --- NOT APPOINTMENT ACTION OR RETURN TO DUTY

		    l_ghr_cpdf_temp_rec.position_number		 := l_ghr_pa_requests_rec.to_position_number;

		    -- NEW EHRI CHANGES MADHURI
		    --
		     -- Displaying names for correction of 817 modified the if condition for 002 of 817
		    IF NOT((l_ghr_pa_requests_rec.first_noa_code='002' AND l_ghr_pa_requests_rec.second_noa_code = '817')
		            OR
 		           (l_ghr_pa_requests_rec.first_noa_code = '817')) THEN
			l_ghr_cpdf_temp_rec.employee_last_name    := format_name_ehri(l_ghr_pa_requests_rec.employee_last_name);
    			l_ghr_cpdf_temp_rec.employee_first_name   := format_name_ehri(l_ghr_pa_requests_rec.employee_first_name);
    			l_ghr_cpdf_temp_rec.employee_middle_names := format_name_ehri(l_ghr_pa_requests_rec.employee_middle_names);
			-- Added format_name_ehri for EHRI changes.
			 FOR per_det IN cur_per_details(l_ghr_pa_requests_rec.person_id,
			 			        l_ghr_pa_requests_rec.effective_date)
			 LOOP
            -- Bug# 4648811 extracting suffix from the lastname and removing suffix from the lastname
               get_suffix_lname(per_det.last_name,
                                l_ghr_pa_requests_rec.effective_date,
                                l_suffix,
                                l_last_name);
			   l_ghr_cpdf_temp_rec.name_title	  := l_suffix;
             -- End Bug# 4648811
 			 END LOOP;



			 FOR scd_dates IN cur_scd_dates(l_ghr_pa_requests_rec.pa_request_id)
			 LOOP
		            l_ghr_cpdf_temp_rec.SCD_rif        := fnd_date.canonical_to_date(scd_dates.rif);
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

                         Raise EHRI_DYNRPT_ERROR;
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
						  l_ghr_pa_requests_rec.second_noa_code = '825' ) THEN
					 l_ghr_cpdf_temp_rec.to_pay_plan            := l_ghr_pa_requests_rec.from_pay_plan;
					 l_ghr_cpdf_temp_rec.to_occ_code            := l_ghr_pa_requests_rec.from_occ_code;
					 l_ghr_cpdf_temp_rec.to_grade_or_level      := l_ghr_pa_requests_rec.from_grade_or_level;
					 l_ghr_cpdf_temp_rec.to_step_or_rate        := l_ghr_pa_requests_rec.from_step_or_rate;
					 l_ghr_cpdf_temp_rec.to_basic_pay           := l_ghr_pa_requests_rec.from_basic_pay;            -- format in report
					 l_ghr_cpdf_temp_rec.to_pay_basis           := l_ghr_pa_requests_rec.from_pay_basis;
			                 --
					 l_ghr_pa_requests_rec.to_locality_adj      := l_ghr_pa_requests_rec.from_locality_adj;
					 l_ghr_pa_requests_rec.to_total_salary      := l_ghr_pa_requests_rec.from_total_salary;
			 	     l_ghr_pa_requests_rec.to_adj_basic_pay     := l_ghr_pa_requests_rec.from_adj_basic_pay;

					 l_ghr_cpdf_temp_rec.to_pay_rate_determinant:= l_ghr_pa_requests_rec.pay_rate_determinant;
					 l_ghr_cpdf_temp_rec.position_title         := l_ghr_pa_requests_rec.from_position_title;
				 END IF;

				IF  NOT (l_ghr_pa_requests_rec.first_noa_code like '3%'
				          OR ( l_ghr_pa_requests_rec.first_noa_code = '002' and
						  l_ghr_pa_requests_rec.first_noa_code like '3%' ) )
				AND
                                    NOT (l_ghr_pa_requests_rec.first_noa_code like '4%'
				          OR ( l_ghr_pa_requests_rec.first_noa_code = '002' and
						  l_ghr_pa_requests_rec.first_noa_code like '4%' ) )
				AND
                                    NOT (l_ghr_pa_requests_rec.first_noa_code = '817'
				          OR ( l_ghr_pa_requests_rec.first_noa_code = '002' and
						  l_ghr_pa_requests_rec.first_noa_code = '817' ) )
												  THEN
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
										 Raise EHRI_DYNRPT_ERROR;
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
									 Raise EHRI_DYNRPT_ERROR;
					 END;

				  END IF;
				END IF;
				 --Pradeep end of Bug 3953500

-- 3327389 Bug fix start
-- CPDF Reporting changes to include Creditable Military Service, Frozen Service and Prev Retirement Coverage
-- including the NOACS 800 and 782 inspite they are optional for reporting
-- as they will be anyways filtered under exclude_noacs
		BEGIN

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

		    l_ghr_cpdf_temp_rec.creditable_military_service:= ll_per_ei_data.pei_information5;
	 	    ll_per_ei_data :=NULL;

		    ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_SEPARATE_RETIRE',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			  );
		   l_ghr_cpdf_temp_rec.from_retirement_coverage := ll_per_ei_data.pei_information4;
 		   l_ghr_cpdf_temp_rec.Frozen_service:= ll_per_ei_data.pei_information5;

		   ll_per_ei_data:=NULL;
		END IF;

		-- Bug 4714292 EHRI Reports Changes for EOY 05
		IF l_ghr_cpdf_temp_rec.from_pay_rate_determinant IN ('5','6','E','F') THEN
				l_ghr_cpdf_temp_rec.from_spl_rate_supplement := l_ghr_cpdf_temp_rec.from_locality_adj;
				l_ghr_cpdf_temp_rec.from_locality_adj := NULL;
		END IF;

		IF l_ghr_cpdf_temp_rec.to_pay_rate_determinant IN ('5','6','E','F') THEN
				l_ghr_cpdf_temp_rec.to_spl_rate_supplement := l_ghr_cpdf_temp_rec.to_locality_adj;
				l_ghr_cpdf_temp_rec.to_locality_adj := NULL;
		END IF;

		-- End Bug 4714292 EHRI Reports Changes for EOY 05

		-- If Ethnicity is reported, RNO should be null
	      IF l_ghr_cpdf_temp_rec.race_ethnic_info IS NOT NULL THEN
	      	l_ghr_cpdf_temp_rec.race_national_origin := NULL;
	      END IF;

		  -- Bug 5011003
		  l_locality_pay_area_code := get_loc_pay_area_code(p_duty_station_id => l_ghr_pa_requests_rec.duty_station_id,
                                         p_effective_date => l_ghr_pa_requests_rec.effective_date);
		  l_equiv_plan := get_equivalent_pay_plan(NVL(l_retained_pay_plan, l_ghr_pa_requests_rec.to_pay_plan));

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

		  END IF; -- IF PRD IN ('3', 'J', 'K', 'U',

		-- For Prior locality pay
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

		 END IF; -- IF PRD IN ('3', 'J', 'K', 'U',

		  -- End Bug 5011003

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
           IF l_ghr_pa_requests_rec.first_noa_code <> '001' THEN
			  IF l_ghr_cpdf_temp_rec.from_retirement_coverage IS NULL THEN
				l_ghr_cpdf_temp_rec.from_retirement_coverage:= 'NA';
		          ELSIF l_ghr_cpdf_temp_rec.from_retirement_coverage IN ('P','R') THEN  --bug#5184157 yogi
			        l_ghr_cpdf_temp_rec.from_retirement_coverage:= 'Y';
			    END IF;
	   ELSE
				l_ghr_cpdf_temp_rec.from_retirement_coverage := NULL;
	   END If;


          --Bug #6158983 EHRI Status and Dynamic Report Changes
           BEGIN

	    FOR bus_grp_rec in cur_per_details(l_ghr_pa_requests_rec.person_id,
  	                                       l_ghr_pa_requests_rec.effective_date)
            LOOP
              l_business_group_id := bus_grp_rec.business_group_id;
	    END LOOP;

            l_value := null;
	    l_effective_start_date := null;

            l_message_name := 'Fetch HB Pre Tax';
	     ghr_per_sum.get_element_details
		    (p_element_name          => 'Health Benefits Pre tax'
		    ,p_input_value_name      => 'Health Plan'
		    ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
		    ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
  		    ,p_value                 => l_value
  		    ,p_effective_start_date =>  l_effective_start_date
                    ,p_business_group_id    =>  l_business_group_id);

            l_ghr_cpdf_temp_rec.health_plan := l_value;
	    l_ghr_cpdf_temp_rec.fehb_elect_eff_date := l_effective_start_date;
          -- Reporting  Plan + Enrollment as Health Plan.
            l_message_name := 'Fetch HB Pre Tax Enroll';

            l_value := null;
	    l_effective_start_date := null;
            ghr_per_sum.get_element_details
		    (p_element_name          => 'Health Benefits Pre tax'
		    ,p_input_value_name      => 'Enrollment'
		    ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
		    ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
  		    ,p_value                 => l_value
  		    ,p_effective_start_date  => l_effective_start_date
                    ,p_business_group_id     => l_business_group_id);


            l_ghr_cpdf_temp_rec.health_plan := l_ghr_cpdf_temp_rec.health_plan||l_value;

	    if l_ghr_cpdf_temp_rec.health_plan is Null then

              l_message_name := 'Fetch HB plan';
   	      ghr_per_sum.get_element_details
		    (p_element_name          => 'Health Benefits'
		    ,p_input_value_name      => 'Health Plan'
		    ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
		    ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
  		    ,p_value                 => l_value
  		    ,p_effective_start_date  => l_effective_start_date
                    ,p_business_group_id     => l_business_group_id);

            l_ghr_cpdf_temp_rec.health_plan := l_value;
	    l_ghr_cpdf_temp_rec.fehb_elect_eff_date := l_effective_start_date;
          -- Reporting  Plan + Enrollment as Health Plan.
            l_message_name := 'Fetch HB Enrollment';
            l_value := null;
	    l_effective_start_date := null;
            ghr_per_sum.get_element_details
		    (p_element_name          => 'Health Benefits'
		    ,p_input_value_name      => 'Enrollment'
		    ,p_assignment_id         => l_ghr_pa_requests_rec.employee_assignment_id
		    ,p_effective_date        => l_ghr_pa_requests_rec.effective_date
  		    ,p_value                 => l_value
  		    ,p_effective_start_date  => l_effective_start_date
                    ,p_business_group_id     => l_business_group_id);

            l_ghr_cpdf_temp_rec.health_plan := l_ghr_cpdf_temp_rec.health_plan||l_value;
	    end if;

  	   EXCEPTION
	     WHEN OTHERS THEN
		l_log_text     := 'Error in fetching data for Health Benefits for pa_request_id: '||
				 l_ghr_pa_requests_rec.pa_request_id ||
 			         ' ;  SSN/employee last name' ||
				 l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
				 l_ghr_pa_Requests_rec.employee_last_name ||
				' ; first NOAC/Second NOAC: '||
				 l_ghr_pa_requests_rec.first_noa_code || ' / '||
				 l_ghr_pa_requests_rec.second_noa_code ||
				 ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
				Raise EHRI_DYNRPT_ERROR;
  	     END;

            --- Bug 6312144 commented the below code as the below information will be fetched from RPA -- EIT's


	     /*BEGIN
	      ll_per_ei_data:=NULL;
	      l_message_name := 'Fetch Retirement System Info';
               ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_RETIRMENT_SYS_INFO',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			   );


               l_ghr_cpdf_temp_rec.SPECIAL_POPULATION_CODE := ll_per_ei_data.pei_information1;
               l_ghr_cpdf_temp_rec.CSRS_EXC_APPTS          := ll_per_ei_data.pei_information2;
               l_ghr_cpdf_temp_rec.FERS_EXC_APPTS          := ll_per_ei_data.pei_information3;
               l_ghr_cpdf_temp_rec.FICA_COVERAGE_IND1      := ll_per_ei_data.pei_information4;
               l_ghr_cpdf_temp_rec.FICA_COVERAGE_IND2      := ll_per_ei_data.pei_information5;
             EXCEPTION

	       WHEN OTHERS THEN

                 l_log_text     := 'Error in fetching data for Retirement System Information: '||
				 l_ghr_pa_requests_rec.pa_request_id ||
 			         ' ;  SSN/employee last name' ||
				 l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
				 l_ghr_pa_Requests_rec.employee_last_name ||
				' ; first NOAC/Second NOAC: '||
				 l_ghr_pa_requests_rec.first_noa_code || ' / '||
				 l_ghr_pa_requests_rec.second_noa_code ||
				 ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
				Raise EHRI_DYNRPT_ERROR;
     	      END;

              BEGIN
 	       ll_per_ei_data:=NULL;
               ghr_history_fetch.fetch_peopleei
			  (p_person_id          =>  l_ghr_pa_requests_rec.person_id,
			    p_information_type   =>  'GHR_US_PER_BENEFIT_INFO',
			    p_date_effective     =>  nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)),
		            p_per_ei_data        =>  ll_per_ei_data
			   );

               l_ghr_cpdf_temp_rec.FEGLI_ASSG_INDICATOR := ll_per_ei_data.pei_information16;
               l_ghr_cpdf_temp_rec.FEGLI_POST_ELC_BASIC_INS_AMT:= ll_per_ei_data.pei_information17;
               l_ghr_cpdf_temp_rec.FEGLI_COURT_ORD_IND := ll_per_ei_data.pei_information18;
               l_ghr_cpdf_temp_rec.FEGLI_BENF_DESG_IND := ll_per_ei_data.pei_information19;
               l_ghr_cpdf_temp_rec.FEHB_EVENT_CODE := ll_per_ei_data.pei_information20;

             EXCEPTION

	       WHEN OTHERS THEN

                 l_log_text     := 'Error in fetching data for Person Benefit Information: '||
				 l_ghr_pa_requests_rec.pa_request_id ||
 			         ' ;  SSN/employee last name' ||
				 l_ghr_pa_requests_rec.employee_national_identifier ||' / '||
				 l_ghr_pa_Requests_rec.employee_last_name ||
				' ; first NOAC/Second NOAC: '||
				 l_ghr_pa_requests_rec.first_noa_code || ' / '||
				 l_ghr_pa_requests_rec.second_noa_code ||
				 ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
				Raise EHRI_DYNRPT_ERROR;
     	      END;*/
            --bug #6416590 moving sf50_approval_date to pareq_last_updated_date
	    -- as sf50_approval_date has to be considered for ordering of sequence number
	    --with in effective date
         l_ghr_cpdf_temp_rec.pareq_last_updated_date := l_ghr_pa_requests_rec.sf50_approval_date;
	     --End of Bug#6158983

	     -- Bug # 6850492 added for dual actions need to order on basis of order of processing
	     -- as two actions will refer to same pa_request_id
	     for rec_ord_of_proc in get_ord_of_proc(p_noa_code => l_ghr_pa_requests_rec.first_noa_code,
	                                            p_effective_date => nvl(l_ghr_pa_requests_rec.effective_date,trunc(sysdate)))
	     loop
   	       l_ghr_cpdf_temp_rec.noac_order_of_processing := 	rec_ord_of_proc.order_of_processing;
	     end loop;



	insert_row(l_ghr_cpdf_temp_rec);
		l_records_found:=TRUE;
                --
		<<end_par_loop>>
		NULL;

            EXCEPTION
                WHEN EHRI_DYNRPT_ERROR THEN
                    hr_utility.set_location('Inside EHRI_DYNRPT_ERROR exception ',30);
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


---------------------------------------------------------------------------------------------
-- This is the Main procedure called from the concurrent program
---------------------------------------------------------------------------------------------


PROCEDURE ehri_dynamics_main
(     errbuf            OUT NOCOPY VARCHAR2
     ,retcode           OUT NOCOPY NUMBER
     ,p_report_name	IN VARCHAR2
     ,p_agency_code	IN VARCHAR2
     ,p_agency_subelement	IN VARCHAR2
     -- 8486208 Added new parameter
     ,p_agency_group      IN VARCHAR2
     ,p_start_date	IN VARCHAR2
     ,p_end_date	IN VARCHAR2
	 ,p_gen_xml_file IN VARCHAR2 DEFAULT 'N'
	 ,p_gen_txt_file IN VARCHAR2 DEFAULT 'Y'
)
IS
l_ascii_fname		varchar2(80);
l_xml_fname		varchar2(80);
l_count_only		BOOLEAN;
l_file_name VARCHAR2(500);
l_start_date DATE;
l_end_date DATE;
l_ret_code NUMBER;
l_invalid_filename EXCEPTION;
l_report_name VARCHAR2(500);
l_log_text             ghr_process_log.log_text%type;
l_message_name         ghr_process_log.message_name%type;

l_agency_subelement  VARCHAR2(30);

--
BEGIN
	l_report_name := p_report_name;
	-- Need to convert the dates from canonical to Date
	l_start_date  := fnd_date.canonical_to_date(p_start_date);
	l_end_date    := fnd_date.canonical_to_date(p_end_date);
	l_ret_code    := 0;
	 -- BUg # 8486208 added for new parameter agencies or agency subelements
	 IF p_agency_code is NOT NULL OR p_agency_group is NULL THEN
           IF p_agency_subelement IS NULL THEN
             l_agency_subelement := '%';
           ELSE
             l_agency_subelement := p_agency_subelement;
           END IF;
         END IF;
	--
	--8486208 added new parameter
	populate_ghr_cpdf_temp(p_agency_code||l_agency_subelement,p_agency_group,l_start_date,l_end_date,FALSE);
	-- Generate ASCII and XML files
	WritetoFile(l_report_name,p_gen_xml_file,p_gen_txt_file);

	-- Purge the table contents after reporting
	cleanup_table;
EXCEPTION
	WHEN OTHERS THEN
	           l_message_name := 'Unhandled Error';
                   l_log_text     := 'Unhandled Error under procedure ehri_dynamics_main'||
				     ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
                   ghr_mto_int.log_message(p_procedure => l_message_name,
                                           p_message   => l_log_text
                                            );
                    COMMIT;
END ehri_dynamics_main;

--
END ghr_ehri_dynrpt;

/
