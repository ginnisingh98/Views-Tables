--------------------------------------------------------
--  DDL for Package Body CN_SCA_CRRULEATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CRRULEATTR_PVT" as
-- $Header: cnvscrrb.pls 120.2 2005/08/12 00:00:42 vensrini noship $ --+


G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_SCA_CRRULEATTR_PVT';
-- -------------------------------------------------------------------------+
--+
--  Procedure   : Get_PayGroup_ID
--  Description : This procedure is used to get the ID for the pay group
--  Calls       :
--+
-- -------------------------------------------------------------------------+
-- PROCEDURE Get_Credit_Rule_Attr
--   (p_api_version                 IN      NUMBER,
--    p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
--    p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
--    p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
--    p_start_record                IN      NUMBER := -1,
--    p_fetch_size                  IN      NUMBER := -1,
--    p_search_uname                IN      cn_sca_rule_attributes.user_column_name%TYPE := '%',
--    p_search_trx_source           IN      cn_sca_rule_attributes.transaction_source%TYPE,
--    x_credit_rule_attr                   OUT NOCOPY     credit_rule_attr_tbl_type ,
--    x_total_record                OUT NOCOPY     NUMBER,
--    x_return_status               OUT NOCOPY     VARCHAR2,
--    x_msg_count                   OUT NOCOPY     NUMBER,
--    x_msg_data                    OUT NOCOPY     VARCHAR2
--  ) IS
--      l_api_name           CONSTANT VARCHAR2(30) := 'Get_Credit_Rule_Attr';
--      l_api_version        CONSTANT NUMBER       := 1.0;
--
--      l_counter      NUMBER;
--      l_value_set_name  fnd_flex_value_sets.flex_value_set_name%TYPE;
--      l_user_src_name  VARCHAR2(50);
--
--         CURSOR get_value_set_name(x number) IS
--            SELECT flex_value_set_name
--            FROM fnd_flex_value_Sets
--      	WHERE flex_value_set_id = x;

--      	CURSOR get_user_src_name(x_src_name VARCHAR2) IS
-- 	          SELECT /*+ ORDERED*/ a.user_name from cn_objects b, cn_objects a
-- 		  where	  A.name = x_src_name AND B.NAME= 'CN_COMM_LINES_API'
-- 		  AND a.table_id = b.object_id AND A.object_type = 'COL';
--
--          CURSOR l_credit_rule_attr_search_cr IS
--                SELECT transaction_source,
--                       src_column_name,
--                       user_column_name,
--                       datatype,
--                       VALUE_SET_ID,
--                       TRX_SRC_COLUMN_NAME,
   --                    ENABLED_FLAG,
--                       attribute_category,
--                       attribute1,
--                       attribute2,
--                       attribute3,
--                       attribute4,
--                       attribute5,
--                       attribute6,
--                       attribute7,
--                       attribute8,
--                       attribute9,
--                       attribute10,
--                       attribute11,
--                       attribute12,
--                       attribute13,
--                       attribute14,
--                       attribute15,
--                       object_version_number
--                       FROM cn_sca_rule_attributes  WHERE ((upper(user_column_name) like upper(p_search_uname)
--                and (transaction_source like p_search_trx_source)) )
--                        ORDER BY TO_NUMBER(substr(src_column_name,10));
--      CURSOR l_credit_rule_attr_cr IS
--            SELECT transaction_source,
--                   src_column_name,
--                   user_column_name,
--                   datatype,
--                   VALUE_SET_ID,
--                   TRX_SRC_COLUMN_NAME,
--                   ENABLED_FLAG,
--                   attribute_category,
--                   attribute1,
--                   attribute2,
--                   attribute3,
--                   attribute4,
--                   attribute5,
--                   attribute6,
--                   attribute7,
--                   attribute8,
--                   attribute9,
--                   attribute10,
--                   attribute11,
--                   attribute12,
--                   attribute13,
--                   attribute14,
--                   attribute15,
--                   object_version_number
--                   FROM cn_sca_rule_attributes  WHERE ((upper(user_column_name) like upper(p_search_uname)
--            and (transaction_source like p_search_trx_source))
--                 OR ( transaction_source =  p_search_trx_source ))
--                        ORDER BY TO_NUMBER(substr(src_column_name,10));
--
--
--
-- BEGIN
--    -- Standard Start of API savepoint
--    SAVEPOINT   Get_Credit_Rule_Attr;
--    -- Standard call to check for call compatibility.
--    IF NOT FND_API.Compatible_API_Call
--      (l_api_version           ,
--      p_api_version           ,
--      l_api_name              ,
--      G_PKG_NAME )
--    THEN
--       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--    END IF;
--    -- Initialize message list if p_init_msg_list is set to TRUE.
--    IF FND_API.to_Boolean( p_init_msg_list ) THEN
--       FND_MSG_PUB.initialize;
--    END IF;
--    --  Initialize API return status to success
--    x_return_status := FND_API.G_RET_STS_SUCCESS;
--    -- API body
--
--    x_credit_rule_attr := G_MISS_SCACRRR_REC_TB  ;
--
--    l_counter := 0;
--    x_total_record := 0;
--
--    if p_search_uname <> '%'
--    then
--
--
--    FOR l_credit_rule_attr_search IN l_credit_rule_attr_search_cr  LOOP
--
--       x_total_record := x_total_record +1;
--       IF (p_fetch_size = -1) OR (x_total_record >= p_start_record
-- 	AND x_total_record <= (p_start_record + p_fetch_size - 1)) THEN
--
-- 	 x_credit_rule_attr(l_counter).Transaction_source := l_credit_rule_attr_search.transaction_source;
--          x_credit_rule_attr(l_counter).Destination_column := l_credit_rule_attr_search.src_column_name;
--          x_credit_rule_attr(l_counter).User_Name := l_credit_rule_attr_search.user_column_name;
--          x_credit_rule_attr(l_counter).Data_Type := l_credit_rule_attr_search.datatype;
--          --x_credit_rule_attr(l_counter).Value_Set_Id := l_credit_rule_attr_search.VALUE_SET_ID;
--          OPEN get_user_src_name(l_credit_rule_attr_search.TRX_SRC_COLUMN_NAME);
-- 	         FETCH get_user_src_name INTO l_user_src_name;
-- 	 close get_user_src_name;
--
--          x_credit_rule_attr(l_counter).Source_Column := l_user_src_name;
--
--          x_credit_rule_attr(l_counter).enable_flag := nvl(l_credit_rule_attr_search.enabled_flag,'N');
--          x_credit_rule_attr(l_counter).object_version_number := l_credit_rule_attr_search.object_version_number;
--
--          IF l_credit_rule_attr_search.VALUE_SET_ID IS NULL THEN
--                 x_credit_rule_attr(l_counter).value_set_name := FND_API.G_MISS_CHAR;
--               ELSE
--                OPEN get_value_set_name(l_credit_rule_attr_search.VALUE_SET_ID);
--      	           FETCH get_value_set_name INTO l_value_set_name;
--
--               close get_value_set_name;
--               --select flex_value_set_name into x_credit_rule_attr(l_counter).value_set_name from fnd_flex_value_Sets where flex_value_Set_id = l_credit_rule_attr.VALUE_SET_ID;
--                x_credit_rule_attr(l_counter).value_set_name := l_value_set_name;
--           END IF;
--
--
--          l_counter := l_counter + 1;
--
--       END IF;
--    END LOOP;
--
--    else
--       FOR l_credit_rule_attr IN l_credit_rule_attr_cr  LOOP
--
--          x_total_record := x_total_record +1;
--          IF (p_fetch_size = -1) OR (x_total_record >= p_start_record
--    	AND x_total_record <= (p_start_record + p_fetch_size - 1)) THEN
--
--    	 x_credit_rule_attr(l_counter).Transaction_source := l_credit_rule_attr.transaction_source;
--             x_credit_rule_attr(l_counter).Destination_column := l_credit_rule_attr.src_column_name;
--             x_credit_rule_attr(l_counter).User_Name := l_credit_rule_attr.user_column_name;
--             x_credit_rule_attr(l_counter).Data_Type := l_credit_rule_attr.datatype;
--             --x_credit_rule_attr(l_counter).Value_Set_Id := l_credit_rule_attr.VALUE_SET_ID;
--             OPEN get_user_src_name(l_credit_rule_attr.TRX_SRC_COLUMN_NAME);
-- 	            FETCH get_user_src_name INTO l_user_src_name;
-- 	    close get_user_src_name;
--
--             x_credit_rule_attr(l_counter).Source_Column := l_user_src_name;
--             x_credit_rule_attr(l_counter).enable_flag := nvl(l_credit_rule_attr.enabled_flag,'N');
--             x_credit_rule_attr(l_counter).object_version_number := l_credit_rule_attr.object_version_number;
--
--             IF l_credit_rule_attr.VALUE_SET_ID IS NULL THEN
--               x_credit_rule_attr(l_counter).value_set_name := FND_API.G_MISS_CHAR;
--             ELSE
--              OPEN get_value_set_name(l_credit_rule_attr.VALUE_SET_ID);
--    	           FETCH get_value_set_name INTO l_value_set_name;
--
--             close get_value_set_name;
--             --select flex_value_set_name into x_credit_rule_attr(l_counter).value_set_name from fnd_flex_value_Sets where flex_value_Set_id = l_credit_rule_attr.VALUE_SET_ID;
--              x_credit_rule_attr(l_counter).value_set_name := l_value_set_name;
--             END IF;
--
--             l_counter := l_counter + 1;
--
--          END IF;
--    END LOOP;
--    end if;
--
--    -- End of API body.
--    -- Standard check of p_commit.
--    IF FND_API.To_Boolean( p_commit ) THEN
--       COMMIT WORK;
--    END IF;
--    -- Standard call to get message count and if count is 1, get message info.
--    FND_MSG_PUB.Count_And_Get
--      (p_count                 =>      x_msg_count             ,
--      p_data                   =>      x_msg_data              ,
--      p_encoded                =>      FND_API.G_FALSE         );
-- EXCEPTION
--    WHEN FND_API.G_EXC_ERROR THEN
--      ROLLBACK TO Get_Credit_Rule_Attr;
--      x_return_status := FND_API.G_RET_STS_ERROR ;
--      FND_MSG_PUB.Count_And_Get
--        (p_count                 =>      x_msg_count             ,
--        p_data                   =>      x_msg_data              ,
--        p_encoded                =>      FND_API.G_FALSE         );
--    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--      ROLLBACK TO Get_Credit_Rule_Attr;
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      FND_MSG_PUB.Count_And_Get
--        (p_count                 =>      x_msg_count             ,
--        p_data                   =>      x_msg_data              ,
--        p_encoded                =>      FND_API.G_FALSE         );
--    WHEN OTHERS THEN
--      ROLLBACK TO Get_Credit_Rule_Attr;
--      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--      IF      FND_MSG_PUB.Check_Msg_Level
--        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
--      THEN
--         FND_MSG_PUB.Add_Exc_Msg
--           (G_PKG_NAME          ,
--           l_api_name           );
--      END IF;
--      FND_MSG_PUB.Count_And_Get
--        (p_count                 =>      x_msg_count             ,
--        p_data                   =>      x_msg_data              ,
--         p_encoded                =>      FND_API.G_FALSE         );
-- END Get_Credit_Rule_Attr;


--------------------------------------------------------------------------+
-- Procedure  : Create_PayGroup
-- Description: Public API to create a Credit Rule Attribute
-- Calls      : validate_pay_group
--		CN_Pay_Groups_Pkg.Begin_Record
--------------------------------------------------------------------------+
PROCEDURE Create_Credit_RuleAttr(     p_api_version                 IN NUMBER,
        p_init_msg_list               IN VARCHAR2 ,
       	p_commit                      IN VARCHAR2,
    	p_valdiation_level            IN VARCHAR2,
        p_org_id                      IN  cn_sca_rule_attributes.org_id%TYPE, -- MOAC Change
     	p_credit_rule_attr_rec         IN  credit_rule_attr_rec,
     	x_return_status               OUT NOCOPY VARCHAR2,
     	x_msg_count                   OUT NOCOPY NUMBER,
     	x_msg_data                    OUT NOCOPY VARCHAR2
     ) IS



   l_api_name		CONSTANT VARCHAR2(30) := 'Create_Credit_RuleAttr';
   l_api_version        CONSTANT NUMBER := 1.0;
   l_count              NUMBER;

   L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SCA_CRRULEATTR_PVT';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
L_SECURITY_GROUP_ID           NUMBER  ;
l_credit_rule_attr_rec       credit_rule_attr_rec;
l_value_set_id              NUMBER;
l_sca_rule_attribute_id        cn_sca_rule_attributes.sca_rule_attribute_id%TYPE :=0;


/*--   CURSOR get_value_set_id IS
--      SELECT nvl(flex_value_set_id,0)
--      FROM fnd_flex_value_Sets
--	WHERE flex_value_set_name = p_credit_rule_attr_rec.value_set_name;*/


BEGIN


   -- Standard Start of API savepoint

   SAVEPOINT    Create_Credit_RuleAttr;


   -- Standard call to check for call compatibility.

 IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					L_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


-- Initialize message list if p_init_msg_list is set to TRUE.

 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

l_credit_rule_attr_rec := p_credit_rule_attr_rec;
 --  Initialize API return status to success

x_return_status := FND_API.G_RET_STS_SUCCESS;


--OPEN get_value_set_id;
--FETCH get_value_set_id INTO l_value_set_id;
--IF get_value_set_id%ROWCOUNT = 0 THEN
--    null;
--END IF;

l_value_set_id := l_credit_rule_attr_rec.value_set_id;

IF  (l_credit_rule_attr_rec.source_column IS NULL AND l_credit_rule_attr_rec.transaction_source = 'CN')  THEN
    fnd_message.set_name('CN', 'CN_REQ_PAR_MISSING');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

IF l_credit_rule_attr_rec.user_name IS NULL
  THEN
   l_credit_rule_attr_rec.user_name := l_credit_rule_attr_rec.destination_column;
END IF;

IF l_credit_rule_attr_rec.enable_flag IS NULL
  THEN
   l_credit_rule_attr_rec.enable_flag := 'N';
END IF;

SELECT count(*) into l_count from cn_sca_rule_attributes where
   TRANSACTION_SOURCE = l_credit_rule_attr_rec.transaction_source
   and ORG_ID = p_org_id     -- MOAC Change
   and ( SRC_COLUMN_NAME = l_credit_rule_attr_rec.destination_column OR upper(USER_COLUMN_NAME) = upper(trim(l_credit_rule_attr_rec.user_name)));

   IF (l_count <> 0) THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_SCA_RULE_ATTRIBUTE_EXISTS');
         fnd_msg_pub.add;
      END IF;


      RAISE FND_API.G_EXC_ERROR;
   END IF ;

SELECT cn_sca_rule_attributes_s.nextval INTO l_sca_rule_attribute_id FROM sys.dual;
   -- API body


CN_SCA_CRRULEATTR_PKG.INSERT_ROW(

	 x_Rowid                       => L_ROWID,
         x_org_id                      => p_org_id,     -- MOAC Change
	 x_sca_rule_attribute_id       => l_sca_rule_attribute_id,
	 X_TRANSACTION_SOURCE            => l_credit_rule_attr_rec.transaction_source,
	 X_SRC_COLUMN_NAME     	 => l_credit_rule_attr_rec.destination_column,
	 X_DATATYPE                   => l_credit_rule_attr_rec.data_type,
	 X_VALUE_SET_ID		 => l_value_set_id,
	 X_TRX_SRC_COLUMN_NAME         => l_credit_rule_attr_rec.source_column,
	 X_ENABLED_FLAG         	 => l_credit_rule_attr_rec.enable_flag,
	 x_attribute_category    	 => l_credit_rule_attr_rec.attribute_category,
	 x_attribute1            	 => l_credit_rule_attr_rec.attribute1,
	 x_attribute2                  => l_credit_rule_attr_rec.attribute2,
	 x_attribute3                  => l_credit_rule_attr_rec.attribute3,
	 x_attribute4                  => l_credit_rule_attr_rec.attribute4,
	 x_attribute5                  => l_credit_rule_attr_rec.attribute5,
	 x_attribute6                  => l_credit_rule_attr_rec.attribute6,
	 x_attribute7                  => l_credit_rule_attr_rec.attribute7,
	 x_attribute8                  => l_credit_rule_attr_rec.attribute8,
	 x_attribute9                  => l_credit_rule_attr_rec.attribute9,
	 x_attribute10                 => l_credit_rule_attr_rec.attribute10,
	 x_attribute11                 => l_credit_rule_attr_rec.attribute11,
	 x_attribute12                 => l_credit_rule_attr_rec.attribute12,
	 x_attribute13                 => l_credit_rule_attr_rec.attribute13,
	 x_attribute14                 => l_credit_rule_attr_rec.attribute14,
	 x_attribute15                 => l_credit_rule_attr_rec.attribute15,
	 X_OBJECT_VERSION_NUMBER       =>  l_credit_rule_attr_rec.Object_Version_Number,
         X_SECURITY_GROUP_ID           => L_SECURITY_GROUP_ID,
         X_USER_COLUMN_NAME   	      => l_credit_rule_attr_rec.user_name,
 	 x_Creation_Date               => l_creation_date,
 	 x_Created_By                  => l_created_by,
	 x_Last_Update_Date            => l_last_update_date,
	 x_Last_Updated_By             => l_last_updated_by,
	 x_Last_Update_Login           => l_last_update_login
	 	);

IF l_credit_rule_attr_rec.transaction_source = 'CN' THEN
  UPDATE cn_repositories
  SET sca_mapping_status = 'UNSYNC'
  WHERE org_id = p_org_id;  -- MOAC Change
END IF;

IF FND_API.To_Boolean( p_commit ) THEN
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
      ROLLBACK TO Create_Credit_RuleAttr;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Credit_RuleAttr;
      IF SQLCODE = '-1'
        THEN
      	fnd_message.set_name('CN', 'CN_SCA_RULE_ATTRIBUTES_UNIQUE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
       END IF;
      --x_loading_status := 'UNEXPECTED_ERR';
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Credit_RuleAttr;
      --x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Create_Credit_RuleAttr;

---------------------------------------------------------------------------+
--  Procedure   : 	Update PayGroup
--  Description : 	This is a public procedure to update pay groups
--  Calls       : 	validate_pay_group
--			CN_Pay_Groups_Pkg.Begin_Record
---------------------------------------------------------------------------+

PROCEDURE  Update_Credit_RuleAttr  (
     p_api_version                 IN NUMBER,
     p_init_msg_list               IN VARCHAR2 ,
     p_commit                    IN VARCHAR2,
     p_valdiation_level    IN VARCHAR2,
     p_org_id                      IN  cn_sca_rule_attributes.org_id%TYPE, -- MOAC Change
     p_credit_rule_attr_rec            IN  credit_rule_attr_rec,
--     p_old_credit_rule_attr_rec            IN  credit_rule_attr_rec,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
     ) IS
L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SCA_CRRULEATTR_PVT';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
L_SECURITY_GROUP_ID           NUMBER  ;

   l_api_name		CONSTANT VARCHAR2(30)  := 'Update_Credit_RuleAttr';
   l_api_version       	CONSTANT NUMBER        := 1.0;
   l_credit_rule_attr_rec               credit_rule_attr_rec;
   l_credit_rule_attribute_id		 NUMBER;

   l_count                       NUMBER;
   l_count2                       NUMBER;
   l_period_set_id               NUMBER;
   l_period_type_id              NUMBER;
   l_start_date                  DATE;
   l_end_date                    DATE;
   l_null_date          CONSTANT DATE := to_date('31-12-3000','DD-MM-YYYY');
   l_dummy 			 NUMBER;
   l_old_ovn             NUMBER;
--   l_sca_rule_attribute_id cn_sca_rule_attributes.sca_rule_attribute_id%TYPE;
   l_value_set_id              fnd_flex_value_sets.flex_value_set_id%TYPE;
   l_trx_source_column         cn_sca_rule_attributes.trx_src_column_name%TYPE;

--  CURSOR get_value_set_id IS
--       SELECT flex_value_set_id
--       FROM fnd_flex_value_Sets
--     WHERE flex_value_set_name = p_credit_rule_attr_rec.value_set_name;

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT    Update_Credit_RuleAttr;

   -- Standard call to check for call compatibility.

 IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					L_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   l_credit_rule_attr_rec := p_credit_rule_attr_rec;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


 SELECT object_version_number  -- ,sca_rule_attribute_id
   INTO l_old_ovn              -- ,l_sca_rule_attribute_id
   FROM cn_sca_rule_attributes
   WHERE SCA_RULE_ATTRIBUTE_ID = l_credit_rule_attr_rec.sca_rule_attribute_id
     AND ORG_ID = p_org_id;  -- MOAC Change
--         TRANSACTION_SOURCE = p_old_credit_rule_attr_rec.transaction_source
--         and SRC_COLUMN_NAME = p_old_credit_rule_attr_rec.destination_column ;
     --   and TRX_SRC_COLUMN_NAME = p_old_credit_rule_attr_rec.source_column;

 IF l_old_ovn <> p_credit_rule_attr_rec.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
 END IF;

--OPEN get_value_set_id;
--    FETCH get_value_set_id INTO l_value_set_id;
--    IF get_value_set_id%ROWCOUNT = 0 THEN
--       NULL;
--    END IF;
--CLOSE get_value_set_id;

l_value_set_id := l_credit_rule_attr_rec.value_set_id;



IF l_credit_rule_attr_rec.enable_flag IS NULL THEN
    l_credit_rule_attr_rec.enable_flag := 'N';
END IF;

IF  (l_credit_rule_attr_rec.source_column IS NULL AND l_credit_rule_attr_rec.transaction_source = 'CN'AND (l_credit_rule_attr_rec.enable_flag <> 'N'  OR l_value_set_id IS NOT NULL OR  l_credit_rule_attr_rec.user_name IS NOT NULL ))  THEN
    fnd_message.set_name('CN', 'CN_REQ_PAR_MISSING');
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
END IF;


IF (l_value_set_id IS NULL AND l_credit_rule_attr_rec.user_name IS NULL
AND l_credit_rule_attr_rec.source_column IS NULL
AND l_credit_rule_attr_rec.enable_flag ='N') THEN
  SELECT count(1) into l_count2
  FROM CN_SCA_CONDITIONS
  WHERE SCA_RULE_ATTRIBUTE_ID= l_credit_rule_attr_rec.sca_rule_attribute_id
    AND ORG_ID = p_org_id; -- MOAC Change

  IF l_count2 = 0 THEN
   CN_SCA_CRRULEATTR_PKG.DELETE_ROW(
      X_ORG_ID                    => p_org_id,  -- MOAC Change
      X_SCA_RULE_ATTRIBUTE_ID     => l_credit_rule_attr_rec.sca_rule_attribute_id)    ;

 IF l_credit_rule_attr_rec.transaction_source = 'CN'  THEN
   update cn_repositories
      set sca_mapping_status = 'UNSYNC'
    where org_id = p_org_id;   -- MOAC Change
 END IF;
 ELSE
   IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('CN', 'CN_SCA_RULE_COND_EXISTS');
            fnd_msg_pub.add;
         END IF;

      RAISE FND_API.G_EXC_ERROR;
 END IF;
ELSE
IF l_credit_rule_attr_rec.user_name IS NULL
  THEN
   l_credit_rule_attr_rec.user_name := l_credit_rule_attr_rec.destination_column;
END IF;

--IF l_credit_rule_attr_rec.user_name <> p_old_credit_rule_attr_rec.user_name THEN
SELECT count(sca_rule_attribute_id) into l_count from cn_sca_rule_attributes where
   TRANSACTION_SOURCE = l_credit_rule_attr_rec.transaction_source
   and org_id = p_org_id -- MOAC Change
   and upper(USER_COLUMN_NAME) = upper(trim(l_credit_rule_attr_rec.user_name));

   IF (l_count <> 0) THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_SCA_RULE_ATTRIBUTE_EXISTS');
         fnd_msg_pub.add;
      END IF;


      RAISE FND_API.G_EXC_ERROR;
   END IF ;
--END IF;

l_count2 :=0;
SELECT count(1) into l_count2 FROM CN_SCA_CONDITIONS WHERE
    SCA_RULE_ATTRIBUTE_ID= l_credit_rule_attr_rec.sca_rule_attribute_id
    and org_id = p_org_id;  -- MOAC Change
 IF l_count2 = 0 THEN

-- Changing the UNCYNC update checking condition to retrieve the existing source column
select trx_src_column_name
into l_trx_source_column
from cn_sca_rule_attributes
where sca_rule_attribute_id = l_credit_rule_attr_rec.sca_rule_attribute_id
  and org_id = p_org_id; -- MOAC Change

CN_SCA_CRRULEATTR_PKG.UPDATE_ROW(
         x_org_id                      => p_org_id,  -- MOAC Change
         x_sca_rule_attribute_id       => l_credit_rule_attr_rec.sca_rule_attribute_id,
         X_TRANSACTION_SOURCE            => l_credit_rule_attr_rec.transaction_source,
	 X_SRC_COLUMN_NAME     	 => l_credit_rule_attr_rec.destination_column,
	 X_DATATYPE                   => l_credit_rule_attr_rec.data_type,
	 X_VALUE_SET_ID		 => l_value_set_id,
	 X_TRX_SRC_COLUMN_NAME         => l_credit_rule_attr_rec.source_column,
	 X_ENABLED_FLAG         	 => l_credit_rule_attr_rec.enable_flag,
	 x_attribute_category    	 => l_credit_rule_attr_rec.attribute_category,
	 x_attribute1            	 => l_credit_rule_attr_rec.attribute1,
	 x_attribute2                  => l_credit_rule_attr_rec.attribute2,
	 x_attribute3                  => l_credit_rule_attr_rec.attribute3,
	 x_attribute4                  => l_credit_rule_attr_rec.attribute4,
	 x_attribute5                  => l_credit_rule_attr_rec.attribute5,
	 x_attribute6                  => l_credit_rule_attr_rec.attribute6,
	 x_attribute7                  => l_credit_rule_attr_rec.attribute7,
	 x_attribute8                  => l_credit_rule_attr_rec.attribute8,
	 x_attribute9                  => l_credit_rule_attr_rec.attribute9,
	 x_attribute10                 => l_credit_rule_attr_rec.attribute10,
	 x_attribute11                 => l_credit_rule_attr_rec.attribute11,
	 x_attribute12                 => l_credit_rule_attr_rec.attribute12,
	 x_attribute13                 => l_credit_rule_attr_rec.attribute13,
	 x_attribute14                 => l_credit_rule_attr_rec.attribute14,
	 x_attribute15                 => l_credit_rule_attr_rec.attribute15,
	 X_OBJECT_VERSION_NUMBER       =>  l_credit_rule_attr_rec.Object_Version_Number,
         X_SECURITY_GROUP_ID           => L_SECURITY_GROUP_ID ,
         X_USER_COLUMN_NAME   	      => l_credit_rule_attr_rec.user_name,
 	 x_Last_Update_Date            => l_last_update_date,
	 x_Last_Updated_By             => l_last_updated_by,
	 x_Last_Update_Login           => l_last_update_login

	);


IF l_credit_rule_attr_rec.source_column <>   l_trx_source_column AND  l_credit_rule_attr_rec.transaction_source = 'CN'
   THEN
   update cn_repositories
      set sca_mapping_status = 'UNSYNC'
    where org_id = p_org_id;
END IF;
ELSE
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
           THEN
              fnd_message.set_name('CN', 'CN_SCA_RULE_COND_EXISTS');
              fnd_msg_pub.add;
           END IF;

        RAISE FND_API.G_EXC_ERROR;
 END IF;
END IF;

IF (SQL%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
 END IF;
   -- End of API body.
   -- Standard check of p_commit.

   IF FND_API.To_Boolean( p_commit ) THEN
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
      ROLLBACK TO Update_Credit_RuleAttr;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Credit_RuleAttr;
      --x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Credit_RuleAttr;
     -- x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
END Update_Credit_RuleAttr;

-- TODO: Make MOAC Changes
PROCEDURE Generate_Package
      ( p_api_version       IN NUMBER,
 	p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
 	p_commit             IN VARCHAR2 := FND_API.G_FALSE,
 	p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
        p_org_id            IN NUMBER, -- MOAC Change
 	x_return_status     OUT NOCOPY VARCHAR2,
 	x_msg_count         OUT NOCOPY NUMBER,
 	x_msg_data          OUT NOCOPY VARCHAR2
 	) IS
L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SCA_CRRULEATTR_PVT';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
l_count            NUMBER;

   l_api_name		CONSTANT VARCHAR2(30)  := 'Generate_Package';
   l_api_version       	CONSTANT NUMBER        := 1.0;
       l_return_status      VARCHAR2(2000) ;
       l_msg_count            NUMBER;
       l_msg_data             VARCHAR2(2000);




BEGIN

 -- Standard Start of API savepoint

 SAVEPOINT    Generate_Package;

  -- Standard call to check for call compatibility.

IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					L_PKG_NAME )
    THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean( p_init_msg_list ) THEN
   FND_MSG_PUB.initialize;
END IF;


 x_return_status := FND_API.G_RET_STS_SUCCESS;
-- x_loading_status := 'CN_UPDATED';

 -- API body
 SELECT count(*) into l_count
   FROM CN_SCA_RULE_ATTRIBUTES
  WHERE TRANSACTION_SOURCE='CN'
    AND ORG_ID = p_org_id; -- MOAC Change

 IF l_count = 0 THEN
    fnd_message.set_name('CN', 'CN_NORECORD_GENERATE');
       fnd_msg_pub.add;
       raise fnd_api.g_exc_error;
 ELSE


 CN_SCA_INTERFACE_MAP_PVT.GENERATE (
      p_api_version       	  => l_api_version,
	p_init_msg_list     	  => fnd_api.g_true,
	p_commit            	  => fnd_api.g_false,
	p_validation_level  	  =>  fnd_api.g_valid_level_full,
        p_org_id                  =>  p_org_id, -- MOAC Change
	x_return_status     	  =>  l_return_status,
	x_msg_count         	  =>  l_msg_count,
	x_msg_data          	  =>  l_msg_data
	);




IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   x_return_status     := l_return_status;
     fnd_message.set_name('CN', 'CN_GENERATION_FAILED');

     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_ERROR;
  -- x_loading_status    := l_loading_status;

ELSE
   update cn_repositories
     set sca_mapping_status='GENERATED'
     WHERE org_id = p_org_id; -- MOAC Change

END IF;
END IF;

 -- End of API body.
 -- Standard check of p_commit.

 IF FND_API.To_Boolean( p_commit ) THEN
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
      --ROLLBACK TO Generate_Package;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --ROLLBACK TO Generate_Package;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      --ROLLBACK TO Generate_Package;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Generate_Package;

END CN_SCA_CRRULEATTR_PVT ;

/
