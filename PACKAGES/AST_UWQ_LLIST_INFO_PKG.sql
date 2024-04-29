--------------------------------------------------------
--  DDL for Package AST_UWQ_LLIST_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_LLIST_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: astulins.pls 115.4 2002/12/04 23:23:40 gkeshava noship $ */

--Purpose:  This package will be used for displaying information within
--          the lead list node of work panel
--Created by: Sekar Sundaram dated 5/16/02
--Last Updated by:  Joseph Raj dated 5/23/02
--Derived from astnotes.pls

  procedure ast_uwq_llist_notes (
          p_resource_id               IN  NUMBER,
 		p_language                   IN  VARCHAR2,
 		p_source_lang              IN  VARCHAR2,
 		p_action_key                IN  VARCHAR2,
 		p_workitem_data_list   IN  SYSTEM.ACTION_INPUT_DATA_NST default null,
 		x_notes_data_list          OUT NOCOPY SYSTEM.app_info_header_nst,
 		x_msg_count                OUT NOCOPY NUMBER,
 		x_msg_data                  OUT NOCOPY VARCHAR2,
 		x_return_status             OUT NOCOPY VARCHAR2
 		);
  end ast_uwq_llist_info_pkg;

 

/
