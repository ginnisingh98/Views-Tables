--------------------------------------------------------
--  DDL for Package Body CN_RULESET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULESET_PVT" AS
--$Header: cnvrsetb.pls 120.7 2005/12/27 04:04:37 hanaraya ship $

--Global Variables
G_PKG_NAME 	       CONSTANT VARCHAR2(30) := 'CN_Ruleset_PVT';
G_LAST_UPDATE_DATE     DATE 		     := Sysdate;
G_LAST_UPDATED_BY      NUMBER 		     := fnd_global.user_id;
G_CREATION_DATE        DATE 		     := Sysdate;
G_CREATED_BY           NUMBER 		     := fnd_global.user_id;
G_LAST_UPDATE_LOGIN    NUMBER		     := fnd_global.login_id;

--=========================================================================
-- Check synchronized .
--=========================================================================

FUNCTION Check_Sync_Allowed (
    p_name  In VARCHAR2,
    p_ruleset_id  NUMBER,
    p_org_id in NUMBER,
    p_loading_status IN VARCHAR2,
    x_loading_status OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

    l_api_name CONSTANT VARCHAR2(30) := 'check_sync_allowed';

  CURSOR no_attribute_curs IS
  SELECT name
    FROM cn_rules cr
   WHERE cr.rule_id <> -1002
     AND cr.ruleset_id = p_ruleset_id
     AND cr.org_id=p_org_id
     AND NOT EXISTS (SELECT 1
		       FROM cn_attribute_rules car
		      WHERE car.rule_id = cr.rule_id and
              car.org_id=cr.org_id);

  CURSOR valid_attribute_curs IS
   SELECT attr.ruleset_id ruleset_id,
          attr.rule_id rule_id,
          attr.column_id column_id ,
          attr.column_value column_value,
          attr.high_value,
          attr.low_value,
          cr.name rule_name,
          col.user_name,
          attr.org_id
     FROM cn_rules cr, cn_attribute_rules attr, cn_objects col
   WHERE cr.rule_id <> -1002
     and col.object_id = attr.column_id
     and col.table_id = -11803
     AND cr.ruleset_id = p_ruleset_id
     AND attr.rule_id = cr.rule_id
     and attr.ruleset_id = cr.ruleset_id
     and dimension_hierarchy_id is null and
     cr.org_id=attr.org_id and
     attr.org_id=col.org_id;


     l_data_flag  VARCHAR2(02) := 'O';

 BEGIN
    x_loading_status := p_loading_status;

   for attribute_rec in no_attribute_curs loop

    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CN', 'CN_NO_RULE_ATTRIBUTES_DEFINED');
      fnd_message.set_token('CLASSIFICATION_RULE_NAME', p_name);
      fnd_message.set_token('RULE_NAME', attribute_rec.name);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   END LOOP;

   for attribute_rec1 in valid_attribute_curs loop
      l_data_flag := NULL;

      if attribute_rec1.column_id is not null and
         attribute_rec1.column_value is not null THEN
         l_data_flag := 'O';
     elsif attribute_rec1.column_id is not null and
           attribute_rec1.high_value is not null and
           attribute_rec1.low_value is not null then
         l_data_flag := 'R';
     end if;

     if l_data_flag  = 'O'  THEN

      CN_RuleAttribute_PVT.Check_Attr_types
         (p_value_1           => attribute_rec1.column_value,
          p_value_2           => null,
          p_column_id         => attribute_rec1.column_id,
          p_rule_id           => attribute_rec1.rule_id,
          p_ruleset_id        => attribute_rec1.ruleset_id,
          p_org_id            => attribute_rec1.org_id,
          p_data_flag         => l_data_flag,
          p_loading_status    => x_loading_status,
          x_loading_status    => x_loading_status);

           if x_loading_Status =    'CN_DATATYPE_VALUE_MISMATCH' then
                RAISE FND_API.G_EXC_ERROR;
           END IF;
     elsif l_data_flag = 'R' THEN


      CN_RuleAttribute_PVT.Check_Attr_types
         (p_value_1           => attribute_rec1.low_value,
          p_value_2           => attribute_rec1.high_value,
          p_column_id         => attribute_rec1.column_id,
          p_rule_id           => attribute_rec1.rule_id,
          p_ruleset_id        => attribute_rec1.ruleset_id,
          p_org_id            => attribute_rec1.org_id,
          p_data_flag         => l_data_flag,
          p_loading_status    => x_loading_status,
          x_loading_status    => x_loading_status) ;

          if x_loading_status = 'CN_DATATYPE_VALUE_MISMATCH' THEN
                RAISE FND_API.G_EXC_ERROR;
          end if;
     end if;
   END LOOP;

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

END Check_Sync_Allowed;


--=========================================================================
-- Check Update Allowed.
--=========================================================================

FUNCTION check_update_allowed
   ( p_ruleset_id  IN cn_rulesets.ruleset_id%TYPE,
    p_module_type  In cn_rulesets.module_type%TYPE,
    p_loading_status IN VARCHAR2,
    x_loading_status OUT NOCOPY VARCHAR2,
    x_org_id IN cn_rulesets.org_id%TYPE
    ) RETURN VARCHAR2 IS

      l_api_name CONSTANT VARCHAR2(30) := 'check_update_allowed';

      l_env_org_id    NUMBER;

      CURSOR record_exists  IS
	 SELECT count(1) cnt
	   FROM cn_rules_all_b
	   WHERE ruleset_id = p_ruleset_id
	   AND rule_id    <> -1002
	   AND org_id = l_env_org_id;

      CURSOR get_module_type  IS
	 SELECT module_type
	   FROM cn_rulesets
	   WHERE ruleset_id = p_ruleset_id;

   l_module_type  cn_rulesets.module_type%TYPE;
   l_total_record  NUMBER;

 BEGIN

   x_loading_status := p_loading_status;
   l_env_org_id :=x_org_id;

   OPEN  get_module_type;
   fetch get_module_type into l_module_type;
   close get_module_type;

   IF  l_module_type <> p_module_type THEN

     open  record_exists;
     fetch record_exists into l_total_record;
     close record_exists;

     IF l_total_record > 0 THEN

       --Error condition
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	 THEN
          fnd_message.set_name('CN', 'CN_CANNOT_CHANGE_TYPE');
          fnd_msg_pub.add;
        END IF;
        x_loading_status := 'CN_CANNOT_TYPE_TYPE';
        RAISE FND_API.G_EXC_ERROR;

     END IF;

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

END check_update_allowed;

--=========================================================================
--
-- Procedure : check_ruleset_dates
-- Desc      : Validate the start and end dates for the ruleset
--
--=========================================================================
FUNCTION check_ruleset_dates
  (p_start_date  IN cn_rulesets.start_date%TYPE,
   p_end_date    IN cn_rulesets.end_date%TYPE,
   p_module_type IN cn_rulesets.module_type%TYPE,
   p_ruleset_id  IN cn_rulesets.ruleset_id%TYPE,
   p_org_id IN cn_rulesets.org_id%TYPE,
   p_loading_status IN VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

      l_api_name CONSTANT VARCHAR2(30) := 'check_ruleset_dates';

      CURSOR overlap_check1 (p_date DATE) IS
	 SELECT count(*) cnt
	   FROM cn_rulesets cnr
	   WHERE p_date BETWEEN cnr.start_date AND cnr.end_date
	   AND nvl(module_type,'X') = nvl(p_module_type,'X')
	   AND ruleset_id <> p_ruleset_id
       AND org_id=p_org_id;


      CURSOR overlap_check2
	(p_start_date DATE,
	 p_end_date   DATE) IS
	    SELECT count(*) cnt
	      FROM cn_rulesets cnr
	      WHERE cnr.start_date BETWEEN p_start_date AND p_end_date
	      AND cnr.end_date BETWEEN p_start_date AND p_end_date
	      AND nvl(module_type,'X') = nvl(p_module_type,'X')
	      AND ruleset_id <> p_ruleset_id and
          org_id=p_org_id;

      l_count NUMBER;

BEGIN
   x_loading_status := p_loading_status;

   IF p_start_date > p_end_date
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_DATE_RANGE');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_DATE_RANGE';
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   OPEN overlap_check1 (p_start_date);
   FETCH overlap_check1 INTO l_count;
   IF l_count > 0
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_RULESETS');
         fnd_msg_pub.add;
      END IF;
      CLOSE overlap_check1;
      x_loading_status := 'CN_OVERLAP_RULESETS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;
   CLOSE overlap_check1;


   OPEN overlap_check1 (p_end_date);
   FETCH overlap_check1 INTO l_count;
   IF l_count > 0
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_RULESETS');
         fnd_msg_pub.add;
      END IF;
      CLOSE overlap_check1;
      x_loading_status := 'CN_OVERLAP_RULESETS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;
   CLOSE overlap_check1;


   OPEN overlap_check2 (p_start_date,
			p_end_date);
   FETCH overlap_check2 INTO l_count;
   IF l_count > 0
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_OVERLAP_RULESETS');
         fnd_msg_pub.add;
      END IF;
      CLOSE overlap_check2;
      x_loading_status := 'CN_OVERLAP_RULESETS';
      RAISE FND_API.G_EXC_ERROR;

   END IF;
   CLOSE overlap_check2;

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
END check_ruleset_dates;

--=========================================================================
-- Start of comments
--	API name 	: Create_Ruleset
--	Type		: Private
--	Function	: This private API can be used to create a ruleset
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
--						  CN_Ruleset_PVT.ruleset_rec_type
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
--=========================================================================
PROCEDURE create_ruleset
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    x_ruleset_id	 OUT NOCOPY     NUMBER,
    p_ruleset_rec		IN      CN_Ruleset_PVT.ruleset_rec_type
    )
  IS

     l_api_name			CONSTANT VARCHAR2(30)	:= 'Create_Ruleset';
     l_api_version           	CONSTANT NUMBER 	:= 1.0;
     l_loading_status           VARCHAR2(4000);
     l_error_status             NUMBER;
     l_error_parameter          VARCHAR2(30);
     l_rowid			VARCHAR2(4000);
     l_sequence_number		NUMBER;
     l_count                    NUMBER;
     l_ruleset_id               cn_rulesets.ruleset_id%TYPE;
     l_org_id                   cn_rulesets.org_id%TYPE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_Ruleset;
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


   --Check for missing parameters in the p_ruleset_rec parameter

   IF (cn_api.chk_miss_null_char_para
       ( p_ruleset_rec.ruleset_name,
	 cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_char_para
       ( p_ruleset_rec.module_type,
	 cn_api.get_lkup_meaning('MODULE_TYPE', 'RULESET_TYPE'),
	 x_loading_status,
	 x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     ( p_ruleset_rec.end_date,
       cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
       x_loading_status,
       x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF cn_api.chk_miss_null_date_para
     (p_ruleset_rec.start_date,
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
     WHERE name = p_ruleset_rec.ruleset_name
     AND module_type = p_ruleset_rec.module_type
     AND start_date = p_ruleset_rec.start_date
     AND end_date = p_ruleset_rec.end_date and
     ORG_ID=p_ruleset_rec.org_id;

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

   SELECT Decode(p_ruleset_rec.ruleset_id, NULL, cn_rulesets_s.NEXTVAL,
		 p_ruleset_rec.ruleset_id)
     INTO l_ruleset_id
     FROM dual;

   --since this is a new ruleset, validate the effectivity before inserting
   IF check_ruleset_dates(p_ruleset_rec.start_date,
			  p_ruleset_rec.end_date,
			  p_ruleset_rec.module_type,
			  l_ruleset_id,
			  p_ruleset_rec.org_id,
			  x_loading_status,
			  x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

    IF p_ruleset_rec.module_type NOT IN ('REVCLS', 'ACCGEN', 'PECLS')
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_RULESET_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET_TYPE';

      RAISE fnd_api.g_exc_error;
   END IF;

   cn_syin_rulesets_pkg.insert_row
     (
      x_rowid                          => l_rowid,
      x_ruleset_id                     => l_ruleset_id,
      x_end_date                       => p_ruleset_rec.end_date,
      x_ruleset_status                 => 'UNSYNC',
      x_destination_column_id          => -11980,
      x_repository_id                  => 100,
      x_start_date                     => p_ruleset_rec.start_date,
      x_name                           => p_ruleset_rec.ruleset_name,
      x_module_type                    => p_ruleset_rec.module_type,
      x_creation_date                  => sysdate,
      x_created_by                     => g_created_by,
      x_last_update_date               => sysdate,
      x_last_updated_by                => g_last_updated_by,
      x_last_update_login              => g_last_update_login,
      x_org_id                         =>p_ruleset_rec.org_id
      );

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   x_ruleset_id := l_ruleset_id;


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
--=========================================================================
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
--						  CN_Ruleset_PVT.ruleset_rec_type
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
--=========================================================================

PROCEDURE Update_Ruleset
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PVT.ruleset_rec_type,
    p_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PVT.ruleset_rec_type
    ) IS


  CURSOR l_ovn_csr IS
    SELECT nvl(object_version_number,1)
      FROM cn_rulesets
      WHERE ruleset_id = p_old_ruleset_rec.ruleset_id AND
      ORG_ID=p_old_ruleset_rec.org_id;

  l_env_org_id    NUMBER;

  CURSOR rules IS
    SELECT count(1)
      FROM cn_rules_all_b
      WHERE ruleset_id = p_old_ruleset_rec.ruleset_id
      and rule_id <> -1002 and
      org_id = p_old_ruleset_rec.org_id;

       l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Ruleset';
       l_api_version           	CONSTANT NUMBER 	:= 1.0;
       l_loading_st             VARCHAR2(4000);
       l_count                  NUMBER;

       l_ruleset_status	        VARCHAR2(100);
       l_request_id             NUMBER;
       l_object_version_number  cn_attribute_rules.object_version_number%TYPE;

       l_rules			NUMBER;


      CURSOR get_ruleset_data ( l_ruleset_id NUMBER,l_org_id Number)  IS
     SELECT *
      FROM cn_rulesets
     WHERE ruleset_id = l_ruleset_id and
     org_id=l_org_id;

      l_get_ruleset_data_rec  get_ruleset_data%ROWTYPE;


BEGIN

   l_env_org_id := p_ruleset_rec.org_id;
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

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

  --
  -- Unsync the rulesets
  cn_syin_rules_pkg.unsync_ruleset(p_ruleset_rec.ruleset_id,p_ruleset_rec.org_id);



   p_old_ruleset_rec.ruleset_id := p_ruleset_rec.ruleset_id;

   select name,
          start_date,
          end_date,
          module_type
    into p_old_ruleset_rec.ruleset_name,
         p_old_ruleset_rec.start_date,
         p_old_ruleset_rec.end_date,
         p_old_ruleset_rec.module_type
    from cn_rulesets
   where ruleset_id = p_ruleset_rec.ruleset_id and
   org_id=p_ruleset_rec.org_id;

   -- API body
   IF p_ruleset_rec.ruleset_name <> p_old_ruleset_rec.ruleset_name
     OR p_ruleset_rec.module_type <> p_old_ruleset_rec.module_type
     OR p_ruleset_rec.start_date <> nvl(p_old_ruleset_rec.start_date, p_ruleset_rec.start_date + 1)
     OR p_ruleset_rec.end_date <> nvl(p_old_ruleset_rec.end_date, p_ruleset_rec.end_date + 1)
     THEN
      --ruleset needs to be updated

      --Validate input parameters
      --Check for missing parameters in the p_ruleset_rec parameter

      IF (cn_api.chk_miss_null_char_para
	  ( p_old_ruleset_rec.ruleset_name,
	    cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	    x_loading_status,
	    x_loading_status) = FND_API.G_TRUE )
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      --Check for missing parameters in the p_ruleset_rec parameter

      IF (cn_api.chk_miss_null_char_para
	  ( p_ruleset_rec.ruleset_name,
	    cn_api.get_lkup_meaning('RULESET_NAME', 'RULESET_TYPE'),
	    x_loading_status,
	    x_loading_status) = FND_API.G_TRUE )
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	( p_ruleset_rec.end_date,
	  cn_api.get_lkup_meaning('END_DATE', 'RULESET_TYPE'),
	  x_loading_status,
	  x_loading_status) = fnd_api.g_true
	THEN
	 RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_miss_null_date_para
	(p_ruleset_rec.start_date,
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
	WHERE ruleset_id = p_old_ruleset_rec.ruleset_id and
    org_id=p_old_ruleset_rec.org_id;

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

    IF p_ruleset_rec.module_type NOT IN ('REVCLS', 'ACCGEN', 'PECLS')
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_RULESET_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULESET_TYPE';

      RAISE fnd_api.g_exc_error;
   END IF;

 -- check if the object version number is the same
   OPEN  l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;


   IF (l_object_version_number <>
     p_ruleset_rec.object_version_number) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_OBJECT_VERSION';
      RAISE FND_API.G_EXC_ERROR;

   end if;


      IF p_ruleset_rec.start_date <> p_old_ruleset_rec.start_date
	OR p_ruleset_rec.end_date <> p_old_ruleset_rec.end_date
        THEN
	 --validate the periods before updating
	 IF   check_ruleset_dates(p_ruleset_rec.start_date,
				  p_ruleset_rec.end_date,
				  p_ruleset_rec.module_type,
				  p_old_ruleset_rec.ruleset_id,
				  p_ruleset_rec.org_id,
				  x_loading_status,
				  x_loading_status) = fnd_api.g_true
	   THEN
             RAISE fnd_api.g_exc_error;
	    --Error condition
	    --IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	    --  THEN
	    --   fnd_message.set_name('CN', 'CN_INVALID_RULESET');
	    --   fnd_msg_pub.add;
	    --END IF;
	    ----x_loading_status := 'CN_INVALID_RULESET';
	    ----RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;

    IF check_update_allowed
   ( p_old_ruleset_rec.ruleset_id,
     p_ruleset_rec.module_type,
     x_loading_status,
     x_loading_status,
     P_old_ruleset_rec.org_id) = fnd_api.g_true
   THEN
      RAISE fnd_api.g_exc_error;
   END IF;

      p_ruleset_rec.object_version_number:=p_ruleset_rec.object_version_number+1;
      cn_syin_rulesets_pkg.update_row

	(
	 x_ruleset_id                     => p_old_ruleset_rec.ruleset_id,
         x_object_version_number	  => p_ruleset_rec.object_version_number,
	 x_end_date                       => p_ruleset_rec.end_date,
	 x_ruleset_status                 => 'UNSYNC',
	 x_destination_column_id          => -11980,
	 x_repository_id                  => 100,
	 x_start_date                     => p_ruleset_rec.start_date,
	 x_name                           => p_ruleset_rec.ruleset_name,
	 x_module_type                    => p_ruleset_rec.module_type,
	 x_last_update_date               => sysdate,
	 x_last_updated_by                => g_last_updated_by,
	 x_last_update_login              => g_last_update_login,
         x_org_id                         => p_ruleset_rec.org_id
     );

   END IF;

  -- sync the rulesets

   IF nvl(p_ruleset_rec.sync_flag,'N')  = 'Y' then

    -- Check sync allowed

    open rules;
    fetch rules into l_rules;
    close rules;

    --
    -- check sync allowed.
    --
    IF nvl(l_rules,0) = 0 THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	      THEN
	       fnd_message.set_name('CN', 'CN_NO_RULES_DEFINED');
	       fnd_msg_pub.add;
	    END IF;
	    x_loading_status := 'CN_NO_RULES_DEFINED';
	    RAISE FND_API.G_EXC_ERROR;
    END IF;


     IF check_sync_allowed
     ( p_old_ruleset_rec.ruleset_name,
       p_old_ruleset_rec.ruleset_id,
       p_old_ruleset_rec.org_id,
       x_loading_status,
       x_loading_status ) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
     END IF;

     cn_rulesets_pkg.sync_ruleset(p_ruleset_rec.ruleset_id,l_ruleset_status,l_env_org_id);

     -- Kumar
     -- changed from GENERATED to INSTINPG ( Install in Process )
     -- Date : 11/07/2001

     IF l_ruleset_status = 'INSTINPG'
      THEN
        cn_classification_conc_submit.submit_request(abs(p_ruleset_rec.ruleset_id),
                                  l_request_id,p_ruleset_rec.org_id);
        p_ruleset_rec.status:='INSTINPG';
       --
       -- l_request_id will be null or zero only if the concurrent manager is down.
       -- CONCFAIL Concurrent Manager Down.
       --

       IF l_request_id iS NULL or l_request_id = 0 THEN

       OPEN get_ruleset_data(p_ruleset_rec.ruleset_id,p_ruleset_rec.org_id);
       FETCH get_ruleset_data INTO l_get_ruleset_data_rec;
       CLOSE get_ruleset_data;
       cn_syin_rulesets_pkg.update_row(p_ruleset_rec.ruleset_id,
                                   l_get_ruleset_data_rec.object_version_number,
                                   'CONCFAIL',
                                   l_get_ruleset_data_rec.destination_column_id,
                                   l_get_ruleset_data_rec.repository_id,
                                   l_get_ruleset_data_rec.start_date,
                                   l_get_ruleset_data_rec.end_date,
                                   l_get_ruleset_data_rec.name,
                                   l_get_ruleset_data_rec.module_type,
                                   null,
                                   null,
                                   null,
                                   p_ruleset_rec.org_id);
      p_ruleset_rec.status:='CONCFAIL';
      END IF;


     END IF;
  END IF;

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
      ROLLBACK TO Update_Ruleset;
      x_return_status := FND_API.G_RET_STS_ERROR ;

 FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Ruleset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
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
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END;

END CN_Ruleset_PVT;

/
