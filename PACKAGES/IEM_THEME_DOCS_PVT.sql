--------------------------------------------------------
--  DDL for Package IEM_THEME_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_THEME_DOCS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvthds.pls 115.3 2002/12/06 00:06:46 sboorela shipped $*/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure insert/delete a record in the table IEM_ACCOUNT_INTENT_DOCS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--		p_account_intent_doc_id         IN NUMBER,
--			p_theme_id            IN  NUMBER,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_account_intent_doc_id         IN NUMBER,
			p_theme_id            IN  NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2
			 );

END IEM_THEME_DOCS_PVT;

 

/
