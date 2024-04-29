--------------------------------------------------------
--  DDL for Package Body GMI_APIXML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_APIXML_PKG" AS
/* $Header: GMIXAPIB.pls 115.13 2002/12/06 15:26:16 jdiiorio noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMI_APIXML_PKG';

PROCEDURE log_message(	p_proc_name IN VARCHAR2,
			p_if_id IN NUMBER,
			p_msg IN VARCHAR2);

PROCEDURE update_status(p_proc_name	IN VARCHAR2,
			p_if_id IN NUMBER,
			p_err_msg IN VARCHAR2);

PROCEDURE send_outbound_document(	p_confirm_statuslvl IN VARCHAR2,
					p_confirm_descrtn IN VARCHAR2,
					p_confirm_det_descriptn IN VARCHAR2,
					p_confirm_det_reasoncode IN VARCHAR2,
					p_icn	IN NUMBER,
					p_event_key IN VARCHAR2);

PROCEDURE api_selector ( item_type	IN	 VARCHAR2,
			 item_key	IN	 VARCHAR2,
			 actid	 	IN	 NUMBER,
			 command	IN	 VARCHAR2,
			 resultout	IN OUT NOCOPY VARCHAR2 ) IS

l_item_int_id   VARCHAR2(240);
l_lot_int_id	VARCHAR2(240);
l_conv_int_id	VARCHAR2(240);

l_txn_type	VARCHAR2(240);
l_param1	VARCHAR2(4000);
l_param2	VARCHAR2(4000);
l_param3	VARCHAR2(4000);
l_param4	VARCHAR2(4000);
l_param5	VARCHAR2(4000);

-- local variables for setting the wf context
l_user_id		NUMBER;
l_user_name		fnd_user.user_name%TYPE;
l_resp_appl_id		NUMBER;
l_resp_id		NUMBER;
l_org_id		NUMBER;
l_language 		VARCHAR2(240);
l_nls_lang_find		NUMBER;
l_nls_lang 		VARCHAR2(255);
l_user_key		VARCHAR2(255);
l_role_name		VARCHAR2(255);
l_role_display_name	VARCHAR2(255);

l_item_number		VARCHAR2(32);
l_lot_number                GMI_LOTS_XML_INTERFACE.LOT_NUMBER%TYPE;
l_ext_lot_id            GMI_LOTS_XML_INTERFACE.EXT_LOT_ID%TYPE;
l_ext_conv_id		GMI_LOTS_CONV_XML_INTERFACE.EXT_CONV_ID%TYPE;

--Cursors to fetch the user name from the interface record.
CURSOR c_qty_user_name(p_qty_if_id VARCHAR2) IS
SELECT 	user_name, item_number
FROM	gmi_quantity_xml_interface
WHERE	quantity_interface_id = TO_NUMBER(p_qty_if_id);

CURSOR c_item_user_name(p_item_if_id VARCHAR2) IS
SELECT 	user_name, item_number
FROM	gmi_items_xml_interface
WHERE	item_interface_id = TO_NUMBER(p_item_if_id);

CURSOR c_lot_user_name(p_lot_if_id VARCHAR2) IS
SELECT 	user_name, item_number, lot_number, ext_lot_id
FROM	gmi_lots_xml_interface
WHERE	lot_interface_id = TO_NUMBER(p_lot_if_id);

CURSOR c_conv_user_name(p_conv_if_id VARCHAR2) IS
SELECT 	user_name, item_number, lot_number, ext_conv_id
FROM	gmi_lots_conv_xml_interface
WHERE	conv_interface_id = TO_NUMBER(p_conv_if_id);

BEGIN

	IF( command = 'RUN' )
	THEN
		-- Retrieve the attributes
		l_param1 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER1');


		l_param2 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER2');

        	IF l_param1 = 'GMI' AND l_param2 = 'QTY' THEN --ITEM_TYPE = 'GMIQTAPI' THEN

	        	resultout := 'CREATE_TRANSACTION';

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITEM' THEN --ITEM_TYPE = 'GMIICAPI' THEN

	        	resultout := 'CREATE_ITEM';

		ELSIF l_param1 = 'GMI' AND l_param2 = 'LOT' THEN --ITEM_TYPE = 'GMILTAPI' THEN

	        	resultout := 'CREATE_LOT';   --  process name

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITMCV' THEN --ITEM_TYPE = 'GMILCAPI' THEN

	        	resultout := 'CREATE_LTCONV';   --  process name
		END IF;

	ELSIF( command = 'SET_CTX' )
	THEN
		-- Retrieve the attributes
		l_param1 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER1');

		l_param2 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER2');

		l_param3 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER3');

		l_param4 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER4');

		l_param5 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER5');

		/**
		* Get the User Id and Item Number
		* We cannot use FND_GLOBAL.USER_ID since we do not
		* set the apps context
		*/
		l_user_name 	:= NULL;
		l_item_number 	:= NULL;
		l_lot_number 	:= NULL;
		l_ext_lot_id 	:= NULL;
		l_ext_conv_id	:= NULL;


		IF l_param1 = 'GMI' AND l_param2 = 'QTY' THEN --ITEM_TYPE = 'GMIQTAPI' THEN

			-- Set the appropriate attributes
			wf_engine.setItemAttrnumber(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'EXT_TRANSACTION_ID',
				avalue   => l_param3);

			wf_engine.setItemAttrnumber(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_QUANTITY_INTERFACE_ID',
				avalue   => l_param4);

			wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_TRANSACTION_TYPE',
				avalue   => l_param5);


			OPEN c_qty_user_name(l_param4);
			FETCH c_qty_user_name INTO l_user_name, l_item_number;
			CLOSE c_qty_user_name;

			GMA_GLOBAL_GRP.Get_who(
				p_user_name  => l_user_name,
				x_user_id    => l_user_id);

			-- User Key = Transaction_type.Item_number.Ext_transaction_id
			l_user_key := l_param5 || '.' || l_item_number || '.' || l_param3 ;

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITEM' THEN --ITEM_TYPE = 'GMIICAPI' THEN

			-- Set the appropriate attributes
			wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'EXT_ITEM_ID',
				avalue   => l_param3);

			wf_engine.setItemAttrnumber(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_INTERFACE_ID',
				avalue   => l_param4);

			OPEN c_item_user_name(l_param4);
			FETCH c_item_user_name INTO 	l_user_name, l_item_number;
			CLOSE c_item_user_name;

			GMA_GLOBAL_GRP.Get_who(
				p_user_name  => l_user_name,
				x_user_id    => l_user_id);

			-- User Key = Item_number.Ext_item_id
			l_user_key := l_item_number || '.' || l_param3 ;


		ELSIF l_param1 = 'GMI' AND l_param2 = 'LOT' THEN --ITEM_TYPE = 'GMILTAPI' THEN

			-- Set the appropriate attributes
			wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'EXT_LOT_ID',
				avalue   => l_param3);

			wf_engine.setItemAttrnumber(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_LOT_INTERFACE_ID',
				avalue   => l_param4);

			OPEN c_lot_user_name(l_param4);
			FETCH c_lot_user_name INTO 	l_user_name, l_item_number,
	                                		l_lot_number, l_ext_lot_id;
			CLOSE c_lot_user_name;

			GMA_GLOBAL_GRP.Get_who(
				p_user_name  => l_user_name,
				x_user_id    => l_user_id);

			-- User Key = Lot_no,item_no,Ext_trans_id
			l_user_key := l_lot_number || '.' || l_item_number || '.' || l_ext_lot_id;

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITMCV' THEN --ITEM_TYPE = 'GMILCAPI' THEN

			-- Set the appropriate attributes
			wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'EXT_CONV_ID',
				avalue   => l_param3);

			wf_engine.setItemAttrnumber(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'CONV_INTERFACE_ID',
				avalue   => l_param4);

			OPEN c_conv_user_name(l_param4);
			FETCH c_conv_user_name INTO l_user_name, l_item_number, l_lot_number, l_ext_conv_id;
			CLOSE c_conv_user_name;

			GMA_GLOBAL_GRP.Get_who(
				p_user_name  => l_user_name,
				x_user_id    => l_user_id);

			-- User Key = Lot_no,item_no,Ext_conv_id
			l_user_key := l_lot_number || '.' || l_item_number || '.' || l_ext_conv_id;

		END IF;

		-- Set the user key
		Wf_engine.setItemUserkey(itemtype => item_type,
					 itemkey  => item_key,
					 userkey  => l_user_key);

		-- Set the other context variables
		-- Default language context is already set by apps login

		Wf_engine.SetItemAttrText(itemtype => item_type,
					  itemkey  => item_key,
					  aname    => 'NOTIFICATION_MESSAGE',
					  avalue   => '');

		Wf_directory.getRoleName(p_orig_system    => 'FND_USR',
					 p_orig_system_id => l_user_id,
					 p_name           => l_role_name,
					 p_display_name   => l_role_display_name);

		Wf_engine.setItemOwner(itemtype => item_type,
				       itemkey  => item_key,
				       owner    => l_role_name);

		Wf_engine.setItemAttrText(itemtype => item_type,
					  itemkey  => item_key,
					  aname    => 'WF_ADMINISTRATOR',
					  avalue   => l_role_name);



		Wf_directory.getRoleName(p_orig_system    => 'ECX_SA_ROLE',
					 p_orig_system_id => 0,
					 p_name           => l_role_name,
					 p_display_name   => l_role_display_name);

		Wf_engine.setItemAttrText(itemtype => item_type,
					  itemkey  => item_key,
					  aname    => 'ECX_ADMINISTRATOR',
					  avalue   => l_role_name);

	ELSIF( command = 'TEST_CTX' )
	THEN

		-- Retrieve the attributes
		l_param1 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER1');


		l_param2 := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'PARAMETER2');


        	IF l_param1 = 'GMI' AND l_param2 = 'QTY' THEN --ITEM_TYPE = 'GMIQTAPI' THEN

			l_txn_type := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_TRANSACTION_TYPE');

			IF( l_txn_type IS NULL )
			THEN
				resultout := 'FALSE';
			ELSE
				resultout := 'TRUE';
			END IF;

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITEM' THEN --ITEM_TYPE = 'GMIICAPI' THEN

			l_item_int_id := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_INTERFACE_ID');

			IF( l_item_int_id IS NULL )
			THEN
				resultout := 'FALSE';
			ELSE
				resultout := 'TRUE';
			END IF;

		ELSIF l_param1 = 'GMI' AND l_param2 = 'LOT' THEN --ITEM_TYPE = 'GMILTAPI' THEN

			l_lot_int_id := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'EXT_LOT_ID');

			IF( l_lot_int_id IS NULL )
			THEN
				resultout := 'FALSE';
			ELSE
				resultout := 'TRUE';
			END IF;

		ELSIF l_param1 = 'GMI' AND l_param2 = 'ITMCV' THEN --ITEM_TYPE = 'GMILCAPI' THEN

			l_conv_int_id := wf_engine.GetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'CONV_INTERFACE_ID');

			IF( l_conv_int_id IS NULL )
			THEN
				resultout := 'FALSE';
			ELSE
				resultout := 'TRUE';
			END IF;

		END IF;

	END IF;

END api_selector;

PROCEDURE process_transaction (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 )
IS

l_interface_rec		gmi_quantity_xml_interface%ROWTYPE;
l_trans_rec		Gmigapi.qty_rec_typ;

l_ic_jrnl_mst_row	ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1	ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2	ic_adjs_jnl%ROWTYPE;

l_status	VARCHAR2(1);
l_return_status	VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count		NUMBER;
l_count_msg	NUMBER;
l_data		VARCHAR2(2000);
l_dummy_cnt	NUMBER  :=0;
l_record_count	NUMBER  :=0;

CURSOR c_if_rec(p_interface_id NUMBER, p_ext_txn_id NUMBER) IS
SELECT 	*
FROM	gmi_quantity_xml_interface
WHERE	quantity_interface_id 	= p_interface_id
AND	ext_transaction_id 	= p_ext_txn_id;

l_qty_iface_id	NUMBER(15);
l_ext_txn_id	NUMBER(15);

e_txn_not_found	EXCEPTION;
e_txn_failed	EXCEPTION;

l_event_name		VARCHAR2(100);
l_event_key		VARCHAR2(100);
l_icn			NUMBER;

l_confirm_statuslvl	VARCHAR2(500);
l_confirm_descrtn	VARCHAR2(500);

BEGIN
	IF( funcmode = 'RUN' )
	THEN
		resultout := 'COMPLETE:Y';

		-- Get the variables and call the api procedure
		l_qty_iface_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'GMI_QUANTITY_INTERFACE_ID');

		l_ext_txn_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'EXT_TRANSACTION_ID');

		OPEN c_if_rec(l_qty_iface_id, l_ext_txn_id);
		FETCH c_if_rec INTO l_interface_rec;
		IF( c_if_rec%NOTFOUND )
		THEN
			CLOSE c_if_rec;
			RAISE e_txn_not_found;
		END IF;
		CLOSE c_if_rec;

		Wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_NUMBER',
				avalue   => l_interface_rec.item_number);

		SELECT 	DECODE(l_interface_rec.transaction_type,
					'CREI', 1,
					'ADJI', 2,
					'TRNI', 3,
					'STSI', 4,
					'GRDI', 5,
					'CRER', 6,
					'ADJR', 7,
					'TRNR', 8,
					'STSR', 9,
					'GRDR', 10,-1)
		INTO 	l_trans_rec.trans_type
		FROM 	dual;

  		l_trans_rec.item_no		:= l_interface_rec.item_number;
		l_trans_rec.journal_no		:= l_interface_rec.journal_number;
		l_trans_rec.from_whse_code	:= l_interface_rec.from_warehouse;
		l_trans_rec.to_whse_code	:= l_interface_rec.to_warehouse;
		l_trans_rec.item_um		:= l_interface_rec.primary_uom;
		l_trans_rec.item_um2		:= l_interface_rec.secondary_uom;
		l_trans_rec.lot_no		:= l_interface_rec.lot_number;
		l_trans_rec.sublot_no		:= l_interface_rec.sublot_number;
		l_trans_rec.from_location	:= l_interface_rec.from_location;
		l_trans_rec.to_location		:= l_interface_rec.to_location;
		l_trans_rec.trans_qty		:= l_interface_rec.primary_trans_qty;
		l_trans_rec.trans_qty2		:= l_interface_rec.secondary_trans_qty;
		l_trans_rec.qc_grade		:= l_interface_rec.qc_grade;
		l_trans_rec.lot_status		:= l_interface_rec.lot_status;
		l_trans_rec.co_code		:= l_interface_rec.co_code;
		l_trans_rec.orgn_code		:= l_interface_rec.orgn_code;

		l_trans_rec.attribute1          := l_interface_rec.ATTRIBUTE1;
		l_trans_rec.attribute2          := l_interface_rec.ATTRIBUTE2;
		l_trans_rec.attribute3          := l_interface_rec.ATTRIBUTE3;
		l_trans_rec.attribute4          := l_interface_rec.ATTRIBUTE4;
		l_trans_rec.attribute5          := l_interface_rec.ATTRIBUTE5;
		l_trans_rec.attribute6          := l_interface_rec.ATTRIBUTE6;
		l_trans_rec.attribute7          := l_interface_rec.ATTRIBUTE7;
		l_trans_rec.attribute8          := l_interface_rec.ATTRIBUTE8;
		l_trans_rec.attribute9          := l_interface_rec.ATTRIBUTE9;
		l_trans_rec.attribute10         := l_interface_rec.ATTRIBUTE10;
		l_trans_rec.attribute11         := l_interface_rec.ATTRIBUTE11;
		l_trans_rec.attribute12         := l_interface_rec.ATTRIBUTE12;
		l_trans_rec.attribute13         := l_interface_rec.ATTRIBUTE13;
		l_trans_rec.attribute14         := l_interface_rec.ATTRIBUTE14;
		l_trans_rec.attribute15         := l_interface_rec.ATTRIBUTE15;
		l_trans_rec.attribute16         := l_interface_rec.ATTRIBUTE16;
		l_trans_rec.attribute17         := l_interface_rec.ATTRIBUTE17;
		l_trans_rec.attribute18         := l_interface_rec.ATTRIBUTE18;
		l_trans_rec.attribute19         := l_interface_rec.ATTRIBUTE19;
		l_trans_rec.attribute20         := l_interface_rec.ATTRIBUTE20;
		l_trans_rec.attribute21         := l_interface_rec.ATTRIBUTE21;
		l_trans_rec.attribute22         := l_interface_rec.ATTRIBUTE22;
		l_trans_rec.attribute23         := l_interface_rec.ATTRIBUTE23;
		l_trans_rec.attribute24         := l_interface_rec.ATTRIBUTE24;
		l_trans_rec.attribute25         := l_interface_rec.ATTRIBUTE25;
		l_trans_rec.attribute26         := l_interface_rec.ATTRIBUTE26;
		l_trans_rec.attribute27         := l_interface_rec.ATTRIBUTE27;
		l_trans_rec.attribute28         := l_interface_rec.ATTRIBUTE28;
		l_trans_rec.attribute29         := l_interface_rec.ATTRIBUTE29;
		l_trans_rec.attribute30         := l_interface_rec.ATTRIBUTE30;
		l_trans_rec.attribute_category  := l_interface_rec.ATTRIBUTE_CATEGORY;
		l_trans_rec.acctg_unit_no	:= l_interface_rec.ACCTG_UNIT_NO;
		l_trans_rec.acct_no		:= l_interface_rec.ACCT_NO;

		IF( l_interface_rec.transaction_date IS NULL )
		THEN
		  l_trans_rec.trans_date	:= SYSDATE;
		ELSE
		  l_trans_rec.trans_date	:= TO_DATE(l_interface_rec.transaction_date,
							'YYYY/MM/DD HH24:MI:SS');
		END IF;

		l_trans_rec.reason_code		:= l_interface_rec.reason_code;

		IF( l_interface_rec.user_name IS NULL )
		THEN
		  l_trans_rec.user_name		:= 'OPM';
		ELSE
		  l_trans_rec.user_name		:= l_interface_rec.user_name;
		END IF;

		l_trans_rec.journal_comment	:= l_interface_rec.journal_comment;

		-- Set the context for the GMI APIs
		IF( NOT Gmigutl.Setup(l_interface_rec.user_name) )
		THEN
			RAISE e_txn_failed;
		END IF;

		-- Call the standard API and check the return status
		Gmipapi.Inventory_Posting
		( p_api_version    => 3.0
		, p_init_msg_list  => FND_API.G_TRUE
		, p_commit         => FND_API.G_FALSE
		, p_validation_level  => FND_API.G_valid_level_full
		, p_qty_rec  => l_trans_rec
		, x_ic_jrnl_mst_row => l_ic_jrnl_mst_row
		, x_ic_adjs_jnl_row1 => l_ic_adjs_jnl_row1
		, x_ic_adjs_jnl_row2 => l_ic_adjs_jnl_row2
		, x_return_status  => l_status
		, x_msg_count      => l_count
		, x_msg_data       => l_data
		);

		IF( l_status IN ('U','E') )
		THEN
			RAISE e_txn_failed;
		ELSE
			FOR l_loop_cnt IN 1..l_count
			LOOP

			  FND_MSG_PUB.Get(
			    p_msg_index     => l_loop_cnt,
			    p_data          => l_data,
			    p_encoded       => FND_API.G_FALSE,
			    p_msg_index_out => l_dummy_cnt);

			-- write to log
			/*	log_message(	p_proc_name => 'process_transaction',
						p_if_id => l_qty_iface_id,
						p_msg => l_data);*/

			END LOOP;

			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_SUCCESS');
			l_confirm_statuslvl := FND_MESSAGE.get;

			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_QTY_S');
			l_confirm_descrtn := FND_MESSAGE.get;

		    	l_icn 	:= wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'PARAMETER7');

		    	l_event_key  := l_interface_rec.transaction_type||'.'||l_trans_rec.item_no||'.'||l_ext_txn_id;

		    	send_outbound_document(	l_confirm_statuslvl,
						l_confirm_descrtn,
						l_data,
						l_confirm_statuslvl,
						l_icn,
						l_event_key);

			DELETE  FROM	gmi_quantity_xml_interface
			WHERE	quantity_interface_id 	= l_qty_iface_id
			AND	ext_transaction_id 	= l_ext_txn_id;

			resultout := 'COMPLETE:Y';
		END IF;



		/*  Update error status    */
		l_return_status  := l_status;

		-- End of funcmode = RUN

	ELSIF funcmode = 'CANCEL'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'RESPOND'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'FORWARD'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TRANSFER'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TIMEOUT'
	THEN
		resultout := 'COMPLETE';

	ELSE
		resultout := NULL;
	END IF;

EXCEPTION
	WHEN e_txn_not_found THEN
		log_message(
			p_proc_name => 'process_transaction',
			p_if_id => l_qty_iface_id,
			p_msg => 'Could not find the interface record for if id =>'||
				l_qty_iface_id || ' ext id =>' || l_ext_txn_id);

		resultout := 'COMPLETE:N';

		RAISE;

	WHEN e_txn_failed THEN
		resultout := 'COMPLETE:N';
		-- API Failed. Error message must be on stack.
		l_count_msg := fnd_msg_pub.Count_Msg;

		FOR l_loop_cnt IN 1..l_count_msg
		LOOP
			FND_MSG_PUB.GET(P_msg_index     => l_loop_cnt,
			P_data          => l_data,
			P_encoded       => FND_API.G_FALSE,
			P_msg_index_out => l_dummy_cnt);

			log_message(p_proc_name => 'process_transaction',
				p_if_id => l_qty_iface_id,
				p_msg => 'Error :' || l_data);
		END LOOP;


		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_FAIL');
		l_confirm_statuslvl := FND_MESSAGE.get;

		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_QTY_F');
		l_confirm_descrtn := FND_MESSAGE.get;

		-- Set the appropriate attributes for confirmation
		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_STATUSLVL',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DESCRTN',
			avalue   => l_confirm_descrtn);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_DESCRIPTN',
			avalue   => l_data);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_REASONCODE',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_EVENT_KEY',
			avalue   => l_interface_rec.transaction_type||'.'||l_trans_rec.item_no||'.'||l_ext_txn_id);

		--RAISE;

END process_transaction;


---------------------------------------------------------------------------------

PROCEDURE create_item (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 )
IS

l_item_interface_rec		gmi_items_xml_interface%ROWTYPE;
l_item_rec			Gmigapi.item_rec_typ;

l_ic_item_mst_row	ic_item_mst%ROWTYPE;
l_ic_item_cpg_row   	ic_item_cpg%ROWTYPE;

l_status	VARCHAR2(1);
l_return_status	VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count		NUMBER;
l_count_msg	NUMBER;
l_data		VARCHAR2(2000);
l_dummy_cnt	NUMBER  :=0;
l_record_count	NUMBER  :=0;

CURSOR c_item_rec(p_item_interface_id NUMBER, p_ext_item_id NUMBER) IS
SELECT 	*
FROM	gmi_items_xml_interface
WHERE	item_interface_id = p_item_interface_id
AND	EXT_ITEM_ID = p_ext_item_id;

l_item_iface_id	NUMBER(15);
l_ext_item_id	NUMBER(15);

e_item_not_found	EXCEPTION;
e_item_creation_failed	EXCEPTION;

l_int_control_number	NUMBER;
l_party_type		VARCHAR2(256);

l_trigger_id	      	   PLS_INTEGER;
l_retcode		 PLS_INTEGER;
l_errmsg		 VARCHAR2(2000)   ;

l_event_name		VARCHAR2(100);
l_event_key		VARCHAR2(100);
l_icn			NUMBER;

l_confirm_statuslvl	VARCHAR2(500);
l_confirm_descrtn	VARCHAR2(500);


BEGIN
	IF( funcmode = 'RUN' )
	THEN
		resultout := 'COMPLETE:Y';

		-- Get the variables and call the api procedure
		l_item_iface_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'GMI_ITEM_INTERFACE_ID');

		l_ext_item_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'EXT_ITEM_ID');

		OPEN c_item_rec(l_item_iface_id, l_ext_item_id);
		FETCH c_item_rec INTO l_item_interface_rec;
		IF( c_item_rec%NOTFOUND )
		THEN
			CLOSE c_item_rec;
			RAISE e_item_not_found;
		END IF;
		CLOSE c_item_rec;

		Wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_NUMBER',
				avalue   => l_item_interface_rec.item_number);

		l_item_rec.item_no		:= l_item_interface_rec.ITEM_NUMBER          ;
		l_item_rec.item_desc1           := l_item_interface_rec.ITEM_DESC1           ;
		l_item_rec.item_desc2           := l_item_interface_rec.ITEM_DESC2           ;
		l_item_rec.alt_itema            := l_item_interface_rec.ALT_ITEMA            ;
		l_item_rec.alt_itemb            := l_item_interface_rec.ALT_ITEMB            ;
		l_item_rec.item_um              := l_item_interface_rec.ITEM_UOM             ;
		l_item_rec.dualum_ind           := l_item_interface_rec.DUALUM_IND           ;
		l_item_rec.item_um2             := l_item_interface_rec.ITEM_UOM2            ;
		l_item_rec.deviation_lo         := l_item_interface_rec.DEVIATION_LO         ;
		l_item_rec.deviation_hi         := l_item_interface_rec.DEVIATION_HI         ;
		l_item_rec.level_code           := l_item_interface_rec.LEVEL_CODE           ;
		l_item_rec.lot_ctl              := l_item_interface_rec.LOT_CTL              ;
		l_item_rec.lot_indivisible      := l_item_interface_rec.LOT_INDIVISIBLE      ;
		l_item_rec.sublot_ctl           := l_item_interface_rec.SUBLOT_CTL           ;
		l_item_rec.loct_ctl             := l_item_interface_rec.LOCT_CTL             ;
		l_item_rec.noninv_ind           := l_item_interface_rec.NONINV_IND           ;
		l_item_rec.match_type           := l_item_interface_rec.MATCH_TYPE           ;
		l_item_rec.inactive_ind         := l_item_interface_rec.INACTIVE_IND         ;
		l_item_rec.inv_type             := l_item_interface_rec.INV_TYPE             ;
		l_item_rec.shelf_life           := l_item_interface_rec.SHELF_LIFE           ;
		l_item_rec.retest_interval      := l_item_interface_rec.RETEST_INTERVAL      ;
		l_item_rec.item_abccode         := l_item_interface_rec.ITEM_ABCCODE         ;
		l_item_rec.gl_class             := l_item_interface_rec.GL_CLASS             ;
		l_item_rec.inv_class            := l_item_interface_rec.INV_CLASS            ;
		l_item_rec.sales_class          := l_item_interface_rec.SALES_CLASS          ;
		l_item_rec.ship_class           := l_item_interface_rec.SHIP_CLASS           ;
		l_item_rec.frt_class            := l_item_interface_rec.FRT_CLASS            ;
		l_item_rec.price_class          := l_item_interface_rec.PRICE_CLASS          ;
		l_item_rec.storage_class        := l_item_interface_rec.STORAGE_CLASS        ;
		l_item_rec.purch_class          := l_item_interface_rec.PURCH_CLASS          ;
		l_item_rec.tax_class            := l_item_interface_rec.TAX_CLASS            ;
		l_item_rec.customs_class        := l_item_interface_rec.CUSTOMS_CLASS        ;
		l_item_rec.alloc_class          := l_item_interface_rec.ALLOC_CLASS          ;
		l_item_rec.planning_class       := l_item_interface_rec.PLANNING_CLASS       ;
		l_item_rec.itemcost_class       := l_item_interface_rec.ITEMCOST_CLASS       ;
		l_item_rec.cost_mthd_code       := l_item_interface_rec.COST_MTHD_CODE       ;
		l_item_rec.upc_code             := l_item_interface_rec.UPC_CODE             ;
		l_item_rec.grade_ctl            := l_item_interface_rec.GRADE_CTL            ;
		l_item_rec.status_ctl           := l_item_interface_rec.STATUS_CTL           ;
		l_item_rec.qc_grade             := l_item_interface_rec.QC_GRADE             ;
		l_item_rec.lot_status           := l_item_interface_rec.LOT_STATUS           ;
		l_item_rec.bulk_id              := l_item_interface_rec.BULK_ID              ;
		l_item_rec.pkg_id               := l_item_interface_rec.PKG_ID               ;
		l_item_rec.qcitem_no            := l_item_interface_rec.QCITEM_NUMBER            ;
		l_item_rec.qchold_res_code      := l_item_interface_rec.QCHOLD_RES_CODE      ;
		l_item_rec.expaction_code       := l_item_interface_rec.EXPACTION_CODE       ;
		l_item_rec.fill_qty             := l_item_interface_rec.FILL_QTY             ;
		l_item_rec.fill_um              := l_item_interface_rec.FILL_UM              ;
		l_item_rec.expaction_interval   := l_item_interface_rec.EXPACTION_INTERVAL   ;
		l_item_rec.phantom_type         := l_item_interface_rec.PHANTOM_TYPE         ;
		l_item_rec.whse_item_no         := l_item_interface_rec.WHSE_ITEM_NUMBER         ;
		l_item_rec.experimental_ind     := l_item_interface_rec.EXPERIMENTAL_IND     ;
		--l_item_rec.exported_date      := l_item_interface_rec.EXPORTED_DATE        ;
		l_item_rec.seq_dpnd_class       := l_item_interface_rec.SEQ_DPND_CLASS       ;
		l_item_rec.commodity_code       := l_item_interface_rec.COMMODITY_CODE       ;
		l_item_rec.ic_matr_days         := l_item_interface_rec.IC_MATR_DAYS         ;
		l_item_rec.ic_hold_days         := l_item_interface_rec.IC_HOLD_DAYS         ;
		l_item_rec.attribute1           := l_item_interface_rec.ATTRIBUTE1           ;
		l_item_rec.attribute2           := l_item_interface_rec.ATTRIBUTE2           ;
		l_item_rec.attribute3           := l_item_interface_rec.ATTRIBUTE3           ;
		l_item_rec.attribute4           := l_item_interface_rec.ATTRIBUTE4           ;
		l_item_rec.attribute5           := l_item_interface_rec.ATTRIBUTE5           ;
		l_item_rec.attribute6           := l_item_interface_rec.ATTRIBUTE6           ;
		l_item_rec.attribute7           := l_item_interface_rec.ATTRIBUTE7           ;
		l_item_rec.attribute8           := l_item_interface_rec.ATTRIBUTE8           ;
		l_item_rec.attribute9           := l_item_interface_rec.ATTRIBUTE9           ;
		l_item_rec.attribute10          := l_item_interface_rec.ATTRIBUTE10          ;
		l_item_rec.attribute11          := l_item_interface_rec.ATTRIBUTE11          ;
		l_item_rec.attribute12          := l_item_interface_rec.ATTRIBUTE12          ;
		l_item_rec.attribute13          := l_item_interface_rec.ATTRIBUTE13          ;
		l_item_rec.attribute14          := l_item_interface_rec.ATTRIBUTE14          ;
		l_item_rec.attribute15          := l_item_interface_rec.ATTRIBUTE15          ;
		l_item_rec.attribute16          := l_item_interface_rec.ATTRIBUTE16          ;
		l_item_rec.attribute17          := l_item_interface_rec.ATTRIBUTE17          ;
		l_item_rec.attribute18          := l_item_interface_rec.ATTRIBUTE18          ;
		l_item_rec.attribute19          := l_item_interface_rec.ATTRIBUTE19          ;
		l_item_rec.attribute20          := l_item_interface_rec.ATTRIBUTE20          ;
		l_item_rec.attribute21          := l_item_interface_rec.ATTRIBUTE21          ;
		l_item_rec.attribute22          := l_item_interface_rec.ATTRIBUTE22           ;
		l_item_rec.attribute23          := l_item_interface_rec.ATTRIBUTE23           ;
		l_item_rec.attribute24          := l_item_interface_rec.ATTRIBUTE24           ;
		l_item_rec.attribute25          := l_item_interface_rec.ATTRIBUTE25           ;
		l_item_rec.attribute26          := l_item_interface_rec.ATTRIBUTE26           ;
		l_item_rec.attribute27          := l_item_interface_rec.ATTRIBUTE27           ;
		l_item_rec.attribute28          := l_item_interface_rec.ATTRIBUTE28           ;
		l_item_rec.attribute29          := l_item_interface_rec.ATTRIBUTE29           ;
		l_item_rec.attribute30          := l_item_interface_rec.ATTRIBUTE30           ;
		l_item_rec.attribute_category   := l_item_interface_rec.ATTRIBUTE_CATEGORY    ;
		--l_item_rec.user_name            := l_item_interface_rec.USER_NAME             ;
		l_item_rec.ont_pricing_qty_source:= l_item_interface_rec.ONT_PRICING_QTY_SOURCE;

		IF ( l_item_interface_rec.EXPORTED_DATE IS NULL )
  		THEN
    			l_item_rec.exported_date :=TO_DATE('02011970','DDMMYYYY');
  		ELSE
    			l_item_rec.exported_date :=TO_DATE(l_item_interface_rec.EXPORTED_DATE,
							'YYYY/MM/DD HH24:MI:SS');
  		END IF;

		IF( l_item_interface_rec.user_name IS NULL )
		THEN
		  	l_item_rec.user_name	:= 'OPM';
		ELSE
		  	l_item_rec.user_name	:= l_item_interface_rec.user_name;
		END IF;

		-- Set the context for the GMI APIs
		IF( NOT Gmigutl.Setup(l_item_rec.user_name) )
		THEN
			RAISE e_item_creation_failed;
		END IF;

		-- Call the standard API and check the return status
		Gmipapi.Create_Item
		(  p_api_version    => 3.0
		, p_init_msg_list  => FND_API.G_TRUE
		, p_commit         => FND_API.G_TRUE
		, p_validation_level => FND_API.G_VALID_LEVEL_FULL
		, p_item_rec        => l_item_rec
		, x_ic_item_mst_row  => l_ic_item_mst_row
		, x_ic_item_cpg_row  => l_ic_item_cpg_row
		, x_return_status    => l_status
		, x_msg_count        => l_count
		, x_msg_data         => l_data
		);


		-- for the outbound confirmation set the party type as internal.
		l_party_type		:= 'I';

		IF( l_status IN ('U','E') )
		THEN

		    RAISE e_item_creation_failed;

		ELSE

		    	FOR l_loop_cnt IN 1..l_count
			LOOP

			  FND_MSG_PUB.Get(
			    p_msg_index     => l_loop_cnt,
			    p_data          => l_data,
			    p_encoded       => FND_API.G_FALSE,
			    p_msg_index_out => l_dummy_cnt);

			-- write to log
			/*log_message(	p_proc_name => 'create_item',
					p_if_id => l_item_iface_id,
					p_msg => l_data);*/

			END LOOP;

			l_icn 	:= wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'PARAMETER7');

			l_event_key  := l_item_rec.item_no||'.'||l_ext_item_id;


			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_SUCCESS');
			l_confirm_statuslvl := FND_MESSAGE.get;

			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_ITEM_S');
			l_confirm_descrtn := FND_MESSAGE.get;

			send_outbound_document(	l_confirm_statuslvl,
						l_confirm_descrtn,
						l_data,
						l_confirm_statuslvl,
						l_icn,
						l_event_key);

			DELETE  FROM	gmi_items_xml_interface
			WHERE	item_interface_id = l_item_iface_id
			AND	EXT_ITEM_ID = l_ext_item_id;

			resultout := 'COMPLETE:Y';

		END IF;

		/*  Update error status    */
		l_return_status  := l_status;

		-- End of funcmode = RUN

	ELSIF funcmode = 'CANCEL'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'RESPOND'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'FORWARD'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TRANSFER'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TIMEOUT'
	THEN
		resultout := 'COMPLETE';

	ELSE
		resultout := NULL;

	END IF;

EXCEPTION
	WHEN e_item_not_found THEN
		log_message(
			p_proc_name => 'create_item',
			p_if_id => l_item_iface_id,
			p_msg => 'Could not find the interface record for if id =>'||
				l_item_iface_id || ' ext item id =>' || l_ext_item_id);

		resultout := 'COMPLETE:N';

		RAISE;

	WHEN e_item_creation_failed THEN
		resultout := 'COMPLETE:N';
		-- API Failed. Error message must be on stack.
		l_count_msg := fnd_msg_pub.Count_Msg;

		FOR l_loop_cnt IN 1..l_count_msg
		LOOP
			FND_MSG_PUB.GET(P_msg_index     => l_loop_cnt,
			P_data          => l_data,
			P_encoded       => FND_API.G_FALSE,
			P_msg_index_out => l_dummy_cnt);

			log_message(p_proc_name => 'create_item',
				p_if_id => l_item_iface_id,
				p_msg => 'Error :' || l_data);
		END LOOP;


		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_FAIL');
		l_confirm_statuslvl := FND_MESSAGE.get;

		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_ITEM_F');
		l_confirm_descrtn := FND_MESSAGE.get;

		-- Set the appropriate attributes for confirmation
		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_STATUSLVL',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DESCRTN',
			avalue   => l_confirm_descrtn);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_DESCRIPTN',
			avalue   => l_data);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_REASONCODE',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_EVENT_KEY',
			avalue   => l_item_rec.item_no||'.'||l_ext_item_id);

		--RAISE;

END create_item;

--------------------------------------------------------------------------------


PROCEDURE create_lot (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 )
IS

l_interface_rec		gmi_lots_xml_interface%ROWTYPE;
l_trans_rec		Gmigapi.lot_rec_typ;

l_ic_lots_mst_row       ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_row       ic_lots_cpg%ROWTYPE;

l_status	VARCHAR2(1);
l_return_status	VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count		NUMBER;
l_count_msg	NUMBER;
l_data		VARCHAR2(2000);
l_dummy_cnt	NUMBER  :=0;
l_record_count	NUMBER  :=0;

CURSOR c_if_rec(p_interface_id NUMBER, p_ext_lot_id NUMBER) IS
SELECT *
FROM	gmi_lots_xml_interface
WHERE	lot_interface_id = p_interface_id
AND	ext_lot_id = p_ext_lot_id;

l_lot_iface_id	NUMBER(15);
l_ext_lot_id	NUMBER(15);

e_lot_not_found	EXCEPTION;
e_lot_failed	EXCEPTION;

l_event_name		VARCHAR2(100);
l_event_key		VARCHAR2(100);
l_icn			NUMBER;

l_confirm_statuslvl	VARCHAR2(500);
l_confirm_descrtn	VARCHAR2(500);

l_party_type		VARCHAR2(256);
l_ext_txn_id      	NUMBER(15);

BEGIN
	IF( funcmode = 'RUN' )
	THEN
		resultout := 'COMPLETE:Y';

		-- Get the variables and call the api procedure
		l_lot_iface_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'GMI_LOT_INTERFACE_ID');

		l_ext_lot_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'EXT_LOT_ID');

		OPEN c_if_rec(l_lot_iface_id, l_ext_lot_id);
		FETCH c_if_rec INTO l_interface_rec;
		IF( c_if_rec%NOTFOUND )
		THEN
			CLOSE c_if_rec;
			RAISE e_lot_not_found;
		END IF;
		CLOSE c_if_rec;

		Wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_NUMBER',
				avalue   => l_interface_rec.item_number);


       l_trans_rec.item_no          := l_interface_rec.item_number;
       l_trans_rec.lot_no           := l_interface_rec.lot_number;
       l_trans_rec.sublot_no        := l_interface_rec.sublot_number;
       l_trans_rec.lot_desc         := l_interface_rec.lot_desc;
       l_trans_rec.qc_grade         := l_interface_rec.qc_grade;
       l_trans_rec.expaction_code   := l_interface_rec.expaction_code;
       IF (l_interface_rec.expaction_date IS NOT NULL) THEN
        l_trans_rec.expaction_date := TO_DATE(l_interface_rec.expaction_date,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       IF (l_interface_rec.lot_created  IS NOT NULL) THEN
        l_trans_rec.lot_created    := TO_DATE(l_interface_rec.lot_created,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       IF (l_interface_rec.expire_date  IS NOT NULL) THEN
        l_trans_rec.expire_date    := TO_DATE(l_interface_rec.expire_date,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       IF (l_interface_rec.retest_date  IS NOT NULL) THEN
        l_trans_rec.retest_date    := TO_DATE(l_interface_rec.retest_date,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       l_trans_rec.strength         := l_interface_rec.strength;
       l_trans_rec.inactive_ind     := l_interface_rec.inactive_ind;
       l_trans_rec.origination_type := l_interface_rec.origination_type;
       l_trans_rec.shipvendor_no    := l_interface_rec.shipvendor_no;
       l_trans_rec.vendor_lot_no    := l_interface_rec.vendor_lot_no;
       IF (l_interface_rec.ic_matr_date IS NOT NULL) THEN
        l_trans_rec.ic_matr_date := TO_DATE(l_interface_rec.ic_matr_date,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       IF (l_interface_rec.ic_hold_date IS NOT NULL) THEN
        l_trans_rec.ic_hold_date := TO_DATE(l_interface_rec.ic_hold_date,
                                       'YYYY/MM/DD HH24:MI:SS');
       END IF;
       l_trans_rec.attribute1       := l_interface_rec.attribute1;
       l_trans_rec.attribute2       := l_interface_rec.attribute2;
       l_trans_rec.attribute3       := l_interface_rec.attribute3;
       l_trans_rec.attribute4       := l_interface_rec.attribute4;
       l_trans_rec.attribute5       := l_interface_rec.attribute5;
       l_trans_rec.attribute6       := l_interface_rec.attribute6;
       l_trans_rec.attribute7       := l_interface_rec.attribute7;
       l_trans_rec.attribute8       := l_interface_rec.attribute8;
       l_trans_rec.attribute9       := l_interface_rec.attribute9;
       l_trans_rec.attribute10      := l_interface_rec.attribute10;
       l_trans_rec.attribute11      := l_interface_rec.attribute11;
       l_trans_rec.attribute12      := l_interface_rec.attribute12;
       l_trans_rec.attribute13      := l_interface_rec.attribute13;
       l_trans_rec.attribute14      := l_interface_rec.attribute14;
       l_trans_rec.attribute15      := l_interface_rec.attribute15;
       l_trans_rec.attribute16      := l_interface_rec.attribute16;
       l_trans_rec.attribute17      := l_interface_rec.attribute17;
       l_trans_rec.attribute18      := l_interface_rec.attribute18;
       l_trans_rec.attribute19      := l_interface_rec.attribute19;
       l_trans_rec.attribute20      := l_interface_rec.attribute20;
       l_trans_rec.attribute21      := l_interface_rec.attribute21;
       l_trans_rec.attribute22      := l_interface_rec.attribute22;
       l_trans_rec.attribute23      := l_interface_rec.attribute23;
       l_trans_rec.attribute24      := l_interface_rec.attribute24;
       l_trans_rec.attribute25      := l_interface_rec.attribute25;
       l_trans_rec.attribute26      := l_interface_rec.attribute26;
       l_trans_rec.attribute27      := l_interface_rec.attribute27;
       l_trans_rec.attribute28      := l_interface_rec.attribute28;
       l_trans_rec.attribute29      := l_interface_rec.attribute29;
       l_trans_rec.attribute30      := l_interface_rec.attribute30;
       l_trans_rec.attribute_category    := l_interface_rec.attribute_category;

       IF (l_interface_rec.user_name IS NULL ) THEN
          l_trans_rec.user_name		:= 'OPM';
       ELSE
          l_trans_rec.user_name		:= l_interface_rec.user_name;
       END IF;


		-- Set the context for the GMI APIs
		IF( NOT Gmigutl.Setup(l_trans_rec.user_name) )
		THEN
			RAISE e_lot_failed;
		END IF;

		-- Call the standard API and check the return status
		Gmipapi.Create_Lot
		( p_api_version    => 3.0
		, p_init_msg_list  => FND_API.G_TRUE
		, p_commit         => FND_API.G_FALSE
		, p_validation_level  => FND_API.G_valid_level_full
		, p_lot_rec  => l_trans_rec
		, x_ic_lots_mst_row => l_ic_lots_mst_row
		, x_ic_lots_cpg_row => l_ic_lots_cpg_row
		, x_return_status  => l_status
		, x_msg_count      => l_count
		, x_msg_data       => l_data
		);

		l_party_type		:= 'I';

		IF( l_status IN ('U','E') )
		THEN
			RAISE e_lot_failed;
		ELSE

			FOR l_loop_cnt IN 1..l_count
			LOOP

			  FND_MSG_PUB.Get(
			    p_msg_index     => l_loop_cnt,
			    p_data          => l_data,
			    p_encoded       => FND_API.G_FALSE,
			    p_msg_index_out => l_dummy_cnt);

			  -- write to log
			  /*log_message(p_proc_name => 'create_lot',
				p_if_id => l_lot_iface_id,
				p_msg => l_data);*/

			END LOOP;

		    	l_icn 	:= wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'PARAMETER7');

		    	l_event_key  := l_interface_rec.item_number||'.'||l_trans_rec.lot_no||'.'||l_ext_lot_id;

			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_SUCCESS');
			l_confirm_statuslvl := FND_MESSAGE.get;

			FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_LOT_S');
			l_confirm_descrtn := FND_MESSAGE.get;

		    	send_outbound_document(	l_confirm_statuslvl,
						l_confirm_descrtn,
						l_data,
						l_confirm_statuslvl,
						l_icn,
						l_event_key);

			DELETE	FROM	gmi_lots_xml_interface
			WHERE	lot_interface_id = l_lot_iface_id
			AND	ext_lot_id = l_ext_lot_id;

			resultout := 'COMPLETE:Y';
		END IF;



		/*  Update error status    */
		l_return_status  := l_status;

		-- End of funcmode = RUN

	ELSIF funcmode = 'CANCEL'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'RESPOND'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'FORWARD'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TRANSFER'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TIMEOUT'
	THEN
		resultout := 'COMPLETE';

	ELSE
		resultout := NULL;
	END IF;

EXCEPTION
	WHEN e_lot_not_found THEN
		log_message(
			p_proc_name => 'create_lot',
			p_if_id => l_lot_iface_id,
			p_msg => 'Could not find the interface record for if id =>'||
				l_lot_iface_id || ' ext id =>' || l_ext_lot_id);

		resultout := 'COMPLETE:N';

		RAISE;

	WHEN e_lot_failed THEN
		resultout := 'COMPLETE:N';
		-- API Failed. Error message must be on stack.
		l_count_msg := fnd_msg_pub.Count_Msg;

		FOR l_loop_cnt IN 1..l_count_msg
		LOOP
			FND_MSG_PUB.GET(P_msg_index     => l_loop_cnt,
			P_data          => l_data,
			P_encoded       => FND_API.G_FALSE,
			P_msg_index_out => l_dummy_cnt);

			log_message(p_proc_name => 'create_lot',
				p_if_id => l_lot_iface_id,
				p_msg => 'Error :' || l_data);
		END LOOP;


		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_FAIL');
		l_confirm_statuslvl := FND_MESSAGE.get;

		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_LOT_F');
		l_confirm_descrtn := FND_MESSAGE.get;

		-- Set the appropriate attributes for confirmation
		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_STATUSLVL',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DESCRTN',
			avalue   => l_confirm_descrtn);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_DESCRIPTN',
			avalue   => l_data);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_REASONCODE',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_EVENT_KEY',
			avalue   => l_interface_rec.item_number||'.'||l_trans_rec.lot_no||'.'||l_ext_txn_id);

		--RAISE;


END create_lot;

----------------------------------------------------------------------------
PROCEDURE create_lot_conversion (
 item_type	IN	 VARCHAR2,
 item_key	IN	 VARCHAR2,
 actid	 	IN	 NUMBER,
 funcmode	IN	 VARCHAR2,
 resultout	IN OUT NOCOPY VARCHAR2 )
IS

l_lot_interface_rec       gmi_lots_conv_xml_interface%ROWTYPE;
l_trans_rec	          Gmigapi.conv_rec_typ;

l_ic_item_cnv_row         IC_ITEM_CNV%ROWTYPE;



l_status	VARCHAR2(1);
l_return_status	VARCHAR2(1)  :=FND_API.G_RET_STS_SUCCESS;
l_count		NUMBER;
l_count_msg	NUMBER;
l_data		VARCHAR2(2000);
l_dummy_cnt	NUMBER  :=0;
l_record_count	NUMBER  :=0;

CURSOR c_if_rec(p_interface_id NUMBER, p_ext_lot_id NUMBER) IS
SELECT *
FROM	gmi_lots_conv_xml_interface
WHERE	conv_interface_id = p_interface_id
AND	ext_conv_id = p_ext_lot_id;

l_lot_iface_id	NUMBER(15);
l_ext_lot_id	NUMBER(15);

e_lot_not_found	EXCEPTION;
e_lot_conv_failed	EXCEPTION;

l_event_name		VARCHAR2(100);
l_event_key		VARCHAR2(100);
l_icn			NUMBER;

l_confirm_statuslvl	VARCHAR2(500);
l_confirm_descrtn	VARCHAR2(500);

l_ext_txn_id      	NUMBER(15);
l_party_type		VARCHAR2(256);

BEGIN
	IF( funcmode = 'RUN' )
	THEN
		resultout := 'COMPLETE:Y';

		-- Get the variables and call the api procedure
		l_lot_iface_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'CONV_INTERFACE_ID');

		l_ext_lot_id := wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'EXT_CONV_ID');

		OPEN c_if_rec(l_lot_iface_id, l_ext_lot_id);
		FETCH c_if_rec INTO l_lot_interface_rec;
		IF( c_if_rec%NOTFOUND )
		THEN
			CLOSE c_if_rec;
			RAISE e_lot_not_found;
		END IF;
		CLOSE c_if_rec;

		Wf_engine.SetItemAttrText(
				itemtype => item_type,
				itemkey  => item_key,
				aname    => 'GMI_ITEM_NUMBER',
				avalue   => l_lot_interface_rec.item_number);


       l_trans_rec.item_no          := l_lot_interface_rec.item_number;
       l_trans_rec.lot_no           := l_lot_interface_rec.lot_number;
       l_trans_rec.sublot_no        := l_lot_interface_rec.sublot_number;
       l_trans_rec.from_uom         := l_lot_interface_rec.from_uom;
       l_trans_rec.to_uom           := l_lot_interface_rec.to_uom;
       l_trans_rec.type_factor      := l_lot_interface_rec.type_factor;


       IF (l_lot_interface_rec.user_name IS NULL ) THEN
          l_trans_rec.user_name		:= 'OPM';
       ELSE
          l_trans_rec.user_name		:= l_lot_interface_rec.user_name;
       END IF;


		-- Set the context for the GMI APIs
		IF( NOT Gmigutl.Setup(l_trans_rec.user_name) )
		THEN
			RAISE e_lot_conv_failed;
		END IF;

		-- Call the standard API and check the return status
		Gmipapi.Create_Item_Lot_Conv
		( p_api_version    => 3.0
		, p_init_msg_list  => FND_API.G_TRUE
		, p_commit         => FND_API.G_FALSE
		, p_validation_level  => FND_API.G_valid_level_full
		, p_conv_rec  => l_trans_rec
		, x_ic_item_cnv_row => l_ic_item_cnv_row
		, x_return_status  => l_status
		, x_msg_count      => l_count
		, x_msg_data       => l_data
		);

		l_party_type		:= 'I';

		IF( l_status IN ('U','E') )
		THEN
			RAISE e_lot_conv_failed;

		ELSE
			FOR l_loop_cnt IN 1..l_count
			LOOP

			  FND_MSG_PUB.Get(
			    p_msg_index     => l_loop_cnt,
			    p_data          => l_data,
			    p_encoded       => FND_API.G_FALSE,
			    p_msg_index_out => l_dummy_cnt);

			  -- write to log
			  /*log_message(p_proc_name => 'create_lot_conversion',
				p_if_id => l_lot_iface_id,
				p_msg => l_data);*/

			END LOOP;


		    	l_icn 	:= wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'PARAMETER7');

  		    	l_event_key  := l_lot_interface_rec.item_number||'.'||l_trans_rec.lot_no||'.'||l_ext_lot_id;


	        FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_SUCCESS');
			l_confirm_statuslvl := FND_MESSAGE.get;

                FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_LTCV_S');

			l_confirm_descrtn := FND_MESSAGE.get;

		    	send_outbound_document(	l_confirm_statuslvl,
						l_confirm_descrtn,
						l_data,
						l_confirm_statuslvl,
						l_icn,
						l_event_key);

			DELETE FROM	gmi_lots_conv_xml_interface
			WHERE	conv_interface_id = l_lot_iface_id
			AND	ext_conv_id = l_ext_lot_id;


			resultout := 'COMPLETE:Y';
               END IF;

		/*  Update error status    */
		l_return_status  := l_status;

		-- End of funcmode = RUN

	ELSIF funcmode = 'CANCEL'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'RESPOND'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'FORWARD'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TRANSFER'
	THEN
		resultout := 'COMPLETE';

	ELSIF funcmode = 'TIMEOUT'
	THEN
		resultout := 'COMPLETE';

	ELSE
		resultout := NULL;
	END IF;

EXCEPTION
	WHEN e_lot_not_found THEN
		log_message(
			p_proc_name => 'create_lot_conversion',
			p_if_id => l_lot_iface_id,
			p_msg => 'Could not find the interface record for if id =>'||
				l_lot_iface_id || ' ext id =>' || l_ext_lot_id);

		resultout := 'COMPLETE:N';

		RAISE;

	WHEN e_lot_conv_failed THEN
		resultout := 'COMPLETE:N';
		-- API Failed. Error message must be on stack.
		l_count_msg := fnd_msg_pub.Count_Msg;

		FOR l_loop_cnt IN 1..l_count_msg
		LOOP
			FND_MSG_PUB.GET(P_msg_index     => l_loop_cnt,
			P_data          => l_data,
			P_encoded       => FND_API.G_FALSE,
			P_msg_index_out => l_dummy_cnt);

			log_message(p_proc_name => 'create_lot_conversion',
				p_if_id => l_lot_iface_id,
				p_msg => 'Error :' || l_data);
		END LOOP;


		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_STATUS_FAIL');
		l_confirm_statuslvl := FND_MESSAGE.get;

		FND_MESSAGE.set_name('GMI', 'GMI_XML_CONFIRM_DESCRTN_LTCV_F');
		l_confirm_descrtn := FND_MESSAGE.get;

		-- Set the appropriate attributes for confirmation
		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_STATUSLVL',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DESCRTN',
			avalue   => l_confirm_descrtn);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_DESCRIPTN',
			avalue   => l_data);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_REASONCODE',
			avalue   => l_confirm_statuslvl);

		wf_engine.SetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_EVENT_KEY',
			avalue   => l_lot_interface_rec.item_number||'.'||l_trans_rec.lot_no||'.'||l_ext_txn_id);

		--RAISE;


END create_lot_conversion;

-------------------------------------------------------------------
PROCEDURE log_message(	p_proc_name IN VARCHAR2,
			p_if_id IN NUMBER,
			p_msg IN VARCHAR2)
IS

BEGIN
	wf_core.context(pkg_name => G_PKG_NAME,
			proc_name => p_proc_name,
			arg1 => p_msg);

	-- Also update the interface table with status/messages
	update_status(	p_proc_name => p_proc_name,
			p_if_id => p_if_id,
			p_err_msg => p_msg);

END log_message;

------------------------------------------------------------------
PROCEDURE update_status(
	p_proc_name	IN VARCHAR2,
	p_if_id IN NUMBER,
	p_err_msg IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
	IF p_proc_name = 'process_transaction' THEN
		UPDATE 	gmi_quantity_xml_interface
		SET	error_text = SUBSTRB(error_text || p_err_msg, 1, 2000),
			processed_ind = 3
		WHERE	quantity_interface_id = p_if_id;
	ELSIF p_proc_name = 'create_item' THEN
		UPDATE 	gmi_items_xml_interface
		SET	error_text = SUBSTRB(error_text || p_err_msg, 1, 2000),
			processed_ind = 3
		WHERE	item_interface_id = p_if_id;
	ELSIF p_proc_name = 'create_lot' THEN
		UPDATE 	gmi_lots_xml_interface
		SET	error_text = SUBSTRB(error_text || p_err_msg, 1, 2000),
			processed_ind = 3
		WHERE	lot_interface_id = p_if_id;
	ELSIF p_proc_name = 'create_lot_conv' THEN
		UPDATE 	gmi_lots_conv_xml_interface
		SET	error_text = SUBSTRB(error_text || p_err_msg, 1, 2000),
			processed_ind = 3
		WHERE	conv_interface_id = p_if_id;
	END IF;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		NULL;

END update_status;

-----------------------------------------------------------------------------------------

PROCEDURE confirm_api_selector ( item_type	IN	 VARCHAR2,
			 	item_key	IN	 VARCHAR2,
			 	actid	 	IN	 NUMBER,
			 	command	IN	 VARCHAR2,
			 	resultout	IN OUT NOCOPY VARCHAR2 ) IS

BEGIN

	IF( command = 'RUN' )
	THEN
        	resultout := 'CONFIRM_API';   --  process name

	ELSIF( command = 'SET_CTX' )
	THEN
		NULL;
	ELSIF( command = 'TEST_CTX' )
	THEN
		resultout := 'TRUE';

	END IF;

END confirm_api_selector;

-----------------------------------------------------------------------------------------

PROCEDURE send_outbound_document(	p_confirm_statuslvl IN VARCHAR2,
					p_confirm_descrtn IN VARCHAR2,
					p_confirm_det_descriptn IN VARCHAR2,
					p_confirm_det_reasoncode IN VARCHAR2,
					p_icn	IN NUMBER,
					p_event_key IN VARCHAR2)
IS

l_parameter_list 	wf_parameter_list_t := wf_parameter_list_t();
l_event_name		VARCHAR2(120);

BEGIN

   	wf_event.AddParameterToList(	p_name=>'ECX_TRANSACTION_TYPE',
					p_value=>'ECX',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'ECX_TRANSACTION_SUBTYPE',
					p_value=>'CBODO',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'DOCUMENT_ID',
					p_value=>p_icn,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'PARTY_TYPE',
					p_value=>'I',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'SEND_MODE',
					p_value=>'Immediate',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_STATUSLVL',
					p_value=>p_confirm_statuslvl,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DESCRTN',
					p_value=>p_confirm_descrtn,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DET_DESCRIPTN',
					p_value=>p_confirm_det_descriptn ,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DET_REASONCODE',
					p_value=>p_confirm_det_reasoncode,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'ECX_MSGID_ATTR',
					p_value=>'ECX_MESSAGE_ID',
					p_parameterlist=>l_parameter_list);

	l_event_name := 'oracle.apps.gmi.api.xml.confirm';

	wf_event.raise( p_event_name => l_event_name,
			p_event_key => p_event_key,
			p_parameters => l_parameter_list);

	l_parameter_list.DELETE;

END send_outbound_document;

----------------------------------------------------------------------------

PROCEDURE send_error_cbod ( 	item_type	IN	 VARCHAR2,
			 	item_key	IN	 VARCHAR2,
			 	actid	 	IN	 NUMBER,
			 	command		IN	 VARCHAR2,
			 	resultout	IN OUT NOCOPY VARCHAR2 ) IS

l_confirm_statuslvl  	VARCHAR2(240);
l_confirm_descrtn 	VARCHAR2(240);
l_confirm_det_descriptn VARCHAR2(240);
l_confirm_det_reasoncode VARCHAR2(240);
l_icn			NUMBER;
l_event_name		VARCHAR2(120);
l_event_key		VARCHAR2(240);
l_parameter_list 	wf_parameter_list_t := wf_parameter_list_t();

BEGIN

	l_confirm_statuslvl := wf_engine.GetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_STATUSLVL');

	l_confirm_descrtn := wf_engine.GetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DESCRTN');

	l_confirm_det_descriptn := wf_engine.GetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_DESCRIPTN');

	l_confirm_det_reasoncode := wf_engine.GetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_CONFIRM_DET_REASONCODE');

	l_event_key := wf_engine.GetItemAttrText(
			itemtype => item_type,
			itemkey  => item_key,
			aname    => 'ECX_EVENT_KEY');

	wf_event.AddParameterToList(	p_name=>'ECX_TRANSACTION_TYPE',
					p_value=>'ECX',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'ECX_TRANSACTION_SUBTYPE',
					p_value=>'CBODO',
					p_parameterlist=>l_parameter_list);

	l_icn 	:= wf_engine.GetItemAttrNumber(
					itemtype => item_type,
					itemkey  => item_key,
					aname    => 'PARAMETER7');

	wf_event.AddParameterToList(	p_name=>'DOCUMENT_ID',
					p_value=>l_icn,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'PARTY_TYPE',
					p_value=>'I',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'SEND_MODE',
					p_value=>'Immediate',
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_STATUSLVL',
					p_value=>l_confirm_statuslvl,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DESCRTN',
					p_value=>l_confirm_descrtn,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DET_DESCRIPTN',
					p_value=>l_confirm_det_descriptn,
					p_parameterlist=>l_parameter_list);

	wf_event.AddParameterToList(	p_name=>'CONFIRM_DET_REASONCODE',
					p_value=>l_confirm_det_reasoncode,
					p_parameterlist=>l_parameter_list);

	l_event_name := 'oracle.apps.gmi.api.xml.confirm';

	wf_event.raise( 	p_event_name => l_event_name,
				p_event_key => l_event_key,
				p_parameters => l_parameter_list);

	l_parameter_list.DELETE;

	resultout := 'COMPLETE:Y';

END send_error_cbod;


END Gmi_Apixml_Pkg;

/
