--------------------------------------------------------
--  DDL for Package CN_REASONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REASONS_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvresns.pls 115.1 2002/11/21 21:16:51 hlchen ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_REASON_PVT
-- Purpose
--   Package specifications for Analyst Notes (JSP). This package is built
--   on top of the table handler.
-- History
--   04/02/02   Rao.Chenna         Created
/*--------------------------------------------------------------------------
  API name	: insert_row
  Type		: Private
  Pre-reqs	:
  Usage		: This is the main procedure that gets the data populate the
                  Analyst Notes JSP.
  Desc 		:
  Parameters
  IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_reasons_all_rec 	 IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,

  OUT NOCOPY 		: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2

  Notes	        : This procedure calls the table handler to create a record in the
                  cn_reasons table. reason_id is the primary key in the table and the
                  value is derived from sequence number in this procedure. It also
                  validates for the NOT NULL columns.
--------------------------------------------------------------------------*/
PROCEDURE insert_row(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reasons_all_rec 	IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);

/*--------------------------------------------------------------------------
  API name	: update_row
  Type		: Private
  Pre-reqs	:
  Usage		: This is the main procedure that gets the data populate the
                  Analyst Notes JSP.
  Desc 		:
  Parameters
  IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_reasons_all_rec 	 IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,

  OUT NOCOPY 		: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2

  Notes	        : This procedure calls the update table handler to update
                  the exsiting data. While updating, it will keep the
		  original data in cn_reason_history table. It also does
		  the validation for NOT NULL columns.
--------------------------------------------------------------------------*/

PROCEDURE update_row(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reasons_all_rec 	IN 	CN_REASONS_PKG.REASONS_ALL_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
/*--------------------------------------------------------------------------
  API name	: delete_notes
  Type		: Private
  Pre-reqs	:
  Usage		: This is the main procedure to delete the analyst notes
                  corresponding to the checkboxes selected from the JSP.
  Desc 		:
  Parameters
  IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_reason_id		 IN	NUMBER	 := FND_API.G_MISS_NUM,

  OUT NOCOPY 		: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2

  Notes	        : This procedure deletes the record from cn_reasons table
                  and create a new record with the same data in
		  cn_reason_history table.
--------------------------------------------------------------------------*/
PROCEDURE delete_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_reason_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
/*--------------------------------------------------------------------------
  API name	: delete_worksheet_notes
  Type		: Private
  Pre-reqs	:
  Usage		: This is the main procedure to delete all the analyst notes
                  corresponding to a worksheet.
  Desc 		:
  Parameters
  IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_payment_worksheet_id IN	NUMBER	 := FND_API.G_MISS_NUM,

  OUT NOCOPY 		: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2

  Notes	        : Apart from deleting the records from cn_reasons table, it
                  also deletes the records in the cn_reason_history table.
--------------------------------------------------------------------------*/
PROCEDURE delete_worksheet_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
END; -- Package spec

 

/
