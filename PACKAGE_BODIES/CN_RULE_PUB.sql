--------------------------------------------------------
--  DDL for Package Body CN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULE_PUB" AS
--$Header: cnpruleb.pls 120.2 2005/08/25 23:37:44 rramakri noship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_Rule_PUB';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;



-- Start of comments
--	API name 	: Create_Rule
--	Type		: Public
--	Function	: This Public API can be used to create a rule
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_rule_rec      IN
--						  CN_Rule_PUB.rule_rec_type
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

PROCEDURE Create_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_rule_rec			IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
    )
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Rule';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_count                    NUMBER;
--SK     l_rule_rec             cn_rule_pvt.rule_rec_type;
     l_rule_rec_pvt             cn_rule_pvt.rule_rec_type;
     l_bind_data_id             NUMBER;
     l_return_code              VARCHAR2(1);


     --
     -- Declaration for user hooks
     --
     l_OAI_array	    JTF_USR_HKS.oai_data_array_type;
     l_rule_rec             CN_Rule_PUB.rule_rec_type;

     l_rule_id              cn_rules.rule_id%TYPE;

     CURSOR parent_rules
       (p_ruleset_id NUMBER,
	p_rule_name cn_rules.name%TYPE,p_org_id cn_rules.org_id%TYPE )IS
	SELECT rule_id
	  FROM cn_rules
	  WHERE ruleset_id = p_ruleset_id
	  AND name = p_rule_name
	  AND ORG_ID=p_org_id;

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_Rule;

   --
   -- Standard call to check for call compatibility.
   --
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
   l_rule_rec := p_rule_rec;

   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'CREATE_RULE',
				'B',
				'C')
   THEN
     cn_rule_pub_cuhk.create_rule_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'CREATE_RULE',
				'B',
				'V')
   THEN
     cn_rule_pub_vuhk.create_rule_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec);

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

   --Check for null and missing parameters in the p_rule_rec parameter

   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     ( l_rule_rec.end_date,
       cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
       x_loading_status,
       x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     (l_rule_rec.start_date,
      cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
      x_loading_status,
      x_loading_status)= fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.parent_rule_name,
	 cn_api.get_lkup_meaning('PARENT_RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --Now check if the ruleset exists.
   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_rule_rec.ruleset_name
     AND start_date = l_rule_rec.start_date
     AND end_date = l_rule_rec.end_date and
     org_id=l_rule_rec.org_id;

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
	INTO l_rule_rec_pvt.ruleset_id
	FROM cn_rulesets
	WHERE name = l_rule_rec.ruleset_name
	AND start_date = l_rule_rec.start_date
	AND end_date = l_rule_rec.end_date and
	org_id=l_rule_rec.org_id;
   END IF;

   IF l_rule_rec.revenue_class_name IS NOT NULL
     THEN

     --Now check if the revenue class exists.

   SELECT count(1)
     INTO l_count
     FROM cn_revenue_classes
     WHERE name = l_rule_rec.revenue_class_name;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_REVENUE_CLASS');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_REVENUE_CLASS';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      SELECT revenue_class_id
	INTO l_rule_rec_pvt.revenue_class_id
	FROM cn_revenue_classes
	WHERE name = l_rule_rec.revenue_class_name;
   END IF;
   END IF;

   -- Check if expense account is valid
   IF l_rule_rec.expense_ccid IS NOT NULL
     THEN

   SELECT count(1)
     INTO l_count
     FROM gl_code_combinations
     WHERE code_combination_id = l_rule_rec.expense_ccid;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_EXPENSE_AC');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_EXPENSE_AC';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_rule_rec_pvt.expense_ccid := l_rule_rec.expense_ccid;
    END IF;
   END IF;

   -- Check if liability account is valid
   IF l_rule_rec.liability_ccid IS NOT NULL
     THEN

   SELECT count(1)
     INTO l_count
     FROM gl_code_combinations
     WHERE code_combination_id = l_rule_rec.liability_ccid;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_LIABILITY_AC');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_LIABILITY_AC';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_rule_rec_pvt.liability_ccid := l_rule_rec.liability_ccid;
    END IF;
   END IF;

   l_rule_rec_pvt.ORG_ID:=l_rule_rec.ORG_ID;
   --Validate the parent rule
   SELECT count(1)
     INTO l_count
     FROM cn_rules
     WHERE name = l_rule_rec.parent_rule_name
     AND ruleset_id = l_rule_rec_pvt.ruleset_id
     AND ORG_ID=l_rule_rec_pvt.ORG_ID;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_PARENT_RULE');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_PARENT_RULE';
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   l_rule_rec_pvt.rule_name := l_rule_rec.rule_name;

   FOR i IN parent_rules(l_rule_rec_pvt.ruleset_id,
			 l_rule_rec.parent_rule_name,
			 l_rule_rec.org_id)
     LOOP

      l_rule_rec_pvt.parent_rule_id := i.rule_id;

      select cn_rules_s.nextval
        into l_rule_rec_pvt.rule_id
        from dual;

      SELECT Nvl(MAX(sequence_number) + 1, 1)
	INTO l_rule_rec_pvt.sequence_number
	FROM cn_rules_hierarchy
	WHERE ruleset_id = l_rule_rec_pvt.ruleset_id
	AND parent_rule_id = l_rule_rec_pvt.parent_rule_id and
	org_id=l_rule_rec_pvt.org_id;

      cn_rule_pvt.create_rule
	(p_api_version           	=> p_api_version,
	 p_init_msg_list                => p_init_msg_list,
	 p_commit	    		=> p_commit,
	 p_validation_level     	=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count		        => x_msg_count,
	 x_msg_data		        => x_msg_data,
	 x_loading_status               => x_loading_status,
	 x_rule_id                      => l_rule_id,
	 p_rule_rec                     => l_rule_rec_pvt);


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
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'CREATE_RULE',
				'A',
				'V')
   THEN
     cn_rule_pub_vuhk.create_rule_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'CREATE_RULE',
				'A',
				'C')
   THEN
     cn_rule_pub_cuhk.create_rule_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec);

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
   IF JTF_USR_HKS.Ok_to_execute('CN_RULE_PUB',
				'CREATE_RULE',
				'M',
				'M')
     THEN
      IF  cn_rule_pub_cuhk.ok_to_generate_msg
--	 (p_rule_rec => l_rule_rec)
        (p_rule_name => l_rule_rec.rule_name)

	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULE_NAME', l_rule_rec.rule_name);


         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULE_NAME', l_rule_rec.rule_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'CRT_RULE',
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
	    p_bus_obj_code => 'CRT_RULE',
	    p_bus_obj_name => 'RULE',
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
      ROLLBACK TO Create_Rule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF 	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
END Create_Rule;

-- Start of comments
--	API name 	: Update_Rule
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
--						  CN_Rule_PUB.rule_rec_type
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


PROCEDURE Update_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_rule_rec		IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type,
    p_rule_rec			IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
    ) IS

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Rule';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_count                           NUMBER;
       l_rule_rec_pvt                    cn_rule_pvt.rule_rec_type;
       l_old_rule_rec_pvt                cn_rule_pvt.rule_rec_type;



   --
   --Declaration for user hooks
   --
   l_OAI_array		        JTF_USR_HKS.oai_data_array_type;
   l_old_rule_rec		CN_Rule_PUB.rule_rec_type;
   l_rule_rec			CN_Rule_PUB.rule_rec_type;
   l_bind_data_id               NUMBER;
   l_return_code                VARCHAR2(1);


       CURSOR get_rules(p_ruleset_id cn_rulesets.ruleset_id%TYPE,p_org_id cn_rulesets.org_id%TYPE) IS
	  SELECT cnrv.rule_id, cnrv.parent_rule_id
	    FROM cn_rules_v cnrv, cn_rules cnr1, cn_rules cnr2
	    WHERE cnr1.name = l_old_rule_rec.rule_name
	    AND cnr2.name = l_old_rule_rec.parent_rule_name
	    AND cnr1.ruleset_id = p_ruleset_id
	    AND cnr2.ruleset_id = p_ruleset_id
	    AND cnr1.rule_id = cnrv.rule_id
	    AND cnr2.rule_id = cnrv.parent_rule_id
	    and cnrv.org_id =cnr1.org_id
	    and cnr1.org_id = cnr2.org_id
	    and cnrv.org_id = p_org_id;


       CURSOR parent_rules(p_ruleset_id cn_rulesets.ruleset_id%TYPE,p_org_id cn_rulesets.org_id%TYPE) IS
	  SELECT rule_id
	    FROM cn_rules
	    WHERE name = l_rule_rec.parent_rule_name
	    AND ruleset_id = p_ruleset_id
	    and org_id=p_org_id;


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_Rule;
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
   l_old_rule_rec := p_old_rule_rec;
   l_rule_rec     := p_rule_rec;


   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'UPDATE_RULE',
				'B',
				'C')
   THEN
     cn_rule_pub_cuhk.update_rule_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec,
      p_old_rule_rec            => l_old_rule_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'UPDATE_RULE',
				'B',
				'V')
   THEN
     cn_rule_pub_vuhk.update_rule_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec,
      p_old_rule_rec            => l_old_rule_rec);

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
       ( l_old_rule_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_date_para
       ( l_old_rule_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_date_para
       ( l_old_rule_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_old_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_old_rule_rec.parent_rule_name,
	 cn_api.get_lkup_meaning('PARENT_RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
      IF (cn_api.chk_miss_null_date_para
       ( l_old_rule_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_date_para
       ( l_old_rule_rec.end_date,
	 cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_rule_rec.parent_rule_name,
	 cn_api.get_lkup_meaning('PARENT_RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --Check if the old ruleset exists.
   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_old_rule_rec.ruleset_name
     AND start_date = l_old_rule_rec.start_date
     AND end_date = l_old_rule_rec.end_date;
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
      SELECT ruleset_id,org_id
	INTO l_old_rule_rec_pvt.ruleset_id,l_old_rule_rec_pvt.org_id
	FROM cn_rulesets
	WHERE name = l_old_rule_rec.ruleset_name
	AND start_date = l_old_rule_rec.start_date
	AND end_date = l_old_rule_rec.end_date;
   END IF;

   --Check if the new ruleset exists.
   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_rule_rec.ruleset_name
     AND start_date = l_rule_rec.start_date
     AND end_date = l_rule_rec.end_date;
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
      SELECT ruleset_id,org_id
	INTO l_rule_rec_pvt.ruleset_id,l_rule_rec_pvt.org_id
	FROM cn_rulesets
	WHERE name = l_rule_rec.ruleset_name
	AND start_date = l_rule_rec.start_date
	AND end_date = l_rule_rec.end_date;
   END IF;

   --Validate old parent rule
   SELECT count(1)
     INTO l_count
     FROM cn_rules
     WHERE name = l_old_rule_rec.parent_rule_name
     AND ruleset_id = l_old_rule_rec_pvt.ruleset_id and
     org_id=l_old_rule_rec_pvt.org_id;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULE');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULE';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Validate new parent rule
   SELECT count(1)
     INTO l_count
     FROM cn_rules
     WHERE name = l_rule_rec.parent_rule_name
     AND ruleset_id = l_rule_rec_pvt.ruleset_id
     and org_id=l_rule_rec_pvt.org_id;

   IF l_count = 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULE');
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULE';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_rule_rec.revenue_class_name IS NOT NULL
     THEN
      --Now check if the revenue class exists.

      SELECT count(1)
	INTO l_count
	FROM cn_revenue_classes
	WHERE name = l_rule_rec.revenue_class_name;

      IF l_count = 0
	THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_REVENUE_CLASS');
	    fnd_msg_pub.add;
	 END IF;
	 x_loading_status := 'CN_INVALID_REVENUE_CLASS';
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 SELECT revenue_class_id
	   INTO l_rule_rec_pvt.revenue_class_id
	   FROM cn_revenue_classes
	   WHERE name = l_rule_rec.revenue_class_name;
      END IF;
   END IF;

   IF l_rule_rec.expense_ccid IS NOT NULL
     THEN

      SELECT count(1)
	INTO l_count
	FROM gl_code_combinations
	WHERE code_combination_id = l_rule_rec.expense_ccid;

      IF l_count = 0
	THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_EXPENSE_CCID');
	    fnd_msg_pub.add;
	 END IF;
	 x_loading_status := 'CN_INVALID_EXPENSE_CCID';
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 l_rule_rec_pvt.expense_ccid := l_rule_rec.expense_ccid;
      END IF;
   END IF;

   IF l_rule_rec.liability_ccid IS NOT NULL
     THEN

      SELECT count(1)
	INTO l_count
	FROM gl_code_combinations
	WHERE code_combination_id = l_rule_rec.liability_ccid;

      IF l_count = 0
	THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_LIABILITY_CCID');
	    fnd_msg_pub.add;
	 END IF;
	 x_loading_status := 'CN_INVALID_LIABILITY_CCID';
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 l_rule_rec_pvt.liability_ccid := l_rule_rec.liability_ccid;
      END IF;
   END IF;

   l_old_rule_rec_pvt.rule_name := l_old_rule_rec.rule_name;
   l_rule_rec_pvt.rule_name := l_rule_rec.rule_name;

   FOR i IN get_rules(l_old_rule_rec_pvt.ruleset_id,l_old_rule_rec_pvt.org_id)
     LOOP
	l_rule_rec_pvt.rule_id := i.rule_id;
	l_old_rule_rec_pvt.rule_id := i.rule_id;
	l_old_rule_rec_pvt.parent_rule_id := i.parent_rule_id;


       	IF l_old_rule_rec.parent_rule_name <> l_rule_rec.parent_rule_name
	  THEN
	   FOR j IN parent_rules(l_rule_rec_pvt.ruleset_id,l_rule_rec_pvt.org_id)
	     LOOP
		l_rule_rec_pvt.parent_rule_id := j.rule_id;
		cn_rule_pvt.update_rule
		  (p_api_version           	=> p_api_version,
		   p_init_msg_list              => p_init_msg_list,
		   p_commit	    		=> p_commit,
		   p_validation_level     	=> p_validation_level,
		   x_return_status		=> x_return_status,
		   x_msg_count		        => x_msg_count,
		   x_msg_data		        => x_msg_data,
		   x_loading_status             => x_loading_status,
		   p_old_rule_rec               => l_old_rule_rec_pvt,
		   p_rule_rec                   => l_rule_rec_pvt);
		IF x_return_status = fnd_api.g_ret_sts_error
		  THEN
		   RAISE fnd_api.g_exc_error;
		 ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
		   THEN
		   RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	     END LOOP;
	 ELSE
	   l_rule_rec_pvt.parent_rule_id := i.parent_rule_id;
	   cn_rule_pvt.update_rule
	     (p_api_version           	=> p_api_version,
	      p_init_msg_list           => p_init_msg_list,
	      p_commit	    		=> p_commit,
	      p_validation_level     	=> p_validation_level,
	      x_return_status		=> x_return_status,
	      x_msg_count		=> x_msg_count,
	      x_msg_data		=> x_msg_data,
	      x_loading_status          => x_loading_status,
	      p_old_rule_rec            => l_old_rule_rec_pvt,
	      p_rule_rec                => l_rule_rec_pvt);
	   IF x_return_status = fnd_api.g_ret_sts_error
	     THEN
	      RAISE fnd_api.g_exc_error;
	    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
	      THEN
	      RAISE fnd_api.g_exc_unexpected_error;
	   END IF;
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
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'UPDATE_RULE',
				'A',
				'V')
   THEN
     cn_rule_pub_vuhk.update_rule_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec,
      p_old_rule_rec            => l_old_rule_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'UPDATE_RULE',
				'A',
				'C')
   THEN
     cn_rule_pub_cuhk.update_rule_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_rec                => l_rule_rec,
      p_old_rule_rec            => l_old_rule_rec);

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
   IF JTF_USR_HKS.Ok_to_execute('CN_RULE_PUB',
				'UPDATE_RULE',
				'M',
				'M')
     THEN
      IF  cn_rule_pub_cuhk.ok_to_generate_msg
--	 (p_rule_rec     => l_rule_rec)
         (p_rule_name => l_rule_rec.rule_name)
	THEN

	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULE_NAME', l_rule_rec.rule_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULE_NAME', l_rule_rec.rule_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'UPD_RULE',
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
	    p_bus_obj_code => 'UPD_RULE',
	    p_bus_obj_name => 'RULE',
	    p_action_code  => 'U',
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
      ROLLBACK TO Update_Rule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF 	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );

END;

-- Start of comments
--	API name 	: Delete_Rule
--	Type		: Private
--	Function	: This Public API can be used to delete a rule
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rule_id             IN NUMBER
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
--			  Mandatory parameter is rule id
--
-- End of comments


PROCEDURE Delete_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_rule_name			IN	cn_rules.name%TYPE,
    p_ruleset_name              IN      cn_rulesets.name%TYPE,
    p_ruleset_start_date        IN      cn_rulesets.start_date%TYPE,
    p_ruleset_end_date          IN      cn_rulesets.end_date%TYPE
    ) IS


       l_api_name		CONSTANT VARCHAR2(30)	:= 'Delete_Rule';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_count                           NUMBER;
       l_ruleset_id                      cn_rulesets.ruleset_id%TYPE;
       l_org_id                          cn_rulesets.org_id%TYPE;

       CURSOR get_rules(p_ruleset_id cn_rulesets.ruleset_id%TYPE,p_org_id cn_rulesets.org_id%TYPE) IS
	  SELECT rule_id
	    FROM cn_rules
	    WHERE ruleset_id = p_ruleset_id
	    AND name = p_rule_name AND
	    org_id=p_org_id;

       --
       --Declaration for user hooks
       --
       l_OAI_array		         JTF_USR_HKS.oai_data_array_type;
       l_rule_name	    	         cn_rules.name%TYPE;
       l_ruleset_name                    cn_rulesets.name%TYPE;
       l_ruleset_start_date              cn_rulesets.start_date%TYPE;
       l_ruleset_end_date                cn_rulesets.end_date%TYPE;
       l_bind_data_id                    NUMBER;
       l_return_code                     VARCHAR2(1);


BEGIN


   -- Standard Start of API savepoint
   SAVEPOINT Delete_Rule;
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
   x_loading_status := 'CN_DELETED';


   --
   -- Assign the parameter to a local variable
   --
   l_rule_name          := p_rule_name;
   l_ruleset_name       := p_ruleset_name;
   l_ruleset_start_date := p_ruleset_start_date;
   l_ruleset_end_date   := p_ruleset_end_date;

   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'DELETE_RULE',
				'B',
				'C')
   THEN
     cn_rule_pub_cuhk.delete_rule_pre
     (p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_name               => l_rule_name,
      p_ruleset_name            => l_ruleset_name,
      p_ruleset_start_date      => l_ruleset_start_date,
      p_ruleset_end_date        => l_ruleset_end_date);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'DELETE_RULE',
				'B',
				'V')
   THEN
     cn_rule_pub_vuhk.delete_rule_pre
     (p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_name               => l_rule_name,
      p_ruleset_name            => l_ruleset_name,
      p_ruleset_start_date      => l_ruleset_start_date,
      p_ruleset_end_date        => l_ruleset_end_date);

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
   SELECT COUNT(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_ruleset_name
     AND start_date = l_ruleset_start_date
     AND end_date = l_ruleset_end_date;

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
      SELECT ruleset_id,org_id
	INTO l_ruleset_id,l_org_id
	FROM cn_rulesets
	WHERE name = l_ruleset_name
	AND start_date = l_ruleset_start_date
	AND end_date = l_ruleset_end_date;
  END IF;


  FOR i IN get_rules(l_ruleset_id,l_org_id)
    LOOP
       cn_rule_pvt.delete_rule
	 (p_api_version         => p_api_version,
	  p_init_msg_list       => p_init_msg_list,
	  p_commit	    	=> p_commit,
	  p_validation_level    => p_validation_level,
	  x_return_status	=> x_return_status,
	  x_msg_count		=> x_msg_count,
	  x_msg_data		=> x_msg_data,
	  x_loading_status      => x_loading_status,
	  p_ruleset_id          => l_ruleset_id,
	  p_rule_id             => i.rule_id,
	  p_org_id              => l_org_id);
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
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'DELETE_RULE',
				'A',
				'V')
   THEN
     cn_rule_pub_vuhk.delete_rule_post
     (p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_name               => l_rule_name,
      p_ruleset_name            => l_ruleset_name,
      p_ruleset_start_date      => l_ruleset_start_date,
      p_ruleset_end_date        => l_ruleset_end_date);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULE_PUB',
				'DELETE_RULE',
				'A',
				'C')
   THEN
     cn_rule_pub_cuhk.delete_rule_post
     (p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_rule_name               => l_rule_name,
      p_ruleset_name            => l_ruleset_name,
      p_ruleset_start_date      => l_ruleset_start_date,
      p_ruleset_end_date        => l_ruleset_end_date);

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
   IF JTF_USR_HKS.Ok_to_execute('CN_RULE_PUB',
				'DELETE_RULE',
				'M',
				'M')
     THEN
      IF  cn_rule_pub_cuhk.ok_to_generate_msg
      	(p_rule_name          => l_rule_name)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULE_NAME', l_rule_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULE_NAME', l_rule_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'DEL_RULE',
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
	    p_bus_obj_code => 'DEL_RULE',
	    p_bus_obj_name => 'RULE',
	    p_action_code  => 'D',
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
      ROLLBACK TO Delete_Rule;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Rule;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF 	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME,	    l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data,
	 p_encoded              =>      fnd_api.g_false
	 );
END;

---------------------------+
--
-- This is called from RuleLOV.java to display the entire hierarchy for the given rule
--
---------------------------+

function getRuleHierStr (p_rule_id NUMBER, p_ruleset_id NUMBER) RETURN VARCHAR2 IS
 cursor c_rules is
  select distinct(name) ruleName
   from cn_rules
   where rule_id in (
    select PARENT_RULE_ID
    from cn_rules_hierarchy
    where ruleset_id = p_ruleset_id
    connect by prior PARENT_RULE_ID = rule_id
    start with rule_id = p_rule_id);

  cursor c_rule_name is
   select name
   from cn_rules
   where rule_id = p_rule_id;

    retStr VARCHAR2(30000);
    ruleName cn_rules.name%TYPE;
    i integer := 0;
begin
 open c_rule_name;
 fetch c_rule_name into ruleName;
 close c_rule_name;

 retStr := ruleName || ' (';
 for rule in c_rules loop
   IF rule.ruleName <> 'BASE_RULE' THEN
     IF i = 0 THEN
      retStr := retStr || rule.ruleName;
     ELSE
      retStr := retStr || ' -> ' || rule.ruleName;
     END IF;

     i := i + 1;
   end if;
 end loop;

 retStr := retStr || ')';

 IF i <= 0 THEN
  retStr := ruleName;
 END IF;

 return retStr;
end getRuleHierStr;


END CN_Rule_PUB;

/
