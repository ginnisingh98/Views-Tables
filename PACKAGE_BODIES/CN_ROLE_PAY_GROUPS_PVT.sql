--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PAY_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PAY_GROUPS_PVT" AS
/* $Header: cnvrpgpb.pls 120.11.12010000.3 2009/10/09 23:42:54 rnagired ship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_ROLE_PAY_GROUPS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnvrpgpb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
G_MISS_JOB_TITLE            NUMBER  := -99;

G_ROWID                     VARCHAR2(15);
G_PROGRAM_TYPE              VARCHAR2(30);

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
  l_salesrep_name cn_salesreps.name%TYPE;
  l_role_name jtf_rs_roles_tl.role_name%TYPE;

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
  select name, start_date_active, end_date_active
  into l_salesrep_name, l_res_start_date, l_res_end_date
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

  --IF the sales rep start date is outside the range for the pay group which has the role of this sales rep. Raise Error
IF(l_start_date is NULL)
THEN
   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
   SELECT role_name into l_role_name
    FROM jtf_rs_roles_tl
    WHERE role_id =
      (SELECT role_id
       FROM cn_srp_roles
       WHERE srp_role_id = p_srp_role_id
       AND salesrep_id = l_salesrep_id)
       AND language = USERENV('LANG');
	 fnd_message.set_name('CN', 'CN_SRP_OUTSIDE_PAYGRP_DATE');
	 FND_MESSAGE.SET_TOKEN('SALES_REP_NAME', l_salesrep_name);
         FND_MESSAGE.SET_TOKEN('ROLE_NAME', l_role_name);
	 fnd_msg_pub.ADD;
         END IF;
  RAISE FND_API.G_EXC_ERROR ;
END IF;

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

-- ----------------------------------------------------------------------------*
-- Function : valid_role_name
-- Desc     : check if the role_name exists in cn_roles
-- ---------------------------------------------------------------------------*
FUNCTION valid_role_name
  (
   p_role_name cn_roles.name%TYPE
   ) RETURN BOOLEAN IS

      CURSOR l_cur(l_role_name cn_roles.name%TYPE) IS
	 SELECT *
	   FROM cn_roles
	   WHERE name = l_role_name;

      l_rec l_cur%ROWTYPE;

BEGIN

   OPEN l_cur(p_role_name);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN FALSE;
    ELSE
      CLOSE l_cur;
      RETURN TRUE;
   END IF;

END valid_role_name;

-- ----------------------------------------------------------------------------*
-- Function : valid_pay_group_name
-- Desc     : check if the comp_plan_name exists in cn_comp_plans
-- ---------------------------------------------------------------------------*
FUNCTION valid_pay_groups_name
  (
   p_pay_group_name cn_pay_groups.name%TYPE,
   p_org_id cn_pay_groups.org_id%TYPE
   ) RETURN BOOLEAN IS

      CURSOR l_cur(l_pay_group_name cn_pay_groups.name%TYPE,l_org_id cn_pay_groups.org_id%TYPE) IS
	 SELECT *
	   FROM cn_pay_groups
	   WHERE name = l_pay_group_name and org_id =l_org_id;

      l_rec l_cur%ROWTYPE;

BEGIN

   OPEN l_cur(p_pay_group_name,p_org_id);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN FALSE;
    ELSE
      CLOSE l_cur;
      RETURN TRUE;
   END IF;

END valid_pay_groups_name;

-- ----------------------------------------------------------------------------*
-- Function : valid_role_pay_group_id
-- Desc     : check if the pay_group_id exists in cn_roles
-- ---------------------------------------------------------------------------*
FUNCTION valid_role_pay_group_id
  (
   p_role_pay_group_id cn_role_pay_groups.role_pay_group_id%TYPE
   ) RETURN BOOLEAN IS

      CURSOR l_cur(l_role_pay_group_id cn_role_pay_groups.role_pay_group_id%TYPE) IS
	 SELECT *
	   FROM cn_role_pay_groups
	   WHERE role_pay_group_id = l_role_pay_group_id;

      l_rec l_cur%ROWTYPE;

BEGIN

   OPEN l_cur(p_role_pay_group_id);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN FALSE;
    ELSE
      CLOSE l_cur;
      RETURN TRUE;
   END IF;

END valid_role_pay_group_id;


-- ----------------------------------------------------------------------------*
-- Function : is_exist
-- Desc     : check if the role_pay_group_id exists in cn_role_pay_groups
-- ---------------------------------------------------------------------------*
FUNCTION is_exist
  (
   p_role_pay_group_id cn_role_pay_groups.role_pay_group_id%TYPE
   ) RETURN BOOLEAN IS

      CURSOR l_cur(l_role_pay_group_id cn_role_pay_groups.role_pay_group_id%TYPE) IS
	 SELECT *
	   FROM cn_role_pay_groups
	   WHERE role_pay_group_id = l_role_pay_group_id;

      l_rec l_cur%ROWTYPE;

BEGIN

   OPEN l_cur(p_role_pay_group_id);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN FALSE;
    ELSE
      CLOSE l_cur;
      RETURN TRUE;
   END IF;

END is_exist;

FUNCTION  get_pg_id ( p_pay_group_name     VARCHAR2,p_org_id NUMBER )
  RETURN cn_pay_groups.pay_group_id%TYPE IS

     l_pay_group_id cn_pay_groups.pay_group_id%TYPE;

BEGIN
   SELECT pay_group_id
     INTO l_pay_group_id
     FROM cn_pay_groups
     WHERE  name = p_pay_group_name and org_id=p_org_id;

   RETURN l_pay_group_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;

END get_pg_id;

--| ---------------------------------------------------------------------=
--| Function Name :  get_pay_group_name
--| Desc : Get the  pay group name using the pay group id
--| ---------------------------------------------------------------------=
FUNCTION  get_pg_name (p_pay_group_id    VARCHAR2 )
  RETURN cn_pay_groups.name%TYPE IS

     l_pay_group_name cn_pay_groups.name%TYPE;

BEGIN
   SELECT name
     INTO l_pay_group_name
     FROM cn_pay_groups
     WHERE  pay_group_id = p_pay_group_id ;

   RETURN l_pay_group_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;

END get_pg_name;

-- --------------------------------------------------------------------------=
-- Function : get_role_pay_group_id
-- Desc     : get the role_pay_group_id if it exists in cn_role_pay_groups
-- --------------------------------------------------------------------------=
FUNCTION get_role_pay_group_id
  (
   p_role_name              IN  VARCHAR2,
   p_pay_group_name         IN  VARCHAR2,
   p_start_date             IN  DATE,
   p_end_date               IN  DATE,
   p_org_id                 IN NUMBER
   ) RETURN cn_role_pay_groups.role_pay_group_id%TYPE IS

      CURSOR l_cur(l_role_id      cn_role_pay_groups.role_id%TYPE,
		   l_pay_group_id cn_role_pay_groups.pay_group_id%TYPE,
		   l_start_date   cn_role_pay_groups.start_date%TYPE,
		   l_end_date     cn_role_pay_groups.end_date%TYPE) IS
	 SELECT role_pay_group_id
	   FROM cn_role_pay_groups
	   WHERE role_id = l_role_id AND
	   pay_group_id = l_pay_group_id AND
	   start_date = l_start_date AND
	   ((end_date = l_end_date) OR
	    (end_date IS NULL AND l_end_date IS NULL));

      l_rec              l_cur%ROWTYPE;
      l_role_id          cn_role_pay_groups.role_id%TYPE;
      l_pay_group_id     cn_role_pay_groups.pay_group_id%TYPE;

BEGIN

   l_role_id      := cn_api.get_role_id(p_role_name);
   l_pay_group_id := get_pg_id(p_pay_group_name,p_org_id);

   OPEN l_cur(l_role_id, l_pay_group_id, p_start_date, p_end_date);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN NULL;
    ELSE
      CLOSE l_cur;
      RETURN l_rec.role_pay_group_id;
   END IF;

END get_role_pay_group_id;


-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_insert
-- Desc     : check if the record is valid to insert into cn_role_pay_groups
--            called in create_role_pay_groups before inserting a role-paygroup
--            assignment
-- ----------------------------------------------------------------------------*
PROCEDURE check_valid_insert
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_role_pay_groups_rec     IN  role_pay_groups_rec_type,
   x_role_id                OUT NOCOPY cn_roles.role_id%TYPE,
   x_pay_group_id           OUT NOCOPY cn_role_pay_groups.pay_group_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'check_valid_insert';
       l_count		   NUMBER       := 0;

      l_loading_status VARCHAR2(100);
       l_null_date          CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');


      CURSOR l_cur(l_role_id cn_roles.role_id%TYPE,l_org_id cn_role_pay_groups.org_id%TYPE) IS
	 SELECT start_date, end_date, pay_group_id
	   FROM cn_role_pay_groups
	   WHERE role_id = l_role_id and org_id=l_org_id;

      CURSOR l_cp_cur(l_pay_group_name cn_pay_groups.name%TYPE,l_org_id cn_pay_groups.org_id%TYPE) IS
	 SELECT start_date, end_date
	   FROM cn_pay_groups
	   WHERE name = l_pay_group_name and org_id=l_org_id;

      l_cp_rec l_cp_cur%ROWTYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_loading_status := p_loading_status;
   x_loading_status := p_loading_status;


   -- Start of API body

   -- validate the following issues

   -- role_name can not be missing or null
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_role_pay_groups_rec.role_name,
	p_obj_name => G_ROLE_NAME,
	p_loading_status => l_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- pay_group_name can not be missing or null
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_role_pay_groups_rec.pay_groups_name,
	p_obj_name => G_PG_NAME,
	p_loading_status => l_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- start_date can not be null
   -- start_date can not be missing
   -- start_date < end_date if end_date is null
   IF ( (cn_api.invalid_date_range
	 (p_start_date => p_role_pay_groups_rec.start_date,
	  p_end_date => p_role_pay_groups_rec.end_date,
	  p_end_date_nullable => FND_API.G_TRUE,
	  p_loading_status => l_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- role_name must exist in cn_roles
   IF NOT valid_role_name(p_role_pay_groups_rec.role_name) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name('CN', 'CN_RL_ASGN_ROLE_NOT_EXIST');
	 FND_MESSAGE.SET_TOKEN('ROLE_NAME',p_role_pay_groups_rec.role_name);
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_ASGN_ROLE_NOT_EXIST';
      RAISE fnd_api.g_exc_error;
    ELSE
      x_role_id := cn_api.get_role_id(p_role_pay_groups_rec.role_name);
   END IF;
   -- pay_group_name must exist in cn_pay_groups
   IF NOT valid_pay_groups_name(p_role_pay_groups_rec.pay_groups_name,p_role_pay_groups_rec.org_id) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name('CN', 'CN_RL_ASGN_PG_NOT_EXIST');
	 fnd_message.set_token('PAY_GROUP',p_role_pay_groups_rec.pay_groups_name);
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_ASGN_PG_NOT_EXIST';
      RAISE fnd_api.g_exc_error;
    ELSE
      x_pay_group_id := get_pg_id(p_role_pay_groups_rec.pay_groups_name,p_role_pay_groups_rec.org_id);
   END IF;

   --
   -- Check if the current assignment dates do not fit within the effectivity of the
   -- pay group.
   --
   SELECT COUNT(1)
     INTO l_count
     FROM cn_pay_groups
     WHERE (( p_role_pay_groups_rec.start_date NOT BETWEEN start_date AND end_date )
	    OR  (p_role_pay_groups_rec.end_date NOT BETWEEN start_date AND end_date))
     AND pay_group_id = x_pay_group_id;

   IF l_count <> 0
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_ROLE_PGRP_ASGN_DT');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_ROLE_PGRP_ASGN_DT';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      --
      -- Check for overlapping assignments
      -- Added new message CN_RL_ROLE_PAY_GROUP_OVERLAP for bug 3152146 and included cn_api.date_range_overlap() for checking date overlap
      /* SELECT count(1)
      INTO l_count
      FROM cn_role_pay_groups
      WHERE p_role_pay_groups_rec.start_date between start_date AND Nvl(end_date, p_role_pay_groups_rec.start_date)
      AND role_id = x_role_id; */


         FOR l_rec IN l_cur(x_role_id,p_role_pay_groups_rec.org_id)
         LOOP
            IF ((cn_api.date_range_overlap(l_rec.start_date,
			     l_rec.end_date,
			     p_role_pay_groups_rec.start_date,
			     p_role_pay_groups_rec.end_date)))
             THEN


		/* IF l_count <> 0
		   THEN
		 --Error condition
		 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		 THEN
		    fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
		    fnd_msg_pub.add;
		 END IF; */

		IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
		      fnd_message.set_name ('CN', 'CN_RL_ROLE_PAY_GROUP_OVERLAP_N');
		      fnd_message.set_token('CURRENT_PAY_GROUP ',p_role_pay_groups_rec.pay_groups_name);
		      fnd_message.set_token('ROLE_NAME',p_role_pay_groups_rec.role_name);
		      fnd_message.set_token('ROLE_START_DATE',p_role_pay_groups_rec.start_date);
		      fnd_message.set_token('ROLE_END_DATE',p_role_pay_groups_rec.end_date);
		      FND_MESSAGE.SET_TOKEN('PAY_GROUP_NAME',get_pg_name(l_rec.pay_group_id));
		      fnd_message.set_token('START_DATE',l_rec.start_date);
		      fnd_message.set_token('END_DATE',l_rec.end_date);
		      fnd_msg_pub.ADD;
		 END IF;

   	 	x_loading_status := 'CN_RL_ROLE_PAY_GROUP_OVERLAP';

         	--x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';

         	RAISE FND_API.G_EXC_ERROR;
      	    END IF;
         END LOOP;

         --Commented the code as the overlap conditions are handled in the code above

      /* SELECT count(1)
        INTO l_count
        FROM cn_role_pay_groups
        WHERE Nvl(p_role_pay_groups_rec.end_date, l_null_date) between start_date
        AND Nvl(end_date, Nvl(p_role_pay_groups_rec.end_date, l_null_date))
        AND role_id = x_role_id;



      IF l_count <> 0
        THEN
         --Error condition
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
   	THEN
            fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
            fnd_msg_pub.add;
         END IF;
         x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
         RAISE FND_API.G_EXC_ERROR;
   END IF;

   SELECT count(1)
        INTO l_count
        FROM cn_role_pay_groups
        WHERE p_role_pay_groups_rec.start_date <= start_date
        AND Nvl(p_role_pay_groups_rec.end_date, l_null_date) >= Nvl(end_date, l_null_date) AND role_id = x_role_id;



      IF l_count <> 0
        THEN
         --Error condition
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name('CN', 'CN_OVERLAP_SRP_PGRP_ASGN');
            fnd_msg_pub.add;
         END IF;

         x_loading_status := 'CN_OVERLAP_SRP_PGRP_ASGN';
         RAISE FND_API.G_EXC_ERROR;
      END IF; */

  --End of API body
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (
       p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
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
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
END check_valid_insert;



-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_delete
-- Desc     : check if the record is valid to delete from cn_role_plans
--            called in delete_role_plan before deleting a role
-- ----------------------------------------------------------------------------*
PROCEDURE check_valid_delete
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_role_pay_groups_rec          IN  role_pay_groups_rec_type,
   x_role_pay_group_id           OUT NOCOPY NUMBER,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'check_valid_delete';

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   -- Valide the following issues

   -- Checke if the p_role_plan_id does exist.

   x_role_pay_group_id :=  get_role_pay_group_id(p_role_pay_groups_rec.role_name,
				       p_role_pay_groups_rec.pay_groups_name,
				       p_role_pay_groups_rec.start_date,
				       p_role_pay_groups_rec.end_date,
                       p_role_pay_groups_rec.org_id);
   IF (x_role_pay_group_id IS NULL) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME('CN' ,'CN_RL_DEL_ROLE_PLAN_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_RL_DEL_ROLE_PLAN_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;



   -- End of API body.

    -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
      (
       p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
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
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );

END check_valid_delete;



-- --------------------------------------------------------------------------*
-- Procedure: srp_plan_assignment_for_delete
-- --------------------------------------------------------------------------*
PROCEDURE srp_plan_assignment_for_delete
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_role_plan_id   IN cn_role_plans.role_plan_id%TYPE,
   p_salesrep_id    IN cn_salesreps.salesrep_id%TYPE,
   p_org_id         IN cn_salesreps.org_id%TYPE,
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

      CURSOR l_cur IS
	 SELECT srp_role_id
	   FROM cn_srp_roles
	   WHERE role_id = p_role_id and salesrep_id= p_salesrep_id and org_id=p_org_id;

      l_rec l_cur%ROWTYPE;

      l_return_status      VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_plan_assign_id   cn_srp_plan_assigns.srp_plan_assign_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   FOR l_rec IN l_cur
     LOOP

	cn_srp_plan_assigns_pvt.delete_srp_plan_assigns
	  (
	   p_api_version        => 1.0,
	   p_init_msg_list      => fnd_api.g_false,
	   p_commit             => fnd_api.g_false,
	   p_validation_level   => fnd_api.g_valid_level_full,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
	   p_srp_role_id        => l_rec.srp_role_id,
	   p_role_plan_id       => p_role_plan_id,
	   x_loading_status     => l_loading_status);

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   x_return_status     := l_return_status;
	   x_loading_status    := l_loading_status;
	   EXIT;
	END IF;

     END LOOP;
END srp_plan_assignment_for_delete;


-- --------------------------------------------------------------------------*
-- Procedure: create_role_pay_groups
-- --------------------------------------------------------------------------*
PROCEDURE Create_Role_Pay_Groups
  (
   p_api_version           IN	NUMBER,
   p_init_msg_list	   IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	   IN  	NUMBER	 :=FND_API.g_valid_level_full,
   x_return_status	   OUT NOCOPY	VARCHAR2,
   x_loading_status        OUT NOCOPY  VARCHAR2,
   x_msg_count		   OUT NOCOPY	NUMBER,
   x_msg_data		   OUT NOCOPY	VARCHAR2,
   p_role_pay_groups_rec   IN OUT NOCOPY role_pay_groups_rec_type
   ) IS

      l_api_name		CONSTANT VARCHAR2(30) := 'Create_Role_Pay_Groups';
      l_api_version           	CONSTANT NUMBER  := 1.0;
      l_role_pay_group_id       cn_role_pay_groups.role_pay_group_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;
      l_pay_group_id            cn_pay_groups.pay_group_id%TYPE;
      l_null_date          CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');
      l_loading_status VARCHAR2(100);

      -- Declaration for user hooks

      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;
      l_count NUMBER;

      --CN_Srp_PayGroup_PUB.PayGroup_assign_rec

      CURSOR get_roles (p_salesrep_id cn_salesreps.salesrep_id%TYPE,p_org_id cn_salesreps.org_id%TYPE) IS

    /*
        SELECT role_id, srp_role_id,start_date, nvl(end_date,l_null_date) end_date,org_id
      	FROM cn_srp_roles
      	WHERE salesrep_id = p_salesrep_id and org_id=p_org_id;  */

        --raj reddy for bug fix 8845580
      	SELECT sr.role_id, sr.srp_role_id,sr.start_date, nvl(sr.end_date,l_null_date) end_date,sr.org_id
	FROM jtf_rs_Salesreps s,
	     cn_srp_roles sr
	WHERE sr.salesrep_id = s.salesrep_id
	AND sr.salesrep_id = p_salesrep_id
	AND sr.org_id = p_org_id
	AND
	((end_Date_active  is null)
        OR  (end_Date_active IS  NOT NULL AND end_Date_active BETWEEN p_role_pay_groups_rec.start_date AND p_role_pay_groups_rec.end_date));

      CURSOR get_role_plans(p_role_id  cn_roles.role_id%TYPE,p_org_id cn_role_plans.org_id%TYPE) IS
            SELECT role_plan_id
              FROM cn_role_plans
              WHERE role_id = p_role_id and org_id=p_org_id;

      CURSOR get_plan_assigns
           (p_role_id NUMBER,
            p_salesrep_id NUMBER,
            p_org_id  NUMBER) IS
      	 SELECT comp_plan_id,
      	   start_date,
      	   end_date
      	   FROM cn_srp_plan_assigns
      	   WHERE role_id = p_role_id
      	   AND salesrep_id = p_salesrep_id and org_id=p_org_id;

     /*
         CURSOR l_srp_cur(l_role_id  cn_roles.role_id%TYPE,l_org_id cn_srp_roles.org_id%TYPE) IS
	 SELECT srp_role_id,salesrep_id,start_date,end_date,org_id
	   FROM cn_srp_roles WHERE role_id = l_role_id and org_id=l_org_id;
	   */
        --raj reddy for bug fix 8845580
	   CURSOR l_srp_cur(l_role_id  cn_roles.role_id%TYPE,l_org_id cn_srp_roles.org_id%TYPE) IS
	    SELECT sr.srp_role_id,sr.salesrep_id,sr.start_date,sr.end_date,sr.org_id
            FROM jtf_rs_Salesreps s,
            cn_srp_roles sr
            WHERE sr.salesrep_id = s.salesrep_id
            AND sr.role_id = l_role_id
            AND sr.org_id = l_org_id
            AND
            ((end_Date_active  is null)
               OR  (end_Date_active IS  NOT NULL AND end_Date_active
            BETWEEN p_role_pay_groups_rec.start_date AND p_role_pay_groups_rec.end_date));


      l_role_pg_rec role_pay_groups_rec_type;
      l_rec l_srp_cur%ROWTYPE;
      l_lock_flag VARCHAR2(1);
      l_srp_pay_group_id cn_srp_pay_groups.srp_pay_group_id%TYPE;
      l_object_version_number cn_srp_pay_groups.object_version_number%TYPE;
      l_start_date   DATE;
      l_end_date     DATE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Role_Pay_Groups;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
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
   x_loading_status := 'CN_INSERTED';

   -- Assign the parameter to a local variable to be passed to Pre, Post
   -- and Business APIs
   l_role_pg_rec := p_role_pay_groups_rec;

   l_loading_status := x_loading_status;

   -- Start of API body
   check_valid_insert
     ( x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_role_pay_groups_rec => p_role_pay_groups_rec,
       x_role_id             => l_role_id,
       x_pay_group_id        => l_pay_group_id,
       p_loading_status      => l_loading_status, -- in
       x_loading_status      => x_loading_status  -- out
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
    l_role_pay_group_id := p_role_pay_groups_rec.role_pay_group_id;

      cn_role_pay_groups_pkg.INSERT_ROW
	(
	  x_rowid                  => G_ROWID
	 ,x_role_pay_group_id 	   => l_role_pay_group_id
	 ,x_role_id                => l_role_id
	 ,x_pay_group_id           => l_pay_group_id
	 ,x_start_date             => p_role_pay_groups_rec.start_date
	 ,x_end_date               => p_role_pay_groups_rec.end_date
	 ,x_attribute_category     => p_role_pay_groups_rec.ATTRIBUTE_CATEGORY
	 ,x_attribute1             => p_role_pay_groups_rec.ATTRIBUTE1
	 ,x_attribute2             => p_role_pay_groups_rec.ATTRIBUTE2
	 ,x_attribute3             => p_role_pay_groups_rec.ATTRIBUTE3
	 ,x_attribute4             => p_role_pay_groups_rec.ATTRIBUTE4
	 ,x_attribute5             => p_role_pay_groups_rec.ATTRIBUTE5
	 ,x_attribute6             => p_role_pay_groups_rec.ATTRIBUTE6
	 ,x_attribute7             => p_role_pay_groups_rec.ATTRIBUTE7
	 ,x_attribute8             => p_role_pay_groups_rec.ATTRIBUTE8
	 ,x_attribute9             => p_role_pay_groups_rec.ATTRIBUTE9
	 ,x_attribute10            => p_role_pay_groups_rec.ATTRIBUTE10
	 ,x_attribute11            => p_role_pay_groups_rec.ATTRIBUTE11
	 ,x_attribute12            => p_role_pay_groups_rec.ATTRIBUTE12
	 ,x_attribute13            => p_role_pay_groups_rec.ATTRIBUTE13
	 ,x_attribute14            => p_role_pay_groups_rec.ATTRIBUTE14
	 ,x_attribute15            => p_role_pay_groups_rec.ATTRIBUTE15
	 ,x_created_by             => g_created_by
	 ,x_creation_date          => g_creation_date
	 ,x_last_update_login      => g_last_update_login
	 ,x_last_update_date       => g_last_update_date
	 ,x_last_updated_by        => g_last_updated_by
     ,x_org_id                 => p_role_pay_groups_rec.ORG_ID
     ,x_object_version_number  => p_role_pay_groups_rec.object_version_number);

      FOR l_rec IN l_srp_cur(l_role_id,p_role_pay_groups_rec.org_id) LOOP
        SAVEPOINT create_srp_pay_groups;
        -- Inserted cn_api.date_range_overlap and get_date_range_intersect to check for date intersection

    IF cn_api.date_range_overlap
	(a_start_date => l_rec.start_date,
	 a_end_date   => l_rec.end_date,
	 b_start_date => p_role_pay_groups_rec.start_date,
	 b_end_date   => p_role_pay_groups_rec.end_date)
	THEN
    /*
	 -- l_rec dates are S-R intersect R-PG dates
	    cn_api.get_date_range_intersect
	      (a_start_date => l_rec.start_date,
	         a_end_date   => l_rec.end_date,
	         b_start_date => p_role_pay_groups_rec.start_date,
	         b_end_date   => p_role_pay_groups_rec.end_date,
	         x_start_date => l_start_date,
	         x_end_date   => l_end_date);
     */


     /*According to discussions with PMs, the intersection dates for
      mass assignment must be
      1) Resource Role Assignment dates
      2) Resource start and end dates
      3) Role Pay Group Assignment dates
      4) Pay Group start date and end dates
     */
     get_masgn_date_intersect( -- Bug fix 5511911.  sjustina
         	p_srp_role_id   => l_rec.srp_role_id,
         	p_role_pay_group_id   => p_role_pay_groups_rec.role_pay_group_id,
         	x_start_date => l_start_date,
       x_end_date   => l_end_date);
	 l_rec.start_date := l_start_date;
	 l_rec.end_date   := l_end_date;

	 -- Check if the current assignment dates fit within the
	 -- effectivity of the pay group.
	 -- if S-PG end date is null and PG end date is not null,
	 -- that is OK
	    SELECT COUNT(1)
	     INTO l_count
	     FROM cn_pay_groups
	     WHERE (l_rec.start_date NOT BETWEEN start_date AND end_date OR
		   (l_rec.end_date IS NOT NULL AND
		    l_rec.end_date NOT BETWEEN start_date AND end_date))
	     AND pay_group_id = l_pay_group_id;

	    IF l_count <> 0 THEN
		  GOTO end_create_srp_pay_groups;
      END IF;

	 -- If existing any same role_id in cn_srp_pay_groups THEN
	 -- check no overlap
     SELECT count(1) into l_count
       FROM cn_srp_pay_groups
	   WHERE salesrep_id = l_rec.salesrep_id
	   AND   org_id = p_role_pay_groups_rec.ORG_ID
	   AND Greatest(start_date, l_rec.start_date) <=
	          Least(Nvl(end_date, l_null_date),
			Nvl(l_rec.end_date, l_null_date));

     IF l_count = 0 THEN
	l_lock_flag := 'N';

	SELECT cn_srp_pay_groups_s.NEXTVAL
	  INTO l_srp_pay_group_id
	  FROM dual;

	CN_SRP_Pay_Groups_Pkg.Begin_Record
	  (x_operation         => 'INSERT',
	   x_srp_pay_group_id  => l_srp_pay_group_id,
	   x_salesrep_id       => l_rec.salesrep_id,
	   x_pay_group_id      => l_pay_group_id,
	   x_start_date        => l_rec.start_date,
	   x_end_date          => l_rec.end_date,
	   x_lock_flag         => l_lock_flag,
	   x_role_pay_group_id => l_role_pay_group_id,
	   x_org_id            => p_role_pay_groups_rec.org_id,
	   x_attribute_category =>p_role_pay_groups_rec.attribute_category,
	   x_attribute1        => p_role_pay_groups_rec.attribute1,
	   x_attribute2        => p_role_pay_groups_rec.attribute2,
	   x_attribute3        => p_role_pay_groups_rec.attribute3,
	   x_attribute4        => p_role_pay_groups_rec.attribute4,
	   x_attribute5        => p_role_pay_groups_rec.attribute5,
	   x_attribute6        => p_role_pay_groups_rec.attribute6,
	   x_attribute7        => p_role_pay_groups_rec.attribute7,
	   x_attribute8        => p_role_pay_groups_rec.attribute8,
	   x_attribute9        => p_role_pay_groups_rec.attribute9,
	  x_attribute10       => p_role_pay_groups_rec.attribute10,
	  x_attribute11       => p_role_pay_groups_rec.attribute11,
	  x_attribute12       => p_role_pay_groups_rec.attribute12,
	  x_attribute13       => p_role_pay_groups_rec.attribute13,
	  x_attribute14       => p_role_pay_groups_rec.attribute14,
	  x_attribute15       => p_role_pay_groups_rec.attribute15,
	  x_last_update_date  => g_last_update_date,
	  x_last_updated_by   => g_last_updated_by,
	  x_creation_date     => g_creation_date,
	  x_created_by        => g_created_by,
	  x_last_update_login => g_last_update_login,
	  x_object_version_number => l_object_version_number);

     END IF;
	 END IF; -- if overlap

      -- Call srp-plan assignment API to insert
	 -- Call cn_srp_periods_pvt api to affect the records in cn_srp_periods

	 FOR roles  IN get_roles(l_rec.salesrep_id,l_rec.org_id) LOOP
	      IF ((roles.start_date <= l_rec.start_date AND roles.end_date >=
		   l_rec.start_date) OR
		  (roles.start_date <= l_rec.end_date AND roles.end_date >=
		   l_rec.end_date ) )  THEN

		 FOR role_plans IN get_role_plans(roles.role_id,roles.org_id) LOOP
		 cn_srp_plan_assigns_pvt.Update_Srp_Plan_Assigns
			(
			 p_api_version    =>    1.0,
			 p_init_msg_list  =>  FND_API.G_FALSE,
			 p_commit	  => FND_API.G_FALSE,
			 p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
			 x_return_status => x_return_status,
			 x_msg_count	 => x_msg_count,
			 x_msg_data	 => x_msg_data,
			 p_srp_role_id   => roles.srp_role_id,
			 p_role_plan_id  => role_plans.role_plan_id,
			 x_loading_status  => x_loading_status );
		      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			 RAISE fnd_api.g_exc_error;
		      END IF;

		   END LOOP;
	      END IF;

	      FOR plans IN get_plan_assigns(roles.role_id,l_rec.salesrep_id,l_rec.org_id) LOOP
		   -- Added to check the start_date and end_date of plan assignment, populate the intersection
		   -- part with the pay group assignment date.

		   IF nvl(plans.end_date,l_null_date) > nvl(l_rec.end_date,l_null_date) THEN
		      plans.end_date := l_rec.end_date;
		   END IF;

		   IF plans.start_date < l_rec.start_date THEN
		      plans.start_date := l_rec.start_date;
		   END IF;

		   IF nvl(plans.end_date, l_null_date) > plans.start_date THEN

		      cn_srp_periods_pvt.create_srp_periods
			( p_api_version => p_api_version,
			  p_init_msg_list => fnd_api.g_false,
			  p_commit => fnd_api.g_false,
			  p_validation_level => p_validation_level,
			  x_return_status => x_return_status,
			  x_msg_count => x_msg_count,
			  x_msg_data => x_msg_data,
			  p_salesrep_id => l_rec.salesrep_id,
			  p_role_id => roles.role_id,
			  p_comp_plan_id => plans.comp_plan_id,
			  p_start_date => plans.start_date,
			  p_end_date => plans.end_date,
			  x_loading_status => x_loading_status);
                      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			 RAISE fnd_api.g_exc_error;
                      END IF;

		   END IF;
      	        END LOOP;
      	   END LOOP;
	   <<end_create_srp_pay_groups>>
	     NULL;
      END LOOP;


      -- End of API body
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
      ROLLBACK TO Create_Role_Pay_Groups;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Role_Pay_Groups;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Role_Pay_Groups;
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

END Create_Role_Pay_Groups;




-- --------------------------------------------------------------------------*
-- Procedure: Delete_Role_Pay_Groups
-- --------------------------------------------------------------------------*
PROCEDURE Delete_Role_Pay_Groups
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY	VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY VARCHAR2 	                      ,
	x_msg_count		   OUT NOCOPY	NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      	      ,
    p_role_pay_groups_rec  IN OUT NOCOPY  role_pay_groups_rec_type
 	) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Delete_Role_Pay_Groups';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_role_pay_group_id               cn_role_pay_groups.role_pay_group_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;
      l_pay_group_id            cn_pay_groups.pay_group_id%TYPE;
      l_org_id                  cn_pay_groups.org_id%TYPE;
      -- Declaration for user hooks
      l_rec          role_pay_groups_rec_type;
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;
      l_null_date          CONSTANT DATE := to_date('31-12-9999','DD-MM-YYYY');
      l_loading_status VARCHAR2(100);
      l_count NUMBER(15);
      l_start_date DATE;
      l_end_date   DATE;


      CURSOR get_roles (p_salesrep_id cn_salesreps.salesrep_id%TYPE,p_org_id cn_salesreps.org_id%TYPE) IS
              SELECT role_id, srp_role_id,start_date, nvl(end_date,l_null_date) end_date,org_id
            	FROM cn_srp_roles
      	WHERE salesrep_id = p_salesrep_id and org_id=p_org_id;

      --Changed the cursor to fetch role_plans for the role_id passed

      CURSOR get_role_plans(l_role_id cn_roles.role_id%TYPE,l_org_id cn_role_plans.org_id%TYPE) IS
      	               SELECT role_plan_id,role_id
      	                 FROM cn_role_plans
                    WHERE role_id =l_role_id and org_id=l_org_id;

      CURSOR get_plan_assigns
                 (p_role_id NUMBER,
                  p_salesrep_id NUMBER,
                  p_org_id NUMBER) IS
            	 SELECT comp_plan_id,
            	   start_date,
            	   end_date,
            	   org_id
            	   FROM cn_srp_plan_assigns
            	   WHERE role_id = p_role_id
            	   AND salesrep_id = p_salesrep_id
                   and org_id=p_org_id;



      CURSOR get_salesreps(l_role_id NUMBER,l_pay_group_id cn_pay_groups.pay_group_id%TYPE,l_org_id cn_pay_groups.org_id%TYPE) IS
                  SELECT srp_role_id,salesrep_id,start_date,end_date,org_id
                    FROM cn_srp_roles
              WHERE role_id = l_role_id
              AND salesrep_id IN (select salesrep_id from cn_srp_pay_groups where pay_group_id=l_pay_group_id)
              and org_id=l_org_id;




BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	delete_role_pay_groups;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
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
   x_loading_status := 'CN_DELETED';


   -- Assign the parameter to a local variable to be passed to Pre, Post
   -- and Business APIs
   l_rec := p_role_pay_groups_rec;


   l_loading_status := x_loading_status;

   -- Start of API body
   check_valid_delete
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_role_pay_groups_rec  => p_role_pay_groups_rec,
       x_role_pay_group_id   => l_role_pay_group_id,
       p_loading_status => l_loading_status, -- in
       x_loading_status => x_loading_status  -- out
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE
      -- delete_row

      l_role_id      := cn_api.get_role_id(p_role_pay_groups_rec.role_name);
      l_pay_group_id := get_pg_id(p_role_pay_groups_rec.pay_groups_name,p_role_pay_groups_rec.org_id);
      l_org_id := p_role_pay_groups_rec.org_id;
      --check this
      cn_role_pay_groups_pkg.delete_row(x_role_pay_group_id => l_role_pay_group_id);

      FOR salesrep IN get_salesreps(l_role_id,l_pay_group_id,l_org_id)

           LOOP
           SAVEPOINT delete_srp_pay_groups;
           --Included a where condition to delete the srp_pay_group record for the role_pay_group_id passed
	   delete from cn_srp_pay_groups where salesrep_id=salesrep.salesrep_id
	     AND role_pay_group_id=l_role_pay_group_id
	     and org_id = l_org_id
	     AND lock_flag='N' AND pay_group_id=l_pay_group_id AND (start_date between p_role_pay_groups_rec.start_date AND nvl(p_role_pay_groups_rec.end_date,l_null_date)) AND
	     (nvl(end_date,l_null_date) between p_role_pay_groups_rec.start_date AND nvl(p_role_pay_groups_rec.end_date,l_null_date))
	     AND NOT EXISTS (SELECT 1 FROM cn_payment_worksheets W, cn_period_statuses prd, cn_payruns prun
			     WHERE w.salesrep_id = salesrep.salesrep_id
			     AND   prun.pay_period_id = prd.period_id
			     AND   prun.payrun_id     = w.payrun_id
			     AND   prun.pay_group_id  = l_pay_group_id
			     and prun.org_id = l_org_id
			     AND ((prd.start_date BETWEEN p_role_pay_groups_rec.start_date AND nvl(p_role_pay_groups_rec.end_date,l_null_date)) OR
				  (prd.end_date between p_role_pay_groups_rec.start_date AND nvl(p_role_pay_groups_rec.end_date,l_null_date)) ));



           IF SQL%ROWCOUNT > 0 THEN

	      FOR role_plans IN get_role_plans(l_role_id,l_org_id)
		LOOP
		   srp_plan_assignment_for_delete
		     (p_role_id        => role_plans.role_id,
		      p_role_plan_id   => role_plans.role_plan_id,
		      p_salesrep_id  => salesrep.salesrep_id,
		      p_org_id => salesrep.org_id,
		      x_return_status  => x_return_status,
		      p_loading_status => l_loading_status,
		      x_loading_status => x_loading_status);

		   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		      RAISE fnd_api.g_exc_error;
		   END IF;
		END LOOP ;

	   select count (*),min(start_date),nvl(max(end_date),l_null_date) end_date
	     INTO l_count,l_start_date,l_end_date
	     from cn_srp_pay_groups
	     where salesrep_id = salesrep.salesrep_id and org_id=salesrep.org_id;

	   -- Bug fix 5200094 vensrini
	   IF l_count = 0 THEN
	      FOR roles IN get_roles(salesrep.salesrep_id, salesrep.org_id)
                LOOP
                   FOR role_plans IN get_role_plans(roles.role_id, salesrep.org_id)
                   LOOP
                         srp_plan_assignment_for_delete(p_role_id  => role_plans.role_id,
       		  		              p_role_plan_id => role_plans.role_plan_id,
			                      p_salesrep_id => salesrep.salesrep_id,
			                      p_org_id => salesrep.org_id,
       		  		              x_return_status  => x_return_status,
       		  	                      p_loading_status => l_loading_status,
       		  	                      x_loading_status => x_loading_status);

                        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;
                    END LOOP ;
		END LOOP;
	   END IF;
	   -- Bug fix 5200094 vensrini

		IF l_count > 0 THEN

		   FOR roles  IN get_roles(salesrep.salesrep_id,salesrep.org_id)
		     LOOP

			IF ((roles.start_date <= salesrep.start_date AND roles.end_date >=
			     salesrep.start_date) OR
			    (roles.start_date <= salesrep.end_date AND roles.end_date >=
			     salesrep.end_date ) )  THEN

			   FOR role_plans IN get_role_plans(roles.role_id,roles.org_id)
			     LOOP
				cn_srp_plan_assigns_pvt.Update_Srp_Plan_Assigns
				  (
				   p_api_version    =>    1.0,
				   p_init_msg_list  =>  FND_API.G_FALSE,
				   p_commit	  => FND_API.G_FALSE,
				   p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
				   x_return_status => x_return_status,
				   x_msg_count	 => x_msg_count,
				   x_msg_data	 => x_msg_data,
				   p_srp_role_id   => roles.srp_role_id,--changed this to support my new change(Harlen.Renu)
				   p_role_plan_id  => role_plans.role_plan_id,
				   x_loading_status  => x_loading_status );
				IF ( x_return_status <> FND_API.g_ret_sts_success) THEN
				   RAISE fnd_api.g_exc_error;
				END IF;
			     END LOOP;
			END IF;

			FOR plans IN get_plan_assigns(roles.role_id,salesrep.salesrep_id,salesrep.org_id)
			  LOOP

			     -- Added to check the start_date and end_date of plan assignment, populate the intersection
			     -- part with the pay group assignment date.

			     IF nvl(plans.end_date,l_null_date) > nvl(l_end_date,l_null_date) THEN
				plans.end_date := l_end_date;
			     END IF;

			     IF plans.start_date < l_start_date THEN
				plans.start_date := l_start_date;
			     END IF;

			     IF nvl(plans.end_date, l_null_date) > plans.start_date THEN

				cn_srp_periods_pvt.create_srp_periods
				  ( p_api_version => p_api_version,
				    p_init_msg_list => fnd_api.g_false,
				    p_commit => fnd_api.g_false,
				    p_validation_level => p_validation_level,
				    x_return_status => x_return_status,
				    x_msg_count => x_msg_count,
				    x_msg_data => x_msg_data,
				    p_salesrep_id => salesrep.salesrep_id,
				    p_role_id => roles.role_id,
				    p_comp_plan_id => plans.comp_plan_id,
				    p_start_date => plans.start_date,
				    p_end_date => plans.end_date,
				    x_loading_status => x_loading_status);
				IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE fnd_api.g_exc_error;
				END IF;

			     END IF;
			  END LOOP;
		     END LOOP;
		END IF;
	   END IF;

	   <<end_srp_pay_groups>>
	     NULL;
	   END LOOP;
	   --Added by Harish
	   -- if any of the salesreps with this role has any unpaid payment batch for this period,
	   -- the paygroup mass assignment relationship is severed
           -- and is treated like an resource level paygroup assignment.
		Update cn_srp_pay_groups_all
		set role_pay_group_id = null
		where role_pay_group_id = l_role_pay_group_id;
           --End

   END IF;


   -- End of API body

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
      ROLLBACK TO Delete_Role_Pay_Groups;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get


(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Role_Pay_Groups;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Role_Pay_Groups;
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
END Delete_Role_Pay_Groups;


END CN_ROLE_PAY_GROUPS_PVT;

/
