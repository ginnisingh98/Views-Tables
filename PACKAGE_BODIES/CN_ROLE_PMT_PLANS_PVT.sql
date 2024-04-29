--------------------------------------------------------
--  DDL for Package Body CN_ROLE_PMT_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLE_PMT_PLANS_PVT" AS
/* $Header: cnprptpb.pls 120.13 2006/08/23 10:29:14 sjustina noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_ROLE_PMT_PLANS_PVT';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnprptpb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
G_MISS_JOB_TITLE            NUMBER  := -99;

G_ROWID                     VARCHAR2(15);
G_PROGRAM_TYPE              VARCHAR2(30);

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
-- Function : valid_pmt_plan_id
-- Desc     : check if the pmt_plan_id exists in cn_pmt_plans
-- ---------------------------------------------------------------------------*
FUNCTION valid_pmt_plan_id
  (
   p_pmt_plan_id cn_pmt_plans.pmt_plan_id%TYPE,
   p_org_id cn_pmt_plans.org_id%TYPE
   ) RETURN BOOLEAN IS

      CURSOR l_cur(l_pmt_plan_id cn_pmt_plans.pmt_plan_id%TYPE, l_org_id cn_pmt_plans.org_id%TYPE) IS
	 SELECT *
	   FROM cn_pmt_plans
	   WHERE pmt_plan_id = l_pmt_plan_id
	   AND org_id = l_org_id;

      l_rec l_cur%ROWTYPE;

BEGIN

   OPEN l_cur(p_pmt_plan_id, p_org_id);
   FETCH l_cur INTO l_rec;
   IF (l_cur%notfound) THEN
      CLOSE l_cur;
      RETURN FALSE;
    ELSE
      CLOSE l_cur;
      RETURN TRUE;
   END IF;

END valid_pmt_plan_id;


-- ----------------------------------------------------------------------------*
-- Function: date_range_within
-- Desc     : check if one date range has an intersection with
--              another date range.
--  private function added by Julia Huang for bug 3135619
-- ----------------------------------------------------------------------------*
FUNCTION date_range_within
(
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
) RETURN BOOLEAN IS
BEGIN
    IF ( a_start_date <= NVL( b_end_date, a_start_date)
        AND b_start_date <= NVL(a_end_date, b_start_date) )
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END date_range_within;


-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_insert
-- Desc     : check if the record is valid to insert into cn_role_pmt_plans
--            called in create_role_pmt_plan before inserting a role-pmtplan
--            assignment
-- ----------------------------------------------------------------------------*
PROCEDURE check_valid_insert
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_role_pmt_plan_rec      IN  role_pmt_plan_rec_type,
   x_role_id                OUT NOCOPY cn_roles.role_id%TYPE,
   x_pmt_plan_id            OUT NOCOPY cn_pmt_plans.pmt_plan_id%TYPE,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'check_valid_insert';

      CURSOR l_cur(l_role_id cn_roles.role_id%TYPE,l_org_id cn_pmt_plans.org_id%TYPE) IS
	 SELECT start_date, end_date, pmt_plan_id
	   FROM cn_role_pmt_plans
	   WHERE role_id = l_role_id
       AND org_id = l_org_id;

      CURSOR l_pp_cur(l_pmt_plan_id cn_pmt_plans.pmt_plan_id%TYPE, l_org_id cn_pmt_plans.org_id%TYPE) IS
	 SELECT start_date, end_date
	   FROM cn_pmt_plans
	   WHERE pmt_plan_id = l_pmt_plan_id
	   AND org_id = l_org_id;

      l_pp_rec l_pp_cur%ROWTYPE;
      l_pp_payment_group_code cn_pmt_plans.payment_group_code%TYPE;
      l_payment_group_code cn_pmt_plans.payment_group_code%TYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   -- validate the following issues

   -- role_name can not be missing or null
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_role_pmt_plan_rec.role_name,
	p_obj_name => G_ROLE_NAME,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- pmt_plan_name can not be missing or null
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_role_pmt_plan_rec.pmt_plan_name,
	p_obj_name => G_PP_NAME,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- start_date can not be null
   -- start_date can not be missing
   -- start_date < end_date if end_date is null
   IF ( (cn_api.invalid_date_range
	 (p_start_date => p_role_pmt_plan_rec.start_date,
	  p_end_date => p_role_pmt_plan_rec.end_date,
	  p_end_date_nullable => FND_API.G_TRUE,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- role_name must exist in cn_roles
   IF NOT valid_role_name(p_role_pmt_plan_rec.role_name) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name('CN', 'CN_RL_ASGN_ROLE_NOT_EXIST');
	 FND_MESSAGE.SET_TOKEN('ROLE_NAME',p_role_pmt_plan_rec.role_name);
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_ASGN_ROLE_NOT_EXIST';
      RAISE fnd_api.g_exc_error;
    ELSE
      x_role_id := cn_api.get_role_id(p_role_pmt_plan_rec.role_name);
   END IF;

   -- pmt_plan_id must exist in cn_pmt_plans
   IF NOT valid_pmt_plan_id(p_role_pmt_plan_rec.pmt_plan_id, p_role_pmt_plan_rec.org_id) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name('CN', 'CN_RL_ASGN_PP_NOT_EXIST');
	 fnd_message.set_token('PMT_PLAN',p_role_pmt_plan_rec.pmt_plan_name);
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_ASGN_PP_NOT_EXIST';
      RAISE fnd_api.g_exc_error;
    ELSE
      --x_pmt_plan_id := cn_api.get_pp_id(p_role_pmt_plan_rec.pmt_plan_name,p_role_pmt_plan_rec.org_id);
      x_pmt_plan_id := p_role_pmt_plan_rec.pmt_plan_id;
   END IF;

   -- (start_date, end_date) is within comp plan's (start_date, end_date)
   OPEN l_pp_cur(p_role_pmt_plan_rec.pmt_plan_id,p_role_pmt_plan_rec.org_id);
   FETCH l_pp_cur INTO l_pp_rec;

   IF (l_pp_cur%notfound) THEN
      -- normally this won't happen as it has been valided previously
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name ('CN', 'CN_RL_ASGN_PP_NOT_EXIST');
	 fnd_message.set_token('PMT_PLAN',p_role_pmt_plan_rec.pmt_plan_name);
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_ASGN_PP_NOT_EXIST';
      CLOSE l_pp_cur;
      RAISE fnd_api.g_exc_error;
    ELSE
      --Commented out by Julia Huang for bug 3135619.
      --IF NOT cn_api.date_range_within(p_role_pmt_plan_rec.start_date,
      IF NOT date_range_within(p_role_pmt_plan_rec.start_date,
				      p_role_pmt_plan_rec.end_date,
				      l_pp_rec.start_date,
				      l_pp_rec.end_date) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_PP_DATE_RANGE_NOT_WITHIN');
	    FND_MESSAGE.SET_TOKEN('START_DATE',p_role_pmt_plan_rec.start_date);
	    FND_MESSAGE.SET_TOKEN('END_DATE',p_role_pmt_plan_rec.end_date);
	    FND_MESSAGE.SET_TOKEN('PP_START_DATE',l_pp_rec.start_date);
	    FND_MESSAGE.SET_TOKEN('PP_END_DATE',l_pp_rec.end_date);
	    FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',p_role_pmt_plan_rec.pmt_plan_name);
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_PP_DATE_RANGE_NOT_WITHIN';
	 CLOSE l_pp_cur;
	 RAISE fnd_api.g_exc_error;
      END IF;

      --bug 3560026 by Julia Huang on 4/7/04 -begin
      IF ( p_role_pmt_plan_rec.start_date < l_pp_rec.start_date )
      THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
        THEN
            fnd_message.set_name ('CN', 'CN_RL_PP_SD_LESS_THAN_PP_SD');
            FND_MESSAGE.SET_TOKEN('START_DATE',p_role_pmt_plan_rec.start_date);
            FND_MESSAGE.SET_TOKEN('END_DATE',p_role_pmt_plan_rec.end_date);
            FND_MESSAGE.SET_TOKEN('PP_START_DATE',l_pp_rec.start_date);
            FND_MESSAGE.SET_TOKEN('PP_END_DATE',l_pp_rec.end_date);
            FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',p_role_pmt_plan_rec.pmt_plan_name);
            fnd_msg_pub.ADD;
        END IF;

        x_loading_status := 'CN_RL_PP_SD_LESS_THAN_PP_SD';
        CLOSE l_pp_cur;
        RAISE fnd_api.g_exc_error;
      END IF;
      --bug 3560026 by Julia Huang on 4/7/04 -end

      CLOSE l_pp_cur;
   END IF;

   -- If existing any same role_id in cn_role_pmt_plans THEN
   -- check no overlap and no gap
   FOR l_rec IN l_cur(x_role_id,p_role_pmt_plan_rec.org_id)
     LOOP

        select payment_group_code into
        l_payment_group_code
	    from cn_pmt_plans
        where pmt_plan_id = l_rec.pmt_plan_id;

       select payment_group_code into
       l_pp_payment_group_code
	   from cn_pmt_plans
	   where pmt_plan_id = p_role_pmt_plan_rec.pmt_plan_id
	   and org_id = p_role_pmt_plan_rec.org_id;

	IF ((cn_api.date_range_overlap(l_rec.start_date,
			      l_rec.end_date,
			      p_role_pmt_plan_rec.start_date,
			      p_role_pmt_plan_rec.end_date))
	   AND

	    (l_pp_payment_group_code = l_payment_group_code))

	 THEN

	   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	      fnd_message.set_name ('CN', 'CN_RL_ROLE_PMT_PLAN_OVERLAP');
	      FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',cn_api.get_pp_name(l_rec.pmt_plan_id));
	      fnd_message.set_token('START_DATE',l_rec.start_date);
	      fnd_message.set_token('END_DATE',l_rec.end_date);
	      fnd_msg_pub.ADD;
	   END IF;
	   x_loading_status := 'CN_RL_ROLE_PMT_PLAN_OVERLAP';
	   RAISE fnd_api.g_exc_error;
	END IF;
     END LOOP;

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
END check_valid_insert;


-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_update
-- Desc     : check if the record is valid to update in cn_role_pmt_plans
--            called in update_role_pmt_plan before updating a role
-- ----------------------------------------------------------------------------*
PROCEDURE check_valid_update
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_role_pmt_plan_rec_old      IN  role_pmt_plan_rec_type,
   p_role_pmt_plan_rec_new      IN  role_pmt_plan_rec_type,
   x_role_pmt_plan_id_old       OUT NOCOPY cn_role_pmt_plans.role_pmt_plan_id%TYPE,
   x_role_id                OUT NOCOPY cn_roles.role_id%TYPE,
   x_pmt_plan_id           OUT NOCOPY cn_pmt_plans.pmt_plan_id%TYPE,
   x_date_update_only       OUT NOCOPY VARCHAR2,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'check_valid_update';
      tmp_start_date    cn_role_pmt_plans.start_date%TYPE;
      tmp_end_date      cn_role_pmt_plans.end_date%TYPE;

      CURSOR l_cur(l_role_id       cn_role_plans.role_id%TYPE,
		   l_role_pmt_plan_id  cn_role_pmt_plans.role_pmt_plan_id%TYPE) IS
	 SELECT start_date, end_date, pmt_plan_id
	   FROM cn_role_pmt_plans
	   WHERE role_id = l_role_id AND
	   role_pmt_plan_id <> l_role_pmt_plan_id;

      CURSOR l_old_cur(l_role_pmt_plan_id cn_role_pmt_plans.role_pmt_plan_id%TYPE) IS
	 SELECT *
	   FROM cn_role_pmt_plans
	   WHERE role_pmt_plan_id = l_role_pmt_plan_id;

      l_old_rec l_old_cur%ROWTYPE;

      CURSOR l_pp_cur(l_pmt_plan_id cn_pmt_plans.pmt_plan_id%TYPE) IS
	 SELECT start_date, end_date
	   FROM cn_pmt_plans
	   WHERE pmt_plan_id = l_pmt_plan_id;

      l_pp_rec l_pp_cur%ROWTYPE;

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   -- validate the following issues

   -- old role_plan_id must exist in cn_role_plans
   x_role_pmt_plan_id_old :=
     cn_api.get_role_pmt_plan_id(p_role_pmt_plan_rec_old.role_name,
			     p_role_pmt_plan_rec_old.pmt_plan_name,
			     p_role_pmt_plan_rec_old.start_date,
			     p_role_pmt_plan_rec_old.end_date,
			     p_role_pmt_plan_rec_old.org_id);

   IF (x_role_pmt_plan_id_old IS NULL) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PP_NOT_EXIST');
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_UPD_ROLE_PP_NOT_EXIST';
      RAISE fnd_api.g_exc_error;
   END IF;

   -- new role_name can not be null
   -- note that new role_name can be missing
   IF (cn_api.chk_null_char_para
       (p_char_para => p_role_pmt_plan_rec_new.role_name,
	p_obj_name => G_ROLE_NAME,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- new pmt_plan_name can not be null
   -- note that new pmt_plan_name can be missing
   IF (cn_api.chk_null_char_para
	(p_char_para => p_role_pmt_plan_rec_new.pmt_plan_name,
	 p_obj_name => G_PP_NAME,
	 p_loading_status => x_loading_status,
	 x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- new start_date can not be null
   -- note that new start_date can be missing
   IF (cn_api.chk_null_date_para
       (p_date_para => p_role_pmt_plan_rec_new.start_date,
	p_obj_name => G_START_DATE,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- if new start_date is missing then
   --    tmp_start_date := old start_date
   -- else
   --    tmp_start_date := new start_date
   -- end if

   -- if new end_date is missing then
   --    tmp_end_date := old end_date
   -- else
   --    tmp_end_date := new end_date
   -- end if

   -- check tmp_start_date < tmp_end_date if tmp_end_date is not null


   OPEN l_old_cur(x_role_pmt_plan_id_old);
   FETCH l_old_cur INTO l_old_rec;
   IF (l_old_cur%notfound) THEN
      -- normally, this should not happen as the existance has
      -- been validated previously
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	 fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PP_NOT_EXIST');
	 fnd_msg_pub.ADD;
      END IF;
      x_loading_status := 'CN_RL_UPD_ROLE_PP_NOT_EXIST';
      CLOSE l_old_cur;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF (p_role_pmt_plan_rec_new.start_date = fnd_api.g_miss_date) THEN
	 tmp_start_date := l_old_rec.start_date;
       ELSE
	 tmp_start_date := p_role_pmt_plan_rec_new.start_date;
      END IF;
      IF (p_role_pmt_plan_rec_new.end_date = fnd_api.g_miss_date) THEN
	 tmp_end_date := l_old_rec.end_date;
       ELSE
	 tmp_end_date := p_role_pmt_plan_rec_new.end_date;
      END IF;
      IF (tmp_end_date IS NOT NULL) AND (tmp_start_date > tmp_end_date) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name('CN', 'CN_RL_INVALID_DATE_RANGE');
	    fnd_message.set_token('START_DATE',tmp_start_date);
	    fnd_message.set_token('END_DATE',tmp_end_date);
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_INVALID_DATE_RANGE';
	 CLOSE l_old_cur;
	 RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE l_old_cur;
   END IF;

   -- if new role_name is not missing then new role_name must exist in cn_roles
   IF (p_role_pmt_plan_rec_new.role_name <> fnd_api.g_miss_char) THEN
      x_role_id := cn_api.get_role_id(p_role_pmt_plan_rec_new.role_name);
      IF (x_role_id IS NULL) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name('CN', 'CN_RL_ASGN_ROLE_NOT_EXIST');
	    fnd_message.set_token('ROLE_NAME',p_role_pmt_plan_rec_new.role_name);
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_ASGN_ROLE_NOT_EXIST';
	 RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      OPEN l_old_cur(x_role_pmt_plan_id_old);
      FETCH l_old_cur INTO l_old_rec;
      IF (l_old_cur%notfound) THEN
	 -- normally, this should not happen as the existance has
	 -- been validated previously
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PP_NOT_EXIST');
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_UPD_ROLE_PP_NOT_EXIST';
	 CLOSE l_old_cur;
	 RAISE fnd_api.g_exc_error;
       ELSE
	 x_role_id := l_old_rec.role_id;
	 CLOSE l_old_cur;
      END IF;
   END IF;

   -- if new pmt_plan_name is not missing then
   -- new pmt_plan_name must exist in cn_pmt_plans
   IF (p_role_pmt_plan_rec_new.pmt_plan_name <> fnd_api.g_miss_char) THEN
      x_pmt_plan_id := cn_api.get_pp_id(p_role_pmt_plan_rec_new.pmt_plan_name,p_role_pmt_plan_rec_new.org_id);
      IF (x_pmt_plan_id IS NULL) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_ASGN_PP_NOT_EXIST');
	    fnd_message.set_token('PMT_PLAN',p_role_pmt_plan_rec_new.pmt_plan_name);
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_ASGN_PP_NOT_EXIST';
	 RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      OPEN l_old_cur(x_role_pmt_plan_id_old);
      FETCH l_old_cur INTO l_old_rec;
      IF (l_old_cur%notfound) THEN
	 -- normally, this should not happen as the existance has
	 -- been validated previously
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_UPD_ROLE_PP_NOT_EXIST');
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_UPD_ROLE_PP_NOT_EXIST';
	 CLOSE l_old_cur;
	 RAISE fnd_api.g_exc_error;
       ELSE
	 x_pmt_plan_id := l_old_rec.pmt_plan_id;
	 CLOSE l_old_cur;
      END IF;
   END IF;

   -- (start_date, end_date) is within pmt plan's (start_date, end_date)
   OPEN l_pp_cur(x_pmt_plan_id);
   FETCH l_pp_cur INTO l_pp_rec;
   IF (l_pp_cur%notfound) THEN
      -- normally this won't happen as it has been valided previously
      x_loading_status := 'CN_RL_ASGN_PP_NOT_EXIST';
      CLOSE l_pp_cur;
      RAISE fnd_api.g_exc_error;
    ELSE
      --Commented out by Julia Huang for bug 3135619.
      --IF NOT cn_api.date_range_within(tmp_start_date,
      IF NOT date_range_within(tmp_start_date,
				      tmp_end_date,
				      l_pp_rec.start_date,
				      l_pp_rec.end_date) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_PP_DATE_RANGE_NOT_WITHIN');
	    FND_MESSAGE.SET_TOKEN('START_DATE',tmp_start_date);
	    FND_MESSAGE.SET_TOKEN('END_DATE',tmp_end_date);
	    FND_MESSAGE.SET_TOKEN('PP_START_DATE',l_pp_rec.start_date);
	    FND_MESSAGE.SET_TOKEN('PP_END_DATE',l_pp_rec.end_date);
	    FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',cn_api.get_pp_name(x_pmt_plan_id));
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_PP_DATE_RANGE_NOT_WITHIN';
	 CLOSE l_pp_cur;
	 RAISE fnd_api.g_exc_error;
      END IF;

      --bug 3560026 by Julia Huang on 4/7/04 -begin
      IF ( tmp_start_date < l_pp_rec.start_date )
      THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
        THEN
            fnd_message.set_name ('CN', 'CN_RL_PP_SD_LESS_THAN_PP_SD');
            FND_MESSAGE.SET_TOKEN('START_DATE',tmp_start_date);
            FND_MESSAGE.SET_TOKEN('END_DATE',tmp_end_date);
            FND_MESSAGE.SET_TOKEN('PP_START_DATE',l_pp_rec.start_date);
            FND_MESSAGE.SET_TOKEN('PP_END_DATE',l_pp_rec.end_date);
            FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',cn_api.get_pp_name(x_pmt_plan_id));
            fnd_msg_pub.ADD;
        END IF;

        x_loading_status := 'CN_RL_PP_SD_LESS_THAN_PP_SD';
        CLOSE l_pp_cur;
        RAISE fnd_api.g_exc_error;
      END IF;
      --bug 3560026 by Julia Huang on 4/7/04 -end

      CLOSE l_pp_cur;
   END IF;


   -- If existing any same role_id in cn_role_pmt_plans THEN
   -- check no overlap
   FOR l_rec IN l_cur(x_role_id,x_role_pmt_plan_id_old)
   LOOP
      IF cn_api.date_range_overlap(l_rec.start_date,
				   l_rec.end_date,
				   tmp_start_date,
				   tmp_end_date) THEN
	 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
	    fnd_message.set_name ('CN', 'CN_RL_ROLE_PMT_PLAN_OVERLAP');
	    FND_MESSAGE.SET_TOKEN('PMT_PLAN_NAME',cn_api.get_pp_name(l_rec.pmt_plan_id));
	    fnd_message.set_token('START_DATE',l_rec.start_date);
	    fnd_message.set_token('END_DATE',l_rec.end_date);
	    fnd_msg_pub.ADD;
	 END IF;
	 x_loading_status := 'CN_RL_ROLE_PMT_PLAN_OVERLAP';
	 RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   -- Checking if it is date_update_only
   OPEN l_old_cur(x_role_pmt_plan_id_old);
   FETCH l_old_cur INTO l_old_rec;
   IF (l_old_cur%notfound) THEN
      -- normally, this should not happen as the existence has
      -- been validated previously
      x_loading_status := 'CN_RL_UPD_ROLE_PP_NOT_EXIST';
      CLOSE l_old_cur;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF ((x_role_id <> l_old_rec.role_id) OR
	  (x_pmt_plan_id <> l_old_rec.pmt_plan_id)) THEN
	 x_date_update_only := FND_API.G_FALSE;
       ELSE
	 x_date_update_only := FND_API.G_TRUE;
      END IF;
      CLOSE l_old_cur;
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
END check_valid_update;


-- ----------------------------------------------------------------------------*
-- Procedure: check_valid_delete
-- Desc     : check if the record is valid to delete from cn_role_pmt_plans
--            called in delete_role_pmt_plan before deleting a role
-- ----------------------------------------------------------------------------*
PROCEDURE check_valid_delete
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_role_pmt_plan_rec          IN  role_pmt_plan_rec_type,
   x_role_pmt_plan_id           OUT NOCOPY NUMBER,
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

   -- Checke if the p_role_pmt_plan_id does exist.

   x_role_pmt_plan_id := p_role_pmt_plan_rec.role_pmt_plan_id;

   /*x_role_pmt_plan_id :=  cn_api.get_role_pmt_plan_id(p_role_pmt_plan_rec.role_name,
				       p_role_pmt_plan_rec.pmt_plan_name,
				       p_role_pmt_plan_rec.start_date,
				       p_role_pmt_plan_rec.end_date,
				       p_role_pmt_plan_rec.org_id);*/
   IF (x_role_pmt_plan_id IS NULL) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	 FND_MESSAGE.SET_NAME('CN' ,'CN_RL_DEL_ROLE_PP_NOT_EXIST');
	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_RL_DEL_ROLE_PP_NOT_EXIST';
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
-- Procedure: srp_pmt_plan_asgn_for_insert
-- --------------------------------------------------------------------------*
PROCEDURE srp_pmt_plan_asgn_for_insert
  (p_role_id        IN cn_roles.role_id%TYPE,
   p_role_pmt_plan_id   IN cn_role_pmt_plans.role_pmt_plan_id%TYPE,
   p_suppress_flag IN VARCHAR2 := 'N',
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

      /* CURSOR l_cur IS
      select sr.srp_role_id                srp_role_id,
             nvl(srd.job_title_id, G_MISS_JOB_TITLE) job_title_id,
	     nvl(srd.plan_activate_status, 'NOT_PUSHED') push_status
	from cn_srp_roles                  sr,
	     cn_srp_role_dtls              srd
       where role_id                     = p_role_id
         and srd.role_model_id is NULL
         -- CHANGED FOR MODELING IMPACT
	 and sr.srp_role_id              = srd.srp_role_id(+);*/


    --To exclude 'TBH' category.  Modified by Julia Huang on 4/7/2004 for bug 3560026.
    /*
      CURSOR l_cur IS
      select *
	from cn_srp_roles
       where role_id                     = p_role_id
           ;
    */
      CURSOR l_cur (l_org_id cn_pmt_plans.org_id%TYPE) IS
      select csr.*
	from cn_srp_roles csr, cn_salesreps cs
       where csr.role_id = p_role_id
       and csr.salesrep_id = cs.salesrep_id
       and csr.org_id = cs.org_id
       and csr.org_id = l_org_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_org_id               cn_srp_pmt_plans.org_id%TYPE;
      l_loading_status       VARCHAR2(2000);


BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

     select org_id into l_org_id
     from cn_role_pmt_plans
     where role_pmt_plan_id = p_role_pmt_plan_id;


   FOR l_rec IN l_cur(l_org_id)
     LOOP

	   --	dbms_output.put_line('insert into cn_srp_pmt_plans...');
	   --	dbms_output.put_line('p_srp_role_id = ' || l_rec.srp_role_id);
	   --	dbms_output.put_line('p_role_pmt_plan_id = ' || p_role_pmt_plan_id);

       CN_SRP_PMT_PLANS_PUB.create_mass_asgn_srp_pmt_plan
	   (p_api_version        => 1.0,
	    x_return_status      => l_return_status,
	    x_msg_count          => l_msg_count,
	    x_msg_data           => l_msg_data,
	    p_srp_role_id        => l_rec.srp_role_id,
            p_role_pmt_plan_id   => p_role_pmt_plan_id,
	    x_srp_pmt_plan_id    => l_srp_pmt_plan_id,
	    x_loading_status     => l_loading_status);

           -- Bug 5125998
           -- After discussing with Fred Mburu on MAY 30 2006
           -- it was understood that this API is going to be called
           -- only from the front end.
           -- Apparently in 11.5.10 even when there was an issue for mass
           -- assignment of the payment plan, the error rows were silently
           -- suppressed and valid rows were committed. (Partial commit implementation)

           IF (p_suppress_flag = 'Y') THEN
              l_msg_count := 0;
              l_msg_data := '';
              fnd_msg_pub.initialize;
              x_return_status := FND_API.G_RET_STS_SUCCESS;
           ELSE
              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      	     x_return_status     := l_return_status;
	      	     x_loading_status    := l_loading_status;
	      	     EXIT;
	      END IF;
           END IF;

	 --IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	     -- x_return_status     := l_return_status;
	     -- x_loading_status    := l_loading_status;
	     -- EXIT;
	 --END IF;
	-- end if;
   END LOOP;
END srp_pmt_plan_asgn_for_insert;


-- --------------------------------------------------------------------------*
-- Procedure: srp_pmt_pmt_plan_asgn_for_update
-- --------------------------------------------------------------------------*
PROCEDURE srp_pmt_plan_asgn_for_update
  (p_role_pmt_plan_id     IN  cn_role_pmt_plans.role_pmt_plan_id%TYPE,
   p_role_id              IN  cn_roles.role_id%TYPE,
   p_date_update_only IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   p_loading_status   IN  VARCHAR2,
   x_loading_status   OUT NOCOPY VARCHAR2 ) IS


      /* CURSOR l_cur IS
      select sr.srp_role_id                srp_role_id,
             nvl(srd.job_title_id, G_MISS_JOB_TITLE) job_title_id,
	     nvl(srd.plan_activate_status, 'NOT_PUSHED') push_status
	from cn_srp_roles                  sr,
	     cn_srp_role_dtls              srd
       where role_id                     = p_role_id
         and srd.role_model_id is NULL
         -- CHANGED FOR MODELING IMPACT
	 and sr.srp_role_id              = srd.srp_role_id(+);*/

      CURSOR l_cur (l_org_id cn_role_pmt_plans.org_id%TYPE) IS
        select srp_role_id
        from cn_srp_roles
        where role_id = p_role_id
        and org_id = l_org_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_assign_id   cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_org_id                   cn_srp_pmt_plans.org_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- see here if it is necessary to update cn_srp_plan_assigns...
   -- the create_module here is OSC.
   -- if the job title not assigned yet (original OSC case) or
   -- status is PUSHED (salesrep push done, treat as OSC record), then
   -- call SPA.update

   select org_id into l_org_id
   from cn_role_pmt_plans
   where role_pmt_plan_id = p_role_pmt_plan_id;

   FOR l_rec IN l_cur(l_org_id) LOOP

	CN_SRP_PMT_PLANS_PUB.update_mass_asgn_srp_pmt_plan
	      (p_api_version            => 1.0,
	       x_return_status          => l_return_status,
	       x_msg_count              => l_msg_count,
	       x_msg_data               => l_msg_data,
	       p_srp_role_id            => l_rec.srp_role_id,
               p_role_pmt_plan_id       => p_role_pmt_plan_id,
	       x_loading_status         => l_loading_status);

	--IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	--    x_return_status     := l_return_status;
	--    x_loading_status    := l_loading_status;
	    -- EXIT;
	--END IF;
   END LOOP;

END srp_pmt_plan_asgn_for_update;


-- --------------------------------------------------------------------------*
-- Procedure: srp_pmt_plan_asgn_for_delete
-- --------------------------------------------------------------------------*
PROCEDURE srp_pmt_plan_asgn_for_delete
  (p_role_id            IN cn_roles.role_id%TYPE,
   p_role_pmt_plan_id   IN cn_role_pmt_plans.role_pmt_plan_id%TYPE,
   p_suppress_flag IN VARCHAR2 := 'N',
   x_return_status  OUT NOCOPY VARCHAR2,
   p_loading_status IN  VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2 ) IS

    CURSOR l_cur (l_org_id cn_role_pmt_plans.org_id%TYPE) IS
	 SELECT srp_role_id
	   FROM cn_srp_roles
	   WHERE role_id = p_role_id
	   AND org_id = l_org_id;

      l_rec l_cur%ROWTYPE;

      l_return_status        VARCHAR2(2000);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(2000);
      l_srp_pmt_plan_id      cn_srp_pmt_plans.srp_pmt_plan_id%TYPE;
      l_org_id               cn_srp_pmt_plans.org_id%TYPE;
      l_loading_status       VARCHAR2(2000);

BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   select org_id into l_org_id
   from cn_role_pmt_plans
   where role_pmt_plan_id = p_role_pmt_plan_id;

   FOR l_rec IN l_cur(l_org_id)
     LOOP

	CN_SRP_PMT_PLANS_PUB.delete_mass_asgn_srp_pmt_plan
	  (
	   p_api_version        => 1.0,
	   p_init_msg_list      => fnd_api.g_true,
	   p_commit             => fnd_api.g_true,
	   p_validation_level   => fnd_api.g_valid_level_full,
	   x_return_status      => l_return_status,
	   x_msg_count          => l_msg_count,
	   x_msg_data           => l_msg_data,
	   p_srp_role_id        => l_rec.srp_role_id,
           p_role_pmt_plan_id   => p_role_pmt_plan_id,
	   x_loading_status     => l_loading_status);

           -- Bug 5125998
           -- After discussing with Fred Mburu on MAY 30 2006
           -- it was understood that this API is going to be called
           -- only from the front end.
           -- Apparently in 11.5.10 even when there was an issue for mass
           -- assignment of the payment plan, the error rows were silently
           -- suppressed and valid rows were committed. (Partial commit implementation)

           IF (p_suppress_flag = 'Y') THEN
	       l_msg_count := 0;
	       l_msg_data := '';
	       x_return_status := FND_API.G_RET_STS_SUCCESS;
	   ELSE
	       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   	   x_return_status     := l_return_status;
	   	   x_loading_status    := l_loading_status;
	   	   EXIT;
	       END IF;
           END IF;

 	--IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	--   x_return_status     := l_return_status;
	--   x_loading_status    := l_loading_status;
	   -- EXIT;
	--END IF;

     END LOOP;
END srp_pmt_plan_asgn_for_delete;


-- --------------------------------------------------------------------------*
-- Procedure: create_role_pmt_plan
-- --------------------------------------------------------------------------*
PROCEDURE Create_Role_Pmt_Plan
  (
   p_api_version           IN	NUMBER				      ,
   p_init_msg_list	   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
   p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
   p_validation_level	   IN  	NUMBER	 := FND_API.g_valid_level_full,
   x_return_status	   OUT	NOCOPY VARCHAR2		      	      ,
   x_loading_status        OUT  NOCOPY VARCHAR2 	                      ,
   x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
   x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
   p_role_pmt_plan_rec         IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
   ) IS

      l_api_name		CONSTANT VARCHAR2(30) := 'Create_Role_Pmt_Plan';
      l_api_version           	CONSTANT NUMBER  := 1.0;
      l_role_pmt_plan_id        cn_role_pmt_plans.role_pmt_plan_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;
      l_pmt_plan_id             cn_pmt_plans.pmt_plan_id%TYPE;


      -- Declaration for user hooks
      l_rec role_pmt_plan_rec_type;
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	create_role_pmt_plan;

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
   l_rec := p_role_pmt_plan_rec;

   -- Start of API body


   check_valid_insert
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_role_pmt_plan_rec  => p_role_pmt_plan_rec,
       x_role_id        => l_role_id,
       x_pmt_plan_id   => l_pmt_plan_id,
       p_loading_status => x_loading_status, -- in
       x_loading_status => x_loading_status  -- out
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   ELSE

      SELECT cn_role_pmt_plans_s.NEXTVAL INTO l_role_pmt_plan_id
	FROM dual;

      cn_role_pmt_plans_pkg.INSERT_ROW
	(
	 x_org_id		   => p_role_pmt_plan_rec.org_id
	 ,x_role_pmt_plan_id 	   => l_role_pmt_plan_id
	 ,x_role_id                => l_role_id
	 ,x_pmt_plan_id            => l_pmt_plan_id
	 ,x_start_date             => p_role_pmt_plan_rec.start_date
	 ,x_end_date               => p_role_pmt_plan_rec.end_date
	 ,x_attribute_category     => p_role_pmt_plan_rec.ATTRIBUTE_CATEGORY
	 ,x_attribute1             => p_role_pmt_plan_rec.ATTRIBUTE1
	 ,x_attribute2             => p_role_pmt_plan_rec.ATTRIBUTE2
	 ,x_attribute3             => p_role_pmt_plan_rec.ATTRIBUTE3
	 ,x_attribute4             => p_role_pmt_plan_rec.ATTRIBUTE4
	 ,x_attribute5             => p_role_pmt_plan_rec.ATTRIBUTE5
	 ,x_attribute6             => p_role_pmt_plan_rec.ATTRIBUTE6
	 ,x_attribute7             => p_role_pmt_plan_rec.ATTRIBUTE7
	 ,x_attribute8             => p_role_pmt_plan_rec.ATTRIBUTE8
	 ,x_attribute9             => p_role_pmt_plan_rec.ATTRIBUTE9
	 ,x_attribute10            => p_role_pmt_plan_rec.ATTRIBUTE10
	 ,x_attribute11            => p_role_pmt_plan_rec.ATTRIBUTE11
	 ,x_attribute12            => p_role_pmt_plan_rec.ATTRIBUTE12
	 ,x_attribute13            => p_role_pmt_plan_rec.ATTRIBUTE13
	 ,x_attribute14            => p_role_pmt_plan_rec.ATTRIBUTE14
	 ,x_attribute15            => p_role_pmt_plan_rec.ATTRIBUTE15
	 ,x_created_by             => g_created_by
	 ,x_creation_date          => g_creation_date
	 ,x_last_update_login      => g_last_update_login
	 ,x_last_update_date       => g_last_update_date
	 ,x_last_updated_by        => g_last_updated_by);

      -- Call srp-plan assignment API to insert

      srp_pmt_plan_asgn_for_insert(p_role_id        => l_role_id,
		   		   p_role_pmt_plan_id   => l_role_pmt_plan_id,
		   		   p_suppress_flag => 'Y',
				   x_return_status  => x_return_status,
				   p_loading_status => x_loading_status,
				   x_loading_status => x_loading_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

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
      ROLLBACK TO create_role_pmt_plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_role_pmt_plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO create_role_pmt_plan;
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

END create_role_pmt_plan;


-- --------------------------------------------------------------------------*
-- Procedure: Update_Role_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Update_Role_Pmt_Plan
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2 	                      ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_pmt_plan_rec_old    IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC,
        p_ovn                      IN   cn_role_pmt_plans.object_version_number%TYPE,
	p_role_pmt_plan_rec_new    IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
	) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Update_Role_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_role_pmt_plan_id_old       cn_role_pmt_plans.role_pmt_plan_id%TYPE;
      l_role_id                    cn_roles.role_id%TYPE;
      l_pmt_plan_id                cn_pmt_plans.pmt_plan_id%TYPE;
      l_date_update_only           VARCHAR2(1);

      -- Declaration for user hooks
      l_rec_old      role_pmt_plan_rec_type;
      l_rec_new      role_pmt_plan_rec_type;
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;

BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	update_role_pmt_plan;

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
   x_loading_status := 'CN_UPDATED';


   -- Assign the parameter to a local variable to be passed to Pre, Post
   -- and Business APIs
   l_rec_old := p_role_pmt_plan_rec_old;
   l_rec_new := p_role_pmt_plan_rec_old;


   -- Start of API body

   check_valid_update
     ( x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       p_role_pmt_plan_rec_old   => p_role_pmt_plan_rec_old,
       p_role_pmt_plan_rec_new   => p_role_pmt_plan_rec_new,
       x_role_pmt_plan_id_old    => l_role_pmt_plan_id_old,
       x_role_id             => l_role_id,
       x_pmt_plan_id        => l_pmt_plan_id,
       x_date_update_only    => l_date_update_only,
       p_loading_status      => x_loading_status, -- in
       x_loading_status      => x_loading_status  -- out
       );

   -- x_return_status is failure for all failure cases,

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSE

      cn_role_pmt_plans_pkg.UPDATE_ROW
	(
	 x_org_id			=> p_role_pmt_plan_rec_new.org_id
	 ,x_role_pmt_plan_id            => l_role_pmt_plan_id_old
	 ,x_role_id                => l_role_id
	 ,x_pmt_plan_id            => l_pmt_plan_id
	 ,x_start_date             => p_role_pmt_plan_rec_new.start_date
	 ,x_end_date               => p_role_pmt_plan_rec_new.end_date
	 ,x_attribute_category     => p_role_pmt_plan_rec_new.ATTRIBUTE_CATEGORY
	 ,x_attribute1             => p_role_pmt_plan_rec_new.ATTRIBUTE1
	 ,x_attribute2             => p_role_pmt_plan_rec_new.ATTRIBUTE2
	 ,x_attribute3             => p_role_pmt_plan_rec_new.ATTRIBUTE3
	 ,x_attribute4             => p_role_pmt_plan_rec_new.ATTRIBUTE4
	 ,x_attribute5             => p_role_pmt_plan_rec_new.ATTRIBUTE5
	 ,x_attribute6             => p_role_pmt_plan_rec_new.ATTRIBUTE6
	 ,x_attribute7             => p_role_pmt_plan_rec_new.ATTRIBUTE7
	 ,x_attribute8             => p_role_pmt_plan_rec_new.ATTRIBUTE8
	 ,x_attribute9             => p_role_pmt_plan_rec_new.ATTRIBUTE9
	 ,x_attribute10            => p_role_pmt_plan_rec_new.ATTRIBUTE10
	 ,x_attribute11            => p_role_pmt_plan_rec_new.ATTRIBUTE11
	 ,x_attribute12            => p_role_pmt_plan_rec_new.ATTRIBUTE12
	 ,x_attribute13            => p_role_pmt_plan_rec_new.ATTRIBUTE13
	 ,x_attribute14            => p_role_pmt_plan_rec_new.ATTRIBUTE14
	 ,x_attribute15            => p_role_pmt_plan_rec_new.ATTRIBUTE15
	 ,x_created_by             => g_created_by
	 ,x_creation_date          => g_creation_date
	 ,x_last_update_login      => g_last_update_login
	 ,x_last_update_date       => g_last_update_date
	 ,x_last_updated_by        => g_last_updated_by
         ,x_object_version_number  => p_ovn);

      -- Call srp assignment API to update

      -- IF UPDATE is only for start_date and end_date THEN call srp_plan_assigns.update
      -- IF the update will change comp plan then
      -- call srp_plan_assign.delete then insert


      srp_pmt_plan_asgn_for_update(p_role_pmt_plan_id     => l_role_pmt_plan_id_old,
                                   p_role_id              => l_role_id,
				   p_date_update_only => l_date_update_only,
				   x_return_status    => x_return_status,
				   p_loading_status   => x_loading_status,
				   x_loading_status   => x_loading_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

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
      ROLLBACK TO update_role_pmt_plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_role_pmt_plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO update_role_pmt_plan;
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

END update_role_pmt_plan;


-- --------------------------------------------------------------------------*
-- Procedure: Delete_Role_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Delete_Role_Pmt_Plan
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2 	                      ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
        p_role_pmt_plan_rec            IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
 	) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Delete_Role_Pmt_Plan';
      l_api_version           	   CONSTANT NUMBER  := 1.0;
      l_role_pmt_plan_id               cn_role_pmt_plans.role_pmt_plan_id%TYPE;
      l_role_id                 cn_roles.role_id%TYPE;

      -- Declaration for user hooks
      l_rec          role_pmt_plan_rec_type;
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER ;


BEGIN
   -- Standard Start of API savepoint

   SAVEPOINT	delete_role_pmt_plan;

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
   l_rec := p_role_pmt_plan_rec;

   -- Start of API body

   check_valid_delete
     ( x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_role_pmt_plan_rec  => p_role_pmt_plan_rec,
       x_role_pmt_plan_id   => l_role_pmt_plan_id,
       p_loading_status => x_loading_status, -- in
       x_loading_status => x_loading_status  -- out
       );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSE

      -- need to call srp assignment API to delete

      l_role_id      := cn_api.get_role_id(p_role_pmt_plan_rec.role_name);
      srp_pmt_plan_asgn_for_delete(p_role_id        => l_role_id,
				   p_role_pmt_plan_id   => l_role_pmt_plan_id,
				   p_suppress_flag => 'Y',
				   x_return_status  => x_return_status,
				   p_loading_status => x_loading_status,
				   x_loading_status => x_loading_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- delete_row
      cn_role_pmt_plans_pkg.delete_row(x_role_pmt_plan_id => l_role_pmt_plan_id);

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
      ROLLBACK TO delete_role_pmt_plan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_role_pmt_plan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO delete_role_pmt_plan;
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
END delete_role_pmt_plan;

FUNCTION date_range_overlap
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER IS

BEGIN

   IF (a_end_date IS NOT NULL) THEN
      IF (b_end_date IS NOT NULL) THEN
   IF ((b_start_date BETWEEN a_start_date AND a_end_date) OR
       (b_end_date BETWEEN a_start_date AND a_end_date) OR
       (a_start_date BETWEEN b_start_date AND b_end_date) OR
       (a_end_date BETWEEN b_start_date AND b_end_date)) THEN
      RETURN 1; -- overlap
   END IF;
       ELSE
   IF (b_start_date <= a_end_date) THEN
      RETURN 1; -- overlap
   END IF;
      END IF;
    ELSE
      IF (b_end_date IS NOT NULL) THEN
   IF (b_end_date >= a_start_date) THEN
      RETURN 1; -- overlap
   END IF;
       ELSE
   RETURN 1; -- overlap
      END IF;
   END IF;

   RETURN 0;  -- not overlap

END date_range_overlap;

FUNCTION date_range_diff_present
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER IS
    x_date_range_tbl cn_api.date_range_tbl_type;
BEGIN
    cn_api.get_date_range_diff(a_start_date,
                                a_end_date,
                                b_start_date,
                                b_end_date,
                                x_date_range_tbl);
     IF x_date_range_tbl IS NOT NULL THEN
        IF x_date_range_tbl.count > 0 THEN
            return 1;
         end if;
         else
            return 0;
     end if;
     return 0;


END date_range_diff_present;

FUNCTION date_range_intersect
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER IS
    x_start_date DATE;
    x_end_date DATE;
BEGIN
    if(cn_api.date_range_overlap(a_start_date,
                                a_end_date,
                                b_start_date,
                                b_end_date)) THEN
        cn_api.get_date_range_intersect(a_start_date,
                                a_end_date,
                                b_start_date,
                                b_end_date,
                                x_start_date,
                                x_end_date);
        IF x_start_date IS NOT NULL THEN
            return 1;
        else
            return 0;
        end if;
     return 0;
     END IF;
     return 0;

END date_range_intersect;

END CN_ROLE_PMT_PLANS_PVT;

/
