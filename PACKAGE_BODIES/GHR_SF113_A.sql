--------------------------------------------------------
--  DDL for Package Body GHR_SF113_A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF113_A" AS
/* $Header: ghsf113a.pkb 120.2.12010000.2 2009/09/30 09:21:34 utokachi ship $ */
--
  g_package                     varchar2(33) := 'GHR_SF113_A.';
--
  l_asgn_hist_data              PER_ASSIGNMENT_EXTRA_INFO%ROWTYPE;
  l_people_hist_data            PER_PEOPLE_EXTRA_INFO%ROWTYPE;
  l_pos_hist_data               PER_POSITION_EXTRA_INFO%ROWTYPE;
  l_person_id                   PER_ASSIGNMENTS_F.PERSON_ID%TYPE;
  l_assignment_id               PER_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  l_position_id                 PER_ASSIGNMENTS_F.POSITION_ID%TYPE;
  l_grade_id                    PER_ASSIGNMENTS_F.GRADE_ID%TYPE;
  l_loc_id                      PER_ASSIGNMENTS_F.LOCATION_ID%TYPE;
  l_start_date                  PER_ASSIGNMENTS_F.EFFECTIVE_START_DATE%TYPE;
  l_end_date                    PER_ASSIGNMENTS_F.EFFECTIVE_END_DATE%TYPE;
  l_tenure                      PER_ASSIGNMENT_EXTRA_INFO.AEI_INFORMATION4%TYPE;
  l_date_end                    HR_ALL_POSITIONS_F.DATE_END%TYPE;
  l_date_effective              HR_ALL_POSITIONS_F.DATE_END%TYPE;
  l_work_schedule               PER_POSITION_EXTRA_INFO. POEI_INFORMATION10%TYPE;
  l_position_code               PER_POSITION_EXTRA_INFO.POEI_INFORMATION3%TYPE;
  l_pay_basis                   PER_POSITION_EXTRA_INFO.POEI_INFORMATION6%TYPE;
  l_citizenship                 PER_PEOPLE_EXTRA_INFO.PEI_INFORMATION3%TYPE;
  l_appointment                 PER_PEOPLE_EXTRA_INFO.PEI_INFORMATION3%TYPE;
  l_emp_type                    PER_PEOPLE_EXTRA_INFO.PEI_INFORMATION4%TYPE;
  l_cur_appt1                   PER_PEOPLE_EXTRA_INFO.PEI_INFORMATION8%TYPE;
  l_cur_appt2                   PER_PEOPLE_EXTRA_INFO.PEI_INFORMATION9%TYPE;
  l_pay_plan                    PER_GRADE_DEFINITIONS.SEGMENT1%TYPE;
  l_duty_station_code           GHR_DUTY_STATIONS_F.STATE_OR_COUNTRY_CODE%TYPE;
  l_duty_station                GHR_DUTY_STATIONS_F.STATE_OR_COUNTRY_CODE%TYPE;
  l_msa_code                    GHR_DUTY_STATIONS_F.MSA_CODE%TYPE;
  l_noa_family_code             GHR_PA_REQUESTS.NOA_FAMILY_CODE%TYPE;
  l_first_action_la_code1       GHR_PA_REQUESTS.FIRST_ACTION_LA_CODE1%TYPE;
  l_effective_date              GHR_PA_REQUESTS.EFFECTIVE_DATE%TYPE;
  l_code                        GHR_NATURE_OF_ACTIONS.CODE%TYPE;
  l_ass_eff_date                GHR_PA_HISTORY.EFFECTIVE_DATE%TYPE;
  l_pos_eff_date                GHR_PA_HISTORY.EFFECTIVE_DATE%TYPE;
  l_pos1_eff_date               GHR_PA_HISTORY.EFFECTIVE_DATE%TYPE;
  l_people_eff_date             GHR_PA_HISTORY.EFFECTIVE_DATE%TYPE;
  l_people1_eff_date            GHR_PA_HISTORY.EFFECTIVE_DATE%TYPE;
  l_status                      varchar2(1);
--  l_susp_flag                   varchar2(1) := 'N';
  l_susp_flag                   varchar2(1);
  l_lwop_nte_date                   date;
  l_susp_nte_date                   date;
  l_furlough_nte_date                date;
-----
-----
-----
FUNCTION get_org_info(  p_business_group_id in number)
return varchar2 IS
--
l_col_name        HR_ORGANIZATION_INFORMATION.ORG_INFORMATION5%TYPE;

  CURSOR        get_segment IS
  SELECT        ORG_INFORMATION5
    FROM        HR_ORGANIZATION_INFORMATION
   WHERE        ORG_INFORMATION_CONTEXT = 'GHR_US_ORG_INFORMATION'
          AND   ORGANIZATION_ID = p_business_group_id;
--
  BEGIN
    OPEN get_segment;
    FETCH get_segment INTO l_col_name;
    IF GET_SEGMENT%NOTFOUND THEN
       l_col_name := null;
       CLOSE get_segment;
    END IF;
    CLOSE GET_SEGMENT;
    RETURN l_col_name;
END get_org_info;
-----
----------------------------------------------------------------------------
-----
Function validate_agcy (p_agcy  IN      varchar2,
                                p_segment       IN      varchar2)
return boolean   IS

  l_agcy              varchar(4);
  l_valid_agcy        BOOLEAN;

  CURSOR val_agcy IS
  SELECT      DECODE(p_segment,'SEGMENT1',SEGMENT1,
                                'SEGMENT2',SEGMENT2,
                                'SEGMENT3',SEGMENT3,
                                'SEGMENT4',SEGMENT4,
                                'SEGMENT5',SEGMENT5,
                                'SEGMENT6',SEGMENT6,
                                'SEGMENT7',SEGMENT7,
                                'SEGMENT8',SEGMENT8,
                                'SEGMENT9',SEGMENT9,
                                'SEGMENT10',SEGMENT10,
                                'SEGMENT11',SEGMENT11,
                                'SEGMENT12',SEGMENT12,
                                'SEGMENT13',SEGMENT13,
                                'SEGMENT14',SEGMENT14,
                                'SEGMENT15',SEGMENT15,
                                'SEGMENT16',SEGMENT16,
                                'SEGMENT17',SEGMENT17,
                                'SEGMENT18',SEGMENT18,
                                'SEGMENT19',SEGMENT19,
                                'SEGMENT20',SEGMENT20,
                                'SEGMENT21',SEGMENT21,
                                'SEGMENT22',SEGMENT22,
                                'SEGMENT23',SEGMENT23,
                                'SEGMENT24',SEGMENT24,
                                'SEGMENT25',SEGMENT25,
                                'SEGMENT26',SEGMENT26,
                                'SEGMENT27',SEGMENT27,
                                'SEGMENT28',SEGMENT28,
                                'SEGMENT29',SEGMENT29,
                                'SEGMENT30',SEGMENT30) AGCY
    FROM        PER_POSITION_DEFINITIONS
    WHERE       DECODE(p_segment,'SEGMENT1',segment1
                       ,'SEGMENT2',segment2
                       ,'SEGMENT3',segment3
                       ,'SEGMENT4',segment4
                       ,'SEGMENT5',segment5
                       ,'SEGMENT6',segment6
                       ,'SEGMENT7',segment7
                       ,'SEGMENT8',segment8
                       ,'SEGMENT9',segment9
                       ,'SEGMENT10',segment10
                       ,'SEGMENT11',segment11
                       ,'SEGMENT12',segment12
                       ,'SEGMENT13',segment13
                       ,'SEGMENT14',segment14
                       ,'SEGMENT15',segment15
                       ,'SEGMENT16',segment16
                       ,'SEGMENT17',segment17
                       ,'SEGMENT18',segment18
                       ,'SEGMENT19',segment19
                       ,'SEGMENT20',segment20
                       ,'SEGMENT21',segment21
                       ,'SEGMENT22',segment22
                       ,'SEGMENT23',segment23
                       ,'SEGMENT24',segment24
                       ,'SEGMENT25',segment25
                       ,'SEGMENT26',segment26
                       ,'SEGMENT27',segment27
                       ,'SEGMENT28',segment28
                       ,'SEGMENT29',segment29
                       ,'SEGMENT30',segment30) like ''||p_agcy||'';

  BEGIN
	l_valid_agcy  := FALSE; -- Sundar - GSCC File.Sql.35 Changes
    OPEN val_agcy;
    LOOP
    FETCH val_agcy INTO l_agcy;
    IF VAL_AGCY%NOTFOUND THEN
       l_valid_agcy   := TRUE;
       EXIT;
    ELSIF l_agcy in ('CI00','DD05','DD28','FR00','PO00','PJ00','TV00','WH01')
                  or substr(l_agcy,1,2) in ('LL','LB','LA','LD','LG','LC')   THEN
         l_valid_agcy   := TRUE;
       EXIT;
    END IF;
    END LOOP;
    CLOSE val_agcy;
    RETURN l_valid_agcy;

END validate_agcy;
-----
-----------------------------------------------------------------------------
-----
Procedure sf113a_sec1 (  p_rpt_date                  IN   date
                        ,p_empl_as_of_date           IN date
                        ,p_agcy              IN   varchar2
                        ,p_segment                   IN       varchar2
                        ,p_l1a                 IN OUT NOCOPY   number
                        ,p_l1b                 IN OUT NOCOPY    number
                        ,p_l1c                 IN OUT NOCOPY    number
                        ,p_l1d                 IN OUT NOCOPY    number
                        ,p_l1e                 IN OUT NOCOPY    number
                        ,p_l2a                 IN OUT NOCOPY    number
                        ,p_l2b                 IN OUT NOCOPY    number
                        ,p_l2c                 IN OUT NOCOPY   number
                        ,p_l2d                 IN OUT NOCOPY   number
                        ,p_l2e                 IN OUT NOCOPY   number
                        ,p_l3a                 IN OUT NOCOPY   number
                        ,p_l3b                 IN OUT NOCOPY   number
                        ,p_l3c                 IN OUT NOCOPY   number
                        ,p_l3d                 IN OUT NOCOPY   number
                        ,p_l3e                 IN OUT NOCOPY   number
                        ,p_l4a                 IN OUT NOCOPY   number
                        ,p_l4b                 IN OUT NOCOPY   number
                        ,p_l4c                 IN OUT NOCOPY   number
                        ,p_l4d                 IN OUT NOCOPY   number
                        ,p_l4e                 IN OUT NOCOPY   number
                        ,p_l5a                 IN OUT NOCOPY   number
                        ,p_l5b                 IN OUT NOCOPY   number
                        ,p_l5c                 IN OUT NOCOPY   number
                        ,p_l5d                 IN OUT NOCOPY   number
                        ,p_l5e                 IN OUT NOCOPY   number
                        ,p_l6a                 IN OUT NOCOPY   number
                        ,p_l6b                 IN OUT NOCOPY   number
                        ,p_l6c                 IN OUT NOCOPY   number
                        ,p_l6d                 IN OUT NOCOPY   number
                        ,p_l6e                 IN OUT NOCOPY   number
                        ,p_l7a                 IN OUT NOCOPY   number
                        ,p_l7b                 IN OUT NOCOPY   number
                        ,p_l7c                 IN OUT NOCOPY   number
                        ,p_l7d                 IN OUT NOCOPY   number
                        ,p_l7e                 IN OUT NOCOPY   number
                        ,p_l8a                 IN OUT NOCOPY   number
                        ,p_l8b                 IN OUT NOCOPY   number
                        ,p_l8c                 IN OUT NOCOPY   number
                        ,p_l8d                 IN OUT NOCOPY   number
                        ,p_l8e                 IN OUT NOCOPY   number
                        ,p_l9a                 IN OUT NOCOPY   number
                        ,p_l9b                 IN OUT NOCOPY   number
                        ,p_l9c                 IN OUT NOCOPY   number
                        ,p_l9d                 IN OUT NOCOPY   number
                        ,p_l9e                 IN OUT NOCOPY   number
                        ,p_l10a               IN OUT NOCOPY   number
                        ,p_l10b               IN OUT NOCOPY   number
                        ,p_l10c               IN OUT NOCOPY   number
                        ,p_l10d               IN OUT NOCOPY   number
                        ,p_l10e               IN OUT NOCOPY   number
                        ,p_l11a               IN OUT NOCOPY   number
                        ,p_l11b               IN OUT NOCOPY   number
                        ,p_l11c               IN OUT NOCOPY   number
                        ,p_l11d               IN OUT NOCOPY   number
                        ,p_l11e               IN OUT NOCOPY   number
                        ,p_l12a               IN OUT NOCOPY   number
                        ,p_l12b               IN OUT NOCOPY   number
                        ,p_l12c               IN OUT NOCOPY   number
                        ,p_l12d               IN OUT NOCOPY   number
                        ,p_l12e               IN OUT NOCOPY   number
                        ,p_l13a               IN OUT NOCOPY   number
                        ,p_l13b               IN OUT NOCOPY   number
                        ,p_l13c               IN OUT NOCOPY   number
                        ,p_l13d               IN OUT NOCOPY   number
                        ,p_l13e               IN OUT NOCOPY   number
                        ,p_l14a               IN OUT NOCOPY   number
                        ,p_l14b               IN OUT NOCOPY   number
                        ,p_l14c               IN OUT NOCOPY   number
                        ,p_l14d               IN OUT NOCOPY   number
                        ,p_l14e               IN OUT NOCOPY   number
                        ,p_l15a               IN OUT NOCOPY   number
                        ,p_l15b               IN OUT NOCOPY   number
                        ,p_l15c               IN OUT NOCOPY   number
                        ,p_l15d               IN OUT NOCOPY   number
                        ,p_l15e               IN OUT NOCOPY   number
                        ,p_l16a               IN OUT NOCOPY   number
                        ,p_l16b               IN OUT NOCOPY   number
                        ,p_l16c               IN OUT NOCOPY   number
                        ,p_l16d               IN OUT NOCOPY   number
                        ,p_l16e               IN OUT NOCOPY   number
                        ,p_l29a               IN OUT NOCOPY   number
                        ,p_l29b               IN OUT NOCOPY   number
                        ,p_l29c               IN OUT NOCOPY   number
                        ,p_l29d               IN OUT NOCOPY   number
                        ,p_l29e               IN OUT NOCOPY   number
                        ,p_l30a               IN OUT NOCOPY   number
                        ,p_l30b               IN OUT NOCOPY   number
                        ,p_l30c               IN OUT NOCOPY   number
                        ,p_l30d               IN OUT NOCOPY   number
                        ,p_l30e               IN OUT NOCOPY   number)  IS
--

-- NOCOPY changes
l_l1a                     number ;
l_l1b                      number ;
l_l1c                      number ;
l_l1d                      number ;
l_l1e                      number ;
l_l2a                      number ;
l_l2b                      number ;
l_l2c                     number ;
l_l2d                     number ;
l_l2e                     number ;
l_l3a                     number ;
l_l3b                     number ;
l_l3c                     number ;
l_l3d                     number ;
l_l3e                     number ;
l_l4a                     number ;
l_l4b                     number ;
l_l4c                     number ;
l_l4d                     number ;
l_l4e                     number ;
l_l5a                     number ;
l_l5b                     number ;
l_l5c                     number ;
l_l5d                     number ;
l_l5e                     number ;
l_l6a                     number ;
l_l6b                     number ;
l_l6c                     number ;
l_l6d                     number ;
l_l6e                     number ;
l_l7a                     number ;
l_l7b                     number ;
l_l7c                     number ;
l_l7d                     number ;
l_l7e                     number;
l_l8a                     number ;
l_l8b                     number ;
l_l8c                     number ;
l_l8d                     number ;
l_l8e                     number;
l_l9a                     number ;
l_l9b                     number ;
l_l9c                     number ;
l_l9d                     number ;
l_l9e                     number;
l_l10a                    number ;
l_l10b                    number ;
l_l10c                    number ;
l_l10d                    number ;
l_l10e                   number ;
l_l11a                   number ;
l_l11b                   number ;
l_l11c                   number ;
l_l11d                   number ;
l_l11e                   number;
l_l12a                   number ;
l_l12b                   number ;
l_l12c                   number ;
l_l12d                   number ;
l_l12e                   number;
l_l13a                   number ;
l_l13b                   number ;
l_l13c                   number ;
l_l13d                   number ;
l_l13e                   number;
l_l14a                   number ;
l_l14b                   number ;
l_l14c                   number ;
l_l14d                   number ;
l_l14e                   number ;
l_l15a                   number ;
l_l15b                   number ;
l_l15c                   number ;
l_l15d                   number ;
l_l15e                   number;
l_l16a                   number ;
l_l16b                   number ;
l_l16c                   number ;
l_l16d                   number ;
l_l16e                   number;
l_l29a                   number ;
l_l29b                   number ;
l_l29c                   number ;
l_l29d                   number ;
l_l29e                   number;
l_l30a                   number ;
l_l30b                   number ;
l_l30c                   number ;
l_l30d                   number ;
l_l30e                   number;

 CURSOR sf113_section1 IS
        SELECT v.person_id,
                 v.status,
                 v.effective_start_date start_date,
                 v.effective_end_date end_date,
                 v.assignment_id,
                 v.position_id pos_id,
                 v.grade_id,
                 v.location_id loc_id,
                 pgd.segment1,
                 SUBSTR(hds.state_or_country_code, 1, 2) state_or_country_code,
                 hds.msa_code,
                 pp.date_effective,
                 pp.date_end ,
				 pp.permanent_temporary_flag
        FROM   GHR_SF113_V v,
                 GHR_DUTY_STATIONS_F hds,
                 HR_LOCATION_EXTRA_INFO hlei,
				 PER_POSITION_DEFINITIONS ppd,
                 HR_ALL_POSITIONS_F pp,
				 PER_GRADES pg,
                 PER_GRADE_DEFINITIONS pgd
        WHERE DECODE(p_segment,'SEGMENT1',ppd.segment1
                       ,'SEGMENT2',ppd.segment2
                       ,'SEGMENT3',ppd.segment3
                       ,'SEGMENT4',ppd.segment4
                       ,'SEGMENT5',ppd.segment5
                       ,'SEGMENT6',ppd.segment6
                       ,'SEGMENT7',ppd.segment7
                       ,'SEGMENT8',ppd.segment8
                       ,'SEGMENT9',ppd.segment9
                       ,'SEGMENT10',ppd.segment10
                       ,'SEGMENT11',ppd.segment11
                       ,'SEGMENT12',ppd.segment12
                       ,'SEGMENT13',ppd.segment13
                       ,'SEGMENT14',ppd.segment14
                       ,'SEGMENT15',ppd.segment15
                       ,'SEGMENT16',ppd.segment16
                       ,'SEGMENT17',ppd.segment17
                       ,'SEGMENT18',ppd.segment18
                       ,'SEGMENT19',ppd.segment19
                       ,'SEGMENT20',ppd.segment20
                       ,'SEGMENT21',ppd.segment21
                       ,'SEGMENT22',ppd.segment22
                       ,'SEGMENT23',ppd.segment23
                       ,'SEGMENT24',ppd.segment24
                       ,'SEGMENT25',ppd.segment25
                       ,'SEGMENT26',ppd.segment26
                       ,'SEGMENT27',ppd.segment27
                       ,'SEGMENT28',ppd.segment28
                       ,'SEGMENT29',ppd.segment29
                       ,'SEGMENT30',ppd.segment30) like ''||p_agcy||''
          AND (p_rpt_date between v.effective_start_date and v.effective_end_date)
          AND (trunc(p_rpt_date) between hds.effective_start_date and nvl(hds.effective_end_date, p_rpt_date))
          AND hlei.information_type                     = 'GHR_US_LOC_INFORMATION'
          AND pp.position_definition_id         = ppd.position_definition_id
          AND pg.grade_id                                       = v.grade_id
          AND pg.grade_definition_id                    = pgd.grade_definition_id
          AND pp.position_id                            = v.position_id
          AND TRUNC(p_rpt_date) BETWEEN pp.effective_start_date AND pp.effective_end_date
          AND v.location_id                             = hlei.location_id
          AND to_number(hlei.lei_information3)  = hds.duty_station_id;
---
Cursor chk_susp_asg_status is
 select 'X' from
  per_assignments_f asg,
  per_assignment_status_types ast
  where asg.assignment_id = l_assignment_id
  and p_empl_as_of_date between asg.effective_start_date
                       and asg.effective_end_date
  and asg.primary_flag = 'Y'
  and asg.assignment_type <> 'B'
  and asg.assignment_status_type_id = ast.assignment_status_type_id
  and ast.per_system_status = 'SUSP_ASSIGN';
--
l_pos_permanent hr_all_positions_f.permanent_temporary_flag%type;

BEGIN
-- NOCOPY changes
l_l1a :=	p_l1a;
l_l1b :=	p_l1b	;
l_l1c :=	p_l1c	;
l_l1d :=	p_l1d	;
l_l1e :=	p_l1e	;
l_l2a :=	p_l2a	;
l_l2b :=	p_l2b	;
l_l2c :=	p_l2c;
l_l2d :=	p_l2d;
l_l2e :=	p_l2e;
l_l3a :=	p_l3a;
l_l3b :=	p_l3b;
l_l3c :=	p_l3c;
l_l3d :=	p_l3d;
l_l3e :=	p_l3e;
l_l4a :=	p_l4a;
l_l4b :=	p_l4b;
l_l4c :=	p_l4c;
l_l4d :=	p_l4d;
l_l4e :=	p_l4e;
l_l5a :=	p_l5a;
l_l5b :=	p_l5b;
l_l5c :=	p_l5c;
l_l5d :=	p_l5d;
l_l5e :=	p_l5e;
l_l6a :=	p_l6a;
l_l6b :=	p_l6b;
l_l6c :=	p_l6c;
l_l6d :=	p_l6d;
l_l6e :=	p_l6e;
l_l7a :=	p_l7a;
l_l7b :=	p_l7b;
l_l7c :=	p_l7c;
l_l7d :=	p_l7d;
l_l7e :=	p_l7e  ;
l_l8a :=	p_l8a;
l_l8b :=	p_l8b;
l_l8c :=	p_l8c;
l_l8d :=	p_l8d;
l_l8e :=	p_l8e  ;
l_l9a :=	p_l9a;
l_l9b :=	p_l9b;
l_l9c :=	p_l9c;
l_l9d :=	p_l9d;
l_l9e :=	p_l9e  ;
l_l10a 	:=	p_l10a  ;
l_l10b :=	p_l10b  ;
l_l10c  :=	p_l10c  ;
l_l10d  :=	p_l10d  ;
l_l10e :=	p_l10e ;
l_l11a :=	p_l11a ;
l_l11b :=	p_l11b ;
l_l11c :=	p_l11c ;
l_l11d :=	p_l11d ;
l_l11e :=	p_l11e               	;
l_l12a :=	p_l12a ;
l_l12b :=	p_l12b ;
l_l12c :=	p_l12c ;
l_l12d :=	p_l12d ;
l_l12e :=	p_l12e                   	;
l_l13a :=	p_l13a ;
l_l13b :=	p_l13b ;
l_l13c :=	p_l13c ;
l_l13d :=	p_l13d ;
l_l13e :=	p_l13e                   	;
l_l14a :=	p_l14a ;
l_l14b :=	p_l14b ;
l_l14c :=	p_l14c ;
l_l14d :=	p_l14d ;
l_l14e :=	p_l14e ;
l_l15a :=	p_l15a ;
l_l15b :=	p_l15b ;
l_l15c :=	p_l15c ;
l_l15d :=	p_l15d ;
l_l15e :=	p_l15e                   	;
l_l16a :=	p_l16a ;
l_l16b :=	p_l16b ;
l_l16c :=	p_l16c ;
l_l16d :=	p_l16d ;
l_l16e :=	p_l16e                   	;
l_l29a :=	p_l29a ;
l_l29b :=	p_l29b ;
l_l29c :=	p_l29c ;
l_l29d :=	p_l29d ;
l_l29e :=	p_l29e                   	;
l_l30a :=	p_l30a ;
l_l30b :=	p_l30b ;
l_l30c :=	p_l30c ;
l_l30d :=	p_l30d ;
l_l30e :=	p_l30e                   	;


OPEN sf113_section1;
LOOP
	-- Sundar added Position permanent flag
   FETCH sf113_section1  INTO l_person_id, l_status, l_start_date, l_end_date, l_assignment_id,
                               l_position_id, l_grade_id, l_loc_id, l_pay_plan,l_duty_station_code,
                                                 l_msa_code, l_date_effective, l_date_end,l_pos_permanent;

   EXIT WHEN SF113_SECTION1%NOTFOUND;
   l_susp_flag := 'N';
  --Begin Bug# 8928564
  ghr_history_fetch.fetch_positionei(
    p_position_id         => l_position_id
   ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
   ,p_date_effective      => p_rpt_date
   ,p_pos_ei_data         => l_pos_hist_data);
  --
  l_pay_basis := l_pos_hist_data.poei_information6;
  IF l_pay_basis NOT IN ('PD','WC') THEN
  --end Bug# 8928564
   -- Exclude NAF positions (Non-Apropriated Fund Positions) using CPDF dynamics function
   IF NOT ghr_cpdf_dynrpt.exclude_position(l_position_id, p_rpt_date) THEN
     l_duty_station := hr_api.g_varchar2;

     IF l_duty_station_code  in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                 'RM','HQ','PS','BQ','WQ','VQ') THEN
        l_duty_station := 'T';
     ELSIF  l_duty_station_code  not in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                         'RM','HQ','PS','BQ','WQ','VQ')
             and (l_duty_station_code  >= 'AA'  and l_duty_station_code  <= 'ZZ') THEN
             l_duty_station := 'F';
     ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) = '8840'
            or nvl(l_msa_code,hr_api.g_varchar2) = '47900' )
               and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
            l_duty_station := 'W';
     ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) <> '8840'
                  or nvl(l_msa_code,hr_api.g_varchar2) <> '47900'
                  or l_msa_code is null)
             and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99')
             THEN
            l_duty_station := 'O';
     END IF;
     GHR_HISTORY_FETCH.fetch_asgei(l_assignment_id,'GHR_US_ASG_SF52',p_rpt_date,
                                   l_asgn_hist_data);
     l_tenure       := L_ASGN_HIST_DATA.AEI_INFORMATION4;
     l_work_schedule := L_ASGN_HIST_DATA.AEI_INFORMATION7;

     FOR c_chk_ast_status IN chk_susp_asg_status
     LOOP
       GHR_HISTORY_FETCH.fetch_asgei(l_assignment_id,'GHR_US_ASG_NTE_DATES',p_rpt_date, l_asgn_hist_data);
       l_lwop_nte_date     := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information6);
       l_susp_nte_date     := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information8);
       l_furlough_nte_date := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information10);
       hr_utility.set_location(' lwop date is ' || l_lwop_nte_date, 1);
       hr_utility.set_location(' susp date is ' || l_susp_nte_date, 1);
       hr_utility.set_location(' furlough date is ' || l_furlough_nte_date, 1);
       IF (nvl(l_lwop_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30 )  or
          (nvl(l_susp_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30  ) or
          (nvl(l_furlough_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30 ) then
         l_susp_flag := 'Y';
       END IF;
     END LOOP;
     GHR_HISTORY_FETCH.fetch_peopleei(l_person_id,'GHR_US_PER_SF52',
                                                        p_rpt_date,l_people_hist_data);
     l_citizenship         := l_people_hist_data.pei_information3;

     GHR_HISTORY_FETCH.fetch_peopleei(l_person_id,'GHR_US_PER_GROUP1',p_rpt_date,
                                                                        l_people_hist_data);
     l_emp_type         := l_people_hist_data.pei_information4;
     l_appointment      := l_people_hist_data.pei_information3;
     l_cur_appt1         := l_people_hist_data.pei_information8;
     l_cur_appt2         := l_people_hist_data.pei_information9;

     -- Use Assignment Work Schedule Not Position.
     --GHR_HISTORY_FETCH.fetch_positionei(l_position_id,'GHR_US_POS_GRP1',p_rpt_date,l_pos_hist_data);
     --l_work_schedule    := l_pos_hist_data. poei_information10;

     GHR_HISTORY_FETCH.fetch_positionei(l_position_id,'GHR_US_POS_GRP2',p_rpt_date,
                                        l_pos_hist_data );
     l_position_code  := l_pos_hist_data.poei_information3;
	 hr_utility.set_location('l_susp_flag is ' || l_susp_flag ,2);
	 hr_utility.set_location('l_assignment_id is ' || l_assignment_id ,3);
	 hr_utility.set_location('l_person_id is ' || l_person_id ,3);
	 hr_utility.set_location('l_duty_station is ' || l_duty_station ,3);
	 hr_utility.set_location('l_duty_station_code is ' || l_duty_station_code ,3);
	 hr_utility.set_location('l_work_schedule is ' || l_work_schedule ,3);
	 hr_utility.set_location('l_emp_type is ' || l_emp_type ,3);
	 hr_utility.set_location('l_tenure is ' || l_tenure ,3);
	 hr_utility.set_location('l_position_code is ' || l_position_code ,3);
	 hr_utility.set_location('l_msa_code is ' || l_msa_code ,3);
	 hr_utility.set_location('l_cur_appt1 is ' || l_cur_appt1 ,3);
	 hr_utility.set_location('l_cur_appt2 is ' || l_cur_appt2 ,3);

	-- For line 3, Need to take Work schedule irrespective of Employment type(except Intermittent)
--     IF l_emp_type  in ('1','H') and l_work_schedule ='F' THEN
		-- Sundar 3166530 Commented the above stmt. Replaced it with the one below.
		-- Added the condition to check whether they're not suspended.
--	   IF l_emp_type NOT IN ('D','4') and l_work_schedule IN ('F','G') AND NVL(l_susp_flag,'N') = 'N' THEN
-- Including work schedule Baylor plan as per latest requirements.
	   IF  l_work_schedule IN ('F','G','B') AND NVL(l_susp_flag,'N') = 'N' THEN
			IF l_duty_station = 'T' THEN
				 p_l3b :=  p_l3b + 1;
			ELSIF l_duty_station = 'F' THEN
				 p_l3c :=  p_l3c + 1;
			ELSIF l_duty_station = 'W' THEN
				 p_l3d :=  p_l3d + 1;
			ELSIF l_duty_station = 'O' THEN
				 p_l3e :=  p_l3e + 1;
			END IF;
			p_l3a := p_l3b + p_l3c + p_l3d + p_l3e ;

			-- For line 4, check if they're Permanent positions
			--  check if the position has end date, or establised for an year.
			IF ( (l_date_end > ADD_MONTHS(p_empl_as_of_date, 12))  or  l_date_end is null )
			 THEN
				IF l_duty_station = 'T' THEN
					 p_l4b :=  p_l4b + 1;
				ELSIF l_duty_station = 'F' THEN
					 p_l4c :=  p_l4c + 1;
				ELSIF l_duty_station = 'W' THEN
					 p_l4d :=  p_l4d + 1;
				ELSIF l_duty_station = 'O' THEN
					 p_l4e :=  p_l4e + 1;
				END IF;
				p_l4a := p_l4b + p_l4c + p_l4d + p_l4e ;
			 END IF; -- End if for Permanent Positions.

			 -- For line 5, check if they're Permanent Appointments(Tenure code 1 or 2)
			 IF  (l_tenure in ('1','2') and l_position_code in ('1','2') ) OR
              (l_tenure = '0' and l_position_code  in ('3','4')
	               and (nvl(l_cur_appt1,hr_api.g_varchar2) not in ('V4M','V4P')
                   and nvl(l_cur_appt2,hr_api.g_varchar2) not in ('V4M','V4P')
                    )
               ) THEN
						IF l_duty_station = 'T' THEN
							  p_l5b :=  p_l5b + 1;
						ELSIF l_duty_station = 'F' THEN
							  p_l5c :=  p_l5c + 1;
						ELSIF l_duty_station = 'W' THEN
							  p_l5d :=  p_l5d + 1;
						ELSIF l_duty_station = 'O' THEN
							  p_l5e :=  p_l5e + 1;
						END IF;
						p_l5a := p_l5b + p_l5c + p_l5d + p_l5e ;
						p_l30a := p_l5a;
						p_l30b := p_l5b;
						p_l30c := p_l5c;
						p_l30d := p_l5d;
						p_l30e := p_l5e;
			 END IF; -- End if for Permanent Appointments

		END IF;  -- End if for Full-time employees

/*		IF (l_emp_type  in ('1','2','D','H') and l_work_schedule ='F')
			  and ((l_date_end > ADD_MONTHS(p_empl_as_of_date, 12))  or  l_date_end is null) THEN

			IF l_duty_station = 'T' THEN
				 p_l4b :=  p_l4b + 1;
			ELSIF l_duty_station = 'F' THEN
				 p_l4c :=  p_l4c + 1;
			ELSIF l_duty_station = 'W' THEN
				 p_l4d :=  p_l4d + 1;
			ELSIF l_duty_station = 'O' THEN
				 p_l4e :=  p_l4e + 1;
			END IF;
			p_l4a := p_l4b + p_l4c + p_l4d + p_l4e ;
		 END IF;  */

/*
     IF l_emp_type in ('1','H') and l_work_schedule = 'F'
        and (
              (l_tenure in ('1','2') and
               l_position_code in ('1','2')
               )
        or
              (l_tenure = '0' and l_position_code  in ('3','4')
               and (nvl(l_cur_appt1,hr_api.g_varchar2) not in ('V4M','V4P')
                   and nvl(l_cur_appt2,hr_api.g_varchar2) not in ('V4M','V4P')
                    )
               )
            )
     THEN
        IF l_duty_station = 'T' THEN
            p_l5b :=  p_l5b + 1;
        ELSIF l_duty_station = 'F' THEN
              p_l5c :=  p_l5c + 1;
        ELSIF l_duty_station = 'W' THEN
              p_l5d :=  p_l5d + 1;
        ELSIF l_duty_station = 'O' THEN
              p_l5e :=  p_l5e + 1;
        END IF;
        p_l5a := p_l5b + p_l5c + p_l5d + p_l5e ;
        p_l30a := p_l5a;
        p_l30b := p_l5b;
        p_l30c := p_l5c;
        p_l30d := p_l5d;
        p_l30e := p_l5e;

     END IF;
	 */

	 -- For line 6, We need to take Part time work schedule employees (except Intermittent)

     /*IF l_emp_type in ('2','H')
      and l_work_schedule in ('P','Q','S','T','B') */
	  IF l_work_schedule in ('P','Q','S','T')  AND NVL(l_susp_flag,'N') = 'N'  THEN
       IF l_duty_station = 'T' THEN
            p_l6b :=  p_l6b + 1;
       ELSIF l_duty_station = 'F' THEN
            p_l6c :=  p_l6c + 1;
       ELSIF l_duty_station = 'W' THEN
            p_l6d :=  p_l6d + 1;
       ELSIF l_duty_station = 'O' THEN
            p_l6e :=  p_l6e + 1;
       END IF;
       p_l6a := p_l6b + p_l6c + p_l6d + p_l6e ;

       -- Line 7 - Part time with Permanent Appointments
	   IF  ((l_tenure in ('1','2') and l_position_code in ('1','2')) OR
			( l_tenure = '0' and l_position_code  in ('3','4')
               and ( nvl(l_cur_appt1,hr_api.g_varchar2) not in ('V4M','V4P')
                   and nvl(l_cur_appt2,hr_api.g_varchar2) not in ('V4M','V4P')
                    )
			)  AND l_susp_flag = 'N' )THEN

			   IF l_duty_station = 'T' THEN
					p_l7b :=  p_l7b + 1;
			   ELSIF l_duty_station = 'F' THEN
					p_l7c :=  p_l7c + 1;
			   ELSIF l_duty_station = 'W' THEN
					p_l7d :=  p_l7d + 1;
			   ELSIF l_duty_station = 'O' THEN
					p_l7e :=  p_l7e + 1;
			   END IF;
			   p_l7a := p_l7b + p_l7c + p_l7d + p_l7e ;
	   END IF; -- End if for Part time with Permanent Appts.

	 END IF; -- End if for Part time employees


/*     IF l_emp_type in ('2','H')
        and l_work_schedule in  ('P','Q','S','T','B')
        and (l_date_end > ADD_MONTHS(p_empl_as_of_date, 12)
              or  l_date_end is null)
        and (
              (l_tenure in ('1','2') and l_position_code in ('1','2'))
        or
              (l_tenure = '0' and l_position_code  in ('3','4')
               and (nvl(l_cur_appt1,hr_api.g_varchar2) not in ('V4M','V4P')
                   and nvl(l_cur_appt2,hr_api.g_varchar2) not in ('V4M','V4P')
                    )
               )
            )
     THEN
       IF l_duty_station = 'T' THEN
            p_l7b :=  p_l7b + 1;
       ELSIF l_duty_station = 'F' THEN
            p_l7c :=  p_l7c + 1;
       ELSIF l_duty_station = 'W' THEN
            p_l7d :=  p_l7d + 1;
       ELSIF l_duty_station = 'O' THEN
            p_l7e :=  p_l7e + 1;
       END IF;
       p_l7a := p_l7b + p_l7c + p_l7d + p_l7e ;
     END IF; */
	-- Bug 3166530 Emp type checking for 'H','D' has been removed.
	-- Bug 3588495 Work schedules G, Q removed for Intermittent

     IF l_work_schedule in ('I','J')
        and NVL(l_emp_type,'Z') IN ('Z','1','C','D','E') AND NVL(l_susp_flag,'N') = 'N'
     THEN
       IF l_duty_station = 'T' THEN
            p_l8b :=  p_l8b + 1;
       ELSIF l_duty_station = 'F' THEN
            p_l8c :=  p_l8c + 1;
       ELSIF l_duty_station = 'W' THEN
            p_l8d :=  p_l8d + 1;
       ELSIF l_duty_station = 'O' THEN
            p_l8e :=  p_l8e + 1;
       END IF;
       p_l8a := p_l8b + p_l8c + p_l8d + p_l8e ;
     END IF;

     IF l_emp_type  IN ('3','4','5','F','H','J') and l_work_schedule in ('I','J')   AND NVL(l_susp_flag,'N') = 'N'
     THEN
       IF l_duty_station = 'T' THEN
            p_l16b :=  p_l16b + 1;
       ELSIF l_duty_station = 'F' THEN
            p_l16c :=  p_l16c + 1;
       ELSIF l_duty_station = 'W' THEN
            p_l16d :=  p_l16d + 1;
       ELSIF l_duty_station = 'O' THEN
            p_l16e :=  p_l16e + 1;
       END IF;
       p_l16a := p_l16b + p_l16c + p_l16d + p_l16e ;
     END IF;

	-- Line 2 Permanent Positions  Including check for Suspension flag also
	-- For Line 1,2 Exclude Line 16
--     IF (l_emp_type  in ('1','2','D','H') and l_work_schedule in ('F','P','G','I','J','Q','S','T') AND NVL(l_susp_flag,'N') = 'N') THEN
	 IF l_work_schedule in ('F','B','P','G','I','J','Q','S','T') AND NVL(l_susp_flag,'N') = 'N' THEN

	   IF ( (l_date_end > ADD_MONTHS(p_empl_as_of_date, 12))  or  l_date_end is null )
		THEN
         IF l_duty_station = 'T' THEN
              p_l2b :=  p_l2b + 1;
         ELSIF l_duty_station = 'F' THEN
              p_l2c :=  p_l2c + 1;
         ELSIF l_duty_station = 'W' THEN
              p_l2d :=  p_l2d + 1;
         ELSIF l_duty_station = 'O' THEN
              p_l2e :=  p_l2e + 1;
         END IF;
         p_l2a := p_l2b + p_l2c + p_l2d + p_l2e ;
       END IF; -- end if for checking permanent position.

	   IF l_position_code = '1' THEN
         IF l_duty_station = 'T' THEN
              p_l9b :=  p_l9b + 1;
         ELSIF l_duty_station = 'F' THEN
              p_l9c :=  p_l9c + 1;
         ELSIF l_duty_station = 'W' THEN
           p_l9d :=  p_l9d + 1;
         ELSIF l_duty_station = 'O' THEN
              p_l9e :=  p_l9e + 1;
         END IF;
         p_l9a := p_l9b + p_l9c + p_l9d + p_l9e ;
       END IF;

	   IF l_tenure in ('1','2') and l_position_code  = '1'  THEN
         IF l_duty_station = 'T' THEN
              p_l10b :=  p_l10b + 1;
         ELSIF l_duty_station = 'F' THEN
              p_l10c :=  p_l10c + 1;
         ELSIF l_duty_station = 'W' THEN
              p_l10d :=  p_l10d + 1;
         ELSIF l_duty_station = 'O' THEN
              p_l10e :=  p_l10e + 1;
         END IF;
         p_l10a := p_l10b + p_l10c + p_l10d + p_l10e ;
       END IF;

	   IF l_position_code  in ('2','3','4') THEN
         IF l_duty_station = 'T' THEN
              p_l11b :=  p_l11b + 1;
         ELSIF l_duty_station = 'F' THEN
              p_l11c :=  p_l11c + 1;
         ELSIF l_duty_station = 'W' THEN
              p_l11d :=  p_l11d + 1;
         ELSIF l_duty_station = 'O' THEN
              p_l11e :=  p_l11e + 1;
         END IF;
         p_l11a := p_l11b + p_l11c + p_l11d + p_l11e ;
       END IF;

		IF (l_tenure in ('1','2')
            and l_position_code = '2'
            )
        OR
          (l_tenure = '0'
           and l_position_code in ('3','4')
           and (
                 nvl(l_cur_appt1,hr_api.g_varchar2)
                   not in ('V4M','V4P')
                 and
                 nvl(l_cur_appt2,hr_api.g_varchar2)
                   not in ('V4M','V4P')
                )
           )
       THEN
         IF l_duty_station = 'T' THEN
           p_l12b :=  p_l12b + 1;
         ELSIF l_duty_station = 'F' THEN
           p_l12c :=  p_l12c + 1;
         ELSIF l_duty_station = 'W' THEN
           p_l12d :=  p_l12d + 1;
         ELSIF l_duty_station = 'O' THEN
           p_l12e :=  p_l12e + 1;
         END IF;
         p_l12a := p_l12b + p_l12c + p_l12d + p_l12e ;
	   END IF;

	   IF  substr(l_pay_plan,1,1) in ('W','K','T','N','J','X') THEN
		 IF l_duty_station = 'T' THEN
			  p_l13b :=  p_l13b + 1;
		 ELSIF l_duty_station = 'F' THEN
			  p_l13c :=  p_l13c + 1;
		 ELSIF l_duty_station = 'W' THEN
			  p_l13d :=  p_l13d + 1;
		 ELSIF l_duty_station = 'O' THEN
			  p_l13e :=  p_l13e + 1;
		 END IF;
		 p_l13a := p_l13b + p_l13c + p_l13d + p_l13e ;
	   END IF;
	   IF l_citizenship         ='1'
	   THEN
			IF l_duty_station = 'T' THEN
			p_l14b :=  p_l14b + 1;
			 ELSIF l_duty_station = 'F' THEN
			p_l14c :=  p_l14c + 1;
			 ELSIF l_duty_station = 'W' THEN
			p_l14d :=  p_l14d + 1;
			 ELSIF l_duty_station = 'O' THEN
			p_l14e :=  p_l14e + 1;
			END IF;
			p_l14a := p_l14b + p_l14c + p_l14d + p_l14e ;
	   ELSE
			 IF l_duty_station = 'T' THEN
			p_l15b :=  p_l15b + 1;
			 ELSIF l_duty_station = 'F' THEN
			p_l15c :=  p_l15c + 1;
			 ELSIF l_duty_station = 'W' THEN
			p_l15d :=  p_l15d + 1;
			 ELSIF l_duty_station = 'O' THEN
			p_l15e :=  p_l15e + 1;
			END IF;
			p_l15a := p_l15b + p_l15c + p_l15d + p_l15e ;
	   END IF;
	   -- Ignore Line16 employees in line 1.
	   IF l_emp_type  IN ('3','4','5','F','H','J') and l_work_schedule in ('I','J') THEN
			NULL;
	   ELSE
		   IF l_duty_station = 'T' THEN
				p_l1b :=  p_l1b + 1;
		   ELSIF l_duty_station = 'F' THEN
				p_l1c :=  p_l1c + 1;
		   ELSIF l_duty_station = 'W' THEN
				p_l1d :=  p_l1d + 1;
		   ELSIF l_duty_station = 'O' THEN
				p_l1e :=  p_l1e + 1;
		   END IF;
		   p_l1a := p_l1b + p_l1c + p_l1d + p_l1e ;
       END IF; -- IF l_emp_type is Intermittent  not worked



	   IF   nvl(l_susp_flag,'N') = 'N'
		 and nvl(l_cur_appt1,hr_api.g_varchar2)
					not in ('MBM', 'MAM', 'QDK','NCM',
								  'YBM', 'YGM', 'Y3M','Y1M',
								  'Y2M', 'Y1K', 'Y2K','Y3K',
								  'Y4K', 'Y5K')
		 and nvl(l_cur_appt2,hr_api.g_varchar2)
					not in ('MBM', 'MAM', 'QDK','NCM',
								  'YBM', 'YGM', 'Y3M','Y1M',
								  'Y2M', 'Y1K', 'Y2K','Y3K',
								  'Y4K', 'Y5K') THEN
		 IF l_duty_station = 'T' THEN
			p_l29b :=  p_l29b + 1;
			 ELSIF l_duty_station = 'F' THEN
			p_l29c :=  p_l29c + 1;
			 ELSIF l_duty_station = 'W' THEN
			p_l29d :=  p_l29d + 1;
			 ELSIF l_duty_station = 'O' THEN
			p_l29e :=  p_l29e + 1;
		 END IF;
		 p_l29a := p_l29b + p_l29c + p_l29d + p_l29e ;
	   END IF; -- IF   nvl(l_susp_flag,'N')
   END IF;
 END IF;
 END IF;  --IF l_pay_basis NOT IN ('PD','WC') Bug# 8928564
END LOOP;
CLOSE sf113_section1;
hr_utility.set_location('Leaving ' || l_susp_flag ,1);

EXCEPTION                     -- NOCOPY changes
WHEN OTHERS THEN
	p_l1a                      	:=	l_l1a                      	;
	p_l1b                       	:=	l_l1b                       	;
	p_l1c                       	:=	l_l1c                       	;
	p_l1d                       	:=	l_l1d                       	;
	p_l1e                       	:=	l_l1e                       	;
	p_l2a                       	:=	l_l2a                       	;
	p_l2b                       	:=	l_l2b                       	;
	p_l2c                      	:=	l_l2c                      	;
	p_l2d                      	:=	l_l2d                      	;
	p_l2e                      	:=	l_l2e                      	;
	p_l3a                      	:=	l_l3a                      	;
	p_l3b                      	:=	l_l3b                      	;
	p_l3c                      	:=	l_l3c                      	;
	p_l3d                      	:=	l_l3d                      	;
	p_l3e                      	:=	l_l3e                      	;
	p_l4a                      	:=	l_l4a                      	;
	p_l4b                      	:=	l_l4b                      	;
	p_l4c                      	:=	l_l4c                      	;
	p_l4d                      	:=	l_l4d                      	;
	p_l4e                      	:=	l_l4e                      	;
	p_l5a                      	:=	l_l5a                      	;
	p_l5b                      	:=	l_l5b                      	;
	p_l5c                      	:=	l_l5c                      	;
	p_l5d                      	:=	l_l5d                      	;
	p_l5e                      	:=	l_l5e                      	;
	p_l6a                      	:=	l_l6a                      	;
	p_l6b                      	:=	l_l6b                      	;
	p_l6c                      	:=	l_l6c                      	;
	p_l6d                      	:=	l_l6d                      	;
	p_l6e                      	:=	l_l6e                      	;
	p_l7a                      	:=	l_l7a                      	;
	p_l7b                      	:=	l_l7b                      	;
	p_l7c                      	:=	l_l7c                      	;
	p_l7d                      	:=	l_l7d                      	;
	p_l7e                     	:=	l_l7e                     	;
	p_l8a                      	:=	l_l8a                      	;
	p_l8b                      	:=	l_l8b                      	;
	p_l8c                      	:=	l_l8c                      	;
	p_l8d                      	:=	l_l8d                      	;
	p_l8e                     	:=	l_l8e                     	;
	p_l9a                      	:=	l_l9a                      	;
	p_l9b                      	:=	l_l9b                      	;
	p_l9c                      	:=	l_l9c                      	;
	p_l9d                      	:=	l_l9d                      	;
	p_l9e                     	:=	l_l9e                     	;
	p_l10a                     	:=	l_l10a                     	;
	p_l10b                     	:=	l_l10b                     	;
	p_l10c                     	:=	l_l10c                     	;
	p_l10d                     	:=	l_l10d                     	;
	p_l10e                    	:=	l_l10e                    	;
	p_l11a                    	:=	l_l11a                    	;
	p_l11b                    	:=	l_l11b                    	;
	p_l11c                    	:=	l_l11c                    	;
	p_l11d                    	:=	l_l11d                    	;
	p_l11e                   	:=	l_l11e                   	;
	p_l12a                    	:=	l_l12a                    	;
	p_l12b                    	:=	l_l12b                    	;
	p_l12c                    	:=	l_l12c                    	;
	p_l12d                    	:=	l_l12d                    	;
	p_l12e                   	:=	l_l12e                   	;
	p_l13a                    	:=	l_l13a                    	;
	p_l13b                    	:=	l_l13b                    	;
	p_l13c                    	:=	l_l13c                    	;
	p_l13d                    	:=	l_l13d                    	;
	p_l13e                   	:=	l_l13e                   	;
	p_l14a                    	:=	l_l14a                    	;
	p_l14b                    	:=	l_l14b                    	;
	p_l14c                    	:=	l_l14c                    	;
	p_l14d                    	:=	l_l14d                    	;
	p_l14e                    	:=	l_l14e                    	;
	p_l15a                    	:=	l_l15a                    	;
	p_l15b                    	:=	l_l15b                    	;
	p_l15c                    	:=	l_l15c                    	;
	p_l15d                    	:=	l_l15d                    	;
	p_l15e                   	:=	l_l15e                   	;
	p_l16a                    	:=	l_l16a                    	;
	p_l16b                    	:=	l_l16b                    	;
	p_l16c                    	:=	l_l16c                    	;
	p_l16d                    	:=	l_l16d                    	;
	p_l16e                   	:=	l_l16e                   	;
	p_l29a                    	:=	l_l29a                    	;
	p_l29b                    	:=	l_l29b                    	;
	p_l29c                    	:=	l_l29c                    	;
	p_l29d                    	:=	l_l29d                    	;
	p_l29e                   	:=	l_l29e                   	;
	p_l30a                    	:=	l_l30a                    	;
	p_l30b                    	:=	l_l30b                    	;
	p_l30c                    	:=	l_l30c                    	;
	p_l30d                    	:=	l_l30d                    	;
	p_l30e                   	:=	l_l30e                   	;
        raise;
END  sf113a_sec1;
----
---------------------------------------------------------------------------
----
-- SeCTION II - PAYROLL
--
Procedure sf113a_sec2 (p_agcy                   IN         varchar2
                      ,p_rpt_date               IN         date
                      ,p_empl_as_of_date       IN         date
                      ,p_pay_from               IN         date
                      ,p_pay_to                 IN         date
                      ,p_segment                IN         varchar2
                      ,p_l17a                   IN OUT NOCOPY     number
                      ,p_l17b                   IN OUT NOCOPY     number
                      ,p_l17c                   IN OUT NOCOPY     number
                      ,p_l17d                   IN OUT NOCOPY     number
                      ,p_l17e                   IN OUT NOCOPY     number
                      ,p_l18a                   IN OUT NOCOPY     number
                      ,p_l18b                   IN OUT NOCOPY     number
                      ,p_l18c                   IN OUT NOCOPY     number
                      ,p_l18d                   IN OUT NOCOPY     number
                      ,p_l18e                   IN OUT NOCOPY     number
                      ,p_l31a                   IN OUT NOCOPY     number
                      ,p_l31b                   IN OUT NOCOPY     number
                      ,p_l31c                   IN OUT NOCOPY     number
                      ,p_l31d                   IN OUT NOCOPY     number
                      ,p_l31e                   IN OUT NOCOPY     number)  IS

l_total_sal     number;
l_total_lump    number;

-- NOCOPY changes
l_l17a                       number;
l_l17b                       number;
l_l17c                       number;
l_l17d                       number;
l_l17e                       number;
l_l18a                       number;
l_l18b                       number;
l_l18c                       number;
l_l18d                       number;
l_l18e                       number;
l_l31a                       number;
l_l31b                       number;
l_l31c                       number;
l_l31d                       number;
l_l31e                       number;
--
l_pa_effective_start_date per_all_assignments_f.effective_start_date%type;
l_pa_system_status per_assignment_status_types.per_system_status%type;
---

 CURSOR sf113_section2 IS
 SELECT gp.total_salary_amount,
        gp.lump_sum_amount,
          SUBSTR(hds.state_or_country_code, 1, 2) state_or_country_code,
          hds.msa_code,
          pp.position_id,
		  pa.effective_start_date,
		  past.per_system_status
   FROM per_assignments_f pa,
        per_assignment_status_types past,
        GHR_PAYROLL gp,
        HR_ALL_POSITIONS_F pp,
        PER_POSITION_DEFINITIONS ppd,
        GHR_DUTY_STATIONS_F hds,
        HR_LOCATION_EXTRA_INFO hlei,
		PER_GRADES pg,
        PER_GRADE_DEFINITIONS pgd
  WHERE DECODE(p_segment,'SEGMENT1',ppd.segment1
                       ,'SEGMENT2',ppd.segment2
                       ,'SEGMENT3',ppd.segment3
                       ,'SEGMENT4',ppd.segment4
                       ,'SEGMENT5',ppd.segment5
                       ,'SEGMENT6',ppd.segment6
                       ,'SEGMENT7',ppd.segment7
                       ,'SEGMENT8',ppd.segment8
                       ,'SEGMENT9',ppd.segment9
                       ,'SEGMENT10',ppd.segment10
                       ,'SEGMENT11',ppd.segment11
                       ,'SEGMENT12',ppd.segment12
                       ,'SEGMENT13',ppd.segment13
                       ,'SEGMENT14',ppd.segment14
                       ,'SEGMENT15',ppd.segment15
                       ,'SEGMENT16',ppd.segment16
                       ,'SEGMENT17',ppd.segment17
                       ,'SEGMENT18',ppd.segment18
                       ,'SEGMENT19',ppd.segment19
                       ,'SEGMENT20',ppd.segment20
                       ,'SEGMENT21',ppd.segment21
                       ,'SEGMENT22',ppd.segment22
                       ,'SEGMENT23',ppd.segment23
                       ,'SEGMENT24',ppd.segment24
                       ,'SEGMENT25',ppd.segment25
                       ,'SEGMENT26',ppd.segment26
                       ,'SEGMENT27',ppd.segment27
                       ,'SEGMENT28',ppd.segment28
                       ,'SEGMENT29',ppd.segment29
                       ,'SEGMENT30',ppd.segment30) like ''||p_agcy||''
  AND (p_rpt_date between pa.effective_start_date and pa.effective_end_date)
  AND (trunc(p_rpt_date) between hds.effective_start_date and nvl(hds.effective_end_date, p_rpt_date))
  AND (gp.date_from between p_pay_from and p_pay_to)
  AND TRUNC(p_rpt_date) BETWEEN pp.effective_start_date AND pp.effective_end_date
  AND pa.location_id                             = hlei.location_id
  AND hlei.information_type                     = 'GHR_US_LOC_INFORMATION'
  AND pp.position_definition_id         = ppd.position_definition_id
  AND to_number(hlei.lei_information3)  = hds.duty_station_id
  AND gp.person_id                              = pa.person_id
  AND pa.assignment_status_type_id = past.assignment_status_type_id
  AND  pp.position_id     = pa.position_id
  AND (pa.assignment_type <> 'B')
  AND pa.primary_flag = 'Y'
  AND pg.grade_id                               = pa.grade_id +0
  AND pg.grade_definition_id                    = pgd.grade_definition_id
  AND (past.per_system_status IN ('ACTIVE_ASSIGN', 'TERM_ASSIGN'))
  AND SUBSTR (pgd.segment1, 1, 2) NOT IN ('CC', 'NA', 'NL', 'NS');


BEGIN
-- NOCOPY changes
  l_l17a                                  :=      p_l17a ;
  l_l17b                                  :=      p_l17b ;
  l_l17c                                  :=      p_l17c;
  l_l17d                                  :=      p_l17d;
  l_l17e                                  :=      p_l17e;
  l_l18a                                  :=      p_l18a;
  l_l18b                                  :=      p_l18b;
  l_l18c                                  :=      p_l18c ;
  l_l18d                                  :=      p_l18d;
  l_l18e                                  :=      p_l18e;
  l_l31a                                  :=      p_l31a;
  l_l31b                                  :=      p_l31b;
  l_l31c                                  :=      p_l31c;
  l_l31d                                  :=      p_l31d;
  l_l31e                                  :=      p_l31e;

   OPEN sf113_section2;
   LOOP
        FETCH sf113_section2  INTO l_total_sal,l_total_lump, l_duty_station_code, l_msa_code, l_position_id,l_pa_effective_start_date,l_pa_system_status;
        EXIT WHEN SF113_SECTION2%NOTFOUND;
	-- Below Condition have been moved from cursor to here, to improve performance.
	IF (l_pa_system_status = 'ACTIVE_ASSIGN') OR (l_pa_system_status = 'TERM_ASSIGN' AND l_pa_effective_start_date = p_rpt_date) THEN

     -- Exclude NAF positions (Non-Apropriated Fund Positions) using CPDF dynamics function
     IF NOT ghr_cpdf_dynrpt.exclude_position(l_position_id, p_rpt_date) THEN

    l_duty_station := hr_api.g_varchar2;
          IF l_duty_station_code  in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                      'RM','HQ','PS','BQ','WQ','VQ') THEN
             p_l17b :=  p_l17b + l_total_sal;
          ELSIF l_duty_station_code  not in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                               'RM','HQ','PS','BQ','WQ','VQ')
           and (l_duty_station_code  >= 'AA'  and l_duty_station_code  <= 'ZZ') THEN
           p_l17c :=  p_l17c + l_total_sal;
          ELSIF   (nvl(l_msa_code,hr_api.g_varchar2) = '8840'
                  or nvl(l_msa_code,hr_api.g_varchar2) = '47900' )
                 and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
           p_l17d :=  p_l17d + l_total_sal;
          ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) <> '8840'
                  or nvl(l_msa_code,hr_api.g_varchar2) <> '47900'
                     or l_msa_code is null )
                 and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
           p_l17e :=  p_l17e + l_total_sal;
          END IF;
          IF l_duty_station_code  in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                      'RM','HQ','PS','BQ','WQ','VQ') THEN
           p_l18b :=  p_l18b + l_total_lump;
          ELSIF  l_duty_station_code  not in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                               'RM','HQ','PS','BQ','WQ','VQ')
           and (l_duty_station_code  >= 'AA'  and l_duty_station_code  <= 'ZZ') THEN
             p_l18c :=  p_l18c + l_total_lump;
          ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) = '8840'
                 or nvl(l_msa_code,hr_api.g_varchar2) = '47900' )
                and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
             p_l18d :=  p_l18d + l_total_lump;
          ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) <> '8840'
                  or nvl(l_msa_code,hr_api.g_varchar2) <> '47900'
                  or l_msa_code is null )
                 and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
             p_l18e :=  p_l18e + l_total_lump;
          END IF;
     END IF;
	END IF; -- 	IF (l_pa_system_status = 'ACTIVE_ASSIGN')
   END LOOP;
   p_l17b := round(p_l17b/1000);
   p_l17c := round(p_l17c/1000);
   p_l17d := round(p_l17d/1000);
   p_l17e := round(p_l17e/1000);
   p_l18b := round(p_l18b/1000);
   p_l18c := round(p_l18c/1000);
   p_l18d := round(p_l18d/1000);
   p_l18e := round(p_l18e/1000);

   p_l17a := p_l17b + p_l17c + p_l17d + p_l17e;
   p_l18a := p_l18b + p_l18c + p_l18d + p_l18e;

   p_l31b := p_l17b + p_l18b;
   p_l31c := p_l17c + p_l18c;
   p_l31d := p_l17d + p_l18d;
   p_l31e := p_l17e + p_l18e;
   p_l31a := p_l31b + p_l31c + p_l31d + p_l31e;

   CLOSE sf113_section2;

EXCEPTION
WHEN OTHERS THEN

-- NOCOPY changes
        p_l17a                          	:=	l_l17a;
        p_l17b                          	:=	l_l17b;
        p_l17c                          	:=	l_l17c;
	p_l17d                          	:=	l_l17d;
	p_l17e                          	:=	l_l17e;
	p_l18a                          	:=	l_l18a;
	p_l18b                          	:=	l_l18b;
	p_l18c                          	:=	l_l18c;
	p_l18d                          	:=	l_l18d;
	p_l18e                           	:=	l_l18e;
	p_l31a                          	:=	l_l31a;
	p_l31b                          	:=	l_l31b;
	p_l31c                          	:=	l_l31c;
	p_l31d                          	:=	l_l31d;
	p_l31e                          	:=	l_l31e;
        raise;
END sf113a_sec2;

-----
--------------------------------------------------------------------------------
-----
-- SECTION III - TURNOVER
--
Procedure sf113a_sec3 (p_agcy                   IN         varchar2
                      ,p_rpt_date               IN         date
                      ,p_empl_as_of_date        IN         date
                      ,p_last_rpt_date          IN         date
                      ,p_pay_from               IN         date
                      ,p_pay_to                 IN         date
                      ,p_segment                IN         varchar2
                      ,p_l19a                   IN OUT NOCOPY     number
                      ,p_l19b                   IN OUT NOCOPY     number
                      ,p_l19c                   IN OUT NOCOPY     number
                      ,p_l19d                   IN OUT NOCOPY     number
                      ,p_l19e                   IN OUT NOCOPY     number
                      ,p_l20a                   IN OUT NOCOPY     number
                      ,p_l20b                   IN OUT NOCOPY     number
                      ,p_l20c                   IN OUT NOCOPY     number
                      ,p_l20d                   IN OUT NOCOPY     number
                      ,p_l20e                   IN OUT NOCOPY     number
                      ,p_l21a                   IN OUT NOCOPY     number
                      ,p_l21b                   IN OUT NOCOPY     number
                      ,p_l21c                   IN OUT NOCOPY     number
                      ,p_l21d                   IN OUT NOCOPY     number
                      ,p_l21e                   IN OUT NOCOPY     number
                      ,p_l22a                   IN OUT NOCOPY     number
                      ,p_l22b                   IN OUT NOCOPY     number
                      ,p_l22c                   IN OUT NOCOPY     number
                      ,p_l22d                   IN OUT NOCOPY     number
                      ,p_l22e                   IN OUT NOCOPY     number
                      ,p_l23a                   IN OUT NOCOPY     number
                      ,p_l23b                   IN OUT NOCOPY     number
                      ,p_l23c                   IN OUT NOCOPY     number
                      ,p_l23d                   IN OUT NOCOPY     number
                      ,p_l23e                   IN OUT NOCOPY     number
                      ,p_l24a                   IN OUT NOCOPY     number
                      ,p_l24b                   IN OUT NOCOPY     number
                      ,p_l24c                   IN OUT NOCOPY     number
                      ,p_l24d                   IN OUT NOCOPY     number
                      ,p_l24e                   IN OUT NOCOPY     number
                      ,p_l25a                   IN OUT NOCOPY     number
                      ,p_l25b                   IN OUT NOCOPY     number
                      ,p_l25c                   IN OUT NOCOPY     number
                      ,p_l25d                   IN OUT NOCOPY     number
                      ,p_l25e                   IN OUT NOCOPY     number
                      ,p_l26a                   IN OUT NOCOPY     number
                      ,p_l26b                   IN OUT NOCOPY     number
                      ,p_l26c                   IN OUT NOCOPY     number
                      ,p_l26d                   IN OUT NOCOPY     number
                      ,p_l26e                   IN OUT NOCOPY     number
                      ,p_l27a                   IN OUT NOCOPY     number
                      ,p_l27b                   IN OUT NOCOPY     number
                      ,p_l27c                   IN OUT NOCOPY     number
                      ,p_l27d                   IN OUT NOCOPY     number
                      ,p_l27e                   IN OUT NOCOPY     number
                      ,p_l28a                   IN OUT NOCOPY     number
                      ,p_l28b                   IN OUT NOCOPY     number
                      ,p_l28c                   IN OUT NOCOPY     number
                      ,p_l28d                   IN OUT NOCOPY     number
                      ,p_l28e                   IN OUT NOCOPY     number)
IS
--
-- NOCOPY changes
l_l19a          number;
l_l19b          number;
l_l19c          number;
l_l19d          number;
l_l19e    	number;
l_l20a    	number;
l_l20b    	number;
l_l20c    	number;
l_l20d    	number;
l_l20e         	number;
l_l21a    	number;
l_l21b    	number;
l_l21c    	number;
l_l21d    	number;
l_l21e    	number;
l_l22a    	number;
l_l22b    	number;
l_l22c    	number;
l_l22d    	number;
l_l22e   	number;
l_l23a    	number;
l_l23b    	number;
l_l23c    	number;
l_l23d    	number;
l_l23e   	number;
l_l24a    	number;
l_l24b    	number;
l_l24c    	number;
l_l24d    	number;
l_l24e   	number;
l_l25a    	number;
l_l25b    	number;
l_l25c    	number;
l_l25d    	number;
l_l25e    	number;
l_l26a    	number;
l_l26b    	number;
l_l26c    	number;
l_l26d    	number;
l_l26e   	number;
l_l27a    	number;
l_l27b    	number;
l_l27c    	number;
l_l27d    	number;
l_l27e   	number;
l_l28a    	number;
l_l28b    	number;
l_l28c    	number;
l_l28d    	number;
l_l28e   	number;
--
-- cursor sf113_separation is for line 25 and 28 only

CURSOR sf113_separation IS
   SELECT v.status,
            v.position_id pos_id,
            v.effective_start_date start_date,
            v.effective_end_date end_date,
            v.assignment_id,                                -- Bug 3264666 Anil
            gpr.person_id,
            gpr.noa_family_code,
            gpr.first_action_la_code1,
            gnoa.code,
            SUBSTR(hds.state_or_country_code, 1, 2) state_or_country_code,
            hds.msa_code,
            gpr.effective_date

   FROM   GHR_SF113_V v,
          GHR_PA_REQUESTS gpr,
          GHR_NATURE_OF_ACTIONS gnoa,
          HR_ALL_POSITIONS_F pp,
          PER_POSITION_DEFINITIONS ppd,
          GHR_DUTY_STATIONS_F hds

   WHERE DECODE(p_segment,'SEGMENT1',ppd.segment1
                       ,'SEGMENT2',ppd.segment2
                       ,'SEGMENT3',ppd.segment3
                       ,'SEGMENT4',ppd.segment4
                       ,'SEGMENT5',ppd.segment5
                       ,'SEGMENT6',ppd.segment6
                       ,'SEGMENT7',ppd.segment7
                       ,'SEGMENT8',ppd.segment8
                       ,'SEGMENT9',ppd.segment9
                       ,'SEGMENT10',ppd.segment10
                       ,'SEGMENT11',ppd.segment11
                       ,'SEGMENT12',ppd.segment12
                       ,'SEGMENT13',ppd.segment13
                       ,'SEGMENT14',ppd.segment14
                       ,'SEGMENT15',ppd.segment15
                       ,'SEGMENT16',ppd.segment16
                       ,'SEGMENT17',ppd.segment17
                       ,'SEGMENT18',ppd.segment18
                       ,'SEGMENT19',ppd.segment19
                       ,'SEGMENT20',ppd.segment20
                       ,'SEGMENT21',ppd.segment21
                       ,'SEGMENT22',ppd.segment22
                       ,'SEGMENT23',ppd.segment23
                       ,'SEGMENT24',ppd.segment24
                       ,'SEGMENT25',ppd.segment25
                       ,'SEGMENT26',ppd.segment26
                       ,'SEGMENT27',ppd.segment27
                       ,'SEGMENT28',ppd.segment28
                       ,'SEGMENT29',ppd.segment29
                       ,'SEGMENT30',ppd.segment30) like ''||p_agcy||''
   AND gpr.effective_date between p_last_rpt_date  and p_rpt_date
   AND (trunc(p_rpt_date) between hds.effective_start_date and nvl(hds.effective_end_date, p_rpt_date))
   AND gpr.effective_date between v.effective_start_date AND v.effective_end_date+1
   AND gpr.pa_notification_id is not null
   AND gpr.noa_family_code     IN ('SEPARATION','NON_PAY_DUTY_STATUS')
   AND NVL(gpr.first_noa_cancel_or_correct,'CORR') <> 'CANCEL'
   AND gpr.duty_station_code                    = hds.duty_station_code
   AND (gnoa.nature_of_action_id                = gpr.first_noa_id)
   AND (nvl(gpr.to_position_id,gpr.from_position_id) = pp.position_id)
   AND (TRUNC(p_rpt_date) BETWEEN pp.effective_start_date AND pp.effective_end_date)
   AND (pp.position_definition_id               = ppd.position_definition_id)
   AND (gpr.person_id                           = v.person_id);

-- Bug 3792359 Added condition linking sf_113v and ghr_pa_requests on the column effective date
-- end date incremented by 1 to include suspended employees.

-- Bug 3264666  Anil

CURSOR chk_susp_asg_status is
 SELECT 'X'
 FROM  per_assignments_f asg,
       per_assignment_status_types ast

 WHERE    asg.assignment_id = l_assignment_id
      AND p_empl_as_of_date between asg.effective_start_date
      AND asg.effective_end_date
      AND asg.primary_flag = 'Y'
      AND asg.assignment_type <> 'B'
      AND asg.assignment_status_type_id = ast.assignment_status_type_id
      AND ast.per_system_status = 'SUSP_ASSIGN';

-- End of 3264666

 CURSOR sf113_section3 IS
   SELECT       v.status,
                v.position_id pos_id,
                v.effective_start_date start_date,
                v.effective_end_date end_date,
                gpr.person_id,
                gpr.noa_family_code,
                gpr.first_action_la_code1,
                gnoa.code,
                SUBSTR(hds.state_or_country_code, 1, 2) state_or_country_code,
                hds.msa_code,
                gpr.effective_date

   FROM         GHR_SF113_V v,
                GHR_PA_REQUESTS gpr,
                GHR_NATURE_OF_ACTIONS gnoa,
                HR_ALL_POSITIONS_F pp,
                PER_POSITION_DEFINITIONS ppd,
                GHR_DUTY_STATIONS_F hds

   WHERE DECODE(p_segment,'SEGMENT1',ppd.segment1
                       ,'SEGMENT2',ppd.segment2
                       ,'SEGMENT3',ppd.segment3
                       ,'SEGMENT4',ppd.segment4
                       ,'SEGMENT5',ppd.segment5
                       ,'SEGMENT6',ppd.segment6
                       ,'SEGMENT7',ppd.segment7
                       ,'SEGMENT8',ppd.segment8
                       ,'SEGMENT9',ppd.segment9
                       ,'SEGMENT10',ppd.segment10
                       ,'SEGMENT11',ppd.segment11
                       ,'SEGMENT12',ppd.segment12
                       ,'SEGMENT13',ppd.segment13
                       ,'SEGMENT14',ppd.segment14
                       ,'SEGMENT15',ppd.segment15
                       ,'SEGMENT16',ppd.segment16
                       ,'SEGMENT17',ppd.segment17
                       ,'SEGMENT18',ppd.segment18
                       ,'SEGMENT19',ppd.segment19
                       ,'SEGMENT20',ppd.segment20
                       ,'SEGMENT21',ppd.segment21
                       ,'SEGMENT22',ppd.segment22
                       ,'SEGMENT23',ppd.segment23
                       ,'SEGMENT24',ppd.segment24
                       ,'SEGMENT25',ppd.segment25
                       ,'SEGMENT26',ppd.segment26
                       ,'SEGMENT27',ppd.segment27
                       ,'SEGMENT28',ppd.segment28
                       ,'SEGMENT29',ppd.segment29
                       ,'SEGMENT30',ppd.segment30) like ''||p_agcy||''
    AND gpr.effective_date between ''||p_pay_from||''  and ''||p_pay_to||''
    AND (''||trunc(p_rpt_date)||'' between hds.effective_start_date and nvl(hds.effective_end_date, p_rpt_date))
    AND gpr.pa_notification_id is not null
    AND gpr.duty_station_code                   = hds.duty_station_code
    AND (gnoa.nature_of_action_id               = gpr.first_noa_id)
    AND (nvl(gpr.to_position_id,gpr.from_position_id) = pp.position_id)
    AND (TRUNC(p_rpt_date) BETWEEN pp.effective_start_date AND pp.effective_end_date)
    AND (pp.position_definition_id              = ppd.position_definition_id)
    AND (gpr.person_id                          = v.person_id);


BEGIN
  -- NOCOPY changes
	l_l19a    	:=	p_l19a    	;
	l_l19b    	:=	p_l19b    	;
	l_l19c    	:=	p_l19c    	;
	l_l19d    	:=	p_l19d    	;
	l_l19e    	:=	p_l19e    	;
	l_l20a    	:=	p_l20a    	;
	l_l20b    	:=	p_l20b    	;
	l_l20c    	:=	p_l20c    	;
	l_l20d    	:=	p_l20d    	;
	l_l20e          :=	p_l20e          ;
	l_l21a    	:=	p_l21a    	;
	l_l21b    	:=	p_l21b    	;
	l_l21c    	:=	p_l21c    	;
	l_l21d    	:=	p_l21d    	;
	l_l21e    	:=	p_l21e    	;
	l_l22a    	:=	p_l22a    	;
	l_l22b    	:=	p_l22b    	;
	l_l22c    	:=	p_l22c    	;
	l_l22d    	:=	p_l22d    	;
	l_l22e   	:=	p_l22e   	;
	l_l23a    	:=	p_l23a    	;
	l_l23b    	:=	p_l23b    	;
	l_l23c    	:=	p_l23c    	;
	l_l23d    	:=	p_l23d    	;
	l_l23e   	:=	p_l23e   	;
	l_l24a    	:=	p_l24a    	;
	l_l24b    	:=	p_l24b    	;
	l_l24c    	:=	p_l24c    	;
	l_l24d    	:=	p_l24d    	;
	l_l24e   	:=	p_l24e   	;
	l_l25a    	:=	p_l25a    	;
	l_l25b    	:=	p_l25b    	;
	l_l25c    	:=	p_l25c    	;
	l_l25d    	:=	p_l25d    	;
	l_l25e    	:=	p_l25e    	;
	l_l26a    	:=	p_l26a    	;
	l_l26b    	:=	p_l26b    	;
	l_l26c    	:=	p_l26c    	;
	l_l26d    	:=	p_l26d    	;
	l_l26e   	:=	p_l26e   	;
	l_l27a    	:=	p_l27a    	;
	l_l27b    	:=	p_l27b    	;
	l_l27c    	:=	p_l27c    	;
	l_l27d    	:=	p_l27d    	;
	l_l27e   	:=	p_l27e   	;
	l_l28a    	:=	p_l28a    	;
	l_l28b    	:=	p_l28b    	;
	l_l28c    	:=	p_l28c    	;
	l_l28d    	:=	p_l28d    	;
	l_l28e   	:=	p_l28e   	;





    OPEN sf113_separation;
    LOOP

-- JH Added    AND gpr.noa_family_code IN ('SEPARATION','NON_PAY_DUTY_STATUS') to cursor.
       FETCH sf113_separation  INTO  l_status, l_position_id, l_start_date, l_end_date, l_assignment_id, l_person_id,   -- Bug 3264666 Anil
                                      l_noa_family_code,l_first_action_la_code1, l_code,
                                      l_duty_station_code,l_msa_code, l_effective_date;

       EXIT WHEN SF113_SEPARATION%NOTFOUND;


-- Exclude NAF positions (Non-Appropriate Fund positions)
   --Begin Bug# 8928564
  ghr_history_fetch.fetch_positionei(
    p_position_id         => l_position_id
   ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
   ,p_date_effective      => p_rpt_date
   ,p_pos_ei_data         => l_pos_hist_data);
  --
  l_pay_basis := l_pos_hist_data.poei_information6;
  IF l_pay_basis NOT IN ('PD','WC') THEN
  --end Bug# 8928564

        IF NOT ghr_cpdf_dynrpt.exclude_position(l_position_id, p_rpt_date) THEN

                l_duty_station := hr_api.g_varchar2;

-- Bug 3264666
-- Check if the NTE date more than report date + 30 days.

                l_susp_flag := 'N';
                FOR c_chk_ast_status IN chk_susp_asg_status
                LOOP
                        GHR_HISTORY_FETCH.fetch_asgei(l_assignment_id,'GHR_US_ASG_NTE_DATES',p_rpt_date, l_asgn_hist_data);
                        l_lwop_nte_date     := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information6);
                        l_susp_nte_date     := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information8);
                        l_furlough_nte_date := fnd_date.canonical_to_date(l_asgn_hist_data.aei_information10);

                        hr_utility.set_location(' lwop date is ' || l_lwop_nte_date, 1);
                        hr_utility.set_location(' susp date is ' || l_susp_nte_date, 1);
                        hr_utility.set_location(' furlough date is ' || l_furlough_nte_date, 1);
						-- NOAs 430,452, 473 doesnt have NTE dates. hence they're considered as separations
						-- when counting for line 25 without any 30 days check.
						IF l_code IN ('430','452','473') THEN
							l_susp_flag := 'Y';
						ELSE
							IF (nvl(l_lwop_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30 )  or
							   (nvl(l_susp_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30  ) or
							   (nvl(l_furlough_nte_date,p_empl_as_of_date) > p_empl_as_of_date + 30 ) then
									 l_susp_flag := 'Y';
							END IF;
						END IF;
                 END LOOP;

-- End of Bug 3264666
					-- Bug 3792359 Shd include 430,452,473 when in non-pay status
                 IF l_code in ('300','301','302','303','304','312','317','330','350','351','352',
                               '353','354','355','356','357','385','386','390')
                    or (l_code in ('450','460','472','430','452','473')  and l_susp_flag='Y') then
-- bug#2898787
                         IF l_duty_station_code  in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                                     'RM','HQ','PS','BQ','WQ','VQ')       THEN
                                  l_duty_station := 'T';
                         ELSIF   l_duty_station_code  not in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                                            'RM','HQ','PS','BQ','WQ','VQ')
                             AND (l_duty_station_code  >= 'AA'  and l_duty_station_code  <= 'ZZ') THEN
                                  l_duty_station := 'F';
                         ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) = '8840'
                              or nvl(l_msa_code,hr_api.g_varchar2) = '47900' )
                                AND (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
                                  l_duty_station := 'W';
                         ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) <> '8840'
                              or nvl(l_msa_code,hr_api.g_varchar2) <> '47900'
                                  or l_msa_code is null )
                                AND (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
                                  l_duty_station := 'O';
                         END IF;

                         GHR_HISTORY_FETCH.fetch_peopleei(l_person_id,'GHR_US_PER_SF52',
                                                           p_rpt_date,l_people_hist_data);

                         l_citizenship := l_people_hist_data.pei_information3;

                         hr_utility.set_location('l_person_id is ' || l_person_id ,3);
                         hr_utility.set_location('l_citizenship is ' || l_citizenship ,3);
                         hr_utility.set_location('l_duty_station is ' || l_duty_station ,3);
                         hr_utility.set_location('l_duty_station_code is ' || l_duty_station_code ,3);
                         hr_utility.set_location('l_msa_code is ' || l_msa_code ,3);

                         IF l_effective_date <> p_empl_as_of_date THEN
        -- Line 25 - 27


                                IF l_duty_station = 'T' THEN
                                        p_l25b :=  p_l25b + 1;
                                ELSIF l_duty_station = 'F' THEN
                                        p_l25c :=  p_l25c + 1;
                                ELSIF l_duty_station = 'W' THEN
                                        p_l25d :=  p_l25d + 1;
                                ELSIF l_duty_station = 'O' THEN
                                        p_l25e :=  p_l25e + 1;
                                END IF;


                                p_l25a := p_l25b + p_l25c + p_l25d + p_l25e;

                                IF l_code = '352' and  l_first_action_la_code1 not in ('PZM','ZPM')  THEN
                                        IF l_duty_station = 'T' THEN
                                                p_l26b :=  p_l26b + 1;
                                        ELSIF l_duty_station = 'F' THEN
                                                p_l26c :=  p_l26c + 1;
                                        ELSIF l_duty_station = 'W' THEN
                                                p_l26d :=  p_l26d + 1;
                                        ELSIF l_duty_station = 'O' THEN
                                                p_l26e :=  p_l26e + 1;
                                        END IF;
                                        p_l26a := p_l26b + p_l26c + p_l26d + p_l26e ;
                                END IF;

                                IF ((l_code = '312' and  l_first_action_la_code1  in ('RPR','RWM','RXM','RPM','RQM','RRM','RSM') )
                                    or (l_code = '317' and l_first_action_la_code1 in ('RPM','RUM') )
                                    or (l_code = '330' and l_first_action_la_code1 in ('V9A','V9B','VJJ','V2J') )
                                    or (l_code = '357' and l_first_action_la_code1 in ('C7M','USM','UTM') )
                                    or l_code in ('351','353'))  THEN

                                    IF l_duty_station = 'T' THEN
                                        p_l27b :=  p_l27b + 1;
                                    ELSIF l_duty_station = 'F' THEN
                                        p_l27c :=  p_l27c + 1;
                                    ELSIF l_duty_station = 'W' THEN
                                        p_l27d :=  p_l27d + 1;
                                    ELSIF l_duty_station = 'O' THEN
                                        p_l27e :=  p_l27e + 1;
                                    END IF;
                                    p_l27a := p_l27b + p_l27c + p_l27d + p_l27e ;
                                END IF;

                -- Line 28
                                IF l_citizenship = '1' THEN
                                    IF l_duty_station = 'T' THEN
                                        p_l28b :=  p_l28b + 1;
                                    ELSIF l_duty_station = 'F' THEN
                                        p_l28c :=  p_l28c + 1;
                                    ELSIF l_duty_station = 'W' THEN
                                        p_l28d :=  p_l28d + 1;
                                    ELSIF l_duty_station = 'O' THEN
                                        p_l28e :=  p_l28e + 1;
                                    END IF;
                                    p_l28a := p_l28b + p_l28c + p_l28d + p_l28e ;
                                END IF;
                        END IF;
                END IF;
     END IF;
     END IF;  --IF l_pay_basis NOT IN ('PD','WC') Bug# 8928564
   END LOOP;

   CLOSE sf113_separation;


   OPEN sf113_section3;
   LOOP
        FETCH sf113_section3  INTO  l_status, l_position_id, l_start_date, l_end_date, l_person_id,
                                    l_noa_family_code,l_first_action_la_code1, l_code,
                                    l_duty_station_code,l_msa_code, l_effective_date;

        EXIT WHEN sf113_section3%NOTFOUND;

 --Begin Bug# 8928564
  ghr_history_fetch.fetch_positionei(
    p_position_id         => l_position_id
   ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
   ,p_date_effective      => p_rpt_date
   ,p_pos_ei_data         => l_pos_hist_data);
  --
  l_pay_basis := l_pos_hist_data.poei_information6;
  IF l_pay_basis NOT IN ('PD','WC') THEN
  --end Bug# 8928564
-- Exclude NAF positions (Non-Appropriate Fund positions)
        IF NOT ghr_cpdf_dynrpt.exclude_position(l_position_id, p_rpt_date) THEN

                l_duty_station := hr_api.g_varchar2;

                IF l_duty_station_code  in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                            'RM','HQ','PS','BQ','WQ','VQ') THEN
                              l_duty_station := 'T';
                ELSIF  l_duty_station_code  not in ('GQ','RQ','AQ','FM','JQ','CQ','MQ',
                                                     'RM','HQ','PS','BQ','WQ','VQ')
                        and (l_duty_station_code  >= 'AA'  and l_duty_station_code  <= 'ZZ') THEN
                              l_duty_station := 'F';
                ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) = '8840'
                       or nvl(l_msa_code,hr_api.g_varchar2) = '47900' )
                      and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
                              l_duty_station := 'W';
                ELSIF  (nvl(l_msa_code,hr_api.g_varchar2) <> '8840'
                          or nvl(l_msa_code,hr_api.g_varchar2) <> '47900'
                          or l_msa_code is null )
                      and (l_duty_station_code  >= '00' and l_duty_station_code  <= '99') THEN
                               l_duty_station := 'O';
                END IF;

                GHR_HISTORY_FETCH.fetch_peopleei(l_person_id,'GHR_US_PER_SF52',p_rpt_date,l_people_hist_data);
                l_citizenship         := l_people_hist_data.pei_information3;

                GHR_HISTORY_FETCH.fetch_positionei(l_position_id,'GHR_US_POS_GRP2',p_rpt_date,
                                                                                l_pos_hist_data );
                l_position_code  := l_pos_hist_data.poei_information3;

                hr_utility.set_location('l_person_id is ' || l_person_id ,3);
                hr_utility.set_location('l_code is ' || l_code ,3);
                hr_utility.set_location('l_position_code is ' || l_position_code ,3);
                hr_utility.set_location('l_position_id is ' || l_position_id ,3);
                hr_utility.set_location('l_citizenship is ' || l_citizenship ,3);
                hr_utility.set_location('l_duty_station is ' || l_duty_station ,3);
                hr_utility.set_location('l_duty_station_code is ' || l_duty_station_code ,3);
                hr_utility.set_location('l_msa_code is ' || l_msa_code ,3);

                IF l_code in ('100', '101', '107', '108', '112', '115',
                              '117', '120', '122', '124', '130', '132',
                              '140', '141', '142', '143', '145', '146',
                              '147', '148', '149', '150', '151', '153',
                              '154', '155', '157', '170', '171', '190',
                              '198','199', '280', '292','293')
                THEN
                         IF l_duty_station = 'T' THEN
                                p_l19b :=  p_l19b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l19c :=  p_l19c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l19d :=  p_l19d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l19e :=  p_l19e + 1;
                         END IF;
                         p_l19a := p_l19b + p_l19c + p_l19d + p_l19e ;
                END IF;
                IF (l_code in ('130','132','145','147','157')
                    or  (l_code in ('100','101')
                    and l_first_action_la_code1 in ('K4M','BKM','BBM','V8L','BLM','BNM','BNN')))  THEN
                         IF l_duty_station = 'T' THEN
                                p_l20b :=  p_l20b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l20c :=  p_l20c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l20d :=  p_l20d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l20e :=  p_l20e + 1;
                         END IF;
                         p_l20a := p_l20b + p_l20c + p_l20d + p_l20e ;
                END IF;
                IF( l_code in ('107','108','112','115','117','120',
                               '122','124','140','141','142','143',
                               '146', '148','149','150','151','153',
                               '154','155','170','171','190','198','199')
                   OR
                  (l_code in ('100','101')
                   and  l_first_action_la_code1
                                           not in ('K4M','BKM','BBM','V8L',
                                                                   'BLM','BNM','BNN'))) THEN
                         IF l_duty_station = 'T' THEN
                                p_l21b :=  p_l21b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l21c :=  p_l21c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l21d :=  p_l21d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l21e :=  p_l21e + 1;
                         END IF;
                         p_l21a := p_l21b + p_l21c + p_l21d + p_l21e ;
                END IF;
                IF l_code in  ('100','101','107','108','112','115',
                               '117','120','122','124','130','132',
                               '140','141','190','198','199','280',
                               '292','293')
                      and l_position_code  = '1'
                THEN
                         IF l_duty_station = 'T' THEN
                                p_l22b :=  p_l22b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l22c :=  p_l22c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l22d :=  p_l22d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l22e :=  p_l22e + 1;
                         END IF;
                         p_l22a := p_l22b + p_l22c + p_l22d + p_l22e ;
                END IF;
                IF (l_code in ('107','108','112','115','117','120',
                                '122','124','140','141','190','198',
                               '199')
                   or (l_code in ('100','101')
                   and  l_first_action_la_code1 not in
                        ('K4M','BKM','BBM','V8L','BLM','BNM','BNN')))
                   and l_position_code  = '1'
                THEN
                         IF l_duty_station = 'T' THEN
                                p_l23b :=  p_l23b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l23c :=  p_l23c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l23d :=  p_l23d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l23e :=  p_l23e + 1;
                        END IF;
                        p_l23a := p_l23b + p_l23c + p_l23d + p_l23e ;
                END IF;
                IF l_code in ( '100','101','107','108','112',
                               '115','117','120','122','124',
                               '130','132','140','141','142',
                               '143','145','146','147','148',
                               '149','150','151','153','154',
                               '155','157','170','171','190',
                               '198','199','280','292','293')
                   and l_citizenship = '1'
                THEN
                         IF l_duty_station = 'T' THEN
                                p_l24b :=  p_l24b + 1;
                         ELSIF l_duty_station = 'F' THEN
                                p_l24c :=  p_l24c + 1;
                         ELSIF l_duty_station = 'W' THEN
                                p_l24d :=  p_l24d + 1;
                         ELSIF l_duty_station = 'O' THEN
                                p_l24e :=  p_l24e + 1;
                         END IF;
                         p_l24a := p_l24b + p_l24c + p_l24d + p_l24e ;
                END IF;
        END IF;
 END IF;  --IF l_pay_basis NOT IN ('PD','WC') Bug# 8928564
 END LOOP;
 CLOSE sf113_section3;

EXCEPTION                            -- NOCOPY changes
WHEN OTHERS THEN
         p_l19a     	:=	l_l19a     	;
	 p_l19b     	:=	 l_l19b     	;
	 p_l19c     	:=	 l_l19c     	;
	 p_l19d     	:=	 l_l19d     	;
	 p_l19e     	:=	 l_l19e     	;
	 p_l20a     	:=	 l_l20a     	;
	 p_l20b     	:=	 l_l20b     	;
	 p_l20c     	:=	 l_l20c     	;
	 p_l20d     	:=	 l_l20d     	;
	 p_l20e         :=	 l_l20e        	;
	 p_l21a     	:=	 l_l21a     	;
	 p_l21b     	:=	 l_l21b     	;
	 p_l21c     	:=	 l_l21c     	;
	 p_l21d     	:=	 l_l21d     	;
	 p_l21e     	:=	 l_l21e     	;
	 p_l22a     	:=	 l_l22a     	;
	 p_l22b     	:=	 l_l22b     	;
	 p_l22c     	:=	 l_l22c     	;
	 p_l22d     	:=	 l_l22d     	;
	 p_l22e    	:=	 l_l22e    	;
	 p_l23a     	:=	 l_l23a     	;
	 p_l23b     	:=	 l_l23b     	;
	 p_l23c     	:=	 l_l23c     	;
	 p_l23d     	:=	 l_l23d     	;
	 p_l23e    	:=	 l_l23e    	;
	 p_l24a     	:=	 l_l24a     	;
	 p_l24b     	:=	 l_l24b     	;
	 p_l24c     	:=	 l_l24c     	;
	 p_l24d     	:=	 l_l24d     	;
	 p_l24e    	:=	 l_l24e    	;
	 p_l25a     	:=	 l_l25a     	;
	 p_l25b     	:=	 l_l25b     	;
	 p_l25c     	:=	 l_l25c     	;
	 p_l25d     	:=	 l_l25d     	;
	 p_l25e     	:=	 l_l25e     	;
	 p_l26a     	:=	 l_l26a     	;
	 p_l26b     	:=	 l_l26b     	;
	 p_l26c     	:=	 l_l26c     	;
	 p_l26d     	:=	 l_l26d     	;
	 p_l26e    	:=	 l_l26e    	;
	 p_l27a     	:=	 l_l27a     	;
	 p_l27b     	:=	 l_l27b     	;
	 p_l27c     	:=	 l_l27c     	;
	 p_l27d     	:=	 l_l27d     	;
	 p_l27e    	:=	 l_l27e    	;
	 p_l28a     	:=	 l_l28a     	;
	 p_l28b     	:=	 l_l28b     	;
	 p_l28c     	:=	 l_l28c     	;
	 p_l28d     	:=	 l_l28d     	;
	 p_l28e    	:=	 l_l28e    	;
         raise;

END SF113A_SEC3;
-----
-----------------------------------------------------------------------
-----
PROCEDURE ghr_sf113_payroll (p_pay_from IN DATE,
                             p_pay_to   IN DATE )  is
--
--
l_count         NUMBER;
CURSOR cr IS
  SELECT int.DATE_FROM     pay_from,
         int.DATE_TO       pay_to,
         int.INFORMATION1  person_id,
         int.INFORMATION2  total_pay,
         int.INFORMATION3  lump_sum
  FROM   GHR_INTERFACE     int
  WHERE  int.SOURCE_NAME = 'PAYROLL'
  AND    int.date_from  BETWEEN  p_pay_from and  p_pay_to;

CURSOR  c_numb (l_person_id     NUMBER)  IS
  SELECT count(*)
  FROM   ghr_payroll
  WHERE  date_from  = p_pay_from
  AND    person_id  = l_person_id;

BEGIN
        FOR cr_rec IN cr LOOP
           OPEN c_numb (to_number(cr_rec.person_id));
           FETCH c_numb into l_count;
           CLOSE c_numb;
           IF  l_count = 0 THEN
                INSERT INTO ghr_payroll
                                (PAYROLL_ID,            PERSON_ID,
                                 DATE_FROM,                     DATE_TO,
                                 TOTAL_SALARY_AMOUNT,   LUMP_SUM_AMOUNT)
                VALUES  (ghr_payroll_s.nextval, to_number(cr_rec.person_id),
                                 cr_rec.pay_from,               cr_rec.pay_to,
                                 to_number(cr_rec.total_pay),   to_number(cr_rec.lump_sum));
           ELSE
                UPDATE  ghr_payroll
                SET             total_salary_amount     =       to_number(cr_rec.total_pay),
                                lump_sum_amount         =       to_number(cr_rec.lump_sum)
                WHERE           date_from  = p_pay_from
                AND             person_id  = to_number(cr_rec.person_id);
           END IF;
        END LOOP;

END ghr_sf113_payroll;
--
--This is the main procedure that generates the XML file for SF113A report.
  PROCEDURE ghr_sf113a_out(errbuf                     OUT NOCOPY VARCHAR2,
                           retcode                    OUT NOCOPY NUMBER,
                           p_agency_code           IN            VARCHAR2,
                           p_agency_subelement     IN            VARCHAR2,
                           p_business_id           IN            NUMBER,
                           p_employment_as_of_date IN            VARCHAR2,
                           p_pay_from              IN            VARCHAR2,
                           p_pay_to                IN            VARCHAR2,
                           p_previous_report_date  IN            VARCHAR2,
                           p_rpt_date              IN            VARCHAR2)
  IS
--
--Local Variables
  l_l1a  number:=0; l_l1b  number:=0; l_l1c  number:=0; l_l1d  number:=0; l_l1e  number:=0;
  l_l2a  number:=0; l_l2b  number:=0; l_l2c  number:=0; l_l2d  number:=0; l_l2e  number:=0;
  l_l3a  number:=0; l_l3b  number:=0; l_l3c  number:=0; l_l3d  number:=0; l_l3e  number:=0;
  l_l4a  number:=0; l_l4b  number:=0; l_l4c  number:=0; l_l4d  number:=0; l_l4e  number:=0;
  l_l5a  number:=0; l_l5b  number:=0; l_l5c  number:=0; l_l5d  number:=0; l_l5e  number:=0;
  l_l6a  number:=0; l_l6b  number:=0; l_l6c  number:=0; l_l6d  number:=0; l_l6e  number:=0;
  l_l7a  number:=0; l_l7b  number:=0; l_l7c  number:=0; l_l7d  number:=0; l_l7e  number:=0;
  l_l8a  number:=0; l_l8b  number:=0; l_l8c  number:=0; l_l8d  number:=0; l_l8e  number:=0;
  l_l9a  number:=0; l_l9b  number:=0; l_l9c  number:=0; l_l9d  number:=0; l_l9e  number:=0;
  l_l10a number:=0; l_l10b number:=0; l_l10c number:=0; l_l10d number:=0; l_l10e number:=0;
  l_l11a number:=0; l_l11b number:=0; l_l11c number:=0; l_l11d number:=0; l_l11e number:=0;
  l_l12a number:=0; l_l12b number:=0; l_l12c number:=0; l_l12d number:=0; l_l12e number:=0;
  l_l13a number:=0; l_l13b number:=0; l_l13c number:=0; l_l13d number:=0; l_l13e number:=0;
  l_l14a number:=0; l_l14b number:=0; l_l14c number:=0; l_l14d number:=0; l_l14e number:=0;
  l_l15a number:=0; l_l15b number:=0; l_l15c number:=0; l_l15d number:=0; l_l15e number:=0;
  l_l16a number:=0; l_l16b number:=0; l_l16c number:=0; l_l16d number:=0; l_l16e number:=0;
  l_l17a number:=0; l_l17b number:=0; l_l17c number:=0; l_l17d number:=0; l_l17e number:=0;
  l_l18a number:=0; l_l18b number:=0; l_l18c number:=0; l_l18d number:=0; l_l18e number:=0;
  l_l19a number:=0; l_l19b number:=0; l_l19c number:=0; l_l19d number:=0; l_l19e number:=0;
  l_l20a number:=0; l_l20b number:=0; l_l20c number:=0; l_l20d number:=0; l_l20e number:=0;
  l_l21a number:=0; l_l21b number:=0; l_l21c number:=0; l_l21d number:=0; l_l21e number:=0;
  l_l22a number:=0; l_l22b number:=0; l_l22c number:=0; l_l22d number:=0; l_l22e number:=0;
  l_l23a number:=0; l_l23b number:=0; l_l23c number:=0; l_l23d number:=0; l_l23e number:=0;
  l_l24a number:=0; l_l24b number:=0; l_l24c number:=0; l_l24d number:=0; l_l24e number:=0;
  l_l25a number:=0; l_l25b number:=0; l_l25c number:=0; l_l25d number:=0; l_l25e number:=0;
  l_l26a number:=0; l_l26b number:=0; l_l26c number:=0; l_l26d number:=0; l_l26e number:=0;
  l_l27a number:=0; l_l27b number:=0; l_l27c number:=0; l_l27d number:=0; l_l27e number:=0;
  l_l28a number:=0; l_l28b number:=0; l_l28c number:=0; l_l28d number:=0; l_l28e number:=0;
  l_l29a number:=0; l_l29b number:=0; l_l29c number:=0; l_l29d number:=0; l_l29e number:=0;
  l_l30a number:=0; l_l30b number:=0; l_l30c number:=0; l_l30d number:=0; l_l30e number:=0;
  l_l31a number:=0; l_l31b number:=0; l_l31c number:=0; l_l31d number:=0; l_l31e number:=0;
  l_agency_code          varchar2(50);
  l_bg_id                number;
  l_last_rpt_date        date;
  l_emp_as_of_date       date;
  l_pay_from             date;
  l_pay_to               date;
  l_rpt_date             date;
  l_previous_report_date date;
  l_segment              varchar2(100);
  l_agency_name          varchar2(1000);
  l_subelem              varchar2(1000);
  submit_failed          exception;
  l_proc                 varchar2(72) := g_package||'ghr_sf113a_main';
--
BEGIN
--
  hr_utility.set_location('Entering: '||l_proc,10);
  l_rpt_date             := fnd_date.canonical_to_date(p_rpt_date);
  l_pay_to               := fnd_date.canonical_to_date(p_pay_to);
  l_pay_from             := fnd_date.canonical_to_date(p_pay_from);
  l_emp_as_of_date       := fnd_date.canonical_to_date(p_employment_as_of_date);
  l_previous_report_date := fnd_date.canonical_to_date(p_previous_report_date);
  l_last_rpt_date        := l_previous_report_date - 1;
  l_agency_code          := p_agency_code || p_agency_subelement || '%';
--
  ghr_sf113_payroll(p_pay_from => l_pay_from,
                    p_pay_to   => l_pay_to);
--
--Get Agency, SubElement Name
  hr_utility.set_location('Set Agency and SubElement Name. '||l_proc,20);
  l_segment     := get_org_info(p_business_id);
  l_agency_name := hr_general.decode_lookup('GHR_US_AGENCY_CODE_2',p_agency_code);
  l_subelem     := hr_general.decode_lookup('GHR_US_AGENCY_CODE'
                                           ,p_agency_code||p_agency_subelement);
--
--Populate Section I
  hr_utility.set_location('Calling Procedure to Populate SectionI. '||l_proc,30);
  fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate SectionI');
  sf113a_sec1 (l_rpt_date, l_emp_as_of_date, l_agency_code, l_segment,
               l_l1a,  l_l1b,  l_l1c,  l_l1d,  l_l1e,
               l_l2a,  l_l2b,  l_l2c,  l_l2d,  l_l2e,
               l_l3a,  l_l3b,  l_l3c,  l_l3d,  l_l3e,
               l_l4a,  l_l4b,  l_l4c,  l_l4d,  l_l4e,
               l_l5a,  l_l5b,  l_l5c,  l_l5d,  l_l5e,
               l_l6a,  l_l6b,  l_l6c,  l_l6d,  l_l6e,
               l_l7a,  l_l7b,  l_l7c,  l_l7d,  l_l7e,
               l_l8a,  l_l8b,  l_l8c,  l_l8d,  l_l8e,
               l_l9a,  l_l9b,  l_l9c,  l_l9d,  l_l9e,
               l_l10a, l_l10b, l_l10c, l_l10d, l_l10e,
               l_l11a, l_l11b, l_l11c, l_l11d, l_l11e,
               l_l12a, l_l12b, l_l12c, l_l12d, l_l12e,
               l_l13a, l_l13b, l_l13c, l_l13d, l_l13e,
               l_l14a, l_l14b, l_l14c, l_l14d, l_l14e,
               l_l15a, l_l15b, l_l15c, l_l15d, l_l15e,
               l_l16a, l_l16b, l_l16c, l_l16d, l_l16e,
               l_l29a, l_l29b, l_l29c, l_l29d, l_l29e,
               l_l30a, l_l30b, l_l30c, l_l30d, l_l30e);
--
--Populate Section II
  hr_utility.set_location('Calling Procedure to Populate SectionII. '||l_proc,40);
  fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate SectionII');
  sf113a_sec2 (l_agency_code, l_rpt_date, l_emp_as_of_date,
               l_pay_from, l_pay_to, l_segment,
               l_l17a ,l_l17b ,l_l17c ,l_l17d, l_l17e,
               l_l18a ,l_l18b ,l_l18c ,l_l18d, l_l18e,
               l_l31a ,l_l31b ,l_l31c ,l_l31d, l_l31e);
--
--Populate Section III
  hr_utility.set_location('Calling Procedure to Populate SectionIII. '||l_proc,50);
  fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate SectionIII');
  sf113a_sec3 (l_agency_code, l_rpt_date, l_emp_as_of_date, l_last_rpt_date,
               l_pay_from, l_pay_to, l_segment,
               l_l19a, l_l19b ,l_l19c ,l_l19d, l_l19e,
               l_l20a, l_l20b ,l_l20c ,l_l20d, l_l20e,
               l_l21a, l_l21b ,l_l21c ,l_l21d, l_l21e,
               l_l22a ,l_l22b ,l_l22c ,l_l22d, l_l22e,
               l_l23a, l_l23b ,l_l23c ,l_l23d, l_l23e,
               l_l24a, l_l24b ,l_l24c ,l_l24d, l_l24e,
               l_l25a ,l_l25b ,l_l25c ,l_l25d, l_l25e,
               l_l26a ,l_l26b ,l_l26c ,l_l26d, l_l26e,
               l_l27a ,l_l27b ,l_l27c ,l_l27d, l_l27e,
               l_l28a ,l_l28b ,l_l28c ,l_l28d, l_l28e);
--
--Replace Zeroes with Null
  hr_utility.set_location('Calling Procedure to replace zeroes with null. '||l_proc,60);
  fnd_file.put_line(fnd_file.log,'Calling Procedure to replace zeroes with null');
  repl_zero(l_l1a,  l_l1b,  l_l1c,  l_l1d,  l_l1e,
            l_l2a,  l_l2b,  l_l2c,  l_l2d,  l_l2e,
            l_l3a,  l_l3b,  l_l3c,  l_l3d,  l_l3e,
            l_l4a,  l_l4b,  l_l4c,  l_l4d,  l_l4e,
            l_l5a,  l_l5b,  l_l5c,  l_l5d,  l_l5e,
            l_l6a,  l_l6b,  l_l6c,  l_l6d,  l_l6e,
            l_l7a,  l_l7b,  l_l7c,  l_l7d,  l_l7e,
            l_l8a,  l_l8b,  l_l8c,  l_l8d,  l_l8e,
            l_l9a,  l_l9b,  l_l9c,  l_l9d,  l_l9e,
            l_l10a, l_l10b, l_l10c, l_l10d, l_l10e,
            l_l11a, l_l11b, l_l11c, l_l11d, l_l11e,
            l_l12a, l_l12b, l_l12c, l_l12d, l_l12e,
            l_l13a, l_l13b, l_l13c, l_l13d, l_l13e,
            l_l14a, l_l14b, l_l14c, l_l14d, l_l14e,
            l_l15a, l_l15b, l_l15c, l_l15d, l_l15e,
            l_l16a, l_l16b, l_l16c, l_l16d, l_l16e,
            l_l17a, l_l17b, l_l17c, l_l17d, l_l17e,
            l_l18a, l_l18b, l_l18c, l_l18d, l_l18e,
            l_l19a, l_l19b, l_l19c, l_l19d, l_l19e,
            l_l20a, l_l20b, l_l20c, l_l20d, l_l20e,
            l_l21a, l_l21b, l_l21c, l_l21d, l_l21e,
            l_l22a, l_l22b, l_l22c, l_l22d, l_l22e,
            l_l23a, l_l23b, l_l23c, l_l23d, l_l23e,
            l_l24a, l_l24b, l_l24c, l_l24d, l_l24e,
            l_l25a, l_l25b, l_l25c, l_l25d, l_l25e,
            l_l26a, l_l26b, l_l26c, l_l26d, l_l26e,
            l_l27a, l_l27b, l_l27c, l_l27d, l_l27e,
            l_l28a, l_l28b, l_l28c, l_l28d, l_l28e,
            l_l29a, l_l29b, l_l29c, l_l29d, l_l29e,
            l_l30a, l_l30b, l_l30c, l_l30d, l_l30e,
            l_l31a, l_l31b, l_l31c, l_l31d, l_l31e);
--
  hr_utility.set_location('Started generating XML in Concurrent Request Output. '||l_proc,70);
  fnd_file.put_line(fnd_file.log,'Started generating XML in Concurrent Request Output');
--
--Start adding XML in CP Output
  fnd_file.put_line(fnd_file.output,'<?xml version="1.0" encoding="UTF-8"?>');
  fnd_file.put_line(fnd_file.output,'<rep>');
--Start Report Header in XML
  fnd_file.put_line(fnd_file.output,' <hdr>');
  fnd_file.put_line(fnd_file.output,'  <agency>'  || l_agency_name || '</agency>');
  fnd_file.put_line(fnd_file.output,'  <subelem>' || l_subelem     || '</subelem>');
  fnd_file.put_line(fnd_file.output,'  <emp_dt>' || to_char(l_emp_as_of_date,'mm/dd/yyyy') || '</emp_dt>');
  fnd_file.put_line(fnd_file.output,'  <pay>');
  fnd_file.put_line(fnd_file.output,'   <pay_frm_dt>' || to_char(l_pay_from,'mm/dd/yyyy') || '</pay_frm_dt>');
  fnd_file.put_line(fnd_file.output,'   <pay_to_dt>' || to_char(l_pay_to,'mm/dd/yyyy') || '</pay_to_dt>');
  fnd_file.put_line(fnd_file.output,'  </pay>');
  fnd_file.put_line(fnd_file.output,'  <turn>');
  fnd_file.put_line(fnd_file.output,'   <turn_frm_dt>' || to_char(l_pay_from,'mm/dd/yyyy') || '</turn_frm_dt>');
  fnd_file.put_line(fnd_file.output,'   <turn_to_dt>' || to_char(l_pay_to,'mm/dd/yyyy') || '</turn_to_dt>');
  fnd_file.put_line(fnd_file.output,'  </turn>');
  fnd_file.put_line(fnd_file.output,' </hdr>');
--End Report Header in XML
--Start of SecI - 1
  fnd_file.put_line(fnd_file.output,' <section1>');
  fnd_file.put_line(fnd_file.output,'  <sec1>');
  fnd_file.put_line(fnd_file.output,'   <l_l1a>' || l_l1a || '</l_l1a>');
  fnd_file.put_line(fnd_file.output,'   <l_l1b>' || l_l1b || '</l_l1b>');
  fnd_file.put_line(fnd_file.output,'   <l_l1c>' || l_l1c || '</l_l1c>');
  fnd_file.put_line(fnd_file.output,'   <l_l1d>' || l_l1d || '</l_l1d>');
  fnd_file.put_line(fnd_file.output,'   <l_l1e>' || l_l1e || '</l_l1e>');
  fnd_file.put_line(fnd_file.output,'  </sec1>');
--Start of SecI - 2
  fnd_file.put_line(fnd_file.output,'  <sec2>');
  fnd_file.put_line(fnd_file.output,'   <l_l2a>' || l_l2a || '</l_l2a>');
  fnd_file.put_line(fnd_file.output,'   <l_l2b>' || l_l2b || '</l_l2b>');
  fnd_file.put_line(fnd_file.output,'   <l_l2c>' || l_l2c || '</l_l2c>');
  fnd_file.put_line(fnd_file.output,'   <l_l2d>' || l_l2d || '</l_l2d>');
  fnd_file.put_line(fnd_file.output,'   <l_l2e>' || l_l2e || '</l_l2e>');
  fnd_file.put_line(fnd_file.output,'  </sec2>');
--Start of SecI - 3
  fnd_file.put_line(fnd_file.output,'  <sec3>');
  fnd_file.put_line(fnd_file.output,'   <l_l3a>' || l_l3a || '</l_l3a>');
  fnd_file.put_line(fnd_file.output,'   <l_l3b>' || l_l3b || '</l_l3b>');
  fnd_file.put_line(fnd_file.output,'   <l_l3c>' || l_l3c || '</l_l3c>');
  fnd_file.put_line(fnd_file.output,'   <l_l3d>' || l_l3d || '</l_l3d>');
  fnd_file.put_line(fnd_file.output,'   <l_l3e>' || l_l3e || '</l_l3e>');
  fnd_file.put_line(fnd_file.output,'  </sec3>');
--Start of SecI - 4
  fnd_file.put_line(fnd_file.output,'  <sec4>');
  fnd_file.put_line(fnd_file.output,'   <l_l4a>' || l_l4a || '</l_l4a>');
  fnd_file.put_line(fnd_file.output,'   <l_l4b>' || l_l4b || '</l_l4b>');
  fnd_file.put_line(fnd_file.output,'   <l_l4c>' || l_l4c || '</l_l4c>');
  fnd_file.put_line(fnd_file.output,'   <l_l4d>' || l_l4d || '</l_l4d>');
  fnd_file.put_line(fnd_file.output,'   <l_l4e>' || l_l4e || '</l_l4e>');
  fnd_file.put_line(fnd_file.output,'  </sec4>');
--Start of SecI - 5
  fnd_file.put_line(fnd_file.output,'  <sec5>');
  fnd_file.put_line(fnd_file.output,'   <l_l5a>' || l_l5a || '</l_l5a>');
  fnd_file.put_line(fnd_file.output,'   <l_l5b>' || l_l5b || '</l_l5b>');
  fnd_file.put_line(fnd_file.output,'   <l_l5c>' || l_l5c || '</l_l5c>');
  fnd_file.put_line(fnd_file.output,'   <l_l5d>' || l_l5d || '</l_l5d>');
  fnd_file.put_line(fnd_file.output,'   <l_l5e>' || l_l5e || '</l_l5e>');
  fnd_file.put_line(fnd_file.output,'  </sec5>');
--Start of SecI - 6
  fnd_file.put_line(fnd_file.output,'  <sec6>');
  fnd_file.put_line(fnd_file.output,'   <l_l6a>' || l_l6a || '</l_l6a>');
  fnd_file.put_line(fnd_file.output,'   <l_l6b>' || l_l6b || '</l_l6b>');
  fnd_file.put_line(fnd_file.output,'   <l_l6c>' || l_l6c || '</l_l6c>');
  fnd_file.put_line(fnd_file.output,'   <l_l6d>' || l_l6d || '</l_l6d>');
  fnd_file.put_line(fnd_file.output,'   <l_l6e>' || l_l6e || '</l_l6e>');
  fnd_file.put_line(fnd_file.output,'  </sec6>');
--Start of SecI - 7
  fnd_file.put_line(fnd_file.output,'  <sec7>');
  fnd_file.put_line(fnd_file.output,'   <l_l7a>' || l_l7a || '</l_l7a>');
  fnd_file.put_line(fnd_file.output,'   <l_l7b>' || l_l7b || '</l_l7b>');
  fnd_file.put_line(fnd_file.output,'   <l_l7c>' || l_l7c || '</l_l7c>');
  fnd_file.put_line(fnd_file.output,'   <l_l7d>' || l_l7d || '</l_l7d>');
  fnd_file.put_line(fnd_file.output,'   <l_l7e>' || l_l7e || '</l_l7e>');
  fnd_file.put_line(fnd_file.output,'  </sec7>');
--Start of SecI - 8
  fnd_file.put_line(fnd_file.output,'  <sec8>');
  fnd_file.put_line(fnd_file.output,'   <l_l8a>' || l_l8a || '</l_l8a>');
  fnd_file.put_line(fnd_file.output,'   <l_l8b>' || l_l8b || '</l_l8b>');
  fnd_file.put_line(fnd_file.output,'   <l_l8c>' || l_l8c || '</l_l8c>');
  fnd_file.put_line(fnd_file.output,'   <l_l8d>' || l_l8d || '</l_l8d>');
  fnd_file.put_line(fnd_file.output,'   <l_l8e>' || l_l8e || '</l_l8e>');
  fnd_file.put_line(fnd_file.output,'  </sec8>');
--Start of SecI - 9
  fnd_file.put_line(fnd_file.output,'  <sec9>');
  fnd_file.put_line(fnd_file.output,'   <l_l9a>' || l_l9a || '</l_l9a>');
  fnd_file.put_line(fnd_file.output,'   <l_l9b>' || l_l9b || '</l_l9b>');
  fnd_file.put_line(fnd_file.output,'   <l_l9c>' || l_l9c || '</l_l9c>');
  fnd_file.put_line(fnd_file.output,'   <l_l9d>' || l_l9d || '</l_l9d>');
  fnd_file.put_line(fnd_file.output,'   <l_l9e>' || l_l9e || '</l_l9e>');
  fnd_file.put_line(fnd_file.output,'  </sec9>');
--Start of SecI - 10
  fnd_file.put_line(fnd_file.output,'  <sec10>');
  fnd_file.put_line(fnd_file.output,'   <l_l10a>' || l_l10a || '</l_l10a>');
  fnd_file.put_line(fnd_file.output,'   <l_l10b>' || l_l10b || '</l_l10b>');
  fnd_file.put_line(fnd_file.output,'   <l_l10c>' || l_l10c || '</l_l10c>');
  fnd_file.put_line(fnd_file.output,'   <l_l10d>' || l_l10d || '</l_l10d>');
  fnd_file.put_line(fnd_file.output,'   <l_l10e>' || l_l10e || '</l_l10e>');
  fnd_file.put_line(fnd_file.output,'  </sec10>');
--Start of SecI - 11
  fnd_file.put_line(fnd_file.output,'  <sec11>');
  fnd_file.put_line(fnd_file.output,'   <l_l11a>' || l_l11a || '</l_l11a>');
  fnd_file.put_line(fnd_file.output,'   <l_l11b>' || l_l11b || '</l_l11b>');
  fnd_file.put_line(fnd_file.output,'   <l_l11c>' || l_l11c || '</l_l11c>');
  fnd_file.put_line(fnd_file.output,'   <l_l11d>' || l_l11d || '</l_l11d>');
  fnd_file.put_line(fnd_file.output,'   <l_l11e>' || l_l11e || '</l_l11e>');
  fnd_file.put_line(fnd_file.output,'  </sec11>');
--Start of SecI - 12
  fnd_file.put_line(fnd_file.output,'  <sec12>');
  fnd_file.put_line(fnd_file.output,'   <l_l12a>' || l_l12a || '</l_l12a>');
  fnd_file.put_line(fnd_file.output,'   <l_l12b>' || l_l12b || '</l_l12b>');
  fnd_file.put_line(fnd_file.output,'   <l_l12c>' || l_l12c || '</l_l12c>');
  fnd_file.put_line(fnd_file.output,'   <l_l12d>' || l_l12d || '</l_l12d>');
  fnd_file.put_line(fnd_file.output,'   <l_l12e>' || l_l12e || '</l_l12e>');
  fnd_file.put_line(fnd_file.output,'  </sec12>');
--Start of SecI - 13
  fnd_file.put_line(fnd_file.output,'  <sec13>');
  fnd_file.put_line(fnd_file.output,'   <l_l13a>' || l_l13a || '</l_l13a>');
  fnd_file.put_line(fnd_file.output,'   <l_l13b>' || l_l13b || '</l_l13b>');
  fnd_file.put_line(fnd_file.output,'   <l_l13c>' || l_l13c || '</l_l13c>');
  fnd_file.put_line(fnd_file.output,'   <l_l13d>' || l_l13d || '</l_l13d>');
  fnd_file.put_line(fnd_file.output,'   <l_l13e>' || l_l13e || '</l_l13e>');
  fnd_file.put_line(fnd_file.output,'  </sec13>');
--Start of SecI - 14
  fnd_file.put_line(fnd_file.output,'  <sec14>');
  fnd_file.put_line(fnd_file.output,'   <l_l14a>' || l_l14a || '</l_l14a>');
  fnd_file.put_line(fnd_file.output,'   <l_l14b>' || l_l14b || '</l_l14b>');
  fnd_file.put_line(fnd_file.output,'   <l_l14c>' || l_l14c || '</l_l14c>');
  fnd_file.put_line(fnd_file.output,'   <l_l14d>' || l_l14d || '</l_l14d>');
  fnd_file.put_line(fnd_file.output,'   <l_l14e>' || l_l14e || '</l_l14e>');
  fnd_file.put_line(fnd_file.output,'  </sec14>');
--Start of SecI - 15
  fnd_file.put_line(fnd_file.output,'  <sec15>');
  fnd_file.put_line(fnd_file.output,'   <l_l15a>' || l_l15a || '</l_l15a>');
  fnd_file.put_line(fnd_file.output,'   <l_l15b>' || l_l15b || '</l_l15b>');
  fnd_file.put_line(fnd_file.output,'   <l_l15c>' || l_l15c || '</l_l15c>');
  fnd_file.put_line(fnd_file.output,'   <l_l15d>' || l_l15d || '</l_l15d>');
  fnd_file.put_line(fnd_file.output,'   <l_l15e>' || l_l15e || '</l_l15e>');
  fnd_file.put_line(fnd_file.output,'  </sec15>');
--Start of SecI - 16
  fnd_file.put_line(fnd_file.output,'  <sec16>');
  fnd_file.put_line(fnd_file.output,'   <l_l16a>' || l_l16a || '</l_l16a>');
  fnd_file.put_line(fnd_file.output,'   <l_l16b>' || l_l16b || '</l_l16b>');
  fnd_file.put_line(fnd_file.output,'   <l_l16c>' || l_l16c || '</l_l16c>');
  fnd_file.put_line(fnd_file.output,'   <l_l16d>' || l_l16d || '</l_l16d>');
  fnd_file.put_line(fnd_file.output,'   <l_l16e>' || l_l16e || '</l_l16e>');
  fnd_file.put_line(fnd_file.output,'  </sec16>');
  fnd_file.put_line(fnd_file.output,' </section1>');
--Start of SecII - 17
  fnd_file.put_line(fnd_file.output,' <section2>');
  fnd_file.put_line(fnd_file.output,'  <sec17>');
  fnd_file.put_line(fnd_file.output,'   <l_l17a>' || l_l17a || '</l_l17a>');
  fnd_file.put_line(fnd_file.output,'   <l_l17b>' || l_l17b || '</l_l17b>');
  fnd_file.put_line(fnd_file.output,'   <l_l17c>' || l_l17c || '</l_l17c>');
  fnd_file.put_line(fnd_file.output,'   <l_l17d>' || l_l17d || '</l_l17d>');
  fnd_file.put_line(fnd_file.output,'   <l_l17e>' || l_l17e || '</l_l17e>');
  fnd_file.put_line(fnd_file.output,'  </sec17>');
--Start of SecII - 18
  fnd_file.put_line(fnd_file.output,'  <sec18>');
  fnd_file.put_line(fnd_file.output,'   <l_l18a>' || l_l18a || '</l_l18a>');
  fnd_file.put_line(fnd_file.output,'   <l_l18b>' || l_l18b || '</l_l18b>');
  fnd_file.put_line(fnd_file.output,'   <l_l18c>' || l_l18c || '</l_l18c>');
  fnd_file.put_line(fnd_file.output,'   <l_l18d>' || l_l18d || '</l_l18d>');
  fnd_file.put_line(fnd_file.output,'   <l_l18e>' || l_l18e || '</l_l18e>');
  fnd_file.put_line(fnd_file.output,'  </sec18>');
  fnd_file.put_line(fnd_file.output,' </section2>');
--Start of SecIII - 19
  fnd_file.put_line(fnd_file.output,' <section3>');
  fnd_file.put_line(fnd_file.output,'  <sec19>');
  fnd_file.put_line(fnd_file.output,'   <l_l19a>' || l_l19a||  '</l_l19a>');
  fnd_file.put_line(fnd_file.output,'   <l_l19b>' || l_l19b || '</l_l19b>');
  fnd_file.put_line(fnd_file.output,'   <l_l19c>' || l_l19c || '</l_l19c>');
  fnd_file.put_line(fnd_file.output,'   <l_l19d>' || l_l19d || '</l_l19d>');
  fnd_file.put_line(fnd_file.output,'   <l_l19e>' || l_l19e || '</l_l19e>');
  fnd_file.put_line(fnd_file.output,'  </sec19>');
--Start of SecIII - 20
  fnd_file.put_line(fnd_file.output,'  <sec20>');
  fnd_file.put_line(fnd_file.output,'   <l_l20a>' || l_l20a || '</l_l20a>');
  fnd_file.put_line(fnd_file.output,'   <l_l20b>' || l_l20b || '</l_l20b>');
  fnd_file.put_line(fnd_file.output,'   <l_l20c>' || l_l20c || '</l_l20c>');
  fnd_file.put_line(fnd_file.output,'   <l_l20d>' || l_l20d || '</l_l20d>');
  fnd_file.put_line(fnd_file.output,'   <l_l20e>' || l_l20e || '</l_l20e>');
  fnd_file.put_line(fnd_file.output,'  </sec20>');
--Start of SecIII - 21
  fnd_file.put_line(fnd_file.output,'  <sec21>');
  fnd_file.put_line(fnd_file.output,'   <l_l21a>' || l_l21a || '</l_l21a>');
  fnd_file.put_line(fnd_file.output,'   <l_l21b>' || l_l21b || '</l_l21b>');
  fnd_file.put_line(fnd_file.output,'   <l_l21c>' || l_l21c || '</l_l21c>');
  fnd_file.put_line(fnd_file.output,'   <l_l21d>' || l_l21d || '</l_l21d>');
  fnd_file.put_line(fnd_file.output,'   <l_l21e>' || l_l21e || '</l_l21e>');
  fnd_file.put_line(fnd_file.output,'  </sec21>');
--Start of SecIII - 22
  fnd_file.put_line(fnd_file.output,'  <sec22>');
  fnd_file.put_line(fnd_file.output,'   <l_l22a>' || l_l22a || '</l_l22a>');
  fnd_file.put_line(fnd_file.output,'   <l_l22b>' || l_l22b || '</l_l22b>');
  fnd_file.put_line(fnd_file.output,'   <l_l22c>' || l_l22c || '</l_l22c>');
  fnd_file.put_line(fnd_file.output,'   <l_l22d>' || l_l22d || '</l_l22d>');
  fnd_file.put_line(fnd_file.output,'   <l_l22e>' || l_l22e || '</l_l22e>');
  fnd_file.put_line(fnd_file.output,'  </sec22>');
--Start of SecIII - 23
  fnd_file.put_line(fnd_file.output,'  <sec23>');
  fnd_file.put_line(fnd_file.output,'   <l_l23a>' || l_l23a || '</l_l23a>');
  fnd_file.put_line(fnd_file.output,'   <l_l23b>' || l_l23b || '</l_l23b>');
  fnd_file.put_line(fnd_file.output,'   <l_l23c>' || l_l23c || '</l_l23c>');
  fnd_file.put_line(fnd_file.output,'   <l_l23d>' || l_l23d || '</l_l23d>');
  fnd_file.put_line(fnd_file.output,'   <l_l23e>' || l_l23e || '</l_l23e>');
  fnd_file.put_line(fnd_file.output,'  </sec23>');
--Start of SecIII - 24
  fnd_file.put_line(fnd_file.output,'  <sec24>');
  fnd_file.put_line(fnd_file.output,'   <l_l24a>' || l_l24a || '</l_l24a>');
  fnd_file.put_line(fnd_file.output,'   <l_l24b>' || l_l24b || '</l_l24b>');
  fnd_file.put_line(fnd_file.output,'   <l_l24c>' || l_l24c || '</l_l24c>');
  fnd_file.put_line(fnd_file.output,'   <l_l24d>' || l_l24d || '</l_l24d>');
  fnd_file.put_line(fnd_file.output,'   <l_l24e>' || l_l24e || '</l_l24e>');
  fnd_file.put_line(fnd_file.output,'  </sec24>');
--Start of SecIII - 25
  fnd_file.put_line(fnd_file.output,'  <sec25>');
  fnd_file.put_line(fnd_file.output,'   <l_l25a>' || l_l25a || '</l_l25a>');
  fnd_file.put_line(fnd_file.output,'   <l_l25b>' || l_l25b || '</l_l25b>');
  fnd_file.put_line(fnd_file.output,'   <l_l25c>' || l_l25c || '</l_l25c>');
  fnd_file.put_line(fnd_file.output,'   <l_l25d>' || l_l25d || '</l_l25d>');
  fnd_file.put_line(fnd_file.output,'   <l_l25e>' || l_l25e || '</l_l25e>');
  fnd_file.put_line(fnd_file.output,'  </sec25>');
--Start of SecIII - 26
  fnd_file.put_line(fnd_file.output,'  <sec26>');
  fnd_file.put_line(fnd_file.output,'   <l_l26a>' || l_l26a || '</l_l26a>');
  fnd_file.put_line(fnd_file.output,'   <l_l26b>' || l_l26b || '</l_l26b>');
  fnd_file.put_line(fnd_file.output,'   <l_l26c>' || l_l26c || '</l_l26c>');
  fnd_file.put_line(fnd_file.output,'   <l_l26d>' || l_l26d || '</l_l26d>');
  fnd_file.put_line(fnd_file.output,'   <l_l26e>' || l_l26e || '</l_l26e>');
  fnd_file.put_line(fnd_file.output,'  </sec26>');
--Start of SecIII - 27
  fnd_file.put_line(fnd_file.output,'  <sec27>');
  fnd_file.put_line(fnd_file.output,'   <l_l27a>' || l_l27a || '</l_l27a>');
  fnd_file.put_line(fnd_file.output,'   <l_l27b>' || l_l27b || '</l_l27b>');
  fnd_file.put_line(fnd_file.output,'   <l_l27c>' || l_l27c || '</l_l27c>');
  fnd_file.put_line(fnd_file.output,'   <l_l27d>' || l_l27d || '</l_l27d>');
  fnd_file.put_line(fnd_file.output,'   <l_l27e>' || l_l27e || '</l_l27e>');
  fnd_file.put_line(fnd_file.output,'  </sec27>');
--Start of SecIII - 28
  fnd_file.put_line(fnd_file.output,'  <sec28>');
  fnd_file.put_line(fnd_file.output,'   <l_l28a>' || l_l28a || '</l_l28a>');
  fnd_file.put_line(fnd_file.output,'   <l_l28b>' || l_l28b || '</l_l28b>');
  fnd_file.put_line(fnd_file.output,'   <l_l28c>' || l_l28c || '</l_l28c>');
  fnd_file.put_line(fnd_file.output,'   <l_l28d>' || l_l28d || '</l_l28d>');
  fnd_file.put_line(fnd_file.output,'   <l_l28e>' || l_l28e || '</l_l28e>');
  fnd_file.put_line(fnd_file.output,'  </sec28>');
  fnd_file.put_line(fnd_file.output,' </section3>');
--Start of SecIV - 29
  fnd_file.put_line(fnd_file.output,' <section4>');
  fnd_file.put_line(fnd_file.output,'  <sec29>');
  fnd_file.put_line(fnd_file.output,'   <l_l29a>' || l_l29a || '</l_l29a>');
  fnd_file.put_line(fnd_file.output,'   <l_l29b>' || l_l29b || '</l_l29b>');
  fnd_file.put_line(fnd_file.output,'   <l_l29c>' || l_l29c || '</l_l29c>');
  fnd_file.put_line(fnd_file.output,'   <l_l29d>' || l_l29d || '</l_l29d>');
  fnd_file.put_line(fnd_file.output,'   <l_l29e>' || l_l29e || '</l_l29e>');
  fnd_file.put_line(fnd_file.output,'  </sec29>');
--Start of SecIV - 30
  fnd_file.put_line(fnd_file.output,'  <sec30>');
  fnd_file.put_line(fnd_file.output,'   <l_l30a>' || l_l30a || '</l_l30a>');
  fnd_file.put_line(fnd_file.output,'   <l_l30b>' || l_l30b || '</l_l30b>');
  fnd_file.put_line(fnd_file.output,'   <l_l30c>' || l_l30c || '</l_l30c>');
  fnd_file.put_line(fnd_file.output,'   <l_l30d>' || l_l30d || '</l_l30d>');
  fnd_file.put_line(fnd_file.output,'   <l_l30e>' || l_l30e || '</l_l30e>');
  fnd_file.put_line(fnd_file.output,'  </sec30>');
--Start of SecIV - 31
  fnd_file.put_line(fnd_file.output,'  <sec31>');
  fnd_file.put_line(fnd_file.output,'   <l_l31a>' || l_l31a || '</l_l31a>');
  fnd_file.put_line(fnd_file.output,'   <l_l31b>' || l_l31b || '</l_l31b>');
  fnd_file.put_line(fnd_file.output,'   <l_l31c>' || l_l31c || '</l_l31c>');
  fnd_file.put_line(fnd_file.output,'   <l_l31d>' || l_l31d || '</l_l31d>');
  fnd_file.put_line(fnd_file.output,'   <l_l31e>' || l_l31e || '</l_l31e>');
  fnd_file.put_line(fnd_file.output,'  </sec31>');
  fnd_file.put_line(fnd_file.output,' </section4>');
  fnd_file.put_line(fnd_file.output,'</rep>');
--End adding XML in CP Output
--
  hr_utility.set_location('Finished generating XML in Concurrent Request Output. '||l_proc,80);
  fnd_file.put_line(fnd_file.log,'Finished generating XML in Concurrent Request Output');
  fnd_file.put_line(fnd_file.log,'------------------------------------------------------');
--
  hr_utility.set_location('Leaving: '||l_proc,10);
--
EXCEPTION
  WHEN others THEN
       retcode := 2;
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
       hr_utility.set_location('Error Leaving: '||l_proc,90);
       raise;
END ghr_sf113a_out;
--
--This procedure replaces all Zeroes to NULL.
  PROCEDURE repl_zero(p_l1a  IN OUT NOCOPY   number
                     ,p_l1b  IN OUT NOCOPY   number
                     ,p_l1c  IN OUT NOCOPY   number
                     ,p_l1d  IN OUT NOCOPY   number
                     ,p_l1e  IN OUT NOCOPY   number
                     ,p_l2a  IN OUT NOCOPY   number
                     ,p_l2b  IN OUT NOCOPY   number
                     ,p_l2c  IN OUT NOCOPY   number
                     ,p_l2d  IN OUT NOCOPY   number
                     ,p_l2e  IN OUT NOCOPY   number
                     ,p_l3a  IN OUT NOCOPY   number
                     ,p_l3b  IN OUT NOCOPY   number
                     ,p_l3c  IN OUT NOCOPY   number
                     ,p_l3d  IN OUT NOCOPY   number
                     ,p_l3e  IN OUT NOCOPY   number
                     ,p_l4a  IN OUT NOCOPY   number
                     ,p_l4b  IN OUT NOCOPY   number
                     ,p_l4c  IN OUT NOCOPY   number
                     ,p_l4d  IN OUT NOCOPY   number
                     ,p_l4e  IN OUT NOCOPY   number
                     ,p_l5a  IN OUT NOCOPY   number
                     ,p_l5b  IN OUT NOCOPY   number
                     ,p_l5c  IN OUT NOCOPY   number
                     ,p_l5d  IN OUT NOCOPY   number
                     ,p_l5e  IN OUT NOCOPY   number
                     ,p_l6a  IN OUT NOCOPY   number
                     ,p_l6b  IN OUT NOCOPY   number
                     ,p_l6c  IN OUT NOCOPY   number
                     ,p_l6d  IN OUT NOCOPY   number
                     ,p_l6e  IN OUT NOCOPY   number
                     ,p_l7a  IN OUT NOCOPY   number
                     ,p_l7b  IN OUT NOCOPY   number
                     ,p_l7c  IN OUT NOCOPY   number
                     ,p_l7d  IN OUT NOCOPY   number
                     ,p_l7e  IN OUT NOCOPY   number
                     ,p_l8a  IN OUT NOCOPY   number
                     ,p_l8b  IN OUT NOCOPY   number
                     ,p_l8c  IN OUT NOCOPY   number
                     ,p_l8d  IN OUT NOCOPY   number
                     ,p_l8e  IN OUT NOCOPY   number
                     ,p_l9a  IN OUT NOCOPY   number
                     ,p_l9b  IN OUT NOCOPY   number
                     ,p_l9c  IN OUT NOCOPY   number
                     ,p_l9d  IN OUT NOCOPY   number
                     ,p_l9e  IN OUT NOCOPY   number
                     ,p_l10a IN OUT NOCOPY   number
                     ,p_l10b IN OUT NOCOPY   number
                     ,p_l10c IN OUT NOCOPY   number
                     ,p_l10d IN OUT NOCOPY   number
                     ,p_l10e IN OUT NOCOPY   number
                     ,p_l11a IN OUT NOCOPY   number
                     ,p_l11b IN OUT NOCOPY   number
                     ,p_l11c IN OUT NOCOPY   number
                     ,p_l11d IN OUT NOCOPY   number
                     ,p_l11e IN OUT NOCOPY   number
                     ,p_l12a IN OUT NOCOPY   number
                     ,p_l12b IN OUT NOCOPY   number
                     ,p_l12c IN OUT NOCOPY   number
                     ,p_l12d IN OUT NOCOPY   number
                     ,p_l12e IN OUT NOCOPY   number
                     ,p_l13a IN OUT NOCOPY   number
                     ,p_l13b IN OUT NOCOPY   number
                     ,p_l13c IN OUT NOCOPY   number
                     ,p_l13d IN OUT NOCOPY   number
                     ,p_l13e IN OUT NOCOPY   number
                     ,p_l14a IN OUT NOCOPY   number
                     ,p_l14b IN OUT NOCOPY   number
                     ,p_l14c IN OUT NOCOPY   number
                     ,p_l14d IN OUT NOCOPY   number
                     ,p_l14e IN OUT NOCOPY   number
                     ,p_l15a IN OUT NOCOPY   number
                     ,p_l15b IN OUT NOCOPY   number
                     ,p_l15c IN OUT NOCOPY   number
                     ,p_l15d IN OUT NOCOPY   number
                     ,p_l15e IN OUT NOCOPY   number
                     ,p_l16a IN OUT NOCOPY   number
                     ,p_l16b IN OUT NOCOPY   number
                     ,p_l16c IN OUT NOCOPY   number
                     ,p_l16d IN OUT NOCOPY   number
                     ,p_l16e IN OUT NOCOPY   number
                     ,p_l17a IN OUT NOCOPY   number
                     ,p_l17b IN OUT NOCOPY   number
                     ,p_l17c IN OUT NOCOPY   number
                     ,p_l17d IN OUT NOCOPY   number
                     ,p_l17e IN OUT NOCOPY   number
                     ,p_l18a IN OUT NOCOPY   number
                     ,p_l18b IN OUT NOCOPY   number
                     ,p_l18c IN OUT NOCOPY   number
                     ,p_l18d IN OUT NOCOPY   number
                     ,p_l18e IN OUT NOCOPY   number
                     ,p_l19a IN OUT NOCOPY   number
                     ,p_l19b IN OUT NOCOPY   number
                     ,p_l19c IN OUT NOCOPY   number
                     ,p_l19d IN OUT NOCOPY   number
                     ,p_l19e IN OUT NOCOPY   number
                     ,p_l20a IN OUT NOCOPY   number
                     ,p_l20b IN OUT NOCOPY   number
                     ,p_l20c IN OUT NOCOPY   number
                     ,p_l20d IN OUT NOCOPY   number
                     ,p_l20e IN OUT NOCOPY   number
                     ,p_l21a IN OUT NOCOPY   number
                     ,p_l21b IN OUT NOCOPY   number
                     ,p_l21c IN OUT NOCOPY   number
                     ,p_l21d IN OUT NOCOPY   number
                     ,p_l21e IN OUT NOCOPY   number
                     ,p_l22a IN OUT NOCOPY   number
                     ,p_l22b IN OUT NOCOPY   number
                     ,p_l22c IN OUT NOCOPY   number
                     ,p_l22d IN OUT NOCOPY   number
                     ,p_l22e IN OUT NOCOPY   number
                     ,p_l23a IN OUT NOCOPY   number
                     ,p_l23b IN OUT NOCOPY   number
                     ,p_l23c IN OUT NOCOPY   number
                     ,p_l23d IN OUT NOCOPY   number
                     ,p_l23e IN OUT NOCOPY   number
                     ,p_l24a IN OUT NOCOPY   number
                     ,p_l24b IN OUT NOCOPY   number
                     ,p_l24c IN OUT NOCOPY   number
                     ,p_l24d IN OUT NOCOPY   number
                     ,p_l24e IN OUT NOCOPY   number
                     ,p_l25a IN OUT NOCOPY   number
                     ,p_l25b IN OUT NOCOPY   number
                     ,p_l25c IN OUT NOCOPY   number
                     ,p_l25d IN OUT NOCOPY   number
                     ,p_l25e IN OUT NOCOPY   number
                     ,p_l26a IN OUT NOCOPY   number
                     ,p_l26b IN OUT NOCOPY   number
                     ,p_l26c IN OUT NOCOPY   number
                     ,p_l26d IN OUT NOCOPY   number
                     ,p_l26e IN OUT NOCOPY   number
                     ,p_l27a IN OUT NOCOPY   number
                     ,p_l27b IN OUT NOCOPY   number
                     ,p_l27c IN OUT NOCOPY   number
                     ,p_l27d IN OUT NOCOPY   number
                     ,p_l27e IN OUT NOCOPY   number
                     ,p_l28a IN OUT NOCOPY   number
                     ,p_l28b IN OUT NOCOPY   number
                     ,p_l28c IN OUT NOCOPY   number
                     ,p_l28d IN OUT NOCOPY   number
                     ,p_l28e IN OUT NOCOPY   number
                     ,p_l29a IN OUT NOCOPY   number
                     ,p_l29b IN OUT NOCOPY   number
                     ,p_l29c IN OUT NOCOPY   number
                     ,p_l29d IN OUT NOCOPY   number
                     ,p_l29e IN OUT NOCOPY   number
                     ,p_l30a IN OUT NOCOPY   number
                     ,p_l30b IN OUT NOCOPY   number
                     ,p_l30c IN OUT NOCOPY   number
                     ,p_l30d IN OUT NOCOPY   number
                     ,p_l30e IN OUT NOCOPY   number
                     ,p_l31a IN OUT NOCOPY   number
                     ,p_l31b IN OUT NOCOPY   number
                     ,p_l31c IN OUT NOCOPY   number
                     ,p_l31d IN OUT NOCOPY   number
                     ,p_l31e IN OUT NOCOPY   number)  IS
  BEGIN
    IF p_l1a = 0 THEN
       p_l1a := NULL;
    END IF;
    IF p_l1b = 0 THEN
       p_l1b := NULL;
    END IF;
    IF p_l1c = 0 THEN
       p_l1c := NULL;
    END IF;
    IF p_l1d = 0 THEN
       p_l1d := NULL;
    END IF;
    IF p_l1e = 0 THEN
       p_l1e := NULL;
    END IF;

    IF p_l2a = 0 THEN
       p_l2a := NULL;
    END IF;
    IF p_l2b = 0 THEN
       p_l2b := NULL;
    END IF;
    IF p_l2c = 0 THEN
       p_l2c := NULL;
    END IF;
    IF p_l2d = 0 THEN
       p_l2d := NULL;
    END IF;
    IF p_l2e = 0 THEN
       p_l2e := NULL;
    END IF;

    IF p_l3a = 0 THEN
       p_l3a := NULL;
    END IF;
    IF p_l3b = 0 THEN
       p_l3b := NULL;
    END IF;
    IF p_l3c = 0 THEN
       p_l3c := NULL;
    END IF;
    IF p_l3d = 0 THEN
       p_l3d := NULL;
    END IF;
    IF p_l3e = 0 THEN
       p_l3e := NULL;
    END IF;

    IF p_l4a = 0 THEN
       p_l4a := NULL;
    END IF;
    IF p_l4b = 0 THEN
       p_l4b := NULL;
    END IF;
    IF p_l4c = 0 THEN
       p_l4c := NULL;
    END IF;
    IF p_l4d = 0 THEN
       p_l4d := NULL;
    END IF;
    IF p_l4e = 0 THEN
       p_l4e := NULL;
    END IF;

    IF p_l5a = 0 THEN
       p_l5a := NULL;
    END IF;
    IF p_l5b = 0 THEN
       p_l5b := NULL;
    END IF;
    IF p_l5c = 0 THEN
       p_l5c := NULL;
    END IF;
    IF p_l5d = 0 THEN
       p_l5d := NULL;
    END IF;
    IF p_l5e = 0 THEN
       p_l5e := NULL;
    END IF;

    IF p_l6a = 0 THEN
       p_l6a := NULL;
    END IF;
    IF p_l6b = 0 THEN
       p_l6b := NULL;
    END IF;
    IF p_l6c = 0 THEN
       p_l6c := NULL;
    END IF;
    IF p_l6d = 0 THEN
       p_l6d := NULL;
    END IF;
    IF p_l6e = 0 THEN
       p_l6e := NULL;
    END IF;

    IF p_l7a = 0 THEN
       p_l7a := NULL;
    END IF;
    IF p_l7b = 0 THEN
       p_l7b := NULL;
    END IF;
    IF p_l7c = 0 THEN
       p_l7c := NULL;
    END IF;
    IF p_l7d = 0 THEN
       p_l7d := NULL;
    END IF;
    IF p_l7e = 0 THEN
       p_l7e := NULL;
    END IF;

    IF p_l8a = 0 THEN
       p_l8a := NULL;
    END IF;
    IF p_l8b = 0 THEN
       p_l8b := NULL;
    END IF;
    IF p_l8c = 0 THEN
       p_l8c := NULL;
    END IF;
    IF p_l8d = 0 THEN
       p_l8d := NULL;
    END IF;
    IF p_l8e = 0 THEN
       p_l8e := NULL;
    END IF;

    IF p_l9a = 0 THEN
       p_l9a := NULL;
    END IF;
    IF p_l9b = 0 THEN
       p_l9b := NULL;
    END IF;
    IF p_l9c = 0 THEN
       p_l9c := NULL;
    END IF;
    IF p_l9d = 0 THEN
       p_l9d := NULL;
    END IF;
    IF p_l9e = 0 THEN
       p_l9e := NULL;
    END IF;

    IF p_l10a = 0 THEN
       p_l10a := NULL;
    END IF;
    IF p_l10b = 0 THEN
       p_l10b := NULL;
    END IF;
    IF p_l10c = 0 THEN
       p_l10c := NULL;
    END IF;
    IF p_l10d = 0 THEN
       p_l10d := NULL;
    END IF;
    IF p_l10e = 0 THEN
       p_l10e := NULL;
    END IF;

    IF p_l11a = 0 THEN
       p_l11a := NULL;
    END IF;
    IF p_l11b = 0 THEN
       p_l11b := NULL;
    END IF;
    IF p_l11c = 0 THEN
       p_l11c := NULL;
    END IF;
    IF p_l11d = 0 THEN
       p_l11d := NULL;
    END IF;
    IF p_l11e = 0 THEN
       p_l11e := NULL;
    END IF;

    IF p_l12a = 0 THEN
       p_l12a := NULL;
    END IF;
    IF p_l12b = 0 THEN
       p_l12b := NULL;
    END IF;
    IF p_l12c = 0 THEN
       p_l12c := NULL;
    END IF;
    IF p_l12d = 0 THEN
       p_l12d := NULL;
    END IF;
    IF p_l12e = 0 THEN
       p_l12e := NULL;
    END IF;

    IF p_l13a = 0 THEN
       p_l13a := NULL;
    END IF;
    IF p_l13b = 0 THEN
       p_l13b := NULL;
    END IF;
    IF p_l13c = 0 THEN
       p_l13c := NULL;
    END IF;
    IF p_l13d = 0 THEN
       p_l13d := NULL;
    END IF;
    IF p_l13e = 0 THEN
       p_l13e := NULL;
    END IF;

    IF p_l14a = 0 THEN
       p_l14a := NULL;
    END IF;
    IF p_l14b = 0 THEN
       p_l14b := NULL;
    END IF;
    IF p_l14c = 0 THEN
       p_l14c := NULL;
    END IF;
    IF p_l14d = 0 THEN
       p_l14d := NULL;
    END IF;
    IF p_l14e = 0 THEN
       p_l14e := NULL;
    END IF;

    IF p_l15a = 0 THEN
       p_l15a := NULL;
    END IF;
    IF p_l15b = 0 THEN
       p_l15b := NULL;
    END IF;
    IF p_l15c = 0 THEN
       p_l15c := NULL;
    END IF;
    IF p_l15d = 0 THEN
       p_l15d := NULL;
    END IF;
    IF p_l15e = 0 THEN
       p_l15e := NULL;
    END IF;

    IF p_l16a = 0 THEN
       p_l16a := NULL;
    END IF;
    IF p_l16b = 0 THEN
       p_l16b := NULL;
    END IF;
    IF p_l16c = 0 THEN
       p_l16c := NULL;
    END IF;
    IF p_l16d = 0 THEN
       p_l16d := NULL;
    END IF;
    IF p_l16e = 0 THEN
       p_l16e := NULL;
    END IF;

    IF p_l17a = 0 THEN
       p_l17a := NULL;
    END IF;
    IF p_l17b = 0 THEN
       p_l17b := NULL;
    END IF;
    IF p_l17c = 0 THEN
       p_l17c := NULL;
    END IF;
    IF p_l17d = 0 THEN
       p_l17d := NULL;
    END IF;
    IF p_l17e = 0 THEN
       p_l17e := NULL;
    END IF;

    IF p_l18a = 0 THEN
       p_l18a := NULL;
    END IF;
    IF p_l18b = 0 THEN
       p_l18b := NULL;
    END IF;
    IF p_l18c = 0 THEN
       p_l18c := NULL;
    END IF;
    IF p_l18d = 0 THEN
       p_l18d := NULL;
    END IF;
    IF p_l18e = 0 THEN
       p_l18e := NULL;
    END IF;

    IF p_l19a = 0 THEN
       p_l19a := NULL;
    END IF;
    IF p_l19b = 0 THEN
       p_l19b := NULL;
    END IF;
    IF p_l19c = 0 THEN
       p_l19c := NULL;
    END IF;
    IF p_l19d = 0 THEN
       p_l19d := NULL;
    END IF;
    IF p_l19e = 0 THEN
       p_l19e := NULL;
    END IF;

    IF p_l20a = 0 THEN
       p_l20a := NULL;
    END IF;
    IF p_l20b = 0 THEN
       p_l20b := NULL;
    END IF;
    IF p_l20c = 0 THEN
       p_l20c := NULL;
    END IF;
    IF p_l20d = 0 THEN
       p_l20d := NULL;
    END IF;
    IF p_l20e = 0 THEN
       p_l20e := NULL;
    END IF;

    IF p_l21a = 0 THEN
       p_l21a := NULL;
    END IF;
    IF p_l21b = 0 THEN
       p_l21b := NULL;
    END IF;
    IF p_l21c = 0 THEN
       p_l21c := NULL;
    END IF;
    IF p_l21d = 0 THEN
       p_l21d := NULL;
    END IF;
    IF p_l21e = 0 THEN
       p_l21e := NULL;
    END IF;

    IF p_l22a = 0 THEN
       p_l22a := NULL;
    END IF;
    IF p_l22b = 0 THEN
       p_l22b := NULL;
    END IF;
    IF p_l22c = 0 THEN
       p_l22c := NULL;
    END IF;
    IF p_l22d = 0 THEN
       p_l22d := NULL;
    END IF;
    IF p_l22e = 0 THEN
       p_l22e := NULL;
    END IF;

    IF p_l23a = 0 THEN
       p_l23a := NULL;
    END IF;
    IF p_l23b = 0 THEN
       p_l23b := NULL;
    END IF;
    IF p_l23c = 0 THEN
       p_l23c := NULL;
    END IF;
    IF p_l23d = 0 THEN
       p_l23d := NULL;
    END IF;
    IF p_l23e = 0 THEN
       p_l23e := NULL;
    END IF;

    IF p_l24a = 0 THEN
       p_l24a := NULL;
    END IF;
    IF p_l24b = 0 THEN
       p_l24b := NULL;
    END IF;
    IF p_l24c = 0 THEN
       p_l24c := NULL;
    END IF;
    IF p_l24d = 0 THEN
       p_l24d := NULL;
    END IF;
    IF p_l24e = 0 THEN
       p_l24e := NULL;
    END IF;

    IF p_l25a = 0 THEN
       p_l25a := NULL;
    END IF;
    IF p_l25b = 0 THEN
       p_l25b := NULL;
    END IF;
    IF p_l25c = 0 THEN
       p_l25c := NULL;
    END IF;
    IF p_l25d = 0 THEN
       p_l25d := NULL;
    END IF;
    IF p_l25e = 0 THEN
       p_l25e := NULL;
    END IF;

    IF p_l26a = 0 THEN
       p_l26a := NULL;
    END IF;
    IF p_l26b = 0 THEN
       p_l26b := NULL;
    END IF;
    IF p_l26c = 0 THEN
       p_l26c := NULL;
    END IF;
    IF p_l26d = 0 THEN
       p_l26d := NULL;
    END IF;
    IF p_l26e = 0 THEN
       p_l26e := NULL;
    END IF;

    IF p_l27a = 0 THEN
       p_l27a := NULL;
    END IF;
    IF p_l27b = 0 THEN
       p_l27b := NULL;
    END IF;
    IF p_l27c = 0 THEN
       p_l27c := NULL;
    END IF;
    IF p_l27d = 0 THEN
       p_l27d := NULL;
    END IF;
    IF p_l27e = 0 THEN
       p_l27e := NULL;
    END IF;

    IF p_l28a = 0 THEN
       p_l28a := NULL;
    END IF;
    IF p_l28b = 0 THEN
       p_l28b := NULL;
    END IF;
    IF p_l28c = 0 THEN
       p_l28c := NULL;
    END IF;
    IF p_l28d = 0 THEN
       p_l28d := NULL;
    END IF;
    IF p_l28e = 0 THEN
       p_l28e := NULL;
    END IF;

    IF p_l29a = 0 THEN
       p_l29a := NULL;
    END IF;
    IF p_l29b = 0 THEN
       p_l29b := NULL;
    END IF;
    IF p_l29c = 0 THEN
       p_l29c := NULL;
    END IF;
    IF p_l29d = 0 THEN
       p_l29d := NULL;
    END IF;
    IF p_l29e = 0 THEN
       p_l29e := NULL;
    END IF;

    IF p_l30a = 0 THEN
       p_l30a := NULL;
    END IF;
    IF p_l30b = 0 THEN
       p_l30b := NULL;
    END IF;
    IF p_l30c = 0 THEN
       p_l30c := NULL;
    END IF;
    IF p_l30d = 0 THEN
       p_l30d := NULL;
    END IF;
    IF p_l30e = 0 THEN
       p_l30e := NULL;
    END IF;

    IF p_l31a = 0 THEN
       p_l31a := NULL;
    END IF;
    IF p_l31b = 0 THEN
       p_l31b := NULL;
    END IF;
    IF p_l31c = 0 THEN
       p_l31c := NULL;
    END IF;
    IF p_l31d = 0 THEN
       p_l31d := NULL;
    END IF;
    IF p_l31e = 0 THEN
       p_l31e := NULL;
    END IF;

  END repl_zero;
--
--
END ghr_sf113_a;

/
