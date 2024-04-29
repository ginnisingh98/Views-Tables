--------------------------------------------------------
--  DDL for Package IEM_INTENT_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_INTENT_DOCS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvdocs.pls 115.3 2002/12/05 23:49:37 sboorela shipped $*/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure insert/delete a record in the table IEM_ACCOUNT_INTENT_DOCS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--		p_classification_id         IN NUMBER,
--			p_email_account_id            IN  NUMBER,
--			p_query_response               IN  VARCHAR2,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_classification_id         IN NUMBER,
			p_email_account_id            IN  NUMBER,
			p_query_response               IN  VARCHAR2,
			x_doc_seq_no		 OUT NOCOPY NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_ACCOUNT_INTENT_DOCS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_account_intent_doc_id	in number,

--	OUT
--   x_return_status	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_item (p_account_intent_doc_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2
			 );

END IEM_INTENT_DOCS_PVT;

 

/
