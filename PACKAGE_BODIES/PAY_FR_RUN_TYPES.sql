--------------------------------------------------------
--  DDL for Package Body PAY_FR_RUN_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_RUN_TYPES" As
/* $Header: pyfrrunt.pkb 115.4 2004/04/15 02:21:24 autiwari noship $ */
g_package             Constant varchar2(30):= 'pay_fr_run_types';
g_called_from  Varchar2(18) := Null;
l_index                 Number := 0;
l_prod_flag             Boolean := True;
l_user_flag             Boolean := True;
--
Procedure element_run_types(p_element_type_id In Number
                           )
Is
l_proc                  varchar2(60) := g_package||'.element_run_types';
l_user_table_name       varchar2(30) := 'FR_RUN_TYPE_RULES';
l_rule_type             Varchar2(60) := Null;
l_rule                  Varchar2(10) := Null;
l_run_type              Varchar2(20) := Null;
l_run_type_id           Number;
l_element_type_usage_id	Number;
l_object_version_number	Number;
l_effective_start_date 	Date;
l_effective_end_date   	Date;
l_print_element_info    Varchar2(500);



Cursor csr_element_info(c_element_type_id Number) Is
  Select pet.element_type_id,
         pet.element_name,
         pec.classification_name,
         pet.business_group_id business_group_id,
         pet.legislation_code,
         pet.indirect_only_flag,
         min(pet.effective_start_date) effective_date
  From
         pay_element_types_f pet,
         pay_element_classifications pec,
         per_business_groups pbg
  Where
         pet.element_type_id = c_element_type_id
    and  pet.classification_id = pec.classification_id
    and  nvl(pet.business_group_id,pbg.business_group_id) = pbg.business_group_id
    and  nvl(pet.legislation_code,pbg.legislation_code) = 'FR'
  Group By
         pet.element_type_id,
         pet.element_name,
	 pec.classification_name,
	 pet.business_group_id,
	 pet.legislation_code,
         pet.indirect_only_flag;


Cursor csr_row_id(c_element_name Varchar2,c_classification_name Varchar2,csr_effective_date date) Is
select pur.row_low_range_or_name row_id,puci.value
from pay_user_tables put
,    pay_user_rows_f pur
,    pay_user_columns puc
,    pay_user_column_instances_f puci
,    pay_user_columns puc_rule_type
,    pay_user_column_instances_f puci_rule_type
where put.user_table_name = 'FR_RUN_TYPE_RULES'
and   put.legislation_code = 'FR'
and   put.business_group_id is null
and   puc.user_table_id = put.user_table_id
and   puc.user_column_name = 'ID'
and   pur.user_table_id = put.user_table_id
and   csr_effective_date
      between pur.effective_start_date and pur.effective_end_date
and   puci.user_column_id = puc.user_column_id
and   puci.user_row_id = pur.user_row_id
and   puci.value in (c_element_name , c_classification_name)
and   csr_effective_date
      between puci.effective_start_date and puci.effective_end_date
and   puc_rule_type.user_table_id = put.user_table_id
and   puc_rule_type.user_column_name = 'Rule Type'
and   puci_rule_type.user_column_id = puc_rule_type.user_column_id
and   puci_rule_type.user_row_id = pur.user_row_id
and   csr_effective_date
      between puci_rule_type.effective_start_date and puci_rule_type.effective_end_date
order by puci_rule_type.value;
--
Cursor get_usage_info(c_run_type Varchar2) Is
Select etu.element_type_usage_id
	      ,etu.effective_start_date effective_date
	      ,etu.object_version_number
	      ,etu.business_group_id
	      ,etu.legislation_code
	  From pay_element_type_usages_f etu
	      ,pay_run_types_f rt
	 Where rt.legislation_code = 'FR'
	   And rt.shortname = c_run_type
	   And etu.run_type_id = rt.run_type_id
	   And etu.element_type_id = p_element_type_id;


l_element_info csr_element_info%ROWTYPE;
l_row_id csr_row_id%ROWTYPE;
l_run_type_usage_rec get_usage_info%ROWTYPE;
        --

	Function get_run_type_id(p_run_type varchar2,p_legislation_code varchar2)
	Return Number
	Is

	Cursor csr_run_type_id Is
	  Select run_type_id
	    From pay_run_types_f
	    Where shortname = p_run_type
	      and legislation_code = p_legislation_code;

        l_run_type_id pay_run_types.run_type_id%TYPE;

	Begin

        Open csr_run_type_id ;
        Fetch csr_run_type_id into l_run_type_id;
        Close csr_run_type_id;

        Return l_run_type_id;

        End get_run_type_id;

        --


        Function get_table_value (p_bus_group_id      in number,
	                          p_table_name        in varchar2,
	                          p_col_name          in varchar2,
	                          p_row_value         in varchar2,
	                          p_effective_date    in date )
	Return varchar2 is

	l_value pay_user_column_instances_f.value%TYPE;

	Cursor csr_get_table_value Is
	       Select puci.value
	       From   pay_user_tables put
	             ,pay_user_rows_f pur
	             ,pay_user_columns puc
	             ,pay_user_column_instances_f  puci
	       Where  put.user_table_name = p_table_name
	         and  put.legislation_code = 'FR'
	         and  put.business_group_id Is Null
	         and  put.user_table_id = pur.user_table_id
	         and  pur.row_low_range_or_name = p_row_value
	         and  ((pur.legislation_code = 'FR'and pur.business_group_id Is Null)
	               or
	               (pur.legislation_code Is Null and pur.business_group_id =p_bus_group_id))
	         and  p_effective_date Between pur.effective_start_date And pur.effective_end_date
	         and  puc.user_table_id = put.user_table_id
	         and  puc.user_column_name = p_col_name
	         and  puc.legislation_code = 'FR'
	       	 and  puc.business_group_id Is Null
	       	 and  puci.user_row_id  = pur.user_row_id
	         and  puci.user_column_id  = puc.user_column_id
	         and  p_effective_date Between puci.effective_start_date And puci.effective_end_date;



	Begin

	Open csr_get_table_value;
	Fetch csr_get_table_value Into l_value;
	Close csr_get_table_value;

	Return l_value;

        End get_table_value;





Begin
hr_utility.set_location('Entering ' || l_proc,10);
Open csr_element_info(p_element_type_id);
Fetch csr_element_info into l_element_info;
Close csr_element_info;

--Check For indirect only flag
--If 'Y' don't Maintain usages
If l_element_info.indirect_only_flag = 'N' Then
  --

  IF l_element_info.legislation_code IS NOT NULL THEN
    hr_startup_data_api_support.enable_startup_mode('STARTUP');

    If l_prod_flag Then
	  l_prod_flag := False;
	  hr_startup_data_api_support.create_owner_definition('PER');
	  hr_startup_data_api_support.create_owner_definition('PAY');
    End If;

  ELSE
    hr_startup_data_api_support.enable_startup_mode('USER');
  END IF;


  --
  For l_row_id  In csr_row_id(l_element_info.element_name,l_element_info.classification_name,l_element_info.effective_date) Loop


  Begin
    l_rule_type := get_table_value(  p_bus_group_id    => l_element_info.business_group_id
		 		    ,p_table_name      =>l_user_table_name
                                    ,p_col_name        =>'Rule Type'
				    ,p_row_value       =>l_row_id.row_id
                                    ,p_effective_date  =>l_element_info.effective_date
                                    );
  Exception
     When Others Then
        Null;
  End;

  If l_rule_type = 'ELEMENT' Then
    l_rule :=get_table_value(  p_bus_group_id    =>l_element_info.business_group_id
			      ,p_table_name      =>l_user_table_name
                              ,p_col_name        =>'Rule'
			      ,p_row_value       =>l_row_id.row_id
                              ,p_effective_date  =>l_element_info.effective_date
                             );

    If l_rule = 'EXCLUDE' Then

       l_run_type := get_table_value( p_bus_group_id    =>l_element_info.business_group_id
		                    ,p_table_name      =>l_user_table_name
                                    ,p_col_name        =>'Run Type'
		                    ,p_row_value       =>l_row_id.row_id
                                    ,p_effective_date  =>l_element_info.effective_date
                                  );

       l_run_type_id := get_run_type_id(l_run_type,'FR');

       hr_utility.set_location('Creating Run Type Usage for Element'||l_element_info.element_name||' '||l_proc,20);

       Begin

	 pay_element_type_usage_api.create_element_type_usage(
							     p_effective_date        => l_element_info.effective_date
							    ,p_run_type_id           => l_run_type_id
							    ,p_element_type_id       => p_element_type_id
							    ,p_business_group_id     => l_element_info.business_group_id
							    ,p_legislation_code      => l_element_info.legislation_code
							    ,p_element_type_usage_id => l_element_type_usage_id
							    ,p_object_version_number => l_object_version_number
							    ,p_effective_start_date  => l_effective_start_date
							    ,p_effective_end_date    =>	l_effective_end_date
      						          );
         If g_called_from = 'Concurrent_Program' Then
         l_index := l_index + 1;

         l_print_element_info:= rpad(nvl(to_char(l_index),' '),3)||'  '||
         			rpad(nvl(l_element_info.element_name,' '),45)||'  '||
                                rpad(nvl(l_element_info.classification_name,' '),20)||'  '||
                                rpad(nvl(l_run_type,' '),10)||'  '||
      			        rpad(nvl(to_char(l_element_info.business_group_id),' ') ,17)||'  '||
      				rpad(nvl(l_element_info.legislation_code,' '),16)|| '  '||
      				rpad('Exclude',7);

         Fnd_file.put_line(FND_FILE.OUTPUT,l_print_element_info);
         End If;
       Exception
         When Others then
         If g_called_from = 'Concurrent_Program' Then
           l_index := l_index + 1;
           l_print_element_info:= rpad(nvl(to_char(l_index),' '),3)||'  '||
       			      rpad(nvl(l_element_info.element_name,' '),45)||'  '||
                              rpad(nvl(l_element_info.classification_name,' '),20)||'  '||
                              rpad(nvl(l_run_type,' '),10)||'  '||
                              rpad(nvl(to_char(l_element_info.business_group_id),' ') ,17)||'  '||
                              rpad(nvl(l_element_info.legislation_code,' '),16)|| '  '||
      			      rpad('Invalid',7);
           Fnd_file.put_line(FND_FILE.OUTPUT,l_print_element_info);
         End If;
       End;


    Elsif l_rule = 'INCLUDE' Then
       l_run_type := get_table_value( p_bus_group_id    =>l_element_info.business_group_id
			             ,p_table_name      =>l_user_table_name
	                             ,p_col_name        =>'Run Type'
			             ,p_row_value       =>l_row_id.row_id
	                             ,p_effective_date  =>l_element_info.effective_date
                                  );

       Open get_usage_info(l_run_type);
       Fetch get_usage_info Into l_run_type_usage_rec;

       If get_usage_info%FOUND Then
         pay_element_type_usage_api.delete_element_type_usage( p_validate                =>null
   							    ,p_effective_date          =>l_run_type_usage_rec.effective_date
   							    ,p_datetrack_delete_mode   =>'ZAP'
   							    ,p_element_type_usage_id   =>l_run_type_usage_rec.element_type_usage_id
   							    ,p_object_version_number   =>l_run_type_usage_rec.object_version_number
   							    ,p_business_group_id       =>l_run_type_usage_rec.business_group_id
   							    ,p_legislation_code        =>l_run_type_usage_rec.legislation_code
   							    ,p_effective_start_date    =>l_effective_start_date
   							    ,p_effective_end_date	=>l_effective_end_date
   							  );
       End If;
       Close get_usage_info;

       If g_called_from = 'Concurrent_Program' Then
         l_index := l_index + 1;

         l_print_element_info:= rpad(nvl(to_char(l_index),' '),3)||'  '||
         			rpad(nvl(l_element_info.element_name,' '),45)||'  '||
                                rpad(nvl(l_element_info.classification_name,' '),20)||'  '||
                                rpad(nvl(l_run_type,' '),10)||'  '||
      			        rpad(nvl(to_char(l_element_info.business_group_id),' ') ,17)||'  '||
      				rpad(nvl(l_element_info.legislation_code,' '),16)|| '  '||
      				rpad('Include',7);

         Fnd_file.put_line(FND_FILE.OUTPUT,l_print_element_info);

        End If;

    End If;  -- l_rule (INCLUDE/EXCLUDE)


Else  -- l_rule_type IS NOT ELEMENT
  Begin
    l_rule_type :=get_table_value( p_bus_group_id        =>l_element_info.business_group_id
     		                  ,p_table_name          =>l_user_table_name
                                  ,p_col_name            =>'Rule Type'
     		                  ,p_row_value           =>l_row_id.row_id
                                  ,p_effective_date      =>l_element_info.effective_date
                                 );
  Exception
     When Others Then
     Null;
  End;

  IF l_rule_type = 'CLASSIFICATION' Then
     l_rule :=get_table_value(    p_bus_group_id    =>l_element_info.business_group_id
   	      			 ,p_table_name      =>l_user_table_name
                 	         ,p_col_name        =>'Rule'
   		  		 ,p_row_value       =>l_row_id.row_id
                 		 ,p_effective_date  =>l_element_info.effective_date
                );

    If l_rule = 'EXCLUDE' Then

      l_run_type := get_table_value( p_bus_group_id     =>l_element_info.business_group_id
  	   	                   ,p_table_name      =>l_user_table_name
           	                   ,p_col_name        =>'Run Type'
   	   		           ,p_row_value       =>l_row_id.row_id
           	                   ,p_effective_date  =>l_element_info.effective_date
                                );

      l_run_type_id := get_run_type_id(l_run_type,'FR');

       hr_utility.set_location('Creating Usage for Element '||l_element_info.element_name||' '||l_proc,30);

      Begin

       pay_element_type_usage_api.create_element_type_usage(
   							     p_effective_date        => l_element_info.effective_date
   							    ,p_run_type_id           => l_run_type_id
   							    ,p_element_type_id       => p_element_type_id
   							    ,p_business_group_id     => l_element_info.business_group_id
   							    ,p_legislation_code      => l_element_info.legislation_code
   							    ,p_element_type_usage_id => l_element_type_usage_id
   							    ,p_object_version_number => l_object_version_number
   							    ,p_effective_start_date  => l_effective_start_date
   							    ,p_effective_end_date    =>	l_effective_end_date
   							  );

       If g_called_from = 'Concurrent_Program' Then
         l_index := l_index + 1;

         l_print_element_info:= rpad(nvl(to_char(l_index),' '),3)||'  '||
    			rpad(nvl(l_element_info.element_name,' '),45)||'  '||
                           rpad(nvl(l_element_info.classification_name,' '),20)||'  '||
                           rpad(nvl(l_run_type,' '),10)||'  '||
  			        rpad(nvl(to_char(l_element_info.business_group_id),' '),17)||'  '||
  				rpad(nvl(l_element_info.legislation_code,' '),16)|| '  '||
  				rpad('Exclude',7);

          Fnd_file.put_line(FND_FILE.OUTPUT,l_print_element_info);
       End If;



      Exception
        When Others Then

         If g_called_from = 'Concurrent_Program' Then
           l_index := l_index + 1;

           l_print_element_info:= rpad(nvl(to_char(l_index),' '),3)||'  '||
      			      rpad(nvl(l_element_info.element_name,' '),45)||'  '||
                             rpad(nvl(l_element_info.classification_name,' '),20)||'  '||
                             rpad(nvl(l_run_type,' '),10)||'  '||
                             rpad(nvl(to_char(l_element_info.business_group_id),' ') ,17)||'  '||
                             rpad(nvl(l_element_info.legislation_code,' '),16)|| '  '||
      		              rpad('Invalid',7);
           Fnd_file.put_line(FND_FILE.OUTPUT,l_print_element_info);
         End If;
       End;
     End IF;--If l_rule = 'EXCLUDE'
   End If; --IF l_rule_type = 'CLASSIFICATION'


  End If;  -- IF Direct Elements only
 End Loop;


End If;

End element_run_types;


--
Procedure rebuild_run_types(errbuf  out nocopy Varchar2,
                            retcode out nocopy Varchar2
                           )
Is

l_proc varchar2(60) := g_package||'.rebuild_run_types';

Cursor csr_run_type_usage_all Is
	Select etu.element_type_usage_id
	      ,etu.effective_start_date effective_date
	      ,etu.object_version_number
	      ,etu.business_group_id
	      ,etu.legislation_code
	  From pay_element_type_usages_f etu
	      ,pay_run_types_f rt
	 Where rt.legislation_code = 'FR'
	   And rt.shortname In ('STANDARD', 'NET', 'SICKNESS')
	   And etu.run_type_id = rt.run_type_id;

Cursor csr_element_all Is
	Select  pet.element_type_id
	       ,pet.element_name
	       ,pet.business_group_id
	       ,pet.legislation_code
	       ,Min(pet.effective_start_date) effective_date
	   From pay_element_types_f pet
	       ,per_business_groups pbg
	  Where Nvl(pet.indirect_only_flag, 'N') = 'N'
	    And pbg.business_group_id = pet.business_group_id
	    And pbg.legislation_code = 'FR'
	    And pet.legislation_code Is Null
	 Group By pet.element_type_id,
	          pet.element_name,
	          pet.business_group_id,
	          pet.legislation_code
	union all
	Select  pet.element_type_id
	       ,pet.element_name
	       ,pet.business_group_id
	       ,pet.legislation_code
	       ,Min(pet.effective_start_date) effective_date
	   From pay_element_types_f pet
	  Where Nvl(pet.indirect_only_flag, 'N') = 'N'
	    And pet.legislation_code   = 'FR'
	    And pet.business_group_id Is Null
	  Group By pet.element_type_id,
	          pet.element_name,
	          pet.business_group_id,
                  pet.legislation_code ;


l_run_type_usage_rec csr_run_type_usage_all%ROWTYPE;
l_element_rec  csr_element_all%ROWTYPE;
l_effective_start_date Date;
l_effective_end_date   Date;
l_header Varchar2(500);
l_underline Varchar2(500);


Begin
--hr_utility.trace_on(null ,'PAY_FR_RUN_TYPES');

If g_called_from IS Null Then

g_called_from := 'Concurrent_Program';

End If;
If g_called_from = 'Concurrent_Program' Then

l_header :=   rpad('No',3)||'  '||
	      rpad('Element',45)||'  '||
              rpad('Classification',20)||'  '||
              rpad('Run Type',10)||'  '||
              rpad('Business Group Id',17)||'  '||
              rpad('Legislation Code',16)|| '  '||
              rpad('Status',7);

l_underline :=rpad('-',03,'-')||'  '||
  	      rpad('-',45,'-')||'  '||
              rpad('-',20,'-')||'  '||
              rpad('-',10,'-')||'  '||
              rpad('-',17,'-')||'  '||
              rpad('-',16,'-')||'  '||
              rpad('-',07,'-');

Fnd_File.New_Line(FND_FILE.OUTPUT,1);
Fnd_file.put_line(FND_FILE.OUTPUT,'Rebuilt Element Exclusions (France)');
Fnd_File.New_Line(FND_FILE.OUTPUT,1);
Fnd_file.put_line(FND_FILE.OUTPUT,l_header);
Fnd_file.put_line(FND_FILE.OUTPUT,l_underline);

End If;

Fnd_file.put_line(FND_FILE.OUTPUT,'Deleting Usages');
	--1.Delete all existing usages

	For l_run_type_usage_rec In  csr_run_type_usage_all Loop

		hr_utility.set_location('Deleting run type usage '||l_proc,10);

		If l_run_type_usage_rec.legislation_code Is Null
		Then
		hr_startup_data_api_support.enable_startup_mode('USER');
		ElsIF l_run_type_usage_rec.business_group_id Is Null Then
		hr_startup_data_api_support.enable_startup_mode('STARTUP');
		End If;

		pay_element_type_usage_api.delete_element_type_usage( p_validate                =>null
								     ,p_effective_date          =>l_run_type_usage_rec.effective_date
								     ,p_datetrack_delete_mode   =>'ZAP'
								     ,p_element_type_usage_id   =>l_run_type_usage_rec.element_type_usage_id
								     ,p_object_version_number   =>l_run_type_usage_rec.object_version_number
								     ,p_business_group_id       =>l_run_type_usage_rec.business_group_id
								     ,p_legislation_code        =>l_run_type_usage_rec.legislation_code
								     ,p_effective_start_date    =>l_effective_start_date
								     ,p_effective_end_date	=>l_effective_end_date
								     );

	End Loop;


	--2.Create fresh run type usages

	For l_element_rec In csr_element_all Loop
                 hr_utility.set_location('Creating run type usage For Element '||l_element_rec.element_name||l_proc,20);

		 element_run_types( p_element_type_id => l_element_rec.element_type_id
				  );

	End Loop;



End rebuild_run_types;

Procedure rebuild_run_types IS

l_errbuf varchar2(1000);
l_retcode varchar2(500);

Begin
g_called_from := 'Hrglobal';
          rebuild_run_types( errbuf               =>l_errbuf
                            ,retcode              =>l_retcode
                           );

End rebuild_run_types;

--
End pay_fr_run_types;


/
