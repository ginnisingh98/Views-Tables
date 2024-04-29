--------------------------------------------------------
--  DDL for Package HXC_PUBLIC_TEMP_GROUP_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PUBLIC_TEMP_GROUP_COMP_API" AUTHID CURRENT_USER as
/* $Header: hxcptgapi.pkh 120.1 2005/10/04 05:41:45 sechandr noship $ */


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
);

-- --------------------------------------------------------------
-- |-------------<Insert Of Public Template Group Comps>---------|
-- --------------------------------------------------------------

PROCEDURE insert_public_temp_grp_comp(
  p_entity_group_id   IN NUMBER
 ,p_entity_id         IN NUMBER
 ,p_attribute1        IN VARCHAR2
 ,p_attribute_category IN VARCHAR2
);


-- --------------------------------------------------------------
-- |-------------<Delete Of Public Template Group >-------------|
-- --------------------------------------------------------------

PROCEDURE del_entity_group_rec(
 p_entity_group_id    IN  NUMBER,
 p_business_group_id IN NUMBER,
 p_attached_pref_name OUT NOCOPY VARCHAR2
);



-- --------------------------------------------------------------
-- |-------------<Delete Of Public Template Group Comps>--------|
-- --------------------------------------------------------------

PROCEDURE del_entity_group_comp_rec(
 p_entity_group_id    IN  NUMBER
,p_entity_id    IN  VARCHAR2
);


-- --------------------------------------------------------------
-- |------------<Update Of Public Template Group Comps>---------|
-- --------------------------------------------------------------

PROCEDURE update_public_temp_grp_comp(
   p_entity_group_id   IN NUMBER
  ,p_entity_id         IN HXC_TEMPLATE_ID_TABLE
 );



-- --------------------------------------------------------------
-- |-------------<Update Of Public Template Group >-------------|
-- --------------------------------------------------------------

PROCEDURE update_entity_group_rec(
 p_entity_group_id    IN OUT NOCOPY  NUMBER
,p_name   IN VARCHAR2
,p_description  IN VARCHAR2
);


-- --------------------------------------------------------------
-- |----------<Create API Of Public Template Group Comp >-------|
-- --------------------------------------------------------------

PROCEDURE create_public_temp_grp_comp(
   p_entity_group_id   IN NUMBER
  ,p_entity_id         IN HXC_TEMPLATE_ID_TABLE
 );


-- --------------------------------------------------------------------
-- |----------<List of Preferences in which group is attached >-------|
-- --------------------------------------------------------------------

FUNCTION public_temp_group_list(
	p_public_template_group_id IN NUMBER,
        p_business_group_id IN NUMBER
       )
  RETURN VARCHAR2;

-- ----------------------------------------------------------------------------------
-- |----------< Checks whether deletion of public template is allowed >-------|
-- ----------------------------------------------------------------------------------

FUNCTION can_delete_public_template (p_template_id in  hxc_time_building_blocks.time_building_block_id%type
				     ) RETURN VARCHAR2;

END hxc_public_temp_group_comp_api;

 

/
