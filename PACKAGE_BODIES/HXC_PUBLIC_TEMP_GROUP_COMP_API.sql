--------------------------------------------------------
--  DDL for Package Body HXC_PUBLIC_TEMP_GROUP_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_PUBLIC_TEMP_GROUP_COMP_API" as
/* $Header: hxcptgapi.pkb 120.2 2006/02/16 02:03:16 mbhammar noship $ */
--
-- Package Variables
--
g_package  VARCHAR2(31) := 'hxc_public_temp_group_comp_api';

g_entity_type VARCHAR2(21) := 'PUBLIC_TEMPLATE_GROUP';

g_field_separator VARCHAR2(1) := '|';

g_max_group_retrieve NUMBER(2) := 11;


-- --------------------------------------------------------------
-- |-------------<Insert Of Public Template Group>---------------|
-- --------------------------------------------------------------
PROCEDURE get_entity_group_id(
  p_name                IN VARCHAR2
 ,p_entity_type         IN VARCHAR2
 ,p_entity_group_id     OUT NOCOPY NUMBER
 ,p_description         IN VARCHAR2
 ,p_business_group_id   IN NUMBER
 ,p_legislation_code    IN VARCHAR2
)
IS
    CURSOR csr_group_name_exists IS
     SELECT 'error'
      FROM	dual
      WHERE	 EXISTS (
    	  SELECT	'x'
      	  FROM	hxc_entity_groups heg
        	WHERE	heg.name	= p_name
                and heg.entity_type = 'PUBLIC_TEMPLATE_GROUP'
		and heg.business_group_id = p_business_group_id);

    l_object_version_number HXC_ENTITY_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
    l_error VARCHAR2(5) := NULL;

BEGIN
 OPEN  csr_group_name_exists;
 FETCH csr_group_name_exists INTO l_error;
 CLOSE csr_group_name_exists;

 IF l_error IS NOT NULL
 THEN
  p_entity_group_id := -1 ;
 ELSE
  hxc_heg_ins.ins
  (p_name                   => p_name
  ,p_entity_type            => p_entity_type
  ,p_entity_group_id        => p_entity_group_id
  ,p_object_version_number  => l_object_version_number
  ,p_description            => p_description
  ,p_business_group_id      => p_business_group_id
  ,p_legislation_code       => p_legislation_code
  );
  END IF;
END get_entity_group_id;


-- --------------------------------------------------------------
-- |-------------<Insert Of Public Template Group Comps>---------|
-- --------------------------------------------------------------

PROCEDURE insert_public_temp_grp_comp(
  p_entity_group_id   IN NUMBER
 ,p_entity_id         IN NUMBER
 ,p_attribute1        IN VARCHAR2
 ,p_attribute_category IN VARCHAR2
)
IS
    l_object_version_number HXC_ENTITY_GROUP_COMPS.OBJECT_VERSION_NUMBER%TYPE;
    l_entity_group_comp_id HXC_ENTITY_GROUP_COMPS.ENTITY_GROUP_COMP_ID%TYPE;
    l_attribute2		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE2%TYPE;
    l_attribute3		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE3%TYPE;
    l_attribute4		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE4%TYPE;
    l_attribute5		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE5%TYPE;
    l_attribute6		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE6%TYPE;
    l_attribute7		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE7%TYPE;
    l_attribute8		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE8%TYPE;
    l_attribute9		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE9%TYPE;
    l_attribute10		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE10%TYPE;
    l_attribute11		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE11%TYPE;
    l_attribute12		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE12%TYPE;
    l_attribute13		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE13%TYPE;
    l_attribute14		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE14%TYPE;
    l_attribute15		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE15%TYPE;
    l_attribute16		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE16%TYPE;
    l_attribute17		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE17%TYPE;
    l_attribute18		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE18%TYPE;
    l_attribute19		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE19%TYPE;
    l_attribute20		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE20%TYPE;
    l_attribute21		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE21%TYPE;
    l_attribute22		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE22%TYPE;
    l_attribute23		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE23%TYPE;
    l_attribute24		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE24%TYPE;
    l_attribute25		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE25%TYPE;
    l_attribute26		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE26%TYPE;
    l_attribute27		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE27%TYPE;
    l_attribute28		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE28%TYPE;
    l_attribute29		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE29%TYPE;
    l_attribute30		   HXC_ENTITY_GROUP_COMPS.ATTRIBUTE30%TYPE;

    CURSOR csr_entity_comp_exists IS
     SELECT 'error'
      FROM	dual
      WHERE	 EXISTS (
    	  SELECT	'x'
      	  FROM	hxc_entity_group_comps egc
        	WHERE	egc.entity_group_id	= p_entity_group_id
                AND egc.entity_type = 'PUBLIC_TEMPLATE_GROUP'
            		AND egc.entity_id = p_entity_id );

    CURSOR csr_exists_dynamic_comps IS
     SELECT 'error'
      FROM	dual
      WHERE	 EXISTS (
    	  SELECT	'x'
      	  FROM	hxc_entity_group_comps egc
        	WHERE	egc.entity_group_id	= p_entity_group_id
                AND egc.entity_type = 'PUBLIC_TEMPLATE_GROUP'
            		AND egc.attribute1 = p_attribute1 );


    l_error VARCHAR2(5) := NULL;

BEGIN

 IF (p_entity_id = -1 )
 THEN
   OPEN  csr_exists_dynamic_comps;
   FETCH csr_exists_dynamic_comps INTO l_error;
   CLOSE csr_exists_dynamic_comps;

 ELSE
   OPEN  csr_entity_comp_exists;
   FETCH csr_entity_comp_exists INTO l_error;
   CLOSE csr_entity_comp_exists;
 END IF;

 IF l_error IS NULL
 THEN
   hxc_egc_ins.ins
    (p_effective_date            => sysdate
    ,p_entity_group_id           => p_entity_group_id
    ,p_entity_id                 => p_entity_id
    ,p_entity_type               => 'PUBLIC_TEMPLATE_GROUP'
    ,p_attribute_category        => p_attribute_category
    ,p_attribute1                => p_attribute1
    ,p_attribute2                => l_attribute2
    ,p_attribute3                => l_attribute3
    ,p_attribute4                => l_attribute4
    ,p_attribute5                => l_attribute5
    ,p_attribute6                => l_attribute6
    ,p_attribute7                => l_attribute7
    ,p_attribute8                => l_attribute8
    ,p_attribute9                => l_attribute9
    ,p_attribute10               => l_attribute10
    ,p_attribute11               => l_attribute11
    ,p_attribute12               => l_attribute12
    ,p_attribute13               => l_attribute13
    ,p_attribute14               => l_attribute14
    ,p_attribute15               => l_attribute15
    ,p_attribute16               => l_attribute16
    ,p_attribute17               => l_attribute17
    ,p_attribute18               => l_attribute18
    ,p_attribute19               => l_attribute19
    ,p_attribute20               => l_attribute20
    ,p_attribute21               => l_attribute21
    ,p_attribute22               => l_attribute22
    ,p_attribute23               => l_attribute23
    ,p_attribute24               => l_attribute24
    ,p_attribute25               => l_attribute25
    ,p_attribute26               => l_attribute26
    ,p_attribute27               => l_attribute27
    ,p_attribute28               => l_attribute28
    ,p_attribute29               => l_attribute29
    ,p_attribute30               => l_attribute30
    ,p_entity_group_comp_id      => l_entity_group_comp_id
    ,p_object_version_number     => l_object_version_number
    ,p_called_from_form          => null
    );
   END IF;
END insert_public_temp_grp_comp;


-- --------------------------------------------------------------
-- |-------------<Delete Of Public Template Group >-------------|
-- --------------------------------------------------------------

PROCEDURE del_entity_group_rec(
 p_entity_group_id    IN  NUMBER,
 p_business_group_id  IN NUMBER,
 p_attached_pref_name OUT NOCOPY VARCHAR2
)
IS
    l_object_version_number HXC_ENTITY_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
    l_attached_pref_name VARCHAR2(325) := null;

    CURSOR csr_get_ovn IS
    SELECT
      object_version_number
    FROM	hxc_entity_groups heg
    WHERE	entity_group_id = p_entity_group_id
     AND        heg.business_group_id = p_business_group_id;

BEGIN

 l_attached_pref_name := public_temp_group_list(
	p_entity_group_id ,
	p_business_group_id
       );
 p_attached_pref_name := l_attached_pref_name;

 IF(l_attached_pref_name IS NULL)
 THEN
  OPEN csr_get_ovn;
  FETCH csr_get_ovn INTO l_object_version_number;
  CLOSE csr_get_ovn;

   hxc_heg_del.del
    (p_entity_group_id        => p_entity_group_id
    ,p_object_version_number  => l_object_version_number
   );
 END IF;
END del_entity_group_rec;


-- --------------------------------------------------------------
-- |-------------<Delete Of Public Template Group Comps>--------|
-- --------------------------------------------------------------

PROCEDURE del_entity_group_comp_rec(
 p_entity_group_id    IN  NUMBER
,p_entity_id    IN VARCHAR2
)
IS
    l_object_version_number HXC_ENTITY_GROUP_COMPS.OBJECT_VERSION_NUMBER%TYPE;
    l_entity_group_comp_id HXC_ENTITY_GROUP_COMPS.ENTITY_GROUP_COMP_ID%TYPE;
    l_template_code VARCHAR2(5);

    CURSOR csr_get_entity_comp_id IS
     SELECT
      object_version_number,
      entity_group_comp_id
    FROM
	hxc_entity_group_comps egc
    WHERE
	entity_group_id = p_entity_group_id
        AND entity_id = TO_NUMBER(p_entity_id) ;

    CURSOR csr_get_dynamic_entity_comp_id IS
     SELECT
      object_version_number,
      entity_group_comp_id
     FROM
	 hxc_entity_group_comps egc
     WHERE
	 entity_group_id = p_entity_group_id
         AND attribute1 = p_entity_id ;

BEGIN

 l_template_code := substr(p_entity_id,1,4);

 IF((l_template_code = 'APP|') OR (l_template_code = 'SYS|'))
 THEN
    OPEN csr_get_dynamic_entity_comp_id;
    FETCH csr_get_dynamic_entity_comp_id INTO l_object_version_number, l_entity_group_comp_id;
    CLOSE csr_get_dynamic_entity_comp_id;

 ELSE
    OPEN csr_get_entity_comp_id;
    FETCH csr_get_entity_comp_id INTO l_object_version_number, l_entity_group_comp_id;
    CLOSE csr_get_entity_comp_id;
 END IF;

 IF l_entity_group_comp_id IS NOT NULL
 THEN
 hxc_egc_del.del
  (p_entity_group_comp_id        => l_entity_group_comp_id
  ,p_object_version_number  => l_object_version_number
  );
 END IF;
END del_entity_group_comp_rec;


-- --------------------------------------------------------------
-- |------------<Update Of Public Template Group Comps>---------|
-- --------------------------------------------------------------

PROCEDURE update_public_temp_grp_comp(
   p_entity_group_id   IN NUMBER
  ,p_entity_id         IN HXC_TEMPLATE_ID_TABLE
 )
 IS
     l_count NUMBER;
     l_entity_id VARCHAR2(50);

 BEGIN
l_count:=p_entity_id.first;

LOOP EXIT WHEN NOT p_entity_id.EXISTS(l_count) ;

  l_entity_id := p_entity_id(l_count).entity_id;
  del_entity_group_comp_rec(p_entity_group_id,l_entity_id);
  l_count:=p_entity_id.NEXT(l_count);
END LOOP;
END update_public_temp_grp_comp;


-- --------------------------------------------------------------
-- |-------------<Update Of Public Template Group >-------------|
-- --------------------------------------------------------------

PROCEDURE update_entity_group_rec(
 p_entity_group_id    IN OUT NOCOPY NUMBER
,p_name   IN VARCHAR2
,p_description  IN VARCHAR2
)
IS
    l_object_version_number HXC_ENTITY_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
    l_business_group_id HXC_ENTITY_GROUPS.BUSINESS_GROUP_ID%TYPE;
    l_legislation_code HXC_ENTITY_GROUPS.LEGISLATION_CODE%TYPE;
    l_name HXC_ENTITY_GROUPS.NAME%TYPE;

   CURSOR csr_get_entity_detail IS
    SELECT
       object_version_number
      ,business_group_id
      ,legislation_code
      ,name
    FROM
	hxc_entity_groups heg
    WHERE
	entity_group_id = p_entity_group_id;

   CURSOR csr_exist_template_name(l_business_group_id in HXC_ENTITY_GROUPS.LEGISLATION_CODE%TYPE) IS
     SELECT 'error'
      FROM	dual
      WHERE	 EXISTS (
    	  SELECT	'x'
      	  FROM	hxc_entity_groups heg
        	WHERE	heg.name = p_name
                and heg.entity_type = 'PUBLIC_TEMPLATE_GROUP'
		and heg.business_group_id = l_business_group_id);

    l_error VARCHAR2(5) := NULL;


BEGIN

 OPEN csr_get_entity_detail;
  FETCH csr_get_entity_detail INTO l_object_version_number, l_business_group_id, l_legislation_code, l_name ;
  CLOSE csr_get_entity_detail;

 IF p_name <> l_name
 THEN
  OPEN csr_exist_template_name(l_business_group_id);
   FETCH csr_exist_template_name into l_error;
   CLOSE csr_exist_template_name;
 END IF;

 IF l_error IS NOT NULL
 THEN
  p_entity_group_id := -1 ;
 ELSE
 hxc_heg_upd.upd
  (p_entity_group_id        => p_entity_group_id
  ,p_object_version_number  => l_object_version_number
  ,p_name                   => p_name
  ,p_entity_type            => 'PUBLIC_TEMPLATE_GROUP'
  ,p_description            => p_description
  ,p_business_group_id      => l_business_group_id
  ,p_legislation_code       => l_legislation_code
  );
END IF;

END update_entity_group_rec;

-- --------------------------------------------------------------
-- |----------<Create API Of Public Template Group Comp >-------|
-- --------------------------------------------------------------

PROCEDURE create_public_temp_grp_comp(
   p_entity_group_id   IN NUMBER
  ,p_entity_id         IN HXC_TEMPLATE_ID_TABLE
 )
 IS
     l_error VARCHAR2(5) := NULL;
     l_count NUMBER;
     l_entity_id HXC_ENTITY_GROUP_COMPS.ENTITY_ID%TYPE;
     l_template_id VARCHAR2(50);
     l_template_code VARCHAR2(10);
    BEGIN

l_count:=p_entity_id.first;
LOOP EXIT WHEN NOT p_entity_id.EXISTS(l_count) ;

  l_template_id := p_entity_id(l_count).entity_id;
  l_template_code := substr(l_template_id,1,4);

  IF((l_template_code = 'APP|') OR (l_template_code = 'SYS|'))
  THEN
    insert_public_temp_grp_comp(p_entity_group_id, -1, l_template_id, l_template_id);
  ELSE
    l_entity_id := TO_NUMBER(l_template_id);
    insert_public_temp_grp_comp(p_entity_group_id, l_entity_id, null, 'PUBLIC_TEMPLATE');
  END IF;

  l_count:=p_entity_id.NEXT(l_count);

END LOOP;
END create_public_temp_grp_comp;

-- --------------------------------------------------------------------------
-- |----------< Listing the Preferences which are attached to Group >-------|
-- --------------------------------------------------------------------------

FUNCTION public_temp_group_list(
      p_public_template_group_id IN NUMBER,
      p_business_group_id IN NUMBER
    )
  RETURN VARCHAR2
  IS
    l_public_temp_group_list VARCHAR2(1000) := NULL;
    l_temp_pref_name HXC_PREF_HIERARCHIES_V.PREF_HIERARCHY%TYPE;
--    l_public_template_group_id VARCHAR2(10);


    CURSOR csr_public_temp_group_pref IS
      SELECT
	name PREF_HIERARCHY
      FROM
        HXC_PREF_HIERARCHIES
      WHERE
        attribute_category = 'TC_W_PUBLIC_TEMPLATE'
        AND business_group_id = p_business_group_id
        AND
        (attribute1 = p_public_template_group_id OR
         attribute2 = p_public_template_group_id OR
         attribute3 = p_public_template_group_id OR
         attribute4 = p_public_template_group_id OR
         attribute5 = p_public_template_group_id OR
         attribute6 = p_public_template_group_id OR
         attribute7 = p_public_template_group_id OR
         attribute8 = p_public_template_group_id OR
         attribute9 = p_public_template_group_id OR
         attribute10 =p_public_template_group_id)
         AND ROWNUM < g_max_group_retrieve ;

    BEGIN

    OPEN csr_public_temp_group_pref;
      LOOP
       FETCH csr_public_temp_group_pref INTO l_temp_pref_name;
       EXIT WHEN csr_public_temp_group_pref%NOTFOUND;


       l_public_temp_group_list := l_public_temp_group_list||
                                        l_temp_pref_name||g_field_separator;

      END LOOP;
    CLOSE csr_public_temp_group_pref;


  RETURN substr(l_public_temp_group_list,1,length(l_public_temp_group_list)-1);
 END public_temp_group_list;

-- ----------------------------------------------------------------------------------
-- |----------< Checks whether deletion of public template is allowed >-------|
-- ----------------------------------------------------------------------------------

FUNCTION can_delete_public_template (p_template_id in  hxc_time_building_blocks.time_building_block_id%type
				     ) RETURN VARCHAR2 IS

CURSOR cur_attached_public_temp_grps(p_template_id in  hxc_time_building_blocks.time_building_block_id%type)
IS
SELECT heg.NAME FROM hxc_entity_groups heg ,
		      hxc_entity_group_comps hegc
WHERE
	heg.ENTITY_TYPE = 'PUBLIC_TEMPLATE_GROUP'
	and heg.entity_group_id =hegc.entity_group_id
	and hegc.entity_id = p_template_id and rownum<g_max_group_retrieve;

l_template_grp_name varchar2(150);
l_attached_groups VARCHAR2(1500);
BEGIN

l_attached_groups := NULL;

open cur_attached_public_temp_grps(p_template_id);
loop
	fetch cur_attached_public_temp_grps into l_template_grp_name;
	exit when cur_attached_public_temp_grps%notfound;
	IF l_attached_groups IS NULL THEN
		l_attached_groups := l_template_grp_name;
	ELSE
		l_attached_groups := l_attached_groups||', '||l_template_grp_name;
	END IF;
end loop;

return l_attached_groups;

END can_delete_public_template;

END hxc_public_temp_group_comp_api;

/
