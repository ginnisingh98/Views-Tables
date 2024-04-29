--------------------------------------------------------
--  DDL for Package Body CN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULE_PVT" AS
--$Header: cnvruleb.pls 120.5 2006/03/07 04:57:39 hanaraya ship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_Rule_PVT';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;
--+==========================================================================
--| Procedure : valid_Rule
--| Desc : Procedure to validate  Rules
--+==========================================================================
 PROCEDURE valid_Rule
  (
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER   ,
   x_msg_data               OUT NOCOPY VARCHAR2 ,
   p_rule_rec	            IN      CN_Rule_PVT.rule_rec_type,
   p_action                 IN VARCHAR2,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   )
  IS
     l_api_name      CONSTANT VARCHAR2(30) := 'valid_Rule';

    cursor get_rulesets_rec is
     select module_type
       from cn_rulesets
      where ruleset_id  = p_rule_rec.ruleset_id and
      org_id=p_rule_rec.org_id;

     l_ruleset_rec get_rulesets_rec%ROWTYPE;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   -- API body

   open get_rulesets_rec;
   fetch get_rulesets_rec into l_ruleset_rec;
   close get_rulesets_rec;

/*   if l_ruleset_rec.module_type = 'REVCLS' THEN

  IF p_rule_rec.revenue_class_id is NULL THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_INVALID_REVENUE_CLASS');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_INVALID_REVENUE_CLASS';
	 RAISE FND_API.G_EXC_ERROR ;
    END IF;
    null;
  else
      IF p_rule_rec.expense_ccid is NULL OR
         p_rule_rec.liability_ccid IS NULL  THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('CN', 'CN_INVALID_ACCOUNT_CODE');
 	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_INVALID_ACCOUNT_CODE';
	 RAISE FND_API.G_EXC_ERROR ;
     END IF;
  end if;
*/




  -- End of API body.
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END valid_rule;
--=============================================================================
-- Procedure : validate_rule_name
-- Desc      : Validates the rule name. The rule should be unique at
--		the sibling level and within the branch
--=============================================================================

FUNCTION validate_rule_name
  (p_ruleset_id     IN cn_rulesets.ruleset_id%TYPE,
   p_parent_rule_id IN cn_rules.rule_id%TYPE,
   p_rule_name      IN cn_rules.name%TYPE,
   p_org_id         IN cn_rules.org_id%TYPE,
   p_loading_status IN VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

      CURSOR check_siblings_cur IS
	 SELECT count(*) cnt
	   FROM cn_rules_hierarchy cnrh,
	   cn_rules cnr
	   WHERE cnrh.parent_rule_id = p_parent_rule_id
	   AND cnr.ruleset_id = p_ruleset_id
	   AND cnrh.rule_id = cnr.rule_id
	   AND cnr.name = p_rule_name
	   AND cnrh.org_id=cnr.org_id
	   AND cnr.org_id=p_org_id;

      l_check_siblings_rec check_siblings_cur%ROWTYPE;


      CURSOR check_parents_cur (p_parent_rule_id cn_rules.rule_id%TYPE)IS
	 SELECT cnrh.parent_rule_id,
	   cnr.name
	   FROM cn_rules_hierarchy cnrh,
	   cn_rules cnr
	   WHERE cnr.ruleset_id = p_ruleset_id
	   AND cnrh.rule_id = p_parent_rule_id
	   AND cnrh.rule_id = cnr.rule_id
           AND cnrh.org_id=cnr.org_id
	   AND cnr.org_id=p_org_id;

      l_check_parents_rec check_parents_cur%ROWTYPE;

      l_current_parent_rule_id  cn_rules_hierarchy.parent_rule_id%TYPE;

      l_api_name VARCHAR2(30) := 'validate_rule_name';

BEGIN

   x_loading_status := p_loading_status;

   OPEN check_siblings_cur;
   FETCH check_siblings_cur INTO l_check_siblings_rec;
   CLOSE check_siblings_cur;

   IF l_check_siblings_rec.cnt > 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_DUPLICATE_RULE_NAME');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_DUPLICATE_RULE_NAME';
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_current_parent_rule_id := p_parent_rule_id;
      WHILE l_current_parent_rule_id <> -1002
	LOOP
	   OPEN check_parents_cur(l_current_parent_rule_id);
	   FETCH check_parents_cur INTO l_check_parents_rec;
	   CLOSE check_parents_cur;
	   l_current_parent_rule_id := l_check_parents_rec.parent_rule_id;
	   IF l_check_parents_rec.name = p_rule_name
	     THEN
	      --Error condition
	      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		THEN
		 fnd_message.set_name('CN', 'CN_DUPLICATE_RULE_NAME');
		 fnd_msg_pub.add;
	      END IF;
	      x_loading_status := 'CN_DUPLICATE_RULE_NAME';
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END LOOP;
   END IF;
   RETURN fnd_api.g_false;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;
END;
--=============================================================================
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
--						  CN_Rule_PVT.rule_rec_type
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
---=============================================================================
PROCEDURE Create_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_rule_rec		 IN OUT NOCOPY      CN_Rule_PVT.rule_rec_type,
    x_rule_id		 OUT NOCOPY 	NUMBER
    )
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Rule';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_rowid			VARCHAR2(4000);
     l_sequence_number		NUMBER;
     l_count                    NUMBER;
     l_rule_id                  NUMBER;

     l_ruleset_status           VARCHAR2(100);

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Rule;
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

   --Check for null and missing parameters in the p_rule_rec parameter

   /* IF (cn_api.chk_null_num_para
       ( p_rule_rec.ruleset_id,
	 cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

    IF (cn_api.chk_null_num_para
       ( p_rule_rec.rule_id,
	 cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

  */

   IF (cn_api.chk_null_char_para
       ( p_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('PARENT_RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /* IF (cn_api.chk_null_num_para
       ( p_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('SEQUENCE_NUMBER', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
  */

   --Now check if the ruleset exists.
   SELECT count(1)
     INTO l_count
     FROM cn_rulesets
     WHERE ruleset_id = p_rule_rec.ruleset_id
     AND org_id= p_rule_rec.org_id;

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
   END IF;

   --Validate the parent rule
   SELECT count(1)
     INTO l_count
     FROM cn_rules
     WHERE rule_id = p_rule_rec.parent_rule_id and
     org_id=p_rule_rec.org_id;

   --Fetch rule_id into l_rule_id
   SELECT Decode(p_rule_rec.rule_id, NULL,cn_rules_s.NEXTVAL, p_rule_rec.rule_id)
     INTO l_rule_id
     FROM dual;

   --Since this is a new rule, validate the rule name before inserting
   IF validate_rule_name(p_rule_rec.ruleset_id,
			 p_rule_rec.parent_rule_id,
			 p_rule_rec.rule_name,
			 p_rule_rec.org_id,
			 x_loading_status,
			 x_loading_status) = fnd_api.g_true
     THEN
      --Error condition
      /*IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_RULE_NAME');
	 fnd_msg_pub.add;
      END IF;
       */
      x_loading_status := 'CN_INVALID_RULE_NAME';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_rule_rec.sequence_number IS NULL
     then
      SELECT nvl(MAX(nvl(sequence_number, 0)),0) + 1
	INTO l_sequence_number
	FROM cn_rules_hierarchy
	WHERE ruleset_id = p_rule_rec.ruleset_id;
    ELSE
      l_sequence_number := p_rule_rec.sequence_number;
   END IF;

   --
   -- Valid Validate Rule
   --
    valid_rule
     ( x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_rule_rec              => p_rule_rec,
       p_action                => 'CREATE',
       p_loading_status        => x_loading_status,
       x_loading_status        => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   cn_syin_rules_pkg.insert_row(l_rule_id,
			       p_rule_rec.rule_name,
			       p_rule_rec.ruleset_id,
			       p_rule_rec.revenue_class_id,
			       p_rule_rec.expense_ccid,
			       p_rule_rec.liability_ccid,
			       p_rule_rec.parent_rule_id,
			       l_sequence_number,
			       p_rule_rec.org_id);

  x_rule_id := l_rule_id;

  cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_rule_rec.ruleset_id,
                                 x_ruleset_status_in => l_ruleset_status,
				 x_org_id => p_rule_rec.org_id);

   -- End of API body.

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
--=============================================================================
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
--						  CN_Rule_PVT.rule_rec_type
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
--=============================================================================

PROCEDURE Update_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_rule_rec		IN  	CN_Rule_PVT.rule_rec_type,
    p_rule_rec		 IN OUT NOCOPY  CN_Rule_PVT.rule_rec_type
    ) IS

       l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_Rule';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_rowid			ROWID;
       l_sequence_number		NUMBER;
       l_count                       NUMBER;
       l_ruleset_status         VARCHAR2(100);
       l_object_version_number NUMBER;

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

   -- API body

     -- Check for object version number mismatch
   select object_version_number into l_object_version_number
   from cn_rules_all where rule_id = p_old_rule_rec.rule_id
   and org_id = p_old_rule_rec.org_id;

   if (l_object_version_number <> p_rule_rec.object_version_no) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;

   -- end Check for object version number mismatch



   --Check for missing parameters in the p_rule_rec parameter

   IF (cn_api.chk_null_num_para
       ( p_old_rule_rec.ruleset_id,
	 cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_old_rule_rec.rule_id,
	 cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_char_para
       ( p_old_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_old_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('PARENT_RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_old_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('SEQUENCE_NUMBER', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;



   IF (cn_api.chk_null_num_para
       ( p_rule_rec.ruleset_id,
	 cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_rule_rec.rule_id,
	 cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_char_para
       ( p_rule_rec.rule_name,
	 cn_api.get_lkup_meaning('RULE_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('PARENT_RULE_ID', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF (cn_api.chk_null_num_para
       ( p_rule_rec.parent_rule_id,
	 cn_api.get_lkup_meaning('SEQUENCE_NUMBER', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   IF p_rule_rec.ruleset_id <> p_old_rule_rec.ruleset_id
     THEN

      --Now check if the ruleset exists.
      SELECT count(1)
	INTO l_count
	FROM cn_rulesets
	WHERE ruleset_id = p_rule_rec.ruleset_id;

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
      END IF;

   END IF;

   IF p_rule_rec.parent_rule_id <> p_old_rule_rec.parent_rule_id
     THEN

      --Validate the parent rule
      SELECT count(1)
	INTO l_count
	FROM cn_rules
	WHERE rule_id = p_rule_rec.parent_rule_id and
	org_id=p_rule_rec.org_id;
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
   END IF;


   SELECT COUNT(1)
     INTO l_count
     FROM cn_rules
     WHERE rule_id = p_old_rule_rec.rule_id
     and org_id=p_rule_rec.org_id;
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


   IF p_rule_rec.rule_name <> p_old_rule_rec.rule_name
     THEN
      IF validate_rule_name(p_rule_rec.ruleset_id,
			    p_rule_rec.parent_rule_id,
			    p_rule_rec.rule_name,
			    p_rule_rec.org_id,
			    x_loading_status,
			    x_loading_status) = fnd_api.g_true
	THEN
         --Error condition
	 /* IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_RULE_NAME');
	    fnd_msg_pub.add;
	 END IF;
         */

	 x_loading_status := 'CN_INVALID_RULE_NAME';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --
   -- Validate RUle
   --
    valid_rule
     ( x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_rule_rec              => p_rule_rec,
       p_action                => 'CREATE',
       p_loading_status        => x_loading_status,
       x_loading_status        => x_loading_status
       );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS  ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   cn_syin_rules_pkg.update_row(p_old_rule_rec.rule_id,
			       p_rule_rec.ruleset_id,
			       null,
			       p_rule_rec.revenue_class_id,
			       p_rule_rec.expense_ccid,
			       p_rule_rec.liability_ccid,
			       p_rule_rec.rule_name,
			       Sysdate,
			       g_last_updated_by,
			       g_last_update_login,
			       p_rule_rec.org_id,
			       p_rule_rec.object_version_no);

  cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_rule_rec.ruleset_id,
                                 x_ruleset_status_in => l_ruleset_status,
                                  x_org_id => p_rule_rec.org_id);

   -- End of API body.

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
--=============================================================================
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
--=============================================================================
PROCEDURE Delete_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_rule_id			IN	cn_rules_all_b.rule_id%TYPE,
  p_ruleset_id                  IN      cn_rules_all_b.ruleset_id%TYPE,
  p_org_id                      IN      cn_rules_all_b.org_id%TYPE
) IS

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Delete_Rule';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_count                           NUMBER;
       l_ruleset_status         Varchar2(100);




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

   -- new API body
 SELECT  COUNT(1)
 INTO l_count
 FROM
 (     SELECT rule_id ,ruleset_id
       FROM cn_rules_hierarchy
       WHERE ruleset_id=Nvl(p_ruleset_id ,-1002) and org_id=p_org_id
       CONNECT BY PRIOR  rule_id =  parent_rule_id
       START WITH rule_id = Nvl(p_rule_id, -1002)
 )a WHERE EXISTS
  (SELECT 'x'
   FROM cn_attribute_rules car
   WHERE car.ruleset_id = a.ruleset_id
  AND   car.rule_id = a.rule_id and car.org_id=p_org_id);

  IF l_count <> 0
    THEN
     --Error condition
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
       THEN
	fnd_message.set_name('CN', 'CN_ATTRIBUTE_RULE_EXIST');
	fnd_msg_pub.add;
     END IF;

     x_loading_status := 'CN_ATTRIBUTE_RULE_EXIST';
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  SELECT COUNT(1)
    INTO l_count
    FROM cn_rules
    WHERE ruleset_id = p_ruleset_id
    AND rule_id = p_rule_id and
    org_id=p_org_id;

  IF l_count <> 1
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

  cn_syin_rules_pkg.delete_row(p_rule_id, p_ruleset_id,p_org_id);

  cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_ruleset_id,
                                 x_ruleset_status_in => l_ruleset_status,
				  x_org_id => p_org_id);


   -- End of API body.

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
-- =======================================================================
-- Procedure : Get_rules
-- Desc      : Get_rules
-- =======================================================================
   PROCEDURE  Get_rules
   ( p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2,
     p_commit                IN   VARCHAR2,
     p_validation_level      IN   NUMBER,
     x_return_status         OUT NOCOPY  VARCHAR2,
     x_msg_count             OUT NOCOPY  NUMBER,
     x_msg_data              OUT NOCOPY  VARCHAR2,
     p_ruleset_name          IN   cn_rulesets_all_tl.name%TYPE,
     p_start_record          IN   NUMBER,
     p_increment_count       IN   NUMBER,
     p_order_by              IN   VARCHAR2,
     x_rule_tbl 	     OUT NOCOPY  rule_tbl_type,
     x_total_records         OUT NOCOPY  NUMBER,
     x_status                OUT NOCOPY  VARCHAR2,
     x_loading_status        OUT NOCOPY  VARCHAR2,
     p_org_id                IN   cn_rulesets_all_tl.org_id%TYPE
     ) IS

     TYPE rulecurtype IS ref CURSOR;
     rule_cur rulecurtype;


     l_api_name         CONSTANT VARCHAR2(30)  := 'Get_Rule';
     l_api_version      CONSTANT NUMBER        := 1.0;



     l_ruleset_id          cn_rulesets.ruleset_id%TYPE;
     l_rule_id		   cn_rules.rule_id%TYPE;
     l_rule_name           cn_rules.name%TYPE;
     l_ruleset_name        cn_rulesets.name%TYPE;
     l_revenue_class_id    cn_rules.revenue_class_id%TYPE;
     l_expense_ccid        cn_rules.expense_ccid%TYPE;
     l_liability_ccid      cn_rules.liability_ccid%TYPE;
     l_org_id              cn_rules.org_id%TYPE;
     l_expense_ccid_disp   varchar2(2000);
     l_liability_ccid_disp varchar2(2000);
     l_revenue_class_name  cn_revenue_classes.name%TYPE;

     l_counter NUMBER;


     l_select varchar2(4000) :=
       'SELECT 	rset.ruleset_id ruleset_id,
                rset.name ruleset_name,
                rule.rule_id rule_id,
               	rule.name,
             	rule.revenue_class_id,
        	rule.expense_ccid,
           	rule.liability_id,
                rule.org_id
     FROM cn_rulesets rset, cn_rules rule
     WHERE rset.ruleset_id = rule.ruleset_id AND
     rset.org_id=rule.org_id AND
     rset.org_id=:B1  AND
     upper(rset.name)   like  upper(:B2) ';

  BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Get_Rules;
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                         p_api_version ,
                         l_api_name    ,
                         G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'SELECTED';
   --
   -- API body
   --
   l_counter       := 0;
   x_total_records := 0;

   OPEN rule_cur FOR l_select using p_org_id,p_ruleset_name;
   LOOP

      FETCH rule_cur INTO
       l_ruleset_id
      ,l_ruleset_name
      ,l_rule_id
      ,l_rule_name
      ,l_revenue_class_id
      ,l_expense_ccid
      ,l_liability_ccid
      ,l_org_id;

     EXIT WHEN rule_cur%notfound;

     x_total_records := x_total_records + 1;

     IF (l_counter + 1 BETWEEN p_start_record
         AND (p_start_record + p_increment_count - 1))
       THEN
         x_rule_tbl(l_counter).ruleset_id
         := l_ruleset_id;

         x_rule_tbl(l_counter).ruleset_name
         := l_ruleset_name;

         x_rule_tbl(l_counter).rule_id
         := l_rule_id;

         x_rule_tbl(l_counter).rule_name
         := l_rule_name;

         x_rule_tbl(l_counter).revenue_class_id
         := l_revenue_class_id;

         x_rule_tbl(l_counter).expense_ccid
         := l_expense_ccid;

         x_rule_tbl(l_counter).liability_ccid
         := l_liability_ccid;

         if l_revenue_class_id IS NOT NULL THEN
           cn_syin_rules_pkg.populate_fields
           (l_revenue_class_id,
            l_revenue_class_name,
	    l_org_id);
         end if;

         if l_liability_ccid IS NOT NULL
         then
          cn_api.get_ccid_disp(l_liability_ccid,
                         l_liability_ccid_disp,
			 l_org_id);

         end if;

         if l_expense_ccid IS NOT NULL
         then
          cn_api.get_ccid_disp(l_expense_ccid,
                         l_expense_ccid_disp,
			 l_org_id);
         end if;

          x_rule_tbl(l_counter).expense_desc
          :=  l_expense_ccid_disp;

          x_rule_tbl(l_counter).liability_desc
          :=  l_liability_ccid_disp;

          x_rule_tbl(l_counter).revenue_class_name
          :=  l_revenue_class_name;

     END IF;
     l_counter := l_counter + 1;

   END LOOP;
   CLOSE rule_cur;

   x_loading_status := 'SELECTED';

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Get and Count Messages
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_rules;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Get_rules;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data   ,
      p_encoded => FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Get_rules;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );
END  Get_rules;

-- Function which returns the expression corresponding to a rule
  FUNCTION get_rule_exp (
    p_rule_id  NUMBER ) RETURN VARCHAR2 IS

   --cursor to get all the expressions of a rule
    CURSOR expr_cur(l_rule_id NUMBER) IS
       SELECT cnobj.user_name object_name,
         cnh.name hierarchy_name, cnattr.column_value column_value,
         cnattr.not_flag not_flag, cnattr.high_value high_value,
         cnattr.low_value low_value , cnattr.dimension_hierarchy_id dimension_hierarchy_id
       FROM cn_attribute_rules cnattr, cn_objects cnobj,
         cn_head_hierarchies cnh
       WHERE cnattr.rule_id = l_rule_id
       AND cnattr.column_id = cnobj.object_id (+)
       AND cnattr.org_id = cnobj.org_id
       AND cnattr.dimension_hierarchy_id = cnh.head_hierarchy_id(+)
       AND cnattr.org_id = cnh.org_id(+);


    rule_exp VARCHAR2(2000);
    l_flag             NUMBER := 0;
    l_user_expression  NUMBER := 0;
    l_column_value     NUMBER;
    node_value         VARCHAR2(2000);

    -- variables 	for the lookups
    l_bet               VARCHAR2(80);
    l_is               VARCHAR2(80);
    l_not               VARCHAR2(80);
    l_is_bet            VARCHAR2(80);
    l_is_not_bet            VARCHAR2(80);
    l_and            VARCHAR2(80);
    l_desc            VARCHAR2(80);
    l_not_desc            VARCHAR2(80);
    l_hier            VARCHAR2(80);

    BEGIN

    --get all the lookup meanings
    l_bet := cn_api.get_lkup_meaning('BET','Expression Messages');
    l_is := cn_api.get_lkup_meaning('IS','Expression Messages');
    l_not := cn_api.get_lkup_meaning('NOT','Expression Messages');
    l_is_bet := l_is || ' ' || l_bet;
    l_is_not_bet := l_is || ' ' || l_not || ' ' || l_bet;
    l_and := cn_api.get_lkup_meaning('AND','Expression Messages');
    l_desc := cn_api.get_lkup_meaning('DESCENDANT','Expression Messages');
    l_hier := cn_api.get_lkup_meaning('IIH','Expression Messages');
    l_not_desc := l_is || ' ' || l_not || ' ' || l_desc;
    l_desc := l_is || ' ' || l_desc;


    l_flag := 0;
	l_user_expression :=0;

        -- first check if the user has created any expression
        SELECT COUNT(1)
        INTO l_user_expression
        FROM CN_RULE_ATTR_EXPRESSION
        WHERE RULE_ID = p_rule_id ;

        IF (l_user_expression > 0) THEN

          -- for user created expressions

          SELECT DISTINCT expression
          INTO rule_exp
          FROM CN_ATTRIBUTE_RULES
          WHERE RULE_ID = p_rule_id ;

        ELSE
          -- for expression not 'created' by the user
	  FOR expr IN  expr_cur(p_rule_id) LOOP
	    -- first decide whether this is the first expression or not.
	    IF l_flag = 0 THEN
	       rule_exp := ' ';
	       l_flag := 1;
	    ELSE -- not first expression, need to AND with the previous expression
	       rule_exp := rule_exp || l_and || ' ' ;
	    END IF;

	    IF expr.dimension_hierarchy_id IS NOT  NULL THEN
		l_column_value := expr.column_value;
		SELECT name INTO node_value
		FROM cn_hierarchy_nodes
		WHERE value_id=l_column_value;

	      IF expr.not_flag = 'N'  THEN
		rule_exp :=  rule_exp  ||  expr.object_name || ' ' || l_desc || ' ''' || node_value || ''' '  || l_hier || ' ''' || expr.hierarchy_name || '''' || ' ' ;
	      ELSE
		rule_exp :=  rule_exp   ||  expr.object_name || ' ' || l_not_desc ||' '''||  node_value || ''' '  || l_hier || ' ''' || expr.hierarchy_name || '''' || ' ' ;
	      END IF;

	   ELSE
	     IF expr.column_value  IS NULL THEN
	      IF expr.not_flag = 'N'  THEN
		rule_exp :=  rule_exp   ||  expr.object_name || ' ' || l_is_bet ||' '''|| expr.high_value || ''' ' || l_and  ||' '''|| expr.low_value ||''''|| ' ';
	      ELSE
		rule_exp :=  rule_exp   ||   expr.object_name || ' ' || l_is_not_bet || ' ''' || expr.high_value || ''' ' || l_and  || ' ''' || expr.low_value || '''' || ' ';
	      END IF;
	    ELSE
	      IF expr.not_flag = 'N'  THEN
		rule_exp := rule_exp   ||  expr.object_name || ' = ' ||  '''' || expr.column_value || ''''||  ' ';
	      ELSE
		rule_exp := rule_exp   ||   expr.object_name || ' <> ' || '''' || expr.column_value ||''''|| ' ';
	      END IF;
	    END IF;
	   END IF;
	 END LOOP;

 END IF; -- this is for the user created expressions


    RETURN rule_exp;

  END get_rule_exp;


END CN_Rule_PVT;

/
