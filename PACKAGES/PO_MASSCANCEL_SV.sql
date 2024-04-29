--------------------------------------------------------
--  DDL for Package PO_MASSCANCEL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MASSCANCEL_SV" AUTHID CURRENT_USER as
/* $Header: POXTIMCS.pls 115.0 99/07/17 02:05:06 porting ship $ */

 PROCEDURE lock_row (x_rowid 		  	VARCHAR2,
		     x_default_cancel_flag	VARCHAR2);

 PROCEDURE update_row(x_rowid                 VARCHAR2,
                       x_last_update_date      DATE,
                       x_last_updated_by       NUMBER,
		       x_last_update_login     NUMBER,
		       x_default_cancel_flag   VARCHAR2);


END PO_MASSCANCEL_SV;

 

/
