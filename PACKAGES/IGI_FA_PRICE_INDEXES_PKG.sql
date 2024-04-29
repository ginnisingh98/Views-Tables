--------------------------------------------------------
--  DDL for Package IGI_FA_PRICE_INDEXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_FA_PRICE_INDEXES_PKG" AUTHID CURRENT_USER as
-- $Header: igimhcbs.pls 115.6 2003/02/26 13:29:59 klakshmi ship $

PROCEDURE Insert_Row  ( X_Rowid          IN OUT NOCOPY VARCHAR2,
			X_price_index_id        NUMBER ,
			X_price_index_name      VARCHAR2 ,
			X_created_by            NUMBER ,
			X_creation_date         DATE ,
			X_last_updated_by       NUMBER ,
			X_last_update_date      DATE ,
			X_last_update_login     NUMBER
	) ;


END;

 

/
