--------------------------------------------------------
--  DDL for Package Body CN_PMTPLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMTPLAN_PVT" as
-- $Header: cnvpplnb.pls 120.11 2006/10/26 10:25:58 sjustina ship $
--
--
--  Procedure   : Get_PmtPlan_ID
--  Description : This procedure is used to get the ID for the pmt plan
--
--
PROCEDURE Get_PmtPlan_ID
  (
   x_return_status	    OUT	NOCOPY VARCHAR2 ,
   x_msg_count		    OUT	NOCOPY NUMBER	 ,
   x_msg_data		    OUT	NOCOPY VARCHAR2 ,
   p_PmtPlan_rec            IN  PmtPlan_Rec_Type,
   p_loading_status         IN  VARCHAR2,
   x_pmt_plan_id            OUT NOCOPY NUMBER,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

   l_api_name  CONSTANT VARCHAR2(30) := 'Get_PmtPlan_ID';

   CURSOR get_PmtPlan_id is
      SELECT pmt_plan_id
        FROM cn_pmt_plans
       WHERE name = p_PmtPlan_rec.name
         AND start_date = p_PmtPlan_rec.start_date
         AND end_date = p_PmtPlan_rec.end_date
         AND org_id = p_PmtPlan_rec.org_id;

   --If end date is null, then use the following cursor
   CURSOR get_PmtPlan_id2 is
      SELECT pmt_plan_id
        FROM cn_pmt_plans
       WHERE name = p_PmtPlan_rec.name
         AND start_date = p_PmtPlan_rec.start_date
         AND org_id = p_PmtPlan_rec.org_id;

   l_get_PmtPlan_id_rec get_PmtPlan_id%ROWTYPE;
   L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PVT';


BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;
   x_status := p_loading_status ;

   --Open appropriate cursor and fetch the payment plan ID
   IF p_PmtPlan_rec.end_date IS NOT NULL
   THEN

      OPEN get_PmtPlan_id;
      FETCH get_PmtPlan_id INTO l_get_PmtPlan_id_rec;
      IF get_PmtPlan_id%ROWCOUNT = 0
      THEN
         x_status := 'NEW PMT PLAN';
         SELECT nvl(p_PmtPlan_rec.pmt_plan_id,cn_pmt_plans_s.nextval)
           INTO x_pmt_plan_id
           FROM dual;
      ELSIF get_PmtPlan_id%ROWCOUNT = 1
      THEN
         x_status := 'PMT PLAN EXISTS';
         x_pmt_plan_id  := l_get_PmtPlan_id_rec.pmt_plan_id;
      END IF;
      CLOSE get_PmtPlan_id;
   ELSE
      OPEN get_PmtPlan_id2;
      FETCH get_PmtPlan_id2 INTO l_get_PmtPlan_id_rec;
      IF get_PmtPlan_id2%ROWCOUNT = 0
      THEN
         x_status := 'NEW PMT PLAN';
         SELECT nvl(p_PmtPlan_rec.pmt_plan_id,cn_pmt_plans_s.nextval)
           INTO x_pmt_plan_id
           FROM dual;

      ELSIF get_PmtPlan_id2%ROWCOUNT = 1
      THEN
         x_status := 'PMT PLAN EXISTS';
         x_pmt_plan_id  := l_get_PmtPlan_id_rec.pmt_plan_id;
      END IF;
      CLOSE get_PmtPlan_id2;
   END IF;

EXCEPTION
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;

END Get_PmtPlan_ID;


--
--
--  Procedure   : Validate_PmtPlan
--  Description : This procedure is used to validate the parameters that
--		  have been passed to create a pmt plan.
--
--
PROCEDURE Validate_PmtPlan
  (
   x_return_status	    OUT	NOCOPY VARCHAR2 ,
   x_msg_count		    OUT	NOCOPY NUMBER	 ,
   x_msg_data		    OUT	NOCOPY VARCHAR2 ,
   p_PmtPlan_rec            IN  PmtPlan_Rec_Type,
   p_loading_status         IN  VARCHAR2,
   x_loading_status         OUT NOCOPY VARCHAR2,
   x_status		    OUT NOCOPY VARCHAR2
   ) IS

      l_count		      NUMBER;
      l_pg_count          NUMBER;
      l_pay_interval_type_id  NUMBER;
      l_credit_type_id	NUMBER;
      l_api_name     CONSTANT VARCHAR2(30) := 'Validate_PmtPlan';
      L_PKG_NAME     CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PVT';

   CURSOR get_credit_type_id IS
      SELECT credit_type_id
	FROM cn_credit_types
	WHERE name = p_PmtPlan_rec.credit_type_name
            and org_id = p_PmtPlan_rec.org_id;

   CURSOR get_pay_interval_type_id IS
      SELECT interval_type_id
	FROM cn_interval_types
	WHERE name = p_pmtplan_rec.pay_interval_type_name
            and org_id = p_PmtPlan_rec.org_id;

BEGIN

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status ;
   x_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Check for missing and null parameters.
   --
   IF ( (cn_api.chk_miss_char_para
	     (p_char_para => p_PmtPlan_rec.name,
	      p_para_name  => 'Pmt Plan Name',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_char_para
	     (p_char_para => p_PmtPlan_rec.name,
	      p_obj_name  => 'Pmt Plan Name',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF g_mode = 'INSERT'
     THEN

   IF ( (cn_api.chk_miss_char_para
	     (p_char_para => p_PmtPlan_rec.credit_type_name,
	      p_para_name  => 'Credit Type Name',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_char_para
	     (p_char_para => p_PmtPlan_rec.credit_type_name,
	      p_obj_name  => 'Credit Type Name',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   END IF;

   IF ( (cn_api.chk_miss_date_para
	     (p_date_para => p_PmtPlan_rec.start_date,
	      p_para_name  => 'Start Date',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( (cn_api.chk_null_date_para
	     (p_date_para => p_PmtPlan_rec.start_date,
	      p_obj_name  => 'Start Date',
	      p_loading_status => x_loading_status,
	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
   THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   --Check to ensure start date is less than end date
   --If not, raise an error
   IF p_PmtPlan_rec.end_date IS NOT NULL
     AND p_pmtplan_rec.start_date IS NOT NULL
      AND (p_PmtPlan_rec.start_date > p_PmtPlan_rec.end_date)
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

   -- Check Max amount must > Min amount
   IF p_pmtplan_rec.minimum_amount IS NOT NULL
   AND p_pmtplan_rec.maximum_amount IS NOT NULL
   THEN

	  IF (p_pmtplan_rec.maximum_amount < p_pmtplan_rec.minimum_amount)
	    THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.SET_NAME ('CN' , 'CN_SPP_MAX_LT_MIN');
		FND_MSG_PUB.Add;
	     END IF;
	     x_loading_status := 'CN_SPP_MAX_LT_MIN';
	     RAISE FND_API.G_EXC_ERROR ;
	  END IF;
   END IF;

   --Check for min_rec_flag and max_rec_flag
   IF p_pmtplan_rec.min_rec_flag IS NOT NULL
     THEN
      IF  p_pmtplan_rec.min_rec_flag NOT IN ('Y', 'N')
	THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_PMT_PLAN_FLAGS');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_INVALID_PMT_PLAN_FLAGS';
	 x_loading_status := 'CN_INVALID_PMT_PLAN_FLAGS';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF p_pmtplan_rec.max_rec_flag IS NOT NULL
     THEN
      IF p_pmtplan_rec.max_rec_flag NOT IN ('Y', 'N')
	THEN

	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_PMT_PLAN_FLAGS');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_INVALID_PMT_PLAN_FLAGS';
	 x_loading_status := 'CN_INVALID_PMT_PLAN_FLAGS';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Added by Sundar Venkat Null check for Payment_Group_Code


   IF ( (cn_api.chk_miss_char_para
   	     (p_char_para => p_PmtPlan_rec.payment_group_code,
   	      p_para_name  => 'Payment Group Code',
   	      p_loading_status => x_loading_status,
   	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
      THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF ( (cn_api.chk_null_char_para
   	     (p_char_para => p_PmtPlan_rec.payment_group_code,
   	      p_obj_name  => 'Payment Group Code',
   	      p_loading_status => x_loading_status,
   	      x_loading_status => x_loading_status)) = FND_API.G_TRUE )
      THEN
         RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Check for a valid payment group code. Added by Raja Ramasamy on 7-oct-2005

   select count(1) into l_pg_count from cn_lookups
   where lookup_type like 'PAYMENT_GROUP_CODE'
   and lookup_code = p_PmtPlan_rec.payment_group_code;

   if (l_pg_count = 0)
   then
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_PAY_INVALID_PG_CODE');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_PAY_INVALID_PG_CODE';
	 x_loading_status := 'CN_PAY_INVALID_PG_CODE';
	 RAISE FND_API.G_EXC_ERROR;
    end if;

   -- Since payment plan names are unique in an org, check if a record already exists with the same name.

    SELECT COUNT(*)
	INTO l_count
        FROM cn_pmt_plans
        WHERE name = p_PmtPlan_rec.name
                and org_id = p_PmtPlan_rec.org_id;

   IF (l_count <> 0) THEN
      x_status := 'PMT PLAN EXISTS';
   END IF ;

    -- Validate for invalid credit type
   OPEN get_credit_type_id;
   FETCH get_credit_type_id INTO l_credit_type_id;
   IF get_credit_type_id%ROWCOUNT = 0
   THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN

         fnd_message.set_name('CN', 'CN_INVALID_CREDIT_TYPE');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_CREDIT_TYPE';
      CLOSE get_credit_type_id;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE get_credit_type_id;

   -- Validate for correct pay interval type id

    IF p_pmtplan_rec.pay_interval_type_name IS NOT NULL
    THEN
     OPEN get_pay_interval_type_id;
     FETCH get_pay_interval_type_id INTO l_pay_interval_type_id;
     IF get_pay_interval_type_id%ROWCOUNT = 0 OR
       l_pay_interval_type_id NOT IN  (-1000, -1001, -1002)
       THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
           fnd_message.set_name('CN', 'CN_INVALID_PAY_INTERVAL');
           fnd_msg_pub.add;
        END IF;
        x_loading_status := 'CN_INVALID_PAY_INTERVAL';
        CLOSE get_pay_interval_type_id;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE get_pay_interval_type_id;
    END IF;


   -- End of Validate Pmt Plans.
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
	 FND_MSG_PUB.Add_Exc_Msg( L_PKG_NAME ,l_api_name );
      END IF;

END Validate_PmtPlan;

--
-- Procedure  : Create_PmtPlan
-- Description: Public API to create a pmt plan
-- Calls      : validate_pmt_plan
--		CN_Pmt_Plans_Pkg.Begin_Record
--
PROCEDURE Create_PmtPlan(
    p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 ,
    p_commit	    		IN  	VARCHAR2,
    p_validation_level		IN  	NUMBER,
    x_return_status		OUT	NOCOPY VARCHAR2,
    x_msg_count			OUT	NOCOPY NUMBER,
    x_msg_data			OUT	NOCOPY VARCHAR2,
    p_PmtPlan_rec       	IN OUT NOCOPY   PmtPlan_Rec_Type,
    x_loading_status		OUT     NOCOPY VARCHAR2,
    x_status                    OUT     NOCOPY VARCHAR2
  ) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Create_PmtPlan';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_pmt_plan_id	NUMBER;
    l_credit_type_id	NUMBER;
    l_pay_interval_type_id NUMBER;

    l_recoverable_interval_type_id NUMBER;

    l_pay_against_commission  VArchar2(02);

    L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PVT';
    L_LAST_UPDATE_DATE          DATE    := sysdate;
    L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
    L_CREATION_DATE             DATE    := sysdate;
    L_CREATED_BY                NUMBER  := fnd_global.user_id;
    L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
    L_ROWID                     VARCHAR2(30);
    L_PROGRAM_TYPE              VARCHAR2(30);

    CURSOR get_credit_type_id IS
    SELECT credit_type_id
    FROM cn_credit_types
    WHERE name = p_PmtPlan_rec.credit_type_name
        and org_id = p_PmtPlan_rec.org_id;

   CURSOR get_pay_interval_type_id IS
      SELECT interval_type_id
	FROM cn_interval_types
	WHERE name = p_pmtplan_rec.pay_interval_type_name
            and org_id = p_PmtPlan_rec.org_id;


   CURSOR get_rec_interval_type_id IS
      SELECT interval_type_id
	FROM cn_interval_types
	WHERE name = p_pmtplan_rec.recoverable_interval_type
        and org_id = p_PmtPlan_rec.org_id;

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Create_PmtPlan;
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
   -- API body
   --

   --
   --Initialize g_mode
   --
   g_mode := 'INSERT';

   Validate_PmtPlan(
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PmtPlan_rec        => p_PmtPlan_rec,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status,
      x_status             => x_status
     );

   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR ;
   ELSIF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) AND ( x_status <> 'PMT PLAN EXISTS' )
     THEN

     get_PmtPlan_id(
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_PmtPlan_rec        => p_PmtPlan_rec,
           x_pmt_plan_id        => l_pmt_plan_id,
           p_loading_status     => x_loading_status,
           x_loading_status     => x_loading_status,
           x_status             => x_status
	   );

    p_PmtPlan_rec.pmt_plan_id := l_pmt_plan_id;

   -- At this point, credit type is already validated in Validate_PmtPlan
   -- Get the credit type id for the given credit type name
   OPEN get_credit_type_id;
   FETCH get_credit_type_id INTO l_credit_type_id;

    -- At this point, Pay interval type name is already validate in Validate_pmtPlan method
    -- Get the Pay interval type id for the given pay interval type name
    IF p_pmtplan_rec.pay_interval_type_name IS NOT NULL
    THEN
     OPEN get_pay_interval_type_id;
     FETCH get_pay_interval_type_id INTO l_pay_interval_type_id;
    else
        l_pay_interval_type_id := -1000;
    END IF;

   -- Recoverable Interval type

     IF p_pmtplan_rec.recoverable_interval_type IS NOT NULL
	 THEN
	   OPEN get_rec_interval_type_id;
	  FETCH get_rec_interval_type_id INTO l_recoverable_interval_type_id;
	  CLOSE get_rec_interval_type_id;
     END IF;

    l_pay_against_commission:= p_pmtplan_rec.pay_against_commission ;


    if l_recoverable_interval_type_id is NULL OR
       l_recoverable_interval_type_id = -1000 THEN

       if l_pay_interval_type_id = -1000 THEN

          l_recoverable_interval_type_id := -1000;
          l_pay_against_commission := p_pmtplan_rec.pay_against_commission;

       elsif l_pay_interval_type_id <> -1000 THEN

          l_recoverable_interval_type_id :=  l_pay_interval_type_id;
          --l_pay_against_commission := 'N';
          -- Added by Kumar find a bug
          l_pay_against_commission :=  p_pmtplan_rec.pay_against_commission;

       end if;

    else

        if ( l_recoverable_interval_type_id = -1001 and
           l_pay_interval_type_id = -1002 ) THEN

        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
	    fnd_message.set_name('CN', 'CN_INVALID_PAY_INT_AND_REC_INT');
	    fnd_msg_pub.add;
        END IF;

        x_status := 'CN_INV_PAY_INT_AND_REC';
        x_loading_status := 'CCN_INV_PAY_INT_AND_REC';
        RAISE FND_API.G_EXC_ERROR;
        end if;

   end if;

  -- added on 02/nov/2001 only the additional and
    IF l_recoverable_interval_type_id IN ( -1001, -1002 ) AND
       l_recoverable_interval_type_id <> l_pay_interval_type_id and
       nvl(l_pay_against_commission,'Y') <> 'N' THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_REC_AND_PAC');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_INVALID_REC_AND_PAC';
	 x_loading_status := 'CCN_INVALID_REC_AND_PAC';
	 RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- added on 02/nov/2001 only the additional and
  IF nvl(l_recoverable_interval_type_id,0) NOT IN ( -1001, -1002 ) AND
       l_recoverable_interval_type_id <> l_pay_interval_type_id and
       nvl(l_pay_against_commission,'Y') = 'N' THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_REC_AND_PAC');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_INVALID_REC_AND_PAC';
	 x_loading_status := 'CCN_INVALID_REC_AND_PAC';
	 RAISE FND_API.G_EXC_ERROR;
   END IF;

       CN_Pmt_Plans_Pkg.Begin_Record
	   (
        x_operation            => 'INSERT',
        x_rowid                => L_ROWID,
        x_org_id                => p_PmtPlan_rec.org_id,
        x_pmt_plan_id          => p_PmtPlan_rec.pmt_plan_id,
        x_name                 => p_PmtPlan_rec.name,
        x_minimum_amount	   => p_PmtPlan_rec.minimum_amount,
        x_maximum_amount	   => p_PmtPlan_rec.maximum_amount,
        x_min_rec_flag	   => Nvl(p_PmtPlan_rec.min_rec_flag, 'Y'),
        x_max_rec_flag	   => Nvl(p_PmtPlan_rec.max_rec_flag, 'Y'),
        x_max_recovery_amount  => p_PmtPlan_rec.max_recovery_amount,
        x_credit_type_id	   => l_credit_type_id,
        x_pay_interval_type_id => l_pay_interval_type_id,
        x_start_date           => p_PmtPlan_rec.start_date,
        x_end_date             => p_PmtPlan_rec.end_date,
        x_object_version_number => p_PmtPlan_rec.object_version_number,
        x_recoverable_interval_type_id => l_recoverable_interval_type_id,
        x_pay_against_commission   => l_pay_against_commission,
        x_attribute_category   => p_PmtPlan_rec.attribute_category,
        x_attribute1           => p_PmtPlan_rec.attribute1,
        x_attribute2           => p_PmtPlan_rec.attribute2,
        x_attribute3           => p_PmtPlan_rec.attribute3,
        x_attribute4           => p_PmtPlan_rec.attribute4,
        x_attribute5           => p_PmtPlan_rec.attribute5,
        x_attribute6           => p_PmtPlan_rec.attribute6,
        x_attribute7           => p_PmtPlan_rec.attribute7,
        x_attribute8           => p_PmtPlan_rec.attribute8,
        x_attribute9           => p_PmtPlan_rec.attribute9,
        x_attribute10          => p_PmtPlan_rec.attribute10,
        x_attribute11          => p_PmtPlan_rec.attribute10,
        x_attribute12          => p_PmtPlan_rec.attribute12,
        x_attribute13          => p_PmtPlan_rec.attribute13,
        x_attribute14          => p_PmtPlan_rec.attribute14,
        x_attribute15          => p_PmtPlan_rec.attribute15,
        x_last_update_date     => l_last_update_date,
        x_last_updated_by      => l_last_updated_by,
        x_creation_date        => l_creation_date,
        x_created_by           => l_created_by,
        x_last_update_login    => l_last_update_login,
        x_program_type         => l_program_type,
        x_payment_group_code   => p_PmtPlan_rec.payment_group_code
	 );

       x_loading_status := 'CN_INSERTED';
    ELSE
       -- The pmt plan already exists - Raise an Error Meassge
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
	  FND_MESSAGE.SET_NAME ('CN' , 'CN_PMT_PLAN_EXISTS');
	  FND_MSG_PUB.Add;
       END IF;
       x_loading_status := 'CN_PMT_PLAN_EXISTS';
       RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- End of API body.

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
      ROLLBACK TO Create_PmtPlan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_PmtPlan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	);
   WHEN OTHERS THEN
      ROLLBACK TO Create_PmtPlan;
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
END Create_PmtPlan;

--
--  Procedure   : 	Update PmtPlan
--  Description : 	This is a public procedure to update pmt plans
--  Calls       : 	validate_pmt_plan
--			CN_Pmt_Plans_Pkg.Begin_Record
--

PROCEDURE  Update_PmtPlan (
    p_api_version		IN 	NUMBER,
    p_init_msg_list		IN	VARCHAR2,
    p_commit	    		IN  	VARCHAR2,
    p_validation_level		IN  	NUMBER,
    x_return_status       	OUT 	NOCOPY VARCHAR2,
    x_msg_count	        	OUT 	NOCOPY NUMBER,
    x_msg_data			OUT 	NOCOPY VARCHAR2,
    p_old_PmtPlan_rec          IN      PmtPlan_rec_type,
    p_PmtPlan_rec              IN  OUT NOCOPY  PmtPlan_rec_type,
    x_status            	OUT 	NOCOPY VARCHAR2,
    x_loading_status    	OUT 	NOCOPY VARCHAR2
   )  IS

    l_api_name		CONSTANT VARCHAR2(30)  := 'Update_PmtPlan';
    l_api_version           	CONSTANT NUMBER        := 1.0;
    l_PmtPlans_rec            PmtPlan_rec_type;
    l_org_id          NUMBER;
    l_pmt_plan_id		NUMBER;
    l_credit_type_id		NUMBER;
    l_pay_interval_type_id    NUMBER;
    l_rec_interval_type_id   NUMBER;
    l_pay_Against_commission VArchar2(02);

    l_recoverable_interval_type_id NUMBER;
    l_count                   NUMBER := 0;
    l_start_date              DATE;
    l_end_date                DATE;
    l_null_end_date_srps      NUMBER := 0;

    L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PVT';
    L_LAST_UPDATE_DATE          DATE    := sysdate;
    L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
    L_CREATION_DATE             DATE    := sysdate;
    L_CREATED_BY                NUMBER  := fnd_global.user_id;
    L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
    L_ROWID                     VARCHAR2(30);
    L_PROGRAM_TYPE              VARCHAR2(30);

    CURSOR get_credit_type_id IS
    SELECT credit_type_id
    FROM cn_credit_types
    WHERE name = p_PmtPlan_rec.credit_type_name
        and org_id = p_PmtPlan_rec.org_id;


   CURSOR get_pay_interval_type_id IS
      SELECT interval_type_id
	FROM cn_interval_types
	WHERE name = p_pmtplan_rec.pay_interval_type_name
         AND org_id = p_PmtPlan_rec.org_id;

   CURSOR get_pmt_plan (p_pmt_plan_id NUMBER) IS
      SELECT *
	FROM cn_pmt_plans
	WHERE pmt_plan_id = p_pmt_plan_id
            AND org_id = p_PmtPlan_rec.org_id;

   l_pp_rec get_pmt_plan%ROWTYPE;

   l_old_PmtPlan_rec     PmtPlan_rec_type;
   l_pp_oldrec get_pmt_plan%ROWTYPE;

 CURSOR get_credit_type_curs ( l_credit_type_id  VArchar2) IS
      SELECT name
	FROM cn_credit_types
	WHERE credit_type_id = l_credit_type_id
            AND org_id = p_PmtPlan_rec.org_id;

   CURSOR get_interval_type_curs ( l_interval_type_id Varchar2 )  IS
      SELECT name
	FROM cn_interval_types
	WHERE interval_type_id  = l_interval_type_id
            AND org_id = p_PmtPlan_rec.org_id;

    CURSOR l_ovn_csr IS
    SELECT nvl(object_version_number,1)
      FROM cn_pmt_plans
      WHERE pmt_plan_id = p_old_PmtPlan_rec.pmt_plan_id
            AND org_id = p_old_PmtPlan_rec.org_id;

     l_object_version_number  NUMBER;

     CURSOR get_rec_interval_type_curs ( l_rec_interval_type_id  NUMBER )  IS
      SELECT name
	FROM cn_interval_types
	WHERE interval_type_id  = l_rec_interval_type_id
            AND org_id = p_PmtPlan_rec.org_id;


     CURSOR get_rec_interval_type_id ( l_rec_interval_type  VARCHAR2 )  IS
      SELECT interval_type_id
	FROM cn_interval_types
	WHERE name  = l_rec_interval_type
            AND org_id = p_PmtPlan_rec.org_id;

BEGIN

   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Update_PmtPlan;
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
   -- API body
   --

   --
   --Initialize g_mode
   --
   g_mode := 'UPDATE';

   --
   -- get the old Record
   --

   open get_pmt_plan( p_old_PmtPlan_rec.pmt_plan_id);
   fetch get_pmt_plan into l_pp_oldrec;
   close get_pmt_plan;

   --
   -- get credit types
   --
   open get_credit_type_curs( l_pp_oldrec.credit_type_id );
   fetch get_credit_type_curs into l_old_PmtPlan_rec.credit_type_name;
   close get_credit_type_curs;

   --
   -- get interval types
   --
   open get_interval_type_curs( l_pp_oldrec.pay_interval_type_id );
   fetch get_interval_type_curs into l_old_PmtPlan_rec.pay_interval_type_name;
   close get_interval_type_curs;

   --
   -- get recoverable interval types
   --

    open get_rec_interval_type_curs( l_pp_oldrec.recoverable_interval_type_id );
    fetch get_rec_interval_type_curs into l_old_PmtPlan_rec.recoverable_interval_type;
    close get_rec_interval_type_curs;

     l_old_PmtPlan_rec.org_id      := l_pp_oldrec.org_id;
     l_old_PmtPlan_rec.pmt_plan_id      := l_pp_oldrec.pmt_plan_id;
     l_old_PmtPlan_rec.name        	:= l_pp_oldrec.name;
     l_old_PmtPlan_rec.minimum_amount	:= l_pp_oldrec.minimum_amount;
     l_old_PmtPlan_rec.maximum_amount	:= l_pp_oldrec.maximum_amount;
     l_old_PmtPlan_rec.min_rec_flag	:= l_pp_oldrec.min_rec_flag;
     l_old_PmtPlan_rec.max_rec_flag     := l_pp_oldrec.max_rec_flag;
     l_old_PmtPlan_rec.start_date	:= l_pp_oldrec.start_date;
     l_old_PmtPlan_rec.end_date         := l_pp_oldrec.end_date;
     l_old_PmtPlan_rec.object_version_number := l_pp_oldrec.object_version_number;

   -- Validation
   --
   --
   --Validate if start date is less than end date
   --
   IF p_pmtplan_rec.start_date <> fnd_api.g_miss_date
     AND p_pmtplan_rec.start_date IS NULL
     THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	THEN
	 fnd_message.set_name('CN', 'CN_PP_SDT_CANNOT_NULL');
	 fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_PP_SDT_CANNOT_NULL';
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_pmtplan_rec.start_date IS NOT NULL --start date has been updated
     THEN
      IF p_PmtPlan_rec.end_date IS NOT NULL
	AND (p_PmtPlan_rec.start_date > p_PmtPlan_rec.end_date)
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
      IF l_old_PmtPlan_rec.end_date IS NOT NULL
	AND (p_PmtPlan_rec.start_date > l_old_pmtPlan_Rec.end_date)
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

   get_PmtPlan_id(
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PmtPlan_rec        => l_old_pmtPlan_Rec,
      p_loading_status     => x_loading_status,
      x_pmt_plan_id        => l_pmt_plan_id,
      x_loading_status     => x_loading_status,
      x_status             => x_status
      );

-- check if the object version number is the same
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;

   IF (l_object_version_number <>
     p_pmtplan_rec.object_version_number) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_OBJECT_VERSION';
      RAISE FND_API.G_EXC_ERROR;

    end if;

   IF ( x_return_status  <> FND_API.G_RET_STS_SUCCESS )
   THEN

      RAISE fnd_api.g_exc_error;

   ELSIF x_status <>  'PMT PLAN EXISTS'
   THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PMT_PLAN');
         fnd_message.set_token('PMT_PLAN_NAME', l_old_pmtPlan_Rec.name);
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_INVALID_PMT_PLAN';
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

   SELECT COUNT(1)
     INTO l_count
     FROM cn_srp_pmt_plans
     WHERE pmt_plan_id = l_pmt_plan_id;

   -- If pmt plan has been assigned, select current definition of pmt plan
   -- Ensure min_rec_flag and max_rec_flag are not updated
   -- Start date and end date can only be updated in such a way that they do not
   -- affect the assignment dates

   IF l_count <> 0
     THEN
      --select current definition of pmt plan and compare with new definition
      OPEN get_pmt_plan(l_pmt_plan_id);
      FETCH get_pmt_plan INTO l_pp_rec;
      CLOSE get_pmt_plan;

      IF ( nvl(p_pmtplan_rec.min_rec_flag,'N')  IS NOT NULL
	   AND nvl(p_pmtplan_rec.min_rec_flag,'N') <> l_pp_rec.min_rec_flag)
	OR (  nvl(p_pmtplan_rec.max_rec_flag,'N')  IS NOT NULL
	      AND nvl(p_pmtplan_rec.max_rec_flag,'N') <> l_pp_rec.max_rec_flag)
	  THEN

	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_REC_FLG_UPD_NA');
	    FND_MSG_PUB.Add;
	 END IF;

	 x_loading_status := 'CN_REC_FLG_UPD_NA';
	 RAISE FND_API.G_EXC_ERROR ;
     ELSE IF(p_pmtplan_rec.payment_group_code <> l_pp_rec.payment_group_code)
     THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_PYMT_GRP_CODE_UPD_NA');
	    FND_MSG_PUB.Add;
	 END IF;

	 x_loading_status := 'CN_PYMT_GRP_CODE_UPD_NA';
	 RAISE FND_API.G_EXC_ERROR ;
     END IF;
   END IF;

      SELECT MIN(start_date)
	INTO l_start_date
	FROM cn_srp_pmt_plans
	WHERE pmt_plan_id = l_pmt_plan_id;

    SELECT MAX(end_date)
	INTO l_end_date
	FROM cn_srp_pmt_plans
	WHERE pmt_plan_id = l_pmt_plan_id
	AND end_date IS NOT NULL;

	SELECT count(1)
	INTO l_null_end_date_srps
	FROM cn_srp_pmt_plans
	WHERE pmt_plan_id = l_pmt_plan_id
	AND end_date IS NULL;

      IF l_start_date < p_pmtplan_rec.start_date
	OR l_end_date > p_pmtplan_rec.end_date
	OR l_null_end_date_srps = 1
	THEN

	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_PMT_PLAN_CHANGE_NA');
	    fnd_msg_pub.add;
	 END IF;

	 x_status := 'CN_PMT_PLAN_CHANGE_NA';
	 x_loading_status := 'CN_PMT_PLAN_CHANGE_NA';
	 RAISE FND_API.G_EXC_ERROR;

      END IF;

   END IF;

   Validate_PmtPlan(
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PmtPlan_rec        => p_PmtPlan_rec,
      p_loading_status     => x_loading_status,
      x_loading_status     => x_loading_status,
      x_status             => x_status
     );

   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF ( x_return_status = FND_API.G_RET_STS_SUCCESS )
--      AND ( x_status = 'PMT PLAN EXISTS' )
      THEN

       -- At this point, credit type is already validated in Validate_PmtPlan
       -- Get the credit type id for the given credit type name
       OPEN get_credit_type_id;
       FETCH get_credit_type_id INTO l_credit_type_id;

        -- At this point, Pay interval type name is already validate in Validate_pmtPlan method
        -- Get the Pay interval type id for the given pay interval type name
        IF p_pmtplan_rec.pay_interval_type_name IS NOT NULL
        THEN
         OPEN get_pay_interval_type_id;
         FETCH get_pay_interval_type_id INTO l_pay_interval_type_id;
        else
            l_pay_interval_type_id := -1000;
        END IF;

        l_pay_against_commission:= p_pmtplan_rec.pay_against_commission ;

         IF p_pmtplan_rec.recoverable_interval_type IS NOT NULL
    	THEN
    	 OPEN get_rec_interval_type_id (p_pmtplan_rec.recoverable_interval_type) ;
    	 FETCH get_rec_interval_type_id INTO l_recoverable_interval_type_id;
    	 CLOSE get_rec_interval_type_id;
         END IF;

        if l_recoverable_interval_type_id is NULL OR
           l_recoverable_interval_type_id = -1000 THEN

           if l_pay_interval_type_id = -1000 THEN

              l_recoverable_interval_type_id := -1000;
              l_pay_against_commission := p_pmtplan_rec.pay_against_commission;

           elsif l_pay_interval_type_id <> -1000 THEN

              --l_recoverable_interval_type_id :=  l_pay_interval_type_id;
              /**Added by sjustina**/
	      	      	 if( l_recoverable_interval_type_id = -1000 and
	      	                  l_recoverable_interval_type_id <> l_Pay_interval_type_id and
	      	                 l_pay_interval_type_id = -1002 ) THEN

	      	       	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	      	      	   THEN
	      	      	    fnd_message.set_name('CN', 'CN_INVALID_PAY_INT_AND_REC_INT');
	      	      	    fnd_msg_pub.add;
	      	      	 END IF;

	      	      	 x_status := 'CN_INV_PAY_INT_AND_REC';
	      	      	 x_loading_status := 'CN_INV_PAY_INT_AND_REC';
	      	      	 RAISE FND_API.G_EXC_ERROR;

	      	      	 elsif( l_recoverable_interval_type_id = -1000 and
	      	                  l_recoverable_interval_type_id <> l_Pay_interval_type_id and
	      	                 l_pay_interval_type_id = -1001 ) THEN

	      	       	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	      	      	   THEN
	      	      	    fnd_message.set_name('CN', 'CN_INVALID_PAY_INT_AND_REC_INT');
	      	      	    fnd_msg_pub.add;
	      	      	 END IF;

	      	      	 x_status := 'CN_INV_PAY_INT_AND_REC';
	      	      	 x_loading_status := 'CN_INV_PAY_INT_AND_REC';
	      	      	 RAISE FND_API.G_EXC_ERROR;
	      	      	 end if;
    	 /**End of code Added by sjustina**/
              l_pay_against_commission := p_pmtplan_rec.pay_against_commission;

           end if;

        else

            if ( l_recoverable_interval_type_id = -1001 and
                l_recoverable_interval_type_id <> l_Pay_interval_type_id and
               l_pay_interval_type_id = -1002 ) THEN

     	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
    	   THEN
    	    fnd_message.set_name('CN', 'CN_INVALID_PAY_INT_AND_REC_INT');
    	    fnd_msg_pub.add;
    	 END IF;

    	 x_status := 'CN_INV_PAY_INT_AND_REC';
    	 x_loading_status := 'CCN_INV_PAY_INT_AND_REC';
    	 RAISE FND_API.G_EXC_ERROR;

            end if;

       end if;

    IF l_recoverable_interval_type_id IN ( -1001, -1002 ) AND
      l_recoverable_interval_type_id <> l_Pay_interval_type_id and
     nvl(p_pmtplan_rec.pay_against_commission,'Y') <> 'N' THEN
	 --Error condition
	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
	   THEN
	    fnd_message.set_name('CN', 'CN_INVALID_REC_AND_PAC');
	    fnd_msg_pub.add;
	 END IF;

	 x_loading_status := 'CN_INVALID_REC_AND_PAC';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

        Cn_Pmt_Plans_Pkg.Begin_Record(
    	x_operation            => 'UPDATE',
    	x_rowid                => L_ROWID,
    	x_org_id               => p_PmtPlan_rec.org_id,
    	x_pmt_plan_id          => l_pmt_plan_id,
    	x_name                 => p_PmtPlan_rec.name,
    	x_minimum_amount       => p_PmtPlan_rec.minimum_amount,
    	x_maximum_amount       => p_PmtPlan_rec.maximum_amount,
    	x_min_rec_flag         => p_PmtPlan_rec.min_rec_flag,
    	x_max_rec_flag         => p_PmtPlan_rec.max_rec_flag,
    	x_max_recovery_amount  => p_PmtPlan_rec.max_recovery_amount,
    	x_credit_type_id       => l_credit_type_id,
            x_pay_interval_type_id => l_pay_interval_type_id,
            x_start_date           => p_PmtPlan_rec.start_date,
    	x_end_date             => p_PmtPlan_rec.end_date,
            x_object_version_number => p_PmtPlan_rec.object_version_number,
            x_recoverable_interval_type_id => l_recoverable_interval_type_id,
            x_pay_against_commission   => l_pay_against_commission,
    	x_attribute_category   => p_PmtPlan_rec.attribute_category,
    	x_attribute1           => p_PmtPlan_rec.attribute1,
    	x_attribute2           => p_PmtPlan_rec.attribute2,
    	x_attribute3           => p_PmtPlan_rec.attribute3,
            x_attribute4           => p_PmtPlan_rec.attribute4,
    	x_attribute5           => p_PmtPlan_rec.attribute5,
    	x_attribute6           => p_PmtPlan_rec.attribute6,
    	x_attribute7           => p_PmtPlan_rec.attribute7,
    	x_attribute8           => p_PmtPlan_rec.attribute8,
    	x_attribute9           => p_PmtPlan_rec.attribute9,
    	x_attribute10          => p_PmtPlan_rec.attribute10,
    	x_attribute11          => p_PmtPlan_rec.attribute10,
    	x_attribute12          => p_PmtPlan_rec.attribute12,
    	x_attribute13          => p_PmtPlan_rec.attribute13,
    	x_attribute14          => p_PmtPlan_rec.attribute14,
    	x_attribute15          => p_PmtPlan_rec.attribute15,
    	x_last_update_date     => l_last_update_date,
    	x_last_updated_by      => l_last_updated_by,
    	x_creation_date        => l_creation_date,
    	x_created_by           => l_created_by,
    	x_last_update_login    => l_last_update_login,
    	x_program_type         => l_program_type,
    	x_payment_group_code   => p_PmtPlan_rec.payment_group_code
    	);
        x_loading_status := 'CN_UPDATED';
   END IF;

   -- End of API body.
   -- Standard check of p_commit.
   --
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
      ROLLBACK TO Update_PmtPlan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_PmtPlan;

      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Update_PmtPlan;
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
END Update_PmtPlan;

--
--  Procedure Name : Delete Pmt Plans
--
--
PROCEDURE  Delete_PmtPlan
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        x_return_status       		OUT 	NOCOPY VARCHAR2,
    	x_msg_count	          	OUT 	NOCOPY NUMBER,
    	x_msg_data		  	OUT 	NOCOPY VARCHAR2,
    	p_PmtPlan_rec                  IN      PmtPlan_rec_type ,
        x_status			OUT 	NOCOPY VARCHAR2,
    	x_loading_status    		OUT 	NOCOPY VARCHAR2
   )  IS

      l_api_name		CONSTANT VARCHAR2(30)
	                        := 'Delete_PmtPlan';
      l_api_version           	CONSTANT NUMBER := 1.0;
      l_pmt_plan_id		NUMBER;
      l_count                   NUMBER;
      l_role_count              NUMBER;

      L_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_PmtPlan_PVT';
L_LAST_UPDATE_DATE          DATE    := sysdate;
L_LAST_UPDATED_BY           NUMBER  := fnd_global.user_id;
L_CREATION_DATE             DATE    := sysdate;
L_CREATED_BY                NUMBER  := fnd_global.user_id;
L_LAST_UPDATE_LOGIN         NUMBER  := fnd_global.login_id;
L_ROWID                     VARCHAR2(30);
L_PROGRAM_TYPE              VARCHAR2(30);
l_object_version_number     NUMBER;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT    Delete_PmtPlan ;
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
   x_loading_status := 'CN_DELETED';
   --
   -- API Body
   --

   --
   --Initialize g_mode
   --
   g_mode := 'DELETE';

   get_PmtPlan_id(
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_PmtPlan_rec        => p_PmtPlan_rec,
      p_loading_status     => x_loading_status,
      x_pmt_plan_id        => l_pmt_plan_id,
      x_loading_status     => x_loading_status,
      x_status             => x_status
      );

   IF ( x_return_status  <> FND_API.G_RET_STS_SUCCESS )
   THEN

      RAISE fnd_api.g_exc_error;

   ELSIF x_status <>  'PMT PLAN EXISTS'
   THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_PMT_PLAN');
         fnd_message.set_token('PMT_PLAN_NAME', p_PmtPlan_rec.name);
         FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_INVALID_PMT_PLAN';
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

    -- Payment plan cannot be deleted if there are salesreps assiged to the payment plan
   SELECT COUNT(1)
     INTO l_count
     FROM cn_srp_pmt_plans
     WHERE pmt_plan_id = l_pmt_plan_id;
   IF l_count <> 0
     THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_DELETE_NA');
             fnd_msg_pub.add;
          END IF;

          x_loading_status := 'CN_DELETE_NA';
          RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Payment plan cannot be deleted if there are roles assiged to the payment plan
   SELECT COUNT(1)
     INTO l_count
     FROM cn_role_pmt_plans
     WHERE pmt_plan_id = l_pmt_plan_id;
   IF l_count <> 0
     THEN
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
          THEN
             fnd_message.set_name('CN', 'CN_DELETE_NA');
             fnd_msg_pub.add;
          END IF;
          x_loading_status := 'CN_DELETE_NA';
          RAISE FND_API.G_EXC_ERROR;
   END IF;

      cn_pmt_plans_pkg.begin_record
	(
	 x_operation            => 'DELETE',
	 x_rowid                => L_ROWID,
	 x_org_id               => p_PmtPlan_rec.org_id,
	 x_pmt_plan_id          => l_pmt_plan_id,
	 x_name                 => null,
	 x_minimum_amount	   => null,
	 x_maximum_amount	   => null,
	 x_min_rec_flag	           => null,
	 x_max_rec_flag	           => null,
	 x_max_recovery_amount     => null,
	 x_credit_type_id	   => null,
	 x_pay_interval_type_id => null,
	 x_start_date           => null,
	 x_end_date             => null,
         x_object_version_number => l_object_version_number,
         x_recoverable_interval_type_id => null,
         x_pay_against_commission   => null,
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
     x_payment_group_code   => p_PmtPlan_rec.payment_group_code
	);
      x_loading_status := 'CN_DELETED';

   -- End of API body.
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
      ROLLBACK TO Delete_PmtPlan;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_PmtPlan;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_PmtPlan;
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

END Delete_PmtPlan;

END CN_PmtPlan_PVT ;

/
