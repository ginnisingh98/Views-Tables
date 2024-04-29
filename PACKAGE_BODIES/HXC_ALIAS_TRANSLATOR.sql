--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_TRANSLATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_TRANSLATOR" AS
/* $Header: hxcalttlr.pkb 120.7.12010000.2 2008/08/05 11:59:17 ubhat ship $ */

g_debug	boolean:= hr_utility.debug_enabled;

-- ----------------------------------------------------------------------------
-- |---------------------------< do_deposit_translation>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE do_deposit_translation
         (p_attributes  	IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
         ,p_messages	        IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ) IS

-- index pl/sql table
l_index_attribute 	NUMBER;
l_index_att_to_match	NUMBER;
l_alias_definition_id	NUMBER;
l_alias_old_value_id	NUMBER;
--l_alias_value_id	NUMBER;
l_attribute_index	NUMBER;
l_attribute_found	BOOLEAN;
l_last_attribute	NUMBER;
l_index_to_delete 	NUMBER;

-- pl/sql table
l_tbb_id_reference_table	hxc_alias_utility.t_tbb_id_reference;
l_alias_val_att_to_match	hxc_alias_utility.t_alias_val_att_to_match;

l_bld_blk_info_type_id		NUMBER;
l_bld_blk_info_type		VARCHAR2(80);
l_time_building_block_id	NUMBER;
l_neg_attribute_id		NUMBER;
l_segment			VARCHAR2(80);
l_changed 		 	VARCHAR2(80);
l_value 		 	VARCHAR2(350);
l_alias_type			VARCHAR2(30);

l_att_to_delete			BOOLEAN;

l_reference_object		VARCHAR2(80);
l_prompt			VARCHAR2(80);
--l_select 			VARCHAR2(200);
--l_where_clause			VARCHAR2(300);
--l_apps_table			VARCHAR2(80);

--l_number_column_id		NUMBER;

BEGIN

g_debug:=hr_utility.debug_enabled;

if g_debug then
	hr_utility.trace('BEFORE DEPOSIT');
end if;
--hxc_alias_utility.dump_bb_attribute_info(p_attributes);
if g_debug then
	hr_utility.trace('------------------------');
	hr_utility.trace('------------------------');
	hr_utility.trace('------------------------');
end if;

-- create the reference attribute index table for each tbb_id
hxc_alias_utility.get_tbb_id_reference_table
(p_attributes			=> p_attributes,
 p_tbb_id_reference_table	=> l_tbb_id_reference_table);


-- pick the last attribute and increant it of 1
/*
if (p_attributes.count = 0) THEN
  l_last_attribute := 1;
else
  l_last_attribute := p_attributes.last + 1;
END IF;
*/

-- find also the first negative index available
l_neg_attribute_id :=
  hxc_alias_utility.get_next_negative_attribute_id
  (p_attributes  => p_attributes);

if g_debug then
	hr_utility.trace('Joel : l_neg_attribute_id'||l_neg_attribute_id);
end if;

-- now we are going to every attribute and if we need to we are doing the translation
l_index_attribute := p_attributes.first;
LOOP
   EXIT WHEN
     (NOT p_attributes.exists(l_index_attribute));

   -- reset some values
   l_alias_definition_id := NULL;
   l_alias_old_value_id	 := NULL;
   --l_alias_value_id	 := NULL;

if g_debug then
	hr_utility.trace('Joel : p_attributes(l_index_attribute).ATTRIBUTE_CATEGORY'||p_attributes(l_index_attribute).ATTRIBUTE_CATEGORY);
end if;

   -- we found an attribute to translate
   IF (p_attributes(l_index_attribute).ATTRIBUTE_CATEGORY like 'OTL_ALIAS%') THEN

    IF hxc_alias_utility.process_attribute(p_attributes(l_index_attribute)) THEN

     l_time_building_block_id   := p_attributes(l_index_attribute).BUILDING_BLOCK_ID;
     l_changed			:= p_attributes(l_index_attribute).CHANGED;

if g_debug then
	hr_utility.trace('l_alias_definition_id'||p_attributes(l_index_attribute).ATTRIBUTE2);
	hr_utility.trace('l_alias_old_value_id'||p_attributes(l_index_attribute).ATTRIBUTE3);
	hr_utility.trace('l_alias_type'||p_attributes(l_index_attribute).ATTRIBUTE4);
end if;

     --l_alias_value_id	:= p_attributes(l_index_attribute).ATTRIBUTE1;
     -- look for the alias_definition_id associated
     l_alias_definition_id  := to_number(p_attributes(l_index_attribute).ATTRIBUTE2);
     --l_alias_old_value_id   := to_number(p_attributes(l_index_attribute).ATTRIBUTE3);
     l_alias_type	    := p_attributes(l_index_attribute).ATTRIBUTE4;

     IF l_alias_definition_id is null or l_alias_type is null THEN
       -- get the alias definition from the alias value
       IF l_alias_definition_id is null THEN
         l_alias_definition_id :=
            hxc_alias_utility.get_alias_def_from_value(to_number(p_attributes(l_index_attribute).ATTRIBUTE1));
       END IF;

       hxc_alias_utility.get_alias_definition_info
 		(p_alias_definition_id 	=> l_alias_definition_id,
  		 p_alias_type 		=> l_alias_type,
  		 p_reference_object	=> l_reference_object,
  		 p_prompt		=> l_prompt);
     END IF;

if g_debug then
	hr_utility.trace('l_alias_definition_id'||p_attributes(l_index_attribute).ATTRIBUTE2);
	hr_utility.trace('l_alias_old_value_id'||p_attributes(l_index_attribute).ATTRIBUTE3);
	hr_utility.trace('l_alias_type'||p_attributes(l_index_attribute).ATTRIBUTE4);
end if;

     IF l_alias_type = 'OTL_ALT_DDF' THEN
       l_alias_old_value_id   := to_number(p_attributes(l_index_attribute).ATTRIBUTE3);
     END IF;
     --l_bld_blk_info_type_id := to_number(p_attributes(l_index_attribute).ATTRIBUTE3);
     --l_segment              := p_attributes(l_index_attribute).ATTRIBUTE4;
     --l_bld_blk_info_type    := p_attributes(l_index_attribute).ATTRIBUTE5;

     -- prepare alias_vall_to_match
     l_att_to_delete := FALSE;

     hxc_alias_utility.get_alias_att_to_match_to_dep
     				  (p_alias_definition_id 	=> l_alias_definition_id
     				  ,p_alias_old_value_id  	=> l_alias_old_value_id
     				  ,p_alias_type		 	=> l_alias_type
     				  ,p_original_value		=> p_attributes(l_index_attribute).ATTRIBUTE1
     				  ,p_alias_val_att_to_match	=> l_alias_val_att_to_match
     				  ,p_att_to_delete		=> l_att_to_delete);

     --
     -- debug
     --

if g_debug then
	hr_utility.trace('before debug table');
end if;

--hxc_alias_utility.dump_alias_val_att_to_match(l_alias_val_att_to_match);

if g_debug then
	hr_utility.trace('After debug table');
end if;

     -- look for the attribute if the bld_blk_exists in the attributes table
     -- already.
     -- for each element of the alias_val_att_to_match we are actually doing the
     -- translation
     l_index_att_to_match := l_alias_val_att_to_match.first;
     LOOP
      EXIT WHEN
         (NOT l_alias_val_att_to_match.exists(l_index_att_to_match));

	-- set the information
	l_bld_blk_info_type 	:= l_alias_val_att_to_match(l_index_att_to_match).BLD_BLK_INFO_TYPE;
	l_bld_blk_info_type_id  := l_alias_val_att_to_match(l_index_att_to_match).BLD_BLK_INFO_TYPE_ID;
	l_segment		:= l_alias_val_att_to_match(l_index_att_to_match).segment;
	-- we are getting the value now the correct value now
        hxc_alias_utility.get_attribute_to_match_info
  		(p_attribute_to_match	=> l_alias_val_att_to_match,
   		 p_index_in_table	=> l_index_att_to_match,
		 p_attribute_to_get	=> l_segment,
		 p_get_value		=> l_value);

        --l_attribute_index :=
            hxc_alias_utility.attribute_check
                 (p_bld_blk_info_type_id   => l_bld_blk_info_type_id
                 ,p_time_building_block_id => l_time_building_block_id
                 ,p_attributes             => p_attributes
                 ,p_tbb_id_reference_table => l_tbb_id_reference_table
                 ,p_attribute_index	   => l_attribute_index
                 ,p_attribute_found	   => l_attribute_found
                 );

if g_debug then
	hr_utility.trace('l_bld_blk_info_type_id '||l_bld_blk_info_type_id);
	hr_utility.trace('l_bld_blk_info_type '||l_bld_blk_info_type);
end if;
        -- now we need to check if we need to create an attribute or do an update
        IF l_attribute_found = FALSE AND l_att_to_delete = FALSE THEN

if g_debug then
	hr_utility.trace('create');
end if;
	  l_neg_attribute_id 	:= l_neg_attribute_id -1;

     	  p_attributes.extend;
     	  l_last_attribute 	:= p_attributes.last;
          p_attributes (l_last_attribute) :=
           hxc_attribute_type
           (l_neg_attribute_id,
            l_time_building_block_id,
            l_bld_blk_info_type,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            l_bld_blk_info_type_id,
            1,
            'Y',
            'Y',
            l_bld_blk_info_type,
            null,
            null);


          /*
          -- create a new attribute
          p_attributes(l_neg_attribute_id).TIME_ATTRIBUTE_ID 	:= l_neg_attribute_id;
          p_attributes(l_neg_attribute_id).BLD_BLK_INFO_TYPE    	:= l_bld_blk_info_type;
          p_attributes(l_neg_attribute_id).ATTRIBUTE_CATEGORY    	:= l_bld_blk_info_type;

          p_attributes(l_neg_attribute_id).BUILDING_BLOCK_ID    	:= l_time_building_block_id;
       	  p_attributes(l_neg_attribute_id).BLD_BLK_INFO_TYPE_ID 	:= l_bld_blk_info_type_id;
          p_attributes(l_neg_attribute_id).OBJECT_VERSION_NUMBER  	:= 1;
          p_attributes(l_neg_attribute_id).CHANGED := 'Y';
          p_attributes(l_neg_attribute_id).NEW     := 'Y';
          */

          -- now we need to place the id of this alias at the right place
if g_debug then
	hr_utility.trace('l_last_attribute '||l_last_attribute);
	hr_utility.trace('l_segment '||l_segment);
	hr_utility.trace('p_value_to_set '||l_value);
end if;

          hxc_alias_utility.set_attribute_information
  		(p_attributes 	=> p_attributes,
   		 p_index_in_table	=> l_last_attribute,--l_neg_attribute_id,
		 p_attribute_to_set	=> l_segment,
		 p_value_to_set		=> l_value);

          -- add the new attribute in the ref table
	  IF l_tbb_id_reference_table.exists (l_time_building_block_id) THEN
             l_tbb_id_reference_table(l_time_building_block_id).ATTRIBUTE_INDEX :=
 	     l_tbb_id_reference_table(l_time_building_block_id).ATTRIBUTE_INDEX ||'|'||l_last_attribute;--l_neg_attribute_id;
 	  ELSE
             l_tbb_id_reference_table(l_time_building_block_id).ATTRIBUTE_INDEX := '|'||l_last_attribute;--l_neg_attribute_id;
 	  END IF;

	--l_last_attribute 	:= l_neg_attribute_id -1; --l_last_attribute + 1;
	--l_neg_attribute_id 	:= l_neg_attribute_id -1;

        ELSE
          IF (l_attribute_found) THEN

if g_debug then
	hr_utility.trace('l_segment'||l_segment);
	hr_utility.trace('l_value'||l_value);
	hr_utility.trace('l_changed'||l_changed);
end if;
	  -- update the attribute
          -- now we need to place the id of this alias at the right place
           IF l_att_to_delete = FALSE THEN
             hxc_alias_utility.set_attribute_information
  		(p_attributes 	=> p_attributes,
        	 p_index_in_table	=> l_attribute_index,
		 p_attribute_to_set	=> l_segment,
		 p_value_to_set		=> l_value);
	   ELSE
if g_debug then
	hr_utility.trace('DELETE');
	hr_utility.trace('l_attribute_index'||l_attribute_index);
	hr_utility.trace('l_changed'||l_changed);
end if;
             hxc_alias_utility.set_attribute_information
  		(p_attributes 	=> p_attributes,
        	 p_index_in_table	=> l_attribute_index,
		 p_attribute_to_set	=> l_segment,
		 p_value_to_set		=> null);
	   END IF;

           IF p_attributes(l_attribute_index).CHANGED <> 'Y'
            THEN
          	p_attributes(l_attribute_index).CHANGED  :=
      	   		nvl(l_changed,p_attributes(l_attribute_index).CHANGED);
       	   END IF;
if g_debug then
	hr_utility.trace('p_attributes(l_attribute_index).CHANGED'||p_attributes(l_attribute_index).CHANGED);
end if;
          END IF;

         END IF;

         l_index_att_to_match := l_alias_val_att_to_match.next(l_index_att_to_match);

        END LOOP;

       END IF;

       l_index_to_delete := l_index_attribute;

      END IF;
-- go to the next attribute
l_index_attribute := p_attributes.next(l_index_attribute);

-- we delete the OTL_ALIAS attribute now
IF p_attributes.exists(l_index_to_delete) THEN
 p_attributes.delete(l_index_to_delete);
END if;

END LOOP;

--

--hxc_alias_utility.remove_empty_attribute
--      (p_attribute_table => p_attributes);


--
-- debug
--
if g_debug then
	hr_utility.trace(' AFTER TRANSLATION');
end if;

--hxc_alias_utility.dump_bb_attribute_info(p_attributes);







END do_deposit_translation;


-- ----------------------------------------------------------------------------
-- |----------------< do_retrieval_translation	          >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE do_retrieval_translation
         (p_attributes  		IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE,--hxc_self_service_time_deposit.building_block_attribute_info,
          p_tbb_id_reference_table	IN OUT NOCOPY hxc_alias_utility.t_tbb_id_reference,
	  p_alias_val_att_to_match	IN OUT NOCOPY hxc_alias_utility.t_alias_val_att_to_match,
	  p_item_attribute_category	IN VARCHAR2,
	  p_alias_definition_id		IN NUMBER,
	  p_alias_value_id		IN NUMBER,
	  p_alias_value_name		IN VARCHAR2,
	  p_alias_type			IN VARCHAR2,
	  p_alias_ref_object		IN VARCHAR2,
	  p_tbb_date_reference_table	IN OUT NOCOPY hxc_alias_utility.t_tbb_date_reference_table,
          p_alias_def_start_date        IN DATE,
          p_alias_def_end_date		IN DATE,
          p_alias_att_ref		IN OUT NOCOPY hxc_alias_utility.t_alias_att_ref_table,
          p_messages	        	IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)

IS

-- index for pl/sql table
--l_index_alias_def		NUMBER;
l_time_building_block_id	NUMBER;
l_index_next			NUMBER;
l_index_start			NUMBER;
l_result			VARCHAR2(10);
l_index_string			VARCHAR2(350);
l_index_value_to_match		NUMBER;
l_number_attribute_to_find	NUMBER;
l_attribute_match_found		NUMBER;
--l_attribute_id 			NUMBER := -1;
l_attribute_last		NUMBER;
--
l_value				VARCHAR2(350);
l_value_to_match		VARCHAR2(350);
l_value_id			VARCHAR2(350);
--l_bld_blk_info_type_id		NUMBER;
--l_segment			VARCHAR2(80);
--l_bld_blk_info_type		VARCHAR2(80);

l_tbb_start_date		DATE;
l_tbb_end_date			DATE;

l_time_building_block_ovn	NUMBER;

l_create_otl_alias		BOOLEAN := TRUE;

n number;
l_alias_value_id               NUMBER;

-- Bug No: 6943339
-- The below cursor was added to pull out the value set formats
-- for format conversion from canonical to display formats.
-- Takes in a reference object, which is the flex_value_set_id
-- and returns the format type.

CURSOR get_ref_datatype ( p_reference_object   NUMBER)
    IS SELECT format_type
         FROM fnd_flex_value_sets
        WHERE flex_value_set_id = p_reference_object;

l_vset_data_type            VARCHAR2(5);

BEGIN

l_number_attribute_to_find := p_alias_val_att_to_match.count;
-- flowing the alias type we will have different type of
-- translation we are supporting value_set_table type only
-- for the moment
l_time_building_block_id := p_tbb_id_reference_table.first;
/*
n:=p_tbb_date_reference_table.first;
dbms_output.put_line(p_tbb_date_reference_table.count);
loop
exit when not (p_tbb_date_reference_table.exists(n)) ;
dbms_output.put_line(n);
dbms_output.put_line(p_tbb_date_reference_table(n).START_TIME);
dbms_output.put_line(p_tbb_date_reference_table(N).STOP_TIME);
n:=p_tbb_date_reference_table.next(n);
end loop;
*/


LOOP
 EXIT WHEN
   (NOT p_tbb_id_reference_table.exists(l_time_building_block_id));

     l_index_string := p_tbb_id_reference_table(l_time_building_block_id).ATTRIBUTE_INDEX;

--dbms_output.put_line('l_index_string '||l_index_string);

     l_tbb_start_date	:= SYSDATE;
     l_tbb_end_date	:= HR_GENERAL.END_OF_TIME;
--dbms_output.put_line('l_time_building_block_id '||l_time_building_block_id);

     IF (p_tbb_date_reference_table.exists(l_time_building_block_id)) THEN
        l_tbb_start_date := p_tbb_date_reference_table(l_time_building_block_id).START_TIME;
        l_tbb_end_date   := p_tbb_date_reference_table(l_time_building_block_id).STOP_TIME;
     END IF;

     -- go through the string and check the to_check
     l_index_start := INSTR(l_index_string,'|',1,1)+1;

     -- reset
     l_attribute_match_found := 0;
     l_value 	:= NULL;
     l_value_id	:= NULL;
     --l_bld_blk_info_type_id := NULL;
--dbms_output.put_line('p_alias_def_end_date '||p_alias_def_end_date);
--dbms_output.put_line('p_alias_def_start_date '||p_alias_def_start_date);
--dbms_output.put_line('l_tbb_start_date '||l_tbb_start_date);
--dbms_output.put_line('l_tbb_start_date '||l_tbb_start_date);


     -- we are processing this block only if the date of the block
     -- are part of the alias
     IF  (l_tbb_start_date <= p_alias_def_end_date
     AND l_tbb_start_date  >= p_alias_def_start_date) THEN

      LOOP
       l_index_next := INSTR(l_index_string,'|',l_index_start,1);

       IF(l_index_next = 0) THEN
    	 l_result := SUBSTR(l_index_string,
    	 		    l_index_start,
    	 		    length(l_index_string)+1-l_index_start);
       ELSE
	 l_result := SUBSTR(l_index_string,
	 		    l_index_start,
	 		    l_index_next-l_index_start);
       END IF;

       -- first we need to find if the attribute as the same bld_blk_type_id
       l_index_value_to_match := p_alias_val_att_to_match.first;
       --l_value 		:= NULL;
       --l_value_id	:= NULL;

--dbms_output.put_line
--           ('l_result: '||l_result);

--dbms_output.put_line
--           ('p_alias_val_att_to_match.count: '
--             ||p_alias_val_att_to_match.count);

       LOOP
       EXIT WHEN
         (NOT p_alias_val_att_to_match.exists(l_index_value_to_match));

--dbms_output.put_line
--           ('p_attributes(l_result).BLD_BLK_INFO_TYPE: '||p_attributes(l_result).BLD_BLK_INFO_TYPE);
--dbms_output.put_line
--           ('p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE_ID: '
--             ||p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE);


         l_time_building_block_ovn := p_attributes(l_result).BUILDING_BLOCK_OVN;

         IF  (p_attributes(l_result).BLD_BLK_INFO_TYPE_ID =
         	p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE_ID)
         THEN

             -- following the type of the alternate we will have two processing
             -- first if the alias type is 'OTL_ALT_DDF'
             -- we need to check if the value of the match table is found in
             -- the attribute table.

             -- we need to find the value
             hxc_alias_utility.get_attribute_information
  		(p_attributes 	=> p_attributes,
   		 p_index_in_table	=> l_result,
		 p_attribute_to_get	=> p_alias_val_att_to_match(l_index_value_to_match).segment,
		 p_get_value		=> l_value);


             IF p_alias_type = 'OTL_ALT_DDF' THEN

               -- in this case we need to look if the value to match exists in
               -- attribute table.
               -- find the value in the attribute table to match
               hxc_alias_utility.get_attribute_to_match_info
  		(p_attribute_to_match 	=> p_alias_val_att_to_match,
   		 p_index_in_table	=> l_index_value_to_match,
		 p_attribute_to_get	=> p_alias_val_att_to_match(l_index_value_to_match).segment,
		 p_get_value		=> l_value_to_match);
/*
n:=p_alias_val_att_to_match.first;
loop
exit when not (p_alias_val_att_to_match.exists(n)) ;
dbms_output.put_line('att1 '||p_alias_val_att_to_match(n).ATTRIBUTE1);
dbms_output.put_line('att2 '||p_alias_val_att_to_match(n).ATTRIBUTE2);
n:=p_alias_val_att_to_match.next(n);
end loop;
*/

--dbms_output.put_line
--           ('l_value: '||l_value);
--dbms_output.put_line
--           ('l_value_to_match: '||l_value_to_match);
	       IF l_value = l_value_to_match or l_value_to_match is null THEN

	       	 l_attribute_match_found := l_attribute_match_found + 1;

	       END IF;
--dbms_output.put_line
--           ('l_attribute_match_found: '||l_attribute_match_found);

               --l_bld_blk_info_type_id := p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE_ID;
               --l_bld_blk_info_type    := p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE;
               --l_segment	      := p_alias_val_att_to_match(l_index_value_to_match).segment;
               l_value_id	      := p_alias_value_id;

             ELSE

               -- we need to find the value
               hxc_alias_utility.get_attribute_information
  		(p_attributes 		=> p_attributes,
   		 p_index_in_table	=> l_result,
		 p_attribute_to_get	=> p_alias_val_att_to_match(l_index_value_to_match).segment,
		 p_get_value		=> l_value);


               l_attribute_match_found := l_attribute_match_found + 1;

               -- we need to look now if the this alias to match is the id
               -- if yes then we need to find it
               IF p_alias_val_att_to_match(l_index_value_to_match).component_type = 'COLUMN_ID' THEN
                 -- find now where is the id
--dbms_output.put_line
--           ('l_value: '||l_value);


                 IF l_value_id is not null THEN
                     l_value_id	        := l_value_id ||'ALIAS_SEPARATOR'|| l_value;
                 ELSE
                     l_value_id	        := l_value;
                 END IF;
--dbms_output.put_line
--           ('l_value_id: '||l_value_id);

                 --l_bld_blk_info_type_id := p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE_ID;
                 --l_bld_blk_info_type    := p_alias_val_att_to_match(l_index_value_to_match).BLD_BLK_INFO_TYPE;
                 --l_segment	        := p_alias_val_att_to_match(l_index_value_to_match).segment;
               --ELSE
                 --l_value_id := NULL;
               END IF;

               IF p_alias_val_att_to_match(l_index_value_to_match).component_type = 'VALUE'
               THEN

                  -- Bug No : 6943339
                  -- Added the below construct for format conversion for the alias values.
                  -- If the alias value to match above is VALUE, the value id has to be assigned
                  -- the value.  But the values would be stored in attributes table in canonical
                  -- format, and hence needs a conversion. We are doing this only for Value Set
                  --  - None type, because the translation to canonical is done while deposit
                  -- only for value set none types.
                  -- * Check if there exists a value for the format type in the associative
                  --    array.
                  -- * Pick up the datatype and store in the assoc array, if it doesnt exist
                  --   already.
                  -- * If the format is X ( based on the standard system lookup FIELD_TYPES )
                  --   it is standard date type. Hence convert it to date display format.
                  -- * If the format is N ( again based on FIELD_TYPES ), its number and
                  --   convert to number display format.


                  IF p_alias_type = 'VALUE_SET_NONE'
                  THEN
                     IF NOT g_vset_fmt.EXISTS(TO_CHAR(p_alias_val_att_to_match(l_index_value_to_match).reference_object))
                     THEN
                        OPEN get_ref_datatype(p_alias_val_att_to_match(l_index_value_to_match).reference_object);
                        FETCH get_ref_datatype
                         INTO l_vset_data_type;
                        CLOSE get_ref_datatype;

                        g_vset_fmt(TO_CHAR(p_alias_val_att_to_match(l_index_value_to_match).reference_object))
                          := l_vset_data_type;
                     END IF;

                     -- The below conversion constructs are put inside a BEGIN END
                     -- block to avoid any exception for the existing timecards.
                     -- Existing data wont be in canonical format,and if a format conversion
                     -- error occurs, settle for the value stored, ie. just like the
                     -- way it was before this fix.

                     BEGIN
                         IF g_vset_fmt(TO_CHAR(p_alias_val_att_to_match(l_index_value_to_match).reference_object)) = 'X'
                     	 THEN
                     	    l_value_id := hr_chkfmt.changeformat(l_value,'D',NULL);
                     	 ELSIF g_vset_fmt(TO_CHAR(p_alias_val_att_to_match(l_index_value_to_match).reference_object)) = 'N'
                     	 THEN
                     	    l_value_id := FND_NUMBER.CANONICAL_TO_NUMBER(l_value);
                     	 ELSE
                     	    l_value_id := l_value;
                     	 END IF;

                       EXCEPTION
                           WHEN OTHERS THEN
                               l_value_id := l_value;
                     END;

               	  ELSE
               	     l_value_id := l_value;

               	  END IF;

               END IF;

             END IF;


         END IF;

         l_index_value_to_match := p_alias_val_att_to_match.next(l_index_value_to_match);

     END LOOP;

     l_index_start	:= l_index_next + 1;
     l_result 		:= NULL;

     EXIT WHEN l_index_next = 0;
     END LOOP; -- attribute for a tbb_id

--dbms_output.put_line
--           ('l_attribute_match_found: '||l_attribute_match_found);
--dbms_output.put_line
--           ('l_number_attribute_to_find: '||l_number_attribute_to_find);
--dbms_output.put_line
--           ('l_value_id: '||l_value_id);

    l_create_otl_alias := FALSE;

    -- we look if we need to do the translation
    IF l_attribute_match_found = l_number_attribute_to_find
      and l_value_id is not null THEN

--dbms_output.put_line
--           ('created the attribute: ');
      -- before adding the row we need to check if the
      -- time building block has already an alias.
      --IF not(p_alias_att_ref.exists(l_time_building_block_id)) THEN

      l_create_otl_alias := TRUE;

      --ELSE
        -- if the type of the alias is PARTIAL then
        -- we are overwritting this partial
        -- with this one
      IF p_alias_att_ref.exists(l_time_building_block_id) THEN

        -- start bug 3899872
        -- if the time building block has already an alias with the same att cat
        -- we are not creating a new otl alias
        IF  p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_ATT = p_item_attribute_category
        AND p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_TYPE = 'FULL'
        THEN

          l_create_otl_alias := FALSE;

        ELSIF p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_ATT = p_item_attribute_category
        AND   p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_TYPE = 'PARTIAL'
        THEN
          -- first we are deleting the partial attribute
          p_attributes.delete(to_number(p_alias_att_ref(l_time_building_block_id).ATTRIBUTE_INDEX));

          l_create_otl_alias := TRUE;

        END IF;
        -- end bug 3899872

      END IF;

      IF (l_create_otl_alias) THEN

          -- then we are creating the attribute
          -- we do the translation
          -- create a new attribute.
          g_attribute_id   := g_attribute_id - 1;
          --l_attribute_last := p_attributes.last + 1;

          p_attributes.extend;
          l_attribute_last := p_attributes.last;-- + 1;
          p_attributes (l_attribute_last) :=
          hxc_attribute_type
	          (g_attribute_id,
	          l_time_building_block_id,
	          p_item_attribute_category,
	          l_value_id,
	          p_alias_definition_id,
	          p_alias_value_id,
	          p_alias_type,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,--10
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,--20
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          null,
	          p_alias_ref_object,--29
	          p_alias_value_name,--30
	          null,
	          1,
	          'N',
	          'N',
	          p_item_attribute_category,
	          null,
	          l_time_building_block_ovn);

          --p_attributes(l_attribute_last).TIME_ATTRIBUTE_ID := l_attribute_id;
          --p_attributes(l_attribute_last).BUILDING_BLOCK_ID := l_time_building_block_id;
          --p_attributes(l_attribute_last).BLD_BLK_INFO_TYPE
      	  --		:= p_item_attribute_category;
          --p_attributes(l_attribute_last).ATTRIBUTE_CATEGORY
      	  --		:= p_item_attribute_category;
          --p_attributes(l_attribute_last).ATTRIBUTE1 := l_value_id;

          -- we store extra information to do the translation back
          --p_attributes(l_attribute_last).ATTRIBUTE2 := p_alias_definition_id;
          --p_attributes(l_attribute_last).ATTRIBUTE3 := p_alias_value_id;
          --p_attributes(l_attribute_last).ATTRIBUTE4 := p_alias_type;
      --p_attributes(l_attribute_last).ATTRIBUTE3 := l_bld_blk_info_type_id;
      --p_attributes(l_attribute_last).ATTRIBUTE4 := l_segment;
      --p_attributes(l_attribute_last).ATTRIBUTE5 := l_bld_blk_info_type;

          --p_attributes(l_attribute_last).OBJECT_VERSION_NUMBER := 1;
          --p_attributes(l_attribute_last).CHANGED  	:= 'N';
          --p_attributes(l_attribute_last).NEW 	:= 'N';

          l_value_id := NULL;

          -- add this otl alias in the reference table
          p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_TYPE  := 'FULL';
          p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_ATT   := p_item_attribute_category;
          p_alias_att_ref(l_time_building_block_id).ATTRIBUTE_INDEX := l_attribute_last;

       END IF;

    ELSIF l_attribute_match_found  <> l_number_attribute_to_find and
          not(p_alias_att_ref.exists(l_time_building_block_id)) THEN

      -- we do the translation
      -- create a new attribute.
      g_attribute_id   := g_attribute_id - 1;
      --l_attribute_last := p_attributes.last + 1;

      if(l_attribute_match_found = 0) then
	      l_alias_value_id := null;
      else
	      l_alias_value_id := p_alias_value_id;
      end if;

      p_attributes.extend;
      l_attribute_last := p_attributes.last;-- + 1;
      p_attributes (l_attribute_last) :=
         hxc_attribute_type
         (g_attribute_id,
          l_time_building_block_id,
          p_item_attribute_category,
          null,
          p_alias_definition_id,
          l_alias_value_id,
          p_alias_type,
          null,
          null,
          null,
          null,
          null,
          null,--10
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,--20
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          p_alias_ref_object,--29
          p_alias_value_name,--30
          null,
          1,
          'N',
          'N',
          p_item_attribute_category,
          null,
          null);
      --p_attributes(l_attribute_last).TIME_ATTRIBUTE_ID := l_attribute_id;
      --p_attributes(l_attribute_last).BUILDING_BLOCK_ID := l_time_building_block_id;
      --p_attributes(l_attribute_last).BLD_BLK_INFO_TYPE
      --			:= p_item_attribute_category;
      --p_attributes(l_attribute_last).ATTRIBUTE_CATEGORY
      --			:= p_item_attribute_category;
      --p_attributes(l_attribute_last).ATTRIBUTE1 := null;

      -- we store extra information to do the translation back
      --p_attributes(l_attribute_last).ATTRIBUTE2 := p_alias_definition_id;
      --p_attributes(l_attribute_last).ATTRIBUTE3 := p_alias_value_id;
      --p_attributes(l_attribute_last).ATTRIBUTE4 := p_alias_type;
      --p_attributes(l_attribute_last).ATTRIBUTE3 := l_bld_blk_info_type_id;
      --p_attributes(l_attribute_last).ATTRIBUTE4 := l_segment;
      --p_attributes(l_attribute_last).ATTRIBUTE5 := l_bld_blk_info_type;

      --p_attributes(l_attribute_last).OBJECT_VERSION_NUMBER := 1;
      --p_attributes(l_attribute_last).CHANGED  	:= 'N';
      --p_attributes(l_attribute_last).NEW 	:= 'N';

      -- add this otl alias in the reference table
      p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_TYPE  := 'PARTIAL';
      p_alias_att_ref(l_time_building_block_id).ATTRIBUTE_INDEX := l_attribute_last;
      p_alias_att_ref(l_time_building_block_id).OTL_ALIAS_ATT   := p_item_attribute_category;


      --p_tbb_id_reference_table.delete(l_time_building_block_id);

      --that means we find one attribute but no translation
/*
      hxc_timecard_message_helper.addErrorToCollection
      (p_messages
      ,'HXC_PARTICIAL_TRANSLATION'
      ,hxc_timecard.c_warning
      ,null
      ,null
      ,hxc_timecard.c_hxc
      ,null
      ,null
      ,null
      ,null
      );
  */
    END if;
   END IF; --end of the checking on the date

   l_attribute_match_found := 0;
   -- go to the next tbb_id
   l_time_building_block_id := p_tbb_id_reference_table.next(l_time_building_block_id);

END LOOP;

/*
n:=p_alias_val_att_to_match.first;
loop
exit when not (p_alias_val_att_to_match.exists(n)) ;
dbms_output.put_line('att1 '||p_alias_val_att_to_match(n).BLD_BLK_INFO_TYPE_ID);
dbms_output.put_line('att2 '||p_alias_val_att_to_match(n).BLD_BLK_INFO_TYPE);
n:=p_alias_val_att_to_match.next(n);
end loop;
*/

END do_retrieval_translation;

-- ----------------------------------------------------------------------------
-- |----------------< do_retrieval_translation		  >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE do_retrieval_translation
         (p_attributes	IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE--hxc_self_service_time_deposit.building_block_attribute_info
         ,p_blocks	IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE--hxc_self_service_time_deposit.timecard_info
         ,p_start_time  	IN DATE DEFAULT sysdate
         ,p_stop_time   	IN DATE DEFAULT hr_general.end_of_time
         ,p_resource_id 	IN NUMBER -- timekeeper or resource
         ,p_processing_mode	IN VARCHAR2 DEFAULT hxc_alias_utility.c_ss_processing
         ,p_add_alias_display_value   IN BOOLEAN DEFAULT FALSE
         ,p_add_alias_ref_object      IN BOOLEAN DEFAULT FALSE
         ,p_messages	        IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         )  IS

CURSOR csr_alias_values(p_alias_definition_id NUMBER,
			p_start_time	      DATE,
			p_stop_time	      DATE)
IS
select  alias_value_id ,alias_value_name
from  hxc_alias_values
where alias_definition_id = p_alias_definition_id
and   enabled_flag	  = 'Y'
and   date_from <= p_stop_time
and   nvl(date_to,hr_general.end_of_time) >= p_start_time;

-- index for pl/sql table
l_index_alias_def		NUMBER;
--l_time_building_block_id	NUMBER;
--l_index_next			NUMBER;
--l_index_start			NUMBER;
--l_result			VARCHAR2(10);
--l_index_string			VARCHAR2(350);
--l_index_value_to_match		NUMBER;
--l_number_attribute_to_find	NUMBER;
--l_attribute_match_found		NUMBER;
--l_attribute_id 			NUMBER := -1;
--l_attribute_last		NUMBER;

-- pl/sql table
l_alias_def_item_tab		hxc_alias_utility.t_alias_def_item;
l_tbb_id_reference_table	hxc_alias_utility.t_tbb_id_reference;
l_alias_val_att_to_match	hxc_alias_utility.t_alias_val_att_to_match;
l_tbb_date_reference_table	hxc_alias_utility.t_tbb_date_reference_table;

l_alias_type 		hxc_alias_types.alias_type%TYPE;
l_reference_object	hxc_alias_types.reference_object%TYPE;
l_prompt		hxc_alias_definitions_tl.prompt%TYPE;

--p_attributes		HXC_ATTRIBUTE_TABLE_TYPE;
--p_blocks		HXC_BLOCK_TABLE_TYPE;
--
--l_value				VARCHAR2(350);
--l_value_id			VARCHAR2(350);
--l_bld_blk_info_type_id		NUMBER;
--l_segment			VARCHAR2(80);
--l_bld_blk_info_type		VARCHAR2(80);

l_alias_att_ref		hxc_alias_utility.t_alias_att_ref_table;

l_stop_time		DATE;
l_start_time		DATE;

l_old_alias_type	hxc_alias_types.alias_type%TYPE;

l_alias_value_name	VARCHAR2(80);

n number;

BEGIN

g_debug:=hr_utility.debug_enabled;


if g_debug then
	hr_utility.trace('p_start_time '||p_start_time);
	hr_utility.trace('p_stop_time  '||p_stop_time);
	hr_utility.trace('p_resource_id '||p_resource_id);
	hr_utility.trace('p_processing_mode '||p_processing_mode);
end if;

--p_attributes 	:= hxc_alias_utility.convert_attribute_to_type(p_attributes_tmp);
--p_blocks	:= hxc_alias_utility.convert_timecard_to_type(p_blocks_tmp);

-- create the reference attribute index table for each tbb_id
hxc_alias_utility.get_tbb_id_reference_table
(p_attributes			=> p_attributes,
 p_tbb_id_reference_table	=> l_tbb_id_reference_table);

-- create the reference date index table for each 'DETAIL' tbb_id
hxc_alias_utility.get_tbb_date_reference_table
(p_blocks 			=> p_blocks,
 p_tbb_date_reference_table	=> l_tbb_date_reference_table,
 p_timecard_start_time		=> l_start_time,
 p_timecard_stop_time		=> l_stop_time);

/*
n:=l_tbb_date_reference_table.first;
dbms_output.put_line('Ici '||l_tbb_date_reference_table.count);
loop
exit when not (l_tbb_date_reference_table.exists(n)) ;
dbms_output.put_line(n);
dbms_output.put_line(l_tbb_date_reference_table(n).START_TIME);
dbms_output.put_line(l_tbb_date_reference_table(N).STOP_TIME);
n:=l_tbb_date_reference_table.next(n);
end loop;
*/


-- first check that the date are checked, if not then
-- we are taking the sysdate for start date

IF p_start_time is not null THEN
   l_start_time := p_start_time;
END IF;

IF p_stop_time is not null THEN
   l_stop_time := p_stop_time;
END IF;



--Following the processing mode we are doing the switching
IF p_processing_mode = HXC_ALIAS_UTILITY.c_ss_processing THEN

-- Initialize the global table used to cache preferences to NULL so that
-- the old pref is cleared.   Used for Persistent responsibility and
-- session responsibility eligibility criteria.

  hxc_alias_utility.initialize;


  -- work out on the resource
  hxc_alias_utility.get_alias_def_item
    		(p_resource_id 		=> p_resource_id,
    		 p_attributes		=> p_attributes,
    		 p_alias_def_item	=> l_alias_def_item_tab,
    		 p_start_time		=> l_start_time,
    		 p_stop_time		=> l_stop_time);
/*
if g_debug then
	hr_utility.trace('count '||l_alias_def_item_tab.count);
	hr_utility.trace('ALIAS_DEFINITION_ID '||l_alias_def_item_tab(l_alias_def_item_tab.first).ALIAS_DEFINITION_ID);
	hr_utility.trace('ITEM_ATTRIBUTE_CATEGORY '||l_alias_def_item_tab(l_alias_def_item_tab.first).ITEM_ATTRIBUTE_CATEGORY);
	hr_utility.trace('RESOURCE_ID '||l_alias_def_item_tab(l_alias_def_item_tab.first).RESOURCE_ID);
	hr_utility.trace('LAYOUT_ID '||l_alias_def_item_tab(l_alias_def_item_tab.first).LAYOUT_ID);
	hr_utility.trace('ALIAS_LABEL '||l_alias_def_item_tab(l_alias_def_item_tab.first).ALIAS_LABEL);
	hr_utility.trace('PREF_START_DATE '||l_alias_def_item_tab(l_alias_def_item_tab.first).PREF_START_DATE);
	hr_utility.trace('PREF_END_DATE '||l_alias_def_item_tab(l_alias_def_item_tab.first).PREF_END_DATE);
end if;
*/
ELSIF p_processing_mode = HXC_ALIAS_UTILITY.c_tk_processing THEN
  -- get from the timekeeper preference the list of alias definition
  -- to use to do the translation
  hxc_alias_utility.get_alias_def_item
    		(p_timekeeper_id 	=> p_resource_id,
    		 p_alias_def_item	=> l_alias_def_item_tab);
ELSE
  -- exit of the translation
  RETURN;
END IF;

--hxc_alias_utility.dump_alias_def_item (l_alias_def_item_tab);

-- now for each alias definition we need to find first the
-- mapping to find and then to look into the attributes table
-- if we can do the translation.
l_index_alias_def := l_alias_def_item_tab.first;

LOOP
 EXIT WHEN
 (NOT l_alias_def_item_tab.exists(l_index_alias_def));

  -- get the type of the alias
  -- we need find out the information following the type of the alias
  hxc_alias_utility.get_alias_definition_info
    (l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
     l_alias_type,
     l_reference_object,
     l_prompt);

  -- first we delete the alias attribute reference table
  -- since we are working on a different alias definition.

  --bug 3083904. quick fix in the case that
  --we have 2 same AN values in the set of alternate
  -- name. But this fix will work only if the AN
  -- definition which have the same type are
  -- consecutively set in the preference.
  IF p_processing_mode = HXC_ALIAS_UTILITY.c_ss_processing THEN
    IF l_old_alias_type <> l_alias_type THEN
      l_alias_att_ref.delete;
    END IF;
  ELSE
      l_alias_att_ref.delete;
  END IF;

  l_old_alias_type := l_alias_type;

--dbms_output.put_line
--           ('l_alias_def_item_tab(l_index_alias_def).alias_definition_id: '||l_alias_def_item_tab(l_index_alias_def).alias_definition_id);
--dbms_output.put_line
--           ('l_alias_type: '||l_alias_type);
--dbms_output.put_line
--           ('l_reference_object: '||l_reference_object);
if g_debug then
	hr_utility.trace
		   ('l_alias_def_item_tab(l_index_alias_def).alias_definition_id: '||l_alias_def_item_tab(l_index_alias_def).alias_definition_id);
	hr_utility.trace
		   ('l_alias_type: '||l_alias_type);
	hr_utility.trace
		   ('l_reference_object: '||l_reference_object);
end if;

  --reset the table.
  l_alias_val_att_to_match.delete;

  l_alias_value_name := null;

  IF l_alias_type = 'OTL_ALT_DDF' THEN
    -- we need to open the cursor to find how many
    -- values is attached to this alias definition
    -- for each alias of the alias definition
    FOR c_alias_value IN
        csr_alias_values(l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
        		 l_start_time,
        		 l_stop_time) LOOP

     -- get the alias value attribute to match table
     l_alias_val_att_to_match.delete;

     hxc_alias_utility.get_alias_val_att_to_match
     (l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
      c_alias_value.alias_value_id,
      l_alias_val_att_to_match);

----dbms_output.put_line
--           ('c_alias_value.alias_value_id: '||c_alias_value.alias_value_id);

if g_debug then
	hr_utility.trace
	           ('c_alias_value.alias_value_id: '||c_alias_value.alias_value_id);
end if;

--hxc_alias_utility.dump_alias_val_att_to_match( l_alias_val_att_to_match);

     IF (p_add_alias_display_value) THEN
        l_alias_value_name := c_alias_value.alias_value_name;
     ELSE
        l_alias_value_name := null;
     END IF;

     IF not(p_add_alias_ref_object) THEN
        l_reference_object := null;
     END IF;



     do_retrieval_translation
         (p_attributes  		=> p_attributes,
          p_tbb_id_reference_table	=> l_tbb_id_reference_table,
	  p_alias_val_att_to_match	=> l_alias_val_att_to_match,
	  p_item_attribute_category	=> l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,
	  p_alias_definition_id		=> l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
	  p_alias_value_id		=> c_alias_value.alias_value_id,
	  p_alias_value_name		=> l_alias_value_name,
	  p_alias_type			=> l_alias_type,
	  p_alias_ref_object		=> l_reference_object,
	  p_tbb_date_reference_table	=> l_tbb_date_reference_table,
          p_alias_def_start_date        => l_alias_def_item_tab(l_index_alias_def).pref_start_date,
          p_alias_def_end_date		=> l_alias_def_item_tab(l_index_alias_def).pref_end_date,
          p_alias_att_ref		=> l_alias_att_ref,
          p_messages			=> p_messages
	  );

    END LOOP;


  -- get the alias attribute values to match with the attribute.
  ELSE


     IF not(p_add_alias_display_value) THEN
        l_alias_value_name := null;
     END IF;

     IF not(p_add_alias_ref_object) THEN
        l_reference_object := null;
     END IF;


     hxc_alias_utility.get_alias_val_att_to_match
     (l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
      l_alias_val_att_to_match);

--hxc_alias_utility.dump_alias_val_att_to_match( l_alias_val_att_to_match);

     do_retrieval_translation
         (p_attributes  		=> p_attributes,
          p_tbb_id_reference_table	=> l_tbb_id_reference_table,
	  p_alias_val_att_to_match	=> l_alias_val_att_to_match,
	  p_item_attribute_category	=> l_alias_def_item_tab(l_index_alias_def).ITEM_ATTRIBUTE_CATEGORY,
	  p_alias_definition_id		=> l_alias_def_item_tab(l_index_alias_def).alias_definition_id,
	  p_alias_value_id		=> null,
	  p_alias_value_name 		=> l_alias_value_name,
	  p_alias_type			=> l_alias_type,
	  p_alias_ref_object		=> l_reference_object,
	  p_tbb_date_reference_table	=> l_tbb_date_reference_table,
          p_alias_def_start_date        => l_alias_def_item_tab(l_index_alias_def).pref_start_date,
          p_alias_def_end_date		=> l_alias_def_item_tab(l_index_alias_def).pref_end_date,
          p_alias_att_ref		=> l_alias_att_ref,
          p_messages			=> p_messages
          );


  END IF;

  l_index_alias_def := l_alias_def_item_tab.next(l_index_alias_def);

END LOOP;

--hxc_alias_utility.dump_bb_attribute_info(p_attributes);


END do_retrieval_translation;

END HXC_ALIAS_TRANSLATOR;

/
