--------------------------------------------------------
--  DDL for Package Body HXC_ELP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ELP_UTILS" as
/* $Header: hxcelputl.pkb 120.4.12000000.2 2007/03/27 12:52:17 anuthi noship $ */

-- global package data type and variables
g_debug boolean		:=hr_utility.debug_enabled;
-- public procedure


-- ksethi start new proc for appliation set updation

PROCEDURE set_time_bb_appl_set_id
	 (P_TIME_BUILDING_BLOCKS IN OUT NOCOPY	HXC_BLOCK_TABLE_TYPE
	 ,P_TIME_ATTRIBUTES 	 IN OUT NOCOPY	HXC_ATTRIBUTE_TABLE_TYPE
	 ,P_MESSAGES		 IN OUT NOCOPY  hxc_self_service_time_deposit.message_table
	 ,P_PTE_TERG_ID          IN     number
	 ,P_APPLICATION_SET_ID   IN     number
	 )
    IS

app_set_ok       	   varchar2(1);
time_rec_present           varchar2(1);
time_rec_transfer          varchar2(1);
l_null_application_set_id  varchar2(1);
l_next_blk_id		   NUMBER(15);
l_next_attr_id		   NUMBER(15);
l_next_blk_ovn             NUMBER(15);

-- 2905369 start
l_rev_application_set_id varchar2(1);
-- 2905369 end

TYPE v_app_set IS RECORD (
application_set_id            NUMBER (15));

TYPE r_app_set IS TABLE OF v_app_set
INDEX BY BINARY_INTEGER;

valid_app_set            r_app_set;
temp_app_set             r_app_set;
temp_app_set_drops       r_app_set;

TYPE cac_app_set IS RECORD (
application_set_id            NUMBER (15),
rec_totals                    NUMBER (15));

TYPE c_app_set IS TABLE OF cac_app_set
INDEX BY BINARY_INTEGER;

cached_app_set           c_app_set;

TYPE cac_tm_set IS RECORD (
application_set_id            NUMBER (15),
time_recipient_id             NUMBER (15));

TYPE c_tm_set IS TABLE OF cac_tm_set
INDEX BY BINARY_INTEGER;

cached_tm_set            c_tm_set;


TYPE v_tim_rec IS RECORD (
time_recipient_id             NUMBER (15));

TYPE r_tim_rec IS TABLE OF v_tim_rec
INDEX BY BINARY_INTEGER;

list_tim_rec_day         r_tim_rec;
list_tim_rec_det         r_tim_rec;
list_tim_rec_tc          r_tim_rec;
list_tim_rec_drops       r_tim_rec;

l_index                  BINARY_INTEGER;
l_index_tc               BINARY_INTEGER;
l_index_day              BINARY_INTEGER;
l_index_det              BINARY_INTEGER;
l_index_mess             BINARY_INTEGER;
l_ind_tim_rec_day        BINARY_INTEGER;
l_ind_tim_rec_det        BINARY_INTEGER;
l_ind_tim_rec_tc         BINARY_INTEGER;
l_index_tmp_app          BINARY_INTEGER;
l_index_tmp_rec          BINARY_INTEGER;
l_index_tim_rec_drops    BINARY_INTEGER;
l_index_drops            BINARY_INTEGER;
l_index_attr		    BINARY_INTEGER;
l_last_index 	    BINARY_INTEGER;
l_all_days_entered 	varchar2(10) := 'Y';

CURSOR csr_tm_sets
IS
SELECT DISTINCT application_set_id, time_recipient_id
	 FROM hxc_application_set_comps_v
     ORDER BY application_set_id;

CURSOR csr_app_set_id (p_app_set_id NUMBER)
IS
SELECT DISTINCT (application_set_id) a
	 FROM hxc_application_set_comps_v
	WHERE time_recipient_id IN
		    (SELECT DISTINCT (time_recipient_id)
				FROM hxc_application_set_comps_v
			       WHERE application_set_id =
							 p_app_set_id)
	  AND application_set_id NOT IN
		    (SELECT application_set_id a
		       FROM hxc_application_set_comps_v
		      WHERE time_recipient_id NOT IN
			       (SELECT DISTINCT (time_recipient_id)
					   FROM hxc_application_set_comps_v
					  WHERE application_set_id =
							 p_app_set_id));

CURSOR cache_app_set
IS
SELECT   application_set_id a, COUNT (*) cnt
  FROM hxc_application_set_comps_v
GROUP BY application_set_id;

CURSOR tm_rec_transfer(p_tbb_id NUMBER, p_tbb_ovn NUMBER, p_time_rec_id NUMBER)
IS
SELECT 'Y' status
  FROM sys.DUAL
 WHERE EXISTS ( SELECT htd.time_building_block_id, htd.time_building_block_ovn
		  FROM hxc_transaction_details htd,
		       hxc_transactions ht,
		       hxc_retrieval_processes hrp
		 WHERE ht.transaction_id = htd.transaction_id
		   AND ht.TYPE = 'RETRIEVAL'
		   AND ht.status = 'SUCCESS'
		   AND htd.status = 'SUCCESS'
		   AND ht.transaction_process_id = hrp.retrieval_process_id
		   AND hrp.time_recipient_id = p_time_rec_id
		   AND htd.time_building_block_id = p_tbb_id
	   AND htd.time_building_block_ovn = p_tbb_ovn);

    CURSOR c_get_dropped_attribs(p_tbb_id NUMBER, p_tbb_ovn NUMBER)
	 IS
	  SELECT   hta.attribute_category attribute_category, hta.attribute1 attribute1,
		   hta.attribute2 attribute2, hta.attribute3 attribute3,
		   hta.attribute4 attribute4, hta.attribute5 attribute5,
		   hta.attribute6 attribute6, hta.attribute7 attribute7,
		   hta.attribute8 attribute8, hta.attribute9 attribute9,
		   hta.attribute10 attribute10, hta.attribute11 attribute11,
		   hta.attribute12 attribute12, hta.attribute13 attribute13,
		   hta.attribute14 attribute14, hta.attribute15 attribute15,
		   hta.attribute16 attribute16, hta.attribute17 attribute17,
		   hta.attribute18 attribute18, hta.attribute19 attribute19,
		   hta.attribute20 attribute20, hta.attribute21 attribute21,
		   hta.attribute22 attribute22, hta.attribute23 attribute23,
		   hta.attribute24 attribute24, hta.attribute25 attribute25,
		   hta.attribute26 attribute26, hta.attribute27 attribute27,
		   hta.attribute28 attribute28, hta.attribute29 attribute29,
		   hta.attribute30 attribute30,
		   hta.bld_blk_info_type_id bld_blk_info_type_id,
		   hbbi.bld_blk_info_type bld_blk_info_type, hta.time_attribute_id
	    FROM hxc_time_attributes hta,
		 hxc_time_attribute_usages htau,
		 hxc_bld_blk_info_types hbbi
	   WHERE hta.time_attribute_id IN (SELECT hau.time_attribute_id
					     FROM hxc_time_attribute_usages hau
					    WHERE hau.time_building_block_id = p_tbb_id
					      AND hau.time_building_block_ovn =
									    p_tbb_ovn)
	     AND htau.time_attribute_id = hta.time_attribute_id
	     AND hbbi.bld_blk_info_type_id = hta.bld_blk_info_type_id
	     AND hta.attribute_category NOT LIKE ('SECURITY')
	ORDER BY hta.time_attribute_id ;


l_proc                   VARCHAR2 (30);
PROCEDURE create_reverse_entry(P_TIME_BUILDING_BLOCKS IN HXC_BLOCK_TABLE_TYPE,
			       P_TIME_ATTRIBUTES      IN OUT NOCOPY	HXC_ATTRIBUTE_TABLE_TYPE,
			       P_INDEX_BB		      IN BINARY_INTEGER)	AS
l_in_attr_st   binary_integer;
l_proc                   VARCHAR2 (30);
BEGIN

g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc  := 'create_reverse_entry';
	hr_utility.set_location('Processing '||l_proc, 10);
END if;
FOR c_get_att in c_get_dropped_attribs(P_TIME_BUILDING_BLOCKS (p_index_bb).TIME_BUILDING_BLOCK_ID,
				       P_TIME_BUILDING_BLOCKS (p_index_bb).OBJECT_VERSION_NUMBER)
LOOP
	l_in_attr_st := null;
	l_in_attr_st := P_TIME_ATTRIBUTES.first;
	while l_in_attr_st is not null
	LOOP
		if P_TIME_ATTRIBUTES(l_in_attr_st).time_attribute_id=c_get_att.time_attribute_id then
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE_CATEGORY	:=	c_get_att.ATTRIBUTE_CATEGORY;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE1	     	:=	c_get_att.ATTRIBUTE1;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE2	     	:=	c_get_att.ATTRIBUTE2;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE3	     	:=	c_get_att.ATTRIBUTE3;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE4	     	:=	c_get_att.ATTRIBUTE4;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE5	     	:=	c_get_att.ATTRIBUTE5;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE6	     	:=	c_get_att.ATTRIBUTE6;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE7	     	:=	c_get_att.ATTRIBUTE7;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE8	     	:=	c_get_att.ATTRIBUTE8;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE9	     	:=	c_get_att.ATTRIBUTE9;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE10	     	:=	c_get_att.ATTRIBUTE10;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE11	     	:=	c_get_att.ATTRIBUTE11;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE12	     	:=	c_get_att.ATTRIBUTE12;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE13	     	:=	c_get_att.ATTRIBUTE13;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE14	     	:=	c_get_att.ATTRIBUTE14;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE15	     	:=	c_get_att.ATTRIBUTE15;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE16	     	:=	c_get_att.ATTRIBUTE16;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE17	     	:=	c_get_att.ATTRIBUTE17;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE18	     	:=	c_get_att.ATTRIBUTE18;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE19	     	:=	c_get_att.ATTRIBUTE19;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE20	     	:=	c_get_att.ATTRIBUTE20;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE21	     	:=	c_get_att.ATTRIBUTE21;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE22	     	:=	c_get_att.ATTRIBUTE22;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE23	     	:=	c_get_att.ATTRIBUTE23;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE24	     	:=	c_get_att.ATTRIBUTE24;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE25	     	:=	c_get_att.ATTRIBUTE25;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE26	     	:=	c_get_att.ATTRIBUTE26;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE27	     	:=	c_get_att.ATTRIBUTE27;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE28	     	:=	c_get_att.ATTRIBUTE28;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE29	     	:=	c_get_att.ATTRIBUTE29;
			P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE30	     	:=	c_get_att.ATTRIBUTE30;
			IF g_debug then
			    hr_utility.trace('-----------------------------');
				hr_utility.trace('| ATTRIB_ID     |TBB ID           | BLD_BLK_INFO_TYPE|    ATTRIBUTE_CATEGORY |   A1 | A2 |  A3|  TBB_ID|    NEW|    CHANGED|');
				hr_utility.trace('-----------------------------');
				hr_utility.trace('|  '||P_TIME_ATTRIBUTES(l_in_attr_st).TIME_ATTRIBUTE_ID
						  ||'    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).BUILDING_BLOCK_ID
						  ||'     |   '||P_TIME_ATTRIBUTES(l_in_attr_st).BLD_BLK_INFO_TYPE
						  ||'    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE_CATEGORY
						  ||'    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE1
						  ||'    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE2
						  ||'    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).ATTRIBUTE3
						  || '    |  '||P_TIME_ATTRIBUTES(l_in_attr_st).BUILDING_BLOCK_ID
						  ||'    |   '||P_TIME_ATTRIBUTES(l_in_attr_st).NEW||'   |   '
						  ||P_TIME_ATTRIBUTES(l_in_attr_st).CHANGED);
			END if;
		end if;
		l_in_attr_st := P_TIME_ATTRIBUTES.NEXT(l_in_attr_st);
	end loop;

END LOOP;
if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
END if;
END create_reverse_entry;

BEGIN
-- Check if Entry Level Processing has been set or not
g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc  := 'set_time_bb_appl_set_id';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;
--
-- Issue a SavePoint
   savepoint set_time_bb_appl_set;
--
--if g_debug then
	-- hr_utility.trace('Entered..........'||p_pte_terg_id);
--end if;
if (p_pte_terg_id is not null) then
/*
-- ******************START TRACE SECTION***************************************
--
if g_debug then
	hr_utility.trace('*******BEFORE PROCESSING******');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('| TBB_ID     | APPL_SET_ID    |SCOPE |   OVN|   NEW|   CHANGED|');
	hr_utility.trace('-----------------------------');
	for x IN P_TIME_BUILDING_BLOCKS.first .. P_TIME_BUILDING_BLOCKS.last
	loop
	hr_utility.trace('|  '||P_TIME_BUILDING_BLOCKS(x).time_building_block_id||
			 '         |  '||P_TIME_BUILDING_BLOCKS(x).application_set_id||
			 '    |    '||p_time_building_blocks(x).SCOPE||'     |   '||
			 P_TIME_BUILDING_BLOCKS (x).object_version_number||'   | '||
			 P_TIME_BUILDING_BLOCKS(x).NEW||'    |   '||
			 P_TIME_BUILDING_BLOCKS(x).CHANGED);
	end loop;


	hr_utility.trace('-----------------------------');
	hr_utility.trace('| ATTRIB_ID     |TBB ID           | BLD_BLK_INFO_TYPE|    ATTRIBUTE_CATEGORY |   TBB_ID|    NEW|    CHANGED|');
	hr_utility.trace('-----------------------------');
	l_index := null;
	l_index := P_TIME_ATTRIBUTES.first;
	while l_index is not null
	loop

	hr_utility.trace('|  '||P_TIME_ATTRIBUTES(l_index).TIME_ATTRIBUTE_ID
			  ||'    |  '||P_TIME_ATTRIBUTES(l_index).BUILDING_BLOCK_ID
			  ||'     |   '||P_TIME_ATTRIBUTES(l_index).BLD_BLK_INFO_TYPE
			  ||'    |  '||P_TIME_ATTRIBUTES(l_index).ATTRIBUTE_CATEGORY
			  || '    |  '||P_TIME_ATTRIBUTES(l_index).BUILDING_BLOCK_ID
			  ||'    |   '||P_TIME_ATTRIBUTES(l_index).NEW||'   |   '
			  ||P_TIME_ATTRIBUTES(l_index).CHANGED);
	l_index := P_TIME_ATTRIBUTES.NEXT(l_index);
	end loop;


	hr_utility.trace('-----------------------------');
	hr_utility.trace('| MESSAGE_LEVEL     | message_name|    TBB_OVN |   TBB_ID');
	hr_utility.trace('-----------------------------');
	for x IN P_MESSAGES.first .. P_MESSAGES.last
	loop
	hr_utility.trace('|  '||P_MESSAGES(x).MESSAGE_LEVEL||'         |  '
			  ||P_messages(x).message_name||'    |  '
			  ||p_messages(x).time_building_block_ovn|| '    |  '
			  ||p_messages(x).time_building_block_id);
	end loop;
end if;
-- ************* END TRACE SECTION*************************************************
*/

-- do processing of message table
-- to derive and set the application set id along with the TBB
--
-- First cache all valid Appl Sets that can be set
-- using a temp table, here to have better performance
--
l_index := 1;
--
--if g_debug then
	-- hr_utility.trace('p_application_set_id'||p_application_set_id);
--end if;
--
FOR appl_set IN csr_app_set_id(p_application_set_id) LOOP

--
-- Get all the sub sets of the
-- current application set attached to
-- the resource preference, and use them to populate the
-- temporary table 'valid_app_set'
--

valid_app_set(l_index).application_set_id := appl_set.A;

l_index := l_index+1;
END LOOP;

-- Here cache the application sets with the count of Time recipients
-- attached to them and populate the
-- temporary table 'cached_app_set'
-- which will be used for all further processing
--
l_index := 0;

FOR appl_set IN cache_app_set
LOOP
 --
 cached_app_set (l_index).application_set_id := appl_set.a;
 cached_app_set (l_index).rec_totals := appl_set.cnt;
 l_index :=   l_index
	    + 1;
END LOOP; -- appl_set IN cache_app_set


-- Here cache the application sets with the Time recipients
-- attached to them and populate the
-- temporary table 'cached_tm_set'
-- which will be used for all further processing
--
l_index := 0;

FOR tm_rec IN csr_tm_sets
LOOP
 --
 cached_tm_set (l_index).application_set_id :=
					    tm_rec.application_set_id;
 cached_tm_set (l_index).time_recipient_id :=
					     tm_rec.time_recipient_id;
 l_index :=   l_index
	    + 1;
END LOOP; -- appl_set IN cache_app_set

-- if g_debug then
	--hr_utility.trace('cached_tm_set.COUNT'||cached_tm_set.COUNT);
-- end if;
--

-- here starts the real processing

-- Initialize to read the global timecard object
--
l_index_tc := NULL;
l_index_tc := P_TIME_BUILDING_BLOCKS.FIRST;

WHILE l_index_tc IS NOT NULL
LOOP
 IF (P_TIME_BUILDING_BLOCKS (l_index_tc).scope = 'TIMECARD')
 THEN

-- Initialize the Temp Time Recipient table
-- for SCOPE = 'TIMECARD' to null.
--
    IF (list_tim_rec_tc.COUNT > 0)
    THEN
       list_tim_rec_tc.DELETE;
    END IF;

    l_index_day := NULL;
    l_index_day := P_TIME_BUILDING_BLOCKS.FIRST;

    WHILE l_index_day IS NOT NULL
    LOOP
       IF (    P_TIME_BUILDING_BLOCKS (l_index_day).scope = 'DAY'
	   AND P_TIME_BUILDING_BLOCKS (l_index_day).parent_building_block_id =
		       P_TIME_BUILDING_BLOCKS (l_index_tc).time_building_block_id
	   AND P_TIME_BUILDING_BLOCKS (l_index_day).parent_building_block_ovn =
			P_TIME_BUILDING_BLOCKS (l_index_tc).object_version_number
	  )
       THEN

-- Initialize the Temp Time Recipient table
-- for SCOPE = 'DAY' to null.
--

	  IF (list_tim_rec_day.COUNT > 0)
	  THEN
	     list_tim_rec_day.DELETE;
	  END IF;

	  l_index_det := NULL;
	  l_index_det := P_TIME_BUILDING_BLOCKS.FIRST;


-- Check for existing DETIALS for the current DAY
	  WHILE l_index_det IS NOT NULL
	  LOOP
	     IF (    P_TIME_BUILDING_BLOCKS (l_index_det).scope = 'DETAIL'
		 AND P_TIME_BUILDING_BLOCKS (l_index_det).parent_building_block_id =
			   P_TIME_BUILDING_BLOCKS (l_index_day).time_building_block_id
		 AND P_TIME_BUILDING_BLOCKS (l_index_det).parent_building_block_ovn =
			   P_TIME_BUILDING_BLOCKS (l_index_day).object_version_number
		 AND P_TIME_BUILDING_BLOCKS (l_index_det).DATE_TO = fnd_date.date_to_canonical(hr_general.end_of_time)
		 AND P_TIME_BUILDING_BLOCKS (l_index_det).OBJECT_VERSION_NUMBER <> -9999
		)
	     THEN

-- Initialize the Temp Time Recipient table
-- for SCOPE = 'DETAIL' to null.
--

		IF (list_tim_rec_det.COUNT > 0)
		THEN
		   list_tim_rec_det.DELETE;
		END IF;


-- Initialize the Temp Time Recipient drops table
-- for SCOPE = 'DETAIL' to null.
--
		IF (list_tim_rec_drops.COUNT > 0)
		THEN
		   list_tim_rec_drops.DELETE;
		END IF;


		-- Start processing the message table to get the
		-- Time recipient for the DETAIL BB_ID

		l_index_mess := NULL;
		l_index_mess := p_messages.FIRST;

		WHILE l_index_mess IS NOT NULL
		LOOP

		   IF ( p_messages (l_index_mess).message_level =
								'PTE'
		       AND p_messages (l_index_mess).time_building_block_id =
			      P_TIME_BUILDING_BLOCKS (l_index_det).time_building_block_id
		       AND (p_messages (l_index_mess).time_building_block_ovn - 1) =
			      P_TIME_BUILDING_BLOCKS (l_index_det).object_version_number
		      )
		   THEN


		      -- populating for SCOPE = DETAIL

		      time_rec_present := 'N';

		      IF (list_tim_rec_det.COUNT > 0)
		      THEN
			 FOR x IN
			     list_tim_rec_det.FIRST .. list_tim_rec_det.LAST
			 LOOP
			    IF (p_messages (l_index_mess).message_name =
				   list_tim_rec_det (x).time_recipient_id
			       )
			    THEN
			       time_rec_present := 'Y';
			    END IF; -- check if Time Recipient is already present
			 END LOOP; -- x IN list_tim_rec_det

			 -- get the index to point to the last record, in case we need
			 -- to insert
			 l_ind_tim_rec_det :=
					     list_tim_rec_det.LAST
					   + 1;
		      ELSE -- no records in list_tim_rec_day
			 l_ind_tim_rec_det := 0;
		      END IF; --  list_tim_rec_det.COUNT > 0

		      IF (time_rec_present = 'N')
		      THEN

			 list_tim_rec_det (l_ind_tim_rec_det).time_recipient_id :=
			       p_messages (l_index_mess).message_name;
		      END IF; -- time_rec_present = 'N'

		      -- end population for SCOPE = DETAIL

		      -- Now, populate the time recipinets table for DAY n TIMECARD
		      -- first check if id is already present in the table or not

		      -- populating for SCOPE = DAY

		      time_rec_present := 'N';

		      IF (list_tim_rec_day.COUNT > 0)
		      THEN
			 FOR x IN
			     list_tim_rec_day.FIRST .. list_tim_rec_day.LAST
			 LOOP
			    IF (p_messages (l_index_mess).message_name =
				   list_tim_rec_day (x).time_recipient_id
			       )
			    THEN
			       time_rec_present := 'Y';
			    END IF; -- check if Time Recipient is already present
			 END LOOP; -- x IN list_tim_rec_day

			 -- get the index to point to the last record, in case we need
			 -- to insert
			 l_ind_tim_rec_day :=
					     list_tim_rec_day.LAST
					   + 1;
		      ELSE -- no records in list_tim_rec_day
			 l_ind_tim_rec_day := 0;
		      END IF; --  list_tim_rec_day.COUNT > 0

		      IF (time_rec_present = 'N')
		      THEN
			 list_tim_rec_day (l_ind_tim_rec_day).time_recipient_id :=
			       p_messages (l_index_mess).message_name;
		      END IF; -- time_rec_present = 'N'

		      -- end population for SCOPE = DAY

		      -- populating for SCOPE = TIMECARD

		      time_rec_present := 'N';

		      IF (list_tim_rec_tc.COUNT > 0)
		      THEN
			 FOR x IN
			     list_tim_rec_tc.FIRST .. list_tim_rec_tc.LAST
			 LOOP
			    IF (p_messages (l_index_mess).message_name =
				   list_tim_rec_tc (x).time_recipient_id
			       )
			    THEN
			       time_rec_present := 'Y';
			    END IF; -- check if Time Recipient is already present
			 END LOOP; -- x IN list_tim_rec_day

			 -- get the index to point to the last record, in case we need
			 -- to insert
			 l_ind_tim_rec_tc :=
					      list_tim_rec_tc.LAST
					    + 1;
		      ELSE --  no records in list_tim_rec_day
			 l_ind_tim_rec_tc := 0;
		      END IF; --  list_tim_rec_tc.COUNT > 0

		      IF (time_rec_present = 'N')
		      THEN
			 list_tim_rec_tc (l_ind_tim_rec_tc).time_recipient_id :=
			       p_messages (l_index_mess).message_name;
		      END IF; -- time_rec_present = 'N'

		   -- end population for SCOPE = TIMECARD


		   END IF; -- Message Table level = PTE and match for TBB_ID

		   l_index_mess := p_messages.NEXT (l_index_mess);
		END LOOP; --  l_index_mess is not null


-- Start DETAIL's Time Recipient table processing
-- in order to set the DETAIL SCOPE Application Set ID
--

		-- Initialize a new temproary table to
		-- derive the application set id  :-)
		-- Populate it using the cached Application Set Table
		-- i.e. table 'cached_app_set'

		IF (temp_app_set.COUNT > 0)
		THEN
		   temp_app_set.DELETE;
		END IF;

		l_index := 0;

		l_index_tmp_app := NULL;
		l_index_tmp_app := cached_app_set.FIRST;

		WHILE l_index_tmp_app IS NOT NULL
		LOOP

		   IF (cached_app_set (l_index_tmp_app).rec_totals =
					       list_tim_rec_det.COUNT
		      )
		   THEN
		      temp_app_set (l_index).application_set_id :=
			    cached_app_set (l_index_tmp_app).application_set_id;
		      l_index :=   l_index
				 + 1;
		   END IF;

		   l_index_tmp_app :=
				 cached_app_set.NEXT (l_index_tmp_app);
		END LOOP; -- l_index_tmp_app IS NOT NULL


-- Now check for individual Time Recipients

		l_index_tmp_app := NULL;
		l_index_tmp_app := temp_app_set.FIRST;

		WHILE l_index_tmp_app IS NOT NULL
		LOOP
		   app_set_ok := 'Y';

		l_index_tmp_rec := NULL;
		l_index_tmp_rec := cached_tm_set.FIRST;


		   WHILE l_index_tmp_rec IS NOT NULL

		   LOOP

		      IF (cached_tm_set (l_index_tmp_rec).application_set_id =
			     temp_app_set (l_index_tmp_app).application_set_id
			 )
		      THEN
			 time_rec_present := 'N';

			 --

			 FOR x IN
			     list_tim_rec_det.FIRST .. list_tim_rec_det.LAST
			 LOOP

			    IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
				   list_tim_rec_det (x).time_recipient_id
			       )
			    THEN
			       time_rec_present := 'Y';
			    END IF;
			 END LOOP; -- x IN temp_app_set

			 IF (time_rec_present = 'N')
			 THEN
			    app_set_ok := 'N';
			 END IF;
		      END IF; -- match for same appl set in both tables as same

		      l_index_tmp_rec :=
				  cached_tm_set.NEXT (l_index_tmp_rec);
		   END LOOP; --  l_index_tmp_rec  is not null

		   -- Check flag to delete or not to delete
		   IF (app_set_ok = 'N')
		   THEN
		      temp_app_set.DELETE (l_index_tmp_app);
		   END IF;

		   l_index_tmp_app :=
				   temp_app_set.NEXT (l_index_tmp_app);
		END LOOP; -- l_index_tmp_app is not null


		l_index := NULL;
		l_index := temp_app_set.FIRST;
-- 115.6 start

		l_null_application_set_id := 'N';
		if (temp_app_set.COUNT = 0)
		then
		l_null_application_set_id := 'Y';
		l_index := 0;
		temp_app_set (l_index).application_set_id := -999999;
--		if g_debug then
			--hr_utility.trace('ks ...nulled and temp_app_set (l_index).application_set_id = '||temp_app_set (l_index).application_set_id);
--		end if;
		end if;

-- 115.6 end
 -- Check to see if the application set id that is
		-- to be set is a subset of the main Preference level
		-- then only update
		-- here check that this falls in the temp appl set ids table

		app_set_ok := 'N';


		FOR x IN valid_app_set.FIRST .. valid_app_set.LAST
		LOOP
-- 115.6
		 IF(l_null_application_set_id = 'N') then
		   IF (temp_app_set (l_index).application_set_id =
				 valid_app_set (x).application_set_id
		      )
		   THEN
		      app_set_ok := 'Y';
		   END IF;
		 END IF; -- l_null_application_set_id = 'N'
		END LOOP;
-- 115.6 start
	IF(l_null_application_set_id = 'Y') then
	 app_set_ok := 'Y';
	END IF;
-- 115.6 end

		-- if application set Id is not in the temp
		-- table of application set Ids then
		-- raise an error as the time recipient is not contained in
		-- the application set id attached to the resource preference
		IF (app_set_ok = 'N')
		THEN
-- 115.6
		   hxc_time_entry_rules_utils_pkg.add_error_to_table (
			   p_message_table => p_messages
		   ,       p_message_name  => 'HXC_VLD_ELP_VIOLATION'
		   ,       p_message_token => NULL
		   ,       p_message_level => 'ERROR'
		   ,       p_message_field => NULL
		   ,       p_application_short_name => 'HXC'
		   ,       p_timecard_bb_id     => null
		   ,       p_time_attribute_id  => NULL
		   ,       p_timecard_bb_ovn       => null
		   ,       p_time_attribute_ovn    => NULL );

		ELSE -- update the application set id on the TBB
		   -- here one more check has to be made for checkin if
		   -- already some application set id is present or not
		   -- in which case all time transfer etc needs to be
		   -- checked, postponing that check for now, will add laterz


-- adding check...
IF(P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id is not null
   AND P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id <>
   temp_app_set (l_index).application_set_id)
 Then
-- Initialize the Temp Time Recipient drops table
-- for SCOPE = 'DETAIL' to null.
--
		IF (list_tim_rec_drops.COUNT > 0)
		THEN
		   list_tim_rec_drops.DELETE;
		END IF;

l_index_tim_rec_drops := 0;

	  l_index_tmp_rec := NULL;
	  l_index_tmp_rec := cached_tm_set.FIRST;
--
--
	     WHILE l_index_tmp_rec IS NOT NULL
--
	     LOOP
		IF (cached_tm_set (l_index_tmp_rec).application_set_id =
		       P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id
		   )
		THEN
		   time_rec_present := 'N';
--
		   --
-- 115.6
		 l_index := null;
		 l_index := list_tim_rec_det.FIRST;
		   While l_index IS NOT NULL
  		    LOOP
		      IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
			     list_tim_rec_det (l_index).time_recipient_id
			 )
		      THEN
			 time_rec_present := 'Y';
		      END IF;
		     l_index :=  list_tim_rec_det.NEXT (l_index);
		   END LOOP; -- l_index IS NOT NULL

		   IF (time_rec_present = 'N')
		   THEN
-- if g_debug then
	--hr_utility.trace(' Yes drops and dropped timerecid ='||cached_tm_set (l_index_tmp_rec).time_recipient_id);
	-- addding 115.5
	-- check here first that if time has been transferred to
	-- this time recipinet.
	-- hr_utility.trace(' Now to check if time transfer has taken place for this Dropped TimeRec or not....');
--end if;
--
time_rec_transfer := null;
--
	OPEN tm_rec_transfer(P_TIME_BUILDING_BLOCKS (l_index_det).time_building_block_id,P_TIME_BUILDING_BLOCKS (l_index_det).object_version_number,cached_tm_set (l_index_tmp_rec).time_recipient_id);
	FETCH tm_rec_transfer into time_rec_transfer;
	CLOSE tm_rec_transfer;
	IF( 'Y' = time_rec_transfer)
	 THEN
-- if g_debug then
	-- hr_utility.trace(' Yes there is a drop n the time transfer has taken palce.... and recp id = '||cached_tm_set (l_index_tmp_rec).time_recipient_id);
-- end if;

		    list_tim_rec_drops(l_index_tim_rec_drops).time_recipient_id :=
		    	cached_tm_set (l_index_tmp_rec).time_recipient_id;
		    l_index_tim_rec_drops := l_index_tim_rec_drops +1;

	-- Also add the dropped timce recipient to the DAY n TIMECARD Scopes Tables

     -- populating for SCOPE = DAY when drop is occured
                              time_rec_present := 'N';

                              IF (list_tim_rec_day.COUNT > 0)
                              THEN
                                 FOR x IN
                                     list_tim_rec_day.FIRST .. list_tim_rec_day.LAST
                                 LOOP
                                    IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
                                           list_tim_rec_day (x).time_recipient_id
                                       )
                                    THEN
           --                           if g_debug then
	   --					hr_utility.trace (
           --                               ' yes TR present in DAY'
           --                            );
	   --				end if;
                                       time_rec_present := 'Y';
                                    END IF; -- check if Time Recipient is already present
                                 END LOOP; -- x IN list_tim_rec_day

                                 -- get the index to point to the last record, in case we need
                                 -- to insert
                                 l_ind_tim_rec_day :=
                                                     list_tim_rec_day.LAST
                                                   + 1;
                              ELSE -- no records in list_tim_rec_day
                                 l_ind_tim_rec_day := 0;
                              END IF; --  list_tim_rec_day.COUNT > 0

                              IF (time_rec_present = 'N')
                              THEN
	--                      if g_debug then
					--hr_utility.trace ('poop');
	--			end if;
                                 list_tim_rec_day (l_ind_tim_rec_day).time_recipient_id :=
                                       cached_tm_set (l_index_tmp_rec).time_recipient_id;
                              END IF; -- time_rec_present = 'N'

                              -- end population for SCOPE = DAY   when drop has occured


	    -- populating for SCOPE = TIMECARD and drop has occured

	                    time_rec_present := 'N';

                              IF (list_tim_rec_tc.COUNT > 0)
                              THEN
                                 FOR x IN
                                     list_tim_rec_tc.FIRST .. list_tim_rec_tc.LAST
                                 LOOP
                                    IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
                                           list_tim_rec_tc (x).time_recipient_id
                                       )
                                    THEN
                                       time_rec_present := 'Y';
                                    END IF; -- check if Time Recipient is already present
                                 END LOOP; -- x IN list_tim_rec_day

                                 -- get the index to point to the last record, in case we need
                                 -- to insert
                                 l_ind_tim_rec_tc :=
                                                      list_tim_rec_tc.LAST
                                                    + 1;
                              ELSE --  no records in list_tim_rec_day
                                 l_ind_tim_rec_tc := 0;
                              END IF; --  list_tim_rec_tc.COUNT > 0

                              IF (time_rec_present = 'N')
                              THEN
                                 list_tim_rec_tc (l_ind_tim_rec_tc).time_recipient_id :=
                                       cached_tm_set (l_index_tmp_rec).time_recipient_id;
                              END IF; -- time_rec_present = 'N'

                           -- end population for SCOPE = TIMECARD and drop has occured
--

		END IF; -- 'Y' = time_rec_transfer , The cond that this time rec has been transferred.
--
		   END IF; -- time_rec_present = 'N'
		END IF; -- match for same appl set in both tables as same
--
		l_index_tmp_rec :=
			    cached_tm_set.NEXT (l_index_tmp_rec);
	END LOOP; --  l_index_tmp_rec  is not null

     END IF; -- P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id is not null...

-- IT is here that i check for the drops table
-- and add new rows for TBB and ATTribs
-- 2905369 adding flag to determine if reversing entry is done or not..
l_rev_application_set_id := 'N';

IF ( list_tim_rec_drops.COUNT > 0 )
THEN
-- Start DROPS's Time Recipient table processing
-- in order to get the Application Set ID


	  -- Initialize a new temproary table to
	  -- derive the application set id :-)
	  -- Populate it using the cached Application Set Table
	  -- i.e. table 'cached_app_set'

	  IF (temp_app_set_drops.COUNT > 0)
	  THEN
	     temp_app_set_drops.DELETE;
	  END IF;

	  l_index_drops := 0;

	  l_index_tmp_app := NULL;
	  l_index_tmp_app := cached_app_set.FIRST;

	  WHILE l_index_tmp_app IS NOT NULL
	  LOOP
	     IF (cached_app_set (l_index_tmp_app).rec_totals =
					       list_tim_rec_drops.COUNT
		)
	     THEN
		temp_app_set_drops(l_index_drops).application_set_id :=
		      cached_app_set (l_index_tmp_app).application_set_id;
		l_index_drops :=   l_index_drops
			   + 1;
	     END IF;

	     l_index_tmp_app := cached_app_set.NEXT (l_index_tmp_app);
	  END LOOP; -- l_index_tmp_app IS NOT NULL

-- Now check for individual Time Recipients

	  l_index_tmp_app := NULL;
	  l_index_tmp_app := temp_app_set_drops.FIRST;

	  WHILE l_index_tmp_app IS NOT NULL
	  LOOP
	     app_set_ok := 'Y';


	  l_index_tmp_rec := NULL;
	  l_index_tmp_rec := cached_tm_set.FIRST;


	     WHILE l_index_tmp_rec IS NOT NULL
	     LOOP
		IF (cached_tm_set (l_index_tmp_rec).application_set_id =
			  temp_app_set_drops (l_index_tmp_app).application_set_id
		   )
		THEN
		   time_rec_present := 'N';

		   --
		   FOR x IN
		       list_tim_rec_drops.FIRST .. list_tim_rec_drops.LAST
		   LOOP
		      IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
			       list_tim_rec_drops(x).time_recipient_id
			 )
		      THEN
			 time_rec_present := 'Y';
		      END IF;
		   END LOOP; -- x IN temp_app_set

		   IF (time_rec_present = 'N')
		   THEN
		      app_set_ok := 'N';
		   END IF;
		END IF; -- match for same appl set in both tables as same

		l_index_tmp_rec :=
				  cached_tm_set.NEXT (l_index_tmp_rec);
	     END LOOP; --  l_index_tmp_rec  is not null

	     --Check flag to delete or not to delete

	     IF (app_set_ok = 'N')
	     THEN
		temp_app_set_drops.DELETE (l_index_tmp_app);
	     END IF;

	     l_index_tmp_app := temp_app_set_drops.NEXT (l_index_tmp_app);
	  END LOOP; -- l_index_tmp_app is not null

	  l_index_drops := NULL;
	  l_index_drops := temp_app_set_drops.FIRST;

-- Check to see if the application set id that is
-- to be set is a subset of the main Preference level
-- then only update
-- here check that this falls in the temp appl set ids table
	  app_set_ok := 'N';

	  FOR x IN valid_app_set.FIRST .. valid_app_set.LAST
	  LOOP
	     IF (temp_app_set_drops(l_index_drops).application_set_id =
				 valid_app_set (x).application_set_id
		)
	     THEN
		app_set_ok := 'Y';
	     END IF;
	  END LOOP;

	  -- if application set Id is not in the temp
	  -- table of application set Ids then
	  -- raise an error as the time recipient is not contained in
	  -- the application set id attached to the resource preference
	  IF (app_set_ok = 'N')
	  THEN
-- 115.6
		   hxc_time_entry_rules_utils_pkg.add_error_to_table (
			   p_message_table => p_messages
		   ,       p_message_name  => 'HXC_VLD_ELP_VIOLATION'
		   ,       p_message_token => NULL
		   ,       p_message_level => 'ERROR'
		   ,       p_message_field => NULL
		   ,       p_application_short_name => 'HXC'
		   ,       p_timecard_bb_id     => null
		   ,       p_time_attribute_id  => NULL
		   ,       p_timecard_bb_ovn       => null
		   ,       p_time_attribute_ovn    => NULL );
	  ELSE

       -- and now finally ADD NEW ROWS FOR DROPS IN TBB AND ATTRIBS
--		  if g_debug then
			--hr_utility.trace('ADDING.....ROWS HERE....DROPS IN ELP SEEN');
--		  end if;

       -- Initilaize the index etc to pop
-- 115.7
-- removing the addition to collection and instead calling the api proc directly
-- 115.8 2905369 start
-- Again going to use collection and commenting the call to the api proc.


       l_next_blk_id := HXC_TIMECARD_BLOCK_UTILS.NEXT_BLOCK_ID(P_TIME_BUILDING_BLOCKS);

       l_index:=null;
       l_index := P_TIME_BUILDING_BLOCKS.last;
       l_index := l_index +1;

       --
       -- Insert the new building block record
       --
       -- The application set id for this will be the latest valid application set id
       --
       l_last_index := null;
       l_last_index := temp_app_set.FIRST;

-- Fix for Bug 3025823
-- check if current application set id needs to be null

 if(l_null_application_set_id = 'N')
 then
 P_TIME_BUILDING_BLOCKS.extend();
 	       P_TIME_BUILDING_BLOCKS(l_index)    :=
 	       				HXC_BLOCK_TYPE
 	       				 (l_next_blk_id
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).TYPE
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).MEASURE
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).UNIT_OF_MEASURE
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).START_TIME
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).STOP_TIME
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_IS_NEW
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).SCOPE
 				          ,-9999
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STATUS
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_TYPE
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STYLE_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).DATE_FROM
 				          ,fnd_date.date_to_canonical(hr_general.end_of_time)
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).COMMENT_TEXT
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_OVN
 				          ,'Y'
 				          ,'N'
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PROCESS
 				          ,temp_app_set (l_last_index).application_set_id
                                          ,P_TIME_BUILDING_BLOCKS (l_index_det).TRANSLATION_DISPLAY_KEY
 				          );
 else
 P_TIME_BUILDING_BLOCKS.extend();
 	       P_TIME_BUILDING_BLOCKS(l_index)    :=
 	       				HXC_BLOCK_TYPE
 	       				 (l_next_blk_id
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).TYPE
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).MEASURE
 	       				  ,P_TIME_BUILDING_BLOCKS (l_index_det).UNIT_OF_MEASURE
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).START_TIME
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).STOP_TIME
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_IS_NEW
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).SCOPE
 				          ,-9999
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STATUS
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_TYPE
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STYLE_ID
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).DATE_FROM
 				          ,fnd_date.date_to_canonical(hr_general.end_of_time)
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).COMMENT_TEXT
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_OVN
 				          ,'Y'
 				          ,'N'
 				          ,P_TIME_BUILDING_BLOCKS (l_index_det).PROCESS
 				          ,null
                                          ,P_TIME_BUILDING_BLOCKS (l_index_det).TRANSLATION_DISPLAY_KEY
 				          );
 end if; -- l_null_application_set_id = 'N'

-- 115.8 2905369
-- Now change the information on the current
-- detail TBB here itself, in effect just get to end date it
-- with the application set id as the one for dropped time recipients.
--
l_next_blk_ovn := 1;
P_TIME_BUILDING_BLOCKS (l_index_det).MEASURE := null;
P_TIME_BUILDING_BLOCKS (l_index_det).DATE_TO := fnd_date.date_to_canonical(sysdate);
-- ksethi fix for bug 3831067
-- Comment the following line.
-- P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id := temp_app_set_drops(l_index_drops).application_set_id;
l_rev_application_set_id := 'Y';
--
-- end change for current details block.... 2905369 end

-- 115.8 comment the following call to API and instead using above collection.

/*
l_next_blk_id  := null;
l_next_blk_ovn := null;

-- call the create_reversing_entry directly.....
-- to insert this reversed TBB in the db

 hxc_building_block_api.create_reversing_entry
   (p_effective_date            => sysdate
   ,p_type                      => P_TIME_BUILDING_BLOCKS (l_index_det).TYPE
   ,p_measure                   => P_TIME_BUILDING_BLOCKS (l_index_det).MEASURE
   ,p_unit_of_measure           => P_TIME_BUILDING_BLOCKS (l_index_det).UNIT_OF_MEASURE
   ,p_start_time                => hxc_timecard_block_utils.date_value(P_TIME_BUILDING_BLOCKS (l_index_det).START_TIME)
   ,p_stop_time                 => hxc_timecard_block_utils.date_value(P_TIME_BUILDING_BLOCKS (l_index_det).STOP_TIME)
   ,p_parent_building_block_id  => P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_ID
   ,p_parent_building_block_ovn => P_TIME_BUILDING_BLOCKS (l_index_det).PARENT_BUILDING_BLOCK_OVN
   ,p_scope                     => P_TIME_BUILDING_BLOCKS (l_index_det).SCOPE
   ,p_approval_style_id         => P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STYLE_ID
   ,p_approval_status           => P_TIME_BUILDING_BLOCKS (l_index_det).APPROVAL_STATUS
   ,p_resource_id               => P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_ID
   ,p_resource_type             => P_TIME_BUILDING_BLOCKS (l_index_det).RESOURCE_TYPE
   ,p_comment_text              => P_TIME_BUILDING_BLOCKS (l_index_det).COMMENT_TEXT
   ,p_application_set_id        => temp_app_set_drops(l_index_drops).application_set_id
   ,p_date_to                   => sysdate
   ,p_time_building_block_id    => l_next_blk_id
   ,p_object_version_number     => l_next_blk_ovn
   );
*/
       -- Now for attributes

      l_index :=null;
      l_index := P_TIME_ATTRIBUTES.last;
      l_index := l_index +1;

-- start 2986524
-- 115.10 Reverting the change of 115.6 moving back to add current
-- attributes no need for old attributes now.
-- 115.6
      l_last_index := null;
      l_last_index := P_TIME_ATTRIBUTES.last;

      --
      -- Insert the new attribute records
      --

      l_index_attr := null;
      l_index_attr := P_TIME_ATTRIBUTES.FIRST;
-- 115.11 Fix for 2995655
-- commenting the P_TIME_ATTRIBUTES(l_index_attr).BUILDING_BLOCK_OVN part of if condition
      While l_index_attr is NOT NULL
      LOOP
      IF(P_TIME_ATTRIBUTES(l_index_attr).BUILDING_BLOCK_ID = P_TIME_BUILDING_BLOCKS (l_index_det).TIME_BUILDING_BLOCK_ID
	-- and P_TIME_ATTRIBUTES(l_index_attr).BUILDING_BLOCK_OVN = P_TIME_BUILDING_BLOCKS (l_index_det).OBJECT_VERSION_NUMBER)
	)
       THEN

-- Commenting the below
-- for 2986524
-- no need of this cursor now.
--
--	FOR c_get_att in c_get_dropped_attribs(P_TIME_BUILDING_BLOCKS (l_index_det).TIME_BUILDING_BLOCK_ID,
--					       P_TIME_BUILDING_BLOCKS (l_index_det).OBJECT_VERSION_NUMBER)
--
--	LOOP

	l_next_attr_id := HXC_TIMECARD_ATTRIBUTE_UTILS.NEXT_TIME_ATTRIBUTE_ID(P_TIME_ATTRIBUTES);

-- Commenting population from cursor and instead adding current attributes.
--
/*
P_TIME_ATTRIBUTES.extend();
	      P_TIME_ATTRIBUTES(l_index) :=
	      		HXC_ATTRIBUTE_TYPE
	      		(l_next_attr_id
			,l_next_blk_id
			,c_get_att.ATTRIBUTE_CATEGORY
			,c_get_att.ATTRIBUTE1
			,c_get_att.ATTRIBUTE2
			,c_get_att.ATTRIBUTE3
			,c_get_att.ATTRIBUTE4
			,c_get_att.ATTRIBUTE5
			,c_get_att.ATTRIBUTE6
			,c_get_att.ATTRIBUTE7
			,c_get_att.ATTRIBUTE8
			,c_get_att.ATTRIBUTE9
			,c_get_att.ATTRIBUTE10
			,c_get_att.ATTRIBUTE11
			,c_get_att.ATTRIBUTE12
			,c_get_att.ATTRIBUTE13
			,c_get_att.ATTRIBUTE14
			,c_get_att.ATTRIBUTE15
			,c_get_att.ATTRIBUTE16
			,c_get_att.ATTRIBUTE17
			,c_get_att.ATTRIBUTE18
			,c_get_att.ATTRIBUTE19
			,c_get_att.ATTRIBUTE20
			,c_get_att.ATTRIBUTE21
			,c_get_att.ATTRIBUTE22
			,c_get_att.ATTRIBUTE23
			,c_get_att.ATTRIBUTE24
			,c_get_att.ATTRIBUTE25
			,c_get_att.ATTRIBUTE26
			,c_get_att.ATTRIBUTE27
			,c_get_att.ATTRIBUTE28
			,c_get_att.ATTRIBUTE29
			,c_get_att.ATTRIBUTE30
			,c_get_att.BLD_BLK_INFO_TYPE_ID
			,1
			,'Y'
			,'N'
			,c_get_att.BLD_BLK_INFO_TYPE
			,'Y' -- PROCESS Flag
			,l_next_blk_ovn
			);
*/
--
-- Adding population from current structure
--
P_TIME_ATTRIBUTES.extend();
	      P_TIME_ATTRIBUTES(l_index) :=
	      		HXC_ATTRIBUTE_TYPE
	      		(l_next_attr_id
			,l_next_blk_id
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE_CATEGORY
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE1
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE2
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE3
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE4
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE5
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE6
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE7
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE8
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE9
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE10
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE11
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE12
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE13
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE14
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE15
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE16
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE17
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE18
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE19
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE20
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE21
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE22
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE23
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE24
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE25
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE26
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE27
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE28
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE29
			,P_TIME_ATTRIBUTES(l_index_attr).ATTRIBUTE30
			,P_TIME_ATTRIBUTES(l_index_attr).BLD_BLK_INFO_TYPE_ID
			,1
			,'Y'
			,'N'
			,P_TIME_ATTRIBUTES(l_index_attr).BLD_BLK_INFO_TYPE
			,P_TIME_ATTRIBUTES(l_index_attr).PROCESS
			,1
			);

--
      l_index:= l_index+1;
--
      END IF; -- P_TIME_ATTRIBUTES(l_index_attr).BUILDING_BLOCK_ID = P_TIME_BUILDING_BLOCKS
--
       l_index_attr := P_TIME_ATTRIBUTES.NEXT(l_index_attr);
--

--Bug 3025823  Sonarasi 26-Jun-2003
--Commenting the following line. If this line is not commented then the loop
--would not be executed for the last iteration. Since we want the loop to be completely
--executed, we are commenting this line.
      --EXIT WHEN l_index_attr = l_last_index;
--Bug 3025823  Sonarasi 26-Jun-2003 Over

      END LOOP; -- end loop for l_index_attr not null -- Ignore -> FOR c_get_att in c_get_dropped_attribs

-- Bug 4644401 Sechandr 22-Nov-2005
-- calling this procedure to restore the old attributes in the end date TBB detail row if there is an updation on the timeccard.
create_reverse_entry(P_TIME_BUILDING_BLOCKS,P_TIME_ATTRIBUTES,l_index_det);

 END IF; -- app_set_ok = 'N'

/*
-- ****************** CHECKS for STRUCTURE After DROPS ******************
if g_debug then
	hr_utility.trace('*******POST DROPS STATS******');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('| TBB_ID     | APPL_SET_ID    |SCOPE |   OVN|   NEW|   CHANGED|');
	hr_utility.trace('-----------------------------');
	for x IN P_TIME_BUILDING_BLOCKS.first .. P_TIME_BUILDING_BLOCKS.last
	loop
	hr_utility.trace('|  '
			 ||P_TIME_BUILDING_BLOCKS(x).time_building_block_id
			 ||'         |  '||P_TIME_BUILDING_BLOCKS(x).application_set_id
			 ||'    |    '||p_time_building_blocks(x).SCOPE||'     |   '
			 ||P_TIME_BUILDING_BLOCKS (x).object_version_number||'   | '
			 ||P_TIME_BUILDING_BLOCKS(x).NEW||'    |   '
			 ||P_TIME_BUILDING_BLOCKS(x).CHANGED);
	end loop;


	hr_utility.trace('-----------------------------');
	hr_utility.trace('| ATTRIB_ID     |TBB ID           | BLD_BLK_INFO_TYPE|    ATTRIBUTE_CATEGORY |   TBB_ID|    NEW|    CHANGED|');
	hr_utility.trace('-----------------------------');
	l_index := null;
	l_index := P_TIME_ATTRIBUTES.first;
	while l_index is not null
	loop

	hr_utility.trace('|  '||P_TIME_ATTRIBUTES(l_index).TIME_ATTRIBUTE_ID
			  ||'    |  '||P_TIME_ATTRIBUTES(l_index).BUILDING_BLOCK_ID
			  ||'     |   '||P_TIME_ATTRIBUTES(l_index).BLD_BLK_INFO_TYPE
			  ||'    |  '||P_TIME_ATTRIBUTES(l_index).ATTRIBUTE_CATEGORY
			  || '    |  '||P_TIME_ATTRIBUTES(l_index).BUILDING_BLOCK_ID
			  ||'    |   '||P_TIME_ATTRIBUTES(l_index).NEW||'   |   '
			  ||P_TIME_ATTRIBUTES(l_index).CHANGED);
	l_index := P_TIME_ATTRIBUTES.NEXT(l_index);
	end loop;


	hr_utility.trace('-----------------------------');
end if;
-- ****************** ENDING CHECKS for STRUCTURE After DROPS ******************
*/

END IF; -- list_tim_rec_drops.COUNT > 0


l_index:=null;
l_index:=temp_app_set.FIRST;
-- 115.8  2905369 start
-- Adding check if this DETAIL TBB has been updated in the reversing section
--
if (l_rev_application_set_id ='N')
then
-- 115.6 start
		P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id := null;
		  -- and now finally update the Appl SET id in the DETAIL SCOPE... :-)
		if(l_null_application_set_id = 'N')
		 then
		   P_TIME_BUILDING_BLOCKS (l_index_det).application_set_id :=
			    temp_app_set (l_index).application_set_id;
	   	end if; -- l_null_application_set_id = 'N'
	     end if; -- l_rev_application_set_id ='N'
		END IF; -- app_set_ok = 'N'
	     -- la la ksethi end DETAIL table processin


	     END IF; -- Scope = DETAIL

	     l_index_det := P_TIME_BUILDING_BLOCKS.NEXT (l_index_det);
	  END LOOP; -- l_index_det is not null

-- Check if for the current DAY, any DETAIL was entered or not,
-- if not then default both DAY and TIMECARD to the application
-- set at the user level.

IF (list_tim_rec_day.COUNT = 0 )
THEN

-- Populate both Detail n Timecard as masters
--
l_all_days_entered := 'N';
list_tim_rec_day.DELETE;
list_tim_rec_tc.DELETE;

  l_index := 0;

  l_index_tmp_app := NULL;
  l_index_tmp_app := cached_tm_set.FIRST;

  WHILE l_index_tmp_app IS NOT NULL
   LOOP
     IF (cached_tm_set (l_index_tmp_app).application_set_id =
		      P_APPLICATION_SET_ID
		)
	THEN
	 list_tim_rec_day(l_index).time_recipient_id :=
	 	cached_tm_set (l_index_tmp_app).time_recipient_id;
	 list_tim_rec_tc(l_index).time_recipient_id  :=
	 	cached_tm_set (l_index_tmp_app).time_recipient_id;
	 l_index:=l_index+1;
      END IF;

   l_index_tmp_app := cached_tm_set.NEXT (l_index_tmp_app);
 END LOOP; -- l_index_tmp_app IS NOT NULL
END IF; -- list_tim_rec_day.COUNT = 0

-- Start DAY's Time Recipient table processing
-- in order to set the DAY SCOPE Application Set ID



	  -- Initialize a new temproary table to
	  -- derive the application set id :-)
	  -- Populate it using the cached Application Set Table
	  -- i.e. table 'cached_app_set'

	  IF (temp_app_set.COUNT > 0)
	  THEN
	     temp_app_set.DELETE;
	  END IF;

	  l_index := 0;

	  l_index_tmp_app := NULL;
	  l_index_tmp_app := cached_app_set.FIRST;

	  WHILE l_index_tmp_app IS NOT NULL
	  LOOP
	     IF (cached_app_set (l_index_tmp_app).rec_totals =
					       list_tim_rec_day.COUNT
		)
	     THEN
		temp_app_set (l_index).application_set_id :=
		      cached_app_set (l_index_tmp_app).application_set_id;
		l_index :=   l_index
			   + 1;
	     END IF;

	     l_index_tmp_app := cached_app_set.NEXT (l_index_tmp_app);
	  END LOOP; -- l_index_tmp_app IS NOT NULL



-- Now check for individual Time Recipients


	  l_index_tmp_app := NULL;
	  l_index_tmp_app := temp_app_set.FIRST;

	  WHILE l_index_tmp_app IS NOT NULL
	  LOOP
	     app_set_ok := 'Y';


	  l_index_tmp_rec := NULL;
	  l_index_tmp_rec := cached_tm_set.FIRST;


	     WHILE l_index_tmp_rec IS NOT NULL
	     LOOP
		IF (cached_tm_set (l_index_tmp_rec).application_set_id =
			  temp_app_set (l_index_tmp_app).application_set_id
		   )
		THEN
		   time_rec_present := 'N';

		   --
		   FOR x IN
		       list_tim_rec_day.FIRST .. list_tim_rec_day.LAST
		   LOOP
		      IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
			       list_tim_rec_day (x).time_recipient_id
			 )
		      THEN
			 time_rec_present := 'Y';
		      END IF;
		   END LOOP; -- x IN temp_app_set

		   IF (time_rec_present = 'N')
		   THEN
		      app_set_ok := 'N';
		   END IF;
		END IF; -- match for same appl set in both tables as same

		l_index_tmp_rec :=
				  cached_tm_set.NEXT (l_index_tmp_rec);
	     END LOOP; --  l_index_tmp_rec  is not null

	     --Check flag to delete or not to delete

	     IF (app_set_ok = 'N')
	     THEN
		temp_app_set.DELETE (l_index_tmp_app);
	     END IF;

	     l_index_tmp_app := temp_app_set.NEXT (l_index_tmp_app);
	  END LOOP; -- l_index_tmp_app is not null

	  l_index := NULL;
	  l_index := temp_app_set.FIRST;


-- Check to see if the application set id that is
-- to be set is a subset of the main Preference level
-- then only update
-- here check that this falls in the temp appl set ids table
	  app_set_ok := 'N';

	  FOR x IN valid_app_set.FIRST .. valid_app_set.LAST
	  LOOP
	     IF (temp_app_set (l_index).application_set_id =
				 valid_app_set (x).application_set_id
		)
	     THEN
		app_set_ok := 'Y';
	     END IF;
	  END LOOP;

	  -- if application set Id is not in the temp
	  -- table of application set Ids then
	  -- raise an error as the time recipient is not contained in
	  -- the application set id attached to the resource preference
	  IF (app_set_ok = 'N')
	  THEN
-- 115.6
		   hxc_time_entry_rules_utils_pkg.add_error_to_table (
			   p_message_table => p_messages
		   ,       p_message_name  => 'HXC_VLD_ELP_VIOLATION'
		   ,       p_message_token => NULL
		   ,       p_message_level => 'ERROR'
		   ,       p_message_field => NULL
		   ,       p_application_short_name => 'HXC'
		   ,       p_timecard_bb_id     => null
		   ,       p_time_attribute_id  => NULL
		   ,       p_timecard_bb_ovn       => null
		   ,       p_time_attribute_ovn    => NULL );
	  ELSE -- update the application set id on the TBB
	     -- here one more check has to be made for checkin if
	     -- already some application set id is present or not
	     -- in which case all time transfer etc needs to be
	     -- checked, postponing that check for now, will add laterz

-- and now finally update the Appl SET id in the DAY SCOPE... :-)
	     P_TIME_BUILDING_BLOCKS (l_index_day).application_set_id :=
			    temp_app_set (l_index).application_set_id;

	  END IF; -- app_set_ok = 'N'

       END IF; -- Scope = DAY


       l_index_day := P_TIME_BUILDING_BLOCKS.NEXT (l_index_day);
    END LOOP; -- l_index_day is not null

-- Start TIMECARD's Time Recipient table processing
-- in order to set the TIMECARD SCOPE Application Set ID

-- Populate TIMECARD's Time Recipient table when detail for all days is entered
	IF(l_all_days_entered = 'Y')
	THEN
                      if(list_tim_rec_tc.COUNT > 0) then
                        list_tim_rec_tc.DELETE;
                       end if;
                        l_index := 0;
                        l_index_tmp_app := NULL;
                        l_index_tmp_app := cached_tm_set.FIRST;

                        WHILE l_index_tmp_app IS NOT NULL
                        LOOP
                           IF (cached_tm_set (l_index_tmp_app).application_set_id =
                                                         p_application_set_id
                              )
                           THEN
                              list_tim_rec_tc (l_index).time_recipient_id :=
                                    cached_tm_set (l_index_tmp_app).time_recipient_id;
                              l_index :=   l_index
                                         + 1;
                           END IF;

                           l_index_tmp_app :=
                                          cached_tm_set.NEXT (l_index_tmp_app);
                        END LOOP; -- l_index_tmp_app IS NOT NULL
	END IF;
    -- initialize a new temproary table to
    -- SCOPE  =  TIMECARD
    -- derive the application set id :-)
    -- Populate it using the cached Application Set Table
    -- i.e. table 'cached_app_set'


    IF (temp_app_set.COUNT > 0)
    THEN
       temp_app_set.DELETE;
    END IF;

    l_index := 0;

    l_index_tmp_app := NULL;
    l_index_tmp_app := cached_app_set.FIRST;

    WHILE l_index_tmp_app IS NOT NULL
    LOOP
       IF (cached_app_set (l_index_tmp_app).rec_totals =
						list_tim_rec_tc.COUNT
	  )
       THEN
	  temp_app_set (l_index).application_set_id :=
		  cached_app_set (l_index_tmp_app).application_set_id;
	  l_index :=   l_index
		     + 1;
       END IF;

       l_index_tmp_app := cached_app_set.NEXT (l_index_tmp_app);
    END LOOP; -- l_index_tmp_app IS NOT NULL


-- Now check for individual Time Recipients


    l_index_tmp_app := NULL;
    l_index_tmp_app := temp_app_set.FIRST;

    WHILE l_index_tmp_app IS NOT NULL
    LOOP
       app_set_ok := 'Y';


    l_index_tmp_rec := NULL;
    l_index_tmp_rec := cached_tm_set.FIRST;


       WHILE l_index_tmp_rec IS NOT NULL
       LOOP
	  IF (cached_tm_set (l_index_tmp_rec).application_set_id =
		    temp_app_set (l_index_tmp_app).application_set_id
	     )
	  THEN
	     time_rec_present := 'N';

	     --
	     FOR x IN list_tim_rec_tc.FIRST .. list_tim_rec_tc.LAST
	     LOOP
		IF (cached_tm_set (l_index_tmp_rec).time_recipient_id =
				list_tim_rec_tc (x).time_recipient_id
		   )
		THEN
		   time_rec_present := 'Y';
		END IF;
	     END LOOP; -- x IN temp_app_set

	     IF (time_rec_present = 'N')
	     THEN
		app_set_ok := 'N';
	     END IF;
	  END IF; -- match for same appl set in both tables as same

	  l_index_tmp_rec := cached_tm_set.NEXT (l_index_tmp_rec);
       END LOOP; --  l_index_tmp_rec  is not null

       --Check flag to delete or not to delete

       IF (app_set_ok = 'N')
       THEN
	  temp_app_set.DELETE (l_index_tmp_app);
       END IF;

       l_index_tmp_app := temp_app_set.NEXT (l_index_tmp_app);
    END LOOP; -- l_index_tmp_app is not null


    l_index := NULL;
    l_index := temp_app_set.FIRST;

-- Check to see if the application set id that is
-- to be set is a subset of the main Preference level
-- then only update
-- here check that this falls in the temp appl set ids table
    app_set_ok := 'N';

    FOR x IN valid_app_set.FIRST .. valid_app_set.LAST
    LOOP
       IF (temp_app_set (l_index).application_set_id =
				 valid_app_set (x).application_set_id
	  )
       THEN
	  app_set_ok := 'Y';
       END IF;
    END LOOP;

    -- if application set Id is not in the temp
    -- table of application set Ids then
    -- raise an error as the time recipient is not contained in
    -- the application set id attached to the resource preference
    IF (app_set_ok = 'N')
    THEN
-- 115.6
		   hxc_time_entry_rules_utils_pkg.add_error_to_table (
			   p_message_table => p_messages
		   ,       p_message_name  => 'HXC_VLD_ELP_VIOLATION'
		   ,       p_message_token => NULL
		   ,       p_message_level => 'ERROR'
		   ,       p_message_field => NULL
		   ,       p_application_short_name => 'HXC'
		   ,       p_timecard_bb_id     => null
		   ,       p_time_attribute_id  => NULL
		   ,       p_timecard_bb_ovn       => null
		   ,       p_time_attribute_ovn    => NULL );
    ELSE -- update the application set id on the TBB
       -- here one more check has to be made for checkin if
       -- already some application set id is present or not
       -- in which case all time transfer etc needs to be
       -- checked, postponing that check for now, will add laterz

--- and now finally update the Appl SET id in the DAY TIMECARD... :-)
       P_TIME_BUILDING_BLOCKS (l_index_tc).application_set_id :=
			    temp_app_set (l_index).application_set_id;
    END IF; -- app_set_ok = 'N'
 END IF; -- scope = TIMECARD

 l_index_tc := P_TIME_BUILDING_BLOCKS.NEXT (l_index_tc);
END LOOP; -- l_index_tc is not null





-- here ends the real processing
else -- p_pte_terg_id is null

-- No Entry Level Processing is set
-- update all TBB to have the application set id
-- as the one set on the resource preference
--
-- if g_debug then
	-- hr_utility.trace('ks NO ELP');
-- end if;
l_index_tc := NULL;

l_index_tc := P_TIME_BUILDING_BLOCKS.FIRST;

WHILE l_index_tc IS NOT NULL
LOOP

	P_TIME_BUILDING_BLOCKS(l_index_tc).application_set_id := P_APPLICATION_SET_ID;

	l_index_tc := P_TIME_BUILDING_BLOCKS.NEXT(l_index_tc);


END LOOP;

end if; -- (l_pte_terg_id <> null)

-- 2905369 start 115.8
-- Change back the OVN for the new TBB back to 1
--
l_index := null;
l_index := P_TIME_BUILDING_BLOCKS.first;
while l_index is not null
loop
if (P_TIME_BUILDING_BLOCKS(l_index).OBJECT_VERSION_NUMBER = -9999)
then
-- if g_debug then
	-- hr_utility.trace('ks ...  Yes -ve TBB OVN found which is for the new entry.');
-- end if;
P_TIME_BUILDING_BLOCKS(l_index).OBJECT_VERSION_NUMBER := 1;
end if;
l_index := P_TIME_BUILDING_BLOCKS.NEXT(l_index);
end loop;

-- 2905369 end 115.8


/*
-- ************* After Call to Update/Populate Appliation Set
if g_debug then
	hr_utility.trace('*******AFTER PROCESSING******');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('| TBB_ID     | APPL_SET_ID|');
	hr_utility.trace('-----------------------------');
	for x IN P_TIME_BUILDING_BLOCKS.first .. P_TIME_BUILDING_BLOCKS.last
	loop
	hr_utility.trace('|  '||P_TIME_BUILDING_BLOCKS(x).time_building_block_id
			  ||'         |  '||P_TIME_BUILDING_BLOCKS(x).application_set_id
			  ||'    |');
	end loop;

	hr_utility.trace('Leaves  and messges cnt ='||p_messages.count);
end if;
*/

EXCEPTION
WHEN OTHERS THEN
-- 115.7
--	            hr_utility.set_message (809, 'HXC_ELP_APPL_PROCESS_ERROR');
--	            hr_utility.raise_error;
		   hxc_time_entry_rules_utils_pkg.add_error_to_table (
			   p_message_table => p_messages
		   ,       p_message_name  => 'EXCEPTION'
		   ,       p_message_token => NULL
		   ,       p_message_level => 'ERROR'
		   ,       p_message_field => NULL
		   ,       p_application_short_name => 'HXC'
		   ,       p_timecard_bb_id     => null
		   ,       p_time_attribute_id  => NULL
		   ,       p_timecard_bb_ovn       => null
		   ,       p_time_attribute_ovn    => NULL );



END set_time_bb_appl_set_id;


-- ksethi end the proc...


FUNCTION build_elp_objects
	 (P_ELP_TIME_BUILDING_BLOCKS  HXC_BLOCK_TABLE_TYPE
	 ,P_ELP_TIME_ATTRIBUTES       HXC_ATTRIBUTE_TABLE_TYPE
	 ,P_TIME_RECIPIENT_ID         number
	 ) RETURN HXC_BLOCK_TABLE_TYPE
    IS

time_rec_present_det varchar2(1);
time_rec_present_day varchar2(1);
time_rec_present_tc  varchar2(1);


TYPE v_app_set IS RECORD (
application_set_id            NUMBER (15));

TYPE r_app_set IS TABLE OF v_app_set
INDEX BY BINARY_INTEGER;

cached_app_set           r_app_set;
l_elp_time_builidng_block HXC_BLOCK_TABLE_TYPE;

l_index                  BINARY_INTEGER;
l_index_tc               BINARY_INTEGER;
l_index_day              BINARY_INTEGER;
l_index_det              BINARY_INTEGER;


CURSOR csr_app_set_id (p_tim_rec_id NUMBER)
IS
SELECT DISTINCT (application_set_id) A
	 FROM hxc_application_set_comps_v
	WHERE time_recipient_id = p_tim_rec_id;


l_proc                   VARCHAR2 (30);
--
BEGIN
--
g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc  := 'build_elp_objects';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;
--
-- issue a savepoint
savepoint build_elp_objects;
--
/*
-- **************************** START TRACE SECTION ********************
if g_debug then
	hr_utility.trace('ks enters BUILD P_TIME_RECIPIENT_ID = '||P_TIME_RECIPIENT_ID);
	-- Initialize a local copy of the time builidng block
	hr_utility.trace('*******BEFORE PROCESSING******');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('| TBB_ID     | APPL_SET_ID|');
	hr_utility.trace('-----------------------------');
	for x IN P_ELP_TIME_BUILDING_BLOCKS.first .. P_ELP_TIME_BUILDING_BLOCKS.last
	loop
	hr_utility.trace('|  '||P_ELP_TIME_BUILDING_BLOCKS(x).time_building_block_id
			  ||'         |  '||P_ELP_TIME_BUILDING_BLOCKS(x).application_set_id
			  ||'    |');
	end loop;
end if;
-- **************************** END TRACE SECTION ************************
*/

l_elp_time_builidng_block := p_elp_time_building_blocks;


l_index := 1;

FOR appl_set IN csr_app_set_id(p_time_recipient_id) LOOP

--
-- Get all the valid application sets for the
-- current time recipient
-- and use them to populate the
-- temporary table 'cached_app_set'
--
cached_app_set(l_index).application_set_id := appl_set.A;

l_index := l_index+1;
END LOOP;
-- if g_debug then
	-- hr_utility.trace('valid cached_app_set.COUNT = '||cached_app_set.COUNT);
-- end if;

-- here starts the real processing

-- Initialize to read the global timecard object
--
l_index_tc := NULL;
l_index_tc := l_elp_time_builidng_block.FIRST;

WHILE l_index_tc IS NOT NULL
LOOP
 IF (l_elp_time_builidng_block (l_index_tc).scope = 'TIMECARD')
 THEN
-- Intialize the flag to include timecard row to 'N for SCOPE = TIMECARD

time_rec_present_tc := 'N';

    l_index_day := NULL;
    l_index_day := l_elp_time_builidng_block.FIRST;

    WHILE l_index_day IS NOT NULL
    LOOP
       IF (    l_elp_time_builidng_block (l_index_day).scope = 'DAY'
	   AND l_elp_time_builidng_block (l_index_day).parent_building_block_id =
		       l_elp_time_builidng_block (l_index_tc).time_building_block_id
	   AND l_elp_time_builidng_block (l_index_day).parent_building_block_ovn =
			l_elp_time_builidng_block (l_index_tc).object_version_number
	  )
       THEN
-- Intialize the flag to include timecard row to 'N for SCOPE = DAY
--	if g_debug then
		--hr_utility.trace('ks 1208');
--	end if;
   time_rec_present_day := 'N';

	  l_index_det := NULL;
	  l_index_det := l_elp_time_builidng_block.FIRST;

	  WHILE l_index_det IS NOT NULL
	  LOOP
	     IF (    l_elp_time_builidng_block (l_index_det).scope = 'DETAIL'
		 AND l_elp_time_builidng_block (l_index_det).parent_building_block_id =
			   l_elp_time_builidng_block (l_index_day).time_building_block_id
		 AND l_elp_time_builidng_block (l_index_det).parent_building_block_ovn =
			   l_elp_time_builidng_block (l_index_day).object_version_number
		)
	     THEN

-- Intialize the flag to include timecard row to 'N for SCOPE = DETAIL

     time_rec_present_det := 'N';

		-- Start processing the
		-- Time recipient for the DETAIL BB_ID

		 FOR x IN
		     cached_app_set.FIRST .. cached_app_set.LAST
		 LOOP
		   IF (l_elp_time_builidng_block(l_index_det).application_set_id =
			cached_app_set(x).application_set_id
		      )
		    THEN
		       time_rec_present_det := 'Y';
		       time_rec_present_day := 'Y';
		       time_rec_present_tc  := 'Y';
--	if g_debug then
		--hr_utility.trace('ks in Yes for all 1240');
--	end if;
		    END IF; -- check if Time Recipient is already present
		 END LOOP; -- x IN cached_app_set

-- check n keep or del for DETAIL

		  IF(time_rec_present_det = 'N') then
		   l_elp_time_builidng_block.DELETE(l_index_det);
		  END IF;

	      END IF; -- Scope = DETAIL

	     l_index_det := l_elp_time_builidng_block.NEXT (l_index_det);

	  END LOOP; -- l_index_det is not null


-- check n keep or del for DAY

		  IF(time_rec_present_day = 'N') then
		   l_elp_time_builidng_block.DELETE(l_index_day);
		  END IF;

       END IF; -- Scope = DAY


       l_index_day := l_elp_time_builidng_block.NEXT (l_index_day);
    END LOOP; -- l_index_day is not null

-- check n keep or del for TIMECARD

-- version 115.4 commenting below

--		  IF(time_rec_present_tc = 'N') then
--		   l_elp_time_builidng_block.DELETE(l_index_tc);
--		  END IF;

 END IF; -- scope = TIMECARD

 l_index_tc := l_elp_time_builidng_block.NEXT (l_index_tc);
END LOOP; -- l_index_tc is not null

/*
-- ********************** START TRACE AFTER PROCESSING***********************
if g_debug then
	hr_utility.trace('*******AFTER PROCESSING******');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('| TBB_ID     | APPL_SET_ID|');
	hr_utility.trace('-----------------------------');
	hr_utility.trace('CNT l_elp_time_builidng_block='||l_elp_time_builidng_block.COUNT);
	if(l_elp_time_builidng_block.COUNT > 0 )
	then
	l_index:=0;
	l_index:=l_elp_time_builidng_block.FIRST;
	while l_index is not null
	loop
	hr_utility.trace('|  '||l_elp_time_builidng_block(l_index).time_building_block_id||'         |  '||l_elp_time_builidng_block(l_index).application_set_id||'    |');
	l_index:=l_elp_time_builidng_block.NEXT(l_index);
	end loop; -- l_index is not null
	end if; -- l_elp_time_builidng_block.COUNT > 0
end if;
-- ********************** END TRACE AFTER PROCESSING**************************
*/
RETURN l_elp_time_builidng_block;

-- here ends the processing
EXCEPTION
WHEN OTHERS THEN

            hr_utility.set_message (809, 'HXC_ELP_TC_FILTER_ERROR');
            hr_utility.raise_error;


END build_elp_objects;

-- public procedure

PROCEDURE set_time_bb_appl_set_tk
	 (P_TIME_BUILDING_BLOCKS IN OUT NOCOPY	hxc_self_service_time_deposit.timecard_info
	 ,P_APPLICATION_SET_ID   IN     number
	 )
    IS

l_index_tc               BINARY_INTEGER;
l_proc                   VARCHAR2 (30);

BEGIN
g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc  := 'set_time_bb_appl_set_tk';
	hr_utility.set_location('Processing '||l_proc, 10);
end if;
--
-- Issue a SavePoint
   savepoint set_time_bb_appl_tk;
--
-- if g_debug then
	--hr_utility.trace('Entered..........'||p_pte_terg_id);
-- end if;

-- Here we just update the g_timecard with the
-- Application Set id set at the user pref
-- level for all the TBBs
--
l_index_tc := NULL;
l_index_tc := P_TIME_BUILDING_BLOCKS.FIRST;

WHILE l_index_tc IS NOT NULL
LOOP
--
	P_TIME_BUILDING_BLOCKS(l_index_tc).application_set_id := P_APPLICATION_SET_ID;
--
	l_index_tc := P_TIME_BUILDING_BLOCKS.NEXT(l_index_tc);
--
END LOOP;
--
EXCEPTION
WHEN OTHERS THEN
	            hr_utility.set_message (809, 'HXC_ELP_APPL_PROCESS_ERROR');
	            hr_utility.raise_error;
--
END set_time_bb_appl_set_tk;

end hxc_elp_utils;

/
