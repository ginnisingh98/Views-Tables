--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_CHECK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_CHECK5" as
/* $Header: ghcpdf05.pkb 120.18.12010000.9 2009/07/30 12:24:46 vmididho ship $ */

   max_per_diem		number(5)		:=	1000;
   min_basic_pay	number(10,2);
   max_basic_pay	number(10,2);


/* Name:
--RATING OF RECORD
*/


procedure chk_rating_of_rec
  (p_rating_of_record_level 	in 	varchar2  --non SF52
  ,p_rating_of_record_pattern	in	varchar2  --non SF52
  ,p_rating_of_record_period	in	varchar2  --non SF52
  ,p_rating_of_record_per_starts in     varchar2
  ,p_first_noac_lookup_code     in    varchar2
  ,p_effective_date             in    date
  ,p_submission_date            in    date         --non SF52
  ,p_to_pay_plan                in    varchar2
  ) is

l_end_date date;
l_start_date date;
begin

/* this procedure is commented out requested by functional people*/
--Uncommented for bug 3084133
-- upd49  19-Jan-07	  Raju       From Beginning	        Bug#5619873  817
-- upd55  11-Oct-07	  Raju       From 01-May-2007       Bug#6469079  add pattren condition
-- Upd57  30-Jul-09       Mani       Bug # 8653515 Modified pattern condition

-- 470.02.2
IF p_effective_date < to_date('2007/05/01','RRRR/MM/DD') then --Bug#6469079
   if  p_first_noac_lookup_code  not in ('001','817') and
       p_rating_of_record_level is null then
       hr_utility.set_message(8301, 'GHR_37501_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
ELSE ---Begin Bug#6469079
    if  p_first_noac_lookup_code  not in ('001','817') and
        p_rating_of_record_pattern <> 'Z' and
       p_rating_of_record_level is null then
       hr_utility.set_message(8301, 'GHR_38426_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if; --End Bug#6469079
END IF;


--470.03.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is A, Then rating of record(level) must
be 1,3,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
    and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'A' and
      p_rating_of_record_level not in ('1','3','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37176_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
     if p_rating_of_record_pattern = 'A' and
      p_rating_of_record_level not in ('1','3','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37176_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;
--470.04.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is B, Then rating of record(level) must
be 1,3,5,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'B' and
      p_rating_of_record_level not in ('1','3','5','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37177_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, 5, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
        if p_rating_of_record_pattern = 'B' and
        p_rating_of_record_level not in ('1','3','5','X') and
        p_rating_of_record_level is not null then
            hr_utility.set_message(8301, 'GHR_37177_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('REC_LEVEL','1, 3, 5 or X ');
            hr_utility.raise_error;
        end if; --End Bug#6469079
  end if;
--470.05.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is C, Then rating of record(level) must
be 1,3,4,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'C' and
      p_rating_of_record_level not in ('1','3','4','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37178_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, 4, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'C' and
      p_rating_of_record_level not in ('1','3','4','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37178_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, 4 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;
--470.06.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is D, Then rating of record(level) must
be 1,2,3,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'D' and
      p_rating_of_record_level not in ('1','2','3','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37179_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'D' and
      p_rating_of_record_level not in ('1','2','3','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37179_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;

--470.07.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is E, Then rating of record(level) must
be 1,3,4,5,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'E' and
      p_rating_of_record_level not in ('1','3','4','5','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37180_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, 4, 5, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'E' and
      p_rating_of_record_level not in ('1','3','4','5','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37180_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 3, 4, 5 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;
--470.08.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is F, Then rating of record(level) must
be 1,2,3,5,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'F' and
      p_rating_of_record_level not in ('1','2','3','5','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37181_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 5, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'F' and
      p_rating_of_record_level not in ('1','2','3','5','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37181_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 5 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;
--470.09.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            18-Sep-00   vravikan   01-Oct-99                 Add Z
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is G, Then rating of record(level) must
be 1,2,3,4,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'G' and
      p_rating_of_record_level not in ('1','2','3','4','X','Z') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37182_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 4, X or Z');
          hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'G' and
      p_rating_of_record_level not in ('1','2','3','4','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37182_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 4 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;
--470.10.3
--   10/6     08/13/99    vravikan   01-Oct-99                 New Edit
--            02/16/00    vravikan                 1196230     Add record_level 'Z'
--            11-Oct-07   Raju       01-Jul-08                 delete Z(Bug#6469079)
/* If rating of record (pattern) is H, Then rating of record(level) must
be 1,2,3,4,5,X or Z. */
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01')
     and p_effective_date < to_date('2008/07/01','RRRR/MM/DD') then --Bug#6469079
    if p_rating_of_record_pattern = 'H' and
      p_rating_of_record_level not in ('1','2','3','4','5','X','Z') and
      p_rating_of_record_level is not null then
      hr_utility.set_message(8301, 'GHR_37183_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 4, 5, X or Z');
      hr_utility.raise_error;
    end if;
  else --Begin Bug#6469079
    if p_rating_of_record_pattern = 'H' and
      p_rating_of_record_level not in ('1','2','3','4','5','X') and
      p_rating_of_record_level is not null then
          hr_utility.set_message(8301, 'GHR_37183_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('REC_LEVEL','1, 2, 3, 4, 5 or X');
          hr_utility.raise_error;
    end if; --End Bug#6469079
  end if;

-- 471.02.3
   if  p_rating_of_record_level in ('1','2','3','4','5') and
      (p_rating_of_record_pattern is null or
       p_rating_of_record_period is null or
    ----Bug# 4753117 28-Feb-07	Veeramani  adding Appraisal start date
       p_rating_of_record_per_starts is null) then
       hr_utility.set_message(8301, 'GHR_37502_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;

--471.03.3
--   10/6     08/16/99    vravikan   01-Oct-99                 New Edit
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/10/01') then
    if p_to_pay_plan in ('ES') and
      (p_rating_of_record_pattern is not null and
      p_rating_of_record_pattern in ('A','B','C','E') ) then
      hr_utility.set_message(8301, 'GHR_37184_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
    end if;
  end if;

--471.06.1
--   upd55     11-Oct-2007  Raju   01-May-2007    Bug# 6469079 New Edit

  if p_effective_date >= to_date('2007/05/01','RRRR/MM/DD') then
    if p_rating_of_record_level is null and
       p_rating_of_record_pattern not in ('Z') then
      hr_utility.set_message(8301, 'GHR_38428_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
    end if;
  end if;


/* void due to lack of submission date
--472.02.1
   if p_rating_of_record_period is not null  and
      fnd_date.canonical_to_date(p_rating_of_record_period) > p_submission_date then
       hr_utility.set_message(8301, 'GHR_37503_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
*/
--Bug# 4753117 28-Feb-07	Veeramani    commented as this edit is not required as per the
                        --bug description

/*--472.02.2
   if  p_rating_of_record_period is not null and
       fnd_date.canonical_to_date(p_rating_of_record_period) > p_effective_date then
       hr_utility.set_message(8301, 'GHR_37504_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
   */

--472.03.3
   if  p_rating_of_record_level = 'X' and
       p_rating_of_record_period is not null  then
       hr_utility.set_message(8301, 'GHR_37505_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
   end if;
--472.04.2
--            12/08/00    vravikan   01-Oct-00                 New Edit
--Bug# 4753117 28-Feb-07	Veeramani  adding edit 472.04.2 with respective to the
 --Appraisal start date
/* If rating of record (period) is not spaces,
Then it must not be more than 5 years earlier than the effective date of
personnel action.
*/
  l_end_date   := fnd_date.canonical_to_date(p_rating_of_record_period);
  l_start_date := fnd_date.canonical_to_date(p_rating_of_record_per_starts);
 if p_effective_date >= to_date('2000/10/01','yyyy/mm/dd') and
    ((p_rating_of_record_period is not null and
      months_between(p_effective_date,l_end_date  ) > 60) or
      (p_rating_of_record_per_starts is not null and
      months_between(p_effective_date,l_start_date  ) > 60)) then
      hr_utility.set_message(8301, 'GHR_37857_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
  end if;


end chk_rating_of_rec;



/* Name:
-- Position Occupied
*/


procedure chk_position_occupied
  (p_position_occupied_code 	in varchar2
  ,p_to_pay_plan            	in varchar2
  ,p_first_noac_lookup_code   in varchar2
  ,p_effective_date           in date
) is
begin


-- 500.02.3
--  17-Aug-00  vravikan   From the Start           Add VE
--  Dec 2001 Patch        01-Jul-01               Delete CZ, SZ, and WZ
   if p_effective_date >= to_date('2001/07/01','yyyy/mm/dd') THEN
     if (
	p_to_pay_plan in ('ED','EE','EF','EG','EH','EI',
                        'MA','SV','SW','VE','VM','VN','VP')
	or
       (substr(p_to_pay_plan,1,1)= 'F'  and
        p_to_pay_plan <> 'FC'
       )
	)
	and
      p_position_occupied_code <> '2'
	and
      p_position_occupied_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37908_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
   else
     if (
	p_to_pay_plan in ('CZ','ED','EE','EF','EG','EH','EI',
                        'MA','SV','SW','SZ','VE','VM','VN','VP','WZ')
	or
       (substr(p_to_pay_plan,1,1)= 'F'  and
        p_to_pay_plan <> 'FC'
       )
	)
	and
      p_position_occupied_code <> '2'
	and
      p_position_occupied_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37506_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
     end if;
   end if;

-- 500.04.3
   if p_to_pay_plan = 'ES' and
      p_position_occupied_code not in ('3','4')
	and
      p_position_occupied_code is not null
	 then
      hr_utility.set_message(8301, 'GHR_37507_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 500.07.2
   if (
	substr(p_first_noac_lookup_code,1,1) <> '3'
	and
      substr(p_first_noac_lookup_code,1,1) <> '4'
	) and
       (p_position_occupied_code = '3'
	  or
        p_position_occupied_code = '4')
	and
      p_to_pay_plan <>'ES'
	and
      p_position_occupied_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37508_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--UPDATED_BY	DATE		COMMENTS
------------------------------------------------------------
-- Madhuri     14-SEP-2004     Removed the NOACS- 112, 512
-------------------------------------------------------------
-- 500.13.2
   if p_first_noac_lookup_code in ('100','101','107','108','115',
                                    '120','122','124','140','141','500',
                                    '501','507','508','515','520',
                                    '522','524','540','541') and
      p_position_occupied_code <> '1' then
      hr_utility.set_message(8301, 'GHR_37509_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

--UPDATED_BY	DATE		COMMENTS
------------------------------------------------------------
-- amrchakr    26-SEP-2006     Removed the NOACS- '150','151','153',
--                             '154','155', '157' effective from 2003/07/01
-------------------------------------------------------------
-- 500.16.2
   if p_effective_date < fnd_date.canonical_to_date('2003/07/01') then
       if p_first_noac_lookup_code in ('150','151','153','154','155',
                                       '157','170','171','550','551',
                                       '553','554','555','570','571')
                                   and
                                       p_position_occupied_code <>'2'
                                   and
                                       p_position_occupied_code is not null
          then
          hr_utility.set_message(8301, 'GHR_37510_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
   else
       if p_first_noac_lookup_code in ('170','171','550','551',
                                       '553','554','555','570','571')
                                   and
                                       p_position_occupied_code <>'2'
                                   and
                                       p_position_occupied_code is not null
          then
          hr_utility.set_message(8301, 'GHR_37693_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
   end if;

end chk_position_occupied;

/* Name:
-- Prior Occupation
*/

procedure chk_prior_occupation
  (p_prior_occupation_code         in  varchar2  --non SF52
  ,p_occupation_code               in  varchar2  --non SF52
  ,p_first_noac_lookup_code        in  varchar2
  ,p_prior_pay_plan                in  varchar2  --non SF52
  ,p_agency_subelement             in  varchar2  --non SF52
  ,p_effective_date                in  date
  ) is
begin

-- 520.02.2
--26-Jun-06			Raju		From 01-Apr-2006		Added 611,613,894
--22-Jan-07 upd 49  Raju		From 01-Apr-2006		delete 894
--05-MAR-07         AVR                 Modify the CPDF edit 520.02.2 by adding 890 NOA.
-------------                           do not change the message until OPM Guidelines.
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   --BUG# 8264475 modified for dual actions to consider both of the dual noacs in
   -- dual correction while comparing with cpdf edits as occupation code may change
   -- in any of the NOACs
  if NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'N' then
    if p_effective_date < to_date('2006/04/01','yyyy/mm/dd') then
        if p_prior_occupation_code <> p_occupation_code and
            p_prior_occupation_code is not null and
            p_occupation_code is not null and
            p_first_noac_lookup_code not in ('702','703','713','721','740','741','800','850','855') and
            substr(p_first_noac_lookup_code,1,1) <> 5
        then
            hr_utility.set_message(8301, 'GHR_37511_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    else
        if p_prior_occupation_code <> p_occupation_code and
            p_prior_occupation_code is not null and
            p_occupation_code is not null and
            p_first_noac_lookup_code not in
                ('611','613','702','703','713','721','740','741','800','850','855','890') and
            substr(p_first_noac_lookup_code,1,1) <> 5
        then
            hr_utility.set_message(8301, 'GHR_37163_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
     end if;
   --added for dual actions
  elsif NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'Y' then
	if p_effective_date < to_date('2006/04/01','yyyy/mm/dd') then
	    if p_prior_occupation_code <> p_occupation_code and
		p_prior_occupation_code is not null and
		p_occupation_code is not null and
		NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) not in ('702','703','713','721','740','741','800','850','855') and
		substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1) <> 5 and
		NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) not in ('702','703','713','721','740','741','800','850','855') and
		substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1) <> 5

	    then
		hr_utility.set_message(8301, 'GHR_37511_ALL_PROCEDURE_FAIL');
		hr_utility.raise_error;
	    end if;
	else
	    if p_prior_occupation_code <> p_occupation_code and
		p_prior_occupation_code is not null and
		p_occupation_code is not null and
		NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) not in
		    ('611','613','702','703','713','721','740','741','800','850','855','890') and
		substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1) <> 5 and
		NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) not in
		    ('611','613','702','703','713','721','740','741','800','850','855','890') and
		substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1) <> 5
	    then
		hr_utility.set_message(8301, 'GHR_37163_ALL_PROCEDURE_FAIL');
		hr_utility.raise_error;
	    end if;
	 end if;
	end if;
end if;
-- 520.04.2
   -- 12/12/01 Change 2200 to 2500
   if (
	(p_prior_pay_plan ='LG' or p_prior_pay_plan ='ST')
	or
      substr(p_prior_pay_plan,1,1)='G'
	) and
      to_number(p_prior_occupation_code) >= 2500
      and
      p_prior_occupation_code is not null
     then
      hr_utility.set_message(8301, 'GHR_37512_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 520.07.2
   if substr(p_prior_pay_plan,1,1) in ('K','W','X')
	and
      to_number(p_prior_occupation_code) <= 2499
      and
      p_prior_occupation_code is not null
	then
      hr_utility.set_message(8301, 'GHR_37513_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 520.13.2
   if p_prior_occupation_code = '0605' and
      substr(p_agency_subelement, 1, 2) <> 'VA' then
      hr_utility.set_message(8301, 'GHR_37514_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 520.16.2
-- 28-Nov-2002  Madhuri Commented the edit.
/*   if p_prior_occupation_code = '0805' and
      substr(p_agency_subelement, 1, 2) not in ('AF','AR','DD','NV') then
      hr_utility.set_message(8301, 'GHR_37515_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;*/

-- 520.19.2
   -- removed 2806, 2808 as per update 7 on 16-jul-98
   -- End Dated as on 31st July 2001 for CPDF EOY 11i - Madhuri

if p_effective_date <= to_date('2001/07/31','yyyy/mm/dd') then
   if p_prior_occupation_code in ('2619','2843') and
      substr(p_agency_subelement, 1, 2) <> 'DN'   then
      hr_utility.set_message(8301, 'GHR_37516_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

--520.20.2
   -- added on 16 jul 1998 as per update 7
   -- If prior occupation is 2806 or 2808, then the first two positions of
   -- agency/subelement must be DN or IN
   -- End Dated as on 31st July 2001 for CPDF EOY 11i - Madhuri

if p_effective_date <= to_date('2001/07/31','yyyy/mm/dd') and
   p_effective_date >= to_date('1998/03/01','yyyy/mm/dd') then
    if p_prior_occupation_code in ('2806','2808') and
       substr(p_agency_subelement, 1, 2) NOT IN ('DN', 'IN')  then
         hr_utility.set_message(8301, 'GHR_37873_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
    end if;
end if;

end chk_prior_occupation;


/* Name:
-- Prior Pay Basis
*/

procedure chk_prior_pay_basis
  (p_prior_pay_basis      in  varchar2  --non SF52
  ,p_prior_pay_plan       in  varchar2  --non SF52
  ,p_agency_subelement    in  varchar2  --non SF52
  ,p_prior_basic_pay      in  varchar2  --non SF52
  ,p_effective_date       in  date
  ,p_prior_effective_date in date
  ,p_prior_pay_rate_det_code in varchar2
  ) is
cursor c_fw_pay_plans( p_pay_plan varchar2) is
       SELECT 'X'
	 FROM ghr_pay_plans
	WHERE equivalent_pay_plan = 'FW'
        AND   pay_plan = p_pay_plan;
 l_prior_basic_pay VARCHAR2(50);
begin

-- 530.02.2
--            17-Aug-00   vravikan   From the Start          Add one more condition
--                                                           PRD is other than A,B,E,F,M,U or V
 --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete Prior PRD M effective date from 01-May-2005
if p_effective_date < to_date('2005/05/01','yyyy/mm/dd') THEN
	if p_prior_pay_rate_det_code not in ('A','B','E','F','M','U','V')  then
	   if p_prior_pay_plan in ('AL','CA','ES','EX','GG','GH','GM','GS','SL')
		and
		  p_prior_pay_basis <> 'PA'
		and
		p_prior_pay_basis is not null
		then
		  hr_utility.set_message(8301, 'GHR_37517_ALL_PROCEDURE_FAIL');
		  hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
		  hr_utility.raise_error;
	   end if;

	   if p_prior_pay_plan = 'KA'
		and
		(p_prior_pay_basis <>'PA' and p_prior_pay_basis <>'PH')
		then
		  hr_utility.set_message(8301, 'GHR_37580_ALL_PROCEDURE_FAIL');
		  hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
		  hr_utility.raise_error;
	   end if;

	   if substr(p_prior_pay_plan,1,1) = 'X'  and
		  p_prior_pay_basis<>'PH'then
		  hr_utility.set_message(8301, 'GHR_37582_ALL_PROCEDURE_FAIL');
		  hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
		  hr_utility.raise_error;
	   end if;

	   if p_prior_pay_plan = 'ZZ' and p_prior_pay_basis <>'WC' then
		  hr_utility.set_message(8301, 'GHR_37583_ALL_PROCEDURE_FAIL');
		  hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
		  hr_utility.raise_error;
	   end if;
	end if;

elsif p_effective_date >= to_date('2005/05/01','yyyy/mm/dd') THEN
	if p_prior_pay_rate_det_code not in ('A','B','E','F','U','V')  then
		if	p_prior_pay_plan in ('AL','CA','ES','EX','GG','GH','GM','GS','SL') and
			p_prior_pay_basis <> 'PA' and
			p_prior_pay_basis is not null
		then
			hr_utility.set_message(8301, 'GHR_37517_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
			hr_utility.raise_error;
		end if;

		if	p_prior_pay_plan = 'KA' and
			(p_prior_pay_basis <>'PA' and p_prior_pay_basis <>'PH')
		then
			hr_utility.set_message(8301, 'GHR_37580_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
			hr_utility.raise_error;
		end if;

		if substr(p_prior_pay_plan,1,1) = 'X'  and
		  p_prior_pay_basis<>'PH'then
		  hr_utility.set_message(8301, 'GHR_37582_ALL_PROCEDURE_FAIL');
		  hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
		  hr_utility.raise_error;
		end if;

		if p_prior_pay_plan = 'ZZ' and p_prior_pay_basis <>'WC' then
			hr_utility.set_message(8301, 'GHR_37583_ALL_PROCEDURE_FAIL');
			hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
			hr_utility.raise_error;
		end if;
	end if;
end if;
/*530.10.2  If prior pay basis is PD,
          And agency/subelement is CU, FD, FL, FY, TRAJ, or TR35,
          Then prior basic pay may not exceed 1000.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/
-- UPDATE_DATE	UPDATED_BY	EFFECTIVE_DATE		COMMENTS
-----------------------------------------------------------------------------
-- 18-oct-04    Madhuri         from start of edit	Terminating the edit.
--

/*
   if p_prior_pay_basis = 'PD' and
         (substr(p_agency_subelement,1,2) in ('CU','FD','FL','FY') or
         p_agency_subelement in ('TRAJ','TR35')) and
         to_number(p_prior_basic_pay) > max_per_diem then
      hr_utility.set_message(8301, 'GHR_37519_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if; */
--
--
/*530.07.2  If prior pay basis is PA, PH, PM, BW, or WC,
          Then prior basic pay must not be greater than the
          maximum shown in table 18.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/

-- UPDATE DATE     UPDATE BY	BUG NO		COMMENTS
-----------------------------------------------------------------------------------------------------------------
-- 18-Oct-04	   Madhuri			Modifying the existing edit as under from 11-JAN-2004.
--						If pay basis is BW, PA, PD, PH, or WC,
--						Then basic pay must be within the range for the pay basis shown in Table 56.
--						splitting the error message for if and else part also.
-- 19-NOV-04       Madhuri                      Not splitting message. new message 38918 is being used now.
-- 29-DEC-04       Madhuri                      Modified rule of checking basic pay against range. No need to divide by 2087.
--- Modified for bug 4089960
-----------------------------------------------------------------------------------------------------------------
IF ( p_prior_pay_plan <> 'AD' ) THEN -- Sundar Bug 4307246
	IF ( p_effective_date < to_date('2004/01/11','yyyy/mm/dd') ) then

	max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 18',
					p_prior_pay_basis,
					'Maximum Basic Pay',
					p_prior_effective_date);

	 IF max_basic_pay IS NOT NULL then
	   IF (p_prior_pay_basis ='PA' and to_number(p_prior_basic_pay)> max_basic_pay ) or
	      (p_prior_pay_basis ='PH' and (to_number(p_prior_basic_pay)/2087)> max_basic_pay )  or
	      (p_prior_pay_basis ='PM' and to_number(p_prior_basic_pay)> max_basic_pay )  or
	      (p_prior_pay_basis ='BW' and to_number(p_prior_basic_pay)> max_basic_pay )   or
	      (p_prior_pay_basis ='WC' and to_number(p_prior_basic_pay)> max_basic_pay )
		then
	      hr_utility.set_message(8301, 'GHR_37518_ALL_PROCEDURE_FAIL');
	      hr_utility.raise_error;
	   END IF;
	 END IF;
	ELSE -- if after 11th Jan 2004
	 -- From: If prior pay basis is PA, PH, PM, BW, or WC, Then prior basic pay must not be greater than the maximum shown in table 18.
	 -- To: If prior pay basis is BW, PA, PD, PH, or WC, Then prior basic pay must be within the range for the pay basis shown in Table 56.

	      max_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
					p_prior_pay_basis,
					'Maximum Basic Pay',
					p_prior_effective_date);

	      min_basic_pay := GHR_CPDF_CHECK.get_basic_pay('CPDF Oracle Federal Table 56',
					 p_prior_pay_basis,
					 'Minimum Basic Pay',
					 p_prior_effective_date);

	   l_prior_basic_pay := p_prior_basic_pay;
	   for  pay_plan_rec in c_fw_pay_plans(p_prior_pay_plan) loop
	       hr_utility.set_location('Inside FW pay plan ',45);
	       IF p_prior_pay_basis = 'PH' THEN
		  hr_utility.set_location('Inside PH',50);
		  l_prior_basic_pay := to_char(to_number(p_prior_basic_pay)/2087);
	       END IF;
	   end loop;

	 IF ( max_basic_pay IS NOT NULL and min_basic_pay IS NOT NULL ) then
	   IF (p_prior_pay_basis ='PA' and NOT (to_number(l_prior_basic_pay) BETWEEN min_basic_pay AND max_basic_pay )) or
	      (p_prior_pay_basis ='PH' and NOT (to_number(l_prior_basic_pay) BETWEEN min_basic_pay AND max_basic_pay ))  or
	      (p_prior_pay_basis ='PD' and NOT (to_number(l_prior_basic_pay) BETWEEN min_basic_pay AND max_basic_pay ))  or
	      (p_prior_pay_basis ='BW' and NOT (to_number(l_prior_basic_pay) BETWEEN min_basic_pay AND max_basic_pay))   or
	      (p_prior_pay_basis ='WC' and NOT (to_number(l_prior_basic_pay) BETWEEN min_basic_pay AND max_basic_pay ))
	   THEN
	       hr_utility.set_message(8301, 'GHR_38918_ALL_PROCEDURE_FAIL');
	       hr_utility.raise_error;
	   END IF;
	END IF;

	END IF;
END IF; -- IF ( p_prior_pay_plan <> 'AD' ) THEN

/*530.12.2  If prior pay basis is PD,
          And agency/subelement is other than CU, FD, FL, FY,
          TRAJ, or TR35,
          Then prior basic pay may not exceed the maximum on
          Table 18.

          Default:  Insert asterisks in prior pay basis and prior
                    basic pay.*/

-- UPDATE_DATE	UPDATED_BY	EFFECTIVE_DATE		COMMENTS
-----------------------------------------------------------------------------
-- 18-oct-04    Madhuri         from start of edit	Terminating the edit.
--
/*   if p_prior_pay_basis = 'PD' and
         (substr(p_agency_subelement,1,2) in ('CU','FD','FL','FY') or
         p_agency_subelement in ('TRAJ','TR35')) and
      to_number(p_prior_basic_pay) > max_basic_pay then
      hr_utility.set_message(8301, 'GHR_37520_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;*/


end chk_prior_pay_basis;

/* Name:
-- Prior Grade
*/

procedure chk_prior_grade
  (p_prior_pay_plan         	in  varchar2  --non SF52
  ,p_grade_or_level         	in  varchar2
  ,p_prior_grade            	in  varchar2  --non SF52
  ,p_to_pay_plan            	in  varchar2
  ,p_first_noac_lookup_code 	in  varchar2
  ,p_prior_pay_rate_det_code	in  varchar2  --non SF52
  ,p_effective_date           in  date
  ) is
begin

-- 540.02.2
--BUG# 8264475 modified for dual actions to consider both of the dual noacs in
   -- dual correction while comparing with cpdf edits as grade may change
   -- in any of the NOACs

 if NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'N' then
   if (p_to_pay_plan = 'GM' or p_to_pay_plan = 'GS') and
      (p_prior_pay_plan = 'GM' or p_prior_pay_plan = 'GS') and
       p_grade_or_level <> p_prior_grade and
       p_grade_or_level is not null and
       p_prior_grade is not null and
       (p_first_noac_lookup_code not in ( '702','703','713','740','741') and
        substr(p_first_noac_lookup_code,1,1) <> '5') then
      hr_utility.set_message(8301, 'GHR_37521_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
   --Modified for dual actions
 elsif NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'Y' then
   if (p_to_pay_plan = 'GM' or p_to_pay_plan = 'GS') and
      (p_prior_pay_plan = 'GM' or p_prior_pay_plan = 'GS') and
       p_grade_or_level <> p_prior_grade and
       p_grade_or_level is not null and
       p_prior_grade is not null and
       (NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) not in ( '702','703','713','740','741') and
        substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1) <> '5') and
       (NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) not in ( '702','703','713','740','741') and
        substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1) <> '5') then
      hr_utility.set_message(8301, 'GHR_37521_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
    end if;
  end if;

-- 540.03.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'FG' and
      p_prior_grade not between '01' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37522_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.04.2
   if p_first_noac_lookup_code = '769' and
      p_prior_grade <> p_grade_or_level then
      hr_utility.set_message(8301, 'GHR_37523_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.05.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'FM' and
      p_prior_grade not between '13' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37524_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.06.2
   -- Update/Change     Date        By          Effective Date            Comment
   --   9/2           08/16/99    vravikan        01-Mar-1999             New Edit
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
  if p_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01') then
   if p_prior_pay_plan = 'EZ' and
      p_prior_grade not between '01' and '08'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37185_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
 end if;
end if;

-- 540.07.2
-- Update     Date        By        Effective Date            Comment
   --   9     14/05/99    vravikan                            Add prior pay plans CG and MG
   -- UPD 56  8309414       Raju       From 17-apr-08            Remove MG
   if p_effective_date < fnd_date.canonical_to_date('2008/04/17') then
       if  p_prior_pay_plan in ( 'CG','MG','WL','XG' )  and
          p_prior_grade not between '01' and '15'
          and p_prior_grade is not null then
          hr_utility.set_message(8301, 'GHR_37525_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','CG,MG,WL or XG');
          hr_utility.raise_error;
       end if;
   else
       if  p_prior_pay_plan in ( 'CG','WL','XG' )  and
          p_prior_grade not between '01' and '15'
          and p_prior_grade is not null then
          hr_utility.set_message(8301, 'GHR_37525_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PAY_PLAN','CG,WL or XG');
          hr_utility.raise_error;
       end if;
   end if;

-- 540.10.2
   if (p_prior_pay_plan = 'WS' or p_prior_pay_plan = 'XH') and
      p_prior_grade not between '01' and '19'

      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37526_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.13.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'FA' and
      p_prior_pay_rate_det_code <>'S' and
      p_prior_grade not in ( 'CA','CM','MC','NC','OC','01','02','03','04','13','14')
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37527_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.16.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'CE' and
      p_prior_grade not between '01' and '17'  and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37528_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.17.2
   --  If prior pay plan is CY,
   --  Then prior grade must be 01 through 24 or asterisks.
   --
   --  Included effective date on 16-jul-1998
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
      if p_prior_pay_plan = 'CY' and
         p_prior_grade not between '01' and '24'  and
         p_prior_grade is not null 	then
         hr_utility.set_message(8301, 'GHR_37874_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;

-- 540.18.2
   if (p_prior_pay_plan = 'AL' or p_prior_pay_plan = 'CA') and
      p_prior_grade not between '01' and '03'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37529_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.19.2
   if p_prior_pay_plan = 'GM' and
      p_prior_grade not between '13' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37530_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.20.2
   if p_prior_pay_plan = 'GS' and
      p_prior_grade not between '01' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37531_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.22.2
	-- Update/Change Date	By			Effective Date		Comment
	-- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
	IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
	   if p_prior_pay_plan = 'VM' and
		  p_prior_grade not in ('11','12','13','14','15','96','97') and
		  p_prior_grade is not null
	   then
		  hr_utility.set_message(8301, 'GHR_37532_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
	END IF;

-- 540.25.2
   if p_prior_pay_plan = 'VN' and
      p_prior_grade not in ('01','02','03','04','05','06','08','09',
                            '11','12','13','14','15')

      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37533_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.28.2
   if p_prior_pay_plan = 'VP' and
      p_prior_grade not between '11' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37534_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.29.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'DR' and
      p_prior_grade not between '01' and '04'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37538_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.31.2
   if (p_prior_pay_plan = 'WG' or p_prior_pay_plan = 'XF') and
       p_prior_grade not between '01' and '15'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37535_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.32.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'ND' or p_prior_pay_plan = 'NT') and
       p_prior_grade not between '01' and '06'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37585_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.33.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'NG' and
      p_prior_grade not between '01' and '05'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37536_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.34.2
   if p_prior_pay_plan = 'EX' and
      p_prior_grade not between '01' and '05'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37536_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.35.2
   --
   -- added on 16 jul 98 as per update 7
   --
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
      if p_prior_pay_plan in ('NH', 'NJ') and
         p_prior_grade not between '01' and '04' and
         p_prior_grade is not null  then
         hr_utility.set_message(8301, 'GHR_37871_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

-- 540.36.2
   --
   -- added on 16 jul 98 as per update 7
   --
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('1998/03/01') then
      if p_prior_pay_plan =  'NK' and
         p_prior_grade not between '01' and '03' and
         p_prior_grade is not null  then
         hr_utility.set_message(8301, 'GHR_37872_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;

/* Commenting the edit as per Sept.2000 patch -- refer to doc cpdf_edits_00_sep.doc
-- 540.37.2
   if p_prior_pay_plan = 'OC' and
      p_prior_grade not between '01' and '25'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37537_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
*/
--  540.38.2
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   10/01/1998                   New Edit
   -- 13-Jun-06			Raju		01-Jan-03			Terminate the edit
   -- If prior pay plan is FV, then prior grade must be 'AA' through 'MM' or asterisks
   --
   if	p_effective_date >= fnd_date.canonical_to_date('1998/10/01') and
		p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
      if p_prior_pay_plan = 'FV' and
         p_prior_grade not in ('AA','BB','CC','DD','EE','FF','GG','HH','II',
                                      'JJ','KK','LL','MM')  and
         p_prior_grade is not null then
         hr_utility.set_message(8301, 'GHR_37033_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;

--  540.39.2
   --
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   10/01/1998                New Edit
   -- If prior pay plan is EV, then prior grade must be 01 through 03 or asterisks
   --
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('1998/10/01') then
      if p_prior_pay_plan = 'EV' and
         p_prior_grade not in ('01', '02', '03')  and
         p_prior_grade is not null then
         hr_utility.set_message(8301, 'GHR_37034_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
   end if;
end if;

-- 540.40.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'NY' and
      p_prior_grade not between '01' and '04'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37538_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.43.2
   if p_prior_pay_plan = 'FO' and
      p_prior_grade not between '01' and '08'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37539_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.45.2
   if p_prior_pay_plan = 'FP' and
      (p_prior_grade not between '01' and '09' or
          p_prior_grade in ('AA','BB','CC','DD','EE')
	)
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37540_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.46.2
   if p_prior_pay_plan = 'FE' and
      p_prior_grade not in ('CA','CM','MC','OC','01','02','03')
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37541_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.49.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'AF' and
      p_prior_grade not in ('AA','BB','CC','DD','EE')
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37542_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.52.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'FC' and
      p_prior_grade not between '02' and '14'
      and
	p_prior_grade is not null
	then
      hr_utility.set_message(8301, 'GHR_37543_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.55.2
   if p_prior_pay_plan = 'GG' and
      not( p_prior_grade between '01' and '15' or
          p_prior_grade is null or
          p_prior_grade = 'SL' )
	then
      hr_utility.set_message(8301, 'GHR_37544_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.56.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/5        08/13/99    vravikan   01-Apr-99                 New Edit
   /* If prior pay plan is NC, then prior grade must be 01 through 03 */
   if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
     if p_prior_pay_plan = 'NC' and
       not( p_prior_grade in ('01','02','03')  or
          p_prior_grade is null )
	then
       hr_utility.set_message(8301, 'GHR_37071_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
-- 540.57.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/5        08/13/99    vravikan   01-Apr-99                 New Edit
   --upd47         26-Jun-06	Raju	  01-Apr-2006		        Change prior grade 04 to 05
   --7642919       16-Dec-08    Raju      01-Apr-2006               Included grade 04
   /* If prior pay plan is NO, then prior grade must be 01 through 04 */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
        if p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
            if p_prior_pay_plan = 'NO' and
                not( p_prior_grade in ('01','02','03','04')  or
                p_prior_grade is null ) then
                hr_utility.set_message(8301, 'GHR_37072_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PRIOR_GRD','01 through 04');
                hr_utility.raise_error;
            end if;
        else
            if p_prior_pay_plan = 'NO' and
                not( p_prior_grade in ('01','02','03','04','05')  or
                p_prior_grade is null ) then
                hr_utility.set_message(8301, 'GHR_37072_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PRIOR_GRD','01 through 05');
                hr_utility.raise_error;
            end if;
        end if;
    end if;
end if;

-- 540.58.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/5        08/13/99    vravikan   01-Apr-99                 New Edit
   /* If prior pay plan is NP or NR, then prior grade must be 01 through 05 */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= fnd_date.canonical_to_date('19'||'99/04/01') then
     if p_prior_pay_plan in ( 'NP','NR') and
       not( p_prior_grade in ('01','02','03','04','05')  or
          p_prior_grade is null )
	then
       hr_utility.set_message(8301, 'GHR_37073_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;

-- 540.60.2
   if p_prior_pay_plan = 'GH' and
      not( p_prior_grade between '13' and '15' or
          p_prior_grade is null )
	then
      hr_utility.set_message(8301, 'GHR_37545_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 540.61.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'SL' or p_prior_pay_plan = 'XE')
      and
	p_prior_grade <> '00'
	and
       p_prior_grade is not null
      then
      hr_utility.set_message(8301, 'GHR_37546_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 540.62.2
-- Update/Change Date	By			Effective Date		Comment
--    18-Aug-00		vravikan		01-May-2000         New Edit
--	13-Jun-06			Raju		01-Jan-03			Terminate the edit

/* If Prior Pay plan is VE,
   Then prior grade must be 01, 02, or asterisks */
   if p_effective_date >= to_date('2000/05/01', 'yyyy/mm/dd') and
   p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
     if p_prior_pay_plan = 'VE' and
      not( p_prior_grade in ('01','02') or
          p_prior_grade is null )
     then
       hr_utility.set_message(8301, 'GHR_37421_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;

-- 540.63.2
--    18-Aug-00  vravikan        01-Jun-2000            New Edit
/* If Prior Pay plan is NB,
   Then prior grade must be 01 through 09, or asterisks */
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_effective_date >= to_date('2000/06/01', 'yyyy/mm/dd') then
     if p_prior_pay_plan = 'NB' and
      p_prior_grade not in ('01', '02','03','04','05','06','07','08','09')
      and p_prior_grade is not null
     then
       hr_utility.set_message(8301, 'GHR_37422_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;

-- Begin Bug# 5073313
--540.65.2
	 -- Update/Change Date        By        Effective Date            Comment
	 --  Upd 46  13-Jun-06        Raju      01-Jan-2006               New Edit
	If p_effective_date >= to_date('2006/01/01', 'yyyy/mm/dd') then
		if  p_prior_pay_plan in ('GL') and
			p_prior_grade not in ('03','04','05','06','07','08','09','10') and
			p_prior_grade is not null
		then
			hr_utility.set_message(8301, 'GHR_37432_ALL_PROCEDURE_FAIL');
			hr_utility.raise_error;
		end if;
	end if;
-- End Bug# 5073313

--Begin Bug# 5745356
--550.00.2
    If p_effective_date >= to_date('2006/10/01', 'yyyy/mm/dd') then
        if  p_prior_pay_plan in ('GL') and
            p_prior_grade > '10' and
            p_prior_grade is not null then
            --Bug# 6959477 message number 38629 is duplicated, so created new message with #38158
            hr_utility.set_message(8301, 'GHR_38158_ALL_PROCEDURE_FAIL');
            hr_utility.raise_error;
        end if;
    end if;
--End Bug# 5745356

end chk_prior_grade;

/* Name:
-- Prior Pay Plan
*/

procedure chk_prior_pay_plan
  (p_prior_pay_plan            in  varchar2  --non SF52
  ,p_to_pay_plan               in  varchar2
  ,p_first_noac_lookup_code    in  varchar2
  --,p_prior_effective_date      in  date -- deleted Bug# 6010943
  ,p_effective_date      in  date --  Added Bug# 6010943
  ) is
begin

-- 550.02.2
   -- Update Date        By        Effective Date            Comment
   --   8   01/28/99    vravikan   10/01/1998               Add nature of action codes 600-610
   --upd47  26-Jun-06	Raju	   From 01-Apr-2006		    Added 611,613
   -- upd51 06-Feb-07	Raju       From 01-Jan-2007	    Bug#5745356 add 890
   --BuG# 6010943       Raju       Modified the p_prior_effective_date to p_effective_date
   --
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   --BUG# 8264475 modified for dual actions to consider both of the dual noacs in
   -- dual correction while comparing with cpdf edits as pay plan may change
   -- in any of the NOACs
  if NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'N' then
    if p_effective_date < fnd_date.canonical_to_date('1998/10/01') then
       if p_prior_pay_plan <> p_to_pay_plan and
          p_prior_pay_plan is not null and
          p_to_pay_plan is not null and
            not(p_first_noac_lookup_code in ('702','703','713','721','740','741','850','855','894') or
          substr(p_first_noac_lookup_code,1,1)= '5') then
          hr_utility.set_message(8301, 'GHR_37547_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    elsif p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
       if p_prior_pay_plan <> p_to_pay_plan and
          p_prior_pay_plan is not null and
          p_to_pay_plan is not null and
        not(p_first_noac_lookup_code in ('600','601','602','603','604','605','606','607','608','609','610',
                                        '702','703','713','721','740','741','850','855','894') or
          substr(p_first_noac_lookup_code,1,1)= '5') then
          hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 741, 850, 855 or 894');
          hr_utility.raise_error;
       end if;
     elsif p_effective_date < fnd_date.canonical_to_date('2007/01/01') then
        if p_prior_pay_plan <> p_to_pay_plan and
          p_prior_pay_plan is not null and
          p_to_pay_plan is not null and
        not(p_first_noac_lookup_code in ('600','601','602','603','604','605','606','607','608','609','610',
                                        '611','613','702','703','713','721','740','741','850','855','894') or
          substr(p_first_noac_lookup_code,1,1)= '5') then
          hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','611, 613, 702, 703, 713, 721, 740, 741, 850, 855 or 894 ');
          hr_utility.raise_error;
       end if;
     else
        if p_prior_pay_plan <> p_to_pay_plan and
          p_prior_pay_plan is not null and
          p_to_pay_plan is not null and
        not(p_first_noac_lookup_code in ('600','601','602','603','604','605','606','607','608','609','610',
                                        '611','613','702','703','713','721','740','741','850','855','890','894') or
          substr(p_first_noac_lookup_code,1,1)= '5') then
          hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','611, 613, 702, 703, 713, 721, 740, 741, 850, 855, 890, or 894');
          hr_utility.raise_error;
       end if;
    end if;
 --Modified for dual actions
 elsif NVL(ghr_process_sf52.g_dual_action_yn,'N') = 'Y' then
	 if p_effective_date < fnd_date.canonical_to_date('1998/10/01') then
	   if p_prior_pay_plan <> p_to_pay_plan and
	      p_prior_pay_plan is not null and
	      p_to_pay_plan is not null and
		not(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) in ('702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1)= '5') and
		not(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) in ('702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1)= '5')then
	      hr_utility.set_message(8301, 'GHR_37547_ALL_PROCEDURE_FAIL');
	      hr_utility.raise_error;
	   end if;
	elsif p_effective_date < fnd_date.canonical_to_date('2006/04/01') then
	   if p_prior_pay_plan <> p_to_pay_plan and
	      p_prior_pay_plan is not null and
	      p_to_pay_plan is not null and
	    not(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1)= '5') and
	      not(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1)= '5') then
	      hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
	      hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 741, 850, 855 or 894');
	      hr_utility.raise_error;
	   end if;
	 elsif p_effective_date < fnd_date.canonical_to_date('2007/01/01') then
	    if p_prior_pay_plan <> p_to_pay_plan and
	      p_prior_pay_plan is not null and
	      p_to_pay_plan is not null and
	    not(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '611','613','702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1)= '5') and
	      not(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '611','613','702','703','713','721','740','741','850','855','894') or
	      substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1)= '5') then
	      hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
	      hr_utility.set_message_token('NOA_CODE','611, 613, 702, 703, 713, 721, 740, 741, 850, 855 or 894 ');
	      hr_utility.raise_error;
	   end if;
	 else
	    if p_prior_pay_plan <> p_to_pay_plan and
	      p_prior_pay_plan is not null and
	      p_to_pay_plan is not null and
	    not(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '611','613','702','703','713','721','740','741','850','855','890','894') or
	      substr(NVL(ghr_process_sf52.g_dual_first_noac,p_first_noac_lookup_code),1,1)= '5') and
	      not(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code) in ('600','601','602','603','604','605','606','607','608','609','610',
					    '611','613','702','703','713','721','740','741','850','855','890','894') or
	      substr(NVL(ghr_process_sf52.g_dual_second_noac,p_first_noac_lookup_code),1,1)= '5') then
	      hr_utility.set_message(8301, 'GHR_37035_ALL_PROCEDURE_FAIL');
	      hr_utility.set_message_token('NOA_CODE','611, 613, 702, 703, 713, 721, 740, 741, 850, 855, 890, or 894');
	      hr_utility.raise_error;
	   end if;
	end if;
	end if;
end if;

end chk_prior_pay_plan;



-- Prior Pay Rate Determinant


procedure chk_prior_pay_rate_determinant
  (p_prior_pay_rate_det_code    in varchar2       --non SF52 item
  ,p_pay_rate_determinant       in varchar2
  ,p_prior_pay_plan             in varchar2       --non SF52 item
  ,p_to_pay_plan                in varchar2
  ,p_agency                     in varchar2
  ,p_First_NOAC_Lookup_Code     in varchar2
  ,p_prior_duty_stn             in varchar2       --non SF52 item
  ,p_prior_effective_date       in date
  ,P_effective_date				in 	date          -- FWFA Change
   ) is
   l_session                    ghr_history_api.g_session_var_type;

begin

-- 560.02.2
--  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete Prior PRD M effective date from 01-May-2005
IF P_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
	if	p_First_NOAC_Lookup_Code = '741' and
		p_prior_pay_rate_det_code not in ('A','B','E','F','M','U','V') and
		p_prior_pay_rate_det_code is not null
	then
		hr_utility.set_message(8301, 'GHR_37548_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','A, B, E, F, M, U, or V');
		hr_utility.raise_error;
	end if;
ELSIF P_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
	if	p_First_NOAC_Lookup_Code = '741' and
		p_prior_pay_rate_det_code not in ('A','B','E','F','U','V') and
		p_prior_pay_rate_det_code is not null
	then
		hr_utility.set_message(8301, 'GHR_37548_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','A, B, E, F, U, or V');
		hr_utility.raise_error;
	end if;
END IF;

-- 560.04.2
--            06/25/03    vravikan       By passing this edit if the
--                                          employee on RG Temporary promotion
--upd47  26-Jun-06	Raju	   From 01-Apr-2006		Added pay plan is other than Yx condition
if P_effective_date < fnd_date.canonical_to_date('2006/04/01') then
    IF GHR_GHRWS52L.g_temp_step IS NULL THEN
        if p_First_NOAC_Lookup_Code = '703' and
            p_prior_pay_rate_det_code in ('A','B','E','F','U','V') and
            p_pay_rate_determinant not in ('A','B','E','F','U','V') and
            p_pay_rate_determinant  is not null
        then
            hr_utility.set_message(8301, 'GHR_37549_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PRD_CODE','A, B, E, F, U, or V');
            hr_utility.raise_error;
        end if;
    END IF;
ELSE
   IF GHR_GHRWS52L.g_temp_step IS NULL THEN
        if p_First_NOAC_Lookup_Code = '703' and
            p_prior_pay_rate_det_code in ('A','B','E','F','U','V') and
            substr(p_prior_pay_plan,1,1) <> ('Y') and
            p_pay_rate_determinant not in ('A','B','E','F','U','V') and
            p_pay_rate_determinant  is not null
        then
            hr_utility.set_message(8301, 'GHR_37549_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PRD_CODE','A, B, E, F, U, or V, and pay plan is other than Yx');
            hr_utility.raise_error;
        end if;
    END IF;
END IF;

-- 560.06.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_rate_det_code = 'C' and
      (p_prior_pay_plan in ('ED','EE','EF','EG','EH','EI','ZZ')  or
       substr(p_prior_pay_plan,1,1) in ('B','W','X'))
      then
      hr_utility.set_message(8301, 'GHR_37550_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 560.07.2
   if p_prior_pay_rate_det_code = '4' and
      ( substr(p_prior_pay_plan,1,1) ='W' or
        substr(p_prior_pay_plan,1,1) ='X' )
	then
      hr_utility.set_message(8301, 'GHR_37551_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 560.10.2
--            06/25/03    vravikan       By passing this edit if the
--                                         employee on RG Temporary promotion
--            10/30/03    Ashley        Add nature of action 849 to the list
--            10/03/05    vnarasim      Added 892,893 in the other than list.
--            10/21/05    utokachi      Validate for actions prior to 01-MAY-2005
--  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete Prior PRD and PRD M effective date from 01-May-2005
--  UPD 45(Bug 4567571)   Raju	   14-Nov-2005	      Terminate the edit effective 01-Sep-2005

IF P_effective_date < to_date('2005/09/01','YYYY/MM/DD') THEN
	-- FWFA Changes
	IF P_effective_date < to_date('2005/05/01','YYYY/MM/DD') THEN
		 IF GHR_GHRWS52L.g_temp_step IS NULL THEN
		   if   (substr(p_First_NOAC_Lookup_Code,1,1) = '7'
			   or
				 substr(p_First_NOAC_Lookup_Code,1,1)='8')
			   and
				 p_First_NOAC_Lookup_Code not in ('702','703','713','721','740','800','815','816','817',
												  '825','840','841','842','843','844','845','846',
												  '847','848','849','866','878','879','892','893','894','899')
			   and
				 p_pay_rate_determinant <> 'M'
			   and
				 (p_prior_pay_rate_det_code not in ('5','7','M') or p_prior_pay_rate_det_code is null)
			   and
				 p_pay_rate_determinant <> p_prior_pay_rate_det_code
			   and
			   p_pay_rate_determinant  is not null
			   then
			  hr_utility.set_message(8301, 'GHR_37552_ALL_PROCEDURE_FAIL');
			  hr_utility.raise_error;
		   end if;
		END IF;
	ELSIF P_effective_date >= to_date('2005/05/01','YYYY/MM/DD') THEN
		 IF GHR_GHRWS52L.g_temp_step IS NULL THEN
		   if   (substr(p_First_NOAC_Lookup_Code,1,1) = '7'
			   or
				 substr(p_First_NOAC_Lookup_Code,1,1)='8')
			   and
				 p_First_NOAC_Lookup_Code not in ('702','703','713','721','740','800','815','816','817',
												  '825','840','841','842','843','844','845','846',
												  '847','848','849','866','878','879','892','893','894','899')
			   and
				 (p_prior_pay_rate_det_code not in ('5','7') or p_prior_pay_rate_det_code is null)
			   and
				 p_pay_rate_determinant <> p_prior_pay_rate_det_code
			   and
			   p_pay_rate_determinant  is not null
			   then
			  hr_utility.set_message(8301, 'GHR_38986_ALL_PROCEDURE_FAIL');
			  hr_utility.raise_error;
		   end if;
		END IF;
	END IF;
	-- FWFA Changes
End if;


-- 560.13.2
   if p_prior_pay_plan in ('FA','ST','EX') and
      p_prior_pay_rate_det_code not in ('C','S','0') and
	p_prior_pay_rate_det_code  is not null
	then
      hr_utility.set_message(8301, 'GHR_37553_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 560.28.2
-- Update     Date        By        Effective Date            Comment
-------------------------------------------------------------------------------------------------
--Bug#825741  03/08/99    vravikan                            Code correction
--            18/10/04    Madhuri   start of the edit         including the PRD - 2 to the list
--
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_pay_plan = 'ES' and
      p_prior_pay_rate_det_code not in ('C','0','2') and
        p_prior_pay_rate_det_code  is not null
	 then
      hr_utility.set_message(8301, 'GHR_37554_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
    end if;
end if;

-- 560.30.2
   --
   -- Get the session variable to check whether the action is correction
   -- If correction skip this edit as the prior_duty_station value might
   -- be incorrect. Bug #709282
   --
-------------------------------------------------------------------------------
-- Modified by       Date             Comments
-------------------------------------------------------------------------------
-- Madhuri          01-MAR-05         Retroactively end dating as of 31-JAN-2002
-------------------------------------------------------------------------------
IF p_prior_effective_date <= fnd_date.canonical_to_date('20'||'02/01/31') THEN

 ghr_history_api.get_g_session_var(l_session);
 If l_session.noa_id_correct is null then

   if p_prior_pay_rate_det_code  = 'M' and
   /* This is the code for the cities of Boston, Chicago, Los Angeles, New York, Philadelphia, San Diego,
      San Francisco, and Washington D.C.*/
   		(
		substr(p_prior_duty_stn,1,2) not in ('05','08','41','45','56','71','74','80','11') and

   /* This selects the counties that make up Boston CMSA */
		(
		substr(p_prior_duty_stn,1,2) = '25' and
		substr(p_prior_duty_stn,7,3) not in ('009','017','021','023','025')
		) and
   /* This selects the parts of other counties that make up Boston CMSA */
   /* part of Bristol County */
		 p_prior_duty_stn not in ('250007005','250039005','250096005','250188005','250251005',
		'250254005','250281005','250299005','250315005','250385005','250670005','250850005','250911005',
		'250912005','250913005','250924005','251064005','251062005','251135005','251219005','251225005',
 		'251280005')
		and
   /* part of Hampden County */
		 p_prior_duty_stn <> '250489013'
		and
   /* part of Worcester County */
		 p_prior_duty_stn not in ('250032027','250055027','250079027','250080027','250098027',
		 '250110027','250902027','250910027','250916027','250918027','250927027','250944027','250117027',
		 '250123027','250150027','250185027','250186027','250189027','250220027','250252027','250263027',
		 '250272027','250280027','250332027','250350027','250390027','250436027','250467027','250480027',
		 '250510027','250555027','250565027','250585027','250610027','250619027','250640027','250664027',
		 '250745027','250780027','250785027','250820027','250834027','250900027','250943027','250980027',
		 '250999027','251450027','251800027','251100027','251172027','251200027','251203027','251204027',
		 '251210027','251228027','251240027','251260027','251273027','251266027','251271027','251278027',
		 '251269027','251283027','251310027','251320027','251376027','251380027','251390027','251395027',
		 '251410027','251439027','251455027','251470027','251500027','251520027')
		and
   /* New Hampshire */
   /* part of Hillsborough County */
		 p_prior_duty_stn not in ('330011011','330018011','330031011','330160011','330180011',
		 '330234011','330240011','330299011','330310011','330324011','330334011','330340011','330344011',
		 '330350011','330357011','330401011','330434011','330509011','330540011')
		and
   /* part of Merrimack County */
		 p_prior_duty_stn <> '330236013' and
   /* part of Rockingham County */
		 p_prior_duty_stn not in ('330012015','330013015','330025015','330032015','330045015',
		 '330087015','330085015','330105015','330108015','330112015','330123015','330130015','330153015',
		 '330176015','330195015','330200015','330199015','330201015','330252015','330355015','330354015',
		 '330356015','330370015','330381015','330382015','330391015','330384015','330417015','330430015',
		 '330435015','330445015','330447015','330448015','330462015','330466015','330474015','330475015',
		 '330478015','330255015','330305015','330533015','330527015','330551015')
		and
   /* part of Strafford County */
		 p_prior_duty_stn not in ('330029017','330090017','330100017','330140017','330281017',
		 '330311017','330342017','330345017','330440017','330443017','330470017')
		and
   /* Maine */
   /* part of York County */
		 p_prior_duty_stn not in ('230450031','231445031','232450031','234250031','234300031',
		 '237450031','239800031','239900031','239950031')
		and
   /* Connecticut */
   /* part of Windham County */
		 p_prior_duty_stn not in ('090231015','090259015','090373015','090500015','090603015',
		 '090749015')
		and
   /* Chiacago */
   /* Illinois */
		(
		substr(p_prior_duty_stn,1,2) = '17' and
		  substr(p_prior_duty_stn,7,3) not in ('031','037','043','063','089','091','093','097',
		 '111','197')
		) and
   /* Indiana */
		(
		substr(p_prior_duty_stn,1,2) = '18' and
		substr(p_prior_duty_stn,7,3) not in ('089','027')
		) and
   /* Wisconsin */
		(
		 substr(p_prior_duty_stn,1,2) = '55' and
		 substr(p_prior_duty_stn,7,3) <> '059'
		) and
   /* Los Angeles */
		 (
		(substr(p_prior_duty_stn,1,2) = '06' and
		  substr(p_prior_duty_stn,7,3) not in ('037','059','065','071','083','111')) and
		 p_prior_duty_stn <> '061077029'
		) and
   /* New York */
		 (
		  substr(p_prior_duty_stn,1,2) = '36' and
		  substr(p_prior_duty_stn,7,3) not in ('005','027','047','059','061','071','079','081',
		 '085','087','103','119')
		  ) and
   /* New Jersey */
		 (
		  substr(p_prior_duty_stn,1,2) = '34' and
		  substr(p_prior_duty_stn,7,3) not in ('003','013','017','019','021','023','025','027',
		 '029','031','035','037','039','041')
		  ) and
   /* Connecticut */
		 (
		  substr(p_prior_duty_stn,1,2) = '09' and
		  substr(p_prior_duty_stn,7,3) not in ('001','0009')
		  ) and
   /* part of Litchfield County */
		 p_prior_duty_stn not in ('090051005','090083005','090247005','090629005','090740005',
		 '090802005','090805005','090450005','090454005','090535005','090817005','090857005')
		  and
   /* part of Middlesex County */
		 p_prior_duty_stn not in ('090130007','090332007')
	       and
   /* Pennsylvania */
		 (
		  substr(p_prior_duty_stn,1,2) = '42' and
		  substr(p_prior_duty_stn,7,3) <> '103'
		  ) and
   /* Philadelphia */
   /* Pennsylvania */
		 (
		  substr(p_prior_duty_stn,1,2) = '42' and
		  substr(p_prior_duty_stn,7,3) not in ('017','029','045','091','101')
		  ) and
   /* New Jersey */
		 (
		  substr(p_prior_duty_stn,1,2) = '34' and
		  substr(p_prior_duty_stn,7,3) not in ('001','005','007','009','011','015','033')
              ) and
   /* Delaware */
		 (
	        substr(p_prior_duty_stn,1,2) = '10' and
		  substr(p_prior_duty_stn,7,3) <> '015'
		  ) and
   /* San Diego */
		 (
		  substr(p_prior_duty_stn,1,2) = '06' and
		  substr(p_prior_duty_stn,7,3) <> '073'
	        ) and
   /* San Francisco */
		 (
		  substr(p_prior_duty_stn,1,2) = '06' and
		  substr(p_prior_duty_stn,7,3) not in ('001','013','041','055','075','081','085',
		 '087','095','097')
		  ) and
   /* Washington DC */
   /* Maryland */
		 (
		  substr(p_prior_duty_stn,1,2) = '24' and
		  substr(p_prior_duty_stn,7,3) not in ('003','005','009','013','017','021','025',
		 '027','031','033','035','037','043','510')
		  ) and
   /* Virginia */
		 (
		  substr(p_prior_duty_stn,1,2) = '51' and
		  substr(p_prior_duty_stn,7,3) not in ('013','043','047','059','061','099','107',
		 '153','177','179','187','510','600','610','630','683','685')
		  ) and
   /* West Virginia */
		 (
		  substr(p_prior_duty_stn,1,2) = '54' and
		  substr(p_prior_duty_stn,7,3) not in ('003','037')
		  )
		) then
      hr_utility.set_message(8301, 'GHR_37266_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
 end if;
END IF; -- End of checking date <= 31 Jan 2002
-------------------------------------------------------------------------------
-- 560.40.2
   -- Update/Change Date        By        Effective Date            Comment
   --   9/4        08/10/99    vravikan   01-Mar-99                 Exclude PRD T.
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   If p_prior_effective_date >= fnd_date.canonical_to_date('19'||'99/03/01') then
     if p_prior_pay_plan in ('GM','GS') and
       p_prior_pay_rate_det_code in ('P','T') then
       hr_utility.set_message(8301, 'GHR_37063_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   else
     if p_prior_pay_plan in ('GM','GS') and
       p_prior_pay_rate_det_code = 'P' then
       hr_utility.set_message(8301, 'GHR_37556_ALL_PROCEDURE_FAIL');
       hr_utility.raise_error;
     end if;
   end if;
end if;

 -- 560.43.2
 --  If prior pay rate determinant is Z,
 --  Then prior pay plan must not be FO or FP,
 --   And agency must be AM, GY, or ST,
 --   And the first two positions of prior duty station must be CA or MX.

 -- Date              By            Effective Date         Comment
 -- 30-OCT-2003       Ashley        From the Begining      New Edit.

   IF p_prior_pay_rate_det_code = 'Z' AND
       p_prior_pay_plan  IN ('FO','FP') AND
       p_agency NOT IN ('AM','GY','ST') AND
       substr(p_prior_duty_stn,1,2) NOT IN ('CA','MX') THEN
           hr_utility.set_message(8301, 'GHR_38842_ALL_PROCEDURE_FAIL');
           hr_utility.raise_error;
   END IF;

end chk_prior_pay_rate_determinant;




/* Name:
-- Prior Step or Rate
*/

procedure chk_prior_step_or_rate
  (p_prior_step_or_rate         in varchar2    --non SF52
  ,p_first_noac_lookup_code     in varchar2
  ,p_to_step_or_rate               in varchar2
  ,p_pay_rate_determinant_code  in varchar2
  ,p_to_pay_plan                in varchar2
  ,p_prior_pay_rate_det_code    in varchar2    --non SF52
  ,p_prior_pay_plan             in varchar2    --non SF52
  ,p_prior_grade                in varchar2    --non SF52
  ,p_prior_effective_date       in date
 ,p_cur_appt_auth_1            in varchar2
  ,p_cur_appt_auth_2            in varchar2
  ,p_effective_date             in date

  ) is
begin

-- 580.02.2
 -- Date              By            Effective Date         Comment
 -- 30-OCT-2003       Ashley        From the Begining      Added nature of action 849.
 -- upd50  06-Feb-07  Raju          From 01-Oct-2006	   Bug#5745356 delete NOA 849
 -- upd51  06-Feb-07  Raju          From 01-Jan-2007	   Bug#5745356 delete 815-817, 825
 --                                 840-848,878-879. Add 890
 -- upd53  20-Apr-07  Raju          From 01-Jan-2007	   Bug#5996938 added 815-817, 825
 --                                                        827,840-849,878-879.
 --        27-Jul-07  Raju          6279690                 Added 890 from the beginning.
 -- 890 is there in the previous versions. erroneously deleted while doing upd53.
  -- upd56  17-Mar-09  Raju          From 15-Feb-2007	   Bug#8309414 added 741

   IF p_prior_effective_date < to_date('2006/10/01','yyyy/mm/dd') then
       if (substr(p_first_noac_lookup_code,1,1) = '7' or
            substr(p_first_noac_lookup_code,1,1) = '8') and
            p_first_noac_lookup_code not in ('702','703','713','721','740','815','816','817','840','841',
                                               '842','843','844','845','846','847','848','849','855','866',
                           '867','868','878','879','890','891','892','893','894','899') and
            p_to_step_or_rate is not null and
            p_prior_step_or_rate is not null and
            p_prior_step_or_rate <> p_to_step_or_rate
       then
          hr_utility.set_message(8301, 'GHR_37557_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
   ELSIF p_prior_effective_date < to_date('2007/01/01','yyyy/mm/dd') THEN
       if (substr(p_first_noac_lookup_code,1,1) = '7' or
            substr(p_first_noac_lookup_code,1,1) = '8') and
            p_first_noac_lookup_code not in ('702','703','713','721','740','815','816','817','840','841',
                                               '842','843','844','845','846','847','848','855','866',
                           '867','868','878','879','890','891','892','893','894','899') and
            p_to_step_or_rate is not null and
            p_prior_step_or_rate is not null and
            p_prior_step_or_rate <> p_to_step_or_rate
       then
          --Bug# 6959477 message number 38805 is duplicated, so created new message with #38159
          hr_utility.set_message(8301, 'GHR_38159_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
   ELSIF p_prior_effective_date < to_date('2007/02/15','yyyy/mm/dd') THEN
       if (substr(p_first_noac_lookup_code,1,1) = '7' or
            substr(p_first_noac_lookup_code,1,1) = '8') and
            p_first_noac_lookup_code not in ('702','703','713','721','740','815','816','817','825','827',
                 '840','841','842','843','844','845','846','847','848','849',
                 '855','866','867','868','871','878','879','890','891','892','893','894','899') and
            p_to_step_or_rate is not null and
            p_prior_step_or_rate is not null and
            p_prior_step_or_rate <> p_to_step_or_rate
       then
          --Bug# 6959477 message number 38584 is duplicated, so created new message with #38156
          hr_utility.set_message(8301, 'GHR_38156_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 815-817, 825, 827, 840-849, 855, 866-868, 871, 878, 879, 890-894, or 899');
          hr_utility.raise_error;
       end if;
   ELSE
       if (substr(p_first_noac_lookup_code,1,1) = '7' or
            substr(p_first_noac_lookup_code,1,1) = '8') and
            p_first_noac_lookup_code not in ('702','703','713','721','740','741','815','816','817','825','827',
                 '840','841','842','843','844','845','846','847','848','849',
                 '855','866','867','868','871','878','879','890','891','892','893','894','899') and
            p_to_step_or_rate is not null and
            p_prior_step_or_rate is not null and
            p_prior_step_or_rate <> p_to_step_or_rate
       then
          --Bug# 6959477 message number 38584 is duplicated, so created new message with #38156
          hr_utility.set_message(8301, 'GHR_38156_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('NOA_CODE','702, 703, 713, 721, 740, 741, 815-817, 825, 827, 840-849, 855, 866-868, 871, 878, 879, 890-894, or 899');
          hr_utility.raise_error;
       end if;
   END IF;

-- 580.03.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'FG'
	and
	p_prior_step_or_rate not in ('00','01','02','03','04','05','06',
						'07','08','09','10')
      and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37558_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.04.2
 --  UPD 43(Bug 4567571)   Raju	   09-Nov-2005	      Delete PRD M effective date from 01-May-2005
 if p_prior_effective_date < to_date('2005/05/01','yyyy/mm/dd') then
	if  p_to_pay_plan = 'GS' and
		(p_first_noac_lookup_code = '892' or
		 p_first_noac_lookup_code = '893') 	and
		p_pay_rate_determinant_code in ('0','5','6','7','M') and
		to_number(p_prior_step_or_rate) > to_number(p_to_step_or_rate) and
		p_prior_step_or_rate is not null
	then
		hr_utility.set_message(8301, 'GHR_37559_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','0, 5, 6, 7, or M');
		hr_utility.raise_error;
	end if;
 elsif p_prior_effective_date >= to_date('2005/05/01','yyyy/mm/dd') then
	if  p_to_pay_plan = 'GS' and
		(p_first_noac_lookup_code = '892' or
		 p_first_noac_lookup_code = '893') 	and
		p_pay_rate_determinant_code in ('0','5','6','7') and
		to_number(p_prior_step_or_rate) > to_number(p_to_step_or_rate) and
		p_prior_step_or_rate is not null
	then
		hr_utility.set_message(8301, 'GHR_37559_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PRD_LIST','0, 5, 6, or 7');
		hr_utility.raise_error;
	end if;
 end if;


-- 580.07.2
   if (p_prior_pay_plan = 'CE' or p_prior_pay_plan = 'CY')
	and
      (to_number(p_prior_step_or_rate) not between 00 and 21)
    and
	p_prior_step_or_rate is not null
     then
      hr_utility.set_message(8301, 'GHR_37560_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.10.2
--            17-Aug-00   vravikan   01-jan-2000  Delete 99 form step/rate codes
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
    if p_prior_effective_date >= to_date('2000/01/01','yyyy/mm/dd') then
       if p_prior_pay_plan = 'GM' and p_prior_step_or_rate <> '00'
        and
        p_prior_step_or_rate is not null
        then
          hr_utility.set_message(8301, 'GHR_37424_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    else
       if p_prior_pay_plan = 'GM' and
         (p_prior_step_or_rate <>'00'  and  p_prior_step_or_rate <>'99' )
        and
        p_prior_step_or_rate is not null
        then
          hr_utility.set_message(8301, 'GHR_37561_ALL_PROCEDURE_FAIL');
          hr_utility.raise_error;
       end if;
    end if;
end if;

-- 580.13.2
-- NAME           EFFECTIVE      COMMENTS
-- Madhuri        21-JAN-2004    End Dating this edit as on 10-JAN-04
--				 For SES Pay Calculations
--p_effective_date
--upd47  26-Jun-06	Raju	   From 01-Jan-2004		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2004/01/01') then
	   if (p_effective_date < to_date('2004/01/11', 'yyyy/mm/dd') and
		   (p_prior_pay_plan = 'ES' or p_prior_pay_plan = 'FE') and
		   (to_number(p_prior_step_or_rate) not between 1 and 6) and
		    p_prior_step_or_rate is not null  ) then
		  hr_utility.set_message(8301, 'GHR_37562_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
	end if;
-- 580.19.2
--upd47  26-Jun-06	Raju	   From 01-Apr-2003		             Terminate the edit
	if p_effective_date < fnd_date.canonical_to_date('2003/04/01') then
	   if (p_prior_pay_rate_det_code in ('2','3','4')  or
		   p_prior_pay_rate_det_code in ('A','B','C','D','E','F','G','H','I','J',
											  'K','L','N','O','P','Q','R','S','T','U',
											  'V','W','X','Y','Z')) and
		   p_prior_pay_plan not in ('WT','FA','EX') and
		   p_prior_step_or_rate <>'00' and
		   p_prior_step_or_rate is not null
		then
		  hr_utility.set_message(8301, 'GHR_37563_ALL_PROCEDURE_FAIL');
		  hr_utility.raise_error;
	   end if;
	end if;

-- 580.22.2
--            12/8/00   vravikan    From the Start         Add UAM
-- Madhuri    19-MAY-04 Madhuri     From the Start         Included VP for list of prior Pay Plan
--
    if (p_prior_pay_plan in ('GS', 'GG', 'VP') and
      (p_prior_grade between '01' and '15') and
       p_prior_pay_rate_det_code in ('0','5','6','7') and
       p_cur_appt_auth_1 <> 'UAM' and p_cur_appt_auth_2 <> 'UAM' and
      (to_number(p_prior_step_or_rate) not between 1 and 10) and
        p_prior_step_or_rate is not null )
   then
      hr_utility.set_message(8301, 'GHR_37564_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.25.2
--  18-Sep-00  vravikan   From the Start           Add VE
--  19-MAY-04  Madhuri    From Start              Removed pay plan VP from list
-- 13-Jun-06	Raju		01-Jan-03			Terminate the edit
--
IF p_effective_date < fnd_date.canonical_to_date('2003/01/01') then --Bug# 5073313
    if (p_prior_pay_plan in ('VE','VM'/*,'VP'*/)) and
		p_prior_grade <> '97' and
		(to_number(p_prior_step_or_rate) not between 0 and 10) and
		p_prior_step_or_rate is not null
     then
      hr_utility.set_message(8301, 'GHR_37565_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
END IF;

-- 580.26.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'VM' and p_prior_grade = '97' and
     (to_number(p_prior_step_or_rate) not between 0 and 9)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37566_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.27.2
   if p_prior_pay_plan = 'VN' and
         (to_number(p_prior_step_or_rate) not between 0 and 28)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37567_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.29.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'XE' and
         (to_number(p_prior_step_or_rate) not between 1 and 3)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37568_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.31.2
   if p_prior_pay_plan = 'FO' and
         (to_number(p_prior_step_or_rate) not between 1 and 14)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37569_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.32.2
   if (p_prior_pay_plan = 'FP' and p_prior_grade between '01' and '09') and
         (to_number(p_prior_step_or_rate) not between 1 and 14)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37570_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.33.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'FP' and p_prior_grade in ('AA','BB','CC','DD','EE') and
         to_number(p_prior_step_or_rate) not between 1 and 5)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37571_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.34.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'AF' and
         (to_number(p_prior_step_or_rate) not between 1 and 5)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37572_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.37.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'FC' and
         p_prior_grade between '02' and '12') and
         (to_number(p_prior_step_or_rate) not between 1 and 10)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37573_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.40.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'FC' and p_prior_grade = '13') and
         (to_number(p_prior_step_or_rate) not between 1 and 9)
    and
	p_prior_step_or_rate is not null
    then
      hr_utility.set_message(8301, 'GHR_37574_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.43.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'FC' and p_prior_grade = '14') and
         (to_number(p_prior_step_or_rate) not between 1 and 5)
    and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37575_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.46.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan in ('CA','SL','ST') and
         p_prior_step_or_rate <>'00'
    and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37576_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.49.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'AL'
    and
	(p_prior_grade ='01' or p_prior_grade ='02')
    and
       p_prior_step_or_rate <>'00'
    and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37577_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.52.2
   if p_prior_pay_plan = 'AL' and p_prior_grade = '03' and
  --    p_prior_step_or_rate not in ('A','B','C','D','E','F')  bug # 612826
      p_prior_step_or_rate not in ('01','02','03','04','05','06')
    and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37578_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;

-- 580.55.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if p_prior_pay_plan = 'GG' and p_prior_grade = 'SL' and
      p_prior_step_or_rate <>'00'
    and
	p_prior_step_or_rate is not null
	then
      hr_utility.set_message(8301, 'GHR_37579_ALL_PROCEDURE_FAIL');
      hr_utility.raise_error;
   end if;
end if;

-- 580.57.2
-- UPD 56 (Bug# 8309414) Terminating the edit eff date 13-Aug-2007
if p_effective_date < fnd_date.canonical_to_date('2007/08/14') then
   if (p_prior_pay_plan = 'IJ' and p_prior_pay_rate_det_code in ('0','7')) then
      if NVL(p_prior_step_or_rate, '01') not in ('01','02','03','04') then
         hr_utility.set_message(8301, 'GHR_38413_ALL_PROCEDURE_FAIL');
         hr_utility.raise_error;
      end if;
    end if;
end if;

end chk_prior_step_or_rate;

end GHR_CPDF_CHECK5;

/
