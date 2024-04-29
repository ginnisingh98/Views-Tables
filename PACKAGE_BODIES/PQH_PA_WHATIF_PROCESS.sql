--------------------------------------------------------
--  DDL for Package Body PQH_PA_WHATIF_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PA_WHATIF_PROCESS" AS
/* $Header: pqwifswi.pkb 120.2.12010000.4 2008/11/06 21:02:28 sagnanas ship $ */

TYPE hierarchy_tab IS TABLE OF pqh_pa_whatif_results%ROWTYPE INDEX BY BINARY_INTEGER;

g_hierarchy hierarchy_tab;

g_debug   boolean      := hr_utility.debug_enabled;
g_package varchar2(72) := 'pqh_pa_whatif_process';
g_role_id  number :=-1;
g_effective_date DATE;
-----------------------------------------------------------------------------------------------
FUNCTION get_uom ( p_uom            IN VARCHAR2
                  ,p_nnmntry_uom    IN VARCHAR2
                  ,p_effective_date IN DATE)
RETURN VARCHAR2 IS
--
 CURSOR csr_get_uom ( p_uom VARCHAR2, p_effective_date DATE ) IS
  SELECT name
    FROM fnd_currencies_vl
   WHERE currency_code = p_uom
     AND enabled_flag = 'Y'
     AND p_effective_date BETWEEN nvl(start_date_active,p_effective_date) AND nvl(end_date_active,p_effective_date);

 CURSOR csr_get_nnmntry_uom ( p_nnmntry_uom VARCHAR2, p_effective_date DATE ) IS
  SELECT meaning
    FROM hr_lookups
   WHERE lookup_type= 'BEN_NNMNTRY_UOM'
     AND lookup_code=p_nnmntry_uom
     AND enabled_flag = 'Y'
     AND p_effective_date BETWEEN nvl(start_date_active,p_effective_date) AND nvl(end_date_active,p_effective_date);
--
l_proc     varchar2(72);
l_uom_name fnd_currencies_tl.name%TYPE;
--
BEGIN
--
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    l_proc := g_package || 'get_uom';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;
  IF p_nnmntry_uom is not null THEN
   OPEN  csr_get_nnmntry_uom(p_nnmntry_uom => p_nnmntry_uom, p_effective_date => p_effective_date);
   FETCH csr_get_nnmntry_uom INTO l_uom_name;
   CLOSE csr_get_nnmntry_uom;
   if g_debug then
            hr_utility.set_location('Non Monetary UOM: ' || l_uom_name,15);
   end if;
  ELSE
   OPEN csr_get_uom(p_uom => p_uom, p_effective_date => p_effective_date);
   FETCH csr_get_uom INTO l_uom_name;
   CLOSE csr_get_uom;
   if g_debug then
    hr_utility.set_location('Monetary UOM: ' || l_uom_name,15);
   end if;
  END IF;
  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

 RETURN l_uom_name;

END get_uom;

-----------------------------------------------------------------------------------------------

FUNCTION chk_potential_life_events( p_person_id         IN NUMBER
                                   ,p_business_group_id IN NUMBER
                                   ,p_lf_evt_ocrd_dt   OUT NOCOPY DATE)
RETURN VARCHAR2 IS
--
 CURSOR csr_chk_ptnl_ler(p_person_id NUMBER, p_business_group_id NUMBER) IS
    SELECT lf_evt_ocrd_dt
      FROM ben_ptnl_ler_for_per ptn
     WHERE ptn.person_id          =  p_person_id
       AND ptn.business_group_id  =  p_business_group_id
       AND ptn.ler_id IN ( SELECT ler_id FROM ben_ler_f ler WHERE ler.typ_cd NOT IN ('COMP','SCHEDDU','SCHEDDO'))
       AND ptn.ptnl_ler_for_per_stat_cd NOT IN('VOIDD','PROCD');
--
l_exists VARCHAR2(2) := 'N';
l_lf_evt_ocrd_dt DATE;
l_proc   VARCHAR2(72);
--
BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_potential_life_events';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  OPEN csr_chk_ptnl_ler(p_person_id => p_person_id, p_business_group_id => p_business_group_id);
 FETCH csr_chk_ptnl_ler INTO l_lf_evt_ocrd_dt;
 CLOSE csr_chk_ptnl_ler;

 IF (l_lf_evt_ocrd_dt IS NOT NULL) THEN
      p_lf_evt_ocrd_dt  := l_lf_evt_ocrd_dt;
      l_exists := 'Y';
 END IF;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

 RETURN l_exists;
--
END chk_potential_life_events;
-----------------------------------------------------------------------------------------------
--SSBEN: Function to check if data changes resulted in conflicting LE's
-----------------------------------------------------------------------------------------------
FUNCTION chk_conflict_life_events( p_person_id         IN        NUMBER
                                  ,p_business_group_id IN        NUMBER
                                  ,p_effective_date    IN        DATE
                                  ,p_flag             OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
--
CURSOR csr_chk_cnflt_ler IS
SELECT ptn.ler_id,ler.name,ler.ovridg_le_flag
  FROM ben_ptnl_ler_for_per ptn,
       ben_ler_f            ler
  WHERE    ptn.person_id          =  p_person_id
       AND ptn.business_group_id  =  p_business_group_id
       AND ptn.ler_id             =ler.ler_id
       AND p_effective_date between ler.effective_start_date and effective_end_date
       AND ler.typ_cd NOT IN ('COMP','SCHEDDU','SCHEDDO')
       AND ptn.ptnl_ler_for_per_stat_cd NOT IN('VOIDD','PROCD');
--
l_proc                VARCHAR2(72);
l_counter             NUMBER  := 1;
l_ovridg_le_count     NUMBER  :=0;
l_non_ovridg_le_count NUMBER  :=0;
l_ret_status          BOOLEAN :=false;
--
BEGIN
--
  if g_debug then
    l_proc := g_package || '.chk_conflict_life_events';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;
g_hierarchy.DELETE;

FOR ler_rec IN csr_chk_cnflt_ler LOOP
if g_debug then
    hr_utility.set_location('Detected Le :' ||ler_rec.name|| to_char(ler_rec.ler_id)||ler_rec.ovridg_le_flag,20);

 end if;
 g_hierarchy(l_counter).ler_id         := ler_rec.ler_id;
 g_hierarchy(l_counter).name           := ler_rec.name;
 g_hierarchy(l_counter).hierarchy_type :=ler_rec.ovridg_le_flag;
 l_counter:=l_counter+1;
 IF ler_rec.ovridg_le_flag='N' THEN l_non_ovridg_le_count :=l_non_ovridg_le_count +1;
 ELSIF ler_rec.ovridg_le_flag='Y' THEN l_ovridg_le_count :=l_ovridg_le_count +1;
 END IF;
 END LOOP;

 if g_debug then
    hr_utility.set_location('Number of OVERRDG LE triggered: ' || to_char(l_ovridg_le_count),30);
    hr_utility.set_location('Number of non OVERRDG LE triggered: ' || to_char(l_non_ovridg_le_count),35);
    hr_utility.set_location('Leaving: ' || l_proc,40);
 end if;
IF l_ovridg_le_count+l_non_ovridg_le_count=0 THEN
   fnd_message.set_name('BEN','BEN_92540_NOONE_TO_PROCESS_CM');
   fnd_message.raise_error;
END IF;
IF    l_ovridg_le_count >1  THEN l_ret_status :=true ;p_flag :='Y';
ELSIF l_ovridg_le_count =0  AND l_non_ovridg_le_count>1 THEN l_ret_status :=true ;p_flag :='N';
END IF;
RETURN l_ret_status;
--
END chk_conflict_life_events;
--------------------------------------------------------------------------------------------------------------

PROCEDURE void_potential_life_events(
   p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  )
IS
--
 l_proc VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'void_potential_life_events';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  UPDATE ben_ptnl_ler_for_per
     SET ptnl_ler_for_per_stat_cd = 'VOIDD'
   WHERE person_id =  p_person_id
     AND business_group_id = p_business_group_id
     AND ler_id in ( select ler_id from ben_ler_f ler where ler.typ_cd NOT IN ('COMP','SCHEDDU','SCHEDDO'))
     AND lf_evt_ocrd_dt <= p_effective_date
     AND ptnl_ler_for_per_stat_cd IN ('UNPROCD', 'DTCTD');  -- 5763776 Removed 'PROCD'. Should not require this.

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END void_potential_life_events;
-----------------------------------------------------------------------------------------------
PROCEDURE void_active_life_events(
   p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  )
IS
--
 l_proc VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'void_active_life_events';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  UPDATE ben_per_in_ler
     SET per_in_ler_stat_cd = 'VOIDD'
        ,voidd_dt = p_effective_date
   WHERE person_id         = p_person_id
     AND business_group_id = p_business_group_id
     AND ler_id in ( select ler_id from ben_ler_f ler where ler.typ_cd NOT IN ('COMP','SCHEDDU','SCHEDDO'))
     AND per_in_ler_stat_cd = 'STRTD';

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END void_active_life_events;
-----------------------------------------------------------------------------------------------

PROCEDURE void_conflict_life_events(
   p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_winning_ler_id                 in  number
  ,p_effective_date                 in  date
  )
IS
--
 l_proc VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || '.void_conflict_life_events';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  UPDATE ben_ptnl_ler_for_per
     SET ptnl_ler_for_per_stat_cd = 'VOIDD'
   WHERE person_id =  p_person_id
     AND business_group_id = p_business_group_id
     AND ler_id in ( select ler_id from ben_ler_f ler where ler.typ_cd NOT IN ('COMP','SCHEDDU','SCHEDDO')
                     and ler.ler_id <> p_winning_ler_id)
     AND lf_evt_ocrd_dt <= p_effective_date
     AND ptnl_ler_for_per_stat_cd IN ('UNPROCD', 'DTCTD');

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END void_conflict_life_events;
-----------------------------------------------------------------------------------------------
PROCEDURE process_api_call(p_transaction_step_id  in number
                          ,p_api_name             in varchar2
                          )
IS
 l_sqlstr              varchar2(1000);
 l_proc                VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'process_api_call';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

l_sqlstr := 'BEGIN '||
             p_api_name ||
            '(p_transaction_step_id => :transaction_step_id);'||
            'END;';
EXECUTE IMMEDIATE l_sqlstr USING p_transaction_step_id;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END process_api_call;

-----------------------------------------------------------------------------------------------
PROCEDURE post_data_changes(p_transaction_id in number
                           ,p_effective_date in date
                           ,p_person_id         OUT NOCOPY number
                           ,p_business_group_id OUT NOCOPY number
                           )
IS
--
  Cursor csr_trs is
    select trs.transaction_step_id
          ,trs.api_name
    from   hr_api_transaction_steps trs
    where  trs.transaction_id = p_transaction_id
      and  trs.object_type is null
      and  trs.api_name not in ('BEN_PROCESS_COMPENSATION_W.PROCESS_API')
    order by trs.processing_order, trs.transaction_step_id;
--
 l_proc VARCHAR2(72);
 l_return_status varchar2(10);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'post_data_changes';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  -- select each transaction steps to process

  -- Call SWI's commit Transaction
      l_return_status :=hr_transaction_swi.commit_transaction
                         (p_transaction_id => p_transaction_id
                         ,p_effective_date => p_effective_date);

  FOR csr_rec IN csr_trs LOOP
      -- call the API for the transaction step
      process_api_call
        (p_transaction_step_id => csr_rec.transaction_step_id
        ,p_api_name            => csr_rec.api_name);

      IF (csr_rec.api_name = 'HR_PROCESS_PERSON_SS.PROCESS_API') THEN
       BEGIN
        IF ((hr_process_person_ss.g_person_id IS NOT NULL) AND
           (hr_process_person_ss.g_session_id = ICX_SEC.G_SESSION_ID)) THEN
           p_person_id := hr_process_person_ss.g_person_id;
        END IF;
        p_business_group_id := hr_transaction_api.get_number_value(
                                             p_transaction_step_id => csr_rec.transaction_step_id
                                            ,p_name                => 'P_BUSINESS_GROUP_ID');
      END;
     END IF;

  END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END post_data_changes;
-----------------------------------------------------------------------------------------------
-- SSBEN : Method to post the selected data changes
-----------------------------------------------------------------------------------------------
FUNCTION p_get_lf_evt_ocrd_dt(p_date in date,
                              p_uom in varchar2, p_value in number)
RETURN date  IS
      p_ret_date date;
BEGIN
--
if p_uom = 'DY' then
   p_ret_date := p_date + p_value;
elsif p_uom = 'MO' then
   p_ret_date := add_months(p_date, p_value);
else -- if p_uom = 'YR' then
   p_ret_date := add_months(p_date, p_value*12);
end if;

return p_ret_date;
--
END p_get_lf_evt_ocrd_dt;

FUNCTION p_min_dt(p_date in date,
                  p_date1 in date)
RETURN date  IS
   p_ret_date date;
BEGIN
   --
   if p_date >p_date1 then
      p_ret_date := p_date1;
   else
      p_ret_date := p_date;
   end if;

   return p_ret_date;
   --
END p_min_dt;

PROCEDURE post_ben_changes(p_transaction_id        IN        NUMBER
                          ,p_person_id             IN        NUMBER
                          ,p_business_group_id     IN        NUMBER
                          ,p_effective_date        IN        DATE
	                  ,p_session_date          IN        DATE
	                  ,p_lf_evt_ocrd_dt       OUT NOCOPY DATE
                          )
IS
Cursor csr_trs is
select transaction_step_id
      ,api_name
from   hr_api_transaction_steps
where  transaction_id = p_transaction_id
       order by transaction_step_id, api_name;

Cursor csr_trs_values(c_transaction_step_id in NUMBER) is
select  datatype
       ,name
       ,varchar2_value
       ,number_value
       ,date_value
from   hr_api_transaction_values
where  transaction_step_id = c_transaction_step_id
       order by transaction_value_id, datatype;

Cursor c_ler (p_typ_cd in varchar2) is
select ler.ler_id
from   ben_ler_f ler
where  ler.typ_cd = p_typ_cd
and    ler.business_group_id  = p_business_group_id
and    p_effective_date between
      ler.effective_start_date and ler.effective_end_date;

Cursor c_person_data is
select date_of_birth,original_date_of_hire hire_date
from   per_all_people_f
where  person_id = p_person_id
and    business_group_id  = p_business_group_id
and    p_effective_date between
       effective_start_date and effective_end_date;

Cursor csr_uom(c_lookup_cd VARCHAR2) IS
Select meaning
From hr_lookups
Where lookup_code=c_lookup_cd
and lookup_type='BEN_TM_UOM';
         --------------------Variables------------------
l_proc                  VARCHAR2(72);
l_field_val             varchar2(500);
--
-- Columns for table PER_ASSIGNMENT_BUDGET_VALUES_F
--
l_ASSIGNMENT_BUDGET_VALUE_ID     number;
l_VALUE                          number;
--
-- Columns for table BEN_CRT_ORDR
--
l_CRT_ORDR_TYP_CD                varchar2(60);
l_APLS_PERD_STRTG_DT             date;
l_APLS_PERD_ENDG_DT              date;
l_pl_id                          number;
--
-- Columns for table BEN_PER_BNFTS_BAL_F
--
l_VAL                            NUMBER;
l_BNFTS_BAL_ID                   NUMBER;
l_effective_start_date           date;
l_effective_end_date             date;
--
-- Columns for table PER_ABSENCE_ATTENDANCES
--
l_ABSENCE_ATTENDANCE_TYPE_ID     varchar2(60);
l_ABS_ATTENDANCE_REASON_ID       varchar2(60);
l_DATE_END                       varchar2(60);
l_DATE_START                     varchar2(60);
--
-- Columns for table PER_ADDRESSES
--
l_POSTAL_CODE                    varchar2(60);
l_PRIMARY_FLAG                   varchar2(60);
l_DATE_FROM                      varchar2(60);
l_DATE_TO                        varchar2(60);
-- UTF8 changes
-- l_REGION_2                       varchar2(60);
l_REGION_2                       varchar2(120);
l_ADDRESS_TYPE                   varchar2(60);

--
-- Columns for table PER_ALL_ASSIGNMENTS_F
--
l_PAY_BASIS_ID                   number;
l_EMPLOYMENT_CATEGORY            varchar2(60);
l_LABOUR_UNION_MEMBER_FLAG       varchar2(60);
l_JOB_ID                         number;
l_PAYROLL_ID                     number;
l_PRIMARY_FLAG1                  varchar2(60);
l_LOCATION_ID                    number;
l_CHANGE_REASON                  varchar2(60);
l_ASSIGNMENT_TYPE                varchar2(60);
l_ORGANIZATION_ID                number;
l_POSITION_ID                    number;
l_BARGAINING_UNIT_CODE           varchar2(60);
l_NORMAL_HOURS                   number;
l_FREQUENCY                      varchar2(60);
l_ASSIGNMENT_STATUS_TYPE_ID      number;
l_GRADE_ID                       number;
l_PEOPLE_GROUP_ID            NUMBER;
l_HOURLY_SALARIED_CODE	   varchar2(30);
l_ASS_ATTRIBUTE_CATEGORY	   varchar2(30);
l_ASS_ATTRIBUTE1             VARCHAR2(150);
l_ASS_ATTRIBUTE10            VARCHAR2(150);
l_ASS_ATTRIBUTE11            VARCHAR2(150);
l_ASS_ATTRIBUTE12            VARCHAR2(150);
l_ASS_ATTRIBUTE13            VARCHAR2(150);
l_ASS_ATTRIBUTE14            VARCHAR2(150);
l_ASS_ATTRIBUTE15            VARCHAR2(150);
l_ASS_ATTRIBUTE16            VARCHAR2(150);
l_ASS_ATTRIBUTE17            VARCHAR2(150);
l_ASS_ATTRIBUTE18            VARCHAR2(150);
l_ASS_ATTRIBUTE19            VARCHAR2(150);
l_ASS_ATTRIBUTE2            VARCHAR2(150);
l_ASS_ATTRIBUTE20            VARCHAR2(150);
l_ASS_ATTRIBUTE21            VARCHAR2(150);
l_ASS_ATTRIBUTE22            VARCHAR2(150);
l_ASS_ATTRIBUTE23            VARCHAR2(150);
l_ASS_ATTRIBUTE24            VARCHAR2(150);
l_ASS_ATTRIBUTE25            VARCHAR2(150);
l_ASS_ATTRIBUTE26            VARCHAR2(150);
l_ASS_ATTRIBUTE27            VARCHAR2(150);
l_ASS_ATTRIBUTE28            VARCHAR2(150);
l_ASS_ATTRIBUTE29            VARCHAR2(150);
l_ASS_ATTRIBUTE3            VARCHAR2(150);
l_ASS_ATTRIBUTE30            VARCHAR2(150);
l_ASS_ATTRIBUTE4            VARCHAR2(150);
l_ASS_ATTRIBUTE5            VARCHAR2(150);
l_ASS_ATTRIBUTE6            VARCHAR2(150);
l_ASS_ATTRIBUTE7            VARCHAR2(150);
l_ASS_ATTRIBUTE8            VARCHAR2(150);
l_ASS_ATTRIBUTE9            VARCHAR2(150);

--
-- Columns for table PER_ALL_PEOPLE_F
--
l_STUDENT_STATUS                 varchar2(60);
l_MARITAL_STATUS                 varchar2(60);
l_DATE_OF_DEATH                  date;
l_DATE_OF_BIRTH                  date;
l_COORD_BEN_NO_CVG_FLAG          varchar2(60);
l_COORD_BEN_MED_PLN_NO           varchar2(60);
l_ON_MILITARY_SERVICE            varchar2(60);
l_REGISTERED_DISABLED_FLAG       varchar2(60);
l_USES_TOBACCO_FLAG              varchar2(60);
l_BENEFIT_GROUP_ID               number;
l_ATTRIBUTE1                     VARCHAR2(150);
l_ATTRIBUTE10                    VARCHAR2(150);
l_ATTRIBUTE11                    VARCHAR2(150);
l_ATTRIBUTE12                    VARCHAR2(150);
l_ATTRIBUTE13                    VARCHAR2(150);
l_ATTRIBUTE14                    VARCHAR2(150);
l_ATTRIBUTE15                    VARCHAR2(150);
l_ATTRIBUTE16                    VARCHAR2(150);
l_ATTRIBUTE17                    VARCHAR2(150);
l_ATTRIBUTE18                    VARCHAR2(150);
l_ATTRIBUTE19                    VARCHAR2(150);
l_ATTRIBUTE2                    VARCHAR2(150);
l_ATTRIBUTE20                    VARCHAR2(150);
l_ATTRIBUTE21                    VARCHAR2(150);
l_ATTRIBUTE22                    VARCHAR2(150);
l_ATTRIBUTE23                    VARCHAR2(150);
l_ATTRIBUTE24                    VARCHAR2(150);
l_ATTRIBUTE25                    VARCHAR2(150);
l_ATTRIBUTE26                    VARCHAR2(150);
l_ATTRIBUTE27                    VARCHAR2(150);
l_ATTRIBUTE28                    VARCHAR2(150);
l_ATTRIBUTE29                    VARCHAR2(150);
l_ATTRIBUTE3                    VARCHAR2(150);
l_ATTRIBUTE30                    VARCHAR2(150);
l_ATTRIBUTE4                    VARCHAR2(150);
l_ATTRIBUTE5                    VARCHAR2(150);
l_ATTRIBUTE6                    VARCHAR2(150);
l_ATTRIBUTE7                    VARCHAR2(150);
l_ATTRIBUTE8                    VARCHAR2(150);
l_ATTRIBUTE9                    VARCHAR2(150);
l_DPDNT_VLNTRY_SVCE_FLAG        VARCHAR2(150);
l_per_information10             varchar2(150);
l_RECEIPT_OF_DEATH_CERT_DATE    DATE;
l_sex  			      varchar2(30);

--
-- Columns for table PER_CONTACT_RELATIONSHIPS
--
l_contact_person_id              number;
l_DATE_END1                      date;
l_DATE_START1                    date;
l_CONTACT_TYPE                   VARCHAR2(150);
l_PERSONAL_FLAG                  VARCHAR2(150);
l_START_LIFE_REASON_ID           NUMBER;
l_END_LIFE_REASON_ID             NUMBER;
l_RLTD_PER_RSDS_W_DSGNTR_FLAG    VARCHAR2(150);
--
-- Columns for table PER_PERIODS_OF_SERVICE
--
l_DATE_START2                    date;
l_LEAVING_REASON                 varchar2(60);
l_ADJUSTED_SVC_DATE              date;
l_ACTUAL_TERMINATION_DATE        date;
l_FINAL_PROCESS_DATE             DATE;
l_PDS_ATTRIBUTE1                 VARCHAR2(150);
l_PDS_ATTRIBUTE2                 VARCHAR2(150);
l_PDS_ATTRIBUTE3                 VARCHAR2(150);
l_PDS_ATTRIBUTE4                 VARCHAR2(150);
l_PDS_ATTRIBUTE5                 VARCHAR2(150);
l_PDS_ATTRIBUTE6                 VARCHAR2(150);
l_PDS_ATTRIBUTE7                 VARCHAR2(150);
l_PDS_ATTRIBUTE8                 VARCHAR2(150);
l_PDS_ATTRIBUTE9                 VARCHAR2(150);
l_PDS_ATTRIBUTE10                VARCHAR2(150);
l_PDS_ATTRIBUTE11                VARCHAR2(150);
l_PDS_ATTRIBUTE12                VARCHAR2(150);
l_PDS_ATTRIBUTE13                VARCHAR2(150);
l_PDS_ATTRIBUTE14                VARCHAR2(150);
l_PDS_ATTRIBUTE15                VARCHAR2(150);
l_PDS_ATTRIBUTE16                VARCHAR2(150);
l_PDS_ATTRIBUTE17                VARCHAR2(150);
l_PDS_ATTRIBUTE18                VARCHAR2(150);
l_PDS_ATTRIBUTE19                VARCHAR2(150);
l_PDS_ATTRIBUTE20                VARCHAR2(150);
--
-- Columns for table PER_PERSON_TYPE_USAGES_F
--
l_PERSON_TYPE_ID                 varchar2(60);
--
-- Select unique table names for selected LER
-- for each of the table call the appropriate API
--
l_agf_ler_id             number ;
l_los_ler_id             number ;
l_cmp_ler_id             number ;
l_cal_ler_id             number ;
l_hrw_ler_id             number ;
l_tpf_ler_id             number ;
l_ler_id                 number ;
--
--
-- Columns for Age Change temporal life event.
--
l_age_val                        number;
l_cmp_val                        number;
l_cmp_bnft_val                   number;
l_cmp_bal_val                    number;
l_tpf_val                        number;
l_hrw_val                        number;
l_hrw_bnft_val                   number;
l_uom                            varchar2(30);
l_lf_evt_ocrd_dt                 date;
l_lf_evt_ocrd_dt1                date;
--
l_date                           date;
l_errbuf                         varchar2(1000);
L_RETCODE                        number;


-- Columns for table PER_QUALIFICATIONS

l_qual_type_id             number;
l_qual_title	         varchar2(120);
l_qual_start_date          date;
l_qual_end_date  	         date;
l_qual_attribute1          varchar2(150);
l_qual_attribute2          varchar2(150);
l_qual_attribute3          varchar2(150);
l_qual_attribute4          varchar2(150);
l_qual_attribute5          varchar2(150);
l_qual_attribute6          varchar2(150);
l_qual_attribute7          varchar2(150);
l_qual_attribute8          varchar2(150);
l_qual_attribute9          varchar2(150);
l_qual_attribute10         varchar2(150);
l_qual_attribute11         varchar2(150);
l_qual_attribute12         varchar2(150);
l_qual_attribute13         varchar2(150);
l_qual_attribute14         varchar2(150);
l_qual_attribute15         varchar2(150);
l_qual_attribute16         varchar2(150);
l_qual_attribute17         varchar2(150);
l_qual_attribute18         varchar2(150);
l_qual_attribute19         varchar2(150);
l_qual_attribute20         varchar2(150);

-- Columns for table PER_COMPETENCE_ELEMENTS

l_comp_id                  number;
l_prof_lvl_id	         number;
l_comp_eff_date_from       date;
l_comp_eff_date_to         date;
l_comp_attribute1          varchar2(150);
l_comp_attribute2          varchar2(150);
l_comp_attribute3          varchar2(150);
l_comp_attribute4          varchar2(150);
l_comp_attribute5          varchar2(150);
l_comp_attribute6          varchar2(150);
l_comp_attribute7          varchar2(150);
l_comp_attribute8          varchar2(150);
l_comp_attribute9          varchar2(150);
l_comp_attribute10         varchar2(150);
l_comp_attribute11         varchar2(150);
l_comp_attribute12         varchar2(150);
l_comp_attribute13         varchar2(150);
l_comp_attribute14         varchar2(150);
l_comp_attribute15         varchar2(150);
l_comp_attribute16         varchar2(150);
l_comp_attribute17         varchar2(150);
l_comp_attribute18         varchar2(150);
l_comp_attribute19         varchar2(150);
l_comp_attribute20         varchar2(150);

  -- Columns for table PER_PERFORMANCE_REVIEWS

l_perf_rating              varchar2(30);
l_review_date              date;
l_event_id	         number;
l_perf_attribute1          varchar2(150);
l_perf_attribute2          varchar2(150);
l_perf_attribute3          varchar2(150);
l_perf_attribute4          varchar2(150);
l_perf_attribute5          varchar2(150);
l_perf_attribute6          varchar2(150);
l_perf_attribute7          varchar2(150);
l_perf_attribute8          varchar2(150);
l_perf_attribute9          varchar2(150);
l_perf_attribute10         varchar2(150);
l_perf_attribute11         varchar2(150);
l_perf_attribute12         varchar2(150);
l_perf_attribute13         varchar2(150);
l_perf_attribute14         varchar2(150);
l_perf_attribute15         varchar2(150);
l_perf_attribute16         varchar2(150);
l_perf_attribute17         varchar2(150);
l_perf_attribute18         varchar2(150);
l_perf_attribute19         varchar2(150);
l_perf_attribute20         varchar2(150);
l_perf_attribute21         varchar2(150);
l_perf_attribute22         varchar2(150);
l_perf_attribute23         varchar2(150);
l_perf_attribute24         varchar2(150);
l_perf_attribute25         varchar2(150);
l_perf_attribute26         varchar2(150);
l_perf_attribute27         varchar2(150);
l_perf_attribute28         varchar2(150);
l_perf_attribute29         varchar2(150);
l_perf_attribute30         varchar2(150);
  -- Columns for PER_PAY_PROPOSALS

l_change_date             date;
l_approved	          varchar2(1);
l_forced_ranking          number;
l_last_change_date        date;
l_multiple_components     varchar2(30);
l_next_sal_review_date    date;
l_next_perf_review_date   date;
l_performance_rating      varchar2(30);
l_performance_review_id   number;
l_proposal_reason         varchar2(30);
l_proposed_salary_n       number;
l_pay_review_date         date;
l_pay_attribute1          varchar2(150);
l_pay_attribute2          varchar2(150);
l_pay_attribute3          varchar2(150);
l_pay_attribute4          varchar2(150);
l_pay_attribute5          varchar2(150);
l_pay_attribute6          varchar2(150);
l_pay_attribute7          varchar2(150);
l_pay_attribute8          varchar2(150);
l_pay_attribute9          varchar2(150);
l_pay_attribute10         varchar2(150);
l_pay_attribute11         varchar2(150);
l_pay_attribute12         varchar2(150);
l_pay_attribute13         varchar2(150);
l_pay_attribute14         varchar2(150);
l_pay_attribute15         varchar2(150);
l_pay_attribute16         varchar2(150);
l_pay_attribute17         varchar2(150);
l_pay_attribute18         varchar2(150);
l_pay_attribute19         varchar2(150);
l_pay_attribute20         varchar2(150);

BEGIN
if g_debug then
    l_proc := g_package || '.post_ben_changes';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;
p_lf_evt_ocrd_dt := p_effective_date; -- lf_evt_ocrd_dt will be different only for DRVDAGE ,DRVDLOS,DRVDCAL
FOR C1 in csr_trs
  LOOP
  FOR C2 in csr_trs_values(C1.transaction_step_id)
   LOOP
    IF    C2.datatype='NUMBER' THEN
        l_field_val :=C2.number_value;
    ELSIF C2.datatype='DATE' THEN
        l_field_val :=C2.date_value;
    ELSIF C2.datatype='VARCHAR2' THEN
        l_field_val :=C2.varchar2_value;
    END IF;
    if g_debug then
        hr_utility.set_location('Table and Column: ' ||C1.api_name|| C2.name || l_field_val,15);
    end if;

                IF    C1.api_name = 'PER_ABSENCE_ATTENDANCES' and
		      C2.name = 'ABSENCE_ATTENDANCE_TYPE_ID' then
		        l_ABSENCE_ATTENDANCE_TYPE_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ABSENCE_ATTENDANCES' and
		      C2.name = 'ABS_ATTENDANCE_REASON_ID' then
		        l_ABS_ATTENDANCE_REASON_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ABSENCE_ATTENDANCES' and
		      C2.name = 'DATE_END' then
		      l_DATE_END := l_field_val;
		ELSIF C1.api_name = 'PER_ABSENCE_ATTENDANCES' and
		      C2.name = 'DATE_START' then
		      l_DATE_START := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'DATE_FROM' then
		      l_DATE_FROM := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'DATE_TO' then
		      l_DATE_TO := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'POSTAL_CODE' then
		      l_POSTAL_CODE := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'PRIMARY_FLAG' then
		      l_PRIMARY_FLAG := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'REGION_2' then
		      l_REGION_2 := l_field_val;
		ELSIF C1.api_name = 'PER_ADDRESSES' and
		      C2.name = 'ADDRESS_TYPE' then
		      l_ADDRESS_TYPE := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'ASSIGNMENT_STATUS_TYPE_ID' then
		      l_ASSIGNMENT_STATUS_TYPE_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'ASSIGNMENT_TYPE' then
		      l_ASSIGNMENT_TYPE := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'BARGAINING_UNIT_CODE' then
		      l_BARGAINING_UNIT_CODE := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'CHANGE_REASON' then
		      l_CHANGE_REASON := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'EMPLOYMENT_CATEGORY' then
		      l_EMPLOYMENT_CATEGORY := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'FREQUENCY' then
		      l_FREQUENCY := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'GRADE_ID' then
		      l_GRADE_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'JOB_ID' then
		      l_JOB_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'LABOUR_UNION_MEMBER_FLAG' then
		      l_LABOUR_UNION_MEMBER_FLAG := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'LOCATION_ID' then
		      l_LOCATION_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'NORMAL_HOURS' then
		      l_NORMAL_HOURS := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'ORGANIZATION_ID' then
		      l_ORGANIZATION_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'PAYROLL_ID' then
		      l_PAYROLL_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'PAY_BASIS_ID' then
		      l_PAY_BASIS_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'POSITION_ID' then
		      l_POSITION_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
		      C2.name = 'PRIMARY_FLAG' then
		      l_PRIMARY_FLAG1 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'HOURLY_SALARIED_CODE' then
                      l_HOURLY_SALARIED_CODE := l_field_val;

		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'PEOPLE_GROUP_ID' then
                      l_PEOPLE_GROUP_ID := l_field_val;

		ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE_CATEGORY' then
                      l_ASS_ATTRIBUTE_CATEGORY := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE1' then
                      l_ASS_ATTRIBUTE1 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE10' then
                      l_ASS_ATTRIBUTE10 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE11' then
                      l_ASS_ATTRIBUTE11 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE12' then
                      l_ASS_ATTRIBUTE12 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE13' then
                      l_ASS_ATTRIBUTE13 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE14' then
                      l_ASS_ATTRIBUTE14 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE15' then
                      l_ASS_ATTRIBUTE15 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE16' then
                      l_ASS_ATTRIBUTE16 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE17' then
                      l_ASS_ATTRIBUTE17 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE18' then
                      l_ASS_ATTRIBUTE18 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE19' then
                      l_ASS_ATTRIBUTE19 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE2' then
                      l_ASS_ATTRIBUTE2 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE20' then
                      l_ASS_ATTRIBUTE20 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE21' then
                      l_ASS_ATTRIBUTE21 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE22' then
                      l_ASS_ATTRIBUTE22 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE23' then
                      l_ASS_ATTRIBUTE23 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE24' then
                      l_ASS_ATTRIBUTE24 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE25' then
                      l_ASS_ATTRIBUTE25 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE26' then
                      l_ASS_ATTRIBUTE26 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE27' then
                      l_ASS_ATTRIBUTE27 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE28' then
                      l_ASS_ATTRIBUTE28 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE29' then
                      l_ASS_ATTRIBUTE29 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE3' then
                      l_ASS_ATTRIBUTE3 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE30' then
                      l_ASS_ATTRIBUTE30 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE4' then
                      l_ASS_ATTRIBUTE4 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE5' then
                      l_ASS_ATTRIBUTE5 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE6' then
                      l_ASS_ATTRIBUTE6 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE7' then
                      l_ASS_ATTRIBUTE7 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE8' then
                      l_ASS_ATTRIBUTE8 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_ASSIGNMENTS_F' and
                      C2.name = 'ASS_ATTRIBUTE9' then
                      l_ASS_ATTRIBUTE9 := l_field_val;

		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'BENEFIT_GROUP_ID' then
		      l_BENEFIT_GROUP_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'COORD_BEN_MED_PLN_NO' then
		      l_COORD_BEN_MED_PLN_NO := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'COORD_BEN_NO_CVG_FLAG' then
		      l_COORD_BEN_NO_CVG_FLAG := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'DATE_OF_BIRTH' then
		      l_DATE_OF_BIRTH := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'DATE_OF_DEATH' then
		      l_DATE_OF_DEATH := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'MARITAL_STATUS' then
		      l_MARITAL_STATUS := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'ON_MILITARY_SERVICE' then
		      l_ON_MILITARY_SERVICE := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'REGISTERED_DISABLED_FLAG' then
		      l_REGISTERED_DISABLED_FLAG := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'STUDENT_STATUS' then
		      l_STUDENT_STATUS := l_field_val;
		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
		      C2.name = 'USES_TOBACCO_FLAG' then
		      l_USES_TOBACCO_FLAG := l_field_val;
                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'PER_INFORMATION10' then
                      l_PER_INFORMATION10 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'DPDNT_VLNTRY_SVCE_FLAG' then
                      l_DPDNT_VLNTRY_SVCE_FLAG := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'RECEIPT_OF_DEATH_CERT_DATE' then
                      l_RECEIPT_OF_DEATH_CERT_DATE := l_field_val;

		ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'SEX' then
                      l_SEX := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE1' then
                      l_ATTRIBUTE1 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE10' then
                      l_ATTRIBUTE10 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE11' then
                      l_ATTRIBUTE11 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE12' then
                      l_ATTRIBUTE12 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE13' then
                      l_ATTRIBUTE13 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE14' then
                      l_ATTRIBUTE14 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE15' then
                      l_ATTRIBUTE15 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE16' then
                      l_ATTRIBUTE16 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE17' then
                      l_ATTRIBUTE17 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE18' then
                      l_ATTRIBUTE18 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE19' then
                      l_ATTRIBUTE19 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE2' then
                      l_ATTRIBUTE2 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE20' then
                      l_ATTRIBUTE20 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE21' then
                      l_ATTRIBUTE21 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE22' then
                      l_ATTRIBUTE22 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE23' then
                      l_ATTRIBUTE23 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE24' then
                      l_ATTRIBUTE24 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE25' then
                      l_ATTRIBUTE25 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE26' then
                      l_ATTRIBUTE26 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE27' then
                      l_ATTRIBUTE27 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE28' then
                      l_ATTRIBUTE28 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE29' then
                      l_ATTRIBUTE29 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE3' then
                      l_ATTRIBUTE3 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE30' then
                      l_ATTRIBUTE30 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE4' then
                      l_ATTRIBUTE4 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE5' then
                      l_ATTRIBUTE5 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE6' then
                      l_ATTRIBUTE6 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE7' then
                      l_ATTRIBUTE7 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE8' then
                      l_ATTRIBUTE8 := l_field_val;

                ELSIF C1.api_name = 'PER_ALL_PEOPLE_F' and
                      C2.name = 'ATTRIBUTE9' then
                      l_ATTRIBUTE9 := l_field_val;

		ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
		      C2.name = 'DATE_END' then
		      l_DATE_END1 := l_field_val;
		ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
		      C2.name = 'DATE_START' then
		      l_DATE_START1 := l_field_val;

	       ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'CONTACT_PERSON_ID' then
                      l_CONTACT_PERSON_ID := l_field_val;


		ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'CONTACT_TYPE' then
                      l_CONTACT_TYPE := l_field_val;

                ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'END_LIFE_REASON_ID' then
                      l_END_LIFE_REASON_ID := l_field_val;

                ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'PERSONAL_FLAG' then
                      l_PERSONAL_FLAG := l_field_val;

                ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'START_LIFE_REASON_ID' then
                      l_START_LIFE_REASON_ID := l_field_val;

                ELSIF C1.api_name = 'PER_CONTACT_RELATIONSHIPS' and
                      C2.name = 'RLTD_PER_RSDS_W_DSGNTR_FLAG' then
                      l_RLTD_PER_RSDS_W_DSGNTR_FLAG := l_field_val;

		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ACTUAL_TERMINATION_DATE' then
		      l_ACTUAL_TERMINATION_DATE := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ADJUSTED_SVC_DATE' then
		      l_ADJUSTED_SVC_DATE :=
                                     l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'DATE_START' then
		      l_DATE_START2 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'FINAL_PROCESS_DATE' then
                      l_FINAL_PROCESS_DATE  := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'ATTRIBUTE1' then
                      l_PDS_ATTRIBUTE1 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'ATTRIBUTE2' then
                      l_PDS_ATTRIBUTE2 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'ATTRIBUTE3' then
                      l_PDS_ATTRIBUTE3 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'ATTRIBUTE4' then
                      l_PDS_ATTRIBUTE4 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
                      C2.name = 'ATTRIBUTE5' then
                      l_PDS_ATTRIBUTE5 := l_field_val;
                ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE6' then
		      l_PDS_ATTRIBUTE6 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE7' then
		      l_PDS_ATTRIBUTE7 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE8' then
		      l_PDS_ATTRIBUTE8 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE9' then
		      l_PDS_ATTRIBUTE9 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE10' then
		      l_PDS_ATTRIBUTE10 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE11' then
		      l_PDS_ATTRIBUTE11 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE12' then
		      l_PDS_ATTRIBUTE12 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE13' then
		      l_PDS_ATTRIBUTE13 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE14' then
		      l_PDS_ATTRIBUTE14 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE15' then
		      l_PDS_ATTRIBUTE15 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE16' then
		      l_PDS_ATTRIBUTE16 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE17' then
		      l_PDS_ATTRIBUTE17 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE18' then
		      l_PDS_ATTRIBUTE18 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE19' then
		      l_PDS_ATTRIBUTE19 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'ATTRIBUTE20' then
                      l_PDS_ATTRIBUTE20 := l_field_val;
		ELSIF C1.api_name = 'PER_PERIODS_OF_SERVICE' and
		      C2.name = 'LEAVING_REASON' then
		      l_LEAVING_REASON := l_field_val;
		ELSIF C1.api_name = 'PER_PERSON_TYPE_USAGES_F' and
		      C2.name = 'PERSON_TYPE_ID' then
		      l_PERSON_TYPE_ID := l_field_val;
		ELSIF C1.api_name = 'BEN_PER_BNFTS_BAL_F' and
		      C2.name = 'BNFTS_BAL_ID' then
		      l_BNFTS_BAL_ID := l_field_val;
		ELSIF C1.api_name = 'BEN_PER_BNFTS_BAL_F' and
		      C2.name = 'VAL' then
		      l_VAL := l_field_val;
		ELSIF C1.api_name = 'BEN_PER_BNFTS_BAL_F' and
		      C2.name = 'EFFECTIVE_START_DATE' then
		      l_EFFECTIVE_START_DATE := l_field_val;
		ELSIF C1.api_name = 'BEN_PER_BNFTS_BAL_F' and
		      C2.name = 'EFFECTIVE_END_DATE' then
		      l_EFFECTIVE_END_DATE := l_field_val;
		ELSIF C1.api_name = 'BEN_CRT_ORDR' and
		      C2.name = 'CRT_ORDR_TYP_CD' then
		      l_CRT_ORDR_TYP_CD := l_field_val;
		ELSIF C1.api_name = 'BEN_CRT_ORDR' and
		      C2.name = 'PL_ID' then
		      l_pl_id := l_field_val;
		ELSIF C1.api_name = 'BEN_CRT_ORDR' and
		      C2.name = 'APLS_PERD_STRTG_DT' then
		      l_APLS_PERD_STRTG_DT := l_field_val;
		ELSIF C1.api_name = 'BEN_CRT_ORDR' and
		      C2.name = 'APLS_PERD_ENDG_DT' then
		      l_APLS_PERD_ENDG_DT := l_field_val;
		ELSIF C1.api_name = 'PER_ASSIGNMENT_BUDGET_VALUES_F' and
		      C2.name = 'ASSIGNMENT_BUDGET_VALUE_ID' then
		      l_ASSIGNMENT_BUDGET_VALUE_ID := l_field_val;
		ELSIF C1.api_name = 'PER_ASSIGNMENT_BUDGET_VALUES_F' and
		      C2.name = 'VALUE' then
		      l_value := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'QUALIFICATION_TYPE_ID' then
		      l_qual_type_id := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'TITLE' then
		      l_qual_title := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'START_DATE' then
		      l_qual_start_date := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'END_DATE' then
		      l_qual_end_date := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE1' then
		      l_qual_attribute1 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE2' then
		      l_qual_attribute2 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE3' then
		      l_qual_attribute3 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE4' then
		      l_qual_attribute4 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE5' then
		      l_qual_attribute5 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE6' then
		      l_qual_attribute6 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE7' then
		      l_qual_attribute7 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE8' then
		      l_qual_attribute8 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE9' then
		      l_qual_attribute9 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE10' then
		      l_qual_attribute10 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE11' then
		      l_qual_attribute11 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE12' then
		      l_qual_attribute12 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE13' then
		      l_qual_attribute13 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE14' then
		      l_qual_attribute14 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE15' then
		      l_qual_attribute15 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE16' then
		      l_qual_attribute16 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE17' then
		      l_qual_attribute17 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE18' then
		      l_qual_attribute18 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE19' then
		      l_qual_attribute19 := l_field_val;
		ELSIF C1.api_name = 'PER_QUALIFICATIONS' and
		      C2.name = 'ATTRIBUTE20' then
		      l_qual_attribute20 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'COMPETENCE_ID' then
		      l_comp_id := l_field_val;
		/*ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'PROFICIENCY_LEVEL_ID' then
		      begin
	   	        l_prof_lvl_id := l_field_val;
			l_comp_id := :GLOBAL.CMN_LOV_VAL1;
		      end;	*/
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'EFFECTIVE_DATE_FROM' then
		      l_comp_eff_date_from := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'EFFECTIVE_DATE_TO' then
		      l_comp_eff_date_to := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE1' then
		      l_comp_attribute1 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE2' then
		      l_comp_attribute2 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE3' then
		      l_comp_attribute3 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE4' then
		      l_comp_attribute4 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE5' then
		      l_comp_attribute5 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE6' then
		      l_comp_attribute6 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE7' then
		      l_comp_attribute7 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE8' then
		      l_comp_attribute8 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE9' then
		      l_comp_attribute9 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE10' then
		      l_comp_attribute10 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE11' then
		      l_comp_attribute11 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE12' then
		      l_comp_attribute12 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE13' then
		      l_comp_attribute13 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE14' then
		      l_comp_attribute14 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE15' then
		      l_comp_attribute15 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE16' then
		      l_comp_attribute16 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE17' then
		      l_comp_attribute17 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE18' then
		      l_comp_attribute18 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE19' then
		      l_comp_attribute19 := l_field_val;
		ELSIF C1.api_name = 'PER_COMPETENCE_ELEMENTS' and
		      C2.name = 'ATTRIBUTE20' then
		      l_comp_attribute20 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'PERFORMANCE_RATING' then
		      l_perf_rating := l_field_val;
	/*	ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'EVENT_ID' then
		      begin
		      l_event_id := l_field_val;
		      l_review_date := field_to_date('global.CMN_LOV_VAL1');
		      end; */
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE1' then
		      l_perf_attribute1 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE2' then
		      l_perf_attribute2 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE3' then
		      l_perf_attribute3 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE4' then
		      l_perf_attribute4 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE5' then
		      l_perf_attribute5 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE6' then
		      l_perf_attribute6 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE7' then
		      l_perf_attribute7 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE8' then
		      l_perf_attribute8 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE9' then
		      l_perf_attribute9 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE10' then
		      l_perf_attribute10 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE11' then
		      l_perf_attribute11 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE12' then
		      l_perf_attribute12 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE13' then
		      l_perf_attribute13 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE14' then
		      l_perf_attribute14 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE15' then
		      l_perf_attribute15 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE16' then
		      l_perf_attribute16 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE17' then
		      l_perf_attribute17 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE18' then
		      l_perf_attribute18 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE19' then
		      l_perf_attribute19 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE20' then
		      l_perf_attribute20 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE21' then
		      l_perf_attribute21 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE22' then
		      l_perf_attribute22 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE23' then
		      l_perf_attribute23 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE24' then
		      l_perf_attribute24 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE25' then
		      l_perf_attribute25 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE26' then
		      l_perf_attribute26 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE27' then
		      l_perf_attribute27 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE28' then
		      l_perf_attribute28 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE29' then
		      l_perf_attribute29 := l_field_val;
		ELSIF C1.api_name = 'PER_PERFORMANCE_REVIEWS' and
		      C2.name = 'ATTRIBUTE30' then
		      l_perf_attribute30 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'APPROVED' then
		      l_approved := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'CHANGE_DATE' then
		      l_change_date := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'PROPOSED_SALARY_N' then
		      l_proposed_salary_n := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'FORCED_RANKING' then
		      l_forced_ranking := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'PERFORMANCE_REVIEW_ID' then
		      l_performance_review_id := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'NEXT_SAL_REVIEW_DATE' then
		      l_next_sal_review_date := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE1' then
		      l_pay_attribute1 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE2' then
		      l_pay_attribute2 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE3' then
		      l_pay_attribute3 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE4' then
		      l_pay_attribute4 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE5' then
		      l_pay_attribute5 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE6' then
		      l_pay_attribute6 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE7' then
		      l_pay_attribute7 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE8' then
		      l_pay_attribute8 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE9' then
		      l_pay_attribute9 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE10' then
		      l_pay_attribute10 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE11' then
		      l_pay_attribute11 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE12' then
		      l_pay_attribute12 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE13' then
		      l_pay_attribute13 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE14' then
		      l_pay_attribute14 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE15' then
		      l_pay_attribute15 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE16' then
		      l_pay_attribute16 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE17' then
		      l_pay_attribute17 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE18' then
		      l_pay_attribute18 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE19' then
		      l_pay_attribute19 := l_field_val;
		ELSIF C1.api_name = 'PER_PAY_PROPOSALS' and
		      C2.name = 'ATTRIBUTE20' then
		      l_pay_attribute20 := l_field_val;
		                                                      -- derived data factors
		ELSIF C1.api_name = 'DRVDAGE' then
	         l_age_val := C2.number_value;
		 l_uom     := C2.varchar2_value;
		 FOR p_rec IN c_person_data LOOP
		 l_date    := p_rec.date_of_birth;

		 l_lf_evt_ocrd_dt := p_get_lf_evt_ocrd_dt(
		                                          p_date  => l_date,
		                                          p_uom   => l_uom,
                                                          p_value => l_age_val);
                if(l_lf_evt_ocrd_dt < p_rec.hire_date) then
                  OPEN csr_uom(l_uom);
                  FETCH csr_uom into l_uom;
                  CLOSE csr_uom;
		  fnd_message.set_name('BEN', 'BEN_93194_AGE_VALUE_ERROR');
		  fnd_message.set_token('AGE',l_age_val);
		  fnd_message.set_token('UOM',l_uom);
		  fnd_message.set_token('HIRE_DATE',to_char(p_rec.hire_date,'DD-MM-RRRR'));
		  fnd_message.set_token('DOB',to_char(l_date,'DD-MM-RRRR'));
		  fnd_message.raise_error;
		end if;
		END LOOP;
                ELSIF C1.api_name = 'DRVDLOS' then
	         l_age_val := C2.number_value;
		 l_uom     := C2.varchar2_value;
		 FOR p_rec IN c_person_data LOOP
		 l_date    := p_rec.hire_date;
		 END LOOP;
		 l_lf_evt_ocrd_dt := p_get_lf_evt_ocrd_dt(
		                                          p_date  => l_date,
		                                          p_uom   => l_uom,
                                                          p_value => l_age_val);
                ELSIF C1.api_name = 'DRVDCAL' and
                   C2.name = 'AGE' then
	         l_age_val := C2.number_value;
		 l_uom     := C2.varchar2_value;
		 FOR p_rec IN c_person_data LOOP
		 l_date    := p_rec.date_of_birth;
		 END LOOP;
		 l_lf_evt_ocrd_dt := p_get_lf_evt_ocrd_dt(
		                                          p_date  => l_date,
		                                          p_uom   => l_uom,
                                                          p_value => l_age_val);
                ELSIF C1.api_name = 'DRVDCAL' and
                   C2.name = 'LOS' then
	         l_age_val := C2.number_value;
		 l_uom     := C2.varchar2_value;
		 FOR p_rec IN c_person_data LOOP
		 l_date    := p_rec.hire_date;
		 END LOOP;
		 l_lf_evt_ocrd_dt1 := p_get_lf_evt_ocrd_dt(
		                                          p_date  => l_date,
		                                          p_uom   => l_uom,
                                                          p_value => l_age_val);
                ELSIF C1.api_name = 'DRVDCMP' and
                   C2.name = 'COMP' then
                     l_cmp_val      := l_field_val;
                ELSIF C1.api_name = 'DRVDCMP' and
                  C2.name = 'COMPBAL' then
                   l_cmp_bnft_val      := l_field_val;
                ELSIF C1.api_name = 'DRVDCMP' and
                C2.name = 'COMPBBAL' then
                  l_cmp_bal_val      := l_field_val;
                ELSIF C1.api_name = 'DRVDHRW' and
                C2.name = 'HRW' then
                  l_hrw_val       := l_field_val;
                ELSIF C1.api_name = 'DRVDHRW' and
                C2.name = 'HRWBAL' then
                  l_hrw_bnft_val      := l_field_val;
                ELSIF C1.api_name = 'DRVDTPF' then
                l_tpf_val := l_field_val;

	    END IF; --if else ladder
     END LOOP;
     /*IF   C1.api_name=  'PER_ALL_ASSIGNMENTS_F' THEN
     	        --
                     ben_whatif_elig.WATIF_ALL_ASSIGNMENTS_F_API(
                        p_person_id                      => p_person_id
                       ,p_PAY_BASIS_ID                   => l_PAY_BASIS_ID
                       ,p_LABOUR_UNION_MEMBER_FLAG       => l_LABOUR_UNION_MEMBER_FLAG
                       ,p_JOB_ID                         => l_JOB_ID
                       ,p_PAYROLL_ID                     => l_PAYROLL_ID
                       ,p_PRIMARY_FLAG                   => l_PRIMARY_FLAG1
                       ,p_LOCATION_ID                    => l_LOCATION_ID
                       ,p_CHANGE_REASON                  => l_CHANGE_REASON
                       ,p_ASSIGNMENT_TYPE                => l_ASSIGNMENT_TYPE
                       ,p_ORGANIZATION_ID                => l_ORGANIZATION_ID
                       ,p_POSITION_ID                    => l_POSITION_ID
                       ,p_BARGAINING_UNIT_CODE           => l_BARGAINING_UNIT_CODE
                       ,p_NORMAL_HOURS                   => l_NORMAL_HOURS
                       ,p_FREQUENCY                      => l_FREQUENCY
                       ,p_ASSIGNMENT_STATUS_TYPE_ID      => l_ASSIGNMENT_STATUS_TYPE_ID
                       ,p_GRADE_ID                       => l_GRADE_ID
                       ,p_EMPLOYMENT_CATEGORY            => l_EMPLOYMENT_CATEGORY
                       ,p_PEOPLE_GROUP_ID                =>   l_PEOPLE_GROUP_ID
     		       ,p_HOURLY_SALARIED_CODE           => l_HOURLY_SALARIED_CODE
     		       ,p_ASS_ATTRIBUTE_CATEGORY => l_ASS_ATTRIBUTE_CATEGORY
                       ,p_ASS_ATTRIBUTE1  =>   l_ASS_ATTRIBUTE1
                       ,p_ASS_ATTRIBUTE10 =>   l_ASS_ATTRIBUTE10
                       ,p_ASS_ATTRIBUTE11 =>   l_ASS_ATTRIBUTE11
                       ,p_ASS_ATTRIBUTE12 =>   l_ASS_ATTRIBUTE12
                       ,p_ASS_ATTRIBUTE13 =>   l_ASS_ATTRIBUTE13
                       ,p_ASS_ATTRIBUTE14 =>   l_ASS_ATTRIBUTE14
                       ,p_ASS_ATTRIBUTE15 =>   l_ASS_ATTRIBUTE15
                       ,p_ASS_ATTRIBUTE16 =>   l_ASS_ATTRIBUTE16
                       ,p_ASS_ATTRIBUTE17 =>   l_ASS_ATTRIBUTE17
                       ,p_ASS_ATTRIBUTE18 =>   l_ASS_ATTRIBUTE18
                       ,p_ASS_ATTRIBUTE19 =>   l_ASS_ATTRIBUTE19
                       ,p_ASS_ATTRIBUTE2  =>   l_ASS_ATTRIBUTE2
                       ,p_ASS_ATTRIBUTE20 =>   l_ASS_ATTRIBUTE20
                       ,p_ASS_ATTRIBUTE21 =>   l_ASS_ATTRIBUTE21
                       ,p_ASS_ATTRIBUTE22 =>   l_ASS_ATTRIBUTE22
                       ,p_ASS_ATTRIBUTE23 =>   l_ASS_ATTRIBUTE23
                       ,p_ASS_ATTRIBUTE24 =>   l_ASS_ATTRIBUTE24
                       ,p_ASS_ATTRIBUTE25 =>   l_ASS_ATTRIBUTE25
                       ,p_ASS_ATTRIBUTE26 =>   l_ASS_ATTRIBUTE26
                       ,p_ASS_ATTRIBUTE27 =>   l_ASS_ATTRIBUTE27
                       ,p_ASS_ATTRIBUTE28 =>   l_ASS_ATTRIBUTE28
                       ,p_ASS_ATTRIBUTE29 =>   l_ASS_ATTRIBUTE29
                       ,p_ASS_ATTRIBUTE3  =>   l_ASS_ATTRIBUTE3
                       ,p_ASS_ATTRIBUTE30 =>   l_ASS_ATTRIBUTE30
                       ,p_ASS_ATTRIBUTE4  =>   l_ASS_ATTRIBUTE4
                       ,p_ASS_ATTRIBUTE5  =>   l_ASS_ATTRIBUTE5
                       ,p_ASS_ATTRIBUTE6  =>   l_ASS_ATTRIBUTE6
                       ,p_ASS_ATTRIBUTE7  =>   l_ASS_ATTRIBUTE7
                       ,p_ASS_ATTRIBUTE8  =>   l_ASS_ATTRIBUTE8
                       ,p_ASS_ATTRIBUTE9  =>   l_ASS_ATTRIBUTE9
                       ,p_business_group_id              => p_business_group_id
                       ,p_effective_date                 => p_effective_date
                       );*/
                IF  C1.api_name= 'PER_ABSENCE_ATTENDANCES' THEN
	        --
                 ben_whatif_elig.WATIF_ABSENCE_ATTENDANCES_API(
                   p_person_id                      => p_person_id
                  ,p_ABSENCE_ATTENDANCE_TYPE_ID     => l_ABSENCE_ATTENDANCE_TYPE_ID
                  ,p_ABS_ATTENDANCE_REASON_ID       => l_ABS_ATTENDANCE_REASON_ID
                  ,p_DATE_END                       => l_DATE_END
                  ,p_DATE_START                     => l_DATE_START
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
	        --
        ELSIF   C1.api_name=  'PER_ADDRESSES'	THEN
	        --

                ben_whatif_elig.WATIF_ADDRESSES_API(
                   p_person_id                      => p_person_id
                  ,p_POSTAL_CODE                    => l_POSTAL_CODE
                  ,p_PRIMARY_FLAG                   => l_PRIMARY_FLAG
                  ,p_REGION_2                       => l_region_2
                  ,p_ADDRESS_TYPE                   => l_address_type
                  ,p_DATE_FROM                      => l_DATE_FROM
                  ,p_DATE_TO                        => l_DATE_TO
                  ,p_effective_date                 => p_effective_date
                  );

	        --
            ELSIF   C1.api_name= 'PER_ALL_ASSIGNMENTS_F'   THEN
	        --
                ben_whatif_elig.WATIF_ALL_ASSIGNMENTS_F_API(
                   p_person_id                      => p_person_id
                  ,p_PAY_BASIS_ID                   => l_PAY_BASIS_ID
                  ,p_LABOUR_UNION_MEMBER_FLAG       => l_LABOUR_UNION_MEMBER_FLAG
                  ,p_JOB_ID                         => l_JOB_ID
                  ,p_PAYROLL_ID                     => l_PAYROLL_ID
                  ,p_PRIMARY_FLAG                   => l_PRIMARY_FLAG1
                  ,p_LOCATION_ID                    => l_LOCATION_ID
                  ,p_CHANGE_REASON                  => l_CHANGE_REASON
                  ,p_ASSIGNMENT_TYPE                => l_ASSIGNMENT_TYPE
                  ,p_ORGANIZATION_ID                => l_ORGANIZATION_ID
                  ,p_POSITION_ID                    => l_POSITION_ID
                  ,p_BARGAINING_UNIT_CODE           => l_BARGAINING_UNIT_CODE
                  ,p_NORMAL_HOURS                   => l_NORMAL_HOURS
                  ,p_FREQUENCY                      => l_FREQUENCY
                  ,p_ASSIGNMENT_STATUS_TYPE_ID      => l_ASSIGNMENT_STATUS_TYPE_ID
                  ,p_GRADE_ID                       => l_GRADE_ID
                  ,p_EMPLOYMENT_CATEGORY            => l_EMPLOYMENT_CATEGORY
                  ,p_PEOPLE_GROUP_ID =>   l_PEOPLE_GROUP_ID
		  ,p_HOURLY_SALARIED_CODE => l_HOURLY_SALARIED_CODE
		  ,p_ASS_ATTRIBUTE_CATEGORY => l_ASS_ATTRIBUTE_CATEGORY
                  ,p_ASS_ATTRIBUTE1  =>   l_ASS_ATTRIBUTE1
                  ,p_ASS_ATTRIBUTE10 =>   l_ASS_ATTRIBUTE10
                  ,p_ASS_ATTRIBUTE11 =>   l_ASS_ATTRIBUTE11
                  ,p_ASS_ATTRIBUTE12 =>   l_ASS_ATTRIBUTE12
                  ,p_ASS_ATTRIBUTE13 =>   l_ASS_ATTRIBUTE13
                  ,p_ASS_ATTRIBUTE14 =>   l_ASS_ATTRIBUTE14
                  ,p_ASS_ATTRIBUTE15 =>   l_ASS_ATTRIBUTE15
                  ,p_ASS_ATTRIBUTE16 =>   l_ASS_ATTRIBUTE16
                  ,p_ASS_ATTRIBUTE17 =>   l_ASS_ATTRIBUTE17
                  ,p_ASS_ATTRIBUTE18 =>   l_ASS_ATTRIBUTE18
                  ,p_ASS_ATTRIBUTE19 =>   l_ASS_ATTRIBUTE19
                  ,p_ASS_ATTRIBUTE2  =>   l_ASS_ATTRIBUTE2
                  ,p_ASS_ATTRIBUTE20 =>   l_ASS_ATTRIBUTE20
                  ,p_ASS_ATTRIBUTE21 =>   l_ASS_ATTRIBUTE21
                  ,p_ASS_ATTRIBUTE22 =>   l_ASS_ATTRIBUTE22
                  ,p_ASS_ATTRIBUTE23 =>   l_ASS_ATTRIBUTE23
                  ,p_ASS_ATTRIBUTE24 =>   l_ASS_ATTRIBUTE24
                  ,p_ASS_ATTRIBUTE25 =>   l_ASS_ATTRIBUTE25
                  ,p_ASS_ATTRIBUTE26 =>   l_ASS_ATTRIBUTE26
                  ,p_ASS_ATTRIBUTE27 =>   l_ASS_ATTRIBUTE27
                  ,p_ASS_ATTRIBUTE28 =>   l_ASS_ATTRIBUTE28
                  ,p_ASS_ATTRIBUTE29 =>   l_ASS_ATTRIBUTE29
                  ,p_ASS_ATTRIBUTE3  =>   l_ASS_ATTRIBUTE3
                  ,p_ASS_ATTRIBUTE30 =>   l_ASS_ATTRIBUTE30
                  ,p_ASS_ATTRIBUTE4  =>   l_ASS_ATTRIBUTE4
                  ,p_ASS_ATTRIBUTE5  =>   l_ASS_ATTRIBUTE5
                  ,p_ASS_ATTRIBUTE6  =>   l_ASS_ATTRIBUTE6
                  ,p_ASS_ATTRIBUTE7  =>   l_ASS_ATTRIBUTE7
                  ,p_ASS_ATTRIBUTE8  =>   l_ASS_ATTRIBUTE8
                  ,p_ASS_ATTRIBUTE9  =>   l_ASS_ATTRIBUTE9
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
	        --
            ELSIF   C1.api_name= 'PER_ALL_PEOPLE_F' THEN
	        --
                ben_whatif_elig.WATIF_ALL_PEOPLE_F_API(
                   p_person_id                      => p_person_id
                  ,p_STUDENT_STATUS                 => l_STUDENT_STATUS
                  ,p_DATE_OF_DEATH                  => l_DATE_OF_DEATH
                  ,p_DATE_OF_BIRTH                  => l_DATE_OF_BIRTH
                  ,p_COORD_BEN_NO_CVG_FLAG          => l_COORD_BEN_NO_CVG_FLAG
                  ,p_COORD_BEN_MED_PLN_NO           => l_COORD_BEN_MED_PLN_NO
                  ,p_PER_INFORMATION10              => l_per_information10
                  ,p_ON_MILITARY_SERVICE            => l_ON_MILITARY_SERVICE
                  ,p_REGISTERED_DISABLED_FLAG       => l_REGISTERED_DISABLED_FLAG
                  ,p_USES_TOBACCO_FLAG              => l_USES_TOBACCO_FLAG
                  ,p_BENEFIT_GROUP_ID               => l_BENEFIT_GROUP_ID
                  ,p_MARITAL_STATUS                 => l_MARITAL_STATUS
                  ,p_ATTRIBUTE1                  =>   l_ATTRIBUTE1
                  ,p_ATTRIBUTE10                  =>   l_ATTRIBUTE10
                  ,p_ATTRIBUTE11                  =>   l_ATTRIBUTE11
                  ,p_ATTRIBUTE12                  =>   l_ATTRIBUTE12
                  ,p_ATTRIBUTE13                  =>   l_ATTRIBUTE13
                  ,p_ATTRIBUTE14                  =>   l_ATTRIBUTE14
                  ,p_ATTRIBUTE15                  =>   l_ATTRIBUTE15
                  ,p_ATTRIBUTE16                  =>   l_ATTRIBUTE16
                  ,p_ATTRIBUTE17                  =>   l_ATTRIBUTE17
                  ,p_ATTRIBUTE18                  =>   l_ATTRIBUTE18
                  ,p_ATTRIBUTE19                  =>   l_ATTRIBUTE19
                  ,p_ATTRIBUTE2                  =>   l_ATTRIBUTE2
                  ,p_ATTRIBUTE20                  =>   l_ATTRIBUTE20
                  ,p_ATTRIBUTE21                  =>   l_ATTRIBUTE21
                  ,p_ATTRIBUTE22                  =>   l_ATTRIBUTE22
                  ,p_ATTRIBUTE23                  =>   l_ATTRIBUTE23
                  ,p_ATTRIBUTE24                  =>   l_ATTRIBUTE24
                  ,p_ATTRIBUTE25                  =>   l_ATTRIBUTE25
                  ,p_ATTRIBUTE26                  =>   l_ATTRIBUTE26
                  ,p_ATTRIBUTE27                  =>   l_ATTRIBUTE27
                  ,p_ATTRIBUTE28                  =>   l_ATTRIBUTE28
                  ,p_ATTRIBUTE29                  =>   l_ATTRIBUTE29
                  ,p_ATTRIBUTE3                  =>   l_ATTRIBUTE3
                  ,p_ATTRIBUTE30                  =>   l_ATTRIBUTE30
                  ,p_ATTRIBUTE4                  =>   l_ATTRIBUTE4
                  ,p_ATTRIBUTE5                  =>   l_ATTRIBUTE5
                  ,p_ATTRIBUTE6                  =>   l_ATTRIBUTE6
                  ,p_ATTRIBUTE7                  =>   l_ATTRIBUTE7
                  ,p_ATTRIBUTE8                  =>   l_ATTRIBUTE8
                  ,p_ATTRIBUTE9                  =>   l_ATTRIBUTE9
                  ,p_DPDNT_VLNTRY_SVCE_FLAG      =>   l_DPDNT_VLNTRY_SVCE_FLAG
                  ,p_RECEIPT_OF_DEATH_CERT_DATE  =>   l_RECEIPT_OF_DEATH_CERT_DATE
		  ,p_SEX			 =>   l_sex
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
	        --
         ELSIF   C1.api_name=  'PER_CONTACT_RELATIONSHIPS'  THEN
	    ben_whatif_elig.WATIF_CONTACT_RELATIONSHIP_API(
                   p_person_id                      => p_person_id
                  ,p_contact_person_id              => l_contact_person_id
                  ,p_DATE_END                       => l_DATE_END1
                  ,p_DATE_START                     => nvl(l_DATE_START1,p_effective_date)
                  ,p_CONTACT_TYPE                   => l_CONTACT_TYPE
                  ,p_END_LIFE_REASON_ID             => l_END_LIFE_REASON_ID
                  ,p_PERSONAL_FLAG                  => l_PERSONAL_FLAG
                  ,p_START_LIFE_REASON_ID           => l_START_LIFE_REASON_ID
                  ,p_RLTD_PER_RSDS_W_DSGNTR_FLAG    => nvl(l_RLTD_PER_RSDS_W_DSGNTR_FLAG,'Y')
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
	        --
           ELSIF   C1.api_name= 'PER_PERIODS_OF_SERVICE'    THEN
	        --
		if l_LEAVING_REASON is not null and
                   l_ACTUAL_TERMINATION_DATE is null then
                   l_ACTUAL_TERMINATION_DATE := p_session_date;
                end if;
		if l_ACTUAL_TERMINATION_DATE is not null then
		   p_lf_evt_ocrd_dt := l_ACTUAL_TERMINATION_DATE;
                end if;
		--
                ben_whatif_elig.WATIF_PERIODS_OF_SERVICE_API(
                   p_person_id                      =>p_person_id
                  ,p_per_object_version_number      => null
                  ,p_DATE_START                     => l_DATE_START2
                  ,p_LEAVING_REASON                 => l_LEAVING_REASON
                  ,p_ADJUSTED_SVC_DATE              => l_ADJUSTED_SVC_DATE
                  ,p_ACTUAL_TERMINATION_DATE        => l_ACTUAL_TERMINATION_DATE
                  ,p_FINAL_PROCESS_DATE             => l_FINAL_PROCESS_DATE
                  ,p_ATTRIBUTE1                     => l_PDS_ATTRIBUTE1
                  ,p_ATTRIBUTE2                     => l_PDS_ATTRIBUTE2
                  ,p_ATTRIBUTE3                     => l_PDS_ATTRIBUTE3
                  ,p_ATTRIBUTE4                     => l_PDS_ATTRIBUTE4
                  ,p_ATTRIBUTE5                     => l_PDS_ATTRIBUTE5
                  ,p_ATTRIBUTE6                     => l_ATTRIBUTE6
		  ,p_ATTRIBUTE7  	            => l_ATTRIBUTE7
		  ,p_ATTRIBUTE8  	            => l_ATTRIBUTE8
		  ,p_ATTRIBUTE9  	            => l_ATTRIBUTE9
		  ,p_ATTRIBUTE10 	            => l_ATTRIBUTE10
		  ,p_ATTRIBUTE11 	            => l_ATTRIBUTE11
		  ,p_ATTRIBUTE12 	            => l_ATTRIBUTE12
		  ,p_ATTRIBUTE13 	            => l_ATTRIBUTE13
		  ,p_ATTRIBUTE14 	            => l_ATTRIBUTE14
		  ,p_ATTRIBUTE15 	            => l_ATTRIBUTE15
		  ,p_ATTRIBUTE16 	            => l_ATTRIBUTE16
		  ,p_ATTRIBUTE17 	            => l_ATTRIBUTE17
		  ,p_ATTRIBUTE18 	            => l_ATTRIBUTE18
		  ,p_ATTRIBUTE19 	            => l_ATTRIBUTE19
                  ,p_ATTRIBUTE20   	            => l_ATTRIBUTE20
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
                --
          ELSIF   C1.api_name='PER_PERSON_TYPE_USAGES_F'  THEN
	        --
                ben_whatif_elig.WATIF_PERSON_TYPE_USAGES_F_API(
                   p_person_id                      => p_person_id
                  ,p_PERSON_TYPE_ID                 => l_PERSON_TYPE_ID
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  );
                --
           ELSIF   C1.api_name= 'BEN_PER_BNFTS_BAL_F' then
	        --
                ben_whatif_elig.WATIF_PER_BNFTS_BAL_F_API(
                   p_person_id                      => p_person_id
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  ,p_BNFTS_BAL_ID                   => l_BNFTS_BAL_ID
                  ,p_VAL                            => l_val
                  ,p_EFFECTIVE_START_DATE           => l_effective_start_date
                  ,p_EFFECTIVE_END_DATE             => l_effective_end_date
                  );
                --
         ELSIF   C1.api_name= 'BEN_CRT_ORDR'     THEN
	        --
                ben_whatif_elig.WATIF_CRT_ORDR_API(
                   p_person_id                      => p_person_id
                  ,p_pl_id                          => l_pl_id
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  ,p_CRT_ORDR_TYP_CD                => l_CRT_ORDR_TYP_CD
                  ,p_APLS_PERD_STRTG_DT             => l_APLS_PERD_STRTG_DT
                  ,p_APLS_PERD_ENDG_DT              => l_APLS_PERD_ENDG_DT
                  );
                --
          ELSIF   C1.api_name='PER_ASSIG_BUDGET_VALUES_F'    THEN
	        --
                ben_whatif_elig.WATIF_PER_ASG_BUDG_VAL_F_API(
                   p_person_id                      => p_person_id
                  ,p_ASSIGNMENT_BUDGET_VALUE_ID     => l_ASSIGNMENT_BUDGET_VALUE_ID
                  ,p_VALUE                          => l_value
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                );
           ELSIF   C1.api_name= 'PER_QUALIFICATIONS'  THEN

	      ben_whatif_elig.WATIF_PER_QUALIFICATIONS_API(
			 p_person_id             => p_person_id
   			,p_qualification_type_id => l_qual_type_id
   			,p_title		=> l_qual_title
   			,p_start_date  	      	=> nvl(l_qual_start_date, p_effective_date)
   			,p_end_date		=> l_qual_end_date
   			,p_attribute1	      	=> l_qual_attribute1
                        ,p_attribute2           => l_qual_attribute2
   			,p_attribute3	      	=> l_qual_attribute3
   			,p_attribute4		=> l_qual_attribute4
   			,p_attribute5         	=> l_qual_attribute5
  			,p_attribute6		=> l_qual_attribute6
   			,p_attribute7		=> l_qual_attribute7
   			,p_attribute8		=> l_qual_attribute8
   			,p_attribute9		=> l_qual_attribute9
   			,p_attribute10		=> l_qual_attribute10
   			,p_attribute11        	=> l_qual_attribute11
   			,p_attribute12		=> l_qual_attribute12
  			,p_attribute13		=> l_qual_attribute13
   			,p_attribute14        	=> l_qual_attribute14
   			,p_attribute15		=> l_qual_attribute15
   			,p_attribute16		=> l_qual_attribute16
   			,p_attribute17        	=> l_qual_attribute17
  			,p_attribute18		=> l_qual_attribute18
   			,p_attribute19		=> l_qual_attribute19
  			,p_attribute20		=> l_qual_attribute20
  			,p_business_group_id    => p_business_group_id
   			,p_effective_date       => p_effective_date
			);
	  ELSIF   C1.api_name='PER_COMPETENCE_ELEMENTS'  THEN

	    ben_whatif_elig.WATIF_PER_COMPETENCE_API(
    		p_person_id              => p_person_id
		,p_competence_id          => l_comp_id
	        ,p_proficiency_level_id   => l_prof_lvl_id
   		,p_effective_date_from    => nvl(l_comp_eff_date_from, p_effective_date)
   		,p_effective_date_to	  => l_comp_eff_date_to
   		,p_attribute1	    	  => l_comp_attribute1
   		,p_attribute2	    	  => l_comp_attribute2
   		,p_attribute3	     	  => l_comp_attribute3
   		,p_attribute4	    	  => l_comp_attribute4
   		,p_attribute5        	  => l_comp_attribute5
   		,p_attribute6	     	  => l_comp_attribute6
   		,p_attribute7	  	  => l_comp_attribute7
   		,p_attribute8	  	  => l_comp_attribute8
   		,p_attribute9	     	  => l_comp_attribute9
   	 	,p_attribute10     	  => l_comp_attribute10
   		,p_attribute11            => l_comp_attribute11
   		,p_attribute12	     	  => l_comp_attribute12
   		,p_attribute13	     	  => l_comp_attribute13
   		,p_attribute14            => l_comp_attribute14
   		,p_attribute15	    	  => l_comp_attribute15
   		,p_attribute16	     	  => l_comp_attribute16
   		,p_attribute17            => l_comp_attribute17
   		,p_attribute18	          => l_comp_attribute18
   		,p_attribute19	  	  => l_comp_attribute19
   		,p_attribute20	   	  => l_comp_attribute20
   		,p_business_group_id      => p_business_group_id
   		,p_effective_date         => p_effective_date
		);
   	   ELSIF   C1.api_name= 'PER_PERFORMANCE_REVIEWS'  THEN

 	       ben_whatif_elig.WATIF_PER_PERFORMANCE_API(
		    p_person_id              	=> p_person_id
		   ,p_performance_rating     	=> l_perf_rating
		   ,p_event_id		     	=> l_event_id
		   ,p_review_date            	=> l_review_date
		   ,p_attribute1	     	=> l_perf_attribute1
		   ,p_attribute2	     	=> l_perf_attribute2
		   ,p_attribute3		=> l_perf_attribute3
		   ,p_attribute4		=> l_perf_attribute4
		   ,p_attribute5         	=> l_perf_attribute5
		   ,p_attribute6		=> l_perf_attribute6
		   ,p_attribute7		=> l_perf_attribute7
		   ,p_attribute8		=> l_perf_attribute8
		   ,p_attribute9		=> l_perf_attribute9
		   ,p_attribute10		=> l_perf_attribute10
		   ,p_attribute11        	=> l_perf_attribute11
		   ,p_attribute12		=> l_perf_attribute12
		   ,p_attribute13		=> l_perf_attribute13
		   ,p_attribute14        	=> l_perf_attribute14
		   ,p_attribute15		=> l_perf_attribute15
		   ,p_attribute16		=> l_perf_attribute16
		   ,p_attribute17        	=> l_perf_attribute17
		   ,p_attribute18		=> l_perf_attribute18
		   ,p_attribute19		=> l_perf_attribute19
		   ,p_attribute20		=> l_perf_attribute20
		   ,p_attribute21		=> l_perf_attribute21
		   ,p_attribute22		=> l_perf_attribute22
		   ,p_attribute23		=> l_perf_attribute23
		   ,p_attribute24		=> l_perf_attribute24
		   ,p_attribute25         	=> l_perf_attribute25
		   ,p_attribute26		=> l_perf_attribute26
		   ,p_attribute27		=> l_perf_attribute27
		   ,p_attribute28		=> l_perf_attribute28
		   ,p_attribute29		=> l_perf_attribute29
		   ,p_attribute30		=> l_perf_attribute30
		   );
	  ELSIF   C1.api_name= 'PER_PAY_PROPOSALS'  THEN

	       if l_proposed_salary_n is null then
		  fnd_message.set_name('PER','HR_52401_PYP_NO_PROPOSED_AMT');
	 	  fnd_message.raise_error;

	       end if;
	       ben_whatif_elig.WATIF_PAY_PROPOSAL_API(
		    p_person_id        		=> p_person_id
		   ,p_approved	       		=> nvl(l_approved , 'N')
		   ,p_change_date      		=> nvl(l_change_date,p_effective_date) --6282219
		   ,p_event_id         		=> null
		   ,p_forced_ranking            => l_forced_ranking
		   ,p_last_change_date          => l_last_change_date
		   ,p_multiple_components       => 'N'
		   ,p_next_sal_review_date	=> l_next_sal_review_date
		   ,p_next_perf_review_date	=> l_next_perf_review_date
		   ,p_performance_rating        => l_performance_rating
		   ,p_performance_review_id     => l_performance_review_id
		   ,p_proposal_reason           => l_proposal_reason
		   ,p_proposed_salary_n         => l_proposed_salary_n
		   ,p_review_date		=> l_pay_review_date
		   ,p_attribute1		=> l_attribute1
		   ,p_attribute2		=> l_attribute2
		   ,p_attribute3		=> l_attribute3
		   ,p_attribute4		=> l_attribute4
		   ,p_attribute5         	=> l_attribute5
		   ,p_attribute6		=> l_attribute6
		   ,p_attribute7		=> l_attribute7
		   ,p_attribute8		=> l_attribute8
		   ,p_attribute9		=> l_attribute9
		   ,p_attribute10		=> l_attribute10
		   ,p_attribute11        	=> l_attribute11
		   ,p_attribute12		=> l_attribute12
		   ,p_attribute13		=> l_attribute13
		   ,p_attribute14        	=> l_attribute14
		   ,p_attribute15		=> l_attribute15
		   ,p_attribute16		=> l_attribute16
		   ,p_attribute17        	=> l_attribute17
		   ,p_attribute18		=> l_attribute18
		   ,p_attribute19		=> l_attribute19
		   ,p_attribute20		=> l_attribute20
		   ,p_business_group_id         => p_business_group_id
		   ,p_effective_date            => p_effective_date
		);
                                                          -- derived data factors
		ELSIF C1.api_name = 'DRVDAGE' then
	         FOR l_rec IN c_ler(p_typ_cd =>'DRVDAGE') LOOP
		   l_agf_ler_id := l_rec.ler_id;
		 END LOOP;
		  p_lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;
		  ben_whatif_elig.watif_temporal_lf_evt_API(
		     p_person_id                      => p_person_id
		    ,p_ler_ID                         => l_agf_ler_ID
		    ,p_temporal_lf_evt                => 'AGE'
		    ,p_lf_evt_ocrd_dt                 => l_lf_evt_ocrd_dt
		    ,p_business_group_id              => p_business_group_id
		    ,p_effective_date                 => l_lf_evt_ocrd_dt
		    ,p_tpf_val                        => null
                     );
                ELSIF C1.api_name = 'DRVDLOS' then
	        FOR l_rec IN c_ler(p_typ_cd =>'DRVDLOS') LOOP
		   l_los_ler_ID := l_rec.ler_id;
		END LOOP;
		 p_lf_evt_ocrd_dt := l_lf_evt_ocrd_dt;
		                 ben_whatif_elig.watif_temporal_lf_evt_API(
		                    p_person_id                      => p_person_id
		                   ,p_ler_ID                         => l_los_ler_ID
		                   ,p_temporal_lf_evt                => 'LOS'
		                   ,p_lf_evt_ocrd_dt                 => l_lf_evt_ocrd_dt
		                   ,p_business_group_id              => p_business_group_id
		                   ,p_effective_date                 => l_lf_evt_ocrd_dt
		                   ,p_tpf_val                        => null
                  );
                ELSIF C1.api_name = 'DRVDCAL' then
                FOR l_rec IN c_ler(p_typ_cd =>'DRVDCAL') LOOP
				   l_cal_ler_ID := l_rec.ler_id;
		 END LOOP;
		   l_lf_evt_ocrd_dt  := trunc(p_min_dt(l_lf_evt_ocrd_dt,  l_lf_evt_ocrd_dt1)
                                     + abs((l_lf_evt_ocrd_dt - l_lf_evt_ocrd_dt1)/2));
		 p_lf_evt_ocrd_dt  := l_lf_evt_ocrd_dt;
		                 ben_whatif_elig.watif_temporal_lf_evt_API(
		                    p_person_id                      => p_person_id
		                   ,p_ler_ID                         => l_cal_ler_ID
		                   ,p_temporal_lf_evt                => 'CAL'
		                   ,p_lf_evt_ocrd_dt                 => l_lf_evt_ocrd_dt
		                   ,p_business_group_id              => p_business_group_id
		                   ,p_effective_date                 => l_lf_evt_ocrd_dt
		                   ,p_tpf_val                        => null
                  );
                ELSIF C1.api_name = 'DRVDCMP' then
                FOR l_rec IN c_ler(p_typ_cd =>'DRVDCMP') LOOP
				   l_cmp_ler_ID := l_rec.ler_id;
		 END LOOP;

		  ben_whatif_elig.watif_temporal_lf_evt_API(
                   p_person_id                      => p_person_id
                  ,p_ler_ID                         => l_cmp_ler_ID
                  ,p_temporal_lf_evt                => 'CMP'
                  ,p_lf_evt_ocrd_dt                 => p_effective_date
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  ,p_tpf_val                        => null
                  ,p_cmp_val                        => l_cmp_val
                  ,p_cmp_bnft_val                   => l_cmp_bnft_val
                  ,p_cmp_bal_val                    => l_cmp_bal_val
                  );
                ELSIF C1.api_name = 'DRVDHRW' then
                FOR l_rec IN c_ler(p_typ_cd =>'DRVDHRW') LOOP
				   l_hrw_ler_ID := l_rec.ler_id;
		 END LOOP;
		 ben_whatif_elig.watif_temporal_lf_evt_API(
                   p_person_id                      => p_person_id
                  ,p_ler_ID                         => l_hrw_ler_ID
                  ,p_temporal_lf_evt                => 'HRW'
                  ,p_lf_evt_ocrd_dt                 => p_effective_date
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  ,p_tpf_val                        => null
                  ,p_hwf_val                        => l_hrw_val
                  ,p_hwf_bnft_val                   => l_hrw_bnft_val
                  );
                ELSIF C1.api_name = 'DRVDTPF' then
                FOR l_rec IN c_ler(p_typ_cd =>'DRVDTPF') LOOP
				   l_tpf_ler_ID:= l_rec.ler_id;
		 END LOOP;
		 ben_whatif_elig.watif_temporal_lf_evt_API(
                   p_person_id                      => p_person_id
                  ,p_ler_ID                         => l_tpf_ler_ID
                  ,p_temporal_lf_evt                => 'TPF'
                  ,p_lf_evt_ocrd_dt                 => p_effective_date
                  ,p_business_group_id              => p_business_group_id
                  ,p_effective_date                 => p_effective_date
                  ,p_tpf_val                        => l_tpf_val
                  );
     END IF; --if else ladder
   END LOOP;
if g_debug then
   hr_utility.set_location('Leaving: ' || l_proc,100);
  end if;
END post_ben_changes;
-----------------------------------------------------------------------------------------------

FUNCTION get_coverage_amt(p_elig_per_elctbl_chc_id IN NUMBER
                         ,p_business_group_id IN NUMBER)
RETURN NUMBER IS
 CURSOR csr_get_cvg_amt IS
   SELECT val
     FROM ben_enrt_bnft
    WHERE elig_per_elctbl_chc_id  = p_elig_per_elctbl_chc_id
      AND business_group_id       = p_business_group_id
      AND bnft_typ_cd             = 'CVG' ;

l_coverage_amount  ben_enrt_bnft.val%TYPE;
l_proc             VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'get_coverage_amt';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   OPEN csr_get_cvg_amt;
  FETCH csr_get_cvg_amt INTO l_coverage_amount;
  CLOSE csr_get_cvg_amt;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

 RETURN l_coverage_amount;
--
END get_coverage_amt;
-----------------------------------------------------------------------------------------------
PROCEDURE populate_hierarchy(p_person_id         IN NUMBER
                            ,p_business_group_id IN NUMBER
                            ,p_effective_date    IN DATE
                            ,p_ler_id            IN NUMBER) IS
--------------root node label-----------
Cursor csr_root_label IS
Select Meaning
From hr_lookups
Where lookup_type='BEN_SS_DRVD_LABELS'
  and lookup_code='COBJ';
---------------per in ler---------------
CURSOR csr_ler IS
Select pil.per_in_ler_id,
       ler.name           name,
       ler.ler_id
From   ben_per_in_ler  pil,
       ben_ler_f ler
Where  pil.person_id           =  p_person_id
   AND ler.ler_id              =  pil.ler_id
   AND p_effective_date BETWEEN ler.effective_start_date and ler.effective_end_date
   AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
   AND pil.lf_evt_ocrd_dt     <=  p_effective_date
   AND pil.business_group_id   =  p_business_group_id
   AND ler.typ_cd              NOT IN ('COMP','SCHEDDU','SCHEDDO')
   ORDER BY pil.lf_evt_ocrd_dt desc, 1 desc;

--------------------Program------------------
CURSOR csr_pgms(p_per_in_ler_id NUMBER) IS
Select  pgm.pgm_id
       ,pgm.name
       ,pgm.pgm_uom uom
       ,pgm.acty_ref_perd_cd acty_ref_perd_cd
       ,popl.pil_elctbl_chc_popl_id
From  ben_pil_elctbl_chc_popl popl,
      ben_pgm_f pgm
Where popl.per_in_ler_id = p_per_in_ler_id
  and popl.pgm_id        =pgm.pgm_id
  and p_effective_date between pgm.effective_start_date and pgm.effective_end_date;

--------------------------Plan type not in program------------------
CURSOR csr_pl_types_not_in_program(p_per_in_ler_id NUMBER) IS
Select distinct pt.pl_typ_id,
       pt.name
From   ben_pl_typ_f pt,
       ben_elig_per_elctbl_chc epe,
       ben_pil_elctbl_chc_popl popl
Where  pt.pl_typ_id  = epe.pl_typ_id
       and popl.per_in_ler_id          = p_per_in_ler_id
       and popl.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
       and epe.comp_lvl_cd             = 'PLAN'
       and popl.pl_id                  = epe.pl_id
       and p_effective_date between pt.effective_start_date and pt.effective_end_date;

----------------------plan type in program-------------------
/*CURSOR csr_pl_types_in_program(p_pil_elctbl_chc_popl_id NUMBER) IS
Select pt.pl_typ_id
      ,pt.name
      ,epe.ptip_id
From   ben_elig_per_elctbl_chc epe,
       ben_pl_typ_f pt
Where  epe.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
   and epe.pl_typ_id              = pt.pl_typ_id
   and epe.comp_lvl_cd            = 'PLAN'
   and p_effective_date between pt.effective_start_date and pt.effective_end_date;*/
CURSOR csr_pl_types_in_program(p_pil_elctbl_chc_popl_id NUMBER) IS
Select pt.pl_typ_id,
       pt.name,
       ptip.ptip_id
From   ben_pl_typ_f pt,
       ben_ptip_f ptip
Where
       ptip.pl_typ_id=pt.pl_typ_id
   and pt.pl_typ_id in (  Select epe.pl_typ_id
                          From ben_elig_per_elctbl_chc epe
	                  Where epe.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
	                    and epe.comp_lvl_cd            = 'PLAN'
			   and epe.pgm_id=ptip.pgm_id
		       )
	and p_effective_date between pt.effective_start_date and pt.effective_end_date
	and p_effective_date between ptip.effective_start_date and ptip.effective_end_date;

----------------plans----------------(IN  pgm_id and pl_typ_id)------------
CURSOR csr_plans(p_per_in_ler_id NUMBER
                ,p_pl_typ_id     NUMBER
                ,p_pgm_id        NUMBER) IS
Select epe.pl_id,
       epe.plip_id,
       pl.name name,
       pl.nip_pl_uom uom,
       pl.nip_acty_ref_perd_cd acty_ref_perd_cd,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_pl_f pl,
       ben_elig_per_elctbl_chc epe
Where
       epe.per_in_ler_id = p_per_in_ler_id
   and epe.comp_lvl_cd   = 'PLAN'
   and epe.pl_id         = pl.pl_id
   and epe.pl_typ_id     = p_pl_typ_id
   and nvl(epe.pgm_id ,-1) = p_pgm_id
   and p_effective_date between pl.effective_start_date and effective_end_date;
   ----------------------------options-------------------------------------
CURSOR csr_options_in_plip(p_per_in_ler_id NUMBER, p_plip_id NUMBER) IS
Select opt.opt_id,
       oipl.oipl_id,
       opt.name,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_elig_per_elctbl_chc epe,
       ben_oipl_f              oipl,
       ben_opt_f               opt
Where  epe.per_in_ler_id   = p_per_in_ler_id
  AND  epe.plip_id    = p_plip_id
  AND  epe.comp_lvl_cd = 'OIPL'
  AND  epe.oipl_id     = oipl.oipl_id
  AND  oipl.opt_id     = opt.opt_id
  AND  p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  AND  p_effective_date between  opt.effective_start_date and  opt.effective_end_date;

CURSOR csr_options_in_pnip(p_per_in_ler_id NUMBER, p_pl_id NUMBER) IS
Select opt.opt_id,
       oipl.oipl_id,
       opt.name,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_elig_per_elctbl_chc epe,
       ben_oipl_f              oipl,
       ben_opt_f               opt
Where  epe.per_in_ler_id   = p_per_in_ler_id
  AND  epe.plip_id is NULL and epe.pl_id=p_pl_id
  AND  epe.comp_lvl_cd = 'OIPL'
  AND  epe.oipl_id     = oipl.oipl_id
  AND  oipl.opt_id     = opt.opt_id
  AND  p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  AND  p_effective_date between  opt.effective_start_date and  opt.effective_end_date;
   -----------------------------------rates------------------------------------------------
CURSOR csr_rates (p_elig_per_elctbl_chc_id NUMBER) IS
Select abr.name,
       abr.acty_base_rt_id,
       ecr.enrt_rt_id,
       decode(ecr.entr_val_at_enrt_flag, 'Y', ecr.dflt_val, ecr.val) val,
       ecr.cmcd_val,
       ecr.cmcd_acty_ref_perd_cd,
       ecr.nnmntry_uom
From   ben_enrt_rt             ecr,
       ben_acty_base_rt_f      abr
Where  ecr.elig_per_elctbl_chc_id  =  p_elig_per_elctbl_chc_id
   AND ecr.dsply_on_enrt_flag = 'Y'
   AND ecr.enrt_bnft_id IS NULL
   AND abr.acty_base_rt_id = ecr.acty_base_rt_id
   AND p_effective_date BETWEEN abr.effective_start_date AND abr.effective_end_date

UNION ALL
Select abr.name,
       abr.acty_base_rt_id,
       ecr.enrt_rt_id,
       decode(ecr.entr_val_at_enrt_flag, 'Y', ecr.dflt_val, ecr.val) val,
       ecr.cmcd_val,
       ecr.cmcd_acty_ref_perd_cd,
       ecr.nnmntry_uom
From   ben_enrt_rt             ecr,
       ben_enrt_bnft           enb,
       ben_acty_base_rt_f      abr
Where  enb.elig_per_elctbl_chc_id  =  p_elig_per_elctbl_chc_id
  AND  ecr.dsply_on_enrt_flag = 'Y'
  AND  enb.enrt_bnft_id = ecr.enrt_bnft_id
  AND  abr.acty_base_rt_id = ecr.acty_base_rt_id
  AND  p_effective_date between abr.effective_start_date and abr.effective_end_date;


--
l_per_in_ler_id   NUMBER;
l_counter         NUMBER := 1;
l_hierarchy_id    NUMBER;
l_proc            VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || '.populate_hierarchy';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;


 OPEN csr_ler ;
 FETCH csr_ler INTO  l_per_in_ler_id
                    ,g_hierarchy(l_counter).name
                    ,l_hierarchy_id ;
 CLOSE csr_ler;
 OPEN csr_root_label;
  FETCH csr_root_label into g_hierarchy(l_counter).name;
 CLOSE csr_root_label;

 g_hierarchy(l_counter).person_id             := p_person_id;
 g_hierarchy(l_counter).business_group_id     := p_business_group_id;
 g_hierarchy(l_counter).ler_id                := p_ler_id;
 g_hierarchy(l_counter).hierarchy_id          := l_hierarchy_id;
 g_hierarchy(l_counter).hierarchy_type        := 'LE';
 g_hierarchy(l_counter).parent_hierarchy_id   := -9999;
 g_hierarchy(l_counter).parent_hierarchy_type := NULL;

 FOR csr_pgm_rec IN csr_pgms(l_per_in_ler_id) LOOP
     l_counter := l_counter + 1;
     g_hierarchy(l_counter).hierarchy_id          := csr_pgm_rec.pgm_id;
     g_hierarchy(l_counter).name                  := csr_pgm_rec.name;
     g_hierarchy(l_counter).parent_hierarchy_id   := l_hierarchy_id;
     g_hierarchy(l_counter).parent_hierarchy_type := 'LE';
     g_hierarchy(l_counter).hierarchy_type        := 'PGM';
     g_hierarchy(l_counter).person_id             := p_person_id;
     g_hierarchy(l_counter).business_group_id     := p_business_group_id;
     g_hierarchy(l_counter).ler_id                := p_ler_id;
     g_hierarchy(l_counter).uom                   := csr_pgm_rec.uom;
     g_hierarchy(l_counter).acty_ref_perd_cd      := csr_pgm_rec.acty_ref_perd_cd;
     FOR csr_pgm_pt_rec IN csr_pl_types_in_program(csr_pgm_rec.pil_elctbl_chc_popl_id) LOOP
         l_counter := l_counter + 1;
         g_hierarchy(l_counter).hierarchy_type        := 'PTIP';
         g_hierarchy(l_counter).person_id             := p_person_id;
         g_hierarchy(l_counter).business_group_id     := p_business_group_id;
         g_hierarchy(l_counter).ler_id                := p_ler_id;
         g_hierarchy(l_counter).hierarchy_id          := csr_pgm_pt_rec.ptip_id;
         g_hierarchy(l_counter).name                  := csr_pgm_pt_rec.name;
         g_hierarchy(l_counter).parent_hierarchy_id   := csr_pgm_rec.pgm_id;
         g_hierarchy(l_counter).parent_hierarchy_type := 'PGM';

         FOR csr_plans_in_program_rec IN csr_plans(l_per_in_ler_id, csr_pgm_pt_rec.pl_typ_id, csr_pgm_rec.pgm_id ) LOOP
             l_counter := l_counter + 1;
             g_hierarchy(l_counter).hierarchy_type        := 'PLIP';
             g_hierarchy(l_counter).person_id             := p_person_id;
             g_hierarchy(l_counter).business_group_id     := p_business_group_id;
             g_hierarchy(l_counter).ler_id                := p_ler_id;
             g_hierarchy(l_counter).hierarchy_id          := csr_plans_in_program_rec.plip_id;
             g_hierarchy(l_counter).name                  := csr_plans_in_program_rec.name;
             g_hierarchy(l_counter).parent_hierarchy_id   := csr_pgm_pt_rec.ptip_id;
             g_hierarchy(l_counter).parent_hierarchy_type := 'PTIP';
             g_hierarchy(l_counter).uom                   := csr_pgm_rec.uom;
             g_hierarchy(l_counter).acty_ref_perd_cd      := NULL;
             g_hierarchy(l_counter).crrnt_elctbl_flag     := csr_plans_in_program_rec.elctbl_flag;
             g_hierarchy(l_counter).crrnt_cvg_val         := get_coverage_amt(csr_plans_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
             FOR csr_rates_rec IN csr_rates(csr_plans_in_program_rec.elig_per_elctbl_chc_id) LOOP
	                      l_counter := l_counter + 1;
	                      g_hierarchy(l_counter).hierarchy_type              := 'ERT';
	                      g_hierarchy(l_counter).person_id                   := p_person_id;
	                      g_hierarchy(l_counter).business_group_id           := p_business_group_id;
	                      g_hierarchy(l_counter).ler_id                      := p_ler_id;
	                      g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
	                      g_hierarchy(l_counter).name                        := csr_rates_rec.name;
	                      g_hierarchy(l_counter).parent_hierarchy_id         := csr_plans_in_program_rec.plip_id;
	                      g_hierarchy(l_counter).parent_hierarchy_type       := 'PLIP';
	                      g_hierarchy(l_counter).uom                         := csr_pgm_rec.uom;
	                      g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
	                      g_hierarchy(l_counter).crrnt_val                   := csr_rates_rec.val;
	                      g_hierarchy(l_counter).crrnt_cmcd_val              := csr_rates_rec.cmcd_val;
	                      g_hierarchy(l_counter).crrnt_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
             END LOOP;--rate in plan in program
             FOR csr_options_plip_rec IN csr_options_in_plip(l_per_in_ler_id, csr_plans_in_program_rec.plip_id) LOOP
                 l_counter := l_counter + 1;
                 g_hierarchy(l_counter).hierarchy_type        := 'OIPLIP';
                 g_hierarchy(l_counter).person_id             := p_person_id;
                 g_hierarchy(l_counter).business_group_id     := p_business_group_id;
                 g_hierarchy(l_counter).ler_id                := p_ler_id;
                 g_hierarchy(l_counter).hierarchy_id          := csr_options_plip_rec.oipl_id;
                 g_hierarchy(l_counter).name                  := csr_options_plip_rec.name;
                 g_hierarchy(l_counter).parent_hierarchy_id   := csr_plans_in_program_rec.plip_id;
                 g_hierarchy(l_counter).parent_hierarchy_type := 'PLIP';
                 g_hierarchy(l_counter).uom                   := csr_pgm_rec.uom;
                 g_hierarchy(l_counter).crrnt_elctbl_flag     := csr_options_plip_rec.elctbl_flag;
                 g_hierarchy(l_counter).crrnt_cvg_val         := get_coverage_amt(csr_options_plip_rec.elig_per_elctbl_chc_id,p_business_group_id);
                 FOR csr_rates_rec IN csr_rates( csr_options_plip_rec.elig_per_elctbl_chc_id) LOOP
                     l_counter := l_counter + 1;
                     g_hierarchy(l_counter).hierarchy_type              := 'ERT';
                     g_hierarchy(l_counter).person_id                   := p_person_id;
                     g_hierarchy(l_counter).business_group_id           := p_business_group_id;
                     g_hierarchy(l_counter).ler_id                      := p_ler_id;
                     g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
                     g_hierarchy(l_counter).name                        := csr_rates_rec.name;
                     g_hierarchy(l_counter).parent_hierarchy_id         := csr_options_plip_rec.oipl_id;
                     g_hierarchy(l_counter).parent_hierarchy_type       := 'OIPLIP';
                     g_hierarchy(l_counter).uom                         := csr_pgm_rec.uom;
                     g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
                     g_hierarchy(l_counter).crrnt_val                   := csr_rates_rec.val;
                     g_hierarchy(l_counter).crrnt_cmcd_val              := csr_rates_rec.cmcd_val;
                     g_hierarchy(l_counter).crrnt_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
                 END LOOP;-- rate in option in plan in program
             END LOOP; -- option in plan in program

         END LOOP;    -- plan in program
     END LOOP;  -- plan type in program
  END LOOP;  -- program
  FOR csr_pt_not_in_pgm_rec IN csr_pl_types_not_in_program(l_per_in_ler_id ) LOOP
            l_counter := l_counter + 1;
            g_hierarchy(l_counter).hierarchy_type        := 'PT';
            g_hierarchy(l_counter).person_id             := p_person_id;
            g_hierarchy(l_counter).business_group_id     := p_business_group_id;
            g_hierarchy(l_counter).ler_id                := p_ler_id;
            g_hierarchy(l_counter).hierarchy_id          := csr_pt_not_in_pgm_rec.pl_typ_id;
            g_hierarchy(l_counter).name                  := csr_pt_not_in_pgm_rec.name;
            g_hierarchy(l_counter).parent_hierarchy_id   := l_hierarchy_id;
            g_hierarchy(l_counter).parent_hierarchy_type := 'LE';
     FOR csr_plans_not_in_program_rec IN csr_plans(l_per_in_ler_id , csr_pt_not_in_pgm_rec.pl_typ_id,-1) LOOP
         l_counter := l_counter + 1;
         g_hierarchy(l_counter).hierarchy_type        := 'PNIP';
         g_hierarchy(l_counter).person_id             := p_person_id;
         g_hierarchy(l_counter).business_group_id     := p_business_group_id;
         g_hierarchy(l_counter).ler_id                := p_ler_id;
         g_hierarchy(l_counter).hierarchy_id          := csr_plans_not_in_program_rec.pl_id;
         g_hierarchy(l_counter).name                  := csr_plans_not_in_program_rec.name;
         g_hierarchy(l_counter).parent_hierarchy_id   := csr_pt_not_in_pgm_rec.pl_typ_id;
         g_hierarchy(l_counter).parent_hierarchy_type := 'PT';
         g_hierarchy(l_counter).uom                   := csr_plans_not_in_program_rec.uom;
         g_hierarchy(l_counter).acty_ref_perd_cd      := csr_plans_not_in_program_rec.acty_ref_perd_cd;
         g_hierarchy(l_counter).crrnt_elctbl_flag     := csr_plans_not_in_program_rec.elctbl_flag;
         g_hierarchy(l_counter).crrnt_cvg_val         := get_coverage_amt(csr_plans_not_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
         FOR csr_rates_rec IN csr_rates( csr_plans_not_in_program_rec.elig_per_elctbl_chc_id) LOOP
	                  l_counter := l_counter + 1;
	                  g_hierarchy(l_counter).hierarchy_type              := 'ERT';
	                  g_hierarchy(l_counter).person_id                   := p_person_id;
	                  g_hierarchy(l_counter).business_group_id           := p_business_group_id;
	                  g_hierarchy(l_counter).ler_id                      := p_ler_id;
	                  g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
	                  g_hierarchy(l_counter).name                        := csr_rates_rec.name;
	                  g_hierarchy(l_counter).parent_hierarchy_id         := csr_plans_not_in_program_rec.pl_id;
	                  g_hierarchy(l_counter).parent_hierarchy_type       := 'PNIP';
	                  g_hierarchy(l_counter).uom                         := csr_plans_not_in_program_rec.uom;
	                  g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
	                  g_hierarchy(l_counter).crrnt_val                   := csr_rates_rec.val;
	                  g_hierarchy(l_counter).crrnt_cmcd_val              := csr_rates_rec.cmcd_val;
	                  g_hierarchy(l_counter).crrnt_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
         END LOOP;
         FOR csr_options_pnip_rec IN csr_options_in_pnip(l_per_in_ler_id ,csr_plans_not_in_program_rec.pl_id) LOOP
             l_counter := l_counter + 1;
             g_hierarchy(l_counter).hierarchy_type        := 'OIPNIP';
             g_hierarchy(l_counter).person_id             := p_person_id;
             g_hierarchy(l_counter).business_group_id     := p_business_group_id;
             g_hierarchy(l_counter).ler_id                := p_ler_id;
             g_hierarchy(l_counter).hierarchy_id          := csr_options_pnip_rec.oipl_id;
             g_hierarchy(l_counter).name                  := csr_options_pnip_rec.name;
             g_hierarchy(l_counter).parent_hierarchy_id   := csr_plans_not_in_program_rec.pl_id;
             g_hierarchy(l_counter).parent_hierarchy_type := 'PNIP';
             g_hierarchy(l_counter).uom                   := csr_plans_not_in_program_rec.uom;
             g_hierarchy(l_counter).crrnt_elctbl_flag     := csr_options_pnip_rec.elctbl_flag;
             g_hierarchy(l_counter).crrnt_cvg_val         := get_coverage_amt(csr_options_pnip_rec.elig_per_elctbl_chc_id,p_business_group_id);
             FOR csr_rates_rec IN csr_rates( csr_options_pnip_rec.elig_per_elctbl_chc_id) LOOP
                 l_counter := l_counter + 1;
                 g_hierarchy(l_counter).hierarchy_type              := 'ERT';
                 g_hierarchy(l_counter).person_id                   := p_person_id;
                 g_hierarchy(l_counter).business_group_id           := p_business_group_id;
                 g_hierarchy(l_counter).ler_id                      := p_ler_id;
                 g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
                 g_hierarchy(l_counter).name                        := csr_rates_rec.name;
                 g_hierarchy(l_counter).parent_hierarchy_id         := csr_options_pnip_rec.oipl_id;
                 g_hierarchy(l_counter).parent_hierarchy_type       := 'OIPNIP';
                 g_hierarchy(l_counter).uom                         := csr_plans_not_in_program_rec.uom;
                 g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
                 g_hierarchy(l_counter).crrnt_val                   := csr_rates_rec.val;
                 g_hierarchy(l_counter).crrnt_cmcd_val              := csr_rates_rec.cmcd_val;
                 g_hierarchy(l_counter).crrnt_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
             END LOOP;-- rate in option in plan not in program
         END LOOP; --option in plan not in program

     END LOOP; -- plan not in program
 END LOOP;  -- plan type not in program

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END populate_hierarchy;
-----------------------------------------------------------------------------------------------

FUNCTION get_ler_index RETURN NUMBER IS
l_index NUMBER := 1;
l_proc  VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'get_ler_index';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).hierarchy_type = 'LE' THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_pl_typ_exists(p_pl_typ_id  IN NUMBER)
RETURN NUMBER IS
l_index NUMBER := 0;
l_proc  VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_pl_typ_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).hierarchy_id = p_pl_typ_id AND g_hierarchy(i).hierarchy_type = 'PT'
          AND g_hierarchy(i).parent_hierarchy_type = 'LE' THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_pgm_exists(p_pgm_id      IN NUMBER)
RETURN NUMBER IS
--
l_index NUMBER := 0;
l_proc  VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_pgm_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_type = 'LE'
          AND g_hierarchy(i).hierarchy_id = p_pgm_id AND g_hierarchy(i).hierarchy_type = 'PGM'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_pt_in_pgm_exists(p_pgm_id IN NUMBER
                             ,p_ptip_id IN NUMBER
                             )
RETURN NUMBER IS
l_index NUMBER := 0;
l_proc  VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || '.chk_pt_in_pgm_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).hierarchy_id = p_ptip_id AND g_hierarchy(i).hierarchy_type = 'PTIP'
          AND g_hierarchy(i).parent_hierarchy_type = 'PGM' AND g_hierarchy(i).parent_hierarchy_id = p_pgm_id THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_plip_exists(p_ptip_id      IN NUMBER
                        ,p_pl_id       IN NUMBER)
RETURN NUMBER IS
--
l_index NUMBER      := 0;
l_proc  VARCHAR2(72);
BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_plip_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_ptip_id AND g_hierarchy(i).parent_hierarchy_type = 'PTIP'
          AND g_hierarchy(i).hierarchy_id = p_pl_id AND g_hierarchy(i).hierarchy_type = 'PLIP'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_pnip_exists(p_pl_typ_id      IN NUMBER
                        ,p_pl_id          IN NUMBER)
RETURN NUMBER IS
l_index NUMBER      := 0;
l_proc  VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_pnip_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_pl_typ_id AND g_hierarchy(i).parent_hierarchy_type = 'PT'
          AND g_hierarchy(i).hierarchy_id = p_pl_id AND g_hierarchy(i).hierarchy_type = 'PNIP'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_opt_in_plip_exists(p_pl_id  IN NUMBER
                               ,p_opt_id IN NUMBER)
RETURN NUMBER IS
--
l_index NUMBER      := 0;
l_proc  VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_opt_in_plip_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_pl_id AND g_hierarchy(i).parent_hierarchy_type = 'PLIP'
          AND g_hierarchy(i).hierarchy_id = p_opt_id AND g_hierarchy(i).hierarchy_type = 'OIPLIP'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_opt_in_pnip_exists(p_pl_id  IN NUMBER
                               ,p_opt_id IN NUMBER)
RETURN NUMBER IS
--
l_index NUMBER      := 0;
l_proc  VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_opt_in_pnip_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_pl_id AND g_hierarchy(i).parent_hierarchy_type = 'PNIP'
          AND g_hierarchy(i).hierarchy_id = p_opt_id AND g_hierarchy(i).hierarchy_type = 'OIPNIP'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_rate_exists(p_opt_id          IN NUMBER
                        ,p_acty_base_rt_id IN NUMBER )
RETURN NUMBER IS
--
l_index NUMBER      := 0;
l_proc  VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_rate_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_opt_id AND (g_hierarchy(i).parent_hierarchy_type = 'OIPLIP' OR g_hierarchy(i).parent_hierarchy_type = 'OIPNIP')
          AND g_hierarchy(i).hierarchy_id = p_acty_base_rt_id AND g_hierarchy(i).hierarchy_type = 'ERT'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------

FUNCTION chk_pl_rate_exists(p_pl_id           IN NUMBER
                           ,p_acty_base_rt_id IN NUMBER )
RETURN NUMBER IS

l_index NUMBER := 0;
l_proc  VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'chk_pl_rate_exists';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

   FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
       IF g_hierarchy(i).parent_hierarchy_id = p_pl_id AND (g_hierarchy(i).parent_hierarchy_type = 'PLIP' OR g_hierarchy(i).parent_hierarchy_type = 'PNIP')
          AND g_hierarchy(i).hierarchy_id = p_acty_base_rt_id AND g_hierarchy(i).hierarchy_type = 'ERT'  THEN
          l_index := i;
          EXIT;
       END IF;
   END LOOP;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;

   RETURN l_index;
END;
-----------------------------------------------------------------------------------------------
PROCEDURE populate_proposed_hierarchy(p_person_id         IN NUMBER
                                     ,p_business_group_id IN NUMBER
                                     ,p_effective_date    IN DATE
                                     ,p_ler_id            IN NUMBER) IS
--------------root node label-----------
Cursor csr_root_label IS
Select Meaning
From hr_lookups
Where lookup_type='BEN_SS_DRVD_LABELS'
  and lookup_code='COBJ';
---------------per in ler---------------
CURSOR csr_ler IS
Select pil.per_in_ler_id,
       ler.name           name,
       ler.ler_id
From   ben_per_in_ler  pil,
       ben_ler_f ler
Where  pil.person_id           =  p_person_id
   AND ler.ler_id              =  pil.ler_id
   AND p_effective_date BETWEEN ler.effective_start_date and ler.effective_end_date
   AND pil.per_in_ler_stat_cd IN ('STRTD', 'PROCD')
   AND pil.lf_evt_ocrd_dt     <=  p_effective_date
   AND pil.business_group_id   =  p_business_group_id
   AND ler.typ_cd              NOT IN ('COMP','SCHEDDU','SCHEDDO')
   ORDER BY pil.lf_evt_ocrd_dt desc, 1 desc;

--------------------Program------------------
CURSOR csr_pgms(p_per_in_ler_id NUMBER) IS
Select  pgm.pgm_id
       ,pgm.name
       ,pgm.pgm_uom uom
       ,pgm.acty_ref_perd_cd acty_ref_perd_cd
       ,popl.pil_elctbl_chc_popl_id
From  ben_pil_elctbl_chc_popl popl,
      ben_pgm_f pgm
Where popl.per_in_ler_id = p_per_in_ler_id
  and popl.pgm_id        =pgm.pgm_id
  and p_effective_date between pgm.effective_start_date and pgm.effective_end_date;

--------------------------Plan type not in program------------------
CURSOR csr_pl_types_not_in_program(p_per_in_ler_id NUMBER) IS
Select pt.pl_typ_id,
       pt.name
From   ben_pl_typ_f pt
Where  pt.pl_typ_id IN ( Select epe.pl_typ_id
                           From ben_elig_per_elctbl_chc epe,
				ben_pil_elctbl_chc_popl popl
                          Where popl.per_in_ler_id          = p_per_in_ler_id
			    and popl.pil_elctbl_chc_popl_id = epe.pil_elctbl_chc_popl_id
			    and epe.comp_lvl_cd             = 'PLAN'
			    and popl.pl_id                  = epe.pl_id
                        )
   and p_effective_date between pt.effective_start_date and pt.effective_end_date;

----------------------plan type in program-------------------
/*CURSOR csr_pl_types_in_program(p_pil_elctbl_chc_popl_id NUMBER) IS
Select pt.pl_typ_id
      ,pt.name
      ,epe.ptip_id
From   ben_elig_per_elctbl_chc epe,
       ben_pl_typ_f pt
Where  epe.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
   and epe.pl_typ_id              = pt.pl_typ_id
   and epe.comp_lvl_cd            = 'PLAN'
   and p_effective_date between pt.effective_start_date and pt.effective_end_date;*/
CURSOR csr_pl_types_in_program(p_pil_elctbl_chc_popl_id NUMBER) IS
Select pt.pl_typ_id,
       pt.name,
       ptip.ptip_id
From   ben_pl_typ_f pt,
       ben_ptip_f ptip
Where
       ptip.pl_typ_id=pt.pl_typ_id
   and pt.pl_typ_id in (  Select epe.pl_typ_id
                          From ben_elig_per_elctbl_chc epe
	                  Where epe.pil_elctbl_chc_popl_id = p_pil_elctbl_chc_popl_id
	                    and epe.comp_lvl_cd            = 'PLAN'
			   and epe.pgm_id=ptip.pgm_id
		       )
	and p_effective_date between pt.effective_start_date and pt.effective_end_date
	and p_effective_date between ptip.effective_start_date and ptip.effective_end_date;

----------------plans----------------(IN  pgm_id and pl_typ_id)------------
CURSOR csr_plans(p_per_in_ler_id NUMBER
                ,p_pl_typ_id     NUMBER
                ,p_pgm_id        NUMBER) IS
Select epe.pl_id,
       epe.plip_id,
       pl.name name,
       pl.nip_pl_uom uom,
       pl.nip_acty_ref_perd_cd acty_ref_perd_cd,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_pl_f pl,
       ben_elig_per_elctbl_chc epe
Where
       epe.per_in_ler_id = p_per_in_ler_id
   and epe.comp_lvl_cd   = 'PLAN'
   and epe.pl_id         = pl.pl_id
   and epe.pl_typ_id     = p_pl_typ_id
   and nvl(epe.pgm_id ,-1) = p_pgm_id
   and p_effective_date between pl.effective_start_date and effective_end_date;
   ----------------------------options-------------------------------------
CURSOR csr_options_in_plip(p_per_in_ler_id NUMBER, p_plip_id NUMBER) IS
Select opt.opt_id,
       oipl.oipl_id,
       opt.name,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_elig_per_elctbl_chc epe,
       ben_oipl_f              oipl,
       ben_opt_f               opt
Where  epe.per_in_ler_id   = p_per_in_ler_id
  AND  epe.plip_id    = p_plip_id
  AND  epe.comp_lvl_cd = 'OIPL'
  AND  epe.oipl_id     = oipl.oipl_id
  AND  oipl.opt_id     = opt.opt_id
  AND  p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  AND  p_effective_date between  opt.effective_start_date and  opt.effective_end_date;

CURSOR csr_options_in_pnip(p_per_in_ler_id NUMBER, p_pl_id NUMBER) IS
Select opt.opt_id,
       oipl.oipl_id,
       opt.name,
       epe.elctbl_flag,
       epe.elig_per_elctbl_chc_id
From   ben_elig_per_elctbl_chc epe,
       ben_oipl_f              oipl,
       ben_opt_f               opt
Where  epe.per_in_ler_id   = p_per_in_ler_id
  AND  epe.plip_id is NULL and epe.pl_id=p_pl_id
  AND  epe.comp_lvl_cd = 'OIPL'
  AND  epe.oipl_id     = oipl.oipl_id
  AND  oipl.opt_id     = opt.opt_id
  AND  p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  AND  p_effective_date between  opt.effective_start_date and  opt.effective_end_date;
   -----------------------------------rates------------------------------------------------
CURSOR csr_rates (p_elig_per_elctbl_chc_id NUMBER) IS
Select abr.name,
       abr.acty_base_rt_id,
       ecr.enrt_rt_id,
       decode(ecr.entr_val_at_enrt_flag, 'Y', ecr.dflt_val, ecr.val) val,
       ecr.cmcd_val,
       ecr.cmcd_acty_ref_perd_cd,
       ecr.nnmntry_uom
From   ben_enrt_rt             ecr,
       ben_acty_base_rt_f      abr
Where  ecr.elig_per_elctbl_chc_id  =  p_elig_per_elctbl_chc_id
   AND ecr.dsply_on_enrt_flag = 'Y'
   AND ecr.enrt_bnft_id IS NULL
   AND abr.acty_base_rt_id = ecr.acty_base_rt_id
   AND p_effective_date BETWEEN abr.effective_start_date AND abr.effective_end_date

UNION ALL
Select abr.name,
       abr.acty_base_rt_id,
       ecr.enrt_rt_id,
       decode(ecr.entr_val_at_enrt_flag, 'Y', ecr.dflt_val, ecr.val) val,
       ecr.cmcd_val,
       ecr.cmcd_acty_ref_perd_cd,
       ecr.nnmntry_uom
From   ben_enrt_rt             ecr,
       ben_enrt_bnft           enb,
       ben_acty_base_rt_f      abr
Where  enb.elig_per_elctbl_chc_id  =  p_elig_per_elctbl_chc_id
  AND  ecr.dsply_on_enrt_flag = 'Y'
  AND  enb.enrt_bnft_id = ecr.enrt_bnft_id
  AND  abr.acty_base_rt_id = ecr.acty_base_rt_id
  AND  p_effective_date between abr.effective_start_date and abr.effective_end_date;

--
l_proc          VARCHAR2(72);
l_per_in_ler_id NUMBER;
l_hierarchy_id  NUMBER;
l_name          VARCHAR2(240);

l_counter       NUMBER := g_hierarchy.LAST;

l_index         NUMBER;


BEGIN
--
  if g_debug then
    l_proc := g_package || 'populate_proposed_hierarchy';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

 OPEN csr_ler ;
 FETCH csr_ler INTO  l_per_in_ler_id
                    ,l_name
                    ,l_hierarchy_id ;
 CLOSE csr_ler;
 OPEN csr_root_label;
 FETCH csr_root_label into l_name;
 CLOSE csr_root_label;
 l_index := get_ler_index;

 IF l_hierarchy_id <> nvl(g_hierarchy(l_index).hierarchy_id,-1) THEN

    g_hierarchy(l_index).person_id             := p_person_id;
    g_hierarchy(l_index).business_group_id     := p_business_group_id;
    g_hierarchy(l_index).ler_id                := p_ler_id;
    g_hierarchy(l_index).hierarchy_id          := nvl(g_hierarchy(l_index).hierarchy_id,l_hierarchy_id);
    g_hierarchy(l_index).hierarchy_type        := 'LE';
    g_hierarchy(l_index).name                  := l_name;
    g_hierarchy(l_index).parent_hierarchy_id   := -9999;
    g_hierarchy(l_index).parent_hierarchy_type := NULL;
    l_hierarchy_id :=g_hierarchy(l_index).hierarchy_id; -- added by me
    /*
    FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
      IF g_hierarchy(i).hierarchy_type = 'PT' AND g_hierarchy(i).parent_hierarchy_type = 'LE' THEN
          g_hierarchy(i).parent_hierarchy_id := l_hierarchy_id;
      END IF;
   END LOOP;*/
 END IF;
FOR csr_pgms_rec IN csr_pgms(l_per_in_ler_id) LOOP
         l_index := chk_pgm_exists(p_pgm_id    => csr_pgms_rec.pgm_id);
         IF l_index = 0 THEN
            l_counter := l_counter + 1;
            g_hierarchy(l_counter).hierarchy_type        := 'PGM';
            g_hierarchy(l_counter).person_id             := p_person_id;
            g_hierarchy(l_counter).business_group_id     := p_business_group_id;
            g_hierarchy(l_counter).ler_id                := p_ler_id;
            g_hierarchy(l_counter).hierarchy_id          := csr_pgms_rec.pgm_id;
            g_hierarchy(l_counter).name                  := csr_pgms_rec.name;
            g_hierarchy(l_counter).parent_hierarchy_id   := l_hierarchy_id;
            g_hierarchy(l_counter).parent_hierarchy_type := 'LE';
            g_hierarchy(l_counter).uom                   := csr_pgms_rec.uom;
            g_hierarchy(l_counter).acty_ref_perd_cd      := csr_pgms_rec.acty_ref_perd_cd;
         ELSE
            g_hierarchy(l_index).name                    := csr_pgms_rec.name;
            g_hierarchy(l_index).uom                     := csr_pgms_rec.uom;
            g_hierarchy(l_index).acty_ref_perd_cd        := csr_pgms_rec.acty_ref_perd_cd;
         END IF;

  FOR csr_pgm_pt_rec IN csr_pl_types_in_program(csr_pgms_rec.pil_elctbl_chc_popl_id) LOOP
     l_index   := chk_pt_in_pgm_exists(p_pgm_id => csr_pgms_rec.pgm_id
                                      ,p_ptip_id =>csr_pgm_pt_rec.ptip_id);
     IF l_index = 0 THEN
        l_counter := l_counter + 1;
        g_hierarchy(l_counter).person_id             := p_person_id;
        g_hierarchy(l_counter).business_group_id     := p_business_group_id;
        g_hierarchy(l_counter).ler_id                := p_ler_id;
        g_hierarchy(l_counter).hierarchy_id          := csr_pgm_pt_rec.ptip_id;
        g_hierarchy(l_counter).hierarchy_type        := 'PTIP';
        g_hierarchy(l_counter).name                  := csr_pgm_pt_rec.name;
        g_hierarchy(l_counter).parent_hierarchy_id   := csr_pgms_rec.pgm_id;
        g_hierarchy(l_counter).parent_hierarchy_type := 'PGM';
     ELSE
        g_hierarchy(l_index).name                    := csr_pgm_pt_rec.name;
     END IF;

         FOR csr_plans_in_program_rec IN csr_plans(l_per_in_ler_id, csr_pgm_pt_rec.pl_typ_id, csr_pgms_rec.pgm_id ) LOOP
             l_index := chk_plip_exists(p_ptip_id  => csr_pgm_pt_rec.ptip_id
                                       ,p_pl_id   => csr_plans_in_program_rec.plip_id);
             IF l_index = 0 THEN
                l_counter := l_counter + 1;
                g_hierarchy(l_counter).hierarchy_type        := 'PLIP';
                g_hierarchy(l_counter).person_id             := p_person_id;
                g_hierarchy(l_counter).business_group_id     := p_business_group_id;
                g_hierarchy(l_counter).ler_id                := p_ler_id;
                g_hierarchy(l_counter).hierarchy_id          := csr_plans_in_program_rec.plip_id;
                g_hierarchy(l_counter).name                  := csr_plans_in_program_rec.name;
                g_hierarchy(l_counter).parent_hierarchy_id   := csr_pgm_pt_rec.ptip_id;
                g_hierarchy(l_counter).parent_hierarchy_type := 'PTIP';
                g_hierarchy(l_counter).uom                   := csr_pgms_rec.uom;
                g_hierarchy(l_counter).acty_ref_perd_cd      := NULL;
                g_hierarchy(l_counter).watif_elctbl_flag     := csr_plans_in_program_rec.elctbl_flag;
                g_hierarchy(l_counter).watif_cvg_val         := get_coverage_amt(csr_plans_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
             ELSE
                g_hierarchy(l_index).name                    := csr_plans_in_program_rec.name;
                g_hierarchy(l_index).watif_elctbl_flag       := csr_plans_in_program_rec.elctbl_flag;
                g_hierarchy(l_index).watif_cvg_val           := get_coverage_amt(csr_plans_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
             END IF;
             FOR csr_rates_rec IN csr_rates( csr_plans_in_program_rec.elig_per_elctbl_chc_id) LOOP
	        l_index   := chk_pl_rate_exists(p_pl_id           => csr_plans_in_program_rec.plip_id
	                                       ,p_acty_base_rt_id => csr_rates_rec.acty_base_rt_id);
	        IF l_index = 0 THEN
	           l_counter := l_counter + 1;
	           g_hierarchy(l_counter).hierarchy_type              := 'ERT';
	           g_hierarchy(l_counter).person_id                   := p_person_id;
	           g_hierarchy(l_counter).business_group_id           := p_business_group_id;
	           g_hierarchy(l_counter).ler_id                      := p_ler_id;
	           g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
	           g_hierarchy(l_counter).name                        := csr_rates_rec.name;
	           g_hierarchy(l_counter).parent_hierarchy_id         := csr_plans_in_program_rec.plip_id;
	           g_hierarchy(l_counter).parent_hierarchy_type       := 'PLIP';
	           g_hierarchy(l_counter).uom                         := csr_pgms_rec.uom;
	           g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
	           g_hierarchy(l_counter).watif_val                   := csr_rates_rec.val;
	           g_hierarchy(l_counter).watif_cmcd_val              := csr_rates_rec.cmcd_val;
	           g_hierarchy(l_counter).watif_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
	        ELSE
	           g_hierarchy(l_index).name                          := csr_rates_rec.name;
	           g_hierarchy(l_index).watif_val                     := csr_rates_rec.val;
	           g_hierarchy(l_index).watif_cmcd_val                := csr_rates_rec.cmcd_val;
	           g_hierarchy(l_index).watif_cmcd_acty_ref_perd_cd   := csr_rates_rec.cmcd_acty_ref_perd_cd;
	        END IF;
             END LOOP;
             FOR csr_options_plip_rec IN csr_options_in_plip(l_per_in_ler_id, csr_plans_in_program_rec.plip_id) LOOP
                 l_index   := chk_opt_in_plip_exists(p_pl_id      => csr_plans_in_program_rec.plip_id
                                                    ,p_opt_id     => csr_options_plip_rec.oipl_id );
                 IF l_index = 0 THEN
                    l_counter := l_counter + 1;
                    g_hierarchy(l_counter).hierarchy_type        := 'OIPLIP';
                    g_hierarchy(l_counter).person_id             := p_person_id;
                    g_hierarchy(l_counter).business_group_id     := p_business_group_id;
                    g_hierarchy(l_counter).ler_id                := p_ler_id;
                    g_hierarchy(l_counter).hierarchy_id          := csr_options_plip_rec.oipl_id;
                    g_hierarchy(l_counter).name                  := csr_options_plip_rec.name;
                    g_hierarchy(l_counter).parent_hierarchy_id   := csr_plans_in_program_rec.plip_id;
                    g_hierarchy(l_counter).parent_hierarchy_type := 'PLIP';
                    g_hierarchy(l_counter).uom                   := csr_pgms_rec.uom;
                    g_hierarchy(l_counter).watif_elctbl_flag     := csr_options_plip_rec.elctbl_flag;
                    g_hierarchy(l_counter).watif_cvg_val         := get_coverage_amt(csr_options_plip_rec.elig_per_elctbl_chc_id,p_business_group_id);
                 ELSE
                    g_hierarchy(l_index).name                    := csr_options_plip_rec.name;
                    g_hierarchy(l_index).watif_elctbl_flag       := csr_options_plip_rec.elctbl_flag;
                    g_hierarchy(l_index).watif_cvg_val           := get_coverage_amt(csr_options_plip_rec.elig_per_elctbl_chc_id,p_business_group_id);
                 END IF;
                 FOR csr_rates_rec IN csr_rates(csr_options_plip_rec.elig_per_elctbl_chc_id) LOOP
                     l_index   := chk_rate_exists(p_opt_id          => csr_options_plip_rec.oipl_id
                                                 ,p_acty_base_rt_id => csr_rates_rec.acty_base_rt_id);
                     IF l_index = 0 THEN
                        l_counter := l_counter + 1;
                        g_hierarchy(l_counter).hierarchy_type              := 'ERT';
                        g_hierarchy(l_counter).person_id                   := p_person_id;
                        g_hierarchy(l_counter).business_group_id           := p_business_group_id;
                        g_hierarchy(l_counter).ler_id                      := p_ler_id;
                        g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
                        g_hierarchy(l_counter).name                        := csr_rates_rec.name;
                        g_hierarchy(l_counter).parent_hierarchy_id         := csr_options_plip_rec.oipl_id;
                        g_hierarchy(l_counter).parent_hierarchy_type       := 'OIPLIP';
                        g_hierarchy(l_counter).uom                         := csr_pgms_rec.uom;
                        g_hierarchy(l_counter).nnmntry_uom                   := csr_rates_rec.nnmntry_uom;
                        g_hierarchy(l_counter).watif_val                   := csr_rates_rec.val;
                        g_hierarchy(l_counter).watif_cmcd_val              := csr_rates_rec.cmcd_val;
                        g_hierarchy(l_counter).watif_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
                     ELSE
                        g_hierarchy(l_index).name                          := csr_rates_rec.name;
                        g_hierarchy(l_index).watif_val                     := csr_rates_rec.val;
                        g_hierarchy(l_index).watif_cmcd_val                := csr_rates_rec.cmcd_val;
                        g_hierarchy(l_index).watif_cmcd_acty_ref_perd_cd   := csr_rates_rec.cmcd_acty_ref_perd_cd;
                     END IF;
                 END LOOP; -- rate in option in plan in plan type in pgm
             END LOOP; -- option in plan in plan type in pgm

         END LOOP;   -- plan in plan type in pgm
     END LOOP; -- plan type in pgm
  END LOOP;--program
  FOR csr_pt_not_in_pgm_rec IN csr_pl_types_not_in_program(l_per_in_ler_id ) LOOP
      l_index   := chk_pl_typ_exists(p_pl_typ_id => csr_pt_not_in_pgm_rec.pl_typ_id);
      IF l_index = 0 THEN
	   l_counter := l_counter + 1;
	   g_hierarchy(l_counter).person_id             := p_person_id;
	   g_hierarchy(l_counter).business_group_id     := p_business_group_id;
	   g_hierarchy(l_counter).ler_id                := p_ler_id;
	   g_hierarchy(l_counter).hierarchy_id          := csr_pt_not_in_pgm_rec.pl_typ_id;
	   g_hierarchy(l_counter).hierarchy_type        := 'PT';
	   g_hierarchy(l_counter).name                  := csr_pt_not_in_pgm_rec.name;
	   g_hierarchy(l_counter).parent_hierarchy_id   := l_hierarchy_id;
	   g_hierarchy(l_counter).parent_hierarchy_type := 'LE';
	ELSE
	   g_hierarchy(l_index).name                    := csr_pt_not_in_pgm_rec.name;
      END IF;
     FOR csr_plans_not_in_program_rec IN csr_plans(l_per_in_ler_id , csr_pt_not_in_pgm_rec.pl_typ_id,-1) LOOP
         l_index   := chk_pnip_exists(p_pl_typ_id => csr_pt_not_in_pgm_rec.pl_typ_id
                                     ,p_pl_id     => csr_plans_not_in_program_rec.pl_id );
         IF l_index = 0 THEN
            l_counter := l_counter + 1;
            g_hierarchy(l_counter).person_id             := p_person_id;
            g_hierarchy(l_counter).business_group_id     := p_business_group_id;
            g_hierarchy(l_counter).ler_id                := p_ler_id;
            g_hierarchy(l_counter).hierarchy_id          := csr_plans_not_in_program_rec.pl_id;
            g_hierarchy(l_counter).hierarchy_type        := 'PNIP';
            g_hierarchy(l_counter).name                  := csr_plans_not_in_program_rec.name;
            g_hierarchy(l_counter).parent_hierarchy_id   := csr_pt_not_in_pgm_rec.pl_typ_id;
            g_hierarchy(l_counter).parent_hierarchy_type := 'PT';
            g_hierarchy(l_counter).uom                   := csr_plans_not_in_program_rec.uom;
            g_hierarchy(l_counter).acty_ref_perd_cd      := csr_plans_not_in_program_rec.acty_ref_perd_cd;
            g_hierarchy(l_counter).watif_elctbl_flag     := csr_plans_not_in_program_rec.elctbl_flag;
            g_hierarchy(l_counter).watif_cvg_val         := get_coverage_amt(csr_plans_not_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
         ELSE
            g_hierarchy(l_index).name                    := csr_plans_not_in_program_rec.name;
            g_hierarchy(l_index).uom                     := csr_plans_not_in_program_rec.uom;
            g_hierarchy(l_index).acty_ref_perd_cd        := csr_plans_not_in_program_rec.acty_ref_perd_cd;
            g_hierarchy(l_index).watif_elctbl_flag       := csr_plans_not_in_program_rec.elctbl_flag;
            g_hierarchy(l_index).watif_cvg_val           := get_coverage_amt(csr_plans_not_in_program_rec.elig_per_elctbl_chc_id,p_business_group_id);
         END IF;
         FOR csr_rates_rec IN csr_rates( csr_plans_not_in_program_rec.elig_per_elctbl_chc_id) LOOP
	      l_index   := chk_pl_rate_exists(p_pl_id           => csr_plans_not_in_program_rec.pl_id
	                                     ,p_acty_base_rt_id => csr_rates_rec.acty_base_rt_id);
	      IF l_index = 0 THEN
	         l_counter := l_counter + 1;
	         g_hierarchy(l_counter).person_id                   := p_person_id;
	         g_hierarchy(l_counter).business_group_id           := p_business_group_id;
	         g_hierarchy(l_counter).ler_id                      := p_ler_id;
	         g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
	         g_hierarchy(l_counter).hierarchy_type              := 'ERT';
	         g_hierarchy(l_counter).name                        := csr_rates_rec.name;
	         g_hierarchy(l_counter).parent_hierarchy_id         := csr_plans_not_in_program_rec.pl_id;
	         g_hierarchy(l_counter).parent_hierarchy_type       := 'PNIP';
	         g_hierarchy(l_counter).uom                         := csr_plans_not_in_program_rec.uom;
	         g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
	         g_hierarchy(l_counter).watif_val                   := csr_rates_rec.val;
	         g_hierarchy(l_counter).watif_cmcd_val              := csr_rates_rec.cmcd_val;
	         g_hierarchy(l_counter).watif_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
	      ELSE
	         g_hierarchy(l_index).name                          := csr_rates_rec.name;
	         g_hierarchy(l_index).watif_val                     := csr_rates_rec.val;
	         g_hierarchy(l_index).watif_cmcd_val                := csr_rates_rec.cmcd_val;
	         g_hierarchy(l_index).watif_cmcd_acty_ref_perd_cd   := csr_rates_rec.cmcd_acty_ref_perd_cd;
	      END IF;
         END LOOP;
         FOR csr_options_pnip_rec IN csr_options_in_pnip(l_per_in_ler_id ,csr_plans_not_in_program_rec.pl_id) LOOP
             l_index   := chk_opt_in_pnip_exists(p_pl_id      => csr_plans_not_in_program_rec.pl_id
                                                ,p_opt_id     => csr_options_pnip_rec.oipl_id );
             IF l_index = 0 THEN
                l_counter := l_counter + 1;
                g_hierarchy(l_counter).person_id             := p_person_id;
                g_hierarchy(l_counter).business_group_id     := p_business_group_id;
                g_hierarchy(l_counter).ler_id                := p_ler_id;
                g_hierarchy(l_counter).hierarchy_id          := csr_options_pnip_rec.oipl_id;
                g_hierarchy(l_counter).hierarchy_type        := 'OIPNIP';
                g_hierarchy(l_counter).name                  := csr_options_pnip_rec.name;
                g_hierarchy(l_counter).parent_hierarchy_id   := csr_plans_not_in_program_rec.pl_id;
                g_hierarchy(l_counter).parent_hierarchy_type := 'PNIP';
                g_hierarchy(l_counter).uom                   := csr_plans_not_in_program_rec.uom;
                g_hierarchy(l_counter).watif_elctbl_flag     := csr_options_pnip_rec.elctbl_flag;
                g_hierarchy(l_counter).watif_cvg_val         := get_coverage_amt(csr_options_pnip_rec.elig_per_elctbl_chc_id,p_business_group_id);
             ELSE
                g_hierarchy(l_index).name                    := csr_options_pnip_rec.name;
                g_hierarchy(l_index).watif_elctbl_flag       := csr_options_pnip_rec.elctbl_flag;
                g_hierarchy(l_index).watif_cvg_val           := get_coverage_amt(csr_options_pnip_rec.elig_per_elctbl_chc_id,p_business_group_id);
             END IF;
             FOR csr_rates_rec IN csr_rates(csr_options_pnip_rec.elig_per_elctbl_chc_id) LOOP
                 l_index   := chk_rate_exists(p_opt_id          => csr_options_pnip_rec.oipl_id
                                             ,p_acty_base_rt_id => csr_rates_rec.acty_base_rt_id);
                 IF l_index = 0 THEN
                    l_counter := l_counter + 1;
                    g_hierarchy(l_counter).person_id                   := p_person_id;
                    g_hierarchy(l_counter).business_group_id           := p_business_group_id;
                    g_hierarchy(l_counter).ler_id                      := p_ler_id;
                    g_hierarchy(l_counter).hierarchy_id                := csr_rates_rec.acty_base_rt_id;
                    g_hierarchy(l_counter).hierarchy_type              := 'ERT';
                    g_hierarchy(l_counter).name                        := csr_rates_rec.name;
                    g_hierarchy(l_counter).parent_hierarchy_id         := csr_options_pnip_rec.oipl_id;
                    g_hierarchy(l_counter).parent_hierarchy_type       := 'OIPNIP';
                    g_hierarchy(l_counter).uom                         := csr_plans_not_in_program_rec.uom;
                    g_hierarchy(l_counter).nnmntry_uom                 := csr_rates_rec.nnmntry_uom;
                    g_hierarchy(l_counter).watif_val                   := csr_rates_rec.val;
                    g_hierarchy(l_counter).watif_cmcd_val              := csr_rates_rec.cmcd_val;
                    g_hierarchy(l_counter).watif_cmcd_acty_ref_perd_cd := csr_rates_rec.cmcd_acty_ref_perd_cd;
                 ELSE
                    g_hierarchy(l_index).name                          := csr_rates_rec.name;
                    g_hierarchy(l_index).watif_val                     := csr_rates_rec.val;
                    g_hierarchy(l_index).watif_cmcd_val                := csr_rates_rec.cmcd_val;
                    g_hierarchy(l_index).watif_cmcd_acty_ref_perd_cd   := csr_rates_rec.cmcd_acty_ref_perd_cd;
                 END IF;
             END LOOP; -- rate in option in plan in plan type not in prog
         END LOOP; -- option in plan in plan type not in prog

    END LOOP; --- plan in plan type not in prog
 END LOOP;-- Plan type not in prog

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END populate_proposed_hierarchy;
-----------------------------------------------------------------------------------------------
--                  Code for Role Based Plan Restriction Starts here
--
-----------------------------------------------------------------------------------------------
--                  Program Hierarchy
-----------------------------------------------------------------------------------------------
FUNCTION check_oiplip(p_plip_id in number
                     ,p_parent_exclude IN BOOLEAN
                     ,p_whatif_results_batch_id IN NUMBER
                     )
RETURN BOOLEAN is
l_parent_include BOOLEAN :=false;
l_include VARCHAR2(2);

Cursor csr_oiplip IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and parent_hierarchy_id=p_plip_id
and hierarchy_type='OIPLIP';

Cursor check_setup(p_oipl_id NUMBER) IS
Select information3
From   pqh_role_extra_info ,
       ben_oiplip_f
Where  oipl_id=p_oipl_id
and    plip_id=p_plip_id
and    g_effective_date between effective_start_date and effective_end_date
and    role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='OIPLIP'
and    information2=to_char(oiplip_id);

BEGIN
For C1 in csr_oiplip LOOP
OPEN check_setup(C1.hierarchy_id);
FETCH check_setup into l_include;
IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
CLOSE check_setup;
IF l_include='E'or (p_parent_exclude and l_include='IE') Then
Delete from pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and hierarchy_id=C1.hierarchy_id and hierarchy_type='OIPLIP';
ELSIF l_include='I' THEN l_parent_include :=true;
END IF;
END LOOP;
return l_parent_include;
END;
------------------------------------------------------------------------------------------------
FUNCTION check_plip(p_ptip_id in number
                   ,p_parent_exclude IN BOOLEAN
                   ,p_whatif_results_batch_id IN NUMBER
                   )
RETURN BOOLEAN is
l_parent_include BOOLEAN :=false;
l_dummy          BOOLEAN;
l_include VARCHAR2(2);

Cursor csr_plip IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and parent_hierarchy_id=p_ptip_id
and hierarchy_type='PLIP';

Cursor check_setup(p_plip_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='PLIP'
and    information2=to_char(p_plip_id);

BEGIN
For C1 in csr_plip LOOP
 OPEN check_setup(C1.hierarchy_id);
 FETCH check_setup into l_include;
  IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
 CLOSE check_setup;
 IF l_include='E' OR (p_parent_exclude and l_include ='IE')Then
  IF NOT check_oiplip(C1.hierarchy_id,true,p_whatif_results_batch_id) THEN
   Delete from pqh_pa_whatif_results
    where whatif_results_batch_id=p_whatif_results_batch_id
    and hierarchy_id=C1.hierarchy_id and hierarchy_type='PLIP';
  ELSE l_parent_include :=true;
  END IF;
 ELSIF l_include='I' THEN l_parent_include :=true; l_dummy  := check_oiplip(C1.hierarchy_id,false,p_whatif_results_batch_id);
 ELSIF check_oiplip(C1.hierarchy_id,p_parent_exclude,p_whatif_results_batch_id) THEN l_parent_include:=true;
 END IF;
END LOOP;
return l_parent_include;
END;
-----------------------------------------------------------------------------------------------


FUNCTION check_ptip(p_pgm_id in number
                   ,p_parent_exclude IN BOOLEAN
                   ,p_whatif_results_batch_id IN NUMBER
                   )
RETURN BOOLEAN is
l_parent_include BOOLEAN :=false;
l_dummy          BOOLEAN;
l_include VARCHAR2(2);

Cursor csr_ptip IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and parent_hierarchy_id=p_pgm_id
and hierarchy_type='PTIP';

Cursor check_setup(p_ptip_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='PTIP'
and    information2=to_char(p_ptip_id);

BEGIN
For C1 in csr_ptip LOOP
 OPEN check_setup(C1.hierarchy_id);
 FETCH check_setup into l_include;
  IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
 CLOSE check_setup;
 IF l_include='E' OR (p_parent_exclude and l_include ='IE')Then
  IF NOT check_plip(C1.hierarchy_id,true,p_whatif_results_batch_id) THEN
   Delete from pqh_pa_whatif_results
    where whatif_results_batch_id=p_whatif_results_batch_id
    and hierarchy_id=C1.hierarchy_id and hierarchy_type='PTIP';
  ELSE l_parent_include :=true;
  END IF;
 ELSIF l_include='I' THEN l_parent_include :=true; l_dummy  := check_plip(C1.hierarchy_id,false,p_whatif_results_batch_id);
 ELSIF check_plip(C1.hierarchy_id,p_parent_exclude,p_whatif_results_batch_id) THEN l_parent_include:=true;
 END IF;
END LOOP;
return l_parent_include;
END;
-----------------------------------------------------------------------------------------------

PROCEDURE check_pgm(
                   p_whatif_results_batch_id in number
                  ) IS

l_include VARCHAR2(2);
l_dummy  BOOLEAN;

Cursor csr_pgm IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and hierarchy_type='PGM';

Cursor check_setup(p_pgm_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='PGM'
and    information2=p_pgm_id;

BEGIN
For C1 in csr_pgm LOOP
 OPEN check_setup(C1.hierarchy_id);
 FETCH check_setup into l_include;
  IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
 CLOSE check_setup;
 IF l_include='E' Then
  IF NOT check_ptip(C1.hierarchy_id,true,p_whatif_results_batch_id) THEN
   Delete from pqh_pa_whatif_results
    where whatif_results_batch_id=p_whatif_results_batch_id
    and hierarchy_id=C1.hierarchy_id and hierarchy_type='PGM';
  END IF;
 ELSE l_dummy :=check_ptip(C1.hierarchy_id,false,p_whatif_results_batch_id);
 END IF;
END LOOP;
END;
----------------------------------------------------------------------------------------------
-- Not in Program Hierarchy
-----------------------------------------------------------------------------------------------
FUNCTION check_oipnip(p_pnip_id in number
                     ,p_parent_exclude IN BOOLEAN
                     ,p_whatif_results_batch_id IN NUMBER
                     )
RETURN BOOLEAN is
l_parent_include BOOLEAN :=false;
l_include VARCHAR2(2);

Cursor csr_oipnip IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and parent_hierarchy_id=p_pnip_id
and hierarchy_type='OIPNIP';

Cursor check_setup(p_oipnip_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='OIPNIP'
and    information2=to_char(p_oipnip_id);

BEGIN
For C1 in csr_oipnip LOOP
OPEN check_setup(C1.hierarchy_id);
FETCH check_setup into l_include;
IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
CLOSE check_setup;
IF l_include='E'or (p_parent_exclude and l_include='IE') Then
Delete from pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and hierarchy_id=C1.hierarchy_id and hierarchy_type='OIPNIP';
ELSIF l_include='I' THEN l_parent_include :=true;
END IF;
END LOOP;
return l_parent_include;
END;
------------------------------------------------------------------------------------------------

FUNCTION check_pnip(p_pl_typ_id in number
                   ,p_parent_exclude IN BOOLEAN
                   ,p_whatif_results_batch_id IN NUMBER
                   )
RETURN BOOLEAN is
l_parent_include BOOLEAN :=false;
l_dummy          BOOLEAN;
l_include VARCHAR2(2);

Cursor csr_pnip IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and parent_hierarchy_id=p_pl_typ_id
and hierarchy_type='PNIP';

Cursor check_setup(p_pnip_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='PNIP'
and    information2=to_char(p_pnip_id);

BEGIN
For C1 in csr_pnip LOOP
 OPEN check_setup(C1.hierarchy_id);
 FETCH check_setup into l_include;
  IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
 CLOSE check_setup;
 IF l_include='E' OR (p_parent_exclude and l_include ='IE')Then
  IF NOT check_oipnip(C1.hierarchy_id,true,p_whatif_results_batch_id) THEN
   Delete from pqh_pa_whatif_results
    where whatif_results_batch_id=p_whatif_results_batch_id
    and hierarchy_id=C1.hierarchy_id and hierarchy_type='PNIP';
  ELSE l_parent_include :=true;
  END IF;
 ELSIF l_include='I' THEN l_parent_include :=true; l_dummy  := check_oipnip(C1.hierarchy_id,false,p_whatif_results_batch_id);
 ELSIF check_oipnip(C1.hierarchy_id,p_parent_exclude,p_whatif_results_batch_id) THEN l_parent_include:=true;
 END IF;
END LOOP;
return l_parent_include;
END;
-----------------------------------------------------------------------------------------------

PROCEDURE check_pt(
                   p_whatif_results_batch_id in number
                  ) IS

l_include VARCHAR2(2);
l_dummy  BOOLEAN;

Cursor csr_pt IS
Select hierarchy_id from
pqh_pa_whatif_results
where whatif_results_batch_id=p_whatif_results_batch_id
and hierarchy_type='PT';

Cursor check_setup(p_pl_typ_id NUMBER) IS
Select information3
From   pqh_role_extra_info
Where  role_id=g_role_id
and    information_type='BEN_SS_ROLE_COMP_OBJECTS'
and    information1='PT'
and    information2=p_pl_typ_id;

BEGIN
For C1 in csr_pt LOOP
 OPEN check_setup(C1.hierarchy_id);
 FETCH check_setup into l_include;
  IF check_setup%NOTFOUND THEN l_include :='IE'; END IF;
 CLOSE check_setup;
 IF l_include='E' Then
  IF NOT check_pnip(C1.hierarchy_id,true,p_whatif_results_batch_id) THEN
   Delete from pqh_pa_whatif_results
    where whatif_results_batch_id=p_whatif_results_batch_id
    and hierarchy_id=C1.hierarchy_id and hierarchy_type='PT';
  END IF;
 ELSE l_dummy :=check_pnip(C1.hierarchy_id,false,p_whatif_results_batch_id);
 END IF;
END LOOP;
END;
-----------------------------------------------------------------------------------------------

PROCEDURE RESTRICT_BY_ROLE(p_whatif_results_batch_id IN NUMBER)
IS
l_dummy NUMBER :=0;
Cursor csr_verify_setup IS
Select 1
From  pqh_role_extra_info
Where role_id=g_role_id
 and  information_type='BEN_SS_ROLE_COMP_OBJECTS'
 and  information1 <> 'LE';
BEGIN
--If EIT is not configured then there is nothing to restrict
IF g_role_id <> -1 THEN
 OPEN csr_verify_setup;
 Fetch csr_verify_setup into l_dummy;
  IF csr_verify_setup%FOUND THEN
   check_pgm(p_whatif_results_batch_id);
   check_pt(p_whatif_results_batch_id);
  null;
  END IF;
 CLOSE csr_verify_setup;
END IF;
END RESTRICT_BY_ROLE;
-----------------------------------------------------------------------------------------------
--                  Code for Role Based Plan Restriction Ends here
--
------------------------------------------------------------------------------------------------


PROCEDURE populate_table ( p_person_id                IN NUMBER
                          ,p_business_group_id        IN NUMBER
                          ,p_transaction_id           IN NUMBER
                          ,p_ler_id                   IN NUMBER
                          ,p_whatif_results_batch_id OUT NOCOPY NUMBER
                         ) IS

 CURSOR csr_sequence_val IS
    SELECT pqh_pa_whatif_results_s.nextval
      FROM sys.dual;
--
l_proc VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'populate_table';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

 OPEN csr_sequence_val;
FETCH csr_sequence_val INTO p_whatif_results_batch_id;
CLOSE csr_sequence_val;

FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST LOOP
    INSERT INTO PQH_PA_WHATIF_RESULTS (
                WHATIF_RESULTS_BATCH_ID
               ,PERSON_ID
               ,BUSINESS_GROUP_ID
               ,TRANSACTION_ID
               ,LER_ID
               ,HIERARCHY_ID
               ,HIERARCHY_TYPE
               ,PARENT_HIERARCHY_ID
               ,PARENT_HIERARCHY_TYPE
               ,NAME
               ,UOM
               ,NNMNTRY_UOM
               ,ACTY_REF_PERD_CD
               ,CRRNT_ELCTBL_FLAG
               ,CRRNT_CVG_VAL
               ,CRRNT_VAL
               ,CRRNT_CMCD_VAL
               ,CRRNT_CMCD_ACTY_REF_PERD_CD
               ,WATIF_ELCTBL_FLAG
               ,WATIF_CVG_VAL
               ,WATIF_VAL
               ,WATIF_CMCD_VAL
               ,WATIF_CMCD_ACTY_REF_PERD_CD
               ,OBJECT_VERSION_NUMBER)
    VALUES (
                p_whatif_results_batch_id
               ,p_person_id
               ,p_business_group_id
               ,p_transaction_id
               ,p_ler_id
               ,g_hierarchy(i).HIERARCHY_ID
               ,g_hierarchy(i).HIERARCHY_TYPE
               ,g_hierarchy(i).PARENT_HIERARCHY_ID
               ,g_hierarchy(i).PARENT_HIERARCHY_TYPE
               ,g_hierarchy(i).NAME
               ,g_hierarchy(i).UOM
               ,g_hierarchy(i).NNMNTRY_UOM
               ,g_hierarchy(i).ACTY_REF_PERD_CD
               ,g_hierarchy(i).CRRNT_ELCTBL_FLAG
               ,g_hierarchy(i).CRRNT_CVG_VAL
               ,g_hierarchy(i).CRRNT_VAL
               ,g_hierarchy(i).CRRNT_CMCD_VAL
               ,g_hierarchy(i).CRRNT_CMCD_ACTY_REF_PERD_CD
               ,g_hierarchy(i).WATIF_ELCTBL_FLAG
               ,g_hierarchy(i).WATIF_CVG_VAL
               ,g_hierarchy(i).WATIF_VAL
               ,g_hierarchy(i).WATIF_CMCD_VAL
               ,g_hierarchy(i).WATIF_CMCD_ACTY_REF_PERD_CD
               ,1 );

END LOOP;
--
-- Roles based plan restriction
--
RESTRICT_BY_ROLE(p_whatif_results_batch_id);

COMMIT;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
END populate_table;
----------------------------------------------------------------------------------------------
PROCEDURE purge_table_data
IS
PRAGMA AUTONOMOUS_TRANSACTION;

 CURSOR csr_purge_data IS
    SELECT DISTINCT whatif_results_batch_id
      FROM pqh_pa_whatif_results
     WHERE CREATION_DATE < trunc(SYSDATE);
--
l_proc VARCHAR2(72);

BEGIN
--
  if g_debug then
    l_proc := g_package || 'purge_table_data';
    hr_utility.set_location('Entering: ' || l_proc,10);
  end if;

  FOR csr_purge_data_rec IN csr_purge_data LOOP
     DELETE PQH_PA_WHATIF_RESULTS
      WHERE WHATIF_RESULTS_BATCH_ID = csr_purge_data_rec.whatif_results_batch_id;
  END LOOP;
  COMMIT;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
EXCEPTION
  WHEN OTHERS THEN ROLLBACK;
END purge_table_data;
-----------------------------------------------------------------------------------------------
PROCEDURE get_user_role(
                        p_user_id           IN        NUMBER
                       ,p_user_type         IN        VARCHAR2
                       ,p_business_group_id IN        NUMBER
                       ,p_role_id          OUT NOCOPY NUMBER
                       ) IS
Cursor csr_user_role IS
Select rls.role_id
 From pqh_roles rls
     ,per_people_extra_info pei
     ,fnd_user usr
Where rls.role_type_cd=p_user_type
  and nvl(rls.enable_flag,'N')='Y'
  and rls.role_id =to_number(pei_information3)
  and pei.information_type='PQH_ROLE_USERS'
  and nvl(pei_information5,'N')='Y'
  and nvl(pei_information9,'N')='Y'
  and pei.person_id=usr.employee_id
  and usr.user_id=p_user_id;

Cursor csr_default_role IS
Select role_id
From  pqh_roles
Where role_type_cd=p_user_type
and   role_name='XXXX';

l_proc           VARCHAR2(72);
BEGIN
 if g_debug then
    l_proc := g_package || '.get_user_role';
    hr_utility.set_location('Entering: ' || l_proc,10);
    hr_utility.set_location('p_user_type : ' || p_user_type,15);
    hr_utility.set_location('p_user_id : ' || to_char(p_user_id),20);
  end if;

OPEN csr_user_role;
FETCH csr_user_role into p_role_id;
/*IF csr_user_role%NOTFOUND
THEN
  if g_debug then
      hr_utility.set_location('Using default role....',25);
  end if;
  OPEN csr_default_role;
  FETCH csr_default_role into p_role_id;
  CLOSE csr_default_role;
END IF;*/
CLOSE csr_user_role;
if g_debug then
    hr_utility.set_location('p_role_id : ' || to_char(p_role_id),40);
    hr_utility.set_location('Leaving: ' || l_proc,50);
  end if;
END get_user_role;

-----------------------------------------------------------------------------------------------

PROCEDURE ss_whatif_process(
            p_called_from               IN        VARCHAR2
           ,p_login_id                  IN        NUMBER
           ,p_login_type                IN        VARCHAR2
	   ,p_person_id                 IN        NUMBER
	   ,p_business_group_id         IN        NUMBER
	   ,p_effective_date            IN        DATE
	   ,p_session_date              IN        DATE
	   ,p_transaction_id            IN        NUMBER
	   ,p_ler_id                IN OUT NOCOPY NUMBER
           ,p_whatif_results_batch_id  OUT NOCOPY NUMBER
         )
IS

cursor c_ptnl_le(l_lf_evt_ocrd_dt date) is
select ptn.ptnl_ler_for_per_id,
       ptn.ptnl_ler_for_per_stat_cd,
       ptn.lf_evt_ocrd_dt lf_evt_ocrd_dt
       from   ben_ptnl_ler_for_per ptn,
       ben_ler_f            ler
where ptn.person_id = p_person_id
and ptn.business_group_id = p_business_group_id
and ptn.lf_evt_ocrd_dt > l_lf_evt_ocrd_dt
and ptn.ler_id = ler.ler_id
and ptn.lf_evt_ocrd_dt between
    ler.effective_start_date and ler.effective_end_date
and ler.typ_cd not in ('SCHEDDU','COMP','GSP','ABS')
and ptn.ptnl_ler_for_per_stat_cd in ('UNPROCD', 'DTCTD', 'MNL', 'MNLO')
order by lf_evt_ocrd_dt desc;

l_prog_count     number;
l_plan_count     number;
l_oipl_count     number;
l_person_count   number;
l_plan_nip_count number;
l_oipl_nip_count number;
l_errbuf         varchar2(1000);
l_retcode        number;
l_proc           VARCHAR2(72);
l_lf_evt_ocrd_dt DATE;
l_crrnt_per_in_ler_id number;
l_role_id       number;

l_new_person_id  number;
l_new_business_group_id number;

l_life_evt_ocrd_dt  DATE;
l_lf_evt_exists   VARCHAR2(2);
l_ptnl_le c_ptnl_le%rowtype;


BEGIN
--
  --
  if g_debug then
    l_proc := g_package || '.ss_whatif_process';
    hr_utility.set_location('Entering: ' || l_proc,10);
    hr_utility.set_location('p_called_from : ' || p_called_from,15);
    hr_utility.set_location('p_person_id : ' || to_char(p_person_id),20);
  end if;
  -- Date used for role based restriction;
  g_effective_date := p_effective_date;
  -- Populate Current Benefits
  hr_utility.set_location('BKKKKK Entering '|| l_proc,10);

  hr_utility.set_location('BKKKKK populate_hierarchy ',10);

   populate_hierarchy(p_person_id         => p_person_id
                     ,p_effective_date    => p_effective_date
                     ,p_business_group_id => p_business_group_id
                     ,p_ler_id            => NULL);

  hr_utility.set_location('BKKKKK set current_ben ',10);

   savepoint current_benefits;

   BEGIN
   --
   fnd_msg_pub.initialize;

   -- Ignore the already detected/unprocessed life event for the person as of the effective date
  hr_utility.set_location('BKKKKK void potential ',10);
   void_potential_life_events(p_person_id         => p_person_id
                             ,p_business_group_id => p_business_group_id
                             ,p_effective_date    => p_effective_date
                              );

   -- Ignore the already active life events for the person
  hr_utility.set_location('BKKKKK set current_ben ',10);
   void_active_life_events(p_person_id         => p_person_id
			  ,p_business_group_id => p_business_group_id
			  ,p_effective_date    => p_effective_date
			   );

   -- Post the data changes for the particular transaction
  hr_utility.set_location('BKKKKK p_called_from '||p_called_from,10);
  IF p_called_from='SSHR' THEN
  --
   post_data_changes(p_transaction_id    => p_transaction_id
                    ,p_effective_date    => p_effective_date
                    ,p_person_id         => l_new_person_id
                    ,p_business_group_id => l_new_business_group_id);

  ELSIF p_called_from ='SSBEN' THEN
  --
   post_ben_changes(p_transaction_id    => p_transaction_id
                   ,p_person_id         => p_person_id
                   ,p_business_group_id => p_business_group_id
                   ,p_effective_date    => p_effective_date
	             ,p_session_date      => p_session_date
	             ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                   );

   open c_ptnl_le(l_lf_evt_ocrd_dt);
   fetch c_ptnl_le into l_ptnl_le;
       if (nvl(l_ptnl_le.lf_evt_ocrd_dt,(l_lf_evt_ocrd_dt-1)) > l_lf_evt_ocrd_dt) then
           l_lf_evt_ocrd_dt := l_ptnl_le.lf_evt_ocrd_dt;
       end if;
   close c_ptnl_le;

 -- p_effective_date:=  l_lf_evt_ocrd_dt ;
   IF p_ler_id <>0  THEN
  hr_utility.set_location('BKKKKK void_conflict_life_events ',10);
    void_conflict_life_events(
     p_person_id              => p_person_id
    ,p_business_group_id      => p_business_group_id
    ,p_winning_ler_id         => p_ler_id
    ,p_effective_date         => p_effective_date
   ) ;
    p_ler_id :=null;
   END IF;
  END IF;

  -- Check whether potential life events have been detected
  hr_utility.set_location('BKKKKK chk_potential_life_events ',10);
  l_lf_evt_exists := chk_potential_life_events(p_person_id         => nvl(l_new_person_id,p_person_id)
                                              ,p_business_group_id => nvl(l_new_business_group_id,p_business_group_id)
                                              ,p_lf_evt_ocrd_dt    => l_life_evt_ocrd_dt);


   IF (l_lf_evt_exists = 'Y') THEN
       -- Set Life Event Occurred Date
       IF ( p_called_from = 'SSHR' ) AND (l_life_evt_ocrd_dt > p_effective_date) THEN
            l_lf_evt_ocrd_dt := l_life_evt_ocrd_dt ;
       END IF;

       -- Call the benmngle
        ben_manage_life_events.g_modified_mode := null;
  hr_utility.set_location('BKKKKK p_watif_manage_life_events ',10);
		ben_on_line_lf_evt.p_watif_manage_life_events(
		                 p_person_id             => nvl(l_new_person_id,p_person_id)
		                ,p_effective_date        => nvl(l_lf_evt_ocrd_dt,p_effective_date)
		                ,p_business_group_id     => nvl(l_new_business_group_id,p_business_group_id)
		                ,p_pgm_id                => null
		                ,p_pl_id                 => null
		                ,p_mode                  => 'L'
                                ,p_derivable_factors     => 'Y'
		                ,p_prog_count            => l_prog_count
		                ,p_plan_count            => l_plan_count
		                ,p_oipl_count            => l_oipl_count
		                ,p_person_count          => l_person_count
		                ,p_plan_nip_count        => l_plan_nip_count
		                ,p_oipl_nip_count        => l_oipl_nip_count
		                ,p_ler_id                => p_ler_id
		                ,p_errbuf                => l_errbuf
		                ,p_retcode               => l_retcode);

        -- Compare and populate proposed benefits
            populate_proposed_hierarchy(p_person_id          => nvl(l_new_person_id,p_person_id)
                                       ,p_effective_date     => nvl(l_lf_evt_ocrd_dt,p_effective_date)
                                       ,p_business_group_id  => nvl(l_new_business_group_id,p_business_group_id)
                                       ,p_ler_id             => p_ler_id);
    ELSE
      -- fnd_message.set_name('PQH','PQH_PA_WHTF_NO_PTNL_LER');
      fnd_message.set_name('BEN','BEN_92540_NOONE_TO_PROCESS_CM');
      fnd_message.raise_error;
    END IF;


   EXCEPTION
     --
     WHEN OTHERS THEN fnd_msg_pub.add;

   END;

  -- Rollback Posting to APIs and BENMNGLE run
  hr_utility.set_location('BKKKKK rollback current_benefits ',10);

  rollback to current_benefits;

  -- Purge Data from the table

  purge_table_data;
  -- Get role_id of user
  get_user_role(
                p_user_id           =>p_login_id
               ,p_user_type         =>p_login_type
               ,p_business_group_id =>p_business_group_id
               ,p_role_id           =>l_role_id
              );
  IF l_role_id is not null then g_role_id :=l_role_id; END IF;
  -- Dump data from PL / SQL table to pqh_pa_watif_results;

  populate_table(p_person_id               => nvl(l_new_person_id,p_person_id)
                ,p_business_group_id       => nvl(l_new_business_group_id,p_business_group_id)
                ,p_transaction_id          => p_transaction_id
                ,p_ler_id                  => p_ler_id
                ,p_whatif_results_batch_id => p_whatif_results_batch_id);

  -- Clear the PL/SQL Table instance

  g_hierarchy.DELETE;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,20);
  end if;
--
EXCEPTION
--
 WHEN OTHERS THEN
  BEGIN
  --
    g_hierarchy.DELETE;
    RAISE;
  --
  END;
--
END ss_whatif_process;
-------------------------------------------------------------------------------------------------

PROCEDURE validate_data_changes(
          p_person_id                 IN        NUMBER
         ,p_business_group_id         IN        NUMBER
         ,p_effective_date            IN        DATE
         ,p_session_date              IN        DATE
         ,p_transaction_id            IN        NUMBER
         ,p_whatif_results_batch_id  OUT NOCOPY NUMBER
         ) IS
l_proc           VARCHAR2(72);
l_num_detected_ler NUMBER :=0;
l_conflict_life_events BOOLEAN :=false;
l_flag VARCHAR2(1);
l_lf_evt_ocrd_dt DATE;
BEGIN
 if g_debug then
    l_proc := g_package || '.validate_data_changes';
    hr_utility.set_location('Entering: ' || l_proc,10);
    hr_utility.set_location('p_person_id : ' || to_char(p_person_id),15);
  end if;

  savepoint current_life_events;

  fnd_msg_pub.initialize;

   -- Ignore the already detected/unprocessed life event for the person as of the effective date
   if g_debug then
       hr_utility.set_location('Call to void Potential LE',20);
  end if;
   void_potential_life_events(p_person_id         => p_person_id
                             ,p_business_group_id => p_business_group_id
                             ,p_effective_date    => p_effective_date
                              );
   -- Post the data changes for the particular transaction
   if g_debug then
       hr_utility.set_location('Call to post ben changes ' ,25);
  end if;
     post_ben_changes(p_transaction_id    => p_transaction_id
                     ,p_person_id         => p_person_id
                     ,p_business_group_id => p_business_group_id
                     ,p_effective_date    => p_effective_date
    	             ,p_session_date      => p_session_date
    	             ,p_lf_evt_ocrd_dt    => l_lf_evt_ocrd_dt
                     );


   -- Check whether potential life events have been detected
   if g_debug then
       hr_utility.set_location('Call to Check conflict LE ' || l_proc,30);
  end if;
  l_conflict_life_events :=chk_conflict_life_events( p_person_id =>p_person_id
                                                    ,p_business_group_id =>p_business_group_id
                                                    ,p_effective_date =>p_effective_date
                                                    ,p_flag =>l_flag);
  if g_debug and l_conflict_life_events then

    hr_utility.set_location('cnflt le detected ' ,25);
  end if;

  -- Rollback Posting to APIs

  rollback to current_life_events;

  -- Dump data from PL / SQL table to pqh_pa_watif_results;
  IF l_conflict_life_events THEN
   -- Conflicting LE's are there
     BEGIN
      SELECT pqh_pa_whatif_results_s.nextval INTO p_whatif_results_batch_id from dual;
      EXCEPTION
       WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        raise;
     END;
     FOR i IN g_hierarchy.FIRST .. g_hierarchy.LAST
     LOOP
      IF g_hierarchy(i).hierarchy_type =l_flag THEN
       INSERT INTO PQH_PA_WHATIF_RESULTS (
                   WHATIF_RESULTS_BATCH_ID
                  ,PERSON_ID
                  ,BUSINESS_GROUP_ID
                  ,LER_ID
                  ,NAME
                  )
           VALUES (
                   p_whatif_results_batch_id
                  ,p_person_id
                  ,p_business_group_id
                  ,g_hierarchy(i).ler_id
                  ,g_hierarchy(i).NAME
                  );
     END IF;
    END LOOP;
  ELSE
   p_whatif_results_batch_id := 0;

  END IF;
  -- Clear the PL/SQL Table instance

  g_hierarchy.DELETE;

  if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,100);
  end if;
--

EXCEPTION
 WHEN OTHERS THEN
 if g_debug then
     hr_utility.set_location('Exception: ' ,50);
  end if;
  g_hierarchy.DELETE;
  p_whatif_results_batch_id :=-2;
  fnd_msg_pub.add;
END validate_data_changes;
-----------------------------------------------------------------------------------------------------------------
PROCEDURE prepare_transaction(
                              p_person_id     IN        NUMBER
                             ,p_txn_id    IN OUT NOCOPY NUMBER
                              ) IS
CURSOR csr_trans_steps(txn_id IN NUMBER) IS
SELECT transaction_step_id
FROM   hr_api_transaction_steps
WHERE  transaction_id=txn_id;

l_proc           VARCHAR2(72);
BEGIN

 if g_debug then
    l_proc := g_package || '.prepare_transaction';
    hr_utility.set_location('Entering: ' || l_proc,10);
    hr_utility.set_location('p_txn_id : ' || to_char(p_txn_id),15);
  end if;
if (p_txn_id=0) THEN
hr_transaction_api.create_transaction (
    p_creator_person_id           =>p_person_id
   ,p_transaction_privilege       =>'PRIVATE'
   ,p_function_id                 => 1
   ,p_selected_person_id          =>p_person_id
   ,p_transaction_effective_date  =>sysdate
   ,p_process_name                =>'SSBENWHATIF'
   ,p_status                      =>'ACTIVE'
   ,p_transaction_id              =>p_txn_id);
ELSE
FOR rec_typ IN csr_trans_steps(p_txn_id)
LOOP
DELETE FROM hr_api_transaction_values
WHERE  transaction_step_id=rec_typ.transaction_step_id;
END LOOP;
DELETE FROM hr_api_transaction_steps
WHERE  transaction_id=p_txn_id;
END IF;
if g_debug then
    hr_utility.set_location('Leaving: ' || l_proc,50);
end if;
END prepare_transaction;
-------------------------------------------------------------------------------------------------------------
FUNCTION get_first_label(
                         p_ler_id         IN NUMBER
                        ,p_effective_date IN DATE
                         )
RETURN VARCHAR2 IS
Cursor csr_watif_labels IS
Select whatif_lbl_txt  label
From   ben_per_info_chg_cs_ler_f a,
       ben_ler_per_info_cs_ler_f b
Where  a.PER_INFO_CHG_CS_LER_ID=b.PER_INFO_CHG_CS_LER_ID
   and b.ler_id=p_ler_id
   and a.WHATIF_LBL_TXT is not null
   and p_effective_date between a.effective_start_date and a.effective_end_date
   and p_effective_date between b.effective_start_date and b.effective_end_date;

l_label ben_per_info_chg_cs_ler_f.WHATIF_LBL_TXT%TYPE;

BEGIN
OPEN csr_watif_labels;
FETCH csr_watif_labels into l_label;
CLOSE csr_watif_labels;
RETURN l_label;
END get_first_label;
END pqh_pa_whatif_process;

/
