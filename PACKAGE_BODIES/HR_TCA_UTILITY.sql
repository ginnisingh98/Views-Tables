--------------------------------------------------------
--  DDL for Package Body HR_TCA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TCA_UTILITY" as
/* $Header: petcautl.pkb 115.3 2004/06/29 10:09:41 tpapired noship $ */

  g_package varchar2(30) := 'hr_tca_utility.';
  -- ----------------------------------------------------------------------------
  -- |------------------------------< get_person_id >---------------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE get_person_id
    (p_party_id       in  number
    ,p_effective_date in  date default sysdate
    ,p_person_id      out nocopy number
    ,p_matches        out nocopy varchar
    ) is

    l_person_id        number;
    l_effective_date   date;
    l_count            number :=0;
    l_proc varchar2(80) := g_package||'get_person_id';
    --
    -- Cursor to check for persons of a valid person_type for given party_id
    --
    cursor person_cur (p_party_id in number) IS
       SELECT ppf.PERSON_ID
	         ,typ.SYSTEM_PERSON_TYPE
       FROM  per_all_people_f ppf
            ,per_person_types typ
            ,per_person_type_usages_f ptu
       WHERE ppf.party_id           = p_party_id
       AND   l_effective_date between ppf.effective_start_date
                                  and ppf.effective_end_date
       AND   ppf.person_id          = ptu.person_id
       AND   typ.person_type_id     = ptu.person_type_id
       AND   l_effective_date between ptu.effective_start_date
                                  and ptu.effective_end_date
       ORDER BY DECODE(typ.system_person_type
                      ,'EMP'   ,1
                      ,'CWK'   ,2
                      ,'APL'   ,3
                      ,'EX_EMP',4
                      ,'EX_CWK',5
                      ,'EX_APL',6
                               ,7
                      ), ppf.person_id desc;
    --
    person_type person_cur%rowtype;
    --
    -- A person can have multiple person_types and can have the same person_id for other
    -- person types, which should not be counted as multiple matches. This cursor gets
    -- all other person_id's except the person fetched in the above cursor. This clearly
    -- identifies if more than one match exists for the given party_id
    --
    cursor multiple_person_cur (p_party_id in number,p_person_id in number) IS
       SELECT ppf.PERSON_ID
       FROM  per_all_people_f ppf
       WHERE ppf.party_id           = p_party_id
       AND   l_effective_date between ppf.effective_start_date
                                  and ppf.effective_end_date
       AND   ppf.person_id <> p_person_id;
    --
    multiple_person_type multiple_person_cur%rowtype;
  --
  Begin
  --
    hr_utility.set_location('Entering  '||l_proc,10);
    --
      l_effective_date := trunc(p_effective_date);
      -- initially set this to 'N'.
      p_matches := 'N';

      open person_cur(p_party_id);
      LOOP
        fetch person_cur into person_type;
        exit when person_cur%notfound;
        p_person_id := person_type.person_id;
        --
        --
           p_matches := 'Y';
           --
           -- since atleast one person has a valid match, no need to check
	   -- further, but check for existence of more matches with second cursor.
           -- This cursor fetches all other persons except the person fetched above
           --
           open multiple_person_cur(p_party_id,p_person_id);
           fetch multiple_person_cur into multiple_person_type;
           exit when multiple_person_cur%notfound;
           p_matches := 'W';
           exit;
        --
      end loop;
      --
      close person_cur;
      --
      if multiple_person_cur%ISOPEN then
        close multiple_person_cur;
      end if;
      --
    hr_utility.set_location('Leaving  '||l_proc,100);
    --
    end;
    --
end hr_tca_utility;
--

/
