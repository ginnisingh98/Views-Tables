--------------------------------------------------------
--  DDL for Package Body GHR_US_NFC_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_US_NFC_EXTRACTS" AS
/* $Header: ghrusnfcpa.pkb 120.32 2006/02/15 00:38:42 sumarimu noship $ */

-- =============================================================================
-- ~ Package body variables
-- =============================================================================

   g_proc_name  constant varchar2(200) :='GHR_US_NFC_Extracts.';
   g_debug      boolean;
   g_remark_cnt NUMBER;
   g_assignment_id NUMBER;
-- =============================================================================
-- ~ Package body cursors
-- =============================================================================

   -- Cursor to check has a valid personnel action within the extract date range
   -- Bug 4923586
   CURSOR csr_ghr_per (c_person_id      in number
                      ,c_assignment_id  in number
                      ,c_ext_start_date in date
                      ,c_ext_end_date   in date) is
   SELECT gpr.person_id
         ,gpr.employee_assignment_id
         ,gpr.effective_date
         ,gpr.last_update_date
         ,gpr.pa_request_id
         ,gpr.pa_notification_id
         ,gpr.first_noa_code
         ,gpr.second_noa_code
     FROM ghr_pa_requests gpr
    WHERE
         (TRUNC(gpr.effective_date) between c_ext_start_date
                                 and c_ext_end_date
          or
   /*       TRUNC(gpr.last_update_date) between c_ext_start_date
                                   and c_ext_end_date */
		TRUNC(gpr.approval_date) between c_ext_start_date
                                   and c_ext_end_date
          )
      AND TRUNC(gpr.effective_date) <=  c_ext_end_date
      AND gpr.person_id = c_person_id
      AND(gpr.first_noa_code NOT IN (825,840,841,842,843,844,
                                 845,846,847,848,878,879)
           --or
		   AND
           (--gpr.second_noa_code IS NOT NULL AND -- Bug 5031363
            NVL(gpr.second_noa_code,-1) NOT IN (825,840,841,842,843,844,
                                 845,846,847,848,878,879))
          )
      AND gpr.pa_notification_id IS NOT NULL
	  ORDER BY effective_date;
      --AND gpr.employee_assignment_id = c_assignment_id;
	  -- Bug 4629647
--Added by Gattu
-- =============================================================================
-- Cursor to get the extract record id
-- =============================================================================
   CURSOR csr_ext_rcd_id(c_hide_flag	IN VARCHAR2
		     ,c_rcd_type_cd	IN VARCHAR2) IS
    SELECT rcd.ext_rcd_id
     FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
    WHERE dfn.ext_dfn_id   = ben_ext_thread.g_ext_dfn_id
      AND rin.ext_file_id  = dfn.ext_file_id
      AND rin.hide_flag    = c_hide_flag     -- Y=Hidden, N=Not Hidden
      AND rin.ext_rcd_id   = rcd.ext_rcd_id
      AND rcd.rcd_type_cd  = c_rcd_type_cd;  --S- Sub Header D=Detail,H=Header,F=Footer

 -- =============================================================================
-- Used to get the concurrent request id
-- =============================================================================
   CURSOR csr_org_req (c_ext_dfn_id IN NUMBER
                     ,c_ext_rslt_id IN NUMBER
                     ,c_business_group_id IN NUMBER) IS
    SELECT bba.request_id
      FROM ben_benefit_actions bba
     WHERE bba.pl_id = c_ext_rslt_id
       AND bba.pgm_id = c_ext_dfn_id
       AND bba.business_group_id = c_business_group_id;

   -- Cursor to check has a valid Processed  Individual Award within
   -- the extract date range
   CURSOR csr_ghr_awd (c_person_id      in number
                      ,c_assignment_id  in number
                      ,c_ext_start_date in date
                      ,c_ext_end_date   in date) is
   SELECT gpr.person_id
         ,gpr.employee_assignment_id
         ,gpr.effective_date
         ,gpr.last_update_date
         ,gpr.pa_request_id
         ,gpr.pa_notification_id
         ,gpr.first_noa_code
         ,gpr.second_noa_code
     FROM ghr_pa_requests gpr
    WHERE(TRUNC(gpr.effective_date) between c_ext_start_date
                                 and c_ext_end_date
          or
         /* TRUNC(gpr.last_update_date) between c_ext_start_date
                                   and c_ext_end_date */
		  TRUNC(gpr.approval_date) between c_ext_start_date
                                   and c_ext_end_date
          )
      AND TRUNC(gpr.effective_date) <=  c_ext_end_date
      AND(gpr.first_noa_code in (825,840,841,842,843,844,
                                 845,846,847,848,878,879)
           or
           (gpr.second_noa_code is not null and
            gpr.second_noa_code in (825,840,841,842,843,844,
                                    845,846,847,848,878,879)
            )
          )
      AND gpr.pa_notification_id is not null
      AND gpr.person_id = c_person_id
      AND gpr.employee_assignment_id = c_assignment_id;

   --Cursor to get address only when the rpa is appointment
    CURSOR csr_per_add_apt (c_person_id      in number
                     ,c_ext_end_date   in date) is
    SELECT gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = c_person_id
		AND (gph.primary_flag='Y' OR gph.address_type = 'M') -- Bug 5037078
       AND gph.business_group_id = g_business_group_id
       AND gph.effective_date <=  c_ext_end_date
     ORDER by gph.pa_history_id desc;


   -- Cursor to check if the person has an address change within the extract
   -- date range.
   CURSOR csr_per_add(c_person_id      in number
                     ,c_ext_start_date in date
                     ,c_ext_end_date   in date) is
    SELECT gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = c_person_id
	   AND (gph.primary_flag='Y' OR gph.address_type = 'M') -- Bug 5037078
       AND gph.business_group_id = g_business_group_id
       AND(TRUNC(gph.effective_date) between c_ext_start_date
                                  and c_ext_end_date
           or
           TRUNC(gph.process_date) between c_ext_start_date
                                and c_ext_end_date
           )
       AND TRUNC(gph.effective_date) <=  c_ext_end_date
     ORDER by gph.pa_history_id desc;

   -- Cursor to get the remarks for a given RPA id
   CURSOR csr_rem (c_request_id in number
                   ,c_effective_date date) is
    SELECT gpr.remark_id
         ,gpr.pa_request_id
         ,gpr.pa_remark_id
         ,code
     FROM ghr_pa_remarks gpr
         ,ghr_remarks gr
    WHERE pa_request_id = c_request_id
      AND gr.remark_id=gpr.remark_id
      AND c_effective_date between gr.date_from
                               and NVL(gr.date_to,to_date('12/31/4712','MM/DD/YYYY'))
    ORDER BY remark_id;

   -- Cursor to get the enter record for a given pa_request_id
   CURSOR csr_rpa_rec(c_pa_request_id in number) is
   SELECT gpr.*
     FROM ghr_pa_requests  gpr
    WHERE pa_request_id = c_pa_request_id;

   -- Cursor to get the extract record id
   CURSOR csr_ext_rcd(c_hide_flag in varchar2
                     ,c_rcd_type_cd in varchar2
                      ) is
   SELECT rcd.ext_rcd_id
     FROM ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
    WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract executing currently
      AND rin.ext_file_id  = dfn.ext_file_id
      AND rin.hide_flag    = c_hide_flag    -- Y=Hidden, N=Not Hidden
      AND rin.ext_rcd_id   = rcd.ext_rcd_id
      AND rcd.rcd_type_cd  = c_rcd_type_cd; -- D=Detail,H=Header,F=Footer

   -- Cursor to get the extract result dtl record for a person id
   CURSOR csr_rslt_dtl(c_person_id      in number
                      ,c_ext_rslt_id    in number
                      ,c_ext_dtl_rcd_id in number ) is
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.person_id   = c_person_id
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;

   -- Get the benefit action details
   CURSOR csr_ben (c_ext_dfn_id in number
                  ,c_ext_rslt_id in number
                  ,c_business_group_id in number) is
   SELECT ben.pgm_id
         ,ben.pl_id
         ,ben.benefit_action_id
         ,ben.business_group_id
         ,ben.process_date
         ,ben.request_id
     FROM ben_benefit_actions ben
    WHERE ben.pl_id  = c_ext_rslt_id
      AND ben.pgm_id = c_ext_dfn_id
      AND ben.business_group_id = c_business_group_id;



--============================================================================
--get_rpa_extra_info_val
--===========================================================================
FUNCTION get_rpa_extra_info_val (p_rpa_req_id  IN NUMBER
                                ,p_info_type   IN VARCHAR2
                                )
RETURN ghr_pa_request_extra_info%ROWTYPE IS

CURSOR c_get_val (cp_rpa_req_id  NUMBER
                 ,cp_info_type   ghr_pa_request_extra_info.information_type%TYPE
                 )
IS
SELECT *
 FROM ghr_pa_request_extra_info gpre
WHERE gpre.pa_request_id=cp_rpa_req_id
  AND information_type=cp_info_type;

l_get_val ghr_pa_request_extra_info%ROWTYPE;

BEGIN

 OPEN c_get_val (p_rpa_req_id
                ,p_info_type
                );
 FETCH c_get_val INTO l_get_val;
 CLOSE c_get_val;

 RETURN (l_get_val);
END;

--============================================================================
--Get generic pay period number
--============================================================================

FUNCTION get_gen_pay_period_number (p_payroll_id             IN NUMBER
                                   ,p_business_group_id      IN NUMBER
                                   ,p_effective_date         IN DATE
                                   ,p_start_date             IN DATE
                                   ,p_end_date               IN DATE
                                    )
RETURN NUMBER IS

CURSOR c_get_period_num (cp_payroll_id              NUMBER
                        ,cp_business_group_id       NUMBER
                        ,cp_effective_date          DATE
                        )
IS
SELECT ptp.period_num
 FROM  per_time_periods ptp
WHERE   ptp.payroll_id=p_payroll_id
  AND  cp_effective_date BETWEEN ptp.start_date
                             AND ptp.end_date;

l_get_period_num c_get_period_num%ROWTYPE;
BEGIN

 OPEN c_get_period_num( p_payroll_id
                       ,p_business_group_id
                       ,p_effective_date
                       );
 FETCH c_get_period_num INTO l_get_period_num;
 CLOSE c_get_period_num;
 RETURN(NVL(l_get_period_num.period_num,-1));

END;
--============================================================================
--Get pay period number
--============================================================================

FUNCTION get_pay_period_number (p_person_id              IN  NUMBER
                               ,p_assignment_id          IN  NUMBER
                               ,p_business_group_id      IN  NUMBER
                               ,p_effective_date         IN  DATE
                               ,p_position_id            OUT NOCOPY  NUMBER
                               ,p_start_date             OUT NOCOPY  DATE
                               ,p_end_date               OUT NOCOPY  DATE
                               )
RETURN NUMBER IS
CURSOR c_get_period_num (cp_assignment_id           NUMBER
                        ,cp_business_group_id       NUMBER
                        ,cp_effective_date          DATE
                        )
IS
SELECT ptp.period_num
      ,ptp.start_date start_date
      ,ptp.end_date   end_date
      ,paa.position_id
 FROM  per_time_periods ptp
      ,per_all_assignments_f paa
WHERE  paa.assignment_id = cp_assignment_id
  AND  paa.business_group_id = cp_business_group_id
  AND  cp_effective_date BETWEEN paa.effective_start_date
                             AND paa.effective_end_date
  AND  paa.payroll_id  =ptp.payroll_id
  AND  cp_effective_date BETWEEN ptp.start_date
                             AND ptp.end_date;
i                per_all_assignments_f.business_group_id%TYPE;
l_get_period_num c_get_period_num%ROWTYPE;
l_get_period_num_temp c_get_period_num%ROWTYPE;
l_start_date  DATE;
l_end_date    DATE;
BEGIN
 l_get_period_num_temp:=NULL;
 IF p_assignment_id IS NOT NULL AND p_assignment_id <>-1 THEN
  OPEN c_get_period_num( p_assignment_id
                       ,p_business_group_id
                       ,p_effective_date
                       );
  FETCH c_get_period_num INTO l_get_period_num;
  CLOSE c_get_period_num;
  l_start_date := l_get_period_num.start_date;
  l_end_date   := l_get_period_num.end_date;
  p_position_id := l_get_period_num.position_id;

 END IF;

 i := g_business_group_id;

 IF l_get_period_num.period_num IS NULL THEN
  l_get_period_num.period_num:=
  get_gen_pay_period_number (p_payroll_id     =>g_extract_params(i).payroll_id
                             ,p_business_group_id =>p_business_group_id
                             ,p_effective_date    =>p_effective_date
                             ,p_start_date      =>l_start_date
                             ,p_end_date         =>l_end_date
                             );
 END IF;
 p_start_date:=l_start_date;
 p_end_date  :=l_end_date;
 IF l_get_period_num.period_num = 1 THEN
 --Get previous max pay period
 OPEN c_get_period_num( p_assignment_id
                       ,p_business_group_id
                       ,l_start_date-1
                       );
  FETCH c_get_period_num INTO l_get_period_num_temp;
  CLOSE c_get_period_num;
  IF l_get_period_num_temp.period_num IS NULL THEN
    l_get_period_num_temp.period_num:=26;
  END IF;
  RETURN (l_get_period_num_temp.period_num);
 ELSE
  RETURN((l_get_period_num.period_num-1));
 END IF;
 --RETURN(l_get_period_num.period_num);

END;

--==============================================================================
--Determine_address_chk
--==============================================================================

PROCEDURE Determine_address_chk ( p_person_id          NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_request_id              NUMBER
                       ,p_addr_type               VARCHAR2
                        )
IS
CURSOR c_get_pr_add (cp_person_id NUMBER
                        ,cp_ext_end_date Date)
   IS
   SELECT	gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = cp_person_id
       AND gph.primary_flag='Y'
       AND gph.business_group_id = g_business_group_id
       AND gph.effective_date <=  cp_ext_end_date
       ORDER BY gph.effective_date desc,gph.pa_history_id desc;

   CURSOR c_get_m_add (cp_person_id NUMBER
                      ,cp_ext_end_date Date)
   IS
   SELECT gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = cp_person_id
       AND gph.address_type='M'
       AND gph.business_group_id = g_business_group_id
       AND gph.effective_date <=  cp_ext_end_date
     ORDER by gph.effective_date desc,gph.pa_history_id desc;

CURSOR c_get_state (cp_effective_date   DATE
                   ,cp_state            VARCHAR2
                   )
IS
SELECT SUBSTR(duty_station_code,1,2) state_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE '%0000000' AND
(
 (substr(duty_station_code,1,1)
IN ('1','2','3','4','5','6','7','8','9','0')
AND  substr (duty_station_code,2,1)
IN ('1','2','3','4','5','6','7','8','9','0'))
OR   substr(duty_station_code,1,2)
IN ('AQ','GQ','RM','PS','VQ','FM','CQ','RQ') )
AND trunc(cp_effective_date)
BETWEEN effective_Start_date AND effective_end_date
AND EXISTS (SELECT 'X' FROM hr_lookups hrl WHERE lookup_type='US_STATE'
            AND UPPER(hrl.MEANING)=dut.name
            AND hrl.lookup_code=cp_state);

/*CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_county_name      VARCHAR2)
IS
SELECT SUBSTR(duty_station_code,7,3) county_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code like  cp_state_code ||  '0000%'
AND substr(duty_station_code,7,3) <> '000'
AND cp_effective_date BETWEEN
effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_county_name);*/


CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_city_name      VARCHAR2)
IS

SELECT dut.duty_station_code county_code
  FROM ghr_duty_stations_f dut
WHERE
dut.duty_station_code IN (
                          SELECT  SUBSTR(dut1.duty_station_code,0,2)||'0000'||SUBSTR(dut1.duty_station_code,7,3)
                            FROM ghr_duty_stations_f dut1,ghr_duty_stations_f dut2
                           WHERE dut1.name= UPPER(cp_city_name) AND dut2.duty_station_code =cp_state_code||'0000000'
                             AND SUBSTR(dut1.duty_station_code,0,2) = SUBSTR(dut2.duty_station_code,0,2)
                             AND substr(dut2.duty_station_code,3,7) = '0000000'
                             AND cp_effective_date  BETWEEN dut1.effective_start_date
                                                        AND dut1.effective_end_date
                             AND cp_effective_date  BETWEEN dut2.effective_start_date
                                                        AND dut2.effective_end_date
                           )
AND cp_effective_date  BETWEEN dut.effective_start_date
                           AND dut.effective_end_date;


CURSOR c_get_city (cp_state_code        VARCHAR2
                  ,cp_county_code       VARCHAR2
                  ,cp_effective_date    DATE
                  ,cp_city_name         VARCHAR2
                  )
IS
SELECT substr(duty_station_code,3,4) city_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE
cp_state_code || '%' ||   cp_county_code
AND substr(duty_station_code,3,4) <> '0000'
and trunc(cp_effective_date)
BETWEEN effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_city_name);


l_get_state      c_get_state%ROWTYPE;
l_get_county     c_get_county%ROWTYPE;
l_get_city       c_get_city%ROWTYPE;
l_get_pr_add     c_get_m_add%ROWTYPE;
BEGIN
 IF p_addr_type='N' THEN
   g_rpa_add_attr(p_assignment_id).address_line1_chk :=g_address_rec(p_assignment_id).address_line1;
   g_rpa_add_attr(p_assignment_id).address_line2_chk :=g_address_rec(p_assignment_id).address_line2;
   g_rpa_add_attr(p_assignment_id).address_line3_chk :=g_address_rec(p_assignment_id).address_line3;
   g_rpa_add_attr(p_assignment_id).add_county_chk :=g_address_rec(p_assignment_id).region_1;
   g_rpa_add_attr(p_assignment_id).zip_cd_chk :=g_address_rec(p_assignment_id).postal_code;
   IF g_address_rec(p_assignment_id).region_2='AA'  THEN
    g_rpa_add_attr(p_assignment_id).add_state_chk :='91';

   ELSIF g_address_rec(p_assignment_id).region_2='AE' THEN
    g_rpa_add_attr(p_assignment_id).add_state_chk :='92';

   ELSIF g_address_rec(p_assignment_id).region_2='AP' THEN
   g_rpa_add_attr(p_assignment_id).add_state_chk :='98' ;
  ELSE
   IF g_address_rec(p_assignment_id).region_2='FM' THEN

    g_rpa_add_attr(p_assignment_id).add_state_chk :='FM';

   ELSIF g_address_rec(p_assignment_id).region_2='MP' THEN

    g_rpa_add_attr(p_assignment_id).add_state_chk :='CQ';

   ELSE
    OPEN c_get_state (p_effective_date
                     ,g_address_rec(p_assignment_id).region_2
                   );
    FETCH c_get_state INTO l_get_state;
    CLOSE c_get_state;

    g_rpa_add_attr(p_assignment_id).add_state_chk:=l_get_state.state_code;
   END IF;

   IF g_address_rec(p_assignment_id).region_1 IS NULL THEN
    OPEN c_get_county (g_rpa_add_attr(p_assignment_id).add_state_chk
                       ,p_effective_date
                       ,g_address_rec(p_assignment_id).town_or_city);
    FETCH c_get_county INTO l_get_county;
    CLOSE c_get_county;

   g_rpa_add_attr(p_assignment_id).add_county_chk :=l_get_county.county_code;
   g_address_rec(p_assignment_id).region_1:=l_get_county.county_code;
   END IF;
    OPEN c_get_city (g_rpa_add_attr(p_assignment_id).add_state_chk
                  ,SUBSTR (g_address_rec(p_assignment_id).region_1,7,3)
                  ,p_effective_date
                  ,g_address_rec(p_assignment_id).town_or_city
                  );
    FETCH c_get_city INTO l_get_city;
    CLOSE c_get_city;

    g_rpa_add_attr(p_assignment_id).add_city_chk :=l_get_city.city_code;

  END IF;
 ELSE
  OPEN c_get_m_add (p_person_id
                     ,p_effective_date);
  FETCH c_get_m_add INTO l_get_pr_add;
  CLOSE c_get_m_add;

   g_rpa_add_attr(p_assignment_id).address_line1_chk :=l_get_pr_add.address_line1;
   g_rpa_add_attr(p_assignment_id).address_line2_chk :=l_get_pr_add.address_line2;
   g_rpa_add_attr(p_assignment_id).address_line3_chk :=l_get_pr_add.address_line3;
   g_rpa_add_attr(p_assignment_id).add_county_chk    :=l_get_pr_add.region_1;
   g_rpa_add_attr(p_assignment_id).zip_cd_chk :=l_get_pr_add.postal_code;
   IF l_get_pr_add.region_2='AA'  THEN
    g_rpa_add_attr(p_assignment_id).add_state_chk :='91';

   ELSIF l_get_pr_add.region_2='AE' THEN
    g_rpa_add_attr(p_assignment_id).add_state_chk :='92';

   ELSIF l_get_pr_add.region_2='AP' THEN
   g_rpa_add_attr(p_assignment_id).add_state_chk :='98' ;
   ELSE
    IF l_get_pr_add.region_2='FM' THEN

    g_rpa_add_attr(p_assignment_id).add_state_chk :='FM';

   ELSIF l_get_pr_add.region_2='MP' THEN

    g_rpa_add_attr(p_assignment_id).add_state_chk :='CQ';

   ELSE
    OPEN c_get_state (p_effective_date
                     ,l_get_pr_add.region_2
                   );
    FETCH c_get_state INTO l_get_state;
    CLOSE c_get_state;

    g_rpa_add_attr(p_assignment_id).add_state_chk:=l_get_state.state_code;
   END IF;

   IF l_get_pr_add.region_1 IS NULL THEN
    OPEN c_get_county (g_rpa_add_attr(p_assignment_id).add_state_chk
                       ,p_effective_date
                       ,l_get_pr_add.town_or_city);
    FETCH c_get_county INTO l_get_county;
    CLOSE c_get_county;

    g_rpa_add_attr(p_assignment_id).add_county_chk   :=l_get_county.county_code;
    l_get_pr_add.region_1:=l_get_county.county_code;
   END IF;
    OPEN c_get_city (g_rpa_add_attr(p_assignment_id).add_state_chk
                  ,SUBSTR (l_get_pr_add.region_1,7,3)
                  ,p_effective_date
                  ,l_get_pr_add.town_or_city
                  );
    FETCH c_get_city INTO l_get_city;
    CLOSE c_get_city;

    g_rpa_add_attr(p_assignment_id).add_city_chk :=l_get_city.city_code;

  END IF;
 END IF;
END;






--==============================================================================
--Determine_address_primary
--==============================================================================

PROCEDURE Determine_address_pr ( p_person_id          NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_request_id              NUMBER
                       ,p_addr_type               VARCHAR2
                        )
IS
CURSOR c_get_pr_add (cp_person_id NUMBER
                        ,cp_ext_end_date Date)
   IS
   SELECT  gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = cp_person_id
       AND gph.primary_flag='Y'
       AND gph.business_group_id = g_business_group_id
       AND gph.effective_date <=  cp_ext_end_date
     ORDER by gph.effective_date desc,gph.pa_history_id desc;

   CURSOR c_get_m_add (cp_person_id NUMBER
                      ,cp_ext_end_date Date)
   IS
   SELECT gph.*
      FROM ghr_addresses_h_v gph
     WHERE gph.person_id  = cp_person_id
       AND gph.address_type='M'
       AND gph.business_group_id = g_business_group_id
       AND gph.effective_date <=  cp_ext_end_date
     ORDER by gph.effective_date desc,gph.pa_history_id desc;

CURSOR c_get_state (cp_effective_date   DATE
                   ,cp_state            VARCHAR2
                   )
IS
SELECT SUBSTR(duty_station_code,1,2) state_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE '%0000000' AND
(
 (substr(duty_station_code,1,1)
IN ('1','2','3','4','5','6','7','8','9','0')
AND  substr (duty_station_code,2,1)
IN ('1','2','3','4','5','6','7','8','9','0'))
OR   substr(duty_station_code,1,2)
IN ('AQ','GQ','RM','PS','VQ','FM','CQ','RQ') )
AND trunc(cp_effective_date)
BETWEEN effective_Start_date AND effective_end_date
AND EXISTS (SELECT 'X' FROM hr_lookups hrl WHERE lookup_type='US_STATE'
            AND UPPER(hrl.MEANING)=dut.name
            AND hrl.lookup_code=cp_state);

/*CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_county_name      VARCHAR2)
IS
SELECT SUBSTR(duty_station_code,7,3) county_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code like  cp_state_code ||  '0000%'
AND substr(duty_station_code,7,3) <> '000'
AND cp_effective_date BETWEEN
effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_county_name);*/

CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_city_name      VARCHAR2)
IS

SELECT dut.duty_station_code county_code
  FROM ghr_duty_stations_f dut
WHERE
dut.duty_station_code IN (
                          SELECT  SUBSTR(dut1.duty_station_code,0,2)||'0000'||SUBSTR(dut1.duty_station_code,7,3)
                            FROM ghr_duty_stations_f dut1,ghr_duty_stations_f dut2
                           WHERE dut1.name= UPPER(cp_city_name) AND dut2.duty_station_code =cp_state_code||'0000000'
                             AND SUBSTR(dut1.duty_station_code,0,2) = SUBSTR(dut2.duty_station_code,0,2)
                             AND substr(dut2.duty_station_code,3,7) = '0000000'
                             AND cp_effective_date  BETWEEN dut1.effective_start_date
                                                        AND dut1.effective_end_date
                             AND cp_effective_date  BETWEEN dut2.effective_start_date
                                                        AND dut2.effective_end_date
                           )
AND cp_effective_date  BETWEEN dut.effective_start_date
                           AND dut.effective_end_date;


CURSOR c_get_city (cp_state_code        VARCHAR2
                  ,cp_county_code       VARCHAR2
                  ,cp_effective_date    DATE
                  ,cp_city_name         VARCHAR2
                  )
IS
SELECT substr(duty_station_code,3,4) city_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE
cp_state_code || '%' ||   cp_county_code
AND substr(duty_station_code,3,4) <> '0000'
and trunc(cp_effective_date)
BETWEEN effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_city_name);


l_get_state      c_get_state%ROWTYPE;
l_get_county     c_get_county%ROWTYPE;
l_get_city       c_get_city%ROWTYPE;
l_get_pr_add     c_get_pr_add%ROWTYPE;
BEGIN


 IF p_addr_type='Y' THEN
	hr_utility.set_location('Entering pr 1' , 1234);
   g_rpa_add_attr(p_assignment_id).address_line1 :=g_address_rec(p_assignment_id).address_line1;
   g_rpa_add_attr(p_assignment_id).address_line2 :=g_address_rec(p_assignment_id).address_line2;
   g_rpa_add_attr(p_assignment_id).address_line3 :=g_address_rec(p_assignment_id).address_line3;
   g_rpa_add_attr(p_assignment_id).zip_cd    :=g_address_rec(p_assignment_id).postal_code;
  -- g_rpa_add_attr(p_assignment_id).add_county :=g_address_rec(p_assignment_id).region_1;

	hr_utility.set_location('pr Add 1' || g_address_rec(p_assignment_id).address_line1, 1234);

   IF g_address_rec(p_assignment_id).region_2='AA'  THEN
	    g_rpa_add_attr(p_assignment_id).add_state :='91';
   ELSIF g_address_rec(p_assignment_id).region_2='AE' THEN
	    g_rpa_add_attr(p_assignment_id).add_state :='92';
   ELSIF g_address_rec(p_assignment_id).region_2='AP' THEN
		g_rpa_add_attr(p_assignment_id).add_state :='98' ;
   ELSIF g_address_rec(p_assignment_id).region_2='FM' THEN
		g_rpa_add_attr(p_assignment_id).add_state :='FM';
   ELSIF g_address_rec(p_assignment_id).region_2='MP' THEN
		g_rpa_add_attr(p_assignment_id).add_state :='CQ';
   ELSE
		OPEN c_get_state (p_effective_date
					 ,g_address_rec(p_assignment_id).region_2
				   );
		FETCH c_get_state INTO l_get_state;
		CLOSE c_get_state;
		g_rpa_add_attr(p_assignment_id).add_state:=l_get_state.state_code;
   END IF; -- IF g_address_rec(p_assignment_id).region_2='AA'

   hr_utility.set_location('State ' || g_rpa_add_attr(p_assignment_id).add_state,1001);

	hr_utility.set_location('County ' || g_address_rec(p_assignment_id).region_1,1001);

--   IF g_address_rec(p_assignment_id).region_1 IS NULL THEN
		OPEN c_get_county (g_rpa_add_attr(p_assignment_id).add_state
						   ,p_effective_date
						   ,g_address_rec(p_assignment_id).town_or_city);
		FETCH c_get_county INTO l_get_county;
		CLOSE c_get_county;
		g_address_rec(p_assignment_id).region_1:=l_get_county.county_code;
		g_rpa_add_attr(p_assignment_id).add_county := l_get_county.county_code;
  -- END IF;
      hr_utility.set_location('County ' || g_rpa_add_attr(p_assignment_id).add_county,1001);

	OPEN c_get_city (g_rpa_add_attr(p_assignment_id).add_state
				  ,SUBSTR (g_address_rec(p_assignment_id).region_1,7,3)
				  ,p_effective_date
				  ,g_address_rec(p_assignment_id).town_or_city
				  );
	FETCH c_get_city INTO l_get_city;
	CLOSE c_get_city;
	g_rpa_add_attr(p_assignment_id).add_city :=l_get_city.city_code;
	hr_utility.set_location('City ' || g_rpa_add_attr(p_assignment_id).add_city,1001);

 ELSE --  IF p_addr_type='Y' THEN

  hr_utility.set_location('Entering pr 2' , 1234);

  OPEN c_get_pr_add (p_person_id
                     ,p_effective_date);
  FETCH c_get_pr_add INTO l_get_pr_add;
  CLOSE c_get_pr_add;

   hr_utility.set_location('Entering pr 2' || l_get_pr_add.address_line1, 1234);
   g_rpa_add_attr(p_assignment_id).address_line1 :=l_get_pr_add.address_line1;
   g_rpa_add_attr(p_assignment_id).address_line2 :=l_get_pr_add.address_line2;
   g_rpa_add_attr(p_assignment_id).address_line3 :=l_get_pr_add.address_line3;
   g_rpa_add_attr(p_assignment_id).add_county :=l_get_pr_add.region_1;
   g_rpa_add_attr(p_assignment_id).zip_cd    :=l_get_pr_add.postal_code;

   IF l_get_pr_add.region_2='AA'  THEN
		g_rpa_add_attr(p_assignment_id).add_state :='91';
   ELSIF l_get_pr_add.region_2='AE' THEN
		g_rpa_add_attr(p_assignment_id).add_state :='92';
   ELSIF l_get_pr_add.region_2='AP' THEN
		g_rpa_add_attr(p_assignment_id).add_state :='98' ;
   ELSE
		IF l_get_pr_add.region_2='FM' THEN
		    g_rpa_add_attr(p_assignment_id).add_state :='FM';
	    ELSIF l_get_pr_add.region_2='MP' THEN
		    g_rpa_add_attr(p_assignment_id).add_state :='CQ';
		ELSE
			OPEN c_get_state (p_effective_date
							 ,l_get_pr_add.region_2
						   );
			FETCH c_get_state INTO l_get_state;
			CLOSE c_get_state;
		    g_rpa_add_attr(p_assignment_id).add_state:=l_get_state.state_code;
	   END IF; -- IF l_get_pr_add.region_2='FM'

	   IF l_get_pr_add.region_1 IS NOT NULL THEN
			OPEN c_get_county (g_rpa_add_attr(p_assignment_id).add_state
							   ,p_effective_date
							   ,l_get_pr_add.town_or_city);
			FETCH c_get_county INTO l_get_county;
			CLOSE c_get_county;
			l_get_pr_add.region_1:=l_get_county.county_code;
			g_rpa_add_attr(p_assignment_id).add_county := l_get_county.county_code;
	   END IF;

		OPEN c_get_city (g_rpa_add_attr(p_assignment_id).add_state
					  ,SUBSTR (l_get_pr_add.region_1,7,3)
					  ,p_effective_date
					  ,l_get_pr_add.town_or_city
					  );
		FETCH c_get_city INTO l_get_city;
		CLOSE c_get_city;
	    g_rpa_add_attr(p_assignment_id).add_city :=l_get_city.city_code;
  END IF; --  IF l_get_pr_add.region_2='AA'
 END IF; -- IF p_addr_type='Y' THEN


END Determine_address_pr;
-- =============================================================================
-- Populate_add_attr
-- ============================================================================
PROCEDURE populate_add_attr (p_person_id          NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_request_id              NUMBER
                       )
IS
CURSOR c_get_asg_info
IS
SELECT position_id
 FROM per_all_assignments_f paa
WHERE paa.assignment_id=p_assignment_id
  AND paa.business_group_id=p_business_group_id
  AND p_effective_date BETWEEN paa.effective_start_date
   and paa.effective_end_date;

CURSOR c_ssn (cp_person_id   NUMBER
             ,cp_business_group_id NUMBER
             ,cp_effective_date  DATE
             )
IS
SELECT national_identifier
  FROM per_all_people_f ppf
 WHERE person_id=cp_person_id
   AND ppf.business_group_id=p_business_group_id
   AND p_effective_date BETWEEN ppf.effective_start_date
                            AND ppf.effective_end_date;

CURSOR c_get_pos_info (cp_position_id       NUMBER
                      ,cp_business_group_id NUMBER
                      ,cp_effective_date    DATE
                      )
IS
SELECT pdf.segment3 NFC_Agency_Code,
        pdf.segment4 POI,
        pdf.segment7 Grade
   FROM hr_all_positions_f pos, per_position_definitions pdf
  WHERE pos.position_definition_id = pdf.position_definition_id
    AND pos.position_id = cp_position_id
    AND cp_effective_date between pos.effective_start_date
    AND pos.effective_end_date
    AND pos.business_group_id=cp_business_group_id;



CURSOR c_get_state (cp_effective_date   DATE
                   ,cp_state            VARCHAR2
                   )
IS
SELECT SUBSTR(duty_station_code,1,2) state_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE '%0000000' AND
(
 (substr(duty_station_code,1,1)
IN ('1','2','3','4','5','6','7','8','9','0')
AND  substr (duty_station_code,2,1)
IN ('1','2','3','4','5','6','7','8','9','0'))
OR   substr(duty_station_code,1,2)
IN ('AQ','GQ','RM','PS','VQ','FM','CQ','RQ') )
AND trunc(cp_effective_date)
BETWEEN effective_Start_date AND effective_end_date
AND EXISTS (SELECT 'X' FROM hr_lookups hrl WHERE lookup_type='US_STATE'
            AND UPPER(hrl.MEANING)=dut.name
            AND hrl.lookup_code=cp_state);

/*CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_county_name      VARCHAR2)
IS
SELECT SUBSTR(duty_station_code,7,3) county_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code like  cp_state_code ||  '0000%'
AND substr(duty_station_code,7,3) <> '000'
AND cp_effective_date BETWEEN
effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_county_name);*/


CURSOR c_get_county (cp_state_code       VARCHAR2
                    ,cp_effective_date   DATE
                    ,cp_city_name      VARCHAR2)
IS

SELECT dut.duty_station_code county_code
  FROM ghr_duty_stations_f dut
WHERE
dut.duty_station_code IN (
                          SELECT  SUBSTR(dut1.duty_station_code,0,2)||'0000'||SUBSTR(dut1.duty_station_code,7,3)
                            FROM ghr_duty_stations_f dut1,ghr_duty_stations_f dut2
                           WHERE dut1.name= UPPER(cp_city_name) AND dut2.duty_station_code =cp_state_code||'0000000'
                             AND SUBSTR(dut1.duty_station_code,0,2) = SUBSTR(dut2.duty_station_code,0,2)
                             AND substr(dut2.duty_station_code,3,7) = '0000000'
                             AND cp_effective_date  BETWEEN dut1.effective_start_date
                                                        AND dut1.effective_end_date
                             AND cp_effective_date  BETWEEN dut2.effective_start_date
                                                        AND dut2.effective_end_date
                           )
AND cp_effective_date  BETWEEN dut.effective_start_date
                           AND dut.effective_end_date;


CURSOR c_get_city (cp_state_code        VARCHAR2
                  ,cp_county_code       VARCHAR2
                  ,cp_effective_date    DATE
                  ,cp_city_name         VARCHAR2
                  )
IS
SELECT substr(duty_station_code,3,4) city_code
FROM ghr_duty_stations_f dut
WHERE duty_station_code LIKE
cp_state_code || '%' ||   cp_county_code
AND substr(duty_station_code,3,4) <> '0000'
and trunc(cp_effective_date)
BETWEEN effective_Start_date and effective_end_Date
AND dut.name=UPPER(cp_city_name);




l_get_state      c_get_state%ROWTYPE;
l_get_county     c_get_county%ROWTYPE;
l_get_city       c_get_city%ROWTYPE;
l_get_pos_info  c_get_pos_info%ROWTYPE;
l_get_asg_info c_get_asg_info%ROWTYPE;
l_pos_ag_code   VARCHAR2(30);
l_start_date    DATE;
l_end_date      DATE;
l_position_id   NUMBER;
l_posi_extra_info per_position_extra_info%ROWTYPE;
l_proc_name  constant varchar2(150) := g_proc_name ||'populate_add_attr';
l_ssn  c_ssn%ROWTYPE;
BEGIN
  hr_utility.set_location ('Enter '||l_proc_name,5);

 /* OPEN c_ssn (p_person_id
             ,p_business_group_id
             ,p_effective_date
             );
  FETCH c_ssn INTO l_ssn;
  CLOSE c_ssn;*/
  OPEN c_get_asg_info;
  FETCH c_get_asg_info INTO l_get_asg_info;
  CLOSE c_get_asg_info;

  g_rpa_add_attr(p_assignment_id).assignment_id := p_assignment_id;
  g_rpa_add_attr(p_assignment_id).request_id    := p_request_id;

  hr_utility.set_location (l_proc_name,10);
   g_rpa_add_attr(p_assignment_id).pay_per_num:=
                       get_pay_period_number
                        (p_person_id           => p_person_id
                        ,p_assignment_id       =>p_assignment_id
                        ,p_business_group_id   =>p_business_group_id
                        ,p_effective_date      =>p_effective_date
                        ,p_position_id         =>l_position_id
                        ,p_start_date          =>l_start_date
                        ,p_end_date            =>l_end_date
                        );
  --g_rpa_add_attr(p_assignment_id).ssn:=l_ssn.national_identifier;

  hr_utility.set_location (l_proc_name,15);
   ghr_history_fetch.fetch_positionei
                           ( p_position_id      => l_position_id
                            ,p_information_type =>'GHR_US_POS_GRP3'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);

  g_rpa_add_attr(p_assignment_id).nfc_agency_code := l_posi_extra_info.poei_information21;

  hr_utility.set_location (l_proc_name,20);
   ghr_history_fetch.fetch_positionei
                           ( p_position_id      => l_position_id
                            ,p_information_type =>'GHR_US_POS_GRP1'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);

  g_rpa_add_attr(p_assignment_id).poi := l_posi_extra_info.poei_information1;

  IF g_rpa_add_attr(p_assignment_id).nfc_agency_code IS NULL OR
     g_rpa_add_attr(p_assignment_id).poi IS NULL THEN


   OPEN c_get_pos_info( l_position_id
                       ,p_business_group_id
                       ,p_effective_date
                       );
   FETCH c_get_pos_info INTO l_get_pos_info;
   CLOSE c_get_pos_info;

   IF g_rpa_add_attr(p_assignment_id).nfc_agency_code IS NULL THEN
    g_rpa_add_attr(p_assignment_id).nfc_agency_code :=l_get_pos_info.nfc_agency_code;
   END IF;
   IF g_rpa_add_attr(p_assignment_id).poi IS NULL THEN
    g_rpa_add_attr(p_assignment_id).poi := l_get_pos_info.poi;
   END IF;
  END IF;
  hr_utility.set_location (l_proc_name,25);
  l_pos_ag_code :=ghr_api.get_position_agency_code_pos
                           (p_position_id        =>l_position_id
                           ,p_business_group_id  =>p_business_group_id
                           ,p_effective_date     =>p_effective_date) ;

  g_rpa_add_attr(p_assignment_id).dept_code := SUBSTR(l_pos_ag_code,0,2);


  hr_utility.set_location (l_proc_name,30);

---This part fetches code from duty station table for state
--county and city.

  IF g_address_rec(p_assignment_id).primary_flag='Y' THEN
  Determine_address_pr ( p_person_id         =>p_person_id
                       ,p_assignment_id        =>p_assignment_id
                       ,p_business_group_id    =>p_business_group_id
                       ,p_effective_date       =>p_effective_date
                       ,p_request_id           =>p_request_id
                       ,p_addr_type            =>'Y'
                        );
   Determine_address_chk ( p_person_id         =>p_person_id
                       ,p_assignment_id        =>p_assignment_id
                       ,p_business_group_id    =>p_business_group_id
                       ,p_effective_date       =>p_effective_date
                       ,p_request_id           =>p_request_id
                       ,p_addr_type            =>'Y'
                        );
 ELSE
  Determine_address_pr ( p_person_id         =>p_person_id
                       ,p_assignment_id        =>p_assignment_id
                       ,p_business_group_id    =>p_business_group_id
                       ,p_effective_date       =>p_effective_date
                       ,p_request_id           =>p_request_id
                       ,p_addr_type            =>'N'
                        );
   Determine_address_chk ( p_person_id         =>p_person_id
                       ,p_assignment_id        =>p_assignment_id
                       ,p_business_group_id    =>p_business_group_id
                       ,p_effective_date       =>p_effective_date
                       ,p_request_id           =>p_request_id
                       ,p_addr_type            =>'N'
                        );

 END IF;
  hr_utility.set_location (l_proc_name,60);

END;


-- =============================================================================
-- Populate_awd_attr
-- ============================================================================
PROCEDURE populate_awd_attr (p_person_id          NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_first_noa_cd            VARCHAR2
                       ,p_sec_noa_cd              VARCHAR2
                       ,p_request_id              NUMBER
                       ,p_notification_id         NUMBER
                       )
IS

l_posi_extra_info per_position_extra_info%rowtype;
l_pos_ag_code   VARCHAR2(30);
l_start_date    DATE;
l_end_date      DATE;
l_temp          NUMBER;

CURSOR c_get_city (cp_state_code VARCHAR2
                  ,cp_city_code VARCHAR2
                  ,cp_date       DATE
                  )
IS
SELECT dut.name
  FROM ghr_duty_stations_f dut
 WHERE substr(duty_station_code,3,4) = cp_city_code
   AND substr(duty_station_code,0,2)= cp_state_code
   AND cp_date BETWEEN effective_Start_date
   AND effective_end_Date;

CURSOR c_get_state (cp_state_code VARCHAR2
                   ,cp_date       DATE
                   )
IS
SELECT pus.state_abbrev name
  FROM pay_us_states pus
 WHERE UPPER(pus.state_name)=
  (SELECT dut.name
     FROM  ghr_duty_stations_f dut
    WHERE duty_station_code like '%0000000'  AND
    (
    (SUBSTR(duty_station_code,1,1) in ('1','2','3','4','5','6','7','8','9','0')
    AND  SUBSTR (duty_station_code,2,1) in ('1','2','3','4','5','6','7','8','9','0'))
    OR   SUBSTR(duty_station_code,1,2) in ('AQ','GQ','RM','PS','VQ','FM','CQ') )
    AND cp_date BETWEEN effective_Start_date and effective_end_Date
    AND SUBSTR(duty_station_code,0,2)= cp_state_code);

CURSOR c_get_extra_info (cp_request_id        NUMBER
                        ,cp_information_type  VARCHAR2
                        )
IS
SELECT *
 FROM ghr_pa_request_extra_info gpre
--WHERE gpre.request_id = cp_request_id Bug 4641232 Sundar
WHERE gpre.pa_request_id = cp_request_id
  AND gpre.information_type = cp_information_type;

CURSOR c_get_addr_info (cp_person_id NUMBER
                       ,cp_business_group_id NUMBER
                       ,cp_effective_date    DATE
                       )
IS
SELECT *
 FROM per_addresses pa
WHERE pa.person_id = cp_person_id
  AND pa.business_group_id=cp_business_group_id
  AND cp_effective_date BETWEEN pa.date_from
                            AND NVL(pa.date_to,TO_DATE('12/31/4712','MM/DD/YYYY'))
  AND pa.primary_flag='Y';

/*CURSOR c_get_auth_date(c_person_id  ghr_pa_requests.person_id%TYPE,
						c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT pa_request_id, (effective_date+rownum)-1 auth_date
FROM  ghr_pa_requests
WHERE person_id = c_person_id
AND   first_noa_code NOT IN ('001','002')
AND pa_notification_id IS NOT NULL
AND   effective_date = c_effective_date
ORDER BY last_update_date ASC;
*/

CURSOR c_get_auth_date(c_person_id  ghr_pa_requests.person_id%TYPE,
						c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT pa_request_id, (effective_date+rownum)-1 auth_date, noa_code
FROM
(
	SELECT  pa_request_id, effective_date, last_update_date,first_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code NOT IN ('001','002')
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
UNION ALL
	SELECT  pa_request_id, effective_date, last_update_date,second_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code = '317'
	AND second_noa_code = '825'
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
ORDER BY last_update_date
) par;



CURSOR c_rpas_on_date(c_person_id  ghr_pa_requests.person_id%TYPE,
 					c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT COUNT(*) auth_date
FROM
(
	SELECT  pa_request_id, effective_date, last_update_date,first_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code NOT IN ('001','002')
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
UNION ALL
	SELECT  pa_request_id, effective_date, last_update_date,second_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code = '317'
	AND second_noa_code = '825'
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
ORDER BY last_update_date
) par;

l_no_rpa_count BOOLEAN;
l_auth_date date;
l_noa_code ghr_pa_requests.first_noa_code%type;

l_get_addr_info c_get_addr_info%ROWTYPE;

l_get_extra_info   c_get_extra_info%ROWTYPE;
l_temp1  varchar2(80);
l_get_state c_get_state%ROWTYPE;
l_get_city  c_get_city%ROWTYPE;
l_get_ei_val ghr_pa_request_extra_info%ROWTYPE;
BEGIN

  l_no_rpa_count := FALSE;
  g_rpa_awd_attr(p_request_id).assignment_id := p_assignment_id;
  g_rpa_awd_attr(p_request_id).request_id    := p_request_id;

  IF g_awd_rec(p_request_id).to_position_id IS NULL then
     g_awd_rec(p_request_id).to_position_id := g_awd_rec(p_request_id).from_position_id;
  END IF;

   ghr_history_fetch.fetch_positionei
                           ( p_position_id      => g_awd_rec(p_request_id).to_position_id
                            ,p_information_type =>'GHR_US_POS_GRP3'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);

  g_rpa_awd_attr(p_request_id).nfc_agency_code := l_posi_extra_info.poei_information21;

  l_pos_ag_code :=ghr_api.get_position_agency_code_pos
                           (p_position_id        =>g_awd_rec(p_request_id).to_position_id
                           ,p_business_group_id  =>p_business_group_id
                           ,p_effective_date     =>p_effective_date) ;

  g_rpa_awd_attr(p_request_id).dept_code := SUBSTR(l_pos_ag_code,0,2);

  g_rpa_awd_attr(p_request_id).pay_per_num:=
                       get_pay_period_number
                        (p_person_id           => p_person_id
                        ,p_assignment_id       =>p_assignment_id
                        ,p_business_group_id   =>p_business_group_id
                        ,p_effective_date      =>p_effective_date
                        ,p_position_id         => l_temp
                        ,p_start_date          =>l_start_date
                        ,p_end_date            =>l_end_date
                        );
  g_rpa_awd_attr(p_request_id).dt_cash_awd_from := l_start_date;
  g_rpa_awd_attr(p_request_id).dt_cash_awd_to   := l_end_date;

  OPEN c_get_extra_info (p_request_id
                        ,'GHR_US_PAR_AWARDS_BONUS'
                         );
  FETCH c_get_extra_info INTO l_get_extra_info;
  CLOSE c_get_extra_info;

  g_rpa_awd_attr(p_request_id).cash_award_agency := l_get_extra_info.rei_information3;
  IF
  --g_awd_rec(p_request_id).first_noa_code = '300'
--  AND  g_awd_rec(p_request_id).first_noa_code <= '399'
-- Above code commented by Sundar Bug 4641232
	g_awd_rec(p_request_id).noa_family_code   = 'SEPARATION'
  AND g_awd_rec(p_request_id).second_noa_code   = '825'
  THEN
   g_rpa_awd_attr(p_request_id).nat_act_2nd_3pos := '825';
   g_rpa_awd_attr(p_request_id).csc_auth_code_2nd_noa:= g_awd_rec(p_request_id).second_action_la_code1;
   g_rpa_awd_attr(p_request_id).csc_auth_2ndcode_2nd_noa := g_awd_rec(p_request_id).second_action_la_code2;
  ELSIF g_awd_rec(p_request_id).first_noa_code ='001'
  OR     g_awd_rec(p_request_id).first_noa_code ='002' THEN
   g_rpa_awd_attr(p_request_id).nat_act_2nd_3pos := g_awd_rec(p_request_id).second_noa_code;
   g_rpa_awd_attr(p_request_id).nat_act_1st_3_pos := g_awd_rec(p_request_id).first_noa_code;
   g_rpa_awd_attr(p_request_id).csc_auth_code_2nd_noa:= g_awd_rec(p_request_id).first_action_la_code1;
   g_rpa_awd_attr(p_request_id).csc_auth_2ndcode_2nd_noa := g_awd_rec(p_request_id).first_action_la_code2;
  null;
  ELSE
   g_rpa_awd_attr(p_request_id).nat_act_2nd_3pos := g_awd_rec(p_request_id).first_noa_code;
   g_rpa_awd_attr(p_request_id).csc_auth_code_2nd_noa:= g_awd_rec(p_request_id).first_action_la_code1;
   g_rpa_awd_attr(p_request_id).csc_auth_2ndcode_2nd_noa := g_awd_rec(p_request_id).first_action_la_code2;
  null;
  END IF;

  OPEN c_get_addr_info (p_person_id
                       ,p_business_group_id
                       ,p_effective_date
                       );
  FETCH c_get_addr_info INTO l_get_addr_info;
  CLOSE c_get_addr_info;

 IF g_awd_rec(p_request_id).award_uom='M' THEN
  g_rpa_awd_attr(p_request_id).current_cash_award := LPAD(REPLACE(g_awd_rec(p_request_id).award_amount,'.'),7,'0');
 ELSIF g_awd_rec(p_request_id).award_uom='H' THEN

  g_rpa_awd_attr(p_request_id).current_cash_award := LPAD(g_awd_rec(p_request_id).award_amount,7,'0');
 END IF;

--derive city and state
--commented due to change in address storage format
--uncommented temporarily
 /* OPEN c_get_state (l_get_addr_info.region_2
                   ,p_effective_date
                   );
  FETCH c_get_state INTO l_get_state;
  CLOSE c_get_state;

  OPEN c_get_city (l_get_addr_info.region_2
                  ,l_get_addr_info.town_or_city
                  ,p_effective_date
                  );
  FETCH c_get_city INTO l_get_city;
  CLOSE c_get_city;*/

  g_rpa_awd_attr(p_request_id).chk_mail_addr_ln1 := l_get_addr_info.address_line1;
  g_rpa_awd_attr(p_request_id).chk_mail_addr_ln2 := l_get_addr_info.address_line2;
  g_rpa_awd_attr(p_request_id).chk_mail_addr_city_name :=l_get_addr_info.town_or_city;  --l_get_city.name;
  g_rpa_awd_attr(p_request_id).chk_mail_addr_state_name := l_get_addr_info.region_2; --l_get_state.name;
  g_rpa_awd_attr(p_request_id).chk_mail_addr_zip_5 := SUBSTR(l_get_addr_info.postal_code,0,5);
  IF LENGTH(LTRIM(RTRIM(l_get_addr_info.postal_code)))>5 THEN
  /*g_rpa_awd_attr(p_request_id).chk_mail_addr_zip_4 := SUBSTR(l_get_addr_info.postal_code,
                                                      INSTR(REPLACE(l_get_addr_info.postal_code,' ','-'),'-'),5);*/

  g_rpa_awd_attr(p_request_id).chk_mail_addr_zip_4:=SUBSTR(REPLACE(REPLACE (l_get_addr_info.postal_code,
                                                  (substr(l_get_addr_info.postal_code, 0,5))),'-'),0,4);
  END IF;
  g_rpa_awd_attr(p_request_id).chk_mail_addr_zip_2 := NULL; --SUBSTR(l_get_addr_info.postal_code,4,5);

   --derive Authentication Date
/*  l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_NFC_INFO'
                          ); */
	-- Bug 4990382 Get Authentication date.
	FOR l_no_rpas IN c_rpas_on_date(p_person_id,p_effective_date) LOOP
		l_no_rpa_count := TRUE;
	END LOOP;

	IF g_awd_rec(p_request_id).noa_family_code   = 'SEPARATION'
	  AND g_awd_rec(p_request_id).second_noa_code   = '825' THEN
		 l_noa_code := '825';
	ELSE
		l_noa_code := p_first_noa_cd;
	END IF;

	IF l_no_rpa_count = TRUE THEN
		FOR l_get_auth_date IN c_get_auth_date(p_person_id,p_effective_date) LOOP
			IF p_request_id = l_get_auth_date.pa_request_id
				AND l_noa_code = l_get_auth_date.noa_code THEN
					l_auth_date := l_get_auth_date.auth_date;
			END IF;
		END LOOP;
	END IF;

	IF l_no_rpa_count = FALSE THEN
		l_auth_date := p_effective_date;
	END IF;

   l_no_rpa_count := FALSE;
   -- End Bug 4990382

  g_rpa_awd_attr(p_request_id).authentication_dt := fnd_date.date_to_canonical(l_auth_date);
  l_get_ei_val:=NULL;

  l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_NFC_AWARD_INFO'
                          );


  g_rpa_awd_attr(p_request_id).awd_case_num            :=l_get_ei_val.rei_information3;
  g_rpa_awd_attr(p_request_id).awd_store_act_ind       :=l_get_ei_val.rei_information4;
  g_rpa_awd_attr(p_request_id).awd_csh_awd_typ_cd      :=l_get_ei_val.rei_information5;
  g_rpa_awd_attr(p_request_id).awd_fir_yr_sav          :=l_get_ei_val.rei_information6;
  g_rpa_awd_attr(p_request_id).awd_csh_awd_pay_cd      :=l_get_ei_val.rei_information7;
  g_rpa_awd_attr(p_request_id).awd_no_per_csh_awd      :=l_get_ei_val.rei_information8;
  g_rpa_awd_attr(p_request_id).awd_acctg_dist_fisyr_cd :=l_get_ei_val.rei_information9;
  g_rpa_awd_attr(p_request_id).awd_acctg_dist_appn_cd  :=l_get_ei_val.rei_information10;
  g_rpa_awd_attr(p_request_id).awd_acctg_dist_slev_cd  :=l_get_ei_val.rei_information11;
  g_rpa_awd_attr(p_request_id).awd_csh_awd_accst_chg   :=l_get_ei_val.rei_information12;
  g_rpa_awd_attr(p_request_id).awd_csh_awd_cd          :=l_get_ei_val.rei_information13;



END;

-- =============================================================================
-- Populate_attr
-- ============================================================================
PROCEDURE populate_attr (p_person_id              NUMBER
                       ,p_assignment_id           NUMBER
                       ,p_business_group_id       NUMBER
                       ,p_effective_date          DATE
                       ,p_first_noa_cd            VARCHAR2
                       ,p_sec_noa_cd              VARCHAR2
                       ,p_request_id              NUMBER
                       ,p_notification_id         NUMBER
                       )
IS
l_per_ei_data per_people_extra_info%rowtype;
l_pay_det   VARCHAR2(10);
l_pos_ag_code   VARCHAR2(30);
l_posi_extra_info per_position_extra_info%rowtype;
l_mrn  VARCHAR2(40);
l_start_date  DATE;
l_end_date  DATE;
l_temp   NUMBER;
l_proc_name  constant varchar2(150) := g_proc_name ||'populate_attr';
CURSOR c_get_pos_id IS
SELECT ppf.sex
 FROM  per_all_people_f ppf
WHERE  p_effective_date BETWEEN
      ppf.effective_start_date
  AND ppf.effective_end_date
  AND ppf.business_group_id=p_business_group_id
  AND ppf.person_id =p_person_id;
l_get_pos_id c_get_pos_id%ROWTYPE;

CURSOR c_get_asg_extra_info (cp_assignment_id VARCHAR2
                            ,cp_info_type   VARCHAR2
                            )
IS
SELECT *
  FROM per_assignment_extra_info paei
    WHERE paei.assignment_id= cp_assignment_id
      AND paei.information_type=cp_info_type;

CURSOR c_mast_pos (cp_position_id       NUMBER
                  ,cp_effective_date    DATE
                  ,cp_business_group_id NUMBER
                  )
IS
SELECT hap.information6 mrn
 FROM  hr_all_positions_f hap
WHERE  hap.position_id =cp_position_id
  AND  cp_effective_date BETWEEN hap.effective_start_date
                             AND hap.effective_end_date
  AND  hap.business_group_id =cp_business_group_id;


CURSOR c_get_default_values
               (cp_position_id       IN Number
               ,cp_effective_date    IN Date) IS
 SELECT pdf.segment3 NFC_Agency_Code,
        pdf.segment4 Personnel_Office_ID,
        pdf.segment7 Grade
   FROM hr_all_positions_f pos, per_position_definitions pdf
  WHERE pos.position_definition_id = pdf.position_definition_id
    AND pos.position_id = cp_position_id
    AND cp_effective_date between pos.effective_start_date and pos.effective_end_date;

/*
CURSOR c_get_auth_date(c_person_id  ghr_pa_requests.person_id%TYPE,
						c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT pa_request_id, (effective_date+rownum)-1 auth_date
FROM  ghr_pa_requests
WHERE person_id = c_person_id
AND   first_noa_code NOT IN ('001','002')
AND pa_notification_id IS NOT NULL
AND   effective_date = c_effective_date
ORDER BY last_update_date ASC;*/

CURSOR c_get_auth_date(c_person_id  ghr_pa_requests.person_id%TYPE,
						c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT pa_request_id, (effective_date+rownum)-1 auth_date, noa_code
FROM
(
	SELECT  pa_request_id, effective_date, last_update_date,first_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code NOT IN ('001','002')
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
UNION ALL
	SELECT  pa_request_id, effective_date, last_update_date,second_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code = '317'
	AND second_noa_code = '825'
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
ORDER BY last_update_date
) par;

CURSOR c_rpas_on_date(c_person_id  ghr_pa_requests.person_id%TYPE,
 					c_effective_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT COUNT(*) auth_date
FROM
(
	SELECT  pa_request_id, effective_date, last_update_date,first_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code NOT IN ('001','002')
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
UNION ALL
	SELECT  pa_request_id, effective_date, last_update_date,second_noa_code noa_code
	FROM ghr_pa_requests
	WHERE person_id = c_person_id
	AND first_noa_code = '317'
	AND second_noa_code = '825'
	AND pa_notification_id IS NOT NULL
	AND effective_date = c_effective_date
ORDER BY last_update_date
) par;

l_no_rpa_count BOOLEAN;
l_auth_date DATE;
l_get_default_values c_get_default_values%ROWTYPE;
l_get_asg_extra_info c_get_asg_extra_info%ROWTYPE;
l_mast_pos c_mast_pos%ROWTYPE;
l_position_id   hr_all_positions_f.position_id%TYPE;
l_out_val       pay_element_entry_values_f.screen_entry_value%type;
l_pos_num    VARCHAR2(20);
l_get_ei_val ghr_pa_request_extra_info%ROWTYPE;
l_temp_var    NUMBER;
BEGIN

 build_rules;
 l_per_ei_data:=NULL;
 l_no_rpa_count := FALSE;

 hr_utility.set_location ('Enter'||l_proc_name,05);
 g_rpa_attr(p_request_id).assignment_id := p_assignment_id;
 g_rpa_attr(p_request_id).request_id    := p_request_id;


 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_GROUP1'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );


  hr_utility.set_location (l_proc_name,10);
-- g_rpa_attr(p_request_id).Previous_agency_code  :=l_per_ei_data.pei_information7;

 IF  p_first_noa_cd LIKE '1%' OR p_first_noa_cd LIKE '2%' OR p_first_noa_cd LIKE '5%'
  OR p_first_noa_cd LIKE '7%' OR  p_first_noa_cd='866' OR p_sec_noa_cd LIKE '1%' OR
     p_sec_noa_cd LIKE '2%' OR p_sec_noa_cd LIKE '5%' OR p_sec_noa_cd LIKE '7%' OR
     p_sec_noa_cd = '866' THEN
  IF l_per_ei_data.pei_information6 IS NOT NULL THEN
   g_rpa_attr(p_request_id).Date_entered_present_grade :=l_per_ei_data.pei_information6;
  ELSE
   g_rpa_attr(p_request_id).Date_entered_present_grade := fnd_date.date_to_canonical
                                                      (g_rpa_rec(p_request_id).effective_date);
  END IF;

 ELSE
  g_rpa_attr(p_request_id).Date_entered_present_grade :=NULL;

 END IF;
 g_rpa_attr(p_request_id).phy_handicap_code :=l_per_ei_data.pei_information11;
 g_rpa_attr(p_request_id).race :=l_per_ei_data.pei_information5;

 BEGIN
 l_temp_var :=to_number(l_per_ei_data.pei_information3);
 g_rpa_attr(p_request_id).typ_apt_cd := g_apt_cd(l_temp_var);
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;


  hr_utility.set_location (l_proc_name,15);
--modify
 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_SEPARATE_RETIRE'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );


  hr_utility.set_location (l_proc_name||p_first_noa_cd,20);

 IF g_psr_month.exists(p_first_noa_cd) THEN
  g_rpa_attr(p_request_id).Date_last_pay_status_retired :=l_per_ei_data.pei_information21;
  hr_utility.set_location (l_proc_name,25);
 END IF;
 g_rpa_attr(p_request_id).Frozen_CSRS_service :=l_per_ei_data.pei_information5;
 g_rpa_attr(p_request_id).CSRS_coverage_at_appointment  :=l_per_ei_data.pei_information4;

  hr_utility.set_location (l_proc_name,30);
 l_per_ei_data:=NULL;

 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_LEAVE_INFO'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );


 IF g_sler_month.exists(p_first_noa_cd) THEN
  g_rpa_attr(p_request_id).Date_sick_leave_exp_ret :=l_per_ei_data.pei_information5;
  hr_utility.set_location (l_proc_name,35);
 END IF;

 g_rpa_attr(p_request_id).Annual_leave_category    :=NVL(l_per_ei_data.pei_information3,'0');
-- g_rpa_attr(p_request_id).Annual_leave_45_day_code :=l_per_ei_data.pei_information4;
 g_rpa_attr(p_request_id).Leave_ear_stat_py_period :=l_per_ei_data.pei_information6;

  hr_utility.set_location (l_proc_name,40);

 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_SCD_INFORMATION'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );

 g_rpa_attr(p_request_id).Date_SCD_CSR   :=l_per_ei_data.pei_information7;
 g_rpa_attr(p_request_id).Date_SCD_RIF   :=l_per_ei_data.pei_information5;
 g_rpa_attr(p_request_id).Date_TSP_vested :=l_per_ei_data.pei_information6;
 g_rpa_attr(p_request_id).Date_SCD_SES    :=l_per_ei_data.pei_information8;

  hr_utility.set_location (l_proc_name,45);

 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_PROBATIONS'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );
 g_rpa_attr(p_request_id).Date_Spvr_Mgr_Prob_Ends :=l_per_ei_data.pei_information5;
 g_rpa_attr(p_request_id).Date_Supv_Mgr_Prob      :=l_per_ei_data.pei_information8;
 g_rpa_attr(p_request_id).Date_Prob_period_start  :=l_per_ei_data.pei_information3;
 g_rpa_attr(p_request_id).Supv_mgr_prob_period_req :=l_per_ei_data.pei_information6;

  hr_utility.set_location (l_proc_name,50);

 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_CONVERSIONS'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );
 g_rpa_attr(p_request_id).Date_Career_perma_Ten_St :=l_per_ei_data.pei_information3;

 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_RETAINED_GRADE'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );
 l_pay_det :=g_rpa_rec(p_request_id).pay_rate_determinant;

 IF l_pay_det ='A' OR l_pay_det ='B'
  OR l_pay_det = 'E' OR l_pay_det ='F'
  OR l_pay_det='U' OR l_pay_det ='V' THEN
   g_rpa_attr(p_request_id).Date_Ret_Rght_end :=null ;
   g_rpa_attr(p_request_id).date_retain_rate_exp :=l_per_ei_data.pei_information2 ;
   g_rpa_attr(p_request_id).Saved_Grd_Pay_Plan        :=l_per_ei_data.pei_information5;
   g_rpa_attr(p_request_id).Saved_Grade               :=l_per_ei_data.pei_information3;
 null;
 END IF;

 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_SF52'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );
 g_rpa_attr(p_request_id).Citizenship_code    :=l_per_ei_data.pei_information3;


 l_per_ei_data:=NULL;
 ghr_history_fetch.fetch_peopleei(p_person_id         =>p_person_id
                                 ,p_information_type  =>'GHR_US_PER_UNIFORMED_SERVICES'
                                 ,p_date_effective    =>p_effective_date
                                 ,p_per_ei_data       =>l_per_ei_data
                                 );




 g_rpa_attr(p_request_id).Uniform_Svc_Status  :=l_per_ei_data.pei_information19;
 g_rpa_attr(p_request_id).Creditable_Military_Svc  :=l_per_ei_data.pei_information5;
 g_rpa_attr(p_request_id).Date_Ret_Military        :=l_per_ei_data.pei_information6;

 IF p_first_noa_cd ='002' THEN

  g_rpa_attr(p_request_id).Date_Corr_NoA      :=p_effective_date;

 END IF;

 IF g_NTE_SF50.exists(p_first_noa_cd)
 OR (p_first_noa_cd='002' AND  g_NTE_SF50.exists(p_sec_noa_cd))  THEN

  g_rpa_attr(p_request_id).Date_NTE_SF50     :=g_rpa_rec(p_request_id).first_noa_information1;
 END IF;


-- IF g_retention.exists(p_first_noa_cd) THEN -- Bug 4922145
  g_rpa_attr(p_request_id).Retention_Percent   := g_rpa_rec(p_request_id).to_retention_allow_percentage;
  g_rpa_attr(p_request_id).Retention_allowance    := g_rpa_rec(p_request_id).to_retention_allowance;
-- END IF;

 IF p_first_noa_cd=780 THEN
  g_rpa_attr(p_request_id).Name_Corr_code := 'Y';
 ELSE
  g_rpa_attr(p_request_id).Name_Corr_code := 'N';
 END IF;
--Need to add Old SSNO and Name changed attr

 --IF  g_recruitment.exists(p_first_noa_cd) THEN
  g_rpa_attr(p_request_id).Recruitment_Percent := g_rpa_rec(p_request_id).award_percentage;
  g_rpa_attr(p_request_id).Recruitment_bonus     := g_rpa_rec(p_request_id).award_amount;

-- END IF;

 --IF g_relocation.exists(p_first_noa_cd) THEN
  g_rpa_attr(p_request_id).Relocation_percent :=  g_rpa_rec(p_request_id).award_percentage;
  g_rpa_attr(p_request_id).Relocation_bonus   := g_rpa_rec(p_request_id).award_amount;
  null;
-- END IF;

-- IF g_Supervisory.exists(p_first_noa_cd) THEN
  g_rpa_attr(p_request_id).Supervisory_Percent   :=g_rpa_rec(p_request_id).to_supervisory_diff_percentage;
  g_rpa_attr(p_request_id).Supervisory_Differential_Rate :=g_rpa_rec(p_request_id).to_supervisory_differential;
-- END IF;

--Derive TSP eligilibilty code
IF ( p_first_noa_cd like '1%' OR
(p_sec_noa_cd='02' AND p_first_noa_cd like '1%') )
OR
( p_first_noa_cd like '5%' OR
(p_sec_noa_cd='02' AND p_first_noa_cd like '5%') )
OR
( p_first_noa_cd ='803' OR
(p_sec_noa_cd='02' AND p_first_noa_cd ='803') )
THEN
 IF (g_rpa_rec(p_request_id).retirement_plan='K'
 OR g_rpa_rec(p_request_id).retirement_plan='L'
 OR g_rpa_rec(p_request_id).retirement_plan='M'
 OR g_rpa_rec(p_request_id).retirement_plan='N'
 OR g_rpa_rec(p_request_id).retirement_plan='P'
 OR g_rpa_rec(p_request_id).retirement_plan='D')
 THEN
  g_rpa_attr(p_request_id).tsp_elig_cd := '2';
 ELSIF  (g_rpa_rec(p_request_id).retirement_plan='2'
 OR g_rpa_rec(p_request_id).retirement_plan='5'
 OR g_rpa_rec(p_request_id).retirement_plan='Y'
 OR g_rpa_rec(p_request_id).retirement_plan='Z'
 OR g_rpa_rec(p_request_id).retirement_plan='4'
 )
 THEN
  g_rpa_attr(p_request_id).tsp_elig_cd := '6';
 ELSE
  g_rpa_attr(p_request_id).tsp_elig_cd := '3';
 END IF;

ELSE
  g_rpa_attr(p_request_id).tsp_elig_cd :=NULL;
END IF;

 IF (TO_NUMBER(p_first_noa_cd) >= 100 AND TO_NUMBER(p_first_noa_cd) <=199)
  OR (p_first_noa_cd = '002' AND (TO_NUMBER(p_sec_noa_cd) >= 100 AND TO_NUMBER(p_sec_noa_cd) <=199 ))  THEN
   OPEN c_get_asg_extra_info (p_assignment_id
                            ,'GHR_US_ASG_NON_SF52'
                            );
   FETCH c_get_asg_extra_info INTO l_get_asg_extra_info;
   CLOSE c_get_asg_extra_info;
  g_rpa_attr(p_request_id).special_emp_code := NVL(l_get_asg_extra_info.aei_information12,'00');
  g_rpa_attr(p_request_id).action_code := 1;

  ghr_history_fetch.fetch_element_entry_value
        (p_element_name              =>'Health Benefits',
         p_input_value_name          =>'Enrollment',
         p_assignment_id             =>p_assignment_id,
         p_date_effective            =>p_effective_date,
         p_screen_entry_value        =>l_out_val
         ) ;
   IF l_out_val IS NULL THEN
    ghr_history_fetch.fetch_element_entry_value
        (p_element_name              =>'Health Benefits Pre tax',
         p_input_value_name          =>'Enrollment',
         p_assignment_id             =>p_assignment_id,
         p_date_effective            =>p_effective_date,
         p_screen_entry_value        =>l_out_val
         ) ;
   END IF;

   IF l_out_val='Z' THEN
    l_out_val:='2' ;
   ELSIF l_out_val='Y' THEN
    l_out_val:='3' ;
   ELSE
    l_out_val:='4' ;
   END IF;

   g_rpa_attr(p_request_id).fehb_cov_cd := l_out_val;
    l_out_val:=NULL;
 ELSIF TO_NUMBER(p_first_noa_cd) >=300 AND TO_NUMBER(p_first_noa_cd) <= 399
  OR (p_first_noa_cd = '002' AND (TO_NUMBER(p_sec_noa_cd) >= 300 AND TO_NUMBER(p_sec_noa_cd) <=399 ))  THEN
  g_rpa_attr(p_request_id).action_code :=3;
 ELSIF TO_NUMBER(p_first_noa_cd) >= 500 AND TO_NUMBER(p_first_noa_cd) <=599 THEN

  g_rpa_attr(p_request_id).action_code:= ghr_utility.get_nfc_conv_action_code (p_request_id);
 ELSIF
   p_first_noa_cd = '002' AND (TO_NUMBER(p_sec_noa_cd) >= 500 AND TO_NUMBER(p_sec_noa_cd) <=599 ) THEN
   g_rpa_attr(p_request_id).action_code:=ghr_utility.get_nfc_conv_action_code (p_sec_noa_cd);

 ELSE
  g_rpa_attr(p_request_id).action_code :=2;

 END IF;

IF g_rpa_rec(p_request_id).to_position_id IS NULL THEN
    hr_utility.set_location ('Inside null',05);
   g_rpa_rec(p_request_id).to_position_id := g_rpa_rec(p_request_id).from_position_id;
END IF;

 l_pos_ag_code :=ghr_api.get_position_agency_code_pos
                           (p_position_id        =>g_rpa_rec(p_request_id).to_position_id
                           ,p_business_group_id  =>p_business_group_id
                           ,p_effective_date     =>p_effective_date) ;

 g_rpa_attr(p_request_id).pmso_dept := SUBSTR(l_pos_ag_code,0,2);


 --get MRN using the positionid and get from master pos.

 OPEN c_mast_pos (g_rpa_rec(p_request_id).to_position_id
              ,p_effective_date
              ,p_business_group_id
              );
 FETCH c_mast_pos INTO l_mast_pos;
 CLOSE c_mast_pos;
 l_position_id := TO_NUMBER(l_mast_pos.mrn);

 l_mrn        :=ghr_api.get_position_desc_no_pos
                 (p_position_id           =>l_position_id
                 ,p_business_group_id     =>p_business_group_id
                 ,p_effective_date        =>p_effective_date
                 ) ;


 g_rpa_attr(p_request_id).mrn := l_mrn;
 l_pos_num:=ghr_api.get_position_desc_no_pos
	(p_position_id           =>g_rpa_rec(p_request_id).to_position_id
	,p_business_group_id     =>p_business_group_id
	,p_effective_date        =>p_effective_date
  );

 g_rpa_attr(p_request_id).pos_num := l_pos_num;

 /*ghr_history_fetch.fetch_positionei
                           ( p_position_id      => l_position_id
                            ,p_information_type =>'GHR_US_POS_GRP3'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);*/


 hr_utility.set_location ('p_effective_date'||p_effective_date,05);

 OPEN c_get_default_values (l_position_id
                            ,p_effective_date);
 FETCH c_get_default_values INTO l_get_default_values;
 CLOSE c_get_default_values;

  hr_utility.set_location ('l_get_default_values.nfc_agency_code'||l_get_default_values.nfc_agency_code,05);
  hr_utility.set_location ('p_request_id'||p_request_id,05);


 g_rpa_attr(p_request_id).nfc_agency :=  l_get_default_values.nfc_agency_code;

 l_posi_extra_info:=NULL;
 /*ghr_history_fetch.fetch_positionei
                           ( p_position_id      => l_position_id
                            ,p_information_type =>'GHR_US_POS_GRP1'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);*/
  g_rpa_attr(p_request_id).poi := l_get_default_values.personnel_office_id;
  l_posi_extra_info:=NULL;
  l_get_default_values:=NULL;
 /*ghr_history_fetch.fetch_positionei
                           ( p_position_id      => g_rpa_rec(p_request_id).to_position_id
                            ,p_information_type =>'GHR_US_POS_GRP3'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);*/


 OPEN c_get_default_values (g_rpa_rec(p_request_id).to_position_id
                            ,p_effective_date);
 FETCH c_get_default_values INTO l_get_default_values;
 CLOSE c_get_default_values;
 g_rpa_attr(p_request_id).pmso_agency := l_get_default_values.nfc_agency_code;

 /*ghr_history_fetch.fetch_positionei
                           ( p_position_id      =>g_rpa_rec(p_request_id).to_position_id
                            ,p_information_type =>'GHR_US_POS_GRP1'
                            ,p_date_effective   => p_effective_date
                            ,p_pos_ei_data      => l_posi_extra_info);*/
  --g_rpa_attr(p_request_id).pmso_poi := l_posi_extra_info.poei_information1;
  g_rpa_attr(p_request_id).pmso_poi :=  l_get_default_values.personnel_office_id;
  l_posi_extra_info:=NULL;
  l_get_default_values:=NULL;
--get gender code
 OPEN c_get_pos_id;
 FETCH c_get_pos_id INTO l_get_pos_id;
 CLOSE c_get_pos_id;


 g_rpa_attr(p_request_id).gender_code := l_get_pos_id.sex;

--get payperiod num

   g_rpa_attr(p_request_id).pay_period_num :=
                         get_pay_period_number
                        (p_person_id           => p_person_id
                        ,p_assignment_id       =>p_assignment_id
                        ,p_business_group_id   =>p_business_group_id
                        ,p_effective_date      =>p_effective_date
                        ,p_position_id         => l_temp
                        ,p_start_date          =>l_start_date
                        ,p_end_date            =>l_end_date
                        );



   ghr_history_fetch.fetch_element_entry_value
	(p_element_name              =>'Retirement Annuity',
	 p_input_value_name          =>'Sum',
	 p_assignment_id             =>p_assignment_id,
	 p_date_effective            =>p_effective_date,
	 p_screen_entry_value        =>l_out_val
	 ) ;

   g_rpa_attr(p_request_id).civil_service_annuitant_share := TO_NUMBER(l_out_val);
   l_out_val :=NULL;
   ghr_history_fetch.fetch_element_entry_value
	(p_element_name              =>'Within Grade Increase',
	 p_input_value_name          =>'Last Equivalent Increase',
	 p_assignment_id             =>p_assignment_id,
	 p_date_effective            =>p_effective_date,
	 p_screen_entry_value        =>l_out_val
	 ) ;

   g_rpa_attr(p_request_id).dt_scd_wgi := l_out_val;
    l_out_val :=NULL;

--derive Authentication Date
	FOR l_no_rpas IN c_rpas_on_date(p_person_id,p_effective_date) LOOP
		l_no_rpa_count := TRUE;
	END LOOP;

	IF l_no_rpa_count = TRUE THEN
		FOR l_get_auth_date IN c_get_auth_date(p_person_id,p_effective_date) LOOP
			IF p_request_id = l_get_auth_date.pa_request_id
				AND p_first_noa_cd = l_get_auth_date.noa_code THEN
					l_auth_date := l_get_auth_date.auth_date;
			END IF;
		END LOOP;
	END IF;

	IF l_no_rpa_count = FALSE THEN
		l_auth_date := p_effective_date;
	END IF;

	l_no_rpa_count := FALSE;

   g_rpa_attr(p_request_id).authentication_dt := fnd_date.date_to_canonical(l_auth_date);

  /*l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_NFC_INFO'
                          ); */
--  g_rpa_attr(p_request_id).authentication_dt :=l_get_ei_val.rei_information3;
--derive previous nature of action code
  IF p_first_noa_cd='001' THEN
   g_rpa_attr(p_request_id).nat_act_prev :=
   ghr_utility.get_nfc_prev_noa(
    p_person_id          => p_person_id
   ,p_pa_notification_id => p_notification_id
   ,p_effective_date     => p_effective_date);
  END IF;

  IF p_first_noa_cd='001' OR  p_first_noa_cd='002' THEN
    ghr_utility.get_nfc_auth_codes(
     p_person_id          =>p_person_id,
     p_pa_notification_id => p_notification_id ,
     p_effective_date     =>p_effective_date,
     p_first_auth_code    => g_rpa_attr(p_request_id).csc_auth_prev_noa,
     p_second_auth_code   => g_rpa_attr(p_request_id).csc_auth_prev_2noa);

  END IF;
  IF  g_rpa_rec (p_request_id).veterans_status='X'
   AND g_rpa_rec (p_request_id).veterans_preference='1'
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='Y'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif :='5';

  ELSIF g_rpa_rec (p_request_id).veterans_status='X'
   AND g_rpa_rec (p_request_id).veterans_preference='1'
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='N'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '3' ;

  ELSIF g_rpa_rec (p_request_id).veterans_status <> 'X'
   AND (g_rpa_rec (p_request_id).veterans_preference = '2' OR
        g_rpa_rec (p_request_id).veterans_preference = '3' OR
        g_rpa_rec (p_request_id).veterans_preference = '4' OR
        g_rpa_rec (p_request_id).veterans_preference = '5' )
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='Y'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '2' ;
  ELSIF g_rpa_rec (p_request_id).veterans_status <> 'X'
   AND (g_rpa_rec (p_request_id).veterans_preference = '2' OR
        g_rpa_rec (p_request_id).veterans_preference = '3' OR
        g_rpa_rec (p_request_id).veterans_preference = '4' OR
        g_rpa_rec (p_request_id).veterans_preference = '5' OR
        g_rpa_rec (p_request_id).veterans_preference = '6' )
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='N'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '2' ;

  ELSIF g_rpa_rec (p_request_id).veterans_status <>'X'
   AND g_rpa_rec (p_request_id).veterans_preference='1'
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='N'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '3' ;

  ELSIF g_rpa_rec (p_request_id).veterans_status <>'X'
   AND g_rpa_rec (p_request_id).veterans_preference='1'
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='Y'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '2' ;

  ELSIF g_rpa_rec (p_request_id).veterans_status <>'X'
   AND g_rpa_rec (p_request_id).veterans_preference='6'
   AND g_rpa_rec (p_request_id).veterans_pref_for_rif ='Y'  THEN

   g_rpa_attr(p_request_id).veterans_pref_for_rif := '1' ;
  END IF;

  hr_utility.set_location ('Populate Attr Position Class Code ',54);
  IF (TO_NUMBER(p_first_noa_cd) >=300 AND TO_NUMBER(p_first_noa_cd) <= 399)
  OR  (TO_NUMBER(p_sec_noa_cd) >=300 AND TO_NUMBER(p_sec_noa_cd) <= 399)
  --OR (TO_NUMBER(p_first_noa_cd)=507 OR TO_NUMBER(p_sec_noa_cd) =507)
  OR (TO_NUMBER(p_first_noa_cd)=713 OR TO_NUMBER(p_sec_noa_cd) =713)
  OR (TO_NUMBER(p_first_noa_cd)=740 OR TO_NUMBER(p_sec_noa_cd)=740)
  OR (TO_NUMBER(p_first_noa_cd)=741 OR TO_NUMBER(p_sec_noa_cd)=741)
  OR
  ( g_rpa_rec(p_request_id).from_position_id IS NOT NULL AND
    g_rpa_rec(p_request_id).from_position_id <>
    NVL(g_rpa_rec(p_request_id).to_position_id,hr_api.g_number) -- Bug 5026388
   )
  THEN
   g_rpa_attr(p_request_id).position_class_cd:='0';
  ELSE
    g_rpa_attr(p_request_id).position_class_cd:=NULL;
  END IF;

   l_get_default_values:=NULL;
   IF (p_first_noa_cd LIKE '5%' OR p_sec_noa_cd LIKE '5%' )
   AND g_rpa_rec(p_request_id).from_position_id <> g_rpa_rec(p_request_id).to_position_id
   AND g_rpa_rec(p_request_id).from_position_id IS NOT NULL AND
       g_rpa_rec(p_request_id).to_position_id IS NOT NULL  THEN
    OPEN c_get_default_values (g_rpa_rec(p_request_id).from_position_id
                             ,p_effective_date);
    FETCH c_get_default_values INTO l_get_default_values;
    CLOSE c_get_default_values;

    g_rpa_attr(p_request_id).Previous_agency_code:=l_get_default_values.nfc_agency_code;
   END IF;



---Gain or Lose attribute
--Annual leave 45 day code
   l_get_ei_val:=NULL;
   IF  (p_first_noa_cd LIKE '1%' AND p_first_noa_cd <> '130'
     AND p_first_noa_cd <> '132' )  OR
    ( p_sec_noa_cd LIKE '1%' AND p_sec_noa_cd <> '130'
      AND p_sec_noa_cd <> '132' )
   THEN

    l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_APPT_INFO'
                          );

    g_rpa_attr(p_request_id).gain_lose_dept_non_usda:=NVL(l_get_ei_val.rei_information21,'1B');
    g_rpa_attr(p_request_id).Annual_leave_45_day_code :=NVL(l_get_ei_val.rei_information20,'N');
   ELSIF p_first_noa_cd LIKE '3%'  OR p_sec_noa_cd LIKE '3%'  THEN
 ---this clause is used for Agency use and gain lose dept.

    l_get_ei_val:=NULL;
    l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_NFC_SEPARATION_INFO'
                          );

    g_rpa_attr(p_request_id).gain_lose_dept_non_usda:=NVL(l_get_ei_val.rei_information12,'1B');

    g_rpa_attr(p_request_id).agency_use:=NVL(l_get_ei_val.rei_information3,' ')
                                          ||NVL(l_get_ei_val.rei_information4,' ')
                                          ||NVL(l_get_ei_val.rei_information5,' ')
                                          ||NVL(l_get_ei_val.rei_information6,' ')
                                          ||NVL(l_get_ei_val.rei_information7,' ')
                                          ||NVL(l_get_ei_val.rei_information8,' ')
                                          ||NVL(l_get_ei_val.rei_information9,' ')
                                          ||NVL(l_get_ei_val.rei_information10,' ')
                                          ||NVL(l_get_ei_val.rei_information11,' ');
   ELSIF (p_first_noa_cd = '130' OR p_first_noa_cd = '132')
     OR ( p_sec_noa_cd = '130' OR p_sec_noa_cd = '132') THEN
--Annual leave 45 day code
      l_get_ei_val:=NULL;
      l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_APPT_TRANSFER'
                          );
    g_rpa_attr(p_request_id).gain_lose_dept_non_usda:=NVL(l_get_ei_val.rei_information23,'1B');
    g_rpa_attr(p_request_id).Annual_leave_45_day_code :=NVL(l_get_ei_val.rei_information22,'N');
   END IF;

--Annual leave 45 day code
   IF p_first_noa_cd LIKE '5%' OR p_sec_noa_cd LIKE '5%' THEN
    l_get_ei_val:=NULL;
    l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_CONV_APP'
                          );
    g_rpa_attr(p_request_id).Annual_leave_45_day_code :=NVL(l_get_ei_val.rei_information22,'N');
   END IF;

--Special employee program code

  IF  p_first_noa_cd = '100' OR p_sec_noa_cd = '100' THEN
   g_rpa_attr(p_request_id).special_emp_prg_code := l_get_asg_extra_info.aei_information13;
   IF g_rpa_attr(p_request_id).special_emp_prg_code IS NULL THEN
    l_get_ei_val:=NULL;
    l_get_ei_val:=get_rpa_extra_info_val (p_request_id
                         ,'GHR_US_PAR_APPT_INFO'
                          );
    g_rpa_attr(p_request_id).special_emp_prg_code := l_get_ei_val.rei_information22;
   END IF;

  END IF;
  hr_utility.set_location ('Leaving Populate Attr',55);
END populate_attr;
-- =============================================================================
-- Build_rules:
-- =============================================================================
PROCEDURE build_rules
IS
a  number;
BEGIN

--for attribute Date Last Pay Status Retired Month
 g_psr_month(300) :=300;
 g_psr_month(301) :=301;
 g_psr_month(302) :=302;
 g_psr_month(303) :=303;
 g_psr_month(304) :=304;
 g_psr_month(350) :=350;

---for attribute Date Sick Leave Expired Retired Month
 g_sler_month(300) := 300;
 g_sler_month(301) := 301;
 g_sler_month(302) := 302;
 g_sler_month(303) := 303;
 g_sler_month(304) := 304;
 g_sler_month(350) := 350;

---attribute  Date NTE SF50 Month

 g_NTE_SF50(108) :=108;
 g_NTE_SF50(115) :=115;
 g_NTE_SF50(117) :=117;
 g_NTE_SF50(122) :=122;
 g_NTE_SF50(148) :=148;
 g_NTE_SF50(149) :=149;
 g_NTE_SF50(153) :=153;
 g_NTE_SF50(154) :=154;
 g_NTE_SF50(171) :=171;
 g_NTE_SF50(190) :=190;
 g_NTE_SF50(198) :=198;
 g_NTE_SF50(199) :=199;
 g_NTE_SF50(450) :=450;
 g_NTE_SF50(460) :=460;
 g_NTE_SF50(462) :=462;
 g_NTE_SF50(472) :=472;
 g_NTE_SF50(480) :=480;
 g_NTE_SF50(508) :=508;
 g_NTE_SF50(515) :=515;
 g_NTE_SF50(517) :=517;
 g_NTE_SF50(522) :=522;
 g_NTE_SF50(548) :=548;
 g_NTE_SF50(553) :=553;
 g_NTE_SF50(554) :=554;
 g_NTE_SF50(571) :=571;
 g_NTE_SF50(590) :=590;
 g_NTE_SF50(703) :=703;
 g_NTE_SF50(741) :=741;
 g_NTE_SF50(750) :=750;
 g_NTE_SF50(760) :=760;
 g_NTE_SF50(761) :=761;
 g_NTE_SF50(762) :=762;
 g_NTE_SF50(765) :=765;
 g_NTE_SF50(769) :=769;
 g_NTE_SF50(770) :=770;
 g_NTE_SF50(772) :=772;
 g_NTE_SF50(773) :=773;

--attr for retention
 g_retention(810):=810;
--for attr recruitment
 g_recruitment(815) :=815;


--for attr  g_relocation
 g_relocation(816) :=816;


--for attr g_Supervisory
  g_Supervisory(810) :=810;
--g_apt_cd
g_apt_cd(10) := '01';
g_apt_cd(15) := '02';
g_apt_cd(20) := '03';
g_apt_cd(30) := '06';
g_apt_cd(32) := '06';
g_apt_cd(34) := '06';
g_apt_cd(36) := '06';
g_apt_cd(38) := '06';
g_apt_cd(40) := '09';
g_apt_cd(42) := '09';
g_apt_cd(44) := '09';
g_apt_cd(46) := '09';
g_apt_cd(48) := '09';
g_apt_cd(50) := '01';
g_apt_cd(55) := '06';
g_apt_cd(60) := '09';
g_apt_cd(65) := '08';

END;


-- =============================================================================
-- ~ Get_Rcds_Details:
-- =============================================================================
procedure Get_Rcds_Details is

   -- Cursor to get the seq num of the
   cursor csr_seq (c_ext_rcd_id in number) is
   select eir.seq_num
         ,elm.string_val
     from ben_ext_data_elmt          elm,
          ben_ext_data_elmt_in_rcd   eir
    where elm.ext_data_elmt_id = eir.ext_data_elmt_id
      and elm.data_elmt_typ_cd = 'R'
      and elm.string_val  in ('RPA_REQ_ID',   'RPA_AWARD_ID',
                              'RPA_REMARK_ID','RPA_ADD_ID')
      and  eir.ext_rcd_id = c_ext_rcd_id;

  l_proc     constant varchar2(150) := g_proc_name||'Get_Rcds_Details';
  l_col_value         varchar2(600);
begin
  Hr_Utility.set_location('Entering'||l_proc, 5);
  for rcd_rec in csr_ext_rcd
                (c_hide_flag   => 'N'
                ,c_rcd_type_cd => 'D')
  loop
    for eir in  csr_seq(rcd_rec.ext_rcd_id)
    loop
       if eir.seq_num < 10 then
          l_col_value := 'val_0'|| eir.seq_num;
       else
          l_col_value := 'val_'|| eir.seq_num;
       end if;
       g_ext_rcd(rcd_rec.ext_rcd_id).data_value := eir.string_val;
       g_ext_rcd(rcd_rec.ext_rcd_id).seq_num    := eir.seq_num;
       g_ext_rcd(rcd_rec.ext_rcd_id).col_name   := l_col_value;
       Hr_Utility.set_location(' ext_rcd_id: '||rcd_rec.ext_rcd_id, 5);
       Hr_Utility.set_location(' data_value: '||eir.string_val, 5);
       Hr_Utility.set_location(' seq_num   : '||eir.seq_num, 5);
       Hr_Utility.set_location(' col_name  : '||l_col_value, 5);
    end loop;
  end loop;
  Hr_Utility.set_location('Leaving'||l_proc, 80);

end Get_Rcds_Details;
-- =============================================================================
-- ~ Write_Warning:
-- =============================================================================
procedure Write_Warning
           (p_err_name  in varchar2,
            p_err_no    in number   default null,
            p_element   in varchar2 default null ) is

  l_proc     constant varchar2(150) := g_proc_name||'Write_Warning';
  l_err_name          varchar2(2000);
  l_err_no            number;

begin
  Hr_Utility.set_location('Entering'||l_proc, 5);
  l_err_name  := p_err_name ;
  l_err_no    := p_err_no ;
  --
  if p_err_no is null then
      -- Assumed the name is Error Name
     l_err_no   :=  To_Number(Substr(p_err_name,5,5)) ;
     l_err_name :=  null ;
  end if ;
  -- If element name is sent get the message to write
  if p_err_no is not null and p_element is not null then
     l_err_name :=  Ben_Ext_Fmt.get_error_msg(p_err_no,
                                              p_err_name,
                                              p_element ) ;
  end if ;
  --
  if g_business_group_id is not null then
     Ben_Ext_Util.write_err
      (p_err_num           => l_err_no,
       p_err_name          => l_err_name,
       p_typ_cd            => 'W',
       p_person_id         => g_person_id,
       p_business_group_id => g_business_group_id,
       p_ext_rslt_id       => Ben_Extract.g_ext_rslt_id);
  end if;
  --
  Hr_Utility.set_location('Exiting'||l_proc, 15);
  --

end Write_Warning;

-- =============================================================================
-- ~ Write_Error:
-- =============================================================================
procedure Write_Error
           (p_err_name  in varchar2,
            p_err_no    in number   default null,
            p_element   in varchar2 default null ) is
  --
  l_proc     constant varchar2(72)    := g_proc_name||'Write_Error';
  l_err_name          varchar2(2000);
  l_err_no            number;
  l_err_num           number(15);
  --
  cursor err_cnt_c is
  select count(*) from ben_ext_rslt_err
   where ext_rslt_id = ben_extract.g_ext_rslt_id
     and typ_cd <> 'W';
  --
begin
  --
  Hr_Utility.set_location('Entering'||l_proc, 5);
  l_err_name := p_err_name ;
  l_err_no   := p_err_no ;
  if p_err_no is null then
      -- Assumed the name is Error Name
     l_err_no   :=  To_Number(Substr(p_err_name,5,5)) ;
     l_err_name :=  null ;
  end if ;
  -- If element name is sent get the message to write
  if p_err_no is not null and p_element is not null then
     l_err_name :=  Ben_Ext_Fmt.get_error_msg(p_err_no,
                                              p_err_name,
                                              p_element );
  end if ;
  open  err_cnt_c;
  fetch err_cnt_c into l_err_num;
  close err_cnt_c;
  if l_err_num >= ben_ext_thread.g_max_errors_allowed then
    ben_ext_thread.g_err_num := 91947;
    ben_ext_thread.g_err_name := 'BEN_91947_EXT_MX_ERR_NUM';
    raise ben_ext_thread.g_job_failure_error;
  end if;

  if g_business_group_id is not null then
     Ben_Ext_Util.write_err
      (p_err_num           => l_err_no,
       p_err_name          => l_err_name,
       p_typ_cd            => 'E',
       p_person_id         => g_person_id,
       p_business_group_id => g_business_group_id,
       p_ext_rslt_id       => Ben_Extract.g_ext_rslt_id);
  end if;
  Hr_Utility.set_location('Exiting'||l_proc, 15);
end Write_Error;

-- =============================================================================
-- ~ Extract_Exception:
-- =============================================================================
function Extract_Exception
        (p_assignment_id     in number
        ,p_business_group_id in number
        ,p_effective_date    in date
        ,p_msg_type          in out nocopy varchar2
        ,p_msg_code          in out nocopy varchar2
        ,p_msg_text          in out nocopy varchar2
         )
         return varchar2 is

  l_proc     constant varchar2(72) := g_proc_name||'Write_Warning';
  l_ext_rslt_id   number;
  l_person_id     number;
  l_error_text    varchar2(2000);
  l_return_value  varchar2(50);

begin
  l_ext_rslt_id:= ben_extract.g_ext_rslt_id;
  l_return_value := '0';
  if g_debug then
    Hr_Utility.set_location('Entering : '||l_proc, 5);
    Hr_Utility.set_location(' l_ext_rslt_id : '||l_ext_rslt_id, 5);
    Hr_Utility.set_location(' p_msg_type : '   ||p_msg_type, 5);
    Hr_Utility.set_location(' p_msg_code : '   ||p_msg_code, 5);
  end if;

  if p_assignment_id <> -1 and
     l_ext_rslt_id   <> -1 then
     if p_msg_type = 'E' then
        Write_Error
        (p_err_name  => p_msg_text
        ,p_err_no    => p_msg_code
        ,p_element   => Nvl(Ben_Ext_Person.g_elmt_name
                           ,Ben_Ext_Fmt.g_elmt_name)
         );
     elsif p_msg_type = 'W' then
           Write_Warning
          (p_err_name  => p_msg_text
          ,p_err_no    => p_msg_code
          ,p_element   => Nvl(Ben_Ext_Person.g_elmt_name
                             ,Ben_Ext_Fmt.g_elmt_name)
          );
     end if;
  end if;
  Hr_Utility.set_location('Leaving: '||l_proc, 80);
  return l_return_value;

end Extract_Exception;
-- =============================================================================
-- Exclude_Person:
-- =============================================================================
procedure Exclude_Person
          (p_person_id         in number
          ,p_business_group_id in number
          ,p_benefit_action_id in number
          ,p_flag_thread       in varchar2) is


   cursor csr_ben_per (c_person_id in number
                      ,c_benefit_action_id in number) is
   select *
    from ben_person_actions bpa
   where bpa.benefit_action_id = c_benefit_action_id
     and bpa.person_id = c_person_id;

   l_ben_per csr_ben_per%rowtype;

   cursor csr_rng (c_benefit_action_id in number
                  ,c_person_action_id  in number) is
   select 'x'
     from ben_batch_ranges
    where benefit_action_id = c_benefit_action_id
      and c_person_action_id between starting_person_action_id
                                 and ending_person_action_id;
  l_conc_reqest_id      number(20);
  l_exists              varchar2(2);
  l_proc_name  constant varchar2(150) := g_proc_name ||'Exclude_Person';
begin

  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  open  csr_ben_per (c_person_id         => p_person_id
                    ,c_benefit_action_id => p_benefit_action_id);
  fetch csr_ben_per into  l_ben_per;
  close csr_ben_per;

  update ben_person_actions bpa
     set bpa.action_status_cd = 'U'
   where bpa.benefit_action_id = p_benefit_action_id
     and bpa.person_id = p_person_id;

  if p_flag_thread = 'Y' then

    open csr_rng (c_benefit_action_id => p_benefit_action_id
                 ,c_person_action_id  => l_ben_per.person_action_id);
    fetch csr_rng into l_exists;
    close csr_rng;

    update ben_batch_ranges bbr
       set bbr.range_status_cd = 'E'
     where bbr.benefit_action_id = p_benefit_action_id
        and l_ben_per.person_action_id
                 between bbr.starting_person_action_id
                     and bbr.ending_person_action_id;
  end if;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

end Exclude_Person;

-- =============================================================================
-- ~ Extract_Post_Process:
-- =============================================================================
function Extract_Post_Process
          (p_business_group_id  in number
           )return varchar2 is

  cursor csr_err (c_bg_id in number
                 ,c_ext_rslt_id in number) is
  select err.person_id
        ,err.typ_cd
        ,err.ext_rslt_id
    from ben_ext_rslt_err err
   where err.business_group_id = c_bg_id
     and err.typ_cd = 'E'
     and err.ext_rslt_id = c_ext_rslt_id;

--Added by Gattu
 CURSOR csr_get_record_count(c_ext_rcd_id IN NUMBER) IS
   SELECT Count(dtl.ext_rslt_dtl_id)
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id NOT IN(c_ext_rcd_id);

  l_record_count Number   := 0;
  l_rc           VARCHAr2(8);
  l_ben_params             csr_ben%rowtype;
  l_conc_reqest_id    ben_ext_rslt.request_id%TYPE;
  l_proc_name    constant  varchar2(150):=  g_proc_name||'Extract_Post_Process';
  l_return_value           varchar2(2000);

begin
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
  l_return_value := '0';
  -- Get the record id for the Hidden Detail record
  Hr_Utility.set_location('..Get the hidden record for extract running..',10);
  for csr_rcd_rec in csr_ext_rcd
                      (c_hide_flag   => 'Y' -- Y=Record is hidden one
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
  -- Loop through each detail record for the extract
  loop
    -- Delete all hidden detail records for the all persons
    delete
      from ben_ext_rslt_dtl
     where ext_rcd_id        = csr_rcd_rec.ext_rcd_id
       and ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
       and business_group_id = p_business_group_id;
  end loop;
  -- Get the benefit action id for the extract
  open csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
               ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
               ,c_business_group_id => p_business_group_id);
  fetch csr_ben into l_ben_params;
  close csr_ben;
  -- Flag the person in ben_person_actions and ben_batch_ranges
  -- as Unporcessed and errored.
  for err_rec in csr_err(c_bg_id       => p_business_group_id
                        ,c_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id)
  loop
    Exclude_Person
    (p_person_id         => err_rec.person_id
    ,p_business_group_id => p_business_group_id
    ,p_benefit_action_id => l_ben_params.benefit_action_id
    ,p_flag_thread       => 'Y');

    delete
      from ben_ext_rslt_dtl dtl
     where dtl.ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
       and dtl.person_id         = err_rec.person_id
       and dtl.business_group_id = p_business_group_id;
  end loop;




  OPEN  csr_org_req(c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
                   ,c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
                   ,c_business_group_id => p_business_group_id);
  FETCH csr_org_req INTO l_conc_reqest_id;
  CLOSE csr_org_req;



  ghr_nfc_error_proc.chk_same_day_act(p_request_id =>l_conc_reqest_id
                                     ,p_rslt_id    =>Ben_Ext_Thread.g_ext_rslt_id);


  --Error handling call
  ghr_nfc_error_proc.chk_for_err_data_pa (p_request_id =>l_conc_reqest_id
                                          ,p_rslt_id    =>Ben_Ext_Thread.g_ext_rslt_id);

  --Handling Total Record Count,removing the header count from total
  FOR csr_header_rcd_id IN csr_ext_rcd_id(c_hide_flag => 'N' -- Y=Record is hidden one
                                         ,c_rcd_type_cd   => 'H') --Header
  LOOP
       OPEN csr_get_record_count(c_ext_rcd_id =>csr_header_rcd_id.ext_rcd_id);
       FETCH csr_get_record_count INTO l_record_count;
       CLOSE csr_get_record_count;

       Hr_Utility.set_location('Header Record ID ' ||csr_header_rcd_id.ext_rcd_id, 5);
       l_rc :=l_record_count;
       UPDATE ben_ext_rslt_dtl set val_06 = LPAD(l_rc,8,'0')
        WHERE ext_rcd_id       = csr_header_rcd_id.ext_rcd_id
          AND ext_rslt_id      = Ben_Ext_Thread.g_ext_rslt_id
          AND business_group_id= p_business_group_id;

  END LOOP;

  -- Notifications call
  GHR_WF.initiate_notification (p_request_id =>l_conc_reqest_id
                               ,p_result_id  =>Ben_Ext_Thread.g_ext_rslt_id
                               ,p_role       =>g_extract_params(p_business_group_id).notify);

  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);

  return l_return_value;

exception
  when Others then
   Hr_Utility.set_location('..Exception when others raised..', 20);
   Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
   l_return_value := '1';
   return l_return_value;

end Extract_Post_Process;

-- =============================================================================
-- ~ NFC_Extract_Process:
-- =============================================================================
PROCEDURE NFC_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_business_group_id           IN     NUMBER
           ,p_benefit_action_id           IN     NUMBER
           ,p_ext_dfn_id                  IN     NUMBER
	   ,p_ext_jcl_id                  IN     NUMBER
           ,p_ext_dfn_typ_id              IN     VARCHAR2
           ,p_ext_dfn_data_typ            IN     VARCHAR2
           ,p_transmission_type           IN     VARCHAR2
           ,p_date_criteria               IN     VARCHAR2
	   ,p_dummy1			  IN     VARCHAR2
	   ,p_dummy2			  IN     VARCHAR2
	   ,p_dummy3			  IN     VARCHAR2
           ,p_from_date                   IN     VARCHAR2
           ,p_to_date                     IN     VARCHAR2
           ,p_agency_code                 IN     VARCHAR2
           ,p_personnel_office_id         IN     VARCHAR2
           ,p_transmission_indicator      IN     VARCHAR2
           ,p_signon_identification       IN     VARCHAR2
           ,p_user_id                     IN     VARCHAR2
	   ,p_dept_code                   IN     VARCHAR2
	   ,p_payroll_id                  IN     NUMBER
	   ,p_notify     		  IN     VARCHAR2
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) IS

   l_errbuff          VARCHAR2(3000);
   l_retcode          NUMBER;
   l_session_id       NUMBER;
   l_proc_name        VARCHAR2(150) := g_proc_name ||'Pension_Extract_Process';

BEGIN
     hr_utility.set_location('Entering: '||l_proc_name, 5);

         ben_ext_thread.process
         (errbuf                     => l_errbuff,
          retcode                    => l_retcode,
          p_benefit_action_id        => NULL,
          p_ext_dfn_id               => p_ext_dfn_id,
          p_effective_date           => p_to_date,
          p_business_group_id        => p_business_group_id);

     hr_utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
     WHEN Others THEN
     hr_utility.set_location('Leaving: '||l_proc_name, 90);
     RAISE;
END NFC_Extract_Process;
-- =============================================================================
-- ~ Get_Remarks_Id:
-- =============================================================================
function Get_Remarks_Id
         (p_assignment_id in number
         ,p_input_value   in varchar2
         ,p_error_code    in out nocopy varchar2
         ,p_error_message in out nocopy varchar2
         ) return varchar2 is
  l_return_value          varchar2(2000);
  l_pa_req_id             number(15);
  l_proc_name    constant varchar2(250) := g_proc_name ||'Get_Remarks_Id';
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_return_value := null;

   IF g_pa_req.EXISTS(p_assignment_id) THEN
      l_pa_req_id := g_pa_req(p_assignment_id).pa_request_id;
   END IF;


   Hr_Utility.set_location(' l_pa_req_id: '||l_pa_req_id, 6);
   if l_pa_req_id is not null and
      g_pa_req_remark.exists(l_pa_req_id) then

      IF  p_input_value = 'RPA_RC01' then
          l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_1;
      ELSIF p_input_value = 'RPA_RC02' then
             l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_2;
      ELSIF p_input_value = 'RPA_RC03' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_3;
      ELSIF p_input_value = 'RPA_RC04'then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_4;
      ELSIF p_input_value = 'RPA_RC05' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_5;
      ELSIF p_input_value = 'RPA_RC06' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_6;
      ELSIF p_input_value = 'RPA_RC07' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_7;
      ELSIF p_input_value = 'RPA_RC08'then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_8;
      ELSIF p_input_value = 'RPA_RC09' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_9;
      ELSIF p_input_value = 'RPA_RC10' then
			l_return_value := g_pa_req_remark(l_pa_req_id).remark_code_10;
      END IF;
   END IF;
   Hr_Utility.set_location('l_return_value: '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   return l_return_value;
exception
   when others then
   p_error_code := sqlcode;
   p_error_message := NULL;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   return l_return_value;

end Get_Remarks_Id;

-- =============================================================================
-- ~ Get_RPA_Data:
-- =============================================================================
function Get_RPA_Data
        (p_assignment_id in number
        ,p_input_value   in varchar2
        ,p_error_code    in out nocopy varchar2
        ,p_error_message in out nocopy varchar2
        ) return varchar2 is
  l_return_value          varchar2(2000);
  l_pa_request_id         number;
  l_proc_name    constant varchar2(250) := g_proc_name ||'Get_RPA_Data';

begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_return_value := null;

   if g_pa_req.exists(p_assignment_id) then
     l_pa_request_id := g_pa_req(p_assignment_id).pa_request_id;
   end if;
   Hr_Utility.set_location(' l_pa_request_id: '||l_pa_request_id, 6);
   Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);

   if (l_pa_request_id is not null and
       g_rpa_rec.exists(l_pa_request_id))then

      if p_input_value ='RPA_DOB' then

         l_return_value :=fnd_date.date_to_canonical(
	    g_rpa_rec(l_pa_request_id).employee_date_of_birth);

      elsif p_input_value ='RPA_MNAME' then

         l_return_value := g_rpa_rec(l_pa_request_id).employee_middle_names;

      elsif p_input_value ='RPA_FNAME' then

         l_return_value := g_rpa_rec(l_pa_request_id).employee_first_name;

      elsif p_input_value ='RPA_LNAME' then

         l_return_value := g_rpa_rec(l_pa_request_id).employee_last_name;

      elsif p_input_value ='RPA_SSN' then

         l_return_value := REPLACE(g_rpa_rec(l_pa_request_id).employee_national_identifier,'-');

      elsif p_input_value ='RPA_POI' then

         l_return_value := g_rpa_rec(l_pa_request_id).personnel_office_id;

      elsif p_input_value ='RPA_ED_LEVEL' then

         l_return_value := g_rpa_rec(l_pa_request_id).education_level;

     elsif p_input_value ='RPA_POS_STAT_CSC' then

         l_return_value := g_rpa_rec(l_pa_request_id).position_occupied;

     elsif p_input_value ='RPA_ANN_INDIC' then

         l_return_value := g_rpa_rec(l_pa_request_id).annuitant_indicator;
     elsif p_input_value ='RPA_ALT_REQ' then

         l_return_value := g_rpa_rec(l_pa_request_id).altered_pa_request_id;
     elsif p_input_value ='RPA_SCD_LEAVE' then
        l_return_value := fnd_date.date_to_canonical(
	                  g_rpa_rec(l_pa_request_id).service_comp_date);
     elsif p_input_value ='RPA_CSC_AUTH_CODE_1NOA' then
        l_return_value := g_rpa_rec(l_pa_request_id).first_action_la_code1;
     elsif p_input_value ='RPA_CSC_AUTH_2CODE_1NOA' then
        l_return_value := g_rpa_rec(l_pa_request_id).first_action_la_code2;
     elsif p_input_value ='RPA_CSC_AUTH_CODE_2NOA' then
        l_return_value := g_rpa_rec(l_pa_request_id).second_action_la_code1;
     elsif p_input_value ='RPA_CSC_AUTH_2CODE_2NOA' then
        l_return_value := g_rpa_rec(l_pa_request_id).second_action_la_code2;

     elsif p_input_value ='RPA_VET_PREF_CD' then
        l_return_value := g_rpa_rec(l_pa_request_id).veterans_preference;
     elsif p_input_value ='RPA_VET_PREF_RIF' then
        l_return_value := g_rpa_attr(l_pa_request_id).veterans_pref_for_rif;
     elsif p_input_value ='RPA_TENURE_GRP' then
        l_return_value := g_rpa_rec(l_pa_request_id).tenure;
     elsif p_input_value ='RPA_RETIRE_PLN' then
        l_return_value := g_rpa_rec(l_pa_request_id).retirement_plan;
     elsif p_input_value ='RPA_FIRST_NOA_CD' then
        l_return_value := g_rpa_rec(l_pa_request_id).first_noa_code;
     elsif p_input_value ='RPA_SEC_NOA_CD' then
        l_return_value := g_rpa_rec(l_pa_request_id).second_noa_code;
     elsif p_input_value ='RPA_EFF_DATE' then
         l_return_value := fnd_date.date_to_canonical(
	                 g_rpa_rec(l_pa_request_id).effective_date);
     elsif p_input_value ='RPA_CSC_OTH_LEG_AUTH' then
        l_return_value := g_rpa_rec(l_pa_request_id).first_action_la_desc1;
     elsif p_input_value ='RPA_CSC_OTH_LEG_AUTH2' then
        l_return_value := g_rpa_rec(l_pa_request_id).first_action_la_desc2;
     elsif p_input_value ='RPA_WRK_SCH' then
        l_return_value := g_rpa_rec(l_pa_request_id).work_schedule;
     elsif p_input_value ='RPA_GRADE' then
        l_return_value := g_rpa_rec(l_pa_request_id).to_grade_or_level;
     elsif p_input_value ='RPA_STEP' then
        l_return_value := g_rpa_rec(l_pa_request_id).to_step_or_rate;
     elsif p_input_value ='RPA_SCH_SAL' then
      IF INSTR (g_rpa_rec(l_pa_request_id).to_basic_pay,'.') > 0 THEN
       l_return_value := LPAD(REPLACE(g_rpa_rec(l_pa_request_id).to_basic_pay,'.'),8,'0');
      ELSE
       IF  g_rpa_rec(l_pa_request_id).to_basic_pay IS NOT NULL THEN
        l_return_value := LPAD((g_rpa_rec(l_pa_request_id).to_basic_pay||'00'),8,'0');
       END IF;
      END IF;
     elsif p_input_value ='RPA_PAY_RAISE_SAL' then
      IF INSTR (g_rpa_rec(l_pa_request_id).from_basic_pay,'.') > 0 THEN
        l_return_value := LPAD(REPLACE(g_rpa_rec(l_pa_request_id).from_basic_pay,'.'),8,'0');
      ELSE
       IF g_rpa_rec(l_pa_request_id).from_basic_pay IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_rec(l_pa_request_id).from_basic_pay||'00',8,'0');
       END IF;
      END IF;

     elsif p_input_value ='RPA_SAL_RATE_CD' then
        l_return_value := g_rpa_rec(l_pa_request_id).to_pay_basis;
     elsif p_input_value ='RPA_PAY_RT_DET' then
        l_return_value := g_rpa_rec(l_pa_request_id).pay_rate_determinant;
     elsif p_input_value ='RPA_VET_STAT' then
        l_return_value := g_rpa_rec(l_pa_request_id).veterans_status;
     elsif p_input_value ='RPA_TOUR_DUTY_HRS' then
        l_return_value := LPAD(g_rpa_rec(l_pa_request_id).part_time_hours,4,'0');
     elsif p_input_value ='RPA_FLSA_CAT' then
        l_return_value := g_rpa_rec(l_pa_request_id).flsa_category;
     elsif p_input_value ='RPA_INST_PRG' then
        l_return_value := g_rpa_rec(l_pa_request_id).academic_discipline;
     elsif p_input_value ='RPA_FEGLI_CD' then
        l_return_value := g_rpa_rec(l_pa_request_id).fegli;
     elsif p_input_value ='RPA_DEG_CERT_REC' then
        l_return_value := g_rpa_rec(l_pa_request_id).year_degree_attained;
     elsif p_input_value ='RPA_RPA_PREV_AG_CD' then
      l_return_value :=g_rpa_attr(l_pa_request_id).Previous_agency_code;
     elsif p_input_value ='RPA_DT_ENT_PRES_GRADE' then
      l_return_value :=(
                    g_rpa_attr(l_pa_request_id).Date_entered_present_grade);
     elsif p_input_value ='RPA_PHY_HANDICAP_CD' then
      l_return_value :=g_rpa_attr(l_pa_request_id).phy_handicap_code;
     elsif p_input_value ='RPA_DT_LST_PAY_RET' then
      l_return_value :=(
                      g_rpa_attr(l_pa_request_id).Date_last_pay_status_retired);
     elsif p_input_value ='RPA_FRZN_CSRS_SER' then
      l_return_value :=g_rpa_attr(l_pa_request_id).Frozen_CSRS_service;
     elsif p_input_value ='RPA_CSRS_COV_AT_APT' then
      l_return_value :=g_rpa_attr(l_pa_request_id).CSRS_coverage_at_appointment;
     elsif p_input_value ='RPA_DATE_SICK_LEAVE_EXP_RET' then
      /*l_return_value :=fnd_date.date_to_canonical(
                      g_rpa_attr(l_pa_request_id).Date_sick_leave_exp_ret);*/
      l_return_value :=(
                      g_rpa_attr(l_pa_request_id).Date_sick_leave_exp_ret);
     elsif p_input_value ='RPA_ANNUAL_LEAVE_CATEGORY' then
      l_return_value :=g_rpa_attr(l_pa_request_id).Annual_leave_category;
     elsif p_input_value ='RPA_ANNUAL_LEAVE_45_DAY_CODE' then
      l_return_value :=g_rpa_attr(l_pa_request_id).Annual_leave_45_day_code  ;
     elsif p_input_value ='RPA_LEAVE_EAR_STAT_PY_PERIOD' then
      l_return_value :=g_rpa_attr(l_pa_request_id).Leave_ear_stat_py_period ;
     elsif p_input_value ='RPA_DATE_SCD_CSR' then
      l_return_value :=(
                           g_rpa_attr(l_pa_request_id).Date_SCD_CSR);
     elsif p_input_value ='RPA_DATE_SCD_RIF' then
      l_return_value := (
                      g_rpa_attr(l_pa_request_id).Date_SCD_RIF);
     elsif p_input_value ='RPA_DATE_TSP_VESTE' then
      l_return_value := (
                        g_rpa_attr(l_pa_request_id).Date_TSP_vested) ;
     elsif p_input_value ='RPA_DATE_SCD_SES' then
      l_return_value := g_rpa_attr(l_pa_request_id).Date_SCD_SES;
     elsif p_input_value ='RPA_DATE_SUPV_MGR_PROB' then
      l_return_value := (
                      g_rpa_attr(l_pa_request_id).Date_Supv_Mgr_Prob);
     elsif p_input_value ='RPA_DATE_SPVR_MGR_PROB_ENDS' then
      l_return_value := g_rpa_attr(l_pa_request_id).Date_Spvr_Mgr_Prob_Ends;
     elsif p_input_value ='RPA_DATE_PROB_PERIOD_START' then
      /*l_return_value := fnd_date.date_to_canonical(
                           g_rpa_attr(l_pa_request_id).Date_Prob_period_start)  ;*/
      l_return_value := (
                           g_rpa_attr(l_pa_request_id).Date_Prob_period_start)  ;
     elsif p_input_value ='RPA_SUPV_MGR_PROB_PERIOD_REQ' then
      l_return_value := g_rpa_attr(l_pa_request_id).Supv_mgr_prob_period_req ;
     elsif p_input_value ='RPA_DATE_CAREER_PERMA_TEN_ST' then
     /* l_return_value := fnd_date.date_to_canonical(
                       g_rpa_attr(l_pa_request_id).Date_Career_perma_Ten_St) ;   */
      l_return_value := (
                       g_rpa_attr(l_pa_request_id).Date_Career_perma_Ten_St) ;
     elsif p_input_value ='RPA_DATE_RET_RGHT_END' then
      l_return_value := (
                       g_rpa_attr(l_pa_request_id).Date_Ret_Rght_end)  ;
     elsif p_input_value ='RPA_DATE_RET_RATE_EXP' then
      l_return_value := (
                             g_rpa_attr(l_pa_request_id).date_retain_rate_exp)  ;
     elsif p_input_value ='RPA_CITIZENSHIP_CODE' then
      l_return_value := g_rpa_attr(l_pa_request_id).Citizenship_code  ;
     elsif p_input_value ='RPA_UNIFORM_SVC_STATUS' then
      l_return_value := g_rpa_attr(l_pa_request_id).Uniform_Svc_Status  ;
     elsif p_input_value ='RPA_CREDITABLE_MILITARY_SVC' then
      l_return_value := g_rpa_attr(l_pa_request_id).Creditable_Military_Svc  ;
     elsif p_input_value ='RPA_DATE_RET_MILITARY' then
      l_return_value := (
                        g_rpa_attr(l_pa_request_id).Date_Ret_Military)  ;
     elsif p_input_value ='RPA_SAVED_GRD_PAY_PLAN' then
      l_return_value := g_rpa_attr(l_pa_request_id).Saved_Grd_Pay_Plan ;
     elsif p_input_value ='RPA_SAVED_GRADE' then
      l_return_value := g_rpa_attr(l_pa_request_id).Saved_Grade   ;
     elsif p_input_value ='RPA_DATE_CORR_NOA' then
      l_return_value := fnd_date.date_to_canonical(
                            g_rpa_attr(l_pa_request_id).Date_Corr_NoA)  ;
     elsif p_input_value ='RPA_DATE_NTE_SF50' then
      l_return_value := (
                           g_rpa_attr(l_pa_request_id).Date_NTE_SF50) ;
     elsif p_input_value ='RPA_RETENTION_PERCENT' then

       l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Retention_Percent,2,'0')   ;
     elsif p_input_value ='RPA_RETENTION_ALLOWANCE' then
      IF INSTR(g_rpa_attr(l_pa_request_id).Retention_allowance,'.') > 0 THEN
       l_return_value := LPAD(REPLACE( g_rpa_attr(l_pa_request_id).Retention_allowance,'.'),7,'0') ;
      ELSE
       IF g_rpa_attr(l_pa_request_id).Retention_allowance IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Retention_allowance||'00',7,'0') ;
       END IF;
      END IF;
     elsif p_input_value ='RPA_NAME_CORR_CODE' then
      l_return_value := g_rpa_attr(l_pa_request_id).Name_Corr_code;
     elsif p_input_value ='RPA_SSNO_OLD' then
      l_return_value := g_rpa_attr(l_pa_request_id).SSNO_Old ;
     elsif p_input_value ='RPA_RECRUITMENT_PERCENT' then
       l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Recruitment_Percent,2,'0');
     elsif p_input_value ='RPA_RECRUITMENT_BONUS' then
      IF INSTR(g_rpa_attr(l_pa_request_id).Recruitment_bonus,'.') > 0 THEN
       l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).Recruitment_bonus,'.'),8,'0');
      ELSE
       IF g_rpa_attr(l_pa_request_id).Recruitment_bonus IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Recruitment_bonus||'00',8,'0');
       END IF;
      END IF;
     elsif p_input_value ='RPA_RELOCATION_PERCENT' then
       l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Relocation_percent,2,'0');
     elsif p_input_value ='RPA_RELOCATION_BONUS' then
      IF INSTR(g_rpa_attr(l_pa_request_id).Relocation_bonus,'.') > 0 THEN
       l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).Relocation_bonus,'.'),8,'0') ;
      ELSE
       IF g_rpa_attr(l_pa_request_id).Relocation_bonus IS NOT NULL THEN
        l_return_value :=LPAD( g_rpa_attr(l_pa_request_id).Relocation_bonus||'00',8,'0') ;
       END IF;
      END IF;
     elsif p_input_value ='RPA_SUPERVISORY_PERCENT' then
       l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Supervisory_Percent,2,'0');
     elsif p_input_value ='RPA_SUPERVISORY_DIFFERENTIAL_RATE' then
      IF INSTR(g_rpa_attr(l_pa_request_id).Supervisory_Differential_Rate,'.') > 0 THEN
       l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).Supervisory_Differential_Rate,'.'),8,'0') ;
      ELSE
       IF g_rpa_attr(l_pa_request_id).Supervisory_Differential_Rate IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).Supervisory_Differential_Rate||'00',8,'0') ;
       END IF;
      END IF;
     elsif p_input_value ='RPA_ACTION_CODE' then
       l_return_value := g_rpa_attr(l_pa_request_id).action_code ;
     elsif p_input_value ='RPA_POI' then
      l_return_value := g_rpa_attr(l_pa_request_id).poi  ;
     elsif p_input_value ='RPA_PMSO_POI' then
      l_return_value := g_rpa_attr(l_pa_request_id).pmso_poi  ;
     elsif p_input_value ='RPA_NFC_AGENCY' then
       l_return_value := g_rpa_attr(l_pa_request_id).nfc_agency ;
      Hr_Utility.set_location(' l_return_value: '||l_return_value, 6);
     elsif p_input_value ='RPA_PMSO_AGENCY' then
      l_return_value := g_rpa_attr(l_pa_request_id).pmso_agency ;
     elsif p_input_value ='RPA_POS_NUM' then
      l_return_value := g_rpa_attr(l_pa_request_id).pos_num ;
     elsif p_input_value ='RPA_PMSO_DEPT' then
      l_return_value := g_rpa_attr(l_pa_request_id).pmso_dept ;
     elsif p_input_value ='RPA_DEPT_CODE' then
      l_return_value := g_rpa_attr(l_pa_request_id).pmso_dept  ;
     elsif p_input_value ='RPA_GENDER_CODE' then
      l_return_value := g_rpa_attr(l_pa_request_id).gender_code ;
     elsif p_input_value ='RPA_PAY_PERIOD_NUM' then
      l_return_value := LPAD(g_rpa_attr(l_pa_request_id).pay_period_num,2,'0');
     elsif p_input_value ='RPA_MRN' then
      l_return_value := g_rpa_attr(l_pa_request_id).mrn;
     elsif p_input_value ='RPA_RACE' then
      l_return_value := g_rpa_attr(l_pa_request_id).race;

     elsif p_input_value ='RPA_CVL_SERV_ANNUIT_SHRE' then
      IF INSTR (g_rpa_attr(l_pa_request_id).civil_service_annuitant_share,'.') > 0 THEN
        l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).civil_service_annuitant_share,'.'),7,'0');
      ELSE
       IF g_rpa_attr(l_pa_request_id).civil_service_annuitant_share IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).civil_service_annuitant_share||'00',7,'0');
       END IF;
      END IF;

     elsif p_input_value ='RPA_DATE_SCD_WGI' then
      /*l_return_value := fnd_date.date_to_canonical(
                        g_rpa_attr(l_pa_request_id).dt_scd_wgi);*/
      l_return_value := (
                        g_rpa_attr(l_pa_request_id).dt_scd_wgi);
     elsif p_input_value ='RPA_AUTH_DT' then
      l_return_value := (
                        g_rpa_attr(l_pa_request_id).authentication_dt);
     elsif p_input_value ='RPA_NAT_ACT_PREV' then
      l_return_value := g_rpa_attr(l_pa_request_id).nat_act_prev;
     elsif p_input_value ='RPA_FEHB_COV_CD' then
      l_return_value := g_rpa_attr(l_pa_request_id).fehb_cov_cd;
     elsif p_input_value ='RPA_GAIN_LOSE_DEPT_NUSDA' then
      l_return_value := g_rpa_attr(l_pa_request_id).gain_lose_dept_non_usda;

     elsif p_input_value ='RPA_CSC_AUTH_PREV_NOA' then
      l_return_value := g_rpa_attr(l_pa_request_id).csc_auth_prev_noa;
     elsif p_input_value ='RPA_CSC_AUTH_PREV_2NOA' then
      l_return_value := g_rpa_attr(l_pa_request_id).csc_auth_prev_2noa;
    /* elsif p_input_value ='RPA_DATE_RET_RATE_EXP' then
      l_return_value := g_rpa_attr(l_pa_request_id).date_retain_rate_exp;*/
     elsif p_input_value ='RPA_SPECIAL_EMP_CD' then
      l_return_value := g_rpa_attr(l_pa_request_id).special_emp_code;
     elsif p_input_value ='RPA_SPEC_EMP_PRG_CD' then
      l_return_value := g_rpa_attr(l_pa_request_id).special_emp_prg_code;
     elsif p_input_value ='RPA_TSP_ELIG_CD' then
      l_return_value := g_rpa_attr(l_pa_request_id).tsp_elig_cd;
     elsif p_input_value ='RPA_TYP_APT_CD' then
      l_return_value := g_rpa_attr(l_pa_request_id).typ_apt_cd;

     elsif p_input_value ='RPA_APP_DT' then
        l_return_value := TRUNC(g_rpa_rec(l_pa_request_id).approval_date);


     elsif p_input_value ='RPA_FOR_LANG_PERC' then
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).for_lang_perc,2,'0');
     elsif p_input_value ='RPA_FOR_LANG_ALL' then
        IF INSTR (g_rpa_attr(l_pa_request_id).for_lang_all,'.') > 0 THEN
         l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).for_lang_all,'.'),7,'0');
        ELSE
         IF g_rpa_attr(l_pa_request_id).for_lang_all IS NOT NULL THEN
          l_return_value := LPAD(g_rpa_attr(l_pa_request_id).for_lang_all||'00',7,'0');
         END IF;
        END IF;
     elsif p_input_value ='RPA_WAGE_GRD_SHFT_VAR' then
        l_return_value := g_rpa_attr(l_pa_request_id).wage_grd_shft_var;
     elsif p_input_value ='RPA_COOP_EMP_CTRL_CD' then
        l_return_value := g_rpa_attr(l_pa_request_id).coop_emp_ctrl_cd;
     elsif p_input_value ='RPA_COOP_ANN_SHR_CD' then
        l_return_value := g_rpa_attr(l_pa_request_id).coop_ann_shr_cd;
     elsif p_input_value ='RPA_COOP_ST_SHR_SAL' then
      IF INSTR (g_rpa_attr(l_pa_request_id).coop_st_shr_sal,'.') > 0 THEN
        l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).coop_st_shr_sal,'.'),7,'0');
      ELSE
       IF g_rpa_attr(l_pa_request_id).coop_st_shr_sal IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).coop_st_shr_sal||'00',7,'0');
       END IF;
      END IF;
     elsif p_input_value ='RPA_COOP_EMP_OTRT_FUR' then
      IF INSTR (g_rpa_attr(l_pa_request_id).coop_emp_otrt_fur,'.') > 0 THEN
         l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).coop_emp_otrt_fur,'.'),7,'0');
      ELSE
       IF g_rpa_attr(l_pa_request_id).coop_emp_otrt_fur IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).coop_emp_otrt_fur||'00',7,'0');
       END IF;
      END IF;
        l_return_value := g_rpa_attr(l_pa_request_id).coop_emp_otrt_fur;
     elsif p_input_value ='RPA_COOP_EMP_HOLRT_FUR' then
      IF INSTR (g_rpa_attr(l_pa_request_id).coop_emp_holrt_fur,'.') > 0 THEN
        l_return_value := LPAD(REPLACE(g_rpa_attr(l_pa_request_id).coop_emp_holrt_fur,'.'),7,'0');
      ELSE
       IF g_rpa_attr(l_pa_request_id).coop_emp_holrt_fur IS NOT NULL THEN
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).coop_emp_holrt_fur||'00',7,'0');
       END IF;
      END IF;
     elsif p_input_value ='RPA_QUART_DED_RT' then
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).quart_ded_rt,5,'0');
     elsif p_input_value ='RPA_QUART_DED_CD' then
        l_return_value := g_rpa_attr(l_pa_request_id).quart_ded_cd;
     elsif p_input_value ='RPA_ENV_DIFF_RT' then
        l_return_value := LPAD(g_rpa_attr(l_pa_request_id).env_diff_rt,4,'0');
  /*   elsif p_input_value ='RPA_STAFF_PERC' then
        l_return_value := g_rpa_rec(l_pa_request_id).staff_perc;*/
     elsif p_input_value ='RPA_SAV_GRD_OCC_SER' then
        l_return_value := g_rpa_attr(l_pa_request_id).sav_grd_occ_ser;
     elsif p_input_value ='RPA_SAV_GRD_OCC_SER_FUNCD' then
        l_return_value := g_rpa_attr(l_pa_request_id).sav_grd_occ_ser_funcd;

     elsif p_input_value ='RPA_AGENCY_USE' then
        l_return_value := g_rpa_attr(l_pa_request_id).agency_use;
     elsif p_input_value ='RPA_POSITION_CLASS_CD' then
        l_return_value := g_rpa_attr(l_pa_request_id).position_class_cd;

     end  if;
    end if;

   Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

   return l_return_value;

exception
   when others then
   p_error_code := sqlcode;
   p_error_message :=p_input_value;  --sqlerrm;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   return l_return_value;

end Get_RPA_Data;
-- =============================================================================
-- ~ Get_Remarks_Data:
-- =============================================================================
function Get_Remarks_Data
        (p_assignment_id in number
        ,p_input_value   in varchar2
        ,p_error_code    in out nocopy varchar2
        ,p_error_message in out nocopy varchar2
        ) return varchar2 is

  /*cursor csr_rem_dsc(c_pa_remark_id in number) is
  select description
    from ghr_pa_remarks
   where pa_remark_id = c_pa_remark_id;*/


  CURSOR csr_rem_dsc(c_pa_remark_id  number
                    ,c_request_id    number
                    ,c_effective_date date) is
    SELECT gpr.remark_id
         ,gpr.description
         ,gr.code
     FROM ghr_pa_remarks gpr
         ,ghr_remarks gr
    WHERE gpr.pa_remark_id = c_pa_remark_id
      AND pa_request_id = c_request_id
      AND gr.remark_id=gpr.remark_id
      AND c_effective_date between gr.date_from
                               and NVL(gr.date_to,to_date('12/31/4712','MM/DD/YYYY'))
    ORDER BY remark_id;

  l_csr_rem_dsc           csr_rem_dsc%ROWTYPE;
  l_return_value          VARCHAR2(4000);
  l_value                 VARCHAR2(4000);
  l_pa_request_id         NUMBER;
  l_proc_name    CONSTANT VARCHAR2(250) := g_proc_name ||'Get_Remarks_Data';
  l_rpa_rec_exists        BOOLEAN;
  l_rem_exists            BOOLEAN;
  l_awd_rec_exists        BOOLEAN;
  l_rem_code              VARCHAR2(3);
begin

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_return_value := null;
   l_rpa_rec_exists := false; l_rem_exists := false;


   if g_pa_req.exists(p_assignment_id) then
      Hr_Utility.set_location(' entering g_pa_req if', 6);
      l_pa_request_id  := g_pa_req(p_assignment_id).pa_request_id;
      l_rpa_rec_exists := g_rpa_rec.exists(l_pa_request_id);
      l_rem_exists     := g_pa_req_remark.exists(l_pa_request_id);
   end if;

   Hr_Utility.set_location(' l_pa_request_id: '||l_pa_request_id, 6);
   Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);

   if (l_rpa_rec_exists and
       l_rem_exists )then
      Hr_Utility.set_location(' entering first if', 6);

     open csr_rem_dsc(g_pa_req(p_assignment_id).pa_remark_id
                     ,l_pa_request_id
                     ,g_rpa_rec(l_pa_request_id).effective_date);
            fetch csr_rem_dsc into l_csr_rem_dsc;
               l_value := l_csr_rem_dsc.description ;
               l_rem_code :=l_csr_rem_dsc.code;

            close csr_rem_dsc;
      if p_input_value ='REM_POI' then

         l_return_value :=
               g_rpa_rec(l_pa_request_id).personnel_office_id;
      elsif p_input_value ='REM_AGNCY_CD' THEN
         l_return_value := g_rpa_attr(l_pa_request_id).nfc_agency ;

      elsif p_input_value ='REM_DEPT_CD' THEN
         l_return_value := g_rpa_attr(l_pa_request_id).pmso_dept ;
      elsif p_input_value ='REM_ALT_REQ' then

         l_return_value :=
               g_rpa_rec(l_pa_request_id).altered_pa_request_id;
      elsif p_input_value ='REM_PA_DATE' then

         l_return_value :=fnd_date.date_to_canonical(g_rpa_rec(l_pa_request_id).effective_date);
              -- FND_DATE.CANONICAL_TO_DATE(g_rpa_rec(l_pa_request_id).effective_date);

      elsif p_input_value ='REM_DESC_0109' then
      --Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);
       l_return_value :=SUBSTR(l_value,0,524);
      elsif p_input_value ='REM_DESC_01' then
        l_return_value :=SUBSTR(l_value,0,222);
      elsif p_input_value ='REM_DESC_02' then
        l_return_value :=SUBSTR(l_value,223,222);
      elsif p_input_value ='REM_DESC_03' then
       l_return_value :=SUBSTR(l_value,445,222);
      elsif p_input_value ='REM_DESC_04' then
       l_return_value :=SUBSTR(l_value,75,149);
      elsif p_input_value ='REM_DESC_05' then
       l_return_value :=SUBSTR(l_value,150,224);
      elsif p_input_value ='REM_DESC_06' then
       l_return_value :=SUBSTR(l_value,225,299);
      elsif p_input_value ='REM_DESC_07' then
       l_return_value :=SUBSTR(l_value,300,374);
      elsif p_input_value ='REM_DESC_08' then
       l_return_value :=SUBSTR(l_value,375,449);
      elsif p_input_value ='REM_DESC_09' then
       l_return_value :=SUBSTR(l_value,450,524);
      elsif p_input_value ='REM_SSN' then
         l_return_value :=
               REPLACE(g_rpa_rec(l_pa_request_id).employee_national_identifier,'-');
      elsif p_input_value ='REM_LN_OCCUR' then
       IF l_value IS NOT NULL THEN
       l_return_value :=LPAD(CEIL(LENGTH(l_value)/74),2,'0');
       ELSE
        l_return_value :='0';
       END IF;
      elsif p_input_value ='REM_CODE' then
         l_return_value := g_pa_req(p_assignment_id).remark_code;
      elsif p_input_value ='REM_FIR_NOA_CD' then
         l_return_value :=
               g_rpa_rec(l_pa_request_id).first_noa_code;
      elsif p_input_value ='REM_SEC_NOA_CD' then
         l_return_value :=
               g_rpa_rec(l_pa_request_id).second_noa_code;
      elsif p_input_value ='REM_PAY_PER_NUM' then
         l_return_value :=
               LPAD(g_rpa_attr(l_pa_request_id).pay_period_num,2,'0');
      elsif p_input_value ='REM_RMK_NUM' then
         l_return_value := l_rem_code ; --g_remark_cnt;
      end  if;
    end if;


	-- For awards
	l_awd_rec_exists := false; l_rem_exists := false;

   if g_aw_req.exists(p_assignment_id) then
		Hr_Utility.set_location(' entering g_aw_req if', 6);
      l_pa_request_id := g_aw_req(p_assignment_id).pa_request_id;
      l_awd_rec_exists := g_awd_rec.exists(l_pa_request_id);
      l_rem_exists     := g_pa_req_remark.exists(l_pa_request_id);
   end if;

   Hr_Utility.set_location(' l_pa_request_id: '||l_pa_request_id, 16);
   Hr_Utility.set_location(' p_input_value: '||p_input_value, 16);

   if (l_awd_rec_exists and
       l_rem_exists )then
      Hr_Utility.set_location(' entering first if', 6);
     open csr_rem_dsc(g_aw_req(p_assignment_id).pa_remark_id
                     ,l_pa_request_id
                     ,g_awd_rec(l_pa_request_id).effective_date);
            fetch csr_rem_dsc into l_csr_rem_dsc;
               l_value := l_csr_rem_dsc.description ;
               l_rem_code :=l_csr_rem_dsc.code;

            close csr_rem_dsc;
      if p_input_value ='REM_POI' then

         l_return_value :=
							g_awd_rec(l_pa_request_id).personnel_office_id;
      elsif p_input_value ='REM_AGNCY_CD' THEN
         l_return_value := g_rpa_awd_attr(l_pa_request_id).nfc_agency_code ;

      elsif p_input_value ='REM_DEPT_CD' THEN
         l_return_value := g_rpa_awd_attr(l_pa_request_id).dept_code ;
      elsif p_input_value ='REM_ALT_REQ' then

         l_return_value :=
               g_awd_rec(l_pa_request_id).altered_pa_request_id;
      elsif p_input_value ='REM_PA_DATE' then

         l_return_value :=FND_DATE.date_to_canonical(g_awd_rec(l_pa_request_id).effective_date);
              -- FND_DATE.CANONICAL_TO_DATE(g_rpa_rec(l_pa_request_id).effective_date);

      elsif p_input_value ='REM_DESC_0109' then
      --Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);
       l_return_value :=SUBSTR(l_value,0,524);
      elsif p_input_value ='REM_DESC_01' then
        l_return_value :=SUBSTR(l_value,0,222);
      elsif p_input_value ='REM_DESC_02' then
        l_return_value :=SUBSTR(l_value,223,222);
      elsif p_input_value ='REM_DESC_03' then
       l_return_value :=SUBSTR(l_value,445,222);
      elsif p_input_value ='REM_DESC_04' then
       l_return_value :=SUBSTR(l_value,75,149);
      elsif p_input_value ='REM_DESC_05' then
       l_return_value :=SUBSTR(l_value,150,224);
      elsif p_input_value ='REM_DESC_06' then
       l_return_value :=SUBSTR(l_value,225,299);
      elsif p_input_value ='REM_DESC_07' then
       l_return_value :=SUBSTR(l_value,300,374);
      elsif p_input_value ='REM_DESC_08' then
       l_return_value :=SUBSTR(l_value,375,449);
      elsif p_input_value ='REM_DESC_09' then
       l_return_value :=SUBSTR(l_value,450,524);
      elsif p_input_value ='REM_SSN' then
         l_return_value :=
               REPLACE(g_awd_rec(l_pa_request_id).employee_national_identifier,'-');
      elsif p_input_value ='REM_LN_OCCUR' then
       IF l_value IS NOT NULL THEN
	       l_return_value :=LPAD(CEIL(LENGTH(l_value)/74),2,'0');
       ELSE
		   l_return_value :='0';
       END IF;
      elsif p_input_value ='REM_CODE' then
         l_return_value := g_aw_req(p_assignment_id).remark_code;
      elsif p_input_value ='REM_FIR_NOA_CD' then
         l_return_value :=
               g_rpa_awd_attr(l_pa_request_id).nat_act_2nd_3pos;
      elsif p_input_value ='REM_SEC_NOA_CD' then
         l_return_value :=
               g_rpa_awd_attr(l_pa_request_id).nat_act_1st_3_pos;
      elsif p_input_value ='REM_PAY_PER_NUM' then
         l_return_value :=
               LPAD(g_rpa_awd_attr(l_pa_request_id).pay_per_num,2,'0');
      elsif p_input_value ='REM_RMK_NUM' then
         l_return_value := l_rem_code ; --g_remark_cnt;
      end  if;
    end if;

	-- End awards

   Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

   return l_return_value;

exception
   when others then
   p_error_code := sqlcode;
   p_error_message := NULL;
   Hr_Utility.set_location('SQLERRM: '||sqlerrm, 90);
   Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);
   return l_return_value;

end Get_Remarks_Data;

-- =============================================================================
-- ~ Get_Award_Data:
-- =============================================================================
function Get_Award_Data
        (p_assignment_id in number
        ,p_input_value   in varchar2
        ,p_error_code    in out nocopy varchar2
        ,p_error_message in out nocopy varchar2
        ) return varchar2 is
  l_return_value          varchar2(2000);
  l_proc_name    constant varchar2(250) := g_proc_name ||'Get_Award_Data';
  l_pa_request_id         number(15);
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   l_return_value := null;
   if g_aw_req.exists(p_assignment_id) then
     l_pa_request_id := g_aw_req(p_assignment_id).pa_request_id;
   end if;

   Hr_Utility.set_location(' l_pa_request_id: '||l_pa_request_id, 6);
   Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);


   if (l_pa_request_id is not null and
       g_awd_rec.exists(l_pa_request_id))then

      if p_input_value ='AWD_POI' then

         l_return_value := g_awd_rec(l_pa_request_id).personnel_office_id;
      elsif p_input_value ='AWD_ALT_REQ' then

         l_return_value := g_awd_rec(l_pa_request_id).altered_pa_request_id;
      elsif p_input_value ='AWD_SSN' then

         l_return_value := REPLACE(g_awd_rec(l_pa_request_id).employee_national_identifier,'-');

      elsif p_input_value ='RPA_AWARD_ID' then

         l_return_value := l_pa_request_id;
      elsif p_input_value ='AWD_AGCY' then
         l_return_value := g_rpa_awd_attr(l_pa_request_id).nfc_agency_code;

      elsif p_input_value ='AWD_PAY_PER_NUM' then

         l_return_value := LPAD(g_rpa_awd_attr(l_pa_request_id).pay_per_num,2,'0');

      elsif p_input_value ='AWD_CAW' then
       IF INSTR( g_rpa_awd_attr(l_pa_request_id).current_cash_award,'.') > 0 THEN
         l_return_value := LPAD(REPLACE(g_rpa_awd_attr(l_pa_request_id).current_cash_award,'.'),7,'0');
       ELSE
        IF g_rpa_awd_attr(l_pa_request_id).current_cash_award IS NOT NULL THEN
         l_return_value := LPAD(g_rpa_awd_attr(l_pa_request_id).current_cash_award||'00',7,'0');
        END IF;
       END IF;


      elsif p_input_value ='AWD_PERS_EFF_DT' then

         l_return_value := FND_DATE.date_to_canonical(g_awd_rec(l_pa_request_id).effective_date);

      elsif p_input_value ='AWD_CSC_OTH_LEG_AUTH' then

         l_return_value := g_awd_rec(l_pa_request_id).FIRST_ACTION_LA_DESC1;
      elsif p_input_value ='AWD_CSC_OTH_LEG_AUTH2' then

         l_return_value := g_awd_rec(l_pa_request_id).FIRST_ACTION_LA_DESC2;

      elsif p_input_value ='AWD_DEPT_CD' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).dept_code;

      elsif p_input_value ='AWD_DT_CSH_AWD_FRM' then
        l_return_value := fnd_date.date_to_canonical(g_rpa_awd_attr(l_pa_request_id).dt_cash_awd_from);

      elsif p_input_value ='AWD_DT_CSH_AWD_TO' then

         l_return_value := fnd_date.date_to_canonical(g_rpa_awd_attr(l_pa_request_id).dt_cash_awd_to) ;
      elsif p_input_value ='AWD_TANG_BEN' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).tangible_ben ;

      elsif p_input_value ='AWD_FIR_YR_SAV' then
       IF INSTR(g_rpa_awd_attr(l_pa_request_id).awd_fir_yr_sav,'.')> 0 THEN
         l_return_value := LPAD(REPLACE(g_rpa_awd_attr(l_pa_request_id).awd_fir_yr_sav,'.'),10,'0') ;
       ELSE
        IF g_rpa_awd_attr(l_pa_request_id).awd_fir_yr_sav IS NOT NULL THEN
         l_return_value := LPAD(g_rpa_awd_attr(l_pa_request_id).awd_fir_yr_sav||'00',10,'0') ;
        END IF;
       END IF;

      elsif p_input_value ='AWD_INTANG_BEN' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).intangible_ben ;


      elsif p_input_value ='AWD_CSH_AWD_AGNCY' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).cash_award_agency ;

      elsif p_input_value ='AWD_NAT_ACT_POS2' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).nat_act_2nd_3pos  ;

      elsif p_input_value ='AWD_CSC_AUTH_CD_NOA2' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).csc_auth_code_2nd_noa  ;

      elsif p_input_value ='AWD_CSC_AUTH_CD_NOA22' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).csc_auth_2ndcode_2nd_noa  ;

      elsif p_input_value ='AWD_CSH_AWD_CD' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).awd_csh_awd_cd   ;

     /* elsif p_input_value ='AWD_CSH_AWD_PAY_CD' then

         l_return_value := '0'  ;*/

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_IND' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_ind ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_LN1' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_ln1 ;

      elsif p_input_value ='AWD_CHK_MAIL_DES_AGNT' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_desg_agnt ;
      elsif p_input_value ='AWD_CHK_MAIL_ADDR_LN2' then

         l_return_value :=g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_ln2 ;

      elsif p_input_value ='AWD_NAT_ACT_POS1' then

         l_return_value :=g_rpa_awd_attr(l_pa_request_id).nat_act_1st_3_pos ;

      elsif p_input_value ='AWD_CSC_AUTH_CD_NOA12' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).csc_auth_code_2nd_noa1 ;

      elsif p_input_value ='AWD_CSC_AUTH_CD_NOA122' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).csc_auth_2ndcode_2nd_noa1 ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_CITY' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_city_name ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_STATE' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_state_name ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_ZIP5' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_zip_5 ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_ZIP4' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_zip_4 ;

      elsif p_input_value ='AWD_CHK_MAIL_ADDR_ZIP2' then

         l_return_value := g_rpa_awd_attr(l_pa_request_id).chk_mail_addr_zip_2 ;

     elsif p_input_value ='AWD_CASE_NUM' then
      l_return_value := g_rpa_awd_attr(l_pa_request_id).awd_case_num ;
     elsif p_input_value ='AWD_STORE_ACT_IND' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_store_act_ind;
     elsif p_input_value ='AWD_CSH_AWD_TYP_CD' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_csh_awd_typ_cd;
     elsif p_input_value ='AWD_CSH_AWD_PAY_CD' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_csh_awd_pay_cd  ;
     elsif p_input_value ='AWD_NO_PER_CSH_AWD' then
      l_return_value :=LPAD(g_rpa_awd_attr(l_pa_request_id).awd_no_per_csh_awd,3,'0');
     elsif p_input_value ='AWD_ACCTG_DIST_FISYR_CD' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_acctg_dist_fisyr_cd;
     elsif p_input_value ='AWD_ACCTG_DIST_APPN_CD' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_acctg_dist_appn_cd;
     elsif p_input_value ='AWD_AUTH_DT' then
      l_return_value :=g_rpa_awd_attr(l_pa_request_id).authentication_dt;
    elsif p_input_value ='AWD_CSH_AWD_ACCST_CHG' then
     l_return_value :=g_rpa_awd_attr(l_pa_request_id).awd_csh_awd_accst_chg;
     elsif p_input_value ='AWD_APP_DT' then
      l_return_value := TRUNC(g_awd_rec(l_pa_request_id).approval_date);
      -- Bug 4641232 For elements pos-one-two and pos-three-four
      elsif p_input_value = 'AWD_POS_ONE_TWO' then
      	l_return_value := '67';
      elsif p_input_value = 'AWD_POS_THREE_FOUR' then
      	l_return_value := '00';
      end  if;
   end if;
   return l_return_value;
exception
   when others then
   p_error_code := sqlcode;
   p_error_message := p_input_value;--sqlerrm;
   Hr_Utility.set_location('SQLERRM: '||sqlerrm, 90);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   return l_return_value;

end Get_Award_Data;
-- =============================================================================
-- ~ Get_Address_Data:
-- =============================================================================
function Get_Address_Data
        (p_assignment_id in number
        ,p_input_value   in varchar2
        ,p_error_code    in out nocopy varchar2
        ,p_error_message in out nocopy varchar2
        ) return varchar2 is

  l_return_value          varchar2(2000);
  l_address_id            number;
  l_proc_name    constant varchar2(250) := g_proc_name ||'Get_Address_Data';

begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_return_value := null;
   if g_address_rec.exists(p_assignment_id) then
     l_address_id := g_address_rec(p_assignment_id).address_id;
   end if;


   if g_debug then
      Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);
      Hr_Utility.set_location(' l_address_id: '||l_address_id, 6);
   end if;

   Hr_Utility.set_location(' p_input_value: '||p_input_value, 6);
   Hr_Utility.set_location(' l_address_id: '||l_address_id, 6);

   if (l_address_id is not null )then

      if p_input_value ='ADD_EFF_DATE' then

         l_return_value := fnd_date.date_to_canonical(
                             g_address_rec(p_assignment_id).effective_date);

      elsif p_input_value ='ADD_LINE1' then

         l_return_value := g_rpa_add_attr(p_assignment_id).address_line1;

      elsif p_input_value ='ADD_LINE2' then

         l_return_value := g_rpa_add_attr(p_assignment_id).address_line2;

      elsif p_input_value ='ADD_LINE3' then

         l_return_value := g_rpa_add_attr(p_assignment_id).address_line3;

      elsif p_input_value ='ADD_CITY' then

      --   l_return_value := g_address_rec(p_assignment_id).town_or_city;
           l_return_value := g_rpa_add_attr(p_assignment_id).add_city;

      elsif p_input_value ='ADD_STATE' then

      -- l_return_value := g_address_rec(p_assignment_id).region_2;

         l_return_value := g_rpa_add_attr(p_assignment_id).add_state;

      elsif p_input_value ='ADD_COUNTY' then

        -- l_return_value := SUBSTR (g_address_rec(p_assignment_id).region_1,7,3);
       --   l_return_value := g_rpa_add_attr(p_assignment_id).add_county;
          l_return_value := SUBSTR(g_rpa_add_attr(p_assignment_id).add_county,7,3);

      elsif p_input_value ='ADD_ZIPCODE' then

         l_return_value :=SUBSTR( g_rpa_add_attr(p_assignment_id).zip_cd,0,5);

     elsif p_input_value ='ADD_ZIP_CD_4' then
        --IF LENGTH(g_rpa_add_attr(p_assignment_id).zip_cd) >=9 THEN

         l_return_value := SUBSTR(g_rpa_add_attr(p_assignment_id).zip_cd,LENGTH(g_rpa_add_attr(p_assignment_id).zip_cd)-3);
        --END IF;

      elsif p_input_value ='ADD_AGNCY_CD' then

         Hr_Utility.set_location(' Inside Agency CD: '||p_input_value, 6);

         l_return_value :=g_rpa_add_attr(p_assignment_id).nfc_agency_code;

          Hr_Utility.set_location(' l_return_value: '||l_return_value, 6);

      elsif p_input_value ='ADD_POI' then

         l_return_value := g_rpa_add_attr(p_assignment_id).poi;
      elsif p_input_value ='ADD_PAY_PER_NUM' then

         l_return_value := LPAD(g_rpa_add_attr(p_assignment_id).pay_per_num,2,'0');
      elsif p_input_value ='ADD_DEPT_CODE' then

         l_return_value := g_rpa_add_attr(p_assignment_id).dept_code;
      elsif p_input_value ='ADD_SSN' then
         l_return_value := g_rpa_add_attr(p_assignment_id).ssn;





      elsif p_input_value ='ADD_LINE_CHK1' then
         l_return_value := g_rpa_add_attr(p_assignment_id).address_line1_chk;

      elsif p_input_value ='ADD_LINE_CHK2' then

         l_return_value := g_rpa_add_attr(p_assignment_id).address_line2_chk;

      elsif p_input_value ='ADD_LINE_CHK3' then

         l_return_value := g_rpa_add_attr(p_assignment_id).address_line3_chk;

      elsif p_input_value ='ADD_CITY_CHK' then

      --   l_return_value := g_address_rec(p_assignment_id).town_or_city;
           l_return_value := g_rpa_add_attr(p_assignment_id).add_city_chk;

      elsif p_input_value ='ADD_STATE_CHK' then

      -- l_return_value := g_address_rec(p_assignment_id).region_2;

         l_return_value := g_rpa_add_attr(p_assignment_id).add_state_chk;

      elsif p_input_value ='ADD_COUNTY_CHK' then

          --SUBSTR (g_address_rec(p_assignment_id).region_1,7,3);
          l_return_value := SUBSTR(g_rpa_add_attr(p_assignment_id).add_county_chk,7,3);
      elsif p_input_value ='ADD_ZIPCODE_CHK' then

         l_return_value :=SUBSTR( g_rpa_add_attr(p_assignment_id).zip_cd_chk,0,5);

     elsif p_input_value ='ADD_ZIP_CD_CHK4' then
        --IF LENGTH(g_rpa_add_attr(p_assignment_id).zip_cd_chk) >=9 THEN

         l_return_value := SUBSTR(g_rpa_add_attr(p_assignment_id).zip_cd_chk
                            ,LENGTH(g_rpa_add_attr(p_assignment_id).zip_cd_chk)-3);
        --END IF;






      end if;

   end if;

   if g_debug then
      Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
      Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   end if;
      Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
      Hr_Utility.set_location('Leaving: '||l_proc_name, 80);


   return l_return_value;

exception
   when others then
   p_error_code := sqlcode;
   p_error_message := p_input_value;--sqlerrm;
   Hr_Utility.set_location('SQLERRM: '||sqlerrm, 90);
   Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);
   return l_return_value;

end Get_Address_Data;
-- =============================================================================
-- ~ Get_Elmt_Val:
-- =============================================================================
function Get_Elmt_Val
         (p_rslt_dtl_id in number
         ,p_rslt_id     in number
         ,p_rcd_id      in number
         ,p_person_id   in number
         ,p_col_name    in varchar2
         ) return varchar2 as

   type valtyp is ref cursor;
   ele_cur       valtyp;

   l_sel_stmt   varchar2(2000);
   l_elmt_value varchar2(2000);
   l_proc_name  constant varchar2(150) := g_proc_name ||'Get_Elmt_Val';

begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_sel_stmt := 'select '||p_col_name ||
                 '  from ben_ext_rslt_dtl
                  	where ext_rslt_id     = :1
                  	  and ext_rslt_dtl_id = :2
                  	  and ext_rcd_id      = :3
                  			and person_id       = :4';

   open ele_cur for l_sel_stmt
  		          using p_rslt_id
                   ,p_rslt_dtl_id
                   ,p_rcd_id
                   ,p_person_id;
  	fetch ele_cur into l_elmt_value;
  	close ele_cur;
  	Hr_Utility.set_location(' p_col_name  : '||p_col_name, 79);
	  Hr_Utility.set_location(' l_elmt_value: '||l_elmt_value, 79);
	  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
	  return l_elmt_value;

end Get_Elmt_Val;
-- =============================================================================
-- ~ Update_Record_Values :
-- =============================================================================
procedure Update_Record_Values
           (p_ext_rcd_id            in ben_ext_rcd.ext_rcd_id%type
           ,p_ext_data_element_name in ben_ext_data_elmt.name%type
           ,p_data_element_value    in ben_ext_rslt_dtl.val_01%type
           ,p_data_ele_seqnum       in number
           ,p_ext_dtl_rec           in out nocopy ben_ext_rslt_dtl%rowtype
            ) is
   cursor csr_seqnum (c_ext_rcd_id            in ben_ext_rcd.ext_rcd_id%type
                     ,c_ext_data_element_name in ben_ext_data_elmt.name%type
                      ) is
      select der.ext_data_elmt_id,
             der.seq_num,
             ede.name
        from ben_ext_data_elmt_in_rcd der
             ,ben_ext_data_elmt        ede
       where der.ext_rcd_id = c_ext_rcd_id
         and ede.ext_data_elmt_id = der.ext_data_elmt_id
         and ede.name             like '%'|| c_ext_data_element_name
       order by seq_num;

   l_seqnum_rec        csr_seqnum%rowtype;
   l_proc_name         varchar2(150):= g_proc_name||'Update_Record_Values';
   l_ext_dtl_rec_nc    ben_ext_rslt_dtl%rowtype;
begin
   Hr_Utility.set_location('Entering :'||l_proc_name, 5);
   -- nocopy changes
   l_ext_dtl_rec_nc := p_ext_dtl_rec;

   if p_data_ele_seqnum is null then
      open csr_seqnum ( c_ext_rcd_id            => p_ext_rcd_id
                       ,c_ext_data_element_name => p_ext_data_element_name);
      fetch csr_seqnum into l_seqnum_rec;
      if csr_seqnum%notfound then
         close csr_seqnum;
      else
         close csr_seqnum;
      end if;
   else
      l_seqnum_rec.seq_num := p_data_ele_seqnum;
   end if;

   if l_seqnum_rec.seq_num = 1 then
      p_ext_dtl_rec.val_01 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 2 then
      p_ext_dtl_rec.val_02 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 3 then
      p_ext_dtl_rec.val_03 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 4 then
      p_ext_dtl_rec.val_04 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 5 then
      p_ext_dtl_rec.val_05 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 6 then
      p_ext_dtl_rec.val_06 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 7 then
      p_ext_dtl_rec.val_07 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 8 then
      p_ext_dtl_rec.val_08 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 9 then
      p_ext_dtl_rec.val_09 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 10 then
      p_ext_dtl_rec.val_10 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 11 then
      p_ext_dtl_rec.val_11 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 12 then
      p_ext_dtl_rec.val_12 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 13 then
      p_ext_dtl_rec.val_13 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 14 then
      p_ext_dtl_rec.val_14 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 15 then
      p_ext_dtl_rec.val_15 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 16 then
      p_ext_dtl_rec.val_16 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 17 then
      p_ext_dtl_rec.val_17 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 18 then
      p_ext_dtl_rec.val_18 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 19 then
      p_ext_dtl_rec.val_19 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 20 then
      p_ext_dtl_rec.val_20 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 21 then
      p_ext_dtl_rec.val_21 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 22 then
      p_ext_dtl_rec.val_22 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 23then
      p_ext_dtl_rec.val_23 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 24 then
      p_ext_dtl_rec.val_24 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 25 then
      p_ext_dtl_rec.val_25 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 26 then
      p_ext_dtl_rec.val_26 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 27 then
      p_ext_dtl_rec.val_27 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 28 then
      p_ext_dtl_rec.val_28 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 29 then
      p_ext_dtl_rec.val_29 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 30 then
      p_ext_dtl_rec.val_30 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 31 then
      p_ext_dtl_rec.val_31 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 32 then
      p_ext_dtl_rec.val_32 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 33 then
      p_ext_dtl_rec.val_33 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 34 then
      p_ext_dtl_rec.val_34 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 35 then
      p_ext_dtl_rec.val_35 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 36 then
      p_ext_dtl_rec.val_36 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 37 then
      p_ext_dtl_rec.val_37 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 38 then
      p_ext_dtl_rec.val_38 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 39 then
      p_ext_dtl_rec.val_39 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 40 then
      p_ext_dtl_rec.val_40 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 41 then
      p_ext_dtl_rec.val_41 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 42 then
      p_ext_dtl_rec.val_42 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 43 then
      p_ext_dtl_rec.val_43 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 44 then
      p_ext_dtl_rec.val_44 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 45 then
      p_ext_dtl_rec.val_45 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 46 then
      p_ext_dtl_rec.val_46 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 47 then
      p_ext_dtl_rec.val_47 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 48 then
      p_ext_dtl_rec.val_48 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 49 then
      p_ext_dtl_rec.val_49 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 50 then
      p_ext_dtl_rec.val_50 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 51 then
      p_ext_dtl_rec.val_51 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 52 then
      p_ext_dtl_rec.val_52 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 53 then
      p_ext_dtl_rec.val_53 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 54 then
      p_ext_dtl_rec.val_54 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 55 then
      p_ext_dtl_rec.val_55 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 56 then
      p_ext_dtl_rec.val_56 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 57 then
      p_ext_dtl_rec.val_57 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 58 then
      p_ext_dtl_rec.val_58 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 58 then
      p_ext_dtl_rec.val_58 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 59 then
      p_ext_dtl_rec.val_59 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 60 then
      p_ext_dtl_rec.val_60 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 61 then
      p_ext_dtl_rec.val_61 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 62 then
      p_ext_dtl_rec.val_62 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 63 then
      p_ext_dtl_rec.val_63 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 64 then
      p_ext_dtl_rec.val_64 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 65 then
      p_ext_dtl_rec.val_65 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 66 then
      p_ext_dtl_rec.val_66 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 67 then
      p_ext_dtl_rec.val_67 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 68 then
      p_ext_dtl_rec.val_68 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 69 then
      p_ext_dtl_rec.val_69 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 70 then
      p_ext_dtl_rec.val_70 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 71 then
      p_ext_dtl_rec.val_71 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 72 then
      p_ext_dtl_rec.val_72 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 73 then
      p_ext_dtl_rec.val_73 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 74 then
      p_ext_dtl_rec.val_74 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 75 then
      p_ext_dtl_rec.val_75 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 76 then
      p_ext_dtl_rec.val_76 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 77 then
      p_ext_dtl_rec.val_77 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 78 then
      p_ext_dtl_rec.val_78 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 79 then
      p_ext_dtl_rec.val_79 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 80 then
      p_ext_dtl_rec.val_80 := p_data_element_value;
     elsif l_seqnum_rec.seq_num = 81 then
      p_ext_dtl_rec.val_81 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 82 then
      p_ext_dtl_rec.val_82 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 83 then
      p_ext_dtl_rec.val_83 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 84 then
      p_ext_dtl_rec.val_84 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 85 then
      p_ext_dtl_rec.val_85 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 86 then
      p_ext_dtl_rec.val_86 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 87 then
      p_ext_dtl_rec.val_87 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 88 then
      p_ext_dtl_rec.val_88 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 89 then
      p_ext_dtl_rec.val_89 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 90 then
      p_ext_dtl_rec.val_90 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 91 then
      p_ext_dtl_rec.val_91 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 92 then
      p_ext_dtl_rec.val_92 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 93 then
      p_ext_dtl_rec.val_93 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 94 then
      p_ext_dtl_rec.val_94 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 95 then
      p_ext_dtl_rec.val_95 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 96 then
      p_ext_dtl_rec.val_96 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 97 then
      p_ext_dtl_rec.val_97 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 98 then
      p_ext_dtl_rec.val_98 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 99 then
      p_ext_dtl_rec.val_99 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 100 then
      p_ext_dtl_rec.val_100 := p_data_element_value;
      elsif l_seqnum_rec.seq_num = 101 then
      p_ext_dtl_rec.val_101 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 102 then
      p_ext_dtl_rec.val_102 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 103 then
      p_ext_dtl_rec.val_103 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 104 then
      p_ext_dtl_rec.val_104 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 105 then
      p_ext_dtl_rec.val_105 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 106 then
      p_ext_dtl_rec.val_106 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 107 then
      p_ext_dtl_rec.val_107 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 108 then
      p_ext_dtl_rec.val_108 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 109 then
      p_ext_dtl_rec.val_109 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 110 then
      p_ext_dtl_rec.val_110 := p_data_element_value;
      elsif l_seqnum_rec.seq_num = 111 then
      p_ext_dtl_rec.val_111 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 112 then
      p_ext_dtl_rec.val_112 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 113 then
      p_ext_dtl_rec.val_113 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 114 then
      p_ext_dtl_rec.val_114 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 115 then
      p_ext_dtl_rec.val_115 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 116 then
      p_ext_dtl_rec.val_116 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 117 then
      p_ext_dtl_rec.val_117 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 118 then
      p_ext_dtl_rec.val_118 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 119 then
      p_ext_dtl_rec.val_119 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 120 then
      p_ext_dtl_rec.val_120 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 121 then
      p_ext_dtl_rec.val_121 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 122 then
      p_ext_dtl_rec.val_122 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 123 then
      p_ext_dtl_rec.val_123 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 124 then
      p_ext_dtl_rec.val_124 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 125 then
      p_ext_dtl_rec.val_125 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 126 then
      p_ext_dtl_rec.val_126 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 127 then
      p_ext_dtl_rec.val_127 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 128 then
      p_ext_dtl_rec.val_128 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 129 then
      p_ext_dtl_rec.val_129 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 130 then
      p_ext_dtl_rec.val_130 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 131 then
      p_ext_dtl_rec.val_131 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 132 then
      p_ext_dtl_rec.val_132 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 133 then
      p_ext_dtl_rec.val_133 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 134 then
      p_ext_dtl_rec.val_134 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 135 then
      p_ext_dtl_rec.val_135 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 136 then
      p_ext_dtl_rec.val_136 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 137 then
      p_ext_dtl_rec.val_137 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 138 then
      p_ext_dtl_rec.val_138 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 139 then
      p_ext_dtl_rec.val_139 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 140 then
      p_ext_dtl_rec.val_140 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 141 then
      p_ext_dtl_rec.val_141 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 142 then
      p_ext_dtl_rec.val_142 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 143 then
      p_ext_dtl_rec.val_143 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 144 then
      p_ext_dtl_rec.val_144 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 145 then
      p_ext_dtl_rec.val_145 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 146 then
      p_ext_dtl_rec.val_146 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 147 then
      p_ext_dtl_rec.val_147 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 148 then
      p_ext_dtl_rec.val_148 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 149 then
      p_ext_dtl_rec.val_149 := p_data_element_value;
   elsif l_seqnum_rec.seq_num = 150 then
      p_ext_dtl_rec.val_150 := p_data_element_value;
   end if;

   Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
   return;
exception
   when Others then
     -- nocopy changes
     p_ext_dtl_rec := l_ext_dtl_rec_nc;
     raise;

end Update_Record_Values;
-- =============================================================================
-- Copy_Rec_Values :
-- =============================================================================
procedure Copy_Rec_Values
          (p_rslt_rec   in ben_ext_rslt_dtl%rowtype
          ,p_val_tab    in out NOCOPY  ValTabTyp) is

  l_proc_name    varchar2(150) := g_proc_name ||'Copy_Rec_Values ';
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   p_val_tab(1) := p_rslt_rec.val_01;
   p_val_tab(2) := p_rslt_rec.val_02;
   p_val_tab(3) := p_rslt_rec.val_03;
   p_val_tab(4) := p_rslt_rec.val_04;
   p_val_tab(5) := p_rslt_rec.val_05;
   p_val_tab(6) := p_rslt_rec.val_06;
   p_val_tab(7) := p_rslt_rec.val_07;
   p_val_tab(8) := p_rslt_rec.val_08;
   p_val_tab(9) := p_rslt_rec.val_09;

   p_val_tab(10) := p_rslt_rec.val_10;
   p_val_tab(11) := p_rslt_rec.val_11;
   p_val_tab(12) := p_rslt_rec.val_12;
   p_val_tab(13) := p_rslt_rec.val_13;
   p_val_tab(14) := p_rslt_rec.val_14;
   p_val_tab(15) := p_rslt_rec.val_15;
   p_val_tab(16) := p_rslt_rec.val_16;
   p_val_tab(17) := p_rslt_rec.val_17;
   p_val_tab(18) := p_rslt_rec.val_18;
   p_val_tab(19) := p_rslt_rec.val_19;

   p_val_tab(20) := p_rslt_rec.val_20;
   p_val_tab(21) := p_rslt_rec.val_21;
   p_val_tab(22) := p_rslt_rec.val_22;
   p_val_tab(23) := p_rslt_rec.val_23;
   p_val_tab(24) := p_rslt_rec.val_24;
   p_val_tab(25) := p_rslt_rec.val_25;
   p_val_tab(26) := p_rslt_rec.val_26;
   p_val_tab(27) := p_rslt_rec.val_27;
   p_val_tab(28) := p_rslt_rec.val_28;
   p_val_tab(29) := p_rslt_rec.val_29;

   p_val_tab(30) := p_rslt_rec.val_30;
   p_val_tab(31) := p_rslt_rec.val_31;
   p_val_tab(32) := p_rslt_rec.val_32;
   p_val_tab(33) := p_rslt_rec.val_33;
   p_val_tab(34) := p_rslt_rec.val_34;
   p_val_tab(35) := p_rslt_rec.val_35;
   p_val_tab(36) := p_rslt_rec.val_36;
   p_val_tab(37) := p_rslt_rec.val_37;
   p_val_tab(38) := p_rslt_rec.val_38;
   p_val_tab(39) := p_rslt_rec.val_39;

   p_val_tab(40) := p_rslt_rec.val_40;
   p_val_tab(41) := p_rslt_rec.val_41;
   p_val_tab(42) := p_rslt_rec.val_42;
   p_val_tab(43) := p_rslt_rec.val_43;
   p_val_tab(44) := p_rslt_rec.val_44;
   p_val_tab(45) := p_rslt_rec.val_45;
   p_val_tab(46) := p_rslt_rec.val_46;
   p_val_tab(47) := p_rslt_rec.val_47;
   p_val_tab(48) := p_rslt_rec.val_48;
   p_val_tab(49) := p_rslt_rec.val_49;

   p_val_tab(50) := p_rslt_rec.val_50;
   p_val_tab(51) := p_rslt_rec.val_51;
   p_val_tab(52) := p_rslt_rec.val_52;
   p_val_tab(53) := p_rslt_rec.val_53;
   p_val_tab(54) := p_rslt_rec.val_54;
   p_val_tab(55) := p_rslt_rec.val_55;
   p_val_tab(56) := p_rslt_rec.val_56;
   p_val_tab(57) := p_rslt_rec.val_57;
   p_val_tab(58) := p_rslt_rec.val_58;
   p_val_tab(59) := p_rslt_rec.val_59;

   p_val_tab(60) := p_rslt_rec.val_60;
   p_val_tab(61) := p_rslt_rec.val_61;
   p_val_tab(62) := p_rslt_rec.val_62;
   p_val_tab(63) := p_rslt_rec.val_63;
   p_val_tab(64) := p_rslt_rec.val_64;
   p_val_tab(65) := p_rslt_rec.val_65;
   p_val_tab(66) := p_rslt_rec.val_66;
   p_val_tab(67) := p_rslt_rec.val_67;
   p_val_tab(68) := p_rslt_rec.val_68;
   p_val_tab(69) := p_rslt_rec.val_69;

   p_val_tab(70) := p_rslt_rec.val_70;
   p_val_tab(71) := p_rslt_rec.val_71;
   p_val_tab(72) := p_rslt_rec.val_72;
   p_val_tab(73) := p_rslt_rec.val_73;
   p_val_tab(74) := p_rslt_rec.val_74;
   p_val_tab(75) := p_rslt_rec.val_75;

   p_val_tab(76) := p_rslt_rec.val_76;
   p_val_tab(77) := p_rslt_rec.val_77;
   p_val_tab(78) := p_rslt_rec.val_78;
   p_val_tab(79) := p_rslt_rec.val_79;
   p_val_tab(80) := p_rslt_rec.val_80;

   p_val_tab(81) := p_rslt_rec.val_81;
   p_val_tab(82) := p_rslt_rec.val_82;
   p_val_tab(83) := p_rslt_rec.val_83;
   p_val_tab(84) := p_rslt_rec.val_84;
   p_val_tab(85) := p_rslt_rec.val_85;

   p_val_tab(86) := p_rslt_rec.val_86;
   p_val_tab(87) := p_rslt_rec.val_87;
   p_val_tab(88) := p_rslt_rec.val_88;
   p_val_tab(89) := p_rslt_rec.val_89;
   p_val_tab(90) := p_rslt_rec.val_90;

   p_val_tab(91) := p_rslt_rec.val_91;
   p_val_tab(92) := p_rslt_rec.val_92;
   p_val_tab(93) := p_rslt_rec.val_93;
   p_val_tab(94) := p_rslt_rec.val_94;
   p_val_tab(95) := p_rslt_rec.val_95;

   p_val_tab(96) := p_rslt_rec.val_96;
   p_val_tab(97) := p_rslt_rec.val_97;
   p_val_tab(98) := p_rslt_rec.val_98;
   p_val_tab(99) := p_rslt_rec.val_99;
   p_val_tab(100) := p_rslt_rec.val_100;

   p_val_tab(101) := p_rslt_rec.val_101;
   p_val_tab(102) := p_rslt_rec.val_102;
   p_val_tab(103) := p_rslt_rec.val_103;
   p_val_tab(104) := p_rslt_rec.val_104;
   p_val_tab(105) := p_rslt_rec.val_105;

   p_val_tab(106) := p_rslt_rec.val_106;
   p_val_tab(107) := p_rslt_rec.val_107;
   p_val_tab(108) := p_rslt_rec.val_108;
   p_val_tab(109) := p_rslt_rec.val_109;
   p_val_tab(110) := p_rslt_rec.val_110;

   p_val_tab(111) := p_rslt_rec.val_111;
   p_val_tab(112) := p_rslt_rec.val_112;
   p_val_tab(113) := p_rslt_rec.val_113;
   p_val_tab(114) := p_rslt_rec.val_114;
   p_val_tab(115) := p_rslt_rec.val_115;

   p_val_tab(116) := p_rslt_rec.val_116;
   p_val_tab(117) := p_rslt_rec.val_117;
   p_val_tab(118) := p_rslt_rec.val_118;
   p_val_tab(119) := p_rslt_rec.val_119;
   p_val_tab(120) := p_rslt_rec.val_120;

   p_val_tab(121) := p_rslt_rec.val_121;
   p_val_tab(122) := p_rslt_rec.val_122;
   p_val_tab(123) := p_rslt_rec.val_123;
   p_val_tab(124) := p_rslt_rec.val_124;
   p_val_tab(125) := p_rslt_rec.val_125;

   p_val_tab(126) := p_rslt_rec.val_126;
   p_val_tab(127) := p_rslt_rec.val_127;
   p_val_tab(128) := p_rslt_rec.val_128;
   p_val_tab(129) := p_rslt_rec.val_129;
   p_val_tab(130) := p_rslt_rec.val_130;

   p_val_tab(131) := p_rslt_rec.val_131;
   p_val_tab(132) := p_rslt_rec.val_132;
   p_val_tab(133) := p_rslt_rec.val_133;
   p_val_tab(134) := p_rslt_rec.val_134;
   p_val_tab(135) := p_rslt_rec.val_135;

   p_val_tab(136) := p_rslt_rec.val_136;
   p_val_tab(137) := p_rslt_rec.val_137;
   p_val_tab(138) := p_rslt_rec.val_138;
   p_val_tab(139) := p_rslt_rec.val_139;
   p_val_tab(140) := p_rslt_rec.val_140;

   p_val_tab(141) := p_rslt_rec.val_141;
   p_val_tab(142) := p_rslt_rec.val_142;
   p_val_tab(143) := p_rslt_rec.val_143;
   p_val_tab(144) := p_rslt_rec.val_144;
   p_val_tab(145) := p_rslt_rec.val_145;

   p_val_tab(146) := p_rslt_rec.val_146;
   p_val_tab(147) := p_rslt_rec.val_147;
   p_val_tab(148) := p_rslt_rec.val_148;
   p_val_tab(149) := p_rslt_rec.val_149;
   p_val_tab(150) := p_rslt_rec.val_150;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 15);

end Copy_Rec_Values;
-- =============================================================================
-- Data_Elmt_In_Rcd:
-- =============================================================================
procedure Data_Elmt_In_Rcd
          (p_ext_rcd_id            in number
          ,p_val_tab               in out NOCOPY ValTabTyp
          ,p_exclude_this_rcd_flag out NOCOPY boolean
          ,p_raise_warning         out NOCOPY boolean
          ,p_rollback_person       out NOCOPY boolean) is
  --
  cursor c_xer(p_ext_rcd_id in number) is
  select xer.seq_num,
         xer.sprs_cd,
         xer.ext_data_elmt_in_rcd_id,
         xdm.name
   from  ben_ext_data_elmt_in_rcd xer,
         ben_ext_data_elmt        xdm
   where ext_rcd_id           = p_ext_rcd_id
     and xer.sprs_cd is not null
     and xer.ext_data_elmt_id = xdm.ext_data_elmt_id ;
  --
  cursor c_xwc(p_ext_data_elmt_in_rcd_id in number)  is
  select xwc.oper_cd,
         xwc.val,
         xwc.and_or_cd,
         xer.seq_num
   from ben_ext_where_clause     xwc,
        ben_ext_data_elmt_in_rcd xer
  where xwc.ext_data_elmt_in_rcd_id      = p_ext_data_elmt_in_rcd_id
    and xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
    order by xwc.seq_num;
  --
  l_proc                 varchar2(72) := g_proc_name||'Data_Elmt_In_Rcd';
  l_condition            varchar2(1);
  l_cnt                  number;
  l_value_without_quotes varchar2(500);
  l_dynamic_condition    varchar2(9999);
  --
  l_val_tab_mirror       ValTabTyp;
begin
  Hr_Utility.set_location('Entering'||l_proc, 5);
  p_exclude_this_rcd_flag := false;
  p_raise_warning         := false;
  p_rollback_person       := false;
  -- Make mirror image of table for evaluation, since values in
  -- the real table are changing (being nullified).
  l_val_tab_mirror := p_val_tab;
  --
  for xer in c_xer(p_ext_rcd_id) loop
  --
  l_cnt := 0;
  l_dynamic_condition := 'begin If ';
  for xwc in c_xwc(xer.ext_data_elmt_in_rcd_id) loop
     l_cnt := l_cnt +1;
      -- strip all quotes out of any values.
      l_value_without_quotes := REPLACE(l_val_tab_mirror(xwc.seq_num),'''');
      l_dynamic_condition := l_dynamic_condition    || '''' ||
                             l_value_without_quotes || '''' ||   ' ' ||
                             xwc.oper_cd || ' ' ||
                             xwc.val || ' ' ||
                             xwc.and_or_cd || ' ';
  end loop;-- FOR xwc IN c_xwc

  -- If there is no data for advanced conditions, bypass rest of this program.
  if l_cnt > 0 then
       l_dynamic_condition := l_dynamic_condition ||
         ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
    begin
        execute immediate l_dynamic_condition Using out l_condition;
    exception
    when Others then
      -- this needs replaced with a message for translation.
      Fnd_File.put_line(Fnd_File.Log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      Fnd_File.put_line(Fnd_File.Log, l_dynamic_condition);
      raise;  -- such that the error processing in ben_ext_thread occurs.
    end;
    --
    if l_condition = 'T' then
       if xer.sprs_cd = 'A' then
       -- Rollback Record
          p_exclude_this_rcd_flag := true;
          exit;
       elsif xer.sprs_cd = 'B' then
       -- Rollback Person
          p_exclude_this_rcd_flag := true;
          p_rollback_person       := true;
       elsif xer.sprs_cd = 'C' then
          -- Rollback person and error
          p_exclude_this_rcd_flag := true;
          p_rollback_person       := true;
       elsif xer.sprs_cd = 'G' then
          -- Nullify Data Element
          p_val_tab(xer.seq_num) := null;
       elsif xer.sprs_cd = 'H' then
          -- Signal Warning
          p_raise_warning         := false;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.name);
       elsif xer.sprs_cd = 'I' then
          -- Nullify Data Element and Signal Warning
          p_val_tab(xer.seq_num) := null;
          p_raise_warning        := false;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                        ,92313
                        ,xer.name);
       end if; --IF xer.sprs_cd = 'A'

   else -- l_condition = 'F'
       if xer.sprs_cd = 'D' then
          -- Rollback record
          p_exclude_this_rcd_flag := true;
          exit;
       elsif xer.sprs_cd = 'E' then
          -- Rollback person
          p_exclude_this_rcd_flag := true;
          p_rollback_person       := true;
       elsif xer.sprs_cd = 'F' then
          -- Rollback person and error
          p_exclude_this_rcd_flag := true;
          p_rollback_person       := true;
       elsif xer.sprs_cd = 'J' then
          -- Nullify data element
          p_val_tab(xer.seq_num) := null;
       elsif xer.sprs_cd = 'K' then
          -- Signal warning
          p_raise_warning := false;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.name);
       elsif xer.sprs_cd = 'L' then
          -- Nullify data element and signal warning
          p_val_tab(xer.seq_num) := null;
          p_raise_warning        := false;
          Write_Warning ('BEN_92313_EXT_USER_DEFINED_WRN'
                         ,92313
                         ,xer.name);
       end if; --IF xer.sprs_cd = 'D'
    --
    end if; -- IF l_condition = 'T'
  --
  end if;-- IF l_cnt > 0 THEN
  --
 end loop; -- FOR xer IN c_xer
--
Hr_Utility.set_location('Exiting'||l_proc, 15);
--
end Data_Elmt_In_Rcd;

-- =============================================================================
-- Rcd_In_File:
-- =============================================================================
procedure Rcd_In_File
          (p_ext_rcd_in_file_id    in number
          ,p_sprs_cd               in varchar2
          ,p_val_tab               in out NOCOPY ValTabTyp
          ,p_exclude_this_rcd_flag out NOCOPY boolean
          ,p_raise_warning         out NOCOPY boolean
          ,p_rollback_person       out NOCOPY boolean) is

  cursor c_xwc(p_ext_rcd_in_file_id in number)  is
  select xwc.oper_cd,
         xwc.val,
         xwc.and_or_cd,
         xer.seq_num,
         xrc.name,
         Substr(xel.frmt_mask_cd,1,1) xel_frmt_mask_cd,
         xel.data_elmt_typ_cd,
         xel.data_elmt_rl,
         xel.ext_fld_id,
         fld.frmt_mask_typ_cd
    from ben_ext_where_clause     xwc,
         ben_ext_data_elmt_in_rcd xer,
         ben_ext_rcd              xrc,
         ben_ext_data_elmt        xel,
         ben_ext_fld              fld
   where xwc.ext_rcd_in_file_id           = p_ext_rcd_in_file_id
     and xwc.cond_ext_data_elmt_in_rcd_id = xer.ext_data_elmt_in_rcd_id
     and xer.ext_rcd_id                   = xrc.ext_rcd_id
     and xel.ext_data_elmt_id             = xer.ext_data_elmt_id
     and xel.ext_fld_id                   = fld.ext_fld_id(+)
     order by xwc.seq_num;
   --
   l_proc                 varchar2(72) := g_proc_name||'Rcd_In_File';
   l_condition            varchar2(1);
   l_cnt                  number;
   l_value_without_quotes varchar2(500);
   l_dynamic_condition    varchar2(9999);
   l_rcd_name             ben_ext_rcd.name%type ;
   --
    --
begin
  --
  Hr_Utility.set_location('Entering'||l_proc, 5);
  --
  p_exclude_this_rcd_flag := false;
  p_raise_warning         := false;
  p_rollback_person       := false;
  if p_sprs_cd = null then
     return;
  end if;
  --
  l_cnt := 0;
  l_dynamic_condition := 'begin If ';
  for xwc in c_xwc(p_ext_rcd_in_file_id) loop
    l_cnt := l_cnt +1;
    -- Strip all quotes out of any values.
    l_value_without_quotes := REPLACE(p_val_tab(xwc.seq_num),'''');
    --
    if (xwc.frmt_mask_typ_cd = 'N' or
        xwc.xel_frmt_mask_cd = 'N' or
        xwc.data_elmt_typ_cd = 'R')
       and
       l_value_without_quotes is not null
    then
       begin
          --  Test for numeric value
          if xwc.oper_cd = 'IN' then
             l_dynamic_condition := l_dynamic_condition ||''''||
                                  l_value_without_quotes||'''';
          else
             l_dynamic_condition := l_dynamic_condition ||
                           To_Number(l_value_without_quotes);
          end if;

       exception when Others then
          -- Quotes needed, not numeric value
         l_dynamic_condition := l_dynamic_condition || '''' ||
                       l_value_without_quotes|| '''';
       end;
    else
      -- Quotes needed, not Numeric value
      l_dynamic_condition := l_dynamic_condition || '''' ||
                           l_value_without_quotes|| '''';
    end if;

    l_dynamic_condition := l_dynamic_condition || ' ' || xwc.oper_cd   ||
                                                  ' ' || xwc.val       ||
                                                  ' ' || xwc.and_or_cd ||
                                                  ' ';

    l_rcd_name := xwc.name ;
  end loop;
  -- if there is no data for advanced conditions, exit this program.
  if l_cnt = 0 then
    return;
  end if;
  l_dynamic_condition := l_dynamic_condition ||
         ' then :l_condition := ''T''; else :l_condition := ''F''; end if; end;';
  begin
    execute immediate l_dynamic_condition Using out l_condition;
    exception
    when Others then
      Fnd_File.put_line(Fnd_File.Log,
        'Error in Advanced Conditions while processing this dynamic sql statement: ');
      Fnd_File.put_line(Fnd_File.Log, l_dynamic_condition);
      raise;  -- such that the error processing in ben_ext_thread occurs.
  end;
  --
  if l_condition = 'T' then
    if p_sprs_cd = 'A' then
      -- Rollback Record
      p_exclude_this_rcd_flag := true;
    elsif p_sprs_cd = 'B' then
      -- Rollback Person
      p_exclude_this_rcd_flag := true;
      p_rollback_person       := true;
    elsif p_sprs_cd = 'C' then
      -- Rollback Person and Error
      p_exclude_this_rcd_flag := true;
      p_rollback_person       := true;

      Write_Error
      (p_err_name  => 'BEN_92679_EXT_USER_DEFINED_ERR'
      ,p_err_no    => 92679
      ,p_element   => l_rcd_name);

    elsif p_sprs_cd = 'H' then
      -- Signal Warning
      p_raise_warning := true;

      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
              ,92678
       ,l_rcd_name);

    elsif p_sprs_cd = 'M' then
      -- Rollback Record and Signal Warning
      p_raise_warning := true;

      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
                     ,92678
                     ,l_rcd_name);

      p_exclude_this_rcd_flag := true;
    end if; -- IF p_sprs_cd = 'A'

  else -- l_condition = 'F'

    if p_sprs_cd = 'D' then
      -- Rollback Record
      p_exclude_this_rcd_flag := true;
    elsif p_sprs_cd = 'E' then
      -- Rollback Person
      p_exclude_this_rcd_flag := true;
      p_rollback_person       := true;
    elsif p_sprs_cd = 'F' then
      -- Rollback Person and Error
      p_exclude_this_rcd_flag := true;
      p_rollback_person       := true;

      Write_Error
      (p_err_name  => 'BEN_92679_EXT_USER_DEFINED_ERR'
      ,p_err_no    => 92679
      ,p_element   => l_rcd_name);

    elsif p_sprs_cd = 'K' then
      -- Signal Warning
      p_raise_warning := true;
      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
              ,92678
       ,l_rcd_name);
    elsif p_sprs_cd = 'N' then
       -- Rollback Record and Signal warning
      Write_Warning ('BEN_92678_EXT_USER_DEFINED_WRN'
                     ,92678
                     ,l_rcd_name);
      p_raise_warning         := true;
      p_exclude_this_rcd_flag := true;
    end if; -- IF p_sprs_cd = 'D'
  --
  end if; -- IF l_condition = 'T'
  --
  Hr_Utility.set_location('Exiting'||l_proc, 15);
  --
end Rcd_In_File;
-- =============================================================================
-- ~ Ins_Rslt_Dtl : Inserts a record into the results detail record.
-- =============================================================================
procedure Ins_Rslt_Dtl
          (p_dtl_rec     in out NOCOPY ben_ext_rslt_dtl%rowtype
          ,p_val_tab     in ValTabTyp
          ,p_rslt_dtl_id out NOCOPY number
          ) is

  l_proc_name   varchar2(150) := g_proc_name||'Ins_Rslt_Dtl';
  l_dtl_rec_nc  ben_ext_rslt_dtl%rowtype;

begin -- ins_rslt_dtl
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;
  -- Get the next sequence NUMBER to insert a record into the table
  select ben_ext_rslt_dtl_s.nextval into p_dtl_rec.ext_rslt_dtl_id from dual;
  insert into ben_ext_rslt_dtl
  (ext_rslt_dtl_id
  ,ext_rslt_id
  ,business_group_id
  ,ext_rcd_id
  ,person_id
  ,val_01
  ,val_02
  ,val_03
  ,val_04
  ,val_05
  ,val_06
  ,val_07
  ,val_08
  ,val_09
  ,val_10
  ,val_11
  ,val_12
  ,val_13
  ,val_14
  ,val_15
  ,val_16
  ,val_17
  ,val_19
  ,val_18
  ,val_20
  ,val_21
  ,val_22
  ,val_23
  ,val_24
  ,val_25
  ,val_26
  ,val_27
  ,val_28
  ,val_29
  ,val_30
  ,val_31
  ,val_32
  ,val_33
  ,val_34
  ,val_35
  ,val_36
  ,val_37
  ,val_38
  ,val_39
  ,val_40
  ,val_41
  ,val_42
  ,val_43
  ,val_44
  ,val_45
  ,val_46
  ,val_47
  ,val_48
  ,val_49
  ,val_50
  ,val_51
  ,val_52
  ,val_53
  ,val_54
  ,val_55
  ,val_56
  ,val_57
  ,val_58
  ,val_59
  ,val_60
  ,val_61
  ,val_62
  ,val_63
  ,val_64
  ,val_65
  ,val_66
  ,val_67
  ,val_68
  ,val_69
  ,val_70
  ,val_71
  ,val_72
  ,val_73
  ,val_74
  ,val_75
  ,val_76
  ,val_77
  ,val_78
  ,val_79
  ,val_80
  ,val_81
  ,val_82
  ,val_83
  ,val_84
  ,val_85
  ,val_86
  ,val_87
  ,val_88
  ,val_89
  ,val_90
  ,val_91
  ,val_92
  ,val_93
  ,val_94
  ,val_95
  ,val_96
  ,val_97
  ,val_98
  ,val_99
  ,val_100
  ,val_101
  ,val_102
  ,val_103
  ,val_104
  ,val_105
  ,val_106
  ,val_107
  ,val_108
  ,val_109
  ,val_110
  ,val_111
  ,val_112
  ,val_113
  ,val_114
  ,val_115
  ,val_116
  ,val_117
  ,val_118
  ,val_119
  ,val_120
  ,val_121
  ,val_122
  ,val_123
  ,val_124
  ,val_125
  ,val_126
  ,val_127
  ,val_128
  ,val_129
  ,val_130
  ,val_131
  ,val_132
  ,val_133
  ,val_134
  ,val_135
  ,val_136
  ,val_137
  ,val_138
  ,val_139
  ,val_140
  ,val_141
  ,val_142
  ,val_143
  ,val_144
  ,val_145
  ,val_146
  ,val_147
  ,val_148
  ,val_149
  ,val_150
  ,created_by
  ,creation_date
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,program_application_id
  ,program_id
  ,program_update_date
  ,request_id
  ,object_version_number
  ,prmy_sort_val
  ,scnd_sort_val
  ,thrd_sort_val
  ,trans_seq_num
  ,rcrd_seq_num
  )
  values
  (p_dtl_rec.ext_rslt_dtl_id
  ,p_dtl_rec.ext_rslt_id
  ,p_dtl_rec.business_group_id
  ,p_dtl_rec.ext_rcd_id
  ,p_dtl_rec.person_id
  ,p_val_tab(1)
  ,p_val_tab(2)
  ,p_val_tab(3)
  ,p_val_tab(4)
  ,p_val_tab(5)
  ,p_val_tab(6)
  ,p_val_tab(7)
  ,p_val_tab(8)
  ,p_val_tab(9)
  ,p_val_tab(10)
  ,p_val_tab(11)
  ,p_val_tab(12)
  ,p_val_tab(13)
  ,p_val_tab(14)
  ,p_val_tab(15)
  ,p_val_tab(16)
  ,p_val_tab(17)
  ,p_val_tab(19)
  ,p_val_tab(18)
  ,p_val_tab(20)
  ,p_val_tab(21)
  ,p_val_tab(22)
  ,p_val_tab(23)
  ,p_val_tab(24)
  ,p_val_tab(25)
  ,p_val_tab(26)
  ,p_val_tab(27)
  ,p_val_tab(28)
  ,p_val_tab(29)
  ,p_val_tab(30)
  ,p_val_tab(31)
  ,p_val_tab(32)
  ,p_val_tab(33)
  ,p_val_tab(34)
  ,p_val_tab(35)
  ,p_val_tab(36)
  ,p_val_tab(37)
  ,p_val_tab(38)
  ,p_val_tab(39)
  ,p_val_tab(40)
  ,p_val_tab(41)
  ,p_val_tab(42)
  ,p_val_tab(43)
  ,p_val_tab(44)
  ,p_val_tab(45)
  ,p_val_tab(46)
  ,p_val_tab(47)
  ,p_val_tab(48)
  ,p_val_tab(49)
  ,p_val_tab(50)
  ,p_val_tab(51)
  ,p_val_tab(52)
  ,p_val_tab(53)
  ,p_val_tab(54)
  ,p_val_tab(55)
  ,p_val_tab(56)
  ,p_val_tab(57)
  ,p_val_tab(58)
  ,p_val_tab(59)
  ,p_val_tab(60)
  ,p_val_tab(61)
  ,p_val_tab(62)
  ,p_val_tab(63)
  ,p_val_tab(64)
  ,p_val_tab(65)
  ,p_val_tab(66)
  ,p_val_tab(67)
  ,p_val_tab(68)
  ,p_val_tab(69)
  ,p_val_tab(70)
  ,p_val_tab(71)
  ,p_val_tab(72)
  ,p_val_tab(73)
  ,p_val_tab(74)
  ,p_val_tab(75)
  ,p_val_tab(76)
  ,p_val_tab(77)
  ,p_val_tab(78)
  ,p_val_tab(79)
  ,p_val_tab(80)
  ,p_val_tab(81)
  ,p_val_tab(82)
  ,p_val_tab(83)
  ,p_val_tab(84)
  ,p_val_tab(85)
  ,p_val_tab(86)
  ,p_val_tab(87)
  ,p_val_tab(88)
  ,p_val_tab(89)
  ,p_val_tab(90)
  ,p_val_tab(91)
  ,p_val_tab(92)
  ,p_val_tab(93)
  ,p_val_tab(94)
  ,p_val_tab(95)
  ,p_val_tab(96)
  ,p_val_tab(97)
  ,p_val_tab(98)
  ,p_val_tab(99)
  ,p_val_tab(100)
  ,p_val_tab(101)
  ,p_val_tab(102)
  ,p_val_tab(103)
  ,p_val_tab(104)
  ,p_val_tab(105)
  ,p_val_tab(106)
  ,p_val_tab(107)
  ,p_val_tab(108)
  ,p_val_tab(109)
  ,p_val_tab(110)
  ,p_val_tab(111)
  ,p_val_tab(112)
  ,p_val_tab(113)
  ,p_val_tab(114)
  ,p_val_tab(115)
  ,p_val_tab(116)
  ,p_val_tab(117)
  ,p_val_tab(118)
  ,p_val_tab(119)
  ,p_val_tab(120)
  ,p_val_tab(121)
  ,p_val_tab(122)
  ,p_val_tab(123)
  ,p_val_tab(124)
  ,p_val_tab(125)
  ,p_val_tab(126)
  ,p_val_tab(127)
  ,p_val_tab(128)
  ,p_val_tab(129)
  ,p_val_tab(130)
  ,p_val_tab(131)
  ,p_val_tab(132)
  ,p_val_tab(133)
  ,p_val_tab(134)
  ,p_val_tab(135)
  ,p_val_tab(136)
  ,p_val_tab(137)
  ,p_val_tab(138)
  ,p_val_tab(139)
  ,p_val_tab(140)
  ,p_val_tab(141)
  ,p_val_tab(142)
  ,p_val_tab(143)
  ,p_val_tab(144)
  ,p_val_tab(145)
  ,p_val_tab(146)
  ,p_val_tab(147)
  ,p_val_tab(148)
  ,p_val_tab(149)
  ,p_val_tab(150)
  ,p_dtl_rec.created_by
  ,p_dtl_rec.creation_date
  ,p_dtl_rec.last_update_date
  ,p_dtl_rec.last_updated_by
  ,p_dtl_rec.last_update_login
  ,p_dtl_rec.program_application_id
  ,p_dtl_rec.program_id
  ,p_dtl_rec.program_update_date
  ,p_dtl_rec.request_id
  ,p_dtl_rec.object_version_number
  ,p_dtl_rec.prmy_sort_val
  ,p_dtl_rec.scnd_sort_val
  ,p_dtl_rec.thrd_sort_val
  ,p_dtl_rec.trans_seq_num
  ,p_dtl_rec.rcrd_seq_num
  );
  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  return;

exception
  when Others then
    Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
    p_dtl_rec := l_dtl_rec_nc;
    raise;
end Ins_Rslt_Dtl;
-- =============================================================================
-- ~Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- =============================================================================
procedure Upd_Rslt_Dtl
           (p_dtl_rec     in ben_ext_rslt_dtl%rowtype
           ,p_val_tab     in ValTabTyp ) is

  l_proc_name varchar2(150):= g_proc_name||'upd_rslt_dtl';

begin -- Upd_Rslt_Dtl
  update ben_ext_rslt_dtl
  set val_01                 = p_val_tab(1)
     ,val_02                 = p_val_tab(2)
     ,val_03                 = p_val_tab(3)
     ,val_04                 = p_val_tab(4)
     ,val_05                 = p_val_tab(5)
     ,val_06                 = p_val_tab(6)
     ,val_07                 = p_val_tab(7)
     ,val_08                 = p_val_tab(8)
     ,val_09                 = p_val_tab(9)
     ,val_10                 = p_val_tab(10)
     ,val_11                 = p_val_tab(11)
     ,val_12                 = p_val_tab(12)
     ,val_13                 = p_val_tab(13)
     ,val_14                 = p_val_tab(14)
     ,val_15                 = p_val_tab(15)
     ,val_16                 = p_val_tab(16)
     ,val_17                 = p_val_tab(17)
     ,val_19                 = p_val_tab(19)
     ,val_18                 = p_val_tab(18)
     ,val_20                 = p_val_tab(20)
     ,val_21                 = p_val_tab(21)
     ,val_22                 = p_val_tab(22)
     ,val_23                 = p_val_tab(23)
     ,val_24                 = p_val_tab(24)
     ,val_25                 = p_val_tab(25)
     ,val_26                 = p_val_tab(26)
     ,val_27                 = p_val_tab(27)
     ,val_28                 = p_val_tab(28)
     ,val_29                 = p_val_tab(29)
     ,val_30                 = p_val_tab(30)
     ,val_31                 = p_val_tab(31)
     ,val_32                 = p_val_tab(32)
     ,val_33                 = p_val_tab(33)
     ,val_34                 = p_val_tab(34)
     ,val_35                 = p_val_tab(35)
     ,val_36                 = p_val_tab(36)
     ,val_37                 = p_val_tab(37)
     ,val_38                 = p_val_tab(38)
     ,val_39                 = p_val_tab(39)
     ,val_40                 = p_val_tab(40)
     ,val_41                 = p_val_tab(41)
     ,val_42                 = p_val_tab(42)
     ,val_43                 = p_val_tab(43)
     ,val_44                 = p_val_tab(44)
     ,val_45                 = p_val_tab(45)
     ,val_46                 = p_val_tab(46)
     ,val_47                 = p_val_tab(47)
     ,val_48                 = p_val_tab(48)
     ,val_49                 = p_val_tab(49)
     ,val_50                 = p_val_tab(50)
     ,val_51                 = p_val_tab(51)
     ,val_52                 = p_val_tab(52)
     ,val_53                 = p_val_tab(53)
     ,val_54                 = p_val_tab(54)
     ,val_55                 = p_val_tab(55)
     ,val_56                 = p_val_tab(56)
     ,val_57                 = p_val_tab(57)
     ,val_58                 = p_val_tab(58)
     ,val_59                 = p_val_tab(59)
     ,val_60                 = p_val_tab(60)
     ,val_61                 = p_val_tab(61)
     ,val_62                 = p_val_tab(62)
     ,val_63                 = p_val_tab(63)
     ,val_64                 = p_val_tab(64)
     ,val_65                 = p_val_tab(65)
     ,val_66                 = p_val_tab(66)
     ,val_67                 = p_val_tab(67)
     ,val_68                 = p_val_tab(68)
     ,val_69                 = p_val_tab(69)
     ,val_70                 = p_val_tab(70)
     ,val_71                 = p_val_tab(71)
     ,val_72                 = p_val_tab(72)
     ,val_73                 = p_val_tab(73)
     ,val_74                 = p_val_tab(74)
     ,val_75                 = p_val_tab(75)
     ,val_76                 = p_val_tab(76)
     ,val_77                 = p_val_tab(77)
     ,val_78                 = p_val_tab(78)
     ,val_79                 = p_val_tab(79)
     ,val_80                 = p_val_tab(80)
     ,val_81                 = p_val_tab(81)
     ,val_82                 = p_val_tab(82)
     ,val_83                 = p_val_tab(83)
     ,val_84                 = p_val_tab(84)
     ,val_85                 = p_val_tab(85)
     ,val_86                 = p_val_tab(86)
     ,val_87                 = p_val_tab(87)
     ,val_88                 = p_val_tab(88)
     ,val_89                 = p_val_tab(89)
     ,val_90                 = p_val_tab(90)
     ,val_91                 = p_val_tab(91)
     ,val_92                 = p_val_tab(92)
     ,val_93                 = p_val_tab(93)
     ,val_94                 = p_val_tab(94)
     ,val_95                 = p_val_tab(95)
     ,val_96                 = p_val_tab(96)
     ,val_97                 = p_val_tab(97)
     ,val_98                 = p_val_tab(98)
     ,val_99                 = p_val_tab(99)
     ,val_100                = p_val_tab(100)
     ,val_101                = p_val_tab(101)
     ,val_102                = p_val_tab(102)
     ,val_103                = p_val_tab(103)
     ,val_104                = p_val_tab(104)
     ,val_105                = p_val_tab(105)
     ,val_106                = p_val_tab(106)
     ,val_107                = p_val_tab(107)
     ,val_108                = p_val_tab(108)
     ,val_109                = p_val_tab(109)
     ,val_110                = p_val_tab(110)
     ,val_111                = p_val_tab(111)
     ,val_112                = p_val_tab(112)
     ,val_113                = p_val_tab(113)
     ,val_114                = p_val_tab(114)
     ,val_115                = p_val_tab(115)
     ,val_116                = p_val_tab(116)
     ,val_117                = p_val_tab(117)
     ,val_118                = p_val_tab(118)
     ,val_119                = p_val_tab(119)
     ,val_120                = p_val_tab(120)
     ,val_121                = p_val_tab(121)
     ,val_122                = p_val_tab(122)
     ,val_123                = p_val_tab(123)
     ,val_124                = p_val_tab(124)
     ,val_125                = p_val_tab(125)
     ,val_126                = p_val_tab(126)
     ,val_127                = p_val_tab(127)
     ,val_128                = p_val_tab(128)
     ,val_129                = p_val_tab(129)
     ,val_130                = p_val_tab(130)
     ,val_131                = p_val_tab(131)
     ,val_132                = p_val_tab(132)
     ,val_133                = p_val_tab(133)
     ,val_134                = p_val_tab(134)
     ,val_135                = p_val_tab(135)
     ,val_136                = p_val_tab(136)
     ,val_137                = p_val_tab(137)
     ,val_138                = p_val_tab(138)
     ,val_139                = p_val_tab(139)
     ,val_140                = p_val_tab(140)
     ,val_141                = p_val_tab(141)
     ,val_142                = p_val_tab(142)
     ,val_143                = p_val_tab(143)
     ,val_144                = p_val_tab(144)
     ,val_145                = p_val_tab(145)
     ,val_146                = p_val_tab(146)
     ,val_147                = p_val_tab(147)
     ,val_148                = p_val_tab(148)
     ,val_149                = p_val_tab(149)
     ,val_150                = p_val_tab(150)
     ,object_version_number  = p_dtl_rec.object_version_number
     ,thrd_sort_val          = p_dtl_rec.thrd_sort_val
  where ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  return;

exception
  when Others then
  raise;
end Upd_Rslt_Dtl;
-- =============================================================================
-- Process_Ext_Rslt_Dtl_Rec:
-- =============================================================================
procedure  Process_Ext_Rslt_Dtl_Rec
          (p_assignment_id    in number
          ,p_organization_id  in number
          ,p_effective_date   in date
          ,p_ext_rcd_id       in number
          ,p_rslt_rec         in out nocopy ben_ext_rslt_dtl%rowtype
          ,p_total_lines      in out nocopy number
          ,p_error_code       out nocopy varchar2
          ,p_error_message    out nocopy varchar2) is

   cursor csr_rule_ele(c_ext_rcd_id  in number) is
   select  a.ext_data_elmt_in_rcd_id
          ,a.seq_num
          ,a.sprs_cd
          ,a.strt_pos
          ,a.dlmtr_val
          ,a.rqd_flag
          ,b.ext_data_elmt_id
          ,b.data_elmt_typ_cd
          ,b.data_elmt_rl
          ,b.name
          ,Hr_General.decode_lookup('BEN_EXT_FRMT_MASK',
                                     b.frmt_mask_cd) frmt_mask_cd
          ,b.frmt_mask_cd frmt_mask_lookup_cd
          ,b.string_val
          ,b.dflt_val
          ,b.max_length_num
          ,b.just_cd
     from  ben_ext_data_elmt           b,
           ben_ext_data_elmt_in_rcd    a
     where a.ext_data_elmt_id = b.ext_data_elmt_id
       and b.data_elmt_typ_cd = 'R'
       and a.ext_rcd_id       = c_ext_rcd_id
     order by a.seq_num;

   cursor csr_ff_type ( c_formula_type_id in ff_formulas_f.formula_id%type
                       ,c_effective_date     in date) is
    select formula_type_id
      from ff_formulas_f
     where formula_id = c_formula_type_id
       and c_effective_date between effective_start_date
                                and effective_end_date;
    --
    cursor csr_xrif (c_rcd_id    in number
                   ,c_ext_dfn_id in number ) is
   select rif.ext_rcd_in_file_id
         ,rif.any_or_all_cd
         ,rif.seq_num
                ,rif.sprs_cd
         ,rif.rqd_flag
     from ben_ext_rcd_in_file    rif
         ,ben_ext_dfn            dfn
    where rif.ext_file_id       = dfn.ext_file_id
      and rif.ext_rcd_id        = c_rcd_id
      and dfn.ext_dfn_id        = c_ext_dfn_id;
  --
  l_ben_params             csr_ben%rowtype;
  l_proc_name              varchar2(150) := g_proc_name ||'Process_Ext_Rslt_Dtl_Rec';
  l_foumula_type_id        ff_formulas_f.formula_id%type;
  l_outputs                ff_exec.outputs_t;
  l_ff_value               ben_ext_rslt_dtl.val_01%type;
  l_ff_value_fmt           ben_ext_rslt_dtl.val_01%type;
  l_max_len                number;
  l_rqd_elmt_is_present    varchar2(2) := 'Y';
  l_person_id              per_all_people_f.person_id%type;
  --
  l_val_tab                ValTabTyp;
  l_exclude_this_rcd_flag  boolean;
  l_raise_warning          boolean;
  l_rollback_person        boolean;
  l_rslt_dtl_id            number;
  --
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   for i in 1..75
   loop
     l_val_tab(i) := null;
   end loop;

   for i in  csr_rule_ele( c_ext_rcd_id => p_ext_rcd_id)
   loop
    open  csr_ff_type(c_formula_type_id => i.data_elmt_rl
                     ,c_effective_date  => p_effective_date);
    fetch csr_ff_type  into l_foumula_type_id;
    close csr_ff_type;
    if l_foumula_type_id = -413 then -- person level rule
       l_outputs := Benutils.formula
                   (p_formula_id         => i.data_elmt_rl
                   ,p_effective_date     => p_effective_date
                   ,p_assignment_id      => p_assignment_id
                   ,p_organization_id    => p_organization_id
                   ,p_business_group_id  => g_business_group_id
                   ,p_jurisdiction_code  => null
                   ,p_param1             => 'EXT_DFN_ID'
                   ,p_param1_value       => to_char(nvl(ben_ext_thread.g_ext_dfn_id, -1))
                   ,p_param2             => 'EXT_RSLT_ID'
                   ,p_param2_value       => to_char(nvl(ben_ext_thread.g_ext_rslt_id, -1))
                   ,p_param3             => 'EXT_PERSON_ID'
                   ,p_param3_value       => to_char(nvl(ben_ext_person.g_person_id, -1))
                   ,p_param4             => 'EXT_PROCESS_BUSINESS_GROUP'
                   ,p_param4_value       =>  to_char(g_business_group_id)
                   ,p_param5             => 'EXT_USER_VALUE'
                   ,p_param5_value       =>  i.String_Val
                   );
        l_ff_value := l_outputs(l_outputs.first).value;
        if l_ff_value is null then
           l_ff_value := i.dflt_val;
        end if;
        begin
          if i.frmt_mask_lookup_cd is not null and
             l_ff_value is not null then
             if Substr(i.frmt_mask_lookup_cd,1,1) = 'N' then
               Hr_Utility.set_location('..Applying NUMBER format mask :ben_ext_fmt.apply_format_mask',50);
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(To_Number(l_ff_value), i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            elsif Substr(i.frmt_mask_lookup_cd,1,1) = 'D' then
               Hr_Utility.set_location('..Applying Date format mask :ben_ext_fmt.apply_format_mask',55);
               l_ff_value_fmt := Ben_Ext_Fmt.apply_format_mask(Fnd_Date.canonical_to_date(l_ff_value),
                                                               i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            end if;
          end  if;
        exception  -- incase l_ff_value is not valid for formatting, just don't format it.
            when Others then
            p_error_message := SQLERRM;
        end;
        -- Truncate data element if the max. length is given
        if i.max_length_num is not null then
            l_max_len := Least (Length(l_ff_value),i.max_length_num) ;
            -- numbers should always trunc from the left
            if Substr(i.frmt_mask_lookup_cd,1,1) = 'N' then
               l_ff_value := Substr(l_ff_value, -l_max_len);
            else  -- everything else truncs from the right.
               l_ff_value := Substr(l_ff_value, 1, i.max_length_num);
            end if;
            Hr_Utility.set_location('..After  Max Length : '|| l_ff_value,56 );
        end if;
        -- If the data element is required, and null then exit
        -- no need to re-execute the other data-elements in the record.
        if i.rqd_flag = 'Y' and (l_ff_value is null) then
           l_rqd_elmt_is_present := 'N' ;
           exit ;
        end if;
        -- Update the data-element value at the right seq. num within the
        -- record.
        Update_Record_Values
        (p_ext_rcd_id            => p_ext_rcd_id
        ,p_ext_data_element_name => null
        ,p_data_element_value    => l_ff_value
        ,p_data_ele_seqnum       => i.seq_num
        ,p_ext_dtl_rec           => p_rslt_rec);
      end if;
   end loop; --For i in  csr_rule_ele
  -- Copy the data-element values into a PL/SQL table
   Copy_Rec_Values
  (p_rslt_rec   => p_rslt_rec
  ,p_val_tab    => l_val_tab);
  -- Check the Adv. Conditions for data elements in record
   Data_Elmt_In_Rcd
  (p_ext_rcd_id            => p_rslt_rec.ext_rcd_id
  ,p_val_tab               => l_val_tab
  ,p_exclude_this_rcd_flag => l_exclude_this_rcd_flag
  ,p_raise_warning         => l_raise_warning
  ,p_rollback_person       => l_rollback_person);
   -- Need to remove all the detail records for the person
   if l_rollback_person then
      p_total_lines := 0;
   end if;
   -- Check the Adv. Conditions for records in file
   for rif in csr_xrif
              (c_rcd_id     => p_rslt_rec.ext_rcd_id
              ,c_ext_dfn_id => Ben_Ext_Thread.g_ext_dfn_id )
   loop
       Rcd_In_File
      (p_ext_rcd_in_file_id    => rif.ext_rcd_in_file_id
      ,p_sprs_cd               => rif.sprs_cd
      ,p_val_tab               => l_val_tab
      ,p_exclude_this_rcd_flag => l_exclude_this_rcd_flag
      ,p_raise_warning         => l_raise_warning
      ,p_rollback_person       => l_rollback_person);
   end loop;

   -- Need to remove all the detail records for the person
   if l_rollback_person then
      p_total_lines := 0;
   end if;

   -- If exclude record is not true, then insert or update record
   if not l_exclude_this_rcd_flag     and
          l_rqd_elmt_is_present <> 'N' then
     p_total_lines := p_total_lines + 1;
     if p_total_lines > 1 then
     Ins_Rslt_Dtl(p_dtl_rec      => p_rslt_rec
                 ,p_val_tab      => l_val_tab
                 ,p_rslt_dtl_id  => l_rslt_dtl_id);
     else
     Upd_Rslt_Dtl(p_dtl_rec => p_rslt_rec
                 ,p_val_tab => l_val_tab);
     end if; --IF g_total_dtl_lines
   elsif l_exclude_this_rcd_flag then

      open csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
                   ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
                   ,c_business_group_id => g_business_group_id);
      fetch csr_ben into l_ben_params;
      close csr_ben;

      Exclude_Person
      (p_person_id         => g_person_id
      ,p_business_group_id => g_business_group_id
      ,p_benefit_action_id => l_ben_params.benefit_action_id
      ,p_flag_thread       => 'N');

   end if;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

exception
   when Others then
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);

end Process_Ext_Rslt_Dtl_Rec;
-- =============================================================================
-- ~ Process_Person_RPAs:
-- =============================================================================
procedure Process_Person_RPAs
         (p_ext_rcd_id     in number
         ,p_assignment_id  in number
         ,p_person_id      in number
         ,p_effective_date in date
         ,p_error_code     in out nocopy varchar2
         ,p_error_message  in out nocopy varchar2
         ) as
  l_rslt_dtl_rec        csr_rslt_dtl%rowtype;
  l_no_per_rpas         number(15);
  i                     number(15);
  j                     number(15);
  l_prv_rpa_id          number(15);
  l_proc_name           varchar2(150) := g_proc_name ||'Process_Person_RPAs';
  l_total_lines         number(15);
  l_processed_rpa_id    number(15);
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   open csr_rslt_dtl
       (c_person_id      => p_person_id
       ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
       ,c_ext_dtl_rcd_id => p_ext_rcd_id);
   fetch csr_rslt_dtl into l_rslt_dtl_rec;
   close csr_rslt_dtl;
   l_no_per_rpas := g_rpa_rec.count;
   Hr_Utility.set_location('No Per RPAs: '||l_no_per_rpas, 7);

   if g_pa_req.exists(p_assignment_id) then
      l_processed_rpa_id := g_pa_req(p_assignment_id).pa_request_id;
   end if;
   Hr_Utility.set_location('l_processed_rpa_id : '||l_processed_rpa_id, 9);

   if l_no_per_rpas = 0 then
      Hr_Utility.set_location('l_processed_rpa_id : '||l_processed_rpa_id, 9);
      delete from ben_ext_rslt_dtl dtl
      where dtl.ext_rslt_dtl_id = l_rslt_dtl_rec.ext_rslt_dtl_id;

   elsif l_no_per_rpas > 1 then

        l_total_lines := 1;
        i := p_assignment_id;
        j := g_rpa_rec.first;
        Hr_Utility.set_location('PA Request Id : '||j, 10);
        while j is not null
        loop
          if l_processed_rpa_id <> j then
            g_pa_req(i).person_id         := g_rpa_rec(j).person_id;
            g_pa_req(i).assignment_id     := g_rpa_rec(j).employee_assignment_id;
            g_pa_req(i).effective_date    := g_rpa_rec(j).effective_date;
            g_pa_req(i).last_update_date  := g_rpa_rec(j).last_update_date;
            g_pa_req(i).pa_request_id     := g_rpa_rec(j).pa_request_id;
            g_pa_req(i).pa_notification_id:= g_rpa_rec(j).pa_notification_id;
            g_pa_req(i).first_noa_code    := g_rpa_rec(j).first_noa_code;
            g_pa_req(i).second_noa_code   := g_rpa_rec(j).second_noa_code;
            g_pa_req(i).no_of_rpa         := g_pa_req(i).no_of_rpa + 1;
            Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
           Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_organization_id  => null
           ,p_effective_date   => p_effective_date
           ,p_ext_rcd_id       => p_ext_rcd_id
           ,p_rslt_rec         => l_rslt_dtl_rec
           ,p_total_lines      => l_total_lines
           ,p_error_code       => p_error_code
           ,p_error_message    => p_error_message);
          end if;
          l_prv_rpa_id := j;
          j     := g_rpa_rec.next(l_prv_rpa_id);
          Hr_Utility.set_location('PA Request Id : '||j, 12);
        end loop; -- while loop
   end if;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
exception
   when others then

    p_error_code := sqlcode;
    p_error_message := NULL;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
end Process_Person_RPAs;
-- =============================================================================
-- ~ Process_Address_RPA:
-- =============================================================================
procedure Process_Address_RPA
         (p_ext_rcd_id     in number
         ,p_assignment_id  in number
         ,p_person_id      in number
         ,p_effective_date in date
         ,p_error_code     in out nocopy varchar2
         ,p_error_message  in out nocopy varchar2
         ) as
  l_rslt_dtl_rec        csr_rslt_dtl%rowtype;
  l_no_add_rpas         number(15);
  l_proc_name           varchar2(150) := g_proc_name ||'Process_Address_RPA';
  l_processed_add_id    number(15);

begin

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   open csr_rslt_dtl
       (c_person_id      => p_person_id
       ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
       ,c_ext_dtl_rcd_id => p_ext_rcd_id);
   fetch csr_rslt_dtl into l_rslt_dtl_rec;
   close csr_rslt_dtl;
   l_no_add_rpas := g_address_rec.count;
   Hr_Utility.set_location('No Address RPAs: '||l_no_add_rpas, 7);
   --
   if g_address_rec.exists(p_assignment_id) then
      l_processed_add_id := g_address_rec(p_assignment_id).address_id;
   end if;
   --
   if l_no_add_rpas = 0 then

      delete from ben_ext_rslt_dtl dtl
      where dtl.ext_rslt_dtl_id = l_rslt_dtl_rec.ext_rslt_dtl_id;

   end if;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

exception
   when others then
    p_error_code := sqlcode;
    p_error_message := NULL;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
end Process_Address_RPA;

-- =============================================================================
-- ~ Process_Award_RPAs:
-- =============================================================================
procedure Process_Award_RPAs
         (p_ext_rcd_id     in number
         ,p_assignment_id  in number
         ,p_person_id      in number
         ,p_effective_date in date
         ,p_error_code     in out nocopy varchar2
         ,p_error_message  in out nocopy varchar2
         ) as
  l_rslt_dtl_rec        csr_rslt_dtl%rowtype;
  l_no_per_awds         number(15);
  i                     number(15);
  j                     number(15);
  l_prv_awd_id          number(15);
  l_proc_name           varchar2(150) := g_proc_name ||'Process_Award_RPAs';
  l_total_lines         number(15);
  l_processed_awd_id    number(15);
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   open csr_rslt_dtl
       (c_person_id      => p_person_id
       ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
       ,c_ext_dtl_rcd_id => p_ext_rcd_id);
   fetch csr_rslt_dtl into l_rslt_dtl_rec;
   close csr_rslt_dtl;
   l_no_per_awds := g_awd_rec.count;
   Hr_Utility.set_location(' No Per Awards: '||l_no_per_awds, 7);

   if g_aw_req.exists(p_assignment_id) then
      l_processed_awd_id := g_aw_req(p_assignment_id).pa_request_id;
   end if;
   Hr_Utility.set_location(' l_processed_awd_id : '||l_processed_awd_id, 9);
   if l_no_per_awds = 0 then
       Hr_Utility.set_location(' l_processed_awd_id : '||l_processed_awd_id, 9);

      delete from ben_ext_rslt_dtl dtl
      where dtl.ext_rslt_dtl_id = l_rslt_dtl_rec.ext_rslt_dtl_id;

   elsif l_no_per_awds > 1 then

        l_total_lines := 1;
        i := p_assignment_id;
        j := g_awd_rec.first;
        Hr_Utility.set_location(' Award Request Id : '||j, 10);
        while j is not null
        loop
          if l_processed_awd_id <> j then
            g_aw_req(i).person_id         := g_awd_rec(j).person_id;
            g_aw_req(i).assignment_id     := g_awd_rec(j).employee_assignment_id;
            g_aw_req(i).effective_date    := g_awd_rec(j).effective_date;
            g_aw_req(i).last_update_date  := g_awd_rec(j).last_update_date;
            g_aw_req(i).pa_request_id     := g_awd_rec(j).pa_request_id;
            g_aw_req(i).pa_notification_id:= g_awd_rec(j).pa_notification_id;
            g_aw_req(i).first_noa_code    := g_awd_rec(j).first_noa_code;
            g_aw_req(i).second_noa_code   := g_awd_rec(j).second_noa_code;
            g_aw_req(i).no_of_rpa         := g_aw_req(i).no_of_rpa + 1;
            Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
            Process_Ext_Rslt_Dtl_Rec
           (p_assignment_id    => p_assignment_id
           ,p_organization_id  => null
           ,p_effective_date   => p_effective_date
           ,p_ext_rcd_id       => p_ext_rcd_id
           ,p_rslt_rec         => l_rslt_dtl_rec
           ,p_total_lines      => l_total_lines
           ,p_error_code       => p_error_code
           ,p_error_message    => p_error_message);
          end if;
          l_prv_awd_id := j;
          j     := g_awd_rec.next(l_prv_awd_id);
          Hr_Utility.set_location('PA Request Id : '||j, 12);
        end loop; -- while loop
   end if;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
exception
   when others then

    p_error_code := sqlcode;
    p_error_message := NULL;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
end Process_Award_RPAs;

-- =============================================================================
-- ~ Process_Remark_RPAs:
-- =============================================================================
procedure Process_Remark_RPAs
         (p_ext_rcd_id     in number
         ,p_assignment_id  in number
         ,p_person_id      in number
         ,p_effective_date in date
         ,p_error_code     in out nocopy varchar2
         ,p_error_message  in out nocopy varchar2
         ) as
  l_rslt_dtl_rec        csr_rslt_dtl%rowtype;
  l_no_per_rpas         NUMBER;
  l_no_rpa_rems         NUMBER;
  l_no_awd_rpas         NUMBER;
  i                     NUMBER;
  j                     NUMBER;
  l_prv_rpa_id          NUMBER;
  l_proc_name           VARCHAR2(150) := g_proc_name ||'Process_Remark_RPAs';
  l_total_lines         NUMBER;
  l_processed_rpa_id    NUMBER;
  l_processed_rmk_id    NUMBER;
  l_processed_rmk_cd    NUMBER;
  l_processed_awd_id    NUMBER;
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   open csr_rslt_dtl
       (c_person_id      => p_person_id
       ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
       ,c_ext_dtl_rcd_id => p_ext_rcd_id);
   fetch csr_rslt_dtl into l_rslt_dtl_rec;
   close csr_rslt_dtl;
   l_no_per_rpas := g_rpa_rec.COUNT;
   l_no_rpa_rems := g_pa_req_remark.COUNT;
   l_no_awd_rpas := g_awd_rec.COUNT;

   Hr_Utility.set_location('No Per RPAs: '||l_no_per_rpas, 7);
   Hr_Utility.set_location('No RPAs Remarks: '||l_no_rpa_rems, 7);
   Hr_Utility.set_location('No Award rpas: '||l_no_awd_rpas, 7);

   if g_pa_req.exists(p_assignment_id) then
      l_processed_rpa_id := g_pa_req(p_assignment_id).pa_request_id;
   end if;
   Hr_Utility.set_location('l_processed_rpa_id : '||l_processed_rpa_id, 9);

   IF g_aw_req.exists(p_assignment_id) THEN
		l_processed_awd_id := g_aw_req(p_assignment_id).pa_request_id;
   END IF;

   if (l_no_per_rpas = 0 AND l_no_awd_rpas= 0) or l_no_rpa_rems = 0 then
        Hr_Utility.set_location('l_processed_rpa_id : '||l_processed_rpa_id, 9);
      delete from ben_ext_rslt_dtl dtl
      where dtl.ext_rslt_dtl_id = l_rslt_dtl_rec.ext_rslt_dtl_id;
   elsif l_no_per_rpas >= 1 then
        l_total_lines := 1;
        i := p_assignment_id;

        j := g_rpa_rec.first;
        l_processed_rmk_id := g_pa_req(i).pa_remark_id;
        l_processed_rmk_cd := g_pa_req(i).remark_code;

        Hr_Utility.set_location('PA Request Id : '||j, 10);
        Hr_Utility.set_location('l_processed_rmk_id : '||l_processed_rmk_id, 10);

        while j is not null
        loop
          if l_processed_rpa_id <> j and
             g_pa_req_remark.exists(j) then

            g_pa_req(i).person_id         := g_rpa_rec(j).person_id;
            g_pa_req(i).assignment_id     := g_rpa_rec(j).employee_assignment_id;
            g_pa_req(i).effective_date    := g_rpa_rec(j).effective_date;
            g_pa_req(i).last_update_date  := g_rpa_rec(j).last_update_date;
            g_pa_req(i).pa_request_id     := g_rpa_rec(j).pa_request_id;
            g_pa_req(i).pa_notification_id:= g_rpa_rec(j).pa_notification_id;
            g_pa_req(i).first_noa_code    := g_rpa_rec(j).first_noa_code;
            g_pa_req(i).second_noa_code   := g_rpa_rec(j).second_noa_code;
            g_pa_req(i).no_of_rpa         := g_pa_req(i).no_of_rpa + 1;
            g_pa_req(i).remark_code       := null;
            g_pa_req(i).pa_remark_id      := null;

            for rem_rec in csr_rem(j,g_pa_req(i).effective_date)
            loop
               if ( rem_rec.pa_remark_id <> l_processed_rmk_id) then

                   g_pa_req(i).remark_code  := rem_rec.remark_id;
                   g_pa_req(i).pa_remark_id := rem_rec.pa_remark_id;

                   Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
                   Process_Ext_Rslt_Dtl_Rec
                  (p_assignment_id    => p_assignment_id
                  ,p_organization_id  => null
                  ,p_effective_date   => p_effective_date
                  ,p_ext_rcd_id       => p_ext_rcd_id
                  ,p_rslt_rec         => l_rslt_dtl_rec
                  ,p_total_lines      => l_total_lines
                  ,p_error_code       => p_error_code
                  ,p_error_message    => p_error_message);
                  l_total_lines := l_total_lines + 1;
               end if;
             end loop;

          elsif  l_processed_rpa_id = j then

            g_pa_req(i).person_id         := g_rpa_rec(j).person_id;
            g_pa_req(i).assignment_id     := g_rpa_rec(j).employee_assignment_id;
            g_pa_req(i).effective_date    := g_rpa_rec(j).effective_date;
            g_pa_req(i).last_update_date  := g_rpa_rec(j).last_update_date;
            g_pa_req(i).pa_request_id     := g_rpa_rec(j).pa_request_id;
            g_pa_req(i).pa_notification_id:= g_rpa_rec(j).pa_notification_id;
            g_pa_req(i).first_noa_code    := g_rpa_rec(j).first_noa_code;
            g_pa_req(i).second_noa_code   := g_rpa_rec(j).second_noa_code;
            g_pa_req(i).no_of_rpa         := g_pa_req(i).no_of_rpa + 1;
            g_pa_req(i).remark_code       := l_processed_rmk_cd;
            g_pa_req(i).pa_remark_id      := l_processed_rmk_id;
            for rem_rec in csr_rem(j,g_pa_req(i).effective_date)
            loop
               if (rem_rec.pa_remark_id <> l_processed_rmk_id) then

                   g_pa_req(i).remark_code  := rem_rec.remark_id;
                   g_pa_req(i).pa_remark_id := rem_rec.pa_remark_id;

                   Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
                   Process_Ext_Rslt_Dtl_Rec
                  (p_assignment_id    => p_assignment_id
                  ,p_organization_id  => null
                  ,p_effective_date   => p_effective_date
                  ,p_ext_rcd_id       => p_ext_rcd_id
                  ,p_rslt_rec         => l_rslt_dtl_rec
                  ,p_total_lines      => l_total_lines
                  ,p_error_code       => p_error_code
                  ,p_error_message    => p_error_message);
                  l_total_lines := l_total_lines + 1;

               end if;
             end loop;
          end if;

          l_prv_rpa_id := j;
          j     := g_rpa_rec.next(l_prv_rpa_id);
          Hr_Utility.set_location('PA Request Id : '||j, 12);
        end loop; -- while loop
	-- Code added for Remarks
	ELSIF l_no_awd_rpas >=1 THEN
		l_total_lines := 1;
        i := p_assignment_id;

        j := g_awd_rec.first;
        l_processed_rmk_id := g_aw_req(i).pa_remark_id;
        l_processed_rmk_cd := g_aw_req(i).remark_code;

        Hr_Utility.set_location('PA Request Id : '||j, 10);
        Hr_Utility.set_location('l_processed_rmk_id : '||l_processed_rmk_id, 10);

        while j is not null
        loop
          if l_processed_awd_id <> j and
             g_pa_req_remark.exists(j) then

            g_aw_req(i).person_id         := g_awd_rec(j).person_id;
            g_aw_req(i).assignment_id     := g_awd_rec(j).employee_assignment_id;
            g_aw_req(i).effective_date    := g_awd_rec(j).effective_date;
            g_aw_req(i).last_update_date  := g_awd_rec(j).last_update_date;
            g_aw_req(i).pa_request_id     := g_awd_rec(j).pa_request_id;
            g_aw_req(i).pa_notification_id:= g_awd_rec(j).pa_notification_id;
            g_aw_req(i).first_noa_code    := g_awd_rec(j).first_noa_code;
            g_aw_req(i).second_noa_code   := g_awd_rec(j).second_noa_code;
            g_aw_req(i).no_of_rpa         := g_aw_req(i).no_of_rpa + 1;
            g_aw_req(i).remark_code       := null;
            g_aw_req(i).pa_remark_id      := null;

            for rem_rec in csr_rem(j,g_aw_req(i).effective_date)
            loop
               if ( rem_rec.pa_remark_id <> l_processed_rmk_id) then

                   g_aw_req(i).remark_code  := rem_rec.remark_id;
                   g_aw_req(i).pa_remark_id := rem_rec.pa_remark_id;

                   Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
                   Process_Ext_Rslt_Dtl_Rec
                  (p_assignment_id    => p_assignment_id
                  ,p_organization_id  => null
                  ,p_effective_date   => p_effective_date
                  ,p_ext_rcd_id       => p_ext_rcd_id
                  ,p_rslt_rec         => l_rslt_dtl_rec
                  ,p_total_lines      => l_total_lines
                  ,p_error_code       => p_error_code
                  ,p_error_message    => p_error_message);
                  l_total_lines := l_total_lines + 1;
               end if;
             end loop;

          elsif  l_processed_awd_id = j then

            g_aw_req(i).person_id         := g_awd_rec(j).person_id;
            g_aw_req(i).assignment_id     := g_awd_rec(j).employee_assignment_id;
            g_aw_req(i).effective_date    := g_awd_rec(j).effective_date;
            g_aw_req(i).last_update_date  := g_awd_rec(j).last_update_date;
            g_aw_req(i).pa_request_id     := g_awd_rec(j).pa_request_id;
            g_aw_req(i).pa_notification_id:= g_awd_rec(j).pa_notification_id;
            g_aw_req(i).first_noa_code    := g_awd_rec(j).first_noa_code;
            g_aw_req(i).second_noa_code   := g_awd_rec(j).second_noa_code;
            g_aw_req(i).no_of_rpa         := g_aw_req(i).no_of_rpa + 1;
            g_aw_req(i).remark_code       := l_processed_rmk_cd;
            g_aw_req(i).pa_remark_id      := l_processed_rmk_id;
            for rem_rec in csr_rem(j,g_aw_req(i).effective_date)
            loop
               if (rem_rec.pa_remark_id <> l_processed_rmk_id) then

                   g_aw_req(i).remark_code  := rem_rec.remark_id;
                   g_aw_req(i).pa_remark_id := rem_rec.pa_remark_id;

                   Hr_Utility.set_location('Calling Process_Ext_Rslt_Dtl_Rec... ', 11);
                   Process_Ext_Rslt_Dtl_Rec
                  (p_assignment_id    => p_assignment_id
                  ,p_organization_id  => null
                  ,p_effective_date   => p_effective_date
                  ,p_ext_rcd_id       => p_ext_rcd_id
                  ,p_rslt_rec         => l_rslt_dtl_rec
                  ,p_total_lines      => l_total_lines
                  ,p_error_code       => p_error_code
                  ,p_error_message    => p_error_message);
                  l_total_lines := l_total_lines + 1;

               end if;
             end loop;
          end if;

          l_prv_rpa_id := j;
          j     := g_awd_rec.next(l_prv_rpa_id);
          Hr_Utility.set_location('PA Request Id : '||j, 12);
        end loop; -- while loop

	END IF; -- if l_no_per_rpas = 0
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

exception
   when others then
    p_error_code := sqlcode;
    p_error_message := NULL;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
end Process_Remark_RPAs;

-- =============================================================================
-- ~ Process_Multiple_RPAs
-- =============================================================================
function Process_Multiple_RPAs
         (p_assignment_id     in number
         ,p_person_id         in number
         ,p_effective_date    in date
         ,p_error_code        in out NOCOPY varchar2
         ,p_error_message     in out NOCOPY varchar2)
         return varchar2 is

  l_proc_name           varchar2(150) := g_proc_name ||'Process_Multiple_RPAs';
  l_ext_rcd_id          number(15);
  l_prv_ext_rcd_id      number(15);
  l_rpa_type            varchar2(150);
  l_return_value        varchar2(2000);
begin
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   l_return_value := '0';
   l_ext_rcd_id := g_ext_rcd.first;
   Hr_Utility.set_location('l_ext_rcd_id: '||l_ext_rcd_id, 6);
   while l_ext_rcd_id is not null
   loop
     if g_ext_rcd.exists(l_ext_rcd_id) then
      l_rpa_type := g_ext_rcd(l_ext_rcd_id).data_value;
     end if;
     Hr_Utility.set_location('l_rpa_type: '||l_rpa_type, 7);
     if l_rpa_type ='RPA_REQ_ID' then
        Process_Person_RPAs
        (p_ext_rcd_id     => l_ext_rcd_id
        ,p_assignment_id  => p_assignment_id
        ,p_person_id      => p_person_id
        ,p_effective_date => p_effective_date
        ,p_error_code     => p_error_code
        ,p_error_message  => p_error_message
        );
     elsif l_rpa_type ='RPA_AWARD_ID' THEN ---'RPA_AWD_ID' then
        Process_Award_RPAs
        (p_ext_rcd_id     => l_ext_rcd_id
        ,p_assignment_id  => p_assignment_id
        ,p_person_id      => p_person_id
        ,p_effective_date => p_effective_date
        ,p_error_code     => p_error_code
        ,p_error_message  => p_error_message
        );
     elsif l_rpa_type ='RPA_REMARK_ID' then
        Process_Remark_RPAs
        (p_ext_rcd_id     => l_ext_rcd_id
        ,p_assignment_id  => p_assignment_id
        ,p_person_id      => p_person_id
        ,p_effective_date => p_effective_date
        ,p_error_code     => p_error_code
        ,p_error_message  => p_error_message
        );
     elsif l_rpa_type ='RPA_ADD_ID' then
        Process_Address_RPA
        (p_ext_rcd_id     => l_ext_rcd_id
        ,p_assignment_id  => p_assignment_id
        ,p_person_id      => p_person_id
        ,p_effective_date => p_effective_date
        ,p_error_code     => p_error_code
        ,p_error_message  => p_error_message
        );
     end if;
     l_prv_ext_rcd_id := l_ext_rcd_id;
     l_ext_rcd_id      := g_ext_rcd.next(l_prv_ext_rcd_id);
     Hr_Utility.set_location('l_ext_rcd_id: '||l_ext_rcd_id,10);
   end loop; -- while loop
   for rcd_rec in csr_ext_rcd
                (c_hide_flag   => 'Y'
                ,c_rcd_type_cd => 'D')
   loop
      delete
        from ben_ext_rslt_dtl dtl
       where dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
         and dtl.ext_rcd_id = rcd_rec.ext_rcd_id
         and dtl.business_group_id = g_business_group_id;
   end loop;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   return l_return_value;
exception
   when Others then
    l_return_value  := '-1';
    p_error_code    := sqlcode;
    p_error_message :=' SQL-ERRM :'||NULL;
    Hr_Utility.set_location(p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    return l_return_value;
end Process_Multiple_RPAs;

-- =============================================================================
-- ~ Evaluate_Formula:
-- =============================================================================
function Evaluate_Formula
        (p_assignment_id     in number
        ,p_effective_date    in date
        ,p_business_group_id in number
        ,p_input_value       in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )
         return varchar2 as
   l_return_value           varchar2(2000);
   l_proc_name  constant    varchar2(250) := g_proc_name ||'Evaluate_Formula';
   l_pa_request_id          number;
   l_assignment_id number;
begin

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location(' p_input_value: '||p_input_value, 5);
   Hr_Utility.set_location(' p_assignment_id: '||p_assignment_id, 5);
   Hr_Utility.set_location(' g_assignment_id: '||g_assignment_id, 5);
   -- Sundar Changes Bug 4629647
   IF p_assignment_id IS NULL OR p_assignment_id = -1 THEN
		l_assignment_id := g_assignment_id;
   ELSE
		l_assignment_id := p_assignment_id;
   END IF;

   l_return_value := null;
   p_error_code      := '0'; p_msg_type := '0';
   p_error_message   := '0';
   if (p_input_value = 'RPA_REQ_ID' and
          g_pa_req.exists(l_assignment_id)) then
         l_return_value := g_pa_req(l_assignment_id).pa_request_id;

   elsif (p_input_value = 'RPA_REMARK_ID' and
          g_pa_req.exists(l_assignment_id)) then

         l_return_value := g_pa_req(l_assignment_id).pa_request_id;
	-- Bug 4938143
   elsif (p_input_value = 'RPA_REMARK_ID' and
          g_aw_req.exists(l_assignment_id)) then
		l_return_value := g_aw_req(l_assignment_id).pa_request_id;
	-- Bug 4938143
   elsif (p_input_value = 'RPA_AWARD_ID' and
          g_aw_req.exists(l_assignment_id)) then

         l_return_value := g_aw_req(l_assignment_id).pa_request_id;

   elsif (p_input_value = 'RPA_ADD_ID' and
          g_address_rec.exists(l_assignment_id)) then

         l_return_value := g_address_rec(l_assignment_id).address_id;

   elsif p_input_value = 'RPA_USERID' OR p_input_value = 'AWD_USERID' or
         p_input_value = 'ADD_USERID'  then

         l_return_value := g_extract_params(p_business_group_id).user_id;

   elsif p_input_value ='PRO_MULTI_ACT' then

         l_return_value := Process_Multiple_RPAs
                          (p_assignment_id  => l_assignment_id
                          ,p_person_id      => g_person_id
                          ,p_effective_date => p_effective_date
                          ,p_error_code     => p_error_code
                          ,p_error_message  => p_error_message);

   elsif (p_input_value like 'RPA_RC%' and
          g_pa_req.exists(l_assignment_id)) then
        l_return_value := Get_Remarks_Id
                         (p_assignment_id => l_assignment_id
                         ,p_input_value   => p_input_value
                         ,p_error_code    => p_error_code
                         ,p_error_message => p_error_message
                         );

   elsif (p_input_value like 'RPA%' and
          g_pa_req.exists(l_assignment_id)
          ) then
        l_return_value := Get_RPA_Data
                         (p_assignment_id => l_assignment_id
                         ,p_input_value   => p_input_value
                         ,p_error_code    => p_error_code
                         ,p_error_message => p_error_message
                         );
   elsif (p_input_value like 'REM%' and
          (g_pa_req.exists(l_assignment_id) OR (g_aw_req.exists(l_assignment_id))
          )) then
        l_return_value := Get_Remarks_Data
                         (p_assignment_id => l_assignment_id
                         ,p_input_value   => p_input_value
                         ,p_error_code    => p_error_code
                         ,p_error_message => p_error_message
                         );
   elsif (p_input_value like 'AWD%' and
          g_aw_req.exists(l_assignment_id)
          ) then
        l_return_value := Get_Award_Data
                         (p_assignment_id => l_assignment_id
                         ,p_input_value   => p_input_value
                         ,p_error_code    => p_error_code
                         ,p_error_message => p_error_message
                         );
   elsif (p_input_value like 'ADD%' and
          g_address_rec.exists(l_assignment_id)
          ) then
        l_return_value := Get_Address_Data
                         (p_assignment_id => l_assignment_id
                         ,p_input_value   => p_input_value
                         ,p_error_code    => p_error_code
                         ,p_error_message => p_error_message
                         );
   end if;
   Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   if p_error_code <> '0' then
       p_msg_type := 'W';
   end if;
   return l_return_value;
exception
   when Others then
    p_error_message := NULL; p_msg_type     := 'E';
    p_error_code    := sqlcode; l_return_value := '-1';
    Hr_Utility.set_location('error l_return_value: '||l_return_value, 89);
    Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);
    return l_return_value;
end Evaluate_Formula;

-- =============================================================================
-- ~ Evaluate_Formula:
-- =============================================================================
function Evaluate_Person_Inclusion
        (p_assignment_id     in per_all_assignments_f.assignment_id%type
        ,p_effective_date    in date
        ,p_business_group_id in per_all_assignments_f.business_group_id%type
        ,p_warning_code      in out NoCopy varchar2
        ,p_warning_message   in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )
         return varchar2 as

    -- Cursor to get the person id for the given assignment id.
    cursor csr_per_id (c_assignment_id     in number
                      ,c_business_group_id in number
                      ,c_effective_date    in date) is
    select paf.person_id
          ,paf.assignment_type
      from per_all_assignments_f paf
     where paf.assignment_id     = c_assignment_id
       and paf.business_group_id = c_business_group_id
       and c_effective_date between paf.effective_start_date
                                and paf.effective_end_date;
-- =============================================================================
-- Cursor to get the extract parameters of the last req.
-- =============================================================================
   CURSOR csr_req_params ( c_req_id IN NUMBER) IS
     SELECT argument7, --Tranmission Type
        argument8,  -- Date Criteria
	    argument12,  -- From Date
	    argument13,  -- To Date
        argument14,  -- Agency Code
	    argument15, -- Personnel Office Id
	    argument16, -- Transmission Indicator
	    argument17, -- Signon Identification
	    argument18, -- User_ID
	    argument19, -- dept Code
	    argument20, -- Payroll_id
	    argument21 -- Notify
       FROM fnd_concurrent_requests
      WHERE request_id = c_req_id;


   l_return_value        varchar2(2000);
   i                     number;
   l_remark_cnt          number;
   l_address_id          number;
   l_asg_type            varchar2(30);
   l_Has_RPA_actions     boolean;
   l_Has_Award_Actions   boolean;
   l_Has_Add_chgs        boolean;
   l_Asg_has_Rem         boolean;
   l_ext_rslt_id        ben_ext_rslt.ext_rslt_id%TYPE;
   l_ext_dfn_id         ben_ext_dfn.ext_dfn_id%TYPE;
   l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
   l_req_params         csr_req_params%ROWTYPE;
   j                    per_all_assignments_f.business_group_id%TYPE;
   l_value              Varchar2(150) ;
   l_proc_name  constant varchar2(250) := g_proc_name ||'Evaluate_Person_Inclusion';

begin

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   g_debug := Hr_Utility.debug_enabled;
   g_assignment_id := -1;
   -- ===================================================================
   -- Initialize all local variables
   -- ===================================================================
   l_return_value      := 'N';
   p_warning_message   := null;  p_error_message := null;
   p_warning_code      := '0';   p_error_code    := '0';
   l_Has_RPA_actions   := false; l_Asg_has_Rem   := false;
   l_Has_Award_Actions := false;
   l_Has_Add_chgs      := false;

   l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;
   l_ext_dfn_id  := ben_ext_thread.g_ext_dfn_id;
   j := p_business_group_id;
   g_business_group_id := p_business_group_id;
   g_assignment_id := p_assignment_id; -- Sundar changes.


   Hr_Utility.set_location('p_business_group_id: '||j, 5);

   IF NOT g_extract_params.EXISTS(i) THEN
      -- Get the Conc. request id to get the params
      OPEN  csr_org_req(c_ext_rslt_id      => l_ext_rslt_id
                      ,c_ext_dfn_id        => l_ext_dfn_id
                      ,c_business_group_id => p_business_group_id);
      FETCH csr_org_req INTO l_conc_reqest_id;
      CLOSE csr_org_req;

      Hr_Utility.set_location('l_conc_reqest_id: '||l_conc_reqest_id, 5);
      -- Get the params. based on the conc. request id.
      OPEN  csr_req_params(c_req_id  => l_conc_reqest_id);
      FETCH csr_req_params INTO l_req_params;
      CLOSE csr_req_params;
      Hr_Utility.set_location('..Extract params', 15);

      -- Store the params. in a PL/SQL table record
      g_extract_params(j).business_group_id      := p_business_group_id;
      g_extract_params(j).concurrent_req_id      := l_conc_reqest_id;
      g_extract_params(j).ext_dfn_id             := l_ext_dfn_id;
      g_extract_params(j).transmission_type      := l_req_params.argument7;
      g_extract_params(j).date_criteria          := l_req_params.argument8;
      Hr_Utility.set_location('..Extract params', 17);

      g_extract_params(j).from_date              := Fnd_Date.canonical_to_date(l_req_params.argument12);
      g_extract_params(j).to_date                := Fnd_Date.canonical_to_date(l_req_params.argument13);
      Hr_Utility.set_location('..Extract params', 20);
      g_extract_params(j).agency_code            := l_req_params.argument14;
      g_extract_params(j).personnel_office_id    := l_req_params.argument15;
      g_extract_params(j).transmission_indicator := l_req_params.argument16;
      g_extract_params(j).signon_identification  := l_req_params.argument17;
      g_extract_params(j).user_id                := l_req_params.argument18;
      g_extract_params(j).dept_code              := l_req_params.argument19;
      g_extract_params(j).payroll_id             := l_req_params.argument20;
      g_extract_params(j).notify                 := l_req_params.argument21;

      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
   END IF;

   -- Get the extract start and end date
  /*
   g_ext_start_dt := to_date('01/01/'||to_char(p_effective_date,'YYYY'),
                             'DD/MM/YYYY');
   g_ext_end_dt        := p_effective_date;
   */


   g_ext_start_dt    :=g_extract_params(j).from_date;

   g_ext_end_dt      :=g_extract_params(j).to_date ;
   --

   Get_Rcds_Details;
   g_pa_req.delete;      g_aw_req.delete;
   g_rpa_rec.delete;     g_awd_rec.delete;
   g_address_rec.delete;
   g_auth_date :=NULL;
   g_pa_req_remark.delete;
   g_remark_cnt:=NULL;
   g_rpa_id_apt :=NULL;
   IF g_rpa_attr.count >0 THEN
    g_rpa_attr.delete;
   END IF;

   IF g_rpa_awd_attr.count >0 THEN
    g_rpa_awd_attr.delete;
   END IF;

   Hr_Utility.set_location(' p_assignment_id1: '||p_assignment_id, 6);

   -- Get the person id and bus grp id into pkg global variables
   open csr_per_id(c_assignment_id     => p_assignment_id
                  ,c_business_group_id => p_business_group_id
                  ,c_effective_date    => p_effective_date);
   fetch csr_per_id into g_person_id,l_asg_type;
   close csr_per_id;
   g_effective_date    := p_effective_date;
   i := p_assignment_id;
--   if g_debug then


      Hr_Utility.set_location(' p_business_group_id: '||g_business_group_id, 6);
      Hr_Utility.set_location(' g_ext_start_dt : '||g_ext_start_dt, 6);
      Hr_Utility.set_location(' p_effective_date : '||p_effective_date, 6);
      Hr_Utility.set_location(' g_ext_end_dt: '||g_ext_end_dt, 6);
      Hr_Utility.set_location(' g_person_id: '||g_person_id, 6);
      Hr_Utility.set_location(' p_assignment_id: '||p_assignment_id, 6);
      Hr_Utility.set_location(' l_asg_type: '||l_asg_type, 6);
 --  end if;
   -- Get the Personnel Actions for the person id within the extract
   -- date range
   Hr_Utility.set_location(' Getting RPA s for the person.... ', 7);

   for rpa_rec in csr_ghr_per
                 (c_person_id      => g_person_id
                 ,c_assignment_id  => p_assignment_id
                 ,c_ext_start_date => g_ext_start_dt
                 ,c_ext_end_date   => g_ext_end_dt)
   loop
       -- Assign only one as the current request id.
	   -- Sundar Changes Bug 4629647
       --if not l_Has_RPA_actions then
          g_pa_req(i).person_id          := rpa_rec.person_id;
          g_pa_req(i).assignment_id      := rpa_rec.employee_assignment_id;
          g_pa_req(i).effective_date     := rpa_rec.effective_date;
          g_pa_req(i).last_update_date   := rpa_rec.last_update_date;
          g_pa_req(i).pa_request_id      := rpa_rec.pa_request_id;
          g_pa_req(i).pa_notification_id := rpa_rec.pa_notification_id;
          g_pa_req(i).first_noa_code     := rpa_rec.first_noa_code;
          g_pa_req(i).second_noa_code    := rpa_rec.second_noa_code;
          g_pa_req(i).no_of_rpa          := g_pa_req(i).no_of_rpa + 1;
          l_Has_RPA_actions              := true;
          IF  rpa_rec.first_noa_code=100 THEN
           g_rpa_id_apt:=100;
          END IF;
       --end if;
       -- Get all the RPA into PL/SQL table for the person id.
       --if g_debug then
          Hr_Utility.set_location(' pa_request_id  :'||rpa_rec.pa_request_id, 8);
          Hr_Utility.set_location(' effective_date :'||rpa_rec.effective_date,8);
          Hr_Utility.set_location(' first_noa_code :'||rpa_rec.first_noa_code,8);
       --end if;



       for multi_rpas in csr_rpa_rec
                         (c_pa_request_id => rpa_rec.pa_request_id)
       loop
          g_rpa_rec(rpa_rec.pa_request_id) := multi_rpas;

          populate_attr (p_person_id              => g_pa_req(i).person_id
                       ,p_assignment_id           => g_pa_req(i).assignment_id
                       ,p_business_group_id       =>p_business_group_id
                       ,p_effective_date          =>rpa_rec.effective_date
                       ,p_first_noa_cd            =>rpa_rec.first_noa_code
                       ,p_sec_noa_cd              =>rpa_rec.second_noa_code
                       ,p_request_id              =>rpa_rec.pa_request_id
                       ,p_notification_id         =>rpa_rec.pa_notification_id
                       );

          --Checking the Agency Code
          l_value :=g_rpa_attr(rpa_rec.pa_request_id).nfc_agency;
          IF l_value  <> g_extract_params(j).agency_code THEN
            Hr_Utility.set_location('in side not null - l_value' ||l_value , 8);
			Hr_Utility.set_location('in side not null - ' || g_extract_params(j).agency_code, 8);

            Hr_Utility.set_location('in side not null', 8);
       	     l_return_value := 'N';
			 return l_return_value;
   		 END IF;

			  --Checking the dept code
		  IF g_extract_params(j).dept_code IS NOT NULL THEN
   			l_value :=g_rpa_attr(rpa_rec.pa_request_id).pmso_dept;
                IF l_value <> g_extract_params(j).dept_code THEN
                   l_return_value := 'N';
	           return l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_rpa_rec(rpa_rec.pa_request_id).personnel_office_id;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;
          Hr_Utility.set_location(' RPA req id details in PL/SQL tab', 8);

       end loop; -- for multi_rpas in csr_rpa_rec

       l_remark_cnt := 0;
       -- Get all the Remarks for each RPA
       for j in csr_rem(rpa_rec.pa_request_id
                        ,g_pa_req(i).effective_date)
       loop
          l_remark_cnt := l_remark_cnt + 1;

          if l_remark_cnt = 1 then
             g_pa_req_remark(j.pa_request_id).remark_code_1 := j.code;
             if not l_Asg_has_Rem then
                g_pa_req(i).remark_code  := j.remark_id;
                g_pa_req(i).pa_remark_id := j.pa_remark_id;
                l_Asg_has_Rem := true;
             end if;
          elsif l_remark_cnt = 2 then
             g_pa_req_remark(j.pa_request_id).remark_code_2 := j.code;
          elsif l_remark_cnt = 3 then
             g_pa_req_remark(j.pa_request_id).remark_code_3 := j.code;
          elsif l_remark_cnt = 4 then
             g_pa_req_remark(j.pa_request_id).remark_code_4 := j.code;
          elsif l_remark_cnt = 5 then
             g_pa_req_remark(j.pa_request_id).remark_code_5 := j.code;
          elsif l_remark_cnt = 6 then
             g_pa_req_remark(j.pa_request_id).remark_code_6 := j.code;
          elsif l_remark_cnt = 7 then
             g_pa_req_remark(j.pa_request_id).remark_code_7 := j.code;
          elsif l_remark_cnt = 8 then
             g_pa_req_remark(j.pa_request_id).remark_code_8 := j.code;
          elsif l_remark_cnt = 9 then
             g_pa_req_remark(j.pa_request_id).remark_code_9 := j.code;
          elsif l_remark_cnt = 10 then
             g_pa_req_remark(j.pa_request_id).remark_code_10 := j.code;
          end if;
          exit when l_remark_cnt = 10;
       end loop; -- for j in csr_re
       g_remark_cnt :=l_remark_cnt ;
       Hr_Utility.set_location(' Total remarks found :'||l_remark_cnt,8);
   end loop; --  for rpa_rec in csr_ghr_per

   -- Get the Award Actions for the person id within the extract
   -- date range
   Hr_Utility.set_location(' Getting Awards s for the person.... ', 9);
   for awd_rec in csr_ghr_awd
                  (c_person_id      => g_person_id
                  ,c_assignment_id  => p_assignment_id
                  ,c_ext_start_date => g_ext_start_dt
                  ,c_ext_end_date   => g_ext_end_dt)
   LOOP
       -- Assign only one as the current request id.
       IF NOT l_Has_Award_Actions THEN
          g_aw_req(i).person_id          := awd_rec.person_id;
          g_aw_req(i).assignment_id      := awd_rec.employee_assignment_id;
          g_aw_req(i).effective_date     := awd_rec.effective_date;
          g_aw_req(i).last_update_date   := awd_rec.last_update_date;
          g_aw_req(i).pa_request_id      := awd_rec.pa_request_id;
          g_aw_req(i).pa_notification_id := awd_rec.pa_notification_id;
          g_aw_req(i).first_noa_code     := awd_rec.first_noa_code;
          g_aw_req(i).second_noa_code    := awd_rec.second_noa_code;
          g_aw_req(i).no_of_rpa          := g_aw_req(i).no_of_rpa + 1;
          l_Has_Award_Actions            := true;
       END IF;

       if g_debug then
          Hr_Utility.set_location(' pa_request_id: '||awd_rec.pa_request_id, 10);
          Hr_Utility.set_location(' effective_date : '||awd_rec.effective_date, 10);
          Hr_Utility.set_location(' first_noa_code : '||awd_rec.first_noa_code, 10);
       end if;
       -- Get all the RPA into PL/SQL table for the person id.
       FOR multi_rpas IN csr_rpa_rec
                         (c_pa_request_id => awd_rec.pa_request_id)
       LOOP
          g_awd_rec(awd_rec.pa_request_id) := multi_rpas;
           populate_awd_attr (p_person_id         => g_aw_req(i).person_id
                       ,p_assignment_id           => g_aw_req(i).assignment_id
                       ,p_business_group_id       =>p_business_group_id
                       ,p_effective_date          =>awd_rec.effective_date
                       ,p_first_noa_cd            =>awd_rec.first_noa_code
                       ,p_sec_noa_cd              =>awd_rec.second_noa_code
                       ,p_request_id              =>awd_rec.pa_request_id
                       ,p_notification_id         =>g_aw_req(i).pa_notification_id
                       );
          Hr_Utility.set_location(' Award req id details in PL/SQL tab', 11);

          --Checking the Agency Code in Awards
          l_value :=g_rpa_awd_attr(awd_rec.pa_request_id).nfc_agency_code;
          IF l_value  <> g_extract_params(j).agency_code THEN
       	     l_return_value := 'N';
			 return l_return_value;
   		  END IF;

          --Checking the dept code in Awards
			IF g_extract_params(j).dept_code IS NOT NULL THEN
   				l_value :=g_rpa_awd_attr(awd_rec.pa_request_id).dept_code;
                IF l_value <> g_extract_params(j).dept_code THEN
                   l_return_value := 'N';
					return l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id in awards
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_awd_rec(awd_rec.pa_request_id).personnel_office_id;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;

       END LOOP; -- for multi_rpas in csr_rpa_rec

		l_remark_cnt := 0;
		-- Added remark for award actions
	   FOR j IN csr_rem(awd_rec.pa_request_id
                        ,g_aw_req(i).effective_date)
       LOOP
          l_remark_cnt := l_remark_cnt + 1;
          g_aw_req(i).pa_request_id := awd_rec.pa_request_id;
          IF l_remark_cnt = 1 THEN
             g_pa_req_remark(j.pa_request_id).remark_code_1 := j.code;
             IF NOT l_Asg_has_Rem THEN
                g_aw_req(i).remark_code  := j.remark_id;
                g_aw_req(i).pa_remark_id := j.pa_remark_id;
                l_Asg_has_Rem := true;
             END IF;
          ELSIF l_remark_cnt = 2 then
				g_pa_req_remark(j.pa_request_id).remark_code_2 := j.code;
          ELSIF l_remark_cnt = 3 then
				g_pa_req_remark(j.pa_request_id).remark_code_3 := j.code;
          ELSIF l_remark_cnt = 4 then
				g_pa_req_remark(j.pa_request_id).remark_code_4 := j.code;
          ELSIF l_remark_cnt = 5 then
				g_pa_req_remark(j.pa_request_id).remark_code_5 := j.code;
          ELSIF l_remark_cnt = 6 then
				g_pa_req_remark(j.pa_request_id).remark_code_6 := j.code;
          ELSIF l_remark_cnt = 7 then
				g_pa_req_remark(j.pa_request_id).remark_code_7 := j.code;
          ELSIF l_remark_cnt = 8 then
				g_pa_req_remark(j.pa_request_id).remark_code_8 := j.code;
          ELSIF l_remark_cnt = 9 then
				g_pa_req_remark(j.pa_request_id).remark_code_9 := j.code;
          ELSIF l_remark_cnt = 10 then
				g_pa_req_remark(j.pa_request_id).remark_code_10 := j.code;
          END IF;
          EXIT WHEN l_remark_cnt = 10;
       END LOOP; -- for j in csr_re
       g_remark_cnt :=l_remark_cnt ;
	   -- End Remark Award actions

   END LOOP; -- for awd_rec in csr_ghr_awd
   -- Get the most recent Address Change with the extract date range.
   Hr_Utility.set_location(' Getting Primary Address Changes for the person.... ', 12);

   IF g_rpa_id_apt = 100 THEN

	Hr_Utility.set_location(' 100 - Getting Primary Address.... ', 12);
    open csr_per_add_apt (c_person_id      => g_person_id
                         ,c_ext_end_date   => g_ext_end_dt);
    fetch csr_per_add_apt into g_address_rec(i);
    IF (csr_per_add_apt%found ) then
      populate_add_attr (p_person_id             =>g_person_id
                       ,p_assignment_id          =>p_assignment_id
                       ,p_business_group_id      =>p_business_group_id
                       ,p_effective_date         =>p_effective_date
                       ,p_request_id             =>NULL
                       );
      Hr_Utility.set_location(' Person:address_id: '||g_address_rec(i).address_id, 14);
      l_Has_Add_chgs := true;
     --Checking the criteria validations in Address
     --Checking the Agency Code in Address
          l_value :=g_rpa_add_attr(p_assignment_id).nfc_agency_code;
          IF l_value  <> g_extract_params(j).agency_code THEN
       	     l_return_value := 'N';
			return l_return_value;
   		  END IF;

          --Checking the dept code in Address
		  IF g_extract_params(j).dept_code IS NOT NULL THEN
			 l_value :=g_rpa_add_attr(p_assignment_id).dept_code;
                IF l_value <> g_extract_params(j).dept_code THEN
                   l_return_value := 'N';
					return l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id in Address
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_rpa_add_attr(p_assignment_id).poi;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;
    END IF; -- IF (csr_per_add_apt%found )
    CLOSE csr_per_add_apt;

   ELSE  -- IF g_rpa_id_apt = 100
	   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ' || l_return_value, 12);
    OPEN csr_per_add (c_person_id      => g_person_id
                    ,c_ext_start_date => g_ext_start_dt
                    ,c_ext_end_date   => g_ext_end_dt);
    FETCH csr_per_add into g_address_rec(i);
	Hr_Utility.set_location('Non 100 - After fetching.... ' || l_return_value, 12);
    IF (csr_per_add%found ) then
      populate_add_attr (p_person_id             =>g_person_id
                       ,p_assignment_id          =>p_assignment_id
                       ,p_business_group_id      =>p_business_group_id
                       ,p_effective_date         =>p_effective_date
                       ,p_request_id             =>NULL
                       ); --Checking the criteria validations in Address
     --Checking the Agency Code in Address
          l_value :=g_rpa_add_attr(p_assignment_id).nfc_agency_code;
          IF l_value  <> g_extract_params(j).agency_code THEN
			   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 121);
       	     l_return_value := 'N';
			return l_return_value;
   		END IF;
--Checking the criteria validations in Address
     --Checking the Agency Code in Address
          l_value :=g_rpa_add_attr(p_assignment_id).nfc_agency_code;
          IF l_value  <> g_extract_params(j).agency_code THEN
		   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 122);
       	     l_return_value := 'N';
			return l_return_value;
   		 END IF;

          --Checking the dept code in Address
		  IF g_extract_params(j).dept_code IS NOT NULL THEN
   				l_value :=g_rpa_add_attr(p_assignment_id).dept_code;
                IF l_value <> g_extract_params(j).dept_code THEN
				 Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 123);
                   l_return_value := 'N';
					return l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id in Address
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_rpa_add_attr(p_assignment_id).poi;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
			   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 124);
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;
          --Checking the dept code in Address
		   IF g_extract_params(j).dept_code IS NOT NULL THEN
   				l_value :=g_rpa_add_attr(p_assignment_id).dept_code;
                IF l_value <> g_extract_params(j).dept_code THEN
				 Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 125);
                   l_return_value := 'N';
					RETURN l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id in Address
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_rpa_add_attr(p_assignment_id).poi;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
			   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 126);
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;
      Hr_Utility.set_location(' Person:address_id: '||g_address_rec(i).address_id, 14);
      l_Has_Add_chgs := true;
     --Checking the criteria validations in Address
     --Checking the Agency Code in Address
          l_value :=g_rpa_add_attr(p_assignment_id).nfc_agency_code;
          IF l_value  <> g_extract_params(j).agency_code THEN
		   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 127);
       	     l_return_value := 'N';
	     return l_return_value;
   	  END IF;

          --Checking the dept code in Address
	  IF g_extract_params(j).dept_code IS NOT NULL THEN
   	     l_value :=g_rpa_add_attr(p_assignment_id).dept_code;
                IF l_value <> g_extract_params(j).dept_code THEN
				 Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 128);
                   l_return_value := 'N';
	           return l_return_value;
    	        END IF;
           END IF;

           --Checking the Personnel Office id in Address
           IF g_extract_params(j).personnel_office_id IS NOT NULL THEN
               l_value :=g_rpa_add_attr(p_assignment_id).poi;
   	          IF l_value <> g_extract_params(j).personnel_office_id THEN
			   Hr_Utility.set_location('Non 100 - Getting Primary Address.... ', 129);
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
           END IF;
    end if;
    close csr_per_add;



   END IF;
   -- If person has no RPA, Awards or Addresses changes then the person need
   -- not be extracted.
   if l_Has_Add_chgs or
      l_Has_Award_Actions or
      l_Has_RPA_actions then
      l_return_value := 'Y';
   elsif l_asg_type ='B' then
	   	Hr_Utility.set_location('Non 100 - After fetching.... ' || l_return_value, 12);
      l_return_value := 'Y';
   end if;

   Hr_Utility.set_location(' l_return_value: '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   return l_return_value;

exception
   when Others then
    p_error_code   := sqlcode; p_warning_code   := '-1';
    p_error_message:= NULL; p_warning_message:= null;
    l_return_value := 'N';

    Hr_Utility.set_location(' l_return_value: '||l_return_value, 89);
    Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);

    return l_return_value;

end Evaluate_Person_Inclusion;

-- =============================================================================
-- ~ Get_NFC_ConcProg_Information: Common function to get the conc.prg parameters
-- =============================================================================
FUNCTION Get_NFC_ConcProg_Information
                     (p_header_type IN VARCHAR2
                     ,p_error_message OUT NOCOPY VARCHAR2) RETURN Varchar2 IS

  CURSOR csr_period_num(c_payroll_id     IN per_time_periods.payroll_id%TYPE
                       ,c_effective_date IN DATE) IS
    SELECT period_num
      FROM per_time_periods
     WHERE payroll_id = c_payroll_id
       AND c_effective_date BETWEEN start_date
                                AND end_date;


   CURSOR csr_jcl_org_req (c_ext_dfn_id IN NUMBER
                          ,c_ext_rslt_id IN NUMBER ) IS
    SELECT bba.request_id
      FROM ben_benefit_actions bba
     WHERE bba.pl_id = c_ext_rslt_id
       AND bba.pgm_id = c_ext_dfn_id ;


  l_proc_name     VARCHAR2(150) := g_proc_name ||'.Get_NFC_ConcProg_Information';
  l_return_value  VARCHAR2(1000);
  i               per_all_assignments_f.business_group_id%TYPE;
  l_period_num    per_time_periods.period_num%TYPE;
  l_ext_rslt_id   ben_ext_rslt.ext_rslt_id%TYPE;
  l_ext_dfn_id    ben_ext_dfn.ext_dfn_id%TYPE;
  l_conc_reqest_id ben_ext_rslt.request_id%TYPE;
  l_start_date    DATE;
  l_end_date      DATE;
  l_position_id   NUMBER;

BEGIN
   Hr_Utility.set_location('Entering :'||l_proc_name, 5);
   i := g_business_group_id;

   Hr_Utility.set_location('g_business_group_id :'||g_business_group_id, 5);
   Hr_Utility.set_location('p_header_type :'||p_header_type, 5);
   Hr_Utility.set_location('g_extract_params(i).agency_code:'||g_extract_params(i).agency_code, 5);

   IF p_header_type = 'AGENCY_CODE' THEN
        l_return_value := g_extract_params(i).agency_code;
   ELSIF p_header_type = 'PERSONNEL_OFFICE_ID' THEN
       l_return_value := g_extract_params(i).personnel_office_id;
   ELSIF p_header_type = 'TRANSMISSION_INDICATOR' THEN
       l_return_value := g_extract_params(i).transmission_indicator;
   ELSIF p_header_type = 'SIGNON_IDENTIFICATION' THEN
       l_return_value := g_extract_params(i).signon_identification;
   ELSIF p_header_type = 'PAY_PERIOD_NUMBER' THEN
     l_period_num:= get_pay_period_number
                        (p_person_id           => -1
                        ,p_assignment_id       =>-1
                        ,p_business_group_id   =>g_business_group_id
                        ,p_effective_date      =>g_extract_params(i).to_date
                        ,p_position_id         =>l_position_id
                        ,p_start_date          =>l_start_date
                        ,p_end_date            =>l_end_date
                        );
         l_return_value := LPAD(l_period_num,2,'0');
   END IF;
   hr_utility.set_location('l_return_value: '||l_return_value, 45);
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     hr_utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN l_return_value;
END Get_NFC_ConcProg_Information;


END GHR_US_NFC_EXTRACTS;

/
