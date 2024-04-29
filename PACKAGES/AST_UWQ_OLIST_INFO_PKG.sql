--------------------------------------------------------
--  DDL for Package AST_UWQ_OLIST_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_OLIST_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: astuoins.pls 115.1 2002/12/04 22:57:15 gkeshava noship $ */

--Purpose:  This package will be used for displaying information within
--          the opportunity list node of work panel
--Created by: Joseph Raj dated 10/10/02
--Last Updated by:  Joseph Raj dated 10/10/02
--Derived from astnotes.pls

  procedure ast_uwq_olist_notes (
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
  end ast_uwq_olist_info_pkg;

 

/
