--------------------------------------------------------
--  DDL for Package Body CN_TRX_FACTORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRX_FACTORS_PVT" as
/* $Header: cnxvtrxb.pls 120.1 2005/09/09 00:06:55 rarajara noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_TRX_FACTORS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnxvtrxb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
G_ROWID                     VARCHAR2(30);
G_PROGRAM_TYPE              VARCHAR2(30);
--|/*-----------------------------------------------------------------------+
--|
--|  Procedure Name : CHECK_VALID_QUOTAS
--|
--|----------------------------------------------------------------------- */
PROCEDURE Check_valid_quotas
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_quota_name             IN  VARCHAR2 ,
   p_rev_class_name         IN  VARCHAR2 ,
   p_org_id									IN NUMBER,
   x_quota_id               OUT NOCOPY NUMBER   ,
   x_quota_rule_id          OUT NOCOPY NUMBER   ,
   x_rev_class_id           OUT NOCOPY NUMBER   ,
   p_loading_status         IN  VARCHAR2 ,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name	CONSTANT VARCHAR2(30)
 	                := 'Validate_trx_factors';
      l_lkup_meaning    cn_lookups.meaning%TYPE;

      l_loading_status VARCHAR2(80);

BEGIN
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;
  --+
  -- Check Miss And Null Parameters.
  --+
  l_lkup_meaning := cn_api.get_lkup_meaning('QUOTA_NAME','PM_OBJECT_TYPE');
  IF ( (cn_api.chk_null_char_para
	     (p_char_para => p_quota_name,
	      p_obj_name  => l_lkup_meaning,
	      p_loading_status => x_loading_status,
	      x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
  l_lkup_meaning := cn_api.get_lkup_meaning('','PM_OBJECT_TYPE');
  IF ( (cn_api.chk_null_char_para
	     (p_char_para => p_rev_class_name,
	      p_obj_name  => l_lkup_meaning,
	      p_loading_status => x_loading_status,
	      x_loading_status => l_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- Quota ID
   x_quota_id := cn_chk_plan_element_pkg.get_quota_id(Ltrim(Rtrim(p_quota_name)),p_org_id);
   -- Get the Revenue Class ID
   x_rev_class_id := cn_api.get_rev_class_id(Ltrim(Rtrim(p_rev_class_name)),p_org_id);
   -- get the Quota Rule ID
   x_quota_rule_id := cn_chk_plan_element_pkg.get_quota_rule_id(x_quota_id, x_rev_class_id);
   IF p_quota_name IS NOT NULL THEN
      IF x_quota_id IS NULL THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME('CN' , 'CN_PLN_NOT_EXIST');
	    FND_MESSAGE.SET_TOKEN('PE_NAME',p_quota_name);
	    FND_MSG_PUB.Add;
	     RAISE FND_API.G_EXC_ERROR ;
	 END IF;
      END IF;
   END IF;

   IF p_rev_class_name IS NOT NULL THEN
      IF x_rev_class_id IS NULL THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_REV_CLASS_NOT_EXIST');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_REV_CLASS_NOT_EXIST';
	 RAISE FND_API.G_EXC_ERROR ;
      END IF ;
   END IF;


   IF x_quota_rule_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_QUOTA_RULE_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_QUOTA_RULE_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- End Check Valid Quotas.

END check_valid_quotas;

--|/*-----------------------------------------------------------------------+
--|
--|  Procedure Name : Validate_Trx_Factors
--|
--|----------------------------------------------------------------------- */
  PROCEDURE Validate_trx_Factors
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_trx_factor_rec        IN  cn_plan_element_pub.trx_factor_rec_type,
   p_quota_name             IN  VARCHAR2,
   p_quota_id               IN  NUMBER,
   p_rev_class_name         IN  VARCHAR2,
   p_rev_class_id           IN  NUMBER,
   p_quota_rule_id          IN  NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name	CONSTANT VARCHAR2(30)
 	                := 'Validate_trx_factors';
      l_lkup_meaning    cn_lookups.meaning%TYPE;
      l_tmp             NUMBER;

      l_loading_status VARCHAR2(80);

BEGIN
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;
   --+
   -- Check Miss And Null Parameters.
   --+
   l_lkup_meaning := cn_api.get_lkup_meaning('TRX_TYPE','PM_OBJECT_TYPE');

  IF((cn_api.chk_null_char_para
	(p_char_para => p_trx_factor_rec.trx_type,
	 p_obj_name  => l_lkup_meaning,
	 p_loading_status => x_loading_status,
	 x_loading_status => l_loading_status)) = FND_API.G_TRUE)
    THEN
     RAISE FND_API.G_EXC_ERROR ;
  END IF;


  l_lkup_meaning := cn_api.get_lkup_meaning('REV_CLASS_NAME','PM_OBJECT_TYPE');
  IF((cn_api.chk_null_char_para
      (p_char_para => p_trx_factor_rec.rev_class_name,
	 p_obj_name  => l_lkup_meaning,
	 p_loading_status => x_loading_status,
       x_loading_status => l_loading_status)) = FND_API.G_TRUE)
    THEN
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  l_lkup_meaning := cn_api.get_lkup_meaning('EVENT_FACTOR','PM_OBJECT_TYPE');

  IF ( (cn_api.chk_null_num_para
	(p_num_para => p_trx_factor_rec.event_factor,
	 p_obj_name  => l_lkup_meaning,
	 p_loading_status => x_loading_status,
	 x_loading_status => l_loading_status)) = FND_API.G_TRUE )
    THEN
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ltrim(Rtrim(p_rev_class_name)) <> Ltrim(Rtrim(p_trx_factor_rec.rev_class_name))
     THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INCONSISTENT_REV_CLASS');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_INCONSISTENT_REV_CLASS';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   -- +
   -- Check Record Already exists.
   --+
   SELECT COUNT(*)
     INTO l_tmp
     FROM cn_trx_factors
     WHERE revenue_class_id = p_rev_class_id
     AND quota_id = p_quota_id
     AND quota_rule_id =  p_quota_rule_id
     AND trx_type =  p_trx_factor_rec.trx_type ;

   IF (l_tmp <> 0) THEN
      x_loading_status := 'TRX_FACTORS_EXISTS';
   END IF ;

   -- End of Validate Trx Factors.
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
 	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (
         p_count  =>  x_msg_count,
         p_data   =>  x_msg_data,
         p_encoded=> FND_API.G_FALSE
        );
END Validate_trx_factors;
--|/*---------------n--------------------------------------------------------+
--|  Procedure Name : Update Trx Factors
--|
--|----------------------------------------------------------------------- */
PROCEDURE  update_trx_factors
  (
   p_api_version        IN 	NUMBER,
   p_init_msg_list      IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY 	VARCHAR2,
   x_msg_count	        OUT NOCOPY 	NUMBER,
   x_msg_data	        OUT NOCOPY 	VARCHAR2,
   p_quota_name	        IN      VARCHAR2,
   p_rev_class_name     IN      VARCHAR2,
   p_trx_factor_rec_tbl IN      CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
                                  := CN_PLAN_ELEMENT_PUB.G_MISS_TRX_FACTOR_REC_TBL,
   x_loading_status     OUT NOCOPY 	VARCHAR2,
   p_org_id							IN NUMBER
   ) IS
      l_api_name		CONSTANT VARCHAR2(30)
	                        := 'Update_Trx_Factors';
      l_api_version           	CONSTANT NUMBER := 1.0;

      l_quota_id                NUMBER;
      l_quota_rule_id           NUMBER;
      l_rev_class_id        NUMBER;
      l_trx_factor_rec      cn_plan_element_pub.trx_factor_rec_type;

      l_loading_status VARCHAR2(80);

BEGIN
   --
   -- Standard Start of API savepoint
   -- +
   SAVEPOINT    Update_trx_Factors ;
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
   --+
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   IF p_trx_factor_rec_tbl.COUNT > 0 THEN

    check_valid_quotas
     (x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
	 p_quota_name        => p_quota_name,
	 p_rev_class_name    => p_rev_class_name,
   p_org_id						 => p_org_id,
	 x_quota_id          => l_quota_id,
	 x_quota_rule_id     => l_quota_rule_id,
	 x_rev_class_id      => l_rev_class_id,
         p_loading_status    => x_loading_status,
         x_loading_status    => l_loading_status
      );
      x_loading_status := l_loading_status;
   END IF;

   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR ;
    ELSIF ( x_return_status   = FND_API.G_RET_STS_SUCCESS )
      AND ( x_loading_status  =  'CN_UPDATED' )
      THEN
      IF  p_trx_factor_rec_tbl.COUNT > 0 THEN
	 FOR i IN p_trx_factor_rec_tbl.first .. p_trx_factor_rec_tbl.last LOOP
	    IF (p_trx_factor_rec_tbl.exists(i)) AND
	      (p_trx_factor_rec_tbl(i).rev_class_name =
	       p_rev_class_name )
	      THEN
	       l_trx_factor_rec.rev_class_name := p_trx_factor_rec_tbl(i).rev_class_name;
	       l_trx_factor_rec.trx_type := p_trx_factor_rec_tbl(i).trx_type;
	       l_trx_factor_rec.event_factor := p_trx_factor_rec_tbl(i).event_factor;
	       Validate_trx_Factors
		 (
		  x_return_status	   => x_return_status,
		  x_msg_count		   => x_msg_count,
		  x_msg_data		   => x_msg_data,
		  p_trx_factor_rec        =>  l_trx_factor_rec,
		  p_quota_name             => p_quota_name,
		  p_quota_id               => l_quota_id,
		  p_rev_class_name         => p_rev_class_name,
		  p_rev_class_id           => l_rev_class_id,
		  p_quota_rule_id          => l_quota_rule_id,
		  p_loading_status         => x_loading_status,
		  x_loading_status         => l_loading_status );
           x_loading_status := l_loading_status;

		 IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		    RAISE FND_API.G_EXC_ERROR ;
		  ELSIF ( x_return_status   = FND_API.G_RET_STS_SUCCESS )
		    AND ( x_loading_status = 'TRX_FACTORS_EXISTS' )  THEN
                        x_loading_status  :=  'CN_UPDATED' ;
		    UPDATE cn_trx_factors
		      SET event_factor = p_trx_factor_rec_tbl(i).event_factor
		      WHERE quota_id   = l_quota_id
		      AND quota_rule_id = l_quota_rule_id
		      AND trx_type      = Ltrim(Rtrim(p_trx_factor_rec_tbl(i).trx_type)) ;
		 END IF;
	    END IF;  -- trx Factor Exists
	 END LOOP;  --+
	 CN_CHK_PLAN_ELEMENT_PKG.chk_trx_factor
	   (
	    x_return_status  => x_return_status,
	    p_quota_rule_id  => l_quota_rule_id,
	    p_rev_class_name => p_rev_class_name,
	    p_loading_status => x_loading_status,
	    x_loading_status => l_loading_status
	    );
         x_loading_status := l_loading_status;
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
      END IF;
   END IF;
   -- End of API body.
   -- Standard check of p_commit.
   --+
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   --+
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Trx_Factors;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Trx_Factors;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Trx_Factors;
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
END Update_Trx_Factors;


END CN_TRX_FACTORS_PVT ;

/
