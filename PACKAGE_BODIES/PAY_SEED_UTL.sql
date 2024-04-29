--------------------------------------------------------
--  DDL for Package Body PAY_SEED_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SEED_UTL" AS
/* $Header: pyseedutl.pkb 120.1.12010000.1 2008/09/26 14:16:10 asnell noship $ */
-- PLOG logging message cover for hr_utility           --
procedure PLOG ( p_message IN varchar2 ) is
-- output a message to the process log file
begin
   IF hr_utility.debug_enabled then
      hr_utility.trace('pyseedutl '||p_message);
   END IF;
end plog;


FUNCTION get_creator_id (
             p_creator_type     in VARCHAR2
            ,p_creator_name1    in VARCHAR2
            ,p_creator_name2    in VARCHAR2
            ,p_legislation_code in VARCHAR2 )
         return NUMBER
   IS
      -- Cursor to retrieve element_type_id given name - as name doesnt change date effectivly
  CURSOR c_element_name_id(p_element_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select element_type_id
      from pay_element_types_f
     where element_name = p_element_name
       and legislation_code = p_legislation_code
       and business_group_id IS NULL;

      -- Cursor to retrieve input_value_id given name - as name doesnt change date effectivly
  CURSOR c_input_name_id(p_element_name VARCHAR2,
                      p_input_value_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select i.input_value_id
      from pay_element_types_f e, pay_input_values_f i
     where e.element_name = p_element_name
       and i.name = p_input_value_name
       and i.element_type_id = e.element_type_id
       and i.legislation_code = p_legislation_code
       and i.business_group_id IS NULL
       and e.legislation_code = p_legislation_code
       and e.business_group_id IS NULL;

      -- Cursor to retrieve defined_balance_id given balance name and dimension name
  CURSOR c_defined_balance_id(p_balance_name VARCHAR2,
                      p_dimension VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select db.defined_balance_id
      from pay_balance_types b, pay_balance_dimensions d, pay_defined_balances db
     where b.balance_name = p_balance_name
       and d.dimension_name = p_dimension
       and db.balance_type_id = b.balance_type_id
       and db.balance_dimension_id = d.balance_dimension_id
       and db.legislation_code = p_legislation_code
       and db.business_group_id IS NULL
       and b.legislation_code = p_legislation_code
       and b.business_group_id IS NULL
       and d.legislation_code = p_legislation_code
       and d.business_group_id IS NULL;

      -- Cursor to retrieve absence_type_id given name
  CURSOR c_absence_type_id(p_absence_type_name VARCHAR2) IS
    select ABSENCE_ATTENDANCE_TYPE_ID
      from per_absence_attendance_types
     where name = p_absence_type_name
       and business_group_id IS NULL;

      -- Cursor to retrieve balance_type_id given name
  CURSOR c_grade_name_id(p_grade_name VARCHAR2) IS
    select GRADE_ID
      from per_grades
     where name = p_grade_name
       and business_group_id IS NULL;

      -- Cursor to retrieve balance_type_id given name
  CURSOR c_global_name_id(p_global_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select global_id
      from ff_globals_f
     where global_name = p_global_name
       and legislation_code = p_legislation_code
       and business_group_id IS NULL;

l_creator_id                NUMBER;
g_proc_name                 VARCHAR2(50);

begin

   g_proc_name := 'PAY_SEED_UTL';

   l_creator_id := null;

   If p_creator_type = 'E' then --{
        OPEN c_element_name_id(p_creator_name1, p_legislation_code );
        FETCH c_element_name_id INTO l_creator_id;
        IF c_element_name_id%NOTFOUND THEN  --{
            CLOSE c_element_name_id;
            plog(' ERROR ELEMENT_NAME:'||p_creator_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindElementName');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_element_name_id;
        END IF; --}

      IF p_creator_type = 'I' then --{
        OPEN c_input_name_id(p_creator_name1, p_creator_name2, p_legislation_code );
        FETCH c_input_name_id INTO l_creator_id;
        IF c_input_name_id%NOTFOUND THEN  --{
            CLOSE c_input_name_id;
            plog(' ERROR Element Input:'||p_creator_name1||'.'||p_creator_name2||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindElementInput');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_input_name_id;
        END IF; --}

        IF p_creator_type = 'B' then --{
        OPEN c_defined_balance_id(p_creator_name1, p_creator_name2, p_legislation_code );
        FETCH c_defined_balance_id INTO l_creator_id;
        IF c_defined_balance_id%NOTFOUND THEN  --{
            CLOSE c_defined_balance_id;
            plog(' ERROR Balance Dimension :'||p_creator_name1||'.'||p_creator_name2||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindDefinedBalance');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_defined_balance_id;
        END IF; --}

        IF p_creator_type = 'RB' then --{
        OPEN c_defined_balance_id(p_creator_name1, p_creator_name2, p_legislation_code );
        FETCH c_defined_balance_id INTO l_creator_id;
        IF c_defined_balance_id%NOTFOUND THEN  --{
            CLOSE c_defined_balance_id;
            plog(' ERROR Balance Dimension :'||p_creator_name1||'.'||p_creator_name2||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindBalanceDimension');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_defined_balance_id;
        END IF; --}

        IF p_creator_type = 'A' then --{
        OPEN c_absence_type_id(p_creator_name1);
        FETCH c_absence_type_id INTO l_creator_id;
        IF c_absence_type_id%NOTFOUND THEN  --{
            CLOSE c_absence_type_id;
            plog(' ERROR Absence Type:'||p_creator_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindAbsenceType');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_absence_type_id;
        END IF; --}

        IF p_creator_type = 'G' then --{
        OPEN c_grade_name_id(p_creator_name1);
        FETCH c_grade_name_id INTO l_creator_id;
        IF c_grade_name_id%NOTFOUND THEN  --{
            CLOSE c_grade_name_id;
            plog(' ERROR Grade:'||p_creator_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindGrade ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_grade_name_id;
        END IF; --}

        IF p_creator_type = 'S' then --{
        OPEN c_global_name_id(p_creator_name1, p_legislation_code );
        FETCH c_global_name_id INTO l_creator_id;
        IF c_global_name_id%NOTFOUND THEN  --{
            CLOSE c_global_name_id;
            plog(' ERROR Global Name:'||p_creator_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','USER_ENTITY_CREATOR_ID');
            hr_utility.set_message_token('STEP','FindFFGlobal');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_global_name_id;
        END IF; --}


   return l_creator_id;

END GET_CREATOR_ID;

FUNCTION get_parameter_value (
             p_parameter_name   in VARCHAR2
            ,p_value_name1      in VARCHAR2
            ,p_value_name2      in VARCHAR2
            ,p_legislation_code in VARCHAR2 )
         return VARCHAR2
   IS
      -- Cursor to convert parameter name into type
  CURSOR c_parm_type(p_parameter_name VARCHAR2) IS
         select decode(upper(translate(rtrim(p_PARAMETER_NAME),' ','_'))
               ,'ABSENCE_TYPE_ID','A'
               ,'BALANCE_DIMENSION_ID','BD'
               ,'BALANCE_TYPE_ID','BT'
               ,'DEFINED_BALANCE_ID','B'
               ,'ELEMENT_TYPE_ID','E'
               ,'ID_FLEX_NUMBER','KF'
               ,'INPUT_VALUE_ID','I'
               ,'PAYMENT_TYPE_ID','P'
               ,'USER_ENTITY_ID','UE'
               , 'OTHER') Creator_type
               from dual;

      -- Cursor to retrieve element_type_id given name - as name doesnt change date effectivly
  CURSOR c_element_name_id(p_element_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select element_type_id
      from pay_element_types_f
     where element_name = p_element_name
       and legislation_code = p_legislation_code
       and business_group_id IS NULL;

      -- Cursor to retrieve balance_type_id given name
  CURSOR c_balance_name_id(p_balance_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select balance_type_id
      from pay_balance_types
     where balance_name = p_balance_name
       and legislation_code = p_legislation_code
       and business_group_id IS NULL;

      -- Cursor to retrieve balance_dimension_id given name
  CURSOR c_dimension_name_id(p_dimension_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select balance_dimension_id
      from pay_balance_dimensions
     where dimension_name = p_dimension_name
       and  (legislation_code = p_legislation_code or
             ( legislation_code is null and p_legislation_code is null ))
       and business_group_id IS NULL;

      -- Cursor to retrieve input_value_id given name - as name doesnt change date effectivly
  CURSOR c_input_name_id(p_element_name VARCHAR2,
                      p_input_value_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select i.input_value_id
      from pay_element_types_f e, pay_input_values_f i
     where e.element_name = p_element_name
       and i.name = p_input_value_name
       and i.element_type_id = e.element_type_id
       and i.legislation_code = p_legislation_code
       and i.business_group_id IS NULL
       and e.legislation_code = p_legislation_code
       and e.business_group_id IS NULL;

      -- Cursor to retrieve defined_balance_id given balance name and dimension name
  CURSOR c_defined_balance_id(p_balance_name VARCHAR2,
                      p_dimension VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select db.defined_balance_id
      from pay_balance_types b, pay_balance_dimensions d, pay_defined_balances db
     where b.balance_name = p_balance_name
       and d.dimension_name = p_dimension
       and db.balance_type_id = b.balance_type_id
       and db.balance_dimension_id = d.balance_dimension_id
       and db.legislation_code = p_legislation_code
       and db.business_group_id IS NULL
       and b.legislation_code = p_legislation_code
       and b.business_group_id IS NULL
       and d.legislation_code = p_legislation_code
       and d.business_group_id IS NULL;

      -- Cursor to retrieve absence_type_id given name
  CURSOR c_absence_type_id(p_absence_type_name VARCHAR2) IS
    select ABSENCE_ATTENDANCE_TYPE_ID
      from per_absence_attendance_types
     where name = p_absence_type_name
       and business_group_id IS NULL;

      -- Cursor to retrieve balance_type_id given name
  CURSOR c_grade_name_id(p_grade_name VARCHAR2) IS
    select GRADE_ID
      from per_grades
     where name = p_grade_name
       and business_group_id IS NULL;

      -- Cursor to retrieve payment_type_id given name
  CURSOR c_payment_name_id(p_payment_type_name VARCHAR2,
                      p_legislation_code VARCHAR2) IS
    select payment_type_id
      from pay_payment_types
     where payment_type_name = p_payment_type_name
       and  (territory_code = p_legislation_code or
             ( territory_code is null and p_legislation_code is null ));

      -- Cursor to retrieve user_entity_id given name
  CURSOR c_user_entity_name_id(p_user_entity_name VARCHAR2,
                               p_legislation_code VARCHAR2) IS
    select user_entity_id
      from ff_user_entities
     where user_entity_name = p_user_entity_name
       and  (legislation_code = p_legislation_code or
             ( legislation_code is null and p_legislation_code is null ))
       and business_group_id IS NULL;

l_parameter_value           NUMBER;
l_parameter_value_char      VARCHAR2(80);
l_parm_type                 VARCHAR2(5);
g_proc_name                 VARCHAR2(50);

begin

   g_proc_name := 'PAY_SEED_UTL';

   l_parameter_value := null;

   OPEN c_parm_type(p_parameter_name);
   FETCH c_parm_type into l_parm_type;
   CLOSE c_parm_type;

   If l_parm_type = 'E' then --{
        OPEN c_element_name_id(p_value_name1, p_legislation_code );
        FETCH c_element_name_id INTO l_parameter_value;
        IF c_element_name_id%NOTFOUND THEN  --{
            CLOSE c_element_name_id;
            plog(' ERROR ELEMENT_NAME:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindElementName');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_element_name_id;
        END IF; --}

      IF l_parm_type = 'I' then --{
        OPEN c_input_name_id(p_value_name1, p_value_name2, p_legislation_code );
        FETCH c_input_name_id INTO l_parameter_value;
        IF c_input_name_id%NOTFOUND THEN  --{
            CLOSE c_input_name_id;
            plog(' ERROR Element Input:'||p_value_name1||'.'||p_value_name2||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindElementInput');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_input_name_id;
        END IF; --}

        IF l_parm_type = 'B' then --{
        OPEN c_defined_balance_id(p_value_name1, p_value_name2, p_legislation_code );
        FETCH c_defined_balance_id INTO l_parameter_value;
        IF c_defined_balance_id%NOTFOUND THEN  --{
            CLOSE c_defined_balance_id;
            plog(' ERROR Balance Dimension :'||p_value_name1||'.'||p_value_name2||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindDefinedBalance');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_defined_balance_id;
        END IF; --}

        IF l_parm_type = 'A' then --{
        OPEN c_absence_type_id(p_value_name1);
        FETCH c_absence_type_id INTO l_parameter_value;
        IF c_absence_type_id%NOTFOUND THEN  --{
            CLOSE c_absence_type_id;
            plog(' ERROR Absence Type:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindAbsenceType');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_absence_type_id;
        END IF; --}

        IF l_parm_type = 'G' then --{
        OPEN c_grade_name_id(p_value_name1);
        FETCH c_grade_name_id INTO l_parameter_value;
        IF c_grade_name_id%NOTFOUND THEN  --{
            CLOSE c_grade_name_id;
            plog(' ERROR Grade:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindGrade ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_grade_name_id;
        END IF; --}

        IF l_parm_type = 'BD' then --{
        OPEN c_dimension_name_id(p_value_name1,p_legislation_code);
        FETCH c_dimension_name_id INTO l_parameter_value;
        IF c_dimension_name_id%NOTFOUND THEN  --{
            CLOSE c_dimension_name_id;
            plog(' ERROR dimension:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindDimension ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_dimension_name_id;
        END IF; --}

        IF l_parm_type = 'BT' then --{
        OPEN c_balance_name_id(p_value_name1,p_legislation_code);
        FETCH c_balance_name_id INTO l_parameter_value;
        IF c_balance_name_id%NOTFOUND THEN  --{
            CLOSE c_balance_name_id;
            plog(' ERROR balance:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindBalance ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_balance_name_id;
        END IF; --}

        IF l_parm_type = 'P' then --{
        OPEN c_payment_name_id(p_value_name1,p_legislation_code);
        FETCH c_payment_name_id INTO l_parameter_value;
        IF c_payment_name_id%NOTFOUND THEN  --{
            CLOSE c_payment_name_id;
            plog(' ERROR payment type:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindPaymentType ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_payment_name_id;
        END IF; --}

        IF l_parm_type = 'UE' then --{
        OPEN c_user_entity_name_id(p_value_name1,p_legislation_code);
        FETCH c_user_entity_name_id INTO l_parameter_value;
        IF c_user_entity_name_id%NOTFOUND THEN  --{
            CLOSE c_user_entity_name_id;
            plog(' ERROR user_entity:'||p_value_name1||' not found ');
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','PARAMETER_VALUE');
            hr_utility.set_message_token('STEP','FindUserEntity ');
            hr_utility.raise_error;
        END IF; --}
        CLOSE c_user_entity_name_id;
        END IF; --}

        IF l_parm_type in ('KF','OTHER') then --{
           l_parameter_value_char := p_value_name1;
        ELSE l_parameter_value_char := to_char(l_parameter_value);
        END IF; --}

   PLOG('  return parameter_value:'||l_parameter_value_char);

   return l_parameter_value_char;

END GET_PARAMETER_VALUE;

FUNCTION lookup_balance_name ( p_balance_type_id in number) return varchar2 IS
   CURSOR csr_balance_name(p_balance_type_id NUMBER) IS

   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_type_id = p_balance_type_id;

   l_return VARCHAR2(80);

   begin
         OPEN csr_balance_name(p_balance_type_id);
         FETCH csr_balance_name INTO l_return;
         IF csr_balance_name%NOTFOUND THEN
            l_return := NULL;
         END IF;
         close csr_balance_name;
         return l_return;
   end lookup_balance_name;

FUNCTION lookup_balance_id ( p_balance_name in varchar2 , p_legislation_code in varchar2 )
         return varchar2 IS
   CURSOR csr_balance_id(p_balance_name VARCHAR2,
                         p_legislation_code VARCHAR2) IS
   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_name = p_balance_name
   AND   legislation_code = p_legislation_code;

   l_return VARCHAR2(80);

   begin
         OPEN csr_balance_id(p_balance_name, p_legislation_code);
         FETCH csr_balance_id INTO l_return;
         IF csr_balance_id%NOTFOUND THEN
            l_return := NULL;
         END IF;
         close csr_balance_id;
         return l_return;
   end lookup_balance_id;

FUNCTION id_to_name (
             p_legislation_code   in VARCHAR2
            ,p_context            in VARCHAR2
            ,p_column             in VARCHAR2
            ,p_column_value       in VARCHAR2 )
         return VARCHAR2
   IS
   CURSOR csr_element_name(p_element_type_id NUMBER) IS
   SELECT distinct element_name
   FROM pay_element_types_f
   WHERE element_type_id = p_element_type_id;

   CURSOR csr_element_id(p_element_name VARCHAR2,
                         p_legislation_code VARCHAR2) IS
   SELECT element_type_id
   FROM pay_element_types_f
   WHERE element_type_id = p_column_value
   AND   legislation_code = p_legislation_code;

   CURSOR csr_balance_name(p_balance_type_id NUMBER) IS
   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_type_id = p_balance_type_id;

   CURSOR csr_balance_id(p_balance_name VARCHAR2,
                         p_legislation_code VARCHAR2) IS
   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_name = p_balance_name
   AND   legislation_code = p_legislation_code;

   l_return VARCHAR2(80);


BEGIN
  l_return := p_column_value; -- defualt return the segment value.

  IF p_column_value is not null then  --{
     -- for specific context and columns swap an id for a name
     IF p_legislation_code = 'US' then -- {

        IF p_context = 'US_EARNINGS' then -- {
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_IMPUTED EARNINGS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_INVOLUNTARY DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION8','ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12',
                            'ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_NON-PAYROLL PAYMENTS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_PRE-TAX DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_PTO ACCRUALS' then
           IF p_column in  ('ELEMENT_INFORMATION10') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_SUPPLEMENTAL EARNINGS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}


        ELSIF p_context = 'US_TAX DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17',
                            'ELEMENT_INFORMATION18','ELEMENT_INFORMATION19') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}

        ELSIF p_context = 'US_VOLUNTARY DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_name(to_number(p_column_value));
           END IF; --}


        END IF; --}

     END IF; --} US
  END IF; --}
  return l_return;

END ID_TO_NAME;

FUNCTION name_to_id (
             p_legislation_code   in VARCHAR2
            ,p_context            in VARCHAR2
            ,p_column             in VARCHAR2
            ,p_column_value       in VARCHAR2 )
         return VARCHAR2
   IS
   CURSOR csr_element_name(p_element_type_id NUMBER) IS
   SELECT distinct element_name
   FROM pay_element_types_f
   WHERE element_type_id = p_element_type_id;

   CURSOR csr_element_id(p_element_name VARCHAR2,
                         p_legislation_code VARCHAR2) IS
   SELECT element_type_id
   FROM pay_element_types_f
   WHERE element_type_id = p_column_value
   AND   legislation_code = p_legislation_code;

   CURSOR csr_balance_name(p_balance_type_id NUMBER) IS
   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_type_id = p_balance_type_id;

   CURSOR csr_balance_id(p_balance_name VARCHAR2,
                         p_legislation_code VARCHAR2) IS
   SELECT balance_name
   FROM pay_balance_types
   WHERE balance_name = p_balance_name
   AND   legislation_code = p_legislation_code;

   l_return VARCHAR2(80);


BEGIN
  l_return := p_column_value; -- defualt return the segment value.

  IF p_column_value is not null then  --{
     -- for specific context and columns swap an id for a name
     IF p_legislation_code = 'US' then -- {

        IF p_context = 'US_EARNINGS' then -- {
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_IMPUTED EARNINGS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_INVOLUNTARY DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION8','ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12',
                            'ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_NON-PAYROLL PAYMENTS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_PRE-TAX DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_PTO ACCRUALS' then
           IF p_column in  ('ELEMENT_INFORMATION10') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_SUPPLEMENTAL EARNINGS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION12','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}


        ELSIF p_context = 'US_TAX DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION15','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17',
                            'ELEMENT_INFORMATION18','ELEMENT_INFORMATION19') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}

        ELSIF p_context = 'US_VOLUNTARY DEDUCTIONS' then
           IF p_column in  ('ELEMENT_INFORMATION10','ELEMENT_INFORMATION11','ELEMENT_INFORMATION12','ELEMENT_INFORMATION13',
                            'ELEMENT_INFORMATION14','ELEMENT_INFORMATION16','ELEMENT_INFORMATION17') then  -- {
              l_return := lookup_balance_id(p_column_value,p_legislation_code);
           END IF; --}


        END IF; --}

     END IF; --} US
  END IF; --}
  return l_return;

END NAME_TO_ID;

PROCEDURE UNCOMPILE_FORMULAS ( P_ROUTE_ID in number default null
                              ,P_USER_NAME in VARCHAR2 default null
                              ,P_LEGISLATION_CODE in VARCHAR2 default null
                              ,P_FORMULA_ID in NUMBER default null) is
-- need to uncompile formula when a update is made to a route, dbitem or formula

-- given a route id find formulas using that route and delete compiled info and
-- fdi usages for that.  Used when updating a route.
CURSOR c_formula_id ( p_route_id number) is
    select /*+ ORDERED
               INDEX(C FF_USER_ENTITIES_FK1)
               INDEX(B FF_DATABASE_ITEMS_FK1)
               INDEX(A FF_FDI_USAGES_F_N50) */
          distinct a.formula_id
     from ff_user_entities c,
          ff_database_items b,
          ff_fdi_usages_f a
    where a.item_name = b.user_name
    and   a.usage     = 'D'
    and   b.user_entity_id = c.user_entity_id
    and   c.route_id  = p_route_id;


cursor c_formulas_using_dbi ( p_user_name varchar2, p_legislation_code varchar2)
is
   -- dbitem can be global or legislation (not user) so checks are limitted to
   -- seed database items.  However user formulas can see core and owning legislation
   -- code dbitems.
    select distinct fdi.formula_id from
           ff_fdi_usages_f fdi
          ,ff_database_items dbi
          ,ff_user_entities ue
          ,ff_formulas_f f
          where fdi.ITEM_NAME = p_user_name
          and   fdi.USAGE = 'D'
          and   ue.USER_ENTITY_ID = dbi.USER_ENTITY_ID
          and   dbi.USER_NAME = p_user_name
          and   nvl(ue.legislation_code,'z') = nvl(p_legislation_code,'z')
          and   f.formula_id = fdi.formula_id
          and   (( f.legislation_code = p_legislation_code )
                   or ( f.business_group_id in ( select business_group_id from
                                                        per_business_groups bg
                                                 where bg.legislation_code = p_legislation_code )));

    BEGIN
      IF p_route_id is not null then
          for getrec in c_formula_id(p_route_id ) loop
              delete from ff_fdi_usages_f where formula_id = getrec.formula_id;
              delete from ff_compiled_info_f where formula_id = getrec.formula_id;
          end loop;
      END IF;

      IF p_user_name is not null then
          for getrec in c_formulas_using_dbi(p_user_name, p_legislation_code ) loop
              delete from ff_fdi_usages_f where formula_id = getrec.formula_id;
              delete from ff_compiled_info_f where formula_id = getrec.formula_id;
          end loop;
      END IF;

      IF p_formula_id is not null then
              delete from ff_fdi_usages_f where formula_id = p_formula_id;
              delete from ff_compiled_info_f where formula_id = p_formula_id;
      END IF;

END UNCOMPILE_FORMULAS;

END PAY_SEED_UTL;

/
