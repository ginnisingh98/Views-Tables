--------------------------------------------------------
--  DDL for Package Body CN_RATE_TIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RATE_TIERS_PKG" as
/* $Header: cnplirtb.pls 120.2 2005/07/12 16:28:26 appldev ship $ */
/* Name    : CN_RATE_TIERS_PKG
Purpose : Holds all server side packages used to proces a commission rate
          table tier.

Notes   : If we add, update or delete a tier we must 'INCOMPLETE' any comp
          plans that this schedule is assigned to (via a quota).
	  This is done in the calls to cn_comp_plans_pkg.set_status.
          Since there is no custom validation in this package the com plan
	  status update could've gone at the start of the begin procedure.
	  But for consistency with the other packages we call it in each
	  individual insert, update and delete procedure.*/

PROCEDURE INSERT_ROW
  (X_RATE_TIER_ID          IN OUT NOCOPY CN_RATE_TIERS.RATE_TIER_ID%TYPE,
   X_RATE_SCHEDULE_ID      IN     CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   X_COMMISSION_AMOUNT     IN     CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   X_RATE_SEQUENCE         IN     CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   --R12 MOAC Changes--Start
   X_ORG_ID                IN     CN_RATE_TIERS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   X_CREATION_DATE         IN     CN_RATE_TIERS.CREATION_DATE%TYPE    := SYSDATE,
   X_CREATED_BY            IN     CN_RATE_TIERS.CREATED_BY%TYPE       := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_DATE      IN     CN_RATE_TIERS.LAST_UPDATE_DATE%TYPE := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_RATE_TIERS.LAST_UPDATED_BY%TYPE  := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_RATE_TIERS.LAST_UPDATE_LOGIN%TYPE:= FND_GLOBAL.LOGIN_ID) IS

  CURSOR C IS SELECT RATE_TIER_ID FROM CN_RATE_TIERS
    WHERE RATE_TIER_ID = X_RATE_TIER_ID;

  CURSOR id IS SELECT CN_RATE_TIERS_S.NEXTVAL FROM DUAL;
BEGIN
   IF (x_rate_tier_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_rate_tier_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

   -- invalidate all comp plans using a rate table with this tier
   cn_comp_plans_pkg.set_status
     (x_comp_plan_id	 => NULL,
      x_quota_id	 => NULL,
      x_rate_schedule_id => X_rate_schedule_id,
      x_status_code 	 => 'INCOMPLETE',
      x_event		 => 'CHANGE_TIERS');

   insert into CN_RATE_TIERS
     (RATE_TIER_ID,
      RATE_SCHEDULE_ID,
      COMMISSION_AMOUNT,
      RATE_SEQUENCE,
      --R12 MOAC Changes--Start
      ORG_ID,
      --R12 MOAC Changes--End
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      OBJECT_VERSION_NUMBER)
     VALUES
     (X_RATE_TIER_ID,
      X_RATE_SCHEDULE_ID,
      X_COMMISSION_AMOUNT,
      X_RATE_SEQUENCE,
      --R12 MOAC Changes--Start
      X_ORG_ID,
      --R12 MOAC Changes--End
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATE_LOGIN,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      0);

   open c;
   fetch c into x_rate_tier_id;
   if (c%notfound) then
      close c;
      raise no_data_found;
   end if;
   close c;

   -- assign this rate tier to all salesreps with this rate schedule
   cn_srp_rate_assigns_pkg.insert_record
     (x_rate_schedule_id     => x_rate_schedule_id,
      x_rate_tier_id	     => x_rate_tier_id,
      x_rate_sequence        => x_rate_sequence,

      -- these are not used anymore
      x_srp_plan_assign_id   => null,
      x_srp_quota_assign_id  => null,
      x_srp_rate_assign_id   => null,
      x_quota_id	     => null,
      x_commission_Rate      => null,
      x_commission_amount    => null,
      x_disc_rate_table_flag => null);

  END INSERT_ROW;

  PROCEDURE LOCK_ROW
    (X_RATE_TIER_ID          IN     CN_RATE_TIERS.RATE_TIER_ID%TYPE,
     X_OBJECT_VERSION_NUMBER IN     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from CN_RATE_TIERS
    where RATE_TIER_ID = X_RATE_TIER_ID
      for update of RATE_TIER_ID nowait;

   tlinfo c%rowtype ;
BEGIN
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> x_object_version_number) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

END LOCK_ROW;

PROCEDURE UPDATE_ROW
  (X_RATE_TIER_ID          IN     CN_RATE_TIERS.RATE_TIER_ID%TYPE,
   X_RATE_SCHEDULE_ID      IN     CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   X_COMMISSION_AMOUNT     IN     CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   X_RATE_SEQUENCE         IN     CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   X_OBJECT_VERSION_NUMBER IN OUT NOCOPY    CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   X_LAST_UPDATE_DATE      IN     CN_RATE_TIERS.LAST_UPDATE_DATE%TYPE := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_RATE_TIERS.LAST_UPDATED_BY%TYPE  := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_RATE_TIERS.LAST_UPDATE_LOGIN%TYPE:= FND_GLOBAL.LOGIN_ID) IS

   l_commission_amount_old   number := 0;
BEGIN
   X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;
   -- invalidate all comp plans using a rate schedule with this tier
   cn_comp_plans_pkg.set_status
     (x_comp_plan_id	 => NULL,
      x_quota_id	 => NULL,
      x_rate_schedule_id => x_rate_schedule_id,
      x_status_code 	 => 'INCOMPLETE',
      x_event		 => 'CHANGE_TIERS');

   UPDATE cn_rate_tiers SET
     rate_schedule_id                  =     x_rate_schedule_id,
     commission_amount                 =     x_commission_amount,
     RATE_SEQUENCE                     =     X_RATE_SEQUENCE,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     OBJECT_VERSION_NUMBER             =     X_OBJECT_VERSION_NUMBER
   WHERE rate_tier_id = X_rate_tier_id;

   IF (SQL%NOTFOUND) then
     raise no_data_found;
   END IF;

   -- see if the commission amount changed
   select commission_amount into l_commission_amount_old
     from cn_rate_tiers
    where rate_tier_id = x_rate_tier_id;

   IF x_commission_amount <> l_commission_amount_old THEN

     -- Only the commission amount is denormalized no srp_tiers to maintain
     cn_srp_rate_assigns_pkg.synch_rate(
			  x_srp_plan_assign_id  => null
			 ,x_srp_quota_assign_id => null
  			 ,x_rate_schedule_id	=> x_rate_schedule_id
			 ,x_rate_tier_id	=> x_rate_tier_id
			 ,x_commission_rate	=> null
			 ,x_salesrep_id		=> null
			 ,x_start_period_id	=> null
			 ,x_commission_amount   => x_commission_amount);
   END IF;

  END UPDATE_ROW;


  -- Procedure Name
  --
  -- Purpose
  --
  -- Notes
  --   If the rate tier id is null this routine has been called on delete
  --   or a rate schedule. You cannot delete a schedule that is assigned to a
  --   quota so there's no need to try and update the status of the plans.
  --   If the tier_id is not null then we delete an individual tier.

  PROCEDURE Delete_Row
    (X_RATE_SCHEDULE_ID      IN     CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
     X_RATE_TIER_ID          IN     CN_RATE_TIERS.RATE_TIER_ID%TYPE) IS

  BEGIN

    IF X_Rate_Schedule_Id IS NOT NULL THEN

      IF X_Rate_Tier_Id IS NULL THEN

        DELETE FROM cn_rate_tiers
        WHERE rate_schedule_id = X_Rate_Schedule_Id;

      ELSE
        cn_comp_plans_pkg.set_status(
		  x_comp_plan_id	=> NULL
		 ,x_quota_id		=> NULL
		 ,x_rate_schedule_id	=> X_rate_schedule_id
	         ,x_status_code 	=> 'INCOMPLETE'
		 ,x_event		=> 'CHANGE_TIERS');

        DELETE FROM cn_rate_tiers
        WHERE  rate_tier_id = x_rate_tier_id;

        IF (SQL%NOTFOUND) then
           Raise NO_DATA_FOUND;
        END if;

        cn_srp_rate_assigns_pkg.delete_record(
			   x_srp_plan_assign_id	=> null
		          ,x_srp_rate_assign_id	=> null
		          ,x_quota_id		=> null
		          ,x_rate_schedule_id	=> x_rate_schedule_id
		          ,x_rate_tier_id	=> x_rate_tier_id);

      END IF;

    END IF;


  END Delete_Row;

END CN_RATE_TIERS_PKG;

/
