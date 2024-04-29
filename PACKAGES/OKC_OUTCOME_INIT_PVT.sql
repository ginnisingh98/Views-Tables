--------------------------------------------------------
--  DDL for Package OKC_OUTCOME_INIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OUTCOME_INIT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCROCES.pls 120.1 2005/12/14 22:03:16 npalepu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_WORKFLOW_ACTIVE		CONSTANT VARCHAR2(200) := 'OKC_WORKFLOW_ACTIVE';
  G_WF_NAME_TOKEN CONSTANT   	VARCHAR2(200) 		:= 'WF_ITEM';
  G_WF_P_NAME_TOKEN CONSTANT   	VARCHAR2(200) 		:= 'WF_PROCESS';
  G_PROCESS_NOTFOUND CONSTANT   VARCHAR2(200) 		:= 'OKC_PROCESS_NOT_FOUND';
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_LEVEL			CONSTANT VARCHAR2(4)   := '_PVT';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OUTCOME_INIT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  --Global exception
  G_EXCEPTION			EXCEPTION;

  -- subtype definitions
	subtype msg_rec_typ is okc_aq_pvt.msg_rec_typ;
	subtype msg_tab_typ is okc_aq_pvt.msg_tab_typ;
	subtype corrid_rec_typ is okc_aq_pvt.corrid_rec_typ;

	--Declare a record tupe
	TYPE p_outcomerec_type IS RECORD(
	name		okc_process_def_parameters_v.name%TYPE,
	data_type	okc_process_def_parameters_v.data_type%TYPE,
	value		okc_process_def_parameters_v.default_value%TYPE);
	TYPE p_outcometbl_type IS TABLE OF p_outcomerec_type
	INDEX BY BINARY_INTEGER;

   -- Fire an outcome for a condition occurrence
   PROCEDURE Launch_outcome(p_api_version 	IN NUMBER,
			   p_init_msg_list IN VARCHAR2  DEFAULT FND_API.G_FALSE,
			   p_corrid_rec   	IN corrid_rec_typ,
			   p_msg_tab_typ      	IN msg_tab_typ,
			   x_msg_count    	OUT NOCOPY NUMBER,
			   x_msg_data         	OUT NOCOPY VARCHAR2,
			   x_return_status      OUT NOCOPY VARCHAR2);

  --Execute a plsql procedure
  PROCEDURE Launch_plsql(p_api_version 	 IN NUMBER,
			 p_init_msg_list IN VARCHAR2  DEFAULT FND_API.G_FALSE,
			 p_outcome_name	 IN VARCHAR2,
			 p_outcome_tbl   IN p_outcometbl_type,
			 x_proc       	 OUT NOCOPY VARCHAR2,
                         --NPALEPU
                         --14-DEC-2005
                         --Added new parameter X_PROC_NAME for bug # 4699009.
                         x_proc_name     OUT NOCOPY VARCHAR2,
                         --END NPALEPU
			 x_msg_count     OUT NOCOPY NUMBER,
			 x_msg_data      OUT NOCOPY VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2);

  --Launch a workflow
  PROCEDURE Launch_workflow(p_api_version   IN NUMBER,
			    p_init_msg_list IN VARCHAR2  DEFAULT FND_API.G_FALSE,
			    p_outcome_name  IN VARCHAR2,
			    p_outcome_tbl   IN p_outcometbl_type,
			    x_proc     	    OUT NOCOPY VARCHAR2,
                            --NPALEPU
                            --14-DEC-2005
                            --Added new parameter X_PROC_NAME for bug # 4699009.
                            x_proc_name     OUT NOCOPY VARCHAR2,
                            --END NPALEPU
			    x_msg_count     OUT NOCOPY NUMBER,
			    x_msg_data      OUT NOCOPY VARCHAR2,
			    x_return_status OUT NOCOPY VARCHAR2);
End okc_outcome_init_pvt;

 

/
