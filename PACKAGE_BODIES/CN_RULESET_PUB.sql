--------------------------------------------------------
--  DDL for Package Body CN_RULESET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULESET_PUB" AS
--$Header: cnprsetb.pls 120.1 2005/08/25 23:38:29 rramakri noship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_Ruleset_PUB';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;

-- Start of comments
--	API name 	: Create_Ruleset
--	Type		: Public
--	Function	: This public API can be used to create a ruleset
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_ruleset_rec      IN
--						  CN_Ruleset_PUB.ruleset_rec_type
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

PROCEDURE create_ruleset
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_ruleset_rec		IN      CN_Ruleset_PUB.ruleset_rec_type
    )
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Ruleset';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_error_status             NUMBER;
     l_error_parameter          VARCHAR2(30);
     l_count                    NUMBER;
--SK l_ruleset_rec              cn_ruleset_pvt.ruleset_rec_type;
     l_ruleset_rec_pvt          cn_ruleset_pvt.ruleset_rec_type;

   --
   -- Declaration for user hooks
   --
   l_ruleset_rec          CN_Ruleset_PUB.ruleset_rec_type;
   l_OAI_array	          JTF_USR_HKS.oai_data_array_type;
   l_bind_data_id         NUMBER;
   l_return_code          VARCHAR2(1);

   l_ruleset_id		  NUMBER;

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_Ruleset;

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

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';


   --
   -- Assign the parameter to a local variable
   --
   l_ruleset_rec := p_ruleset_rec;

   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'CREATE_RULESET',
				'B',
				'C')
   THEN
--SK   cn_ruleset_pvt.create_ruleset
     cn_ruleset_pub_cuhk.create_ruleset_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'CREATE_RULESET',
				'B',
				'V')
   THEN
--SK   cn_ruleset_pvt.create_ruleset
     cn_ruleset_pub_vuhk.create_ruleset_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec);

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

   --Check for missing parameters in the p_ruleset_rec parameter

   IF (cn_api.chk_miss_null_char_para
       ( l_ruleset_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_miss_null_char_para
       ( l_ruleset_rec.module_type,
	 cn_api.get_lkup_meaning('MODULE_TYPE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     ( l_ruleset_rec.end_date,
       cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
       x_loading_status,
       x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     (l_ruleset_rec.start_date,
      cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
      x_loading_status,
      x_loading_status)= fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --Now check if the ruleset exists.
   --If it does, then raise error
   --else use cn_rulesets_s.nextval
   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE name = l_ruleset_rec.ruleset_name
     AND module_type = (SELECT lookup_code
			FROM cn_lookups
			WHERE lookup_type = 'MODULE_TYPE'
			AND meaning = l_ruleset_rec.module_type)
     AND start_date = l_ruleset_rec.start_date
     AND end_date = l_ruleset_rec.end_date;

   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_RULESET_EXISTS');
	 fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_RULESET_EXISTS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   l_ruleset_rec_pvt.ruleset_name := p_ruleset_rec.ruleset_name;
   l_ruleset_rec_pvt.start_date   := p_ruleset_rec.start_date;
   l_ruleset_rec_pvt.end_date     := p_ruleset_rec.end_date;
   l_ruleset_rec_pvt.org_id       := p_ruleset_rec.org_id;

   SELECT lookup_code
     INTO l_ruleset_rec_pvt.module_type
     FROM cn_lookups
     WHERE lookup_type = 'MODULE_TYPE'
     AND meaning = l_ruleset_rec.module_type;

   cn_ruleset_pvt.create_ruleset
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      x_ruleset_id              => l_ruleset_id,
      p_ruleset_rec             => l_ruleset_rec_pvt);

   IF x_return_status = fnd_api.g_ret_sts_error
     THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --

   -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'CREATE_RULESET',
				'A',
				'V')
   THEN
--SK   cn_ruleset_pvt.create_ruleset
     cn_ruleset_pub_vuhk.create_ruleset_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'CREATE_RULESET',
				'A',
				'C')
   THEN
--SK   cn_ruleset_pvt.create_ruleset
     cn_ruleset_pub_cuhk.create_ruleset_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec);

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
   IF JTF_USR_HKS.Ok_to_execute('CN_RULESET_PUB',
				'CREATE_RULESET',
				'M',
				'M')
     THEN
      IF  cn_ruleset_pub_cuhk.ok_to_generate_msg
	 (p_ruleset_rec => l_ruleset_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULESET_NAME', l_ruleset_rec.ruleset_name);


         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULESET_NAME', l_ruleset_rec.ruleset_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'CRT_RSET',
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
	    p_bus_obj_code => 'CRT_RSET',
	    p_bus_obj_name => 'RULESET',
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


   --
   -- Standard call to get message count and if count is 1, get message info.
   --

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Ruleset;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Ruleset;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Ruleset;
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
END Create_Ruleset;

-- Start of comments
--	API name 	: Update_Ruleset
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
--				p_ruleset_rec_type      IN
--						  CN_Ruleset_PUB.ruleset_rec_type
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


PROCEDURE Update_Ruleset
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type,
    p_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type
    ) IS

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Ruleset';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_loading_status              VARCHAR2(4000);
       l_count                       NUMBER;
       l_old_ruleset_rec_pvt         cn_ruleset_pvt.ruleset_rec_type;
       l_ruleset_rec_pvt             cn_ruleset_pvt.ruleset_rec_type;

   --
   --Declaration for user hooks
   --
   l_OAI_array		        JTF_USR_HKS.oai_data_array_type;
   l_old_ruleset_rec		CN_Ruleset_PUB.ruleset_rec_type;
   l_ruleset_rec		CN_Ruleset_PUB.ruleset_rec_type;
   l_bind_data_id               NUMBER;
   l_return_code                VARCHAR2(1);


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_Ruleset;
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

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   --
   -- Assign the parameter to a local variable
   --
   l_old_ruleset_rec := p_old_ruleset_rec;
   l_ruleset_rec     := p_ruleset_rec;


   --
   -- User hooks
   --

   -- customer pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'UPDATE_RULESET',
				'B',
				'C')
   THEN
     cn_ruleset_pub_cuhk.update_ruleset_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec,
      p_old_ruleset_rec         => l_old_ruleset_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- vertical industry pre-processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'UPDATE_RULESET',
				'B',
				'V')
   THEN
     cn_ruleset_pub_vuhk.update_ruleset_pre
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec,
      p_old_ruleset_rec         => l_old_ruleset_rec);

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

   IF l_ruleset_rec.ruleset_name <> l_old_ruleset_rec.ruleset_name
     OR l_ruleset_rec.start_date <> l_old_ruleset_rec.start_date
     OR l_ruleset_rec.end_date <> l_old_ruleset_rec.end_date
     OR l_ruleset_rec.module_type <> l_old_ruleset_rec.module_type
     THEN
      --ruleset needs to be updated

      --Validate input parameters
      --Check for missing parameters in the p_ruleset_rec parameter

      IF (cn_api.chk_miss_null_char_para
	  ( l_old_ruleset_rec.ruleset_name,
	    cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	    x_loading_status,
	    x_loading_status) = FND_API.G_TRUE )
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	( l_old_ruleset_rec.end_date,
	  cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	  x_loading_status,
	  x_loading_status) = fnd_api.g_true
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	(l_old_ruleset_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status)= fnd_api.g_true
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;


      --Check for missing parameters in the p_ruleset_rec parameter

      IF (cn_api.chk_miss_null_char_para
	  ( l_ruleset_rec.ruleset_name,
	    cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	    x_loading_status,
	    x_loading_status) = FND_API.G_TRUE )
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	( l_ruleset_rec.end_date,
	  cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	  x_loading_status,
	  x_loading_status) = fnd_api.g_true
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	(l_ruleset_rec.start_date,
	 cn_api.get_lkup_meaning('START_DATE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status)= fnd_api.g_true
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;


      --Now check if the ruleset exists.
      --If it does, then raise error
      --else use cn_rulesets_s.nextval
      SELECT count(1)
	INTO l_count
	FROM cn_rulesets
	WHERE name = l_old_ruleset_rec.ruleset_name
	AND start_date = l_old_ruleset_rec.start_date
	AND end_date = l_old_ruleset_rec.end_date;

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
	   INTO l_old_ruleset_rec_pvt.ruleset_id
	   FROM cn_rulesets
	   WHERE name = l_old_ruleset_rec.ruleset_name
	   AND start_date = l_old_ruleset_rec.start_date
	   AND end_date = l_old_ruleset_rec.end_date;
      END IF;

      l_ruleset_rec_pvt.ruleset_id := l_old_ruleset_rec_pvt.ruleset_id;
      l_ruleset_rec_pvt.ruleset_name := p_ruleset_rec.ruleset_name;
      l_ruleset_rec_pvt.start_date   := p_ruleset_rec.start_date;
      l_ruleset_rec_pvt.end_date     := p_ruleset_rec.end_date;
      l_ruleset_rec_pvt.org_id     := p_ruleset_rec.org_id;
      SELECT lookup_code
	INTO l_ruleset_rec_pvt.module_type
	FROM cn_lookups
	WHERE lookup_type = 'MODULE_TYPE'
	AND meaning = p_ruleset_rec.module_type;

      l_old_ruleset_rec_pvt.ruleset_name := p_old_ruleset_rec.ruleset_name;
      l_old_ruleset_rec_pvt.start_date := p_old_ruleset_rec.start_date;
      l_old_ruleset_rec_pvt.end_date   := p_old_ruleset_rec.end_date;
      l_old_ruleset_rec_pvt.org_id   := p_old_ruleset_rec.org_id;

      SELECT lookup_code
	INTO l_old_ruleset_rec_pvt.module_type
	FROM cn_lookups
	WHERE lookup_type = 'MODULE_TYPE'
	AND meaning = p_old_ruleset_rec.module_type;

   cn_ruleset_pvt.update_ruleset
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec_pvt,
      p_old_ruleset_rec         => l_old_ruleset_rec_pvt);



   END IF;

   --
   -- End of API body.
   --


   --
   -- Post processing hooks
   --

   -- SK Start of post processing hooks

   -- vertical post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'UPDATE_RULESET',
				'A',
				'V')
   THEN
     cn_ruleset_pub_vuhk.update_ruleset_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec,
      p_old_ruleset_rec         => l_old_ruleset_rec);

     IF x_return_status = fnd_api.g_ret_sts_error
     THEN
       RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error
     THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;
   END IF;

   -- customer post processing section
   IF JTF_USR_HKS.Ok_to_Execute('CN_RULESET_PUB',
				'UPDATE_RULESET',
				'A',
				'C')
   THEN
     cn_ruleset_pub_cuhk.update_ruleset_post
     (p_api_version           	=> p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_commit	    		=> p_commit,
      p_validation_level	=> p_validation_level,
      x_return_status		=> x_return_status,
      x_msg_count		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      x_loading_status          => x_loading_status,
      p_ruleset_rec             => l_ruleset_rec,
      p_old_ruleset_rec         => l_old_ruleset_rec);

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
   IF JTF_USR_HKS.Ok_to_execute('CN_RULESET_PUB',
				'UPDATE_RULESET',
				'M',
				'M')
     THEN
      IF  cn_ruleset_pub_cuhk.ok_to_generate_msg
	 (p_ruleset_rec     => l_ruleset_rec)
	THEN
	 -- Clear bind variables
--	 XMLGEN.clearBindValues;

	 -- Set values for bind variables,
	 -- call this for all bind variables in the business object
--	 XMLGEN.setBindValue('RULESET_NAME', l_ruleset_rec.ruleset_name);

         -- get ID for all the bind_variables in a Business Object.
         l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

         JTF_USR_HKS.load_bind_data(l_bind_data_id, 'RULESET_NAME', l_ruleset_rec.ruleset_name, 'S', 'T');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'UPD_RSET',
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
	    p_bus_obj_code => 'UPD_RSET',
	    p_bus_obj_name => 'RULESET',
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
      ROLLBACK TO Update_Ruleset;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Ruleset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count         	=>      x_msg_count,
	 p_data          	=>      x_msg_data
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Ruleset;
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
	 p_data          	=>      x_msg_data
	 );

END;

END CN_Ruleset_PUB;

/
