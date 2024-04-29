--------------------------------------------------------
--  DDL for Package Body OE_AK_OBJ_ATTR_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_AK_OBJ_ATTR_EXT_PKG" AS
/* $Header: OEXVOATB.pls 120.0 2005/06/01 01:07:00 appldev noship $ */

   PROCEDURE Update_Row(
      p_rowid                                   in      varchar2
     , p_database_object_name           in   VARCHAR2
     , p_attribute_code                 in     VARCHAR2
     , p_defaulting_sequence            in      NUMBER
     , p_defaulting_condn_ref_flag              in      VARCHAR2
     , p_last_updated_by                in      number
     , p_last_update_date               in      date
     , p_last_update_login              in      number
   )
   IS
   BEGIN

      UPDATE OE_AK_OBJ_ATTR_EXT
      SET
	  defaulting_sequence = p_defaulting_sequence
	 ,defaulting_condn_ref_flag = p_defaulting_condn_ref_flag
         ,last_updated_by    	 = p_last_updated_by
         ,last_update_date     = p_last_update_date
         ,last_update_login     = p_last_update_login
      WHERE rowid = p_rowid;


	IF (SQL%NOTFOUND) then
 	Raise NO_DATA_FOUND;
	end if;
    END Update_Row;

    PROCEDURE Lock_Row( p_rowid     in      varchar2
      , p_database_object_name          in   VARCHAR2
      , p_attribute_code                in     VARCHAR2
      , p_defaulting_sequence           in      NUMBER
      , p_defaulting_condn_ref_flag          in      VARCHAR2
      , p_created_by                    in      number
      , p_creation_date                 in      date
      , p_last_updated_by               in      number
      , p_last_update_date              in      date
      , p_last_update_login             in      number
      )
    IS
    	CURSOR C IS
    	SELECT * FROM OE_AK_OBJ_ATTR_EXT
	WHERE rowid = p_Rowid
	FOR UPDATE OF database_object_name NOWAIT;

	Recinfo C%ROWTYPE;

    BEGIN
 	OPEN C;
	FETCH C into Recinfo;

	IF (C%NOTFOUND) then
  	CLOSE C;
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	APP_EXCEPTION.Raise_Exception;
	else
	CLOSE C;
	end if;

	if (
	(Recinfo.database_object_name = p_database_object_name)
	AND (Recinfo.attribute_code = p_attribute_code)
	AND (Recinfo.defaulting_sequence = p_defaulting_sequence)
	AND (Recinfo.defaulting_condn_ref_flag = p_defaulting_condn_ref_flag)
	)
	then return;
	else
	FND_MESSAGE.set_Name('FND','FORM_RECORD_CHANGED');
	APP_EXCEPTION.Raise_Exception;
	end if;

    END Lock_Row;

END OE_AK_OBJ_ATTR_EXT_PKG;

/
