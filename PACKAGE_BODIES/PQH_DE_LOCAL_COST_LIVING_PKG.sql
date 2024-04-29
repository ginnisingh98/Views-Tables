--------------------------------------------------------
--  DDL for Package Body PQH_DE_LOCAL_COST_LIVING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_LOCAL_COST_LIVING_PKG" as
/* $Header: pqhdeloc.pkb 120.0 2005/05/29 02:03:04 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Local cost of living Package
Purpose
	This package is used to calculate the amount for the Local cost of Living
        for german Public Sector.

History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      17-MAR-02  nsinghal     Created
*/
--
--
 Function local_cost_of_living
  (p_effective_date                         in      date
  ,p_business_group_id                      in      number
  ,p_ASSIGNMENT_ID                          in      number
  ,p_pay_grade                              in      varchar2
  ,p_Tariff_contract                        in      varchar2
  ,p_tariff_group                           in      varchar2
    )

  Return number  Is


-- cursor to get the Person_id for teh given Assignment_id

 cursor c_person_id (p_ASSIGNMENT_ID number,p_effective_date date) is
 select person_id from  PER_ALL_ASSIGNMENTS_F
 where ASSIGNMENT_ID = p_ASSIGNMENT_ID
 and p_effective_date between  EFFECTIVE_START_DATE and  nvl(EFFECTIVE_end_DATE,p_effective_date );


  -- cursor to get the alimony amount of  the Employee

  Cursor c_alimony_amount (P_person_id number,p_business_group_id  number,p_effective_date date) is
  select to_number(nvl(pcr.CONT_INFORMATION5,0))
          from per_contact_relationships pcr,
          per_all_people_f paf
  where paf.PERSON_ID = p_PERSON_ID
  and pcr.person_id = paf.person_id
  and pcr.CONT_INFORMATION1 = 'N'
  and pcr.CONT_INFORMATION4 = 'Y'
  and pcr.CONT_INFORMATION6 is  NULL
  and pcr.CONT_information_category ='DE_PQH'
  and pcr.contact_type = 'S'
  and paf.business_group_id = p_business_group_id
  and pcr.business_group_id = p_business_group_id
  and p_effective_date between  paf.EFFECTIVE_START_DATE    and nvl( paf.EFFECTIVE_end_DATE,p_effective_date ) ;

  -- cursor to get the sequence number of the child of the Employee

  Cursor c_seq_number (P_person_id number,p_business_group_id  number,p_effective_date date) is
  select to_number(nvl(pcr.CONT_INFORMATION6,0)) count1
          from per_contact_relationships pcr,
          per_all_people_f paf
  where paf.PERSON_ID = p_PERSON_ID
  and pcr.person_id = paf.person_id
  and pcr.CONT_INFORMATION1 = 'N'
  and pcr.CONT_INFORMATION4 = 'Y'
  and pcr.CONT_INFORMATION6 is not NULL
  and pcr.CONT_information_category ='DE_PQH'
  and pcr.contact_type in ('A','O','OC','T')
  and paf.business_group_id = p_business_group_id
  and pcr.business_group_id = p_business_group_id
  and p_effective_date between  paf.EFFECTIVE_START_DATE    and nvl( paf.EFFECTIVE_end_DATE   ,p_effective_date )
  ORDER BY COUNT1 ASC;

  -- cursor to get the Marital status of the Employee

  Cursor c_marital_status (P_person_id number,p_business_group_id number ,p_effective_date date) is
  select NVL(marital_status,'S') from per_all_people_f
  where PERSON_ID = p_PERSON_ID
  and   business_group_id = p_business_group_id
  AND   p_effective_date between  EFFECTIVE_START_DATE and nvl( EFFECTIVE_end_DATE,p_effective_date) ;

 -- cursor to get the grade_id of the required  Pay  grade of the Employee

  Cursor c_grade_id (p_pay_grade varchar2 ,p_business_group_id number,p_effective_date date) is
  select grade_id  from per_grades
  where name = p_pay_grade
  and business_group_id = p_business_group_id
  and p_effective_date between  DATE_from and nvl(DATE_to,p_effective_date ) ;

 -- cursor to get the tariff_class information having the amount to be given based on the Children amd the marital
 -- status of the Employee

 Cursor  c_tariff_class ( l_grade_id number ,p_tariff_group varchar2,p_effective_date date) is
 select
     pghn.information1,     -- Additional amount First  Child
     pghn.information2,     -- Additional amount Second Child
     pghn.information3,     -- Additional amount Further Child
     pghn.information4,     -- Amount if Single
     pghn.information5,     -- Amount if Married
     pghn.information6      -- Amount if Married and a child
    from   per_gen_hierarchy_nodes pghn,
           per_gen_hierarchy_versions pghv,
           per_gen_hierarchy_nodes pghn1,
           per_gen_hierarchy_nodes pghn2,
           per_gen_hierarchy pgh
    where  pgh.TYPE='LOCAL_COST_OF_LIVING'
           and pghv.HIERARCHY_ID=pgh.HIERARCHY_ID
           and pghn.HIERARCHY_VERSION_ID=pghv.HIERARCHY_VERSION_ID
           and p_effective_date between pghv.date_from and nvl(pghv.date_to, p_effective_date)
           and pghn.NODE_TYPE   ='TARIFF_CLASS'
           and pghn2.NODE_TYPE  ='LCOL_PAY_GRADES'
           and pghn1.NODE_TYPE ='TARIFF_GROUP'
           and pghn1.entity_id = p_tariff_group
           and pghn2.entity_id = l_grade_id
           and pghn1.PARENT_HIERARCHY_NODE_ID    =  pghn.HIERARCHY_NODE_ID
           and pghn2.PARENT_HIERARCHY_NODE_ID    =  pghn1.HIERARCHY_NODE_ID;

   l_information1 per_gen_hierarchy_nodes.INFORMATION1%type;
   l_information2 per_gen_hierarchy_nodes.INFORMATION2%type;
   l_information3 per_gen_hierarchy_nodes.INFORMATION3%type;
   l_information4 per_gen_hierarchy_nodes.INFORMATION4%type;
   l_information5 per_gen_hierarchy_nodes.INFORMATION5%type;
   l_information6 per_gen_hierarchy_nodes.INFORMATION6%type;
   l_sum_amount       number(15,2):=0.00;
   total              number(15,2)	:=0.00;
   n_further_count    number(15)	:=0;
   l_marital_status   varchar2(30);
   l_grade_id         number(15);
   l_alimony_amount per_gen_hierarchy_nodes.INFORMATION1%type;

   count_child  NUMBER(15):=0;

   p_person_id   NUMBER(10);

   g_package varchar2(30) := 'PQH_DE_LOCAL_COST_LIVING_PKG.';
   l_proc           varchar2(80) := g_package||'local_cost_of_living';


 BEGIN


    hr_utility.set_location('Entering '||l_proc,10);

    -- Cursor to get the grade id for the given pay Grade

       open c_person_id (p_ASSIGNMENT_ID ,p_effective_date );
            fetch c_person_id  into p_person_id ;
       close c_person_id ;

   hr_utility.set_location('Entering '||l_proc,20);


   -- Cursor to get the grade id for the given pay Grade

       open c_grade_id (p_pay_grade  ,p_business_group_id ,p_effective_date );
         fetch c_grade_id into l_grade_id;
       close c_grade_id;

    hr_utility.set_location('Entering '||l_proc,30);

       -- Cursor to get the additional amount information for the given pay Grade, tariff group in
       -- Hierarchy structure .

       open c_tariff_class (l_grade_id ,p_tariff_group ,p_effective_date);
          fetch c_tariff_class into
l_information1,l_information2,l_information3,l_information4,l_information5,l_information6;
       close c_tariff_class;

     hr_utility.set_location('Entering '||l_proc,30);

       -- Loop for calculation of additional amount

       For c_count in c_seq_number(P_person_id ,p_business_group_id ,p_effective_date)
	loop
  		if c_count.count1 = 1 then
                    total := Total + to_number(nvl(l_Information1,0)) ;
                 Elsif  c_count.count1  >= 2  then
                    total := Total + to_number(nvl(l_Information3,0)) ;
 	 	end if ;
                 count_child := count_child +1;
	end loop;

        hr_utility.set_location('Entering '||l_proc,40);

        -- End Loop for calculation of additional amount

        -- To get total amount of money to be paid based on number of Children.

	if count_child <= 2 then

        total := count_child * (to_number(nvl(l_Information6,0)) - to_number(nvl(l_Information5,0))) + Total;

	else

        total := 2 * (to_number(nvl(l_Information6,0)) - to_number(nvl(l_Information5,0))) + Total;

	total := (count_child - 2) * (to_number(nvl(l_Information2,0)) - to_number(nvl(l_Information5,0))) + Total;

	end if;

        -- Cursor to get the alimony amount paid by the employee

        open c_alimony_amount (P_person_id,p_business_group_id,p_effective_date);
            fetch c_alimony_amount into  l_alimony_amount;
        close c_alimony_amount;

        hr_utility.set_location('Entering '||l_proc,50);

        -- Cursor to get the Marital Status of the employee

        open c_marital_status (P_person_id,p_business_group_id,p_effective_date);
	 fetch c_marital_status into  l_marital_status;
        close c_marital_status;


        hr_utility.set_location('Entering '||l_proc,60);

         if  l_marital_status ='M' then
           l_sum_amount := l_sum_amount + Total + to_number(nvl(l_Information5,0)) - to_number(nvl(l_Information4,0)) ;
         elsif  l_marital_status ='S' then
           l_sum_amount := l_sum_amount + Total  ;
         elsif l_marital_status ='D' AND (c_alimony_amount%FOUND)  then
          l_sum_amount := l_sum_amount + Total + to_number(nvl(l_Information5,0)) - to_number(nvl(l_Information4,0)) ;
         else
          l_sum_amount := l_sum_amount + Total ;
           end if ;
         l_sum_amount := l_sum_amount + to_number(nvl(l_Information4,0));

         -- Return the Total amount to be paid to the Employee.

         return(l_sum_amount);

  END local_cost_of_living;

end PQH_DE_LOCAL_COST_LIVING_PKG;

/
