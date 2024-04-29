--------------------------------------------------------
--  DDL for Package Body WMS_TXNREASONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TXNREASONS_PUB" as
/* $Header: WMSTXR3B.pls 120.1 2005/06/10 10:18:39 appldev  $ */
g_pkg_name CONSTANT VARCHAR(30) := 'wms_txnreasons_pub';

-- to turn off debugger, comment out the line 'dbms_output.put_line(msg);'
PROCEDURE mdebug(msg in varchar2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--dbms_output.put_line(msg);
   null;
END;

Procedure Start_Workflow(
P_REASON_ID				IN	NUMBER,
P_REASON_NAME				IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_ORGANIZATION_ID		IN	NUMBER DEFAULT NULL,
P_DESTINATION_ORGANIZATION_ID		IN	NUMBER DEFAULT NULL,
P_LPN_ID				IN	NUMBER DEFAULT NULL,
P_INVENTORY_ITEM_ID			IN	NUMBER DEFAULT NULL,
P_REVISION				IN	VARCHAR2 DEFAULT NULL,
p_update_status_method                  IN 	VARCHAR2 DEFAULT NULL,
P_LOT_NUMBER				IN	VARCHAR2 DEFAULT NULL,
p_to_lot_number                         IN      VARCHAR2 DEFAULT NULL,
P_LOT_STATUS				IN	VARCHAR2 DEFAULT NULL,
P_SUBLOT_NUMBER				IN	VARCHAR2 DEFAULT NULL,
P_SUBLOT_STATUS				IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_SUBINVENTORY			IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_SUBINVENTORY_STATUS		IN	VARCHAR2 DEFAULT NULL,
P_DESTINATION_SUBINVENTORY		IN	VARCHAR2 DEFAULT NULL,
P_DESTINATION_SUBINVENTORY_ST           IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_LOCATOR			IN	NUMBER DEFAULT NULL,
P_SOURCE_LOCATOR_STATUS			IN	VARCHAR2 DEFAULT NULL,
P_DESTINATION_LOCATOR			IN	NUMBER DEFAULT NULL,
P_DESTINATION_LOCATOR_STATUS		IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_IMMEDIATE_LPN_ID		IN	NUMBER DEFAULT NULL,
P_SOURCE_IMMEDIATE_LPN_STATUS		IN	VARCHAR2 DEFAULT NULL,
P_SOURCE_TOPLEVEL_LPN_ID		IN	NUMBER DEFAULT NULL,
P_SOURCE_TOPLEVEL_LPN_STATUS		IN	VARCHAR2 DEFAULT NULL,
P_DEST_IMMEDIATE_LPN_ID 		IN	NUMBER DEFAULT NULL,
P_DEST_IMMEDIATE_LPN_STATUS     	IN	VARCHAR2 DEFAULT NULL,
P_DEST_TOPLEVEL_LPN_ID  		IN	NUMBER DEFAULT NULL,
P_DEST_TOPLEVEL_LPN_STATUS      	IN	VARCHAR2 DEFAULT NULL,
P_SERIAL_NUMBER				IN	VARCHAR2 DEFAULT NULL,
p_to_serial_number                      IN      VARCHAR2 DEFAULT NULL,
P_SERIAL_NUMBER_STATUS			IN	VARCHAR2 DEFAULT NULL,
P_PRIMARY_UOM				IN	VARCHAR2 DEFAULT NULL,
P_TRANSACTION_UOM			IN	VARCHAR2 DEFAULT NULL,
P_PRIMARY_QUANTITY			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_QUANTITY			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_ACTION_ID			IN	NUMBER DEFAULT NULL,
P_TRANSACTION_SOURCE_TYPE_ID		IN	NUMBER DEFAULT NULL,
P_TRANSACTION_SOURCE			IN	VARCHAR2 DEFAULT NULL,
P_PARENT_TRANSACTION_SOURCE		IN	VARCHAR2 DEFAULT NULL,
P_PARENT_TRANS_ACTION_ID		IN	NUMBER DEFAULT NULL,
P_PARENT_TRANS_SOURCE_TYPE_ID   	IN	NUMBER DEFAULT NULL,
P_RESERVATION_ID			IN	NUMBER DEFAULT NULL,
P_EQUIPMENT_ID				IN	NUMBER DEFAULT NULL,
P_ROLE_ID				IN	NUMBER DEFAULT NULL,
P_EMPLOYEE_ID				IN	NUMBER DEFAULT NULL,
P_TASK_TYPE_ID				IN	NUMBER DEFAULT NULL,
P_TASK_ID				IN	NUMBER DEFAULT NULL,
P_CALLING_PROGRAM_NAME			IN	VARCHAR2 DEFAULT NULL,
P_EMAIL_ID				IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_NAME				IN	VARCHAR2 DEFAULT NULL,
P_RUN_MODE				IN	VARCHAR2 DEFAULT NULL,
P_INIT_MSG_LST   			IN  	VARCHAR2 DEFAULT fnd_api.g_false,
P_PROGRAM_CONTROL_ARG1			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG2			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG3			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG4			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG5			IN	VARCHAR2 DEFAULT NULL,
P_PROGRAM_CONTROL_ARG6 			IN	VARCHAR2 DEFAULT NULL,
X_RETURN_STATUS				OUT NOCOPY	VARCHAR2,
X_MSG_DATA				OUT NOCOPY	VARCHAR2,
X_MSG_COUNT				OUT NOCOPY	NUMBER,
X_REVISION				OUT NOCOPY	VARCHAR2,
X_LOT_NUMBER				OUT NOCOPY	VARCHAR2,
X_LOT_STATUS				OUT NOCOPY	VARCHAR2,
X_SUBLOT_NUMBER				OUT NOCOPY	VARCHAR2,
X_SUBLOT_STATUS				OUT NOCOPY	VARCHAR2,
X_LPN_ID				OUT NOCOPY	NUMBER,
X_LPN_STATUS				OUT NOCOPY	VARCHAR2,
X_UOM_CODE				OUT NOCOPY	VARCHAR2,
X_QUANTITY				OUT NOCOPY	NUMBER,
X_INVENTORY_ITEM_ID			OUT NOCOPY	NUMBER,
X_ORGANIZATION_ID			OUT NOCOPY	NUMBER,
X_SUBINVENTORY				OUT NOCOPY	VARCHAR2,
X_SUBINVENTORY_STATUS			OUT NOCOPY	VARCHAR2,
X_LOCATOR				OUT NOCOPY	NUMBER,
X_LOCATOR_STATUS			OUT NOCOPY	VARCHAR2,
X_PRIMARY_QUANTITY			OUT NOCOPY	NUMBER,
X_TRANSACTION_QUANTITY 			OUT NOCOPY	NUMBER,
X_NEXT_FORM				OUT NOCOPY	VARCHAR2,
X_NEXT_MOBILE_FORM			OUT NOCOPY	VARCHAR2,
X_NEXT_PLSQL_PROGRAM			OUT NOCOPY	VARCHAR2,
X_RESERVATION_ID			OUT NOCOPY	NUMBER,
X_IS_RESERVATION_SUCCESSFUL		OUT NOCOPY	VARCHAR2,
X_IS_CYCLE_COUNT_SUCCESSFUL 		OUT  NOCOPY	VARCHAR2
) IS

l_reason_name		varchar2(250);
l_workflow_name		varchar2(250);
l_workflow_process	varchar2(250);
l_sequence_number	number ;
l_item_key 		varchar2(500);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF (l_debug = 1) THEN
     mdebug('In Start_Workflow');
  END IF;
  -- make sure that reason name is not null
  if (p_reason_id is null ) then
       fnd_message.set_name('INV','INV_FIELD_INVALID');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  end if;

  IF (l_debug = 1) THEN
     mdebug('Before Select WORKFLOW_NAME, WORKFLOW_PROCESS ');
  END IF;
  -- get workflow_name and workflow_process from mtl_transaction_reasons.
  -- This is needed to create the workflow process
  SELECT WORKFLOW_NAME, WORKFLOW_PROCESS
  INTO  l_workflow_name, l_workflow_process
  FROM MTL_TRANSACTION_REASONS
  WHERE P_REASON_ID  = REASON_ID ;

  IF (l_debug = 1) THEN
     mdebug('Workflow name is: '|| l_workflow_name);
     mdebug('Workflow process: '|| l_workflow_process);
  END IF;

  -- generate item key using sequence number and concat with txnworkflow 'twflow'.
  -- This is needed to create the workflow process
  SELECT WMS_DISPATCHED_TASKS_S.nextval
  INTO l_sequence_number
  FROM DUAL ;
  l_item_key := 'twflow' || l_sequence_number ;

  IF (l_debug = 1) THEN
     mdebug('Item key is: '|| l_item_key);
  END IF;

   -- initialize workflow
	wf_engine.CreateProcess(itemtype	=>	l_workflow_name,
				itemkey		=>	l_item_key,
				process		=>	l_workflow_process);

  -- set the attribute values of workflow with the given input parameters
	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_REASON_ID',
				  avalue	=>	P_REASON_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_REASON_NAME',
				  avalue	=>	P_REASON_NAME);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_SOURCE_ORGANIZATION_ID',
				    avalue	=>	P_SOURCE_ORGANIZATION_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_DESTINATION_ORGANIZATION_ID',
				    avalue	=>	P_DESTINATION_ORGANIZATION_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_LPN_ID',
				    avalue	=>	P_LPN_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_INVENTORY_ITEM_ID',
				    avalue	=>	P_INVENTORY_ITEM_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_REVISION',
				  avalue	=>	P_REVISION);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_UPDATE_STATUS_METHOD',
				  avalue	=>	P_UPDATE_STATUS_METHOD);


	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_LOT_NUMBER',
				  avalue	=>	P_LOT_NUMBER);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_TO_LOT_NUMBER',
				  avalue	=>	P_TO_LOT_NUMBER);


	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_LOT_STATUS',
				  avalue	=>	P_LOT_STATUS);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SUBLOT_NUMBER',
				  avalue	=>	P_SUBLOT_NUMBER);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SUBLOT_STATUS',
				  avalue	=>	P_SUBLOT_STATUS);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SOURCE_SUBINVENTORY',
				  avalue	=>	P_SOURCE_SUBINVENTORY);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SOURCE_SUBINVENTORY_STATUS',
				  avalue	=>	P_SOURCE_SUBINVENTORY_STATUS);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_DESTINATION_SUBINVENTORY',
				  avalue	=>	P_DESTINATION_SUBINVENTORY);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_DESTINATION_SUBINVENTORY_ST',
				  avalue	=>	P_DESTINATION_SUBINVENTORY_ST);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_SOURCE_LOCATOR',
				    avalue	=>	P_SOURCE_LOCATOR);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SOURCE_LOCATOR_STATUS',
				  avalue	=>	P_SOURCE_LOCATOR);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_DESTINATION_LOCATOR',
				    avalue	=>	P_DESTINATION_LOCATOR);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_DESTINATION_LOCATOR_STATUS',
				  avalue	=>	P_DESTINATION_LOCATOR_STATUS);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_SOURCE_IMMEDIATE_LPN_ID',
				    avalue	=>	P_SOURCE_IMMEDIATE_LPN_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SOURCE_IMMEDIATE_LPN_STATUS',
				  avalue	=>	P_SOURCE_IMMEDIATE_LPN_STATUS);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_SOURCE_TOPLEVEL_LPN_ID',
				    avalue	=>	P_SOURCE_TOPLEVEL_LPN_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SOURCE_TOPLEVEL_LPN_STATUS',
				  avalue	=>	P_SOURCE_TOPLEVEL_LPN_STATUS);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_DEST_IMMEDIATE_LPN_ID',
				    avalue	=>	P_DEST_IMMEDIATE_LPN_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_DEST_IMMEDIATE_LPN_STATUS',
				  avalue	=>	P_DEST_IMMEDIATE_LPN_STATUS);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_DEST_TOPLEVEL_LPN_ID',
				    avalue	=>	P_DEST_TOPLEVEL_LPN_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_DEST_TOPLEVEL_LPN_STATUS',
				  avalue	=>	P_DEST_TOPLEVEL_LPN_STATUS);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SERIAL_NUMBER',
				  avalue	=>	P_SERIAL_NUMBER);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_TO_SERIAL_NUMBER',
				  avalue	=>	P_TO_SERIAL_NUMBER);


	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_SERIAL_NUMBER_STATUS',
				  avalue	=>	P_SERIAL_NUMBER_STATUS);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PRIMARY_UOM',
				  avalue	=>	P_PRIMARY_UOM);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_TRANSACTION_UOM',
				  avalue	=>	P_TRANSACTION_UOM);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_PRIMARY_QUANTITY',
				    avalue	=>	P_PRIMARY_QUANTITY);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_TRANSACTION_QUANTITY',
				    avalue	=>	P_TRANSACTION_QUANTITY);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_TRANSACTION_ACTION_ID',
				    avalue	=>	P_TRANSACTION_ACTION_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_TRANSACTION_SOURCE_TYPE_ID',
				    avalue	=>	P_TRANSACTION_SOURCE_TYPE_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_TRANSACTION_SOURCE',
				  avalue	=>	P_TRANSACTION_SOURCE);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PARENT_TRANSACTION_SOURCE',
				  avalue	=>	P_PARENT_TRANSACTION_SOURCE);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_PARENT_TRANS_ACTION_ID',
				    avalue	=>	P_PARENT_TRANS_ACTION_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_PARENT_TRANS_SOURCE_TYPE_ID',
				    avalue	=>	P_PARENT_TRANS_SOURCE_TYPE_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_RESERVATION_ID',
				    avalue	=>	P_RESERVATION_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_EQUIPMENT_ID',
				    avalue	=>	P_EQUIPMENT_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_ROLE_ID',
				    avalue	=>	P_ROLE_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_EMPLOYEE_ID',
				    avalue	=>	P_EMPLOYEE_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_TASK_TYPE_ID',
				    avalue	=>	P_TASK_TYPE_ID);

	wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
				    itemkey	=>	l_item_key,
				    aname	=>	'PW_TASK_ID',
				    avalue	=>	P_TASK_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_CALLING_PROGRAM_NAME',
				  avalue	=>	P_CALLING_PROGRAM_NAME);


	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_EMAIL_ID',
				  avalue	=>	P_EMAIL_ID);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_NAME',
			          avalue	=>	P_PROGRAM_NAME);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_RUN_MODE',
			          avalue	=>	P_RUN_MODE);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_INIT_MSG_LST',
			          avalue	=>	P_INIT_MSG_LST);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG1',
				  avalue	=>	P_PROGRAM_CONTROL_ARG1);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG2',
				  avalue	=>	P_PROGRAM_CONTROL_ARG2);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG3',
			          avalue	=>	P_PROGRAM_CONTROL_ARG3);

	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG4',
			          avalue	=>	P_PROGRAM_CONTROL_ARG4);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG5',
				  avalue	=>	P_PROGRAM_CONTROL_ARG5);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'PW_PROGRAM_CONTROL_ARG6',
				  avalue	=>	P_PROGRAM_CONTROL_ARG6);


 -- start workflow
        IF (l_debug = 1) THEN
           mdebug('Before Start Process of: ' || l_workflow_name);
        END IF;
	wf_engine.StartProcess (itemtype	=>	l_workflow_name,
				itemkey		=>	l_item_key);

-- on completion of the workflow, the output parameters are populated with the
-- workflow attribute values
X_RETURN_STATUS	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				 	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_RETURN_STATUS');

X_MSG_DATA	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_MSG_DATA');

X_MSG_COUNT	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_MSG_COUNT');

X_REVISION	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_REVISION');

X_LOT_NUMBER	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LOT_NUMBER');

X_LOT_STATUS	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LOT_STATUS');

X_SUBLOT_NUMBER	:=  wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	      itemkey	=>	l_item_key,
				  	      aname	=>	'XW_SUBLOT_NUMBER');

X_SUBLOT_STATUS	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_SUBLOT_STATUS');

X_LPN_ID 	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_LPN_ID');

X_LPN_STATUS	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LPN_STATUS');

X_UOM_CODE	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_UOM_CODE');

X_QUANTITY	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_QUANTITY');

X_INVENTORY_ITEM_ID:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		 itemkey =>	l_item_key,
				    		 aname	 =>	'XW_INVENTORY_ITEM_ID');

X_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		itemkey	=>	l_item_key,
				    		aname	=>	'XW_ORGANIZATION_ID');

X_SUBINVENTORY	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_SUBINVENTORY');

X_SUBINVENTORY_STATUS:=wf_engine.GetItemAttrText(itemtype=>	l_workflow_name,
				  		 itemkey =>	l_item_key,
				  		 aname	 =>	'XW_SUBINVENTORY_STATUS');

X_LOCATOR	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_LOCATOR');

X_LOCATOR_STATUS:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LOCATOR_STATUS');

X_PRIMARY_QUANTITY:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    	        itemkey	=>	l_item_key,
				    	        aname	=>	'XW_PRIMARY_QUANTITY');

X_TRANSACTION_QUANTITY:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		    itemkey =>	l_item_key,
				    		    aname   =>	'XW_TRANSACTION_QUANTITY');

X_NEXT_FORM	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_NEXT_FORM');

X_NEXT_MOBILE_FORM := wf_engine.GetItemAttrText(itemtype=>	l_workflow_name,
				  		itemkey	=>	l_item_key,
				  		aname	=>	'XW_NEXT_MOBILE_FORM');

X_NEXT_PLSQL_PROGRAM := wf_engine.GetItemAttrText(itemtype =>	l_workflow_name,
				  		  itemkey  =>	l_item_key,
				  		  aname	   =>	'XW_NEXT_PLSQL_PROGRAM');

X_RESERVATION_ID   := wf_engine.GetItemAttrText(itemtype=>	l_workflow_name,
				  		itemkey	=>	l_item_key,
				  		aname	=>	'XW_RESERVATION_ID');

X_IS_RESERVATION_SUCCESSFUL:= wf_engine.GetItemAttrText(itemtype=>l_workflow_name,
				  		itemkey	=>l_item_key,
				  		aname	=>'XW_IS_RESERVATION_SUCCESSFUL');

X_IS_CYCLE_COUNT_SUCCESSFUL:= wf_engine.GetItemAttrText(itemtype=>l_workflow_name,
				  		itemkey	=>l_item_key,
				  		aname	=>'XW_IS_CYCLE_COUNT_SUCCESSFUL');

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

   WHEN NO_DATA_FOUND THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_message.set_name('INV','INV_INT_REACODE');
     fnd_msg_pub.ADD;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Start_Workflow'
              );
        END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END Start_workflow ;

END wms_txnreasons_pub ;

/
