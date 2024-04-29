--------------------------------------------------------
--  DDL for Package Body CN_SRP_PAYGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PAYGROUP_PUB" as
-- $Header: cnpspgpb.pls 120.12 2006/10/05 09:59:16 chanthon noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PayGroup_PUB';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpspgpb.pls';

procedure get_date_range_intersect(a_start_date in date, a_end_date in date,
                                   b_start_date in date, b_end_date in date,
                         x_start_date out nocopy date, x_end_date out nocopy date)
IS
BEGIN
   if ( a_start_date is null or b_start_date is null) then
     x_start_date := null;
     x_end_date := null;
   elsif (a_end_date is not null and a_end_date < b_start_date)
      or ( b_end_date is not null and a_start_date > b_end_date) then
       x_start_date := null;
       x_end_date := null;
   else
     x_start_date := greatest(a_start_date, b_start_date);
     if a_end_date is null then
       x_end_date := b_end_date;
     elsif b_end_date is null then
       x_end_date := a_end_date;
     else
       x_end_date := least(a_end_date, b_end_date);
     end if;
   end if;
END;

procedure get_masgn_date_intersect(
    p_role_pay_group_id IN NUMBER,
    p_srp_role_id IN NUMBER,
    x_start_date OUT NOCOPY DATE,
    x_end_date OUT NOCOPY DATE) IS

  l_start_date cn_srp_pay_groups.start_date%TYPE;
  l_end_date cn_srp_pay_groups.start_date%TYPE;


  l_res_start_date cn_srp_pay_groups.start_date%TYPE;
  l_res_end_date cn_srp_pay_groups.start_date%TYPE;

  l_role_pg_start_date cn_srp_pay_groups.start_date%TYPE;
  l_role_pg_end_date cn_srp_pay_groups.start_date%TYPE;

  l_srp_role_start_date cn_srp_pay_groups.start_date%TYPE;
  l_srp_role_end_date cn_srp_pay_groups.start_date%TYPE;

  l_pg_start_date cn_srp_pay_groups.start_date%TYPE;
  l_pg_end_date cn_srp_pay_groups.start_date%TYPE;

  l_org_id NUMBER;
  l_salesrep_id NUMBER;
  l_pay_group_id NUMBER;
BEGIN
  -- get start_date, end_date org_id and pay_group_id from role_pay_groups
  select org_id, pay_group_id, start_date, end_date
  into l_org_id, l_pay_group_id, l_role_pg_start_date, l_role_pg_end_date
  from cn_role_pay_groups
  where role_pay_group_id = p_role_pay_group_id;

  -- get srp role assignment start and end dates
  select start_date, end_date, salesrep_id
  into l_srp_role_start_date, l_srp_role_end_date, l_salesrep_id
  from cn_srp_roles
  where srp_role_id = p_srp_role_id
    and org_id = l_org_id;

  -- get intersection between srp_role and role_pay_group dates
  get_date_range_intersect(
	 	a_start_date => l_srp_role_start_date,
         	a_end_date   => l_srp_role_end_date,
         	b_start_date => l_role_pg_start_date,
         	b_end_date   => l_role_pg_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

  l_start_date := x_start_date;
  l_end_date := x_end_date;

  -- get resource start and end dates
  select start_date_active, end_date_active
  into l_res_start_date, l_res_end_date
  from cn_salesreps
  where salesrep_id = l_salesrep_id
    and org_id = l_org_id;

  -- get intersection with resource start and end dates
  get_date_range_intersect(
	 	a_start_date => l_start_date,
         	a_end_date   => l_end_date,
         	b_start_date => l_res_start_date,
         	b_end_date   => l_res_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

  l_start_date := x_start_date;
  l_end_date := x_end_date;

  -- get pay groups start and end dates
  select start_date, end_date
  into l_pg_start_date, l_pg_end_date
  from cn_pay_groups
  where pay_group_id = l_pay_group_id;

  -- get intersection with pay group start and end dates
  get_date_range_intersect(
	 	a_start_date => l_start_date,
         	a_end_date   => l_end_date,
         	b_start_date => l_pg_start_date,
         	b_end_date   => l_pg_end_date,
         	x_start_date => x_start_date,
         	x_end_date   => x_end_date);

END;

--| -----------------------------------------------------------------------+
--| Function Name :  chk_and get_salesrep_id
--| Desc : Based on the employee number and salesrep type passed in,
--|        Check if only one rec retrieve, if yes get the salesrep_id
--|        Created to fix the customer Bug which has same employee number
--|	   only happed for multiple contacts for the supplier
--|        Added By Kumar Sivasankran Dated on 05/OCT/01
--|
--| ---------------------------------------------------------------------+
PROCEDURE  chk_and_get_salesrep_id( p_emp_num         IN VARCHAR2,
                                    p_type            IN VARCHAR2,
                                    p_source_id       IN NUMBER,
				    p_org_id          IN NUMBER,
                                    x_salesrep_id     OUT NOCOPY cn_salesreps.salesrep_id%TYPE,
                                    x_return_status   OUT NOCOPY VARCHAR2,
                                    x_loading_status  OUT NOCOPY VARCHAR2) IS

    l_salesrep_id  cn_salesreps.salesrep_id%TYPE;
    l_emp_num      cn_salesreps.employee_number%TYPE;
    p_show_message VARCHAR2(1);
BEGIN
   -- change for performance. Force to hit index on employee_number
   -- Bug 1508614
   -- Fixed on 25/0ct/2001
   p_show_message := fnd_api.g_true;
   l_emp_num := upper(p_emp_num);

   IF p_emp_num IS NULL THEN
      SELECT salesrep_id
        INTO l_salesrep_id
        FROM cn_salesreps
        WHERE employee_number IS NULL
          AND source_id = p_source_id
	  AND org_id = p_org_id
          AND ((type = p_type) OR (type IS NULL AND p_type IS NULL));
    ELSE
      SELECT /*+ first_rows */ salesrep_id
        INTO l_salesrep_id
        FROM cn_salesreps
        WHERE upper(employee_number) = l_emp_num
        AND source_id 		     = p_source_id
	AND org_id                   = p_org_id
        AND ((type = p_type) OR (type IS NULL AND p_type IS NULL));
   END IF;

   x_salesrep_id := l_salesrep_id;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_SALESREP_FOUND';

EXCEPTION
   WHEN no_data_found THEN
      x_salesrep_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_loading_status := 'CN_SALESREP_NOT_FOUND';
     IF (p_show_message = FND_API.G_TRUE) THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
            FND_MESSAGE.SET_NAME ('CN', 'CN_SALESREP_NOT_FOUND');
            FND_MSG_PUB.Add;
         END IF;
      END IF;
   WHEN too_many_rows THEN
      x_salesrep_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_loading_status := 'CN_SALESREP_TOO_MANY_ROWS';
      IF (p_show_message = FND_API.G_TRUE) THEN
         -- Error, check the msg level and add an error message to the
         -- API message list
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
            FND_MESSAGE.SET_NAME ('CN', 'CN_SALESREP_TOO_MANY_ROWS');
            FND_MSG_PUB.Add;
         END IF;
      END IF;
END chk_and_get_salesrep_id;

-- -------------------------------------------------------------------------+
-- Procedure   : ASSIGN_SALESREPS
-- Description : To assign pay groups to a salesperson
-- -------------------------------------------------------------------------+

PROCEDURE Assign_salesreps
  ( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count  		        OUT NOCOPY NUMBER,
	x_msg_data		        OUT NOCOPY VARCHAR2,
        p_paygroup_assign_rec           IN      PayGroup_assign_rec,
        x_loading_status	        OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
	) IS

   l_api_name		CONSTANT VARCHAR2(30) := 'assign_salesreps';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_pay_group_id                NUMBER;
   l_org_id                      NUMBER;
   l_srp_pay_group_id	         NUMBER;
   l_salesrep_id	 	 cn_srp_pay_groups.salesrep_id%TYPE;
   l_null_date          CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');
   l_status                      VARCHAR2(1);

   l_pay_group_name    cn_pay_groups.name%TYPE;
   l_create_rec        cn_srp_paygroup_pvt.paygroup_assign_rec;

   CURSOR get_pay_group_id_cur IS
      SELECT pay_group_id
	FROM cn_pay_groups_all
       WHERE name = p_paygroup_assign_rec.pay_group_name
	 AND org_id = l_org_id;
   l_get_pay_group_id_rec 	get_pay_group_id_cur%ROWTYPE;

   --
   --Declaration for user hooks
   --
   l_paygroup_assign_rec        paygroup_assign_rec;
   l_OAI_array		        JTF_USR_HKS.oai_data_array_type;
   l_bind_data_id               NUMBER;

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    assign_salesreps;


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
   x_loading_status := 'CN_INSERTED';

   --
   -- Assign the parameter to a local variable
   --
   l_paygroup_assign_rec := p_paygroup_assign_rec;

   --
   -- API body
   --

   --
   --Validate the input parameters
   --

   --
   --Validate org id
   --
   l_org_id := l_paygroup_assign_rec.org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_paygroup_pub.assign_salesreps.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   --
   --Validate pay group Name
   --
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => l_paygroup_assign_rec.pay_group_name,
	  p_obj_name  => 'Pay Group Name',
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Fetch pay_group_id
   OPEN get_pay_group_id_cur;
   FETCH get_pay_group_id_cur INTO l_get_pay_group_id_rec;

   --
   --Check to ensure that the specified pay group actually exists
   --If it does not exist, raise an error
   --
   IF get_pay_group_id_cur%ROWCOUNT <> 1
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_GROUP');
         fnd_message.set_token('PAY_GROUP_NAME', l_paygroup_assign_rec.pay_group_name);
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      CLOSE get_pay_group_id_cur;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   --
   --Pay group exists, fetch id
   --
   l_pay_group_id := l_get_pay_group_id_rec.pay_group_id;
   CLOSE get_pay_group_id_cur;

   --
   --Process the salesrep that has to be assigned to the pay group
   --

   --
   -- Check to ensure that the salesrep actually exists
   -- Fetch salesrep ID
   --

   --**************************************************************
   -- added Kumar Sivasankaran
   -- Dated on 05/OCT/01
   --
   -- Added new procedure to handle multiple supplier contact
   --
   --**************************************************************
   IF l_paygroup_assign_rec.employee_type = 'SUPPLIER_CONTACT' THEN

       chk_and_get_salesrep_id( p_emp_num	    =>
				l_paygroup_assign_rec.employee_number,
				p_type	    =>
				l_paygroup_assign_rec.employee_type,
				p_source_id     =>  l_paygroup_assign_rec.source_id,
				p_org_id        => l_org_id,
				x_salesrep_id   => l_salesrep_id,
				x_return_status => x_return_status,
				x_loading_status=> x_loading_status);

   ELSE
      cn_api.chk_and_get_salesrep_id( p_emp_num	    =>
				      l_paygroup_assign_rec.employee_number,
				      p_type	    =>
				      l_paygroup_assign_rec.employee_type,
				      p_org_id        => l_org_id,
				      x_salesrep_id   => l_salesrep_id,
				      x_return_status => x_return_status,
				      x_loading_status=> x_loading_status);
   END IF;


   IF x_loading_status = 'CN_SALESREP_FOUND'
     THEN
      --
      --Reset the loading status
      --
      x_loading_status := 'CN_INSERTED';
    ELSE
      RAISE fnd_api.g_exc_error;
   END IF;

   --
   -- User hooks
   --

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'ASSIGN_SALESREPS',
				'B',
				'C')
     THEN
      cn_srp_paygroup_pub_cuhk.assign_salesreps_pre
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'ASSIGN_SALESREPS',
				'B',
				'V')
     THEN
      cn_srp_paygroup_pub_vuhk.assign_salesreps_pre
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- call main API

   -- build rec type
   l_create_rec.salesrep_id           := l_salesrep_id;
   l_create_rec.pay_group_id          := l_pay_group_id;
   l_create_rec.assignment_start_date := l_paygroup_assign_rec.assignment_start_date;
   l_create_rec.assignment_end_date   := l_paygroup_assign_rec.assignment_end_date;
   l_create_rec.lock_flag             := l_paygroup_assign_rec.lock_flag;
   l_create_rec.role_pay_group_id     := l_paygroup_assign_rec.role_pay_group_id;
   l_create_rec.org_id                := l_org_id;
   l_create_rec.attribute_category    := l_paygroup_assign_rec.attribute_category;
   l_create_rec.attribute1            := l_paygroup_assign_rec.attribute1;
   l_create_rec.attribute2            := l_paygroup_assign_rec.attribute2;
   l_create_rec.attribute3            := l_paygroup_assign_rec.attribute3;
   l_create_rec.attribute4            := l_paygroup_assign_rec.attribute4;
   l_create_rec.attribute5            := l_paygroup_assign_rec.attribute5;
   l_create_rec.attribute6            := l_paygroup_assign_rec.attribute6;
   l_create_rec.attribute7            := l_paygroup_assign_rec.attribute7;
   l_create_rec.attribute8            := l_paygroup_assign_rec.attribute8;
   l_create_rec.attribute9            := l_paygroup_assign_rec.attribute9;
   l_create_rec.attribute10           := l_paygroup_assign_rec.attribute10;
   l_create_rec.attribute11           := l_paygroup_assign_rec.attribute11;
   l_create_rec.attribute12           := l_paygroup_assign_rec.attribute12;
   l_create_rec.attribute13           := l_paygroup_assign_rec.attribute13;
   l_create_rec.attribute14           := l_paygroup_assign_rec.attribute14;
   l_create_rec.attribute15           := l_paygroup_assign_rec.attribute15;

   cn_srp_paygroup_pvt.Create_Srp_Pay_Group
     (  p_api_version              => 1.0,
  	x_return_status		   => x_return_status,
  	x_loading_status           => x_loading_status,
  	x_msg_count		   => x_msg_count,
  	x_msg_data		   => x_msg_data,
  	p_paygroup_assign_rec      => l_create_rec);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --
   -- End of API body.
   --

   --
   -- Post processing hooks
   --


   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'ASSIGN_SALESREPS',
				'A',
				'V')
     THEN
      cn_srp_paygroup_pub_vuhk.assign_salesreps_post
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'ASSIGN_SALESREPS',
				'A',
				'C')
     THEN
      cn_srp_paygroup_pub_cuhk.assign_salesreps_post
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_execute('CN_SRP_PAYGROUP_PUB',
				'ASSIGN_SALESREPS',
				'M',
				'M')
     THEN
      IF  cn_srp_paygroup_pub_cuhk.ok_to_generate_msg
	 (p_paygroup_assign_rec         => l_paygroup_assign_rec)
	THEN

	 -- Get a ID for workflow/ business object instance
	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	 --  Do this for all the bind variables in the Business Object
	 JTF_USR_HKS.load_bind_data
	   (  l_bind_data_id, 'SRP_PAY_GROUP_ID', l_srp_pay_group_id, 'S', 'S');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'SRP_PGRP',
	    p_bus_obj_name => 'SRP_PAYGROUP',
	    p_action_code  => 'I',
	    p_bind_data_id => l_srp_pay_group_id,
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
      END IF;
   END IF;



   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
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
      ROLLBACK TO Assign_salesreps;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Assign_salesreps;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Assign_salesreps;
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

END Assign_salesreps;

-- -------------------------------------------------------------------------+
-- Procedure   : Update_srp_assignment
-- Description : TO update the salesrep assignment to a paygroup
-- -------------------------------------------------------------------------+

PROCEDURE Update_srp_assignment
  ( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        p_old_paygroup_assign_rec       IN      PayGroup_assign_rec,
        p_paygroup_assign_rec           IN      PayGroup_assign_rec,
        p_ovn                           IN      NUMBER,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
	) IS

   l_api_name		CONSTANT VARCHAR2(30) := 'Update_srp_assignment';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_pay_group_id                NUMBER;
   l_srp_pay_group_id	         NUMBER;
   l_salesrep_id	 	 cn_srp_pay_groups.salesrep_id%TYPE;
   l_old_salesrep_id             cn_srp_pay_groups.salesrep_id%TYPE;
   l_org_id	         	 cn_srp_pay_groups.org_id%TYPE;
   l_null_date          CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');
   l_ovn_old	                 NUMBER;
   l_count                       NUMBER;
   l_role_pay_group_id           cn_role_pay_groups.role_pay_group_id%TYPE;
   l_status                      VARCHAR2(1);

   --
   --Declaration for user hooks
   --
   l_OAI_array		        JTF_USR_HKS.oai_data_array_type;
   l_old_paygroup_assign_rec    paygroup_assign_rec;
   l_paygroup_assign_rec        paygroup_assign_rec;
   l_update_rec                 cn_srp_paygroup_pvt.paygroup_assign_rec;
   l_bind_data_id               NUMBER;

   CURSOR get_pay_group_id_cur(p_name VARCHAR2, p_org_id NUMBER) IS
      SELECT pay_group_id
	FROM cn_pay_groups_all
       WHERE name = p_name
	 AND org_id = p_org_id;
   l_old_pay_group_id 	cn_pay_groups.pay_group_id%TYPE;

   CURSOR get_srp_pay_group_id_cur (
           c_salesrep_id cn_srp_pay_groups.salesrep_id%TYPE,
           c_pay_group_id cn_srp_pay_groups.pay_group_id%TYPE,
           c_start_date cn_srp_pay_groups.start_date%TYPE,
           c_end_date cn_srp_pay_groups.end_date%TYPE) IS
      SELECT srp_pay_group_id
	FROM cn_srp_pay_groups_all
       WHERE salesrep_id = c_salesrep_id
	 AND pay_group_id = c_pay_group_id
         AND trunc(start_date) = trunc(c_start_date)
	 AND trunc(nvl(end_date,   l_null_date)) =
	     trunc(nvl(c_end_date, l_null_date));

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    update_srp_assignment;


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
   x_loading_status := 'CN_UPDATED';

   --
   -- Assign the parameter to a local variable
   --
   l_paygroup_assign_rec := p_paygroup_assign_rec;
   l_old_paygroup_assign_rec := p_old_paygroup_assign_rec;

   -- API body
   --

   --
   --Validate the input parameters
   --

   --
   --Validate org ID
   --

   if nvl(l_paygroup_assign_rec.org_id, -99) <>
      Nvl(l_old_paygroup_assign_rec.org_id, -99) then
      FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
      if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
			 'cn.plsql.cn_srp_paygroup_pub.update_srp_assignment.error',
			 true);
      end if;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	 FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR ;
   end if;

   l_org_id := l_old_paygroup_assign_rec.org_id;
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_paygroup_pub.update_srp_assignment.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   --
   --Validate pay group Name
   --
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => l_old_paygroup_assign_rec.pay_group_name,
	  p_obj_name  =>
	   cn_api.get_lkup_meaning('PAY_GROUP_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Fetch pay_group_id
   OPEN get_pay_group_id_cur(l_old_paygroup_assign_rec.pay_group_name, l_org_id);
   FETCH get_pay_group_id_cur INTO l_old_pay_group_id;


   --
   --Check to ensure that the specified pay group actually exists
   --If it does not exist, raise an error
   --
   IF get_pay_group_id_cur%ROWCOUNT <> 1
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_GROUP');
         fnd_message.set_token('PAY_GROUP_NAME',
			       l_old_paygroup_assign_rec.pay_group_name);
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      CLOSE get_pay_group_id_cur;
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   --
   --Pay group exists, close cursor
   --
   CLOSE get_pay_group_id_cur;


   --
   --Check for the current paygroup definition
   --

   --org cannot change - no need to validate new org ID since it is ignored

   --
   --Validate pay group Name
   --
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => l_paygroup_assign_rec.pay_group_name,
	  p_obj_name  =>
	  cn_api.get_lkup_meaning('PAY_GROUP_NAME', 'PAY_GROUP_VALIDATION_TYPE'),
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE )
     THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Fetch pay_group_id
   OPEN get_pay_group_id_cur(l_paygroup_assign_rec.pay_group_name, l_org_id);
   FETCH get_pay_group_id_cur INTO l_pay_group_id;

   --
   --Check to ensure that the specified pay group actually exists
   --If it does not exist, raise an error
   --
   IF get_pay_group_id_cur%ROWCOUNT <> 1
     THEN

      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
         fnd_message.set_name('CN', 'CN_INVALID_PAY_GROUP');
         fnd_message.set_token('PAY_GROUP_NAME', l_paygroup_assign_rec.pay_group_name);
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_PAY_GROUP';
      CLOSE get_pay_group_id_cur;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   --
   --Pay group exists, close cursor
   --
   CLOSE get_pay_group_id_cur;


   --
   -- Process  the salesrep that has to be assigned to the pay group
   --
   --
   -- Check to ensure that the salesrep actually exists
   -- Fetch salesrep ID
   --
   --**************************************************************
   -- added Kumar Sivasankaran
   -- Dated on 05/OCT/01
   --
   -- Added new procedure to handle multiple supplier contact
   --
   --**************************************************************
   IF l_paygroup_assign_rec.employee_type = 'SUPPLIER_CONTACT' THEN

       chk_and_get_salesrep_id( p_emp_num	    =>
				l_paygroup_assign_rec.employee_number,
				p_type	    =>
				l_paygroup_assign_rec.employee_type,
				p_source_id     => l_paygroup_assign_rec.source_id,
				p_org_id        => l_org_id,
				x_salesrep_id   => l_salesrep_id,
				x_return_status => x_return_status,
				x_loading_status=> x_loading_status);

   ELSE

       cn_api.chk_and_get_salesrep_id( p_emp_num	    =>
				       l_paygroup_assign_rec.employee_number,
				       p_type	    =>
				       l_paygroup_assign_rec.employee_type,
				       p_org_id    => l_org_id,
				       x_salesrep_id   => l_salesrep_id,
				       x_return_status => x_return_status,
				       x_loading_status=> x_loading_status);
   END IF;



   IF x_loading_status = 'CN_SALESREP_FOUND'
     THEN
      --
      --Reset the loading status
      --
      x_loading_status := 'CN_UPDATED';
    ELSE
      RAISE fnd_api.g_exc_error;
   END IF;

 --**************************************************************
   -- added Kumar Sivasankaran
   -- Dated on 05/OCT/01
   --
   -- Added new procedure to handle multiple supplier contact
   --
   --**************************************************************
   IF l_old_paygroup_assign_rec.employee_type = 'SUPPLIER_CONTACT' THEN

       chk_and_get_salesrep_id( p_emp_num	    =>
				l_old_paygroup_assign_rec.employee_number,
				p_type	    =>
				l_old_paygroup_assign_rec.employee_type,
				p_source_id     => l_paygroup_assign_rec.source_id,
				p_org_id        => l_org_id,
				x_salesrep_id   => l_old_salesrep_id,
				x_return_status => x_return_status,
				x_loading_status=> x_loading_status);

   ELSE

   cn_api.chk_and_get_salesrep_id( p_emp_num	   =>
				   l_old_paygroup_assign_rec.employee_number,
				   p_type	   =>
				   l_old_paygroup_assign_rec.employee_type,
				   p_org_id        => l_org_id,
				   x_salesrep_id   => l_old_salesrep_id,
				   x_return_status => x_return_status,
				   x_loading_status=> x_loading_status);

   END IF;


   IF x_loading_status = 'CN_SALESREP_FOUND'
     THEN
      --
      --Reset the loading status
      --
      x_loading_status := 'CN_UPDATED';
    ELSE
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN get_srp_pay_group_id_cur(l_old_salesrep_id,
				 l_old_pay_group_id,
                     l_old_paygroup_assign_rec.assignment_start_date,
                     l_old_paygroup_assign_rec.assignment_end_date);

   FETCH get_srp_pay_group_id_cur INTO l_srp_pay_group_id;

   IF get_srp_pay_group_id_cur%rowcount = 0
     THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_INVALID_SRP_PGRP_ASGN');
	 fnd_message.set_token('EMPLOYEE_TYPE',
			       l_old_paygroup_assign_rec.employee_type);
	 fnd_message.set_token('EMPLOYEE_NUMBER',
			       l_old_paygroup_assign_rec.employee_number);
	 fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_SRP_PGRP_ASGN';
      CLOSE get_srp_pay_group_id_cur;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE get_srp_pay_group_id_cur;

   --
   -- User hooks
   --

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'UPDATE_SRP_ASSIGNMENT',
				'B',
				'C')
     THEN
      cn_srp_paygroup_pub_cuhk.update_srp_assignment_pre
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 p_old_paygroup_assign_rec      => l_old_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'UPDATE_SRP_ASSIGNMENT',
				'B',
				'V')
     THEN
      cn_srp_paygroup_pub_vuhk.update_srp_assignment_pre
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 p_old_paygroup_assign_rec      => l_old_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- main API

   -- build update rec
   l_update_rec.srp_pay_group_id      := l_srp_pay_group_id;
   l_update_rec.salesrep_id           := l_salesrep_id;
   l_update_rec.pay_group_id          := l_pay_group_id;
   l_update_rec.assignment_start_date := l_paygroup_assign_rec.assignment_start_date;
   l_update_rec.assignment_end_date   := l_paygroup_assign_rec.assignment_end_date;
   l_update_rec.lock_flag             := l_paygroup_assign_rec.lock_flag;
   l_update_rec.role_pay_group_id     := l_paygroup_assign_rec.role_pay_group_id;
   l_update_rec.org_id                := l_org_id;
   l_update_rec.attribute_category    := l_paygroup_assign_rec.attribute_category;
   l_update_rec.attribute1            := l_paygroup_assign_rec.attribute1;
   l_update_rec.attribute2            := l_paygroup_assign_rec.attribute2;
   l_update_rec.attribute3            := l_paygroup_assign_rec.attribute3;
   l_update_rec.attribute4            := l_paygroup_assign_rec.attribute4;
   l_update_rec.attribute5            := l_paygroup_assign_rec.attribute5;
   l_update_rec.attribute6            := l_paygroup_assign_rec.attribute6;
   l_update_rec.attribute7            := l_paygroup_assign_rec.attribute7;
   l_update_rec.attribute8            := l_paygroup_assign_rec.attribute8;
   l_update_rec.attribute9            := l_paygroup_assign_rec.attribute9;
   l_update_rec.attribute10           := l_paygroup_assign_rec.attribute10;
   l_update_rec.attribute11           := l_paygroup_assign_rec.attribute11;
   l_update_rec.attribute12           := l_paygroup_assign_rec.attribute12;
   l_update_rec.attribute13           := l_paygroup_assign_rec.attribute13;
   l_update_rec.attribute14           := l_paygroup_assign_rec.attribute14;
   l_update_rec.attribute15           := l_paygroup_assign_rec.attribute15;


   -- call private API
   cn_srp_paygroup_pvt.Update_Srp_Pay_Group
     (  p_api_version              => 1.0,
  	x_return_status		   => x_return_status,
  	x_loading_status           => x_loading_status,
  	x_msg_count		   => x_msg_count,
  	x_msg_data		   => x_msg_data,
	p_paygroup_assign_rec      => l_update_rec);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --
   -- End of API body.
   --


   --
   -- Post processing hooks
   --


   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'UPDATE_SRP_ASSIGNMENT',
				'A',
				'V')
     THEN
      cn_srp_paygroup_pub_vuhk.update_srp_assignment_post
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_old_paygroup_assign_rec      => l_old_payGroup_assign_rec,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_Execute('CN_SRP_PAYGROUP_PUB',
				'UPDATE_SRP_ASSIGNMENT',
				'A',
				'C')
     THEN
      cn_srp_paygroup_pub_cuhk.update_srp_assignment_post
	(p_api_version           	=> p_api_version,
	 p_init_msg_list		=> fnd_api.g_false,
	 p_commit	    		=> fnd_api.g_false,
	 p_validation_level		=> p_validation_level,
	 x_return_status		=> x_return_status,
	 x_msg_count			=> x_msg_count,
	 x_msg_data			=> x_msg_data,
	 p_old_paygroup_assign_rec      => l_old_payGroup_assign_rec,
	 p_paygroup_assign_rec          => l_payGroup_assign_rec,
	 x_loading_status		=> x_loading_status,
	 x_status                       => x_status
	 );

      IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	THEN
	 RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	 THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF JTF_USR_HKS.Ok_to_execute('CN_SRP_PAYGROUP_PUB',
				'UPDATE_SRP_ASSIGNMENT',
				'M',
				'M')
     THEN
      IF  cn_srp_paygroup_pub_cuhk.ok_to_generate_msg
	 (p_paygroup_assign_rec         => l_paygroup_assign_rec)
	THEN

	 -- Get a ID for workflow/ business object instance
	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	 --  Do this for all the bind variables in the Business Object
	 JTF_USR_HKS.load_bind_data
	   (  l_bind_data_id, 'SRP_PAY_GROUP_ID', l_srp_pay_group_id, 'S', 'S');

	 -- Message generation API
	 JTF_USR_HKS.generate_message
	   (p_prod_code    => 'CN',
	    p_bus_obj_code => 'SRP_PGRP',
	    p_bus_obj_name => 'SRP_PAYGROUP',
	    p_action_code  => 'I',
	    p_bind_data_id => l_bind_data_id,
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
      END IF;
   END IF;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
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
      ROLLBACK TO update_srp_assignment;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_srp_assignment;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO update_srp_assignment;
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

END update_srp_assignment;


-- --------------------------------------------------------------------------*
-- Procedure: Create_Mass_Asgn_Srp_Pay_Groups
-- --------------------------------------------------------------------------*

PROCEDURE Create_Mass_Asgn_Srp_Pay
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pay_group_id  IN    NUMBER,
   x_srp_pay_group_id   OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   ) IS

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pay_group_id     cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_loading_status       VARCHAR2(2000);
      l_status               VARCHAR2(2000);
      l_count                NUMBER;
      l_api_name	   CONSTANT VARCHAR2(30) := 'Create_Mass_Asgn_Srp_Pay';
      l_api_version        CONSTANT NUMBER       := 1.0;
      l_null_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
      newrec                 CN_SRP_PAYGROUP_PUB.PayGroup_assign_rec;
      l_salesrep_type        cn_salesreps.type%TYPE;
      l_salesrep_id          cn_salesreps.salesrep_id%TYPE;
      l_org_id               cn_salesreps.org_id%TYPE;
      l_emp_num 	     cn_salesreps.employee_number%TYPE;
      l_pay_group_name       cn_pay_groups.name%TYPE;
      l_pay_group_id	     cn_pay_groups.pay_group_id%TYPE;
      l_pg_start_date        cn_pay_groups.start_date%TYPE;
      l_pg_end_date	     cn_pay_groups.end_date%TYPE;
      l_srp_start_date       cn_srp_roles.start_date%TYPE;
      l_srp_end_date	     cn_pay_groups.end_date%TYPE;
      l_start_date           cn_srp_pay_groups.start_date%TYPE;
      l_end_date             cn_srp_pay_groups.start_date%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Mass_Asgn_Srp_Pay;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   -- begin API
   select pay_group_id, start_date, end_date, org_id
     into l_pay_group_id, l_pg_start_date, l_pg_end_date, l_org_id
     from cn_role_pay_groups_all
    where role_pay_group_id = p_role_pay_group_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_paygroup_pub.create_mass_asgn_srp_pay.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   select salesrep_id, start_date, end_date
     into l_salesrep_id, l_srp_start_date, l_srp_end_date
     from cn_srp_roles
    where srp_role_id = p_srp_role_id
      AND org_id = l_org_id;

   select employee_number, type
     into l_emp_num, l_salesrep_type
     from cn_salesreps
    where salesrep_id = l_salesrep_id
      AND org_id = l_org_id;

   select name
     into l_pay_group_name
     from cn_pay_groups_all
    where pay_group_id = l_pay_group_id;

     l_start_date := NULL;
     l_end_date   := NULL;

     get_masgn_date_intersect( -- Bug fix 5458432.  vensrini
         	p_srp_role_id   => p_srp_role_id,
         	p_role_pay_group_id   => p_role_pay_group_id,
         	x_start_date => l_start_date,
       x_end_date   => l_end_date);

     IF l_start_date IS NOT NULL AND l_end_date IS NOT NULL THEN

	select count(*)
	  into l_count
	  from cn_srp_pay_groups_all
	 where salesrep_id = l_salesrep_id
	   AND org_id      = l_org_id
	   and ((l_start_date between start_date and nvl(end_date,l_null_date))
		or (nvl(l_end_date,l_null_date) between
		    start_date and nvl(end_date,l_null_date)));

     IF l_count = 0

     THEN

	newrec.employee_type         := l_salesrep_type;
	newrec.employee_number       := l_emp_num;
	newrec.pay_group_name        := l_pay_group_name;
	newrec.assignment_start_date := l_start_date;
	newrec.assignment_end_date   := l_end_date;
	newrec.role_pay_group_id     := p_role_pay_group_id;
	newrec.lock_flag             := 'N';

	Assign_salesreps
	  (p_api_version        => 1.0,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
	   p_paygroup_assign_rec  => newrec,
	   x_loading_status     => l_loading_status,
	   x_status             => l_status	    );

	IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	   RAISE fnd_api.g_exc_error;
	END IF;

	l_return_status     := FND_API.G_RET_STS_SUCCESS;
	x_return_status     := l_return_status;
	x_loading_status    := l_loading_status;
      ELSE
	null;
     END IF;

      ELSE
	NULL;
     END IF;

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
      ROLLBACK TO Create_Mass_Asgn_Srp_Pay;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Mass_Asgn_Srp_Pay;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  	(
  	 p_count   =>  x_msg_count ,
  	 p_data    =>  x_msg_data   ,
  	 p_encoded => FND_API.G_FALSE
  	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Mass_Asgn_Srp_Pay;
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

END Create_Mass_Asgn_Srp_Pay;

-- --------------------------------------------------------------------------*
-- Procedure: Update_Mass_Asgn_Srp_Pay
-- --------------------------------------------------------------------------*

PROCEDURE Update_Mass_Asgn_Srp_Pay
  (
     p_api_version        IN    NUMBER,
     p_init_msg_list      IN    VARCHAR2,
     p_commit	          IN    VARCHAR2,
     p_validation_level   IN    NUMBER,
     x_return_status      OUT NOCOPY  VARCHAR2,
     x_msg_count	  OUT NOCOPY  NUMBER,
     x_msg_data	          OUT NOCOPY  VARCHAR2,
     p_srp_role_id        IN    NUMBER,
     p_role_pay_group_id  IN    NUMBER,
     x_srp_pay_group_id   OUT NOCOPY  NUMBER,
     x_loading_status     OUT NOCOPY  VARCHAR2
     ) IS

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_loading_status       VARCHAR2(2000);
      l_status               VARCHAR2(2000);
      l_lock_flag            cn_srp_pay_groups.lock_flag%TYPE;
      l_api_name	     CONSTANT VARCHAR2(30) := 'Update_Mass_Asgn_Srp_Pay';
      l_api_version          CONSTANT NUMBER       := 1.0;
      l_null_date            CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
      l_count                    NUMBER;
      l_count_pay                NUMBER;
      l_count_role               NUMBER;
      l_count_srp_pay_group      NUMBER;
      l_salesrep_type_old        cn_salesreps.type%TYPE;
      l_salesrep_id_old          cn_salesreps.salesrep_id%TYPE;
      l_emp_num_old 	         cn_salesreps.employee_number%TYPE;
      l_pay_group_name_old       cn_pay_groups.name%TYPE;
      l_pay_group_id_old 	 cn_pay_groups.pay_group_id%TYPE;
      l_role_id_old              cn_roles.role_id%TYPE;
      l_start_date_old           cn_srp_pay_groups.start_date%TYPE;
      l_end_date_old             cn_srp_pay_groups.start_date%TYPE;
      l_ovn_old                  cn_srp_pay_groups.object_version_number%TYPE;
      l_srp_pay_group_id         cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_org_id                   cn_srp_pay_groups.org_id%TYPE;

      newrec                     CN_SRP_PAYGROUP_PUB.PayGroup_assign_rec;
      oldrec                     CN_SRP_PAYGROUP_PUB.PayGroup_assign_rec;

      delrec                     CN_Srp_PayGroup_PVT.PayGroup_assign_rec;
      l_salesrep_type_new        cn_salesreps.type%TYPE;
      l_salesrep_id_new          cn_salesreps.salesrep_id%TYPE;
      l_emp_num_new 	         cn_salesreps.employee_number%TYPE;
      l_pay_group_name_new       cn_pay_groups.name%TYPE;
      l_pay_group_id_new         cn_pay_groups.pay_group_id%TYPE;
      l_pp_start_date_new        cn_pay_groups.start_date%TYPE;
      l_pp_end_date_new	         cn_pay_groups.end_date%TYPE;
      l_srp_start_date_new       cn_srp_roles.start_date%TYPE;
      l_srp_end_date_new	 cn_srp_roles.end_date%TYPE;
      l_start_date_new           cn_srp_pay_groups.start_date%TYPE;
      l_end_date_new             cn_srp_pay_groups.start_date%TYPE;


  --changed the cursor to get proper srp-pay_group assignment to be updated--Hanaraya
  CURSOR get_pay_groups
     (l_salesrep_id_old NUMBER,
      p_role_pay_group_id NUMBER) IS
     select srp_pay_group_id,pay_group_id, start_date, end_date,object_version_number,lock_flag
	  from cn_srp_pay_groups sp
	 where salesrep_id = l_salesrep_id_old
       AND role_pay_group_id = p_role_pay_group_id
	AND NOT EXISTS
	( Select 1 from cn_srp_roles sr, cn_role_pay_groups rp
	  Where salesrep_id = l_salesrep_id_old
	  AND role_pay_group_id = p_role_pay_group_id
          AND sr.role_id = rp.role_id
          AND sr.org_id = rp.org_id
	  AND greatest(sr.start_date,rp.start_date) = sp.start_date
	  AND least(nvl(sr.end_date,l_null_date),nvl(rp.end_date,l_null_date))
      = nvl(sp.end_date,l_null_date)
    );

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Update_Mass_Asgn_Srp_Pay;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- begin API
   SELECT org_id
     INTO l_org_id
     FROM cn_role_pay_groups_all
    WHERE role_pay_group_id = p_role_pay_group_id;

   -- validate org ID
   mo_global.validate_orgid_pub_api
     (org_id => l_org_id,
      status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		     'cn.plsql.cn_srp_paygroup_pub.update_mass_asgn_srp_pay.org_validate',
                     'Validated org_id = ' || l_org_id || ' status = ' || l_status);
   end if;

   SELECT salesrep_id,role_id,start_date, end_date
     INTO l_salesrep_id_old,l_role_id_old,l_srp_start_date_new, l_srp_end_date_new
     FROM cn_srp_roles
    WHERE srp_role_id = p_srp_role_id
      AND org_id      = l_org_id;

   SELECT count(*)
     INTO l_count
     FROM cn_srp_pay_groups_all
    WHERE salesrep_id       = l_salesrep_id_old
      AND role_pay_group_id = p_role_pay_group_id;

   IF (l_count <> 0)
     THEN
      FOR paygroup IN get_pay_groups(l_salesrep_id_old, p_role_pay_group_id) LOOP
	 l_pay_group_id_old := paygroup.pay_group_id;
	 l_start_date_old   := paygroup.start_date;
	 l_end_date_old     := paygroup.end_date;
	 l_ovn_old          := paygroup.object_version_number;
	 l_lock_flag        := paygroup.lock_flag;

	 /* commented out validation for bug 5018892 - it is performed later
	   SELECT count(*) into l_count_pay
	     FROM cn_payment_worksheets_all W, cn_period_statuses_all prd,
	          cn_payruns_all prun
	    WHERE w.salesrep_id      = l_salesrep_id_old
	      AND w.org_id           = l_org_id
	      AND prun.pay_period_id = prd.period_id
	      AND prun.payrun_id     = w.payrun_id
	      AND prun.pay_group_id  = l_pay_group_id_old
	      AND prd.org_id         = l_org_id
	      AND ((prd.start_date BETWEEN l_start_date_old AND nvl(l_end_date_old,l_null_date)) OR
		   (prd.end_date between l_start_date_old AND nvl(l_end_date_old,l_null_date)) );


	   IF l_count_pay > 0
	     THEN
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
	   */

     SELECT employee_number, type
       INTO l_emp_num_old, l_salesrep_type_old
       FROM cn_salesreps
      WHERE salesrep_id = l_salesrep_id_old
        AND org_id      = l_org_id;

     SELECT name
       INTO l_pay_group_name_old
       FROM cn_pay_groups_all
      WHERE pay_group_id = l_pay_group_id_old;

     oldrec.employee_type             := l_salesrep_type_old;
     oldrec.employee_number           := l_emp_num_old;
     delrec.salesrep_id               := l_salesrep_id_old;
     oldrec.pay_group_name            := l_pay_group_name_old;
     delrec.pay_group_id              := l_pay_group_id_old;
     oldrec.org_id                    := l_org_id;
     delrec.org_id                    := l_org_id;
     oldrec.assignment_start_date     := l_start_date_old;
     delrec.assignment_start_date     := l_start_date_old;
     oldrec.assignment_end_date       := l_end_date_old;
     delrec.assignment_end_date       := l_end_date_old;
     oldrec.role_pay_group_id         := p_role_pay_group_id;
     delrec.role_pay_group_id         := p_role_pay_group_id;

	end loop;
   END IF;

   SELECT salesrep_id, start_date, end_date
     INTO l_salesrep_id_new, l_srp_start_date_new, l_srp_end_date_new
     FROM cn_srp_roles
    WHERE srp_role_id = p_srp_role_id
      AND org_id = l_org_id;

   SELECT employee_number, type
     INTO l_emp_num_new, l_salesrep_type_new
     FROM cn_salesreps
    WHERE salesrep_id = l_salesrep_id_new
      AND org_id = l_org_id;

   SELECT pay_group_id, start_date, end_date
     INTO l_pay_group_id_new, l_pp_start_date_new, l_pp_end_date_new
     FROM cn_role_pay_groups_all
    WHERE role_pay_group_id = p_role_pay_group_id;

   SELECT name
     INTO l_pay_group_name_new
     FROM cn_pay_groups_all
    WHERE pay_group_id = l_pay_group_id_new;

   SELECT count(*)
     INTO l_count_srp_pay_group
     FROM cn_srp_pay_groups_all
    WHERE salesrep_id=l_salesrep_id_old
      AND org_id = l_org_id
      AND ((l_start_date_old between start_date and nvl(end_date,l_null_date))
       OR (l_end_date_old between start_date and nvl(end_date,l_null_date)));

   l_start_date_new := NULL;
   l_end_date_new   := NULL;

   IF (l_lock_flag = 'N' or l_count=0)
   THEN
      get_masgn_date_intersect(  -- Bug fix 5458432
	 	p_srp_role_id => p_srp_role_id,
         	p_role_pay_group_id   => p_role_pay_group_id,
         	x_start_date => l_start_date_new,
	x_end_date   => l_end_date_new);

      IF l_start_date_new IS NOT NULL AND l_end_date_new IS NOT NULL THEN
	newrec.employee_type             := l_salesrep_type_new;
	newrec.employee_number           := l_emp_num_new;
	newrec.pay_group_name            := l_pay_group_name_new;
	newrec.org_id                    := l_org_id;
	newrec.assignment_start_date     := l_start_date_new;
	newrec.assignment_end_date       := l_end_date_new;
	newrec.lock_flag                 :='N';
	newrec.role_pay_group_id         := p_role_pay_group_id;

	IF (l_count  > 0 )
	  THEN
	   Update_srp_Assignment
	     (p_api_version        => 1.0,
	      x_return_status      => l_return_status,
	      x_msg_count          => l_msg_count,
	      x_msg_data           => l_msg_data,
	      p_old_paygroup_assign_rec => oldrec,
	      p_paygroup_assign_rec     => newrec,
	      p_ovn                => l_ovn_old    ,
	      x_loading_status     => l_loading_status,
	      x_status             => l_status	    );

	   IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	      RAISE fnd_api.g_exc_error;
	   END IF;

	   l_return_status := FND_API.G_RET_STS_SUCCESS;

	   IF l_loading_status = 'CN_INVALID_SRP_PGRP_ASGN_DT' THEN
	      cn_srp_paygroup_pvt.delete_srp_pay_group
		(
		 p_api_version        => 1.0,
		 x_return_status      => l_return_status,
		 x_loading_status     => l_loading_status,
		 x_msg_count          => l_msg_count,
		 x_msg_data           => l_msg_data,
		 p_paygroup_assign_rec  => delrec
		 );

	      IF l_return_status <> fnd_api.g_ret_sts_success THEN
		 RAISE fnd_api.g_exc_error;
	      END IF;
	   END IF;

	   l_return_status     := FND_API.G_RET_STS_SUCCESS;
	   x_return_status     := l_return_status;
	   x_loading_status    := l_loading_status;
	 ELSIF (l_count_srp_pay_group = 0 )
	   THEN

       SELECT count(*)
       INTO l_count_srp_pay_group
       FROM cn_srp_pay_groups_all
       WHERE salesrep_id=l_salesrep_id_old
       AND org_id = l_org_id
       AND ((l_start_date_new between start_date and nvl(end_date,l_null_date))
       OR (l_end_date_new between start_date and nvl(end_date,l_null_date)));

       IF (l_count_srp_pay_group = 0) THEN

           Assign_salesreps
	     (p_api_version        => 1.0,
	      x_return_status      => l_return_status,
	      x_msg_count          => l_msg_count,
	      x_msg_data           => l_msg_data,
	      p_paygroup_assign_rec=> newrec,
	      x_loading_status     => l_loading_status,
	      x_status             => l_status	    );

	     IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	        RAISE fnd_api.g_exc_error;
	     END IF;
       END IF;
	   l_return_status     := FND_API.G_RET_STS_SUCCESS;
	   x_return_status     := l_return_status;
	   x_loading_status    := l_loading_status;

	END IF;

       ELSIF l_count <> 0 THEN
	 cn_srp_paygroup_pvt.delete_srp_pay_group
	   (
	    p_api_version        => 1.0,
	    x_return_status      => l_return_status,
	    x_loading_status     => l_loading_status,
	    x_msg_count          => l_msg_count,
	    x_msg_data           => l_msg_data,
	    p_paygroup_assign_rec=> delrec

	    );

	 IF l_return_status <> fnd_api.g_ret_sts_success THEN
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 l_return_status:=FND_API.G_RET_STS_SUCCESS;

      END IF;
    ELSE
      NULL;

   END IF;

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
      ROLLBACK TO Update_Mass_Asgn_Srp_Pay;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_Mass_Asgn_Srp_Pay;
       x_loading_status := 'UNEXPECTED_ERR';
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
	 (
	  p_count   =>  x_msg_count ,
	  p_data    =>  x_msg_data   ,
	  p_encoded => FND_API.G_FALSE
	  );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Mass_Asgn_Srp_Pay;
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

End Update_Mass_Asgn_Srp_Pay;

END CN_Srp_PayGroup_PUB ;

/
