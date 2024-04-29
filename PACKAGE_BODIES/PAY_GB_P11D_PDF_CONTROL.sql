--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_PDF_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_PDF_CONTROL" AS
/* $Header: pygbp11dr.pkb 120.4.12010000.6 2009/10/07 07:45:51 namgoyal ship $ */

    PROCEDURE write_header
    IS
    BEGIN
          fnd_file.put_line(fnd_file.output,null);
          fnd_file.put_line(fnd_file.output,'P11D PDF Output Report');
          fnd_file.put_line(fnd_file.output,rpad('File No',9) ||
                                            rpad('Request ID',21) ||
                                            rpad('File Name',21) ||
                                            rpad('P11D Per File',16));
          fnd_file.put_line(fnd_file.output,rpad('-',8,'-')   || ' ' ||
                                            rpad('-',20,'-')  || ' ' ||
                                            rpad('-',20,'-') || ' ' ||
                                            rpad('-',15,'-'));
    END;

    PROCEDURE write_body(p_file_no     number,
                         p_request_id  number,
                         p_file_name   varchar2,
                         p_size        number)
    IS
    BEGIN
          fnd_file.put_line(fnd_file.output,rpad(p_file_no,9) ||
                                            rpad(p_request_id,21) ||
                                            rpad(p_file_name,21) ||
                                            rpad(p_size,16));
    END write_body;

    PROCEDURE write_footer(p_total number)
    IS
    BEGIN
          fnd_file.put_line(fnd_file.output,' ');
          fnd_file.put_line(fnd_file.output,rpad('Total P11D PDF Produced',51) ||
                                            rpad(p_total,16));
    END;

    PROCEDURE print_pdf(errbuf            out NOCOPY VARCHAR2,
                        retcode           out NOCOPY NUMBER,
                        p_print_address_page   in varchar2 default null,
                        p_print_p11d           in varchar2,
                        p_print_p11d_summary   in varchar2,
                        p_print_ws             in varchar2,
                        p_payroll_action_id    in varchar2,
                        p_organization_id      in varchar2 default null,
                        p_org_hierarchy        in varchar2 default null,
                        p_assignment_set_id    in varchar2 default null,
                        p_location_code        in varchar2 default null,
                        p_assignment_action_id in varchar2 default null,
                        p_business_group_id    in varchar2,
                        p_sort_order1          in varchar2 default null,
                        p_sort_order2          in varchar2 default null,
                        p_profile_out_folder   in varchar2 default null,
		  	p_rec_per_file         in varchar2,
                        p_chunk_size           in number,
                        p_person_type          in varchar2 default null,
			p_print_style          in varchar2 default null, --bug 8241399
                        -- p_print style parameter added to suppress additional blank page
                        p_priv_mark            in varchar2 default null)--bug 8942337
     is
           l_id          number;
           l_asg_count   number;
           l_remainder   number;
           l_full_chunk  number;
           l_temp        number;
           function get_assignment_count return number
           is
                l_select      varchar2(1000);
     		l_from        varchar2(1000);
         	l_where       varchar2(15000);
     		l_group       varchar2(1000);
                l_sql         varchar2(20000);
                l_sql_cursor  integer;
                l_rows        integer;
                l_asg_count   number;
                l_ret         number;
           begin
                l_select := 'select count(1)
                             from (select /*+ ORDERED use_nl(paa,paf,emp,pai_payroll)
                                              use_index(pai_person,pay_action_information_n2)
                                              use_index(pai,pay_action_information_n2) */
                                          paf.person_id, max(paa.assignment_action_id) as asg_id ';
                l_from   := '      from   pay_assignment_actions paa,
                                          per_all_assignments_f  paf,
                                          pay_action_information emp,
                                          pay_action_information pai_payroll  ';
                l_where  := 'where  paa.payroll_action_id = ' || p_payroll_action_id || '
                             and    paa.action_status = ''C''
                             and    paa.assignment_id = paf.assignment_id
                             and    emp.action_information_category = ''EMPLOYEE DETAILS''
                             and    emp.action_context_id = paa.assignment_action_id
                             and    emp.action_context_type = ''AAP''
                             and    pai_payroll.action_information_category = ''GB EMPLOYEE DETAILS''
                             and    pai_payroll.action_context_id = paa.assignment_action_id
                             and    pai_payroll.action_context_type = ''AAP'' ';

                if p_assignment_action_id is not null then
               	   l_where :=  l_where || 'and   paa.assignment_action_id = ' || p_assignment_action_id ;
         	end if;

                if p_person_type is not null then
                   l_from := l_from || ', per_all_people_f pap
                                        , per_person_types ppt ';
                   l_where := l_where || ' and pap.person_id = paf.person_id
                                           and pap.person_type_id = ppt.person_type_id
                                           and (ppt.system_person_type = ''EX_EMP''
                                           or ppt.system_person_type = ''EX_EMP_APL'') ';  -- Added to fix the bug 8727098
                end if;
                if p_organization_id is not null then
                   l_where := l_where || ' and   emp.action_information2 = ' || p_organization_id ;
                end if;
         	if p_location_code is not null then
              	   l_where := l_where || ' and   nvl(emp.action_information30,''0'')= ''' || p_location_code || ''' ' ;
        	end if;
         	if p_org_hierarchy is not null then
             	   l_where := l_where || ' and   emp.action_information2 in(select organization_id_child
                                                                            from   per_org_structure_elements
                                                                     where  business_group_id = ' || p_org_hierarchy ||
                                                                   ' union
                                                                     select ' || p_org_hierarchy  || ' from dual)';
                end if;
         	if p_assignment_set_id is not null then
            	   l_from := l_from  || ',hr_assignment_sets has
                                         ,hr_assignment_set_amendments hasa ';
                   l_where := l_where ||
                        		' and    has.assignment_set_id  = ' || p_assignment_set_id ||
                       		        ' and    has.assignment_set_id = hasa.assignment_set_id(+)
                        		  and    ((     has.payroll_id is null
                                   			and hasa.include_or_exclude = ''I''
                                   			and hasa.assignment_id = paa.assignment_id
                                  		   )
                                  	 	 OR
                                 		  (     has.payroll_id is not null
                                   			and has.payroll_id  = pai_payroll.ACTION_INFORMATION5
                                   			and nvl(hasa.include_or_exclude, ''I'') = ''I''
                                   			and nvl(hasa.assignment_id, paa.assignment_id) = paa.assignment_id
                                		 )) ';
                end if;
         	l_group  := ' group by paf.person_id, pai_payroll.action_information13 )';
                hr_utility.trace(l_select);
                hr_utility.trace(l_from);
                hr_utility.trace(l_where);
                hr_utility.trace(l_group);
                l_sql := l_select || l_from || l_where || l_group;

		l_sql_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(l_sql_cursor, l_sql, dbms_sql.v7);
                dbms_sql.define_column (l_sql_cursor, 1, l_asg_count);
                l_rows := dbms_sql.execute_and_fetch (l_sql_cursor, false);
                dbms_sql.column_value (l_sql_cursor, 1, l_asg_count);
                dbms_sql.close_cursor(l_sql_cursor);

                if (l_rows = 1) then
                   l_ret := l_asg_count;
                else
                   l_ret := 0;
                end if;

                return l_ret;
           end;

	   function get_mod(p_total number, p_chunk_size number) return number
	   is
	        l_ret number;
	   begin
	        select mod(p_total,p_chunk_size)
	        into   l_ret
	        from   dual;
	        return l_ret;
	   end;

	   function get_div(p_total number, p_chunk_size number) return number
	   is
	        l_val number;
	   begin
	        select floor(p_total / p_chunk_size)
	        into   l_val
	        from   dual;
	        return l_val;
	   end;
     begin
          l_asg_count := get_assignment_count;
          hr_utility.trace(l_asg_count);
          hr_utility.trace(p_chunk_size);
          if l_asg_count > 0 then
            if l_asg_count <= p_chunk_size then
               hr_utility.trace('All assignments in 1 chunk');
               l_id := fnd_request.submit_request(application => 'PER',
                                                program     => 'PER_P11D_REP',
                                                argument1   => p_print_address_page,
                                                argument2   => p_print_p11d,
                                                argument3   => p_print_p11d_summary,
                                                argument4   => p_print_ws,
                                                argument5   => p_payroll_action_id,
                                                argument6   => p_organization_id,
                                                argument7   => p_org_hierarchy,
                                                argument8   => p_assignment_set_id,
                                                argument9   => p_location_code,
                                                argument10  => p_assignment_action_id,
                                                argument11  => p_business_group_id,
                                                argument12  => p_sort_order1,
                                                argument13  => p_sort_order2,
                                                argument14  => p_profile_out_folder,
                                                argument15  => p_rec_per_file,
						argument16  => p_chunk_size,
						argument17  => 1,
                                                argument18  => p_person_type,
						argument19  =>p_print_style,--bug 8241399
                                                -- p_print style parameter added to suppress additional blank page
                                                argument20  =>p_priv_mark);--bug 8942337

                write_header;
                write_body(p_file_no    => 1,
                           p_request_id => l_id,
                           p_file_name  => 'o' || l_id || '.out',
                           p_size       => l_asg_count);
                write_footer(p_total => l_asg_count);
            else
              -- assignment count > chunk_size
              l_remainder   := get_mod(l_asg_count,p_chunk_size);
              l_full_chunk  := get_div(l_asg_count,p_chunk_size);
              hr_utility.trace('Remainder ' || l_remainder);
              hr_utility.trace('Chunk '     || l_full_chunk);
              if (l_remainder > 0) then
                  l_full_chunk := l_full_chunk + 1;
              end if;
              write_header;
              l_temp := 0;
              for x in 1..l_full_chunk loop
                  hr_utility.trace('Processing chunk : ' || x);
                  l_id := fnd_request.submit_request(application => 'PER',
                                                program     => 'PER_P11D_REP',
                                                argument1   => p_print_address_page,
                                                argument2   => p_print_p11d,
                                                argument3   => p_print_p11d_summary,
                                                argument4   => p_print_ws,
                                                argument5   => p_payroll_action_id,
                                                argument6   => p_organization_id,
                                                argument7   => p_org_hierarchy,
                                                argument8   => p_assignment_set_id,
                                                argument9   => p_location_code,
                                                argument10  => p_assignment_action_id,
                                                argument11  => p_business_group_id,
                                                argument12  => p_sort_order1,
                                                argument13  => p_sort_order2,
                                                argument14  => p_profile_out_folder,
                                                argument15  => p_rec_per_file,
                                                argument16  => p_chunk_size,
                                                argument17  => x,
                                                argument18  => p_person_type,
						argument19  =>p_print_style,--bug 8241399
                                                -- p_print style parameter added to suppress additional blank page
                                                argument20  =>p_priv_mark);--bug 8942337
                  if (x * p_chunk_size) > l_asg_count then
                      --l_temp := (x * p_chunk_size) - l_asg_count;
                      l_temp := l_asg_count - ((x-1) * p_chunk_size) ;  -- Modified for the bug #8781376
                  else
                      l_temp := p_chunk_size;
                  end if;
                  write_body(p_file_no    => x,
                             p_request_id   => l_id,
                             p_file_name    => 'o' || l_id || '.out',
                             p_size         => l_temp);
              end loop;
              write_footer(p_total => l_asg_count);
            end if;
          end if;
     end;

END PAY_GB_P11D_PDF_CONTROL;

/
