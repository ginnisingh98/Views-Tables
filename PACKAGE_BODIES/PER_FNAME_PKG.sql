--------------------------------------------------------
--  DDL for Package Body PER_FNAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FNAME_PKG" AS
/* $Header: pepefnam.pkb 115.1 2004/03/23 01:00:11 bsubrama noship $ */

procedure REBUILD_FULLNAME ( errbuf out NOCOPY varchar2,
                                     retcode out NOCOPY NUMBER,
                                     p_legislation_code varchar2)
IS


 --
 -- Set up the PL/SQL tables used to hold values returned from Bulk Collect
 --
   type person_id_list is table of per_all_people_f.person_id%type;
   TYPE effective_start_date_list IS TABLE OF per_all_people_f.effective_start_date%TYPE;
   TYPE effective_end_date_list IS TABLE OF per_all_people_f.effective_end_Date%TYPE;
 -- Fix 3386992 Start
   type first_name_list is table of per_all_people_f.first_name%type;
   type middle_names_list is table of per_all_people_f.middle_names%type;
   type last_name_list is table of per_all_people_f.last_name%type;
   type known_as_list is table of per_all_people_f.known_as%type;
   type title_list is table of per_all_people_f.title%type;
   type suffix_list is table of per_all_people_f.suffix%type;
   type date_of_birth_list is table of per_all_people_f.date_of_birth%type;
   type business_group_id_list is table of per_all_people_f.business_group_id%type;
   type full_name_list is table of per_all_people_f.full_name%type;
 -- Fix 3386992 End

 --
 -- Declare the variables based on this new type
 --
    l_person_id_list            person_id_list;
    l_effective_start_date_list effective_start_date_list;
    l_effective_end_date_list   effective_end_date_list;
 -- Fix 3386992 Start
    l_first_name_list           first_name_list;
    l_middle_names_list         middle_names_list;
    l_last_name_list            last_name_list;
    l_known_as_list             known_as_list;
    l_title_list                title_list;
    l_suffix_list               suffix_list;
    l_date_of_birth_list        date_of_birth_list;
    l_business_group_id_list    business_group_id_list;
    l_full_name_list             full_name_list;
    l_dflag  varchar2(100);
 -- Fix 3386992 End

   -- Cursor to check for installed legislation
   CURSOR instl_prod (p_legislation_code varchar2) IS
    SELECT 'x'
    FROM   hr_legislation_installations
    WHERE  application_short_name = 'PER'
                   AND (status='I' OR action IS NOT NULL)
                   AND legislation_code = p_legislation_code;


  -- cursor to check package body is delivered by Localization Team
  CURSOR lgsl_pkb(p_legislation_code varchar2) IS
    SELECT 'x'
    FROM user_objects
    WHERE object_type='PACKAGE BODY'
      AND object_name LIKE 'HR_'||p_legislation_code||'_UTILITY'
      AND length(object_name)=13
    ORDER BY object_name;

 -- Cursor to select all persons belonging to legislation code.
 cursor csr_get_people_in_leg (p_legislation_code varchar2) is
     select person_id,
            effective_start_date,
            effective_end_date
     from per_all_people_f per, per_business_groups bg
     where per.business_group_id = bg.business_group_id
     and   bg.legislation_code = p_legislation_code;

 -- Fix 3386992 Start
 -- This trigger is similar to the one being used already csr_get_people_in_leg
 -- but fetches additional fields from the table
 cursor csr_get_people_details_in_leg (p_legislation_code varchar2) is
     select person_id,
            effective_start_date,
            effective_end_date,
            first_name,
            middle_names,
            last_name,
            known_as,
            title,
            suffix,
            date_of_birth,
            per.business_group_id,
            full_name
     from per_all_people_f per, per_business_groups bg
     where per.business_group_id = bg.business_group_id
     and   bg.legislation_code = p_legislation_code;
 -- Fix 3386992 End

-- Declare local variables
l_dummy  varchar2(1);
l_old_row_count number := 0; -- Fix 3386992 Initialize to zero
l_new_row_count number := 0; -- Fix 3386992 Initialize to zero
l_rows_in_this_collect number;

-- Fix 3386992
-- Variable holds the state of installation of the package hr_<leg_code>_utility
l_leg_util_installed boolean := true;

-- p_legislation_code varchar2(2):= 'US'; -- Should be reomved while creating Proc
 --
 -- This block defines the number of rows to update before committing
 --
 l_commit_block NATURAL := 100;



BEGIN

retcode := 0;
errbuf := NULL;

   if p_legislation_code is null then
       -- In the rare case that this script is called incorrectly
       -- without being passed a legislation code, raise an error
       --
       fnd_message.set_name('PER', 'PER_52123_AMD_LEG_CODE_INV');
       hr_utility.raise_error;
   end if;

   OPEN instl_prod(p_legislation_code);
   FETCH instl_prod INTO l_dummy;
   IF instl_prod%notfound THEN
      CLOSE instl_prod;
      retcode := 1;
      errbuf := 'Legislation Not Installed';
      fnd_message.set_name('PER', 'PER_52123_AMD_LEG_CODE_INV');
      hr_utility.raise_error;
      return;
   END IF;

   CLOSE instl_prod;

   -- Fix 3386992
   -- Initialize the value of the variable l_leg_util_installed
   -- based on whether the package is installed or not.
   OPEN lgsl_pkb(p_legislation_code);
   FETCH lgsl_pkb INTO l_dummy;
   IF lgsl_pkb%notfound THEN
      CLOSE lgsl_pkb;
      l_leg_util_installed := false;
   else
      CLOSE lgsl_pkb;
      l_leg_util_installed := true;
   END IF;


   OPEN csr_get_people_in_leg(p_legislation_code);
   OPEN csr_get_people_details_in_leg(p_legislation_code);

   LOOP -- Wish to loop round and commit every l_commit_block rows,
        -- processing l_commit_block (=100) records at a time.

        -- Fix 3386992
        -- if the package hr_<LEG_CODE>_utility is installed then
        -- use trigger code  to generate full_name
        -- else use hr_person.derive_full_name
        if l_leg_util_installed then
           FETCH csr_get_people_in_leg BULK COLLECT INTO
               l_person_id_list,
               l_effective_start_date_list,
               l_effective_end_date_list
           LIMIT l_commit_block;

           -- We need to keep a count of how many rows we are bringing back in
           -- each iteration of the loop. Row Count is cumulative.
           -- There appears to be a bug in the way BULK COLLECT and LIMIT works
           -- in that if the COLLECT retrieves less rows that the LIMIT number
           -- it raises a CSR%NOTFOUND exception. Therefore we cannot exit on
           -- this exception as the last rows will not get processed.
           --
           -- To get around this, we keep track of how many rows will be
           -- processed on this iteration and exit when this drops to zero.

              l_old_row_count := l_new_row_count;
              l_new_row_count := csr_get_people_in_leg%ROWCOUNT;

              l_rows_in_this_collect := l_new_row_count - l_old_row_count;

             --
             -- Break out of the loop when the BULK COLLECT has got all rows
             --
             EXIT WHEN (l_rows_in_this_collect = 0);

           FORALL j IN l_person_id_list.FIRST..l_person_id_list.LAST

           -- Touching the rows by update statement so that the actual
           -- Full name and Order name is derived by logic in
           -- trigger PER_ALL_PEOPLE_F_NAME
           --

           UPDATE  per_all_people_f
           SET last_name = last_name
           WHERE person_id = l_person_id_list(j)
                and effective_start_date = l_effective_start_date_list(j)
                and effective_end_date   = l_effective_end_date_list(j);
           COMMIT;

        else

            FETCH csr_get_people_details_in_leg BULK COLLECT INTO
               l_person_id_list,
               l_effective_start_date_list,
               l_effective_end_date_list,
               l_first_name_list,
               l_middle_names_list,
               l_last_name_list,
               l_known_as_list,
               l_title_list,
               l_suffix_list,
               l_date_of_birth_list,
               l_business_group_id_list,
               l_full_name_list
            LIMIT l_commit_block;

            -- We need to keep a count of how many rows we are bringing back in
            -- each iteration of the loop. Row Count is cumulative.
            -- There appears to be a bug in the way BULK COLLECT and LIMIT works
            -- in that if the COLLECT retrieves less rows that the LIMIT number
            -- it raises a CSR%NOTFOUND exception. Therefore we cannot exit on
            -- this exception as the last rows will not get processed.
            --
            -- To get around this, we keep track of how many rows will be
            -- processed on this iteration and exit when this drops to zero.

            l_old_row_count := l_new_row_count;
            l_new_row_count := csr_get_people_details_in_leg%ROWCOUNT;

            l_rows_in_this_collect := l_new_row_count - l_old_row_count;

            --
            -- Break out of the loop when the BULK COLLECT has got all rows
            --
            EXIT WHEN (l_rows_in_this_collect = 0);

            -- For each record, generate the full_name using
            -- procedure hr_person.derive_full_name
            for counter in 1 .. l_rows_in_this_collect
            loop
               hr_person.derive_full_name
                   (p_first_name    => l_first_name_list(counter),
                    p_middle_names  => l_middle_names_list(counter),
                    p_last_name     => l_last_name_list(counter),
                    p_known_as      => l_known_as_list(counter),
                    p_title         => l_title_list(counter),
                    p_suffix        => l_suffix_list(counter),
                    p_date_of_birth => l_date_of_birth_list(counter),
                    p_person_id         => l_person_id_list(counter),
                    p_business_group_id => l_business_group_id_list(counter),
                    p_full_name => l_full_name_list(counter) ,
                    p_duplicate_flag => l_dflag);
            end loop;

            FORALL j IN l_person_id_list.FIRST..l_person_id_list.LAST

            -- Touching the rows by update statement so that the actual
            -- Full name and Order name is derived by logic in
            -- trigger PER_ALL_PEOPLE_F_NAME
              --

            UPDATE  per_all_people_f
            SET full_name = l_full_name_list(j)  -- Fix 3386992
            WHERE person_id = l_person_id_list(j)
                and effective_start_date = l_effective_start_date_list(j)
                and effective_end_date   = l_effective_end_date_list(j);

            COMMIT;
        end if;

    END LOOP;

EXCEPTION
   WHEN OTHERS THEN
       retcode := sqlcode;
       errbuf  := sqlerrm;
       ROLLBACK;
END;

END PER_FNAME_PKG;

/
