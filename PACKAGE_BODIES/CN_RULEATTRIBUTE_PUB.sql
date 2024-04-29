--------------------------------------------------------
--  DDL for Package Body CN_RULEATTRIBUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULEATTRIBUTE_PUB" AS
--$Header: cnpratrb.pls 120.1 2005/08/25 23:37:55 rramakri noship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_RuleAttribute_PUB';
G_API_NAME             VARCHAR2(30);
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;


-- Start of comments
--	API name 	: Create_RuleAttribute
--	Type		: Public
--	Function	: This Public API can be used to create a rule,
--			  a ruleset or rule attributes.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_RuleAttribute_rec IN
--					CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: Note text
--
-- End of comments

PROCEDURE Create_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_RuleAttribute_rec       	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
)
IS

  l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_RuleAttribute';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;
  l_count                       NUMBER;
  l_ruleattribute_rec_pvt       cn_ruleattribute_pvt.ruleattribute_rec_type;
  l_object_id                   cn_objects.object_id%TYPE;
  l_bind_data_id                NUMBER;
  l_return_code                 VARCHAR2(1);


  CURSOR get_rules(p_ruleset_id IN cn_rulesets.ruleset_id%TYPE,p_org_id IN cn_rulesets.org_id%TYPE) IS
     SELECT rule_id
       FROM cn_rules
       WHERE ruleset_id = p_ruleset_id
       AND name = p_ruleattribute_rec.rule_name
       AND org_id=p_org_id;

     --
     -- Declaration for user hooks
     --
     l_OAI_array	    JTF_USR_HKS.oai_data_array_type;
     l_ruleattribute_rec    CN_RuleAttribute_PUB.RuleAttribute_rec_type;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_RuleAttribute;
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


   --
   -- Assign the parameter to a local variable
   --
   l_ruleattribute_rec := p_ruleattribute_rec;


   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'CREATE_RULEATTRIBUTE',
				'B',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.create_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'CREATE_RULEATTRIBUTE',
				'B',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.create_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;


   --
   -- API body
   --


   --Check for missing parameters
   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.object_name,
	 cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.data_flag,
	 cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT object_id
     INTO l_object_id
     FROM cn_objects
     WHERE name = l_RuleAttribute_rec.object_name
     AND table_id = -11803 and
     org_id=l_RuleAttribute_rec.org_id;

   SELECT cn_attribute_rules_s.NEXTVAL
     INTO l_ruleattribute_rec_pvt.attribute_rule_id
     FROM dual;

   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_ruleattribute_rec.ruleset_name
     AND start_date = l_ruleattribute_rec.start_date
     AND end_date = l_ruleattribute_rec.end_date
     and org_id=l_RuleAttribute_rec.org_id;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULESET');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      SELECT ruleset_id
	INTO l_ruleattribute_rec_pvt.ruleset_id
	FROM cn_rulesets
	WHERE name = l_ruleattribute_rec.ruleset_name
	AND start_date = l_ruleattribute_rec.start_date
	AND end_date = l_ruleattribute_rec.end_date and
	org_id=l_RuleAttribute_rec.org_id;
   END IF;

   l_ruleattribute_rec_pvt.object_name := l_ruleattribute_rec.object_name;
   l_ruleattribute_rec_pvt.not_flag := l_ruleattribute_rec.not_flag;
   l_ruleattribute_rec_pvt.value_1 := l_ruleattribute_rec.value_1;
   l_ruleattribute_rec_pvt.value_2 := l_ruleattribute_rec.value_2;
   l_ruleattribute_rec_pvt.data_flag := l_ruleattribute_rec.data_flag;
   l_ruleattribute_rec_pvt.org_id := l_RuleAttribute_rec.org_id;

   FOR i IN get_rules(l_ruleattribute_rec_pvt.ruleset_id,l_ruleattribute_rec_pvt.org_id)
     LOOP
	l_ruleattribute_rec_pvt.rule_id := i.rule_id;

	cn_ruleattribute_pvt.create_ruleattribute
	  (p_api_version           	=> p_api_version,
	   p_init_msg_list              => p_init_msg_list,
	   p_commit	    		=> p_commit,
	   p_validation_level     	=> p_validation_level,
	   x_return_status		=> x_return_status,
	   x_msg_count		        => x_msg_count,
	   x_msg_data		        => x_msg_data,
	   x_loading_status             => x_loading_status,
	   p_ruleattribute_rec          => l_ruleattribute_rec_pvt);

	IF x_return_status = fnd_api.g_ret_sts_error
	  THEN
	   RAISE fnd_api.g_exc_error;
	 ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
	   THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
     END LOOP;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --

   -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'CREATE_RULEATTRIBUTE',
				'A',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.create_ruleattribute_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'CREATE_RULEATTRIBUTE',
				'A',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.create_ruleattribute_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- Message generation section.
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'CREATE_RULEATTRIBUTE',
				'M',
				'M')
     THEN
      IF  cn_ruleattribute_pub_cuhk.ok_to_generate_msg
	 (p_ruleattribute_rec => l_ruleattribute_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULESET_NAME', l_ruleattribute_rec.ruleset_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULESET_NAME', l_ruleattribute_rec.ruleset_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'CRT_RUAT',
	    p_action_code  => 'I',
	    p_bind_data_id => l_bind_data_id,
	    x_return_code  => l_return_code) ;

	 IF (l_return_code = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

/*
	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'CRT_RUAT',
	    p_bus_obj_name => 'RATTR',
	    p_action_code  => 'I',
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
*/

      END IF;
   END IF;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data
      );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_RuleAttribute;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data,
		 p_encoded              =>      fnd_api.g_false
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_RuleAttribute;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_loading_status := 'UNEXPECTED_ERR';
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data,
		 p_encoded              =>      fnd_api.g_false
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_RuleAttribute;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_loading_status := 'UNEXPECTED_ERR';
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data,
		 p_encoded              =>      fnd_api.g_false
    		);
END Create_RuleAttribute;



-- Start of comments
--	API name 	: Update_RuleAttribute
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
--				p_rule_rec_type      IN
--						  CN_RuleAttribute_PUB.rule_rec_type
--                              p_RuleAttribute_rec_type IN
--					CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: Note text
--
-- End of comments


PROCEDURE Update_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type,
  p_RuleAttribute_rec       	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
) IS

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_RuleAttribute';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_ruleattribute_rec_pvt          cn_ruleattribute_pvt.ruleattribute_rec_type;
       l_old_ruleattribute_rec_pvt      cn_ruleattribute_pvt.ruleattribute_rec_type;
       l_object_id                      cn_objects.object_id%TYPE;
       l_old_object_id                  cn_objects.object_id%TYPE;
       l_count                          NUMBER;

      --
      --Declaration for user hooks
      --
      l_OAI_array		        JTF_USR_HKS.oai_data_array_type;
      l_old_RuleAttribute_rec           CN_RuleAttribute_PUB.RuleAttribute_rec_type;
      l_RuleAttribute_rec   	        CN_RuleAttribute_PUB.RuleAttribute_rec_type;
      l_bind_data_id                    NUMBER;
      l_return_code                     VARCHAR2(1);


       CURSOR get_rules(p_ruleset_id  IN cn_rulesets.ruleset_id%TYPE,
			p_rule_name   IN cn_rules.name%TYPE,
			p_org_id IN cn_rules.org_id%TYPE) IS
     SELECT rule_id
       FROM cn_rules
       WHERE ruleset_id = p_ruleset_id
       AND name = p_rule_name and
       org_id=p_org_id;

	CURSOR get_attribute_rules(p_rule_id IN cn_rules.rule_id%TYPE,
						  p_column_id IN
						  cn_attribute_rules.column_id%TYPE,
				   p_org_id IN cn_rules.org_id%TYPE) IS
	SELECT attribute_rule_id
	  FROM cn_attribute_rules
	  WHERE rule_id = p_rule_id
	  AND column_id = p_column_id and
	  org_id=p_org_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_RuleAttribute;
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


   --
   -- Assign the parameter to a local variable
   --
   l_old_RuleAttribute_rec := p_old_RuleAttribute_rec;
   l_RuleAttribute_rec     := p_RuleAttribute_rec;


   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'UPDATE_RULEATTRIBUTE',
				'B',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.update_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec,
      p_old_RuleAttribute_rec   => l_old_RuleAttribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'UPDATE_RULEATTRIBUTE',
				'B',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.update_ruleattribute_pre
    (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec,
      p_old_RuleAttribute_rec   => l_old_RuleAttribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;



   --
   -- API body
   --

   --Check for missing parameters in the p_rule_rec parameter
   IF (cn_api.chk_miss_null_char_para
       ( l_old_RuleAttribute_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_old_RuleAttribute_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_old_RuleAttribute_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( l_old_RuleAttribute_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_old_RuleAttribute_rec.object_name,
	 cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_old_RuleAttribute_rec.data_flag,
	 cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  --New parameters
   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.object_name,
	 cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.data_flag,
	 cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- l_old_ruleattribute_rec.object_name := p_old_ruleattribute_rec.object_name;
   SELECT object_id
     INTO l_old_object_id
     FROM cn_objects
     WHERE name = l_old_RuleAttribute_rec.object_name
     AND table_id = -11803;

   -- l_ruleattribute_rec.object_name := l_ruleattribute_rec.object_name;
   SELECT object_id
     INTO l_object_id
     FROM cn_objects
     WHERE name = l_RuleAttribute_rec.object_name
     AND table_id = -11803;

   l_count := 0;

   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_ruleattribute_rec.ruleset_name
     AND start_date = l_ruleattribute_rec.start_date
     AND end_date = l_ruleattribute_rec.end_date;

   IF l_count <> 1
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULESET');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      SELECT ruleset_id
	INTO l_ruleattribute_rec_pvt.ruleset_id
	FROM cn_rulesets
	WHERE name = l_ruleattribute_rec.ruleset_name
	AND start_date = l_ruleattribute_rec.start_date
	AND end_date = l_ruleattribute_rec.end_date;
   END IF;

   l_count := 0;

   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_old_ruleattribute_rec.ruleset_name
     AND start_date = l_old_ruleattribute_rec.start_date
     AND end_date = l_old_ruleattribute_rec.end_date;

   IF l_count <> 1
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULESET');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      SELECT ruleset_id
	INTO l_old_ruleattribute_rec_pvt.ruleset_id
	FROM cn_rulesets
	WHERE name = l_old_ruleattribute_rec.ruleset_name
	AND start_date = l_old_ruleattribute_rec.start_date
	AND end_date = l_old_ruleattribute_rec.end_date and
	org_id=l_old_ruleattribute_rec.org_id;
   END IF;

   l_ruleattribute_rec_pvt.object_name := l_ruleattribute_rec.object_name;
   l_ruleattribute_rec_pvt.org_id := l_ruleattribute_rec.org_id;
   l_old_ruleattribute_rec_pvt.object_name := l_old_ruleattribute_rec.object_name;
   l_old_ruleattribute_rec_pvt.not_flag := l_old_ruleattribute_rec.not_flag;
   l_old_ruleattribute_rec_pvt.value_1 := l_old_ruleattribute_rec.value_1;
   l_old_ruleattribute_rec_pvt.value_2 := l_old_ruleattribute_rec.value_2;
   l_old_ruleattribute_rec_pvt.data_flag := l_old_ruleattribute_rec.data_flag;
   l_old_ruleattribute_rec_pvt.org_id := l_old_ruleattribute_rec.org_id;

   l_ruleattribute_rec_pvt.not_flag := l_ruleattribute_rec.not_flag;
   l_ruleattribute_rec_pvt.value_1 := l_ruleattribute_rec.value_1;
   l_ruleattribute_rec_pvt.value_2 := l_ruleattribute_rec.value_2;
   l_ruleattribute_rec_pvt.data_flag := l_ruleattribute_rec.data_flag;


     FOR i IN get_rules(l_ruleattribute_rec_pvt.ruleset_id,
			l_old_ruleattribute_rec.rule_name,
			l_old_ruleattribute_rec.org_id)
     LOOP

	l_ruleattribute_rec_pvt.rule_id := i.rule_id;
	l_old_ruleattribute_rec_pvt.rule_id := i.rule_id;

     -- Fixed  code based on bug# 1320242 as the update record was
	-- giving error as multiple records are found with a single select below

	/*
	SELECT attribute_rule_id
	  INTO l_ruleattribute_rec_pvt.attribute_rule_id
	  FROM cn_attribute_rules
	  WHERE rule_id = i.rule_id
	  AND column_id = l_object_id;

	SELECT attribute_rule_id
	  INTO l_old_ruleattribute_rec_pvt.attribute_rule_id
	  FROM cn_attribute_rules
	  WHERE rule_id = i.rule_id
	  AND column_id = l_old_object_id;
     */

	FOR j IN get_attribute_rules(i.rule_id, l_old_object_id,l_old_ruleattribute_rec.org_id)
	LOOP
	  l_ruleattribute_rec_pvt.attribute_rule_id := j.attribute_rule_id;
	  l_old_ruleattribute_rec_pvt.attribute_rule_id := j.attribute_rule_id;

	cn_ruleattribute_pvt.update_ruleattribute
	  (p_api_version           	=> p_api_version,
	   p_init_msg_list              => p_init_msg_list,
	   p_commit	    		=> p_commit,
	   p_validation_level     	=> p_validation_level,
	   x_return_status		=> x_return_status,
	   x_msg_count		        => x_msg_count,
	   x_msg_data		        => x_msg_data,
	   x_loading_status             => x_loading_status,
	   p_ruleattribute_rec          => l_ruleattribute_rec_pvt,
	   p_old_ruleattribute_rec      => l_old_ruleattribute_rec_pvt);

	IF x_return_status = fnd_api.g_ret_sts_error
	  THEN
	   RAISE fnd_api.g_exc_error;
	 ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
	   THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	END LOOP;
     END LOOP;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --

   -- SK Start of post processing hooks

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'UPDATE_RULEATTRIBUTE',
				'A',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.update_ruleattribute_post
    (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec,
      p_old_RuleAttribute_rec   => l_old_RuleAttribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;


   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'UPDATE_RULEATTRIBUTE',
				'A',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.update_ruleattribute_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec,
      p_old_RuleAttribute_rec   => l_old_RuleAttribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;
   -- SK End of post processing hooks


   -- Message generation section.
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'UPDATE_RULEATTRIBUTE',
				'M',
				'M')
     THEN
      IF  cn_ruleattribute_pub_cuhk.ok_to_generate_msg
	 (p_ruleattribute_rec     => l_ruleattribute_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULESET_NAME', l_ruleattribute_rec.ruleset_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULESET_NAME', l_ruleattribute_rec.ruleset_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'UPD_RUAT',
	    p_action_code  => 'U',
	    p_bind_data_id => l_bind_data_id,
	    x_return_code  => l_return_code) ;

	 IF (l_return_code = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

/*
	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'UPD_RUAT',
	    p_bus_obj_name => 'RATTR',
	    p_action_code  => 'I',
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
*/
      END IF;
   END IF;


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_RuleAttribute;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_RuleAttribute;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_RuleAttribute;
      x_loading_status := 'UNEXPECTED_ERR';
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
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );

END;

-- Start of comments
--	API name 	: Delete_RuleAttribute
--	Type		: Public
--	Function	: This Public API can be used to delete a rule or
--			  it's attributes from Oracle Sales Compensation.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_rule_rec_type      IN
--						  CN_RuleAttribute_PUB.rule_rec_type
--                              p_rule_attr_rec_type IN
--					CN_RuleAttribute_PUB.rule_attr_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: This can be used to delete rules (and thus
--			  their rule attributes).
--			  Mandatory parameters are ruleset id, rule id
--			  and attribute_rule_id
--
-- End of comments


PROCEDURE Delete_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_ruleattribute_rec   	IN	CN_RuleAttribute_PUB.ruleattribute_rec_type
) IS


  l_api_name			CONSTANT VARCHAR2(30)	:= 'Delete_RuleAttribute';
  l_api_version           	CONSTANT NUMBER 	:= 1.0;
  l_ruleattribute_rec_pvt	        cn_ruleattribute_pvt.ruleattribute_rec_type;
  l_count                       NUMBER;
  l_object_id                   cn_objects.object_id%TYPE;

  CURSOR get_rules
    (p_ruleset_id IN cn_rulesets.ruleset_id%TYPE,
     p_rule_name   IN cn_rules.name%TYPE,
     p_org_id      IN cn_rules.org_id%TYPE) IS
	SELECT rule_id
	  FROM cn_rules
	  WHERE ruleset_id = p_ruleset_id
	  AND name = p_rule_name
	  AND org_id = p_org_id;

	CURSOR get_attribute_rules(p_rule_id IN cn_rules.rule_id%TYPE,
				   p_column_id IN cn_attribute_rules.column_id%TYPE,
				   p_org_id IN cn_rules.org_id%TYPE) IS
	SELECT attribute_rule_id,object_version_number
	  FROM cn_attribute_rules
	  WHERE rule_id = p_rule_id
	  AND column_id = p_column_id
	  AND org_id = p_org_id;
     --
     -- Declaration for user hooks
     --
     l_OAI_array	    JTF_USR_HKS.oai_data_array_type;
     l_ruleattribute_rec    CN_RuleAttribute_PUB.RuleAttribute_rec_type;
     l_bind_data_id         NUMBER;
     l_return_code          VARCHAR2(1);


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_RuleAttribute;
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
   -- Assign the parameter to a local variable
   --
   l_ruleattribute_rec := p_ruleattribute_rec;


   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'DELETE_RULEATTRIBUTE',
				'B',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.delete_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'DELETE_RULEATTRIBUTE',
				'B',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.delete_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;


  --
  -- API body
  --

   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_date_para
       ( l_RuleAttribute_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( l_RuleAttribute_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.object_name,
	 cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( l_RuleAttribute_rec.data_flag,
	 cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- l_ruleattribute_rec.object_name := p_ruleattribute_rec.object_name;
   SELECT object_id
     INTO l_object_id
     FROM cn_objects
     WHERE name = l_RuleAttribute_rec.object_name
     AND table_id = -11803
     and org_id = l_RuleAttribute_rec.org_id;

   l_count := 0;

   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_ruleattribute_rec.ruleset_name
     AND start_date = l_ruleattribute_rec.start_date
     AND end_date = l_ruleattribute_rec.end_date;

   IF l_count <> 1
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULESET');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      SELECT ruleset_id
	INTO l_ruleattribute_rec_pvt.ruleset_id
	FROM cn_rulesets
	WHERE name = l_ruleattribute_rec.ruleset_name
	AND start_date = l_ruleattribute_rec.start_date
	AND end_date = l_ruleattribute_rec.end_date;
   END IF;

   l_ruleattribute_rec_pvt.not_flag := l_ruleattribute_rec.not_flag;
   l_ruleattribute_rec_pvt.value_1 := l_ruleattribute_rec.value_1;
   l_ruleattribute_rec_pvt.value_2 := l_ruleattribute_rec.value_2;
   l_ruleattribute_rec_pvt.data_flag := l_ruleattribute_rec.data_flag;
   l_ruleattribute_rec_pvt.org_id := l_ruleattribute_rec.org_id;


     FOR i IN get_rules(l_ruleattribute_rec_pvt.ruleset_id,
			l_ruleattribute_rec.rule_name,
			l_ruleattribute_rec.org_id)
     LOOP
	l_ruleattribute_rec_pvt.rule_id := i.rule_id;

     -- Fixed  code based on bug# 1320242 as the update record was
	-- giving error as multiple records are found with a single select below

     /*
	SELECT attribute_rule_id
	  INTO l_ruleattribute_rec_pvt.attribute_rule_id
	  FROM cn_attribute_rules
	  WHERE rule_id = i.rule_id
	  AND column_id = l_object_id;
	  */

	FOR j IN get_attribute_rules(i.rule_id, l_object_id,l_ruleattribute_rec_pvt.org_id)
	LOOP
	   l_ruleattribute_rec_pvt.attribute_rule_id := j.attribute_rule_id;
           l_ruleattribute_rec_pvt.object_version_number := j.object_version_number;
	cn_ruleattribute_pvt.delete_ruleattribute
	  (p_api_version           	=> p_api_version,
	   p_init_msg_list              => p_init_msg_list,
	   p_commit	    		=> p_commit,
	   p_validation_level     	=> p_validation_level,
	   x_return_status		=> x_return_status,
	   x_msg_count		        => x_msg_count,
	   x_msg_data		        => x_msg_data,
	   x_loading_status             => x_loading_status,
	   p_ruleset_id                 => l_ruleattribute_rec_pvt.ruleset_id,
	   p_rule_id                    => l_ruleattribute_rec_pvt.rule_id,
	   p_object_version_number      => l_ruleattribute_rec_pvt.object_version_number,
	   p_attribute_rule_id          => l_ruleattribute_rec_pvt.attribute_rule_id);

	IF x_return_status = fnd_api.g_ret_sts_error
	  THEN
	   RAISE fnd_api.g_exc_error;
	 ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
	   THEN
	   RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	END LOOP;
     END LOOP;

  --
  -- End of API body.
  --


  --
  -- Post processing hooks
  --

  -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'DELETE_RULEATTRIBUTE',
				'A',
				'V')
   THEN
     cn_ruleattribute_pub_vuhk.delete_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'DELETE_RULEATTRIBUTE',
				'A',
				'C')
   THEN
     cn_ruleattribute_pub_cuhk.delete_ruleattribute_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleattribute_rec       => l_ruleattribute_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- Message generation section.
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULEATTRIBUTE_PUB',
				'DELETE_RULEATTRIBUTE',
				'M',
				'M')
     THEN
      IF  cn_ruleattribute_pub_cuhk.ok_to_generate_msg
	 (p_ruleattribute_rec => l_ruleattribute_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULESET_NAME', l_ruleattribute_rec.ruleset_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULESET_NAME', l_ruleattribute_rec.ruleset_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'DEL_RUAT',
	    p_action_code  => 'D',
	    p_bind_data_id => l_bind_data_id,
	    x_return_code  => l_return_code) ;

	 IF (l_return_code = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

/*
	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'DEL_RUAT',
	    p_bus_obj_name => 'RATTR',
	    p_action_code  => 'I',
	    p_oai_param    => null,
	    p_oai_array    => l_oai_array,
	    x_return_code  => x_return_status) ;

	 IF (x_return_status = FND_API.G_RET_STS_ERROR)
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
*/
      END IF;
   END IF;


  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
    	(p_count         	=>      x_msg_count,
         p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Delete_RuleAttribute;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Delete_RuleAttribute;
		x_loading_status := 'UNEXPECTED_ERR';
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data,
	      p_encoded          =>      fnd_api.g_false
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Delete_RuleAttribute;
		x_loading_status := 'UNEXPECTED_ERR';
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
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data,
	      p_encoded          =>      fnd_api.g_false
    		);
END;
END CN_RuleAttribute_PUB;

/
