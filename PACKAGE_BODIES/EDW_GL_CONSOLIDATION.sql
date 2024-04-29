--------------------------------------------------------
--  DDL for Package Body EDW_GL_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GL_CONSOLIDATION" AS
/* $Header: FIIECONB.pls 120.2 2005/08/30 15:05:22 sgautam noship $ */

procedure edw_get_cons_flex_value (
 p_coa_mapping_id      IN  gl_cons_segment_map.coa_mapping_id%TYPE,
 p_cons_from_flex_set_id IN  fnd_flex_values.FLEX_VALUE_SET_ID%TYPE ,
 p_cons_to_flex_set_id   IN  fnd_flex_values.FLEX_VALUE_SET_ID%TYPE ,
 p_cons_from_flex_value	 IN  fnd_flex_values.FLEX_VALUE%TYPE ,
 p_parent_flag		 IN  varchar2,
 p_cons_to_flex_value    OUT NOCOPY /* file.sql.39 change */ fnd_flex_values.FLEX_VALUE%TYPE ,
 p_return_msg            OUT NOCOPY /* file.sql.39 change */ varchar2,
 p_status                OUT NOCOPY /* file.sql.39 change */ boolean
) IS

l_map_type	gl_cons_segment_map.segment_map_type%TYPE;
l_proc_name 	varchar2(30) :='EDW_GET_CONS_FLEX_VALUE';

diamond_problem		exception;
no_return_value		exception;

CURSOR csr_get_cons_to_value (
	p_from_value_set_id 	in number,
	p_to_value_set_id 	in number,
	p_coa_mapping_id 	in number,
	p_from_value 		in varchar2
) IS
SELECT 	cfh.parent_flex_value 	parent,
	csm.segment_map_type 	segment_map_type
FROM	gl_cons_segment_map 	csm,
        gl_cons_flex_hierarchies cfh
WHERE 	cfh.segment_map_id 	= csm.segment_map_id
AND	csm.segment_map_type 	= 'R'
AND	csm.from_value_set_id 	= p_from_value_set_id
AND	csm.to_value_set_id	= p_to_value_set_id
AND	csm.coa_mapping_id	= p_coa_mapping_id
AND	p_from_value between cfh.child_flex_value_low
		         and cfh.child_flex_value_high
UNION ALL
SELECT	csm.single_value 	parent,
	csm.segment_map_type 	segment_map_type
FROM	gl_cons_segment_map 	csm
WHERE	csm.segment_map_type 	= 'P'
AND	csm.from_value_set_id 	= p_from_value_set_id
AND	csm.to_value_set_id	= p_to_value_set_id
AND	csm.coa_mapping_id	= p_coa_mapping_id
AND	p_from_value		= csm.parent_rollup_value
UNION ALL
SELECT	csm.single_value 	parent,
	csm.segment_map_type 	segment_map_type
FROM	gl_cons_segment_map 	csm
WHERE	csm.segment_map_type	= 'C'
AND	csm.from_value_set_id 	= p_from_value_set_id
AND	csm.to_value_set_id	= p_to_value_set_id
AND	csm.coa_mapping_id	= p_coa_mapping_id
UNION ALL
SELECT	csm.single_value 	parent,
	csm.segment_map_type 	segment_map_type
FROM	gl_cons_segment_map 	csm
WHERE	csm.segment_map_type	= 'S'
AND	csm.to_value_set_id	= p_to_value_set_id
AND	csm.coa_mapping_id	= p_coa_mapping_id;

BEGIN

  open csr_get_cons_to_value(
	p_cons_from_flex_set_id,
	p_cons_to_flex_set_id,
        p_coa_mapping_id,
	p_cons_from_flex_value
	);

  fetch csr_get_cons_to_value
  into p_cons_to_flex_value, l_map_type;

  close csr_get_cons_to_value;

-- Throw exception to avoid 'diamond problem' for map type 'C'

  if (l_map_type = 'C') then

    if (p_parent_flag = 'Y') then
      raise diamond_problem;
    else
      p_cons_to_flex_value := p_cons_from_flex_value;
    end if;

  end if;

-- Throw exception if no return value

  if ( p_cons_to_flex_value is null ) then
    raise no_return_value;
  end if;

  p_return_msg	:= null;
  p_status 	:= true;

EXCEPTION

  WHEN diamond_problem THEN

    p_cons_to_flex_value := null;

    p_return_msg := l_proc_name || ' - not mapped due to diamond problem';

    p_status := false;

  WHEN no_return_value THEN

    p_cons_to_flex_value := null;

    p_return_msg := l_proc_name || ' - no mapping found in API';

    p_status := false;

  WHEN OTHERS THEN

    p_cons_to_flex_value := NULL;

    p_return_msg := substrb(l_proc_name || ' Unexpected Error '
			|| sqlerrm, 1, 240);

    p_status := false;

END EDW_GET_CONS_FLEX_VALUE;

END EDW_GL_CONSOLIDATION ;

/
