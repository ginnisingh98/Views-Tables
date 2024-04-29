--------------------------------------------------------
--  DDL for Package Body PER_PERFRALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERFRALC_PKG" AS
/*$Header: perfralc.pkb 115.9 2002/11/25 15:33:29 sfmorris ship $*/
--
procedure run_process   (errbuf		         out nocopy varchar2,
			 retcode		 out nocopy number,
			 P_BUSINESS_GROUP_ID     in number,
	    	         P_APPLICATION_ID        in number,
		         P_LOOKUP_TYPE           in varchar2,
		         P_ROW_TITLE             in varchar2,
		         P_FUNCTION_TYPE         in varchar2,
		         P_REQUIRED_DEFAULTS     in varchar2,
		         P_DEFAULT_VALUE         in varchar2,
		         P_LEGISLATION_CODE      in varchar2) IS
--
l_legislation_code per_business_groups.legislation_code%type;
--
cursor csr_table_name is
       select a.user_table_id
       from pay_user_tables_v a
       where upper (a.user_table_name) = upper (P_LOOKUP_TYPE)
       and a.business_group_id = P_BUSINESS_GROUP_ID;

cursor csr_column_name (p_user_table_id number) is
       select c.user_column_id
       from pay_user_columns_v c
       where p_user_table_id = c.user_table_id
       and  upper (c.user_column_name) = upper (P_FUNCTION_TYPE)
       and  nvl(c.business_group_id,P_BUSINESS_GROUP_ID) = P_BUSINESS_GROUP_ID
       and  nvl(c.legislation_code,l_legislation_code) = l_legislation_code;

cursor csr_lookup_code(p_user_table_id number) is
      select hl.lookup_code, hl.meaning, b.user_row_id, b.effective_start_date, b.effective_end_date
      from hr_lookups hl, pay_user_rows_f b
       where hl.lookup_type = P_LOOKUP_TYPE
       and   b.user_table_id (+) = p_user_table_id
       and   nvl(b.business_group_id(+),P_BUSINESS_GROUP_ID) = P_BUSINESS_GROUP_ID
       and   nvl(b.legislation_code(+),l_legislation_code) = l_legislation_code
       and   b.row_low_range_or_name(+) = hl.lookup_code;

cursor csr_instance (p_user_row_id number, p_user_column_id number) is
       select a.user_column_instance_id
       from pay_user_column_instances_f a
       where  a.user_row_id = p_user_row_id
       and    a.user_column_id = p_user_column_id;

cursor csr_max_sequence (p_user_table_id number) is
       select max(a.display_sequence)
       from  pay_user_rows_f a
       where user_table_id = p_user_table_id
       and   nvl(a.business_group_id,P_BUSINESS_GROUP_ID) = P_BUSINESS_GROUP_ID
       and   nvl(a.legislation_code,l_legislation_code) = l_legislation_code;
--
l_order_code_new number;
--
l_table_rowid varchar2(100);
--
l_column_rowid varchar2(100);
l_column_instance_rowid varchar2(100);
--
l_user_row_id number;
l_user_table_id number;
l_user_column_id number;
l_user_column_instance_id number;
--
l_procedure varchar2(100);
--
l_lookup_code hr_lookups.lookup_code%type;
l_lookup_meaning hr_lookups.meaning%type;
--
l_effective_start_date date;
l_effective_end_date date;
--
begin
--
l_table_rowid := NULL;
--
l_column_rowid := NULL;
l_column_instance_rowid := NULL;
--
l_user_row_id := NULL;
l_user_table_id := NULL;
l_user_column_id := NULL;
l_user_column_instance_id := NULL;
--
l_procedure := 'Procedure run_process in the package per_perfralc_pkg';
--
hr_utility.set_location(l_procedure , 5);
--
if P_BUSINESS_GROUP_ID is not null then
  select legislation_code into l_legislation_code
  from per_business_groups
  where business_group_id = P_BUSINESS_GROUP_ID;
--
else
--
  l_legislation_code := P_LEGISLATION_CODE;
--
end if;
--
--  Creating The Tables
--
open csr_table_name;
fetch csr_table_name into l_user_table_id;
--
 if csr_table_name%notfound then
  pay_user_tables_pkg.insert_row (
    P_ROWID => l_table_rowid
   ,P_USER_TABLE_ID => l_user_table_id
   ,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
   ,P_LEGISLATION_CODE  => l_legislation_code
   ,P_LEGISLATION_SUBGROUP => NULL
   ,P_RANGE_OR_MATCH => 'M'
   ,P_USER_KEY_UNITS => 'T'
   ,P_USER_TABLE_NAME => P_LOOKUP_TYPE
   ,P_USER_ROW_TITLE => P_ROW_TITLE);
 --
 hr_utility.trace('Successefully  created table '|| P_LOOKUP_TYPE);
 --
 end if;
--
close csr_table_name;
--
-- Creating The Columns
--
hr_utility.set_location(l_procedure , 10);
--
open csr_column_name(l_user_table_id);
fetch csr_column_name into l_user_column_id;
if csr_column_name%notfound then
pay_user_columns_pkg.insert_row (
    P_ROWID => l_column_rowid
    ,P_USER_COLUMN_ID => l_user_column_id
   ,P_USER_TABLE_ID => l_user_table_id
   ,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
   ,P_LEGISLATION_CODE  => l_legislation_code
   ,P_LEGISLATION_SUBGROUP => NULL
   ,P_USER_COLUMN_NAME => P_FUNCTION_TYPE
   ,P_FORMULA_ID => NULL);
 --
 hr_utility.trace('Successefully  created column '|| P_FUNCTION_TYPE);
 --
end if;
--
close csr_column_name;
--
-- Creating The Rows
--
hr_utility.set_location(l_procedure , 15);
--
open csr_lookup_code(l_user_table_id);
loop
--
 open csr_max_sequence(l_user_table_id);
 fetch csr_max_sequence into l_order_code_new;
 close csr_max_sequence;
--
    fetch csr_lookup_code into l_lookup_code,l_lookup_meaning,l_user_row_id,
    			       l_effective_start_date, l_effective_end_date;
    exit when csr_lookup_code%notfound;
--
   if l_effective_start_date is null then
     l_effective_start_date := to_date('01/01/1900', 'DD/MM/YYYY');
   end if;
--
   if l_effective_end_date is null then
     l_effective_end_date := to_date('31/12/4712', 'DD/MM/YYYY');
   end if;
--
 if  l_effective_start_date <> to_date('01/01/1900','DD/MM/YYYY')
 or  l_effective_end_date <> to_date('31/12/4712', 'DD/MM/YYYY') then
    null;
--
 else
  if l_user_row_id is null then
    select pay_user_rows_s.nextval into l_user_row_id from dual;
      --
      if l_order_code_new is null then
         l_order_code_new := 10;
      else
        l_order_code_new := l_order_code_new + 10;
      end if;
      --
   	insert into PAY_USER_ROWS_F
 		(USER_ROW_ID,
	 	EFFECTIVE_START_DATE,
	 	EFFECTIVE_END_DATE,
	 	BUSINESS_GROUP_ID,
	 	LEGISLATION_CODE,
	 	USER_TABLE_ID,
	 	ROW_LOW_RANGE_OR_NAME,
	 	DISPLAY_SEQUENCE,
	 	LEGISLATION_SUBGROUP,
	 	ROW_HIGH_RANGE)
	values  (l_user_row_id,
	 	to_date('01/01/1900', 'DD/MM/YYYY'),
	 	to_date('31/12/4712', 'DD/MM/YYYY'),
	 	P_BUSINESS_GROUP_ID,
	 	l_legislation_code,
	 	l_user_table_id,
	 	l_lookup_code,
	 	(l_order_code_new),
	 	NULL,
	 	NULL);
   --
      hr_utility.trace('Successefully  created row '|| l_lookup_code);
   --
   end if;
   --
   -- Creating The Column Values
   --
      hr_utility.set_location(l_procedure , 20);
   --
   l_user_column_instance_id := null;
   open csr_instance(l_user_row_id,l_user_column_id);
   fetch csr_instance into l_user_column_instance_id;
   close csr_instance;
   --
   if (l_user_column_instance_id is null) then
    --
      if P_REQUIRED_DEFAULTS = 'NONE' then
	 pay_user_column_instances_pkg.insert_row(
   	 	 P_ROWID => l_column_instance_rowid
   		,P_USER_COLUMN_INSTANCE_ID => l_user_column_instance_id
   		,P_EFFECTIVE_START_DATE => to_date('01/01/1900', 'DD/MM/YYYY')
   		,P_EFFECTIVE_END_DATE => to_date('31/12/4712', 'DD/MM/YYYY')
   		,P_USER_ROW_ID => l_user_row_id
   		,P_USER_COLUMN_ID => l_user_column_id
   		,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
   		,P_LEGISLATION_CODE => l_legislation_code
   		,P_LEGISLATION_SUBGROUP => NULL
   		,P_VALUE => NULL);
      --
      elsif  P_REQUIRED_DEFAULTS = 'QUICKCODE_VALUE' then
 	pay_user_column_instances_pkg.insert_row(
    		 P_ROWID => l_column_instance_rowid
   		,P_USER_COLUMN_INSTANCE_ID =>  l_user_column_instance_id
   		,P_EFFECTIVE_START_DATE => to_date('01/01/1900', 'DD/MM/YYYY')
   		,P_EFFECTIVE_END_DATE => to_date('31/12/4712', 'DD/MM/YYYY')
   		,P_USER_ROW_ID => l_user_row_id
   		,P_USER_COLUMN_ID => l_user_column_id
   		,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
   		,P_LEGISLATION_CODE => l_legislation_code
   		,P_LEGISLATION_SUBGROUP => NULL
   		,P_VALUE => l_lookup_meaning);
      --
      else
         pay_user_column_instances_pkg.insert_row(
    		 P_ROWID => l_column_instance_rowid
   		,P_USER_COLUMN_INSTANCE_ID =>  l_user_column_instance_id
   		,P_EFFECTIVE_START_DATE => to_date('01/01/1900', 'DD/MM/YYYY')
   		,P_EFFECTIVE_END_DATE => to_date('31/12/4712', 'DD/MM/YYYY')
   		,P_USER_ROW_ID => l_user_row_id
   		,P_USER_COLUMN_ID => l_user_column_id
   		,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
   		,P_LEGISLATION_CODE => l_legislation_code
   		,P_LEGISLATION_SUBGROUP => NULL
   		,P_VALUE => P_DEFAULT_VALUE);
     end if;
     --
    end if;
--
  end if;
--
end loop;
--
close csr_lookup_code;
--
errbuf := null;
retcode := 0;
--
exception
  when others then
  	hr_utility.trace ('Error in the '||l_procedure||' - ORA '||to_char(SQLCODE));
  	errbuf := sqlerrm;
  	retcode := 2;
	rollback;
--
end run_process;
--
---------------------------------------------------------------------------
-- |----------------  Clean_pay_tables  -------------------------------|  -
---------------------------------------------------------------------------
procedure clean_pay_tables
            (cn_business_group_id IN per_business_groups.business_group_id%TYPE,
             cp_user_table_name   IN pay_user_tables.user_table_name%TYPE) IS


ln_row_count           number  := 1;
ln_user_table_id       number;
ln_user_column_id      number;
ln_user_row_id         number;
ln_pay_user_rows       number;


--
-- Local Cursor Definition
--

CURSOR Get_pay_user_tables_id (cp_user_table_name   CHAR,
                               cn_business_group_id NUMBER) IS
SELECT USER_TABLE_ID
FROM PAY_USER_TABLES
WHERE USER_TABLE_NAME   = cp_user_table_name and
      BUSINESS_GROUP_ID = cn_business_group_id;


CURSOR Get_pay_user_columns (cp_user_table_id     NUMBER,
                             cn_business_group_id NUMBER) IS
SELECT USER_COLUMN_ID
FROM PAY_USER_COLUMNS
WHERE USER_TABLE_ID     = cp_user_table_id and
      BUSINESS_GROUP_ID = cn_business_group_id;


CURSOR Get_pay_user_rows_f (cp_user_table_id     NUMBER,
                            cn_business_group_id NUMBER) IS
SELECT USER_ROW_ID
FROM PAY_USER_ROWS_F
WHERE USER_TABLE_ID    = cp_user_table_id and
      BUSINESS_GROUP_ID = cn_business_group_id;

begin
  hr_utility.set_location('perfralc - Clean_pay_tables ', 1);
  -- Clean all the PAY_USER tables for one specific (lookup) table
  --
  --
  -- Get first the user_table_id associated to the given user_table_name
  OPEN Get_pay_user_tables_id (cp_user_table_name,cn_business_group_id);
  FETCH Get_pay_user_tables_id into ln_user_table_id;
  If (Get_pay_user_tables_id%FOUND) then
     Begin
        hr_utility.set_location('perfralc - Clean_pay_tables', 5);
        hr_utility.set_location('user_table_id found for ' || cp_user_table_name, 5);
        -- Get all the PAY_USER_COLUMNS associated to the user_table_name
        -- For each column, get the Ids of the column instances to delete them
        OPEN Get_pay_user_columns (ln_user_table_id,cn_business_group_id);
        Loop
           FETCH Get_pay_user_columns into ln_user_column_id;
           EXIT When Get_pay_user_columns%NOTFOUND;
           hr_utility.set_location('user_column_id found for ' || to_char(ln_user_column_id), 10);
           -- Get all the PAY_USER_ROWS_F Columns
           OPEN Get_pay_user_rows_f (ln_user_table_id,cn_business_group_id);
           Loop
              FETCH Get_pay_user_rows_f into ln_pay_user_rows;
              EXIT When Get_pay_user_rows_f%NOTFOUND;

              hr_utility.set_location('user_rows_f found. to be deleted ' || to_char(ln_pay_user_rows), 15);
              -- for each pay_user_row found, delete the associated
              -- PAY_USER_COLUMN_INSTANCES_F (related value for added column)
              DELETE FROM PAY_USER_COLUMN_INSTANCES_F
              WHERE USER_ROW_ID       = ln_pay_user_rows  and
                    USER_COLUMN_ID    = ln_user_column_id and
                    BUSINESS_GROUP_ID = cn_business_group_id;

           End Loop;
           CLOSE Get_pay_user_rows_f;

        End Loop;
        CLOSE Get_pay_user_columns;

        hr_utility.set_location('perfralc - delete pay_user_row, column and table rows' , 20);
        -- Delete all the PAY_USER_ROW, COLUMNS and TABLE rows
        DELETE FROM PAY_USER_ROWS_F
        WHERE USER_TABLE_ID     = ln_user_table_id and
              BUSINESS_GROUP_ID = cn_business_group_id;

        DELETE FROM PAY_USER_COLUMNS
        WHERE USER_TABLE_ID     = ln_user_table_id and
              BUSINESS_GROUP_ID = cn_business_group_id;

        DELETE FROM PAY_USER_TABLES
        WHERE USER_TABLE_ID     = ln_user_table_id and
              BUSINESS_GROUP_ID = cn_business_group_id;
     end;
  end if;
  CLOSE Get_pay_user_tables_id;
  hr_utility.set_location('perfralc - End Clean_pay_tables', 50);
end;




------------------------------------------------------------------
-- -----  set_instance_value ------------------------------------|
------------------------------------------------------------------
Procedure Set_instance_value  (cn_business_group_id  IN per_business_groups.business_group_id%TYPE,
                               cp_legislation_code   IN per_business_groups.legislation_code%TYPE,
                               cp_user_table_name    IN pay_user_tables.user_table_name%TYPE       ,
                               cp_user_column_name   IN pay_user_columns.user_column_name%TYPE     ,
                               cp_row_name           IN pay_user_rows_f.row_low_range_or_name%TYPE ,
                               cp_value              IN pay_user_column_instances_f.value%TYPE
                              ) IS


ln_count_column_instance_id  NUMBER;
ln_count_row_id              NUMBER;
ln_column_instance_id        NUMBER;
ln_user_table_id             NUMBER;
ln_user_column_id            NUMBER;
ln_user_row_id               NUMBER;

--
-- Local Cursor Definition

CURSOR Get_pay_user_tables_id (cp_user_table_name   CHAR,
                               cn_business_group_id NUMBER) IS
SELECT USER_TABLE_ID
FROM PAY_USER_TABLES
WHERE USER_TABLE_NAME   = cp_user_table_name
  and BUSINESS_GROUP_ID = cn_business_group_id;


CURSOR Get_column_id (cp_user_table_id    NUMBER,
                      cp_user_column_name pay_user_columns.user_column_name%TYPE,
                      cn_business_group_id NUMBER) IS
SELECT USER_COLUMN_ID
FROM PAY_USER_COLUMNS
WHERE USER_TABLE_ID     = cp_user_table_id    and
      USER_COLUMN_NAME  = cp_user_column_name and
      BUSINESS_GROUP_ID = cn_business_group_id;



CURSOR Get_row_id (cp_user_table_id NUMBER,
                   cp_row_name IN pay_user_rows_f.row_low_range_or_name%TYPE,
                   cn_business_group_id NUMBER) IS
SELECT USER_ROW_ID
FROM PAY_USER_ROWS_F
WHERE USER_TABLE_ID         = cp_user_table_id    and
      ROW_LOW_RANGE_OR_NAME = cp_row_name         and
      BUSINESS_GROUP_ID     = cn_business_group_id;


CURSOR Get_Column_instance_id (cn_user_row_id       NUMBER,
                               cn_user_column_id    NUMBER,
                               cn_business_group_id NUMBER) IS
SELECT USER_COLUMN_INSTANCE_ID
FROM PAY_USER_COLUMN_INSTANCES_F
WHERE USER_ROW_ID       = cn_user_row_id     and
      USER_COLUMN_ID    = cn_user_column_id  and
      BUSINESS_GROUP_ID = cn_business_group_id;



Begin
  -- First, Get the table_id
  --
  hr_utility.set_location('perfralc - set_instance_value - Entering',1);
  OPEN Get_pay_user_tables_id (cp_user_table_name,cn_business_group_id);
  FETCH Get_pay_user_tables_id into ln_user_table_id;
  if (Get_pay_user_tables_id%NOTFOUND) Then
     hr_utility.set_location('perfralc - set_instance_value - unknown table_name : ' || cp_user_table_name, 5);
  Else
     hr_utility.set_location(' --> table_id = ' || to_char(ln_user_table_id),2);
     -- Get the column id
     --
     OPEN Get_column_id (ln_user_table_id,cp_user_column_name,cn_business_group_id);
     FETCH Get_column_id into ln_user_column_id;
     if (Get_column_id%NOTFOUND) Then
        hr_utility.set_location('perfralc - set_instance_value - unknown column_name : ' || cp_user_column_name, 10);
     Else
        hr_utility.set_location(' --> column_id = ' || to_char(ln_user_column_id),2);
        -- Get the row id, and check if only one instance is defined
        --
        ln_count_row_id := 0;
        OPEN Get_row_id (ln_user_table_id,cp_row_name,cn_business_group_id);
        Loop
           FETCH Get_row_id into ln_user_row_id;
           EXIT When Get_row_id%NOTFOUND;
           ln_count_row_id := ln_count_row_id + 1;
        End Loop;

        if (ln_count_row_id = 0) Then
           hr_utility.set_location('perfralc - set_instance_value - unknown row_name : ' || cp_row_name, 15);
        Else if (ln_count_row_id > 1) Then
                hr_utility.set_location('more than one effective row for ' || cp_row_name,16);
                hr_utility.set_location('nothing to do ...',17);
              else
                 Begin
                    hr_utility.set_location(' --> Row_id = ' || to_char(ln_user_row_id),18);
                    -- Get the column_instance_id to update the value
                    OPEN Get_column_instance_id (ln_user_row_id,ln_user_column_id,cn_business_group_id);

	            -- Check if we have more than one column (different effective dates) for this instance
                    ln_count_column_instance_id := 0;
                    Loop
                       FETCH Get_Column_instance_id into ln_column_instance_id;
                       EXIT When Get_Column_instance_id%NOTFOUND;
                       ln_count_column_instance_id := ln_count_column_instance_id + 1;
                    End Loop;

                    if (ln_count_column_instance_id > 1) then
                       hr_utility.set_location('no change to do. More than one instance : ' || cp_row_name, 15);
                    Else
                       Begin
                          hr_utility.set_location(' Update PAY_USER_COLUMN_INSTANCES_F for ' || to_char(ln_column_instance_id),16);
                          UPDATE PAY_USER_COLUMN_INSTANCES_F
                          set value = cp_value
                          where user_column_instance_id = ln_column_instance_id;
                          EXCEPTION
                          WHEN OTHERS Then
                             hr_utility.set_location ('perfralc - set_instance_value - unable to update row into PAY_USER_COLUMN_INSTANCES_F '|| to_char(ln_column_instance_id), 20);
                       End;
                    End if;
                 End;
              end if;
        End if;
        CLOSE Get_row_id;
     End if;
     CLOSE Get_column_id;
  End if;
  CLOSE Get_pay_user_tables_id;

  hr_utility.set_location('perfralc - Set_instance_value - Leaving',30);

End;

------------------------------------------------------------------------
-- |---------  Update_Instance_Value ----------------------------------|
------------------------------------------------------------------------
-- Procedure Update_instance_value
-- parameters are : Business_group (optional)
--                  Legislation_Code (optional)
--                  (Lookup) table_name
--                  Alternative Lookup column_name
--                  Instance_name
--                  value to be updated for the instance
--
-- Only process the Business_group if provided
-- or Process all the business_groups for a given legislation_code

Procedure Update_Instance_value
   (cn_business_group_id  IN per_business_groups.business_group_id%TYPE,
    cp_legislation_code   IN per_business_groups.legislation_code%TYPE,
    cp_user_table_name    IN pay_user_tables.user_table_name%TYPE       ,
    cp_user_column_name   IN pay_user_columns.user_column_name%TYPE     ,
    cp_row_name           IN pay_user_rows_f.row_low_range_or_name%TYPE ,
    cp_value              IN pay_user_column_instances_f.value%TYPE
   ) IS

ln_user_table_id           NUMBER;
ln_user_column_id          NUMBER;
ln_user_row_id             NUMBER;
ln_temp_leg_code           VARCHAR2(150);
ln_temp_business_group_id  NUMBER;

--
-- Local Cursor Definition

CURSOR Get_Business_group_id (cp_legislation_code per_business_groups.legislation_code%TYPE) IS
SELECT BUSINESS_GROUP_ID
FROM PER_BUSINESS_GROUPS
WHERE LEGISLATION_CODE = cp_legislation_code;



Begin
   hr_utility.set_location(' ',1);
   hr_utility.set_location('per_perfralc_pkg - Entering update_instance_value', 1);
   hr_utility.set_location('--------------------------------------------------',1);

  -- First case - only process the business_group
  if (cn_business_group_id is NOT NULL) Then
     -- check the existance of this business_group,and get the associated legislation_code
     ln_temp_leg_code := '';

     Begin
        select rtrim(ltrim(pbg.legislation_code)) into ln_temp_leg_code
        from per_business_groups pbg
        where pbg.business_group_id = cn_business_group_id;
     end;

     if (ln_temp_leg_code = '') then
        hr_utility.set_location('unable to update the instance - unknown business_group ' || to_char(cn_business_group_id),10);
     Else
        Begin
           if (ln_temp_leg_code <> '') and (cp_legislation_code <> '') and (ln_temp_leg_code <> cp_legislation_code)  Then
             hr_utility.set_location('unable to update the instance - incompatible business group and legislation code ',20);
           else
              -- call the update procedure only for the business_group
              hr_utility.set_location(' Processed the business_group ' || to_char(cn_business_group_id),21);
              set_instance_value(cn_business_group_id,
                                 ln_temp_leg_code,
                                 cp_user_table_name,
                                 cp_user_column_name,
                                 cp_row_name,
                                 cp_value);
           end if;
       end;
     end if;
  else
     -- Second case : process all the business_groups associated to the legislation_code
     OPEN Get_Business_group_id (cp_legislation_code);
     Loop
        FETCH Get_Business_Group_id into ln_temp_business_group_id;
        EXIT when Get_Business_Group_id%NOTFOUND;

        -- call the update procedure for this business_group
           set_instance_value(ln_temp_business_group_id,
                              ln_temp_leg_code,
                              cp_user_table_name,
                              cp_user_column_name,
                              cp_row_name,
                              cp_value);
     End Loop;
   end if;

  hr_utility.set_location('perfralc - Updte_Instance_value - Leaving ..',30);
End;
--
end PER_PERFRALC_PKG;

/
