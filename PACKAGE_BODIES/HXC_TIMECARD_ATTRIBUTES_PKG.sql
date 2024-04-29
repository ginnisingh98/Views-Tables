--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_ATTRIBUTES_PKG" as
/* $Header: hxctcrda.pkb 115.4 2002/06/10 13:31:10 pkm ship    $ */
--
-- function get_timecard_attribute
--
--
-- description Returns the first found Attribute for the given Detail Building
--             block.
--
-- parameters
--        p_timecard_id		  - Detail Building block id of timecard
--        p_timecard_ovn          - Detail Building block ovn of the timecard
--        p_map                   - Map for the attribute from the mappings
--        p_field_name            - Field Name of the attribute from the mappings
--
-- returns 	Attribute
--
FUNCTION get_timecard_attribute(
           p_timecard_id number,
           p_timecard_ovn number,
           p_map varchar2,
           p_field_name varchar2)
RETURN varchar2
is

cursor csr_timecard_attributes(p_context varchar2, p_segment varchar2,bb_id number,bb_ovn number)
is
SELECT
decode(hta.attribute_category,
p_context, decode(p_segment,
'ATTRIBUTE1' , hta.attribute1,
'ATTRIBUTE2' , hta.attribute2,
'ATTRIBUTE3' , hta.attribute3,
'ATTRIBUTE4' , hta.attribute4,
'ATTRIBUTE5' , hta.attribute5,
'ATTRIBUTE6' , hta.attribute6,
'ATTRIBUTE7' , hta.attribute7,
'ATTRIBUTE8' , hta.attribute8,
'ATTRIBUTE9' , hta.attribute9,
'ATTRIBUTE10' , hta.attribute10,
'ATTRIBUTE11' , hta.attribute11,
'ATTRIBUTE12' , hta.attribute12,
'ATTRIBUTE13' , hta.attribute13,
'ATTRIBUTE14' , hta.attribute14,
'ATTRIBUTE15' , hta.attribute15,
'ATTRIBUTE16' , hta.attribute16,
'ATTRIBUTE17' , hta.attribute17,
'ATTRIBUTE18' , hta.attribute18,
'ATTRIBUTE19' , hta.attribute19,
'ATTRIBUTE20' , hta.attribute20,
'ATTRIBUTE21' , hta.attribute21,
'ATTRIBUTE22' , hta.attribute22,
'ATTRIBUTE23' , hta.attribute23,
'ATTRIBUTE24' , hta.attribute24,
'ATTRIBUTE25' , hta.attribute25,
'ATTRIBUTE26' , hta.attribute26,
'ATTRIBUTE27' , hta.attribute27,
'ATTRIBUTE28' , hta.attribute28,
'ATTRIBUTE29' , hta.attribute29,
'ATTRIBUTE30' , hta.attribute30
),
null)
FROM hxc_time_building_blocks htb,
     hxc_time_attribute_usages htau,
     hxc_time_attributes hta
WHERE
    htb.time_building_block_id = bb_id
and htb.object_version_number = bb_ovn
and htb.time_building_block_id = htau.time_building_block_id
and htb.object_version_number = htau.time_building_block_ovn
and htau.time_attribute_id  = hta.time_attribute_id
and htb.resource_type = 'PERSON'
and htb.date_to = hr_general.end_of_time
and htb.scope = 'DETAIL';

CURSOR csr_mapping(p_map varchar2, p_field_name varchar2)
is
SELECT hma.context,hma.segment
FROM hxc_mapping_attributes_v hma
WHERE hma.map = p_map
and   hma.field_name = p_field_name;

l_mapping_row csr_mapping%rowtype;
l_attribute_row varchar2(500);
l_attribute varchar2(1000);
BEGIN
   l_attribute := null;

   Open  csr_mapping(p_map,p_field_name);
   Fetch csr_mapping into l_mapping_row;
   Close csr_mapping;


   Open csr_timecard_attributes(l_mapping_row.context,
                                l_mapping_row.segment,
                                p_timecard_id,
                                p_timecard_ovn);
   LOOP
      Fetch csr_timecard_attributes into l_attribute_row;


      EXIT when csr_timecard_attributes%NOTFOUND;
      IF (l_attribute_row is not null)
      THEN
          l_attribute := l_attribute_row;
          return l_attribute;
       END IF;
    END LOOP;
    Close  csr_timecard_attributes;

    return l_attribute;
 END get_timecard_attribute;

END hxc_timecard_attributes_pkg;

/
