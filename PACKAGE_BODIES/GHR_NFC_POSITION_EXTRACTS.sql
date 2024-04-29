--------------------------------------------------------
--  DDL for Package Body GHR_NFC_POSITION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NFC_POSITION_EXTRACTS" AS
/* $Header: ghrnfcpext.pkb 120.17 2005/12/15 05:04:50 sumarimu noship $ */

-- =============================================================================
-- ~ Package body variables
-- =============================================================================
   g_debug      boolean;
   TYPE r_pos_extra_info IS RECORD
                               (information_type               VARCHAR2(40)
                               ,poei_information_category      VARCHAR2(40)
                               ,poei_information               VARCHAR2(40)
                               ,poei_value                     VARCHAR2(150)
                               ,last_update_date               DATE
                               ,creation_date                  DATE);

   TYPE t_pos_extra_info IS TABLE OF r_pos_extra_info INDEX BY BINARY_INTEGER;
   l_master_data_temp t_pqp_record_values;
   l_interdiscp_cd   VARCHAR2(1);

-- =============================================================================
-- Cursor to get the default values
-- =============================================================================

 CURSOR csr_get_default_values
               (c_position_id       IN Number
               ,c_effective_date    IN Date) IS
 SELECT pdf.segment3 NFC_Agency_Code,
        pdf.segment4 Personnel_Office_ID,
        pdf.segment7 Grade
   FROM hr_all_positions_f pos, per_position_definitions pdf
  WHERE pos.position_definition_id = pdf.position_definition_id
    AND pos.position_id = c_position_id
    AND c_effective_date between pos.effective_start_date and pos.effective_end_date;


-- =============================================================================
-- Cursor to check the master positions
-- =============================================================================
   CURSOR csr_master_position(cp_position_id       NUMBER
                             ,cp_effective_date    DATE
                             ,cp_business_group_id NUMBER ) IS
    SELECT 'X'
      FROM  hr_all_positions_f hap
     WHERE  hap.position_id =cp_position_id
       AND  cp_effective_date BETWEEN hap.effective_start_date
                              AND hap.effective_end_date
       AND  hap.business_group_id =cp_business_group_id
       AND  hap.information6 is null;

-- =============================================================================
-- Cursor to check the master positions
-- =============================================================================
   CURSOR csr_detail_position(cp_position_id       NUMBER
                             ,cp_effective_date    DATE
                             ,cp_business_group_id NUMBER ) IS
    SELECT 'X'
      FROM  hr_all_positions_f hap
     WHERE  hap.position_id =cp_position_id
       AND  cp_effective_date BETWEEN hap.effective_start_date
                              AND hap.effective_end_date
       AND  hap.business_group_id =cp_business_group_id
       AND  hap.information6 is not null;

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

-- =============================================================================
-- Cursor to check the master positions
-- =============================================================================
   CURSOR csr_org_req (c_ext_dfn_id IN NUMBER
                     ,c_ext_rslt_id IN NUMBER
                     ,c_business_group_id IN NUMBER) IS
    SELECT bba.request_id
      FROM ben_benefit_actions bba
     WHERE bba.pl_id = c_ext_rslt_id
       AND bba.pgm_id = c_ext_dfn_id
       AND bba.business_group_id = c_business_group_id;

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
-- Cursor to get the extract result dtl record for a person id
-- =============================================================================
CURSOR csr_rslt_dtl(c_position_id    IN NUMBER
                   ,c_ext_rslt_id    IN Number
                   ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.VAL_71      = c_position_id
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;

-- =============================================================================
-- Cursor to get the extract result dtl record for a rest dtl id
-- =============================================================================
CURSOR csr_err_rslt_dtl(c_position_id    IN NUMBER
                   ,c_ext_rslt_id    IN Number
                   ,c_ext_rslt_dtl_id IN Number ) IS
   SELECT *
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.VAL_71      = c_position_id
      AND dtl.ext_rslt_dtl_id  = c_ext_rslt_dtl_id;

-- =============================================================================
-- Cursor to get the extract position ids for result id
-- =============================================================================
CURSOR csr_rcd_position_ids
                   (c_ext_rslt_id    IN Number
                   ,c_ext_dtl_rcd_id IN Number ) IS
   SELECT dtl.val_71 --Position_id
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = c_ext_rslt_id
      AND dtl.VAL_45      = 'A'	    --Function Code
      AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id
      AND dtl.VAL_49 is not null; --Incumbent SSN

-- =============================================================================
-- Cursor to get the extract position ids for result id
-- =============================================================================
CURSOR csr_rslt_dtl_id
                   (c_ext_rslt_id    IN NUMBER
                   ,c_ext_hide_flag  IN VARCHAR2
		   ,c_rcd_type_cd    IN VARCHAR2
		   ,c_position_id    IN VARCHAR2
		   ,c_business_group_id IN NUMBER) IS

   SELECT rslt.ext_rslt_dtl_id
     FROM ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
         ,ben_ext_rslt_dtl rslt
    WHERE dfn.ext_dfn_id   = ben_ext_thread.g_ext_dfn_id
      AND rin.ext_file_id  = dfn.ext_file_id
      AND rin.hide_flag    = c_ext_hide_flag     -- Y=Hidden, N=Not Hidden
      AND rin.ext_rcd_id   = rcd.ext_rcd_id
      AND rslt.EXT_RCD_ID  = rcd.ext_rcd_id
      AND rcd.rcd_type_cd  = c_rcd_type_cd  --S- Sub Header D=Detail,H=Header,F=Footer
      and rslt.val_71 =c_position_id
      and rslt.ext_rslt_id =c_ext_rslt_id
      and rslt.business_group_id =c_business_group_id;

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
 l_get_period_num:=NULL;
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








-- =============================================================================
-- ~ NFC_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================

PROCEDURE NFC_Position_Extract_Process
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

     g_conc_request_id := fnd_global.conc_request_id;

     hr_utility.set_location('p_business_group_id: '||p_business_group_id, 80);
     hr_utility.set_location('g_conc_request_id: '||g_conc_request_id, 80);
     hr_utility.set_location('p_ext_dfn_id: '||p_ext_dfn_id, 80);
     hr_utility.set_location('p_date_criteria: '||p_date_criteria, 80);
     hr_utility.set_location('p_transmission_type: '||p_transmission_type, 80);
     hr_utility.set_location('p_from_date: '||p_from_date, 80);
     hr_utility.set_location('p_to_date: '||p_to_date, 80);
     --
     -- Call the actual benefit extract process with the effective date as the extract
     -- end date along with the ext def. id and business group id.
     --
     hr_utility.set_location('..Calling Benefit Ext Process'||l_proc_name, 6);
     IF p_transmission_type = 'FULL' THEN
        hr_utility.set_location('In side Full', 5);

        ben_ext_thread.process
         (errbuf                     => l_errbuff,
          retcode                    => l_retcode,
          p_benefit_action_id        => NULL,
          p_ext_dfn_id               => p_ext_dfn_id,
          p_effective_date           => p_to_date,
          p_business_group_id        => p_business_group_id);
      ELSE
        --This defined at position level based on GHR history table
        ben_ext_thread.process
         (errbuf                     => l_errbuff,
          retcode                    => l_retcode,
          p_benefit_action_id        => NULL,
          p_ext_dfn_id               => p_ext_dfn_id,
          p_effective_date           => p_to_date,
          p_business_group_id        => p_business_group_id,
     	  p_subhdr_chg_log           => 'Y',
        --p_subhdr_ghr_from_dt	     => Fnd_Date.canonical_to_date(p_from_date),
	--p_subhdr_ghr_to_dt	     => Fnd_Date.canonical_to_date(p_to_date)
	  p_eff_start_date	     => p_from_date,
	  p_eff_end_date	     => p_to_date);
      END IF;
     hr_utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
     WHEN Others THEN
     hr_utility.set_location('Leaving: '||l_proc_name, 90);
     RAISE;
END NFC_Position_Extract_Process;

-- =============================================================================
-- ~ NFC_JCL_Extract_Process: This is called by the conc. program as is a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================

PROCEDURE NFC_JCL_Extract_Process
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_extract_name                IN     VARCHAR2
	   ,p_effective_date              IN     VARCHAR2
           ,p_business_group_id           IN     NUMBER
	   ,p_user_id                     IN     VARCHAR2
           ,p_dept_code                   IN     VARCHAR2
           ,p_agency_code                 IN     VARCHAR2
           ,p_poi                         IN     VARCHAR2
           ,p_ext_rslt_id                 IN     NUMBER DEFAULT NULL ) IS

   CURSOR csr_ext_dfn_id( c_extract_name     in varchar2) IS
   SELECT pea.ext_dfn_id      ext_dfn_id
     FROM pqp_extract_attributes pea
    WHERE pea.ext_dfn_name  = c_extract_name;

   l_errbuff          VARCHAR2(3000);
   l_retcode          NUMBER;
   l_session_id       NUMBER;
   l_proc_name        VARCHAR2(150) := g_proc_name ||'NFC_JCL_Extract_Process';
   l_ext_dfn_id       NUMBER;
BEGIN
     hr_utility.set_location('Entering: '||l_proc_name, 5);
     g_conc_request_id := fnd_global.conc_request_id;
     g_business_group_id :=p_business_group_id;
     --
     -- Call the actual benefit extract process with the effective date as the extract
     -- end date along with the ext def. id and business group id.
     --
     OPEN  csr_ext_dfn_id( c_extract_name     => p_extract_name);
     FETCH csr_ext_dfn_id  INTO  l_ext_dfn_id;
     IF csr_ext_dfn_id%FOUND THEN
         ben_ext_thread.process
         (errbuf                     => l_errbuff,
          retcode                    => l_retcode,
          p_benefit_action_id        => NULL,
          p_ext_dfn_id               => l_ext_dfn_id,
          p_effective_date           => p_effective_date,
          p_business_group_id        => p_business_group_id);
     END IF;
     CLOSE csr_ext_dfn_id;
     hr_utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
     WHEN Others THEN
     hr_utility.set_location('Leaving: '||l_proc_name, 90);
     RAISE;
END NFC_JCL_Extract_Process;

-- =============================================================================
-- Copy_Rec_Values :
-- =============================================================================
PROCEDURE Copy_Rec_Values
          (p_rslt_rec   IN ben_ext_rslt_dtl%ROWTYPE
	  ,p_val_tab    IN OUT NOCOPY  ValTabTyp) IS

  l_proc_name    Varchar2(150) := g_proc_name ||'Copy_Rec_Values ';
BEGIN

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

   Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Copy_Rec_Values;

-- =============================================================================
-- ~Upd_Rslt_Dtl : Updates the primary assignment record in results detail table
-- =============================================================================
procedure Upd_Rslt_Dtl
           (p_dtl_rec     in ben_ext_rslt_dtl%rowtype
           ,p_val_tab     in ValTabTyp ) is

  l_proc_name varchar2(150):= g_proc_name||'upd_rslt_dtl';

begin -- Upd_Rslt_Dtl

  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

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
     ,object_version_number  = p_dtl_rec.object_version_number
     --,thrd_sort_val          = p_dtl_rec.thrd_sort_val
  where ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
  return;

exception
  when Others then
    Hr_Utility.set_location('Errorm Leaving: '||l_proc_name, 5);
  raise;
end Upd_Rslt_Dtl;

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
  /*,val_76
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
  ,val_150 */
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
  /*,p_val_tab(76)
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
  ,p_val_tab(150)*/
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
-- Create Position info table
-- =============================================================================
PROCEDURE Create_Poition_Extra_Info (p_posi_extra_info IN per_position_extra_info%rowtype
                                    ,p_pos_extra_info  OUT NOCOPY t_pos_extra_info) IS
BEGIN
  IF p_posi_extra_info.information_type IS NOT NULL then
     p_pos_extra_info(1).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(1).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(1).poei_information          :='POEI_INFORMATION1';
     p_pos_extra_info(1).poei_value                :=p_posi_extra_info.poei_information1;
     p_pos_extra_info(1).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(1).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(2).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(2).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(2).poei_information          :='POEI_INFORMATION2';
     p_pos_extra_info(2).poei_value                :=p_posi_extra_info.poei_information2;
     p_pos_extra_info(2).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(2).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(3).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(3).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(3).poei_information          :='POEI_INFORMATION3';
     p_pos_extra_info(3).poei_value                :=p_posi_extra_info.poei_information3;
     p_pos_extra_info(3).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(3).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(4).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(4).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(4).poei_information          :='POEI_INFORMATION4';
     p_pos_extra_info(4).poei_value                :=p_posi_extra_info.poei_information4;
     p_pos_extra_info(4).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(4).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(5).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(5).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(5).poei_information          :='POEI_INFORMATION5';
     p_pos_extra_info(5).poei_value                :=p_posi_extra_info.poei_information5;
     p_pos_extra_info(5).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(5).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(6).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(6).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(6).poei_information          :='POEI_INFORMATION6';
     p_pos_extra_info(6).poei_value                :=p_posi_extra_info.poei_information6;
     p_pos_extra_info(6).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(6).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(7).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(7).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(7).poei_information          :='POEI_INFORMATION7';
     p_pos_extra_info(7).poei_value                :=p_posi_extra_info.poei_information7;
     p_pos_extra_info(7).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(7).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(8).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(8).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(8).poei_information          :='POEI_INFORMATION8';
     p_pos_extra_info(8).poei_value                :=p_posi_extra_info.poei_information8;
     p_pos_extra_info(8).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(8).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(9).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(9).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(9).poei_information          :='POEI_INFORMATION9';
     p_pos_extra_info(9).poei_value                :=p_posi_extra_info.poei_information9;
     p_pos_extra_info(9).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(9).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(10).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(10).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(10).poei_information          :='POEI_INFORMATION10';
     p_pos_extra_info(10).poei_value                :=p_posi_extra_info.poei_information10;
     p_pos_extra_info(10).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(10).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(11).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(11).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(11).poei_information          :='POEI_INFORMATION11';
     p_pos_extra_info(11).poei_value                :=p_posi_extra_info.poei_information11;
     p_pos_extra_info(11).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(11).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(12).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(12).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(12).poei_information          :='POEI_INFORMATION12';
     p_pos_extra_info(12).poei_value                :=p_posi_extra_info.poei_information12;
     p_pos_extra_info(12).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(12).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(13).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(13).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(13).poei_information          :='POEI_INFORMATION13';
     p_pos_extra_info(13).poei_value                :=p_posi_extra_info.poei_information13;
     p_pos_extra_info(13).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(13).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(14).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(14).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(14).poei_information          :='POEI_INFORMATION14';
     p_pos_extra_info(14).poei_value                :=p_posi_extra_info.poei_information14;
     p_pos_extra_info(14).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(14).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(15).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(15).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(15).poei_information          :='POEI_INFORMATION15';
     p_pos_extra_info(15).poei_value                :=p_posi_extra_info.poei_information15;
     p_pos_extra_info(15).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(15).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(16).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(16).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(16).poei_information          :='POEI_INFORMATION16';
     p_pos_extra_info(16).poei_value                :=p_posi_extra_info.poei_information16;
     p_pos_extra_info(16).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(16).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(17).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(17).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(17).poei_information          :='POEI_INFORMATION17';
     p_pos_extra_info(17).poei_value                :=p_posi_extra_info.poei_information17;
     p_pos_extra_info(17).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(17).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(18).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(18).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(18).poei_information          :='POEI_INFORMATION18';
     p_pos_extra_info(18).poei_value                :=p_posi_extra_info.poei_information18;
     p_pos_extra_info(18).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(18).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(19).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(19).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(19).poei_information          :='POEI_INFORMATION19';
     p_pos_extra_info(19).poei_value                :=p_posi_extra_info.poei_information19;
     p_pos_extra_info(19).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(19).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(20).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(20).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(20).poei_information          :='POEI_INFORMATION20';
     p_pos_extra_info(20).poei_value                :=p_posi_extra_info.poei_information20;
     p_pos_extra_info(20).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(20).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(21).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(21).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(21).poei_information          :='POEI_INFORMATION21';
     p_pos_extra_info(21).poei_value                :=p_posi_extra_info.poei_information21;
     p_pos_extra_info(21).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(21).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(22).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(22).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(22).poei_information          :='POEI_INFORMATION22';
     p_pos_extra_info(22).poei_value                :=p_posi_extra_info.poei_information22;
     p_pos_extra_info(22).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(22).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(23).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(23).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(23).poei_information          :='POEI_INFORMATION23';
     p_pos_extra_info(23).poei_value                :=p_posi_extra_info.poei_information23;
     p_pos_extra_info(23).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(23).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(24).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(24).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(24).poei_information          :='POEI_INFORMATION24';
     p_pos_extra_info(24).poei_value                :=p_posi_extra_info.poei_information24;
     p_pos_extra_info(24).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(24).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(25).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(25).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(25).poei_information          :='POEI_INFORMATION25';
     p_pos_extra_info(25).poei_value                :=p_posi_extra_info.poei_information25;
     p_pos_extra_info(25).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(25).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(26).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(26).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(26).poei_information          :='POEI_INFORMATION26';
     p_pos_extra_info(26).poei_value                :=p_posi_extra_info.poei_information26;
     p_pos_extra_info(26).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(26).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(27).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(27).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(27).poei_information          :='POEI_INFORMATION27';
     p_pos_extra_info(27).poei_value                :=p_posi_extra_info.poei_information27;
     p_pos_extra_info(27).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(27).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(28).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(28).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(28).poei_information          :='POEI_INFORMATION28';
     p_pos_extra_info(28).poei_value                :=p_posi_extra_info.poei_information28;
     p_pos_extra_info(28).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(28).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(29).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(29).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(29).poei_information          :='POEI_INFORMATION29';
     p_pos_extra_info(29).poei_value                :=p_posi_extra_info.poei_information29;
     p_pos_extra_info(29).poei_information          :=p_posi_extra_info.poei_information1;
     p_pos_extra_info(29).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(29).creation_date             :=p_posi_extra_info.creation_date;

     p_pos_extra_info(30).information_type          :=p_posi_extra_info.information_type;
     p_pos_extra_info(30).poei_information_category :=p_posi_extra_info.poei_information_category;
     p_pos_extra_info(30).poei_information          :='POEI_INFORMATION30';
     p_pos_extra_info(30).poei_value                :=p_posi_extra_info.poei_information30;
     p_pos_extra_info(30).last_update_date          :=p_posi_extra_info.last_update_date;
     p_pos_extra_info(30).creation_date             :=p_posi_extra_info.creation_date;
END IF;
END Create_Poition_Extra_Info;
-- =============================================================================
-- Build_Metadata_Values
-- =============================================================================
PROCEDURE Build_Metadata_Values	IS
   l_proc_name  constant  varchar2(150) := g_proc_name ||'Build_Metadata_Values';
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  IF g_position_kff.count = 0 THEN
     ---define data from Position kff
     g_position_kff(1).context_name       :='US Federal Position';
     g_position_kff(1).segment_name       :='Agency/Subelement Code';
     g_position_kff(1).db_column_name     :='SEGMENT4';
     g_position_kff(1).rep_attribute_name :='Department Code';
     g_position_kff(1).record_indicator   :='B';
     g_position_kff(1).sequence :=3;

     g_position_kff(2).context_name       :='US Federal Position';
     g_position_kff(2).segment_name       :='Sequence Number';
     g_position_kff(2).db_column_name     :='SEGMENT3';
     g_position_kff(2).rep_attribute_name :='Master Record Number';
     g_position_kff(2).record_indicator   :='B';
     g_position_kff(2).sequence           :=6;

     g_position_kff(3).context_name       :='US Federal Position';
     g_position_kff(3).segment_name       :='Position Title';
     g_position_kff(3).db_column_name     :='SEGMENT1';
     g_position_kff(3).rep_attribute_name :='Position Official Title';
     g_position_kff(3).record_indicator   :='M';
     g_position_kff(3).sequence           :=14;

     g_position_kff(4).context_name       :='US Federal Position';
     g_position_kff(4).segment_name       :='Sequence Number';
     g_position_kff(4).db_column_name     :='SEGMENT3';
     g_position_kff(4).rep_attribute_name :='Position Number';
     g_position_kff(4).record_indicator   :='I';
     g_position_kff(4).sequence           :=8;
  END IF;

  ---define data from grade KFF
  IF g_grade_kff.count = 0 THEN
     g_grade_kff(1).context_name       :='US_FEDERAL_GRADE';
     g_grade_kff(1).segment_name       :='Grade or Level';
     g_grade_kff(1).db_column_name     :='SEGMENT2';
     g_grade_kff(1).rep_attribute_name :='Grade';
     g_grade_kff(1).record_indicator   :='B';
     g_grade_kff(1).sequence           :=7;

     g_grade_kff(2).context_name       :='US_FEDERAL_GRADE';
     g_grade_kff(2).segment_name       :='Pay Plan';
     g_grade_kff(2).db_column_name     :='SEGMENT1';
     g_grade_kff(2).rep_attribute_name :='Pay Plan';
     g_grade_kff(2).record_indicator   :='M';
     g_grade_kff(2).sequence           :=8;
  END IF;

  ---Define data from job KFF
  IF g_job_kff.count = 0 THEN
     g_job_kff(1).context_name       :='US_FEDERAL_JOB';
     g_job_kff(1).segment_name       :='Occupational Series';
     g_job_kff(1).db_column_name     :='SEGMENT1';
     g_job_kff(1).rep_attribute_name :='Occupational Series Code';
     g_job_kff(1).record_indicator   :='M';
     g_job_kff(1).sequence           :=9;
  END IF;
  ---define data from Position Position Extra information
  IF g_per_position_extra_info.count = 0 THEN

     g_per_position_extra_info(1).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(1).segment_name       :='Personnel Office ID';
     g_per_position_extra_info(1).db_column_name     :='POEI_INFORMATION3';
     g_per_position_extra_info(1).rep_attribute_name :='Personnel Office Identifier';
     g_per_position_extra_info(1).record_indicator   :='B';
     g_per_position_extra_info(1).sequence           :=5;

     g_per_position_extra_info(2).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(2).segment_name       :='Functional Class';
     g_per_position_extra_info(2).db_column_name     :='POEI_INFORMATION11';
     g_per_position_extra_info(2).rep_attribute_name :='Occupation Function Code';
     g_per_position_extra_info(2).record_indicator   :='M';
     g_per_position_extra_info(2).sequence           :=10;

     g_per_position_extra_info(3).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(3).segment_name       :='Official Title Suffix';
     g_per_position_extra_info(3).db_column_name     :='POEI_INFORMATION4';
     g_per_position_extra_info(3).rep_attribute_name :='Official Title Suffix';
     g_per_position_extra_info(3).record_indicator   :='M';
     g_per_position_extra_info(3).sequence           :=11;

     g_per_position_extra_info(4).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(4).segment_name       :='Official Title Prefix';
     g_per_position_extra_info(4).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(4).rep_attribute_name :='Official Title Prefix';
     g_per_position_extra_info(4).record_indicator   :='M';
     g_per_position_extra_info(4).sequence           :=12;

     g_per_position_extra_info(5).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(5).segment_name       :='Official Title Code';
     g_per_position_extra_info(5).db_column_name     :='POEI_INFORMATION6';
     g_per_position_extra_info(5).rep_attribute_name :='Official Title Code';
     g_per_position_extra_info(5).record_indicator   :='M';
     g_per_position_extra_info(5).sequence           :=13;

     g_per_position_extra_info(6).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(6).segment_name       :='Headquarters Field Code';
     g_per_position_extra_info(6).db_column_name     :='POEI_INFORMATION7';
     g_per_position_extra_info(6).rep_attribute_name :='Headquarters Field Code';
     g_per_position_extra_info(6).record_indicator   :='M';
     g_per_position_extra_info(6).sequence           :=15;

     g_per_position_extra_info(7).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(7).segment_name       :='Supervisory Status';
     g_per_position_extra_info(7).db_column_name     :='POEI_INFORMATION16';
     g_per_position_extra_info(7).rep_attribute_name :='Position Supervisory Code';
     g_per_position_extra_info(7).record_indicator   :='M';
     g_per_position_extra_info(7).sequence           :=16;

     g_per_position_extra_info(8).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(8).segment_name       :='Date Position Classified';
     g_per_position_extra_info(8).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(8).rep_attribute_name :='Date Position Classified';
     g_per_position_extra_info(8).record_indicator   :='M';
     g_per_position_extra_info(8).rule               :='Y';
     g_per_position_extra_info(8).sequence           :=17;

     g_per_position_extra_info(9).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(9).segment_name       :='Classification Standard Code';
     g_per_position_extra_info(9).db_column_name     :='POEI_INFORMATION8';
     g_per_position_extra_info(9).rep_attribute_name :='Classification Standard Code';
     g_per_position_extra_info(9).record_indicator   :='M';
     g_per_position_extra_info(9).sequence           :=18;

     g_per_position_extra_info(10).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(10).segment_name       :='Occupation Category Code';
     g_per_position_extra_info(10).db_column_name     :='POEI_INFORMATION6';
     g_per_position_extra_info(10).rep_attribute_name :='PATCO Code';
     g_per_position_extra_info(10).record_indicator   :='M';
     g_per_position_extra_info(10).sequence           :=19;

     g_per_position_extra_info(11).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(11).segment_name       :='Early Retirement Indicator';
     g_per_position_extra_info(11).db_column_name     :='POEI_INFORMATION17';
     g_per_position_extra_info(11).rep_attribute_name :='Early Retirement Indicator';
     g_per_position_extra_info(11).record_indicator   :='M';
     g_per_position_extra_info(11).sequence           :=20;

     g_per_position_extra_info(12).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(12).segment_name       :='FLSA Category';
     g_per_position_extra_info(12).db_column_name     :='POEI_INFORMATION7';
     g_per_position_extra_info(12).rep_attribute_name :='Fair Labor Standards Code';
     g_per_position_extra_info(12).record_indicator   :='I';
     g_per_position_extra_info(12).sequence           :=9;

     g_per_position_extra_info(13).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(13).segment_name       :='Financial Statement';
     g_per_position_extra_info(13).db_column_name     :='POEI_INFORMATION10';
     g_per_position_extra_info(13).rep_attribute_name :='Financial Disclosure Required Code';
     g_per_position_extra_info(13).record_indicator   :='I';
     g_per_position_extra_info(13).rule               :='Y';
     g_per_position_extra_info(13).sequence           :=10;

     g_per_position_extra_info(14).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(14).segment_name       :='Position Schedule';
     g_per_position_extra_info(14).db_column_name     :='POEI_INFORMATION11';
     g_per_position_extra_info(14).rep_attribute_name :='Position Schedule';
     g_per_position_extra_info(14).record_indicator   :='I';
     g_per_position_extra_info(14).sequence           :=11;

     g_per_position_extra_info(15).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(15).segment_name       :='Position Sensitivity';
     g_per_position_extra_info(15).db_column_name     :='POEI_INFORMATION13';
     g_per_position_extra_info(15).rep_attribute_name :='Position Sensitivity Code';
     g_per_position_extra_info(15).record_indicator   :='I';
     g_per_position_extra_info(15).rule               :='Y';
     g_per_position_extra_info(15).sequence           :=12;

     g_per_position_extra_info(16).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(16).segment_name       :='Computer Position Indicator';
     g_per_position_extra_info(16).db_column_name     :='POEI_INFORMATION18';
     --This is a concatination for Position Sensitivity Code
     g_per_position_extra_info(16).rep_attribute_name :='Position Sensitivity Cd';
     g_per_position_extra_info(16).record_indicator   :='I';
     g_per_position_extra_info(16).rule               :='Y';
     g_per_position_extra_info(16).sequence           :=13;

     g_per_position_extra_info(17).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(17).segment_name       :='Procurement Integrity Act';
     g_per_position_extra_info(17).db_column_name     :='POEI_INFORMATION13';
     g_per_position_extra_info(17).rep_attribute_name :='Procurement Integrity Act Flag';
     --g_per_position_extra_info(17).rule               :='Y';
     g_per_position_extra_info(17).record_indicator   :='I';
     g_per_position_extra_info(17).sequence           :=14;

     g_per_position_extra_info(18).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(18).segment_name       :='LEO Position Indicator';
     g_per_position_extra_info(18).db_column_name     :='POEI_INFORMATION16';
     g_per_position_extra_info(18).rep_attribute_name :='LEO (Law Enforcement Officer) Indicator';
     g_per_position_extra_info(18).record_indicator   :='I';
     g_per_position_extra_info(18).rule               :='Y';
     g_per_position_extra_info(18).sequence           :=15;

     g_per_position_extra_info(19).context_name       :='GHR_US_POS_VALID_GRADE';
     g_per_position_extra_info(19).segment_name       :='Pay Table ID';
     g_per_position_extra_info(19).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(19).rep_attribute_name :='Pay Table Code';
     g_per_position_extra_info(19).record_indicator   :='I';
     g_per_position_extra_info(19).rule               := 'Y';
     g_per_position_extra_info(19).sequence           :=16;

     g_per_position_extra_info(20).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(20).segment_name       :='Competitive Level';
     g_per_position_extra_info(20).db_column_name     :='POEI_INFORMATION9';
     g_per_position_extra_info(20).rep_attribute_name :='Competitive Level Code';
     g_per_position_extra_info(20).record_indicator   :='I';
     g_per_position_extra_info(20).sequence           :=17;

     g_per_position_extra_info(21).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(21).segment_name       :='Working Title Code';
     g_per_position_extra_info(21).db_column_name     :='POEI_INFORMATION3';
     g_per_position_extra_info(21).rep_attribute_name :='Working Title Code';
     g_per_position_extra_info(21).record_indicator   :='I';
     g_per_position_extra_info(21).sequence           :=18;

     g_per_position_extra_info(22).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(22).segment_name       :='Position Working Title';
     g_per_position_extra_info(22).db_column_name     :='POEI_INFORMATION12';
     g_per_position_extra_info(22).rep_attribute_name :='Position Working Title';
     g_per_position_extra_info(22).record_indicator   :='I';
     g_per_position_extra_info(22).rule               :='Y';
     g_per_position_extra_info(22).sequence           :=19;

     g_per_position_extra_info(23).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(23).segment_name       :='OPM Organizational Component';
     g_per_position_extra_info(23).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(23).rep_attribute_name :='Organizational Structure Code';
     g_per_position_extra_info(23).record_indicator   :='I';
     g_per_position_extra_info(23).sequence           :=20;

     g_per_position_extra_info(24).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(24).segment_name       :='OPM Organizational Component';
     g_per_position_extra_info(24).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(24).rep_attribute_name :='Organizational Structure Code Agency';
     g_per_position_extra_info(24).record_indicator   :='I';
     g_per_position_extra_info(24).rule				  :='Y';
     g_per_position_extra_info(24).sequence           :=21;

     g_per_position_extra_info(25).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(25).segment_name       :='Vacancy Review Code';
     g_per_position_extra_info(25).db_column_name     :='POEI_INFORMATION10';
     g_per_position_extra_info(25).rep_attribute_name :='Vacancy Review Code';
     g_per_position_extra_info(25).record_indicator   :='I';
     g_per_position_extra_info(25).sequence           :=22;

     g_per_position_extra_info(26).context_name       :='GHR_US_POS_VALID_GRADE';
     g_per_position_extra_info(26).segment_name       :='Target Grade';
     g_per_position_extra_info(26).db_column_name     :='POEI_INFORMATION4';
     g_per_position_extra_info(26).rep_attribute_name :='Position Target Grade';
     g_per_position_extra_info(26).record_indicator   :='I';
     g_per_position_extra_info(26).rule               :='Y';
     g_per_position_extra_info(26).sequence           :=23;

     g_per_position_extra_info(27).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(27).segment_name       :='Date Last Position Audit';
     g_per_position_extra_info(27).db_column_name     :='POEI_INFORMATION6';
     g_per_position_extra_info(27).rep_attribute_name :='Date Position Last Audited/Reviewed';
     g_per_position_extra_info(27).record_indicator   :='I';
     g_per_position_extra_info(27).rule               :='Y';
     g_per_position_extra_info(27).sequence           :=27;

     g_per_position_extra_info(28).context_name       :='GHR_US_POS_GRP1';
     g_per_position_extra_info(28).segment_name       :='Bargaining Unit Status';
     g_per_position_extra_info(28).db_column_name     :='POEI_INFORMATION8';
     g_per_position_extra_info(28).rep_attribute_name :='Bargaining Unit Status';
     g_per_position_extra_info(28).record_indicator   :='I';
     g_per_position_extra_info(28).sequence           :=28;

     g_per_position_extra_info(29).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(29).segment_name       :='Grade Basis Indicator';
     g_per_position_extra_info(29).db_column_name     :='POEI_INFORMATION12';
     g_per_position_extra_info(29).rep_attribute_name :='Grade Basis Indicator';
     g_per_position_extra_info(29).record_indicator   :='I';
     g_per_position_extra_info(29).sequence           :=30;

     g_per_position_extra_info(30).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(30).segment_name       :='Language Required';
     g_per_position_extra_info(30).db_column_name     :='POEI_INFORMATION8';
     g_per_position_extra_info(30).rep_attribute_name :='Language Required';
     g_per_position_extra_info(30).record_indicator   :='I';
     g_per_position_extra_info(30).sequence           :=31;

     g_per_position_extra_info(31).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(31).segment_name       :='Presidential Appointment Indicator';
     g_per_position_extra_info(31).db_column_name     :='POEI_INFORMATION14';
     g_per_position_extra_info(31).rep_attribute_name :='Presidential Appointment Indicator';
     g_per_position_extra_info(31).record_indicator   :='I';
     g_per_position_extra_info(31).sequence           :=33;

     g_per_position_extra_info(32).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(32).segment_name       :='Projected Duties Indicator';
     g_per_position_extra_info(32).db_column_name     :='POEI_INFORMATION9';
     g_per_position_extra_info(32).rep_attribute_name :='Projected Duties Indicator';
     g_per_position_extra_info(32).record_indicator   :='I';
     g_per_position_extra_info(32).sequence           :=34;

     g_per_position_extra_info(33).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(33).segment_name       :='Date Classification Request Received';
     g_per_position_extra_info(33).db_column_name     :='POEI_INFORMATION18';
     g_per_position_extra_info(33).rep_attribute_name :='Date Request Received';
     g_per_position_extra_info(33).record_indicator   :='I';
     g_per_position_extra_info(33).rule               :='Y';
     g_per_position_extra_info(33).sequence           :=35;

     g_per_position_extra_info(34).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(34).segment_name       :='Maintenance Review Code';
     g_per_position_extra_info(34).db_column_name     :='POEI_INFORMATION19';
     g_per_position_extra_info(34).rep_attribute_name :='Maintenance Review Class Code';
     g_per_position_extra_info(34).record_indicator   :='I';
     g_per_position_extra_info(34).rule               :='Y';
     g_per_position_extra_info(34).sequence           :=38;

     g_per_position_extra_info(35).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(35).segment_name       :='Classification Official';
     g_per_position_extra_info(35).db_column_name     :='POEI_INFORMATION20';
     g_per_position_extra_info(35).rep_attribute_name :='Maintenance Review Class Code';
     g_per_position_extra_info(35).record_indicator   :='I';
     g_per_position_extra_info(35).sequence           :=39;

     g_per_position_extra_info(36).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(36).segment_name       :='Accounting Station';
     g_per_position_extra_info(36).db_column_name     :='POEI_INFORMATION15';
     g_per_position_extra_info(36).rep_attribute_name :='Accounting Station Code';
     g_per_position_extra_info(36).record_indicator   :='I';
     g_per_position_extra_info(36).sequence           :=42;

     g_per_position_extra_info(37).context_name       :='GHR_US_POS_GRP2';
     g_per_position_extra_info(37).segment_name       :='Drug Test';
     g_per_position_extra_info(37).db_column_name     :='POEI_INFORMATION9';
     g_per_position_extra_info(37).rep_attribute_name :='Drug Testing';
     g_per_position_extra_info(37).record_indicator   :='I';
     g_per_position_extra_info(37).rule               :='Y';
     g_per_position_extra_info(37).sequence           :=45;

     g_per_position_extra_info(38).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(38).segment_name       :='Customs Officer Pay Reform';
     g_per_position_extra_info(38).db_column_name     :='POEI_INFORMATION16';
     g_per_position_extra_info(38).rep_attribute_name :='COPR (Customs Officer Pay Reform) Status';
     g_per_position_extra_info(38).record_indicator   :='I';
     g_per_position_extra_info(38).sequence           :=48;

     g_per_position_extra_info(39).context_name       :='GHR_US_POS_OBLIG';
     g_per_position_extra_info(39).segment_name       :='Obligated Employee SSN';
     g_per_position_extra_info(39).db_column_name     :='POEI_INFORMATION5';
     g_per_position_extra_info(39).rep_attribute_name :='Obligated SSN';
     g_per_position_extra_info(39).record_indicator   :='I';
     g_per_position_extra_info(39).sequence           :=51;

     g_per_position_extra_info(40).context_name       :='GHR_US_POS_GRP3';
     g_per_position_extra_info(40).segment_name       :='NFC Agency Code';
     g_per_position_extra_info(40).db_column_name     :='POEI_INFORMATION21';
     g_per_position_extra_info(40).rep_attribute_name :='Agency Code';
     g_per_position_extra_info(40).record_indicator   :='B';
     g_per_position_extra_info(40).sequence           :=4;

     g_per_position_extra_info(41).context_name       :='GHR_US_POS_VALID_GRADE';
     g_per_position_extra_info(41).segment_name       :='Professional Category';
     g_per_position_extra_info(41).db_column_name     :='POEI_INFORMATION8';
     g_per_position_extra_info(41).rep_attribute_name :='Professional Category';
     g_per_position_extra_info(41).record_indicator   :='M';
     g_per_position_extra_info(41).sequence           :=68;
 END IF;

 ---Define data from Per Positions
 IF g_per_positions.count=0 THEN
    g_per_positions(1).context_name       :='PER_POSITIONS';
    g_per_positions(1).segment_name       :='Master Active-Inactive';
    g_per_positions(1).db_column_name     :='Master Active-Inactive';
    g_per_positions(1).rep_attribute_name :='Master Active-Inactive';
    g_per_positions(1).record_indicator   :='M';
    g_per_positions(1).sequence           :=21;

    g_per_positions(2).context_name       :='PER_POSITIONS';
    g_per_positions(2).segment_name       :='End Date';
    g_per_positions(2).db_column_name     :='end_date';
    g_per_positions(2).rep_attribute_name :='Date Abolished';
    g_per_positions(2).rule               :='Y';
    g_per_positions(2).record_indicator   :='M';
    g_per_positions(2).sequence           :=22;

    g_per_positions(3).context_name       :='PER_POSITIONS';
    g_per_positions(3).segment_name       :='Date Inactivated-Reactivated';
    g_per_positions(3).db_column_name     :='Date Inactivated-Reactivated';
    g_per_positions(3).rep_attribute_name :='Date Inactivated-Reactivated';
    g_per_positions(3).rule               :='Y';
    g_per_positions(3).record_indicator   :='M';
    g_per_positions(3).sequence           :=23;

    g_per_positions(4).context_name       :='PER_POSITIONS';
    g_per_positions(4).segment_name       :='Function Code';
    g_per_positions(4).db_column_name     :='Function Code';
    g_per_positions(4).rep_attribute_name :='Function Code';
    g_per_positions(4).record_indicator   :='M';
    g_per_positions(4).sequence           :=26;

    g_per_positions(5).context_name       :='PER_POSITIONS';
    g_per_positions(5).segment_name       :='Position Status Budget';
    g_per_positions(5).db_column_name     :='PERMANENT_TEMPORARY_FLAG';
    g_per_positions(5).rep_attribute_name :='Position Status Budget';
    g_per_positions(5).record_indicator   :='I';
    g_per_positions(5).sequence           :=29;

    g_per_positions(6).context_name       :='PER_POSITIONS';
    g_per_positions(6).segment_name       :='Date Position NTE';
    g_per_positions(6).db_column_name     :='EFFECTIVE_END_DATE';
    g_per_positions(6).rep_attribute_name :='Date Position NTE';
    --g_per_positions(6).rule               :='Y';
    g_per_positions(6).record_indicator   :='I';
    g_per_positions(6).sequence           :=32;

    g_per_positions(7).context_name       :='PER_POSITIONS';
    g_per_positions(7).segment_name       :='Position Active/Inactive';
    g_per_positions(7).db_column_name     :='Position Active/Inactive';
    g_per_positions(7).rep_attribute_name :='Position Active/Inactive';
    g_per_positions(7).record_indicator   :='I';
    g_per_positions(7).sequence           :=36;

    g_per_positions(8).context_name       :='PER_POSITIONS';
    g_per_positions(8).segment_name       :='Date Position Established';
    g_per_positions(8).db_column_name     :='EFFECTIVE_START_DATE';
    g_per_positions(8).rep_attribute_name :='Date Position Established';
    g_per_positions(8).record_indicator   :='I';
    g_per_positions(8).rule               :='Y';
    g_per_positions(8).sequence           :=37;

    g_per_positions(9).context_name       :='PER_POSITIONS';
    g_per_positions(9).segment_name       :='Date Position Inactivated/ Reactivated';
    g_per_positions(9).db_column_name     :='Date Position Inactivated/ Reactivated';
    g_per_positions(9).rep_attribute_name :='Date Position Inactivated/ Reactivated';
    g_per_positions(9).rule               :='Y';
    g_per_positions(9).record_indicator   :='I';
    g_per_positions(9).sequence           :=40;

    g_per_positions(10).context_name       :='PER_POSITIONS';
    g_per_positions(10).segment_name       :='End Date';
    g_per_positions(10).db_column_name     :='END_DATE';
    g_per_positions(10).rep_attribute_name :='Date Abolished';
    g_per_positions(10).rule               :='Y';
    g_per_positions(10).record_indicator   :='I';
    g_per_positions(10).sequence           :=41;

    g_per_positions(11).context_name       :='PER_POSITIONS';
    g_per_positions(11).segment_name       :='Function Code';
    g_per_positions(11).db_column_name     :='Function Code';
    g_per_positions(11).rep_attribute_name :='Function Code';
    g_per_positions(11).record_indicator   :='I';
    g_per_positions(11).sequence           :=46;

    g_per_positions(12).context_name       :='PER_POSITIONS';
    g_per_positions(12).segment_name       :='User Id';
    g_per_positions(12).db_column_name     :='User Id';
    g_per_positions(12).rep_attribute_name :='User Id';
    g_per_positions(12).record_indicator   :='I';
    g_per_positions(12).rule               :='Y';
    g_per_positions(12).sequence           :=47;

    g_per_positions(13).context_name       :='PER_POSITIONS';
    g_per_positions(13).segment_name       :='Duty Station State Code';
    g_per_positions(13).db_column_name     :='Duty Station State Code';
    g_per_positions(13).rep_attribute_name :='Duty Station State Code';
    g_per_positions(13).record_indicator   :='I';
    g_per_positions(13).sequence           :=24;

    g_per_positions(14).context_name       :='PER_POSITIONS';
    g_per_positions(14).segment_name       :='Duty Station City Code';
    g_per_positions(14).db_column_name     :='Duty Station City Code';
    g_per_positions(14).rep_attribute_name :='Duty Station City Code';
    g_per_positions(14).record_indicator   :='I';
    g_per_positions(14).sequence           :=25;

    g_per_positions(15).context_name       :='PER_POSITIONS';
    g_per_positions(15).segment_name       :='Duty Station County Code';
    g_per_positions(15).db_column_name     :='Duty Station County Code';
    g_per_positions(15).rep_attribute_name :='Duty Station County Code';
    g_per_positions(15).record_indicator   :='I';
    g_per_positions(15).sequence           :=26;

    g_per_positions(16).context_name       :='PER_POSITIONS';
    g_per_positions(16).segment_name       :='Interdisciplinary Code';
    g_per_positions(16).db_column_name     :='Interdisciplinary Code';
    g_per_positions(16).rep_attribute_name :='Interdisciplinary Code';
    g_per_positions(16).record_indicator   :='M';
    --g_per_positions(16).rule               :='Y';
    g_per_positions(16).sequence           :=24;

    g_per_positions(17).context_name       :='PER_POSITIONS';
    g_per_positions(17).segment_name       :='User-Identification';
    g_per_positions(17).db_column_name     :='User-Identification';
    g_per_positions(17).rep_attribute_name :='User-Identification';
    g_per_positions(17).record_indicator   :='M';
    g_per_positions(17).rule               :='Y';
    g_per_positions(17).sequence           :=27;
 END IF;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
END  Build_Metadata_Values;

-- =============================================================================
-- Get_Other_Gen_Val
-- =============================================================================
PROCEDURE Get_Other_Gen_Val(p_position_id          IN NUMBER
                           ,p_business_group_id    IN VARCHAR2
                           ,p_effective_start_date IN DATE
                           ,p_effective_end_date   IN DATE
                           ,p_record_indicator     IN VARCHAR2) IS

  CURSOR  c_get_position (cp_eff_date DATE) IS
   SELECT hap.effective_start_date
         ,hap.effective_end_date
         ,permanent_temporary_flag
         ,HR_GENERAL.DECODE_AVAILABILITY_STATUS(hap.availability_status_id) status
         ,hap.location_id
     FROM hr_all_positions_f hap
    WHERE cp_eff_date BETWEEN hap.effective_start_date
                      AND hap.effective_end_date
      AND hap.position_id=p_position_id
      AND hap.business_group_id = p_business_group_id;

--This cursor is used to find the function code
--the records are fetched based on end date in the
--parameter. This is done to determine the function code
--if creation date falls between the start date and end date.

--Example
--Create Position on 01-JUL-2005 and make correction on 02-JUL-2005
--when the from and to date is 01-JUL-2005 the function code is 'A'
--when the from and to date is 02-JUL-2005 then the function code is 'C'
--when the from date is 01-JUL-2005 and To date is 02-JUL-2005 the the
--function code is 'A' as the creation date is between these two dates.
--If the position is created on the physical date of 20-JUL-2005 and
--position start date is 01-JUL-2005.On from date of 20-JUL-2005 this position
--function code is 'A'
  CURSOR  c_get_position_rec (p_eff_dt DATE) IS
   SELECT hap.effective_start_date st_date
         ,hap.effective_end_date   e_date
         ,hap.creation_date
         ,HR_GENERAL.DECODE_AVAILABILITY_STATUS(hap.availability_status_id) status
     FROM hr_all_positions_f hap
    WHERE hap.position_id=p_position_id
      AND hap.business_group_id = p_business_group_id
      AND hap.effective_start_date <= p_eff_dt
    ORDER BY hap.effective_start_date asc;

	CURSOR c_avbl_status_history(c_position_id hr_all_positions_f.position_id%type,
								 c_eff_start_date ghr_pa_history.effective_date%type,
								 c_eff_end_date ghr_pa_history.effective_date%type)
	IS
	SELECT 1
    FROM ghr_pa_history hist
    WHERE hist.information1 = to_char(c_position_id)
    AND hist.table_name = 'HR_ALL_POSITIONS_F'
    AND (hist.effective_date BETWEEN c_eff_start_date AND c_eff_end_date
	OR TRUNC(hist.process_date) BETWEEN TRUNC(c_eff_start_date) AND TRUNC(c_eff_end_date))
	AND EXISTS(
	   SELECT 1 FROM ghr_pa_history hist1
        WHERE hist1.information1 = to_char(c_position_id)
        AND hist1.table_name = 'HR_ALL_POSITIONS_F'
        AND hist1.effective_date > hist.effective_date
		and hist.pa_history_id > hist1.pa_history_id
        AND HR_GENERAL.DECODE_AVAILABILITY_STATUS(hist1.information24) = 'Eliminated') ;


  l_function_code       VARCHAR2(1);
  l_active_inactive     VARCHAR2(1);
  l_date_abolished      VARCHAR2(9);
  l_activate_reactivate VARCHAR2(9);
  l_perm_flg            VARCHAR2(1);
  l_dt_pos_est          VARCHAR2(9);
  l_dt_nte              VARCHAR2(9);
  l_act_inact           VARCHAR2(9);
  l_get_position_rec    c_get_position_rec%ROWTYPE;
  l_get_position        c_get_position%ROWTYPE;
  l_st_date             DATE;
  l_e_date              DATE;
  l_c_date              DATE;
  l_temp_st             VARCHAR2(20);
  l_status              VARCHAR2(20);
  l_count               NUMBER;
  l_duty_sation_code    VARCHAR2(16);
  l_duty_station_desc   VARCHAR2(100);
  l_locality_pay_area   VARCHAR2(100);
  l_locality_pay_area_percentage NUMBER;
  l_proc_name  VARCHAR2(150);

BEGIN

  l_function_code      :=NULL;
  l_active_inactive    :=NULL;
  l_date_abolished     :=NULL;
  l_activate_reactivate:=NULL;
  l_perm_flg           :=NULL;
  l_dt_pos_est         :=NULL;
  l_dt_nte             :=NULL;
  l_act_inact          :=NULL;
  l_st_date            :=NULL;
  l_e_date             :=NULL;
  l_c_date             :=NULL;
  l_temp_st            :=NULL;
  l_status             :=NULL;
  l_count              := 0;
  l_proc_name  := g_proc_name ||'Get_Other_Gen_Val';

  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  OPEN c_get_position_rec(p_effective_end_date) ;
  LOOP
    FETCH c_get_position_rec INTO l_get_position_rec;
    EXIT WHEN c_get_position_rec%NOTFOUND;

    IF l_st_date IS NULL THEN
       l_st_date := l_get_position_rec.st_date;
    END IF;
    IF l_c_date IS NULL THEN
       l_c_date := l_get_position_rec.creation_date;
    END IF;

    IF l_e_date IS NULL THEN
       l_e_date :=l_get_position_rec.e_date;
    END IF;

    IF l_st_date > l_get_position_rec.st_date THEN
       l_st_date := l_get_position_rec.st_date;
    END IF;

    IF l_e_date < l_get_position_rec.e_date THEN
       l_e_date :=l_get_position_rec.e_date;
    END IF;

    IF l_get_position_rec.st_date <= p_effective_start_date
       AND l_get_position_rec.e_date >= p_effective_end_date THEN
       l_status :=l_temp_st;
    END IF;
    l_temp_st := l_get_position_rec.status;
  END LOOP;
  CLOSE c_get_position_rec ;

   l_dt_pos_est := TO_CHAR(l_st_date,'YYYYMMDD');

  Hr_Utility.set_location('p_position_id: '||p_position_id, 5);
  Hr_Utility.set_location('p_effective_start_date: '||p_effective_start_date, 5);
  Hr_Utility.set_location('l_st_date: '||l_st_date, 5);
  Hr_Utility.set_location('p_effective_end_date: '||p_effective_end_date, 5);
  Hr_Utility.set_location('l_e_date: '||l_e_date, 5);
  IF (l_st_date >= p_effective_start_date
     AND l_st_date <= p_effective_end_date)
     OR ( TRUNC(l_c_date) >= p_effective_start_date
     AND  TRUNC(l_c_date) <= p_effective_end_date) THEN
     l_function_code := 'A';
  ELSE
     l_function_code := 'C';
  END IF;

  IF l_e_date <= p_effective_end_date THEN
     l_function_code :='D';
     l_date_abolished := TO_CHAR(l_e_date,'YYYYMMDD');
  END IF;

  Hr_Utility.set_location('l_function_code: '||l_function_code, 5);

  OPEN c_get_position (p_effective_end_date);
  LOOP
     FETCH c_get_position INTO l_get_position;
     EXIT WHEN c_get_position%NOTFOUND;
  END LOOP;
  CLOSE c_get_position;

  --get dutystation code
  ghr_per_sum.get_duty_station_details(p_location_id       =>l_get_position.location_id
                                      ,p_effective_date    =>p_effective_end_date
                                      ,p_duty_sation_code  =>l_duty_sation_code
                                      ,p_duty_station_desc =>l_duty_station_desc
                                      ,p_locality_pay_area =>l_locality_pay_area
                                      ,p_locality_pay_area_percentage
				                           =>l_locality_pay_area_percentage);
  --This is only for temporary positions so NTE is only for temp position
  --based on permanent flagMaster
   IF l_e_date <> TO_DATE ('31-12-4712','DD-MM-YYYY') AND
     l_get_position.permanent_temporary_flag='N'   THEN
     l_dt_nte:=TO_CHAR(l_e_date,'YYYYMMDD');
  ELSIF l_e_date <> TO_DATE ('31-12-4712','DD-MM-YYYY') AND
     l_get_position.permanent_temporary_flag='Y' THEN
     l_date_abolished := TO_CHAR(l_e_date,'YYYYMMDD');
  END IF;

  l_perm_flg := NVL(l_get_position.permanent_temporary_flag,'N');
  IF l_get_position.status ='Active' THEN
     l_active_inactive := 'A';
  ELSE
   l_active_inactive := 'I';
   IF l_function_code <> 'A' THEN
    l_function_code :='I';
   END IF;
  END IF;

 /* IF l_get_position.status ='Eliminated' THEN
     l_date_abolished := TO_CHAR((l_get_position.effective_start_date+1),'YYYYMMDD');
  END IF;*/
 -- Check if position is reactivated
 -- Bug 4589367
   IF l_get_position.status ='Active' THEN
		FOR l_history IN c_avbl_status_history(p_position_id,p_effective_start_date,p_effective_end_date) LOOP
				l_function_code := 'R';
				EXIT;
		END LOOP;
   END IF;


/*  IF l_get_position.status <> l_status THEN
     l_act_inact:= TO_CHAR(l_get_position.effective_start_date,'YYYYMMDD');
    IF l_get_position.status='Active' THEN
       l_function_code :='R';
    END IF;
  END IF; */

  l_count := g_master_data.count;

  FOR i in 1..g_per_positions.count
  LOOP
      IF    g_per_positions(i).record_indicator=p_record_indicator
            AND (g_per_positions(i).rep_attribute_name ='Master Active-Inactive'
            OR  g_per_positions(i).rep_attribute_name ='Position Active/Inactive') THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_active_inactive;
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Date Abolished' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_date_abolished;
            g_master_data(l_count).rule:=g_per_positions(i).rule;
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND (g_per_positions(i).rep_attribute_name ='Date Inactivated-Reactivated'
            OR g_per_positions(i).rep_attribute_name ='Date Position Inactivated/ Reactivated') THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).rule :=g_per_positions(i).rule;
            g_master_data(l_count).attribute_value := l_act_inact;
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Function Code' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_function_code;

      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Position Status Budget' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_perm_flg;

      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Date Position NTE'THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := '00000000'; --l_dt_nte;
           -- g_master_data(l_count).rule := g_per_positions(i).rule;
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Date Position Established' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_dt_pos_est;
            g_master_data(l_count).rule := g_per_positions(i).rule;

      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Duty Station State Code' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := SUBSTR(l_duty_sation_code,0,2);
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Duty Station City Code' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := SUBSTR(l_duty_sation_code,3,6);
      ELSIF g_per_positions(i).record_indicator=p_record_indicator
            AND g_per_positions(i).rep_attribute_name ='Duty Station County Code' THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_per_positions(i).sequence;
            g_master_data(l_count).attribute_name :=g_per_positions(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := SUBSTR(l_duty_sation_code,7,9);
      END IF;
  END LOOP;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END;
-- =============================================================================
-- Get_Pos_KFF
-- =============================================================================
PROCEDURE Get_Pos_KFF(p_position_id       IN NUMBER
                     ,p_information_type  IN VARCHAR2
                     ,p_business_group_id IN NUMBER
                     ,p_date_effective    IN DATE
                     ,p_record_indicator  IN VARCHAR2) IS

  CURSOR c_mast_pos(cp_position_id       NUMBER
                   ,cp_effective_date    DATE
                   ,cp_business_group_id NUMBER) IS
   SELECT hap.information6 mrn
     FROM  hr_all_positions_f hap
    WHERE  hap.position_id =cp_position_id
      AND  cp_effective_date BETWEEN hap.effective_start_date
                             AND hap.effective_end_date
      AND  hap.business_group_id =cp_business_group_id;

  l_pos_ag_code   VARCHAR2(30);
  l_count         NUMBER;
  l_pos_title     VARCHAR2(40);
  l_mrn           VARCHAR2(15);
  l_position_id   hr_all_positions_f.position_id%TYPE;
  l_mast_pos c_mast_pos%ROWTYPE;
  l_proc_name      Varchar2(150) := g_proc_name ||'Get_Pos_KFF';
  l_position_number Varchar2(20);

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  l_pos_ag_code :=ghr_api.get_position_agency_code_pos
                           (p_position_id        =>p_position_id
                           ,p_business_group_id  =>p_business_group_id
                           ,p_effective_date     =>p_date_effective) ;
  l_pos_title := ghr_api.get_position_title_pos
                           (p_position_id         =>p_position_id
                           ,p_business_group_id   =>p_business_group_id
                           ,p_effective_date      =>p_date_effective) ;
  l_position_number := ghr_api.get_position_desc_no_pos(p_position_id  =>p_position_id
                                          ,p_business_group_id =>p_business_group_id
                                          ,p_effective_date    =>p_date_effective) ;
  IF p_record_indicator= 'I' THEN
     OPEN c_mast_pos(p_position_id
                    ,p_date_effective
                    ,p_business_group_id);
     FETCH c_mast_pos INTO l_mast_pos;
     CLOSE c_mast_pos;
     l_position_id := TO_NUMBER(l_mast_pos.mrn);
  ELSE
     l_position_id :=p_position_id;
  END IF;
  l_mrn := ghr_api.get_position_desc_no_pos(p_position_id       =>l_position_id
                                          ,p_business_group_id =>p_business_group_id
                                          ,p_effective_date    =>p_date_effective) ;

  l_count:=g_master_data.count;
  FOR i in 1..g_position_kff.count
  LOOP
      IF    g_position_kff(i).rep_attribute_name= 'Department Code' AND
            ( g_position_kff(i).record_indicator =p_record_indicator
            OR g_position_kff(i).record_indicator='B' )  THEN
            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_position_kff(i).sequence;
            g_master_data(l_count).attribute_name :=g_position_kff(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := SUBSTR (l_pos_ag_code,0,2);

      ELSIF g_position_kff(i).rep_attribute_name='Position Number' AND
            (g_position_kff(i).record_indicator =p_record_indicator
            OR g_position_kff(i).record_indicator='B' ) THEN
            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_position_kff(i).sequence;
            g_master_data(l_count).attribute_name :=g_position_kff(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_position_number;

      ELSIF g_position_kff(i).rep_attribute_name='Position Official Title' AND
            (g_position_kff(i).record_indicator =p_record_indicator
            OR g_position_kff(i).record_indicator ='B' )  THEN

            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_position_kff(i).sequence;
            g_master_data(l_count).attribute_name :=g_position_kff(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_pos_title;

      ELSIF g_position_kff(i).rep_attribute_name='Master Record Number'  AND
            (g_position_kff(i).record_indicator =p_record_indicator
            OR g_position_kff(i).record_indicator ='B' )  THEN
            l_count:=l_count+1;
            g_master_data(l_count).sequence := g_position_kff(i).sequence;
            g_master_data(l_count).attribute_name :=g_position_kff(i).rep_attribute_name;
            g_master_data(l_count).attribute_value := l_mrn;
      END IF;
 END LOOP;
Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
END Get_Pos_KFF;

-- =============================================================================
-- Get_Special_Rules_ValEntering
-- =============================================================================
  PROCEDURE Get_Special_Rules_Val ( p_record_values  IN t_pqp_record_values
                                   ,p_sequence       IN Number
                                   ,p_value     OUT NOCOPY VARCHAR2) IS
    l_temp       VARCHAR2(30);
    l_temp1      VARCHAR2(30);
    l_proc_name  Varchar2(150) := g_proc_name ||'Get_Special_Rules_Val';
    CURSOR c_grd (cp_grade_id NUMBER
                ,cp_business_group_id NUMBER
                )
    IS
    SELECT pg.name
      FROM per_grades  pg
       WHERE pg.grade_id=cp_grade_id
       AND pg.business_group_id = cp_business_group_id;
    l_grd c_grd%ROWTYPE;

  BEGIN

    Hr_Utility.set_location('Entering: '||l_proc_name, 5);

    IF  p_record_values(p_sequence).attribute_name='Procurement Integrity Act' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='N';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;
    IF  p_record_values(p_sequence).attribute_name='Date Abolished' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;

    IF  p_record_values(p_sequence).attribute_name='Date Inactivated-Reactivated' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;

    IF  p_record_values(p_sequence).attribute_name='Date Position Inactivated/ Reactivated' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;


    IF  p_record_values(p_sequence).attribute_name='Date Position Classified' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;

    IF  p_record_values(p_sequence).attribute_name='Date Position Last Audited/Reviewed' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;

    IF  p_record_values(p_sequence).attribute_name='Date Request Received' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;
    IF  p_record_values(p_sequence).attribute_name='Date Position Established' THEN
     IF p_record_values(p_sequence).attribute_value IS NULL THEN
      p_value:='00000000';
     ELSE
      p_value:=p_record_values(p_sequence).attribute_value;
     END IF;
    END IF;
    IF  p_record_values(p_sequence).attribute_name = 'Drug Testing' THEN
        IF p_record_values(p_sequence).attribute_value = 'Y' OR
           p_record_values(p_sequence).attribute_value = 'A' OR
           p_record_values(p_sequence).attribute_value = 'N' OR
           p_record_values(p_sequence).attribute_value = 'U' THEN
           p_value:=p_record_values(p_sequence).attribute_value;
        ELSIF p_record_values(p_sequence).attribute_value ='Z' THEN
              p_value:='C';
        ELSE
              p_value:=NULL;
        END IF;
    END IF;

    IF  p_record_values(p_sequence).attribute_name ='LEO (Law Enforcement Officer) Indicator' THEN

        IF p_record_values(p_sequence).attribute_value = '0' THEN
           p_value:='N' ;
        ELSIF p_record_values(p_sequence).attribute_value = '1' THEN
           p_value:='Y';
        ELSIF p_record_values(p_sequence).attribute_value = '2' THEN
           p_value:='A' ;
        ELSE
           p_value:=NULL;
        END IF;
    END IF;

    IF     p_record_values(p_sequence).attribute_name =  'Organizational Structure Code Agency' THEN

           p_value := SUBSTR(p_record_values(p_sequence).attribute_value,0,2);
		  -- p_value  :=null; Bug 4584046

    ELSIF  p_record_values(p_sequence).attribute_name =  'Pay Table Code' THEN
            p_value  :=SUBSTR(ghr_pay_calc.get_user_table_name
                     (p_user_table_id => TO_NUMBER(p_record_values(p_sequence).attribute_value)),0,4);

    ELSIF  p_record_values(p_sequence).attribute_name ='Position Sensitivity Code' THEN
           p_value := p_record_values(p_sequence).attribute_value;
    ELSIF  p_record_values(p_sequence).attribute_name ='Position Sensitivity Cd' THEN
           l_temp := p_record_values(p_sequence).attribute_value;
           Hr_Utility.set_location('Temp Position Sensitivity Cd '||l_temp, 5);
           Hr_Utility.set_location('Temp Value '||l_temp, 5);
           IF l_temp= 'Y' THEN
                 p_value :='C';
           ELSE
                 p_value:='N';
           END IF;

    ELSIF  p_record_values(p_sequence).attribute_name ='Financial Disclosure Required Code' THEN
           IF p_record_values(p_sequence).attribute_value = 1 THEN

            p_value := 3;
           ELSIF p_record_values(p_sequence).attribute_value=2 THEN
            p_value := 4;

           ELSIF p_record_values(p_sequence).attribute_value=8 THEN
            p_value := 5;

           ELSIF p_record_values(p_sequence).attribute_value=6 THEN

            p_value := 6;
           ELSIF p_record_values(p_sequence).attribute_value=7 THEN

            p_value := 7;
           ELSE

            p_value := NULL;

           END IF;
           --Earlier it was JUST NULL
    ELSIF  p_record_values(p_sequence).attribute_name ='Position Working Title' THEN
           p_value :=p_record_values(p_sequence).attribute_value;
    ELSIF  p_record_values(p_sequence).attribute_name ='Position Target Grade' THEN
           OPEN c_grd (to_number(p_record_values(p_sequence).attribute_value)
                        ,g_business_group_id);
           FETCH c_grd INTo l_grd;
           CLOSE c_grd;
           p_value := SUBSTR(l_grd.name,4,2);
    ELSIF  p_record_values(p_sequence).attribute_name ='Maintenance Review Class Code' THEN
           l_temp := SUBSTR(p_record_values(p_sequence).attribute_value,0,1);
           l_temp1 := g_master_data(39).attribute_value;
           p_value:=l_temp||l_temp1;
  END IF;

  Hr_Utility.set_location('p_value: '||p_value, 5);
  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
END Get_Special_Rules_Val;

-- =============================================================================
-- Get_Grd_Pay_Job
-- =============================================================================
PROCEDURE Get_Grd_Pay_Job(p_position_id         IN  NUMBER
                         ,p_information_type    IN  VARCHAR2
                         ,p_date_effective      IN  DATE
                         ,p_record_indicator    IN  VARCHAR2) IS
    CURSOR c_job IS
    SELECT job.name
      FROM hr_all_positions_f pos,
           per_jobs job
     WHERE pos.position_id = p_position_id
       AND p_date_effective BETWEEN pos.effective_start_date
       AND pos.effective_end_date
       AND job.job_id      = pos.job_id;

  l_posi_extra_info per_position_extra_info%rowtype;
  l_grade  VARCHAR2(2);
  l_pay_plan VARCHAR2(2);
  l_job c_job%ROWTYPE;
  l_count   NUMBER;
  l_proc_name      Varchar2(150) := g_proc_name ||'Get_Grd_Pay_Job';
  l_grade_plan_id   VARCHAR2(10);

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
 OPEN c_job;
 FETCH c_job INTO l_job;
 CLOSE c_job;
 l_grade_plan_id := ghr_pa_requests_pkg2.get_pay_plan_grade(p_position_id => p_position_id ,
                                                           p_effective_date => p_date_effective);

 IF l_grade_plan_id IS NOT NULL then
    l_grade := SUBSTR(l_grade_plan_id,4,5);
    l_pay_plan :=SUBSTR (l_grade_plan_id,1,2);
 END IF;

 l_count:=g_master_data.count;
 FOR i in 1..g_grade_kff.count
 LOOP
   IF    g_grade_kff(i).rep_attribute_name='Grade' THEN
         l_count:=l_count+1;
         g_master_data(l_count).attribute_name := g_grade_kff(i).rep_attribute_name;
         g_master_data(l_count).attribute_value :=l_grade;
         g_master_data(l_count).sequence        := g_grade_kff(i).sequence;

   ELSIF g_grade_kff(i).rep_attribute_name='Pay Plan' AND
         (g_grade_kff(i).record_indicator =p_record_indicator)  THEN
         l_count:=l_count+1;
         g_master_data(l_count).attribute_name :=g_grade_kff(i).rep_attribute_name;
         g_master_data(l_count).attribute_value:=l_pay_plan;
         g_master_data(l_count).sequence       :=g_grade_kff(i).sequence;
   END IF;
  END LOOP;

 IF g_job_kff(1).rep_attribute_name='Occupational Series Code'
   AND  g_job_kff(1).record_indicator =p_record_indicator THEN
    l_count:=l_count+1;
    g_master_data(l_count).attribute_name := g_job_kff(1).rep_attribute_name;
    g_master_data(l_count).attribute_value :=l_job.name;
    g_master_data(l_count).sequence        := g_job_kff(1).sequence;
 END IF;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
EXCEPTION
WHEN others THEN
  Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);
END Get_Grd_Pay_Job;

-- =============================================================================
-- Get_Poei_Values
-- =============================================================================
PROCEDURE  Get_Poei_Values
                    ( p_position_id         in  number
                     ,p_information_type    in  varchar2
                     ,p_date_effective      in  date
                     ,p_record_indicator    IN VARCHAR2
                    ) IS
  l_count  NUMBER;
  l_posi_extra_info per_position_extra_info%rowtype;
  l_pos_extra_info  t_pos_extra_info;
  l_pos number;
  l_ei number;
  l_agency_code    per_position_definitions.segment3%TYPE;
  l_poi            per_position_definitions.segment4%TYPE;
  l_grade          per_position_definitions.segment5%TYPE;
  l_proc_name  constant  varchar2(150) := g_proc_name ||'get_poei_values';
 BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   ghr_history_fetch.fetch_positionei
                           ( p_position_id      =>p_position_id
                            ,p_information_type =>p_information_type
                            ,p_date_effective   =>p_date_effective
                            ,p_pos_ei_data      =>l_posi_extra_info);

   Create_Poition_Extra_Info (p_posi_extra_info =>l_posi_extra_info
                             ,p_pos_extra_info  =>l_pos_extra_info);
   l_count:=g_master_data.count;
   l_pos :=l_pos_extra_info.count;
   l_ei  := g_per_position_extra_info.count;
   FOR i in 1..l_pos_extra_info.count
   LOOP
    FOR j in 1..g_per_position_extra_info.count
    LOOP
     IF g_per_position_extra_info(j).context_name= l_pos_extra_info(i).poei_information_category
        AND g_per_position_extra_info(j).db_column_name = l_pos_extra_info(i).poei_information
        AND (g_per_position_extra_info(j).record_indicator =p_record_indicator
        OR g_per_position_extra_info(j).record_indicator='B' )    THEN

	IF g_per_position_extra_info(j).rep_attribute_name = 'Agency Code' OR
 	   g_per_position_extra_info(j).rep_attribute_name = 'Personnel Office Identifier' THEN


           OPEN csr_get_default_values(c_position_id      => g_position_id
                 ,c_effective_date   => g_extract_params(g_business_group_id).to_date);
           FETCH csr_get_default_values INTO l_agency_code,l_poi,l_grade;
           CLOSE csr_get_default_values;

           Hr_Utility.set_location('g_position_id-- '||g_position_id, 5);
           IF g_per_position_extra_info(j).rep_attribute_name = 'Agency Code' THEN
             Hr_Utility.set_location('Agency Code Before-- '||l_pos_extra_info(i).poei_value, 5);
             Hr_Utility.set_location('Agency Code After-- '||l_agency_code, 5);
  	      g_master_data(l_count+1).attribute_value := l_agency_code;
           ELSE
              Hr_Utility.set_location('POI Code Before-- '||l_poi, 5);
              Hr_Utility.set_location('POI After--- '||l_poi, 5);
	      g_master_data(l_count+1).attribute_value := l_poi;
	   END IF;

	ELSE
	  g_master_data(l_count+1).attribute_value := l_pos_extra_info(i).poei_value;
        END IF;
           g_master_data(l_count+1).sequence := g_per_position_extra_info(j).sequence;
           g_master_data(l_count+1).attribute_name :=g_per_position_extra_info(j).rep_attribute_name;
           g_master_data(l_count+1).rule            :=g_per_position_extra_info(j).rule;
           l_count:=l_count+1;
     END IF;
    END LOOP;
   END LOOP;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
END Get_Poei_Values;
-- =============================================================================
-- Get_Interdisciplinary_Data
-- =============================================================================
PROCEDURE Get_Interdisciplinary_Data(p_position_id         IN  NUMBER
                                    ,p_business_group_id   IN  NUMBER
                                    ,p_effective_date      IN  DATE
                                    ,p_record_indicator    IN  VARCHAR2) IS

   CURSOR c_get_int (cp_position_id       NUMBER
                    ,cp_business_group_id NUMBER) IS
     SELECT poei_information3 Int_Series_Code
           ,poei_information4 Int_Title_Code
           ,poei_information6 Int_Title_Suffix
           ,poei_information5 Int_Title_Prefix
      FROM per_position_extra_info pei
      WHERE pei.position_id  = cp_position_id
        AND rownum <=10
	AND information_type = 'GHR_US_POSITION_INTERDISC'
        ORDER BY poei_information3;

  l_get_int c_get_int%ROWTYPE;
  l_seq     NUMBER:=28;
  l_rc      NUMBER:=0;
  l_num     NUMBER;
  l_count   NUMBER :=0;
  l_proc_name  constant  varchar2(150) := g_proc_name ||'Get_Interdisciplinary_Data';
BEGIN
IF p_record_indicator='I' THEN
l_seq:=43;
END IF;
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
    l_count:=l_count+1;
   OPEN c_get_int (p_position_id
                  ,p_business_group_id);
   LOOP
     FETCH c_get_int INTO l_get_int;
     EXIT WHEN c_get_int%NOTFOUND;
     g_int_metadata(l_count).int_series_code  :=l_get_int.Int_Series_Code;
     g_int_metadata(l_count).int_title_code   :=l_get_int.Int_Title_Code;
     g_int_metadata(l_count).int_title_suffix :=l_get_int.Int_Title_Suffix;
     g_int_metadata(l_count).int_title_prefix :=l_get_int.Int_Title_Prefix;
     l_count:=l_count+1;
   END LOOP;
   CLOSE c_get_int;
   l_rc:=1;
   IF g_int_metadata.count > 0 THEN
    l_interdiscp_cd :='Y';
   ELSE

    l_interdiscp_cd :='N';
   END IF;
   FOR i in 1..g_int_metadata.count
   LOOP
     g_int_data(l_seq).sequence := l_seq;
     g_int_data(l_seq).attribute_name :='Interdisciplinary Series Code'||l_rc;
     g_int_data(l_seq).attribute_value:=g_int_metadata(i).Int_Series_Code;
     l_seq :=l_seq+1;
     l_rc:=l_rc+1;
     g_int_data(l_seq).sequence := l_seq;
     g_int_data(l_seq).attribute_name :='Interdisciplinary Title Code'||l_rc;
     g_int_data(l_seq).attribute_value:=g_int_metadata(i).Int_Title_Code;
     l_seq :=l_seq+1;
     l_rc:=l_rc+1;
     g_int_data(l_seq).sequence := l_seq;
     g_int_data(l_seq).attribute_name :='Interdisciplinary Title Suffix'||l_rc;
     g_int_data(l_seq).attribute_value:=g_int_metadata(i).Int_Title_Suffix;
     l_seq :=l_seq+1;
     l_rc:=l_rc+1;
     g_int_data(l_seq).sequence := l_seq;
     g_int_data(l_seq).attribute_name :='Interdisciplinary Title prefix'||l_rc;
     g_int_data(l_seq).attribute_value:=g_int_metadata(i).Int_Title_prefix;
     l_seq :=l_seq+1;
     l_rc:=l_rc+1;
   END LOOP;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
END Get_Interdisciplinary_Data;
 -- =============================================================================
 -- Build_Element_Values
 -- =============================================================================
 PROCEDURE Build_Element_Values
                (p_position_id            IN per_all_positions.position_id%type
                ,p_business_group_id      IN per_all_positions.business_group_id%type
                ,p_effective_start_date   IN date  default sysdate
                ,p_effective_end_date     IN date  default sysdate
                ,p_record_indicator       IN VARCHAR2) IS

  CURSOR c_pos(cp_position_id          NUMBER
              ,cp_business_group_id    NUMBER
              ,cp_effective_start_date DATE
              ,cp_effective_end_date   DATE) IS
   SELECT hap.effective_start_date
         ,hap.effective_end_date
     FROM hr_all_positions_f hap
    WHERE hap.position_id = cp_position_id
      AND (cp_effective_end_date BETWEEN hap.effective_start_date
                               AND hap.effective_end_date
       OR hap.effective_start_date BETWEEN cp_effective_start_date
                               AND cp_effective_end_date
       OR hap.effective_end_date BETWEEN cp_effective_start_date
                               AND cp_effective_end_date)
      AND hap.business_group_id   = cp_business_group_id
    ORDER BY hap.effective_end_date;

    l_pos                c_pos%ROWTYPE;
    l_proc_name          VARCHAR2(150) := g_proc_name ||'Build_Element_Values';
    l_pos_ag_code        VARCHAR2(30);
    l_posi_extra_info    per_position_extra_info%ROWTYPE;
    l_pos_extra_info     t_pos_extra_info;
    l_count              NUMBER;
    l_rc                 NUMBER;
    l_effective_end_date DATE;
    l_row                NUMBER;

  BEGIN
    Hr_Utility.set_location('Entering: '||l_proc_name, 5);

    IF l_master_data_temp.count> 0 THEN
     l_master_data_temp.delete;
    END IF;
    IF g_master_data.count >0 THEN
       g_master_data.delete;
    END IF;

    IF g_int_data.count>0 THEN
        g_int_data.delete;
    END IF;

    IF g_int_metadata.count>0 THEN
       g_int_metadata.delete;
    END IF;
    l_interdiscp_cd :=NULL;

    OPEN  c_pos(p_position_id
               ,p_business_group_id
               ,p_effective_start_date
               ,p_effective_end_date);
    LOOP
     FETCH c_pos INTO l_pos;
      EXIT WHEN c_pos%NOTFOUND;
     END LOOP;
    CLOSE c_pos;

    IF l_pos.effective_end_date < p_effective_end_date THEN
       l_effective_end_date :=l_pos.effective_end_date;
    ELSE
       l_effective_end_date:=p_effective_end_date;
    END IF;

    Build_Metadata_Values;

   ---Get the values from Position kff
   IF p_record_indicator = 'M' THEN
      g_master_data(1).sequence        := 2;
      g_master_data(1).attribute_name  :='Indicator Code Record Identifier';
      g_master_data(1).attribute_value :='2055';

      Get_Pos_KFF(p_position_id       =>p_position_id
                 ,p_information_type  =>''
                 ,p_business_group_id =>p_business_group_id
                 ,p_date_effective    =>l_effective_end_date
                 ,p_record_indicator  =>p_record_indicator);

      Get_Other_Gen_Val(p_position_id          =>p_position_id
                       ,p_business_group_id    =>p_business_group_id
                       ,p_effective_start_date =>p_effective_start_date
                       ,p_effective_end_date   =>l_effective_end_date
                       ,p_record_indicator     =>p_record_indicator);

      Get_Grd_Pay_Job(p_position_id      =>p_position_id
                     ,p_information_type =>'GHR_US_POS_VALID_GRADE'
                     ,p_date_effective   =>l_effective_end_date
                     ,p_record_indicator =>p_record_indicator);

      Get_Poei_Values(p_position_id      =>p_position_id
                     ,p_information_type =>'GHR_US_POS_GRP1'
                     ,p_date_effective   =>l_effective_end_date
                     ,p_record_indicator =>p_record_indicator);

      Get_Poei_Values(p_position_id      =>p_position_id
                     ,p_information_type =>'GHR_US_POS_GRP2'
                     ,p_date_effective   =>l_effective_end_date
                     ,p_record_indicator =>p_record_indicator);

      Get_Poei_Values(p_position_id      =>p_position_id
                     ,p_information_type =>'GHR_US_POS_GRP3'
                     ,p_date_effective   =>l_effective_end_date
                     ,p_record_indicator =>p_record_indicator);

      Get_Poei_Values(p_position_id      =>p_position_id
                     ,p_information_type =>'GHR_US_POS_VALID_GRADE'
                     ,p_date_effective   =>l_effective_end_date
                     ,p_record_indicator =>p_record_indicator);

      Get_Interdisciplinary_Data(p_position_id        =>p_position_id
                                ,p_business_group_id  =>p_business_group_id
                                ,p_effective_date     =>l_effective_end_date
                                ,p_record_indicator   =>p_record_indicator);

  ELSIF p_record_indicator = 'I' THEN

         g_master_data(1).sequence := 2;
         g_master_data(1).attribute_name :='Indicator Code Record Identifier';
         g_master_data(1).attribute_value := '2056';

         Get_Pos_KFF (p_position_id      =>p_position_id
                    ,p_information_type  =>''
                    ,p_business_group_id =>p_business_group_id
                    ,p_date_effective    =>l_effective_end_date
                    ,p_record_indicator  =>p_record_indicator);

       ---Get the values generic
         Get_Other_Gen_Val(p_position_id        =>p_position_id
                        ,p_business_group_id    =>p_business_group_id
                        ,p_effective_start_date =>p_effective_start_date
                        ,p_effective_end_date   =>l_effective_end_date
                        ,p_record_indicator     =>p_record_indicator);

         --Begin Grade pay job
         Get_Grd_Pay_Job(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_VALID_GRADE'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);

         ---Get the values generic
         Get_Poei_Values(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_GRP1'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);

         --Info category GHR_US_POS_GRP2
         Get_Poei_Values(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_GRP2'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);

         --Info category GHR_US_POS_GRP3
         Get_Poei_Values(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_GRP3'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);

         --Info category GHR_US_POS_VALID_GRADE
         Get_Poei_Values(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_VALID_GRADE'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);
        ----
         Get_Poei_Values(p_position_id    =>p_position_id
                      ,p_information_type =>'GHR_US_POS_OBLIG'
                      ,p_date_effective   =>l_effective_end_date
                      ,p_record_indicator =>p_record_indicator);

         Get_Interdisciplinary_Data(p_position_id        =>p_position_id
                                ,p_business_group_id  =>p_business_group_id
                                ,p_effective_date     =>l_effective_end_date
                                ,p_record_indicator   =>p_record_indicator);
    END IF;
    --Now rearrange the data in the master data so that it is arranged in sequence.
    l_row :=g_master_data.first;
    WHILE l_row <= g_master_data.last
     LOOP
      l_master_data_temp(g_master_data(l_row).sequence).sequence := g_master_data(l_row).sequence;
      l_master_data_temp(g_master_data(l_row).sequence).attribute_name := g_master_data(l_row).attribute_name;
      l_master_data_temp(g_master_data(l_row).sequence).attribute_value := g_master_data(l_row).attribute_value;
      l_master_data_temp(g_master_data(l_row).sequence).rule := g_master_data(l_row).rule;
      l_row :=g_master_data.next(l_row);
     END LOOP;
    IF g_master_data.count >0 THEN
       g_master_data.delete;
    END IF;
    g_master_data := l_master_data_temp;
    Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Build_Element_Values;

-- =============================================================================
-- Get_Interface_Attribute_Value
-- =============================================================================
FUNCTION Get_Interface_Attribute_Value
                       (p_indicator          VARCHAR2
                       ,p_attribute_name     VARCHAR2
                       ,p_sequence           NUMBER
                       ) RETURN VARCHAR2 IS

 l_ret_value      VARCHAR2(80):= null;
 l_pqp_record_values  t_pqp_record_values;
 l_count          NUMBER;
 l_rule           VARCHAR2(1);
 l_row            NUMBER;
 l_sequence       NUMBER;
 l_attribute_name VARCHAR2(80);
 i                PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID%TYPE;
 l_proc_name      VARCHAR2(150) := g_proc_name ||'Get_Interface_Attribute_Value';

BEGIN

 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
 Hr_Utility.set_location('g_position_id: '||g_position_id, 5);
 i := g_business_group_id;

 BEGIN
  l_sequence := TO_NUMBER(SUBSTR(p_attribute_name,LENGTH(p_attribute_name)-1,LENGTH(p_attribute_name)));
  l_attribute_name :=SUBSTR(p_attribute_name,0,LENGTH(p_attribute_name)-2);
 EXCEPTION
 WHEN OTHERS THEN
  l_sequence:=0;
  l_attribute_name:=p_attribute_name;
 END;

 Hr_Utility.set_location('l_attribute_name'||l_attribute_name, 5);
 Hr_Utility.set_location('l_sequence'||l_sequence, 5);

 l_count :=l_pqp_record_values.count;
 IF p_indicator ='M' THEN
    IF l_attribute_name like 'Interdisciplinary Series%' THEN
     IF g_int_data.exists(l_sequence) THEN
      l_ret_value := g_int_data(l_sequence).attribute_value;
     ELSE
      l_ret_value :='0000';
     END IF;

    ELSIF  l_attribute_name like 'Interdisciplinary Title%' THEN
     IF g_int_data.exists(l_sequence) THEN
      l_ret_value := g_int_data(l_sequence).attribute_value;
     END IF;
    ELSIF l_attribute_name = 'Interdisciplinary Code' THEN
           l_ret_value := l_interdiscp_cd;
    ELSIF l_attribute_name ='Positon ID' THEN
          l_ret_value :=g_position_id;
    ELSIF l_attribute_name ='User-Identification' THEN
         l_ret_value :=g_extract_params(i).user_id;
    ELSE
          l_count:=l_count+1;
          l_pqp_record_values(l_sequence).attribute_name :=g_master_data(l_sequence).attribute_name;
          l_pqp_record_values(l_sequence).attribute_value:=g_master_data(l_sequence).attribute_value;
          l_pqp_record_values(l_sequence).rule           :=g_master_data(l_sequence).rule;
          l_rule                                         :=g_master_data(l_sequence).rule;
          l_ret_value := g_master_data(l_sequence).attribute_value;
          IF l_pqp_record_values(l_sequence).attribute_name <> l_attribute_name THEN
             IF l_pqp_record_values.count > 0 THEN
                l_pqp_record_values.delete;
             END IF;
          l_row :=g_master_data.first;
          WHILE l_row <= g_master_data.last
          LOOP
             IF g_master_data(l_row).attribute_name=l_attribute_name THEN
                l_count:=l_count+1;
                l_pqp_record_values(l_row).attribute_name :=g_master_data(l_row).attribute_name;
                l_pqp_record_values(l_row).attribute_value:=g_master_data(l_row).attribute_value;
                l_pqp_record_values(l_row).rule           :=g_master_data(l_row).rule;
                l_rule                                    :=g_master_data(l_row).rule;
                l_ret_value := g_master_data(l_row).attribute_value;
                EXIT;
             END IF;
             l_row :=g_master_data.next(l_row);
          END LOOP;
         END IF;
  END IF;
 ELSE

   IF l_attribute_name like 'Interdisciplinary Occupational Series%' THEN
     IF g_int_data.exists(l_sequence) THEN
      l_ret_value := g_int_data(l_sequence).attribute_value;
      RETURN(l_ret_value);
     ELSE
      l_ret_value :='0000';
      RETURN(l_ret_value);
     END IF;
   END IF;

  IF l_attribute_name ='Position ID' or  l_attribute_name ='Positon ID' THEN
     l_ret_value :=g_position_id;
  ELSIF l_attribute_name ='User Id' THEN
     l_ret_value :=g_extract_params(i).user_id;
  ELSE

       l_count:=l_count+1;
     l_pqp_record_values(l_sequence).attribute_name := g_master_data(l_sequence).attribute_name;
     l_pqp_record_values(l_sequence).attribute_value:=g_master_data(l_sequence).attribute_value;
     l_pqp_record_values(l_sequence).rule           :=g_master_data(l_sequence).rule;
     l_rule                                      :=g_master_data(l_sequence).rule;
     l_ret_value := g_master_data(l_sequence).attribute_value;

     Hr_Utility.set_location('attribute_name'||g_master_data(l_sequence).attribute_name, 5);
     Hr_Utility.set_location('attribute_value'||g_master_data(l_sequence).attribute_value, 5);


     IF l_pqp_record_values(l_sequence).attribute_name <> l_attribute_name THEN
        IF l_pqp_record_values.count > 0 THEN
           l_pqp_record_values.delete;
        END IF;
        l_row :=g_master_data.first;
        WHILE l_row <= g_master_data.last
        LOOP
           IF g_master_data(l_row).attribute_name=l_attribute_name THEN
              l_count:=l_count+1;
              l_pqp_record_values(l_row).attribute_name := g_master_data(l_row).attribute_name;
              l_pqp_record_values(l_row).attribute_value:=g_master_data(l_row).attribute_value;
              l_pqp_record_values(l_row).rule           :=g_master_data(l_row).rule;
              l_rule                                    :=g_master_data(l_row).rule;
              l_ret_value := g_master_data(l_row).attribute_value;
           EXIT;
           END IF;
           l_row :=g_master_data.next(l_row);
        END LOOP;
    END IF;
  END IF;
 END IF;
 IF l_rule='Y' THEN
    Get_Special_Rules_Val(p_record_values    =>l_pqp_record_values
                         ,p_sequence         =>l_sequence
                         ,p_value            =>l_ret_value);
 END IF;

/* IF l_attribute_name =  'Organizational Structure Code Agency' THEN
    l_ret_value := null;
 END IF; */ -- Bug 4584046

 IF l_attribute_name =  'Obligated SSN' AND l_ret_value is not null THEN
     l_ret_value := ben_ext_fmt.apply_format_mask(l_ret_value, '9999999999');
 END IF;


 RETURN(l_ret_value);
 Hr_Utility.set_location('Return_value-: '||l_ret_value, 5);
 Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
 WHEN Others THEN
 hr_utility.set_location('Error Leaving: '||l_proc_name, 90);
 return null;
END Get_Interface_Attribute_Value;
-- =============================================================================
-- Check_Master_Position:This will call from record advanced condetions to
-- check the position is detail or master
-- =============================================================================
FUNCTION Check_Position_Type(p_sub_header_type  IN VARCHAR2
                            ,p_error_message    OUT NOCOPY Varchar2
  		             ) RETURN Varchar2 IS

   l_proc_name      Varchar2(150) := g_proc_name ||'Check_Position_Type';
   l_return_value   Varchar2(2) :='N';
   l_valid_action   Varchar2(2);

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location('p_sub_header_type'||p_sub_header_type, 5);
   Hr_Utility.set_location('g_position_id'||g_position_id , 5);
   Hr_Utility.set_location('g_master_position_exist'||g_master_position_exist , 5);

   IF p_sub_header_type = 'MASTER_POSITION' THEN
      --Check the Position is master then return "Y"
      IF g_master_position_exist = 'Y' THEN
	 l_return_value :='Y';
      END IF;
   ELSE
      --Check the position is detail then return value is "Y"
      --this procedure will call from two different data elements for master and Child
      -- so always return "Y" if condetion is valid based on p_sub_header_type
      OPEN csr_detail_position (cp_position_id      => g_position_id
                               ,cp_effective_date   => g_extract_params(g_business_group_id).to_date
 			       ,cp_business_group_id=> g_business_group_id);
      FETCH csr_detail_position INTO l_valid_action;
      CLOSE csr_detail_position;
      Hr_Utility.set_location('l_valid_action'||l_valid_action , 5);

      IF l_valid_action = 'X' THEN
         g_master_position_exist :='N';
         l_return_value :='Y';
      END IF;
   END IF;
   Hr_Utility.set_location('l_return_value: '||l_return_value, 80);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('error Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Check_Position_Type;

-- =============================================================================
-- Position_Sub_Header_Criteria: The Main Sub Header  criteria that would be used
-- for the position extract.
-- =============================================================================
FUNCTION Position_Sub_Header_Criteria
          (p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
	  ,p_position_id          IN hr_all_positions_f.position_id%TYPE
          ,p_warning_message      OUT NOCOPY Varchar2
          ,p_error_message        OUT NOCOPY Varchar2
           ) RETURN Varchar2 IS

   -- Checking the position is attached to person or not
   CURSOR csr_person_exist
           (c_position_id       IN  NUMBER
           ,c_effective_date    IN  DATE
           ,c_business_group_id IN  NUMBER) IS
      SELECT 'X'
        FROM per_all_assignments_f
       WHERE position_id       = c_position_id
         AND business_group_id = c_business_group_id
	 AND c_effective_date BETWEEN effective_start_date
	 AND effective_end_date;


  l_proc_name          Varchar2(150) := g_proc_name ||'Position_Sub_Header_Criteria';
  l_req_params         csr_req_params%ROWTYPE;
  l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
  i                    per_all_assignments_f.business_group_id%TYPE;
  l_ext_rslt_id        ben_ext_rslt.ext_rslt_id%TYPE;
  l_ext_dfn_id         ben_ext_dfn.ext_dfn_id%TYPE;
  l_return_value       Varchar2(2) :='Y';
  l_valid_action       Varchar2(2) := 'Y';
  l_x_valid_action     Varchar2(2) := 'Y';
  l_value              Varchar2(150) ;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   g_person_exist := 'N';
   i := p_business_group_id;
   l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;
   l_ext_dfn_id  := ben_ext_thread.g_ext_dfn_id;
   g_position_id := p_position_id;
   g_business_group_id :=p_business_group_id;

   Hr_Utility.set_location('l_ext_rslt_id: '||l_ext_rslt_id, 5);
   Hr_Utility.set_location('l_ext_dfn_id: '||l_ext_dfn_id, 5);
   Hr_Utility.set_location('p_business_group_id: '||p_business_group_id, 5);
   Hr_Utility.set_location('p_position_id: '||p_position_id, 5);

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
      -- Store the params. in a PL/SQL table record
      g_extract_params(i).business_group_id      := p_business_group_id;
      g_extract_params(i).concurrent_req_id      := l_conc_reqest_id;
      g_extract_params(i).ext_dfn_id             := l_ext_dfn_id;
      g_extract_params(i).transmission_type      := l_req_params.argument7;
      g_extract_params(i).date_criteria          := l_req_params.argument8;
      g_extract_params(i).from_date              := Fnd_Date.canonical_to_date(l_req_params.argument12);
      g_extract_params(i).to_date                := Fnd_Date.canonical_to_date(l_req_params.argument13);
      g_extract_params(i).agency_code            := l_req_params.argument14;
      g_extract_params(i).personnel_office_id    := l_req_params.argument15;
      g_extract_params(i).transmission_indicator := l_req_params.argument16;
      g_extract_params(i).signon_identification  := l_req_params.argument17;
      g_extract_params(i).user_id                := l_req_params.argument18;
      g_extract_params(i).dept_code              := l_req_params.argument19;
      g_extract_params(i).payroll_id             := l_req_params.argument20;
      g_extract_params(i).notify                 := l_req_params.argument21;

      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
   END IF;

      --Check the position is master or child then populate only those records
      OPEN csr_master_position (cp_position_id      => g_position_id
                               ,cp_effective_date   => g_extract_params(i).to_date
 			       ,cp_business_group_id=> p_business_group_id);
      FETCH csr_master_position INTO l_valid_action;
      CLOSE csr_master_position;

      IF l_valid_action = 'X' THEN
         Hr_Utility.set_location('Master Position found', 17);
         --Setting the Master position data
   	 g_master_position_exist :='Y';
	 Build_Element_Values(p_position_id => g_position_id
              ,p_business_group_id      => p_business_group_id
              ,p_effective_start_date   => g_extract_params(i).from_date
              ,p_effective_end_date     => g_extract_params(i).to_date
              ,p_record_indicator       => 'M');

	   -- Checking the conc parameters criteria
 	    IF g_extract_params(i).dept_code IS NOT NULL THEN
    	       l_value :=Get_Interface_Attribute_Value('M','Department Code03',0);
               Hr_Utility.set_location('in side Dept Code--'||l_value, 17);
   	         IF l_value <> g_extract_params(i).dept_code THEN
	          l_return_value := 'N';
  	          return l_return_value;
    	         END IF;
	     END IF;

            -- Checking the conc parameters criteria
    	    l_value :=Get_Interface_Attribute_Value('M','Agency Code04',0);
            Hr_Utility.set_location('inside Agency Code--'||l_value, 17);
	    Hr_Utility.set_location('g_extract_params(i).agency_code--'||g_extract_params(i).agency_code, 17);

  	       IF l_value <> g_extract_params(i).agency_code THEN
	          l_return_value := 'N';
            Hr_Utility.set_location('inside l_return_value--'||l_return_value, 17);
 	          return l_return_value;
   	       END IF;

	    IF g_extract_params(i).personnel_office_id IS NOT NULL THEN
               l_value :=Get_Interface_Attribute_Value('M','Personnel Office Identifier05',0);
                Hr_Utility.set_location('Personnel Office Identifier--'||l_value, 17);
  	          IF l_value <> g_extract_params(i).personnel_office_id THEN
   	             l_return_value := 'N';
   	             return l_return_value;
	          END IF;
   	    END IF;

      ELSE
         Hr_Utility.set_location('Detail Position found', 17);
         --Checking the sub position is attached to person or not
	 --If attached then set the g_person_exist is to "Y"
         OPEN csr_person_exist(c_position_id       => g_position_id
                              ,c_effective_date    => g_extract_params(i).to_date
        	              ,c_business_group_id => p_business_group_id);
         FETCH csr_person_exist INTO l_x_valid_action;
         CLOSE csr_person_exist;
         IF l_x_valid_action = 'X' THEN
            Hr_Utility.set_location('Detial Position attached', 17);
            g_person_exist := 'Y';
 	 ELSE
            Hr_Utility.set_location('Detial Position not attached', 17);
            g_person_exist := 'N';
     	    Build_Element_Values(p_position_id         => g_position_id
                                ,p_business_group_id   => p_business_group_id
                                ,p_effective_start_date=> g_extract_params(i).from_date
                                ,p_effective_end_date  => g_extract_params(i).to_date
                                ,p_record_indicator    => 'I');

    	    IF g_extract_params(i).dept_code IS NOT NULL THEN
   	       l_value :=Get_Interface_Attribute_Value('I','Department Code03',0);
  	          IF l_value <> g_extract_params(i).dept_code THEN
	             l_return_value := 'N';
	             return l_return_value;
    	          END IF;
              END IF;

	    l_value :=Get_Interface_Attribute_Value('I','Agency Code04',0);
  	       IF l_value <> g_extract_params(i).agency_code THEN
       	          l_return_value := 'N';
	          return l_return_value;
   	       END IF;

	    IF g_extract_params(i).personnel_office_id IS NOT NULL THEN
               l_value :=Get_Interface_Attribute_Value('I','Personnel Office Identifier05',0);
   	          IF l_value <> g_extract_params(i).personnel_office_id THEN
   	             l_return_value := 'N';
  	             return l_return_value;
	           END IF;
             END IF;
         END IF;
    	 --Setting the Details position data
   	 g_master_position_exist :='N';
	 --If above condetions are fine then return "Y"
     END IF;
   Hr_Utility.set_location('..l_return_value : '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Position_Sub_Header_Criteria;

-- =============================================================================
-- Position_Person_Main_Criteria: The Main criteria that would be used
-- for the position extract.
-- =============================================================================
FUNCTION Position_Person_Main_Criteria
          (p_business_group_id    IN per_all_assignments_f.business_group_id%TYPE
          ,p_effective_date       IN Date
	  ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
          ,p_warning_message      OUT NOCOPY Varchar2
          ,p_error_message        OUT NOCOPY Varchar2
           ) RETURN Varchar2 IS

  CURSOR   per_assignment_f_cursor(c_assignment_id     IN  NUMBER
                                  ,c_effective_date    IN  DATE
                                  ,c_business_group_id IN  NUMBER) IS
    SELECT position_id
     FROM  per_all_assignments_f
    WHERE  assignment_id = c_assignment_id
      AND  business_group_id = c_business_group_id
      AND  c_effective_date BETWEEN effective_start_date
      AND  effective_end_date;

  l_proc_name          Varchar2(150) := g_proc_name ||'Person_Main_Criteria';
  i                    per_all_assignments_f.business_group_id%TYPE;
  l_return_value       Varchar2(2) :='Y';
  l_conc_reqest_id     ben_ext_rslt.request_id%TYPE;
  l_position_id        hr_all_positions_f.position_id%TYPE;
  l_value              Varchar2(150) ;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   Hr_Utility.set_location('p_assignment_id: '||p_assignment_id, 5);
   Hr_Utility.set_location('p_business_group_id: '||p_business_group_id, 5);

   i := p_business_group_id;
   OPEN per_assignment_f_cursor(c_assignment_id	    =>p_assignment_id
                               ,c_effective_date    =>p_effective_date
			       ,c_business_group_id =>p_business_group_id);
   FETCH per_assignment_f_cursor INTO l_position_id;
   CLOSE per_assignment_f_cursor;
   g_position_id := l_position_id;

   Build_Element_Values(p_position_id   => l_position_id
                       ,p_business_group_id      => p_business_group_id
                       ,p_effective_start_date   => g_extract_params(i).from_date
                       ,p_effective_end_date     => g_extract_params(i).to_date
                       ,p_record_indicator       => 'I');

   IF g_extract_params(i).dept_code IS NOT NULL THEN
      l_value :=Get_Interface_Attribute_Value('I','Department Code03',0);
      IF l_value <> g_extract_params(i).dept_code THEN
         l_return_value := 'N';
         return l_return_value;
       END IF;
   END IF;

   l_value :=Get_Interface_Attribute_Value('I','Agency Code04',0);
   IF l_value <> g_extract_params(i).agency_code THEN
      l_return_value := 'N';
   END IF;

   IF g_extract_params(i).personnel_office_id IS NOT NULL THEN
      l_value :=Get_Interface_Attribute_Value('I','Personnel Office Identifier05',0);
      IF l_value <> g_extract_params(i).personnel_office_id THEN
         l_return_value := 'N';
      END IF;
   END IF;

   Hr_Utility.set_location('..l_return_value : '||l_return_value, 79);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message :='SQL-ERRM :'||SQLERRM;
    Hr_Utility.set_location('..'||p_error_message,85);
    Hr_Utility.set_location('Error Leaving: '||l_proc_name, 90);
    RETURN l_return_value;
END Position_Person_Main_Criteria;
-- =============================================================================
-- ~ Evaluate_SubHeader_Formula:
-- =============================================================================
function Evaluate_SubHeader_Formula
        (p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )
         return varchar2 as
   l_return_value           varchar2(150) := null;
   l_proc_name  constant    varchar2(250) := g_proc_name ||'Evaluate_SubHeader_Formula';
   l_pa_request_id          number;
BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   p_error_code:= '0'; p_msg_type := '0'; p_error_message:= '0';

   IF p_attribute_name = 'Position ID' THEN
      l_return_value := g_position_id;
   ELSE
      l_return_value :=Get_Interface_Attribute_Value(p_indicator,p_attribute_name,0);
   END IF;
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   return l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message := sqlerrm;
    p_msg_type     := 'E'; p_error_code    := sqlcode; l_return_value := '-1';
    Hr_Utility.set_location(' l_return_value: '||l_return_value, 89);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    return null;
END Evaluate_SubHeader_Formula;

-- =============================================================================
-- ~ Evaluate_SubPosition_Formula:
-- =============================================================================
FUNCTION Evaluate_SubPosition_Formula
        (p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2
         )
         RETURN VARCHAR2 AS
   l_return_value           varchar2(150) := null;
   l_proc_name  constant    varchar2(250) := g_proc_name ||'Evaluate_SubPosition_Formula';
   l_pa_request_id          number;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   p_error_code:= '0'; p_msg_type := '0'; p_error_message:= '0';
   --Checking whether person exist for sub position or not
   --If person exist then we don't require to extract this position.
   --If pasing "Found" to the Person Occupancy and
   -- removing this record after grouping done in post process
   IF p_indicator = 'I' AND g_person_exist = 'Y' THEN
      IF p_attribute_name = 'Person Occupancy' THEN
         l_return_value := 'FOUND';
      ELSIF p_attribute_name = 'Positon ID' THEN
         l_return_value := g_position_id;
      ELSE
         l_return_value := null;
      END IF;
   ELSE
      IF p_attribute_name = 'Person Occupancy' OR p_attribute_name = 'IncumbentSSN' THEN
        l_return_value := null;
      ELSE
         l_return_value :=Get_Interface_Attribute_Value(p_indicator
                                                      ,p_attribute_name,0);
      END IF;
   END IF;
   Hr_Utility.set_location('l_return_value: '||l_return_value, 80);
   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message := sqlerrm;
    p_msg_type     := 'E'; p_error_code    := sqlcode; l_return_value := '-1';
    Hr_Utility.set_location(' l_return_value: '||l_return_value, 89);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    return null;
END Evaluate_SubPosition_Formula;

-- =============================================================================
-- ~ Evaluate_Detail_Rcd_Formula:
-- =============================================================================
FUNCTION Evaluate_Detail_Rcd_Formula
        (p_assignment_id       IN         NUMBER
        ,p_business_group_id   IN         NUMBER
 	,p_indicator         in varchar2
        ,p_attribute_name    in varchar2
        ,p_msg_type          in out NoCopy varchar2
        ,p_error_code        in out NoCopy varchar2
        ,p_error_message     in out NoCopy varchar2) RETURN VARCHAR2 AS

   l_return_value           varchar2(150) := null;
   l_proc_name  constant    varchar2(250) := g_proc_name ||'Evaluate_SubPosition_Formula';
   l_pa_request_id          number;

BEGIN
   Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   p_error_code:= '0'; p_msg_type := '0'; p_error_message:= '0';

   l_return_value :=Get_Interface_Attribute_Value(p_indicator,p_attribute_name,0);

   Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
   RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    p_error_message := sqlerrm;
    p_msg_type     := 'E'; p_error_code    := sqlcode; l_return_value := '-1';
    Hr_Utility.set_location(' l_return_value: '||l_return_value, 89);
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    return null;
END Evaluate_Detail_Rcd_Formula;
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

   CURSOR csr_jcl_req_params( c_req_id IN NUMBER) IS
     SELECT argument4, --Business Group ID
            argument5, --User ID
	    argument6, --dept Code
	    argument7, --Agency Code
	    argument8 --POI
       FROM fnd_concurrent_requests
      WHERE request_id = c_req_id;

  l_proc_name     VARCHAR2(150) := g_proc_name ||'.Get_NFC_ConcProg_Information';
  l_return_value  VARCHAR2(1000);
  i               per_all_assignments_f.business_group_id%TYPE;
  l_period_num    per_time_periods.period_num%TYPE;
  l_ext_rslt_id   ben_ext_rslt.ext_rslt_id%TYPE;
  l_ext_dfn_id    ben_ext_dfn.ext_dfn_id%TYPE;
  l_conc_reqest_id ben_ext_rslt.request_id%TYPE;
  l_position_id   NUMBER;
  l_start_date    DATE;
  l_end_date      DATE;

BEGIN
   Hr_Utility.set_location('Entering :'||l_proc_name, 5);

   i := g_business_group_id;
   l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;
   l_ext_dfn_id  := ben_ext_thread.g_ext_dfn_id;

   IF NOT g_extract_params.EXISTS(i) THEN
      -- Get the Conc. request id to get the params
      OPEN  csr_jcl_org_req(c_ext_rslt_id  => l_ext_rslt_id
                           ,c_ext_dfn_id   => l_ext_dfn_id );
      FETCH csr_jcl_org_req INTO l_conc_reqest_id;
      CLOSE csr_jcl_org_req;

      Hr_Utility.set_location('l_conc_reqest_id: '||l_conc_reqest_id, 5);

      -- Get the params. based on the conc. request id.
      OPEN  csr_jcl_req_params(c_req_id  => l_conc_reqest_id);
      FETCH csr_jcl_req_params INTO i,g_user_id,g_dept_code,g_agency_code,g_poi;
      CLOSE csr_jcl_req_params;

      Hr_Utility.set_location('..Stored the Conc. Program parameters', 17);
   END IF;

   IF p_header_type = 'AGENCY_CODE' THEN
        l_return_value := g_extract_params(i).agency_code;
   ELSIF p_header_type = 'PERSONNEL_OFFICE_ID' THEN
       l_return_value := g_extract_params(i).personnel_office_id;
   ELSIF p_header_type = 'TRANSMISSION_INDICATOR' THEN
       l_return_value := g_extract_params(i).transmission_indicator;
   ELSIF p_header_type = 'SIGNON_IDENTIFICATION' THEN
       l_return_value := g_extract_params(i).signon_identification;
   ELSIF p_header_type = 'USER_ID' THEN
       l_return_value := g_user_id;
   ELSIF p_header_type = 'DEPT_CODE' THEN
       l_return_value := g_dept_code;
   ELSIF p_header_type = 'AGENCY_CODE_JCL' THEN
       l_return_value := g_agency_code;
   ELSIF p_header_type = 'PERSONEL_OFFICE_ID_JCL' THEN
       l_return_value := g_poi;
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
   hr_utility.set_location('Leaving: '||l_proc_name, 45);
  RETURN l_return_value;
EXCEPTION
  WHEN Others THEN
     p_error_message :='SQL-ERRM :'||SQLERRM;
     hr_utility.set_location('Leaving: '||l_proc_name, 45);
     RETURN l_return_value;
END Get_NFC_ConcProg_Information;

-- ====================================================================
-- ~ Del_Post_Process_Recs : Delete all the records created as part
-- ~ of hidden record as they are not required.
-- ====================================================================
FUNCTION Del_Post_Process_Recs
          (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
          )RETURN NUMBER IS

CURSOR  csr_error_poi_id IS
 SELECT POSITION_ID,
        susp_function_cd,
	record_id,
	result_dtl_id,
	result_id
   FROM ghr_pos_interface_err_dtls;

CURSOR csr_chk_err_position
                   (c_position_id     IN NUMBER
                   ,c_ext_rslt_id     IN Number
                   ,c_ext_dtl_rcd_id  IN Number) IS
SELECT dtl.ext_rslt_dtl_id
      ,dtl.val_45 --Detail function code
      ,dtl.val_26 --Open Position function code
  FROM ben_ext_rslt_dtl dtl
 WHERE dtl.ext_rslt_id = c_ext_rslt_id
   AND dtl.VAL_71      = c_position_id
   AND dtl.ext_rcd_id  = c_ext_dtl_rcd_id;

 CURSOR csr_get_record_count(c_ext_rcd_id IN NUMBER) IS
   SELECT Count(dtl.ext_rslt_dtl_id)
     FROM ben_ext_rslt_dtl dtl
    WHERE dtl.ext_rslt_id = Ben_Ext_Thread.g_ext_rslt_id
    AND dtl.ext_rcd_id NOT IN(c_ext_rcd_id);


  CURSOR csr_get_correction_pos(c_ext_rcd_id        IN NUMBER
                               ,c_ext_rslt_id       IN Number
			       ,c_business_group_id IN VARCHAR2
  	                       ,c_effective_date    IN VARCHAR2 ) IS
  select distinct paf.position_id
    from per_all_assignments_f paf
        ,ben_ext_rslt_dtl dtl
   where dtl.val_71 = paf.position_id
     and paf.business_group_id = c_business_group_id
     and paf.business_group_id = dtl.business_group_id
     and paf.person_id         = dtl.person_id
     and dtl.ext_rslt_id       = c_ext_rslt_id
     and dtl.VAL_45      = 'C'
     and dtl.ext_rcd_id  = c_ext_rcd_id
     and dtl.VAL_49 is not null
     and paf.effective_start_date = c_effective_date;

CURSOR csr_rslt_dtl_sort(c_ext_rslt_id    IN Number
                        ,c_ext_dfn_id     IN Number  ) IS
   SELECT dtl.*
     FROM ben_ext_rcd         rcd
         ,ben_ext_rcd_in_file rin
         ,ben_ext_dfn dfn
         ,ben_ext_rslt_dtl dtl
    WHERE dfn.ext_dfn_id   = c_ext_dfn_id
      AND rin.ext_file_id  = dfn.ext_file_id
      AND rin.hide_flag    = 'N'     -- Y=Hidden, N=Not Hidden
      AND rin.ext_rcd_id   = rcd.ext_rcd_id
      AND rcd.rcd_type_cd  in ('S','D')
      AND rcd.ext_rcd_id  = dtl.ext_rcd_id
      and dtl.ext_rslt_id = c_ext_rslt_id
      ORDER BY dtl.val_02 desc;


l_ext_dtl_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE;
l_ext_main_rcd_id   ben_ext_rcd.ext_rcd_id%TYPE;
l_proc_name         VARCHAR2(150):=  g_proc_name||'Del_Post_Process_Recs';
l_return_value      NUMBER := 0; --0= Sucess, -1=Error
l_ext_rslt_id       ben_ext_rslt.ext_rslt_id%TYPE;
l_ext_dfn_id        ben_ext_dfn.ext_dfn_id%TYPE;
i_count             NUMBER;
l_main_rec          csr_rslt_dtl%ROWTYPE;
l_val_tab           ValTabTyp;
l_ext_position_id   NUMBER;
l_ext_rslt_dtl_id   ben_ext_rslt_dtl.ext_rslt_dtl_id%TYPE;
l_conc_reqest_id    ben_ext_rslt.request_id%TYPE;
l_err_position_id   ghr_pos_interface_err_dtls.POSITION_ID%TYPE;
l_err_fuction_code  ghr_pos_interface_err_dtls.susp_function_cd%TYPE;
l_rcd_function_code varchar(2);
l_sh_function_code  varchar(2);
l_result_dtl_id     ben_ext_rslt_dtl.ext_rslt_dtl_id%TYPE;
l_rslt_dtl_id       NUMBER;
l_record_count Number  := 0;
l_rc           VARCHAR2(8);
sort_val            Number :=1;
l_sort_val          Varchar2(15);
l_new_rec          csr_rslt_dtl%ROWTYPE;

BEGIN
  Hr_Utility.set_location('Entering :'||l_proc_name, 5);
  l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;
  l_ext_dfn_id  := ben_ext_thread.g_ext_dfn_id;
  --Getting the detail record id
  FOR csr_rcd_rec IN csr_ext_rcd_id(c_hide_flag   => 'N' -- N=No Y=Yes
 	                           ,c_rcd_type_cd => 'D')-- D=Detail, T=Total, H-Header
   LOOP
      g_ext_dtl_rcd_id := csr_rcd_rec.ext_rcd_id;
      Hr_Utility.set_location('Detail record ID :'||g_ext_dtl_rcd_id, 5);

      --Get all position Id's whose FuntionCode is "A" and the Incumbent SSN is not Null
      --Then update this entire row into the second subheader and make Incumbent SSN as NULL
      FOR csr_rcd_position_id IN csr_rcd_position_ids
                                    (c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
				    ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id)
      LOOP
          l_ext_position_id := csr_rcd_position_id.val_71;
	  Hr_Utility.set_location('Detail Position ID whose SSN is null :'||l_ext_position_id, 5);
          OPEN csr_rslt_dtl
                (c_position_id    => l_ext_position_id
   	        ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id);
          FETCH csr_rslt_dtl INTO l_main_rec;
          CLOSE csr_rslt_dtl;
          l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
	  --Get the sub header ext_rslt_dtl_id for this position
	  --Because this position record already exist in SH with all null values
	  OPEN csr_rslt_dtl_id
                (c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
		,c_ext_hide_flag     => 'N'
		,c_rcd_type_cd       => 'S'
  		,c_position_id       => l_ext_position_id
                ,c_business_group_id => p_business_group_id);
          FETCH csr_rslt_dtl_id INTO l_ext_rslt_dtl_id;
          CLOSE csr_rslt_dtl_id;
          Hr_Utility.set_location('l_ext_rslt_dtl_id :'||l_ext_rslt_dtl_id, 5);
	  Copy_Rec_Values(p_rslt_rec   => l_main_rec
	 	         ,p_val_tab    => l_val_tab);
 	  l_main_rec.ext_rslt_dtl_id := l_ext_rslt_dtl_id;
	  --Making Incumbent SSN as Null
	  l_val_tab(49) := null;
          Upd_Rslt_Dtl(p_dtl_rec  => l_main_rec
	   	      ,p_val_tab  => l_val_tab);
	  -- then delete it from detail record
          DELETE
            FROM ben_ext_rslt_dtl
           WHERE ext_rcd_id        = g_ext_dtl_rcd_id
             AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
             AND business_group_id = p_business_group_id
             AND val_71 = l_ext_position_id;
      END LOOP;
      --Get all position Id's whose FuntionCode is "C" and the Incumbent SSN is not Null
      --and position is allocated in same date
      --Then update this entire row into the second subheader and make Incumbent SSN as NULL
        FOR csr_get_correction_pos_id IN csr_get_correction_pos
                                    (c_ext_rcd_id    => g_ext_dtl_rcd_id
				    ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
				    ,c_business_group_id => p_business_group_id
				    ,c_effective_date    => g_extract_params(p_business_group_id).to_date)
        LOOP
	  l_ext_position_id := csr_get_correction_pos_id.position_id;
	  Hr_Utility.set_location('Detail Position ID whose SSN is null :'||l_ext_position_id, 5);
          OPEN csr_rslt_dtl
                (c_position_id    => l_ext_position_id
   	        ,c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
                ,c_ext_dtl_rcd_id => g_ext_dtl_rcd_id);
          FETCH csr_rslt_dtl INTO l_main_rec;
          CLOSE csr_rslt_dtl;
          l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
	  --Get the sub header ext_rslt_dtl_id for this position
	  --Because this position record already exist in SH with all null values
	  OPEN csr_rslt_dtl_id
                (c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
		,c_ext_hide_flag     => 'N'
		,c_rcd_type_cd       => 'S'
  		,c_position_id       => l_ext_position_id
                ,c_business_group_id => p_business_group_id);
          FETCH csr_rslt_dtl_id INTO l_ext_rslt_dtl_id;
          CLOSE csr_rslt_dtl_id;
          Hr_Utility.set_location('l_ext_rslt_dtl_id :'||l_ext_rslt_dtl_id, 5);
	  Copy_Rec_Values(p_rslt_rec   => l_main_rec
	 	         ,p_val_tab    => l_val_tab);
 	  l_main_rec.ext_rslt_dtl_id := l_ext_rslt_dtl_id;
	  --Making Incumbent SSN as Null
	  l_val_tab(49) := null;
          Upd_Rslt_Dtl(p_dtl_rec  => l_main_rec
	   	      ,p_val_tab  => l_val_tab);
	  -- then delete it from detail record
          DELETE
            FROM ben_ext_rslt_dtl
           WHERE ext_rcd_id        = g_ext_dtl_rcd_id
             AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
             AND business_group_id = p_business_group_id
             AND val_71 = l_ext_position_id;
      END LOOP;

   END LOOP;

  -- Get the record id for the  Detail record Ids
  FOR csr_rcd_rec_t IN csr_ext_rcd_id(c_hide_flag   => 'N' -- Y=Record is hidden one
                                     ,c_rcd_type_cd => 'S') --Sub Header
  -- Loop through each detail record for the extract
  LOOP
    -- Delete all rows where the val_52 hidden field value is Found.
    DELETE
      FROM ben_ext_rslt_dtl
     WHERE ext_rcd_id        = csr_rcd_rec_t.ext_rcd_id
       AND ext_rslt_id       = Ben_Ext_Thread.g_ext_rslt_id
       AND business_group_id = p_business_group_id
       AND val_52 = 'FOUND';

  END LOOP;

  Hr_Utility.set_location('Handling Total Record count ', 5);
  --Handling Total Record Count,removing the header count from total
  FOR csr_header_rcd_id IN csr_ext_rcd_id(c_hide_flag => 'N' -- Y=Record is hidden one
                                     ,c_rcd_type_cd   => 'H') --Header
  LOOP
       OPEN csr_get_record_count(c_ext_rcd_id =>csr_header_rcd_id.ext_rcd_id);
       FETCH csr_get_record_count INTO l_record_count;
       CLOSE csr_get_record_count;

       Hr_Utility.set_location('Handling Total Record count ' ||csr_header_rcd_id.ext_rcd_id, 5);
       l_rc :=l_record_count;
       UPDATE ben_ext_rslt_dtl set val_06 = LPAD(l_rc,8,'0')
        WHERE ext_rcd_id       = csr_header_rcd_id.ext_rcd_id
          AND ext_rslt_id      = Ben_Ext_Thread.g_ext_rslt_id
          AND business_group_id= p_business_group_id;

  END LOOP;

  Hr_Utility.set_location('Handling Notifications ', 5);

  --Notifications
  OPEN  csr_org_req(c_ext_rslt_id       => l_ext_rslt_id
                   ,c_ext_dfn_id        => l_ext_dfn_id
                   ,c_business_group_id => p_business_group_id);
  FETCH csr_org_req INTO l_conc_reqest_id;
  CLOSE csr_org_req;

  GHR_WF.initiate_notification (p_request_id =>l_conc_reqest_id
                               ,p_result_id  =>Ben_Ext_Thread.g_ext_rslt_id
                               ,p_role       =>g_extract_params(p_business_group_id).notify
                               );
  ghr_nfc_error_proc.chk_for_err_data_pos (p_request_id =>l_conc_reqest_id
                                          ,p_rslt_id    =>Ben_Ext_Thread.g_ext_rslt_id);

  --Get all subheader and details record ids
  --then update the record id
  Hr_Utility.set_location('Sort value Logic starts here', 5);
  Hr_Utility.set_location('Sort Result ID'||Ben_Ext_Thread.g_ext_rslt_id, 5);
  FOR ind_dtl IN csr_rslt_dtl_sort
		      (c_ext_rslt_id    => Ben_Ext_Thread.g_ext_rslt_id
		      ,c_ext_dfn_id     => l_ext_dfn_id  )
  LOOP
    l_main_rec :=  ind_dtl;
    l_main_rec.object_version_NUMBER := Nvl(l_main_rec.object_version_NUMBER,0) + 1;
    l_new_rec := l_main_rec;

    Hr_Utility.set_location('l_main_rec.val_02--'||l_main_rec.val_02, 5);
    l_sort_val:= Lpad(sort_val,15,0);
    l_new_rec.prmy_sort_val := l_main_rec.val_02||l_sort_val;
    sort_val :=sort_val+1;


    IF l_main_rec.val_02 = '2055'  THEN
        UPDATE ben_ext_rslt_dtl set PRMY_SORT_VAL = l_new_rec.prmy_sort_val
               ,group_val_01 = '   '
         WHERE ext_rcd_id       = l_main_rec.ext_rcd_id
           AND ext_rslt_id      = Ben_Ext_Thread.g_ext_rslt_id
           AND ext_rslt_dtl_id  = l_main_rec.ext_rslt_dtl_id
           AND business_group_id= p_business_group_id;
    ELSE
        UPDATE ben_ext_rslt_dtl set PRMY_SORT_VAL = l_new_rec.prmy_sort_val
         WHERE ext_rcd_id       = l_main_rec.ext_rcd_id
           AND ext_rslt_id      = Ben_Ext_Thread.g_ext_rslt_id
           AND ext_rslt_dtl_id  = l_main_rec.ext_rslt_dtl_id
           AND business_group_id= p_business_group_id;
    END IF;


    Hr_Utility.set_location('l_sort_val--'||l_sort_val, 5);
    Hr_Utility.set_location('Sort l_new_rec.prmy_sort_val'||l_new_rec.prmy_sort_val, 5);


  END LOOP;

  hr_utility.set_location('Leaving :'||l_proc_name, 25);
  RETURN l_return_value;
EXCEPTION
   WHEN Others THEN
    hr_utility.set_location('Error Leaving :'||l_proc_name, 25);
    RETURN -1;
END Del_Post_Process_Recs;

END GHR_NFC_POSITION_EXTRACTS;

/
