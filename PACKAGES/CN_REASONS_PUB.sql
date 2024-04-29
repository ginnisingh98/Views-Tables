--------------------------------------------------------
--  DDL for Package CN_REASONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REASONS_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpresns.pls 115.2 2003/07/04 01:35:20 jjhuang ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_REASON_PUB
-- Purpose
--   Package specifications for Analyst Notes JSP. The following flow diagram
--   shows how Analyst Notes JSP interacts with all the APIs.
--                   |-------------|   |------------|   |-------------|
-- |-------------|   |Rosetta      |   |cn_reasons_ |   |cn_reasons_  |
-- |cnreason.jsp |-->|Wrapper      |-->|pub         |-->|pvt          |---|
-- |-------------|   |CnReasonsPub |   |cnpresns.pls|   |cnvresns.pls |   |
--                   |-------------|   |------------|   |-------------|   |
--                                                      |-------------|   |
--                                                      |cn_reasons_  |   |
--                                                      |pkg          |<--|
--                                                      |cntresns.pls |
--                                                      |-------------|
-- History
--   04/02/02   Rao.Chenna         Created
--   06/16/03   Julia Huang        Added show_last_analyst_note for 11.5.10
   TYPE worksheet_rec IS RECORD(
      payment_worksheet_id	number		:= fnd_api.g_miss_num,
      role_id			number		:= fnd_api.g_miss_num,
      worksheet_status		varchar2(30)	:= fnd_api.g_miss_char,
      payrun_name		varchar2(80)	:= fnd_api.g_miss_char,
      payrun_id			number		:= fnd_api.g_miss_num,
      pay_period_id		number		:= fnd_api.g_miss_num,
      payrun_status		varchar2(80)	:= fnd_api.g_miss_char,
      period_name		varchar2(30)	:= fnd_api.g_miss_char,
      salesrep_id		number		:= fnd_api.g_miss_num,
      resource_id		number		:= fnd_api.g_miss_num,
      salesrep_name		varchar2(360)	:= fnd_api.g_miss_char,
      employee_number		varchar2(30)	:= fnd_api.g_miss_char,
      pay_group_id		number		:= fnd_api.g_miss_num,
      pay_group_name		varchar2(80)	:= fnd_api.g_miss_char);
   --
   TYPE notes_rec IS RECORD(
      reason_history_id		number		:= fnd_api.g_miss_num,
      reason_id			number		:= fnd_api.g_miss_num,
      updated_table		varchar2(30)	:= fnd_api.g_miss_char,
      upd_table_id		number		:= fnd_api.g_miss_num,
      reason			varchar2(4000)	:= fnd_api.g_miss_char,
      reason_code		varchar2(30)	:= fnd_api.g_miss_char,
      reason_meaning		varchar2(80)	:= fnd_api.g_miss_char,
      lookup_type		varchar2(30)	:= fnd_api.g_miss_char,
      update_flag		varchar2(30)	:= fnd_api.g_miss_char,
      dml_flag			varchar2(30)	:= fnd_api.g_miss_char,
      attribute_category	varchar2(30)	:= fnd_api.g_miss_char,
      attribute1		varchar2(30)	:= fnd_api.g_miss_char,
      attribute2		varchar2(30)	:= fnd_api.g_miss_char,
      attribute3		varchar2(30)	:= fnd_api.g_miss_char,
      attribute4		varchar2(30)	:= fnd_api.g_miss_char,
      attribute5		varchar2(30)	:= fnd_api.g_miss_char,
      attribute6		varchar2(30)	:= fnd_api.g_miss_char,
      attribute7		varchar2(30)	:= fnd_api.g_miss_char,
      attribute8		varchar2(30)	:= fnd_api.g_miss_char,
      attribute9		varchar2(30)	:= fnd_api.g_miss_char,
      attribute10		varchar2(30)	:= fnd_api.g_miss_char,
      attribute11		varchar2(30)	:= fnd_api.g_miss_char,
      attribute12		varchar2(30)	:= fnd_api.g_miss_char,
      attribute13		varchar2(30)	:= fnd_api.g_miss_char,
      attribute14		varchar2(30)	:= fnd_api.g_miss_char,
      attribute15		varchar2(30)	:= fnd_api.g_miss_char,
      last_update_date     	date		:= fnd_api.g_miss_date,
      last_updated_by      	number		:= fnd_api.g_miss_num,
      last_updated_username    	varchar2(100)	:= fnd_api.g_miss_char,
      object_version_number	number		:= fnd_api.g_miss_num);
   --
   TYPE notes_tbl IS
     TABLE OF notes_rec INDEX BY BINARY_INTEGER ;
   --
   /*--------------------------------------------------------------------------
     API name	: show_analyst_notes
     Type	: Public
     Pre-reqs	:
     Usage	: This is the main procedure that gets the data populate the
                  Analyst Notes JSP.
     Desc 	:
     Parameters
     IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_first		 IN    	NUMBER,
   		  p_last                 IN     NUMBER,
		  p_payment_worksheet_id IN	NUMBER,
	 	  p_table_name		 IN	VARCHAR2,
		  p_lookup_type		 IN	VARCHAR2,

     OUT NOCOPY 	: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2,
		  x_worksheet_rec	 OUT NOCOPY cn_reasons_pub.worksheet_rec,
   		  x_notes_tbl     	 OUT NOCOPY    cn_reasons_pub.notes_tbl,
   		  x_notes_count   	 OUT NOCOPY    NUMBER

     Notes	: This JSP has two sections. One is Worksheet
		  information and second is showing the notes corresponding to
		  the Worksheet. x_worksheet_rec populate the first section and
		  x_notes_tbl populates the second section
   --------------------------------------------------------------------------*/
   PROCEDURE show_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_first			IN    	NUMBER,
   	p_last                  IN      NUMBER,
	p_payment_worksheet_id	IN	NUMBER,
	p_table_name		IN	VARCHAR2,
	p_lookup_type		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_worksheet_rec	 OUT NOCOPY cn_reasons_pub.worksheet_rec,
   	x_notes_tbl      OUT NOCOPY     cn_reasons_pub.notes_tbl,
   	x_notes_count    OUT NOCOPY     NUMBER);
   /*--------------------------------------------------------------------------
     API name	: manage_analyst_notes
     Type	: Public
     Pre-reqs	:
     Usage	: This procedure is used to insert or update an analyst notes.
     Desc 	:
     Parameters
     IN		: p_api_version     	IN	NUMBER,
   		  p_init_msg_list       IN      VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level    IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_notes_tbl     	IN      cn_reasons_pub.notes_tbl

     OUT NOCOPY 	: x_return_status       OUT NOCOPY     VARCHAR2,
   		  x_msg_count           OUT NOCOPY     NUMBER,
   		  x_msg_data            OUT NOCOPY     VARCHAR2,
   		  x_loading_status      OUT NOCOPY     VARCHAR2);
     Notes	: From the JSP data comes through p_notes_tbl PL/SQL table. Based
                  on the dml_flag either the record is inserted into the cn_reasons
		  table or updated. When the record is updated, original content
		  will be copied to cn_reason_history table.
   --------------------------------------------------------------------------*/
   PROCEDURE manage_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_notes_tbl     	IN      cn_reasons_pub.notes_tbl,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
    /*--------------------------------------------------------------------------
     API name	: remove_analyst_notes
     Type	: Public
     Pre-reqs	:
     Usage	: This procedure is used to remove the record from cn_reasons table
     Desc 	:
     Parameters
     IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_payment_worksheet_id IN	NUMBER	 := FND_API.G_MISS_NUM,
		  p_reason_id		 IN	NUMBER	 := FND_API.G_MISS_NUM,
     OUT NOCOPY 	: x_return_status        OUT NOCOPY    VARCHAR2,
   		  x_msg_count            OUT NOCOPY    NUMBER,
   		  x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE remove_analyst_notes(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_reason_id		IN	NUMBER		:= FND_API.G_MISS_NUM,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   --

   /*--------------------------------------------------------------------------
     API name	: show_last_analyst_note
     Type	: Public
     Pre-reqs	:
     Usage	: This is the main procedure that gets the data populate the
                  Analyst Notes JSP.
     Desc 	:
     Parameters
     IN		: p_api_version     	 IN	NUMBER,
   		  p_init_msg_list        IN     VARCHAR2 := FND_API.G_TRUE,
   		  p_validation_level     IN     VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
		  p_commit	    	 IN  	VARCHAR2 := CN_API.G_FALSE,
		  p_first		 IN    	NUMBER,
   		  p_last                 IN     NUMBER,
		  p_payment_worksheet_id IN	NUMBER,
	 	  p_table_name		 IN	VARCHAR2,
		  p_lookup_type		 IN	VARCHAR2,

     OUT NOCOPY 	: x_return_status        OUT NOCOPY    VARCHAR2,
   	          x_msg_count            OUT NOCOPY    NUMBER,
   	          x_msg_data             OUT NOCOPY    VARCHAR2,
   		  x_loading_status       OUT NOCOPY    VARCHAR2,
		  x_worksheet_rec	 OUT NOCOPY cn_reasons_pub.worksheet_rec,
   		  x_notes_tbl     	 OUT NOCOPY    cn_reasons_pub.notes_tbl,
   		  x_notes_count   	 OUT NOCOPY    NUMBER

     Notes	: This JSP has two sections. One is Worksheet
		  information and second is showing the notes corresponding to
		  the Worksheet. x_worksheet_rec populate the first section and
		  x_notes_tbl populates the second section
          11.5.10 by Julia Huang
   --------------------------------------------------------------------------*/
   PROCEDURE show_last_analyst_note(
   	p_api_version     	IN	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_commit	    	IN  	VARCHAR2 	:= CN_API.G_FALSE,
	p_payment_worksheet_id	IN	NUMBER,
	p_table_name		IN	VARCHAR2,
	p_lookup_type		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
   	x_notes_tbl      OUT NOCOPY     cn_reasons_pub.notes_tbl,
   	x_notes_count    OUT NOCOPY     NUMBER);
END; -- Package spec

 

/
