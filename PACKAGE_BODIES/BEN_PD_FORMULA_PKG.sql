--------------------------------------------------------
--  DDL for Package Body BEN_PD_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PD_FORMULA_PKG" as
/* $Header: beffnpkg.pkb 120.1 2006/05/02 16:38:51 ashrivas noship $ */

---------------------------------------------------

PROCEDURE remove_formula_from_FF
     ( p_formula_name in varchar2) is

begin
DELETE FROM ff_formulas_f
WHERE formula_name = p_formula_name;
exception
     when no_data_found then
      -- No record found to be deleted.
      null;
end;

---------------------------------------------------
FUNCTION copy_formula_to_FF
     (
       p_business_group_id in number,
       p_legislation_code in varchar2,
       p_formula_id       in number,
       p_formula_type_id  in number,
       p_formula_name in varchar2,
       p_description  in varchar2,
       p_effective_start_date in date,
       p_effective_end_date in date,
       p_formula_text in long ) return number is

l_formula_id     number(15);
l_rowid          varchar2(255);
l_formula_name   varchar2(255);
l_lastUpdateDate date;

CURSOR ffRow IS SELECT rowId FROM ff_formulas_f
               WHERE  formula_id = p_formula_id
               and    p_effective_start_date between effective_start_date and effective_end_date;

BEGIN
l_formula_name := p_formula_name;

if (p_formula_id IS NULL) THEN
     select ff_formulas_s.nextval
     into l_formula_id
     from sys.dual;

     ff_formulas_f_pkg.insert_row(
      x_rowid                 => l_rowid,
      x_formula_id            => l_formula_id,
      x_effective_start_date  => p_effective_start_date,
      x_effective_end_date    => p_effective_end_date,
      x_business_group_id     => p_business_group_id,
      x_legislation_code      => p_legislation_code,
      x_formula_type_id       => p_formula_type_id,
      x_formula_name          => l_formula_name,
      x_description           => p_description,
      x_formula_text          => p_formula_text,
      x_sticky_flag           => 'Y',
      x_last_update_date      => l_lastUpdateDate
      );
else
   l_formula_id  := p_formula_id;
   open  ffRow;
   Fetch ffRow into l_rowid;
   close ffRow;

   ff_formulas_f_pkg.update_row(
      x_rowid                 => l_rowid,
      x_formula_id            => l_formula_id,
      x_effective_start_date  => p_effective_start_date,
      x_effective_end_date    => p_effective_end_date,
      x_business_group_id     => p_business_group_id,
      x_legislation_code      => p_legislation_code,
      x_formula_type_id       => p_formula_type_id,
      x_formula_name          => p_formula_name,
      x_description           => p_description,
      x_formula_text          => p_formula_text,
      x_sticky_flag           => 'Y',
      x_last_update_date      => l_lastUpdateDate
      );
  end if;

return l_formula_id;
END;

FUNCTION copy_formula_STAGE_TO_FF
     ( p_copy_entity_result_id IN number ) return number is
cursor csr1 is
select information4 BUSINESS_GROUP_ID,
       information11 legislation_code,
       information161  FORMULA_TYPE_ID,
       information111 FORMULA_NAME,
       information151 DESCRIPTION,
       information325 FORMULA_TEXT,
       information1 ff_formula_id
from ben_copy_entity_results
where copy_entity_result_id = p_copy_entity_result_id;
l_formula_id number(15);
l_rowid varchar2(255);
l_lastUpdateDate date;
r_fff  csr1%RowType;

begin
    open csr1;
    fetch csr1 into r_fff;
    close csr1;

      if (r_fff.ff_formula_id is null) then
             select ff_formulas_s.nextval
             into l_formula_id
             from sys.dual;

    ff_formulas_f_pkg.insert_row(
      x_rowid                 => l_rowid,
      x_formula_id            => l_formula_id,
      x_effective_start_date  => sysdate,
      x_effective_end_date    => hr_general.end_of_time,
      x_business_group_id     => r_fff.business_group_id,
      x_legislation_code      => r_fff.legislation_code,
      x_formula_type_id       => r_fff.formula_type_id,
      x_formula_name          => r_fff.formula_name,
      x_description           => r_fff.description,
      x_formula_text          => r_fff.formula_text,
      x_sticky_flag           => 'Y',
      x_last_update_date      => l_lastUpdateDate
      );
   else -- Formula Already created, now update it instead
   l_formula_id :=  r_fff.ff_formula_id;
    ff_formulas_f_pkg.update_row(
      x_rowid                 => l_rowid,
      x_formula_id            => l_formula_id,
      x_effective_start_date  => sysdate,
      x_effective_end_date    => hr_general.end_of_time,
      x_business_group_id     => r_fff.business_group_id,
      x_legislation_code      => r_fff.legislation_code,
      x_formula_type_id       => r_fff.formula_type_id,
      x_formula_name          => r_fff.formula_name,
      x_description           => r_fff.description,
      x_formula_text          => r_fff.formula_text,
      x_sticky_flag           => 'Y',
      x_last_update_date      => l_lastUpdateDate
      );

  end if;

return l_formula_id;
     end;




  function compile_formula(
    p_formula_id     in            number,
    p_effective_date in            date ) return varchar2  is

   l_retval  number;
    l_timeout number := 120;
    l_outcome varchar2(1000);
    l_message varchar2(1000);
    l_return_status varchar2(10);
    --
  begin
    --
    -- Enable multi-messaging
    hr_multi_message.enable_message_list;
    --
    l_retval := fnd_transaction.synchronous(
      timeout     => l_timeout,
      outcome     => l_outcome,
      message     => l_message,
      application => 'FF',
      program     => 'FFTMSINGLECOMPILE',
      arg_1       => to_char(p_formula_id),
      arg_2       => fnd_date.date_to_canonical(p_effective_date)
      );
    --
--    hr_utility.trace('!!! l_retval: '||to_char(l_retval));
    -- Return values are either 0, 1, 2 or 3
    -- 0 Indicates success - although formula compilation may have failed
    -- 1 Indicates timeout error
    -- 2 Indicates no transaction manager available
    -- 3 Indicates some other error
    if l_retval <> 0  or l_outcome <> 'SUCCESS' then
      --
      if l_retval = 1 then
        --
        -- Timeout error
        hr_utility.set_message(8302, 'PQH_TX_MGR_TIMEOUT_ERROR');
        hr_utility.set_message_token('ERROR_MESSAGE', l_message);
        if hr_multi_message.exception_add then
          hr_utility.raise_error;
        end if;
      elsif l_retval = 2 then
        --
        -- No transaction manager error
        hr_utility.set_message(8302, 'PQH_TX_MGR_NOTFOUND_ERROR');
        hr_utility.set_message_token( 'ERROR_MESSAGE', l_message);
        if hr_multi_message.exception_add then
          hr_utility.raise_error;
        end if;
      elsif l_retval = 3 then
        --
        -- Generic error
--        hr_utility.trace('!!! Generic error!!!');
        hr_utility.set_message(8302, 'PQH_TX_MGR_OTHER_ERROR');
        hr_utility.set_message_token( 'ERROR_MESSAGE', l_message);
        if hr_multi_message.exception_add then
          hr_utility.raise_error;
        end if;
      else

        --
        -- Formula compilation error
        -- Get compilation error details from fnd_message.get
        hr_utility.set_message(805, 'FF_WIZ_BUILD_VERIFY_FAILURE');
        hr_utility.set_message_token( 'ERROR_MESSAGE', l_message);
        if hr_multi_message.exception_add then
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    --
    -- Get the return status and disable multi-messaging
--    hr_utility.trace('!!! get return status and disable mult-messaging');
    l_return_status := hr_multi_message.get_return_status_disable;
    return l_return_status;
    --
  exception
    --
    when hr_multi_message.error_message_exist then
      l_return_status := hr_multi_message.get_return_status_disable;
      return l_return_status||'O';
    --
    when others then raise;
    --
  end compile_formula;

function get_formula_text (p_formula_id number, p_effective_start_date date)
return clob is
l_clob clob;

begin

  delete from ben_copy_entity_results
  where copy_entity_result_id = -999999;

  insert into ben_copy_entity_results (
         COPY_ENTITY_RESULT_ID,
         COPY_ENTITY_TXN_ID,
         RESULT_TYPE_CD,
         OBJECT_VERSION_NUMBER,
         INFORMATION325)
  select -999999, -999999, 'COPY_FF',1, to_lob(formula_text)
  from  ff_formulas_f
  where formula_id = p_formula_id
  and   p_effective_start_date between effective_start_date and effective_end_date;

  select information325 into l_clob from ben_copy_entity_results
  where copy_entity_result_id = -999999;

--  rollback; can't use it, the formula text get's lost.
  return l_clob;
end;

--
  FUNCTION maintain_formula(p_formula_id           IN NUMBER
                         ,p_effective_date       IN DATE
                         ,p_effective_start_date IN DATE
                         ,p_effective_end_date   IN DATE
                         ,p_business_group_id    IN NUMBER
                         ,p_legislation_code     IN VARCHAR2
                         ,p_formula_type_id      IN NUMBER
                         ,p_formula_name         IN VARCHAR2
                         ,p_description          IN VARCHAR2
                         ,p_formula_text         IN LONG
                         ,p_sticky_flag          IN VARCHAR2
                         ,p_compile_flag         IN VARCHAR2
                         ,p_dml_operation        IN VARCHAR2
                         ,p_datetrack_mode       IN VARCHAR2)
  RETURN varchar2 IS
  --
  /*
  --Cursor to fetch formula details
    CURSOR c_formula IS
    SELECT effective_start_date, effective_end_date
      FROM ff_formulas_f
     WHERE formula_id = p_formula_id
       AND business_group_id = p_business_group_id
       AND TRUNC(p_effective_date) BETWEEN effective_start_date AND effective_end_date;
*/
  --
  --Local variables
    l_formula_id           NUMBER;
    l_dml_operation        VARCHAR2(20);
    l_datetrack_mode       VARCHAR2(50);
    l_correction           BOOLEAN;
    l_update               BOOLEAN;
    l_update_override      BOOLEAN;
    l_update_change_insert BOOLEAN;
--    l_effective_start_date DATE;
--    l_effective_end_date   DATE;
--
   mesg varchar2(4000);
  BEGIN
  --
    IF p_formula_id IS NULL THEN
      SELECT ff_formulas_s.nextval
        INTO l_formula_id
        FROM sys.dual;
--      l_effective_start_date := TRUNC(p_effective_date);
--      l_effective_end_date   := HR_GENERAL.end_of_time;
    ELSE
      l_formula_id := p_formula_id;
    --
/*
      OPEN c_formula;
      FETCH c_formula INTO l_effective_start_date, l_effective_end_date;
      CLOSE c_formula;
*/
    --
    END IF;
  --
/*
  insert into ns_temp values ('Formula Id: '||p_formula_id);
    insert into ns_temp values ('p_effective_start_date Id: '||p_effective_start_date);
  insert into ns_temp values ('p_effective_end_date Id: '||p_effective_end_date);
  insert into ns_temp values ('p_business_group_id Id: '||p_business_group_id);
  insert into ns_temp values ('p_legislation_code Id: '||p_legislation_code);
  insert into ns_temp values ('p_formula_type_id Id: '||p_formula_type_id);
  insert into ns_temp values ('p_formula_name Id: '||p_formula_name);
  insert into ns_temp values ('p_dml_operation Id: '||p_dml_operation);
  insert into ns_temp values ('p_datetrack_mode Id: '||p_datetrack_mode);
*/

    BEN_PD_COPY_TO_BEN_ONE.create_or_update_ff
                          (p_formula_id           => l_formula_id
                          ,p_effective_start_date => p_effective_start_date
                          ,p_effective_end_date   => p_effective_end_date
                          ,p_business_group_id    => p_business_group_id
                          ,p_legislation_code     => p_legislation_code
                          ,p_formula_type_id      => p_formula_type_id
                          ,p_formula_name         => p_formula_name
                          ,p_description          => p_description
                          ,p_formula_text         => p_formula_text
                          ,p_sticky_flag          => p_sticky_flag
                          ,p_compile_flag         => p_compile_flag
                          ,p_last_update_date     => SYSDATE
                          ,p_last_updated_by      => -1
                          ,p_last_update_login    => -1
                          ,p_created_by           => -1
                          ,p_creation_date        => SYSDATE
                          ,p_process_date         => TRUNC(p_effective_date)
                          ,p_dml_operation        => p_dml_operation
                          ,p_datetrack_mode       => p_datetrack_mode);
  --
  commit;
  /*
  If creating the formula, commit it irrespective verify or finish

  if (p_formula_id = null) then
    commit;
  end if;
    */

  mesg := compile_formula(l_formula_id, p_effective_date);

  /*
    Delete formula if new formula and mode is verify

  if (p_formula_id = null --AND p_mode = 'VERIFY'
   ) then
  declare
  l_rowid  varchar2(100);
   begin
     select rowid into l_rowid
     from ff_formulas_f
     where formula_id = p_formula_id
     and  p_effective_date between effective_start_date and effective_end_date;

     ff_formulas_f_pkg.delete_row(
      x_rowid                 => l_rowid,
      x_formula_id            => p_formula_id,
      x_dt_delete_mode        => 'DELETE',
      x_validation_start_date => p_effective_date,
      x_validation_end_date   => null,
      x_effective_date        => p_effective_date
      );
--      commit;
   end;
  end if;
*/

  return (mesg);
--    RETURN l_formula_id;
  --
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END maintain_formula;
/*--
  Function to copy the formula into staging table and return the primary key
  This key will be used to execute the query in front end.
*/

  FUNCTION copy_formula_result(p_copy_entity_txn_id   IN NUMBER
                              ,p_formula_id           IN NUMBER
                              ,p_effective_date       IN DATE
                              ,p_business_group_id    IN NUMBER)
  RETURN NUMBER IS
  --
  --Cursor to fetch copy_entity_result_id
    CURSOR c_copy_result IS
    SELECT copy_entity_result_id
          ,dml_operation
          ,datetrack_mode
      FROM ben_copy_entity_results
     WHERE copy_entity_txn_id = p_copy_entity_txn_id
       AND information1       = p_formula_id
       AND ( information4       = p_business_group_id OR
             ( p_business_group_id is null AND information4 is null))
       AND p_effective_date BETWEEN information2 AND information3
       AND table_alias        = 'FFF'
       ORDER By copy_entity_result_id desc;
  --
  --Local Variables
    l_copy_entity_result_id NUMBER;
    l_object_version_number NUMBER;
    l_dml_operation         VARCHAR2(100);
    l_datetrack_mode        VARCHAR2(100);
  --
  BEGIN
  --
    l_copy_entity_result_id := null;
    l_object_version_number := null;
  --
  --Call API
    BEN_PLAN_DESIGN_PROGRAM_MODULE.create_formula_result
                                  (p_copy_entity_result_id => l_copy_entity_result_id
                                  ,p_copy_entity_txn_id    => p_copy_entity_txn_id
                                  ,p_formula_id            => p_formula_id
                                  ,p_business_group_id     => p_business_group_id
                                  ,p_object_version_number => l_object_version_number
                                  ,p_effective_date        => TRUNC(p_effective_date));
    OPEN c_copy_result;
    FETCH c_copy_result INTO l_copy_entity_result_id, l_dml_operation, l_datetrack_mode;
    CLOSE c_copy_result;

    update ben_copy_entity_results
       set number_of_copies = 0,
           status           = 'INVALID'
     where copy_entity_result_id = l_copy_entity_result_id;
     commit;

    RETURN l_copy_entity_result_id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END copy_formula_result;
--
  FUNCTION is_formula_verified (p_formula_id  IN NUMBER
                            ,p_effective_date IN DATE ) RETURN VARCHAR2 IS
   CURSOR verif IS
   SELECT 'Y'
   FROM FF_COMPILED_INFO_F
   WHERE formula_id = p_formula_id
   AND   p_effective_date between effective_start_date and effective_end_date;
   --
   l_verified varchar2(10);
   --
  BEGIN
     IF (p_formula_id IS NULL) THEN
       l_verified := 'N';
     ELSE
       OPEN verif;
       FETCH verif INTO l_verified;
        IF verif%NOTFOUND THEN
           l_verified := 'N';
        END IF;
       CLOSE verif;
      END IF;

      return l_verified;

  END is_formula_verified;

 /*
  * Procedure to check the length of the formula,  if it is more than
  * 32K, an error will be displayed.
  */
  PROCEDURE formula_length_check (
                             p_formula_id  IN NUMBER
                            ,p_effective_date IN DATE ) IS
    l_formula_text clob;
  BEGIN
    l_formula_text := get_formula_text (p_formula_id , p_effective_date );

    if (dbms_lob.getlength(l_formula_text) > 32512) then
       hr_utility.set_message(8302,'PQH_FF_TEXT_MORETHAN_32K');
       hr_utility.raise_error;
    end if;

  END formula_length_check;


END; -- Package Body BEN_PD_FORMULA_PKG

/
