--------------------------------------------------------
--  DDL for Package CSTPGLXF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPGLXF" AUTHID CURRENT_USER AS
/* $Header: CSTGLXFS.pls 115.3 2002/11/08 20:34:36 awwang ship $ */

PROCEDURE  cst_gl_transfer (
			   p_errbuf                      OUT NOCOPY  VARCHAR2,
			   p_retcode                     OUT NOCOPY  NUMBER,
			   p_application_id                   NUMBER,
			   p_user_id                          NUMBER,
			   p_legal_entity		      NUMBER,
			   p_cost_type_id		      NUMBER,
			   p_cost_group_id		      NUMBER,
			   p_period_id			      NUMBER,
			   p_batch_name                       VARCHAR2,
			   p_gl_transfer_mode                 VARCHAR2,
			   p_submit_journal_import            VARCHAR2,
			   p_debug_flag                       VARCHAR2
			   );
END CSTPGLXF;

 

/
