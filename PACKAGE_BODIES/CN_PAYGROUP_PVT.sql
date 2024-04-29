--------------------------------------------------------
--  DDL for Package Body CN_PAYGROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYGROUP_PVT" as
-- $Header: cnvpgrpb.pls 120.7 2006/07/03 14:26:08 sjustina ship $

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_PAYGROUP_PVT';

-- -------------------------------------------------------------------------+
--+
--  Procedure   : Get_PayGroup_ID
--  Description : This procedure is used to get the ID for the pay group
--  Calls       :
--+
-- -------------------------------------------------------------------------+
PROCEDURE Get_PayGroup_ID
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_PayGroup_rec           IN  PayGroup_Rec_Type,
   p_loading_status         IN  VARCHAR2,
   x_pay_group_id           OUT NOCOPY NUMBER,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

      l_api_name  CONSTANT VARCHAR2(30) := 'Get_PayGroup_ID';

      CURSOR get_PayGroup_id is
	 SELECT pay_group_id
	   FROM cn_pay_groups
	   WHERE name = p_PayGroup_rec.name
	   AND start_date = p_PayGroup_rec.start_date
	   AND end_date = p_PayGroup_rec.end_date
       and org_id= p_PayGroup_rec.org_id;
      l_get_PayGroup_id_rec get_PayGroup_id%ROWTYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;

   OPEN get_PayGroup_id;
   FETCH get_PayGroup_id INTO l_get_PayGroup_id_rec;
   IF get_PayGroup_id%ROWCOUNT = 0
     THEN
      x_status := 'NEW PAY GROUP';
      x_pay_group_id  := l_get_PayGroup_id_rec.pay_group_id;
      SELECT cn_pay_groups_s.nextval
        INTO x_pay_group_id
        FROM dual;
    ELSIF get_PayGroup_id%ROWCOUNT = 1
      THEN
      x_status := 'PAY GROUP EXISTS';
      x_pay_group_id  := l_get_PayGroup_id_rec.pay_group_id;
   END IF;
   CLOSE get_PayGroup_id;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;

END Get_PayGroup_ID;


-- -------------------------------------------------------------------------+
--+
--  Procedure   : Validate_PayGroup
--  Description : This procedure is used to validate the parameters that
--		  have been passed to create a pay group.
--  Calls       :
--+
-- -------------------------------------------------------------------------+
PROCEDURE Validate_PayGroup
  (
   x_return_status	    OUT NOCOPY VARCHAR2 ,
   x_msg_count		    OUT NOCOPY NUMBER	 ,
   x_msg_data		    OUT NOCOPY VARCHAR2 ,
   p_PayGroup_rec           IN  PayGroup_Rec_Type,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

      l_count		   NUMBER;
      l_api_name  CONSTANT VARCHAR2(30) := 'Validate_PayGroup';

BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;


   -- Check for missing and null parameters.

   IF ( (cn_api.chk_miss_char_para
	 (p_char_para => p_PayGroup_rec.name,
	  p_para_name  =>
	      cn_api.get_lkup_meaning('PAY_GROUP_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_char_para
	 (p_char_para => p_PayGroup_rec.name,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('PAY_GROUP_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   IF ( (cn_api.chk_miss_date_para
	 (p_date_para => p_PayGroup_rec.start_date,
	  p_para_name  =>
	   cn_api.get_lkup_meaning('START_DATE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_date_para
	 (p_date_para => p_PayGroup_rec.start_date,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('START_DATE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_date_para
	 (p_date_para => p_PayGroup_rec.end_date,
	  p_para_name  =>
	    cn_api.get_lkup_meaning('END_DATE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_date_para
	 (p_date_para => p_PayGroup_rec.end_date,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('END_DATE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_num_para
	 (p_num_para => p_PayGroup_rec.org_id,
	  p_para_name  =>
	      cn_api.get_lkup_meaning('ORG_ID', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_num_para
	 (p_num_para => p_PayGroup_rec.org_id,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('ORG_ID', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_char_para
	 (p_char_para => p_PayGroup_rec.period_set_name,
	  p_para_name  =>
	   cn_api.get_lkup_meaning('PERIOD_SET_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_char_para
	 (p_char_para => p_PayGroup_rec.period_set_name,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('PERIOD_SET_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_miss_char_para
	 (p_char_para => p_PayGroup_rec.period_type,
	  p_para_name  =>
	   cn_api.get_lkup_meaning('PERIOD_TYPE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_char_para
	 (p_char_para => p_PayGroup_rec.period_type,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('PERIOD_TYPE', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- End of Validate Pay Groups.
   -- Standard call to get message count and if count is 1,
   -- get message info.

   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count,
      p_data    =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
      );

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

END Validate_PayGroup;



--------------------------------------------------------------------------+
-- Procedure  : Create_PayGroup
-- Description: Public API to create a pay group
-- Calls      : validate_pay_group
--		CN_Pay_Groups_Pkg.Begin_Record
--------------------------------------------------------------------------+
PROCEDURE Create_PayGroup(
		p_api_version           	IN	     NUMBER,
		p_init_msg_list		        IN	     VARCHAR2 ,
		p_commit	    		    IN  	 VARCHAR2,
		p_validation_level		    IN  	 NUMBER,
		x_return_status		      OUT NOCOPY VARCHAR2,
		x_msg_count		          OUT NOCOPY NUMBER,
		x_msg_data		          OUT NOCOPY VARCHAR2,
		p_PayGroup_rec       IN OUT NOCOPY    PayGroup_Rec_Type,
		x_loading_status	      OUT NOCOPY VARCHAR2,
		x_status                  OUT NOCOPY VARCHAR2
		) IS

   l_api_name		     CONSTANT VARCHAR2(30) := 'Create_PayGroup';
   l_api_version         CONSTANT NUMBER := 1.0;
   l_pay_group_id	     NUMBER;
   l_period_set_id       NUMBER;
   l_period_type_id      NUMBER;
   l_count               NUMBER;
   l_dummy 			     NUMBER;

L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PayGroup_PUB';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);

   CURSOR get_period_set_id IS
      SELECT period_set_id
	FROM cn_period_sets
	WHERE period_set_name = p_paygroup_rec.period_set_name
    and org_id = p_paygroup_rec.org_id;

   CURSOR get_period_type_id IS
      SELECT period_type_id
	FROM cn_period_types
	WHERE period_type = p_paygroup_rec.period_type
    and org_id = p_paygroup_rec.org_id;

BEGIN


   -- Standard Start of API savepoint

   SAVEPOINT    Create_PayGroup;


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

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';



   -- API body

   IF p_PayGroup_rec.end_date IS NOT NULL
     AND p_PayGroup_rec.start_date IS NOT NULL
      AND (p_PayGroup_rec.start_date > p_PayGroup_rec.end_date)
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

  Validate_PayGroup
     (
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PayGroup_rec       => p_PayGroup_rec,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status,
      x_status             => x_status
      );

   -- Added by Kumar Sivasankran on 26/JUL/01
   --
    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   SELECT COUNT(*)
     INTO l_count
     FROM cn_pay_groups
     WHERE name = p_PayGroup_rec.name
     AND start_date = p_PayGroup_rec.start_date
     AND end_date = p_PayGroup_rec.end_date
     and org_id = p_PayGroup_rec.org_id;


   IF (l_count <> 0) THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_PAY_GROUP_EXISTS');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_PAY_GROUP_EXISTS';
      RAISE FND_API.G_EXC_ERROR;
   END IF ;


   --***********************************************************************
   -- Check Overlap
   --    Ensure paygroup do not overlap each other in same pay group name
   --    Returns an error message and raises an exception if overlap occurs.
   -- Added Kumar
   -- Date 25-OCT-2000
   --***********************************************************************

   BEGIN
      SELECT 1 INTO l_dummy FROM dual
        WHERE NOT EXISTS
        ( SELECT 1
          FROM   cn_pay_groups
          WHERE
                 ((end_date IS NOT NULL) AND
                  (p_paygroup_rec.end_date IS NOT NULL) AND
                  ((start_date BETWEEN p_paygroup_rec.start_date
                    AND p_Paygroup_rec.end_date) OR
                   (end_date BETWEEN p_Paygroup_rec.start_date
                    AND p_paygroup_rec.end_date) OR
                   (p_paygroup_rec.start_date BETWEEN start_date
                    AND end_date))
                  )
          AND  name   = p_paygroup_rec.name
          and org_id = p_paygroup_rec.org_id
        );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGROUP_OVERLAPS');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PAYGROUP_OVERLAPS';
         RAISE FND_API.G_EXC_ERROR ;
    END;

    l_pay_group_id := p_PayGroup_rec.pay_group_id;
    IF(l_pay_group_id IS NULL) THEN
             get_PayGroup_id(
		      x_return_status      => x_return_status,
		      x_msg_count          => x_msg_count,
		      x_msg_data           => x_msg_data,
		      p_PayGroup_rec       => p_PayGroup_rec,
		      x_pay_group_id       => l_pay_group_id,
		      p_loading_status     => x_loading_status,
		      x_loading_status     => x_loading_status,
		      x_status             => x_status
		      );
       END IF;

      --Check if period_set_name is valid
       OPEN get_period_set_id;
       FETCH get_period_set_id INTO l_period_set_id;
       IF get_period_set_id%ROWCOUNT = 0
       THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_INVALID_PRD_SET');
             fnd_msg_pub.add;
          END IF;

          x_loading_status := 'CN_INVALID_PRD_SET';
          CLOSE get_period_set_id;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       CLOSE get_period_set_id;

      --Check if period_type is valid

       OPEN get_period_type_id;
       FETCH get_period_type_id INTO l_period_type_id;
       IF get_period_type_id%ROWCOUNT = 0
       THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_INVALID_PERIOD_TYPE');
             fnd_msg_pub.add;
          END IF;

          x_loading_status := 'CN_INVALID_PERIOD_TYPE';
          CLOSE get_period_type_id;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       CLOSE get_period_type_id;
      CN_Pay_Groups_Pkg.Begin_Record
	(
	 x_operation            => 'INSERT',
	 x_rowid                => L_ROWID,
	 x_pay_group_id         => l_pay_group_id,
	 x_name                 => p_PayGroup_rec.name,
	 x_period_set_name      => p_PayGroup_rec.period_set_name,
	 x_period_type          => p_PayGroup_rec.period_type,
	 x_start_date           => p_PayGroup_rec.start_date,
	 x_end_date             => p_PayGroup_rec.end_date,
	 x_pay_group_description=> p_PayGroup_rec.pay_group_description,
	 x_period_set_id        => l_period_set_id,
	 x_period_type_id       => l_period_type_id,
	 x_attribute_category   => p_PayGroup_rec.attribute_category,
	 x_attribute1           => p_PayGroup_rec.attribute1,
	 x_attribute2           => p_PayGroup_rec.attribute2,
	 x_attribute3           => p_PayGroup_rec.attribute3,
	 x_attribute4           => p_PayGroup_rec.attribute4,
	 x_attribute5           => p_PayGroup_rec.attribute5,
	 x_attribute6           => p_PayGroup_rec.attribute6,
	 x_attribute7           => p_PayGroup_rec.attribute7,
	 x_attribute8           => p_PayGroup_rec.attribute8,
	 x_attribute9           => p_PayGroup_rec.attribute9,
 	 x_attribute10          => p_PayGroup_rec.attribute10,
	 x_attribute11          => p_PayGroup_rec.attribute10,
	 x_attribute12          => p_PayGroup_rec.attribute12,
	 x_attribute13          => p_PayGroup_rec.attribute13,
	 x_attribute14          => p_PayGroup_rec.attribute14,
	 x_attribute15          => p_PayGroup_rec.attribute15,
	 x_last_update_date     => l_last_update_date,
	 x_last_updated_by      => l_last_updated_by,
	 x_creation_date        => l_creation_date,
	 x_created_by           => l_created_by,
	 x_last_update_login    => l_last_update_login,
	 x_program_type         => l_program_type,
	 x_object_version_number => p_PayGroup_rec.object_version_number,
	 x_org_id                => p_PayGroup_rec.org_id
	);


   -- End of API body.


  p_PayGroup_Rec.pay_group_id :=l_pay_group_id;
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
      ROLLBACK TO Create_PayGroup;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
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
END Create_PayGroup;

---------------------------------------------------------------------------+
--  Procedure   : 	Update PayGroup
--  Description : 	This is a public procedure to update pay groups
--  Calls       : 	validate_pay_group
--			CN_Pay_Groups_Pkg.Begin_Record
---------------------------------------------------------------------------+

PROCEDURE  Update_PayGroup (
		p_api_version		   IN 	NUMBER,
		p_init_msg_list		   IN	VARCHAR2,
		p_commit	    	   IN  	VARCHAR2,
		p_validation_level	   IN  	NUMBER,
		x_return_status        OUT NOCOPY 	VARCHAR2,
		x_msg_count	           OUT NOCOPY 	NUMBER,
		x_msg_data	           OUT NOCOPY 	VARCHAR2,
		p_PayGroup_rec         IN OUT NOCOPY     PayGroup_rec_type,
		x_status               OUT NOCOPY 	VARCHAR2,
		x_loading_status       OUT NOCOPY 	VARCHAR2
		)  IS
L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PayGroup_PUB';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
L_OBJECT_VERSION_NUMBER     NUMBER;

   l_api_name		         CONSTANT VARCHAR2(30)  := 'Update_PayGroup';
   l_api_version       	     CONSTANT NUMBER        := 1.0;
   l_PayGroups_rec           PayGroup_rec_type;
   l_pay_group_id		     NUMBER;
   l_count                   NUMBER;
   l_period_set_id           NUMBER;
   l_period_type_id          NUMBER;
   l_start_date              DATE;
   l_end_date                DATE;
   l_null_date               CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');
   l_dummy 			         NUMBER;
   l_old_ovn                 NUMBER;
   p_old_PayGroup_rec        PayGroup_rec_type;
   l_pay_period_end_date     DATE;
   l_valid_data              NUMBER := 0;

   CURSOR get_period_set_id  IS
      SELECT period_set_id
	FROM cn_period_sets
	WHERE period_set_name = p_paygroup_rec.period_set_name
    and org_id = p_paygroup_rec.org_id;

   CURSOR get_period_type_id IS
      SELECT period_type_id
	FROM cn_period_types
	WHERE period_type = p_paygroup_rec.period_type
    and org_id = p_paygroup_rec.org_id;


   CURSOR get_pay_group (p_pay_group_id NUMBER) IS
      SELECT *
	FROM cn_pay_groups
	WHERE pay_group_id = p_pay_group_id;
   l_pg_rec get_pay_group%ROWTYPE;

    cursor get_old_pay_group is
    select
        pay_group_id,
        name,
        period_set_name,
        period_type,
        start_date,
        end_date,
        pay_group_description,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        object_version_number,
        org_id
    from cn_pay_groups
    where pay_group_id = p_paygroup_rec.pay_group_id;

  -- get the all the salesrep assigned to this salesreps and the the
  -- data should fall with in the srp Paygroups
  -- Added KS
  CURSOR get_srp_pay_group_id_cur (
           c_pay_group_id cn_srp_pay_groups.pay_group_id%TYPE,
           c_start_date cn_srp_pay_groups.start_date%TYPE,
           c_end_date cn_srp_pay_groups.end_date%TYPE,
           c_org_id cn_srp_pay_groups.org_id%TYPE) IS
      SELECT  salesrep_id
        FROM cn_srp_pay_groups
        WHERE  pay_group_id = c_pay_group_id
        AND trunc(start_date) = trunc(c_start_date)
        AND trunc(nvl(end_date, l_null_date)) = trunc(nvl(c_end_date, l_null_date))
        AND org_id = c_org_id;


  --
  -- Get the Role info for Each Salesreps
  -- Added KS
  CURSOR get_roles (p_salesrep_id NUMBER,p_org_id NUMBER) IS
      SELECT role_id
        FROM cn_srp_roles
        WHERE salesrep_id = p_salesrep_id
        and org_id = p_org_id;

  --
  -- Get the comp plans , start_date and End Date
  -- Added KS
   CURSOR get_plan_assigns
     (p_role_id NUMBER,
      p_salesrep_id NUMBER,
      p_org_id NUMBER) IS
         SELECT comp_plan_id,
           start_date,
           end_date
           FROM cn_srp_plan_assigns
           WHERE role_id = p_role_id
           AND salesrep_id = p_salesrep_id
           AND org_id = p_org_id;

   l_old_period_set_id NUMBER;

      CURSOR get_affected_reps IS
      select sr.srp_role_id, rp.role_plan_id
	from cn_srp_pay_groups spg, cn_pay_groups pg,
	     cn_srp_roles sr, cn_role_plans rp
       where spg.end_date is null
         and spg.pay_group_id = pg.pay_group_id
         and pg.pay_group_id  = p_paygroup_rec.pay_group_id
         and sr.salesrep_id   = spg.salesrep_id
         and sr.org_id        = spg.org_id
	 and sr.role_id       = rp.role_id
	 and greatest(sr.start_date, rp.start_date) <=
	     least(nvl(sr.end_date, l_null_date),
		   nvl(rp.end_date, l_null_date));

BEGIN

   -- Standard Start of API savepoint

   SAVEPOINT    Update_PayGroup;

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- API body

    open get_old_pay_group;
    fetch get_old_pay_group into p_old_PayGroup_rec;
    close get_old_pay_group;

   --  check object version number

   l_old_ovn := p_old_PayGroup_rec.object_version_number;

   IF l_old_ovn <> p_PayGroup_rec.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

       Validate_PayGroup
     (
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PayGroup_rec       => p_PayGroup_rec,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status,
      x_status             => x_status
      );


   -- Added by Kumar Sivasankran on 26/JUL/01
   --Validate if start date is less than end date
    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF p_paygroup_rec.start_date IS NOT NULL --start date has been updated
     THEN
      IF p_paygroup_rec.end_date IS NOT NULL
	AND (p_paygroup_rec.start_date > p_paygroup_rec.end_date)
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
    ELSE
      IF p_old_paygroup_rec.end_date IS NOT NULL
	AND (p_paygroup_rec.start_date > p_old_paygroup_rec.end_date)
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
   END IF;

   get_PayGroup_id
     (x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PayGroup_rec       => p_old_PayGroup_rec,
      p_loading_status     => x_loading_status,
      x_pay_group_id       => l_pay_group_id,
      x_loading_status     => x_loading_status,
      x_status             => x_status
      );

   IF ( x_return_status  <> FND_API.G_RET_STS_SUCCESS )
     THEN

      RAISE fnd_api.g_exc_error;

    ELSIF x_status <>  'PAY GROUP EXISTS'
      THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PAY_GROUP');
         fnd_message.set_token('PAY_GROUP_NAME', p_old_PayGroup_rec.name);
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

   -- duplicate check at the time of update
   -- Added on 08/07/01
   -- Kumar.

    SELECT COUNT(*)
      INTO l_count
      FROM cn_pay_groups
     WHERE name = p_PayGroup_rec.name
       AND start_date = p_PayGroup_rec.start_date
       AND end_date = p_PayGroup_rec.end_date
       and org_id = p_PayGroup_rec.org_id
       AND pay_group_id <> l_pay_group_id;

    IF (l_count <> 0) THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_PAY_GROUP_EXISTS');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_PAY_GROUP_EXISTS';
      RAISE FND_API.G_EXC_ERROR;
   END IF ;

   --***********************************************************************
   -- Check Overlap
   --    Ensure paygroup do not overlap each other in same pay group name
   --    Returns an error message and raises an exception if overlap occurs.
   -- Added Kumar
   -- Date 25-OCT-2000
   --***********************************************************************
   BEGIN
      SELECT 1 INTO l_dummy FROM dual
        WHERE NOT EXISTS
        ( SELECT 1
          FROM   cn_pay_groups
          WHERE
                 ((end_date IS NOT NULL) AND
                  (p_paygroup_rec.end_date IS NOT NULL) AND
                  ((start_date BETWEEN p_paygroup_rec.start_date
                    AND p_Paygroup_rec.end_date) OR
                   (end_date BETWEEN p_Paygroup_rec.start_date
                    AND p_paygroup_rec.end_date) OR
                   (p_paygroup_rec.start_date BETWEEN start_date
                    AND end_date))
                  )
          AND  name   = p_paygroup_rec.name
          and org_id =  p_paygroup_rec.org_id
          AND  pay_group_id <> l_pay_group_id
        );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGROUP_OVERLAPS');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PAYGROUP_OVERLAPS';
         RAISE FND_API.G_EXC_ERROR ;
    END;


   SELECT COUNT(1)
     INTO l_count
     FROM cn_srp_pay_groups
     WHERE pay_group_id = l_pay_group_id;


   IF l_count <> 0
     THEN
      --select current definition of pay group and compare with new definition
      OPEN get_pay_group(l_pay_group_id);
      FETCH get_pay_group INTO l_pg_rec;
      CLOSE get_pay_group;

      SELECT MIN(start_date),MAX(end_date)
	INTO l_start_date,l_end_date
	FROM cn_srp_pay_groups
	WHERE pay_group_id = l_pay_group_id;

      IF l_start_date < p_paygroup_rec.start_date
	OR l_end_date > p_paygroup_rec.end_date
	THEN

	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_PAY_GROUP_CHANGE_NA');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_PAY_GROUP_CHANGE_NA';
	 x_loading_status := 'CN_PAY_GROUP_CHANGE_NA';
	 RAISE FND_API.G_EXC_ERROR;

      END IF;

   END IF;

   SELECT COUNT(1)
     INTO l_count
     FROM cn_role_pay_groups
     WHERE pay_group_id = l_pay_group_id;


   IF l_count <> 0
     THEN
      --select current definition of pay group and compare with new definition
      OPEN get_pay_group(l_pay_group_id);
      FETCH get_pay_group INTO l_pg_rec;
      CLOSE get_pay_group;

      SELECT MIN(start_date)
	INTO l_start_date
	FROM cn_role_pay_groups
	WHERE pay_group_id = l_pay_group_id;

      SELECT MAX(end_date)
	INTO l_end_date
	FROM cn_role_pay_groups
	WHERE pay_group_id = l_pay_group_id;


      IF l_start_date < p_paygroup_rec.start_date
	OR l_end_date > p_paygroup_rec.end_date
	THEN

	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_PAY_GROUP_CHANGE_ROLE_NA');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_PAY_GROUP_CHANGE_ROLE_NA';
	 x_loading_status := 'CN_PAY_GROUP_CHANGE_ROLE_NA';
	 RAISE FND_API.G_EXC_ERROR;

      END IF;
  END IF;

   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF ( x_return_status = FND_API.G_RET_STS_SUCCESS )
      THEN

      IF p_PayGroup_rec.period_set_name IS NOT NULL
	THEN

      --Check if period_set_name is valid
       OPEN get_period_set_id;
       FETCH get_period_set_id INTO l_period_set_id;
       IF get_period_set_id%ROWCOUNT = 0
       THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_INVALID_PRD_SET');
             fnd_msg_pub.add;
          END IF;

          x_loading_status := 'CN_INVALID_PRD_SET';
          CLOSE get_period_set_id;
          RAISE FND_API.G_EXC_ERROR;
       END IF;


       CLOSE get_period_set_id;
       ELSE
	 l_period_set_id := cn_api.g_miss_id;
      END IF;

      --Check if period_type is valid
      IF p_paygroup_rec.period_type IS NOT NULL
	THEN

       OPEN get_period_type_id;
       FETCH get_period_type_id INTO l_period_type_id;
       IF get_period_type_id%ROWCOUNT = 0
       THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_INVALID_PERIOD_TYPE');
             fnd_msg_pub.add;
          END IF;

          x_loading_status := 'CN_INVALID_PERIOD_TYPE';
          CLOSE get_period_type_id;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       CLOSE get_period_type_id;
       ELSE
	 l_period_type_id := cn_api.g_miss_id;
      END IF;

      select 1 into l_valid_data from dual where exists
      (select count(cp.pay_date) from
       cn_srp_pay_groups cspg,cn_payment_worksheets cpw,cn_payruns cp
       where
       cp.payrun_id = cpw.payrun_id and cp.pay_group_id = cspg.pay_group_id and
       cp.org_id = cpw.org_id and cp.org_id = cspg.org_id and
       cpw.salesrep_id = cspg.salesrep_id and cpw.org_id = cspg.org_id and
       cspg.pay_group_id=p_PayGroup_rec.pay_group_id and cpw.quota_id is null);

      if(l_valid_data = 1) then
      begin
      select max(cps.end_date) into l_pay_period_end_date  from
      cn_srp_pay_groups cspg,cn_payment_worksheets cpw,cn_payruns cp,cn_period_statuses cps
      where
      cp.payrun_id = cpw.payrun_id and cp.pay_group_id = cspg.pay_group_id and
      cp.org_id = cpw.org_id and cp.org_id = cspg.org_id and
      cpw.salesrep_id = cspg.salesrep_id and cpw.org_id = cspg.org_id and
      cspg.pay_group_id=p_PayGroup_rec.pay_group_id and cpw.quota_id is null
      and cp.pay_period_id = cps.period_id and cp.org_id = cps.org_id;

      if(p_PayGroup_rec.end_date < l_pay_period_end_date) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PG_CANNOT_SHORTEN_ED');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PG_CANNOT_SHORTEN_ED';
         RAISE FND_API.G_EXC_ERROR ;
      end if;
      end;
      end if;



 --***********************************************************************
   -- Check Period Type Updateable Allowed
   --    Ensure Period Type is not updateable if payment has already used
   --    this paygroup
   --    Added Kumar Sivasankaran
   -- Date 09-NOV-2001
   --    Added Period_set_name also in the validation
   -- Date 30-NOV-2001
   --
   --***********************************************************************


   IF p_old_PayGroup_rec.period_type <> p_PayGroup_rec.period_type or
      p_old_PayGroup_rec.period_set_name <> p_payGroup_Rec.period_set_name THEN
     BEGIN
      SELECT 1 INTO l_dummy FROM dual
        WHERE NOT EXISTS
        ( SELECT 1
            FROM cn_pay_groups pg,
                 cn_payruns p
           WHERE pg.pay_group_id = p.pay_group_id
             and pg.org_id = p.org_id
             AND pg.pay_group_id = l_pay_group_id
        );
      EXCEPTION

      WHEN NO_DATA_FOUND THEN

       IF p_old_PayGroup_rec.period_type <> p_PayGroup_rec.period_type THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGRP_PRD_TYPE_NOT_UPD');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PAYGRP_PRD_TYPE_NOT_UPD';
         RAISE FND_API.G_EXC_ERROR ;
       END IF;

       IF p_old_PayGroup_rec.period_set_name <> p_PayGroup_rec.period_set_name THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGRP_PRD_SNAME_NOT_UPD');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PAYGRP_PRD_SNAME_NOT_UPD';
         RAISE FND_API.G_EXC_ERROR ;
       END IF;

    END;


    BEGIN
       SELECT 1 INTO l_dummy FROM dual
        WHERE NOT EXISTS
        ( SELECT 1
            FROM cn_srp_periods csp,
                 cn_posting_details_sum cpd,
                 cn_srp_pay_groups spg
           WHERE cpd.credited_salesrep_id = spg.salesrep_id
             and cpd.pay_period_id = csp.period_id
             and csp.salesrep_id = cpd.credited_salesrep_id
             and csp.org_id = cpd.org_id
             and csp.org_id = spg.org_id
             and csp.start_date between spg.start_date and nvl(spg.end_date, csp.end_date)
             AND spg.pay_group_id = l_pay_group_id
        );

   EXCEPTION
     WHEN NO_DATA_FOUND THEN

     IF p_old_PayGroup_rec.period_type <> p_PayGroup_rec.period_type THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGRP_PRD_TYPE_NOT_UPDP');
           FND_MSG_PUB.Add;
         END IF;
       x_loading_status := 'CN_PAYGRP_PRD_TYPE_NOT_UPDP';
       RAISE FND_API.G_EXC_ERROR ;
     END IF;


     IF p_old_PayGroup_rec.period_set_name <> p_PayGroup_rec.period_set_name THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME ('CN' , 'CN_PAYGRP_PRD_SNAME_NOT_UPD');
            FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_PAYGRP_PRD_SNAME_NOT_UPDP';
         RAISE FND_API.G_EXC_ERROR ;
       END IF;


     END;



   END IF;

  -- Period Type is not update check


      Cn_Pay_Groups_Pkg.Begin_Record(
	     x_operation            => 'UPDATE',
	     x_rowid                => L_ROWID,
	     x_pay_group_id         => l_pay_group_id,
	     x_name                 => p_PayGroup_rec.name,
	     x_period_set_name      => p_PayGroup_rec.period_set_name,
	     x_period_type          => p_PayGroup_rec.period_type,
	     x_start_date           => p_PayGroup_rec.start_date,
	     x_end_date             => p_PayGroup_rec.end_date,
	     x_pay_group_description=> p_PayGroup_rec.pay_group_description,
             x_period_set_id        => l_period_set_id,
             x_period_type_id       => l_period_type_id,
	     x_attribute_category   => p_PayGroup_rec.attribute_category,
	     x_attribute1           => p_PayGroup_rec.attribute1,
	     x_attribute2           => p_PayGroup_rec.attribute2,
	     x_attribute3           => p_PayGroup_rec.attribute3,
	     x_attribute4           => p_PayGroup_rec.attribute4,
	     x_attribute5           => p_PayGroup_rec.attribute5,
	     x_attribute6           => p_PayGroup_rec.attribute6,
	     x_attribute7           => p_PayGroup_rec.attribute7,
	     x_attribute8           => p_PayGroup_rec.attribute8,
	     x_attribute9           => p_PayGroup_rec.attribute9,
     	     x_attribute10          => p_PayGroup_rec.attribute10,
 	     x_attribute11          => p_PayGroup_rec.attribute10,
	     x_attribute12          => p_PayGroup_rec.attribute12,
	     x_attribute13          => p_PayGroup_rec.attribute13,
	     x_attribute14          => p_PayGroup_rec.attribute14,
	     x_attribute15          => p_PayGroup_rec.attribute15,
	     x_last_update_date     => l_last_update_date,
	     x_last_updated_by      => l_last_updated_by,
	     x_creation_date        => l_creation_date,
	     x_created_by           => l_created_by,
	     x_last_update_login    => l_last_update_login,
	     x_program_type         => l_program_type,
	     x_object_version_number => L_OBJECT_VERSION_NUMBER,
	     x_org_id               => p_PayGroup_rec.org_id
	    );
   END IF;

   -- if reps are assigned with null end date, then propogate changes to
   -- their srp_plan_assigns (fix for bug 4529601)
   FOR s IN get_affected_reps LOOP
      -- mop up changes in cn_srp_plan_assigns for this rep
      cn_srp_plan_assigns_pvt.update_srp_plan_assigns
	(p_api_version    => 1.0,
	 x_return_status  => x_return_status,
	 x_msg_count      => x_msg_count,
	 x_msg_data       => x_msg_data,
	 p_srp_role_id    => s.srp_role_id,
	 p_role_plan_id   => s.role_plan_id,
	 p_attribute_rec  => NULL,
	 x_loading_status => x_loading_status);
   END LOOP;

   --**************************************************************************
   -- Create SRP Periods is the Period Type is different
   -- Added on 12/SEP/01
   -- Kumar Sivasankaran
   --**************************************************************************
   IF p_paygroup_rec.period_type <> p_old_PayGroup_rec.period_type THEN

      FOR srp_paygroup_rec IN  get_srp_pay_group_id_cur
	(l_pay_group_id,
	 p_PayGroup_rec.start_date,
	 p_PayGroup_rec.end_date,
	 p_PayGroup_rec.org_id )
     LOOP

    -- Call cn_srp_periods_pvt api to affect the records in cn_srp_periods
        FOR roles  IN get_roles(srp_paygroup_rec.salesrep_id,p_PayGroup_rec.org_id)
          LOOP


             FOR plans IN get_plan_assigns(roles.role_id,srp_paygroup_rec.salesrep_id,p_PayGroup_rec.org_id)
               LOOP



                  cn_srp_periods_pvt.create_srp_periods
                    ( p_api_version => p_api_version,
                      p_init_msg_list => fnd_api.g_false,
                      p_commit => fnd_api.g_false,
                      p_validation_level => p_validation_level,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      p_salesrep_id => srp_paygroup_rec.salesrep_id,
                      p_role_id => roles.role_id,
                      p_comp_plan_id => plans.comp_plan_id,
                      p_start_date => plans.start_date,
                      p_end_date => plans.end_date,
                      x_loading_status => x_loading_status);
                  IF ( x_return_status = FND_API.G_RET_STS_ERROR )
                    THEN
                     RAISE FND_API.G_EXC_ERROR;
                   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
                     THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END LOOP;
          END LOOP;

    END LOOP;

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
      ROLLBACK TO Update_PayGroup;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
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
END Update_PayGroup;

---------------------------------------------------------------------------+
--  Procedure Name :  Pay Groups
--+
---------------------------------------------------------------------------+
PROCEDURE  Delete_PayGroup
  (    p_api_version			    IN 	NUMBER,
       p_init_msg_list		        IN	VARCHAR2,
       p_commit	    		        IN  	VARCHAR2,
       p_validation_level		    IN  	NUMBER,
       x_return_status       	    OUT NOCOPY 	VARCHAR2,
       x_msg_count	                OUT NOCOPY 	NUMBER,
       x_msg_data		            OUT NOCOPY 	VARCHAR2,
       p_PayGroup_rec               IN  OUT NOCOPY PayGroup_rec_type ,
       x_status		                OUT NOCOPY 	VARCHAR2,
       x_loading_status    	        OUT NOCOPY 	VARCHAR2
       )  IS
L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PayGroup_PUB';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
L_OBJECT_VERSION_NUMBER     NUMBER;

	  l_api_name		CONSTANT VARCHAR2(30)
	    := 'Delete_PayGroup';
	  l_api_version         CONSTANT NUMBER := 1.0;
	  l_pay_group_id		NUMBER;
	  l_count               NUMBER;
       l_count_role         NUMBER;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Delete_PayGroup ;
   --
   -- Standard call to check for call compatibility.
   --
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_DELETED';

   -- API Body
   get_PayGroup_id(
			  x_return_status      => x_return_status,
			  x_msg_count          => x_msg_count,
			  x_msg_data           => x_msg_data,
			  p_PayGroup_rec       => p_PayGroup_rec,
			  p_loading_status     => x_loading_status,
			  x_pay_group_id       => l_pay_group_id,
			  x_loading_status     => x_loading_status,
			  x_status             => x_status
			  );


   IF ( x_return_status  <> FND_API.G_RET_STS_SUCCESS )
     THEN

      RAISE fnd_api.g_exc_error;

    ELSIF x_status <>  'PAY GROUP EXISTS'

      THEN



      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PAY_GROUP');
         fnd_message.set_token('PAY_GROUP_NAME', p_PayGroup_rec.name);
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      RAISE FND_API.G_EXC_ERROR ;

   END IF;
  SELECT COUNT(1)
     INTO l_count_role
     FROM cn_role_pay_groups
     WHERE pay_group_id = l_pay_group_id;

   IF l_count_role <> 0
      THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PAY_GROUP_ASSIGNED_TO_ROLE');
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_PAY_GROUP_ASSIGNED_TO_ROLE';
      RAISE FND_API.G_EXC_ERROR ;
 END IF;


   SELECT COUNT(1)
     INTO l_count
     FROM cn_srp_pay_groups
     WHERE pay_group_id = l_pay_group_id;

   IF l_count <> 0
      THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_PAY_GROUP_ASSIGNED_TO_SRP');
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_PAY_GROUP_CHANGE_NA';
      RAISE FND_API.G_EXC_ERROR ;

    ELSE
            cn_pay_groups_pkg.begin_record
	       (
	       x_operation            => 'DELETE',
	       x_rowid                => L_ROWID,
	       x_pay_group_id         => l_pay_group_id,
	       x_name                 => null,
	       x_period_set_name      => null,
	       x_period_type          => null,
	       x_start_date           => null,
	       x_end_date             => null,
	       x_pay_group_description=> null,
           x_period_set_id        => NULL,
	       x_period_type_id       => NULL,
	       x_attribute_category   => null,
	       x_attribute1           => null,
	       x_attribute2           => null,
	       x_attribute3           => null,
	       x_attribute4           => null,
	       x_attribute5           => null,
	       x_attribute6           => null,
	       x_attribute7           => null,
	       x_attribute8           => null,
	       x_attribute9           => null,
	       x_attribute10          => null,
	       x_attribute11          => null,
	       x_attribute12          => null,
	       x_attribute13          => null,
            x_attribute14          => null,
	       x_attribute15          => null,
	       x_last_update_date     => null,
	       x_last_updated_by      => l_last_updated_by,
	       x_creation_date        => l_creation_date,
	       x_created_by           => l_created_by,
	       x_last_update_login    => l_last_update_login,
	       x_program_type         => l_program_type,
	       x_object_version_number => L_OBJECT_VERSION_NUMBER,
	       x_org_id                => null
	       );
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
      ROLLBACK TO Delete_PayGroup;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_PayGroup;
      x_loading_status := 'UNEXPECTED_ERR';
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

END Delete_PayGroup;


END CN_PAYGROUP_PVT ;

/
