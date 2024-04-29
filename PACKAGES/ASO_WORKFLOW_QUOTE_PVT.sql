--------------------------------------------------------
--  DDL for Package ASO_WORKFLOW_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_WORKFLOW_QUOTE_PVT" AUTHID CURRENT_USER AS
/* $Header: asovwfqs.pls 120.1 2005/06/29 12:46:09 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_WORKFLOW_QUOTE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



PROCEDURE NotifyForASOContractChange(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2  := FND_API.G_FALSE,
  p_quote_id          IN  NUMBER,
  p_contract_id       IN  NUMBER,
  p_notification_type IN  VARCHAR2,
  p_customer_comments IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

PROCEDURE ParseThisString (
	p_string_in		  IN	VARCHAR2,
	p_string_out	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	p_string_left	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
	);

FUNCTION AddSpaces (
	p_num_in			IN	NUMBER
) RETURN VARCHAR2;


PROCEDURE GenerateQuoteHeader(
	document_id		  IN		    VARCHAR2,
	display_type		IN		    VARCHAR2,
	document		    IN  OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2
	);

PROCEDURE GenerateQuoteDetail(
	document_id		  IN		    VARCHAR2,
	display_type		IN		    VARCHAR2,
	document		    IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2
	);

PROCEDURE GenerateQuoteFooter(
	document_id		  IN		    VARCHAR2,
	display_type		IN		    VARCHAR2,
	document		    IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2
	);

PROCEDURE GetContractRef(
	document_id		  IN		    VARCHAR2,
	display_type		IN		    VARCHAR2,
	document		    IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2
	);

PROCEDURE GetCartName(
	document_id		  IN		    VARCHAR2,
	display_type		IN		    VARCHAR2,
	document		    IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type	 IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2
	);


END ASO_WORKFLOW_QUOTE_PVT;

 

/
