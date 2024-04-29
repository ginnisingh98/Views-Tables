--------------------------------------------------------
--  DDL for Package CS_SPLIT_REPAIRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SPLIT_REPAIRS" AUTHID CURRENT_USER as
/* $Header: csxdspls.pls 115.0 99/07/16 09:08:02 porting ship $ */

procedure CS_SPLIT_REPAIRS(x_user_id		     IN  NUMBER,
			   x_repair_line_id	     IN  NUMBER,
			   x_first_quantity	     IN  NUMBER,
		   	   x_total_quantity   	     IN  NUMBER);
END CS_SPLIT_REPAIRS;

 

/
