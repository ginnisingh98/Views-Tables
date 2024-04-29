--------------------------------------------------------
--  DDL for Package Body HXC_SELF_SERVICE_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SELF_SERVICE_TIMECARD" AS
/* $Header: hxctctprt.pkb 120.23.12010000.15 2010/04/08 10:15:41 amakrish ship $ */

g_package varchar2(30) := 'hxc_self_service_timecard.';
g_one_day               NUMBER  := (1-1/24/3600);
-- Constants for fragment view
c_for_fragment CONSTANT VARCHAR2(8) := 'FRAGMENT';
c_for_approver CONSTANT VARCHAR2(8) := 'APPROVER';

g_debug boolean := hr_utility.debug_enabled;

-- Types created for the Zero Hrs Template Enhancement.

TYPE v_att_ids IS RECORD (
      ATTRIBUTE_CATEGORY   HXC_LAYOUT_COMP_QUALIFIERS.QUALIFIER_ATTRIBUTE26%type,
      ATTRIBUTE_COLUMN_NAME   HXC_LAYOUT_COMP_QUALIFIERS.QUALIFIER_ATTRIBUTE27%type
      );

TYPE r_att_ids IS TABLE OF v_att_ids
      INDEX BY BINARY_INTEGER;


TYPE v_del_bb_ids IS RECORD (
      TIME_BUILDING_BLOCK_ID    NUMBER (15));

TYPE r_del_bb_ids IS TABLE OF v_del_bb_ids
      INDEX BY BINARY_INTEGER;

--Function to get the timecard layout id.

FUNCTION get_timecard_layout_id(p_attribute_array IN HXC_ATTRIBUTE_TABLE_TYPE) RETURN varchar2
is
l_index number;

BEGIN
l_index  := p_attribute_array.FIRST;
	WHILE l_index IS NOT NULL
	LOOP
	   IF(p_attribute_array(l_index).ATTRIBUTE_CATEGORY = 'LAYOUT') THEN
		RETURN p_attribute_array(l_index).ATTRIBUTE1;
	   END IF;
	        l_index := p_attribute_array.NEXT(l_index);
	END LOOP;
RETURN NULL;
end get_timecard_layout_id;

--Function to get the display attributes for the corresponding timecard layout.

PROCEDURE get_layout_display_attributes(p_layout_id in varchar2,
					p_att_ids in out nocopy r_att_ids)
IS
cursor cur_layout_attributes(P_LAYOUT_ID in varchar2) is
select QUALIFIER_ATTRIBUTE26,UPPER(QUALIFIER_ATTRIBUTE27)
       from HXC_LAYOUT_COMP_QUALIFIERS qualifiers
where
	  exists
	   (select LAYOUT_COMPONENT_ID from HXC_LAYOUT_COMPONENTS COMPONENTS where
	    layout_id =P_LAYOUT_ID and COMPONENTS.LAYOUT_COMPONENT_ID = qualifiers.LAYOUT_COMPONENT_ID )
	   and UPPER(QUALIFIER_ATTRIBUTE27) LIKE 'ATTRIBUTE%' and QUALIFIER_ATTRIBUTE_CATEGORY<>'HIDDEN_FIELD';
l_attribute HXC_LAYOUT_COMP_QUALIFIERS.QUALIFIER_ATTRIBUTE26%type;
l_attribute_category HXC_LAYOUT_COMP_QUALIFIERS.QUALIFIER_ATTRIBUTE27%type;
l_index number;
begin

	l_index := 0;
	OPEN cur_layout_attributes(p_layout_id);
	LOOP
	FETCH cur_layout_attributes INTO l_attribute_category,l_attribute;
	EXIT WHEN cur_layout_attributes%NOTFOUND;
		p_att_ids(l_index).ATTRIBUTE_CATEGORY := l_attribute_category;
		p_att_ids(l_index).attribute_column_name :=  l_attribute;
		l_index := l_index+1;
	end loop;
end get_layout_display_attributes;


FUNCTION chk_template_override_appr_set(p_template_attributes IN HXC_ATTRIBUTE_TABLE_TYPE)
RETURN BOOLEAN IS
  l_attribute_index NUMBER;
BEGIN
l_attribute_index := p_template_attributes.first;
    LOOP
          EXIT WHEN NOT p_template_attributes.exists(l_attribute_index);
 	    IF (p_template_attributes(l_attribute_index).ATTRIBUTE_CATEGORY = 'APPROVAL') THEN
              RETURN true;
	    END IF;
   	    l_attribute_index := p_template_attributes.next(l_attribute_index);
      END LOOP;
return false;
END chk_template_override_appr_set;

-- remove the override approver.
PROCEDURE remove_override_approver(p_timecard_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE)
IS
l_attribute_index NUMBER;
BEGIN
      l_attribute_index := p_timecard_attributes.first;
      LOOP
          EXIT WHEN NOT p_timecard_attributes.exists(l_attribute_index);
 	    IF (p_timecard_attributes(l_attribute_index).ATTRIBUTE_CATEGORY = 'APPROVAL') THEN
	      p_timecard_attributes.delete(l_attribute_index);
              EXIT;
	    END IF;
   	    l_attribute_index := p_timecard_attributes.next(l_attribute_index);
      END LOOP;
END remove_override_approver;


--Removing the redudant attribute set from the last timecard when it is applied over a timecard, with zero
--Hrs Tempalte preference set.

PROCEDURE remove_redundant_attributesets(
	  p_timecard_blocks          IN     HXC_BLOCK_TABLE_TYPE
	 ,p_timecard_attributes      IN     HXC_ATTRIBUTE_TABLE_TYPE
	 ,p_zero_template_blocks     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
	 ,p_zero_template_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
)
IS

-- Type to contain the detail building blocks id which needs to be removed as index.
-- This would be indexed by timebuilding block id and a dummy value is stored.
-- Thus we dont need to loop thru this table and we can use the exists operator to
-- check while deletion.

TYPE v_bb_ids IS RECORD (
      DUMMY VARCHAR2(1) );

TYPE r_bb_ids IS TABLE OF v_bb_ids
      INDEX BY BINARY_INTEGER;


l_del_bb_ids  r_bb_ids;


l_timecard_detail_attributes     HXC_ATTRIBUTE_TABLE_TYPE;
l_zero_hrs_temp_dtl_attr     HXC_ATTRIBUTE_TABLE_TYPE;

l_index          	      BINARY_INTEGER;
l_index_day        	BINARY_INTEGER;
l_index_detail   		BINARY_INTEGER;
l_zero_hrs_index_detail BINARY_INTEGER;

l_tc_det_att_index   	BINARY_INTEGER;
l_zero_temp_det_att_index    BINARY_INTEGER;
l_sub_index_detail      BINARY_INTEGER;

l_det_row_found    BOOLEAN;

l_attributes_table r_att_ids;

l_layout_id HXC_TIME_ATTRIBUTES.ATTRIBUTE1%TYPE;
l_attributes_table_index number;
l_building_block_id hxc_time_building_blocks.TIME_BUILDING_BLOCK_ID%TYPE;

BEGIN

--This procedure would simply build two temporary detail attributes
--array for the newly entered/existing timecard details and the
--zero_hrs_template details. Then it will compare only the display
--attributes in them based on the layout.

--If any attribute sets is matched, then the corresponding building
--block id would be stored in a temp.table and later the corresponding
--block and the attribute would be cleared from the zero_hrs_template
--details.


-- Initialize the Temp Attribute Table
	l_zero_hrs_temp_dtl_attr    :=  HXC_ATTRIBUTE_TABLE_TYPE ();
	l_timecard_detail_attributes     :=  HXC_ATTRIBUTE_TABLE_TYPE ();



	 	     -- Fetch all the detail attributes of the Zero Hrs Template records.
	l_zero_hrs_index_detail  := NULL;
	l_zero_hrs_index_detail  := p_zero_template_blocks.FIRST;

	--First Capturing all the Zero Hrs template details attributes sets. Later we will
	--loop through the each timecard detail attribute sets and compare for redundancy.

	--Capturing the Timecard Detail Attribute Sets.

	-- Initialize the indices.
	--l_del_index := 1;
	l_tc_det_att_index := 1;

	--First Fetching the Layout Details.
	l_layout_id := get_timecard_layout_id(p_timecard_attributes);
	get_layout_display_attributes(l_layout_id,l_attributes_table);



	-- Fetch all the detail attributes of the new/existing Timecard details.
	l_index_detail  := NULL;
	l_index_detail  := p_timecard_blocks.FIRST;

	WHILE l_index_detail IS NOT NULL -- (While Loop)
	  LOOP
		 IF (p_timecard_blocks (l_index_detail).SCOPE = 'DETAIL'
		     AND p_timecard_blocks (l_index_detail).date_to =
		     fnd_date.date_to_canonical (hr_general.end_of_time)
		    )
		 THEN

		  -- Get all the ATTRIBUTES for this DETAIL Building Block into a Temp Table
		  -- Loop thru the attributes
		    l_index  :=NULL;
		    l_index  := p_timecard_attributes.FIRST;
		    if(l_timecard_detail_attributes.count>0) then
			  l_timecard_detail_attributes.delete;
		    end if;
		        l_tc_det_att_index := 1;
			WHILE l_index IS NOT NULL
			LOOP
			   IF (p_timecard_attributes (l_index).BUILDING_BLOCK_ID =
			       p_timecard_blocks(l_index_detail).time_building_block_id
			      )
			   THEN
				  --Get all the ATTRIBUTES for this DETAIL Building Block
				  --into a Temp Table
				  l_timecard_detail_attributes.EXTEND;
				  l_timecard_detail_attributes(l_tc_det_att_index) := p_timecard_attributes(l_index);
				  l_tc_det_att_index := l_timecard_detail_attributes.LAST +1;
			   END IF; -- attribute BB_ID = Time BB_ID
			   l_index := p_timecard_attributes.NEXT (l_index);
			END LOOP; -- l_index IS NOT NULL

		l_zero_hrs_index_detail  := NULL;
		l_zero_hrs_index_detail  := p_zero_template_blocks.FIRST;

		WHILE l_zero_hrs_index_detail IS NOT NULL -- (While Loop)
		LOOP
		IF (p_zero_template_blocks (l_zero_hrs_index_detail).SCOPE = 'DETAIL'
		    AND p_zero_template_blocks (l_zero_hrs_index_detail).date_to =
				 fnd_date.date_to_canonical (hr_general.end_of_time)
		) AND (NOT l_del_bb_ids.EXISTS(p_zero_template_blocks (l_zero_hrs_index_detail).TIME_BUILDING_BLOCK_ID))
		THEN
			-- Initialize the Temp Attribute Table
			if(l_zero_hrs_temp_dtl_attr.count>0) then
				l_zero_hrs_temp_dtl_attr.delete;
			end if;

			l_zero_temp_det_att_index := 1;
			-- Get all the ATTRIBUTES for this DETAIL Building Block
			-- into a Temp Table
			l_index  :=NULL;
			l_index  := p_zero_template_attributes.FIRST;

			WHILE l_index IS NOT NULL
			LOOP
				IF (p_zero_template_attributes(l_index).BUILDING_BLOCK_ID = p_zero_template_blocks(l_zero_hrs_index_detail).time_building_block_id)
				THEN

					-- Get all the ATTRIBUTES for this DETAIL Building Block into a Temp Table
					l_zero_hrs_temp_dtl_attr.EXTEND;
					l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index) := p_zero_template_attributes(l_index);
					l_zero_temp_det_att_index := l_zero_hrs_temp_dtl_attr.LAST +1;

				  END IF;
					   l_index := p_zero_template_attributes.NEXT (l_index);
			   END LOOP; -- l_index IS NOT NULL

		    l_det_row_found     := false;
		    l_tc_det_att_index     := null;
		    l_tc_det_att_index     := l_timecard_detail_attributes.FIRST;

		    WHILE l_tc_det_att_index IS NOT NULL
			LOOP

			-- Start the inner Detail loop
			-- Open up the Zero Hrs template attribute sets.

			l_zero_temp_det_att_index     := null;
			l_zero_temp_det_att_index     := l_zero_hrs_temp_dtl_attr.FIRST;

			WHILE l_zero_temp_det_att_index IS NOT NULL
			  LOOP
			--Only if the attribute category matches we loop thru... otherwise we will look for the next record.
			-- Also, the ELEMENT% attribute category are not considered and only 'OTL_ALIAS%' is considered.
			IF (l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE_CATEGORY =l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE_CATEGORY)
			AND ((l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE_CATEGORY NOT LIKE ('ELEMENT%')) OR (l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE_CATEGORY NOT LIKE ('ELEMENT%') )) THEN
				l_attributes_table_index := l_attributes_table.first;

				while l_attributes_table_index IS NOT NULL
				 LOOP
				   --Check the condition only if the attribute category matches.
				      if(l_attributes_table(l_attributes_table_index).ATTRIBUTE_CATEGORY = l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE_CATEGORY) THEN --Just to make sure only needed attributes are compared.
					IF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE1') THEN
						IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE1,-9999) =
					           nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE1,-9999)) THEN
						      l_det_row_found :=TRUE;

						  ELSE
						     l_det_row_found :=FALSE;
						  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE2') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE2,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE2,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE3') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE3,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE3,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE4') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE4,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE4,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE5') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE5,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE5,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE6') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE6,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE6,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE7') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE7,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE7,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE8') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE8,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE8,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'Attribute9') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE9,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE9,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE10') THEN

							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE10,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE10,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE11') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE11,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE11,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE12') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE12,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE12,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE13') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE13,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE13,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE14') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE14,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE14,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE15') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE15,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE15,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE16') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE16,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE16,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE17') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE17,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE17,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE18') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE18,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE18,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE19') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE19,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE19,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE20') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE20,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE20,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE21') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE21,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE21,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE22') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE22,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE22,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE23') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE23,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE23,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE24') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE24,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE24,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE25') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE25,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE25,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE26') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE26,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE26,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE27') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE27,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE27,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE28') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE28,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE28,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE29') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE29,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE29,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					ELSIF(l_attributes_table(l_attributes_table_index).ATTRIBUTE_COLUMN_NAME = 'ATTRIBUTE30') THEN
							  IF(nvl(l_zero_hrs_temp_dtl_attr(l_zero_temp_det_att_index).ATTRIBUTE30,-9999) =
							     nvl(l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE30,-9999)) THEN
							      l_det_row_found :=TRUE;
							   ELSE
							     l_det_row_found :=FALSE;
							  END IF;
					END IF;
					IF l_det_row_found = FALSE THEN
						l_attributes_table_index := NULL;
						l_zero_temp_det_att_index     := null;
					else
						l_attributes_table_index := l_attributes_table.NEXT(l_attributes_table_index);
					end if;
					else
						l_attributes_table_index := l_attributes_table.NEXT(l_attributes_table_index);
					END IF;

				 END LOOP;

		       END IF;

			if(l_zero_temp_det_att_index is not null) then
				l_zero_temp_det_att_index := l_zero_hrs_temp_dtl_attr.NEXT(l_zero_temp_det_att_index);
			END IF;
		  END LOOP;
		   --We dont consider the ELEMENT% Attribute category.
		    if (l_timecard_detail_attributes(l_tc_det_att_index).ATTRIBUTE_CATEGORY NOT LIKE 'ELEMENT%') then
			IF l_det_row_found = FALSE THEN
				l_tc_det_att_index :=NULL;
			else
				l_tc_det_att_index := l_timecard_detail_attributes.NEXT(l_tc_det_att_index);

			end if;
		   else
				l_tc_det_att_index := l_timecard_detail_attributes.NEXT(l_tc_det_att_index);
		   end if;
	  END LOOP;
       END IF;

		IF l_det_row_found -- Got a match
		THEN
		 -- Adding the Time Building Block id in the temp. table
		 -- Index it by Timebuilding block id.
		if(NOT l_del_bb_ids.EXISTS(p_zero_template_blocks(l_zero_hrs_index_detail).time_building_block_id)) then
			l_del_bb_ids(p_zero_template_blocks(l_zero_hrs_index_detail).time_building_block_id).DUMMY :=NULL;
		END IF;
	 	END IF;
		l_det_row_found :=FALSE;
		l_zero_hrs_index_detail := p_zero_template_blocks.NEXT (l_zero_hrs_index_detail);
	  END LOOP;
    END IF;
	  l_index_detail := p_timecard_blocks.NEXT (l_index_detail);
  END LOOP; -- (While Loop)

l_index  :=NULL;
l_index  := p_zero_template_blocks.FIRST;

WHILE l_index IS NOT NULL
LOOP
   IF ( l_del_bb_ids.EXISTS(p_zero_template_blocks (l_index).TIME_BUILDING_BLOCK_ID)
	 )
   THEN
 -- Delete Block Row
	p_zero_template_blocks.DELETE(l_index);
   END IF; -- attribute BB_ID = Deleted Time BB_ID
  l_index := p_zero_template_blocks.NEXT (l_index);
END LOOP; -- l_index IS NOT NULL

l_index  :=NULL;
l_index  := p_zero_template_attributes.FIRST;

WHILE l_index IS NOT NULL
LOOP
	IF ( l_del_bb_ids.EXISTS(p_zero_template_attributes (l_index).BUILDING_BLOCK_ID)
	 )
   THEN

    -- Delete Attribute Row

	p_zero_template_attributes.DELETE(l_index);
   END IF; -- attribute BB_ID = Deleted Time BB_ID
  l_index := p_zero_template_attributes.NEXT (l_index);
END LOOP; -- l_index IS NOT NULL

END remove_redundant_attributesets;

-- v115.64 ksethi ksethi adding new procedure
-- This will convert a Template to a Zero hours template

PROCEDURE modify_to_zero_hrs_template (
   p_start_time      IN              VARCHAR2,
   p_stop_time       IN              VARCHAR2,
   p_block_array     IN OUT NOCOPY   HXC_BLOCK_TABLE_TYPE,
   p_attribute_array IN OUT NOCOPY   HXC_ATTRIBUTE_TABLE_TYPE,
   p_clear_comment   IN 	     VARCHAR2
)
IS

   -- Local variables
   l_day_one_time_bb_id  NUMBER;
   l_day_one_ovn         NUMBER;
   l_first_day           DATE;

   -- Index variables
   l_index          	        BINARY_INTEGER;
   l_index_day        	        BINARY_INTEGER;
   l_index_detail   		BINARY_INTEGER;
   l_det_att_index   		BINARY_INTEGER;
   l_det_sub_att_index          BINARY_INTEGER;
   l_sub_index_detail           BINARY_INTEGER;
   l_del_index  		BINARY_INTEGER;


   -- Local Flags
   l_day_found        BOOLEAN;
   l_det_row_found    BOOLEAN;

   -- Local Types used
   l_detail_attributes     HXC_ATTRIBUTE_TABLE_TYPE;
   l_detail_sub_attributes HXC_ATTRIBUTE_TABLE_TYPE;


   l_del_bb_ids  r_del_bb_ids;

   --

   l_proc             VARCHAR2 (70);
BEGIN


-- DBMS_PROFILER.START_PROFILER('Kunal');
   IF g_debug THEN
   	l_proc        := 'modify_to_zero_hrs_template';
   	hr_utility.set_location (g_package || l_proc, 120);
   END IF;
-- Get the range calculated
   l_first_day      := fnd_date.canonical_to_date (p_start_time);
--
-- Get the Time Building Block ID and OVN for the first day
--
      l_index_day  := NULL;
      l_index_day  := p_block_array.FIRST;
      l_day_found := FALSE ;

      WHILE l_index_day IS NOT NULL
      LOOP
         IF (    p_block_array (l_index_day).SCOPE = 'DAY'
             AND p_block_array (l_index_day).start_time =
                                fnd_date.date_to_canonical (l_first_day)
             AND p_block_array (l_index_day).date_to =
                          fnd_date.date_to_canonical (hr_general.end_of_time)
            )
         THEN
         -- Store the info in local variables
            l_day_one_time_bb_id :=p_block_array (l_index_day).TIME_BUILDING_BLOCK_ID;
	    l_day_one_ovn        :=p_block_array (l_index_day).OBJECT_VERSION_NUMBER;
	    l_day_found := TRUE ;
         END IF; -- Scope = DAY
         IF l_day_found
	       THEN
	        l_index_day := NULL;
               ELSE
                l_index_day := p_block_array.NEXT (l_index_day);
         END IF; -- l_day_found
      END LOOP; -- l_index_day is not null

-- Update all DETAILS to be children of DAY ONE
      l_index_detail  := NULL;
      l_index_detail  := p_block_array.FIRST;

      WHILE l_index_detail IS NOT NULL
      LOOP
         IF (    p_block_array (l_index_detail).SCOPE = 'DETAIL'
             AND p_block_array (l_index_detail).date_to =
	                           fnd_date.date_to_canonical (hr_general.end_of_time)
             AND p_block_array (l_index_detail).PARENT_BUILDING_BLOCK_ID <>
                                l_day_one_time_bb_id
--	     AND p_block_array (l_index_detail).PARENT_BUILDING_BLOCK_OVN <>
--		                l_day_one_ovn
            )
         THEN
           -- Update the DETAIL to have the DAY one as its parent
           p_block_array (l_index_detail).PARENT_BUILDING_BLOCK_OVN := l_day_one_ovn;
           p_block_array (l_index_detail).PARENT_BUILDING_BLOCK_ID  := l_day_one_time_bb_id;
         END IF; -- Scope = DETAIL
         l_index_detail := p_block_array.NEXT (l_index_detail);
      END LOOP; -- l_index_detail is not null


-- Now that all DETAILS are children of DAY ONE,
-- Wipe out, such that only one DETAIL stays with one unique ATTRIBUTE SET

-- Since zero hours template is being used,
-- here we remove any DETAIL DDF attributes from the attribute list.

	l_index  :=NULL;
	l_index  := p_attribute_array.FIRST;

	WHILE l_index IS NOT NULL
	LOOP
	   IF (    p_attribute_array (l_index).ATTRIBUTE_CATEGORY  like
	  	                               'PAEXPITDFF%'
	      )
	   THEN
	    -- Delete Attribute Row
				p_attribute_array.DELETE(l_index);
	    END IF; -- ATTRIBUTE_CATEGORY  like 'PAEXPITDFF%'
	   l_index := p_attribute_array.NEXT (l_index);
	END LOOP; -- l_index IS NOT NULL

-- Initialize the Local Attribute Types
l_detail_attributes     :=  HXC_ATTRIBUTE_TABLE_TYPE ();
l_detail_sub_attributes :=  HXC_ATTRIBUTE_TABLE_TYPE();


-- Initialize the TBB ID delete table
	      IF (l_del_bb_ids.COUNT > 0)
	       THEN
	        l_del_bb_ids.DELETE;
	      END IF;
		l_del_index := 1;



-- Start with looping thru all the DEATILS
      l_index_detail  := NULL;
      l_index_detail  := p_block_array.FIRST;

      WHILE l_index_detail IS NOT NULL -- (Main Processing)
      LOOP
         IF (    p_block_array (l_index_detail).SCOPE = 'DETAIL'
             AND p_block_array (l_index_detail).date_to =
	                           fnd_date.date_to_canonical (hr_general.end_of_time)
            )
         THEN

          -- Get all the ATTRIBUTES for this DETAIL Building Block into a Temp Table




	  -- Initialize the Temp Attribute Table

	  	      IF (l_detail_attributes.COUNT > 0)
	  	       THEN
	  	        l_detail_attributes.DELETE;
	  	      END IF;
	  	       l_det_att_index := 1;

	  -- Loop thru the attributes
	            l_index  :=NULL;
	            l_index  := p_attribute_array.FIRST;

	  	        WHILE l_index IS NOT NULL
	  	        LOOP
	  	           IF (    p_attribute_array (l_index).BUILDING_BLOCK_ID =
	  	                              p_block_array(l_index_detail).time_building_block_id
	  	              )
	  	           THEN

	  	            -- Get all the ATTRIBUTES for this DETAIL Building Block into a Temp Table
	  	            l_detail_attributes.EXTEND;
	  	            l_detail_attributes(l_det_att_index) := p_attribute_array(l_index);
	  	            l_det_att_index := l_detail_attributes.LAST +1;


	  	  /*  IF g_debug THEN
	  	  	hr_utility.trace('|  '||p_attribute_array (l_index).BUILDING_BLOCK_ID||'   |    '||p_attribute_array (l_index).TIME_ATTRIBUTE_ID||'   |    '||p_attribute_array (l_index).ATTRIBUTE_CATEGORY);
	  	      END IF;
	  	  */
	  	           END IF; -- attribute BB_ID = Time BB_ID
	  	           l_index := p_attribute_array.NEXT (l_index);
	  	        END LOOP; -- l_index IS NOT NULL

	  /*	IF g_debug THEN
	  		hr_utility.trace(p_block_array(l_index_detail).time_building_block_id||'      |    '||l_detail_attributes.COUNT);
	  	END IF;
	  */
	  	-- Here we have a list of all attributes for the main DETAIL id.
	  	-- Now loop thru the rest of the DETAILS to find other DETAILS
	  	-- that have the same set of Attributes as in 'l_detail_attributes'
	  	--

	  	-- Start with looping thru to get all the SUB - DEATILS
	  	      l_sub_index_detail  := NULL;
	  	      l_sub_index_detail  := p_block_array.FIRST;

	  	      WHILE l_sub_index_detail IS NOT NULL -- (Sub Processing)
	  	      LOOP
	  		 IF (    p_block_array (l_sub_index_detail).SCOPE = 'DETAIL'
	  	             AND p_block_array (l_sub_index_detail).date_to =
	  		                           fnd_date.date_to_canonical (hr_general.end_of_time)
	  	             AND p_block_array(l_sub_index_detail).time_building_block_id <>
	  	                                   p_block_array(l_index_detail).time_building_block_id

	  		    )
	  		 THEN
	  		 --
	  			-- Get all the ATTRIBUTES for this Sub - DETAIL Building Block
	  			-- into a Temp Table
	  		          l_index  :=NULL;
	  		          l_index  := p_attribute_array.FIRST;

	   		 -- Initialize the Temp Attribute Table

	  			      IF (l_detail_sub_attributes.COUNT > 0)
	  			       THEN
	  			        l_detail_sub_attributes.DELETE;
	  			      END IF;
	  			        l_det_sub_att_index := 1;

	  			       WHILE l_index IS NOT NULL
	  			        LOOP
	  			           IF (    p_attribute_array (l_index).BUILDING_BLOCK_ID =
	  			                   p_block_array(l_sub_index_detail).time_building_block_id
	  			              )
	  			           THEN

	  			            -- Get all the ATTRIBUTES for this DETAIL Building Block into a Temp Table
	  			            l_detail_sub_attributes.EXTEND;
	  			            l_detail_sub_attributes(l_det_sub_att_index) := p_attribute_array(l_index);
	  			            l_det_sub_att_index := l_detail_sub_attributes.LAST +1;


	  			            END IF; -- attribute BB_ID = Time BB_ID and
	  			                    -- Sub Detail BB ID <> Detail BB ID
	  			           l_index := p_attribute_array.NEXT (l_index);
	  			        END LOOP; -- l_index IS NOT NULL

	  		  -- Just a check to see all is well
	  		  /*      IF g_debug THEN
	  		  		hr_utility.trace(p_block_array(l_index_detail).time_building_block_id||'      |    '||l_detail_attributes.COUNT||'        |    '||p_block_array(l_sub_index_detail).time_building_block_id||'      |    '||l_detail_sub_attributes.COUNT);
	  		  	  END IF;
	  		  */


	  		 -- Now compare l_detail_sub_attributes and l_detail_attributes
	  		 -- If same, then remove the p_block_array(l_sub_index_detail)
	  		 -- and also add to a removed TBB table so to flush the
	  		 -- attributes at a later stage.

	  		  -- First check if the size is same
	  		  -- If yes then enter
	  		   IF ( l_detail_sub_attributes.COUNT = l_detail_attributes.COUNT )
	  		    THEN
	  		  --
	  		  --  Just a check to see all is well
	  		/*	IF g_debug THEN
	  				hr_utility.trace(p_block_array(l_index_detail).time_building_block_id||'      |    '||l_detail_attributes.COUNT||'        |    '||p_block_array(l_sub_index_detail).time_building_block_id||'      |    '||l_detail_sub_attributes.COUNT);
	  			END IF;
	  		*/
	                     -- OK, here we go, Start the Comparison here
	  			 l_det_sub_att_index := null;
	  			 l_det_sub_att_index := l_detail_sub_attributes.FIRST;
	  		-- Start the Loop
	   			 WHILE l_det_sub_att_index IS NOT NULL
	                            LOOP
	  			    l_det_row_found     := false;
	  			    l_det_att_index     := null;
	  			    l_det_att_index     := l_detail_attributes.FIRST;
	                     -- Start the inner Detail loop
	             		     WHILE l_det_att_index IS NOT NULL
	  	                      LOOP

	  	                      -- Make the comparison
	  	                      IF (
	  	                           l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE_CATEGORY =
	  	                               l_detail_attributes(l_det_att_index).ATTRIBUTE_CATEGORY
	  	                        AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE1,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE1,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE2,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE2,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE3,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE3,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE4,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE4,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE5,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE5,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE6,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE6,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE7,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE7,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE8,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE8,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE9,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE9,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE10,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE10,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE11,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE11,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE12,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE12,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE13,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE13,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE14,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE14,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE15,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE15,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE16,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE16,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE17,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE17,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE18,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE18,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE19,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE19,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE20,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE20,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE21,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE21,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE22,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE22,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE23,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE23,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE24,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE24,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE25,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE25,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE26,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE26,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE27,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE27,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE28,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE28,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE29,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE29,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE30,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).ATTRIBUTE30,-9999)
	  				AND nvl(l_detail_sub_attributes(l_det_sub_att_index).BLD_BLK_INFO_TYPE,-9999) =
	  				  nvl(l_detail_attributes(l_det_att_index).BLD_BLK_INFO_TYPE,-9999)
	  	                         )
	  	                       THEN
	  	                       -- Set the Same Attribute FOUND Flag
	  	                         l_det_row_found := TRUE;
					 -- Incase we need to ignore DETAIL attributes
					 /*
					  ELSE
	  	                          IF (l_detail_sub_attributes(l_det_sub_att_index).ATTRIBUTE_CATEGORY  like
	  	                               'PAEXPITDFF%'
	  	                             AND
	  	                           l_detail_attributes(l_det_att_index).ATTRIBUTE_CATEGORY like
	  	                               'PAEXPITDFF%'   )
	  	                          THEN
	  	                            -- Set the Same Attribute FOUND Flag
	  	                            l_det_row_found := TRUE;
	  	                          End if;
	  	                          */
	  	                      END IF; -- Comparison between the two rows

	  	                      IF l_det_row_found -- Got a match
	  	                       THEN
	                                  l_det_att_index := NULL;
	                                 ELSE
	                                  l_det_att_index := l_detail_attributes.NEXT (l_det_att_index);
	                                 END IF;
	  	                      END LOOP; -- l_det_att_index IS NOT NULL
	  	           -- Here we have the final result if the row exists or not
	  	           --
	  	                   IF NOT l_det_row_found
	  	                    THEN
	  	                     l_det_sub_att_index := NULL;
	  	                    ELSE -- Carry on to find if the next row exists or not
	  	                     l_det_sub_att_index := l_detail_sub_attributes.NEXT (l_det_sub_att_index);
	  	                   END IF; --l_det_row_found
	                            END LOOP; -- l_det_sub_att_index IS NOT NULL

	                            -- Here finally check the flag to determine if the complete
	                            -- Attribute set is same or not
	                            -- If yes, delete the SUB Detail Row
	  			   IF l_det_row_found
	  			    THEN

	  			  -- Check to see if the correct TBB is obtained
	  			  /* IF g_debug THEN
	  			  	hr_utility.trace(p_block_array(l_index_detail).time_building_block_id||'      |    '||p_block_array(l_sub_index_detail).time_building_block_id||'      |    ');
	  			     END IF;
	  			  */
	  			  -- First add the TBB ID to the temp table
	  			  -- that will be used later to clear the attributes
				  l_del_bb_ids(l_del_index).time_building_block_id := p_block_array(l_sub_index_detail).time_building_block_id;
				  l_del_index := l_del_index+1;
	  			  p_block_array.DELETE(l_sub_index_detail);

	  		     END IF; -- l_det_row_found
	  		   --
	  		   END IF; -- l_detail_sub_attributes.COUNT = l_detail_attributes.COUNT

	    	         END IF; -- Scope = DETAIL
	  			 -- And Sub Detail ID <> Main Detail ID
	  			 --
	  		  l_sub_index_detail := p_block_array.NEXT (l_sub_index_detail);
	  		END LOOP; -- l_sub_index_detail is not null -- (Sub Processing)
	          --
	  	--
		 -- Fix 115.65 moving before End if Scope = Detail
		 -- Here we are sure that this is the only Valid Detail ID and hence set
		 -- the measure to zero
		 -- Check if we need to null START / STOP TIME or Measure
		 if (p_block_array(l_index_detail).MEASURE is not null)
		  then
		   p_block_array(l_index_detail).MEASURE := 0;
                   p_block_array(l_index_detail).TRANSLATION_DISPLAY_KEY :=
                      hxc_trans_display_key_utils.reset_column_index_to_zero(p_block_array(l_index_detail).translation_display_key);

		   IF (p_clear_comment = 'Y') THEN
		     p_block_array(l_index_detail).COMMENT_TEXT := null;
		   END IF;


		 end if;
		 if ((p_block_array(l_index_detail).START_TIME is not null) OR
		     (p_block_array(l_index_detail).STOP_TIME is not null)
		     )
		  then
		   p_block_array(l_index_detail).START_TIME := fnd_date.date_to_canonical(l_first_day);
		   p_block_array(l_index_detail).STOP_TIME  := fnd_date.date_to_canonical(l_first_day);
                   p_block_array(l_index_detail).TRANSLATION_DISPLAY_KEY :=
                      hxc_trans_display_key_utils.reset_column_index_to_zero(p_block_array(l_index_detail).translation_display_key);

		   IF (p_clear_comment = 'Y') THEN
		     p_block_array(l_index_detail).COMMENT_TEXT := null;
		   END IF;

		 end if;
         ELSIF  (p_block_array (l_index_detail).SCOPE = 'TIMECARD' and (p_clear_comment = 'Y')) THEN
  	    p_block_array(l_index_detail).COMMENT_TEXT := null;

         END IF; -- Scope = DETAIL



         l_index_detail := p_block_array.NEXT (l_index_detail);
      END LOOP; -- l_index_detail is not null (Main Processing)

	-- Now, for all Building Blocks deleted, also delete the attributes
	--

	IF (l_del_bb_ids.COUNT > 0)
	  THEN
	   -- Loop thru the l_del_bb_ids table
	FOR x IN
	     l_del_bb_ids.FIRST .. l_del_bb_ids.LAST
	 LOOP
	  -- Now for every TBB ID in l_del_bb_ids loop thru the attributes
	  -- and delete if found
	   -- Find attributes of deleted l_del_bb_ids (x).time_building_block_id
		     l_index  :=NULL;
		     l_index  := p_attribute_array.FIRST;

			WHILE l_index IS NOT NULL
			LOOP
			   IF (  p_attribute_array (l_index).BUILDING_BLOCK_ID =
					      l_del_bb_ids (x).time_building_block_id
			      )
			   THEN

			    -- Delete Attribute Row

				p_attribute_array.DELETE(l_index);
			   END IF; -- attribute BB_ID = Deleted Time BB_ID
			  l_index := p_attribute_array.NEXT (l_index);
			END LOOP; -- l_index IS NOT NULL
	 END LOOP; -- x IN list_tim_rec_det

	END IF;   --  (l_del_bb_ids.COUNT > 0)
	--
-- DBMS_PROFILER.STOP_PROFILER;

--- Bug 8662179
--- Null out translation display key values for all detail blocks.

	l_index := p_block_array.first;
        LOOP
        EXIT WHEN NOT p_block_array.exists(l_index);

		  IF p_block_array(l_index).SCOPE = 'DETAIL' THEN
			p_block_array(l_index).TRANSLATION_DISPLAY_KEY := NULL;
		  END IF;

		  l_index := p_block_array.next(l_index);

        END LOOP;

END modify_to_zero_hrs_template;

-- ========================================================================
-- This function gets building block information type id from a field name
-- ========================================================================
FUNCTION get_info_type_id(
  p_field_name IN hxc_mapping_components.field_name%TYPE
 ,p_retrieval_process_id IN hxc_retrieval_processes.retrieval_process_id%TYPE
)
RETURN hxc_bld_blk_info_types.bld_blk_info_type%TYPE
IS
  l_info_type_id hxc_bld_blk_info_types.bld_blk_info_type%TYPE;

  CURSOR c_info_type_id(
    p_field_name IN hxc_mapping_components.field_name%TYPE
   ,p_retrieval_process_id IN hxc_retrieval_processes.retrieval_process_id%TYPE
  )
  IS
    SELECT mc.bld_blk_info_type_id
      FROM hxc_mapping_components mc
          ,hxc_mapping_comp_usages mcu
          ,hxc_mappings m
          ,hxc_retrieval_processes rp
     WHERE upper(mc.field_name) = upper(p_field_name)
       AND rp.mapping_id = m.mapping_id
       AND rp.retrieval_process_id = p_retrieval_process_id
       AND m.mapping_id = mcu.mapping_id
       AND mcu.mapping_component_id = mc.mapping_component_id;

BEGIN
  OPEN c_info_type_id(p_field_name, p_retrieval_process_id);
  FETCH c_info_type_id INTO l_info_type_id;

  IF c_info_type_id%NOTFOUND
  THEN
    CLOSE c_info_type_id;
    FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');
    FND_MESSAGE.RAISE_ERROR;
  ELSE
    CLOSE c_info_type_id;
  END IF;

  RETURN l_info_type_id;
END get_info_type_id;


---------------------------------------------------------------------
-- get building block information type id from a building block
-- information type
---------------------------------------------------------------------
FUNCTION get_info_type_id_from_type(
  p_bld_blk_info_type IN hxc_bld_blk_info_types.bld_blk_info_type%TYPE
)
RETURN hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
IS
  l_bld_blk_info_type_id hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;

  CURSOR c_info_type_id(
    p_bld_blk_info_type IN hxc_bld_blk_info_types.bld_blk_info_type%TYPE
  )
  IS
    SELECT bld_blk_info_type_id
      FROM hxc_bld_blk_info_types
     WHERE bld_blk_info_type = p_bld_blk_info_type;

BEGIN

  l_bld_blk_info_type_id := NULL;

  OPEN c_info_type_id(
    p_bld_blk_info_type => p_bld_blk_info_type
  );

  FETCH c_info_type_id INTO l_bld_blk_info_type_id;

  IF c_info_type_id%notfound
  THEN
    --
    -- There isn't a corresponding info type id
    -- Show an error!
    --
    CLOSE c_info_type_id;
    FND_MESSAGE.SET_NAME('HXC','HXC_NO_BLD_BLK_INFO_TYPE');
    FND_MESSAGE.RAISE_ERROR;

  ELSE

    CLOSE c_info_type_id;

  END IF;

  RETURN l_bld_blk_info_type_id;
END;

-- -----------------------------------------------------------------
-- get building block information type  from a building block
-- information type id
-- -----------------------------------------------------------------
FUNCTION get_info_type(
  p_bld_blk_info_type_id IN hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
)
RETURN hxc_bld_blk_info_types.bld_blk_info_type%TYPE
IS
  l_bld_blk_info_type hxc_bld_blk_info_types.bld_blk_info_type%TYPE;

  CURSOR c_info_type(
    p_bld_blk_info_type_id IN hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
  )
  IS
    SELECT bld_blk_info_type
      FROM hxc_bld_blk_info_types
     WHERE bld_blk_info_type_id = p_bld_blk_info_type_id;

BEGIN

  l_bld_blk_info_type:= NULL;

  OPEN c_info_type(
    p_bld_blk_info_type_id => p_bld_blk_info_type_id
  );

  FETCH c_info_type INTO l_bld_blk_info_type;

  IF c_info_type%NOTFOUND
  THEN
    --
    -- There isn't a corresponding info type id
    -- Show an error!
    --
    CLOSE c_info_type;
    FND_MESSAGE.SET_NAME('HXC','HXC_NO_BLD_BLK_INFO_TYPE');
    FND_MESSAGE.RAISE_ERROR;

  ELSE

    CLOSE c_info_type;

  END IF;

  RETURN l_bld_blk_info_type;
END;


PROCEDURE build_attribute_detail(
  p_process_id        IN     hxc_retrieval_processes.retrieval_process_id%TYPE
 ,p_block_attribute   IN OUT NOCOPY HXC_ATTRIBUTE_TYPE
 ,p_app_attributes    IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
 ,p_template_type     IN     VARCHAR2
)
IS
  l_att_count         NUMBER;
  l_bld_blk_info_type hxc_bld_blk_info_types.bld_blk_info_type%TYPE;
  l_info_type_id      hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
  l_segment           hxc_mapping_components.segment%TYPE;

  CURSOR csr_segment(
    p_retrieval_process_id NUMBER
   ,p_attribute_category VARCHAR2
   ,p_field_name VARCHAR2
  )
  IS
    select mc.segment
    from hxc_mapping_components mc
     ,hxc_mapping_comp_usages mcu
     ,hxc_mappings m
     ,hxc_retrieval_processes rp
     ,hxc_bld_blk_info_types bbit
     ,hxc_bld_blk_info_type_usages bbui
    where rp.mapping_id = m.mapping_id
      AND mc.field_name = p_field_name
      and rp.retrieval_process_id = p_retrieval_process_id
      and m.mapping_id = mcu.mapping_id
      and mcu.mapping_component_id = mc.mapping_component_id
      and mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
      AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
      AND bbit.bld_blk_info_type = p_attribute_category;

BEGIN
  l_att_count := p_app_attributes.first;

  LOOP
    EXIT WHEN NOT p_app_attributes.exists(l_att_count);

    IF NVL(p_app_attributes(l_att_count).UPDATED, 'N') <> 'Y'
      AND p_app_attributes(l_att_count).time_attribute_id = p_block_attribute.TIME_ATTRIBUTE_ID
    THEN
        l_info_type_id :=
          get_info_type_id(
            p_field_name => p_app_attributes(l_att_count).ATTRIBUTE_NAME
           ,p_retrieval_process_id => p_process_id
          );

        l_bld_blk_info_type := get_info_type(l_info_type_id);

      --
      -- Because 'ELEMENT - XXXXX' typse share the same context definition,
      -- we need to use the 'Dummy Element Context' to find the mapping
      --
      IF SUBSTR(l_bld_blk_info_type, 1, 7) = 'ELEMENT'
      THEN
        l_bld_blk_info_type := 'Dummy Element Context';
      END IF;

      --
      -- This name value pair belongs to the current attribute record
      -- and therefore we should update the record.
      -- Fetch the segment associated with this field name, so that we
      -- know where to store the modified value.
      --
      OPEN csr_segment(
        p_retrieval_process_id => p_process_id
       ,p_attribute_category   => l_bld_blk_info_type
       ,p_field_name           => p_app_attributes(l_att_count).attribute_name
      );

      FETCH csr_segment INTO l_segment;

      IF csr_segment%notfound THEN
        --
        -- The field specified is not found.
        -- We don't know where to put the data
        -- Show an error
        --
        CLOSE csr_segment;
        FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');
        FND_MESSAGE.RAISE_ERROR;
      ELSE
        --
        -- We need to update the appropriate segment in the correct time
        -- attribute record.
        --
        CLOSE csr_segment;

        IF l_segment = 'ATTRIBUTE1'
        THEN
          p_block_attribute.attribute1 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE2' THEN
          p_block_attribute.attribute2 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE3' THEN
          p_block_attribute.attribute3 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE4' THEN
          p_block_attribute.attribute4 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE5' THEN
          p_block_attribute.attribute5 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE6' THEN
          p_block_attribute.attribute6 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE7' THEN
          p_block_attribute.attribute7 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE8' THEN
          p_block_attribute.attribute8 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE9' THEN
          p_block_attribute.attribute9 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE10' THEN
          p_block_attribute.attribute10 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE11' THEN
          p_block_attribute.attribute11 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE12' THEN
          p_block_attribute.attribute12 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE13' THEN
          p_block_attribute.attribute13 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE14' THEN
          p_block_attribute.attribute14 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE15' THEN
          p_block_attribute.attribute15 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE16' THEN
          p_block_attribute.attribute16 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE17' THEN
          p_block_attribute.attribute17 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE18' THEN
          p_block_attribute.attribute18 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE19' THEN
          p_block_attribute.attribute19 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE20' THEN
          p_block_attribute.attribute20 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE21' THEN
          p_block_attribute.attribute21 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE22' THEN
          p_block_attribute.attribute22 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE23' THEN
          p_block_attribute.attribute23 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE24' THEN
          p_block_attribute.attribute24 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE25' THEN
          p_block_attribute.attribute25 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE26' THEN
          p_block_attribute.attribute26 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE27' THEN
          p_block_attribute.attribute27 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE28' THEN
          p_block_attribute.attribute28 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE29' THEN
          p_block_attribute.attribute29 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE30' THEN
          p_block_attribute.attribute30 := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        ELSIF l_segment = 'ATTRIBUTE_CATEGORY' THEN
          p_block_attribute.attribute_category := p_app_attributes(l_att_count).attribute_value;
          p_app_attributes(l_att_count).updated := 'Y';
        END IF;
      END IF;

    END IF;

    l_att_count := p_app_attributes.next(l_att_count);

  END LOOP;
END build_attribute_detail;



FUNCTION app_to_block_attributes(
  p_app_attributes IN hxc_self_service_time_deposit.app_attributes_info
 ,p_process_id     IN hxc_retrieval_processes.retrieval_process_id%TYPE
 ,p_resource_id    IN hxc_time_building_blocks.resource_id%TYPE
 ,p_timecard_id    IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_template_type  IN VARCHAR2
)
RETURN HXC_ATTRIBUTE_TABLE_TYPE
IS
  l_block_attributes      HXC_ATTRIBUTE_TABLE_TYPE;
  l_app_attributes        hxc_self_service_time_deposit.app_attributes_info;
  l_info_type_id          hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
  l_app_attribute_index   NUMBER;
  l_block_attribute_index NUMBER := 0;

BEGIN
  l_block_attributes := HXC_ATTRIBUTE_TABLE_TYPE();

  l_app_attributes := p_app_attributes;
  l_app_attribute_index := l_app_attributes.first;

  LOOP
    EXIT WHEN NOT l_app_attributes.exists(l_app_attribute_index);

    IF NVL(l_app_attributes(l_app_attribute_index).UPDATED, 'N') <> 'Y'
    THEN
      -- build a new time attribute record
      l_block_attributes.extend;
      l_block_attribute_index := l_block_attribute_index + 1;

      l_block_attributes(l_block_attribute_index) :=
         HXC_ATTRIBUTE_TYPE(
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

      l_block_attributes(l_block_attribute_index).TIME_ATTRIBUTE_ID
        := l_app_attributes(l_app_attribute_index).TIME_ATTRIBUTE_ID;

      l_block_attributes(l_block_attribute_index).BUILDING_BLOCK_ID
        := l_app_attributes(l_app_attribute_index).BUILDING_BLOCK_ID;

      l_block_attributes(l_block_attribute_index).BLD_BLK_INFO_TYPE
        := l_app_attributes(l_app_attribute_index).BLD_BLK_INFO_TYPE;

      l_block_attributes(l_block_attribute_index).ATTRIBUTE_CATEGORY
        := l_app_attributes(l_app_attribute_index).BLD_BLK_INFO_TYPE;

      l_info_type_id
        := get_info_type_id(
             p_field_name => l_app_attributes(l_app_attribute_index).ATTRIBUTE_NAME
            ,p_retrieval_process_id => p_process_id
           );

      l_block_attributes(l_block_attribute_index).BLD_BLK_INFO_TYPE_ID
        := l_info_type_id;

      l_block_attributes(l_block_attribute_index).OBJECT_VERSION_NUMBER
        := 1;

      l_block_attributes(l_block_attribute_index).NEW
        := 'Y';

      --set changed flag to indicate this is generated by applying a template
      l_block_attributes(l_block_attribute_index).CHANGED := 'TEMPLATE';

      -- go through all the app attributes to fill in attribute1..30.
      build_attribute_detail(
        p_process_id      => p_process_id
       ,p_block_attribute => l_block_attributes(l_block_attribute_index)
       ,p_app_attributes  => l_app_attributes
       ,p_template_type   => p_template_type
      );

    END IF;

    l_app_attribute_index := l_app_attributes.next(l_app_attribute_index);
  END LOOP;

  -- create an attribute for LAYOUT
  l_block_attributes.extend;
  l_block_attribute_index := l_block_attribute_index + 1;

  l_block_attributes(l_block_attribute_index) :=
     HXC_ATTRIBUTE_TYPE(
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


  l_block_attributes(l_block_attribute_index).TIME_ATTRIBUTE_ID := 0;
  l_block_attributes(l_block_attribute_index).BUILDING_BLOCK_ID := p_timecard_id;
  l_block_attributes(l_block_attribute_index).BLD_BLK_INFO_TYPE := 'LAYOUT';
  l_block_attributes(l_block_attribute_index).ATTRIBUTE_CATEGORY := 'LAYOUT';
  l_block_attributes(l_block_attribute_index).ATTRIBUTE1
    := hxc_preference_evaluation.resource_preferences(
         p_resource_id,
         'TC_W_TCRD_LAYOUT',
         1);
  l_block_attributes(l_block_attribute_index).ATTRIBUTE2
    := hxc_preference_evaluation.resource_preferences(
         p_resource_id,
         'TC_W_TCRD_LAYOUT',
         2);
  l_block_attributes(l_block_attribute_index).ATTRIBUTE3
    := hxc_preference_evaluation.resource_preferences(
         p_resource_id,
         'TC_W_TCRD_LAYOUT',
         3);

  l_block_attributes(l_block_attribute_index).BLD_BLK_INFO_TYPE_ID
    := get_info_type_id_from_type('LAYOUT');
  l_block_attributes(l_block_attribute_index).OBJECT_VERSION_NUMBER := 1;
  l_block_attributes(l_block_attribute_index).NEW := 'Y';
  l_block_attributes(l_block_attribute_index).CHANGED := 'N';


  RETURN l_block_attributes;

END app_to_block_attributes;



-----------------------------------------------------------------------------
-- This procedure will assignment dummy block ids for blocks starting with -2
-- in order to avoid conflicts somehow.
-- (NOTE: block ids cannot be -1!!! because of deposit logics)
-----------------------------------------------------------------------------
PROCEDURE assign_block_ids(
  p_start_id   IN NUMBER
 ,p_blocks     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
)
IS
  l_timecard_block_id  hxc_time_building_blocks.time_building_block_id%TYPE := p_start_id;
  l_day_block_id       hxc_time_building_blocks.time_building_block_id%TYPE
                         := l_timecard_block_id;
  l_detail_block_id    hxc_time_building_blocks.time_building_block_id%TYPE
                         := p_start_id - p_blocks.count;
  l_old_block_id       hxc_time_building_blocks.time_building_block_id%TYPE;
  l_block_index        NUMBER;
  l_second_block_index NUMBER;
  l_attribute_index    NUMBER;
BEGIN
  l_block_index := p_blocks.first;
  LOOP
    EXIT WHEN NOT p_blocks.EXISTS(l_block_index);

    l_old_block_id := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;

    IF p_blocks(l_block_index).SCOPE = 'TIMECARD'
    THEN
      p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID := l_timecard_block_id;
    ELSIF p_blocks(l_block_index).SCOPE = 'DAY'
    THEN
      l_day_block_id := l_day_block_id - 1;
      p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID := l_day_block_id;
    ELSIF p_blocks(l_block_index).SCOPE = 'DETAIL'
    THEN
      l_detail_block_id := l_detail_block_id + 1;
      p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID := l_detail_block_id;
    END IF;

    -- change parent referenes to this block
    l_second_block_index := p_blocks.first;
    LOOP
      EXIT WHEN NOT p_blocks.EXISTS(l_second_block_index);

      IF p_blocks(l_second_block_index).PARENT_BUILDING_BLOCK_ID = l_old_block_id
      THEN
        p_blocks(l_second_block_index).PARENT_BUILDING_BLOCK_ID
          := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;
      END IF;
      l_second_block_index := p_blocks.next(l_second_block_index);
    END LOOP;

    -- change attribute reference to this block
    l_attribute_index := p_attributes.first;
    LOOP
      EXIT WHEN NOT p_attributes.EXISTS(l_attribute_index);

      IF P_attributes(l_attribute_index).BUILDING_BLOCK_ID = l_old_block_id
      THEN
        p_attributes(l_attribute_index).BUILDING_BLOCK_ID
          := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;
        p_attributes(l_attribute_index).OBJECT_VERSION_NUMBER := 1;

      END IF;

      l_attribute_index := p_attributes.next(l_attribute_index);
    END LOOP;

  l_block_index := p_blocks.next(l_block_index);
  END LOOP;

END assign_block_ids;


FUNCTION get_pref_template(
  p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
)
RETURN VARCHAR2
IS
  l_template_code VARCHAR2(200) := NULL;

BEGIN

  l_template_code := hxc_preference_evaluation.resource_preferences(
                       p_resource_id,
                       'TC_W_TMPLT_DFLT_VAL_USR',
                       1
                     );

  IF l_template_code IS NULL
  THEN
    l_template_code := hxc_preference_evaluation.resource_preferences(
                         p_resource_id,
                         'TC_W_TMPLT_DFLT_VAL_ADMIN',
                         1
                       );
  END IF;

  RETURN l_template_code;
END get_pref_template;

PROCEDURE get_template_info(
  p_template_code    IN  VARCHAR2
 ,p_template_handle  OUT NOCOPY VARCHAR2
 ,p_template_action  OUT NOCOPY VARCHAR2
)
IS
  l_separator_pos    NUMBER := 0;
  l_template_type    VARCHAR2(50) := '';
  l_template_handle  VARCHAR2(500) := '';
  l_template_action  VARCHAR2(20) := '';
BEGIN
  l_separator_pos := INSTR(p_template_code, '|');

  IF l_separator_pos = 0
  THEN
    p_template_handle := NULL;
    p_template_action := 'INVALID';
    RETURN;
  END IF;

  l_template_type := SUBSTR(p_template_code, 1, l_separator_pos - 1);
  l_template_handle := SUBSTR(p_template_code, l_separator_pos + 1);

  IF l_template_type = 'DYNAMIC'
  THEN
    -- we need to retreive a dynamic template for a specific appl
    l_separator_pos := INSTR(l_template_handle, '|');
    IF l_separator_pos = 0
    THEN
      p_template_handle := NULL;
      p_template_action := 'INVALID';
      RETURN;
    END IF;

    l_template_type := SUBSTR(l_template_handle, 1, l_separator_pos - 1);
    p_template_handle := SUBSTR(l_template_handle, l_separator_pos + 1);

    IF l_template_type = 'APP'
    THEN
      p_template_action := 'APP';
    ELSE
      p_template_action := 'SYS';
    END IF;
  ELSE -- if not dynamic
    p_template_handle := l_template_handle;
    p_template_action := 'STATIC';
  END IF;
END get_template_info;


--  ==================================================================
--  This procedure examines and updates blocks info returned by an
--  application autogen routine. It also returns the id of the block
--  which has a scope of 'TIMECARD'. It sets p_timecard_found to false
--  if block count is 0, or if the structure of timecard data is wrong.
--  ==================================================================

PROCEDURE update_blocks(
  p_resource_id     IN     hxc_time_building_blocks.resource_id%TYPE
 ,p_approval_status IN     hxc_time_building_blocks.approval_status%TYPE
 ,p_approval_style  IN     hxc_time_building_blocks.approval_style_id%TYPE
 ,p_blocks          IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_timecard_id        OUT NOCOPY hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_timecard_found     OUT NOCOPY BOOLEAN
)
IS
  l_block_index        NUMBER;
  l_timecard_id        hxc_time_building_blocks.time_building_block_id%TYPE := 0;
  l_approval_style_id  hxc_time_building_blocks.approval_style_id%TYPE;
BEGIN
  p_timecard_found := FALSE;

  l_approval_style_id := TO_NUMBER(p_approval_style);

  l_block_index := p_blocks.first;

  LOOP
    EXIT WHEN NOT p_blocks.exists(l_block_index);

    --populate the following fields as there is no guanrantee the
    --autogen routines will populate them correctly
    p_blocks(l_block_index).PARENT_IS_NEW := 'Y';
    p_blocks(l_block_index).OBJECT_VERSION_NUMBER := 1;
    p_blocks(l_block_index).APPROVAL_STATUS := p_approval_status;
    p_blocks(l_block_index).RESOURCE_ID := p_resource_id;
    p_blocks(l_block_index).RESOURCE_TYPE := 'PERSON';
    p_blocks(l_block_index).APPROVAL_STYLE_ID := p_approval_style;
    p_blocks(l_block_index).DATE_FROM := fnd_date.date_to_canonical(SYSDATE);
    p_blocks(l_block_index).DATE_TO := fnd_date.date_to_canonical(hr_general.end_of_time);
    p_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN := 1;
    p_blocks(l_block_index).NEW := 'Y';

    IF p_blocks(l_block_index).SCOPE = 'TIMECARD'
    THEN
      p_timecard_id := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;
      p_timecard_found := TRUE;
      p_blocks(l_block_index).STOP_TIME := to_char(
      					  fnd_date.canonical_to_date(p_blocks(l_block_index).STOP_TIME),'YYYY/MM/DD')
                                             || ' 23:59:59'; --fnd_date.date_to_canonical(SYSDATE);
    END IF;


    IF p_blocks(l_block_index).SCOPE = 'DAY'
    THEN
      p_blocks(l_block_index).STOP_TIME := to_char(
      					  fnd_date.canonical_to_date(p_blocks(l_block_index).STOP_TIME),'YYYY/MM/DD')
                                             || ' 23:59:59'; --fnd_date.date_to_canonical(SYSDATE);
    END IF;

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;

END update_blocks;


-- given a block (day, timecard), find the record index
-- need p_found flag because block index could be any number
PROCEDURE find_block(
  p_blocks     IN HXC_BLOCK_TABLE_TYPE
 ,p_new_block  IN HXC_BLOCK_TYPE
 ,p_index      OUT NOCOPY NUMBER
 ,p_found      OUT NOCOPY BOOLEAN
)
IS
  l_block_index NUMBER;
  l_date_to     DATE;
BEGIN
  l_block_index := p_blocks.first;
  LOOP
    EXIT WHEN NOT p_blocks.exists(l_block_index);

    IF p_blocks(l_block_index).DATE_TO IS NULL
    THEN
      l_date_to := hr_general.end_of_time;
    ELSE
      l_date_to := fnd_date.canonical_to_date(p_blocks(l_block_index).DATE_TO);
    END IF;

    IF p_new_block.SCOPE = 'TIMECARD'
    THEN
      IF p_blocks(l_block_index).SCOPE = 'TIMECARD'
--array        AND NVL(p_blocks(l_block_index).DATE_TO, hr_general.end_of_time) = hr_general.end_of_time
        AND l_date_to = hr_general.end_of_time
      THEN
        p_index := l_block_index;
        p_found := TRUE;
        RETURN;
      END IF;
    ELSIF p_new_block.SCOPE = 'DAY'
    THEN
      IF p_blocks(l_block_index).SCOPE = 'DAY'
--array        AND NVL(p_blocks(l_block_index).DATE_TO, hr_general.end_of_time) = hr_general.end_of_time
--array        AND TRUNC(p_blocks(l_block_index).START_TIME) = TRUNC(p_new_block.START_TIME)
        AND l_date_to = hr_general.end_of_time
        AND TRUNC(fnd_date.canonical_to_date(p_blocks(l_block_index).START_TIME))
            = TRUNC(fnd_date.canonical_to_date(p_new_block.START_TIME))
      THEN
        p_index := l_block_index;
        p_found := TRUE;
        RETURN;
      END IF;
    END IF;

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;

  -- this should not be happening
  p_index := 0;
  p_found := FALSE;

END find_block;

--------------------------------------------------------------------------------
-- find next available dummy block id for additional detail blocks
--------------------------------------------------------------------------------
FUNCTION get_next_block_id(
  p_blocks IN HXC_BLOCK_TABLE_TYPE
)
RETURN hxc_time_building_blocks.time_building_block_id%TYPE
IS
  l_min_id      hxc_time_building_blocks.time_building_block_id%TYPE;
  l_block_index NUMBER;
BEGIN
  -- existing block structure is also generated by applying a template, we need
  -- to find the next available dummy block id for additional detail blocks
  l_block_index := p_blocks.first;
  l_min_id := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;
  LOOP
    EXIT WHEN NOT p_blocks.exists(l_block_index);

    IF p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID < l_min_id
    THEN
      l_min_id := p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID;
    END IF;

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;

  IF l_min_id > 0
  THEN
    l_min_id := -2;
  ELSE
    l_min_id := l_min_id - 1;
  END IF;

  RETURN l_min_id;
END get_next_block_id;



FUNCTION get_next_attribute_id(
  p_attributes IN HXC_ATTRIBUTE_TABLE_TYPE
)
RETURN NUMBER
IS

l_attribute_index NUMBER;
l_next_att_id     NUMBER;
BEGIN
  l_next_att_id := -2;

  l_attribute_index := p_attributes.first;
  LOOP
    EXIT WHEN NOT p_attributes.exists(l_attribute_index);

    IF p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID <= l_next_att_id
    THEN
      l_next_att_id := p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID - 1;
    END IF;

    l_attribute_index := p_attributes.next(l_attribute_index);
  END LOOP;

  RETURN l_next_att_id;
END;


-- update new attributes to ensure we get unique attribute ids
PROCEDURE assign_attribute_ids(
  p_start_id   IN NUMBER
 ,p_attributes IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
)
IS
  l_new_attribute_id    NUMBER := p_start_id;
  l_new_attribute_index NUMBER;
BEGIN
  l_new_attribute_index := p_attributes.first;
  LOOP
    EXIT WHEN NOT p_attributes.exists(l_new_attribute_index);

    p_attributes(l_new_attribute_index).time_attribute_id := l_new_attribute_id;

    l_new_attribute_id := l_new_attribute_id - 1;
    l_new_attribute_index := p_attributes.next(l_new_attribute_index);
  END LOOP;
END assign_attribute_ids;


PROCEDURE add_attribute(
  p_total_attributes    IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_new_attribute       IN HXC_ATTRIBUTE_TYPE
 ,p_new_block_id        IN NUMBER
 ,p_new_attribute_id    IN OUT NOCOPY NUMBER
)
IS
  l_attribute_count NUMBER;
BEGIN
  l_attribute_count := NVL(p_total_attributes.last, 0);
  p_total_attributes.extend;

  p_total_attributes(l_attribute_count + 1) := p_new_attribute;
  p_total_attributes(l_attribute_count + 1).BUILDING_BLOCK_ID := p_new_block_id;
  p_total_attributes(l_attribute_count + 1).TIME_ATTRIBUTE_ID := p_new_attribute_id;

  p_new_attribute_id := p_new_attribute_id - 1;
END add_attribute;


PROCEDURE translate_alias(
  p_attribute_array IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_block_array     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_resource_id     IN VARCHAR2
 ,p_start_time      IN VARCHAR2
 ,p_stop_time       IN VARCHAR2
)
IS
--  l_attributes 	hxc_self_service_time_deposit.building_block_attribute_info;
--  l_blocks		hxc_self_service_time_deposit.timecard_info;
l_messages	HXC_MESSAGE_TABLE_TYPE;

BEGIN

  --temporary convertion
  --l_attributes		:= hxc_deposit_wrapper_utilities.array_to_attributes(
  --                        p_attribute_array => p_attribute_array
  --                          );

  --l_blocks 		:= hxc_deposit_wrapper_utilities.array_to_blocks(
  --                        p_block_array => p_block_array
  --                          );


  HXC_ALIAS_TRANSLATOR.do_retrieval_translation(
    p_attributes  	=> p_attribute_array
   ,p_blocks		=> p_block_array
   ,p_start_time  	=> FND_DATE.CANONICAL_TO_DATE(p_start_time)
   ,p_stop_time   	=> FND_DATE.CANONICAL_TO_DATE(p_stop_time)
   ,p_resource_id 	=> p_resource_id
   ,p_messages		=> l_messages
  );

  --p_attribute_array := hxc_deposit_wrapper_utilities.attributes_to_array(
  --                       p_attributes => l_attributes
  --                     );
END translate_alias;


-- v115.58 kSethi adding new procedure
-- to pad missing DAYS incase a template with a shorter time period
-- is applied to a timecard with a greater time period.
PROCEDURE chk_all_days_in_block (
   p_resource_id     IN              VARCHAR2,
   p_resource_type   IN              VARCHAR2,
   p_start_time      IN              VARCHAR2,
   p_stop_time       IN              VARCHAR2,
   p_template_code   IN              VARCHAR2,
   p_block_array     IN OUT NOCOPY   hxc_block_table_type
)
IS
   -- Variables....
   l_day_exists       BOOLEAN;
   l_day_found        BOOLEAN;
   l_cached           BOOLEAN              := FALSE ;
   l_cache_index      BINARY_INTEGER;
   l_index_day        BINARY_INTEGER;
   l_last_index       BINARY_INTEGER;
   l_blocks           hxc_block_table_type;
   l_next_block_id    NUMBER;
   l_num_days         NUMBER;
   l_new_start_time   DATE;
   l_new_stop_time    DATE;
   l_dummy_block  boolean := FALSE;
   --

   l_proc             VARCHAR2 (70);
BEGIN


   IF g_debug THEN
   	l_proc := 'chk_all_days_in_block';
   	hr_utility.set_location (g_package || l_proc, 120);
   END IF;
-- Get the range calculated
   l_new_start_time := fnd_date.canonical_to_date (p_start_time);
   l_new_stop_time := fnd_date.canonical_to_date (p_stop_time);
   l_num_days := l_new_stop_time - l_new_start_time;

-- Loop for the total number of days in the time period.
   WHILE l_num_days <> -1
   LOOP

      l_index_day  := NULL;
      l_index_day  := p_block_array.FIRST;
      l_day_exists := FALSE ;

      WHILE l_index_day IS NOT NULL
      LOOP
         IF (    p_block_array (l_index_day).SCOPE = 'DAY'
             AND p_block_array (l_index_day).start_time =
                                fnd_date.date_to_canonical (l_new_start_time)
             AND p_block_array (l_index_day).date_to =
                          fnd_date.date_to_canonical (hr_general.end_of_time)
             AND p_block_array (l_index_day).object_version_number <> -99999
            )
         THEN
            l_day_exists := TRUE ;
         END IF; -- Scope = DAY
         l_index_day := p_block_array.NEXT (l_index_day);
      END LOOP; -- l_index_day is not null

      -- Cache information incase an update is needed for further use
      IF NOT l_cached
      THEN
         IF NOT l_day_exists
         THEN
            -- cache day info that can be used for later updates as well...
            l_blocks := hxc_block_table_type ();
            l_cache_index := NULL;
            l_cache_index := p_block_array.FIRST;
            l_day_found := FALSE ;

            WHILE l_cache_index IS NOT NULL
            LOOP
               IF (    p_block_array (l_cache_index).SCOPE = 'DAY'
                   AND p_block_array (l_cache_index).date_to =
                          fnd_date.date_to_canonical (hr_general.end_of_time)
                  )
               THEN
                  l_blocks.EXTEND;
                  l_blocks (1) := p_block_array (l_cache_index);
                  l_day_found := TRUE ;
               END IF; -- Scope = DAY
               IF l_day_found
               THEN
                  l_cache_index := NULL;
               ELSE
                  l_cache_index := p_block_array.NEXT (l_cache_index);
               END IF;
            END LOOP; -- l_cache_index is not null
            l_cached := TRUE ;
         END IF; -- l_day_exists
      END IF; -- l_cached
      IF NOT l_day_exists
      THEN
         l_last_index := NULL;
         l_last_index := p_block_array.LAST;
         l_last_index := l_last_index + 1;
         l_next_block_id := get_next_block_id (p_blocks => p_block_array);
         p_block_array.EXTEND;

	 If p_block_array.count <  p_block_array.LAST then
	    		l_dummy_block:= true;
	 else
	    	 	l_dummy_block:= false;
   	 end if;

	 p_block_array (l_last_index) :=
            hxc_block_type (
               l_next_block_id,
               l_blocks (1).TYPE,
               l_blocks (1).measure,
               l_blocks (1).unit_of_measure,
               fnd_date.date_to_canonical (l_new_start_time),
               TO_CHAR (l_new_start_time, 'YYYY/MM/DD') || ' 23:59:59',
               l_blocks (1).parent_building_block_id,
               l_blocks (1).parent_is_new,
               l_blocks (1).SCOPE,
               -99999,
               l_blocks (1).approval_status,
               l_blocks (1).resource_id,
               l_blocks (1).resource_type,
               l_blocks (1).approval_style_id,
               l_blocks (1).date_from,
               l_blocks (1).date_to,
               l_blocks (1).comment_text,
               l_blocks (1).parent_building_block_ovn,
               l_blocks (1).NEW,
               l_blocks (1).changed,
               l_blocks (1).process,
               l_blocks (1).application_set_id,
               NULL
            );

            if l_dummy_block and p_block_array(p_block_array.LAST).TIME_BUILDING_BLOCK_ID is null then
	            	p_block_array.delete(p_block_array.LAST);
            end if;

      END IF; -- l_day_exists
      l_new_start_time := l_new_start_time + 1;
      l_num_days := l_num_days - 1;
   END LOOP; -- l_num_days <> -1

   -- Update OVNs to the correct value
   l_last_index := NULL;
   l_last_index := p_block_array.FIRST;
   WHILE l_last_index IS NOT NULL
   LOOP
      IF (p_block_array (l_last_index).object_version_number = -99999)
      THEN
         p_block_array (l_last_index).object_version_number := 1;
      END IF;

      l_last_index := p_block_array.NEXT (l_last_index);
   END LOOP;

-- Temp check note sure if we need, hence not calling....
/*   assign_block_ids(
     p_start_id   => -2
    ,p_blocks     => p_block_array
    ,p_attributes => p_attribute_array
   );
*/
END chk_all_days_in_block;


PROCEDURE append_blocks(
  p_block_array          IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array      IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_new_blocks           IN HXC_BLOCK_TABLE_TYPE
 ,p_new_attributes       IN HXC_ATTRIBUTE_TABLE_TYPE
 ,p_overwrite            IN VARCHAR2
 ,p_start_time           IN VARCHAR2
 ,p_stop_time            IN VARCHAR2
 ,p_resource_id          IN VARCHAR2
 ,p_resource_type        IN VARCHAR2
 ,p_template_code        IN VARCHAR2
 ,p_remove_redundant_entries IN BOOLEAN
)
IS
  l_complete_blocks      HXC_BLOCK_TABLE_TYPE;
  l_complete_attributes  HXC_ATTRIBUTE_TABLE_TYPE;
  l_new_blocks           HXC_BLOCK_TABLE_TYPE;
  l_new_blocks_array     HXC_BLOCK_TABLE_TYPE;
  l_new_attributes       HXC_ATTRIBUTE_TABLE_TYPE;
  l_next_detail_id       hxc_time_building_blocks.time_building_block_id%TYPE;
  l_complete_block_count     NUMBER;
  l_complete_attribute_count NUMBER;
  l_new_block_index          NUMBER;
  l_detail_index             NUMBER;
  l_old_block_index          NUMBER;
  l_attribute_index          NUMBER;
  l_found                    BOOLEAN;
  --
  l_block_index              NUMBER;
  l_new_attribute_index      NUMBER;
  l_new_attribute_id         NUMBER;
  l_existing_att_index       NUMBER;
  l_next_block_id            NUMBER;
  l_new_att_index            NUMBER;
  l_timecard_row_count       NUMBER;
  l_proc                     VARCHAR2(70);
BEGIN


  IF g_debug THEN
  	l_proc := 'append_blocks';
  	hr_utility.set_location ( g_package||l_proc, 300);
  END IF;

  l_new_blocks := p_new_blocks;
  l_new_attributes := p_new_attributes;

  -- if in blocks is null, we only need to assign block ids for the newly generated
  -- blocks and attributes and return them
  IF p_block_array.count = 0
  THEN
    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 310);
    END IF;

    assign_block_ids(
      p_start_id   => -2
     ,p_blocks     => l_new_blocks
     ,p_attributes => l_new_attributes
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 320);
    END IF;

    assign_attribute_ids(
      p_start_id   => -2
     ,p_attributes => l_new_attributes
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 330);
    END IF;


    p_block_array := l_new_blocks;

    p_attribute_array := l_new_attributes;

    --translate alias here
    translate_alias(
      p_attribute_array => p_attribute_array
     ,p_block_array     => p_block_array
     ,p_resource_id     => p_resource_id
     ,p_start_time      => p_start_time
     ,p_stop_time       => p_stop_time
    );

    RETURN;
  END IF;

  l_complete_blocks := HXC_BLOCK_TABLE_TYPE();
  l_complete_blocks := p_block_array;

  l_next_block_id := get_next_block_id(p_blocks => l_complete_blocks);

  --if overwrite flag is set, end date all the blocks and append new blocks.
  --
  IF p_overwrite = 'Y'
  THEN
    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 340);
    END IF;

    --end date all the existing blocks
    l_block_index := l_complete_blocks.first;
    LOOP
      EXIT WHEN NOT l_complete_blocks.exists(l_block_index);

      l_complete_blocks(l_block_index).DATE_TO := fnd_date.date_to_canonical(sysdate);

      l_block_index := l_complete_blocks.next(l_block_index);
    END LOOP;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 350);
    END IF;

    -- append new blocks
    -- before we append new blocks, we need to assign new ids to new blocks

    assign_block_ids(
      p_start_id   => l_next_block_id
     ,p_blocks     => l_new_blocks
     ,p_attributes => l_new_attributes
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 360);
    END IF;

    l_block_index := l_complete_blocks.last + 1;
    l_new_block_index := l_new_blocks.first;
    LOOP
      EXIT WHEN NOT l_new_blocks.exists(l_new_block_index);

      l_complete_blocks.extend;
      l_complete_blocks(l_block_index) := l_new_blocks(l_new_block_index);

      l_block_index := l_block_index + 1;
      l_new_block_index := l_new_blocks.next(l_new_block_index);
    END LOOP;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 370);
    END IF;

    l_new_attribute_id := get_next_attribute_id(
                          p_attributes => p_attribute_array
                        );

    assign_attribute_ids(
      p_start_id   => l_new_attribute_id
     ,p_attributes => l_new_attributes
    );


    p_block_array := l_complete_blocks;

    --p_attribute_array := l_new_attributes;

    --mbhammar : add the missing blocks before translation, so the new blocks get included in translation
    --ref : bug 4996639
    IF p_block_array.COUNT > 0 THEN
	chk_all_days_in_block(
	      p_resource_id      => p_resource_id
	     ,p_resource_type    => p_resource_type
	     ,p_start_time       => p_start_time
	     ,p_stop_time        => p_stop_time
	     ,p_template_code    => p_template_code
	     ,p_block_array      => p_block_array
	    );
     END IF;

    --translate alias here
    translate_alias(
      p_attribute_array => l_new_attributes
     ,p_block_array     => p_block_array
     ,p_resource_id     => p_resource_id
     ,p_start_time      => p_start_time
     ,p_stop_time       => p_stop_time
    );

    --support for CLA
    l_new_att_index := NVL(l_new_attributes.last, 0);
    FOR i in p_attribute_array.first .. p_attribute_array.last
    LOOP
      l_new_attributes.extend;

      l_new_att_index := l_new_att_index + 1;
      l_new_attributes(l_new_att_index) := p_attribute_array(i);
    END LOOP;

    p_attribute_array := l_new_attributes;

    RETURN;
  END IF;


  -- overwrite flag is not set, we need to end date all the in detail blocks and append
  -- new blocks and attributes to the existing block structure. We also need to append
  -- comment to the comment_text fields of timecard and day blocks.
  l_new_blocks_array := p_new_blocks;
  l_timecard_row_count := hxc_trans_display_key_utils.timecard_row_count
                            (l_complete_blocks);
  --translate alias here
  translate_alias(
    p_attribute_array => l_new_attributes
   ,p_block_array     => l_new_blocks_array
   ,p_resource_id     => p_resource_id
   ,p_start_time      => p_start_time
   ,p_stop_time       => p_stop_time
  );

  IF(p_remove_redundant_entries = TRUE) THEN
	      remove_redundant_attributesets(p_timecard_blocks => p_block_array,
					 p_timecard_attributes => p_attribute_array,
					 p_zero_template_blocks => l_new_blocks_array,
					 p_zero_template_attributes => l_new_attributes);
  END IF;

  l_complete_attributes := p_attribute_array;

IF((p_overwrite = 'Y')
    AND
   (NOT chk_template_override_appr_set(l_new_attributes))
   )THEN
-- we dont need to retain the overriding approver in the timecard,
-- if the template *doesn't* contain one incase of overwriting.
-- We do it well before the if condition to remove the redundant
-- attributes, because we dont need to check for the following scenario again n again
-- inside the loop.
     remove_override_approver(l_complete_attributes);
END IF;

  l_new_attribute_id := get_next_attribute_id(
                          p_attributes => l_complete_attributes
                        );
  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 380);
  END IF;

  l_complete_block_count := l_complete_blocks.last + 1;
  l_complete_attribute_count := l_complete_attributes.last + 1;

  --changed from p_new_blocks to l_new_blocks_array, since the removal of redundant entries
  --is done on l_new_blocks_array.

  l_new_block_index := l_new_blocks_array.first;
  LOOP
    EXIT WHEN NOT l_new_blocks_array.exists(l_new_block_index);

    -- we only want to add detail blocks to the corresponding day blocks in
    -- the existing block structure
    IF l_new_blocks_array(l_new_block_index).SCOPE = 'TIMECARD'
       OR l_new_blocks_array(l_new_block_index).SCOPE = 'DAY'
    THEN
      find_block(
        p_blocks    => l_complete_blocks
       ,p_new_block => l_new_blocks_array(l_new_block_index)
       ,p_index     => l_old_block_index
       ,p_found     => l_found
      );

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 390);
      END IF;

      -- append comment to corrresponding block
      -- attach attributes to corrresponding block
      IF l_found
      THEN
        IF g_debug THEN
        	hr_utility.set_location ( g_package||l_proc, 400);
        END IF;

        --append comments
        IF l_new_blocks_array(l_new_block_index).COMMENT_TEXT IS NOT NULL
        THEN
          IF l_complete_blocks(l_old_block_index).COMMENT_TEXT IS NULL
          THEN
            l_complete_blocks(l_old_block_index).COMMENT_TEXT
              := l_new_blocks_array(l_new_block_index).COMMENT_TEXT;
          ELSE
            l_complete_blocks(l_old_block_index).COMMENT_TEXT
              :=
              -- Bug 8937768
              SUBSTR(l_complete_blocks(l_old_block_index).COMMENT_TEXT
              || fnd_global.local_chr(10)
              || l_new_blocks_array(l_new_block_index).COMMENT_TEXT,1,2000);
          END IF;
        END IF;

        IF g_debug THEN
        	hr_utility.set_location ( g_package||l_proc, 410);
        END IF;

        --append attributes
        l_attribute_index := l_new_attributes.first;
        LOOP
          EXIT WHEN NOT l_new_attributes.exists(l_attribute_index);

          IF l_new_attributes(l_attribute_index).BUILDING_BLOCK_ID
            = l_new_blocks_array(l_new_block_index).TIME_BUILDING_BLOCK_ID
          THEN
            --ignore layout and security attributes
            --override other attributes
            IF l_new_attributes(l_attribute_index).ATTRIBUTE_CATEGORY <> 'LAYOUT'
              AND l_new_attributes(l_attribute_index).ATTRIBUTE_CATEGORY <> 'SECURITY'
            THEN
              --check if there is a redundant attribute, if so, remove it
              l_existing_att_index := l_complete_attributes.first;
              LOOP
                EXIT WHEN NOT l_complete_attributes.exists(l_existing_att_index);

                IF l_complete_attributes(l_existing_att_index).BUILDING_BLOCK_ID
                  = l_complete_blocks(l_old_block_index).TIME_BUILDING_BLOCK_ID
                THEN
                  IF l_complete_attributes(l_existing_att_index).ATTRIBUTE_CATEGORY
                    = l_new_attributes(l_attribute_index).ATTRIBUTE_CATEGORY
                  THEN
		   -- New Code Addced here.
                     IF ((l_new_attributes(l_attribute_index).ATTRIBUTE_CATEGORY = 'APPROVAL')
			 AND (p_overwrite <>'Y')
			  )THEN
                             -- Retain the Overriding Approver if the template has a NULL entry.
                             -- while appending.
			     l_new_attributes(l_attribute_index).ATTRIBUTE10 :=
                             l_complete_attributes(l_existing_att_index).ATTRIBUTE10;
	              END IF;
                    l_complete_attributes.delete(l_existing_att_index);
                    EXIT;
                  END IF;
                END IF;

                l_existing_att_index := l_complete_attributes.next(l_existing_att_index);
              END LOOP;

              add_attribute(
                p_total_attributes => l_complete_attributes
               ,p_new_attribute    => l_new_attributes(l_attribute_index)
               ,p_new_block_id     => l_complete_blocks(l_old_block_index).TIME_BUILDING_BLOCK_ID
               ,p_new_attribute_id => l_new_attribute_id
              );

            END IF;
          END IF;

          l_attribute_index := l_new_attributes.next(l_attribute_index);
        END LOOP;

        IF g_debug THEN
        	hr_utility.set_location ( g_package||l_proc, 420);
        END IF;

        IF l_new_blocks_array(l_new_block_index).SCOPE = 'DAY'
        THEN
          -- find the details for the day. add them to the existing
          -- block structure. We also need to add the attributes associated
          -- with the detail blocks to the existing attribute structure.
          l_detail_index := l_new_blocks_array.first;
          LOOP
            EXIT WHEN NOT l_new_blocks_array.exists(l_detail_index);

            IF l_new_blocks_array(l_detail_index).SCOPE = 'DETAIL'
               AND l_new_blocks_array(l_detail_index).PARENT_BUILDING_BLOCK_ID
                 = l_new_blocks_array(l_new_block_index).TIME_BUILDING_BLOCK_ID
            THEN
              -- add detail blocks first
              l_complete_blocks.extend;
              l_complete_blocks(l_complete_block_count) := l_new_blocks_array(l_detail_index);
              l_complete_blocks(l_complete_block_count).TIME_BUILDING_BLOCK_ID
                :=  l_next_block_id;
              l_complete_blocks(l_complete_block_count).PARENT_BUILDING_BLOCK_ID
                := l_complete_blocks(l_old_block_index).TIME_BUILDING_BLOCK_ID;
              l_complete_blocks(l_complete_block_count).PARENT_IS_NEW
                := l_complete_blocks(l_old_block_index).NEW;
              l_complete_blocks(l_complete_block_count).PARENT_BUILDING_BLOCK_OVN
                := l_complete_blocks(l_old_block_index).OBJECT_VERSION_NUMBER;
              l_complete_blocks(l_complete_block_count).TRANSLATION_DISPLAY_KEY
                 := hxc_trans_display_key_utils.new_display_key
                      (l_complete_blocks(l_complete_block_count).translation_display_key,
                       l_timecard_row_count
                       );

              -- then add attributes
              l_attribute_index := l_new_attributes.first;
              LOOP
                EXIT WHEN NOT l_new_attributes.exists(l_attribute_index);

                IF l_new_attributes(l_attribute_index).BUILDING_BLOCK_ID
                   = l_new_blocks_array(l_detail_index).TIME_BUILDING_BLOCK_ID
                THEN
                  add_attribute(
                    p_total_attributes => l_complete_attributes
                   ,p_new_attribute    => l_new_attributes(l_attribute_index)
                   ,p_new_block_id     => l_next_block_id
                   ,p_new_attribute_id => l_new_attribute_id
                  );

                END IF;

                l_attribute_index := l_new_attributes.next(l_attribute_index);
              END LOOP;

              l_complete_block_count := l_complete_block_count + 1;
              l_next_block_id := l_next_block_id - 1;
            END IF;

            l_detail_index := l_new_blocks_array.next(l_detail_index);
          END LOOP;
        END IF;
      END IF;
    END IF;

    l_new_block_index := l_new_blocks_array.next(l_new_block_index);
  END LOOP;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 430);
  END IF;

  p_block_array :=  l_complete_blocks;

  p_attribute_array := l_complete_attributes;

END append_blocks;


/*
FUNCTION attributes_to_array(
  p_attributes IN hxc_self_service_time_deposit.building_block_attribute_info
)
RETURN HXC_ATTRIBUTE_TABLE_TYPE
IS
  l_attribute_array HXC_ATTRIBUTE_TABLE_TYPE;
  l_attribute HXC_ATTRIBUTE_TYPE;
  l_array_index NUMBER := 0;
  l_attribute_index NUMBER;
  l_proc              VARCHAR2(50);
BEGIN


  IF g_debug THEN
  	l_proc := 'attributes_to_array';
  	hr_utility.set_location ( g_package||l_proc, 10);
  END IF;

  --initialize attribute array
  l_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();

  l_attribute_index := p_attributes.first;
  LOOP
    EXIT WHEN NOT p_attributes.exists(l_attribute_index);

    l_array_index := l_array_index + 1;
    l_attribute_array.extend;

    l_attribute_array(l_array_index) :=
      HXC_ATTRIBUTE_TYPE(
        p_attributes(l_attribute_index).TIME_ATTRIBUTE_ID
       ,p_attributes(l_attribute_index).BUILDING_BLOCK_ID
       ,p_attributes(l_attribute_index).ATTRIBUTE_CATEGORY
       ,p_attributes(l_attribute_index).ATTRIBUTE1
       ,p_attributes(l_attribute_index).ATTRIBUTE2
       ,p_attributes(l_attribute_index).ATTRIBUTE3
       ,p_attributes(l_attribute_index).ATTRIBUTE4
       ,p_attributes(l_attribute_index).ATTRIBUTE5
       ,p_attributes(l_attribute_index).ATTRIBUTE6
       ,p_attributes(l_attribute_index).ATTRIBUTE7
       ,p_attributes(l_attribute_index).ATTRIBUTE8
       ,p_attributes(l_attribute_index).ATTRIBUTE9
       ,p_attributes(l_attribute_index).ATTRIBUTE10
       ,p_attributes(l_attribute_index).ATTRIBUTE11
       ,p_attributes(l_attribute_index).ATTRIBUTE12
       ,p_attributes(l_attribute_index).ATTRIBUTE13
       ,p_attributes(l_attribute_index).ATTRIBUTE14
       ,p_attributes(l_attribute_index).ATTRIBUTE15
       ,p_attributes(l_attribute_index).ATTRIBUTE16
       ,p_attributes(l_attribute_index).ATTRIBUTE17
       ,p_attributes(l_attribute_index).ATTRIBUTE18
       ,p_attributes(l_attribute_index).ATTRIBUTE19
       ,p_attributes(l_attribute_index).ATTRIBUTE20
       ,p_attributes(l_attribute_index).ATTRIBUTE21
       ,p_attributes(l_attribute_index).ATTRIBUTE22
       ,p_attributes(l_attribute_index).ATTRIBUTE23
       ,p_attributes(l_attribute_index).ATTRIBUTE24
       ,p_attributes(l_attribute_index).ATTRIBUTE25
       ,p_attributes(l_attribute_index).ATTRIBUTE26
       ,p_attributes(l_attribute_index).ATTRIBUTE27
       ,p_attributes(l_attribute_index).ATTRIBUTE28
       ,p_attributes(l_attribute_index).ATTRIBUTE29
       ,p_attributes(l_attribute_index).ATTRIBUTE30
       ,p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE_ID
       ,p_attributes(l_attribute_index).OBJECT_VERSION_NUMBER
       ,p_attributes(l_attribute_index).NEW
       ,p_attributes(l_attribute_index).CHANGED
       ,p_attributes(l_attribute_index).BLD_BLK_INFO_TYPE
       ,'N'
       ,NULL);

    l_attribute_index := p_attributes.next(l_attribute_index);
  END LOOP;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 20);
  END IF;
  RETURN l_attribute_array;
END attributes_to_array;
*/

/*
FUNCTION blocks_to_array(
  p_blocks IN hxc_self_service_time_deposit.timecard_info
)
RETURN HXC_BLOCK_TABLE_TYPE
IS
  l_block_array HXC_BLOCK_TABLE_TYPE;
  l_array_index NUMBER := 0;
  l_block_index NUMBER;
  l_proc VARCHAR2(50);
  l_block HXC_BLOCK_TYPE;

BEGIN


  IF g_debug THEN
  	l_proc := 'blocks_to_array';
  	hr_utility.set_location ( g_package||l_proc, 10);
  END IF;

  l_block_array := HXC_BLOCK_TABLE_TYPE();

  l_block_index := p_blocks.first;
  LOOP
    EXIT WHEN NOT p_blocks.exists(l_block_index);

    l_array_index := l_array_index + 1;
    l_block_array.extend;

    l_block_array(l_array_index) :=
      HXC_BLOCK_TYPE(
        p_blocks(l_block_index).TIME_BUILDING_BLOCK_ID
       ,p_blocks(l_block_index).TYPE
       ,p_blocks(l_block_index).MEASURE
       ,p_blocks(l_block_index).UNIT_OF_MEASURE
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).START_TIME)
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).STOP_TIME)
       ,p_blocks(l_block_index).PARENT_BUILDING_BLOCK_ID
       ,p_blocks(l_block_index).PARENT_IS_NEW
       ,p_blocks(l_block_index).SCOPE
       ,p_blocks(l_block_index).OBJECT_VERSION_NUMBER
       ,p_blocks(l_block_index).APPROVAL_STATUS
       ,p_blocks(l_block_index).RESOURCE_ID
       ,p_blocks(l_block_index).RESOURCE_TYPE
       ,p_blocks(l_block_index).APPROVAL_STYLE_ID
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).DATE_FROM)
       ,fnd_date.date_to_canonical(p_blocks(l_block_index).DATE_TO)
       ,p_blocks(l_block_index).COMMENT_TEXT
       ,p_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN
       ,p_blocks(l_block_index).NEW
       ,p_blocks(l_block_index).CHANGED
     );

    l_block_index := p_blocks.next(l_block_index);
  END LOOP;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 140);
  END IF;
  RETURN l_block_array;
END blocks_to_array;
*/

  PROCEDURE remove_blocks
     (p_blocks      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE,
      p_attributes  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,
      p_block_index IN     NUMBER
      ) is
     l_index      NUMBER;
     l_attr_index NUMBER;
  BEGIN
     --
     -- First clean up any attributes
     --
     l_attr_index := p_attributes.first;
     Loop
        Exit when not p_attributes.exists(l_attr_index);
        if(p_attributes(l_attr_index).building_block_id = p_blocks(p_block_index).time_building_block_id) then
           p_attributes.delete(l_attr_index);
        end if;
        l_attr_index := p_attributes.next(l_attr_index);
     End Loop;
     -- Remove the block itself.
     --
     p_blocks.delete(p_block_index);
  End remove_blocks;

procedure get_dynamic_templates_info(
p_template_procedure HXC_TIME_RECIPIENTS.APPL_DYNAMIC_TEMPLATE_PROCESS%TYPE,
p_tp_resource_id IN NUMBER,
p_tp_start_time IN  DATE,
p_tp_stop_time IN  DATE,
p_attribute_string IN OUT NOCOPY VARCHAR2,
p_block_string IN OUT NOCOPY VARCHAR2,
p_message_string IN OUT NOCOPY VARCHAR2,
p_messages IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE )

IS
l_dyn_template_sql   VARCHAR2(2000);

begin


IF g_debug THEN
	hr_utility.trace ('p_template_procedure='||p_template_procedure);
END IF;
hxc_timecard_message_helper.initializeErrors;

l_dyn_template_sql := 'BEGIN '||fnd_global.newline
                   ||p_template_procedure    ||fnd_global.newline
                   ||'(p_resource_id => :1'  ||fnd_global.newline
                   ||',p_start_date  => :2'  ||fnd_global.newline
                   ||',p_stop_date   => :3'  ||fnd_global.newline
                   ||',p_attributes  => :4'  ||fnd_global.newline
                   ||',p_timecard    => :5'  ||fnd_global.newline
                   ||',p_messages    => :6);'||fnd_global.newline
                   ||'END;';

IF g_debug THEN
	hr_utility.trace ('l_dyn_template_sql='||l_dyn_template_sql);
END IF;


  EXECUTE IMMEDIATE l_dyn_template_sql
            using IN p_tp_resource_id, IN p_tp_start_time, IN
p_tp_stop_time, IN OUT p_attribute_string,IN OUT p_block_string,IN OUT
p_message_string;

EXCEPTION
when others then

	hxc_timecard_message_helper.addErrorToCollection
	    (p_messages
	    ,'HXC_INVALID_DYNAMIC_TEMPL'
	    ,hxc_timecard.c_error
	    ,null
	    ,null
	    ,hxc_timecard.c_hxc
	    ,null
	    ,null
	    ,null
	    ,null
	    );

end get_dynamic_templates_info;

PROCEDURE get_blocks_from_template(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_approval_style   IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2 DEFAULT 'Y'
 ,p_exclude_hours_template in VARCHAR2 DEFAULT 'N'
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
)
IS
  l_template_type               VARCHAR2(50) := '';
  l_template_handle             VARCHAR2(500) := '';
  l_template_action             VARCHAR2(20) :='';
  l_temp_blocks                 hxc_self_service_time_deposit.timecard_info;
  l_blocks                      HXC_BLOCK_TABLE_TYPE;
  l_attributes                  HXC_ATTRIBUTE_TABLE_TYPE;
  l_temp_attributes             hxc_self_service_time_deposit.building_block_attribute_info;
  l_app_attributes              hxc_self_service_time_deposit.app_attributes_info;
  l_block_string                VARCHAR2(32767) := '';
  l_attribute_string            VARCHAR2(32767) := '';
  l_message_string              VARCHAR2(32767) := '';
  l_temp                        VARCHAR2(32767) := '';
  l_block_index                 NUMBER := 1;
  l_attribute_index             NUMBER := 1;
  l_detail_start_date           DATE;
  l_detail_stop_date            DATE;
  l_zero_template               VARCHAR2(1);
  l_template_procedure          HXC_TIME_RECIPIENTS.APPL_DYNAMIC_TEMPLATE_PROCESS%TYPE;
  l_dyn_template_sql            VARCHAR2(2000);
  l_process_id                  HXC_RETRIEVAL_PROCESSES.RETRIEVAL_PROCESS_ID%TYPE;
  l_tp_resource_id              NUMBER := TO_NUMBER(p_resource_id);
  l_tp_start_time               DATE := TO_DATE(p_start_time, 'YYYY/MM/DD');
  l_tp_stop_time                DATE := TO_DATE(p_stop_time, 'YYYY/MM/DD');
  l_timecard_id                 hxc_time_building_blocks.time_building_block_id%TYPE;
  l_old_block_id                hxc_time_building_blocks.time_building_block_id%TYPE;
  l_template_id                 hxc_time_building_blocks.time_building_block_id%TYPE;
  l_timecard_block_id           NUMBER := -1;
  l_day_block_id                NUMBER := -1;
  l_next_id                     NUMBER := -1;
  l_detail_block_id             NUMBER;
  l_new_start_time              DATE;
  l_new_stop_time               DATE;
  l_old_start_time              DATE;
  l_old_stop_time               DATE;
  l_difference                  NUMBER;
  l_start_time                  DATE;
  l_second_block_index          NUMBER;
  l_timecard_found              BOOLEAN;
  l_remove_redundant_entries    BOOLEAN;
  l_found                       BOOLEAN;
  l_template_display_key        BOOLEAN;
  l_timecard_display_key        BOOLEAN;
  l_block_array_idx             PLS_INTEGER;
  l_proc                        VARCHAR2(70);
  l_clear_comment		VARCHAR2(1);

  CURSOR c_dyn_template_procedure(
    p_dyn_template_app IN VARCHAR2
  )
  IS
    select htr.appl_dynamic_template_process
      from hxc_time_recipients htr,
           fnd_application fa
     where fa.application_short_name = p_dyn_template_app
       and htr.application_id = fa.application_id;

  CURSOR c_last_timecard(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN VARCHAR2
  )
  IS
    SELECT time_building_block_id
      FROM (
              SELECT time_building_block_id
                FROM hxc_time_building_blocks tbb1
               WHERE tbb1.resource_id = p_resource_id
                 AND tbb1.resource_type = p_resource_type
                 AND tbb1.scope = 'TIMECARD'
                 AND to_char(tbb1.stop_time,'YYYY/MM/DD') < p_start_time
                 AND date_to = hr_general.end_of_time
            ORDER BY tbb1.stop_time desc
           )
     WHERE rownum = 1;

  CURSOR c_otm_retrieval_process(
    p_process_name IN hxc_retrieval_processes.NAME%TYPE
  )
  IS
    SELECT retrieval_process_id
      FROM hxc_retrieval_processes
     WHERE name = p_process_name;

  CURSOR c_retrieval_process(
    p_dyn_template_process IN hxc_time_recipients.appl_dynamic_template_process%TYPE
  )
  IS
    SELECT hrp.retrieval_process_id
      FROM hxc_retrieval_processes hrp,
           hxc_time_recipients htr
     WHERE htr.appl_dynamic_template_process = p_dyn_template_process
       AND htr.time_recipient_id = hrp.time_recipient_id;

BEGIN


  l_remove_redundant_entries := FALSE;
  IF g_debug THEN
  	l_proc := 'get_blocks_from_template';
  	hr_utility.set_location ( g_package||l_proc, 120);
  END IF;
  l_template_type := SUBSTR(p_template_code, 1, INSTR(p_template_code, '|') - 1);
  get_template_info(
    p_template_code   => p_template_code
   ,p_template_handle => l_template_handle
   ,p_template_action => l_template_action
  );

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 130);
  END IF;

  IF l_template_action = 'INVALID'
  THEN
    RETURN;
  END IF;

  IF l_template_action = 'APP'
    OR (l_template_action = 'SYS' AND l_template_handle = 'WORK_SCHEDULE')
  THEN

    -- for OTM work schedule
    IF l_template_handle = 'WORK_SCHEDULE'
    THEN

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 140);
      END IF;

      HXT_TIMECARD_INFO.GENERATE_TIME(
        p_resource_id     => TO_NUMBER(p_resource_id)
       ,p_start_time      => TO_DATE(p_start_time, 'YYYY/MM/DD')
       ,p_stop_time       => TO_DATE(p_stop_time, 'YYYY/MM/DD')
       ,p_app_attributes  => l_app_attributes
       ,p_timecard        => l_temp_blocks
       ,p_messages        => p_messages
      );

      OPEN c_otm_retrieval_process(
        p_process_name => 'BEE Retrieval Process'
      );
      FETCH c_otm_retrieval_process INTO l_process_id;

      IF c_otm_retrieval_process%NOTFOUND
      THEN
        CLOSE c_otm_retrieval_process;
        FND_MESSAGE.SET_NAME('HXC','HXC_NO_RETRIEVAL_PROCESS');
        FND_MESSAGE.RAISE_ERROR;
      ELSE
        CLOSE c_otm_retrieval_process;
      END IF;

    ELSE
      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 150);
      END IF;

      -- find the corresponding dynamic template function for the
      -- specific application
      OPEN c_dyn_template_procedure(
        p_dyn_template_app => l_template_handle
      );

      FETCH c_dyn_template_procedure INTO l_template_procedure;

      IF c_dyn_template_procedure%NOTFOUND
      THEN
        CLOSE c_dyn_template_procedure;

        RETURN;
      END IF;

      CLOSE c_dyn_template_procedure;


      -- call the procedure to get the blocks info
  /*    l_dyn_template_sql := 'BEGIN '||fnd_global.newline
                   ||l_template_procedure    ||fnd_global.newline
                   ||'(p_resource_id => :1'  ||fnd_global.newline
                   ||',p_start_date  => :2'  ||fnd_global.newline
                   ||',p_stop_date   => :3'  ||fnd_global.newline
                   ||',p_attributes  => :4'  ||fnd_global.newline
                   ||',p_timecard    => :5'  ||fnd_global.newline
                   ||',p_messages    => :6);'||fnd_global.newline
                   ||'END;';

      EXECUTE IMMEDIATE l_dyn_template_sql
            using IN l_tp_resource_id, IN l_tp_start_time, IN
l_tp_stop_time, IN OUT l_attribute_string,IN OUT l_block_string,IN OUT
l_message_string;
*/
	get_dynamic_templates_info
		( l_template_procedure,
		  l_tp_resource_id,
		  l_tp_start_time,
		  l_tp_stop_time,
		  l_attribute_string,
		  l_block_string,
		  l_message_string,
		  p_messages);

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 160);
      END IF;

      OPEN c_retrieval_process(
        p_dyn_template_process => l_template_procedure
      );

      FETCH c_retrieval_process INTO l_process_id;
      IF c_retrieval_process%NOTFOUND
      THEN
        CLOSE c_retrieval_process;

        FND_MESSAGE.SET_NAME('HXC','HXC_NO_RETRIEVAL_PROCESS');
        FND_MESSAGE.RAISE_ERROR;
      ELSE
        CLOSE c_retrieval_process;
      END IF;

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 170);
      END IF;

      l_temp_blocks := hxc_deposit_wrapper_utilities.string_to_blocks(
                    p_block_string => l_block_string
                  );


      l_app_attributes := hxc_deposit_wrapper_utilities.string_to_attributes(
                          p_attribute_string => l_attribute_string
                        );


    END IF;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 180);
    END IF;

    --now we need to update the returned block info
    l_blocks := hxc_deposit_wrapper_utilities.blocks_to_array(p_blocks => l_temp_blocks);

    -- Added for bug 9530086
    IF (l_template_type = 'DYNAMIC' and l_template_handle = 'PA' and p_exclude_hours_template = 'Y') THEN
       IF l_blocks.count > 0 THEN
         FOR l_block_index IN 1..l_blocks.count LOOP
           IF l_blocks.exists(l_block_index) THEN
              IF l_blocks(l_block_index).SCOPE = 'DETAIL'
              THEN
                 l_blocks(l_block_index).MEASURE := null;
                 l_blocks(l_block_index).COMMENT_TEXT := null;
                 l_blocks(l_block_index).START_TIME := null;
                 l_blocks(l_block_index).STOP_TIME := null;
              END IF;
            END IF;
          END LOOP;
         END IF;
     END IF;


    update_blocks(
      p_resource_id     => p_resource_id
     ,p_approval_status => p_approval_status
     ,p_approval_style  => p_approval_style
     ,p_blocks          => l_blocks
     ,p_timecard_id     => l_timecard_id
     ,p_timecard_found  => l_timecard_found
    );


    IF NOT l_timecard_found
    THEN
      RETURN;
    END IF;

    IF g_debug THEN
    	hr_utility.trace('block count=' || l_blocks.count);
    	hr_utility.set_location ( g_package||l_proc, 190);
    END IF;

    -- update the returned apps attributes and convert them to block attributes
    l_attributes := app_to_block_attributes(
                      p_app_attributes  => l_app_attributes
                     ,p_process_id      => l_process_id
                     ,p_resource_id     => p_resource_id
                     ,p_timecard_id     => l_timecard_id
                     ,p_template_type   => l_template_handle
                    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 200);
    END IF;

    append_blocks(
      p_block_array     => p_block_array
     ,p_attribute_array => p_attribute_array
     ,p_new_blocks      => l_blocks
     ,p_new_attributes  => l_attributes
     ,p_overwrite       => p_overwrite
     ,p_start_time      => p_start_time
     ,p_stop_time       => p_stop_time
     ,p_resource_id     => p_resource_id
     ,p_resource_type   => p_resource_type
     ,p_template_code	=> p_template_code
     ,p_remove_redundant_entries => FALSE
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 210);
    END IF;

    p_message_string := l_message_string;
    RETURN;
  END IF;


  -- need to work out the last time card
  IF l_template_action = 'SYS' AND l_template_handle = 'LAST_TIMECARD'
  THEN
    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 220);
    END IF;

    OPEN c_last_timecard(
      p_resource_id    => TO_NUMBER(p_resource_id)
     ,p_resource_type  => p_resource_type
     ,p_start_time     => p_start_time
    );

    FETCH c_last_timecard INTO l_template_id;
    IF c_last_timecard%NOTFOUND
    THEN
      CLOSE c_last_timecard;


      RETURN;
    END IF;

    CLOSE c_last_timecard;

  END IF;
  --
  -- Check the display key setting in the current blocks
  -- This only matters if we are appending, not if overwriting
  -- Ultimately, when all timecards have the display key set
  -- we can remove this check
  --
  l_template_display_key := true;
  l_timecard_display_key := true;

  l_block_array_idx := p_block_array.first;
  l_found := false;
  Loop
     Exit when ((l_found) or (not p_block_array.exists(l_block_array_idx)));
     if(p_block_array(l_block_array_idx).scope = hxc_timecard.c_detail_scope) then
        l_found := true;
        if((p_block_array(l_block_array_idx).translation_display_key is null)
           OR
           (p_block_array(l_block_array_idx).translation_display_key ='')) then
           l_timecard_display_key := false;
        end if;
     end if;
     l_block_array_idx := p_block_array.next(l_block_array_idx);
  End Loop;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 230);
  END IF;

  -- we need to retrieve the template from time building blocks table
  IF l_template_action = 'STATIC'
  THEN
    l_template_id := TO_NUMBER(l_template_handle);
  END IF;
  --
  -- Get the blocks and attributes associated with the template.
  --
  hxc_block_collection_utils.get_template
     (p_template_id         => l_template_id,
      p_blocks              => l_blocks,
      p_attributes          => l_attributes,
      p_template_start_time => l_old_start_time,
      p_template_stop_time  => l_old_stop_time
      );

  IF l_blocks.count > 0 THEN
    -- we need to adjust data based on the IN parameters
    l_new_start_time := TO_DATE(p_start_time, 'YYYY/MM/DD');
    l_new_stop_time  := TO_DATE(p_stop_time, 'YYYY/MM/DD');
    --
    -- Using new routine, we know the first block is the top-level block
    -- which might be a timecard or a timecard-template.
    --
    l_blocks(1).START_TIME := fnd_date.date_to_canonical(l_new_start_time);
    -- joel asked for this stop time set like this!
    l_blocks(1).STOP_TIME := to_char(l_new_stop_time, 'YYYY/MM/DD') || ' 23:59:59';
    l_blocks(1).SCOPE := 'TIMECARD';

    FOR l_block_index IN 1..l_blocks.count LOOP
     IF l_blocks.exists(l_block_index) THEN
      l_blocks(l_block_index).DATE_FROM := fnd_date.date_to_canonical(SYSDATE);
      l_blocks(l_block_index).DATE_TO := fnd_date.date_to_canonical(hr_general.end_of_time);
      l_blocks(l_block_index).RESOURCE_ID := p_resource_id;
      l_blocks(l_block_index).RESOURCE_TYPE := p_resource_type;
      l_blocks(l_block_index).OBJECT_VERSION_NUMBER := 1;
      l_blocks(l_block_index).new := hxc_timecard.c_yes;

      if((l_blocks(l_block_index).translation_display_key is null)
       OR
         (l_blocks(l_block_index).translation_display_key = '')) then
         l_template_display_key := false;
      end if;

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 246);
      END IF;

      IF l_template_action = 'LAST_TIMECARD'
      THEN
        l_blocks(l_block_index).APPROVAL_STATUS := p_approval_status;
        l_blocks(l_block_index).COMMENT_TEXT := NULL;
      END IF;

      IF l_blocks(l_block_index).SCOPE = 'DAY'
      THEN
        l_difference := fnd_date.canonical_to_date(l_blocks(l_block_index).START_TIME)
                        - l_old_start_time;
        l_start_time := l_new_start_time + l_difference;

        IF l_start_time > l_new_stop_time
        THEN

         -- we need to remove the details also bug 3174721
          l_second_block_index := l_blocks.first;
          LOOP
            EXIT WHEN
             (NOT l_blocks.exists(l_second_block_index));
              IF l_blocks(l_second_block_index).PARENT_BUILDING_BLOCK_ID
                  = l_blocks(l_block_index).TIME_BUILDING_BLOCK_ID
              THEN
                remove_blocks
                    (p_blocks      => l_blocks,
                     p_attributes  => l_attributes,
                     p_block_index => l_second_block_index
                     );
            END IF;
            l_second_block_index := l_blocks.next(l_second_block_index);
           END LOOP;

          remove_blocks
              (p_blocks      => l_blocks,
               p_attributes  => l_attributes,
               p_block_index => l_block_index
               );

        ELSE
          l_blocks(l_block_index).START_TIME := fnd_date.date_to_canonical(l_start_time);
          l_blocks(l_block_index).STOP_TIME := TO_CHAR(l_start_time, 'YYYY/MM/DD')
                                             || ' 23:59:59';

          l_blocks(l_block_index).PARENT_IS_NEW := 'Y';
          l_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN := 1;

          --modify detail blocks
          FOR l_second_block_index IN 1..l_blocks.count LOOP
            IF l_blocks(l_second_block_index).PARENT_BUILDING_BLOCK_ID
               = l_blocks(l_block_index).TIME_BUILDING_BLOCK_ID
            THEN
              IF l_blocks(l_second_block_index).START_TIME IS NOT NULL
              THEN

                l_detail_start_date :=
                  fnd_date.canonical_to_date(l_blocks(l_second_block_index).START_TIME)
                        - l_old_start_time + l_new_start_time;
                l_blocks(l_second_block_index).START_TIME :=
                  TO_CHAR(l_detail_start_date, 'YYYY/MM/DD')
                  || TO_CHAR(
                     TO_DATE(l_blocks(l_second_block_index).START_TIME, 'YYYY/MM/DD HH24:MI:SS'),
                     ' HH24:MI:SS');

                l_detail_stop_date :=
                  fnd_date.canonical_to_date(l_blocks(l_second_block_index).STOP_TIME)
                        - l_old_start_time + l_new_start_time;

                l_blocks(l_second_block_index).STOP_TIME :=
                  TO_CHAR(l_detail_stop_date, 'YYYY/MM/DD')
                  || TO_CHAR(
                     TO_DATE(l_blocks(l_second_block_index).STOP_TIME, 'YYYY/MM/DD HH24:MI:SS'),
                    ' HH24:MI:SS');

              END IF;

              l_blocks(l_second_block_index).PARENT_IS_NEW := 'Y';
              l_blocks(l_second_block_index).PARENT_BUILDING_BLOCK_OVN := 1;
            END IF;
          END LOOP;

        END IF;
      ELSIF l_blocks(l_block_index).SCOPE = 'DETAIL' and p_exclude_hours_template = 'Y'
      THEN
         l_blocks(l_block_index).MEASURE := null;
         l_blocks(l_block_index).COMMENT_TEXT := null;
         l_blocks(l_block_index).START_TIME := null;
         l_blocks(l_block_index).STOP_TIME := null;
      END IF;

     END IF;
    END LOOP;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 250);
    END IF;

     if((l_blocks.COUNT > 0) AND (l_template_action = 'SYS' AND l_template_handle = 'LAST_TIMECARD'))
       then
	-- Check if the Zero hours preference is set
	l_zero_template := hxc_preference_evaluation.resource_preferences(
				 p_resource_id,
				 'TC_W_TMPLT_FCNLTY',
				 2 );

	l_clear_comment := hxc_preference_evaluation.resource_preferences(
				 p_resource_id,
				 'TC_W_TMPLT_FCNLTY',
				 3 );

-- added check for p_exclude_hours_template bug5955838

	if (nvl(l_zero_template,'N') ='Y'AND NVL(p_exclude_hours_template,'N') <> 'Y') then

	 modify_to_zero_hrs_template (
	    p_start_time      	=> p_start_time
	   ,p_stop_time       	=> p_stop_time
	   ,p_block_array     	=> l_blocks
	   ,p_attribute_array 	=> l_attributes
	   ,p_clear_comment     => nvl(l_clear_comment,'N')
	  );
	  if(nvl(p_overwrite,'N') = 'N') then -- Only in the case of Appending.
	      l_remove_redundant_entries :=TRUE;
	 end if;
	end if; -- (l_zero_template ='Y') then
       end if;

    append_blocks(
      p_block_array     => p_block_array
     ,p_attribute_array => p_attribute_array
     ,p_new_blocks      => l_blocks
     ,p_new_attributes  => l_attributes
     ,p_overwrite       => p_overwrite
     ,p_start_time      => p_start_time
     ,p_stop_time       => p_stop_time
     ,p_resource_id     => p_resource_id
     ,p_resource_type   => p_resource_type
     ,p_template_code   => p_template_code
     ,p_remove_redundant_entries =>l_remove_redundant_entries
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 260);
    END IF;
    --
    -- If the timecard, or the template are missing the display keys
    -- we must permit the timecard to dynamically allocate the row
    -- for the timecard entries.
    -- I.e. reset the display key.
    --
    if((NOT l_timecard_display_key) OR (NOT l_template_display_key)) then
       l_block_array_idx := p_block_array.first;
       Loop
          Exit when not p_block_array.exists(l_block_array_idx);
          p_block_array(l_block_array_idx).translation_display_key := '';
          l_block_array_idx := p_block_array.next(l_block_array_idx);
       End Loop;
    end if;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 270);
    END IF;

    p_message_string := NULL;

  END IF;


END get_blocks_from_template;


/*
PROCEDURE get_attributes(
  p_block_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_block_ovn  IN hxc_time_building_blocks.object_version_number%TYPE
 ,p_attributes IN OUT NOCOPY hxc_self_service_time_deposit.building_block_attribute_info
 ,p_review     IN VARCHAR2
)
IS
  l_attribute_index NUMBER;
  l_temp_attribute  hxc_self_service_time_deposit.attribute_info;

  CURSOR c_block_attributes(
    p_building_block_id IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
   ,p_ovn               IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  )
  IS
    select   a.time_attribute_id
            ,au.time_building_block_id
            ,bbit.bld_blk_info_type
            ,a.attribute_category
            ,a.attribute1
            ,a.attribute2
            ,a.attribute3
            ,a.attribute4
            ,a.attribute5
            ,a.attribute6
            ,a.attribute7
            ,a.attribute8
            ,a.attribute9
            ,a.attribute10
            ,a.attribute11
            ,a.attribute12
            ,a.attribute13
            ,a.attribute14
            ,a.attribute15
            ,a.attribute16
            ,a.attribute17
            ,a.attribute18
            ,a.attribute19
            ,a.attribute20
            ,a.attribute21
            ,a.attribute22
            ,a.attribute23
            ,a.attribute24
            ,a.attribute25
            ,a.attribute26
            ,a.attribute27
            ,a.attribute28
            ,a.attribute29
            ,a.attribute30
            ,a.bld_blk_info_type_id
            ,a.object_version_number
            ,'N' NEW
            ,'N' CHANGED
       from hxc_time_attributes a,
            hxc_time_attribute_usages au,
            hxc_bld_blk_info_types bbit
      where au.time_building_block_id = p_building_block_id
        and au.time_building_block_ovn = p_ovn
        and au.time_attribute_id = a.time_attribute_id
        and (not (a.attribute_category = 'SECURITY'))
        and a.bld_blk_info_type_id = bbit.bld_blk_info_type_id;


BEGIN
  IF p_attributes.count = 0
  THEN
    l_attribute_index := 1;
  ELSE
    l_attribute_index := p_attributes.last + 1;
  END IF;

  OPEN c_block_attributes(
      p_building_block_id => p_block_id
     ,p_ovn               => p_block_ovn
    );

  LOOP
    FETCH c_block_attributes INTO l_temp_attribute;
    EXIT WHEN c_block_attributes%NOTFOUND;

    IF p_review <> 'TIMECARD-REVIEW'
      AND l_temp_attribute.attribute_category = 'REASON'
    THEN
      NULL;
    ELSE
      p_attributes(l_attribute_index) := l_temp_attribute;

      l_attribute_index := l_attribute_index + 1;
    END IF;
  END LOOP;

  CLOSE c_block_attributes;
END get_attributes;
*/

PROCEDURE get_attributes(
  p_block_id   IN hxc_time_building_blocks.time_building_block_id%TYPE
 ,p_block_ovn  IN hxc_time_building_blocks.object_version_number%TYPE
 ,p_attributes IN OUT NOCOPY hxc_self_service_time_deposit.building_block_attribute_info
 ,p_review     IN VARCHAR2
 ,p_new_block_id IN hxc_time_building_blocks.time_building_block_id%TYPE DEFAULT NULL
)
IS
  l_attribute_index NUMBER;
  l_temp_attribute  hxc_self_service_time_deposit.attribute_info;

  CURSOR c_block_attributes(
    p_building_block_id IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
   ,p_ovn               IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  )
  IS
    select   a.time_attribute_id
            ,au.time_building_block_id
            ,bbit.bld_blk_info_type
            ,a.attribute_category
            ,a.attribute1
            ,a.attribute2
            ,a.attribute3
            ,a.attribute4
            ,a.attribute5
            ,a.attribute6
            ,a.attribute7
            ,a.attribute8
            ,a.attribute9
            ,a.attribute10
            ,a.attribute11
            ,a.attribute12
            ,a.attribute13
            ,a.attribute14
            ,a.attribute15
            ,a.attribute16
            ,a.attribute17
            ,a.attribute18
            ,a.attribute19
            ,a.attribute20
            ,a.attribute21
            ,a.attribute22
            ,a.attribute23
            ,a.attribute24
            ,a.attribute25
            ,a.attribute26
            ,a.attribute27
            ,a.attribute28
            ,a.attribute29
            ,a.attribute30
            ,a.bld_blk_info_type_id
            ,a.object_version_number
            ,'N' NEW
            ,'N' CHANGED
            ,'N' PROCESS
       from hxc_time_attributes a,
            hxc_time_attribute_usages au,
            hxc_bld_blk_info_types bbit
      where au.time_building_block_id = p_building_block_id
        and au.time_building_block_ovn = p_ovn
        and au.time_attribute_id = a.time_attribute_id
        and (not (a.attribute_category = 'SECURITY'))
        and a.bld_blk_info_type_id = bbit.bld_blk_info_type_id;


BEGIN
  IF p_attributes.count = 0
  THEN
    l_attribute_index := 1;
  ELSE
    l_attribute_index := p_attributes.last + 1;
  END IF;

  OPEN c_block_attributes(
      p_building_block_id => p_block_id
     ,p_ovn               => p_block_ovn
    );

  LOOP
    FETCH c_block_attributes INTO l_temp_attribute;
    EXIT WHEN c_block_attributes%NOTFOUND;

    IF p_review <> 'TIMECARD-REVIEW'
      AND l_temp_attribute.attribute_category = 'REASON'
    THEN
      NULL;
    ELSE
      p_attributes(l_attribute_index) := l_temp_attribute;

      IF p_new_block_id IS NOT NULL
      THEN
        p_attributes(l_attribute_index).building_block_id := p_new_block_id;

      END IF;

      l_attribute_index := l_attribute_index + 1;
    END IF;
  END LOOP;

  CLOSE c_block_attributes;
END get_attributes;





PROCEDURE translate_alias_timecards(
  p_resource_id     IN VARCHAR2
 ,p_start_time      IN VARCHAR2
 ,p_stop_time       IN VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
)
IS
  l_resource_id       VARCHAR2(50) := NULL;

  l_proc VARCHAR2(50);

  l_messages_table	HXC_MESSAGE_TABLE_TYPE;

BEGIN


  -- call translator alias package
  l_resource_id := p_resource_id;

  IF l_resource_id IS NULL
  THEN
    l_resource_id := p_block_array(1).resource_id;
  END IF;

  IF g_debug THEN
  	l_proc := 'translate_alias_timecards';
  	hr_utility.set_location ( g_package||l_proc, 20);
  END IF;

  HXC_ALIAS_TRANSLATOR.do_retrieval_translation(
    p_attributes	=> p_attribute_array
   ,p_blocks  	        => p_block_array
   ,p_start_time  	=> FND_DATE.CANONICAL_TO_DATE(p_start_time)
   ,p_stop_time   	=> FND_DATE.CANONICAL_TO_DATE(p_stop_time)
   ,p_resource_id 	=> l_resource_id
   ,p_messages		=> l_messages_table
  );

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 30);
  END IF;

END translate_alias_timecards;


--return a structure of timecard, day and details that

--corresponds to an application period

PROCEDURE get_application_period_blocks(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_review           IN     VARCHAR2
)
IS
  l_attributes        hxc_self_service_time_deposit.building_block_attribute_info;
  l_blocks            hxc_self_service_time_deposit.timecard_info;
  l_block_index       NUMBER;
  l_parent_id         hxc_time_building_blocks.time_building_block_id%TYPE;


  CURSOR c_day_blocks(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN VARCHAR2
   ,p_stop_time     IN VARCHAR2
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
          ,hxc_time_building_blocks tc
      where tbb1.date_to = hr_general.end_of_time
          and tbb1.resource_id = p_resource_id
          and tbb1.resource_type = p_resource_type
          and tbb1.scope = 'DAY'
          and tbb1.parent_building_block_id = tc.time_building_block_id
          and tbb1.parent_building_block_ovn = tc.object_version_number
          and tc.scope = 'TIMECARD'
          and tc.date_to = hr_general.end_of_time
          and to_char(tbb1.start_time,'YYYY/MM/DD') >= p_start_time
          and to_char(tbb1.start_time,'YYYY/MM/DD') <= p_stop_time
          and tbb1.date_to = hr_general.end_of_time
      order by tbb1.start_time asc;

  CURSOR c_detail_blocks(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN VARCHAR2
   ,p_stop_time     IN VARCHAR2
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
          ,hxc_time_building_blocks tc
          ,hxc_time_building_blocks days
      where tbb1.date_to = hr_general.end_of_time
          and tbb1.resource_id = p_resource_id
          and tbb1.resource_type = p_resource_type
          and tbb1.scope = 'DETAIL'
          and tbb1.parent_building_block_id = days.time_building_block_id
          and tbb1.parent_building_block_ovn = days.object_version_number
          and days.scope = 'DAY'
          and to_char(days.start_time,'YYYY/MM/DD') >= p_start_time
          and to_char(days.start_time,'YYYY/MM/DD') <= p_stop_time
          and days.date_to = hr_general.end_of_time
          and days.parent_building_block_id = tc.time_building_block_id
          and days.parent_building_block_ovn = tc.object_version_number
          and tc.date_to = hr_general.end_of_time
          and tc.scope = 'TIMECARD'
      order by tbb1.start_time asc;

  CURSOR c_timecard_block(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN VARCHAR2
   ,p_stop_time     IN VARCHAR2
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
      where tbb1.date_to = hr_general.end_of_time
        and tbb1.resource_id = p_resource_id
        and tbb1.resource_type = p_resource_type
        and tbb1.scope = 'TIMECARD'
        and to_char(tbb1.start_time,'YYYY/MM/DD') >= p_start_time
        and to_char(tbb1.start_time,'YYYY/MM/DD') <= p_stop_time;

BEGIN
   p_message_string := NULL;

   l_block_index := 1;

   --get a timecard block that includes the first day of the
   --application period, we need layout attributes associated
   --with this timecard

   OPEN c_timecard_block(
     p_resource_id => p_resource_id
    ,p_resource_type => p_resource_type
    ,p_start_time => p_start_time
    ,p_stop_time => p_stop_time
   );

   -- one of the related timecards has been deleted. This notification
   -- should have been cancelled. (this should not happen in the first place
   FETCH c_timecard_block INTO l_blocks(l_block_index);
   IF c_timecard_block%NOTFOUND
   THEN
     CLOSE c_timecard_block;

     RETURN;
   END IF;

   CLOSE c_timecard_block;

   l_blocks(l_block_index).start_time := to_date(p_start_time, 'YYYY/MM/DD');
   l_blocks(l_block_index).stop_time := to_date(p_stop_time, 'YYYY/MM/DD');
   l_parent_id := l_blocks(l_block_index).time_building_block_id;

   get_attributes(
     p_block_id   => l_blocks(l_block_index).time_building_block_id
    ,p_block_ovn  => l_blocks(l_block_index).object_version_number
    ,p_attributes => l_attributes
    ,p_review     => p_review
   );

   --now get all the day blocks
   OPEN c_day_blocks(
     p_resource_id => p_resource_id
    ,p_resource_type => p_resource_type
    ,p_start_time => p_start_time
    ,p_stop_time  => p_stop_time
   );

   l_block_index := l_block_index + 1;
   LOOP
     FETCH c_day_blocks INTO l_blocks(l_block_index);
     EXIT WHEN c_day_blocks%NOTFOUND;

     l_blocks(l_block_index).PARENT_BUILDING_BLOCK_ID := l_parent_id;

     get_attributes(
       p_block_id   => l_blocks(l_block_index).time_building_block_id
      ,p_block_ovn  => l_blocks(l_block_index).object_version_number
      ,p_attributes => l_attributes
      ,p_review     => p_review
     );

     l_block_index := l_block_index + 1;

   END LOOP;

   CLOSE c_day_blocks;

   OPEN c_detail_blocks(
     p_resource_id => p_resource_id
    ,p_resource_type => p_resource_type
    ,p_start_time => p_start_time
    ,p_stop_time  => p_stop_time
   );

   l_block_index := l_block_index + 1;
   LOOP
     FETCH c_detail_blocks INTO l_blocks(l_block_index);
     EXIT WHEN c_detail_blocks%NOTFOUND;


     get_attributes(
       p_block_id   => l_blocks(l_block_index).time_building_block_id
      ,p_block_ovn  => l_blocks(l_block_index).object_version_number
      ,p_attributes => l_attributes
      ,p_review     => p_review
     );

     l_block_index := l_block_index + 1;

   END LOOP;

   CLOSE c_detail_blocks;

   p_block_array := hxc_deposit_wrapper_utilities.blocks_to_array(
                      p_blocks => l_blocks
                    );
   p_attribute_array := hxc_deposit_wrapper_utilities.attributes_to_array(
                         p_attributes => l_attributes
                       );

   translate_alias_timecards(
     p_resource_id     => p_resource_id
    ,p_start_time      => p_start_time
    ,p_stop_time       => p_stop_time
    ,p_block_array     => p_block_array
    ,p_attribute_array => p_attribute_array
   );

END get_application_period_blocks;

PROCEDURE request_lock
            (p_resource_id      IN            VARCHAR2
            ,p_resource_type    IN            VARCHAR2
            ,p_start_time       IN            VARCHAR2
            ,p_stop_time        IN            VARCHAR2
            ,p_timecard_id      IN            NUMBER
            ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
            ,p_lock_success        OUT NOCOPY BOOLEAN
            ,p_lock_rowid       IN OUT NOCOPY ROWID
            ,p_timecard_action  in     VARCHAR2
            ) is

cursor c_find_timecard_ovn
         (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is
  select object_version_number
    from hxc_time_building_blocks
   where time_building_block_id = p_timecard_id
     and date_to = hr_general.end_of_time;

l_process_locker_type  varchar2(80) := hxc_lock_util.c_ss_timecard_action;
l_timecard_ovn hxc_time_building_blocks.object_version_number%type;

Begin

p_messages := HXC_MESSAGE_TABLE_TYPE();

if(p_timecard_id is not null) then
  open c_find_timecard_ovn(p_timecard_id);
  fetch c_find_timecard_ovn into l_timecard_ovn;
  close c_find_timecard_ovn;
else
  l_timecard_ovn := null;
end if;

if(
   (p_timecard_action = 'ApprovalDetail')
  OR
   (p_timecard_action = 'Detail')
  )  then
  l_process_locker_type := hxc_lock_util.c_ss_timecard_view;
end if;

--
-- Try obtaining a lock
--
  hxc_lock_api.request_lock
    (P_PROCESS_LOCKER_TYPE    => l_process_locker_type
    ,P_RESOURCE_ID            => p_resource_id
    ,P_START_TIME             => to_date(p_start_time,'YYYY/MM/DD')
    ,P_STOP_TIME              => to_date(p_stop_time,'YYYY/MM/DD')
    ,P_TIME_BUILDING_BLOCK_ID => p_timecard_id
    ,P_TIME_BUILDING_BLOCK_OVN=> l_timecard_ovn
    ,P_EXPIRATION_TIME        => 10
    ,P_ROW_LOCK_ID            => p_lock_rowid
    ,P_MESSAGES               => p_messages
    ,P_LOCKED_SUCCESS         => p_lock_success
    );

End request_lock;


FUNCTION get_name(
  p_person_id IN per_all_people_f.person_id%TYPE
)
RETURN VARCHAR2
IS
  CURSOR c_person_name(
    p_person_id per_all_people_f.person_id%TYPE
  )
  IS
    SELECT full_name
      FROM per_all_people_f ppf
     WHERE person_id = p_person_id
       AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

  l_person_name per_all_people_f.full_name%TYPE := NULL;

BEGIN
  IF p_person_id IS NULL
  THEN
    RETURN hr_general.decode_lookup('HXC_APPROVAL_MECHANISM','AUTO_APPROVE');
  END IF;

  OPEN c_person_name(p_person_id);
  FETCH c_person_name INTO l_person_name;
  CLOSE c_person_name;

  RETURN l_person_name;

END get_name;

FUNCTION get_timecard_comment(
  p_app_period_id IN hxc_time_building_blocks.time_building_block_id%TYPE
)
RETURN varchar2
IS
  CURSOR c_timecards(
    p_app_period_id IN hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
    SELECT timecards.comment_text
      FROM hxc_tc_ap_links links
          ,hxc_time_building_blocks timecards
     WHERE links.application_period_id = p_app_period_id
       AND links.timecard_id = timecards.time_building_block_id
       AND timecards.date_to = hr_general.end_of_time;

  l_comment hxc_time_building_blocks.comment_text%TYPE := '';
  l_combined_comment hxc_time_building_blocks.comment_text%TYPE := '';
  l_extra number := 0;
  l_comment_len number := 0;
BEGIN
  OPEN c_timecards(p_app_period_id);

  LOOP
    FETCH c_timecards INTO l_comment;
    EXIT WHEN c_timecards%NOTFOUND;

    IF l_combined_comment IS NOT NULL
      AND l_comment IS NOT NULL
      THEN
        l_comment_len := length(l_comment);
        l_extra := length(l_combined_comment) + l_comment_len - 2000;
        l_combined_comment := l_combined_comment
                           || substr(l_comment, 1, l_comment_len - l_extra);

    ELSE
      l_combined_comment := l_combined_comment || l_comment;
    END IF;

    IF length(l_combined_comment) = 2000
    THEN
      RETURN l_combined_comment;
    END IF;
  END LOOP;

  CLOSE c_timecards;

  RETURN l_combined_comment;
END get_timecard_comment;
--
-- New version, supporting the fragment page.
--
  Procedure get_app_period_blocks_by_id
     (p_app_period_id in     hxc_time_building_blocks.time_building_block_id%type,
      p_start_time    in     date,
      p_stop_time     in     date,
      p_blocks        in out nocopy hxc_block_table_type,
      p_attributes    in out nocopy hxc_attribute_table_type
      ) IS

  Begin

     hxc_block_collection_utils.get_application_period
        (p_app_period_id,
         p_start_time,
         p_stop_time,
         p_blocks,
         p_attributes
         );

     if(p_blocks is not null) then
        translate_alias_timecards
           (p_resource_id     => p_blocks(1).resource_id,
            p_start_time      => substrb(fnd_date.date_to_canonical(p_start_time),1,10),
            p_stop_time       => substrb(fnd_date.date_to_canonical(p_stop_time),1,10),
            p_block_array     => p_blocks,
            p_attribute_array => p_attributes
            );
     end if;

  End get_app_period_blocks_by_id;
--
-- Old version, called from?
--
PROCEDURE get_app_period_blocks_by_id(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_app_period_id    IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_return_timecard  IN     VARCHAR2 DEFAULT 'Y'
 ,p_mode             IN     VARCHAR2 DEFAULT c_for_approver
 ,p_notif_id         IN     VARCHAR2 DEFAULT null
)
IS
  l_attributes        hxc_self_service_time_deposit.building_block_attribute_info;
  l_blocks            hxc_self_service_time_deposit.timecard_info;
  l_app_period        hxc_self_service_time_deposit.building_block_info;
  l_block_index       NUMBER;
  l_parent_id         hxc_time_building_blocks.time_building_block_id%TYPE;
  l_parent_ovn        hxc_time_building_blocks.object_version_number%TYPE;
  l_timecard_id       hxc_time_building_blocks.time_building_block_id%TYPE;
  l_timecard_ovn      hxc_time_building_blocks.object_version_number%TYPE;
  l_app_status        VARCHAR2(500);
  l_app_recipient     fnd_application_tl.application_name%TYPE;
  l_approver_id       per_all_people_f.person_id%TYPE;
  l_attribute_index   NUMBER;
  l_dummy             varchar2(1);
  l_time_category_id  number;
  l_row_data          hxc_trans_display_key_utils.translation_row_used;
  l_same_app_time_period varchar2(1);
  CURSOR c_day_blocks(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN hxc_time_building_blocks.start_time%TYPE
   ,p_stop_time     IN hxc_time_building_blocks.stop_time%TYPE
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
          ,hxc_time_building_blocks tc
      where tbb1.date_to = hr_general.end_of_time
        and tbb1.resource_id = p_resource_id
        and tbb1.resource_type = p_resource_type
        and tbb1.scope = 'DAY'
        and tbb1.start_time >= p_start_time
        and tbb1.start_time <= p_stop_time
        and tbb1.parent_building_block_id = tc.time_building_block_id
        and tbb1.parent_building_block_ovn = tc.object_version_number
        and tc.scope = 'TIMECARD'
        and tc.date_to = hr_general.end_of_time
   order by tbb1.start_time asc;

  CURSOR c_app_period(
    p_app_period_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
      where tbb1.time_building_block_id = p_app_period_id
        and tbb1.date_to = hr_general.end_of_time;

  CURSOR c_timecard_block(
    p_resource_id   IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
   ,p_resource_type IN HXC_TIME_BUILDING_BLOCKS.RESOURCE_TYPE%TYPE
   ,p_start_time    IN HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE
   ,p_stop_time     IN HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE
  )
  IS
    select
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
      from hxc_time_building_blocks tbb1
      where tbb1.date_to = hr_general.end_of_time
        and tbb1.resource_id = p_resource_id
        and tbb1.resource_type = p_resource_type
        and tbb1.scope = 'TIMECARD'
        and p_start_time <= tbb1.stop_time
        and p_stop_time >= tbb1.start_time;

  CURSOR c_detail_blocks(
    p_app_period_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
  SELECT
       tbb1.TIME_BUILDING_BLOCK_ID
      ,tbb1.TYPE
      ,tbb1.MEASURE
      ,tbb1.UNIT_OF_MEASURE
      ,tbb1.START_TIME
      ,tbb1.STOP_TIME
      ,tbb1.PARENT_BUILDING_BLOCK_ID
      ,'N' PARENT_IS_NEW
      ,tbb1.SCOPE
      ,tbb1.OBJECT_VERSION_NUMBER
      ,tbb1.APPROVAL_STATUS
      ,tbb1.RESOURCE_ID
      ,tbb1.RESOURCE_TYPE
      ,tbb1.APPROVAL_STYLE_ID
      ,tbb1.DATE_FROM
      ,tbb1.DATE_TO
      ,tbb1.COMMENT_TEXT
      ,tbb1.PARENT_BUILDING_BLOCK_OVN
      ,'N' NEW
      ,'N' CHANGED
      ,'N' PROCESS
      ,tbb1.application_set_id
      ,tbb1.translation_display_key
  FROM hxc_ap_detail_links adlinks
      ,hxc_time_building_blocks tbb1
 WHERE adlinks.application_period_id = p_app_period_id
   AND adlinks.time_building_block_id = tbb1.time_building_block_id
   AND adlinks.time_building_block_ovn = tbb1.object_version_number
   AND tbb1.date_to = hr_general.end_of_time;

   CURSOR c_detail_blocks_sup(
         p_app_period_id hxc_time_building_blocks.time_building_block_id%TYPE,
         p_start_time date,
         p_stop_time date
       )
     IS
   SELECT
          details.TIME_BUILDING_BLOCK_ID
         ,details.TYPE
         ,details.MEASURE
         ,details.UNIT_OF_MEASURE
         ,details.START_TIME
         ,details.STOP_TIME
         ,details.PARENT_BUILDING_BLOCK_ID
         ,'N' PARENT_IS_NEW
         ,details.SCOPE
         ,details.OBJECT_VERSION_NUMBER
         ,details.APPROVAL_STATUS
         ,details.RESOURCE_ID
         ,details.RESOURCE_TYPE
         ,details.APPROVAL_STYLE_ID
         ,details.DATE_FROM
         ,details.DATE_TO
         ,details.COMMENT_TEXT
         ,details.PARENT_BUILDING_BLOCK_OVN
         ,'N' NEW
         ,'N' CHANGED
         ,'N' PROCESS
         ,details.application_set_id
         ,details.translation_display_key
 from hxc_time_building_blocks timecard,
      hxc_time_building_blocks details,
      hxc_time_building_blocks days,
      hxc_tc_ap_links hal
 where
     days.time_building_block_id = details.parent_building_block_id
     and days.object_version_number = details.parent_building_block_ovn
     and hal.APPLICATION_PERIOD_ID = p_app_period_id
     and hal.timecard_id = timecard.time_building_block_id
     and days.parent_building_block_id = timecard.time_building_block_id
     and days.parent_building_block_ovn = timecard.object_version_number
     and details.date_to = hr_general.end_of_time
     and days.start_time <= p_stop_time
     and days.stop_time >= p_start_time
    order by details.translation_display_key;


  CURSOR c_app_attribute(
    p_app_period_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
    SELECT hr_general.decode_lookup('HXC_APPROVAL_STATUS', apsum.approval_status)
          ,favtl.application_name
          ,apsum.approver_id
          ,apsum.time_category_id
      FROM hxc_app_period_summary apsum
          ,fnd_application_tl favtl
          ,hxc_time_recipients htr
     WHERE apsum.application_period_id = p_app_period_id
       AND favtl.application_id = htr.application_id
       AND htr.time_recipient_id = apsum.time_recipient_id
       AND favtl.language = userenv('LANG');

  CURSOR c_is_sup_notification(p_notif_id in wf_notifications.notification_id%TYPE)
  is
       select 'Y'
          from wf_notification_attributes wna,
          wf_notification_attributes wnb
          where wna.notification_id = wnb.notification_id
          and wna.notification_id = p_notif_id
          and wna.name = 'FYI_ACTION_CODE'
          and wna.text_value = hxc_app_comp_notifications_api.c_action_request_approval
          and wnb.name ='FYI_RECIPIENT_CODE'
          and wnb.text_value = hxc_app_comp_notifications_api.c_recipient_supervisor;

BEGIN



   p_message_string := NULL;

   OPEN c_app_period(
     p_app_period_id => p_app_period_id
   );

   FETCH c_app_period INTO l_app_period;

   IF c_app_period%NOTFOUND
   THEN
     RETURN;
   END IF;

   CLOSE c_app_period;


   --find a timecard that overlaps with this app period
   l_block_index := 1;

   OPEN c_timecard_block(
     p_resource_id   => p_resource_id
    ,p_resource_type => p_resource_type
    ,p_start_time    => l_app_period.start_time
    ,p_stop_time     => l_app_period.stop_time
   );



   FETCH c_timecard_block INTO l_blocks(l_block_index);
   IF c_timecard_block%NOTFOUND
   THEN
     CLOSE c_timecard_block;

     RETURN;
   END IF;

   CLOSE c_timecard_block;

   IF g_debug THEN
   	hr_utility.trace('found timecard');
   END IF;

   IF trunc(l_blocks(l_block_index).START_TIME) = trunc(l_app_period.start_time)
   	AND trunc(l_blocks(l_block_index).STOP_TIME) = trunc(l_app_period.stop_time) THEN

   	l_same_app_time_period := 'Y' ;
   ELSE
   	l_same_app_time_period := 'N' ;

   END IF;

   IF p_return_timecard = 'N'
   THEN
     l_blocks(l_block_index).scope := 'APPLICATION_PERIOD';
   END IF;


   get_attributes(
     p_block_id   => l_blocks(l_block_index).time_building_block_id
    ,p_block_ovn  => l_blocks(l_block_index).object_version_number
    ,p_attributes => l_attributes
    ,p_review     => p_review
    ,p_new_block_id => l_app_period.time_building_block_id
   );

   --add approval attribute
   OPEN c_app_attribute(p_app_period_id);
   FETCH c_app_attribute INTO l_app_status, l_app_recipient, l_approver_id,l_time_category_id;
   CLOSE c_app_attribute;

   IF l_attributes.count = 0
   THEN
     l_attribute_index := 1;
   ELSE
     l_attribute_index := l_attributes.last + 1;
   END IF;

   l_attributes(l_attribute_index).time_attribute_id := -2;
   l_attributes(l_attribute_index).building_block_id := p_app_period_id;
   l_attributes(l_attribute_index).attribute_category := 'APPROVAL';
   l_attributes(l_attribute_index).attribute1 := l_app_recipient;
   l_attributes(l_attribute_index).attribute3 := get_name(l_approver_id);
   l_attributes(l_attribute_index).attribute7 := l_app_status;
   --add approval attribute

   l_blocks(l_block_index).time_building_block_id := l_app_period.time_building_block_id;
   l_blocks(l_block_index).object_version_number := l_app_period.object_version_number;
   l_blocks(l_block_index).start_time := l_app_period.start_time;
   l_blocks(l_block_index).stop_time := l_app_period.stop_time;
   if(p_mode = c_for_approver) then
     l_blocks(l_block_index).comment_text := get_timecard_comment(p_app_period_id);
   else
     l_blocks(l_block_index).comment_text := l_app_period.comment_text;
   end if;
   l_blocks(l_block_index).approval_status := l_app_period.approval_status;


   --now get all the day blocks
   OPEN c_day_blocks(
     p_resource_id   => p_resource_id
    ,p_resource_type => p_resource_type
    ,p_start_time    => l_app_period.start_time
    ,p_stop_time     => l_app_period.stop_time
   );

   l_block_index := l_block_index + 1;
   LOOP
     FETCH c_day_blocks INTO l_blocks(l_block_index);
     EXIT WHEN c_day_blocks%NOTFOUND;


     l_blocks(l_block_index).PARENT_BUILDING_BLOCK_ID := l_app_period.time_building_block_id;
     l_blocks(l_block_index).PARENT_BUILDING_BLOCK_OVN :=  l_app_period.object_version_number;
     get_attributes(
       p_block_id   => l_blocks(l_block_index).time_building_block_id
      ,p_block_ovn  => l_blocks(l_block_index).object_version_number
      ,p_attributes => l_attributes
      ,p_review     => p_review
     );

     l_block_index := l_block_index + 1;
   END LOOP;

   CLOSE c_day_blocks;

--For the 'Notify supervisor on approval request' notification We need to show all the details
--associated with the application period.
   if p_notif_id is not null then
   	open c_is_sup_notification(p_notif_id);
   	fetch c_is_sup_notification into l_dummy;
   end if;
   --get detail blocks
   if p_notif_id is not null and c_is_sup_notification%found then
	 close c_is_sup_notification;
	   OPEN c_detail_blocks_sup(
	     p_app_period_id => p_app_period_id,
	     p_start_time => l_app_period.start_time,
	     p_stop_time => l_app_period.stop_time
	   );

	   LOOP
	     FETCH c_detail_blocks_sup INTO l_blocks(l_block_index);
	     EXIT WHEN c_detail_blocks_sup%NOTFOUND;

	     get_attributes(
	       p_block_id   => l_blocks(l_block_index).time_building_block_id
	      ,p_block_ovn  => l_blocks(l_block_index).object_version_number
	      ,p_attributes => l_attributes
	      ,p_review     => p_review
	     );

	     l_block_index := l_block_index + 1;
	   END LOOP;

	  CLOSE c_detail_blocks_sup;
   ELSE
	   OPEN c_detail_blocks(
	     p_app_period_id => p_app_period_id
	   );

	   LOOP
	     FETCH c_detail_blocks INTO l_blocks(l_block_index);
	     EXIT WHEN c_detail_blocks%NOTFOUND;

	     get_attributes(
	       p_block_id   => l_blocks(l_block_index).time_building_block_id
	      ,p_block_ovn  => l_blocks(l_block_index).object_version_number
	      ,p_attributes => l_attributes
	      ,p_review     => p_review
	     );

		----Bug 5565773
	     if l_time_category_id is not null  then
	             hxc_trans_display_key_utils.set_row_data
	                 (l_blocks(l_block_index).translation_display_key,
	                  l_row_data);
             end if;
	     l_block_index := l_block_index + 1;
	   END LOOP;

	   CLOSE c_detail_blocks;
  end if;

   p_block_array := hxc_deposit_wrapper_utilities.blocks_to_array(
                      p_blocks => l_blocks
                    );
   IF l_same_app_time_period = 'N' THEN

   	l_block_index:= p_block_array.first;
   	LOOP
   	  EXIT WHEN NOT p_block_array.exists(l_block_index);

   	  p_block_array(l_block_index).TRANSLATION_DISPLAY_KEY := null;
   	  l_block_index:= p_block_array.next(l_block_index);

   	END LOOP;
   END IF;
   --Bug 5565773

   if l_same_app_time_period = 'Y' AND HXC_TRANS_DISPLAY_KEY_UTILS.missing_rows(l_row_data) then
	 HXC_TRANS_DISPLAY_KEY_UTILS.remove_empty_rows(l_row_data,
					p_block_array);
   end if;
   p_attribute_array := hxc_deposit_wrapper_utilities.attributes_to_array(
                         p_attributes => l_attributes
                       );

   translate_alias_timecards(
     p_resource_id     => p_resource_id
    ,p_start_time      => to_char(l_app_period.start_time, 'YYYY/MM/DD')
    ,p_stop_time       => to_char(l_app_period.stop_time, 'YYYY/MM/DD')
    ,p_block_array     => p_block_array
    ,p_attribute_array => p_attribute_array
   );

END get_app_period_blocks_by_id;


FUNCTION is_app_period(
  p_block_id IN hxc_time_building_blocks.time_building_block_id%TYPE
)
RETURN BOOLEAN
IS

  CURSOR c_app_period(
    p_block_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
    SELECT 'Y'
      FROM hxc_app_period_summary
     WHERE application_period_id = p_block_id;

  l_result VARCHAR2(1) := NULL;
BEGIN

  OPEN c_app_period(p_block_id);
  FETCH c_app_period INTO l_result;
  CLOSE c_app_period;

  IF l_result IS NULL
  THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

END is_app_period;


PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 )
IS

BEGIN

fetch_blocks_and_attributes(
  p_resource_id       => p_resource_id
 ,p_resource_type     => p_resource_type
 ,p_start_time        => p_start_time
 ,p_stop_time         => p_stop_time
 ,p_timecard_id       => p_timecard_id
 ,p_template_code     => p_template_code
 ,p_approval_status   => p_approval_status
 ,p_create_template   => p_create_template
 ,p_block_array       => p_block_array
 ,p_attribute_array   => p_attribute_array
 ,p_messages          => p_messages
 ,p_message_string    => p_message_string
 ,p_overwrite         => p_overwrite
 ,p_review            => p_review
 ,p_lock_rowid        => p_lock_rowid
 ,p_timecard_action   => p_timecard_action
 ,p_exclude_hours_template => null
 );

END;


PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 ,p_exclude_hours_template in VARCHAR2
 )

 is

 BEGIN

 fetch_blocks_and_attributes(
   p_resource_id       => p_resource_id
  ,p_resource_type     => p_resource_type
  ,p_start_time        => p_start_time
  ,p_stop_time         => p_stop_time
  ,p_timecard_id       => p_timecard_id
  ,p_template_code     => p_template_code
  ,p_approval_status   => p_approval_status
  ,p_create_template   => p_create_template
  ,p_block_array       => p_block_array
  ,p_attribute_array   => p_attribute_array
  ,p_messages          => p_messages
  ,p_message_string    => p_message_string
  ,p_overwrite         => p_overwrite
  ,p_review            => p_review
  ,p_lock_rowid        => p_lock_rowid
  ,p_timecard_action   => p_timecard_action
  ,p_exclude_hours_template => p_exclude_hours_template
  ,p_notif_id    => null);

  END;

PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 ,p_exclude_hours_template in VARCHAR2
 ,p_notif_id         in     VARCHAR2)
IS
   cursor c_timecard_id
      (p_resource_id   in number,
       p_start_time    in date,
       p_stop_time     in date) is
   select timecard_id
     from hxc_timecard_summary
    where resource_id = p_resource_id
      and trunc(start_time) = trunc(p_start_time)
      and trunc(stop_time) = trunc(p_stop_time);


  l_blocks            hxc_self_service_time_deposit.timecard_info;
  l_attributes        hxc_self_service_time_deposit.building_block_attribute_info;
  l_block_id          hxc_time_building_blocks.time_building_block_id%TYPE;
  l_block_index       NUMBER := 1;
  l_attribute_index   NUMBER := 1;
  l_block_string      VARCHAR2(32767) := NULL;
  l_attribute_string  VARCHAR2(32767) := NULL;
  l_message_string    VARCHAR2(2000) := NULL;
  l_template_code     VARCHAR2(500);
  l_pref_template     VARCHAR2(2000);
  l_template_fcnlty   VARCHAR2(1);
  l_approval_style_id VARCHAR2(20) := NULL;
  l_resource_id       VARCHAR2(50) := NULL;
  l_lock_success      BOOLEAN      := FALSE;
  l_lock_rowid        ROWID;
  l_temp_block        HXC_BLOCK_TYPE;
  l_row_data          hxc_trans_display_key_utils.translation_row_used;
  l_missing_rows      boolean;
  l_timecard_id       hxc_timecard_summary.timecard_id%type;
  l_temp_attributes   hxc_attribute_table_type;
  i                   number;

  l_proc              VARCHAR2(50);

  l_resp_id	      NUMBER;
  l_resp_appl_id      NUMBER;
BEGIN
  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
  	l_proc := 'fetch_blocks_and_attributes';
  	hr_utility.set_location (g_package||l_proc, 20);
  END IF;

--if(p_timecard_action <> 'Template') then
if(p_timecard_action NOT IN ('Template','Export')) then
--
-- Try getting a lock for the period, or the timecard
--
   request_lock
            (p_resource_id   => p_resource_id
            ,p_resource_type => p_resource_type
            ,p_start_time    => p_start_time
            ,p_stop_time     => p_stop_time
            ,p_timecard_id   => p_timecard_id
            ,p_messages      => p_messages
            ,p_lock_success   => l_lock_success
            ,p_lock_rowid    => p_lock_rowid
            ,p_timecard_action => p_timecard_action
            );

else
  p_messages := hxc_message_table_type();
end if;

if(p_messages.count=0) then
  --
  -- Lock was sucessful, we can continue
  --

-- Commented for bug 8468802
-- Making this call at a later point
/*  IF p_resource_id IS NOT NULL
  THEN
hxc_preference_evaluation.get_tc_resp(p_resource_id, TO_DATE(p_start_time, 'YYYY/MM/DD'),TO_DATE(p_stop_time,'YYYY/MM/DD'),l_resp_id,l_resp_appl_id);
    l_approval_style_id := hxc_preference_evaluation.resource_preferences(
                             p_resource_id,
                            'TS_PER_APPROVAL_STYLE',
                             1,
                             l_resp_id
                           );
  END IF;*/

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 20);
  END IF;

  IF p_timecard_id IS NOT NULL
    AND is_app_period(TO_NUMBER(p_timecard_id))
  THEN
    get_app_period_blocks_by_id(
      p_resource_id      => p_resource_id
     ,p_resource_type    => p_resource_type
     ,p_app_period_id    => p_timecard_id
     ,p_block_array      => p_block_array
     ,p_attribute_array  => p_attribute_array
     ,p_message_string   => l_message_string
     ,p_review           => p_review
     ,p_notif_id         => p_notif_id);

    p_message_string := l_message_string;

    RETURN;

  END IF;

  -- Moved this call to this place for bug 8468802
  IF p_resource_id IS NOT NULL
  THEN
hxc_preference_evaluation.get_tc_resp(p_resource_id, TO_DATE(p_start_time, 'YYYY/MM/DD'),TO_DATE(p_stop_time,'YYYY/MM/DD'),l_resp_id,l_resp_appl_id);
    l_approval_style_id := hxc_preference_evaluation.resource_preferences(
                             p_resource_id,
                            'TS_PER_APPROVAL_STYLE',
                             1,
                             l_resp_id
                           );
  END IF;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 28);
  END IF;


  --(1) First check if we need to apply a template
  IF p_template_code IS NOT NULL
  THEN
    get_blocks_from_template(
      p_resource_id      => p_resource_id
     ,p_resource_type    => p_resource_type
     ,p_start_time       => p_start_time
     ,p_stop_time        => p_stop_time
     ,p_template_code    => p_template_code
     ,p_approval_status  => p_approval_status
     ,p_approval_style   => l_approval_style_id
     ,p_block_array      => p_block_array
     ,p_attribute_array  => p_attribute_array
     ,p_message_string   => l_message_string
     ,p_overwrite        => p_overwrite
     ,p_exclude_hours_template => p_exclude_hours_template    -- pass the new param
     ,p_messages         => p_messages
    );

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 30);
    END IF;

    p_message_string := l_message_string;

-- v115.58 kSethi
    -- Adding new check to verify all DAYS are present
    -- 115.60 ARundell
    -- Added and clause.  We should only call this check
    -- if there are some blocks to check!
    -- 115.86 mbhammar
    -- append blocks would take care of chk_all_days_in_block for p_overwrite = 'Y'
    /*
	IF ((p_overwrite = 'Y') AND (p_block_array.COUNT > 0))
	then

	chk_all_days_in_block(
	      p_resource_id      => p_resource_id
	     ,p_resource_type    => p_resource_type
	     ,p_start_time       => p_start_time
	     ,p_stop_time        => p_stop_time
	     ,p_template_code    => p_template_code
	     ,p_block_array      => p_block_array
	    );
	end if;
    */

    RETURN;
  END IF;

  --(2)if this flag is set to 'Y', create an empty template from scratch
  --This was built at Joel's request, may not be in use
  IF p_create_template = 'Y'
  THEN
    RETURN;
  END IF;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 40);

  	hr_utility.trace(' p_resource_id=' || p_resource_id);
  	hr_utility.trace('p_resource_type=' || p_resource_type);
  	hr_utility.trace('p_start_time=' || p_start_time);
  	hr_utility.trace('p_stop_time=' || p_stop_time);
  	hr_utility.trace('p_timecard_id=' || p_timecard_id);
  END IF;

  --(3)retrieve an existing timecard
  --   Make sure we replace the display key
  --   if possible.
  --
  l_missing_rows := true;
  if(p_timecard_id is null) then
     open c_timecard_id
        (p_resource_id,
         to_date(p_start_time,'YYYY/MM/DD'),
         to_date(p_stop_time,'YYYY/MM/DD')
         );
     fetch c_timecard_id into l_timecard_id;
     close c_timecard_id;
  else
     l_timecard_id := p_timecard_id;
  end if;

  if(p_attribute_array is null) then
     l_temp_attributes := hxc_attribute_table_type();
     p_attribute_array := hxc_attribute_table_type();
  else
     l_temp_attributes := p_attribute_array;
  end if;

  hxc_block_collection_utils.get_timecard
    (p_timecard_id => l_timecard_id,
     p_blocks => p_block_array,
     p_attributes => l_temp_attributes,
     p_row_data => l_row_data,
     p_missing_rows => l_missing_rows
     );

  if(l_temp_attributes is not null) then
     i := l_temp_attributes.first;
     Loop
        Exit when not l_temp_attributes.exists(i);
        if(l_temp_attributes(i).attribute_category in ('SECURITY','REASON')) then
           -- Do not send these attributes back to the middle tier
           null;
        else
           p_attribute_array.extend;
           p_attribute_array(p_attribute_array.last) := l_temp_attributes(i);
        end if;
        i := l_temp_attributes.next(i);
     End Loop;
  end if;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 50);
  END IF;

  -- if there is an existing timecard, return the info in string
  IF p_block_array is not null THEN

     if (l_missing_rows) then
        hxc_trans_display_key_utils.remove_empty_rows
           (p_row_data => l_row_data,
            p_blocks   => p_block_array
            );
     end if;

     IF g_debug THEN
     	hr_utility.set_location ( g_package||l_proc, 60);
     END IF;

    -- call translator alias package
    translate_alias_timecards(
      p_resource_id     => p_resource_id
     ,p_start_time      => p_start_time
     ,p_stop_time       => p_stop_time
     ,p_block_array     => p_block_array
     ,p_attribute_array => p_attribute_array
    );

    if(p_review = 'TIMECARD-TEMPLATE_DUPLICATE') THEN
	   hxc_block_attribute_update.replace_ids
	       (p_blocks => p_block_array
	       ,p_attributes => p_attribute_array,
	       p_duplicate_template => TRUE
           );
	   --Only in case of duplicate mode, we replace the resourceids if they dont match.
	   --((i.e) if an administrator tries to duplicate a template created by someone else.)
	   HXC_DEPOSIT_WRAPPER_UTILITIES.replace_resource_id(p_block_array,p_resource_id);
    END IF;

    p_message_string  := NULL;
    RETURN;
  ELSE
    p_block_array := hxc_block_table_type();
    p_attribute_array := hxc_attribute_table_type();
  END IF;


  IF g_debug THEN
  	hr_utility.trace('app period jxtan');
  END IF;
  --(4) there is no existing timecard, check if this period
  -- corresponds to an application period
  -- this part is here so that the url we created for
  -- workflow notification before ELA will still work

    get_application_period_blocks(
      p_resource_id      => p_resource_id
     ,p_resource_type    => p_resource_type
     ,p_start_time       => p_start_time
     ,p_stop_time        => p_stop_time
     ,p_block_array      => p_block_array
     ,p_attribute_array  => p_attribute_array
     ,p_message_string   => l_message_string
     ,p_review           => p_review
    );


  IF p_block_array.count > 0
  THEN
    p_message_string := l_message_string;

    RETURN;
  END IF;



  --(5) if there is no existing timecard and no application
  -- period for this time period, check default templates
  IF (p_resource_id IS NOT NULL
      AND p_resource_type IS NOT NULL
      AND p_start_time IS NOT NULL
      AND p_stop_time  IS NOT NULL
      AND p_timecard_id IS NULL
     )
  THEN

    l_template_fcnlty := hxc_preference_evaluation.resource_preferences(
                           p_resource_id,
                           'TC_W_TMPLT_FCNLTY',
                           1,
                           l_resp_id
                         );
    -- return NULL if this person doesn't have template functionality
    IF l_template_fcnlty <> 'Y'
    THEN
      p_message_string := NULL;

      -- OTL- ABS Integration

      hxc_retrieve_absences.add_absence_types ( p_person_id         => p_resource_id,
                                                p_start_date  	     => TO_DATE(p_start_time,'yyyy/mm/dd'),
                                                p_end_date    	     => TO_DATE(p_stop_time,'yyyy/mm/dd'),
                                                p_approval_style_id =>	l_approval_style_id,
                                                p_lock_rowid        =>	p_lock_rowid,
                                                p_block_array 	     =>	p_block_array,
                                                p_attribute_array   =>	p_attribute_array );

      p_messages := hxc_retrieve_absences.g_messages;
      hr_utility.trace('ABS Message count = '||p_messages.count);
      p_message_string := hxc_retrieve_absences.g_message_string;
      IF p_messages.COUNT > 0
      THEN
         IF g_debug
         THEN
         for i in p_messages.first..p_messages.last
         loop
            hr_utility.trace('ABS : message_name '||p_messages(i).message_name);
            hr_utility.trace('ABS : message_level '||p_messages(i).message_level);
         END LOOP;
         END IF;
      END IF;

      RETURN;
    END IF;

    -- this user has template functionality, thus
    -- check template_code or pref setting for user or admin default
    l_template_code := p_template_code;
    IF l_template_code IS NULL
    THEN
      -- we need to check preference to get the template associated to
      -- this user
      l_template_code := get_pref_template(
                           p_resource_id   => TO_NUMBER(p_resource_id)
                         );
    END IF;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 100);
    END IF;

    IF l_template_code IS NOT NULL
    THEN

      -- Bug 8854684
      -- Added the below condition to restrict
      -- Default template in case the action is Import of timecard
      -- from a spreadsheet.
      IF p_timecard_action <> 'CreateImportTC'
      THEN


         get_blocks_from_template(
           p_resource_id      => p_resource_id
          ,p_resource_type    => p_resource_type
          ,p_start_time       => p_start_time
          ,p_stop_time        => p_stop_time
          ,p_template_code    => l_template_code
          ,p_approval_status  => p_approval_status
          ,p_approval_style   => l_approval_style_id
          ,p_block_array      => p_block_array
          ,p_attribute_array  => p_attribute_array
          ,p_message_string   => l_message_string
          ,p_messages         => p_messages
         );

         IF g_debug THEN
         	hr_utility.set_location ( g_package||l_proc, 110);
         END IF;

         p_message_string := l_message_string;

   -- v115.58 kSethi
	-- Adding new check to verify all DAYS are present
	-- Note: here we don't need to check for p_overwrite 'coz the above call
	-- to get_blocks_from_templates does not pass any p_overwrite, in which case
         -- it is always taken as 'Y'
         -- 115.60 ARundell
         -- Only check the blocks if there are some to return.
         IF(p_block_array.COUNT>0) then

	chk_all_days_in_block(
	      p_resource_id      => p_resource_id
	     ,p_resource_type    => p_resource_type
	     ,p_start_time       => p_start_time
	     ,p_stop_time        => p_stop_time
	     ,p_template_code    => p_template_code
	     ,p_block_array      => p_block_array
	    );

         END IF;
      END IF;

    END IF; -- l_template_code IS NOT NULL

      -- OTL - ABS Integration
      hxc_retrieve_absences.add_absence_types ( p_person_id         => p_resource_id,
                                                p_start_date  	     => TO_DATE(p_start_time,'yyyy/mm/dd'),
                                                p_end_date    	     => TO_DATE(p_stop_time,'yyyy/mm/dd'),
                                                p_approval_style_id =>	l_approval_style_id,
                                                p_lock_rowid        =>	p_lock_rowid,
                                                p_block_array 	     =>	p_block_array,
                                                p_attribute_array   =>	p_attribute_array );
      p_messages := hxc_retrieve_absences.g_messages;
      hr_utility.trace('ABS Message count2 = '||p_messages.count);

      IF p_messages.COUNT > 0
      THEN
         IF g_debug
         THEN
         for i in p_messages.first..p_messages.last
         loop
            hr_utility.trace('ABS : message_name '||p_messages(i).message_name);
            hr_utility.trace('ABS : message_level '||p_messages(i).message_level);
         END LOOP;
         END IF;
      END IF;

      p_message_string := hxc_retrieve_absences.g_message_string;


      RETURN;


  END IF;

end if; -- was this a sucessful lock?

END fetch_blocks_and_attributes;


PROCEDURE add_block_attributes(
  p_final_block_array     IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_final_attribute_array IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_new_block_array       IN HXC_BLOCK_TABLE_TYPE
 ,p_new_attribute_array   IN HXC_ATTRIBUTE_TABLE_TYPE
 ,p_start_att_id          IN NUMBER
)
IS
  l_final_index NUMBER;
  l_new_index   NUMBER;
  l_start_att_id NUMBER := p_start_att_id;
BEGIN
  l_final_index := NVL(p_final_block_array.last, 0);
  l_new_index := p_new_block_array.first;

  LOOP
    EXIT WHEN NOT p_new_block_array.exists(l_new_index);

    p_final_block_array.extend;
    l_final_index := l_final_index + 1;
    p_final_block_array(l_final_index) := p_new_block_array(l_new_index);

    l_new_index := p_new_block_array.next(l_new_index);
  END LOOP;

  l_final_index := NVL(p_final_attribute_array.last, 0);
  l_new_index := p_new_attribute_array.first;

  LOOP
    EXIT WHEN NOT p_new_attribute_array.exists(l_new_index);

    p_final_attribute_array.extend;
    l_final_index := l_final_index + 1;
    p_final_attribute_array(l_final_index) := p_new_attribute_array(l_new_index);
    p_final_attribute_array(l_final_index).time_attribute_id := l_start_att_id;
    l_start_att_id := l_start_att_id - 1;

    l_new_index := p_new_attribute_array.next(l_new_index);
  END LOOP;

END add_block_attributes;


PROCEDURE fetch_appl_periods(
  p_resource_id      IN VARCHAR2
 ,p_resource_type    IN VARCHAR2
 ,p_timecard_id      IN VARCHAR2
 ,p_block_array     OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_message_string  OUT NOCOPY VARCHAR2
 )
IS

  CURSOR c_app_periods(
    p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE
  )
  IS
    SELECT tal.application_period_id,
           ts.start_time,
           ts.stop_time
      FROM hxc_tc_ap_links tal, hxc_timecard_summary ts
     WHERE ts.timecard_id = p_timecard_id
       and ts.timecard_id = tal.timecard_id;

  l_app_period_id   hxc_time_building_blocks.time_building_block_id%TYPE;
  l_start_time      hxc_timecard_summary.start_time%type;
  l_stop_time       hxc_timecard_summary.stop_time%type;
  l_block_array     HXC_BLOCK_TABLE_TYPE;
  l_attribute_array HXC_ATTRIBUTE_TABLE_TYPE;
  l_message_string  VARCHAR(2000) := NULL;
  l_count           NUMBER;
  l_start_block_id  NUMBER;
  l_start_att_id    NUMBER;
BEGIN
  p_block_array := HXC_BLOCK_TABLE_TYPE();
  p_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();

  l_block_array := HXC_BLOCK_TABLE_TYPE();
  l_attribute_array := HXC_ATTRIBUTE_TABLE_TYPE();

  l_count := 0;
  l_start_block_id := -2;
  l_start_att_id := -2;

  OPEN c_app_periods(p_timecard_id);

  LOOP
    FETCH c_app_periods INTO l_app_period_id, l_start_time, l_stop_time;
    EXIT WHEN c_app_periods%NOTFOUND;

    get_app_period_blocks_by_id
       (l_app_period_id,
        l_start_time,
        l_stop_time,
        l_block_array,
        l_attribute_array
        );

    if l_count > 0 then
      assign_block_ids
          (p_start_id   => l_start_block_id,
           p_blocks     => l_block_array,
           p_attributes => l_attribute_array
           );

      l_start_block_id := l_start_block_id - l_block_array.count;
      l_start_att_id := l_start_att_id - l_attribute_array.count;

   end if;

    add_block_attributes
      (p_final_block_array     => p_block_array,
       p_final_attribute_array => p_attribute_array,
       p_new_block_array       => l_block_array,
       p_new_attribute_array   => l_attribute_array,
       p_start_att_id          => l_start_att_id
       );

    l_count := l_count + 1;

 END LOOP;

 CLOSE c_app_periods;

END fetch_appl_periods;

PROCEDURE check_blocks_from_template(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
)
IS

  l_template_handle    VARCHAR2(500) := '';
  l_template_action    VARCHAR2(20) :='';
  l_temp_blocks        hxc_self_service_time_deposit.timecard_info;
  l_blocks             HXC_BLOCK_TABLE_TYPE;
  l_attributes         HXC_ATTRIBUTE_TABLE_TYPE;
  l_temp_attributes    hxc_self_service_time_deposit.building_block_attribute_info;
  l_app_attributes     hxc_self_service_time_deposit.app_attributes_info;
  l_block_string       VARCHAR2(32767) := '';
  l_attribute_string   VARCHAR2(32767) := '';
  l_message_string     VARCHAR2(32767) := '';
  l_block_index        NUMBER := 1;
  l_attribute_index    NUMBER := 1;
  l_attribute_count    NUMBER;
  l_detail_start_date  DATE;
  l_detail_stop_date   DATE;

  l_template_procedure HXC_TIME_RECIPIENTS.APPL_DYNAMIC_TEMPLATE_PROCESS%TYPE;

  l_process_id         HXC_RETRIEVAL_PROCESSES.RETRIEVAL_PROCESS_ID%TYPE;
  l_tp_resource_id     NUMBER := TO_NUMBER(p_resource_id);
  l_tp_start_time      DATE := TO_DATE(p_start_time, 'YYYY/MM/DD');
  l_tp_stop_time       DATE := TO_DATE(p_stop_time, 'YYYY/MM/DD');
  l_timecard_id        hxc_time_building_blocks.time_building_block_id%TYPE;
  l_block_count        NUMBER;
  l_new_stop_time      DATE;
  l_old_start_time     DATE;
  l_old_stop_time      DATE;
  l_proc               VARCHAR2(70);

  CURSOR c_dyn_template_procedure(
    p_dyn_template_app IN VARCHAR2
  )
  IS
    select htr.appl_dynamic_template_process
      from hxc_time_recipients htr,
           fnd_application fa
     where fa.application_short_name = p_dyn_template_app
       and htr.application_id = fa.application_id;

  CURSOR c_otm_retrieval_process(
    p_process_name IN hxc_retrieval_processes.NAME%TYPE
  )
  IS
    SELECT retrieval_process_id
      FROM hxc_retrieval_processes
     WHERE name = p_process_name;

  CURSOR c_retrieval_process(
    p_dyn_template_process IN hxc_time_recipients.appl_dynamic_template_process%TYPE
  )
  IS
    SELECT hrp.retrieval_process_id
      FROM hxc_retrieval_processes hrp,
           hxc_time_recipients htr
     WHERE htr.appl_dynamic_template_process = p_dyn_template_process
       AND htr.time_recipient_id = hrp.time_recipient_id;

BEGIN

  g_debug := hr_utility.debug_enabled;

  get_template_info(
    p_template_code   => p_template_code
   ,p_template_handle => l_template_handle
   ,p_template_action => l_template_action
  );

  IF g_debug THEN
  	l_proc := 'get_blocks_from_template';
  	hr_utility.set_location ( g_package||l_template_action, 130);
  END IF;


  IF l_template_action = 'APP'
    OR (l_template_action = 'SYS' AND l_template_handle = 'WORK_SCHEDULE')
  THEN

    -- for OTM work schedule
    IF l_template_handle = 'WORK_SCHEDULE'
    THEN

      IF g_debug THEN
      	hr_utility.set_location ( g_package||l_proc, 140);
      END IF;

      HXT_TIMECARD_INFO.GENERATE_TIME(
        p_resource_id     => TO_NUMBER(p_resource_id)
       ,p_start_time      => TO_DATE(p_start_time, 'YYYY/MM/DD')
       ,p_stop_time       => TO_DATE(p_stop_time, 'YYYY/MM/DD')
       ,p_app_attributes  => l_app_attributes
       ,p_timecard        => l_temp_blocks
       ,p_messages        => p_messages
      );

      OPEN c_otm_retrieval_process(
        p_process_name => 'BEE Retrieval Process'
      );
      FETCH c_otm_retrieval_process INTO l_process_id;

      IF c_otm_retrieval_process%NOTFOUND
      THEN
        CLOSE c_otm_retrieval_process;
        FND_MESSAGE.SET_NAME('HXC','HXC_NO_RETRIEVAL_PROCESS');
        FND_MESSAGE.RAISE_ERROR;
      ELSE
        CLOSE c_otm_retrieval_process;
      END IF;

    ELSE
      -- find the corresponding dynamic template function for the
      -- specific application
      OPEN c_dyn_template_procedure(
        p_dyn_template_app => l_template_handle
      );

      FETCH c_dyn_template_procedure INTO l_template_procedure;

      IF g_debug THEN
      	hr_utility.set_location ( 'PJRM=='||l_template_procedure, 150);
      END IF;

      IF c_dyn_template_procedure%NOTFOUND
      THEN
        CLOSE c_dyn_template_procedure;

        RETURN;
      END IF;

      CLOSE c_dyn_template_procedure;

IF g_debug THEN
	hr_utility.set_location ( 'calling  get_dynamic_templates_info==', 160);
END IF;
	get_dynamic_templates_info
		( l_template_procedure,
		  l_tp_resource_id,
		  l_tp_start_time,
		  l_tp_stop_time,
		  l_attribute_string,
		  l_block_string,
		  l_message_string,
		  p_messages);

      IF g_debug THEN
      	hr_utility.set_location ( 'completed get_dynamic_templates_info=='||p_messages.count, 170);
      END IF;

      OPEN c_retrieval_process(
        p_dyn_template_process => l_template_procedure
      );

      FETCH c_retrieval_process INTO l_process_id;
      IF c_retrieval_process%NOTFOUND
      THEN
        CLOSE c_retrieval_process;

        FND_MESSAGE.SET_NAME('HXC','HXC_NO_RETRIEVAL_PROCESS');
        FND_MESSAGE.RAISE_ERROR;
      ELSE
        CLOSE c_retrieval_process;
      END IF;

      l_temp_blocks := hxc_deposit_wrapper_utilities.string_to_blocks(
                    p_block_string => l_block_string
                  );
      l_app_attributes := hxc_deposit_wrapper_utilities.string_to_attributes(
                          p_attribute_string => l_attribute_string
                        );
   END IF;
     RETURN;
  END IF;

  -- if there is an existing template, adjust the data
  l_block_count := l_temp_blocks.count;
  l_attribute_count := l_temp_attributes.count;

  IF l_block_count < 0
  THEN
	  hxc_timecard_message_helper.addErrorToCollection
  	    (p_messages
  	    ,'HXC_INVALID_DYNAMIC_TEMPL1'
  	    ,hxc_timecard.c_error
  	    ,null
  	    ,null
  	    ,hxc_timecard.c_hxc
  	    ,null
  	    ,null
  	    ,null
  	    ,null
	    );
  END IF;


END check_blocks_from_template;


FUNCTION get_timecard_transferred_to(f_timecard_id HXC_TIMECARD_SUMMARY.TIMECARD_ID%TYPE,
					f_timecard_ovn HXC_TIMECARD_SUMMARY.TIMECARD_OVN%TYPE) RETURN varchar2
is

CURSOR c_get_latest_timecard_details(l_timecard_id hxc_timecard_summary.timecard_id%TYPE,
l_timecard_ovn hxc_timecard_summary.timecard_ovn%TYPE) IS
SELECT /*+ ordered */
  lat.time_building_block_id,
  lat.object_version_number
FROM hxc_timecard_summary sum,
  hxc_time_building_blocks day,
  hxc_time_building_blocks det,
  hxc_latest_details lat
WHERE sum.timecard_id = l_timecard_id
 AND sum.timecard_ovn = l_timecard_ovn
 AND day.parent_building_block_id = sum.timecard_id
 AND day.parent_building_block_ovn = sum.timecard_ovn
 AND det.parent_building_block_id = day.time_building_block_id
 AND det.parent_building_block_ovn = day.object_version_number
 AND(det.measure IS NOT NULL OR(det.start_time IS NOT NULL AND det.stop_time IS NOT NULL))
 AND lat.time_building_block_id = det.time_building_block_id ;


CURSOR c_get_transaction_id(l_bb_id hxc_transaction_details.time_building_block_id%TYPE,
l_bb_ovn hxc_transaction_details.time_building_block_ovn%TYPE) IS
SELECT ht.transaction_id,
  ht.transaction_process_id
FROM hxc_transaction_details htd,
  hxc_transactions ht
WHERE htd.transaction_id = ht.transaction_id
 AND ht.type = 'RETRIEVAL'
 AND ht.status = 'SUCCESS'
 AND htd.status = 'SUCCESS'
 AND htd.time_building_block_id = l_bb_id
 AND htd.time_building_block_ovn = l_bb_ovn;


--------------------------------------------------------------------------

l_timecard_id  hxc_timecard_summary.timecard_id%TYPE;
l_timecard_ovn hxc_timecard_summary.timecard_ovn%TYPE;
l_resource_id hxc_timecard_summary.resource_id%TYPE;
l_start_time hxc_timecard_summary.start_time%TYPE;


TYPE building_blocks_tab IS TABLE OF NUMBER;

bb_id_tab 			building_blocks_tab;
bb_ovn_tab 			building_blocks_tab;
l_transaction_id_tab 		building_blocks_tab;
l_transaction_process_id_tab	building_blocks_tab;

l_index NUMBER;
l_transfer_to VARCHAR2(400) := 'None';
l_time_recipient_name hxc_application_set_comps_v.time_recipient_name%TYPE;

-----------------------------------------------------------------------------

BEGIN

  l_timecard_id  := f_timecard_id;
  l_timecard_ovn := f_timecard_ovn;


  ----------------------------- get latest timecard details------------------------------------------


  OPEN c_get_latest_timecard_details(l_timecard_id,l_timecard_ovn);
  FETCH c_get_latest_timecard_details bulk collect
  INTO bb_id_tab,
    bb_ovn_tab;
  CLOSE c_get_latest_timecard_details;

  hr_utility.trace('Detail Building Blocks Count :' || bb_id_tab.COUNT);



------------------------------ check whether data has transfer or not------------------------------


  l_index := bb_id_tab.FIRST;
  LOOP
    EXIT
  WHEN NOT bb_id_tab.EXISTS(l_index);

  hr_utility.trace(bb_id_tab(l_index) || '-' || bb_ovn_tab(l_index));

  OPEN c_get_transaction_id(bb_id_tab(l_index),   bb_ovn_tab(l_index));
      FETCH c_get_transaction_id bulk collect
      INTO l_transaction_id_tab,l_transaction_process_id_tab;
  CLOSE c_get_transaction_id;

  IF l_transaction_id_tab IS NULL THEN
    l_transfer_to := 'None';
    EXIT;
  END IF;

  l_index := bb_id_tab.NEXT(l_index);

  END LOOP;




--------------------------------- get time recipient name's for which timecard has transferred------------



  IF l_transaction_id_tab IS NOT NULL THEN

  IF g_debug
  THEN
     hr_utility.trace('l_transfer_to : YET TO DECIDE');
     hr_utility.trace('Transaction Ids Count :' || l_transaction_id_tab.COUNT);
     hr_utility.trace('l_transfer_to :' || l_transfer_to);
  END IF;

    l_index := l_transaction_id_tab.FIRST;

    LOOP
      EXIT
    WHEN NOT l_transaction_id_tab.EXISTS(l_index);
      hr_utility.trace('l_transaction_id_tab('||l_index||'):'||l_transaction_id_tab(l_index)
      			   ||'-'||'l_transaction_process_id_tab('||l_index||'):'||l_transaction_process_id_tab(l_index));

      IF l_transaction_process_id_tab(l_index) = -1 THEN
	SELECT retrieval_process_id
	INTO l_transaction_process_id_tab(l_index)
	FROM hxc_retrieval_processes
	WHERE name = 'BEE Retrieval Process';
      END IF;

        SELECT time_recipient_name
          INTO l_time_recipient_name
	FROM hxc_application_set_comps_v
	WHERE application_set_id IN
	  (SELECT application_set_id
	   FROM hxc_time_building_blocks
	   WHERE time_building_block_id = l_timecard_id
	     and object_version_number      = l_timecard_ovn
	  )
	AND time_recipient_id IN
	  (SELECT time_recipient_id
	   FROM hxc_retrieval_processes
   	WHERE retrieval_process_id = l_transaction_process_id_tab(l_index));



	  hr_utility.trace('l_time_recipient_name :' || l_time_recipient_name);

	  IF l_transfer_to = 'None' AND l_time_recipient_name IS NOT NULL THEN
	    l_transfer_to := l_time_recipient_name;
	  ELSIF instrb(l_transfer_to,   l_time_recipient_name) = 0 THEN
	    l_transfer_to := l_transfer_to || ', ' || l_time_recipient_name;
	  END IF;

    l_index := l_transaction_id_tab.NEXT(l_index);

    END LOOP;

  END IF;  -- IF l_transaction_id IS NOT NULL THEN

  ------------------------------- pass the transfer_to data to TcActivitiesPG .------------------

  hr_utility.trace('l_transfer_to :' || l_transfer_to);
  hr_utility.trace('end');


  RETURN l_transfer_to;

END get_timecard_transferred_to;


END hxc_self_service_timecard;

/
