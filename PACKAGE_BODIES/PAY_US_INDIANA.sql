--------------------------------------------------------
--  DDL for Package Body PAY_US_INDIANA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_INDIANA" as
/* $Header: pyusinyb.pkb 120.0.12010000.2 2009/12/08 07:41:01 parusia ship $*/


/* Script to get the vaule of person's address detail
    insert the values into temporary table and delete the values from
    temporary table once the data is printed.
*/

PROCEDURE print_report_address(errbuf             OUT     NOCOPY VARCHAR2,
                               retcode            OUT     NOCOPY NUMBER)
IS
      l6_wait           BOOLEAN;
      l6_phase          VARCHAR2(30);
      l6_status         VARCHAR2(30);
      l6_dev_phase      VARCHAR2(30);
      l6_dev_status     VARCHAR2(30);
      l6_message        VARCHAR2(255);
      l_rep_req_id      NUMBER;
      copies_buffer 	varchar2(80) := null;
      print_buffer  	varchar2(80) := null;
      printer_buffer  	varchar2(80) := null;
      style_buffer  	varchar2(80) := null;
      save_buffer  	boolean := null;
      save_result  	varchar2(1) := null;
      req_id 		VARCHAR2(80) := NULL; /* Request Id of the main request */
      x			BOOLEAN;

      l_session_id number;
BEGIN
 -- initialise variables - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
      retcode := 0;

      select userenv('sessionid')
      into   l_session_id
      from dual;

      hr_utility.trace('Entering the print_report_address');

      req_id:=fnd_profile.value('CONC_REQUEST_ID');
      print_buffer:= 'N'; /*can be retrieved from fnd_profile.value('CONC_PRINT_TOGETHER'), if
			    set to 'Y' then will print the report only if all the processes are
			    complete */

      select number_of_copies,
        printer,
        print_style,
        save_output_flag
      into  copies_buffer,
        printer_buffer,
        style_buffer,
        save_result
      from  fnd_concurrent_requests
      where request_id = to_number(req_id);

      if (save_result='Y') then
        save_buffer:=true;
      elsif (save_result='N') then
        save_buffer:=false;
      else
        save_buffer:=NULL;
      end if;

      x := FND_REQUEST.set_print_options(
			printer => printer_buffer,
			style	=> style_buffer,
			copies  => copies_buffer,
			save_output => save_buffer,
			print_together => print_buffer);

      l_rep_req_id := fnd_request.submit_request(application    => 'PAY',
                                                 program        => 'PYUSINRP');

      IF(l_rep_req_id = 0) THEN
           hr_utility.trace(' Error While Indiana Year Begin Address Report' );
           hr_utility.raise_error;
      ELSE
         hr_utility.trace(' Concurrent Request Id (Report Spool Request) : '
                                         ||to_char(l_rep_req_id));
      END IF; /* if l_rep_req_id */

      COMMIT;

     /* Wait for report request completion */
      hr_utility.trace('Waiting for the application to get completed ');

      /* Check for Report Request Status */

      l6_wait := fnd_concurrent.wait_for_request
                 (request_id => l_rep_req_id
                 ,interval   => 1
                 ,phase      => l6_phase
                 ,status     => l6_status
                 ,dev_phase  => l6_dev_phase
                 ,dev_status => l6_dev_status
                 ,message    => l6_message);

     hr_utility.trace('Wait completed,Printing output based on the result');

     IF NOT (l6_dev_phase = 'COMPLETE' and l6_dev_status = 'NORMAL') THEN
             hr_utility.trace('SQL Report - Indiana Address Exited with error') ;
             retcode := 2;
     ELSE
             hr_utility.trace('SQL Report - Indiana Address Successful');
     END IF; /* l6_dev_phase */


     DELETE
     FROM pay_us_rpt_totals
     WHERE attribute20 = 'INDIANA_YEAR_BEGIN_ADDRESS'
     AND   organization_id = l_session_id;

     COMMIT;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
               hr_utility.trace('Exception  : No data Found');
     --
     -- Set up error message and error return code.
     --

               errbuf  := hr_utility.get_message;
               retcode := 2;
         WHEN OTHERS THEN
              hr_utility.trace('Excption    : When Others');
     --
     -- Set up error message and error return code.
     --

               errbuf  := hr_utility.get_message;
              retcode := 2;
END print_report_address;


PROCEDURE print_override_location(errbuf             OUT     NOCOPY VARCHAR2,
                                  retcode            OUT     NOCOPY NUMBER,
                                  p_business_group   IN      VARCHAR2,
                                  p_curr_year        IN      VARCHAR2) IS

      l6_wait           BOOLEAN;
      l6_phase          VARCHAR2(30);
      l6_status         VARCHAR2(30);
      l6_dev_phase      VARCHAR2(30);
      l6_dev_status     VARCHAR2(30);
      l6_message        VARCHAR2(255);
      l_rep_req_id      NUMBER;
      copies_buffer 	varchar2(80) := null;
      print_buffer  	varchar2(80) := null;
      printer_buffer  	varchar2(80) := null;
      style_buffer  	varchar2(80) := null;
      save_buffer  	    boolean := null;
      save_result  	    varchar2(1) := null;
      req_id 		    VARCHAR2(80) := NULL; /* Request Id of the main request */
      x			        BOOLEAN;
BEGIN
 -- initialise variables - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error
      retcode := 0;

      hr_utility.trace('Entering the print_report_address');

      req_id:=fnd_profile.value('CONC_REQUEST_ID');
      print_buffer:= 'N'; /*can be retrieved from fnd_profile.value('CONC_PRINT_TOGETHER'), if
			    set to 'Y' then will print the report only if all the processes are
			    complete */

      select number_of_copies,
        printer,
        print_style,
        save_output_flag
      into  copies_buffer,
        printer_buffer,
        style_buffer,
        save_result
      from  fnd_concurrent_requests
      where request_id = to_number(req_id);

      if (save_result='Y') then
        save_buffer:=true;
      elsif (save_result='N') then
        save_buffer:=false;
      else
        save_buffer:=NULL;
      end if;

      x := FND_REQUEST.set_print_options(
			printer => printer_buffer,
			style	=> style_buffer,
			copies  => copies_buffer,
			save_output => save_buffer,
			print_together => print_buffer);

      l_rep_req_id := fnd_request.submit_request(application    => 'PAY',
                                                 program        => 'pyusolrp',
                                                 argument1      => p_business_group,
                                                 argument2      => p_curr_year);

      IF(l_rep_req_id = 0) THEN
           hr_utility.trace(' Error While Indiana Year Begin Address Report' );
           hr_utility.raise_error;
      ELSE
         hr_utility.trace(' Concurrent Request Id (Report Spool Request) : '
                                         ||to_char(l_rep_req_id));
      END IF; /* if l_rep_req_id */

      COMMIT;

     /* Wait for report request completion */
      hr_utility.trace('Waiting for the application to get completed ');

      /* Check for Report Request Status */

      l6_wait := fnd_concurrent.wait_for_request
                 (request_id => l_rep_req_id
                 ,interval   => 1
                 ,phase      => l6_phase
                 ,status     => l6_status
                 ,dev_phase  => l6_dev_phase
                 ,dev_status => l6_dev_status
                 ,message    => l6_message);

     hr_utility.trace('Wait completed,Printing output based on the result');

     IF NOT (l6_dev_phase = 'COMPLETE' and l6_dev_status = 'NORMAL') THEN
             hr_utility.trace('SQL Report Override Location Exited with error') ;
             retcode := 2;
     ELSE
             hr_utility.trace('SQL Report Override Loaction Successful');
     END IF; /* l6_dev_phase */


       EXCEPTION
         WHEN NO_DATA_FOUND THEN
               hr_utility.trace('Exception  : No data Found');
     --
     -- Set up error message and error return code.
     --

               errbuf  := hr_utility.get_message;
               retcode := 2;
         WHEN OTHERS THEN
              hr_utility.trace('Exception    : When Others');
     --
     -- Set up error message and error return code.
     --

               errbuf  := hr_utility.get_message;
              retcode := 2;
END print_override_location;



PROCEDURE get_insert_values (  p_proc_name                VARCHAR2,
                               p_BUSINESS_GROUP_ID        VARCHAR2,
                               p_person_id                VARCHAR2,
                               p_curr_year                VARCHAR2,
                               p_gre_name          IN OUT NOCOPY VARCHAR2,
                               p_full_name         IN OUT NOCOPY VARCHAR2,
                               p_employee_number   IN OUT NOCOPY VARCHAR2)
IS

 /* cursor to get the person's assignment detail  */

CURSOR  csr_person_details
IS
SELECT  ppf.full_name,
        ppf.employee_number
FROM
        per_all_people_f ppf
WHERE
         ppf.person_id = p_person_id
     AND to_date('01-JAN-'||p_curr_year,'DD/MM/YYYY')
     BETWEEN (ppf.effective_start_date + 1)
     AND ppf.effective_end_date;

CURSOR cst_get_gre_name IS
SELECT hou.name
FROM hr_all_organization_units hou
WHERE hou.organization_id = hou.business_group_id
and hou.business_group_id = p_business_group_id ;

l_proc_name varchar2(50) := 'get_insert_value';

 BEGIN
  hr_utility.trace('In proc : get_insert_values');
--  hr_utility.trace('Person Id : ' || to_char(p_person_id));
  --hr_utility.trace('Location Id   :  ' || to_char(p_location_id));

  IF  p_proc_name = 'INDIANA_YEAR_BEGIN_ADDRESS' THEN

        hr_utility.trace('Entering : ' || l_proc_name);

        /* get the detail of the person */

        OPEN csr_person_details;

        FETCH csr_person_details
         INTO p_full_name,
              p_employee_number;

       IF csr_person_details%NOTFOUND THEN
             hr_utility.trace('csr_person_details failed');
       END IF;


       CLOSE csr_person_details;


    /* get the Business Group name for p_business_group_id*/

      OPEN  cst_get_gre_name;

      FETCH  cst_get_gre_name
       INTO  p_gre_name;

      CLOSE cst_get_gre_name;

   END IF;
   hr_utility.trace('GRE NAME         : ' || p_gre_name);
   hr_utility.trace('Full NAME        : ' || p_full_name);
   hr_utility.trace('Employee Number: '  || p_employee_number);

   hr_utility.trace('Leaving : ' || l_proc_name);
EXCEPTION
    WHEN OTHERS THEN
    hr_utility.trace('Leaving : ' || l_proc_name || ' With Erorr' );

END  get_insert_values ;


/* Mapping of the Temp. table and value are as follows
   tax_unit_name       -     GRE_NAME
   full_name           -     Attribute1
   Employee_no     	-        ATTRUBITE2
   effective_start_date-     ATTRIBUTE3
   town_or_city              ATTRIBUTE4
   region_1                ATTRIBUTE5
   region_2                ATTRIBUTE6
   postal_code             ATTRIBUTE7
   add_information17       ATTRIBUTE8
   add_information18       ATTRIBUTE9
   add_information19       ATTRIBUTE10
   add_information20       ATTRIBUTE11
   error                   ATTRIBUTE12
    */

procedure  put_into_temp_table(
                              p_tax_unit_name in varchar2,
                              p_emp_full_name in varchar2,
                              p_employee_number in varchar2,
                              p_effective_start_date in date,
                        	  p_town_or_city in varchar2,
                        	  p_region_1 in varchar2,
                        	  p_region_2 in varchar2,
                        	  p_postal_code in varchar2,
                        	  p_add_information17 in varchar2,
                        	  p_add_information18 in varchar2,
                        	  p_add_information19 in varchar2,
                        	  p_add_information20 in varchar2,
               				  p_error in varchar2
                                  )
IS
l_success_failure_indicator number;
l_proc_name                 varchar2(50) := 'put_into_temp_table';
l_session_id                number;

BEGIN
       hr_utility.trace('Entering :' || l_proc_name);

       select userenv('sessionid')
       into   l_session_id
       from dual;

        INSERT
        INTO    pay_us_rpt_totals
               (
                  organization_id,
                  gre_name,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute20
               )
        VALUES (
                  l_session_id,
                  p_tax_unit_name,
                  p_emp_full_name,
                  p_employee_number,
                  to_char(p_effective_start_date,'mm/dd/yyyy'),
                  p_town_or_city    ,
                  p_region_1        ,
                  p_region_2        ,
                  p_postal_code     ,
                  p_add_information17,
                  p_add_information18,
                  p_add_information19,
                  p_add_information20,
                  p_error,
                  'INDIANA_YEAR_BEGIN_ADDRESS');


        hr_utility.trace('Leaving : ' || l_proc_name);
EXCEPTION

     WHEN others THEN
        hr_utility.trace('Error in the Instertion into temporary Table');
END put_into_temp_table;


procedure update_address(errbuf             OUT     NOCOPY VARCHAR2,
                         retcode            OUT     NOCOPY NUMBER,
                         p_business_group   IN      VARCHAR2,
                         p_curr_year        IN      VARCHAR2) is

 l_ret_code             number;
 l_ret_text		        varchar2(1000);
 l_gre_name             hr_tax_units_v.name%type;
 l_full_name            per_people_f.full_name%type;
 l_employee_number      per_people_f.employee_number%type;
 l_error		        varchar2(1000);
 l_last_day              DATE;
 l_last_year            VARCHAR2(4);


 cursor csr_get_add  is
 SELECT *
 FROM per_addresses pa
 WHERE
        pa.add_information17 = 'IN'
	and pa.date_from < to_date('01-JAN-'||p_curr_year,'DD/MM/YYYY')
	and pa.date_to is null
    and pa.primary_flag = 'Y'
    and pa.business_group_id = p_business_group;

 l_add_rec              csr_get_add%rowtype;
begin

-- hr_utility.trace_on(null,'oracle');
  /* Get the addresses which has an tax override address of Indiana prior to
     or as of 1-JAN-2001 */

  l_last_year := p_curr_year - 1;
  l_last_day  := to_date('31-DEC-'||l_last_year,'DD/MM/YYYY');

  open csr_get_add ;

  hr_utility.trace('Updating the Per_Addresses for the esisting records...');

  loop

      fetch csr_get_add into l_add_rec;

      exit when csr_get_add%NOTFOUND;

      /* End date the address record as of /12/31/2000 */


      update PER_ADDRESSES
      set date_to = l_last_day
      where address_id = l_add_rec.address_id;

      hr_utility.trace('Updated Addresses : ' || to_char(l_add_rec.address_id));

      insert into PER_ADDRESSES
        (ADDRESS_ID,
        BUSINESS_GROUP_ID,
        PERSON_ID,
        DATE_FROM,
        PRIMARY_FLAG,
        STYLE,
        ADDRESS_LINE1,
        ADDRESS_LINE2,
        ADDRESS_LINE3,
        ADDRESS_TYPE,
        COMMENTS,
        COUNTRY,
        DATE_TO,
        POSTAL_CODE,
        REGION_1,
        REGION_2,
        REGION_3,
        TELEPHONE_NUMBER_1,
        TELEPHONE_NUMBER_2,
        TELEPHONE_NUMBER_3,
        TOWN_OR_CITY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        ADDR_ATTRIBUTE_CATEGORY,
        ADDR_ATTRIBUTE1,
        ADDR_ATTRIBUTE2,
        ADDR_ATTRIBUTE3,
        ADDR_ATTRIBUTE4,
        ADDR_ATTRIBUTE5,
        ADDR_ATTRIBUTE6,
        ADDR_ATTRIBUTE7,
        ADDR_ATTRIBUTE8,
        ADDR_ATTRIBUTE9,
        ADDR_ATTRIBUTE10,
        ADDR_ATTRIBUTE11,
        ADDR_ATTRIBUTE12,
        ADDR_ATTRIBUTE13,
        ADDR_ATTRIBUTE14,
        ADDR_ATTRIBUTE15,
        ADDR_ATTRIBUTE16,
        ADDR_ATTRIBUTE17,
        ADDR_ATTRIBUTE18,
        ADDR_ATTRIBUTE19,
        ADDR_ATTRIBUTE20,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATED_BY,
        CREATION_DATE,
        OBJECT_VERSION_NUMBER,
        ADD_INFORMATION17,
        ADD_INFORMATION18,
        ADD_INFORMATION19,
        ADD_INFORMATION20,
        ADD_INFORMATION13,
        ADD_INFORMATION14,
        ADD_INFORMATION15,
        ADD_INFORMATION16
        )
        values
        (per_addresses_s.NEXTVAL,
        l_add_rec.BUSINESS_GROUP_ID,
        l_add_rec.PERSON_ID,
        to_date('01-JAN-'||p_curr_year,'DD/MM/YYYY'),
        --to_date('01-JAN-2001', 'DD-MON-YYYY'),
        l_add_rec.PRIMARY_FLAG,
        l_add_rec.STYLE,
        l_add_rec.ADDRESS_LINE1,
        l_add_rec.ADDRESS_LINE2,
        l_add_rec.ADDRESS_LINE3,
        l_add_rec.ADDRESS_TYPE,
        l_add_rec.COMMENTS,
        l_add_rec.COUNTRY,
        NULL,
        l_add_rec.POSTAL_CODE,
        l_add_rec.REGION_1,
        l_add_rec.REGION_2,
        l_add_rec.REGION_3,
        l_add_rec.TELEPHONE_NUMBER_1,
        l_add_rec.TELEPHONE_NUMBER_2,
        l_add_rec.TELEPHONE_NUMBER_3,
        l_add_rec.TOWN_OR_CITY,
        l_add_rec.REQUEST_ID,
        l_add_rec.PROGRAM_APPLICATION_ID,
        l_add_rec.PROGRAM_ID,
        l_add_rec.PROGRAM_UPDATE_DATE,
        l_add_rec.ADDR_ATTRIBUTE_CATEGORY,
        l_add_rec.ADDR_ATTRIBUTE1,
        l_add_rec.ADDR_ATTRIBUTE2,
        l_add_rec.ADDR_ATTRIBUTE3,
        l_add_rec.ADDR_ATTRIBUTE4,
        l_add_rec.ADDR_ATTRIBUTE5,
        l_add_rec.ADDR_ATTRIBUTE6,
        l_add_rec.ADDR_ATTRIBUTE7,
        l_add_rec.ADDR_ATTRIBUTE8,
        l_add_rec.ADDR_ATTRIBUTE9,
        l_add_rec.ADDR_ATTRIBUTE10,
        l_add_rec.ADDR_ATTRIBUTE11,
        l_add_rec.ADDR_ATTRIBUTE12,
        l_add_rec.ADDR_ATTRIBUTE13,
        l_add_rec.ADDR_ATTRIBUTE14,
        l_add_rec.ADDR_ATTRIBUTE15,
        l_add_rec.ADDR_ATTRIBUTE16,
        l_add_rec.ADDR_ATTRIBUTE17,
        l_add_rec.ADDR_ATTRIBUTE18,
        l_add_rec.ADDR_ATTRIBUTE19,
        l_add_rec.ADDR_ATTRIBUTE20,
        NULL,                      -- Bug 9157658
        l_add_rec.LAST_UPDATED_BY,
        l_add_rec.LAST_UPDATE_LOGIN,
        l_add_rec.CREATED_BY,
        l_add_rec.CREATION_DATE,
        l_add_rec.OBJECT_VERSION_NUMBER,
        NULL,
        NULL,
        NULL,
        NULL,
        l_add_rec.ADD_INFORMATION13,
        l_add_rec.ADD_INFORMATION14,
        l_add_rec.ADD_INFORMATION15,
        l_add_rec.ADD_INFORMATION16
        ) ;

--      hr_utility.trace('Updated Addresses : ' ||
  --                          to_char(l_add_rec.address_id));

        get_insert_values(
                        'INDIANA_YEAR_BEGIN_ADDRESS',
                         l_add_rec.BUSINESS_GROUP_ID,
                         l_add_rec.PERSON_ID,
                         p_curr_year,
                         l_gre_name,
                         l_full_name,
                         l_employee_number
                         );

         put_into_temp_table(p_tax_unit_name => l_gre_name ,
                        p_emp_full_name => l_full_name ,
                        p_employee_number => l_employee_number,
                        p_effective_start_date => l_add_rec.DATE_FROM ,
            			p_town_or_city => l_add_rec.town_or_city,
                		p_region_1 => l_add_rec.region_1,
            			p_region_2 => l_add_rec.region_2,
            			p_postal_code => l_add_rec.postal_code,
            			p_add_information17 =>l_add_rec.add_information17,
            			p_add_information18 =>l_add_rec.add_information18,
            			p_add_information19 =>l_add_rec.add_information19,
			            p_add_information20 =>l_add_rec.add_information20,
                        p_error => l_error);
	COMMIT;
  end loop;
  close csr_get_add;
  /* Print the Indiana Address Report ' */

  print_report_address(errbuf, retcode);

  /* print_override_location(errbuf, retcode, p_curr_year, p_business_group); */

  print_override_location(errbuf, retcode, p_business_group,p_curr_year);

end;
end pay_us_indiana;

/
