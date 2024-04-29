--------------------------------------------------------
--  DDL for Package Body PQP_NL_PGGM_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_PGGM_PENSION_EXTRACTS" AS
/* $Header: pqpnlpggmpext.pkb 120.0.12000000.14 2007/04/18 20:48:12 rrajaman noship $ */

g_proc_name  Varchar2(200) :='PQP_NL_PGGM_Pension_Extracts.';

-- =============================================================================
-- Cursor to get the extract record id's for extract definition id
-- =============================================================================
CURSOR csr_ext_rcd_id_with_seq  IS
   SELECT Decode(rin.seq_num,1,'000',
                             2,'010',
                             3,'020',
                             4,'030',
                             5,'040',
                             6,'060',
                             7,'070',
                             8,'080',
                             9,'081',
                            12,'999',
                            '~') rec_num,
          rin.seq_num,
          rin.hide_flag,
          rcd.ext_rcd_id,
          rcd.rcd_type_cd
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     ORDER BY rin.seq_num;

-- =============================================================================
-- Cursor to get assignment details
-- =============================================================================
CURSOR csr_assig (c_assignment_id     IN Number
                 ,c_effective_date    IN Date
                 ,c_business_group_id IN Number) IS
SELECT paf.person_id
      ,paf.organization_id
      ,paf.assignment_type
      ,paf.effective_start_date
      ,paf.effective_end_date
      ,ast.user_status
      ,Hr_General.decode_lookup
        ('EMP_CAT',
          paf.employment_category) employment_category
      ,pps.date_start
      ,pps.actual_termination_date
      ,paf.payroll_id
      ,'ER'
      ,per.employee_number
      ,paf.assignment_sequence
      ,per.national_identifier
      ,per.last_name
      ,per.per_information1
      ,per.pre_name_adjunct
      ,per.sex
      ,per.date_of_birth
      ,'PLN'
      ,'PIX'
      ,per.per_information14
      ,per.marital_status
      ,paf.primary_flag
  FROM per_all_assignments_f       paf,
       per_all_people_f            per,
       per_periods_of_service      pps,
       per_assignment_status_types ast
 WHERE paf.assignment_id             = c_assignment_id
   AND paf.person_id                 = per.person_id
   AND pps.period_of_service_id(+)       = paf.period_of_service_id
   AND ast.assignment_status_type_id = paf.assignment_status_type_id
   AND c_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND c_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND paf.business_group_id = c_business_group_id
   AND per.business_group_id = c_business_group_id;
-- =============================================================================
-- Based on result id and Ext. Dfn Id, get the con. request id
-- =============================================================================
CURSOR csr_req_id (c_ext_rslt_id       IN ben_ext_rslt.ext_rslt_id%TYPE
                   ,c_ext_dfn_id        IN ben_ext_rslt.ext_dfn_id%TYPE
                   ,c_business_group_id IN ben_ext_rslt.business_group_id%TYPE) IS
SELECT request_id
  FROM ben_ext_rslt
 WHERE ext_rslt_id       = c_ext_rslt_id
   AND ext_dfn_id        = c_ext_dfn_id
   AND business_group_id = c_business_group_id;

-- =============================================================================
-- Check whether assignment is primary or secondary
-- =============================================================================
CURSOR csr_chk_primary_asg(c_assignment_id NUMBER, c_effective_date DATE) IS
SELECT 'x'
  FROM per_all_assignments_f
 WHERE assignment_id = c_assignment_id
   AND primary_flag= 'Y'
   AND c_effective_date BETWEEN effective_start_date AND effective_end_date;

-- =============================================================================
-- Cursor to get secondary asgsignments  details
-- =============================================================================

CURSOR csr_sec_assig (c_assignment_id     IN Number
                     ,c_effective_date    IN Date
                     ,c_business_group_id IN Number
                     ,c_person_id         IN Number) IS
SELECT paf.organization_id
      ,paf.payroll_id
  FROM per_all_assignments_f       paf,
       per_all_people_f            per
 WHERE paf.assignment_id             <> c_assignment_id
   AND paf.person_id                 = c_person_id
   AND paf.person_id                 = per.person_id
   AND c_effective_date BETWEEN paf.effective_start_date
                            AND paf.effective_end_date
   AND c_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND paf.business_group_id = c_business_group_id
   AND per.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to get the extract record id's for record sequence number
-- =============================================================================
CURSOR c_get_rcd_id(c_seq IN Number)  IS
   SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract executing currently
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rin.seq_num      = c_seq;

-- =============================================================================
-- Cursor to get the extract record id
-- =============================================================================
CURSOR csr_ext_rcd_id (c_hide_flag   IN Varchar2
                      ,c_rcd_type_cd IN Varchar2
                      ) IS
   SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id -- The extract
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.hide_flag    = c_hide_flag     -- Y=Hidden, N=Not Hidden
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rcd.rcd_type_cd  = c_rcd_type_cd;  -- D=Detail,H=Header,F=Footer

-- =============================================================================
-- Cursor to get the extract record id for hidden and Not hidden records
-- =============================================================================
CURSOR csr_ext_rcd_id_hidden(c_rcd_type_cd IN Varchar2) IS
    SELECT rcd.ext_rcd_id
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     AND rcd.rcd_type_cd  = c_rcd_type_cd
     ORDER BY rin.seq_num;
-- ============================================================================
-- Cursor to get the Organization name
-- ============================================================================
  CURSOR csr_org_name (c_org_id IN Number
     		       )IS
  SELECT NAME
    FROM hr_all_organization_units
   WHERE organization_id = c_org_id;
-- =============================================================================
-- Cursor to chk for other primary assig. within the extract date range.
-- =============================================================================
CURSOR csr_sec_assg
        (c_primary_assignment_id IN per_all_assignments_f.assignment_id%TYPE
        ,c_person_id             IN per_all_people_f.person_id%TYPE
        ,c_effective_date        IN Date
        ,c_extract_start_date    IN Date
        ,c_extract_end_date      IN Date ) IS
  SELECT asg.person_id
        ,asg.organization_id
        ,asg.assignment_type
        ,asg.effective_start_date
        ,asg.effective_end_date
        ,'NO'
        ,asg.assignment_id
    FROM per_all_assignments_f  asg
   WHERE asg.person_id       = c_person_id
     AND asg.assignment_id  <> c_primary_assignment_id
     AND asg.assignment_type ='E'
     AND (( c_effective_date  BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date
           )
          OR
          ( asg.effective_end_date =
           (SELECT Max(asx.effective_end_date)
              FROM per_all_assignments_f asx
             WHERE asx.assignment_id   = asg.assignment_id
               AND asx.person_id       = c_person_id
               AND asx.assignment_type = 'E'
               AND ((asx.effective_end_date BETWEEN c_extract_start_date
                                                AND c_extract_end_date)
                     OR
                    (asx.effective_start_date BETWEEN c_extract_start_date
                                                  AND c_extract_end_date)
                   )
            )
           )
         )
   ORDER BY asg.effective_start_date ASC;
-- =============================================================================
-- Cursor to get the extract result dtl record for a person id
-- =============================================================================
CURSOR csr_rslt_dtl(c_person_id      IN Number
                   ,c_ext_rslt_id    IN Number
                   ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.person_id   = c_person_id
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;
-- =============================================================================
-- Cursor to get all assig.actions for a given assig. within a data range
-- =============================================================================
CURSOR csr_asg_act (c_assignment_id IN Number
                   ,c_payroll_id    IN Number
                   ,c_con_set_id    IN Number
                   ,c_start_date    IN Date
                   ,c_end_date      IN Date
                   ) IS
  SELECT paa.assignment_action_id
        ,ppa.effective_date
        ,ppa.action_type
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.assignment_id        = c_assignment_id
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND paa.source_action_id     IS NULL
     AND ppa.action_status        = 'C'
     AND paa.action_status        = 'C'
     AND ppa.action_type IN ('B','L','O','Q','R')
     AND ppa.payroll_id           = Nvl(c_payroll_id,ppa.payroll_id)
     AND ppa.consolidation_set_id = Nvl(c_con_set_id,ppa.consolidation_set_id)
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date
     ORDER BY ppa.effective_date;

l_asg_act csr_asg_act%ROWTYPE;

-- =============================================================================
--Cursor to fetch Start date of a year
-- =============================================================================
CURSOR c_get_period_start_date ( c_year           IN VARCHAR2
                                ,c_assignment_id  IN NUMBER
                                ,c_date_earned    IN DATE )
IS
SELECT NVL(min(PTP.start_date),to_date('0101'||c_year,'DDMMYYYY'))
 FROM  per_time_periods PTP
       ,per_all_assignments_f PAA
 WHERE PAA.assignment_id = c_assignment_id
   AND PTP.payroll_id = PAA.payroll_id
   AND (c_date_earned between PAA.effective_start_date and PAA.effective_end_date)
   AND (substr(PTP.period_name,4,4)=c_year
    OR substr(PTP.period_name,3,4)=c_year);

-- =============================================================================
--Cursor to fetch End date of a year
-- =============================================================================
CURSOR c_get_period_end_date ( c_year IN VARCHAR2
                              ,c_assignment_id  IN NUMBER
                              ,c_date_earned    IN DATE )
IS
SELECT NVL(max(PTP.end_date),to_date('3112'||c_year,'DDMMYYYY'))
 FROM   per_time_periods PTP
      , per_all_assignments_f PAA
 WHERE PAA.assignment_id = c_assignment_id
   AND PTP.payroll_id = PAA.payroll_id
   AND (c_date_earned between PAA.effective_start_date and PAA.effective_end_date)
   AND (substr(PTP.period_name,4,4)=c_year
    OR substr(PTP.period_name,3,4)=c_year);

-- =============================================================================
--Cursor to get number of pay periods in a year
-- =============================================================================
CURSOR c_get_num_periods_per_year(c_assignment_id IN NUMBER
                                  ,c_date_earned IN DATE)  IS
SELECT NVL(TPTYPE.number_per_fiscal_year,12)
FROM   per_all_assignments_f    PAA
,      per_time_periods       TPERIOD
,      per_time_period_types  TPTYPE
WHERE  PAA.assignment_id      = c_assignment_id
  AND  TPERIOD.payroll_id     = PAA.payroll_id
  AND  ( c_date_earned between PAA.effective_start_date and PAA.effective_end_date)
  AND  ( c_date_earned between TPERIOD.start_date       and TPERIOD.end_date )
  AND  TPTYPE.period_type      = TPERIOD.period_type;

-- ====================================================================
-- ~ Set_ConcProg_Parameter_Values : Used to get the conc program parameters
--   values for passed ids and also setting the values into the global records
-- ====================================================================
PROCEDURE Set_ConcProg_Parameter_Values
           (p_ext_dfn_id                  IN     Number
           ,p_start_date                  IN     Varchar2
           ,p_end_date                    IN     Varchar2
           ,p_payroll_id                  IN     Number
           ,p_con_set                     IN     Number
           ,p_org_id                      IN     Number
           )  IS

   CURSOR csr_ext_name(c_ext_dfn_id  IN Number
                       )IS
   SELECT Substr(ed.NAME,1,240)
     FROM ben_ext_dfn ed
    WHERE ed.ext_dfn_id = p_ext_dfn_id;

   CURSOR csr_pay_name(c_payroll_id IN Number
                      ,c_end_date   IN Date
                 )IS
   SELECT pay.payroll_name
     FROM pay_payrolls_f pay
    WHERE pay.payroll_id = c_payroll_id
      AND c_end_date BETWEEN pay.effective_start_date
      AND pay.effective_end_date;

   CURSOR csr_con_set (c_con_set IN Number
                      )IS
   SELECT con.consolidation_set_name
     FROM pay_consolidation_sets con
    WHERE con.consolidation_set_id = c_con_set;

   l_proc_name      Varchar2(150) := g_proc_name ||'Set_ConcProg_Parameter_Values';
   l_extract_name    ben_ext_dfn.NAME%TYPE;
   l_payroll_name    PAY_PAYROLLS_F.PAYROLL_NAME%TYPE ;
   l_con_set_name    PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_NAME%TYPE;
   l_org_name        hr_all_organization_units.NAME%TYPE;

BEGIN
      Hr_Utility.set_location('Entering: '||l_proc_name, 5);

      OPEN csr_ext_name( c_ext_dfn_id => p_ext_dfn_id);
      FETCH csr_ext_name INTO l_extract_name;
      CLOSE csr_ext_name;

      IF p_payroll_id IS NOT NULL THEN
         OPEN  csr_pay_name( c_payroll_id => p_payroll_id
                             ,c_end_date =>p_end_date
	 	           );
         FETCH csr_pay_name INTO l_payroll_name;
         CLOSE csr_pay_name;
      END IF;

      IF p_con_set IS NOT NULL THEN
         OPEN  csr_con_set( c_con_set => p_con_set);
         FETCH csr_con_set INTO l_con_set_name;
         CLOSE csr_con_set;
      END IF;

      IF p_org_id IS NOT NULL THEN
         OPEN  csr_org_name( c_org_id => p_org_id);
         FETCH csr_org_name INTO l_org_name;
         CLOSE csr_org_name;
      END IF;

      -- Add code for extract type.............................................Code Required here
      --Setting the values
      g_conc_prog_details(0).extract_name   := l_extract_name;
      g_conc_prog_details(0).beginningdt    := p_start_date;
      g_conc_prog_details(0).endingdt       := p_end_date;
      g_conc_prog_details(0).payrollname    := l_payroll_name;
      g_conc_prog_details(0).consolset      := l_con_set_name;
      g_conc_prog_details(0).orgname        := l_org_name;
      g_conc_prog_details(0).orgid          := p_org_id;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Set_ConcProg_Parameter_Values;
-- ====================================================================
-- Get_Current_Extract_Result:
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
-- ====================================================================
FUNCTION Get_Current_Extract_Result
    RETURN Number  IS
  e_extract_process_not_running EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_extract_process_not_running,-8002);
  l_ext_rslt_id  Number;
BEGIN
  l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
  RETURN l_ext_rslt_id;
EXCEPTION
  WHEN e_extract_process_not_running THEN
   RETURN -1;
END Get_Current_Extract_Result;

-- ====================================================================
-- Get_Current_Extract_Person:
--    Returns the person_id for the current extract process
--    if one is running, else returns -1
-- ====================================================================
FUNCTION Get_Current_Extract_Person
          (p_assignment_id IN Number )
          RETURN Number IS
 l_person_id  Number;
BEGIN
  SELECT person_id
    INTO l_person_id
    FROM per_all_assignments_f
   WHERE assignment_id = p_assignment_id
     AND ROWNUM < 2;
    RETURN l_person_id;
  EXCEPTION
    WHEN No_Data_Found THEN
      RETURN NULL;
END Get_Current_Extract_Person ;

-- =============================================================================
-- IsNumber: return TRUE if number else FALSE
-- =============================================================================
FUNCTION IsNumber (p_data_value IN Varchar2)
RETURN Boolean  IS
 l_data_value Number;
BEGIN
  l_data_value := Fnd_Number.Canonical_To_Number(Nvl(p_data_value,'0'));
  RETURN TRUE;
EXCEPTION
  WHEN Value_Error THEN
   RETURN FALSE;
END IsNumber;

-- =============================================================================
-- Get the correct year for the effective date
-- =============================================================================
FUNCTION Get_Year(p_assignment_id NUMBER
                 ,p_effective_start_date DATE
		 ,p_effective_end_date DATE )
RETURN NUMBER IS

--CURSOR to extract the year from the date irrespective of payroll period type
CURSOR c_get_year (c_assignment_id NUMBER, c_effective_date DATE)
IS
SELECT
decode(
        trunc( to_number(PTP.period_num)/10),
                             0,substr(PTP.period_name,3,4),
			     1,substr(PTP.period_name,4,4)
      )
 FROM   per_time_periods PTP
      ,per_all_assignments_f PAA
 WHERE PAA.assignment_id = c_assignment_id
 AND   PTP.payroll_id = PAA.payroll_id
 AND ( c_effective_date between PTP.start_date and PTP.end_date );

l_proc_name         Varchar2(150):= g_proc_name||'Get_Year';
l_start_date_year   NUMBER;
l_end_date_year     NUMBER;
l_year              NUMBER;

BEGIN
 Hr_Utility.set_location('Entering :'||l_proc_name, 5);
 --Extract the correct year from the start date and end date
  l_start_date_year:=to_number(to_char(p_effective_start_date,'YYYY'));
  l_end_date_year  :=to_number(to_char(p_effective_end_date,'YYYY'));
  IF ( l_start_date_year = l_end_date_year) THEN
       l_year := l_start_date_year;
  ELSE --Not a calendar month payroll
      OPEN c_get_year(p_assignment_id,p_effective_start_date);
      Hr_Utility.set_location('p_assignment_id :'||p_assignment_id, 5);
      Hr_Utility.set_location('p_effective_start_date :'||p_effective_start_date, 6);
      FETCH c_get_year INTO l_year;
      IF c_get_year%NOTFOUND THEN
       Hr_Utility.set_location('cursor not found', 6);
       l_year := to_number(to_char(p_effective_start_date,'YYYY'));
      END IF;
      CLOSE c_get_year;
  END IF;
 Hr_Utility.set_location('Leaving :'||l_proc_name, 100);
 RETURN l_year;

EXCEPTION
 WHEN OTHERS THEN
   Hr_Utility.set_location('Exception occurred at :'||l_proc_name, 120);
   RETURN -1;
END Get_Year;

-- ============================================================================
-- ~ Update_Record_Values :
-- ============================================================================
PROCEDURE Update_Record_Values
           (p_ext_rcd_id            IN ben_ext_rcd.ext_rcd_id%TYPE
           ,p_ext_data_element_name IN ben_ext_data_elmt.NAME%TYPE
           ,p_data_element_value    IN ben_ext_rslt_dtl.val_01%TYPE
           ,p_data_ele_seqnum       IN Number
           ,p_ext_dtl_rec           IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
            ) IS
   CURSOR csr_seqnum (c_ext_rcd_id            IN ben_ext_rcd.ext_rcd_id%TYPE
                     ,c_ext_data_element_name IN ben_ext_data_elmt.NAME%TYPE
                      ) IS
      SELECT der.ext_data_elmt_id,
             der.seq_num,
             ede.NAME
        FROM ben_ext_data_elmt_in_rcd der
             ,ben_ext_data_elmt        ede
       WHERE der.ext_rcd_id = c_ext_rcd_id
         AND ede.ext_data_elmt_id = der.ext_data_elmt_id
         AND ede.NAME             LIKE '%'|| c_ext_data_element_name
       ORDER BY seq_num;

   l_seqnum_rec        csr_seqnum%ROWTYPE;
   l_proc_name         Varchar2(150):= g_proc_name||'Update_Record_Values';
   l_ext_dtl_rec_nc    ben_ext_rslt_dtl%ROWTYPE;
BEGIN

 Hr_Utility.set_location('Entering :'||l_proc_name, 5);
 -- nocopy changes
 l_ext_dtl_rec_nc := p_ext_dtl_rec;

 IF p_data_ele_seqnum IS NULL THEN
    OPEN csr_seqnum ( c_ext_rcd_id            => p_ext_rcd_id
                     ,c_ext_data_element_name => p_ext_data_element_name);
    FETCH csr_seqnum INTO l_seqnum_rec;
    IF csr_seqnum%NOTFOUND THEN
       CLOSE csr_seqnum;
    ELSE
       CLOSE csr_seqnum;
    END IF;
 ELSE
    l_seqnum_rec.seq_num := p_data_ele_seqnum;
 END IF;

 IF l_seqnum_rec.seq_num = 1 THEN
    p_ext_dtl_rec.val_01 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 2 THEN
    p_ext_dtl_rec.val_02 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 3 THEN
    p_ext_dtl_rec.val_03 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 4 THEN
    p_ext_dtl_rec.val_04 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 5 THEN
    p_ext_dtl_rec.val_05 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 6 THEN
    p_ext_dtl_rec.val_06 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 7 THEN
    p_ext_dtl_rec.val_07 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 8 THEN
    p_ext_dtl_rec.val_08 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 9 THEN
    p_ext_dtl_rec.val_09 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 10 THEN
    p_ext_dtl_rec.val_10 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 11 THEN
    p_ext_dtl_rec.val_11 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 12 THEN
    p_ext_dtl_rec.val_12 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 13 THEN
    p_ext_dtl_rec.val_13 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 14 THEN
    p_ext_dtl_rec.val_14 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 15 THEN
    p_ext_dtl_rec.val_15 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 16 THEN
    p_ext_dtl_rec.val_16 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 17 THEN
    p_ext_dtl_rec.val_17 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 18 THEN
    p_ext_dtl_rec.val_18 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 19 THEN
    p_ext_dtl_rec.val_19 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 20 THEN
    p_ext_dtl_rec.val_20 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 21 THEN
    p_ext_dtl_rec.val_21 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 22 THEN
    p_ext_dtl_rec.val_22 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 23THEN
    p_ext_dtl_rec.val_23 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 24 THEN
    p_ext_dtl_rec.val_24 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 25 THEN
    p_ext_dtl_rec.val_25 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 26 THEN
    p_ext_dtl_rec.val_26 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 27 THEN
    p_ext_dtl_rec.val_27 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 28 THEN
    p_ext_dtl_rec.val_28 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 29 THEN
    p_ext_dtl_rec.val_29 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 30 THEN
    p_ext_dtl_rec.val_30 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 31 THEN
    p_ext_dtl_rec.val_31 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 32 THEN
    p_ext_dtl_rec.val_32 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 33 THEN
    p_ext_dtl_rec.val_33 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 34 THEN
    p_ext_dtl_rec.val_34 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 35 THEN
    p_ext_dtl_rec.val_35 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 36 THEN
    p_ext_dtl_rec.val_36 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 37 THEN
    p_ext_dtl_rec.val_37 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 38 THEN
    p_ext_dtl_rec.val_38 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 39 THEN
    p_ext_dtl_rec.val_39 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 40 THEN
    p_ext_dtl_rec.val_40 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 41 THEN
    p_ext_dtl_rec.val_41 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 42 THEN
    p_ext_dtl_rec.val_42 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 43 THEN
    p_ext_dtl_rec.val_43 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 44 THEN
    p_ext_dtl_rec.val_44 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 45 THEN
    p_ext_dtl_rec.val_45 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 46 THEN
    p_ext_dtl_rec.val_46 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 47 THEN
    p_ext_dtl_rec.val_47 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 48 THEN
    p_ext_dtl_rec.val_48 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 49 THEN
    p_ext_dtl_rec.val_49 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 50 THEN
    p_ext_dtl_rec.val_50 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 51 THEN
    p_ext_dtl_rec.val_51 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 52 THEN
    p_ext_dtl_rec.val_52 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 53 THEN
    p_ext_dtl_rec.val_53 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 54 THEN
    p_ext_dtl_rec.val_54 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 55 THEN
    p_ext_dtl_rec.val_55 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 56 THEN
    p_ext_dtl_rec.val_56 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 57 THEN
    p_ext_dtl_rec.val_57 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 58 THEN
    p_ext_dtl_rec.val_58 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 58 THEN
    p_ext_dtl_rec.val_58 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 59 THEN
    p_ext_dtl_rec.val_59 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 60 THEN
    p_ext_dtl_rec.val_60 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 61 THEN
    p_ext_dtl_rec.val_61 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 62 THEN
    p_ext_dtl_rec.val_62 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 63 THEN
    p_ext_dtl_rec.val_63 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 64 THEN
    p_ext_dtl_rec.val_64 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 65 THEN
    p_ext_dtl_rec.val_65 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 66 THEN
    p_ext_dtl_rec.val_66 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 67 THEN
    p_ext_dtl_rec.val_67 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 68 THEN
    p_ext_dtl_rec.val_68 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 69 THEN
    p_ext_dtl_rec.val_69 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 70 THEN
    p_ext_dtl_rec.val_70 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 71 THEN
    p_ext_dtl_rec.val_71 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 72 THEN
    p_ext_dtl_rec.val_72 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 73 THEN
    p_ext_dtl_rec.val_73 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 74 THEN
    p_ext_dtl_rec.val_74 := p_data_element_value;
 ELSIF l_seqnum_rec.seq_num = 75 THEN
    p_ext_dtl_rec.val_75 := p_data_element_value;
 END IF;
 Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
 RETURN;
EXCEPTION
  WHEN Others THEN
    -- nocopy changes
    p_ext_dtl_rec := l_ext_dtl_rec_nc;
    RAISE;

END Update_Record_Values;

-- ============================================================================
-- ~ Ins_Rslt_Dtl : Inserts a record into the results detail record.
-- ============================================================================
PROCEDURE Ins_Rslt_Dtl(p_dtl_rec IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE) IS

l_proc_name   Varchar2(150) := g_proc_name||'Ins_Rslt_Dtl';
l_dtl_rec_nc  ben_ext_rslt_dtl%ROWTYPE;

BEGIN -- ins_rslt_dtl
--hr_utility.trace_on(null,'rk');
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;
  -- Get the next sequence NUMBER to insert a record into the table
  SELECT ben_ext_rslt_dtl_s .NEXTVAL INTO p_dtl_rec.ext_rslt_dtl_id FROM dual;
hr_utility.set_location(p_dtl_rec.EXT_RSLT_DTL_ID,10);
hr_utility.set_location(p_dtl_rec.EXT_RSLT_ID,10);
hr_utility.set_location(p_dtl_rec.BUSINESS_GROUP_ID,10);
hr_utility.set_location(p_dtl_rec.EXT_RCD_ID,10);
hr_utility.set_location(p_dtl_rec.PERSON_ID,10);
hr_utility.set_location(p_dtl_rec.VAL_01,10);
hr_utility.set_location(p_dtl_rec.VAL_02,10);
hr_utility.set_location(p_dtl_rec.VAL_03,10);
hr_utility.set_location(p_dtl_rec.VAL_04,10);
hr_utility.set_location(p_dtl_rec.VAL_05,10);
hr_utility.set_location(p_dtl_rec.VAL_06,10);
hr_utility.set_location(p_dtl_rec.VAL_07,10);
hr_utility.set_location(p_dtl_rec.VAL_08,10);
hr_utility.set_location(p_dtl_rec.VAL_09,10);
hr_utility.set_location(p_dtl_rec.VAL_10,10);
hr_utility.set_location(p_dtl_rec.VAL_11,10);
hr_utility.set_location(p_dtl_rec.VAL_12,10);
hr_utility.set_location(p_dtl_rec.VAL_13,10);
hr_utility.set_location(p_dtl_rec.VAL_14,10);
hr_utility.set_location(p_dtl_rec.VAL_15,10);
hr_utility.set_location(p_dtl_rec.VAL_16,10);
hr_utility.set_location(p_dtl_rec.VAL_17,10);
hr_utility.set_location(p_dtl_rec.VAL_19,10);
hr_utility.set_location(p_dtl_rec.VAL_18,10);
hr_utility.set_location(p_dtl_rec.VAL_20,10);
hr_utility.set_location(p_dtl_rec.VAL_21,10);
hr_utility.set_location(p_dtl_rec.VAL_22,10);
hr_utility.set_location(p_dtl_rec.VAL_23,10);
hr_utility.set_location(p_dtl_rec.VAL_24,10);
hr_utility.set_location(p_dtl_rec.VAL_25,10);
hr_utility.set_location(p_dtl_rec.VAL_26,10);
hr_utility.set_location(p_dtl_rec.VAL_27,10);
hr_utility.set_location(p_dtl_rec.VAL_28,10);
hr_utility.set_location(p_dtl_rec.VAL_29,10);
hr_utility.set_location(p_dtl_rec.VAL_30,10);
hr_utility.set_location(p_dtl_rec.VAL_31,10);
hr_utility.set_location(p_dtl_rec.VAL_32,10);
hr_utility.set_location(p_dtl_rec.VAL_33,10);
hr_utility.set_location(p_dtl_rec.VAL_34,10);
hr_utility.set_location(p_dtl_rec.VAL_35,10);
hr_utility.set_location(p_dtl_rec.VAL_36,10);
hr_utility.set_location(p_dtl_rec.VAL_37,10);
hr_utility.set_location(p_dtl_rec.VAL_38,10);
hr_utility.set_location(p_dtl_rec.VAL_39,10);
hr_utility.set_location(p_dtl_rec.VAL_40,10);
hr_utility.set_location(p_dtl_rec.VAL_41,10);
hr_utility.set_location(p_dtl_rec.VAL_42,10);
hr_utility.set_location(p_dtl_rec.VAL_43,10);
hr_utility.set_location(p_dtl_rec.VAL_44,10);
hr_utility.set_location(p_dtl_rec.VAL_45,10);
hr_utility.set_location(p_dtl_rec.VAL_46,10);
hr_utility.set_location(p_dtl_rec.VAL_47,10);
hr_utility.set_location(p_dtl_rec.VAL_48,10);
hr_utility.set_location(p_dtl_rec.VAL_49,10);
hr_utility.set_location(p_dtl_rec.VAL_50,10);
hr_utility.set_location(p_dtl_rec.VAL_51,10);
hr_utility.set_location(p_dtl_rec.VAL_52,10);
hr_utility.set_location(p_dtl_rec.VAL_53,10);
hr_utility.set_location(p_dtl_rec.VAL_54,10);
hr_utility.set_location(p_dtl_rec.VAL_55,10);
hr_utility.set_location(p_dtl_rec.VAL_56,10);
hr_utility.set_location(p_dtl_rec.VAL_57,10);
hr_utility.set_location(p_dtl_rec.VAL_58,10);
hr_utility.set_location(p_dtl_rec.VAL_59,10);
hr_utility.set_location(p_dtl_rec.VAL_60,10);
hr_utility.set_location(p_dtl_rec.VAL_61,10);
hr_utility.set_location(p_dtl_rec.VAL_62,10);
hr_utility.set_location(p_dtl_rec.VAL_63,10);
hr_utility.set_location(p_dtl_rec.VAL_64,10);
hr_utility.set_location(p_dtl_rec.VAL_65,10);
hr_utility.set_location(p_dtl_rec.VAL_66,10);
hr_utility.set_location(p_dtl_rec.VAL_67,10);
hr_utility.set_location(p_dtl_rec.VAL_68,10);
hr_utility.set_location(p_dtl_rec.VAL_69,10);
hr_utility.set_location(p_dtl_rec.VAL_70,10);
hr_utility.set_location(p_dtl_rec.VAL_71,10);
hr_utility.set_location(p_dtl_rec.VAL_72,10);
hr_utility.set_location(p_dtl_rec.VAL_73,10);
hr_utility.set_location(p_dtl_rec.VAL_74,10);
hr_utility.set_location(p_dtl_rec.VAL_75,10);
hr_utility.set_location(p_dtl_rec.CREATED_BY,10);
hr_utility.set_location(p_dtl_rec.CREATION_DATE,10);
hr_utility.set_location(p_dtl_rec.LAST_UPDATE_DATE,10);
hr_utility .set_location(p_dtl_rec.LAST_UPDATED_BY,10);
hr_utility.set_location(p_dtl_rec.LAST_UPDATE_LOGIN,10);
hr_utility.set_location(p_dtl_rec.PROGRAM_APPLICATION_ID,10);
hr_utility.set_location(p_dtl_rec.PROGRAM_ID,10);
hr_utility.set_location(p_dtl_rec.PROGRAM_UPDATE_DATE,10);
hr_utility.set_location(p_dtl_rec.REQUEST_ID,10);
hr_utility.set_location(p_dtl_rec.OBJECT_VERSION_NUMBER,10);
hr_utility.set_location(p_dtl_rec.PRMY_SORT_VAL,10);
hr_utility.set_location(p_dtl_rec.SCND_SORT_VAL,10);
hr_utility.set_location(p_dtl_rec.THRD_SORT_VAL,10);
hr_utility.set_location(p_dtl_rec.TRANS_SEQ_NUM,10);
hr_utility.set_location(p_dtl_rec.RCRD_SEQ_NUM,10);
  INSERT INTO ben_ext_rslt_dtl
  (EXT_RSLT_DTL_ID
  ,EXT_RSLT_ID
  ,BUSINESS_GROUP_ID
  ,EXT_RCD_ID
  ,PERSON_ID
  ,VAL_01
  ,VAL_02
  ,VAL_03
  ,VAL_04
  ,VAL_05
  ,VAL_06
  ,VAL_07
  ,VAL_08
  ,VAL_09
  ,VAL_10
  ,VAL_11
  ,VAL_12
  ,VAL_13
  ,VAL_14
  ,VAL_15
  ,VAL_16
  ,VAL_17
  ,VAL_19
  ,VAL_18
  ,VAL_20
  ,VAL_21
  ,VAL_22
  ,VAL_23
  ,VAL_24
  ,VAL_25
  ,VAL_26
  ,VAL_27
  ,VAL_28
  ,VAL_29
  ,VAL_30
  ,VAL_31
  ,VAL_32
  ,VAL_33
  ,VAL_34
  ,VAL_35
  ,VAL_36
  ,VAL_37
  ,VAL_38
  ,VAL_39
  ,VAL_40
  ,VAL_41
  ,VAL_42
  ,VAL_43
  ,VAL_44
  ,VAL_45
  ,VAL_46
  ,VAL_47
  ,VAL_48
  ,VAL_49
  ,VAL_50
  ,VAL_51
  ,VAL_52
  ,VAL_53
  ,VAL_54
  ,VAL_55
  ,VAL_56
  ,VAL_57
  ,VAL_58
  ,VAL_59
  ,VAL_60
  ,VAL_61
  ,VAL_62
  ,VAL_63
  ,VAL_64
  ,VAL_65
  ,VAL_66
  ,VAL_67
  ,VAL_68
  ,VAL_69
  ,VAL_70
  ,VAL_71
  ,VAL_72
  ,VAL_73
  ,VAL_74
  ,VAL_75
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,OBJECT_VERSION_NUMBER
  ,PRMY_SORT_VAL
  ,SCND_SORT_VAL
  ,THRD_SORT_VAL
  ,TRANS_SEQ_NUM
  ,RCRD_SEQ_NUM
  )
  VALUES
  ( p_dtl_rec.EXT_RSLT_DTL_ID
  , p_dtl_rec.EXT_RSLT_ID
  , p_dtl_rec.BUSINESS_GROUP_ID
  , p_dtl_rec.EXT_RCD_ID
  , p_dtl_rec.PERSON_ID
  ,p_dtl_rec.VAL_01
  ,p_dtl_rec.VAL_02
  ,p_dtl_rec.VAL_03
  ,p_dtl_rec.VAL_04
  ,p_dtl_rec.VAL_05
  ,p_dtl_rec.VAL_06
  ,p_dtl_rec.VAL_07
  ,p_dtl_rec.VAL_08
  ,p_dtl_rec.VAL_09
  ,p_dtl_rec.VAL_10
  ,p_dtl_rec.VAL_11
  ,p_dtl_rec.VAL_12
  ,p_dtl_rec.VAL_13
  ,p_dtl_rec.VAL_14
  ,p_dtl_rec.VAL_15
  ,p_dtl_rec.VAL_16
  ,p_dtl_rec.VAL_17
  ,p_dtl_rec.VAL_19
  ,p_dtl_rec.VAL_18
  ,p_dtl_rec.VAL_20
  ,p_dtl_rec.VAL_21
  ,p_dtl_rec.VAL_22
  ,p_dtl_rec.VAL_23
  ,p_dtl_rec.VAL_24
  ,p_dtl_rec.VAL_25
  ,p_dtl_rec.VAL_26
  ,p_dtl_rec.VAL_27
  ,p_dtl_rec.VAL_28
  ,p_dtl_rec.VAL_29
  ,p_dtl_rec.VAL_30
  ,p_dtl_rec.VAL_31
  ,p_dtl_rec.VAL_32
  ,p_dtl_rec.VAL_33
  ,p_dtl_rec.VAL_34
  ,p_dtl_rec.VAL_35
  ,p_dtl_rec.VAL_36
  ,p_dtl_rec.VAL_37
  ,p_dtl_rec.VAL_38
  ,p_dtl_rec.VAL_39
  ,p_dtl_rec.VAL_40
  ,p_dtl_rec.VAL_41
  ,p_dtl_rec.VAL_42
  ,p_dtl_rec.VAL_43
  ,p_dtl_rec.VAL_44
  ,p_dtl_rec.VAL_45
  ,p_dtl_rec.VAL_46
  ,p_dtl_rec.VAL_47
  ,p_dtl_rec.VAL_48
  ,p_dtl_rec.VAL_49
  ,p_dtl_rec.VAL_50
  ,p_dtl_rec.VAL_51
  ,p_dtl_rec.VAL_52
  ,p_dtl_rec.VAL_53
  ,p_dtl_rec.VAL_54
  ,p_dtl_rec.VAL_55
  ,p_dtl_rec.VAL_56
  ,p_dtl_rec.VAL_57
  ,p_dtl_rec.VAL_58
  ,p_dtl_rec.VAL_59
  ,p_dtl_rec.VAL_60
  ,p_dtl_rec.VAL_61
  ,p_dtl_rec.VAL_62
  ,p_dtl_rec.VAL_63
  ,p_dtl_rec.VAL_64
  ,p_dtl_rec.VAL_65
  ,p_dtl_rec.VAL_66
  ,p_dtl_rec.VAL_67
  ,p_dtl_rec.VAL_68
  ,p_dtl_rec.VAL_69
  ,p_dtl_rec.VAL_70
  ,p_dtl_rec.VAL_71
  ,p_dtl_rec.VAL_72
  ,p_dtl_rec.VAL_73
  ,p_dtl_rec.VAL_74
  ,p_dtl_rec.VAL_75
  ,p_dtl_rec.CREATED_BY
  ,p_dtl_rec.CREATION_DATE
  ,p_dtl_rec.LAST_UPDATE_DATE
  ,p_dtl_rec.LAST_UPDATED_BY
  ,p_dtl_rec.LAST_UPDATE_LOGIN
  ,p_dtl_rec.PROGRAM_APPLICATION_ID
  ,p_dtl_rec.PROGRAM_ID
  ,p_dtl_rec.PROGRAM_UPDATE_DATE
  ,p_dtl_rec.REQUEST_ID
  ,p_dtl_rec.OBJECT_VERSION_NUMBER
  ,p_dtl_rec.PRMY_SORT_VAL
  ,p_dtl_rec.SCND_SORT_VAL
  ,p_dtl_rec.THRD_SORT_VAL
  ,p_dtl_rec.TRANS_SEQ_NUM
  ,p_dtl_rec.RCRD_SEQ_NUM
  );
  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
 -- hr_utility.trace_off;
  RETURN;

EXCEPTION
  WHEN Others THEN
    Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
    p_dtl_rec := l_dtl_rec_nc;
    RAISE;
END Ins_Rslt_Dtl;

-- ============================================================================
-- ~ Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- ============================================================================
PROCEDURE Upd_Rslt_Dtl(p_dtl_rec IN ben_ext_rslt_dtl %ROWTYPE ) IS

l_proc_name Varchar2(150):= g_proc_name||'upd_rslt_dtl';

BEGIN -- Upd_Rslt_Dtl
  UPDATE ben_ext_rslt_dtl
  SET VAL_01                 = p_dtl_rec.VAL_01
     ,VAL_02                 = p_dtl_rec.VAL_02
     ,VAL_03                 = p_dtl_rec.VAL_03
     ,VAL_04                 = p_dtl_rec.VAL_04
     ,VAL_05                 = p_dtl_rec.VAL_05
     ,VAL_06                 = p_dtl_rec.VAL_06
     ,VAL_07                 = p_dtl_rec.VAL_07
     ,VAL_08                 = p_dtl_rec.VAL_08
     ,VAL_09                 = p_dtl_rec.VAL_09
     ,VAL_10                 = p_dtl_rec.VAL_10
     ,VAL_11                 = p_dtl_rec.VAL_11
     ,VAL_12                 = p_dtl_rec.VAL_12
     ,VAL_13                 = p_dtl_rec.VAL_13
     ,VAL_14                 = p_dtl_rec.VAL_14
     ,VAL_15                 = p_dtl_rec.VAL_15
     ,VAL_16                 = p_dtl_rec.VAL_16
     ,VAL_17                 = p_dtl_rec.VAL_17
     ,VAL_19                 = p_dtl_rec.VAL_19
     ,VAL_18                 = p_dtl_rec.VAL_18
     ,VAL_20                 = p_dtl_rec.VAL_20
     ,VAL_21                 = p_dtl_rec.VAL_21
     ,VAL_22                 = p_dtl_rec.VAL_22
     ,VAL_23                 = p_dtl_rec.VAL_23
     ,VAL_24                 = p_dtl_rec.VAL_24
     ,VAL_25                 = p_dtl_rec.VAL_25
     ,VAL_26                 = p_dtl_rec.VAL_26
     ,VAL_27                 = p_dtl_rec.VAL_27
     ,VAL_28                 = p_dtl_rec.VAL_28
     ,VAL_29                 = p_dtl_rec.VAL_29
     ,VAL_30                 = p_dtl_rec.VAL_30
     ,VAL_31                 = p_dtl_rec.VAL_31
     ,VAL_32                 = p_dtl_rec.VAL_32
     ,VAL_33                 = p_dtl_rec.VAL_33
     ,VAL_34                 = p_dtl_rec.VAL_34
     ,VAL_35                 = p_dtl_rec.VAL_35
     ,VAL_36                 = p_dtl_rec.VAL_36
     ,VAL_37                 = p_dtl_rec.VAL_37
     ,VAL_38                 = p_dtl_rec.VAL_38
     ,VAL_39                 = p_dtl_rec.VAL_39
     ,VAL_40                 = p_dtl_rec.VAL_40
     ,VAL_41                 = p_dtl_rec.VAL_41
     ,VAL_42                 = p_dtl_rec.VAL_42
     ,VAL_43                 = p_dtl_rec.VAL_43
     ,VAL_44                 = p_dtl_rec.VAL_44
     ,VAL_45                 = p_dtl_rec.VAL_45
     ,VAL_46                 = p_dtl_rec.VAL_46
     ,VAL_47                 = p_dtl_rec.VAL_47
     ,VAL_48                 = p_dtl_rec.VAL_48
     ,VAL_49                 = p_dtl_rec.VAL_49
     ,VAL_50                 = p_dtl_rec.VAL_50
     ,VAL_51                 = p_dtl_rec.VAL_51
     ,VAL_52                 = p_dtl_rec.VAL_52
     ,VAL_53                 = p_dtl_rec.VAL_53
     ,VAL_54                 = p_dtl_rec.VAL_54
     ,VAL_55                 = p_dtl_rec.VAL_55
     ,VAL_56                 = p_dtl_rec.VAL_56
     ,VAL_57                 = p_dtl_rec.VAL_57
     ,VAL_58                 = p_dtl_rec.VAL_58
     ,VAL_59                 = p_dtl_rec.VAL_59
     ,VAL_60                 = p_dtl_rec.VAL_60
     ,VAL_61                 = p_dtl_rec.VAL_61
     ,VAL_62                 = p_dtl_rec.VAL_62
     ,VAL_63                 = p_dtl_rec.VAL_63
     ,VAL_64                 = p_dtl_rec.VAL_64
     ,VAL_65                 = p_dtl_rec.VAL_65
     ,VAL_66                 = p_dtl_rec.VAL_66
     ,VAL_67                 = p_dtl_rec.VAL_67
     ,VAL_68                 = p_dtl_rec.VAL_68
     ,VAL_69                 = p_dtl_rec.VAL_69
     ,VAL_70                 = p_dtl_rec.VAL_70
     ,VAL_71                 = p_dtl_rec.VAL_71
     ,VAL_72                 = p_dtl_rec.VAL_72
     ,VAL_73                 = p_dtl_rec.VAL_73
     ,VAL_74                 = p_dtl_rec.VAL_74
     ,VAL_75                 = p_dtl_rec.VAL_75
     ,OBJECT_VERSION_NUMBER  = p_dtl_rec.OBJECT_VERSION_NUMBER
     ,THRD_SORT_VAL          = p_dtl_rec.THRD_SORT_VAL
     ,prmy_sort_val          =p_dtl_rec.prmy_sort_val
  WHERE ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  RETURN;

EXCEPTION
  WHEN Others THEN
     RAISE;
END Upd_Rslt_Dtl;

-- ===============================================================================
-- ~ Get_Balance_Value
-- ===============================================================================
FUNCTION Get_Balance_Value ( p_assignment_id         IN Number  ,
                             p_business_group_id     IN Number  ,
                             p_balance_name          IN VARCHAR2,
                             p_dimension_name        IN VARCHAR2,
                             p_start_date            IN DATE    ,
                             p_end_date              IN DATE
     			    )
RETURN NUMBER IS

CURSOR csr_get_def_bal_type_id(c_balance_name VARCHAR2,c_dimension_name VARCHAR2)  IS
SELECT defined_balance_id
FROM  pay_defined_balances pdb,
      pay_balance_types pbt,
      pay_balance_dimensions pbd
WHERE pbt.balance_name =c_balance_name
  AND pbd.legislation_code='NL'
  AND pbd.DIMENSION_NAME=c_dimension_name
  AND pdb.balance_type_id = pbt.balance_type_id
  AND pdb.balance_dimension_id = pbd.balance_dimension_id;

l_proc_name           Varchar2(150) :=g_proc_name || 'Get_Balance_Value';
l_def_bal_type_id NUMBER:=0;
l_balance_amount  NUMBER:=0;
l_bal_total_amt   NUMBER:=0;
asgact_rec        csr_asg_act%ROWTYPE;
BEGIN
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

OPEN csr_get_def_bal_type_id(p_balance_name,p_dimension_name);
FETCH csr_get_def_bal_type_id INTO l_def_bal_type_id;
CLOSE csr_get_def_bal_type_id;
Hr_Utility.set_location(' l_def_bal_type_id '   ||l_def_bal_type_id,15);
  IF l_def_bal_type_id IS NOT NULL THEN
  --Get the Assignment action ids for this assignment
        OPEN csr_asg_act(c_assignment_id => p_assignment_id
                   ,c_payroll_id    => g_extract_params (p_business_group_id).payroll_id
                   ,c_con_set_id    => g_extract_params (p_business_group_id).con_set_id
                   ,c_start_date    => p_start_date
                   ,c_end_date      => p_end_date
                   );
         LOOP
            FETCH csr_asg_act INTO asgact_rec;
            EXIT WHEN csr_asg_act%NOTFOUND;
            l_balance_amount := Pay_Balance_Pkg.get_value
                      (p_defined_balance_id   => l_def_bal_type_id,
                       p_assignment_action_id => asgact_rec.assignment_action_id );
            l_bal_total_amt := l_bal_total_amt + Nvl(l_balance_amount,0);
            Hr_Utility.set_location(' l_balance_amount '  ||l_balance_amount,25);
            Hr_Utility.set_location(' l_bal_total_amt  '   ||l_bal_total_amt,25);
         END LOOP; -- For Loop
         CLOSE csr_asg_act;
    END IF;  -- If l_def_bal_type_id

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
RETURN l_bal_total_amt;

EXCEPTION
   WHEN OTHERS THEN
      --p_error_message :='SQL-ERRM :'||SQLERRM;
      CLOSE csr_asg_act;
      Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,30);
      Hr_Utility.set_location('Exception Occured Leaving: '||l_proc_name,40);
      RETURN 0;
END Get_Balance_Value;

-- ===============================================================================
-- ~ Get_Start_Date_PTP : function to get the Start Date of paticiaption
--  which is taken as Start date of PGGM GEN Info element entry for that assignment
-- ===============================================================================
FUNCTION Get_Start_Date_PTP
                 (  p_assignment_id       IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
                 )
RETURN NUMBER IS
CURSOR csr_get_st_dt_of_ptp(c_asg_id IN Number,c_date_earned IN Date) IS
SELECT to_char(pee.effective_start_date,'YYYYMMDD')
  FROM pay_element_types_f pet, pay_element_entries_f pee
 WHERE pet.element_name like 'PGGM Pensions General Information'
   AND pee.element_type_id =pet.element_type_id
   AND pee.assignment_id=c_asg_id
   AND pee.effective_start_date <= g_extract_params(p_business_group_id).extract_end_date;

l_proc_name    Varchar2(150) := g_proc_name ||'Get_Start_Date_PTP';
l_ret_val      Number:=0;
l_st_dt_of_ptp varchar2(8);
--
BEGIN
 Hr_Utility.set_location('Entering:   '||l_proc_name, 10);
 OPEN csr_get_st_dt_of_ptp(p_assignment_id,p_date_earned);
 FETCH csr_get_st_dt_of_ptp INTO l_st_dt_of_ptp;
 Hr_Utility.set_location('l_st_dt_of_ptp:   '||l_st_dt_of_ptp, 20);
 IF (csr_get_st_dt_of_ptp%FOUND) THEN
    p_data_element_value:=l_st_dt_of_ptp;
    l_ret_val:=0;
 END IF;
 Hr_Utility.set_location('p_data_element_value:   '||p_data_element_value, 30);
 CLOSE csr_get_st_dt_of_ptp;
 Hr_Utility.set_location('Leaving:   '||l_proc_name, 60);
RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Start_Date_PTP;

-- ===============================================================================
--Get a string of Zeros of required length
-- ===============================================================================
FUNCTION Get_Zeros_String(Num NUMBER)
RETURN varchar2 IS
zeros    varchar2(250):='';
BEGIN

      FOR i IN 0..Num-1
      LOOP
       zeros:=zeros||'0';
      END LOOP;
      RETURN zeros;

END Get_Zeros_String;

-- =============================================================================
-- Process_Ext_Rslt_Dtl_Rec:
-- =============================================================================
PROCEDURE  Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    IN per_all_assignments.assignment_id%TYPE
            ,p_organization_id  IN per_all_assignments.organization_id%TYPE DEFAULT NULL
            ,p_effective_date   IN Date
            ,p_ext_dtl_rcd_id   IN ben_ext_rcd.ext_rcd_id%TYPE
            ,p_rslt_rec         IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE
            ,p_asgaction_no     IN Number  DEFAULT NULL
            ,p_error_message    OUT NOCOPY Varchar2) IS

 CURSOR csr_rule_ele
          (c_ext_rcd_id  IN ben_ext_data_elmt_in_rcd.ext_rcd_id%TYPE) IS
   SELECT  a.ext_data_elmt_in_rcd_id
          ,a.seq_num
          ,a.sprs_cd
          ,a.strt_pos
          ,a.dlmtr_val
          ,a.rqd_flag
          ,b.ext_data_elmt_id
          ,b.data_elmt_typ_cd
          ,b.data_elmt_rl
          ,b.NAME
          ,Hr_General.decode_lookup('BEN_EXT_FRMT_MASK', b.frmt_mask_cd) frmt_mask_cd
          ,b.frmt_mask_cd frmt_mask_lookup_cd
          ,b.string_val
          ,b.dflt_val
          ,b.max_length_num
          ,b.just_cd
     FROM  ben_ext_data_elmt           b,
           ben_ext_data_elmt_in_rcd    a
    WHERE  a.ext_data_elmt_id = b.ext_data_elmt_id
      AND  b.data_elmt_typ_cd = 'R'
      AND  a.ext_rcd_id       = c_ext_rcd_id
      --  AND  a.hide_flag        = 'N'
     ORDER BY a.seq_num;

   CURSOR csr_ff_type ( c_formula_type_id IN ff_formulas_f.formula_id%TYPE
                       ,c_effective_date     IN Date) IS
    SELECT formula_type_id
      FROM ff_formulas_f
     WHERE formula_id = c_formula_type_id
       AND c_effective_date BETWEEN effective_start_date
                                AND effective_end_date;

   CURSOR c_get_org_id IS
   SELECT organization_id,business_group_id
     FROM per_all_assignments_f
   WHERE  assignment_id = p_assignment_id
     AND  business_group_id = g_business_group_id
     AND  p_effective_date BETWEEN effective_start_date
                                AND effective_end_date;



  l_proc_name           Varchar2(150) := g_proc_name ||'Process_Ext_Rslt_Dtl_Rec';
  l_formula_type_id     ff_formulas_f.formula_id%TYPE;
  l_outputs             Ff_Exec.outputs_t;
  l_ff_value            ben_ext_rslt_dtl.val_01%TYPE;
  l_ff_value_fmt        ben_ext_rslt_dtl.val_01%TYPE;
  l_org_id              per_all_assignments_f.organization_id%TYPE;
  l_bgid                per_all_assignments_f.business_group_id%TYPE;


BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   OPEN c_get_org_id;
   FETCH c_get_org_id INTO l_org_id,l_bgid;
   CLOSE c_get_org_id;
   Hr_Utility.set_location('p_ext_dtl_rcd_id: '||p_ext_dtl_rcd_id , 5);
   Hr_Utility .set_location('p_assignment_id: '||p_assignment_id, 5);
   FOR i IN  csr_rule_ele( c_ext_rcd_id => p_ext_dtl_rcd_id )
   LOOP
    OPEN  csr_ff_type (c_formula_type_id => i.data_elmt_rl
                     ,c_effective_date  => p_effective_date);
    FETCH csr_ff_type  INTO l_formula_type_id ;
    CLOSE csr_ff_type;
    Hr_Utility.set_location('l_formula_type_id: '||l_formula_type_id, 5);

    IF l_formula_type_id = -413 THEN -- person level rule
       l_outputs :=  Benutils.formula
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
        l_ff_value := l_outputs(l_outputs.FIRST).VALUE;
        BEGIN
          IF i.frmt_mask_lookup_cd IS NOT NULL AND
             l_ff_value IS NOT NULL THEN
             IF Substr(i.frmt_mask_lookup_cd,1,1) = 'N' THEN
               Hr_Utility.set_location('..Applying NUMBER format mask  :ben_ext_fmt.apply_format_mask'   ,50);
               l_ff_value_fmt := Ben_Ext_Fmt .apply_format_mask (To_Number(l_ff_value), i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            ELSIF Substr(i.frmt_mask_lookup_cd,1,1) = 'D' THEN
               Hr_Utility.set_location('..Applying Date format mask :ben_ext_fmt.apply_format_mask'   ,55);
               l_ff_value_fmt := Ben_Ext_Fmt .apply_format_mask (Fnd_Date.canonical_to_date(l_ff_value),
                                                               i.frmt_mask_cd);
               l_ff_value     := l_ff_value_fmt;
            END IF;
          END  IF;
        EXCEPTION  -- incase l_ff_value is not valid for formatting, just don't format it.
            WHEN Others THEN
            NULL;
        END;
        Update_Record_Values (p_ext_rcd_id            => p_ext_dtl_rcd_id
                             ,p_ext_data_element_name => NULL
                             ,p_data_element_value    => l_ff_value
                             ,p_data_ele_seqnum       => i.seq_num
                             ,p_ext_dtl_rec           => p_rslt_rec);
    END IF;
   END LOOP; --For i in  csr_rule_ele
   p_rslt_rec.prmy_sort_val := p_assignment_id;
   Ins_Rslt_Dtl(p_dtl_rec => p_rslt_rec);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
   WHEN Others THEN
    Hr_Utility.set_location('..error',85);
    Hr_Utility.set_location('SQL-ERRM :'||SQLERRM,87);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Process_Ext_Rslt_Dtl_Rec;

-- =============================================================================
-- Check_Addl_Assigs: Check if the person has any secondary active assigs within
-- the extract date range, then check the criteria and store it in PL/SQL table.
-- =============================================================================
FUNCTION Check_Addl_Assigs
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           ) RETURN Varchar2 IS

   l_return_value         Varchar2(50);
   bg_id                      per_all_assignments_f.business_group_id%TYPE;
   l_proc_name            Varchar2(150) := g_proc_name ||'Check_Addl_Assigs';
   l_sec_assg_rec         csr_sec_assg%ROWTYPE;
   l_effective_date       Date;
   l_criteria_value       Varchar2(2);
   l_warning_message      Varchar2(2000);
   l_error_message        Varchar2(2000);
   l_asg_type             per_all_assignments_f.assignment_type%TYPE;
   l_person_id            per_all_people_f.person_id%TYPE;
   l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   bg_id := p_business_group_id;

   IF NOT g_primary_assig.EXISTS(p_assignment_id) THEN
     l_return_value := 'NOTFOUND';
     Hr_Utility.set_location('..Not a Valid assignment: '||p_assignment_id, 6);
     RETURN l_return_value;
   ELSIF g_primary_assig (p_assignment_id).assignment_type IN ('B','E') THEN
     Hr_Utility.set_location('..Valid Assignment Type B : '||p_assignment_id, 6);
     l_person_id := g_primary_assig (p_assignment_id).person_id;
     l_asg_type  := g_primary_assig (p_assignment_id).assignment_type;
     -- Check if there are any other assignments which might be active within the
     -- specified extract date range
     FOR sec_asg_rec IN  csr_sec_assg
         (c_primary_assignment_id=> p_assignment_id
         ,c_person_id => g_primary_assig (p_assignment_id).person_id
         ,c_effective_date     => g_extract_params (bg_id).extract_end_date
         ,c_extract_start_date   => g_extract_params(bg_id).extract_start_date
         ,c_extract_end_date     => g_extract_params(bg_id).extract_end_date)
     LOOP
       l_sec_assg_rec   := sec_asg_rec;
       l_criteria_value := 'N';
       l_effective_date := Least(g_extract_params (bg_id).extract_end_date,
                                 l_sec_assg_rec.effective_end_date);
       Hr_Utility.set_location('..Checking for assignment id: '||
                             l_sec_assg_rec.assignment_id, 7);
       Hr_Utility.set_location('..p_effective_date : '||l_effective_date, 7);
       -- Call the main criteria function for this assignment to check if its a
       -- valid assignment that can be reported based on the criteria specified.
       --Note that this function adds the assignment id in its PL SQL table
       l_criteria_value := Pension_Criteria_Full_Profile
                          (p_assignment_id        => l_sec_assg_rec.assignment_id
                          ,p_effective_date       => l_effective_date
                          ,p_business_group_id    => p_business_group_id
                          ,p_warning_message      => l_warning_message
                          ,p_error_message        => l_error_message
                           );
       IF l_criteria_value ='Y' THEN
     l_return_value := 'FOUND';
   END IF;
     END LOOP; -- FOR sec_asg_rec
   END IF;
   Hr_Utility.set_location('..Assignment Count : '||g_primary_assig.Count, 7);
   Hr_Utility.set_location('..l_person_id : '||l_person_id, 7);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Check_Addl_Assigs;

-- =============================================================================
-- Create_Addl_Assignments:
-- =============================================================================
PROCEDURE Create_Addl_Assignments
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_person_id         IN Number
          ,p_no_asg_action     IN OUT NOCOPY Number
          ,p_error_message     OUT NOCOPY Varchar2)IS

   l_ele_type_id         pay_element_types_f.element_type_id %TYPE;
   l_prev_ele_type_id    pay_element_types_f.element_type_id %TYPE;
   l_valid_action        Varchar2(2);
   bg_id                     per_all_assignments_f.business_group_id%TYPE;
   l_ext_dfn_type        pqp_extract_attributes.ext_dfn_type  %TYPE;
   l_proc_name           Varchar2(150) := g_proc_name ||'Create_Addl_Assignments';
   l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
   l_organization_id     per_all_assignments_f.organization_id%TYPE;
   l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
   l_main_rec            csr_rslt_dtl%ROWTYPE;
   l_new_rec             csr_rslt_dtl%ROWTYPE;
   l_effective_date      Date;
   l_ext_rcd_id          ben_ext_rcd.ext_rcd_id %TYPE;
   l_record_num          Varchar2(20);
   l_return_value        Varchar2(2);
   l_conc_reqest_id      NUMBER;
   l_ext_rslt_id         NUMBER;
   l_ext_dfn_id          NUMBER;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   bg_id := p_business_group_id;
   l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
   l_ext_dfn_id  := Ben_Ext_Thread.g_ext_dfn_id;

   -- Get the Conc. request id
   OPEN  csr_req_id(c_ext_rslt_id       => l_ext_rslt_id
                    ,c_ext_dfn_id        => l_ext_dfn_id
                    ,c_business_group_id => p_business_group_id);
   FETCH csr_req_id INTO l_conc_reqest_id;
   CLOSE csr_req_id;

   FOR csr_rcd_rec IN csr_ext_rcd_id_hidden
                       (c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   LOOP
      l_ext_rcd_id := csr_rcd_rec.ext_rcd_id;

     Hr_Utility.set_location('l_ext_rcd_id: '||l_ext_rcd_id, 5);

    --These are single processing reCords
    IF g_ext_rcds(l_ext_rcd_id ).record_number  IN
      ('010','10h','020','030','040','060','070','080','081')THEN
        l_record_num := g_ext_rcds(l_ext_rcd_id).record_number;
        Hr_Utility.set_location('l_record_num: '||l_record_num, 5);
        OPEN csr_rslt_dtl
               (c_person_id      => p_person_id
               ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
               ,c_ext_dtl_rcd_id => l_ext_rcd_id
                );
        FETCH csr_rslt_dtl INTO l_main_rec;
        l_new_rec :=NULL;
        IF csr_rslt_dtl%NOTFOUND THEN
            l_new_rec.EXT_RSLT_ID:=Ben_Ext_Thread.g_ext_rslt_id;
            l_new_rec.BUSINESS_GROUP_ID:=bg_id;
            l_new_rec.EXT_RCD_ID:=l_ext_rcd_id;
            l_new_rec.PERSON_ID :=p_person_id;
            l_new_rec.val_01    :=l_record_num;
            l_new_rec.val_03    :='0000000000';
            l_new_rec.val_04    := g_per_details(g_person_id).national_identifier;
            l_new_rec.val_07    :='0';
            l_new_rec.val_08    := g_per_details(g_person_id).date_of_birth;
            l_new_rec.val_10    := g_per_details(g_person_id).last_name;
            l_new_rec.val_11    := g_per_details(g_person_id).prefix;
            l_new_rec.REQUEST_ID:= l_conc_reqest_id;
            IF l_record_num = '010' THEN
                l_new_rec.val_17    :=Get_Zeros_String(26);
                l_new_rec.val_30    :=Get_Zeros_String(30);
            ELSE
             IF l_record_num = '020' THEN
               l_new_rec.val_18    :=Get_Zeros_String(135);
             ELSE
               IF l_record_num = '030' THEN
                 l_new_rec.val_17    :=Get_Zeros_String(147);
               ELSE
                 IF l_record_num = '040' THEN
                    l_new_rec.val_20    :=Get_Zeros_String(109);
                 ELSE
                    IF l_record_num = '060' THEN
                        l_new_rec.val_17    :=Get_Zeros_String(2);
                        l_new_rec.val_20    :=Get_Zeros_String(124);
                    ELSE
                        IF l_record_num = '070' THEN
                           l_new_rec.val_16    :=Get_Zeros_String(155);
                        ELSE
                           IF l_record_num = '080' THEN
                             l_new_rec.val_17    :=Get_Zeros_String(150);
                           ELSE
                              IF l_record_num = '081' THEN
                                     l_new_rec.val_17    :=Get_Zeros_String(147);
                               END IF;
                           END IF;
                        END IF;
                    END IF;
                 END IF;
               END IF;
             END IF;
            END IF;
        ELSE
           l_new_rec:= l_main_rec;
        END IF;
        CLOSE csr_rslt_dtl;

        l_main_rec.object_version_NUMBER
                            := Nvl(l_main_rec.object_version_NUMBER,0) + 1;

        l_assignment_id     := p_assignment_id;
        l_organization_id   := g_primary_assig(p_assignment_id).organization_id;
        l_business_group_id := p_business_group_id;
        l_effective_date    := Least(g_extract_params(bg_id).extract_end_date ,
                                     g_primary_assig (p_assignment_id).effective_end_date);
        Hr_Utility.set_location('l_record_num: '||l_record_num, 25);
        l_return_value := Chk_If_Req_To_Extract
                          (p_assignment_id     => l_assignment_id
                          ,p_business_group_id => l_business_group_id
                          ,p_effective_date    => l_effective_date
                          ,p_record_num        => l_record_num
                          ,p_error_message     => p_error_message);
        Hr_Utility.set_location('l_return_value: '||l_return_value, 25);
        IF l_return_value = 'Y' THEN
           -- Re-Process the person level rule based data-element for the record
           -- along with appropiate effective date and assignment id
           Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    => l_assignment_id
            ,p_organization_id  => l_organization_id
            ,p_effective_date   => l_effective_date
            ,p_ext_dtl_rcd_id   => l_ext_rcd_id
            ,p_rslt_rec         => l_new_rec
            ,p_asgaction_no     => p_no_asg_action
            ,p_error_message    => p_error_message);
        END IF; -- IF l_return_value = 'Y'
    END IF;
   END LOOP;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Create_Addl_Assignments;

-- =============================================================================
-- Process_Addl_Assigs: Process all the assigs in the PL/SQL table for the
-- person and create the records accordingly.
-- =============================================================================
FUNCTION Process_Addl_Assigs
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           ) RETURN Number IS

   l_return_value         Number;
   bg_id                  per_all_assignments_f.business_group_id%TYPE;
   l_ele_type_id          pay_element_types_f.element_type_id %TYPE;
   l_prev_ele_type_id     pay_element_types_f.element_type_id  %TYPE;
   l_valid_action         Varchar2(2);
   l_no_asg_action        Number(5) := 0;
   l_proc_name            Varchar2(150) := g_proc_name ||'Process_Addl_Assigs';
   l_sec_assg_rec         csr_sec_assg%ROWTYPE;
   l_effective_date       Date;
   l_criteria_value       Varchar2(2);
   l_warning_message      Varchar2(2000);
   l_error_message        Varchar2(2000);
   l_asg_type             per_all_assignments_f.assignment_type %TYPE;
   l_main_rec             csr_rslt_dtl%ROWTYPE;
   l_person_id            per_all_people_f.person_id%TYPE;
   l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
   l_mutli_assig          Varchar2(150);
BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   l_mutli_assig := Check_Addl_Assigs
                     (p_assignment_id       => p_assignment_id
                     ,p_business_group_id   => p_business_group_id
                     ,p_effective_date      => p_effective_date
                     ,p_error_message       => p_error_message
                      );

   bg_id := p_business_group_id;
   IF g_primary_assig.EXISTS(p_assignment_id) THEN
     l_person_id := g_primary_assig (p_assignment_id).person_id;
     l_asg_type  := g_primary_assig (p_assignment_id).assignment_type;
   END IF;
   -- For each assignment for this person id check if additional rows need to be
   -- created and re-calculate the person level based fast-formulas.
   l_assignment_id := g_primary_assig.FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    Hr_Utility.set_location('..Checking for assignment : '||l_assignment_id, 7);
    IF g_primary_assig (l_assignment_id).person_id = l_person_id AND
       l_assignment_id <> p_assignment_id                           AND
       g_primary_assig (l_assignment_id).Assignment_Type = 'E' THEN

       Hr_Utility.set_location('..Valid Assignment : '||l_assignment_id, 8);
       Hr_Utility.set_location('..l_no_asg_action  : '||l_no_asg_action, 8);

       Create_Addl_Assignments
         (p_assignment_id     => l_assignment_id
         ,p_business_group_id => p_business_group_id
         ,p_person_id         => l_person_id
         ,p_no_asg_action     => l_no_asg_action
         ,p_error_message     => l_error_message
          );
       l_no_asg_action := l_no_asg_action + 1;
    END IF;
    l_assignment_id  := g_primary_assig.NEXT(l_assignment_id);

   END LOOP;
   IF l_asg_type = 'B' AND l_no_asg_action = 0 THEN
      -- =================================================================
      -- This mean that the extract created a row for the benefit's assig.
      -- record and that person does not have any assig. record
      -- within the extract date range specified.
      -- =================================================================
      FOR csr_rcd_rec IN csr_ext_rcd_id
                          (c_hide_flag   => 'N' -- N=No Y=Yes
                         ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
      -- Loop through each detail record for the extract
      LOOP
          OPEN csr_rslt_dtl
                (c_person_id      => l_person_id
                ,c_ext_rslt_id    => Ben_Ext_Thread .g_ext_rslt_id
                ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id
                 );
          FETCH csr_rslt_dtl INTO l_main_rec;
          WHILE csr_rslt_dtl%FOUND
          LOOP
             -- Delete for each detail record for the person
             DELETE ben_ext_rslt_dtl
              WHERE ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id
                AND person_id       = l_person_id;
             FETCH csr_rslt_dtl INTO l_main_rec;

          END LOOP; -- While csr_rslt_dtl%FOUND
          CLOSE csr_rslt_dtl;
      END LOOP; -- FOR csr_rcd_rec
   END IF;
   -- Delete all the hidden Records for the person
   FOR csr_rcd_rec IN csr_ext_rcd_id
                      (c_hide_flag   => 'Y' -- N=No Y=Yes
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   -- Loop through each detail record for the extract
   LOOP
    OPEN csr_rslt_dtl
          (c_person_id      => l_person_id
          ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
          ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id
           );
    FETCH csr_rslt_dtl INTO l_main_rec;
    WHILE csr_rslt_dtl%FOUND
    LOOP
       -- Delete for each detail record for the person
       DELETE ben_ext_rslt_dtl
        WHERE ext_rslt_dtl_id = l_main_rec.ext_rslt_dtl_id
          AND person_id       = l_person_id;
       FETCH csr_rslt_dtl INTO l_main_rec;
    END LOOP; -- While csr_rslt_dtl%FOUND
    CLOSE csr_rslt_dtl;
   END LOOP; -- FOR csr_rcd_rec

   -- Once the sec. record has been taken care of all the asg actions
   -- remove it from the PL/SQL table.
   l_assignment_id := g_primary_assig .FIRST;
   WHILE l_assignment_id IS NOT NULL
   LOOP
    IF g_primary_assig (l_assignment_id).person_id = l_person_id THEN
       g_primary_assig.DELETE(l_assignment_id);
    END IF;
    l_assignment_id  := g_primary_assig .NEXT(l_assignment_id);
   END LOOP;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Process_Addl_Assigs;
-- ===============================================================================
-- ~ Get_Country_Code : Function to get the Country Code
-- ===============================================================================
FUNCTION Get_Country_Code
                 (  p_assignment_id      IN NUMBER
                   ,p_business_group_id  IN NUMBER
                   ,p_date_earned        IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
                  )
 RETURN NUMBER IS
-- cursor to fetch country code stored in Address DDF for a person (Add_Attibute1)
 CURSOR csr_get_country_code(c_business_group_id NUMBER) IS
     SELECT hrl1.lookup_code
       FROM  per_addresses p_addr, hr_lookups hrl1
      WHERE p_addr.person_id = g_person_id
        AND hrl1.lookup_type='PQP_NL_STUCON_CODE_MAPPING'
        AND hrl1.meaning = p_addr.country
        AND g_extract_params(c_business_group_id).extract_end_date >= p_addr.date_from;

 l_proc_name  Varchar2(150) := g_proc_name ||'Get_Country_Code';
 l_ret_val number:=0;
 l_country_code varchar2(5);
BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

  OPEN csr_get_country_code(p_business_group_id);
  FETCH csr_get_country_code INTO l_country_code;
  IF csr_get_country_code%FOUND THEN
     p_data_element_value:=l_country_code;
     l_ret_val := 0;
  END IF;
  Hr_Utility.set_location('l_country_code:   '||l_country_code, 30);
  CLOSE csr_get_country_code;
  Hr_Utility.set_location('Leaving:   '||l_proc_name, 60);
RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN 1;
END Get_Country_Code;

-- =============================================================================
-- ~ Pension_Extract_Process: This is called by the conc. program and this is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================
PROCEDURE Pension_Extract_Process
           (errbuf                        OUT NOCOPY  Varchar2
           ,retcode                       OUT NOCOPY  Varchar2
           ,p_benefit_action_id           IN     Number
           ,p_ext_dfn_id                  IN     Number
           ,p_org_id                      IN     Number
           ,p_payroll_id                  IN     Number
           ,p_start_date                  IN     Varchar2
           ,p_end_date                    IN     Varchar2
           ,p_extract_type                IN     VARCHAR2
           ,p_business_group_id           IN     Number
           ,p_consolidation_set           IN     Number
           ,p_ext_rslt_id                 IN     Number DEFAULT NULL
) IS
   l_errbuff          Varchar2(3000);
   l_retcode          Number;
   l_session_id       Number;
   l_proc_name        Varchar2(150) := g_proc_name ||'Pension_Extract_Process';

BEGIN

     Hr_Utility.set_location('Entering: '||l_proc_name, 5);
     g_conc_request_id := Fnd_Global.conc_request_id;

    IF p_end_date < p_start_date THEN
       Fnd_Message.set_name('PQP','PQP_230869_END_BEFORE_START');
       Fnd_Message.raise_error;
    END IF;

    SELECT Userenv('SESSIONID') INTO l_session_id FROM dual;

     -- Delete values from the temporary table
     DELETE FROM pay_us_rpt_totals
     WHERE organization_name = 'NL PGGM Pension Extracts';

     --
     -- Insert into pay_us_rpt_totals so that we can refer to these parameters
     -- when we call the criteria formula for the pension extract.
     --
hr_utility.set_location('inserting into rpt totals : '||p_business_group_id,20);
     INSERT INTO pay_us_rpt_totals
     (session_id         -- Session id
     ,organization_name  -- Concurrent Program Name
     ,business_group_id  -- Business Group
     ,tax_unit_id        -- Concurrent Request Id
     ,value1             -- Extract Definition Id
     ,value2             -- Payroll Id
     ,value3             -- Consolidation Set
     ,value4             -- Organization Id
     ,value5             --
     ,value6             --
     ,attribute1         --
     ,attribute2         --
     ,attribute3         -- Extract Start Date
     ,attribute4         -- Extract End Date
     ,attribute5         -- Type of Extract
     )
     VALUES
     (l_session_id
     ,'NL PGGM Pension Extracts'
     ,p_business_group_id
     ,g_conc_request_id
     ,p_ext_dfn_id
     ,p_payroll_id
     ,p_consolidation_set
     ,p_org_id
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,p_start_date
     ,p_end_date
     ,p_extract_type
     );
     COMMIT;
     --
     -- Call the actual benefit extract process with the effective date as the
     -- extract end date along with the ext def. id and business group id.
     --
     Hr_Utility.set_location('..Calling Benefit Ext Process'||l_proc_name, 6);
     Ben_Ext_Thread.process
       (errbuf                     => l_errbuff,
        retcode                    => l_retcode,
        p_benefit_action_id        => NULL,
        p_ext_dfn_id               => p_ext_dfn_id,
        p_effective_date           => p_end_date,
        p_business_group_id        => p_business_group_id);

     Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

--hr_utility.trace_off;
EXCEPTION
     WHEN Others THEN
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
     RAISE;
END Pension_Extract_Process;

-- =============================================================================
-- Pension_Criteria_Full_Profile: The Main extract criteria that would be used
-- for the pension extract. This function decides the assignments that need
-- to be processed. The assignments that need not be processed are rejected
-- here. The criteria is to filter the assignments based on the org hierarchy
-- (only child organizations which are non-tax organizations are taken in account).
-- =============================================================================

FUNCTION Pension_Criteria_Full_Profile
           (p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
           ,p_effective_date       IN Date
           ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
           ,p_warning_message      OUT NOCOPY Varchar2
           ,p_error_message        OUT NOCOPY Varchar2
            ) RETURN Varchar2 IS
   -- =========================================
   -- ~ Type Of Extract(Full or Change)
   -- =========================================
   CURSOR csr_ext_attr (c_ext_dfn_id IN ben_ext_rslt.ext_dfn_id%TYPE) IS
      SELECT ext_dfn_type
        FROM pqp_extract_attributes
       WHERE ext_dfn_id = c_ext_dfn_id;

   -- Get the Conc. requests params based on the request id fetched
   CURSOR csr_ext_params (c_request_id        IN Number
                         ,c_ext_dfn_id        IN Number
                         ,c_business_group_id IN Number) IS
    SELECT   session_id         -- Session id
            ,organization_name  -- Concurrent Program Name
            ,business_group_id  -- Business Group
            ,tax_unit_id        -- Concurrent Request Id
            ,value1             -- Extract Definition Id
            ,value2             -- Payroll Id
            ,value3             -- Consolidation Set
            ,value4             -- Organization Id
            ,value5             --
            ,value6             --
            ,attribute1         --
            ,attribute2         --
            ,attribute3         -- Extract Start Date
            ,attribute4         -- Extract End Date
            ,attribute5         -- Type of Extract
        FROM pay_us_rpt_totals
       WHERE tax_unit_id       = c_request_id
         AND value1            = c_ext_dfn_id
         AND business_group_id = c_business_group_id;

   -- Get the Assignment Run level dimension id
   CURSOR csr_asg_dimId IS
      SELECT balance_dimension_id
        FROM pay_balance_dimensions
       WHERE legislation_code = 'NL'
         AND database_item_suffix = '_ASG_RUN';

   -- Get the Legislation Code and Curreny Code
   CURSOR csr_leg_code (c_business_group_id IN Number) IS
      SELECT pbg.legislation_code
            ,pbg.currency_code
        FROM per_business_groups_perf   pbg
       WHERE pbg.business_group_id = c_business_group_id;

   -- Cursor to Check if a org hierarchy is attached to the BG.
   -- If it is attached get the valid version as of the effective date.
   -- If a valid version is not found then do nothing.
   CURSOR c_get_org_hierarchy IS
   SELECT pos.org_structure_version_id
     FROM per_org_structure_versions_v pos,
          hr_organization_information hoi
    WHERE hoi.organization_id = p_business_group_id
      AND To_Number(hoi.org_information1) = pos.organization_structure_id
      AND Trunc(p_effective_date) BETWEEN date_from
                                      AND Nvl(date_to,Hr_Api.g_eot)
      AND hoi.org_information_context = 'NL_BG_INFO';

   -- Cursor to get the list of child orgs from the hierarchy if one exists.
   CURSOR c_get_children ( c_org_str_ver_id IN Number
                          ,c_org_id         IN Number) IS
   SELECT os.organization_id_child
     FROM (SELECT *
             FROM per_org_structure_elements a
            WHERE a.org_structure_version_id = c_org_str_ver_id ) os
     START WITH os.organization_id_parent = c_org_id
     CONNECT BY os.organization_id_parent = PRIOR os.organization_id_child;

   -- Cursor to store the record ids in a PL/SQL table to be used while
   -- processing the sec. and terminated assignments
   CURSOR csr_rcd_ids IS
   SELECT Decode(rin.seq_num,1,'000',
                             2,'010',
                             3,'020',
                             4,'030',
                             5,'040',
                             6,'060',
                             7,'070',
                             8,'080',
                             9,'081',
                             10,'10h',
                             12,'999',
                            '~') rec_num,
          rin.seq_num,
          rin.hide_flag,
          rcd.ext_rcd_id,
          rcd.rcd_type_cd
    FROM  ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
   WHERE dfn.ext_dfn_id   = Ben_Ext_Thread.g_ext_dfn_id
     AND rin.ext_file_id  = dfn.ext_file_id
     AND rin.ext_rcd_id   = rcd.ext_rcd_id
     ORDER BY rin.seq_num;

--Cursor to check whether oganization is tax organization or not
CURSOR csr_tax_org(c_org_id NUMBER) IS
SELECT 'x'
  FROM hr_organization_information
 WHERE organization_id         = c_org_id
   AND org_information_context = 'NL_ORG_INFORMATION'
   AND org_information3 IS NOT NULL
   AND org_information4 IS NOT NULL;

--Cursor to fetch the PGGM employer number from
--org information context
CURSOR csr_get_pggm_er_num(c_org_id IN Number) IS
SELECT SUBSTR(NVL(org_information5,'000000'),1,6)
  FROM hr_organization_information
 WHERE org_information_context = 'PQP_NL_PGGM_INFO'
   AND organization_id = c_org_id;

--Cursor to check the PTP in the Std Conditions tab
--Pick ptp value from Std conditions at asg level
CURSOR csr_get_ptp_std_cond(c_assignment_id NUMBER,bg_id NUMBER) IS
SELECT fnd_number.canonical_to_number(NVL(scl.SEGMENT29,'0')) pt_perc,
       asg.effective_start_date, asg.effective_end_date
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE  asg.assignment_id = c_assignment_id
  AND  scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  asg.effective_start_date BETWEEN g_extract_params(bg_id).extract_start_date
       AND g_extract_params(p_business_group_id).extract_end_date;

--Cursor to check the previous PTP in the Std Conditions tab
CURSOR csr_get_prev_ptp_std_cond(c_asg_id NUMBER,c_date DATE) IS
SELECT fnd_number.canonical_to_number(NVL(scl.SEGMENT29,'0')) pt_perc
FROM   per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND (c_date - 1 BETWEEN asg.effective_start_date
      AND asg.effective_end_date)
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

------Cursor to check whether there is any change in part time percentage
CURSOR csr_chk_curr_ptp_ele(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT peev.element_entry_value_id,
peev.screen_entry_value,peev.effective_start_date,peev.effective_end_date
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (g_extract_params(bg_id).extract_start_date between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (peev.effective_start_date between g_extract_params(bg_id).extract_start_date
  and g_extract_params(bg_id).extract_end_date);


------Cursor to check whether there is any retrospective change in part time percentage
CURSOR csr_chk_retro_ptp_ele(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT peev.element_entry_value_id,
peev.screen_entry_value,pee.source_start_date
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'Retro PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (g_extract_params(bg_id).extract_start_date between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and peev.screen_entry_value is not null
  order by pee.source_start_date;

-------Cursor to check whether there is any change in incidental worker code
CURSOR csr_chk_inci_code_ele(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT Decode(scl.SEGMENT1,'Y','0','1') segment1, asg.effective_start_date,asg.effective_end_date
FROM   per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND (asg.effective_start_date BETWEEN g_extract_params(bg_id).extract_start_date
  AND g_extract_params(p_business_group_id).extract_end_date)
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

------Cursor to pick all retrospective changes in incidental worker code in the current period
------in a sorted order
CURSOR csr_chk_retro_inci_code_ele(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT peev.screen_entry_value,pee.source_start_date
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  ( pet.element_name = 'Retro PGGM Pensions General Information'
    OR pet.element_name = 'Retro PGGM Pensions General Information Previous Year')
  and piv.name ='Incidental Worker'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (g_extract_params(bg_id).extract_start_date between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  ORDER by pee.source_start_date;

--Cursor to check whether Pension Salary Current Year Retro Changes exists or not
-- and fetch the difference in pension salary
CURSOR csr_get_060_curr_retro_val(c_asg_id Number,c_eff_date Date) IS
Select peev.screen_entry_value,pee.element_entry_id
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
   pet.element_name ='Retro PGGM Pensions General Information'
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (c_eff_date between pee.effective_start_date
                and pee.effective_end_date)
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND ( c_eff_date between peev.effective_start_date
       and peev.effective_end_date)
 AND peev.screen_entry_value is not null;


--Cursor to check whether Pension Salary Previous Year Retro Changes exists or not
-- and fetch the difference in pension salary
CURSOR csr_get_060_prev_retro_val(c_asg_id Number,c_eff_date Date) IS
Select peev.screen_entry_value,pee.element_entry_id
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
 pet.element_name ='Retro PGGM Pensions General Information Previous Year'
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (c_eff_date between pee.effective_start_date
                and pee.effective_end_date)
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND ( c_eff_date between peev.effective_start_date
       and peev.effective_end_date)
 AND peev.screen_entry_value is not null;

--Cursor to check whether Pension Salary Retro Changes exists or not
--and fetch the orginal date earned
CURSOR csr_get_060_curr_retro_date(c_asg_id Number,c_eff_date Date) IS
Select to_char(pee.source_start_date,'YYYYMMDD') source_start_date ,pee.element_entry_id
from pay_element_entries_f  pee,
     pay_element_types_f   pet
where
    pet.element_name ='Retro PGGM Pensions General Information'
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (c_eff_date between pee.effective_start_date
                and pee.effective_end_date);

--Cursor to check whether Pension Salary Retro Changes exists or not
--and fetch the orginal date earned
CURSOR csr_get_060_prev_retro_date(c_asg_id Number,c_eff_date Date) IS
Select to_char(pee.source_start_date,'YYYYMMDD') source_start_date ,pee.element_entry_id
from pay_element_entries_f  pee,
     pay_element_types_f   pet
where
 pet.element_name ='Retro PGGM Pensions General Information Previous Year'
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (c_eff_date between pee.effective_start_date
                and pee.effective_end_date);

------Cursor to check whether there is any change in part time percentage
CURSOR csr_chk_prev_ptp_ele(c_asg_id NUMBER,bg_id NUMBER,c_date DATE) IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and ((c_date -1) between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and((c_date-1)  between peev.effective_start_date
       and peev.effective_end_date);


-------Cursor to check whether there is any change in incidental worker code
CURSOR csr_chk_inci_code_chg_ele(c_asg_id NUMBER,bg_id NUMBER,c_date DATE) IS
SELECT Decode(scl.SEGMENT1,'Y','0','1') segment1
FROM   per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND (c_date - 1 BETWEEN asg.effective_start_date
  AND asg.effective_end_date)
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

Cursor csr_retro_pggm_gen_info_iwc IS
Select 'x'
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
(    pet.element_name ='Retro PGGM Pensions General Information'
 OR  pet.element_name ='Retro PGGM Pensions General Information Previous Year')
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=p_assignment_id
 AND pee.element_type_id =pet.element_type_id
 AND  (p_effective_date between pee.effective_start_date
                AND pee.effective_end_date )
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND ( p_effective_date between peev.effective_start_date
                AND peev.effective_end_date )
 AND peev.screen_entry_value is  null;

---Cursor to check whether there is any change in definitive part time percentage retrospectievly
--Record 081 triggering condition
CURSOR  csr_get_081_retro_values(c_asg_id NUMBER,bg_id NUMBER,c_date DATE) IS
SELECT distinct to_char(pee.source_start_date,'YYYY') year_of_change
FROM
pay_element_types_f     pet,
pay_input_values_f      piv,
pay_element_entries_f   pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'Retro PGGM Pensions Part Time Percentage'
  AND ( piv.name = 'Extra Hours'
        OR piv.name = 'Hours Worked'
OR piv.name = 'Total Hours' )
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and ( pee.effective_start_date  between g_extract_params(bg_id).extract_start_date
          and g_extract_params(bg_id).extract_end_date)
  and pee.source_start_date < c_date
  AND peev.element_entry_id=pee.element_entry_id
  AND peev.input_value_id=piv.input_value_id
  AND peev.screen_entry_value is not null
  order by year_of_change;

   -- =========================================
   -- ~ Local variables
   -- =========================================
   l_ext_params         csr_ext_params%ROWTYPE;
   l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
   l_ext_dfn_type       pqp_extract_attributes.ext_dfn_type%TYPE;
   bg_id                per_all_assignments_f.business_group_id%TYPE;
   l_ext_rslt_id        ben_ext_rslt.ext_rslt_id%TYPE;
   l_ext_dfn_id         ben_ext_dfn.ext_dfn_id%TYPE;
   l_return_value       Varchar2(2) :='N';
   l_valid_action       Varchar2(2);
   l_ele_type_id        pay_element_types_f.element_type_id%TYPE;
   l_prev_ele_type_id   pay_element_types_f.element_type_id%TYPE;
   l_proc_name          Varchar2(150) := g_proc_name ||'Pension_Criteria_Full_Profile';
   l_assig_rec          csr_assig%ROWTYPE;
   l_Chg_Evt_Exists     Varchar2(2);
   l_effective_date     Date;
   l_org_hierarchy      Number;
   l_ret_val            Number:=0;
   l_rr_exists          number := 0;
   l_basis_amount       number(9,2);
   l_asg_act_id         number;
   l_def_bal_id         number;
   l_amount             number;
   l_context_id         number;
   l_code               number;
   l_date               date := hr_api.g_eot;
   l_ptp_start_date     DATE;
   l_new_start          date;
   l_old_start          date;
   l_tax_org_flag       varchar2(1);
   l_get_count_ptp_changes NUMBER := 0;
   l_pay_year           NUMBER;
   l_pay_mon            NUMBER;
   l_pay_day            NUMBER;
   l_pay_start_date     DATE;
   l_pay_end_date       DATE;
   l_index              NUMBER;
   loop_index           NUMBER:=0;
   l_temp_rec080_01    csr_chk_curr_ptp_ele%ROWTYPE;
   l_temp_rec080_02    csr_chk_retro_ptp_ele%ROWTYPE;
   l_temp_rec080_03    csr_chk_inci_code_ele%ROWTYPE;
   l_temp_rec080_04    csr_chk_retro_inci_code_ele%ROWTYPE;

   l_temp_rec060_curr_01    csr_get_060_curr_retro_val%ROWTYPE;
   l_temp_rec060_curr_02    csr_get_060_curr_retro_date%ROWTYPE;
   l_temp_rec060_prev_01    csr_get_060_prev_retro_val%ROWTYPE;
   l_temp_rec060_prev_02    csr_get_060_prev_retro_date%ROWTYPE;

   l_temp_rec081        csr_get_081_retro_values%ROWTYPE;

   l_040_eff_date       DATE;
   l_temp_date          DATE;
   l_temp_index         NUMBER;
   l_iwc_change_val     NUMBER;
   l_04_counter         NUMBER:=0;
   l_prev_iwc           varchar2(1);
   l_data_element_val   varchar2(10);
   l_prev_ptp_val       varchar2(10);
   l_start_date         DATE;
   l_02_counter         NUMBER:=0;
   l_ptp_change_val     NUMBER:=0;
   l_check              varchar2(1);
   l_pggm_er_num        varchar2(6);
   l_check_date         varchar2(2);
   l_check_mon          varchar2(2);
   l_flag               varchar2(10);
   l_employer_contri    NUMBER;
   l_emp_contri         NUMBER;
   l_period_start_date  DATE;
   l_period_end_date    DATE;
   l_period_start_date2 DATE;
   l_prev_ptp_std       NUMBER;
BEGIN
--hr_utility.trace_on(null,'SS');

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   bg_id := p_business_group_id;
   g_ptp_index          := 0;
   g_retro_ptp_count := 0;
   l_ext_rslt_id := Ben_Ext_Thread.g_ext_rslt_id;
   l_ext_dfn_id  := Ben_Ext_Thread.g_ext_dfn_id;
   -- Executed only once during extract run
   IF NOT g_extract_params .EXISTS(bg_id) THEN
      Hr_Utility.set_location('..Exract Params PL/SQL not populated ' ,7);
      -- Get the extract type, Changes extract or Full Profile
      OPEN  csr_ext_attr(c_ext_dfn_id=> l_ext_dfn_id);
      FETCH csr_ext_attr INTO l_ext_dfn_type;
      CLOSE csr_ext_attr;
      Hr_Utility.set_location('..After cursor csr_ext_attr',9);
      -- Get the Conc. request id to get the params
      OPEN  csr_req_id(c_ext_rslt_id       => l_ext_rslt_id
                      ,c_ext_dfn_id        => l_ext_dfn_id
                      ,c_business_group_id => p_business_group_id);
      FETCH csr_req_id INTO l_conc_reqest_id;
      CLOSE csr_req_id;
      Hr_Utility.set_location('..After Conc.Request id cursor csr_req_id',11);
      -- Get the params. based on the conc. request id.
      OPEN  csr_ext_params (c_request_id        => l_conc_reqest_id
                           ,c_ext_dfn_id        => l_ext_dfn_id
                           ,c_business_group_id => p_business_group_id);
      FETCH csr_ext_params INTO l_ext_params;
      CLOSE csr_ext_params;
      -- Store the params. in a PL/SQL table record
      g_extract_params(bg_id).session_id          := l_ext_params.session_id;
      g_extract_params(bg_id).ext_dfn_type        := l_ext_dfn_type;
      g_extract_params(bg_id).business_group_id   := l_ext_params.business_group_id;
      g_extract_params(bg_id).concurrent_req_id   := l_ext_params.tax_unit_id;
      g_extract_params(bg_id).ext_dfn_id          := l_ext_params.value1;
      g_extract_params(bg_id).payroll_id          := l_ext_params.value2;
      g_extract_params(bg_id).con_set_id          := l_ext_params.value3;
      g_extract_params(bg_id).org_id              := l_ext_params.value4;
      g_extract_params(bg_id).extract_start_date  :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute3);
      g_extract_params(bg_id).extract_end_date    :=
          Fnd_Date.canonical_to_date(l_ext_params.attribute4);
      g_extract_params(bg_id).extract_type      := l_ext_params.attribute5;

      OPEN csr_leg_code (c_business_group_id => p_business_group_id);
      FETCH csr_leg_code INTO g_extract_params(bg_id).legislation_code,
                              g_extract_params(bg_id).currency_code;
      CLOSE csr_leg_code;
      g_legislation_code  := g_extract_params(bg_id).legislation_code;
      g_business_group_id := p_business_group_id;
      Hr_Utility.set_location('..Stored the extract parameters in PL/SQL table', 15);

/*
      -- Get Assignment Run dimension Id as we will be using for
      -- calculating the amount
      OPEN  csr_asg_dimId;
      FETCH csr_asg_dimId INTO g_asgrun_dim_id;
      CLOSE csr_asg_dimId; */

      -- Set the meaning for concurrent program parameters
       Set_ConcProg_Parameter_Values
       (p_ext_dfn_id          => g_extract_params(bg_id).ext_dfn_id
       ,p_start_date          => g_extract_params(bg_id).extract_start_date
       ,p_end_date            => g_extract_params(bg_id).extract_end_date
       ,p_payroll_id          => g_extract_params(bg_id).payroll_id
       ,p_con_set             => g_extract_params(bg_id).con_set_id
       ,p_org_id              => g_extract_params(bg_id).org_id
        );

      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
      -- Store all record ids in a PL/SQL tbl
      FOR rcd_rec IN csr_rcd_ids
      LOOP
          g_ext_rcds(rcd_rec.ext_rcd_id):= rcd_rec;
      END LOOP;
      -- Add the current org to the org table.
       g_org_list(g_extract_params(bg_id).org_id).org_id
                          := g_extract_params(bg_id).org_id;

      --Store the PGGM employer number in a global variable
      -- Get PGGM Er number from derived org id
      OPEN csr_get_pggm_er_num(g_extract_params(bg_id).org_id);
      FETCH csr_get_pggm_er_num INTO l_pggm_er_num;
      IF csr_get_pggm_er_num%FOUND THEN
         g_pggm_employer_num:=l_pggm_er_num;
         l_ret_val := 0;
      END IF;
      CLOSE csr_get_pggm_er_num;


      -- Check if a hierarchy is attached.
      OPEN c_get_org_hierarchy;
      FETCH c_get_org_hierarchy INTO l_org_hierarchy;
      IF c_get_org_hierarchy%FOUND THEN
         CLOSE c_get_org_hierarchy;
         -- Get all the children of the Org for which extract is being run
         -- based on the hierarchy obtained above.
         FOR temp_rec IN c_get_children
                         (c_org_str_ver_id => l_org_hierarchy
                         ,c_org_id         => g_extract_params(bg_id).org_id)
         LOOP

   -- All non-employers  child orgs are added in the list
   OPEN csr_tax_org(temp_rec.organization_id_child);
   FETCH csr_tax_org INTO l_tax_org_flag;
   IF csr_tax_org%NOTFOUND Then
        g_org_list(temp_rec.organization_id_child).org_id
                           := temp_rec.organization_id_child;
     End If;
   CLOSE csr_tax_org;
  END LOOP;
       ELSE
          CLOSE c_get_org_hierarchy;
       END IF;


   END IF;

   -- Get the person id for the assignment and store it in a global
   -- variable
   g_person_id:= Nvl(get_current_extract_person(p_assignment_id),
                    Ben_Ext_Person.g_person_id);

    --If person is not retro hired then g_retro_hires record is null
    Hr_Utility.set_location('c_start_date'||g_extract_params(bg_id).extract_start_date, 15);
    Hr_Utility.set_location('c_end_date'||g_extract_params(bg_id).extract_end_date, 15);
   -- Derive the effective date
   l_effective_date := Least(g_extract_params(bg_id).extract_end_date,
                             p_effective_date);
   Hr_Utility.set_location('..Processing Assig Id  : '||p_assignment_id, 17);
   Hr_Utility.set_location('..Processing Person Id : '||g_person_id, 17);
   Hr_Utility.set_location('..Processing Eff.Date  : '||p_effective_date, 17);
   -- Get the list of employers (HR Orgs) in the current hierarchy.
   -- Store this value in a PL/SQL Table.
   -- Check if the assignments need to be processed. Assignments are
   -- processed if
   -- 1. The organization of the person assignment exists in the
   --    org list derived above.
   -- 2. If the primary assignment does not satisfy point 1 then check if
   --    the secondary assignments satisfy point 1
   -- 3. If the assignment passed is a Benefits assignment

   -- Check if the assignments passed by BEN are in the org list
   OPEN csr_assig (c_assignment_id     => p_assignment_id
                  ,c_effective_date    => l_effective_date
                  ,c_business_group_id => p_business_group_id);
   FETCH csr_assig INTO l_assig_rec;
   CLOSE csr_assig;

   g_per_details(g_person_id).national_identifier:=substr(l_assig_rec.national_identifier,1,9);
   g_per_details(g_person_id).date_of_birth:=to_char(l_assig_rec.date_of_birth,'YYMMDD');
   g_per_details(g_person_id).prefix:=substr(l_assig_rec.pre_name_adjunct,1,7);
   g_per_details(g_person_id).last_name:=substr(l_assig_rec.last_name,1,18);

   -- Check for Benefits assignment first.
   IF l_assig_rec.assignment_type = 'B' THEN
      l_return_value := 'Y';
   -- Check for EE Assignment
   ELSIF l_assig_rec.assignment_type = 'E' THEN
      l_return_value := 'N';

      -- Check if the asg org_id is in the list of orgs, Also Check if the
      -- value of payroll_id on the ASG is the same as the param Payroll id.

      IF g_org_list.EXISTS(l_assig_rec.organization_id) AND
         ( g_extract_params(bg_id).payroll_id IS NULL OR
           l_assig_rec.payroll_id =g_extract_params(bg_id).payroll_id )  THEN
               l_return_value := 'Y';
      END IF;

    END IF;

   -- Check if any secondary assignments exist and need to be picked up
   IF l_return_value = 'N' AND l_assig_rec.primary_flag = 'Y' THEN

      FOR temp_rec IN csr_sec_assig (c_assignment_id     => p_assignment_id
                                    ,c_effective_date    => l_effective_date
                                    ,c_business_group_id => p_business_group_id
                                    ,c_person_id         => g_person_id)
      -- For all sec asg's..Recheck
      LOOP
         IF g_org_list.EXISTS(temp_rec.organization_id) AND
            ( g_extract_params(bg_id).payroll_id IS NULL OR
              temp_rec.payroll_id =g_extract_params(bg_id).payroll_id) THEN
              l_return_value := 'Y';
          EXIT;
         END IF;
      END LOOP;

    END IF;

   -- Added to maintain global asg data
   IF l_return_value = 'Y' THEN
      g_primary_assig(p_assignment_id):=l_assig_rec;

       --Setting the start and end date to check for payroll run
       l_pay_start_date:=g_extract_params(p_business_group_id).extract_start_date;
       l_pay_end_date:=g_extract_params(p_business_group_id).extract_end_date;

      --Check whether for this assignment payroll has been run or not
      OPEN csr_asg_act(p_assignment_id
                      ,null
                      ,null
                      ,l_pay_start_date
                      ,l_pay_end_date
                      );
      FETCH csr_asg_act INTO l_asg_act;
      IF csr_asg_act%FOUND THEN
         CLOSE csr_asg_act;
      ELSE
         CLOSE csr_asg_act;
         p_error_message := 'Payroll has not been run for this assignment.';
      END IF;

     --------------------Record060 Pre Processing----------------
     --Initialize global variables for record 060
     g_rcd_060.DELETE;
     g_rec060_mult_flag:='N';
     g_rec_060_count:=0;

     OPEN csr_get_060_curr_retro_val(p_assignment_id,p_effective_date);
     OPEN csr_get_060_curr_retro_date(p_assignment_id,p_effective_date);

     LOOP
         FETCH csr_get_060_curr_retro_val INTO l_temp_rec060_curr_01;
         FETCH csr_get_060_curr_retro_date INTO l_temp_rec060_curr_02;
         EXIT WHEN csr_get_060_curr_retro_val%NOTFOUND OR csr_get_060_curr_retro_date%NOTFOUND;

        l_check_date:=substr(l_temp_rec060_curr_02.source_start_date,7,2);
        l_check_mon:=substr(l_temp_rec060_curr_02.source_start_date,5,2);

        --Get year start date and month
	OPEN  c_get_period_start_date( substr(l_temp_rec060_curr_02.source_start_date,1,4)
	                             ,p_assignment_id
				     ,p_effective_date );
	FETCH c_get_period_start_date INTO l_period_start_date2;
	CLOSE c_get_period_start_date;


      IF l_check_date=to_char(l_period_start_date2,'DD') AND l_check_mon=to_char(l_period_start_date2,'MM') THEN
            Hr_Utility.set_location('Adding 060 record', 75);
             l_temp_index:=l_temp_rec060_curr_01.element_entry_id;
             g_rcd_060(l_temp_index).pension_sal_amount :=to_number(l_temp_rec060_curr_01.screen_entry_value);
             l_temp_index:=l_temp_rec060_curr_02.element_entry_id;
            l_temp_date:=to_date(l_temp_rec060_curr_02.source_start_date,'YYYYMMDD');
             g_rcd_060(l_temp_rec060_curr_02.element_entry_id).pension_sal_dt_change:=l_temp_date;
            g_rcd_060(l_temp_rec060_curr_02.element_entry_id).element_type:='C';
      END IF;
     END LOOP;
     CLOSE csr_get_060_curr_retro_val;
     CLOSE csr_get_060_curr_retro_date;

     OPEN csr_get_060_prev_retro_val(p_assignment_id,p_effective_date);
     OPEN csr_get_060_prev_retro_date(p_assignment_id,p_effective_date);
     LOOP
         FETCH csr_get_060_prev_retro_val INTO l_temp_rec060_prev_01;
         FETCH csr_get_060_prev_retro_date INTO l_temp_rec060_prev_02;
         EXIT WHEN csr_get_060_prev_retro_val%NOTFOUND OR csr_get_060_prev_retro_date%NOTFOUND;
         l_check_date:=substr(l_temp_rec060_prev_02.source_start_date,7,2);
         l_check_mon:=substr(l_temp_rec060_prev_02.source_start_date,5,2);

         IF l_check_date='01' AND l_check_mon='01' THEN
          Hr_Utility.set_location('Adding 060 record', 75);
          l_temp_index:=l_temp_rec060_prev_01.element_entry_id;
          g_rcd_060(l_temp_index).pension_sal_amount :=to_number(l_temp_rec060_prev_01.screen_entry_value);
          l_temp_index:=l_temp_rec060_prev_02.element_entry_id;
          l_temp_date:=to_date(l_temp_rec060_prev_02.source_start_date,'YYYYMMDD');
          g_rcd_060(l_temp_rec060_prev_02.element_entry_id).pension_sal_dt_change:=l_temp_date;
          g_rcd_060(l_temp_rec060_prev_02.element_entry_id).element_type:='P';
         END IF;
     END LOOP;
     CLOSE csr_get_060_prev_retro_val;
     CLOSE csr_get_060_prev_retro_date;

     g_rec_060_count:=g_rcd_060.COUNT;
     Hr_Utility.set_location('g_rec_060_count'||g_rec_060_count, 78);

     --------------------Record_080_Pre_Processing ---------------

     --Initialze the variables
     g_rcd_080.DELETE;
     g_rec_080_type1_count:=0;
     g_rec_080_type2_count:=0;
     g_rec_080_type3_count:=0;
     g_rec_080_type4_count:=0;
     --g_080_index:=0         ;
     g_080_display_flag:='N';



     FOR l_temp_rec080_01 IN csr_chk_curr_ptp_ele(p_assignment_id,p_business_group_id)
     LOOP

          OPEN  csr_chk_prev_ptp_ele(p_assignment_id,p_business_group_id,l_temp_rec080_01.effective_start_date);
          FETCH csr_chk_prev_ptp_ele INTO l_prev_ptp_val;
          Hr_Utility.set_location('g_080_index: '||g_080_index,25);
          IF (to_number(NVL(l_prev_ptp_val,'0')) <> to_number(NVL(l_temp_rec080_01.screen_entry_value,'0')))
            AND  csr_chk_prev_ptp_ele%FOUND   THEN

            g_ptp_index:=100;
            l_index:=g_ptp_index+g_rec_080_type1_count;
            g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_01.effective_start_date;
            g_rcd_080(l_index).part_time_factor:=to_number(NVL(l_temp_rec080_01.screen_entry_value,'0'));
            g_rec_080_type1_count:=g_rec_080_type1_count+1;

            Hr_Utility.set_location('Full_Profile', 75);
            Hr_Utility.set_location('..l_index: '||l_index, 76);
            Hr_Utility.set_location('..g_ptp_index: '||g_ptp_index, 77);
            Hr_Utility.set_location('..Validg_rec_080_type1_count: '||g_rec_080_type1_count, 78);
            Hr_Utility.set_location('..g_rcd_080(l_index).part_time_pct_dt_change '||g_rcd_080(l_index).part_time_pct_dt_change, 79);
            Hr_Utility.set_location('g_rcd_080(l_index).part_time_factor '||g_rcd_080(l_index).part_time_factor, 80);
            g_080_display_flag:='Y';
          END IF;
 CLOSE csr_chk_prev_ptp_ele;
     END LOOP;

FOR l_temp_rec080_01 IN csr_get_ptp_std_cond(p_assignment_id,p_business_group_id)
LOOP
  OPEN csr_get_prev_ptp_std_cond (p_assignment_id,l_temp_rec080_01.effective_start_date);
  FETCH csr_get_prev_ptp_std_cond INTO l_prev_ptp_std;
  IF csr_get_prev_ptp_std_cond%FOUND AND l_prev_ptp_std <> l_temp_rec080_01.pt_perc THEN
      g_ptp_index:=100;
      l_index:=g_ptp_index+g_rec_080_type1_count;
      g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_01.effective_start_date;
      g_rcd_080(l_index).part_time_factor:=l_temp_rec080_01.pt_perc;
      g_rec_080_type1_count:=g_rec_080_type1_count+1;
      g_080_display_flag:='Y';
  END IF;
  CLOSE csr_get_prev_ptp_std_cond;
END LOOP;

     Hr_Utility.set_location('..Validg_rec_080_type1_count: '||g_rec_080_type1_count, 78);

     --Initialize the counter
     l_02_counter:=0;
     FOR l_temp_rec080_02 IN csr_chk_retro_ptp_ele(p_assignment_id,p_business_group_id)
     LOOP
         g_ptp_index:=200;
         --Store the first record details
         IF l_02_counter = 0 THEN
              l_index:=g_ptp_index+g_rec_080_type2_count;
             g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_02.source_start_date;
              g_rcd_080(l_index).part_time_factor:=to_number(l_temp_rec080_02.screen_entry_value);
              g_rec_080_type2_count:=g_rec_080_type2_count+1;
             l_ptp_change_val:=to_number(l_temp_rec080_02.screen_entry_value);
             g_080_display_flag:='Y';
         ELSE
         --Add record details if there is a change in Part Time Percent or not
         IF l_ptp_change_val <> to_number(l_temp_rec080_02.screen_entry_value) THEN
               l_index:=g_ptp_index+g_rec_080_type2_count;
               g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_02.source_start_date;
               g_rcd_080(l_index).part_time_factor:=to_number(l_temp_rec080_02.screen_entry_value);
               g_rec_080_type2_count:=g_rec_080_type2_count+1;
               l_ptp_change_val:=to_number(l_temp_rec080_02.screen_entry_value);
               g_080_display_flag:='Y';
         END IF;
 END IF;
 l_02_counter:=l_02_counter+1;
END LOOP;

    Hr_Utility.set_location('..g_rec_080_type2_count: '||g_rec_080_type2_count, 78);
     FOR l_temp_rec080_03 IN csr_chk_inci_code_ele(p_assignment_id,p_business_group_id)
     LOOP
        OPEN  csr_chk_inci_code_chg_ele(p_assignment_id,p_business_group_id,l_temp_rec080_03.effective_start_date);
        FETCH csr_chk_inci_code_chg_ele INTO l_prev_iwc;
        IF ( to_number(l_prev_iwc) <>
             to_number(NVL(l_temp_rec080_03.SEGMENT1,'1'))
            AND  csr_chk_inci_code_chg_ele%FOUND )
        THEN
           g_ptp_index:=300;
           l_index:=g_ptp_index+g_rec_080_type3_count;
           g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_03.effective_start_date;
           g_rcd_080(l_index).incidental_code:=to_number(l_temp_rec080_03.segment1);
           g_rec_080_type3_count:=g_rec_080_type3_count+1;
           Hr_Utility.set_location('Full_Profile', 75);
           Hr_Utility.set_location('..Validg_rec_080_type3_count: '||g_rec_080_type3_count, 78);
           Hr_Utility.set_location('..g_rcd_080(l_index).part_time_pct_dt_change '||g_rcd_080(l_index).part_time_pct_dt_change, 79);
           Hr_Utility.set_location('g_rcd_080(l_index).part_time_factor '||g_rcd_080(l_index).part_time_factor, 80);
           g_080_display_flag:='Y';
         END IF;
       CLOSE csr_chk_inci_code_chg_ele;
     END LOOP;
     Hr_Utility.set_location('..g_rec_080_type3_count: '||g_rec_080_type3_count, 78);
     --Initialize the counter
     l_04_counter:=0;
     --Check for Current Year Retro IWC Changes
     OPEN csr_retro_pggm_gen_info_iwc;
     FETCH csr_retro_pggm_gen_info_iwc INTO l_check;
     IF csr_retro_pggm_gen_info_iwc%FOUND THEN
       FOR l_temp_rec080_04 IN csr_chk_retro_inci_code_ele(p_assignment_id,p_business_group_id)
       LOOP
       --Store the first record details
       IF l_04_counter = 0 THEN
         g_ptp_index:=400;
         l_index:=g_ptp_index+g_rec_080_type4_count;
         g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_04.source_start_date;
         g_rcd_080(l_index).incidental_code:=to_number(l_temp_rec080_04.screen_entry_value);
         g_rec_080_type4_count:=g_rec_080_type4_count+1;
         l_iwc_change_val:=to_number(l_temp_rec080_04.screen_entry_value);
         g_080_display_flag:='Y'; --Display the 080 record
       ELSE
       --Add record details if there is a change in IWC or not
       IF l_iwc_change_val <> to_number(l_temp_rec080_04.screen_entry_value) THEN
           l_index:=g_ptp_index+g_rec_080_type4_count;
           g_rcd_080(l_index).part_time_pct_dt_change:=l_temp_rec080_04.source_start_date;
           g_rcd_080(l_index).incidental_code:=to_number(l_temp_rec080_04.screen_entry_value);
           g_rec_080_type4_count:=g_rec_080_type4_count+1;
           l_iwc_change_val:=to_number(l_temp_rec080_04.screen_entry_value);
       END IF;
     END IF;
     l_04_counter:=l_04_counter+1;
     END LOOP;
     END IF;
     Hr_Utility.set_location('..Validg_rec_080_type4_count: '||g_rec_080_type4_count, 78);
     Hr_Utility.set_location('..Valid Assig Id : '||p_assignment_id, 79);
    ---------------End  Record 080 Processing---------------------------------

     --------------------Record_081_Pre_Processing ---------------
     --Store all the year for which hours worked or total hours have been changed retrospectively

     --Set flags and initialize the counter
     g_rcd_081.DELETE;
     g_main_rec_081 :='N';
     g_rec_081_type :='C';
     g_rec_081_count:=0;

     Hr_Utility.set_location('Record_081_Pre_Processing', 75);
     OPEN csr_get_081_retro_values(p_assignment_id,p_business_group_id,g_extract_params(p_business_group_id).extract_start_date);
     l_temp_index:=0;
     LOOP
         FETCH csr_get_081_retro_values INTO l_temp_rec081;
         EXIT WHEN csr_get_081_retro_values%NOTFOUND;
	--Get the period start and end dates
	OPEN  c_get_period_start_date(l_temp_rec081.year_of_change
	                             ,p_assignment_id
				     ,p_effective_date );
	FETCH c_get_period_start_date INTO l_period_start_date;
	CLOSE c_get_period_start_date;

	OPEN  c_get_period_end_date(l_temp_rec081.year_of_change
	                            ,p_assignment_id
				    ,p_effective_date );
	FETCH c_get_period_end_date INTO l_period_end_date;
	CLOSE c_get_period_end_date;
        --Calculate deduction amount
	l_emp_contri:=Get_Balance_value(p_assignment_id
                                ,p_business_group_id
                                ,'PGGM Employee Contribution'
                                ,'Assignment Period To Date'
                                ,l_period_start_date
                                ,l_period_end_date
                                );
    l_employer_contri:=Get_Balance_value(p_assignment_id
                                ,p_business_group_id
                                ,'PGGM Employer Contribution'
                                ,'Assignment Period To Date'
                                ,l_period_start_date
                                ,l_period_end_date
                                );
     --Process 018 only when employee has paid pension premiums
     IF (l_emp_contri + l_employer_contri )> 0 THEN
          g_rcd_081(l_temp_index).year_of_change:=l_temp_rec081.year_of_change;
     END IF;
      l_temp_index:=l_temp_index+1;
     END LOOP;

       g_rec_081_count:=g_rcd_081.COUNT;
       Hr_Utility.set_location('g_rec_081_count'||g_rec_081_count, 75);
     CLOSE csr_get_081_retro_values;
    ---------------End  Record 081 Processing---------------------------------

    END IF; -- if l_return_value = 'Y'
    Hr_Utility.set_location('l_return_value : '||l_return_value, 79);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
    --hr_utility.trace_off;
    RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;

END Pension_Criteria_Full_Profile;
-- =============================================================================
-- Get_Street
-- =============================================================================
FUNCTION Get_Street
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_street(c_person_id IN Number) IS
SELECT region_1
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND primary_flag = 'Y'
   AND style = 'NL'
UNION
SELECT address_line1
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND primary_flag = 'Y'
   AND style = 'NL_GLB';

l_street     per_addresses_v.region_1%TYPE;
l_proc_name Varchar2(150) := g_proc_name ||'Get_Street';

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_street(g_person_id);
   FETCH cur_get_street INTO l_street;
   CLOSE cur_get_street;

   p_data_element_value := Upper(l_street);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Street;

-- =============================================================================
-- Get_House_Num
-- =============================================================================
FUNCTION Get_House_Num
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

CURSOR cur_get_house_num(c_person_id IN Number) IS
SELECT add_information13
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND style = 'NL'
  AND  primary_flag = 'Y'
UNION
SELECT address_line2
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND style = 'NL_GLB'
  AND  primary_flag = 'Y';


l_house_num    per_addresses_v.address_line1%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_House_Num';
l_ret_val      Number := 0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN cur_get_house_num(g_person_id);
   FETCH cur_get_house_num INTO l_house_num;
   CLOSE cur_get_house_num;
   p_data_element_value := Upper(l_house_num);
   l_ret_val :=0;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_House_Num;

-- =============================================================================
-- Get_Addl_House_Num
-- =============================================================================
FUNCTION Get_Addl_House_Num
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
         ) RETURN Number IS


CURSOR cur_get_addl_house_num(c_person_id IN Number) IS
SELECT add_information14
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  primary_flag = 'Y'
  AND  style = 'NL'
UNION
SELECT address_line3
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND  primary_flag = 'Y'
  AND  style = 'NL_GLB';

l_addl_house_num    per_addresses_v.address_line1%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Addnl_House_Num';
l_ret_val      Number := 0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN cur_get_addl_house_num(g_person_id);
   FETCH cur_get_addl_house_num INTO l_addl_house_num;
   CLOSE cur_get_addl_house_num;

   p_data_element_value := Upper(l_addl_house_num);
   l_ret_val :=0;

   Hr_Utility.set_location('Leaving:   '||l_proc_name, 15);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_Addl_House_Num;

-- =============================================================================
-- Get_Postal_Code
-- =============================================================================
FUNCTION Get_Postal_Code
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_postal_code(c_person_id IN Number) IS
SELECT postal_code
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND  style IN ('NL','NL_GLB')
   AND primary_flag = 'Y';

l_postal_code   per_addresses_v.postal_code%TYPE;
l_postal_code1  per_addresses_v.postal_code%TYPE;
temp_str       varchar2(1);
i              Number := 0;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_Postal_Code';
l_ret_val      Number :=0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN cur_get_postal_code(g_person_id);
   FETCH cur_get_postal_code INTO l_postal_code;
   IF cur_get_postal_code%FOUND THEN
      CLOSE cur_get_postal_code;
      FOR i in 1..length(l_postal_code)
      LOOP
         SELECT substr(l_postal_code,i,1) INTO temp_str from dual;
         IF temp_str <> ' ' THEN
            l_postal_code1 := l_postal_code1||temp_str;
         END IF;
      END LOOP;
      p_data_element_value := Upper(substr(l_postal_code1,0,6));
   ELSE
     CLOSE cur_get_postal_code;
     p_data_element_value := '';
   END IF;
   l_ret_val :=0;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_Postal_Code;
-- =============================================================================
-- Get_City
-- =============================================================================
FUNCTION Get_City
         (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN  Date
         ,p_error_message        OUT NOCOPY Varchar2
         ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS


CURSOR cur_get_city(c_person_id IN Number) IS
SELECT town_or_city
  FROM per_addresses_v
 WHERE person_id = c_person_id
   AND p_effective_date BETWEEN date_from
   AND Nvl(date_to,Hr_Api.g_eot)
   AND style IN ('NL','NL_GLB')
   AND primary_flag = 'Y';

CURSOR cur_get_foreign_coun(c_person_id IN Number) IS
SELECT Decode(country,'NL','N',country) code
      ,d_country
  FROM per_addresses_v
 WHERE person_id = c_person_id
  AND  p_effective_date BETWEEN date_from
  AND  Nvl(date_to,Hr_Api.g_eot)
  AND style IN ('NL','NL_GLB')
  AND  primary_flag = 'Y';


CURSOR c_city (p_lookup_code IN VARCHAR2) IS
SELECT meaning
  FROM hr_lookups
 WHERE lookup_type = 'HR_NL_CITY'
   AND lookup_code = p_lookup_code;


l_city         per_addresses_v.town_or_city%TYPE;
l_city_name    hr_lookups.meaning%TYPE;
l_country      per_addresses_v.d_country%TYPE;
l_code         per_addresses_v.country%TYPE;
l_proc_name    Varchar2(150) := g_proc_name ||'Get_City';
l_ret_val      Number :=0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   OPEN cur_get_city(g_person_id);
   FETCH cur_get_city INTO l_city;
   CLOSE cur_get_city;

/*   OPEN cur_get_foreign_coun(g_person_id);
   FETCH cur_get_foreign_coun INTO l_code,l_country;
   CLOSE cur_get_foreign_coun; */

   IF l_city IS NOT NULL THEN
     FOR c_city_rec IN c_city (l_city) LOOP
        l_city_name := c_city_rec.meaning;
     END LOOP;
   END IF;

   l_city_name := nvl(l_city_name,l_city);

   IF l_code <> 'N' THEN
      p_data_element_value := Upper(l_city_name); --||' '||Upper(l_country);
   ELSE
      p_data_element_value := Upper(l_city_name);
   END IF;

  l_ret_val :=0;

   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_ret_val;
END Get_City;
--============================================================================
--GET_PERSON_INITIALS
--============================================================================
FUNCTION Get_Person_Initials
         ( p_assignment_id      IN Number
          ,p_business_group_id  IN Number
          ,p_date_earned        IN Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
         ) RETURN Number IS

    CURSOR cur_get_initials(c_person_id   IN Number,
                            c_date_earned IN Date) IS
    SELECT Substr(replace(per_information1,'.',NULL),1,5)
      FROM per_all_people_f
     WHERE person_id         = c_person_id
       AND business_group_id = p_business_group_id
       AND c_date_earned BETWEEN effective_start_date
                             AND effective_end_date;

    l_initials     Varchar2(5);
    l_proc_name    Varchar2(150) := g_proc_name ||'Get_Person_Initials';
    l_return_value Number :=0;

BEGIN

    Hr_Utility.set_location('Entering: '||l_proc_name, 5);

    --Get the initials stored as entered by user
    OPEN cur_get_initials(g_person_id,p_date_earned);
       FETCH cur_get_initials INTO l_initials;
    CLOSE cur_get_initials;
    p_data_element_value := l_initials;

    Hr_Utility.set_location('Leaving: '||l_proc_name, 10);
    RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,7);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 9);
    l_return_value := -1;
    RETURN l_return_value;
END Get_Person_Initials;
-- =============================================================================
-- Get_Gender:
-- =============================================================================
FUNCTION Get_Gender
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS
CURSOR cur_get_gender(c_date_earned       IN Date
                     ,c_business_group_id IN Number) IS
SELECT Decode(sex,'F','V','M') gender
  FROM per_all_people_f
 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND c_date_earned BETWEEN effective_start_date
                         AND effective_end_date;

 l_proc_name Varchar2(150) := g_proc_name ||'Get_Gender';
 l_gender    Varchar2(2);
 l_return_value   Number:=0;

BEGIN
   Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
   OPEN  cur_get_gender(p_effective_date,p_business_group_id);
   FETCH cur_get_gender INTO l_gender;
   CLOSE cur_get_gender;
   p_data_element_value := l_gender;

   Hr_Utility.set_location('p_data_element_value:'||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

   l_return_value := 0;
   RETURN l_return_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value := -1;
    RETURN l_return_value;
END Get_Gender;
-- =============================================================================
-- Get_Occupation_Code --function to get the Occupation Code
-- =============================================================================

FUNCTION Get_Occupation_Code
         (p_assignment_id      IN  Number
         ,p_business_group_id  IN Number
         ,p_effective_date     IN Date
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
         ) RETURN Number IS

--cursor to fetch the Occupation_Code
--from the soft coding key flex
CURSOR c_get_emp_code IS
SELECT scl.SEGMENT2||scl.SEGMENT3
  FROM per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = p_assignment_id
  AND p_effective_date BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

l_emp_code Varchar2(120);
l_emp_kind Varchar2(1);
l_proc_name Varchar2(150) := 'Get_Occupation_Code';

BEGIN

Hr_Utility.set_location('Entering : '||l_proc_name,10);
--first fetch the employment code from the soft coding keyflex
OPEN c_get_emp_code;
FETCH c_get_emp_code INTO l_emp_code;
IF c_get_emp_code%FOUND THEN
   CLOSE c_get_emp_code;
   Hr_Utility.set_location('found the code as : '||l_emp_code,20);
   p_data_element_value := l_emp_code;
ELSE
   CLOSE c_get_emp_code;
   p_data_element_value := '';
END IF;
Hr_Utility.set_location('Leaving : '||l_proc_name,50);
RETURN 0;
EXCEPTION
WHEN Others THEN
p_error_message := SQLERRM;
Hr_Utility.set_location('error message : '||SQLERRM,10);
Hr_Utility.set_location('Leaving : '||l_proc_name,50);
p_data_element_value := '';
RETURN 1;

END Get_Occupation_Code;
-- =============================================================================
-- Get_PGGM_ER_Num
-- Private function to fetch PGGM Employer Number stored in Org DDF
-- =============================================================================
Function Get_PGGM_ER_Num
( p_assignment_id      IN Number
 ,p_business_group_id  IN Number
 ,p_date_earned        IN Date
 ,p_error_message      OUT NOCOPY Varchar2
 ,p_data_element_value OUT NOCOPY Varchar2
)
 Return Number IS
--local variables
l_proc_name  Varchar2(150) := g_proc_name ||'Get_PGGM_ER_Num';
l_ret_val    Number := 0;

Begin
Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

--return the pggm employer number which has been set for Parent organization
--for all child orgs also,only this value has to be reported
p_data_element_value:=g_pggm_employer_num;


Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
l_ret_val:=0;

RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_PGGM_ER_Num;

-- ===============================================================================
-- ~ Function to get the Kind of participation stored in PGGM General Info Element as I/P val
-- ===============================================================================
Function Get_Kind_Of_PTP
                 ( p_assignment_id       IN Number
                   ,p_business_group_id  IN Number
                   ,p_date_earned        IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
                 )
Return Number IS
CURSOR csr_get_kind_of_ptp(c_asg_id IN Number,c_date_earned IN DATE)  IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions General Information'
  and piv.name ='Kind Of Participation'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (c_date_earned between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (c_date_earned between peev.effective_start_date
       and peev.effective_end_date );
--5869420
CURSOR csr_get_primary_asg (c_assgt_id NUMBER, c_date DATE) IS
SELECT pri.assignment_id
FROM per_all_assignments_f sec,
per_all_assignments_f pri
WHERE sec.assignment_id = c_assgt_id
AND sec.person_id = pri.person_id
AND pri.primary_flag = 'Y'
AND c_date BETWEEN pri.effective_start_date AND pri.effective_end_date
AND c_date BETWEEN sec.effective_start_date AND sec.effective_end_date;
--
l_primary_flag VARCHAR2(2);
l_pri_assignment_id NUMBER;
--End of 5869420

l_proc_name   Varchar2(150):=g_proc_name || 'Get_Kind_Of_PTP';
l_ret_val     Number:=0;
l_kind_of_ptp varchar2(2):='';

BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name,5);
OPEN csr_get_kind_of_ptp(p_assignment_id,p_date_earned);
FETCH csr_get_kind_of_ptp INTO l_kind_of_ptp;
IF csr_get_kind_of_ptp%FOUND THEN
     p_data_element_value:=l_kind_of_ptp;
     l_ret_val := 0;
END IF;
CLOSE csr_get_kind_of_ptp;

--5869420
--If Participation Kind is not entered for this assignment, and if this is a
--secondary assignment, get the value from the primary assignment.
IF l_kind_of_ptp = '' OR l_kind_of_ptp IS NULL THEN
   OPEN csr_chk_primary_asg (p_assignment_id, p_date_earned);
   FETCH csr_chk_primary_asg INTO l_primary_flag;
   IF csr_chk_primary_asg%NOTFOUND THEN
        OPEN csr_get_primary_asg (p_assignment_id, p_date_earned);
        FETCH csr_get_primary_asg INTO l_pri_assignment_id;
        CLOSE csr_get_primary_asg;
        OPEN csr_get_kind_of_ptp(l_pri_assignment_id,p_date_earned);
        FETCH csr_get_kind_of_ptp INTO l_kind_of_ptp;
             p_data_element_value:=l_kind_of_ptp;
             l_ret_val := 0;
        CLOSE csr_get_kind_of_ptp;
   END IF;
   CLOSE csr_chk_primary_asg;
END IF;
--End of 5869420

Hr_Utility.set_location(' Leaving:   '||l_proc_name,20);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_Kind_Of_PTP;
-- ===============================================================================
-- ~ Function to get the CAO Code stored in Org DDF
-- ===============================================================================
Function Get_CAO_Code
                 ( p_assignment_id       IN Number
                   ,p_business_group_id  IN Number
                   ,p_date_earned        IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
 )
Return Number is
-- Cursor to get Org id for the given asg id
CURSOR csr_get_org_id IS
SELECT fnd_number.canonical_to_number (ppf.prl_information1)
  FROM per_all_assignments_f paf,
       pay_all_payrolls_f ppf
 WHERE paf.assignment_id = p_assignment_id
   AND paf.business_group_id = p_business_group_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN
       paf.effective_start_date AND paf.effective_end_date
   AND paf.payroll_id = ppf.payroll_id
   AND ppf.prl_information_category = 'NL';

--Cursor to fetch the CAO Code from
--org information context
CURSOR csr_get_cao_code(c_org_id IN Number) IS
SELECT SUBSTR(org_information6,1,6)
  FROM hr_organization_information
 WHERE org_information_context = 'PQP_NL_PGGM_INFO'
   AND organization_id = c_org_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN
       fnd_date.canonical_to_date (org_information1)
       AND nvl(fnd_date.canonical_to_date (org_information2), to_date('47121231','YYYYMMDD'));

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_CAO_Code';
l_ret_val     Number:=0;
l_cao_code    varchar2(10):='';
l_org_id      Number:=0;
BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name,5);
-- Get org id
 OPEN csr_get_org_id;
 FETCH csr_get_org_id  INTO l_org_id;
 CLOSE csr_get_org_id ;

 Hr_Utility.set_location('l_org_id: '||l_org_id,10);

 -- Get CAO Code from derived org id
 OPEN csr_get_cao_code(l_org_id);
 FETCH csr_get_cao_code INTO l_cao_code;
 IF csr_get_cao_code%FOUND AND ( l_cao_code <> ' ' OR l_cao_code IS NOT NULL)  THEN
    CLOSE csr_get_cao_code;
 ELSE
    CLOSE csr_get_cao_code;
    Hr_Utility.set_location('CAO not found at org level',30);
    --Fetch CAO code of parent org
    Hr_Utility.set_location('Fetching CAO code of parent org',40);
    OPEN csr_get_cao_code(g_extract_params(p_business_group_id).org_id);
    FETCH csr_get_cao_code INTO l_cao_code;
    IF csr_get_cao_code%NOTFOUND THEN
      l_cao_code:=NULL;
    END IF;
    Hr_Utility.set_location('l_cao_code'||l_cao_code,50);
    CLOSE csr_get_cao_code;
 END If;

 l_ret_val := 0;
 p_data_element_value:=SUBSTR(l_cao_code,1,5);
 p_data_element_value:=lpad(p_data_element_value,4,'0');
Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_CAO_Code;
-- ===============================================================================
-- ~ Function to get the Employer Registration Number stored in Org DDF
-- ===============================================================================
Function Get_Emp_Reg_Num
                 ( p_assignment_id       IN Number
                   ,p_business_group_id  IN Number
                   ,p_date_earned        IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
 )
Return Number is

-- Cursor to get Org id for the given asg id
CURSOR csr_get_org_id IS
SELECT fnd_number.canonical_to_number (ppf.prl_information1)
  FROM per_all_assignments_f paf,
       pay_all_payrolls_f ppf
 WHERE paf.assignment_id = p_assignment_id
   AND paf.business_group_id = p_business_group_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN
       paf.effective_start_date AND paf.effective_end_date
   AND paf.payroll_id = ppf.payroll_id
   AND ppf.prl_information_category = 'NL';

--Cursor to fetch the Emp Reg No. from
--org information context
CURSOR csr_emp_reg_num(c_org_id IN Number) IS
SELECT lpad(org_information7,15,'0')
  FROM hr_organization_information
 WHERE organization_id = c_org_id
   AND org_information_context = 'PQP_NL_PGGM_INFO'
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN
       fnd_date.canonical_to_date (org_information1)
       AND nvl(fnd_date.canonical_to_date (org_information2), to_date('47121231','YYYYMMDD'));

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Emp_Reg_Num';
l_ret_val     Number:=0;
l_emp_reg_num varchar2(16):='';
l_org_id      Number:=0;
BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name,5);
-- Get org id
 OPEN csr_get_org_id;
 FETCH csr_get_org_id  INTO l_org_id;
 CLOSE csr_get_org_id ;

 Hr_Utility.set_location('l_org_id: '||l_org_id,10);

 -- Get Emp Reg Num Code from derived org id
 OPEN csr_emp_reg_num(l_org_id);
 FETCH csr_emp_reg_num INTO l_emp_reg_num;
 IF csr_emp_reg_num%FOUND AND (l_emp_reg_num <> ' ' OR l_emp_reg_num IS NOT NULL) THEN
    CLOSE csr_emp_reg_num;
    l_ret_val := 0;
 ELSE
    CLOSE csr_emp_reg_num;
    --If not found at org level then fetch it from parent org level
    OPEN csr_emp_reg_num(g_extract_params(p_business_group_id).org_id);
    FETCH csr_emp_reg_num INTO l_emp_reg_num;
    IF csr_emp_reg_num%NOTFOUND THEN
       l_emp_reg_num:=NULL;
    END IF;
    CLOSE csr_emp_reg_num;

 END If;
 p_data_element_value:=l_emp_reg_num;

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_Emp_Reg_Num;
-- ===============================================================================
-- ~ Function to get the PGGM Emp Number stored in PGGM General Info Element as I/P val
-- ===============================================================================
Function Get_PGGM_Ee_Num
(p_assignment_id      IN Number
,p_business_group_id  IN Number
,p_date_earned        IN DATE
,p_error_message      OUT NOCOPY VARCHAR2
,p_data_element_value OUT NOCOPY VARCHAR2
)
Return Number is
--Cursor to get PGGM employee number
CURSOR csr_get_pggm_ee_num(c_asg_id IN Number,c_date_earned IN DATE)
IS
SELECT substr(NVL(peev.screen_entry_value,'0'),1,3)
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions General Information'
  and piv.name ='PGGM Employee Number'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (c_date_earned between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (c_date_earned between peev.effective_start_date
       and peev.effective_end_date);

CURSOR csr_get_primary_asg (c_assgt_id NUMBER, c_date DATE) IS
SELECT pri.assignment_id
FROM per_all_assignments_f sec,
per_all_assignments_f pri
WHERE sec.assignment_id = c_assgt_id
AND sec.person_id = pri.person_id
AND pri.primary_flag = 'Y'
AND c_date BETWEEN pri.effective_start_date AND pri.effective_end_date
AND c_date BETWEEN sec.effective_start_date AND sec.effective_end_date;
--
l_primary_flag VARCHAR2(2);
l_pri_assignment_id NUMBER;
l_proc_name   Varchar2(150) :=g_proc_name || 'Get_PGGM_Ee_Num';
l_ret_val     Number :=0;
l_pggm_ee_num varchar2(30) :='0';
Begin
Hr_Utility.set_location(' Entering     ' || l_proc_name , 5);
OPEN csr_get_pggm_ee_num(p_assignment_id,p_date_earned);
FETCH csr_get_pggm_ee_num INTO l_pggm_ee_num;
Hr_Utility.set_location('l_pggm_ee_num: '||l_pggm_ee_num, 45);
IF csr_get_pggm_ee_num%FOUND THEN
     p_data_element_value:=l_pggm_ee_num;
     l_ret_val :=0;
END If;
Hr_Utility.set_location('p_data_element_value: '||p_data_element_value, 45);
CLOSE csr_get_pggm_ee_num;

--If PGGM EE Num is not entered for this assignment, and if this is a
--secondary assignment, get the value from the primary assignment.
IF l_pggm_ee_num = '0' THEN
   OPEN csr_chk_primary_asg (p_assignment_id, p_date_earned);
   FETCH csr_chk_primary_asg INTO l_primary_flag;
   IF csr_chk_primary_asg%NOTFOUND THEN
        OPEN csr_get_primary_asg (p_assignment_id, p_date_earned);
        FETCH csr_get_primary_asg INTO l_pri_assignment_id;
        CLOSE csr_get_primary_asg;
        OPEN csr_get_pggm_ee_num(l_pri_assignment_id,p_date_earned);
        FETCH csr_get_pggm_ee_num INTO l_pggm_ee_num;
             p_data_element_value:=l_pggm_ee_num;
             l_ret_val := 0;
        CLOSE csr_get_pggm_ee_num;
   END IF;
   CLOSE csr_chk_primary_asg;
END IF;
RETURN l_ret_val;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     Hr_Utility.set_location('..Exception Others Raised at Get_PGGM_Ee_Num'||p_error_message,40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     l_ret_val:=1;
     RETURN l_ret_val;
END Get_PGGM_Ee_Num;

-- =============================================================================
-- Get_EE_Num:
-- =============================================================================
FUNCTION Get_EE_Num
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_proc_name    VARCHAR2(150) := g_proc_name ||'Get_EE_Num';
  l_per_ee_num   per_all_people_f.employee_number%TYPE;
  l_asg_seq_num  VARCHAR2(2);

BEGIN

  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

  IF g_primary_assig.EXISTS(p_assignment_id) THEN

     l_per_ee_num := g_primary_assig (p_assignment_id).ee_num;

     --
     -- Derive the assignment sequence number for the assignment
     --
     IF g_primary_assig (p_assignment_id).asg_seq_num < 10 THEN
        l_asg_seq_num := '0'||g_primary_assig(p_assignment_id).asg_seq_num;
     ELSE
        l_asg_seq_num := g_primary_assig(p_assignment_id).asg_seq_num;
     END IF;

     --
     -- Add the asg seq number to the EE number
     --
     l_per_ee_num := l_per_ee_num || l_asg_seq_num;
     l_per_ee_num := lpad(l_per_ee_num,15,'0');
     Hr_Utility.set_location('l_asg_seq_num:   '||l_asg_seq_num, 5);

  END IF;

  p_data_element_value := Nvl(l_per_ee_num,'000000000000000');

  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);

  RETURN 0;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_EE_Num;

-- =============================================================================
-- Get_Hire_Date
-- =============================================================================
FUNCTION Get_Hire_Date
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  Date
          ,p_error_message      OUT NOCOPY Varchar2
          ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS


-- Cursor to get the hire date of the person
/*Cursor csr_get_hire_date IS
 SELECT max(date_start)
FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;*/


-- Cursor to get the hire date of the assignment
CURSOR csr_get_hire_date IS
SELECT min(effective_start_date)
FROM  per_all_assignments_f asg
WHERE asg.assignment_id = p_assignment_id
   AND asg.business_group_id = p_business_group_id
   AND asg.assignment_type='E';


  l_proc_name       Varchar2(150) := g_proc_name ||'Get_Hire_Date';
  l_hire_date       DATE;
  BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

  OPEN csr_get_hire_date;
  FETCH csr_get_hire_date INTO l_hire_date;
  IF csr_get_hire_date%FOUND THEN
  p_data_element_value:=to_char(l_hire_date,'YYYYMMDD');
  END IF;
  CLOSE csr_get_hire_date;


  Hr_Utility.set_location('Leaving:   '||l_proc_name, 45);
  RETURN 0;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN 1;
END Get_Hire_Date;
-- =============================================================================
-- Get_Term_Reason
-- =============================================================================
FUNCTION Get_Term_Reason
          (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date     IN  DATE
          ,p_error_message      OUT NOCOPY VARCHAR2
          ,p_data_element_value OUT NOCOPY VARCHAR2
          ) RETURN NUMBER IS

--
-- Cursor to get the termination reason
--
 CURSOR c_get_end_reason_new IS
 SELECT SUBSTR(DECODE(NVL(leaving_reason,'OVE'),'D','OVL'
                     ,NVL(leaving_reason,'OVE')),1,3)
   FROM per_periods_of_service pps,
        per_all_assignments_f asg
  WHERE asg.period_of_service_id = pps.period_of_service_id
    AND assignment_id = p_assignment_id
    AND p_effective_date BETWEEN effective_start_date AND
                                 effective_end_date ;

  l_proc_name      VARCHAR2(150) := g_proc_name ||'Get_Term_Reason';
  l_reason         VARCHAR2(3);

BEGIN

   hr_utility.set_location('Entering:   '||l_proc_name, 5);

   --
   -- 5869420
   --
   OPEN c_get_end_reason_new;
   FETCH c_get_end_reason_new INTO l_reason;
   IF c_get_end_reason_new%FOUND THEN
       CLOSE c_get_end_reason_new;
   ELSE
       --
       -- Termination reason not found. Send OVE (Other Reasons)
       --
       l_reason := 'OVE';
       CLOSE c_get_end_reason_new;
   END IF;

   --
   -- Ensure that the length of termination reason is 3
   --
   l_reason := RPAD(l_reason,3,' ');

   --
   -- Only the following reasons are allowed in the report
   -- VWO = Voluntary resignation
   -- GO  = Forced resignation
   -- OVL = Deceased
   -- OP  = Start of pension
   -- OBU = Transitional pension
   -- OBV = Unpaid leave
   -- WAO = Disability
   -- OVP = Transition employee
   -- OVE = Other reasons
   --
   IF l_reason NOT IN('VWO','GO ','OVL','OP ','OBU','OBV','WAO','OVP','OVE') THEN
      l_reason := 'OVE';
   END IF;

   p_data_element_value := l_reason;

   hr_utility.set_location('....Termination reason is : '||l_reason,32);
   hr_utility.set_location('Leaving:   '||l_proc_name, 45);

   RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    hr_utility.set_location('..'||p_error_message,85);
    hr_utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Get_Term_Reason;


-- ===============================================================================
-- ~ Function to get the Reason of participation stored in PGGM General Info Element as I/P val
-- ===============================================================================
Function Get_Reason_Of_PTP
                 ( p_assignment_id       IN Number
                   ,p_business_group_id  IN Number
                   ,p_date_earned        IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
                 )
Return Number IS

CURSOR csr_get_reason_of_ptp(c_asg_id IN Number,c_date_earned IN DATE)  IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions General Information'
  and piv.name ='Reason Of Participation'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (c_date_earned between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (c_date_earned between peev.effective_start_date
       and peev.effective_end_date );

CURSOR csr_get_primary_asg (c_assgt_id NUMBER, c_date DATE) IS
SELECT pri.assignment_id
FROM per_all_assignments_f sec,
per_all_assignments_f pri
WHERE sec.assignment_id = c_assgt_id
AND sec.person_id = pri.person_id
AND pri.primary_flag = 'Y'
AND c_date BETWEEN pri.effective_start_date AND pri.effective_end_date
AND c_date BETWEEN sec.effective_start_date AND sec.effective_end_date;
--
l_primary_flag VARCHAR2(2);
l_pri_assignment_id NUMBER;
l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Reason_Of_PTP';
l_ret_val     Number:=-1;
l_reason_of_ptp varchar2(40):='';
BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

OPEN csr_get_reason_of_ptp(p_assignment_id,p_date_earned);
FETCH csr_get_reason_of_ptp INTO l_reason_of_ptp;
IF csr_get_reason_of_ptp%FOUND THEN
     p_data_element_value:=l_reason_of_ptp;
     l_ret_val := 0;
 END If;
CLOSE csr_get_reason_of_ptp;

--If PTP Reason is not entered for this assignment, and if this is a
--secondary assignment, get the value from the primary assignment.
IF l_reason_of_ptp = '' OR l_reason_of_ptp IS NULL THEN
   OPEN csr_chk_primary_asg (p_assignment_id, p_date_earned);
   FETCH csr_chk_primary_asg INTO l_primary_flag;
   IF csr_chk_primary_asg%NOTFOUND THEN
        OPEN csr_get_primary_asg (p_assignment_id, p_date_earned);
        FETCH csr_get_primary_asg INTO l_pri_assignment_id;
        CLOSE csr_get_primary_asg;
        OPEN csr_get_reason_of_ptp(l_pri_assignment_id,p_date_earned);
        FETCH csr_get_reason_of_ptp INTO l_reason_of_ptp;
             p_data_element_value:=l_reason_of_ptp;
             l_ret_val := 0;
        CLOSE csr_get_reason_of_ptp;
   END IF;
   CLOSE csr_chk_primary_asg;
END IF;
Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_Reason_Of_PTP;
-- ===============================================================================
-- ~ Function to get the part time percent as of hire date
-- ===============================================================================
Function Get_Hire_Date_PTP
                 ( p_assignment_id       IN Number
                   ,p_business_group_id  IN Number
                   ,p_effective_date     IN DATE
                   ,p_error_message      OUT NOCOPY VARCHAR2
                   ,p_data_element_value OUT NOCOPY VARCHAR2
                 )
Return Number IS
--Pick PTP from element entry level
CURSOR csr_get_overide_ptp_val(c_asg_id IN Number,c_date_earned IN DATE)  IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (c_date_earned between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (c_date_earned between peev.effective_start_date
       and peev.effective_end_date )
   and peev.screen_entry_value is not null;

--Pick ptp value from Std conditions at asg level
CURSOR csr_get_ptp_asg_level(c_assignment_id NUMBER,c_effective_date IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'0')) pt_perc
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = c_assignment_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  c_effective_date between asg.effective_start_date
  AND  asg.effective_end_date
  AND  target.enabled_flag = 'Y';

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Hire_Date_PTP';
l_ret_val     Number:=-1;
l_hire_date   varchar2(10):='';
l_ptp         NUMBER;
BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

--Fetch the hire date for this assignment
l_ret_val:= Get_Hire_Date(p_assignment_id
              ,p_business_group_id
              ,p_effective_date
              ,p_error_message
             ,l_hire_date
              );

--Check whether ptp has been overriden at assignment level
OPEN csr_get_overide_ptp_val(p_assignment_id,to_date(l_hire_date,'YYYYMMDD'));
FETCH csr_get_overide_ptp_val INTO l_ptp;
IF csr_get_overide_ptp_val%FOUND THEN
  p_data_element_value:=l_ptp;
ELSE
 --IF not overriden then take the asg value (STD conditions)
  OPEN csr_get_ptp_asg_level(p_assignment_id,to_date(l_hire_date,'YYYYMMDD'));
  FETCH csr_get_ptp_asg_level INTO l_ptp;
  p_data_element_value:=l_ptp;
  CLOSE csr_get_ptp_asg_level;
END IF;
CLOSE csr_get_overide_ptp_val;

p_data_element_value := lpad(fnd_number.number_to_canonical(ceil(l_ptp)),3,'0')||'000';

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_Hire_Date_PTP;
-- ===============================================================================
-- ~ Function to get the incidental worker code as of hire date
-- ===============================================================================
Function Get_Hire_Date_IWC
                 ( p_assignment_id        IN Number
                   ,p_business_group_id   IN Number
                   ,p_effective_date      IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
                 )
Return Number IS

CURSOR csr_get_incidental_wkr_code(c_asg_id Number ,c_date_earned Date) IS
SELECT Decode(scl.SEGMENT1,'Y','0','1')
  FROM per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND c_date_earned BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Hire_Date_IWC';
l_ret_val     Number:=-1;
l_hire_date   varchar2(10):='';
l_iwc         varchar2(1);
BEGIN
Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

--Fetch the hire date for this assignment
l_ret_val:= Get_Hire_Date(p_assignment_id
              ,p_business_group_id
              ,p_effective_date
              ,p_error_message
             ,l_hire_date
              );

--Get the iwc at asg level
OPEN csr_get_incidental_wkr_code(p_assignment_id,to_date(l_hire_date,'YYYYMMDD'));
FETCH csr_get_incidental_wkr_code INTO l_iwc;
CLOSE csr_get_incidental_wkr_code;

IF l_iwc IS NULL THEN
    l_iwc := '1';
END IF;
p_data_element_value:=l_iwc;

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,20);
RETURN l_ret_val;

EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_Hire_Date_IWC;

-- ===============================================================================
-- ~ Get_End_Date_Of_Employment: Assignment End Date
-- ===============================================================================
Function Get_End_Date_Of_Employment
                 ( p_assignment_id        IN Number
                   ,p_business_group_id   IN Number
                   ,p_effective_date      IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
                 )
Return Number IS
/*CURSOR csr_get_assgn_end_date(c_assignment_id NUMBER) IS
SELECT max(actual_termination_date)
FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = c_assignment_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_effective_date;

CURSOR csr_get_sec_assgn_end_date(c_assignment_id NUMBER,c_business_group_id NUMBER) IS
SELECT paa.effective_start_date
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_assignment_id
   AND paa.business_group_id       = c_business_group_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='TERM_ASSIGN'
   AND ( paa.effective_start_date
    BETWEEN  g_extract_params (c_business_group_id).extract_start_date +1
             AND g_extract_params (c_business_group_id).extract_end_date + 1 );*/

--
CURSOR csr_get_term_date IS
SELECT MIN(effective_start_date)-1 term_date
 FROM per_all_assignments_f asg
WHERE assignment_id = p_assignment_id
  AND assignment_status_type_id IN (SELECT assignment_status_type_id
                                      FROM per_assignment_status_types
                                     WHERE per_system_status = 'TERM_ASSIGN'
                                       AND active_flag = 'Y')
UNION
--
-- Get the dates for any ended assignments. Note that this is for sec
-- assignments only.
--
SELECT MAX(effective_end_date)
 FROM per_all_assignments_f asg
WHERE assignment_id    = p_assignment_id
  AND asg.primary_flag = 'N'
  AND NOT EXISTS( SELECT 1
                    FROM per_all_assignments_f  asg1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND asg1.effective_start_date = asg.effective_end_date + 1
                     AND asg.assignment_id = asg1.assignment_id )
  AND NOT EXISTS( SELECT 1
                    FROM per_all_assignments_f  asg1
                   WHERE asg1.assignment_id = p_assignment_id
                     AND asg1.effective_start_date < asg.effective_start_date
                     AND asg.assignment_id = asg1.assignment_id
                     AND asg1.assignment_status_type_id IN (SELECT assignment_status_type_id
                                                              FROM per_assignment_status_types
                                                             WHERE per_system_status = 'TERM_ASSIGN'
                                                               AND active_flag = 'Y'));
--

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_End_Date_Of_Employment';
l_ret_val     Number:=0;
l_end_date    DATE;
l_check       varchar2(1);
BEGIN
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);
/*OPEN csr_chk_primary_asg(p_assignment_id, p_effective_date);
FETCH csr_chk_primary_asg INTO l_check;
IF csr_chk_primary_asg%FOUND THEN
  OPEN csr_get_assgn_end_date(p_assignment_id);
  FETCH csr_get_assgn_end_date INTO l_end_date;
  IF (csr_get_assgn_end_date%FOUND) THEN
    l_ret_val:=0;
    p_data_element_value:=to_char(l_end_date,'YYYYMMDD');
  END IF;
  CLOSE csr_get_assgn_end_date;
ELSE

  OPEN csr_get_sec_assgn_end_date(p_assignment_id,p_business_group_id);
  FETCH csr_get_sec_assgn_end_date INTO l_end_date;
  IF (csr_get_sec_assgn_end_date%FOUND) THEN
    l_ret_val:=0;
    p_data_element_value:=to_char(l_end_date-1,'YYYYMMDD');
  END IF;
  CLOSE csr_get_sec_assgn_end_date;

END IF;
CLOSE csr_chk_primary_asg;*/

OPEN csr_get_term_date;
FETCH csr_get_term_date INTO l_end_date;
IF csr_get_term_date%FOUND THEN
   l_ret_val:=0;
   p_data_element_value:=to_char(l_end_date,'YYYYMMDD');
END IF;
CLOSE csr_get_term_date;

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      RETURN l_ret_val;
END Get_End_Date_Of_Employment;
-- ===============================================================================
-- ~ Get_Pension_Salary
-- ===============================================================================
Function Get_Pension_Salary
                 ( p_assignment_id         IN Number
                   ,p_business_group_id    IN Number
                   ,p_date_earned          IN DATE
                   ,p_error_message        OUT NOCOPY VARCHAR2
                   ,p_data_element_value   OUT NOCOPY VARCHAR2
  )
Return Number IS
--Cursor to check for PGGM General Info Elements for the current period
CURSOR csr_chk_curr_year_pen_sal_chg(c_asg_id Number,c_start_date DATE) IS
Select 'x'
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
 pet.element_name ='Retro PGGM Pensions General Information'
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (pee.effective_start_date  between c_start_date
                and g_extract_params(p_business_group_id).extract_end_date )
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND peev.screen_entry_value is not null
 ORDER by source_start_date desc;

  --Cursor to check for PGGM General Info Elements for the previous period
CURSOR csr_chk_prev_year_pen_sal_chg(c_asg_id Number,c_start_date DATE) IS
Select 'x'
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
 pet.element_name ='Retro PGGM Pensions General Information Previous Year'
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (pee.effective_start_date  between c_start_date
                and g_extract_params(p_business_group_id).extract_end_date )
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND peev.screen_entry_value is not null
 ORDER by source_start_date desc;

 --get the  total value for Retro Previous year element
 Cursor csr_total_chg_val(c_asg_id NUMBER,c_start_date DATE,c_end_date DATE) IS
 Select count(to_number(peev.screen_entry_value))
 from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
 where
  pet.element_name ='Retro PGGM Pensions General Information Previous Year'
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=c_asg_id
 AND pee.element_type_id =pet.element_type_id
 AND  (pee.effective_start_date  between c_start_date
                and c_end_date )
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND peev.screen_entry_value is not null;

--
-- Cursor to get the current year override for pension salary
--
CURSOR csr_curr_year_pen_sal_or(c_asg_id Number,c_start_date DATE) IS
SELECT CEIL(fnd_number.canonical_to_number(peev.screen_entry_value))
  FROM pay_element_entries_f  pee,
       pay_input_values_f    piv,
       pay_element_types_f   pet,
       pay_element_entry_values_f peev
 WHERE pet.element_name ='PGGM Pensions General Information'
   AND piv.name = 'Annual Pension Salary'
   AND piv.element_type_id = pet.element_type_id
   AND pee.assignment_id = c_asg_id
   AND pee.element_type_id = pet.element_type_id
   AND pee.effective_start_date  BETWEEN c_start_date
                AND g_extract_params(p_business_group_id).extract_end_date
   AND peev.effective_start_date  BETWEEN c_start_date
                AND g_extract_params(p_business_group_id).extract_end_date
   AND peev.element_entry_id = pee.element_entry_id
   AND peev.input_value_id = piv.input_value_id
   AND peev.screen_entry_value IS NOT NULL
 ORDER by source_start_date desc;


l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Pension_Salary';
l_ret_val              Number:=0;
l_balance_amount       Number:=0;
l_bal_total_amt        Number:=0;
asgact_rec             csr_asg_act%ROWTYPE;
l_curr_year            NUMBER;
l_prev_year            NUMBER;
l_mon                  Number;
l_end_date             Number;
l_error_message        VARCHAR2(150);
l_pen_sal_date         DATE;
l_start_date_PTP       varchar2(10);
orig_pen_sal_amt       NUMBER;
l_chg_amt              NUMBER:=0;
l_retro_chg_amt        NUMBER:=0;
l_retro_total_amt      NUMBER:=0;
l_chg_date             DATE;
l_data_element_value   DATE;
l_chk_retro            VARCHAR2(1);
l_period_start_date    DATE;


Begin
  Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

  l_curr_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);



IF ( g_extract_params(p_business_group_id).extract_type='Y' )  --Annual report

THEN


   --Date Parameter will be 0ne less than the current year in annual report
   l_curr_year:=l_curr_year+1;


   --Get Participation start date
   l_ret_val:=Get_Start_Date_PTP(p_assignment_id
             ,p_business_group_id
             ,p_date_earned
             ,p_error_message
            ,l_start_date_PTP
          );

   --Get the period start date
    OPEN  c_get_period_start_date(l_curr_year
                                 ,p_assignment_id
				 ,p_date_earned);
    FETCH c_get_period_start_date INTO l_period_start_date;
    CLOSE c_get_period_start_date;


   --Reporting Date is the latest date of hire date and 1st Jan of that year
   --Pension Salary is calculated in this period
   l_pen_sal_date:=l_period_start_date;


   IF l_pen_sal_date < to_date(l_start_date_PTP,'YYYYMMDD') THEN
     l_pen_sal_date:=to_date(l_start_date_PTP,'YYYYMMDD');
   END IF;

    Hr_Utility.set_location(' Pen Sal Date  '   ||l_pen_sal_date,30);


     --Check whether there is retro change in pension salary for current year or not
     OPEN csr_chk_curr_year_pen_sal_chg(p_assignment_id,l_pen_sal_date);
     FETCH csr_chk_curr_year_pen_sal_chg INTO l_chk_retro;
     IF csr_chk_curr_year_pen_sal_chg%FOUND THEN

     --Get the YTD value for Retro PGGM Pension Salary Current Year Element
     l_chg_amt:=Get_Balance_Value(p_assignment_id
                                 ,p_business_group_id
                                 ,'Retro PGGM Pension Salary Current Year'
                                 ,'Assignment Period To Date'
                                 ,g_extract_params(p_business_group_id).extract_start_date
                                 ,g_extract_params(p_business_group_id).extract_end_date -- last day of the period/year
                                  );
     ELSE
       l_chg_amt:=0;
     END IF;
     CLOSE csr_chk_curr_year_pen_sal_chg;
      Hr_Utility.set_location('l_chg_amt'   ||l_chg_amt,30);
    --Get the original pension salary
    l_balance_amount:= Get_Balance_Value(p_assignment_id
                                     ,p_business_group_id
                                     ,'PGGM Pension Salary'
                                     ,'Assignment Year To Date'
                                     ,l_pen_sal_date
                                     ,last_day(l_pen_sal_date)  -- last day of the month
                                     );

     Hr_Utility.set_location('l_balance_amount'   ||l_balance_amount,30);
    --Actual Amount is summation of Retro amount and original pension salary
    p_data_element_value := CEIL(l_balance_amount+l_chg_amt);
    p_data_element_value:=lpad(p_data_element_value,6,'0');
    l_ret_val:=0;

   ELSE  ---Monthly Report

   --------------------called from 060 record ---------------------------
   IF g_rec060_mult_flag='Y' THEN --if  Record 060 value then calculate it from global table for 060

    IF g_rcd_060(g_060_index).element_type = 'C' Then

      --g_060_index is set at Mult Rec 060 Processing
      --l_chg_amt:=g_rcd_060(g_060_index).pension_sal_amount; --  This contains the diffrence in Pensoin Salary
      l_pen_sal_date:=g_rcd_060(g_060_index).pension_sal_dt_change;
      --Check whether there is retro change in pension salary for current year or not
      OPEN csr_chk_curr_year_pen_sal_chg(p_assignment_id,l_pen_sal_date);
      FETCH csr_chk_curr_year_pen_sal_chg INTO l_chk_retro;
      IF csr_chk_curr_year_pen_sal_chg%FOUND THEN


         --Get the YTD value for Retro PGGM Pension Salary Current Year Element
         l_retro_chg_amt:=Get_Balance_Value(p_assignment_id
                                     ,p_business_group_id
                                    ,'Retro PGGM Pension Salary Current Year'
                                    ,'Assignment Year To Date'
                                    ,g_extract_params(p_business_group_id).extract_start_date
                                    ,g_extract_params(p_business_group_id).extract_end_date -- last day of the period/year
                                    );
         ELSE
             l_retro_chg_amt:=0;
         END IF;
     ELSE ---------For Retro PGGM Gen Information previous Year

        l_pen_sal_date:=g_rcd_060(g_060_index).pension_sal_dt_change;
        --Check whether there is retro change in pension salary for current year or not
        OPEN csr_chk_prev_year_pen_sal_chg(p_assignment_id,l_pen_sal_date);
        FETCH csr_chk_prev_year_pen_sal_chg INTO l_chk_retro;
        IF csr_chk_prev_year_pen_sal_chg%FOUND THEN


        --Get the YTD value for Retro PGGM Pension Salary Previous Year Element
        l_retro_chg_amt:=Get_Balance_Value(p_assignment_id
                                      ,p_business_group_id
                                      ,'Retro PGGM Pension Salary Previous Year'
                                      ,'Assignment Year To Date'
                                      ,l_pen_sal_date
                                      ,Last_day(l_pen_sal_date) -- last day of the period/year
                                     );
        OPEN csr_total_chg_val(p_assignment_id,l_pen_sal_date,g_extract_params(p_business_group_id).extract_end_date);
        FETCH csr_total_chg_val INTO l_retro_total_amt;
        CLOSE csr_total_chg_val;
        l_retro_chg_amt:=l_retro_chg_amt+NVL(l_retro_total_amt,0);

        ELSE
          l_retro_chg_amt:=0;
        END IF;


     END IF;--End of element type check

      orig_pen_sal_amt:= Get_Balance_Value(p_assignment_id
                                     ,p_business_group_id
                                     ,'PGGM Pension Salary'
                                     ,'Assignment Year To Date'
                                     ,l_pen_sal_date
                                     ,last_day(l_pen_sal_date)  -- last day of the month
                                     );

       p_data_element_value:=CEIL(l_retro_chg_amt + orig_pen_sal_amt);
      l_ret_val:=0;
      ------------called from record other than 060 monthly report------------------
      ELSE

         --Get Participation start date
         l_ret_val:=Get_Start_Date_PTP(
                     p_assignment_id
                    ,p_business_group_id
                    ,p_date_earned
                    ,p_error_message
                   ,l_start_date_PTP
                   );
          --Get the period start date
         OPEN  c_get_period_start_date(l_curr_year
	                              ,p_assignment_id
				      ,p_date_earned);
         FETCH c_get_period_start_date INTO l_period_start_date;
         CLOSE c_get_period_start_date;

         --Reporting Date is the latest date of hire date and 1st Jan of that year
         --Pension Salary is calculated in this period
         l_pen_sal_date:=l_period_start_date;


         IF l_pen_sal_date < to_date(l_start_date_PTP,'YYYYMMDD') THEN
            l_pen_sal_date:=to_date(l_start_date_PTP,'YYYYMMDD');
         END IF;

          Hr_Utility.set_location(' Pen Sal Date  '   ||l_pen_sal_date,30);


          --Check whether there is retro change in pension salary for current year or not
          OPEN csr_chk_curr_year_pen_sal_chg(p_assignment_id,l_pen_sal_date);
          FETCH csr_chk_curr_year_pen_sal_chg INTO l_chk_retro;
          IF csr_chk_curr_year_pen_sal_chg%FOUND THEN

           --Get the YTD value for Retro PGGM Pension Salary Current Year Element
          l_chg_amt:=Get_Balance_Value(p_assignment_id
                                      ,p_business_group_id
                                      ,'Retro PGGM Pension Salary Current Year'
                                      ,'Assignment Year To Date'
                                      ,g_extract_params(p_business_group_id).extract_start_date
                                      ,g_extract_params(p_business_group_id).extract_end_date -- last day of the period/year
                                  );
          ELSE
            l_chg_amt:=0;
          END IF;
          CLOSE csr_chk_curr_year_pen_sal_chg;
          Hr_Utility.set_location('l_chg_amt'   ||l_chg_amt,30);
          --Get the original pension salary
          l_balance_amount:= Get_Balance_Value(p_assignment_id
                                              ,p_business_group_id
                                              ,'PGGM Pension Salary'
                                              ,'Assignment Year To Date'
                                              ,l_pen_sal_date
                                              ,g_extract_params(p_business_group_id).extract_end_date
					      -- last day of the month
                                             );

         Hr_Utility.set_location('l_balance_amount'   ||l_balance_amount,30);
         --Actual Amount is summation of Retro amount and original pension salary
         p_data_element_value:=CEIL(l_balance_amount+l_chg_amt);
         --p_data_element_value:=lpad(p_data_element_value,6,'0');

         -- Override pension salary
         OPEN csr_curr_year_pen_sal_or(p_assignment_id,l_pen_sal_date);
         FETCH csr_curr_year_pen_sal_or INTO l_balance_amount;
         IF csr_curr_year_pen_sal_or%FOUND THEN
            p_data_element_value:=CEIL(l_balance_amount);
            --p_data_element_value:=lpad(p_data_element_value,6,'0');
         END IF;
         CLOSE csr_curr_year_pen_sal_or;

         l_ret_val:=0;

   END IF;--Record 060 check
    p_data_element_value:=lpad(p_data_element_value,6,'0');
END IF;---End of Type of report check

  Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,40);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,50);
      Hr_Utility.set_location('Leaving: '||l_proc_name,60);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Pension_Salary;
-- ===============================================================================
-- ~ Get_Final_Part_Time_Val
-- ===============================================================================
Function Get_Final_Part_Time_Val
                 ( p_assignment_id        IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
  )
Return Number IS

CURSOR csr_retro_hours_worked(c_assignment_id NUMBER
                              ,c_start_date DATE
                              ,c_end_date   DATE
) IS
Select sum(to_number(NVL(peev.screen_entry_value,0)))
from pay_element_entries_f pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f   peev
     where
     pet.element_name='Retro PGGM Pensions Part Time Percentage'
     and piv.name='Hours Worked'
     and pee.assignment_id=c_assignment_id
     and pet.element_type_id =pee.element_type_id
     and ( pee.effective_start_date between c_start_date
          and  c_end_date )
     and peev.element_entry_id = pee.element_entry_id
     and peev.input_value_id = piv.input_value_id
     and to_char(pee.source_start_date,'YYYY')=to_char(c_start_date,'YYYY')
     and peev.screen_entry_value is not null;

CURSOR csr_retro_total_hours(c_assignment_id NUMBER
                             ,c_start_date DATE
                           ,c_end_date   DATE
 ) IS
Select sum(to_number(NVL(peev.screen_entry_value,0)))
from pay_element_entries_f pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f   peev
     where
     pet.element_name='Retro PGGM Pensions Part Time Percentage'
     and piv.name='Total Hours'
     and pee.assignment_id=c_assignment_id
     and pet.element_type_id =pee.element_type_id
     and ( pee.effective_start_date between c_start_date
          and  c_end_date )
     and peev.element_entry_id = pee.element_entry_id
     and peev.input_value_id = piv.input_value_id
     and to_char(pee.source_start_date,'YYYY')=to_char(c_start_date,'YYYY')
     and peev.screen_entry_value is not null;

CURSOR csr_retro_extra_hours(c_assignment_id NUMBER
                            ,c_start_date DATE
                          ,c_end_date   DATE
) IS
Select sum(to_number(NVL(peev.screen_entry_value,0)))
from pay_element_entries_f pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f   peev
     where
     pet.element_name='Retro PGGM Pensions Part Time Percentage'
     and piv.name='Extra Hours'
     and pee.assignment_id=c_assignment_id
     and pet.element_type_id =pee.element_type_id
     and ( pee.effective_start_date between c_start_date
          and  c_end_date )
     and peev.element_entry_id = pee.element_entry_id
     and peev.input_value_id = piv.input_value_id
     and to_char(pee.source_start_date,'YYYY')=to_char(c_start_date,'YYYY')
     and peev.screen_entry_value is not null;

CURSOR csr_get_asg_action_ids (  c_assignment_id NUMBER
                              , c_start_date DATE
                              , c_end_date  DATE
                              )
IS
SELECT paa.assignment_action_id
       ,ppa.date_earned
FROM  pay_assignment_actions paa
      ,pay_payroll_actions    ppa
WHERE  paa.assignment_id          = c_assignment_id
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND paa.source_action_id     IS NOT NULL
     AND ppa.action_status        = 'C'
     AND paa.action_status        = 'C'
     AND ppa.action_type IN ('B','L','O','Q','R')
     AND ppa.effective_date BETWEEN c_start_date
                                AND c_end_date
     ORDER BY ppa.effective_date;

CURSOR csr_get_run_result_value
       (  p_element_entry_id NUMBER
         ,p_input_value_id   NUMBER
         ,p_asg_act_id       NUMBER
       )
  IS
  SELECT to_number(prrv.result_value) result
    FROM pay_run_result_values prrv
        ,pay_run_results       prr
    WHERE prrv.run_result_id       = prr.run_result_id
      AND prr.assignment_action_id = p_asg_act_id
      AND prr.source_id            = p_element_entry_id
      AND prrv.input_value_id      = p_input_value_id ;

CURSOR csr_get_ele_entry_id (c_assignment_id NUMBER
                             ,c_date_earned DATE
			     )
IS
SELECT pee.element_entry_id
FROM pay_element_entries_f pee,
     pay_element_types_f   pet
     WHERE
     pet.element_name='PGGM Pensions Part Time Percentage'
     AND pee.assignment_id=c_assignment_id
     AND pet.element_type_id =pee.element_type_id
     AND ( c_date_earned BETWEEN pee.effective_start_date
                             AND pee.effective_end_date);

CURSOR csr_get_input_val_id
IS
SELECT piv.input_value_id  FROM
  pay_input_values_f piv,
  pay_element_types_f pet
WHERE
    pet.element_name = 'PGGM Pensions Part Time Percentage'
AND piv.name ='Extra Hours'
AND piv.element_type_id =pet.element_type_id;


l_proc_name             Varchar2(150) :=g_proc_name || 'Get_Final_Part_Time_Val';
l_ret_val                Number:=0;
l_balance_amount_h       Number :=0;
l_balance_amount_t       Number :=0;
l_sum_hours_worked       Number :=0;
l_sum_total_hours        Number :=0;
l_sum_extra_hours        Number :=0;
l_extra_hours            NUMBER :=0;
l_total_extra_hours      NUMBER :=0;
l_chg_year               VARCHAR2(10);
l_input_value_id         NUMBER :=-1;
l_element_entry_id       NUMBER :=-1;
asgact_rec               csr_asg_act%ROWTYPE;
asg_ids_rec              csr_get_asg_action_ids%ROWTYPE;
l_period_start_date      DATE;
l_period_end_date        DATE;
Begin
--hr_utility.trace_on(null,'SS');
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

IF g_rec_081_type='C' THEN -- Current Year
  --Get Hours Worked from Balance
     l_balance_amount_h:=Get_Balance_Value(p_assignment_id
                                     ,p_business_group_id
                                     ,'PGGM Hours Worked'
                                     ,'Assignment Period To Date'
                                     ,g_extract_params(p_business_group_id).extract_start_date
                                     ,g_extract_params(p_business_group_id).extract_end_date
                                    );

  --Get Total Hours from Balance
     l_balance_amount_t:=Get_Balance_Value(p_assignment_id
                                       ,p_business_group_id
                                       ,'PGGM Total Hours'
                                       ,'Assignment Period To Date'
                                       ,g_extract_params(p_business_group_id).extract_start_date
                                       ,g_extract_params(p_business_group_id).extract_end_date
                                      );
 --Get Extra hours
 --Get input value id of extra hours
   OPEN csr_get_input_val_id;
   FETCH csr_get_input_val_id INTO l_input_value_id;
   CLOSE csr_get_input_val_id;
   Hr_Utility.set_location('l_input_value_id for extra hours'||l_input_value_id,20);
 --Get total extra hours from run results of whole year (current)
   OPEN csr_get_asg_action_ids( p_assignment_id
                               ,g_extract_params(p_business_group_id).extract_start_date
                               ,g_extract_params(p_business_group_id).extract_end_date
			       );
   LOOP
    FETCH csr_get_asg_action_ids INTO asg_ids_rec;
    EXIT WHEN  csr_get_asg_action_ids%NOTFOUND;
    Hr_Utility.set_location('asg action ids found'||asg_ids_rec.assignment_action_id,20);
    OPEN csr_get_ele_entry_id(  p_assignment_id
                               ,asg_ids_rec.date_earned
                            );
    FETCH csr_get_ele_entry_id INTO l_element_entry_id;

    IF csr_get_ele_entry_id%FOUND THEN
    Hr_Utility.set_location('l_element_entry_id found '||l_element_entry_id,21);
       OPEN csr_get_run_result_value
            (  p_element_entry_id => l_element_entry_id
              ,p_input_value_id   => l_input_value_id
              ,p_asg_act_id       => asg_ids_rec.assignment_action_id
            );
       FETCH csr_get_run_result_value INTO l_extra_hours;
       IF csr_get_run_result_value%FOUND THEN

         Hr_Utility.set_location('run result for extra hours found '||l_extra_hours,23);
       ELSE
         Hr_Utility.set_location('run result for extra hours not found ',24);
       END IF;
       CLOSE csr_get_run_result_value;
       l_total_extra_hours := l_total_extra_hours + NVL(l_extra_hours,0);
       l_extra_hours :=0;
    END IF;
    CLOSE csr_get_ele_entry_id;

   END LOOP;
   CLOSE csr_get_asg_action_ids;

    -- Get sum of retro extra hours
    OPEN csr_retro_extra_hours(p_assignment_id
                                ,g_extract_params(p_business_group_id).extract_start_date
                                ,g_extract_params(p_business_group_id).extract_end_date
                                );
    FETCH csr_retro_extra_hours INTO l_sum_extra_hours;
    CLOSE csr_retro_extra_hours;

     l_total_extra_hours := l_total_extra_hours + NVL(l_sum_extra_hours,0);
     Hr_Utility.set_location('l_total_extra_hours'||l_total_extra_hours,20);
  --End Extra Hours
  OPEN csr_retro_hours_worked(p_assignment_id
                                ,g_extract_params(p_business_group_id).extract_start_date
                                ,g_extract_params(p_business_group_id).extract_end_date
                                 );
     FETCH csr_retro_hours_worked INTO l_sum_hours_worked;
     CLOSE csr_retro_hours_worked;

     Hr_Utility.set_location('l_sum_hours_worked'||l_sum_hours_worked,20);

     OPEN csr_retro_total_hours(p_assignment_id
                                ,g_extract_params(p_business_group_id).extract_start_date
                                 ,g_extract_params(p_business_group_id).extract_end_date
                                );
     FETCH csr_retro_total_hours INTO l_sum_total_hours;
     CLOSE csr_retro_total_hours;
     Hr_Utility.set_location('l_sum_total_hours'||l_sum_total_hours,30);
     --

     l_sum_hours_worked:=NVL(l_sum_hours_worked,0) + NVL(l_total_extra_hours,0) + l_balance_amount_h;
     l_sum_total_hours :=NVL(l_sum_total_hours,0)  +  l_balance_amount_t;

   --Divide hours worked to total hours to get final part time value
     IF l_balance_amount_t <> 0 THEN
       p_data_element_value:=trim(to_char(((l_sum_hours_worked/l_sum_total_hours)*100),'099'));
     Else
       p_data_element_value:=0;
     END IF;
     --p_data_element_value:=lpad(p_data_element_value,6,'0');
 ELSE
     --g_rec_081_type='P' Previous Years
     --Get Hours Worked from Balance
     l_chg_year:=g_rcd_081(g_081_index).year_of_change;

     --Get the period start and end dates
	OPEN  c_get_period_start_date(l_chg_year
	                              ,p_assignment_id
				      ,p_date_earned);
	FETCH c_get_period_start_date INTO l_period_start_date;
	CLOSE c_get_period_start_date;

	OPEN  c_get_period_end_date(l_chg_year
	                           ,p_assignment_id
				   ,p_date_earned);
	FETCH c_get_period_end_date INTO l_period_end_date;
	CLOSE c_get_period_end_date;

     l_balance_amount_h:=Get_Balance_Value(p_assignment_id
                                          ,p_business_group_id
                                          ,'PGGM Hours Worked'
                                          ,'Assignment Period To Date'
                                          ,l_period_start_date
                                          ,l_period_end_date
                                         );
    --Get Total Hours from Balance
    l_balance_amount_t:=Get_Balance_Value(p_assignment_id
                                       ,p_business_group_id
                                       ,'PGGM Total Hours'
                                       ,'Assignment Period To Date'
                                       ,l_period_start_date
                                       ,l_period_end_date
                                      );

   ---------------Calculate Extra Hours-------------------------------------------
   --Get total extra hours from run results of whole year (current)

   --Get input value id of extra hours
   OPEN csr_get_input_val_id;
   FETCH csr_get_input_val_id INTO l_input_value_id;
   CLOSE csr_get_input_val_id;

   OPEN csr_get_asg_action_ids( p_assignment_id
                               ,l_period_start_date
                               ,l_period_end_date
			       );
   LOOP
    FETCH csr_get_asg_action_ids INTO asg_ids_rec;
    EXIT WHEN  csr_get_asg_action_ids%NOTFOUND;

    OPEN csr_get_ele_entry_id(  p_assignment_id
                               ,asg_ids_rec.date_earned
                            );
    FETCH csr_get_ele_entry_id INTO l_element_entry_id;

    IF csr_get_ele_entry_id%FOUND THEN
       OPEN csr_get_run_result_value
            (  p_element_entry_id => l_element_entry_id
              ,p_input_value_id   => l_input_value_id
              ,p_asg_act_id       => asg_ids_rec.assignment_action_id
            );
       FETCH csr_get_run_result_value INTO l_extra_hours;
       CLOSE csr_get_run_result_value;

       l_total_extra_hours := l_total_extra_hours + NVL(l_extra_hours,0);

    END IF;
    CLOSE csr_get_ele_entry_id;

   END LOOP;
   CLOSE csr_get_asg_action_ids;

    -- Get sum of retro extra hours
    OPEN csr_retro_extra_hours(p_assignment_id
                                ,l_period_start_date
                                ,g_extract_params(p_business_group_id).extract_end_date
                                );
    FETCH csr_retro_extra_hours INTO l_sum_extra_hours;
    CLOSE csr_retro_extra_hours;

     l_total_extra_hours := l_total_extra_hours + NVL(l_sum_extra_hours,0);
  ---------------------End Extra Hours ---------------------------------------

     Hr_Utility.set_location('l_total_extra_hours'||l_total_extra_hours,50);

     OPEN csr_retro_hours_worked(p_assignment_id
                                ,l_period_start_date
                                ,g_extract_params(p_business_group_id).extract_end_date
                                 );
     FETCH csr_retro_hours_worked INTO l_sum_hours_worked;
     CLOSE csr_retro_hours_worked;

     Hr_Utility.set_location('l_sum_hours_worked'||l_sum_hours_worked,20);

     OPEN csr_retro_total_hours(p_assignment_id
                                ,l_period_start_date
                                 ,g_extract_params(p_business_group_id).extract_end_date
                                );
     FETCH csr_retro_total_hours INTO l_sum_total_hours;
     CLOSE csr_retro_total_hours;
     Hr_Utility.set_location('l_sum_total_hours'||l_sum_total_hours,30);



       l_sum_hours_worked:=NVL(l_sum_hours_worked,0) + NVL(l_total_extra_hours,0) + l_balance_amount_h;
       l_sum_total_hours :=NVL(l_sum_total_hours,0)  +  l_balance_amount_t;

       --Divide hours worked to total hours to get final part time value
       IF l_sum_total_hours <> 0 THEN
         p_data_element_value:=trim(to_char( ((l_sum_hours_worked/l_sum_total_hours)*100),'099'));
       ELSE
         p_data_element_value:=0;
       END IF;

       --p_data_element_value:=lpad(p_data_element_value,6,'0');
       Hr_Utility.set_location('p_data_element_value'||p_data_element_value,50);
 END IF;
--  hr_utility.trace_off;
     l_ret_val:=0;
Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Final_Part_Time_Val;
-- ===============================================================================
-- ~ Get_Part_Time_Percent
-- ===============================================================================
Function Get_Part_Time_Percent
                 ( p_assignment_id        IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
  )
Return Number IS

CURSOR csr_get_def_bal_type_id(c_balance_name VARCHAR2,c_dimension_name VARCHAR2)  IS
SELECT defined_balance_id
FROM  pay_defined_balances pdb,
      pay_balance_types pbt,
      pay_balance_dimensions pbd
WHERE
      pbt.balance_name =c_balance_name
      and pbd.legislation_code='NL'
      and pbd.DIMENSION_NAME=c_dimension_name
      and pdb.balance_type_id = pbt.balance_type_id
      and pdb.balance_dimension_id = pbd.balance_dimension_id;

--Pick PTP from element entry level
CURSOR csr_get_ptp_val(c_asg_id IN Number,c_date_earned IN DATE)  IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (c_date_earned between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and (c_date_earned between peev.effective_start_date
       and peev.effective_end_date )
   and peev.screen_entry_value is not null;

--Pick ptp value from Std conditions at asg level
CURSOR c_get_ptp_std_asg(c_effective_date IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(target.SEGMENT29,'0')) pt_perc
 FROM  per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  asg.assignment_id = p_assignment_id
  AND  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  c_effective_date between asg.effective_start_date
  AND  asg.effective_end_date
  AND  target.enabled_flag = 'Y';

l_proc_name         Varchar2(150) :=g_proc_name || 'Get_Part_Time_Percent';
l_ret_val           Number:=0;
l_balance_amount    Number :=0;
asgact_rec          csr_asg_act%ROWTYPE;
l_pay_start_date    DATE;
l_pay_end_date      DATE;
l_pay_year          NUMBER;
l_pay_mon           NUMBER;
l_pay_day           NUMBER;
l_irr_pay_amt       NUMBER:=0;
l_def_bal_type_id   NUMBER;
l_ptp_value         NUMBER:=0;
l_ptp_diff          NUMBER:=0;
l_count             NUMBER:=0;
Begin
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

IF g_extract_params(p_business_group_id).extract_type='Y' THEN
l_ret_val:=Get_Final_Part_Time_Val
                 (  p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
  );
ELSE  --For Monthly Report
Hr_Utility.set_location('g_ptp_index  '||g_ptp_index,30);
--Depending upon type of change  in part time  percentage
--or incidental worker code set the part time percentage value

--080 appears due to current changes in Incidental worker code
  IF ( g_ptp_index=300 ) THEN
 --Fetch the ptp effective on changed date (new value)
    --Get the ptp over ridden value from element entry page
    OPEN csr_get_ptp_val(p_assignment_id,g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
   FETCH csr_get_ptp_val INTO l_ptp_value;

     --If not found then pick it from asg std condition
      IF csr_get_ptp_val%NOTFOUND THEN
      OPEN  c_get_ptp_std_asg(g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
      FETCH c_get_ptp_std_asg INTO l_ptp_value;
      CLOSE c_get_ptp_std_asg;
       END IF;
     CLOSE csr_get_ptp_val;

  ELSE
  --080 appears due to retro changes in Incidental worker code
      IF ( g_ptp_index=400 ) THEN
      l_ptp_value:=0;
      --Get the ptp over ridden value from element entry page
         OPEN csr_get_ptp_val(p_assignment_id,g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
         FETCH csr_get_ptp_val INTO l_ptp_value;


      --If not found then pick it from asg std condition
      IF csr_get_ptp_val%NOTFOUND THEN
      OPEN  c_get_ptp_std_asg(g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
      FETCH c_get_ptp_std_asg INTO l_ptp_value;
      CLOSE c_get_ptp_std_asg;
      END IF;
         CLOSE csr_get_ptp_val;

      ELSE
         --080 appears due to current changes in Part time percentage
          IF ( g_ptp_index=100 ) THEN
              Hr_Utility.set_location('g_ptp_index+g_080_index'   ||(g_ptp_index+g_080_index),35);
             l_ptp_value:=g_rcd_080(g_ptp_index+g_080_index).part_time_factor;

         ELSE
     IF(g_ptp_index=200) THEN
       --Fetch the ptp effective on changed date (new value)
        OPEN csr_get_ptp_val(p_assignment_id,g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
       FETCH csr_get_ptp_val INTO l_ptp_value;
       --If not found then pick it from asg std condition
        IF csr_get_ptp_val%NOTFOUND THEN
          OPEN  c_get_ptp_std_asg(g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change);
          FETCH c_get_ptp_std_asg INTO l_ptp_value;
          CLOSE c_get_ptp_std_asg;
        END IF;
        CLOSE csr_get_ptp_val;

    ELSE  --g_ptp_index=0
              l_ptp_value:=Get_Balance_Value
                        (  p_assignment_id
                            ,p_business_group_id
                            ,'PGGM Part Time Percentage'
                            ,'Assignment Period To Date'
                            ,g_extract_params(p_business_group_id).extract_start_date
                            ,g_extract_params(p_business_group_id).extract_end_date
                         );
            END IF;

          END IF;
       END IF;
  END IF;

   p_data_element_value := lpad(fnd_number.number_to_canonical(ceil(l_ptp_value)),3,'0')||'000';

 END IF;
 Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
 l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Part_Time_Percent;
-- ===============================================================================
-- ~ Get_Incidental_Worker
-- ===============================================================================
Function Get_Incidental_Worker
                 ( p_assignment_id         IN Number
                   ,p_business_group_id    IN Number
                   ,p_date_earned          IN DATE
                   ,p_error_message        OUT NOCOPY VARCHAR2
                   ,p_data_element_value   OUT NOCOPY VARCHAR2
               )
Return Number IS
CURSOR csr_get_incidental_wkr_code(c_asg_id Number ,c_date_earned Date) IS
SELECT Decode(scl.SEGMENT1,'Y','0','1')
  FROM per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND c_date_earned BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

/*
SELECT prrv.result_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_run_results prr,
pay_run_result_values prrv
WHERE
  pet.element_name = 'PGGM Pensions General Information'
  and piv.name ='Incidental Worker'
  and piv.element_type_id=pet.element_type_id
  and prr.element_type_id=pet.element_type_id
  and prr.assignment_action_id =c_asg_action_id
  and (c_date_earned between prr.start_date
       and prr.end_date)
  and prrv.run_result_id=prr.run_result_id
  and prrv.input_value_id=piv.input_value_id;
*/
l_proc_name      Varchar2(150) :=g_proc_name || 'Get_Incidental_Worker';
l_ret_val        Number:=0;
l_inci_wkr_code  varchar2(1):='1';
l_start_date     DATE;
l_ptp_start_date varchar2(10);
l_error_message  varchar2(150);
l_orig_date_earned DATE;
asgact_rec       csr_asg_act%ROWTYPE;
Begin
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);
Hr_Utility.set_location(' g_080_index'|| g_080_index,15);
Hr_Utility.set_location(' g_ptp_index'|| g_ptp_index,20);
-- Calculating value for Retro Change
IF g_ptp_index = 400 THEN
   IF(g_rcd_080(g_ptp_index + g_080_index).incidental_code = 1 ) THEN
   l_inci_wkr_code:=0;
   END IF;
   IF(g_rcd_080(g_ptp_index + g_080_index).incidental_code = -1 ) THEN
   l_inci_wkr_code:=1;
   END IF;
ELSE
   IF g_ptp_index = 300 THEN
   l_inci_wkr_code:=g_rcd_080(g_ptp_index + g_080_index).incidental_code;
   ELSE
    IF g_ptp_index= 200 THEN

    --Get the  original date earned from the retro element
    l_orig_date_earned:=g_rcd_080(g_ptp_index + g_080_index).part_time_pct_dt_change;

    -- Get the incidental worker  code on that date
      OPEN  csr_get_incidental_wkr_code(p_assignment_id,l_orig_date_earned);
      FETCH csr_get_incidental_wkr_code INTO l_inci_wkr_code;
      CLOSE csr_get_incidental_wkr_code;

    ELSE --g_ptp_index=100
          IF g_ptp_index = 100 THEN
           l_start_date:=g_rcd_080(g_ptp_index + g_080_index).part_time_pct_dt_change;
           OPEN  csr_get_incidental_wkr_code(p_assignment_id,l_start_date);
           FETCH csr_get_incidental_wkr_code INTO l_inci_wkr_code;
           CLOSE csr_get_incidental_wkr_code;
  ELSE
   OPEN  csr_get_incidental_wkr_code(p_assignment_id,g_extract_params(p_business_group_id).extract_end_date);
           FETCH csr_get_incidental_wkr_code INTO l_inci_wkr_code;
           CLOSE csr_get_incidental_wkr_code;
  END IF;
       END IF;

   END IF;
END IF;

p_data_element_value:=l_inci_wkr_code;

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
 l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Incidental_Worker;
-- ===============================================================================
-- ~ Get_Irregular_Payment_Year
-- ===============================================================================
Function Get_Irregular_Payment_Year
                 ( p_assignment_id         IN Number
                   ,p_business_group_id    IN Number
                   ,p_date_earned          IN DATE
                   ,p_error_message        OUT NOCOPY VARCHAR2
                   ,p_data_element_value   OUT NOCOPY VARCHAR2
               )
Return Number IS
l_proc_name     Varchar2(150) :=g_proc_name || 'Get_Irregular_Payment_Year';
l_ret_val       Number:=0;
l_irr_pay_year  NUMBER;
l_irr_pay_amt   NUMBER:=0;
l_pay_year      NUMBER;
l_pay_mon       NUMBER;
l_pay_day       NUMBER;
l_pay_start_date DATE;
l_pay_end_date   DATE;
Begin
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

--Current year is the irregular payment year
l_irr_pay_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);

p_data_element_value:=l_irr_pay_year;

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
 l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Irregular_Payment_Year;
-- ===============================================================================
-- ~ Get_Irregular_Payment_Amt
-- ===============================================================================
Function Get_Irregular_Payment_Amt
                 ( p_assignment_id         IN Number
                   ,p_business_group_id    IN Number
                   ,p_date_earned          IN DATE
                   ,p_error_message        OUT NOCOPY VARCHAR2
                   ,p_data_element_value   OUT NOCOPY VARCHAR2
               )
Return Number IS

-- Cursor to get Org id for the given asg id
CURSOR csr_get_org_id(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT organization_id
  FROM per_all_assignments_f
 WHERE assignment_id = c_asg_id
   AND business_group_id = bg_id
   AND g_extract_params(p_business_group_id).extract_end_date BETWEEN
       effective_start_date AND effective_end_date;

--Cursor to get organization start date for that assignment
CURSOR csr_get_org_asg_start_date(c_asg_id NUMBER,org_id NUMBER) IS
Select max(effective_start_date) from per_all_assignments_f
where assignment_id = c_asg_id
and organization_id = org_id;


l_proc_name     Varchar2(150) :=g_proc_name || 'Get_Irregular_Payment_Amt';
l_ret_val       Number:=0;
l_irr_pay_amt   NUMBER;
l_pay_start_date  DATE;
l_org_id        NUMBER;

BEGIN
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

l_irr_pay_amt :=Get_Balance_Value(p_assignment_id
                                  ,p_business_group_id
                                  ,'PGGM Pensions Irregular Payments'
                                  ,'Assignment Period To Date'
                                  ,g_extract_params(p_business_group_id).extract_start_date
                                  ,g_extract_params(p_business_group_id).extract_end_date
                                 );
p_data_element_value:= lpad(fnd_number.number_to_canonical(CEIL(l_irr_pay_amt)),6,'0');
/*--For yearly report round the irregular payment amount
IF g_extract_params(p_business_group_id).extract_type='Y' THEN
    p_data_element_value:= lpad(fnd_number.number_to_canonical(CEIL(l_irr_pay_amt)),6,'0');
ELSE
    p_data_element_value:=l_irr_pay_amt;
END IF; */

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
 l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Irregular_Payment_Amt;

-- ===============================================================================
-- ~ Get_Final_PTF_Year:
-- ===============================================================================
Function Get_Final_PTF_Year
                 ( p_assignment_id        IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN DATE
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
                 )
Return Number IS
l_proc_name   Varchar2(150) :=g_proc_name || 'Get_Final_PTF_Year';
l_ret_val     Number:=0;
l_final_year  Number;
BEGIN
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);
--If called from extract
IF g_rec_081_type='C' THEN

l_final_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);
p_data_element_value:=to_char(l_final_year);
ELSE
   IF g_rec_081_type='P' THEN
       p_data_element_value:=g_rcd_081(g_081_index).year_of_change;
   END IF;
END IF;
Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_Final_PTF_Year;
-- ===============================================================================
-- ~ Get_ST_DT_Change_Pens_Sal
-- ===============================================================================
Function Get_ST_DT_Change_Pens_Sal
                 (  p_assignment_id       IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN Date
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
               )
     RETURN NUMBER IS
l_proc_name      Varchar2(150) :=g_proc_name || 'Get_ST_DT_Change_Pens_Sal';
l_ret_val        NUMBER:=0;
l_curr_year      NUMBER:=0;
l_prev_year      NUMBER:=0;
l_pen_sal_date   DATE;
l_start_date_PTP VARCHAR2(10);
l_period_start_date DATE;

BEGIN
Hr_Utility.set_location(' Entering:   '   ||l_proc_name,10);

--Get the current year
l_curr_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);

Hr_Utility.set_location(' l_year   '   ||l_curr_year,15);


IF g_extract_params(p_business_group_id).extract_type='Y' THEN  --Yearly Report
l_curr_year:=l_curr_year+1;

--Get the period start date
OPEN  c_get_period_start_date(l_curr_year
                              ,p_assignment_id
			      ,p_date_earned);
FETCH c_get_period_start_date INTO l_period_start_date;
CLOSE c_get_period_start_date;

   --Get Participation start date
   l_ret_val:=Get_Start_Date_PTP(p_assignment_id
                                ,p_business_group_id
                                ,p_date_earned
                                ,p_error_message
                               ,l_start_date_PTP
                                );

   --Reporting Date is the latest date of hire date and 1st Jan of that year
   --Pension Salary is calculated in this period
   l_pen_sal_date:=l_period_start_date;
   IF l_pen_sal_date < to_date(l_start_date_PTP,'YYYYMMDD') THEN
     l_pen_sal_date:=to_date(l_start_date_PTP,'YYYYMMDD');
   END IF;

    Hr_Utility.set_location(' Pen Sal Date  '   ||l_pen_sal_date,30);

    p_data_element_value:=to_char(l_pen_sal_date,'YYYYMMDD');
    l_ret_val:=0;
ELSE  --Monthy report

     IF g_rec060_mult_flag='Y' THEN --Calling from Record 060
         l_pen_sal_date:=g_rcd_060(g_060_index).pension_sal_dt_change;
        p_data_element_value:=to_char(l_pen_sal_date,'YYYYMMDD');
 l_ret_val:=0;
     ELSE  --other than 060 record

    --Get Participation start date
           l_ret_val:=Get_Start_Date_PTP(p_assignment_id
                                        ,p_business_group_id
                                        ,p_date_earned
                                        ,p_error_message
                                        ,l_start_date_PTP
                                         );

       --Get the period start date
      OPEN  c_get_period_start_date(l_curr_year
                                    ,p_assignment_id
				    ,p_date_earned);
      FETCH c_get_period_start_date INTO l_period_start_date;
      CLOSE c_get_period_start_date;

       --Reporting Date is the latest date of participation start date and 1st Jan of that year
       --Pension Salary is calculated on this date
        l_pen_sal_date:=l_period_start_date;
        IF l_pen_sal_date < to_date(l_start_date_PTP,'YYYYMMDD') THEN
         l_pen_sal_date:=to_date(l_start_date_PTP,'YYYYMMDD');
        END IF;

       p_data_element_value:=to_char(l_pen_sal_date,'YYYYMMDD');
        l_ret_val:=0;

     END IF;  --060 or other record

End IF;-- Report type check

Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_ST_DT_Change_Pens_Sal;
-- ===============================================================================
-- ~ Get_ST_DT_Chg_Part_Time_Per
-- ===============================================================================
Function Get_ST_DT_Chg_Part_Time_Per
                 (  p_assignment_id       IN Number
                   ,p_business_group_id   IN Number
                   ,p_date_earned         IN Date
                   ,p_error_message       OUT NOCOPY VARCHAR2
                   ,p_data_element_value  OUT NOCOPY VARCHAR2
  )
     RETURN NUMBER IS
     /*
CURSOR csr_chk_retro_ptp_ele(c_asg_id NUMBER,bg_id NUMBER) IS
Select pee.screen_entry_value,pee.effective_start_date
FROM
pay_element_entries_f pee,
pay_element_types_f  pet
where pee.assignment_id = c_asg_id
AND pee.element_type_id =pet.element_type_id
AND pet.element_name='Retro PGGM Pensions Part Time Percentage'
AND g_extract_params(bg_id).extract_start_date
Between  pee.effective_start_date and pee.effective_end_date;

CURSOR csr_chk_curr_ptp_ele(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT pee.screen_entry_value,pee.effective_start_date
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and (g_extract_params(bg_id).extract_start_date between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id;*/

l_proc_name   Varchar2(150) :=g_proc_name || 'Get_ST_DT_Chg_Part_Time_Per';
l_ret_val NUMBER:=0;
BEGIN
Hr_Utility.set_location('Entering:'   ||l_proc_name,10);

   Hr_Utility.set_location(' ptp_chg_date   '   ||g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change,25);
   Hr_Utility.set_location(' g_ptp_index,g_080_index'||g_ptp_index||g_080_index,25);

   p_data_element_value:=to_char(g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change,'YYYYMMDD');


Hr_Utility.set_location(' Leaving:   '   ||l_proc_name,50);
l_ret_val:=0;
RETURN l_ret_val;
EXCEPTION
   WHEN OTHERS THEN
      p_error_message :='SQL-ERRM :'||SQLERRM;
      Hr_Utility.set_location('..'||p_error_message,30);
      Hr_Utility.set_location('Leaving: '||l_proc_name,40);
      l_ret_val:=1;
      RETURN l_ret_val;
END Get_ST_DT_Chg_Part_Time_Per;

--============================================================================
-- chk_term_asg_eff
-- Function to check if the assignment is terminated and that
-- the termination has happened before or on the effective date passed
--============================================================================
FUNCTION chk_term_asg_eff
        ( p_assignment_id        IN Number
         ,p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date       IN DATE
        ) RETURN Number IS
CURSOR cur_chk_term IS
SELECT 1 FROM per_periods_of_service
WHERE PERSON_ID = g_person_id
  AND TRUNC(actual_termination_date) <=  trunc(p_effective_date)
  AND NOT EXISTS ( SELECT 1 FROM PER_PERIODS_OF_SERVICE
                    WHERE person_id = g_person_id
                      AND trunc(date_start) BETWEEN  trunc(p_effective_date)
                      AND add_months(trunc(p_effective_date),1) - 1
                      AND actual_termination_date is null) ;

 l_proc_name    Varchar2(150) := g_proc_name ||'chk_term_asg_eff';
 l_return_value Number :=0;
 l_chk          NUMBER := 0;

BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);

   OPEN cur_chk_term;
      FETCH cur_chk_term INTO l_chk;
        IF cur_chk_term%FOUND THEN
           l_return_value := 1;
        ELSIF cur_chk_term%NOTFOUND THEN
           l_return_value := 0;
        END IF;
   CLOSE cur_chk_term;

   Hr_Utility.set_location('Leaving: '||l_proc_name, 10);
   RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   Hr_Utility.set_location('Error -- Leaving: '||l_proc_name, 9);
   l_return_value := 0;
   RETURN l_return_value;
END chk_term_asg_eff;
-- =============================================================================
-- Org_Id_Data Element:Returns  Org Id to Fast formula
-- =============================================================================

FUNCTION Org_Id_DataElement
           (p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
           ,p_business_group_id    IN  per_all_assignments_f.business_group_id%TYPE
           ,p_effective_date       IN  Date
           ,p_error_message        OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_temp_sort_org              Varchar2(50);
  l_proc_name       Varchar2(150) := g_proc_name ||'Sort_Id_Generator';
  l_return_value    Number := 1;


BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);

   IF g_primary_assig.EXISTS(p_assignment_id) THEN
     p_data_element_value := g_primary_assig(p_assignment_id).organization_id;
  END IF;

  l_return_value := 0;
  Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
  RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Org_Id_DataElement;
-- ================================================================================
-- ~ Sort_Id_Generator : It is concatenated with ernum+empNumber+record.
-- ================================================================================
FUNCTION Sort_Id_Generator
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
          ,p_generator_record     IN         Varchar2
           ,p_error_message       OUT NOCOPY Varchar2
          ,p_data_element_value   OUT NOCOPY Varchar2
          ) RETURN Number IS

  l_temp_sort_id    Varchar2(50);
  l_proc_name       Varchar2(150) := g_proc_name ||'Sort_Id_Generator';
  l_employee_number per_all_people_f.Employee_number%TYPE;
  l_temp_person_id  per_all_people_f.Employee_number%TYPE;
   l_return_value    Number := -1;
  l_employer_number Number;
  l_asg_seq_num     Varchar2(2);

BEGIN
  Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
  -- Get the orgId for assigntment ID
 l_return_value := Get_PGGM_ER_Num(p_assignment_id
                                 ,p_business_group_id
                                 ,p_effective_date
                                 ,p_error_message
                                 ,p_data_element_value);
  l_employer_number := Nvl(p_data_element_value,9999999);
  l_employer_number := p_data_element_value;
  p_data_element_value :='';

  IF g_primary_assig.EXISTS(p_assignment_id) THEN
     l_employee_number := g_primary_assig(p_assignment_id).ee_num;
  END IF;

   Hr_Utility.set_location('l_employee_number:   '||l_employee_number, 5);
   l_employer_number := Lpad(l_employer_number,9,0);
   l_employee_number :=Lpad(l_employee_number,6,0);
   l_asg_seq_num     := g_primary_assig(p_assignment_id).asg_seq_num;
   IF To_Number(Nvl(l_asg_seq_num,'1')) < 10 THEN
  l_asg_seq_num := '0' ||Nvl(l_asg_seq_num,'1');
   END IF;

   p_data_element_value :=  l_employer_number ||
                            l_employee_number ||
    l_asg_seq_num     ||
     p_generator_record;

   Hr_Utility.set_location('p_data_element_value:   '||p_data_element_value, 5);
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   l_return_value := 0;

  RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    RETURN l_return_value;
END Sort_Id_Generator;

--Multiple Record Processing for Record 060
Function Process_Mult_Rec060
                (   p_assignment_id     IN         Number
                  ,p_business_group_id  IN         Number
                  ,p_effective_date     IN         DATE
                  ,p_error_message      OUT NOCOPY VARCHAR2
               )
RETURN Number IS

  l_proc_name          Varchar2(150) := g_proc_name ||'Process_Mult_Rec060';
  l_error_message      Varchar2(2000);
  l_ret_val            Number := 0;
  l_rcd_id             Number :=0;
  l_main_rec           csr_rslt_dtl%ROWTYPE;
  l_new_rec            csr_rslt_dtl%ROWTYPE;
  l_evt_dates          DATE;
BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name,5);



   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(6);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   -- Fetch result dtl record
   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;
   -- increase the OVN by 1
   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;
   l_new_rec.val_40 := NULL;
   Hr_Utility.set_location('g_rec_060_count'||g_rec_060_count,80);
   IF g_rec_060_count > 0 THEN
    g_rec060_mult_flag:='Y';
    g_060_index:=g_rcd_060.FIRST;
    While g_060_index IS NOT NULL
    LOOP
           Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    => p_assignment_id
            ,p_organization_id  => NULL
            ,p_effective_date   => p_effective_date
            ,p_ext_dtl_rcd_id   => l_rcd_id
            ,p_rslt_rec         => l_new_rec
            ,p_asgaction_no     => NULL
            ,p_error_message    => p_error_message
   );
    g_060_index:=g_rcd_060.NEXT(g_060_index);

    END LOOP;
    --Reset the flag
    g_rec060_mult_flag:='N';

   END IF;
   --Delete the main rec from the ben table
   IF (g_rec_060_count >0 )
   THEN
         l_main_rec.val_40:='Delete';
         Upd_Rslt_Dtl(l_main_rec);
    Hr_Utility.set_location('Delete main rec',80);
   END IF;

   l_ret_val := 0;

 Hr_Utility.set_location('Leaving: '||l_proc_name,80);
 RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Process_Mult_Rec060;

--Multiple Record Processing for Record 080
Function Process_Mult_Rec080
                (   p_assignment_id      IN         Number
                  ,p_business_group_id   IN         Number
                  ,p_effective_date      IN         DATE
                  ,p_error_message       OUT NOCOPY VARCHAR2
         )
RETURN Number IS

------Cursor to check whether there is any change in part time percentage
CURSOR csr_chk_prev_ptp_ele(c_asg_id NUMBER,bg_id NUMBER,c_date DATE) IS
SELECT peev.screen_entry_value
FROM
pay_element_types_f pet,
pay_input_values_f piv,
pay_element_entries_f pee,
pay_element_entry_values_f peev
WHERE
  pet.element_name = 'PGGM Pensions Part Time Percentage'
  and piv.name ='Part Time Percentage'
  and piv.element_type_id=pet.element_type_id
  and pee.element_type_id=pet.element_type_id
  and pee.assignment_id =c_asg_id
  and ((c_date -1) between pee.effective_start_date
       and pee.effective_end_date)
  and peev.element_entry_id=pee.element_entry_id
  and peev.input_value_id=piv.input_value_id
  and((c_date-1)  between peev.effective_start_date
       and peev.effective_end_date);

-------Cursor to check whether there is any change in incidental worker code
CURSOR csr_chk_inci_code_chg_ele(c_asg_id NUMBER,bg_id NUMBER,c_date DATE) IS
SELECT Decode(scl.SEGMENT1,'Y','0','1') segment1
FROM   per_all_assignments_f asg
      ,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = c_asg_id
  AND (c_date - 1 BETWEEN asg.effective_start_date
  AND asg.effective_end_date)
  AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
  l_proc_name           Varchar2(150) := g_proc_name ||'Process_Mult_Rec080';


  l_evt_dates           DATE;
  l_error_message       Varchar2(2000);
  l_ret_val             Number := 0;
  l_rcd_id              Number :=0;
  l_main_rec            csr_rslt_dtl%ROWTYPE;
  l_new_rec             csr_rslt_dtl%ROWTYPE;
  l_ptp_start_date      DATE;
  l_start_date          DATE;
  l_prev_ptp_val        varchar2(10);
  l_data_element_val    VARCHAR2(10);
  l_080_index           NUMBER;
  l_prev_iwc            VARCHAR2(1);
  l_080_rec_type3_flag  VARCHAR2(1):='Y';
  l_080_rec_type4_flag  VARCHAR2(1):='Y';
  l_check_date          DATE;
  l_ptp_index           NUMBER;

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name,5);


   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(8);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;


   -- Fetch result dtl record
   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );

   Hr_Utility.set_location('l_rcd_id'||l_rcd_id,10);
   Hr_Utility.set_location('g_ext_rslt_id'||Ben_Ext_Thread.g_ext_rslt_id,10);
   Hr_Utility.set_location('g_person_id'||g_person_id,10);

   FETCH csr_rslt_dtl INTO l_main_rec;
   IF csr_rslt_dtl%FOUND THEN
     Hr_Utility.set_location('080 Cursor Found '||l_main_rec.CREATED_BY,10);
   ELSE
     Hr_Utility.set_location('080 Cursor NOT Found ',10);
   END IF;

   CLOSE csr_rslt_dtl;
   -- increase the OVN by 1
   l_new_rec := l_main_rec;
   l_new_rec.val_40 := NULL;
   l_new_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;

    g_080_index:=0;
   Hr_Utility.set_location('g_rec_080_type1_count: '||g_rec_080_type1_count,15);
   -- 1) Loop for Current change in part time percentage
   IF g_rec_080_type1_count > 0 THEN
     g_ptp_index:=100;
     g_080_index:=0;
     FOR l_080_index IN 0..g_rec_080_type1_count-1
     LOOP
           Hr_Utility.set_location('Loop'||g_080_index,80);

      g_080_display_flag:='Y';
           Process_Ext_Rslt_Dtl_Rec
                  (p_assignment_id    => p_assignment_id
                   ,p_effective_date   => p_effective_date
                   ,p_ext_dtl_rcd_id   => l_rcd_id
                   ,p_rslt_rec         => l_new_rec
                   ,p_error_message    => p_error_message
                   );
                  g_080_display_flag:='N';

             g_080_index:= g_080_index + 1;
     END LOOP;
     g_080_index:=0;

   END IF;-- End of g_rec_080_type1_count check

   Hr_Utility.set_location('g_rec_080_type2_count: '||g_rec_080_type2_count,15);
    -- 2) Loop for Retro change in part time percentage
   IF g_rec_080_type2_count > 0 THEN
     g_ptp_index:=200;
     FOR l_080_index IN 0..g_rec_080_type2_count-1
     LOOP

              g_080_display_flag:='Y';
                  Process_Ext_Rslt_Dtl_Rec
                   (p_assignment_id    => p_assignment_id
                   ,p_effective_date   => p_effective_date
                   ,p_ext_dtl_rcd_id   => l_rcd_id
                   ,p_rslt_rec         => l_new_rec
                   ,p_error_message    => p_error_message
                   );
             g_080_display_flag:='N';
     g_080_index:= g_080_index + 1;

     END LOOP;
     g_080_index:=0;
   END IF;-- End of g_rec_080_type2_count check

   Hr_Utility.set_location('g_rec_080_type3_count: '||g_rec_080_type3_count,15);
   -- 3) Loop for Current change in Incidental Worker Code
   IF g_rec_080_type3_count > 0 THEN
     g_ptp_index:=300;


     FOR l_080_index IN 0..g_rec_080_type3_count-1
     LOOP

     --Check if extract date is already in the global table
     --if extract is already processed during ptp processing then do not insert it
     l_ptp_index:=100;
     l_check_date:=g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change;
     For  l_index IN 0..g_rec_080_type1_count-1
     LOOP
   l_080_rec_type3_flag:='Y';
   IF l_check_date=g_rcd_080(l_ptp_index).part_time_pct_dt_change THEN
      l_080_rec_type3_flag:='N';
   END IF;
         l_ptp_index:=l_ptp_index+1;
     END LOOP;
         g_080_display_flag:='Y';

IF l_080_rec_type3_flag <>'N' THEN
                   Process_Ext_Rslt_Dtl_Rec
                   (p_assignment_id    => p_assignment_id
                   ,p_effective_date   => p_effective_date
                   ,p_ext_dtl_rcd_id   => l_rcd_id
                   ,p_rslt_rec         => l_new_rec
                   ,p_error_message    => p_error_message
                   );
         END IF;
  g_080_display_flag:='N';

       g_080_index:= g_080_index + 1;
     END LOOP;
     g_080_index:=0;
   END IF;-- End of g_rec_080_type1_count check

   Hr_Utility.set_location('g_rec_080_type4_count: '||g_rec_080_type4_count,15);
   -- 4) Loop for Retro change in Incidental Worker Code
   IF g_rec_080_type4_count > 0 THEN
     g_ptp_index:=400;
     FOR l_080_index IN 0..g_rec_080_type4_count-1
     LOOP
     --Check if extract date is already in the global table
     --if extract is already processed during ptp processing then do not insert it
     l_ptp_index:=200;
     l_check_date:=g_rcd_080(g_ptp_index+g_080_index).part_time_pct_dt_change;
        Hr_Utility.set_location('l_check_date'||l_check_date,15);
       Hr_Utility.set_location('g_rec_080_type2_count'||g_rec_080_type2_count,15);
     For  l_index IN 0..g_rec_080_type2_count-1
     LOOP
         l_080_rec_type4_flag:='Y';
         Hr_Utility.set_location('g_rcd_080(l_ptp_index).part_time_pct_dt_change'||g_rcd_080(l_ptp_index).part_time_pct_dt_change,15);
       IF l_check_date=g_rcd_080(l_ptp_index).part_time_pct_dt_change THEN
         l_080_rec_type4_flag:='N';
       END IF;
         l_ptp_index:=l_ptp_index+1;
     END LOOP;
         g_080_display_flag:='Y';


      IF l_080_rec_type3_flag <>'N' THEN
                  Process_Ext_Rslt_Dtl_Rec
                   (p_assignment_id    => p_assignment_id
                   ,p_effective_date   => p_effective_date
                   ,p_ext_dtl_rcd_id   => l_rcd_id
                   ,p_rslt_rec         => l_new_rec
                   ,p_error_message    => p_error_message
                   );
      END IF;
      g_080_display_flag:='N';
           g_080_index:= g_080_index + 1;
     END LOOP;
     g_080_index:=0;
   END IF;-- End of g_rec_080_type4_count check

   -- Delete the 080 record created by extract
     IF((g_rec_080_type1_count+g_rec_080_type2_count+g_rec_080_type3_count+g_rec_080_type4_count)>0) THEN
           l_main_rec.val_40:='Delete';
           Upd_Rslt_Dtl(l_main_rec);
     Hr_Utility.set_location('Delete main rec',80);
     END IF;


   l_ret_val := 0;

 Hr_Utility.set_location('Leaving: '||l_proc_name,80);
 RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Process_Mult_Rec080;

--Multiple Record Processing for Record 081
Function Process_Mult_Rec081
                (    p_assignment_id       IN         Number
                     ,p_business_group_id  IN         Number
                     ,p_effective_date     IN         DATE
                     ,p_error_message      OUT NOCOPY VARCHAR2
               )
RETURN Number IS

  l_proc_name          Varchar2(150) := g_proc_name ||'Process_Mult_Rec081';
  l_error_message      Varchar2(2000);
  l_ret_val            Number :=0;
  l_rcd_id             Number :=0;
  l_no_asg_action      NUMBER :=0;
  l_organization_id    NUMBER :=0;
  l_main_rec           csr_rslt_dtl%ROWTYPE;
  l_new_rec            csr_rslt_dtl%ROWTYPE;
  l_081_count          NUMBER:=0;

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name,5);

   IF  g_rec_081_count > 0 THEN

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(9);
   FETCH c_get_rcd_id INTO l_rcd_id;
   CLOSE c_get_rcd_id;

   -- Fetch result dtl record
   OPEN csr_rslt_dtl(c_person_id      => g_person_id
                    ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                    ,c_ext_dtl_rcd_id => l_rcd_id
                   );
   FETCH csr_rslt_dtl INTO l_main_rec;
   CLOSE csr_rslt_dtl;
   -- increase the OVN by 1
   l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
   l_new_rec := l_main_rec;
   l_new_rec.val_40 := NULL;

   g_rec_081_type:='P';
   g_081_index:=0;
   l_081_count:=g_rcd_081.COUNT;
   WHILE g_081_index < l_081_count
   LOOP
            Process_Ext_Rslt_Dtl_Rec
            (p_assignment_id    => p_assignment_id
            ,p_organization_id  => NULL
            ,p_effective_date   => p_effective_date
            ,p_ext_dtl_rcd_id   => l_rcd_id
            ,p_rslt_rec         => l_new_rec
            ,p_asgaction_no     => NULL
            ,p_error_message    => p_error_message
   );
    g_081_index:=g_081_index+1;

   END LOOP;
   --Re set global flag
   g_rec_081_type:='C';
    -- Delete the 081 record created by extract
   IF(g_main_rec_081 = 'D') THEN
     l_main_rec.val_40:='Delete';
     Upd_Rslt_Dtl(l_main_rec);
     Hr_Utility.set_location('Delete main rec',80);
     END IF;
   END IF;

   l_ret_val := 0;

 Hr_Utility.set_location('Leaving: '||l_proc_name,80);
 RETURN l_ret_val;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;
END Process_Mult_Rec081;
-- =============================================================================
-- Process_Mult_Records: For a given assignment multiple records are created for
-- Records 040,060,080. Addl. rows for the record are
-- provided it satisfies the functional requirements for each record i.e. the
-- record display criteria.
-- =============================================================================
FUNCTION Process_Mult_Records
           (p_assignment_id       IN         Number
           ,p_business_group_id   IN         Number
           ,p_effective_date      IN         Date
           ,p_error_message       OUT NOCOPY Varchar2
           )
RETURN Number IS
  l_proc_name          Varchar2(150) := g_proc_name ||'Process_Mult_Records';
  l_data_element_value Varchar2(150);
  l_error_message      Varchar2(2000);
  l_error_flag         Boolean;
  l_ret_val            Number := 0;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 4);

   -- Process Multiple Records for Record 060
   BEGIN
   l_ret_val := Process_Mult_Rec060
                ( p_assignment_id      => p_assignment_id
                  ,p_business_group_id  => p_business_group_id
                  ,p_effective_date     => p_effective_date
                  ,p_error_message      => p_error_message
                );
   Hr_Utility.set_location('..Processed Multi Recds for 060 : '||l_proc_name, 20);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 060 : '||l_proc_name, 12);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
  IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 060 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;
    -- Process Multiple Records for Record 080
   BEGIN
   l_ret_val := Process_Mult_Rec080
                (p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_effective_date     => p_effective_date
                ,p_error_message      => p_error_message
               );
   Hr_Utility.set_location('..Processed Multi Recds for 080 : '||l_proc_name, 12);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 080 : '||l_proc_name, 12);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
   IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 080 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;
    -- Process Multiple Records for Record 081
   BEGIN
   l_ret_val := Process_Mult_Rec081
                ( p_assignment_id      => p_assignment_id
                 ,p_business_group_id  => p_business_group_id
                 ,p_effective_date     => p_effective_date
                 ,p_error_message      => p_error_message
                );
   Hr_Utility.set_location('..Processed Multi Recds for 081 : '||l_proc_name, 20);
   EXCEPTION
      WHEN Others THEN
      Hr_Utility.set_location('..Error in Multi Recds for 081 : '||l_proc_name, 12);
      l_error_message := Substr('SQL-ERRM :'||SQLERRM,1,2000);
      l_error_flag    := TRUE;
   END;
  IF l_ret_val <> 0 THEN
      l_error_message := l_error_message ||
                         'Error in Processing Multi Record 081 for '||
                         'Assignment Id :'||p_assignment_id ;
      l_error_flag    := TRUE;
   END IF;



   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   IF  l_error_flag THEN
       p_error_message := l_error_message;
       RETURN -1;
   ELSE
       RETURN 0;
   END IF;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN -1;

END Process_Mult_Records;
-- ===============================================================================
-- ~ Get_Conc_Prog_Information : Common function to get the concurrent program parameters
-- ===============================================================================
FUNCTION Get_Conc_Prog_Information
           (p_header_type         IN Varchar2
            ,p_error_message      OUT NOCOPY Varchar2
           ,p_data_element_value  OUT NOCOPY Varchar2
)
RETURN Number IS

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Conc_Prog_Information';
l_return_value  Number:=-1;

BEGIN

   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location('p_header_type: '||p_header_type,10);
   IF p_header_type = 'EXTRACT_NAME' THEN
        p_data_element_value := g_conc_prog_details(0).extract_name;
   ELSIF p_header_type = 'PGGM_ER_NAME' THEN
       p_data_element_value := g_conc_prog_details(0).orgname;
   ELSIF p_header_type = 'ELE_SET' THEN
      p_data_element_value := g_conc_prog_details(0).elementset;
   ELSIF p_header_type = 'REPORT_TYPE' THEN
       p_data_element_value := g_conc_prog_details(0).extract_type;
   ELSIF p_header_type = 'EXT_START_DATE' THEN
      p_data_element_value := to_char(g_conc_prog_details(0).beginningdt,'YYMM');
   ELSIF p_header_type = 'END_DT_PAID' THEN
         p_data_element_value := g_conc_prog_details(0).endingdt;
   ELSIF p_header_type = 'PAYROLL_NAME' THEN
      Hr_Utility.set_location('PAYROLL_NAME: '||g_conc_prog_details(0).payrollname, 5);
      p_data_element_value := g_conc_prog_details(0).payrollname;
   ELSIF p_header_type = 'CON_SET' THEN
      p_data_element_value := g_conc_prog_details(0).consolset;
      Hr_Utility.set_location('CON_SET: '||l_return_value, 5);
   END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
   l_return_value:=0;
  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     Hr_Utility.set_location('..Exception Others Raised at  Get_Conc_Prog_Information'||p_error_message,40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     l_return_value:=1;
     RETURN l_return_value;
END Get_Conc_Prog_Information;

-- =============================================================================
-- PQP_NL_GET_DATA_ELEMENT_VALUE
-- This function is used for all rule based data elements
-- =============================================================================

FUNCTION PQP_NL_Get_Data_Element_Value
 (  p_assignment_id      IN Number
   ,p_business_group_id  IN Number
   ,p_date_earned        IN Date
   ,p_data_element_cd    IN Varchar2
   ,p_error_message      OUT NOCOPY Varchar2
   ,p_data_element_value OUT NOCOPY Varchar2
 ) RETURN Number IS

 l_ret_val    Number;
 l_header_type varchar2(40);
 l_debug      Boolean;
 l_proc_name  Varchar2(150) := g_proc_name ||'PQP_NL_Get_Data_Element_Value';

BEGIN

l_ret_val := 0;

   Hr_Utility.set_location(' Entering :      ' || l_proc_name , 5);
   Hr_Utility.set_location(' p_assignment_id ' || p_assignment_id , 10);
   Hr_Utility.set_location(' p_bg_id is      ' || p_business_group_id ,15);
   Hr_Utility.set_location(' p_date_earned   ' || p_date_earned,20 );
   Hr_Utility.set_location(' p_data_ele_cd   ' || p_data_element_cd ,25);
   Hr_Utility.set_location(' g_person_id     ' || g_person_id , 30);

   IF (p_data_element_cd = 'PGGM_ER_NUM') THEN

    l_ret_val := Get_PGGM_ER_Num(p_assignment_id
                               ,p_business_group_id
                               ,p_date_earned
                               ,p_error_message
                               ,p_data_element_value);
    IF ISNUMBER(p_data_element_value) THEN
       p_data_element_value := Trim(To_Char(Fnd_Number.Canonical_To_Number
                                       (Nvl(p_data_element_value,'0'))
                                   ,'099999'));
    END IF;
    ELSIF(p_data_element_cd = 'PGGM_EE_NUM') THEN

     l_ret_val := Get_PGGM_Ee_Num(p_assignment_id
                               ,p_business_group_id
                               ,p_date_earned
                               ,p_error_message
                               ,p_data_element_value);
     IF ISNUMBER(p_data_element_value) THEN
       p_data_element_value := Trim(To_Char(Fnd_Number.Canonical_To_Number
                                       (Nvl(p_data_element_value,'0'))
                                   ,'099'));
     END IF;
     ELSIF(p_data_element_cd = 'EE_NUM') THEN

     l_ret_val := Get_EE_Num(p_assignment_id
                               ,p_business_group_id
                               ,p_date_earned
                               ,p_error_message
                               ,p_data_element_value);

     ELSIF (p_data_element_cd = 'KIND_OF_PARTICIPATION') THEN
     l_ret_val := Get_Kind_Of_PTP
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'INITIALS') THEN
     l_ret_val := Get_Person_Initials
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'OCC_CODE') THEN
     /*l_ret_val := Get_Occupation_Code
                 (p_assignment_id
         ,p_business_group_id
                 ,p_date_earned
         ,p_error_message
         ,p_data_element_value);*/
     p_data_element_value := '00';
     l_ret_val := 0;
     ELSIF (p_data_element_cd = 'HIRE_DATE') THEN
     l_ret_val := Get_Hire_Date
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'GENDER') THEN
     l_ret_val := Get_Gender
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'STREET') THEN
     l_ret_val := Get_Street
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'HOUSE_NUM') THEN
     l_ret_val := Get_House_Num
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'ADDL_HOUSE_NUM') THEN
     l_ret_val := Get_Addl_House_Num
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'EMP_REG_NUM') THEN
     l_ret_val := Get_Emp_Reg_Num
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'POSTAL_CODE') THEN
     l_ret_val := Get_Postal_Code
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'CITY') THEN
     l_ret_val := Get_City
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'CAO_CODE') THEN
     l_ret_val := Get_CAO_Code
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'COUNTRY_CODE') THEN
     l_ret_val := Get_Country_Code
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'ST_DT_PTP') THEN
     l_ret_val := Get_Start_Date_PTP
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'REASON_OF_PTP') THEN
     l_ret_val := Get_Reason_Of_PTP
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'TERM_REASON') THEN
     l_ret_val := Get_Term_Reason
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'END_DT_EMPLOYMENT') THEN
     l_ret_val := Get_End_Date_Of_Employment
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'PENSION_SAL') THEN
     l_ret_val := Get_Pension_Salary
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'IRR_PAYMNT_AMT') THEN
     l_ret_val := Get_Irregular_Payment_Amt
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
     ELSIF (p_data_element_cd = 'IRR_PAYMNT_YEAR') THEN
     l_ret_val := Get_Irregular_Payment_Year
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
    ELSIF (p_data_element_cd = 'HIRE_DATE_PTP') THEN
     l_ret_val := Get_Hire_Date_PTP
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
    ELSIF (p_data_element_cd = 'HIRE_DATE_IWC') THEN
     l_ret_val := Get_Hire_Date_IWC
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );
    ELSIF (p_data_element_cd = 'PART_TIME_PERCENT') THEN
     l_ret_val := Get_Part_Time_Percent
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );

    ELSIF (p_data_element_cd = 'ST_DT_CHANGE_PENS_SAL') THEN
     l_ret_val := Get_ST_DT_Change_Pens_Sal
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'ST_DT_CHG_PART_TIME_PERCENT') THEN
     l_ret_val := Get_ST_DT_Chg_Part_Time_Per
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                 );

     ELSIF (p_data_element_cd = 'FINAL_PART_TIME_PERCENTAGE') THEN
     l_ret_val := Get_Final_Part_Time_Val
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
       p_data_element_value := rpad(lpad(p_data_element_value,3,'0'),6,'0');

     ELSIF (p_data_element_cd = 'INCIDENTAL_WORKER') THEN
     l_ret_val := Get_Incidental_Worker
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'FINAL_PTF_YEAR') THEN
     l_ret_val := Get_Final_PTF_Year
                 ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                   ,p_data_element_value
                  );

     ELSIF (p_data_element_cd = 'PROCESS_MULTIPLE_ASSIGS') THEN
     l_ret_val := Process_Addl_Assigs
                 (  p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                 );
     ELSIF (p_data_element_cd = 'MULTIPLE_RECORDS') THEN
     l_ret_val := Process_Mult_Records
                 (  p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,p_error_message
                 );
     ELSIF (p_data_element_cd = 'HIDE_ORG_ID') THEN
     l_ret_val := Org_Id_DataElement
                          (p_assignment_id
                           ,p_business_group_id
                           ,p_date_earned
                           ,p_error_message
                           ,p_data_element_value
                           );
     ELSIF (p_data_element_cd = 'SORT_ID_010') THEN

     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                    ,p_business_group_id
                    ,p_date_earned
                    ,'010'
                    ,p_error_message
                    ,p_data_element_value
                   );
     ELSIF (p_data_element_cd = 'SORT_ID_020') THEN

     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                    ,p_business_group_id
                    ,p_date_earned
                    ,'020'
                    ,p_error_message
                    ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'SORT_ID_030') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,'030'
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'SORT_ID_040') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,'040'
                   ,p_error_message
                   ,p_data_element_value
                   );
     ELSIF (p_data_element_cd = 'SORT_ID_060') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                    ,p_business_group_id
                    ,p_date_earned
                    ,'060'
                    ,p_error_message
                    ,p_data_element_value
                   );
     ELSIF (p_data_element_cd = 'SORT_ID_070') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,'070'
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'SORT_ID_080') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,'080'
                   ,p_error_message
                   ,p_data_element_value
                  );
     ELSIF (p_data_element_cd = 'SORT_ID_081') THEN
     l_ret_val := Sort_Id_Generator
                  ( p_assignment_id
                   ,p_business_group_id
                   ,p_date_earned
                   ,'081'
                   ,p_error_message
                   ,p_data_element_value
                  );
     END IF;
     p_data_element_value := Upper(p_data_element_value);
     l_ret_val:=0;
     RETURN l_ret_val;

EXCEPTION
   WHEN Others THEN
   p_error_message :='SQL-ERRM :'||SQLERRM;
   Hr_Utility.set_location('..'||p_error_message,85);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   RETURN l_ret_val;
END PQP_NL_GET_DATA_ELEMENT_VALUE;


--============================================================================
--This is used to decide the Record010 hide  or show
--============================================================================
FUNCTION Record010_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

-- The first payroll date is considered as the hire date so that
--late hire scenarios etc. are met
CURSOR csr_chk_new_hire (c_assignment_id      IN Number
                        ) IS
SELECT MIN(ppa.effective_date)
FROM  pay_payroll_actions ppa,
      pay_assignment_actions paa
WHERE paa.assignment_id = c_assignment_id
AND   paa.payroll_action_id = ppa.payroll_action_id
AND   paa.action_status = 'C'
AND   ppa.action_type IN ('R', 'Q', 'I', 'B', 'V');


l_person_id          per_all_people_f.person_id%TYPE;
l_proc_name          VARCHAR2(150) := g_proc_name ||'Record010_Display_Criteria';
l_return_value       NUMBER :=0;
l_new_asg            VARCHAR2(1);
l_prev_pggm_er_num   NUMBER;
l_curr_pggm_er_num   NUMBER;
l_prev_pggm_ee_num   NUMBER;
l_curr_pggm_ee_num   NUMBER;
l_data_element_value VARCHAR2(10);
l_org_id             NUMBER;
l_term_date          DATE;
l_chg_eff_date       DATE;
l_hire_date          DATE;

Begin
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--For yearly report hide this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE
     OPEN csr_chk_new_hire(p_assignment_id);
     FETCH csr_chk_new_hire INTO l_hire_date;
     IF csr_chk_new_hire%FOUND AND
        (l_hire_date >= g_extract_params (p_business_group_id).extract_start_date) AND
        (l_hire_date <= g_extract_params (p_business_group_id).extract_end_date) THEN
        p_data_element_value := 'Y';
     ELSE
        p_data_element_value := 'N';
     END IF;
     CLOSE csr_chk_new_hire;
END IF;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
   l_return_value := 0;
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Record010_Display_Criteria ;

--============================================================================
--This is used to decide the Record_020 hide  or show
--============================================================================
FUNCTION Record020_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_error_message      OUT NOCOPY Varchar2
        ,p_data_element_value  OUT NOCOPY Varchar2
          ) RETURN Number IS

--Cursor to check termination of secondary assignment
CURSOR csr_chk_terminate_sec_asg ( c_assignment_id      IN Number
                             ,c_business_group_id IN Number
                                ) IS
SELECT min(paa.effective_start_date)
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
 WHERE paa.assignment_id           = c_assignment_id
   AND paa.business_group_id       = c_business_group_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='TERM_ASSIGN';

   --Cursor to check termiantion of primary assignment
CURSOR csr_chk_terminate_pri_asg ( c_assignment_id      IN Number
                             ,c_business_group_id IN Number
                                ) IS
SELECT max(paa.effective_end_date)
  FROM per_all_assignments_f paa
 WHERE paa.assignment_id           = c_assignment_id
   AND paa.business_group_id       = c_business_group_id;

l_person_id       per_all_people_f.person_id%TYPE;
l_proc_name       Varchar2(150) := g_proc_name ||'Record020_Display_Criteria';
l_return_value    Number :=0;
l_term_asg        Varchar2(1);
l_rev_asg_dt      DATE;
l_term_asg_dt     DATE;
l_chk_term_asg    NUMBER:=0;
l_org_id          NUMBER;
l_asg_end_date    DATE;
l_term_sec_asg_dt     DATE;
l_term_pri_asg_dt     DATE;
l_already_terminated   NUMBER := 0;

Begin
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--For yearly report hide this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE
  --Assignment termination logic
   OPEN csr_chk_terminate_sec_asg (p_assignment_id, p_business_group_id);
   FETCH csr_chk_terminate_sec_asg INTO l_term_sec_asg_dt;
   IF csr_chk_terminate_sec_asg%FOUND THEN
      IF(l_term_sec_asg_dt >= g_extract_params(p_business_group_id).extract_start_date + 1) AND
        (l_term_sec_asg_dt <= g_extract_params(p_business_group_id).extract_end_date + 1) THEN
        p_data_element_value := 'Y';
      ELSE
        p_data_element_value := 'N';
        l_already_terminated := 1;
      END IF;
    ELSE
     p_data_element_value := 'N';
    END IF;
    CLOSE csr_chk_terminate_sec_asg;

   --End of Employment logic
   IF p_data_element_value <> 'Y' THEN
     OPEN csr_chk_terminate_pri_asg (p_assignment_id, p_business_group_id);
     FETCH csr_chk_terminate_pri_asg INTO l_term_pri_asg_dt;
     IF (l_term_pri_asg_dt >= g_extract_params(p_business_group_id).extract_start_date) AND
         (l_term_pri_asg_dt <= g_extract_params(p_business_group_id).extract_end_date) AND
         l_already_terminated <> 1 THEN
       p_data_element_value := 'Y';
     ELSE
       p_data_element_value := 'N';
     END IF;
     CLOSE csr_chk_terminate_pri_asg;
   END IF;
END IF;--type of report
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 50);
   l_return_value := 0;

RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Record020_Display_Criteria;

--============================================================================
--This is used to decide the Record_030 hide  or show
--============================================================================
FUNCTION Record030_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

--cursor to check for termination of primary assignment
CURSOR csr_chk_terminate_asg (c_assignment_id      IN Number
                              ,c_business_group_id IN Number
                             ) IS
SELECT chg_eff_dt
  FROM ben_ext_chg_evt_log
 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND chg_evt_cd = 'AAT'
   AND (chg_eff_dt BETWEEN  g_extract_params (c_business_group_id).extract_start_date
                       AND g_extract_params (c_business_group_id).extract_end_date)
 ORDER BY ext_chg_evt_log_id desc;

--Cursor to check termiantion of secondary assignment
CURSOR csr_chk_terminate_sec_asg (c_assignment_id      IN Number
                                 ,c_business_group_id IN Number
                                ) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_assignment_id
   AND paa.business_group_id       = c_business_group_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='TERM_ASSIGN'
   AND ( paa.effective_start_date
    BETWEEN  g_extract_params (c_business_group_id).extract_start_date + 1
             AND g_extract_params (c_business_group_id).extract_end_date + 1);

--Cursor to check termiantion of secondary assignment
CURSOR csr_get_asg_end_date (c_assignment_id      IN Number
                             ,c_business_group_id IN Number
                             ) IS
SELECT paa.effective_end_date
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_assignment_id
   AND paa.business_group_id       = c_business_group_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status = 'TERM_ASSIGN';

l_person_id       per_all_people_f.person_id%TYPE;
l_proc_name       Varchar2(150) := g_proc_name ||'Record030_Display_Criteria';
l_return_value    Number :=0;
l_term_asg        Varchar2(1);
l_irr_paymnt      NUMBER:=0;
l_year            NUMBER:=0;
l_term_asg_dt     DATE;
l_rev_asg_dt      DATE;
l_start_date_PTP  DATE;
l_start_date      DATE;
l_data_element_value VARCHAR2(10);
l_chk_term_asg    NUMBER:=0;
l_asg_end_date    DATE;
l_period_start_date DATE;
Begin
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--For yearly report hide this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE
    --Get End date of assignment
    OPEN csr_get_asg_end_date(p_assignment_id
                             ,p_business_group_id);
    FETCH csr_get_asg_end_date INTO l_asg_end_date;
    CLOSE csr_get_asg_end_date;
    --If assignment is already ended then do not process further
    IF NVL(l_asg_end_date,to_Date('47121231','YYYYMMDD')-1) < g_extract_params (p_business_group_id).extract_start_date THEN
        p_data_element_value := 'N';
        Hr_Utility.set_location('Leaving:   '||l_proc_name, 30);
        RETURN 0;
    END IF;
    ----Check for irregular payment balance
    --Get Participation start date
        l_return_value:=Get_Start_Date_PTP(p_assignment_id
                                          ,p_business_group_id
                                          ,p_effective_date
                                          ,p_error_message
                                          ,l_data_element_value
                                           );

        l_start_date_PTP:=to_date(l_data_element_value,'YYYYMMDD');


        l_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);

	--Get the period start and end dates
        OPEN  c_get_period_start_date(l_year
	                              ,p_assignment_id
				      ,p_effective_date);
        FETCH c_get_period_start_date INTO l_period_start_date;
        CLOSE c_get_period_start_date;

        l_start_date:=l_period_start_date;

        IF l_start_date < l_start_date_PTP THEN
             l_start_date:=l_start_date_PTP;
        END IF;

        --Get Irregular amount paid to employee
        l_irr_paymnt :=Get_Balance_Value(p_assignment_id
                                       ,p_business_group_id
                                       ,'PGGM Pensions Irregular Payments'
                                       ,'Assignment Period To Date'
                                       ,l_start_date
                                       ,g_extract_params(p_business_group_id).extract_end_date
                                       );

          IF l_irr_paymnt <= 0   THEN
              p_data_element_value := 'N';
              Hr_Utility.set_location('Leaving:   '||l_proc_name, 35);
             Return 0;
          END IF;

          l_chk_term_asg:=chk_term_asg_eff
                            (  p_assignment_id
                              ,p_business_group_id
                              ,p_effective_date
                            );
    IF  l_chk_term_asg = 1 THEN
       --Check whether person has end of employment event
       OPEN csr_chk_terminate_asg(p_assignment_id,p_business_group_id);
       FETCH csr_chk_terminate_asg INTO l_term_asg_dt;

        IF csr_chk_terminate_asg%FOUND THEN
          CLOSE csr_chk_terminate_asg;
          p_data_element_value := 'Y';
        ELSE  ---csr_chk_terminate_asg not found
          CLOSE csr_chk_terminate_asg;
          p_data_element_value := 'N';
        END IF;  --END of csr_chk_terminate_asg
    ELSE  --l_chk_term_asg is 0

	--Check only for secondary assignment
        OPEN csr_chk_primary_asg(p_assignment_id, p_effective_date);
        FETCH csr_chk_primary_asg INTO l_term_asg;
        IF csr_chk_primary_asg%NOTFOUND THEN
           -- Check for termiantion of secondary assignment
           OPEN csr_chk_terminate_sec_asg(p_assignment_id,p_business_group_id);
           FETCH csr_chk_terminate_sec_asg INTO l_term_asg;

           IF csr_chk_terminate_sec_asg%FOUND THEN
                p_data_element_value := 'Y';
           ELSE
                p_data_element_value := 'N';
           END IF;

           CLOSE csr_chk_terminate_sec_asg;
         ELSE --primary assignment
                  p_data_element_value := 'N';
         END IF;
        CLOSE csr_chk_primary_asg;
     END IF; -- End of End of employment check
END IF;--Type of report

 Hr_Utility.set_location('Leaving:   '||l_proc_name, 5);
 l_return_value := 0;

RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Record030_Display_Criteria;
--============================================================================
--This is used to decide the Record_040 hide  or show
--============================================================================
FUNCTION Record040_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_error_message      OUT NOCOPY Varchar2
         ,p_data_element_value OUT NOCOPY Varchar2
       ) RETURN Number IS



--cursor to check for change in address.
CURSOR csr_chk_chg_address(c_business_group_id  IN Number
                           ) IS
SELECT chg_eff_dt
  FROM ben_ext_chg_evt_log
 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND (chg_evt_cd = 'COCN' ) --OR (chg_evt_cd = 'APA')
   AND ( chg_eff_dt between g_extract_params(c_business_group_id).extract_start_date
                  and g_extract_params(c_business_group_id).extract_end_date )
   ORDER by ext_chg_evt_log_id desc;

--cursor to check for change in foreign address.
CURSOR csr_chk_chg_foreign_address(c_business_group_id IN Number
   ) IS
 SELECT chg_eff_dt
  FROM ben_ext_chg_evt_log

 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND  ( chg_evt_cd = 'COPR' or
           chg_evt_cd = 'COPC' or chg_evt_cd = 'CORS' OR chg_evt_cd = 'APA' )
   AND ( chg_eff_dt between g_extract_params(c_business_group_id).extract_start_date
                  and g_extract_params(c_business_group_id).extract_end_date )
   ORDER by ext_chg_evt_log_id desc;

--cursor to check for change in address.
CURSOR csr_chk_chg_COCN(c_business_group_id  IN Number
                          ,c_effective_date     IN DATE
                        ) IS
 SELECT hrl1.lookup_code
  FROM ben_ext_chg_evt_log,
       hr_lookups hrl1
 WHERE person_id         = g_person_id
   AND business_group_id = c_business_group_id
   AND chg_evt_cd = 'COCN'
   AND  Substr(Nvl(old_val1,'-1'),0,7)=hrl1.meaning
   AND hrl1.LOOKUP_TYPE='PQP_NL_STUCON_CODE_MAPPING'
   AND (chg_eff_dt between  g_extract_params(c_business_group_id).extract_start_date
                  AND g_extract_params(c_business_group_id).extract_start_date)
   AND chg_eff_dt >=
   ( Select min(chg_eff_dt) FROM ben_ext_chg_evt_log
        WHERE person_id         = g_person_id
     AND business_group_id = c_business_group_id
     AND chg_evt_cd = 'COCN'
     AND chg_eff_dt >=c_effective_date
   )
   ORDER by ext_chg_evt_log_id desc;



--Cursor to fetch the old country code from
--the ben_ext_chg_evt_log table in case a change has been made
CURSOR c_get_old_cc( c_effective_date IN DATE) IS
SELECT to_number(hrl1.lookup_code)
  FROM ben_ext_chg_evt_log,
       hr_lookups hrl1
WHERE  chg_evt_cd  = 'COCN'
  AND  ( chg_eff_dt between g_extract_params(p_business_group_id).extract_start_date
                  and g_extract_params(p_business_group_id).extract_end_date )
  AND  Substr(Nvl(old_val1,'-1'),0,7)=hrl1.meaning
  AND  hrl1.lookup_type='PQP_NL_STUCON_CODE_MAPPING'
  AND  person_id = g_person_id
  ORDER by ext_chg_evt_log_id desc;

--Cursor to fetch the new country code from
--the ben_ext_chg_evt_log table in case a change has been made
CURSOR c_get_new_cc(c_effective_date IN DATE) IS
SELECT to_number(hrl1.lookup_code)
  FROM ben_ext_chg_evt_log,
       hr_lookups hrl1
WHERE  chg_evt_cd = 'COCN'
  AND  ( chg_eff_dt between g_extract_params(p_business_group_id).extract_start_date
                  and g_extract_params(p_business_group_id).extract_end_date )
  AND  Substr(Nvl(new_val1,'-1'),0,7)=hrl1.meaning
  AND  hrl1.lookup_type='PQP_NL_STUCON_CODE_MAPPING'
  AND  person_id = g_person_id
  ORDER by ext_chg_evt_log_id desc;

l_old_country_code Number;
l_new_country_code Number;
l_person_id       per_all_people_f.person_id%TYPE;
l_proc_name       Varchar2(150) := g_proc_name ||'Record040_Display_Criteria';
l_return_value    Number :=0;
l_chg_addr        Varchar2(10);
l_eff_date        DATE;
l_country_code    varchar2(5);
l_check           varchar2(10);
Begin
 Hr_Utility.set_location('Entering:   '||l_proc_name, 5);
--For yearly report hide this record
IF (NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y') THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE
--Checking the ben event log  to report if the record is for a change of country code
--initialize
p_data_element_value := 'N';
 OPEN csr_chk_primary_asg (p_assignment_id, p_effective_date);
 FETCH csr_chk_primary_asg INTO l_check;
 IF csr_chk_primary_asg%FOUND THEN
 CLOSE csr_chk_primary_asg;

   OPEN csr_chk_chg_address(p_business_group_id);
   FETCH csr_chk_chg_address INTO l_chg_addr;

   IF csr_chk_chg_address%FOUND THEN
        CLOSE csr_chk_chg_address;
        Hr_Utility.set_location('Inside csr_chk_chg_address', 15);
        Open c_get_old_cc(l_eff_date);
        FETCH  c_get_old_cc INTO l_old_country_code;
        CLOSE c_get_old_cc;

        Hr_Utility.set_location('l_old_country_code'||l_old_country_code, 15);

         Open c_get_new_cc(l_eff_date);
         FETCH  c_get_new_cc INTO l_new_country_code;
         CLOSE c_get_new_cc;

	Hr_Utility.set_location('l_new_country_code'||l_new_country_code, 15);

        IF (l_old_country_code <> 6030 and l_new_country_code = 6030 ) or
           (l_old_country_code = 6030 and l_new_country_code <> 6030 ) or
           (l_old_country_code <> 6030 and l_new_country_code <> 6030 )
        THEN
          p_data_element_value :='Y';
          Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
          l_return_value := 0;
         RETURN l_return_value;
         END IF;

      ELSE
        CLOSE csr_chk_chg_address;
      END IF;


     --Check if there is change in foreign address(Non NL)
     OPEN csr_chk_chg_foreign_address(p_business_group_id);
     FETCH csr_chk_chg_foreign_address INTO l_eff_date;

     IF csr_chk_chg_foreign_address%FOUND THEN


      l_return_value:=Get_Country_Code (p_assignment_id
                                        ,p_business_group_id
                                        ,p_effective_date
                                        ,p_error_message
                                        ,l_country_code);
      Hr_Utility.set_location('l_country_code:   '||l_country_code ||'for'||g_person_id, 60);
         IF (to_number(l_country_code) <> 6030) THEN
           p_data_element_value :='Y';
         END IF;
      END IF;
      CLOSE csr_chk_chg_foreign_address;

   ELSE  --csr_chk_primary_asg not found
   CLOSE csr_chk_primary_asg;
   p_data_element_value :='N';

  END IF;

End IF;
   Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
   l_return_value := 0;

RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value:=1;
    RETURN l_return_value;
END Record040_Display_Criteria;
--============================================================================
--This is used to decide the Record_060 hide  or show
--============================================================================
FUNCTION Record060_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  Date
         ,p_error_message      OUT NOCOPY Varchar2
 ,p_data_element_value OUT NOCOPY Varchar2
          )
RETURN Number IS
Cursor csr_retro_pggm_gen_info_entry IS
Select 'x'
from pay_element_entries_f  pee,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_entry_values_f peev
where
(    pet.element_name ='Retro PGGM Pensions General Information'
 OR  pet.element_name ='Retro PGGM Pensions General Information Previous Year')
 AND piv.name = 'Annual Pension Salary'
 AND piv.element_type_id=pet.element_type_id
 AND pee.assignment_id=p_assignment_id
 AND pee.element_type_id =pet.element_type_id
 AND  (p_effective_date between pee.effective_start_date
                AND pee.effective_end_date )
 AND peev.element_entry_id=pee.element_entry_id
 AND peev.input_value_id=piv.input_value_id
 AND ( p_effective_date between peev.effective_start_date
                AND peev.effective_end_date )
 AND peev.screen_entry_value is not null;


CURSOR csr_chk_active_asg(c_asg_id NUMBER,bg_id NUMBER,eff_date DATE) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_asg_id
   AND paa.business_group_id       = bg_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND (eff_date between paa.effective_start_date and paa.effective_end_date);

CURSOR c_get_period_num(c_extract_start_date IN DATE
                       ,c_assignment_id IN NUMBER
		       ,c_date_earned IN DATE
) IS
SELECT NVL(period_num,0)
FROM  per_all_assignments_f PAA
     ,per_time_periods TPERIOD
WHERE
PAA.assignment_id = c_assignment_id
AND TPERIOD.payroll_id = PAA.payroll_id
AND c_date_earned between PAA.effective_start_date and PAA.effective_end_date
AND c_extract_start_date between TPERIOD.start_date and TPERIOD.end_date;

 l_return_value NUMBER :=0;
l_proc_name    Varchar2(150) := g_proc_name ||'Record060_Display_Criteria';
l_chk_entry     varchar2(1);
l_year          NUMBER;
l_mon           NUMBER;
l_eff_date      DATE;
l_period_start_date DATE;

Begin
--hr_utility.trace_on(null,'SS');
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--If yearly report then do not show this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y' THEN
  p_data_element_value := 'N';
ELSE
 --Check whether assignment is active or not


 l_year:=Get_year(p_assignment_id
                       ,g_extract_params(p_business_group_id).extract_start_date
	    	       ,g_extract_params(p_business_group_id).extract_end_date);
 Hr_Utility.set_location('l_year :   '||l_year, 15);
 --Get the period number of payroll from the extract start date
 OPEN c_get_period_num(g_extract_params(p_business_group_id).extract_start_date,
                       p_assignment_id
		       ,p_effective_date);
 FETCH c_get_period_num INTO l_mon;
 CLOSE c_get_period_num;
  Hr_Utility.set_location('l_mon :   '||l_mon, 16);
 --Get the period start date
  OPEN  c_get_period_start_date(l_year
                                ,p_assignment_id
				,p_effective_date);
  FETCH c_get_period_start_date INTO l_period_start_date;
  CLOSE c_get_period_start_date;

 l_eff_date:=l_period_start_date;
    Hr_Utility.set_location('l_eff_date :   '||l_eff_date, 17);
   --OPEN csr_chk_active_asg(p_assignment_id,p_business_group_id,l_eff_date);
   OPEN csr_chk_active_asg(p_assignment_id,p_business_group_id,p_effective_date);
   FETCH csr_chk_active_asg INTO l_chk_entry;
   --For First month(pay period) of the year only
   IF csr_chk_active_asg%FOUND AND l_mon=1 THEN
      p_data_element_value := 'Y';
      CLOSE csr_chk_active_asg;
      Return 0;
   ELSE
      p_data_element_value := 'N';
   END IF;
   CLOSE csr_chk_active_asg;


  OPEN csr_retro_pggm_gen_info_entry;
  FETCH csr_retro_pggm_gen_info_entry  INTO l_chk_entry;
   IF csr_retro_pggm_gen_info_entry%FOUND THEN
   p_data_element_value := 'Y';
   ElSE
   p_data_element_value := 'N';
   End IF;
   CLOSE csr_retro_pggm_gen_info_entry ;
END IF;
l_return_value:=0;
Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
-- Hr_Utility.trace_off;
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value:=1;
    RETURN l_return_value;
END Record060_Display_Criteria;
--============================================================================
--This is used to decide the Record_070 hide  or show
--============================================================================
FUNCTION Record070_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY Varchar2
 ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

CURSOR csr_chk_active_asg(c_asg_id NUMBER,bg_id NUMBER,eff_date DATE) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_asg_id
   AND paa.business_group_id       = bg_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='ACTIVE_ASSIGN'
   AND (eff_date between paa.effective_start_date and paa.effective_end_date);

CURSOR csr_chk_active_asg_period(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_asg_id
   AND paa.business_group_id       = bg_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='ACTIVE_ASSIGN'
   AND (paa.effective_start_date between g_extract_params(bg_id).extract_start_date
          and g_extract_params(bg_id).extract_end_date );

l_return_value NUMBER :=-1;
l_proc_name    Varchar2(150) := g_proc_name ||'Record070_Display_Criteria';
l_irr_paymnt    Number:=0;
l_year          Number:=0;
l_chk           varchar2(1);
l_period_start_date DATE;
l_period_end_date DATE;

Begin
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--If monthly report then hide this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'M' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE

   --Check whether assignment is active or not
   OPEN csr_chk_active_asg(p_assignment_id,p_business_group_id,g_extract_params(p_business_group_id).extract_start_date);
   FETCH csr_chk_active_asg INTO l_chk;
   IF csr_chk_active_asg%FOUND THEN
      CLOSE csr_chk_active_asg;
      p_data_element_value := 'Y';
   ELSE
     CLOSE csr_chk_active_asg;

     OPEN csr_chk_active_asg_period(p_assignment_id,p_business_group_id);
     FETCH csr_chk_active_asg_period INTO l_chk;
     IF csr_chk_active_asg_period%FOUND THEN
         CLOSE csr_chk_active_asg_period;
         p_data_element_value := 'Y';
     ELSE
        CLOSE csr_chk_active_asg_period;
        p_data_element_value := 'N';
        Hr_Utility.set_location('Leaving:   '||l_proc_name, 35);
      RETURN 0;
     END IF;
   END IF;


  l_year:=Get_year(p_assignment_id
                   ,g_extract_params(p_business_group_id).extract_start_date
	    	   ,g_extract_params(p_business_group_id).extract_end_date);

  Hr_Utility.set_location('l_year  '||l_year, 25);
  --Get the period start and end dates
  OPEN  c_get_period_start_date(l_year
                                ,p_assignment_id
				,p_effective_date);
  FETCH c_get_period_start_date INTO l_period_start_date;
  CLOSE c_get_period_start_date;

  OPEN  c_get_period_end_date(l_year
                              ,p_assignment_id
			      ,p_effective_date);
  FETCH c_get_period_end_date INTO l_period_end_date;
  CLOSE c_get_period_end_date;

  l_irr_paymnt :=Get_Balance_Value(p_assignment_id
                                  ,p_business_group_id
                                  ,'PGGM Pensions Irregular Payments'
                                  ,'Assignment Period To Date'
                                  ,l_period_start_date
                                  ,l_period_end_date
                                  );
Hr_Utility.set_location('Irregular balance amount'||l_irr_paymnt, 25);
    IF l_irr_paymnt  > 0   THEN
    p_data_element_value := 'Y';
    ELSE
    p_data_element_value := 'N';
    END IF;
END IF;

l_return_value:=0;
Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value:=1;
    RETURN l_return_value;
END Record070_Display_Criteria;
--============================================================================
--This is used to decide the Record_080 hide  or show
--============================================================================
FUNCTION Record080_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY Varchar2
 ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS
Cursor csr_retro_pggm_ptp_entry  IS
Select 'x'
from pay_element_entries_f  pee,
     pay_element_types_f pet
     where pet.element_name='Retro PGGM Pensions Part Time Percentage Information Element'
     and pee.assignment_id=p_assignment_id
     and pet.element_type_id =pee.element_type_id
     and p_effective_date between pee.effective_start_date
                     and pee.effective_end_date;
l_return_value NUMBER :=-1;
l_proc_name    Varchar2(150) := g_proc_name ||'Record080_Display_Criteria';
l_curr_val     NUMBER:=0;
l_prev_val     NUMBER:=0;
l_chk_entry    varchar2(1);
l_start_date   NUMBER:=0;
l_end_date     NUMBER:=0;
l_mon          NUMBER:=0;
l_year         NUMBER:=0;
l_prev_mon     NUMBER:=0;
Begin
Hr_Utility.set_location('Entering :   '||l_proc_name, 10);
--If yearly report hide this record
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'M') = 'Y' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE
p_data_element_value:=g_080_display_flag;
l_return_value:=0;
END IF;
Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value:=1;
    RETURN l_return_value;
END Record080_Display_Criteria;
--============================================================================
--This is used to decide the Record_081 hide  or show
--============================================================================
FUNCTION Record081_Display_Criteria
         (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
         ,p_business_group_id  IN  per_all_assignments_f.business_group_id%TYPE
         ,p_effective_date     IN  DATE
         ,p_error_message      OUT NOCOPY Varchar2
 ,p_data_element_value OUT NOCOPY Varchar2
          ) RETURN Number IS

CURSOR csr_chk_active_asg(c_asg_id NUMBER,bg_id NUMBER,eff_date DATE) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_asg_id
   AND paa.business_group_id       = bg_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='ACTIVE_ASSIGN'
   AND (eff_date between paa.effective_start_date and paa.effective_end_date);

CURSOR csr_chk_active_asg_period(c_asg_id NUMBER,bg_id NUMBER) IS
SELECT 'x'
  FROM per_all_assignments_f paa,
       per_assignment_status_types past
WHERE  paa.assignment_id           = c_asg_id
   AND paa.business_group_id       = bg_id
   AND paa.assignment_status_type_id=past.assignment_status_type_id
   AND past.per_system_status ='ACTIVE_ASSIGN'
   AND (paa.effective_start_date between g_extract_params(bg_id).extract_start_date
          and g_extract_params(bg_id).extract_end_date );
/*
Cursor csr_retro_pggm_ptp_entry(c_assignment_id NUMBER)  IS
Select 'x'
from pay_element_entries_f  pee,
     pay_element_types_f pet
     where pet.element_name='Retro PGGM Pensions Part Time Percentage'
     and pee.assignment_id=c_assignment_id
     and pet.element_type_id =pee.element_type_id
     and ( pee.effective_start_date between g_extract_params(p_business_group_id).extract_start_date
          and  g_extract_params(p_business_group_id).extract_end_date)
     and pee.source_start_date < g_extract_params(p_business_group_id).extract_start_date;*/

l_return_value NUMBER :=0;
l_proc_name    Varchar2(150) := g_proc_name ||'Record081_Display_Criteria';
l_emp_contri      NUMBER:=0;
l_employer_contri NUMBER:=0;
l_pay_year        NUMBER:=0;
l_pay_mon         NUMBER:=0;
l_pay_day         NUMBER:=0;
l_pay_start_date  DATE;
l_pay_end_date    DATE;
l_chk             varchar2(1);

Begin
Hr_Utility.set_location('Entering:   '||l_proc_name, 10);
IF NVL(g_extract_params (p_business_group_id).extract_type  ,'N') = 'M' THEN
 p_data_element_value := 'N';
 RETURN 0;
ELSE

 --Check whether assignment is to be included or not
   OPEN csr_chk_active_asg(p_assignment_id,p_business_group_id,g_extract_params(p_business_group_id).extract_start_date);
   FETCH csr_chk_active_asg INTO l_chk;
   IF csr_chk_active_asg%FOUND THEN
      CLOSE csr_chk_active_asg;
      p_data_element_value := 'Y';
   ELSE
     CLOSE csr_chk_active_asg;

     OPEN csr_chk_active_asg_period(p_assignment_id,p_business_group_id);
     FETCH csr_chk_active_asg_period INTO l_chk;
     IF csr_chk_active_asg_period%FOUND THEN
         CLOSE csr_chk_active_asg_period;
         p_data_element_value := 'Y';
     ELSE
        CLOSE csr_chk_active_asg_period;
        p_data_element_value := 'N';
        Hr_Utility.set_location('Leaving:   '||l_proc_name, 35);
      RETURN 0;
     END IF;
   END IF;

   --Calculate deduction amount

   l_emp_contri:=Get_Balance_value(p_assignment_id
                                  ,p_business_group_id
                                  ,'PGGM Employee Contribution'
                                  ,'Assignment Period To Date'
                                  ,g_extract_params(p_business_group_id).extract_start_date
                                  ,g_extract_params(p_business_group_id).extract_end_date
                                 );
   l_employer_contri:=Get_Balance_value(p_assignment_id
                                        ,p_business_group_id
                                        ,'PGGM Employer Contribution'
                                        ,'Assignment Period To Date'
                                        ,g_extract_params(p_business_group_id).extract_start_date
                                        ,g_extract_params(p_business_group_id).extract_end_date
                                       );

 --Record 081 for current year reporting
 IF (l_emp_contri + l_employer_contri) > 0  THEN
        p_data_element_value:='Y';
 ELSE
     IF g_rec_081_count > 0 THEN
         --set the global flag so that 081 record created by extract can be deleted
 g_main_rec_081:='D';
         p_data_element_value:='Y';
     ELSE
         p_data_element_value:='N';
     END IF;
 END IF;


  l_return_value:=0;
END IF;
Hr_Utility.set_location('Leaving:   '||l_proc_name, 65);
RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    p_data_element_value := 'N';
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_return_value:=1;
    RETURN l_return_value;
END Record081_Display_Criteria;

-- =============================================================================
-- Chk_If_Req_To_Extract: For a given assignment check to see the record needs to
-- be extracted or not.
-- =============================================================================
FUNCTION Chk_If_Req_To_Extract
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_effective_date    IN Date
          ,p_record_num        IN Varchar2
          ,p_error_message     OUT NOCOPY Varchar2)
RETURN Varchar2 IS

   l_proc_name          Varchar2(150) := g_proc_name ||'Chk_If_Req_To_Extract';
   l_return_value       Number :=0;
   l_data_element_value Varchar2(2):='Y';

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location('..p_record_num : '||p_record_num , 6);
   IF p_record_num = '010' THEN
     l_return_value := Record010_Display_Criteria
                       (p_assignment_id      => p_assignment_id
                       ,p_business_group_id  => p_business_group_id
                       ,p_effective_date     => p_effective_date
                       ,p_error_message      => p_error_message
                       ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '020' THEN
     l_return_value := Record020_Display_Criteria
                        (p_assignment_id      => p_assignment_id
                        ,p_business_group_id  => p_business_group_id
                        ,p_effective_date     => p_effective_date
                        ,p_error_message      => p_error_message
                        ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '030' THEN
     l_return_value :=  Record030_Display_Criteria
                        (p_assignment_id      => p_assignment_id
                        ,p_business_group_id  => p_business_group_id
                        ,p_effective_date     => p_effective_date
                        ,p_error_message      => p_error_message
                        ,p_data_element_value => l_data_element_value
                        );
   ELSIF p_record_num = '040' THEN
     l_return_value :=  Record040_Display_Criteria
                        (p_assignment_id      => p_assignment_id
                        ,p_business_group_id  => p_business_group_id
                        ,p_effective_date     => p_effective_date
                        ,p_error_message      => p_error_message
                        ,p_data_element_value => l_data_element_value
                        );

   ELSIF p_record_num = '060' THEN
     l_return_value :=  Record060_Display_Criteria
                        (p_assignment_id      => p_assignment_id
                         ,p_business_group_id  => p_business_group_id
                         ,p_effective_date     => p_effective_date
                         ,p_error_message      => p_error_message
                         ,p_data_element_value => l_data_element_value
                        );

   ELSIF p_record_num = '070' THEN
          l_return_value := Record070_Display_Criteria
                    (p_assignment_id
                    ,p_business_group_id
                    ,p_effective_date
                    ,p_error_message
                    ,l_data_element_value);

  ELSIF p_record_num = '080' THEN
          l_return_value := Record080_Display_Criteria(p_assignment_id
                            ,p_business_group_id
                            ,p_effective_date
                            ,p_error_message
                            ,l_data_element_value);

   ELSIF p_record_num = '081' THEN
          l_return_value := Record081_Display_Criteria
                            (p_assignment_id
                             ,p_business_group_id
                             ,p_effective_date
                             ,p_error_message
                             ,l_data_element_value);
   ELSIF p_record_num = '10h' THEN
       l_data_element_value := 'Y';
   ELSE
     l_data_element_value := 'N';
   END IF;
   Hr_Utility.set_location('..l_data_element_value: '||l_data_element_value,45);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
   IF(l_return_value <> 0) THEN
    l_data_element_value:='E';
   END IF;

   RETURN l_data_element_value;

EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    l_data_element_value:='E';
    RETURN l_data_element_value;

END Chk_If_Req_To_Extract;

-- ====================================================================
-- Raise_Extract_Warning:
--    When called from the Rule of a extract detail data element
--    it logs a warning in the ben_ext_rslt_err table against
--    the person being processed (or as specified by context of
--    assignment id ). It prefixes all warning messages with a
--    string "Warning raised in data element "||element_name
--    This allows the same Rule to be called from different data
--    elements. Usage example.
--    RAISE_EXTRACT_WARNING("No initials were found.")
--    RRTURNCODE  MEANING
--    -1          Cannot raise warning against a header/trailer
--                record. System Extract does not allow it.
--    -2          No current extract process was found.
--    -3          No person was found.A Warning in System Extract
--                is always raised against a person.
-- ====================================================================

FUNCTION Raise_Extract_Warning
         (p_assignment_id     IN     Number -- context
         ,p_error_text        IN     Varchar2
         ,p_error_NUMBER      IN     Number DEFAULT NULL
          ) RETURN Number IS
  l_ext_rslt_id   Number;
  l_person_id     Number;
  l_error_text    Varchar2(2000);
  l_return_value  Number:= 0;
BEGIN
  --
    IF p_assignment_id <> -1 THEN
      l_ext_rslt_id:= get_current_extract_result;
      IF l_ext_rslt_id <> -1 THEN
        IF p_error_NUMBER IS NULL THEN
          l_error_text:= 'Warning raised in data element '||
                          Nvl(Ben_Ext_Person.g_elmt_name
                             ,Ben_Ext_Fmt.g_elmt_name)||'. '||
                          p_error_text;
        ELSE
          Ben_Ext_Thread.g_err_num  := p_error_NUMBER;
          Ben_Ext_Thread.g_err_name := p_error_text;
          l_error_text :=
            Ben_Ext_Fmt.get_error_msg(To_Number(Substr(p_error_text, 5, 5)),
              p_error_text,Nvl(Ben_Ext_Person.g_elmt_name,Ben_Ext_Fmt.g_elmt_name) );

        END IF;
        l_person_id:= Nvl(get_current_extract_person(p_assignment_id)
                       ,Ben_Ext_Person.g_person_id);

        IF l_person_id IS NOT NULL THEN
        --
          Ben_Ext_Util.write_err
            (p_err_num           => p_error_NUMBER
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'W'
            ,p_person_id         => l_person_id
            ,p_request_id        => Fnd_Global.conc_request_id
            ,p_business_group_id => Fnd_Global.per_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );
          l_return_value:= 0;
        ELSE
          l_return_value:= -3;
        END IF;
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;
    --
    ELSE
    --
      l_return_value := -1; /* Cannot raise warnings against header/trailers */
    --
    END IF;
  --
  RETURN l_return_value;
END Raise_Extract_Warning;

-- ===============================================================================
-- ~ Get_Trailer_Record_Count : This is used to calculate the record count
-- ===============================================================================
FUNCTION Get_Trailer_Record_Count
           (p_rcd_id  IN Number
   ,p_org_id IN Number
           ) RETURN Number IS

 CURSOR csr_get_record_count(c_record_id IN Number
                            ,c_org_id IN Number ) IS
   SELECT Count(dtl.ext_rslt_dtl_id)
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
     AND ext_rcd_id IN(c_record_id);
     --AND val_31=c_org_id;

l_proc_name     Varchar2(150) := g_proc_name ||'.Get_Trailer_Record_Count';
l_record_count Number  := 0;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   OPEN csr_get_record_count(p_rcd_id,p_org_id);
   FETCH csr_get_record_count INTO l_record_count;
   CLOSE csr_get_record_count;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN l_record_count;
EXCEPTION
  WHEN Others THEN
     Hr_Utility.set_location('Exception Others Raised at Get_Trailer_Record_Count',40);
     Hr_Utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN -1;
END Get_Trailer_Record_Count;

-- ================================================================================
-- ~ Sort_Post_Process : Post process logic
-- ================================================================================
FUNCTION Sort_Post_Process
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
          )RETURN Number IS

CURSOR csr_get_rslt(c_org_id         IN Varchar2
                   ,c_ext_rslt_id    IN Number ) IS
SELECT DISTINCT(val_32) val_32
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND val_31= c_org_id
      ORDER BY val_32 ASC ;

CURSOR csr_get_rslt1(c_ext_rslt_id    IN Number ) IS
SELECT val_31,val_32
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      ORDER BY val_32 ASC;

CURSOR csr_rslt_dtl_sort(c_val_32         IN Varchar2
                        ,c_ext_rslt_id    IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
    --  AND dtl.person_id   = c_person_id
      AND dtl.val_32      =c_val_32;



CURSOR csr_get_header_rslt(c_ext_rslt_id    IN Number
             ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND ext_rcd_id= c_ext_dtl_rcd_id;


CURSOR csr_get_trailer_rslt(c_ext_rslt_id    IN Number
           ,c_ext_dtl_rcd_id IN Number ) IS
SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND ext_rcd_id= c_ext_dtl_rcd_id;

-- Cursor to get the person existence flag
CURSOR csr_get_person_exist(c_org_id IN Number) IS
SELECT 'x'
  FROM  ben_ext_rslt_dtl
  WHERE ext_rslt_id=Ben_Ext_Thread.g_ext_rslt_id
  AND   val_31=c_org_id;


l_ext_dtl_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE;
l_rcd_id            NUMBER;
l_rcd_id_060        NUMBER;
l_rcd_id_080        NUMBER;
l_rcd_id_081        NUMBER;

l_ext_main_rcd_id   ben_ext_rcd.ext_rcd_id%TYPE;
l_proc_name         Varchar2(150):=  g_proc_name||'Sort_Post_Process';
l_return_value      Number := 0; --0= Sucess, -1=Error;
l_tmp_person_id     Number;
l_tmp_org_id        Number;
l_first_flag        Number  :=0;
l_org_pram_id       hr_all_organization_units.organization_id%TYPE;
l_temp_org_pram_id  hr_all_organization_units.organization_id%TYPE;
l_org_detl          g_org_list%TYPE;
l_org_index         Number :=1;
l_global_contribution Number :=0;
l_first_person_id   Number;
l_main_rec          csr_rslt_dtl_sort%ROWTYPE;
l_new_rec           csr_rslt_dtl_sort%ROWTYPE;
l_header_main_rec   csr_get_header_rslt%ROWTYPE;
l_header_new_rec    csr_get_header_rslt%ROWTYPE;
l_trailer_main_rec  csr_get_trailer_rslt%ROWTYPE;
l_trailer_new_rec   csr_get_trailer_rslt%ROWTYPE;
sort_val            Number :=1;
l_sort_val          Varchar2(15);
l_emp_ext_chk       Number:=0;
l_org_count         Number :=0;
l_org_name          hr_all_organization_units.NAME%TYPE;
l_insert_trailer    Number := 1;
l_first_trailer_flag  Number :=0;
l_Person_Exists     Varchar2(2):='y';
i Number := 0;
l_ext_rslt_dtl_id  Number;
l_count            Number := 0;
l_000_rslt_dtl_id  NUMBER;
l_999_rslt_dtl_id  NUMBER;
l_010_count        NUMBER;
l_020_count        NUMBER;
l_030_count        NUMBER;
l_040_count        NUMBER;
l_060_count        NUMBER;
l_070_count        NUMBER;
l_080_count        NUMBER;
l_081_count        NUMBER;
l_total_data_rcd_count        NUMBER;
l_delete_count     NUMBER:=0;
l_delete_index     NUMBER:=0;
del_index          NUMBER:=0;
l_999_inserted     NUMBER := 0;
l_000_inserted     NUMBER := 0;

BEGIN
  Hr_Utility.set_location('Entering :---------'||l_proc_name, 5);

  -- Delete all the hidden Records
   FOR csr_rcd_rec IN csr_ext_rcd_id
                      (c_hide_flag   => 'Y' -- N=No Y=Yes
                      ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
  -- Loop through each detail record for the extract
   LOOP
       -- Delete all detail records for the record which are hidden
       DELETE ben_ext_rslt_dtl
        WHERE ext_rcd_id        = csr_rcd_rec.ext_rcd_id
          AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
          AND business_group_id = p_business_group_id;
   END LOOP; -- FOR csr_rcd_rec

--Fetch the record id from the sequence number
   OPEN c_get_rcd_id(6);
   FETCH c_get_rcd_id INTO l_rcd_id_060;
   CLOSE c_get_rcd_id;

--Fetch the record id from the sequence number
   OPEN c_get_rcd_id(8);
   FETCH c_get_rcd_id INTO l_rcd_id_080;
   CLOSE c_get_rcd_id;

   --Fetch the record id from the sequence number
   OPEN c_get_rcd_id(9);
   FETCH c_get_rcd_id INTO l_rcd_id_081;
   CLOSE c_get_rcd_id;

   --Delete all extra records created by system extract
    DELETE ben_ext_rslt_dtl
        WHERE ext_rcd_id        IN ( l_rcd_id_060,l_rcd_id_080,l_rcd_id_081 )
          AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
          AND business_group_id = p_business_group_id
          AND val_40='Delete';


     -- All orgs,fill up the temp. table with the org ids in order of
     --the sort value
      FOR val IN csr_get_rslt1
                (c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id )
      LOOP
         hr_utility.set_location('val 32 : '||val.val_32,10);
         IF g_org_list.EXISTS(val.val_31) THEN
            IF NOT g_ord_details1.EXISTS(val.val_31) THEN
               hr_utility.set_location('l_org_index : '||l_org_index,20);
               hr_utility.set_location('org : '||val.val_31,30);
               g_ord_details(l_org_index).gre_org_id := val.val_31;
               g_ord_details1(to_number(val.val_31)).gre_org_id := val.val_31;
               l_org_index := l_org_index + 1;
            END IF;
          END IF;
      END LOOP;

      -- Maintaining recordIds with record numbers in plsql table
       FOR rcd_dtls IN csr_ext_rcd_id_with_seq()
       LOOP
           IF rcd_dtls.hide_flag = 'N' THEN
              g_rcd_dtls(To_Number(rcd_dtls.rec_num)).ext_rcd_id := rcd_dtls.ext_rcd_id;
          END IF;
       END LOOP;

       l_org_count := g_ord_details.Count;

       --fetch the extract result id for the trailer records
       --these are ids for the records created automatically by
       --benefits, and they will be deleted in the end after we
       --create our own trailer records for each org based on these
       FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                        ,c_rcd_type_cd => 'T')-- T-Trailer
       LOOP
        OPEN csr_get_trailer_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                   ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
        FETCH csr_get_trailer_rslt INTO l_trailer_main_rec;
        CLOSE csr_get_trailer_rslt;
          IF g_rcd_dtls(999).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_999_rslt_dtl_id := l_trailer_main_rec.ext_rslt_dtl_id;
          END IF;
       END LOOP;

       --find the dtl record id for the header record
       --since records need to be sorted by employer number, the default
       --header record created by benefits needs to be deleted later
       FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                        ,c_rcd_type_cd => 'H')-- H-Header
       LOOP

       OPEN csr_get_header_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id
                               );
       FETCH csr_get_header_rslt INTO l_header_main_rec;
       CLOSE csr_get_header_rslt;
          IF g_rcd_dtls(000).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
             l_000_rslt_dtl_id := l_header_main_rec.ext_rslt_dtl_id;
          END IF;
       END LOOP;


     -- loop through all orgids
     FOR num IN 1..l_org_count
     LOOP
       -- Check wether employee exists in hierarchy or not
       OPEN csr_get_person_exist(g_ord_details(num).gre_org_id);
       FETCH csr_get_person_exist INTO l_Person_Exists;
       IF csr_get_person_exist%FOUND THEN
         l_Person_Exists:='x';
	 exit;
       END IF;
       CLOSE csr_get_person_exist;
     END LOOP;

     IF l_Person_Exists = 'x' THEN
      --Loop through Header records
      FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                       ,c_rcd_type_cd => 'H')-- H-Header
      LOOP
         OPEN csr_get_header_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                 ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
         FETCH csr_get_header_rslt INTO l_header_main_rec;
         CLOSE csr_get_header_rslt;
         l_header_new_rec :=  l_header_main_rec;
         l_sort_val := Lpad(sort_val,15,0);
         l_header_new_rec.prmy_sort_val := l_sort_val;
         l_header_new_rec.object_version_NUMBER :=  Nvl(l_header_new_rec.object_version_NUMBER,0) + 1;
         sort_val :=sort_val+1;

           -- Insert the header record only once for each extract
           IF l_000_inserted = 0  THEN
            Ins_Rslt_Dtl(p_dtl_rec => l_header_new_rec);
              l_000_inserted := 1;
           END IF;

       END LOOP;--End of Header Loop
    END IF; -- l_person exists



-- loop through all orgids
     FOR num IN 1..l_org_count
     LOOP
      l_count := 0;
      Hr_Utility.set_location('Current Org Id:---------'||g_ord_details(num).gre_org_id, 5);
      IF num <= l_org_count THEN

       -- Get all records for orgid
        FOR val IN csr_get_rslt
                     (c_org_id         => g_ord_details(num).gre_org_id
                     ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id )
       LOOP
         -- Get the individual row using sortid key
         -- So we will get only one record related data per person
          FOR ind_dtl IN csr_rslt_dtl_sort
                        (c_val_32=> val.val_32
                         ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                        )
         LOOP
          l_main_rec :=  ind_dtl;
          l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
          l_new_rec := l_main_rec;
            l_sort_val:= Lpad(sort_val,15,0);
          l_new_rec.prmy_sort_val := l_sort_val;
          sort_val :=sort_val+1;
          Upd_Rslt_Dtl(p_dtl_rec => l_new_rec);
          l_emp_ext_chk := 1;
          END LOOP; --ind_dtl Loop
        END LOOP; -- csr_get_rslt Loop

      END IF; -- org count
   END LOOP; --End of org loop

    --Check wether trailor record has to be shown or not
    IF l_Person_Exists = 'x' THEN
      --Loop through trailer records
      FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                      ,c_rcd_type_cd => 'T')-- T-Trailer
      LOOP
          l_insert_trailer := 1;
          OPEN csr_get_trailer_rslt(c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                                   ,c_ext_dtl_rcd_id => csr_rcd_rec.ext_rcd_id);
          FETCH csr_get_trailer_rslt INTO l_trailer_main_rec;
          CLOSE csr_get_trailer_rslt;
          l_trailer_new_rec :=  l_trailer_main_rec;

          -- Start of trailer record 999
           IF g_rcd_dtls(999).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN

               l_total_data_rcd_count:=0;

            --Get the record count for 010
            l_010_count:=Get_Trailer_Record_Count(g_rcd_dtls(010).ext_rcd_id
                                        ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_04 := lpad(fnd_number.number_to_canonical(l_010_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_010_count;

            --Get the record count for 020
            l_020_count:=Get_Trailer_Record_Count(g_rcd_dtls(020).ext_rcd_id
                                        ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_05 := lpad(fnd_number.number_to_canonical(l_020_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_020_count;

            --Get the record count for 030
            l_030_count:=Get_Trailer_Record_Count(g_rcd_dtls(030).ext_rcd_id
                                         ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_06 := lpad(fnd_number.number_to_canonical(l_030_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_030_count;

            --Get the record count for 040
            l_040_count:=Get_Trailer_Record_Count(g_rcd_dtls(040).ext_rcd_id
                                       ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_07 := lpad(fnd_number.number_to_canonical(l_040_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_040_count;


            --Get the record count for 060
            l_060_count:=Get_Trailer_Record_Count(g_rcd_dtls(060).ext_rcd_id
                                   ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_09 := lpad(fnd_number.number_to_canonical(l_060_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_060_count;

            --Get the record count for 070
            l_070_count:=Get_Trailer_Record_Count(g_rcd_dtls(070).ext_rcd_id
                                    ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_10 := lpad(fnd_number.number_to_canonical(l_070_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_070_count;

            --Get the record count for 080
            l_080_count:=Get_Trailer_Record_Count(g_rcd_dtls(080).ext_rcd_id
                                    ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_11 := lpad(fnd_number.number_to_canonical(l_080_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_080_count;

            --Get the record count for 081
            l_081_count:=Get_Trailer_Record_Count(g_rcd_dtls(081).ext_rcd_id
                                    ,g_extract_params(p_business_group_id).org_id );
            l_trailer_new_rec.val_15 := lpad(fnd_number.number_to_canonical(l_081_count),6,'0');
            l_total_data_rcd_count:=l_total_data_rcd_count+l_081_count;

            --Set Total Data Record Count
            l_trailer_new_rec.val_03 := lpad(fnd_number.number_to_canonical(l_total_data_rcd_count),6,'0');

         END IF;
         --Set the primary sort value
          l_sort_val := Lpad(sort_val,15,0);
          l_trailer_new_rec.prmy_sort_val := l_sort_val;
          l_trailer_new_rec.object_version_NUMBER :=  Nvl(l_trailer_new_rec.object_version_NUMBER,0) + 1;
          sort_val :=sort_val+1;


          -- Inserting new Record 999 for this extract
          IF l_999_inserted = 0 THEN
             Ins_Rslt_Dtl(p_dtl_rec => l_trailer_new_rec);
             l_999_inserted := 1;
          END IF;

      END LOOP;  --  Trailor Records csr_rcd_rec

     END IF; -- l_person_exists check



--fetch the result id to delete the extract result
--trailer records created by benefits
FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                 ,c_rcd_type_cd => 'T')-- T-Trailer
LOOP
  IF g_rcd_dtls(999).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_999_rslt_dtl_id;
  END IF;

  DELETE
    FROM ben_ext_rslt_dtl dtl
  WHERE dtl.ext_rslt_id  = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id    = csr_rcd_rec.ext_rcd_id
    AND dtl.ext_rslt_dtl_id = l_ext_rslt_dtl_id
    AND business_group_id = p_business_group_id;

END LOOP;

--fetch the result id to delete the extract result
--Header records created by benefits
FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N'
                                 ,c_rcd_type_cd => 'H')-- H-Header
LOOP
  IF g_rcd_dtls(000).ext_rcd_id = csr_rcd_rec.ext_rcd_id THEN
     l_ext_rslt_dtl_id := l_000_rslt_dtl_id;
  END IF;

  DELETE
    FROM ben_ext_rslt_dtl dtl
  WHERE dtl.ext_rslt_id  = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id    = csr_rcd_rec.ext_rcd_id
    AND dtl.ext_rslt_dtl_id = l_ext_rslt_dtl_id
    AND business_group_id = p_business_group_id;

END LOOP;
--  Hr_Utility.trace_off;
  Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
  RETURN l_return_value;

EXCEPTION
  WHEN Others THEN
   Hr_Utility.set_location('..Exception when others raised..', 20);
   Hr_Utility.set_location('Leaving :'||l_proc_name, 25);
   RETURN -1;
END Sort_Post_Process;

END Pqp_Nl_PGGM_Pension_Extracts ;

/
