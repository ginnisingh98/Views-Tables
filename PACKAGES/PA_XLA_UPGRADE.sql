--------------------------------------------------------
--  DDL for Package PA_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_XLA_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: PACOXLUS.pls 120.6 2006/08/04 19:35:50 vthakkar noship $ */

PROCEDURE UPGRADE_COST_XCHARGE
		      ( p_table_owner	IN VARCHAR2,
		        p_script_name	IN VARCHAR2,
			p_worker_id	IN NUMBER,
			p_num_workers	IN NUMBER,
			p_batch_size	IN NUMBER,
			p_min_eiid	IN NUMBER,
			p_max_eiid	IN NUMBER,
			p_upg_batch_id	IN NUMBER,
			p_mode		IN VARCHAR2,
			p_cost_cross	IN VARCHAR2);

PROCEDURE UPGRADE_MC_COST_XCHARGE
		      ( p_table_owner	IN VARCHAR2,
		        p_script_name	IN VARCHAR2,
			p_worker_id	IN NUMBER,
			p_num_workers	IN NUMBER,
			p_batch_size	IN NUMBER,
			p_min_eiid	IN NUMBER,
			p_max_eiid	IN NUMBER,
			p_upg_batch_id	IN NUMBER,
			p_mode		IN VARCHAR2,
			p_cost_cross	IN VARCHAR2);

PROCEDURE POPULATE_CTRL_TABLE(p_batch_id	IN  NUMBER,
			      x_mrc_enabled	OUT NOCOPY VARCHAR2);

END PA_XLA_UPGRADE;

 

/
