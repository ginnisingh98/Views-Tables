--------------------------------------------------------
--  DDL for Package Body CN_CNSYTC_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CNSYTC_TABLES_PVT" AS
/* $Header: cnsytblb.pls 120.2 2005/09/16 06:55:57 rramakri noship $ */

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'cn_cnsytc_tables_pvt'   ;
G_FILE_NAME          CONSTANT VARCHAR2(12) := 'cnsytblb.pls'           ;
G_LAST_UPDATE_DATE   DATE                  := sysdate                  ;
G_LAST_UPDATED_BY    NUMBER                := fnd_global.user_id       ;
G_CREATION_DATE      DATE                  := sysdate                  ;
G_CREATED_BY         NUMBER                := fnd_global.user_id       ;
G_LAST_UPDATE_LOGIN  NUMBER                := fnd_global.login_id      ;
G_ROWID              VARCHAR2(30)                                      ;
G_PROGRAM_TYPE       VARCHAR2(30)                                      ;

--======================================================================
PROCEDURE get_new_object_id ( x_object_id OUT NOCOPY NUMBER   )
  IS
     l_object_id      NUMBER(15);
BEGIN
   SELECT  cn_objects_s.NEXTVAL
     INTO l_object_id
     FROM sys.dual;

   x_object_id := l_object_id;

END get_new_object_id;
--======================================================================

PROCEDURE  insert_into_cn_objects( p_table_rec        IN OUT NOCOPY   table_rec_type,
				   x_ext_obj_id        OUT NOCOPY NUMBER
				   )
  IS
     l_new_object_id NUMBER;
     l_new_object_version_no NUMBER;
BEGIN
  -- get_new_object_id( l_new_object_id );
       l_new_object_version_no:=1;

       cn_obj_tables_pkg.begin_record(
	P_OPERATION                   => 'INSERT'
	, P_OBJECT_ID                 => p_table_rec.object_id
	, P_NAME                      => p_table_rec.name
	, P_DESCRIPTION               => p_table_rec.description
        , P_DEPENDENCY_MAP_COMPLETE   => 'N'
        , P_STATUS                    => 'A'
	, P_REPOSITORY_ID             => p_table_rec.repository_id
	, P_ALIAS                     => p_table_rec.alias
	, P_TABLE_LEVEL               => NULL
	, P_TABLE_TYPE                => 'T'
	, P_OBJECT_TYPE               => 'TBL'
	, P_SCHEMA                    => p_table_rec.schema
	, P_CALC_ELIGIBLE_FLAG        => p_table_rec.calc_eligible_flag
        , P_USER_NAME                 => p_table_rec.user_name
	, p_data_length               => NULL
	, p_data_type                 => NULL
	, p_calc_formula_flag         => NULL
	, p_table_id                  => NULL
	, p_column_datatype           => NULL
	, x_object_version_number         =>l_new_object_version_no
	, p_org_id                    =>p_table_rec.org_id
	 );

   --+
   -- Return This Id back to Calling Form for
   -- Bringing up columns
   --+
   x_ext_obj_id := p_table_rec.object_id;
END  insert_into_cn_objects;
--========================================================================
--Change made by Sundar Venkat on 02/11/2002 in procedure insert_ext_cols
--Included data_type IN (CHAR,NCHAR,VARCHAR2,VARCHAR,NVARCHAR2,LONG,NUMBER,DATE)




PROCEDURE  insert_ext_cols(p_table_rec           IN OUT NOCOPY  table_rec_type,
			   p_ext_tbl_id          IN NUMBER
			   )
  IS
     CURSOR ext_cols_cur  IS
	SELECT  column_name,
	        data_type,
	        data_length
	  FROM  all_tab_columns
	  WHERE owner       = p_table_rec.schema
	  AND   table_name  = p_table_rec.name
      AND   data_type IN ('CHAR','NCHAR','VARCHAR2','VARCHAR','NVARCHAR2','LONG','NUMBER','DATE');

     l_col_name        VARCHAR2(30);
     l_data_type       VARCHAR2(9);
     l_data_len        NUMBER(15);
     l_new_object_id   NUMBER(15);
     l_column_data_type VARCHAR2(30);
     l_new_object_version_no NUMBER;
BEGIN
   l_new_object_version_no:=1;
   OPEN ext_cols_cur;
   LOOP
      FETCH ext_cols_cur
	INTO l_col_name,
	l_data_type,
	l_data_len;
      EXIT WHEN ext_cols_cur%notfound;
      get_new_object_id( l_new_object_id );
      --+
      -- Set Column_Datatype to what ever is the data type of
      -- the native column
      --+
      IF l_data_type = 'NUMBER' THEN
	 l_column_data_type := 'NUMB';
       ELSIF l_data_type = 'DATE' THEN
	 l_column_data_type := 'DATE';
       ELSE
	 l_column_data_type := 'ALPN';
      END IF;
      cn_obj_tables_pkg.begin_record(
	   P_OPERATION                 => 'INSERT'
	 , P_OBJECT_ID                 => l_new_object_id
	 , P_NAME                      => l_col_name
	 , P_DESCRIPTION               =>  p_table_rec.description
	 , P_DEPENDENCY_MAP_COMPLETE   => 'N'
	 , P_STATUS                    => 'A'
 	 , P_REPOSITORY_ID             => p_table_rec.repository_id
	 , P_ALIAS                     => p_table_rec.alias
	 , P_TABLE_LEVEL               => NULL
	 , P_TABLE_TYPE                => NULL
	 , P_OBJECT_TYPE               => 'COL'
	 , P_SCHEMA                    => p_table_rec.schema
	 , P_CALC_ELIGIBLE_FLAG        => p_table_rec.calc_eligible_flag
	 , P_USER_NAME                 => l_col_name
	 , p_data_type                 => l_data_type
 	 , p_data_length               => l_data_len
	 , p_calc_formula_flag         => 'N'
	 , p_table_id                  => p_table_rec.object_id
	 , p_column_datatype           => l_column_data_type
	 , x_object_version_number     => l_new_object_version_no
	 , p_org_id                    => p_table_rec.org_id
				  );
   END LOOP;
   CLOSE ext_cols_cur ;
END;
--========================================================================
--
--
--
--
--
--   x_return_status      OUT VARCHAR2
--   x_msg_count          OUT NUMBER
--   x_msg_data           OUT VARCHAR2
--   x_loading_status     OUT VARCHAR2
--   p_api_version        IN  NUMBER
--   p_init_msg_list      IN  VARCHAR2
--   p_commit             IN  VARCHAR2
--   p_validation_level   IN  VARCHAR2
--   p_table_mapping_rec  IN  p_table_mapping_rec_type
--   p_column_mapping_tbl IN  p_column_mapping_tbl_type
--
--
--
--
--
--
--
--
--
--
--
--

PROCEDURE create_tables(
			      x_return_status      OUT NOCOPY VARCHAR2
			    , x_msg_count          OUT NOCOPY NUMBER
			    , x_msg_data           OUT NOCOPY VARCHAR2
			    , x_loading_status     OUT NOCOPY VARCHAR2
			    , p_api_version        IN  NUMBER
			    , p_init_msg_list      IN  VARCHAR2
			    , p_commit             IN  VARCHAR2
			    , p_validation_level   IN  VARCHAR2
			    , p_table_rec          IN OUT NOCOPY table_rec_type
			    )
  IS
     l_api_name		CONSTANT VARCHAR2(30)
                        := 'CREATE_TABLES_PVT';
     l_api_version      CONSTANT NUMBER := 1.0;
     l_int_obj_id       NUMBER(15);
     l_ext_obj_id       NUMBER(15);
     l_repository_id    NUMBER(15);
     x_status           NUMBER;
BEGIN
   --   +
   -- Standard Start of API savepoint
   -- +
   SAVEPOINT  cn_obj_tables  ;
   --+
   -- Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --+
   -- Initialize message list if p_init_msg_list is set to TRUE.
   -- +
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- +
   --  Initialize API return status to success
   --   +
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   --    +
   --+
   --      +
   -- Repository Id of EXternal Table = Repository_Id of Internal Table
   -- Insert EXTERNAL_TABLE_NAME INTO CN_OBJECTS
   -- AND GET THE EXTERNAL_TABLE ID FROM CN_OBJECTS
   insert_into_cn_objects( p_table_rec,l_ext_obj_id);
   --   +
   -- CALL TABLE HANDLER TO INSERT INTO CN_TABLE_MAPPINGS
   --   +
   insert_ext_cols(p_table_rec,l_ext_obj_id);

   --   +
   -- Standard Check to p_commit
   --+

   IF( FND_API.to_boolean(p_commit)) THEN
      COMMIT WORK;
   END IF ;

   --   +
   -- Standard Call to get Message count if count > 1 get message
   --   +
   FND_MSG_PUB.count_and_get
     (
	    p_count => x_msg_count ,
	    p_data  => x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO cn_obj_tables ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO   cn_obj_tables ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN OTHERS THEN
      ROLLBACK TO  cn_obj_tables ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	);

END create_tables;
--
END cn_cnsytc_tables_pvt;

/
