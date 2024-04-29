--------------------------------------------------------
--  DDL for Package PA_WF_FB_SAMPLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WF_FB_SAMPLE_PKG" 
/* $Header: PAXTMPFS.pls 120.2 2005/08/08 12:41:11 sbharath noship $ */
AUTHID CURRENT_USER AS
 PROCEDURE pa_wf_sample_sql_fn
	(	p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2);

 PROCEDURE pa_test_ap_inv_account ;

END pa_wf_fb_sample_pkg;

 

/
