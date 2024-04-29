--------------------------------------------------------
--  DDL for Package Body OTA_ADMIN_ACCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ADMIN_ACCESS_UTIL" as
/* $Header: otadminacc.pkb 120.0.12010000.6 2009/09/30 09:35:24 shwnayak noship $ */

--This function is used to determine the primary category of any catalog object
--object type/object_id:
--course=H/activity_version_id,offering=O/offering_id,class=CL/event_id
--learning path=CLP/learning_path_id,learning certification=CER/certification_id
--category forum=RFOR/forum_id,category chat=SCHT/chat_id

function get_primary_category_id(p_object_type in varchar,
                                    p_object_id in number) return NUMBER is

Cursor get_id_for_course(p_activity_version_id ota_activity_versions.activity_version_id%type) is
Select  category_usage_id
From ota_act_cat_inclusions
Where activity_version_id=p_activity_version_id
And primary_flag='Y';

Cursor get_id_for_cert is
Select  category_usage_id
From ota_cert_cat_inclusions
Where certification_id=p_object_id
And primary_flag='Y';

Cursor get_id_for_lp is
Select  category_usage_id
From ota_lp_cat_inclusions
Where learning_path_id=p_object_id
And primary_flag='Y';

Cursor get_id_for_forum is
Select  object_id
From ota_frm_obj_inclusions
Where forum_id=p_object_id
And primary_flag='Y';

Cursor get_id_for_chat is
Select  object_id
From ota_chat_obj_inclusions
Where chat_id=p_object_id
And primary_flag='Y';

Cursor get_course_id_for_class is
Select  activity_version_id
From ota_events
where event_id=p_object_id;

Cursor get_course_id_for_offering is
Select  activity_version_id
From ota_offerings
where offering_id=p_object_id;

l_act_ver_id number:=null;
l_category_id number:=null;
Begin

if p_object_type='H' then
  OPEN   get_id_for_course(p_object_id);
  Fetch get_id_for_course  into l_category_id;
  Close get_id_for_course ;

elsif p_object_type='SCHT' then
    OPEN   get_id_for_chat;
    Fetch get_id_for_chat  into l_category_id;
    Close get_id_for_chat;

elsif p_object_type='RFOR' then
    OPEN   get_id_for_forum;
    Fetch get_id_for_forum  into l_category_id;
    Close get_id_for_forum;

elsif p_object_type='CER' then
  OPEN   get_id_for_cert;
    Fetch get_id_for_cert  into l_category_id;
    Close get_id_for_cert;

elsif p_object_type='CLP' then
  OPEN   get_id_for_lp;
    Fetch get_id_for_lp  into l_category_id;
    Close get_id_for_lp;

elsif  p_object_type='O' then
  OPEN   get_course_id_for_offering;
  Fetch get_course_id_for_offering  into l_act_ver_id;
  Close get_course_id_for_offering;
  OPEN   get_id_for_course(l_act_ver_id);
  Fetch get_id_for_course  into l_category_id;
  Close get_id_for_course ;

elsif  p_object_type='CL' then
  OPEN   get_course_id_for_class;
  Fetch get_course_id_for_class  into l_act_ver_id;
  Close get_course_id_for_class;
  OPEN   get_id_for_course(l_act_ver_id);
  Fetch get_id_for_course  into l_category_id;
  Close get_id_for_course ;

end if;

return l_category_id;

End get_primary_category_id;


--This function is used to determine the admin group of any catalog object
--The admin group is determined based on primary category of the object
--object type/object_id:
--course=H/activity_version_id,offering=O/offering_id,class=CL/event_id
--learning path=CLP/learning_path_id,learning certification=CER/certification_id
--category forum=RFOR/forum_id,category chat=SCHT/chat_id
function get_catalog_obj_admin_grp (p_object_type in varchar,
                                       p_object_id in number) return Number is


l_category_id number;
l_admin_grp_id number;

Begin
--allow access by default??
  if p_object_type is null or p_object_id is null then
    return null;
  end if;


 if p_object_type = 'C' then
  l_category_id := p_object_id;
 else
  l_category_id:=get_primary_category_id(p_object_type, p_object_id);
 end if;

  OPEN  check_is_category_secured(l_category_id);
  Fetch check_is_category_secured into l_admin_grp_id;
  Close check_is_category_secured;

  return l_admin_grp_id;

end get_catalog_obj_admin_grp;


--This function is used to determine the admin group of any catalog object
--The admin group is determined based on primary category of the object
--object type/object_id:
--folder=F/folder_id
--learning object=LO/learning_object_id

function get_content_obj_admin_grp(p_object_type in varchar,
                                      p_object_id in number) return Number is

Cursor get_folder_adminGrp IS
Select user_group_id
from ota_lo_folders
where folder_id=p_object_id;

Cursor get_lo_adminGrp IS
select user_group_id
from
ota_lo_folders lof,
ota_learning_objects lo
where
lo.learning_object_id=p_object_id
and lo.folder_id=lof.folder_id;


l_admin_grp_id Number;

Begin
 if p_object_type ='F' then
    OPEN  get_folder_adminGrp;
    Fetch get_folder_adminGrp into l_admin_grp_id;
    Close get_folder_adminGrp;
  elsif p_object_type ='LO' then
    OPEN  get_lo_adminGrp;
    Fetch get_lo_adminGrp into l_admin_grp_id;
    Close get_lo_adminGrp;
 end if;

   return l_admin_grp_id;

end get_content_obj_admin_grp;




function get_admin_group_id(p_object_type in varchar,
                            p_object_id in number) return Number is


l_admin_grp_id number null;

Begin
--allow access by default??
  if p_object_type is null or p_object_id is null then
    return null;
  end if;


 if p_object_type = 'C' then
  l_admin_grp_id := get_catalog_obj_admin_grp(p_object_type, p_object_id);
 else
  l_admin_grp_id := get_content_obj_admin_grp(p_object_type, p_object_id);
 end if;

   return l_admin_grp_id;

end get_admin_group_id;





--The function admin_can_access_object will be called from all VO's where objects are not
--used for a transaction i.e objects used only for view purpose
--Admin can access catalog objects only if one of the below is true
--1.the object is not secured
--2.if secured then,admin should belong to that admingroup

function admin_can_access_object(p_object_type in varchar,
                                    p_object_id in number,
                                    p_module_name IN VARCHAR2 default 'ADMIN') return varchar2 is
l_person_id number;
l_adminGrpId number;

begin

 if p_module_name <> 'ADMIN' then
   return 'Y';

 else

    l_person_id := fnd_global.employee_id();

    if p_object_type IN ('F','LO') then
     l_adminGrpId := get_content_obj_admin_grp(p_object_type,p_object_id);
    else
     l_adminGrpId :=get_catalog_obj_admin_grp(p_object_type,p_object_id);
    end if;

    if l_adminGrpId is null then
     return 'Y';
    else
     return ota_learner_access_util.is_learner_in_user_group(l_person_id, l_adminGrpId, ota_general.get_business_group_id());
    end if;

  end if;

end admin_can_access_object;

--Function called to check whether a particular course can be added to lp
--check if the course is secured.If it is not secured,you can add it to any lp
--if lp is secured,the course should be secured with same admin group
Function lp_has_access_to_course(p_lp_id in NUMBER,
                                p_crs_id in NUMBER) return varchar2 is

l_crsAdminGrpId number:=null;
l_lpAdminGrpId number :=null;

begin


l_crsAdminGrpId := get_catalog_obj_admin_grp('H',p_crs_id);
l_lpAdminGrpId := get_catalog_obj_admin_grp('CLP',p_lp_id);

 if l_crsAdminGrpId is null then
  return 'Y';
 end if;

 if(l_crsAdminGrpId = l_lpAdminGrpId) then
  return 'Y';
 else
  return 'N';
 end if;

End lp_has_access_to_course;

--Function called to check whether a particular course can be added to lp
--check if the course is secured.If it is not secured,you can add it any cert
--if cert is secured,the course should be secured with same admin group
Function cert_has_access_to_course(p_cert_id in NUMBER,
                                    p_crs_id in NUMBER) return varchar2 is

l_crsAdminGrpId number:=null;
l_certAdminGrpId number :=null;

begin


l_crsAdminGrpId := get_catalog_obj_admin_grp('H',p_crs_id);
l_certAdminGrpId := get_catalog_obj_admin_grp('CER',p_cert_id);

 if l_crsAdminGrpId is null then
  return 'Y';
 end if;

 if(l_crsAdminGrpId = l_certAdminGrpId) then
  return 'Y';
 else
  return 'N';
 end if;

End cert_has_access_to_course;



--Function called to check whether a particular learning object can be added to an offering
--When called from catalog tab :create offering page,p_course_id is passed

function offering_has_access_to_lo(p_course_id in NUMBER,p_lo_id in NUMBER)
return varchar2 is

l_offrAdminGrpId number;
l_loAdminGrpId number;
begin
--check if the content object is secured.If it is not secured,you can add it
--if offering is secured,the content object should be secured with same admin group

l_offrAdminGrpId := get_catalog_obj_admin_grp('H',p_course_id);
l_loAdminGrpId := get_content_obj_admin_grp('LO',p_lo_id);

 if l_loAdminGrpId is null then
   return 'Y';
 end if;

 if l_offrAdminGrpId = l_loAdminGrpId then
  return 'Y';
 else
  return 'N';
 end if;

end offering_has_access_to_lo;



--when called from content tab,quick offering page,use existing course:p_course_id id passed
--when called from content tab,quick offering page,create new course:p_cateory_id id passed

function lo_has_access_to_offering(p_course_id in NUMBER,p_lo_id in NUMBER,p_category_id in NUMBER default NULL)
return varchar2 is

l_offrAdminGrpId number;
l_loAdminGrpId number;
begin
--check if the content object is secured.If it is not secured,you can add it to any object accessible.
--if offering is secured,the content object should be secured with same admin group

if p_course_id is not null then
l_offrAdminGrpId := get_catalog_obj_admin_grp('H',p_course_id);
else
l_offrAdminGrpId := get_catalog_obj_admin_grp('C',p_category_id);
end if;

l_loAdminGrpId := get_content_obj_admin_grp('LO',p_lo_id);


 if l_loAdminGrpId is null then
  if p_course_id is not null then
    return admin_can_access_object('H',p_course_id);
  else
    return admin_can_access_object('C',p_category_id);
   end if;
 end if;

  if(l_offrAdminGrpId = l_loAdminGrpId) then
   return 'Y';
 end if;

  return 'N';


end lo_has_access_to_offering;
function is_root_category(p_category_id in NUMBER)
return boolean is

Cursor get_root_id IS
Select  parent_cat_usage_id
From ota_category_usages
Where category_usage_id=p_category_id;

l_root_id number := null;
begin
  OPEN  get_root_id;
  Fetch get_root_id  into l_root_id;
  Close get_root_id;

  if l_root_id is null then
     return true;
  else
     return false;
  end if;

end is_root_category;


--This function is used for displaying categories for copy functionality of catalog objects
--and move functionality of category

function category_has_access_to_object(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_category_id in NUMBER) return varchar2 is
l_ctgAdminGrpId number;
l_objAdminGrpId number;

begin
--1.always display root
--2.if the catalog object to be copied(or category to be moved) is access controlled,
--then category should be access controlled with same admin group or not access controlled
--This is done as a non access controlled category may have child categories which are access
--controlled.Hence display them.The selection can be restricted based on function disable_select
--3.if catalog object is not access controlled,then category should also be non access controlled
 if is_root_category(p_category_id) then
   return 'Y';
 else
    l_ctgAdminGrpId := get_catalog_obj_admin_grp('C',p_category_id);
    l_objAdminGrpId := get_catalog_obj_admin_grp(p_object_type,p_object_id);

     if(l_objAdminGrpId is null ) then
       if (l_ctgAdminGrpId is null) then
         return 'Y';
        else
         return 'N';
        end if;
     else
       if((l_ctgAdminGrpId is null) or (l_ctgAdminGrpId = l_objAdminGrpId))then
         return 'Y';
       else
         return 'N';
       end if;
     end if;

   end if;

end category_has_access_to_object;

--This function governs whether a displayed category/course can be selected for the copy/move functionality

function disable_select(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_dest_object_type in varchar2,
                                           p_dest_object_id in NUMBER,
                                           p_action in varchar2 default 'Copy' ) return varchar2 is
l_destAdminGrpId number;
l_objAdminGrpId number;

begin
--1.always allow  root selection
--2.if catalog object is not access controlled,then category/course should also be non access controlled
--This holds good for copy of catalog objects and move for category
--3.if the catalog object to be copied(or category to be moved) is access controlled,
--3.1.if action is copy then destination object  should be secured with same admin group
--3.2.if action is move then destination object can either be non access controlled or access controlled with the same admin group
 if ((p_dest_object_type='C') and is_root_category(p_dest_object_id)) then
     return 'N';
 else
    l_destAdminGrpId := get_catalog_obj_admin_grp(p_dest_object_type,p_dest_object_id);
    l_objAdminGrpId := get_catalog_obj_admin_grp(p_object_type,p_object_id);

   if(p_action = 'Copy') then
     if ((l_destAdminGrpId is null and l_objAdminGrpId is null ) or (l_destAdminGrpId = l_objAdminGrpId))then
        return 'N';
     else
       return 'Y';
     end if;
   else
   --move action
     if(l_objAdminGrpId is null ) then
        if (l_destAdminGrpId is null) then
         return 'N';
        else
         return 'Y';
        end if;
     else
        if((l_destAdminGrpId is null) or (l_destAdminGrpId = l_objAdminGrpId))then
         return 'N';
        else
         return 'Y';
        end if;
     end if;

   end if; --end move

 end if;

end disable_select;




/*function category_has_access_to_object(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_category_id in NUMBER) return varchar2 is
l_ctgAdminGrpId number;
l_objAdminGrpId number;

begin
--always display root
--if catalog object is not secured,then category should also be unsecured
--if the catalog object to be copied(or category to be moved) is secured,then category should be secured with same admin group
 if is_root_category(p_category_id) then
   return 'Y';
 else
    l_ctgAdminGrpId := get_catalog_obj_admin_grp('C',p_category_id);
    l_objAdminGrpId := get_catalog_obj_admin_grp(p_object_type,p_object_id);

     if ((l_ctgAdminGrpId is null and l_objAdminGrpId is null ) or (l_ctgAdminGrpId = l_objAdminGrpId))then
        return 'Y';
     else
       return 'N';
    end if;

 end if;

end category_has_access_to_object;*/


function is_root_folder(p_folder_id in NUMBER)
return boolean is

Cursor get_root_id IS
Select  parent_folder_id
From ota_lo_folders
Where folder_id=p_folder_id;

l_root_id number := null;
begin
  OPEN  get_root_id;
  Fetch get_root_id  into l_root_id;
  Close get_root_id;

  if l_root_id is null then
     return true;
  else
     return false;
  end if;

end is_root_folder;

--This function is used for displaying folders for copy functionality of content objects
function folder_has_access_to_object(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_folder_id in NUMBER) return varchar2 is
l_fAdminGrpId number;
l_objAdminGrpId number;

begin
--1.always display root
--2.if the content object to be copied is access controlled,
--then folder should be access controlled with same admin group or not access controlled
--This is done as a non access controlled folder may have child folder which are access
--controlled.Hence display them.The selection can be restricted based on function disable_folder_select
--3.if content object is not access controlled,then folder should also be non access controlled
 if is_root_folder(p_folder_id) then
   return 'Y';
 else
    l_fAdminGrpId := get_content_obj_admin_grp('F',p_folder_id);
    l_objAdminGrpId := get_content_obj_admin_grp(p_object_type,p_object_id);

    --Modified for Bug 8975113

     /*if ((l_fAdminGrpId is null and l_objAdminGrpId is null ) or (l_fAdminGrpId = l_objAdminGrpId))then
        return 'Y';
     else
       return 'N';
    end if;*/

    if(l_objAdminGrpId is null ) then
       if (l_fAdminGrpId is null) then
         return 'Y';
        else
         return 'N';
        end if;
     else
       if((l_fAdminGrpId is null) or (l_fAdminGrpId = l_objAdminGrpId))then
         return 'Y';
       else
         return 'N';
       end if;
     end if;


 end if;

end folder_has_access_to_object;


--Added for Bug 8975113 - user is not able to copy to an access controlled folder
--This function governs whether a displayed content object can be selected for the copy functionality
function disable_content_obj_select(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_dest_obj_type in varchar2,
                                           p_dest_obj_id in NUMBER
                                           ) return varchar2 is
l_destAdminGrpId number;
l_objAdminGrpId number;

begin
--1.always allow  root selection
--2.if content object is not access controlled,then folder should also be non access controlled
--3.if the content object to be copied is access controlled,
-- then destination folder object  should be access controlled with same admin group

  if ((p_dest_obj_type='F') and is_root_folder(p_dest_obj_id)) then
       return 'N';
  else

    l_destAdminGrpId := get_content_obj_admin_grp(p_dest_obj_type,p_dest_obj_id);
    l_objAdminGrpId := get_content_obj_admin_grp(p_object_type,p_object_id);

     if ((l_destAdminGrpId is null and l_objAdminGrpId is null ) or (l_destAdminGrpId = l_objAdminGrpId))then
        return 'N';
     else
       return 'Y';
     end if;


  end if;

end disable_content_obj_select;
--This function is used for displaying learning objects for copy functionality of content objects
function lo_has_access_to_object(p_object_type in varchar2,
                                 p_object_id in NUMBER,
                                 p_lo_id in NUMBER) return varchar2 is
l_loAdminGrpId number;
l_objAdminGrpId number;

begin
--always display root
--if content object is not secured,then folder should also be unsecured
--if the content object to be copied is secured,then folder should be secured with same admin group

    l_loAdminGrpId := get_content_obj_admin_grp('LO',p_lo_id);
    l_objAdminGrpId := get_content_obj_admin_grp(p_object_type,p_object_id);

     if ((l_loAdminGrpId is null and l_objAdminGrpId is null ) or (l_loAdminGrpId = l_objAdminGrpId))then
        return 'Y';
     else
       return 'N';
    end if;



end lo_has_access_to_object;


--This function is used for displaying eval objects while admin tries to add course/class evaluations
function object_has_access_to_eval(p_object_type in varchar,p_object_id in NUMBER,p_test_id in NUMBER)
return varchar2 is

l_objAdminGrpId number;
l_loAdminGrpId number;
l_lo_id number;

begin
--check if the eval is secured.If it is not secured,you can add it
--if course is secured,the eval should be secured with same admin group


  OPEN  get_lo_id(p_test_id);
  Fetch get_lo_id into l_lo_id;
  Close get_lo_id;


 l_objAdminGrpId := get_catalog_obj_admin_grp(p_object_type,p_object_id);
 l_loAdminGrpId := get_content_obj_admin_grp('LO',l_lo_id);


if l_loAdminGrpId is null then
  return 'Y';
end if;

if(l_objAdminGrpId = l_loAdminGrpId) then
  return 'Y';
else
  return 'N';
end if;


End object_has_access_to_eval;



function test_has_access_to_qbank(p_qbank_id in NUMBER,p_test_id in NUMBER)
return varchar2 is

  Cursor get_folder_id IS
  Select folder_id
  from ota_question_banks
  where question_bank_id=p_qbank_id;



l_qbAdminGrpId number;
l_folder_id number;
l_loAdminGrpId number;
l_lo_id number;

begin
--check if the question bank is secured.If it is not secured,you can add it
--if question bank is secured,the test should be secured with same admin group


  OPEN  get_lo_id(p_test_id);
  Fetch get_lo_id into l_lo_id;
  Close get_lo_id;

  OPEN  get_folder_id;
  Fetch get_folder_id into l_folder_id;
  Close get_folder_id;

 l_qbAdminGrpId := get_content_obj_admin_grp('F',l_folder_id);
  l_loAdminGrpId := get_content_obj_admin_grp('LO',l_lo_id);



if l_qbAdminGrpId is null then
  return 'Y';
end if;

if(l_loAdminGrpId = l_qbAdminGrpId) then
  return 'Y';
else
   return 'N';

end if;

End test_has_access_to_qbank;
--This function is used for displaying categories for any catalog object:side nav->Category
--After adding a category,admin can change the primary category,thereby moving the catalog object
--across category.Hence tighter restriction

function object_can_add_category(p_object_type in varchar,
                                     p_object_id in NUMBER,
                                     p_category_usage_id in NUMBER)
return varchar2 is



l_objAdminGrpId number;
l_ctgAdminGrpId number;


begin
--if  object is not secured,then category should also be unsecured
--if the object is secured,then category should be secured with same admin group


l_objAdminGrpId := get_catalog_obj_admin_grp(p_object_type,p_object_id);

  OPEN  check_is_category_secured(p_category_usage_id);
  Fetch check_is_category_secured into l_ctgAdminGrpId;
  Close check_is_category_secured;



  if ((l_ctgAdminGrpId is null and l_objAdminGrpId is null ) or (l_ctgAdminGrpId = l_objAdminGrpId))then
        return 'Y';
     else
       return 'N';
    end if;

End object_can_add_category;

--course/player prereqs
Function can_add_object_as_prereq(p_object_type in varchar,
                                  p_obj_id in NUMBER,
                                p_prereq_obj_id in NUMBER) return varchar2 is

l_objAdminGrpId number:=null;
l_prereq_objAdminGrpId number :=null;

begin

if p_object_type = 'H' then
    l_objAdminGrpId := get_catalog_obj_admin_grp('H',p_obj_id);
    l_prereq_objAdminGrpId := get_catalog_obj_admin_grp('H',p_prereq_obj_id);
elsif  p_object_type = 'LO' then
    l_objAdminGrpId := get_content_obj_admin_grp('LO',p_obj_id);
    l_prereq_objAdminGrpId := get_content_obj_admin_grp('LO',p_prereq_obj_id);
end if;

 if ((l_prereq_objAdminGrpId is null ) or (l_objAdminGrpId = l_prereq_objAdminGrpId))then
        return 'Y';
     else
       return 'N';
    end if;

End can_add_object_as_prereq;

function get_lo_offering_count (p_learning_object_id in number) return varchar2
 IS
    l_offering_count number;

CURSOR c_get_offering_count IS
    SELECT count(*)
    FROM   ota_offerings
    WHERE  learning_object_id = p_learning_object_id
    and admin_can_access_object('O',offering_id)='Y';

BEGIN
    open c_get_offering_count;
    fetch c_get_offering_count into l_offering_count;
    close c_get_offering_count;

 return(l_offering_count);

end get_lo_offering_count ;


--for valuesets.Need to find whther it is a category or class chat and then
--perform the appropriate action
function admin_can_access_chat(p_chat_id in number) return varchar2
IS

cursor get_chat_details is
  select object_type,object_id
  from ota_chat_obj_inclusions
  where chat_id=p_chat_id
  and primary_flag='Y';

 l_chat_type varchar2(4);
 l_object_id number;

  BEGIN
    open get_chat_details;
    fetch get_chat_details into l_chat_type,l_object_id;
    close get_chat_details;

    if l_chat_type = 'C' then
     return(admin_can_access_object('C',l_object_id));
    else
     return(admin_can_access_object('CL',l_object_id));
     end if;

end admin_can_access_chat;


--for valuesets.Need to find whther it is a category or class forum and then
--perform the appropriate action
function admin_can_access_forum(p_forum_id in number) return varchar2
IS

--bugBug 8916572 - tst1212:user is able to generate report for forums outside administrator group
/*cursor get_forum_details is
  select object_type,object_id
  from ota_chat_obj_inclusions
  where chat_id=p_forum_id
    and primary_flag='Y';*/

cursor get_forum_details is
  select object_type,object_id
  from ota_frm_obj_inclusions
  where forum_id=p_forum_id
    and primary_flag='Y';

 l_forum_type varchar2(4);
 l_object_id number;

  BEGIN
    open get_forum_details;
    fetch get_forum_details into l_forum_type,l_object_id;
    close get_forum_details;

    if l_forum_type = 'C' then
     return(admin_can_access_object('C',l_object_id));
    else
     return(admin_can_access_object('CL',l_object_id));
     end if;

end admin_can_access_forum;



end ota_admin_access_util;


/
