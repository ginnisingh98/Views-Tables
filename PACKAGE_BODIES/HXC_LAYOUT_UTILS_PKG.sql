--------------------------------------------------------
--  DDL for Package Body HXC_LAYOUT_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LAYOUT_UTILS_PKG" as
/* $Header: hxclayoututl.pkb 120.2 2005/09/23 05:27:30 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--

c_attribute_category constant varchar2(18) := 'ATTRIBUTE_CATEGORY';

g_debug boolean := hr_utility.debug_enabled;

FUNCTION get_updatable_components RETURN components_tab IS

CURSOR  csr_get_layout_components ( p_layout_id NUMBER ) IS
SELECT  SUBSTRB(q.qualifier_attribute26,1,30) attribute_category,
        UPPER(SUBSTRB(q.qualifier_attribute27,1,30)) attribute
FROM
	hxc_layout_components c,
	hxc_layout_comp_qualifiers q
WHERE
	c.layout_id = p_layout_id
AND
	q.layout_component_id   = c.layout_component_id AND
	q.qualifier_attribute25 = 'FLEX' AND
	q.qualifier_attribute_category in ('LOV','CHOICE_LIST','PACKAGE_CHOICE_LIST','TEXT_FIELD','DESCRIPTIVE_FLEX');

CURSOR	csr_get_alias_components ( p_alias_definition_id NUMBER ) IS
SELECT	SUBSTRB(bbit.bld_blk_info_type,1,40) attribute_category,
	UPPER(SUBSTRB(mc.segment,1,30)) attribute
FROM
	hxc_alias_definitions ad,
        hxc_alias_types hat,
        hxc_alias_type_components atc,
        hxc_mapping_components mc,
        hxc_bld_blk_info_types bbit
WHERE
	ad.alias_definition_id = p_alias_definition_id
   and ad.alias_type_id = hat.alias_type_id
   and hat.alias_type = 'OTL_ALT_DDF'
   and atc.alias_type_id = hat.alias_type_id
   and atc.mapping_component_id = mc.mapping_component_id
   and bbit.bld_blk_info_type_id = mc.bld_blk_info_type_id;

l_resource_id         fnd_user.user_id%TYPE := fnd_global.employee_id;
l_layout_id           hxc_layouts.layout_id%TYPE;
l_alias_definition_id hxc_alias_definitions.alias_definition_id%TYPE;

l_components_tab components_tab;

l_ind PLS_INTEGER := 1;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
	hr_utility.trace('Entering get updatable comps');

	hr_utility.trace('in layout comps');
	hr_utility.trace('resource id is '||to_char(l_resource_id));
END IF;

l_layout_id := hxc_preference_evaluation.resource_preferences(l_resource_id, 'TC_W_TCRD_LAYOUT', 1);

FOR comps IN csr_get_layout_components ( l_layout_id )
LOOP

	IF ( comps.attribute_category NOT LIKE 'OTL_ALIAS%' )
	THEN

		l_components_tab(l_ind).bld_blk_info_type := comps.attribute_category;
		l_components_tab(l_ind).segment           := comps.attribute;

		l_ind := l_ind + 1;

	ELSE

		-- this is an alias definition

		l_alias_definition_id :=
                  hxc_preference_evaluation.resource_preferences(l_resource_id, 'TC_W_TCRD_ALIASES', 1);

		FOR alias_comps IN csr_get_alias_components ( l_alias_definition_id )
		LOOP

			l_components_tab(l_ind).bld_blk_info_type := alias_comps.attribute_category;
			l_components_tab(l_ind).segment           := alias_comps.attribute;

			l_ind := l_ind + 1;

		END LOOP;

	END IF;

END LOOP;

-- now do something similar for the TimeKeeper Layout Items

FOR x IN 1 .. 20
LOOP

	l_alias_definition_id := hxc_preference_evaluation.resource_preferences(
	                             p_resource_id => l_resource_id,
	                             p_pref_code   => 'TK_TCARD_ATTRIBUTES_DEFINITION',
	                             p_attribute_n => x );

	-- note the query will not return any rows if l_alias_definition_id is null

	FOR alias_comps IN csr_get_alias_components ( l_alias_definition_id )
	LOOP

		l_components_tab(l_ind).bld_blk_info_type := alias_comps.attribute_category;
		l_components_tab(l_ind).segment           := alias_comps.attribute;

		l_ind := l_ind + 1;

	END LOOP;

END LOOP;

IF g_debug THEN
	hr_utility.trace('Leaving get updatable comps');
END IF;

RETURN l_components_tab;


END get_updatable_components;




PROCEDURE reset_non_updatable_comps ( p_attributes IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info ) IS

-- private function to compare the current attribute row to the set of updatable components.
-- if the attribute can be set from the user interface then return FALSE so the value
-- is not reset.

l_att_ind    pls_integer;

l_comps_tab components_tab;

FUNCTION update_ok ( p_att_rec   IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes
                   , p_comps_tab IN            components_tab ) RETURN BOOLEAN IS

BEGIN



IF g_debug THEN
	hr_utility.trace('In update ok');
END IF;

FOR x IN p_comps_tab.FIRST .. p_comps_tab.LAST
LOOP

IF g_debug THEN
	hr_utility.trace('p comps is '||p_comps_tab(x).bld_blk_info_type ||' : '||p_comps_tab(x).segment );
END IF;

	IF ( ( p_comps_tab(x).bld_blk_info_type = p_att_rec.bld_blk_info_type ) AND
	     ( p_comps_tab(x).segment           = p_att_rec.segment ) )
	THEN

		IF g_debug THEN
			hr_utility.trace('Cannot update !!!!');
		END IF;

		RETURN FALSE;

	END IF;
        --
        -- We should never update the attribute category of an attribute
        -- to null, so always return false for that mapping component.
        -- See bug 4269761
        --
	if(p_att_rec.segment = c_attribute_category) then
	   IF g_debug THEN
	   	hr_utility.trace('Can not update attribute category!');
	   END IF;
	   return false;
	end if;

END LOOP;

IF g_debug THEN
	hr_utility.trace('Can update !!!!');
END IF;

RETURN TRUE;

END update_ok;


BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
	hr_utility.trace('Entering reset non updatable comps');
END IF;

l_comps_tab := hxc_layout_utils_pkg.get_updatable_components;

l_att_ind := p_attributes.FIRST;

WHILE l_att_ind IS NOT NULL
LOOP

	IF ( update_ok ( p_attributes(l_att_ind)
                       , l_comps_tab ) )
	THEN

		p_attributes(l_att_ind).attribute_value := NULL;

	END IF;

	l_att_ind := p_attributes.NEXT(l_att_ind);

END LOOP;

IF g_debug THEN
	hr_utility.trace('Leaving reset non updatable comps');
END IF;

END reset_non_updatable_comps;

end hxc_layout_utils_pkg;

/
