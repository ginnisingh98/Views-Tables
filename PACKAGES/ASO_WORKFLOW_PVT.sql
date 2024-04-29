--------------------------------------------------------
--  DDL for Package ASO_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: asovwfts.pls 120.1 2005/06/29 12:46:16 appldev ship $ */
-- Package name     : ASO_WORKFLOW_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE NotifyOrderStatus(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_status 		IN	VARCHAR2,
	p_errmsg_count		IN	NUMBER,
	p_errmsg_data		IN	VARCHAR2,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
	);

PROCEDURE GenerateQuoteHeader(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document		IN 	OUT NOCOPY VARCHAR2,
	document_type		IN	OUT NOCOPY VARCHAR2
	);

PROCEDURE Selector (
	itemtype		IN	VARCHAR2,
	itemkey			IN	VARCHAR2,
	actid			IN 	NUMBER,
	funcmode		IN	VARCHAR2,
	result		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
	);

END aso_workflow_pvt;

 

/
