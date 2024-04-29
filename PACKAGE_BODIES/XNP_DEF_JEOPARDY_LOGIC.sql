--------------------------------------------------------
--  DDL for Package Body XNP_DEF_JEOPARDY_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_DEF_JEOPARDY_LOGIC" AS
/* $Header: XNPJTMRB.pls 120.1 2005/06/21 04:08:18 appldev ship $ */

--------------------------------------------------------------------------------
-----  API Name      : notify_fmc
-----  Type          : Private
-----  Purpose       : Starts a workflow to notify the FMC. The FMC waits for a
-----                  response from an FMC user.
-----  Parameters    : p_msg_header
--------------------------------------------------------------------------------


PROCEDURE notify_fmc (
	p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE
)
IS
l_item_type	VARCHAR2(1024);
l_item_key	VARCHAR2(1024);

l_parent_item_type	VARCHAR2(1024);
l_parent_item_key	VARCHAR2(1024);

CURSOR parent_process_rec(p_order_id IN NUMBER) IS
	SELECT	WF_ITEM_TYPE, WF_ITEM_KEY
	FROM	xdp_order_headers
	WHERE	order_id = p_order_id;

BEGIN

	l_item_type := 'XDPWFSTD';

	l_item_key := 'XDP_ORDER_' || TO_CHAR(p_msg_header.order_id);

	wf_core.context('XDP_WF_STANDARD',
			'ORDER_JEOPARDY_NOTIFICATION',
			l_item_type,
			l_item_key);

	wf_engine.createprocess(l_item_type,
				l_item_key,
				'ORDER_JEOPARDY_NOTIFICATION');

	-- BUG 1621513
	-- get the parent workflow  process keys
	-- and link the new workflow process to the parent
	-- BUG 2009983
	-- This may hinder the logic behind  "Notification" button on the FMC

--	FOR rec IN parent_process_rec(p_msg_header.order_id)
--	LOOP
--		l_parent_item_type := rec.WF_ITEM_TYPE;
--		l_parent_item_key := rec.WF_ITEM_KEY;
--		exit;
--	END LOOP;

--	wf_engine.SetItemParent(
--		itemType => l_item_type,
--		itemKey	 => l_item_key,
--		parent_itemType => l_parent_item_type,
--		parent_itemKey	 => l_parent_item_key,
--		parent_context	 => NULL);

	wf_engine.SetItemAttrNumber(
		itemType => l_item_type,
		itemKey	 => l_item_key,
		aname => 'ORDER_ID',
		avalue => p_msg_header.order_id);

	wf_engine.startprocess(l_item_type,
		l_item_key);

END notify_fmc;

END XNP_DEF_JEOPARDY_LOGIC;

/
