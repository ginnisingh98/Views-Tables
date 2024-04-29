--------------------------------------------------------
--  DDL for Package Body PAY_PAYWSDAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYWSDAS_PKG" as
/* $Header: pywsdas1.pkb 120.1 2005/12/23 02:43:19 arashid noship $ */
--
/*
 * NAME
 *   core_fetch_dbi_info
 *
 * DESCRIPTION
 *   Internal routine containing common code to fetch database item
 *   information.
 */
procedure core_fetch_dbi_info
(p_business_group_id in number
,p_legislation_code in varchar2
,p_formula_type_id in number
,p_operand_value in varchar2
,p_data_type out nocopy varchar2
,p_null_allowed out nocopy varchar2
,p_notfound_allowed out nocopy varchar2
) is
cursor csr_dbitl(p_operand_value in varchar2) is
select dbitl.user_name
,      dbitl.user_entity_id
from   ff_database_items_tl dbitl
where  dbitl.translated_user_name = p_operand_value
;
begin
  --
  -- Exceptions will be passed up for handling in the calling code.
  --
  begin
    select di.data_type
    ,      di.null_allowed_flag
    ,      ue.notfound_allowed_flag
    into   p_data_type
    ,      p_null_allowed
    ,      p_notfound_allowed
    from   ff_database_items di
    ,      ff_user_entities ue
    ,      ff_routes fr
    where  di.user_name = p_operand_value
    and    ue.user_entity_id = di.user_entity_id
    and    (
             (ue.business_group_id is null and ue.legislation_code is null) or
             ue.legislation_code = p_legislation_code or
             ue.business_group_id = p_business_group_id
           )
    and    fr.route_id = ue.route_id
    and    not exists
           (
             select  context_id
             from    ff_route_context_usages rcu
             where   rcu.route_id = fr.route_id
             minus
             select  context_id
             from    ff_ftype_context_usages fcu
             where   fcu.formula_type_id = p_formula_type_id
           )
    ;

    --
    -- Got a match.
    --
    return;
  exception
    when no_data_found then
      if ff_dbi_utils_pkg.translations_supported(p_legislation_code) then
        --
        -- For the translated database item case use a cursor FOR-loop to return
        -- the tiny fraction of rows from ff_database_items_tl. The code can then
        -- match against ff_database_items, ff_user_entities etc. more efficiently.
        --
        for dbitl in csr_dbitl(p_operand_value => p_operand_value) loop
          begin
            select di.data_type
            ,      di.null_allowed_flag
            ,      ue.notfound_allowed_flag
            into   p_data_type
            ,      p_null_allowed
            ,      p_notfound_allowed
            from   ff_database_items di
            ,      ff_user_entities ue
            ,      ff_routes fr
            where  di.user_name = dbitl.user_name
            and    di.user_entity_id = dbitl.user_entity_id
            and    ue.user_entity_id = dbitl.user_entity_id
            and    (
                     (ue.business_group_id is null and ue.legislation_code is null) or
                     ue.legislation_code = p_legislation_code or
                     ue.business_group_id = p_business_group_id
                   )
            and    fr.route_id = ue.route_id
            and    not exists
                   (
                     select  context_id
                     from    ff_route_context_usages rcu
                     where   rcu.route_id = fr.route_id
                     minus
                     select  context_id
                     from    ff_ftype_context_usages fcu
                     where   fcu.formula_type_id = p_formula_type_id
                   )
            ;

            --
            -- Got a match.
            --
            return;
          exception
            --
            -- The user entity does not belong to the business group or legislation.
            --
            when no_data_found then
              null;
          end;
        end loop;

        --
        -- No translated database item match.
        --
        raise no_data_found;
      else
        --
        -- Translations are not supported, and a match was not made.
        --
        raise no_data_found;
      end if;
  end;
end core_fetch_dbi_info;
--
function get_formula_type return number is
--
  cursor C_FID1 is
    select FORMULA_TYPE_ID
    from   FF_FORMULA_TYPES
    where  upper(FORMULA_TYPE_NAME) = 'ASSIGNMENT SET';
--
 formula_id FF_FORMULA_TYPES.FORMULA_TYPE_ID%type;
 --
 begin
 --
   open C_FID1;
   fetch C_FID1 into formula_id;
   --
   if C_FID1%notfound then
      close C_FID1;
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PACKAGE','PAYWSDAS');
      fnd_message.set_token('FUNCTION','GET_FORMULA_TYPE');
      fnd_message.raise_error;
   end if;
   --
   close C_FID1;
   return(formula_id);
 end;
--
--
function get_assignment_sets_s return number is
--
  cursor C_ASS1 is
    select HR_ASSIGNMENT_SETS_S.nextval
    from   DUAL;
  --
  ass_sets number(15);
  --
  begin
  --
    open C_ASS1;
    fetch C_ASS1 into ass_sets;
    if C_ASS1%notfound then
       close C_ASS1;
       fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PACKAGE','PAYWSDAS');
       fnd_message.set_token('FUNCTION','GET_ASSIGNMENT_SETS_S');
      fnd_message.raise_error;
    else
       close C_ASS1;
       return(ass_sets);
    end if;
  end;
--
--
function get_formula_id(p_assignment_set_id in number) return number is
--
  cursor C_FID2 is
    select FORMULA_ID
    from   HR_ASSIGNMENT_SETS
    where  ASSIGNMENT_SET_ID = p_assignment_set_id;
--
 formula_id HR_ASSIGNMENT_SETS.FORMULA_ID%type;
 --
 begin
 --
   open C_FID2;
   fetch C_FID2 into formula_id;
   --
   if C_FID2%notfound then
      close C_FID2;
      fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE','PAYWSDAS');
      fnd_message.set_token('STEP','GET_FORMULA_ID');
      fnd_message.raise_error;
   end if;
   --
   close C_FID2;
   return(formula_id);
 end;
--
--
function no_criteria_exists(p_assignment_set_id in number) return boolean is
--
 cursor C_CR2 is
    select null
    from   HR_ASSIGNMENT_SET_CRITERIA
    where  ASSIGNMENT_SET_ID = p_assignment_set_id;
--
dummy varchar2(1);
--
 begin
 --
   open C_CR2;
   fetch C_CR2 into dummy;
   --
   if C_CR2%found then
     close C_CR2;
     return(FALSE);
   else
     close C_CR2;
     return(TRUE);
   end if;
 --
 end;
--
--
procedure check_amendment_exists(p_assignment_set_id in number) is
--
  cursor C_AMD2 is
    select null
    from   HR_ASSIGNMENT_SET_AMENDMENTS
    where  ASSIGNMENT_SET_ID = p_assignment_set_id;
--
dummy varchar2(1);
--
 begin
 --
   open C_AMD2;
   fetch C_AMD2 into dummy;
   --
   if C_AMD2%found then
     close C_AMD2;
     fnd_message.set_name('PAY','HR_6941_PAY_AMENDMENTS_EXIST');
      fnd_message.raise_error;
   end if;
   --
   close C_AMD2;
 end;
--
--
procedure check_unq_amendment(p_assignment_set_id in number,
                              p_assignment_id     in number,
                              p_rowid             in varchar2) is
--
  cursor C_AMD5 is
    select null
    from   HR_ASSIGNMENT_SET_AMENDMENTS
    where  ASSIGNMENT_SET_ID = p_assignment_set_id
    and    ASSIGNMENT_ID     = p_assignment_id
    and (  p_rowid is null
        or p_rowid is not null and p_rowid <> ROWID);
--
dummy varchar2(1);
--
 begin
 --
   open C_AMD5;
   fetch C_AMD5 into dummy;
   --
   if C_AMD5%found then
     close C_AMD5;
     fnd_message.set_name('PAY','HR_6942_PAY_DUPLICATE_AMEND');
      fnd_message.raise_error;
   end if;
   --
   close C_AMD5;
 end;
--
--
procedure check_amd_inc_exc(p_assignment_set_id in number) is
--
  cursor C_AMD3 is
    select null
    from   HR_ASSIGNMENT_SET_AMENDMENTS HR1,
           HR_ASSIGNMENT_SET_AMENDMENTS HR2
    where  HR1.ASSIGNMENT_SET_ID   = p_assignment_set_id
    and    HR1.ASSIGNMENT_SET_ID   = HR2.ASSIGNMENT_SET_ID
    and    HR1.INCLUDE_OR_EXCLUDE <> HR2.INCLUDE_OR_EXCLUDE;
--
dummy varchar2(1);
--
 begin
 --
   open C_AMD3;
   fetch C_AMD3 into dummy;
   --
   if C_AMD3%found then
     close C_AMD3;
     fnd_message.set_name('PAY','HR_6944_PAY_DIFFERENT_AMEND');
     fnd_message.raise_error;
   end if;
   --
   close C_AMD3;
 end;
--
--
procedure check_include_exclude(p_assignment_set_id in number,
                                p_include_exclude   in varchar2,
                                p_rowid             in varchar2) is
--
  cursor C_AMD4 is
    select null
    from   HR_ASSIGNMENT_SET_AMENDMENTS
    where  ASSIGNMENT_SET_ID   = p_assignment_set_id
    and    INCLUDE_OR_EXCLUDE <> p_include_exclude
    and  ( p_rowid is null
        or p_rowid is not null and p_rowid <> ROWID);
  --
  dummy varchar2(1);
 begin
 --
   open C_AMD4;
   fetch C_AMD4 into dummy;
   --
   if C_AMD4%found then
     close C_AMD4;
     fnd_message.set_name('PAY','HR_6943_PAY_NOT_INC_OR_EXC');
     fnd_message.raise_error;
   end if;
   --
   close C_AMD4;
 end;
--
--
procedure check_criteria_exists(p_assignment_set_id in number,
                                p_line_no           in number default 0) is
--
  cursor C_AS2 is
    select null
    from   HR_ASSIGNMENT_SET_CRITERIA
    where  ASSIGNMENT_SET_ID = p_assignment_set_id
    and    LINE_NO          <> p_line_no;
--
dummy varchar2(1);
--
 begin
 --
   open C_AS2;
   fetch C_AS2 into dummy;
   --
   if C_AS2%found then
     close C_AS2;
     fnd_message.set_name('PAY','HR_6831_ASS_DEL_SET_CRIT');
     fnd_message.raise_error;
   end if;
   --
   close C_AS2;
 end;
--
--
procedure check_operand(p_business_group_id  in number,
                        p_legislation_code   in varchar2,
                        p_formula_type_id    in number,
                        p_data_type          in  out nocopy varchar2,
                        p_operand            in varchar2) is
  --
  l_data_type ff_database_items.data_type%type;
  l_null_allowed ff_database_items.null_allowed_flag%type;
  l_notfound_allowed ff_user_entities.notfound_allowed_flag%type;
  begin
  --
   begin
     core_fetch_dbi_info
     (p_business_group_id => p_business_group_id
     ,p_legislation_code  => p_legislation_code
     ,p_formula_type_id   => p_formula_type_id
     ,p_operand_value     => p_operand
     ,p_data_type         => l_data_type
     ,p_null_allowed      => l_null_allowed
     ,p_notfound_allowed  => l_notfound_allowed
     );

     --
     -- Supplied data type should match - the original code included
     -- data type matching claused in the SQL.
     --
     if l_data_type <> nvl(p_data_type, l_data_type) then
       raise no_data_found;
     end if;
   exception
     when no_data_found then
       fnd_message.set_name('PAY','HR_6829_ASS_OPERAND_TYPE_MATCH');
       fnd_message.raise_error;
   end;
   --
   -- if procedure used to fetch data type
   if p_data_type is null then
      p_data_type := l_data_type;
   end if;
  end;
--
--
procedure check_unique_name(p_assignment_set_name in varchar2,
                            p_business_group_id   in number,
                            p_rowid               in varchar2,
                            p_formula_type_id     in number,
                            p_legislation_code    in varchar2) is
 --
   cursor C_CU1 is
      select null
      from   HR_ASSIGNMENT_SETS
      where  upper(ASSIGNMENT_SET_NAME) = upper(p_assignment_set_name)
      and    business_group_id + 0          = p_business_group_id
      and    ( p_rowid is null
              or
              ( p_rowid is not null and ROWID <> p_rowid));
--
  dummy         varchar2(1);
  d_assign_name varchar2(80);
  --
  begin
  --
    open C_CU1;
    fetch C_CU1 into dummy;
    if C_CU1%found then
       close C_CU1;
       fnd_message.set_name('PAY','HR_6395_SETUP_SET_EXISTS');
       fnd_message.raise_error;
    else
       close C_CU1;
       d_assign_name := p_assignment_set_name;
       ffdict.validate_formula(d_assign_name,
                               p_formula_type_id,
                               p_business_group_id,
                               p_legislation_code);
    end if;
    --
  end;
--
--
procedure check_line_no(p_assignment_set_id  in number,
                        p_line_no            in number,
                        p_rowid              in varchar2) is
--
  cursor C_LN1 is
     select 'x'
     from   HR_ASSIGNMENT_SET_CRITERIA
     where  ASSIGNMENT_SET_ID = p_assignment_set_id
     and    LINE_NO           = p_line_no
     and   (p_rowid is null
            or p_rowid is not null and p_rowid <> ROWID);
 --
  dummy varchar2(1);
  begin
  --
   open C_LN1;
   fetch C_LN1 into dummy;
   --
   -- if row found then error
   if C_LN1%found then
      close C_LN1;
      fnd_message.set_name('PAY','HR_6820_ASS_UNIQUE_SEQUENCE');
      fnd_message.raise_error;
   end if;
   --
   close C_LN1;
  end;
--
--
procedure delete_formula(p_formula_id      in number,
                         p_formula_type_id in number) is
 --
  begin
  --
    delete
    from   FF_FORMULAS_F
    where  FORMULA_ID      = p_formula_id
    and    FORMULA_TYPE_ID = p_formula_type_id;
  end;
--
--
procedure get_min_max_line(p_assignment_set_id in     number,
                           p_min_line_no       in out nocopy number,
                           p_max_line_no       in out nocopy number) is
--
  cursor C_MMAX1 is
     select  ((FLOOR(max(LINE_NO) / 10)) + 1) * 10,
             min(LINE_NO)
     from    HR_ASSIGNMENT_SET_CRITERIA
     where   ASSIGNMENT_SET_ID = p_assignment_set_id;
  --
  begin
  --
    open C_MMAX1;
    fetch C_MMAX1 into p_max_line_no,
                       p_min_line_no;
    --
    if C_MMAX1%notfound then
       p_max_line_no := 10;
       p_min_line_no := 0;
    end if;

 close C_MMAX1;
    --
  end;
--
procedure fetch_dbi_info
(p_assignment_set_id in number
,p_formula_type_id in number
,p_date_format in varchar2
,p_operand_value in varchar2
,p_data_type out nocopy varchar2
,p_null_allowed out nocopy varchar2
,p_notfound_allowed out nocopy varchar2
,p_start_of_time out nocopy varchar2
) is
l_business_group_id per_business_groups_perf.business_group_id%type;
l_legislation_code  per_business_groups_perf.legislation_code%type;
begin
  --
  -- This code replaces plain SQL so don't worry about exceptions.
  --

  --
  -- Fetch BUSINESS_GROUP_ID and LEGISLATION_CODE for the core routine call.
  --
  select bg.business_group_id
  ,      bg.legislation_code
  into   l_business_group_id
  ,      l_legislation_code
  from   hr_assignment_sets a_s
  ,      per_business_groups_perf bg
  where  a_s.assignment_set_id = p_assignment_set_id
  and    bg.business_group_id = a_s.business_group_id
  ;

  --
  -- Call the core routine.
  --
  core_fetch_dbi_info
  (p_business_group_id => l_business_group_id
  ,p_legislation_code  => l_legislation_code
  ,p_formula_type_id   => p_formula_type_id
  ,p_operand_value     => p_operand_value
  ,p_data_type         => p_data_type
  ,p_null_allowed      => p_null_allowed
  ,p_notfound_allowed  => p_notfound_allowed
  );

  --
  -- Return the start-of-time string in the required date format.
  --
  p_start_of_time :=
  to_char(to_date('01/01/0001', 'DD/MM/YYYY'), p_date_format);
end fetch_dbi_info;
--
end PAY_PAYWSDAS_PKG;

/
