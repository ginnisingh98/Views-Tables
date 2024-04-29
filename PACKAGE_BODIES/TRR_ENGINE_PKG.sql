--------------------------------------------------------
--  DDL for Package Body TRR_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."TRR_ENGINE_PKG" as
/* $Header: pytrreng.pkb 115.10 2002/06/14 10:15:01 pkm ship    $ */

procedure federal_trr(errbuf     OUT     VARCHAR2,
                      retcode    OUT     NUMBER,
                      p_business_group   number ,
                      p_start_date       varchar2,
                      p_end_date	 varchar2,
		      p_gre		 number,
                      p_federal  	 varchar2,
                      p_state		 varchar2,
                      p_dimension        varchar2)
is
--
--
 cursor gre_sizes(c_business_group_id  number,
                  c_tax_unit_id        number,
                  c_jurisdiction_code  varchar2)
 is
   select count(*) gre_size, puar.tax_unit_id gre_id, htu.name gre_name
   from   pay_us_asg_reporting puar,
          hr_tax_units_v htu
   where  puar.tax_unit_id=htu.tax_unit_id
   and    htu.business_group_id=c_business_group_id
   and    substr(puar.jurisdiction_code,1,2)=
                   nvl(c_jurisdiction_code,substr(puar.jurisdiction_code,1,2))
   and    htu.tax_unit_id=nvl(c_tax_unit_id,htu.tax_unit_id)
   group by puar.tax_unit_id,htu.name
   order by count(*);

  gre_list    gre_info_list;
  list_index  number:=1;
  start_index number:=1;
  end_index   number:=1;
  l_req_id    number;
  copies_buffer varchar2(80) := null;
  print_buffer  varchar2(80) := null;
  printer_buffer  varchar2(80) := null;
  style_buffer  varchar2(80) := null;
  save_buffer  boolean := null;
  save_result  varchar2(1) := null;
  req_id  varchar2(80) := null;
  x boolean;

  l_valid_status  varchar2(5);
  l_program       varchar2(100);
--
--
begin

--hr_utility.trace_on(null,'oracle');

  -- initialise variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
  retcode := 0;
  -- get printing info
  req_id:=fnd_profile.value('CONC_REQUEST_ID');
  print_buffer:=fnd_profile.value('CONC_PRINT_TOGETHER');
   if (print_buffer is NULL)
   then print_buffer:='N';
   end if;

  select number_of_copies,
        printer,
        print_style,
        save_output_flag
  into  copies_buffer,
        printer_buffer,
        style_buffer,
        save_result
  from  fnd_concurrent_requests
  where request_id = fnd_number.canonical_to_number(req_id);


  if (save_result='Y') then
    save_buffer:=true;
  elsif (save_result='N') then
    save_buffer:=false;
  else
    save_buffer:=NULL;
  end if;

-- logic to decide which report to fire
   begin
        select pdb.run_balance_status
          into l_valid_status
        from   pay_defined_balances pdb,
               pay_balance_types pbt,
               pay_balance_dimensions pbd
        where  pdb.legislation_code = 'US'
           and pdb.save_run_balance = 'Y'
           and pdb.run_balance_status is not null
           and pdb.balance_type_id = pbt.balance_type_id
           and pbd.balance_dimension_id = pdb.balance_dimension_id
           and pbt.balance_name = 'SIT Withheld'
           and pbd.database_item_suffix = '_GRE_JD_RUN';

        if l_valid_status = 'V' then
           --call the new report
           l_program := 'PYFEDTRR_RB';

        else
           -- call the old report
           l_program := 'PYFEDTRR';

        end if;

   exception when others then
           -- call the old report
           l_program := 'PYFEDTRR';
   end;
-- end logic

  -- read data into table
  for  grerec in gre_sizes(p_business_group,p_gre,p_state) loop
    gre_list(list_index).gre_size :=grerec.gre_size;
    gre_list(list_index).gre_id   :=grerec.gre_id;
    gre_list(list_index).gre_name :=grerec.gre_name;


    list_index:=list_index+1;
  end loop;


  -- get start of list
  start_index:=1;
  -- get end of list
  end_index:=list_index-1;
  -- loop round from both ends working inwards
  while (start_index<end_index) loop
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    -- submit requests for report
    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => l_program,
                            argument1      => gre_list(start_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(start_index).gre_id,
                            argument6      => p_federal,
                            argument7      => p_state,
                            argument8      => p_dimension);
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => l_program,
                            argument1      => gre_list(end_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(end_index).gre_id,
                            argument6      => p_federal,
                            argument7      => p_state,
                            argument8      => p_dimension);
    -- get next values
    start_index:=start_index+1;
    end_index:=end_index-1;
    --

  end loop;
  -- submit for middle value in list if odd number of gre's
  if (start_index=end_index) then
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => l_program,
                            argument1      => gre_list(start_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(start_index).gre_id,
                            argument6      => p_federal,
                            argument7      => p_state,
                            argument8      => p_dimension);
  end if;
EXCEPTION
  --
   WHEN hr_utility.hr_error THEN
     --
     -- Set up error message and error return code.
     --
	--hr_utility.trace('in the exception');
     errbuf  := hr_utility.get_message;
     retcode := 2;
     --
--
WHEN others THEN
--
     -- Set up error message and return code.
     --
     errbuf  := sqlerrm;
     retcode := 2;
end federal_trr;

procedure state_trr
is
begin

 null;
end state_trr;
--
procedure local_trr(errbuf    out     varchar2
                     ,retcode   out     number
                     ,p_business_group  number
                     ,p_start_date      varchar2
                     ,p_end_date        varchar2
                     ,p_gre             number
                     ,p_state           varchar2
                     ,p_locality_type   varchar2
                     ,p_is_city         varchar2
                     ,p_city            varchar2
                     ,p_is_county       varchar2
                     ,p_county          varchar2
                     ,p_is_school       varchar2
                     ,p_school          varchar2
                     ,p_sort_option_1   varchar2
                     ,p_sort_option_2   varchar2
                     ,p_sort_option_3   varchar2
                     ,p_dimension       varchar2)
is
--
 cursor gre_sizes(c_business_group_id  number,
                  c_tax_unit_id        number,
                  c_jurisdiction_code  varchar2)
 is
   select count(*) gre_size,puar.tax_unit_id gre_id,htu.name gre_name
   from   pay_us_asg_reporting puar,
          hr_tax_units_v htu
   where  puar.tax_unit_id=htu.tax_unit_id
   and    htu.business_group_id=c_business_group_id
   and    substr(puar.jurisdiction_code,1,2)=
                   nvl(c_jurisdiction_code,substr(puar.jurisdiction_code,1,2))
   and    htu.tax_unit_id=nvl(c_tax_unit_id,htu.tax_unit_id)
   group by puar.tax_unit_id,htu.name
   order by count(*);

  gre_list    gre_info_list;
  list_index  number:=1;
  start_index number:=1;
  end_index   number:=1;
  l_req_id    number;
  copies_buffer varchar2(80) := null;
  print_buffer  varchar2(80) := null;
  printer_buffer  varchar2(80) := null;
  style_buffer  varchar2(80) := null;
  save_buffer  boolean := null;
  save_result  varchar2(1) := null;
  req_id  varchar2(80) := null;
  x boolean;

--
--
begin
  -- initialise variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
  retcode := 0;
  -- get printing info
  req_id:=fnd_profile.value('CONC_REQUEST_ID');
  print_buffer:=fnd_profile.value('CONC_PRINT_TOGETHER');
   if (print_buffer is NULL)
   then print_buffer:='N';
   end if;

  select number_of_copies,
        printer,
        print_style,
        save_output_flag
  into  copies_buffer,
        printer_buffer,
        style_buffer,
        save_result
  from  fnd_concurrent_requests
  where request_id = fnd_number.canonical_to_number(req_id);

  if (save_result='Y') then
    save_buffer:=true;
  elsif (save_result='N') then
    save_buffer:=false;
  else
    save_buffer:=NULL;
  end if;

  -- read data into table
  for  grerec in gre_sizes(p_business_group,p_gre,p_state) loop
    gre_list(list_index).gre_size:=grerec.gre_size;
    gre_list(list_index).gre_id   :=grerec.gre_id;
    gre_list(list_index).gre_name :=grerec.gre_name;

    list_index:=list_index+1;
  end loop;
  -- get start of list
  start_index:=1;
  -- get end of list
  end_index:=list_index-1;
  -- loop round from both ends working inwards
  while (start_index<end_index) loop
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    -- submit requests for report
    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'PYLOCTRR',
                            argument1      => gre_list(start_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(start_index).gre_id,
                            argument6      => p_state,
			    argument7	   => p_locality_type,
                            argument8      => p_is_city,
                            argument9      => p_city,
                            argument10     => p_is_county,
                            argument11     => p_county,
                            argument12     => p_is_school,
                            argument13     => p_school,
                            argument14     => p_sort_option_1,
                            argument15     => p_sort_option_2,
                            argument16     => p_sort_option_3,
                            argument17     => p_dimension);
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'PYLOCTRR',
                            argument1      => gre_list(end_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(end_index).gre_id,
                            argument6      => p_state,
                            argument7      => p_locality_type,
                            argument8      => p_is_city,
                            argument9      => p_city,
                            argument10     => p_is_county,
                            argument11     => p_county,
                            argument12     => p_is_school,
                            argument13     => p_school,
                            argument14     => p_sort_option_1,
                            argument15     => p_sort_option_2,
                            argument16     => p_sort_option_3,
                            argument17     => p_dimension);
    -- get next values
    start_index:=start_index+1;
    end_index:=end_index-1;
    --

  end loop;
  -- submit for middle value in list if odd number of gre's
  if (start_index=end_index) then
    -- set print options
    x:=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    l_req_id:=fnd_request.submit_request(
                            application    => 'PAY',
                            program        => 'PYLOCTRR',
                            argument1      => gre_list(start_index).gre_name,
                            argument2      => p_business_group,
                            argument3      => p_start_date,
                            argument4      => p_end_date,
                            argument5      => gre_list(start_index).gre_id,
                            argument6      => p_state,
                            argument7      => p_locality_type,
                            argument8      => p_is_city,
                            argument9      => p_city,
                            argument10     => p_is_county,
                            argument11     => p_county,
                            argument12     => p_is_school,
                            argument13     => p_school,
                            argument14     => p_sort_option_1,
                            argument15     => p_sort_option_2,
                            argument16     => p_sort_option_3,
                            argument17     => p_dimension);
  end if;
EXCEPTION
  --
   WHEN hr_utility.hr_error THEN
     --
     -- Set up error message and error return code.
     --
     errbuf  := hr_utility.get_message;
     retcode := 2;
     --
--
--
     -- Set up error message and return code.
     --
     errbuf  := sqlerrm;
     retcode := 2;
end local_trr;
end TRR_ENGINE_PKG;

/
