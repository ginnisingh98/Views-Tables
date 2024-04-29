--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_MAPPING" AS
/* $Header: amsvlsrb.pls 115.31 2004/06/15 20:44:37 solin ship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_LIST_SRC_MAPPING
--
-- HISTORY
-- 24-MAY-2002    huili           Added "Import_Type" for the "create_mapping" module
-- 29-MAY-2002    huili           Change the "c_required_field_id" definition.
-- 12-AUG-2002    huili           Bug #2502991 for both XML and NONE XML.
-- 14-AUG-2002    huili           Bug #2441049 for both XML and NONE XML.
------------------------------------------------------------------------------

PROCEDURE create_mapping(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_imp_list_header_id    in  NUMBER,
   p_source_name           in  varchar2,
   p_table_name            in  varchar2,
   p_list_src_fields       IN  l_Tbl_Type ,
   p_list_target_fields    IN  l_Tbl_Type ,
   px_src_type_id          in  OUT NOCOPY number
) IS
	l_api_name constant varchar2(30) := 'create_mapping';
	l_api_version       CONSTANT NUMBER := 1.0;
	l_list_source_type_id   number;
	l_list_source_field_id  number;
	l_list_target_fields       l_Tbl_Type ;
	l_temp_fields       l_Tbl_Type ;

   CURSOR c_get_id is
      SELECT ams_list_src_types_s.NEXTVAL
      FROM DUAL;

   CURSOR c_get_field_id is
      SELECT ams_list_src_fields_s.NEXTVAL
      FROM DUAL;

   CURSOR c_get_source_col_name(p_src_id number) is
     SELECT source_column_name
     FROM ams_list_src_fields_vl
     WHERE list_source_type_id=p_src_id
	  ORDER BY LIST_SOURCE_FIELD_ID;

	CURSOR c_get_source_name(p_src_type_id number) is
     SELECT source_type_code FROM ams_list_src_types_vl
     where list_source_type_id = p_src_type_id ;

	CURSOR c_get_import_type(p_import_list_header_id number) is
     SELECT import_type, b2b_flag
     FROM AMS_IMP_LIST_HEADERS_ALL
     WHERE IMPORT_LIST_HEADER_ID = p_import_list_header_id;
	l_import_type c_get_import_type%ROWTYPE;

	CURSOR c_get_list_source_name(name VARCHAR2) IS
     SELECT 1
     FROM  ams_list_src_types_vl
     WHERE list_source_name=name;

	mapping_table dbms_utility.uncl_array;
	l_no_of_rows number;
	l_no_of_rows_saved number;
	l_tmp_var    number :=1;
	l_old_map_name VARCHAR2(30);

	--cursor c_count_import(cur_source_type_id number,
	--							 cur_table_name   varchar2) is
	--SELECT COUNT(1)
	--FROM ams_imp_col_mapping ai
	--WHERE ai.required_flag = 'Y'
	--AND ai.table_name = cur_table_name
	--AND NOT  EXISTS ( SELECT 'x'
	--					 FROM ams_list_src_fields al
	--					 WHERE al.field_table_name = ai.table_name
	--					 AND al.field_column_name IS NOT NULL
	--					 AND NVL (al.field_column_name, '') = ai.column_name
	--					 AND al.list_source_type_id = cur_source_type_id );

	cursor c_count_import(cur_source_type_id number,
								 p_import_type   varchar2) is
	SELECT COUNT(1)
	FROM ak_region_items_vl ai
	WHERE ai.region_code LIKE 'AMS_IMPH_METADATA_0%'
	AND ai.required_flag = 'Y'
	AND ai.SORTBY_VIEW_ATTRIBUTE_NAME = p_import_type
	AND NOT  EXISTS ( SELECT 'x'
						 FROM ams_list_src_fields al
						 WHERE UPPER(al.field_table_name) = UPPER(ai.view_usage_name)
						 AND al.field_column_name IS NOT NULL
						 AND UPPER(al.field_column_name) = UPPER(ai.view_attribute_name)
						 AND al.list_source_type_id = cur_source_type_id );

	--CURSOR c_required_field_id (p_source_type_id NUMBER,
	--							 p_table_name   VARCHAR2) IS
	--SELECT ai.COL_MAPPING_ID
	--FROM ams_imp_col_mapping ai
	--WHERE ai.required_flag = 'Y'
	--AND ai.table_name = p_table_name
	--AND ai.column_name NOT IN ( SELECT al.field_column_name
	--					 FROM ams_list_src_fields al
	--					 WHERE al.field_table_name = ai.table_name
	--					 AND al.field_column_name IS NOT NULL
	--					 AND al.list_source_type_id = p_source_type_id );


	l_count   number;
	l_dummy             number;
	l_debug_msg VARCHAR2(2000);
BEGIN

	SAVEPOINT create_mapping;

   IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
        RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

	OPEN c_get_import_type (p_imp_list_header_id);
   FETCH c_get_import_type INTO l_import_type;
	CLOSE c_get_import_type;

	IF l_import_type.IMPORT_TYPE = 'CUSTOMER' AND l_import_type.b2b_flag = 'Y' THEN
	   l_import_type.IMPORT_TYPE := 'B2B';
	ELSIF l_import_type.IMPORT_TYPE = 'CUSTOMER' AND l_import_type.b2b_flag = 'N' THEN
	   l_import_type.IMPORT_TYPE := 'B2C';
	END IF;

	IF  px_src_type_id is not null then -- update

		FOR l_rec IN c_get_source_col_name(px_src_type_id)
		LOOP
			l_temp_fields(l_tmp_var):=l_rec.source_column_name;
			l_tmp_var := l_tmp_var +1;
		END LOOP;

		FOR l_rec IN c_get_source_name(px_src_type_id)
		LOOP
			l_old_map_name:=l_rec.source_type_code;

		END LOOP;

		l_no_of_rows_saved :=l_temp_fields.last;
		l_no_of_rows :=  p_list_src_fields.last;

		IF l_no_of_rows_saved <> l_no_of_rows THEN
			FND_MESSAGE.Set_Name('AMS','AMS_INVALID_MAP');
			FND_MSG_PUB.Add;
			RAISE FND_API.g_exc_error;
		END If;

		for i in  1 .. l_no_of_rows
		loop
			begin
				IF p_list_src_fields(i) <> l_temp_fields(i) THEN
					FND_MESSAGE.Set_Name('AMS','AMS_INVALID_MAP');
					FND_MSG_PUB.Add;
					RAISE FND_API.g_exc_error;
				END If;
			end;
		end loop;
	ELSE -- create, need to check the name
		OPEN c_get_list_source_name(p_source_name);
      FETCH c_get_list_source_name INTO l_dummy;
      IF (l_dummy is not null)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_MAPPING_NAME_DUPLICATE');
         FND_MSG_PUB.Add;
         RAISE FND_API.g_exc_error;
      END IF;
	End if;

   IF p_list_target_fields IS NULL OR p_list_target_fields.COUNT=0
   THEN
		FND_MESSAGE.Set_Name('AMS','AMS_INVALID_MAP');
      FND_MSG_PUB.Add;
      RAISE FND_API.g_exc_error;
   END IF;

   IF p_list_src_fields.last <> p_list_target_fields.last
   THEN
		FND_MESSAGE.Set_Name('AMS','AMS_MAX_COL_MAP');
      FND_MSG_PUB.Add;
      RAISE FND_API.g_exc_error;
   END IF;

   if  px_src_type_id is  null then
       OPEN c_get_id;
       FETCH c_get_id INTO l_list_source_type_id;
       CLOSE c_get_id;
       px_src_type_id := l_list_source_type_id;
   else
		/****
      delete from ams_list_src_types
      where list_source_type_id = px_src_type_id ;

      delete from ams_list_src_types_tl
      where list_source_type_id = px_src_type_id ;

      DELETE FROM ams_list_src_fields_tl
      WHERE list_source_field_id IN
     (SELECT list_source_field_id FROM ams_list_src_fields
        WHERE list_source_type_id =px_src_type_id);


      delete from ams_list_src_fields
      where list_source_type_id = px_src_type_id;

      l_list_source_type_id := px_src_type_id ;
		****/
		IF p_source_name = l_old_map_name THEN
     		update ams_imp_list_headers_all
			set LIST_SOURCE_TYPE_ID = px_src_type_id,
				 last_update_date= SYSDATE
			where IMPORT_LIST_HEADER_ID = p_imp_list_header_id;
			RETURN;
		END IF;
   end if;
	--ELSE
	--create a new mapping with new name but leave the old one intact
	OPEN c_get_id;
	FETCH c_get_id INTO l_list_source_type_id;
	CLOSE c_get_id;
	px_src_type_id := l_list_source_type_id;

	INSERT INTO ams_list_src_types (
		list_source_type_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		object_version_number,
		list_source_type,
		source_type_code,
		source_object_name,
		master_source_type_flag,
		source_object_pk_field,
		enabled_flag,
		view_application_id,
		IMPORT_TYPE
	)
	values (
		l_list_source_type_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.conc_login_id,
		1,
		'IMPORT',
		p_source_name,
		'DATA FILE',
		'Y',
		'',
		'Y',
		530, --CHANGE!!
		l_import_type.IMPORT_TYPE
	);

	insert into ams_list_src_types_tl (
		language,
		source_lang,
		list_source_name,
		description,
		list_source_type_id,
		last_update_date,
		last_update_by,
		creation_date,
		created_by,
		last_update_login
	)
	select
		l.language_code,
		userenv('LANG'),
		p_source_name,
		p_source_name,
		l_list_source_type_id,
		sysdate,
		FND_GLOBAL.user_id,
		sysdate,
		FND_GLOBAL.user_id,
		FND_GLOBAL.conc_login_id
		from FND_LANGUAGES L
		where L.INSTALLED_FLAG in ('I', 'B')
		and not exists
		(select NULL
		from AMS_LIST_SRC_TYPES_TL T
		where T.LIST_SOURCE_TYPE_ID = l_list_source_type_id
		and T.LANGUAGE = L.LANGUAGE_CODE);

	l_no_of_rows :=  p_list_src_fields.last;
	for i in  1 .. l_no_of_rows
	loop
		begin
			select column_name
			into  l_list_target_fields(i)
			from ams_imp_col_mapping
			where table_name   = p_table_name
			and meaning  = p_list_target_fields(i) ;
			exception
				when no_data_found then
					l_list_target_fields(i) := p_list_target_fields(i) ;
		end;
	end loop;

	l_no_of_rows :=  p_list_src_fields.last;

	--
	-- Remove the following code since the target fields contain column names
	--
	--for i in  1 .. l_no_of_rows
	--loop
	--   begin
	--  select column_name
	--     into  l_list_target_fields(i)
	--     from ams_imp_col_mapping
	--    where table_name   = p_table_name
	--      and meaning  = p_list_target_fields(i) ;
	--   exception
	--         when no_data_found then
	--            l_list_target_fields(i) := p_list_target_fields(i) ;
	--   end;
	--end loop;

	for i in 1 .. l_no_of_rows
	loop

		OPEN c_get_field_id;
		FETCH c_get_field_id INTO l_list_source_field_id;
		CLOSE c_get_field_id;

		INSERT INTO ams_list_src_fields (
			list_source_field_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			object_version_number,
			de_list_source_type_code,
			list_source_type_id,
			field_table_name,
			field_column_name,
			source_column_name,
			--        source_column_meaning,
			enabled_flag,
			start_position,
			end_position
		)
		(SELECT
			l_list_source_field_id,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.conc_login_id,
			1,
			p_source_name,
			l_list_source_type_id,
			p_table_name,
			--l_list_target_fields(i),
			p_list_target_fields(i),
			p_list_src_fields(i) ,
			--      p_list_src_fields(i)   ,
			'Y',
			'',
			'' from dual);

		insert into ams_list_src_fields_tl (
			language,
			source_lang,
			source_column_meaning,
			list_source_field_id,
			last_update_date,
			last_update_by,
			creation_date,
			created_by,
			last_update_login
		)
		select
			l.language_code,
			userenv('LANG'),
			p_list_src_fields(i),
			l_list_source_field_id,
			sysdate,
			FND_GLOBAL.user_id,
			sysdate,
			FND_GLOBAL.user_id,
			FND_GLOBAL.conc_login_id
			from FND_LANGUAGES L
			where L.INSTALLED_FLAG in ('I', 'B')
			and not exists
			(select NULL
			from AMS_LIST_SRC_FIELDS_TL T
			where T.LIST_source_field_ID = l_list_source_field_id
			and T.LANGUAGE = L.LANGUAGE_CODE);
	end loop;

	l_count := 0;

	OPEN c_count_import (l_list_source_type_id, l_import_type.IMPORT_TYPE);
	FETCH c_count_import INTO l_count;
	CLOSE c_count_import;

	if l_count > 0 then
		FND_MESSAGE.Set_Name('AMS','AMS_REQ_FIELDS_NOT_MAPPED');
		FND_MSG_PUB.Add;
		RAISE FND_API.g_exc_error;
	end if;

	update ams_imp_list_headers_all
	set  LIST_SOURCE_TYPE_ID    = l_list_source_type_id
	where IMPORT_LIST_HEADER_ID =    p_imp_list_header_id ;

	IF x_return_status =  fnd_api.g_ret_sts_error THEN
		RAISE FND_API.g_exc_error;
	ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		RAISE FND_API.g_exc_unexpected_error;
	END IF;
	IF p_commit = FND_API.g_true then
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_AND_Get
		( p_count           =>      x_msg_count,
			p_data            =>      x_msg_data,
			p_encoded         =>      FND_API.G_FALSE );
	--END IF;
--end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
	  ROLLBACK TO create_mapping;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO create_mapping;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO create_mapping;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;
END AMS_LIST_SRC_MAPPING ;

/
