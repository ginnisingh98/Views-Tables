--------------------------------------------------------
--  DDL for Package GMI_WF_ITEM_ACTIVATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_WF_ITEM_ACTIVATION" AUTHID CURRENT_USER as
/* $Header: gmiitmws.pls 115.0 2003/01/10 19:56:15 jdiiorio noship $ */

	procedure init_wf
	(
		p_item_id in number,
		p_item_no in varchar2,
		p_item_um in varchar2,
		p_item_desc1 in varchar2,
		p_created_by in varchar2
	);

	procedure select_approver
	(
		p_itemtype in varchar2,
		p_itemkey in varchar2,
		p_actid in number,
		p_funcmode in varchar2,
		p_result out nocopy varchar2
	);

	procedure activate_item
	(
		p_itemtype in varchar2,
		p_itemkey in varchar2,
		p_actid in number,
		p_funcmode in varchar2,
		p_result out nocopy varchar2
	);


end gmi_wf_item_activation;

 

/
