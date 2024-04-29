--------------------------------------------------------
--  DDL for Package Body HR_DE_TAX_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_TAX_SUPPORT" AS
/* $Header: perdetbu.pkb 115.4 2002/01/25 04:47:49 pkm ship      $ */

--

procedure batch_update
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_date_from                 IN DATE
, P_ORG_HIERARCHY             IN NUMBER
, P_TOP_ORG                   IN NUMBER
, P_ASSIGNMENT_SET            IN NUMBER
, P_ACTION                    IN VARCHAR2
, P_PROCESS_ID		      IN NUMBER
, P_TAX_CLASS                 IN VARCHAR2
, P_NO_OF_CHILDREN            IN VARCHAR2
, P_TAX_FREE_INCOME           IN VARCHAR2
, P_ADD_INCOME                IN VARCHAR2
)

is


cursor	get_org_structure_version
(P_ORG_HIERARCHY        	NUMBER
,P_DATE_FROM			DATE)
is
select max(posv.org_structure_version_id) org_structure_version_id
from per_org_structure_versions posv
where posv.organization_structure_id = P_ORG_HIERARCHY
and   nvl(posv.date_from,P_DATE_FROM) <= P_DATE_FROM
and   nvl(posv.date_to,TO_DATE('31/12/4712','DD/MM/YYYY'))   >= P_DATE_FROM
order by   posv.org_structure_version_id;


cursor    get_org_structure_element
(P_ORG_STRUCT_VERSION_ID	NUMBER
,P_TOP_ORG	 NUMBER
,P_ORG_HIERARCHY NUMBER)
is
select    distinct ose.organization_id_child organization_id
from      per_org_structure_elements ose, per_org_structure_versions_v posv
where     ose.org_structure_version_id     = posv.ORG_STRUCTURE_VERSION_ID
and       ose.BUSINESS_GROUP_ID = posv.BUSINESS_GROUP_ID
and       posv.ORG_STRUCTURE_VERSION_ID =  P_ORG_HIERARCHY
and       posv.ORGANIZATION_STRUCTURE_ID = P_ORG_HIERARCHY
and       ose.organization_id_parent         = P_TOP_ORG

UNION
select    P_TOP_ORG organization_id
from      dual
order by  organization_id;

cursor	get_organizations
( P_ORG_HIERARCHY        NUMBER
, P_ORGANIZATION_ID  	 NUMBER
)
is
select 	distinct ose.organization_id_child organization_id
from   	per_org_structure_elements ose
where  	ose.org_structure_version_id +0  	= P_ORG_HIERARCHY
connect by prior ose.organization_id_child 	= ose.organization_id_parent
and    	ose.org_structure_version_id  	= P_ORG_HIERARCHY
start with ose.organization_id_parent 		= P_ORGANIZATION_ID
and    	ose.org_structure_version_id  	= P_ORG_HIERARCHY
UNION
select 	P_ORGANIZATION_ID organization_id
from		dual;


cursor get_assignment_sets
( P_BUSINESS_GROUP_ID NUMBER
 ,P_DATE_FROM         DATE
 ,P_ASSIGNMENT_SET    NUMBER)

is
SELECT asg.assignment_id
       ,hdt.effective_end_date
       ,hdt.effective_start_date
       ,hdt.element_entry_id
       ,hdt.object_version_number
FROM PER_ALL_ASSIGNMENTS_F asg
    ,HR_ASSIGNMENT_SET_AMENDMENTS amn
    ,HR_DE_TAX_INFORMATION_V hdt
WHERE asg.business_group_id = P_BUSINESS_GROUP_ID
AND   asg.assignment_id = amn.assignment_id
AND   amn.include_or_exclude = 'I'
AND   amn.assignment_set_id = P_ASSIGNMENT_SET
AND   P_DATE_FROM between asg.effective_start_date and nvl(asg.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY'))
AND   hdt.assignment_id     = asg.assignment_id
and   get_tax_record(asg.assignment_id, P_DATE_FROM) = 'Y';


cursor	get_assignment_bg
( P_DATE_FROM			DATE
, P_BUSINESS_GROUP_ID		NUMBER
)
is

select      paf.assignment_id
           ,hdt.effective_end_date
           ,hdt.effective_start_date
           ,hdt.element_entry_id
           ,hdt.object_version_number

from       per_all_assignments_f paf
          ,hr_de_tax_information_v hdt
where      paf.business_group_id   =     P_BUSINESS_GROUP_ID
and        paf.assignment_type     =       'E'
and        P_DATE_FROM between paf.effective_start_date and nvl(paf.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY'))
AND        paf.assignment_id     = hdt.assignment_id
and        get_tax_record(paf.assignment_id, P_DATE_FROM) = 'Y';


cursor	get_assignment_org
( P_DATE_FROM			DATE
 ,P_ORGANIZATION_ID             NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is

select      paf.assignment_id
           ,HDT.EFFECTIVE_END_DATE
           ,HDT.EFFECTIVE_START_DATE
           ,hdt.element_entry_id
           ,hdt.object_version_number
from       per_all_assignments_f paf
          ,hr_de_tax_information_v hdt
where      paf.business_group_id   =     P_BUSINESS_GROUP_ID
and        paf.organization_id     =     P_ORGANIZATION_ID
and        paf.assignment_type     =       'E'
and        P_DATE_FROM between paf.effective_start_date and nvl(paf.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY'))
and        paf.assignment_id       = hdt.assignment_id
and        get_tax_record(paf.assignment_id, P_DATE_FROM) = 'Y';



BEGIN


IF  P_ASSIGNMENT_SET IS NULL AND P_ORG_HIERARCHY IS NULL THEN

for assgt_rec in get_assignment_bg
		( P_DATE_FROM
		, P_BUSINESS_GROUP_ID)

loop


tax_record( P_BUSINESS_GROUP_ID
            ,P_DATE_FROM
	    ,P_ACTION
            ,assgt_rec.assignment_id
            ,P_PROCESS_ID
            ,assgt_rec.effective_end_date
            ,assgt_rec.effective_start_date
            ,assgt_rec.element_entry_id
            ,P_TAX_CLASS
            ,P_NO_OF_CHILDREN
            ,P_TAX_FREE_INCOME
            ,P_ADD_INCOME
            ,assgt_rec.object_version_number);

end loop;

END IF;

IF P_ASSIGNMENT_SET IS NULL AND P_ORG_HIERARCHY IS not NULL THEN

for org_structure_version_rec in get_org_structure_version
(P_ORG_HIERARCHY
,P_DATE_FROM)
loop

	for org_structure_element_rec in get_org_structure_element
		(org_structure_version_rec.org_structure_version_id
		,P_TOP_ORG
		,P_ORG_HIERARCHY)
	loop


            for org_rec in get_organizations
	   ( org_structure_version_rec.org_structure_version_id
	   , org_structure_element_rec.organization_id )

            loop

for assgt_rec in get_assignment_org
		( P_DATE_FROM
                , org_rec.organization_id
		, P_BUSINESS_GROUP_ID)

loop
fnd_file.put_line(fnd_file.log,'ASG_SET');
tax_record( P_BUSINESS_GROUP_ID
            ,P_DATE_FROM
	    ,P_ACTION
            ,assgt_rec.assignment_id
            ,P_PROCESS_ID
            ,assgt_rec.effective_end_date
            ,assgt_rec.effective_start_date
            ,assgt_rec.element_entry_id
            ,P_TAX_CLASS
            ,P_NO_OF_CHILDREN
            ,P_TAX_FREE_INCOME
            ,P_ADD_INCOME
            ,assgt_rec.object_version_number);

end loop; -- assignment


end loop; -- get_organizations


end loop; -- get_org_structure_element


end loop;  -- get_org_structure_version

END IF;

IF P_ASSIGNMENT_SET IS NOT NULL THEN

for assgt_rec in get_assignment_sets
		(P_BUSINESS_GROUP_ID,
		 P_DATE_FROM,
		 P_ASSIGNMENT_SET)
loop

tax_record( P_BUSINESS_GROUP_ID
            ,P_DATE_FROM
	    ,P_ACTION
            ,assgt_rec.assignment_id
            ,P_PROCESS_ID
            ,assgt_rec.effective_end_date
            ,assgt_rec.effective_start_date
            ,assgt_rec.element_entry_id
            ,P_TAX_CLASS
            ,P_NO_OF_CHILDREN
            ,P_TAX_FREE_INCOME
            ,P_ADD_INCOME
            ,assgt_rec.object_version_number);






end loop;
END IF;

exception
when others then
fnd_file.put_line(fnd_file.log,SQLERRM);
fnd_file.put_line(fnd_file.log,'');

end batch_update;


procedure tax_record
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_date_from                 IN DATE
, P_ACTION                    IN VARCHAR2
, P_ASSIGNMENT_ID             IN NUMBER
, P_PROCESS_ID		      IN NUMBER
, P_END_DATE                  IN DATE
, P_START_DATE                IN DATE
, P_ELEMENT_ENTRY_ID          IN NUMBER
, P_TAX_CLASS                 IN VARCHAR2
, P_NO_OF_CHILDREN            IN VARCHAR2
, P_TAX_FREE_INCOME           IN VARCHAR2
, P_ADD_INCOME                IN VARCHAR2
, P_OBJECT_VERSION_NUMBER     IN NUMBER)

is

l_update_mode     varchar2(20);
l_tax_class       varchar2(30);
l_no_of_children  varchar2(30);
l_tax_free_income varchar2(30);
l_add_income      varchar2(30);
l_assignment_info_id number(15);
l_object_version_number  number(15);
l_effective_start_date  date;
l_effective_end_date    date;
l_update_warning boolean;
l_bdate            date;
l_cdate            date;

BEGIN

IF P_ACTION = 'R' THEN


   hr_assignment_extra_info_api.create_assignment_extra_info
		(p_assignment_id    => P_ASSIGNMENT_ID
		,p_information_type => 'DE_TAX_BATCH_UPDATE_INFO'
                ,p_aei_information_category => 'DE_TAX_BATCH_UPDATE_INFO'
                ,p_aei_information1 => to_char(P_PROCESS_ID)
                ,P_ASSIGNMENT_EXTRA_INFO_ID  => l_assignment_info_id
                ,P_OBJECT_VERSION_NUMBER   => l_object_version_number);







END IF;

IF P_ACTION = 'UR' THEN

select nvl(p_end_date,to_date('31/12/4712','dd/mm/yyyy'))
into l_cdate
from dual;

select to_date('31/12/4712','dd/mm/yyyy')
into l_bdate
from dual;

  if l_cdate = l_bdate then

     l_update_mode := 'UPDATE' ;
  else

     l_update_mode := 'UPDATE_CHANGE_INSERT' ;

  end if;
if P_START_DATE = P_DATE_FROM then
l_update_mode := 'CORRECTION' ;
end if;


select DECODE(P_TAX_CLASS,'NC',hr_api.g_varchar2,'DE_TAX_CLASS6')
      ,DECODE(P_NO_OF_CHILDREN,'NC',hr_api.g_varchar2,'0')
      ,DECODE(P_TAX_FREE_INCOME,'NC',hr_api.g_varchar2,'0')
      ,DECODE(P_ADD_INCOME,'NC',hr_api.g_varchar2,'0')

into   l_tax_class
      ,l_no_of_children
      ,l_tax_free_income
      ,l_add_income

from  dual;


l_object_version_number := p_object_version_number;
  per_de_ele_api.update_tax_information

      (p_datetrack_update_mode      => RTRIM(l_update_mode)
      ,P_EFFECTIVE_DATE             => p_date_from
      ,p_business_group_id          => P_BUSINESS_GROUP_ID
      ,p_element_entry_id           => P_ELEMENT_ENTRY_ID
      ,p_updated                    => P_PROCESS_ID
      ,p_tax_class                  => l_tax_class
      ,p_no_of_children             => l_no_of_children
      ,p_yearly_tax_free_income     => l_tax_free_income
      ,p_monthly_tax_free_income    => l_tax_free_income
      ,p_additional_mth_tax_income  => l_add_income
      ,p_additional_year_tax_income => l_add_income
      ,p_object_version_number      => l_object_version_number
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_update_warning             => l_update_warning);

END IF;


end tax_record;

procedure delete_assignment
( p_process_id IN NUMBER) IS

CURSOR C_ASSIGNMENT ( p_process_id NUMBER) IS
   SELECT ASSIGNMENT_ID,
          ASSIGNMENT_EXTRA_INFO_ID,
          OBJECT_VERSION_NUMBER
   FROM  HR_DE_ASG_TAX_BATCH_UPD_V
   WHERE PROCESS_ID = P_PROCESS_ID;



BEGIN

for assgt_del_rec in c_assignment(P_PROCESS_ID)
loop

hr_assignment_extra_info_api.delete_assignment_extra_info
 ( p_assignment_extra_info_id => assgt_del_rec.ASSIGNMENT_EXTRA_INFO_ID
  ,p_object_version_number => assgt_del_rec.object_version_number );

end loop;

END  delete_assignment;

function get_tax_record( p_assignment_id IN NUMBER,
                         p_date_from IN DATE) return char is
CURSOR c_get_tax_rec ( p_assignment_id number,
                       p_date_from date)
 IS
select '1'
from hr_de_tax_information_v hdt
where hdt.assignment_id = p_assignment_id
and   to_char(hdt.effective_start_date,'YYYY') < to_char(p_date_from,'YYYY')
and   nvl(hdt.effective_end_date,TO_DATE('31/12/4712','DD/MM/YYYY')) > p_date_from
and   hdt.tax_class IN ('I','II','III','IV','V','VI')
and   hdt.effective_start_date = ( select max(effective_start_date)
				   from pay_element_entries_f pee
                                   where pee.element_entry_id = hdt.element_entry_id
                                    and  pee.assignment_id = hdt.assignment_id);

l_var varchar2(1);
begin

OPEN c_get_tax_rec(p_assignment_id, p_date_from);

 FETCH  c_get_tax_rec into l_var;
 IF c_get_tax_rec%notfound then
 close c_get_tax_rec;
   return 'N';
 END IF;
 close  c_get_tax_rec;
  return 'Y';
end;

END HR_DE_TAX_SUPPORT;

/
