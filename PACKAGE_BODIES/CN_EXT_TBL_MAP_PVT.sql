--------------------------------------------------------
--  DDL for Package Body CN_EXT_TBL_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_EXT_TBL_MAP_PVT" AS
/* $Header: cnvextbb.pls 115.6 2002/11/28 00:02:05 fting ship $ */

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'cn_ext_tbl_map_pvt'     ;
G_FILE_NAME          CONSTANT VARCHAR2(12) := 'cnvextbb.pls'           ;
G_LAST_UPDATE_DATE   DATE                  := sysdate                  ;
G_LAST_UPDATED_BY    NUMBER                := fnd_global.user_id       ;
G_CREATION_DATE      DATE                  := sysdate                  ;
G_CREATED_BY         NUMBER                := fnd_global.user_id       ;
G_LAST_UPDATE_LOGIN  NUMBER                := fnd_global.login_id      ;


FUNCTION get_calc_ext_table_id RETURN NUMBER
  IS
     l_id NUMBER;
BEGIN
   SELECT cn_calc_ext_tables_s.NEXTVAL
     INTO l_id
     FROM dual;
   RETURN (l_id);
END;

FUNCTION get_mapping_status ( p_mapping_name VARCHAR2 ) RETURN NUMBER
  IS
     l_mapping_id NUMBER;
BEGIN
   SELECT calc_ext_table_id
     INTO l_mapping_id
     FROM cn_calc_ext_tables
     WHERE name = Ltrim(Rtrim(p_mapping_name));
   RETURN(l_mapping_id);
EXCEPTION
   WHEN no_data_found THEN
      RETURN(0);
END get_mapping_status;

PROCEDURE create_external_mapping(
	x_return_status      OUT NOCOPY VARCHAR2                ,
	x_msg_count          OUT NOCOPY NUMBER                  ,
	x_msg_data           OUT NOCOPY VARCHAR2                ,
	x_loading_status     OUT NOCOPY VARCHAR2                ,
	p_api_version        IN  NUMBER                  ,
	p_init_msg_list      IN  VARCHAR2                ,
	p_commit             IN  VARCHAR2                ,
	p_validation_level   IN  VARCHAR2                ,
	p_table_mapping_rec  IN  table_mapping_rec_type  ,
	p_column_mapping_tbl IN  column_mapping_tbl_type ,
	x_calc_ext_table_id  OUT NOCOPY NUMBER
	)
  IS
     l_api_name		CONSTANT VARCHAR2(30) := 'Create_External_Mapping';
     l_api_version      CONSTANT NUMBER := 1.0;
     x_status           NUMBER;

     l_calc_ext_table_id NUMBER;
     l_rowid VARCHAR2(30);
BEGIN
   --   +
   -- Standard Start of API savepoint
   -- +
   SAVEPOINT    create_external_mapping ;
   --+
   -- Standard call to check for call compatibility.
   --+
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME ) THEN
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
   --       +
   x_status :=  get_mapping_status ( p_table_mapping_rec.name);
   IF ( x_status = 0 ) THEN
      l_calc_ext_table_id := get_calc_ext_table_id ;
      cn_calc_ext_tables_pkg.insert_row(x_rowid               => l_rowid,
					x_calc_ext_table_id   => l_calc_ext_table_id ,
					x_schema              => p_table_mapping_rec.schema ,
					x_name                => p_table_mapping_rec.name ,
					x_description         => p_table_mapping_rec.description ,
					x_internal_table_id   => p_table_mapping_rec.internal_table_id ,
					x_external_table_id   => p_table_mapping_rec.external_table_id ,
					x_used_flag           => p_table_mapping_rec.used_flag ,
					x_external_table_name => p_table_mapping_rec.external_table_name ,
					x_alias               => p_table_mapping_rec.alias ,
					x_attribute_category  => p_table_mapping_rec.attribute_category ,
					x_attribute1          => p_table_mapping_rec.attribute1 ,
					x_attribute2          => p_table_mapping_rec.attribute2 ,
					x_attribute3          => p_table_mapping_rec.attribute3 ,
					x_attribute4          => p_table_mapping_rec.attribute4 ,
					x_attribute5          => p_table_mapping_rec.attribute5 ,
					x_attribute6          => p_table_mapping_rec.attribute6 ,
					x_attribute7          => p_table_mapping_rec.attribute7 ,
					x_attribute8          => p_table_mapping_rec.attribute8 ,
					x_attribute9          => p_table_mapping_rec.attribute9 ,
					x_attribute10         => p_table_mapping_rec.attribute10 ,
					x_attribute11         => p_table_mapping_rec.attribute11 ,
					x_attribute12         => p_table_mapping_rec.attribute12 ,
					x_attribute13         => p_table_mapping_rec.attribute13 ,
					x_attribute14         => p_table_mapping_rec.attribute14 ,
					x_attribute15         => p_table_mapping_rec.attribute15 ,
					x_creation_date       => g_creation_date ,
					x_created_by          => g_created_by ,
					x_last_update_date    => g_last_update_date ,
					x_last_updated_by     => g_last_updated_by ,
					x_last_update_login   => g_last_update_login ) ;
    ELSE
      fnd_message.set_name('CN', 'NAME_NOT_UNIQUE');
      RAISE fnd_api.g_exc_error;
   END IF;

   FOR i IN 1 ..  p_column_mapping_tbl.COUNT LOOP
      cn_calc_ext_tbl_dtls_pkg.insert_row
	(x_rowid               => l_rowid,
	 x_calc_ext_tbl_dtl_id => NULL,
	 x_external_column_id  => p_column_mapping_tbl(i).external_column_id,
	 x_calc_ext_table_id   => l_calc_ext_table_id,
	 x_internal_column_id  => p_column_mapping_tbl(i).internal_column_id,
	 x_attribute_category  => p_column_mapping_tbl(i).attribute_category,
	 x_attribute1          => p_column_mapping_tbl(i).attribute1,
         x_attribute2          => p_column_mapping_tbl(i).attribute2,
	 x_attribute3          => p_column_mapping_tbl(i).attribute3,
	 x_attribute4          => p_column_mapping_tbl(i).attribute4,
	 x_attribute5          => p_column_mapping_tbl(i).attribute5,
	 x_attribute6          => p_column_mapping_tbl(i).attribute6,
	 x_attribute7          => p_column_mapping_tbl(i).attribute7,
	 x_attribute8          => p_column_mapping_tbl(i).attribute8,
	 x_attribute9          => p_column_mapping_tbl(i).attribute9,
	 x_attribute10         => p_column_mapping_tbl(i).attribute10,
	 x_attribute11         => p_column_mapping_tbl(i).attribute11,
	 x_attribute12         => p_column_mapping_tbl(i).attribute12,
         x_attribute13         => p_column_mapping_tbl(i).attribute13,
         x_attribute14         => p_column_mapping_tbl(i).attribute14,
         x_attribute15         => p_column_mapping_tbl(i).attribute15,
         x_creation_date       => g_creation_date,
         x_created_by          => g_created_by,
         x_last_update_date    => g_last_update_date,
         x_last_updated_by     => g_last_updated_by,
         x_last_update_login   => g_last_update_login);

   END LOOP;
   --   +
   -- Standard Check to p_commit
   --   +
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
      ROLLBACK TO create_external_mapping ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  create_external_mapping ;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN OTHERS THEN
      ROLLBACK TO create_external_mapping ;
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

END create_external_mapping;
--
END  cn_ext_tbl_map_pvt;

/
