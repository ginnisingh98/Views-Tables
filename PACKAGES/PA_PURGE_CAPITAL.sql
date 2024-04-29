--------------------------------------------------------
--  DDL for Package PA_PURGE_CAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_CAPITAL" AUTHID CURRENT_USER AS
/* $Header: PAXGCPPS.pls 120.1 2005/08/09 04:16:50 avajain noship $ */

PROCEDURE PA_Capital_Main_Purge (p_purge_batch_id	in NUMBER,
				 p_project_id		in NUMBER,
				 p_purge_release	in VARCHAR2,
				 p_txn_to_date		in DATE,
				 p_archive_flag		in VARCHAR2,
				 p_commit_size		in NUMBER,
				 p_err_stack		in OUT NOCOPY VARCHAR2,
				 p_err_stage		in OUT NOCOPY VARCHAR2,
				 p_err_code		in OUT NOCOPY VARCHAR2);

PROCEDURE PA_MC_AsstLinDtls (p_purge_batch_id	IN NUMBER,
	                     p_project_id       IN NUMBER,
			     p_txn_to_date	IN DATE,
			     p_purge_release	IN VARCHAR2,
			     p_archive_flag	IN VARCHAR2,
			     p_commit_size	IN NUMBER,
			     p_err_code		IN OUT NOCOPY NUMBER,
			     p_err_stack        IN OUT NOCOPY VARCHAR2,
			     p_err_stage	IN OUT NOCOPY VARCHAR2);

PROCEDURE PA_AsstLineDtls (p_purge_batch_id	IN NUMBER,
	                   p_project_id		IN NUMBER,
			   p_txn_to_date	IN DATE,
			   p_purge_release	IN VARCHAR2,
			   p_archive_flag	IN VARCHAR2,
			   p_commit_size	IN NUMBER,
			   p_err_code		IN OUT NOCOPY NUMBER,
			   p_err_stack		IN OUT NOCOPY VARCHAR2,
			   p_err_stage		IN OUT NOCOPY VARCHAR2);


END PA_Purge_Capital;
 

/
