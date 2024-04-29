--------------------------------------------------------
--  DDL for Package Body CN_REVENUE_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REVENUE_CLASS_PVT" AS
--$Header: cnvrclsb.pls 120.2 2005/08/07 23:04:47 vensrini noship $

--Global Variables

G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_REVENUE_CLASS_PVT';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;

--=========================================================================
-- Start of comments
--	API name 	: Create_Revenue_class
--	Type		: Private
--	Function	: This private API can be used to create Revenue Class
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
PROCEDURE create_revenue_class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  x_revenue_class_id 	 OUT NOCOPY     NUMBER,
  p_revenue_class_rec		IN      CN_REVENUE_CLASS_PVT.revenue_class_rec_type,
  p_org_id			IN 	NUMBER
)
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Revenue_class';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_error_status             NUMBER;
     l_error_parameter          VARCHAR2(30);
     l_rowid			VARCHAR2(4000);
     l_sequence_number		NUMBER;
     l_count                    NUMBER;
     l_revenue_class_id         NUMBER;

 Cursor get_rev_cls( p_revenue_class_name cn_revenue_classes.name%TYPE )  IS
  select  count(1)
    from cn_revenue_classes
  where name = p_revenue_class_name and org_id = p_org_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Revenue_Class;
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
  if p_revenue_class_rec.name is NULL  THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_REV_NAME_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_REV_NAME_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Duplicate Check
     l_count := 0;
     open get_rev_cls(p_revenue_class_rec.name);
     fetch get_rev_cls into l_count;
     close get_rev_cls;

     IF l_count >= 1 THEN

       IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_REV_CLASS_DUPLICATE');
         fnd_msg_pub.add;
       END IF;
       x_loading_status := 'CN_REV_CLASS_DUPLICATE';
       RAISE FND_API.G_EXC_ERROR;
     END IF;



  CN_REVENUE_CLASS_PKG.insert_row
   (x_revenue_class_id      => x_revenue_class_id
    ,p_name                 => p_revenue_class_rec.name
    ,p_description          => p_revenue_class_rec.description
    ,p_liability_account_id   => p_revenue_class_rec.liability_account_id
    ,p_expense_account_id     => p_revenue_class_rec.expense_account_id
    ,p_creation_date        => sysdate
    ,p_created_by           => g_created_by
    ,p_last_update_date     => sysdate
    ,p_last_updated_by      => g_last_updated_by
    ,p_last_update_login    => g_last_update_login
    ,p_org_id		    => p_org_id);

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
      ROLLBACK TO Create_Revenue_Class;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Revenue_Class;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Revenue_Class;
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
END Create_Revenue_Class;
--=========================================================================
-- Start of comments
--	API name 	: Update_Revenue_class
--	Type		: Public
--	Function	: This Public API can be used to update a Revenue Class
--			  in Oracle Sales
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

PROCEDURE Update_Revenue_class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  pold_revenue_class_rec	IN OUT NOCOPY  CN_REVENUE_CLASS_PVT.revenue_class_rec_type,
  p_revenue_class_rec		IN OUT NOCOPY  CN_REVENUE_CLASS_PVT.revenue_class_rec_type
) IS

   CURSOR l_ovn_csr IS
    SELECT nvl(object_version_number,1)
      FROM cn_revenue_classes
      WHERE revenue_class_id = p_revenue_class_rec.revenue_class_id;

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Revenue_Class';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_loading_st             VARCHAR2(4000);
       l_count                  NUMBER;

       l_object_version_number  NUMBER;


   Cursor get_rev_cls( p_revenue_class_name cn_revenue_classes.name%TYPE,
                       p_revenue_class_id  NUMBER )  IS
  select  count(1)
    from cn_revenue_classes
  where name = p_revenue_class_name
    and revenue_class_id <> p_revenue_class_id;

 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_Revenue_Class;
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

  pold_revenue_class_rec.revenue_class_id := p_revenue_class_rec.revenue_class_id;

  if p_revenue_class_rec.name is null  THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_REV_CLS_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_REV_CLS_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_revenue_class_rec.revenue_Class_id is null  THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_REV_CLS_NOT_NULL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_REV_CLS_NOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Duplicate Check
     l_count := 0;
     open get_rev_cls(p_revenue_class_rec.name, p_revenue_class_rec.revenue_class_id);
     fetch get_rev_cls into l_count;
     close get_rev_cls;

     IF l_count >= 1 THEN

       IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_REV_CLASS_DUPLICATE');
         fnd_msg_pub.add;
       END IF;
       x_loading_status := 'CN_REV_CLASS_DUPLICATE';
       RAISE FND_API.G_EXC_ERROR;
     END IF;


 -- check if the object version number is the same
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;

   /* IF (nvl(l_object_version_number,1) <>
     nvl(p_revenue_class_rec.object_version_number,1)) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_OBJECT_VERSION';
      RAISE FND_API.G_EXC_ERROR;

    end if;
   */


   CN_REVENUE_CLASS_PKG.update_row
   (p_revenue_class_id      =>  p_revenue_class_rec.revenue_class_id
    ,p_name                 => p_revenue_class_rec.name
    ,p_description          => p_revenue_class_rec.description
    ,p_liability_account_id => p_revenue_class_rec.liability_account_id
    ,p_expense_account_id   => p_revenue_class_rec.expense_account_id
    ,p_object_version_number=> p_revenue_class_rec.object_version_number
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
      ROLLBACK TO Update_Revenue_Class;
      x_return_status := FND_API.G_RET_STS_ERROR ;

 FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Revenue_Class;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Revenue_Class;
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
--	API name 	: Delete_Revenue_Class
--	Type		: Private
--	Function	: This Public API can be used to delete Revenue Class
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
PROCEDURE Delete_Revenue_Class
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_revenue_class_id		IN      NUMBER
) IS


  l_api_name			CONSTANT VARCHAR2(30)	:= 'Delete_Revenue_Class';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;
  l_status                      NUMBER;

  l_loading_status		VARCHAR2(100);
  l_error_parameter		VARCHAR2(100);
  l_error_status		NUMBER;

  l_count        		NUMBER  := 0;
  l_rule_count  		NUMBER  := 0;
  l_hierarchy_count  		NUMBER  := 0;
  l_quota_rule_count  		NUMBER  := 0;
  l_total_count  		NUMBER  := 0;

  --
  -- cursor to get the revenue classes
  --
  cursor get_rev is
  select name
    from cn_revenue_classes
   where revenue_class_id =   p_revenue_class_id;

  l_revenue_class_name       cn_revenue_classes.name%TYPE;
  l_env_org_id               NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_Revenue_class;
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

  --
  -- get revenue class
  --
  open get_rev;
  fetch get_rev into l_revenue_class_name;
  close get_rev;

   --
   -- get the rule count before the delete the the revenue class
   --
  SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
			      SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    INTO l_env_org_id FROM dual;

   SELECT count(rule_id)
     INTO l_rule_count
     FROM cn_rules_all_b
    WHERE revenue_class_id = p_revenue_class_id
      AND NVL(ORG_ID, l_env_org_id) = l_env_org_id;

   --
   -- get the quota rules before deleting the revenue class
   --
   SELECT count(quota_rule_id)
     INTO l_quota_rule_count
     FROM cn_quota_rules
    WHERE revenue_class_id = p_revenue_Class_id;

   --
   -- get the hierarchy count
   --

   SELECT nvl(MAX(ref_count),0)
     INTO l_hierarchy_count
     FROM cn_hierarchy_nodes chn , cn_dim_hierarchies  cdh
    WHERE chn.external_id = p_revenue_Class_id
      AND chn.dim_hierarchy_id = cdh.dim_hierarchy_id
      AND cdh.header_dim_hierarchy_id = -1001;

   IF (l_hierarchy_count = 0) THEN

      -- Delete this revenue class from nodes table.
      DELETE FROM cn_hierarchy_nodes
	WHERE external_id = p_revenue_Class_id
	AND dim_hierarchy_id IN (SELECT dim_hierarchy_id
				 FROM cn_dim_hierarchies
				 WHERE header_dim_hierarchy_id = -1001);
   END IF;

   l_total_count := l_rule_count + l_hierarchy_count + l_quota_rule_count;

   IF (l_total_count <> 0) THEN
    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
        fnd_message.set_name('CN','REV_CLS_EXISTS_SW');
        fnd_message.set_token('REV', l_revenue_class_name);
        fnd_message.set_token('RULE_COUNT', l_rule_count);
        fnd_message.set_token('QUOTA_RULE_COUNT',l_quota_rule_count);
        fnd_message.set_token('HIERARCHY_COUNT', l_hierarchy_count);
        fnd_msg_pub.add;
      END IF;
      x_loading_status := 'REV_CLS_EXISTS_SW';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- delete the revenue class

   CN_REVENUE_CLASS_PKG.Delete_row(p_revenue_Class_id);

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
		ROLLBACK TO Delete_Revenue_Class;
                x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
	     (
	     p_count   =>  x_msg_count ,
	     p_data    =>  x_msg_data  ,
	     p_encoded => FND_API.G_FALSE
	     );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Delete_Revenue_Class;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

               FND_MSG_PUB.Count_And_Get
	       (
	         p_count   =>  x_msg_count ,
	         p_data    =>  x_msg_data  ,
	         p_encoded => FND_API.G_FALSE
	       );

	WHEN OTHERS THEN
		ROLLBACK TO Delete_Revenue_Class;
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


END CN_REVENUE_CLASS_PVT;

/
