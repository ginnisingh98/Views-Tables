--------------------------------------------------------
--  DDL for Package WIP_SUBS_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_SUBS_MERGE" AUTHID CURRENT_USER as
/* $Header: wipsbcps.pls 115.6 2002/11/29 15:34:28 rmahidha ship $ */

	function Cmp_Merge_Subs(
			interface_id in number,
			organization_id in number,
			err_num in out nocopy number,
			err_mesg in out nocopy varchar2
			  ) return number;

	function Post_SubMerge(
			p_interface_id in number,
                        p_org_id in number,
                        p_src_prj_id in number,
                        p_src_tsk_id in number,
                        p_wip_entity_id in number,
                        p_transaction_date in varchar2,
                        p_txn_hdr_id in number,
                        p_err_num in out nocopy number,
                        p_err_mesg in out nocopy varchar2
			) return number;

end Wip_Subs_Merge;

 

/
