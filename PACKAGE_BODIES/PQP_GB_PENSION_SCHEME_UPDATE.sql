--------------------------------------------------------
--  DDL for Package Body PQP_GB_PENSION_SCHEME_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PENSION_SCHEME_UPDATE" AS
-- /* $Header: pqpgbschupd.pkb 120.0.12000000.1 2007/02/06 15:28:22 appldev noship $ */

  ----------------------------------------------------------------------------+
  --This procedure is called from concurrent program to update
  --Pension scheme type(of AVC elements) information held in element type eit
  ----------------------------------------------------------------------------+
  PROCEDURE process_scheme_type
              (errbuf                OUT NOCOPY  VARCHAR2
              ,retcode               OUT NOCOPY  VARCHAR2
              ,p_business_group_id   IN          NUMBER
              ,p_execution_mode      IN          VARCHAR2 ) is

   l_bg_name varchar2(80);
   PROGRAM_FAILURE     CONSTANT NUMBER := 2 ;
   PROGRAM_SUCCESS     CONSTANT NUMBER := 0 ;

        Procedure  print_details is
          --Procedure to Output AVC deduction element name
          --and its Pension scheme type
          Cursor csr_element_and_type is
             Select   petf.element_name,
                      pee.eei_information8 scheme_type
               From   pay_element_classifications pec,
                      pay_element_types_f petf,
                      pay_element_type_extra_info pee
               Where  pec.classification_name     ='Pre Tax Deductions'
                 and  pec.legislation_code='GB'
                 and  petf.classification_id      = pec.classification_id
                 and  sysdate between
                           petf.effective_start_date and petf.effective_end_date
                 and  petf.business_group_id      =p_business_group_id
                 and  pee.information_type        = 'PQP_GB_PENSION_SCHEME_INFO'
                 and  pee.eei_information_category= 'PQP_GB_PENSION_SCHEME_INFO'
                 and  pee.eei_information4        = 'AVC'
                 and petf.element_type_id         = pee.element_type_id
                 and  pee.eei_information12 is null;

        Begin    --print_details

          fnd_file.put_line(fnd_file.output,
                           'List of Existing Additional Voluntary Contribution'
                            ||' Elements and Their Pension Scheme Types: ');
          fnd_file.new_line(fnd_file.output,1);

          fnd_file.put_line(fnd_file.output,rpad('-',80,'-')
                                            ||'     '
                                            ||rpad('-',19,'-'));

          fnd_file.put_line(fnd_file.output,rpad('Element Name',80)
                                            ||'     '
                                            ||'Pension Scheme Type');

          fnd_file.put_line(fnd_file.output,rpad('-',80,'-')
                                            ||'     '
                                            ||rpad('-',19,'-'));

         --loop through the cursor
         --and print element name and its pension scheme type
          For i in  csr_element_and_type loop
           fnd_file.put_line(fnd_file.output,rpad(i.element_name,85,' ')
                                            ||i.scheme_type);

          End loop;
        End print_details ;

     Procedure update_scheme_type is
         --update element eit eei_information8 with
         --pension scheme type picked from lookup.
       Cursor csr_element_details is
       select petf.element_type_id,petf.element_name,
              upper(hr.description) description
         from hr_lookups hr,
              pay_element_types_f petf,
              pay_element_classifications pec
         where hr.lookup_type='PQP_GB_PENSION_SCHEME_UPDATE'
          and  hr.enabled_flag='Y'
          and  (upper(hr.description) in ('COMP','COSR')
                  or hr.description is null)
          and  petf.element_name = hr.meaning
          and  sysdate between --to restrict rows to 1
                        petf.effective_start_date and petf.effective_end_date
          and  petf.business_group_id=p_business_group_id
          and  petf.classification_id = pec.classification_id
          and  pec.classification_name='Pre Tax Deductions'
          and  pec.legislation_code='GB';

          type element_details_typ is table of  csr_element_details%rowtype
                                                index by binary_integer;
          element_details_tab element_details_typ;

      Begin --update_scheme_type

        fnd_file.put_line(fnd_file.output,
                       'List of Elements Updated with Pension Scheme Types: ');
        fnd_file.new_line(fnd_file.output,1);

        fnd_file.put_line(fnd_file.output,rpad('-',80,'-')
                                          ||'     '
                                          ||rpad('-',19,'-'));

        fnd_file.put_line(fnd_file.output,rpad('Element Name',80)
                                          ||'     '
                                          ||'Pension Scheme Type');

        fnd_file.put_line(fnd_file.output,rpad('-',80,'-')
                                          ||'     '
                                          ||rpad('-',19,'-'));


        Open  csr_element_details;
        Fetch csr_element_details Bulk Collect Into element_details_tab;
        Close csr_element_details;

        If element_details_tab.count>0 Then

         For i in element_details_tab.first..element_details_tab.last loop

         update pay_element_type_extra_info pee
            set  pee.eei_information8      = element_details_tab(i).description
          where  pee.element_type_id  = element_details_tab(i).element_type_id
            and  pee.information_type        = 'PQP_GB_PENSION_SCHEME_INFO'
            and  pee.eei_information_category= 'PQP_GB_PENSION_SCHEME_INFO'
            and  pee.eei_information4        = 'AVC'
            and  pee.eei_information12 is null;

         If(sql%rowcount>0) then
            fnd_file.put_line(fnd_file.output,
                           rpad(element_details_tab(i).element_name,85,' ')
                                ||element_details_tab(i).description);
         End If;
        End Loop;
       Else
           fnd_file.put_line(fnd_file.log,
                       'Element_details_tab.count : '||Element_details_tab.count
                             );
       End If;
      End Update_scheme_type;


     BEGIN  --process_scheme_type

       --write parameters  to log file
       fnd_file.put_line(fnd_file.log,
                         'Business Group id : '||p_business_group_id);
       fnd_file.put_line(fnd_file.log,'Execution Mode    : '||p_execution_mode);


      select  name
       into  l_bg_name
       from  per_business_groups_perf
       where business_group_id = p_business_group_id;


       fnd_file.put_line(fnd_file.output,'Business Group Name : '||l_bg_name);
       fnd_file.new_line(fnd_file.output,2);

       if    p_execution_mode ='PRINT'
         then
                  print_details;
       elsif p_execution_mode ='UPDATE'
         then
                 update_scheme_type;
       end if;


     retcode:=PROGRAM_SUCCESS;

     return;
     Exception
     When others then
          rollback;
          errbuf  := NULL;
          retcode := PROGRAM_FAILURE ;
          RAISE_APPLICATION_ERROR(-20001, SQLERRM);
     End process_scheme_type;
END PQP_GB_PENSION_SCHEME_UPDATE;


/
