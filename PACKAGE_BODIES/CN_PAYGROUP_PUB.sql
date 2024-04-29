--------------------------------------------------------
--  DDL for Package Body CN_PAYGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYGROUP_PUB" as
-- $Header: cnppgrpb.pls 120.6 2005/11/02 22:01:09 sjustina ship $ --+


G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_PAYGROUP_PUB';
-- -------------------------------------------------------------------------+
--+
--  Procedure   : Get_PayGroup_ID
--  Description : This procedure is used to get the ID for the pay group
--  Calls       :
--+
-- -------------------------------------------------------------------------+
PROCEDURE Get_Pay_Group_Sum
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_search_name                 IN      VARCHAR2 := '%',
   p_search_start_date           IN      DATE := FND_API.G_MISS_DATE,
   p_search_end_date             IN      DATE := FND_API.G_MISS_DATE,
   p_search_period_set_name      IN      VARCHAR2 := '%',
   x_pay_group                   OUT NOCOPY     PayGroup_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2,
   p_org_id                      IN NUMBER := NULL
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Pay_Group_Sum';
     l_api_version        CONSTANT NUMBER       := 1.0;

     l_counter      NUMBER;
     CURSOR l_pay_group_cr(x_org_id NUMBER) IS
           SELECT name,
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
           FROM cn_pay_groups
	     WHERE upper(name) like upper(p_search_name)
	     and (p_search_start_date is null
		  OR ( trunc(start_date) >= trunc(p_search_start_date)
		       AND
		       (p_search_end_date is null OR (nvl(end_date,p_search_end_date) <= p_search_end_date))
		       )
		  )

	     and upper(period_set_name) like upper(p_search_period_set_name)
	     and org_id = x_org_id
     ORDER BY name;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Pay_Group_Sum;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

   x_pay_group := G_MISS_PAYGROUP_REC_TB ;
   /**Start of MOAC Org Validation change */
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_paygroup_pub.get_pay_group_sum.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
  end if;
   /**End of MOAC Org Validation change */

   l_counter := 0;
   x_total_record := 0;

   FOR l_pay_group IN l_pay_group_cr(l_org_id) LOOP

      x_total_record := x_total_record +1;
      IF (p_fetch_size = -1) OR (x_total_record >= p_start_record
	AND x_total_record <= (p_start_record + p_fetch_size - 1)) THEN
	 -- assign values of the row to x_srp_list



         x_pay_group(l_counter).name := l_pay_group.name;
         x_pay_group(l_counter).period_set_name := l_pay_group.period_set_name;
         x_pay_group(l_counter).period_type := l_pay_group.period_type;
         x_pay_group(l_counter).start_date := l_pay_group.start_date;
         x_pay_group(l_counter).end_date := l_pay_group.end_date;
         x_pay_group(l_counter).pay_group_description := l_pay_group.pay_group_description;
         x_pay_group(l_counter).object_version_number := l_pay_group.object_version_number;
         x_pay_group(l_counter).org_id := l_pay_group.org_id;

         l_counter := l_counter + 1;

      END IF;
   END LOOP;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Sum;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Pay_Group_Sum;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Pay_Group_Sum;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Get_Pay_Group_Sum;













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

      CURSOR get_PayGroup_id(x_org_id NUMBER) is
	 SELECT pay_group_id
	   FROM cn_pay_groups
	   WHERE name = p_PayGroup_rec.name
	   AND start_date = p_PayGroup_rec.start_date
	   AND end_date = p_PayGroup_rec.end_date
       and org_id= x_org_id;
      l_get_PayGroup_id_rec get_PayGroup_id%ROWTYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;


   OPEN get_PayGroup_id(l_org_id);
   FETCH get_PayGroup_id INTO l_get_PayGroup_id_rec;
   IF get_PayGroup_id%ROWCOUNT = 0
     THEN
      x_status := 'NEW PAY GROUP';
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
   l_create_rec          cn_paygroup_pvt.PayGroup_rec_type;

   l_pay_group_id	     NUMBER;
   L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PayGroup_PUB';
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
   /**Start of MOAC Org Validation change */
   l_org_id := p_PayGroup_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_paygroup_pub.create_paygroup.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
  end if;
   /**End of MOAC Org Validation change */

  p_PayGroup_rec.org_id := l_org_id;

     l_create_rec.pay_group_id := p_PayGroup_rec.pay_group_id;
     l_create_rec.name        :=	p_PayGroup_rec.name;
     l_create_rec.period_set_name := p_PayGroup_rec.period_set_name;
     l_create_rec.period_type	:= p_PayGroup_rec.period_type;
     l_create_rec.start_date :=		p_PayGroup_rec.start_date;
     l_create_rec.end_date	:=	p_PayGroup_rec.end_date;
     l_create_rec.pay_group_description := p_PayGroup_rec.pay_group_description;
     l_create_rec.attribute_category:= p_PayGroup_rec.attribute_category;
     l_create_rec.attribute1 := p_PayGroup_rec.attribute1;
     l_create_rec.attribute2 := p_PayGroup_rec.attribute2;
     l_create_rec.attribute3 := p_PayGroup_rec.attribute3;
     l_create_rec.attribute4 := p_PayGroup_rec.attribute4;
     l_create_rec.attribute5 := p_PayGroup_rec.attribute5;
     l_create_rec.attribute6 := p_PayGroup_rec.attribute6;
     l_create_rec.attribute7 := p_PayGroup_rec.attribute7;
     l_create_rec.attribute8 := p_PayGroup_rec.attribute8;
     l_create_rec.attribute9 := p_PayGroup_rec.attribute9;
     l_create_rec.attribute10 := p_PayGroup_rec.attribute10;
     l_create_rec.attribute11 := p_PayGroup_rec.attribute11;
     l_create_rec.attribute12 := p_PayGroup_rec.attribute12;
     l_create_rec.attribute13 := p_PayGroup_rec.attribute13;
     l_create_rec.attribute14 := p_PayGroup_rec.attribute14;
     l_create_rec.attribute15 := p_PayGroup_rec.attribute15;
     l_create_rec.object_version_number := p_PayGroup_rec.object_version_number;
     l_create_rec.org_id := p_PayGroup_rec.org_id;

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

   l_create_rec.pay_group_id := l_pay_group_id;


   cn_paygroup_pvt.create_Paygroup
   (p_api_version => p_api_version,
	p_init_msg_list => p_init_msg_list,
	p_commit => p_commit,
	p_validation_level => p_validation_level,
	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data,
	p_PayGroup_rec => l_create_rec,
	x_loading_status => x_loading_status,
	x_status => x_status
   );

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
		p_old_Paygroup_rec     IN  PayGroup_rec_type,
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
   l_update_rec          cn_paygroup_pvt.PayGroup_rec_type;
   l_pay_group_id            NUMBER;

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
   /**Start of MOAC Org Validation change */
   l_org_id := p_PayGroup_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_paygroup_pub.update_paygroup.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
  end if;

   if (l_org_id <> p_old_PayGroup_rec.org_id) then
    FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
    if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                      'cn.plsql.cn_paygroup_pub.update_paygroup.error',
                      true);
    end if;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
      FND_MSG_PUB.Add;
    END IF;

    RAISE FND_API.G_EXC_ERROR ;
  end if;
   /**End of MOAC Org Validation change */
   p_PayGroup_rec.org_id := l_org_id;

    get_PayGroup_id(
		      x_return_status      => x_return_status,
		      x_msg_count          => x_msg_count,
		      x_msg_data           => x_msg_data,
		      p_PayGroup_rec       => p_old_PayGroup_rec,
		      x_pay_group_id       => l_pay_group_id,
		      p_loading_status     => x_loading_status,
		      x_loading_status     => x_loading_status,
		      x_status             => x_status
		      );

     p_PayGroup_rec.pay_group_id :=  l_pay_group_id;

     l_update_rec.pay_group_id := p_PayGroup_rec.pay_group_id;
     l_update_rec.name        :=	p_PayGroup_rec.name;
     l_update_rec.period_set_name := p_PayGroup_rec.period_set_name;
     l_update_rec.period_type	:= p_PayGroup_rec.period_type;
     l_update_rec.start_date :=		p_PayGroup_rec.start_date;
     l_update_rec.end_date	:=	p_PayGroup_rec.end_date;
     l_update_rec.pay_group_description := p_PayGroup_rec.pay_group_description;
     l_update_rec.attribute_category:= p_PayGroup_rec.attribute_category;
     l_update_rec.attribute1 := p_PayGroup_rec.attribute1;
     l_update_rec.attribute2 := p_PayGroup_rec.attribute2;
     l_update_rec.attribute3 := p_PayGroup_rec.attribute3;
     l_update_rec.attribute4 := p_PayGroup_rec.attribute4;
     l_update_rec.attribute5 := p_PayGroup_rec.attribute5;
     l_update_rec.attribute6 := p_PayGroup_rec.attribute6;
     l_update_rec.attribute7 := p_PayGroup_rec.attribute7;
     l_update_rec.attribute8 := p_PayGroup_rec.attribute8;
     l_update_rec.attribute9 := p_PayGroup_rec.attribute9;
     l_update_rec.attribute10 := p_PayGroup_rec.attribute10;
     l_update_rec.attribute11 := p_PayGroup_rec.attribute11;
     l_update_rec.attribute12 := p_PayGroup_rec.attribute12;
     l_update_rec.attribute13 := p_PayGroup_rec.attribute13;
     l_update_rec.attribute14 := p_PayGroup_rec.attribute14;
     l_update_rec.attribute15 := p_PayGroup_rec.attribute15;
     l_update_rec.object_version_number := p_PayGroup_rec.object_version_number;
     l_update_rec.org_id := p_PayGroup_rec.org_id;

     cn_paygroup_pvt.Update_PayGroup (
		p_api_version => p_api_version,
		p_init_msg_list => p_init_msg_list,
		p_commit => p_commit,
		p_validation_level => p_validation_level,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_PayGroup_rec => l_update_rec,
		x_status => x_status,
		x_loading_status => x_loading_status
		);

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

	  l_api_name		CONSTANT VARCHAR2(30) := 'Delete_PayGroup';
	  l_api_version         CONSTANT NUMBER := 1.0;
	  l_delete_rec  cn_paygroup_pvt.PayGroup_rec_type;
	  l_pay_group_id         NUMBER;

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

   /**Start of MOAC Org Validation change */
   l_org_id := p_PayGroup_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,status => l_status);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'cn.plsql.cn_paygroup_pub.delete_paygroup.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = '||l_status);
  end if;
   /**End of MOAC Org Validation change */
   p_PayGroup_rec.org_id := l_org_id;

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

     p_PayGroup_rec.pay_group_id :=  l_pay_group_id;

     l_delete_rec.pay_group_id := p_PayGroup_rec.pay_group_id;
     l_delete_rec.name        :=	p_PayGroup_rec.name;
     l_delete_rec.period_set_name := p_PayGroup_rec.period_set_name;
     l_delete_rec.period_type	:= p_PayGroup_rec.period_type;
     l_delete_rec.start_date :=		p_PayGroup_rec.start_date;
     l_delete_rec.end_date	:=	p_PayGroup_rec.end_date;
     l_delete_rec.pay_group_description := p_PayGroup_rec.pay_group_description;
     l_delete_rec.attribute_category:= p_PayGroup_rec.attribute_category;
     l_delete_rec.attribute1 := p_PayGroup_rec.attribute1;
     l_delete_rec.attribute2 := p_PayGroup_rec.attribute2;
     l_delete_rec.attribute3 := p_PayGroup_rec.attribute3;
     l_delete_rec.attribute4 := p_PayGroup_rec.attribute4;
     l_delete_rec.attribute5 := p_PayGroup_rec.attribute5;
     l_delete_rec.attribute6 := p_PayGroup_rec.attribute6;
     l_delete_rec.attribute7 := p_PayGroup_rec.attribute7;
     l_delete_rec.attribute8 := p_PayGroup_rec.attribute8;
     l_delete_rec.attribute9 := p_PayGroup_rec.attribute9;
     l_delete_rec.attribute10 := p_PayGroup_rec.attribute10;
     l_delete_rec.attribute11 := p_PayGroup_rec.attribute11;
     l_delete_rec.attribute12 := p_PayGroup_rec.attribute12;
     l_delete_rec.attribute13 := p_PayGroup_rec.attribute13;
     l_delete_rec.attribute14 := p_PayGroup_rec.attribute14;
     l_delete_rec.attribute15 := p_PayGroup_rec.attribute15;
     l_delete_rec.object_version_number := p_PayGroup_rec.object_version_number;
     l_delete_rec.org_id := p_PayGroup_rec.org_id;

    cn_paygroup_pvt.Delete_PayGroup
  (    p_api_version => p_api_version,
       p_init_msg_list => p_init_msg_list,
       p_commit => p_commit,
       p_validation_level => p_validation_level,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_PayGroup_rec => l_delete_rec,
       x_status => x_status,
       x_loading_status => x_loading_status
       );

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

END CN_PAYGROUP_PUB ;

/
