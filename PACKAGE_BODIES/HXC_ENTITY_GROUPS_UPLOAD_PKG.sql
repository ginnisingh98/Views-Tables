--------------------------------------------------------
--  DDL for Package Body HXC_ENTITY_GROUPS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ENTITY_GROUPS_UPLOAD_PKG" AS
/* $Header: hxcetgupl.pkb 120.2 2005/09/23 08:08:24 sechandr noship $ */

g_debug boolean	:=hr_utility.debug_enabled;

FUNCTION GET_ENTITY_GROUP_ID(p_entity_type in varchar2, p_name in varchar2)
RETURN NUMBER IS

cursor c_get_egroup_id (l_p_entity_type in varchar2, l_p_name in varchar2) IS
	SELECT entity_group_id FROM hxc_entity_groups
	WHERE entity_type = l_p_entity_type and name = l_p_name;
l_entity_group_id HXC_ENTITY_GROUPS.ENTITY_GROUP_ID%TYPE;
BEGIN
	OPEN c_get_egroup_id(p_entity_type, p_name);
	FETCH c_get_egroup_id INTO l_entity_group_id ;
	CLOSE c_get_egroup_id;

RETURN l_entity_group_id ;

END GET_ENTITY_GROUP_ID;


PROCEDURE LOAD_ENTITY_GROUP_ROW(
 P_NAME                            IN VARCHAR2,
 P_ENTITY_TYPE                     IN VARCHAR2,
 P_OWNER		    	   IN VARCHAR2,
 P_CUSTOM_MODE            	   IN VARCHAR2 DEFAULT NULL) IS

l_entity_group_id  HXC_ENTITY_GROUPS.ENTITY_GROUP_ID%TYPE;
l_entity_type	   HXC_ENTITY_GROUPS.ENTITY_TYPE%TYPE;
l_ovn		   HXC_ENTITY_GROUPS.object_version_number%TYPE;
l_owner   	   VARCHAR2(6);

BEGIN

	g_debug:=hr_utility.debug_enabled;
	if g_debug then
		hr_utility.trace('P_NAME ='||P_NAME );
	end if;
	SELECT  entity_group_id,
		entity_type,
		object_version_number,
		DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO
		  l_entity_group_id,
		  l_entity_type ,
		  l_ovn,
		  l_owner
	FROM hxc_entity_groups
	WHERE name = p_name and entity_type = p_entity_type;

 -- IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
 -- THEN
	  -- only update if the entity type has actually changed
	 IF (  ( p_entity_type <> l_entity_type ) )
	 THEN
       		hxc_heg_upd.upd
		  (p_entity_group_id         => l_entity_group_id
		  ,p_object_version_number   => l_ovn
		  ,p_name                    => p_name
		  ,p_entity_type             => p_entity_type
		  ) ;
         END IF;
 -- END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN
BEGIN hxc_heg_ins.ins
	  (p_name              	    => p_name
	  ,p_entity_type       	    => p_entity_type
	  ,p_entity_group_id        => l_entity_group_id
	  ,p_object_version_number  => l_ovn
	  ) ;
END;
END LOAD_ENTITY_GROUP_ROW;


PROCEDURE LOAD_ENTITY_GROUP_COMPS_ROW(
	 P_ENTITY_TYPE IN VARCHAR2,
	 P_NAME	       IN VARCHAR2,
	 P_ATTRIBUTE_CATEGORY IN VARCHAR2,
	 P_ATTRIBUTE1 IN VARCHAR2,
	 P_ATTRIBUTE2 IN VARCHAR2,
	 P_ATTRIBUTE3 IN VARCHAR2,
	 P_OWNER      IN VARCHAR2,
	 P_CUSTOM_MODE IN VARCHAR2 ) IS

l_entity_group_comp_id HXC_ENTITY_GROUP_COMPS.ENTITY_GROUP_comp_ID%TYPE;
l_object_version_number HXC_ENTITY_GROUP_COMPS.OBJECT_VERSION_NUMBER%TYPE;
l_entity_group_id HXC_ENTITY_GROUPS.ENTITY_GROUP_ID%TYPE;

l_owner	VARCHAR2(6);

BEGIN
	-- check to see row exists


	l_entity_group_id := GET_ENTITY_GROUP_ID(P_ENTITY_TYPE,P_NAME);
	g_debug:=hr_utility.debug_enabled;
	if g_debug then
		hr_utility.trace('l_entity_group_id'||l_entity_group_id);
	end if;

	SELECT
		entity_group_comp_id,
		OBJECT_VERSION_NUMBER,
		DECODE( NVL(last_updated_by,-1),1, 'SEED', 'CUSTOM')
 	INTO
 		l_entity_group_comp_id,
 		l_object_version_number,
 		l_owner
	FROM 	hxc_entity_group_comps
	WHERE	entity_group_id = l_entity_group_id
	AND   	attribute_category = P_ATTRIBUTE_CATEGORY;

	if g_debug then
		hr_utility.trace('l_entity_group_comp_id=2='||l_entity_group_comp_id);
		hr_utility.trace('p_custom_mode='||p_custom_mode);
		hr_utility.trace('l_owner ='||l_owner );
	end if;

	-- IF ( p_custom_mode = 'FORCE' OR l_owner = 'SEED' )
	-- THEN
		if g_debug then
			hr_utility.trace('Starting to upd --');
		end if;
		  hxc_egc_upd.upd(
		     p_entity_group_comp_id   => l_entity_group_comp_id
		    ,p_object_version_number  => l_object_version_number
		    ,p_entity_group_id        => l_entity_group_id
		    ,p_entity_id              => -1
		    ,p_entity_type            => P_ENTITY_TYPE
		    ,p_attribute_category     => P_ATTRIBUTE_CATEGORY
		    ,p_attribute1             => P_ATTRIBUTE1
		    ,p_attribute2             => P_ATTRIBUTE2
		    ,p_attribute3             => P_ATTRIBUTE3
		    ,p_effective_date 	      => sysdate
		    ,p_called_from_form	      => null
		);
		if g_debug then
			hr_utility.trace('Finishing from upd --');
		end if;
	-- END IF;

	EXCEPTION WHEN NO_DATA_FOUND
	THEN
 	BEGIN
 		if g_debug then
			hr_utility.trace('Starting to ins--');
		end if;

	  	hxc_egc_ins.ins(
		     p_entity_group_comp_id   => l_entity_group_comp_id
		    ,p_object_version_number  => l_object_version_number
		    ,p_entity_group_id        => l_entity_group_id
		    ,p_entity_id              => -1
		    ,p_entity_type            => P_ENTITY_TYPE
		    ,p_attribute_category     => P_ATTRIBUTE_CATEGORY
		    ,p_attribute1             => P_ATTRIBUTE1
		    ,p_attribute2             => P_ATTRIBUTE2
		    ,p_attribute3             => P_ATTRIBUTE3
		    ,p_effective_date 	      => sysdate
		    ,p_called_from_form	      => null
		  );
	 	if g_debug then
			hr_utility.trace('Finishing to ins--');
		end if;
	END;

END LOAD_ENTITY_GROUP_COMPS_ROW;

PROCEDURE LOAD_ENTITY_GROUP_ROW(
 P_NAME                            IN VARCHAR2,
 P_ENTITY_TYPE                     IN VARCHAR2,
 P_OWNER		    	   IN VARCHAR2,
 P_CUSTOM_MODE            	   IN VARCHAR2 DEFAULT NULL
 ,p_last_update_date         IN VARCHAR2) IS

l_entity_group_id  HXC_ENTITY_GROUPS.ENTITY_GROUP_ID%TYPE;
l_entity_type	   HXC_ENTITY_GROUPS.ENTITY_TYPE%TYPE;
l_ovn		   HXC_ENTITY_GROUPS.object_version_number%TYPE;
l_last_update_date_db              HXC_ENTITY_GROUPS.last_update_date%TYPE;
l_last_updated_by_db               HXC_ENTITY_GROUPS.last_updated_by%TYPE;
l_last_updated_by_f              HXC_ENTITY_GROUPS.last_updated_by%TYPE;
l_last_update_date_f               HXC_ENTITY_GROUPS.last_update_date%TYPE;

BEGIN

	l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
	l_last_update_date_f := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
	g_debug:=hr_utility.debug_enabled;

	if g_debug then
		hr_utility.trace('P_NAME ='||P_NAME );
	end if;

	SELECT  entity_group_id,
		entity_type,
		object_version_number
		,last_update_date
			,last_updated_by

	INTO
		  l_entity_group_id,
		  l_entity_type ,
		  l_ovn
		  ,l_last_update_date_db
                        ,l_last_updated_by_db

	FROM hxc_entity_groups
	WHERE name = p_name and entity_type = p_entity_type;

IF (fnd_load_util.upload_test(	l_last_updated_by_f,
					l_last_update_date_f,
	                        	 l_last_updated_by_db,
					l_last_update_date_db ,
					 p_custom_mode))
 THEN
	  -- only update if the entity type has actually changed
	 IF (  ( p_entity_type <> l_entity_type ) )
	 THEN
       		hxc_heg_upd.upd
		  (p_entity_group_id         => l_entity_group_id
		  ,p_object_version_number   => l_ovn
		  ,p_name                    => p_name
		  ,p_entity_type             => p_entity_type
		  ) ;
         END IF;
 END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN
BEGIN hxc_heg_ins.ins
	  (p_name              	    => p_name
	  ,p_entity_type       	    => p_entity_type
	  ,p_entity_group_id        => l_entity_group_id
	  ,p_object_version_number  => l_ovn
	  ) ;
END;
END LOAD_ENTITY_GROUP_ROW;


PROCEDURE LOAD_ENTITY_GROUP_COMPS_ROW(
	 P_ENTITY_TYPE IN VARCHAR2,
	 P_NAME	       IN VARCHAR2,
	 P_ATTRIBUTE_CATEGORY IN VARCHAR2,
	 P_ATTRIBUTE1 IN VARCHAR2,
	 P_ATTRIBUTE2 IN VARCHAR2,
	 P_ATTRIBUTE3 IN VARCHAR2,
	 P_OWNER      IN VARCHAR2,
	 P_CUSTOM_MODE IN VARCHAR2
	 ,p_last_update_date         IN VARCHAR2) IS

l_entity_group_comp_id HXC_ENTITY_GROUP_COMPS.ENTITY_GROUP_comp_ID%TYPE;
l_object_version_number HXC_ENTITY_GROUP_COMPS.OBJECT_VERSION_NUMBER%TYPE;
l_entity_group_id HXC_ENTITY_GROUPS.ENTITY_GROUP_ID%TYPE;

l_last_update_date_db              HXC_ENTITY_GROUP_COMPS.last_update_date%TYPE;
l_last_updated_by_db               HXC_ENTITY_GROUP_COMPS.last_updated_by%TYPE;
l_last_updated_by_f               HXC_ENTITY_GROUP_COMPS.last_updated_by%TYPE;
l_last_update_date_f              HXC_ENTITY_GROUP_COMPS.last_update_date%TYPE;

BEGIN
	-- check to see row exists

	l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
	l_last_update_date_f := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
	l_entity_group_id := GET_ENTITY_GROUP_ID(P_ENTITY_TYPE,P_NAME);
	g_debug:=hr_utility.debug_enabled;

	if g_debug then
		hr_utility.trace('l_entity_group_id'||l_entity_group_id);
	end if;

	SELECT
		entity_group_comp_id,
		OBJECT_VERSION_NUMBER
		,last_update_date
			,last_updated_by
 	INTO
 		l_entity_group_comp_id,
 		l_object_version_number
 		,l_last_update_date_db
                        ,l_last_updated_by_db
	FROM 	hxc_entity_group_comps
	WHERE	entity_group_id = l_entity_group_id
	AND   	attribute_category = P_ATTRIBUTE_CATEGORY;

	if g_debug then
		hr_utility.trace('l_entity_group_comp_id=2='||l_entity_group_comp_id);
		hr_utility.trace('p_custom_mode='||p_custom_mode);
	end if;

	IF (fnd_load_util.upload_test(	l_last_updated_by_f,
					l_last_update_date_f,
	                        	 l_last_updated_by_db,
					l_last_update_date_db ,
					 p_custom_mode))
	THEN
		if g_debug then
			hr_utility.trace('Starting to upd --');
		end if;
		  hxc_egc_upd.upd(
		     p_entity_group_comp_id   => l_entity_group_comp_id
		    ,p_object_version_number  => l_object_version_number
		    ,p_entity_group_id        => l_entity_group_id
		    ,p_entity_id              => -1
		    ,p_entity_type            => P_ENTITY_TYPE
		    ,p_attribute_category     => P_ATTRIBUTE_CATEGORY
		    ,p_attribute1             => P_ATTRIBUTE1
		    ,p_attribute2             => P_ATTRIBUTE2
		    ,p_attribute3             => P_ATTRIBUTE3
		    ,p_effective_date 	      => sysdate
		    ,p_called_from_form	      => null
		);
		if g_debug then
			hr_utility.trace('Finishing from upd --');
		end if;
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND
	THEN
 	BEGIN
 		if g_debug then
			hr_utility.trace('Starting to ins--');
	 	end if;

	  	hxc_egc_ins.ins(
		     p_entity_group_comp_id   => l_entity_group_comp_id
		    ,p_object_version_number  => l_object_version_number
		    ,p_entity_group_id        => l_entity_group_id
		    ,p_entity_id              => -1
		    ,p_entity_type            => P_ENTITY_TYPE
		    ,p_attribute_category     => P_ATTRIBUTE_CATEGORY
		    ,p_attribute1             => P_ATTRIBUTE1
		    ,p_attribute2             => P_ATTRIBUTE2
		    ,p_attribute3             => P_ATTRIBUTE3
		    ,p_effective_date 	      => sysdate
		    ,p_called_from_form	      => null
		  );
	 	if g_debug then
			hr_utility.trace('Finishing to ins--');
		end if;
	END;

END LOAD_ENTITY_GROUP_COMPS_ROW;


END hxc_entity_groups_upload_pkg;

/
