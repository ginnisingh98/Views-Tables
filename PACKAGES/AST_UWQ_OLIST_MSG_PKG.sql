--------------------------------------------------------
--  DDL for Package AST_UWQ_OLIST_MSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_OLIST_MSG_PKG" AUTHID CURRENT_USER AS
/* $Header: astuomss.pls 115.1 2002/12/04 22:50:29 gkeshava noship $ */

--
--Purpose:  This package will be used for displaying messages within the opportunity list work panel
--Created by:  Joseph Raj dated 10/10/02

--Last Updated by:  Joseph Raj dated 10/10/02

  procedure AST_UWQ_OLIST_MESSAGE
 ( p_resource_id        	IN  NUMBER,
   p_language           	IN  VARCHAR2 DEFAULT NULL,
   p_source_lang        	IN  VARCHAR2 DEFAULT NULL,
   p_action_key         	IN  VARCHAR2,
   p_action_input_data_list 	IN system.action_input_data_nst DEFAULT null,
   x_mesg_data_char 	 OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2);

  end AST_UWQ_OLIST_MSG_PKG;

 

/
