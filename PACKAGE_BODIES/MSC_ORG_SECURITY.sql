--------------------------------------------------------
--  DDL for Package Body MSC_ORG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ORG_SECURITY" AS
/* $Header: MSCORGSB.pls 120.3 2006/10/05 20:35:55 pabram noship $  */
PROCEDURE set_org_security(
                      p_selected_orgs      IN  varchar2
                     ,p_resp_id            IN  varchar2
                     ) IS
i number := 1;
v_len number;
one_len number;
org_id number;
inst_id number;
org_id1 number;
inst_id1 number;
org_inst_id varchar2(100); --5515434 bugfix
org_assigned number :=0;
record_exists number := 0;

-- the other columns have to be null for the record to be considered a
-- org security record

     CURSOR current_orgs (p_resp_id varchar2) is
     select organization_id, sr_instance_id
     from msc_selected_orgs_v mso
      where mso.responsibility_id = p_resp_id;

     CURSOR org_assigned_c(
                                   lorg_id     number,
                                   linst_id    number) IS
     select organization_id
       from msc_selected_orgs_v mso
      where mso.responsibility_id   = trim(p_resp_id)
        and mso.organization_id     = lorg_id
        and mso.sr_instance_id      = linst_id;


     CURSOR record_exists_c(
                                   lorg_id1     number,
                                   linst_id1    number) IS
     select 1
       from msc_org_access
      where responsibility_id     = to_number(trim(p_resp_id))
        and organization_id     = lorg_id1
        and sr_instance_id      = linst_id1;
BEGIN
    -- terminate organizations that are in the table but have not been selected
    -- to be assigned
    OPEN current_orgs (p_resp_id);
    LOOP
      --dbms_output.put_line('starting loop');
      FETCH current_orgs INTO org_id,
                            inst_id;
      EXIT WHEN current_orgs%NOTFOUND;
       --dbms_output.put_line('before creating org_inst');
       org_inst_id := to_char(org_id) || ':' || to_char(inst_id);
       --dbms_output.put_line('org_id =' || org_id);
       --dbms_output.put_line('inst_id =' || inst_id);
       --dbms_output.put_line('instr value ' ||
       --                     instr(p_selected_orgs, org_inst_id,1));
       if instr(p_selected_orgs, org_inst_id,1) = 0 then
            update_row(org_id,
                       inst_id,
                       to_number(p_resp_id),
                       724,
                       sysdate,
                       sysdate-1,
                       'REMOVE');
       end if;
     end loop;
     close current_orgs;
     --dbms_output.put_line('past current orgs cursor');
     -- parse the p_selected_orgs, the format is '201:207;201:208;'
    -- assign orgs that have been selected
    v_len := length(p_selected_orgs);
    while v_len > 1 loop

      one_len := instr(p_selected_orgs,';',1,i+1)-
                          instr(p_selected_orgs,';',1 ,i)-1;

      org_inst_id := trim(substr(p_selected_orgs,
                           instr(p_selected_orgs,';',1,i)+1,one_len));

      org_id := to_number(
                      trim(substr(org_inst_id,1,
                             instr(org_inst_id,':',1)-1)));
      org_id1 := org_id;
      inst_id := to_number( trim(substr(org_inst_id,instr(
                            org_inst_id,':',1)+1)));
      inst_id1 := inst_id;

      i := i+1;
      v_len := v_len - one_len-1;
      --dbms_output.put_line('p_resp_id' || p_resp_id);
      --dbms_output.put_line('org_id' || org_id);
      --dbms_output.put_line('inst_id' || inst_id);
      OPEN org_assigned_c(org_id, inst_id);
      FETCH  org_assigned_c into org_assigned;
      --dbms_output.put_line('rule id is ' || org_assigned);
      if ( org_assigned_c%notfound) then
      --dbms_output.put_line('org not found ' || org_id || '  '|| inst_id);
      -- determine if the record exists
      -- if record exists then update the record
      -- else insert record
         OPEN record_exists_c(org_id, inst_id);
         FETCH  record_exists_c into record_exists;
         --dbms_output.put_line('rule id is ' || org_assigned);
         if ( record_exists_c%notfound) then
           --dbms_output.put_line('record not found ' || org_id || '  '||
           --                     inst_id);
           insert_row(org_id,
                      inst_id,
                      to_number(p_resp_id),
                      724,
                      sysdate,
                      to_date(null)
                     );
        else
           --dbms_output.put_line('record found ' || org_id || '  '|| inst_id);
           update_row( org_id1,
                       inst_id1,
                       to_number(p_resp_id),
                       724,
                       sysdate,
                       to_date(null),
                       'ADD'
                      );
        end if;
       CLOSE  record_exists_c;
        --else
        --dbms_output.put_line('found ' || org_id || '  '|| inst_id);
      end if;
      CLOSE  org_assigned_c;
    end loop ;

-- need to add exception clause
Exception when others then
      raise_application_error(-20000,sqlerrm||':'||
                              'parameters passed: ' ||' ' ||
                              'p_selected_orgs =>' || p_selected_orgs ||'  ' ||
                              'p_resp_id=>' || p_resp_id);

END set_org_security;


procedure get_resp_id   (p_resp            IN  varchar2,
                         p_resp_id         OUT NoCopy varchar2) is
-- this procedure gets the responsibility id given the responsibility name
-- it returns '-1' if no responsibility exists with the given name in MSC
lquery_id number ;
cursor resp_c is
select resp.responsibility_id
from fnd_responsibility_tl resp
where resp.responsibility_name = p_resp;
begin
  open resp_c;
  fetch resp_c into p_resp_id;

  if resp_c%notfound then
    p_resp_id := '-1';
  end if;
  close resp_c;
Exception when others then
      raise_application_error(-20000,sqlerrm||':'||
                              'parameter passed: ' ||' ' ||
                              p_resp);
end get_resp_id;


procedure insert_row (p_organization_id in number,
                      p_sr_instance_id  in number,
                      p_responsibility_id in number,
                      p_resp_appl_id in number,
                      p_eff_from_date in date,
                      p_eff_to_date in date)

is
v_statement varchar2(4000);

cursor c_resp_appl_id is
select application_id
from fnd_responsibility
where responsibility_id = p_responsibility_id;

l_resp_appl_id number;
begin
  open c_resp_appl_id;
  fetch c_resp_appl_id into l_resp_appl_id;
  close c_resp_appl_id;

  if (l_resp_appl_id is null) then
    l_resp_appl_id := p_resp_appl_id;
  end if;

 v_statement :=  'insert into msc_org_access(' ||
            'ORGANIZATION_ID' ||
           ',SR_INSTANCE_ID' ||
           ',RESPONSIBILITY_ID' ||
           ',RESP_APPLICATION_ID' ||
           ',EFFECTIVE_FROM_DATE' ||
           ',EFFECTIVE_TO_DATE' ||
           ',LAST_UPDATE_DATE' ||
           ',LAST_UPDATED_BY' ||
           ',CREATION_DATE' ||
           ',CREATED_BY' ||
           ',LAST_UPDATE_LOGIN' ||
           ')'  ||
           'values ( ' ||
           ' :1' ||
           ',:2' ||
           ',:3' ||
           ',:4' ||
           ',:5' ||
           ',:6' ||
           ',:7' ||
           ',:8' ||
           ',:9' ||
           ',:10' ||
           ',:11' ||
           ')';
EXECUTE IMMEDIATE v_statement USING
        p_organization_id,
        p_sr_instance_id,
        p_responsibility_id,
        l_resp_appl_id,
        p_eff_from_date,
        p_eff_to_date,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.user_id;

EXCEPTION
    when others then
      raise_application_error(-20000,sqlerrm||':'||v_statement  ||
        'p_organization_id'  ||p_organization_id ||' ' ||
        'p_sr_instance_id'    ||p_sr_instance_id ||' ' ||
        'p_responsibility_id' ||p_responsibility_id ||' ' ||
        'p_resp_application_id' ||p_resp_appl_id ||' ' ||
        'p_effective_from_date' ||p_eff_from_date ||' ' ||
        'p_effective_to_date' || p_eff_to_date);
end insert_row;

procedure update_row (p_organization_id in number,
                      p_sr_instance_id  in number,
                      p_responsibility_id in number,
                      p_resp_appl_id in number,
                      p_eff_from_date in date,
                      p_eff_to_date in date,
                      p_action varchar2)

is
v_statement varchar2(2000);

cursor c_resp_appl_id is
select application_id
from fnd_responsibility
where responsibility_id = p_responsibility_id;

l_resp_appl_id number;
begin

  open c_resp_appl_id;
  fetch c_resp_appl_id into l_resp_appl_id;
  close c_resp_appl_id;

  if (l_resp_appl_id is null) then
    l_resp_appl_id := p_resp_appl_id;
  end if;

 v_statement :=  'update msc_org_access set' ;
 if p_action = 'ADD' then
   v_statement := v_statement ||' effective_from_date= :1,';
 end if;

   v_statement := v_statement ||
           '    effective_to_date= :2,' ||
           '    LAST_UPDATE_DATE = :3,' ||
           '    LAST_UPDATED_BY  = :4,' ||
           '    LAST_UPDATE_LOGIN= :5 ' ||
           'where responsibility_id = :6 and ' ||
                 'organization_id   = :7 and ' ||
                 'sr_instance_id    = :8 and ' ||
                 'resp_application_id = :9';
if p_action='ADD' then
     EXECUTE IMMEDIATE v_statement USING
                  p_eff_from_date,
                  p_eff_to_date,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.user_id,
                  p_responsibility_id,
                  p_organization_id,
                  p_sr_instance_id,
                  l_resp_appl_id;
else
     EXECUTE IMMEDIATE v_statement USING
                  p_eff_to_date,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.user_id,
                  p_responsibility_id,
                  p_organization_id,
                  p_sr_instance_id,
                  l_resp_appl_id;
end if;
EXCEPTION
    when others then
      raise_application_error(-20000,sqlerrm||':'||v_statement||
        'p_organization_id'  ||p_organization_id ||' ' ||
        'p_sr_instance_id'    ||p_sr_instance_id ||' ' ||
        'p_responsibility_id' ||p_responsibility_id ||' ' ||
        'p_resp_application_id' ||p_resp_appl_id ||' ' ||
        'p_effective_from_date' ||p_eff_from_date ||' ' ||
        'p_effective_to_date' || p_eff_to_date);
end update_row;



end msc_org_security;

/
