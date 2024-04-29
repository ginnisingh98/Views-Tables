--------------------------------------------------------
--  DDL for Package Body CN_CALC_EXT_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_EXT_TABLES_PVT" AS
--$Header: cnvexttb.pls 115.9 2002/11/21 21:13:14 hlchen ship $

--Global Variables

G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_CALC_EXT_TABLES_PVT';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;

--=========================================================================
-- Start of comments
--	API name 	: Create_Calc_Ext_Table
--	Type		: Private
--	Function	: This private API can be used to create External
--			  Table Mapping
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
--=========================================================================
PROCEDURE create_calc_ext_table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  x_calc_ext_table_id 	 OUT NOCOPY     NUMBER,
  p_calc_ext_table_rec		IN      CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type
)
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Calc_Ext_Table';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_error_status             NUMBER;
     l_error_parameter          VARCHAR2(30);
     l_rowid			VARCHAR2(4000);
     l_sequence_number		NUMBER;
     l_count                    NUMBER;
     l_calc_ext_table_id        NUMBER;

     l_alias			cn_calc_ext_tables.alias%TYPE;

   cursor unique_alias is
    Select count(*)
      from cn_calc_ext_tables
    Where external_table_id = p_calc_ext_table_rec.external_table_id
     and  calc_ext_table_id <> nvl( p_calc_ext_table_rec.calc_ext_table_id, -99);

    l_table_id   NUMBER;


   cursor table_name_curs ( p_object_id NUMBER ) is
    select name from cn_objects
    where  object_id =  p_object_id
      and  object_type = 'TBL';

    l_external_table_name  cn_objects.name%TYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Calc_Ext_Table;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
     THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   -- API body

   open unique_alias;
   fetch unique_alias into l_count;
   close unique_alias;

   if l_count = 0 then
     l_alias :=   p_calc_ext_table_rec.alias;
   else
     l_count := l_count + 1;
     l_alias :=   p_calc_ext_table_rec.alias || l_count ;
   end if;

   --Check for missing parameters in the p_ruleset_rec parameter
   IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.name,
	 cn_api.get_lkup_meaning('NAME', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  IF (cn_api.chk_miss_null_num_para
       ( p_calc_ext_table_rec.internal_table_id,
	 cn_api.get_lkup_meaning('INTERNAL_TABLE_ID', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  if p_calc_ext_table_rec.internal_table_id = 0 THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INTERNAL_TABLE_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INTERNAL_TABLE_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (cn_api.chk_miss_null_num_para
       ( p_calc_ext_table_rec.external_table_id,
	 cn_api.get_lkup_meaning('EXTERNAL_TABLE_ID', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

 if p_calc_ext_table_rec.external_table_id = 0 THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_EXTERNAL_TABLE_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_EXTERNAL_TABLE_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.used_flag,
	 cn_api.get_lkup_meaning('USED_FLAG', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.schema,
	 cn_api.get_lkup_meaning('SCHEMA', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  /* IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.alias,
	 cn_api.get_lkup_meaning('ALIAS', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF ;
  */

  open table_name_curs(  p_calc_ext_table_rec.external_table_id);
  fetch table_name_curs into l_external_table_name;
  close table_name_curs;


  CN_CALC_EXT_TABLE_PKG.insert_row
   (x_calc_ext_table_id     => x_calc_ext_table_id
    ,p_name                 => p_calc_ext_table_rec.name
    ,p_description          => p_calc_ext_table_rec.description
    ,p_internal_table_id    => p_calc_ext_table_rec.internal_table_id
    ,p_external_table_id    => p_calc_ext_table_rec.external_table_id
    ,p_used_flag	    => p_calc_ext_table_rec.used_flag
    ,p_schema 		    => p_calc_ext_table_rec.schema
    ,p_external_table_name  => l_external_table_name
    ,p_alias		    => l_alias
    ,p_creation_date        => sysdate
    ,p_created_by           => g_created_by
    ,p_last_update_date     => sysdate
    ,p_last_updated_by      => g_last_updated_by
    ,p_last_update_login    => g_last_update_login);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Calc_Ext_Table;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Calc_Ext_Table;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Calc_Ext_Table;
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
END Create_Calc_Ext_Table;
--=========================================================================
-- Start of comments
--	API name 	: Update_Calc_Ext_Table
--	Type		: Public
--	Function	: This Public API can be used to update a rule,
--			  a ruleset or rule attributes in Oracle Sales
--			  Compensation.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
--=========================================================================

PROCEDURE Update_calc_ext_table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_calc_ext_table_rec	IN OUT NOCOPY  CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type,
  p_calc_ext_table_rec		IN OUT NOCOPY  CN_CALC_EXT_TABLES_PVT.calc_ext_table_rec_type
) IS

/*   CURSOR l_ovn_csr IS
    SELECT nvl(object_version_number,1)
      FROM cn_calc_ext_tables
      WHERE calc_ext_table_id = p_old_calc_ext_table_rec.calc_ext_table_id;
*/

  cursor unique_alias is
    Select count(*)
      from cn_calc_ext_tables
    Where external_table_id = p_calc_ext_table_rec.external_table_id
     and  calc_ext_table_id <> nvl( p_calc_ext_table_rec.calc_ext_table_id, -99);

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Calc_Ext_Table';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_loading_st             VARCHAR2(4000);
       l_count                  NUMBER;

       l_ruleset_status	        VARCHAR2(100);
       l_request_id             NUMBER;
       l_object_version_number  NUMBER;

       l_alias			cn_calc_ext_tables.alias%TYPE;


 cursor table_name_curs ( p_object_id NUMBER ) is
    select name from cn_objects
    where  object_id =  p_object_id
      and  object_type = 'TBL';

    l_external_table_name  cn_objects.name%TYPE;


  cursor get_tbl_curs ( p_calc_ext_table_id NUMBER ) is
   Select external_table_id, internal_table_id
    from cn_calc_ext_tables
   where calc_ext_table_id = p_calc_ext_table_id;


  cursor get_dtl_curs ( p_calc_ext_table_id NUMBER ) is
   Select count(1)
    from cn_calc_ext_tbl_dtls
   where calc_ext_table_id = p_calc_ext_table_id;


   l_col_found NUMBER := 0;
   l_old_external_table_id NUMBER := 0;
   l_old_internal_table_id NUMBER := 0;


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_CALC_EXT_TABLES;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
     THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

  p_old_calc_ext_table_rec.calc_ext_table_id := p_calc_ext_table_rec.calc_ext_table_id;


  open unique_alias;
   fetch unique_alias into l_count;
   close unique_alias;

   if l_count = 0 then
     l_alias :=   p_calc_ext_table_rec.alias;
   else
     l_count := l_count + 1;
     l_alias :=   p_calc_ext_table_rec.alias || l_count;
   end if;

 IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.name,
	 cn_api.get_lkup_meaning('NAME', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


  IF (cn_api.chk_miss_null_num_para
       ( p_calc_ext_table_rec.internal_table_id,
	 cn_api.get_lkup_meaning('INTERNAL_TABLE_ID', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

   if p_calc_ext_table_rec.internal_table_id = 0 THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INTERNAL_TABLE_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INTERNAL_TABLE_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (cn_api.chk_miss_null_num_para
       ( p_calc_ext_table_rec.external_table_id,
	 cn_api.get_lkup_meaning('EXTERNAL_TABLE_ID', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

 IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.used_flag,
	 cn_api.get_lkup_meaning('USED_FLAG', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  if p_calc_ext_table_rec.external_table_id = 0 THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_EXTERNAL_TABLE_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_EXTERNAL_TABLE_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.schema,
	 cn_api.get_lkup_meaning('SCHEMA', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

  IF (cn_api.chk_miss_null_char_para
       ( p_calc_ext_table_rec.alias,
	 cn_api.get_lkup_meaning('ALIAS', 'EXTERNAL_TABLE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF ;

  open table_name_curs(  p_calc_ext_table_rec.external_table_id);
  fetch table_name_curs into l_external_table_name;
  close table_name_curs;

  open get_tbl_curs( p_calc_ext_table_rec.calc_ext_table_id);
  fetch get_tbl_curs into l_old_external_table_id, l_old_internal_table_id;
  close get_tbl_curs;

  if ( p_calc_ext_table_rec.internal_table_id <>
       l_old_internal_table_id ) or
     ( p_calc_ext_table_rec.external_table_id <>
       l_old_external_table_id ) THEN

       open get_dtl_curs( p_calc_ext_table_rec.calc_ext_table_id);
       fetch get_dtl_curs into l_col_found;
       close get_dtl_curs;

    if l_col_found = 1 THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_EXT_UPDATE_NOT_ALLOWED');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_EXT_UPDATE_NOT_ALLOWED';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;


  CN_CALC_EXT_TABLE_PKG.update_row
   (p_calc_ext_table_id     =>  p_calc_ext_table_rec.calc_ext_table_id
    ,p_name                 => p_calc_ext_table_rec.name
    ,p_description          => p_calc_ext_table_rec.description
    ,p_internal_table_id    => p_calc_ext_table_rec.internal_table_id
    ,p_external_table_id    => p_calc_ext_table_rec.external_table_id
    ,p_used_flag	    => p_calc_ext_table_rec.used_flag
    ,p_schema 		    => p_calc_ext_table_rec.schema
    ,p_external_table_name  => l_external_table_name
    ,p_alias		    => l_alias
    ,p_last_update_date     => sysdate
    ,p_last_updated_by      => g_last_updated_by
    ,p_last_update_login    => g_last_update_login);


   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_CALC_EXT_TABLES;
      x_return_status := FND_API.G_RET_STS_ERROR ;

 FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_CALC_EXT_TABLES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN OTHERS THEN
      ROLLBACK TO Update_CALC_EXT_TABLES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME,
	    l_api_name
	    );
      END IF;

        FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END;
--=========================================================================
-- Start of comments
--	API name 	: Delete_CALC_EXT_TABLES
--	Type		: Public
--	Function	: This Public API can be used to delete External
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_ruleset_rec_type      IN
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--
--
-- End of comments
--=========================================================================
PROCEDURE Delete_Calc_Ext_Table
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_calc_ext_table_id		IN      NUMBER
) IS


  l_api_name			CONSTANT VARCHAR2(30)	:= 'Delete_Calc_Ext_Table';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;
  l_status                      NUMBER;

  l_loading_status		VARCHAR2(100);
  l_error_parameter		VARCHAR2(100);
  l_error_status		NUMBER;

  cursor get_col is
   select count(*)
     from cn_calc_ext_tbl_dtls
    where CALC_EXT_TABLE_ID = p_calc_ext_table_id ;

  l_count  number := 0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_CALC_EXT_TABLES;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
        	    	    	    	p_api_version,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- check delete allowed

 open get_col;
 fetch get_col into l_count;
 close get_col;

 IF l_count > 0 THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_COLUMN_EXISTS');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_COLUMN_EXISTS';
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  CN_CALC_EXT_TABLE_PKG.Delete_row(p_calc_ext_table_id);

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Delete_CALC_EXT_TABLES;
                x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
	     (
	     p_count   =>  x_msg_count ,
	     p_data    =>  x_msg_data  ,
	     p_encoded => FND_API.G_FALSE
	     );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Delete_CALC_EXT_TABLES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               FND_MSG_PUB.Count_And_Get
	       (
	         p_count   =>  x_msg_count ,
	         p_data    =>  x_msg_data  ,
	         p_encoded => FND_API.G_FALSE
	       );

	WHEN OTHERS THEN
		ROLLBACK TO Delete_CALC_EXT_TABLES;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		 l_api_name
	    		);
		END IF;

                FND_MSG_PUB.Count_And_Get
	        (
	         p_count   =>  x_msg_count ,
	         p_data    =>  x_msg_data  ,
	         p_encoded => FND_API.G_FALSE
	        );

  END;


END CN_CALC_EXT_TABLES_PVT;

/
