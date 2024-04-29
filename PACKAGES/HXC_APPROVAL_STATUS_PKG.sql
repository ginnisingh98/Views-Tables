--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcapvst.pkh 120.1 2007/01/05 11:44:24 gkrishna noship $ */
--
-- procedure
--   update_status
--
-- description
--   Wrapper procedure the updates the status of an APPLICATION PERIOD
--   building block. Performs a validation to check if the correct
--   Time Building Block is being updated. Calls the Workflow to transisition
--   to HXC_APP_SET_PERIODS node.
-- parameters
--	      p_approvals     -PL/SQL Type holding item_type,key,aprv_comments.
--            p_aprv_status   - new status of approval form row
--
PROCEDURE update_status
            (p_approvals   in APPROVAL_REC_TABLE_TYPE,
	     p_aprv_status in VARCHAR2);
end hxc_approval_status_pkg;

/
