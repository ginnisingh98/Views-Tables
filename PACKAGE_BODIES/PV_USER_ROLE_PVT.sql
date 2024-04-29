--------------------------------------------------------
--  DDL for Package Body PV_USER_ROLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_USER_ROLE_PVT" AS
/* $Header: pvxvrolb.pls 115.5 2002/12/17 04:30:04 svnathan ship $     */

g_pkg_name   CONSTANT VARCHAR2(30):='PV_USER_ROLE_PUB';
G_FILE_NAME  CONSTANT VARCHAR2(15) := 'pvxvrolb.pls';
G_PRIMARY_USER CONSTANT VARCHAR2(30) := 'PV_PARTNER_PRIMARY_USER_ENRL';
G_BUSINESS_USER CONSTANT VARCHAR2(30) := 'PV_PARTNER_BUSINESS_USER_ENRL';
G_APP_ID CONSTANT NUMBER := 691;




PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE ASSIGN_DEF_ROLES(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,P_USERNAME          in  VARCHAR2
  ,P_USERTYPE          in VARCHAR
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  )

IS

l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'ASSIGN_DEF_ROLES';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_enrltype_id  NUMBER;
l_usertype_key VARCHAR2(30);
l_principal_name VARCHAR2(255);
L_ENRLTYPE_KEY VARCHAR2(30);


cursor find_enrltype is select subscription_id from jtf_um_subscriptions_b
where subscription_key = L_ENRLTYPE_KEY
and (effective_end_date is null or effective_end_date > sysdate) ;


cursor primary_enroll_roles is select jusr.principal_name
from jtf_um_subscriptions_b jusb, jtf_um_subscription_role jusr
where subscription_key = L_ENRLTYPE_KEY
and  jusb.subscription_id = jusr.subscription_id
and jusr.effective_start_date <= sysdate
and nvl(jusr.effective_end_date, sysdate) >= sysdate
and jusb.effective_start_date <= sysdate
and nvl(jusb.effective_end_date, sysdate) >= sysdate
and  jusb.enabled_flag = 'Y';

cursor business_enroll_roles is select jusr.principal_name
from jtf_um_subscriptions_b jusb, jtf_um_subscription_role jusr
where subscription_key = L_ENRLTYPE_KEY
and  jusb.subscription_id = jusr.subscription_id
and jusr.effective_start_date <= sysdate
and nvl(jusr.effective_end_date, sysdate) >= sysdate
and jusb.effective_start_date <= sysdate
and nvl(jusb.effective_end_date, sysdate) >= sysdate;



BEGIN
 SAVEPOINT ASSIGN_DEF_ROLES;

   IF (PV_DEBUG_HIGH_ON) THEN



   PVX_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

	IF(UPPER(P_USERTYPE) = 'PRIMARY') THEN
	  L_ENRLTYPE_KEY:=G_PRIMARY_USER;
	ELSIF(UPPER(P_USERTYPE) = 'BUSINESS') THEN
	  L_ENRLTYPE_KEY:=G_BUSINESS_USER;
	ELSE
	  --raise exception by adding apppropriate FND message as not valid user type passed in.
          IF (PV_DEBUG_HIGH_ON) THEN
	    Pvx_Utility_Pvt.debug_message('ERROR: NOT valid USER TYPE IS passed IN.');
	  END IF;
	  --raise exception by adding apppropriate FND message as not valid user type passed in.
          FND_MESSAGE.set_name('PV', 'PV_USER_ROLE_NO_TYPE');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.g_exc_error;
	END IF;


   open find_enrltype;
   fetch find_enrltype into l_enrltype_id;
   /* Validation of enrollment Key. */
   IF find_enrltype%NOTFOUND THEN
        FND_MESSAGE.set_name('PV', 'PV_USER_ROLE_NO_ENRL');
        FND_MSG_PUB.add;
        x_return_status := FND_API.g_ret_sts_error;
        close find_enrltype;
        RAISE FND_API.g_exc_error;
   END IF;
   close find_enrltype;



-- Find out primary default roles
IF(UPPER(P_USERTYPE) = 'PRIMARY') THEN

  open primary_enroll_roles;

  loop
   fetch  primary_enroll_roles into l_principal_name;
   exit when primary_enroll_roles%NOTFOUND;


   -- Assign default roles
   if l_principal_name is not null then

   -- Make sure that user name is not null
          if P_USERNAME is not null then
	  JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => P_USERNAME,
		       ROLE_NAME       => l_principal_name,
		       OWNERTABLE_NAME => 'JTF_UM_SUBSCRIPTIONS_B',
		       OWNERTABLE_KEY  => l_enrltype_id
		    -- ,APP_ID          => 691
		     );
          end if;

    end if;
   end loop;
   close primary_enroll_roles;

ELSIF (UPPER(P_USERTYPE) = 'BUSINESS') THEN
-- Find out business default roles

  open business_enroll_roles;

  loop
   fetch  business_enroll_roles into l_principal_name;
   exit when business_enroll_roles%NOTFOUND;


   -- Assign default roles
   if l_principal_name is not null then

   -- Make sure that user name is not null
          if P_USERNAME is not null then
	  JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => P_USERNAME,
		       ROLE_NAME       => l_principal_name,
		       OWNERTABLE_NAME => 'JTF_UM_SUBSCRIPTIONS_B',
		       OWNERTABLE_KEY  => l_enrltype_id
		    -- ,APP_ID          => 691
		     );
          end if;

    end if;
   end loop;
   close business_enroll_roles;
END IF;


  -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data

  );

  IF (PV_DEBUG_HIGH_ON) THEN



  PVX_Utility_PVT.debug_message(l_full_name ||': end');

  END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO ASSIGN_DEF_ROLES;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO ASSIGN_DEF_ROLES;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO ASSIGN_DEF_ROLES;

      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


END ASSIGN_DEF_ROLES;








END PV_USER_ROLE_PVT;

/
