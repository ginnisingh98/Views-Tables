--------------------------------------------------------
--  DDL for Package Body WF_REPOPULATE_AQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_REPOPULATE_AQ" AS
/* $Header: WFAQREPB.pls 120.1 2005/07/02 04:26:06 appldev ship $ */

--
-- Procedure
--   Repopulate_SMTP_Item
--
-- Purpose
--   Repopulates the smtp with actions related to a particular item
--      Note: It does not clear off existing actions already on the queues...
--	instead we rely on the runtime code to verify actions still need to
--	be done.
--
-- Arguments:
--	Item_Type 	-- set to null for all items.
--	Item_Key  	-- set to null for all items in type.
--
Procedure Repopulate_SMTP_Item(	x_Item_Type in VARCHAR2,
				x_Item_Key in VARCHAR2)

is
  PRAGMA AUTONOMOUS_TRANSACTION;

  Cursor CN IS
  Select N.NOTIFICATION_ID
    from WF_ITEM_ACTIVITY_STATUSES IAS, WF_NOTIFICATIONS N
   where IAS.Item_Type = x_Item_Type
     and IAS.Item_Key  = x_Item_Key
     and IAS.NOTIFICATION_ID = N.GROUP_ID
     and N.status = 'OPEN'
     and N.mail_status in ('MAIL', 'INVALID');

  begin
        For CN_REC in CN Loop
	     wf_xml.EnqueueNotification(CN_REC.NOTIFICATION_ID);
        end loop;

        commit;
  end;

--
-- Procedure
--   Repopulate_Deferred_Item
--
-- Purpose
--   Repopulates the smtp with actions related to a particular item
--      Note: It does not clear off existing actions already on the queues...
--      instead we rely on the runtime code to verify actions still need to
--      be done.
--
-- Arguments:
--      Item_Type       -- set to null for all items.
--      Item_Key        -- set to null for all items in type.
--
Procedure Repopulate_Deferred_Item( x_Item_Type in VARCHAR2,
                                    x_Item_Key in VARCHAR2)

is
  PRAGMA AUTONOMOUS_TRANSACTION;

  Cursor CD IS
    select
         CWIAS.ITEM_TYPE,
         CWIAS.ITEM_KEY,
         CWIAS.PROCESS_ACTIVITY,
         greatest((CWIAS.BEGIN_DATE  - sysdate)*86400,0) delay
    from WF_ITEM_ACTIVITY_STATUSES CWIAS, WF_PROCESS_ACTIVITIES CWPA,
         WF_PROCESS_ACTIVITIES PWPA, WF_ITEM_ACTIVITY_STATUSES PWIAS
    where CWIAS.ACTIVITY_STATUS = 'DEFERRED'
    and CWIAS.PROCESS_ACTIVITY = CWPA.INSTANCE_ID
    and CWPA.ACTIVITY_ITEM_TYPE = x_Item_Type
    and CWIAS.ITEM_TYPE = x_Item_Type
    and CWIAS.ITEM_KEY = x_Item_Key
    and CWPA.PROCESS_NAME = PWPA.ACTIVITY_NAME
    and CWPA.PROCESS_ITEM_TYPE = PWPA.ACTIVITY_ITEM_TYPE
    and PWPA.INSTANCE_ID = PWIAS.PROCESS_ACTIVITY
    and PWIAS.ITEM_TYPE = CWIAS.ITEM_TYPE
    and PWIAS.ITEM_KEY = CWIAS.ITEM_KEY
    and PWIAS.ACTIVITY_STATUS <> 'SUSPEND';
  msg_id raw(16);

  begin
        For CD_REC in CD Loop
           wf_queue.enqueue_event
              (queuename=>wf_queue.DeferredQueue,
               itemtype=>CD_REC.item_type,
               itemkey=>CD_REC.item_key,
               actid=>CD_REC.process_activity,
               delay=>CD_REC.delay,
               message_handle=>msg_id);
           -- dont need a message handle
           msg_id := null;
        end loop;

        commit;
  end;

--
-- Procedure
--   PopulateAQforItem
--
-- Purpose
--   Repopulates the smtp and/or deferred queue with actions related to a
-- 	particular item, item type, or all items.  Note: It does not clear
--      off existing actions already on the queues...instead we rely on the
--	runtime code to verify actions still need to be done.
--
-- Arguments:
--	ItemType 	-- set to null for all items.
--	ItemKey  	-- set to null for all items in type.
--	SMTPFlag 	-- Y/N: repopulate smtp aq?
--	DeferredFlag 	-- Y/N: repopulate deferred aq?
--
Procedure PopulateAQforItem(	ItemType in VARCHAR2,
				ItemKey in VARCHAR2,
				SMTPFlag in VARCHAR2 ,
				DeferredFlag in VARCHAR2 )

is

  -- Bug 2497815.
  -- The query for the cursor is modified to refer to values in
  -- the variables l_item_type and l_item_key.

  l_item_type VARCHAR2(8)   := nvl(ItemType, '%');
  l_item_key  VARCHAR2(240) := nvl(ItemKey, '%');

  Cursor CI IS
  Select Item_Type, Item_Key
    from wf_items
   where Item_Type like l_item_type
     and Item_Key  like l_item_key
   order by 1,2;

  begin

     /* If both flags are 'N', the caller is an idiot, but let's not
        make the customer wait */
     if ((SmtpFlag = 'Y') OR (DeferredFlag = 'Y')) then
        For CI_REC in CI Loop
          if (SmtpFlag = 'Y') then
	     Repopulate_SMTP_Item(CI_REC.Item_Type, CI_REC.Item_Key);
          end if;

          if (DeferredFlag = 'Y') then
             Repopulate_Deferred_Item(CI_REC.Item_Type, CI_REC.Item_Key);
	  end if;
        end loop;
     end if;
  end;



END WF_Repopulate_AQ;

/
