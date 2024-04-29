--------------------------------------------------------
--  DDL for Package Body WIP_WS_SKILL_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_SKILL_CHECK_PVT" AS
/* $Header: wipwsscb.pls 120.0.12010000.6 2010/01/29 13:33:38 sisankar noship $ */

    /* This procedure sets package variables for preference parameters */
    procedure get_skill_parameters(p_organization_id in number)
    is
        cursor get_preferences is
        select attribute_name,
        attribute_value_code
        from wip_preference_values
        where preference_id = 41
        and level_id = 1
        and attribute_name <> G_PREF_ORG_ATTRIBUTE
        and sequence_number = (select sequence_number
                               from wip_preference_values
                               where preference_id = 41
                               and level_id = 1
                               and attribute_name = G_PREF_ORG_ATTRIBUTE
                               and attribute_value_code = to_char(p_organization_id))
        order by 1 desc;
    begin
        G_PREF_CLOCK_VALUE   := G_DISABLE_CLOCK_VALIDATION;
        G_PREF_MOVE_VALUE    := G_DISABLE_MOVE_VALIDATION;
        G_PREF_CERTIFY_VALUE := G_DISABLE_CERTIFICATION_CHECK;
        for preferences in get_preferences loop
            if preferences.attribute_name = G_PREF_CLOCK_ATTRIBUTE then
                G_PREF_CLOCK_VALUE := preferences.attribute_value_code;
            elsif preferences.attribute_name =G_PREF_MOVE_ATTRIBUTE then
                G_PREF_MOVE_VALUE := preferences.attribute_value_code;
            elsif preferences.attribute_name =G_PREF_CERTIFY_ATTRIBUTE then
                G_PREF_CERTIFY_VALUE := preferences.attribute_value_code;
            end if;
        end loop;
    end get_skill_parameters;

    procedure set_message_context(p_wip_entity_id in Number,
                                  p_emp_id        in Number)
    is
    begin
        select wip_entity_name
        into G_WIP_ENTITY_NAME
        from wip_entities
        where wip_entity_id =  p_wip_entity_id;

        select full_name
        into G_EMPLOYEE
        from per_all_people_f
        where person_id = p_emp_id
        and sysdate between effective_start_date and nvl(effective_end_date,sysdate+1);
    exception
        when others then
            null;
    end set_message_context;

    function get_operation_skill_check(p_wip_entity_id in number,
                                       p_op_seq_num    in number)
    return number
    is
        l_check_skill number;
    begin
        select nvl(check_skill,2)
        into l_check_skill
        from wip_operations
        where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_op_seq_num;

        return l_check_skill;
    exception
        when others then
            return 2;
    end get_operation_skill_check;

    /* This function will be called to validate employee skill for a job operation.
       We are not passing Clock-In time or Move transaction date to these methods to validate
       effectivity of competence/Certification since MES Move transactions are stamped with sysdate.
       We need to pass additional date parameter when we allow updating transaction dates in MES. */

    function validate_skill_for_operation(p_wip_entity_id   in number,
                                          p_organization_id in number,
                                          p_operation       in number,
                                          p_emp_id          in number)
    return Number
    is

        cursor get_operation_competence is
        select competence_id,rating_level_id,qualification_type_id
        from wip_operation_competencies
        where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation;

        l_counter Number;
        l_validate_skill number := G_SKILL_VALIDATION_SUCCESS;
        l_err_msg varchar2(2000) := null;
        l_certify_date date;
        l_next_review_date date;
        l_comp_certify_required varchar2(1);

        type job_op_competence_rec is record (
             competency_id          wip_operation_competencies.competence_id%type,
             rating_level_id        wip_operation_competencies.rating_level_id%type,
             qualification_type_id  wip_operation_competencies.qualification_type_id%type);

        type t_job_op_competence is table of job_op_competence_rec index by binary_integer;
        v_job_op_competence t_job_op_competence;

    begin

        if p_emp_id is null then
            return G_INV_SKILL_CHECK_EMP;
        end if;

        open get_operation_competence;
        fetch get_operation_competence bulk collect into v_job_op_competence;
        close get_operation_competence;

        l_counter := v_job_op_competence.first;
	       l_validate_skill := G_SKILL_VALIDATION_SUCCESS;
        while l_counter is not null loop
            if v_job_op_competence(l_counter).competency_id is not null then
                begin
                    SELECT certification_date,  next_certification_date
                    into l_certify_date,l_next_review_date
                    FROM  per_competence_elements
                    WHERE type = 'PERSONAL'
                    AND person_id = p_emp_id
                    AND trunc(sysdate) between effective_date_from and NVL(effective_date_to,trunc(sysdate))
                    and competence_id = v_job_op_competence(l_counter).competency_id
                    and nvl(proficiency_level_id,-1) = nvl(v_job_op_competence(l_counter).rating_level_id ,nvl(proficiency_level_id,-1));

                exception
                    when others then
                        l_validate_skill := G_COMPETENCE_CHECK_FAIL;
                end;
                if l_validate_skill=G_SKILL_VALIDATION_SUCCESS and
                   G_PREF_CERTIFY_VALUE = G_ENABLE_CERTIFICATION_CHECK then

                    select nvl(certification_required,'N')
                    into l_comp_certify_required
                    FROM per_competences
                    WHERE competence_id = v_job_op_competence(l_counter).competency_id;

                    if l_comp_certify_required='Y' and
                       (l_certify_date is null or
                        l_certify_date > sysdate or
                        nvl(l_next_review_date,sysdate+1) < sysdate) then
                        l_validate_skill := G_CERTIFY_CHECK_FAIL;
                    end if;
                end if;
            end if;
            if l_validate_skill= G_SKILL_VALIDATION_SUCCESS and
               v_job_op_competence(l_counter).qualification_type_id is not null then
                begin
                    select 1
                    into l_validate_skill
                    from   dual
                    where exists (select 'x'
                                  from per_qualifications
                                  where person_id = p_emp_id
                                  and qualification_type_id = v_job_op_competence(l_counter).qualification_type_id);
                exception
                    when others then
                        l_validate_skill := G_QUALIFY_CHECK_FAIL;
                end;
            end if;
            if l_validate_skill <> G_SKILL_VALIDATION_SUCCESS then
                exit;
            end if;
            l_counter := v_job_op_competence.next(l_counter);
        end loop;
        return l_validate_skill;
    end validate_skill_for_operation;

    /* Main Function for skill Validation for a Op in Move Transaction. */
    function validate_skill_for_move_ops(p_wip_entity_id   in number,
                                         p_organization_id in number,
                                         p_operation       in number,
                                         p_emp_id          in number)
    return number
    is
        l_validate_skill Number := G_SKILL_VALIDATION_SUCCESS;
        l_op_competence_exist Number := 0;
        cursor get_clocked_employees is
        select distinct employee_id
        from wip_resource_actual_times
        where organization_id = p_organization_id
        and wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation;

    begin
        if G_PREF_MOVE_VALUE = G_ENABLE_MOVE_VALIDATION then
            l_validate_skill := validate_skill_for_operation(p_wip_entity_id   => p_wip_entity_id,
                                                                  p_organization_id => p_organization_id,
                                                                  p_operation       => p_operation,
                                                                  p_emp_id          => p_emp_id);
        end if;
        if G_PREF_CLOCK_VALUE in (G_ALLOW_ONLY_SKILL_OPERATORS,G_ALLOW_ALL_OPERATORS) AND
           l_validate_skill= G_SKILL_VALIDATION_SUCCESS then
            begin
                select 1 into l_op_competence_exist
                from dual
                where exists (select 1
                             from wip_operation_competencies
                             where wip_entity_id = p_wip_entity_id
                             and operation_seq_num = p_operation );
            exception
                when others then
                    l_op_competence_exist := 0;
            end;
            if l_op_competence_exist = 0 then
                l_validate_skill := G_SKILL_VALIDATION_SUCCESS;
            else
                l_validate_skill := G_NO_SKILL_EMP_CLOCKIN;
            end if;
            if l_validate_skill <> G_SKILL_VALIDATION_SUCCESS then
                for employees in get_clocked_employees loop
                    if employees.employee_id = p_emp_id  then
                        l_validate_skill := G_SKILL_VALIDATION_SUCCESS;
                        exit;
                    else
                        l_validate_skill := validate_skill_for_operation(p_wip_entity_id   => p_wip_entity_id,
                                                                         p_organization_id => p_organization_id,
                                                                         p_operation       => p_operation,
                                                                         p_emp_id          => employees.employee_id);
                        exit when l_validate_skill = G_SKILL_VALIDATION_SUCCESS;
                    end if;
                end loop;
            end if;
            if l_validate_skill <> G_SKILL_VALIDATION_SUCCESS then
               l_validate_skill := G_NO_SKILL_EMP_CLOCKIN;
            end if;
        end if;
        return l_validate_skill;
    end validate_skill_for_move_ops;

    /* Main Function for skill Validation for Clock-In. */
    function validate_skill_for_clock_in(p_wip_entity_id   in number,
                                         p_op_seq_num      in number,
                                         p_emp_id          in number)
    return number
    is
        l_check_skill number;
        l_org_id number;
        l_validate_skill number := G_SKILL_VALIDATION_SUCCESS;
    begin

        select organization_id
        into l_org_id
        from wip_entities
        where wip_entity_id = p_wip_entity_id
        and rownum=1;

        get_skill_parameters(l_org_id);
        /* validate only if clock in is allowed only for skilled operators and
           skill check is enabled for the operation*/
        if G_PREF_CLOCK_VALUE = G_ALLOW_ONLY_SKILL_OPERATORS then

            l_check_skill := get_operation_skill_check(p_wip_entity_id,p_op_seq_num);

            if l_check_skill=G_SKILL_CHECK_ENABLED then
                l_validate_skill := validate_skill_for_operation(p_wip_entity_id   => p_wip_entity_id,
                                                                 p_organization_id => l_org_id,
                                                                 p_operation       => p_op_seq_num,
                                                                 p_emp_id          => p_emp_id);
            end if;
        end if;
        return l_validate_skill;
    exception
        when others then
            return G_SKILL_VALIDATION_EXCEPTION;
    end validate_skill_for_clock_in;

    /* Main Function for skill Validation for Move Transaction. */
    procedure validate_skill_for_move_txn(p_wip_entity_id   in number,
                                          p_organization_id in number,
                                          p_from_op         in number,
                                          p_to_op           in number,
                                          p_from_step       in number,
                                          p_to_step         in number,
                                          p_emp_id          in number,
                                          l_validate_skill out nocopy number,
                                          l_move_pref      out nocopy varchar2,
                                          l_certify_pref   out nocopy varchar2,
                                          l_err_msg        out nocopy varchar2)
    is

    l_sql varchar2(4000);
    l_add_where_clause varchar2(1000);
    l_from_op number;
    l_to_op number;
    l_from_step number;
    l_to_step number;
    l_op_seq_num number;
    l_check_skill number;
    l_cursor integer;
    l_sql_exec integer;
    begin
        l_validate_skill := G_SKILL_VALIDATION_SUCCESS;
        get_skill_parameters(p_organization_id);
        if G_PREF_MOVE_VALUE = G_ENABLE_MOVE_VALIDATION OR
           G_PREF_CLOCK_VALUE in (G_ALLOW_ONLY_SKILL_OPERATORS,G_ALLOW_ALL_OPERATORS) then

            if (p_from_op > p_to_op OR (p_from_op = p_to_op and p_from_step > p_to_step)) then
                l_from_op   := p_to_op;
                l_to_op     := p_from_op;
                l_to_step   := p_from_step;
                l_from_step := p_to_step;
            else
                l_from_op := p_from_op;
                l_to_op   := p_to_op;
                l_to_step   := p_to_step;
                l_from_step := p_from_step;
            end if;

            if l_from_step = WIP_CONSTANTS.TOMOVE then
                l_add_where_clause := ' and operation_seq_num > :3 ';
            else
                l_add_where_clause := ' and operation_seq_num >= :3 ';
            end if;

            if l_to_step = WIP_CONSTANTS.QUEUE then
                l_add_where_clause := l_add_where_clause || ' and operation_seq_num < :4 ';
            else
                l_add_where_clause := l_add_where_clause || ' and operation_seq_num <= :4 ';
            end if;

            l_sql := ' select operation_seq_num,nvl(check_skill,2) '||
                     ' from wip_operations '||
                     ' where organization_id = :1 '||
                     ' and wip_entity_id = :2 '||
                     l_add_where_clause;

            l_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
            dbms_sql.define_column(l_cursor, 1, l_op_seq_num);
            dbms_sql.define_column(l_cursor, 2, l_check_skill);
            dbms_sql.bind_variable(l_cursor, ':1', p_organization_id);
            dbms_sql.bind_variable(l_cursor, ':2', p_wip_entity_id);
            dbms_sql.bind_variable(l_cursor, ':3', l_from_op);
            dbms_sql.bind_variable(l_cursor, ':4', l_to_op);
            l_sql_exec := dbms_sql.execute(l_cursor);

            loop
                exit when dbms_sql.fetch_rows(l_cursor) = 0 OR l_validate_skill <> G_SKILL_VALIDATION_SUCCESS;
                dbms_sql.column_value(l_cursor, 1, l_op_seq_num);
                dbms_sql.column_value(l_cursor, 2, l_check_skill);
                if l_check_skill=G_SKILL_CHECK_ENABLED then
                    l_validate_skill := validate_skill_for_move_ops(p_wip_entity_id => p_wip_entity_id,
                                                                    p_organization_id => p_organization_id,
                                                                    p_operation => l_op_seq_num,
                                                                    p_emp_id => p_emp_id);
                end if;

            end loop;
            dbms_sql.close_cursor(l_cursor);
        end if;
        if l_validate_skill <> G_SKILL_VALIDATION_SUCCESS then
            if p_wip_entity_id is not null and p_emp_id is not null then
                set_message_context(p_wip_entity_id,p_emp_id);
            end if;
            if l_validate_skill = G_COMPETENCE_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_COMPETENCE_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_CERTIFY_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_CERTIFY_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_QUALIFY_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_QUALIFY_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_NO_SKILL_EMP_CLOCKIN then
                fnd_message.set_name('WIP','WIP_NO_SKILL_EMP_CLOCKIN');
            end if;
            fnd_message.set_token('JOB', G_WIP_ENTITY_NAME);
            fnd_message.set_token('OP', to_char(l_op_seq_num));
            if l_validate_skill = G_INV_SKILL_CHECK_EMP then
                fnd_message.set_name('WIP','WIP_SKILL_CHECK_EMP_NULL');
            end if;
            l_err_msg := fnd_message.get;
        end if;
        if G_PREF_MOVE_VALUE = G_ENABLE_MOVE_VALIDATION then
            fnd_message.set_name('WIP','WIP_YES');
            l_move_pref := fnd_message.get;
        else
            fnd_message.set_name('WIP','WIP_NO');
            l_move_pref := fnd_message.get;
        end if;
        if G_PREF_CERTIFY_VALUE = G_ENABLE_CERTIFICATION_CHECK then
            fnd_message.set_name('WIP','WIP_YES');
            l_certify_pref := fnd_message.get;
        else
            fnd_message.set_name('WIP','WIP_NO');
            l_certify_pref := fnd_message.get;
        end if;
    exception
        when others then
            l_validate_skill := G_SKILL_VALIDATION_EXCEPTION;
            l_err_msg := 'Exception during Skill Validation'||sqlerrm(sqlcode);
    end validate_skill_for_move_txn;

    /* This function will be called to validate skill for Express Move.*/
    procedure validate_skill_for_exp_move(p_wip_entity_id   in number,
                                          p_organization_id in number,
                                          p_op_seq_num      in number,
                                          p_emp_id          in number,
                                          l_validate_skill out nocopy number,
                                          l_err_msg        out nocopy varchar2)
    is
    l_skill_check number;
    begin
        l_validate_skill := G_SKILL_VALIDATION_SUCCESS;
        get_skill_parameters(p_organization_id);
        l_skill_check := get_operation_skill_check(p_wip_entity_id => p_wip_entity_id,
                                                   p_op_seq_num    => p_op_seq_num);
        if l_skill_check=G_SKILL_CHECK_ENABLED then
            l_validate_skill := validate_skill_for_move_ops(p_wip_entity_id   => p_wip_entity_id,
                                                            p_organization_id => p_organization_id,
                                                            p_operation       => p_op_seq_num,
                                                            p_emp_id          => p_emp_id);
        end if;
        if l_validate_skill <> G_SKILL_VALIDATION_SUCCESS then
            if p_wip_entity_id is not null and p_emp_id is not null then
                set_message_context(p_wip_entity_id,p_emp_id);
            end if;
            if l_validate_skill = G_COMPETENCE_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_COMPETENCE_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_CERTIFY_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_CERTIFY_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_QUALIFY_CHECK_FAIL then
                fnd_message.set_name('WIP','WIP_QUALIFY_CHECK_FAIL');
                fnd_message.set_token('EMP', G_EMPLOYEE);
            elsif l_validate_skill = G_NO_SKILL_EMP_CLOCKIN then
                fnd_message.set_name('WIP','WIP_NO_SKILL_EMP_CLOCKIN');
            end if;
            fnd_message.set_token('JOB', G_WIP_ENTITY_NAME);
            fnd_message.set_token('OP', to_char(p_op_seq_num));
            if l_validate_skill = G_INV_SKILL_CHECK_EMP then
                fnd_message.set_name('WIP','WIP_SKILL_CHECK_EMP_NULL');
            end if;
            l_err_msg := fnd_message.get;
        end if;
    exception
        when others then
            l_validate_skill := G_SKILL_VALIDATION_EXCEPTION;
            l_err_msg := 'Exception during Skill Validation'||sqlerrm(sqlcode);
    end validate_skill_for_exp_move;

END WIP_WS_SKILL_CHECK_PVT;

/
