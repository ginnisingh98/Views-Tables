--------------------------------------------------------
--  DDL for Package Body PV_PG_NOTIF_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_NOTIF_UTILITY_PVT" as
/* $Header: pvxvpnub.pls 120.8 2006/09/22 17:53:27 speddu ship $ */

/*----------------------------------------------------------------------------
-- HISTORY
--    20-SEP-2002   rdsharma  Created
--    11-NOV-2002   SVEERAVE  Since the package pv_pgp_notif_pvt is changed to
--                            pv_ge_party_notif_pvt, all the references are changed
--                            accordingly. Since pv_ge_party_notifications table
--                            is change to have partner_id column instead of partner_party_id
--                            set_pgp_notif procedure is changed to capture partner_id
--                            all call-outs to set_pgp_notif is changed to pass partner_id
--                            intead of partner_party_id.
--    05-DEC-2002   SVEERAVE  Replaced new line character with <BR> for html formatting,
--                            Added get_Notification_Body procedure.
--    06-DEC-2002   SVEERAVE  Replaced partner portal URL with jtflogin.jsp for now.
--    11-DEC-2002   RDSHARMA  Modified the file to resolve the issue for
--			                      Termination notificationn by changing the HISTORY
--			                      CATEGORY to ENROLLMENT, during creation of History
--			                      log record.
--    12-MAR-2002   RDSHARMA  Modified the file to resolve the issue for
--			                      Bug # 2794559.
--   03/25/2003  sveerave  Modified from GetFullBody to GetBody as
--                         GetFullBody is failing to get full message body for bug#2862626
--   03/25/2003  sveerave  Modified from GetFullBody to GetBody as
--                         GetFullBody is failing to get full message body for bug#2862626
--   08/04/2003  sveerave  Fix for bug#3072153. Changed <BR> to wf_core.newline for alert_message
--                         notifications, and wherever there is URL, i.e. send_welcome_notif,
--                         send_mbrship_exp_notif- those notifications are implemented
--                         through pl/sql document for which added a new w/f enabled pl/sql doc
--                         proc, set_msg_doc, and the above two procedures are modified to
--                         to call this notification.
--   08/22/2003  sveerave  Fix for bug# 3107892. Changed message from ALERT_MESSAGE to
--                         DOC_MESSAGE in send_mbrship_exp_notif method.
--   09/15/2003  sveerave  Added partner_id for create_history_log API call out
--                         Changed ENRQ object to GENERAL, and entity_object_id to
--                         partner_id instead of enrl_request_id in this call out
--  10/08/2003   pukken    Modified Expire_Membership to procedure. called PV_Pg_Memberships_PVT.Terminate_membership
--                         with event code as expired.
--  10/18/2003   pukken	   Added new procedure Send_Workflow_Notification to send the notifications
--  30-MAR-2004  pukken    fix bug 3428446
--  15-APR-2005  pukken    to fix bug 4301902 to modify Expire_Memberships conc program so that even if
--                         expire or renewal fails for one membership, processing continues and error is logged.

--  31-OCT-2005  kvattiku  In send_welcome_notif, commented out and modified code so that the URL is
			   obtained from profile. (fix for bug 4666288)
 -----------------------------------------------------------------------------*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PG_NOTIF_UTILITY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpnub.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- Logging function - Local
--
-- p_which = 1. write to log
-- p_which = 2, write to output
--
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;

PROCEDURE Write_Log(p_which number, p_mssg  varchar2) IS
BEGIN
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
END Write_Log;




FUNCTION logging_enabled (p_log_level IN NUMBER)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
END;

PROCEDURE debug_message
(
   p_log_level IN NUMBER
   , p_module_name    IN VARCHAR2
   , p_text   IN VARCHAR2
)
IS
BEGIN
/*
  IF logging_enabled (p_log_level) THEN
    FND_LOG.STRING(p_log_level, p_module_name, p_text);
  END IF;
*/
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message( p_module_name ||' :  '|| p_text);
   END IF;

END debug_message;

PROCEDURE WRITE_TO_FND_LOG
(
   p_api_name      IN VARCHAR2
   , p_log_message   IN VARCHAR2
)
IS

BEGIN
  debug_message
   (
      p_log_level   => g_log_level
      , p_module_name => 'plsql.pv'||'.'|| g_pkg_name||'.'||p_api_name||'.'||p_log_message
      , p_text => p_log_message
   );
END WRITE_TO_FND_LOG;

--======================
/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_enrl_requests_details
--
-- PURPOSE
--    This procedure will return enrollment request details
--    from PV_PG_ENRL_REQUESTS table for a given enrl_requests_id
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE get_enrl_requests_details(
    p_enrl_request_id       IN NUMBER,
    x_req_submission_date   OUT NOCOPY DATE,
    x_partner_program_id    OUT NOCOPY NUMBER,
    x_partner_program       OUT NOCOPY VARCHAR2,
    x_enrollment_duration   OUT NOCOPY VARCHAR2,
    x_enrollment_type       OUT NOCOPY VARCHAR2,
    x_req_resource_id       OUT NOCOPY NUMBER,
    x_prtnr_vndr_relship_id OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS

/* Get the Enrollment Request details in cursor c_pg_enrl_requests */
CURSOR  c_pg_enrl_requests (cv_enrl_request_id  IN NUMBER) IS
SELECT  enrl_req.creation_date,
	prog.program_id,
        prog.program_name,
        prog.membership_valid_period ||'  ' || lookup1.meaning,
        lookup2.meaning,
        enrl_req.Requestor_resource_id,
        enrl_req.partner_id
 FROM   pv_pg_enrl_requests enrl_req,
      pv_partner_program_vl prog,
      fnd_lookups  lookup1,
      fnd_lookups  lookup2
 WHERE  enrl_req.enrl_request_id = cv_enrl_request_id
 AND    enrl_req.program_id = prog.program_id
 AND  lookup1.lookup_type='PV_PROGRAM_PMNT_UNIT'
 AND  lookup1.lookup_code = prog.membership_period_unit
 AND  lookup2.lookup_type='PV_ENROLLMENT_REQUEST_TYPE'
 AND  lookup2.lookup_code = enrl_req.enrollment_type_code;

BEGIN
    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_pg_enrl_requests( p_enrl_request_id );
    FETCH c_pg_enrl_requests
        INTO x_req_submission_date,
             x_partner_program_id,
             x_partner_program,
             x_enrollment_duration,
             x_enrollment_type,
             x_req_resource_id,
             x_prtnr_vndr_relship_id ;

    IF ( c_pg_enrl_requests%NOTFOUND) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_pg_enrl_requests;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_enrl_requests_details;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_requestor_details
--
-- PURPOSE
--    This procedure will return enrollment requestor details from
--    JTF_RS_RESOURCE_EXTNS table for a given resource_id
-- Called By
-- NOTES
-- End of Comments
=============================================================================*/
PROCEDURE get_requestor_details(
    p_req_resource_id  IN NUMBER,
    x_user_id               OUT NOCOPY NUMBER,
    x_source_name           OUT NOCOPY VARCHAR2,
    x_user_name             OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS
/* Get the Requestor  details in cursor c_reqestor_details */
CURSOR  c_requestor_details(cv_req_resource_id  IN NUMBER) IS
    SELECT  user_id, source_name, user_name
    FROM    JTF_RS_RESOURCE_EXTNS
    WHERE   resource_id = cv_req_resource_id;

BEGIN
    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_requestor_details( p_req_resource_id );
    FETCH c_requestor_details
        INTO x_user_id,
             x_source_name,
             x_user_name;

    IF ( c_requestor_details%NOTFOUND) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_requestor_details;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_requestor_details;


/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_partnor_vendor_details
--
-- PURPOSE
--    This procedure will return partner and vendor details
--    given the partner_id
--
-- Called By
-- NOTES
-- End of Comments
=============================================================================*/
PROCEDURE get_partner_vendor_details(
    p_partner_id       IN NUMBER,
    x_vendor_party_id       OUT NOCOPY NUMBER,
    x_vendor_name           OUT NOCOPY VARCHAR2,
    x_partner_party_id      OUT NOCOPY NUMBER,
    x_partner_comp_name     OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS

    /* Get the Partner and Vendor  details in cursor c_vendor_prtnr_details */
    CURSOR  c_vendor_prtnr_details(cv_partner_id  IN NUMBER) IS
        SELECT  vendor.party_id   VENDOR_ID,
                vendor.party_name VENDOR_NAME,
                partner.party_id  PARTNER_ID,
                partner.party_name PARTNER_NAME
        FROM    pv_partner_profiles prtnr_profile,
                hz_relationships rel_ship,
                hz_parties partner,
                hz_parties vendor
        WHERE   prtnr_profile.partner_id =cv_partner_id
        AND     prtnr_profile.partner_id = rel_ship.party_id
        AND     prtnr_profile.partner_party_id = rel_ship.object_id
        AND     rel_ship.party_id = cv_partner_id
        AND     rel_ship.subject_id = vendor.party_id
        AND     rel_ship.object_id = partner.PARTY_ID;


BEGIN

    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Get the Partner and Vendor  details in cursor c_vendor_prtnr_details */
    OPEN c_vendor_prtnr_details( p_partner_id );
    FETCH c_vendor_prtnr_details
        INTO x_vendor_party_id,
             x_vendor_name ,
             x_partner_party_id,
             x_partner_comp_name;

    IF ( c_vendor_prtnr_details%NOTFOUND) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_vendor_prtnr_details;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_partner_vendor_details;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_prtnr_vendor_details
--
-- PURPOSE
--    This procedure will return partner and vendor details
--    for a given relationship_id  between Partner and the Vendor
-- Called By
-- NOTES
-- End of Comments
=============================================================================*/
PROCEDURE get_prtnr_vendor_details(
    p_enrl_request_id       IN NUMBER,
    x_vendor_party_id       OUT NOCOPY NUMBER,
    x_vendor_name           OUT NOCOPY VARCHAR2,
    x_partner_party_id      OUT NOCOPY NUMBER,
    x_partner_comp_name     OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS

    /* Get the Partner and Vendor  details in cursor c_vendor_prtnr_details */
    CURSOR  c_vendor_prtnr_details(cv_enrl_request_id  IN NUMBER) IS
        SELECT  vendor.party_id   VENDOR_ID,
                vendor.party_name VENDOR_NAME,
                partner.party_id  PARTNER_ID,
                partner.party_name PARTNER_NAME
        FROM    pv_pg_enrl_requests  enrl_req,
                pv_partner_profiles prtnr_profile,
                hz_relationships rel_ship,
                hz_parties partner,
                hz_parties vendor
        WHERE   enrl_req.enrl_request_id = cv_enrl_request_id
        AND     enrl_req.partner_id= prtnr_profile.partner_id
        AND     prtnr_profile.partner_id = rel_ship.party_id
        AND     prtnr_profile.partner_party_id = rel_ship.object_id
        AND     enrl_req.partner_id = rel_ship.party_id
        AND     rel_ship.subject_id = vendor.party_id
        AND     rel_ship.object_id = partner.PARTY_ID;


BEGIN

    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Get the Partner and Vendor  details in cursor c_vendor_prtnr_details */
    OPEN c_vendor_prtnr_details( p_enrl_request_id );
    FETCH c_vendor_prtnr_details
        INTO x_vendor_party_id,
             x_vendor_name ,
             x_partner_party_id,
             x_partner_comp_name;

    IF ( c_vendor_prtnr_details%NOTFOUND) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_vendor_prtnr_details;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_prtnr_vendor_details;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_membership_details
--
-- PURPOSE
--    This procedure will return all the membership details for a
--    partner user enrolled for a program for a given membership_id
-- Called By
-- NOTES
-- End of Comments
=============================================================================*/
PROCEDURE get_membership_details(
    p_membership_id         IN NUMBER,
    x_req_submission_date   OUT NOCOPY DATE,
    x_partner_program_id    OUT NOCOPY NUMBER,
    x_partner_program       OUT NOCOPY VARCHAR2,
    x_enrl_request_id       OUT NOCOPY NUMBER,
    x_enrollment_start_date OUT NOCOPY DATE,
    x_enrollment_end_date   OUT NOCOPY DATE,
    x_req_resource_id       OUT NOCOPY NUMBER,
    x_prtnr_vndr_relship_id OUT NOCOPY NUMBER,
    x_enrollment_type       OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS

/* Cursor : Get the Membership details in cursor c_pg_membership_details */
CURSOR  c_pg_membership_details (cv_membership_id   IN NUMBER) IS
    SELECT  enrl_req.creation_date ,
            program.program_id ,
            program.program_name ,
            membership.enrl_request_id ,
            membership.start_date ,
            membership.original_end_date ,
	    enrl_req.requestor_resource_id,
            enrl_req.partner_id,
          lookup.meaning
    FROM  pv_pg_memberships membership,
            pv_pg_enrl_requests enrl_req,
          pv_partner_program_vl program,
          fnd_lookups  lookup
    WHERE   membership.membership_id = cv_membership_id
    AND   enrl_req.enrl_request_id =  membership.enrl_request_id
    AND     membership.program_id = program.program_id
    AND lookup.lookup_type='PV_ENROLLMENT_REQUEST_TYPE'
    AND lookup.lookup_code = enrl_req.enrollment_type_code;

BEGIN
    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Get the Enrollment details in cursor c_pg_enrollment_details */
    OPEN c_pg_membership_details( p_membership_id  );
    FETCH c_pg_membership_details INTO
            x_req_submission_date ,
            x_partner_program_id  ,
            x_partner_program     ,
            x_enrl_request_id     ,
            x_enrollment_start_date ,
            x_enrollment_end_date   ,
	    x_req_resource_id ,
	    x_prtnr_vndr_relship_id ,
            x_enrollment_type ;

    IF ( c_pg_membership_details%NOTFOUND) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_pg_membership_details;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_membership_details;

/*============================================================================*/
-- Start of Comments
-- NAME
--   Get_Users_List
--
-- PURPOSE
--   This Procedure will be return all the users for a given partner Vendor
--   relationship id and the requestor resourse id.
--
-- Called By
-- NOTES
-- End of Comments

/*============================================================================*/

PROCEDURE get_users_list
   (  p_partner_id          IN     NUMBER,
      x_user_notify_rec_tbl OUT NOCOPY    user_notify_rec_tbl_type ,
      x_user_count          OUT NOCOPY    NUMBER,
      x_return_status       OUT NOCOPY    VARCHAR2
)
IS

    l_user_type     VARCHAR2(255);
    l_user_id       NUMBER;
    l_user_name     VARCHAR2(100);
    l_user_resource_id   NUMBER;
    l_user_cnt      NUMBER;

    /* Declare the cursor to get the USERS List for the given partner_id
       and the user type (of type PV_PARTNER_PRIMARY_USER or
       PV_PARTNER_BUSINESS_USER ) */
    CURSOR c_user_list (cv_partner_id   IN  NUMBER) IS
	SELECT 	user_id,
		user_name,
		resource_id
	FROM 	pv_partner_primary_users_v
	WHERE   partner_id = cv_partner_id ;

BEGIN
    /* Initialize API return status to success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Open the c_user_list cursor to get all the Users of that type */
   OPEN c_user_list (p_partner_id) ;
   l_user_cnt := 1;
   LOOP
      FETCH c_user_list INTO l_user_id, l_user_name, l_user_resource_id;
      EXIT WHEN c_user_list%notfound;
         x_user_notify_rec_tbl(l_user_cnt).user_id := l_user_id;
         x_user_notify_rec_tbl(l_user_cnt).user_name := l_user_name;
         x_user_notify_rec_tbl(l_user_cnt).user_resource_id := l_user_resource_id;
         l_user_cnt := l_user_cnt + 1;
   END LOOP;
   x_user_count := l_user_cnt - 1;

   IF ( x_user_count = 0 ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   CLOSE c_user_list ;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_users_list;

/*============================================================================
-- Start of Comments
-- NAME
--   Get_Resource_Role
--
-- PURPOSE
--   This Procedure will be return the workflow user role for
--   the resourceid sent
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

PROCEDURE get_resource_role(
        p_resource_id        IN     NUMBER,
        x_role_name          OUT NOCOPY    VARCHAR2,
        x_role_display_name  OUT NOCOPY    VARCHAR2 ,
        x_return_status      OUT NOCOPY    VARCHAR2
)
IS
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_error_msg              VARCHAR2(4000);

  CURSOR c_resource IS
    SELECT  source_id, user_id, category
    FROM    JTF_RS_RESOURCE_EXTNS_VL
    WHERE   resource_id > 0
      AND (    category = 'EMPLOYEE'
            OR category = 'PARTNER'
            OR category = 'PARTY')
      AND resource_id = p_resource_id ;

   l_person_id number;
   l_user_id number;
   l_category  varchar2(30);

BEGIN
    /* Initialize API return status to success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_resource ;
   FETCH c_resource INTO l_person_id , l_user_id, l_category;
   IF c_resource%NOTFOUND THEN
	CLOSE c_resource ;
	x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   END IF;

   CLOSE c_resource ;

   /* Pass the Employee ID to get the Role */
   IF l_category = 'PARTY' THEN
      WF_DIRECTORY.getrolename
      (  p_orig_system     => 'FND_USR',
         p_orig_system_id    => l_user_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
      );
      IF x_role_name is null  then
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;
      END IF;
   ELSIF l_category = 'EMPLOYEE' THEN
      WF_DIRECTORY.getrolename
      (  p_orig_system     => 'PER',
         p_orig_system_id    => l_person_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
      );
      IF x_role_name is null  then
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('AMS_UTLITY_PVT', 'Get_Resource_Role');
      END IF;
      RAISE;

END Get_Resource_Role;

/*============================================================================
-- Start of Comments
-- NAME
--   Get_Notification_Name
--
-- PURPOSE
--   This function returns the Notification name by selecting the
--   meaning  for the send notification code for 'PV_NOTIFICATION_TYPE'.
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

FUNCTION get_Notification_Name(p_notif_code IN  VARCHAR2)
RETURN VARCHAR2
IS
    CURSOR c_notification IS
    SELECT  meaning
    FROM    FND_LOOKUPS
    WHERE   lookup_type= 'PV_NOTIFICATION_TYPE'
    AND     lookup_code= p_notif_code;

    l_notification_name     VARCHAR2(80):= NULL;

BEGIN
    OPEN c_notification ;
    FETCH c_notification INTO l_notification_name;

    CLOSE c_notification ;
    return l_notification_name;
END get_Notification_Name;

/*============================================================================
-- Start of Comments
-- NAME
--   Get_Program_Url
--
-- PURPOSE
--   This function returns the URL to display the benefits of the program
--   to the primary user, who's successfully enrolled for that program.
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

FUNCTION get_Program_Url(p_program_id IN  NUMBER)
RETURN VARCHAR2
IS
    /* Get the web server jsp agent.  */
    CURSOR c_jsp_agent IS
    	SELECT fnd_web_config.jsp_agent FROM dual;

    /* Get the function url. */
    CURSOR c_function_url IS
    	SELECT web_html_call
	FROM fnd_form_functions
	WHERE function_name = 'PV_ENRL_NOW';

    /* Get the cItemVersionId. */
    CURSOR c_Item_Version_Id(cv_program_id	NUMBER) IS
	SELECT nvl(citem_version_id ,0)
	FROM pv_partner_program_b
	WHERE program_id = cv_program_id;

    l_jsp_agent		VARCHAR2(200) := NULL;
    l_function_url	VARCHAR2(1000) := NULL;
    l_item_ver_id	NUMBER;
    l_program_url       VARCHAR2(4000) := NULL;
    l_param_list        VARCHAR2(1000) := NULL;
    l_char        	VARCHAR2(1) := '&';

BEGIN

    /* Get the web server jsp agent. */
    OPEN c_jsp_agent ;
    FETCH c_jsp_agent INTO l_jsp_agent ;
    CLOSE c_jsp_agent ;

    /* Get the function url. */
    OPEN c_function_url;
    FETCH c_function_url INTO l_function_url;
    CLOSE c_function_url;

    /* Get the cItemVersionId. */
    OPEN c_Item_Version_Id(p_program_id);
    FETCH c_Item_Version_Id INTO l_item_ver_id;
    CLOSE c_Item_Version_Id ;

   /* Concatenate the following paramters -
		i)   PAGE.OBJ.ID_NAME0=programId
		ii)  PAGE.OBJ.ID0=program_id
		iii) PAGE.OBJ.ID_NAME1=cItemVersionId
		iv)  PAGE.OBJ.ID1=citem_ver_id
		v)   PAGE.OBJ.objType=MEMB'
    */
   l_param_list := '?PAGE.OBJ.ID_NAME0=programId' || l_char ;
   l_param_list := l_param_list || 'PAGE.OBJ.ID0='||p_program_id|| l_char ;
   l_param_list := l_param_list || 'PAGE.OBJ.ID_NAME1=cItemVersionId' || l_char ;
   l_param_list := l_param_list || 'PAGE.OBJ.ID1='||l_item_ver_id|| l_char ;
   l_param_list := l_param_list || 'PAGE.OBJ.objType=MEMB';

   /* Form the final program URL */
   l_program_url := l_jsp_agent || l_function_url || l_param_list ;

   return l_program_url;
END get_Program_Url;

/*============================================================================
-- Start of Comments
-- NAME
--   Check_Notif_Rule_Active
--
-- PURPOSE
--   This Procedure will return the ACTIVE_FLAG value for the Notification
--   rule set for the given Program Id and Notification Type.
--
-- Called By
-- NOTES
-- End of Comments

=============================================================================*/

FUNCTION check_Notif_Rule_Active( p_program_id    IN    NUMBER ,
                                  p_notif_type    IN    VARCHAR2 )
RETURN VARCHAR2
IS
	CURSOR c_notif_rule_active IS
	SELECT active_flag
	FROM   pv_ge_notif_rules_vl
	WHERE notif_type_code = p_notif_type
	AND arc_notif_for_entity_code = 'PRGM'
	AND notif_for_entity_id = p_program_id ;

	l_active_flag VARCHAR2(1) := 'Y' ;

BEGIN
    OPEN c_notif_rule_active ;
       FETCH c_notif_rule_active INTO l_active_flag;
    CLOSE c_notif_rule_active ;

    IF l_active_flag IS NULL THEN
       l_active_flag:= 'Y';
    END IF;
    return l_active_flag;
END  check_Notif_Rule_Active;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    Validate_Enrl_Requests
--
-- PURPOSE
--    This procedure validates the enrollment request id or enrollment id.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE Validate_Enrl_Requests (
    p_item_id        IN  NUMBER ,
    p_item_name         IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2
)
IS
error_flag  BOOLEAN:=FALSE;
BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;
      IF (  p_item_id = FND_API.G_MISS_NUM OR
            p_item_id IS NULL ) THEN

            error_flag := TRUE;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
            FND_MESSAGE.SET_TOKEN('ITEM_NAME', p_item_name);
            FND_MSG_PUB.Add;
      END IF;



 END Validate_Enrl_Requests;

 /*============================================================================*/
-- Start of Comments
-- NAME
--   Set_Pgp_Notif
--
-- PURPOSE
--   This procedure set the proper values in pgp_notif_rec, before calling the
--  Create_Ge_Party_Notif procedure.
--
-- Called By
--
-- NOTES
--  SVEERAVE    11/11/02    Changed p_partner_party_id to p_partner_id
-- End of Comments

/*============================================================================*/
PROCEDURE Set_Pgp_Notif(
    p_notif_id         IN   NUMBER,
    p_object_version   IN   NUMBER,
    p_partner_id IN   NUMBER,
    p_user_id          IN   NUMBER,
    p_arc_notif_for_entity_code IN VARCHAR2,
    p_notif_for_entity_id  IN   NUMBER,
    p_notif_type_code   IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2 ,
    x_pgp_notif_rec     OUT NOCOPY PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type  )
IS
BEGIN
     --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize OUT parameter with the supplied parameter values
    x_pgp_notif_rec.notification_id := p_notif_id;
    x_pgp_notif_rec.object_version_number := p_object_version;
    x_pgp_notif_rec.partner_id := p_partner_id ;
    x_pgp_notif_rec.recipient_user_id := p_user_id;
    x_pgp_notif_rec.arc_notif_for_entity_code := p_arc_notif_for_entity_code;
    x_pgp_notif_rec.notif_for_entity_id := p_notif_for_entity_id;
    x_pgp_notif_rec.notif_type_code := p_notif_type_code;

    -- Debug Message
    IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Set_Pgp_Notif');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
END Set_Pgp_Notif;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    get_enrl_requests_details
--
-- PURPOSE
--    This procedure will return enrollment request  and membership details
--    from PV_PG_ENRL_REQUESTS table and PV_PG_MEMBERSHIPS_TABLE for a given enrl_requests_id
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE get_enrl_memb_details(
    p_enrl_request_id       IN NUMBER,
    x_req_submission_date   OUT NOCOPY DATE,
    x_partner_program_id    OUT NOCOPY NUMBER,
    x_partner_program       OUT NOCOPY VARCHAR2,
    x_enrollment_duration   OUT NOCOPY VARCHAR2,
    x_enrollment_type       OUT NOCOPY VARCHAR2,
    x_req_resource_id       OUT NOCOPY NUMBER,
    x_prtnr_vndr_relship_id OUT NOCOPY NUMBER,
    x_start_date            OUT NOCOPY DATE,
    x_end_date              OUT NOCOPY DATE,
    x_membership_id         OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS
   CURSOR  c_pg_enrl_requests (cv_enrl_request_id  IN NUMBER) IS
   SELECT  enrl_req.creation_date
           , prog.program_id
           , prog.program_name
           , prog.membership_valid_period ||'  ' || lookup1.meaning
           , lookup2.meaning
           , enrl_req.Requestor_resource_id
           , enrl_req.partner_id
   	   , memb.start_date
   	   , memb.ORIGINAL_END_DATE
   	   , memb.membership_id
   FROM    pv_pg_enrl_requests enrl_req
           , pv_partner_program_vl prog
           , fnd_lookups  lookup1
           , fnd_lookups  lookup2
   	   , pv_pg_memberships memb
   WHERE   enrl_req.enrl_request_id = cv_enrl_request_id
   AND     enrl_req.program_id = prog.program_id
   AND     lookup1.lookup_type='PV_PROGRAM_PMNT_UNIT'
   AND     lookup1.lookup_code = prog.membership_period_unit
   AND     lookup2.lookup_type='PV_ENROLLMENT_REQUEST_TYPE'
   AND     lookup2.lookup_code = enrl_req.enrollment_type_code
   AND     enrl_req.enrl_request_id=memb.enrl_request_id(+);


BEGIN
    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_pg_enrl_requests( p_enrl_request_id );
    FETCH c_pg_enrl_requests
        INTO x_req_submission_date,
             x_partner_program_id,
             x_partner_program,
             x_enrollment_duration,
             x_enrollment_type,
             x_req_resource_id,
             x_prtnr_vndr_relship_id,
             x_start_date,
             x_end_date,
             x_membership_id;

    IF ( c_pg_enrl_requests%NOTFOUND) THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    CLOSE c_pg_enrl_requests;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_enrl_memb_details;

/*============================================================================


/*============================================================================
-- Start of comments
--  API name  : send_thnkyou_notif
--  Type    : Private.
--  Function  : This API compiles and sends the Thank you notification to all
--                partner users, once the partner user successfully enrolled to
--                a partner program.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_enrl_request_id      IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--        .
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_thnkyou_notif (
  p_api_version       IN  NUMBER ,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
  x_return_status     OUT NOCOPY VARCHAR2 ,
  x_msg_count         OUT NOCOPY NUMBER ,
  x_msg_data          OUT NOCOPY VARCHAR2 ,
  p_enrl_request_id   IN  NUMBER
 )
IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_thnkyou_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status    VARCHAR2(1);

 l_enrl_request_id      NUMBER;
 l_req_resource_id      NUMBER ;
 l_req_submission_date  VARCHAR2(240);
 l_partner_program_id   NUMBER;
 l_partner_program      VARCHAR2(240);
 l_enrollment_duration  VARCHAR2(240);
 l_enrollment_type      VARCHAR2(240);
 l_prtnr_vndr_relship_id NUMBER;
 l_user_id              NUMBER;
 l_notif_user_id        NUMBER;
 l_source_name          VARCHAR2(360);
 l_requestor_name       VARCHAR2(360);
 l_user_name            VARCHAR2(100);
 l_vendor_party_id      NUMBER;
 l_vendor_name          VARCHAR2(360);
 l_partner_party_id     NUMBER;
 l_partner_comp_name    VARCHAR2(360);
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'ENRQ';
 l_notif_type_code      VARCHAR2(30) := 'PG_THANKYOU';

 /* Declaration of  local variables  for all the  message attributes */
 l_thankyou_subject     VARCHAR2(240);
 l_enrl_alert           VARCHAR2(240);
 l_thankyou_greetings VARCHAR2(240);
 l_enrl_processing      VARCHAR2(240);
 l_alert_thanks         VARCHAR2(240);
 l_alert_closing        VARCHAR2(240);
 l_enrollment_team    VARCHAR2(240);


 l_item_type           VARCHAR2(8) := 'PVXNUTIL';
 l_message_name        VARCHAR2(20):= 'ALERT_MESSGAE';
 l_message_hdr         VARCHAR2(2000):= NULL;
 l_message_body        VARCHAR2(4000):= NULL;
 l_message_footer      VARCHAR2(2000):= NULL;
 l_role_name           VARCHAR2(100);
 l_display_role_name   VARCHAR2(240);
 l_notif_id            NUMBER;
 l_user_count          NUMBER;
 l_user_resource_id    NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 x_party_notification_id      NUMBER;
-- l_newline_msg              VARCHAR2(1) := FND_GLOBAL.Newline;
-- l_newline              VARCHAR2(10) := l_newline_msg || '<BR>';
-- l_newline              VARCHAR2(5) := '<BR>';
 l_newline              VARCHAR2(5) := wf_core.newline;

 l_notif_rule_active   VARCHAR2(1):='N';
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;

BEGIN
    /*  Standard Start of API savepoint */
    SAVEPOINT send_thnkyou_notif_PVT;

    /* Standard call to check for call compatibility. */
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                              p_api_version ,
                              l_api_name    ,
                                        G_PKG_NAME
    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Validate the Enrollment Request Id */
    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
    THEN
      /* Debug message */
      IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message('Validate_Enrl_Requests_Id');
      END IF;
      /* Invoke validation procedures */
      Validate_Enrl_Requests
      (  p_enrl_request_id
       , 'ENRL_REQUEST_ID'
       , l_return_status
       );
      /* If any errors happen abort API. */
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* Get the enrollment request details */
    get_enrl_requests_details(
        p_enrl_request_id       =>  p_enrl_request_id ,
        x_req_submission_date   =>  l_req_submission_date,
        x_partner_program_id    =>  l_partner_program_id,
        x_partner_program       =>  l_partner_program,
        x_enrollment_duration   =>  l_enrollment_duration,
        x_enrollment_type       =>  l_enrollment_type,
        x_req_resource_id       =>  l_req_resource_id,
        x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
        x_return_status         =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
	    FND_MESSAGE.SET_NAME('PV', 'PV_ENRL_REQ_NOT_EXIST');
	    FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	    FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* If Notification Rule is Active for the given PROGRAM_ID, then only
       proceed, else do not send the notification. */

    l_notif_rule_active := check_Notif_Rule_Active(
        p_program_id => l_partner_program_id,
        p_notif_type => 'PG_THANKYOU' ) ;

    IF ( l_notif_rule_active = 'Y' )
    THEN
       /* Get the Partner and Vendor details */
      get_prtnr_vendor_details(
        p_enrl_request_id       =>  p_enrl_request_id ,
        x_vendor_party_id       =>  l_vendor_party_id,
        x_vendor_name           =>  l_vendor_name,
        x_partner_party_id      =>  l_partner_party_id,
        x_partner_comp_name     =>  l_partner_comp_name,
        x_return_status         =>  x_return_status
      );

      /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
	      FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      /* Get the requestor details */
      get_requestor_details(
        p_req_resource_id       =>  l_req_resource_id,
        x_user_id               =>  l_user_id,
        x_source_name           =>  l_source_name,
        x_user_name             =>  l_user_name,
        x_return_status         =>  x_return_status
      );

      /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
	      FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      /* Get the user list */
      get_users_list(
         p_partner_id          =>  l_prtnr_vndr_relship_id,
         x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
         x_user_count          =>  l_user_count,
         x_return_status       =>  x_return_status ) ;

       /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	      FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

       /* Send the notification to all the users from that partner Organization
          for the given partner vendor relationship id. */

      FOR i IN 1 .. l_user_count LOOP
        l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
 	      l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

        /* Get the role name for the given 'p_requestor_id'.
        IF p_send_to_role_name IS NULL THEN */
        get_resource_role(
            p_resource_id       =>  l_user_resource_id,
            x_role_name         =>  l_role_name,
            x_role_display_name =>  l_display_role_name,
            x_return_status     =>  x_return_status
        );

        /* Check for Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	        FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	        FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        /* Use the 'WF_Notification.send' procedure to send the notification */

        l_notif_id := WF_Notification.send (  role => l_role_name
                                            , msg_type => 'PVXNUTIL'
                                           -- , msg_name => 'DOC_MESSAGE');
                                            , msg_name => 'ALERT_MESSAGE');
        /* Set all the entity attributes by replacing the supplyied parameters.*/
--          WF_Notification.SetAttrText(l_notif_id,'DOCUMENT_ID', 'PVXNUTIL:'||l_notif_id);
        /*  Set the Vendor Name */
        /*
          fnd_message.set_name('PV', 'PV_VENDOR_NM');
          fnd_message.set_token('PV_VENDOR_NAME',  l_vendor_name);
          WF_Notification.SetAttrText (l_notif_id, 'PV_VENDOR_NM', fnd_message.get);
          */

        -- Set the subject line
        fnd_message.set_name('PV', 'PV_NTF_THANKYOU_SUBJECT');
        fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
        WF_Notification.SetAttrText (l_notif_id, 'SUBJECT', fnd_message.get);


          -- Set the Message Header
          fnd_message.set_name('PV', 'PV_NTF_ENRL_ALERT');
          fnd_message.set_token('PV_VENDOR_NM', l_vendor_name);
          l_message_hdr  := fnd_message.get || l_newline;


          l_message_body  := fnd_message.get_string('PV', 'PV_NTF_THANKYOU_GREETINGS') || l_newline;
          l_message_body  := l_message_body || l_newline;
          l_message_body  := l_message_body || fnd_message.get_string('PV', 'PV_NTF_ENRL_PROCESSING')|| l_newline ;
          l_message_body  := l_message_body || l_newline;

          -- Set the Partner Company Name
          fnd_message.set_name('PV', 'PV_NTF_PARTNER_NM');
          fnd_message.set_token('PV_PARTNER_NM', l_partner_comp_name);
          l_message_body  := l_message_body ||fnd_message.get|| l_newline ;

          -- Set the requestor name
          fnd_message.set_name('PV', 'PV_NTF_REQUESTOR_NM');
          fnd_message.set_token('PV_REQUESTOR_NM', rtrim(l_source_name));
          l_message_body  := l_message_body || fnd_message.get || l_newline ;

          -- Set the request submission date
          fnd_message.set_name('PV', 'PV_NTF_REQ_SUBMIT_DT');
          fnd_message.set_token('PV_REQ_SUBMIT_DT', l_req_submission_date);
          l_message_body  := l_message_body || fnd_message.get|| l_newline;

          -- Set the partner program name
          fnd_message.set_name('PV', 'PV_NTF_PARTNER_PRGM');
          fnd_message.set_token('PV_PARTNER_PRGM', l_partner_program);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          -- Set the enrollment duration
          fnd_message.set_name('PV', 'PV_NTF_ENRL_DURATION');
          fnd_message.set_token('PV_ENRL_DURATION', l_enrollment_duration);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          -- Set the enrollment type
          fnd_message.set_name('PV', 'PV_NTF_ENRL_TYPE');
          fnd_message.set_token('PV_ENRL_TYPE', l_enrollment_type);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          -- Get the values for all message attributes from the message list for Message Footer
          l_message_footer  := l_newline || fnd_message.get_string('PV', 'PV_NTF_ALERT_THANKS') || l_newline;
          l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ALERT_CLOSING')|| l_newline;
          l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ENROLLMENT_TEAM') || l_newline;

          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_HEADER', l_message_hdr);
          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_BODY', l_message_body);
          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_FOOTER', l_message_footer);

          WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

          /* Set the record for Create_Ge_Party_Notif API */
          Set_Pgp_Notif(
                p_notif_id          => l_notif_id,
                p_object_version    => 1,
                p_partner_id  	    => l_prtnr_vndr_relship_id,
                p_user_id           => l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id=> p_enrl_request_id,
                p_notif_type_code   => l_notif_type_code,
                x_return_status     => x_return_status ,
                x_pgp_notif_rec     =>  l_pgp_notif_rec );

          /* Check for Procedure's x_return_status */
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
             FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
             FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

          /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */
          PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
                p_api_version_number    => 1.0,
                p_init_msg_list         => FND_API.G_FALSE ,
                p_commit                => FND_API.G_FALSE ,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
                x_return_status         => x_return_status ,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data ,
                p_pgp_notif_rec         => l_pgp_notif_rec,
                x_party_notification_id => x_party_notification_id );

          /* Check for Procedure's x_return_status */
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
             FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
             FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

       END LOOP;

       /* call transaction history log to record this log. */
       /* Set the log params for History log. */
       l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
       l_log_params_tbl(1).param_value := get_Notification_Name(l_notif_type_code);
       l_log_params_tbl(2).param_name := 'ITEM_NAME';
       l_log_params_tbl(2).param_value := 'ENRL_REQUEST_ID';
       l_log_params_tbl(3).param_name := 'ITEM_ID';
       l_log_params_tbl(3).param_value := p_enrl_request_id;

       /* call transaction history log to record this log. */
       PVX_Utility_PVT.create_history_log(
           p_arc_history_for_entity_code   => 'GENERAL', --'ENRQ',
           p_history_for_entity_id         => l_prtnr_vndr_relship_id, --p_enrl_request_id,
           p_history_category_code         => 'ENROLLMENT',
           p_message_code                  => 'PV_NOTIF_HISTORY_MSG',
           p_partner_id                    => l_prtnr_vndr_relship_id,
           p_log_params_tbl                => l_log_params_tbl,
           x_return_status                 => x_return_status,
           x_msg_count                     => x_msg_count,
           x_msg_data                      => x_msg_data );

       /* Check for Procedure's x_return_status */
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
          FND_MESSAGE.SET_TOKEN('ID',p_enrl_request_id);
          FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       /* Standard check of p_commit. */
       IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
       END IF;

       /* Standard call to get message count and if count is 1, get message info.*/
       FND_MSG_PUB.Count_And_Get
       ( p_count =>      x_msg_count ,
         p_data  =>      x_msg_data
       );
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO send_thnkyou_notif_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
        p_data  =>      x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO  send_thnkyou_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
        p_data  =>      x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO send_thnkyou_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
    END IF;
    FND_MSG_PUB.Count_And_Get
      (  p_count =>      x_msg_count
       , p_data  =>      x_msg_data
      );
END send_thnkyou_notif;

/*============================================================================
-- Start of comments
--  API name  : send_welcome_notif
--  Type    : Private.
--  Function  : This API compiles and sends the Welcome Notification to a
--                partner, once the partner user's  enrollment request is
--                approved by the approver.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_membership_id        IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_welcome_notif (
    p_api_version       IN  NUMBER ,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE ,
    p_commit        IN  VARCHAR2 := FND_API.G_FALSE ,
    p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
    x_return_status   OUT NOCOPY VARCHAR2 ,
    x_msg_count     OUT NOCOPY NUMBER ,
    x_msg_data      OUT NOCOPY VARCHAR2 ,
    p_membership_id     IN  NUMBER
 )
IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_welcome_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status    VARCHAR2(1);

 l_membership_id        NUMBER;
 l_enrl_request_id      NUMBER;
 l_req_resource_id      NUMBER;
 l_req_submission_date  VARCHAR2(240);
 l_enrollment_start_date VARCHAR2(240);
 l_enrollment_end_date  VARCHAR2(240);
 l_partner_program_id   NUMBER;
 l_partner_program      VARCHAR2(240);
 l_enrollment_type      VARCHAR2(240);
 l_prtnr_vndr_relship_id NUMBER;
 l_user_id              NUMBER;
 l_notif_user_id        NUMBER;
 l_source_name          VARCHAR2(360);
 l_requestor_name       VARCHAR2(360);
 l_user_name            VARCHAR2(100);
 l_vendor_name          VARCHAR2(360);
 l_vendor_party_id      NUMBER;
 l_partner_party_id     NUMBER;
 l_partner_comp_name    VARCHAR2(360);
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'ENRQ';
 l_notif_type_code      VARCHAR2(30) := 'PG_WELCOME';
 l_message_hdr          VARCHAR2(2000):= NULL;
 l_message_body         VARCHAR2(4000):= NULL;
 l_message_footer       VARCHAR2(2000):= NULL;

 /* Declaration of  local variables  for all the  message attributes */
 l_alert_thanks         VARCHAR2(240);
 l_alert_closing        VARCHAR2(240);
 l_enrollment_team    VARCHAR2(240);

 l_item_type           VARCHAR2(8) := 'PVXNUTIL';
-- l_message_name        VARCHAR2(20):= 'ALERT_MESSAGE';
 l_message_name        VARCHAR2(20):= 'DOC_MESSAGE';

 l_role_name           VARCHAR2(100);
 l_display_role_name   VARCHAR2(240);
 l_notif_id            NUMBER;
 l_user_count          NUMBER;
 l_user_resource_id    NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 x_party_notification_id      NUMBER;
-- l_newline_msg              VARCHAR2(1) := FND_GLOBAL.Newline;
-- l_newline              VARCHAR2(10) := l_newline_msg || '<BR>';
 l_newline              VARCHAR2(5) := '<BR>'; -- not using wf_core as we are using pl/sql document
-- l_newline              VARCHAR2(5) := wf_core.newline;

 l_notif_rule_active   VARCHAR2(1):='N';
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;
 l_prtner_portal_url    VARCHAR2(4000);
 l_login_url  VARCHAR2(4000);

BEGIN
    /* Standard Start of API savepoint */
    SAVEPOINT send_welcome_notif_PVT;

    /* Standard call to check for call compatibility. */
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                              p_api_version ,
                              l_api_name    ,
                              G_PKG_NAME
      )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /*  Initialize API return status to success */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Validate the Enrollment Request Id */
    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        /* Debug message */
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_membership_Id');
        END IF;

        /* Invoke validation procedures */
        Validate_Enrl_Requests
        (   p_membership_id ,
            'MEMBERSHIP_ID',
            l_return_status
        );

         /* If any errors happen abort API. */
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

    /* Get the membership details*/
    get_membership_details(
        p_membership_id         =>  p_membership_id ,
        x_req_submission_date   =>  l_req_submission_date,
        x_partner_program_id    =>  l_partner_program_id,
        x_partner_program       =>  l_partner_program,
        x_enrl_request_id       =>  l_enrl_request_id,
        x_enrollment_start_date =>  l_enrollment_start_date,
        x_enrollment_end_date   =>  l_enrollment_end_date,
	      x_req_resource_id	=>  l_req_resource_id,
        x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
        x_enrollment_type       =>  l_enrollment_type,
        x_return_status         =>  x_return_status);


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PV','PV_MBRSHIP_NOT_EXIST');
      FND_MESSAGE.SET_TOKEN('MEMBERSHIP_ID',p_membership_id);
      FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* If Notification Rule is Active for the given PROGRAM_ID, then only
       proceed, else do not send the notification. */

    l_notif_rule_active := check_Notif_Rule_Active(
				    p_program_id => l_partner_program_id,
            p_notif_type => 'PG_WELCOME' ) ;

    IF ( l_notif_rule_active = 'Y' )
    THEN
       /* Get the Partner and Vendor details */
      get_prtnr_vendor_details(
	         p_enrl_request_id       =>  l_enrl_request_id ,
           x_vendor_party_id       =>  l_vendor_party_id,
           x_vendor_name           =>  l_vendor_name,
           x_partner_party_id      =>  l_partner_party_id,
           x_partner_comp_name     =>  l_partner_comp_name,
           x_return_status         =>  x_return_status);


       /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',l_enrl_request_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

       /* Get the requestor details */
      get_requestor_details(
           p_req_resource_id       =>  l_req_resource_id,
           x_user_id               =>  l_user_id,
           x_source_name           =>  l_source_name,
           x_user_name             =>  l_user_name,
           x_return_status         =>  x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

       /* Get the user list */
      get_users_list(
           p_partner_id          =>  l_prtnr_vndr_relship_id,
           x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
           x_user_count          =>  l_user_count,
           x_return_status       =>  x_return_status ) ;

       /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	      FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

       /* Send the notification to all the users from that partner Organization
          for the given partner vendor relationship id. */

      FOR i IN 1 .. l_user_count
      LOOP
        l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
        l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

           /* Get the role name for the given 'p_requestor_id'. */
           /*IF p_send_to_role_name IS NULL THEN */
        get_resource_role(
               p_resource_id       =>  l_user_resource_id,
               x_role_name         =>  l_role_name,
               x_role_display_name =>  l_display_role_name,
               x_return_status     =>  x_return_status
           );

           /* Check for Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
	        FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	        FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	        FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        /* Use the 'WF_Notification.send' procedure to send the notification */

        l_notif_id := WF_Notification.send (
                 role => l_role_name
               , msg_type => l_item_type
               , msg_name => l_message_name );

        WF_Notification.SetAttrText(l_notif_id,'NOTIF_DOC_ID', 'PVXNUTIL:'||l_notif_id); -- passing the doc id

        /* Set the subject line */
        fnd_message.set_name('PV', 'PV_NTF_WELCOME_SUBJECT');
        fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
        WF_Notification.SetAttrText (l_notif_id, 'SUBJECT', fnd_message.get);

        /* Set the Message Header */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_ALERT');
        fnd_message.set_token('PV_VENDOR_NM', l_vendor_name);
        l_message_hdr  := fnd_message.get || l_newline;

        /*  Set all the entity attributes by replacing the supplied parameters. */

        /*  Set the Vendor Name
           fnd_message.set_name('PV', 'PV_VENDOR_NM');
           fnd_message.set_token('PV_VENDOR_NAME',  l_vendor_name);
           WF_Notification.SetAttrText (l_notif_id, 'PV_VENDOR_NM', fnd_message.get);
           */

        /* Set the welcome greeting Line */
        fnd_message.set_name('PV', 'PV_NTF_WELCOME_GREETINGS');
        fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
        l_message_body  := fnd_message.get || l_newline;
        l_message_body  := l_message_body || l_newline;

        /* Set the Partner Company Name */
        fnd_message.set_name('PV', 'PV_NTF_PARTNER_NM');
        fnd_message.set_token('PV_PARTNER_NM', l_partner_comp_name);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

               /* Set the Requestor Name */
        fnd_message.set_name('PV', 'PV_NTF_REQUESTOR_NM');
        fnd_message.set_token('PV_REQUESTOR_NM', l_source_name);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Request Submission Date */
        fnd_message.set_name('PV', 'PV_NTF_REQ_SUBMIT_DT');
        fnd_message.set_token('PV_REQ_SUBMIT_DT', l_req_submission_date);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Partner Program Name */
        fnd_message.set_name('PV', 'PV_NTF_PARTNER_PRGM');
        fnd_message.set_token('PV_PARTNER_PRGM', l_partner_program);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Enrollment Start Date */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_START_DT');
        fnd_message.set_token('PV_ENRL_START_DT', l_enrollment_start_date);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Enrollment End Date */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_END_DT');
        fnd_message.set_token('PV_ENRL_END_DT', l_enrollment_end_date);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Enrollment Type */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_TYPE');
        fnd_message.set_token('PV_ENRL_TYPE', l_enrollment_type);
        l_message_body  := l_message_body || fnd_message.get || l_newline;
        l_message_body  := l_message_body || l_newline;

	--kvattiku Oct 31, 05 Commented out and modified code so that the URL is obtained from profile.
        --/* Set the Log-in portal line */
	--l_login_url := get_Program_Url(l_partner_program_id);
	l_login_url := FND_PROFILE.VALUE('PV_WORKFLOW_ISTORE_URL');
        l_prtner_portal_url := '<a href="'|| l_login_url || '">'|| l_partner_program  || '</a>';

           /*
           l_prtner_portal_url := icx_sec.createRFURL(
                p_function_name     => 'PV_MYPARTNER_ORGZN',
                p_application_id    => 691,
                p_responsibility_id => 23073,
                p_security_group_id => fnd_global.security_group_id );
           */

        fnd_message.set_name('PV', 'PV_NTF_LOGIN_PORTAL');
        fnd_message.set_token('PV_LOGIN_PORTAL', l_prtner_portal_url);
        --fnd_message.set_token('PV_LOGIN_PORTAL', '');
        l_message_body  := l_message_body || fnd_message.get || l_newline;


        /* Get the values for all message attributes from the message list for Message Footer  */
        l_message_footer  := l_newline || fnd_message.get_string('PV', 'PV_NTF_ALERT_THANKS') || l_newline;
        l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ALERT_CLOSING')|| l_newline;
        l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ENROLLMENT_TEAM') || l_newline;


        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_HEADER', l_message_hdr);
        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_BODY', l_message_body);
        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_FOOTER', l_message_footer);

        WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

           /* Set the record for Create_Ge_Party_Notif API */
        Set_Pgp_Notif(
                p_notif_id		=> l_notif_id,
                p_object_version	=> 1,
                p_partner_id	    	=> l_prtnr_vndr_relship_id,
                p_user_id           	=> l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id   => p_membership_id,
                p_notif_type_code   	=> l_notif_type_code,
                x_return_status         => x_return_status ,
                x_pgp_notif_rec     	=>  l_pgp_notif_rec );

        /* Check for Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
          FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
          FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

           /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */

        PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
               p_api_version_number    => 1.0,
               p_init_msg_list         => FND_API.G_FALSE ,
               p_commit                => FND_API.G_FALSE ,
               p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
               x_return_status         => x_return_status ,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data ,
               p_pgp_notif_rec         => l_pgp_notif_rec,
               x_party_notification_id       => x_party_notification_id );

           /* Check for Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
          FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
          FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

      END LOOP;

       /* call transaction history log to record this log. */
       /* Set the log params for History log. */
       l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
       l_log_params_tbl(1).param_value := get_Notification_Name(l_notif_type_code);
       l_log_params_tbl(2).param_name := 'ITEM_NAME';
       l_log_params_tbl(2).param_value := 'MEMBERSHIP_ID';
       l_log_params_tbl(3).param_name := 'ITEM_ID';
       l_log_params_tbl(3).param_value := p_membership_id;

       /* call transaction history log to record this log. */
       PVX_Utility_PVT.create_history_log(
           p_arc_history_for_entity_code=> 'MBRSHIP',
           p_history_for_entity_id      => p_membership_id,
           p_history_category_code      => 'APPROVAL',
           p_message_code              	=> 'PV_NOTIF_HISTORY_MSG',
           p_partner_id	    	          => l_prtnr_vndr_relship_id,
           p_log_params_tbl            	=> l_log_params_tbl,
           x_return_status              => x_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data );

        /* Check for Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
           FND_MESSAGE.SET_TOKEN('ID',p_membership_id);
           FND_MSG_PUB.Add;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        ( p_count =>      x_msg_count ,
          p_data  =>      x_msg_data
         );

    END IF;  /* End the IF condition for check_Notif_Rule_Active */

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
    	   ROLLBACK TO send_welcome_notif_PVT;
    	   x_return_status := FND_API.G_RET_STS_ERROR ;
    	   FND_MSG_PUB.Count_And_Get
    	   ( p_count =>      x_msg_count ,
      	     p_data  =>      x_msg_data
           );

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO send_welcome_notif_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
         ( p_count =>      x_msg_count ,
           p_data  =>      x_msg_data
         );

	  WHEN OTHERS THEN
      ROLLBACK TO send_welcome_notif_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
      END IF;
        FND_MSG_PUB.Count_And_Get
        (  p_count =>      x_msg_count
        , p_data  =>      x_msg_data
        );
END send_welcome_notif;

/*============================================================================
-- Start of comments
--  API name  : send_rejection_notif
--  Type    : Private.
--  Function  : This API compiles and sends the rejection notification to a
--                partner, once the partner user's enrollment request for a
--                partner program is rejected by the approver.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_enrl_request_id      IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_rejection_notif (
    p_api_version       IN  NUMBER ,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE ,
    p_commit        IN  VARCHAR2 := FND_API.G_FALSE ,
    p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
    x_return_status   OUT NOCOPY VARCHAR2 ,
    x_msg_count     OUT NOCOPY NUMBER ,
    x_msg_data      OUT NOCOPY VARCHAR2 ,
    p_enrl_request_id   IN  NUMBER
 )
IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_rejection_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status        VARCHAR2(1);

 l_enrl_request_id      NUMBER;
 l_req_resource_id      NUMBER ;
 l_req_submission_date  VARCHAR2(240);
 l_enrollment_duration  VARCHAR2(240);
 l_partner_program_id   NUMBER;
 l_partner_program      VARCHAR2(240);
 l_enrollment_type      VARCHAR2(240);
 l_prtnr_vndr_relship_id NUMBER;
 l_user_id              NUMBER;
 l_notif_user_id        NUMBER;
 l_source_name          VARCHAR2(360);
 l_requestor_name       VARCHAR2(360);
 l_user_name            VARCHAR2(100);
 l_vendor_party_id      NUMBER;
 l_partner_party_id     NUMBER;
 l_vendor_name          VARCHAR2(360);
 l_partner_comp_name    VARCHAR2(360);
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'ENRQ';
 l_notif_type_code      VARCHAR2(30) := 'PG_REJECT';

 /* Declaration of  local variables  for all the  message attributes */
 l_enrl_alert           VARCHAR2(240);
 l_rejection_info       VARCHAR2(240);
 l_alert_thanks         VARCHAR2(240);
 l_alert_closing        VARCHAR2(240);
 l_enrollment_team    VARCHAR2(240);
 l_message_hdr         VARCHAR2(2000):= NULL;
 l_message_body        VARCHAR2(4000):= NULL;
 l_message_footer      VARCHAR2(2000):= NULL;


 l_item_type           VARCHAR2(8) := 'PVXNUTIL';
 l_message_name        VARCHAR2(20):= 'ALERT_MESSAGE';
-- l_message_name        VARCHAR2(20):= 'DOC_MESSAGE';

 l_role_name           VARCHAR2(100);
 l_display_role_name   VARCHAR2(240);
 l_notif_id            NUMBER;
 l_user_count          NUMBER;
 l_user_resource_id    NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 x_party_notification_id      NUMBER;
-- l_newline_msg              VARCHAR2(1) := FND_GLOBAL.Newline;
-- l_newline              VARCHAR2(10) := l_newline_msg || '<BR>';
-- l_newline              VARCHAR2(5) := '<BR>';
 l_newline              VARCHAR2(5) := wf_core.newline;

 l_notif_rule_active   VARCHAR2(1):='N';
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT send_rejection_notif_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                              p_api_version ,
                              l_api_name    ,
                              G_PKG_NAME
    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Validate the Enrollment Request Id */
    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_Enrl_Requests_Id');
        END IF;

        -- Invoke validation procedures
        Validate_Enrl_Requests
        (   p_enrl_request_id ,
            'ENRL_REQUEST_ID',
            l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Get the enrollment request details*/
    get_enrl_requests_details(
        p_enrl_request_id       =>  p_enrl_request_id ,
        x_req_submission_date   =>  l_req_submission_date,
        x_partner_program_id    =>  l_partner_program_id,
        x_partner_program       =>  l_partner_program,
        x_enrollment_duration   =>  l_enrollment_duration,
        x_enrollment_type       =>  l_enrollment_type,
        x_req_resource_id       =>  l_req_resource_id,
        x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
        x_return_status         =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('PV', 'PV_ENRL_REQ_NOT_EXIST');
	FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* If Notification Rule is Active for the given PROGRAM_ID, then only
       proceed, else do not send the notification. */

    l_notif_rule_active := check_Notif_Rule_Active(
				p_program_id => l_partner_program_id,
                                p_notif_type => 'PG_REJECT' ) ;

    IF ( l_notif_rule_active = 'Y' ) THEN

        /* Get the Partner and Vendor details */
        get_prtnr_vendor_details(
            p_enrl_request_id       =>  p_enrl_request_id ,
            x_vendor_party_id       =>  l_vendor_party_id,
            x_vendor_name           =>  l_vendor_name,
            x_partner_party_id      =>  l_partner_party_id,
            x_partner_comp_name     =>  l_partner_comp_name,
            x_return_status         =>  x_return_status);

        /* Check for API return status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
	    FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	    FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        /*  Validate the Enrollment Requestor Resource Id */
        IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
        THEN
           -- Debug message
           IF (PV_DEBUG_HIGH_ON) THEN

               PVX_UTILITY_PVT.debug_message('Validate_Enrl_Requestor_Resource_Id');
           END IF;

           -- Invoke validation procedures
           Validate_Enrl_Requests
           (   l_req_resource_id ,
               'REQUESTOR_RESOURCE_ID',
               l_return_status
           );

           -- If any errors happen abort API.
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

       END IF;

       /* Get the requestor details */
       get_requestor_details(
           p_req_resource_id       =>  l_req_resource_id,
           x_user_id               =>  l_user_id,
           x_source_name           =>  l_source_name,
           x_user_name             =>  l_user_name,
           x_return_status         =>  x_return_status);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	  FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
	  FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       /* Get the user list */
       get_users_list(
         p_partner_id          =>  l_prtnr_vndr_relship_id,
         x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
         x_user_count          =>  l_user_count,
         x_return_status       =>  x_return_status ) ;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	  FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	  FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       /* Send the notification to all the users from that partner Organization
          for the given partner vendor relationship id. */

       FOR i IN 1 .. l_user_count LOOP
           l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
 	   l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

           /* Get the role name for the given 'p_requestor_id'. */
           /*IF p_send_to_role_name IS NULL THEN */
           get_resource_role(
               p_resource_id       =>  l_user_resource_id,
               x_role_name         =>  l_role_name,
               x_role_display_name =>  l_display_role_name,
               x_return_status     =>  x_return_status
           );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	     FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	     FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

          /* Use the 'WF_Notification.send' procedure to send the notification */
          l_notif_id := WF_Notification.send (
            		role => l_role_name
            		, msg_type => l_item_type
            		, msg_name => l_message_name );

          /*  Set all the entity attributes by replacing the supplyied parameters. */
--          WF_Notification.SetAttrText(l_notif_id,'DOCUMENT_ID', 'PVXNUTIL:'||l_notif_id);
          /*  Set the Vendor Name */
          /*
          fnd_message.set_name('PV', 'PV_VENDOR_NM');
          fnd_message.set_token('PV_VENDOR_NAME',  l_vendor_name);
          WF_Notification.SetAttrText (l_notif_id, 'PV_VENDOR_NM', fnd_message.get);
          */

          /* Set the subject line */
          fnd_message.set_name('PV', 'PV_NTF_REJECTION_SUBJECT');
          fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
          WF_Notification.SetAttrText (l_notif_id, 'SUBJECT', fnd_message.get);

          /* Set the Message Header */
          fnd_message.set_name('PV', 'PV_NTF_ENRL_ALERT');
          fnd_message.set_token('PV_VENDOR_NM', l_vendor_name);
          l_message_hdr  := fnd_message.get || l_newline;
--          WF_Notification.SetAttrText (l_notif_id, 'MESSAGE_HEADER', l_message_hdr);

          /* Set the Message Body */
          fnd_message.set_name('PV', 'PV_NTF_REJECTION_MESG');
          fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
          l_message_body  := fnd_message.get || l_newline;
          l_message_body  := l_message_body || l_newline;

          /* Set the Partner Company Name */
          fnd_message.set_name('PV', 'PV_NTF_PARTNER_NM');
          fnd_message.set_token('PV_PARTNER_NM', l_partner_comp_name);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          /* Set the requestor name */
          fnd_message.set_name('PV', 'PV_NTF_REQUESTOR_NM');
          fnd_message.set_token('PV_REQUESTOR_NM', rtrim(l_source_name));
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          /* Set the request submission date */
          fnd_message.set_name('PV', 'PV_NTF_REQ_SUBMIT_DT');
          fnd_message.set_token('PV_REQ_SUBMIT_DT', l_req_submission_date);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          /* Set the partner program name */
          fnd_message.set_name('PV', 'PV_NTF_PARTNER_PRGM');
          fnd_message.set_token('PV_PARTNER_PRGM', l_partner_program);
          l_message_body  := l_message_body || fnd_message.get || l_newline;

          /* Set the enrollment type */
          fnd_message.set_name('PV', 'PV_NTF_ENRL_TYPE');
          fnd_message.set_token('PV_ENRL_TYPE', l_enrollment_type);
          l_message_body  := l_message_body || fnd_message.get|| l_newline;

          /* Get the values for all message attributes from the message list for Message Footer  */
          l_message_footer  := l_newline || fnd_message.get_string('PV', 'PV_NTF_ALERT_THANKS') || l_newline;
          l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ALERT_CLOSING')|| l_newline;
          l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ENROLLMENT_TEAM') || l_newline;

          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_HEADER', l_message_hdr);
          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_BODY', l_message_body);
          WF_Notification.SetAttrText(l_notif_id,'MESSAGE_FOOTER', l_message_footer);

          WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

          /* Set the record for Create_Ge_Party_Notif API */
          Set_Pgp_Notif(
                p_notif_id          => l_notif_id,
                p_object_version    => 1,
                p_partner_id  => l_prtnr_vndr_relship_id,
                p_user_id           => l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id   => p_enrl_request_id,
                p_notif_type_code   => l_notif_type_code,
                x_return_status         => x_return_status ,
                x_pgp_notif_rec     =>  l_pgp_notif_rec );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
             FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
             FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

          /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */

          PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
             p_api_version_number    => 1.0,
             p_init_msg_list         => FND_API.G_FALSE ,
             p_commit                => FND_API.G_FALSE ,
             p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
             x_return_status         => x_return_status ,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data ,
             p_pgp_notif_rec         => l_pgp_notif_rec,
             x_party_notification_id => x_party_notification_id );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
             FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
             FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;


        END LOOP;

        /* call transaction history log to record this log. */
        /* Set the log params for History log. */
        l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
        l_log_params_tbl(1).param_value := get_Notification_Name(l_notif_type_code);
        l_log_params_tbl(2).param_name := 'ITEM_NAME';
        l_log_params_tbl(2).param_value := 'ENRL_REQUEST_ID';
        l_log_params_tbl(3).param_name := 'ITEM_ID';
        l_log_params_tbl(3).param_value := p_enrl_request_id;

        /* call transaction history log to record this log. */
        PVX_Utility_PVT.create_history_log(
            p_arc_history_for_entity_code=> 'GENERAL', --'ENRQ',
            p_history_for_entity_id     => l_prtnr_vndr_relship_id, --p_enrl_request_id,
            p_history_category_code     => 'APPROVAL',
            p_message_code              => 'PV_NOTIF_HISTORY_MSG',
            p_partner_id	    	        => l_prtnr_vndr_relship_id,
            p_log_params_tbl            => l_log_params_tbl,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data );

        /* if any error happens rollback only this row, and proceed to next record. otherwise commit */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
           FND_MESSAGE.SET_TOKEN('ID',p_enrl_request_id);
           FND_MSG_PUB.Add;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
         ( p_count =>      x_msg_count ,
           p_data  =>      x_msg_data
        );

    END IF;  /* End the IF condition for check_Notif_Rule_Active */

    EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO send_rejection_notif_PVT;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              ( p_count =>      x_msg_count ,
                p_data  =>      x_msg_data
              );

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	     ROLLBACK TO send_rejection_notif_PVT;
    	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      	     FND_MSG_PUB.Count_And_Get
      	     ( p_count =>      x_msg_count ,
      	     p_data  =>      x_msg_data
    	     );

  WHEN OTHERS THEN
    ROLLBACK TO send_rejection_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
    END IF;
    FND_MSG_PUB.Count_And_Get
      (  p_count =>      x_msg_count
       , p_data  =>      x_msg_data
      );
END send_rejection_notif;
/*============================================================================
-- Start of comments
--  API name  : send_cntrct_notrcvd_notif
--  Type    : Private.
--  Function  : This API compiles and sends the 'Signed Contract is not received'
--                notification to a partner, when there signed copy of contract is
--                not received by the vendor, which is required for approval the
--                enrollment request.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_enrl_request_id      IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_cntrct_notrcvd_notif (
    p_api_version       IN  NUMBER ,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE ,
    p_commit        IN  VARCHAR2 := FND_API.G_FALSE ,
    p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
    x_return_status   OUT NOCOPY VARCHAR2 ,
    x_msg_count     OUT NOCOPY NUMBER ,
    x_msg_data      OUT NOCOPY VARCHAR2 ,
    p_enrl_request_id   IN  NUMBER
 )
IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_cntrct_notrcvd_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status    VARCHAR2(1);

 l_enrl_request_id      NUMBER;
 l_req_resource_id      NUMBER ;
 l_req_submission_date  VARCHAR2(240);
 l_enrollment_duration  VARCHAR2(240);
 l_partner_program_id   NUMBER;
 l_partner_program      VARCHAR2(240);
 l_enrollment_type      VARCHAR2(240);
 l_prtnr_vndr_relship_id NUMBER;
 l_user_id              NUMBER;
 l_notif_user_id        NUMBER;
 l_source_name          VARCHAR2(360);
 l_requestor_name       VARCHAR2(360);
 l_user_name            VARCHAR2(100);
 l_vendor_party_id      NUMBER;
 l_partner_party_id     NUMBER;
 l_vendor_name          VARCHAR2(360);
 l_partner_comp_name    VARCHAR2(360);
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'ENRQ';
 l_notif_type_code      VARCHAR2(30) := 'PG_CONTRCT_NRCVD';
 l_message_hdr         VARCHAR2(2000):= NULL;
 l_message_body        VARCHAR2(4000):= NULL;
 l_message_footer      VARCHAR2(2000):= NULL;

 /* Declaration of  local variables  for all the  message attributes */
 l_cntrct_mesg          VARCHAR2(240);
 l_cntrct_addl_mesg     VARCHAR2(240);
 l_enrl_alert           VARCHAR2(240);
 l_alert_thanks         VARCHAR2(240);
 l_alert_closing        VARCHAR2(240);
 l_enrollment_team    VARCHAR2(240);

 l_item_type           VARCHAR2(8) := 'PVXNUTIL';
 l_message_name        VARCHAR2(30):= 'ALERT_MESSAGE';
-- l_message_name        VARCHAR2(20):= 'DOC_MESSAGE';

 l_role_name           VARCHAR2(100);
 l_display_role_name   VARCHAR2(240);
 l_notif_id            NUMBER;
 l_user_count          NUMBER;
 l_user_resource_id    NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 x_party_notification_id      NUMBER;
-- l_newline_msg              VARCHAR2(1) := FND_GLOBAL.Newline;
-- l_newline              VARCHAR2(10) := l_newline_msg || '<BR>';
-- l_newline              VARCHAR2(5) := '<BR>';
 l_newline              VARCHAR2(5) := wf_core.newline;

 l_notif_rule_active   VARCHAR2(1):='N';
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT send_cntrct_notrcvd_notif_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                              p_api_version ,
                              l_api_name    ,
                                        G_PKG_NAME
    )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Validate the Enrollment Request Id */
    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_Enrl_Requests_Id');
        END IF;

        -- Invoke validation procedures
        Validate_Enrl_Requests
        (   p_enrl_request_id ,
            'ENRL_REQUEST_ID',
            l_return_status
        );

        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Get the enrollment request details*/
    get_enrl_requests_details(
        p_enrl_request_id       =>  p_enrl_request_id ,
        x_req_submission_date   =>  l_req_submission_date,
        x_partner_program_id    =>  l_partner_program_id,
        x_partner_program       =>  l_partner_program,
        x_enrollment_duration   =>  l_enrollment_duration,
        x_enrollment_type       =>  l_enrollment_type,
        x_req_resource_id       =>  l_req_resource_id,
        x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
        x_return_status         =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('PV', 'PV_ENRL_REQ_NOT_EXIST');
	FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* If Notification Rule is Active for the given PROGRAM_ID, then only
       proceed, else do not send the notification. */

    l_notif_rule_active := check_Notif_Rule_Active(
				p_program_id => l_partner_program_id,
                                p_notif_type => 'PG_CONTRCT_NRCVD') ;

    IF ( l_notif_rule_active = 'Y' ) THEN

       /* Get the Partner and Vendor details */
       get_prtnr_vendor_details(
           p_enrl_request_id       =>  p_enrl_request_id ,
           x_vendor_party_id       =>  l_vendor_party_id,
           x_vendor_name           =>  l_vendor_name,
           x_partner_party_id      =>  l_partner_party_id,
           x_partner_comp_name     =>  l_partner_comp_name,
           x_return_status         =>  x_return_status);

      /* Check the Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
	 FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_enrl_request_id);
	 FND_MSG_PUB.Add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     END IF;

     /* Get the requestor details */
     get_requestor_details(
        p_req_resource_id       =>  l_req_resource_id,
        x_user_id               =>  l_user_id,
        x_source_name           =>  l_source_name,
        x_user_name             =>  l_user_name,
        x_return_status         =>  x_return_status);

    /* Check the Procedure's x_return_status */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
	FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Get the user list */
    get_users_list(
      p_partner_id          =>  l_prtnr_vndr_relship_id,
      x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
      x_user_count          =>  l_user_count,
      x_return_status       =>  x_return_status ) ;

    /* Check the Procedure's x_return_status */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Send the notification to all the users from that partner Organization
       for the given partner vendor relationship id. */

    FOR i IN 1 .. l_user_count LOOP
        l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
 	l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

        /* Get the role name for the given 'p_requestor_id'. */
        get_resource_role(
            p_resource_id       =>  l_user_resource_id,
            x_role_name         =>  l_role_name,
            x_role_display_name =>  l_display_role_name,
            x_return_status     =>  x_return_status
        );

        /* Check the Procedure's x_return_status */
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	  FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	  FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        /* Use the 'WF_Notification.send' procedure to send the notification */
        l_notif_id := WF_Notification.send (
            role => l_role_name
            , msg_type => l_item_type
            , msg_name => l_message_name );

        /*  Set all the entity attributes by replacing the supplied parameters. */
--        WF_Notification.SetAttrText(l_notif_id,'DOCUMENT_ID', 'PVXNUTIL:'||l_notif_id);

        /* Set the subject line */
        fnd_message.set_name('PV', 'PV_NTF_CONTRACT_SUBJECT');
        fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
        WF_Notification.SetAttrText (l_notif_id, 'SUBJECT', fnd_message.get);

        /* Set the Message Header */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_ALERT');
        fnd_message.set_token('PV_VENDOR_NM', l_vendor_name);
        l_message_hdr  := fnd_message.get || l_newline;

        /*  Set the Vendor Name */
        /*
        fnd_message.set_name('PV', 'PV_VENDOR_NM');
        fnd_message.set_token('PV_VENDOR_NAME',  l_vendor_name);
        WF_Notification.SetAttrText (l_notif_id, 'PV_VENDOR_NM', fnd_message.get);
       */

       l_message_body  := fnd_message.get_string('PV', 'PV_NTF_CONTRACT_MESG')|| l_newline;
       l_message_body  := l_message_body || l_newline;

        /* Set the Partner Company Name */
        fnd_message.set_name('PV', 'PV_NTF_PARTNER_NM');
        fnd_message.set_token('PV_PARTNER_NM', l_partner_comp_name);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

        /* Set the Requestor Name */
        fnd_message.set_name('PV', 'PV_NTF_REQUESTOR_NM');
        fnd_message.set_token('PV_REQUESTOR_NM', l_source_name);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

        /* Set the request submission date */
        fnd_message.set_name('PV', 'PV_NTF_REQ_SUBMIT_DT');
        fnd_message.set_token('PV_REQ_SUBMIT_DT', l_req_submission_date);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

        /* Set the Partner Program Name */
        fnd_message.set_name('PV', 'PV_NTF_PARTNER_PRGM');
        fnd_message.set_token('PV_PARTNER_PRGM', l_partner_program);
        l_message_body  := l_message_body || fnd_message.get || l_newline;

        /* Set the Enrollment Type */
        fnd_message.set_name('PV', 'PV_NTF_ENRL_TYPE');
        fnd_message.set_token('PV_ENRL_TYPE', l_enrollment_type);
        l_message_body  := l_message_body || fnd_message.get || l_newline;
        l_message_body  := l_message_body || l_newline;

        /* Get the values for all message attributes from the message list   */
        l_message_body  := l_message_body || fnd_message.get_string('PV', 'PV_NTF_CONTRACT_ADDL_MESG')|| l_newline;

        /* Get the values for all message attributes from the message list for Message Footer  */
        l_message_footer  := l_newline || fnd_message.get_string('PV', 'PV_NTF_ALERT_THANKS') || l_newline;
        l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ALERT_CLOSING')|| l_newline;
        l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ENROLLMENT_TEAM') || l_newline;

        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_HEADER', l_message_hdr);
        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_BODY', l_message_body);
        WF_Notification.SetAttrText(l_notif_id,'MESSAGE_FOOTER', l_message_footer);

        WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

         /* Set the record for Create_Ge_Party_Notif API */
         Set_Pgp_Notif(
                p_notif_id          => l_notif_id,
                p_object_version    => 1,
                p_partner_id  => l_prtnr_vndr_relship_id,
                p_user_id           => l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id   => p_enrl_request_id,
                p_notif_type_code   => l_notif_type_code,
                x_return_status         => x_return_status ,
                x_pgp_notif_rec     =>  l_pgp_notif_rec );

        /* Check the Procedure's x_return_status */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
            FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */

        PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE ,
            p_commit                => FND_API.G_FALSE ,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
            x_return_status         => x_return_status ,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data ,
            p_pgp_notif_rec         => l_pgp_notif_rec,
            x_party_notification_id       => x_party_notification_id );

        /* Check the Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
            FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;


    END LOOP;

     /* call transaction history log to record this log. */
  /* Set the log params for History log. */
   l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
   l_log_params_tbl(1).param_value := get_Notification_Name(l_notif_type_code);
   l_log_params_tbl(2).param_name := 'ITEM_NAME';
   l_log_params_tbl(2).param_value := 'ENRL_REQUEST_ID';
   l_log_params_tbl(3).param_name := 'ITEM_ID';
   l_log_params_tbl(3).param_value := p_enrl_request_id;

   /* call transaction history log to record this log. */
   PVX_Utility_PVT.create_history_log(
         p_arc_history_for_entity_code   => 'GENERAL', --'ENRQ',
         p_history_for_entity_id         => l_prtnr_vndr_relship_id, --p_enrl_request_id,
         p_history_category_code         => 'CONTRACT',
         p_message_code                 => 'PV_NOTIF_HISTORY_MSG',
         p_log_params_tbl               => l_log_params_tbl,
         p_partner_id	    	        => l_prtnr_vndr_relship_id,
         x_return_status               => x_return_status,
         x_msg_count                     => x_msg_count,
         x_msg_data                      => x_msg_data );

    /* Check for x_return_status */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
         FND_MESSAGE.SET_TOKEN('ID',p_enrl_request_id);
         FND_MSG_PUB.Add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );

    END IF;  /* End the IF condition for check_Notif_Rule_Active */

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO send_cntrct_notrcvd_notif_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO send_cntrct_notrcvd_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO send_cntrct_notrcvd_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
    END IF;
      FND_MSG_PUB.Count_And_Get
      (  p_count =>      x_msg_count
       , p_data  =>      x_msg_data
      );
END send_cntrct_notrcvd_notif;

/*============================================================================
-- Start of comments
--  API name  : send_mbrship_exp_notif
--  Type    : Private.
--  Function  : This API compiles and sends the 'Membership Expiry' Notification
--                to a partner, once the partner user's  enrollment is going to
--                expire in near future.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_membership_id        IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_mbrship_exp_notif (
    p_api_version       IN  NUMBER ,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit        IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
  x_return_status   OUT NOCOPY VARCHAR2 ,
  x_msg_count     OUT NOCOPY NUMBER ,
  x_msg_data      OUT NOCOPY VARCHAR2 ,
    p_membership_id     IN  NUMBER
 )
IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_membership_expiry_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status    VARCHAR2(1);

 l_membership_id        NUMBER;
 l_enrl_request_id      NUMBER;
 l_req_resource_id      NUMBER ;
 l_req_submission_date  VARCHAR2(240);
 l_enrollment_start_date VARCHAR2(240);
 l_enrollment_end_date   VARCHAR2(240);
 l_partner_program_id   NUMBER;
 l_partner_program      VARCHAR2(240);
 l_enrollment_type      VARCHAR2(240);
 l_prtnr_vndr_relship_id NUMBER;
 l_user_id              NUMBER;
 l_notif_user_id        NUMBER;
 l_source_name          VARCHAR2(360);
 l_requestor_name       VARCHAR2(360);
 l_user_name            VARCHAR2(100);
 l_vendor_name          VARCHAR2(360);
 l_vendor_party_id      NUMBER;
 l_partner_party_id     NUMBER;
 l_partner_comp_name    VARCHAR2(360);
 l_enrl_expiry_in_days  VARCHAR2(80);
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'MEMBR';
 l_notif_type_code      VARCHAR2(30) := 'PG_MEM_EXP';

 /* Declaration of  local variables  for all the  message attributes */
 l_expiry_mesg          VARCHAR2(240);
 l_expiry_addl_mesg     VARCHAR2(240);
 l_enrl_alert           VARCHAR2(240);
 l_alert_thanks         VARCHAR2(240);
 l_alert_closing        VARCHAR2(240);
 l_enrollment_team    VARCHAR2(240);

 l_item_type           VARCHAR2(8) := 'PVXNUTIL';
-- l_message_name        VARCHAR2(20):= 'ALERT_MESSAGE';
 l_message_name        VARCHAR2(20):= 'DOC_MESSAGE';

 l_message_hdr         VARCHAR2(2000):= NULL;
 l_message_body        VARCHAR2(4000):= NULL;
 l_message_footer      VARCHAR2(2000):= NULL;
 l_role_name           VARCHAR2(100);
 l_display_role_name   VARCHAR2(240);
 l_notif_id            NUMBER;
 l_user_count          NUMBER;
 l_user_resource_id    NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 x_party_notification_id      NUMBER;
-- l_newline_msg              VARCHAR2(1) := FND_GLOBAL.Newline;
-- l_newline              VARCHAR2(10) := l_newline_msg || '<BR>';
 l_newline              VARCHAR2(5) := '<BR>'; -- not using wf_core as we are using pl/sql document
-- l_newline              VARCHAR2(5) := wf_core.newline;

 l_notif_rule_active  VARCHAR2(1);
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;
 l_prtner_portal_url    VARCHAR2(2000);
 l_login_url    VARCHAR2(4000);

BEGIN
      -- Standard Start of API savepoint
    SAVEPOINT send_mbership_expiry_notif_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                              p_api_version ,
                              l_api_name    ,
                                        G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /*  Initialize API return status to success */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*  Validate the Enrollment Request Id */
    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_Membership_Id');
        END IF;

        -- Invoke validation procedures
        Validate_Enrl_Requests
        (   p_membership_id ,
            'MEMBERSHIP_ID',
            l_return_status
        );

        /* If any errors happen abort API. */
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Get the membership details*/
    get_membership_details(
        p_membership_id         =>  p_membership_id ,
        x_req_submission_date   =>  l_req_submission_date,
        x_partner_program_id    =>  l_partner_program_id,
        x_partner_program       =>  l_partner_program,
        x_enrl_request_id       =>  l_enrl_request_id,
        x_enrollment_start_date =>  l_enrollment_start_date,
        x_enrollment_end_date   =>  l_enrollment_end_date,
	      x_req_resource_id	=>  l_req_resource_id,
        x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
        x_enrollment_type       =>  l_enrollment_type,
        x_return_status         =>  x_return_status);

    /* Check Procedure's x_return_status */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('PV','PV_MBRSHIP_NOT_EXIST');
	FND_MESSAGE.SET_TOKEN('MEMBERSHIP_ID',p_membership_id);
	FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* If Notification Rule is Active for the given PROGRAM_ID, then only
       proceed, else do not send the notification. */

    l_notif_rule_active := check_Notif_Rule_Active(
				p_program_id => l_partner_program_id,
                                p_notif_type => 'PG_MEM_EXP' ) ;

    IF ( l_notif_rule_active = 'Y' ) THEN

       /* Get the Partner and Vendor details */
       get_prtnr_vendor_details(
           p_enrl_request_id       =>  l_enrl_request_id ,
           x_vendor_party_id       =>  l_vendor_party_id,
           x_vendor_name           =>  l_vendor_name,
           x_partner_party_id      =>  l_partner_party_id,
           x_partner_comp_name     =>  l_partner_comp_name,
           x_return_status         =>  x_return_status);

       /* Check for Procedure's x_return_status */
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
	  FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',l_enrl_request_id);
	  FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       /*  Validate the Enrollment Requestor Resource Id */
       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
         THEN
           -- Debug message
           IF (PV_DEBUG_HIGH_ON) THEN

              PVX_UTILITY_PVT.debug_message('Validate_Enrl_Requestor_Resource_Id');
           END IF;

           -- Invoke validation procedures
           Validate_Enrl_Requests
           (   l_req_resource_id ,
               'REQUESTOR_RESOURCE_ID',
               l_return_status
           );

        /* If any errors happen abort API. */
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
       /* Get the requestor details */
       get_requestor_details(
           p_req_resource_id       =>  l_req_resource_id,
           x_user_id               =>  l_user_id,
           x_source_name           =>  l_source_name,
           x_user_name             =>  l_user_name,
           x_return_status         =>  x_return_status);

       /* Check the Procedure's x_return_status */
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	  FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
	  FND_MSG_PUB.Add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

        /* Get the user list */
       get_users_list(
         p_partner_id          =>  l_prtnr_vndr_relship_id,
         x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
         x_user_count          =>  l_user_count,
         x_return_status       =>  x_return_status ) ;

        /* Check the Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	   FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	   FND_MSG_PUB.Add;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        /* Send the notification to all the users from that partner Organization
           for the given partner vendor relationship id. */

        FOR i IN 1 .. l_user_count LOOP
            l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
 	    l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

            /* Get the role name for the given 'p_requestor_id'. */
            /*IF p_send_to_role_name IS NULL THEN */
            get_resource_role(
                p_resource_id       =>  l_user_resource_id,
                x_role_name         =>  l_role_name,
                x_role_display_name =>  l_display_role_name,
                x_return_status     =>  x_return_status
            );

            /* Check the Procedure's x_return_status */
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	      FND_MSG_PUB.Add;
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

            /* Use the 'WF_Notification.send' procedure to send the notification */
            l_notif_id := WF_Notification.send (
                    role => l_role_name
                    , msg_type => l_item_type
                    , msg_name => l_message_name );

            WF_Notification.SetAttrText(l_notif_id,'NOTIF_DOC_ID', 'PVXNUTIL:'||l_notif_id); -- passing the doc id

             /* Set the subject line */
            fnd_message.set_name('PV', 'PV_NTF_EXPIRY_SUBJECT');
            fnd_message.set_token('PV_PARTNER_PROGRAM', l_partner_program);
            WF_Notification.SetAttrText (l_notif_id, 'SUBJECT', fnd_message.get);

            /* Set the Message Header */
            fnd_message.set_name('PV', 'PV_NTF_ENRL_ALERT');
            fnd_message.set_token('PV_VENDOR_NM', l_vendor_name);
            l_message_hdr  := fnd_message.get || l_newline;

            /*  Set all the entity attributes by replacing the supplied parameters. */

            /*  Set the Vendor Name */
            /*
            fnd_message.set_name('PV', 'PV_VENDOR_NM');
            fnd_message.set_token('PV_VENDOR_NAME',  l_vendor_name);
            WF_Notification.SetAttrText (l_notif_id, 'PV_VENDOR_NM', fnd_message.get);
            */

            l_message_body  := fnd_message.get_string('PV', 'PV_NTF_EXPIRY_MESG')|| l_newline;
            l_message_body  := l_message_body || l_newline;

            /* Set the Partner Company Name */
            fnd_message.set_name('PV', 'PV_NTF_PARTNER_NM');
            fnd_message.set_token('PV_PARTNER_NM', l_partner_comp_name);
            l_message_body  := l_message_body || fnd_message.get || l_newline;

            /* Set the Requestor Name */
            fnd_message.set_name('PV', 'PV_NTF_REQUESTOR_NM');
            fnd_message.set_token('PV_REQUESTOR_NM', l_source_name);
            l_message_body  := l_message_body || fnd_message.get || l_newline;

           /* Set the Partner Program Name */
            fnd_message.set_name('PV', 'PV_NTF_PARTNER_PRGM');
            fnd_message.set_token('PV_PARTNER_PRGM', l_partner_program);
            l_message_body  := l_message_body || fnd_message.get || l_newline;

            /* Set the Enrollment Start Date */
            fnd_message.set_name('PV', 'PV_NTF_ENRL_START_DT');
            fnd_message.set_token('PV_ENRL_START_DT', l_enrollment_start_date);
            l_message_body  := l_message_body || fnd_message.get || l_newline;

            /* Set the Enrollment End Date */
            fnd_message.set_name('PV', 'PV_NTF_ENRL_END_DT');
            fnd_message.set_token('PV_ENRL_END_DT', l_enrollment_end_date);
            l_message_body  := l_message_body || fnd_message.get || l_newline;

            /* Set the Expiry in # of days */
            fnd_message.set_name('PV', 'PV_NTF_EXPIRY_IN_DAYS');
            --fnd_message.set_token('PV_ENRL_EXPIRY_IN_DAYS', trunc(to_date(l_enrollment_end_date) - sysdate) );
            fnd_message.set_token('PV_ENRL_EXPIRY_IN_DAYS', trunc( to_date( l_enrollment_end_date,'DD-MM-YY' ) - to_date( sysdate,'DD-MM-YY') ) );
            l_message_body  := l_message_body || fnd_message.get || l_newline;

            /* Get the values for all message attributes from the message list   */
            /* Set the Log-in portal line */
            /*        l_prtner_portal_url := icx_sec.createRFURL(
                            p_function_name     => 'PV_MYPARTNER_ORGZN',
                            p_application_id    => 691,
                            p_responsibility_id => 23073,
                            p_security_group_id => fnd_global.security_group_id );
            */
            /* Set the Log-in portal line */
            l_login_url := FND_PROFILE.VALUE('PV_WORKFLOW_RESPOND_URL');
            l_prtner_portal_url := '<a href="'|| l_login_url || '">'|| l_partner_program  || '</a>';

            fnd_message.set_name('PV', 'PV_NTF_EXPIRY_ADDL_MESG');
            fnd_message.set_token('PV_PARTNER_PORTAL_URL', l_prtner_portal_url);
            l_message_body  := l_message_body ||fnd_message.get || l_newline;

            /* Get the values for all message attributes from the message list for Message Footer  */
            l_message_footer  := l_newline || fnd_message.get_string('PV', 'PV_NTF_ALERT_THANKS') || l_newline;
            l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ALERT_CLOSING')|| l_newline;
            l_message_footer  := l_message_footer || fnd_message.get_string('PV', 'PV_NTF_ENROLLMENT_TEAM') || l_newline;

            WF_Notification.SetAttrText(l_notif_id,'MESSAGE_HEADER', l_message_hdr);
            WF_Notification.SetAttrText(l_notif_id,'MESSAGE_BODY', l_message_body);
            WF_Notification.SetAttrText(l_notif_id,'MESSAGE_FOOTER', l_message_footer);

            WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

            /* Set the record for Create_Ge_Party_Notif API */
            Set_Pgp_Notif(
                p_notif_id          => l_notif_id,
                p_object_version    => 1,
                p_partner_id  => l_prtnr_vndr_relship_id,
                p_user_id           => l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id   => p_membership_id,
                p_notif_type_code   => l_notif_type_code,
                x_return_status         => x_return_status ,
                x_pgp_notif_rec     =>  l_pgp_notif_rec );

            /* Check the Procedure's x_return_status */
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
               FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
               FND_MSG_PUB.Add;
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

            /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */

            PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
                    p_api_version_number    => 1.0,
                    p_init_msg_list         => FND_API.G_FALSE ,
                    p_commit                => FND_API.G_FALSE ,
                    p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
                    x_return_status         => x_return_status ,
                    x_msg_count             => x_msg_count,
                    x_msg_data              => x_msg_data ,
                    p_pgp_notif_rec         => l_pgp_notif_rec,
                    x_party_notification_id       => x_party_notification_id );

            /* Check the Procedure's x_return_status */
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
               FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
               FND_MSG_PUB.Add;
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

        END LOOP;

        /* call transaction history log to record this log. */
        /* Set the log params for History log. */
        l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
        l_log_params_tbl(1).param_value := get_Notification_Name(l_notif_type_code);
        l_log_params_tbl(2).param_name := 'ITEM_NAME';
        l_log_params_tbl(2).param_value := 'MEMBERSHIP_ID';
        l_log_params_tbl(3).param_name := 'ITEM_ID';
        l_log_params_tbl(3).param_value := p_membership_id;

        /* call transaction history log to record this log. */
        PVX_Utility_PVT.create_history_log(
                p_arc_history_for_entity_code   => 'MBRSHIP',
                p_history_for_entity_id         => p_membership_id,
                p_history_category_code         => 'PAYMENT',
                p_message_code              => 'PV_NOTIF_HISTORY_MSG',
                p_partner_id	    	        => l_prtnr_vndr_relship_id,
                p_log_params_tbl            => l_log_params_tbl,
                x_return_status               => x_return_status,
                x_msg_count                     => x_msg_count,
                x_msg_data                      => x_msg_data );

        /* Check for x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
           FND_MESSAGE.SET_TOKEN('ID',p_membership_id);
           FND_MSG_PUB.Add;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         ( p_count =>      x_msg_count ,
         p_data  =>      x_msg_data
       );

    END IF;  /* End the IF condition for check_Notif_Rule_Active */

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO send_mbership_expiry_notif_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO send_mbership_expiry_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO send_mbership_expiry_notif_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
    END IF;
      FND_MSG_PUB.Count_And_Get
      (  p_count =>      x_msg_count
       , p_data  =>      x_msg_data
      );
END send_mbrship_exp_notif;

/*============================================================================
-- Start of comments
--  API name  : send_mbrship_change_notif
--  Type    : Private.
--  Function  : This API compiles and sends notification to all partner
--                primary users in case of Upgrade/Downgrade/Termination/Invite
--                membership to a partner user.
--  Pre-reqs  : None.
--  Parameters  :
--  IN    : p_api_version          IN NUMBER  Required
--        p_init_msg_list        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_commit               IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level     IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_mbr_upgrade_rec      IN NUMBER    Required
--
--  OUT   : x_return_status   OUT VARCHAR2(1)
--        x_msg_count     OUT NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--
--  Version : Current version 1.0
--        Initial version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
PROCEDURE send_mbrship_chng_notif (
    p_api_version       IN  NUMBER ,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit        IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN  NUMBER  :=  FND_API.G_VALID_LEVEL_FULL  ,
  x_return_status   OUT NOCOPY VARCHAR2 ,
  x_msg_count     OUT NOCOPY NUMBER ,
  x_msg_data      OUT NOCOPY VARCHAR2 ,
    p_mbrship_chng_rec  IN  PV_PG_NOTIF_UTILITY_PVT.mbrship_chng_rec_type
  )
 IS

 /* Declaration of local variables. */
 l_api_name             CONSTANT VARCHAR2(30) := 'send_mbrship_change_notif';
 l_api_version          CONSTANT NUMBER     := 1.0;
 l_return_status    VARCHAR2(1);

 l_membership_resource_id NUMBER;
 l_partner_program        VARCHAR2(240);
 l_prtnr_vndr_relship_id  NUMBER;
 l_enrl_request_id        NUMBER;
 l_user_id                NUMBER;
 l_notif_user_id          NUMBER;
 l_source_name            VARCHAR2(360);
 l_requestor_name         VARCHAR2(360);
 l_user_name              VARCHAR2(100);
 l_vendor_name            VARCHAR2(360);
 l_partner_comp_name      VARCHAR2(360);

 /* Declaration of  local variables  for all the  message attributes */
 l_enrl_alert             VARCHAR2(240);
 l_alert_thanks           VARCHAR2(240);
 l_alert_closing          VARCHAR2(240);
 l_enrollment_team        VARCHAR2(240);

 l_item_type              VARCHAR2(8) := 'PVXNUTIL';
 l_message_name           VARCHAR2(20):= 'ALERT_MESSAGE';
-- l_message_name           VARCHAR2(20):= 'DOC_MESSAGE';

 l_message_hdr              VARCHAR2(2000):= NULL;
 l_message_body             VARCHAR2(4000):= NULL;
 l_message_footer           VARCHAR2(2000):= NULL;
 l_role_name              VARCHAR2(100);
 l_display_role_name      VARCHAR2(240);
 l_user_count               NUMBER;
 l_user_resource_id         NUMBER ;
 x_user_notify_rec_tbl user_notify_rec_tbl_type;
 l_notif_id               NUMBER;
 x_party_notification_id          NUMBER;
 l_pgp_notif_rec        PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
 l_arc_notif_for_entity_code VARCHAR2(30) := 'ENRQ';
 l_notif_type_code      VARCHAR2(30) ;
 l_history_category_code      VARCHAR2(30) ;
 l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;

BEGIN

    /*  Standard Start of API savepoint */
    SAVEPOINT send_mbrship_chng_notif;

  /* Standard call to check for call compatibility. */
    IF NOT FND_API.Compatible_API_Call (  l_api_version ,
                                    p_api_version ,
                                    l_api_name ,
                                            G_PKG_NAME
   ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
    END IF;

    /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    /* Validate the partner contact resource id and partner id. */
    IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
    THEN
        /* Debug message */
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_partner_contact_resource_Id');
        END IF;

        /* Invoke validation procedures */

        Validate_Enrl_Requests
        (   p_mbrship_chng_rec.id,
            'ID',
            l_return_status
        );

        /* If any errors happen abort API. */
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      /* Debug message */
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Validate_partner_vendor_relship_Id');
        END IF;

        /* Invoke validation procedures */
        Validate_Enrl_Requests
        (   p_mbrship_chng_rec.partner_id ,
            'PRNTR_VENDOR_RELSHIP_ID',
            l_return_status
        );

        /* If any errors happen abort API. */
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    /* Get the requestor details */
    get_requestor_details(
        p_req_resource_id       =>  p_mbrship_chng_rec.resource_id,
        x_user_id               =>  l_user_id,
        x_source_name           =>  l_source_name,
        x_user_name             =>  l_user_name,
        x_return_status         =>  x_return_status);

    /* Check the Procedure's x_return_status */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
	    FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',p_mbrship_chng_rec.resource_id);
	    FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /* Call 'get_users_list' procedure, to find out, all users from that partner
    orgnization of same type, to whome, we have to send upgrade notification. */
    get_users_list(
      p_partner_id          =>  p_mbrship_chng_rec.partner_id,
      x_user_notify_rec_tbl =>  x_user_notify_rec_tbl ,
      x_user_count          =>  l_user_count,
      x_return_status       =>  x_return_status ) ;


   /* Check the Procedure's x_return_status */
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_USER_EXIST');
	    FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_prtnr_vndr_relship_id);
	    FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;


    /*  Execute in a loop the Send notification process, for all the users,
    which we got from the previous step. */

    FOR i IN 1 .. l_user_count LOOP
      l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
 	    l_notif_user_id    := x_user_notify_rec_tbl(i).user_id;

      get_resource_role(
                p_resource_id       =>  l_user_resource_id,
                x_role_name         =>  l_role_name,
                x_role_display_name =>  l_display_role_name,
                x_return_status     =>  x_return_status
      );

        /* Check the Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      FND_MESSAGE.SET_NAME('PV','PV_RES_ROLE_NOT_EXIST');
	      FND_MESSAGE.SET_TOKEN('RESOURCE_ID',l_user_resource_id);
	      FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      l_notif_id := WF_Notification.send (  role => l_role_name
                , msg_type => l_item_type
                 , msg_name => l_message_name );

--        WF_Notification.SetAttrText(l_notif_id,'DOCUMENT_ID', 'PVXNUTIL:'||l_notif_id);
        /* Set all entity attributes by replacing the supplied parameters. */
      WF_Notification.SetAttrText(l_notif_id, 'SUBJECT',p_mbrship_chng_rec.MESSAGE_SUBJ );

      WF_Notification.SetAttrText(l_notif_id, 'MESSAGE_HEADER', l_message_hdr);
      WF_Notification.SetAttrText(l_notif_id, 'MESSAGE_BODY',p_mbrship_chng_rec.MESSAGE_BODY  );
      WF_Notification.SetAttrText(l_notif_id, 'MESSAGE_FOOTER', l_message_footer);

      WF_NOTIFICATION.Denormalize_Notification(l_notif_id);

      /* Set the record for Set_Pgp_Notif API */
      Set_Pgp_Notif(
                p_notif_id          	=> l_notif_id,
                p_object_version    	=> 1,
                p_partner_id  		=> p_mbrship_chng_rec.partner_id ,
                p_user_id           	=> l_notif_user_id,
                p_arc_notif_for_entity_code => l_arc_notif_for_entity_code,
                p_notif_for_entity_id   => p_mbrship_chng_rec.id,
                p_notif_type_code   	=> p_mbrship_chng_rec.NOTIF_TYPE,
                x_return_status     	=> x_return_status ,
                x_pgp_notif_rec     	=>  l_pgp_notif_rec );


      /* Check the Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
            FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;


        /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATION   */
        PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE ,
            p_commit                => FND_API.G_FALSE ,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
            x_return_status         => x_return_status ,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data ,
            p_pgp_notif_rec         => l_pgp_notif_rec,
            x_party_notification_id       => x_party_notification_id );

        /* Check the Procedure's x_return_status */
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
            FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notif_id);
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END LOOP;


    /* call transaction history log to record this log. */
    /* Set the log params for History log. */
    l_log_params_tbl(1).param_name := 'NOTIFICATION_TYPE';
    l_log_params_tbl(1).param_value := get_Notification_Name(p_mbrship_chng_rec.NOTIF_TYPE);
    l_log_params_tbl(2).param_name := 'ITEM_NAME';
    l_log_params_tbl(2).param_value := 'ID';
    l_log_params_tbl(3).param_name := 'ITEM_ID';
    l_log_params_tbl(3).param_value := p_mbrship_chng_rec.id;

    /* Select the proper hitory category code based on the Notification Type.*/
    IF (p_mbrship_chng_rec.NOTIF_TYPE = 'PG_INVITE') THEN
	    l_history_category_code := 'INVITE' ;
    ELSIF (p_mbrship_chng_rec.NOTIF_TYPE = 'PG_UPGRADE' ) THEN
	    l_history_category_code := 'UPGRADE' ;
    ELSIF (p_mbrship_chng_rec.NOTIF_TYPE = 'PG_DOWNGRADE' ) THEN
	    l_history_category_code := 'DOWNGRADE' ;
    ELSIF (p_mbrship_chng_rec.NOTIF_TYPE = 'PG_TERMINATE' ) THEN
	    l_history_category_code := 'TERMINATE' ;
    END IF;

    /* call transaction history log to record this log. */

    PVX_Utility_PVT.create_history_log(
        p_arc_history_for_entity_code   => 'GENERAL', --ENRQ',
        p_history_for_entity_id         => p_mbrship_chng_rec.partner_id, --p_mbrship_chng_rec.id,
        p_history_category_code         => l_history_category_code,
        p_message_code              	  => 'PV_NOTIF_HISTORY_MSG',
        p_partner_id	    	            => p_mbrship_chng_rec.partner_id,
        p_log_params_tbl            	  => l_log_params_tbl,
        x_return_status               	=> x_return_status,
        x_msg_count                     => x_msg_count,
        x_msg_data                      => x_msg_data );

    -- Check for x_return_status
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('PV','PV_CR_HISTORY_LOG');
        FND_MESSAGE.SET_TOKEN('ID',p_mbrship_chng_rec.id);
        FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /*  Set OUT values Standard check of p_commit. */
    IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
    END IF;

  /*  Standard call to get message count and if count is 1, get message info. */
   FND_MSG_PUB.Count_And_Get(
        p_count =>      x_msg_count ,
        p_data  =>      x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO send_mbrship_chng_notif;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO send_mbrship_chng_notif;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      ( p_count =>      x_msg_count ,
      p_data  =>      x_msg_data
    );
    WHEN OTHERS THEN
    ROLLBACK TO send_mbrship_chng_notif;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
        (  G_FILE_NAME
         , G_PKG_NAME
         );
    END IF;
    FND_MSG_PUB.Count_And_Get
      (  p_count =>      x_msg_count
       , p_data  =>      x_msg_data
      );
End  send_mbrship_chng_notif;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    send_ini_rmdr_notif
--
-- PURPOSE
--  This procedure send the initial or a reminder notification.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE send_ini_rmdr_notif(
    ITEMTYPE    IN  VARCHAR2,
    ITEMKEY     IN  VARCHAR2,
    ACTID     IN  NUMBER,
    FUNCMODE    IN  VARCHAR2,
    RESULTOUT   OUT NOCOPY VARCHAR2
)
IS
    /* Declare local variables */
  l_mbrship_id  NUMBER;
    l_enrl_req_id   NUMBER;
    l_notif_type    VARCHAR2(30);
    l_wait_in_days  NUMBER;
  l_itemtype    VARCHAR2(30) ;
  l_itemkey   VARCHAR2(240);
    x_return_status VARCHAR2(1);
    x_msg_count   NUMBER;
    x_msg_data      VARCHAR2(240);

    BEGIN
        l_itemtype := itemtype;
        l_itemkey  := itemkey;

        IF ( funcmode = 'RUN' ) THEN

            /* Get the notification type from the workflow Itemtype 'PVXNUTIL' */
            l_notif_type := wf_engine.GetItemAttrText(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'NOTIFICATION_TYPE' );

            /* Get wait in Days, applicable for any type of notification. */
            l_wait_in_days := wf_engine.GetItemAttrNumber(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'WAIT_PERIOD_IN_DAYS' );

            /* Check for Notification Type. It may be 'PG_MEM_EXP' or 'PG_CONTRCT_NRCVD' */
            IF (l_notif_type = 'PG_MEM_EXP' ) THEN

                /* Get the membership Id from the workflow Itemtype 'PVXNUTIL' */
                l_mbrship_id := wf_engine.GetItemAttrNumber(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'MEMBERSHIP_ID' );

                /* Call the send_membership_expiry_notif */
                PV_PG_NOTIF_UTILITY_PVT.send_mbrship_exp_notif (
                    p_api_version       => 1.0 ,
                    p_init_msg_list   => FND_API.G_FALSE  ,
                    p_commit        => FND_API.G_FALSE  ,
                    p_validation_level  => FND_API.G_VALID_LEVEL_FULL ,
                    x_return_status   => x_return_status ,
                    x_msg_count     => x_msg_count ,
                    x_msg_data      => x_msg_data ,
                    p_membership_id     => l_mbrship_id );

                IF (X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS ) THEN
                    FND_MESSAGE.SET_NAME('PV','PV_API_ERROR_MESSAGE');
                    FND_MESSAGE.SET_TOKEN('PROC_NAME','PVX_Utility_PVT.send_ini_rmdr_notif');
                    FND_MESSAGE.SET_TOKEN('ITEM_NAME','MEMBERSHIP_ID');
                    FND_MESSAGE.SET_TOKEN('ITEM_ID',l_mbrship_id);
        	          FND_MSG_PUB.Add;
                END IF;


             ELSIF (l_notif_type = 'PG_CONTRCT_NRCVD' ) THEN
                 /* Get the Enrollment Request Id from the workflow Itemtype 'PVXNUTIL' */
                l_enrl_req_id := wf_engine.GetItemAttrNumber(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'ENROLLMENT_REQUEST_ID' );

                /* Call the send_cntrct_notrcvd_notif */
                PV_PG_NOTIF_UTILITY_PVT.send_cntrct_notrcvd_notif (
                    p_api_version       => 1.0 ,
                    p_init_msg_list   => FND_API.G_FALSE  ,
                    p_commit        => FND_API.G_FALSE  ,
                    p_validation_level  => FND_API.G_VALID_LEVEL_FULL ,
                    x_return_status   => x_return_status ,
                    x_msg_count     => x_msg_count ,
                    x_msg_data      => x_msg_data ,
                    p_enrl_request_id   => l_enrl_req_id );

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                    FND_MESSAGE.SET_NAME('PV','PV_API_ERROR_MESSAGE');
                    FND_MESSAGE.SET_TOKEN('PROC_NAME','PVX_Utility_PVT.send_ini_rmdr_notif');
                    FND_MESSAGE.SET_TOKEN('ITEM_NAME','ENRL_REQUEST_ID');
                    FND_MESSAGE.SET_TOKEN('ITEM_ID',l_enrl_req_id);
        	          FND_MSG_PUB.Add;
                END IF;

             END IF;

         END IF;
        RESULTOUT :=  'COMPLETE:Y';
        return;
  EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'send_ini_rmdr_notif');
      END IF;
      wf_core.context(G_PKG_NAME,'send_ini_rmdr_notif', itemtype,itemkey,to_char(actid),funcmode);

  END send_ini_rmdr_notif;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    check_for_rmdr_notif
--
-- PURPOSE
--  This procedure checks, whether, is there any need to send a reminder notification
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
  PROCEDURE check_for_rmdr_notif(
    ITEMTYPE    IN  VARCHAR2,
    ITEMKEY     IN  VARCHAR2,
    ACTID     IN  NUMBER,
    FUNCMODE    IN  VARCHAR2,
    RESULTOUT   OUT NOCOPY VARCHAR2
)
IS
  /* Cursor declaration to check the remainder flag for a given membership_id,
  whether we have to send any reminder or not */
  CURSOR c_Check_Memexp_Rmdr_Flg (cv_membership_id NUMBER) IS
    SELECT  'Y'
    FROM    pv_pg_memberships mmbr
    WHERE   mmbr.membership_id = cv_membership_id
    AND NOT EXISTS
        (   SELECT  1
            FROM    pv_pg_mmbr_transitions trans,
                    pv_pg_memberships mmbr_future
            WHERE   trans.from_membership_id = mmbr.membership_id
            AND     trans.to_membership_id = mmbr_future.membership_id
            AND     mmbr_future.membership_status_code = 'FUTURE' );

  /* Cursor declaration to check the remainder flag for a given enrl_request_id,
 whether we have to send any reminder notification or not in case of 'Signed
 Contract not received' notification */
 CURSOR c_Check_Cnrcvd_Rmdr_Flg (cv_enrl_request_id NUMBER) IS
    SELECT  'Y'
    FROM    pv_pg_enrl_requests enrq
    WHERE   enrq.enrl_request_id = cv_enrl_request_id
    AND     enrq.contract_status_code = 'AWAITING_FAX_OR_MAIL';

/* Declare local variables */
  l_mbrship_id  NUMBER;
    l_enrl_req_id   NUMBER;
    l_notif_type    VARCHAR2(30);
    l_wait_in_days  NUMBER;
  l_itemtype    VARCHAR2(30) ;
  l_itemkey   VARCHAR2(240);
    l_rmdr_flag     VARCHAR2(1) := 'N';
    x_return_status VARCHAR2(1);
    x_msg_count   NUMBER;
    x_msg_data      VARCHAR2(240);
    l_end_date   DATE;
    l_expiry_days  NUMBER;
    l_date_format            VARCHAR2(80);
 BEGIN
        l_itemtype := itemtype;
        l_itemkey  := itemkey;

        IF ( funcmode = 'RUN' ) THEN

            /* Get the WAIT_PERIOD_IN_DAYS attribute from the workflow Itemtype 'PVXNUTIL' */
            l_wait_in_days := wf_engine.GetItemAttrText(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'WAIT_PERIOD_IN_DAYS' );
            /* Check for WAIT_PERIOD_IN_DAYS */
            IF ( l_wait_in_days > 0)
            THEN
                /* Get the notification type from the workflow Itemtype 'PVXNUTIL' */
                l_notif_type := wf_engine.GetItemAttrText(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'NOTIFICATION_TYPE' );

                /* Check for Notification Type. It may be 'PG_MEM_EXP' or 'PG_CONTRCT_NRCVD' */
                IF (l_notif_type = 'PG_MEM_EXP' ) THEN
                    /* Get the membership Id from the workflow Itemtype 'PVXNUTIL' */
                    l_mbrship_id := wf_engine.GetItemAttrNumber(
                          ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'MEMBERSHIP_ID' );

                    OPEN c_Check_Memexp_Rmdr_Flg(l_mbrship_id);
                    FETCH c_Check_Memexp_Rmdr_Flg INTO l_rmdr_flag;

                    IF ( l_rmdr_flag = 'Y' ) THEN
                    	 l_end_date:= wf_engine.GetItemAttrDate(
                                         ITEMTYPE => l_itemtype,
                                         ITEMKEY => l_itemkey,
                                         ANAME => 'END_DATE' );
			--l_date_format := 'DD-MON-YYYY';
                        l_expiry_days := to_number(trunc( fnd_date.displaydate_to_date( l_end_date ) - fnd_date.displaydate_to_date( sysdate )));
                        IF  l_expiry_days <0 THEN
                           l_expiry_days := 0;
                        END IF;
                        wf_engine.setItemAttrText
                        (
                           ITEMTYPE   => l_itemtype
                           , ITEMKEY  => l_itemkey
                           , ANAME    => 'MBRSHIP_EXPIRY_IN_DAYS'
                           , AVALUE   =>  to_char(l_expiry_days)
                        );

                        RESULTOUT :=  'COMPLETE:Y';
                        return;
                    END IF; /* End if for l_rmdr_flag check */

                ELSIF (l_notif_type = 'PG_CONTRCT_NRCVD' ) THEN
                /* Get the Enrollment Request Id from the workflow Itemtype 'PVXNUTIL' */
                    l_enrl_req_id  := wf_engine.GetItemAttrNumber(
                        ITEMTYPE => l_itemtype,
                        ITEMKEY => l_itemkey,
                        ANAME => 'ENROLLMENT_REQUEST_ID' );

                    OPEN c_Check_Cnrcvd_Rmdr_Flg(l_enrl_req_id);
                    FETCH c_Check_Cnrcvd_Rmdr_Flg INTO l_rmdr_flag;

                    IF ( l_rmdr_flag = 'Y' ) THEN
                        RESULTOUT :=  'COMPLETE:Y';
                        return;
                    END IF; /* End if for l_rmdr_flag check */
                END IF; /* End IF for l_notif_type Check */
            END IF ; /* End if for l_wait_in_days Check */
        END IF;  /* End If for FUNMODE Check */

        RESULTOUT :=  'COMPLETE:N';

 END check_for_rmdr_notif;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    Prtnr_Prgm_Enrl_notif
--
-- PURPOSE
--  This procedure is called from the Concurrent Request program for sending the
--  Membership Expiry and Signed Contract not received notifications.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE Prtnr_Prgm_Enrl_notif(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2 )
IS
    -- Get all the memberships for which initial expiry notification is to be sent(exclude
    -- the ones FOR which already notifications are sent)

    CURSOR c_get_memberships IS
    	SELECT  mmbr.membership_id,
                mmbr.enrl_request_id,
                mmbr.partner_id,
               (notif_rule.repeat_freq_value * DECODE(notif_rule.repeat_freq_unit, 'PV_DAYS',1,'PV_WEEK', 7,'PV_MONTH', 30)) wait_time_in_days
        FROM    pv_pg_memberships mmbr,
                pv_ge_notif_rules_b notif_rule
        WHERE   mmbr.membership_status_code = 'ACTIVE'
        AND     trunc(mmbr.original_end_date - sysdate) < notif_rule.send_notif_before_value *
                DECODE(notif_rule.send_notif_before_unit, 'PV_DAYS',1,'PV_WEEK', 7,
                                   'PV_MONTH', 30)
        AND     mmbr.program_id = notif_rule.notif_for_entity_id
        AND     notif_rule.arc_notif_for_entity_code = 'PRGM'
        AND     notif_rule.active_flag = 'Y'
        AND     notif_rule.notif_type_code = 'PG_MEM_EXP'
        AND NOT EXISTS
                (   SELECT  1
                    FROM    pv_pg_mmbr_transitions trans,
                            pv_pg_memberships mmbr_future
                    WHERE   trans.from_membership_id = mmbr.membership_id
                    AND     trans.to_membership_id = mmbr_future.membership_id
                    AND     mmbr_future.membership_status_code = 'FUTURE'
                )
        AND NOT EXISTS
                (   SELECT 1
                    FROM pv_ge_party_notifications sent_notif
                    WHERE sent_notif.ARC_NOTIF_FOR_ENTITY_CODE = 'ENRQ'
                    AND sent_notif.NOTIF_FOR_ENTITY_ID = mmbr.enrl_request_id
                    AND sent_notif.notif_type_code = notif_rule.notif_type_code
                    AND sent_notif.partner_id = mmbr.partner_id
                );

    /* Get  all the enrollment requests for which initial signed contract not
       received notification is to be sent(exclude the ones FOR which already
       notifications are sent)*/
    CURSOR c_get_enrollment_requests IS
        SELECT  enrq.enrl_request_id,
                enrq.partner_id,
                notif_rule.repeat_freq_value*
                    DECODE(notif_rule.repeat_freq_unit, 'PV_DAYS',1,
                                    'PV_WEEK', 7,
                                    'PV_MONTH', 30) "wait_time_in_days"
        FROM    pv_pg_enrl_requests enrq,
                pv_ge_notif_rules_b notif_rule
        WHERE   enrq.contract_status_code = 'AWAITING_FAX_OR_MAIL'
	AND     enrq.request_status_code in ('AWAITING_APPROVAL', 'APPROVED')
        AND     (enrq.request_submission_date -sysdate) < notif_rule.send_notif_after_value *
                    DECODE(notif_rule.send_notif_after_unit, 'PV_DAYS',1,
                                    'PV_WEEK', 7,
                                    'PV_MONTH', 30)
        AND     enrq.program_id = notif_rule.notif_for_entity_id
        AND     notif_rule.arc_notif_for_entity_code = 'PRGM'
        AND     notif_rule.active_flag = 'Y'
        AND     notif_rule.notif_type_code = 'PG_CONTRCT_NRCVD'
        AND NOT EXISTS
        (   SELECT  1
            FROM    pv_ge_party_notifications sent_notif
            WHERE   sent_notif.ARC_NOTIF_FOR_ENTITY_CODE = 'ENRQ'
            AND     sent_notif. NOTIF_FOR_ENTITY_ID = enrq.enrl_request_id
            AND     sent_notif.notif_type_code = notif_rule.notif_type_code
            AND     sent_notif.partner_id = enrq.partner_id);

    /* Declaration of Local variables. */

    l_mbrship_id                NUMBER;
    l_enrl_request_id           NUMBER;
    l_wait_time_in_days         NUMBER;
    l_partner_id                NUMBER;
    l_itemtype                  VARCHAR2(240) := 'PVXNUTIL';
    l_itemkey                   VARCHAR2(240);

    p_debug_mode                VARCHAR2(1);
    l_status                    BOOLEAN;
    x_return_status VARCHAR2(1);
    x_msg_count   NUMBER;
    x_msg_data      VARCHAR2(240);
    p_api_version_number        CONSTANT NUMBER       := 1.0;
    p_init_msg_list               VARCHAR2(100)     := FND_API.G_FALSE;
    p_commit                    VARCHAR2(100)     := FND_API.G_FALSE;
    p_validation_level           NUMBER       := FND_API.G_VALID_LEVEL_FULL;

BEGIN


    /* *** Send membership expiry notification Start *** */
    Write_log (1, '*** Send membership expiry notification Start ***');

    /* Process all the Membership expiry records selected in c_get_memberships Cursor */

     OPEN c_get_memberships;
     LOOP
         FETCH c_get_memberships INTO l_mbrship_id,l_enrl_request_id,l_partner_id, l_wait_time_in_days ;

         IF ( c_get_memberships%NOTFOUND) THEN
             Close c_get_memberships;
             exit;
         END IF;
         PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
         (
            p_api_version_number    => p_api_version_number
            , p_init_msg_list       => p_init_msg_list
            , p_commit              => p_commit
            , p_validation_level    => p_validation_level
            , p_context_id          => l_partner_id
	    , p_context_code        => 'PARTNER'
            , p_target_ctgry        => 'PARTNER'
            , p_target_ctgry_pt_id  => l_partner_id
            , p_notif_event_code    => 'PG_MEM_EXP'
            , p_entity_id           => l_enrl_request_id
	    , p_entity_code         => 'ENRQ'
            , p_wait_time           => l_wait_time_in_days
            , x_return_status       => x_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
         );

    END LOOP;

    IF c_get_memberships%ISOPEN THEN
    	CLOSE c_get_memberships;
    END IF;

    /* *** Send membership expiry notification End *** */

    /* *** Send Signed Contract Copy not received notification Start *** */
     OPEN c_get_enrollment_requests;
     LOOP
         FETCH c_get_enrollment_requests INTO l_enrl_request_id, l_partner_id,l_wait_time_in_days ;

         IF ( c_get_enrollment_requests%NOTFOUND) THEN
             Close c_get_enrollment_requests;
             exit;
         END IF;
		 PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
         (
            p_api_version_number    => p_api_version_number
            , p_init_msg_list       => p_init_msg_list
            , p_commit              => p_commit
            , p_validation_level    => p_validation_level
            , p_context_id          => l_partner_id
	    , p_context_code        => 'PARTNER'
            , p_target_ctgry        => 'PARTNER'
            , p_target_ctgry_pt_id  => l_partner_id
            , p_notif_event_code    => 'PG_CONTRCT_NRCVD'
            , p_entity_id           => l_enrl_request_id
	    , p_entity_code         => 'ENRQ'
            , p_wait_time           => l_wait_time_in_days
            , x_return_status       => x_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
         );


    END LOOP;

    IF c_get_enrollment_requests%ISOPEN THEN
    	CLOSE c_get_enrollment_requests;
    END IF;

    /* *** Send Signed Contract Copy not received notification End *** */
    COMMIT;

    EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ERRBUF := ERRBUF || sqlerrm;
             RETCODE := FND_API.G_RET_STS_ERROR;
             ROLLBACK ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Error in PV_PG_NOTIF_UTILITY_PVT.Prtnr_Prgm_Enrl_notif');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Unexpected error in Error in PV_PG_NOTIF_UTILITY_PVT.Prtnr_Prgm_Enrl_notif');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
         WHEN OTHERS THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := '2';
             ROLLBACK  ;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Other error in Error in PV_PG_NOTIF_UTILITY_PVT.Prtnr_Prgm_Enrl_notif');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
END Prtnr_Prgm_Enrl_notif;

/*============================================================================
-- Start of Comments
-- PROCEDURE
--    Expire_Memberships
--
-- PURPOSE
--  This procedure updates the membership status either to EXPIRE or RENEW based
--  on the status criteria.
--
-- Called By
-- NOTES
-- End of Comments
============================================================================*/
PROCEDURE Expire_Memberships(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2 )
IS
    /* Concurrent Program for expiring or renewing the memberships:
     Get all the memberships to be expired - for which there are no
     early renewals or renewals. */
    CURSOR c_get_expired_memberships IS
        SELECT mmbr.membership_id membership_id
               , mmbr.partner_id
               , mmbr.object_version_number
        FROM pv_pg_memberships mmbr
        WHERE mmbr.membership_status_code = 'ACTIVE'
        AND trunc(SYSDATE - mmbr.original_end_date) >=  1
        AND NOT EXISTS
            (   SELECT 1
                FROM pv_pg_mmbr_transitions trans,
                     pv_pg_memberships mmbr_future
                WHERE trans.from_membership_id = mmbr.membership_id
                AND trans.to_membership_id = mmbr_future.membership_id
                AND mmbr_future.membership_status_code = 'FUTURE'  ) ;


    CURSOR   c_get_status(mmbr_id NUMBER) IS
    SELECT   membership_status_code
    FROM     pv_pg_memberships
    WHERE    membership_id=mmbr_id;

    -- Get all the memberships to be renewed for early renewals cases.
    CURSOR  c_get_renew_memberships IS
        SELECT  mmbr.membership_id current_membership_id,
                mmbr_future.membership_id future_membership_id,
                mmbr.partner_id,
	        mmbr.object_version_number,
	        mmbr_future.object_version_number future_memb_obj_ver_no
        FROM    pv_pg_memberships mmbr,
                pv_pg_memberships mmbr_future,
                pv_pg_mmbr_transitions trans
        WHERE   mmbr.membership_status_code = 'ACTIVE'
        --AND     trunc(SYSDATE - mmbr.original_end_date) >=  1
        AND     mmbr.original_end_date <=  trunc(SYSDATE -1 )
        AND     trans.from_membership_id = mmbr.membership_id
        AND     trans.to_membership_id = mmbr_future.membership_id
        AND     mmbr_future.membership_status_code = 'FUTURE';

        CURSOR c_getptrprgm(memb_id NUMBER) IS
        SELECT  distinct party.party_name, prgm.program_name
        FROM   hz_parties party
        , pv_partner_profiles prof
        , pv_pg_memberships memb
        , pv_partner_program_vl prgm
        WHERE  prof.status = 'A'
        AND   prof.partner_party_id = party.party_id
        AND    memb.partner_id = prof.partner_id
        AND    memb.membership_id = memb_id
        AND    memb.program_id=prgm.program_id;

        /* Declaration of local variables. */
        l_return_status     VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        l_status                    BOOLEAN;
        l_log_params_tbl PVX_UTILITY_PVT.log_params_tbl_type;
        l_membership_id     NUMBER;
        l_obj_version_no     NUMBER;
        l_current_mbrship_id   NUMBER;
        l_future_mbrship_id    NUMBER;
        x_return_status VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        x_msg_count   NUMBER;
        x_msg_data      VARCHAR2(4000);
        l_memb_rec  PV_Pg_Memberships_PVT.memb_rec_type;
        l_membership_status VARCHAR2(30);
	l_partner_name  VARCHAR2(360);
	l_program_name  VARCHAR2(60);
	l_index                  number;

BEGIN

    /*  Standard Start of API savepoint */
    SAVEPOINT Expire_Memberships;

    /* Logic to update the membership status to EXPIRE for all the EXPIRED members */
    Write_log (1, 'Updating the Membership Status to EXPIRED  -');
    FOR l_get_expire_memberships_rec IN c_get_expired_memberships
    LOOP
       /*  call update table handler for pv_pg_memberships by passing
           membership_status_code = 'EXPIRED', actual_end_date as sysdate */
       /*l_memb_rec.membership_id := l_get_expire_memberships_rec.membership_id;
       l_memb_rec.membership_status_code := 'EXPIRED';
       l_memb_rec.actual_end_date := sysdate;
       l_memb_rec.object_version_number := l_get_expire_memberships_rec.object_version_number;
       Write_log (1,'Membership Id :'||l_memb_rec.membership_id);
       PV_Pg_Memberships_PVT.Update_Pg_Memberships(
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count ,
           x_msg_data            => x_msg_data ,
           p_memb_rec            => l_memb_rec  );
       */
       /** making changes for 11.5.10 by pukken. since we need to take care of prereqs and subsidiary memberships
           call terminate membership api with event code as EXPIRED
           Before calling the api, check for membership status once again,
           because of the first terminate_membership call in this loop
           could have expired the next membership id in the loop. so query for the status again
       */
       l_membership_status := null;
       OPEN c_get_status( l_get_expire_memberships_rec.membership_id ) ;
          FETCH c_get_status INTO l_membership_status;
       CLOSE c_get_status;
       IF l_membership_status='ACTIVE' THEN
       	  Write_log (1,'Before calling expire api for Membership Id :'|| l_get_expire_memberships_rec.membership_id);
       	  SAVEPOINT Terminate_membership;
       	  PV_Pg_Memberships_PVT.Terminate_membership
          (
             p_api_version_number         =>1.0
             , p_init_msg_list            => FND_API.g_true
             , p_commit                   => FND_API.G_FALSE
             , p_validation_level         => FND_API.g_valid_level_full
             , p_membership_id            => l_get_expire_memberships_rec.membership_id
             , p_event_code               => 'EXPIRED'
             , p_memb_type                => NULL
             , p_status_reason_code       => 'EXPIRED_BY_SYSTEM'
             , p_comments                 => NULL
             , x_return_status            => x_return_status
             , x_msg_count                => x_msg_count
             , x_msg_data                 => x_msg_data
          );

          /* Check for x_return_status */

          IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             Write_log (1,'Expired Membership id'|| l_get_expire_memberships_rec.membership_id || 'with Status as :' ||x_return_status);
          ELSE
             OPEN c_getptrprgm(l_get_expire_memberships_rec.membership_id);
                FETCH c_getptrprgm INTO l_partner_name,l_program_name;
             CLOSE c_getptrprgm;
             Write_log (1,'Error expiring membership in program:'||l_program_name||'for  partner: ' || l_partner_name|| 'with Status as :'||x_return_status || 'with error message as: ' || x_msg_data );

             for I in 1 .. x_msg_count LOOP
                fnd_msg_pub.Get
                (  p_msg_index      => FND_MSG_PUB.G_NEXT
                   ,p_encoded        => FND_API.G_FALSE
                   ,p_data           => x_msg_data
                   ,p_msg_index_out  => l_index
                );
                Write_log (1,x_msg_data);
             end loop;
             Write_log (1,'End of error stack  for expiring membership in the program'|| l_program_name|| 'for the partner' || l_partner_name );
             ROLLBACK to Terminate_membership;
          END IF;

       END IF;
    END LOOP;
    Write_log (1, 'Finished Updating the Membership Status to EXPIRED');

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Pick all the memberships to be renewed. */
    Write_log (1, 'Updating the Membership Status to RENEW for following members -');

    FOR l_get_renew_memberships_rec IN c_get_renew_memberships LOOP
        -- call update API for pv_pg_memberships by passing
	-- membership_status_code = 'RENEWED', actual_end_date as sysdate
   	-- for membership_id = l_get_renew_memberships_rec.current_membership_id
        l_memb_rec.membership_id := l_get_renew_memberships_rec.current_membership_id;
        l_memb_rec.membership_status_code := 'RENEWED';
        l_memb_rec.actual_end_date := sysdate;
        l_memb_rec.object_version_number := l_get_renew_memberships_rec.object_version_number;

        Write_log (1,'Before Changing to Renewed status for Membership Id :'||l_memb_rec.membership_id);
        SAVEPOINT renew_membership;

        PV_Pg_Memberships_PVT.Update_Pg_Memberships(
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_TRUE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count ,
            x_msg_data            => x_msg_data ,
            p_memb_rec            => l_memb_rec  );

        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             Write_log (1,'Renewed Membership Status : '||x_return_status);
        ELSE
             OPEN c_getptrprgm(l_memb_rec.membership_id);
                FETCH c_getptrprgm INTO l_partner_name,l_program_name;
             CLOSE c_getptrprgm;
             Write_log (1,'Error in renewing membership in program :'|| l_program_name|| ' for partner: ' || l_partner_name || ' with status as: ' || x_return_status || ' and error message is:  ' || x_msg_data );
             for I in 1 .. x_msg_count LOOP
                fnd_msg_pub.Get
                (  p_msg_index      => FND_MSG_PUB.G_NEXT
                   ,p_encoded        => FND_API.G_FALSE
                   ,p_data           => x_msg_data
                   ,p_msg_index_out  => l_index
                );
                Write_log (1,x_msg_data);
             end loop;
             Write_log (1,'End of error stack  for renewing membership in the program: '|| l_program_name|| ' for the partner: ' || l_partner_name );
             ROLLBACK to renew_membership;
        END IF;



        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
           -- call update API for pv_pg_memberships by passing
   	   -- membership_status_code = 'ACTIVE',
           -- for membership_id = l_get_renew_memberships_rec.future_membership_id
           l_memb_rec.membership_id := l_get_renew_memberships_rec.future_membership_id;
           l_memb_rec.membership_status_code := 'ACTIVE';
           l_memb_rec.object_version_number := l_get_renew_memberships_rec.future_memb_obj_ver_no;
           Write_log (1,'Before Changing to Active status for Membership Id :'||l_memb_rec.membership_id);
           PV_Pg_Memberships_PVT.Update_Pg_Memberships(
               p_api_version_number => 1.0,
               p_init_msg_list      => FND_API.G_FALSE,
               p_commit             => FND_API.G_FALSE,
               p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count ,
               x_msg_data           => x_msg_data ,
               p_memb_rec           => l_memb_rec  );

              IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                Write_log (1,'Activated Membership Status  :'||x_return_status);
              ELSE
                OPEN c_getptrprgm(l_memb_rec.membership_id);
                   FETCH c_getptrprgm INTO l_partner_name,l_program_name;
                CLOSE c_getptrprgm;
                Write_log (1,'Error activating membership in program '|| l_program_name|| ' for  partner ' || l_partner_name ||' with status as ' || x_return_status || ' and the error message is  ' || x_msg_data );
                for I in 1 .. x_msg_count LOOP
                   fnd_msg_pub.Get
                   (  p_msg_index      => FND_MSG_PUB.G_NEXT
                      ,p_encoded        => FND_API.G_FALSE
                      ,p_data           => x_msg_data
                      ,p_msg_index_out  => l_index
                   );
                   Write_log (1,x_msg_data);
                end loop;
                Write_log (1,'End of error stack  for activating membership in the program: '|| l_program_name|| ' for the partner: ' || l_partner_name );
                ROLLBACK to renew_membership;
             END IF;
        END IF;



        -- We may need to call the activate_contract_api,  here. -- will let you know very soon which API needs to go here.

        -- call transaction history log to record this log.
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
           /* Set the log params for History log. */
               l_log_params_tbl(1).param_name := 'MBRSHIP_RENEW_DT';
               l_log_params_tbl(1).param_value := to_char(sysdate);
               l_log_params_tbl(2).param_name := 'CURRENT_MBRSHIP_ID';
               l_log_params_tbl(2).param_value := l_get_renew_memberships_rec.current_membership_id;
               l_log_params_tbl(3).param_name := 'FUTURE_MBRSHIP_ID';
               l_log_params_tbl(3).param_value := l_get_renew_memberships_rec.future_membership_id;

           /* call transaction history log to record this log. */
            Write_log (1,'Before Creating History Log for '|| l_get_renew_memberships_rec.current_membership_id );
            PVX_UTILITY_PVT.create_history_log
               (
                  p_arc_history_for_entity_code   => 'MEMBERSHIP'
                  , p_history_for_entity_id       => l_get_renew_memberships_rec.current_membership_id
                  , p_history_category_code       => 'ENROLLMENT'
                  , p_message_code                => 'PV_MEMBERSHIP_RENEWED'
                  , p_comments                    => null
                  , p_partner_id                  => l_get_renew_memberships_rec.partner_id
                  , p_access_level_flag           => 'P'
                  , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
                  , p_log_params_tbl              => l_log_params_tbl
                  , p_init_msg_list               => FND_API.g_false
                  , p_commit                      => FND_API.G_FALSE
                  , x_return_status               => x_return_status
                  , x_msg_count                   => x_msg_count
                  , x_msg_data                    => x_msg_data
               );

               IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                  Write_log (1,'Creating History Log '||x_return_status);
               ELSE
                   OPEN c_getptrprgm(l_get_renew_memberships_rec.current_membership_id);
                      FETCH c_getptrprgm INTO l_partner_name,l_program_name;
                   CLOSE c_getptrprgm;
                   Write_log (1,'Error Creating Enrollment Log for program: '|| l_program_name|| ' for partner ' || l_partner_name || ' with status as ' || x_return_status || ' and error message is ' || x_msg_data );
                   for I in 1 .. x_msg_count LOOP
                      fnd_msg_pub.Get
                      (  p_msg_index      => FND_MSG_PUB.G_NEXT
                         ,p_encoded        => FND_API.G_FALSE
                         ,p_data           => x_msg_data
                         ,p_msg_index_out  => l_index
                      );
                      Write_log (1,x_msg_data);
                   end loop;
                   Write_log (1,'End of error stack  in creating history log' );
                   ROLLBACK to renew_membership;
                END IF;
            END IF;
       END LOOP;

EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ERRBUF := ERRBUF || sqlerrm;
             RETCODE := FND_API.G_RET_STS_ERROR;
             ROLLBACK TO Expire_Memberships;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Error in Updating Membership Status(PV_PG_NOTIF_UTILITY_PVT.Expire_Memberships)');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK TO Expire_Memberships;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Unexpected error in in Updating Membership Status(PV_PG_NOTIF_UTILITY_PVT.Expire_Memberships)');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
         WHEN OTHERS THEN
             ERRBUF := ERRBUF||sqlerrm;
             RETCODE := '2';
             ROLLBACK TO Expire_Memberships;
             l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
             Write_log (1, 'Other error in in Updating Membership Status(PV_PG_NOTIF_UTILITY_PVT.Expire_Memberships)');
             Write_log (1, 'SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || substr(SQLERRM, 1, 100));
 END Expire_Memberships;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   get_Notification_Body
   --
   -- PURPOSE
   --   Gets Notification Body in HTML from Workflow.
   -- IN
   --   notification_id NUMBER
   -- OUT
   --   Notification body in HTML
   -- USED BY
   --   Notifications Detail screen from partner portal
   -- HISTORY
   --   12/05/2002  sveerave  CREATION
   --   03/25/2003  sveerave  Modified from GetFullBody to GetBody as
   --                         GetFullBody is failing to get full message body for bug#2862626
   --------------------------------------------------------------------------
FUNCTION get_Notification_Body(p_notif_id IN NUMBER)
RETURN VARCHAR2 IS
  l_msgBody VARCHAR2(4000);
  --l_flag BOOLEAN DEFAULT FALSE;

BEGIN
  /*
  WF_NOTIFICATION.GetFullBody(  nid         => p_notif_id
                              , msgbody     => l_msgBody
                              , end_of_body => l_flag
                              , disptype    => l_disptype
                              );
  */
  l_msgBody :=  WF_NOTIFICATION.getBody(  nid      => p_notif_id
                                        , disptype => wf_notification.doc_html
                                        );
  RETURN l_msgBody;
END  get_Notification_Body;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   set_msg_doc
   --
   -- PURPOSE
   --   Sets Message Document for PL/SQL Document.
   -- IN -- as per PL/SQL Notification Document stadards
   --   document_id     IN       VARCHAR2
   --   display_type    IN       VARCHAR2
   --
   -- OUT
   --   document        IN OUT NOCOPY   VARCHAR2
   --   document_type   IN OUT NOCOPY   VARCHAR2   -- USED BY

   -- HISTORY
   --   08/04/2003        sveerave        CREATION
   --------------------------------------------------------------------------

  PROCEDURE set_msg_doc (
        document_id     IN       VARCHAR2
      , display_type    IN       VARCHAR2
      , document        IN OUT NOCOPY   VARCHAR2
      , document_type   IN OUT NOCOPY   VARCHAR2
  ) IS
    l_api_name           VARCHAR2 (61) :=  g_pkg_name || 'set_msg_doc';
    l_notif_id  NUMBER;

  BEGIN

    ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
    );

    l_notif_id := TO_NUMBER(SUBSTR(document_id,10)); --'PVXNUTIL:';
    document := document || wf_notification.getAttrText(l_notif_id,'MESSAGE_HEADER');
    document := document ||'<BR>'||wf_notification.getAttrText(l_notif_id,'MESSAGE_BODY');
    document := document ||'<BR>'||wf_notification.getAttrText(l_notif_id,'MESSAGE_FOOTER');

    document_type              := wf_notification.doc_html;
--    document                   := document || g_message_body_doc;
    RETURN;
  END set_msg_doc;


PROCEDURE set_event_code
(
   itemtype  IN     VARCHAR2
   , itemkey   IN     VARCHAR2
   , actid     IN     NUMBER
   , funcmode  IN     VARCHAR2
   , resultout    OUT NOCOPY   VARCHAR2
)
IS


l_api_name     CONSTANT VARCHAR2(30) := 'SET_EVENT_CODE';
l_event_code   VARCHAR2(30) ;
BEGIN

   l_event_code := WF_ENGINE.GetItemAttrText (
                               itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'PARTNER_EVENT_CODE'
                              );



   PVX_UTILITY_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN
         resultout  := 'COMPLETE:' ||l_event_code  ;
         RETURN;
   ELSIF (funcmode = 'CANCEL') THEN
      resultout  := 'COMPLETE:' ;
      RETURN;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      resultout  := 'COMPLETE:' ;
      RETURN;
   END IF;

   PVX_UTILITY_PVT.debug_message (L_API_NAME || ' - RESULT: ' || resultout);

 -- write to log
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      wf_core.context(G_PKG_NAME,'set_event_code', itemtype,itemkey,to_char(actid),funcmode);
      resultout := 'COMPLETE:' ;
      raise;

END set_event_code;

FUNCTION getUserIdTbl( val IN VARCHAR2 )
RETURN JTF_NUMBER_TABLE
IS

n NUMBER;
y NUMBER:=1;
x VARCHAR2(30);
l_value VARCHAR2(2000);
l_user_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
ct NUMBER:=1;

BEGIN
   l_value :=val;
   LOOP
      n := instr( l_value, ',' );
      x := substr(l_value,1,n-1);
      l_value:=substr(l_value,n+1);
      l_user_id_tbl.extend(1);
      IF n>0 THEN
         l_user_id_tbl(ct) :=to_number(x);
      ELSE
      	 l_user_id_tbl(ct) :=to_number(l_value);
      END IF;
      ct:=ct+1;
      EXIT WHEN n=0;
   END LOOP;
   RETURN l_user_id_tbl;
END  getUserIdTbl;



PROCEDURE log_action
(
   itemtype     IN     VARCHAR2
   , itemkey    IN     VARCHAR2
   , actid      IN     NUMBER
   , funcmode   IN     VARCHAR2
   , resultout  OUT NOCOPY   VARCHAR2
) IS


L_API_NAME       CONSTANT VARCHAR2(30) := 'log_action';
l_object_id       NUMBER;
l_object_type     VARCHAR2(30);
l_approver_id     NUMBER;
l_flag            VARCHAR2(1);
l_event_code       VARCHAR2(30);
l_notification_id  NUMBER;
l_pgp_notif_rec    PV_GE_PARTY_NOTIF_PVT.pgp_notif_rec_type ;
x_party_notifid    NUMBER;
l_partner_id       NUMBER;
l_entity_id        NUMBER;
l_entity_code      VARCHAR2(30);
l_user_id          VARCHAR2(2000);
l_user_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
x_return_status    VARCHAR2(1);
x_msg_count        NUMBER;
x_msg_data         VARCHAR2(4000);

BEGIN

   l_notification_id := wf_engine.context_nid;

   IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   END IF;



   l_event_code := WF_ENGINE.GetItemAttrText
                   (
                      itemtype   =>   itemtype
                      , itemkey    =>   itemkey
                      , aname      =>   'PARTNER_EVENT_CODE'
                   );

    l_partner_id := WF_ENGINE.GetItemAttrText
                   (
                      itemtype   =>   itemtype
                      , itemkey    =>   itemkey
                      , aname      =>   'PARTNER_ID'
                   );

    l_user_id := WF_ENGINE.GetItemAttrText
                   (
                      itemtype   =>   itemtype
                      , itemkey    =>   itemkey
                      , aname      =>   'RECIPIENT_USER_ID'
                   );

    l_entity_code := WF_ENGINE.GetItemAttrText
                   (
                      itemtype   =>   itemtype
                      , itemkey    =>   itemkey
                      , aname      =>   'ENTITY_CODE'
                   );

    l_entity_id := WF_ENGINE.GetItemAttrNumber
                   (
                      itemtype   =>   itemtype
                      , itemkey    =>   itemkey
                      , aname      =>   'ENTITY_ID'
                   );


   IF  l_notification_id is not  null THEN
      l_user_id_tbl:=getUseridTbl(l_user_id);
      for i in 1..l_user_id_tbl.count() loop
         Set_Pgp_Notif(
                   p_notif_id            	=> l_notification_id,
                   p_object_version      	=> 1,
                   p_partner_id  	        => l_partner_id ,
                   p_user_id            	=> l_user_id_tbl(i),
                   p_arc_notif_for_entity_code  =>l_entity_code,
                   p_notif_for_entity_id        => l_entity_id,
                   p_notif_type_code     	=> l_event_code,
                   x_return_status      	=> x_return_status ,
                   x_pgp_notif_rec      	=>  l_pgp_notif_rec
         );


         /* Check the Procedure's x_return_status */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               FND_MESSAGE.SET_NAME('PV','PV_SET_NOTIF_REC');
               FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notification_id);
               FND_MSG_PUB.Add;
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
         END IF;


         /* Call the Create_Ge_Party_Notif to insert a record in PV_GE_PARTY_NOTIFICATIONS   */
         PV_GE_PARTY_NOTIF_PVT.Create_Ge_Party_Notif (
             p_api_version_number    => 1.0,
             p_init_msg_list         => FND_API.G_FALSE ,
             p_commit                => FND_API.G_FALSE ,
             p_validation_level      => FND_API.G_VALID_LEVEL_FULL   ,
             x_return_status         => x_return_status ,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data ,
             p_pgp_notif_rec         => l_pgp_notif_rec,
             x_party_notification_id => x_party_notifid
         );

         /* Check the Procedure's x_return_status */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             FND_MESSAGE.SET_NAME('PV','PV_GE_PARTY_NOTIF_REC');
             FND_MESSAGE.SET_TOKEN('NOTIFICATION_ID',l_notification_id);
             FND_MSG_PUB.Add;
             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF;
      END LOOP;
      resultout  := 'COMPLETE:';
      --commit;
      RETURN;
   END IF;
   resultout  := 'COMPLETE:';
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message(L_API_NAME || ' - RESULT: ' || resultout);

   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      --write_to_enrollment_log
      wf_core.context(G_PKG_NAME,'log_action', itemtype,itemkey,to_char(actid),funcmode);
      resultout := 'COMPLETE:' ;
      raise;

END log_action ;


--------------------------------------------------------------------------
-- PROCEDURE
--   Send_Workflow_Notification
--
-- PURPOSE
--   to start the workflow process that sends notifications
-- IN
--    , p_context_id          IN  NUMBER
--         this could be partner_id, vendor id , depending on the context you are in
--    , p_context_code        IN  VARCHAR2
--         who is senting the notification validated against PV_ENTITY_TYPE
--    , p_target_ctgry        IN  VARCHAR
--         to whom the notification be sent 'PARTNER', 'VAD', 'GLOBAL', 'SUBSIDIARY' validated against pv_entity_notif_category
--    , p_target_ctgry_pt_id  IN  NUMBER
--         pass partner_id of the partner to whom notifiction needs to be sent,
--    , p_notif_event_code    IN  VARCHAR
--         the event due to which this is being called validated against PV_NOTIFICATION_EVENT_TYPE
--    , p_entity_id           IN  NUMBER
--         if the notification is related to program enrollment pass enrl_request_id.
--         else pass corressponfing entity ids depending on what entity you are sending the notification for
--    , p_entity_code         IN  VARCHAR2
--         pass 'ENRQ' for enrollment related, PARTNER for partner related
--         like member type change, INVITE incase of inviations related. validated against PV_ENTITY_TYPE
--    , p_wait_time           IN  NUMBER
--         wait time in days after which the reminder needs to be sent pass zero if no reminder is to be sent

-- HISTORY
--   10-Oct-2003  pukken  CREATION

--------------------------------------------------------------------------
PROCEDURE Send_Workflow_Notification
(
   p_api_version_number    IN  NUMBER
   , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_context_id          IN  NUMBER
   , p_context_code        IN  VARCHAR2
   , p_target_ctgry        IN  VARCHAR
   , p_target_ctgry_pt_id  IN  NUMBER
   , p_notif_event_code    IN  VARCHAR
   , p_entity_id           IN  NUMBER
   , p_entity_code         IN  VARCHAR2
   , p_wait_time           IN  NUMBER
   , x_return_status       OUT NOCOPY  VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
) IS

   l_api_name               CONSTANT VARCHAR2(30) := 'Send_Workflow_Notification';
   l_itemType		    CONSTANT VARCHAR2(30) :='PVXNUTIL' ;
   l_api_version_number     CONSTANT NUMBER       := 1.0;
   l_itemKey		    VARCHAR2(80) := p_target_ctgry_pt_id || p_target_ctgry ;
   l_notify_type            VARCHAR2(20);
   l_pt_role_list           wf_directory.usertable;
   l_notif_user_id          VARCHAR2(2000);
   l_pt_adhoc_role          VARCHAR2(80);
   l_role_disp_name         VARCHAR2(80);
   l_prtner_portal_url      VARCHAR2(4000);
   l_login_url              VARCHAR2(4000);
   l_send_respond_url       VARCHAR2(500);
   l_vendor_org_name        VARCHAR2(50);
   l_email_enabled          VARCHAR2(5);
   l_lookup_exists          VARCHAR2(1);
   l_entity_code            VARCHAR2(30);
   l_notif_rule_active      VARCHAR2(1):='Y';
   l_partner_program        VARCHAR2(240);
   l_to_partner_program     VARCHAR2(240);
   l_enrollment_duration    VARCHAR2(240);
   l_enrollment_type        VARCHAR2(240);
   l_source_name            VARCHAR2(360);
   l_requestor_name         VARCHAR2(360);
   l_user_name              VARCHAR2(100);
   l_vendor_name            VARCHAR2(360);
   l_partner_comp_name      VARCHAR2(360);
   l_event_meaning          VARCHAR2(80);
   l_string                 VARCHAR2(1000);
   l_date_format            VARCHAR2(50);
   l_entity_id              NUMBER;
   l_notif_targeted_ptr_id  NUMBER; -- partner_id to whom the notification is targeted to.
   l_user_count             NUMBER;
   l_partner_id             NUMBER;
   l_expiry_days            NUMBER;
   l_enrl_request_id        NUMBER;
   l_req_resource_id        NUMBER;
   l_partner_program_id     NUMBER;
   l_prtnr_vndr_relship_id  NUMBER;
   l_user_id                NUMBER;
   --l_notif_user_id        NUMBER;
   l_vendor_party_id        NUMBER;
   l_partner_party_id       NUMBER;
   l_membership_id          NUMBER;
   l_start_date             DATE;
   l_end_date               DATE;
   l_req_submission_date    DATE;
   x_user_notify_rec_tbl    user_notify_rec_tbl_type;
   l_val NUMBER;
   CURSOR c_prgm_csr ( prgm_id NUMBER ) IS
   SELECT program_name
   FROM   pv_partner_program_vl
   WHERE  program_id=prgm_id;

   CURSOR c_inv_csr ( inv_hdr_id NUMBER ) IS
   SELECT prgm.program_name
   FROM   PV_PG_INVITE_HEADERS_b inv
          , pv_partner_program_vl prgm
   WHERE  inv.invite_header_id=inv_hdr_id
   AND    inv.invite_for_program_id =prgm.program_id;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;


   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   SELECT  PV_LEAD_WORKFLOWS_S.nextval
    INTO    l_val
    FROM    dual;
    l_itemKey  :=  l_itemKey || l_val;
   -- check for null
   /**
   IF (  p_context_code  = FND_API.G_MISS_CHAR OR   p_context_code IS NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', p_context_code);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (  p_target_ctgry  = FND_API.G_MISS_CHAR OR   p_target_ctgry IS NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', p_target_ctgry);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (  p_entity_code  = FND_API.G_MISS_CHAR OR   p_entity_code IS NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', p_entity_code);
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF (  p_notif_event_code  = FND_API.G_MISS_CHAR OR   p_notif_event_code IS NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', p_notif_event_code);
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   */
   --validate the lookupcode for target category
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type       => 'PV_ENTITY_NOTIF_CATEGORY'
                         ,p_lookup_code       => p_target_ctgry
                       );

   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE','PV_ENTITY_NOTIF_CATEGORY' );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_target_ctgry  );
      fnd_msg_pub.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    --validate the lookupcode for event
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type       => 'PV_NOTIFICATION_EVENT_TYPE'
                         ,p_lookup_code       => p_notif_event_code
                       );
   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE','PV_NOTIFICATION_EVENT_TYPE' );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_notif_event_code  );
      fnd_msg_pub.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    --validate the lookupcodfe for entity code
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type       => 'PV_ENTITY_TYPE'
                         ,p_lookup_code       => p_entity_code
                       );
   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE','PV_ENTITY_TYPE' );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_entity_code );
      fnd_msg_pub.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --validate the lookup for context code
   /**
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type       => 'PV_ENTITY_TYPE'
                         ,p_lookup_code       => p_context_code
                       );
   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE','PV_ENTITY_TYPE' );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_context_code );
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   */
   IF p_entity_code IN ( 'GLOBAL', 'SUBSIDIARY', 'STANDARD' ) THEN
      l_entity_code := 'PARTNER';
   ELSE
      l_entity_code := p_entity_code;
   END IF;

   /* Invoke validation procedures
      validate p_context_id, if context_code is anything other than VENDOR
   */
   IF p_context_code <>  'VENDOR' THEN
      Validate_Enrl_Requests
      (  p_context_id
       , p_context_code || '_ID'
       , x_return_status
       );
      /* If any errors happen abort API. */
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   Validate_Enrl_Requests
   (  p_target_ctgry_pt_id
    , p_target_ctgry || '_ID'
    , x_return_status
    );
   /* If any errors happen abort API. */
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_notif_targeted_ptr_id:=  p_target_ctgry_pt_id ;

   Validate_Enrl_Requests
   (  p_entity_id
    , 'ENTITY_ID'
    , x_return_status
    );
   /* If any errors happen abort API. */
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF   p_entity_code = 'ENRQ' THEN
       /* Get the enrollment request details */
       get_enrl_memb_details(
           p_enrl_request_id       =>  p_entity_id  ,
           x_req_submission_date   =>  l_req_submission_date,
           x_partner_program_id    =>  l_partner_program_id,
           x_partner_program       =>  l_partner_program,
           x_enrollment_duration   =>  l_enrollment_duration,
           x_enrollment_type       =>  l_enrollment_type,
           x_req_resource_id       =>  l_req_resource_id,
           x_prtnr_vndr_relship_id =>  l_prtnr_vndr_relship_id,
           x_start_date            =>  l_start_date,
           x_end_date              =>  l_end_date,
           x_membership_id         =>  l_membership_id,
           x_return_status         =>  x_return_status);


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
   	    FND_MESSAGE.SET_NAME('PV', 'PV_ENRL_REQ_NOT_EXIST');
   	    FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_entity_id);
   	    FND_MSG_PUB.Add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;




      /* Get the Partner and Vendor details */
      get_prtnr_vendor_details(
        p_enrl_request_id       =>  p_entity_id  ,
        x_vendor_party_id       =>  l_vendor_party_id,
        x_vendor_name           =>  l_vendor_name,
        x_partner_party_id      =>  l_partner_party_id,
        x_partner_comp_name     =>  l_partner_comp_name,
        x_return_status         =>  x_return_status
      );

      /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
         FND_MESSAGE.SET_TOKEN('ENRL_REQUEST_ID',p_entity_id);
         FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;


      /* Get the requestor details */
      get_requestor_details(
        p_req_resource_id       =>  l_req_resource_id,
        x_user_id               =>  l_user_id,
        x_source_name           =>  l_source_name,
        x_user_name             =>  l_user_name,
        x_return_status         =>  x_return_status
      );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         FND_MESSAGE.SET_NAME('PV','PV_REQUESTOR_NOT_EXIST');
         FND_MESSAGE.SET_TOKEN('REQ_RESOURCE_ID',l_req_resource_id);
         FND_MSG_PUB.Add;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      l_notif_rule_active := check_Notif_Rule_Active
                             (
	  		        p_program_id => l_partner_program_id
                                , p_notif_type => p_notif_event_code
                              ) ;


   END IF;

   IF l_notif_rule_active= 'N' THEN

      return;
   END IF;

   /* Get the user list */
   get_users_list
   (
      p_partner_id            =>  l_notif_targeted_ptr_id
      , x_user_notify_rec_tbl =>  x_user_notify_rec_tbl
      , x_user_count          =>  l_user_count
      , x_return_status       =>  x_return_status
   ) ;

   /* Check for Procedure's x_return_status */
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

     IF x_return_status IN ( FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR )  THEN

       -- raise error if its an invitation. else.. log it and return without sending any notification
       IF p_notif_event_code IN ( 'PG_INVITE','VAD_INVITE_IMP') THEN
       	  FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_CNTCT_FOR_INVITE');
          FND_MSG_PUB.Add;
       	  RAISE FND_API.G_EXC_ERROR;
       ELSE
       	  fnd_message.set_name ('PV', 'PV_NO_PRIMARY_USER_EXIST');
          fnd_message.set_token ('PARTNER_ID',l_notif_targeted_ptr_id);
          FND_MSG_PUB.Add;
          l_string      := SUBSTR(fnd_message.get,1,1000);
       	  WRITE_TO_FND_LOG(l_api_name,l_string );
       	  x_return_status := FND_API.G_RET_STS_SUCCESS;
       	  IF x_msg_count is null THEN
       	     x_msg_count := 0;
       	  END IF;
          return;
       END IF;
     END IF;
   END IF;

   FOR i IN 1 .. l_user_count LOOP
      --l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
      l_notif_user_id    := l_notif_user_id || ',' || x_user_notify_rec_tbl(i).user_id;
      l_pt_role_list(i) := x_user_notify_rec_tbl(i).user_name;
   END LOOP;

   IF l_pt_role_list.count > 0 then
      l_notif_user_id :=substr(l_notif_user_id,2);
      l_pt_adhoc_role := 'PV_' || l_itemKey ;
      l_role_disp_name :='Primary Users';
       -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message( 'Creating role PT: '|| l_pt_adhoc_role);
      END IF;
      wf_directory.CreateAdHocRole2
      (
         role_name         => l_pt_adhoc_role
         , role_display_name => l_pt_adhoc_role
         , role_users        => l_pt_role_list
      );
   END IF;


   IF l_pt_role_list.count < 1   THEN
      return;
   ELSE
      -- Once the parameters for workflow is validated, start the workflow
      wf_engine.CreateProcess
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , process  => 'EVENT_NOTIF_PROCESS'
      );

      wf_engine.SetItemUserKey
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , userKey  => l_itemkey
      );

      wf_engine.SetItemAttrText
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'NOTIFY_ROLE'
         , avalue   => l_pt_adhoc_role
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'PARTNER_EVENT_CODE'
         , avalue   => p_notif_event_code
      );

      -- NOTIFICATION_TYPE can be different from the event in some cases
      -- so that can be set accordingly here or later in the workflow process
      -- so right now setting it to p_notif_event_code

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'NOTIFICATION_TYPE'
         , avalue   =>  p_notif_event_code
      );

      wf_engine.SetItemAttrNumber
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'PARTNER_ID'
         , avalue   => l_notif_targeted_ptr_id --the partner_id to whom the notificationneeds to be sent
      );

      wf_engine.SetItemAttrNumber
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'ENTITY_ID'
         , avalue   => p_entity_id
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'ENTITY_CODE'
         , avalue   => l_entity_code
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'RECIPIENT_USER_ID'
         , avalue   => l_notif_user_id
      );

      -- set wait period in number of days in the workflow
      wf_engine.setItemAttrNumber(
         ITEMTYPE => l_itemtype,
         ITEMKEY  => l_itemkey,
         ANAME    => 'WAIT_PERIOD_IN_DAYS',
         AVALUE   => p_wait_time
         );

      l_login_url := FND_PROFILE.VALUE('PV_WORKFLOW_ISTORE_URL');
      --l_prtner_portal_url := '<a href="'|| l_login_url || '">'|| l_partner_program  || '</a>';
      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'ISTORE_LOGIN_URL'
         , AVALUE  => l_login_url
      );

      IF   l_entity_code = 'ENRQ' THEN
         -- set the program name
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'PROGRAM_NAME'
            , AVALUE  => l_partner_program
         );

         -- set the vendor org name
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'VENDOR_ORG_NAME'
            , AVALUE  => l_vendor_name
         );

         -- set the PARTNER_NAME
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'PARTNER_NAME'
            , AVALUE  => l_partner_comp_name
         );

         -- set the REQUESTOR_NAME
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'REQUESTOR_NAME'
            , AVALUE  => l_source_name
         );

          -- set the submit date
         wf_engine.setItemAttrDate
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'ENROLL_SUBMIT_DATE'
            , AVALUE  => l_req_submission_date
         );

          -- set the enroll type
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'ENROLLMENT_TYPE'
            , AVALUE  => l_enrollment_type
         );

         -- set the Enrollment Duration
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'ENROLLMENT_DURATION'
            , AVALUE  => l_enrollment_duration
         );
         -- set the START_DATE
         wf_engine.setItemAttrDate
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'START_DATE'
            , AVALUE  => l_start_date
         );

         -- set the END_DATE
         wf_engine.setItemAttrDate
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'END_DATE'
            , AVALUE  => l_end_date
         );

         -- set membership id.
         wf_engine.setItemAttrNumber
         (
            ITEMTYPE    => l_itemtype
            , ITEMKEY   => l_itemkey
            , ANAME     => 'MEMBERSHIP_ID'
            , AVALUE    => l_membership_id
         );

         --set enrollment request_id
        wf_engine.setItemAttrNumber
         (
            ITEMTYPE    => l_itemtype
            , ITEMKEY   => l_itemkey
            , ANAME     => 'ENROLLMENT_REQUEST_ID'
            , AVALUE    => p_entity_id
         );
         /* Set the Expiry in # of days */
	 --l_date_format := 'DD-MON-YYYY';
         l_expiry_days := to_number(trunc( fnd_date.displaydate_to_date( nvl(l_end_date, sysdate) ) - fnd_date.displaydate_to_date( sysdate )));
         IF  l_expiry_days <0 THEN
             l_expiry_days := 0;
         END IF;

         wf_engine.setItemAttrText
         (
            ITEMTYPE   => l_itemtype
            , ITEMKEY  => l_itemkey
            , ANAME    => 'MBRSHIP_EXPIRY_IN_DAYS'
            , AVALUE   =>  to_char(l_expiry_days)
         );

         -- set the event meaning  when Subsidiary Partner's enrollment has been approved/rejected/terminated by the Vendor
         IF p_notif_event_code = 'PG_TERMINATE' THEN
            PVX_UTILITY_PVT.get_lookup_meaning
            (
                  p_lookup_type     => 'PV_MEMBERSHIP_STATUS'
                  , p_lookup_code   => p_context_code
                  , x_return_status => x_return_status
                  , x_meaning       => l_event_meaning
            );
            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'EVENT_MEANING'
               , AVALUE  => l_event_meaning
            );

         END IF;

         IF p_notif_event_code = 'SUBSIDIARY_PTNR_ENROLL' THEN
            IF p_context_code IN ( 'APPROVED' , 'REJECTED' ) THEN
               PVX_UTILITY_PVT.get_lookup_meaning
               (
                  p_lookup_type     => 'PV_ENROLLMENT_REQUEST_STATUS'
                  , p_lookup_code   => p_context_code
                  , x_return_status => x_return_status
                  , x_meaning       => l_event_meaning
               );
            ELSE
               PVX_UTILITY_PVT.get_lookup_meaning
               (
                  p_lookup_type     => 'PV_NOTIFICATION_EVENT_TYPE'
                  , p_lookup_code   => p_notif_event_code
                  , x_return_status => x_return_status
                  , x_meaning       => l_event_meaning
               );
            END IF;

            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'EVENT_MEANING'
               , AVALUE  => l_event_meaning
            );
         END IF;

         IF p_notif_event_code = 'PG_DOWNGRADE' THEN
            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'FROM_PROGRAM'
               , AVALUE  => l_partner_program
            );

            OPEN c_prgm_csr(p_context_id);
               FETCH c_prgm_csr INTO l_to_partner_program;
            CLOSE c_prgm_csr;

            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'TO_PROGRAM'
               , AVALUE  => l_to_partner_program
            );

         END IF;

      ELSIF l_entity_code IN ( 'PARTNER', 'INVITE' ) THEN
         IF p_notif_event_code = 'SUBSIDIARY_PTNR_REGISTRATION' THEN
            l_partner_id :=p_context_id;
         ELSE
            l_partner_id := l_notif_targeted_ptr_id;
         END IF;

         get_partner_vendor_details
         (
            p_partner_id              =>  l_partner_id
            , x_vendor_party_id       =>  l_vendor_party_id
            , x_vendor_name           =>  l_vendor_name
            , x_partner_party_id      =>  l_partner_party_id
            , x_partner_comp_name     =>  l_partner_comp_name
            , x_return_status         =>  x_return_status
         );
         /* Check for Procedure's x_return_status */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
            FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_partner_id );
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         -- set the vendor org name
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'VENDOR_ORG_NAME'
            , AVALUE  => l_vendor_name
         );

         -- set the PARTNER_NAME
         wf_engine.setItemAttrText
         (
            ITEMTYPE  => l_itemtype
            , ITEMKEY => l_itemkey
            , ANAME   => 'PARTNER_NAME'
            , AVALUE  => l_partner_comp_name
         );

         IF p_notif_event_code IN ( 'PG_INVITE', 'VAD_INVITE_IMP' ) THEN
            OPEN c_inv_csr (p_entity_id);
               FETCH c_inv_csr  INTO l_partner_program;
            CLOSE c_inv_csr ;
            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'PROGRAM_NAME'
               , AVALUE  => l_partner_program
            );
         END IF;

         IF p_notif_event_code = 'MEMBER_TYPE_CHANGE' THEN
            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'FROM_MEMBER_TYPE'
               , AVALUE  => p_context_code
            );

            wf_engine.setItemAttrText
            (
               ITEMTYPE  => l_itemtype
               , ITEMKEY => l_itemkey
               , ANAME   => 'TO_MEMBER_TYPE'
               , AVALUE  => p_entity_code
            );
         END IF;


      END IF;  -- END OF IF .



      wf_engine.StartProcess
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
      );
      -- we can call the following procedure to see whether workflow was able to send notification successfully.
      -- but commenting this ouit because the error message could be seen by partner user.
      /** pv_assignment_pub.checkforErrors
                       (p_api_version_number  => 1.0
                       ,p_init_msg_list       => FND_API.G_FALSE
                       ,p_commit              => FND_API.G_FALSE
                       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                       ,p_itemtype            => l_itemType
                       ,p_itemkey             => l_itemKey
                       ,x_msg_count           => x_msg_count
                       ,x_msg_data            => x_msg_data
                       ,x_return_status       => x_return_status);

      -- Check the x_return_status. If its not successful throw an exception.
           if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
           end if;

           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_token('TEXT', 'After Checkforerror');
               fnd_msg_pub.Add;
           END IF;
      */
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                             p_count     =>  x_msg_count,
                             p_data      =>  x_msg_data);

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end Send_Workflow_Notification;



PROCEDURE Send_Invitations
(
   p_api_version_number    IN  NUMBER
   , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id          IN  NUMBER
   , p_invite_header_id    IN  NUMBER
   , p_from_program_id     IN  NUMBER  DEFAULT NULL
   , p_notif_event_code    IN  VARCHAR2
   , p_discount_value      IN  VARCHAR2
   , p_discount_unit       IN  VARCHAR2
   , p_currency            IN  VARCHAR2
   , p_end_date            IN  DATE
   , x_return_status       OUT NOCOPY  VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
) IS

   l_api_name               CONSTANT VARCHAR2(30) := 'Send_Invitation';
   l_itemType		    CONSTANT VARCHAR2(30) :='PVXNUTIL' ;
   l_api_version_number     CONSTANT NUMBER       := 1.0;
   l_itemKey		    VARCHAR2(30) := p_partner_id  ||'INVITE';
   l_notify_type            VARCHAR2(20);
   l_pt_role_list           wf_directory.usertable;
   l_notif_user_id          VARCHAR2(2000);
   l_pt_adhoc_role          VARCHAR2(80);
   l_role_disp_name         VARCHAR2(80);
   l_prtner_portal_url      VARCHAR2(4000);
   l_login_url              VARCHAR2(4000);
   l_send_respond_url       VARCHAR2(500);
   l_vendor_org_name        VARCHAR2(50);
   l_email_enabled          VARCHAR2(5);
   l_lookup_exists          VARCHAR2(1);
   l_entity_code            VARCHAR2(30);
   l_notif_rule_active      VARCHAR2(1):='Y';
   l_partner_program        VARCHAR2(240);
   l_to_partner_program     VARCHAR2(240);
   l_from_partner_program   VARCHAR2(240);
   l_enrollment_duration    VARCHAR2(240);
   l_enrollment_type        VARCHAR2(240);
   l_source_name            VARCHAR2(360);
   l_requestor_name         VARCHAR2(360);
   l_user_name              VARCHAR2(100);
   l_vendor_name            VARCHAR2(360);
   l_partner_comp_name      VARCHAR2(360);
   l_event_meaning          VARCHAR2(80);
   l_discount_meaning       VARCHAR2(80);
   l_currency               VARCHAR2(80);
   l_string                 VARCHAR2(1000):=null;
   l_discount_str           VARCHAR2(120);
   l_entity_id              NUMBER;
   l_notif_targeted_ptr_id  NUMBER; -- partner_id to whom the notification is targeted to.
   l_user_count             NUMBER;
   l_partner_id             NUMBER;
   l_expiry_days            NUMBER;
   l_enrl_request_id        NUMBER;
   l_req_resource_id        NUMBER;
   l_partner_program_id     NUMBER;
   l_prtnr_vndr_relship_id  NUMBER;
   l_user_id                NUMBER;
   --l_notif_user_id        NUMBER;
   l_vendor_party_id        NUMBER;
   l_partner_party_id       NUMBER;
   l_membership_id          NUMBER;
   l_start_date             DATE;
   l_end_date               DATE;
   l_req_submission_date    DATE;
   x_user_notify_rec_tbl    user_notify_rec_tbl_type;
   l_val                    NUMBER;

   CURSOR c_prgm_csr ( prgm_id NUMBER ) IS
   SELECT program_name
   FROM   pv_partner_program_vl
   WHERE  program_id=prgm_id;

   CURSOR c_inv_csr ( inv_hdr_id NUMBER ) IS
   SELECT prgm.program_name
   FROM   PV_PG_INVITE_HEADERS_b inv
          , pv_partner_program_vl prgm
   WHERE  inv.invite_header_id=inv_hdr_id
   AND    inv.invite_for_program_id =prgm.program_id;

   CURSOR c_currency_csr ( currencyCode VARCHAR2 ) IS
   SELECT name
   FROM fnd_currencies_vl
   WHERE currency_code = currencyCode;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;


   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   SELECT  PV_LEAD_WORKFLOWS_S.nextval
   INTO    l_val
   FROM    dual;

   l_itemKey  :=  l_itemKey || l_val;
   /* Get the user list */
   get_users_list
   (
      p_partner_id            =>  p_partner_id
      , x_user_notify_rec_tbl =>  x_user_notify_rec_tbl
      , x_user_count          =>  l_user_count
      , x_return_status       =>  x_return_status
   ) ;

   /* Check for Procedure's x_return_status */
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PV','PV_NO_PRIMARY_CNTCT_FOR_INVITE');
      FND_MSG_PUB.Add;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   FOR i IN 1 .. l_user_count LOOP
      --l_user_resource_id := x_user_notify_rec_tbl(i).user_resource_id;
      l_notif_user_id    := l_notif_user_id || ',' || x_user_notify_rec_tbl(i).user_id;
      l_pt_role_list(i) := x_user_notify_rec_tbl(i).user_name;
   END LOOP;

   IF l_pt_role_list.count > 0 then
      l_notif_user_id :=substr(l_notif_user_id,2);
      l_pt_adhoc_role := 'PV_' || l_itemKey ;
      l_role_disp_name :='Primary Users';
       -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         PVX_UTILITY_PVT.debug_message( 'Creating role PT: '|| l_pt_adhoc_role);
      END IF;
      wf_directory.CreateAdHocRole2
      (
         role_name         => l_pt_adhoc_role
         , role_display_name => l_pt_adhoc_role
         , role_users        => l_pt_role_list
      );
   END IF;


   IF l_pt_role_list.count < 1   THEN
      return;
   ELSE
      -- Once the parameters for workflow is validated, start the workflow
      wf_engine.CreateProcess
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , process  => 'EVENT_NOTIF_PROCESS'
      );

      wf_engine.SetItemUserKey
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , userKey  => l_itemkey
      );

      wf_engine.SetItemAttrText
      (
         ItemType => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'NOTIFY_ROLE'
         , avalue   => l_pt_adhoc_role
      );

      -- set the discount
      IF p_discount_unit IS NOT NULL THEN
      	 IF p_discount_unit= 'AMT'  THEN
            OPEN  c_currency_csr ( p_currency );
               FETCH c_currency_csr INTO l_currency;
            CLOSE c_currency_csr;
            l_discount_str:= p_discount_value || ' ' || l_currency ;
         ELSE
            PVX_UTILITY_PVT.get_lookup_meaning
            (
               p_lookup_type     => 'PV_OFFER_DISCOUNT_TYPE'
               , p_lookup_code   => p_discount_unit
               , x_return_status => x_return_status
               , x_meaning       => l_discount_meaning
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            l_discount_str:= p_discount_value || ' ' || l_discount_meaning ;
         END IF;
         fnd_message.set_name ('PV', 'PV_PRGM_DISCOUNT_MSG');
         fnd_message.set_token ('DISCOUNT', l_discount_str);
         fnd_message.set_token ('END_DATE', p_end_date);
         l_string      := SUBSTR(fnd_message.get,1,1000);

      END IF;

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'DISCOUNT_STRING'
         , avalue   => l_string
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'PARTNER_EVENT_CODE'
         , avalue   => p_notif_event_code
      );

      -- NOTIFICATION_TYPE can be different from the event in some cases
      -- so that can be set accordingly here or later in the workflow process
      -- so right now setting it to p_notif_event_code

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'NOTIFICATION_TYPE'
         , avalue   =>  p_notif_event_code
      );

      wf_engine.SetItemAttrNumber
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'PARTNER_ID'
         , avalue   => p_partner_id --the partner_id to whom the notificationneeds to be sent
      );

      wf_engine.SetItemAttrNumber
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'ENTITY_ID'
         , avalue   => p_invite_header_id
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'ENTITY_CODE'
         , avalue   => 'INVITE'
      );

      wf_engine.SetItemAttrText
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
         , aname    => 'RECIPIENT_USER_ID'
         , avalue   => l_notif_user_id
      );

      -- set wait period in number of days in the workflow
      wf_engine.setItemAttrNumber(
         ITEMTYPE => l_itemtype,
         ITEMKEY  => l_itemkey,
         ANAME    => 'WAIT_PERIOD_IN_DAYS',
         AVALUE   => 0
         );

      l_login_url := FND_PROFILE.VALUE('PV_WORKFLOW_ISTORE_URL');
      --l_prtner_portal_url := '<a href="'|| l_login_url || '">'|| l_partner_program  || '</a>';
      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'ISTORE_LOGIN_URL'
         , AVALUE  => l_login_url
      );

      get_partner_vendor_details
      (
         p_partner_id              =>  p_partner_id
         , x_vendor_party_id       =>  l_vendor_party_id
         , x_vendor_name           =>  l_vendor_name
         , x_partner_party_id      =>  l_partner_party_id
         , x_partner_comp_name     =>  l_partner_comp_name
         , x_return_status         =>  x_return_status
      );
      /* Check for Procedure's x_return_status */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
         FND_MESSAGE.SET_NAME('PV','PV_PRTNR_VNDR_NOT_EXIST');
         FND_MESSAGE.SET_TOKEN('PARTNER_ID',l_partner_id );
         FND_MSG_PUB.Add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      -- set the vendor org name
      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'VENDOR_ORG_NAME'
         , AVALUE  => l_vendor_name
      );

      -- set the PARTNER_NAME
      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'PARTNER_NAME'
         , AVALUE  => l_partner_comp_name
      );


      OPEN c_inv_csr (p_invite_header_id);
         FETCH c_inv_csr  INTO l_partner_program;
      CLOSE c_inv_csr ;

      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'PROGRAM_NAME'
         , AVALUE  => l_partner_program
      );

      wf_engine.setItemAttrText
      (
         ITEMTYPE  => l_itemtype
         , ITEMKEY => l_itemkey
         , ANAME   => 'TO_PROGRAM'
         , AVALUE  => l_partner_program
      );

      IF p_from_program_id IS NOT NULL THEN
         OPEN c_prgm_csr(p_from_program_id);
            FETCH c_prgm_csr INTO l_from_partner_program;
         CLOSE c_prgm_csr;

         wf_engine.setItemAttrText
         (
                  ITEMTYPE  => l_itemtype
                  , ITEMKEY => l_itemkey
                  , ANAME   => 'FROM_PROGRAM'
                  , AVALUE  => l_from_partner_program
         );
      END IF;

      wf_engine.StartProcess
      (
         ItemType   => l_itemType
         , ItemKey  => l_itemKey
      );

   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                             p_count     =>  x_msg_count,
                             p_data      =>  x_msg_data);

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end Send_Invitations;



END PV_PG_NOTIF_UTILITY_PVT;

/
