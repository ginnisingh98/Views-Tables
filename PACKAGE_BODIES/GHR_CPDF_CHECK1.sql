--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK1" as
/* $Header: ghcpdf01.pkb 120.7.12010000.2 2009/03/10 13:16:36 utokachi ship $ */

/* Name:
     Bargaining Unit
*/


procedure chk_bargaining_unit
  (p_to_pay_plan                   in varchar2
  ,p_agency_sub_element            in varchar2     --non SF52
  ,p_bargaining_unit_status_code   in varchar2
  ) is
begin

-- 060.02.1
  if   p_to_pay_plan = 'ES'
    and
       p_bargaining_unit_status_code <> '8888'
    and
       p_bargaining_unit_status_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37001_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

/* Commented as per December 2000 cpdf changes -- vravikan
-- 060.04.1
  if   p_agency_sub_element in ('AF07','ARAS','DD12','LT00','NV15','TRAC' )
    and
       p_bargaining_unit_status_code <> '8888'
    and
       p_bargaining_unit_status_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37002_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/
end chk_bargaining_unit ;

/* Name:
      Federal Employees Group Life Insurance
*/

procedure chk_fegli
  (p_to_basic_pay    in  varchar2
  ,p_to_pay_plan     in  varchar2
  ,p_fegli_code      in  varchar2
  ,p_effective_date  in  date
  ) is
begin

--170.04.1
   -- Update Date        By        Effective Date            Comment
   --   ?   05/06/99    vravikan   04/25/99                 Fegli changes
if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/25') then
  if   p_to_basic_pay = '0'
    and
       p_to_pay_plan <> 'VC'
    and
       p_fegli_code <>  'A0'
    and
       p_fegli_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37038_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
else
  if   p_to_basic_pay = '0'
    and
       p_to_pay_plan <> 'VC'
    and
       p_fegli_code <>  'A'
    and
       p_fegli_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37003_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;
end chk_fegli;

/* Name:
     FSLA Category
*/

procedure chk_fsla_category
  (p_duty_station_lookup_code    in    varchar2
  ,p_to_pay_plan                 in    varchar2
  ,p_agency_subelement           in    varchar2
  ,p_flsa_category               in    varchar2
  ,p_to_grade_or_level           in    varchar2
  ,p_effective_date              in    date --Bug# 5619873
  )is
begin
--Venkat 03/27/2000 -- Bug # 1246822 -- replacing or with and

-- 180.02.1
--upd49  08-Jan-07	Raju Bug#5619873 From 01-Sep-2006	 Terminate the edit
 if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
   if  (substr(upper(p_duty_station_lookup_code),1,2) between 'AA' and 'ZZ')
     and (substr(p_duty_station_lookup_code,1,2)<>'US'
       and -- Bug # 1246822
        substr(p_duty_station_lookup_code,2,1)<>'Q' )
     and p_flsa_category <> 'E'
     and p_flsa_category is not null
     then
       hr_utility.set_message(8301, 'GHR_37004_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
 end if;
-- 180.04.1
--upd49  08-Jan-07	Raju Bug#5619873 From 01-Sep-2006	 Terminate the edit
 if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
   if  (p_to_pay_plan = 'WG' or p_to_pay_plan = 'WL')
     and
        p_agency_subelement not in ('AFNG','AFZG','ARNG')
     and
       ((substr(p_duty_station_lookup_code,1,2) between '00' and '99')
       or
        substr(p_duty_station_lookup_code,1,2)='US'
       or
	  substr(p_duty_station_lookup_code,2,1)='Q')
     and
        p_flsa_category <> 'N'
     and
       p_flsa_category is not null
     then
       hr_utility.set_message(8301, 'GHR_37005_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
 end if;
-- 180.07.1
--upd49  08-Jan-07	Raju Bug#5619873 From 01-Sep-2006	 Terminate the edit
 if p_effective_date < fnd_date.canonical_to_date('2006/09/01') then
   if   p_to_pay_plan = 'GS'
     and
        p_agency_subelement  not in ('AFNG','AFZG','ARNG')
     and
        p_to_grade_or_level between '01' and '04'
     and
       (substr(p_duty_station_lookup_code,1,2) between '00' and '99'
       or
        substr(p_duty_station_lookup_code,1,2)='US'
       or
	  substr(p_duty_station_lookup_code,2,1)='Q')
     and
        p_flsa_category <>'N'
     and
       p_flsa_category is not null
     then
       hr_utility.set_message(8301, 'GHR_37006_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
end if;
-- 180.09.1
-- UPD 56 (Bug# 8309414) edit adding eff  07-sep-2007
if p_effective_date > fnd_date.canonical_to_date('2007/09/06') then
    IF  (NOT(substr(p_duty_station_lookup_code,1,2) between '00' and '99') AND
        substr(p_duty_station_lookup_code,1,2) NOT IN ('AQ','CQ','GQ','JQ','LQ','MQ','RQ','VQ','WQ') )
        AND p_flsa_category <>'E' THEN
        hr_utility.set_message(8301, 'GHR_37452_ALL_PROCEDURE_FAIL');
        hr_utility.raise_error;
    END IF;
END IF;

-- 180.13.1
   if   p_to_pay_plan in ('AL','CA','ES','EX','SL','ST')
     and
        p_flsa_category <> 'E'
     and
       p_flsa_category is not null
     then
       hr_utility.set_message(8301, 'GHR_37007_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

end chk_fsla_category;


/* Name:
     Functional Classification
*/

procedure chk_functional_classification
  (p_to_occ_code         in  varchar2
  ,p_functional_class    in  varchar2
  ,p_effective_date	     in	 date --Bug# 5619873
  ) is
begin

-- 200.04.1
 --upd49  08-Jan-07	Raju Bug#5619873 From 01-Oct-2006	 change 0470-0493 to 0470-0487
 --  remove occu code 1540
 if p_effective_date < fnd_date.canonical_to_date('2006/10/01') then

      if   (p_to_occ_code in
          ('0020','0101','0110','0140','0150','0170','0180','0184'
          ,'0185','0190','0193','0401','0403','0457','0460','0601'
          ,'0602','0610','0644','0660','0662','0665','0668','0680'
          ,'0690','0696','0701','0801','0803','0804','0810','0819'
          ,'0896','1220','1221','1350','1360','1370','1372','1373'
          ,'1529','1530','1540','1550')
          or p_to_occ_code between '0405' and '0415'
          or p_to_occ_code between '0430' and '0454'
          or p_to_occ_code between '0470' and '0493'
          or p_to_occ_code between '0630' and '0635'
          or p_to_occ_code between '0637' and '0639'
          or p_to_occ_code between '0806' and '0808'
          or p_to_occ_code between '0830' and '0855'
          or p_to_occ_code between '0858' and '0871'
          or p_to_occ_code between '0880' and '0894'
          or p_to_occ_code between '1223' and '1226'
          or p_to_occ_code between '1301' and '1310'
          or p_to_occ_code between '1313' and '1315'
          or p_to_occ_code between '1320' and '1340'
          or p_to_occ_code between '1380' and '1386'
          or p_to_occ_code between '1510' and '1520')
          and to_number(p_functional_class)  <= 10
          and p_functional_class is not null
        then
           hr_utility.set_message(8301, 'GHR_37008_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
      end if;
   else
        if   (p_to_occ_code in
          ('0020','0101','0110','0140','0150','0170','0180','0184'
          ,'0185','0190','0193','0401','0403','0457','0460','0601'
          ,'0602','0610','0644','0660','0662','0665','0668','0680'
          ,'0690','0696','0701','0801','0803','0804','0810','0819'
          ,'0896','1220','1221','1350','1360','1370','1372','1373'
          ,'1529','1530','1550')
          or p_to_occ_code between '0405' and '0415'
          or p_to_occ_code between '0430' and '0454'
          or p_to_occ_code between '0470' and '0487'
          or p_to_occ_code between '0630' and '0635'
          or p_to_occ_code between '0637' and '0639'
          or p_to_occ_code between '0806' and '0808'
          or p_to_occ_code between '0830' and '0855'
          or p_to_occ_code between '0858' and '0871'
          or p_to_occ_code between '0880' and '0894'
          or p_to_occ_code between '1223' and '1226'
          or p_to_occ_code between '1301' and '1310'
          or p_to_occ_code between '1313' and '1315'
          or p_to_occ_code between '1320' and '1340'
          or p_to_occ_code between '1380' and '1386'
          or p_to_occ_code between '1510' and '1520')
          and to_number(p_functional_class)  <= 10
          and p_functional_class is not null
        then
           hr_utility.set_message(8301, 'GHR_37008_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
      end if;
   end if;

-- 200.07.1
 --upd49  08-Jan-07	Raju Bug#5619873 From 01-Oct-2006	 change 0470-0493 to 0470-0487
 --  remove occu code 1540
    if p_effective_date < fnd_date.canonical_to_date('2006/10/01') then
        if  (p_to_occ_code not in
         ('0020','0101','0110','0140','0150','0170','0180','0184'
         ,'0185','0190','0193','0401','0403','0457','0460','0601'
         ,'0602','0610','0644','0660','0662','0665','0668','0680'
         ,'0690','0696','0701','0801','0803','0804','0810','0819'
         ,'0896','1220','1221','1350','1360','1370','1372','1373'
         ,'1529','1530','1540','1550')
        and p_to_occ_code not between '0405' and '0415'
        and p_to_occ_code not between '0430' and '0454'
        and p_to_occ_code not between '0470' and '0493'
        and	p_to_occ_code not between '0630' and '0635'
        and	p_to_occ_code not between '0637' and '0639'
        and	p_to_occ_code not between '0806' and '0808'
        and	p_to_occ_code not between '0830' and '0855'
        and	p_to_occ_code not between '0858' and '0871'
        and	p_to_occ_code not between '0880' and '0894'
        and	p_to_occ_code not between '1223' and '1226'
        and	p_to_occ_code not between '1301' and '1310'
        and	p_to_occ_code not between '1313' and '1315'
        and	p_to_occ_code not between '1320' and '1340'
        and p_to_occ_code not between '1380' and '1386'
        and	p_to_occ_code not between '1510' and '1520')
        and p_functional_class  <> '00'
        and p_functional_class is not null
        then
           hr_utility.set_message(8301, 'GHR_37009_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
        end if;
    else
         if  (p_to_occ_code not in
         ('0020','0101','0110','0140','0150','0170','0180','0184'
         ,'0185','0190','0193','0401','0403','0457','0460','0601'
         ,'0602','0610','0644','0660','0662','0665','0668','0680'
         ,'0690','0696','0701','0801','0803','0804','0810','0819'
         ,'0896','1220','1221','1350','1360','1370','1372','1373'
         ,'1529','1530','1550')
        and p_to_occ_code not between '0405' and '0415'
        and p_to_occ_code not between '0430' and '0454'
        and p_to_occ_code not between '0470' and '0487'
        and	p_to_occ_code not between '0630' and '0635'
        and	p_to_occ_code not between '0637' and '0639'
        and	p_to_occ_code not between '0806' and '0808'
        and	p_to_occ_code not between '0830' and '0855'
        and	p_to_occ_code not between '0858' and '0871'
        and	p_to_occ_code not between '0880' and '0894'
        and	p_to_occ_code not between '1223' and '1226'
        and	p_to_occ_code not between '1301' and '1310'
        and	p_to_occ_code not between '1313' and '1315'
        and	p_to_occ_code not between '1320' and '1340'
        and p_to_occ_code not between '1380' and '1386'
        and	p_to_occ_code not between '1510' and '1520')
        and p_functional_class  <> '00'
        and p_functional_class is not null
        then
           hr_utility.set_message(8301, 'GHR_37009_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
        end if;
    end if;

end chk_functional_classification;

/* Name:
     HEALTH PLAN
*/

procedure chk_health_plan
  (p_health_plan	 	        in	varchar2  --non SF52
  ,p_tenure_group_code		  in	varchar2
  ,p_work_schedule_code 	  in	varchar2
  ,p_to_pay_basis		        in	varchar2
  ,p_to_pay_status		  in	varchar2  --non SF52
  ,p_submission_date            in  date      --non SF52
  ,p_Cur_Appt_Auth_1            in  varchar2
  ,p_Cur_Appt_Auth_2            in  varchar2
  ) is

begin

/* not supported in the product due to unsolved submission date
-- 230.00.1  note: this procedure is from Part B Notes section.
  if   p_health_plan is null
    and
       to_char(p_submission_date,'MM') <> '03'
       and
       to_char(p_submission_date,'MM') <> '09'
    then
       hr_utility.set_message(8301, 'GHR_370_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

-- 230.02.01
  if   p_health_plan = 'ZZZ'
    and
       p_tenure_group_code <> '0'
    and
       p_tenure_group_code <> '3'
    and
       p_tenure_group_code is not null
    and
       p_work_schedule_code not in ('G','I','J','Q')
    and
       p_work_schedule_code is not null
    and
       p_to_pay_basis not in ('PW','FB','WC')
    and
       p_to_pay_basis is not null
    and
       p_Cur_Appt_Auth_1 not in ('YAM','YBM','YGM','Y1M','Y2M','Y3M','Y4M')
    and
       p_Cur_Appt_Auth_1 is not null
    and
       p_Cur_Appt_Auth_2 not in ('YAM','YBM','YGM','Y1M','Y2M','Y3M','Y4M')
    and
       p_Cur_Appt_Auth_2 is not null
    -- and
    --   p_to_pay_status <> 'N'

    then
       hr_utility.set_message(8301, 'GHR_37031_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

end chk_health_plan;



/* Name:
  -- Retained Grade
*/

procedure chk_retain_grade
  (p_retain_pay_plan               in     varchar2   --non SF52
  ,p_retain_grade                  in     varchar2   --non SF52
  ,p_pay_rate_determinant_code     in     varchar2
  ,p_effective_date				   in	  date
  ) is

begin

-- 610.02.1
  if   p_retain_pay_plan = 'WL'
    and
       p_retain_grade not between '01' and '15'
    then
       hr_utility.set_message(8301, 'GHR_37029_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 610.04.1
  if   p_retain_pay_plan = 'WS'
    and
       p_retain_grade not between '01' and '19'
    then
       hr_utility.set_message(8301, 'GHR_37010_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

/* Commented as per December 2000 cpdf changes -- vravikan
-- 610.07.1
  if   p_retain_pay_plan = 'GM'
    and
       p_retain_grade not between '14' and '15'
    then
       hr_utility.set_message(8301, 'GHR_37011_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

-- 610.10.1
  if   p_retain_pay_plan = 'GS'
    and
       p_retain_grade not between '01' and '15'
    then
       hr_utility.set_message(8301, 'GHR_37012_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 610.13.1
  if   p_retain_pay_plan = 'WG'
    and
       p_retain_grade not between '01' and '15'
    then
       hr_utility.set_message(8301, 'GHR_37013_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;


-- 610.16.1
 --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
 -- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date < fnd_date.canonical_to_date('2005/05/01') then
        if  p_retain_grade is not null and
            p_pay_rate_determinant_code not in ('A','B','E','F','M','U','V')
        then
            hr_utility.set_message(8301, 'GHR_37014_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
            hr_utility.raise_error;
        end if;
    elsif p_effective_date >= fnd_date.canonical_to_date('2005/05/01') then
        if  p_retain_grade is not null and
            p_pay_rate_determinant_code not in ('A','B','E','F','U','V')
        then
            hr_utility.set_message(8301, 'GHR_37014_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
            hr_utility.raise_error;
        end if;
    end if;
end if;
-- 610.19.1
  if   p_pay_rate_determinant_code  in ('A','B','E','F','U','V')
    and
       p_retain_grade is null
    then
       hr_utility.set_message(8301, 'GHR_37015_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

/* Commented as per December 2000 cpdf changes -- vravikan
-- 610.25.1
  if   p_retain_pay_plan = 'GH'
    and
       p_retain_grade <>'14'
    and
       p_retain_grade <>'15'
    and
       p_retain_grade is not null
    then
       hr_utility.set_message(8301, 'GHR_37016_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

-- 610.30.1
  if   p_retain_pay_plan = 'GG'
    and
       p_retain_grade not between '01' and '15'
    and
       p_retain_grade is not null
    then
       hr_utility.set_message(8301, 'GHR_37017_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

end chk_retain_grade;

/* Name:
 -- Retained Pay Plan
*/

procedure chk_retain_pay_plan
  (p_retain_grade      in varchar2   --non SF52
  ,p_retain_pay_plan   in varchar2   --non SF52
  ,p_retain_step       in varchar2   --non SF52
  ,p_to_pay_plan       in varchar2
  ,p_pay_rate_determinant_code in varchar2
  ,p_effective_date    in date

  ) is
begin
-- 620.02.1
-- If Pay rate determinant is A, B, E, F, U, or V,
-- Then retained pay plan may not be GH or GM
   --            12/8/00   vravikan    01-Oct-2000    New Edit
if p_effective_date >= fnd_date.canonical_to_date('2000/10/01') then
  if p_pay_rate_determinant_code is not null and
     p_pay_rate_determinant_code in ('A','B','E','F','U','V') and
     p_retain_pay_plan in ('GH','GM') then
       hr_utility.set_message(8301, 'GHR_37663_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end if;


-- 620.04.1
  if   p_retain_grade is not null
    and
      (p_retain_pay_plan is null
       or
       p_retain_step is null )
    then
       hr_utility.set_message(8301, 'GHR_37018_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

/* Commented as per December 2000 cpdf changes -- vravikan
-- 620.10.1
  if   p_to_pay_plan = 'GS'
    and
       p_retain_pay_plan = 'GM'
    then
       hr_utility.set_message(8301, 'GHR_37019_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
*/

/* Commented as per December 2000 cpdf changes -- vravikan
-- 620.13.1
  if   p_to_pay_plan = 'GM'
    and
       p_retain_pay_plan = 'GS'
    then
       hr_utility.set_message(8301, 'GHR_37020_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

*/
end chk_retain_pay_plan;

/* Name:
-- Retained Step
*/

procedure chk_retain_step
  (p_pay_rate_determinant_code   in  varchar2
  ,p_first_action_noa_la_code1   in  varchar2
  ,p_first_action_noa_la_code2   in  varchar2
  ,p_Cur_Appt_Auth_1                   in varchar2  --non SF52 item
  ,p_Cur_Appt_Auth_2                   in varchar2  --non SF52 item
  ,p_retain_pay_plan             in  varchar2  --non SF52
  ,p_retain_grade                in  varchar2  --non SF52
  ,p_retain_step                 in  varchar2  --non SF52
  ,p_effective_date              in  date
  ) is
begin

-- 630.02.1
 --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
if p_effective_date < to_date('2005/05/01','yyyy/mm/dd') then
	if   p_pay_rate_determinant_code in ('A','B','E','F','M') and
	   p_Cur_Appt_Auth_1 <> 'UAM' and
	   p_Cur_Appt_Auth_2 <> 'UAM' and
	  (p_retain_pay_plan = 'GS'   or
	   p_retain_pay_plan ='GG')   and
	   p_retain_grade between '01' and '15' and
	   p_retain_step not between '01' and '10' and
	   p_retain_step is not null
	then
	   hr_utility.set_message(8301, 'GHR_37021_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','A, B, E, F, or M');
	   hr_utility.raise_error;
	end if;
elsif p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') then
	if   p_pay_rate_determinant_code in ('A','B','E','F') and
	   p_Cur_Appt_Auth_1 <> 'UAM' and
	   p_Cur_Appt_Auth_2 <> 'UAM' and
	  (p_retain_pay_plan = 'GS'   or
	   p_retain_pay_plan ='GG')   and
	   p_retain_grade between '01' and '15' and
	   p_retain_step not between '01' and '10' and
	   p_retain_step is not null
	then
	   hr_utility.set_message(8301, 'GHR_37021_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','A, B, E, or F');
	   hr_utility.raise_error;
	end if;
end if;


-- 630.04.1
/* Commented as per December 2000 cpdf changes -- vravikan
  --            17-Aug-00   vravikan   01-jan-2000   Delete 99 from step codes
if p_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
  if   p_pay_rate_determinant_code in ('A','B','E','F','M')
    and
       p_retain_pay_plan = 'GM'
    and
       p_retain_step <> '00'
    and
       p_retain_step is not null
    then
       hr_utility.set_message(8301, 'GHR_37413_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
  else
  if   p_pay_rate_determinant_code in ('A','B','E','F','M')
    and
       p_retain_pay_plan = 'GM'
    and
       p_retain_step <> '00'
    and
       p_retain_step <> '99'
    and
       p_retain_step is not null
    then
       hr_utility.set_message(8301, 'GHR_37022_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
 end if;
*/

-- 630.07.1
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if  (p_pay_rate_determinant_code ='U'
       or
       p_pay_rate_determinant_code = 'V')
    and
       p_retain_pay_plan <> 'WT'
    and
       p_retain_step <> '00'
    and
       p_retain_step is not null
    then
       hr_utility.set_message(8301, 'GHR_37023_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end if;
end chk_retain_step;


/* Name:
-- Retirement Plan
*/

procedure chk_retirement_plan
  (p_retirement_plan_code     in  varchar2
  ,p_fers_coverage            in  varchar2  --non SF52
  ) is
begin

-- 640.11.1
  if   p_retirement_plan_code in ('K','L','M','N')
    and
       p_fers_coverage <> 'A'
    and
       p_fers_coverage <> 'E'
    and
       p_fers_coverage is not null
    then
       hr_utility.set_message(8301, 'GHR_37024_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;

-- 640.14.1
  if  (p_fers_coverage = 'A'
       or
       p_fers_coverage = 'E')
    and
       p_retirement_plan_code not in ('K','L','M','N','P')
    and
       p_retirement_plan_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37025_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;
end chk_retirement_plan;


/* Name:
-- special_pay_table_id
*/

procedure chk_special_pay_table_id
  (p_pay_rate_determinant_code       in varchar2
  ,p_to_pay_plan                     in varchar2
  ,p_special_pay_table_id            in varchar2  --non SF52
  -- FWFA Changes Bug#4444609
  ,p_effective_date                  in date
  -- FWFA Changes
) is
begin


   -- Update Date        By        Effective Date            Comment
   --   ?   01/28/99    vravikan   01/10/98                  Commented - Bug 808117
/*
-- 695.05.1
  if   p_pay_rate_determinant_code not in ('5','6','E','F','M')
    and
       p_special_pay_table_id is not null
    then
       hr_utility.set_message(8301, 'GHR_37026_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
*/

-- 695.10.1
-- Modified as a part of FWFA Changes. Restricted the edit to actions processed
-- before 01-MAY-2005. For actions processed on or after 01-MAY-2005, this edit
-- will be skipped.
-- FWFA Changes Bug#4444609
--  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005

IF p_effective_date < to_date('2005/05/01','yyyy/mm/dd') THEN
  if  p_to_pay_plan in ('GM','GS')
    and
       p_pay_rate_determinant_code in ('5','6','E','F','M')
    and
       p_special_pay_table_id is null
    then
       hr_utility.set_message(8301, 'GHR_37027_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','5, 6, E, F, or M');
       hr_utility.raise_error;
   end if;
ELSIF p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') THEN
	if  p_to_pay_plan in ('GM','GS') and
	   p_pay_rate_determinant_code in ('5','6','E','F') and
	   p_special_pay_table_id is null
	then
	   hr_utility.set_message(8301, 'GHR_37027_ALL_PROCEDURE_FAIL');
	   hr_utility.set_message_token('PRD_LIST','5, 6, E, or F');
	   hr_utility.raise_error;
	end if;
END IF;

-- FWFA Changes
end chk_special_pay_table_id ;



/* Name:
-- U.S. Citizenship
*/

procedure chk_us_citizenship
  (p_citizenship           		in   varchar2
  ,p_duty_station_lookup_code 		in varchar2
  ) is
begin
  null;

/* COMMENTED on 16-OCT-2002 as per NOV'02 FP Requirements -- VNARASIM
-- 740.02.1
-- No changes made as edit is end dated : amrchakr
  if   p_citizenship <> '1'
    and
       substr(p_duty_station_lookup_code,1,2) <> 'US'
       and
       substr(p_duty_station_lookup_code,2,1) <> 'Q'
       and
       substr(p_duty_station_lookup_code,1,1) not in ('1','2','3','4','5','6','7','8','9','0')
       and
       substr(p_duty_station_lookup_code,2,1) not in ('1','2','3','4','5','6','7','8','9','0')
       and
       p_duty_station_lookup_code is not null
    then
       hr_utility.set_message(8301, 'GHR_37028_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
  end if;*/

end chk_us_citizenship;
--
--
procedure chk_century_info (
   p_date_of_birth                  in   date
  ,p_effective_date                 in   date
  ,p_Service_Computation_Date       in   date
  ,p_year_degree_attained           in   varchar2
  ,p_rating_of_record_period        in   varchar2
  ,p_rating_of_record_per_starts    in   varchar2
  ) is
begin
   --
   -- Procedure added to check the century info.
   --
-- 110.00.1
   if to_number(to_char(p_date_of_birth, 'YYYY')) NOT BETWEEN 1900 and 2099  then
       hr_utility.set_message(8301, 'GHR_37887_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 140.00.2
   if to_number(to_char(p_effective_date, 'YYYY')) NOT BETWEEN 1900 and 2099  then
       hr_utility.set_message(8301, 'GHR_37888_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 660.00.1

-- renamed from 660.00.1 to 600.00.3
-- renamed back to 660.00.1 from 660.00.3 on 12-oct-98 for update 8

   -- Update     Date        By        Effective Date   Comment
   --   ?        05/06/99    vravikan                   660.00.1 has changed - if condition is
   --                                                   removed as both branchings refer to
   --                                                   same message
     if  to_number(to_char(p_service_computation_date, 'YYYY'))
         NOT BETWEEN 1900 and 2099  then
         hr_utility.set_message(8301, 'GHR_37889_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
     end if;

-- 780.00.3
   if to_number(p_year_degree_attained) NOT BETWEEN 1900 and 2099  then
       hr_utility.set_message(8301, 'GHR_37890_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

-- 472.00.3
   if  to_number(to_char(fnd_date.canonical_to_date(p_rating_of_record_period), 'yyyy'))
                 NOT BETWEEN 1900 and 2099  then
       hr_utility.set_message(8301, 'GHR_37891_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
--Bug# 4753117 28-Feb-07	Veeramani  adding edit for the Appraisal start date
   if  to_number(to_char(fnd_date.canonical_to_date(p_rating_of_record_per_starts), 'yyyy'))
                 NOT BETWEEN 1900 and 2099  then
       hr_utility.set_message(8301, 'GHR_37891_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;



end chk_century_info;

end GHR_CPDF_CHECK1;

/
