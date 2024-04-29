--------------------------------------------------------
--  DDL for Package IEM_AMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_AMV_PVT" AUTHID CURRENT_USER as
/* $Header: iemvamvs.pls 120.0 2005/06/02 14:01:09 appldev noship $*/
TYPE category_type IS RECORD (
          category_id   amv_c_categories_vl.channel_category_id%type,
          category_name amv_c_categories_vl.channel_category_name%type);

TYPE category_tbl IS TABLE OF category_type
           INDEX BY BINARY_INTEGER;

PROCEDURE get_categories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2:=NULL,
		    	      p_commit	    IN   VARCHAR2:=NULL,
			      x_category_tbl out nocopy category_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);

PROCEDURE get_sub_categories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_category_id	IN	NUMBER,
			      p_index		IN	NUMBER,
			      p_string		IN	VARCHAR2,
			      x_index		OUT	NOCOPY NUMBER,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2);



end IEM_AMV_PVT;

 

/
