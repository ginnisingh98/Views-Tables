--------------------------------------------------------
--  DDL for Package Body IGI_FA_PRICE_INDEXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_FA_PRICE_INDEXES_PKG" as
-- $Header: igimhcbb.pls 115.5 2003/02/26 13:30:22 klakshmi ship $

PROCEDURE Insert_Row  ( X_Rowid          IN OUT NOCOPY VARCHAR2,
			X_price_index_id        NUMBER ,
			X_price_index_name      VARCHAR2 ,
			X_created_by            NUMBER ,
			X_creation_date         DATE ,
			X_last_updated_by       NUMBER ,
			X_last_update_date      DATE ,
			X_last_update_login     NUMBER
	) IS
	CURSOR C IS     SELECT rowid
			FROM   fa_price_indexes
			WHERE price_index_id  = X_price_index_id ;
BEGIN

	INSERT INTO   fa_price_indexes   (
			price_index_id      ,
			price_index_name    ,
			created_by          ,
			creation_date       ,
			last_updated_by     ,
			last_update_date    ,
			last_update_login
	)
	VALUES (
			X_price_index_id      ,
			X_price_index_name    ,
			X_created_by          ,
			X_creation_date       ,
			X_last_updated_by     ,
			X_last_update_date    ,
			X_last_update_login
	);

	OPEN C;
	FETCH C INTO X_Rowid;
	if (C%NOTFOUND) then
		CLOSE C;
		Raise NO_DATA_FOUND;
	end if;
	CLOSE C;
END Insert_Row;

END;

/
