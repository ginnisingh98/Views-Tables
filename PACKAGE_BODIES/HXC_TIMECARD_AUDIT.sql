--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_AUDIT" AS
/* $Header: hxctcaudit.pkb 120.2.12010000.14 2010/05/06 08:20:33 asrajago ship $ */

g_debug boolean := hr_utility.debug_enabled;

Function find_overall_status
          (p_transaction_info in hxc_timecard.transaction_info
          ) return varchar2 is

l_index  NUMBER;
l_status varchar2(20);

Begin

l_index := p_transaction_info.first;

LOOP
 EXIT WHEN
   (
    (NOT p_transaction_info.exists(l_index))
   OR
    (l_status <> hxc_timecard.c_trans_success)
   );

  l_status := p_transaction_info(l_index).status;

  l_index := p_transaction_info.next(l_index);

END LOOP;

return l_status;

End find_overall_status;

Procedure insert_audit_header
            (p_overall_status   in            varchar2
            ,p_transaction_info in            hxc_timecard.transaction_info
            ,p_messages         in out nocopy hxc_message_table_type
            ,p_transaction_id      out nocopy hxc_transactions.transaction_id%type
            ) is

cursor c_transaction_sequence is
  select hxc_transactions_s.nextval from dual;

l_transaction_id        hxc_transactions.transaction_id%TYPE;
l_deposit_process_id    hxc_deposit_processes.deposit_process_id%type;
l_data_set_id           hxc_transactions.data_set_id%TYPE;
l_index                 BINARY_INTEGER;

Begin

  select deposit_process_id
    into l_deposit_process_id
    from hxc_deposit_processes
   where name = 'OTL Deposit Process';

  open c_transaction_sequence;
  fetch c_transaction_sequence into l_transaction_id;
  close c_transaction_sequence;

  l_index := p_transaction_info.first;
  if l_index is not null then
  	l_data_set_id := p_transaction_info(l_index).data_set_id;
  end if;


  insert into hxc_dep_transactions
    (transaction_id
    ,transaction_date
    ,type
    ,transaction_process_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,status
    ,data_set_id
  ) values
    (l_transaction_id
    ,sysdate
    ,'DEPOSIT'
    ,l_deposit_process_id
    ,null
    ,sysdate
    ,null
    ,sysdate
    ,null
    ,p_overall_status
    ,l_data_set_id
  );

p_transaction_id := l_transaction_id;

End insert_audit_header;

Procedure insert_audit_details
           (p_transaction_info in out nocopy hxc_timecard.transaction_info
           ,p_messages         in out nocopy hxc_message_table_type
           ,p_transaction_id   in            hxc_transactions.transaction_id%type
           ) is

l_index NUMBER;

cursor c_transaction_detail_sequence is
  select hxc_transaction_details_s.nextval from dual;

l_transaction_detail_id hxc_transaction_details.transaction_detail_id%TYPE;

Begin

l_index := p_transaction_info.first;

Loop
 EXIT WHEN NOT p_transaction_info.exists(l_index);

  open c_transaction_detail_sequence;
  fetch c_transaction_detail_sequence into l_transaction_detail_id;
  close c_transaction_detail_sequence;

  insert into hxc_dep_transaction_details
    (transaction_detail_id
    ,time_building_block_id
    ,transaction_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,time_building_block_ovn
    ,status
    ,exception_description
    ,data_set_id
  ) values
    (l_transaction_detail_id
    ,p_transaction_info(l_index).time_building_block_id
    ,p_transaction_id
    ,null
    ,sysdate
    ,null
    ,sysdate
    ,null
    ,p_transaction_info(l_index).object_version_number
    ,p_transaction_info(l_index).status
    ,p_transaction_info(l_index).exception_desc
    ,p_transaction_info(l_index).data_set_id
  );

  p_transaction_info(l_index).transaction_detail_id := l_transaction_detail_id;

  l_index := p_transaction_info.next(l_index);

End Loop;

End insert_audit_details;

Procedure audit_deposit
  (p_transaction_info  in out nocopy hxc_timecard.transaction_info
  ,p_messages          in out nocopy hxc_message_table_type
  ) is

PRAGMA AUTONOMOUS_TRANSACTION;

l_transaction hxc_transactions.transaction_id%type;

Begin

insert_audit_header
  (find_overall_status(p_transaction_info)
  ,p_transaction_info
  ,p_messages
  ,l_transaction
  );

insert_audit_details
  (p_transaction_info
  ,p_messages
  ,l_transaction
  );

commit;

End audit_deposit;

Procedure maintain_latest_details
  (p_blocks           in hxc_block_table_type
  ) IS

l_timecard_blocks  hxc_timecard.block_list;
l_day_blocks       hxc_timecard.block_list;
l_detail_blocks    hxc_timecard.block_list;

l_detail_ind PLS_INTEGER;

l_blk_ind PLS_INTEGER;

l_status hxc_time_building_blocks.approval_status%TYPE;

l_org_id     NUMBER;
l_bg_id      NUMBER;

-- Bug 8888801
-- Added the following datatypes and variables for
-- recording Apps specific details.

l_timecard_id hxc_time_building_blocks.time_building_block_id%type;

TYPE NUMTAB     IS TABLE OF NUMBER;
TYPE VARCHARTAB IS TABLE OF VARCHAR2(2500);
TYPE DATETAB    IS TABLE OF DATE;

-- Bug 9684373
TYPE NUMBERTAB  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_app_sets      NUMBERTAB;
l_day_scope     NUMBERTAB;


pa_resource_id_tab                NUMTAB;
pa_time_building_block_id_tab     NUMTAB;
pa_object_version_number_tab 	  NUMTAB;
pa_application_set_id_tab	  NUMTAB;
pa_org_id_tab     		  NUMTAB;
pa_business_group_id_tab 	  NUMTAB;
pa_timecard_id_tab		  NUMTAB;
pa_start_time_tab 		  DATETAB;
pa_stop_time_tab 		  DATETAB;
pa_last_update_date_tab		  DATETAB;
pa_approval_status_tab 		  VARCHARTAB;
pa_comment_text_tab 		  VARCHARTAB;
pa_resource_type_tab  		  VARCHARTAB;

pay_resource_id_tab               NUMTAB;
pay_time_building_block_id_tab    NUMTAB;
pay_object_version_number_tab 	  NUMTAB;
pay_application_set_id_tab	  NUMTAB;
pay_org_id_tab     		  NUMTAB;
pay_business_group_id_tab 	  NUMTAB;
pay_timecard_id_tab		  NUMTAB;
pay_start_time_tab 		  DATETAB;
pay_stop_time_tab 		  DATETAB;
pay_last_update_date_tab	  DATETAB;
pay_approval_status_tab 	  VARCHARTAB;
pay_comment_text_tab 		  VARCHARTAB;
pay_resource_type_tab  		  VARCHARTAB;

l_pay_index                       NUMBER := 0;
l_pa_index                        NUMBER := 0;

-- Bug 8888801
-- Define a new exception type.
TABLE_EXCEPTION EXCEPTION;
PRAGMA EXCEPTION_INIT(TABLE_EXCEPTION,-24381);


    -- Bug 8888801
    -- Private Procedure added to extend the tables
    -- used for insert/update.
    PROCEDURE extend_tables(p_app   IN  VARCHAR2)
    IS

    BEGIN

        IF p_app = 'PAY'
        THEN
            pay_resource_id_tab.EXTEND(1);
            pay_time_building_block_id_tab.EXTEND(1);
            pay_object_version_number_tab.EXTEND(1);
            pay_application_set_id_tab.EXTEND(1);
            pay_org_id_tab.EXTEND(1);
            pay_business_group_id_tab.EXTEND(1);
            pay_timecard_id_tab.EXTEND(1);
            pay_start_time_tab.EXTEND(1);
            pay_stop_time_tab.EXTEND(1);
            pay_last_update_date_tab.EXTEND(1);
            pay_approval_status_tab.EXTEND(1);
            pay_comment_text_tab.EXTEND(1);
            pay_resource_type_tab.EXTEND(1);
        ELSIF p_app = 'PA'
        THEN
            pa_resource_id_tab.EXTEND(1);
            pa_time_building_block_id_tab.EXTEND(1);
            pa_object_version_number_tab.EXTEND(1);
            pa_application_set_id_tab.EXTEND(1);
            pa_org_id_tab.EXTEND(1);
            pa_business_group_id_tab.EXTEND(1);
            pa_timecard_id_tab.EXTEND(1);
            pa_start_time_tab.EXTEND(1);
            pa_stop_time_tab.EXTEND(1);
            pa_last_update_date_tab.EXTEND(1);
            pa_approval_status_tab.EXTEND(1);
            pa_comment_text_tab.EXTEND(1);
            pa_resource_type_tab.EXTEND(1);
        END IF;

    END extend_tables;

    -- Bug 9684373
    -- This procedure picks up the DAY scope blocks and
    -- stores their parent_id -> timecard_id
    PROCEDURE pick_up_day_scope(p_blocks IN  hxc_block_table_type)
    IS

          l_index   BINARY_INTEGER;

    BEGIN
        l_index := p_blocks.FIRST;
        LOOP
           IF p_blocks(l_index).SCOPE = 'DAY'
           THEN
              l_day_scope(p_blocks(l_index).time_building_block_id) :=
                          p_blocks(l_index).parent_building_block_id;
           END IF;
           l_index := p_blocks.NEXT(l_index);
           EXIT WHEN NOT p_blocks.EXISTS(l_index);
         END LOOP;
    END pick_up_day_scope;

BEGIN

g_debug := hr_utility.debug_enabled;

-- Bug 8888801
-- Initializing the tables for Insert/Update App specific
-- details.
pa_resource_id_tab               :=NUMTAB();
pa_time_building_block_id_tab    :=NUMTAB();
pa_object_version_number_tab 	 :=NUMTAB();
pa_application_set_id_tab	 :=NUMTAB();
pa_org_id_tab     		 :=NUMTAB();
pa_business_group_id_tab 	 :=NUMTAB();
pa_timecard_id_tab		 :=NUMTAB();
pa_start_time_tab 		 :=DATETAB();
pa_stop_time_tab 		 :=DATETAB();
pa_last_update_date_tab		 :=DATETAB();
pa_approval_status_tab 		 :=VARCHARTAB();
pa_comment_text_tab 		 :=VARCHARTAB();
pa_resource_type_tab  		 :=VARCHARTAB();

pay_resource_id_tab              :=NUMTAB();
pay_time_building_block_id_tab   :=NUMTAB();
pay_object_version_number_tab 	 :=NUMTAB();
pay_application_set_id_tab	 :=NUMTAB();
pay_org_id_tab     		 :=NUMTAB();
pay_business_group_id_tab 	 :=NUMTAB();
pay_timecard_id_tab		 :=NUMTAB();
pay_start_time_tab 		 :=DATETAB();
pay_stop_time_tab 		 :=DATETAB();
pay_last_update_date_tab	 :=DATETAB();
pay_approval_status_tab 	 :=VARCHARTAB();
pay_comment_text_tab 		 :=VARCHARTAB();
pay_resource_type_tab  		 :=VARCHARTAB();

-- Bug 8888911
l_blk_ind := p_blocks.FIRST;

BEGIN
    l_org_id := hr_organization_api.get_operating_unit (p_effective_date  => SYSDATE
                                                       ,p_person_id       => p_blocks(l_blk_ind).resource_id);

   EXCEPTION
      WHEN OTHERS THEN
         l_org_id := FND_PROFILE.VALUE('ORG_ID');
END;

l_bg_id := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');


if g_debug then
	hr_utility.trace('In maintain details 1');
end if;

  hxc_timecard_block_utils.sort_blocks
   (p_blocks          => p_blocks
   ,p_timecard_blocks => l_timecard_blocks
   ,p_day_blocks      => l_day_blocks
   ,p_detail_blocks   => l_detail_blocks
   );

l_detail_ind := l_detail_blocks.FIRST;
-- Bug 8888801
-- Pick up the timecard id from the blocks list.
l_timecard_id := p_blocks(l_blk_ind).time_building_block_id;

-- Bug 9684373
-- Added this call to populate the day scope records and against them,
-- the respective timecard_ids.
pick_up_day_scope(p_blocks);

WHILE l_detail_ind IS NOT NULL
LOOP

	l_blk_ind := l_detail_blocks(l_detail_ind);

--if g_debug then
--	hr_utility.trace('resource_id is '||to_char(p_blocks(l_blk_ind).resource_id));
--	hr_utility.trace('tbb id      is '||to_char(p_blocks(l_blk_ind).time_building_Block_id));
--	hr_utility.trace('ovn         is '||to_char(p_blocks(l_blk_ind).object_version_number));
--	hr_utility.trace('process     is '||p_blocks(l_blk_ind).process);
--	hr_utility.trace('approval    is '||p_blocks(l_blk_ind).approval_status);
--end if;

	-- Override status for deleted building blocks. These should always be passed to
	-- recipient applications for processing once deleted.

	IF ( fnd_date.canonical_to_date(( p_blocks(l_blk_ind).date_to )) = hr_general.end_of_time )
	THEN

		l_status := p_blocks(l_blk_ind).approval_status;

	ELSE

		l_status := 'SUBMITTED';

	END IF;

	IF ( p_blocks(l_blk_ind).object_version_number = 1 AND p_blocks(l_blk_ind).process = 'Y' )
	THEN

	--if g_debug then
--		hr_utility.trace('gaz about to insert '||to_char(p_blocks(l_blk_ind).time_building_Block_id));
	--end if;

		-- insert row

		INSERT INTO hxc_latest_details (
			resource_id,
			time_building_block_id,
			object_version_number,
			approval_status,
			start_time,
			stop_time,
                        application_set_id,
			last_update_date,
                        comment_text,
                        resource_type,
                        org_id,
                        business_group_id )                      -- Bug 8888911
		VALUES (
			p_blocks(l_blk_ind).resource_id,
			p_blocks(l_blk_ind).time_building_block_id,
			p_blocks(l_blk_ind).object_version_number,
			l_status,
                        hxc_timecard_block_utils.date_value(
                          p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time),
                        hxc_timecard_block_utils.date_value(
                          p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time),
                        p_blocks(l_blk_ind).application_set_id,
			sysdate,
                        p_blocks(l_blk_ind).comment_text,
                        p_blocks(l_blk_ind).resource_type ,
                        l_org_id,
                        l_bg_id );                                -- Bug 8888911


          -- Bug 8888801
          -- If Payroll is a valid recipient for this Application set,
          -- add the details to the tables.
          IF valid_time_recipient('Payroll',p_blocks(l_blk_ind).application_set_id)
          THEN
                        extend_tables('PAY');
                        l_pay_index := l_pay_index + 1;
                        pay_resource_id_tab(l_pay_index) :=            p_blocks(l_blk_ind).resource_id;
			pay_time_building_block_id_tab(l_pay_index) := p_blocks(l_blk_ind).time_building_block_id;
			pay_object_version_number_tab(l_pay_index) :=  p_blocks(l_blk_ind).object_version_number;
			pay_application_set_id_tab(l_pay_index) :=	  p_blocks(l_blk_ind).application_set_id;
                        pay_org_id_tab(l_pay_index) :=     		  l_org_id;
                        pay_business_group_id_tab(l_pay_index) := 	  l_bg_id;
			-- Bug 9684373
                        --pay_timecard_id_tab(l_pay_index) :=		l_timecard_id;
                        pay_timecard_id_tab(l_pay_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			pay_start_time_tab(l_pay_index) := 		hxc_timecard_block_utils.date_value
			                      (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                        pay_stop_time_tab(l_pay_index) := 		hxc_timecard_block_utils.date_value
                                              (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                        pay_last_update_date_tab(l_pay_index) :=	SYSDATE;
                        pay_approval_status_tab(l_pay_index) := 	l_status;
                        pay_comment_text_tab(l_pay_index) := 	p_blocks(l_blk_ind).comment_text;
                        pay_resource_type_tab(l_pay_index) :=  	p_blocks(l_blk_ind).resource_type;


          END IF;

          -- Bug 8888801
          -- If Projects is a valid recipient for this Application set,
          -- add the details to the tables.
          IF valid_time_recipient('Projects',p_blocks(l_blk_ind).application_set_id)
          THEN
                        extend_tables('PA');
                        l_pa_index := l_pa_index + 1;
			pa_resource_id_tab(l_pa_index) :=            p_blocks(l_blk_ind).resource_id;
			pa_time_building_block_id_tab(l_pa_index) := p_blocks(l_blk_ind).time_building_block_id;
			pa_object_version_number_tab(l_pa_index) :=  p_blocks(l_blk_ind).object_version_number;
			pa_application_set_id_tab(l_pa_index) :=	  p_blocks(l_blk_ind).application_set_id;
                        pa_org_id_tab(l_pa_index) :=     		  l_org_id;
                        pa_business_group_id_tab(l_pa_index) := 	  l_bg_id;
			-- Bug 9684373
--                        pa_timecard_id_tab(l_pa_index) :=		l_timecard_id;
                        pa_timecard_id_tab(l_pa_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			pa_start_time_tab(l_pa_index) := 		hxc_timecard_block_utils.date_value
			                       (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                        pa_stop_time_tab(l_pa_index) := 		hxc_timecard_block_utils.date_value
                                               (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                        pa_last_update_date_tab(l_pa_index) :=	SYSDATE;
                        pa_approval_status_tab(l_pa_index) := 	l_status;
                        pa_comment_text_tab(l_pa_index) := 	p_blocks(l_blk_ind).comment_text;
                        pa_resource_type_tab(l_pa_index) :=  	p_blocks(l_blk_ind).resource_type;

          END IF;


	ELSIF ( p_blocks(l_blk_ind).object_version_number > 1 and p_blocks(l_blk_ind).process = 'Y' )
	THEN
	--if g_debug then
--		hr_utility.trace('gaz about to update '||to_char(p_blocks(l_blk_ind).time_building_Block_id));
	--end if;

		-- update row

		UPDATE hxc_latest_details
		SET    object_version_number = p_blocks(l_blk_ind).object_version_number,
                       approval_status       = l_status,
                       application_set_id    = p_blocks(l_blk_ind).application_set_id,
                       last_update_date      = sysdate,
                       comment_text          = p_blocks(l_blk_ind).comment_text,
                       resource_type         = p_blocks(l_blk_ind).resource_type,
                       org_id                = l_org_id,    -- Bug 8888911
                       business_group_id     = l_bg_id      -- Bug 8888911
		WHERE  time_building_block_id = p_blocks(l_blk_ind).time_building_block_id;

		IF ( SQL%ROWCOUNT = 0 )
		THEN
			-- nothing to update, insert

		    INSERT INTO hxc_latest_details (
			    resource_id,
			    time_building_block_id,
			    object_version_number,
			    approval_status,
			    start_time,
			    stop_time,
                            application_set_id,
			    last_update_date,
                            comment_text,
                            resource_type ,
                            org_id,    -- Bug 8888911
                            business_group_id)    -- Bug 8888911
		    VALUES (
			    p_blocks(l_blk_ind).resource_id,
			    p_blocks(l_blk_ind).time_building_block_id,
			    p_blocks(l_blk_ind).object_version_number,
			    l_status,
                            hxc_timecard_block_utils.date_value(
                              p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time),
                            hxc_timecard_block_utils.date_value(
                              p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time),
                            p_blocks(l_blk_ind).application_set_id,
			    sysdate,
                            p_blocks(l_blk_ind).comment_text,
                            p_blocks(l_blk_ind).resource_type ,
                            l_org_id,    -- Bug 8888911
                            l_bg_id );   -- Bug 8888911


                    -- Bug 8888801
                    -- If Payroll is a valid recipient for this Application set,
                    -- add the details to the tables.

                    IF valid_time_recipient('Payroll',p_blocks(l_blk_ind).application_set_id)
          	    THEN
                            extend_tables('PAY');
                            l_pay_index                                 := l_pay_index + 1;
                            pay_resource_id_tab(l_pay_index)            := p_blocks(l_blk_ind).resource_id;
			    pay_time_building_block_id_tab(l_pay_index) := p_blocks(l_blk_ind).time_building_block_id;
			    pay_object_version_number_tab(l_pay_index)  := p_blocks(l_blk_ind).object_version_number;
			    pay_application_set_id_tab(l_pay_index)     := p_blocks(l_blk_ind).application_set_id;
                            pay_org_id_tab(l_pay_index)                 := l_org_id;
                            pay_business_group_id_tab(l_pay_index)      := l_bg_id;
			    -- Bug 9684373
                            pay_timecard_id_tab(l_pay_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			    pay_start_time_tab(l_pay_index)             := hxc_timecard_block_utils.date_value
			                      (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                            pay_stop_time_tab(l_pay_index) := 		hxc_timecard_block_utils.date_value
                                                  (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                            pay_last_update_date_tab(l_pay_index)       := SYSDATE;
                            pay_approval_status_tab(l_pay_index)        := l_status;
                            pay_comment_text_tab(l_pay_index)           := p_blocks(l_blk_ind).comment_text;
                            pay_resource_type_tab(l_pay_index)          := p_blocks(l_blk_ind).resource_type;
                    END IF;


                    -- Bug 8888801
                    -- If Projects is a valid recipient for this Application set,
                    -- add the details to the tables.

                    IF valid_time_recipient('Projects',p_blocks(l_blk_ind).application_set_id)
          	    THEN
                            extend_tables('PA');
                            l_pa_index := l_pa_index + 1;
                            pa_resource_id_tab(l_pa_index)            := p_blocks(l_blk_ind).resource_id;
			    pa_time_building_block_id_tab(l_pa_index) := p_blocks(l_blk_ind).time_building_block_id;
			    pa_object_version_number_tab(l_pa_index)  := p_blocks(l_blk_ind).object_version_number;
			    pa_application_set_id_tab(l_pa_index)     := p_blocks(l_blk_ind).application_set_id;
                            pa_org_id_tab(l_pa_index)                 := l_org_id;
                            pa_business_group_id_tab(l_pa_index)      := l_bg_id;
			    -- Bug 9684373
                            pa_timecard_id_tab(l_pa_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			    pa_start_time_tab(l_pa_index)             := hxc_timecard_block_utils.date_value
			                     (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                            pa_stop_time_tab(l_pa_index) := 		hxc_timecard_block_utils.date_value
                                                 (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                            pa_last_update_date_tab(l_pa_index)       := SYSDATE;
                            pa_approval_status_tab(l_pa_index)        := l_status;
                            pa_comment_text_tab(l_pa_index)           := p_blocks(l_blk_ind).comment_text;
                            pa_resource_type_tab(l_pa_index)          := p_blocks(l_blk_ind).resource_type;

                    END IF;

                ELSE

                    -- Bug 8888801
                    -- If Payroll is a valid recipient for this Application set,
                    -- add the details to the tables.
                    IF valid_time_recipient('Payroll',p_blocks(l_blk_ind).application_set_id)
          	    THEN
                            extend_tables('PAY');
                            l_pay_index := l_pay_index + 1;
                            pay_resource_id_tab(l_pay_index)            := p_blocks(l_blk_ind).resource_id;
			    pay_time_building_block_id_tab(l_pay_index) := p_blocks(l_blk_ind).time_building_block_id;
			    pay_object_version_number_tab(l_pay_index)  := p_blocks(l_blk_ind).object_version_number;
			    pay_application_set_id_tab(l_pay_index)     := p_blocks(l_blk_ind).application_set_id;
                            pay_org_id_tab(l_pay_index)                 := l_org_id;
                            pay_business_group_id_tab(l_pay_index)      := l_bg_id;
			    -- Bug 9684373
                            pay_timecard_id_tab(l_pay_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			    pay_start_time_tab(l_pay_index)             := hxc_timecard_block_utils.date_value
			                      (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                            pay_stop_time_tab(l_pay_index) := 		hxc_timecard_block_utils.date_value
                                                  (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                            pay_last_update_date_tab(l_pay_index)       := SYSDATE;
                            pay_approval_status_tab(l_pay_index)        := l_status;
                            pay_comment_text_tab(l_pay_index)           := p_blocks(l_blk_ind).comment_text;
                            pay_resource_type_tab(l_pay_index)          := p_blocks(l_blk_ind).resource_type;


                    END IF;

                    -- Bug 8888801
                    -- If Projects is a valid recipient for this Application set,
                    -- add the details to the tables.
                    IF valid_time_recipient('Projects',p_blocks(l_blk_ind).application_set_id)
                    THEN
                            extend_tables('PA');
                            l_pa_index := l_pa_index + 1;
                            pa_resource_id_tab(l_pa_index)            := p_blocks(l_blk_ind).resource_id;
			    pa_time_building_block_id_tab(l_pa_index) := p_blocks(l_blk_ind).time_building_block_id;
			    pa_object_version_number_tab(l_pa_index)  := p_blocks(l_blk_ind).object_version_number;
			    pa_application_set_id_tab(l_pa_index)     := p_blocks(l_blk_ind).application_set_id;
                            pa_org_id_tab(l_pa_index)                 := l_org_id;
                            pa_business_group_id_tab(l_pa_index)      := l_bg_id;
			    -- Bug 9684373
                            pa_timecard_id_tab(l_pa_index) :=		l_day_scope(p_blocks(l_blk_ind).parent_building_block_id);
			    pa_start_time_tab(l_pa_index)             := hxc_timecard_block_utils.date_value
			                     (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).start_time);
                            pa_stop_time_tab(l_pa_index) := 		hxc_timecard_block_utils.date_value
                                                 (p_blocks(l_day_blocks(p_blocks(l_blk_ind).parent_building_block_id)).stop_time);
                            pa_last_update_date_tab(l_pa_index)       := SYSDATE;
                            pa_approval_status_tab(l_pa_index)        := l_status;
                            pa_comment_text_tab(l_pa_index)           := p_blocks(l_blk_ind).comment_text;
                            pa_resource_type_tab(l_pa_index)          := p_blocks(l_blk_ind).resource_type;

                    END IF;

		END IF;



	END IF;

	l_detail_ind := l_detail_blocks.NEXT(l_detail_ind);

END LOOP;


        -- Bug 8888801
        -- Updating hxc_pa_latest_details
        -- with details specific for the application.
        FORALL i IN pa_resource_id_tab.FIRST..pa_resource_id_tab.LAST
           UPDATE hxc_pa_latest_details
              SET object_version_number = pa_object_version_number_tab(i),
                  approval_status       = pa_approval_status_tab(i),
                  application_set_id    = pa_application_set_id_tab(i),
                  last_update_date      = pa_last_update_date_tab(i),
                  comment_text          = pa_comment_text_tab(i),
                  resource_type         = pa_resource_type_tab(i),
                  org_id                = pa_org_id_tab(i),
                  business_group_id     = pa_business_group_id_tab(i)
            WHERE time_building_block_id = pa_time_building_block_id_tab(i);

        -- Bug 8888801
        -- Updating hxc_pay_latest_details
        -- with details specific for the application.
        FORALL i IN pay_resource_id_tab.FIRST..pay_resource_id_tab.LAST
           UPDATE hxc_pay_latest_details
              SET object_version_number = pay_object_version_number_tab(i),
                  approval_status       = pay_approval_status_tab(i),
                  application_set_id    = pay_application_set_id_tab(i),
                  last_update_date      = pay_last_update_date_tab(i),
                  comment_text          = pay_comment_text_tab(i),
                  resource_type         = pay_resource_type_tab(i),
                  org_id                = pay_org_id_tab(i),
                  business_group_id     = pay_business_group_id_tab(i)
            WHERE time_building_block_id = pay_time_building_block_id_tab(i);


        -- Bug 8888801
        -- Inserting into hxc_pa_latest_details and hxc_pay_latest_details
        -- the respective details.  Save Exceptions will see to it that
        -- any exception is raised only at the end.
        -- with details specific for the application.
        BEGIN

        FORALL i IN pay_resource_id_tab.FIRST..pay_resource_id_tab.LAST SAVE EXCEPTIONS
          INSERT INTO hxc_pay_latest_details
                       (
			resource_id,
			time_building_block_id,
			object_version_number,
			approval_status,
			start_time,
			stop_time,
                        application_set_id,
			last_update_date,
                        comment_text,
                        resource_type ,
                        org_id,
                        business_group_id,
                        timecard_id)
		   VALUES (
			pay_resource_id_tab(i),
			pay_time_building_block_id_tab(i),
			pay_object_version_number_tab(i),
			pay_approval_status_tab(i),
                        pay_start_time_tab(i),
                        pay_stop_time_tab(i),
                        pay_application_set_id_tab(i),
	                pay_last_update_date_tab(i),
                        pay_comment_text_tab(i),
                        pay_resource_type_tab(i) ,
                        pay_org_id_tab(i),
                        pay_business_group_id_tab(i),
                        pay_timecard_id_tab(i));

           EXCEPTION

             WHEN TABLE_EXCEPTION
             THEN
                 NULL;

        END;


        BEGIN

        FORALL i IN pa_resource_id_tab.FIRST..pa_resource_id_tab.LAST SAVE EXCEPTIONS
          INSERT INTO hxc_pa_latest_details
                       (
			resource_id,
			time_building_block_id,
			object_version_number,
			approval_status,
			start_time,
			stop_time,
                        application_set_id,
			last_update_date,
                        comment_text,
                        resource_type ,
                        org_id,
                        business_group_id,
                        timecard_id)
		   VALUES (
			pa_resource_id_tab(i),
			pa_time_building_block_id_tab(i),
			pa_object_version_number_tab(i),
			pa_approval_status_tab(i),
                        pa_start_time_tab(i),
                        pa_stop_time_tab(i),
                        pa_application_set_id_tab(i),
	                pa_last_update_date_tab(i),
                        pa_comment_text_tab(i),
                        pa_resource_type_tab(i) ,
                        pa_org_id_tab(i),
                        pa_business_group_id_tab(i),
                        pa_timecard_id_tab(i));

           EXCEPTION

             WHEN TABLE_EXCEPTION
             THEN
                 NULL;

        END;


EXCEPTION
        -- Bug 8888801
        -- IF an ORA - 24381 occurs, do nothing.
        WHEN TABLE_EXCEPTION
        THEN
            NULL;
        WHEN OTHERS THEN

            hr_utility.trace(dbms_utility.format_error_backtrace);
            IF g_debug
            THEN
          	hr_utility.trace(SQLERRM);

            END IF;

            RAISE;

END maintain_latest_details;

FUNCTION valid_time_recipient(p_recipient   IN VARCHAR2,
                              p_app_set_id  IN NUMBER)
RETURN BOOLEAN
IS

l_exists NUMBER := 0;

BEGIN

    IF NOT g_valid_rec.EXISTS(p_recipient||'-'||p_app_set_id)
    THEN

      BEGIN
        SELECT 1
          INTO l_exists
          FROM hxc_application_set_comps_v
         WHERE application_set_id = p_app_set_id
           AND time_recipient_name = p_recipient;

        EXCEPTION
            WHEN NO_DATA_FOUND
               THEN
                 l_exists := 0;
       END;
        IF l_exists = 1
        THEN
           g_valid_rec(p_recipient||'-'||p_app_set_id) := 'TRUE';
           RETURN TRUE;
        ELSE
           g_valid_rec(p_recipient||'-'||p_app_set_id) := 'FALSE';
           RETURN FALSE;
        END IF;
   ELSE
      IF g_valid_rec(p_recipient||'-'||p_app_set_id) = 'TRUE'
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   END IF;


END valid_time_recipient;


/*Following proc added for Bug 8888904 */

PROCEDURE maintain_rdb_snapshot(p_blocks     IN hxc_block_table_type,
                                p_attributes IN hxc_attribute_table_type)
IS


l_index   BINARY_INTEGER:=0;


l_pa_att_index  BINARY_INTEGER:=0;
l_pay_att_index BINARY_INTEGER:=0;

TYPE VTAB IS TABLE OF VARCHAR2(2500);
TYPE NTAB IS TABLE OF NUMBER;

PA_TIME_ATTRIBUTE_ID    NTAB;
PA_BUILDING_BLOCK_ID    NTAB;
PA_BUILDING_BLOCK_OVN   NTAB;
PA_ATTRIBUTE_CATEGORY   VTAB;
PA_ATTRIBUTE1		VTAB;
PA_ATTRIBUTE2		VTAB;
PA_ATTRIBUTE3		VTAB;
PA_ATTRIBUTE4		VTAB;
PA_ATTRIBUTE5		VTAB;
PA_ATTRIBUTE6		VTAB;
PA_ATTRIBUTE7		VTAB;
PA_MEASURE		NTAB;

PAY_TIME_ATTRIBUTE_ID   NTAB;
PAY_BUILDING_BLOCK_ID   NTAB;
PAY_BUILDING_BLOCK_OVN  NTAB;
PAY_ATTRIBUTE_CATEGORY  VTAB;
PAY_ATTRIBUTE1		VTAB;
PAY_ATTRIBUTE2		VTAB;
PAY_ATTRIBUTE3		VTAB;
PAY_ATTRIBUTE4		VTAB;
PAY_ATTRIBUTE5		VTAB;
PAY_ATTRIBUTE6		VTAB;
PAY_ATTRIBUTE7		VTAB;
PAY_MEASURE		NTAB;

TYPE ATTR_TBB_MAP_TYPE IS TABLE OF NUMBER
             INDEX BY VARCHAR2(250);

PAY_ATTR_TBB_MAP	ATTR_TBB_MAP_TYPE;
PA_ATTR_TBB_MAP		ATTR_TBB_MAP_TYPE;

l_measure 		NUMBER;
l_start_time		DATE;
l_stop_time		DATE;

l_resource_id		NUMBER;
l_pref_date		DATE;
l_pref_table		hxc_preference_evaluation.t_pref_table;
l_resource_rdb_enabled	VARCHAR2(1):='N';
l_pref_index		NUMBER;

/*
CURSOR get_upgrade_status
IS
SELECT 'Y'
  FROM HXC_UPGRADE_DEFINITIONS
 WHERE upg_type = 'RDB_ATTRIB_SNAPSHOT'
   AND status = 'COMPLETE';

upg_status 	VARCHAR2(1):='N';
*/

  FUNCTION valid_bld_blk_info_type(p_bld_blk_info_type IN VARCHAR2)
  RETURN NUMBER
  IS

  l_bld_blk_info_type_id	NUMBER:=0;

  BEGIN

  IF NOT g_valid_bld_blk.EXISTS(p_bld_blk_info_type)   THEN

        BEGIN
          select bld_blk_info_type_id
            into l_bld_blk_info_type_id
            from hxc_bld_blk_info_types
           where bld_blk_info_type = p_bld_blk_info_type;


        EXCEPTION
            WHEN NO_DATA_FOUND
               THEN
                 l_bld_blk_info_type_id := 0;
        END;

        g_valid_bld_blk(p_bld_blk_info_type):= l_bld_blk_info_type_id;

  END IF; --g_valid_bld_blk

  RETURN g_valid_bld_blk(p_bld_blk_info_type);
  END valid_bld_blk_info_type;

  PROCEDURE EXTEND_ATTR_TAB(p_appln	VARCHAR2)
  IS
  BEGIN

  IF p_appln = 'PAY' then


  	PAY_TIME_ATTRIBUTE_ID.EXTEND(1);
  	PAY_BUILDING_BLOCK_ID.EXTEND(1);
  	PAY_BUILDING_BLOCK_OVN.EXTEND(1);
  	PAY_ATTRIBUTE_CATEGORY.EXTEND(1);
  	PAY_ATTRIBUTE1.EXTEND(1);
  	PAY_ATTRIBUTE2.EXTEND(1);
  	PAY_ATTRIBUTE3.EXTEND(1);
  	PAY_ATTRIBUTE4.EXTEND(1);
  	PAY_ATTRIBUTE5.EXTEND(1);
  	PAY_ATTRIBUTE6.EXTEND(1);
  	PAY_ATTRIBUTE7.EXTEND(1);
  	PAY_MEASURE.EXTEND(1);

  ELSIF p_appln = 'PA' then

  	PA_TIME_ATTRIBUTE_ID.EXTEND(1);
  	PA_BUILDING_BLOCK_ID.EXTEND(1);
  	PA_BUILDING_BLOCK_OVN.EXTEND(1);
  	PA_ATTRIBUTE_CATEGORY.EXTEND(1);
  	PA_ATTRIBUTE1.EXTEND(1);
  	PA_ATTRIBUTE2.EXTEND(1);
  	PA_ATTRIBUTE3.EXTEND(1);
  	PA_ATTRIBUTE4.EXTEND(1);
  	PA_ATTRIBUTE5.EXTEND(1);
  	PA_ATTRIBUTE6.EXTEND(1);
  	PA_ATTRIBUTE7.EXTEND(1);
        PA_MEASURE.EXTEND(1);

  END IF; -- p_appln

  END EXTEND_ATTR_TAB;





BEGIN -- maintain_rdb_snapshot

l_resource_id:= p_blocks(p_blocks.FIRST).RESOURCE_ID;
l_pref_date:= TO_DATE( p_blocks(p_blocks.FIRST).START_TIME , 'RRRR/MM/DD HH24:MI:SS');

-- Bug 8888905
hxc_preference_evaluation.resource_preferences
	                 (p_resource_id           => l_resource_id,
	    	          p_start_evaluation_date => l_pref_date,
	    	          p_end_evaluation_date   => l_pref_date,
	                  p_pref_table            => l_pref_table);

l_pref_index := l_pref_table.FIRST;
  LOOP
       IF l_pref_table(l_pref_index).preference_code = 'TS_RDB_PREFERENCES'
          THEN
              l_resource_rdb_enabled := l_pref_table(l_pref_index).attribute1;
              EXIT;
       END IF;
     l_pref_index := l_pref_table.NEXT(l_pref_index);
  EXIT WHEN NOT l_pref_table.EXISTS(l_pref_index);
  END LOOP;

IF nvl(l_resource_rdb_enabled,'N') <> 'Y' THEN

        if g_debug then
             	hr_utility.trace('RDB Snapshot Pref not enabled');
        end if;
	return;
END IF;


-- initialize the pay/pa plsql tables

PA_TIME_ATTRIBUTE_ID  	:=     	NTAB();
PA_BUILDING_BLOCK_ID	:=    	NTAB();
PA_BUILDING_BLOCK_OVN	:=    	NTAB();
PA_ATTRIBUTE_CATEGORY	:=    	VTAB();
PA_ATTRIBUTE1		:=	VTAB();
PA_ATTRIBUTE2		:=	VTAB();
PA_ATTRIBUTE3		:=	VTAB();
PA_ATTRIBUTE4		:=	VTAB();
PA_ATTRIBUTE5		:=	VTAB();
PA_ATTRIBUTE6		:=	VTAB();
PA_ATTRIBUTE7		:=	VTAB();
PA_MEASURE              :=      NTAB();

PAY_TIME_ATTRIBUTE_ID   :=	NTAB();
PAY_BUILDING_BLOCK_ID   :=	NTAB();
PAY_BUILDING_BLOCK_OVN  :=      NTAB();
PAY_ATTRIBUTE_CATEGORY  :=	VTAB();
PAY_ATTRIBUTE1		:=	VTAB();
PAY_ATTRIBUTE2		:=	VTAB();
PAY_ATTRIBUTE3		:=	VTAB();
PAY_ATTRIBUTE4		:=	VTAB();
PAY_ATTRIBUTE5		:=	VTAB();
PAY_ATTRIBUTE6		:=	VTAB();
PAY_ATTRIBUTE7		:=	VTAB();
PAY_MEASURE             :=      NTAB();




if g_debug then
	 hr_utility.trace('maintain_rdb_snapshot');

	 if (p_blocks.count>0) then


	    hr_utility.trace('  P_BLOCK TABLE START ');
	    hr_utility.trace(' *****************');

	    l_index := p_blocks.FIRST;

	     LOOP
	       EXIT WHEN NOT p_blocks.EXISTS (l_index);


	      hr_utility.trace(' TIME_BUILDING_BLOCK_ID      =   '|| p_blocks(l_index).TIME_BUILDING_BLOCK_ID     );
	      hr_utility.trace(' TYPE =   '|| p_blocks(l_index).TYPE )    ;
	      hr_utility.trace(' MEASURE =   '|| p_blocks(l_index).MEASURE)    ;
	      hr_utility.trace(' UNIT_OF_MEASURE     =       '|| p_blocks(l_index).UNIT_OF_MEASURE        )    ;
	      hr_utility.trace(' START_TIME     =       '|| p_blocks(l_index).START_TIME        )    ;
	      hr_utility.trace(' STOP_TIME      =       '|| p_blocks(l_index).STOP_TIME        )    ;
	      hr_utility.trace(' PARENT_BUILDING_BLOCK_ID  =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_ID        )    ;
	      hr_utility.trace(' PARENT_IS_NEW     =       '|| p_blocks(l_index).PARENT_IS_NEW        )    ;
	      hr_utility.trace(' SCOPE     =       '|| p_blocks(l_index).SCOPE        )    ;
	      hr_utility.trace(' OBJECT_VERSION_NUMBER     =       '|| p_blocks(l_index).OBJECT_VERSION_NUMBER        )    ;
	      hr_utility.trace(' APPROVAL_STATUS     =       '|| p_blocks(l_index).APPROVAL_STATUS        )    ;
	      hr_utility.trace(' RESOURCE_ID     =       '|| p_blocks(l_index).RESOURCE_ID        )    ;
	      hr_utility.trace(' RESOURCE_TYPE    =       '|| p_blocks(l_index).RESOURCE_TYPE       )    ;
	      hr_utility.trace(' APPROVAL_STYLE_ID    =       '|| p_blocks(l_index).APPROVAL_STYLE_ID       )    ;
	      hr_utility.trace(' DATE_FROM    =       '|| p_blocks(l_index).DATE_FROM       )    ;
	      hr_utility.trace(' DATE_TO    =       '|| p_blocks(l_index).DATE_TO       )    ;
	      hr_utility.trace(' COMMENT_TEXT    =       '|| p_blocks(l_index).COMMENT_TEXT       )    ;
	      hr_utility.trace(' PARENT_BUILDING_BLOCK_OVN     =       '|| p_blocks(l_index).PARENT_BUILDING_BLOCK_OVN        )    ;
	      hr_utility.trace(' NEW    =       '|| p_blocks(l_index).NEW       )    ;
	      hr_utility.trace(' CHANGED    =       '|| p_blocks(l_index).CHANGED       )    ;
	      hr_utility.trace(' PROCESS    =       '|| p_blocks(l_index).PROCESS       )    ;
	      hr_utility.trace(' APPLICATION_SET_ID    =       '|| p_blocks(l_index).APPLICATION_SET_ID       )    ;
	      hr_utility.trace(' TRANSLATION_DISPLAY_KEY    =       '|| p_blocks(l_index).TRANSLATION_DISPLAY_KEY       )    ;
	      hr_utility.trace('------------------------------------------------------');

	      l_index := p_blocks.NEXT (l_index);

	      END LOOP;

	        hr_utility.trace('  p_blocks TABLE END ');
	        hr_utility.trace(' *****************');

	          end if;


	     if (p_attributes.count>0) then


	    hr_utility.trace('  ATTRIBUTES TABLE START ');
	    hr_utility.trace(' *****************');

	    l_index := p_attributes.FIRST;

	     LOOP
	       EXIT WHEN NOT p_attributes.EXISTS (l_index);


	      hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| p_attributes(l_index).TIME_ATTRIBUTE_ID);
	      hr_utility.trace(' BUILDING_BLOCK_ID =   '|| p_attributes(l_index).BUILDING_BLOCK_ID )    ;
	      hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| p_attributes(l_index).ATTRIBUTE_CATEGORY)    ;
	      hr_utility.trace(' ATTRIBUTE1     =       '|| p_attributes(l_index).ATTRIBUTE1        )    ;
	      hr_utility.trace(' ATTRIBUTE2  (p_alias_definition_id)   =       '|| p_attributes(l_index).ATTRIBUTE2        )    ;
	      hr_utility.trace(' ATTRIBUTE3  (l_alias_value_id)    =       '|| p_attributes(l_index).ATTRIBUTE3        )    ;
	      hr_utility.trace(' ATTRIBUTE4  (p_alias_type)   =       '|| p_attributes(l_index).ATTRIBUTE4        )    ;
	      hr_utility.trace(' ATTRIBUTE5     =       '|| p_attributes(l_index).ATTRIBUTE5        )    ;
	      hr_utility.trace(' ATTRIBUTE6     =       '|| p_attributes(l_index).ATTRIBUTE6        )    ;
	      hr_utility.trace(' ATTRIBUTE7     =       '|| p_attributes(l_index).ATTRIBUTE7        )    ;
	      hr_utility.trace(' ATTRIBUTE8     =       '|| p_attributes(l_index).ATTRIBUTE8        )    ;
	      hr_utility.trace(' ATTRIBUTE9     =       '|| p_attributes(l_index).ATTRIBUTE9        )    ;
	      hr_utility.trace(' ATTRIBUTE10    =       '|| p_attributes(l_index).ATTRIBUTE10       )    ;
	      hr_utility.trace(' ATTRIBUTE11    =       '|| p_attributes(l_index).ATTRIBUTE11       )    ;
	      hr_utility.trace(' ATTRIBUTE12    =       '|| p_attributes(l_index).ATTRIBUTE12       )    ;
	      hr_utility.trace(' ATTRIBUTE13    =       '|| p_attributes(l_index).ATTRIBUTE13       )    ;
	      hr_utility.trace(' ATTRIBUTE14    =       '|| p_attributes(l_index).ATTRIBUTE14       )    ;
	      hr_utility.trace(' ATTRIBUTE15    =       '|| p_attributes(l_index).ATTRIBUTE15       )    ;
	      hr_utility.trace(' ATTRIBUTE16    =       '|| p_attributes(l_index).ATTRIBUTE16       )    ;
	      hr_utility.trace(' ATTRIBUTE17    =       '|| p_attributes(l_index).ATTRIBUTE17       )    ;
	      hr_utility.trace(' ATTRIBUTE18    =       '|| p_attributes(l_index).ATTRIBUTE18       )    ;
	      hr_utility.trace(' ATTRIBUTE19    =       '|| p_attributes(l_index).ATTRIBUTE19       )    ;
	      hr_utility.trace(' ATTRIBUTE20    =       '|| p_attributes(l_index).ATTRIBUTE20       )    ;
	      hr_utility.trace(' ATTRIBUTE21    =       '|| p_attributes(l_index).ATTRIBUTE21       )    ;
	      hr_utility.trace(' ATTRIBUTE22    =       '|| p_attributes(l_index).ATTRIBUTE22       )    ;
	      hr_utility.trace(' ATTRIBUTE23    =       '|| p_attributes(l_index).ATTRIBUTE23       )    ;
	      hr_utility.trace(' ATTRIBUTE24    =       '|| p_attributes(l_index).ATTRIBUTE24       )    ;
	      hr_utility.trace(' ATTRIBUTE25    =       '|| p_attributes(l_index).ATTRIBUTE25       )    ;
	      hr_utility.trace(' ATTRIBUTE26    =       '|| p_attributes(l_index).ATTRIBUTE26       )    ;
	      hr_utility.trace(' ATTRIBUTE27    =       '|| p_attributes(l_index).ATTRIBUTE27       )    ;
	      hr_utility.trace(' ATTRIBUTE28    =       '|| p_attributes(l_index).ATTRIBUTE28       )    ;
	      hr_utility.trace(' ATTRIBUTE29  (p_alias_ref_object)  =       '|| p_attributes(l_index).ATTRIBUTE29       )    ;
	      hr_utility.trace(' ATTRIBUTE30  (p_alias_value_name)  =       '|| p_attributes(l_index).ATTRIBUTE30       )    ;
	      hr_utility.trace(' BLD_BLK_INFO_TYPE_ID = '|| p_attributes(l_index).BLD_BLK_INFO_TYPE_ID  );
	      hr_utility.trace(' OBJECT_VERSION_NUMBER = '|| p_attributes(l_index).OBJECT_VERSION_NUMBER );
	      hr_utility.trace(' NEW             =       '|| p_attributes(l_index).NEW                   );
	      hr_utility.trace(' CHANGED              =  '|| p_attributes(l_index).CHANGED               );
	      hr_utility.trace(' BLD_BLK_INFO_TYPE    =  '|| p_attributes(l_index).BLD_BLK_INFO_TYPE     );
	      hr_utility.trace(' PROCESS              =  '|| p_attributes(l_index).PROCESS               );
	      hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| p_attributes(l_index).BUILDING_BLOCK_OVN    );
	      hr_utility.trace('------------------------------------------------------');

	      l_index := p_attributes.NEXT (l_index);

	      END LOOP;

	        hr_utility.trace('  ATTRIBUTES TABLE END ');
	        hr_utility.trace(' *****************');

	 end if;

end if; -- g_debug

/*
1. Put it into Globals - the bld_blk_ids of DUMMY ELEMENT CONTEXT and PROJECTS
2. Get the Attributes into 2 sep plsql tables - pa and pay based on the bld blk globals.
3. Make one forall update.
*/

if p_attributes.COUNT > 0 then

	     l_index := p_attributes.FIRST;

	     LOOP
	     EXIT WHEN NOT p_attributes.EXISTS (l_index);

             if p_attributes(l_index).BLD_BLK_INFO_TYPE_ID = valid_bld_blk_info_type('Dummy Element Context') then


                EXTEND_ATTR_TAB('PAY');
                l_pay_att_index:= l_pay_att_index +1;

             	PAY_TIME_ATTRIBUTE_ID(l_pay_att_index)	:=	p_attributes(l_index).TIME_ATTRIBUTE_ID;
		PAY_BUILDING_BLOCK_ID(l_pay_att_index)  :=	p_attributes(l_index).BUILDING_BLOCK_ID;
		PAY_BUILDING_BLOCK_OVN(l_pay_att_index) :=	p_attributes(l_index).BUILDING_BLOCK_OVN;
		PAY_ATTRIBUTE_CATEGORY(l_pay_att_index) :=	p_attributes(l_index).ATTRIBUTE_CATEGORY;
		PAY_ATTRIBUTE1(l_pay_att_index)   	:=	REPLACE(p_attributes(l_index).ATTRIBUTE_CATEGORY,'ELEMENT - ');
		PAY_ATTRIBUTE2(l_pay_att_index)   	:=	null ; --p_attributes(l_index).ATTRIBUTE2;
		PAY_ATTRIBUTE3(l_pay_att_index)   	:=	null ; -- p_attributes(l_index).ATTRIBUTE3;
		PAY_ATTRIBUTE4(l_pay_att_index)   	:=	null ; --p_attributes(l_index).ATTRIBUTE4;
		PAY_ATTRIBUTE5(l_pay_att_index)   	:=	null ; --p_attributes(l_index).ATTRIBUTE5;
		PAY_ATTRIBUTE6(l_pay_att_index)   	:=	null ; --p_attributes(l_index).ATTRIBUTE6;
                PAY_ATTRIBUTE7(l_pay_att_index)   	:=	null ; --p_attributes(l_index).ATTRIBUTE7;

                PAY_ATTR_TBB_MAP(p_attributes(l_index).BUILDING_BLOCK_ID ||':'||
                                 p_attributes(l_index).BUILDING_BLOCK_OVN)   := l_pay_att_index;

             elsif p_attributes(l_index).BLD_BLK_INFO_TYPE_ID = valid_bld_blk_info_type('PROJECTS') then

             	EXTEND_ATTR_TAB('PA');
		l_pa_att_index:= l_pa_att_index +1;

		PA_TIME_ATTRIBUTE_ID(l_pa_att_index)	:=	p_attributes(l_index).TIME_ATTRIBUTE_ID;
		PA_BUILDING_BLOCK_ID(l_pa_att_index)  :=	p_attributes(l_index).BUILDING_BLOCK_ID;
		PA_BUILDING_BLOCK_OVN(l_pa_att_index) :=	p_attributes(l_index).BUILDING_BLOCK_OVN;
		PA_ATTRIBUTE_CATEGORY(l_pa_att_index) :=	p_attributes(l_index).ATTRIBUTE_CATEGORY;
		PA_ATTRIBUTE1(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE1;
		PA_ATTRIBUTE2(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE2;
		PA_ATTRIBUTE3(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE3;
		PA_ATTRIBUTE4(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE4;
		PA_ATTRIBUTE5(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE5;
		PA_ATTRIBUTE6(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE6;
                PA_ATTRIBUTE7(l_pa_att_index)   	:=	p_attributes(l_index).ATTRIBUTE7;

                PA_ATTR_TBB_MAP(p_attributes(l_index).BUILDING_BLOCK_ID ||':'||
                                 p_attributes(l_index).BUILDING_BLOCK_OVN)   := l_pa_att_index;


             end if; -- BLD_BLK_INFO_TYPE_ID

             l_index := p_attributes.NEXT (l_index);

	     END LOOP; -- p_attributes

            /* Populating PA_MEASURE and PAY_MEASURE */

            l_pa_att_index:= 0;
	    l_pay_att_index:=0;

	    if p_blocks.COUNT > 0 then

	     l_index := p_blocks.FIRST;

	     LOOP
	      EXIT WHEN NOT p_blocks.EXISTS (l_index);

	       IF PAY_ATTR_TBB_MAP.EXISTS(p_blocks(l_index).TIME_BUILDING_BLOCK_ID || ':' ||
	                                p_blocks(l_index).OBJECT_VERSION_NUMBER) THEN


	     	l_pay_att_index:= PAY_ATTR_TBB_MAP(p_blocks(l_index).TIME_BUILDING_BLOCK_ID || ':' ||
	                                		   p_blocks(l_index).OBJECT_VERSION_NUMBER);

	    	if (p_blocks(l_index).DATE_TO <> fnd_date.date_to_canonical(hr_general.end_of_time)) then
	     		l_measure:=0; -- deleted entry
	     	elsif p_blocks(l_index).MEASURE IS NOT NULL then
	     		l_measure:= p_blocks(l_index).MEASURE;
	     	else
	     		l_stop_time:= TO_DATE(p_blocks(l_index).STOP_TIME , 'RRRR/MM/DD HH24:MI:SS');
			l_start_time := TO_DATE(p_blocks(l_index).START_TIME , 'RRRR/MM/DD HH24:MI:SS');
			l_measure:= ( TO_NUMBER(l_stop_time - l_start_time)
			              * 24 ) ;

			if l_measure < 0 then
			  	l_measure:= l_measure + 24;
	     		end if;
	     	end if;

	     	PAY_MEASURE(l_pay_att_index):= 	l_measure;

	       END IF;


	       IF PA_ATTR_TBB_MAP.EXISTS(p_blocks(l_index).TIME_BUILDING_BLOCK_ID || ':' ||
	     		                            p_blocks(l_index).OBJECT_VERSION_NUMBER) THEN


	     	l_pa_att_index:= PA_ATTR_TBB_MAP(p_blocks(l_index).TIME_BUILDING_BLOCK_ID || ':' ||
	     	                    		 p_blocks(l_index).OBJECT_VERSION_NUMBER);

	     	if (p_blocks(l_index).DATE_TO <> fnd_date.date_to_canonical(hr_general.end_of_time)) then
	     		l_measure:=0; -- deleted entry
	     	elsif p_blocks(l_index).MEASURE IS NOT NULL then
	     		l_measure:= p_blocks(l_index).MEASURE;
	     	else
	     	        l_stop_time:= TO_DATE(p_blocks(l_index).STOP_TIME , 'RRRR/MM/DD HH24:MI:SS');
	     	        l_start_time := TO_DATE(p_blocks(l_index).START_TIME , 'RRRR/MM/DD HH24:MI:SS');
	     		l_measure:= ( TO_NUMBER(l_stop_time - l_start_time)
	     		              * 24 ) ;

	     		if l_measure < 0 then
			  	l_measure:= l_measure + 24;
	     		end if;

	     	end if;

	     	PA_MEASURE(l_pa_att_index):= l_measure;

	      END IF;

	      l_index := p_blocks.NEXT (l_index);

	     END LOOP; -- p_blocks

            end if; -- p_block.count




            /*PRINTING THE PAY TAB*/
            /*time to print out the pa and pay specific stuff we have here */
            if g_debug then

	    if (PAY_TIME_ATTRIBUTE_ID.count>0) then


	    	hr_utility.trace('  PAY ATTRIBUTES TABLE START ');
	    	hr_utility.trace(' *****************');

	    	FOR i in PAY_TIME_ATTRIBUTE_ID.first .. PAY_TIME_ATTRIBUTE_ID.last LOOP


	      		hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| PAY_TIME_ATTRIBUTE_ID(i));
	      		hr_utility.trace(' BUILDING_BLOCK_ID =   '|| PAY_BUILDING_BLOCK_ID(i))   ;
	      		hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| PAY_ATTRIBUTE_CATEGORY(i))   ;
	      		hr_utility.trace(' ATTRIBUTE1     =       '|| PAY_ATTRIBUTE1(i));
	      		hr_utility.trace(' ATTRIBUTE2     =       '|| PAY_ATTRIBUTE2(i)) ;
	      		hr_utility.trace(' ATTRIBUTE3     =       '|| PAY_ATTRIBUTE3(i));
	      		hr_utility.trace(' ATTRIBUTE4     =       '|| PAY_ATTRIBUTE4(i)) ;
	      		hr_utility.trace(' ATTRIBUTE5     =       '|| PAY_ATTRIBUTE5(i))    ;
	      		hr_utility.trace(' ATTRIBUTE6     =       '|| PAY_ATTRIBUTE6(i))   ;
	      		hr_utility.trace(' ATTRIBUTE7     =       '|| PAY_ATTRIBUTE7(i))   ;
	      		hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| PAY_BUILDING_BLOCK_OVN(i));
	      		hr_utility.trace(' MEASURE              =  '|| PAY_MEASURE(i));
	      		hr_utility.trace('------------------------------------------------------');



	    	END LOOP;

	      	hr_utility.trace(' PAY ATTRIBUTES TABLE END ');
	      	hr_utility.trace(' *****************');


	    else

		hr_utility.trace('NO PAY ATTR');

	    end if;


           /*PRINTING THE PA TAB*/

	   if (PA_TIME_ATTRIBUTE_ID.count>0) then


	    	hr_utility.trace('  PA ATTRIBUTES TABLE START ');
	    	hr_utility.trace(' *****************');

	    	FOR i in PA_TIME_ATTRIBUTE_ID.first .. PA_TIME_ATTRIBUTE_ID.last LOOP


	      		hr_utility.trace(' TIME_ATTRIBUTE_ID =   '|| PA_TIME_ATTRIBUTE_ID(i));
	      		hr_utility.trace(' BUILDING_BLOCK_ID =   '|| PA_BUILDING_BLOCK_ID(i))   ;
	      		hr_utility.trace(' ATTRIBUTE_CATEGORY =   '|| PA_ATTRIBUTE_CATEGORY(i))   ;
	      		hr_utility.trace(' ATTRIBUTE1     =       '|| PA_ATTRIBUTE1(i))   ;
	      		hr_utility.trace(' ATTRIBUTE2     =       '|| PA_ATTRIBUTE2(i))    ;
	      		hr_utility.trace(' ATTRIBUTE3     =       '|| PA_ATTRIBUTE3(i))  ;
	      		hr_utility.trace(' ATTRIBUTE4     =       '|| PA_ATTRIBUTE4(i))   ;
	      		hr_utility.trace(' ATTRIBUTE5     =       '|| PA_ATTRIBUTE5(i))    ;
	      		hr_utility.trace(' ATTRIBUTE6     =       '|| PA_ATTRIBUTE6(i))   ;
	      		hr_utility.trace(' ATTRIBUTE7     =       '|| PA_ATTRIBUTE7(i))   ;
	      		hr_utility.trace(' BUILDING_BLOCK_OVN   =  '|| PA_BUILDING_BLOCK_OVN(i));
	      		hr_utility.trace(' MEASURE              =  '|| PA_MEASURE(i));
	      		hr_utility.trace('------------------------------------------------------');

	    	END LOOP;

	    	hr_utility.trace(' PA ATTRIBUTES TABLE END ');
	    	hr_utility.trace(' *****************');

	   else

		hr_utility.trace('NO PA ATTR');

	   end if;


        end if; --g_debug


	FORALL i IN PAY_TIME_ATTRIBUTE_ID.FIRST..PAY_TIME_ATTRIBUTE_ID.LAST
           UPDATE hxc_pay_latest_details
              SET ATTRIBUTE_CATEGORY = PAY_ATTRIBUTE_CATEGORY(i),
                  ATTRIBUTE1         = PAY_ATTRIBUTE1(i),
                  ATTRIBUTE2         = PAY_ATTRIBUTE2(i),
                  ATTRIBUTE3         = PAY_ATTRIBUTE3(i),
                  ATTRIBUTE4         = PAY_ATTRIBUTE4(i),
                  ATTRIBUTE5         = PAY_ATTRIBUTE5(i),
                  ATTRIBUTE6         = PAY_ATTRIBUTE6(i),
                  ATTRIBUTE7         = PAY_ATTRIBUTE7(i),
                  MEASURE            = PAY_MEASURE(i)
            WHERE TIME_BUILDING_BLOCK_ID = PAY_BUILDING_BLOCK_ID(i)
              AND OBJECT_VERSION_NUMBER = PAY_BUILDING_BLOCK_OVN(i);


	FORALL i IN PA_TIME_ATTRIBUTE_ID.FIRST..PA_TIME_ATTRIBUTE_ID.LAST
           UPDATE hxc_pa_latest_details
              SET ATTRIBUTE_CATEGORY = PA_ATTRIBUTE_CATEGORY(i),
                  ATTRIBUTE1         = PA_ATTRIBUTE1(i),
                  ATTRIBUTE2         = PA_ATTRIBUTE2(i),
                  ATTRIBUTE3         = PA_ATTRIBUTE3(i),
                  ATTRIBUTE4         = PA_ATTRIBUTE4(i),
                  ATTRIBUTE5         = PA_ATTRIBUTE5(i),
                  ATTRIBUTE6         = PA_ATTRIBUTE6(i),
                  ATTRIBUTE7         = PA_ATTRIBUTE7(i),
                  MEASURE            = PA_MEASURE(i)
            WHERE TIME_BUILDING_BLOCK_ID = PA_BUILDING_BLOCK_ID(i)
              AND OBJECT_VERSION_NUMBER = PA_BUILDING_BLOCK_OVN(i);

else

if g_debug then
hr_utility.trace('NO P_ATTRIBUTES');
end if;

end if; -- p_attributes.COUNT

if g_debug then
hr_utility.trace('Came out of maintain_rdb_snapshot');
end if;

END maintain_rdb_snapshot;

End hxc_timecard_audit;

/
