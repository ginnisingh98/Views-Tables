--------------------------------------------------------
--  DDL for Package Body IRC_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_UTILITIES_PKG" AS
/* $Header: irutil.pkb 120.3.12010000.46 2010/05/20 06:59:56 vmummidi ship $ */
g_qual_party_id number;
g_qual_type varchar2(150);
g_emp_upt_party_id number;
g_emp_upt varchar2(80);
g_apl_upt_party_id number;
g_apl_upt varchar2(80);
g_prev_emp_party_id number;
g_prev_emp varchar2(240);

g_open_party_id number;
g_open_party varchar2(5);

g_rec_person_id_in number;
g_rec_person_id_out number;

g_internal_person_id number;
g_internal_person varchar2(5);
g_internal_email_address varchar2(240);
g_internal_email varchar2(5);
g_internal_user_name varchar2(100);
g_internal_user varchar2(5);

-- ----------------------------------------------------------------------------
-- |---------------------------< SET_SAVEPOINT  >-----------------------------|
-- ----------------------------------------------------------------------------

procedure SET_SAVEPOINT IS

BEGIN

savepoint IRC_SAVEPOINT;

END SET_SAVEPOINT;

-- ----------------------------------------------------------------------------
-- |-----------------------< ROLLBACK_TO_SAVEPOINT  >-------------------------|
-- ----------------------------------------------------------------------------

procedure ROLLBACK_TO_SAVEPOINT IS

BEGIN

rollback to savepoint IRC_SAVEPOINT;

END ROLLBACK_TO_SAVEPOINT;

-- -------------------------------------------------------------------
-- |--------------------< get_home_page_function >-------------------|
-- -------------------------------------------------------------------
procedure GET_HOME_PAGE_FUNCTION(p_responsibility_id in varchar2
                                ,p_function out nocopy varchar2) is
--
cursor csr_get_function_id is
select fe.function_id
from fnd_menu_entries fe
where fe.function_id is not null
start with fe.menu_id=
(select resp.menu_id from fnd_responsibility resp
 where resp.responsibility_id=p_responsibility_id
 and resp.application_id=800)
connect by prior fe.sub_menu_id= fe.menu_id
             and fe.grant_flag='Y'
order by level,fe.entry_sequence;
--
cursor csr_get_function_info(p_function_id number) is
select fff.function_name
from fnd_form_functions fff
where fff.function_id=p_function_id;
--
l_function_id fnd_menu_entries.function_id%type;
l_function_name fnd_form_functions.function_name%type;
--
begin
open csr_get_function_id;
fetch csr_get_function_id into l_function_id;
if csr_get_function_id%notfound then
  close csr_get_function_id;
else
  close csr_get_function_id;
  open csr_get_function_info(l_function_id);
  fetch csr_get_function_info into l_function_name;
  close csr_get_function_info;
end if;
--
p_function:=l_function_name;

END GET_HOME_PAGE_FUNCTION;

function removeTags(p_in varchar2) return varchar2 is
l_retval varchar2(32767);
begin
l_retval:=replace(p_in,'&','&'||'amp;');
l_retval:=replace(l_retval,'<','&'||'lt;');
return l_retval;
end removeTags;

function removeTags(p_in clob) return varchar2 is
l_v_retval varchar2(32767);
begin
l_v_retval:=dbms_lob.substr(p_in);
l_v_retval:=removeTags(l_v_retval);
return l_v_retval;
end removeTags;



-- ----------------------------------------------------------------------------
-- |-----------------------< GET_CURRENT_EMPLOYER  >--------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_CURRENT_EMPLOYER  (p_person_id  per_all_people_f.person_id%TYPE,
                                p_eff_date  date  )
  RETURN VARCHAR2

IS

l_employer   PER_PREVIOUS_EMPLOYERS.EMPLOYER_NAME%TYPE;


CURSOR c_current_employers(p_person_id PER_PREVIOUS_EMPLOYERS.PERSON_ID%TYPE,
                           p_date      PER_PREVIOUS_EMPLOYERS.END_DATE%TYPE)  IS
  SELECT empl.EMPLOYER_NAME
  FROM   PER_PREVIOUS_EMPLOYERS empl,
         PER_ALL_PEOPLE_F ppf,
         PER_ALL_PEOPLE_F ppf2
  WHERE  ppf.person_id = p_person_id
  AND    ppf.party_id = ppf2.party_id
  AND    p_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
  AND    p_date BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
  AND    ppf2.person_id = empl.person_id
  AND    p_date BETWEEN nvl(empl.START_DATE,trunc(SYSDATE))
                        and(nvl(empl.END_DATE,hr_api.g_eot));

BEGIN
--  MAIN FUNCTION LOGIC

  OPEN c_current_employers(p_person_id,p_eff_date);
  --Get an instance of current employer (not concerned if multiple)
  FETCH c_current_employers INTO l_employer;
  if c_current_employers%notfound then
    l_employer:='';
  end if;
  CLOSE c_current_employers;
  RETURN (l_employer);

END GET_CURRENT_EMPLOYER;


-- ----------------------------------------------------------------------------
-- |---------------------< GET_CURRENT_EMPLOYER_PTY  >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_CURRENT_EMPLOYER_PTY(p_party_id number,
                                  p_eff_date date)
  RETURN VARCHAR2

IS
CURSOR c_current_employers  IS
  SELECT ppe.employer_name
    FROM per_all_people_f       ppf
        ,per_previous_employers ppe
   WHERE ppf.party_id = p_party_id
     AND p_eff_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
     AND p_eff_date BETWEEN ppe.start_date AND NVL(ppe.end_date,HR_GENERAL.end_of_time)
     AND ppe.person_id = ppf.person_id
   ORDER BY NVL(ppe.end_date,HR_GENERAL.end_of_time) DESC
           ,NVL(ppe.start_date,HR_GENERAL.start_of_time) DESC;
BEGIN
--  MAIN FUNCTION LOGIC
  if(nvl(g_prev_emp_party_id,-1)<>p_party_id) then
    g_prev_emp_party_id:=p_party_id;
    OPEN c_current_employers;
    --Get an instance of current employer (not concerned if multiple)
    FETCH c_current_employers INTO g_prev_emp;
    if c_current_employers%notfound then
      g_prev_emp:='';
    end if;
    CLOSE c_current_employers;
  end if;
  RETURN (g_prev_emp);

END GET_CURRENT_EMPLOYER_PTY;


-- ----------------------------------------------------------------------------
-- |-------------------------< GET_MAX_QUAL_TYPE  >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_MAX_QUAL_TYPE  (p_person_id  per_all_people_f.person_id%TYPE)
  RETURN VARCHAR2

IS

l_qual_type   PER_QUALIFICATION_TYPES.NAME%TYPE;
l_qual_type2   PER_QUALIFICATION_TYPES.NAME%TYPE;
l_max_rank number;

CURSOR c_qual_types(p_person PER_ALL_PEOPLE_F.PERSON_ID%TYPE)  IS
  SELECT QTYP.NAME,qtyp.rank
  FROM   PER_QUALIFICATION_TYPES QTYP,
         PER_QUALIFICATIONS QUAL,
         PER_ALL_PEOPLE_F ppf,
         PER_ALL_PEOPLE_F ppf2
  WHERE ppf.person_id = p_person
  AND ppf.party_id = ppf2.party_id
  AND trunc(sysdate) BETWEEN ppf.effective_start_date and ppf.effective_end_date
  AND trunc(sysdate) BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
  AND ppf2.person_id = QUAL.PERSON_ID
  AND QUAL.QUALIFICATION_TYPE_ID = QTYP.QUALIFICATION_TYPE_ID
  order by QTYP.RANK desc, qual.awarded_date desc, qual.creation_date desc;

CURSOR c_qual_types2(p_person PER_ALL_PEOPLE_F.PERSON_ID%TYPE
                    ,p_max_rank number)  IS
  SELECT QTYP.NAME
  FROM   PER_QUALIFICATION_TYPES QTYP,
         PER_QUALIFICATIONS QUAL,
         PER_ESTABLISHMENT_ATTENDANCES ESTAB,
         PER_ALL_PEOPLE_F ppf,
         PER_ALL_PEOPLE_F ppf2
  WHERE ppf.person_id = p_person
  AND ppf.party_id = ppf2.party_id
  AND trunc(sysdate) BETWEEN ppf.effective_start_date and ppf.effective_end_date
  AND trunc(sysdate) BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
  AND ppf2.person_id = ESTAB.PERSON_ID
  AND estab.attendance_id=qual.attendance_id
  AND QUAL.QUALIFICATION_TYPE_ID = QTYP.QUALIFICATION_TYPE_ID
  and nvl(qtyp.rank,-1)>=nvl(p_max_rank,-1)
  order by QTYP.RANK desc, qual.awarded_date desc, qual.creation_date desc;

BEGIN
--  MAIN FUNCTION LOGIC

  OPEN c_qual_types(p_person_id);
  --Get an instance of a qualification of max rank
  FETCH c_qual_types INTO l_qual_type,l_max_rank;
  if c_qual_types%notfound then
    l_qual_type:='';
    l_max_rank:=-1;
  end if;
  CLOSE c_qual_types;
  OPEN c_qual_types2(p_person_id,l_max_rank);
  --Get an instance of a qualification of max rank
  FETCH c_qual_types2 INTO l_qual_type2;
  if c_qual_types2%found then
    l_qual_type:=l_qual_type2;
  end if;
  CLOSE c_qual_types2;

  RETURN (l_qual_type);

END GET_MAX_QUAL_TYPE;
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_MAX_QUAL_TYPE_PTY  >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_MAX_QUAL_TYPE_PTY  (p_party_id number)
  RETURN VARCHAR2

IS

l_qual_type   PER_QUALIFICATION_TYPES.NAME%TYPE;

CURSOR c_qual_types  IS
  SELECT QTYP.NAME
  FROM   PER_QUALIFICATION_TYPES QTYP,
         PER_QUALIFICATIONS QUAL,
         PER_ALL_PEOPLE_F ppf
  WHERE ppf.party_id = p_party_id
  AND trunc(sysdate) BETWEEN ppf.effective_start_date and ppf.effective_end_date
  AND ppf.person_id = QUAL.PERSON_ID
  AND QUAL.QUALIFICATION_TYPE_ID = QTYP.QUALIFICATION_TYPE_ID
  order by QTYP.RANK desc, qual.awarded_date desc, qual.creation_date desc;

CURSOR c_qual_types2  IS
  SELECT /*+ FIRST_ROWS */ QTYP.NAME
  FROM   PER_QUALIFICATION_TYPES QTYP,
         PER_QUALIFICATIONS QUAL,
         PER_ESTABLISHMENT_ATTENDANCES ESTAB,
         PER_ALL_PEOPLE_F ppf
  WHERE ppf.party_id = p_party_id
  AND trunc(sysdate) BETWEEN ppf.effective_start_date and ppf.effective_end_date
  AND ppf.person_id = ESTAB.PERSON_ID
  AND estab.attendance_id=qual.attendance_id
  AND QUAL.QUALIFICATION_TYPE_ID = QTYP.QUALIFICATION_TYPE_ID
  and not exists (select 1 from per_qualifications qual2,per_qualification_types qtyp2
                  where qual2.person_id=ppf.person_id
                  and qtyp2.qualification_type_id=qual2.qualification_type_id
                  and nvl(qtyp2.rank,-1)>nvl(qtyp.rank,-1))
  order by QTYP.RANK desc, qual.awarded_date desc, qual.creation_date desc;

BEGIN
--  MAIN FUNCTION LOGIC

  if (nvl(g_qual_party_id,-1) <>p_party_id) then
    g_qual_party_id:=p_party_id;

  OPEN c_qual_types2;
  --Get an instance of a qualification of max rank
  FETCH c_qual_types2 INTO g_qual_type;
  if c_qual_types2%notfound  then
    CLOSE c_qual_types2;
    OPEN c_qual_types;
    --Get an instance of a qualification of max rank
    FETCH c_qual_types INTO g_qual_type;
    if c_qual_types%notfound then
      g_qual_type:='';
    end if;
    CLOSE c_qual_types;
  else
    CLOSE c_qual_types2;
  end if;

  end if;

  RETURN (g_qual_type);

END GET_MAX_QUAL_TYPE_PTY;


-- ----------------------------------------------------------------------------
-- |-----------------------< GET_EMP_UPT_FOR_PERSON >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_EMP_UPT_FOR_PERSON (p_person_id  per_all_people_f.person_id%TYPE,
                                p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_emp_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
          ,PER_ALL_PEOPLE_F ppf2
    WHERE ppf.person_id = p_person_id
    AND ppf.party_id = ppf2.party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND p_eff_date BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
    AND ppf2.person_id = ptu.person_id
    AND ttl.language = userenv('LANG')
    AND ttl.person_type_id = typ.person_type_id
    AND typ.system_person_type IN ('EMP','EX_EMP')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                          AND ptu.effective_end_date
       order by typ.system_person_type ASC, ptu.effective_start_date DESC;

  l_user_person_type             per_person_types_tl.user_person_type%type;

BEGIN
  open csr_emp_person_types;
  fetch csr_emp_person_types into l_user_person_type;
  if csr_emp_person_types%notfound then
    l_user_person_type:=null;
  end if;
  close csr_emp_person_types;

  RETURN l_user_person_type;

END GET_EMP_UPT_FOR_PERSON;


-- ----------------------------------------------------------------------------
-- |-----------------------< GET_EMP_UPT_FOR_PARTY >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_EMP_UPT_FOR_PARTY (p_party_id  number,
                                p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_emp_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
    WHERE ppf.party_id = p_party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND ppf.person_id = ptu.person_id
    AND ttl.language = userenv('LANG')
    AND ttl.person_type_id = typ.person_type_id
    AND typ.system_person_type IN ('EMP','EX_EMP')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                          AND ptu.effective_end_date
       order by typ.system_person_type ASC, ptu.effective_start_date DESC;


BEGIN

  if (nvl(g_emp_upt_party_id,-1)<>p_party_id) then
    g_emp_upt_party_id:=p_party_id;
    open csr_emp_person_types;
    fetch csr_emp_person_types into g_emp_upt;
    if csr_emp_person_types%notfound then
      g_emp_upt:='';
    end if;
    close csr_emp_person_types;
  end if;

  RETURN g_emp_upt;

END GET_EMP_UPT_FOR_PARTY;




-- ----------------------------------------------------------------------------
-- |-----------------------< GET_APL_UPT_FOR_PERSON  >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_APL_UPT_FOR_PERSON (p_person_id  per_all_people_f.person_id%TYPE,
                                 p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_emp_person_type_exists
  IS
    SELECT GET_EMP_UPT_FOR_PERSON (ppf.person_id,p_eff_date)
      FROM per_people_f ppf
     WHERE ppf.person_id = p_person_id
       AND p_eff_date BETWEEN ppf.effective_start_date
                          AND ppf.effective_end_date;

  CURSOR csr_apl_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
          ,PER_ALL_PEOPLE_F ppf2
    WHERE ppf.person_id = p_person_id
    AND ppf.party_id = ppf2.party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND p_eff_date BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
    AND ppf2.person_id = ptu.person_id
    AND ttl.language = userenv('LANG')
    AND ttl.person_type_id = typ.person_type_id
    AND typ.system_person_type IN ('APL','EX_APL')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                       AND ptu.effective_end_date
    ORDER BY typ.system_person_type ASC, ptu.effective_start_date DESC;


  l_user_person_type             per_person_types_tl.user_person_type%type;
  l_dummy                        per_person_types_tl.user_person_type%type;

BEGIN
  open csr_emp_person_type_exists;
  fetch csr_emp_person_type_exists into l_dummy;
  if csr_emp_person_type_exists%found OR
    (GET_EMP_UPT_FOR_PERSON (p_person_id,p_eff_date)=null)
  then
      open csr_apl_person_types;
      fetch csr_apl_person_types into l_user_person_type;
      if csr_apl_person_types%notfound then
        l_user_person_type:=null;
      end if;
      close csr_apl_person_types;
  else
      l_user_person_type:=null;
  end if;
  close csr_emp_person_type_exists;

  RETURN l_user_person_type;

END GET_APL_UPT_FOR_PERSON;

-- ----------------------------------------------------------------------------
-- |-----------------------< GET_APL_UPT_FOR_PARTY >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_APL_UPT_FOR_PARTY (p_party_id  number,
                                p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_emp_person_types
  IS
    SELECT ttl.user_person_type
      FROM per_person_types_tl ttl
          ,per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
    WHERE ppf.party_id = p_party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND ppf.person_id = ptu.person_id
    AND ttl.language = userenv('LANG')
    AND ttl.person_type_id = typ.person_type_id
    AND typ.system_person_type IN ('APL','EX_APL')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                          AND ptu.effective_end_date
       order by typ.system_person_type ASC, ptu.effective_start_date DESC;

  l_user_person_type             per_person_types_tl.user_person_type%type;

BEGIN
  if (nvl(g_apl_upt_party_id,-1)<>p_party_id) then
    g_apl_upt_party_id:=p_party_id;
    open csr_emp_person_types;
    fetch csr_emp_person_types into g_apl_upt;
    if csr_emp_person_types%notfound then
      g_apl_upt:='';
    end if;
    close csr_emp_person_types;
  end if;
  RETURN g_apl_upt;

END GET_APL_UPT_FOR_PARTY;



-- ----------------------------------------------------------------------------
-- |-----------------------< GET_EMP_SPT_FOR_PERSON >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION GET_EMP_SPT_FOR_PERSON (p_person_id  per_all_people_f.person_id%TYPE,
                                 p_eff_date  date  )     RETURN VARCHAR2
IS
  CURSOR csr_emp_person_types
  IS
    SELECT typ.system_person_type
      FROM per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
          ,PER_ALL_PEOPLE_F ppf2
    WHERE ppf.person_id = p_person_id
    AND ppf.party_id = ppf2.party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND p_eff_date BETWEEN ppf2.effective_start_date and ppf2.effective_end_date
    AND ppf2.person_id = ptu.person_id
    AND typ.system_person_type IN ('EMP','EX_EMP')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                       AND ptu.effective_end_date
    order by typ.system_person_type ASC, ptu.effective_start_date DESC;

  l_system_person_type             per_person_types.system_person_type%type;

BEGIN
  open csr_emp_person_types;
  fetch csr_emp_person_types into l_system_person_type;
  if csr_emp_person_types%notfound then
    l_system_person_type:=null;
  end if;
  close csr_emp_person_types;

  RETURN l_system_person_type;

END GET_EMP_SPT_FOR_PERSON;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_recruitment_person_id >-------------------|
-- -------------------------------------------------------------------------
--
FUNCTION GET_RECRUITMENT_PERSON_ID
   (p_person_id                 IN     per_all_people_f.person_id%TYPE
   ,p_effective_date            IN     per_all_people_f.effective_start_date%TYPE)
  RETURN per_all_people_f.person_id%TYPE

IS
--
-- cursor to find party with a notification preference
--
  CURSOR csr_person_with_notif_prefs(p_person_id NUMBER
                                    ,p_effective_date DATE) IS
  SELECT inp.person_id
  FROM PER_ALL_PEOPLE_F PPF,
       IRC_NOTIFICATION_PREFERENCES INP,
       PER_ALL_PEOPLE_F PPF2
  WHERE ppf.person_id = p_person_id
  AND trunc(p_effective_date) BETWEEN ppf.effective_start_date
                        AND ppf.effective_end_date
  AND ppf.party_id = ppf2.party_id
  AND trunc(p_effective_date) BETWEEN ppf2.effective_start_date
                        AND ppf2.effective_end_date
  AND ppf2.person_id = inp.person_id;

begin

  if (nvl(g_rec_person_id_in,-1)<>p_person_id) then
    g_rec_person_id_in:=p_person_id;
    --
    -- check for a person with notif prefs
    --
    open csr_person_with_notif_prefs(p_person_id, p_effective_date);
    fetch csr_person_with_notif_prefs into g_rec_person_id_out;
    if csr_person_with_notif_prefs%notfound then
      g_rec_person_id_out:=p_person_id;
    end if;
    close csr_person_with_notif_prefs;
  end if;

  return g_rec_person_id_out;
end get_recruitment_person_id;
-- ----------------------------------------------------------------------------
-- |-----------------------< IS_OPEN_PARTY >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION IS_OPEN_PARTY (p_party_id  number
                       ,p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_is_emp is
  select 1
  from per_all_people_f per_per
  where per_per.party_id=p_party_id
  and p_eff_date between per_per.effective_start_date and per_per.effective_end_date
  and per_per.current_employee_flag='Y';
--
  cursor csr_has_vac is
  select 1
  from per_all_people_f per_per
  ,per_all_assignments_f per_asg
  ,per_vacancies per_vac
  where per_per.party_id=p_party_id
  and p_eff_date between per_per.effective_start_date and per_per.effective_end_date
  and per_per.person_id=per_asg.person_id
  and p_eff_date between per_asg.effective_start_date and per_asg.effective_end_date
  and per_asg.vacancy_id=per_vac.vacancy_id;
--

  l_dummy number;

BEGIN
  if (nvl(g_open_party_id,-1)<>p_party_id) then
    g_open_party_id:=p_party_id;
    g_open_party:='TRUE';
    open csr_is_emp;
    fetch csr_is_emp into l_dummy;
    if csr_is_emp%found then
      close csr_is_emp;
      open csr_has_vac;
      fetch csr_has_vac into l_dummy;
      if csr_has_vac%notfound then
        g_open_party:='FALSE';
      end if;
      close csr_has_vac;
    else
      close csr_is_emp;
    end if;
  end if;
  RETURN g_open_party;

END IS_OPEN_PARTY;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_person >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION is_internal_person (p_person_id  number
                            ,p_eff_date  date  )
  RETURN VARCHAR2
IS
  CURSOR csr_is_emp is
  select 1
  from per_all_people_f per_per
  where per_per.person_id=p_person_id
  and p_eff_date between per_per.effective_start_date and per_per.effective_end_date
  and (per_per.current_employee_flag='Y' or per_per.current_npw_flag='Y');
--
  CURSOR csr_is_emp2 is
  select 1
  from per_all_people_f per_per
  ,    per_all_people_f per_per2
  where per_per.person_id=p_person_id
  and p_eff_date between per_per.effective_start_date and per_per.effective_end_date
  and per_per.party_id is not null
  and per_per2.party_id=per_per.party_id
  and p_eff_date between per_per2.effective_start_date and per_per2.effective_end_date
  and (per_per2.current_employee_flag='Y' or per_per2.current_npw_flag='Y');
--
  l_dummy number;

BEGIN
  if (nvl(g_internal_person_id,-1)<>p_person_id) then
    g_internal_person_id:=p_person_id;
    g_internal_person:='FALSE';
    open csr_is_emp2;
    fetch csr_is_emp2 into l_dummy;
    if csr_is_emp2%found then
      close csr_is_emp2;
      g_internal_person:='TRUE';
    else
      close csr_is_emp2;
      open csr_is_emp;
      fetch csr_is_emp into l_dummy;
      if csr_is_emp%found then
        g_internal_person:='TRUE';
      end if;
      close csr_is_emp;
    end if;
  end if;
  RETURN g_internal_person;

END is_internal_person;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_email >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION is_internal_email (p_email_address varchar2
                           ,p_eff_date  date  )
  RETURN VARCHAR2
IS
cursor get_user is
select employee_id
from fnd_user
where upper(email_address)=upper(p_email_address);

l_employee_id number(15);

begin

  if (nvl(g_internal_email_address,'X')<>p_email_address) then
    g_internal_email_address:=p_email_address;
    g_internal_email:='FALSE';

    open get_user;
    fetch get_user into l_employee_id;
    if get_user%found then
      close get_user;
      if l_employee_id is not null then
        g_internal_email:=irc_utilities_pkg.is_internal_person(l_employee_id
                         ,p_eff_date);
      end if;
    else
      close get_user;
    end if;
  end if;
  RETURN g_internal_email;

end is_internal_email;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_internal_person >-------------------------|
-- ----------------------------------------------------------------------------

FUNCTION is_internal_person (p_user_name varchar2
                           ,p_eff_date  date  )
  RETURN VARCHAR2
IS
cursor get_user is
select employee_id
from fnd_user
where user_name=upper(p_user_name);

l_employee_id number(15);

begin
  if (nvl(g_internal_user_name,'X')<>p_user_name) then
    g_internal_user_name:=p_user_name;
    g_internal_user:='FALSE';

    open get_user;
    fetch get_user into l_employee_id;
    if get_user%found then
      close get_user;
      if l_employee_id is not null then
        g_internal_user:=irc_utilities_pkg.is_internal_person(l_employee_id
                         ,p_eff_date);
      end if;
    else
      close get_user;
    end if;
  end if;
  RETURN g_internal_user;

end is_internal_person;

-- ----------------------------------------------------------------------------
-- |-----------------------< is_function_allowed >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION is_function_allowed(p_function_name varchar2
                            ,p_test_maint_availability in varchar2 default 'Y')
  RETURN VARCHAR2
IS
  l_retval varchar2(5);
begin
  if(fnd_function.test(p_function_name,p_test_maint_availability)) then
    l_retval := 'TRUE';
  else
    l_retval := 'FALSE';
  end if;
  RETURN l_retval;
end is_function_allowed;

--
--Added GET_LAST_QUAL_PTY by deenath to fix Bug #4726469
-- ----------------------------------------------------------------------------
-- |---------------------< GET_LAST_QUAL_PTY  >-----------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_LAST_QUAL_PTY(p_party_id NUMBER,
                           p_eff_date DATE)
  RETURN VARCHAR2
IS
--
  CURSOR c_qualifications IS
  SELECT pqt.name
    FROM per_qualifications         pq
        ,per_qualification_types_vl pqt
   WHERE pq.party_id = p_party_id
     AND pq.attendance_id IS NOT NULL
     AND pq.awarded_date  IS NOT NULL
     AND pqt.qualification_type_id = pq.qualification_type_id
   ORDER BY pq.awarded_date DESC;
--
  l_qual_title per_qualification_types_vl.name%TYPE;
--
BEGIN
  OPEN c_qualifications;
  FETCH c_qualifications INTO l_qual_title;
  IF c_qualifications%NOTFOUND THEN
    l_qual_title := '';
  END IF;
  CLOSE c_qualifications;
  RETURN(l_qual_title);
END GET_LAST_QUAL_PTY;
--
-- -------------------------------------------------------------------
-- |--------------------< irc_applicant_tracking >-------------------|
-- -------------------------------------------------------------------
--
procedure irc_applicant_tracking(p_person_id              in         number
                                 ,p_apl_profile_access_id in         number
                                 ,p_object_version_number out nocopy number
                                  ) is
 pragma autonomous_transaction;
 l_object_version_number number;
 l_return_status         number;
 l_person_id number := p_person_id;
 l_apl_profile_access_id number := p_apl_profile_access_id;
--
 begin
--
 irc_apl_profile_access_api.create_apl_profile_access (
  P_VALIDATE                          =>    false
 ,P_PERSON_ID                         =>    l_person_id
 ,P_APL_PROFILE_ACCESS_ID             =>    l_apl_profile_access_id
 ,P_OBJECT_VERSION_NUMBER             =>    l_object_version_number
  );
  commit;
  exception
  when others then
  rollback;
end irc_applicant_tracking;
--
-- ----------------------------------------------------------------------------
-- |---------------------< irc_mark_appl_considered  >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure irc_mark_appl_considered( p_effective_date               in     date
                                   ,p_assignment_id                in     number
                                   ,p_attempt_id                   in     number
                                   ,p_assignment_details_id        in     number
                                   ,p_qualified                    in     varchar2
                                   ,p_considered                   in     varchar2
                                   ,p_update_mode                  in     varchar2
                                   ,p_details_version              out nocopy number
                                   ,p_effective_start_date         out nocopy date
                                   ,p_effective_end_date           out nocopy date
                                   ,p_object_version_number        out nocopy number
                                   )is
 pragma autonomous_transaction;
--
 l_effective_date            date  := p_effective_date;
 l_assignment_id             number := p_assignment_id;
 l_attempt_id                number := p_attempt_id;
 l_assignment_details_id     number ;
 l_qualified                 varchar2(30) := p_qualified;
 l_considered                varchar2(30) := p_considered;
 l_details_version           number;
 l_effective_start_date      date;
 l_effective_end_date        date;
 l_object_version_number     number;
 l_return_status             varchar2(30);
 l_update_mode               varchar2(30) := p_update_mode;
 l_assgn_details_row         irc_assignment_details_f%ROWTYPE;
 l_business_grp_id           per_all_assignments_f.business_group_id%TYPE;
 l_appln_tracking            varchar2(1);
--
  cursor c_assgn_details_row is
    select *
      from irc_assignment_details_f
     where assignment_id =p_assignment_id
       and sysdate between effective_start_date and effective_end_Date
       and latest_details='Y';
--
  cursor c_bg_id is
    select business_group_id
      from per_all_assignments_f
     where assignment_id = p_assignment_id
       and trunc(sysdate) between effective_start_date and effective_end_date;
--
  cursor c_appln_tracking is
    select nvl(ORG_INFORMATION11,'N')
      from HR_ORGANIZATION_INFORMATION
     where organization_id = l_business_grp_id
       and org_information_context = 'BG Recruitment';
--
 begin
 hr_utility.set_location('Entering irc_mark_appl_considered',10);
--
    open c_bg_id;
    fetch c_bg_id into l_business_grp_id;
    close c_bg_id;
    --
    open c_appln_tracking;
    fetch c_appln_tracking into l_appln_tracking;
    close c_appln_tracking;
    --
    if ( l_appln_tracking <> 'N') then
      open c_assgn_details_row;
      fetch c_assgn_details_row into l_assgn_details_row;
      --
      if(c_assgn_details_row%ROWCOUNT=0) then
        hr_utility.set_location('Assignment details record does not exist',20);
   irc_assignment_details_api.create_assignment_details (
       p_validate                =>     false
      ,P_EFFECTIVE_DATE          =>     l_effective_date
      ,p_assignment_id           =>     l_assignment_id
      ,p_attempt_id              =>     l_attempt_id
      ,P_QUALIFIED               =>     l_qualified
      ,P_CONSIDERED              =>     l_considered
      ,p_assignment_details_id   =>     l_assignment_details_id
      ,p_details_version         =>     l_details_version
      ,p_effective_start_date    =>     l_effective_start_date
      ,p_effective_end_date      =>     l_effective_end_date
      ,P_OBJECT_VERSION_NUMBER   =>     l_object_version_number
       );
        hr_utility.set_location('Created new assignment details row',30);
 else
        hr_utility.set_location('Assignment details record already exists',40);
        hr_utility.set_location('p_update_mode::'||p_update_mode,50);

        l_object_version_number := l_assgn_details_row.object_version_number;
        l_assignment_details_id := l_assgn_details_row.assignment_details_id;

   irc_assignment_details_api.update_assignment_details (
      p_validate                      =>     false
     ,p_effective_date               =>     l_effective_date
     ,p_datetrack_update_mode        =>     l_update_mode
     ,p_assignment_id                =>     l_assignment_id
     ,p_attempt_id                   =>     l_attempt_id
     ,p_qualified                    =>     l_qualified
     ,p_considered                   =>     l_considered
     ,p_assignment_details_id        =>     l_assignment_details_id
     ,p_object_version_number        =>     l_object_version_number
     ,p_details_version              =>     l_details_version
     ,p_effective_start_date         =>     l_effective_start_date
     ,p_effective_end_date           =>     l_effective_end_date
    );
       hr_utility.set_location('Updated assignment details record',60);
 end if;
     close c_assgn_details_row;
 commit;
   end if;
   hr_utility.set_location('Leaving irc_mark_appl_considered',10);
 exception
  when others then
    hr_utility.set_location('Exception in irc_mark_appl_considered::' || SQLERRM,100);
  rollback;
    hr_utility.set_location('Leaving irc_mark_appl_considered',10);
    raise;
end irc_mark_appl_considered;
--
-- ----------------------------------------------------------------------------
-- |---------------------< irc_mark_appl_considered  >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure irc_mark_appl_considered(p_assignment_id                in     number)is
 pragma autonomous_transaction;
--
 l_effective_date            date  := trunc(sysdate);
 l_assignment_id             number := p_assignment_id;
 l_attempt_id                number ;
 l_assignment_details_id     number ;
 l_qualified                 varchar2(30) ;
 l_considered                varchar2(30) := 'Y';
 l_details_version           number;
 l_effective_start_date      date;
 l_effective_end_date        date;
 l_object_version_number     number;
 l_row                       number;
 l_return_status             varchar2(30);
 l_update_mode               varchar2(30);
 l_assgn_details_row         irc_assignment_details_f%ROWTYPE;
 l_appl_tracking             varchar2(1);
 l_business_grp_id           per_all_assignments_f.business_group_id%TYPE;

 cursor c_bg_id is select business_group_id from per_all_assignments_f where assignment_id=p_assignment_id and trunc(sysdate) between effective_start_date and effective_end_date;
 cursor c_assgn_details_row is select * from irc_assignment_details_f where assignment_id =p_assignment_id and latest_details='Y';
 cursor c_assgn_details is select 1 from irc_assignment_details_f where assignment_id =p_assignment_id and sysdate between effective_start_date and effective_end_Date and latest_details='Y';
 cursor c_appln_tracking is select nvl(ORG_INFORMATION11,'N') from HR_ORGANIZATION_INFORMATION where organization_id=l_business_grp_id and org_information_context='BG Recruitment';

 begin

 open c_bg_id;
 fetch c_bg_id into l_business_grp_id;
 close c_bg_id;

 open c_appln_tracking;
 fetch c_appln_tracking into l_appl_tracking;
 close c_appln_tracking;

 open c_assgn_details_row;
 fetch c_assgn_details_row into l_assgn_details_row;
 close c_assgn_details_row;

 if (l_appl_tracking<>'N') then

 open c_assgn_details;
  fetch c_assgn_details into l_row;
 if(c_assgn_details%NOTFOUND) then

   irc_assignment_details_api.create_assignment_details (
       p_validate                =>     false
      ,P_EFFECTIVE_DATE          =>     l_effective_date
      ,p_assignment_id           =>     l_assignment_id
      ,p_attempt_id              =>     l_attempt_id
      ,P_QUALIFIED               =>     l_qualified
      ,P_CONSIDERED              =>     l_considered
      ,p_assignment_details_id   =>     l_assignment_details_id
      ,p_details_version         =>     l_details_version
      ,p_effective_start_date    =>     l_effective_start_date
      ,p_effective_end_date      =>     l_effective_end_date
      ,P_OBJECT_VERSION_NUMBER   =>     l_object_version_number
       );
 else

 if(trunc(sysdate)>l_assgn_details_row.effective_start_date) then
   l_update_mode:='UPDATE';
 else
   l_update_mode:='CORRECTION';
 end if;

 l_assignment_details_id:=l_assgn_details_row.assignment_details_id;
 l_object_version_number:=l_assgn_details_row.object_version_number;
   irc_assignment_details_api.update_assignment_details (
      p_validate                      =>     false
     ,p_effective_date               =>     l_effective_date
     ,p_datetrack_update_mode        =>     l_update_mode
     ,p_assignment_id                =>     l_assignment_id
     ,p_attempt_id                   =>     l_assgn_details_row.attempt_id
     ,p_qualified                    =>     l_assgn_details_row.qualified
     ,p_considered                   =>     l_considered
     ,p_assignment_details_id        =>     l_assignment_details_id
     ,p_object_version_number        =>     l_object_version_number
     ,p_details_version              =>     l_details_version
     ,p_effective_start_date         =>     l_effective_start_date
     ,p_effective_end_date           =>     l_effective_end_date
    );
 end if;
 close c_assgn_details;
commit;
 end if;
 exception
  when others then
   rollback;
end irc_mark_appl_considered;

function getAMETxnDetailsForOffer (p_offerId in varchar2)
return varchar2
is
cursor c_AMETxnDetails(c_offerId in varchar2) is
SELECT history.transaction_history_id
      ,irc_xml_util.valueOf(histstate.transaction_document,'/Transaction/TransCtx/pAMETranType')
      ,irc_xml_util.valueOf(histstate.transaction_document,'/Transaction/TransCtx/pAMEAppId')
FROM   pqh_ss_transaction_history history,
       pqh_ss_trans_state_history histstate
WHERE history.transaction_identifier = 'OFFER'
  AND history.transaction_history_id = ( SELECT min(transaction_history_id)
                                           FROM pqh_ss_step_history
                                          WHERE api_name = 'IRC_OFFERS_SWI.PROCESS_OFFERS_API'
                                            AND pk1 = c_offerId )
  AND histstate.transaction_history_id = history.transaction_history_id;
txnId number := null;
txnType varchar2(100) := null;
applId number :=null;
begin
  open c_AMETxnDetails(p_offerId);
  fetch c_AMETxnDetails into txnId, txnType, applId;
  if c_AMETxnDetails%FOUND then
    return txnId || ':' || txnType ||':' ||applId;
  end if;
  close c_AMETxnDetails;
  return '';
end;

--
-- ----------------------------------------------------------------------------
-- |---------------------< copy_candidate_address >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_candidate_address
  (p_assignment_id            in     number) is
--
  l_business_group_id number;
  l_person_id_appl number;
  l_person_id number;
  l_application_date per_addresses.date_from%TYPE;
  p_addr per_addresses%ROWTYPE;
  l_addr_id number;
  l_party_id number;
  l_object_version_number number;
  l_return_status varchar2(30);
  l_proc varchar2(72) := 'irc_utilities_pkg.copy_candidate_address';
  l_addr_found boolean := false;
--
  Cursor C_Assignment_details is
    select person_id
       , business_group_id
       , effective_start_date
    from  per_all_assignments_f
    where assignment_id=p_assignment_id
    and sysdate between effective_start_date and effective_end_date;
--
  Cursor C_Address_id is
     select address_id
     from per_addresses
     where person_id=l_person_id_appl;
--
  Cursor C_Person_id is
     select min(person_id)
     from per_all_people_f
     where party_id in (select party_id
		        from per_all_people_f
			where person_id=l_person_id_appl);
--
  Cursor C_Address_details_Rec is
      select *
      from per_addresses
      where person_id=l_person_id
        and address_type='REC'
        and sysdate between date_from and nvl(date_to,sysdate);
--
  Cursor C_Address_details_Primary is
      select *
      from per_addresses
      where person_id=l_person_id
        and primary_flag = 'Y'
        and sysdate between date_from and nvl(date_to,sysdate);
--
  begin
--
        hr_utility.set_location('Enteringp_addr: '||l_proc, 5);
--
        open C_Assignment_details;
        fetch C_Assignment_details into l_person_id_appl,l_business_group_id,l_application_date;
        close C_Assignment_details;
--
        open C_Address_id;
        fetch C_Address_id into l_addr_id;
        if C_Address_id%notfound then
--
          hr_utility.set_location('C_Address_id not found: '||l_proc, 6);
          open C_Person_id;
          fetch C_Person_id into l_person_id;
          close C_Person_id;
--
--   Modified the logic to get the recuritment address of the applicant.
--   If the recuritment address is not found getting the primary address of the applicant
--   If one of the above is found creating the address with applicant person id
--
          open C_Address_details_Rec;
          fetch C_Address_details_Rec into p_addr;
--
          if C_Address_details_Rec%notfound then
            hr_utility.set_location('C_Address_details_Rec not found: '||l_proc, 7);
            open C_Address_details_Primary;
            fetch C_Address_details_Primary into p_addr;
--
            if C_Address_details_Primary%found then
              hr_utility.set_location('C_Address_details_Primary found: '||l_proc, 8);
              l_addr_found := true;
            end if;
--
            close C_Address_details_Primary;
          else
            hr_utility.set_location('C_Address_details_Rec found: '||l_proc, 9);
            l_addr_found := true;
          end if;
--
          if l_addr_found then
            hr_utility.set_location('Creating the address: '||l_proc, 10);
--
            p_addr.person_id:=l_person_id_appl;
            p_addr.primary_flag:='Y';
            p_addr.address_id:=null;
            p_addr.object_version_number:=null;
            p_addr.date_from:=l_application_date;
            p_addr.business_group_id:=l_business_group_id;
--
            hr_person_address_swi.create_person_address (
                       P_EFFECTIVE_DATE                    => p_addr.date_from
                      ,P_PERSON_ID                         => p_addr.person_id
                      ,P_PRIMARY_FLAG                      => p_addr.primary_flag
                      ,P_STYLE                             => p_addr.style
                      ,P_DATE_FROM                         => p_addr.date_from
                      ,P_DATE_TO                           => p_addr.date_to
                      ,P_ADDRESS_TYPE                      => p_addr.address_type
                      ,P_COMMENTS                          => p_addr.comments
                      ,P_ADDRESS_LINE1                     => p_addr.address_line1
                      ,P_ADDRESS_LINE2                     => p_addr.address_line2
                      ,P_ADDRESS_LINE3                     => p_addr.address_line3
                      ,P_TOWN_OR_CITY                      => p_addr.town_or_city
                      ,P_REGION_1                          => p_addr.region_1
                      ,P_REGION_2                          => p_addr.region_2
                      ,P_REGION_3                          => p_addr.region_3
                      ,P_POSTAL_CODE                       => p_addr.postal_code
                      ,P_COUNTRY                           => p_addr.country
                      ,P_TELEPHONE_NUMBER_1                => p_addr.telephone_number_1
                      ,P_TELEPHONE_NUMBER_2                => p_addr.telephone_number_2
                      ,P_TELEPHONE_NUMBER_3                => p_addr.telephone_number_3
                      ,P_ADDR_ATTRIBUTE_CATEGORY           => p_addr.addr_attribute_category
                      ,P_ADDR_ATTRIBUTE1                   => p_addr.addr_attribute1
                      ,P_ADDR_ATTRIBUTE2                   => p_addr.addr_attribute2
                      ,P_ADDR_ATTRIBUTE3                   => p_addr.addr_attribute3
                      ,P_ADDR_ATTRIBUTE4                   => p_addr.addr_attribute4
                      ,P_ADDR_ATTRIBUTE5                   => p_addr.addr_attribute5
                      ,P_ADDR_ATTRIBUTE6                   => p_addr.addr_attribute6
                      ,P_ADDR_ATTRIBUTE7                   => p_addr.addr_attribute7
                      ,P_ADDR_ATTRIBUTE8                   => p_addr.addr_attribute8
                      ,P_ADDR_ATTRIBUTE9                   => p_addr.addr_attribute9
                      ,P_ADDR_ATTRIBUTE10                  => p_addr.addr_attribute10
                      ,P_ADDR_ATTRIBUTE11                  => p_addr.addr_attribute11
                      ,P_ADDR_ATTRIBUTE12                  => p_addr.addr_attribute12
                      ,P_ADDR_ATTRIBUTE13                  => p_addr.addr_attribute13
                      ,P_ADDR_ATTRIBUTE14                  => p_addr.addr_attribute14
                      ,P_ADDR_ATTRIBUTE15                  => p_addr.addr_attribute15
                      ,P_ADDR_ATTRIBUTE16                  => p_addr.addr_attribute16
                      ,P_ADDR_ATTRIBUTE17                  => p_addr.addr_attribute17
                      ,P_ADDR_ATTRIBUTE18                  => p_addr.addr_attribute18
                      ,P_ADDR_ATTRIBUTE19                  => p_addr.addr_attribute19
                      ,P_ADDR_ATTRIBUTE20                  => p_addr.addr_attribute20
                      ,P_ADD_INFORMATION13                 => p_addr.add_information13
                      ,P_ADD_INFORMATION14                 => p_addr.add_information14
                      ,P_ADD_INFORMATION15                 => p_addr.add_information15
                      ,P_ADD_INFORMATION16                 => p_addr.add_information16
                      ,P_ADD_INFORMATION17                 => p_addr.add_information17
                      ,P_ADD_INFORMATION18                 => p_addr.add_information18
                      ,P_ADD_INFORMATION19                 => p_addr.add_information19
                      ,P_ADD_INFORMATION20                 => p_addr.add_information20
                      ,P_PARTY_ID                          => p_addr.party_id
                      ,P_ADDRESS_ID                        => p_addr.address_id
                      ,P_OBJECT_VERSION_NUMBER             => l_object_version_number
                      ,P_RETURN_STATUS                     => l_return_status
                       );
            hr_utility.set_location('After Creating the address: '||l_proc, 11);
          end if;
--
          close C_Address_details_Rec;
        end if;
--
	close C_Address_id;
        hr_utility.set_location(' Leaving: ' || l_proc, 50);
--
 exception
  when others then
   hr_utility.set_location(' Exception occured: ' || l_proc, 50);
   raise;
end copy_candidate_address;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< copy_candidate_details  >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_candidate_details
  (p_assignment_id            in     number) is
  l_proc varchar2(72) := 'irc_utilities_pkg.copy_candidate_address';
  begin
	  hr_utility.set_location('Entering: '||l_proc, 5);
    copy_candidate_address(p_assignment_id);
    hr_utility.set_location('Leaving: '||l_proc, 5);
  exception
  when others then
    raise;
end copy_candidate_details;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  get_fte_factor  >---------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_fte_factor(p_assignment_id      NUMBER ,
                        p_asg_hours_per_year NUMBER ,
                        p_position_id        NUMBER ,
                        p_organization_id    NUMBER ,
                        p_business_group_id  NUMBER ,
                        p_effective_date IN DATE)
        RETURN NUMBER
IS
          CURSOR csr_pos_fte IS
                  SELECT pos.working_hours ,
                         DECODE(pos.frequency ,'Y',1 ,'M',12 ,'W',52 ,'D',365 ,1)
                  FROM   hr_all_positions pos
                  WHERE  pos.position_id=p_position_id;
           CURSOR csr_org_fte IS
                   SELECT fnd_number.canonical_to_number(org.org_information3) normal_hours ,
                          DECODE(org.org_information4 ,'Y',1 ,'M',12 ,'W',52 ,'D',365 ,1)
                   FROM   HR_ORGANIZATION_INFORMATION org
                   WHERE  org.organization_id            =p_organization_id
                      AND org.organization_id            = p_organization_id
                      AND org.org_information_context(+) = 'Work Day Information';
            CURSOR csr_bus_fte IS
                    SELECT fnd_number.canonical_to_number(bus.working_hours) normal_hours ,
                           DECODE(bus.frequency ,'Y',1 ,'M',12 ,'W',52 ,'D',365 ,1)
                    FROM   per_business_groups bus
                    WHERE  bus.business_group_id = p_business_group_id;
             l_fte_factor          NUMBER := NULL;
             l_norm_hours_per_year NUMBER;
             l_hours_per_year      NUMBER;
             l_norm_hours          NUMBER;
             l_norm_frequency      NUMBER;
     BEGIN
             --
                     IF(NVL(p_asg_hours_per_year,0) <> 0) THEN
                             IF(p_position_id IS NOT NULL) THEN
                             	open csr_pos_fte;
                             	fetch csr_pos_fte into l_norm_hours,l_norm_frequency;
                             	close csr_pos_fte;
                             END IF;
                             IF (l_norm_hours IS NULL OR l_norm_frequency IS NULL)THEN
                                     open csr_org_fte;
                                     fetch csr_org_fte into l_norm_hours,l_norm_frequency;
                             	  	 close csr_org_fte;
                             END IF;
                             IF (l_norm_hours IS NULL OR l_norm_frequency IS NULL)THEN
                                     open csr_bus_fte;
                                     fetch csr_bus_fte into l_norm_hours,l_norm_frequency;
                             	  	 close csr_bus_fte;
                             END IF;
                             l_norm_hours_per_year            := NVL(l_norm_hours,0)*l_norm_frequency;
                             IF ( NVL(l_norm_hours_per_year,0) = 0) THEN
                                     l_fte_factor             := 1;
                             ELSE
                                     l_fte_factor := l_norm_hours_per_year/p_asg_hours_per_year;
                             END IF;
                     ELSE
                             l_fte_factor := 1;
                     END IF;
             IF (l_fte_factor IS NULL) THEN
                     l_fte_factor := 1;
             END IF;
             --
             RETURN l_fte_factor;
     END get_fte_factor;


--
-- ----------------------------------------------------------------------------
-- |---------------------< split_to_token >---------------------------------|
-- ----------------------------------------------------------------------------
--
function split_to_token(list  varchar2, indexnum number)  return    varchar2
is
   pos_start number;
   pos_end   number;
   delimiter varchar(2) := ',';
begin
   if indexnum = 1 then
       pos_start := 1;
   else
       pos_start := instr(list, delimiter, 1, indexnum - 1);
       if pos_start = 0 then
           return null;
       else
           pos_start := pos_start + length(delimiter);
       end if;
   end if;

   pos_end := instr(list, delimiter, pos_start, 1);

   if pos_end = 0 then
       return substr(list, pos_start);
   else
       return substr(list, pos_start, pos_end - pos_start);
   end if;

end split_to_token;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< getRunFunctionUrl >---------------------------------|
-- ----------------------------------------------------------------------------
--
function getVacancyRunFunctionUrl(
                                  p_function_id number,
                                  p_vacancy_id number,
                                  p_posting_id number,
                                  p_site_id number
                                 ) return varchar2 is
url varchar2(32767);
encyrpt boolean;
l_function_id number;
params varchar2(32767);
begin
encyrpt := true;
l_function_id := p_function_id ;
params:='p_svid='||p_vacancy_id||'&'||'p_spid='||p_posting_id||'&'||'p_site_id='||p_site_id;

 url := fnd_run_function.get_run_function_url ( p_function_id =>l_function_id,
                                             p_resp_appl_id => fnd_global.resp_appl_id,
                                             p_resp_id =>fnd_global.resp_id,
                                             p_security_group_id =>fnd_global.security_group_id,
                                             p_parameters =>params,
                                             p_override_agent=>'/OA_HTML',
                                             p_encryptParameters =>encyrpt );
 return url;
end;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< getJobSearchItems >---------------------------------|
-- ----------------------------------------------------------------------------
--

function getJobSearchItems(l_keyword varchar2 default null,
l_job varchar2 default null,
l_employee varchar2 default null,
l_contractor varchar2 default null,
l_dateposted varchar2 default null,
l_travelpercent number default null,
l_workathome varchar2 default null,
l_employmentstatus varchar2 default null,
l_min_salary  in varchar2 default null,
l_currency in varchar2 default null,
l_lat in varchar2 default null,
l_long in varchar2 default null,
l_dist in varchar2 default null,
l_location in varchar2 default null,
l_attribute_category in varchar2 default null,
l_attribute1 in varchar2 default null,
l_attribute2 in varchar2 default null,
l_attribute3 in varchar2 default null,
l_attribute4 in varchar2 default null,
l_attribute5 in varchar2 default null,
l_attribute6 in varchar2 default null,
l_attribute7 in varchar2 default null,
l_attribute8 in varchar2 default null,
l_attribute9 in varchar2 default null,
l_attribute10 in varchar2 default null,
l_attribute11 in varchar2 default null,
l_attribute12 in varchar2 default null,
l_attribute13 in varchar2 default null,
l_attribute14 in varchar2 default null,
l_attribute15 in varchar2 default null,
l_attribute16 in varchar2 default null,
l_attribute17 in varchar2 default null,
l_attribute18 in varchar2 default null,
l_attribute19 in varchar2 default null,
l_attribute20 in varchar2 default null,
l_attribute21 in varchar2 default null,
l_attribute22 in varchar2 default null,
l_attribute23 in varchar2 default null,
l_attribute24 in varchar2 default null,
l_attribute25 in varchar2 default null,
l_attribute26 in varchar2 default null,
l_attribute27 in varchar2 default null,
l_attribute28 in varchar2 default null,
l_attribute29 in varchar2 default null,
l_attribute30 in varchar2 default null,
langcode in varchar2 default null,
enterprise in varchar2 default null,
l_drvdlocal in varchar2 default null,
l_locid in varchar2 default null)  return clob is

query varchar2(32000);
ctx DBMS_XMLQUERY.ctxType;
xml clob;
bindNum number:=1;
type bindlist is table of varchar2(4000) index by binary_integer;
bindvalues bindlist;
token varchar2(100);
firstToken boolean := true;
i number;
test varchar2(32000);
l_funcId number;

 cursor c_func(p_function_name varchar2) is
          select function_id from fnd_form_functions
                  where function_name = p_function_name;
begin
 if enterprise is not null then
    hr_multi_tenancy_pkg.set_context_for_enterprise(enterprise);
 end if;

 open c_func('IRC_VIS_VAC_DISPLAY');
 fetch c_func into l_funcId;
 close c_func;

 if l_keyword is not null or l_job is not null or l_dateposted is not null or l_drvdlocal is not null then

query:='SELECT PAV.NAME  title                            ,
       fnd_message.get_string(''PER'',''IRC_412594_RSS_JOB_TITLE'')||'' ''||IPC.JOB_TITLE ||'' <br>''|| fnd_message.get_string(''PER'',''IRC_412595_RSS_ORGANIZATION'')||'' ''||IPC.ORG_NAME||
       '' <br>''|| fnd_message.get_string(''PER'',''IRC_412596_RSS_DESCRIPTION'')||'' ''||IPC.BRIEF_DESCRIPTION description ,
       to_char( trunc(pra.date_start),''Dy, DD Mon YYYY'') pubDate,
       irc_utilities_pkg.getVacancyRunFunctionUrl('|| l_funcId||',
                                                    pav.vacancy_id,
                                                    pav.primary_posting_id,
                                                    1) rlink
 FROM HR_LOOKUPS HRL,
       HR_LOOKUPS HL2,
       PER_ALL_VACANCIES PAV,
       PER_RECRUITMENT_ACTIVITIES PRA,
       PER_RECRUITMENT_ACTIVITY_FOR PRF,
       IRC_POSTING_CONTENTS_VL IPC,
       IRC_SEARCH_CRITERIA IVS,
       HR_LOCATIONS_ALL LOC,
       HR_LOOKUPS HLW,
       HR_LOOKUPS HLT,
       IRC_ALL_RECRUITING_SITES ias WHERE pav.status = ''APPROVED''
       AND PAV.VACANCY_ID = PRF.VACANCY_ID
       AND PRF.RECRUITMENT_ACTIVITY_ID = PRA.RECRUITMENT_ACTIVITY_ID
       AND PRA.POSTING_CONTENT_ID = IPC.POSTING_CONTENT_ID
       AND PAV.VACANCY_ID = IVS.OBJECT_ID
       AND IVS.OBJECT_TYPE = ''VACANCY''
       AND HRL.LOOKUP_TYPE(+) = ''IRC_PROFESSIONAL_AREA''
       AND IVS.PROFESSIONAL_AREA = HRL.LOOKUP_CODE(+)
       AND HL2.LOOKUP_TYPE(+) = ''IRC_EMP_CAT''
       AND IVS.EMPLOYMENT_CATEGORY = HL2.LOOKUP_CODE(+)
       AND HLW.LOOKUP_TYPE(+) = ''IRC_WORK_AT_HOME''
       AND IVS.WORK_AT_HOME = HLW.LOOKUP_CODE(+)
       AND HLT.LOOKUP_TYPE(+) = ''IRC_TRAVEL_PERCENTAGE''
       AND IVS.TRAVEL_PERCENTAGE = HLT.LOOKUP_CODE(+)
       AND sysdate BETWEEN PRA.date_start AND NVL(PRA.date_end,sysdate)
       AND loc.location_id(+)=pav.location_id
       AND ias.EXTERNAL = ''Y''
       AND
       (
               pav.date_from <= sysdate
               AND
               (
                       (
                               pav.date_to IS NOT NULL
                               AND pav.date_to > = sysdate
                       )
                       OR
                       (
                               pav.date_to IS NULL
                       )
               )
       )
       AND EXISTS
       (SELECT 1
       FROM    per_vacancies vac1
       WHERE   vac1.vacancy_id      =pav.vacancy_id
       )
       AND pra.recruiting_site_id = ias.recruiting_site_id
       AND sysdate BETWEEN pra.date_start AND NVL (pra.date_end, sysdate)';

--adding where clause for keyword search
if l_keyword is not null then
   query:=query|| ' AND contains(ipc.name,:' ||bindnum || ',1) > 0';
   bindvalues(bindnum):=l_keyword;
   bindnum:=bindnum+1;
end if;

--adding where clause for Professional area
if l_job is not null then

      query:=query|| ' AND HRL.LOOKUP_CODE  in  (' ;
      i := 1;
      loop
        token := split_to_token(l_job,i);
        exit when token is null;
        if not firstToken then
          query:=query|| ',';
        end if;
        firstToken := false;
        query:=query|| ':' || bindnum;
      	bindvalues(bindnum) := token;
        bindnum:=bindnum+1;
        i := i+1;
      end loop;
      query:=query|| ')';

end if;

--adding where clause for contractor and employee checkbox
if l_contractor is not null and l_employee  is not null then

	if l_contractor ='Y' and l_employee ='Y'  then
		query:=query|| ' and (ivs.contractor = ''Y'' or ivs.employee = ''Y'')';

	elsif l_contractor ='Y' and l_employee ='N' then
		query:=query|| ' and (ivs.contractor = ''Y'')';

  elsif l_contractor ='N' and l_employee ='Y' then
    query:=query|| ' and (ivs.employee = ''Y'')';

  elsif l_contractor ='N' and l_employee ='N' then
    query:=query|| ' and (ivs.contractor = ''N'' and ivs.employee = ''N'')';

  end if;

end if;

--adding whereclause for travel percentage
if l_travelpercent is not null then
  query:=query||' AND (HLT.LOOKUP_CODE = :'||bindnum ||' OR IVS.TRAVEL_PERCENTAGE IS NULL)';
	bindvalues(bindnum):=l_travelpercent;
  bindnum:=bindnum+1;
end if;

--adding where clause for date posted
if l_dateposted  is not null then
      query:=query|| ' AND ((trunc(sysdate) - pra.date_start ) <= to_number(:'|| bindnum|| ') )';
	bindvalues(bindnum):=l_dateposted ;
    bindnum:=bindnum+1;
end if;

--adding where clause for employment status
if l_employmentstatus  is not null then
  if l_employmentstatus ='FULLTIME' then
     query:=query||' and (HL2.LOOKUP_CODE IN (''FULLTIME'',''EITHER'') OR IVS.EMPLOYMENT_CATEGORY IS NULL)';
  elsif l_employmentstatus ='PARTTIME' then
     query:=query||' and (HL2.LOOKUP_CODE IN (''PARTTIME'',''EITHER'') OR IVS.EMPLOYMENT_CATEGORY IS NULL)';
  elsif l_employmentstatus ='EITHER' then
     query:=query||' and (HL2.LOOKUP_CODE IN (''FULLTIME'',''PARTTIME'',''EITHER'') OR IVS.EMPLOYMENT_CATEGORY IS NULL)';
  end if;
end if;

--adding where clause for work at home
if l_workathome  is not null and l_workathome <>'' then
     query:=query||' and (HLW.LOOKUP_CODE = :'||bindNum||' OR IVS.WORK_AT_HOME IS NULL)';
     bindvalues(bindnum):=l_workathome ;
     bindnum:=bindnum+1;
end if;

--adding where clause for minimum salary and currency
if l_min_salary is not null and l_currency is not null then
	query:=query|| ' AND ( (IVS.salary_currency = :'||bindnum;
	bindvalues(bindnum):=l_currency;
    bindnum:=bindnum+1;

	query:=query|| ' AND IVS.max_salary >= to_number(:' || bindnum|| '))';
	bindvalues(bindnum):=l_min_salary;
	bindnum:=bindnum+1;

	query:=query|| ' OR (IVS.salary_currency<>:'||bindnum || ' AND';
	bindvalues(bindnum):=l_currency;
	bindnum:=bindnum+1;

	query:=query|| ' to_number(:'||bindnum || ') <= irc_seeker_vac_matching_pkg.convert_vacancy_amount';
	bindvalues(bindnum):=l_min_salary;
	bindnum:=bindnum+1;

	query:=query|| ' (IVS.salary_currency,:'||bindnum ||',IVS.max_salary,sysdate';
    bindvalues(bindnum):=l_currency;
	bindnum:=bindnum+1;

	query:=query|| ' ,PAV.BUSINESS_GROUP_ID,''P'' )))';

end if;

if l_locid is null and l_drvdlocal is null then
--adding where clause for location based search
if l_location is not null and l_lat is not null and l_long is not null and l_dist is not null then

test:=' and catsearch(loc.derived_locale,'''||l_location||''',null)>0';
query:=query||' and loc.derived_locale is not null';
query:=query||' and locator_within_distance(loc.geometry,mdsys.sdo_geometry(2001,8307,mdsys.sdo_point_type(' ||l_long|| ',';
query:=query||l_lat||',null),null,null),';

query:=query||'''distance='||l_dist||',units=mile'''||')=''TRUE''';
query:=query||' and loc.geometry is not null';

elsif ((l_location is null or l_lat is null or l_long is null) and l_dist is not null)
   or ((l_location is not null and (l_lat is null or l_long is null)) and l_dist is not null)
   or ((l_location is null and (l_lat is not null or l_long is not null)) and l_dist is not null) then
query:='SELECT fnd_message.get_string(''PER'',''IRC_412597_RSS_CRITERIA_ERROR'')  title                            ,
       fnd_message.get_string(''PER'',''IRC_412011_BAD_LOCATION'') description ,
       to_char(trunc(sysdate),''Dy, DD Mon YYYY'') pubDate,
       ''/OA_HTML/IrcVisitor.jsp''  rlink from dual';
       ctx:= dbms_xmlquery.newContext(query);
       dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
       dbms_xmlquery.setEncodingTag(ctx,'UTF8');
       xml:=dbms_xmlquery.getXML(ctx);
       return (xml);

elsif (l_location is not null and l_lat is not null and l_long is not null and l_dist is null) then
query:='SELECT fnd_message.get_string(''PER'',''IRC_412597_RSS_CRITERIA_ERROR'')  title                            ,
        fnd_message.get_string(''PER'',''IRC_412164_NO_DISTANCE'') description ,
       to_char(trunc(sysdate),''Dy, DD Mon YYYY'') pubDate,
       ''/OA_HTML/IrcVisitor.jsp''  rlink from dual';
       ctx:= dbms_xmlquery.newContext(query);
       dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
       dbms_xmlquery.setEncodingTag(ctx,'UTF8');
       xml:=dbms_xmlquery.getXML(ctx);
       return (xml);

end if;
elsif l_locid is not null and l_drvdlocal is null then
	 query:=query|| ' and loc.location_id=:'||bindnum;
	 bindvalues(bindnum):=to_number(l_locid);
   bindnum:=bindnum+1;
elsif l_locid is null and l_drvdlocal is not null then
	 query:=query|| ' and catsearch(loc.derived_locale,:'||bindnum||',null) > 0';
   query:=query|| ' and loc.derived_locale is not null';
	 bindvalues(bindnum):=l_drvdlocal;
   bindnum:=bindnum+1;
end if;
--flex
if l_attribute_category is not null then
      query := query || ' AND IVS.ATTRIBUTE_CATEGORY = :' ||bindnum ;
      bindvalues(bindnum):=l_attribute_category;
      bindnum:=bindnum+1;

    end if;
if l_attribute1 is not null then query := query || ' AND lower(IVS.attribute1) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute1;      bindnum:=bindnum+1;  end if;
 if l_attribute2 is not null then query := query || ' AND  lower(IVS.attribute2) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute2;      bindnum:=bindnum+1;  end if;
 if l_attribute3 is not null then query := query || ' AND  lower(IVS.attribute3) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute3;      bindnum:=bindnum+1;  end if;
 if l_attribute4 is not null then query := query || ' AND  lower(IVS.attribute4) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute4;      bindnum:=bindnum+1;  end if;
 if l_attribute5 is not null then query := query || ' AND  lower(IVS.attribute5) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute5;      bindnum:=bindnum+1;  end if;
 if l_attribute6 is not null then query := query || ' AND  lower(IVS.attribute6) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute6;      bindnum:=bindnum+1;  end if;
 if l_attribute7 is not null then query := query || ' AND  lower(IVS.attribute7) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute7;      bindnum:=bindnum+1;  end if;
 if l_attribute8 is not null then query := query || ' AND  lower(IVS.attribute8) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute8;      bindnum:=bindnum+1;  end if;
 if l_attribute9 is not null then query := query || ' AND  lower(IVS.attribute9) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute9;      bindnum:=bindnum+1;  end if;
 if l_attribute10 is not null then query := query || ' AND lower(IVS.attribute10) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute10;      bindnum:=bindnum+1;  end if;
 if l_attribute11 is not null then query := query || ' AND lower(IVS.attribute11) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute11;      bindnum:=bindnum+1;  end if;
 if l_attribute12 is not null then query := query || ' AND lower(IVS.attribute12) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute12;      bindnum:=bindnum+1;  end if;
 if l_attribute13 is not null then query := query || ' AND lower(IVS.attribute13) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute13;      bindnum:=bindnum+1;  end if;
 if l_attribute14 is not null then query := query || ' AND lower(IVS.attribute14) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute14;      bindnum:=bindnum+1;  end if;
 if l_attribute15 is not null then query := query || ' AND lower(IVS.attribute15) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute15;      bindnum:=bindnum+1;  end if;
 if l_attribute16 is not null then query := query || ' AND lower(IVS.attribute16) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute16;      bindnum:=bindnum+1;  end if;
 if l_attribute17 is not null then query := query || ' AND lower(IVS.attribute17) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute17;      bindnum:=bindnum+1;  end if;
 if l_attribute18 is not null then query := query || ' AND lower(IVS.attribute18) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute18;      bindnum:=bindnum+1;  end if;
 if l_attribute19 is not null then query := query || ' AND lower(IVS.attribute19) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute19;      bindnum:=bindnum+1;  end if;
 if l_attribute20 is not null then query := query || ' AND lower(IVS.attribute20) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute20;      bindnum:=bindnum+1;  end if;
 if l_attribute21 is not null then query := query || ' AND lower(IVS.attribute21) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute21;      bindnum:=bindnum+1;  end if;
 if l_attribute22 is not null then query := query || ' AND lower(IVS.attribute22) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute22;      bindnum:=bindnum+1;  end if;
 if l_attribute23 is not null then query := query || ' AND lower(IVS.attribute23) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute23;      bindnum:=bindnum+1;  end if;
 if l_attribute24 is not null then query := query || ' AND lower(IVS.attribute24) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute24;      bindnum:=bindnum+1;  end if;
 if l_attribute25 is not null then query := query || ' AND lower(IVS.attribute25) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute25;      bindnum:=bindnum+1;  end if;
 if l_attribute26 is not null then query := query || ' AND lower(IVS.attribute26) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute26;      bindnum:=bindnum+1;  end if;
 if l_attribute27 is not null then query := query || ' AND lower(IVS.attribute27) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute27;      bindnum:=bindnum+1;  end if;
 if l_attribute28 is not null then query := query || ' AND lower(IVS.attribute28) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute28;      bindnum:=bindnum+1;  end if;
 if l_attribute29 is not null then query := query || ' AND lower(IVS.attribute29) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute29;      bindnum:=bindnum+1;  end if;
 if l_attribute30 is not null then query := query || ' AND lower(IVS.attribute30) like  lower(:' ||bindnum||')' ;  bindvalues(bindnum):=l_attribute30;      bindnum:=bindnum+1;  end if;


--flex end
query:=query|| ' ORDER BY pra.date_start DESC';

else
query:='SELECT fnd_message.get_string(''PER'',''IRC_412597_RSS_CRITERIA_ERROR'')  title                            ,
        fnd_message.get_string(''PER'',''PER_34296_DIAG_NO_BLANKL_QUERY'') description ,
       to_char(trunc(sysdate),''Dy, DD Mon YYYY'') pubDate,
       ''/OA_HTML/IrcVisitor.jsp''  rlink from dual';
       ctx:= dbms_xmlquery.newContext(query);
       dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
       dbms_xmlquery.setEncodingTag(ctx,'UTF8');
       xml:=dbms_xmlquery.getXML(ctx);
       return (xml);
end if;

if bindnum=1 then

   return (xml);

end if;

ctx:= dbms_xmlquery.newContext(query);
dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
dbms_xmlquery.setEncodingTag(ctx,'UTF8');

for i in 1 .. bindvalues.count loop
  dbms_xmlquery.setBindValue(ctx,i,bindvalues(i));
end loop;

  xml:=dbms_xmlquery.getXML(ctx);

 return (xml);
end getJobSearchItems;

--
-- ----------------------------------------------------------------------------
-- |---------------------< getJobSearchChannel >-------------------------------|
-- ----------------------------------------------------------------------------
--
function getJobSearchChannel(langcode in varchar2 default null,
enterprise in varchar2 default null) return clob is
xml clob;
query varchar2(1000);
ctx DBMS_XMLQUERY.ctxType;
begin
  if enterprise is not null then
     hr_multi_tenancy_pkg.set_context_for_enterprise(enterprise);
  end if;
	query:=
	 'SELECT fnd_message.get_string(''PER'',''IRC_412592_RSS_CHANNEL_TITLE'') title, fnd_message.get_string(''PER'',''IRC_412593_RSS_CHANNEL_DESC'') description , to_char(trunc(sysdate),''Dy, DD Mon YYYY'') pubDate,
	    ''/OA_HTML/IrcVisitor.jsp''  rlink
	       FROM dual';

	  ctx:= dbms_xmlquery.newContext(query);
	  dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
	  dbms_xmlquery.setEncodingTag(ctx,'UTF8');
	xml:=dbms_xmlquery.getXML(ctx);

return (xml);

end getJobSearchChannel;


FUNCTION GET_RATE_SQL
   (l_from_currency               IN     varchar2 ,
    l_to_currency                 IN     varchar2 ,
    l_exchange_date               IN     date )
return number is
conversion_rate Number;
exchange_date date := l_exchange_date;
to_currency varchar2(240) := l_to_currency;
l_profile_date varchar2(240);
	cursor csr_corp_currency is
	select CURRENCY_CODE
	from per_business_groups
	where BUSINESS_GROUP_ID = fnd_profile.value('IRC_CORPORATE_BUSINESS_GROUP');
begin
--
if(to_currency is null) then
	open csr_corp_currency;
	fetch csr_corp_currency into to_currency;
	if csr_corp_currency%notfound then
   to_currency := '';
   end if;
end if;
--
if(exchange_date is null) then
	select nvl(fnd_profile.value('IRC_CURR_CONV_DATE'),'') into l_profile_date
	from dual;
	exchange_date := get_exchange_date(l_profile_date,to_currency);
end if;

conversion_rate := hr_currency_pkg.get_rate_sql (
p_from_currency     =>  l_from_currency,
p_to_currency       =>  to_currency,
p_conversion_date   =>   exchange_date,
p_rate_type         =>    'Corporate');
return conversion_rate;
end get_rate_sql;

function get_exchange_date(profile_date in varchar2,
                           l_from_currency in varchar2)
return date
is
  l_user_date date;
  l_to_currency varchar2(240);
  cursor csr_curr_code is
     select CURRENCY_CODE
     from per_business_groups
     where BUSINESS_GROUP_ID = fnd_profile.value('IRC_CORPORATE_BUSINESS_GROUP');
begin
l_user_date := to_date(profile_date||'-'||to_char(sysdate,'YYYY'),'dd-MM-YYYY');
if(l_user_date > sysdate) then
l_user_date := to_date(profile_date||'-'||to_char(to_number(to_char(sysdate,'YYYY'))-1),'dd-MM-YYYY');
end if;
return l_user_date;
exception
when others then
   OPEN csr_curr_code;
   FETCH csr_curr_code INTO l_to_currency;
  if csr_curr_code%notfound then
    l_to_currency :='';
  end if;
  CLOSE csr_curr_code;
--
--
     select max(conversion_date) into l_user_date
     from GL_DAILY_RATES
     where from_currency = l_from_currency
     and to_currency = l_to_currency
     and conversion_type = 'Corporate'
     and conversion_date <= sysdate
     order by conversion_date desc;
    if(l_user_date is null) then
      return sysdate;
    end if;
return l_user_date;
end get_exchange_date;
FUNCTION is_salary_basis_required
                                    (
                                            p_business_group_id IN NUMBER,
                                            p_organization_id   IN NUMBER,
                                            p_position_id       IN NUMBER,
                                            p_grade_id          IN NUMBER,
                                            p_job_id            IN NUMBER
                                    )
        RETURN VARCHAR2
IS
        l_job_dff_column_name   VARCHAR2(240);
        l_grade_dff_column_name VARCHAR2(240);
        l_grade_name            VARCHAR2(240);
        l_position_name         VARCHAR2(240);
        l_organization_name     VARCHAR2(240);
        l_job_name              VARCHAR2(240);
        l_business_group_name   VARCHAR2(240);
        CURSOR csr_select_column_names(dff_name VARCHAR2)
        IS
                SELECT APPLICATION_COLUMN_NAME
                FROM   FND_DESCR_FLEX_COLUMN_USAGES
                WHERE  DESCRIPTIVE_FLEXFIELD_NAME = (dff_name)
                and    DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements'
                AND    END_USER_COLUMN_NAME = fnd_profile.value('IRC_OFFER_SAL_FLEX_SEGMENT');

         return_val    VARCHAR2(24);
         query_stmt    VARCHAR2(2000);
         l_column_name VARCHAR2(240);
         --
 BEGIN
         --
         IF(p_grade_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_grade_name
                 FROM   per_grades
                 WHERE  grade_id = p_grade_id;

                 OPEN csr_select_column_names('PER_GRADES');
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from per_grades where grade_id = :grade_id';
                         EXECUTE immediate query_stmt INTO return_val USING p_grade_id;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
         IF(p_position_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_position_name
                 FROM   HR_ALL_POSITIONS_F
                 WHERE  position_id = p_position_id
                   AND  TRUNC(sysdate) between effective_start_date and effective_end_date;

                 OPEN csr_select_column_names('PER_POSITIONS');
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from hr_all_positions_f where position_id = '
                         || p_position_id
                         || ' AND TRUNC(sysdate) between effective_start_date and effective_end_date';
                         EXECUTE immediate query_stmt INTO return_val;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
                  IF(p_job_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_job_name
                 FROM   per_jobs
                 WHERE  job_id = p_job_id;

                 OPEN csr_select_column_names('PER_JOBS');
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from per_jobs where job_id = :job_id';
                         EXECUTE immediate query_stmt INTO return_val USING p_job_id;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
         IF(p_organization_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_organization_name
                 FROM   HR_ALL_ORGANIZATION_UNITS
                 WHERE  organization_id = p_organization_id;

                 OPEN csr_select_column_names('PER_ORGANIZATION_UNITS');
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from HR_ALL_ORGANIZATION_UNITS where organization_id = '
                         ||p_organization_id;
                         EXECUTE immediate query_stmt INTO return_val;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
         IF(p_business_group_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_business_group_name
                 FROM   HR_ALL_ORGANIZATION_UNITS
                 WHERE  organization_id = p_business_group_id;

                 OPEN csr_select_column_names('PER_ORGANIZATION_UNITS');
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from HR_ALL_ORGANIZATION_UNITS where organization_id = '
                         ||p_organization_id;
                         EXECUTE immediate query_stmt INTO return_val;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
         RETURN return_val;
  END is_salary_basis_required;


  FUNCTION is_proposed_salary_required
                                    (
                                            p_salary_basis_id   IN NUMBER
                                    )
        RETURN VARCHAR2
        is
        l_salary_basis_name     VARCHAR2(240);
        return_val    VARCHAR2(24);
        query_stmt    VARCHAR2(2000);
        l_column_name VARCHAR2(240);

        CURSOR csr_select_column_names
        IS
                SELECT APPLICATION_COLUMN_NAME
                FROM   FND_DESCR_FLEX_COLUMN_USAGES
                WHERE  DESCRIPTIVE_FLEXFIELD_NAME = 'PER_PAY_BASES'
                 and    DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements'
                AND    END_USER_COLUMN_NAME = fnd_profile.value('IRC_OFFER_SAL_FLEX_SEGMENT');
        Begin
         IF(p_salary_basis_id IS NOT NULL) THEN
                 SELECT name
                 INTO   l_salary_basis_name
                 FROM   per_pay_bases
                 WHERE  PAY_BASIS_ID = p_salary_basis_id;

                 OPEN csr_select_column_names;
                 FETCH csr_select_column_names
                 INTO  l_column_name;

                 IF csr_select_column_names%found THEN
                         query_stmt := 'select '
                         || l_column_name
                         || ' from per_pay_bases where PAY_BASIS_ID = '
                         ||p_salary_basis_id;
                         EXECUTE immediate query_stmt INTO return_val;
                 END IF;
                 CLOSE csr_select_column_names;
                 IF (return_val IS NOT NULL) THEN
                         RETURN return_val;
                 END IF;
         END IF;
         RETURN return_val;
    end is_proposed_salary_required;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< GET_PERSON_TYPE >----------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_person_type (p_party_id  number
                         ,p_eff_date  date  )
  RETURN VARCHAR2
IS
  --
  l_person_type varchar2(400);
  --
  CURSOR csr_emp_person_types
  IS
    SELECT typ.system_person_type
      FROM per_person_types typ
          ,per_person_type_usages_f ptu
          ,PER_ALL_PEOPLE_F ppf
    WHERE ppf.party_id = p_party_id
    AND p_eff_date BETWEEN ppf.effective_start_date and ppf.effective_end_date
    AND ppf.person_id = ptu.person_id
    AND typ.system_person_type IN ('EMP','EX_EMP')
    AND typ.person_type_id = ptu.person_type_id
    AND p_eff_date BETWEEN ptu.effective_start_date
                          AND ptu.effective_end_date
       order by typ.system_person_type ASC, ptu.effective_start_date DESC;
  --
BEGIN
  --
  open csr_emp_person_types;
  fetch csr_emp_person_types into l_person_type;
  if csr_emp_person_types%notfound then
    l_person_type:='';
  end if;
  close csr_emp_person_types;
  --
  RETURN l_person_type;
  --
END get_person_type;
--
END IRC_UTILITIES_PKG;

/
