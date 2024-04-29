--------------------------------------------------------
--  DDL for Package Body PA_CC_TP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_TP_UTILS" AS
/* $Header: PAXTPUTB.pls 120.4 2005/10/06 03:51:30 rgandhi noship $ */

------------------------------------------------------------------------
---  is_rule_in_schedule_lines_
-----This function returns 'Y' if the transfer price rule is used in
-----transfer price schedule lines
------------------------------------------------------------------------
FUNCTION  is_rule_in_schedule_lines (p_rule_id IN NUMBER)
                                           RETURN varchar2
IS

CURSOR c_tp_rule IS
   select '1'
   from dual
   where exists (select 'Y'
                 from pa_cc_tp_schedule_lines sl
                 where sl.labor_tp_rule_id=p_rule_id
                 or    sl.nl_tp_rule_id=p_rule_id);

v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN
  v_ret_code := 'N';

  OPEN  c_tp_rule ;
  FETCH  c_tp_rule INTO v_dummy;
  IF c_tp_rule%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE  c_tp_rule;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END is_rule_in_schedule_lines ;


------------------------------------------------------------------------
--- function get_lowest_org_level
-----This function returns lowest org level( 'ORG','OU','LE',or 'BG')for given organization_id
-----if an organization has been classified in multiple levels
------------------------------------------------------------------------
function get_lowest_org_level(p_organization_id in number) return varchar2
is

   cursor c_ou is
     select '1' from dual
     where exists (select 'Y'
                    from hr_operating_units o
              where o.business_group_id=decode(G_global_access,'Y',business_group_id,G_business_group_id)
                and  o.organization_id=p_organization_id);
   cursor c_le is
     select '1' from dual
     where exists (select 'Y'
                    from hr_legal_entities  o
            where o.business_group_id=decode(G_global_access,'Y',business_group_id,G_business_group_id)
            and o.organization_id=p_organization_id);

    cursor c_bg is
      select '1' from dual
       where exists (select 'Y'
                   from hr_organization_units o1,
                            hr_organization_information o2
                   where o1.organization_id=o2.organization_id
                    and o1.organization_id=p_organization_id
                    and    o2.org_information_context||'' ='CLASS'
                     and o2.org_information1='HR_BG');

   v_ret_code  varchar2(3);
   v_dummy     varchar2(1);

  begin

    v_ret_code:='ORG';
    return v_ret_code;

 /* Commented for Legal Entity Changes. After 12.0 TP SCHEDULE WILL
    LOOK only in ORG HIERARCHY AND NOT IN OU,LE,BG
    open  c_ou;
    fetch c_ou into v_dummy;
    if c_ou%FOUND then
      v_ret_code:='OU';
      return v_ret_code;
    else
        open c_le;
        fetch c_le into v_dummy;
        if c_le%FOUND then
           v_ret_code:='LE';
            return v_ret_code;
        else
           if p_organization_id=G_business_group_id then
              v_ret_code:='BG';
              return v_ret_code;
           else
              open c_bg;
              fetch c_bg into v_dummy;
              if c_bg%found and g_global_access='Y' then
                 v_ret_code:='BG';
                 return v_ret_code;
              end if;
           end if;
        end if;
     end if;
     close c_le;
     close c_ou;
     return v_ret_code;*/
 exception
    when no_data_found then
       v_ret_code:='ORG';
       return v_ret_code;
    when others then
        raise;
end get_lowest_org_level;


-------------------------------------------------------------------
----procedure pre_insert_schedule_lines
---- delete affected rows in schedule line lookup table when shcedule lines are inserted or updated
---------------------------------------------------------------------------------
procedure pre_insert_schedule_lines(p_tp_schedule_id IN number,
                                    p_prvdr_organization_id IN number,
                                    p_recvr_organization_id  in number)
is
 v_prvdr_org_level varchar2(4);
 v_recvr_org_level varchar2(4);

begin
    v_prvdr_org_level :=get_highest_org_level(p_prvdr_organization_id);
 if p_recvr_organization_id is not null then
    v_recvr_org_level :=get_highest_org_level(p_recvr_organization_id);
 else
    v_recvr_org_level :='NULL';
 end if;

 if v_prvdr_org_level='ORG' and v_recvr_org_level='ORG' then
    delete from pa_cc_tp_schedule_line_lkp
     where prvdr_organization_id=p_prvdr_organization_id
     and   recvr_organization_id=p_recvr_organization_id
     and   tp_schedule_id=p_tp_schedule_id;

 /* Commented for Legal Entity Changes. After 12.0 TP SCHEDULE WILL
    LOOK only in ORG HIERARCHY AND NOT IN OU,LE,BG
 elsif v_prvdr_org_level='ORG' and v_recvr_org_level='OU' then
     delete from pa_cc_tp_schedule_line_lkp
     where prvdr_organization_id=p_prvdr_organization_id
     and   recvr_org_id=p_recvr_organization_id
     and   tp_schedule_id=p_tp_schedule_id;

 elsif v_prvdr_org_level='ORG' and v_recvr_org_level='LE' then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
      and   prvdr_organization_id=p_prvdr_organization_id
      and  recvr_org_id in
                ( select organization_id
                  from hr_operating_units h
                  where h.legal_entity_id=to_char(p_recvr_organization_id));

 elsif (v_prvdr_org_level='ORG' and v_recvr_org_level='BG') then
    delete from pa_cc_tp_schedule_line_lkp
    where tp_schedule_id=p_tp_schedule_id
     and prvdr_organization_id=p_prvdr_organization_id
     and recvr_org_id in
            (select organization_id
              from hr_operating_units h
              where h.business_group_id =p_recvr_organization_id);*/

 elsif (v_prvdr_org_level='ORG' and v_recvr_org_level='NULL') then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
      and   PRVDR_ORGANIZATION_ID =p_prvdr_organization_id;

 /* Commented for Legal Entity Changes. After 12.0 TP SCHEDULE WILL
    LOOK only in ORG HIERARCHY AND NOT IN OU,LE,BG
 elsif v_prvdr_org_level='OU' and v_recvr_org_level='OU' then
     delete from pa_cc_tp_schedule_line_lkp
     where prvdr_org_id=p_prvdr_organization_id
     and   recvr_org_id=p_recvr_organization_id
     and   tp_schedule_id=p_tp_schedule_id;

 elsif v_prvdr_org_level='OU' and v_recvr_org_level='LE' then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
      and   prvdr_org_id=p_prvdr_organization_id
      and  recvr_org_id in
                ( select organization_id
                  from hr_operating_units h
                  where h.legal_entity_id=to_char(p_recvr_organization_id));

 elsif (v_prvdr_org_level='OU' and v_recvr_org_level='BG')  then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
      and PRVDR_ORG_ID=p_prvdr_organization_id
      and recvr_org_id in
            (select organization_id
             from hr_operating_units h
              where h.business_group_id =p_recvr_organization_id);

 elsif (v_prvdr_org_level='OU' and v_recvr_org_level='NULL') then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
      and    PRVDR_ORG_ID=p_prvdr_organization_id;

 elsif v_prvdr_org_level='LE' and v_recvr_org_level='LE' then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
       and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.legal_entity_id=to_char(p_prvdr_organization_id))
       and recvr_org_id in
             (select organization_id
              from  hr_operating_units h
              where h.legal_entity_id=to_char(p_recvr_organization_id));
 elsif (v_prvdr_org_level='LE' and v_recvr_org_level='BG') then
     delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
       and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.legal_entity_id=to_char(p_prvdr_organization_id))
       and recvr_org_id in
             (select organization_id from  hr_operating_units h
              where h.business_group_id=p_recvr_organization_id);

 elsif (v_prvdr_org_level='LE' and v_recvr_org_level='NULL') then
       delete from pa_cc_tp_schedule_line_lkp
       where tp_schedule_id=p_tp_schedule_id
        and  prvdr_org_id in
             (select organization_id
               from  hr_operating_units h
               where h.legal_entity_id =to_char(p_prvdr_organization_id));

 elsif  (v_prvdr_org_level='BG' and v_recvr_org_level='BG') then
       delete from pa_cc_tp_schedule_line_lkp
       where tp_schedule_id=p_tp_schedule_id
        and  prvdr_org_id in
             (select organization_id
               from  hr_operating_units h
               where h.business_group_id =p_prvdr_organization_id)
        and recvr_org_id in
              (select organization_id
               from  hr_operating_units h
               where h.business_group_id =p_recvr_organization_id);

 elsif  (v_prvdr_org_level='BG' and  v_recvr_org_level='NULL') then
        delete from pa_cc_tp_schedule_line_lkp
          where tp_schedule_id=p_tp_schedule_id
          and prvdr_org_id in
             (select organization_id
               from  hr_operating_units h
               where h.business_group_id =p_prvdr_organization_id);

Move the end of comment from here to the end for bug 4654754
--
-- The following cases are functionally not allowed to define.
-- But since an org can be at any level ( BG / LE / OU / ORG ) and get_highest_org_level
-- would give the maximum level to which an org is defined, the following cases arise
--

 elsif  (v_prvdr_org_level = 'BG' and v_recvr_org_level = 'LE') then
     delete from pa_cc_tp_schedule_line_lkp
     where tp_schedule_id=p_tp_schedule_id
      and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.business_group_id =p_prvdr_organization_id)
          and recvr_org_id  in
                        (select organization_id
                          from  hr_operating_units h
                          where h.legal_entity_id= to_char(p_prvdr_organization_id));

 elsif  (v_prvdr_org_level = 'BG' and v_recvr_org_level = 'OU') then
     delete from pa_cc_tp_schedule_line_lkp
     where tp_schedule_id=p_tp_schedule_id
      and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.business_group_id =p_prvdr_organization_id)
        and recvr_org_id  =p_recvr_organization_id;

 elsif  (v_prvdr_org_level = 'BG' and v_recvr_org_level = 'ORG') then
     delete from pa_cc_tp_schedule_line_lkp
     where tp_schedule_id=p_tp_schedule_id
      and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.business_group_id =p_prvdr_organization_id)
        and recvr_organization_id  =p_recvr_organization_id;

elsif (v_prvdr_org_level = 'LE' and v_recvr_org_level = 'OU') then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
       and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.legal_entity_id=to_char(p_prvdr_organization_id))
       and recvr_org_id = p_recvr_organization_id ;
elsif (v_prvdr_org_level = 'LE' and v_recvr_org_level = 'ORG') then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
       and  prvdr_org_id in
            (select organization_id
              from  hr_operating_units h
              where h.legal_entity_id=to_char(p_prvdr_organization_id))
       and recvr_organization_id = p_recvr_organization_id ;
elsif (v_prvdr_org_level = 'OU' and v_recvr_org_level = 'ORG') then
      delete from pa_cc_tp_schedule_line_lkp
      where tp_schedule_id=p_tp_schedule_id
       and  prvdr_org_id = p_prvdr_organization_id
       and recvr_organization_id = p_recvr_organization_id ; End of 4654754 */
else
       null;
       ---anything need to do here ??
end if;

end pre_insert_schedule_lines;

-----------------------------------------------------------------------
----procedure pre_delete_schedule_lines
-----delete the row from schedule line lookup table if a schedule line is to be deleted from
-----schedule line table
------------------------------------------------------------------------
procedure pre_delete_schedule_lines(p_tp_schedule_id in number,
                                    p_tp_schedule_line_id in number)
is
begin
      delete from pa_cc_tp_schedule_line_lkp
      where  tp_schedule_id=p_tp_schedule_id
       and   tp_schedule_line_id=p_tp_schedule_line_id;

end pre_delete_schedule_lines;


-------------------------------------------------------
---procedure check_delete_tp_schedule_ok is an central API which check if a transfer
---price schedule has been used in any other features. If yes, then it will return
----error code and error stage
----------------------------------------------------------
procedure check_delete_tp_schedule_ok(p_tp_schedule_id in number,
                                      x_error_code  in out NOCOPY number,/*File.sql.39*/
                                      x_error_stage  in out NOCOPY varchar2,/*File.sql.39*/
                                      x_error_stack  in out NOCOPY varchar2)/*File.sql.39*/
IS

old_stack           varchar2(630);
l_return_val        varchar2(1);

begin
        x_error_code := 0;
        old_stack := x_error_stack;
        x_error_stack := x_error_stack || '->check_delete_tp_schedule_ok';

  -- Check if schedule is used in projects or tasks
        x_error_stage := 'check if projects or tasks use transfer price schedule'||p_tp_schedule_id ;
        l_return_val := pa_project_utils.is_tp_schd_proj_task(p_tp_schedule_id);
        if ( l_return_val = 'Y' ) then
            x_error_code := 10;
            x_error_stage := 'PA_CC_TP_SCHEDULE_IN_PROJ';
            return;
        end if;
exception
        when others then
                x_error_code := SQLCODE;
                rollback;
                return;
end check_delete_tp_schedule_ok;

-------------------------------------------------------
---procedure check_del_update_rule_ok is an central API which check if a transfer
---price rule has been used in schedule line or any other features. If yes, then it will return
----error code and error stage
----------------------------------------------------------
procedure check_del_update_rule_ok(p_tp_rule_id in number,
                                      x_error_code  in out NOCOPY number,/*File.sql.39*/
                                      x_error_stage  in out NOCOPY varchar2,/*File.sql.39*/
                                      x_error_stack  in out NOCOPY varchar2/*File.sql.39*/)
IS

old_stack           varchar2(630);
l_return_val        varchar2(1);

begin
        x_error_code := 0;
        old_stack := x_error_stack;
        x_error_stack := x_error_stack || '->check_del_update_rule_ok';

  -- Check if rule is used in schedule lines
        x_error_stage := 'check if schedule lines use rule: '||p_tp_rule_id ;
        l_return_val:=is_rule_in_schedule_lines(p_tp_rule_id);
        if ( l_return_val = 'Y' ) then
            x_error_code := 10;
            x_error_stage := 'PA_CC_TP_NO_DELETE_RULE';
            return;
        end if;
exception
        when others then
                x_error_code := SQLCODE;
                rollback;
                return;
end check_del_update_rule_ok;


------------------------------------------
----function get_highest_org_level returns the highest level of the organization
-----if it has been classified at diffierent levels
-----------------------------------------------------------
function get_highest_org_level(p_organization_id in number)
                                         return varchar2
IS
  cursor c_bg is
      select '1' from dual
       where exists (select 'Y'
                   from hr_organization_units o1,
                        hr_organization_information o2
                   where o1.organization_id=o2.organization_id
                    and o1.organization_id=p_organization_id
                    and    o2.org_information_context||''='CLASS'
                    and o2.org_information1='HR_BG');

  cursor c_ou is
     select '1' from dual
     where exists (select 'Y'
                   from hr_operating_units
                   where organization_id=p_organization_id
                  and business_group_id=decode(G_global_access,'Y',business_group_id,G_business_group_id));
 cursor c_le is
     select '1' from dual
     where exists (select 'Y'
                   from hr_legal_entities
                   where organization_id=p_organization_id
                   and business_group_id=decode(G_global_access,'Y',business_group_id,G_business_group_id));

   v_ret_code  varchar2(3);
   v_dummy     varchar2(1);
begin

/* Commented for Legal Entity Changes. After 12.0 TP SCHEDULE WILL
    LOOK only in ORG HIERARCHY AND NOT IN OU,LE,BG

 if (p_organization_id=G_business_group_id  )  then
        v_ret_code:='BG';
        return(v_ret_code);
 else
   open c_bg;
   fetch c_bg into v_dummy;
   if (c_bg%found and G_global_access='Y') then
        v_ret_code:='BG';
        return(v_ret_code);
   else
     open c_le;
     fetch c_le into v_dummy;
     if c_le%found then
         v_ret_code:='LE';
         return (v_ret_code);
     else
        open c_ou;
        fetch c_ou into v_dummy;
        if c_ou%found then
           v_ret_code:='OU';
           return (v_ret_code);
        else
           v_ret_code:='ORG';
           return (v_ret_code);
        end if;
     end if;
   end if;
 end if;
   close c_le;

   close c_ou;*/

 v_ret_code:='ORG';
 return (v_ret_code);

exception
    when no_data_found then
       v_ret_code:='ORG';
       return v_ret_code;
    when others then
        raise;
end get_highest_org_level;

END  PA_CC_TP_UTILS;


/
