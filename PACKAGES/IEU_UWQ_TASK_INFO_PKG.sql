--------------------------------------------------------
--  DDL for Package IEU_UWQ_TASK_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_TASK_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: IEUTAINS.pls 120.0 2005/06/02 15:57:32 appldev noship $ */

--Purpose:  This package will be used for displaying information within the work panel
--Created by: Don-May Lee dated 12/9/02
-- changed data to header type..

 procedure ieu_uwq_task_notes (
        p_resource_id                IN  NUMBER,
 		p_language                   IN  VARCHAR2,
 		p_source_lang              	 IN  VARCHAR2,
 		p_action_key                 IN  VARCHAR2,
 		p_workitem_data_list   		 IN  SYSTEM.ACTION_INPUT_DATA_NST default null,
 		x_notes_data_list          	 OUT NOCOPY SYSTEM.app_info_header_nst,
 		x_msg_count                	 OUT NOCOPY NUMBER,
 		x_msg_data                   OUT NOCOPY VARCHAR2,
 		x_return_status              OUT NOCOPY VARCHAR2
 		);
END ieu_uwq_task_info_pkg;

 

/
