--------------------------------------------------------
--  DDL for Package Body HR_PAY_BASIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_BASIS" AS
/* $Header: pepbasis.pkb 120.1 2006/01/06 10:06:26 rthiagar noship $ */
/*
 ************************************************************************
 *                                                                      *
 *Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved*
 ************************************************************************ */
/*
 Name        : hr_pay_basis (BODY)

 Description : This package declares procedures required to
               INSERT, UPDATE and DELETE pay bases:

               PER_PAY_BASES
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 ------------------------------------------------------------
 80.0    11-NOV-1993 msingh             Date Created
 80.1    20-DEC-1993 msingh   G311      chk_duplicate_element and
                                        chk_input_val_rate_uk take into
                                        account template elements
                                        spanning business groups
 70.1    23-NOV-1993 rfine		Suppressed index on business_group_id
 70.2	 01-MAR-1994 gpaytonm		Removed reference to bg_id in
					chk_input_val_rate_uk
 70.4    20-NOV-1996 fshojaas           The bg_id was added to the
					chk_input_val_rate_uk.
					This change was done to fix bug #412780.
 115.2  16-Sep-2000 mmillmor  1385192   Added element_type_id output and
                                        translated element and input value
 115.3  09-Dec-2002 pkakar              Added nocopy to parameters
 115.4  05-Jan-2006 rthiagar  4894015   Changed the use of per_assignments_f
                                        to per_all_assignments_f in
                                        chk_basis_assignment.
--------------------------------------------------------------- */
--
FUNCTION generate_unique_id RETURN NUMBER IS
--
  v_pay_basis_id    NUMBER;
--
  Begin
      hr_utility.set_location('hr_pay_basis.generate_unique_id',1);
   Begin
      select per_pay_bases_s.nextval
      into   v_pay_basis_id
      from   sys.dual;
  --
     exception
     when NO_DATA_FOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_salary_data',1 );
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    End;
  --
  --
  return v_pay_basis_id;
--
  end generate_unique_id;
--
-----------------------------------------------------------------------
PROCEDURE insert_row (p_pay_basis_id      IN OUT NOCOPY NUMBER,
                      p_business_group_id NUMBER,
                      p_name              VARCHAR2,
                      p_pay_basis         VARCHAR2,
                      p_input_value_id    NUMBER,
                      p_rate_id           NUMBER,
                      p_rate_basis        VARCHAR2) IS
 --
 --
   Begin
   --
     hr_utility.set_location ('hr_salary_date.insert_pay_basis',1);
     --
     Begin
     --
      p_pay_basis_id := generate_unique_id;
      --
      -- insert row
      --
      INSERT INTO PER_PAY_BASES(pay_basis_id,
                                business_group_id,
                                name,
                                pay_basis,
                                input_value_id,
                                rate_id,
                                rate_basis,
                                last_update_date,
                                last_updated_by,
                                last_update_login,
                                created_by,
                                creation_date)
     VALUES                     (p_pay_basis_id ,
                                 p_business_group_id,
                                 p_name,
                                 p_pay_basis,
                                 p_input_value_id,
                                 p_rate_id,
                                 p_rate_basis,
                                 trunc(sysdate),
                                 -1,
                                 -1,
                                 -1,
                                 trunc(sysdate));
    --
   exception
   when NO_DATA_FOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_pay_basis.insert_row',1 );
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    End;
 End insert_row;
--
-------------------------------------------------------------------
PROCEDURE  chk_name_uniqueness
                          (p_business_group_id    IN   NUMBER
                          ,p_name                 IN   VARCHAR2
                          ,p_row_id               IN   VARCHAR2  DEFAULT NULL
                          ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
  duplicate VARCHAR2(1) := 'N';
--
  BEGIN
--
--  hr_utility.set_location('hr_pay_basis.chk_name_uniqueness',1);
--
     BEGIN
--
      SELECT 'Y'
      INTO   duplicate
      FROM   sys.dual
      WHERE EXISTS
        (select 'Y'
         from  per_pay_bases
         where upper(p_name)     = upper(name)
           and business_group_id + 0 = p_business_group_id
           and (p_row_id <> rowid
                or p_row_id is null)
         );
--
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
--
      END;
    if duplicate = 'Y' then
      hr_utility.set_message(801 ,'HR_13017_SAL_BASIS_DUP_NAME');
      hr_utility.raise_error;
    end if;
--
 END chk_name_uniqueness;
--
-------------------------------------------------------------------------------
--
PROCEDURE chk_input_val_rate_uk
--
                               (
                                p_input_value_id     IN   NUMBER
                               ,p_rate_id            IN   NUMBER DEFAULT NULL
                               ,p_row_id             IN   VARCHAR2 DEFAULT NULL
                               ,p_business_group_id  IN   NUMBER
                                )
                               IS
--
  duplicate    VARCHAR2(1) := 'N';
--
  BEGIN
--
--  hr_utility.set_location('hr_pay_basis.chk_input_val_rate_uk',1);
--
    BEGIN
--
      SELECT 'Y'
      INTO   duplicate
      FROM   sys.dual
      WHERE EXISTS
        (select 'Y'
         from  per_pay_bases
         where input_value_id = p_input_value_id
         and   nvl(p_rate_id,-1) = nvl(rate_id,-1)
	 and   p_business_group_id = business_group_id
         and   (p_row_id <> rowid
                or p_row_id IS NULL)
         );
--
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
     END;
--
      if duplicate = 'Y' then
         hr_utility.set_message(801,'HR_13018_SAL_IV_RATE_DUP');
         hr_utility.raise_error;
       end if;
--
   END chk_input_val_rate_uk;
--
----------------------------------------------------------------------------
--
FUNCTION chk_duplicate_element
                          (
                           p_element_type_id      IN   NUMBER
                          ,p_row_id               IN   VARCHAR2
                          ,p_business_group_id    IN   NUMBER
                          ) RETURN BOOLEAN  IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
--
  v_validation_chk    VARCHAR2(1);
--
  BEGIN
--
    v_validation_chk := 'N';
--  hr_utility.set_location('hr_pay_basis.chk_duplicate_element',1);
--
    BEGIN
--
      SELECT 'Y'
      INTO v_validation_chk
      FROM   sys.dual
      WHERE EXISTS
        (select 'Y'
         from  per_pay_bases ppb,
               pay_input_values_f piv
         where piv.element_type_id = p_element_type_id
         and   ppb.input_value_id = piv.input_value_id
         and   (p_row_id <> ppb.rowid
                  or p_row_id is null)
         and   ppb.business_group_id + 0 = p_business_group_id
        );
--
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
     END;
--
     RETURN (v_validation_chk = 'N');
--
   END chk_duplicate_element;
--
-----------------------------------------------------------------------------
--
PROCEDURE chk_element_entry(
                             p_input_value_id       IN   NUMBER
                           ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
--
  v_validation_chk    VARCHAR2(1);
--
  BEGIN
--
    v_validation_chk := 'N';
--  hr_utility.set_location('hr_pay_basis.chk_element_entry',1);
--
--
    BEGIN
--
      SELECT 'Y'
      INTO   v_validation_chk
      FROM   sys.dual
      WHERE EXISTS
      (select 'Y'
       from   pay_element_entry_values_f pev
       where  pev.input_value_id = p_input_value_id
       );
--
      EXCEPTION
--
       WHEN NO_DATA_FOUND THEN NULL;
--
    END;
--
--
   if v_validation_chk = 'Y'
     then
      hr_utility.set_message(801,'HR_13019_SAL_ENTRY_EXISTS');
      hr_utility.raise_error;
    end if;
--
   END chk_element_entry;
--
-----------------------------------------------------------------------------
Procedure chk_basis_assignment
                          (
                          p_pay_basis_id         IN   NUMBER
                          ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
--
  v_validation_chk    VARCHAR2(1);
--
  BEGIN
--
    v_validation_chk := 'N';
    hr_utility.set_location('hr_pay_basis.chk_basis_assignment',1);
--
--
    BEGIN
--
      SELECT 'Y'
      INTO   v_validation_chk
      FROM   sys.dual
      WHERE EXISTS
      (select 'Y'
       from   per_all_assignments_f ass
       where  ass.pay_basis_id = p_pay_basis_id
       );
--
      EXCEPTION
--
       WHEN NO_DATA_FOUND THEN NULL;
--
    END;
    --
--
    if v_validation_chk = 'Y'
     then
      hr_utility.set_message(801,'HR_13020_SAL_ASG_EXISTS');
      hr_utility.raise_error;
    end if;
--
   END chk_basis_assignment;
--
----------------------------------------------------------------------------
--
Function populate_basis (p_basis_code  IN VARCHAR2)
                     return VARCHAR2 IS
--
  v_basis_meaning  VARCHAR2(80);
--
  Begin
--
   hr_utility.set_location('hr_pay_basis.populate_basis',1);
  --
   Begin
   select hlu.meaning into v_basis_meaning
   from   hr_lookups hlu
   where  hlu.lookup_code = p_basis_code
   and    hlu.lookup_type = 'PAY_BASIS';
--
   EXCEPTION
--
   WHEN NO_DATA_FOUND THEN
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_pay.basis.populate_basis');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
   end;
--
   RETURN v_basis_meaning;
--
  End populate_basis;
-----------------------------------------------------------------------------
Procedure  populate_element_iv_name (p_input_value_id   IN    NUMBER,
                                     p_session_date     IN    DATE,
                                     p_iv_name            OUT NOCOPY VARCHAR2,
                                     p_element_type_id    OUT NOCOPY VARCHAR2,
                                     p_element_name       OUT NOCOPY VARCHAR2)
                                   IS
--
--
   Begin
--
   hr_utility.set_location ('hr_pay_basis.populate_element_iv_name',1);
   --
   Begin
   --
    select pivtl.name,
           pettl.element_name,
           pet.element_type_id
    into   p_iv_name,
           p_element_name,
           p_element_type_id
    from   pay_input_values_f piv,
           pay_input_values_f_tl pivtl,
           pay_element_types_f pet,
           pay_element_types_f_tl pettl
    where  pet.element_type_id = piv.element_type_id
    and    pet.element_type_id = pettl.element_type_id
    and    p_session_date between pet.effective_start_date
                              and pet.effective_end_date
    and    piv.input_value_id = p_input_value_id
    and    pivtl.input_value_id = p_input_value_id
    and    p_session_date between piv.effective_start_date
                              and piv.effective_end_date
    and    pivtl.language=userenv('LANG')
    and    pettl.language=userenv('LANG');
--
    EXCEPTION
--
    WHEN NO_DATA_FOUND THEN
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_pay.basis.populate_iv_name');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
    end;
--
  End populate_element_iv_name;
--
-----------------------------------------------------------------------
Function populate_rate_name   (p_rate_id    IN NUMBER)
                                 RETURN VARCHAR2 Is
--
  v_rate_name    VARCHAR2(80);
--
  Begin
  --
  hr_utility.set_location('hr_pay_basis.populate_rate_name',1);
   Begin
--
     select name into v_rate_name
     from   pay_rates
     where  rate_id = p_rate_id;
--
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_pay.basis.populate_rate_name');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
     end;
--
     RETURN v_rate_name;
--
  end populate_rate_name;
--
------------------------------------------------------------------------
--
Procedure populate_iv_valid_dates   (
                                  p_input_value_id IN     NUMBER,
                                  p_start_date        OUT NOCOPY DATE,
                                  p_end_date          OUT NOCOPY DATE) IS
--
  Begin
  --
    hr_utility.set_location ('hr_pay_basis.populate_valid_dates',1);
    --
    Begin
    --
     select min(effective_start_date),
            max(effective_end_date)
     into   p_start_date,
            p_end_date
     from   pay_input_values_f
     where  input_value_id = p_input_value_id;
     --
     exception
      when NO_DATA_FOUND
       then
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_pay.basis.populate_rate_name');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
     end;
   --
  end populate_iv_valid_dates;
--
--------------------------------------------------------------------
Procedure retreive_fields ( p_session_date     IN       DATE,
                            p_basis_code       IN       VARCHAR2,
                            p_basis                OUT NOCOPY  VARCHAR2,
                            p_element_type_id      OUT NOCOPY  NUMBER,
                            p_element_name         OUT NOCOPY  VARCHAR2,
                            p_input_value_id   IN       NUMBER,
                            p_iv_name              OUT NOCOPY  VARCHAR2,
                            p_rate_id          IN       NUMBER,
                            p_rate_name            OUT NOCOPY  VARCHAR2,
                            p_rate_basis_code  IN       VARCHAR2,
                            p_rate_basis           OUT NOCOPY  VARCHAR2,
                            p_start_date           OUT NOCOPY  DATE,
                            p_end_date             OUT NOCOPY  DATE) IS
--
  v_valid    VARCHAR2(1);
  --
  Begin
   --
   hr_utility.set_location ('hr_pay_basis.retreive_fields',1);
   --
   Begin
     -- check to see if salary basis reteived is valid for the given session
     -- date
      select 'V'
      into v_valid
      from sys.dual
      where exists
          (select 1
           from pay_input_values_f
           where input_value_id = p_input_value_id
           and p_session_date between effective_start_date
                              and effective_end_date);
      --
      exception
      when no_data_found then
           hr_utility.set_message(801, 'HR_13027_SAL_BAS_DATE_INVALID');
           hr_utility.raise_error;
     end;

   p_basis := populate_basis (p_basis_code);
   --
   populate_element_iv_name  (p_input_value_id,
                              p_session_date,
                              p_iv_name,
                              p_element_type_id,
                              p_element_name);
   --
   populate_iv_valid_dates (p_input_value_id,
                            p_start_date,
                            p_end_date);
   --
   if (p_rate_id is not null)
    then
      p_rate_name  := populate_rate_name (p_rate_id);
      p_rate_basis := populate_basis (p_rate_basis_code);
    end if;
   --
  End retreive_fields;
--
------------------------------------------------------------------------
--
Procedure validate_insert (p_business_group_id    NUMBER,
                           p_row_id               VARCHAR2,
                           p_name                 VARCHAR2,
                           p_input_value_id       NUMBER,
                           p_rate_id              NUMBER,
                           p_pay_basis_id   IN OUT NOCOPY NUMBER) IS
--
  Begin
  --
    chk_name_uniqueness (p_business_group_id,
                         p_name,
                         p_row_id);
    --
    chk_input_val_rate_uk (p_input_value_id,
                           p_rate_id,
                           p_row_id,
                           p_business_group_id);
    --
    p_pay_basis_id := generate_unique_id;
    --
  End validate_insert;
--
-------------------------------------------------------------------------
--
Procedure validate_update (p_row_id     VARCHAR2,
                           p_input_value_id  NUMBER,
                           p_pay_basis       VARCHAR2) IS
--
 v_pay_basis   VARCHAR2 (30);
 v_input_value_id   NUMBER;
 --
 CURSOR C IS SELECT pay_basis, input_value_id
             from per_pay_bases
             where rowid = p_row_id;

 --
 Begin
  hr_utility.set_location ('hr_pay_basis.validate_update',1);
  --
  OPEN C;
  Fetch C into v_pay_basis, v_input_value_id;
  if (C%NOTFOUND)
    then
     close C;
     raise NO_DATA_FOUND;
  end if;
  --
  close C;
  --
  if (v_pay_basis <> p_pay_basis)
    or (v_input_value_id <> p_input_value_id)
  then
   chk_element_entry(v_input_value_id);
  end if;
  --
  exception
       when no_data_found
         then
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_pay_basis.validate_update');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
  end;


END hr_pay_basis;

/
