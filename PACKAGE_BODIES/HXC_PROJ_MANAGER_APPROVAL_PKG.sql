--------------------------------------------------------
--  DDL for Package Body HXC_PROJ_MANAGER_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_PROJ_MANAGER_APPROVAL_PKG" AS
/* $Header: hxcpamgrapr.pkb 120.6.12000000.1 2007/01/18 17:54:43 appldev noship $ */

g_debug boolean := hr_utility.debug_enabled;

cursor g_csr_get_approval_style
is
select approval_style_id from HXC_APPROVAL_STYLES where name ='SEEDED_APPL_PA_MGR';


-- Getting the Time recepient id for Projects application (APPLICATION_ID = 275 )

cursor csr_get_recipient_id
is
select TIME_RECIPIENT_ID from HXC_TIME_RECIPIENTs where APPLICATION_ID = 275 ;

cursor csr_get_ela_approval_comp(l_approval_style_id in number)
is
select APPROVAL_COMP_ID, OBJECT_VERSION_NUMBER from hxc_approval_comps where APPROVAL_MECHANISM = 'ENTRY_LEVEL_APPROVAL'  and APPROVAL_STYLE_ID = l_approval_style_id;

--bug 4671272
cursor csr_get_flex_value_set_id
is
select FLEX_VALUE_SET_ID from fnd_flex_value_sets where flex_value_set_name = 'HXC_ALL_PROJECTS';

g_update_flag NUMBER;

/* The many unused parameters were meant for the concurrent program previously planned */

PROCEDURE create_time_cat(p_project_id in number,
			p_approval_style_id in number,
			p_parent_comp_id in number,
			p_parent_object_version_number in number,
			p_default_approval_mechanism in varchar2 default null,
			p_mechanism_id in number default null ,
			p_wf_name in varchar2 default null,
			p_wf_item_type varchar2 default null,
			p_manager_id out NOCOPY number )
is
cursor csr_find_time_category_comp(l_project_id in number)
is
select time_category_comp_id, object_version_number, time_category_id
from hxc_time_category_comps
where value_id = to_char(l_project_id)
and    TIME_CATEGORY_ID IN (     SELECT  TIME_CATEGORY_ID  FROM HXC_TIME_CATEGORIES
   WHERE TIME_CATEGORY_NAME LIKE 'PROJECT MANAGER :: % SYSTEM GENERATED DO NOT MODIFY'   );



cursor csr_get_time_category_name(l_time_category_name  hxc_time_categories.TIME_CATEGORY_NAME%TYPE)
is
select time_category_id from hxc_time_categories where time_category_name = l_time_category_name;


cursor csr_get_approval_mechanism( l_approval_style_id in number, l_time_category_id in number)
is
select APPROVAL_MECHANISM, APPROVAL_MECHANISM_ID, APPROVAL_COMP_ID, OBJECT_VERSION_NUMBER , WF_NAME , WF_ITEM_TYPE from hxc_approval_comps where
APPROVAL_STYLE_ID = l_approval_style_id  and TIME_CATEGORY_ID = l_time_category_id
and OBJECT_VERSION_NUMBER  = ( select max( OBJECT_VERSION_NUMBER ) from hxc_approval_comps where
APPROVAL_STYLE_ID = l_approval_style_id  and TIME_CATEGORY_ID = l_time_category_id);


CURSOR csr_get_map_comp_id
IS
SELECT	mapping_component_id
  FROM	hxc_mapping_components_v
 WHERE	bld_blk_info_type	= 'PROJECTS'
   AND	field_name	= 'Project_Id';


l_wf_name VARCHAR2(100);
l_wf_item_type VARCHAR2(100);

L_mapping_component_id NUMBER;

l_project_id  number;
l_approval_style_id  number;
l_parent_comp_id  number;
l_parent_object_version_number  number;

l_object_version_number NUMBER;
l_object_version_number_old NUMBER;
L_APPROVAL_COMP_ID NUMBER;
l_time_category_id NUMBER;
l_time_category_comp_id_old NUMBER;
l_time_category_id_old NUMBER;
l_manager_id NUMBER;
l_time_category_comp_id NUMBER;
l_flex_value_set_id NUMBER;


l_approval_mechanism  VARCHAR2(100);
l_mechanism_id NUMBER;
l_def_approval_mech VARCHAR2(100);
l_def_approval_mech_id NUMBER;
l_dyn_sql VARCHAR2(2000);
l_time_category_name  hxc_time_categories.TIME_CATEGORY_NAME%TYPE;


  l_proc varchar2(100);
begin

	g_debug := hr_utility.debug_enabled;

	  if g_debug then
	  	l_proc := 'hxc_proj_manager_approval_pkg.create_tim_cat';
	  	hr_utility.set_location(l_proc, 10);
	  end if;

	l_project_id := p_project_id;
	l_approval_style_id := p_approval_style_id;
	l_parent_comp_id := p_parent_comp_id;
	l_parent_object_version_number  := p_parent_object_version_number  ;


	l_approval_mechanism  := 'PERSON';

/* get the Manager id of the project */

	l_dyn_sql := 'BEGIN '|| fnd_global.newline
              || ':1 := Pa_Otc_Api.GetProjectManager'  ||fnd_global.newline
              ||'(p_project_id => :2);'   ||fnd_global.newline
              ||'END;';

	EXECUTE IMMEDIATE l_dyn_sql
              using OUT l_manager_id, IN l_project_id;

---	l_mechanism_id :=  l_manager_id;

/* if the manager id is null then the project will go into a time category for all such left out entries .We are choosing the value -1 for manager id when it is null */
	IF l_manager_id is NOT NULL
	THEN

/*
		  if g_debug then
		  	hr_utility.set_location(l_proc, 20);
		  end if;
		l_manager_id := -1;
		IF p_default_approval_mechanism  IS NOT NULL
		THEN
		l_approval_mechanism  := p_default_approval_mechanism ;
		ELSE
		l_approval_mechanism  :=  'HR_SUPERVISOR';
		END IF;

		l_mechanism_id            :=  p_mechanism_id;

	END IF;         */

		p_manager_id := l_manager_id;            -- setting the OUT parameter
		l_mechanism_id :=  l_manager_id;


              l_time_category_name  := 'PROJECT MANAGER :: ' || l_manager_id  || ' SYSTEM GENERATED DO NOT MODIFY';


/* Passing the time category name we check whether the time category already exists. If it exists then gets the time category id */

OPEN csr_get_time_category_name(l_time_category_name);
FETCH csr_get_time_category_name into l_time_category_id;

if csr_get_time_category_name%NOTFOUND
then
	  if g_debug then
	  	hr_utility.set_location(l_proc, 30);
	  end if;

              l_object_version_number := 0;


/* As the time category does not exist we are creating a new Time category */

	hxc_time_category_api.create_time_category(
	p_time_category_id	  => l_time_category_id
	,p_object_version_number  => l_object_version_number
	,p_time_category_name     => l_time_category_name
	,p_operator               => 'OR'
	,p_description            => 'Created for Project Manager Approval'
	,p_display                =>  'N' );


-----------------------     Creating Approval Component for each Time Category-----------------+
/* As a new Time Category has been created we also need to create a corresponding Approval Component with the just created Time Category */


    hxc_approval_comps_api.create_approval_comps(
               p_approval_mechanism      => l_approval_mechanism,
	 p_approval_mechanism_id         =>  l_mechanism_id,
               p_approval_style_id       =>  l_approval_style_id,
               p_time_recipient_id       =>   -1,
	       p_approval_order          =>  10,
               p_approval_comp_id        =>  l_approval_comp_id,
               p_object_version_number   =>  l_object_version_number,
		p_wf_item_type           =>  p_wf_item_type ,
		p_wf_name                =>  p_wf_name,
	 	p_start_date  	         =>  SYSDATE,
	 	p_end_date               =>  hr_general.end_of_time,
               p_time_category_id        => l_time_category_id,
               p_parent_comp_id          => l_parent_comp_id,
               p_parent_comp_ovn         => l_parent_object_version_number
               );

/*

-- The following code is commented out as it was originally added for updating the default approval mechanism selected  through the Concurrent program


ELSE

-- If the Time Category  consists of Left out entries( projects without managers ) then we need
---      to make sure the approval mechanism for the left out entries has not changed. So if
--       the new approval mechanism is not null and is also different from the already existing
--       approval mechanism then we need to update the approval component for the left out entries


	 if g_debug then
	 	hr_utility.set_location(l_proc, 40);
	 end if;


	IF l_time_category_name = 'PROJECT MANAGER :: -1 SYSTEM GENERATED DO NOT MODIFY' and p_default_approval_mechanism IS NOT NULL and g_update_flag  = 0
	THEN
	  if g_debug then
	  	hr_utility.set_location(l_proc, 50);
	  end if;


-- Getting the approval mechanism and approval mechanism id of the approval component for left out entries

OPEN csr_get_approval_mechanism( l_approval_style_id, l_time_category_id  );
FETCH csr_get_approval_mechanism INTO l_def_approval_mech , l_def_approval_mech_id, l_approval_comp_id, l_object_version_number, l_wf_name, l_wf_item_type;



-- checking if the presently specified approval mechanism and mechanism id match with those already present

		IF l_def_approval_mech <> l_approval_mechanism
		THEN
			g_update_flag := 1;
		ELSE
			IF  l_approval_mechanism = 'WORKFLOW'
			THEN

			IF l_wf_name <> p_wf_name OR l_wf_item_type <> p_wf_item_type
			THEN
				g_update_flag := 1;
			END IF;

			ELSE
			IF l_def_approval_mech_id <> l_mechanism_id
			THEN
				g_update_flag := 1;
			END IF;
			END IF;        --        end if for workflow check
		END IF;

-- As the mechanism or mechanism id has changed update the approval component
			---- update

IF g_update_flag = 1
THEN
	  if g_debug then
	  	hr_utility.set_location(l_proc, 60);
	  end if;

	hxc_approval_comps_api.update_approval_comps
	  (
	  p_approval_comp_id             => l_approval_comp_id
	  ,p_object_version_number       => l_object_version_number
	  ,p_approval_mechanism          =>  l_approval_mechanism
	  ,p_approval_mechanism_id       =>  l_mechanism_id
	  ,p_time_recipient_id           =>   -1
                ,p_approval_style_id     => l_approval_style_id
	  ,p_wf_item_type                =>  p_wf_item_type
	  ,p_wf_name                     =>  p_wf_name
	  ,p_start_date                  => sysdate
	  ,p_end_date                    =>  hr_general.end_of_time
	  ,p_time_category_id            => l_time_category_id
	  ,p_parent_comp_id              =>  l_parent_comp_id
	  ,p_parent_comp_ovn             => l_parent_object_version_number );

END IF;
CLOSE csr_get_approval_mechanism;
	  if g_debug then
	  	hr_utility.set_location(l_proc, 70);
	  end if;
END IF;

*/
end if;	-----    if not found loop
CLOSE csr_get_time_category_name ;
ELSE
 l_time_category_id := -99;           ---   Manager id is NULL, so make it -99
END IF;


  l_object_version_number := 0;
/* get the flex_value_set_id of the value set HXC_ALL_PROJECTS_ID */

OPEN csr_get_flex_value_set_id;
FETCH csr_get_flex_value_set_id into l_flex_value_set_id;
CLOSE csr_get_flex_value_set_id;

/* get the time category id, time category comp id and  ovn  of the record with specified project id
----      and flex value set id. We are basically trying to check whether the project is present in
----      the correct time category or any change in project set up has happened. If the cursor does
----      not fetch any values then it means that the project is not present in any time category and
----      we need to create a new time category component with the project. On the other hand if the cursor
----      fetches some values and they do not match the present time category then we need to remove the
------    project from the old time category and add it to the new time category */

OPEN csr_find_time_category_comp(l_project_id);
FETCH csr_find_time_category_comp into l_time_category_comp_id_old,l_object_version_number_old,l_time_category_id_old;



IF l_time_category_id_old <>   l_time_category_id OR csr_find_time_category_comp%NOTFOUND
THEN
	  if g_debug then
	  	hr_utility.set_location(l_proc, 80);
	  end if;

	IF csr_find_time_category_comp%FOUND
	THEN
		  if g_debug then
		  	hr_utility.set_location(l_proc, 90);
		  end if;

/* The project set-up has changed and so we need to delete previous time cat comp and then add new one */
		-- dele

		hxc_time_category_comp_api.delete_time_category_comp
		 (  p_time_category_comp_id   => l_time_category_comp_id_old
		     ,p_object_version_number   => l_object_version_number_old
		   );

                --
                -- Clear the time category cache, so that the new component
                -- is used properly - bug 5469357
                --
                if hxc_time_category_utils_pkg.reset_cache then
                  null;
                end if;

	END IF;
		  if g_debug then
		  	hr_utility.set_location(l_proc, 100);
		  end if;



IF l_time_category_id <> -99
THEN
/* Creating a new time category comp */
--  neo
OPEN csr_get_map_comp_id;
FETCH csr_get_map_comp_id INTO L_mapping_component_id ;
CLOSE csr_get_map_comp_id;

	hxc_time_category_comp_api.create_time_category_comp
	(  p_validate                    => FALSE
	  ,p_time_category_comp_id	=> l_time_category_comp_id
	  ,p_object_version_number	=> l_object_version_number
	  ,p_ref_time_category_id       => null
	  ,p_time_category_id           => l_time_category_id
	  ,p_component_type_id          => L_mapping_component_id
	  ,p_flex_value_set_id          => l_flex_value_set_id
	  ,p_value_id             	=> l_project_id
	  ,p_is_null              	=> 'Y'
	  ,p_equal_to                   => 'Y'
	  ,p_type                      	=>    'MC'
	);
        --
        -- Clear the time category cache, so that the new component
        -- is used properly - bug 5469357
        --
        if hxc_time_category_utils_pkg.reset_cache then
          null;
        end if;

END IF;                  --        l_time_category_id <> -99

END IF;
CLOSE csr_find_time_category_comp;



end  create_time_cat;







PROCEDURE replace_projman_by_spl_ela( p_tab_project_id  in out NOCOPY tab_project_id ,
				      p_new_spl_ela_style_id out NOCOPY number
				    )
is
l_project_id NUMBER;
l_approval_style_id NUMBER;
l_approval_comp_id NUMBER;
l_object_version_number NUMBER;
l_index NUMBER;
l_time_recipient_id NUMBER;
l_parent_comp_id NUMBER;
l_parent_object_version_number NUMBER;

l_approval_comp_id_1  NUMBER;
l_object_version_number_1  NUMBER;
l_manager_id NUMBER;

  l_proc varchar2(100);
begin

	g_debug := hr_utility.debug_enabled;

		  if g_debug then
		  	l_proc := 'hxc_proj_manager_approval_pkg.replace_by_spl_ela';
		  	hr_utility.set_location(l_proc, 10);
		  end if;

open csr_get_recipient_id;
Fetch csr_get_recipient_id into l_time_recipient_id;
close csr_get_recipient_id;

/* Checking if the standard Special ELA Style already exists. If it exists it returns the approval_style_id of the Special ELA Approval Style */

OPEN g_csr_get_approval_style;
FETCH g_csr_get_approval_style into l_approval_style_id;

IF g_csr_get_approval_style%NOTFOUND
THEN
		  if g_debug then
		  	hr_utility.set_location(l_proc, 20);
		  end if;


    hxc_approval_styles_api.create_approval_styles(
            p_name                     =>'SEEDED_APPL_PA_MGR',
            p_approval_style_id        => l_approval_style_id,
            p_object_version_number    => l_object_version_number);

/* Creating the ENTRY_LEVEL_APPROVAL approval component for the above created Special ELA Approval Style */
    hxc_approval_comps_api.create_approval_comps(
                p_approval_mechanism      =>  'ENTRY_LEVEL_APPROVAL',
                p_approval_style_id        =>  l_approval_style_id,
                p_time_recipient_id        =>   l_time_recipient_id,
                p_approval_order           =>  10,
                p_approval_comp_id         =>  l_approval_comp_id,
                p_object_version_number    =>  l_object_version_number,
	 p_start_date  	        	   =>  SYSDATE,
	 p_end_date                        =>  hr_general.end_of_time
               );

l_parent_comp_id			:= l_approval_comp_id ;
l_parent_object_version_number      	:= l_object_version_number;

/* Creating the mandatory default approval style for ELA, */

    hxc_approval_comps_api.create_approval_comps(
               p_approval_mechanism          => 'HR_SUPERVISOR',
               p_approval_style_id           =>  l_approval_style_id,
               p_time_recipient_id           =>   -1,
               p_approval_order              =>  10,
               p_approval_comp_id            =>  l_approval_comp_id_1,
               p_object_version_number       =>  l_object_version_number_1,
	 p_start_date  	          	     =>  SYSDATE,
	 p_end_date                          =>  hr_general.end_of_time,
               p_time_category_id            => 0,
               p_parent_comp_id              => l_parent_comp_id,
               p_parent_comp_ovn             => l_parent_object_version_number
               );

ELSE
/* If the special ELA approval style exists then get the ENTRY_LEVEL_APPROVAL approval component id associated with the special ELA approval style */

		  if g_debug then
		  	hr_utility.set_location(l_proc, 30);
		  end if;


OPEN csr_get_ela_approval_comp(l_approval_style_id);
FETCH csr_get_ela_approval_comp INTO l_approval_comp_id , l_object_version_number;
CLOSE csr_get_ela_approval_comp;
END IF;
CLOSE g_csr_get_approval_style;
----   putting value into OUT parameter
p_new_spl_ela_style_id  	        :=  l_approval_style_id;



/* Looping through all the projects in the input parameter p_tab_project_id */

l_index := p_tab_project_id.first;
WHILE l_index IS NOT NULL LOOP

l_project_id  :=   p_tab_project_id( l_index ).project_id;

/* Call the create_time_cat procedure to do further processing */
create_time_cat( p_project_id  => l_project_id,
		p_approval_style_id => l_approval_style_id,
		p_parent_comp_id => l_approval_comp_id,
		p_parent_object_version_number => l_object_version_number,
		p_manager_id => l_manager_id    );

p_tab_project_id( l_index ).manager_id := l_manager_id;


l_index := p_tab_project_id.next( l_index );
END LOOP;
		  if g_debug then
		  	hr_utility.set_location(l_proc, 40);
		  end if;

commit;

end replace_projman_by_spl_ela;

end hxc_proj_manager_approval_pkg;

/
