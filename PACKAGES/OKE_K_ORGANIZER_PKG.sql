--------------------------------------------------------
--  DDL for Package OKE_K_ORGANIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_ORGANIZER_PKG" AUTHID CURRENT_USER as
/* $Header: OKEKORGS.pls 115.8 2002/11/20 17:19:21 syho ship $ */

RECORD_COUNT	NUMBER := to_number(FND_PROFILE.VALUE('OKE_K_FIFO_LOG'));

--
-- Procedure: populate_query_node
--
-- Purpose: return the tree node data based on the passed in where clause
--
-- Parameters:
--        (IN) x_user_valuse		varchar2			passed in where clause
--             x_icon			varchar2			tree node icon
--	       x_tree_object		varchar2			tree name
--	       x_node_state		number				tree node state
--	       x_low_value		number				low range associated w/current node
--	       x_high_value		number				high range associated w/current node
--
--	 (OUT) x_tree_data_table	fnd_apptree.node_tbl_type	store return tree node data
--	       x_return_status		varchar2			status
--


PROCEDURE populate_query_node(x_user_value		IN 		varchar2,
			      x_icon			IN		varchar2,
			      x_tree_object		IN		varchar2,
			      x_node_state		IN		number,
			      x_low_value		IN     		number,
			      x_high_value		IN		number,
			      x_tree_data_table		OUT	NOCOPY	fnd_apptree.node_tbl_type,
			      x_return_status   	OUT	NOCOPY	varchar2);


--
-- Procedure: fifo_log
--
-- Purpose: update the contract documents log for user
--
-- Parameters:
--        (IN) x_user_id		number			user id
--             x_k_header_id		number			contract document id
--	       x_object_name		varchar2		tree object name
--


PROCEDURE fifo_log(x_user_id	   number,
  		   x_k_header_id   number,
  		   x_object_name   varchar2);

--
-- Procedure: get_party_name
--
-- Purpose: get the customer/contractor name for the contract document
--
-- Parameters:
--        (IN) x_role			varchar2		party role
--             x_k_header_id		number			contract document id
--
--	 (OUT) x_party_name		varchar2		party name
--


PROCEDURE get_party_name(x_role	        IN 		varchar2  ,
  		         x_k_header_id  IN 		number    ,
  		         x_party_name   OUT NOCOPY	varchar2  );


end OKE_K_ORGANIZER_PKG;

 

/
