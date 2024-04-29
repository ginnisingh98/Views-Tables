--------------------------------------------------------
--  DDL for Package Body PAY_US_GEO_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GEO_UPD_PKG" as
/* $Header: pyusgeou.pkb 120.14.12010000.9 2009/08/25 19:10:29 jdevasah ship $ */

--Bug 2996546 declare pl/sql table variables in order to load
--input_value_id from pay_input_values_f


TYPE     piv_type is table of pay_input_values_f.input_value_id%type
         index by binary_integer ;
l_counter       number := 0 ;
l_total         number := 0 ;
l_number        number := 0 ;


input_val_cur piv_type ;
piv_rec pay_input_values_f%rowtype;


function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;



procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

--

  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_year        varchar2(4);

  ln_upgrade_patch    pay_patch_status.patch_name%TYPE;
--
begin

     hr_utility.trace('reached range_cursor');

   select ppa.legislative_parameters,
          pay_us_geo_upd_pkg.get_parameter('PATCH_NAME',PPa.legislative_parameters)
     into leg_param,
          ln_upgrade_patch
     from pay_payroll_actions ppa
     where ppa.payroll_action_id = pactid;

   sqlstr := ' select distinct paf.person_id
    from pay_us_modified_geocodes mg,
         pay_us_emp_city_tax_rules_f tr,
         per_all_assignments_f paf,
         pay_us_states pus
   where mg.patch_name = '''||ln_upgrade_patch||'''
     and mg.state_code = pus.state_code
     and mg.state_code = tr.state_code
     and mg.county_code = tr.county_code
     and mg.old_city_code = tr.city_code
     and tr.assignment_id = paf.assignment_id
     and :pactid is not null
   order by paf.person_id';

hr_utility.trace(sqlstr);

     hr_utility.trace('leaving range_cursor');

end range_cursor;


---------------------------------- action_creation ----------------------------------
--
procedure action_creation (pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_year        varchar2(4);
  l_geo_phase_id number;
  l_mode        Pay_Payroll_actions.legislative_parameters%type;

  l_patch_name    pay_patch_status.patch_name%TYPE;




  cursor c_parameters ( pactid number) is
   select ppa.legislative_parameters,
          pay_us_geo_upd_pkg.get_parameter('PATCH_NAME',PPa.legislative_parameters),
          pay_us_geo_upd_pkg.get_parameter('MODE',PPa.legislative_parameters)
     from pay_payroll_actions ppa
     where ppa.payroll_action_id = pactid;


  CURSOR c_actions_assignment
      (
         pactid    number,
         stperson  number,
         endperson number
      ) is

  SELECT distinct  ectr.assignment_id
   FROM   per_all_assignments_f paf,
          pay_us_emp_city_tax_rules_f ectr,
          pay_us_modified_geocodes pmod
   WHERE  pmod.state_code = ectr.state_code
     AND  pmod.county_code = ectr.county_code
     AND  pmod.new_county_code is null
     AND  pmod.old_city_code = ectr.city_code
     AND  pmod.process_type in ('UP','US','PU','D','SU')
     AND  pmod.patch_name = l_patch_name
     AND  ectr.assignment_id = paf.assignment_id
     AND  paf.person_id between stperson and endperson
     AND  NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = ectr.assignment_id
		       and pugu.new_juri_code = pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code
		       and pugu.old_juri_code = ectr.jurisdiction_code
                       and pugu.table_value_id is null
                       and pugu.table_name is null
		       and pugu.process_type = pmod.process_type
                       and pugu.process_mode = l_mode
                       and pugu.id = l_geo_phase_id)
UNION ALL

   SELECT distinct  pac.assignment_id
  FROM   per_all_assignments_f paf,
         pay_action_contexts pac,
         pay_us_modified_geocodes pmod
  WHERE  pmod.state_code = 'CA'
    AND  pmod.county_code = pac.context_value
    AND  pac.context_id  in (select context_id
                               from ff_contexts
                               where context_name = 'JURISDICTION_CODE')
    AND  pmod.patch_name = l_patch_name
    AND  pac.assignment_id = paf.assignment_id
    AND  paf.person_id between stperson and endperson ;


/* Changing the hint to use index PAY_US_MODIFIED_GEOCODES_N1 */
  CURSOR c_actions_run_bal
      (
         pactid    number,
         p_balance_load_date date
      ) is
        select ppa.payroll_action_id
         from per_business_groups pbg, pay_payroll_actions ppa
        Where ppa.action_type in ('R', 'Q', 'I', 'B', 'V')
          and ppa.effective_date >= p_balance_load_date
          and pbg.business_group_id = ppa.business_group_id
          and pbg.legislation_code in ( 'US', 'CA');

    cursor c_get_phase_id (p_patch_name  varchar2)
    is
       select ID
       from pay_patch_status
       where patch_name = p_patch_name
       and status in ('P','E');

   Cursor c_geo_check (p_patch_name   in varchar2) is
    select phase, status from pay_patch_status
     where patch_name like p_patch_name || '%'
       and legislation_code = 'US';

      l_assignment_id        number;
      l_payact_id            number;
      lockingactid           number;

      lv_phase               varchar2(30);
      lv_status              varchar2(2);

      l_balance_load_date   pay_balance_validation.balance_load_date%type;
--
   /* Bug#7240914: New variables */
     lv_no_of_chunks number;
     lv_count        number;
     lv_curr_chunk   number;
  /* Bug#7240914: Changes end*/
   begin

--  hr_utility.trace_on('','TCL');

      hr_utility.trace('entering action_creation');
      hr_utility.set_location('geocode_action_creation',1);

      open c_parameters(pactid);

      fetch c_parameters into leg_param,
                              l_patch_name,
                              l_mode;

      close c_parameters;

       hr_utility.trace('l_patch_name is '|| l_patch_name );


       hr_utility.trace('before open c_geo_check ');
     open c_geo_check (l_patch_name);

    fetch c_geo_check into lv_phase, lv_status;

    if c_geo_check%notfound or lv_status <> 'C' then
    hr_utility.trace('c_geo_check not found ');

        if c_geo_check%notfound and chunk=1 then
    hr_utility.trace('c_geo_check not found chunk = 1');
             /*
                If both conditions above are true, there is a geocode update
                underway and a row for this process needs to be added to the
                pay_patch_status table.
             */
     hr_utility.trace('inserting into pay_patch_status ');
             insert into pay_patch_status
                 (ID,
                  PATCH_NUMBER,
                  PATCH_NAME,
                  PHASE,
                  PROCESS_TYPE,
                  APPLIED_DATE,
                  STATUS,
                  DESCRIPTION,
                  UPDATE_DATE,
                  LEGISLATION_CODE,
                  APPLICATION_RELEASE,
                  PREREQ_PATCH_NAME)
                values
                  (PAY_PATCH_STATUS_S.nextval,
                   '1111111',
                   l_patch_name, --p_patch_name,
                   'START',
                   null,
                   sysdate,
                   'P',
                   'CURRENT GEOCODE PATCH', -- lv_patch_desc,
                   null,
                   'US',
                   '115',
                   'Q2' );

             end if;  -- end if for the chunk=1

           hr_utility.trace('opening c_get_phase_id ');

           open c_get_phase_id(l_patch_name);

           fetch c_get_phase_id into l_geo_phase_id;


          hr_utility.trace('value of l_geo_phase id is '|| to_char(l_geo_phase_id ));


              hr_utility.set_location('geocode_action_creation',2);
              open c_actions_assignment(pactid,stperson,endperson);

              loop
                 hr_utility.set_location('geocode_action_creation',3);
                 fetch c_actions_assignment into l_assignment_id;

                 exit when c_actions_assignment%notfound;

                	hr_utility.set_location('geocode_action_creation',4);
                	select pay_assignment_actions_s.nextval
                	into   lockingactid
                	from   dual;

                	-- insert the action record.

                	hr_nonrun_asact.insact(lockingactid =>  lockingactid,
                                           Object_Id     =>  l_assignment_id,
                                           pactid       =>  pactid,
                                           chunk        =>  chunk,
                                           object_type   =>  'ASG');
        --
              end loop;  -- loop 1
              close c_actions_assignment;


        -- Create actions for  GRE level Run balances

              hr_utility.set_location('geocode_action_creation',5);


       hr_utility.trace('before update_taxability_rules value of l_geo_phase_Id is '|| to_char(l_geo_phase_Id));

              IF chunk=1 THEN

	             select min(balance_load_date)
	             into l_balance_load_date
	             from pay_balance_validation;
	              open c_actions_run_bal(pactid,l_balance_load_date);

	              /* Bug#7240914: Fetch number of chunks created for the current run
                   from table pay_population_ranges */
	              hr_utility.trace( 'Fetching Number of chunks created for this process from pay_population_ranges.');
	              select max(chunk_number)
                  into lv_no_of_chunks
                  from pay_population_ranges
                 where  payroll_action_id = pactid;

	              hr_utility.trace( 'Number of chunks: ' || to_char(lv_no_of_chunks));
	              lv_no_of_chunks := NVL(lv_no_of_chunks,0);
	              lv_count := 1 ;
                /*Bug#7240914: Changes end here*/
	              loop
	                 hr_utility.set_location('gocode_action_creation',6);
	                 fetch c_actions_run_bal into l_payact_id;

	                 exit when c_actions_run_bal%notfound;
	        --

	                	hr_utility.set_location('gocode_action_creation',7);
	                	select pay_assignment_actions_s.nextval
	                	into   lockingactid
	                	from   dual;
	        --
	                 /*Bug#7240914: if lv_no_of_chunks < 1 then assign all to chunk 1
                     else use the iterator lv_count to distribute records among
                     all chunks. */
	                 IF lv_no_of_chunks < 1 THEN
	                     lv_curr_chunk := 1 ;
	                 ELSE
                      select decode (mod(lv_count,lv_no_of_chunks),0,lv_no_of_chunks,mod(lv_count,lv_no_of_chunks))
                        into lv_curr_chunk
                        from dual;
                   END IF;

                    hr_utility.trace( 'lv_count: ' || to_char(lv_count));
                    hr_utility.trace( 'lv_current_chunk: ' || to_char(lv_curr_chunk));
	                  /*Bug#7240914: changes end here */
	                	hr_nonrun_asact.insact(lockingactid   =>  lockingactid,
	                                           Object_id    =>  l_payact_id,
	                                           pactid       =>  pactid,
	                                        -- chunk        =>  chunk,
	                                           chunk        => lv_curr_chunk, /*Bug#7240914 */
	                                          object_type   =>  'PER');
	        --
	              lv_count := lv_count + 1 ;  /*Bug#7240914 */
	              end loop;  -- loop 1
	              close c_actions_run_bal;


                 pay_us_geo_upd_pkg.update_taxability_rules(l_geo_phase_id,l_mode,l_patch_name);  --l_patch_name);

                 pay_us_geo_upd_pkg.update_org_info(l_geo_phase_id,l_mode,l_patch_name);          --l_patch_name);

                 pay_us_geo_upd_pkg.update_ca_emp_info(l_geo_phase_id,l_mode,l_patch_name);

              END IF;


              hr_utility.trace('leaving action_creation');

           if c_get_phase_id%isopen then
              close c_get_phase_id;
           end if;

        END IF;  /* lv_status patch is 'C' and no actions were created  */

       if c_geo_check%isopen then
          close c_geo_check;
       end if;

end action_creation;


procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out  nocopy  number        /* length of the sql string */
) is
begin

      sqlstr :=  'select paa1.rowid
                    from pay_assignment_actions paa1,   -- PYUGEN assignment action
                         pay_payroll_actions    ppa1    -- PYUGEN payroll action id
                   where ppa1.payroll_action_id = :pactid
                     and paa1.payroll_action_id = ppa1.payroll_action_id
                   order by paa1.assignment_action_id
                   for update of paa1.assignment_id';

      len := length(sqlstr); -- return the length of the string.
   end sort_action;


 PROCEDURE archive_code(p_xfr_action_id  in number
                      ,p_effective_date in date)
    IS

    cursor c_xfr_info (cp_assignment_action in number) is
      select ptoa.payroll_action_id,
             ptoa.object_id,
             ptoa.object_type
        from PAY_TEMP_OBJECT_ACTIONS  ptoa
       where ptoa.object_action_id = cp_assignment_action;

  cursor c_parameters ( pactid number) is
   select ppa.legislative_parameters,
          pay_us_geo_upd_pkg.get_parameter('PATCH_NAME',PPa.legislative_parameters),
          pay_us_geo_upd_pkg.get_parameter('MODE',PPa.legislative_parameters)
     from pay_payroll_actions ppa
     where ppa.payroll_action_id = pactid;

    cursor c_get_phase_id (p_patch_name  varchar2)
    is
       select ID
       from pay_patch_status
       where patch_name = p_patch_name
       and status in ('P','E');

    l_payroll_action_id   number;
    l_object_id           number;
    l_object_type         PAY_TEMP_OBJECT_ACTIONS.object_type%TYPE;

    l_geo_phase_id        number;
    l_year                varchar2(4);
    l_mode                varchar2(7);
    leg_param             pay_payroll_actions.legislative_parameters%type;
    l_patch_name          pay_patch_status.patch_name%type;

  BEGIN

  hr_utility.set_location ('pay_us_geo_update.action_code', 1);

    open c_xfr_info (p_xfr_action_id);

    fetch c_xfr_info into l_payroll_action_id,
                           l_object_id,
                           l_object_type;

    close c_xfr_info;

    open c_parameters(l_payroll_action_id);

    fetch c_parameters into leg_param,
                              l_patch_name,
                              l_mode;
   close c_parameters;

   open c_get_phase_id(l_patch_name);
   fetch c_get_phase_id into l_geo_phase_id;
   close c_get_phase_id;


    if l_object_type = 'ASG'  THEN

        pay_us_geo_upd_pkg.upgrade_geocodes (p_assign_start => l_object_id,
			                               p_assign_end   => l_object_id,
			                               p_geo_phase_id => l_geo_phase_id,
			                               p_mode	      => l_mode,
                                                       p_patch_name   => l_patch_name);


    elsif l_object_type = 'PER' Then

        pay_us_geo_upd_pkg.group_level_balance (P_START_PAYROLL_ACTION  => l_object_id,
                                              P_END_PAYROLL_ACTION    => l_object_id,
                                              P_GEO_PHASE_ID          => l_geo_phase_id,
                                              P_MODE                  => l_mode,
                                              P_PATCH_NAME            => l_patch_name);

    END IF;

  END archive_code;



  procedure archive_deinit( p_payroll_action_id in number)
            is
            --
            --
              Cursor c_get_params is
                select patch_name, patch_number
                  from pay_patch_status
                 where description = 'CURRENT GEOCODE PATCH';

              Cursor c_geo_check (p_patch_name   in varchar2,
                                  p_patch_number in number   ) is
               select id from pay_patch_status
                where patch_name = p_patch_name
                  and patch_number = p_patch_number
                  and legislation_code = 'US';


            -- Bug 3354053 -- Changed the cursor query to remove the FTS from pay_us_geo_update.
              Cursor c_geo_upd (p_patch_id     in number,
                                p_patch_status in varchar2) is
              select 'x' from dual
                where exists(select 'x' from pay_us_geo_update
                               where id = p_patch_id
                              and status = p_patch_status
                              and rownum < 2);

               cursor c_parameters ( pactid number) is
               select ppa.legislative_parameters,
                      pay_us_geo_upd_pkg.get_parameter('PATCH_NAME',PPa.legislative_parameters),
                      pay_us_geo_upd_pkg.get_parameter('MODE',PPa.legislative_parameters)
                 from pay_payroll_actions ppa
                 where ppa.payroll_action_id = pactid;



              lv_cur_geo_patch varchar2(240);
              ln_patch_number  number;
              ln_patch_id      number;
              lc_error varchar2(10);
              lc_status varchar2(1);
              --
              ln_upgrade_patch    pay_patch_status.patch_name%TYPE;
              ln_upgrade_patch_id pay_patch_status.id%TYPE;
              leg_param    pay_payroll_actions.legislative_parameters%type;
              l_year        varchar2(4);
              l_mode       pay_payroll_actions.legislative_parameters%type;
              l_geo_phase_id number;

              l_patch_name    pay_patch_status.patch_name%TYPE;

              l_req_id    number;
              copies_buffer varchar2(80) := null;
              print_buffer  varchar2(80) := null;
              printer_buffer  varchar2(80) := null;
              style_buffer  varchar2(80) := null;
              save_buffer  boolean := null;
              save_result  varchar2(1) := null;
              req_id  varchar2(80) := null;
              x boolean;
              x1 boolean;

              l_valid_status  varchar2(5);
              l_program       varchar2(100);
              retcode         number;
              errbuf          varchar2(80);

            --
            --

            begin
              fnd_file.put_line(fnd_file.log, 'Inside Archive_deinit procedure');
              -- initialise variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
              retcode := 0;
              fnd_file.put_line(fnd_file.log, 'p_payroll_action_id: ' || to_char(p_payroll_action_id));
                  open c_parameters(p_payroll_action_id);

                  fetch c_parameters into leg_param,
                                          l_patch_name,
                                          l_mode;
                  close c_parameters;
                fnd_file.put_line(fnd_file.log, 'leg_param: ' || to_char(leg_param));
                fnd_file.put_line(fnd_file.log, 'l_patch_name: ' || l_patch_name);
                fnd_file.put_line(fnd_file.log, 'l_mode: ' || l_mode);
            /*****   submit the geocode reports ****/

                   pay_us_geocode_report_pkg.extract_data( errbuf
                                                          ,retcode
                                                          ,p_process_mode       => l_mode
                                                          ,p_geocode_patch_name => l_patch_name );

            /* Wrap up the geocode process */

             lc_status := 'C';

              open c_get_params;
              fetch c_get_params into lv_cur_geo_patch, ln_patch_number;
              close c_get_params;

              --hr_utility.trace(' lv_cur_geo_patch = ' || lv_cur_geo_patch);
              --hr_utility.trace('archive deinit ln_patch_number = ' || ln_patch_number);
              fnd_file.put_line(fnd_file.log, ' lv_cur_geo_patch = ' || lv_cur_geo_patch);
              fnd_file.put_line(fnd_file.log, 'archive deinit ln_patch_number = ' || ln_patch_number);
              --
              open c_geo_check(lv_cur_geo_patch, ln_patch_number);
              fetch c_geo_check into ln_patch_id;
              if c_geo_check%found then

                 fnd_file.put_line(fnd_file.log, 'c_geo_check%found');
                 open c_geo_upd(ln_patch_id, 'P');
                fetch c_geo_upd into lc_error;
                if c_geo_upd%found then
                    fnd_file.put_line(fnd_file.log, 'c_geo_upd%found');
                    update pay_patch_status
                      set status = 'E'
                     where id = ln_patch_id;

                else
                    fnd_file.put_line(fnd_file.log, 'c_geo_upd%notfound');
                    update pay_patch_status
                      set status = 'C',
                          phase = null,
                          process_type = null,
                          description = null
                     where id = ln_patch_id;

                end if;
                close c_geo_upd;
              else /* c_geo_check%found */
                fnd_file.put_line(fnd_file.log, 'c_geo_check%notfound');
              end if;
              close c_geo_check;

        /*    EXCEPTION
              --
               WHEN hr_utility.hr_error THEN
                 --
                 -- Set up error message and error return code.
                 --

                hr_utility.trace('in the exception 1');

                 errbuf  := hr_utility.get_message;
                 retcode := 2;
                 --
           --
            WHEN others THEN
            --
                 -- Set up error message and return code.
                 --

                hr_utility.trace('in the exception 2 sqlerrm = ' || sqlerrm);

                 errbuf  := sqlerrm;
                 retcode := 2;  */
  end archive_deinit;



PROCEDURE  write_message(
                        p_proc_type      IN VARCHAR2,
                        p_person_id      IN NUMBER,
                        p_assign_id      IN NUMBER,
                        p_old_juri_code  IN VARCHAR2,
                        p_new_juri_code  IN VARCHAR2,
                        p_location       IN VARCHAR2,
                        p_id             IN NUMBER,
                        p_status         IN VARCHAR2 DEFAULT NULL)

IS

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.write message');

 	IF G_MODE = 'UPGRADE' THEN
        insert into PAY_US_GEO_UPDATE (ID,
                                       ASSIGNMENT_ID,
                                       PERSON_ID,
                                       TABLE_NAME,
                                       TABLE_VALUE_ID,
                                       OLD_JURI_CODE,
                                       NEW_JURI_CODE,
                                       PROCESS_TYPE,
                                       PROCESS_DATE,
				       PROCESS_MODE,
                                       STATUS)
        VALUES(g_geo_phase_id,
	       p_assign_id,
               p_person_id,
               p_location,
               p_id,
               p_old_juri_code,
               p_new_juri_code,
               p_proc_type,
               sysdate,
	       'UPGRADE',
               p_status);

	ELSE
	 insert into PAY_US_GEO_UPDATE (ID,
                                       ASSIGNMENT_ID,
                                       PERSON_ID,
                                       TABLE_NAME,
                                       TABLE_VALUE_ID,
                                       OLD_JURI_CODE,
                                       NEW_JURI_CODE,
                                       PROCESS_TYPE,
                                       PROCESS_DATE,
				       PROCESS_MODE,
                                       STATUS)
        VALUES(g_geo_phase_id,
               p_assign_id,
               p_person_id,
               p_location,
               p_id,
               p_old_juri_code,
               p_new_juri_code,
               p_proc_type,
               sysdate,
	       g_mode,
               p_status);


	END IF;
hr_utility.trace('Exiting pay_us_geo_upd_pkg.write message');

END write_message;


-- We can call upgrade_geocodes in a DEBUG mode also.
-- DEBUG mode will not do any updates in the tables.  It will
-- Create the city tax records and vertex element entries though.
-- But it only creates them if they are missing in the first place.
-- We are defaulting to NULL, in our update statements we check for DEBUG

PROCEDURE  upgrade_geocodes(P_ASSIGN_START NUMBER,
                            P_ASSIGN_END NUMBER,
	          	    P_GEO_PHASE_ID NUMBER,
	    		    P_MODE VARCHAR2,
                            P_PATCH_NAME VARCHAR2,
		            P_CITY_NAME VARCHAR2 DEFAULT NULL,
		            P_API_MODE  VARCHAR2 DEFAULT 'N')

IS
--Retrieve all changed geocodes on per_assignment_extra_info table. This will
--be our main 'driving' table
/*  CURSOR paei_cur IS
    SELECT  distinct paei.aei_information2, paei.aei_information13,
            paei.assignment_id,
            pmod.state_code||'-'||pmod.county_code||'-'
                                                  ||pmod.new_city_code jd_code,
            paf.person_id
    FROM    per_assignments_f paf,
            pay_us_modified_geocodes pmod,
            per_assignment_extra_info paei
    WHERE   paei.information_type = 'LOCALITY'
    AND     substr(paei.aei_information2,8,4) <> '0000'
    AND     pmod.city_name = paei.aei_information13
    AND     pmod.state_code = substr(paei.aei_information2,1,2)
    AND     pmod.county_code = substr(paei.aei_information2,4,3)
    AND     pmod.old_city_code = substr(paei.aei_information2,8,4)
    AND     pmod.process_type in ('UP','US','PU','D','SU','RP','RS')
    AND     paf.assignment_id = paei.assignment_id;

  paei_rec   paei_cur%ROWTYPE; */

--Retrieve all changed geocodes on pay_us_emp_city_tax_rules_f table.
--This will be our main 'driving' table.
--Added the ASSIGN START and ASSIGN END so that we can multi-thread the
--driving cursor
--
--
--Per bug 2996546 added another select statement with UNION ALL
--to the CURSOR main_driving_cur in order to process Canadian
--Legislation data
--
--

  CURSOR main_driving_cur(P_ASSIGN_START NUMBER, P_ASSIGN_END NUMBER, P_CITY_NAME VARCHAR2, P_API_MODE VARCHAR2) IS
  SELECT distinct ectr.jurisdiction_code, ectr.assignment_id,
       pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code jd_code,
          paf.person_id, pmod.new_city_code, pmod.process_type, ectr.emp_city_tax_rule_id
   FROM   per_all_assignments_f paf,
          pay_us_emp_city_tax_rules_f ectr,
          pay_us_modified_geocodes pmod
   WHERE  pmod.state_code = ectr.state_code
     AND  pmod.county_code = ectr.county_code
     AND  pmod.new_county_code is null
     AND  pmod.old_city_code = ectr.city_code
     AND  pmod.process_type in ('UP','US','PU','D','SU')
     AND  pmod.patch_name = p_patch_name
     AND  ectr.assignment_id = paf.assignment_id
     AND  pmod.city_name = nvl(p_city_name, pmod.city_name)
     AND  paf.assignment_id between P_ASSIGN_START and P_ASSIGN_END
     AND  NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = ectr.assignment_id
		       and pugu.new_juri_code = pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code
		       and pugu.old_juri_code = ectr.jurisdiction_code
                       and pugu.table_value_id is null
                       and pugu.table_name is null
		       and pugu.process_type = pmod.process_type
                       and pugu.process_mode = g_mode
                       and pugu.id = g_geo_phase_id
		       and ((p_api_mode = 'Y' and pugu.status = 'C') or
			   (p_api_mode = 'N' and pugu.status in ('A','C'))))
UNION ALL
  SELECT distinct pac.context_value, pac.assignment_id,
         pmod.new_county_code jd_code,
         paf.person_id, pmod.new_city_code, pmod.process_type,
         pac.context_id
    FROM per_all_assignments_f paf,
         pay_action_contexts pac,
         pay_us_modified_geocodes pmod
  WHERE  pmod.state_code = 'CA'
    AND  pmod.county_code = pac.context_value
    AND  pac.context_id  in (select context_id
                               from ff_contexts
                               where context_name = 'JURISDICTION_CODE')
    AND  pmod.patch_name = p_patch_name
    AND  pac.assignment_id = paf.assignment_id
    AND  paf.assignment_id between P_ASSIGN_START and P_ASSIGN_END ;


main_old_juri_code varchar2(11);
main_assign_id number;
main_new_juri_code varchar2(11);
main_person_id number;
main_new_city_code varchar2(4);
main_proc_type varchar2(3);
main_city_tax_rule_id number;
lv_update_prr  varchar2(1);

--  main_ ectr_cur%ROWTYPE;

--Retrieve all affected rows in PAY_US_EMP_CITY_TAX_RULES_F
--This is decoupled from above because we still want the level of
--of granularity for city tax records that are changed.
--We already have this information we just need to verify if it has
--been processed already.
--Since we have this cursor we do not need this in the city_tax_records
--procedure. We could have put it there but there is no need.

cursor city_rec_cur (p_new_juri_code VARCHAR2, p_old_juri_code VARCHAR2,
                     p_assign_id NUMBER, p_city_tax_record_id NUMBER)
IS
SELECT   distinct 'Y'
FROM     pay_us_emp_city_tax_rules_f puecf
WHERE    puecf.jurisdiction_code = p_old_juri_code
AND      puecf.assignment_id = p_assign_id
AND      puecf.emp_city_tax_rule_id = p_city_tax_record_id
AND      NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = p_assign_id
                       and pugu.table_value_id = puecf.emp_city_tax_rule_id
                       and pugu.old_juri_code = p_old_juri_code
                       and pugu.table_name = 'PAY_US_EMP_CITY_TAX_RULES_F'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);

l_city_tax_exists varchar2(2);

--Retrieve all affected rows in the pay_element_entry_values_f table.
--Since we can join on the main part of the pk of the table we do not
--need the logic in the element_entries procedure.

--
--Per bug 2996546 changed the where clause for
--piv.legislation_code = 'US' to use the function
--IS_US_OR_CA_LEGISLATION and compare input value id
--stored in pl/sql table to improve performance
--
--


  CURSOR pev_cur(geocode VARCHAR2, assign_id NUMBER) IS
    SELECT /*+ ORDERED */ distinct pev.screen_entry_value, pev.element_entry_id,
           pev.input_value_id
    FROM   pay_element_entries_f pee,
           pay_element_entry_values_f pev,
           pay_input_values_f piv
    WHERE  pee.assignment_id = assign_id
    AND    pee.element_entry_id = pev.element_entry_id
    AND    pev.screen_entry_value = geocode
    AND    pev.input_value_id = piv.input_value_id
    AND    piv.name = 'Jurisdiction'
--  AND    piv.legislation_code = 'US'
    AND    IS_US_OR_CA_LEGISLATION(piv.input_value_id) = piv.input_value_id
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
		       where pugu.assignment_id = assign_id
 		       and pugu.table_value_id = pev.element_entry_id
		       and pugu.old_juri_code = geocode
		       and pugu.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
		       and pugu.id = g_geo_phase_id);

  pev_rec   pev_cur%ROWTYPE;

--Retrieve all affected rows in the pay_run_results table.
--The run_result_id's from this cursor will then be
--used to dertermine the rows to update in the pay_run_result_values
--table note since run_result_id is driving for the value table we have to pick
--up all regardless if the geocode has changed because they may have run result values
--that are tagged to a different jurisdiction.
--Right now if the patch is reran this cursor will still pick up assignments that have
--already been processed but for run result ids that do not have a modified geocode, but
--when it goes through the procedure it WILL NOT update wrong geocodes because the
--jurisdictions will not match.  So this can be changed in the future to add the logic
--here versus in the procedure: run_results.


-- Bug 3319878 -- Breaked the query into two cursors i.e paa_cur and prr_cur.
  CURSOR paa_cur(assign_id NUMBER) IS
    SELECT assignment_action_id
      FROM pay_assignment_actions
     WHERE assignment_id = assign_id;

  CURSOR prr_cur(assign_action_id NUMBER,assign_id NUMBER) IS
    SELECT distinct prr.run_result_id,
           prr.assignment_action_id, prr.jurisdiction_code
    FROM   pay_run_results prr
    WHERE  prr.assignment_action_id = assign_action_id
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = assign_id
		       and pugu.table_value_id = prr.run_result_id
		       and pugu.old_juri_code = prr.jurisdiction_code
		       and pugu.table_name = 'PAY_RUN_RESULTS'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
		       and pugu.id = g_geo_phase_id);

  paa_rec   NUMBER;

  prr_rec   prr_cur%ROWTYPE;

--Per bug 2996546
--Retrieves all affected rows in the table pay_action_contexts
--
--
CURSOR pac_cur(assign_id NUMBER, context_id  NUMBER) IS
    SELECT pac.context_id,
           pac.assignment_action_id
    FROM   pay_action_contexts pac,
           pay_assignment_actions paa
    WHERE  paa.assignment_id = assign_id
    AND    pac.assignment_id = paa.assignment_id    -- Bug# 3679984 added this to where clause
    AND    paa.assignment_action_id = pac.assignment_action_id
    AND    pac.context_id = context_id  ;

  pac_rec   pac_cur%ROWTYPE;



--Retrieve all affected rows in the ff_archive_item_contexts table.
--This cursor will check for a specific geocode that is passed in.
--The passed in geocode will be the old one from pay_us_modified_geocodes.
--We are joining with the archive item id, so we don't need this logic
--in the procedure archive_items.

/*  CURSOR fac_cur(assign_id NUMBER, geocode VARCHAR2) IS
    SELECT distinct paa.assignment_action_id,
           faic.context old_juri_code, faic.archive_item_id, ffc.context_id
    FROM   ff_archive_items fai,
           ff_archive_item_contexts faic,
           pay_assignment_actions paa,
           pay_payroll_actions ppa,
           ff_contexts ffc
  WHERE    ppa.report_type = 'YREND'
    AND    ppa.report_category = 'RT'
    AND    ppa.report_qualifier = 'FED'
    AND    ppa.payroll_action_id = paa.payroll_action_id
    AND    paa.assignment_id = assign_id
    AND    fai.context1 = paa.assignment_action_id
    AND    fai.archive_item_id = faic.archive_item_id
    AND    faic.context = geocode
    AND    ffc.context_id = faic.context_id
    AND    ffc.context_name = 'JURISDICTION_CODE'
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = assign_id
                       and pugu.table_value_id = faic.archive_item_id
                       and pugu.old_juri_code = faic.context
                       and pugu.table_name = 'FF_ARCHIVE_ITEM_CONTEXTS'
                       and pugu.process_mode = g_mode
                       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);
*/
--Bug 3126437 hrglobal performance fix
--
CURSOR fac_cur(assign_id NUMBER, geocode VARCHAR2) IS
SELECT distinct paa.assignment_action_id,
                faic.context old_juri_code,
                faic.archive_item_id,
                ffc.context_id
        FROM ff_archive_items fai,
             ff_archive_item_contexts faic,
             pay_assignment_actions paa,
             pay_payroll_actions ppa,
             ff_contexts ffc
       WHERE ppa.report_type       in ('T4', 'T4A', 'RL1', 'RL2', 'YREND')
         and ppa.report_category   in ('RT', 'CAEOYRL1', 'CAEOYRL2', 'CAEOY', 'CAEOY')
         and report_qualifier      in ('FED','CAEOYRL1', 'CAEOYRL2', 'CAEOY', 'CAEOY')
         and ppa.payroll_action_id = paa.payroll_action_id
         and paa.assignment_id     = assign_id
         and fai.context1          = paa.assignment_action_id
         and fai.archive_item_id   = faic.archive_item_id
         and faic.context          = geocode
         and ffc.context_id        = faic.context_id
         and ffc.context_name      = 'JURISDICTION_CODE'
         and not exists (select 'Y' from PAY_US_GEO_UPDATE pugu
                          where pugu.assignment_id  = assign_id
                            and pugu.table_value_id = faic.archive_item_id
                            and pugu.old_juri_code  = faic.context
                            and pugu.table_name     = 'FF_ARCHIVE_ITEM_CONTEXTS'
                            and pugu.process_mode   = g_mode
                            and pugu.process_type   = g_process_type
                            and pugu.id             = g_geo_phase_id);
  fac_rec   fac_cur%ROWTYPE;

--Retrieve affected rows in the pay_balance_context_values table
--using the latest_balance_id's from the pay_person_latest_balances
--table.
--Since we can join by the pk of the table we do not need any more logic
--in the balance_contexts procedure.

  CURSOR pbcv_cur(geocode VARCHAR2, assign_id NUMBER, personid NUMBER) IS
    SELECT distinct pbcv.context_id, pbcv.value, pbcv.latest_balance_id,
           plb.assignment_action_id
    FROM   pay_assignment_actions paa,
           pay_balance_context_values pbcv,
           pay_person_latest_balances plb,
     	   ff_contexts fcon
    WHERE  paa.assignment_id = assign_id
    AND    paa.assignment_action_id = plb.assignment_action_id
    AND    plb.person_id = personid
    AND    pbcv.latest_balance_id = plb.latest_balance_id
    AND    pbcv.value = geocode
    AND    fcon.context_id = pbcv.context_id
    AND    fcon.context_name = 'JURISDICTION_CODE'
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = assign_id
                       and pugu.table_value_id = plb.latest_balance_id
		       and pugu.old_juri_code = geocode
		       and pugu.table_name = 'PAY_BALANCE_CONTEXT_VALUES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
		       and pugu.id = g_geo_phase_id);

  pbcv_rec   pbcv_cur%ROWTYPE;

--Retrieve affected rows in the pay_balance_context_values table
--using the latest_balance_id's from the pay_assignment_latest_balances
--table.
  CURSOR pacv_cur(geocode VARCHAR2, assign_id NUMBER, personid NUMBER) IS
    SELECT distinct pbcv.context_id, pbcv.value, pbcv.latest_balance_id,
           plb.assignment_action_id
    FROM   ff_contexts fcon,
           pay_balance_context_values pbcv,
           pay_assignment_latest_balances plb
    WHERE  plb.assignment_id = assign_id
    AND    pbcv.latest_balance_id = plb.latest_balance_id
    AND    pbcv.value = geocode
    AND    fcon.context_id = pbcv.context_id
    AND    fcon.context_name = 'JURISDICTION_CODE'
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = assign_id
                       and pugu.table_value_id = plb.latest_balance_id
                       and pugu.old_juri_code = geocode
                       and pugu.table_name = 'PAY_BALANCE_CONTEXT_VALUES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
		       and pugu.id = g_geo_phase_id);


  pacv_rec   pacv_cur%ROWTYPE;

-- Rosie Monge 10/17/2005 Bug 4602222
--Retrieve affected rows in the pay_balance_context_values table
--using the latest_balance_id's from the pay_latest_balances
--table.

  CURSOR plbcv_cur(geocode VARCHAR2, assign_id NUMBER, personid NUMBER) IS
    SELECT distinct pbcv.context_id, pbcv.value, pbcv.latest_balance_id,
           plb.assignment_action_id
    FROM   ff_contexts fcon,
           pay_balance_context_values pbcv,
           pay_latest_balances plb
    WHERE  plb.assignment_id = assign_id
    AND    pbcv.latest_balance_id = plb.latest_balance_id
    AND    pbcv.value = geocode
    AND    fcon.context_id = pbcv.context_id
    AND    fcon.context_name = 'JURISDICTION_CODE'
    AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = assign_id
                       and pugu.table_value_id = plb.latest_balance_id
                       and pugu.old_juri_code = geocode
                       and pugu.table_name = 'PAY_BALANCE_CONTEXT_VALUES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
		       and pugu.id = g_geo_phase_id);


  plbcv_rec   pacv_cur%ROWTYPE;


-- This cursor will check if a particular assignment is errored.
CURSOR chk_assign_error_cur(p_assign_id NUMBER, p_new_juri_code VARCHAR2, p_old_juri_code VARCHAR2)
IS
SELECT 'Y' from PAY_US_GEO_UPDATE pugu
WHERE pugu.assignment_id = p_assign_id
AND   pugu.process_mode = g_mode
AND   pugu.id = g_geo_phase_id
AND   pugu.table_name is null
AND   pugu.status = 'P'
AND   pugu.new_juri_code = p_new_juri_code
AND   pugu.old_juri_code = p_old_juri_code;

l_chk_assign_error varchar2(4);
l_error_text varchar2(1000);

-- This cursor will check if a particular assignment needs to be upgraded via the api.
-- If it does then we will update the status to 'A' in the main procedure.

CURSOR chk_assign_api_cur(p_assign_id NUMBER, p_new_juri_code VARCHAR2, p_old_juri_code VARCHAR2)
IS select distinct 'Y'
  from   pay_us_geo_update pugu
  where  pugu.process_type in ('SU','US')
  and    pugu.table_name is null
  and    pugu.process_mode = g_mode
  and    pugu.id = g_geo_phase_id
  and    pugu.assignment_id = p_assign_id
  and    pugu.table_name is null
  and    pugu.table_value_id is null
  and    pugu.old_juri_code = p_old_juri_code
  and    pugu.new_juri_code = p_new_juri_code
  and    NOT EXISTS (select 'Y' from pay_us_modified_geocodes pmod
			 where pmod.state_code = substr(pugu.new_juri_code,1,2)
	 		 and   pmod.county_code = substr(pugu.new_juri_code,4,3)
			 and   pmod.old_city_code = substr(pugu.old_juri_code,8)
                         and   pmod.new_city_code = substr(pugu.new_juri_code,8)
                         and   pmod.process_type not in ('SU','US')
                         and   pmod.patch_name = p_patch_name);

l_chk_assign_api varchar2(4);


sql_cursor              INTEGER;
ret                     INTEGER;
table_exist             NUMBER(1) := 0;
tab_name                VARCHAR2(30) := 'PAY_US_ASG_REPORTING';
l_text                  VARCHAR2(2000);
l_proc_stage 		VARCHAR2(240);

--
--
--
--Bug 2996546 PROCEDURE load_input_values loads input_value_id
--from  pay_input_values_f into a pl/sql table input_val_cur
-- for both seeded and non-seeded in US and Canada Legislations
--
--
--
PROCEDURE load_input_values IS
Begin

for piv_rec in (
 select piv.input_value_id
                  from pay_input_values_f piv
                 where piv.name in ('Jurisdiction', 'jd_rs', 'jd_wk')
                 and  (  (piv.legislation_code in( 'US', 'CA')
                          )
                       OR (piv.legislation_code is null
                              and piv.business_group_id is not null
                              and exists (select 'Y'
                                          from hr_organization_information hoi
                                          where  hoi.organization_id = piv.business_group_id
                                 and  hoi.org_information_context = 'Business Group Information'
                                          and  hoi.org_information9 in ('US','CA')
                                          )
                           )
                       )
                 )
                     Loop
         l_counter := l_counter+1;
         input_val_cur(l_counter):= piv_rec.input_value_id;

         end Loop;
         l_total := l_counter;


END load_input_values;

-- This procedure will update pay balance batch lines for a particular assignment id
-- Note the cursor use here. Where we have the cursor in before both write messages
-- this is because if we want to run in debug mode and the type is not SU and US the
-- sql rowcount wont work because we are bypassing the update.

PROCEDURE balance_batch_lines(p_proc_type     IN VARCHAR2,
                             p_person_id     IN NUMBER,
                             p_assign_id     IN NUMBER,
                             p_old_juri_code IN VARCHAR2,
                             p_new_juri_code IN VARCHAR2)

IS

CURSOR bal_batch_cur(p_new_juri_code varchar2, p_old_juri_code varchar2, p_assign_id number)
IS     select 'Y'
FROM   pay_balance_batch_lines
WHERE  jurisdiction_code = p_old_juri_code
AND    assignment_id = p_assign_id
AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = p_assign_id
                       and pugu.old_juri_code = p_old_juri_code
 		       and pugu.new_juri_code = p_new_juri_code
                       and pugu.table_name = 'PAY_BALANCE_BATCH_LINES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);

l_bal_batch_exist varchar2(2);


BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.balance_batch_lines');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of balance_batch_lines for assignment id: '||to_char(p_assign_id));

      IF G_MODE = 'UPGRADE' THEN

      UPDATE pay_balance_batch_lines
      SET    jurisdiction_code = p_new_juri_code
      WHERE  jurisdiction_code = p_old_juri_code
      AND    assignment_id = p_assign_id;

      END IF;

-- Write a message to the table to be later spooled to a report

		/*IF SQL%ROWCOUNT > 0 THEN 6864396 */

			  OPEN bal_batch_cur(p_new_juri_code, p_old_juri_code, p_assign_id);
		          FETCH bal_batch_cur into l_bal_batch_exist;
      			  IF bal_batch_cur%FOUND THEN

                          write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_BALANCE_BATCH_LINES',
                             p_id             => p_assign_id);

			    END IF;
		            CLOSE bal_batch_cur;

		/*END IF;*/

ELSE

-- Write a message to the table to be later spooled to a report

	OPEN bal_batch_cur(p_new_juri_code, p_old_juri_code, p_assign_id);
	FETCH bal_batch_cur into l_bal_batch_exist;
	IF bal_batch_cur%FOUND THEN

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_BALANCE_BATCH_LINES',
                             p_id             => p_assign_id);


	END IF;
	CLOSE bal_batch_cur;

END IF;

END balance_batch_lines;
---
---
---
--Per bug 2738574
-- This procedure will update pay_run_balances for a particular assignment id

PROCEDURE pay_run_balances  (p_proc_type     IN VARCHAR2,
                             p_person_id     IN NUMBER,
                             p_assign_id     IN NUMBER,
                             p_new_city_code IN VARCHAR2,
                             p_old_juri_code IN VARCHAR2,
                             p_new_juri_code IN VARCHAR2)

IS

CURSOR run_balance_cur(p_new_juri_code varchar2, p_old_juri_code varchar2, p_assign_id number)
IS     select 'Y'
FROM   pay_run_balances
WHERE  jurisdiction_code = p_old_juri_code
AND    assignment_id = p_assign_id
AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = p_assign_id
                       and pugu.old_juri_code = p_old_juri_code
 		       and pugu.new_juri_code = p_new_juri_code
                       and pugu.table_name = 'PAY_RUN_BALANCES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);

l_run_balance_exist varchar2(2);


BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.pay_run_balances');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of pay_run_balances for assignment id: '||to_char(p_assign_id));

      IF G_MODE = 'UPGRADE' THEN

      UPDATE pay_run_balances
      SET    jurisdiction_code  = p_new_juri_code,
             jurisdiction_comp3 = p_new_city_code
      WHERE  assignment_id      = p_assign_id
      AND    jurisdiction_code  = p_old_juri_code ;

      END IF;

-- Write a message to the table to be later spooled to a report

		/*IF SQL%ROWCOUNT > 0 THEN 6864396 */

                          write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_RUN_BALANCES',
                             p_id             => p_assign_id);


		/*END IF;*/

ELSE

-- Write a message to the table to be later spooled to a report

	OPEN run_balance_cur(p_new_juri_code, p_old_juri_code, p_assign_id);
	FETCH run_balance_cur into l_run_balance_exist;
	IF run_balance_cur%FOUND THEN

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_RUN_BALANCES',
                             p_id             => p_assign_id);


	END IF;
	CLOSE run_balance_cur;

END IF;

END pay_run_balances ;

---
---
---


-- This procedure will update the city tax records for  a particular assignment id
PROCEDURE city_tax_records (p_proc_type     IN VARCHAR2,
                           p_person_id      IN NUMBER,
                           p_assign_id      IN NUMBER,
                           p_old_juri_code  IN VARCHAR2,
                           p_new_juri_code  IN VARCHAR2,
			   p_new_city_code  IN VARCHAR2,
			   p_city_tax_record_id IN NUMBER)


IS

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.city_tax_records');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of city tax records for assignment id: '||to_char(p_assign_id));

      IF G_MODE = 'UPGRADE' THEN

      UPDATE pay_us_emp_city_tax_rules_f
      SET    jurisdiction_code = p_new_juri_code,
             city_code = p_new_city_code
      WHERE  jurisdiction_code = p_old_juri_code
      AND    assignment_id = p_assign_id
      AND    emp_city_tax_rule_id = p_city_tax_record_id
      AND    NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.assignment_id = p_assign_id
                       and pugu.table_value_id = p_city_tax_record_id
                       and pugu.old_juri_code = p_old_juri_code
                       and pugu.table_name = 'PAY_US_EMP_CITY_TAX_RULES_F'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);


      END IF;
-- Write a message to the table to be later spooled to a report

		/*IF SQL%ROWCOUNT > 0 THEN 6864396 */

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_US_EMP_CITY_TAX_RULES_F',
                             p_id             => p_city_tax_record_id);

		/*END IF;*/
ELSE

-- Write a message to the table to be later spooled to a report


                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_US_EMP_CITY_TAX_RULES_F',
                             p_id             => p_city_tax_record_id);

END IF;

END city_tax_records;

PROCEDURE del_dup_city_tax_recs IS

-- This cursor identifies assignment id/jurisdiction pairs that have multiple
-- rows in the pay_us_emp_city_tax_rules_f table created by geocode updates.
-- For example, prior to geocode patch 1105095, these geocodes were in place:
--                 Van Nuys, CA:       05-037-3880
--                 Woodland Hills, CA: 05-037-6080
--                 Los Angeles, CA:    05-037-1900
-- Patch 1105095 updated the first two geocodes to 05-037-1900, so a person that
-- previously had distinct city tax records for any two or all three of the above
-- geocodes would now have multiple tax records for geocode 05-037-1900, each
-- with a different city_tax_rule_id.


-- Bug 3319878 -- Changed the query  to  reduce the cost  of the query
 CURSOR dup_city_tax_rows is
 select distinct pect1.assignment_id, pect1.jurisdiction_code
       from pay_us_emp_city_tax_rules_f pect1,
            pay_us_emp_city_tax_rules_f pect2
      where pect1.assignment_id = pect2.assignment_id
        and pect1.jurisdiction_code = pect2.jurisdiction_code
        and pect1.emp_city_tax_rule_id < pect2.emp_city_tax_rule_id
        and pect1.assignment_id between P_ASSIGN_START and P_ASSIGN_END ;

/* select distinct pect1.assignment_id, pect1.jurisdiction_code
      from pay_us_emp_city_tax_rules_f pect1
      where pect1.assignment_id between P_ASSIGN_START and P_ASSIGN_END
        and pect1.emp_city_tax_rule_id <
                (select pect2.emp_city_tax_rule_id
                  from pay_us_emp_city_tax_rules_f pect2
                  where pect1.assignment_id = pect2.assignment_id
                    and pect1.jurisdiction_code = pect2.jurisdiction_code
                );
*/

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.del_dup_city_tax_recs');

    IF G_MODE = 'UPGRADE' THEN

      FOR dup_rec IN dup_city_tax_rows

        LOOP

hr_utility.trace('Deleting dups for Assign ID: ' || to_char(dup_rec.assignment_id) ||
                 ' Geocode: ' || dup_rec.jurisdiction_code);

          DELETE FROM pay_us_emp_city_tax_rules_f pecto
           WHERE pecto.rowid < (SELECT max(pecti.rowid)
                                  FROM pay_us_emp_city_tax_rules_f pecti
                                 WHERE pecti.assignment_id = pecto.assignment_id
                                   AND pecti.assignment_id = dup_rec.assignment_id
                                   AND pecti.jurisdiction_code = pecto.jurisdiction_code
                                   AND pecti.jurisdiction_code = dup_rec.jurisdiction_code
                                   AND pecti.emp_city_tax_rule_id <> pecto.emp_city_tax_rule_id)
            AND pecto.assignment_id = dup_rec.assignment_id;

        END LOOP;

    END IF;

  END del_dup_city_tax_recs;

-- This procedure will update the run results for a particular assignment action id and
-- a particulare run result id.
-- NOTE  where we have the cursor in before both write messages
-- this is because if we want to run in debug mode and the type is not SU and US the
-- sql rowcount wont work because we are bypassing the update.

PROCEDURE run_results(p_proc_type     IN VARCHAR2,
	  	     p_person_id     IN NUMBER,
 		     p_assign_id     IN NUMBER,
		     p_assign_act_id IN NUMBER,
		     p_run_result_id IN NUMBER,
             p_old_juri_code IN VARCHAR2,
             p_new_juri_code IN VARCHAR2)


IS

--
--Per bug 2996546 changed the where clause in
--cursor ele_run_result_val for piv.legislation_code = 'US'
--to use the function IS_US_OR_CA_LEGISLATION and compare
--input value id stored in pl/sql table to improve performance
--

cursor ele_run_result_val(p_new_juri_code VARCHAR2, p_run_result_id VARCHAR2, p_assign_act_id NUMBER,p_assign_id NUMBER)
IS       select distinct 'Y'
FROM     pay_run_result_values prv
WHERE    prv.result_value = p_new_juri_code
AND      prv.run_result_id = p_run_result_id
AND      EXISTS (SELECT 0
         FROM   pay_input_values_f piv
         WHERE  piv.input_value_id = prv.input_value_id
         AND    (piv.name = 'Jurisdiction' OR
                 piv.name = 'jd_rs' OR
                 piv.name = 'jd_wk')
--       AND    piv.legislation_code = 'US')
         AND    IS_US_OR_CA_LEGISLATION(piv.input_value_id) = piv.input_value_id )
AND      NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
		     where pugu.assignment_id = p_assign_id
                       and pugu.table_value_id = prv.run_result_id
                       and pugu.old_juri_code = p_old_juri_code
                       and pugu.table_name = 'PAY_RUN_RESULT_VALUES'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);


cursor ele_run_results(p_new_juri_code VARCHAR2, p_old_juri_code VARCHAR2, p_run_result_id VARCHAR2,
		       p_assign_act_id NUMBER)
IS	 select distinct 'Y'
FROM	 pay_run_results prr
WHERE    prr.jurisdiction_code = p_new_juri_code
AND      prr.run_result_id = p_run_result_id
AND      prr.assignment_action_id = p_assign_act_id
AND      NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                     where pugu.assignment_id = p_assign_id
                       and pugu.table_value_id = prr.run_result_id
                       and pugu.old_juri_code = p_old_juri_code
                       and pugu.table_name = 'PAY_RUN_RESULTS'
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);


l_flag varchar2(2);

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.run_results');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of run result values for assignment_action_id: '||to_char(p_assign_act_id));

--
--Per bug 2996546 changed the where clause in
--in the update of pay_run_result_values
--for piv.legislation_code = 'US'
--to use the function IS_US_OR_CA_LEGISLATION and compare
--input value id stored in pl/sql table to improve performance
--


	IF G_MODE = 'UPGRADE' THEN

	UPDATE pay_run_result_values prv
        SET    prv.result_value = p_new_juri_code
        WHERE  prv.run_result_id = p_run_result_id
        AND    prv.result_value = p_old_juri_code
        AND    EXISTS (SELECT 0
                       FROM   pay_input_values_f piv
                       WHERE  piv.input_value_id = prv.input_value_id
                       AND    (piv.name = 'Jurisdiction' OR
                               piv.name = 'jd_rs' OR
                               piv.name = 'jd_wk')
--                     AND    piv.legislation_code = 'US');
                       AND    IS_US_OR_CA_LEGISLATION(piv.input_value_id) = piv.input_value_id );

	END IF;
-- Write a message to the table to be later spooled to a report
-- only if a row was updated

		/*IF SQL%ROWCOUNT > 0 THEN 6864396 */

	           OPEN ele_run_result_val(p_new_juri_code, p_run_result_id, p_assign_act_id, p_assign_id);
                   FETCH ele_run_result_val INTO l_flag;

                   IF ele_run_result_val%FOUND THEN


                    write_message(
			     p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
			     p_location       => 'PAY_RUN_RESULT_VALUES',
 			     p_id	      => p_run_result_id);

	           CLOSE ele_run_result_val;

		   END IF;

		/*END IF;*/
hr_utility.trace('After update of run result values for assignment_action_id: '||to_char(p_assign_act_id));

ELSE

-- Write a message to the table to be later spooled to a report
	OPEN ele_run_result_val(p_new_juri_code, p_run_result_id, p_assign_act_id, p_assign_id);
	FETCH ele_run_result_val INTO l_flag;

	    IF ele_run_result_val%FOUND THEN

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_RUN_RESULT_VALUES',
                             p_id             => p_run_result_id);

	    END IF;

	CLOSE ele_run_result_val;

END IF;


IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of run results for assignment_action_id: '||to_char(p_assign_act_id));

	IF G_MODE = 'UPGRADE' THEN

        UPDATE pay_run_results
        SET    jurisdiction_code = p_new_juri_code
        WHERE  jurisdiction_code = p_old_juri_code
        AND    run_result_id = p_run_result_id
        AND    assignment_action_id = p_assign_act_id;

	END IF;

-- Write a message to the table to be later spooled to a report

	/*IF SQL%ROWCOUNT > 0 THEN 6864396 */

                OPEN ele_run_results(p_new_juri_code, p_old_juri_code, p_run_result_id, p_assign_act_id);
                FETCH ele_run_results INTO l_flag;

                IF ele_run_results%FOUND THEN

		   write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_RUN_RESULTS',
                             p_id             => p_run_result_id);

                CLOSE ele_run_results;

		END IF;

	/*END IF;*/

ELSE

	OPEN ele_run_results(p_new_juri_code, p_old_juri_code, p_run_result_id, p_assign_act_id);
 	FETCH ele_run_results INTO l_flag;

		IF ele_run_results%FOUND THEN

			write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_RUN_RESULTS',
                             p_id             => p_run_result_id);

		END IF;

        CLOSE ele_run_results;
END IF;


hr_utility.trace('After update of run results for assignment_action_id: '||to_char(p_assign_act_id));

hr_utility.trace('Exiting pay_us_geo_upd_pkg.run_results');

END run_results;
--
--
--Per bug 2996546
-- This procedure, PROCEDURE pay_action_contexts, will update the context values
--based on assignment_action_id
--
--
PROCEDURE pay_action_contexts
                    (p_proc_type       IN VARCHAR2,
	  	     p_person_id       IN NUMBER,
 		     p_assign_id       IN NUMBER,
		     p_assign_act_id   IN NUMBER,
		     p_context_id      IN NUMBER,
                     p_old_juri_code   IN VARCHAR2,
                     p_new_juri_code   IN VARCHAR2)
IS

CURSOR pac_inside_cur(p_assign_act_id number, p_assign_id number,
                      p_context_id  number, p_old_juri_code varchar2)
IS     select 'Y'
FROM   pay_action_contexts
WHERE  assignment_action_id = p_assign_act_id
AND    assignment_id        = p_assign_id
AND    context_id           = p_context_id
AND    context_value        = p_old_juri_code ;

l_pac_inside_exist varchar2(2);

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.pay_action_contexts');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of pay_action_contexts for assignment id: '||to_char(p_assign_id));

        IF G_MODE = 'UPGRADE' THEN

           UPDATE pay_action_contexts
           SET    context_value = p_new_juri_code
           WHERE  context_value = p_old_juri_code
           AND    assignment_action_id = p_assign_act_id
           AND    context_id  = p_context_id ;
        END IF;

-- Write a message to the table to be later spooled to a report

	/*	IF SQL%ROWCOUNT > 0 THEN 6864396 */

		 OPEN pac_inside_cur(p_assign_act_id , p_assign_id,
                               p_context_id, p_old_juri_code ) ;
		          FETCH pac_inside_cur into l_pac_inside_exist;
      			  IF pac_inside_cur%FOUND THEN
                               write_message(
                                      p_proc_type      => p_proc_type,
                                      p_person_id      => p_person_id,
                                      p_assign_id      => p_assign_id,
                                      p_old_juri_code  => p_old_juri_code,
                                      p_new_juri_code  => p_new_juri_code,
                                      p_location       => 'PAY_ACTION_CONTEXTS',
                                      p_id             => p_assign_id);

			   END IF;
                           CLOSE pac_inside_cur;
		/*END IF ;*/
ELSE

-- Write a message to the table to be later spooled to a report

                       	OPEN pac_inside_cur(p_assign_act_id, p_assign_id ,
                                             p_context_id , p_old_juri_code ) ;
		          FETCH pac_inside_cur into l_pac_inside_exist;
      			  IF pac_inside_cur%FOUND THEN
                               write_message(
                                      p_proc_type      => p_proc_type,
                                      p_person_id      => p_person_id,
                                      p_assign_id      => p_assign_id,
                                      p_old_juri_code  => p_old_juri_code,
                                      p_new_juri_code  => p_new_juri_code,
                                      p_location       => 'PAY_ACTION_CONTEXTS',
                                      p_id             => p_assign_id);

			   END IF;
                           CLOSE pac_inside_cur;

END IF;

END pay_action_contexts;
---
---
---

-- This procedure will update the archive item contexts based on assignment_action_id
-- We do not do a mass update on the contexts here because we want to be certain that
-- the geocodes updated have a corresponding tax record for the assignment.
-- Not every old juri code will have an archived item against it for that particular
-- assignment action.  But we still have to check to make sure.

PROCEDURE archive_item_contexts (p_proc_type    IN VARCHAR2,
  			  	p_person_id     IN NUMBER,
			 	p_assign_id     IN NUMBER,
			  	p_archive_item_id IN NUMBER,
				p_context_id 	IN NUMBER,
                                p_old_juri_code IN VARCHAR2,
                                p_new_juri_code IN VARCHAR2)

IS

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.archive_item_contexts');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of archive item contexts for assignment_id: '||to_char(p_assign_id));

	IF G_MODE = 'UPGRADE' THEN

        UPDATE ff_archive_item_contexts ffaic
        SET    ffaic.context = p_new_juri_code
        WHERE  ffaic.context = p_old_juri_code
        AND    ffaic.context_id = p_context_id
        AND    ffaic.archive_item_id = p_archive_item_id;

	END IF;

hr_utility.trace('After update of archive item contexts for assignment_id: '||to_char(p_assign_id));

-- Write a message to the table to be later spooled to a report

                write_message(
			     p_proc_type => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'FF_ARCHIVE_ITEM_CONTEXTS',
			     p_id	      => p_archive_item_id);


ELSE

-- Write a message to the table to be later spooled to a report

                write_message(
                             p_proc_type => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'FF_ARCHIVE_ITEM_CONTEXTS',
                             p_id             => p_archive_item_id);

END IF;

hr_utility.trace('Exiting pay_us_geo_upd_pkg.archive_item_contexts');



END archive_item_contexts;


-- This procedure will upgrade the element entry geocodes.

PROCEDURE element_entries(
                        p_proc_type 	 IN VARCHAR2,
			p_person_id 	 IN NUMBER,
			p_assign_id 	 IN NUMBER,
                        p_input_value_id IN NUMBER,
                        p_ele_ent_id     IN NUMBER,
                        p_old_juri_code  IN VARCHAR2,
                        p_new_juri_code  IN VARCHAR2)


IS

BEGIN
hr_utility.trace('Entering pay_us_geo_upd_pkg.element_entries');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of element entry values for assignment_id: '||to_char(p_assign_id));

	IF G_MODE = 'UPGRADE' THEN

        UPDATE pay_element_entry_values_f
        SET    screen_entry_value = p_new_juri_code
        WHERE  screen_entry_value = p_old_juri_code
        AND    input_value_id+0 = p_input_value_id
        AND    element_entry_id = p_ele_ent_id;

	END IF;
hr_utility.trace('After update of element entry values for assignment_id: '||to_char(p_assign_id));

-- Write a message to the table to be later spooled to a report

                write_message(
			     p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_ELEMENT_ENTRY_VALUES_F',
 			     p_id	      => p_ele_ent_id);

ELSE

-- Write a message to the table to be later spooled to a report

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_ELEMENT_ENTRY_VALUES_F',
                             p_id             => p_ele_ent_id);

END IF;

hr_utility.trace('Exiting pay_us_geo_upd_pkg.element_entries');



END element_entries;


-- This procedure will upgrade the latest balance contexts.

PROCEDURE balance_contexts(p_proc_type      IN VARCHAR2,
                          p_person_id      IN NUMBER,
                          p_assign_id      IN NUMBER,
                          p_assign_act_id  IN NUMBER,
                          p_context_id     IN NUMBER,
		          p_lat_bal_id	   IN NUMBER,
                          p_old_juri_code  IN VARCHAR2,
                          p_new_juri_code  IN VARCHAR2)


IS

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.balance_contexts');

IF ((p_proc_type <> 'SU' and p_proc_type <> 'US') and p_api_mode = 'N') THEN

hr_utility.trace('Before update of latest balances context for assignment_action_id: '||to_char(p_assign_act_id));

	IF G_MODE = 'UPGRADE' THEN

        UPDATE pay_balance_context_values
        SET    value = p_new_juri_code
        WHERE  value = p_old_juri_code
        AND    context_id = p_context_id
        AND    latest_balance_id = p_lat_bal_id;

	END IF;
-- Write a message to the table to be later spooled to a report

                write_message(
			     p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_BALANCE_CONTEXT_VALUES',
			     p_id	      => p_lat_bal_id);

ELSE

-- Write a message to the table to be later spooled to a report

                write_message(
                             p_proc_type      => p_proc_type,
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => p_old_juri_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_BALANCE_CONTEXT_VALUES',
                             p_id             => p_lat_bal_id);

END IF;

hr_utility.trace('After update of latest balances context for assignment_action_id: '||to_char(p_assign_act_id));


hr_utility.trace('Exiting pay_us_geo_upd_pkg.balance_contexts');

END balance_contexts;


--  This procedure will take out duplicate VERTEX element entries and add the percentages
--  of the previously duplicated element entries togethor
--  This used to be script pydeldup.sql earlier

PROCEDURE duplicate_vertex_ee(p_assignment_id IN NUMBER)

IS

-- This cursor will get us the element entries of the assignments processed
 cursor csr_get_dup (p_assignment number) is
 select pev.screen_entry_value sev, pev.element_entry_id eei
 from pay_element_entry_values_f pev,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_links_f   pel,
     pay_element_entries_f pee
 where pee.assignment_id = p_assignment
 and   pel.element_link_id = pee.element_link_id
 and   pet.element_type_id = pel.element_type_id
 and   pet.element_name    = 'VERTEX'
 and   pev.element_entry_id = pee.element_entry_id
 and   pev.screen_entry_value is not null
 and   piv.input_value_id = pev.input_value_id+0
 and   piv.element_type_id = pet.element_type_id
 and   piv.name = 'Jurisdiction'
 and   piv.legislation_code = 'US'
 and   pet.legislation_code = 'US'
 order by 1,2;

 cursor csr_get_percentage (p_element_entry_id NUMBER) is
 select /*Bug 7592909*/distinct pev.screen_entry_value , pev.effective_start_date,
        pev.effective_end_date
 from pay_element_entry_values_f pev,
     pay_input_values_f    piv,
     pay_element_types_f   pet,
     pay_element_links_f   pel,
     pay_element_entries_f pef
 where pef.element_entry_id = p_element_entry_id
 and   pel.element_link_id = pef.element_link_id
 and   pet.element_type_id = pel.element_type_id
 and   pet.element_name    = 'VERTEX'
 and   pev.element_entry_id = pef.element_entry_id
 and   pev.screen_entry_value is not null
 and   piv.input_value_id = pev.input_value_id+0
 and   piv.element_type_id = pet.element_type_id
 and   piv.name = 'Percentage'
 and   piv.legislation_code = 'US'
 and   pet.legislation_code = 'US';

 l_prev_screen pay_element_entry_values_f.screen_entry_value%TYPE;
 l_prev_eleid  pay_element_entry_values_f.element_entry_id%TYPE;
 l_percent  pay_element_entry_values_f.screen_entry_value%TYPE;
 l_effective_start_date pay_element_entry_values_f.effective_start_date%TYPE;
 l_effective_end_date pay_element_entry_values_f.effective_end_date%TYPE;

 BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.duplicate_vertex_ee');

      l_prev_screen := null;
      l_prev_eleid := null;

      for j in csr_get_dup(p_assignment_id) loop

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 1);

          if j.sev = l_prev_screen and j.eei <> l_prev_eleid then
            hr_utility.trace('Element Entry Id : '|| to_char(j.eei)
                        ||' is a duplicate of : ' || to_char(l_prev_eleid)
                        ||' for assignment_id : ' || to_char(p_assignment_id));

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 2);

            /* get the percentages for the record to be deleted */
            open csr_get_percentage(j.eei);
            loop

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 3);

               /* Get the %age for each datetracked record */

               fetch csr_get_percentage into l_percent,
                                             l_effective_start_date,
                                             l_effective_end_date;
                     exit when csr_get_percentage%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 4);

               /* Add the %age of the current element entry to the earlier
                  entry */

	IF G_MODE = 'UPGRADE' THEN

hr_utility.trace('The previous element entry id is:  '||to_char(l_prev_eleid));

               update pay_element_entry_values_f pev
               set pev.screen_entry_value = pev.screen_entry_value + l_percent
               where pev.element_entry_id = l_prev_eleid
               and   pev.screen_entry_value is not null
               and   pev.input_value_id = (select distinct piv.input_value_id
                                           from pay_input_values_f piv,
                                                pay_element_types_f pet,
                                                pay_element_links_f pel,
                                                pay_element_entries_f pef
                                           where pef.element_entry_id =
                                                     l_prev_eleid
                                           and   pel.element_link_id =
                                                     pef.element_link_id
                                           and   pet.element_type_id =
                                                     pel.element_type_id
                                           and   pet.element_name = 'VERTEX'
                                           and   piv.element_type_id =
                                                     pet.element_type_id
                                           and   piv.name = 'Percentage'
					   and   piv.legislation_code = 'US'
					   and   pet.legislation_code = 'US')
					   /*Bug 7592909*/
             and pev.effective_start_date=l_effective_start_date
             and pev.effective_end_date=l_effective_end_date;

	END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 5);

            end loop;
            close csr_get_percentage;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 6);

            /* Now delete the current entry */

            delete pay_element_entries_f
            where element_entry_id = j.eei
            and   assignment_id    = p_assignment_id;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 7);

          else

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 8);

            l_prev_screen := j.sev;
            l_prev_eleid  := j.eei;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 9);

          end if;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 10);

      end loop;

hr_utility.set_location('pay_us_geo_upd_pkg.duplicate_vertex_ee', 11);

hr_utility.trace('Exiting pay_us_geo_upd_pkg.duplicate_vertex_ee');

end duplicate_vertex_ee;


-- This procedure will create element entries for assignments that have geocodes
-- which have split from the upgrade.

PROCEDURE insert_ele_entries
                    (p_proc_type      in varchar2,
                     p_assign_id      in number,
                     p_person_id      in number,
                     p_new_juri_code  in varchar2,
                     p_old_juri_code  in varchar2)

IS

-- Finds out if County Tax Record exists for this ASSIGNMENT_ID
   cursor c_county_rec (p_assignment_id        in number,
                        p_state_code           in varchar2,
                        p_county_code          in varchar2) is
     select business_group_id
       from pay_us_emp_county_tax_rules_f pecot
      where pecot.assignment_id = p_assignment_id
        and pecot.state_code = p_state_code
        and pecot.county_code = p_county_code;

-- Finds out if City Tax Record exists for this ASSIGNMENT_ID
   cursor c_tax_rec (p_assignment_id        in number,
                     p_state_code           in varchar2,
                     p_county_code          in varchar2,
                     p_city_code            in varchar2) is
     select business_group_id
       from pay_us_emp_city_tax_rules_f pect
      where pect.assignment_id = p_assignment_id
        and pect.state_code = p_state_code
        and pect.county_code = p_county_code
        and pect.city_code = p_city_code;

-- Gets the date when the eligiblity criteria was met for this assignment.
  cursor c_elig_date (p_assignment_id in number) is
    select  min(peft.effective_start_date),
            max(peft.effective_end_date),
	    peft.business_group_id
      from pay_us_emp_city_tax_rules_f peft
     where peft.assignment_id = p_assignment_id
     group by peft.business_group_id;

  ld_eff_start_date date;
  ld_eff_end_date   date;
  ln_state_code     pay_us_emp_state_tax_rules_f.state_code%TYPE;
  ln_county_code    pay_us_emp_county_tax_rules_f.county_code%TYPE;
  ln_city_code      pay_us_emp_city_tax_rules_f.city_code%TYPE;
  ln_old_city_code  pay_us_modified_geocodes.old_city_code%TYPE;

  ln_business_group_id    number;
  ln_check		  number;
  ln_emp_city_tax_rule_id number;

  lc_exists      number;
  lc_insert_rec  varchar2(1);
  l_profile_value  varchar2(1):='N';
BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.insert_ele_entries');

  lc_insert_rec  := 'N';

  IF ((p_proc_type = 'SU' or p_proc_type = 'US') and p_api_mode = 'N') THEN

    ln_state_code  := substr(p_new_juri_code,1,2);
    ln_county_code := substr(p_new_juri_code,4,3);
    ln_city_code   := substr(p_new_juri_code,8);
    ln_old_city_code := substr(p_old_juri_code,8);

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',1);

    open c_county_rec(p_assign_id,
                      ln_state_code,
                      ln_county_code);

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',2);

    fetch c_county_rec into lc_exists;
    if c_county_rec%notfound then

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',3);

-- Call write message to store information that their is no county record for this assignment
			  write_message(
                             p_proc_type      => 'MISSING_COUNTY_RECORDS',
                             p_person_id      => p_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => ln_state_code||'-'||ln_county_code,
                             p_new_juri_code  => p_new_juri_code,
                             p_location       => 'PAY_US_EMP_COUNTY_TAX_RULES_F',
                             p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',4);


   ELSE

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',5);

    open c_tax_rec(p_assign_id,
                   ln_state_code,
                   ln_county_code,
                   ln_old_city_code);

    fetch c_tax_rec into ln_check;

  hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',6);

    if c_tax_rec%found then  -- changed notfound to found
       close c_tax_rec;
       open c_tax_rec(p_assign_id,
                      ln_state_code,
                      ln_county_code,
                      ln_city_code); -- Check with new city code.
       fetch c_tax_rec into ln_check;
       if c_tax_rec%notfound then
          lc_insert_rec := 'Y';
       end if;
    end if;

  hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',7);

    close c_tax_rec;

    if lc_insert_rec = 'Y' then

  hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',8);

       open c_elig_date(p_assign_id);

       fetch c_elig_date into ld_eff_start_date, ld_eff_end_date, ln_business_group_id;

       if c_elig_date%notfound then
         hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',9);
       --Exiting if there are no city Tax Records.
       end if;

  hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',10);
       close c_elig_date;

  hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',11);

  hr_utility.trace('The business group id is:  '||to_char(ln_business_group_id));

      IF G_MODE = 'UPGRADE' THEN

            /* changes for 7240905*/
       if(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'))<> 'Y' then
              fnd_profile.put('HR_CROSS_BUSINESS_GROUP','Y');
              l_profile_value := 'Y';
             hr_utility.trace('modifed the profile to'||to_char(fnd_profile.value('HR_CROSS_BUSINESS_GROUP')));
        end if;

            ln_emp_city_tax_rule_id :=
               pay_us_emp_dt_tax_rules.insert_def_city_rec(p_assign_id,
                                                    ld_eff_start_date,
                                                    ld_eff_end_date,
                                                    ln_state_code,
                                                    ln_county_code,
                                                    ln_city_code,
                                                    ln_business_group_id,
                                                    0);

                /* changes for 7240905*/
      if(l_profile_value ='Y') then
         fnd_profile.put('HR_CROSS_BUSINESS_GROUP','N');
         hr_utility.trace('modifed the profile to'||to_char(fnd_profile.value('HR_CROSS_BUSINESS_GROUP')));
      end if;

   hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',12);

-- Write to the table with the new city information

 	        write_message(
      	       	 p_proc_type      => 'NEW_CITY_RECORDS',
       		        p_person_id      => p_person_id,
       		        p_assign_id      => p_assign_id,
    		        p_old_juri_code  => null,
                    p_new_juri_code  => p_new_juri_code,
     		        p_location       => 'PAY_US_EMP_CITY_TAX_RULES_F',
        			p_id             => ln_emp_city_tax_rule_id);

     else /* Modified for bug 6864396*/

       	      write_message(
      	       	 p_proc_type      => 'NEW_CITY_RECORDS',
       		        p_person_id      => p_person_id,
       		        p_assign_id      => p_assign_id,
    		        p_old_juri_code  => null,
                    p_new_juri_code  => p_new_juri_code,
     		        p_location       => 'PAY_US_EMP_CITY_TAX_RULES_F',
        			p_id             => null);

      END IF;

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',12);

/*
          pay_us_emp_dt_tax_rules.maintain_element_entry
                              (p_assignment_id        => p_assign_id,
                               p_effective_start_date => ld_eff_start_date,
                               p_effective_end_date   => ld_eff_end_date,
                               p_session_date         => ld_eff_start_date,
                               p_jurisdiction_code    => p_new_juri_code,
                               p_percentage_time      => 0,
                               p_mode                 => 'INSERT');
*/

-- Write to the table the new vertex information of the new vertex record

  	write_message(
                 p_proc_type      => 'NEW_VERTEX_RECORDS',
                 p_person_id      => p_person_id,
                 p_assign_id      => p_assign_id,
                 p_old_juri_code  => null,
                 p_new_juri_code  => p_new_juri_code,
                 p_location       => 'PAY_ELEMENT_ENTRIES_F',
                 p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',13);

   /* END IF;  County  6864396*/
  END IF;

   end if;

hr_utility.set_location('pay_us_geo_upd_pkg.insert_ele_entries',14);

ELSE -- p_proc_type != 'SU' and p_proc_type != 'US'

  	write_message(
                 p_proc_type      => 'ELE_ENTRY_INSERT_NOT_REQD',
                 p_person_id      => p_person_id,
                 p_assign_id      => p_assign_id,
                 p_old_juri_code  => null,
                 p_new_juri_code  => p_new_juri_code,
                 p_location       => 'PAY_ELEMENT_ENTRIES_F',
                 p_id             => null);

END IF;
END insert_ele_entries;


-- This procedure will check the percentage time in state for a particular jurisdiction
-- and make sure that percent time is not more than 100%

PROCEDURE check_time(p_assign_id IN NUMBER)

IS

--Retrieve all states for the assignments that have changed from per_assignments_f

  CURSOR state_cur(p_assign_id NUMBER) IS
    SELECT  pus.state_code,
            pus.state_name,
	    pusf.effective_start_date,
   	    pusf.effective_end_date
    FROM    pay_us_states pus,
            pay_us_emp_state_tax_rules_f pusf
    WHERE   pusf.assignment_id = p_assign_id
    AND     pusf.state_code = pus.state_abbrev
    AND     NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                       and pugu.process_type = 'PERCENTAGE_OVER_100'
		       and pugu.assignment_id = p_assign_id
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);



  state_rec   state_cur%ROWTYPE;

--Sum the percentage for all Vertex entries falling within the state
--jurisdiction for the effective dates of the assignment.
  CURSOR sum_cur(p_assign_id NUMBER, start_date DATE,
                 end_date DATE, state_code CHAR) IS
    SELECT sum(nvl(to_number(pev2.screen_entry_value),0))
    FROM   pay_input_values_f piv2,
           pay_element_entry_values_f pev2,
           pay_input_values_f piv1,
           pay_element_entry_values_f pev1,
           pay_element_types_f pet,
           pay_element_links_f pel,
           pay_element_entries_f pef
    WHERE  pef.assignment_id = p_assign_id
     AND   pef.creator_type = 'UT'
     AND   pef.element_link_id = pel.element_link_id
     AND   pel.element_type_id = pet.element_type_id
     AND   pet.element_name = 'VERTEX'
     AND   (
            (start_date >= pef.effective_start_date AND
             end_date <= pef.effective_end_date)
        OR  (start_date = pef.effective_end_date)
        OR  (end_date = pef.effective_start_date)
           )
     AND   (pef.element_entry_id = pev1.element_entry_id
        AND pef.effective_start_date = pev1.effective_start_date
        AND pef.effective_end_date = pev1.effective_end_date
        AND state_code = substr(pev1.screen_entry_value,1,2)
        AND pev1.input_value_id = piv1.input_value_id
        AND piv1.name = 'Jurisdiction'
	AND piv1.legislation_code = 'US')
     AND   (pev2.element_entry_id = pev1.element_entry_id
        AND pev2.effective_start_date = pev1.effective_start_date
        AND pev2.effective_end_date = pev1.effective_end_date
        AND pev2.screen_entry_value is not null
        AND piv2.input_value_id = pev2.input_value_id
        AND piv2.name = 'Percentage'
        AND piv2.legislation_code = 'US');

  sum_rec   sum_cur%ROWTYPE;

  l_person_id  per_people_f.person_id%TYPE;
  tot_percentage NUMBER;
  percentage NUMBER;

BEGIN

hr_utility.trace('Entering pay_us_geo_upd_pkg.check_time');

    tot_percentage := 0;

hr_utility.set_location('pay_us_geo_upd_pkg.check_time',1);

-- Get each state for the assignment.
    FOR state_rec IN state_cur(p_assign_id) LOOP

hr_utility.set_location('pay_us_geo_upd_pkg.check_time',2);

-- Get the percentage of time worked in that state.

      OPEN sum_cur(p_assign_id, state_rec.effective_start_date,
                   state_rec.effective_end_date, state_rec.state_code);
      FETCH sum_cur INTO percentage;
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',3);

        IF sum_cur%FOUND THEN
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',4);

          tot_percentage := tot_percentage + percentage;
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',5);

        END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',6);

      CLOSE sum_cur;
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',7);

    END LOOP; -- state_cur
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',8);

    IF (tot_percentage > 100) THEN

hr_utility.set_location('pay_us_geo_upd_pkg.check_time',9);

      SELECT ppf.person_id
      INTO   l_person_id
      FROM   per_all_people_f ppf,
  	     per_all_assignments_f paf
      WHERE  ppf.person_id = paf.person_id
      AND    paf.assignment_id = p_assign_id
      AND    ppf.effective_start_date = (SELECT max(ppf2.effective_start_date)
                                         FROM   per_all_people_f ppf2
                                         WHERE  ppf2.person_id = ppf.person_id);


 		write_message(
                             p_proc_type      => 'PERCENTAGE_OVER_100',
			     p_person_id      => l_person_id,
                             p_assign_id      => p_assign_id,
                             p_old_juri_code  => null,
                             p_new_juri_code  => null,
                             p_location       => 'PAY_ELEMENT_ENTRY_VALUES_F',
                             p_id             => null);


hr_utility.set_location('pay_us_geo_upd_pkg.check_time',10);

    END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.check_time',11);

-- Taking out the exception here because if the procedure errors let it go to the calling block and
-- use that exception handler as that errors to the savepoint and continues with the assignment.

/*
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace(SQLCODE||SQLERRM||'Program error contact support');
    hr_utility.raise_error;
*/
END check_time;




-- THE BEGINNING OF THE MAIN PROCEDURE:  UPGRADE_GEOCODES

BEGIN

-- Initialize the global variables here

g_geo_phase_id := null;
g_mode 	       := null;
g_process_type := null;

-- hr_utility.trace_on(null,'oracle');

hr_utility.trace('Entering pay_us_geo_upd_pkg.upgrade_geocodes');

-- Set the global phase id for the geo update

g_geo_phase_id := p_geo_phase_id;

hr_utility.trace('The pay patch status id for this upgrade is:   '||to_char(g_geo_phase_id));

-- Set the global mode for the upgrade

g_mode := p_mode;

hr_utility.trace('The mode for this upgrade is:   '||g_mode);



--Check if pay_us_asg_reporting table exists as some clients may
--not have this table on their database.
  SELECT count(*)
  INTO table_exist
  FROM  cat
  WHERE table_name = tab_name;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',1);

--Bug 2996546 call procedure load_input_values
load_input_values;
--hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',230);


  OPEN main_driving_cur(P_ASSIGN_START, P_ASSIGN_END, P_CITY_NAME, P_API_MODE);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',5);

  LOOP

BEGIN

  FETCH main_driving_cur into main_old_juri_code, main_assign_id, main_new_juri_code, main_person_id,
        main_new_city_code, main_proc_type, main_city_tax_rule_id;
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',10);

  EXIT when main_driving_cur%NOTFOUND;


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',15);


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',20);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',25);

-- Set the global variable for g_process_type

g_process_type := main_proc_type;

hr_utility.trace('The process type for this pair of geocodes is:  '||g_process_type);
hr_utility.trace('The main assignment id is:  '||to_char(main_assign_id));
hr_utility.trace('The main old juri code id is:  '||main_old_juri_code);
hr_utility.trace('The main new juri code id is:  '||main_new_juri_code);
hr_utility.trace('The main person id is:  '||to_char(main_person_id));
hr_utility.trace('The city name is:    '||p_city_name);

-- We first insert a row into PAY_US_GEO_UPDATE to state that we are processing this assignment
-- Our concern is how do we track an assignment that has errored.  So we will start by creating
-- a row for the assignment with a p_status of 'U'.  Then at the end of the loop we will
-- change the p_status to 'C' before commiting

-- If a person has errored and this upgrade is rerun we must not re-write the message

l_proc_stage := 'START';

  OPEN chk_assign_error_cur(main_assign_id, main_new_juri_code, main_old_juri_code);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',30);

  FETCH chk_assign_error_cur INTO l_chk_assign_error;
  IF (chk_assign_error_cur%FOUND or p_api_mode = 'Y') THEN
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',35);

  	NULL;  /* We do nothing here because we want the assignment to re-processed
              but do not create another row in the pay_us_geo_update table */

  ELSE
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',40);

-- We need to store a process type because the same geocode can have two records for different city names
-- Thus we would get two rows in PAY_US_GEO_UPDATE for the same assignment id.

		write_message(
                             p_proc_type      => main_proc_type,
                             p_person_id      => main_person_id,
                             p_assign_id      => main_assign_id,
                             p_old_juri_code  => main_old_juri_code,
                             p_new_juri_code  => main_new_juri_code,
                             p_location       => null,
                             p_id             => null,
			   				 p_status	      => 'P');
 hr_utility.set_location('before commit',1);
--   commit;

 END IF;

 CLOSE chk_assign_error_cur;
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',45);

-- Create element entries and a new city record for new jusrisdictions for the assignment.  We do this first
-- because we want to commit based on an assignment.

l_proc_stage := 'INSERT_ELEMENT_ENTRIES';


		insert_ele_entries (
                                      p_proc_type      =>  main_proc_type,
		                              p_assign_id      =>  main_assign_id,
                                      p_person_id      =>  main_person_id,
                                      p_new_juri_code  =>  main_new_juri_code,
                                      p_old_juri_code  =>  main_old_juri_code);


-- Here is the savepoint so if an assignment fails during the upgrade it will rollback to here and continue with the
-- next assignment.

SAVEPOINT GEO_UPDATE_SAVEPOINT;

--Update pay_us_asg_reporting table using dynamic sql. We
--must build and execute a new update statement each time.
--This used to point to non-dt w4 tables, changing.

  IF (table_exist <> '0') THEN
      l_text := 'UPDATE '||tab_name||
              ' SET jurisdiction_code = '''||main_new_juri_code||
              ''' WHERE  assignment_id = '''||to_char(main_assign_id)||
              ''' AND    jurisdiction_code = '''||main_old_juri_code||
              '''';
      sql_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(sql_cursor, l_text, dbms_sql.v7);
      ret := dbms_sql.execute(sql_cursor);
      dbms_sql.close_cursor(sql_cursor);
    END IF;


--Update element entry values

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',50);

      OPEN pev_cur(main_old_juri_code, main_assign_id);
      LOOP
      FETCH pev_cur INTO pev_rec;
      EXIT WHEN pev_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',55);

l_proc_stage := 'ELEMENT_ENTRIES';

 		    		           element_entries(
					   p_proc_type	    => main_proc_type,
					   p_person_id      => main_person_id,
			     		   p_assign_id      => main_assign_id,
                        		   p_input_value_id => pev_rec.input_value_id,
               	        		   p_ele_ent_id     => pev_rec.element_entry_id,
					   p_old_juri_code  => main_old_juri_code,
                     	                   p_new_juri_code  => main_new_juri_code);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',60);


      END LOOP;
      CLOSE pev_cur;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',65);


-- Conditionally Update run results and run result values
--Per bug 2996546 included another condition
--where clause in OR length(main_old_juri_code) = 2
--to include Canada legislation
--

      BEGIN

        SELECT 'Y'
          INTO lv_update_prr
          FROM dual
         WHERE EXISTS (SELECT 0
                         FROM  pay_us_city_tax_info_f
                        WHERE  jurisdiction_code = main_old_juri_code)
            OR EXISTS (SELECT 0
                         FROM  pay_us_city_tax_info_f
                        WHERE  jurisdiction_code = main_new_juri_code)
            OR length(main_old_juri_code) = 2 ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          lv_update_prr := 'N';

      END;

      IF lv_update_prr = 'Y' THEN

 -- Bug 3319878 -- Opening cursor

        OPEN paa_cur(main_assign_id);
        LOOP
        FETCH paa_cur INTO paa_rec;
        EXIT WHEN paa_cur%NOTFOUND;

	OPEN prr_cur(paa_rec,main_assign_id);
        LOOP
        FETCH prr_cur INTO prr_rec;
        EXIT WHEN prr_cur%NOTFOUND;

        hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',70);

        l_proc_stage := 'RUN_RESULTS';

        run_results(
		    p_proc_type		=> main_proc_type,
		    p_person_id		=> main_person_id,
		    p_assign_id		=> main_assign_id,
		    p_assign_act_id	=> prr_rec.assignment_action_id,
		    p_run_result_id	=> prr_rec.run_result_id,
		    p_old_juri_code	=> main_old_juri_code,
		    p_new_juri_code	=> main_new_juri_code);


        hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',75);
        END LOOP;
	CLOSE prr_cur;
        END LOOP;
       	CLOSE paa_cur;

      END IF;
--
--
--

--Per bug 2996546
-- Update pay_action_contexts . context value
--
--

OPEN pac_cur(main_assign_id, main_city_tax_rule_id);
        LOOP
        FETCH pac_cur INTO pac_rec;
        EXIT WHEN pac_cur%NOTFOUND;


        hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',240);

        l_proc_stage := 'PAY_ACTION_CONTEXTS';

        pay_action_contexts(
		    p_proc_type		=> main_proc_type,
		    p_person_id		=> main_person_id,
		    p_assign_id		=> main_assign_id,
		    p_assign_act_id	=> pac_rec.assignment_action_id,
		    p_context_id	=> pac_rec.context_id,
		    p_old_juri_code	=> main_old_juri_code,
		    p_new_juri_code	=> main_new_juri_code);


        hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',250);

        END LOOP;
 CLOSE pac_cur;

--
--

-- Update  ff archive item contexts


  OPEN fac_cur(main_assign_id, main_old_juri_code);
      LOOP
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',80);

      FETCH fac_cur INTO fac_rec;
      EXIT WHEN fac_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',85);

l_proc_stage := 'ARCHIVE_ITEM_CONTEXTS';

        	    archive_item_contexts(
				    p_proc_type		=> main_proc_type,
				    p_person_id		=> main_person_id,
				    p_assign_id		=> main_assign_id,
               	    p_archive_item_id  	=> fac_rec.archive_item_id,
				    p_context_id	=> fac_rec.context_id,
                    P_OLD_JURi_code 	=> main_old_juri_code,
                    p_new_juri_code 	=> main_new_juri_code);


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',90);

      END LOOP;
      CLOSE fac_cur;


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',95);


-- Update person balance context values.


      OPEN pbcv_cur(main_old_juri_code, main_assign_id, main_person_id);
      LOOP
      FETCH pbcv_cur INTO pbcv_rec;
      EXIT WHEN pbcv_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',100);

l_proc_stage := 'PERSON_BALANCE_CONTEXTS';

					balance_contexts(
					p_proc_type	 => main_proc_type,
					p_person_id	 => main_person_id,
					p_assign_id	 => main_assign_id,
					p_assign_act_id  => pbcv_rec.assignment_action_id,
    	                                p_context_id     => pbcv_rec.context_id ,
                                        p_lat_bal_id     => pbcv_rec.latest_balance_id,
                                        p_old_juri_code  => main_old_juri_code,
                                        p_new_juri_code  => main_new_juri_code);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',105);


      END LOOP;
      CLOSE pbcv_cur;

-- Update assignment balance context values.

      OPEN pacv_cur(main_old_juri_code, main_assign_id, main_person_id);
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',110);

      LOOP
      FETCH pacv_cur INTO pacv_rec;
      EXIT WHEN pacv_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',115);

l_proc_stage := 'ASSIGNMENT_BALANCE_CONTEXTS';

				        balance_contexts(
					p_proc_type      => main_proc_type,
                                        p_person_id      => main_person_id,
                                        p_assign_id	 => main_assign_id,
                                        p_assign_act_id  => pacv_rec.assignment_action_id,
                                        p_context_id     => pacv_rec.context_id ,
                                        p_lat_bal_id     => pacv_rec.latest_balance_id,
                                        p_old_juri_code  => main_old_juri_code,
                                        p_new_juri_code  => main_new_juri_code);


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',120);


      END LOOP;
      CLOSE pacv_cur;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',125);

-- Rosie Monge 10/17/2005
-- Update Pay_Latest_balances context values.

      OPEN plbcv_cur(main_old_juri_code, main_assign_id, main_person_id);
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',126 );
      LOOP
      FETCH plbcv_cur INTO plbcv_rec;

      EXIT WHEN plbcv_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',127);

l_proc_stage := 'PAY_LATEST_BALANCES_CONTEXT';

				        balance_contexts(
					p_proc_type      => main_proc_type,
                                        p_person_id      => main_person_id,
                                        p_assign_id	 => main_assign_id,
                                        p_assign_act_id  => plbcv_rec.assignment_action_id,
                                        p_context_id     => plbcv_rec.context_id ,
                                        p_lat_bal_id     => plbcv_rec.latest_balance_id,
                                        p_old_juri_code  => main_old_juri_code,
                                        p_new_juri_code  => main_new_juri_code);


hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',128);

      END LOOP;
      CLOSE plbcv_cur;
-- End Rosie Monge addition for bug 4602222

--Update the pay_balance_batch_lines table.

l_proc_stage := 'BALANCE_BATCH_LINES';

  			     balance_batch_lines(
			     p_proc_type     => main_proc_type,
                             p_person_id     => main_person_id,
                             p_assign_id     => main_assign_id,
                             p_old_juri_code => main_old_juri_code,
                             p_new_juri_code => main_new_juri_code);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',130);

---
---
---
--Per bug 2738574
--Update the pay_run_balances table.

l_proc_stage := 'PAY_RUN_BALANCES';

  			     pay_run_balances(
			     p_proc_type     => main_proc_type,
                             p_person_id     => main_person_id,
                             p_assign_id     => main_assign_id,
                             p_new_city_code => main_new_city_code,
                             p_old_juri_code => main_old_juri_code,
                             p_new_juri_code => main_new_juri_code);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',131);
---
---
---


-- Check for and delete any duplicate Vertex element entries
-- This can be caused by two geocodes combining.
-- We will then add the percentages togethor before deleting.

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',135);

l_proc_stage := 'DUPLICATE_VERTEX_EE';

			   duplicate_vertex_ee(main_assign_id);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',140);


--Update the pay_us_emp_city_tax_rules_f table.

OPEN city_rec_cur(main_new_juri_code, main_old_juri_code, main_assign_id, main_city_tax_rule_id);
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',145);

FETCH city_rec_cur INTO l_city_tax_exists;
CLOSE city_rec_cur;

l_proc_stage := 'CITY_TAX_RECORDS';

	IF l_city_tax_exists = 'Y' THEN
			   city_tax_records (
			   p_proc_type      => main_proc_type,
                           p_person_id      => main_person_id,
                           p_assign_id      => main_assign_id,
                           p_old_juri_code  => main_old_juri_code,
                           p_new_juri_code  => main_new_juri_code,
                           p_new_city_code  => main_new_city_code,
			   p_city_tax_record_id => main_city_tax_rule_id);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',150);

	END IF;




hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',155);


-- Now we check for assignments with more than 100% time in jurisdiction

l_proc_stage := 'CHECK_TIME';

		check_time(p_assign_id =>  main_assign_id);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',160);

-- Now we update the SU and US cases to a status of 'A' for assignments that need to be updated
-- via the API. If the cursor is found then we will update the status to 'A', only if the assignment
-- was not updated because the same jurisdiction also had another type.

l_proc_stage := 'SET API';

	 	OPEN chk_assign_api_cur(main_assign_id, main_new_juri_code, main_old_juri_code);
		hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',165);

		FETCH chk_assign_api_cur into l_chk_assign_api;
		hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',170);

		CLOSE chk_assign_api_cur;

	    IF (l_chk_assign_api = 'Y' and p_api_mode = 'N')  THEN

		hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',175);

		UPDATE PAY_US_GEO_UPDATE
        SET status = 'A', description = null
        WHERE assignment_id = main_assign_id
        AND old_juri_code = main_old_juri_code
        AND new_juri_code = main_new_juri_code
        AND table_name is null
        AND table_value_id is null
        AND status = 'P'
        AND process_type = main_proc_type;

		ELSE
-- Now we update the assignment that has just processed to a status of 'C' in PAY_US_GEO_UPDATE

	hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',180);

l_proc_stage := 'END';

		UPDATE PAY_US_GEO_UPDATE
		SET status = 'C', description = null
		WHERE assignment_id = main_assign_id
		AND old_juri_code = main_old_juri_code
		AND new_juri_code = main_new_juri_code
 		AND table_name is null
		AND table_value_id is null
		AND status in ('P','A')
		AND process_type = main_proc_type;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',185);

	END IF;

 hr_utility.set_location('before commit',2);
-- 	commit;  /* We commit at this point so if it fails at any point let it rollback to the savepoint and continue */


hr_utility.trace('Exiting pay_us_geo_upd_pkg.upgrade_geocodes');


EXCEPTION
WHEN OTHERS THEN
	l_error_text := 'An error occurred in step:  '||l_proc_stage||'    The sql error message is:   '||SQLERRM|| '   The error code is:  '||to_char(SQLCODE);

    hr_utility.trace(to_char(SQLCODE)||SQLERRM||'Program error contact support');
    hr_utility.trace('Entered the main program exception handler');
    hr_utility.trace('The code failed at process type of:   '||l_proc_stage);

    fnd_file.put_line(fnd_file.log, 'Exception ' || l_proc_stage || ' Person id = ' || to_char(main_person_id));
    fnd_file.put_line(fnd_file.log, 'Exception ' || l_proc_stage || ' Assignment id = ' || to_char(main_assign_id));
    fnd_file.put_line(fnd_file.log, 'Exception ' || l_proc_stage || ' Old Jurisdiction Code = ' || main_old_juri_code);
    fnd_file.put_line(fnd_file.log, 'Exception ' || l_proc_stage || ' New Jurisdiction Code = ' || main_new_juri_code);
    fnd_file.put_line(fnd_file.log, 'sql error ' || sqlcode || ' - ' || substr(sqlerrm,1,80));

    rollback to GEO_UPDATE_SAVEPOINT;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geocodes',170);

		UPDATE PAY_US_GEO_UPDATE
		SET description = l_error_text
		WHERE assignment_id = main_assign_id
	    AND old_juri_code = main_old_juri_code
        AND new_juri_code = main_new_juri_code
        AND table_name is null
	    AND table_value_id is null
        AND old_juri_code = main_old_juri_code
        AND new_juri_code = main_new_juri_code
        AND status = 'P'
        AND process_type = main_proc_type;

-- Close all the cursors that are within the main loop, otherwise they will remain open.

	IF chk_assign_error_cur%ISOPEN THEN
	CLOSE chk_assign_error_cur;
	END IF;

	IF pev_cur%ISOPEN THEN
	CLOSE pev_cur;
	END IF;

	IF prr_cur%ISOPEN THEN
	CLOSE prr_cur;
	END IF;

	--Bug 3319878
        IF paa_cur%ISOPEN THEN
	CLOSE paa_cur;
	END IF;

	IF fac_cur%ISOPEN THEN
	CLOSE fac_cur;
	END IF;


	IF pbcv_cur%ISOPEN THEN
	CLOSE pbcv_cur;
	END IF;

	IF pacv_cur%ISOPEN THEN
	CLOSE pacv_cur;
	END IF;

	IF city_rec_cur%ISOPEN THEN
	CLOSE city_rec_cur;
	END IF;

	IF chk_assign_api_cur%ISOPEN THEN
	CLOSE chk_assign_api_cur;
	END IF;

hr_utility.set_location('before commit',3);
-- commit;

END;

END LOOP;

CLOSE main_driving_cur;

-- Remove duplicate city tax records created
-- by geocode updates for all assignment ids
-- in the range processed.

del_dup_city_tax_recs;

END upgrade_geocodes;

-- END OF THE MAIN UPGRADE GEOCODES PROCEDURE


-- This procedure is seperate from the above main upgrade_geocodes
-- This procedure will update all the taxability rules
-- By taking in a parameter of P_GEO_PHASE_ID we can determine if the taxability rules
-- have been upgraded already.
-- This procedure will only be run by one process, NOT MULTIPLE TIMES
-- This procedure taxes the place of pyrulupd.sql from previous versions

PROCEDURE  update_taxability_rules(P_GEO_PHASE_ID IN NUMBER,
                                   P_MODE         IN VARCHAR2,
                                   P_PATCH_NAME   IN VARCHAR2)

IS

--Retrieve all changed geocodes on pay_taxability_rules table.


--Bug 3319878 -- Changed the cursor query to  reduce cost.
--Bug 5042715 -- Added hints to  reduce cost.
CURSOR ptax_cur IS
    SELECT /*+index( pmod PAY_US_MODIFIED_GEOCODES_N2 ,
                     ptax PAY_TAXABILITY_RULES_UK)
              use_nl(pmod ptax)*/
	    distinct ptax.jurisdiction_code
    FROM    pay_us_modified_geocodes pmod,
            pay_taxability_rules ptax
    WHERE   ptax.jurisdiction_code = pmod.state_code||'-000-'||pmod.old_city_code
    AND     pmod.process_type in ('UP','RP')
    AND     pmod.patch_name = p_patch_name
    AND     substr(ptax.jurisdiction_code,8,4) <> '0000'
    AND     NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.table_name = 'PAY_TAXABILITY_RULES'
                       and pugu.new_juri_code = ptax.jurisdiction_code
                       and pugu.process_mode = g_mode
		       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id
		       and rownum <2);


  ptax_rec   ptax_cur%ROWTYPE;

--Per bug 2996546
--Added a cursor ptax_ca_cur to the procedure update_taxability_rules
--Retrieve all changed jurisdiction_code on pay_taxability_rules table.
--and update (for Canadian Legislation)
--

--Bug 3319878 -- Changed the query  to improve performance

CURSOR ptax_ca_cur IS
    SELECT  distinct ptax.jurisdiction_code
    FROM    pay_us_modified_geocodes pmod,
            pay_taxability_rules ptax
    WHERE   pmod.state_code  = 'CA'
    AND ptax.jurisdiction_code = pmod.county_code || '000-0000'
    AND     pmod.patch_name = p_patch_name
    AND     ptax.legislation_code = 'CA' ;




ptax_ca_rec ptax_ca_cur%ROWTYPE;



  jd_code    pay_taxability_rules.jurisdiction_code%TYPE;
  l_proc_type  pay_us_modified_geocodes.process_type%TYPE;
  l_error_message_text varchar2(240);
  l_count number;
BEGIN

g_geo_phase_id := p_geo_phase_id;
g_mode         := p_mode;

hr_utility.trace('Entering pay_us_geo_upd_pkg.update_taxability_rules');
hr_utility.trace('The phase id is:  '||to_char(g_geo_phase_id));

  FOR ptax_rec IN ptax_cur LOOP

hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',1);

   SELECT  pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code,
           process_type
   INTO    jd_code, l_proc_type
   FROM    pay_us_modified_geocodes pmod
   WHERE   pmod.state_code = substr(ptax_rec.jurisdiction_code,1,2)
   AND     pmod.old_city_code = substr(ptax_rec.jurisdiction_code,8,4)
   AND     pmod.process_type in ('UP','RP')
   AND     pmod.patch_name = p_patch_name
--city taxability rules don't carry a county-code so we have to pull the first
-- row in the case of a city that spans a county.
   and     rownum = 1;

hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',2);

select count(*) into l_count
from pay_taxability_rules ptax
where ptax.jurisdiction_code = substr(jd_code,1,2)||'-000-'||substr(jd_code,8,4);

IF l_count = 0 THEN

   IF G_MODE = 'UPGRADE' THEN

   UPDATE pay_taxability_rules ptax
   SET ptax.jurisdiction_code = substr(jd_code,1,2)||'-000-'||
                                substr(jd_code,8,4)
   WHERE  ptax.jurisdiction_code = ptax_rec.jurisdiction_code;

--  COMMIT;


   END IF;

END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',3);

-- write to the message table so that if this fails unexpectedly we can track which taxability
-- rules have been upgraded already.

			     write_message(
                             p_proc_type      => l_proc_type,
                             p_person_id      => null,
                             p_assign_id      => null,
                             p_old_juri_code  => ptax_rec.jurisdiction_code,
                             p_new_juri_code  => substr(jd_code,1,2)||'-000-'||substr(jd_code,8,4),
                             p_location       => 'PAY_TAXABILITY_RULES',
                             p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',4);

  END LOOP;
--
--
--
--Per bug 2996546
--Update of pay_taxability_rules . jurisdiction_code
--(Canadian Legislation)

OPEN ptax_ca_cur ;
          LOOP
          FETCH ptax_ca_cur INTO ptax_ca_rec;
          EXIT WHEN ptax_ca_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',15);

                    SELECT  pmod.new_county_code,
                            process_type
                    INTO    jd_code, l_proc_type
                    FROM    pay_us_modified_geocodes pmod
                    WHERE   pmod.state_code = 'CA'
                    AND     pmod.county_code = substr(ptax_ca_rec.jurisdiction_code,1,2)
                    AND     pmod.patch_name = p_patch_name;

                      IF G_MODE = 'UPGRADE' THEN

                          UPDATE pay_taxability_rules ptax
                          SET    ptax.jurisdiction_code = jd_code||'-000-'||'0000'
                          WHERE  ptax.jurisdiction_code = ptax_ca_rec.jurisdiction_code;

  --                    COMMIT;

                      END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',20);

-- write to the message table so that if this fails unexpectedly we can track which taxability
-- rules have been upgraded already.

			     write_message(
                             p_proc_type      => l_proc_type,
                             p_person_id      => null,
                             p_assign_id      => null,
                             p_old_juri_code  => ptax_ca_rec.jurisdiction_code,
                             p_new_juri_code  => jd_code||'-000-'||'0000',
                             p_location       => 'PAY_TAXABILITY_RULES',
                             p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',25);


          END LOOP;
CLOSE ptax_ca_cur ;
--
--
--
hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',5);

EXCEPTION
  WHEN OTHERS THEN

    l_error_message_text := to_char(SQLCODE)||SQLERRM||' Program error contact support';
    rollback;
    hr_utility.set_location('pay_us_geo_upd_pkg.update_taxability_rules',6);

     fnd_file.put_line(fnd_file.log, 'Exception update_taxability_rules' );
     fnd_file.put_line(fnd_file.log, 'sql error ' || sqlcode || ' - ' || substr(sqlerrm,1,80));

    raise_application_error(-20001,l_error_message_text);


END update_taxability_rules;

-- This procedure is separate from the above main upgrade_geocodes
-- This procedure will update the org_information1 column in the
-- hr_organization_information table where the org_information_context
-- is 'Local Tax Rules'
-- This procedure will only be run by one process, NOT MULTIPLE TIMES

PROCEDURE  update_org_info(P_GEO_PHASE_ID IN NUMBER,
                           P_MODE         IN VARCHAR2,
                           P_PATCH_NAME   IN VARCHAR2)

IS

--Retrieve all changed geocodes in the hr_organization_information table

  CURSOR org_info_cur IS
    SELECT  distinct org_information1
    FROM    pay_us_modified_geocodes pmod,
            hr_organization_information hoi
    WHERE   pmod.state_code = substr(hoi.org_information1,1,2)
    AND     pmod.county_code = substr(hoi.org_information1,4,3)
    AND     pmod.old_city_code = substr(hoi.org_information1,8,4)
    AND     pmod.process_type in ('UP','PU','RP')
    AND     pmod.patch_name = p_patch_name
    AND     hoi.org_information_context = 'Local Tax Rules'
    AND     NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                       where pugu.table_name = 'HR_ORGANIZATION_INFORMATION'
                       and pugu.new_juri_code = hoi.org_information1
                       and pugu.process_mode = g_mode
                       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);

   org_info_rec          org_info_cur%ROWTYPE;

--
--
--Per bug 2996546
--Added a cursor org_info_ca_cur to the procedure update_org_info
--Retrieve all changed org_information1 on hr_organization_information table.
--and update (for Canadian Legislation)
--

CURSOR org_info_ca_cur IS
    SELECT  distinct hoi.org_information1, hoi.org_information_id
    FROM    pay_us_modified_geocodes pmod,
            hr_organization_information hoi
    WHERE   pmod.state_code = 'CA'
    AND     pmod.county_code = substr(hoi.org_information1,1,2)
    AND     pmod.patch_name = p_patch_name
    AND     hoi.org_information_context in
			(
			'Prov Reporting Est',
			'Provincial Information',
			'Provincial Reporting Info.',
                        'Provincial Employment Standard',
			'Workers Comp Info.'
			)  ;
  org_info_ca_rec       org_info_ca_cur%ROWTYPE;
--
--
  new_geocode           hr_organization_information.org_information1%TYPE;
  l_proc_type           pay_us_modified_geocodes.process_type%TYPE;
  l_error_message_text  varchar2(240);

BEGIN

  g_geo_phase_id := p_geo_phase_id;
  g_mode         := p_mode;

hr_utility.trace('Entering pay_us_geo_upd_pkg.update_org_info');
hr_utility.trace('The phase id is:  '||to_char(g_geo_phase_id));

  FOR org_info_rec IN org_info_cur LOOP

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',1);

    SELECT  pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code,
            process_type
      INTO    new_geocode, l_proc_type
      FROM    pay_us_modified_geocodes pmod
     WHERE   pmod.state_code = substr(org_info_rec.org_information1,1,2)
       AND     pmod.county_code = substr(org_info_rec.org_information1,4,3)
       AND     pmod.old_city_code = substr(org_info_rec.org_information1,8,4)
       AND     pmod.process_type in ('UP','PU','RP','U')
       AND     pmod.patch_name = p_patch_name;

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',2);

    IF G_MODE = 'UPGRADE' THEN

      UPDATE hr_organization_information
         SET org_information1 = new_geocode
       WHERE org_information1 = org_info_rec.org_information1
         AND org_information_context = 'Local Tax Rules';

   --   COMMIT;

    END IF;

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',3);

-- write to the message table so that if this fails unexpectedly we can track which taxability
-- rules have been upgraded already.

    write_message(
                   p_proc_type      => l_proc_type,
                   p_person_id      => null,
                   p_assign_id      => null,
                   p_old_juri_code  => org_info_rec.org_information1,
                   p_new_juri_code  => new_geocode,
                   p_location       => 'HR_ORGANIZATION_INFORMATION',
                   p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',4);

  END LOOP;

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',5);
--
--
--

--Per bug 2996546
--Update of hr_organization_information . org_information1
--(Canadian Legislation)

OPEN org_info_ca_cur;
             LOOP
             FETCH org_info_ca_cur into org_info_ca_rec;
             EXIT WHEN org_info_ca_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',15);


		   SELECT   pmod.new_county_code,
                            process_type
                    INTO    new_geocode, l_proc_type
                    FROM    pay_us_modified_geocodes pmod
                    WHERE   pmod.state_code = 'CA'
                    AND     pmod.county_code = substr(org_info_ca_rec.org_information1,1,2)
                    AND     pmod.patch_name = p_patch_name;

                    IF G_MODE = 'UPGRADE' THEN

                          UPDATE hr_organization_information
                          SET    org_information1 = new_geocode
                          WHERE  org_information1 = org_info_ca_rec.org_information1
                          AND    org_information_id = org_info_ca_rec.org_information_id
                          AND    org_information_context in
                                        (
			                 'Prov Reporting Est',
			                 'Provincial Information',
			                 'Provincial Reporting Info.',
                                         'Provincial Employment Standard',
			                 'Workers Comp Info.'
			                 )  ;

                --      COMMIT;


                    END IF;
hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',15);

-- write to the message table so that if this fails unexpectedly
--

    write_message(
                   p_proc_type      => l_proc_type,
                   p_person_id      => null,
                   p_assign_id      => null,
                   p_old_juri_code  => org_info_rec.org_information1,
                   p_new_juri_code  => new_geocode,
                   p_location       => 'HR_ORGANIZATION_INFORMATION',
                   p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',20);
             END LOOP ;
CLOSE org_info_ca_cur;
--
--
--

EXCEPTION
  WHEN OTHERS THEN
        l_error_message_text := to_char(SQLCODE)||SQLERRM||' Program error contact support';
    rollback;
    hr_utility.set_location('pay_us_geo_upd_pkg.update_org_info',6);

     fnd_file.put_line(fnd_file.log, 'Exception update_org_info' );
     fnd_file.put_line(fnd_file.log, 'sql error ' || sqlcode || ' - ' || substr(sqlerrm,1,80));

    raise_application_error(-20001,l_error_message_text);

END update_org_info;


-- This api is used to upgrade assignments with a process type of US or SU

PROCEDURE upgrade_geo_api(P_ASSIGN_ID NUMBER,
                          P_PATCH_NAME VARCHAR2,
                          P_MODE VARCHAR2,
                          P_CITY_NAME VARCHAR2)
IS

-- Bug 3319878 -- Changed the query  to remove FTS  from  PAY_US_GEO_UPDATE

CURSOR chk_last_api(p_geo_phase_id NUMBER, p_mode VARCHAR2) IS
SELECT 'Y'
FROM  dual
WHERE exists (SELECT /*+index(pugu PAY_US_GEO_UPDATE_N2) */ 'Y'
                FROM  PAY_US_GEO_UPDATE pugu
               WHERE pugu.id = p_geo_phase_id
               AND  pugu.process_mode = p_mode
               AND  pugu.table_name is null
               AND  pugu.table_value_id is null
               AND  pugu.status <> 'C'
               AND  rownum < 2 );



l_chk_last_api varchar2(2);

CURSOR pay_patch_id(p_patch_name VARCHAR2) IS
SELECT ID
FROM pay_patch_status
WHERE  patch_name = p_patch_name;

l_id number;

BEGIN

hr_utility.trace('Entering the Geocode Upgrade API');


OPEN pay_patch_id(p_patch_name);
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',1);

FETCH pay_patch_id INTO l_id;
hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',5);

CLOSE pay_patch_id;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',10);

IF p_mode = 'UPGRADE' THEN

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',15);

            upgrade_geocodes(P_ASSIGN_START => p_assign_id,
                             P_ASSIGN_END   => p_assign_id,
                             P_GEO_PHASE_ID => l_id,
                             P_MODE         => 'UPGRADE',
                             P_PATCH_NAME   => p_patch_name,
                             P_CITY_NAME    => p_city_name,
			     P_API_MODE     => 'Y');

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',20);

ELSE

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',25);

            upgrade_geocodes(P_ASSIGN_START => p_assign_id,
                             P_ASSIGN_END   => p_assign_id,
                             P_GEO_PHASE_ID => l_id,
                             P_MODE         => 'DEBUG',
                             P_PATCH_NAME   => p_patch_name,
                             P_CITY_NAME    => p_city_name,
			     P_API_MODE     => 'Y');

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',30);

END IF;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',35);

OPEN chk_last_api(l_id, p_mode);

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',40);

FETCH chk_last_api INTO l_chk_last_api;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',45);

IF chk_last_api%NOTFOUND THEN  /* Everything is complete we can update pay_patch_status to complete */

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',50);

	UPDATE pay_patch_status
	SET status = 'C', phase = null
	WHERE id = l_id;
hr_utility.set_location('before commit ',4);

-- commit;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',55);

END IF;

hr_utility.set_location('pay_us_geo_upd_pkg.upgrade_geo_api',60);

CLOSE chk_last_api;

hr_utility.trace('Exiting the Geocode Upgrade API');

EXCEPTION
WHEN OTHERS THEN
   hr_utility.trace(to_char(SQLCODE)||SQLERRM||'Program error contact support');


END upgrade_geo_api;

--
--Per bug 2996546 created a public function
--to return pay_input_values_f.input_value_id
--after comparing values stored in a pl/sql table
--

Function IS_US_OR_CA_LEGISLATION
     (p_input_value_id in pay_input_values_f.input_value_id%TYPE)
      Return pay_input_values_f.input_value_id%TYPE Is

Begin
     for l_number in 1..l_total
     loop
     If (input_val_cur(l_number) = p_input_value_id) THEN
          Return (p_input_value_id);
     End If;
     End loop;
Return (0);
End IS_US_OR_CA_LEGISLATION ;

--
--
--
--Per bug 2996546,Added a new procedure update_ca_emp_info
--to update pay_ca_emp_fed_tax_info_f.employment_province,
--pay_ca_emp_prov_tax_info_f.province_code,
--pay_ca_legislation_info.jurisdiction_code
--
--
PROCEDURE  update_ca_emp_info (P_GEO_PHASE_ID IN NUMBER,
                               P_MODE         IN VARCHAR2,
                               P_PATCH_NAME   IN VARCHAR2)

IS
CURSOR canada_emp_fed_tax_cur IS
SELECT distinct cafed.employment_province, cafed.assignment_id
FROM pay_ca_emp_fed_tax_info_f cafed,
     pay_us_modified_geocodes pmod
WHERE  pmod.state_code = 'CA'
  AND  pmod.county_code = cafed.employment_province
  AND  pmod.patch_name = p_patch_name;

canada_emp_fed_rec       canada_emp_fed_tax_cur%ROWTYPE;

CURSOR canada_emp_prov_tax_cur IS
SELECT   distinct caprov.province_code, caprov.assignment_id
FROM pay_ca_emp_prov_tax_info_f caprov,
     pay_us_modified_geocodes pmod
WHERE  pmod.state_code = 'CA'
  AND  pmod.county_code = caprov.province_code
  AND  pmod.patch_name = p_patch_name;

canada_emp_prov_rec        canada_emp_prov_tax_cur%ROWTYPE;

CURSOR canada_leg_info_cur IS
SELECT distinct caleg.jurisdiction_code
FROM     pay_ca_legislation_info caleg,
               pay_us_modified_geocodes pmod
WHERE  pmod.state_code = 'CA'
    AND  pmod.county_code = caleg.jurisdiction_code
    AND  pmod.patch_name = p_patch_name ;

canada_leg_info_rec          canada_leg_info_cur%ROWTYPE;



  new_geocode               pay_ca_emp_fed_tax_info_f .employment_province%TYPE;
  new_geocode1             pay_ca_emp_prov_tax_info_f.province_code%TYPE;
  new_geocode2             pay_ca_legislation_info. jurisdiction_code%TYPE;
  l_proc_type                  pay_us_modified_geocodes.process_type%TYPE;
  l_error_message_text  varchar2(240);

BEGIN

  g_geo_phase_id := p_geo_phase_id;
  g_mode         := p_mode;


hr_utility.trace('Entering pay_us_geo_upd_pkg.update_ca_emp_info');
hr_utility.trace('The phase id is:  '||to_char(g_geo_phase_id));

OPEN canada_emp_fed_tax_cur ;
             LOOP
             FETCH canada_emp_fed_tax_cur into canada_emp_fed_rec;
             EXIT WHEN canada_emp_fed_tax_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',1);
                    SELECT   pmod.new_county_code,
                                   pmod.process_type
                    INTO       new_geocode, l_proc_type
                    FROM    pay_us_modified_geocodes pmod
                    WHERE   pmod.state_code = 'CA'
                    AND     pmod.county_code = canada_emp_fed_rec.employment_province
                    AND     pmod.patch_name = p_patch_name;

                    IF G_MODE = 'UPGRADE' THEN


                       UPDATE pay_ca_emp_fed_tax_info_f
                       SET    employment_province = new_geocode
                       WHERE  employment_province = canada_emp_fed_rec.employment_province
                       AND      assignment_id     = canada_emp_fed_rec.assignment_id ;

               --     COMMIT;


                    END IF;


hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',2);
      -- write to the message table so that if this fails unexpectedly
write_message(
                   p_proc_type      => l_proc_type,
                   p_person_id      => null,
                   p_assign_id      => canada_emp_fed_rec.assignment_id,
                   p_old_juri_code  => canada_emp_fed_rec.employment_province,
                   p_new_juri_code  => new_geocode,
                   p_location       => 'PAY_CA_EMP_FED_TAX_INFO_F',
                   p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',3);

             END LOOP ;
CLOSE canada_emp_fed_tax_cur ;

OPEN canada_emp_prov_tax_cur ;
             LOOP
             FETCH canada_emp_prov_tax_cur into canada_emp_prov_rec;
             EXIT WHEN canada_emp_prov_tax_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',4);

                    SELECT   pmod.new_county_code,
                                   pmod.process_type
                    INTO       new_geocode1, l_proc_type
                    FROM    pay_us_modified_geocodes pmod
                    WHERE   pmod.state_code = 'CA'
                    AND     pmod.county_code = canada_emp_prov_rec.province_code
                    AND     pmod.patch_name = p_patch_name;


                     IF G_MODE = 'UPGRADE' THEN


                           UPDATE pay_ca_emp_prov_tax_info_f
                           SET    province_code = new_geocode1
                           WHERE  province_code = canada_emp_prov_rec.province_code
                           AND    assignment_id = canada_emp_prov_rec.assignment_id ;

                --     COMMIT;


                     END IF;


hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',5);
-- write to the message table so that if this fails unexpectedly
write_message(
                   p_proc_type      => l_proc_type,
                   p_person_id      => null,
                   p_assign_id      => canada_emp_prov_rec.assignment_id,
                   p_old_juri_code  => canada_emp_prov_rec.province_code,
                   p_new_juri_code  => new_geocode1,
                   p_location       => 'PAY_CA_EMP_PROV_TAX_INFO_F',
                   p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',6);
             END LOOP ;
CLOSE canada_emp_prov_tax_cur ;



OPEN  canada_leg_info_cur;
             LOOP
             FETCH canada_leg_info_cur into canada_leg_info_rec ;
             EXIT WHEN canada_leg_info_cur%NOTFOUND;

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',7);
                    SELECT   pmod.new_county_code,
                                   pmod.process_type
                    INTO       new_geocode2, l_proc_type
                    FROM    pay_us_modified_geocodes pmod
                    WHERE   pmod.state_code = 'CA'
                    AND     pmod.county_code = canada_leg_info_rec.jurisdiction_code
                    AND     pmod.patch_name = p_patch_name;

                      IF G_MODE = 'UPGRADE' THEN

                             UPDATE pay_ca_legislation_info
                             SET    jurisdiction_code = new_geocode2
                             WHERE  jurisdiction_code = canada_leg_info_rec.jurisdiction_code ;
                   --     COMMIT;


                      END IF;

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',8);
-- write to the message table so that if this fails unexpectedly
write_message(
                   p_proc_type      => l_proc_type,
                   p_person_id      => null,
                   p_assign_id      => null,
                   p_old_juri_code  => canada_leg_info_rec.jurisdiction_code,
                   p_new_juri_code  => new_geocode2,
                   p_location       => 'PAY_CA_LEGISLATION_INFO',
                   p_id             => null);

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',9);
             END LOOP ;

CLOSE  canada_leg_info_cur;

hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',10);
EXCEPTION
  WHEN OTHERS THEN
        l_error_message_text := to_char(SQLCODE)||SQLERRM||
                             ' Program error contact support';
    rollback;
    hr_utility.set_location('pay_us_geo_upd_pkg.update_ca_emp_info',11);

     fnd_file.put_line(fnd_file.log, 'Exception update_ca_emp_info' );
     fnd_file.put_line(fnd_file.log, 'sql error ' || sqlcode || ' - ' || substr(sqlerrm,1,80));

    raise_application_error(-20001,l_error_message_text);

hr_utility.set_location('before commit ',5);
-- commit;
END update_ca_emp_info ;
--
--
--
--
--
--
--Per bug 2996546,Created a new procedure group_level_balance to
--update pay_run_balances.jurisdiction_code
--for group level balances (both US and Canadian
--legislation)
--
--
--
PROCEDURE  group_level_balance (P_START_PAYROLL_ACTION  IN NUMBER,
                                P_END_PAYROLL_ACTION    IN NUMBER,
                                P_GEO_PHASE_ID          IN NUMBER,
                                P_MODE                  IN VARCHAR2,
                                P_PATCH_NAME            IN VARCHAR2)
IS

/*  Bug# 3679984  Forced the index PAY_US_MODIFIED_GEOCODES_PK on pay_us_modified_geocodes
and rearranged the order of the where clause in the subquery */

/* Bug 4773276 Changing the hint to PAY_US_MODIFIED_GEOCODES_N1 */

CURSOR group_level_bal_us (c_payroll_action_id number) IS
select
      prb.run_balance_id, prb.jurisdiction_code, prb.jurisdiction_comp3
 from pay_run_balances prb,   pay_us_modified_geocodes pmod
Where prb.payroll_action_id = c_payroll_action_id
                 --between p_start_payroll_action and p_end_payroll_action
  and prb.assignment_id is null
  and pmod.state_code = substr(prb.jurisdiction_code,1,2)
  and pmod.county_code = substr(prb.jurisdiction_code,4,3)
  and pmod.old_city_code = substr(prb.jurisdiction_code,8,4)
  and pmod.process_type in ('PU', 'UP')
  and pmod.patch_name = p_patch_name;

/*  and NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                    where pugu.process_type = g_process_type
                      and pugu.process_mode = g_mode
                      and pugu.assignment_id is null
                      and pugu.old_juri_code = prb.jurisdiction_code
                      and pugu.person_id = prb.run_balance_id
                      and pugu.table_name = 'PAY_RUN_BALANCES'
                      and pugu.id = g_geo_phase_id);*/

/* select /*+  ORDERED
            index(pmod PAY_US_MODIFIED_GEOCODES_N1)
            USE_NL(prb pdb pbd pmod) */
/*        prb.run_balance_id,
		prb.jurisdiction_code,
		prb.jurisdiction_comp3
  from pay_run_balances prb,
       pay_defined_balances pdb,
       pay_balance_dimensions pbd,
       pay_us_modified_geocodes pmod
 Where prb.payroll_action_id = c_payroll_action_id
                  --between p_start_payroll_action and p_end_payroll_action
   and prb.assignment_id is null
   and prb.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'GRP'
   and pdb.legislation_code = 'US'
   and pbd.database_item_suffix like '%JD%'
   and pmod.state_code = substr(prb.jurisdiction_code,1,2)
   and pmod.county_code = substr(prb.jurisdiction_code,4,3)
   and pmod.old_city_code = substr(prb.jurisdiction_code,8,4)
   and pmod.patch_name = p_patch_name
   and NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                     where pugu.process_type = g_process_type
                       and pugu.process_mode = g_mode
                       and pugu.assignment_id is null
                       and pugu.old_juri_code = pmod.state_code || '-' || pmod.county_code || '-' || pmod.old_city_code --prb.jurisdiction_code
                       and pugu.person_id = prb.payroll_action_id
                       and pugu.table_name = 'PAY_RUN_BALANCES'
                       and pugu.id = g_geo_phase_id);
*/
group_level_bal_us_rec     group_level_bal_us%ROWTYPE;


CURSOR group_level_bal_ca (c_payroll_action_id number) IS
select
      prb.run_balance_id, prb.jurisdiction_code, prb.jurisdiction_comp3
 from pay_run_balances prb, pay_us_modified_geocodes pmod
Where prb.payroll_action_id = c_payroll_action_id
                          --between p_start_payroll_action and p_end_payroll_action
  and prb.assignment_id is null
  and pmod.state_code = 'CA'
  and pmod.county_code = substr(prb.jurisdiction_code,1,2)
  and pmod.process_type in ('PU', 'UP')
  and pmod.patch_name = p_patch_name;

/*
  and NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                    where pugu.old_juri_code = prb.jurisdiction_code
                      and pugu.assignment_id is null
                      and pugu.person_id = prb.run_balance_id
                      and pugu.table_name = 'PAY_RUN_BALANCES'
                      and pugu.process_mode = g_mode
                      and pugu.process_type = g_process_type
                      and pugu.id = g_geo_phase_id); */

 /*select /*+  ORDERED
            index(pmod PAY_US_MODIFIED_GEOCODES_N1)
            USE_NL(prb pdb pbd pmod) */
/*	   prb.run_balance_id,
	   prb.jurisdiction_code,
       prb.jurisdiction_comp3
  from pay_run_balances prb,
       pay_defined_balances pdb,
       pay_balance_dimensions pbd,
       pay_us_modified_geocodes pmod
 Where prb.payroll_action_id = c_payroll_action_id
                           --between p_start_payroll_action and p_end_payroll_action
   and prb.assignment_id is null
   and prb.defined_balance_id = pdb.defined_balance_id
   and pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.dimension_level = 'GRP'
   and pdb.legislation_code = 'CA'
   and pbd.database_item_suffix like '%JD%'
   and pmod.state_code = 'CA'
   and pmod.county_code = substr(prb.jurisdiction_code,1,2)
   and pmod.patch_name = p_patch_name
   and NOT EXISTS (select 'Y' from PAY_US_GEO_UPDATE pugu
                     where pugu.old_juri_code = prb.jurisdiction_code
                       and pugu.assignment_id is null
                       and pugu.person_id = prb.payroll_action_id
                       and pugu.table_name = 'PAY_RUN_BALANCES'
                       and pugu.process_mode = g_mode
                       and pugu.process_type = g_process_type
                       and pugu.id = g_geo_phase_id);    */

  CURSOR c_legislation_code
      (
         c_start_pactid    number,
         c_end_pactid      number
      ) is
        select pbg.legislation_code,
               ppa.payroll_action_id
         from per_business_groups pbg, pay_payroll_actions ppa
        Where ppa.payroll_action_id between c_start_pactid and c_end_pactid
          and pbg.business_group_id = ppa.business_group_id;

group_level_bal_ca_rec     group_level_bal_ca%ROWTYPE;


  l_proc_type             pay_us_modified_geocodes.process_type%TYPE;
  l_geocode               pay_run_balances.jurisdiction_code%TYPE;
  l_new_city_code         pay_us_modified_geocodes.new_city_code%TYPE;
  l_legislation_code      per_business_groups.legislation_code%TYPE;
  l_pactid                pay_payroll_actions.payroll_action_id%TYPE;

  l_row_updated         varchar2(1);

  l_error_message_text  varchar2(240);

BEGIN

  g_geo_phase_id := p_geo_phase_id;
  g_mode              := p_mode;

hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance');
hr_utility.trace('The phase id is:  '||to_char(g_geo_phase_id));

    OPEN c_legislation_code ( p_start_payroll_action
                             ,p_end_payroll_action) ;

    LOOP
    FETCH c_legislation_code into l_legislation_code,
                                  l_pactid;
    EXIT WHEN c_legislation_code%NOTFOUND;



        If l_legislation_code = 'US' THEN
            OPEN group_level_bal_us (l_pactid);
                         LOOP
                         FETCH group_level_bal_us into group_level_bal_us_rec;
                         EXIT WHEN group_level_bal_us%NOTFOUND;


                 begin

                    l_row_updated := 'N';

                    select 'Y'
                    into l_row_updated
					from PAY_US_GEO_UPDATE pugu
                    where pugu.old_juri_code = group_level_bal_us_rec.jurisdiction_code
                      and pugu.assignment_id is null
                      and pugu.person_id = group_level_bal_us_rec.run_balance_id
                      and pugu.table_name = 'PAY_RUN_BALANCES'
                      and pugu.process_mode = g_mode
                      and pugu.process_type = g_process_type
                      and pugu.id = g_geo_phase_id;

                 exception

					when no_data_found then

			            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',1);
			            SELECT  pmod.state_code||'-'||pmod.county_code||'-'||pmod.new_city_code,
			                           process_type, pmod.new_city_code
			                  INTO l_geocode, l_proc_type, l_new_city_code
			                  FROM    pay_us_modified_geocodes pmod
			                 WHERE   pmod.state_code = substr(group_level_bal_us_rec.jurisdiction_code,1,2)
			                   AND     pmod.county_code = substr(group_level_bal_us_rec.jurisdiction_code,4,3)
			                   AND     pmod.old_city_code = substr(group_level_bal_us_rec.jurisdiction_code,8,4)
			            --     AND     pmod.process_type in ('UP','PU','RP','U','US','D','SU')
			                   AND     pmod.patch_name = p_patch_name;

			            	   IF G_MODE = 'UPGRADE' THEN

			                                UPDATE pay_run_balances
			                                SET    jurisdiction_code    = l_geocode,
			                                       jurisdiction_comp3 = l_new_city_code
			                                WHERE  payroll_action_id   =  group_level_bal_us_rec.run_balance_id
			                            --  AND    jurisdiction_comp3 = group_level_bal_us_rec.jurisdiction_comp3
			                                AND    jurisdiction_code = group_level_bal_us_rec.jurisdiction_code;

			                       --     COMMIT;
			                          END IF;


			            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',2);
			            -- write to the message table so that if this fails unexpectedly
			            write_message(
			                               p_proc_type      => l_proc_type,
			                               p_person_id      => group_level_bal_us_rec.run_balance_id,
			                               p_assign_id      => null,
			                               p_old_juri_code  => group_level_bal_us_rec.jurisdiction_code,
			                               p_new_juri_code  => l_geocode,
			                               p_location       => 'PAY_RUN_BALANCES',
			                               p_id             => null);

			            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',3);

				 end;

            END LOOP ;
               hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance - 7001');

            CLOSE group_level_bal_us ;

        else

            OPEN  group_level_bal_ca (l_pactid);
            LOOP
                         FETCH group_level_bal_ca into group_level_bal_ca_rec;
                         EXIT WHEN group_level_bal_ca%NOTFOUND;


                 begin

                    l_row_updated := 'N';

                    select 'Y'
                    into l_row_updated
					from PAY_US_GEO_UPDATE pugu
                    where pugu.old_juri_code = group_level_bal_ca_rec.jurisdiction_code
                      and pugu.assignment_id is null
                      and pugu.person_id = group_level_bal_ca_rec.run_balance_id
                      and pugu.table_name = 'PAY_RUN_BALANCES'
                      and pugu.process_mode = g_mode
                      and pugu.process_type = g_process_type
                      and pugu.id = g_geo_phase_id;

                 exception

					when no_data_found then

                    hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance - 7002');
		            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',4);
		            SELECT  pmod.new_county_code, pmod.process_type
		                  INTO l_geocode, l_proc_type
		                  FROM pay_us_modified_geocodes pmod
		                 WHERE pmod.state_code = 'CA'
		               --  AND pmod.county_code = group_level_bal_ca_rec.jurisdiction_code
		                   AND pmod.county_code = substr(group_level_bal_ca_rec.jurisdiction_code,1,2)
		                   AND pmod.patch_name = p_patch_name;

		              hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance - 7003');

		                           IF G_MODE = 'UPGRADE' THEN

		                                UPDATE pay_run_balances
		                                SET    jurisdiction_code    = l_geocode
		                                WHERE  payroll_action_id   =  group_level_bal_ca_rec.run_balance_id
		                            --  AND    jurisdiction_comp3 = group_level_bal_ca_rec.jurisdiction_comp3
		                            --  AND    jurisdiction_code = group_level_bal_ca_rec.jurisdiction_code
		                                AND    substr(jurisdiction_code,1,2) =
		                                           substr(group_level_bal_ca_rec.jurisdiction_code,1,2) ;

		            hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance - 7004');

		                       --     COMMIT;
		                          END IF;

		            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',5);
		            -- write to the message table so that if this fails unexpectedly
		            write_message(
		                               p_proc_type      => l_proc_type,
		                               p_person_id      => group_level_bal_ca_rec.run_balance_id,
		                               p_assign_id      => null,
		                               p_old_juri_code  => group_level_bal_ca_rec.jurisdiction_code,
		                               p_new_juri_code  => l_geocode,
		                               p_location       => 'PAY_RUN_BALANCES',
		                               p_id             => null);

		            hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',6);

				 end;

            END LOOP ;

            CLOSE group_level_bal_ca;

        END IF;  --l_legislation_code

END LOOP;

CLOSE c_legislation_code;

hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',7);
EXCEPTION
  WHEN OTHERS THEN
        l_error_message_text := to_char(SQLCODE)||SQLERRM||
                              ' Program error contact support';

hr_utility.trace('Entering pay_us_geo_upd_pkg. group_level_balance - 7005');
hr_utility.trace('l_error_message_text - ' ||l_error_message_text);


     fnd_file.put_line(fnd_file.log, 'Exception update_ca_emp_info' );
     fnd_file.put_line(fnd_file.log, 'sql error ' || sqlcode || ' - ' || substr(sqlerrm,1,80));


 rollback;



    hr_utility.set_location('pay_us_geo_upd_pkg. group_level_balance',8);
    raise_application_error(-20001,l_error_message_text);

hr_utility.set_location('before commit ',6);
-- commit;
END group_level_balance ;
--

END pay_us_geo_upd_pkg;

/
