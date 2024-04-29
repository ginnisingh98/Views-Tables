--------------------------------------------------------
--  DDL for Package INV_RSV_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RSV_SYNCH" AUTHID CURRENT_USER AS
/* $Header: INVRSV7S.pls 120.1 2005/06/17 18:04:29 appldev  $ */

procedure for_insert (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 );

procedure for_update (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 );

procedure for_delete (
  p_reservation_id		IN	NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 );

procedure for_relieve (
  p_reservation_id		IN	NUMBER
, p_primary_relieved_quantity   IN      NUMBER
, x_return_status	        OUT NOCOPY	VARCHAR2
, x_msg_count	        	OUT NOCOPY	NUMBER
, x_msg_data     	        OUT NOCOPY	VARCHAR2 );

end INV_RSV_SYNCH;

 

/
