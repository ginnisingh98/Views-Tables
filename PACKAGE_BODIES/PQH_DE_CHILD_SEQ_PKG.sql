--------------------------------------------------------
--  DDL for Package Body PQH_DE_CHILD_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_CHILD_SEQ_PKG" as
/* $Header: pqhdeseq.pkb 120.0 2005/05/29 02:03:15 appldev noship $ */
/*---------------------------------------------------------------------------------------------+
                            Procedure REGENERATE_SEQ_NUM
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to run as a concurrent program that generates  Sequence Numbers
  for children of Employees in German Public Sector. The processing is as follows
   1. Find all employess in the bussiness group who want the sequence number of their children
      to be automatically generated.
   2. For each such employee find out all the children(contacts) in order of date of birth
   3. Assigns sequence number 1 to first child, 2 to second child and so on. However a child
      is eligable for a sequence number if and only if the child satisfies certain rules on
      age,qualification,disability and military/civilian service.
   4.Update the child contact to insert the new sequence number.

 In Parameters:
   1. Business Group ID
   2. Effective Date

 Post Success:
      Updates the child contact record to insert the new sequence number.

 Post Failure:

 Developer Implementation Notes:
   1. Cursor C_Emp_In_Business_Grp finds all Employees in the Business Group who want child
      sequence number to be auto generated.
   2. Cursor C_Emp_Children finds all the chldren of a employee in the Business Group in the order of Date of Birth.
   3. Cursor C_Children_Disability finds Disability information of a Person(Child)
   4. Cursor C_Children_Qualification finds Qualification details of a Person(Child)
   5. Cursor C_Child_Military_Info finds Military Service/ Civil Service info of the Person(Child)
   6. The procedure PER_CONTACT_RELATIONSHIPS_PKG.Update_Row updates the Child Contact record in
      PER_CONTACT_RELATIONSHIPS to change the Sequence Number.

-------------------------------------------------------------------------------------------------*/

PROCEDURE REGENERATE_SEQ_NUM(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER, pBusiness_grp_id IN NUMBER, pEffective_date IN VARCHAR2) is

lBusiness_group_id HR_ALL_ORGANIZATION_UNITS.BUSINESS_GROUP_ID%type;
cSeq number(2);
c_Age number;
--l_api_ovn  number;
update_flag boolean;
l_session_date date;

                               --Given Business Group name find business group id

CURSOR C_B_Grp(pBusiness_grp_name varchar) is
	select BUSINESS_GROUP_ID
	from HR_ALL_ORGANIZATION_UNITS
 	where name=pBusiness_grp_name;




				 --Find all Employees in the Business Group with auto seq yes
CURSOR C_Emp_In_Business_Grp(lBusiness_group_id number) is
	select pap.PERSON_ID,
	       pap.EFFECTIVE_START_DATE,
               pap.EFFECTIVE_END_DATE
        from PER_ALL_PEOPLE_F pap,
	     PER_PERSON_TYPES ppt,
	     PER_PEOPLE_EXTRA_INFO pei
	where
	      pap.BUSINESS_GROUP_ID=lBusiness_group_id
	and   pap.person_type_id=ppt.person_type_id
	and   ppt.SYSTEM_PERSON_TYPE='EMP'
	and   pap.EFFECTIVE_START_DATE <= l_session_date
	and   pap.EFFECTIVE_END_DATE >= l_session_date
	and   pei.PERSON_ID=pap.PERSON_ID
	and   pei.PEI_INFORMATION_CATEGORY='DE_PQH_AUTO_SEQUENCE'
	and   nvl(pei.pei_information1,'Y')='Y';


                              --Given Person_id and business group find all children of the person
CURSOR C_Emp_Children(lBusiness_group_id number,
			      lPERSON_ID number,
		      lEFFECTIVE_START_DATE date,
		      lEFFECTIVE_END_DATE date) is
	select 	     pap.PERSON_ID CHILD_ID,
		     pap.EFFECTIVE_START_DATE,
		     pap.EFFECTIVE_END_DATE,
		     pap.DATE_OF_BIRTH,
		     pap.REGISTERED_DISABLED_FLAG,
		     pcr.Rowid,
		     pcr.Contact_Relationship_Id,
		     pcr.Business_Group_Id,
		     pcr.Person_Id,
		     pcr.Contact_Person_Id,
		     pcr.Contact_Type,
		     pcr.Comments,
		     pcr.Bondholder_Flag,
		     pcr.Third_Party_Pay_Flag,
		     pcr.Primary_Contact_Flag,
		     pcr.Cont_Attribute_Category,
		     pcr.Cont_Attribute1,
		     pcr.Cont_Attribute2,
		     pcr.Cont_Attribute3,
		     pcr.Cont_Attribute4,
		     pcr.Cont_Attribute5,
		     pcr.Cont_Attribute6,
		     pcr.Cont_Attribute7 ,
		     pcr.Cont_Attribute8 ,
		     pcr.Cont_Attribute9,
		     pcr.Cont_Attribute10,
		     pcr.Cont_Attribute11,
		     pcr.Cont_Attribute12,
		     pcr.Cont_Attribute13,
		     pcr.Cont_Attribute14,
		     pcr.Cont_Attribute15,
		     pcr.Cont_Attribute16,
		     pcr.Cont_Attribute17,
		     pcr.Cont_Attribute18,
		     pcr.Cont_Attribute19,
		     pcr.Cont_Attribute20,
		     pcr.Cont_Information_Category,
		     pcr.Cont_Information1,
		     pcr.Cont_Information2,
		     pcr.Cont_Information3,
		     pcr.Cont_Information4,
		     pcr.Cont_Information5,
		     pcr.Cont_Information6,
		     pcr.Cont_Information7,
		     pcr.Cont_Information8,
		     pcr.Cont_Information9,
		     pcr.Cont_Information10,
		     pcr.Cont_Information11,
		     pcr.Cont_Information12,
		     pcr.Cont_Information13,
		     pcr.Cont_Information14,
		     pcr.Cont_Information15,
		     pcr.Cont_Information16,
		     pcr.Cont_Information17,
		     pcr.Cont_Information18,
		     pcr.Cont_Information19,
		     pcr.Cont_Information20,
		     pcr.Date_Start,
		     pcr.Start_Life_Reason_Id,
		     pcr.Date_End,
		     pcr.End_Life_Reason_Id,
		     pcr.Rltd_Per_Rsds_W_Dsgntr_Flag,
		     pcr.Personal_Flag,
		     pcr.Sequence_Number,
		     pcr.Dependent_Flag,
		     pcr.Beneficiary_Flag,
		     pei.pei_information1,
		     pei.pei_information2,
		     pei.pei_information3

from    PER_CONTACT_RELATIONSHIPS pcr,
        PER_PEOPLE_F pap,
        PER_PEOPLE_EXTRA_INFO pei
where
pcr.Contact_Relationship_Id in
       (select
        xpcr.Contact_Relationship_Id
        from    PER_CONTACT_RELATIONSHIPS xpcr,
                PER_ALL_PEOPLE_F xpap
        where   xpcr.BUSINESS_GROUP_ID=lBusiness_group_id
        and     xpcr.PERSON_ID=xpap.PERSON_ID
        and     xpap.PERSON_ID=lPerson_id
        and     nvl(xpcr.DATE_START,l_session_date) <= l_session_date
        and     nvl(xpcr.DATE_END,l_session_date)   >= l_session_date
        and     xpcr.CONTACT_TYPE IN ('A','O','OC','T')
        and     xpap.EFFECTIVE_START_DATE = lEffective_Start_Date
        and     xpap.EFFECTIVE_END_DATE   = lEffective_End_Date
  )
and     pap.PERSON_ID = pcr.CONTACT_PERSON_ID
and     pcr.PERSON_ID = pei.PERSON_ID (+)
and     pei.PEI_INFORMATION_CATEGORY (+)='DE_PQH_CHILD_DETAILS'
and 	l_session_date between nvl(fnd_date.canonical_to_date(pei.pei_information4), l_session_date)
	and nvl(fnd_date.canonical_to_date(pei.pei_information5), l_session_date)
order by nvl(pap.DATE_OF_BIRTH,l_session_date);

			                  --Select disability status of a person

CURSOR C_Children_Disability(lBusiness_group_id number,lPERSON_ID number,Date_of_Birth date) is
	select pdf.DISABILITY_ID,
	       pdf.CATEGORY,
	       pdf.STATUS

	from PER_DISABILITIES_V pdf
	where 	pdf.PERSON_ID=lPERSON_ID
	and     pdf.BUSINESS_GROUP_ID=lBusiness_group_id
	and   	pdf.EFFECTIVE_START_DATE <= l_session_date
	and   	pdf.EFFECTIVE_END_DATE >=  l_session_date
        and     STATUS in ('A','APP')
        and     (months_between(pdf.REGISTRATION_DATE,Date_of_Birth)/12) <=27;


CURSOR C_Child_Military_Info(lBusiness_group_id number,
			      lCHILD_ID number,
			      lEFFECTIVE_START_DATE date,
			      lEFFECTIVE_END_DATE date) is
	select     pap.PERSON_ID,
           	   pei.person_extra_info_id,
		   pei.pei_information_category,
		   pei.pei_information1,       --Start Date
		   pei.pei_information2,       --End Date
		   pei.pei_information3,       --Type of Service
		   pei.pei_information4        --Certificate Presented
	from       PER_ALL_PEOPLE_F pap,
		   PER_PEOPLE_EXTRA_INFO pei
	where
	           pap.BUSINESS_GROUP_ID=lBusiness_group_id
	     and   pap.PERSON_ID= lCHILD_ID
 	     and   pei.PERSON_ID=pap.PERSON_ID
	     and   pei.PEI_INFORMATION_CATEGORY='DE_MILITARY_SERVICE'	  --German Public Sector Child Military Deatails
             and   pap.EFFECTIVE_START_DATE = lEFFECTIVE_START_DATE
             and   pap.EFFECTIVE_END_DATE   = lEFFECTIVE_END_DATE;

CURSOR C_Children_Qualification(lBusiness_group_id number,lPERSON_ID number, Date_of_Birth date) is
	select
           pq.PERSON_ID,
           pq.QUALIFICATION_ID,
	   pq.QUA_INFORMATION1,
	   pq.START_DATE,
	   pq.END_DATE
	from per_qualifications pq
	where pq.BUSINESS_GROUP_ID=lBusiness_group_id
	      and pq.PERSON_ID=lPERSON_ID
	      and pq.START_DATE is not null
              and pq.END_DATE   is not null
              and (months_between(pq.START_DATE ,Date_of_Birth)/12) <27
	      and pq.QUA_INFORMATION1='Y'                                -- Certificates Presented
	      and (
	             (
	               ((months_between(pq.END_DATE ,Date_of_Birth)/12) >21)
	                  and exists
                              (select  xpq.QUALIFICATION_ID
	                      from per_qualifications xpq
	                      where
	                      xpq.BUSINESS_GROUP_ID=lBusiness_group_id
	                      and xpq.PERSON_ID=pq.PERSON_ID
	                      and months_between(pq.END_DATE,xpq.START_DATE)<=4
	                      )
	              )
	          OR  (pq.END_DATE>=l_session_date and (months_between(pq.START_DATE ,Date_of_Birth)/12) <21)
	      );



c_Child_Mil C_Child_Military_Info%rowtype;
c_Child_Qua C_Children_Qualification%rowtype;
c_Dis_Cur C_Children_Disability%rowtype;


Begin
savepoint PQH_DE_SEQ_NUM;
--select effective_date into l_session_date from fnd_sessions where session_id=userenv('sessionid');
--OPEN C_B_Grp(pBusiness_grp_name);
--fetch C_B_grp into lBusiness_group_id;
lBusiness_group_id :=pBusiness_grp_id;

l_session_date := fnd_date.canonical_to_date(pEffective_date);

--l_session_date :=  to_date(pEffective_date, 'RRRR/MM/DD HH24:MI:SS');
--l_session_date := to_date(to_char(trunc(l_session_date), 'DD/MM/RRRR'),'DD/MM/RRRR');

FOR C1 in C_Emp_In_Business_Grp(lBusiness_group_id)
LOOP
   cSeq:=0;
   FOR C2 in C_Emp_Children(lBusiness_group_id, C1.PERSON_id, C1.EFFECTIVE_START_DATE, C1.EFFECTIVE_END_DATE)
   LOOP
      update_flag := false;
      if (C2.DATE_OF_BIRTH is not null
          and C2.CONT_INFORMATION1='N'  --Not Entitled for some body else
          and C2.CONT_INFORMATION4='Y'  --Elligible for local cost of living allowance
         )
      then
        OPEN C_Children_Disability(lBusiness_group_id,C2.CHILD_ID,C2.DATE_OF_BIRTH);
	      			FETCH C_Children_Disability into c_Dis_Cur;

	OPEN C_Child_Military_Info(lBusiness_group_id, C2.CHILD_ID, C2.EFFECTIVE_START_DATE, C2.EFFECTIVE_END_DATE);
	      			FETCH C_Child_Military_Info into c_Child_Mil;

	OPEN C_Children_Qualification(lBusiness_group_id, C2.CHILD_ID,C2.DATE_OF_BIRTH);
			FETCH C_Children_Qualification into c_Child_Qua;
       c_Age := floor(months_between(l_session_date,last_day(C2.DATE_OF_BIRTH))/12);
       if c_Age >= 18               -- if age is greater than 18 years then do the following
       then

         if (C2.PEI_INFORMATION1 ='N')                 -- Child is Unemployed
           then
           if
            (                             --Child  age less than 21
	      ( c_Age < 21)
	      or              -- or Child is Unemployed and has done militaty service and less than 21 +period of service
	      (C_Child_Military_Info%FOUND and c_Child_Mil.PEI_INFORMATION3 ='M' and c_Child_Mil.PEI_INFORMATION4 ='Y'
               and c_Age < (21 + months_between(fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION2),fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION1))/12)
              )
              or    -- or Child is Unemployed and has done civil service and less than 21 +period of sevice+1 month
              (C_Child_Military_Info%FOUND  and c_Child_Mil.PEI_INFORMATION3 ='C' and c_Child_Mil.PEI_INFORMATION4 ='Y'
	       and  c_Age < (21 + (1+months_between(fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION2),fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION1)))/12)
	      )
	      or
	      ( C_Children_Qualification%FOUND )
	      or
	      (C_Children_Disability%FOUND)
            )
              then
                 cSeq:=cSeq+1;
                 update_flag := true;
            end if;
         elsif (nvl(to_number(C2.PEI_INFORMATION3),0) < 14040  )
           then
              if
           (                             --Child  age less than 21
     	      ( c_Age < 21)
      	      or              -- or Child is Unemployed and has done militaty service and less than 22 +period of service
      	      (C_Child_Military_Info%FOUND and c_Child_Mil.PEI_INFORMATION3 ='M' and c_Child_Mil.PEI_INFORMATION4 ='Y'
                     and c_Age < (21 + months_between(fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION2),fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION1))/12)
              )
              or    -- or Child is Unemployed and has done civil service and less than 22 +period of sevice+1 month
              (C_Child_Military_Info%FOUND  and c_Child_Mil.PEI_INFORMATION3 ='C' and c_Child_Mil.PEI_INFORMATION4 ='Y'
      	       and  c_Age < (21 + (1+months_between(fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION2),fnd_date.canonical_to_date(c_Child_Mil.PEI_INFORMATION1)))/12)
	      )
      	      or
      	      (C_Children_Qualification%FOUND )
      	      or
      	      (C_Children_Disability%FOUND)
            )
               then
                   cSeq:=cSeq+1;
                   update_flag := true;
            end if;  -- salary
         end if; -- unemployment
       else
         cSeq:=cSeq+1;
         update_flag := true;
       end if; -- c_Age > 18
       /*if (c_Age < 18)
        then
          cSeq:=cSeq+1;
          update_flag := true;
       end if;*/
        end if;   -- DATE_OF_BIRTH
        if (update_flag=true)
         then
         PER_CONTACT_RELATIONSHIPS_PKG.Update_Row(
	      X_Rowid                   =>    C2.Rowid,
	      X_Contact_Relationship_Id =>     c2.Contact_Relationship_Id,
	      X_Business_Group_Id      =>        C2.Business_Group_Id,
	      X_Person_Id              =>        C2.Person_Id,
	      X_Contact_Person_Id      =>        C2.Contact_Person_Id,
	      X_Contact_Type           =>        C2.Contact_Type,
	      X_Comments                =>         C2.Comments,
	      X_Bondholder_Flag         =>         C2.Bondholder_Flag,
	      X_Third_Party_Pay_Flag    =>         C2.Third_Party_Pay_Flag,
	      X_Primary_Contact_Flag    =>         C2.Primary_Contact_Flag,
	      X_Cont_Attribute_Category =>         C2.Cont_Attribute_Category,
	      X_Cont_Attribute1         =>         C2.Cont_Attribute1,
	      X_Cont_Attribute2         =>         C2.Cont_Attribute2,
	      X_Cont_Attribute3         =>         C2.Cont_Attribute3,
	      X_Cont_Attribute4         =>         C2.Cont_Attribute4,
	      X_Cont_Attribute5         =>         C2.Cont_Attribute5,
	      X_Cont_Attribute6         =>         C2.Cont_Attribute6,
	      X_Cont_Attribute7         =>         C2.Cont_Attribute7,
	      X_Cont_Attribute8         =>         C2.Cont_Attribute8,
	      X_Cont_Attribute9         =>         C2.Cont_Attribute9,
	      X_Cont_Attribute10        =>         C2.Cont_Attribute10,
	      X_Cont_Attribute11        =>         C2.Cont_Attribute11,
	      X_Cont_Attribute12        =>         C2.Cont_Attribute12,
	      X_Cont_Attribute13        =>         C2.Cont_Attribute13,
	      X_Cont_Attribute14        =>         C2.Cont_Attribute14,
	      X_Cont_Attribute15        =>         C2.Cont_Attribute15,
	      X_Cont_Attribute16        =>         C2.Cont_Attribute16,
	      X_Cont_Attribute17        =>         C2.Cont_Attribute17,
	      X_Cont_Attribute18        =>         C2.Cont_Attribute18,
	      X_Cont_Attribute19        =>         C2.Cont_Attribute19,
	      X_Cont_Attribute20        =>         C2.Cont_Attribute20,
	      X_Cont_Information_Category =>       C2.Cont_Information_Category,
	      X_Cont_Information1         =>       C2.Cont_Information1,
	      X_Cont_Information2         =>       C2.Cont_Information2,
	      X_Cont_Information3         =>       C2.Cont_Information3,
	      X_Cont_Information4         =>       C2.Cont_Information4,
	      X_Cont_Information5         =>       C2.Cont_Information5,
	      X_Cont_Information6         =>       cSeq,
	      X_Cont_Information7         =>       C2.Cont_Information7,
	      X_Cont_Information8         =>       C2.Cont_Information8,
	      X_Cont_Information9         =>       C2.Cont_Information9,
	      X_Cont_Information10        =>       C2.Cont_Information10,
	      X_Cont_Information11        =>       C2.Cont_Information11,
	      X_Cont_Information12        =>       C2.Cont_Information12,
	      X_Cont_Information13        =>       C2.Cont_Information13,
	      X_Cont_Information14        =>       C2.Cont_Information14,
	      X_Cont_Information15        =>       C2.Cont_Information15,
	      X_Cont_Information16        =>       C2.Cont_Information16,
	      X_Cont_Information17        =>       C2.Cont_Information17,
	      X_Cont_Information18        =>       C2.Cont_Information18,
	      X_Cont_Information19        =>       C2.Cont_Information19,
	      X_Cont_Information20        =>       C2.Cont_Information20,
	      X_Session_Date              =>       l_session_date,
	      X_Date_Start                =>       C2.Date_Start,
	      X_Start_Life_Reason_Id      =>       C2.Start_Life_Reason_Id,
	      X_Date_End                   =>      C2.Date_End,
	      X_End_Life_Reason_Id         =>      C2.End_Life_Reason_Id,
	      X_Rltd_Per_Rsds_W_Dsgntr_Flag =>     C2.Rltd_Per_Rsds_W_Dsgntr_Flag,
	      X_Personal_Flag               =>     C2.Personal_Flag,
	      X_Sequence_Number             =>     C2.Sequence_Number,
	      X_Dependent_Flag              =>     C2.Dependent_Flag,
	      X_Beneficiary_Flag            =>     C2.Beneficiary_Flag
	 );
	 ELSE
	          PER_CONTACT_RELATIONSHIPS_PKG.Update_Row(
	      X_Rowid                   =>    C2.Rowid,
	      X_Contact_Relationship_Id =>     c2.Contact_Relationship_Id,
	      X_Business_Group_Id      =>        C2.Business_Group_Id,
	      X_Person_Id              =>        C2.Person_Id,
	      X_Contact_Person_Id      =>        C2.Contact_Person_Id,
	      X_Contact_Type           =>        C2.Contact_Type,
	      X_Comments                =>         C2.Comments,
	      X_Bondholder_Flag         =>         C2.Bondholder_Flag,
	      X_Third_Party_Pay_Flag    =>         C2.Third_Party_Pay_Flag,
	      X_Primary_Contact_Flag    =>         C2.Primary_Contact_Flag,
	      X_Cont_Attribute_Category =>         C2.Cont_Attribute_Category,
	      X_Cont_Attribute1         =>         C2.Cont_Attribute1,
	      X_Cont_Attribute2         =>         C2.Cont_Attribute2,
	      X_Cont_Attribute3         =>         C2.Cont_Attribute3,
	      X_Cont_Attribute4         =>         C2.Cont_Attribute4,
	      X_Cont_Attribute5         =>         C2.Cont_Attribute5,
	      X_Cont_Attribute6         =>         C2.Cont_Attribute6,
	      X_Cont_Attribute7         =>         C2.Cont_Attribute7,
	      X_Cont_Attribute8         =>         C2.Cont_Attribute8,
	      X_Cont_Attribute9         =>         C2.Cont_Attribute9,
	      X_Cont_Attribute10        =>         C2.Cont_Attribute10,
	      X_Cont_Attribute11        =>         C2.Cont_Attribute11,
	      X_Cont_Attribute12        =>         C2.Cont_Attribute12,
	      X_Cont_Attribute13        =>         C2.Cont_Attribute13,
	      X_Cont_Attribute14        =>         C2.Cont_Attribute14,
	      X_Cont_Attribute15        =>         C2.Cont_Attribute15,
	      X_Cont_Attribute16        =>         C2.Cont_Attribute16,
	      X_Cont_Attribute17        =>         C2.Cont_Attribute17,
	      X_Cont_Attribute18        =>         C2.Cont_Attribute18,
	      X_Cont_Attribute19        =>         C2.Cont_Attribute19,
	      X_Cont_Attribute20        =>         C2.Cont_Attribute20,
	      X_Cont_Information_Category =>       C2.Cont_Information_Category,
	      X_Cont_Information1         =>       C2.Cont_Information1,
	      X_Cont_Information2         =>       C2.Cont_Information2,
	      X_Cont_Information3         =>       C2.Cont_Information3,
	      X_Cont_Information4         =>       C2.Cont_Information4,
	      X_Cont_Information5         =>       C2.Cont_Information5,
	      X_Cont_Information6         =>       NULL,
	      X_Cont_Information7         =>       C2.Cont_Information7,
	      X_Cont_Information8         =>       C2.Cont_Information8,
	      X_Cont_Information9         =>       C2.Cont_Information9,
	      X_Cont_Information10        =>       C2.Cont_Information10,
	      X_Cont_Information11        =>       C2.Cont_Information11,
	      X_Cont_Information12        =>       C2.Cont_Information12,
	      X_Cont_Information13        =>       C2.Cont_Information13,
	      X_Cont_Information14        =>       C2.Cont_Information14,
	      X_Cont_Information15        =>       C2.Cont_Information15,
	      X_Cont_Information16        =>       C2.Cont_Information16,
	      X_Cont_Information17        =>       C2.Cont_Information17,
	      X_Cont_Information18        =>       C2.Cont_Information18,
	      X_Cont_Information19        =>       C2.Cont_Information19,
	      X_Cont_Information20        =>       C2.Cont_Information20,
	      X_Session_Date              =>       l_session_date,
	      X_Date_Start                =>       C2.Date_Start,
	      X_Start_Life_Reason_Id      =>       C2.Start_Life_Reason_Id,
	      X_Date_End                   =>      C2.Date_End,
	      X_End_Life_Reason_Id         =>      C2.End_Life_Reason_Id,
	      X_Rltd_Per_Rsds_W_Dsgntr_Flag =>     C2.Rltd_Per_Rsds_W_Dsgntr_Flag,
	      X_Personal_Flag               =>     C2.Personal_Flag,
	      X_Sequence_Number             =>     C2.Sequence_Number,
	      X_Dependent_Flag              =>     C2.Dependent_Flag,
	      X_Beneficiary_Flag            =>     C2.Beneficiary_Flag
	 );

     end if; -- update_flag

     --Added condition to check if cursor is open to fix bug 2361730
  IF C_Children_Disability%ISOPEN THEN
	  CLOSE C_Children_Disability;
  END IF;

  IF C_Child_Military_Info%ISOPEN THEN
  	CLOSE C_Child_Military_Info;
  END IF;

  IF C_Children_Qualification%ISOPEN THEN
	CLOSE C_Children_Qualification;
  END IF;


   END LOOP; -- LOOP C2
END LOOP; -- LOOP C1
commit;
--CLOSE C_B_Grp;
EXCEPTION
   --
   WHEN Others THEN
   rollback to PQH_DE_SEQ_NUM;
   raise_application_error(-20001, sqlerrm);
   --

End REGENERATE_SEQ_NUM;
/*---------------------------------------------------------------------------------------------+
                            Function DEFAULT_SEQ_NUM
 ----------------------------------------------------------------------------------------------+
 Description:
  This is intended to return a default Sequence Number whenever a new Child contact is
  being added to an Employee in German Public Sector.The processing is as follows:
   1. Checks if the Parent is Employee of the Business Group.
   2. If the Parent is Employee go to next step else return -1.
   3. Find maximum of Sequence Numbers given to the Children of the Employee.
   4. Return Maximum Sequence Number +1.

 In Parameters:
   1. Parent_id
   2. bg_id
   3. session_date
 Post Success:
      Returns -1 if Parent is not an Employee or returns some non negative number.

 Post Failure:

 Developer Implementation Notes:
   1. Cursor finds all Employees in the Business Group who want child sequence number to be auto generated.
   2. Cursor finds all the chldren of a employee in the Business Group in the order of Date of Birth.
   3. Cursor finds Disability information of a Person(Child)
   4. Cursor finds Qualification details of a Person(Child)
   5. The procedure PER_CONTACT_RELATIONSHIPS_PKG.Update_Row updates the Child Contact record in
      PER_CONTACT_RELATIONSHIPS to change the Sequence Number.

-------------------------------------------------------------------------------------------------*/
FUNCTION DEFAULT_SEQ_NUM (parent_id IN NUMBER, bg_id IN NUMBER, session_date IN date) RETURN NUMBER  IS

   parent_is_emp NUMBER(1) :=0;
   seq_num  NUMBER(2) :=0;

 CURSOR IS_Emp_OF_Business_Grp(lPERSON_ID number ,lBusiness_group_id number) is
 	select pap.PERSON_ID,
 	       pap.EFFECTIVE_START_DATE,
               pap.EFFECTIVE_END_DATE

 	from PER_ALL_PEOPLE_F pap,
 	     PER_PERSON_TYPES ppt
 	 where
 	      pap.PERSON_ID=lPERSON_ID
 	and   pap.BUSINESS_GROUP_ID=lBusiness_group_id
 	and   pap.person_type_id=ppt.person_type_id
 	and   ppt.SYSTEM_PERSON_TYPE='EMP'
 	and   pap.EFFECTIVE_START_DATE <= session_date
 	and   pap.EFFECTIVE_END_DATE >= session_date ;

c_Emp_Cur IS_Emp_OF_Business_Grp%rowtype;

BEGIN
   OPEN IS_Emp_OF_Business_Grp(parent_id,bg_id);
   FETCH IS_Emp_OF_Business_Grp into c_Emp_Cur;

   if IS_Emp_OF_Business_Grp%FOUND  then
     select max(nvl(pcr.cont_information6,0)) into seq_num
       from PER_CONTACT_RELATIONSHIPS pcr
       where
 	        pcr.BUSINESS_GROUP_ID=bg_id
 	    and pcr.PERSON_ID=parent_id
 	    and nvl(pcr.DATE_START,session_date) <=session_date
	    and nvl(pcr.DATE_END,session_date)  >= session_date
 	    and pcr.CONTACT_TYPE IN ('A','O','OC','T');

            seq_num :=nvl(seq_num,0)+1;
            RETURN seq_num;
   end if;
   CLOSE IS_Emp_OF_Business_Grp;
  RETURN -1;
 END DEFAULT_SEQ_NUM;
END PQH_DE_CHILD_SEQ_PKG;


/
