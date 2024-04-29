--------------------------------------------------------
--  DDL for Package Body AME_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_UTILITY_PKG" as
/* $Header: ameutility.pkb 120.10 2008/04/11 05:30:41 prasashe noship $ */
  --private method
  procedure checkBindVariables(queryStringIn   in varchar2
                              ,allowedBindVars in ame_util.stringList) as
  tempstring1       varchar2(4000);
  tempstring        varchar2(4000);
  col1Position      number;
  col2Position      number;
  comPos1           number := 0;
  comPos2           number := 0;
  commaPos          number :=0;
  paranPos          number :=0;
  minPos            number:=0;
  errInBindVar      boolean := true;
  invalidBindException exception;
  begin
  --+
  tempstring  := ' ' || replace(replace(replace(queryStringIn,fnd_global.local_chr(10),' '),
                        fnd_global.local_chr(13),' '),'  ',' ') || ' ';
  col1Position := instrb(tempstring, ':', 1) ;
  --+
  while col1Position > 0 loop
    --+
    errInBindVar := true;
    col1Position := col1Position + 1;
    comPos1:= instrb(tempstring, '''', 1) ;
     if compos1 < col1Position  and comPos1 > 0 then
       comPos2:= instrb(tempstring, '''', 1,2) ;
       if comPos2 > 0 then
         tempstring := substr(tempstring,comPos2+1);
       end if;
     else
       tempstring := substr(tempstring,col1Position);
       commaPos:=instrb(tempstring, ',', 1) ;
       paranPos:= instrb(tempstring, ')', 1) ;
       col2Position := instrb(tempstring, ' ', 1);
       minPos := col2Position;
       if commaPos > 0 and commaPos < minPos then
         minPos := commaPos;
       end if;
       if paranPos > 0 and paranPos < minPos then
         minPos := paranPos;
       end if;
       tempstring1 := substr(tempstring,1,minPos-1);
       for i in 1 .. allowedBindVars.count loop
         if trim(tempstring1) = trim(allowedBindVars(i)) then
           errInBindVar := false;
           exit;
         end if;
       end loop;
       if errInBindVar = true then
         raise invalidBindException;
         exit;
       end if;
     end if;
    col1Position := instrb(tempstring, ':', 1);
  end loop;
end checkBindVariables;
  function truncate_cond_desc(p_description varchar2,
                              p_truncate    varchar2) return varchar2;
  function validate_query
    (p_query_string varchar2
    ,p_columns      number default null
    ,p_object       varchar2 default null
    ) return varchar2 as

    query_cursor       integer;
    temp_query_string  varchar2(4000);
    columna            varchar2(100);
    columnb            varchar2(100);
    error_string       varchar2(1000);
    l_allowed_bind_vars ame_util.stringList;
  begin
     if (check_seeddb = 'Y') then
       return 'Y';
     end if;
    /* Query String Cannot be null */
    if p_query_string is null then
      fnd_message.set_name('PER','AME_400629_EMPTY_QUERY_STRING');
      return fnd_message.get;
    end if;

    /* Remove any new lines and replace with spaces */
    temp_query_string := ' ' || replace(replace(replace(p_query_string,
                                                 fnd_global.local_chr(10),
                                                 ' '),
                                          fnd_global.local_chr(13),
                                          ' '),
                                '  ',
                                ' ') || ' ';

    /* Following commands are not SQL queries */
    /* insert,update,delete,commit,rollback   */
    /* truncate,drop,grant,execute,locl,alter */
    if instr(lower(temp_query_string),' insert ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','INSERT');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' update ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','UPDATE');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' delete ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','DELETE');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' commit ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','COMMIT');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' rollback ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','ROLLBACK');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' truncate ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','TRUNCATE');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' drop ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','DROP');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' grant ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','GRANT');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'execute ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','EXECUTE');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' lock ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','LOCK');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),' alter ',1,1) > 0 then
      fnd_message.set_name('PER','AME_400630_PROHIBITED_KEYWORD');
      fnd_message.set_token('KEYWORD','ALTER');
      return fnd_message.get;
    end if;

    /* Comments and semicolons are not allowed */
    if instr(lower(temp_query_string),';',1,1) > 0 then
      fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'/*',1,1) > 0 then
      fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'*/',1,1) > 0 then
      fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'--',1,1) > 0 then
      fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
      return fnd_message.get;
    end if;

    /* References to following packages is forbidden */
    if instr(lower(temp_query_string),'dbms_output.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG');
      fnd_message.set_token('PACKAGE','DBMS_OUTPUT');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'dbms_sql.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG');
      fnd_message.set_token('PACKAGE','DBMS_SQL');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'ht'||'f.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG');
      fnd_message.set_token('PACKAGE','HTF');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'ht'||'p.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG');
      fnd_message.set_token('PACKAGE','HTP');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'owa_util.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG');
      fnd_message.set_token('PACKAGE','OWA_UTIL');
      return fnd_message.get;
    end if;
    if instr(lower(temp_query_string),'owa_cookie.',1,1) > 0 then
      fnd_message.set_name('PER','AME_400625_PROHIBITED_PKG ');
      fnd_message.set_token('PACKAGE','OWA_COOKIE');
      return fnd_message.get;
    end if;

    --Check for valid bind variable for the module
    if(p_object is not null) then
      begin
        if(p_object in ( ame_util2.attributeObject, ame_util2.itemClassObject) ) then
          l_allowed_bind_vars(1) := 'transactionId';
        elsif (p_object = ame_util2.actionTypeObject) then
          l_allowed_bind_vars(1) := 'parameterOne';
          l_allowed_bind_vars(2) := 'parameterTwo';
        elsif (p_object = ame_util2.approverGroupObject or
	       p_object = ame_util2.specialObject) then
          l_allowed_bind_vars(1) := 'transactionId';
          l_allowed_bind_vars(2) := 'itemId';
          l_allowed_bind_vars(3) := 'itemClass';
        end if;
        checkBindVariables(queryStringIn => temp_query_string
                          ,allowedBindVars => l_allowed_bind_vars
                          );
      exception
        when others then
          if (p_object = ame_util2.attributeObject) then
             fnd_message.set_name('PER', 'AME_400794_INV_ATR_BIND_VAR');
          elsif p_object = ame_util2.specialObject then
            fnd_message.set_name('PER', 'AME_400799_INV_VATR_BIND_VAR');
          elsif p_object = ame_util2.itemClassObject then
            fnd_message.set_name('PER', 'AME_400795_INV_ITU_BIND_VAR');
          elsif p_object = ame_util2.actionTypeObject then
            fnd_message.set_name('PER', 'AME_400796_INV_ATY_BIND_VAR');
          elsif p_object = ame_util2.approverGroupObject then
            fnd_message.set_name('PER', 'AME_400797_INV_APG_BIND_VAR');
          end if;
          return fnd_message.get;
      end;
    end if;
    query_cursor := dbms_sql.open_cursor;

    dbms_sql.parse
      (query_cursor
      ,p_query_string
      ,dbms_sql.native
      );

    if p_columns is null then
      dbms_sql.close_cursor(query_cursor);
      return 'Y';
    else
      begin
        dbms_sql.define_column(query_cursor,p_columns,columna,100);
        begin
          dbms_sql.define_column(query_cursor,p_columns + 1,columnb,100);
          dbms_sql.close_cursor(query_cursor);
          if p_columns > 1 then
            fnd_message.set_name('PER','AME_400626_INVALID_NUM_COLS');
            fnd_message.set_token('NUMCOLS',p_columns);
          else
            fnd_message.set_name('PER','AME_400628_INVALID_SINGLE_COL');
          end if;
          return fnd_message.get;
        exception
          when others then
            dbms_sql.close_cursor(query_cursor);
            return 'Y';
        end;
      exception
        when others then
          dbms_sql.close_cursor(query_cursor);
          if p_columns > 1 then
            fnd_message.set_name('PER','AME_400626_INVALID_NUM_COLS');
            fnd_message.set_token('NUMCOLS',p_columns);
          else
            fnd_message.set_name('PER','AME_400628_INVALID_SINGLE_COL');
          end if;
          return fnd_message.get;
      end;
    end if;
  exception

    when others then
      dbms_sql.close_cursor(query_cursor);
      fnd_message.set_name('PER','AME_400627_QUERY_SQL_INVALID');
      error_string := sqlerrm;
      if instrb(error_string,':',1,1) > 0 then
        error_string := substrb(error_string,instrb(error_string,':',1,1) + 2);
      end if;
      fnd_message.set_token('EXPSTRING',error_string);
      return fnd_message.get;
  end validate_query;

  function get_action_description(p_action_id      in number
                                 ,p_effective_date in date default sysdate) return varchar2 is
    cursor getActionTypeDynamicDesc(actionIdIn in number
                                   ,p_effective_date in date) is
      select dynamic_description
        from ame_action_types aty,
             ame_actions act
       where act.action_id = actionIdIn
         and act.action_type_id = aty.action_type_id
         and p_effective_date between act.start_date and nvl(act.end_date - (1/86400), p_effective_date)
         and p_effective_date between aty.start_date and nvl(aty.end_date - (1/86400), p_effective_date);

    cursor getActionDesc(actionIdIn       in number
                        ,p_effective_date in date) is
      select description
        from ame_actions_vl
       where action_id = actionIdIn
         and p_effective_date between start_date and nvl(end_date - (1/86400), p_effective_date);

    cursor getActionDescQueryAndParam(actionIdIn       in number
                                     ,p_effective_date in date) is
      select description_query,
             parameter,
             parameter_two
        from ame_action_types aty,
             ame_actions act
       where act.action_id = actionIdIn
         and act.action_type_id = aty.action_type_id
         and p_effective_date between act.start_date and nvl(act.end_date - (1/86400), p_effective_date)
         and p_effective_date between aty.start_date and nvl(aty.end_date - (1/86400), p_effective_date);

    l_query_string        ame_action_types.description_query%type;
    l_parameter_one       ame_actions.parameter%type;
    l_parameter_two       ame_actions.parameter_two%type;
    query_cursor          integer;
    dynamic_description   varchar2(1);
    action_description    varchar2(500);
    l_result              integer;
  begin

    open getActionTypeDynamicDesc(actionIdIn => p_action_id,p_effective_date => p_effective_date);
    fetch getActionTypeDynamicDesc into dynamic_description;
    close getActionTypeDynamicDesc;
    if dynamic_description = 'Y' then
      open getActionDescQueryAndParam(actionIdIn => p_action_id,p_effective_date => p_effective_date);
      fetch getActionDescQueryAndParam
       into l_query_string,
            l_parameter_one,
            l_parameter_two;
      close getActionDescQueryAndParam;
      begin
        query_cursor := dbms_sql.open_cursor;
        dbms_sql.parse
          (query_cursor
          ,l_query_string
          ,dbms_sql.native
          );
        if instrb(l_query_string,':parameterOne') > 0 then
          dbms_sql.bind_variable
            (query_cursor
            ,':parameterOne'
            ,l_parameter_one
            ,320);
        end if;
        if instrb(l_query_string,':parameterTwo') > 0 then
          dbms_sql.bind_variable
            (query_cursor
            ,':parameterTwo'
            ,l_parameter_two
            ,320);
        end if;
        dbms_sql.define_column(query_cursor,1,action_description,500);
        l_result := dbms_sql.execute(query_cursor);
        if dbms_sql.fetch_rows(query_cursor) > 0 then
          dbms_sql.column_value(query_cursor,1,action_description);
        end if;
        dbms_sql.close_cursor(query_cursor);
        return action_description;
      exception
        when others then
          fnd_message.set_name('PER','AME_400636_INV_DYN_ACT_DESC');
          fnd_message.set_token('PARAMETER_ONE',l_parameter_one);
          fnd_message.set_token('PARAMETER_TWO',l_parameter_two);
          return fnd_message.get;
      end;
    else
      open getActionDesc(actionIdIn => p_action_id,p_effective_date => p_effective_date);
      fetch getActionDesc into action_description;
      close getActionDesc;
      return action_description;
    end if;
  end get_action_description;

  function is_approver_valid_in_action(p_action_type_id in number
                                      ,p_action_id in number) return varchar2 is
    l_return_value varchar2(1);
    l_name ame_action_types.name%type;
  begin
    select name into l_name
      from ame_action_types
     where action_type_id = p_action_type_id
       and sysdate between start_date and nvl(end_date-(1/86400),sysdate)
       and rownum < 2;

    l_return_value := 'N';

    if l_name = ame_util.substitutionTypeName or l_name = ame_util.positionTypeName then
        select 'Y' into l_return_value
          from wf_roles wfroles
	       ,ame_actions act
         where wfroles.name = act.parameter
           and wfroles.status = 'ACTIVE'
           and (wfroles.expiration_date is null or
                                 sysdate < wfroles.expiration_date)
           and act.action_type_id = p_action_type_id
	   and act.action_id = p_action_id
	   and sysdate between act.start_date and nvl(act.end_date-(1/86400),sysdate)
	   and rownum < 2;
    else
      l_return_value := 'Y';
    end if;
    return l_return_value;
  exception
    when others then
      return 'N';
  end;

    procedure purge_log
    (p_transaction_type in            varchar2 default null
    ,p_transaction_id   in            varchar2 default null
    ,p_success             out nocopy varchar2
    ) is
    l_application_id integer;
    l_count          integer;
  begin
    p_success := 'Y';

    if p_transaction_type is not null then
      select application_id into l_application_id
        from ame_calling_apps_vl
       where upper(trim(application_name)) = upper(trim(p_transaction_type))
         and sysdate between start_date and nvl(end_date-(1/86400),sysdate);
    end if;

    if (p_transaction_id is null) and (p_transaction_type is not null ) then
      select count(*)
        into l_count
        from ame_exceptions_log
       where application_id = l_application_id ;
      if l_count > 0 then
        delete from ame_exceptions_log
         where application_id = l_application_id ;
        p_success :='Y';
      else
        p_success :='N';
      end if;
    elsif (p_transaction_id is not null) and (p_transaction_type is null) then
      select count(*)
        into l_count
        from ame_exceptions_log
       where transaction_id like (p_transaction_id || '%');
      if l_count > 0 then
        delete from ame_exceptions_log
         where transaction_id like (p_transaction_id || '%');
        p_success :='Y';
      else
        p_success :='N';
      end if;
    elsif (p_transaction_id is not null) and (p_transaction_type is not null) then
      select count(*)
       into l_count
       from ame_exceptions_log
      where transaction_id like (p_transaction_id || '%')
        and application_id = l_application_id ;
      if l_count > 0 then
        delete from ame_exceptions_log
         where application_id = l_application_id
          and transaction_id like (p_transaction_id || '%');
        p_success :='Y';
      else
        p_success :='N';
      end if;
    end if;
  end purge_log;
  function truncate_cond_desc(p_description varchar2,
                              p_truncate    varchar2) return varchar2 is
  begin
    if p_truncate = 'Y' and length(p_description) > 200 then
      return substr(p_description, 1, 197) || '...';
    end if;
    return p_description;
  end truncate_cond_desc;
  function get_condition_description(p_condition_id   in varchar2,
                                     p_truncate       in varchar2 default 'Y',
                                     p_effective_date in date default sysdate) return varchar2 is
    cursor c_attr(p_condition_id   in number
                 ,p_effective_date in date) is
      select attr.name
            ,attr.attribute_type
            ,attr.approver_type_id
            ,cond.parameter_one
            ,cond.parameter_two
            ,cond.parameter_three
            ,cond.include_lower_limit
            ,cond.include_upper_limit
            ,cond.condition_type
        from ame_conditions cond
            ,(select name
                    ,attribute_id
                    ,attribute_type
                    ,approver_type_id
                from ame_attributes
               where p_effective_date between start_date
                                 and nvl(end_date,p_effective_date)
             ) attr
       where cond.condition_id = p_condition_id
         and cond.attribute_id = attr.attribute_id (+)
         and p_effective_date between cond.start_date
                         and nvl(cond.end_date-(1/86400),p_effective_date);

    cursor c_str_val(p_condition_id   in number
                    ,p_effective_date in date) is
      select strval.string_value
        from ame_string_values strval
       where strval.condition_id = p_condition_id
         and p_effective_date between strval.start_date
                         and nvl(strval.end_date-(1/86400),p_effective_date)
          order by strval.string_value;

    l_attribute_name        varchar2(200);
    l_attribute_type        varchar2(20);
    l_approver_type_id      number;
    l_parameter_one         varchar2(50);
    l_parameter_two         varchar2(320);
    l_parameter_three       varchar2(100);
    l_include_lower_limit   varchar2(1);
    l_include_upper_limit   varchar2(1);
    l_condition_type        varchar2(10);
    l_stringvalues          varchar2(32000);
    l_string_value          varchar2(4000);
    l_flag                  varchar2(4);
    l_expression            varchar2(32000);
    l_message_name          varchar2(30);

  begin

    open c_attr(p_condition_id,p_effective_date);
    fetch c_attr into l_attribute_name
                     ,l_attribute_type
                     ,l_approver_type_id
                     ,l_parameter_one
                     ,l_parameter_two
                     ,l_parameter_three
                     ,l_include_lower_limit
                     ,l_include_upper_limit
                     ,l_condition_type;
    close c_attr;

    if l_condition_type = 'post' then
      l_string_value := ame_approver_type_pkg.getApproverDescription(l_parameter_two);
      if l_parameter_one = 'any_approver' then
        fnd_message.set_name('PER','AME_400479_LM_COND_ANY_APPR');
        fnd_message.set_token('APPROVER',l_string_value);
      elsif l_parameter_one = 'final_approver' then
        fnd_message.set_name('PER','AME_400480_LM_COND_FINAL_APPR');
        fnd_message.set_token('APPROVER',l_string_value);
      end if;
      l_expression := fnd_message.get;
      return truncate_cond_desc(l_expression,
                                p_truncate);
    end if;

    if(l_attribute_type = 'boolean') then
      if l_parameter_one = 'true' then
        fnd_message.set_name('PER','AME_400481_BOOL_T_COND_DESC');
        fnd_message.set_token('ATTR',l_attribute_name);
      elsif l_parameter_one = 'false' then
        fnd_message.set_name('PER','AME_400482_BOOL_F_COND_DESC');
        fnd_message.set_token('ATTR',l_attribute_name);
      end if;
      l_expression := fnd_message.get;
      return truncate_cond_desc(l_expression,
                                p_truncate);
    end if;

    if(l_attribute_type = 'string') then
      l_string_value := null;
      l_flag := null;
      open c_str_val(p_condition_id,p_effective_date);
      loop
        if l_flag is not null then
          if (length(l_stringvalues) + length(l_string_value)) > 32000 then
            exit;
          end if;
          l_stringvalues := l_stringvalues ||l_string_value;
        end if;
        fetch c_str_val into l_string_value;
        if c_str_val%notfound then
          close c_str_val;
          exit;
        end if;
        if l_flag is not null and length(l_stringvalues) < 31999 then
          l_stringvalues := l_stringvalues || ', ';
        else
          l_flag := 'Y';
        end if;
      end loop;
      fnd_message.set_name('PER','AME_400483_STRING_COND_DESC');
      fnd_message.set_token('ATTR',l_attribute_name);
      fnd_message.set_token('STRINGVALUES','('||substr(l_stringvalues,1,1900)||')');
      l_expression := fnd_message.get;
      return truncate_cond_desc(l_expression,
                                p_truncate);
    end if;

    if ((l_attribute_type = 'number' and l_approver_type_id is null) or
         l_attribute_type = 'date' or
         l_attribute_type = 'currency') then
      if(l_parameter_one is not null and
         l_parameter_two is not null and
         l_include_lower_limit is not null and
         l_include_upper_limit is not null and
         l_parameter_one = l_parameter_two and
         l_include_lower_limit = 'Y' and
         l_include_lower_limit = 'Y') then
              if l_attribute_type = 'date' then
          l_parameter_one := to_char(to_date(l_parameter_one,'yyyy:mm:dd:hh24:mi:ss'),'DD-MON-YYYY');
        end if;
        fnd_message.set_name('PER','AME_400484_NUM_COND_EQ_DESC');
        fnd_message.set_token('ATTR',l_attribute_name);
        fnd_message.set_token('VALUE',l_parameter_one);
        l_expression := fnd_message.get;
      else
        l_flag := '';
        if l_parameter_one is not null then
          if l_attribute_type = 'date' then
            l_parameter_one := to_char(to_date(l_parameter_one,'yyyy:mm:dd:hh24:mi:ss'),'DD-MON-YYYY');
          end if;
          if(l_include_lower_limit = 'Y') then
            l_flag := 'GE';
          else
            l_flag := 'GT';
          end if;
        end if;
        if l_parameter_two is not null then
          if l_attribute_type = 'date' then
            l_parameter_two := to_char(to_date(l_parameter_two,'yyyy:mm:dd:hh24:mi:ss'),'DD-MON-YYYY');
          end if;
          if(l_include_upper_limit = 'Y') then
            l_flag := l_flag || 'LE';
          else
            l_flag := l_flag || 'LT';
          end if;
        end if;
        if(l_flag = 'GT') then
          fnd_message.set_name('PER','AME_400485_NUM_COND_GT_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE',l_parameter_one);
        elsif (l_flag = 'GE') then
          fnd_message.set_name('PER','AME_400486_NUM_COND_GE_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE',l_parameter_one);
        elsif (l_flag = 'LT') then
          fnd_message.set_name('PER','AME_400487_NUM_COND_LT_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE',l_parameter_two);
        elsif (l_flag = 'LE') then
          fnd_message.set_name('PER','AME_400488_NUM_COND_LE_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE',l_parameter_two);
        elsif (l_flag = 'GTLT') then
          fnd_message.set_name('PER','AME_400489_NUM_COND_GTLT_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE1',l_parameter_one);
          fnd_message.set_token('VALUE2',l_parameter_two);
        elsif (l_flag = 'GTLE') then
          fnd_message.set_name('PER','AME_400490_NUM_COND_GTLE_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE1',l_parameter_one);
          fnd_message.set_token('VALUE2',l_parameter_two);
        elsif (l_flag = 'GELE') then
          fnd_message.set_name('PER','AME_400491_NUM_COND_GELE_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE1',l_parameter_one);
          fnd_message.set_token('VALUE2',l_parameter_two);
        elsif (l_flag = 'GELT') then
          fnd_message.set_name('PER','AME_400492_NUM_COND_GELT_DESC');
          fnd_message.set_token('ATTR',l_attribute_name);
          fnd_message.set_token('VALUE1',l_parameter_one);
          fnd_message.set_token('VALUE2',l_parameter_two);
        end if;
        l_expression := fnd_message.get;
      end if;
      if(l_attribute_type = 'currency') then
        l_expression := l_expression || ','||l_parameter_three;
      end if;
      return truncate_cond_desc(l_expression,
                                p_truncate);
    end if;

    if l_attribute_type = 'number' and l_approver_type_id is not null then
      begin
        select lookup.meaning ||': '||wfroles.display_name
          into l_string_value
          from ame_approver_types appr
              ,fnd_lookups lookup
              ,wf_roles wfroles
         where appr.approver_type_id = l_approver_type_id
           and lookup.lookup_type = 'FND_WF_ORIG_SYSTEMS'
           and lookup.lookup_code = appr.orig_system
           and p_effective_date between appr.start_date
                           and nvl(appr.end_date-(1/86400),p_effective_date)
           and wfroles.orig_system = appr.orig_system
           and to_char(wfroles.orig_system_id) = l_parameter_one
           and wfroles.status = 'ACTIVE'
           and (wfroles.expiration_date is null or
                                p_effective_date < wfroles.expiration_date);
      exception
        when others then
	  begin
            select lookup.meaning ||': '||wfroles.display_name
              into l_string_value
              from ame_approver_types appr
                  ,fnd_lookups lookup
                  ,wf_local_roles wfroles
             where appr.approver_type_id = l_approver_type_id
               and lookup.lookup_type = 'FND_WF_ORIG_SYSTEMS'
               and lookup.lookup_code = appr.orig_system
               and p_effective_date between appr.start_date
                             and nvl(appr.end_date-(1/86400),p_effective_date)
               and wfroles.orig_system = appr.orig_system
               and to_char(wfroles.orig_system_id) = l_parameter_one
	       and rownum < 2;

	    fnd_message.set_name('PER','AME_400344_INVALID_APPROVER');
            fnd_message.set_token('ATTR',l_attribute_name);
	    fnd_message.set_token('NAME',l_string_value);
            l_string_value := fnd_message.get;
            return truncate_cond_desc(l_string_value,
                                    p_truncate);
          exception
	    when others then
	      fnd_message.set_name('PER','AME_400344_INVALID_APPROVER');
              fnd_message.set_token('ATTR',l_attribute_name);
              select lookup.meaning ||': '|| l_parameter_one
                into l_string_value
                from ame_approver_types appr
                    ,fnd_lookups lookup
               where appr.approver_type_id = l_approver_type_id
                 and lookup.lookup_type = 'FND_WF_ORIG_SYSTEMS'
                 and lookup.lookup_code = appr.orig_system
                 and p_effective_date between appr.start_date
                             and nvl(appr.end_date-(1/86400),p_effective_date)
                 and rownum < 2;
	      fnd_message.set_token('NAME', l_string_value);
              l_string_value := fnd_message.get;
              return truncate_cond_desc(l_string_value,
                                    p_truncate);
	  end;
      end;

      fnd_message.set_name('PER','AME_400493_NUM_APPR_COND_DESC');
      fnd_message.set_token('ATTR',l_attribute_name);
      fnd_message.set_token('APPROVER',l_string_value);
      l_expression := fnd_message.get;
      return truncate_cond_desc(l_expression,
                                p_truncate);
    end if;
    return '';
  end get_condition_description;

  function get_action_types(p_attribute_id number) return varchar2 is

    action_types_list   ame_util.longStringList;
    list                varchar2(4000);

    cursor action_types_cursor(l_attribute_id number)is
      select act.name
        from ame_action_types act,
             ame_mandatory_attributes man
       where Man.action_type_id = Act.action_type_id
         and sysdate between act.start_date and nvl(act.end_date,sysdate)
         and sysdate between man.start_date and nvl(man.end_date,sysdate)
         and man.attribute_id = l_attribute_id
       order by act.name;
  begin

    open action_types_cursor(l_attribute_id => p_attribute_id);
    fetch action_types_cursor bulk collect into action_types_list;
    close action_types_cursor;

    if action_types_list.count = 0 then
      fnd_message.set_name('PER','AME_400637_TEXT_NONE');
      return fnd_message.get;
    end if;

    for i in 1 .. action_types_list.count loop
      list := list || action_types_list(i);
      if i <> action_types_list.count then
        list := list || '<BR>';
      end if;
    end loop;
    return list;

  exception
    when others then
      return null;
  end get_action_types;

  function get_attribute_category(p_attribute_id number) return varchar2 as

    action_type_id_list   ame_util.idList;
    man_category          varchar2(25);
    req_category          varchar2(25);
    oth_category          varchar2(25);

    cursor category_cursor(l_attribute_id number)is
      select man.action_type_id
        from ame_attributes atr,
             ame_mandatory_attributes man
       where atr.attribute_id = man.attribute_id
         and atr.attribute_id = l_attribute_id
         and sysdate between atr.start_date and nvl(atr.end_date-(1/84600),sysdate)
         and sysdate between man.start_date and nvl(man.end_date-(1/84600),sysdate);

  begin

    man_category := 'MANDATORY_CATEGORY';
    req_category := 'REQUIRED_CATEGORY';
    oth_category := 'OTHER_CATEGORY';

    open category_cursor(l_attribute_id => p_attribute_id);
    fetch category_cursor bulk collect into action_type_id_list;

    if action_type_id_list.count = 0 then
      return oth_category;
    end if;

    if action_type_id_list(1) = -1 then
      return man_category;
    else
      return req_category;
    end if;
    close category_cursor;

  exception
    when others then
      return null;

  end get_attribute_category;

  procedure set_ame_savepoint is
  begin
    savepoint ame_savepoint;
  end set_ame_savepoint;

  procedure rollback_to_ame_savepoint is
  begin
    rollback to savepoint ame_savepoint;
  end rollback_to_ame_savepoint;

  procedure get_value_set_query
    (p_value_set_id in            number
    ,p_select          out nocopy varchar2) is
    l_select            varchar2(4000);
    l_mapping_code      varchar2(100);
    l_success           number;
    l_validation_type   varchar2(1);
    l_before_from       varchar2(4000);
    l_after_from        varchar2(4000);
    l_column1           varchar2(200);
    l_column2           varchar2(200);
    l_v_r  fnd_vset.valueset_r;
    l_v_dr fnd_vset.valueset_dr;
    l_whr  varchar2(4000);
    l_valid_number_col varchar2(100);
    l_format_type fnd_flex_value_sets.format_type%TYPE;
    l_value             BOOLEAN;
    l_out_status        VARCHAR2(30);
    l_out_industry      VARCHAR2(30);
    l_out_oracle_schema VARCHAR2(30);
    cursor fnd_attr_data_type(TabNameIn     in varchar2
                              ,ColumnNameIn in varchar2) is
      select column_type
        from fnd_columns fcol
            ,fnd_tables ftab
       where ftab.table_name = upper(TabNameIn)
         and ftab.table_id = fcol.table_id
         and fcol.column_name =upper(ColumnNameIn);
    cursor valSetDetails(p_valuesetIdIn   in number) is
      select validation_type,format_type
        from fnd_flex_value_sets
       where flex_value_set_id = p_valuesetIdIn;
  begin
    --+
    open valSetDetails(p_valuesetIdIn  => p_value_set_id);
    fetch valSetDetails into l_validation_type,l_format_type;
    close valSetDetails;
    --+
    if (l_validation_type <> 'I' and l_validation_type <> 'F') then
     p_select := 'AME_400818_INV_VALIDATION_TYP';
     return;
    end if;
    --+
    if(l_validation_type = 'I') then
      fnd_flex_val_api.get_independent_vset_select
        (p_value_set_id    => p_value_set_id
        ,x_select          => l_select
        ,x_mapping_code    => l_mapping_code
        ,x_success         => l_success
        );
      l_before_from := substrb(l_select,1,instrb(lower(l_select),'from') - 1);
      l_after_from := substrb(l_select,instrb(lower(l_select),'from')+4);
      l_before_from := replace(trim(substrb(
                                            l_before_from,
                                            instrb(lower(l_before_from),'select')+6
                                            )
                                    ),
                                    fnd_global.local_chr(10),
                                    '');

      l_column1 := substrb(l_before_from,1,instrb(l_before_from,',')-1);
      l_before_from := substrb(l_before_from,instrb(l_before_from,',')+1);
      l_before_from := substrb(l_before_from,instrb(l_before_from,',')+1);
      if(instrb(l_before_from,',') = 0) then
        l_column2 := trim(l_before_from);
      else
        l_column2 := trim(substrb(l_before_from,1,instrb(l_before_from,',')-1));
      end if;
      p_select := 'select '||l_column1||' VALUE, '||l_column2||' MEANING from'||l_after_from;
    elsif (l_validation_type = 'F') then
      fnd_vset.get_valueset(valueset_id => p_value_set_id ,
                            valueset    => l_v_r,
                            format      => l_v_dr);
      l_whr := trim(l_v_r.table_info.where_clause) ;
      if(l_whr is not null and
         lower(substr(l_whr,1,5)) <> 'where') then
        l_whr := ' where ' || l_whr;
      end if;
      l_column2 := trim(l_v_r.table_info.meaning_column_name);
      if(l_column2 is null) then
        l_column2 := l_v_r.table_info.value_column_name;
      end if;
      p_select := rtrim('select ' ||
                        l_v_r.table_info.value_column_name ||
                        ' Value, ' ||
                        l_column2 ||
                        ' Meaning from ' ||
                        l_v_r.table_info.table_name ||
                        ' ' ||
                        l_whr
                        );
    end if;
    if(validate_query(p_select) <> 'Y' ) then
      p_select := 'AME_400779_INV_VALUE_SET';
    end if;
    if(p_select <> 'AME_400779_INV_VALUE_SET' and l_format_type = 'N' and l_validation_type = 'F') then
      open fnd_attr_data_type( TabNameIn     =>l_v_r.table_info.table_name
                              ,ColumnNameIn =>l_v_r.table_info.value_column_name);
      fetch fnd_attr_data_type into l_valid_number_col;
      close fnd_attr_data_type;
      if(l_valid_number_col is not null and l_valid_number_col <> 'N') then
        p_select := 'AME_400819_INV_VAL_COL_TYPE';
      end if;
    end if;
   --+
  exception
    when others then
      p_select := 'AME_400779_INV_VALUE_SET';
  end get_value_set_query;

  function get_rule_last_update_date
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return date is

  cursor c_last_update_date (c_rule_id integer,c_application_id integer,c_rule_usage_start_date date) is
    select ar.last_update_date RULE_LUD,
           ar.last_updated_by RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_rules ar
     where ar.rule_id = c_rule_id
       and ar.last_update_date in (select max(last_update_date)
                                     from ame_rules art
                                    where art.rule_id = c_rule_id)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           aru.last_update_date RULE_USAGE_LUD,
           aru.last_updated_by RULE_USAGE_LUB,
           aru.end_date RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_rule_usages aru
     where aru.rule_id = c_rule_id
       and aru.item_id = c_application_id
       and aru.start_date = c_rule_usage_start_date
       and aru.start_date < aru.end_date
       and aru.last_update_date in (select max(last_update_date)
                                      from ame_rule_usages arut
                                     where arut.rule_id = c_rule_id
                                       and arut.item_id = c_application_id
                                       and arut.start_date = c_rule_usage_start_date
                                       and arut.start_date < arut.end_date)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           acu.last_update_date CONDITION_USAGE_LUD,
           acu.last_updated_by CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_condition_usages acu
     where acu.rule_id = c_rule_id
       and acu.last_update_date in (select max(last_update_date)
                                      from ame_condition_usages acut
                                     where acut.rule_id = c_rule_id)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           aau.last_update_date ACTION_USAGE_LUD,
           aau.last_updated_by ACTION_USAGE_LUB
      from ame_action_usages aau
     where aau.rule_id = c_rule_id
       and aau.last_update_date in (select max(last_update_date)
                                      from ame_action_usages aaut
                                     where aaut.rule_id = c_rule_id)
       and rownum < 2;

    rl_lud  date;
    rl_lub  integer;
    ru_lud  date;
    ru_lub  integer;
    cu_lud  date;
    cu_lub  integer;
    au_lud  date;
    au_lub  integer;
    ru_ed   date;

    rule_lud             date;
    rule_lub             integer;
    rule_usage_lud       date;
    rule_usage_lub       integer;
    condition_usage_lud  date;
    condition_usage_lub  integer;
    action_usage_lud     date;
    action_usage_lub     integer;
    rule_usage_ed        date;

    latest_update_date date;
    latest_update_by integer;

  begin

    open c_last_update_date(p_rule_id,p_application_id,p_usage_start_date);
    loop
      fetch c_last_update_date into rl_lud,
                                    rl_lub,
                                    ru_lud,
                                    ru_lub,
                                    ru_ed,
                                    cu_lud,
                                    cu_lub,
                                    au_lud,
                                    au_lub;
      exit when c_last_update_date%notfound;
      if rl_lud is not null then
        rule_lud := rl_lud;
        rule_lub := rl_lub;
      elsif ru_lud is not null then
        rule_usage_lud := ru_lud;
        rule_usage_lub := ru_lub;
        rule_usage_ed := ru_ed;
      elsif cu_lud is not null then
        condition_usage_lud := cu_lud;
        condition_usage_lub := cu_lub;
      elsif au_lud is not null then
        action_usage_lud := au_lud;
        action_usage_lub := au_lub;
      end if;
    end loop;
    close c_last_update_date;

    latest_update_date := rule_lud;
    latest_update_by := rule_lub;

    if condition_usage_lud > latest_update_date then
      latest_update_date := condition_usage_lud;
      latest_update_by := condition_usage_lub;
    end if;

    if action_usage_lud > latest_update_date then
      latest_update_date := action_usage_lud;
      latest_update_by := action_usage_lub;
    end if;

    if rule_usage_lud > latest_update_date then
      latest_update_date := rule_usage_lud;
      latest_update_by := rule_usage_lub;
    end if;

    if rule_usage_ed < latest_update_date then
      latest_update_date := rule_usage_ed;
      latest_update_by := rule_usage_lub;
    end if;

    return latest_update_date;
  end get_rule_last_update_date;

  function get_rule_last_updated_by
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return integer is

  cursor c_last_update_date (c_rule_id integer,c_application_id integer,c_rule_usage_start_date date) is
    select ar.last_update_date RULE_LUD,
           ar.last_updated_by RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_rules ar
     where ar.rule_id = c_rule_id
       and ar.last_update_date in (select max(last_update_date)
                                     from ame_rules art
                                    where art.rule_id = c_rule_id)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           aru.last_update_date RULE_USAGE_LUD,
           aru.last_updated_by RULE_USAGE_LUB,
           aru.end_date RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_rule_usages aru
     where aru.rule_id = c_rule_id
       and aru.item_id = c_application_id
       and aru.start_date = c_rule_usage_start_date
       and aru.start_date < aru.end_date
       and aru.last_update_date in (select max(last_update_date)
                                      from ame_rule_usages arut
                                     where arut.rule_id = c_rule_id
                                       and arut.item_id = c_application_id
                                       and arut.start_date = c_rule_usage_start_date
                                       and arut.start_date < arut.end_date)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           acu.last_update_date CONDITION_USAGE_LUD,
           acu.last_updated_by CONDITION_USAGE_LUB,
           null ACTION_USAGE_LUD,
           null ACTION_USAGE_LUB
      from ame_condition_usages acu
     where acu.rule_id = c_rule_id
       and acu.last_update_date in (select max(last_update_date)
                                      from ame_condition_usages acut
                                     where acut.rule_id = c_rule_id)
       and rownum < 2
    union
    select null RULE_LUD,
           null RULE_LUB,
           null RULE_USAGE_LUD,
           null RULE_USAGE_LUB,
           null RULE_USAGE_ED,
           null CONDITION_USAGE_LUD,
           null CONDITION_USAGE_LUB,
           aau.last_update_date ACTION_USAGE_LUD,
           aau.last_updated_by ACTION_USAGE_LUB
      from ame_action_usages aau
     where aau.rule_id = c_rule_id
       and aau.last_update_date in (select max(last_update_date)
                                      from ame_action_usages aaut
                                     where aaut.rule_id = c_rule_id)
       and rownum < 2;

    rl_lud  date;
    rl_lub  integer;
    ru_lud  date;
    ru_lub  integer;
    cu_lud  date;
    cu_lub  integer;
    au_lud  date;
    au_lub  integer;
    ru_ed   date;

    rule_lud             date;
    rule_lub             integer;
    rule_usage_lud       date;
    rule_usage_lub       integer;
    condition_usage_lud  date;
    condition_usage_lub  integer;
    action_usage_lud     date;
    action_usage_lub     integer;
    rule_usage_ed        date;

    latest_update_date date;
    latest_update_by integer;

  begin

    open c_last_update_date(p_rule_id,p_application_id,p_usage_start_date);
    loop
      fetch c_last_update_date into rl_lud,
                                    rl_lub,
                                    ru_lud,
                                    ru_lub,
                                    ru_ed,
                                    cu_lud,
                                    cu_lub,
                                    au_lud,
                                    au_lub;
      exit when c_last_update_date%notfound;
      if rl_lud is not null then
        rule_lud := rl_lud;
        rule_lub := rl_lub;
      elsif ru_lud is not null then
        rule_usage_lud := ru_lud;
        rule_usage_lub := ru_lub;
        rule_usage_ed := ru_ed;
      elsif cu_lud is not null then
        condition_usage_lud := cu_lud;
        condition_usage_lub := cu_lub;
      elsif au_lud is not null then
        action_usage_lud := au_lud;
        action_usage_lub := au_lub;
      end if;
    end loop;
    close c_last_update_date;

    latest_update_date := rule_lud;
    latest_update_by := rule_lub;

    if condition_usage_lud > latest_update_date then
      latest_update_date := condition_usage_lud;
      latest_update_by := condition_usage_lub;
    end if;

    if action_usage_lud > latest_update_date then
      latest_update_date := action_usage_lud;
      latest_update_by := action_usage_lub;
    end if;

    if rule_usage_lud > latest_update_date then
      latest_update_date := rule_usage_lud;
      latest_update_by := rule_usage_lub;
    end if;

    if rule_usage_ed < latest_update_date then
      latest_update_date := rule_usage_ed;
      latest_update_by := rule_usage_lub;
    end if;

    return latest_update_by;
  end get_rule_last_updated_by;

  function is_rule_updatable
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ) return varchar2 is

    cursor active_rule_cursor (ruleId integer) is
      select rule_id
        from ame_rules
       where rule_id = ruleId
         and (sysdate between start_date and nvl(end_date - (1/86400),sysdate) or
                  (start_date > sysdate and start_date < nvl(end_date,start_date + (1/86400)))
                 );

    cursor active_rule_usage_count_cursor (ruleId integer,applicationId integer,usageStartDate date) is
      select count(rule_id)
        from ame_rule_usages
       where rule_id = ruleId
         and item_id = applicationId
         and start_date = usageStartDate
         and start_date < end_date
         and (sysdate between start_date and nvl(end_date - (1/86400),sysdate) or
              (start_date > sysdate and start_date < nvl(end_date,start_date + (1/86400)))
             );

    dummy_rule_id integer;
    dummy_rule_usage_count integer;

  begin

    open active_rule_cursor(p_rule_id);
    fetch active_rule_cursor into dummy_rule_id;
    if active_rule_cursor%notfound then
      close active_rule_cursor;
      return 'UpdateDisabled';
    end if;
    close active_rule_cursor;

    open active_rule_usage_count_cursor(p_rule_id,p_application_id,p_usage_start_date);
    fetch active_rule_usage_count_cursor into dummy_rule_usage_count;
    close active_rule_usage_count_cursor;
    if dummy_rule_usage_count = 0 then
      return 'UpdateDisabled';
    else
      return 'UpdateEnabled';
    end if;

  end is_rule_updatable;

  function get_rule_last_update_action
    (p_rule_id integer
    ,p_application_id integer
    ,p_usage_start_date date
    ,p_usage_end_date date
    ) return varchar2 is

  cursor c_row_count (c_rule_id integer,c_application_id integer,c_rule_usage_start_date date) is
   select count(ar.rule_id) RULE_COUNT,
          null CONDITION_USAGE_COUNT,
          null ACTION_USAGE_COUNT
     from ame_rules ar
    where ar.rule_id = c_rule_id
      and ar.last_update_date > (c_rule_usage_start_date + (1/86400))
   union
   select null RULE_COUNT,
          count(acu.rule_id) CONDITION_USAGE_COUNT,
          null ACTION_USAGE_COUNT
     from ame_condition_usages acu
    where acu.rule_id = c_rule_id
      and acu.last_update_date > (c_rule_usage_start_date + (1/86400))
   union
   select null RULE_COUNT,
          null CONDITION_USAGE_COUNT,
          count(aau.rule_id) ACTION_USAGE_COUNT
     from ame_action_usages aau
    where aau.rule_id = c_rule_id
      and aau.last_update_date > (c_rule_usage_start_date + (1/86400));
    rl_cnt integer;
    cu_cnt integer;
    au_cnt integer;
    rule_count integer;
    condition_usage_count integer;
    action_usage_count integer;
    latest_action varchar2(10);
  begin
    open c_row_count(p_rule_id,p_application_id,p_usage_start_date);
    loop
      fetch c_row_count into rl_cnt,
                             cu_cnt,
                             au_cnt;
      exit when c_row_count%notfound;
      if rl_cnt is not null then
        rule_count := rl_cnt;
      elsif cu_cnt is not null then
        condition_usage_count := cu_cnt;
      elsif au_cnt is not null then
        action_usage_count := au_cnt;
      end if;
    end loop;
    close c_row_count;
    if p_usage_end_date < sysdate then
      latest_action := 'DELETED';
    elsif (rule_count is not null and rule_count > 0) or
          (condition_usage_count is not null and condition_usage_count > 0) or
          (action_usage_count is not null and action_usage_count > 0) then
      latest_action := 'UPDATED';
    else
      latest_action := 'CREATED';
    end if;
    return latest_action;
  end get_rule_last_update_action;

  function is_valid_attribute(p_attribute_id   in varchar2
                             ,p_application_id in varchar2
                             ,p_allow_all      in varchar2) return varchar2 as
    l_attribute_id   integer;
    l_application_id integer;
    l_item_id        integer;
    return_val        varchar2(30);
    temp_count integer;

    cursor c_sel1(attributeIdIn   in integer
                 ,applicationIdIn in integer) is
      select count(*)
        from ame_attribute_usages
        where attribute_id = attributeIdIn
          and application_id = applicationIdIn
          and sysdate between start_date
                      and nvl(end_date - (1/86400), sysdate);

  begin

    l_attribute_id := to_number(p_attribute_id);
    l_application_id := to_number(p_application_id);

    open c_sel1(l_attribute_id,l_application_id);
    fetch c_sel1 into temp_count;
    if c_sel1%found and
       temp_count > 0 then
      close c_sel1;
      return_val := 'AttributeExists';
      return(return_val);
    end if;
    close c_sel1;

    select count(*)
      into temp_count
      from ame_item_class_usages itu,
          ame_attributes atr
     where itu.item_class_id = atr.item_class_id
       and itu.application_id = l_application_id
       and atr.attribute_id = l_attribute_id
       and sysdate between itu.start_date
                   and nvl(itu.end_date - (1/86400), sysdate)
       and sysdate between atr.start_date
                   and nvl(atr.end_date - (1/86400), sysdate);

    if temp_count = 0 then
      return_val := 'ItemClassNotExists';
      return(return_val);
    end if;

    if p_allow_all = 'yes' then
      return_val := 'NoIssues';
      return(return_val);
    end if;

    select atr.approver_type_id
      into temp_count
      from ame_attributes atr
     where atr.attribute_id = l_attribute_id
       and sysdate between atr.start_date
                   and nvl(atr.end_date - (1/86400), sysdate);

    if temp_count is null then
      return_val := 'NoIssues';
      return(return_val);
    end if;

    select count(*) into temp_count
      from ame_attributes atr,
           ame_approver_types apt
     where atr.approver_type_id = apt.approver_type_id
       and atr.attribute_id = l_attribute_id
       and sysdate between atr.start_date
                   and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between apt.start_date
                   and nvl(apt.end_date - (1/86400), sysdate)
       and apt.orig_system in ('FND_USR','PER');

    if temp_count =0 then
      return_val := 'ApproverTypeNotExists';
      return(return_val);
    else
      return_val := 'NoIssues';
      return(return_val);
    end if;

  exception
    when others then
      null;
  end is_valid_attribute;

  function get_rule_end_date
    (p_rule_id integer
    ) return date as
    l_rule_end_date date;
  begin
    begin
      select max(ar.end_date)
        into l_rule_end_date
        from ame_rules ar
       where rule_id = p_rule_id;
      return l_rule_end_date;
    exception
      when no_data_found then
        return null;
      when too_many_rows then
        return null;
    end;
  end get_rule_end_date;

  function check_seeddb return varchar2 as
  begin
    if fnd_global.resp_name = 'AME Developer' then
      return 'Y';
    end if;
    return 'N';
  end check_seeddb;

  function get_rule_id return number is
  l_rule_id number;
  begin
    if fnd_global.resp_name = 'AME Developer' then
      select min(rule_id) - 1
        into l_rule_id
        from ame_rules;
    else
      select ame_rules_s.nextval
        into l_rule_id
        from sys.dual;
    end if;
    return l_rule_id;
  end get_rule_id;

  function get_condition_id return number is
  l_condition_id number;
  begin
    if fnd_global.resp_name = 'AME Developer' then
      select min(condition_id) - 1
        into l_condition_id
        from ame_conditions;
    else
      select ame_conditions_s.nextval
        into l_condition_id
        from sys.dual;
    end if;
    return l_condition_id;
  end get_condition_id;

  function get_item_class_id return number is
  l_item_class_id number;
  begin
    select max(item_class_id) + 1
      into l_item_class_id
      from ame_item_classes;

    return l_item_class_id;
  end get_item_class_id;

  function is_seed_user
    (p_user_id integer
    ) return number is
  begin
    if p_user_id in (1,2,120,121) then
      return ame_util.seededDataCreatedById;
    else
      return 0;
    end if;
  end is_seed_user;
  function getNextApproverTypeId return integer is
    nextSequence integer;
    countOfIds integer;
  begin
    while true loop
      select ame_approver_types_s.nextval into nextSequence from dual;
      select count(*)
        into countOfIds
          from ame_approver_types
            where approver_type_id = nextSequence;
      if countOfIds = 0 then
        return nextSequence;
      end if;
      end loop;
  end getNextApproverTypeId;
end ame_utility_pkg;

/
