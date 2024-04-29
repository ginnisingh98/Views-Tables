--------------------------------------------------------
--  DDL for Package Body IGW_PROP_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_APPROVALS_PVT" as
 /* $Header: igwvpapb.pls 115.10 2002/11/14 18:51:47 vmedikon ship $*/



Procedure start_approval_process (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_proposal_id              	  IN	 	NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)  is


  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_short_name		     VARCHAR2(30);
  l_message_name 	     VARCHAR2(200);

BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT start_approval;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;

/*
-- first validate user rights

        VALIDATE_LOGGED_USER_RIGHTS
			(p_proposal_id		 =>	p_proposal_id
			,x_return_status         =>	x_return_status);

  check_errors;
*/

------------------------------------- value_id conversion ---------------------------------

-------------------------------------------- validations -----------------------------------------------------
 --  dbms_output.put_line('before call to start approval');
            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
                        		start_approval (
              				 p_proposal_id       	=>	p_proposal_id
 					,p_error_message	=>	l_msg_data
              				,p_return_status	=>	l_return_status);

	    end if;

 --   dbms_output.put_line(l_msg_data);
 --   dbms_output.put_line(l_message_name);

   if (l_return_status = 'E') then
         fnd_msg_pub.initialize;
         fnd_message.parse_encoded(encoded_message   =>   l_msg_data,
         			   app_short_name    =>   l_short_name,
         			   message_name      =>   l_message_name);
    --    dbms_output.put_line(l_msg_data);
    --    dbms_output.put_line(l_message_name);

        fnd_message.set_name(l_short_name, l_message_name);
        fnd_msg_pub.add;
        raise  fnd_api.g_exc_error;
    elsif (l_return_status = 'U') then
         fnd_msg_pub.initialize;
         fnd_message.parse_encoded(encoded_message   =>   l_msg_data,
         			   app_short_name    =>   l_short_name,
         			   message_name      =>   l_message_name);
      --  dbms_output.put_line(l_msg_data);
      --  dbms_output.put_line(l_message_name);

        fnd_message.set_name('l_short_name', l_message_name);
        fnd_msg_pub.add;
        raise  fnd_api.g_exc_unexpected_error;
    elsif (l_return_status = 'S') then
        update igw_proposals_all set proposal_status = 'I' where proposal_id = p_proposal_id;
    end if;


-- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;

  -- set x_msg_count and x_msg_data
    x_msg_count := 0;
    x_msg_data := 'Proposal Submitted for Approval';




EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO start_approval;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

          x_msg_count := 1;
          x_msg_data := l_message_name;





  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO start_approval;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       x_msg_count := 1;
       x_msg_data := l_message_name;

  /*     fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_APPROVALS_PVT',
                            p_procedure_name    =>    'START_APPROVAL',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			         p_data		=>	x_msg_data);
 */

END  start_approval_process;

--------------------------------------------------------------------------------------------------------

PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,p_logged_user_id         IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2) is

x		VARCHAR2(1);
y		VARCHAR2(1);

BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;

    select x into y
    from igw_prop_user_roles  ppr,
         igw_prop_users  ppu
    where ppr.proposal_id = p_proposal_id  	AND
         ppr.proposal_id = ppu.proposal_id      AND
         ppr.user_id = ppu.user_id   		AND
         ppr.role_id in (0,2)		        AND
         ppr.user_id = p_logged_user_id		AND
         sysdate >= ppu.start_date_active  	AND
         sysdate <= nvl(ppu.end_date_active, sysdate);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('IGW', 'IGW_NO_RIGHTS');
    fnd_msg_pub.add;

  WHEN too_many_rows THEN
      NULL;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_APPROVALS_PVT',
                            p_procedure_name => 'VALIDATE_LOGGED_USER_RIGHTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise fnd_api.g_exc_unexpected_error;
END VALIDATE_LOGGED_USER_RIGHTS;

 --------------------------------------------------------------------------------------------------------------
procedure start_approval(p_proposal_id   in   number,
                         p_error_message out NOCOPY  varchar2,
                         p_return_status out NOCOPY  varchar2) is


 l_proposal_status      	varchar2(1);
 l_budget_complete      	varchar2(1);
 l_budget_not_applicable	varchar2(1);
 l_narrative_complete      	varchar2(1);
 l_narrative_not_applicable	varchar2(1);
 l_signing_official_id  	number;
 l_admin_official_id    	number;


 l_run_id            number;
 l_invalid_flag      varchar2(1);
 l_rules_found       varchar2(1);
 l_error_message     varchar2(2000);
 l_return_status     varchar2(1);
 l_msg_count         number;
 l_count             number;


begin
 -- Assign proposal_id to global variable
 g_proposal_id := p_proposal_id;

/*
 -- do not rout the proposal if not submitted by Proposal Owner
 -- or the Proposal Manager

 select count(*)
 into   l_count
 from   igw_prop_user_roles  ppr,
        igw_prop_users       ppu
 where  ppr.proposal_id = p_proposal_id
 and    ppr.proposal_id = ppu.proposal_id
 and    ppr.user_id = ppu.user_id
 and    (ppr.role_id = 0 or ppr.role_id = 2)
 and    ppu.user_id = fnd_global.user_id
 and    sysdate >= ppu.start_date_active
 and    sysdate <= nvl(ppu.end_date_active,sysdate);


 if l_count = 0 then

   fnd_message.set_name('IGW','IGW_ROUT_PR_OWNER_CAN_SUBMIT');
   p_error_message := fnd_message.get_encoded;
   p_return_status := 'E';
   return;

 end if;
*/
 -- do not rout the proposal if the proposal_status = 'I' or 'A'

 select ipa.proposal_status,
        ipa.signing_official_id,
        ipa.admin_official_id
 into   l_proposal_status,
        l_signing_official_id,
        l_admin_official_id
 from   igw_proposals_all  ipa
 where ipa.proposal_id = g_proposal_id;

  -- do not rout the proposal if budget is incomplete
   select complete,
          not_applicable
   into l_budget_complete,
        l_budget_not_applicable
   from igw_prop_checklist
   where document_type_code = 'BUDGETS' and
   proposal_id = g_proposal_id;

 if l_proposal_status = 'I' then

   fnd_message.set_name('IGW','IGW_ROUT_IPR_CANNOT_SUBMIT');
   p_error_message := fnd_message.get_encoded;
   p_return_status := 'E';
   return;

 elsif l_proposal_status = 'A' then

   fnd_message.set_name('IGW','IGW_ROUT_APR_CANNOT_SUBMIT');
   p_error_message := fnd_message.get_encoded;
   p_return_status := 'E';
   return;


 elsif ((l_budget_complete = 'N') AND (l_budget_not_applicable = 'N')) then

   fnd_message.set_name('IGW','IGW_ROUT_BUDGET_INCOMPLETE');
   p_error_message := fnd_message.get_encoded;
   p_return_status := 'E';
   return;

 end if;

 -- get the validation business rules

-- dbms_output.put_line('Calling Validation ...');
 get_business_rules('V',l_run_id,l_invalid_flag,l_rules_found,l_error_message);

 if l_invalid_flag = 'Y' then
   p_error_message := l_error_message;
   p_return_status := 'E';
   return;
 end if;

 --dbms_output.put_line('################### p_return_status ' || p_return_status);

 -- get the routing business rules

-- dbms_output.put_line('Calling routing ....');
 get_business_rules('R',l_run_id,l_invalid_flag,l_rules_found,l_error_message);

-- dbms_output.put_line('# of rules found='||l_rules_found);

 if l_rules_found = 'T'  then

   -- get the notification business rules
   l_invalid_flag  := null;
   l_rules_found := null;
   l_error_message := null;

 --  dbms_output.put_line('Calling notification .........');

   get_business_rules('N',l_run_id,l_invalid_flag,l_rules_found,l_error_message);

 --  dbms_output.put_line('After Calling notification .........');

   -- insert into wf_local_roles and wf_local_user_roles table
   populate_local_wf_tables(l_run_id);

 --   dbms_output.put_line('After populate local tables.');

   -- Assign Proposal Signing Official role(role_id=3) to Proposal Signing Official and Administrative Official
   assign_so_role(l_signing_official_id,l_admin_official_id);
 --  dbms_output.put_line('After assigning signing official');

   -- commit before invoking the workflow
   ----commit;
   -- call workflow
 --  dbms_output.put_line('Calling workflow .........');
   igw_workflow.start_workflow(p_proposal_id,l_run_id);

 else

   fnd_message.set_name('IGW','IGW_ROUT_NO_STOPS_FOUND');

   p_error_message := fnd_message.get_encoded;
   p_return_status := 'E';
   return;
 end if;

 p_return_status := 'S';

 -- update the status to I (Approval In-Progress) in igw_prop_approval_runs
 -- and igw_proposals_all

/* update igw_prop_approval_runs
 set status_code = 'I',
     status_date = sysdate
 where run_id = l_run_id;

 commit; */

exception
  when others then

  --  dbms_output.put_line('Inside when other exception');
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','START_APPROVAL');

    p_error_message := fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                                       p_encoded       =>  FND_API.G_TRUE);

    p_return_status := 'U';
  --  dbms_output.put_line('p_error_message -->  ' || p_error_message);
   -- dbms_output.put_line('p_return_status --> ' || p_return_status  );
 --   raise;
end start_approval;
--------------------------------------------------------------------------------------------------------------
procedure get_business_rules(p_rule_type     in     varchar2,
                             p_run_id        in out NOCOPY number,
                             p_invalid_flag  out NOCOPY    varchar2,
                             p_rules_found   out NOCOPY    varchar2,
                             p_error_message out NOCOPY    varchar2) is


 l_org_id                 number(15);
 l_rule_name              varchar2(50);
 l_rule_id                number(15);
 l_map_id                 number(15);
 l_valid_flag             varchar2(1);
 l_execute_result         varchar2(5);
 l_org_name               hr_all_organization_units.NAME%TYPE;
 l_map_seq_number         number := 0;
 l_wf_role_name           varchar2(100);
 l_wf_display_role_name   varchar2(240);


 l_description            varchar2(200);
 l_level_id               number(4);
 l_user_name              varchar2(100);
 l_run_number             number(4);
 l_dummy                  varchar2(1);
 l_user_id                number(15);

 cursor get_business_rules is
 select hou.name,
        pbr.rule_name,
        pbr.rule_id,
        pbr.map_id,
        map.description,
        pbr.valid_flag
 from   hr_organization_units    hou,
        igw_org_maps_all        map,
        igw_business_rules_all  pbr
 where  pbr.organization_id = l_org_id
 and    pbr.map_id = map.map_id(+)
 and    pbr.organization_id = hou.organization_id
 and    nvl(pbr.end_date_active,sysdate) >= sysdate
 and    pbr.rule_type = p_rule_type
 order by pbr.rule_sequence_number;


 cursor get_map_details is
 select pom.stop_id,
        pom.user_name,
        fus.user_id,
        pom.approver_type
 from   fnd_user   fus,
        igw_org_map_details pom
 where  pom.user_name = fus.user_name
 and    pom.map_id = l_map_id;

 cursor next_run_number is
 select nvl(max(run_number),0) + 1
 from   igw_prop_approval_runs
 where  proposal_id = g_proposal_id;


 cursor user_exists is
 select 'x'
 from   igw_prop_users
 where  proposal_id = g_proposal_id
 and    user_id = l_user_id;


 cursor role_exists(l_role_id in number) is
 select 'x'
 from   igw_prop_user_roles
 where  proposal_id = g_proposal_id
 and    user_id = l_user_id
 and    role_id = l_role_id;

begin

  -- get the starting organization_id
  select lead_organization_id
  into   l_org_id
  from   igw_proposals_all
  where  proposal_id = g_proposal_id;
  --dbms_output.put_line('Lead Org = '||to_char(l_org_id));


  loop
    open get_business_rules;
    loop
      fetch get_business_rules into l_org_name,l_rule_name,l_rule_id,l_map_id,
                                    l_description,l_valid_flag;

      if get_business_rules%notfound then

       --dbms_output.put_line('No business rules found .....');


        close get_business_rules;
        exit;
      end if;

      --dbms_output.put_line('Org Id '||l_org_name||' Rule Id '||to_char(l_rule_id));
      l_execute_result := execute_business_rule(l_rule_id);
      --dbms_output.put_line('The output of execute_result='||l_execute_result);


      -- If rule_type = 'V' and the function returns 'T', then continue
      -- If rule_type = 'V' and the function returns 'F', then display error
      -- If rule_type = 'N' or 'R' and the function returns 'F', then continue
      -- If rule_type = 'N' or 'R' and the function returns 'T', then
      -- insert row in igw_prop_maps and igw_prop_map_stops table

      if  (p_rule_type = 'V' and l_execute_result = '1=2' and l_valid_flag = 'V') or
          (p_rule_type = 'V' and l_execute_result = '1=1' and l_valid_flag = 'I') then


        fnd_message.set_name('IGW','IGW_ROUT_VALIDATION_FAILED');
        fnd_message.set_token('RULE_NAME',l_rule_name);
        fnd_message.set_token('ORGANIZATION_NAME',l_org_name);
        p_error_message := fnd_message.get_encoded;

        close get_business_rules;
        p_invalid_flag := 'Y';
        exit;


      elsif  (p_rule_type = 'N' or p_rule_type = 'R') and l_execute_result = '1=1' then

        if p_rule_type = 'N' then
          l_map_seq_number := 1;
        elsif p_rule_type = 'R' then
          l_map_seq_number := l_map_seq_number + 1;
          p_rules_found := 'T';
          if l_map_seq_number = 1 then
            select igw_prop_approval_runs_s.nextval
            into p_run_id
            from dual;

            open next_run_number;
            fetch next_run_number into l_run_number;
            close next_run_number;

            -- insert into igw_prop_approval_runs
            insert into igw_prop_approval_runs(run_id,proposal_id,
                  run_number,status_code,status_date) values (
            p_run_id,g_proposal_id,l_run_number,'I',sysdate);
          end if;
        end if;

        insert into igw_prop_maps(prop_map_id,proposal_id,description,
           map_type,map_sequence_number,run_id,approval_status,
           last_update_date,last_updated_by,creation_date,created_by,
           last_update_login)
        values(
           igw_prop_maps_s.nextval,g_proposal_id,l_description,
           p_rule_type,l_map_seq_number,p_run_id,null,
           sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
           fnd_global.login_id);

        --dbms_output.put_line('!!!!!!!!!!!!!!!!Inserted into igw_prop_maps .....'||to_char(l_map_id));
        for c1 in get_map_details loop

          l_user_id := c1.user_id;

          if p_rule_type = 'N' then

            l_wf_role_name := 'IGW'||'-'||to_char(p_run_id)||'-0-0';
            fnd_message.set_name('IGW','IGW_ROUT_NOTIFICATION_ROLE');
            fnd_message.set_token('RUN_ID', p_run_id);
            l_wf_display_role_name := fnd_message.get;


          elsif p_rule_type = 'R' then

            l_wf_role_name := 'IGW'||'-'||to_char(p_run_id)||'-'||
                              to_char(l_map_id)||'-'||to_char(c1.stop_id);

            fnd_message.set_name('IGW','IGW_ROUT_ROUTING_ROLE');
            fnd_message.set_token('MAP_NAME', l_description);
            fnd_message.set_token('STOP_ID',c1.stop_id);
            fnd_message.set_token('RUN_ID', p_run_id);
            l_wf_display_role_name := fnd_message.get;

          end if;

          insert into igw_prop_map_stops(prop_map_id,stop_id,
           user_name,wf_role_name,wf_display_role_name,approver_type,
           approval_status,submission_date,approval_date,comments,
           last_update_date,last_updated_by,creation_date,created_by,
           last_update_login)
          values(
           igw_prop_maps_s.currval,c1.stop_id,c1.user_name,l_wf_role_name,
           l_wf_display_role_name,c1.approver_type,null,null,null,null,
           sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
           fnd_global.login_id);

          --dbms_output.put_line('################Inserted into igw_prop_map_stops .....'||to_char(l_map_id));


           -- Assign the user to the proposal if it is not already assigned
           open user_exists;
           fetch user_exists into l_dummy;
           if user_exists%notfound then

             insert into igw_prop_users(proposal_id,user_id,start_date_active,
              end_date_active,
              last_update_date,last_updated_by,creation_date, created_by,
              last_update_login)
             values(
              g_proposal_id,l_user_id,sysdate,null,
              sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
              fnd_global.login_id);

            end if;
            close user_exists;

            -- Assign Proposal Approver role(role_id=1) to proposal approver and Proposal Viewer role(role_id=4) to the notified user if they don't have the roles

            if p_rule_type = 'N' then
             open role_exists(4);
             fetch role_exists into l_dummy;
             if role_exists%notfound then
               insert into igw_prop_user_roles(proposal_id,user_id,role_id,
                last_update_date,last_updated_by,creation_date, created_by,
                last_update_login)
               values(
                g_proposal_id,l_user_id,4,
                sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
                fnd_global.login_id);
             end if;
             close role_exists;

            elsif p_rule_type = 'R' then
             open role_exists(1);
             fetch role_exists into l_dummy;
             if role_exists%notfound then
               insert into igw_prop_user_roles(proposal_id,user_id,role_id,
                last_update_date,last_updated_by,creation_date, created_by,
                last_update_login)
               values(
                g_proposal_id,l_user_id,1,
                sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
                fnd_global.login_id);
             end if;
             close role_exists;
            end if;
        end loop;

      end if;


    end loop;
    if p_invalid_flag = 'Y' then
      exit;
    end if;

    l_org_id := get_parent_org_id(l_org_id);
    if l_org_id is null then
      exit;
    end if;

  end loop;

exception
  when others then
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','GET_BUSINESS_RULES');
    raise;
end get_business_rules;



----------- function execute_business_rules   -----------------------------

function execute_business_rule(p_rule_id  in   number)
return varchar2 is


 l_execute_result     varchar2(5);
 l_select_stmt        varchar2(2000);
 l_loop_count         number(4) := 0;


 cursor business_rule_lines is
 select expression_type,
        lbrackets,
        lvalue,
        operator,
        rvalue,
        rvalue_id,
        rbrackets,
        logical_operator
 from   igw_business_rule_lines
 where  rule_id = p_rule_id
 order by expression_sequence_number;

begin

  l_select_stmt := 'select 1 from dual where ';


  for c1 in business_rule_lines loop

    l_loop_count := l_loop_count + 1;


    --dbms_output.put_line('Calling execute_line....'||c1.lvalue);


    l_execute_result := execute_line(c1.expression_type,c1.lvalue,c1.operator,c1.rvalue_id);
    l_select_stmt := l_select_stmt||c1.lbrackets||l_execute_result||
                     c1.rbrackets||' '||c1.logical_operator||' ';

    --dbms_output.put_line('** Business Rule SQL statement='||l_select_stmt);

  end loop;

  if l_loop_count = 0 then
    return '1=1';
  elsif l_loop_count >= 1 then
    --l_select_stmt := l_select_stmt||';';
    return execute_dynamic_sql(l_select_stmt);
  end if;

exception
 when others then
   fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','EXECUTE_BUSINESS_RULE');
   raise;

end execute_business_rule;


----------- function execute_line  ------------------------------------

function execute_line(p_expression_type  in  varchar2,
                      p_lvalue           in  varchar2,
                      p_operator         in  varchar2,
                      p_rvalue_id        in  varchar2)
return varchar2 as


 cursor get_answer is
 select answer
 from   igw_prop_questions
 where  question_number = p_lvalue
 and    proposal_id = g_proposal_id;


 cursor get_budget_amounts is
 select total_cost,
        total_direct_cost,
        total_indirect_cost,
        cost_sharing_amount,
        underrecovery_amount
 from   igw_budgets
 where  proposal_id = g_proposal_id
 and    final_version_flag = 'Y';


 cursor get_deadline_date is
 select to_char(deadline_date,'YYYYMMDD')
 from   igw_proposals_all
 where  proposal_id = g_proposal_id;


 cursor  get_expenditure_cat_type(exp_cat_flag in varchar2) is
 select  'x'
 from    igw_budget_details   pbd,
         igw_budget_periods   pbp,
         igw_budgets          pbu
 where   pbu.proposal_id = g_proposal_id
 and     pbu.final_version_flag = 'Y'
 and     pbu.proposal_id = pbp.proposal_id
 and     pbu.version_id = pbp.version_id
 and     pbp.proposal_id = pbd.proposal_id
 and     pbp.version_id = pbd.version_id
 and     pbd.expenditure_type = p_rvalue_id
 and     pbd.expenditure_category_flag = exp_cat_flag;


 cursor get_lead_org is
 select 'x'
 from   igw_proposals_all
 where  proposal_id = g_proposal_id
 and    lead_organization_id = p_rvalue_id;


 cursor get_overhead_rate_deviation is
 select 'x'
 from   igw_prop_rates  ppr,
        igw_budgets     pbu
 where  pbu.proposal_id = g_proposal_id
 and    pbu.final_version_flag = 'Y'
 and    pbu.proposal_id = ppr.proposal_id
 and    pbu.version_id = ppr.version_id
 and    ppr.applicable_rate <> ppr.institute_rate;


 cursor get_pi is
 select 'x'
 from   igw_prop_persons
 where  proposal_id = g_proposal_id
 and    pi_flag = 'Y'
 and    person_id = p_rvalue_id;


 cursor get_special_review_type is
 select 'x'
 from   igw_prop_special_reviews
 where  proposal_id = g_proposal_id
 and    special_review_code = p_rvalue_id;



 l_select_stmt          varchar2(2000) := 'select 1 from dual where ';
 l_answer               varchar2(1);
 l_total_cost           number(15,2);
 l_total_direct_cost    number(15,2);
 l_total_indirect_cost  number(15,2);
 l_cost_sharing_amount  number(15,2);
 l_underrecovery_amount number(15,2);
 l_deadline_date        varchar2(15);
 l_dummy                varchar2(1);


begin

 if p_expression_type = 'Q' then

   open get_answer;
   fetch get_answer into l_answer;
   if get_answer%notfound then
     close get_answer;
     return '1=2';
   elsif get_answer%found then
     close get_answer;
     l_select_stmt := l_select_stmt||l_answer||p_operator||p_rvalue_id;

      --dbms_output.put_line('Question SQL='||l_select_stmt);
     return execute_dynamic_sql(l_select_stmt);
   end if;

 elsif p_expression_type = 'C' or p_expression_type = 'F'  then

   if p_lvalue = 'TOTAL_COST' OR p_lvalue = 'TOTAL_DIRECT_COST' OR
      p_lvalue = 'TOTAL_INDIRECT_COST' OR p_lvalue = 'COST_SHARING_AMOUNT' OR
      p_lvalue = 'UNDERRECOVERY_AMOUNT' then

     open get_budget_amounts;
     fetch get_budget_amounts into
           l_total_cost,
           l_total_direct_cost,
           l_total_indirect_cost,
           l_cost_sharing_amount,
           l_underrecovery_amount;

     if get_budget_amounts%notfound then
       close get_budget_amounts;
       return '1=2';
     elsif get_budget_amounts%found then
       close get_budget_amounts;
       if p_lvalue = 'TOTAL_COST' then

         l_select_stmt := l_select_stmt||to_char(l_total_cost)||p_operator||
                          p_rvalue_id;

       elsif p_lvalue = 'TOTAL_DIRECT_COST' then

         l_select_stmt := l_select_stmt||to_char(l_total_direct_cost)||
                            p_operator||p_rvalue_id;

       elsif p_lvalue = 'TOTAL_INDIRECT_COST' then

         l_select_stmt := l_select_stmt||to_char(l_total_indirect_cost)||
                            p_operator||p_rvalue_id;

       elsif p_lvalue = 'COST_SHARING_AMOUNT' then

         l_select_stmt := l_select_stmt||to_char(l_cost_sharing_amount)||
                            p_operator||p_rvalue_id;

       elsif p_lvalue = 'UNDERRECOVERY_AMOUNT' then

         l_select_stmt := l_select_stmt||to_char(l_underrecovery_amount)||
                            p_operator||p_rvalue_id;

       end if;

       --dbms_output.put_line(p_lvalue||' = '||l_select_stmt);

       return execute_dynamic_sql(l_select_stmt);
     end if;

   elsif p_lvalue = 'DEADLINE_DATE' then

    open get_deadline_date;
    fetch get_deadline_date into l_deadline_date;
    if l_deadline_date is null then
      close get_deadline_date;
      return '1=2';
    elsif l_deadline_date is not null then
      close get_deadline_date;
      l_select_stmt := l_select_stmt||l_deadline_date||p_operator||p_rvalue_id;

      --dbms_output.put_line('Deadline Date='||l_select_stmt);
      return execute_dynamic_sql(l_select_stmt);
    end if;

   elsif p_lvalue = 'EXPENDITURE_TYPE' then

    open get_expenditure_cat_type('N');
    fetch get_expenditure_cat_type into l_dummy;
    if get_expenditure_cat_type%notfound then

      close get_expenditure_cat_type;
      return not_found_string(p_operator);

    elsif get_expenditure_cat_type%found then
      close get_expenditure_cat_type;
      return found_string(p_operator);

    end if;


   elsif p_lvalue = 'EXPENDITURE_CATEGORY' then

    open get_expenditure_cat_type('Y');
    fetch get_expenditure_cat_type into l_dummy;
    if get_expenditure_cat_type%notfound then

      close get_expenditure_cat_type;
      return not_found_string(p_operator);

    elsif get_expenditure_cat_type%found then
      close get_expenditure_cat_type;
      return found_string(p_operator);

    end if;


   elsif p_lvalue = 'LEAD_ORGANIZATION' then

    open get_lead_org;
    fetch get_lead_org into l_dummy;
    if get_lead_org%notfound then

      close get_lead_org;
      return not_found_string(p_operator);

    elsif get_lead_org%found then
      close get_lead_org;
      return found_string(p_operator);
    end if;


   elsif p_lvalue = 'OVERHEAD_RATE_DEVIATION' then

    open get_overhead_rate_deviation;
    fetch get_overhead_rate_deviation into l_dummy;
    if get_overhead_rate_deviation%notfound then

      close get_overhead_rate_deviation;
      return not_found_string(p_operator);
    elsif get_overhead_rate_deviation%found then
      close get_overhead_rate_deviation;
      return found_string(p_operator);
    end if;


   elsif p_lvalue = 'PI_IS_SPECIFIED_PERSON' then


    open get_pi;
    fetch get_pi into l_dummy;
    if get_pi%notfound then

      close get_pi;
      return not_found_string(p_operator);
    elsif get_pi%found then
      close get_pi;
      return found_string(p_operator);
    end if;


   elsif p_lvalue = 'SPECIAL_REVIEW_TYPE' then


    open get_special_review_type;
    fetch get_special_review_type into l_dummy;
    if get_special_review_type%notfound then

      close get_special_review_type;
      return not_found_string(p_operator);
    elsif get_special_review_type%found then
      close get_special_review_type;
      return found_string(p_operator);
    end if;

   end if;

 end if;

exception
  when others then
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','EXECUTE_LINE');
    raise;
end execute_line;


-----------  function found_string    -----------------------------

function  found_string(p_operator  in  varchar2)
 return varchar2 is

begin

  if p_operator = '=' then
    return '1=1';
  elsif p_operator = '<>' then
    return '1=2';
  end if;

exception
  when others then
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','FOUND_STRING');
    raise;
end found_string;


-----------  function not_found_string    -----------------------------
function not_found_string(p_operator  in  varchar2)
 return varchar2 is

begin

   if p_operator = '=' then
     return '1=2';
   elsif p_operator = '<>' then
     return '1=1';
   end if;

exception
  when others then
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','NOT_FOUND_STRING');
    raise;
end not_found_string;



-----------  function execute_dynamic_sql    -----------------------------
function execute_dynamic_sql(p_select_stmt  in   varchar2)
 return varchar2 as

 l_cursor_name      integer;
 l_rows_fetched     integer;
 l_dummy_one        number(1);

begin

   l_cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor_name,p_select_stmt,dbms_sql.v7);
   dbms_sql.define_column(l_cursor_name,1,l_dummy_one);
   l_rows_fetched := dbms_sql.execute_and_fetch(l_cursor_name);
   dbms_sql.close_cursor(l_cursor_name);
   if l_rows_fetched = 0 then
     return '1=2';
   else
     return '1=1';
   end if;

exception
  when others then
    fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','EXECUTE_DYNAMIC_SQL');
    raise;
end execute_dynamic_sql;



-----------  function get_parent_org_id    -----------------------------
function get_parent_org_id(l_org_id  in   number)
 return number as

 cursor  get_parent_org is
 select  poe.organization_id_parent
 from    per_org_structure_elements  poe
 where   poe.org_structure_version_id = (select apr_org_structure_version_id
         from igw_implementations)
 and     poe.organization_id_child = l_org_id;

 l_org_id_parent   number(15);


begin
 open get_parent_org;
 fetch get_parent_org into l_org_id_parent;
 close get_parent_org;
 return l_org_id_parent;

exception
 when others then
  fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','GET_PARENT_ORG_ID');
  raise;
end get_parent_org_id;


----------- procedure assign_so_role  -----------------------------
procedure assign_so_role(p_signing_official_id in number,
                         p_admin_official_id   in number) is

 cursor get_user_id(l_person_id in number) is
 select user_id
 from   fnd_user
 where  employee_id = l_person_id;


 cursor so_user_exists(l_user_id in number) is
 select 'x'
 from   igw_prop_users
 where  proposal_id = g_proposal_id
 and    user_id = l_user_id;

 cursor so_user_role_exists(l_user_id in number, l_role_id in number) is
 select 'x'
 from   igw_prop_user_roles
 where  proposal_id = g_proposal_id
 and    user_id = l_user_id
 and    role_id = l_role_id;


 l_sign_off_user_id   number(15);
 l_admin_off_user_id  number(15);
 l_dummy              varchar2(1);

begin
  open get_user_id(p_signing_official_id);
  fetch get_user_id into l_sign_off_user_id;
  close get_user_id;

  open get_user_id(p_admin_official_id);
  fetch get_user_id into l_admin_off_user_id;
  close get_user_id;

   -- Assign the SO to the proposal if it is not already assigned
   open so_user_exists(l_sign_off_user_id);
   fetch so_user_exists into l_dummy;

   if so_user_exists%notfound then

     insert into igw_prop_users(proposal_id,user_id,start_date_active,
        end_date_active,last_update_date,last_updated_by,creation_date,
        created_by,last_update_login)
      values(
         g_proposal_id,l_sign_off_user_id,sysdate,
         null,sysdate,fnd_global.user_id,sysdate,
         fnd_global.user_id,fnd_global.login_id);

   end if;
   close so_user_exists;
  -- dbms_output.put_line('After inserting so into prop_users ');

   -- Assign the AO to the proposal if it is not already assigned
   open so_user_exists(l_admin_off_user_id);
   fetch so_user_exists into l_dummy;

   if so_user_exists%notfound then

     insert into igw_prop_users(proposal_id,user_id,start_date_active,
        end_date_active,last_update_date,last_updated_by,creation_date,
        created_by,last_update_login)
      values(
         g_proposal_id,l_admin_off_user_id,sysdate,
         null,sysdate,fnd_global.user_id,sysdate,
         fnd_global.user_id,fnd_global.login_id);

   end if;
   close so_user_exists;
  --  dbms_output.put_line('After inserting ao into prop_users ');

   -- Assign Signing Official role(role_id=3) to Signing Official if it does not already exist and Administrative Official

   open so_user_role_exists(l_sign_off_user_id, 3);
   fetch so_user_role_exists into l_dummy;
   if so_user_role_exists%notfound then
       insert into igw_prop_user_roles(proposal_id,user_id,role_id,
            last_update_date,last_updated_by,creation_date, created_by,
            last_update_login)
       values(
            g_proposal_id,l_sign_off_user_id,3,
            sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
            fnd_global.login_id);
    end if;
    close  so_user_role_exists;


   if l_sign_off_user_id <> l_admin_off_user_id then
        open so_user_role_exists(l_admin_off_user_id, 3);
        fetch so_user_role_exists into l_dummy;
        if so_user_role_exists%notfound then
              insert into igw_prop_user_roles(proposal_id,user_id,role_id,
                 last_update_date,last_updated_by,creation_date, created_by,
                 last_update_login)
              values(
                 g_proposal_id,l_admin_off_user_id,3,
                 sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,
                 fnd_global.login_id);
         end if;
         close  so_user_role_exists;

   end if;
end assign_so_role;


----------- procedure populate_local_wf_tables  -----------------------------
procedure populate_local_wf_tables(p_run_id  in number) is

/*
  cursor one_approver_in_stop is
  select pms.prop_map_id,
         pms.stop_id
  from  igw_prop_maps      pm,
        igw_prop_map_stops pms
  where pms.prop_map_id = pm.prop_map_id
  and   pm.run_id = p_run_id
  and   pm.map_type = 'R'
  group by pms.prop_map_id,pms.stop_id
  having count(*) = 1;
*/
  cursor create_local_role is
  select distinct
  ppms.wf_role_name,
  ppms.wf_display_role_name
  from igw_prop_maps      ppm,
       igw_prop_map_stops ppms
  where ppm.prop_map_id = ppms.prop_map_id
  and   ppm.run_id = to_number(p_run_id)
  and   wf_role_name <> user_name;

  cursor assign_user_to_role is
  select distinct
  ppms.user_name,
  ppms.wf_role_name
  from igw_prop_maps      ppm,
       igw_prop_map_stops ppms
  where ppm.prop_map_id = ppms.prop_map_id
  and   ppm.run_id = to_number(p_run_id)
  and   wf_role_name <> user_name;


  l_wf_role_name           varchar2(100);
  l_wf_display_role_name   varchar2(200);
  l_user_name              varchar2(100);
  l_prop_map_id            number(15);
  l_stop_id                number(4);

begin
/*
  -- update wf_role_name with user_name whereever there is one
  -- approver in a stop.If there is one approver in a stop, local
  -- workflow role will not be created and the user_name will be
  -- used as the workflow role name
  for i in one_approver_in_stop loop

    update igw_prop_map_stops
     set wf_role_name = user_name
     where prop_map_id = i.prop_map_id
     and stop_id = i.stop_id;

  end loop;
*/

  -- create local workflow roles
  for j in create_local_role loop

    wf_directory.createadhocrole(role_name => j.wf_role_name,
                                 role_display_name => j.wf_display_role_name,
                                 expiration_date => null);
  end loop;

  -- assign users to the local workflow roles
  for k in assign_user_to_role loop

    wf_directory.adduserstoadhocrole(role_name => k.wf_role_name,
                                     role_users => k.user_name);
  end loop;

exception
 when others then
  fnd_msg_pub.add_exc_msg('IGW_PROPOSAL_APPROVAL','POPULATE_LOCAL_WF_TABLES');
  raise;
end populate_local_wf_tables;


END IGW_PROP_APPROVALS_PVT;

/
