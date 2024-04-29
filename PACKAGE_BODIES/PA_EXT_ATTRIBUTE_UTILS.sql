--------------------------------------------------------
--  DDL for Package Body PA_EXT_ATTRIBUTE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXT_ATTRIBUTE_UTILS" AS
/* $Header: PAEXTUTB.pls 120.1 2007/03/06 12:07:39 apangana ship $ */

Function get_attribute_groups
  (
   p_classfication_code IN VARCHAR2
   )  RETURN VARCHAR2  is
      l_ret VARCHAR2(4000);
      l_size NUMBER := 0;
      l_new_size NUMBER :=0;

      CURSOR
	get_attr_groups
	IS
	   SELECT
	     attr_group_disp_name
	     FROM
	     EGO_OBJ_ATTR_GRP_ASSOCS_V AGV
	     WHERE 	     AGV.classification_code =  p_classfication_code;


BEGIN
   l_ret := NULL;

   FOR rec IN get_attr_groups LOOP

      l_size := Length(l_ret);
      l_new_size := 2 + Length(rec.attr_group_disp_name);
      IF l_new_size > 4000 THEN

	 l_ret := Substr(l_ret || ', ' || rec.attr_group_disp_name, 1, 4000);
	 RETURN l_ret;

      END IF;

      IF l_ret IS NULL then
	l_ret := l_ret || rec.attr_group_disp_name;
       ELSE

	 l_ret := l_ret || ', ' || rec.attr_group_disp_name;
      END IF;

   END LOOP;





   RETURN l_ret;

END get_attribute_groups;

Function get_page_regions
  (
   p_classfication_code IN VARCHAR2
   )  RETURN VARCHAR2  IS
      l_ret VARCHAR2(4000);
      l_size NUMBER := 0;
      l_new_size NUMBER :=0;


     CURSOR get_page_regions
	IS
	  select
	    display_name
	    From EGO_PAGES_V
	    where classification_code = p_classfication_code;

BEGIN

   l_ret := NULL;

    FOR rec IN get_page_regions LOOP

      l_size := Length(l_ret);
      l_new_size := 2 + Length(rec.display_name);
      IF l_new_size > 4000 THEN

  	 l_ret := Substr(l_ret || ', ' || rec.display_name, 1, 4000);


  	 RETURN l_ret;

      END IF;

      IF l_ret IS NULL then
	l_ret := l_ret || rec.display_name;
      else
	 l_ret := l_ret || ', ' || rec.display_name;
      END IF;

   END LOOP;





   RETURN l_ret;
END get_page_regions;

FUNCTION check_object_page_region
  (
   p_object_type VARCHAR2,
   p_object_id   NUMBER,
   p_page_id NUMBER
   ) RETURN VARCHAR2 IS

  l_ret VARCHAR2(1):= 'F';
  l_page_id NUMBER;
  l_project_id NUMBER;

CURSOR
  check_project_page
  IS
     SELECT
       epv.page_id
       FROM PA_PROJECT_DRIVERS_V pprv,
       ego_pages_v epv,
       fnd_objects fo
       where pprv.project_id = p_object_id
       AND fo.obj_name = 'PA_PROJECTS'
       and epv.object_id = fo.object_id and epv.object_name = 'PA_PROJECTS'
       and pprv.driver_code = epv.classification_code
       and epv.data_level_int_name = 'PROJECT_LEVEL'
       AND epv.page_id = p_page_id;

CURSOR get_project_id
  IS
     	select project_id from pa_proj_elements
	where proj_element_id =  p_object_id
	  AND object_type = 'PA_TASKS'
	  ;

CURSOR
  check_task_page
  IS
     SELECT
       epv.page_id
       FROM
       PA_PROJECTS_ALL PPA,
       PA_PROJECT_TYPES_ALL PPT,
       ego_pages_v epv,
       fnd_objects fo
       where ppa.project_id = l_project_id
       AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
       AND PPA.ORG_ID = PPT.ORG_ID   -- Bug 5900445
       AND fo.obj_name = 'PA_PROJECTS'
       and epv.object_id = fo.object_id and epv.object_name = 'PA_PROJECTS'
       and 'PROJECT_TYPE:' || PPT.PROJECT_TYPE_ID = epv.classification_code
       and epv.data_level_int_name = 'TASK_LEVEL'
       AND epv.page_id = p_page_id
union
SELECT
       epv.page_id
       FROM
       PA_PROJECT_CLASSES PPC,
       PA_CLASS_CATEGORIES PCC,
       ego_pages_v epv,
       fnd_objects fo
       where
       PPC.PROJECT_ID = l_project_id
       AND PPC.CLASS_CATEGORY = PCC.CLASS_CATEGORY
       AND fo.obj_name = 'PA_PROJECTS'
       and epv.object_id = fo.object_id and epv.object_name = 'PA_PROJECTS'
       and 'CLASS_CATEGORY:' || PCC.CLASS_CATEGORY_ID  = epv.classification_code
       and epv.data_level_int_name = 'TASK_LEVEL'
       AND epv.page_id = p_page_id
union
SELECT
       epv.page_id
       FROM
       PA_PROJECT_CLASSES PPC,
       PA_CLASS_CODES pcc,
       ego_pages_v epv,
       fnd_objects fo
       where
       PPC.PROJECT_ID = l_project_id
       AND PPC.CLASS_CATEGORY = PCC.CLASS_CATEGORY
       AND PPC.CLASS_CODE = PCC.CLASS_CODE
       AND fo.obj_name = 'PA_PROJECTS'
       and epv.object_id = fo.object_id and epv.object_name = 'PA_PROJECTS'
       and 'CLASS_CODE:' || PCC.CLASS_CODE_ID  = epv.classification_code
       and epv.data_level_int_name = 'TASK_LEVEL'
       AND epv.page_id = p_page_id;


CURSOR
  check_task_page_for_task_type
  IS
     SELECT
       epv.page_id
       FROM  PA_TASK_TYPES TT,
       PA_LOOKUPS pl,
       ego_pages_v epv,
       fnd_objects fo
       WHERE
        PL.LOOKUP_TYPE     = 'PA_EXT_DRIVER_TYPE'
       AND PL.LOOKUP_CODE = 'TASK_TYPE'
       AND tt.task_type_id =
       (
	select type_id from pa_proj_elements
	where proj_element_id =  p_object_id
	AND object_type = 'PA_TASKS'
	)
       AND fo.obj_name = 'PA_PROJECTS'
       and epv.object_id = fo.object_id and epv.object_name = 'PA_PROJECTS'
       and 'TASK_TYPE:' || TT.TASK_TYPE_ID = epv.classification_code
       and epv.data_level_int_name = 'TASK_LEVEL'
       AND epv.page_id = p_page_id;

BEGIN

   IF p_object_type = 'PA_PROJECTS' THEN
      OPEN check_project_page;
      FETCH check_project_page INTO l_page_id;
      IF check_project_page%found THEN
	 l_ret := 'T';
      END IF;
      CLOSE check_project_page;
    ELSIF p_object_type = 'PA_TASKS' THEN

      OPEN get_project_id;
      FETCH get_project_id INTO l_project_id;
      IF get_project_id%notfound THEN
	 CLOSE get_project_id;
	 RETURN 'F';
      END IF;

      CLOSE get_project_id;

      OPEN check_task_page;
      FETCH check_task_page INTO l_page_id;

      IF check_task_page%found THEN
	 l_ret := 'T';
       ELSE
	 OPEN check_task_page_for_task_type;
	 FETCH check_task_page_for_task_type INTO l_page_id;
	 IF check_task_page_for_task_type%found THEN
	    l_ret := 'T';
	 END IF;
	 CLOSE check_task_page_for_task_type;
      END IF;
      CLOSE check_task_page;

    ELSE
	 NULL;
      END IF;

   RETURN l_ret;

END check_object_page_region;



END Pa_ext_attribute_utils;

/
