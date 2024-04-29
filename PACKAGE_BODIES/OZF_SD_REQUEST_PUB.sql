--------------------------------------------------------
--  DDL for Package Body OZF_SD_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_REQUEST_PUB" AS
/* $Header: ozfpsdrb.pls 120.14.12010000.18 2010/06/09 08:31:59 bkunjan ship $ */

G_PKG_NAME   CONSTANT     VARCHAR2(30):= 'OZF_SD_REQUEST_PUB';
G_FILE_NAME  CONSTANT     VARCHAR2(14) := 'ozfpsdrb.pls';
G_DEBUG                   BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_ITEM_ORG_ID             NUMBER;
G_REQUEST_HEADER_ID       NUMBER;

CURSOR c_currency(p_currency_code IN VARCHAR2) IS
   SELECT currency_code
   FROM fnd_currencies
   WHERE currency_code = p_currency_code
   AND enabled_flag='Y';

-----------------------------------------------------------------------
-- PROCEDURE
--    raise_stat_change_business_event
--
-- HISTORY
--
-----------------------------------------------------------------------
PROCEDURE raise_status_business_event(
   p_request_header_id      IN NUMBER
  ,p_from_status            IN VARCHAR2
  ,p_to_status              IN VARCHAR2)
IS

l_item_key          VARCHAR2(30);
l_event_name        VARCHAR2(80);
l_parameter_list    wf_parameter_list_t;

BEGIN
   l_item_key := p_request_header_id ||'SD_STAT'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
   l_parameter_list := WF_PARAMETER_LIST_T();

   l_event_name :=  'oracle.apps.ozf.sd.request.statuschange';

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message('    Request Header Id :'||p_request_header_id );
  END IF;

    wf_event.AddParameterToList(p_name        => 'OZF_SDR_HEADER_ID',
                              p_value          => p_request_header_id,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name        => 'OZF_SDR_FROM_STATUS',
                              p_value          => p_from_status,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name        => 'OZF_SDR_TO_STATUS',
                              p_value          => p_to_status,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
   END IF;

    wf_event.raise( p_event_name =>l_event_name,
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);

EXCEPTION
   WHEN OTHERS THEN
     RAISE Fnd_Api.g_exc_error;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('Exception in raising business event');
      END IF;

END;


-----------------------------------------------------------------------
-- PROCEDURE
--   raise_XMLGateway_business_event
--
-- HISTORY
--
-----------------------------------------------------------------------
PROCEDURE raise_XML_business_event(
   p_request_header_id      IN NUMBER
  ,p_supplier_id            IN NUMBER
  ,p_supplier_site_id       IN NUMBER)
IS

l_item_key          VARCHAR2(30);
l_event_name        VARCHAR2(80);
l_parameter_list    wf_parameter_list_t;

BEGIN
   l_item_key := p_request_header_id ||'SD_XML'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
   l_parameter_list := WF_PARAMETER_LIST_T();

   l_event_name :=  'oracle.apps.ozf.sd.request.outbound';

  IF G_DEBUG THEN
     ozf_utility_pvt.debug_message(' Request Header Id :'||p_request_header_id );
  END IF;

    wf_event.AddParameterToList(p_name         => 'ECX_MAP_CODE',
                              p_value          => 'OZF_SD_REQ_OUT',
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARTY_ID',
                              p_value          => p_supplier_id,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARTY_SITE_ID',
                              p_value          => p_supplier_site_id,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARTY_TYPE',
                              p_value          => 'S',
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_DOCUMENT_ID',
                              p_value          => p_request_header_id,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_TRANSACTION_TYPE',
                              p_value          => 'OZF',
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_TRANSACTION_SUBTYPE',
                              p_value          => 'SDRO',
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARAMETER1',
                              p_value          => NULL,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARAMETER2',
                              p_value          => NULL,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARAMETER3',
                              p_value          => NULL,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARAMETER4',
                              p_value          => NULL,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_PARAMETER5',
                              p_value          => NULL,
                              p_parameterlist  => l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'ECX_DEBUG_LEVEL',
                              p_value          => 3,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
   END IF;

    wf_event.raise( p_event_name =>l_event_name,
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);

EXCEPTION
   WHEN OTHERS THEN
     RAISE Fnd_Api.g_exc_error;
     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message('Exception in raising XML Gateway business event');
     END IF;
END;

---------------------------------------------------------------------
-- FUNCTION
--      check_zero
--
-- PURPOSE
--
--Parameters
---------------------------------------------------------------------
FUNCTION check_zero(p_value IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    IF p_value <= 0 THEN
       RETURN FND_API.g_false;
    ELSE
       RETURN FND_API.g_true;
    END IF;
END check_zero;
-----------------------------------------------------------------------
-- FUNCTION
--    get_user_status_id
--
-- HISTORY

-----------------------------------------------------------------------
FUNCTION get_user_status_id(
   p_system_status_code   IN  VARCHAR2
)
RETURN NUMBER
IS
l_user_status_id   NUMBER;

CURSOR  c_user_status_id IS
    SELECT user_status_id
    FROM ams_user_statuses_b
    WHERE system_status_type ='OZF_SD_REQUEST_STATUS'
    AND enabled_flag         ='Y'
    AND default_flag         ='Y'
    AND system_status_code   = p_system_status_code;

BEGIN

   OPEN c_user_status_id;
   FETCH c_user_status_id INTO l_user_status_id;
   CLOSE c_user_status_id;

   RETURN l_user_status_id;

END get_user_status_id;

---------------------------------------------------------------------
-- FUNCTION
--    get_system_status_code
--
-- PURPOSE

---------------------------------------------------------------------
FUNCTION get_system_status_code(
   p_user_status_id   IN  NUMBER
)
RETURN VARCHAR2
IS
l_system_status_code   VARCHAR2(30);

CURSOR c_system_status_code IS
    SELECT system_status_code
    FROM   ams_user_statuses_b
    WHERE  system_status_type ='OZF_SD_REQUEST_STATUS'
    AND    enabled_flag         ='Y'
    AND    user_status_id     = p_user_status_id ;

BEGIN

   OPEN c_system_status_code;
   FETCH c_system_status_code INTO l_system_status_code;
   CLOSE c_system_status_code;

   RETURN l_system_status_code;

END get_system_status_code;

---------------------------------------------------------------------
-- FUNCTION
--    check_status_transition
--
-- PURPOSE
---------------------------------------------------------------------

FUNCTION check_status_transition(
    p_from_status       IN VARCHAR2,
    p_to_status         IN VARCHAR2,
    p_owner_flag        IN VARCHAR2,
    p_pm_flag           IN VARCHAR2,
    p_internal_flag     IN VARCHAR2,
    p_external_flag     IN VARCHAR2)
RETURN VARCHAR2
IS
l_owner_count       NUMBER :=0;
l_pm_count          NUMBER :=0;
l_owner_pm_count    NUMBER :=0;

CURSOR c_external_transition (p_cur_owner_flag IN VARCHAR2,p_cur_pm_flag IN VARCHAR2) IS
   SELECT  COUNT(1)
   FROM ozf_sd_status_transitions
   WHERE enabled_flag		            ='Y'
   AND  from_status 		            = p_from_status
   AND  to_status			            = p_to_status
   AND  NVL(owner_flag,'N')             = p_cur_owner_flag
   AND  NVL(product_manager_flag,'N')   = p_cur_pm_flag
   AND  external_flag                   = p_external_flag
   AND  system_flag IS NULL;

CURSOR c_internal_transition (p_cur_owner_flag IN VARCHAR2,p_cur_pm_flag IN VARCHAR2) IS
   SELECT  COUNT(1)
   FROM ozf_sd_status_transitions
   WHERE enabled_flag		            ='Y'
   AND  from_status 		            = p_from_status
   AND  to_status			            = p_to_status
   AND  NVL(owner_flag,'N')             = p_cur_owner_flag
   AND  NVL(product_manager_flag,'N')   = p_cur_pm_flag
   AND  internal_flag                   = p_internal_flag
   AND  system_flag IS NULL;
BEGIN
   IF p_external_flag ='Y' THEN

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Checking status transitions for External Request');
      END IF;

      IF p_owner_flag ='Y' THEN

         OPEN c_external_transition('Y','N');
         FETCH c_external_transition INTO l_owner_count;
         CLOSE c_external_transition;

         IF G_DEBUG THEN
            OZF_UTILITY_PVT.debug_message('l_owner_count  :'||l_owner_count);
         END IF;
      END IF;

      IF p_pm_flag ='Y' THEN

         OPEN c_external_transition('N','Y');
         FETCH c_external_transition INTO l_pm_count;
         CLOSE c_external_transition;

         IF G_DEBUG THEN
            OZF_UTILITY_PVT.debug_message('l_pm_count  :'||l_pm_count);
         END IF;
      END IF;

      IF p_owner_flag ='Y' AND p_pm_flag ='Y' THEN
         OPEN c_external_transition('Y','Y');
         FETCH c_external_transition INTO l_owner_pm_count;
         CLOSE c_external_transition;
      END IF;

      IF l_owner_count = 0  AND l_pm_count = 0  AND l_owner_pm_count= 0 THEN
         RETURN FND_API.g_false;
      ELSE
         RETURN FND_API.g_true;
      END IF;

   ELSIF p_internal_flag ='Y' THEN

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Checking status transitions for Internal Request');
      END IF;

       IF p_owner_flag ='Y' THEN

         OPEN c_internal_transition('Y','N');
         FETCH c_internal_transition INTO l_owner_count;
         CLOSE c_internal_transition;

         IF G_DEBUG THEN
            OZF_UTILITY_PVT.debug_message('l_owner_count  :'||l_owner_count);
         END IF;
      END IF;

      IF p_pm_flag ='Y' THEN

         OPEN c_internal_transition('N','Y');
         FETCH c_internal_transition INTO l_pm_count;
         CLOSE c_internal_transition;

         IF G_DEBUG THEN
            OZF_UTILITY_PVT.debug_message('l_pm_count  :'||l_pm_count);
         END IF;
      END IF;

      IF p_owner_flag ='Y' AND p_pm_flag ='Y' THEN
         OPEN c_internal_transition('Y','Y');
         FETCH c_internal_transition INTO l_owner_pm_count;
         CLOSE c_internal_transition;
      END IF;

     IF l_owner_count = 0  AND l_pm_count = 0  AND l_owner_pm_count= 0 THEN
         RETURN FND_API.g_false;
      ELSE
         RETURN FND_API.g_true;
      END IF;

   END IF;

END check_status_transition;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Header_items
--
-- PURPOSE
--    This procedure validates Header record
--Parameters
--       p_SDR_hdr_rec   -Header Recordset
--      p_mode           -Insert /Update Mode
--      x_return_status - Result
---------------------------------------------------------------------
PROCEDURE validate_header_items(
    p_SDR_hdr_rec         IN OUT NOCOPY  SDR_Hdr_rec_type
   ,p_mode                IN             VARCHAR2
   ,x_return_status       OUT    NOCOPY  VARCHAR2
  )
IS
 l_lookup_stat              VARCHAR2(1); --To validate from lookups
 l_req_hdr_id_count         NUMBER;
 l_req_no_count             NUMBER;
 l_org_id                   NUMBER;
 l_requestor_id             NUMBER;
 l_supplier_id              NUMBER;
 l_supplier_site_id         NUMBER;
 l_supplier_contact_id      NUMBER;
 l_supp_email               VARCHAR2(2000);
 l_supp_phone               VARCHAR2(40);
 l_cust_account_id          NUMBER;
 l_authorization_period     NUMBER         :=0;
 l_currency_code            VARCHAR2(30);
 l_assignee_resource_id     NUMBER;
 l_sales_order_currency     VARCHAR2(30);
 l_user_id                  NUMBER;
 l_system_status_code       VARCHAR2(30);
 l_internal_order_number    NUMBER;
 l_resource_id              NUMBER;
 l_sup_contact_full_name    VARCHAR2(360) := NULL; --//Bugfix :7822442
 l_stp_count                NUMBER :=0;  --//Bugfix : 9748413

CURSOR c_user(p_user_id IN NUMBER) IS
	SELECT user_id
	FROM fnd_user
	WHERE user_id =p_user_id;

CURSOR c_org_id(p_org_id IN NUMBER)IS
    SELECT ou.organization_id org_id
    FROM hr_operating_units ou
    WHERE MO_GLOBAL.check_access(ou.organization_id) = 'Y'
    AND ou.organization_id =p_org_id;

CURSOR c_resource_id (p_user_id IN NUMBER) IS
    SELECT resource_id
    FROM jtf_rs_resource_extns
    WHERE start_date_active <= sysdate
    AND nvl(end_date_active,sysdate) >= sysdate
    AND resource_id > 0
    AND   (category = 'EMPLOYEE' OR category = 'PARTNER' OR category = 'PARTY')
    AND   user_id = p_user_id;

CURSOR c_requestor_id (p_requestor_id IN NUMBER) IS
    SELECT resource_id
    FROM jtf_rs_resource_extns
    WHERE start_date_active <= sysdate
    AND nvl(end_date_active,sysdate) >= sysdate
    AND resource_id > 0
    AND   (category = 'EMPLOYEE' OR category = 'PARTNER' OR category = 'PARTY')
    AND   resource_id = p_requestor_id;

CURSOR c_supp_id(p_supplier_id IN NUMBER) IS
   SELECT vendor_id
   FROM  ap_suppliers
   WHERE vendor_id = p_supplier_id;

CURSOR c_supplier_site_id(p_supplier_site_id  IN NUMBER,
                          p_supplier_id       IN NUMBER,
                          p_org_id            IN NUMBER) IS
    SELECT vendor_site_id
    FROM ap_supplier_sites_all
    WHERE vendor_site_id = p_supplier_site_id
    AND   vendor_id      = p_supplier_id
    AND   org_id         = p_org_id;

--//Bugfix : 9748413
CURSOR c_chk_stp_exists(p_supplier_id       IN NUMBER,
			p_supplier_site_id  IN NUMBER,
                        p_org_id            IN NUMBER) IS
   SELECT COUNT(1)
   FROM ozf_supp_trd_prfls_all
   WHERE supplier_id      = p_supplier_id
   AND   supplier_site_id = p_supplier_site_id
   AND   org_id           = p_org_id;

--//Bugfix : 7822442
CURSOR c_sup_contacts(p_supplier_site_id  IN NUMBER,
                      p_vendor_contact_id IN NUMBER) IS
   SELECT apc.vendor_contact_id
         ,apc.area_code||apc.phone phone_number
         ,apc.email_address
         ,decode(pvc.last_name,null,null,'','',pvc.last_name || ', ') || nvl(pvc.middle_name, '')|| ' '|| pvc.first_name AS Sup_contact_full_name
   FROM    ap_supplier_contacts apc,po_vendor_contacts pvc
   WHERE   apc.vendor_site_id                 =  pvc.vendor_site_id
   AND     apc.vendor_contact_id              =  pvc.vendor_contact_id
   AND     NVL(pvc.inactive_date, SYSDATE +1) >  SYSDATE
   AND     apc.vendor_site_id                 =  p_supplier_site_id
   AND     apc.vendor_contact_id              =  p_vendor_contact_id;

/*
CURSOR c_currency(p_currency_code IN VARCHAR2) IS
   SELECT currency_code
   FROM fnd_currencies
   WHERE currency_code = p_currency_code
   AND enabled_flag='Y';
*/
CURSOR c_cust_account_id(p_cust_account_id IN NUMBER) IS
    SELECT  cust_account_id
    FROM    hz_cust_accounts
    WHERE   status          ='A'
    AND     customer_type   ='I'
    AND     cust_account_id =p_cust_account_id;

CURSOR c_language_code(p_language_code IN VARCHAR2)IS
    SELECT language_code
    FROM fnd_languages
    WHERE language_code =p_language_code;

CURSOR c_authorization_period(p_supplier_id      IN NUMBER,
                              p_supplier_site_id IN NUMBER,
                              p_org_id           IN NUMBER)IS
    SELECT NVL(authorization_period,-1)
    FROM   ozf_supp_trd_prfls_all
    WHERE  supplier_id      = p_supplier_id
    AND    supplier_site_id = p_supplier_site_id
    AND    org_id           = p_org_id;

CURSOR c_request_header_id_count(p_request_header_id IN VARCHAR2)IS
    SELECT  COUNT(1)
    FROM    ozf_sd_request_headers_all_b
    WHERE   request_header_id = p_request_header_id;

CURSOR c_request_number_count(p_request_number IN VARCHAR2)IS
    SELECT  COUNT(1)
    FROM    ozf_sd_request_headers_all_b
    WHERE   request_number =p_request_number;

CURSOR c_system_status_code(p_user_status_id IN VARCHAR2)IS
    SELECT system_status_code
    FROM   ams_user_statuses_b
    WHERE system_status_type ='OZF_SD_REQUEST_STATUS'
    AND  user_status_id      = p_user_status_id;

CURSOR c_order_no(p_internal_order_number IN NUMBER,p_org_id IN NUMBER)IS
    SELECT order_number
    FROM oe_order_headers_all
    WHERE order_number = p_internal_order_number
    AND   org_id       = p_org_id;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

--// User ID validation
IF p_SDR_hdr_rec.user_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.user_id IS NOT NULL THEN
   OPEN c_user(p_SDR_hdr_rec.user_id);
   FETCH c_user INTO l_user_id;
   CLOSE c_user;

   IF l_user_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_USER_ID');
          --//User Id is invalid, Please re-enter
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   ELSE --// Check if User is a valid resource or not
       OPEN c_resource_id(p_SDR_hdr_rec.user_id);
       FETCH c_resource_id INTO l_resource_id;
       CLOSE c_resource_id;

       IF l_resource_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_USER_IS_NOT_RESOURCE');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
       IF g_debug THEN
          OZF_UTILITY_PVT.debug_message('l_resource_id of the user :'||l_resource_id);
       END IF;
   END IF;

ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_USER_ID');
       --//User Id is Mandatory
        FND_MSG_PUB.add;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
     RETURN;
END IF;

--// Organization id Validation
IF p_SDR_hdr_rec.org_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.org_id IS NOT NULL THEN
   OPEN  c_org_id(p_SDR_hdr_rec.org_id);
   FETCH c_org_id INTO l_org_id;
   CLOSE c_org_id;

   IF l_org_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ORG_ID');
          --//Organization id entered is invalid
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
  --//Set Org ID to Global Variable
 -- G_ORG_ID := p_SDR_hdr_rec.org_id;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_ORG_ID');
      --//Organization id is Mandatory
       FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//  Requestor ID Validation (owner)
IF p_SDR_hdr_rec.requestor_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.requestor_id IS NOT NULL THEN
   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Requestor NOT NULL');
   END IF;
   OPEN  c_requestor_id(p_SDR_hdr_rec.requestor_id);
   FETCH c_requestor_id INTO l_requestor_id;
   CLOSE c_requestor_id;

   IF l_requestor_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQUESTOR_ID');
          --//Requestor id entered is invalid
	   IF G_DEBUG THEN
              OZF_UTILITY_PVT.debug_message('Requestor id entered is invalid');
           END IF;
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
ELSE
     p_SDR_hdr_rec.requestor_id := l_resource_id;
     IF G_DEBUG THEN
        OZF_UTILITY_PVT.debug_message('l_resource_id :'||l_resource_id);
     END IF;
END IF;

IF  p_SDR_hdr_rec.accrual_type ='SUPPLIER' THEN
--//Supplier Validations
   p_SDR_hdr_rec.cust_account_id   := NULL;

--//Supplier ID
    IF p_SDR_hdr_rec.supplier_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.supplier_id IS NOT NULL THEN
        OPEN  c_supp_id(p_SDR_hdr_rec.supplier_id);
        FETCH c_supp_id INTO l_supplier_id;
        CLOSE c_supp_id;

       IF l_supplier_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPPLIER_ID');
            --//Supplier id entered is invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;

    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_SUPPLIER_ID');
           --//Supplier id is Mandatory
           FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;

--//Supplier site ID
    IF p_SDR_hdr_rec.supplier_site_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.supplier_site_id IS NOT NULL THEN
        OPEN  c_supplier_site_id(p_SDR_hdr_rec.supplier_site_id
                                ,p_SDR_hdr_rec.supplier_id
                                ,p_SDR_hdr_rec.org_id);

        FETCH c_supplier_site_id INTO l_supplier_site_id;
        CLOSE c_supplier_site_id;

       IF l_supplier_site_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPP_SITE_ID');
            --//Supplier site id entered is invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;

    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_SUPP_SITE_ID');
          --//Supplier site id is Mandatory
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;

--//Bugfix : 9748413
--//Supplier trade profile validation.
   OPEN  c_chk_stp_exists(p_SDR_hdr_rec.supplier_id
                         ,p_SDR_hdr_rec.supplier_site_id
                         ,p_SDR_hdr_rec.org_id);

   FETCH c_chk_stp_exists INTO l_stp_count;
   CLOSE c_chk_stp_exists;

   IF l_stp_count = 0 THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_SUP_TRD_PRFL');
         --//Supplier site id entered is invalid
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

 --//Supplier Contact ID
 --// Bugfix : 7822442
     IF p_SDR_hdr_rec.supplier_contact_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.supplier_contact_id IS NOT NULL THEN

        OPEN  c_sup_contacts(p_SDR_hdr_rec.supplier_site_id
	                    ,p_SDR_hdr_rec.supplier_contact_id);

        FETCH c_sup_contacts INTO l_supplier_contact_id,l_supp_email,l_supp_phone,l_sup_contact_full_name;
        CLOSE c_sup_contacts;

        IF l_supplier_contact_id IS NOT NULL THEN
           p_SDR_hdr_rec.supplier_contact_name := l_sup_contact_full_name;
        ELSE
          IF p_SDR_hdr_rec.supplier_contact_name = FND_API.g_miss_char OR p_SDR_hdr_rec.supplier_contact_name IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPP_CONTACT_ID');
                --//Supplier contact id entered is invalid
                FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
             RETURN;
          ELSE
             p_SDR_hdr_rec.supplier_contact_id  := NULL;
          END IF;
      END IF;
   END IF;

--Supplier Contact Info
   IF p_SDR_hdr_rec.supplier_contact_email_address = FND_API.g_miss_char OR p_SDR_hdr_rec.supplier_contact_email_address IS NULL THEN
      p_SDR_hdr_rec.supplier_contact_email_address :=l_supp_email;
   END IF;
   IF p_SDR_hdr_rec.supplier_contact_phone_number = FND_API.g_miss_char OR p_SDR_hdr_rec.supplier_contact_phone_number IS NULL THEN
      p_SDR_hdr_rec.supplier_contact_phone_number :=l_supp_phone;
   END IF;

    --supplier_response_by_date
   IF p_SDR_hdr_rec.supplier_response_by_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.supplier_response_by_date IS NOT NULL THEN
      p_SDR_hdr_rec.supplier_response_by_date := TRUNC(p_SDR_hdr_rec.supplier_response_by_date);

      IF p_SDR_hdr_rec.supplier_response_by_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                      p_SDR_hdr_rec.request_end_date THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPRESPB_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
     END IF;
   END IF;

--supplier_response_date
   IF p_SDR_hdr_rec.supplier_response_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.supplier_response_date IS NOT NULL THEN
      p_SDR_hdr_rec.supplier_response_date := TRUNC(p_SDR_hdr_rec.supplier_response_date);

      IF p_SDR_hdr_rec.supplier_response_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                          p_SDR_hdr_rec.request_end_date THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPRESP_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

--supplier_submission_date
   IF p_SDR_hdr_rec.supplier_submission_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.supplier_submission_date IS NOT NULL THEN
      p_SDR_hdr_rec.supplier_submission_date := TRUNC(p_SDR_hdr_rec.supplier_submission_date);

      IF p_SDR_hdr_rec.supplier_submission_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                            p_SDR_hdr_rec.request_end_date THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SUPSUB_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --//Validating Assignee Resource ID
   l_system_status_code := get_system_status_code(p_SDR_hdr_rec.user_status_id);

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Validating Assignee Resource ID');
   END IF;

   IF l_system_status_code <> 'DRAFT' THEN

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Assignee resource_id ID :'||p_SDR_hdr_rec.assignee_resource_id);
   END IF;

   IF p_SDR_hdr_rec.assignee_resource_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.assignee_resource_id IS NOT NULL THEN

       OPEN  c_requestor_id(p_SDR_hdr_rec.assignee_resource_id);
       FETCH c_requestor_id INTO l_assignee_resource_id;
       CLOSE c_requestor_id;

        IF l_assignee_resource_id IS NULL THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ASSIGNEE_ID');
               --//Assignee id entered is invalid (Approver)
               FND_MSG_PUB.add;
           END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_ASSIGNEE_ID');
          --//Assignee resource id is Mandatory (Approver is mandatory)
          FND_MSG_PUB.add;
       END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;

   --asignee_response_by_date
   IF p_SDR_hdr_rec.assignee_response_by_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.assignee_response_by_date IS NOT NULL THEN
      p_SDR_hdr_rec.assignee_response_by_date := TRUNC(p_SDR_hdr_rec.assignee_response_by_date);

      IF p_SDR_hdr_rec.assignee_response_by_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                         p_SDR_hdr_rec.request_end_date THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ASRESPB_DATE');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --asignee_response_date
   IF p_SDR_hdr_rec.assignee_response_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.assignee_response_date IS NOT NULL THEN
      p_SDR_hdr_rec.assignee_response_date := TRUNC(p_SDR_hdr_rec.assignee_response_date);

      IF p_SDR_hdr_rec.assignee_response_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                      p_SDR_hdr_rec.request_end_date THEN

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ASRESP_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
ELSE
   p_SDR_hdr_rec.assignee_resource_id       :=NULL;
   p_SDR_hdr_rec.assignee_response_by_date  :=NULL;
   p_SDR_hdr_rec.assignee_response_date     :=NULL;

END IF;

ELSIF p_SDR_hdr_rec.accrual_type ='INTERNAL' THEN

    p_SDR_hdr_rec.supplier_id                   :=NULL;
    p_SDR_hdr_rec.supplier_site_id              :=NULL;
    p_SDR_hdr_rec.supplier_contact_id           :=NULL;
    p_SDR_hdr_rec.supplier_contact_phone_number :=NULL;
    p_SDR_hdr_rec.supplier_contact_email_address:=NULL;
    p_SDR_hdr_rec.supplier_response_by_date     :=NULL;
    p_SDR_hdr_rec.supplier_response_date        :=NULL;
    p_SDR_hdr_rec.supplier_submission_date      :=NULL;
    p_SDR_hdr_rec.supplier_quote_number         :=NULL;
    p_SDR_hdr_rec.assignee_resource_id          :=NULL;
    p_SDR_hdr_rec.assignee_response_by_date     :=NULL;
    p_SDR_hdr_rec.assignee_response_date        :=NULL;


     IF p_SDR_hdr_rec.cust_account_id <> FND_API.g_miss_num AND p_SDR_hdr_rec.cust_account_id IS NOT NULL THEN

        OPEN  c_cust_account_id(p_SDR_hdr_rec.cust_account_id);
        FETCH c_cust_account_id INTO l_cust_account_id;
        CLOSE c_cust_account_id;

        IF l_cust_account_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_ACCOUNT_ID');
            --//Cust Account ID entered is invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;

       ELSE
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_CUST_ACCOUNT_ID');
             --//Cust Account id is Mandatory
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
    END IF;
END IF;

--//Bugfix : 7607795 - Start Date/End date Validations
IF p_SDR_hdr_rec.request_start_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.request_start_date IS NOT NULL THEN

   IF (p_SDR_hdr_rec.request_end_date = FND_API.g_miss_date OR p_SDR_hdr_rec.request_end_date IS NULL) AND p_mode = 'CREATE' THEN
         --//Generate End Date from Supplier trade profile
      OPEN  c_authorization_period(p_SDR_hdr_rec.supplier_id
                                  ,p_SDR_hdr_rec.supplier_site_id
                                  ,p_SDR_hdr_rec.org_id);

      FETCH c_authorization_period INTO l_authorization_period;
      CLOSE c_authorization_period;

      IF l_authorization_period <> -1 THEN
         p_SDR_hdr_rec.request_end_date := p_SDR_hdr_rec.request_start_date + l_authorization_period;
      END IF;

   ELSIF p_SDR_hdr_rec.request_end_date < p_SDR_hdr_rec.request_start_date THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_END_DATE');
        --//End date should be greater than start date
        FND_MSG_PUB.add;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
   END IF;
END IF;

--//TRUNC Date
p_SDR_hdr_rec.request_start_date := TRUNC(p_SDR_hdr_rec.request_start_date);
p_SDR_hdr_rec.request_end_date   := TRUNC(p_SDR_hdr_rec.request_end_date);

--Request Currency code
IF p_SDR_hdr_rec.request_currency_code <> FND_API.g_miss_char AND p_SDR_hdr_rec.request_currency_code IS NOT NULL THEN
   OPEN  c_currency (p_SDR_hdr_rec.request_currency_code);
   FETCH c_currency INTO l_currency_code;
   CLOSE c_currency;

   IF l_currency_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CURRENCY_CODE');
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
      END IF;
   ELSE
 --//Get currency code from profile :JTF_PROFILE_DEFAULT_CURRENCY
   p_SDR_hdr_rec.request_currency_code :=FND_PROFILE.value('JTF_PROFILE_DEFAULT_CURRENCY');

   IF p_SDR_hdr_rec.request_currency_code IS NULL THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_ADD_PROFILE_CURRENCY');
           --//Please set default Currency in  profile JTF_PROFILE_DEFAULT_CURRENCY
           FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;
END IF;

--Request Outcome
IF p_SDR_hdr_rec.request_outcome <> FND_API.g_miss_char AND p_SDR_hdr_rec.request_outcome IS NOT NULL THEN
l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                   p_lookup_table_name =>'OZF_LOOKUPS'
                  ,p_lookup_type       =>'OZF_SD_REQUEST_OUTCOME'
                  ,p_lookup_code       => p_SDR_hdr_rec.request_outcome);

  IF l_lookup_stat = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQ_OUTCOME');
         FND_MSG_PUB.add;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
     RETURN;
   END IF;
END IF;

--Internal Order Number
IF p_SDR_hdr_rec.internal_order_number <> FND_API.g_miss_num AND p_SDR_hdr_rec.internal_order_number IS NOT NULL THEN
   OPEN  c_order_no (p_SDR_hdr_rec.internal_order_number,p_SDR_hdr_rec.org_id);
   FETCH c_order_no INTO l_internal_order_number;
   CLOSE c_order_no;

   IF l_internal_order_number IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ORDER_NUMBER');
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
END IF;

--Sales Order Currency
IF p_SDR_hdr_rec.sales_order_currency <> FND_API.g_miss_char AND p_SDR_hdr_rec.sales_order_currency IS NOT NULL THEN
   OPEN  c_currency (p_SDR_hdr_rec.sales_order_currency);
   FETCH c_currency INTO l_sales_order_currency;
   CLOSE c_currency;

   IF l_sales_order_currency IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SO_CURRENCY');
          --//Invalid Sales order Currency.
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
END IF;

--internal_submission_date
IF p_SDR_hdr_rec.internal_submission_date <> FND_API.g_miss_date AND p_SDR_hdr_rec.internal_submission_date IS NOT NULL THEN
   p_SDR_hdr_rec.internal_submission_date := TRUNC(p_SDR_hdr_rec.internal_submission_date);

   IF p_SDR_hdr_rec.internal_submission_date NOT BETWEEN p_SDR_hdr_rec.request_start_date AND
                                                         p_SDR_hdr_rec.request_end_date THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_INTSUB_DATE');
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
END IF;


END Validate_Header_Items;
---------------------------------------------------------------------
-- PROCEDURE
--    validate_product_lines
--
-- PURPOSE
--    This procedure validates Lines table
--Parameters
--       p_SDR_hdr_rec   -Header Recordset
--      p_mode           -Insert /Update Mode
--      x_return_status - Result
---------------------------------------------------------------------
PROCEDURE validate_product_lines(
    p_SDR_lines_tbl       IN OUT NOCOPY  SDR_lines_tbl_type
   ,p_SDR_hdr_rec         IN             SDR_Hdr_rec_type
   ,p_mode                IN             VARCHAR2
   ,x_return_status       OUT    NOCOPY  VARCHAR2
  )
IS
 l_lookup_stat              VARCHAR2(1); --To validate from lookups

 l_request_line_id          NUMBER;
 l_inventory_item_id        NUMBER;
 l_category_id              NUMBER;
 l_category_set_id          NUMBER;
 l_formula_count            NUMBER;
 l_status                   VARCHAR2(30);
 l_qty_increase_tolerance   NUMBER       := 0 ;
 l_item_uom                 VARCHAR2(30);
 l_status_code              VARCHAR2(30);
 l_external_code            VARCHAR2(240);
 l_internal_code            NUMBER;
 l_old_product_lines        OZF_SD_REQUEST_PUB.SDR_lines_rec_type;
 l_currency_var             VARCHAR2(30) := NULL;

CURSOR c_master_org_id(p_header_org_id IN NUMBER)IS
   SELECT master_organization_id
   FROM   oe_system_parameters
   WHERE  org_id = p_header_org_id;

CURSOR c_request_line_id(p_request_line_id IN NUMBER,p_request_header_id IN NUMBER) IS
    SELECT request_line_id
    FROM  ozf_sd_request_lines_all
    WHERE request_line_id   = p_request_line_id
    AND   request_header_id = p_request_header_id;

CURSOR c_inventory_item_id(p_inventory_item_id IN NUMBER,p_org_id IN NUMBER)IS
    SELECT inventory_item_id
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id
    AND   organization_id   = p_org_id;

CURSOR c_category_id(p_category_id IN NUMBER) IS
    SELECT category_id
    FROM  mtl_categories_v
    WHERE category_id = p_category_id;

CURSOR c_category_set_id(p_category_id IN NUMBER,p_category_set_id IN NUMBER)IS
   SELECT b.category_set_id
   FROM mtl_default_category_sets a ,
        mtl_category_sets_b b ,
        mtl_categories_v c
   WHERE a.functional_area_id in (7,11)
   AND   a.category_set_id   = b.category_set_id
   AND   b.structure_id      = c.structure_id
   AND   c.category_id       = p_category_id
   AND   a.category_set_id   = p_category_set_id;

CURSOR c_product_cost(p_inventory_item_id IN NUMBER,p_org_id IN NUMBER)IS
    SELECT list_price_per_unit
    FROM mtl_system_items_kfv
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id     = p_org_id;

CURSOR c_item_uom(p_item_uom IN VARCHAR2,p_inventory_item_id IN NUMBER,p_org_id IN NUMBER)IS
    SELECT 	a.uom_code
    FROM 	mtl_units_of_measure a,
		    mtl_system_items c
    WHERE c.primary_unit_of_measure = a.unit_of_measure
    AND   c.organization_id         = p_org_id
    AND   c.inventory_item_id       = p_inventory_item_id
    AND   uom_code                  = p_item_uom;

--//Bugfix :8511949
CURSOR c_price_formula(p_price_formula_id IN NUMBER) IS
   SELECT COUNT(1)
   FROM   qp_price_formulas_b
   WHERE  TRUNC(sysdate) between NVL(start_date_active, TRUNC(sysdate))
   AND    NVL(end_date_active, TRUNC(sysdate))
   AND    price_formula_id = p_price_formula_id;

CURSOR c_func_currency(p_org_id IN NUMBER)IS
   SELECT gs.currency_code
   FROM gl_sets_of_books gs ,
        ozf_sys_parameters_all org
   WHERE org.set_of_books_id = gs.set_of_books_id
   AND   org.org_id          = p_org_id;

CURSOR c_cost_basis(p_supplier_id              IN NUMBER
                   ,p_supplier_site_id         IN NUMBER
                   ,p_org_id                   IN NUMBER)IS
    SELECT claim_computation_basis
    FROM   ozf_supp_trd_prfls_all otrpf
    WHERE supplier_id           = p_supplier_id
    AND supplier_site_id        = p_supplier_site_id
    AND org_id                  = p_org_id;

CURSOR c_qty_increase_tolerance(p_supplier_id       IN NUMBER
                               ,p_supplier_site_id  IN NUMBER
                               ,p_org_id            IN NUMBER)IS
    SELECT NVL(qty_increase_tolerance,0)
    FROM ozf_supp_trd_prfls_all
    WHERE supplier_id	  = p_supplier_id
    AND supplier_site_id  = p_supplier_site_id
    AND org_id            = p_org_id;

CURSOR c_object_version_number(p_request_line_id IN NUMBER)IS
    SELECT object_version_number
    FROM   ozf_sd_request_lines_all
    WHERE  request_line_id = p_request_line_id;

CURSOR c_vendor_item_code(p_supplier_id         IN NUMBER
                         ,p_supplier_site_id    IN NUMBER
                         ,p_org_id              IN NUMBER
                         ,p_inventory_item_id   IN NUMBER)IS
   SELECT external_code
   FROM ozf_supp_code_conversions_all code,
        ozf_supp_trd_prfls_all trd_profile
   WHERE  code.code_conversion_type     = 'OZF_PRODUCT_CODES'
   AND    code.supp_trade_profile_id    = trd_profile.supp_trade_profile_id
   AND    trd_profile.supplier_id       = p_supplier_id
   AND    trd_profile.supplier_site_id  = p_supplier_site_id
   AND    trd_profile.org_id            = p_org_id
   AND    internal_code                 = p_inventory_item_id;


CURSOR c_ext_int_code(p_supplier_id         IN NUMBER
                     ,p_supplier_site_id    IN NUMBER
                     ,p_org_id              IN NUMBER) IS
   SELECT external_code,  --Vendor Item Code
	      internal_code   --Inventory Item ID
   FROM ozf_supp_code_conversions_all code,
        ozf_supp_trd_prfls_all trd_profile
   WHERE  code.code_conversion_type     = 'OZF_PRODUCT_CODES'
   AND    code.supp_trade_profile_id    = trd_profile.supp_trade_profile_id
   AND    trd_profile.supplier_id       = p_supplier_id
   AND    trd_profile.supplier_site_id  = p_supplier_site_id
   AND    trd_profile.org_id            = p_org_id;

CURSOR c_old_product_lines(p_request_line_id IN NUMBER)IS
   SELECT object_version_number,
          request_header_id,
          product_context,
          inventory_item_id,
          prod_catg_id,
          product_cat_set_id,
          product_cost,
          item_uom,
          requested_discount_type,
          requested_discount_value,
          cost_basis,
          max_qty,
          limit_qty,
          design_win,
          end_customer_price,
          requested_line_amount,
          approved_discount_type,
          approved_discount_value,
          approved_max_qty,
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
          vendor_approved_flag,
          vendor_item_code,
          start_date,
          end_date,
          end_customer_price_type,
          end_customer_tolerance_type,
          end_customer_tolerance_value,
          org_id,
          rejection_code,
          requested_discount_currency,
          product_cost_currency,
          end_customer_currency,
          approved_discount_currency
FROM ozf_sd_request_lines_all
WHERE request_line_id   = p_request_line_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

--//Get the master organization id
OPEN c_master_org_id(p_SDR_hdr_rec.org_id);
FETCH c_master_org_id INTO G_ITEM_ORG_ID;
CLOSE c_master_org_id;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('c_master_org_id -->G_ITEM_ORG_ID: ' || G_ITEM_ORG_ID);
END IF;


FOR i IN p_SDR_lines_tbl.FIRST..p_SDR_lines_tbl.LAST LOOP
--//Update Mode
IF p_mode ='UPDATE' THEN

   IF p_SDR_lines_tbl(i).request_line_id <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).request_line_id IS NOT NULL THEN
   --Updating existing lines
      OPEN  c_request_line_id(p_SDR_lines_tbl(i).request_line_id,p_SDR_hdr_rec.request_header_id);
      FETCH c_request_line_id INTO l_request_line_id;
      CLOSE c_request_line_id;

      IF l_request_line_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQUEST_LINE_ID');
            --//Request Line id is Invalid , Please Re-enter
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      ELSE

      --//Reset the values of new record from old record if NULL.
         OPEN c_old_product_lines(p_SDR_lines_tbl(i).request_line_id);
         FETCH c_old_product_lines INTO l_old_product_lines.object_version_number,
                                        l_old_product_lines.request_header_id,
                                        l_old_product_lines.product_context,
                                        l_old_product_lines.inventory_item_id,
                                        l_old_product_lines.prod_catg_id,
                                        l_old_product_lines.product_cat_set_id,
                                        l_old_product_lines.product_cost,
                                        l_old_product_lines.item_uom,
                                        l_old_product_lines.requested_discount_type,
                                        l_old_product_lines.requested_discount_value,
                                        l_old_product_lines.cost_basis,
                                        l_old_product_lines.max_qty,
                                        l_old_product_lines.limit_qty,
                                        l_old_product_lines.design_win,
                                        l_old_product_lines.end_customer_price,
                                        l_old_product_lines.requested_line_amount,
                                        l_old_product_lines.approved_discount_type,
                                        l_old_product_lines.approved_discount_value,
                                        l_old_product_lines.approved_max_qty,
                                        l_old_product_lines.attribute_category,
                                        l_old_product_lines.attribute1,
                                        l_old_product_lines.attribute2,
                                        l_old_product_lines.attribute3,
                                        l_old_product_lines.attribute4,
                                        l_old_product_lines.attribute5,
                                        l_old_product_lines.attribute6,
                                        l_old_product_lines.attribute7,
                                        l_old_product_lines.attribute8,
                                        l_old_product_lines.attribute9,
                                        l_old_product_lines.attribute10,
                                        l_old_product_lines.attribute11,
                                        l_old_product_lines.attribute12,
                                        l_old_product_lines.attribute13,
                                        l_old_product_lines.attribute14,
                                        l_old_product_lines.attribute15,
                                        l_old_product_lines.vendor_approved_flag,
                                        l_old_product_lines.vendor_item_code,
                                        l_old_product_lines.start_date,
                                        l_old_product_lines.end_date,
                                        l_old_product_lines.end_customer_price_type,
                                        l_old_product_lines.end_customer_tolerance_type,
                                        l_old_product_lines.end_customer_tolerance_value,
                                        l_old_product_lines.org_id,
                                        l_old_product_lines.rejection_code,
                                        l_old_product_lines.requested_discount_currency,
                                        l_old_product_lines.product_cost_currency,
                                        l_old_product_lines.end_customer_currency,
                                        l_old_product_lines.approved_discount_currency;
         CLOSE c_old_product_lines;

        p_SDR_lines_tbl(i).object_version_number		:= l_old_product_lines.object_version_number;
        p_SDR_lines_tbl(i).request_header_id			:= NVL(p_SDR_lines_tbl(i).request_header_id,l_old_product_lines.request_header_id);
        p_SDR_lines_tbl(i).product_context			:= NVL(p_SDR_lines_tbl(i).product_context,l_old_product_lines.product_context);
        p_SDR_lines_tbl(i).inventory_item_id			:= NVL(p_SDR_lines_tbl(i).inventory_item_id,l_old_product_lines.inventory_item_id);
        p_SDR_lines_tbl(i).prod_catg_id			        := NVL(p_SDR_lines_tbl(i).prod_catg_id,l_old_product_lines.prod_catg_id);
        p_SDR_lines_tbl(i).product_cat_set_id			:= NVL(p_SDR_lines_tbl(i).product_cat_set_id,l_old_product_lines.product_cat_set_id);
        p_SDR_lines_tbl(i).product_cost			        := NVL(p_SDR_lines_tbl(i).product_cost,l_old_product_lines.product_cost);
        p_SDR_lines_tbl(i).item_uom				:= NVL(p_SDR_lines_tbl(i).item_uom,l_old_product_lines.item_uom);
        p_SDR_lines_tbl(i).requested_discount_type		:= NVL(p_SDR_lines_tbl(i).requested_discount_type,l_old_product_lines.requested_discount_type);
        p_SDR_lines_tbl(i).requested_discount_value		:= NVL(p_SDR_lines_tbl(i).requested_discount_value,l_old_product_lines.requested_discount_value);
        p_SDR_lines_tbl(i).cost_basis				:= NVL(p_SDR_lines_tbl(i).cost_basis,l_old_product_lines.cost_basis);
        p_SDR_lines_tbl(i).max_qty				:= NVL(p_SDR_lines_tbl(i).max_qty,l_old_product_lines.max_qty);
        p_SDR_lines_tbl(i).limit_qty				:= NVL(p_SDR_lines_tbl(i).limit_qty,l_old_product_lines.limit_qty);
        p_SDR_lines_tbl(i).design_win				:= NVL(p_SDR_lines_tbl(i).design_win,l_old_product_lines.design_win);
        p_SDR_lines_tbl(i).end_customer_price			:= NVL(p_SDR_lines_tbl(i).end_customer_price,l_old_product_lines.end_customer_price);
        p_SDR_lines_tbl(i).requested_line_amount		:= NVL(p_SDR_lines_tbl(i).requested_line_amount,l_old_product_lines.requested_line_amount);
        p_SDR_lines_tbl(i).approved_discount_type		:= NVL(p_SDR_lines_tbl(i).approved_discount_type,l_old_product_lines.approved_discount_type);
        p_SDR_lines_tbl(i).approved_discount_value		:= NVL(p_SDR_lines_tbl(i).approved_discount_value,l_old_product_lines.approved_discount_value);
        p_SDR_lines_tbl(i).approved_max_qty			:= NVL(p_SDR_lines_tbl(i).approved_max_qty,l_old_product_lines.approved_max_qty);
        p_SDR_lines_tbl(i).attribute_category			:= NVL(p_SDR_lines_tbl(i).attribute_category,l_old_product_lines.attribute_category);
        p_SDR_lines_tbl(i).attribute1				:= NVL(p_SDR_lines_tbl(i).attribute1,l_old_product_lines.attribute1);
        p_SDR_lines_tbl(i).attribute2				:= NVL(p_SDR_lines_tbl(i).attribute2,l_old_product_lines.attribute2);
        p_SDR_lines_tbl(i).attribute3				:= NVL(p_SDR_lines_tbl(i).attribute3,l_old_product_lines.attribute3);
        p_SDR_lines_tbl(i).attribute4			    	:= NVL(p_SDR_lines_tbl(i).attribute4,l_old_product_lines.attribute4);
        p_SDR_lines_tbl(i).attribute5			    	:= NVL(p_SDR_lines_tbl(i).attribute5,l_old_product_lines.attribute5);
        p_SDR_lines_tbl(i).attribute6		     		:= NVL(p_SDR_lines_tbl(i).attribute6,l_old_product_lines.attribute6);
        p_SDR_lines_tbl(i).attribute7		     		:= NVL(p_SDR_lines_tbl(i).attribute7,l_old_product_lines.attribute7);
        p_SDR_lines_tbl(i).attribute8		     		:= NVL(p_SDR_lines_tbl(i).attribute8,l_old_product_lines.attribute8);
        p_SDR_lines_tbl(i).attribute9		     		:= NVL(p_SDR_lines_tbl(i).attribute9,l_old_product_lines.attribute9);
        p_SDR_lines_tbl(i).attribute10		        	:= NVL(p_SDR_lines_tbl(i).attribute10,l_old_product_lines.attribute10);
        p_SDR_lines_tbl(i).attribute11			       	:= NVL(p_SDR_lines_tbl(i).attribute11,l_old_product_lines.attribute11);
        p_SDR_lines_tbl(i).attribute12		    		:= NVL(p_SDR_lines_tbl(i).attribute12,l_old_product_lines.attribute12);
        p_SDR_lines_tbl(i).attribute13			       	:= NVL(p_SDR_lines_tbl(i).attribute13,l_old_product_lines.attribute13);
        p_SDR_lines_tbl(i).attribute14			       	:= NVL(p_SDR_lines_tbl(i).attribute14,l_old_product_lines.attribute14);
        p_SDR_lines_tbl(i).attribute15			       	:= NVL(p_SDR_lines_tbl(i).attribute15,l_old_product_lines.attribute15);
        p_SDR_lines_tbl(i).vendor_approved_flag		        := NVL(p_SDR_lines_tbl(i).vendor_approved_flag,l_old_product_lines.vendor_approved_flag);
        p_SDR_lines_tbl(i).vendor_item_code			:= NVL(p_SDR_lines_tbl(i).vendor_item_code,l_old_product_lines.vendor_item_code);
        p_SDR_lines_tbl(i).start_date			    	:= NVL(p_SDR_lines_tbl(i).start_date,l_old_product_lines.start_date);
        p_SDR_lines_tbl(i).end_date			        := NVL(p_SDR_lines_tbl(i).end_date,l_old_product_lines.end_date);
        p_SDR_lines_tbl(i).end_customer_price_type		:= NVL(p_SDR_lines_tbl(i).end_customer_price_type,l_old_product_lines.end_customer_price_type);
        p_SDR_lines_tbl(i).end_customer_tolerance_type	        := NVL(p_SDR_lines_tbl(i).end_customer_tolerance_type,l_old_product_lines.end_customer_tolerance_type);
        p_SDR_lines_tbl(i).end_customer_tolerance_value	        := NVL(p_SDR_lines_tbl(i).end_customer_tolerance_value,l_old_product_lines.end_customer_tolerance_value);
        p_SDR_lines_tbl(i).org_id			        := NVL(p_SDR_lines_tbl(i).org_id,l_old_product_lines.org_id);
        p_SDR_lines_tbl(i).rejection_code		     	:= NVL(p_SDR_lines_tbl(i).rejection_code,l_old_product_lines.rejection_code);
        p_SDR_lines_tbl(i).requested_discount_currency	        := NVL(p_SDR_lines_tbl(i).requested_discount_currency,l_old_product_lines.requested_discount_currency);
        p_SDR_lines_tbl(i).product_cost_currency		:= NVL(p_SDR_lines_tbl(i).product_cost_currency,l_old_product_lines.product_cost_currency);
        p_SDR_lines_tbl(i).end_customer_currency		:= NVL(p_SDR_lines_tbl(i).end_customer_currency,l_old_product_lines.end_customer_currency);
        p_SDR_lines_tbl(i).approved_discount_currency	        := NVL(p_SDR_lines_tbl(i).approved_discount_currency,l_old_product_lines.approved_discount_currency);

      END IF;
   END IF;
END IF;

--//Update Mode End

--Product Context
IF p_SDR_lines_tbl(i).product_context <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).product_context IS NOT NULL THEN

    l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                        p_lookup_table_name =>'OZF_LOOKUPS'
                       ,p_lookup_type       =>'OZF_SD_PRODUCT_CONTEXT'
                       ,p_lookup_code       => p_SDR_lines_tbl(i).product_context);

    IF l_lookup_stat = FND_API.g_false THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_PRODUCT_TYPE');
           FND_MSG_PUB.add;
        END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
     END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_PRODUCT_CONTEXT');
      --//Product context is Mandatory
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//PRODUCT
--==========
IF p_SDR_lines_tbl(i).product_context ='PRODUCT' THEN

   p_SDR_lines_tbl(i).prod_catg_id          := NULL;
   p_SDR_lines_tbl(i).product_cat_set_id    := NULL;

    IF p_SDR_lines_tbl(i).inventory_item_id <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).inventory_item_id IS NOT NULL THEN

       OPEN  c_inventory_item_id(p_SDR_lines_tbl(i).inventory_item_id,G_ITEM_ORG_ID);
       FETCH c_inventory_item_id INTO l_inventory_item_id;
       CLOSE c_inventory_item_id;

       IF l_inventory_item_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_INVENTORY_ITEM_ID');
             --//Inventory item id is Invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
      --//Populating Vendor Item code
      --// Bugfix 7372272 gmiss_num changed to gmiss_char
      IF p_SDR_lines_tbl(i).vendor_item_code = FND_API.g_miss_char OR p_SDR_lines_tbl(i).vendor_item_code IS NULL THEN

         OPEN  c_vendor_item_code(p_SDR_hdr_rec.supplier_id,p_SDR_hdr_rec.supplier_site_id,p_SDR_hdr_rec.org_id,p_SDR_lines_tbl(i).inventory_item_id);
         FETCH c_vendor_item_code INTO  p_SDR_lines_tbl(i).vendor_item_code;
         CLOSE c_vendor_item_code;
      END IF;

    ELSIF p_SDR_lines_tbl(i).vendor_item_code <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).vendor_item_code IS NOT NULL THEN

         l_external_code := NULL;
         l_internal_code := NULL;
         OPEN  c_ext_int_code(p_SDR_hdr_rec.supplier_id,p_SDR_hdr_rec.supplier_site_id,p_SDR_hdr_rec.org_id);
         FETCH c_ext_int_code INTO l_external_code,l_internal_code;
         CLOSE c_ext_int_code;

         IF l_external_code IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_VENDOR_ITEM_CODE');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
             RETURN;
         END IF;
         p_SDR_lines_tbl(i).inventory_item_id := l_internal_code;

    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_INVENTORY_ITEM_ID');
          --//Inventory item id is mandatory
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;

   IF p_SDR_lines_tbl(i).item_uom <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).item_uom IS NOT NULL THEN

       OPEN  c_item_uom(p_SDR_lines_tbl(i).item_uom
                       ,p_SDR_lines_tbl(i).inventory_item_id
                       ,G_ITEM_ORG_ID);
       FETCH c_item_uom INTO l_item_uom;
       CLOSE c_item_uom;

       IF l_item_uom IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ITEM_UOM');
             --//Unit of Measurement is Invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_ITEM_UOM');
          --//Unit of Measurement is mandatory
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

 --//Product Cost Validation Bugfix: 7501046
  IF p_SDR_lines_tbl(i).product_cost = FND_API.g_miss_num OR p_SDR_lines_tbl(i).product_cost IS NULL THEN
    OPEN  c_product_cost(p_SDR_lines_tbl(i).inventory_item_id,G_ITEM_ORG_ID);
    FETCH c_product_cost INTO p_SDR_lines_tbl(i).product_cost;
    CLOSE c_product_cost;

    IF p_SDR_lines_tbl(i).product_cost IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_PRODUCT_COST');
          --//A value must be entered for Product Cost
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
  END IF;

--//Bugfix : 8511949  - Product Cost Currency Validation - If NULL is passed to API, get from Functional Currency, Else validate and process
  IF p_SDR_lines_tbl(i).product_cost_currency = FND_API.g_miss_char OR p_SDR_lines_tbl(i).product_cost_currency IS NULL THEN

     l_currency_var := NULL;
     OPEN  c_func_currency(p_SDR_hdr_rec.org_id);
     FETCH c_func_currency INTO p_SDR_lines_tbl(i).product_cost_currency;
     CLOSE c_func_currency;
  ELSE
     OPEN c_currency(p_SDR_lines_tbl(i).product_cost_currency);
     FETCH c_currency INTO l_currency_var;
     CLOSE c_currency;

     IF l_currency_var IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_INVALID_PROD_COST_CURR');
            FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;
  END IF;

--//PRODUCT CATEGORY
--===================
ELSIF p_SDR_lines_tbl(i).product_context ='PRODUCT_CATEGORY' THEN

   p_SDR_lines_tbl(i).inventory_item_id     := NULL;
   p_SDR_lines_tbl(i).vendor_item_code      := NULL;
   p_SDR_lines_tbl(i).item_uom              := NULL;
   p_SDR_lines_tbl(i).product_cost          := NULL;
   p_SDR_lines_tbl(i).product_cost_currency := NULL;

    --//Category ID
    IF p_SDR_lines_tbl(i).prod_catg_id <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).prod_catg_id IS NOT NULL THEN

       OPEN  c_category_id(p_SDR_lines_tbl(i).prod_catg_id);
       FETCH c_category_id INTO l_category_id;
       CLOSE c_category_id;

       IF l_category_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_PRODUCT_CATEGORY');
             --//Product category is Invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_PRODUCT_CATEGORY');
          --//Product category is mandatory
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;

    --//Category set id
    IF p_SDR_lines_tbl(i).product_cat_set_id <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).product_cat_set_id IS NOT NULL THEN

       OPEN  c_category_set_id(p_SDR_lines_tbl(i).prod_catg_id
                              ,p_SDR_lines_tbl(i).product_cat_set_id);
       FETCH c_category_set_id INTO l_category_set_id;
       CLOSE c_category_set_id;

       IF l_category_set_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_PRODUCT_CATEGORY_SET');
             --//Product category set is Invalid
            FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
    END IF;

END IF;

--//Requested discount type
IF p_SDR_lines_tbl(i).requested_discount_type <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).requested_discount_type IS NOT NULL THEN
l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                   p_lookup_table_name =>'OZF_LOOKUPS'
                  ,p_lookup_type       =>'OZF_SD_REQUEST_DISTYPE'
                  ,p_lookup_code       => p_SDR_lines_tbl(i).requested_discount_type);

  IF l_lookup_stat = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_DISCOUNT_TYPE');
         FND_MSG_PUB.add;
     END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_DISCOUNT_TYPE');
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Requested discount Value

IF p_SDR_lines_tbl(i).requested_discount_value = FND_API.g_miss_num OR p_SDR_lines_tbl(i).requested_discount_value IS NULL THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_DISC_VALUE');
      FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
 ELSE
   l_status := check_zero(p_SDR_lines_tbl(i).requested_discount_value);
    IF l_status = FND_API.g_false THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_DISCOUNT_VALUE_IS_ZERO');
           --//Discount value should not be zero
          FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
    END IF;
END IF;

--//Bugfix : 8511949 - Requested discount Currency Validation
--//For Discount type other than % , if requested_discount_currency is NULL, default it to Header Request Currency, Else Validate and Process.
IF p_SDR_lines_tbl(i).requested_discount_type <> '%' THEN
   IF p_SDR_lines_tbl(i).requested_discount_currency = FND_API.g_miss_char OR p_SDR_lines_tbl(i).requested_discount_currency IS NULL THEN
      p_SDR_lines_tbl(i).requested_discount_currency := p_SDR_hdr_rec.request_currency_code;
   ELSE
      l_currency_var := NULL;
      OPEN c_currency(p_SDR_lines_tbl(i).requested_discount_currency);
      FETCH c_currency INTO l_currency_var;
      CLOSE c_currency;

      IF l_currency_var IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_INVALID_REQ_DISC_CURR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
END IF;

--//Populating Cost Basis
--//Bugfix :8511949
IF p_SDR_lines_tbl(i).cost_basis <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).cost_basis IS NOT NULL THEN

   OPEN c_price_formula(p_SDR_lines_tbl(i).cost_basis);
   FETCH c_price_formula INTO l_formula_count;
   CLOSE c_price_formula;

   IF l_formula_count = 0 THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_COST_BASIS');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
ELSE
   --//Default cost basis only in Line create Mode
   IF p_SDR_lines_tbl(i).request_line_id = FND_API.g_miss_num OR p_SDR_lines_tbl(i).request_line_id IS NULL THEN
      OPEN  c_cost_basis(p_SDR_hdr_rec.supplier_id
                        ,p_SDR_hdr_rec.supplier_site_id
                        ,p_SDR_hdr_rec.org_id);
      FETCH c_cost_basis INTO p_SDR_lines_tbl(i).cost_basis;
      CLOSE c_cost_basis;
   END IF;
END IF;

--//Max Qty
IF p_SDR_lines_tbl(i).max_qty <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).max_qty IS NOT NULL THEN
   l_status := check_zero(p_SDR_lines_tbl(i).max_qty);
   IF l_status = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_MAX_QTY_ZERO_CHECK'); --//Check the message!
         --//Discount value should not be zero
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

--//Set limit Qty
  OPEN  c_qty_increase_tolerance(p_SDR_hdr_rec.supplier_id
                                ,p_SDR_hdr_rec.supplier_site_id
                                ,p_SDR_hdr_rec.org_id);
   FETCH c_qty_increase_tolerance INTO l_qty_increase_tolerance;
   CLOSE c_qty_increase_tolerance;

   p_SDR_lines_tbl(i).limit_qty := p_SDR_lines_tbl(i).max_qty + ((p_SDR_lines_tbl(i).max_qty * l_qty_increase_tolerance)/100);

END IF;

--//End Customer price
IF p_SDR_lines_tbl(i).end_customer_price <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).end_customer_price IS NOT NULL THEN
   l_status := check_zero(p_SDR_lines_tbl(i).end_customer_price);
   IF l_status = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_END_CUST_PRICE_VALUE_IS_ZERO');
         --//Discount value should not be zero
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
   --//End Customer Currency. Bugfix : 8511949, Introduced the validation
   IF p_SDR_lines_tbl(i).end_customer_currency <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).end_customer_currency IS NOT NULL THEN

      l_currency_var := NULL;
      OPEN c_currency(p_SDR_lines_tbl(i).end_customer_currency);
      FETCH c_currency INTO l_currency_var;
      CLOSE c_currency;

      IF l_currency_var IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_INVALID_END_CUST_CURR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
      p_SDR_lines_tbl(i).end_customer_currency := p_SDR_hdr_rec.request_currency_code;
   END IF;
ELSE
   p_SDR_lines_tbl(i).end_customer_currency := NULL;
END IF;



--Vendor Approved Flag
--//Bugfix : 9791659 - Changed <> to = in condition vendor_approved_flag = FND_API.g_miss_char
IF p_SDR_lines_tbl(i).vendor_approved_flag = FND_API.g_miss_char OR p_SDR_lines_tbl(i).vendor_approved_flag IS NULL THEN
   p_SDR_lines_tbl(i).vendor_approved_flag := 'Y';
ELSE
   IF  p_SDR_lines_tbl(i).vendor_approved_flag NOT IN ('Y','N')THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_VENDOR_AP_FLAG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;
--//Bugfix : 7607795
IF p_mode ='CREATE' THEN
    IF p_SDR_lines_tbl(i).start_date = FND_API.g_miss_date OR p_SDR_lines_tbl(i).start_date IS NULL THEN
      p_SDR_lines_tbl(i).start_date :=p_SDR_hdr_rec.request_start_date;

    ELSIF TRUNC(p_SDR_lines_tbl(i).start_date) NOT BETWEEN
       TRUNC(p_SDR_hdr_rec.request_start_date) AND TRUNC(p_SDR_hdr_rec.request_end_date) THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SD_LINE_START_DATE_CHECK');
               --//Start Date should fall in between Header Start date and End Date
               FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
             RETURN;
    END IF;

    --End Date
    IF p_SDR_lines_tbl(i).end_date = FND_API.g_miss_date OR p_SDR_lines_tbl(i).end_date IS NULL THEN
      p_SDR_lines_tbl(i).end_date :=p_SDR_hdr_rec.request_end_date;

    ELSIF TRUNC(p_SDR_lines_tbl(i).end_date) NOT BETWEEN
            TRUNC(p_SDR_hdr_rec.request_start_date) AND TRUNC(p_SDR_hdr_rec.request_end_date) THEN

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SD_LINE_END_DATE_CHECK');
               --//End Date should fall in between Header Start date and End Date
               FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
   END IF;
END IF;

IF p_SDR_lines_tbl(i).end_date < p_SDR_lines_tbl(i).start_date THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_LINE_END_DATE_GT_CHECK');
      --//End Date should be greater than start date
      FND_MSG_PUB.add;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
END IF;

p_SDR_lines_tbl(i).start_date := TRUNC(p_SDR_lines_tbl(i).start_date);
p_SDR_lines_tbl(i).end_date   := TRUNC(p_SDR_lines_tbl(i).end_date);

--//Price Type
IF p_SDR_lines_tbl(i).end_customer_price_type <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).end_customer_price_type IS NOT NULL THEN
    l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                       p_lookup_table_name =>'OZF_LOOKUPS'
                      ,p_lookup_type       =>'OZF_SD_PRICE_TYPE'
                      ,p_lookup_code       => p_SDR_lines_tbl(i).end_customer_price_type);

  IF l_lookup_stat = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_PRICE_TYPE');
         FND_MSG_PUB.add;
     END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;

--Tolerance Type
IF p_SDR_lines_tbl(i).end_customer_tolerance_type <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).end_customer_tolerance_type IS NOT NULL THEN
    l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                       p_lookup_table_name =>'OZF_LOOKUPS'
                      ,p_lookup_type       =>'OZF_SD_TOLERANCE_TYPE'
                      ,p_lookup_code       => p_SDR_lines_tbl(i).end_customer_tolerance_type);

      IF l_lookup_stat = FND_API.g_false THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_BAD_TOLERANCE_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
END IF;

--//Rejection Code
IF p_SDR_lines_tbl(i).rejection_code <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).rejection_code IS NOT NULL THEN
    l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                       p_lookup_table_name =>'OZF_LOOKUPS'
                      ,p_lookup_type       =>'OZF_SD_REQ_LINE_REJECT_CODE'
                      ,p_lookup_code       => p_SDR_lines_tbl(i).rejection_code);

  IF l_lookup_stat = FND_API.g_false THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REJECTION_CODE');
         FND_MSG_PUB.add;
     END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;
l_status_code := get_system_status_code(p_SDR_hdr_rec.user_status_id);
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Validate Product Lines Status Code :'||l_status_code);
END IF;

--//Bugfix : 8511949
--//Populate Approved discount type and Value in the following statuses. If value is not passed, default it from requested_discount_type and Value
IF l_status_code IN ('SUPPLIER_APPROVED'
		    ,'PENDING_SALES_APPROVAL'
		    ,'SALES_APPROVED'
		    ,'PENDING_OFFER_APPROVAL'
		    ,'ACTIVE') THEN
    IF G_DEBUG THEN
       OZF_UTILITY_PVT.debug_message('Validate Product Lines Status Code INSIDE');
    END IF;

   --//Approved discount type
   IF p_SDR_lines_tbl(i).approved_discount_type <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).approved_discount_type IS NOT NULL THEN
      l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                            p_lookup_table_name =>'OZF_LOOKUPS'
                           ,p_lookup_type       =>'OZF_SP_REQUEST_DISTYPE'
                           ,p_lookup_code       => p_SDR_lines_tbl(i).approved_discount_type);

      IF l_lookup_stat =FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_APPROVED_DISC_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
    ELSE
       p_SDR_lines_tbl(i).approved_discount_type := p_SDR_lines_tbl(i).requested_discount_type;
   END IF;

    --//Approved discount Value
    IF p_SDR_lines_tbl(i).approved_discount_value <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).approved_discount_value IS NOT NULL THEN
       l_status := check_zero(p_SDR_lines_tbl(i).approved_discount_value);
       IF l_status = FND_API.g_false THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_APPR_DISC_VALUE_IS_ZERO');
             FND_MSG_PUB.add;
           END IF;
           x_return_status := fnd_api.g_ret_sts_error;
           RETURN;
       END IF;
    ELSE
       p_SDR_lines_tbl(i).approved_discount_value := p_SDR_lines_tbl(i).requested_discount_value;
    END IF;

    --//Approved Discount Currency
    IF p_SDR_lines_tbl(i).approved_discount_currency <> FND_API.g_miss_char AND p_SDR_lines_tbl(i).approved_discount_currency IS NOT NULL THEN
       l_currency_var := NULL;
       OPEN c_currency(p_SDR_lines_tbl(i).approved_discount_currency);
       FETCH c_currency INTO l_currency_var;
       CLOSE c_currency;

       IF l_currency_var IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_INVALID_APPR_DISC_CURR');
             --//A value must be entered for Product Cost
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
    ELSE
       p_SDR_lines_tbl(i).approved_discount_currency := p_SDR_lines_tbl(i).requested_discount_currency;
    END IF;

    --//Approved Max Qty
    IF p_SDR_lines_tbl(i).approved_max_qty <> FND_API.g_miss_num AND p_SDR_lines_tbl(i).approved_max_qty IS NOT NULL THEN
       l_status := check_zero(p_SDR_lines_tbl(i).approved_max_qty);
       IF l_status = FND_API.g_false THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_APPR_MAX_QTY_VALUE_IS_ZERO');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
    ELSE
        p_SDR_lines_tbl(i).approved_max_qty :=  p_SDR_lines_tbl(i).max_qty;
    END IF;

    /* BugFix : 7501013
    ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_APPROVED_MAX_QTY');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN; */

ELSIF l_status_code IN ('DRAFT'
		       ,'ASSIGNED'
		       ,'PENDING_SUPPLIER_APPROVAL') THEN
   p_SDR_lines_tbl(i).approved_discount_type     := NULL;
   p_SDR_lines_tbl(i).approved_discount_value    := NULL;
   p_SDR_lines_tbl(i).approved_max_qty           := NULL;
   p_SDR_lines_tbl(i).approved_discount_currency := NULL;

END IF;

END LOOP;
END validate_product_lines;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_customer_items
--
-- PURPOSE
--    This procedure validates customer record table
--Parameters
--       p_SDR_cust_tbl   -Customer recordset
--      p_mode           -Insert /Update Mode
--      x_return_status - Result
---------------------------------------------------------------------
PROCEDURE validate_customer_items(
    p_SDR_cust_tbl       IN OUT NOCOPY  SDR_cust_tbl_type
   ,p_mode                IN             VARCHAR2
   ,x_return_status       OUT   NOCOPY   VARCHAR2
  )
IS
 l_lookup_stat          VARCHAR2(1); --To validate from lookups

 l_request_customer_id      NUMBER;
 l_cust_account_id          NUMBER;
 l_party_id                 NUMBER;
 l_site_use_id              NUMBER;
 l_old_cust_details         OZF_SD_REQUEST_PUB.SDR_cust_rec_type;


CURSOR c_request_customer_id(p_request_customer_id IN NUMBER,p_request_header_id IN NUMBER)IS
   SELECT request_customer_id
    FROM   ozf_sd_customer_details
    WHERE  request_customer_id = p_request_customer_id
    AND    request_header_id   = p_request_header_id ;

CURSOR c_party_id(p_party_id IN NUMBER)IS
   SELECT party_id
   FROM hz_parties
   WHERE party_id = p_party_id;

CURSOR c_cust_account_id(p_cust_account_id IN NUMBER)IS
    SELECT  cust_acct.cust_account_id
    FROM    hz_parties party,
            hz_cust_accounts cust_acct
    WHERE  cust_acct.party_id           = party.party_id
    AND     cust_acct.status            = 'A'
    AND     cust_acct.cust_account_id   = p_cust_account_id;

CURSOR c_site_use_id(p_cust_account_id IN NUMBER
                    ,p_party_id        IN NUMBER
                    ,p_site_use_id     IN NUMBER
                    ,p_site_use_code   IN VARCHAR2)IS
   SELECT sites.site_use_id
   FROM hz_cust_site_uses sites,
	    hz_cust_acct_sites acct_sites,
	    hz_party_sites party_sites
   WHERE sites.cust_acct_site_id    = acct_sites.cust_acct_site_id
   AND acct_sites.party_site_id     = party_sites.party_site_id
   AND acct_sites.cust_account_id   = p_cust_account_id
   AND party_sites.party_id         = p_party_id
   AND sites.site_use_id            = p_site_use_id
   AND sites.site_use_code          = p_site_use_code;

CURSOR c_old_cust_details(p_request_customer_id IN NUMBER)IS
   SELECT object_version_number,
          request_header_id,
          cust_account_id,
          party_id,
          site_use_id,
          cust_usage_code,
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
          end_customer_flag
   FROM ozf_sd_customer_details
   WHERE request_customer_id = p_request_customer_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

FOR j IN p_SDR_cust_tbl.FIRST..p_SDR_cust_tbl.LAST LOOP

--//Update Mode Check
IF p_mode ='UPDATE' THEN

   IF p_SDR_cust_tbl(j).request_customer_id <> FND_API.g_miss_num AND p_SDR_cust_tbl(j).request_customer_id IS NOT NULL THEN
      OPEN c_request_customer_id (p_SDR_cust_tbl(j).request_customer_id,G_REQUEST_HEADER_ID);
      FETCH c_request_customer_id INTO l_request_customer_id;
      CLOSE c_request_customer_id;

        IF l_request_customer_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQUEST_CUSTOMER_ID');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       ELSE
          --//Set old value to New If NULL.
          OPEN c_old_cust_details(p_SDR_cust_tbl(j).request_customer_id);
          FETCH c_old_cust_details INTO l_old_cust_details.object_version_number,
                                        l_old_cust_details.request_header_id,
                                        l_old_cust_details.cust_account_id,
                                        l_old_cust_details.party_id,
                                        l_old_cust_details.site_use_id,
                                        l_old_cust_details.cust_usage_code,
                                        l_old_cust_details.attribute_category,
                                        l_old_cust_details.attribute1,
                                        l_old_cust_details.attribute2,
                                        l_old_cust_details.attribute3,
                                        l_old_cust_details.attribute4,
                                        l_old_cust_details.attribute5,
                                        l_old_cust_details.attribute6,
                                        l_old_cust_details.attribute7,
                                        l_old_cust_details.attribute8,
                                        l_old_cust_details.attribute9,
                                        l_old_cust_details.attribute10,
                                        l_old_cust_details.attribute11,
                                        l_old_cust_details.attribute12,
                                        l_old_cust_details.attribute13,
                                        l_old_cust_details.attribute14,
                                        l_old_cust_details.attribute15,
                                        l_old_cust_details.end_customer_flag;
          CLOSE c_old_cust_details;
          p_SDR_cust_tbl(j).object_version_number	:= l_old_cust_details.object_version_number;
          p_SDR_cust_tbl(j).request_header_id		:= NVL(p_SDR_cust_tbl(j).request_header_id,l_old_cust_details.request_header_id);
          p_SDR_cust_tbl(j).cust_account_id		    := NVL(p_SDR_cust_tbl(j).cust_account_id,l_old_cust_details.cust_account_id);
          p_SDR_cust_tbl(j).party_id			    := NVL(p_SDR_cust_tbl(j).party_id,l_old_cust_details.party_id);
          p_SDR_cust_tbl(j).site_use_id			    := NVL(p_SDR_cust_tbl(j).site_use_id,l_old_cust_details.site_use_id);
          p_SDR_cust_tbl(j).cust_usage_code		    := NVL(p_SDR_cust_tbl(j).cust_usage_code,l_old_cust_details.cust_usage_code);
          p_SDR_cust_tbl(j).attribute_category		:= NVL(p_SDR_cust_tbl(j).attribute_category,l_old_cust_details.attribute_category);
          p_SDR_cust_tbl(j).attribute1			    := NVL(p_SDR_cust_tbl(j).attribute1,l_old_cust_details.attribute1);
          p_SDR_cust_tbl(j).attribute2			    := NVL(p_SDR_cust_tbl(j).attribute2,l_old_cust_details.attribute2);
          p_SDR_cust_tbl(j).attribute3			    := NVL(p_SDR_cust_tbl(j).attribute3,l_old_cust_details.attribute3);
          p_SDR_cust_tbl(j).attribute4			    := NVL(p_SDR_cust_tbl(j).attribute4,l_old_cust_details.attribute4);
          p_SDR_cust_tbl(j).attribute5			    := NVL(p_SDR_cust_tbl(j).attribute5,l_old_cust_details.attribute5);
          p_SDR_cust_tbl(j).attribute6			    := NVL(p_SDR_cust_tbl(j).attribute6,l_old_cust_details.attribute6);
          p_SDR_cust_tbl(j).attribute7			    := NVL(p_SDR_cust_tbl(j).attribute7,l_old_cust_details.attribute7);
          p_SDR_cust_tbl(j).attribute8			    := NVL(p_SDR_cust_tbl(j).attribute8,l_old_cust_details.attribute8);
          p_SDR_cust_tbl(j).attribute9			    := NVL(p_SDR_cust_tbl(j).attribute9,l_old_cust_details.attribute9);
          p_SDR_cust_tbl(j).attribute10			    := NVL(p_SDR_cust_tbl(j).attribute10,l_old_cust_details.attribute10);
          p_SDR_cust_tbl(j).attribute11			    := NVL(p_SDR_cust_tbl(j).attribute11,l_old_cust_details.attribute11);
          p_SDR_cust_tbl(j).attribute12			    := NVL(p_SDR_cust_tbl(j).attribute12,l_old_cust_details.attribute12);
          p_SDR_cust_tbl(j).attribute13			    := NVL(p_SDR_cust_tbl(j).attribute13,l_old_cust_details.attribute13);
          p_SDR_cust_tbl(j).attribute14			    := NVL(p_SDR_cust_tbl(j).attribute14,l_old_cust_details.attribute14);
          p_SDR_cust_tbl(j).attribute15			    := NVL(p_SDR_cust_tbl(j).attribute15,l_old_cust_details.attribute15);
          p_SDR_cust_tbl(j).end_customer_flag		:= NVL(p_SDR_cust_tbl(j).end_customer_flag,l_old_cust_details.end_customer_flag);
       END IF;
   END IF;
END IF;

--//End Customer Flag check
IF p_SDR_cust_tbl(j).end_customer_flag <> FND_API.g_miss_char AND p_SDR_cust_tbl(j).end_customer_flag IS NOT NULL THEN

   IF p_SDR_cust_tbl(j).end_customer_flag NOT IN ('N','Y') THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_END_CUST_FLAG');
         --//Invalid End Customer flag
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_END_CUST_FLAG');
      --//End Customer Flag is Mandatory
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Customer usage code Check
IF p_SDR_cust_tbl(j).cust_usage_code <> FND_API.g_miss_char AND p_SDR_cust_tbl(j).cust_usage_code IS NOT NULL THEN

   l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                       p_lookup_table_name =>'OZF_LOOKUPS'
                      ,p_lookup_type       =>'OZF_SD_CUSTOMER_TYPE'
                      ,p_lookup_code       => p_SDR_cust_tbl(j).cust_usage_code);

    IF l_lookup_stat = FND_API.g_false THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_ADDR_TYPE');
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;

    --//if end_customer_flag = 'Y' then cust_usage_code should be CUSTOMER only
    IF ((p_SDR_cust_tbl(j).end_customer_flag ='Y')
       AND (p_SDR_cust_tbl(j).cust_usage_code <> 'CUSTOMER')) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_COMB');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
    END IF;

     --//Party ID is mandatory for All Combinations
    IF p_SDR_cust_tbl(j).party_id <> FND_API.g_miss_num AND p_SDR_cust_tbl(j).party_id IS NOT NULL THEN
       OPEN c_party_id (p_SDR_cust_tbl(j).party_id);
       FETCH c_party_id INTO l_party_id;
       CLOSE c_party_id;

       IF l_party_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_PARTY_ID'); --//To set in design
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_PARTY_ID');
         --//Party Id is mandatory
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_SDR_cust_tbl(j).cust_usage_code ='CUSTOMER' THEN

      --//Cust Account ID
      IF p_SDR_cust_tbl(j).cust_account_id <> FND_API.g_miss_num AND p_SDR_cust_tbl(j).cust_account_id IS NOT NULL THEN
         OPEN c_cust_account_id (p_SDR_cust_tbl(j).cust_account_id);
         FETCH c_cust_account_id INTO l_cust_account_id;
         CLOSE c_cust_account_id;

          IF l_cust_account_id IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_ACCOUNT_ID');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
             RETURN;
           END IF;
       ELSE
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_CUST_ACCOUNT_ID');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;

   --//For Bill To/Ship To Site Use Id is Mandatory
   ELSIF p_SDR_cust_tbl(j).cust_usage_code IN ('BILL_TO','SHIP_TO') THEN

   --//Cust Account ID
      IF p_SDR_cust_tbl(j).cust_account_id <> FND_API.g_miss_num AND p_SDR_cust_tbl(j).cust_account_id IS NOT NULL THEN
         OPEN c_cust_account_id (p_SDR_cust_tbl(j).cust_account_id);
         FETCH c_cust_account_id INTO l_cust_account_id;
         CLOSE c_cust_account_id;

         IF l_cust_account_id IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_ACCOUNT_ID');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
          END IF;
      END IF;

      --//Site Use Id
       IF p_SDR_cust_tbl(j).site_use_id <> FND_API.g_miss_num AND p_SDR_cust_tbl(j).site_use_id IS NOT NULL THEN
          OPEN  c_site_use_id (p_SDR_cust_tbl(j).cust_account_id
                              ,p_SDR_cust_tbl(j).party_id
                              ,p_SDR_cust_tbl(j).site_use_id
                              ,p_SDR_cust_tbl(j).cust_usage_code);
          FETCH c_site_use_id INTO l_site_use_id;
          CLOSE c_site_use_id;

          IF l_site_use_id IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SITE_USE_ID');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
             RETURN;
           END IF;
       ELSE
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_SITE_USE_ID');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;
ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_CUST_ADDR_TYPE');
       --//Invalid Customer Usage Code
       FND_MSG_PUB.add;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
END IF;

END LOOP;
END validate_customer_items;

---------------------------------------------------------------------
-- PROCEDURE
--    Insert_SDR_Header_record
--
-- PURPOSE
--    This procedure Inserts record into SDR Header table
---------------------------------------------------------------------
PROCEDURE insert_header_record(
     p_SDR_hdr_rec                IN   SDR_Hdr_rec_type
    ,p_request_source             IN           VARCHAR2
    ,x_request_header_id          OUT NOCOPY   NUMBER
    ,x_return_status              OUT  NOCOPY  VARCHAR2)
IS

l_SDR_hdr_rec               OZF_SD_REQUEST_PUB.SDR_Hdr_rec_type   := p_SDR_hdr_rec;
l_req_hdr_seq                NUMBER;
l_code_prefix                VARCHAR2(3);
l_request_class              VARCHAR2(30):='SD_REQUEST';
--l_request_source             VARCHAR2(30) :='API';
l_root_request_header_id     NUMBER;

CURSOR c_reqest_header_seq IS
      SELECT OZF_SD_REQUEST_HEADERS_ALL_B_S.nextval
      FROM dual;

CURSOR c_code_prefix(p_request_type_setup_id IN NUMBER) IS
    SELECT source_code_suffix
    FROM ams_custom_setups_vl
    WHERE custom_setup_id = p_request_type_setup_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF G_DEBUG THEN
     OZF_UTILITY_PVT.debug_message('Inside INSERT HEADER RECORD Procedure ');
   END IF;

IF l_SDR_hdr_rec.request_basis IS NULL THEN
 l_SDR_hdr_rec.request_basis := FND_PROFILE.value('OZF_SD_REQUEST_BASED');
END IF;

OPEN c_reqest_header_seq;
FETCH c_reqest_header_seq INTO l_req_hdr_seq;
CLOSE c_reqest_header_seq;

--Generate Request Number, If Null
IF  l_SDR_hdr_rec.request_number = FND_API.g_miss_char OR l_SDR_hdr_rec.request_number IS NULL THEN

    OPEN  c_code_prefix(p_SDR_hdr_rec.request_type_setup_id);
    FETCH  c_code_prefix INTO l_code_prefix;
    CLOSE  c_code_prefix;

   l_SDR_hdr_rec.request_number :=l_code_prefix||TO_CHAR(l_req_hdr_seq);
   IF G_DEBUG THEN
     OZF_UTILITY_PVT.debug_message('Request Number : '||l_SDR_hdr_rec.request_number);
   END IF;

END IF;

IF l_SDR_hdr_rec.request_header_id IS NOT NULL THEN
    --//Set the root request header id for Copy
    l_root_request_header_id :=l_SDR_hdr_rec.request_header_id;
    IF G_DEBUG THEN
       OZF_UTILITY_PVT.debug_message('Root Request Header ID :'||l_root_request_header_id);
    END IF;
END IF;

OZF_SD_REQUEST_HEADER_PKG.Insert_Row(
    p_request_header_id             =>l_req_hdr_seq
   ,p_object_version_number         =>1
   ,p_last_update_date              =>SYSDATE
   ,p_last_updated_by               =>NVL(FND_GLOBAL.user_id,-1)
   ,p_creation_date                 =>SYSDATE
   ,p_created_by                    =>NVL(FND_GLOBAL.user_id,-1)
   ,p_last_update_login             =>NVL(FND_GLOBAL.conc_login_id,-1)
   ,p_request_id                    =>FND_GLOBAL.CONC_REQUEST_ID
   ,p_program_application_id        =>FND_GLOBAL.PROG_APPL_ID
   ,p_program_update_date           =>SYSDATE
   ,p_program_id                    =>FND_GLOBAL.CONC_PROGRAM_ID
   ,p_created_from                  =>NULL
   ,p_request_number                =>l_SDR_hdr_rec.request_number
   ,p_request_class                 =>l_request_class
   ,p_offer_type                    =>NULL
   ,p_offer_id                      =>NULL
   ,p_root_request_header_id        =>l_root_request_header_id
   ,p_linked_request_header_id      =>NULL
   ,p_request_start_date            =>l_SDR_hdr_rec.request_start_date
   ,p_request_end_date              =>l_SDR_hdr_rec.request_end_date
   ,p_user_status_id                =>l_SDR_hdr_rec.user_status_id
   ,p_request_outcome               =>l_SDR_hdr_rec.request_outcome
   ,p_decline_reason_code           =>NULL
   ,p_return_reason_code            =>NULL
   ,p_request_currency_code         =>l_SDR_hdr_rec.request_currency_code
   ,p_authorization_number          =>l_SDR_hdr_rec.authorization_number
   ,p_sd_requested_budget_amount    =>NULL
   ,p_sd_approved_budget_amount     =>NULL
   ,p_attribute_category            =>l_SDR_hdr_rec.attribute_category
   ,p_attribute1                    =>l_SDR_hdr_rec.attribute1
   ,p_attribute2                    =>l_SDR_hdr_rec.attribute2
   ,p_attribute3                    =>l_SDR_hdr_rec.attribute3
   ,p_attribute4                    =>l_SDR_hdr_rec.attribute4
   ,p_attribute5                    =>l_SDR_hdr_rec.attribute5
   ,p_attribute6                    =>l_SDR_hdr_rec.attribute6
   ,p_attribute7                    =>l_SDR_hdr_rec.attribute7
   ,p_attribute8                    =>l_SDR_hdr_rec.attribute8
   ,p_attribute9                    =>l_SDR_hdr_rec.attribute9
   ,p_attribute10                   =>l_SDR_hdr_rec.attribute10
   ,p_attribute11                   =>l_SDR_hdr_rec.attribute11
   ,p_attribute12                   =>l_SDR_hdr_rec.attribute12
   ,p_attribute13                   =>l_SDR_hdr_rec.attribute13
   ,p_attribute14                   =>l_SDR_hdr_rec.attribute14
   ,p_attribute15                   =>l_SDR_hdr_rec.attribute15
   ,p_supplier_id                   =>l_SDR_hdr_rec.supplier_id
   ,p_supplier_site_id              =>l_SDR_hdr_rec.supplier_site_id
   ,p_supplier_contact_id           =>l_SDR_hdr_rec.supplier_contact_id
   ,p_internal_submission_date      =>l_SDR_hdr_rec.internal_submission_date
   ,p_assignee_response_by_date     =>l_SDR_hdr_rec.assignee_response_by_date
   ,p_assignee_response_date        =>l_SDR_hdr_rec.assignee_response_date
   ,p_submtd_by_for_supp_appr       =>l_SDR_hdr_rec.submtd_by_for_supp_approval
   ,p_supplier_response_by_date     =>l_SDR_hdr_rec.supplier_response_by_date
   ,p_supplier_response_date        =>l_SDR_hdr_rec.supplier_response_date
   ,p_supplier_submission_date      =>l_SDR_hdr_rec.supplier_submission_date
   ,p_requestor_id                  =>l_SDR_hdr_rec.requestor_id
   ,p_supplier_quote_number         =>l_SDR_hdr_rec.supplier_quote_number
   ,p_internal_order_number         =>l_SDR_hdr_rec.internal_order_number
   ,p_sales_order_currency          =>l_SDR_hdr_rec.sales_order_currency
   ,p_request_source                => p_request_source
   ,p_assignee_resource_id          =>l_SDR_hdr_rec.assignee_resource_id
   ,p_org_id                        =>l_SDR_hdr_rec.org_id
   ,p_security_group_id             =>NULL
   ,p_accrual_type                  =>l_SDR_hdr_rec.accrual_type
   ,p_cust_account_id               =>l_SDR_hdr_rec.cust_account_id
   ,p_supplier_email                =>l_SDR_hdr_rec.supplier_contact_email_address
   ,p_supplier_phone                =>l_SDR_hdr_rec.supplier_contact_phone_number
   ,p_request_type_setup_id         =>l_SDR_hdr_rec.request_type_setup_id
   ,p_request_basis                 =>l_SDR_hdr_rec.request_basis
   ,p_supplier_contact_name         =>l_SDR_hdr_rec.supplier_contact_name); --//Bugfix : 7822442

x_request_header_id := l_req_hdr_seq;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
          FND_MSG_PUB.add;
      END IF;
End insert_header_record;
---------------------------------------------------------------------
-- PROCEDURE
--    Insert_translation_record
--
-- PURPOSE
--    This procedure Insert records into SDR TL table
---------------------------------------------------------------------
PROCEDURE populate_translation_record(
    p_request_header_id          IN   NUMBER,
    p_description                IN   VARCHAR2,
    p_org_id                     IN   NUMBER,
    p_mode                       IN    VARCHAR2,
    x_return_status              OUT  NOCOPY  VARCHAR2)
IS

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_mode ='CREATE' OR p_mode ='COPY' THEN

    INSERT INTO ozf_sd_request_headers_all_tl
           (request_header_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_description,
            language,
            source_lang,
            request_id,
            program_application_id,
            program_update_date,
            program_id,
            created_from,
            security_group_id,
            org_id)
   SELECT
           p_request_header_id,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.conc_login_id,-1),
           p_description,
	   l.language_code,
           USERENV('LANG'),
           FND_GLOBAL.CONC_REQUEST_ID,
           FND_GLOBAL.PROG_APPL_ID,
           SYSDATE,
           FND_GLOBAL.CONC_PROGRAM_ID,
           NULL,
           NULL,
           p_org_id
   FROM  fnd_languages l
   WHERE  l.installed_flag IN('I', 'B')
    AND NOT EXISTS(SELECT  NULL
                    FROM   ozf_sd_request_headers_all_tl t
                    WHERE  t.request_header_id = p_request_header_id
                     AND t.language            = l.language_code);

ELSIF p_mode ='UPDATE' THEN

  UPDATE ozf_sd_request_headers_all_tl
  SET request_description = p_description
      ,org_id             = p_org_id
   WHERE request_header_id =p_request_header_id;

END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_TL_POPULATION_ERROR');
           FND_MSG_PUB.add;
        END IF;

END populate_translation_record;
---------------------------------------------------------------------
-- PROCEDURE
--    Insert_SDR_lines_record
--
-- PURPOSE
--    This procedure Insert records into SDR Lines table
---------------------------------------------------------------------
PROCEDURE populate_product_lines(
    p_request_header_id          IN   NUMBER
   ,p_SDR_lines_tbl              IN   SDR_lines_tbl_type
   ,x_return_status              OUT  NOCOPY  VARCHAR2)

   --,p_SDR_lines_tbl              IN   SDR_lines_tbl_type

IS
  -- l_api_name                  CONSTANT VARCHAR2(30) := 'insert lines record';
  -- l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_req_line_seq               NUMBER;


CURSOR c_reqest_lines_seq IS
   SELECT ozf_sd_request_lines_all_s.nextval
   FROM dual;

BEGIN
-- Initialize API return status to sucess
x_return_status := FND_API.G_RET_STS_SUCCESS;

FOR p IN p_SDR_lines_tbl.FIRST..p_SDR_lines_tbl.LAST LOOP

  IF p_SDR_lines_tbl(p).request_line_id = FND_API.g_miss_num OR p_SDR_lines_tbl(p).request_line_id IS NULL THEN

  IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('populate_product_lines - Create Mode');
    OZF_UTILITY_PVT.debug_message('Count :'||p_SDR_lines_tbl.count);
  END IF;

    OPEN  c_reqest_lines_seq;
    FETCH c_reqest_lines_seq INTO l_req_line_seq;
    CLOSE c_reqest_lines_seq;

    OZF_SD_REQUEST_LINES_PKG.Insert_Row(
        p_request_line_id                  =>l_req_line_seq
       ,p_object_version_number            =>1
       ,p_last_update_date                 =>SYSDATE
       ,p_last_updated_by                  =>NVL(FND_GLOBAL.user_id,-1)
       ,p_creation_date                    =>SYSDATE
       ,p_created_by                       =>NVL(FND_GLOBAL.user_id,-1)
       ,p_last_update_login                =>NVL(FND_GLOBAL.conc_login_id,-1)
       ,p_request_id                       =>FND_GLOBAL.CONC_REQUEST_ID
       ,p_program_application_id           =>FND_GLOBAL.PROG_APPL_ID
       ,p_program_update_date              =>SYSDATE
       ,p_program_id                       =>FND_GLOBAL.CONC_PROGRAM_ID
       ,p_create_from                      =>NULL
       ,p_request_header_id                =>p_request_header_id
       ,p_product_context                  =>p_SDR_lines_tbl(p).product_context
       ,p_inventory_item_id                =>p_SDR_lines_tbl(p).inventory_item_id
       ,p_prod_catg_id                     =>p_SDR_lines_tbl(p).prod_catg_id
       ,p_product_cat_set_id               =>p_SDR_lines_tbl(p).product_cat_set_id
       ,p_product_cost                     =>p_SDR_lines_tbl(p).product_cost
       ,p_item_uom                         =>p_SDR_lines_tbl(p).item_uom
       ,p_requested_discount_type          =>p_SDR_lines_tbl(p).requested_discount_type
       ,p_requested_discount_value         =>p_SDR_lines_tbl(p).requested_discount_value
       ,p_cost_basis                       =>p_SDR_lines_tbl(p).cost_basis
       ,p_max_qty                          =>p_SDR_lines_tbl(p).max_qty
       ,p_limit_qty                        =>p_SDR_lines_tbl(p).limit_qty
       ,p_design_win                       =>p_SDR_lines_tbl(p).design_win
       ,p_end_customer_price               =>p_SDR_lines_tbl(p).end_customer_price
       ,p_requested_line_amount            =>p_SDR_lines_tbl(p).requested_line_amount
       ,p_approved_discount_type           =>p_SDR_lines_tbl(p).approved_discount_type
       ,p_approved_discount_value          =>p_SDR_lines_tbl(p).approved_discount_value
       ,p_approved_amount                  =>NULL
       ,p_total_requested_amount           =>NULL
       ,p_total_approved_amount            =>NULL
       ,p_approved_max_qty                 =>p_SDR_lines_tbl(p).approved_max_qty
       ,p_attribute_category               =>p_SDR_lines_tbl(p).attribute_category
       ,p_attribute1                       =>p_SDR_lines_tbl(p).attribute1
       ,p_attribute2                       =>p_SDR_lines_tbl(p).attribute2
       ,p_attribute3                       =>p_SDR_lines_tbl(p).attribute3
       ,p_attribute4                       =>p_SDR_lines_tbl(p).attribute4
       ,p_attribute5                       =>p_SDR_lines_tbl(p).attribute5
       ,p_attribute6                       =>p_SDR_lines_tbl(p).attribute6
       ,p_attribute7                       =>p_SDR_lines_tbl(p).attribute7
       ,p_attribute8                       =>p_SDR_lines_tbl(p).attribute8
       ,p_attribute9                       =>p_SDR_lines_tbl(p).attribute9
       ,p_attribute10                      =>p_SDR_lines_tbl(p).attribute10
       ,p_attribute11                      =>p_SDR_lines_tbl(p).attribute11
       ,p_attribute12                      =>p_SDR_lines_tbl(p).attribute12
       ,p_attribute13                      =>p_SDR_lines_tbl(p).attribute13
       ,p_attribute14                      =>p_SDR_lines_tbl(p).attribute14
       ,p_attribute15                      =>p_SDR_lines_tbl(p).attribute15
       ,p_vendor_approved_flag             =>p_SDR_lines_tbl(p).vendor_approved_flag
       ,p_vendor_item_code                 =>p_SDR_lines_tbl(p).vendor_item_code
       ,p_start_date                       =>p_SDR_lines_tbl(p).start_date
       ,p_end_date                         =>p_SDR_lines_tbl(p).end_date
       ,p_end_customer_price_type          =>p_SDR_lines_tbl(p).end_customer_price_type
       ,p_end_customer_tolerance_type      =>p_SDR_lines_tbl(p).end_customer_tolerance_type
       ,p_end_customer_tolerance_value     =>p_SDR_lines_tbl(p).end_customer_tolerance_value
       ,p_security_group_id                =>NULL
       ,p_org_id                           =>G_ITEM_ORG_ID
       ,p_rejection_code                   =>p_SDR_lines_tbl(p).rejection_code
       ,p_discount_currency                =>p_SDR_lines_tbl(p).requested_discount_currency
       ,p_product_cost_currency            =>p_SDR_lines_tbl(p).product_cost_currency
       ,p_end_customer_currency            =>p_SDR_lines_tbl(p).end_customer_currency
       ,p_approved_discount_currency       =>p_SDR_lines_tbl(p).approved_discount_currency);

  ELSE  --UPDATE MODE
   OZF_SD_REQUEST_LINES_PKG.Update_Row(
        p_request_line_id                  =>p_SDR_lines_tbl(p).request_line_id
       ,p_object_version_number            =>p_SDR_lines_tbl(p).object_version_number + 1
       ,p_last_update_date                 =>SYSDATE
       ,p_last_updated_by                  =>NVL(FND_GLOBAL.user_id,-1)
       ,p_last_update_login                =>NVL(FND_GLOBAL.conc_login_id,-1)
       ,p_request_id                       =>FND_GLOBAL.CONC_REQUEST_ID
       ,p_program_application_id           =>FND_GLOBAL.PROG_APPL_ID
       ,p_program_update_date              =>SYSDATE
       ,p_program_id                       =>FND_GLOBAL.CONC_PROGRAM_ID
       ,p_create_from                      =>NULL
       ,p_request_header_id                =>p_request_header_id
       ,p_product_context                  =>p_SDR_lines_tbl(p).product_context
       ,p_inventory_item_id                =>p_SDR_lines_tbl(p).inventory_item_id
       ,p_prod_catg_id                     =>p_SDR_lines_tbl(p).prod_catg_id
       ,p_product_cat_set_id               =>p_SDR_lines_tbl(p).product_cat_set_id
       ,p_product_cost                     =>p_SDR_lines_tbl(p).product_cost
       ,p_item_uom                         =>p_SDR_lines_tbl(p).item_uom
       ,p_requested_discount_type          =>p_SDR_lines_tbl(p).requested_discount_type
       ,p_requested_discount_value         =>p_SDR_lines_tbl(p).requested_discount_value
       ,p_cost_basis                       =>p_SDR_lines_tbl(p).cost_basis
       ,p_max_qty                          =>p_SDR_lines_tbl(p).max_qty
       ,p_limit_qty                        =>p_SDR_lines_tbl(p).limit_qty
       ,p_design_win                       =>p_SDR_lines_tbl(p).design_win
       ,p_end_customer_price               =>p_SDR_lines_tbl(p).end_customer_price
       ,p_requested_line_amount            =>p_SDR_lines_tbl(p).requested_line_amount
       ,p_approved_discount_type           =>p_SDR_lines_tbl(p).approved_discount_type
       ,p_approved_discount_value          =>p_SDR_lines_tbl(p).approved_discount_value
       ,p_approved_amount                  =>NULL
       ,p_total_requested_amount           =>NULL
       ,p_total_approved_amount            =>NULL
       ,p_approved_max_qty                 =>p_SDR_lines_tbl(p).approved_max_qty
       ,p_attribute_category               =>p_SDR_lines_tbl(p).attribute_category
       ,p_attribute1                       =>p_SDR_lines_tbl(p).attribute1
       ,p_attribute2                       =>p_SDR_lines_tbl(p).attribute2
       ,p_attribute3                       =>p_SDR_lines_tbl(p).attribute3
       ,p_attribute4                       =>p_SDR_lines_tbl(p).attribute4
       ,p_attribute5                       =>p_SDR_lines_tbl(p).attribute5
       ,p_attribute6                       =>p_SDR_lines_tbl(p).attribute6
       ,p_attribute7                       =>p_SDR_lines_tbl(p).attribute7
       ,p_attribute8                       =>p_SDR_lines_tbl(p).attribute8
       ,p_attribute9                       =>p_SDR_lines_tbl(p).attribute9
       ,p_attribute10                      =>p_SDR_lines_tbl(p).attribute10
       ,p_attribute11                      =>p_SDR_lines_tbl(p).attribute11
       ,p_attribute12                      =>p_SDR_lines_tbl(p).attribute12
       ,p_attribute13                      =>p_SDR_lines_tbl(p).attribute13
       ,p_attribute14                      =>p_SDR_lines_tbl(p).attribute14
       ,p_attribute15                      =>p_SDR_lines_tbl(p).attribute15
       ,p_vendor_approved_flag             =>p_SDR_lines_tbl(p).vendor_approved_flag
       ,p_vendor_item_code                 =>p_SDR_lines_tbl(p).vendor_item_code
       ,p_start_date                       =>p_SDR_lines_tbl(p).start_date
       ,p_end_date                         =>p_SDR_lines_tbl(p).end_date
       ,p_end_customer_price_type          =>p_SDR_lines_tbl(p).end_customer_price_type
       ,p_end_customer_tolerance_type      =>p_SDR_lines_tbl(p).end_customer_tolerance_type
       ,p_end_customer_tolerance_value     =>p_SDR_lines_tbl(p).end_customer_tolerance_value
       ,p_security_group_id                =>NULL--p_SDR_lines_tbl(p).security_group_id
       ,p_org_id                           =>G_ITEM_ORG_ID
       ,p_rejection_code                   =>p_SDR_lines_tbl(p).rejection_code
       ,p_discount_currency                =>p_SDR_lines_tbl(p).requested_discount_currency
       ,p_product_cost_currency            =>p_SDR_lines_tbl(p).product_cost_currency
       ,p_end_customer_currency            =>p_SDR_lines_tbl(p).end_customer_currency
       ,p_approved_discount_currency       =>p_SDR_lines_tbl(p).approved_discount_currency);
   END IF;
 END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
       x_return_status := FND_API.g_ret_sts_unexp_error;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
           FND_MSG_PUB.add;
        END IF;

END populate_product_lines;

---------------------------------------------------------------------
-- PROCEDURE
--    populate_customer_details.
--
-- PURPOSE
--    This procedure Insert records into SDR Lines table
---------------------------------------------------------------------
PROCEDURE populate_customer_details(
    p_request_header_id          IN   NUMBER
   ,p_SDR_cust_tbl               IN   SDR_cust_tbl_type
   ,x_return_status              OUT  NOCOPY  VARCHAR2)
IS

l_request_cust_seq          NUMBER;
l_cust_count                NUMBER;

CURSOR c_reqest_cust_seq IS
   SELECT OZF_SD_CUSTOMER_DETAILS_S.nextval
   FROM dual;

CURSOR c_cust_details(p_request_header_id IN NUMBER
                     ,p_cust_usage_code   IN VARCHAR2
                     ,p_party_id          IN NUMBER
                     ,p_cust_account_id   IN NUMBER
		     ,p_site_use_id       IN NUMBER --//Bugfix :8724614
                     ,p_end_customer_flag IN VARCHAR2)IS
   SELECT COUNT(1)
   FROM   ozf_sd_customer_details
   WHERE  request_header_id  = p_request_header_id
   AND    cust_usage_code    = p_cust_usage_code
   AND    party_id           = p_party_id
   AND    cust_account_id    = p_cust_account_id
   AND    NVL(site_use_id,0) = NVL(p_site_use_id,0) --//Bugfix :8724614
   AND    end_customer_flag  = p_end_customer_flag;

BEGIN
-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Inside populate_customer_details');
END IF;

FOR c IN p_SDR_cust_tbl.FIRST..p_SDR_cust_tbl.LAST LOOP

--//Duplicate check for Customers

   l_cust_count :=0;
   OPEN  c_cust_details(p_request_header_id
                       ,p_SDR_cust_tbl(c).cust_usage_code
                       ,p_SDR_cust_tbl(c).party_id
                       ,p_SDR_cust_tbl(c).cust_account_id
		       ,p_SDR_cust_tbl(c).site_use_id
                       ,p_SDR_cust_tbl(c).end_customer_flag);
   FETCH c_cust_details INTO l_cust_count;
   CLOSE c_cust_details;

   IF l_cust_count <> 0 THEN

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Duplicate Customer/End Customer ');
         OZF_UTILITY_PVT.debug_message('Cust Usage Code   :'||p_SDR_cust_tbl(c).cust_usage_code);
         OZF_UTILITY_PVT.debug_message('Party Id          :'||p_SDR_cust_tbl(c).party_id);
         OZF_UTILITY_PVT.debug_message('Cust Account id   :'||p_SDR_cust_tbl(c).cust_account_id);
	 OZF_UTILITY_PVT.debug_message('Site use id       :'||p_SDR_cust_tbl(c).site_use_id);
         OZF_UTILITY_PVT.debug_message('End Customer Flag :'||p_SDR_cust_tbl(c).end_customer_flag);
      END IF;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         IF p_SDR_cust_tbl(c).end_customer_flag = 'Y' THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_REQ_DUP_END_CUST');
         ELSE
            FND_MESSAGE.set_name('OZF', 'OZF_SD_REQ_DUP_CUSTOMER');
         END IF;
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_SDR_cust_tbl(c).request_customer_id = FND_API.g_miss_num OR p_SDR_cust_tbl(c).request_customer_id IS NULL THEN
   --//Create mode
       OPEN  c_reqest_cust_seq;
       FETCH c_reqest_cust_seq INTO l_request_cust_seq;
       CLOSE c_reqest_cust_seq;

        OZF_SD_CUSTOMER_PKG.Insert_Row(
            p_request_customer_id        =>l_request_cust_seq
           ,p_request_header_id      	 =>p_request_header_id
           ,p_cust_account_id        	 =>p_SDR_cust_tbl(c).cust_account_id
           ,p_party_id               	 =>p_SDR_cust_tbl(c).party_id
           ,p_site_use_id            	 =>p_SDR_cust_tbl(c).site_use_id
           ,p_cust_usage_code	         =>p_SDR_cust_tbl(c).cust_usage_code
           ,p_security_group_id      	 =>NULL
           ,p_creation_date          	 =>SYSDATE
           ,p_created_by             	 =>NVL(FND_GLOBAL.user_id,-1)
           ,p_last_update_date       	 =>SYSDATE
           ,p_last_updated_by        	 =>NVL(FND_GLOBAL.user_id,-1)
           ,p_last_update_login      	 =>NVL(FND_GLOBAL.conc_login_id,-1)
           ,p_object_version_number  	 =>1
           ,p_attribute_category     	 =>p_SDR_cust_tbl(c).attribute_category
           ,p_attribute1             	 =>p_SDR_cust_tbl(c).attribute1
           ,p_attribute2             	 =>p_SDR_cust_tbl(c).attribute2
           ,p_attribute3             	 =>p_SDR_cust_tbl(c).attribute3
           ,p_attribute4             	 =>p_SDR_cust_tbl(c).attribute4
           ,p_attribute5             	 =>p_SDR_cust_tbl(c).attribute5
           ,p_attribute6             	 =>p_SDR_cust_tbl(c).attribute6
           ,p_attribute7             	 =>p_SDR_cust_tbl(c).attribute7
           ,p_attribute8             	 =>p_SDR_cust_tbl(c).attribute8
           ,p_attribute9             	 =>p_SDR_cust_tbl(c).attribute9
           ,p_attribute10            	 =>p_SDR_cust_tbl(c).attribute10
           ,p_attribute11            	 =>p_SDR_cust_tbl(c).attribute11
           ,p_attribute12            	 =>p_SDR_cust_tbl(c).attribute12
           ,p_attribute13            	 =>p_SDR_cust_tbl(c).attribute13
           ,p_attribute14            	 =>p_SDR_cust_tbl(c).attribute14
           ,p_attribute15		 =>p_SDR_cust_tbl(c).attribute15
           ,p_end_customer_flag          =>p_SDR_cust_tbl(c).end_customer_flag);
   ELSE
      OZF_SD_CUSTOMER_PKG.Update_Row(
         p_request_customer_id		 =>p_SDR_cust_tbl(c).request_customer_id
        ,p_request_header_id      	 =>p_request_header_id
        ,p_cust_account_id        	 =>p_SDR_cust_tbl(c).cust_account_id
        ,p_party_id               	 =>p_SDR_cust_tbl(c).party_id
        ,p_site_use_id            	 =>p_SDR_cust_tbl(c).site_use_id
        ,p_cust_usage_code	         =>p_SDR_cust_tbl(c).cust_usage_code
        ,p_security_group_id      	 =>NULL
        ,p_last_update_date       	 =>SYSDATE
        ,p_last_updated_by        	 =>NVL(FND_GLOBAL.user_id,-1)
        ,p_last_update_login      	 =>NVL(FND_GLOBAL.conc_login_id,-1)
        ,p_object_version_number  	 =>p_SDR_cust_tbl(c).object_version_number + 1
        ,p_attribute_category     	 =>p_SDR_cust_tbl(c).attribute_category
        ,p_attribute1             	 =>p_SDR_cust_tbl(c).attribute1
        ,p_attribute2             	 =>p_SDR_cust_tbl(c).attribute2
        ,p_attribute3             	 =>p_SDR_cust_tbl(c).attribute3
        ,p_attribute4             	 =>p_SDR_cust_tbl(c).attribute4
        ,p_attribute5             	 =>p_SDR_cust_tbl(c).attribute5
        ,p_attribute6             	 =>p_SDR_cust_tbl(c).attribute6
        ,p_attribute7             	 =>p_SDR_cust_tbl(c).attribute7
        ,p_attribute8             	 =>p_SDR_cust_tbl(c).attribute8
        ,p_attribute9             	 =>p_SDR_cust_tbl(c).attribute9
        ,p_attribute10            	 =>p_SDR_cust_tbl(c).attribute10
        ,p_attribute11            	 =>p_SDR_cust_tbl(c).attribute11
        ,p_attribute12            	 =>p_SDR_cust_tbl(c).attribute12
        ,p_attribute13            	 =>p_SDR_cust_tbl(c).attribute13
        ,p_attribute14            	 =>p_SDR_cust_tbl(c).attribute14
        ,p_attribute15		         =>p_SDR_cust_tbl(c).attribute15
        ,p_end_customer_flag		 =>p_SDR_cust_tbl(c).end_customer_flag);

   END IF;
END LOOP;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
         FND_MSG_PUB.add;
      END IF;
END populate_customer_details;
---------------------------------------------------------------------
-- PROCEDURE
--    update_header_record
--
---------------------------------------------------------------------
PROCEDURE update_header_record(
    p_SDR_hdr_rec                IN   SDR_Hdr_rec_type
   ,x_return_status              OUT  NOCOPY  VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_SDR';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  x_msg_count               NUMBER;
  x_msg_data                VARCHAR2(30);
  l_status_code             VARCHAR2(30);
  l_qp_list_header_id       NUMBER;
  l_error_location          NUMBER;
  l_offer_type              VARCHAR2(30);


CURSOR c_qp_list_header_id(p_request_header_id IN NUMBER)IS
    SELECT offer_id
    FROM ozf_sd_request_headers_all_b
    WHERE request_header_id =p_request_header_id;
/*
 --//To check the offer status
CURSOR c_offer_status_code (p_qp_list_header_id IN NUMBER)IS
   SELECT status_code
   FROM  ozf_offers
   WHERE qp_list_header_id = p_qp_list_header_id;
*/

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

--//Update process
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Invokes Update Row');
END IF;

   OPEN c_qp_list_header_id(p_SDR_hdr_rec.request_header_id);
   FETCH c_qp_list_header_id INTO l_qp_list_header_id;
   CLOSE c_qp_list_header_id;

   IF l_qp_list_header_id IS NOT NULL THEN
     l_offer_type :='ACCRUAL';
   END IF;


OZF_SD_REQUEST_HEADER_PKG.Update_Row(
    p_request_header_id	            =>p_SDR_hdr_rec.request_header_id
   ,p_object_version_number         =>p_SDR_hdr_rec.object_version_number + 1
   ,p_last_update_date              =>SYSDATE
   ,p_last_updated_by               =>NVL(FND_GLOBAL.user_id,-1)
   ,p_last_update_login             =>NVL(FND_GLOBAL.conc_login_id,-1)
   ,p_request_id                    =>FND_GLOBAL.CONC_REQUEST_ID
   ,p_program_application_id        =>FND_GLOBAL.PROG_APPL_ID
   ,p_program_update_date           =>SYSDATE
   ,p_program_id                    =>FND_GLOBAL.CONC_PROGRAM_ID
   ,p_created_from                  =>NULL
   ,p_request_number                =>p_SDR_hdr_rec.request_number
   ,p_request_class                 =>'SD_REQUEST'
   ,p_offer_type                    =>l_offer_type
   ,p_offer_id                      =>l_qp_list_header_id
   ,p_root_request_header_id        =>NULL
   ,p_linked_request_header_id      =>NULL
   ,p_request_start_date            =>p_SDR_hdr_rec.request_start_date
   ,p_request_end_date              =>p_SDR_hdr_rec.request_end_date
   ,p_user_status_id                =>p_SDR_hdr_rec.user_status_id
   ,p_request_outcome               =>p_SDR_hdr_rec.request_outcome
   ,p_decline_reason_code           =>NULL
   ,p_return_reason_code            =>NULL
   ,p_request_currency_code         =>p_SDR_hdr_rec.request_currency_code
   ,p_authorization_number          =>p_SDR_hdr_rec.authorization_number
   ,p_sd_requested_budget_amount    =>NULL
   ,p_sd_approved_budget_amount     =>NULL
   ,p_attribute_category            =>p_SDR_hdr_rec.attribute_category
   ,p_attribute1                    =>p_SDR_hdr_rec.attribute1
   ,p_attribute2                    =>p_SDR_hdr_rec.attribute2
   ,p_attribute3                    =>p_SDR_hdr_rec.attribute3
   ,p_attribute4                    =>p_SDR_hdr_rec.attribute4
   ,p_attribute5                    =>p_SDR_hdr_rec.attribute5
   ,p_attribute6                    =>p_SDR_hdr_rec.attribute6
   ,p_attribute7                    =>p_SDR_hdr_rec.attribute7
   ,p_attribute8                    =>p_SDR_hdr_rec.attribute8
   ,p_attribute9                    =>p_SDR_hdr_rec.attribute9
   ,p_attribute10                   =>p_SDR_hdr_rec.attribute10
   ,p_attribute11                   =>p_SDR_hdr_rec.attribute11
   ,p_attribute12                   =>p_SDR_hdr_rec.attribute12
   ,p_attribute13                   =>p_SDR_hdr_rec.attribute13
   ,p_attribute14                   =>p_SDR_hdr_rec.attribute14
   ,p_attribute15                   =>p_SDR_hdr_rec.attribute15
   ,p_supplier_id                   =>p_SDR_hdr_rec.supplier_id
   ,p_supplier_site_id              =>p_SDR_hdr_rec.supplier_site_id
   ,p_supplier_contact_id           =>p_SDR_hdr_rec.supplier_contact_id
   ,p_internal_submission_date      =>p_SDR_hdr_rec.internal_submission_date
   ,p_assignee_response_by_date     =>p_SDR_hdr_rec.assignee_response_by_date
   ,p_assignee_response_date        =>p_SDR_hdr_rec.assignee_response_date
   ,p_submtd_by_for_supp_appr       =>p_SDR_hdr_rec.submtd_by_for_supp_approval
   ,p_supplier_response_by_date     =>p_SDR_hdr_rec.supplier_response_by_date
   ,p_supplier_response_date        =>p_SDR_hdr_rec.supplier_response_date
   ,p_supplier_submission_date      =>p_SDR_hdr_rec.supplier_submission_date
   ,p_requestor_id                  =>p_SDR_hdr_rec.requestor_id
   ,p_supplier_quote_number         =>p_SDR_hdr_rec.supplier_quote_number
   ,p_internal_order_number         =>p_SDR_hdr_rec.internal_order_number
   ,p_sales_order_currency          =>p_SDR_hdr_rec.sales_order_currency
   ,p_request_source                =>'API'
   ,p_assignee_resource_id          =>p_SDR_hdr_rec.assignee_resource_id
   ,p_org_id                        =>p_SDR_hdr_rec.org_id
   ,p_security_group_id             =>NULL
   ,p_accrual_type                  =>p_SDR_hdr_rec.accrual_type
   ,p_cust_account_id               =>p_SDR_hdr_rec.cust_account_id
   ,p_supplier_email                =>p_SDR_hdr_rec.supplier_contact_email_address
   ,p_supplier_phone                =>p_SDR_hdr_rec.supplier_contact_phone_number
   ,p_request_type_setup_id         =>p_SDR_hdr_rec.request_type_setup_id
   ,p_request_basis                 =>p_SDR_hdr_rec.request_basis
   ,p_supplier_contact_name         =>p_SDR_hdr_rec.supplier_contact_name); --//Bugfix : 7822442

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('End update_header_record');
END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message(SQLERRM);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
         FND_MSG_PUB.add;
      END IF;

END update_header_record;
---------------------------------------------------------------------
-- PROCEDURE
--    create_sd_request
--
-- PURPOSE
--    Public API for creating SDR
---------------------------------------------------------------------

PROCEDURE create_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_SDR_hdr_rec                IN   SDR_Hdr_rec_type,
    p_SDR_lines_tbl              IN   SDR_lines_tbl_type,
    p_SDR_cust_tbl               IN   SDR_cust_tbl_type ,
    x_request_header_id          OUT NOCOPY  NUMBER)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_sd_request';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_SDR_rec                    OZF_SD_REQUEST_PUB.SDR_Hdr_rec_type   := p_SDR_hdr_rec;
   l_SDR_lines_tbl              OZF_SD_REQUEST_PUB.SDR_lines_tbl_type := p_SDR_lines_tbl;
   l_SDR_cust_tbl               OZF_SD_REQUEST_PUB.SDR_cust_tbl_type  := p_SDR_cust_tbl;

   l_line_rec_flag              VARCHAR2(1):='N';
   l_cust_rec_flag              VARCHAR2(1):='N';
   l_user_id                    NUMBER;
   l_resource_id                NUMBER;
   l_system_status_code         VARCHAR2(100);
   l_request_type_setup_id      NUMBER;
   l_request_type               VARCHAR2(100);
   l_request_number             VARCHAR2(30);
   l_lookup_check               VARCHAR2(1); --To validate from lookups

CURSOR c_request_type_setup(p_request_type_setup_id IN NUMBER)IS
    SELECT custom_setup_id,
	       activity_type_code
    FROM  ams_custom_setups_vl
    WHERE object_type     = 'SDREQUEST'
    AND   enabled_flag    = 'Y'
    AND   custom_setup_id = p_request_type_setup_id;

CURSOR c_request_number(p_request_number IN VARCHAR2)IS
    SELECT  request_number
    FROM    ozf_sd_request_headers_all_b
    WHERE   request_number =p_request_number;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT CREATE_SDR_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
   p_api_version_number,
   l_api_name,
   G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
   FND_MSG_PUB.initialize;
END IF;
-- Debug Message
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' PUB start');
END IF;
-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

--//API Body
--========================================================================
--//Validations

--//Accrual type Validation
IF  l_SDR_rec.accrual_type <> FND_API.g_miss_char AND l_SDR_rec.accrual_type IS NOT NULL THEN

    l_lookup_check :=OZF_UTILITY_PVT.check_lookup_exists(
                         p_lookup_table_name =>'OZF_LOOKUPS'
                        ,p_lookup_type       =>'OZF_SDR_ACCRUAL_TYPE'
                        ,p_lookup_code       => l_SDR_rec.accrual_type);

     IF l_lookup_check = FND_API.g_false THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ACCRUAL_TYPE');
             FND_MSG_PUB.add;
         END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_ACCRUAL_TYPE');
      --//Accrual type is Mandatory
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Set default user status id
IF l_SDR_rec.user_status_id = FND_API.g_miss_num OR l_SDR_rec.user_status_id IS NULL THEN
    l_SDR_rec.user_status_id :=get_user_status_id('DRAFT');
END IF;
l_system_status_code := get_system_status_code(l_SDR_rec.user_status_id);

   IF l_system_status_code IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_USER_STATUS_ID');
         --//User status id entered is invalid
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

  --//Accrual type wise status check
   IF l_SDR_rec.accrual_type ='SUPPLIER' THEN
      IF l_system_status_code NOT IN ('DRAFT','ASSIGNED','SUPPLIER_APPROVED') THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CREATE_STATUS');
            --//User status id entered is invalid for Create
            FND_MSG_PUB.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

    ELSIF l_SDR_rec.accrual_type ='INTERNAL' THEN
       IF l_system_status_code <> 'DRAFT' THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CREATE_STATUS_I');
             --//User status id entered is invalid for Create
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

    IF G_DEBUG THEN
       OZF_UTILITY_PVT.debug_message('User Status id '||l_SDR_rec.user_status_id);
       OZF_UTILITY_PVT.debug_message('l_system_status_code :'||l_system_status_code);
    END IF;

IF (l_system_status_code <> 'DRAFT') AND (p_SDR_lines_tbl.count = 0) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_PRODUCT_RECORDS');
       --//Product Line records are mandatory
       FND_MSG_PUB.add;
    END IF;
    x_return_status := fnd_api.g_ret_sts_error;
    RETURN;
END IF;
--//Request Number Validation
IF l_SDR_rec.request_number <> FND_API.g_miss_char AND l_SDR_rec.request_number IS NOT NULL THEN
   OPEN  c_request_number(l_SDR_rec.request_number);
   FETCH c_request_number INTO l_request_number;
   CLOSE c_request_number;

   IF l_request_number IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_DUP_SOURCE_REQ_NO');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;

--//Request type validation
IF l_SDR_rec.request_type_setup_id <> FND_API.g_miss_num AND l_SDR_rec.request_type_setup_id IS NOT NULL THEN
   OPEN c_request_type_setup(l_SDR_rec.request_type_setup_id);
   FETCH c_request_type_setup INTO l_request_type_setup_id,l_request_type;
   CLOSE c_request_type_setup;

   IF l_request_type_setup_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQUEST_TYPE_SETUP');
         --//Request type setup id is Mandatory
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   ELSE
     IF ((l_request_type = 'BID')
        AND (l_system_status_code <> 'DRAFT')
           AND (l_SDR_cust_tbl.count = 0)) THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_CUSTOMER_DETAILS');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_REQUEST_TYPE_SETUP');
      --//Request type setup id is Mandatory
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Validate Header Record');
END IF;
--//Validate Header Record
  validate_header_items(p_SDR_hdr_rec   => l_SDR_rec
                       ,p_mode          =>'CREATE'
                       ,x_return_status => x_return_status);

  IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
  END IF;

--//Validate Product Lines
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Validate Product Lines');
END IF;
IF p_SDR_lines_tbl.count > 0 THEN
    validate_product_lines(p_SDR_lines_tbl  => l_SDR_lines_tbl
                          ,p_SDR_hdr_rec    => l_SDR_rec
                          ,p_mode           => 'CREATE'
                          ,x_return_status  => x_return_status);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
    END IF;
    l_line_rec_flag :='Y';
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Validate Customer Records');
END IF;
--//Validate Customer Records
IF ((p_SDR_cust_tbl.count > 0) AND (l_request_type = 'BID' ))THEN
    validate_customer_items(p_SDR_cust_tbl   => l_SDR_cust_tbl
                            ,p_mode          => 'CREATE'
                            ,x_return_status => x_return_status);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
    END IF;
   l_cust_rec_flag :='Y';
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Inserting data into SD Request Header table');
END IF;
--// Insert into Header Table
   Insert_header_record(
        p_SDR_hdr_rec        => l_SDR_rec
       ,p_request_source     => 'API'
       ,x_request_header_id  => x_request_header_id
       ,x_return_status      => x_return_status);

 IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populating Translation table');
END IF;
--//Populate Transilation table
 populate_translation_record(
    p_request_header_id     =>x_request_header_id
   ,p_description           =>l_SDR_rec.request_description
   ,p_org_id                =>l_SDR_rec.org_id
   ,p_mode                  =>'CREATE'
   ,x_return_status         => x_return_status);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
    END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate SD Access table for Requestor');
    OZF_UTILITY_PVT.debug_message('p_resource_id =>'||l_SDR_rec.requestor_id);
END IF;
--Populate SD Access table

     OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>x_request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_SDR_rec.requestor_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>'Y'
           ,p_approver_flag     =>NULL
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);


    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

IF l_SDR_rec.assignee_resource_id IS NOT NULL THEN
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate SD Access table for Assignee');
    OZF_UTILITY_PVT.debug_message('p_resource_id =>'||l_SDR_rec.assignee_resource_id);
END IF;
--//Assignee Entry
        OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>x_request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_SDR_rec.assignee_resource_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>NULL
           ,p_approver_flag     =>'Y'
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);


    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;


IF l_line_rec_flag ='Y' THEN
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate Product Lines table');
END IF;
  --//Populate Product Lines table
  populate_product_lines(
        p_request_header_id  => x_request_header_id
       ,p_SDR_lines_tbl      => l_SDR_lines_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;

IF ((l_cust_rec_flag ='Y')  AND (l_request_type = 'BID' ))THEN

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate Customer Details table');
END IF;
--//Populate Customer Details table
 populate_customer_details(
        p_request_header_id  => x_request_header_id
       ,p_SDR_cust_tbl       => l_SDR_cust_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;
--========================================================================
--// Commit the process
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Request Header Id: '||x_request_header_id);
   OZF_UTILITY_PVT.debug_message('Public API: '|| l_api_name||' End');
END IF;
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

 FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
   );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_SDR_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count   => x_msg_count,
           p_data    => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CREATE_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO CREATE_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
End create_sd_request;
---------------------------------------------------------------------
-- PROCEDURE
--    update_sd_request
--
-- PURPOSE
--    Public API for updating Ship and Debit Request
---------------------------------------------------------------------
PROCEDURE update_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_SDR_hdr_rec                IN   SDR_Hdr_rec_type,
    p_SDR_lines_tbl              IN   SDR_lines_tbl_type,
    p_SDR_cust_tbl               IN   SDR_cust_tbl_type)

IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Update_sd_request';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  l_new_sdr_hdr_rec           OZF_SD_REQUEST_PUB.SDR_Hdr_rec_type := p_SDR_hdr_rec;
  l_old_sdr_hdr_rec           OZF_SD_REQUEST_PUB.SDR_Hdr_rec_type;
  l_new_sdr_lines_tbl         OZF_SD_REQUEST_PUB.SDR_lines_tbl_type := p_SDR_lines_tbl;
  l_new_sdr_cust_tbl          OZF_SD_REQUEST_PUB.SDR_cust_tbl_type  := p_SDR_cust_tbl;

  l_internal_flag           VARCHAR2(1);
  l_external_flag           VARCHAR2(1);
  l_admin_flag              VARCHAR2(1);
  l_owner_flag              VARCHAR2(1);
  l_approver_flag           VARCHAR2(1);
  l_group_member_id         NUMBER;
  l_old_user_status_id      NUMBER;
  l_new_user_status_id      NUMBER;
  l_old_status_code         VARCHAR2(60);
  l_new_status_code         VARCHAR2(60);
  l_is_stat_trns_allowed    VARCHAR2(30);
  l_line_rec_flag           VARCHAR2(1) := 'N';
  l_cust_rec_flag           VARCHAR2(1) := 'N';
  l_resource_id             NUMBER;
  l_line_update_flag        VARCHAR2(1) := 'N';
  l_cust_update_flag        VARCHAR2(1) := 'N';
  l_user_id                 NUMBER;
  l_request_header_id       NUMBER;
  l_request_number          VARCHAR2(30);
  l_request_communication   VARCHAR2(30);
  l_old_user_stat_name      VARCHAR2(120);
  l_new_user_stat_name      VARCHAR2(120);
  l_qp_list_header_id       NUMBER;
  l_error_location          NUMBER;

CURSOR c_old_sdr_hdr(p_request_header_id IN NUMBER)IS
    SELECT
        object_version_number,
        request_header_id,
        request_number,
        request_start_date,
    	request_end_date,
    	user_status_id,
    	request_outcome,
    	request_currency_code,
    	authorization_number,
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
    	supplier_id,
    	supplier_site_id,
	supplier_contact_id,
    	internal_submission_date,
    	asignee_response_by_date,
    	asignee_response_date,
    	submtd_by_for_supp_approval,
    	supplier_response_by_date,
    	supplier_response_date,
    	supplier_submission_date,
    	requestor_id,
    	supplier_quote_number,
    	internal_order_number,
    	sales_order_currency ,
       	asignee_resource_id,
    	org_id,
       	accrual_type,
    	cust_account_id,
    	supplier_contact_email_address,
    	supplier_contact_phone_number,
    	request_type_setup_id,
    	request_basis,
      supplier_contact_name --//Bugfix : 7822442
    FROM ozf_sd_Request_headers_all_b
    WHERE request_header_id =p_request_header_id;

CURSOR c_old_sdr_tl(p_request_header_id IN NUMBER)IS
   SELECT request_description
   FROM   ozf_sd_request_headers_all_tl
   WHERE  request_header_id = p_request_header_id;

CURSOR c_admin_check(p_resource_id IN NUMBER)IS
    SELECT jrgm.group_member_id
    FROM jtf_rs_group_members jrgm
    WHERE  jrgm.resource_id       = p_resource_id
    AND    jrgm.delete_flag       = 'N'
    AND    jrgm.group_id          = to_number(fnd_profile.value('AMS_ADMIN_GROUP'));

CURSOR c_sd_access(p_request_header_id IN NUMBER,p_user_id IN NUMBER)IS
    SELECT owner_flag,
	       approver_flag
    FROM   ozf_sd_request_access
    WHERE enabled_flag  ='Y'
    AND	  request_header_id     =p_request_header_id
    AND	  user_id               =p_user_id;

CURSOR c_user(p_user_id IN NUMBER) IS
	SELECT user_id
	FROM fnd_user
	WHERE user_id =p_user_id;

CURSOR c_resource_id (p_user_id IN NUMBER) IS
    SELECT resource_id
    FROM jtf_rs_resource_extns
    WHERE start_date_active <= sysdate
    AND nvl(end_date_active,sysdate) >= sysdate
    AND resource_id > 0
    AND   (category = 'EMPLOYEE' OR category = 'PARTNER' OR category = 'PARTY')
    AND   user_id = p_user_id;

CURSOR c_request_header_id(p_request_header_id IN VARCHAR2)IS
    SELECT  request_header_id
    FROM    ozf_sd_request_headers_all_b
    WHERE   request_header_id = p_request_header_id;

CURSOR c_request_number(p_request_number IN VARCHAR2)IS
    SELECT  request_number
    FROM    ozf_sd_request_headers_all_b
    WHERE   request_number =p_request_number;

CURSOR c_user_status_name(p_user_status_id IN NUMBER)IS
   SELECT name
   FROM   ams_user_statuses_vl
   WHERE  user_status_id = p_user_status_id;

CURSOR c_communication(p_supplier_id IN NUMBER,p_supplier_site_id IN NUMBER)IS
   SELECT request_communication
   FROM   ozf_supp_trd_prfls_all
   WHERE  supplier_id       =p_supplier_id
   AND    supplier_site_id  =p_supplier_site_id;

CURSOR c_qp_list_header_id(p_request_header_id IN NUMBER)IS
    SELECT offer_id
    FROM ozf_sd_request_headers_all_b
    WHERE request_header_id =p_request_header_id;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT UPDATE_SDR_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
   p_api_version_number,
   l_api_name,
   G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
   FND_MSG_PUB.initialize;
END IF;
-- Debug Message
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' PUB start');
END IF;
-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;
--==============================================================================
IF l_new_sdr_hdr_rec.request_header_id = FND_API.g_miss_num OR l_new_sdr_hdr_rec.request_header_id IS NULL THEN

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_REQUEST_HEADER_ID_NULL');
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
  RETURN;
ELSE
   OPEN  c_request_header_id(l_new_sdr_hdr_rec.request_header_id);
   FETCH c_request_header_id INTO l_request_header_id;
   CLOSE c_request_header_id;

   IF l_request_header_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQ_HEADER_ID');
         --//Request id is invalid. Please re-enter
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;
--//Set the request Header ID to Global var
G_REQUEST_HEADER_ID  :=l_request_header_id;
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('G_REQUEST_HEADER_ID: ' ||G_REQUEST_HEADER_ID);
END IF;

--//Request Number Validation
IF l_new_sdr_hdr_rec.request_number <> FND_API.g_miss_char AND l_new_sdr_hdr_rec.request_number IS NOT NULL THEN
   OPEN  c_request_number(l_new_sdr_hdr_rec.request_number);
   FETCH c_request_number INTO l_request_number;
   CLOSE c_request_number;

   IF l_request_number IS NOT NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_DUP_SOURCE_REQ_NO');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;

OPEN c_old_sdr_hdr(l_new_sdr_hdr_rec.request_header_id);

FETCH c_old_sdr_hdr INTO l_old_sdr_hdr_rec.object_version_number,
                         l_old_sdr_hdr_rec.request_header_id,
                         l_old_sdr_hdr_rec.request_number,
                         l_old_sdr_hdr_rec.request_start_date,
                         l_old_sdr_hdr_rec.request_end_date,
                         l_old_sdr_hdr_rec.user_status_id,
                         l_old_sdr_hdr_rec.request_outcome,
                         l_old_sdr_hdr_rec.request_currency_code,
                         l_old_sdr_hdr_rec.authorization_number,
                         l_old_sdr_hdr_rec.attribute_category,
                         l_old_sdr_hdr_rec.attribute1,
                         l_old_sdr_hdr_rec.attribute2,
                         l_old_sdr_hdr_rec.attribute3,
                         l_old_sdr_hdr_rec.attribute4,
                         l_old_sdr_hdr_rec.attribute5,
                         l_old_sdr_hdr_rec.attribute6,
                         l_old_sdr_hdr_rec.attribute7,
                         l_old_sdr_hdr_rec.attribute8,
                         l_old_sdr_hdr_rec.attribute9,
                         l_old_sdr_hdr_rec.attribute10,
                         l_old_sdr_hdr_rec.attribute11,
                         l_old_sdr_hdr_rec.attribute12,
                         l_old_sdr_hdr_rec.attribute13,
                         l_old_sdr_hdr_rec.attribute14,
                         l_old_sdr_hdr_rec.attribute15,
                         l_old_sdr_hdr_rec.supplier_id,
                         l_old_sdr_hdr_rec.supplier_site_id,
                         l_old_sdr_hdr_rec.supplier_contact_id,
                         l_old_sdr_hdr_rec.internal_submission_date,
                         l_old_sdr_hdr_rec.assignee_response_by_date,
                         l_old_sdr_hdr_rec.assignee_response_date,
                         l_old_sdr_hdr_rec.submtd_by_for_supp_approval,
                         l_old_sdr_hdr_rec.supplier_response_by_date,
                         l_old_sdr_hdr_rec.supplier_response_date,
                         l_old_sdr_hdr_rec.supplier_submission_date,
                         l_old_sdr_hdr_rec.requestor_id,
                         l_old_sdr_hdr_rec.supplier_quote_number,
                         l_old_sdr_hdr_rec.internal_order_number,
                         l_old_sdr_hdr_rec.sales_order_currency ,
                         l_old_sdr_hdr_rec.assignee_resource_id,
                         l_old_sdr_hdr_rec.org_id,
                         l_old_sdr_hdr_rec.accrual_type,
                         l_old_sdr_hdr_rec.cust_account_id,
                         l_old_sdr_hdr_rec.supplier_contact_email_address,
                         l_old_sdr_hdr_rec.supplier_contact_phone_number,
                         l_old_sdr_hdr_rec.request_type_setup_id,
                         l_old_sdr_hdr_rec.request_basis,
                         l_old_sdr_hdr_rec.supplier_contact_name; --//Bugfix : 7822442
CLOSE c_old_sdr_hdr;

--// Object Version number check
IF l_old_sdr_hdr_rec.object_version_number <> l_new_sdr_hdr_rec.object_version_number THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
        FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
END IF;

OPEN  c_old_sdr_tl(l_new_sdr_hdr_rec.request_header_id);
FETCH c_old_sdr_tl INTO l_old_sdr_hdr_rec.request_description;
CLOSE c_old_sdr_tl;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Validating User');
END IF;
--//User Check
IF l_new_sdr_hdr_rec.user_id <> FND_API.g_miss_num AND l_new_sdr_hdr_rec.user_id IS NOT NULL THEN
   OPEN c_user(l_new_sdr_hdr_rec.user_id);
   FETCH c_user INTO l_user_id;
   CLOSE c_user;

   IF l_user_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_USER_ID');
         --//User Id is invalid, Please re-enter
         FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   ELSE --// Check if User is a valid resource or not
       OPEN c_resource_id(p_SDR_hdr_rec.user_id);
       FETCH c_resource_id INTO l_resource_id;
       CLOSE c_resource_id;

       IF l_resource_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_USER_IS_NOT_RESOURCE');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_USER_ID');
       --//User Id is Mandatory
        FND_MSG_PUB.add;
     END IF;
     x_return_status := fnd_api.g_ret_sts_error;
     RETURN;
END IF;

--//Admin check
OPEN c_admin_check(l_resource_id);
FETCH c_admin_check INTO l_group_member_id;
CLOSE c_admin_check;

   IF l_group_member_id IS NOT NULL THEN
      l_admin_flag :='Y';
   END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('SD Access Check');
    OZF_UTILITY_PVT.debug_message('Request Header ID :'||l_new_sdr_hdr_rec.request_header_id);
    OZF_UTILITY_PVT.debug_message('User id :'||l_new_sdr_hdr_rec.user_id);
END IF;
OPEN  c_sd_access(l_new_sdr_hdr_rec.request_header_id
                 ,l_new_sdr_hdr_rec.user_id);

FETCH c_sd_access INTO l_owner_flag,l_approver_flag;
CLOSE c_sd_access;

IF l_admin_flag = 'Y' THEN
   l_approver_flag :='Y';
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Owner Flag :'||l_owner_flag);
    OZF_UTILITY_PVT.debug_message('Approver Flag :'||l_approver_flag);
    OZF_UTILITY_PVT.debug_message('Admin Flag :'||l_admin_flag);
END IF;

--//Access Permission check
IF ((l_owner_flag IS NULL)
    AND (l_approver_flag IS NULL)
          AND(l_admin_flag IS NULL)) THEN

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_USER_PERMISSIONS');
      --//User has no previlage to update the record.
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Get the internal and external flags
IF l_old_sdr_hdr_rec.accrual_type ='INTERNAL' THEN
    l_internal_flag  := 'Y';
    l_external_flag  := NULL;
ELSIF l_old_sdr_hdr_rec.accrual_type ='SUPPLIER' THEN
    l_internal_flag  := NULL;
    l_external_flag  := 'Y';
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Internal Flag :'||l_internal_flag);
    OZF_UTILITY_PVT.debug_message('External Flag :'||l_external_flag);

END IF;

  l_old_user_status_id :=NVL(l_old_sdr_hdr_rec.user_status_id,0);
  l_new_user_status_id :=NVL(l_new_sdr_hdr_rec.user_status_id,l_old_sdr_hdr_rec.user_status_id);

--//Status Transition check
IF l_new_sdr_hdr_rec.user_status_id <> FND_API.g_miss_num AND l_new_sdr_hdr_rec.user_status_id IS NOT NULL THEN
   l_old_status_code := get_system_status_code(l_old_sdr_hdr_rec.user_status_id);
   l_new_status_code := get_system_status_code(l_new_sdr_hdr_rec.user_status_id);
ELSE
   l_old_status_code := get_system_status_code(l_old_sdr_hdr_rec.user_status_id);
   l_new_status_code := l_old_status_code;
END IF;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Checking the Status transition ');
   OZF_UTILITY_PVT.debug_message('Old Status Code :'||l_old_status_code);
   OZF_UTILITY_PVT.debug_message('New Status Code :'||l_new_status_code);
   OZF_UTILITY_PVT.debug_message('Old Status Id   :'||l_old_user_status_id);
   OZF_UTILITY_PVT.debug_message('New Status Id   :'||l_new_user_status_id);
END IF;

--//Update is not allowed in the following statuses
IF l_old_status_code IN ('CLOSED','CANCELLED') THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_UPDATE_ALLOWED');
      --//Ship and Debit Request updation is not allowed in Closed/Cancelled Status.
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;


IF l_old_status_code <> l_new_status_code THEN
      l_is_stat_trns_allowed := check_status_transition(
                                    p_from_status       =>l_old_status_code
                                   ,p_to_status         =>l_new_status_code
                                   ,p_owner_flag        =>l_owner_flag
                                   ,p_pm_flag           =>l_approver_flag
                                   ,p_internal_flag     =>l_internal_flag
                                   ,p_external_flag     =>l_external_flag);

    IF l_is_stat_trns_allowed =  FND_API.g_false THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_STATUS_TRANS');
          --//Status transition is invalid
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
    END IF;
    l_old_sdr_hdr_rec.user_status_id := l_new_sdr_hdr_rec.user_status_id;

END IF;

--//Set Common updatable values
l_old_sdr_hdr_rec.attribute_category                := l_new_sdr_hdr_rec.attribute_category;
l_old_sdr_hdr_rec.attribute1                        := l_new_sdr_hdr_rec.attribute1;
l_old_sdr_hdr_rec.attribute2                        := l_new_sdr_hdr_rec.attribute2;
l_old_sdr_hdr_rec.attribute3                        := l_new_sdr_hdr_rec.attribute3;
l_old_sdr_hdr_rec.attribute4                        := l_new_sdr_hdr_rec.attribute4;
l_old_sdr_hdr_rec.attribute5                        := l_new_sdr_hdr_rec.attribute5;
l_old_sdr_hdr_rec.attribute6                        := l_new_sdr_hdr_rec.attribute6;
l_old_sdr_hdr_rec.attribute7                        := l_new_sdr_hdr_rec.attribute7;
l_old_sdr_hdr_rec.attribute8                        := l_new_sdr_hdr_rec.attribute8;
l_old_sdr_hdr_rec.attribute9                        := l_new_sdr_hdr_rec.attribute9;
l_old_sdr_hdr_rec.attribute10                       := l_new_sdr_hdr_rec.attribute10;
l_old_sdr_hdr_rec.attribute11                       := l_new_sdr_hdr_rec.attribute11;
l_old_sdr_hdr_rec.attribute12                       := l_new_sdr_hdr_rec.attribute12;
l_old_sdr_hdr_rec.attribute13                       := l_new_sdr_hdr_rec.attribute13;
l_old_sdr_hdr_rec.attribute14                       := l_new_sdr_hdr_rec.attribute14;
l_old_sdr_hdr_rec.attribute15                       := l_new_sdr_hdr_rec.attribute15;

IF l_external_flag ='Y' THEN
   l_old_sdr_hdr_rec.supplier_contact_email_address    := NVL
(l_new_sdr_hdr_rec.supplier_contact_email_address,l_old_sdr_hdr_rec.supplier_contact_email_address);
   l_old_sdr_hdr_rec.supplier_contact_phone_number     := NVL
(l_new_sdr_hdr_rec.supplier_contact_phone_number,l_old_sdr_hdr_rec.supplier_contact_phone_number);
END IF;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('l_old_status_code :'||l_old_status_code);
END IF;

--//Statuswise transitions
IF l_old_status_code ='DRAFT' THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_number                  :=NVL(l_new_sdr_hdr_rec.request_number,l_old_sdr_hdr_rec.request_number);
    l_old_sdr_hdr_rec.org_id			      :=NVL(l_new_sdr_hdr_rec.org_id,l_old_sdr_hdr_rec.org_id);
    l_old_sdr_hdr_rec.cust_account_id		      :=NVL(l_new_sdr_hdr_rec.cust_account_id,l_old_sdr_hdr_rec.cust_account_id);
    l_old_sdr_hdr_rec.supplier_id		      :=NVL(l_new_sdr_hdr_rec.supplier_id,l_old_sdr_hdr_rec.supplier_id);
    l_old_sdr_hdr_rec.supplier_site_id                :=NVL(l_new_sdr_hdr_rec.supplier_site_id,l_old_sdr_hdr_rec.supplier_site_id);
    l_old_sdr_hdr_rec.supplier_response_date          :=NVL(l_new_sdr_hdr_rec.supplier_response_date,l_old_sdr_hdr_rec.supplier_response_date);
    l_old_sdr_hdr_rec.assignee_response_by_date       :=NVL(l_new_sdr_hdr_rec.assignee_response_by_date,l_old_sdr_hdr_rec.assignee_response_by_date);
    l_old_sdr_hdr_rec.authorization_number	      :=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_start_date	      :=NVL(l_new_sdr_hdr_rec.request_start_date,l_old_sdr_hdr_rec.request_start_date);
    l_old_sdr_hdr_rec.request_end_date		      :=NVL(l_new_sdr_hdr_rec.request_end_date,l_old_sdr_hdr_rec.request_end_date);
    l_old_sdr_hdr_rec.request_outcome	              :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	      :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	      :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_currency_code	      :=NVL(l_new_sdr_hdr_rec.request_currency_code,l_old_sdr_hdr_rec.request_currency_code);
    l_old_sdr_hdr_rec.sales_order_currency	      :=NVL(l_new_sdr_hdr_rec.sales_order_currency,l_old_sdr_hdr_rec.sales_order_currency);
    l_old_sdr_hdr_rec.request_description	      :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	              :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);

 --//Bugfix 7822442
    IF ((l_new_sdr_hdr_rec.supplier_contact_id = FND_API.g_miss_num OR l_new_sdr_hdr_rec.supplier_contact_id IS NULL)
       AND (l_new_sdr_hdr_rec.supplier_contact_name <> FND_API.g_miss_char AND l_new_sdr_hdr_rec.supplier_contact_name IS NOT NULL)) THEN
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NULL;
       l_old_sdr_hdr_rec.supplier_contact_name	    :=l_new_sdr_hdr_rec.supplier_contact_name;
    ELSE
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NVL(l_new_sdr_hdr_rec.supplier_contact_id,l_old_sdr_hdr_rec.supplier_contact_id);
       l_old_sdr_hdr_rec.supplier_contact_name	    :=NVL(l_new_sdr_hdr_rec.supplier_contact_name,l_old_sdr_hdr_rec.supplier_contact_name);
    END IF;

 END IF;
 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.cust_account_id		:=NVL(l_new_sdr_hdr_rec.cust_account_id,l_old_sdr_hdr_rec.cust_account_id);

 END IF;

ELSIF l_old_status_code ='ASSIGNED' THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.assignee_response_by_date :=NVL(l_new_sdr_hdr_rec.assignee_response_by_date,l_old_sdr_hdr_rec.assignee_response_by_date);
    l_old_sdr_hdr_rec.request_outcome	        :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	    :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	    :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	            :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.authorization_number	 :=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_start_date	 :=NVL(l_new_sdr_hdr_rec.request_start_date,l_old_sdr_hdr_rec.request_start_date);
    l_old_sdr_hdr_rec.request_end_date		 :=NVL(l_new_sdr_hdr_rec.request_end_date,l_old_sdr_hdr_rec.request_end_date);
    l_old_sdr_hdr_rec.request_outcome		 :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	 :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	 :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_currency_code	 :=NVL(l_new_sdr_hdr_rec.request_currency_code,l_old_sdr_hdr_rec.request_currency_code);
    l_old_sdr_hdr_rec.sales_order_currency	 :=NVL(l_new_sdr_hdr_rec.sales_order_currency,l_old_sdr_hdr_rec.sales_order_currency);
    l_old_sdr_hdr_rec.request_description	 :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	         :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);
 END IF;

ELSIF l_old_status_code IN ('WITHDRAW','REJECTED')THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

ELSIF l_old_status_code ='PENDING_SUPPLIER_APPROVAL' THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.assignee_response_by_date :=NVL(l_new_sdr_hdr_rec.assignee_response_by_date,l_old_sdr_hdr_rec.assignee_response_by_date);
    l_old_sdr_hdr_rec.request_outcome	        :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	    :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	    :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
 OZF_UTILITY_PVT.debug_message('l_new_sdr_hdr_rec.request_number '||l_new_sdr_hdr_rec.request_number);

    l_old_sdr_hdr_rec.request_number                 :=NVL(l_new_sdr_hdr_rec.request_number,l_old_sdr_hdr_rec.request_number);
    l_old_sdr_hdr_rec.org_id			     :=NVL(l_new_sdr_hdr_rec.org_id,l_old_sdr_hdr_rec.org_id);
    l_old_sdr_hdr_rec.supplier_id		     :=NVL(l_new_sdr_hdr_rec.supplier_id,l_old_sdr_hdr_rec.supplier_id);
    l_old_sdr_hdr_rec.supplier_site_id               :=NVL(l_new_sdr_hdr_rec.supplier_site_id,l_old_sdr_hdr_rec.supplier_site_id);
    l_old_sdr_hdr_rec.supplier_response_date         :=NVL(l_new_sdr_hdr_rec.supplier_response_date,l_old_sdr_hdr_rec.supplier_response_date);
    l_old_sdr_hdr_rec.authorization_number	     :=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_outcome	             :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	     :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	     :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_description            :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);

  --//Bugfix 7822442
    IF ((l_new_sdr_hdr_rec.supplier_contact_id = FND_API.g_miss_num OR l_new_sdr_hdr_rec.supplier_contact_id IS NULL)
       AND (l_new_sdr_hdr_rec.supplier_contact_name <> FND_API.g_miss_char AND l_new_sdr_hdr_rec.supplier_contact_name IS NOT NULL)) THEN
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NULL;
       l_old_sdr_hdr_rec.supplier_contact_name	    :=l_new_sdr_hdr_rec.supplier_contact_name;
    ELSE
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NVL(l_new_sdr_hdr_rec.supplier_contact_id,l_old_sdr_hdr_rec.supplier_contact_id);
       l_old_sdr_hdr_rec.supplier_contact_name	    :=NVL(l_new_sdr_hdr_rec.supplier_contact_name,l_old_sdr_hdr_rec.supplier_contact_name);
    END IF;
 END IF;

ELSIF l_old_status_code = 'SUPPLIER_APPROVED' THEN
 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.assignee_response_by_date  :=NVL(l_new_sdr_hdr_rec.assignee_response_by_date,l_old_sdr_hdr_rec.assignee_response_by_date);
    l_old_sdr_hdr_rec.request_outcome		     :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	     :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	     :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_description        :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.authorization_number	  :=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_start_date	  :=NVL(l_new_sdr_hdr_rec.request_start_date,l_old_sdr_hdr_rec.request_start_date);
    l_old_sdr_hdr_rec.request_end_date		  :=NVL(l_new_sdr_hdr_rec.request_end_date,l_old_sdr_hdr_rec.request_end_date);
    l_old_sdr_hdr_rec.request_outcome		  :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	  :=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	  :=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_currency_code	  :=NVL(l_new_sdr_hdr_rec.request_currency_code,l_old_sdr_hdr_rec.request_currency_code);
    l_old_sdr_hdr_rec.sales_order_currency	  :=NVL(l_new_sdr_hdr_rec.sales_order_currency,l_old_sdr_hdr_rec.sales_order_currency);
    l_old_sdr_hdr_rec.request_description         :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	          :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);

 --//Bugfix 7822442
    IF ((l_new_sdr_hdr_rec.supplier_contact_id = FND_API.g_miss_num OR l_new_sdr_hdr_rec.supplier_contact_id IS NULL)
       AND (l_new_sdr_hdr_rec.supplier_contact_name <> FND_API.g_miss_char AND l_new_sdr_hdr_rec.supplier_contact_name IS NOT NULL)) THEN
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NULL;
       l_old_sdr_hdr_rec.supplier_contact_name	    :=l_new_sdr_hdr_rec.supplier_contact_name;
    ELSE
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NVL(l_new_sdr_hdr_rec.supplier_contact_id,l_old_sdr_hdr_rec.supplier_contact_id);
       l_old_sdr_hdr_rec.supplier_contact_name	    :=NVL(l_new_sdr_hdr_rec.supplier_contact_name,l_old_sdr_hdr_rec.supplier_contact_name);
    END IF;
 END IF;

ELSIF l_old_status_code = 'SUPPLIER_REJECTED'THEN
 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	:=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	:=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_description   :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.request_number            :=NVL(l_new_sdr_hdr_rec.request_number,l_old_sdr_hdr_rec.request_number);
    l_old_sdr_hdr_rec.org_id			:=NVL(l_new_sdr_hdr_rec.org_id,l_old_sdr_hdr_rec.org_id);
    l_old_sdr_hdr_rec.supplier_id		:=NVL(l_new_sdr_hdr_rec.supplier_id,l_old_sdr_hdr_rec.supplier_id);
    l_old_sdr_hdr_rec.supplier_site_id          :=NVL(l_new_sdr_hdr_rec.supplier_site_id,l_old_sdr_hdr_rec.supplier_site_id);
    l_old_sdr_hdr_rec.supplier_response_date    :=NVL(l_new_sdr_hdr_rec.supplier_response_date,l_old_sdr_hdr_rec.supplier_response_date);
    l_old_sdr_hdr_rec.authorization_number	:=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_outcome	        :=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.supplier_quote_number	:=NVL(l_new_sdr_hdr_rec.supplier_quote_number,l_old_sdr_hdr_rec.supplier_quote_number);
    l_old_sdr_hdr_rec.internal_order_number	:=NVL(l_new_sdr_hdr_rec.internal_order_number,l_old_sdr_hdr_rec.internal_order_number);
    l_old_sdr_hdr_rec.request_currency_code	:=NVL(l_new_sdr_hdr_rec.request_currency_code,l_old_sdr_hdr_rec.request_currency_code);
    l_old_sdr_hdr_rec.sales_order_currency	:=NVL(l_new_sdr_hdr_rec.sales_order_currency,l_old_sdr_hdr_rec.sales_order_currency);
    l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);

 --//Bugfix 7822442
    IF ((l_new_sdr_hdr_rec.supplier_contact_id = FND_API.g_miss_num OR l_new_sdr_hdr_rec.supplier_contact_id IS NULL)
       AND (l_new_sdr_hdr_rec.supplier_contact_name <> FND_API.g_miss_char AND l_new_sdr_hdr_rec.supplier_contact_name IS NOT NULL)) THEN
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NULL;
       l_old_sdr_hdr_rec.supplier_contact_name	    :=l_new_sdr_hdr_rec.supplier_contact_name;
    ELSE
       l_old_sdr_hdr_rec.supplier_contact_id	      :=NVL(l_new_sdr_hdr_rec.supplier_contact_id,l_old_sdr_hdr_rec.supplier_contact_id);
       l_old_sdr_hdr_rec.supplier_contact_name	    :=NVL(l_new_sdr_hdr_rec.supplier_contact_name,l_old_sdr_hdr_rec.supplier_contact_name);
    END IF;

 END IF;

ELSIF l_old_status_code IN ('PENDING_SALES_APPROVAL','SALES_REJECTED',
                            'SALES_APPROVED','PENDING_OFFER_APPROVAL') THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
  END IF;

ELSIF (l_old_status_code ='SALES_APPROVED')THEN

 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	        :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);
 END IF;

ELSIF l_old_status_code ='ACTIVE' THEN
 IF l_owner_flag ='Y' THEN
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
 END IF;

 IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
    l_old_sdr_hdr_rec.authorization_number	:=NVL(l_new_sdr_hdr_rec.authorization_number,l_old_sdr_hdr_rec.authorization_number);
    l_old_sdr_hdr_rec.request_start_date	:=NVL(l_new_sdr_hdr_rec.request_start_date,l_old_sdr_hdr_rec.request_start_date);
    l_old_sdr_hdr_rec.request_end_date		:=NVL(l_new_sdr_hdr_rec.request_end_date,l_old_sdr_hdr_rec.request_end_date);
    l_old_sdr_hdr_rec.request_outcome		:=NVL(l_new_sdr_hdr_rec.request_outcome,l_old_sdr_hdr_rec.request_outcome);
    l_old_sdr_hdr_rec.request_description	:=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
    l_old_sdr_hdr_rec.request_basis	        :=NVL(l_new_sdr_hdr_rec.request_basis,l_old_sdr_hdr_rec.request_basis);
 END IF;

ELSIF l_old_status_code IN ('OFFER_REJECTED','CANCELLED','CLOSED') THEN
   IF l_owner_flag ='Y' THEN
      l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
   END IF;

   IF (l_approver_flag ='Y')  OR (l_admin_flag='Y') THEN
      l_old_sdr_hdr_rec.request_description       :=NVL(l_new_sdr_hdr_rec.request_description,l_old_sdr_hdr_rec.request_description);
   END IF;
END IF;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('End of Statuswise Data set');
END IF;
--//Set the user Id
l_old_sdr_hdr_rec.user_id                           := l_new_sdr_hdr_rec.user_id;

--//Admin Actions
IF l_admin_flag ='Y' THEN
   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Admin Actions ');
   END IF;

   IF (l_new_sdr_hdr_rec.requestor_id IS NOT NULL)
        AND (NVL(l_old_sdr_hdr_rec.requestor_id,0) <> NVL(l_new_sdr_hdr_rec.requestor_id,0)) THEN
      --//Admin is updating the Owner
    IF G_DEBUG THEN
        OZF_UTILITY_PVT.debug_message('Admin is updating the Owner ');
    END IF;

    OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>l_old_sdr_hdr_rec.request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_new_sdr_hdr_rec.requestor_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>'Y'
           ,p_approver_flag     =>NULL
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;
       l_old_sdr_hdr_rec.requestor_id :=l_new_sdr_hdr_rec.requestor_id;

   END IF;
   IF l_external_flag  = 'Y' THEN
      IF ((l_new_sdr_hdr_rec.assignee_resource_id IS NOT NULL)
         AND NVL(l_old_sdr_hdr_rec.assignee_resource_id,0) <> NVL(l_new_sdr_hdr_rec.assignee_resource_id,0)) THEN
         --//Admin is updating the Assignee
        IF g_debug THEN
           OZF_UTILITY_PVT.debug_message('Admin is updating the Assignee ');
        END IF;

       OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>l_old_sdr_hdr_rec.request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_new_sdr_hdr_rec.assignee_resource_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>NULL
           ,p_approver_flag     =>'Y'
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
            l_old_sdr_hdr_rec.assignee_resource_id :=l_new_sdr_hdr_rec.assignee_resource_id;
      END IF;
   END IF;
ELSE
   l_old_sdr_hdr_rec.requestor_id         :=NVL(l_new_sdr_hdr_rec.requestor_id,l_old_sdr_hdr_rec.requestor_id);
   l_old_sdr_hdr_rec.assignee_resource_id :=NVL(l_new_sdr_hdr_rec.assignee_resource_id,l_old_sdr_hdr_rec.assignee_resource_id);
END IF;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Validate Header Records');
END IF;
--//Validate Header Record
validate_header_items(p_SDR_hdr_rec     => l_old_sdr_hdr_rec
                     ,p_mode            =>'UPDATE'
                     ,x_return_status   => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

--//Proc Lines and Customer details Validation
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Proc Lines and Customer details Validation');
END IF;

IF l_old_status_code ='DRAFT' AND (l_owner_flag ='Y' OR l_admin_flag ='Y') THEN
    IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Owner can update Product Lines and Customer Details');
    END IF;
--//Owner can update Product Lines and Customer Details
    l_line_update_flag := 'Y';
    l_cust_update_flag := 'Y';
ELSIF l_old_status_code <>'DRAFT' AND (l_approver_flag ='Y' OR l_admin_flag ='Y') THEN
   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('PM Can update Product Lines and Customer Details');
   END IF;
--//PM Can update Product Lines and Customer Details
    l_line_update_flag := 'Y';
    l_cust_update_flag := 'Y';
END IF;

--//Validate Product Line Records
IF l_line_update_flag ='Y' THEN

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Validate Product Line Records');
END IF;

   IF l_new_sdr_lines_tbl.count > 0 THEN

      validate_product_lines(p_SDR_lines_tbl  => l_new_sdr_lines_tbl
                            ,p_SDR_hdr_rec    => l_old_sdr_hdr_rec
                            ,p_mode           => 'UPDATE'
                            ,x_return_status  => x_return_status);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      l_line_rec_flag :='Y';
   END IF;
END IF;

--//Validate Customer Records
IF l_cust_update_flag = 'Y' THEN
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Validate Customer Records');
END IF;

   IF l_new_sdr_cust_tbl.count > 0 THEN


      validate_customer_items(p_SDR_cust_tbl   => l_new_sdr_cust_tbl
                              ,p_mode          => 'UPDATE'
                              ,x_return_status => x_return_status);

       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;
       l_cust_rec_flag :='Y';
   END IF;
END IF;

--//UPDATE PROCESS
--//Update Header Records
IF G_DEBUG THEN
  OZF_UTILITY_PVT.debug_message('update_header_record');
END IF;

update_header_record(
     p_SDR_hdr_rec    =>l_old_sdr_hdr_rec
    ,x_return_status  =>x_return_status);

     IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
     ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
     END IF;

IF G_DEBUG THEN
  OZF_UTILITY_PVT.debug_message('populate_translation_record');
END IF;
--//Update TL record
populate_translation_record(
    p_request_header_id     =>l_old_sdr_hdr_rec.request_header_id
   ,p_description           =>l_old_sdr_hdr_rec.request_description
   ,p_org_id                =>l_old_sdr_hdr_rec.org_id
   ,p_mode                  =>'UPDATE'
   ,x_return_status         => x_return_status);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
    END IF;

--//Populating SD Access Table
IF l_old_sdr_hdr_rec.accrual_type ='SUPPLIER'
   AND l_new_status_code ='ASSIGNED'
      AND l_old_status_code <>l_new_status_code THEN

   OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>l_old_sdr_hdr_rec.request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_old_sdr_hdr_rec.assignee_resource_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>NULL
           ,p_approver_flag     =>'Y'
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
END IF;

--//Update Lines Record
IF l_line_rec_flag ='Y' THEN

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Update Lines Record');
END IF;
    populate_product_lines(
        p_request_header_id  => l_new_sdr_hdr_rec.request_header_id
       ,p_SDR_lines_tbl      => l_new_sdr_lines_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;

--//Update Customer Record
IF l_cust_rec_flag ='Y' THEN
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate Customer Details table');
END IF;
 populate_customer_details(
        p_request_header_id  => l_new_sdr_hdr_rec.request_header_id
       ,p_SDR_cust_tbl       => l_new_sdr_cust_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;

--//Invoking Offer API Process
--//Moved the code from update_header_record Procedure - Bugfix : 7501052
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Request Header id  from update_header_record :'||p_SDR_hdr_rec.request_header_id);
END IF;

IF l_new_status_code IN ('PENDING_OFFER_APPROVAL','ACTIVE') OR
   l_old_status_code ='ACTIVE' OR
   (l_old_status_code ='ACTIVE' AND l_new_status_code IN('CANCELLED','CLOSED')) THEN

   OPEN c_qp_list_header_id(l_new_sdr_hdr_rec.request_header_id);
   FETCH c_qp_list_header_id INTO l_qp_list_header_id;
   CLOSE c_qp_list_header_id;

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('l_qp_list_header_id:'||l_qp_list_header_id);
      OZF_UTILITY_PVT.debug_message('l_new_status_code :'||l_new_status_code);
      OZF_UTILITY_PVT.debug_message('IG_OLD_STATUS_CODE:'||l_old_status_code);
      OZF_UTILITY_PVT.debug_message('Invoking OZF_OFFER_PVT.process_sd_modifiers :'||p_SDR_hdr_rec.request_header_id);
   END IF;

    OZF_OFFER_PVT.process_sd_modifiers(
           p_sdr_header_id  	 => p_SDR_hdr_rec.request_header_id
          ,p_init_msg_list	     => FND_API.G_FALSE
          ,p_api_version 	     => l_api_version_number
          ,p_commit   		     => FND_API.G_FALSE
          ,x_return_status	     => x_return_status
          ,x_msg_count 		     => x_msg_count
          ,x_msg_data 		     => x_msg_data
          ,x_qp_list_header_id   => l_qp_list_header_id
          ,x_error_location  	 => l_error_location);

   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('l_qp_list_header_id(Offer Id) :'||l_qp_list_header_id);
      OZF_UTILITY_PVT.debug_message('Invoking OZF_OFFER_PVT.process_sd_modifiers'||l_error_location);
   END IF;

   IF l_new_status_code ='PENDING_OFFER_APPROVAL' THEN
      --//Updating SD Request Header table with offer information
      UPDATE ozf_sd_request_headers_all_b
      SET    offer_id          = l_qp_list_header_id,
             offer_type        = 'ACCRUAL'
      WHERE  request_header_id =  p_SDR_hdr_rec.request_header_id;
   END IF;

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;


--// Commit the process
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' End');
END IF;
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

--// Invoke Business Events
--//1.Status Change Business Event

IF l_old_user_status_id <> l_new_user_status_id THEN
  IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Raises business event');
    END IF;
   --//Get the user status names
   OPEN  c_user_status_name(l_old_user_status_id);
   FETCH c_user_status_name INTO l_old_user_stat_name;
   CLOSE c_user_status_name;

   OPEN  c_user_status_name(l_new_user_status_id);
   FETCH c_user_status_name INTO l_new_user_stat_name;
   CLOSE c_user_status_name;

   raise_status_business_event(
      p_request_header_id =>l_new_sdr_hdr_rec.request_header_id
     ,p_from_status       => l_old_user_stat_name
     ,p_to_status         => l_new_user_stat_name);

END IF;

--//1.XML Gateway Business Event
/*
 Raises a XML Gateway business event if the following three conditions are satisfied:
  * a) whenever there is status change
  * b) New status is 'PENDING_SUPPLIER_APPROVAL'
 * c) Trade profile value is 'XML'
*/
OPEN  c_communication(l_old_sdr_hdr_rec.supplier_id,l_old_sdr_hdr_rec.supplier_site_id);
FETCH c_communication INTO l_request_communication;
CLOSE c_communication;

IF (l_old_status_code <> l_new_status_code)
    AND (l_new_status_code='PENDING_SUPPLIER_APPROVAL')
       AND (l_request_communication ='XML') THEN

    IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('Raises a XML Gateway business event');
    END IF;
      raise_XML_business_event(
        p_request_header_id     => l_new_sdr_hdr_rec.request_header_id
       ,p_supplier_id           => l_old_sdr_hdr_rec.supplier_id
       ,p_supplier_site_id      => l_old_sdr_hdr_rec.supplier_site_id);

END IF;

 FND_MSG_PUB.Count_And_Get (
   p_encoded        => FND_API.G_FALSE,
   p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
   );
--==============================================================================
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_SDR_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count   => x_msg_count,
           p_data    => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO UPDATE_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
END update_sd_request;

---------------------------------------------------------------------
-- PROCEDURE
--    copy_sd_request
--
-- PURPOSE
--    Public API for Copying SDR
---------------------------------------------------------------------
PROCEDURE copy_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_source_request_id          IN   VARCHAR2,
    p_new_request_number         IN   VARCHAR2,
    p_accrual_type               IN   VARCHAR2,
    p_cust_account_id            IN   NUMBER,
    p_request_start_date         IN   DATE,
    p_request_end_date           IN   DATE,
    p_copy_product_flag          IN   VARCHAR2 DEFAULT 'N',
    p_copy_customer_flag         IN   VARCHAR2 DEFAULT 'N',
    p_copy_end_customer_flag     IN   VARCHAR2 DEFAULT 'N',
    p_request_source             IN   VARCHAR2 DEFAULT 'API',
    x_request_header_id          OUT  NOCOPY NUMBER)
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'copy_sd_request';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_sdr_source_rec            OZF_SD_REQUEST_PUB.SDR_Hdr_rec_type;
   l_sd_access_rec             OZF_APPROVAL_PVT.sd_access_rec_type;
   l_sdr_source_lines_tbl      OZF_SD_REQUEST_PUB.SDR_lines_tbl_type;
   l_sdr_source_cust_tbl       OZF_SD_REQUEST_PUB.SDR_cust_tbl_type;

   l_lookup_stat               VARCHAR2(1); --To validate from lookups
   l_source_rid                NUMBER;
   l_new_req_no                VARCHAR2(30);
   l_product_count             NUMBER   := 0;
   l_customer_count            NUMBER   := 0;
   l_end_customer_count        NUMBER   := 0;
   l_product_flag_chk          NUMBER;
   l_customer_flag_chk         NUMBER;
   l_end_customer_flag_chk     NUMBER;
   l_cust_account_id           NUMBER;
   l_product_exists            VARCHAR2(1) :='N';
   l_customer_exists           VARCHAR2(1) :='N';
   l_end_customer_exists       VARCHAR2(1) :='N';
   l_authorization_period      NUMBER  :=0;
   l_request_end_date          DATE;
   l_request_start_date        DATE;
   l_user_id                   NUMBER;
   l_resource_id               NUMBER;

CURSOR c_source_request_header_id(p_request_header_id IN NUMBER)IS
    SELECT request_header_id
    FROM   ozf_sd_request_headers_all_b
    WHERE  request_header_id = p_request_header_id;

CURSOR c_new_request_no(p_request_number IN VARCHAR2)IS
    SELECT request_number
    FROM   ozf_sd_request_headers_all_b
    WHERE  request_number = p_request_number;

CURSOR c_cust_account_id(p_cust_account_id IN NUMBER) IS
    SELECT  cust_account_id
    FROM    hz_cust_accounts
    WHERE   status          ='A'
    AND     customer_type   ='I'
    AND     cust_account_id =p_cust_account_id;

CURSOR c_source_sd_header(p_request_header_id IN NUMBER)IS
    SELECT
      request_outcome,
      request_currency_code,
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
      supplier_id,
      supplier_site_id,
      supplier_contact_id,
      --requestor_id,
      sales_order_currency,
      org_id,
      accrual_type,
      cust_account_id,
      supplier_contact_email_address,
      supplier_contact_phone_number,
      request_type_setup_id,
      request_basis,
      supplier_contact_name  --//Bugfix : 7822442
FROM	ozf_sd_request_headers_all_b
WHERE	request_header_id = p_request_header_id;

CURSOR c_tl_description(p_request_header_id IN NUMBER)IS
    SELECT  request_description
    FROM   ozf_sd_request_headers_all_tl
    WHERE  request_header_id = p_request_header_id;

CURSOR c_product_flag_check(p_request_header_id IN NUMBER)IS
    SELECT COUNT(1)
    FROM ozf_sd_request_lines_all
    WHERE request_header_id = p_request_header_id;

CURSOR c_source_sd_lines(p_request_header_id IN NUMBER)IS
    SELECT
      product_context,
      inventory_item_id,
      prod_catg_id,
      product_cat_set_id,
      product_cost,
      item_uom,
      requested_discount_type,
      requested_discount_value,
      cost_basis,
      max_qty,
      limit_qty,
      design_win,
      end_customer_price,
      requested_line_amount,
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
      vendor_approved_flag,
      vendor_item_code,
      end_customer_price_type,
      end_customer_tolerance_type,
      end_customer_tolerance_value,
      org_id,
      rejection_code,
      requested_discount_currency,
      product_cost_currency,
      end_customer_currency,
      approved_discount_currency
FROM ozf_sd_request_lines_all
WHERE request_header_id = p_request_header_id;

CURSOR c_cust_flag_check(p_request_header_id IN NUMBER,p_end_customer_flag IN VARCHAR2)IS
    SELECT COUNT(1)
    FROM ozf_sd_customer_details
    WHERE request_header_id = p_request_header_id
    AND   end_customer_flag = p_end_customer_flag;

CURSOR c_source_customer_dtl(p_request_header_id IN NUMBER,p_end_customer_flag IN VARCHAR2)IS
    SELECT
	   cust_account_id,
	   party_id,
	   site_use_id,
	   cust_usage_code,
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
	   end_customer_flag
    FROM ozf_sd_customer_details
    WHERE request_header_id = p_request_header_id
    AND   end_customer_flag = p_end_customer_flag;

CURSOR c_authorization_period(p_supplier_id      IN NUMBER,
                              p_supplier_site_id IN NUMBER,
                              p_org_id           IN NUMBER)IS
    SELECT NVL(authorization_period,-1)
    FROM   ozf_supp_trd_prfls_all
    WHERE  supplier_id      = p_supplier_id
    AND    supplier_site_id = p_supplier_site_id
    AND    org_id           = p_org_id;

CURSOR c_resource_id (p_user_id IN NUMBER) IS
    SELECT resource_id
    FROM jtf_rs_resource_extns
    WHERE start_date_active <= sysdate
    AND nvl(end_date_active,sysdate) >= sysdate
    AND resource_id > 0
    AND   (category = 'EMPLOYEE' OR category = 'PARTNER' OR category = 'PARTY')
    AND   user_id = p_user_id;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT COPY_SDR_PUB;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
   p_api_version_number,
   l_api_name,
   G_PKG_NAME)
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean( p_init_msg_list )
THEN
   FND_MSG_PUB.initialize;
END IF;
-- Debug Message
IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' pub start');
END IF;
-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;
--==============================================================================
--//Bug 7190421 - User Check and population

l_user_id := FND_GLOBAL.user_id;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('l_user_id: ' ||l_user_id);
END IF;
--//Check if user is a valid resource or not
OPEN c_resource_id(l_user_id);
FETCH c_resource_id INTO l_resource_id;
CLOSE c_resource_id;

   IF l_resource_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_USER_IS_NOT_RESOURCE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('l_resource_id: ' ||l_resource_id);
END IF;


--//Check If Source Request Id is valid
IF p_source_request_id IS NOT NULL THEN
   OPEN  c_source_request_header_id(p_source_request_id);
   FETCH c_source_request_header_id INTO l_source_rid;
   CLOSE c_source_request_header_id;

   IF l_source_rid IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_SOURCE_REQ_ID');
          --//Invalid source request id. Please re-enter
          FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_SOURCE_REQ_ID');
       --//Invalid source request id. Please re-enter
       FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Check If New Request Number already exists
IF p_new_request_number IS NOT NULL THEN
    OPEN  c_new_request_no(p_new_request_number);
    FETCH c_new_request_no INTO l_new_req_no;
    CLOSE c_new_request_no;

       IF l_new_req_no IS NOT NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SD_DUP_SOURCE_REQ_NO');
              --//New request number entered is already exists.
              FND_MSG_PUB.add;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
       END IF;
END IF;
--//Accrual type Check
IF  p_accrual_type IS NOT NULL THEN
   l_lookup_stat :=OZF_UTILITY_PVT.check_lookup_exists(
                         p_lookup_table_name =>'OZF_LOOKUPS'
                        ,p_lookup_type       =>'OZF_SDR_ACCRUAL_TYPE'
                        ,p_lookup_code       => p_accrual_type);

    IF l_lookup_stat = FND_API.g_false THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_ACCRUAL_TYPE');
            FND_MSG_PUB.add;
        END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   END IF;
ELSE
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_ACCRUAL_TYPE');
      --//Accrual type is Mandatory
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Cust Account ID Validation
IF p_accrual_type ='INTERNAL' THEN

   IF p_cust_account_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SD_NO_CUST_ACCOUNT_ID');
         FND_MSG_PUB.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
   ELSE
     OPEN  c_cust_account_id(p_cust_account_id);
     FETCH c_cust_account_id INTO l_cust_account_id;
     CLOSE c_cust_account_id;

     IF l_cust_account_id IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_CUST_ACCOUNT_ID');
           FND_MSG_PUB.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
    END IF;
  END IF;
END IF;

--//Check if product lines exists
IF p_copy_product_flag ='Y' THEN
    OPEN  c_product_flag_check(p_source_request_id);
    FETCH c_product_flag_check INTO l_product_flag_chk;
    CLOSE c_product_flag_check;

    IF l_product_flag_chk > 0 THEN
        l_product_exists :='Y';
    ELSE
        l_product_exists :='N';
    END IF;
END IF;

--//Check if Customer exists
IF p_copy_customer_flag ='Y' THEN
    OPEN  c_cust_flag_check(p_source_request_id,'N'); --> N for Customer
    FETCH c_cust_flag_check INTO l_customer_flag_chk;
    CLOSE c_cust_flag_check;

    IF l_customer_flag_chk > 0 THEN
        l_customer_exists :='Y';
    ELSE
        l_customer_exists :='N';
    END IF;
END IF;

--//Check if End Customer exists
IF p_copy_end_customer_flag ='Y' THEN
    OPEN  c_cust_flag_check(p_source_request_id,'Y'); --> Y for End Customer
    FETCH c_cust_flag_check INTO l_end_customer_flag_chk;
    CLOSE c_cust_flag_check;

    IF l_end_customer_flag_chk > 0 THEN
        l_end_customer_exists :='Y';
    ELSE
        l_end_customer_exists :='N';
    END IF;
END IF;

IF p_request_source NOT IN ('API','Manual') THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_REQUEST_SOURCE');
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

--//Get the source Information
--l_sdr_source_rec.request_source := p_request_source;

OPEN c_source_sd_header(p_source_request_id);
FETCH c_source_sd_header INTO   l_sdr_source_rec.request_outcome,
                                l_sdr_source_rec.request_currency_code,
                                l_sdr_source_rec.attribute_category,
                                l_sdr_source_rec.attribute1,
                                l_sdr_source_rec.attribute2,
                                l_sdr_source_rec.attribute3,
                                l_sdr_source_rec.attribute4,
                                l_sdr_source_rec.attribute5,
                                l_sdr_source_rec.attribute6,
                                l_sdr_source_rec.attribute7,
                                l_sdr_source_rec.attribute8,
                                l_sdr_source_rec.attribute9,
                                l_sdr_source_rec.attribute10,
                                l_sdr_source_rec.attribute11,
                                l_sdr_source_rec.attribute12,
                                l_sdr_source_rec.attribute13,
                                l_sdr_source_rec.attribute14,
                                l_sdr_source_rec.attribute15,
                                l_sdr_source_rec.supplier_id,
                                l_sdr_source_rec.supplier_site_id,
                                l_sdr_source_rec.supplier_contact_id,
                              --  l_sdr_source_rec.requestor_id,
                                l_sdr_source_rec.sales_order_currency,
                                l_sdr_source_rec.org_id,
                                l_sdr_source_rec.accrual_type,
                                l_sdr_source_rec.cust_account_id,
                                l_sdr_source_rec.supplier_contact_email_address,
                                l_sdr_source_rec.supplier_contact_phone_number,
                                l_sdr_source_rec.request_type_setup_id,
                                l_sdr_source_rec.request_basis,
                                l_sdr_source_rec.supplier_contact_name; --//Bugfix : 7822442
CLOSE c_source_sd_header;

--//BugFix : 7607795 - Start Date/End date Validation
l_request_start_date :=p_request_start_date;

IF l_request_start_date IS NOT NULL AND p_request_end_date IS NULL THEN
   OPEN  c_authorization_period(l_sdr_source_rec.supplier_id
                                ,l_sdr_source_rec.supplier_site_id
                                ,l_sdr_source_rec.org_id);

   FETCH c_authorization_period INTO l_authorization_period;
   CLOSE c_authorization_period;

   IF l_authorization_period <> -1 THEN
      l_request_end_date := l_request_start_date + l_authorization_period;
   END IF;
END IF;

IF p_request_end_date IS NOT NULL THEN
  l_request_end_date := p_request_end_date;
END IF;

IF p_request_end_date < p_request_start_date THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_END_DATE');
      --//End date should be greater than start date
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;
END IF;

IF G_DEBUG THEN
   OZF_UTILITY_PVT.debug_message('Copy Option ');
   OZF_UTILITY_PVT.debug_message('Source accrual_type :'||l_sdr_source_rec.accrual_type);
   OZF_UTILITY_PVT.debug_message('New accrual_type    :'|| p_accrual_type);
END IF;

IF (l_sdr_source_rec.accrual_type ='INTERNAL') AND (p_accrual_type ='SUPPLIER') THEN
--Invalid Copy Option
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_SD_INVALID_COPY_OPTION');
      --//Internal to Supplier Copy option is invalid!
      FND_MSG_PUB.add;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   RETURN;

ELSIF ((l_sdr_source_rec.accrual_type ='SUPPLIER') AND (p_accrual_type ='INTERNAL')) OR  p_accrual_type ='INTERNAL' THEN
    l_sdr_source_rec.accrual_type                   := p_accrual_type;
    l_sdr_source_rec.cust_account_id                := p_cust_account_id;
    l_sdr_source_rec.supplier_id                    :=NULL;
    l_sdr_source_rec.supplier_site_id               :=NULL;
    l_sdr_source_rec.supplier_contact_id            :=NULL;
    l_sdr_source_rec.supplier_contact_name          :=NULL; --//Bugfix : 7822442
    l_sdr_source_rec.supplier_contact_email_address :=NULL;
    l_sdr_source_rec.supplier_contact_phone_number  :=NULL;


END IF;

--//Copy Header Information

--//Initilizations
l_sdr_source_rec.request_header_id      :=p_source_request_id; --//To populate Root Request Header ID
l_sdr_source_rec.request_number         :=p_new_request_number;
l_sdr_source_rec.request_start_date     :=TRUNC(l_request_start_date);
l_sdr_source_rec.request_end_date       :=TRUNC(l_request_end_date);
l_sdr_source_rec.requestor_id           :=l_resource_id;

--//Get the User status ID
l_sdr_source_rec.user_status_id         :=get_user_status_id('DRAFT');

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate Header table');
END IF;
--//Populate Header table
 Insert_header_record(
        p_SDR_hdr_rec        => l_sdr_source_rec
       ,p_request_source     => p_request_source
       ,x_request_header_id  => x_request_header_id
       ,x_return_status      => x_return_status);

 IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

--//Populate Translation table
OPEN c_tl_description(p_source_request_id);
FETCH c_tl_description INTO l_sdr_source_rec.request_description;
CLOSE c_tl_description;

IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Populate Translation table');
END IF;
populate_translation_record(
    p_request_header_id     =>x_request_header_id
   ,p_description           =>l_sdr_source_rec.request_description
   ,p_org_id                =>l_sdr_source_rec.org_id
   ,p_mode                  =>'COPY'
   ,x_return_status         => x_return_status);

IF G_DEBUG THEN
 OZF_UTILITY_PVT.debug_message('x_request_header_id '||x_request_header_id);
END IF;

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
    END IF;

--//Populate SD Access table
--//For Owner

   OZF_APPROVAL_PVT.Add_SD_Access(
            p_api_version       =>p_api_version_number
           ,p_init_msg_list     =>FND_API.G_FALSE
           ,p_commit            =>FND_API.G_FALSE
           ,p_validation_level  =>p_validation_level
           ,p_request_header_id =>x_request_header_id
           ,p_user_id           =>NULL
           ,p_resource_id       =>l_sdr_source_rec.requestor_id
           ,p_person_id         =>NULL
           ,p_owner_flag        =>'Y'
           ,p_approver_flag     =>NULL
           ,p_enabled_flag      =>'Y'
           ,x_return_status     =>x_return_status
           ,x_msg_count         =>x_msg_count
           ,x_msg_data          =>x_msg_data);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;


IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('Copy Product Lines');
END IF;
--//Copy Product Lines
IF ((p_copy_product_flag ='Y') AND (l_product_exists ='Y'))THEN
      OPEN c_source_sd_lines(p_source_request_id);
      LOOP
            l_product_count := l_product_count + 1;
       	    IF G_DEBUG THEN
               OZF_UTILITY_PVT.debug_message('Inside Loop :'||l_product_count);
            END IF;

          FETCH c_source_sd_lines INTO
                    l_sdr_source_lines_tbl(l_product_count).product_context,
                    l_sdr_source_lines_tbl(l_product_count).inventory_item_id,
                    l_sdr_source_lines_tbl(l_product_count).prod_catg_id,
                    l_sdr_source_lines_tbl(l_product_count).product_cat_set_id,
                    l_sdr_source_lines_tbl(l_product_count).product_cost,
                    l_sdr_source_lines_tbl(l_product_count).item_uom,
                    l_sdr_source_lines_tbl(l_product_count).requested_discount_type,
                    l_sdr_source_lines_tbl(l_product_count).requested_discount_value,
                    l_sdr_source_lines_tbl(l_product_count).cost_basis,
                    l_sdr_source_lines_tbl(l_product_count).max_qty,
                    l_sdr_source_lines_tbl(l_product_count).limit_qty,
                    l_sdr_source_lines_tbl(l_product_count).design_win,
                    l_sdr_source_lines_tbl(l_product_count).end_customer_price,
                    l_sdr_source_lines_tbl(l_product_count).requested_line_amount,
                    l_sdr_source_lines_tbl(l_product_count).attribute_category,
                    l_sdr_source_lines_tbl(l_product_count).attribute1,
                    l_sdr_source_lines_tbl(l_product_count).attribute2,
                    l_sdr_source_lines_tbl(l_product_count).attribute3,
                    l_sdr_source_lines_tbl(l_product_count).attribute4,
                    l_sdr_source_lines_tbl(l_product_count).attribute5,
                    l_sdr_source_lines_tbl(l_product_count).attribute6,
                    l_sdr_source_lines_tbl(l_product_count).attribute7,
                    l_sdr_source_lines_tbl(l_product_count).attribute8,
                    l_sdr_source_lines_tbl(l_product_count).attribute9,
                    l_sdr_source_lines_tbl(l_product_count).attribute10,
                    l_sdr_source_lines_tbl(l_product_count).attribute11,
                    l_sdr_source_lines_tbl(l_product_count).attribute12,
                    l_sdr_source_lines_tbl(l_product_count).attribute13,
                    l_sdr_source_lines_tbl(l_product_count).attribute14,
                    l_sdr_source_lines_tbl(l_product_count).attribute15,
                    l_sdr_source_lines_tbl(l_product_count).vendor_approved_flag,
                    l_sdr_source_lines_tbl(l_product_count).vendor_item_code,
                    l_sdr_source_lines_tbl(l_product_count).end_customer_price_type,
                    l_sdr_source_lines_tbl(l_product_count).end_customer_tolerance_type,
                    l_sdr_source_lines_tbl(l_product_count).end_customer_tolerance_value,
                    l_sdr_source_lines_tbl(l_product_count).org_id,
                    l_sdr_source_lines_tbl(l_product_count).rejection_code,
                    l_sdr_source_lines_tbl(l_product_count).requested_discount_currency,
                    l_sdr_source_lines_tbl(l_product_count).product_cost_currency,
                    l_sdr_source_lines_tbl(l_product_count).end_customer_currency,
                    l_sdr_source_lines_tbl(l_product_count).approved_discount_currency;
             EXIT WHEN c_source_sd_lines%NOTFOUND;

                    l_sdr_source_lines_tbl(l_product_count).start_date := TRUNC(l_request_start_date);
                    l_sdr_source_lines_tbl(l_product_count).end_date   := TRUNC(l_request_end_date);

		    --//Item Organization ID setup
		    G_ITEM_ORG_ID                                      :=l_sdr_source_lines_tbl(l_product_count).org_id;
		    IF p_accrual_type ='INTERNAL' THEN
		       --//Vendor Approved Flag should be defaulted to Y
		       l_sdr_source_lines_tbl(l_product_count).vendor_approved_flag := 'Y';
		    END IF;
     END LOOP;
   CLOSE c_source_sd_lines;

  --//Proulate Product Lines
    populate_product_lines(
        p_request_header_id  => x_request_header_id
       ,p_SDR_lines_tbl      => l_sdr_source_lines_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;
END IF;

--//Copy Customer
IF ((p_copy_customer_flag='Y') AND (l_customer_exists ='Y')) THEN
 l_sdr_source_cust_tbl.DELETE;
 OPEN c_source_customer_dtl(p_source_request_id,'N');
     LOOP
        l_customer_count := l_customer_count + 1;
        FETCH c_source_customer_dtl INTO
                    l_sdr_source_cust_tbl(l_customer_count).cust_account_id,
                    l_sdr_source_cust_tbl(l_customer_count).party_id,
                    l_sdr_source_cust_tbl(l_customer_count).site_use_id,
                    l_sdr_source_cust_tbl(l_customer_count).cust_usage_code,
                    l_sdr_source_cust_tbl(l_customer_count).attribute_category,
                    l_sdr_source_cust_tbl(l_customer_count).attribute1,
                    l_sdr_source_cust_tbl(l_customer_count).attribute2,
                    l_sdr_source_cust_tbl(l_customer_count).attribute3,
                    l_sdr_source_cust_tbl(l_customer_count).attribute4,
                    l_sdr_source_cust_tbl(l_customer_count).attribute5,
                    l_sdr_source_cust_tbl(l_customer_count).attribute6,
                    l_sdr_source_cust_tbl(l_customer_count).attribute7,
                    l_sdr_source_cust_tbl(l_customer_count).attribute8,
                    l_sdr_source_cust_tbl(l_customer_count).attribute9,
                    l_sdr_source_cust_tbl(l_customer_count).attribute10,
                    l_sdr_source_cust_tbl(l_customer_count).attribute11,
                    l_sdr_source_cust_tbl(l_customer_count).attribute12,
                    l_sdr_source_cust_tbl(l_customer_count).attribute13,
                    l_sdr_source_cust_tbl(l_customer_count).attribute14,
                    l_sdr_source_cust_tbl(l_customer_count).attribute15,
                    l_sdr_source_cust_tbl(l_customer_count).end_customer_flag;
       EXIT WHEN c_source_customer_dtl%NOTFOUND;
     END LOOP;
   CLOSE c_source_customer_dtl;
   --//Populate Customer Details table
   IF G_DEBUG THEN
      OZF_UTILITY_PVT.debug_message('populate_customer_details');
   END IF;
   populate_customer_details(
        p_request_header_id  => x_request_header_id
       ,p_SDR_cust_tbl       => l_sdr_source_cust_tbl
       ,x_return_status      => x_return_status);


   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

END IF;

IF ((p_copy_end_customer_flag='Y') AND (l_end_customer_exists ='Y')) THEN
   l_sdr_source_cust_tbl.DELETE;
 OPEN c_source_customer_dtl(p_source_request_id,'Y');
     LOOP
        l_end_customer_count := l_end_customer_count + 1;
        FETCH c_source_customer_dtl INTO
                    l_sdr_source_cust_tbl(l_end_customer_count).cust_account_id,
                    l_sdr_source_cust_tbl(l_end_customer_count).party_id,
                    l_sdr_source_cust_tbl(l_end_customer_count).site_use_id,
                    l_sdr_source_cust_tbl(l_end_customer_count).cust_usage_code,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute_category,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute1,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute2,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute3,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute4,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute5,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute6,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute7,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute8,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute9,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute10,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute11,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute12,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute13,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute14,
                    l_sdr_source_cust_tbl(l_end_customer_count).attribute15,
                    l_sdr_source_cust_tbl(l_end_customer_count).end_customer_flag;
       EXIT WHEN c_source_customer_dtl%NOTFOUND;
     END LOOP;
   CLOSE c_source_customer_dtl;
   --//Populate End Customer Details table
    populate_customer_details(
        p_request_header_id  => x_request_header_id
       ,p_SDR_cust_tbl       => l_sdr_source_cust_tbl
       ,x_return_status      => x_return_status);

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

END IF;

-- Commit the process
IF G_DEBUG THEN
    OZF_UTILITY_PVT.debug_message('New request_header_id :'||x_request_header_id );
    OZF_UTILITY_PVT.debug_message('Return Status :'|| x_return_status );
   OZF_UTILITY_PVT.debug_message('Public API: ' || l_api_name || ' End..');
END IF;
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

 FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
   );

--==============================================================================
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO COPY_SDR_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count   => x_msg_count,
           p_data    => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO COPY_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
    WHEN OTHERS THEN
        ROLLBACK TO COPY_SDR_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
END copy_sd_request;
END OZF_SD_REQUEST_PUB;

/
