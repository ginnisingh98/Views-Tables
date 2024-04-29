--------------------------------------------------------
--  DDL for Package BOM_ROUTINGINTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ROUTINGINTERFACE_PUB" AUTHID CURRENT_USER AS
/* $Header: BOMPRTGS.pls 120.1 2005/06/21 12:12:02 rfarook noship $ */

-- Start of comments
--	API name 	: ImportRouting
--	Type		: Public.
--	Function	: Imports routings from open interface tables
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER	 	Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_organization_id  	NUMBER		Required
--	  p_commit_rows  	NUMBER		Optional  Default = 500
--	  p_delete_rows  	VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_all_organizations  	VARCHAR2	Optional
--	    Default = FND_API.G_TRUE
--
--	OUT		:
--	  x_return_status	OUT	VARCHAR2(1)
--	  x_msg_count		OUT	NUMBER
--	  x_msg_data		OUT	VARCHAR2(2000)
--
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		:
--	  When p_commit = true, commits will be issued after every
--	  p_commit_rows are transacted.
--
--	  When p_delete_rows = true, successfully processed interface table
--	  rows will be deleted.  Rows with errors will still remain
--
--	  When p_all_organizations = false, only interface table rows for the
--	  specified organization id will be processed.
--
-- End of comments

-- Constants
G_Insert constant varchar2(10) := 'INSERT'; -- transaction type
G_Update constant varchar2(10) := 'UPDATE'; -- transaction type
G_Delete constant varchar2(10) := 'DELETE'; -- transaction type
G_NullChar constant varchar2(10) := 'empty'; -- null value
G_NullNum constant number := -999999; -- null value
G_NullDate constant date :=
  to_date('1900/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'); -- null value
G_RtgDelEntity constant varchar2(30) := 'BOM_OP_ROUTINGS_INTERFACE';
G_OprDelEntity constant varchar2(30) := 'BOM_OP_SEQUENCES_INTERFACE';

PROCEDURE ImportRouting(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2	:= FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 	:= FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER		:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_organization_id  	IN	NUMBER,
  p_all_organizations  	IN	VARCHAR2 	:= FND_API.G_TRUE,
  p_commit_rows	    	IN  	NUMBER 		:= 500,
  p_delete_rows	    	IN  	VARCHAR2 	:= FND_API.G_FALSE
);

END BOM_RoutingInterface_PUB;

 

/
