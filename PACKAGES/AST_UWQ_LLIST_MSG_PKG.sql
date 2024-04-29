--------------------------------------------------------
--  DDL for Package AST_UWQ_LLIST_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_LLIST_MSG_PKG" AUTHID CURRENT_USER AS
/* $Header: astulmss.pls 115.3 2002/12/04 23:27:47 gkeshava noship $ */

--
--Purpose:  This package will be used for displaying messages within the lead list work panel
--Created by: Sekar Sundaram dated 5/16/02
--Last Updated by:  Joseph Raj dated 5/23/02
--Change Record: Joseph Raj 5/23/02..
--Modified sql for campaign/schedule description,
--error handling,obtaining work item data...

  procedure AST_UWQ_LLIST_MESSAGE
 ( p_resource_id        	IN  NUMBER,
   p_language           	IN  VARCHAR2 DEFAULT NULL,
   p_source_lang        	IN  VARCHAR2 DEFAULT NULL,
   p_action_key         	IN  VARCHAR2,
   p_action_input_data_list 	IN system.action_input_data_nst DEFAULT null,
   x_mesg_data_char 	 OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2);

  end AST_UWQ_LLIST_MSG_PKG;

 

/
