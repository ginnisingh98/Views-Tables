--------------------------------------------------------
--  DDL for Package Body HXC_MISSING_TCARD_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MISSING_TCARD_REPORT" AS
/* $Header: hxcmistc.pkb 115.3 2003/11/02 22:26:16 namrute ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_assignment_set >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_assignment_set
  (p_assignment_set_id             in number,
   p_assignment_id                 in number)
 Return varchar2 is

   l_flag                          varchar2(5):= 'N';

   CURSOR  csr_chk_asg_set IS
   SELECT 'Y'
   FROM   dual
   WHERE EXISTS (
          SELECT  'x'
          FROM    hr_assignment_set_amendments has
          WHERE   has.assignment_set_id = p_assignment_set_id
          AND     has.assignment_id     = p_assignment_id);


 begin

   OPEN  csr_chk_asg_set;
   FETCH csr_chk_asg_set INTO l_flag;
   CLOSE csr_chk_asg_set;

    return l_flag;

 end check_assignment_set;

Function get_vendor_name
  (p_start_date                in date,
   p_end_date                  in date,
   p_resource_id                in number
   )
 Return varchar2 IS

 cursor c_vendor is
    SELECT    pov.vendor_name VENDOR_NAME,
              a.vendor_id     VENDOR_ID
       FROM per_assignments_f a,
            per_all_people_f pp,
	    po_vendors pov
      WHERE a.assignment_type ='C'
        AND a.person_id = pp.person_id
        AND p_start_date <= a.effective_end_date
        AND p_end_date >= a.effective_start_date
        AND p_start_date <= pp.effective_end_date
        AND p_end_date >= pp.effective_start_date
	and pp.person_id=p_resource_id
        AND a.vendor_id = pov.vendor_id(+)
        AND a.vendor_id is not null
        group by  pov.vendor_name,a.vendor_id;

l_vender_list varchar2(2000) :=NULL;
Begin


FOR X IN c_vendor LOOP

 if l_vender_list is null then
    l_vender_list:=x.vendor_name;
 else
    l_vender_list:=l_vender_list||'&'||x.vendor_name;
 end if;

END LOOP;

return(l_vender_list);

End get_vendor_name;

Function check_vendor_exists
  (p_start_date                in date,
   p_end_date                  in date,
   p_assignment_id             in NUMBER,
   p_resource_id               in number,
   p_vendor_id		       in number
   )
 Return varchar2 IS

 cursor c_vendor is
       SELECT distinct 'Y'
       FROM per_assignments_f a,
            per_all_people_f pp,
	    po_vendors pov
      WHERE a.assignment_type ='C'
        AND a.person_id = pp.person_id
        AND p_start_date <= a.effective_end_date
        AND p_end_date >= a.effective_start_date
        AND p_start_date <= pp.effective_end_date
        AND p_end_date >= pp.effective_start_date
	and pp.person_id=p_resource_id
        AND a.vendor_id = pov.vendor_id
	and a.vendor_id=p_vendor_id
        AND a.vendor_id is not null;

l_vender_exists varchar2(2000) :=NULL;
Begin

l_vender_exists :='N';

open c_vendor;
fetch c_vendor into  l_vender_exists;
close c_vendor;

return(l_vender_exists);

End check_vendor_exists;


END hxc_missing_tcard_report;

/
