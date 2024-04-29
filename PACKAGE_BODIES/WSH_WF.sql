--------------------------------------------------------
--  DDL for Package Body WSH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WF" as
/* $Header: WSHUTWFB.pls 120.0 2005/05/26 18:47:56 appldev noship $ */

   TYPE wfRecTyp IS RECORD (
	    source_header_id NUMBER,
	    source_code      VARCHAR2(10),
	    contact_type     VARCHAR2(10),
	    contact_id       NUMBER,
	    wf_started       BOOLEAN);

   TYPE wfRecTabTyp IS TABLE OF wfRecTyp INDEX BY BINARY_INTEGER;
   g_wf_table wfRecTabTyp;



--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_WF';
--
PROCEDURE Start_Process(
		 p_source_header_id  in number,
		 p_source_code       in varchar2,
		 p_order_number      in number,
		 p_contact_type      in varchar2,
		 p_contact_name      in varchar2,
		 p_contact_id        in number,
		 p_contact_last_name in varchar2,
		 p_shipped_lines     in varchar2,
		 p_backordered_lines in varchar2,
		 p_ship_notif_date   in date,
		 p_bo_notif_date     in date,
		 p_workflow_process  in varchar2 default null,
		 p_item_type         in varchar2 default null) is

l_workflow_process varchar2(30)  := nvl(p_workflow_process,'WSHNOTIF');
l_item_type        varchar2(30)  := nvl(p_item_type,'WSHNOTIF');
l_item_key         varchar2(150) := to_char(p_source_header_id)||'-'||p_source_code||'-'||p_contact_name ;
l_item_userkey     varchar2(30)  := to_char(p_source_header_id) ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_PROCESS';
--
begin
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER',P_ORDER_NUMBER);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_TYPE',P_CONTACT_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_NAME',P_CONTACT_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_ID',P_CONTACT_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_LAST_NAME',P_CONTACT_LAST_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIPPED_LINES',P_SHIPPED_LINES);
	    WSH_DEBUG_SV.log(l_module_name,'P_BACKORDERED_LINES',P_BACKORDERED_LINES);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_NOTIF_DATE',P_SHIP_NOTIF_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_BO_NOTIF_DATE',P_BO_NOTIF_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_PROCESS',P_WORKFLOW_PROCESS);
	    WSH_DEBUG_SV.log(l_module_name,'P_ITEM_TYPE',P_ITEM_TYPE);
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.CREATEPROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.CreateProcess(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  process   => l_workflow_process );

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrNumber(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'SOURCE_HEADER_ID',
	  avalue    => p_source_header_id );

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrText(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'SOURCE_CODE',
	  avalue    => p_source_code);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrNumber(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'ORDER_NUMBER',
	  avalue    => p_order_number );

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrText(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'CONTACT_TYPE',
	  avalue    => p_contact_type);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrText(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'CONTACT_NAME',
	  avalue    => p_contact_name);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrNumber(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'CONTACT_ID',
	  avalue    => p_contact_id);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrText(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'CONTACT_LAST_NAME',
	  avalue    => p_contact_last_name);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrDate(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'LAST_SHIP_NOTIF_DATE',
	  avalue    => p_ship_notif_date);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemAttrDate(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  aname     => 'LAST_BO_NOTIF_DATE',
	  avalue    => p_bo_notif_date);

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMUSERKEY',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.SetItemUserKey(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key,
	  UserKey   => l_item_userkey );

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.STARTPROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wf_engine.StartProcess(
	  ItemType  => l_item_type,
	  ItemKey   => l_item_key);
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
exception
	when others then
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_CORE.CONTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wf_core.context('WSHNOTIF','StartProcess',
				    to_char(p_source_header_id),
				    p_source_code,
				    to_char(p_order_number),
				    p_contact_type,
				    to_char(p_contact_id));
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
       raise;
END Start_Process;


PROCEDURE Order_Status(
		 itemtype  in varchar2,
           itemkey   in varchar2,
           actid     in number,
           funcmode  in varchar2,
           resultout in out NOCOPY  varchar2) is

CURSOR c_shipped_lines(
	   p_source_header_id in number,
	   p_source_code      in varchar2,
	   p_contact_type     in varchar2,
	   p_contact_id       in number,
	   p_last_notif_date  in date) is
SELECT
wdd.delivery_detail_id
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd,
mtl_system_items msi
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wda.delivery_id = wnd.delivery_id
AND   wnd.status_code in ('IT','CL')
AND   wnd.initial_pickup_date > p_last_notif_date
AND   nvl(wdd.shipped_quantity,0) > 0
AND   wdd.inventory_item_id = msi.inventory_item_id
AND   wdd.organization_id = msi.organization_id
AND   wdd.source_header_id = p_source_header_id
AND   wdd.source_code = p_source_code
AND   nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
AND   decode(p_contact_type,
	   'SHIP_TO',wdd.ship_to_contact_id,
	   'SOLD_TO',wdd.sold_to_contact_id,
	   wdd.customer_id) = p_contact_id;

CURSOR c_backordered_lines(
	   p_source_header_id in number,
	   p_source_code      in varchar2,
	   p_contact_type     in varchar2,
	   p_contact_id       in number,
	   p_last_notif_date  in date) is
SELECT
wdd.delivery_detail_id
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd,
mtl_system_items msi
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wdd.date_scheduled < sysdate
--AND   wdd.date_scheduled > p_last_notif_date
AND   nvl(wdd.picked_quantity, wdd.requested_quantity) > 0
AND   wdd.released_status NOT IN ('C', 'D')
AND   wda.delivery_id = wnd.delivery_id (+)
AND   nvl(wnd.status_code,'XX') not in ('IT','CL')
AND   wdd.inventory_item_id = msi.inventory_item_id
AND   wdd.organization_id = msi.organization_id
AND   wdd.source_header_id = p_source_header_id
AND   wdd.source_code = p_source_code
AND   nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
AND   decode(p_contact_type,
	   'SHIP_TO',wdd.ship_to_contact_id,
	   'SOLD_TO',wdd.sold_to_contact_id,
	   wdd.customer_id) = p_contact_id;

l_source_header_id number;
l_source_code      varchar2(30);
l_contact_type     varchar2(10);
l_contact_id       number;
l_ship_notif_date  date;
l_bo_notif_date  date;

l_delivery_detail_id number;
l_shipped BOOLEAN;
l_backordered BOOLEAN;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ORDER_STATUS';
--
begin
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'ITEMTYPE',ITEMTYPE);
	    WSH_DEBUG_SV.log(l_module_name,'ITEMKEY',ITEMKEY);
	    WSH_DEBUG_SV.log(l_module_name,'ACTID',ACTID);
	    WSH_DEBUG_SV.log(l_module_name,'FUNCMODE',FUNCMODE);
	    WSH_DEBUG_SV.log(l_module_name,'RESULTOUT',RESULTOUT);
	END IF;
	--
	if (funcmode = 'RUN') then
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_source_header_id := wf_engine.GetItemAttrNumber(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'SOURCE_HEADER_ID');

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_source_code     := wf_engine.GetItemAttrText(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'SOURCE_CODE');

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_contact_type    := wf_engine.GetItemAttrText(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'CONTACT_TYPE');

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_contact_id      := wf_engine.GetItemAttrNumber(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'CONTACT_ID');

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_bo_notif_date   := wf_engine.GetItemAttrDate(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'LAST_BO_NOTIF_DATE');

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  l_ship_notif_date := wf_engine.GetItemAttrDate(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'LAST_SHIP_NOTIF_DATE');

	l_delivery_detail_id := 0;
	open c_shipped_lines(l_source_header_id, l_source_code, l_contact_type, l_contact_id, l_ship_notif_date);
	fetch c_shipped_lines
	into  l_delivery_detail_id;
	close c_shipped_lines;

	if (l_delivery_detail_id <> 0) then
	  l_shipped := TRUE;
	else
	  l_shipped := FALSE;
	end if;

	l_delivery_detail_id := 0;
	open c_backordered_lines(l_source_header_id, l_source_code, l_contact_type, l_contact_id, l_bo_notif_date);
	fetch c_backordered_lines
	into  l_delivery_detail_id;
	close c_backordered_lines;

	if (l_delivery_detail_id <> 0) then
	  l_backordered := TRUE;
	else
	  l_backordered := FALSE;
	end if;

       if (l_shipped and l_backordered) then
         resultout := 'COMPLETE:SHIPPED_BACKORDERD';
       elsif (l_shipped) then
         resultout := 'COMPLETE:SHIPPED';
       elsif (l_backordered) then
         resultout := 'COMPLETE:BACKORDERED';
       else
         resultout := 'COMPLETE:NO_STATUS';
       end if;

     elsif (funcmode = 'CANCEL') then
	  resultout := 'COMPLETE';
     end if;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'resultout',resultout);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
END Order_Status;


PROCEDURE Order_fulfilled(
		 itemtype  in varchar2,
           itemkey   in varchar2,
           actid     in number,
           funcmode  in varchar2,
           resultout in out NOCOPY  varchar2) is

cursor c_order_fulfilled(
           p_source_header_id in number,
           p_source_code      in varchar2,
           p_contact_type     in varchar2,
           p_contact_id       in number) is
SELECT wdd.delivery_detail_id
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wda.delivery_id  = wnd.delivery_id (+)
AND   nvl(wnd.status_code,'XX') not in ('IT','CL')
AND   wdd.source_header_id = p_source_header_id
AND   wdd.source_code = p_source_code
AND   nvl(wdd.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
AND   decode(p_contact_type,
           'SHIP_TO',wdd.ship_to_contact_id,
           'SOLD_TO',wdd.sold_to_contact_id,
           wdd.customer_id) = p_contact_id;

l_source_header_id number;
l_source_code      varchar2(30);
l_contact_type varchar2(10);
l_contact_id number;
l_delivery_detail_id number := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ORDER_FULFILLED';
--
begin
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'ITEMTYPE',ITEMTYPE);
	    WSH_DEBUG_SV.log(l_module_name,'ITEMKEY',ITEMKEY);
	    WSH_DEBUG_SV.log(l_module_name,'ACTID',ACTID);
	    WSH_DEBUG_SV.log(l_module_name,'FUNCMODE',FUNCMODE);
	    WSH_DEBUG_SV.log(l_module_name,'RESULTOUT',RESULTOUT);
	END IF;
	--
	if (funcmode = 'RUN') then
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_source_header_id := wf_engine.GetItemAttrNumber(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'SOURCE_HEADER_ID');

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_source_code     := wf_engine.GetItemAttrText(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'SOURCE_CODE');

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_contact_type    := wf_engine.GetItemAttrText(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'CONTACT_TYPE');

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_contact_id      := wf_engine.GetItemAttrNumber(
                               ItemType  => itemtype,
                               ItemKey   => itemkey,
                               aname     => 'CONTACT_ID');

          open c_order_fulfilled(l_source_header_id,l_source_code,l_contact_type,l_contact_id);
		fetch c_order_fulfilled
		into  l_delivery_detail_id;
		close c_order_fulfilled;

		if (l_delivery_detail_id = 0) then
		  resultout := 'COMPLETE:YES';
          else
		  resultout := 'COMPLETE:NO';
          end if;

     elsif (funcmode = 'CANCEL') then
	  resultout := 'COMPLETE';
     end if;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'resultout',resultout);
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
END Order_Fulfilled;

PROCEDURE Shipped_Lines(
           document_id   in varchar2,
           display_type  in varchar2,
           document      in out NOCOPY  varchar2,
           document_type in out NOCOPY  varchar2) IS

CURSOR c_get_itemkey(c_document_id in varchar2) is
SELECT item_key
FROM   wf_item_activity_statuses
WHERE  notification_id = to_number(c_document_id);

l_item_type varchar2(30) := 'WSHNOTIF';
l_item_key  varchar2(150);
l_source_header_id number;
l_source_code      varchar2(30);
l_contact_type     varchar2(10);
l_contact_id       number;
l_last_notif_date  date;
l_shipped boolean := FALSE;
l_shipped_lines varchar2(32750) := '';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SHIPPED_LINES';
--
BEGIN
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_ID',DOCUMENT_ID);
	    WSH_DEBUG_SV.log(l_module_name,'DISPLAY_TYPE',DISPLAY_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT',DOCUMENT);
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_TYPE',DOCUMENT_TYPE);
	END IF;
	--
	open  c_get_itemkey(document_id);
	fetch c_get_itemkey
	into  l_item_key;
	close c_get_itemkey;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_source_header_id := wf_engine.GetItemAttrNumber(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'SOURCE_HEADER_ID');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_source_code     := wf_engine.GetItemAttrText(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'SOURCE_CODE');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_contact_type    := wf_engine.GetItemAttrText(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'CONTACT_TYPE');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_contact_id      := wf_engine.GetItemAttrNumber(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'CONTACT_ID');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_last_notif_date := wf_engine.GetItemAttrDate(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'LAST_SHIP_NOTIF_DATE');

	/* Put Customizations in WSH_CUSTOM_PUB.Shipped_Lines Procedure */
	WSH_CUSTOM_PUB.Shipped_Lines(
	  l_source_header_id,
	  l_source_code,
	  l_contact_type,
	  l_contact_id,
	  l_last_notif_date,
	  l_shipped,
	  l_shipped_lines);

        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_shipped',l_shipped);
         WSH_DEBUG_SV.log(l_module_name,'l_shipped_lines',l_shipped_lines);
        END IF;

	document_type := 'text/plain';
	document := l_shipped_lines;

	if (l_shipped = TRUE) THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wf_engine.SetItemAttrDate(
	    ItemType  => l_item_type,
	    ItemKey   => l_item_key,
	    aname     => 'LAST_SHIP_NOTIF_DATE',
	    avalue    => sysdate);
	end if;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
END Shipped_Lines;

PROCEDURE Backordered_Lines(
           document_id   in varchar2,
           display_type  in varchar2,
           document      in out NOCOPY  varchar2,
           document_type in out NOCOPY  varchar2) IS

CURSOR c_get_itemkey (c_document_id in number) is
SELECT item_key
FROM   wf_item_activity_statuses
WHERE  notification_id = to_number(c_document_id);

l_item_type varchar2(30) := 'WSHNOTIF';
l_item_key  varchar2(150);
l_source_header_id number;
l_source_code      varchar2(30);
l_contact_type     varchar2(10);
l_contact_id       number;
l_last_notif_date  date;

l_backordered boolean := FALSE;
l_backordered_lines varchar2(32750) := '';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'BACKORDERED_LINES';
--
BEGIN
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_ID',DOCUMENT_ID);
	    WSH_DEBUG_SV.log(l_module_name,'DISPLAY_TYPE',DISPLAY_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT',DOCUMENT);
	    WSH_DEBUG_SV.log(l_module_name,'DOCUMENT_TYPE',DOCUMENT_TYPE);
	END IF;
	--
	open  c_get_itemkey(document_id);
	fetch c_get_itemkey
	into  l_item_key;
	close c_get_itemkey;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_source_header_id := wf_engine.GetItemAttrNumber(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'SOURCE_HEADER_ID');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_source_code     := wf_engine.GetItemAttrText(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'SOURCE_CODE');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRTEXT',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_contact_type    := wf_engine.GetItemAttrText(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'CONTACT_TYPE');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRNUMBER',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_contact_id      := wf_engine.GetItemAttrNumber(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'CONTACT_ID');

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.GETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	l_last_notif_date := wf_engine.GetItemAttrDate(
                             ItemType  => l_item_type,
                             ItemKey   => l_item_key,
                             aname     => 'LAST_BO_NOTIF_DATE');


	/* Put Customizations in WSH_CUSTOM_PUB.Backordered_Lines Procedure */
	WSH_CUSTOM_PUB.Backordered_Lines(
	  l_source_header_id,
	  l_source_code,
	  l_contact_type,
	  l_contact_id,
	  l_last_notif_date,
	  l_backordered,
	  l_backordered_lines);

        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_backordered',l_backordered);
         WSH_DEBUG_SV.log(l_module_name,'l_backordered_lines',l_backordered_lines);
        END IF;

	document_type := 'text/plain';
	document := l_backordered_lines;

	if (l_backordered = TRUE) then
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.SETITEMATTRDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wf_engine.SetItemAttrDate(
	    ItemType  => l_item_type,
	    ItemKey   => l_item_key,
	    aname     => 'LAST_BO_NOTIF_DATE',
	    avalue    => sysdate);
	end if;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
END Backordered_Lines;

PROCEDURE Update_Workflow(
           p_delivery_id in number) is

CURSOR c_get_item_key(p_delivery_id in number) IS
SELECT
DISTINCT wdd.source_header_id,
wdd.source_code,
decode(NVL(wdd.ship_to_contact_id,-99),
		-99,decode(nvl(wdd.sold_to_contact_id,-99),
			  -99, 'CUSTOMER',
				  'SOLD_TO'),
          'SHIP_TO') contact_type,
nvl(wdd.ship_to_contact_id,nvl(wdd.sold_to_contact_id,wdd.customer_id)) contact_id
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda
WHERE wdd.delivery_detail_id = wda.delivery_detail_id
AND   wda.delivery_id = p_delivery_id
AND   wda.delivery_id IS NOT NULL
AND   wdd.source_code = 'OE';

l_wf_contact_name varchar2(100) := NULL;
l_wf_contact_last_name varchar2(240) := NULL;
l_result BOOLEAN := FALSE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_WORKFLOW';
--
BEGIN
     --
     -- Debug Statements
     --
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         --
         WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
     END IF;
     --
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'IN PROCEDURE WSH_WF.UPDATE_WORKFLOW FOR DELIVERY '||P_DELIVERY_ID  );
     END IF;
     --
	for crec in c_get_item_key(p_delivery_id)
	loop
	  begin
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,  'CALLING WORKFLOW WAIT_FOR_SHIP_CONFIRM_EVENT WITH '|| TO_CHAR ( CREC.SOURCE_HEADER_ID ) ||'-'|| CREC.SOURCE_CODE||'-'||CREC.CONTACT_TYPE||'-'||TO_CHAR ( CREC.CONTACT_ID )  );
		 END IF;
		 --

         l_wf_contact_name := NULL;
	    l_wf_contact_last_name := NULL;
         Get_Wf_User(
		 crec.contact_type,
		 crec.contact_id,
           l_wf_contact_last_name,
           l_wf_contact_name);
         IF (l_wf_contact_name is NULL) THEN
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,  'UNABLE TO FIND THE CONTACT IN WF_USERS'  );
		 END IF;
		 --
         ELSE
           -- See if the workflow instance is exisiting
		 Check_Item_Instance(
		   crec.source_header_id,
		   crec.source_code,
		   l_wf_contact_name,
		   l_result);

           IF (l_result) THEN
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW INSTANCE EXISTS'  );
		   END IF;
		   --
	        --
	        -- Debug Statements
	        --
	        IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.COMPLETEACTIVITY',WSH_DEBUG_SV.C_PROC_LEVEL);
	        END IF;
	        --
	        wf_engine.completeactivity(
		     'WSHNOTIF',
		     to_char(crec.source_header_id)||'-'|| crec.source_code||'-'||l_wf_contact_name,
		     'WAIT_FOR_SHIP_CONFIRM_EVENT',
		      null);
           END IF;

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW BLOCK REMOVED SUCCESSFULLY'  );
           END IF;
           --
         END IF;
       exception
	    when others then
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR WHILE UNBLOCKING THE WORKFLOW BLOCK WAIT_FOR_SHIP_CONFIRM_EVENT'  );
		 END IF;
		 --
       end;
	end loop;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION
   WHEN OTHERS THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR IN WSH_WF.UPDATE_WORKFLOW'  );
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END Update_Workflow;

PROCEDURE Check_Item_Instance(
		 p_source_header_id in number,
		 p_source_code      in varchar2,
		 p_contact_name     in varchar2,
		 p_result           out NOCOPY  BOOLEAN) IS
l_status varchar2(20);
l_result varchar2(20);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ITEM_INSTANCE';
--
BEGIN
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_NAME',P_CONTACT_NAME);
	END IF;
	--
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_WF.CHECK_ITEM_INSTANCE : CALLING WITH ITEM KEY '|| TO_CHAR ( P_SOURCE_HEADER_ID ) ||'-'||P_SOURCE_CODE||'-'||P_CONTACT_NAME  );
	  END IF;
	  --

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_ENGINE.ITEMSTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	Wf_Engine.ItemStatus(
	  'WSHNOTIF',
	  to_char(p_source_header_id)||'-'||p_source_code||'-'||p_contact_name,
	  l_status,
	  l_result);

	IF (l_status = 'ACTIVE') THEN
	  p_result := TRUE;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW ITEM INSTANCE IS '||L_STATUS  );
	  END IF;
	  --
     ELSE
	  p_result := FALSE;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW ITEM INSTANCE IS '||L_STATUS  );
	  END IF;
	  --
     END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION
	WHEN OTHERS THEN
	  p_result := FALSE;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW ITEM INSTANCE DOESN''T EXIST'  );
	  END IF;
	  --
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END Check_Item_Instance;

PROCEDURE Start_Workflow(
           p_source_header_id in number,
		 p_source_code      in varchar2,
		 p_order_number     in number,
		 p_contact_type     in varchar2,
		 p_contact_id       in number,
		 p_result           out NOCOPY  BOOLEAN) IS

l_result               BOOLEAN := FALSE;
l_cached_result        BOOLEAN := FALSE;
l_wf_contact_name      VARCHAR2(100) := NULL;
l_wf_contact_last_name VARCHAR2(240) := NULL;
l_count                NUMBER := 0;
l_wf_active            BOOLEAN := FALSE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'START_WORKFLOW';
--
BEGIN

	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_HEADER_ID',P_SOURCE_HEADER_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER',P_ORDER_NUMBER);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_TYPE',P_CONTACT_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_ID',P_CONTACT_ID);
	END IF;
	--
	l_result := FALSE;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CUSTOM_PUB.START_WORKFLOW',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_CUSTOM_PUB.Start_Workflow(
	  p_source_header_id,
	  p_source_code,
	  p_contact_type,
	  p_contact_id,
	  l_result);

     IF (l_result = TRUE) THEN
	  l_cached_result := FALSE;
	  FOR i in 1..g_wf_table.COUNT LOOP
	    IF ((g_wf_table(i).source_header_id = p_source_header_id) AND
		   (g_wf_table(i).source_code      = p_source_code)      AND
		   (g_wf_table(i).contact_type     = p_contact_type)     AND
		   (g_wf_table(i).contact_id       = p_contact_id)) THEN
           IF (g_wf_table(i).wf_started) THEN
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW INSTANCE ALREADY EXISTING FOR THE COMBINATION'  );
		   END IF;
		   --
           ELSE
		   --
		   -- Debug Statements
		   --
		   IF l_debug_on THEN
		       WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW INSTANCE NOT STARTED DUE TO A PREVIOUS ERROR FOR THE COMBINATION'  );
		   END IF;
		   --
           END IF;
		 l_cached_result := TRUE;
         END IF;
       END LOOP;

       IF (NOT l_cached_result) THEN
  	    --
  	    -- Debug Statements
  	    --
  	    IF l_debug_on THEN
  	        WSH_DEBUG_SV.logmsg(l_module_name,  'WORKFLOW INSTANCE NOT FOUND IN THE CACHED TABLE'  );
  	    END IF;
  	    --
         l_count := g_wf_table.COUNT + 1;

  	    g_wf_table(l_count).source_header_id := p_source_header_id;
  	    g_wf_table(l_count).source_code      := p_source_code;
  	    g_wf_table(l_count).contact_type     := p_contact_type;
  	    g_wf_table(l_count).contact_id       := p_contact_id;

         Get_Wf_User(
  	    g_wf_table(l_count).contact_type,
  	    g_wf_table(l_count).contact_id,
  	    l_wf_contact_last_name,
  	    l_wf_contact_name);
         IF (l_wf_contact_name is NULL) THEN
  	    -- Cannot Start Wf if we cannot get a valid wf_user from contact
  	    g_wf_table(l_count).wf_started := FALSE;
         ELSE
  	    -- Check if the workflow instance is already running
  	    -- This can happen if we happened to import the line in one of the previous
  	    -- Import Delivery runs.
  	    Check_Item_Instance(
  	      g_wf_table(l_count).source_header_id,
  	      g_wf_table(l_count).source_code,
  	      l_wf_contact_name,
  	      l_wf_active);

  	    IF (l_wf_active) THEN
  		 g_wf_table(l_count).wf_started := TRUE;
           ELSE
  		 -- Need to Start workflow now
             Start_Process(
               p_source_header_id  => p_source_header_id,
               p_source_code       => p_source_code,
               p_order_number      => p_order_number,
               p_contact_type      => p_contact_type,
               p_contact_name      => l_wf_contact_name,
               p_contact_id        => p_contact_id,
               p_contact_last_name => l_wf_contact_last_name,
               p_shipped_lines     => NULL,
               p_backordered_lines => NULL,
               p_ship_notif_date   => sysdate,
               p_bo_notif_date     => sysdate,
               p_workflow_process  => 'WSHNOTIF',
               p_item_type         => 'WSHNOTIF');
             --
             -- Debug Statements
             --
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,  'STARTED WORKFLOW FOR '||P_SOURCE_HEADER_ID||'-'||P_SOURCE_CODE||'-'||L_WF_CONTACT_NAME  );
             END IF;
             --
  		 g_wf_table(l_count).wf_started := TRUE;
           END IF; -- l_wf_active
         END  IF; -- l_wf_contact_name is NULL
  	    p_result := g_wf_table(l_count).wf_started;
       ELSE
	    p_result := FALSE;
       END IF; -- l_cached_result
     ELSE
	  p_result := FALSE;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_CUSTOM_PUB.START_WORKFLOW RETURNED FALSE'  );
	  END IF;
	  --
     END IF;  -- l_result = TRUE;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
	--
EXCEPTION
	WHEN OTHERS THEN
	  p_result := FALSE;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR IN WSH_WF.START_WORKFLOW'  );
	  END IF;
	  --
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END Start_Workflow;

PROCEDURE Get_Wf_User(
           p_contact_type in  varchar2,
		 p_contact_id   in  number,
		 p_wf_contact_last_name out NOCOPY  varchar2,
		 p_wf_contact_name   out NOCOPY  varchar2) IS

CURSOR get_party(c_contact_type in varchar2, c_contact_id in number) IS --TCA view Removal Starts
SELECT
party_id
FROM
hz_cust_accounts
WHERE
cust_account_id/*customer_id*/ = c_contact_id
AND    c_contact_type = 'CUSTOMER'
UNION
SELECT
rel.subject_id /*contact_party_id*/
FROM
hz_cust_account_roles Acct_role,
hz_relationships Rel,
hz_org_contacts Org_cont,
hz_cust_accounts Role_acct
WHERE
acct_role.cust_account_role_id/*contact id*/ = c_contact_id
AND acct_role.party_id = rel.party_id
AND acct_role.Role_type = 'CONTACT'
AND org_cont.party_relationship_id = rel.relationship_id
AND rel.party_id is not null
AND rel.subject_table_name = 'HZ_PARTIES'
AND rel.object_table_name = 'HZ_PARTIES'
And acct_role.cust_account_id = role_acct.cust_account_id
AND role_acct.party_id = rel.Object_id
AND c_contact_type in ('SHIP_TO','SOLD_TO'); --TCA view Removal Ends


l_party_id                NUMBER := 0;
l_wf_contact_last_name    VARCHAR2(240) := NULL;
l_email_address           VARCHAR2(2000) := NULL;
l_notification_preference VARCHAR2(4000) := NULL;
l_language                VARCHAR2(4000) := NULL;
l_territory               VARCHAR2(4000) := NULL;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_WF_USER';
--
BEGIN

     -- Get the party_id for the contact
	--
	-- Debug Statements
	--
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    --
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_TYPE',P_CONTACT_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTACT_ID',P_CONTACT_ID);
	END IF;
	--
	OPEN  get_party(p_contact_type,p_contact_id);
	FETCH get_party
	INTO  l_party_id;
	CLOSE get_party;

     IF (NVL(l_party_id,0) = 0) THEN
	  p_wf_contact_name := NULL;
     ELSE
	  -- parties will be with the following format in wf_users view
	  -- Made HZ_PARTY change as per 1391687
	  p_wf_contact_name := 'HZ_PARTY:'||to_char(l_party_id);

	  -- Check if the party is in wf_users view
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_DIRECTORY.GETROLEINFO',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  wf_directory.getroleinfo(
	    p_wf_contact_name,
	    l_wf_contact_last_name,
	    l_email_address,
	    l_notification_preference,
	    l_language,
	    l_territory);

          IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_wf_contact_last_name',l_wf_contact_last_name);
           WSH_DEBUG_SV.log(l_module_name,'l_email_address',l_email_address);
           WSH_DEBUG_SV.log(l_module_name,'l_notification_preference',l_notification_preference);
           WSH_DEBUG_SV.log(l_module_name,'l_language',l_language);
           WSH_DEBUG_SV.log(l_module_name,'l_territory',l_territory);
          END IF;

	  IF (l_wf_contact_last_name IS NULL) THEN
	    -- If party is not in wf_users views the we cannot send notification
	    -- So return null which will not trigger workflow
	    p_wf_contact_name := NULL;
	    p_wf_contact_last_name := NULL;
       ELSE
	    p_wf_contact_last_name := l_wf_contact_last_name;
       END IF;

     END IF;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
	return;
EXCEPTION
	WHEN OTHERS THEN
       p_wf_contact_name := NULL;
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR IN WSH_WF.GET_WF_USER'  );
	  END IF;
	  --
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END Get_Wf_User;

END WSH_WF;

/
