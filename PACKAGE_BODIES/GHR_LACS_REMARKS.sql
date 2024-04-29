--------------------------------------------------------
--  DDL for Package Body GHR_LACS_REMARKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_LACS_REMARKS" AS
/* $Header: ghlacrem.pkb 120.13.12010000.2 2008/12/12 06:15:12 vmididho ship $ */
  g_requests_rec		ghr_pa_requests%ROWTYPE;
  g_position_id                ghr_pa_requests.from_position_id%TYPE;
  g_pay_plan                   ghr_pa_requests.from_step_or_rate%TYPE;
  g_step_or_rate               ghr_pa_requests.from_pay_plan%TYPE;
  g_grade_or_level             ghr_pa_requests.from_grade_or_level%TYPE;
  g_loc_percentage	       ghr_locality_pay_areas_f.adjustment_percentage%TYPE;
  -- Added for MSL expanded func
  g_pay_table_id               VARCHAR2(4);
  g_new_prd                    VARCHAR2(10);
  g_leo_posn_indicator         per_position_extra_info.poei_information16%TYPE;
  g_intl_posn_indicator        per_position_extra_info.poei_information15%TYPE; ---- variable declared for Bug#4130683
  g_equivalent_pay_plan        ghr_pay_plans.equivalent_pay_plan%TYPE;
  l_pos_extra_info_rec         per_position_extra_info%ROWTYPE;
  l_package                    VARCHAR2(30) := 'GHR_LACS_REMARKS';
  l_location                   VARCHAR2(200);

  PROCEDURE Fetch_Data(
     p_pa_request_id  ghr_pa_requests.pa_request_id%TYPE)
  IS
     l_grade_id            per_grades.grade_id%TYPE;
     l_assignment_id       per_assignments_f.assignment_id%TYPE;
     l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
     l_multi_error_flag    boolean;
     cursor c_grade_kff (grd_id number) is
             select gdf.segment1
                   ,gdf.segment2
               from per_grades grd,
                    per_grade_definitions gdf
              where grd.grade_id = grd_id
                and grd.grade_definition_id = gdf.grade_definition_id;
  BEGIN
    -- Fetch PA_REQUESTS Table
    l_location := 'Apply_894_Rules:Fetch_Data:Fetching PA_REQUESTS';
    SELECT *
      INTO g_requests_rec
      FROM ghr_pa_requests
     WHERE pa_request_id = p_pa_request_id;
    g_position_id :=  g_requests_rec.from_position_id;
    BEGIN
      l_location := 'Apply_894_Rules:Fetch_Data:' ||
                    '=>ghr_pc_basic_pay.get_retained_grade_details';
      l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
                                ( g_requests_rec.person_id,
                                  g_requests_rec.effective_date);
    EXCEPTION
      WHEN ghr_pay_calc.pay_calc_message THEN
        NULL;
    END;
    -- Bug#4901888

    IF l_retained_grade_rec.pay_plan IS NOT NULL THEN
      g_step_or_rate   := l_retained_grade_rec.step_or_rate;
      g_pay_plan       := l_retained_grade_rec.pay_plan;
      g_grade_or_level := l_retained_grade_rec.grade_or_level;
      g_pay_table_id   := SUBSTR(ghr_pay_calc.get_user_table_name(
                                  l_retained_grade_rec.user_table_id), 1, 4);
    ELSE
      l_location := 'Apply_894_Rules:Fetch_Data:Fetching Assignments';
      SELECT paf.assignment_id, paf.grade_id
        INTO l_assignment_id, l_grade_id
        FROM per_assignments_f paf
       WHERE paf.person_id = g_requests_rec.person_id
         AND paf.primary_flag = 'Y'
         AND paf.assignment_type <> 'B'
         AND g_requests_rec.effective_date BETWEEN
                paf.effective_start_date AND
                NVL(paf.effective_end_date,
                    g_requests_rec.effective_date+1);

      FOR c_grade_kff_rec IN c_grade_kff (l_grade_id)
      LOOP
         g_pay_plan          := c_grade_kff_rec.segment1;
         g_grade_or_level    := c_grade_kff_rec.segment2;
         EXIT;
      END LOOP;

      -- Fetch GHR_US_POS_VALID_GRADE information
      l_location := 'Apply_894_Rules:Fetch_Data:' ||
                    'Fetching GHR_US_POS_VALID_GRADE info';
      ghr_history_fetch.fetch_positionei
       (p_position_id      => g_position_id,
        p_information_type => 'GHR_US_POS_VALID_GRADE',
        p_date_effective   => g_requests_rec.effective_date,
        p_pos_ei_data      => l_pos_extra_info_rec);
      g_pay_table_id := SUBSTR(ghr_pay_calc.get_user_table_name(
                                l_pos_extra_info_rec.poei_information5), 1, 4);
    END IF;
    hr_utility.set_location('Pay Table ID Bef Calc Pay Table'||g_pay_table_id,10);
    -- Bug#4901888 Added the following IF condition to consider the Calculation
    --             pay table to determine the LAC/Remarks.(using TO PAY TABLE ID
    --             AS IT HOLDS THE CALC PAY TABLE ID).
    IF g_requests_rec.to_pay_table_identifier IS NOT NULL THEN
        g_pay_table_id := SUBSTR(ghr_pay_calc.get_user_table_name(
                                g_requests_rec.to_pay_table_identifier), 1, 4);
    END IF;
    hr_utility.set_location('Pay Table ID Aft Calc Pay Table'||g_pay_table_id,50);
    -- Bug#4901888 End
    l_location := 'Apply_894_Rules:Fetch_Data:Fetching Extra Information';
    -- Fetch GHR_US_POS_GRP2 information
    ghr_history_fetch.fetch_positionei
     (p_position_id      => g_position_id,
      p_information_type => 'GHR_US_POS_GRP2',
      p_date_effective   => g_requests_rec.effective_date,
      p_pos_ei_data      => l_pos_extra_info_rec);
    g_leo_posn_indicator := NVL(l_pos_extra_info_rec.poei_information16,'0');
    g_intl_posn_indicator := NVL(l_pos_extra_info_rec.poei_information15,'0'); -- variable for Bug#4130683
    -- Fetch Equivalent Pay Plan
    SELECT equivalent_pay_plan
      INTO g_equivalent_pay_plan
      FROM ghr_pay_plans
     WHERE pay_plan = g_pay_plan;

  END;

  PROCEDURE Apply_894_Rules(
     p_pa_request_id  ghr_pa_requests.pa_request_id%TYPE,
     p_new_prd        ghr_pa_requests.pay_rate_determinant%TYPE,
     p_old_prd        ghr_pa_requests.pay_rate_determinant%TYPE,
     p_out_step_or_rate GHR_PA_REQUESTS.TO_STEP_OR_RATE%TYPE,
     p_eo_nbr         VARCHAR2 := NULL,
     p_eo_date        DATE := NULL,
     p_opm_nbr        VARCHAR2 := NULL,
     p_opm_date       DATE := NULL,
     p_errbuf         IN OUT NOCOPY VARCHAR2,
     p_retcode        IN OUT NOCOPY NUMBER)
  IS
     l_la_code1                   ghr_pa_requests.first_action_la_code1%TYPE;
     l_la_code2                   ghr_pa_requests.first_action_la_code2%TYPE;
     l_la_desc1                   ghr_pa_requests.first_action_la_desc1%TYPE;
     --Bug#4256022 Declared l_la_desc1_out variable.
     l_la_desc1_out               ghr_pa_requests.first_action_la_desc1%TYPE;
     l_la_desc2                   ghr_pa_requests.first_action_la_desc2%TYPE;
     --Bug#4256022 Declared l_la_desc2_out variable.
     l_la_desc2_out               ghr_pa_requests.first_action_la_desc1%TYPE;
     l_insrt_value1                ghr_pa_requests.first_lac1_information1%TYPE;
     l_insrt_value2                ghr_pa_requests.first_lac1_information2%TYPE;
     l_retcode			  VARCHAR2(50) ; --For NOCOPY Changes
     l_errbuf			  NUMBER ;  --For NOCOPY Changes

     l_adj_bp                     ghr_pa_requests.from_adj_basic_pay%type;
     l_pay_cap_amount             ghr_pa_requests.from_adj_basic_pay%type;
     l_create_rmk                 BOOLEAN:=FALSE;
     l_remark_id                  ghr_pa_remarks.pa_remark_id%type;
     l_loc_area_id		  ghr_duty_Stations_f.locality_pay_area_id%type;
     l_loc_perc  		  ghr_locality_pay_areas_f.adjustment_percentage%TYPE;

     CURSOR cur_loc_area_id(p_ds_id	ghr_duty_Stations_f.duty_station_id%type,
			    p_eff_date  ghr_pa_requests.effective_date%type)
     IS
     SELECT   locality_pay_area_id
     FROM     ghr_duty_stations_f
     WHERE    duty_station_id=p_ds_id
     AND      p_eff_date between effective_start_date and effective_end_date;

     CURSOR cur_loc_perc
      (p_ds_loc_area_id	 ghr_duty_Stations_f.locality_pay_area_id%type,
       p_eff_date        ghr_pa_requests.effective_date%type)
     IS
      SELECT adjustment_percentage
      FROM   ghr_locality_pay_areas_f
      WHERE  locality_pay_area_id = p_ds_loc_area_id
      AND    p_eff_date between effective_start_date and effective_end_date;

     PROCEDURE Create_Remark(p_remark_code  in ghr_remarks.code%TYPE,
                             p_out_step_or_rate GHR_PA_REQUESTS.TO_STEP_OR_RATE%TYPE)
     IS
       l_remark_id           ghr_remarks.remark_id%TYPE;
       l_pa_remark_id        ghr_pa_remarks.pa_remark_id%TYPE;
       l_object_version_nbr  ghr_pa_remarks.object_version_number%TYPE;
       l_remark_desc         ghr_remarks.description%TYPE;
       l_remark_information1 ghr_pa_remarks.remark_code_information1%TYPE;
       l_remark_information2 ghr_pa_remarks.remark_code_information2%TYPE;
       l_remark_information3 ghr_pa_remarks.remark_code_information3%TYPE;
       l_remark_information4 ghr_pa_remarks.remark_code_information4%TYPE;
       l_remark_information5 ghr_pa_remarks.remark_code_information5%TYPE;
			--Pradeep added for the Bug#3974979.
       l_remark_desc_out     ghr_remarks.description%TYPE;

     BEGIN
       l_location := 'Apply_894_Rules:Create_Remark(' || p_remark_code || ')';
       ghr_mass_actions_pkg.get_remark_id_desc
         (p_remark_code       => p_remark_code,
          p_effective_date    => g_requests_rec.effective_date,
          p_remark_id         => l_remark_id,
          p_remark_desc       => l_remark_desc);

       l_remark_information1 := NULL;
       l_remark_information2 := NULL;
       l_remark_information3 := NULL;
       l_remark_information4 := NULL;
       l_remark_information5 := NULL;

       -- Remarks with Insertion Values
       IF p_remark_code IN ('X44','P81','P99','P70','P71','P07','P72','P92') THEN
         IF p_remark_code = 'X44' THEN
           l_remark_information1 := nvl(p_out_step_or_rate,g_step_or_rate);
           l_remark_information2 := g_pay_plan || '-' || g_grade_or_level;
         ELSIF p_remark_code = 'P70' THEN
           l_remark_information1 := TO_CHAR(g_requests_rec.to_retention_allowance);
         ELSIF p_remark_code = 'P71' THEN
           l_remark_information1 := TO_CHAR(g_requests_rec.to_staffing_differential);
         ELSIF p_remark_code = 'P72' THEN
           l_remark_information1 := TO_CHAR(g_requests_rec.to_supervisory_differential);
         -- GPPA Update 46
         ELSIF p_remark_code = 'P07' THEN
           l_remark_information1 := g_pay_table_id;
         --
         ELSIF p_remark_code = 'P81' THEN
           l_remark_information1 := TO_CHAR(g_requests_rec.to_au_overtime);
         ELSIF p_remark_code = 'P99' THEN
           l_remark_information1 := TO_CHAR(g_requests_rec.to_availability_pay);
         -- MSL expanded percentage
	 ELSIF p_remark_code = 'P92' THEN

	    FOR loc_area IN cur_loc_area_id(g_requests_rec.duty_station_id,
	  			            g_requests_rec.effective_date )
  	    LOOP
		l_loc_area_id	:= loc_area.locality_pay_area_id;

		-- Can find percentage only when there is percentage
		--
		FOR loc_perc IN cur_loc_perc(l_loc_area_id,g_requests_rec.effective_date )
		LOOP
	 	 l_loc_perc	  := loc_perc.adjustment_percentage;
		 g_loc_percentage := l_loc_perc;
		END LOOP;
	    END LOOP;
                 l_remark_desc := replace(l_remark_desc,'__',to_char(g_loc_percentage));

		-- HARD CODING for this remark only. replacing 2 hyphens with the percent
         END IF;
		--Pradeep commented l_remark_desc and added l_remark_desc_out for the Bug#3974979.
         ghr_mass_actions_pkg.replace_insertion_values
           (p_desc              => l_remark_desc,
            p_information1      => l_remark_information1,
            p_information2      => l_remark_information2,
            p_information3      => l_remark_information3,
            p_information4      => l_remark_information4,
            p_information5      => l_remark_information5,
            p_desc_out          => l_remark_desc_out
				);
			l_remark_desc := l_remark_desc_out;

       END IF;
       ghr_pa_remarks_api.create_pa_remarks
         (p_pa_request_id            => p_pa_request_id,
          p_remark_id                => l_remark_id,
          p_description              => l_remark_desc,
          p_remark_code_information1 => l_remark_information1,
          p_remark_code_information2 => l_remark_information2,
          p_remark_code_information3 => l_remark_information3,
          p_remark_code_information4 => l_remark_information4,
          p_remark_code_information5 => l_remark_information5,
          p_pa_remark_id             => l_pa_remark_id,
          p_object_version_number    => l_object_version_nbr);
     END;

  BEGIN
    p_retcode := 0;
    p_errbuf  := NULL;
    g_new_prd := p_new_prd;
    Fetch_Data(p_pa_request_id);
    -- 894 LAC/Remarks Rules
  IF g_requests_rec.first_noa_code = '894' THEN
      -- GS Equivalent Rules
      IF g_equivalent_pay_plan = 'GS' THEN
        l_location := 'Apply_894_Rules:GS Equivalent Plan Rules';
        IF g_pay_plan IN ('GS','GM','GH') AND
           p_new_prd  IN ('2','4')
        THEN
          l_la_code1 := 'QWM';
          l_la_code2 := 'ZLM';
        ELSIF g_pay_plan = 'GG' AND p_new_prd NOT IN ('U','V')THEN  ------and p_new_prd <> 'M' THEN
            -- Bug#4882715 Added the IF condition
            --IF g_leo_posn_indicator IN ('1','2') THEN
	    -- Bug#4130683 Changed the IF condition
	    IF g_intl_posn_indicator IN ('2') THEN
                l_la_code1 := 'UAM';
                l_la_code2 := 'ZLM';
            ELSE
                l_la_code1 := 'ZLM';
            END IF;
        -- Bug#4130683 Added on ELSEIF condition to include 'GL' pay plan
	ELSIF g_pay_plan = 'GL' THEN
	    IF p_new_prd NOT IN ('U','V') THEN
                IF g_intl_posn_indicator IN ('2') THEN
                    l_la_code1 := 'UAM';
                    l_la_code2 := 'ZLM';
                ELSE
                    l_la_code1 := 'ZTW';
		END IF;
            ELSIF g_intl_posn_indicator NOT IN ('2') THEN
	            l_la_code1 := 'ZTW';
	    END IF;
            -- Bug#4882715
        ELSIF g_pay_plan in ('CA','AA','AL') AND p_new_prd IN ('A','B','E','F') THEN
          l_la_code1 := 'ZLM';
        ELSIF g_pay_plan in ('CA','AA','AL') AND
              p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3','M','2','4') THEN
          l_la_code1 := 'ZLM';
        ELSIF g_pay_plan IN ('EX') AND
              p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3','M','2','4') AND
              g_pay_table_id = '0000'
        THEN
          l_la_code1 := 'ZLM';
        ELSIF g_pay_plan IN ('SL','ST','IP') AND
              p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3','M','2','4') AND
              g_pay_table_id = 'ESSL'
        THEN
          l_la_code1 := 'ZLM';
          l_la_code2 := 'ZLM';
        ELSE
          IF p_new_prd = 'M' THEN
            l_la_code1 := 'QHP';
            l_la_code2 := 'ZLM';
          ELSE
              l_la_code2 := 'ZLM';
              IF g_pay_table_id = '0000' THEN
                l_la_code1 := 'QWM';
              ELSIF g_pay_table_id <> '0491' THEN
                IF p_new_prd IN ('J','K','R','S','U','V','3') THEN
                  l_la_code1 := 'QJP';
                ELSE
                  l_la_code1 := 'QHP';
                END IF;
              END IF;
            IF g_leo_posn_indicator IN ('1','2') AND
                  g_pay_table_id = '0491'
            THEN
              l_la_code1 := 'ZTW';
              l_la_code2 := NULL;
            END IF;
          END IF;
        END IF;
      --Bug 5931199 added pay plan = FE condition as FE is nomore ES equ pay plan
      ELSIF g_equivalent_pay_plan = 'ES' OR g_pay_plan = 'FE' THEN -- ES Equivalent Rules
        l_location := 'Apply_894_Rules:ES Equivalent Plan Rules';

        IF g_pay_plan IN ('ES','EP','IE','FE') AND g_pay_table_id = 'ESSL' THEN
              l_la_code1 := 'VWZ';

                l_adj_bp := g_requests_rec.from_adj_basic_pay;

                      l_pay_cap_amount := ghr_pay_calc.get_standard_pay_table_value('EX'
                                                                   ,'02'
                                                                   ,'00'
                                                                   ,g_requests_rec.effective_date);

                      If l_adj_bp >= (l_pay_cap_amount * 86.5)/100 THEN
                              l_create_rmk :=TRUE;
                      ELSE
                              l_create_rmk :=FALSE;
                      END IF;

                      IF l_create_rmk THEN
                         Create_remark('M97',p_out_step_or_rate);
                      END IF;

        END IF;
      ELSIF g_equivalent_pay_plan = 'SL' THEN
        IF g_pay_plan IN ('SL','ST','IP') AND
              p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3','M','2','4') AND
              g_pay_table_id = 'ESSL'      THEN
          l_la_code1 := 'ZLM';
          l_la_code2 := 'ZLM';
        END IF;
      ELSIF g_equivalent_pay_plan = 'FW' THEN -- FWS Equivalent Rules
        l_location := 'Apply_894_Rules:FWS Equivalent Plan Rules';
        IF p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3') THEN
          l_la_code1 := 'FNM';
        ELSIF p_new_prd IN ('A','B','E','F') THEN
          l_la_code1 := 'FNM';
          l_la_code2 := 'VLJ';
        ELSIF p_new_prd IN ('J','K','R','S','U','V','3') THEN
          l_la_code1 := 'FNM';
          l_la_code2 := 'VSJ';
        END IF;
      END IF; -- Pay Plan Equivalent Rules

      --7636318
      IF  g_pay_plan IN ('IG') THEN
	  l_la_code1 := 'ZLM';
      END IF;
	  --7636318


      -- Insertion Values for LAC ZLM (EO Nbr or OPM Nbr will be used).
      -- Updated 11-SEP-1999: EO Nbr will be the only one used for Ins. Value
      l_location := 'Apply_894_Rules:Determining Insertion Value';
      IF l_la_code1 IN ('ZLM', 'UNM') OR l_la_code2 IN ('ZLM', 'UNM') THEN
        l_insrt_value1 := 'E.O. ' || p_eo_nbr || ', Dated ' ||
                         TO_CHAR(p_eo_date, 'DD-MON-YYYY');
        l_insrt_value2 := 'E.O. ' || p_eo_nbr || ', Dated ' ||
                         TO_CHAR(p_eo_date, 'DD-MON-YYYY');
      END IF;
      IF g_pay_plan IN ('SL','ST','IP') AND
              p_new_prd NOT IN ('A','B','E','F','U','V','J','K','R','S','3','M','2','4') AND
              g_pay_table_id = 'ESSL' THEN
              l_insrt_value1 := 'Reg. 534.504';
      END IF;

      IF p_retcode = 0 THEN
        IF l_la_code1 IS NOT NULL THEN -- Update GHR_PA_REQUESTS with new LACs
          l_location := 'Apply_894_Rules:Replacing Insertion Value';
          SELECT description
            INTO l_la_desc1
            FROM fnd_common_lookups fcl
           WHERE fcl.lookup_code = l_la_code1
             AND fcl.application_id = 800
             AND fcl.lookup_type = 'GHR_US_LEGAL_AUTHORITY'
             AND fcl.enabled_flag = 'Y'
             AND g_requests_rec.effective_date BETWEEN
                 NVL(fcl.start_date_active,
                     g_requests_rec.effective_date) AND
                 NVL(fcl.end_date_active, g_requests_rec.effective_date);
          IF l_la_code1 in ('ZLM','UNM')  THEN
	    -- Bug#4256022 Passed the variable l_la_desc1_out and assigned
	    -- the value back to l_la_desc1 to avoid NOCOPY related problems.
            ghr_mass_actions_pkg.replace_insertion_values
              (p_desc              => l_la_desc1,
               p_information1      => l_insrt_value1,
               p_desc_out          => l_la_desc1_out);
	       l_la_desc1 := l_la_desc1_out;
          END IF;
          IF l_la_code2 IS NOT NULL THEN
            SELECT description
              INTO l_la_desc2
              FROM fnd_common_lookups fcl
             WHERE fcl.lookup_code = l_la_code2
               AND fcl.application_id = 800
               AND fcl.lookup_type = 'GHR_US_LEGAL_AUTHORITY'
               AND fcl.enabled_flag = 'Y'
               AND g_requests_rec.effective_date BETWEEN
                   NVL(fcl.start_date_active,
                       g_requests_rec.effective_date) AND
                   NVL(fcl.end_date_active,
                       g_requests_rec.effective_date);
          END IF;
          IF l_la_code2 in ('ZLM','UNM')  THEN
	    -- Bug#4256022 Passed the variable l_la_desc2_out and
	    -- assigned the value back to l_la_desc2 to avoid NOCOPY related problems..
            ghr_mass_actions_pkg.replace_insertion_values
              (p_desc              => l_la_desc2,
               p_information1      => l_insrt_value2,
               p_desc_out          => l_la_desc2_out);
	       l_la_desc2 := l_la_desc2_out;
          END IF;
          l_location := 'Apply_894_Rules:Updating GHR_PA_REQUESTS';
          UPDATE GHR_PA_REQUESTS
             SET first_action_la_code1   = l_la_code1,
                 first_action_la_code2   = l_la_code2,
                 first_action_la_desc1   = l_la_desc1,
                 first_action_la_desc2   = DECODE(l_la_code2, NULL, NULL,
                                                l_la_desc2),
                 first_lac1_information1 = DECODE(l_la_code1, 'ZLM',
                                                  l_insrt_value1,'UNM',l_insrt_value1, NULL),
                 first_lac1_information2 = NULL,
                 first_lac1_information3 = NULL,
                 first_lac1_information4 = NULL,
                 first_lac1_information5 = NULL,
                 first_lac2_information1 = DECODE(l_la_code2, 'ZLM',
                                                  l_insrt_value2, NULL),
                 first_lac2_information2 = NULL,
                 first_lac2_information3 = NULL,
                 first_lac2_information4 = NULL,
                 first_lac2_information5 = NULL
          WHERE pa_request_id = p_pa_request_id;
          -- Create Remarks
          l_location := 'Apply_894_Rules:Creating Remarks';
          IF  (l_la_code1 in ('QHP','QJP') AND l_la_code2 = 'ZLM')  THEN
             Create_Remark('P05',p_out_step_or_rate);
             Create_Remark('P07',p_out_step_or_rate);
----          ELSIF p_new_prd IN ('6','E','F') then
----             Create_Remark('P05',p_out_step_or_rate);
          END IF;
          IF p_new_prd IN ('A','B','E','F') THEN
            Create_Remark('X44',p_out_step_or_rate);
          ELSIF   p_new_prd IN ('J','K','R','S','3') THEN
            Create_Remark('X40',p_out_step_or_rate);
          ELSIF p_new_prd IN ('U','V') THEN
              -- Bug#4130683 Added this IF condition for 'GL' pay plan
	      IF g_pay_plan IN ('GL') AND g_intl_posn_indicator NOT IN ('2') THEN
                  Create_Remark('X44',p_out_step_or_rate);
	      ELSE
	          Create_Remark('X40',p_out_step_or_rate);
                  Create_Remark('X44',p_out_step_or_rate);
	      END IF;
          END IF;
 /*       IF ((l_la_code1 = 'QWM' AND l_la_code2 = 'ZLM') OR
              (l_la_code1 = 'QHP' AND l_la_code2 = 'ZLM') OR
              (l_la_code1 = 'ZTW' AND l_la_code2 IS NULL) OR
              (l_la_code1 = 'ZLM' AND l_la_code2 IS NULL) OR
              (l_la_code1 = 'UNM' AND l_la_code2 IS NULL) OR
              (l_la_code1 = 'UAM' AND l_la_code2 = 'ZLM') OR
              (l_la_code1 = 'FNM' AND l_la_code2 = 'VLJ')) AND
             p_new_prd IN ('A','B','E','F')
          THEN
            Create_Remark('X44',p_out_step_or_rate);
          ELSIF ((l_la_code1 = 'QWM' AND l_la_code2 = 'ZLM') OR
                 (l_la_code1 = 'QJP' AND l_la_code2 = 'ZLM') OR
                 (l_la_code1 = 'ZTW' AND l_la_code2 IS NULL) OR
                 (l_la_code1 = 'UAM' AND l_la_code2 = 'ZLM') OR
                 (l_la_code1 = 'ZLM' AND l_la_code2 IS NULL) OR
                 (l_la_code1 = 'FNM' AND l_la_code2 = 'VSJ')) AND
                p_new_prd IN ('J','K','R','S','U','V','3')
          THEN
            Create_Remark('X40',p_out_step_or_rate);
          END IF;
          IF  ((l_la_code1 = 'QWM' AND l_la_code2 = 'ZLM') OR
               (l_la_code1 = 'QJP' AND l_la_code2 = 'ZLM') OR
               (l_la_code1 = 'FNM' AND l_la_code2 = 'VSJ')) AND
                p_new_prd IN ('U','V') THEN
             Create_Remark('X44',p_out_step_or_rate);
          END IF; */
        END IF;
        IF p_old_prd IN ('J','K','R','S','U','V','3')    AND
           p_new_prd NOT IN ('J','K','R','S','U','V','3')
          THEN
           -- Needs to be fixed to generate X42
           -- leaving it as X40 for the moment. 13-JAN-2001
           -- modified as X42 by AVR as of 18-JAN-2002
        Create_Remark('X42',p_out_step_or_rate);
        END IF;
        -- Create Extra Remarks depending on some element values
        IF g_requests_rec.to_auo_premium_pay_indicator IS NOT NULL AND
           g_requests_rec.to_au_overtime > 0
        THEN
          Create_Remark('P81',p_out_step_or_rate);
        END IF;
        IF g_requests_rec.to_ap_premium_pay_indicator IS NOT NULL AND
           g_requests_rec.to_availability_pay > 0
        THEN
          Create_Remark('P99',p_out_step_or_rate);
        END IF;
        -- Bug#5719467 Added the date condition to avoid P70 remark printing.
	l_location := 'Apply_894_Rules:Creating Remark P70';
        IF g_requests_rec.to_retention_allowance > 0 THEN
            IF g_requests_rec.effective_date < to_date('02/09/2006','DD/MM/YYYY') THEN
                Create_Remark('P70',p_out_step_or_rate);
            ELSE
                p_errbuf := 'Error: Retention Allowance not terminated. Terminate Retention Allowance and process the Pay Adjustment';
            END IF;
        END IF;
        IF g_requests_rec.to_staffing_differential > 0 THEN
          Create_Remark('P71',p_out_step_or_rate);
        END IF;
        IF g_requests_rec.to_supervisory_differential > 0 THEN
          Create_Remark('P72',p_out_step_or_rate);
        END IF;
        -- Calling USER HOOK
        l_location := 'Apply_894_Rules:Calling User-hook';
        ghr_agency_check.mass_salary_lacs_remarks(p_pa_request_id,
                                                  p_new_prd,
                                                  p_eo_nbr, p_eo_date,
                                                  p_opm_nbr, p_opm_date,
                                                  p_retcode, p_errbuf);

        IF p_retcode = 0 THEN
          -- Checking existence of LAC in GHR_PA_REQUESTS
          SELECT first_action_la_code1
            INTO l_la_code1
            FROM GHR_PA_REQUESTS
           WHERE pa_request_id = p_pa_request_id;
          IF l_la_code1 IS NULL THEN
            p_retcode := 2;
            p_errbuf  := 'Error in Apply_894_Rules: ' ||
                         'Legal Authority Code is NULL or No Default ' ||
                         'LACS were specified';
          END IF;
        END IF;
      END IF;

  --- ADDED for MSL Expaned functionality MADHURI
  ---
  ELSIF  g_requests_rec.first_noa_code = '895' THEN
        -- IF THE NOA CODE IS 895
        -- 894 LAC/Remarks Rules

--    IF g_requests_rec.first_la_action_code1 IS NULL THEN
    -- {
      IF g_leo_posn_indicator = 0 THEN
	      l_la_code1:='VGR';
      ELSIF g_leo_posn_indicator IN ('1','2') THEN
	      l_la_code1:='ZTX';
      END IF;
    -- }
--    END IF;

      IF l_la_code1 IS NOT NULL THEN
      -- {
         -- STAGE 1
         l_location := 'Apply_895_Rules:Replacing Insertion Value';

	   SELECT description
            INTO l_la_desc1
            FROM fnd_common_lookups fcl
           WHERE fcl.lookup_code = l_la_code1
             AND fcl.application_id = 800
             AND fcl.lookup_type = 'GHR_US_LEGAL_AUTHORITY'
             AND fcl.enabled_flag = 'Y'
             AND g_requests_rec.effective_date BETWEEN
                 NVL(fcl.start_date_active,
                     g_requests_rec.effective_date) AND
                 NVL(fcl.end_date_active, g_requests_rec.effective_date);
       END IF;

       BEGIN
	  -- STAGE 2
	  l_location := 'Apply_895_Rules:Updating GHR_PA_REQUESTS';

	  UPDATE GHR_PA_REQUESTS
             SET first_action_la_code1   = l_la_code1,
                 first_action_la_desc1   = l_la_desc1,
                 first_lac1_information1 = NULL,
                 first_lac1_information2 = NULL,
                 first_lac1_information3 = NULL,
                 first_lac1_information4 = NULL,
                 first_lac1_information5 = NULL
          WHERE pa_request_id = p_pa_request_id;
       -- }
       END;
      -- Create Remarks
      l_location := 'Apply_895_Rules:Creating Remarks';

      IF (p_new_prd = '6' and g_requests_rec.to_locality_adj=0) THEN
	Create_Remark('P93',p_out_step_or_rate);

      ELSIF ( (p_new_prd IN ('0','6') AND
               g_leo_posn_indicator in ('1','2') ) AND
                g_requests_rec.to_locality_adj=0
	    ) THEN
	Create_Remark('P95',p_out_step_or_rate);

      ELSIF ( p_new_prd IN ('M','P') AND
              g_requests_rec.to_locality_adj > 0
	    ) THEN
	Create_Remark('P96',p_out_step_or_rate);

      ELSE
        Create_Remark('P92',p_out_step_or_rate);

      END IF;
        -- Calling USER HOOK
        l_location := 'Apply_895_Rules:Calling User-hook';
        ghr_agency_check.mass_salary_lacs_remarks(p_pa_request_id,
                                                  p_new_prd,
                                                  p_eo_nbr, p_eo_date,
                                                  p_opm_nbr, p_opm_date,
                                                  p_retcode, p_errbuf);

        IF p_retcode = 0 THEN
          -- Checking existence of LAC in GHR_PA_REQUESTS
          SELECT first_action_la_code1
            INTO l_la_code1
            FROM GHR_PA_REQUESTS
           WHERE pa_request_id = p_pa_request_id;
          IF l_la_code1 IS NULL THEN
            p_retcode := 2;
            p_errbuf  := 'Error in Apply_895_Rules: ' ||
                         'Legal Authority Code is NULL or No Default ' ||
                         'LACS were specified';
          END IF;
        END IF;

    END IF; -- 894 LAC/Remarks Rules

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := 2;
      p_errbuf  := l_location;
  END;

  -- FWFA Changes Bug#4444609

  PROCEDURE apply_fwfa_rules( p_pa_request_id  GHR_PA_REQUESTS.PA_REQUEST_ID%TYPE,
                              p_noa_code       GHR_PA_REQUESTS.FIRST_NOA_CODE%TYPE,
			                  p_pay_plan       GHR_PA_REQUESTS.TO_PAY_PLAN%TYPE,
                              p_errbuf         IN OUT NOCOPY VARCHAR2,
                              p_retcode        IN OUT NOCOPY NUMBER
                              ) is
    l_la_code1                   ghr_pa_requests.first_action_la_code1%TYPE;
    l_la_code2                   ghr_pa_requests.first_action_la_code2%TYPE;
    l_la_desc1                   ghr_pa_requests.first_action_la_desc1%TYPE;
    l_la_desc1_out               ghr_pa_requests.first_action_la_desc1%TYPE;
    l_la_desc2                   ghr_pa_requests.first_action_la_desc2%TYPE;
    l_la_desc2_out               ghr_pa_requests.first_action_la_desc2%TYPE;
    l_insrt_value                ghr_pa_requests.first_lac1_information1%TYPE;

  BEGIN
    p_retcode := 0;
    p_errbuf  := NULL;

	IF p_noa_code = '800' THEN
		IF p_pay_plan <> 'GG' THEN
            l_la_code1 := 'CGM';
        END IF;
	ELSIF p_noa_code = '894' THEN
        IF p_pay_plan <> 'GG' THEN
            l_la_code1 := 'ZLM';
        ELSE
            l_la_code1 := 'UAM';
            l_la_code2 := 'ZLM';
        END IF;
	END IF;

    l_la_desc1 := ghr_pa_requests_pkg.get_lookup_description(800,'GHR_US_LEGAL_AUTHORITY',l_la_code1);
    l_la_desc2 := ghr_pa_requests_pkg.get_lookup_description(800,'GHR_US_LEGAL_AUTHORITY',l_la_code2);

    IF (l_la_code1 = 'ZLM') THEN
      l_insrt_value :=  'P.L. 108-411, Sec. 301 dated 10-30-04.';
      ghr_mass_actions_pkg.replace_insertion_values
          (p_desc              => l_la_desc1,
           p_information1      => l_insrt_value,
           p_desc_out          => l_la_desc1_out);
       l_la_desc1 := l_la_desc1_out;
    END IF;

    IF (l_la_code2 = 'ZLM') THEN
      l_insrt_value :=  'P.L. 108-411, Sec. 301 dated 10-30-04.';
      ghr_mass_actions_pkg.replace_insertion_values
          (p_desc              => l_la_desc2,
           p_information1      => l_insrt_value,
           p_desc_out          => l_la_desc2_out);
       l_la_desc2 := l_la_desc2_out;
     END IF;

     UPDATE GHR_PA_REQUESTS
        SET first_action_la_code1   = l_la_code1,
            first_action_la_code2   = l_la_code2,
            first_action_la_desc1   = l_la_desc1,
            first_action_la_desc2   = l_la_Desc2,
            first_lac1_information1 = DECODE(l_la_code1, 'ZLM',
                                             l_insrt_value,NULL),
            first_lac1_information2 = NULL,
            first_lac1_information3 = NULL,
            first_lac1_information4 = NULL,
            first_lac1_information5 = NULL,
            first_lac2_information1 = DECODE(l_la_code2, 'ZLM',
                                             l_insrt_value, NULL),
            first_lac2_information2 = NULL,
            first_lac2_information3 = NULL,
            first_lac2_information4 = NULL,
            first_lac2_information5 = NULL
      WHERE pa_request_id = p_pa_request_id;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := 2;
      p_errbuf  := sqlerrm;

  END apply_fwfa_rules;
  -- FWFA Changes

END GHR_LACS_REMARKS;

/
