--------------------------------------------------------
--  DDL for Package Body CN_OBJ_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_TABLES_PKG" AS
-- $Header: cnobjtbb.pls 120.1 2005/08/08 04:49:54 rramakri noship $

/*
Date	  Name	     	        Description
---------------------------------------------------------------------------+
11-FEB-99 Venkatachalam Krishnan Created

  Name	  :  cn_ext_tbl_mapping_pkg
  Purpose : Holds all server side packages used to insert /Delete/Update
            view CN_TABLE_MAPPINGS

  Desc    : Begin-Record is the Start Procedure
*/



-- Lock Record Fired in the form is Handled
--
--
PROCEDURE  lock_record  ( p_object_id IN NUMBER
                        ) IS
   CURSOR C IS
      SELECT *
      FROM  cn_objects
      WHERE  object_id  = p_object_id
      FOR UPDATE OF object_id NOWAIT;

   Recinfo C%ROWTYPE;
BEGIN
   OPEN C;
   Fetch C into Recinfo;

   if( C%NOTFOUND )then
     CLOSE C;
   end if;

   CLOSE C;
   if (Recinfo.object_id = p_object_id )then
      return;
  else
         fnd_message.Set_Name ( 'FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
  end if;
END lock_record ;
--
--
--
PROCEDURE update_record (
			  p_object_id                  IN NUMBER
			, p_name                       IN VARCHAR2
			, p_description                IN VARCHAR2
			, p_dependency_map_complete    IN VARCHAR2
			, p_status                     IN VARCHAR2
			, p_repository_id              IN NUMBER
			, p_alias                      IN VARCHAR2
			, p_table_level                IN VARCHAR2
			, p_table_type                 IN VARCHAR2
			, p_object_type                IN VARCHAR2
			, p_schema                     IN VARCHAR2
			, p_calc_eligible_flag         IN VARCHAR2
			, p_user_name                  IN VARCHAR2
			, x_object_version_no          IN OUT NOCOPY NUMBER
			, p_org_id                     IN NUMBER
                       )
  IS
BEGIN
   x_object_version_no:=x_object_version_no+1;
   UPDATE cn_objects SET
       name                          =   p_name
     , description                   =   p_description
     , dependency_map_complete       =   p_dependency_map_complete
     , object_status                 =   p_status
     , repository_id                 =   p_repository_id
     , alias                         =   p_alias
     , table_level                   =   p_table_level
     , table_type                    =   p_table_type
     , object_type                   =   p_object_type
     , schema                        =   p_schema
     , calc_eligible_flag            =   p_calc_eligible_flag
     , user_name                     =   p_user_name
     , object_version_number         =   x_object_version_no
     WHERE object_id                 =   p_object_id and org_id=p_org_id;
END update_record ;
--
--
--

PROCEDURE insert_record(
			  p_object_id                  IN NUMBER
			, p_name                       IN VARCHAR2
			, p_description                IN VARCHAR2
			, p_dependency_map_complete    IN VARCHAR2
			, p_status                     IN VARCHAR2
			, p_repository_id              IN NUMBER
			, p_alias                      IN VARCHAR2
			, p_table_level                IN VARCHAR2
			, p_table_type                 IN VARCHAR2
			, p_object_type                IN VARCHAR2
			, p_schema                     IN VARCHAR2
			, p_calc_eligible_flag         IN VARCHAR2
			, p_user_name                  IN VARCHAR2
		        , p_data_type                  IN VARCHAR2
			, p_data_length                IN NUMBER
			, p_calc_formula_flag          IN VARCHAR2
			, p_table_id                   IN NUMBER
			, p_column_datatype            IN VARCHAR2
			, x_object_version_number      IN OUT NOCOPY NUMBER
			, p_org_id		       IN NUMBER
                       )
  IS
BEGIN
   INSERT INTO     cn_objects (
			    object_id
			  , name
			  , description
			  , dependency_map_complete
			  , object_status
			  , repository_id
			  , alias
			  , table_level
			  , table_type
			  , object_type
			  , schema
			  , calc_eligible_flag
			  , user_name
			  , data_length
			  , data_type
			  , calc_formula_flag
			  , table_id
			  , column_datatype
			  , object_version_number
			  , org_id
			       )
     VALUES  (
			    p_object_id
			  , p_name
			  , p_description
			  , P_dependency_map_complete
			  , p_status
			  , p_repository_id
			  , p_alias
			  , p_table_level
			  , p_table_type
			  , p_object_type
			  , p_schema
			  , p_calc_eligible_flag
	                  , p_user_name
	                  , p_data_length
	                  , p_data_type
	                  , p_calc_formula_flag
	                  , p_table_id
	                  , p_column_datatype
			  , x_object_version_number
			  , p_org_id
	      );
END insert_record;

--
--

PROCEDURE  begin_record(
		       	  p_operation                  IN VARCHAR2
			, p_object_id                  IN NUMBER
			, p_name                       IN VARCHAR2
			, p_description                IN VARCHAR2
			, p_dependency_map_complete    IN VARCHAR2
			, p_status                     IN VARCHAR2
			, p_repository_id              IN NUMBER
			, p_alias                      IN VARCHAR2
			, p_table_level                IN VARCHAR2
			, p_table_type                 IN VARCHAR2
			, p_object_type                IN VARCHAR2
			, p_schema                     IN VARCHAR2
			, p_calc_eligible_flag         IN VARCHAR2
			, p_user_name                  IN VARCHAR2
		        , p_data_type                  IN VARCHAR2
			, p_data_length                IN NUMBER
			, p_calc_formula_flag          IN VARCHAR2
			, p_table_id                   IN NUMBER
		        , p_column_datatype            IN VARCHAR2
			, x_object_version_number      IN OUT NOCOPY NUMBER
			, p_org_id                     IN NUMBER
			)
  IS
BEGIN
   IF p_operation = 'INSERT' THEN
           insert_record (
			    p_object_id
			  , p_name
			  , p_description
			  , P_dependency_map_complete
			  , p_status
			  , p_repository_id
			  , p_alias
			  , p_table_level
			  , p_table_type
			  , p_object_type
			  , p_schema
			  , p_calc_eligible_flag
			  , p_user_name
			  , p_data_type
			  , p_data_length
			  , p_calc_formula_flag
			  , p_table_id
			  , p_column_datatype
			  , x_object_version_number
			  , p_org_id
			  );


    ELSIF p_operation = 'UPDATE' THEN
          update_record  (
                            p_object_id
			  , p_name
			  , p_description
			  , P_dependency_map_complete
			  , p_status
			  , p_repository_id
			  , p_alias
			  , p_table_level
			  , p_table_type
			  , p_object_type
			  , p_schema
			  , p_calc_eligible_flag
			  , p_user_name
			  , x_object_version_number
			  , p_org_id
			  );
    ELSIF p_operation = 'LOCK' THEN
         lock_record ( p_object_id );
   END IF;
END begin_record ;
--
--
--
END cn_obj_tables_pkg;

/
