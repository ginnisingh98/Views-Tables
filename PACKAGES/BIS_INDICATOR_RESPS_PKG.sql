--------------------------------------------------------
--  DDL for Package BIS_INDICATOR_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_INDICATOR_RESPS_PKG" AUTHID CURRENT_USER AS
/* $Header: BISINRSS.pls 115.5 2002/12/16 10:22:26 rchandra noship $ */


PROCEDURE Load_Row
( p_target_level_short_name     IN      VARCHAR
, p_responsibility_short_name   IN      VARCHAR
, p_created_by                  IN      NUMBER
, p_last_updated_by             IN      NUMBER
, p_owner			IN 	VARCHAR
, x_return_status		OUT NOCOPY 	VARCHAR
, x_return_msg			OUT NOCOPY  	VARCHAR
);



  PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY  varchar2
      ,x_indicator_resp_id   		in out NOCOPY  number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  );

  PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
      ,x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  );

  PROCEDURE Update_Row(
      x_rowid    				in      varchar2
      ,x_indicator_resp_id   		in      number
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
  );

  PROCEDURE Delete_Row(
      x_rowid    				in      varchar2
  );

  PROCEDURE Check_Unique(
      x_rowid    				in      varchar2
      ,x_target_level_id		in	  number
      ,x_responsibility_id		in	  number
  );

END BIS_INDICATOR_RESPS_PKG;

 

/
