--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_ERRORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_ERRORS" AS
/* $Header: hxctkerror.pkb 120.3 2005/09/23 09:38:06 nissharm noship $ */

g_debug boolean := hr_utility.debug_enabled;

--
-- public procedure
--   show_timecard_errors
--
-- description
--   See DESCRIPTION in header

procedure show_timecard_errors (
	p_error_table		IN OUT NOCOPY 	t_error_table
,	p_timecard_id		IN	NUMBER
,	p_timecard_ovn  	IN	NUMBER
,	p_full_name 		IN 	VARCHAR2)
IS


CURSOR csr_get_detail is

SELECT  detail.time_building_block_id tbb_id,
        detail.object_version_number tbb_ovn,
	detail.scope scope,
	nvl(detail.start_time,trunc(day.start_time)) start_time,
	nvl(detail.stop_time,trunc(day.stop_time))  stop_time,
	detail.measure measure
FROM hxc_time_building_blocks detail, hxc_time_building_blocks DAY
WHERE DAY.parent_building_block_id = p_timecard_id
AND DAY.parent_building_block_ovn = p_timecard_ovn
AND detail.date_to = hr_general.end_of_time
AND detail.SCOPE = 'DETAIL'
AND detail.parent_building_block_id = DAY.time_building_block_id
AND detail.parent_building_block_ovn = DAY.object_version_number
AND DAY.SCOPE = 'DAY'
AND DAY.date_to = hr_general.end_of_time
UNION
SELECT  time_building_block_id detail_id,
        object_version_number detail_ovn,
	scope,
        trunc(start_time),
        trunc(stop_time),
	measure
FROM  hxc_time_building_blocks
WHERE time_building_block_id = p_timecard_id
and   object_version_number = p_timecard_ovn
ORDER BY 4;

/*
CURSOR  csr_get_timecard IS
select  bb.time_building_block_id bb_id
,	bb.object_version_number ovn
,       bb.scope
,       bb.start_time
,	bb.stop_time
,	bb.resource_id
FROM
	hxc_time_building_blocks bb
WHERE EXISTS ( select 'x'
               from 	hxc_errors tke
               where   tke.time_building_block_id = bb.time_building_block_id
               and     tke.time_building_block_ovn = bb.object_version_number)
START WITH bb.time_building_block_id = p_timecard_id
AND	   bb.object_version_number  = p_timecard_ovn
AND        bb.scope		     = 'TIMECARD'
CONNECT BY PRIOR bb.time_building_block_id = bb.parent_building_block_id
AND	   PRIOR bb.object_version_number  = bb.parent_building_block_ovn;

*/

CURSOR csr_get_error ( p_tbb_id IN NUMBER, p_ovn_id IN NUMBER )
IS
SELECT
  tke.ERROR_ID
, tke.TRANSACTION_DETAIL_ID
, tke.TIME_BUILDING_BLOCK_ID
, tke.TIME_BUILDING_BLOCK_OVN
, tke.TIME_ATTRIBUTE_ID
, tke.TIME_ATTRIBUTE_OVN
, tke.MESSAGE_NAME
, tke.MESSAGE_LEVEL
, tke.MESSAGE_FIELD
, tke.MESSAGE_TOKENS
, tke.APPLICATION_SHORT_NAME
FROM
   hxc_errors tke
WHERE
   tke.time_building_block_id  = p_tbb_id AND
   tke.time_building_block_ovn = p_ovn_id AND
   (tke.date_to=hr_general.end_of_time OR tke.date_to is NULL);


l_tbb_id 	number(15);
l_tbb_ovn 	number(15);

l_index		NUMBER := 1;

l_scope		VARCHAR2(80);
l_start_time	DATE;
l_stop_time	DATE;
l_resource_id	NUMBER;

l_token_table hxc_deposit_wrapper_utilities.t_simple_table;

BEGIN

For timecard_rec in csr_get_detail LOOP

l_scope :=timecard_rec.scope;

  FOR c_get_error in csr_get_error ( timecard_rec.tbb_id, timecard_rec.tbb_ovn ) LOOP

     -- populate the error_table here
     p_error_table(l_index).ERROR_ID		 	:= c_get_error.error_id;
     p_error_table(l_index).TRANSACTION_DETAIL_ID   	:= c_get_error.TRANSACTION_DETAIL_ID ;
     p_error_table(l_index).TIME_BUILDING_BLOCK_ID  	:= c_get_error.TIME_BUILDING_BLOCK_ID ;
     p_error_table(l_index).TIME_BUILDING_BLOCK_OVN	:= c_get_error.TIME_BUILDING_BLOCK_OVN ;
     p_error_table(l_index).TIME_ATTRIBUTE_ID		:= c_get_error.TIME_ATTRIBUTE_ID ;
     p_error_table(l_index).TIME_ATTRIBUTE_OVN		:= c_get_error.TIME_ATTRIBUTE_OVN ;
     p_error_table(l_index).MESSAGE_NAME		:= c_get_error.MESSAGE_NAME ;
     p_error_table(l_index).MESSAGE_FIELD		:= c_get_error.MESSAGE_FIELD ;
     p_error_table(l_index).MESSAGE_TOKENS 		:= c_get_error.MESSAGE_TOKENS ;
     p_error_table(l_index).APPLICATION_SHORT_NAME	:= c_get_error.APPLICATION_SHORT_NAME ;
     p_error_table(l_index).SCOPE_LEVEL			:=
     			hr_bis.bis_decode_lookup('HXC_BUILDING_BLOCK_SCOPE',timecard_rec.scope);
     p_error_table(l_index).MESSAGE_LEVEL		:=
     			hr_bis.bis_decode_lookup('HXC_TIME_ENTRY_RULE_OUTCOME',c_get_error.MESSAGE_LEVEL);

     fnd_message.set_name(c_get_error.APPLICATION_SHORT_NAME,c_get_error.MESSAGE_NAME);

     -- set the token if applicable
     -- GPM v115.4

     IF ( c_get_error.MESSAGE_TOKENS IS NOT NULL )
     THEN
        --
        -- parse string into a more accessible form
        --

        hxc_deposit_wrapper_utilities.string_to_table('&',
                                                    '&'||c_get_error.MESSAGE_TOKENS,
                                                    l_token_table);

        -- table should be full of TOKEN, VALUE pairs. The number of TOKEN, VALUE pairs is l_token_table/2

        FOR l_token in 0..(l_token_table.count/2)-1
        LOOP

          FND_MESSAGE.SET_TOKEN
          (TOKEN => l_token_table(2*l_token)
          ,VALUE => l_token_table(2*l_token+1)
          );

        END LOOP;

     END IF; -- c_get_error.MESSAGE_TOKEN IS NOT NULL

     p_error_table(l_index).MESSAGE_TEXT		:= fnd_message.get() ;

     fnd_message.clear;

     p_error_table(l_index).PERSON_FULL_NAME		:= p_full_name ;
     p_error_table(l_index).START_PERIOD		:= timecard_rec.start_time ;
     p_error_table(l_index).END_PERIOD			:= timecard_rec.stop_time ;
     p_error_table(l_index).MEASURE			:= timecard_rec.measure ;

   l_index	:= l_index + 1;

   END LOOP;

END LOOP;

IF (l_index = 1 and l_scope = 'ERROR') THEN

  fnd_message.set_name('HXC','HXC_TIMEKEEPER_UNEXCEP_ERROR');

  p_error_table(l_index).MESSAGE_TEXT			:= fnd_message.get();

ELSIF (l_index = 1) THEN

  fnd_message.set_name('HXC','HXC_TIMEKEEPER_NO_ERROR');

  p_error_table(l_index).MESSAGE_TEXT			:= fnd_message.get();

END IF;


-- Joel - we also need to process the l_error_tab(x).message_name
-- to the message_text param
-- IF message_name begins with HXC, HR, PER, PAY then call fnd message
-- to get text else just put message_name into text.

END show_timecard_errors;


--
-- public procedure
--   maintain_errors
--
-- description
--   See DESCRIPTION in header
PROCEDURE maintain_errors
     (p_messages           IN  OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
     ,p_timecard_id	   IN  OUT NOCOPY NUMBER
     ,p_timecard_ovn  	   IN  OUT NOCOPY NUMBER) IS

cursor c_max_ovn
(p_tbb_id in number) is
 select max(object_version_number)
 from   hxc_time_building_blocks
 where  time_building_block_id = p_tbb_id;

cursor c_transaction_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select transaction_id
 from  hxc_transaction_details
 where time_building_block_id = p_tbb_id
 and   object_version_number  = p_tbb_ovn;

cursor c_error_id
(p_tbb_id  in number,
 p_tbb_ovn in number) is
 select *
 from  hxc_errors
 where time_building_block_id = p_tbb_id
 and   time_building_block_ovn  = p_tbb_ovn
 and   (date_to=hr_general.end_of_time OR date_to is NULL);

CURSOR c_detail_info (timecard_id IN NUMBER, timecard_ovn IN NUMBER)
IS
SELECT   detail.time_building_block_id detail_id,
       detail.object_version_number detail_ovn
  FROM hxc_time_building_blocks detail, hxc_time_building_blocks DAY
 WHERE DAY.parent_building_block_id = timecard_id
   AND DAY.parent_building_block_ovn = timecard_ovn
   AND detail.date_to = hr_general.end_of_time
   AND detail.SCOPE = 'DETAIL'
   AND detail.parent_building_block_id = DAY.time_building_block_id
   AND detail.parent_building_block_ovn = DAY.object_version_number
   AND DAY.SCOPE = 'DAY'
   AND DAY.date_to = hr_general.end_of_time;

l_proc varchar2(72);

l_message_index NUMBER;
l_tbb_id	NUMBER := NULL;
l_tbb_ovn	NUMBER := NULL;
l_tx_id		NUMBER := NULL;
l_error_id	NUMBER := NULL;
l_ovn           NUMBER := NULL;
l_errid         NUMBER  :=NULL;

PROCEDURE purge_duplicate_messages ( p_messages IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE ) IS

l_ind PLS_INTEGER;

BEGIN

l_ind := p_messages.FIRST;

WHILE l_ind IS NOT NULL
LOOP

	BEGIN

         delete from hxc_errors
         where time_building_Block_id    = p_messages(l_ind).time_building_block_id
         and   message_name              = p_messages(l_ind).message_name
         and   NVL(message_tokens,'ZzZ') = NVL(p_messages(l_ind).message_tokens,'ZzZ');

 	EXCEPTION WHEN OTHERS THEN null;

 	END;

	l_ind := p_messages.NEXT(l_ind);

END LOOP;

END purge_duplicate_messages;



BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'.maintain_errors';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;


--first set the date_to to todays date if message already exists for saved timecard in error status
For error_rec in c_error_id(p_timecard_id,p_timecard_ovn) LOOP

 hxc_err_upd.upd
  (p_error_id                     => error_rec.error_id
  ,p_object_version_number        => error_rec.object_version_number
  ,p_date_from			  => error_rec.date_from
  ,p_date_to                      => sysdate-1
  );

END LOOP;

For detail_rec in c_detail_info(p_timecard_id,p_timecard_ovn) LOOP

   For error_rec in c_error_id(detail_rec.detail_id,detail_rec.detail_ovn) LOOP

      hxc_err_upd.upd
       (p_error_id                     => error_rec.error_id
       ,p_object_version_number        => error_rec.object_version_number
       ,p_date_from			  => error_rec.date_from
       ,p_date_to                      => sysdate-1
       );
   END LOOP;

END LOOP;

purge_duplicate_messages ( p_messages );

-- parse the transaction table to produce a mapping of time building blocks
-- to transaction details id- this will save traversing the table for every message

l_message_index := p_messages.FIRST;

LOOP
  EXIT WHEN (NOT p_messages.EXISTS (l_message_index));

  if g_debug then
  	hr_utility.set_location('Processing '||l_proc, 40);
  end if;

  -- assign to variables (makes it easier to read the following code)
  l_tbb_id   := p_messages(l_message_index).time_building_block_id;
  l_tbb_ovn  := p_messages(l_message_index).time_building_block_ovn;

  if g_debug then
  	hr_utility.set_location('Processing '||l_proc, 70);
  end if;

--added for bug no 2927608
  If p_messages(l_message_index).message_level IN ('ERROR','WARNING','BUSINESS_MESSAGE') then

   --find the transaction_id from the tbb
   OPEN   c_transaction_id(l_tbb_id,l_tbb_ovn);
   FETCH  c_transaction_id INTO l_tx_id;
   CLOSE  c_transaction_id;

   if l_tbb_id is null or l_tbb_id < 0 then
    l_tbb_id  := p_timecard_id;
    l_tbb_ovn := p_timecard_ovn;
   end if;

 --  IF l_tbb_ovn is null then   --3420765
     OPEN   c_max_ovn(l_tbb_id);
     FETCH  c_max_ovn INTO l_tbb_ovn;
     CLOSE  c_max_ovn;
 --  END IF;

   IF l_tbb_ovn is null then
     l_tbb_ovn := 1;
   END IF;


   IF (l_tx_id is null) THEN
       l_tx_id := -1;
   END IF;

   hxc_err_ins.ins
	  (p_transaction_detail_id         => l_tx_id
	  ,p_time_building_block_id        => l_tbb_id
	  ,p_time_building_block_ovn       => l_tbb_ovn
          ,p_time_attribute_id             =>p_messages(l_message_index).time_attribute_id
          ,p_time_attribute_ovn            =>p_messages(l_message_index).time_attribute_ovn
          ,p_message_name                  =>p_messages(l_message_index).message_name
          ,p_message_level                 =>p_messages(l_message_index).message_level
          ,p_message_field                 =>p_messages(l_message_index).message_field
          ,p_message_tokens                =>p_messages(l_message_index).message_tokens
          ,p_application_short_name        =>p_messages(l_message_index).application_short_name
	  ,p_error_id                      => l_error_id
	  ,p_object_version_number	   => l_ovn
          ,p_date_from			   => sysdate
	  ,p_date_to			   => hr_general.end_of_time
	  );
   End if;
   l_message_index := p_messages.NEXT(l_message_index);

  l_tbb_id	:= NULL;
  l_tbb_ovn	:= NULL;
  l_tx_id	:= NULL;
  l_error_id   := NULL;

END LOOP;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 80);
end if;

END maintain_errors;

--
-- public procedure
--   maintain_errors
--
-- description
--   See DESCRIPTION in header
PROCEDURE rollback_tc_or_set_err_status
  (p_message_table in out nocopy HXC_MESSAGE_TABLE_TYPE
  ,p_blocks        in out nocopy hxc_block_table_type
  ,p_attributes    in out nocopy hxc_attribute_table_type
  ,p_rollback	   in out nocopy BOOLEAN
  ,p_status_error  out NOCOPY BOOLEAN) IS

l_index  BINARY_INTEGER;

l_error_message_found	BOOLEAN := FALSE;

BEGIN

p_rollback := FALSE;

l_index := p_message_table.first;
-- at this point we are checking if we need to
-- rollback.

WHILE l_index IS NOT NULL
LOOP

   IF p_message_table(l_index).message_name = 'HXC_VLD_TC_STATUS_CHANGED'
   OR
      p_message_table(l_index).message_name = 'HXC_TIME_BLD_BLK_NOT_LATEST'
   OR
      p_message_table(l_index).message_name = 'PA_NO_DEL_EX_ITEM'
   OR
      p_message_table(l_index).message_name = 'PA_TR_ADJ_NO_NET_ZERO'
   OR
      p_message_table(l_index).message_name = 'HXT_TC_CANNOT_BE_DELETED'
   OR
      p_message_table(l_index).message_name = 'HXT_TC_CANNOT_BE_CHANGED_TODAY'
   OR
      p_message_table(l_index).message_name = 'HXC_TC_OFFLINE_PERIOD_CONFLICT'
   THEN
 	-- we need to rollback;
	p_rollback := TRUE;
   END IF;

   IF p_message_table(l_index).message_level =
   	hxc_timecard_deposit_common.c_error
   THEN
      l_error_message_found := TRUE;
   END IF;

   l_index := p_message_table.NEXT(l_index);
END LOOP;

IF l_error_message_found THEN
  -- if we passed the above then we need to change the status
  -- to be error
  l_index := p_blocks.FIRST;

  WHILE l_index IS NOT NULL
  LOOP
     p_blocks(l_index).approval_status := 'ERROR';
     p_blocks(l_index).process := 'Y';
     l_index := p_blocks.NEXT(l_index);
  END LOOP;

  hxc_block_attribute_update.set_process_flags
    (p_blocks     => p_blocks
    ,p_attributes => p_attributes
    );

  -- set the status error
  p_status_error := TRUE;
ELSE
  -- set the status error
  p_status_error := FALSE;


END IF;

END rollback_tc_or_set_err_status;

end hxc_timekeeper_errors;

/
