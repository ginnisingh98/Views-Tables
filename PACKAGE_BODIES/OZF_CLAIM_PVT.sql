--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_PVT" AS
/* $Header: ozfvclab.pls 120.29.12010000.17 2010/06/14 17:24:20 kpatro ship $ */

-- Package name     : OZF_CLAIM_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_CLAIM_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ozfvclab.pls';

-- status
G_CLAIM_STATUS  CONSTANT VARCHAR2(30) := 'OZF_CLAIM_STATUS';
G_INIT_STATUS   CONSTANT VARCHAR2(30) :=  NVL(fnd_profile.value('OZF_CLAIM_DEFAULT_STATUS'), 'NEW'); -- R12 Enhancements
G_OPEN_STATUS   CONSTANT VARCHAR2(30) := 'OPEN';
G_DUPLICATE_STATUS CONSTANT VARCHAR2(30) := 'DUPLICATE';
G_PENDING_STATUS CONSTANT VARCHAR2(30) := 'PENDING';
G_CANCELLED_STATUS CONSTANT VARCHAR2(30) := 'CANCELLED';

-- object_type
G_EMPLOYEE_CAT  CONSTANT VARCHAR2(30) := 'EMPLOYEE';
G_RS_EMPLOYEE_TYPE  CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE';
G_RS_GROUP_TYPE  CONSTANT VARCHAR2(30) := 'RS_GROUP';
G_RS_TEAM_TYPE  CONSTANT VARCHAR2(30) := 'RS_TEAM';

-- For bug#8718804
--G_OBJECT_TYPE   CONSTANT VARCHAR2(10) := 'OZF_CLAM';
G_OBJECT_TYPE   CONSTANT VARCHAR2(10) := 'AMS_CLAM';

G_CLAIM_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'CLAM';
G_DEDUCTION_OBJECT_TYPE CONSTANT VARCHAR2(30) := 'DEDU';
G_CLAIM_LINE_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'LINE';
G_TASK_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'TASK';

-- CLASS
G_CLAIM_CLASS           CONSTANT VARCHAR2(30) := 'CLAIM';
G_DEDUCTION_CLASS       CONSTANT VARCHAR2(30) := 'DEDUCTION';
G_OVERPAYMENT_CLASS     CONSTANT  VARCHAR2(20) := 'OVERPAYMENT';
G_CHARGE_CLASS          CONSTANT  VARCHAR2(20) := 'CHARGE';
G_GROUP_CLASS           CONSTANT  VARCHAR2(20) := 'GROUP';

-- events
G_UPDATE_EVENT  CONSTANT VARCHAR2(30) := 'UPDATE';
G_NEW_EVENT     CONSTANT VARCHAR2(30) := 'NEW';
G_CREATION_EVENT_DESC  CONSTANT VARCHAR2(30) :='OZF_CLAIM_CREATE';

--others
G_CLAIM_HISTORY_TYPE   CONSTANT VARCHAR2(30) := 'OZF_CLAMHIST';
G_CLAIM_TYPE           CONSTANT VARCHAR2(30) := 'OZF_CLAM';

G_SYSTEM_DATE_TYPE     CONSTANT VARCHAR2(30) :='SYSTEM_DATE';
G_CLAIM_DATE_TYPE      CONSTANT VARCHAR2(30) :='CLAIM_DATE';
G_DUE_DATE_TYPE        CONSTANT VARCHAR2(30) :='DUE_DATE';


G_UPDATE_CALLED   boolean := false;  -- This variable is used in the update_claim procedure.
                                     -- It is to see whether an update_claim is called upon already.
                                     -- We use this to avoid multiple save_point setting for settlment.
G_YES       CONSTANT VARCHAR2(1) :='Y';

G_ALLOW_UNREL_SHIPTO_FLAG VARCHAR2(1) := NVL(fnd_profile.value('OZF_CLAIM_UR_SHIPTO'),'N'); -- 4334023

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
-- Definitions of some packagewise cursors.
---------------------------------------------------------------------
 -- fix for bug 5042046
CURSOR gp_func_currency_cd_csr IS
SELECT gs.currency_code
FROM   gl_sets_of_books gs,
       ozf_sys_parameters osp
WHERE  gs.set_of_books_id = osp.set_of_books_id
AND    osp.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

---------------------------------------------------------------------
-- Definitions of some packagewise data type.
---------------------------------------------------------------------
Type gp_access_list_type is table of ams_access_pvt.access_rec_type INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_System_Status
--
-- PURPOSE
--    This procedure maps a user_status_id to a system status.
--
-- PARAMETERS
--    p_user_status_id: Id of the status defined by a user.
--    p_status_type:
--    x_system_status: the system status corresponding a user status id
--    x_msg_data
--    x_msg_count
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_System_Status( p_user_status_id IN NUMBER,
                             p_status_type    IN VARCHAR2,
                             x_system_status  OUT NOCOPY VARCHAR,
              x_msg_data       OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
              x_return_status  OUT NOCOPY VARCHAR2)
IS
CURSOR system_status_csr(p_user_status_id IN NUMBER,
                         p_status_type    IN VARCHAR2)IS
SELECT system_status_code
FROM   ams_user_statuses_vl
WHERE  system_status_type = p_status_type
AND    user_status_id = p_user_status_id;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN system_status_csr(p_user_status_id, p_status_type);
   FETCH system_status_csr INTO x_system_status;
   CLOSE system_status_csr;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_STATUS_CODE');
         FND_MSG_PUB.add;
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
END Get_System_Status;
---------------------------------------------------------------------
-- PROCEDURE
--    get_seeded_user_status
--
-- PURPOSE
--    This procedure maps system status to a seeded user status.
--
-- PARAMETERS
--    p_status_code: status code of a system status.
--    p_status_type:
--    x_user_status_id: the system status corresponding a user status id
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_seeded_user_status( p_status_code      IN VARCHAR2,
                                  p_status_type      IN VARCHAR2,
                                  x_user_status_id   OUT NOCOPY NUMBER,
                                  x_return_status    OUT NOCOPY VARCHAR2)
IS
CURSOR Get_Status_csr IS
SELECT user_status_id
FROM   ams_user_statuses_vl
WHERE  system_status_type = p_status_type
AND    system_status_code = p_status_code
AND    seeded_flag = 'Y';

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN Get_Status_csr;
   FETCH Get_Status_csr INTO x_user_status_id;
   CLOSE Get_Status_csr;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVALID_USER_STATUS');
        FND_MSG_PUB.add;
     END IF;
END get_seeded_user_status;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_Claim_Number
--
-- PURPOSE
--    This procedure retrieves a claim number based on the object_type
--    and class.
--
-- PARAMETERS
--    p_claim  : The claim record passed in.
--    p_object_type : The type of object.
--    p_class       : class.
--    x_claim_number :claim number based on the object_type and class.
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Claim_Number( p_split_from_claim_id IN NUMBER,
                            p_custom_setup_id IN NUMBER,
                            x_claim_number   OUT NOCOPY VARCHAR2,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2)

IS
CURSOR Claim_Number_csr(p_claim_id in number) IS
SELECT claim_number
FROM ozf_claims_all
WHERE claim_id = p_claim_id;

CURSOR Number_of_Split_csr(p_split_from_claim_id in number) IS
SELECT count(claim_id)
FROM ozf_claims_all
WHERE split_from_claim_id = p_split_from_claim_id;

CURSOR c_seq_csr IS
SELECT TO_CHAR(ams_source_codes_gen_s.NEXTVAL)
FROM DUAL;

CURSOR prefix_csr (p_id in number) IS
SELECT source_code_suffix
FROM ams_custom_setups_b
WHERE custom_setup_id = p_id;

CURSOR claim_number_count_csr(p_claim_number in varchar2) IS
SELECT count(claim_number)
FROM   ozf_claims_all
WHERE  upper(claim_number) = p_claim_number;

l_count number := -1;

l_prefix       VARCHAR2(30);
l_seq          NUMBER;
l_claim_number VARCHAR2(30);
l_temp_claim_number varchar2(30);
l_parent_claim_number VARCHAR2(30);
l_number_of_split_claim NUMBER;

l_claim_number_length   NUMBER;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_split_from_claim_id is null OR
       p_split_from_claim_id = FND_API.G_MISS_NUM) THEN

       OPEN prefix_csr(p_custom_setup_id);
       FETCH prefix_csr INTO l_prefix;
       CLOSE prefix_csr;

       IF l_prefix is NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SUFFIX_NOT_FOUND');
             FND_MSG_PUB.add;
          END IF;
     RAISE FND_API.G_EXC_ERROR;
       END IF;

       OPEN c_seq_csr;
       FETCH c_seq_csr INTO l_seq;
       CLOSE c_seq_csr;

       l_claim_number := l_prefix || l_seq;
       LOOP
          OPEN claim_number_count_csr(l_claim_number);
          FETCH claim_number_count_csr into l_count;
          CLOSE claim_number_count_csr;

          -- Find the correct claim number
          EXIT WHEN l_count = 0;

          -- get the next available number
          OPEN c_seq_csr;
          FETCH c_seq_csr INTO l_seq;
          CLOSE c_seq_csr;
          l_claim_number := l_prefix || l_seq;
       END LOOP;
   ELSE
      -- Get the parent_claim_number
      OPEN Claim_Number_csr(p_split_from_claim_id);
      FETCH Claim_Number_csr INTO l_parent_claim_number;
      ClOSE Claim_Number_csr;

      -- Get the number of split claims
      OPEN Number_of_Split_csr(p_split_from_claim_id);
      FETCH Number_of_Split_csr INTO l_number_of_split_claim;
      CLOSE Number_of_Split_csr;

      l_number_of_split_claim := l_number_of_split_claim +1;

      --Bug fix 3354592
      l_claim_number_length := length(l_parent_claim_number || '_' || l_number_of_split_claim);
      IF  l_claim_number_length > 30 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NUMBER_TOO_LARGE');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --Bug fix 3354592
      l_claim_number := l_parent_claim_number || '_' || l_number_of_split_claim;
   END IF;
   x_claim_number := l_claim_number;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NO_CLAIM_NUMBER');
        FND_MSG_PUB.add;
     END IF;
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );
END Get_Claim_Number;

---------------------------------------------------------------------
-- PROCEDURE
--    get_customer_info
--
-- PURPOSE
--    This procedure default the cusomter information
--
-- PARAMETERS
--    p_claim        : claim record
--    x_claim        : defaulted record
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_customer_info (p_claim          in  claim_rec_type,
                             x_claim          OUT NOCOPY claim_rec_type,
              x_return_status  OUT NOCOPY VARCHAR2)
IS

l_claim  claim_rec_type := p_claim;

-- get shipto customer based on shipto site
CURSOR shipto_cust_account_id_csr(p_site_use_id in number) is
select a.cust_account_id
FROM   HZ_CUST_ACCT_SITES a
,      HZ_CUST_SITE_USES s
WHERE  a.cust_acct_site_id = s.cust_acct_site_id
and    s.site_use_id = p_site_use_id;
l_shipto_cust_account_id number;

--default bill_to based on ship_to
CURSOR bill_to_bsd_ship_to_csr (p_shipto_id in number) is
SELECT bill_to_site_use_id
FROM   HZ_CUST_SITE_USES
WHERE  site_use_id = p_shipto_id;

-- default get billto_site and pseudo salesrep_id, contact_id
-- from customer account table
-- not good performance
CURSOR cust_info_csr (p_cust_acct_id in NUMBER) is
SELECT s.site_use_id  -- b      illto site
,      s.contact_id     -- party relation id (do not store this value- see SQL below)
FROM   HZ_CUST_ACCT_SITES a
,      HZ_CUST_SITE_USES s
WHERE  a.cust_account_id = p_cust_acct_id
AND    a.cust_acct_site_id = s.cust_acct_site_id
AND    s.site_use_code = 'BILL_TO'
AND    s.primary_flag = 'Y';

l_bill_to_id   number;
l_pseudo_contact_id    number;

-- get primary ship to information
CURSOR cust_shipinfo_csr (p_cust_acct_id in NUMBER) is
SELECT s.site_use_id  --shipto site
FROM   HZ_CUST_ACCT_SITES a
,      HZ_CUST_SITE_USES s
WHERE  a.cust_account_id = p_cust_acct_id
AND    a.cust_acct_site_id = s.cust_acct_site_id
AND    s.site_use_code = 'SHIP_TO'
AND    s.primary_flag = 'Y';


-- default contact id based on cust_acct_id and pseudo contact_id
CURSOR contact_id_csr(p_cust_account_id in number,
                      p_party_relationship_id in number) is
SELECT p.party_id --     ,p.party_name
FROM   hz_relationships r -- Bug 4654753
,      hz_parties p
,      hz_cust_accounts c
WHERE  r.subject_id = p.party_id
AND    r.relationship_id = p_party_relationship_id -- Bug 4654753
AND    r.object_id = c.party_id
AND    c.cust_account_id = p_cust_account_id;

-- default salesrep resource based on bill to/ship to
CURSOR salesrep_csr(p_site_use_id  in number) is
SELECT s.primary_salesrep_id -- salesrep id, r.name, r.resource_id -- resource id
FROM   HZ_CUST_SITE_USES s
WHERE  s.site_use_id = p_site_use_id;

CURSOR PRM_SALES_REP_CSR (p_source_object_id in number)is
select primary_salesrep_id
from ra_customer_trx_all
where customer_trx_id = p_source_object_id;

CURSOR billto_contact_CSR (p_source_object_id in number)is
select bill_to_contact_id
from ra_customer_trx
where customer_trx_id = p_source_object_id;
l_contact_id number;

CURSOR contact_party_id_csr (p_contact_id in number) is
select p.party_id
from hz_parties p
,    hz_cust_account_roles r
,    hz_relationships rel
where   r.cust_account_role_id = p_contact_id
and  r.party_id = rel.party_id
and  rel.subject_id = p.party_id
and SUBJECT_TABLE_NAME = 'HZ_PARTIES'
AND OBJECT_TABLE_NAME = 'HZ_PARTIES'
AND DIRECTIONAL_FLAG = 'F';

BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get customer info
   OPEN cust_info_csr (l_claim.cust_account_id);
   FETCH cust_info_csr INTO l_bill_to_id, l_pseudo_contact_id;
   CLOSE cust_info_csr;

   -- Bug4334023: Default Ship To Information
   -- if shipto_cust_account_id is null then
   --    if ship to site info is not null then
   --        get it from ship to site (AR passes only ship to site)
   --    else
   --        default it to cust_account_id if not a source deduction
   --    end if
   -- end if
   IF (l_claim.ship_to_cust_account_id IS NULL OR
          l_claim.ship_to_cust_account_id = FND_API.G_MISS_NUM) THEN
      IF (l_claim.cust_shipto_acct_site_id is not null AND
           l_claim.cust_shipto_acct_site_id <> FND_API.G_MISS_NUM) THEN
            OPEN shipto_cust_account_id_csr(l_claim.cust_shipto_acct_site_id);
            FETCH shipto_cust_account_id_csr INTO l_claim.ship_to_cust_account_id;
            CLOSE shipto_cust_account_id_csr;
      ELSE
          IF (l_claim.SOURCE_OBJECT_ID IS NULL OR
                     l_claim.SOURCE_OBJECT_ID = FND_API.G_MISS_NUM) THEN
              l_claim.ship_to_cust_account_id := l_claim.cust_account_id;
          ELSE -- Added the condition for 6338281
            IF ((l_claim.SOURCE_OBJECT_ID IS NOT NULL OR
                     l_claim.SOURCE_OBJECT_ID <> FND_API.G_MISS_NUM) AND l_claim.cust_shipto_acct_site_id is null
             OR l_claim.cust_shipto_acct_site_id = FND_API.G_MISS_NUM ) THEN
                        l_claim.ship_to_cust_account_id := l_claim.cust_account_id;
                     END IF;
          END IF;
      END IF;
   END IF;

   -- Bug4334023: Default Ship To Information
   -- if ship to site info is null then
   --       default to primary ship to of shipto_cust_account_id if not a source deduction
   -- end if
   -- Added the souce_object_class check for 6338281
    IF (l_claim.cust_shipto_acct_site_id is null OR l_claim.cust_shipto_acct_site_id = FND_API.G_MISS_NUM)
    AND (l_claim.SOURCE_OBJECT_ID IS NULL OR  l_claim.SOURCE_OBJECT_ID = FND_API.G_MISS_NUM OR
        l_claim.SOURCE_OBJECT_CLASS IN ('BATCH','SOFT_FUND','SPECIAL_PRICE')) THEN
         OPEN cust_shipinfo_csr (l_claim.ship_to_cust_account_id);
         FETCH cust_shipinfo_csr INTO l_claim.cust_shipto_acct_site_id;
         CLOSE cust_shipinfo_csr;
   END IF;


   IF (l_claim.cust_shipto_acct_site_id is null OR l_claim.cust_shipto_acct_site_id = FND_API.G_MISS_NUM)
   THEN
      l_claim.ship_to_cust_account_id := NULL;
   END IF;

   -- Bug4334023: Default Bill To Information
   -- if bill_to site is null Then
   --    if shipto_cust_account_id is same as cust account id and ship to site is not null
   --       default bill_to site based on the ship_to site
   --    if still null then
   --       default bill_to site based on the cust_account_id
   -- end if;
   IF (l_claim.cust_billto_acct_site_id is null OR
       l_claim.cust_billto_acct_site_id = FND_API.G_MISS_NUM) THEN
       IF l_claim.cust_shipto_acct_site_id IS NOT NULL AND l_claim.ship_to_cust_account_id = l_claim.cust_account_id THEN
              OPEN bill_to_bsd_ship_to_csr (l_claim.cust_shipto_acct_site_id);
              FETCH bill_to_bsd_ship_to_csr INTO l_claim.cust_billto_acct_site_id;
              CLOSE bill_to_bsd_ship_to_csr;
       END IF;
       IF l_claim.cust_billto_acct_site_id is null THEN
              l_claim.cust_billto_acct_site_id := l_bill_to_id;
       END IF;
   END IF;


   -- default salesrep_id:
   -- If ship_to site is not null Then
   --    default salesrep_id based on the ship_to site
   -- elsif bill_to site is not null
   --    default salesrep_id based on the bill_to site
   -- end if;
   IF (l_claim.sales_rep_id is null OR
       l_claim.sales_rep_id = FND_API.G_MISS_NUM) THEN

      -- If this is a deduction, we will try to get the salesrep_id from the transaction.
      -- If we can't, we will try to default it based on shipto, billto and cust_acct_id.
      --//Bug Fix: 7378832
      IF l_claim.SOURCE_OBJECT_CLASS IN ('INVOICE','DM') THEN
         IF (l_claim.SOURCE_OBJECT_ID is not NULL AND
                    l_claim.SOURCE_OBJECT_ID <> FND_API.G_MISS_NUM) THEN
            OPEN PRM_SALES_REP_CSR (l_claim.source_object_id);
            FETCH PRM_SALES_REP_CSR INTO l_claim.sales_rep_id;
            CLOSE PRM_SALES_REP_CSR;
         END IF;
      END IF;

      IF (l_claim.sales_rep_id is null) THEN
         IF l_claim.cust_shipto_acct_site_id is not null AND
            l_claim.cust_shipto_acct_site_id <> FND_API.G_MISS_NUM AND
            l_shipto_cust_account_id is not null AND
            l_shipto_cust_account_id = l_claim.cust_account_id THEN

            OPEN salesrep_csr(l_claim.cust_shipto_acct_site_id);
            FETCH salesrep_csr INTO l_claim.sales_rep_id;
            CLOSE salesrep_csr;
        END IF;

        -- Try billto_acct_site_id if salesrep id is still null
        IF (l_claim.sales_rep_id is null AND
            l_claim.cust_billto_acct_site_id is not null AND
            l_claim.cust_billto_acct_site_id <> FND_API.G_MISS_NUM) THEN

            OPEN salesrep_csr(l_claim.cust_billto_acct_site_id);
            FETCH salesrep_csr INTO l_claim.sales_rep_id;
            CLOSE salesrep_csr;
        END IF;
      END IF;
   END IF;

   -- default contact_id
   -- if pseudo_contact_id is not null
   --    default contact_id based on pseudo_contact_id and cust_account_id
   -- end if;
   IF (l_claim.CONTACT_ID is null OR
       l_claim.contact_id = FND_API.G_MISS_NUM) THEN

                 -- If this is a deduction, we will try to get the salesrep_id from the transaction.
       -- If we can't, we will try to default it based on shipto, billto and cust_acct_id.
       IF (l_claim.SOURCE_OBJECT_ID is not NULL AND
                     l_claim.SOURCE_OBJECT_ID <> FND_API.G_MISS_NUM) THEN
          OPEN billto_contact_CSR (l_claim.source_object_id);
          FETCH billto_contact_CSR INTO l_contact_id;
          CLOSE billto_contact_CSR;

                         IF l_contact_id is not null THEN
                            -- We need to transfer this id to party id
                            OPEN contact_party_id_csr (l_contact_id);
                                 FETCH contact_party_id_csr into l_claim.contact_id;
                                 CLOSE contact_party_id_csr;
                         END IF;
       END IF;

       IF l_claim.contact_id is null and l_pseudo_contact_id is not null THEN
          OPEN contact_id_csr(l_claim.cust_account_id, l_pseudo_contact_id);
                         FETCH contact_id_csr INTO l_claim.contact_id;
                         CLOSE contact_id_csr;
       END IF;
   END IF;

   x_claim := l_claim;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CUSTOMER_INFO_ERR');
        FND_MSG_PUB.add;
     END IF;
END get_customer_info;

---------------------------------------------------------------------
-- PROCEDURE
--    get_days_due
--
-- PURPOSE
--    This procedure maps gets the days_due
--
-- PARAMETERS
--    p_cust_account : custome account id
--    x_days_due     : days due
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_days_due (p_cust_accout_id IN  NUMBER,
                        x_days_due       OUT NOCOPY NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2)
IS
CURSOR days_due_csr(p_customer_account_id in number) IS
SELECT days_due
FROM   ozf_cust_trd_prfls
WHERE  cust_account_id = p_customer_account_id;

-- fix for bug 5042046
CURSOR sys_parameters_days_due_csr IS
SELECT days_due
FROM   ozf_sys_parameters
where   org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

l_days_due  number;
BEGIN

   -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- get customer info from trade profile
   OPEN days_due_csr(p_cust_accout_id);
   FETCH days_due_csr into l_days_due;
   CLOSE days_due_csr;

   -- get days_due from ozf_sys_parameters.
   IF l_days_due is null  THEN
      OPEN sys_parameters_days_due_csr;
      FETCH sys_parameters_days_due_csr INTO l_days_due;
      CLOSE sys_parameters_days_due_csr;
      IF l_days_due is null THEN
         l_days_due := 0;
      END IF;
   END IF;
   x_days_due:= l_days_due;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DAYS_DUE_ERR');
        FND_MSG_PUB.add;
     END IF;
END get_days_due;

---------------------------------------------------------------------
-- PROCEDURE
--    get_offer_qualifiers
--
-- PURPOSE
--    This procedure gets the values of offer qualifiers
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_offer_qualifiers(
        p_cust_account_id    IN NUMBER,
        p_billto_site_id     IN NUMBER,
        p_shipto_site_id     IN NUMBER,
        x_account_code       OUT NOCOPY NUMBER,
        x_customer_category  OUT NOCOPY VARCHAR2,
        x_customer_id      OUT NOCOPY NUMBER,
        x_sales_channel      OUT NOCOPY VARCHAR2,
        x_customer_profile   OUT NOCOPY NUMBER,
        x_site_class         OUT NOCOPY VARCHAR2,
        x_city               OUT NOCOPY VARCHAR2,
        x_county             OUT NOCOPY VARCHAR2,
        x_country            OUT NOCOPY VARCHAR2,
        x_postal_code        OUT NOCOPY VARCHAR2,
        x_state              OUT NOCOPY VARCHAR2,
        x_province           OUT NOCOPY VARCHAR2,
        x_party_relation     OUT NOCOPY VARCHAR2,
        x_account_classification OUT NOCOPY NUMBER,
        x_account_hierarchy  OUT NOCOPY NUMBER,
        x_return_status      OUT NOCOPY VARCHAR2
)IS
l_account_code                number:=null;
l_customer_category           varchar2(30):=null;
l_customer_id                 number;
l_sales_channel               varchar2(30):=null;
l_customer_profile_id         number;
l_site_class                  varchar2(30):=null;
l_city                        varchar2(60):=null;
l_county                      varchar2(60):=null;
l_country                     varchar2(60):=null;
l_postal_code                 varchar2(60):=null;
l_state                       varchar2(60):=null;
l_province                    varchar2(60):=null;
l_party_relation              varchar2(60):=null;
l_account_classification      number;
l_account_hierarchy           number;

CURSOR account_code_csr(p_site_id in number)is
SELECT party_site_id
FROM hz_cust_acct_sites
WHERE cust_acct_site_id = p_site_id;

CURSOR cust_account_info_csr(p_cust_account_id in number) is
SELECT party_id, sales_channel_code
FROM hz_cust_accounts
WHERE CUST_ACCOUNT_ID = p_cust_account_id;

-- waiting for customer_class_code query
--CURSOR cust_account_info_csr(p_cust_account_id in number) is
--SELECT party_id, customer_class_code, sales_channel_code
--FROM hz_cust_accounts
--WHERE CUST_ACCOUNT_ID = p_cust_account_id;

CURSOR party_info_csr(p_party_id in number)is
SELECT category_code
FROM hz_parties
WHERE party_id = p_party_id;

CURSOR cust_profile_csr(p_account_id in number,
                        p_site_use_id in number) is
SELECT profile_class_id
FROM hz_customer_profiles
WHERE cust_account_id = p_account_id
AND   site_use_id = p_site_use_id;


-- For Bug#9146716 (+)

CURSOR cust_profile_site_csr(p_account_id in number) is
SELECT profile_class_id
FROM hz_customer_profiles
WHERE cust_account_id = p_account_id
AND   site_use_id IS NULL;

-- For Bug#9146716 (-)

CURSOR site_use_code_csr(p_site_use_id in number) is
SELECT site_use_code
FROM hz_cust_site_uses
WHERE site_use_id = p_site_use_id;

--based on ship to site if found, else bill to site.
-- location_id is the primary key for hz_locations.
--to get location_id (verify the sqls)
CURSOR location_id_csr(p_site_id in number) IS
SELECT ps.location_id
FROM   hz_party_sites ps
,      hz_cust_acct_sites ac
,      hz_cust_site_uses su
WHERE  ps.party_site_id = ac.party_site_id
AND    ac.cust_acct_site_id = su.cust_acct_site_id
AND    su.site_use_id = p_site_id;
l_location_id number;

CURSOR location_info_csr(p_location_id in number) is
SELECT  city, county, country, postal_code, state, province
FROM hz_locations
WHERE location_id = p_location_id;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get account_code
  IF p_shipto_site_id is not null THEN
     OPEN account_code_csr(p_shipto_site_id);
     FETCH account_code_csr into l_account_code;
     CLOSE account_code_csr;
  END IF;

  IF l_account_code is null and p_billto_site_id is not null THEN
     OPEN account_code_csr(p_billto_site_id);
     FETCH account_code_csr into l_account_code;
     CLOSE account_code_csr;
  END IF;

  OPEN cust_account_info_csr(p_cust_account_id);
--  FETCH cust_account_info_csr into l_customer_id, l_account_classification, l_sales_channel;
  FETCH cust_account_info_csr into l_customer_id, l_sales_channel;
  CLOSE cust_account_info_csr;

  OPEN party_info_csr(l_customer_id);
  FETCH party_info_csr into l_customer_category;
  CLOSE party_info_csr;

  IF p_shipto_site_id is not null THEN
     OPEN cust_profile_csr(p_cust_account_id, p_shipto_site_id);
     FETCH cust_profile_csr into l_customer_profile_id;
     CLOSE cust_profile_csr;
  END IF;

  -- get customer profile
  IF l_customer_profile_id is null THEN
     IF p_billto_site_id is not null THEN
        OPEN cust_profile_csr(p_cust_account_id, p_billto_site_id);
        FETCH cust_profile_csr into l_customer_profile_id;
        CLOSE cust_profile_csr;

        IF l_customer_profile_id is null THEN
        -- For Bug#9146716 (+)
        /*
           OPEN cust_profile_csr(p_cust_account_id, null);
           FETCH cust_profile_csr into l_customer_profile_id;
           CLOSE cust_profile_csr;
        */
        OPEN cust_profile_site_csr(p_cust_account_id);
        FETCH cust_profile_site_csr into l_customer_profile_id;
        CLOSE cust_profile_site_csr;
        END IF;
     ELSE
        /*
        OPEN cust_profile_csr(p_cust_account_id, null);
        FETCH cust_profile_csr into l_customer_profile_id;
        CLOSE cust_profile_csr;
        */
        OPEN cust_profile_site_csr(p_cust_account_id);
        FETCH cust_profile_site_csr into l_customer_profile_id;
        CLOSE cust_profile_site_csr;

        -- For Bug#9146716 (-)
     END IF;
  END IF;

  -- get site classification
  IF p_shipto_site_id is not null THEN
     OPEN site_use_code_csr(p_shipto_site_id);
     FETCH site_use_code_csr into l_site_class;
     CLOSE site_use_code_csr;
  END IF;

  IF l_site_class is null AND p_billto_site_id is not null THEN
     OPEN site_use_code_csr(p_billto_site_id);
     FETCH site_use_code_csr into l_site_class;
     CLOSE site_use_code_csr;
  END IF;

  -- get location_id
  IF p_shipto_site_id is not null THEN
     OPEN location_id_csr(p_shipto_site_id);
     FETCH location_id_csr into l_location_id;
     CLOSE location_id_csr;
  END IF;

  IF l_location_id is null AND p_billto_site_id is not null THEN
     OPEN location_id_csr(p_billto_site_id);
     FETCH location_id_csr into l_location_id;
     CLOSE location_id_csr;
  END IF;

  -- If location_id is not null, then put the address info
  IF l_location_id is not null THEN
     OPEN location_info_csr (l_location_id);
     FETCH location_info_csr into l_city, l_county, l_country, l_postal_code, l_state, l_province;
     CLOSE location_info_csr;
  END IF;

  x_account_code      := l_account_code;
  x_customer_category := l_customer_category;
  x_customer_id       := l_customer_id;
  x_sales_channel     := l_sales_channel;
  x_customer_profile  := l_customer_profile_id;
  x_site_class        := l_site_class;
  x_city              := l_city;
  x_county            := l_county;
  x_country           := l_country;
  x_postal_code       := l_postal_code;
  x_state             := l_state;
  x_province          := l_province;
  x_party_relation    := l_party_relation;
  x_account_classification := l_account_classification;
  x_account_hierarchy := l_account_hierarchy;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_OFF_QUAL_ERR');
        FND_MSG_PUB.add;
     END IF;
END get_offer_qualifiers;
---------------------------------------------------------------------
-- PROCEDURE
--    get_owner
--
-- PURPOSE
--    This procedure gets the owner of a claim by call jft_terr assignment manager
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_owner (p_claim_type_id   IN NUMBER,
                     p_claim_id        IN NUMBER,
                     p_reason_code_id  IN NUMBER,
                     p_vendor_id       IN NUMBER,
                     p_vendor_site_id  IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_billto_site_id  IN NUMBER,
                     p_shipto_site_id  IN NUMBER,
                     p_claim_class     IN VARCHAR2,
                     x_owner_id       OUT NOCOPY NUMBER,
                     x_access_list    OUT NOCOPY gp_access_list_type,
                     x_return_status  OUT NOCOPY VARCHAR2)
IS
lp_gen_bulk_Rec               JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
l_gen_return_Rec              JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
l_use_type                    VARCHAR2(30);
l_Return_Status               VARCHAR2(01);
l_Msg_Count                   NUMBER;
l_Msg_Data                    VARCHAR2(2000);
l_counter                     NUMBER;
l_rank                        NUMBER;
l_account_code                number;
l_customer_category           varchar2(30);
l_customer_id                 number;
l_sales_channel               varchar2(30);
l_customer_profile_id         number;
l_site_class                  varchar2(30);
l_city                        varchar2(60);
l_county                      varchar2(60);
l_country                     varchar2(60);
l_postal_code                 varchar2(60);
l_state                       varchar2(60);
l_province                    varchar2(60);
l_party_relation              varchar2(60);
l_account_classification      varchar2(60);
l_account_hierarchy           number;
l_access_list gp_access_list_type;

CURSOR group_member_csr(p_id in number) is
select b.category, b.resource_id
from jtf_rs_group_members a, ams_jtf_rs_emp_v b
where a.resource_id = b.resource_id
and a.group_id = p_id
and a.delete_flag = 'N';

TYPE group_member_list_TYPE is table of group_member_csr%rowType
                               INDEX BY BINARY_INTEGER;
l_group_member_list group_member_list_type;

-- R12 enhancements

CURSOR team_member_csr(p_id in number) is
select team_resource_id , c.lead_flag
from jtf_rs_team_members a,  jtf_rs_defresroles_vl c
where a.team_member_id = c.role_resource_id(+)
and a.team_id = p_id
and a.delete_flag = 'N'
and c.delete_flag(+) = 'N'
and c.role_resource_type(+) = 'RS_TEAM_MEMBER';

l_team_member_resource_id number := null;
l_team_member_lead_flag varchar2(5) := null;

l_primary_group_id number:= null;

l_access_list_index number;
BEGIN

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_owner_id := null;

    get_offer_qualifiers(
        p_cust_account_id => p_cust_account_id,
        p_billto_site_id  => p_billto_site_id,
        p_shipto_site_id  => p_shipto_site_id,
        x_account_code    => l_account_code,
        x_customer_category => l_customer_category,
        x_customer_id   => l_customer_id,
        x_sales_channel   => l_sales_channel,
        x_customer_profile=> l_customer_profile_id,
        x_site_class      => l_site_class,
        x_city            => l_city,
        x_county          => l_county,
        x_country         => l_country,
        x_postal_code     => l_postal_code,
        x_state           => l_state,
        x_province        => l_province,
        x_party_relation  => l_party_relation,
        x_account_classification => l_account_classification,
        x_account_hierarchy => l_account_hierarchy,
        x_return_status   => x_return_status
    );
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_error;
    END IF;

    -- bulk_trans_rec_type instantiation
    -- logic control properties
    lp_gen_bulk_rec.trans_object_id         := JTF_TERR_NUMBER_LIST(null);
    lp_gen_bulk_rec.trans_detail_object_id  := JTF_TERR_NUMBER_LIST(null);

    -- extend qualifier elements
    lp_gen_bulk_rec.SQUAL_NUM01.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM02.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM03.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM04.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM05.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM06.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM07.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM08.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM09.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM10.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM11.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM12.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM13.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM14.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM15.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM16.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM17.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM18.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM19.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM20.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM21.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM22.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM23.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM24.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM25.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM26.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM27.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM28.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM29.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM30.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM31.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM32.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM33.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM34.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM35.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM36.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM37.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM38.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM39.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM40.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM41.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM42.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM43.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM44.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM45.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM46.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM47.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM48.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM49.EXTEND;
    lp_gen_bulk_rec.SQUAL_NUM50.EXTEND;


    lp_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR02.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR03.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR05.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR06.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR08.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR09.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR10.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR11.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR12.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR13.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR14.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR15.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR16.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR17.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR18.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR19.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR20.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR21.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR22.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR23.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR24.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR25.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR26.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR27.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR28.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR29.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR30.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR31.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR32.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR33.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR34.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR35.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR36.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR37.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR38.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR39.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR40.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR41.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR42.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR43.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR44.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR45.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR46.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR47.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR48.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR49.EXTEND;
    lp_gen_bulk_rec.SQUAL_CHAR50.EXTEND;

    -- transaction qualifier values
    lp_gen_bulk_rec.SQUAL_NUM01(1) := l_customer_id;
    lp_gen_bulk_rec.SQUAL_NUM02(1) := l_account_code;
    lp_gen_bulk_rec.SQUAL_NUM03(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM04(1) := l_account_hierarchy;
    lp_gen_bulk_rec.SQUAL_NUM05(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM06(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM07(1) := l_account_classification;
    lp_gen_bulk_rec.SQUAL_NUM08(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM09(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM10(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM11(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM12(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM13(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM14(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM15(1) := l_customer_profile_id;
    lp_gen_bulk_rec.SQUAL_NUM16(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM17(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM18(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM19(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM20(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM21(1) := p_claim_type_id; -- claim_type_id: sal01: 4 Promotion Good Request;; sal03: 5 Invoice deduction
    lp_gen_bulk_rec.SQUAL_NUM22(1) := p_reason_code_id; -- reason_code_id: sal01: 3 Promotion;; sal03: 82 1 year agreement
    lp_gen_bulk_rec.SQUAL_NUM23(1) := p_vendor_id;
    lp_gen_bulk_rec.SQUAL_NUM24(1) := p_vendor_site_id;
    lp_gen_bulk_rec.SQUAL_NUM25(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM26(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM27(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM28(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM29(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM30(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM31(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM32(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM33(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM34(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM35(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM36(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM37(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM38(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM39(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM40(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM41(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM42(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM43(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM44(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM45(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM46(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM47(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM48(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM49(1) := null;
    lp_gen_bulk_rec.SQUAL_NUM50(1) := null;

    lp_gen_bulk_rec.SQUAL_CHAR01(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR02(1) := l_city;
    lp_gen_bulk_rec.SQUAL_CHAR03(1) := l_county;
    lp_gen_bulk_rec.SQUAL_CHAR04(1) := l_state;
    lp_gen_bulk_rec.SQUAL_CHAR05(1) := l_province;
    lp_gen_bulk_rec.SQUAL_CHAR06(1) := l_postal_code;
    lp_gen_bulk_rec.SQUAL_CHAR07(1) := l_country;
    lp_gen_bulk_rec.SQUAL_CHAR08(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR09(1) := l_customer_category;
    lp_gen_bulk_rec.SQUAL_CHAR10(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR11(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR12(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR13(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR14(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR15(1) := l_party_relation;
    lp_gen_bulk_rec.SQUAL_CHAR16(1) := l_sales_channel;
    lp_gen_bulk_rec.SQUAL_CHAR17(1) := l_site_class;
    lp_gen_bulk_rec.SQUAL_CHAR18(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR19(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR20(1) := p_claim_class;
    lp_gen_bulk_rec.SQUAL_CHAR21(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR22(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR23(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR24(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR25(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR26(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR27(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR28(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR29(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR30(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR31(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR32(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR33(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR34(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR35(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR36(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR37(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR38(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR39(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR40(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR41(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR42(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR43(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR44(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR45(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR46(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR47(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR48(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR49(1) := null;
    lp_gen_bulk_rec.SQUAL_CHAR50(1) := null;

    l_use_type := 'RESOURCE';                      -- OR l_use_type := 'LOOKUP';
    -- source_id : TM :-1003
    -- trasns_id : -1007 : offer, -1302: claim
    JTF_TERR_ASSIGN_PUB.get_winners
    (   p_api_version_number       => 1.0,
        p_init_msg_list            => FND_API.G_FALSE,

        p_use_type                 => l_use_type,
        p_source_id                => -1003,
        p_trans_id                 => -1302,
        p_trans_rec                => lp_gen_bulk_rec,

        p_resource_type            => FND_API.G_MISS_CHAR,
        p_role                     => FND_API.G_MISS_CHAR,
        p_top_level_terr_id        => FND_API.G_MISS_NUM,
        p_num_winners              => FND_API.G_MISS_NUM,

        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data,
        x_winners_rec              => l_gen_return_rec
    );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_PVT.debug_message('winner count:' || l_gen_return_Rec.terr_id.count );
   END IF;
   IF (l_gen_return_Rec.terr_id.LAST >= 1) THEN

      -- For the list of winners, we need to do two things.
      -- 1. find the owner
      -- 2. create the access list based on the ranking and territory.
       -- We only need to consider the winners in the first ranking.

     l_rank := l_gen_return_Rec.absolute_rank(l_gen_return_Rec.terr_id.FIRST);
     For i in 1..l_gen_return_Rec.terr_id.LAST LOOP
         l_access_list(i).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
         l_access_list(i).user_or_role_id := l_gen_return_Rec.RESOURCE_ID(i);

         IF OZF_DEBUG_HIGH_ON THEN
           ozf_utility_PVT.debug_message('winner :'||i||' resource_id:' || l_gen_return_Rec.resource_id(i) );
           ozf_utility_PVT.debug_message('winner :'||i||' type:' || l_gen_return_Rec.resource_type(i) );
           ozf_utility_PVT.debug_message('winner :'||i||' group_id:' || l_gen_return_Rec.group_id(i) );
         END IF;

         l_access_list(i).admin_flag := 'N';
         l_access_list(i).owner_flag := 'N';

         IF l_gen_return_Rec.RESOURCE_TYPE(i) = G_RS_EMPLOYEE_TYPE THEN
             l_access_list(i).arc_user_or_role_type := 'USER';
             IF l_gen_return_Rec.primary_contact_flag(i) = 'Y' THEN
                x_owner_id := l_gen_return_Rec.RESOURCE_ID(i);
             ELSE IF x_owner_id is null THEN
                     x_owner_id := l_gen_return_Rec.RESOURCE_ID(i);
                  END IF;
             END IF;
         ELSIF l_gen_return_Rec.RESOURCE_TYPE(i) = G_RS_GROUP_TYPE THEN
             l_access_list(i).arc_user_or_role_type := 'GROUP';
             IF l_gen_return_Rec.primary_contact_flag(i) = 'Y' THEN
                l_primary_group_id := l_gen_return_Rec.RESOURCE_ID(i);
             END IF;
         ELSIF l_gen_return_Rec.RESOURCE_TYPE(i) = G_RS_TEAM_TYPE THEN
             -- Loop through all the team members and add them to the access list
             l_access_list_index := l_access_list.LAST;
             OPEN team_member_csr(l_gen_return_Rec.RESOURCE_ID(i));
               LOOP
                 FETCH team_member_csr into l_team_member_resource_id, l_team_member_lead_flag;
                 EXIT when team_member_csr%NOTFOUND;
                   l_access_list(l_access_list_index).arc_user_or_role_type := 'USER';
                   l_access_list(l_access_list_index).user_or_role_id := l_team_member_resource_id;
                   l_access_list(l_access_list_index).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
                   l_access_list(l_access_list_index).act_access_to_object_id := p_claim_id;
                   l_access_list(l_access_list_index).owner_flag := 'N';
                   IF l_gen_return_Rec.full_access_flag(i) = 'Y' THEN
                        l_access_list(l_access_list_index).admin_flag := 'Y';
                   END IF;
                   IF (l_gen_return_Rec.primary_contact_flag(i) = 'Y'
                     AND l_team_member_lead_flag = 'Y') THEN
                       x_owner_id := l_team_member_resource_id;
                   ELSIF ( x_owner_id is null ) AND (l_team_member_lead_flag = 'Y') THEN
                       x_owner_id := l_team_member_resource_id;
                   ELSE
                     IF x_owner_id is null THEN
                       x_owner_id := l_team_member_resource_id;
                      END IF;
                   END IF;
                   l_access_list_index := l_access_list_index +1;
               END LOOP;
             CLOSE team_member_csr;
         END IF;
         EXIT WHEN l_gen_return_Rec.absolute_rank(i) <> l_rank;
     END LOOP;

     -- In case there is no owner defined. We need to pick up a owner from the group
     IF x_owner_id is null THEN
        -- pick up the first group as the owner group.
        IF l_primary_group_id is null THEN
           l_primary_group_id := l_access_list(1).user_or_role_id;
        END IF;
        l_counter := 1;
        OPEN group_member_csr(l_primary_group_id);
        LOOP
          EXIT when group_member_csr%NOTFOUND;
          FETCH group_member_csr into l_group_member_list(l_counter);
          l_counter:= l_counter + 1;
        END LOOP;
        CLOSE group_member_csr;

        ---pick one person from the group to be the owner.
        l_access_list_index := l_access_list.LAST;
         For i in 1..l_group_member_list.LAST LOOP
             IF OZF_DEBUG_HIGH_ON THEN
               ozf_utility_PVT.debug_message('l_group_member_list :'||i||' category:' || l_group_member_list(i).category );
               ozf_utility_PVT.debug_message('l_group_member_list :'||i||' resource_id:' || l_group_member_list(i).resource_id );
             END IF;

             IF l_group_member_list(i).category = G_EMPLOYEE_CAT THEN
                x_owner_id := l_group_member_list(i).resource_id;
                         l_access_list_index := l_access_list_index +1;
                l_access_list(l_access_list_index).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
                l_access_list(l_access_list_index).user_or_role_id := l_group_member_list(i).resource_id;
                l_access_list(l_access_list_index).admin_flag := 'Y';
                l_access_list(l_access_list_index).owner_flag := 'Y';
                l_access_list(l_access_list_index).arc_user_or_role_type := 'USER';

                 IF OZF_DEBUG_HIGH_ON THEN
                   ozf_utility_PVT.debug_message('end of assign');
               END IF;
                exit;
             END IF;
         END LOOP;
     ELSE
         -- find the owner in the access list, update its field value
         FOR I in 1..l_access_list.last Loop
             IF l_access_list(i).user_or_role_id = x_owner_id THEN
                l_access_list(i).admin_flag := 'Y';
                l_access_list(i).owner_flag := 'Y';
             END IF;
         EXIT WHEN l_access_list(i).user_or_role_id = x_owner_id;
         END LOOP;
     END IF;
   ELSE
      x_owner_id := null;
   END IF;
   x_access_list := l_access_list;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,'Get_owner');
      END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_GET_OWNER_ERR');
        FND_MSG_PUB.add;
     END IF;
END get_owner;

---------------------------------------------------------------------
-- PROCEDURE
--    generate_tasks
--
-- PURPOSE
--    This procedure maps generate a task list for a claim based on the
--    reason code.
--
-- PARAMETERS
--    p_task_template_group_id : task_template_group_id
--    p_owner_id    : person who is going to perform the task
--    p_claim_id       : claim id
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE generate_tasks( p_task_template_group_id   IN  NUMBER
                         ,p_owner_id         IN  NUMBER
                         ,p_claim_number     IN  VARCHAR2
                         ,p_claim_id         IN  NUMBER
                         ,x_return_status    OUT NOCOPY   VARCHAR2
                         )
IS
l_api_version          CONSTANT NUMBER := 1.0;
l_claim_id             NUMBER := p_claim_id;
l_source_object_name   varchar2(30) := p_task_template_group_id;
l_task_details_tbl     JTF_TASKS_PUB.task_details_tbl;
l_assignment_status_id NUMBER;
l_task_assignment_id   NUMBER;
l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;

CURSOR task_status_csr (p_task_id in number) IS
SELECT task_status_id
FROM   jtf_tasks_vl
WHERE  task_id = p_task_id;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT','create task from template');
      FND_MSG_PUB.Add;
   END IF;

   -- Generate taks template
   JTF_TASKS_PUB.create_task_from_template(
       p_api_version       => l_api_version
      ,p_init_msg_list     => FND_API.g_false
      ,p_commit            => FND_API.g_false
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data
      ,p_task_template_group_id => p_task_template_group_id
      ,p_owner_type_code   => G_RS_EMPLOYEE_TYPE
      ,p_owner_id          => p_owner_id
      ,p_source_object_id  => l_claim_id
      ,p_source_object_name=> p_claim_number
      ,x_task_details_tbl  => l_task_details_tbl
   );
   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      -- Generate tasks
      FOR i in 1..l_task_details_tbl.count LOOP

          OPEN task_status_csr(l_task_details_tbl(i).task_id);
          FETCH task_status_csr INTO l_assignment_status_id;
          CLOSE task_status_csr;

          IF OZF_DEBUG_LOW_ON THEN
             FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
             FND_MESSAGE.Set_Token('TEXT','create task assignment');
             FND_MSG_PUB.Add;
          END IF;

          JTF_TASK_ASSIGNMENTS_PUB.create_task_assignment (
              p_api_version             => l_api_version,
              p_task_id                 => l_task_details_tbl(i).task_id,
              P_RESOURCE_TYPE_CODE      => G_RS_EMPLOYEE_TYPE,
              P_RESOURCE_ID             => p_owner_id ,
              p_assignment_status_id    => l_assignment_status_id,
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count ,
              x_msg_data                => l_msg_data,
              X_TASK_ASSIGNMENT_ID      => l_task_assignment_id
          );
          IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;

      END LOOP;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TASK_API_ERR');
         FND_MSG_PUB.add;
      END IF;
END generate_tasks;



---------------------------------------------------------------------
-- PROCEDURE
--    get_write_off_threshold
--
-- PURPOSE
--    This procedure gets (-VE and +VE)threshold value from customer profile
--    and system parameters.
--
--
-- PARAMETERS
--    p_cust_account_id : claim cust_account_id
--    x_ded_pos_write_off_threshold : Positive threshold value
--    x_opy_neg_write_off_threshold : Negetive threshold value
--
-- NOTES :
--
-- BUG         : 2710047
-- CHANAGED BY : (uday poluri) 28-May-2003
-- COMMENTS    : New procedure in OZF_CLAIM_PVT package called from
--               OZF_CLAIM_PVT.get_write_off_eligibility and
--               OZF_SETTLEMENT_DOC_PVT.Process_Tax_Impact.
----------------------------------------------------------------------
PROCEDURE get_write_off_threshold ( p_cust_account_id              IN NUMBER,
                                    x_ded_pos_write_off_threshold  OUT NOCOPY NUMBER,
                                    x_opy_neg_write_off_threshold  OUT NOCOPY NUMBER,
                                    x_return_status                OUT NOCOPY VARCHAR2
                                   )
IS

   --Variable declarations.
   l_cust_account_id                NUMBER := p_cust_account_id;

   l_ded_pos_write_off_threshold    NUMBER;
   l_opy_neg_write_off_threshold    NUMBER;
   l_party_id                        NUMBER;
   l_get_thr_frm_sysparam           BOOLEAN := false;

   --Cursor to get the party_id of the customer.
   CURSOR   get_party_id_csr( p_cust_account_id IN NUMBER )IS
   SELECT   party_id
   FROM     HZ_CUST_ACCOUNTS
   WHERE    cust_account_id = p_cust_account_id;


   --Cursor to get the Threshold amounts from the customers
   --trade profile based on the account id
   CURSOR   get_cst_trd_prfl_wo_thr_csr(p_cust_account_id IN NUMBER) IS
   SELECT   pos_write_off_threshold
          , neg_write_off_threshold
   FROM     OZF_CUST_TRD_PRFLS
   WHERE    cust_account_id = p_cust_account_id;

   --Cursor to get the Threshold amounts from the customers
   --Tradeprofile based on the party_id
   CURSOR get_prt_trd_prfl_wo_thr_csr(p_party_id IN NUMBER) IS
   SELECT pos_write_off_threshold
        , neg_write_off_threshold
   FROM   OZF_CUST_TRD_PRFLS
   WHERE  party_id = p_party_id
   AND    (pos_write_off_threshold is not null
   AND    neg_write_off_threshold is not null)
   AND    rownum = 1;


   -- fix for bug 5042046
   --Cursor to get the Threshold amounts from the system parameters.
   CURSOR   get_sys_parm_wo_thr_csr IS
   SELECT   pos_write_off_threshold
          , neg_write_off_threshold
   FROM     OZF_SYS_PARAMETERS
   WHERE    org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_cust_account_id IS NOT NULL)
   OR (l_cust_account_id <> FND_API.G_MISS_NUM)
   THEN
      --Get the thresholds from customer trade profile based on account id
      OPEN get_cst_trd_prfl_wo_thr_csr(l_cust_account_id);
      FETCH get_cst_trd_prfl_wo_thr_csr
      INTO l_ded_pos_write_off_threshold, l_opy_neg_write_off_threshold;
      CLOSE get_cst_trd_prfl_wo_thr_csr;

      --START 1
      IF (l_ded_pos_write_off_threshold IS NULL OR l_ded_pos_write_off_threshold = FND_API.G_MISS_NUM)
         AND(l_opy_neg_write_off_threshold IS NULL OR l_opy_neg_write_off_threshold = FND_API.G_MISS_NUM)
      THEN

         --Get the customers party_id
         OPEN get_party_id_csr(l_cust_account_id);
         FETCH get_party_id_csr INTO l_party_id;
         CLOSE get_party_id_csr;

         IF (l_party_id IS NOT NULL AND l_party_id <> FND_API.G_MISS_NUM)
         THEN
            --Get the thresholds from customer trade profile based on party id
            OPEN get_prt_trd_prfl_wo_thr_csr(l_party_id);
            FETCH get_prt_trd_prfl_wo_thr_csr
            INTO l_ded_pos_write_off_threshold, l_opy_neg_write_off_threshold;
            CLOSE get_prt_trd_prfl_wo_thr_csr;

            IF (l_ded_pos_write_off_threshold IS NULL OR l_ded_pos_write_off_threshold = FND_API.G_MISS_NUM)
            AND(l_opy_neg_write_off_threshold IS NULL OR l_opy_neg_write_off_threshold = FND_API.G_MISS_NUM)
            THEN
               --if the thresholds are null then get from the system paramters.
               l_get_thr_frm_sysparam := true;
            END IF;
         ELSE
            --If trade profile is not configured for the party
            --Get the thresholds from Sysparameters
              l_get_thr_frm_sysparam := true;
         END IF; --End of Party_id is not null if block
      END IF; --END OF START 1
   ELSE
      --If the cust_account_id is null then also
      --get the thresholds from system paramters
      l_get_thr_frm_sysparam := true;
   END IF;
   --End of l_cust_account_id is not NULL If block.

   IF (l_get_thr_frm_sysparam = true) THEN
      OPEN get_sys_parm_wo_thr_csr;
      FETCH get_sys_parm_wo_thr_csr INTO l_ded_pos_write_off_threshold, l_opy_neg_write_off_threshold;
      CLOSE get_sys_parm_wo_thr_csr;
   END IF;

   --If the thresholds are null then assign zero
   l_ded_pos_write_off_threshold := NVL(l_ded_pos_write_off_threshold,0);
   l_opy_neg_write_off_threshold := NVL(l_opy_neg_write_off_threshold,0);

   x_ded_pos_write_off_threshold := l_ded_pos_write_off_threshold;
   x_opy_neg_write_off_threshold := l_opy_neg_write_off_threshold;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_WO_THRESHOLD_ERROR');
      FND_MSG_PUB.ADD;
   END IF;
END get_write_off_threshold;

---------------------------------------------------------------------
-- PROCEDURE
--    get_write_off_eligibility
--
-- PURPOSE
--    This procedure checks the eligibility of a deduction/overpayment
--    for the write off and sets the write off flag.
-- PARAMETERS
--    p_claim : Claim record
--    x_claim : Claim record
--    x_return_status
--
-- NOTES : This procedure will be called only if Status_Code is OPEN.
--
-- BUG         : 2710047
-- CHANAGED BY : (uday poluri)
-- COMMENTS    : New procedure in OZF_CLAIM_PVT package called from
--               OZF_CLAIM_PVT.Check_Claim_Common_Elements.

---------------------------------------------------------------------
PROCEDURE get_write_off_eligibility ( p_cust_account_id   IN  NUMBER
                                    , px_currency_code     IN OUT NOCOPY  VARCHAR2
                                    , px_exchange_rate_type IN OUT NOCOPY VARCHAR2
                                    , px_exchange_rate_date IN OUT NOCOPY DATE
                                    , p_exchange_rate      IN NUMBER
                                    , p_set_of_books_id    IN NUMBER
                                    , p_amount             IN NUMBER
                                    , px_acctd_amount      IN OUT NOCOPY NUMBER
                                    , px_acctd_amount_remaining IN OUT NOCOPY NUMBER
                                    , x_write_off_flag     OUT NOCOPY VARCHAR2
                                    , x_write_off_threshold_amount OUT NOCOPY NUMBER
                                    , x_under_write_off_threshold  OUT NOCOPY VARCHAR2
                                    , x_return_status  OUT NOCOPY VARCHAR2)
IS

--Variable declations
l_cust_account_id       NUMBER := p_cust_account_id;
l_currency_code         VARCHAR2(15) := px_currency_code;
l_exchange_rate_type    VARCHAR2(30) := px_exchange_rate_type;
l_exchange_rate_date    DATE := px_exchange_rate_date;
l_exchange_rate         NUMBER := p_exchange_rate;
l_set_of_books_id       NUMBER := p_set_of_books_id;
l_amount                NUMBER := p_amount;

l_acctd_amount          NUMBER := px_acctd_amount;
l_acctd_amount_remaining NUMBER := px_acctd_amount_remaining;

l_acc_amount            NUMBER;
l_rate                  NUMBER;

l_ded_pos_threshold_amount    NUMBER;
l_opy_neg_threshold_amount    NUMBER;
l_functional_currency_code    VARCHAR2(15);
l_write_off_flag              VARCHAR2(1);
l_write_off_threshold_amount  NUMBER;
l_under_write_off_threshold   VARCHAR2(5);

l_return_status   VARCHAR2(30);

-- fix for bug 5042046
--Cursor to get the exchange rate type.
CURSOR get_exchange_rate_type_csr IS
SELECT exchange_rate_type
FROM  OZF_SYS_PARAMETERS
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Get the write-off thresholds
   get_write_off_threshold( p_cust_account_id   => l_cust_account_id
                          , x_ded_pos_write_off_threshold => l_ded_pos_threshold_amount
                          , x_opy_neg_write_off_threshold => l_opy_neg_threshold_amount
                          , x_return_status           => l_return_status
                          );

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.g_exc_error;
   ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --Get the functional currency code
   OPEN   gp_func_currency_cd_csr;
   FETCH  gp_func_currency_cd_csr INTO l_functional_currency_code;
   CLOSE  gp_func_currency_cd_csr;

   --Default the transaction currency code to functional currency
   -- if the transaction currency code is null
   IF (l_currency_code IS NULL
      OR l_currency_code = FND_API.G_MISS_CHAR) THEN
      l_currency_code := l_functional_currency_code;
   END IF;

   --If the transaction currency code is different from the functional currency code
   -- ensure that the exchange type is not null.
   IF (l_currency_code <> l_functional_currency_code) THEN
      IF (l_exchange_rate_type IS NULL
         OR l_exchange_rate_type = FND_API.G_MISS_CHAR) THEN
         --Get the default exchange rate type
         OPEN get_exchange_rate_type_csr;
         FETCH get_exchange_rate_type_csr INTO l_exchange_rate_type;
         CLOSE get_exchange_rate_type_csr;


         --If the exchange rate type is null then raise an error
         IF (l_exchange_rate_type IS NULL
            OR l_exchange_rate_type = FND_API.G_MISS_CHAR) THEN
            IF FND_MSG_PUB.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CONTYPE_MISSING');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      --Check the exchange rate date.
      IF (l_exchange_rate_date IS NULL
         OR l_exchange_rate_date = FND_API.G_MISS_DATE) THEN
         l_exchange_rate_date := SYSDATE;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         ozf_utility_PVT.debug_message('rate_type:'||l_exchange_rate_type);
         ozf_utility_PVT.debug_message('l_exchange_rate_date:'||l_exchange_rate_date);
         ozf_utility_PVT.debug_message('l_exchange_rate:'||l_exchange_rate);
      END IF;

      IF (l_amount <> 0) THEN
         OZF_UTILITY_PVT.Convert_Currency(
              P_SET_OF_BOOKS_ID => l_set_of_books_id,
              P_FROM_CURRENCY   => l_currency_code,
              P_CONVERSION_DATE => l_exchange_rate_date,
              P_CONVERSION_TYPE => l_exchange_rate_type,
              P_CONVERSION_RATE => l_exchange_rate,
              P_AMOUNT          => l_amount,
              X_RETURN_STATUS   => l_return_status,
              X_ACC_AMOUNT      => l_acc_amount,
              X_RATE            => l_rate);
         IF (l_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
         ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         l_exchange_rate := l_rate;
         l_acctd_amount  := l_acc_amount;
         l_acctd_amount_remaining := l_acc_amount;
      ELSE
         l_acctd_amount := l_amount;
      END IF;
      --Round off the amount and acctd_amount according to the currency.
      --As threshold amounts are stored in functional currency, we need to round off by functional currency code.
      l_acctd_amount := OZF_UTILITY_PVT.CurrRound(l_acctd_amount, l_functional_currency_code);
   ELSE --else of IF (l_claim.currency_code <> l_functional_currency_code)
      l_acctd_amount := l_amount;
      l_exchange_rate_type := null;
      l_exchange_rate_date := null;
      l_exchange_rate := 1;
   END IF; -- end of IF (l_claim.currency_code <> l_functional_currency_code)


   IF (l_acctd_amount < 0) THEN
      --Perform -ve threshold comparison.
      l_opy_neg_threshold_amount := NVL(l_opy_neg_threshold_amount, 0);
      IF( abs(l_acctd_amount) < l_opy_neg_threshold_amount )
      THEN
         l_write_off_flag := 'T';
         l_write_off_threshold_amount := l_opy_neg_threshold_amount * -1;
         l_under_write_off_threshold := 'UNDER';
      ELSE
         l_write_off_flag := 'F';
         l_write_off_threshold_amount := l_opy_neg_threshold_amount * -1;
         l_under_write_off_threshold := 'OVER';
      END IF;
   END IF;

   --Check for the +ve (Deduction) amount.
   IF (l_acctd_amount > 0) THEN
      l_ded_pos_threshold_amount := NVL(l_ded_pos_threshold_amount, 0);
      IF (l_acctd_amount < l_ded_pos_threshold_amount)
      THEN
         l_write_off_flag := 'T';
         l_write_off_threshold_amount := l_ded_pos_threshold_amount;
         l_under_write_off_threshold := 'UNDER';
      ELSE
         l_write_off_flag := 'F';
         l_write_off_threshold_amount := l_ded_pos_threshold_amount;
         l_under_write_off_threshold := 'OVER';
      END IF;
   END IF;

   x_write_off_flag := l_write_off_flag;
   x_write_off_threshold_amount := l_write_off_threshold_amount;
   x_under_write_off_threshold := l_under_write_off_threshold;
   px_currency_code := l_currency_code;
   px_exchange_rate_type := l_exchange_rate_type;
   px_exchange_rate_date := l_exchange_rate_date;
   px_acctd_amount := l_acctd_amount;
   px_acctd_amount_remaining := l_acctd_amount_remaining;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_WRITE_OFF_SETUP_ERR');
      FND_MSG_PUB.add;
   END IF;

END get_write_off_eligibility;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Customer_Reason
--
-- PURPOSE
--    This procedure will call get_claim_reason procedure from
--    OZF_Cust_Reason_Mapping_Pvt.
--
-- PARAMETERS
--    p_claim        : claim record
--    x_claim        : defaulted record
--
-- NOTES :
--
-- BUG         : 2732290
-- CHANAGED BY : (Uday Poluri)
-- COMMENTS    : New procedure in OZF_CLAIM_PVT package called from
--               Create_Claim, Update_Claim, Create_Claim_Tbl
----------------------------------------------------------------------
PROCEDURE Get_Customer_Reason( p_cust_account_id     IN NUMBER
                          , px_reason_code_id     IN OUT NOCOPY  NUMBER
                          , p_customer_reason     IN VARCHAR2
                         , x_return_status       OUT NOCOPY  VARCHAR2)
IS


--Variable declaration.
l_cust_account_id    NUMBER := p_cust_account_id;
l_party_id           NUMBER;
l_reason_code_id     NUMBER := px_reason_code_id;
l_customer_reason    VARCHAR2(30) := p_customer_reason;
l_code_conversion_type VARCHAR2(20) :=  'OZF_REASON_CODES';


l_claim_reason_code_id  NUMBER;
l_internal_code         VARCHAR2(150);

l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(30);
l_msg_count          NUMBER;

CURSOR c_party_id(p_cust_id in number) IS
SELECT h.party_id
FROM HZ_CUST_ACCOUNTS H
WHERE h.cust_account_id = p_cust_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_party_id(l_cust_account_id);
   FETCH c_party_id INTO l_party_id;
   CLOSE c_party_id;

  IF (l_customer_reason is not NULL or l_customer_reason <> FND_API.G_MISS_CHAR) AND
     (l_reason_code_id is NULL or l_reason_code_id = FND_API.G_MISS_NUM) THEN
       -- ----------------------------------------------------------------------------
       -- Call OZF_CODE_CONVERSION_PVT.convert_code.
       -- ----------------------------------------------------------------------------
       OZF_CODE_CONVERSION_PVT.convert_code(
                               p_cust_account_id      => l_cust_account_id,
                               p_party_id             => l_party_id,
                               p_code_conversion_type => l_code_conversion_type,
                               p_external_code        => l_customer_reason,
                               x_internal_code        => l_internal_code,
                               X_Return_Status        => l_return_status,
                               X_Msg_Count            => l_msg_count,
                               X_Msg_Data             => l_msg_data );

       IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF l_internal_code is not null THEN
         l_claim_reason_code_id := to_number(l_internal_code);
       END IF;

       IF l_claim_reason_code_id is NOT NULL THEN
         l_reason_code_id := l_claim_reason_code_id;
       ELSE
         -- Mapping for the custome reason is not available. Throw an exception
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NO_REASON_MAPPING');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;

   px_reason_code_id := l_reason_code_id;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Customer_Reason;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Association
-- PURPOSE
--    This procedure will create the claim line and associate the
--    earnings to it.
--
-- PARAMETERS
--   p_claim_id      :   Claim ID
--   p_offer_id      :   Offer ID
--   p_claim_amt     :   Claim Amount
--   p_claim_acc_amt : Claim Accounted Amount
--
--
-- NOTES :
--
-- HISTORY
--    29-Apr-2010  KPATRO  Created for ER#9453443.
---------------------------------------------------------------------

PROCEDURE Create_Claim_Association(
            p_api_version      IN NUMBER,
            p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
            p_commit           IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_claim_id         IN NUMBER,
            p_offer_id         IN NUMBER,
            p_claim_amt        IN NUMBER,
            p_claim_acc_amt    IN NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2)
IS

CURSOR csr_claim_line(cv_claim_line_id IN NUMBER) IS
SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
       , acctd_amount
FROM ozf_claim_lines_all
WHERE claim_line_id = cv_claim_line_id;


l_api_name VARCHAR2(30):= 'Create_Claim_Association';
l_api_version           CONSTANT NUMBER := 1.0;
l_claim_line_rec      OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_funds_util_flt      OZF_Claim_Accrual_PVT.funds_util_flt_type;
l_claim_line_id       NUMBER;
l_return_status  VARCHAR2(30);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_payment_method VARCHAR2(30);
l_vendor_id      NUMBER := 0;
l_vendor_site_id NUMBER := 0;

BEGIN


SAVEPOINT  Create_Claim_Association;
IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('Start :' || l_api_name);
    END IF;

        --Construct the claim line record as:
   l_claim_line_rec.claim_id := p_claim_id;
   l_claim_line_rec.activity_type := 'OFFR';
   l_claim_line_rec.activity_id := p_offer_id;
   l_claim_line_rec.claim_currency_amount := p_claim_amt;
   l_claim_line_rec.amount := p_claim_amt;
   l_claim_line_rec.acctd_amount := p_claim_acc_amt;


   OZF_CLAIM_LINE_PVT.Create_Claim_Line(
       p_api_version       => l_api_version
     , p_init_msg_list     => FND_API.g_false
     , p_commit            => FND_API.g_false
     , p_validation_level  => FND_API.g_valid_level_full
     , x_return_status     => l_return_status
     , x_msg_data          => l_msg_data
     , x_msg_count         => l_msg_count
     , p_claim_line_rec    => l_claim_line_rec
     , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
     , x_claim_line_id     => l_claim_line_id
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_error;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       OZF_Utility_PVT.debug_message('Claim lines created l_claim_line_id =' || l_claim_line_id);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.claim_line_id =' || l_funds_util_flt.claim_line_id);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.activity_type =' || l_funds_util_flt.activity_type);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.activity_id =' || l_funds_util_flt.activity_id);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.product_level_type =' || l_funds_util_flt.product_level_type);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.product_id =' || l_funds_util_flt.product_id);
       OZF_Utility_PVT.debug_message('l_funds_util_flt.total_amount =' || l_funds_util_flt.total_amount);
    END IF;

    OPEN csr_claim_line(l_claim_line_id);
      FETCH csr_claim_line INTO l_funds_util_flt.claim_line_id
                              , l_funds_util_flt.activity_type
                              , l_funds_util_flt.activity_id
                              , l_funds_util_flt.product_level_type
                              , l_funds_util_flt.product_id
                              , l_funds_util_flt.total_amount;

      OZF_CLAIM_ACCRUAL_PVT.Update_Group_Line_Util(
            p_api_version         => l_api_version
           ,p_init_msg_list       => FND_API.g_false
           ,p_commit              => FND_API.g_false
           ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
           ,x_return_status       => l_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,p_summary_view        => 'ACTIVITY'
           ,p_funds_util_flt      => l_funds_util_flt
        );
       IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_error;
       END IF;

   CLOSE csr_claim_line;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
--        IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Create_Claim_Association;
--        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 --       IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Create_Claim_Association;
 --       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
 --       IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Create_Claim_Association;
 --       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
--
END Create_Claim_Association;



---------------------------------------------------------------------
-- PROCEDURE
--    check_amount
--
-- PURPOSE
--    This procedure checks whether there is a need to change the
--    amount field in the ozf_claims_all table.
--
-- PARAMETERS
--    p_claim              in claim_rec_type,
--    p_mode               in varchar2
--    x_amount_changed     OUT NOCOPY boolean,
--    x_exchange_changed   OUT NOCOPY boolean,
--    x_return_status      OUT NOCOPY varchar2
--
-- NOTES
--   Modified by: Uday Poluri    Date: 03-JUN-2003
--   Comments: Added new parameter p_mode.
---------------------------------------------------------------------
PROCEDURE check_amount(p_claim              in claim_rec_type,
                       p_mode               in varchar2,
                       x_amount_changed     OUT NOCOPY boolean,
                       x_exchange_changed   OUT NOCOPY boolean,
                       x_pass               OUT NOCOPY boolean,
                       x_return_status      OUT NOCOPY varchar2
                       )
IS
CURSOR amount_csr(p_id in number) IS
SELECT currency_code,
       exchange_rate_date,
       exchange_rate_type,
       exchange_rate,
       amount,
       amount_adjusted,
       amount_settled,
       cust_account_id
       FROM   ozf_claims_all
WHERE  claim_id = p_id;

l_info amount_csr%rowtype;

BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_pass := true;

   OPEN amount_csr(p_claim.claim_id);
   FETCH amount_csr into l_info;
   CLOSE amount_csr;

   IF p_mode = 'MANU' AND
      (p_claim.claim_class = G_DEDUCTION_CLASS OR
       p_claim.claim_class = G_OVERPAYMENT_CLASS) THEN
       x_pass :=p_claim.currency_code      = l_info.currency_code AND
              ((p_claim.exchange_rate_date is null AND
                l_info.exchange_rate_date is null) OR
               (p_claim.exchange_rate_date is not null AND
                l_info.exchange_rate_date is not null AND
                p_claim.exchange_rate_date = l_info.exchange_rate_date)) AND
              ((p_claim.exchange_rate_type is null AND
                l_info.exchange_rate_type is null) OR
               (p_claim.exchange_rate_type is not null AND
                l_info.exchange_rate_type is not null AND
                p_claim.exchange_rate_type = l_info.exchange_rate_type)) AND
              p_claim.exchange_rate      = l_info.exchange_rate AND
              p_claim.amount             = l_info.amount;

      IF x_pass = true THEN
         x_pass := p_claim.cust_account_id = l_info.cust_account_id;
         IF x_pass = false THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_DED_CUST_CHANGED');
               FND_MSG_PUB.ADD;
            END IF;
        END IF;
      ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_DED_AMT_CHANGED');
             FND_MSG_PUB.ADD;
          END IF;
      END IF;
   END IF;


   IF x_pass = true AND
      p_claim.root_claim_id <> p_claim.claim_id AND
      -- mchang 04/21/2004: add p_mode checking for subsequent receipt amount update in case of split
      p_mode = 'MANU' THEN
      x_pass := p_claim.amount        = l_info.amount;
      IF x_pass = false THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_CHLD_AMT_CHANGED');
            FND_MSG_PUB.ADD;
         END IF;
      END IF;
   END IF;

   x_amount_changed := (
       (p_claim.currency_code      <> l_info.currency_code) OR
       (p_claim.exchange_rate_date is null and
        l_info.exchange_rate_date is not null) OR
       (p_claim.exchange_rate_date is not null and
        l_info.exchange_rate_date is null) OR
       (p_claim.exchange_rate_date is not null and
        l_info.exchange_rate_date is not null and
        p_claim.exchange_rate_date <> l_info.exchange_rate_date) OR
       (p_claim.exchange_rate_type is null and
        l_info.exchange_rate_type is not null) OR
       (p_claim.exchange_rate_type is not null and
        l_info.exchange_rate_type is null) OR
       (p_claim.exchange_rate_type is not null and
        l_info.exchange_rate_type is not null and
        p_claim.exchange_rate_type <> l_info.exchange_rate_type) OR
       (p_claim.exchange_rate      <> l_info.exchange_rate) OR
       (p_claim.amount             <> l_info.amount) OR
       (p_claim.amount_adjusted    <> l_info.amount_adjusted) OR
       (p_claim.amount_settled     <> l_info.amount_settled));

    x_exchange_changed := (
       (p_claim.currency_code      <> l_info.currency_code) OR
       (p_claim.exchange_rate_date is null and
        l_info.exchange_rate_date is not null) OR
       (p_claim.exchange_rate_date is not null and
        l_info.exchange_rate_date is null) OR
       (p_claim.exchange_rate_date is not null and
        l_info.exchange_rate_date is not null and
        p_claim.exchange_rate_date <> l_info.exchange_rate_date) OR
       (p_claim.exchange_rate_type is null and
        l_info.exchange_rate_type is not null) OR
       (p_claim.exchange_rate_type is not null and
        l_info.exchange_rate_type is null) OR
       (p_claim.exchange_rate_type is not null and
        l_info.exchange_rate_type is not null and
        p_claim.exchange_rate_type <> l_info.exchange_rate_type) OR
       (p_claim.exchange_rate      <> l_info.exchange_rate));

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMOUNT_CHANGE_ERR');
         FND_MSG_PUB.add;
      END IF;
END check_amount;
---------------------------------------------------------------------
-- PROCEDURE
--    check_claim_number
--
-- PURPOSE
--    This procedure check whether there is a duplication for a cliam
--    number in the database.
--
-- PARAMETERS
--    p_claim_id       : claim id
--    p_claim_number
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE check_claim_number(p_claim_id      IN  NUMBER,
                             p_claim_number  IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2)
IS
l_claim_id    NUMBER;

CURSOR get_claim_id_csr(p_id in number) IS
SELECT count(claim_id)
FROM   ozf_claims_all
WHERE  claim_id = p_id;

CURSOR get_claim_id_num_csr(p_num in varchar2) IS
SELECT count(claim_id)
FROM   ozf_claims_all
WHERE  claim_number = p_num;

CURSOR get_count_csr(p_number in varchar2,
                     p_claim_id in number) IS
SELECT count(claim_id)
FROM   ozf_claims_all
WHERE  claim_number = p_number
AND    claim_id     = p_claim_id;

l_count  number:=0;
BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ((p_claim_number is null) OR
       (p_claim_number = FND_API.G_MISS_CHAR)) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_CLAIM_NUM');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   ELSE
      -- claim_id will never be not null at this point.
      -- so we first check whether this is a new claim or not.
      l_count := 0;
      OPEN get_claim_id_csr(p_claim_id);
      FETCH get_claim_id_csr INTO l_count;
      CLOSE get_claim_id_csr;

      IF (l_count = 0) THEN
         -- check claim_number for new claim. Here claim_number should not exist

         l_count := 0;
         OPEN get_claim_id_num_csr(p_claim_number);
         FETCH get_claim_id_num_csr INTO l_count;
         CLOSE get_claim_id_num_csr;

         IF l_count <> 0 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUP_CLAIM_NUM_NEW');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      ELSE
         -- check claim_number for an old claim. Here claim_number and claim_id should match
         -- and claim_number should be unique.

         OPEN get_count_csr(p_claim_number, p_claim_id);
         FETCH get_count_csr INTO l_count;
         CLOSE get_count_csr;

         IF l_count <> 1 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ID_NUM_MISS');
                   FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         ELSE
            l_count := 0;
            OPEN get_claim_id_num_csr(p_claim_number);
                           FETCH get_claim_id_num_csr INTO l_count;
                           CLOSE get_claim_id_num_csr;

                           IF l_count <> 1 THEN
                                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                                           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUP_CLAIM_NUM');
                                           FND_MSG_PUB.add;
                                   END IF;
                                   x_return_status := FND_API.g_ret_sts_error;
                           END IF;
                        END IF;
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NUM_CHECK_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END check_claim_number;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_validation_mode
--    p_claim_rec      : the record to be validated
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Claim_Items( p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
                             p_claim_rec         IN claim_rec_type,
                             x_return_status     OUT NOCOPY VARCHAR2
)
IS
l_return_status varchar2(30);
BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- check for duplicate claim numbers
   check_claim_number(
      p_claim_id      => p_claim_rec.claim_id,
      p_claim_number  => p_claim_rec.claim_number,
      x_return_status => l_return_status
   );

   x_return_status := l_return_status;
END Check_Claim_Items;

---------------------------------------------------------------------
-- FUNCTION
--    get_action_id
--
-- PURPOSE
--    This returns an action_id based on the reason_code_id
--
-- PARAMETERS
--    p_reason_code_id
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
FUNCTION get_action_id(p_reason_code_id in number)
return number
IS
CURSOR default_action_id_csr (p_id in number) is
select t.task_template_group_id
from ozf_reasons r,
jtf_task_temp_groups_vl t
where t.source_object_type_code = 'AMS_CLAM'
and r.active_flag = 'T'
and r.default_flag = 'T'
and t.task_template_group_id = r.task_template_group_id
and nvl(t.start_date_active, sysdate) <= sysdate
and nvl(t.end_date_active, sysdate) >= sysdate
and r.reason_code_id = p_id;

l_default_action_id number;
BEGIN

   If (p_reason_code_id is not null and
       p_reason_code_id <> FND_API.G_MISS_NUM) THEN
       OPEN default_action_id_csr(p_reason_code_id);
       FETCH default_action_id_csr into l_default_action_id;
       CLOSE default_action_id_csr;

   ELSE
      l_default_action_id := null;
   END IF;
        return l_default_action_id;
END get_action_id;

---------------------------------------------------------------------
-- PROCEDURE
--    check_deduction
--
-- PURPOSE
--    This procedure validate some deduction information.
--
-- PARAMETERS
--    p_claim              : claim_rec_type
--    p_mode               : varchar2
--    x_pass               : boolean
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE check_deduction(p_claim              in claim_rec_type,
                          p_mode               in  varchar2,
                          x_pass               OUT NOCOPY boolean,
                          x_return_status      OUT NOCOPY varchar2
                          )
IS
CURSOR deduction_info_csr(p_id in number) IS
SELECT currency_code,
       exchange_rate_date,
       exchange_rate_type,
       exchange_rate,
       amount,
       cust_account_id
FROM   ozf_claims_all
WHERE  claim_id = p_id;

l_deduction_info deduction_info_csr%rowtype;

BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_pass := true;

   OPEN deduction_info_csr(p_claim.claim_id);
   FETCH deduction_info_csr into l_deduction_info;
   CLOSE deduction_info_csr;

   -- -------------------------------------------------------------------------------------------
   -- Bug        : 2781186
   -- Changed by : (Uday Poluri)  Date: 03-JUN-2003
   -- Comments   : Add p_mode check, If it is AUTO then allow amount change on claim.
   -- -------------------------------------------------------------------------------------------
   IF p_mode <> OZF_claim_Utility_pvt.G_AUTO_MODE THEN    --Bug:2781186
      IF ((p_claim.currency_code      <> l_deduction_info.currency_code) OR
          (p_claim.exchange_rate_date <> l_deduction_info.exchange_rate_date) OR
          (p_claim.exchange_rate_type <> l_deduction_info.exchange_rate_type) OR
          (p_claim.exchange_rate      <> l_deduction_info.exchange_rate) OR
          (p_claim.amount             <> l_deduction_info.amount)) THEN

          x_pass := false;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_DED_AMT_CHANGED');
             FND_MSG_PUB.ADD;
          END IF;
      END IF;
   END IF; -- End of BUG#2781186

   IF p_claim.cust_account_id      <> l_deduction_info.cust_account_id THEN
       x_pass := false;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_DED_CUST_CHANGED');
          FND_MSG_PUB.ADD;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DED_CHK_ERR');
         FND_MSG_PUB.add;
      END IF;
END check_deduction;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Rec
--
-- PURPOSE
--    For Update_Claim, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Rec (
   p_claim_rec        IN   claim_rec_type
  ,x_complete_rec     OUT NOCOPY  claim_rec_type
  ,x_return_status    OUT NOCOPY  varchar2
)
IS
CURSOR c_claim (cv_claim_id NUMBER) IS
SELECT * FROM ozf_claims_all
WHERE CLAIM_ID = cv_claim_id;

l_claim_rec    c_claim%ROWTYPE;

BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_rec  := p_claim_rec;

  OPEN c_claim(p_claim_rec.claim_id);
  FETCH c_claim INTO l_claim_rec;
     IF c_claim%NOTFOUND THEN
        CLOSE c_claim;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
     END IF;
  CLOSE c_claim;

  IF p_claim_rec.claim_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_id       := NULL;
  END IF;
  IF p_claim_rec.claim_id         IS NULL THEN
     x_complete_rec.claim_id       := l_claim_rec.claim_id;
  END IF;
  IF p_claim_rec.batch_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.batch_id       := NULL;
  END IF;
  IF p_claim_rec.batch_id         IS NULL THEN
     x_complete_rec.batch_id       := l_claim_rec.batch_id;
  END IF;
  IF p_claim_rec.claim_number         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.claim_number       := NULL;
  END IF;
  IF p_claim_rec.claim_number         IS NULL THEN
     x_complete_rec.claim_number       := l_claim_rec.claim_number;
  END IF;
  IF p_claim_rec.claim_type_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_type_id       := NULL;
  END IF;
  IF p_claim_rec.claim_type_id         IS NULL THEN
     x_complete_rec.claim_type_id       := l_claim_rec.claim_type_id;
  END IF;
  IF p_claim_rec.claim_class         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.claim_class       := NULL;
  END IF;
  IF p_claim_rec.claim_class         IS NULL THEN
     x_complete_rec.claim_class       := l_claim_rec.claim_class;
  END IF;
  IF p_claim_rec.claim_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.claim_date       := NULL;
  END IF;
  IF p_claim_rec.claim_date         IS NULL THEN
     x_complete_rec.claim_date       := l_claim_rec.claim_date;
  END IF;
  IF p_claim_rec.due_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.due_date       := NULL;
  END IF;
  IF p_claim_rec.due_date         IS NULL THEN
     x_complete_rec.due_date       := l_claim_rec.due_date;
  END IF;
  IF p_claim_rec.owner_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.owner_id := NULL;
  END IF;
  IF p_claim_rec.owner_id  IS NULL THEN
     x_complete_rec.owner_id := l_claim_rec.owner_id;
  END IF;
  IF p_claim_rec.history_event  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.history_event := NULL;
  END IF;
  IF p_claim_rec.history_event  IS NULL THEN
     x_complete_rec.history_event := l_claim_rec.history_event;
  END IF;
  IF p_claim_rec.history_event_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.history_event_date := NULL;
  END IF;
  IF p_claim_rec.history_event_date  IS NULL THEN
     x_complete_rec.history_event_date := l_claim_rec.history_event_date;
  END IF;
  IF p_claim_rec.history_event_description  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.history_event_description := NULL;
  END IF;
  IF p_claim_rec.history_event_description  IS NULL THEN
     x_complete_rec.history_event_description := l_claim_rec.history_event_description;
  END IF;
  IF p_claim_rec.split_from_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.split_from_claim_id       := NULL;
  END IF;
  IF p_claim_rec.split_from_claim_id  IS NULL THEN
     x_complete_rec.split_from_claim_id       := l_claim_rec.split_from_claim_id;
  END IF;
  IF p_claim_rec.duplicate_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.duplicate_claim_id       := NULL;
  END IF;
  IF p_claim_rec.duplicate_claim_id  IS NULL THEN
     x_complete_rec.duplicate_claim_id       := l_claim_rec.duplicate_claim_id;
  END IF;
  IF p_claim_rec.split_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.split_date := NULL;
  END IF;
  IF p_claim_rec.split_date  IS NULL THEN
     x_complete_rec.split_date := l_claim_rec.split_date;
  END IF;

 IF p_claim_rec.root_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.root_claim_id       := NULL;
  END IF;
 IF p_claim_rec.root_claim_id  IS NULL THEN
     x_complete_rec.root_claim_id       := l_claim_rec.root_claim_id;
  END IF;
  IF p_claim_rec.amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount       := NULL;
  END IF;
  IF p_claim_rec.amount  IS NULL THEN
     x_complete_rec.amount       := l_claim_rec.amount;
  END IF;
  IF p_claim_rec.amount_adjusted  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_adjusted       := NULL;
  END IF;
  IF p_claim_rec.amount_adjusted  IS NULL THEN
     x_complete_rec.amount_adjusted       := l_claim_rec.amount_adjusted;
  END IF;
  IF p_claim_rec.amount_remaining  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_remaining       := NULL;
  END IF;
  IF p_claim_rec.amount_remaining  IS NULL THEN
     x_complete_rec.amount_remaining       := l_claim_rec.amount_remaining;
  END IF;
  IF p_claim_rec.amount_settled  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_settled       := NULL;
  END IF;
  IF p_claim_rec.amount_settled  IS NULL THEN
     x_complete_rec.amount_settled       := l_claim_rec.amount_settled;
  END IF;
  IF p_claim_rec.acctd_amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount       := NULL;
  END IF;
  IF p_claim_rec.acctd_amount  IS NULL THEN
     x_complete_rec.acctd_amount       := l_claim_rec.acctd_amount;
  END IF;
  IF p_claim_rec.acctd_amount_remaining   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_remaining        := NULL;
  END IF;
  IF p_claim_rec.acctd_amount_remaining   IS NULL THEN
     x_complete_rec.acctd_amount_remaining        := l_claim_rec.acctd_amount_remaining ;
  END IF;
  IF p_claim_rec.acctd_amount_adjusted  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_adjusted       := NULL;
  END IF;
  IF p_claim_rec.acctd_amount_adjusted  IS NULL THEN
     x_complete_rec.acctd_amount_adjusted       := l_claim_rec.acctd_amount_adjusted;
  END IF;
  IF p_claim_rec.acctd_amount_settled  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_settled       := NULL;
  END IF;
  IF p_claim_rec.acctd_amount_settled  IS NULL THEN
     x_complete_rec.acctd_amount_settled       := l_claim_rec.acctd_amount_settled;
  END IF;
  IF p_claim_rec.tax_amount   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.tax_amount        := NULL;
  END IF;
  IF p_claim_rec.tax_amount   IS NULL THEN
     x_complete_rec.tax_amount        := l_claim_rec.tax_amount ;
  END IF;
  IF p_claim_rec.tax_code   = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_code        := NULL;
  END IF;
  IF p_claim_rec.tax_code   IS NULL THEN
     x_complete_rec.tax_code        := l_claim_rec.tax_code ;
  END IF;
  IF p_claim_rec.tax_calculation_flag   = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_calculation_flag        := NULL;
  END IF;
  IF p_claim_rec.tax_calculation_flag   IS NULL THEN
     x_complete_rec.tax_calculation_flag        := l_claim_rec.tax_calculation_flag ;
  END IF;
  IF p_claim_rec.currency_code         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.currency_code       := NULL;
  END IF;
  IF p_claim_rec.currency_code         IS NULL THEN
     x_complete_rec.currency_code       := l_claim_rec.currency_code;
  END IF;
  IF p_claim_rec.exchange_rate_type         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.exchange_rate_type       := NULL;
  END IF;
  IF p_claim_rec.exchange_rate_type         IS NULL THEN
     x_complete_rec.exchange_rate_type       := l_claim_rec.exchange_rate_type;
  END IF;
  IF p_claim_rec.exchange_rate_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.exchange_rate_date       := NULL;
  END IF;
  IF p_claim_rec.exchange_rate_date         IS NULL THEN
     x_complete_rec.exchange_rate_date       := l_claim_rec.exchange_rate_date;
  END IF;
  IF p_claim_rec.exchange_rate  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.exchange_rate       := NULL;
  END IF;
  IF p_claim_rec.exchange_rate  IS NULL THEN
     x_complete_rec.exchange_rate       := l_claim_rec.exchange_rate;
  END IF;
  IF p_claim_rec.set_of_books_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.set_of_books_id       := NULL;
  END IF;
  IF p_claim_rec.set_of_books_id  IS NULL THEN
     x_complete_rec.set_of_books_id       := l_claim_rec.set_of_books_id;
  END IF;
  IF p_claim_rec.original_claim_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.original_claim_date       := NULL;
  END IF;
  IF p_claim_rec.original_claim_date         IS NULL THEN
     x_complete_rec.original_claim_date       := l_claim_rec.original_claim_date;
  END IF;
  IF p_claim_rec.source_object_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_id       := NULL;
  END IF;
  IF p_claim_rec.source_object_id  IS NULL THEN
     x_complete_rec.source_object_id       := l_claim_rec.source_object_id;
  END IF;
  IF p_claim_rec.source_object_class  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.source_object_class       := NULL;
  END IF;
  IF p_claim_rec.source_object_class  IS NULL THEN
     x_complete_rec.source_object_class       := l_claim_rec.source_object_class;
  END IF;
  IF p_claim_rec.source_object_type_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_type_id       := NULL;
  END IF;
  IF p_claim_rec.source_object_type_id  IS NULL THEN
     x_complete_rec.source_object_type_id       := l_claim_rec.source_object_type_id;
  END IF;
  IF p_claim_rec.source_object_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.source_object_number       := NULL;
  END IF;
  IF p_claim_rec.source_object_number  IS NULL THEN
     x_complete_rec.source_object_number       := l_claim_rec.source_object_number;
  END IF;
  IF p_claim_rec.cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_account_id       := NULL;
  END IF;
  IF p_claim_rec.cust_account_id  IS NULL THEN
     x_complete_rec.cust_account_id       := l_claim_rec.cust_account_id;
  END IF;
  IF p_claim_rec.cust_billto_acct_site_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_billto_acct_site_id       := NULL;
  END IF;
  IF p_claim_rec.cust_billto_acct_site_id  IS NULL THEN
     x_complete_rec.cust_billto_acct_site_id       := l_claim_rec.cust_billto_acct_site_id;
  END IF;
  IF p_claim_rec.cust_shipto_acct_site_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_shipto_acct_site_id := NULL;
  END IF;
  IF p_claim_rec.cust_shipto_acct_site_id  IS NULL THEN
     x_complete_rec.cust_shipto_acct_site_id := l_claim_rec.cust_shipto_acct_site_id;
  END IF;
  IF p_claim_rec.location_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.location_id       := NULL;
  END IF;
  IF p_claim_rec.location_id  IS NULL THEN
     x_complete_rec.location_id       := l_claim_rec.location_id;
  END IF;
  IF p_claim_rec.pay_related_account_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.pay_related_account_flag := NULL;
  END IF;
  IF p_claim_rec.pay_related_account_flag  IS NULL THEN
     x_complete_rec.pay_related_account_flag := l_claim_rec.pay_related_account_flag;
  END IF;
  IF p_claim_rec.related_cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.related_cust_account_id := NULL;
  END IF;
  IF p_claim_rec.related_cust_account_id  IS NULL THEN
     x_complete_rec.related_cust_account_id := l_claim_rec.related_cust_account_id;
  END IF;
  IF p_claim_rec.related_site_use_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.related_site_use_id := NULL;
  END IF;
  IF p_claim_rec.related_site_use_id  IS NULL THEN
     x_complete_rec.related_site_use_id := l_claim_rec.related_site_use_id;
  END IF;
  IF p_claim_rec.relationship_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.relationship_type := NULL;
  END IF;
  IF p_claim_rec.relationship_type IS NULL THEN
     x_complete_rec.relationship_type := l_claim_rec.relationship_type;
  END IF;
  IF p_claim_rec.vendor_id   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.vendor_id := NULL;
  END IF;
  IF p_claim_rec.vendor_id   IS NULL THEN
     x_complete_rec.vendor_id := l_claim_rec.vendor_id;
  END IF;
  IF p_claim_rec.vendor_site_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.vendor_site_id := NULL;
  END IF;
  IF p_claim_rec.vendor_site_id IS NULL THEN
     x_complete_rec.vendor_site_id := l_claim_rec.vendor_site_id;
  END IF;
  IF p_claim_rec.reason_type  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_type       := NULL;
  END IF;
  IF p_claim_rec.reason_type  IS NULL THEN
     x_complete_rec.reason_type       := l_claim_rec.reason_type;
  END IF;
  IF p_claim_rec.reason_code_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.reason_code_id       := NULL;
  END IF;
  IF p_claim_rec.reason_code_id  IS NULL THEN
     x_complete_rec.reason_code_id       := l_claim_rec.reason_code_id;
  END IF;
  IF p_claim_rec.task_template_group_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_template_group_id       := NULL;
  END IF;
  IF p_claim_rec.task_template_group_id  IS NULL THEN
     x_complete_rec.task_template_group_id       := l_claim_rec.task_template_group_id;
  END IF;
  IF p_claim_rec.status_code  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.status_code       := NULL;
  END IF;
  IF p_claim_rec.status_code  IS NULL THEN
     x_complete_rec.status_code       := l_claim_rec.status_code;
  END IF;
  IF p_claim_rec.user_status_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.user_status_id       := NULL;
  END IF;
  IF p_claim_rec.user_status_id  IS NULL THEN
     x_complete_rec.user_status_id       := l_claim_rec.user_status_id;
  END IF;
  IF p_claim_rec.sales_rep_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.sales_rep_id       := NULL;
  END IF;
  IF p_claim_rec.close_status_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.close_status_id       := NULL;
  END IF;
  IF p_claim_rec.close_status_id  IS NULL THEN
     x_complete_rec.close_status_id       := l_claim_rec.close_status_id;
  END IF;
  IF p_claim_rec.open_status_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.open_status_id       := NULL;
  END IF;
  IF p_claim_rec.open_status_id  IS NULL THEN
     x_complete_rec.open_status_id       := l_claim_rec.open_status_id;
  END IF;
  IF p_claim_rec.sales_rep_id  IS NULL THEN
     x_complete_rec.sales_rep_id       := l_claim_rec.sales_rep_id;
  END IF;
  IF p_claim_rec.collector_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.collector_id       := NULL;
  END IF;
  IF p_claim_rec.collector_id  IS NULL THEN
     x_complete_rec.collector_id       := l_claim_rec.collector_id;
  END IF;
  IF p_claim_rec.contact_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.contact_id       := NULL;
  END IF;
  IF p_claim_rec.contact_id  IS NULL THEN
     x_complete_rec.contact_id       := l_claim_rec.contact_id;
  END IF;
  IF p_claim_rec.broker_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.broker_id       := NULL;
  END IF;
  IF p_claim_rec.broker_id  IS NULL THEN
     x_complete_rec.broker_id       := l_claim_rec.broker_id;
  END IF;
  IF p_claim_rec.territory_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.territory_id       := NULL;
  END IF;
  IF p_claim_rec.territory_id  IS NULL THEN
     x_complete_rec.territory_id       := l_claim_rec.territory_id;
  END IF;
  IF p_claim_rec.customer_ref_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.customer_ref_date       := NULL;
  END IF;
  IF p_claim_rec.customer_ref_date         IS NULL THEN
     x_complete_rec.customer_ref_date       := l_claim_rec.customer_ref_date;
  END IF;
  IF p_claim_rec.customer_ref_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.customer_ref_number       := NULL;
  END IF;
  IF p_claim_rec.customer_ref_number  IS NULL THEN
     x_complete_rec.customer_ref_number       := l_claim_rec.customer_ref_number;
  END IF;
  IF p_claim_rec.receipt_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.receipt_id       := NULL;
  END IF;
  IF p_claim_rec.receipt_id  IS NULL THEN
     x_complete_rec.receipt_id       := l_claim_rec.receipt_id;
  END IF;
  IF p_claim_rec.receipt_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.receipt_number       := NULL;
  END IF;
  IF p_claim_rec.receipt_number  IS NULL THEN
     x_complete_rec.receipt_number       := l_claim_rec.receipt_number;
  END IF;
  IF p_claim_rec.doc_sequence_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.doc_sequence_id       := NULL;
  END IF;
  IF p_claim_rec.doc_sequence_id  IS NULL THEN
     x_complete_rec.doc_sequence_id       := l_claim_rec.doc_sequence_id;
  END IF;
  IF p_claim_rec.doc_sequence_value  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.doc_sequence_value       := NULL;
  END IF;
  IF p_claim_rec.doc_sequence_value  IS NULL THEN
     x_complete_rec.doc_sequence_value       := l_claim_rec.doc_sequence_value;
  END IF;
  IF p_claim_rec.gl_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.gl_date       := NULL;
  END IF;
  IF p_claim_rec.gl_date  IS NULL THEN
     x_complete_rec.gl_date       := l_claim_rec.gl_date;
  END IF;
  IF p_claim_rec.payment_method  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_method       := NULL;
  END IF;
  IF p_claim_rec.payment_method  IS NULL THEN
     x_complete_rec.payment_method       := l_claim_rec.payment_method;
  END IF;
  IF p_claim_rec.voucher_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.voucher_id       := NULL;
  END IF;
  IF p_claim_rec.voucher_id  IS NULL THEN
     x_complete_rec.voucher_id       := l_claim_rec.voucher_id;
  END IF;
  IF p_claim_rec.voucher_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.voucher_number       := NULL;
  END IF;
  IF p_claim_rec.voucher_number  IS NULL THEN
     x_complete_rec.voucher_number       := l_claim_rec.voucher_number;
  END IF;
  IF p_claim_rec.payment_reference_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.payment_reference_id       := NULL;
  END IF;
  IF p_claim_rec.payment_reference_id  IS NULL THEN
     x_complete_rec.payment_reference_id       := l_claim_rec.payment_reference_id;
  END IF;
  IF p_claim_rec.payment_reference_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_reference_number := NULL;
  END IF;
  IF p_claim_rec.payment_reference_number  IS NULL THEN
     x_complete_rec.payment_reference_number := l_claim_rec.payment_reference_number;
  END IF;
  IF p_claim_rec.payment_reference_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.payment_reference_date := NULL;
  END IF;
  IF p_claim_rec.payment_reference_date  IS NULL THEN
     x_complete_rec.payment_reference_date := l_claim_rec.payment_reference_date;
  END IF;
  IF p_claim_rec.payment_status  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_status := NULL;
  END IF;
  IF p_claim_rec.payment_status  IS NULL THEN
     x_complete_rec.payment_status := l_claim_rec.payment_status;
  END IF;
  IF p_claim_rec.approved_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.approved_flag := NULL;
  END IF;
  IF p_claim_rec.approved_flag  IS NULL THEN
     x_complete_rec.approved_flag := l_claim_rec.approved_flag;
  END IF;
  IF p_claim_rec.approved_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.approved_date := NULL;
  END IF;
  IF p_claim_rec.approved_date  IS NULL THEN
     x_complete_rec.approved_date := l_claim_rec.approved_date;
  END IF;
  IF p_claim_rec.approved_by  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.approved_by := NULL;
  END IF;
  IF p_claim_rec.approved_by  IS NULL THEN
     x_complete_rec.approved_by := l_claim_rec.approved_by;
  END IF;
  IF p_claim_rec.settled_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.settled_date := NULL;
  END IF;
  IF p_claim_rec.settled_date  IS NULL THEN
     x_complete_rec.settled_date := l_claim_rec.settled_date;
  END IF;
  IF p_claim_rec.settled_by  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.settled_by := NULL;
  END IF;
  IF p_claim_rec.settled_by  IS NULL THEN
     x_complete_rec.settled_by := l_claim_rec.settled_by;
  END IF;
  IF p_claim_rec.effective_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.effective_date := NULL;
  END IF;
  IF p_claim_rec.effective_date  IS NULL THEN
     x_complete_rec.effective_date := l_claim_rec.effective_date;
  END IF;
  IF p_claim_rec.custom_setup_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.custom_setup_id := NULL;
  END IF;
  IF p_claim_rec.custom_setup_id IS NULL THEN
     x_complete_rec.custom_setup_id := l_claim_rec.custom_setup_id;
  END IF;
  IF p_claim_rec.task_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_id := NULL;
  END IF;
  IF p_claim_rec.task_id  IS NULL THEN
     x_complete_rec.task_id := l_claim_rec.task_id;
  END IF;
  IF p_claim_rec.country_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.country_id := NULL;
  END IF;
  IF p_claim_rec.country_id IS NULL THEN
     x_complete_rec.country_id := l_claim_rec.country_id;
  END IF;
  IF p_claim_rec.order_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.order_type_id := NULL;
  END IF;
  IF p_claim_rec.order_type_id IS NULL THEN
     x_complete_rec.order_type_id := l_claim_rec.order_type_id;
  END IF;
  IF p_claim_rec.comments  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.comments := NULL;
  END IF;
  IF p_claim_rec.comments  IS NULL THEN
     x_complete_rec.comments := l_claim_rec.comments;
  END IF;
  IF p_claim_rec.attribute_category  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute_category := NULL;
  END IF;
  IF p_claim_rec.attribute_category  IS NULL THEN
     x_complete_rec.attribute_category := l_claim_rec.attribute_category;
  END IF;
  IF p_claim_rec.attribute1  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute1 := NULL;
  END IF;
  IF p_claim_rec.attribute1  IS NULL THEN
     x_complete_rec.attribute1 := l_claim_rec.attribute1;
  END IF;
  IF p_claim_rec.attribute2  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute2 := NULL;
  END IF;
  IF p_claim_rec.attribute2  IS NULL THEN
     x_complete_rec.attribute2 := l_claim_rec.attribute2;
  END IF;
  IF p_claim_rec.attribute3  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute3 := NULL;
  END IF;
  IF p_claim_rec.attribute3  IS NULL THEN
     x_complete_rec.attribute3 := l_claim_rec.attribute3;
  END IF;
  IF p_claim_rec.attribute4  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute4 := NULL;
  END IF;
  IF p_claim_rec.attribute4  IS NULL THEN
     x_complete_rec.attribute4 := l_claim_rec.attribute4;
  END IF;
  IF p_claim_rec.attribute5  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute5 := NULL;
  END IF;
  IF p_claim_rec.attribute5  IS NULL THEN
     x_complete_rec.attribute5 := l_claim_rec.attribute5;
  END IF;
  IF p_claim_rec.attribute6  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute6 := NULL;
  END IF;
  IF p_claim_rec.attribute6  IS NULL THEN
     x_complete_rec.attribute6 := l_claim_rec.attribute6;
  END IF;
  IF p_claim_rec.attribute7  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute7 := NULL;
  END IF;
  IF p_claim_rec.attribute7  IS NULL THEN
     x_complete_rec.attribute7 := l_claim_rec.attribute7;
  END IF;
  IF p_claim_rec.attribute8  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute8 := NULL;
  END IF;
  IF p_claim_rec.attribute8  IS NULL THEN
     x_complete_rec.attribute8 := l_claim_rec.attribute8;
  END IF;
  IF p_claim_rec.attribute9  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute9 := NULL;
  END IF;
  IF p_claim_rec.attribute9  IS NULL THEN
     x_complete_rec.attribute9 := l_claim_rec.attribute9;
  END IF;
  IF p_claim_rec.attribute10  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute10 := NULL;
  END IF;
  IF p_claim_rec.attribute10  IS NULL THEN
     x_complete_rec.attribute10 := l_claim_rec.attribute10;
  END IF;
  IF p_claim_rec.attribute11  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute11 := NULL;
  END IF;
  IF p_claim_rec.attribute11  IS NULL THEN
     x_complete_rec.attribute11 := l_claim_rec.attribute11;
  END IF;
  IF p_claim_rec.attribute12  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute12 := NULL;
  END IF;
  IF p_claim_rec.attribute12  IS NULL THEN
     x_complete_rec.attribute12 := l_claim_rec.attribute12;
  END IF;
  IF p_claim_rec.attribute13  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute13 := NULL;
  END IF;
  IF p_claim_rec.attribute13  IS NULL THEN
     x_complete_rec.attribute13 := l_claim_rec.attribute13;
  END IF;
  IF p_claim_rec.attribute14  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute14 := NULL;
  END IF;
  IF p_claim_rec.attribute14  IS NULL THEN
     x_complete_rec.attribute14 := l_claim_rec.attribute14;
  END IF;
  IF p_claim_rec.attribute15  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute15 := NULL;
  END IF;
  IF p_claim_rec.attribute15  IS NULL THEN
     x_complete_rec.attribute15 := l_claim_rec.attribute15;
  END IF;
  IF p_claim_rec.deduction_attribute_category  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute_category := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute_category  IS NULL THEN
     x_complete_rec.deduction_attribute_category := l_claim_rec.deduction_attribute_category;
  END IF;
  IF p_claim_rec.deduction_attribute1  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute1 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute1  IS NULL THEN
     x_complete_rec.deduction_attribute1 := l_claim_rec.deduction_attribute1;
  END IF;
  IF p_claim_rec.deduction_attribute2  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute2 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute2  IS NULL THEN
     x_complete_rec.deduction_attribute2 := l_claim_rec.deduction_attribute2;
  END IF;
  IF p_claim_rec.deduction_attribute3  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute3 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute3  IS NULL THEN
     x_complete_rec.deduction_attribute3 := l_claim_rec.deduction_attribute3;
  END IF;
  IF p_claim_rec.deduction_attribute4  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute4 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute4  IS NULL THEN
     x_complete_rec.deduction_attribute4 := l_claim_rec.deduction_attribute4;
  END IF;
  IF p_claim_rec.deduction_attribute5  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute5 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute5  IS NULL THEN
     x_complete_rec.deduction_attribute5 := l_claim_rec.deduction_attribute5;
  END IF;
  IF p_claim_rec.attribute6  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute6 := NULL;
  END IF;
  IF p_claim_rec.attribute6  IS NULL THEN
     x_complete_rec.deduction_attribute6 := l_claim_rec.deduction_attribute6;
  END IF;
  IF p_claim_rec.deduction_attribute7  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute7 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute7  IS NULL THEN
     x_complete_rec.deduction_attribute7 := l_claim_rec.deduction_attribute7;
  END IF;
  IF p_claim_rec.deduction_attribute8  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute8 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute8  IS NULL THEN
     x_complete_rec.deduction_attribute8 := l_claim_rec.deduction_attribute8;
  END IF;
  IF p_claim_rec.deduction_attribute9  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute9 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute9  IS NULL THEN
     x_complete_rec.deduction_attribute9 := l_claim_rec.deduction_attribute9;
  END IF;
  IF p_claim_rec.deduction_attribute10  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute10 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute10  IS NULL THEN
     x_complete_rec.deduction_attribute10 := l_claim_rec.deduction_attribute10;
  END IF;
  IF p_claim_rec.deduction_attribute11  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute11 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute11  IS NULL THEN
     x_complete_rec.deduction_attribute11 := l_claim_rec.deduction_attribute11;
  END IF;
  IF p_claim_rec.deduction_attribute12  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute12 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute12  IS NULL THEN
     x_complete_rec.deduction_attribute12 := l_claim_rec.deduction_attribute12;
  END IF;
  IF p_claim_rec.deduction_attribute13  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute13 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute13  IS NULL THEN
     x_complete_rec.deduction_attribute13 := l_claim_rec.deduction_attribute13;
  END IF;
  IF p_claim_rec.deduction_attribute14  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute14 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute14  IS NULL THEN
     x_complete_rec.deduction_attribute14 := l_claim_rec.deduction_attribute14;
  END IF;
  IF p_claim_rec.deduction_attribute15  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute15 := NULL;
  END IF;
  IF p_claim_rec.deduction_attribute15  IS NULL THEN
     x_complete_rec.deduction_attribute15 := l_claim_rec.deduction_attribute15;
  END IF;
  IF p_claim_rec.org_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.org_id := NULL;
  END IF;
  IF p_claim_rec.org_id  IS NULL THEN
     x_complete_rec.org_id := l_claim_rec.org_id;
  END IF;
  --  Added by Kishore
  IF p_claim_rec.legal_entity_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.legal_entity_id := NULL;
  END IF;
  IF p_claim_rec.legal_entity_id  IS NULL THEN
     x_complete_rec.legal_entity_id := l_claim_rec.legal_entity_id;
  END IF;
 --Auto Write-off changes (Added by Uday Poluri)
  IF p_claim_rec.write_off_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.write_off_flag := NULL;
  END IF;
  IF p_claim_rec.write_off_flag  IS NULL  THEN
     x_complete_rec.write_off_flag := l_claim_rec.write_off_flag;
  END IF;

  IF p_claim_rec.write_off_threshold_amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.write_off_threshold_amount := NULL;
  END IF;
  IF p_claim_rec.write_off_threshold_amount  IS NULL  THEN
     x_complete_rec.write_off_threshold_amount := l_claim_rec.write_off_threshold_amount;
  END IF;

  IF p_claim_rec.under_write_off_threshold  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.under_write_off_threshold := NULL;
  END IF;
  IF p_claim_rec.under_write_off_threshold  IS NULL  THEN
     x_complete_rec.under_write_off_threshold := l_claim_rec.under_write_off_threshold;
  END IF;

  IF p_claim_rec.customer_reason  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.customer_reason := NULL;
  END IF;
  IF p_claim_rec.customer_reason  IS NULL  THEN
     x_complete_rec.customer_reason := l_claim_rec.customer_reason;
  END IF;

  IF p_claim_rec.ship_to_cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.ship_to_cust_account_id       := NULL;
  END IF;
  IF p_claim_rec.ship_to_cust_account_id  IS NULL  THEN
     x_complete_rec.ship_to_cust_account_id       := l_claim_rec.ship_to_cust_account_id;
  END IF;
  --End of Auto Write-off changes (Added by Uday Poluri)

  -- Start Bug:2781186 (Subsequent Receipt Application changes)
  IF p_claim_rec.amount_applied  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_applied := NULL;
  END IF;
  IF p_claim_rec.amount_applied  IS NULL  THEN
     x_complete_rec.amount_applied := l_claim_rec.amount_applied;
  END IF;

  IF p_claim_rec.applied_receipt_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.applied_receipt_id := NULL;
  END IF;
  IF p_claim_rec.applied_receipt_id  IS NULL  THEN
     x_complete_rec.applied_receipt_id := l_claim_rec.applied_receipt_id;
  END IF;

  IF p_claim_rec.applied_receipt_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.applied_receipt_number := NULL;
  END IF;
  IF p_claim_rec.applied_receipt_number  IS NULL  THEN
     x_complete_rec.applied_receipt_number := l_claim_rec.applied_receipt_number;
  END IF;
  -- End Bug:2781186
  IF p_claim_rec.wo_rec_trx_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.wo_rec_trx_id := NULL;
  END IF;
  IF p_claim_rec.wo_rec_trx_id  IS NULL  THEN
     x_complete_rec.wo_rec_trx_id := l_claim_rec.wo_rec_trx_id;
  END IF;


  IF p_claim_rec.group_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.group_claim_id := NULL;
  END IF;
  IF p_claim_rec.group_claim_id  IS NULL  THEN
     x_complete_rec.group_claim_id := l_claim_rec.group_claim_id;
  END IF;
  IF p_claim_rec.appr_wf_item_key  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.appr_wf_item_key := NULL;
  END IF;
  IF p_claim_rec.appr_wf_item_key  IS NULL  THEN
     x_complete_rec.appr_wf_item_key := l_claim_rec.appr_wf_item_key;
  END IF;
  IF p_claim_rec.cstl_wf_item_key  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.cstl_wf_item_key := NULL;
  END IF;
  IF p_claim_rec.cstl_wf_item_key  IS NULL  THEN
     x_complete_rec.cstl_wf_item_key := l_claim_rec.cstl_wf_item_key;
  END IF;
  IF p_claim_rec.batch_type  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.batch_type := NULL;
  END IF;
  IF p_claim_rec.batch_type  IS NULL  THEN
     x_complete_rec.batch_type := l_claim_rec.batch_type;
  END IF;

  IF p_claim_rec.created_from  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.created_from := NULL;
  END IF;
  IF p_claim_rec.created_from  IS NULL  THEN
     x_complete_rec.created_from := l_claim_rec.created_from;
  END IF;

   IF p_claim_rec.program_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.program_id := NULL;
  END IF;
  IF p_claim_rec.program_id  IS NULL  THEN
     x_complete_rec.program_id := l_claim_rec.program_id;
  END IF;

  IF p_claim_rec.program_update_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.program_update_date       := NULL;
  END IF;
  IF p_claim_rec.program_update_date         IS NULL THEN
     x_complete_rec.program_update_date       := l_claim_rec.program_update_date;
  END IF;

   IF p_claim_rec.program_application_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.program_application_id := NULL;
  END IF;
  IF p_claim_rec.program_application_id  IS NULL  THEN
     x_complete_rec.program_application_id := l_claim_rec.program_application_id;
  END IF;

   IF p_claim_rec.request_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.request_id := NULL;
  END IF;
  IF p_claim_rec.request_id  IS NULL  THEN
     x_complete_rec.request_id := l_claim_rec.request_id;
  END IF;
 -- For Rule Based Settlement
  IF p_claim_rec.pre_auth_deduction_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.pre_auth_deduction_number := NULL;
  END IF;
  IF p_claim_rec.pre_auth_deduction_number  IS NULL  THEN
     x_complete_rec.pre_auth_deduction_number := l_claim_rec.pre_auth_deduction_number;
  END IF;

  IF p_claim_rec.pre_auth_deduction_normalized  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.pre_auth_deduction_normalized := NULL;
  END IF;
  IF p_claim_rec.pre_auth_deduction_normalized  IS NULL  THEN
     x_complete_rec.pre_auth_deduction_normalized := l_claim_rec.pre_auth_deduction_normalized;
  END IF;

  IF p_claim_rec.offer_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.offer_id := NULL;
  END IF;
  IF p_claim_rec.offer_id  IS NULL  THEN
     x_complete_rec.offer_id := l_claim_rec.offer_id;
  END IF;

  IF p_claim_rec.settled_from  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.settled_from := NULL;
  END IF;
  IF p_claim_rec.settled_from  IS NULL  THEN
     x_complete_rec.settled_from := l_claim_rec.settled_from;
  END IF;

  IF p_claim_rec.approval_in_prog  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.approval_in_prog := NULL;
  END IF;
  IF p_claim_rec.approval_in_prog  IS NULL  THEN
     x_complete_rec.approval_in_prog := l_claim_rec.approval_in_prog;
  END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_COMPLETE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Complete_Claim_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim
--
-- PURPOSE
--    Create a claim
--
-- PARAMETERS
--
--    x_claim_id  : return the claim_id of the new claim record
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If claim_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If claim_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--    7. The program assumes that the cust_account_id and
--       cust_billto_acct_site_id that passed in the program are valid
---------------------------------------------------------------------
PROCEDURE  Create_Claim (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim                  IN    claim_rec_type
   ,x_claim_id               OUT NOCOPY   NUMBER
)
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Create_Claim';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id            number;
l_user_id                number;
l_login_user_id          number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);
l_object_version_number  number := 1;
l_claim                  claim_rec_type := p_claim;
l_complete_claim         claim_rec_type;
l_claim_id               number;
l_cust_number            varchar2(80);

l_customer_ref_norm      varchar2(30);
--Added For Rule Based Settlement
l_pad_ref_norm      varchar2(30);

l_acc_amount             number;
l_rate                   number;
l_object_type            varchar2(30) := G_CLAIM_OBJECT_TYPE;
l_custom_setup_id        number;

--l_mc_transaction_rec     OZF_mc_transactions_PVT.mc_transactions_rec_type;
--l_mc_transaction_id      NUMBER;

l_claim_number           varchar2(30);
l_gl_date                date;
l_gl_date_type           varchar2(30);
l_days_due       number;
l_sales_rep_id           number;
l_customer_name          varchar2(250);
l_broker_id              number;
l_contact_id             number;
l_user_status_id         number;
l_status_code            varchar2(30);
l_org_id                 number;
l_sob_id                 number;
l_functional_currency_code varchar2(15);

l_return_status          varchar2(30);
l_msg_data               varchar2(2000);
l_msg_count              number;

l_claim_reason_code_id         number;   --Bug:2732290  (Added by Uday Poluri)
l_reason_code_id               number;   --Bug:2732290
l_short_payment_reason_code_id number;   --Bug:2732290
l_need_to_create        varchar2(1) := 'N';
l_claim_history_id      number;
l_clam_def_rec_type     ozf_claim_def_rule_pvt.clam_def_rec_type;
l_default_owner                NUMBER;   -- [BUG 3835800 Fixing]

CURSOR custom_setup_id_csr(p_claim_class in varchar2) IS
SELECT custom_setup_id
FROM ams_custom_setups_vl
WHERE object_type = G_CLAIM_OBJECT_TYPE
AND  activity_type_code = p_claim_class;

-- fix for bug 5042046
CURSOR sob_csr IS
SELECT set_of_books_id
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR sys_parameters_csr IS
SELECT gl_date_type
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR exchange_rate_type_csr IS
SELECT exchange_rate_type
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR default_owner_id_csr IS
SELECT default_owner_id
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR auto_assign_flag_csr IS
SELECT auto_assign_flag
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

l_auto_assign_flag varchar2(1);

CURSOR claim_id_csr IS
SELECT ozf_claims_all_s.nextval FROM dual;

CURSOR trade_profile_csr(p_customer_account_id in number) IS
SELECT vendor_id, vendor_site_id
FROM   ozf_cust_trd_prfls
WHERE  cust_account_id = p_customer_account_id;

l_trade_profile trade_profile_csr%ROWTYPE;

-- This cursor get the account_name of a cust_acc. We might not need it.
CURSOR cust_account_name_csr(p_customer_account_id in number) IS
SELECT account_name
FROM   hz_cust_accounts
WHERE  cust_account_id = p_customer_account_id;

/* CURSOR org_id_csr IS  -- R12 Enhancements
SELECT (TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10)))
FROM   dual; */

CURSOR claim_number_count_csr(p_claim_number in varchar2) IS
SELECT count(claim_number)
FROM   ozf_claims_all
WHERE  upper(claim_number) = p_claim_number;
l_temp_claim_number varchar2(30);

l_count number:=0;

CURSOR claim_id_count_csr(p_id in number) is
select count(*)
from ozf_claims
where claim_id =p_id;

l_claim_id_count number:=0;

l_access_list gp_access_list_type;
-- [BEGIN OF BUG 3835800 Fixing]
l_access_comp_list gp_access_list_type;
l_dup_resource     BOOLEAN := FALSE;
-- [END OF BUG 3835800 Fixing]
l_access_id number;
l_last_index  number;

l_errbuf       VARCHAR2(3000);
l_retcode      VARCHAR2(30);

CURSOR default_action_id_csr (p_id in number) is
select t.task_template_group_id
from ozf_reasons r,
jtf_task_temp_groups_vl t
where t.source_object_type_code = 'OZF_CLAM'
and r.active_flag = 'T'
and r.default_flag = 'T'
and t.task_template_group_id = r.task_template_group_id
and nvl(t.start_date_active, sysdate) <= sysdate
and nvl(t.end_date_active, sysdate) >= sysdate
and r.reason_code_id = p_id;


l_default_action_id number;

-- Added For Rule Based Settlement
CURSOR csr_offer_id(p_offer_code in varchar2) is
SELECT qp_list_header_id
FROM ozf_offers
WHERE offer_code = p_offer_code;

-- Added For Bug 8924230
CURSOR csr_offer_id_ignoreCase(p_offer_code in varchar2) is
SELECT qp_list_header_id
FROM ozf_offers
WHERE UPPER(offer_code) = UPPER(p_offer_code)
AND ROWNUM = 1
ORDER BY creation_date;

CURSOR csr_claim_line(cv_claim_line_id IN NUMBER) IS
SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
       , acctd_amount
FROM ozf_claim_lines_all
WHERE claim_line_id = cv_claim_line_id;

l_attribute VARCHAR2(30);
L_ATTRIBUTE_PAD  CONSTANT VARCHAR2(30) := 'OZF_RBS_RECEIPTS_PAD_ATTIBUTE';
l_claim_line_rec      OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_claim_line_id       NUMBER;
l_funds_util_flt      OZF_Claim_Accrual_PVT.funds_util_flt_type;

--Fix for ER#9453443
l_vendor_id      NUMBER;
l_vendor_site_id NUMBER;
l_payment_method VARCHAR2(30);


BEGIN

    -- Standard begin of API savepoint
    SAVEPOINT  Create_Claim_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Default claim_class
    IF (l_claim.claim_class is null OR
        l_claim.claim_class = FND_API.G_MISS_CHAR) THEN
       if l_claim.amount >0 then
          l_claim.claim_class := G_CLAIM_CLASS;
       else
          l_claim.claim_class := G_CHARGE_CLASS;
        end if;
    ELSE
       /* check claim class value */
       IF l_claim.claim_class <> G_CLAIM_CLASS AND
          l_claim.claim_class <> G_DEDUCTION_CLASS AND
               l_claim.claim_class <> G_OVERPAYMENT_CLASS AND
          l_claim.claim_class <> G_CHARGE_CLASS AND
          l_claim.claim_class <> G_GROUP_CLASS
      THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CLAIM_CLASS_WRG');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF l_claim.cust_account_id is NULL OR
              l_claim.cust_account_id = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CUST_ID_MISSING');
           FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Call Get Customer Reason to get the reason code
    --if the customer reason is not null.
    IF (l_claim.reason_code_id is NULL
       OR l_claim.reason_code_id = FND_API.G_MISS_NUM)
       AND (l_claim.customer_reason is NOT NULL
       AND l_claim.customer_reason <> FND_API.G_MISS_CHAR)
    THEN
      Get_Customer_Reason(p_cust_account_id => l_claim.cust_account_id,
                          px_reason_code_id => l_claim.reason_code_id,
                          p_customer_reason => l_claim.customer_reason,
                          x_return_status  => l_return_status);

      --in case of ded/opm don't raise the error in case if we fail to
      --retrieve the reason code. Instead default it from the Claim Defaults.
      IF  l_claim.claim_class <> G_DEDUCTION_CLASS AND
               l_claim.claim_class <> G_OVERPAYMENT_CLASS
      THEN
         IF l_return_status = FND_API.g_ret_sts_error
         THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
    END IF;
    --end of get_customer_reason if block.


    -- Call Claim defaults to default the reason code, Claim type and custom setup.
    -- set the default values only incase user has not specified any of these values.
    OZF_CLAIM_DEF_RULE_PVT.get_clam_def_rule (
                  p_claim_rec               => l_claim,
                  x_clam_def_rec_type       => l_clam_def_rec_type,
                  x_return_status           => l_return_status,
                  x_msg_count               => l_msg_count,
                  x_msg_data                => l_msg_data);

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Default custom setup Id
   IF l_claim.custom_setup_id IS NULL
   OR l_claim.custom_setup_id = FND_API.G_MISS_NUM
   THEN
      l_claim.custom_setup_id := l_clam_def_rec_type.custom_setup_id;
   END IF;

   IF l_claim.custom_setup_id is NULL OR
      l_claim.custom_setup_id = FND_API.G_MISS_NUM
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CUST_SETUP_MISSING');
         FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
 END IF;


   --Default Claim type Id.
   IF l_claim.claim_type_id IS NULL
   OR l_claim.claim_type_id = FND_API.G_MISS_NUM
   THEN
      l_claim.claim_type_id := l_clam_def_rec_type.claim_type_id;
   END IF;

    IF l_claim.claim_type_id is NULL OR
         l_claim.claim_type_id = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CLAIM_TYPE_MISSING');
           FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


   --Default reason code
   IF (l_claim.reason_code_id IS NULL
      OR l_claim.reason_code_id = FND_API.G_MISS_NUM)
   THEN
      l_claim.reason_code_id := l_clam_def_rec_type.reason_code_id;
   END IF;


    -- End Bug: 2732290 -----------------------------------------------------------
    IF l_claim.reason_code_id is NULL
    THEN
     IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_REASON_CD_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   --End of defalting values from Claim defaults.


    IF (l_claim.amount is NULL OR
       l_claim.amount = FND_API.G_MISS_NUM OR
       l_claim.amount = 0) AND
       l_claim.claim_class <>'GROUP' THEN

    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT','l_claim.amount='||l_claim.amount);
       FND_MSG_PUB.Add;
    END IF;

        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_AMOUNT_MISSING');
           FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Now we will default some values for this claim record
    --
    -- get org_id
    /* OPEN org_id_csr;
    FETCH org_id_csr INTO l_org_id;
    IF org_id_csr%NOTFOUND THEN
       CLOSE org_id_csr;
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('OZF', 'OZF_CLAIM_ORG_ID_MISSING');
          fnd_msg_pub.add;
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE org_id_csr;
    l_claim.org_id := l_org_id;  */

    -- If org_id is null, then needs to get current_org_id.
     IF (l_claim.org_id IS NULL ) THEN
         l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
         l_claim.org_id  := l_org_id;
     ELSE
         l_org_id := l_claim.org_id;
     END IF;

    -- If legal_entity_id is null, then needs to get from profile.
    IF (l_claim.legal_entity_id IS NULL) THEN
      l_claim.legal_entity_id  := FND_PROFILE.VALUE('OZF_DEFAULT_LE_FOR_CLAIM');
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('legal_entity_id:'||l_claim.legal_entity_id);
    END IF;

    -- BUG 4600325 is fixed.
    IF l_claim.legal_entity_id is NULL OR
            l_claim.legal_entity_id = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_LE_FOR_CLAIM_MISSING');
           FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get sob
    OPEN sob_csr;
    FETCH sob_csr INTO l_sob_id;
    CLOSE sob_csr;
    l_claim.set_of_books_id := l_sob_id;



    -- Default claim_number if it's null
    IF ((l_claim.claim_number is null) OR
        (l_claim.claim_number = FND_API.G_MISS_CHAR))THEN

       Get_Claim_Number(
          p_split_from_claim_id => l_claim.split_from_claim_id,
          p_custom_setup_id => l_claim.custom_setup_id,
          x_claim_number => l_claim_number,
          x_msg_data     => l_msg_data,
          x_msg_count    => l_msg_count,
          x_return_status=> l_return_status
       );
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_claim.claim_number := l_claim_number;
    ELSE
       l_temp_claim_number := Upper(l_claim.claim_number);
       OPEN claim_number_count_csr(l_temp_claim_number);
       FETCH claim_number_count_csr INTO l_count;
       CLOSE claim_number_count_csr;

       IF l_count > 0 THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUP_CLAIM_NUM');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    -- Default CLAIM_DATE if it's null
    IF (l_claim.claim_date is null OR
        l_claim.claim_date = FND_API.G_MISS_DATE)THEN
       l_claim.claim_date := TRUNC(sysdate);
    END IF;

    -- get customer info from trade profile
    OPEN trade_profile_csr(l_claim.cust_account_id);
    IF trade_profile_csr%NOTFOUND THEN
       l_trade_profile.vendor_id := null;
       l_trade_profile.vendor_site_id := null;
       CLOSE trade_profile_csr;
    ELSE
       FETCH trade_profile_csr into l_trade_profile;
       CLOSE trade_profile_csr;
    END IF;

    -- Default vendor info
    IF l_claim.vendor_id is null OR
       l_claim.vendor_id = FND_API.G_MISS_NUM THEN
       l_claim.vendor_id := l_trade_profile.vendor_id;

       IF l_claim.vendor_site_id is null OR
          l_claim.vendor_site_id = FND_API.G_MISS_NUM THEN
          l_claim.vendor_site_id := l_trade_profile.vendor_site_id;
       END IF;
    END IF;

    -- Default DUE_DATE if it's null
    IF (l_claim.DUE_DATE is null OR
        l_claim.due_date = FND_API.G_MISS_DATE) THEN

       get_days_due (p_cust_accout_id => l_claim.cust_account_id,
                     x_days_due       => l_days_due,
                     x_return_status  => l_return_status);
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.DUE_DATE := TRUNC(l_claim.claim_date + l_days_due);
    END IF;

    -- Default user_status_id if it's null
    IF (l_claim.user_status_id is null OR
        l_claim.user_status_id = FND_API.G_MISS_NUM) THEN

       -- Commented for Rule Based Settlement
       /*IF (l_claim.offer_id IS NOT NULL AND l_claim.claim_class = 'CLAIM') THEN
                l_claim.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                          P_STATUS_TYPE=> G_CLAIM_STATUS,
                                          P_STATUS_CODE=> 'OPEN'
                                      )
                                    );

       ELSE
       */
       l_claim.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                          P_STATUS_TYPE=> G_CLAIM_STATUS,
                                          P_STATUS_CODE=> G_INIT_STATUS
                                          )
                                          );
       --END IF;
     END IF;

    -- Default action id i.e. task_template_group_id if possible
      l_claim.TASK_TEMPLATE_GROUP_ID := get_action_id(l_claim.reason_code_id);

    -- Default status_code according to user_status_id if it's null
    IF (l_claim.status_code is null OR
        l_claim.status_code = FND_API.G_MISS_CHAR) THEN
        Get_System_Status( p_user_status_id => l_claim.user_status_id,
                      p_status_type    => G_CLAIM_STATUS,
                      x_system_status  => l_status_code,
                      x_msg_data       => l_msg_data,
                      x_msg_count      => l_msg_count,
                      x_return_status  => l_return_status
       );
       l_claim.status_code := l_status_code;
    END IF;

    IF l_claim.status_code = G_OPEN_STATUS THEN
       l_claim.open_status_id := l_claim.user_status_id;
    END IF;
    -----------------* Deal with customer information *---------------------------
    get_customer_info (p_claim => l_claim,
                       x_claim => l_complete_claim,
                       x_return_status  => l_return_status);
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_claim := l_complete_claim;

    -- Default broker if it's null
--    IF (l_claim.BROKER_ID is null OR
--        l_claim.broker_id = FND_API.G_MISS_NUM)THEN
--       OPEN broker_id_csr(l_claim.cust_account_id);
--       FETCH broker_id_csr INTO l_broker_id;
--       CLOSE broker_id_csr;
--       l_claim.broker_id := l_broker_id;
--    END IF;
    -----------------* End of customer information *---------------------------

    -- if owner is specified, I will add it to the access list.
    -- else I will check if the auto assign flag is turned on.
    --      If it is then call the get owner routine.
    --      If there is still no owner after this. get the owner from sys parameter and add it to access list

    IF (l_claim.owner_id is not null AND
        l_claim.owner_id <> FND_API.G_MISS_NUM) THEN

        l_access_list(1).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
        l_access_list(1).user_or_role_id := l_claim.owner_id;
        l_access_list(1).arc_user_or_role_type := 'USER';
        l_access_list(1).admin_flag := 'Y';
        l_access_list(1).owner_flag := 'Y';
        l_access_list(1).act_access_to_object_id := l_claim_id;
    ELSE

      -- Default owner_id if Auto assign is turned on

      OPEN auto_assign_flag_csr;
      FETCH auto_assign_flag_csr INTO l_auto_assign_flag;
      CLOSE auto_assign_flag_csr;

      IF l_auto_assign_flag = 'T' THEN

         get_owner (p_claim_type_id   => l_claim.claim_type_id,
                  p_claim_id        => l_claim.claim_id,
                  p_reason_code_id  => l_claim.reason_code_id,
                  p_vendor_id       => l_claim.vendor_id,
                  p_vendor_site_id  => l_claim.vendor_site_id,
                  p_cust_account_id => l_claim.cust_account_id,
                  p_billto_site_id  => l_claim.cust_billto_acct_site_id,
                  p_shipto_site_id  => l_claim.cust_shipto_acct_site_id,
                  p_claim_class     => l_claim.claim_class,
                  x_owner_id        => l_default_owner, --l_claim.owner_id, [BUG 3835800 Fixing]
                  x_access_list     => l_access_list,
                  x_return_status   => l_return_status);
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         l_claim.owner_id := l_default_owner; -- [BUG 3835800 Fixing]
      END IF;
      IF (l_claim.owner_id is null OR
          l_claim.owner_id = FND_API.G_MISS_NUM) THEN
          OPEN default_owner_id_csr;
          FETCH default_owner_id_csr into l_claim.owner_id;
          CLOSE default_owner_id_csr;

          -- Now we need to add the owner to the access list
          IF l_access_list.count = 0 THEN
             l_last_index :=1;
          ELSE
             l_last_index := l_access_list.LAST +1;
          END IF;
          l_access_list(l_last_index).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
          l_access_list(l_last_index).user_or_role_id := l_claim.owner_id;
          l_access_list(l_last_index).arc_user_or_role_type := 'USER';
          l_access_list(l_last_index).admin_flag := 'Y';
          l_access_list(l_last_index).owner_flag := 'Y';
          l_access_list(l_last_index).act_access_to_object_id := l_claim_id;
      END IF;
    END IF;

  -- R12 Enhancements
  -- Add creator for to access list

    IF l_access_list.count = 0 THEN
        l_last_index :=1;
    ELSE
        l_last_index := l_access_list.LAST +1;
    END IF;

    IF  l_claim.created_from = 'MASS_CREATE' THEN
        l_access_list(l_last_index).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
        l_access_list(l_last_index).user_or_role_id := OZF_UTILITY_PVT.get_resource_id(FND_GLOBAL.user_id) ;
        l_access_list(l_last_index).arc_user_or_role_type := 'USER';
        l_access_list(l_last_index).admin_flag := 'Y';
        l_access_list(l_last_index).owner_flag := 'N';
        l_access_list(l_last_index).act_access_to_object_id := l_claim_id;

    END IF;

    --Calculate amounts
    l_claim.amount_adjusted := 0;
    l_claim.amount_settled := 0;
    l_claim.acctd_amount_adjusted := 0;
    l_claim.acctd_amount_settled := 0;

    IF (l_claim.amount is NULL OR
        l_claim.amount = FND_API.G_MISS_NUM) THEN
       l_claim.amount := 0;
    END IF;
    l_claim.amount_remaining := l_claim.amount;

    -- get functional currency code
    OPEN  gp_func_currency_cd_csr;
    FETCH gp_func_currency_cd_csr INTO l_functional_currency_code;
    CLOSE gp_func_currency_cd_csr;

    -- Default the transaction currency code to functional currency code
    -- if it's null.
    IF (l_claim.currency_code is NULL OR
        l_claim.currency_code = FND_API.G_MISS_CHAR)THEN
       l_claim.currency_code := l_functional_currency_code;
    END IF;

    -- ER#9382547 - ChRM-SLA Uptake
    -- If the functional and claim currency is same we need to populate the
    -- the exchange rate informations along with the date. This will be used for
    -- SLA pogram to calculate the accounting appropriately.
    IF l_claim.currency_code = l_functional_currency_code THEN
       l_claim.exchange_rate :=1;
    END IF;

       IF  l_claim.exchange_rate_type is null OR
           l_claim.exchange_rate_type = FND_API.G_MISS_CHAR THEN
           OPEN exchange_rate_type_csr;
           FETCH exchange_rate_type_csr into l_claim.exchange_rate_type;
           CLOSE exchange_rate_type_csr;

           IF  l_claim.exchange_rate_type is null OR
               l_claim.exchange_rate_type = FND_API.G_MISS_CHAR THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_CLAIM_CONTYPE_MISSING');
                  fnd_msg_pub.add;
               END IF;
               RAISE fnd_api.g_exc_error;
           END IF;
       END IF;


       IF l_claim.exchange_rate_date is null OR
          l_claim.exchange_rate_date = FND_API.G_MISS_DATE THEN

          -- Default exchange_rate_date to sysdate
          l_claim.exchange_rate_date := SYSDATE;
       END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('rate_type:'||l_claim.exchange_rate_type);
    END IF;

    IF (l_claim.amount <> 0 )THEN
       OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim.set_of_books_id,
           P_FROM_CURRENCY   => l_claim.currency_code,
           P_CONVERSION_DATE => l_claim.exchange_rate_date,
           P_CONVERSION_TYPE => l_claim.exchange_rate_type,
           P_CONVERSION_RATE => l_claim.exchange_rate,
           P_AMOUNT          => l_claim.amount,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_acc_amount,
           X_RATE            => l_rate);
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
       l_claim.exchange_rate := l_rate;
       l_claim.ACCTD_AMOUNT := l_acc_amount;
       l_claim.ACCTD_AMOUNT_REMAINING := l_acc_amount;
    ELSE
       l_claim.acctd_amount :=l_claim.amount;
       l_claim.acctd_amount_remaining := l_claim.amount;
    END IF;

    -- We need to round the amount and account_amount according to the currency.
    l_claim.amount := OZF_UTILITY_PVT.CurrRound(l_claim.amount, l_claim.currency_code);
    l_claim.amount_remaining := OZF_UTILITY_PVT.CurrRound(l_claim.amount_remaining, l_claim.currency_code);
    l_claim.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount,l_functional_currency_code);
    l_claim.acctd_amount_remaining := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount_remaining, l_functional_currency_code);


    --Default the Claim_id only if the in coming claim_id is null.
    IF l_claim.claim_id is NULL
    OR l_claim.claim_id = FND_API.G_MISS_NUM
    THEN
       --fetch claim_id
       OPEN claim_id_csr;
       FETCH claim_id_csr INTO l_claim_id;
       CLOSE claim_id_csr;

       LOOP
         -- Get the identifier
         OPEN claim_id_csr;
            FETCH claim_id_csr INTO l_claim_id;
            CLOSE claim_id_csr;

            -- Check the uniqueness of the identifier
            OPEN  claim_id_count_csr(l_claim_id);
            FETCH claim_id_count_csr INTO l_claim_id_count;
            CLOSE claim_id_count_csr;
            -- Exit when the identifier uniqueness is established
            EXIT WHEN l_claim_id_count = 0;
       END LOOP;
       l_claim.claim_id := l_claim_id;
    END IF;

    --set it back to l_claim_id to ensure that it is set properly, as it is accessed at serveral places
    --down the line.
    l_claim_id := l_claim.claim_id;

    -- default root_claim_id
    IF l_claim.root_claim_id is NULL OR
       l_claim.root_claim_id = FND_API.G_MISS_NUM THEN
       l_claim.root_claim_id := l_claim_id;
    END IF;

    -- END of default

    -- normalize customer reference number if it isn't null
    IF l_claim.customer_ref_number is not NULL AND
       l_claim.customer_ref_number <> FND_API.G_MISS_CHAR THEN
       OZF_Claim_Utility_PVT.Normalize_Customer_Reference(
          p_customer_reference   => l_claim.customer_ref_number,
          x_normalized_reference => l_customer_ref_norm
       );
    END IF;

  IF (l_claim.claim_class = 'DEDUCTION') THEN

    l_attribute := FND_PROFILE.Value(L_ATTRIBUTE_PAD);

    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('l_attribute:'||l_attribute);
    END IF;

    IF l_attribute = 'ATTRIBUTE1' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE1;
    ELSIF l_attribute = 'ATTRIBUTE2' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE2;
    ELSIF l_attribute = 'ATTRIBUTE3' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE3;
    ELSIF l_attribute = 'ATTRIBUTE4' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE4;
    ELSIF l_attribute = 'ATTRIBUTE5' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE5;
    ELSIF l_attribute = 'ATTRIBUTE6' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE6;
    ELSIF l_attribute = 'ATTRIBUTE7' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE7;
    ELSIF l_attribute = 'ATTRIBUTE8' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE8;
    ELSIF l_attribute = 'ATTRIBUTE9' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE9;
    ELSIF l_attribute = 'ATTRIBUTE10' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE10;
    ELSIF l_attribute = 'ATTRIBUTE11' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE11;
    ELSIF l_attribute = 'ATTRIBUTE12' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE12;
    ELSIF l_attribute = 'ATTRIBUTE13' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE13;
    ELSIF l_attribute = 'ATTRIBUTE14' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE14;
    ELSIF l_attribute = 'ATTRIBUTE15' THEN
       l_claim.pre_auth_deduction_number := l_claim.DEDUCTION_ATTRIBUTE15;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('l_claim.pre_auth_deduction_number:'||l_claim.pre_auth_deduction_number);
    END IF;

  END IF;


    -- Added for Rule Based Settlement
    IF l_claim.pre_auth_deduction_number is not NULL AND
       l_claim.pre_auth_deduction_number <> FND_API.G_MISS_CHAR THEN
       -- Removed the Normalization logic for PAD - Bug 8924230
       /*OZF_Claim_Utility_PVT.Normalize_Customer_Reference(
          p_customer_reference   => l_claim.pre_auth_deduction_number,
          x_normalized_reference => l_pad_ref_norm
       );
       */
     l_pad_ref_norm := l_claim.pre_auth_deduction_number;
    END IF;

    -- Populate the offer_id value for Deductions only
    IF (l_pad_ref_norm IS NOT NULL AND l_claim.claim_class = 'DEDUCTION') THEN
        OPEN csr_offer_id (l_pad_ref_norm);
        FETCH csr_offer_id INTO l_claim.offer_id;
         IF OZF_DEBUG_HIGH_ON THEN
               ozf_utility_PVT.debug_message('Case Sensitive: l_claim.offer_id:'||l_claim.offer_id);
        END IF;
        CLOSE csr_offer_id;

        -- Check for case insensitive - Bug 8924230
        IF (l_claim.offer_id IS NULL) THEN
          OPEN csr_offer_id_ignoreCase (l_pad_ref_norm);
          FETCH csr_offer_id_ignoreCase INTO l_claim.offer_id;
          CLOSE csr_offer_id_ignoreCase;
           IF OZF_DEBUG_HIGH_ON THEN
               ozf_utility_PVT.debug_message('Case Insensitive: l_claim.offer_id:'||l_claim.offer_id);
        END IF;
        END IF;
    END IF;

    -- Added For ER#9453443
    IF(l_claim.offer_id IS NOT NULL) THEN

       l_claim.status_code := 'OPEN';
       l_claim.USER_STATUS_ID   := to_number(
                                              ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                              P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                              P_STATUS_CODE=> 'OPEN'
                                           ));

    END IF;


    -- Validate Claim
    Validate_Claim (
       p_api_version       => l_api_version,
       p_init_msg_list     => p_init_msg_list,
       p_validation_level  => p_validation_level,
       x_return_status     => l_return_status,
       x_msg_count         => l_msg_count,
       x_msg_data          => l_msg_data,
       p_claim             => l_claim
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

-- -------------------------------------------------------------------------------------------
    -- Bug        : 2781186
    -- Changed by : (Uday Poluri)  Date: 03-JUN-2003
    -- Comments   : In case of creatiion of cliam pass receipt info to applied receipt info
    -- -------------------------------------------------------------------------------------------
    --l_claim.AMOUNT_APPLIED         := l_claim.AMOUNT; --This needs to come from AR.
    l_claim.APPLIED_RECEIPT_ID     := l_claim.RECEIPT_ID;
    l_claim.APPLIED_RECEIPT_NUMBER := l_claim.RECEIPT_NUMBER;

    -- End Bug:2781186 ---------------------------------------------------------------------------
    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('Before Insert : l_claim.offer_id:'||l_claim.offer_id);
    END IF;

    BEGIN
       OZF_claims_PKG.Insert_Row(
          px_CLAIM_ID => l_claim_id,
          px_OBJECT_VERSION_NUMBER => l_object_version_number,
          p_LAST_UPDATE_DATE => SYSDATE,
          p_LAST_UPDATED_BY => NVL(FND_GLOBAL.user_id,-1),
          p_CREATION_DATE => SYSDATE,
          p_CREATED_BY => NVL(FND_GLOBAL.user_id,-1),
          p_LAST_UPDATE_LOGIN => NVL(FND_GLOBAL.conc_login_id,-1),
          p_REQUEST_ID => FND_GLOBAL.CONC_REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => FND_GLOBAL.PROG_APPL_ID,
          p_PROGRAM_UPDATE_DATE => SYSDATE,
          p_PROGRAM_ID => FND_GLOBAL.CONC_PROGRAM_ID,
          p_CREATED_FROM => l_claim.CREATED_FROM,
          p_BATCH_ID => l_claim.BATCH_ID,
          p_CLAIM_NUMBER => l_claim.CLAIM_NUMBER,
          p_CLAIM_TYPE_ID => l_claim.CLAIM_TYPE_ID,
          p_CLAIM_CLASS  => l_claim.CLAIM_CLASS,
          p_CLAIM_DATE => trunc(l_claim.CLAIM_DATE), -- Added for Bug 7693000
          p_DUE_DATE => trunc(l_claim.DUE_DATE), -- Added for Bug 7693000
          p_OWNER_ID   => l_claim.owner_id,
          p_HISTORY_EVENT => G_NEW_EVENT,
          p_HISTORY_EVENT_DATE => sysdate,
          p_HISTORY_EVENT_DESCRIPTION => G_CREATION_EVENT_DESC,
          p_SPLIT_FROM_CLAIM_ID => l_claim.SPLIT_FROM_CLAIM_ID,
          p_duplicate_claim_id  => l_claim.duplicate_claim_id,
          p_SPLIT_DATE => l_claim.SPLIT_DATE,
          p_ROOT_CLAIM_ID  => l_claim.ROOT_CLAIM_ID,
          p_AMOUNT => l_claim.AMOUNT,
          p_AMOUNT_ADJUSTED => l_claim.AMOUNT_ADJUSTED,
          p_AMOUNT_REMAINING => l_claim.AMOUNT_REMAINING,
          p_AMOUNT_SETTLED => l_claim.AMOUNT_SETTLED,
          p_ACCTD_AMOUNT => l_claim.ACCTD_AMOUNT,
          p_acctd_amount_remaining  => l_claim.acctd_amount_remaining,
          p_acctd_AMOUNT_ADJUSTED => l_claim.acctd_AMOUNT_ADJUSTED,
          p_acctd_AMOUNT_SETTLED => l_claim.acctd_AMOUNT_SETTLED,
          p_tax_amount  => l_claim.tax_amount,
          p_tax_code  => l_claim.tax_code,
          p_tax_calculation_flag  => l_claim.tax_calculation_flag,
          p_CURRENCY_CODE => l_claim.CURRENCY_CODE,
          p_EXCHANGE_RATE_TYPE => l_claim.EXCHANGE_RATE_TYPE,
          p_EXCHANGE_RATE_DATE => l_claim.EXCHANGE_RATE_DATE,
          p_EXCHANGE_RATE => l_claim.EXCHANGE_RATE,
          p_SET_OF_BOOKS_ID => l_claim.SET_OF_BOOKS_ID,
          p_ORIGINAL_CLAIM_DATE => l_claim.ORIGINAL_CLAIM_DATE,
          p_SOURCE_OBJECT_ID => l_claim.SOURCE_OBJECT_ID,
          p_SOURCE_OBJECT_CLASS => l_claim.SOURCE_OBJECT_CLASS,
          p_SOURCE_OBJECT_TYPE_ID => l_claim.SOURCE_OBJECT_TYPE_ID,
          p_SOURCE_OBJECT_NUMBER => l_claim.SOURCE_OBJECT_NUMBER,
          p_CUST_ACCOUNT_ID => l_claim.CUST_ACCOUNT_ID,
          p_CUST_BILLTO_ACCT_SITE_ID => l_claim.CUST_BILLTO_ACCT_SITE_ID,
          P_CUST_SHIPTO_ACCT_SITE_ID  => L_CLAIM.CUST_SHIPTO_ACCT_SITE_ID,
          p_LOCATION_ID => l_claim.LOCATION_ID,
          p_PAY_RELATED_ACCOUNT_FLAG  => l_claim.PAY_RELATED_ACCOUNT_FLAG,
          p_RELATED_CUST_ACCOUNT_ID  => l_claim.related_cust_account_id,
          p_RELATED_SITE_USE_ID  => l_claim.RELATED_SITE_USE_ID,
          p_RELATIONSHIP_TYPE  => l_claim.RELATIONSHIP_TYPE,
          p_VENDOR_ID  => l_claim.VENDOR_ID,
          p_VENDOR_SITE_ID  => l_claim.VENDOR_SITE_ID,
          p_REASON_TYPE => l_claim.REASON_TYPE,
          p_REASON_CODE_ID => l_claim.REASON_CODE_ID,
          p_TASK_TEMPLATE_GROUP_ID  => l_claim.TASK_TEMPLATE_GROUP_ID,
          p_STATUS_CODE => l_claim.STATUS_CODE,
          p_USER_STATUS_ID => l_claim.USER_STATUS_ID,
          p_SALES_REP_ID => l_claim.SALES_REP_ID,
          p_COLLECTOR_ID => l_claim.COLLECTOR_ID,
          p_CONTACT_ID => l_claim.CONTACT_ID,
          p_BROKER_ID => l_claim.BROKER_ID,
          p_TERRITORY_ID => l_claim.TERRITORY_ID,
          p_CUSTOMER_REF_DATE => l_claim.CUSTOMER_REF_DATE,
          p_CUSTOMER_REF_NUMBER => l_claim.CUSTOMER_REF_NUMBER,
          p_CUSTOMER_REF_NORMALIZED => l_customer_ref_norm,
          p_ASSIGNED_TO => l_claim.ASSIGNED_TO,
          p_RECEIPT_ID => l_claim.RECEIPT_ID,
          p_RECEIPT_NUMBER => l_claim.RECEIPT_NUMBER,
          p_DOC_SEQUENCE_ID => l_claim.DOC_SEQUENCE_ID,
          p_DOC_SEQUENCE_VALUE => l_claim.DOC_SEQUENCE_VALUE,
          p_GL_DATE    => trunc(l_claim.gl_date), -- Added for Bug 7693000
          p_PAYMENT_METHOD => l_claim.PAYMENT_METHOD,
          p_VOUCHER_ID => l_claim.VOUCHER_ID,
          p_VOUCHER_NUMBER => l_claim.VOUCHER_NUMBER,
          p_PAYMENT_REFERENCE_ID => l_claim.PAYMENT_REFERENCE_ID,
          p_PAYMENT_REFERENCE_NUMBER => l_claim.PAYMENT_REFERENCE_NUMBER,
          p_PAYMENT_REFERENCE_DATE => l_claim.PAYMENT_REFERENCE_DATE,
          p_PAYMENT_STATUS => l_claim.PAYMENT_STATUS,
          p_APPROVED_FLAG => l_claim.APPROVED_FLAG,
          p_APPROVED_DATE => l_claim.APPROVED_DATE,
          p_APPROVED_BY => l_claim.APPROVED_BY,
          p_SETTLED_DATE => l_claim.SETTLED_DATE,
          p_SETTLED_BY => l_claim.SETTLED_BY,
          p_effective_date  => l_claim.effective_date,
          p_CUSTOM_SETUP_ID  => l_claim.CUSTOM_SETUP_ID,
          p_TASK_ID  => l_claim.TASK_ID,
          p_COUNTRY_ID  => l_claim.COUNTRY_ID,
          p_ORDER_TYPE_ID  => l_claim.ORDER_TYPE_ID,
          p_COMMENTS   => l_claim.COMMENTS,
          p_ATTRIBUTE_CATEGORY => l_claim.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1 => l_claim.ATTRIBUTE1,
          p_ATTRIBUTE2 => l_claim.ATTRIBUTE2,
          p_ATTRIBUTE3 => l_claim.ATTRIBUTE3,
          p_ATTRIBUTE4 => l_claim.ATTRIBUTE4,
          p_ATTRIBUTE5 => l_claim.ATTRIBUTE5,
          p_ATTRIBUTE6 => l_claim.ATTRIBUTE6,
          p_ATTRIBUTE7 => l_claim.ATTRIBUTE7,
          p_ATTRIBUTE8 => l_claim.ATTRIBUTE8,
          p_ATTRIBUTE9 => l_claim.ATTRIBUTE9,
          p_ATTRIBUTE10 => l_claim.ATTRIBUTE10,
          p_ATTRIBUTE11 => l_claim.ATTRIBUTE11,
          p_ATTRIBUTE12 => l_claim.ATTRIBUTE12,
          p_ATTRIBUTE13 => l_claim.ATTRIBUTE13,
          p_ATTRIBUTE14 => l_claim.ATTRIBUTE14,
          p_ATTRIBUTE15 => l_claim.ATTRIBUTE15,
          p_DEDUCTION_ATTRIBUTE_CATEGORY  => l_claim.DEDUCTION_ATTRIBUTE_CATEGORY,
          p_DEDUCTION_ATTRIBUTE1  => l_claim.DEDUCTION_ATTRIBUTE1,
          p_DEDUCTION_ATTRIBUTE2  => l_claim.DEDUCTION_ATTRIBUTE2,
          p_DEDUCTION_ATTRIBUTE3  => l_claim.DEDUCTION_ATTRIBUTE3,
          p_DEDUCTION_ATTRIBUTE4  => l_claim.DEDUCTION_ATTRIBUTE4,
          p_DEDUCTION_ATTRIBUTE5  => l_claim.DEDUCTION_ATTRIBUTE5,
          p_DEDUCTION_ATTRIBUTE6  => l_claim.DEDUCTION_ATTRIBUTE6,
          p_DEDUCTION_ATTRIBUTE7  => l_claim.DEDUCTION_ATTRIBUTE7,
          p_DEDUCTION_ATTRIBUTE8  => l_claim.DEDUCTION_ATTRIBUTE8,
          p_DEDUCTION_ATTRIBUTE9  => l_claim.DEDUCTION_ATTRIBUTE9,
          p_DEDUCTION_ATTRIBUTE10  => l_claim.DEDUCTION_ATTRIBUTE10,
          p_DEDUCTION_ATTRIBUTE11  => l_claim.DEDUCTION_ATTRIBUTE11,
          p_DEDUCTION_ATTRIBUTE12  => l_claim.DEDUCTION_ATTRIBUTE12,
          p_DEDUCTION_ATTRIBUTE13  => l_claim.DEDUCTION_ATTRIBUTE13,
          p_DEDUCTION_ATTRIBUTE14  => l_claim.DEDUCTION_ATTRIBUTE14,
          p_DEDUCTION_ATTRIBUTE15  => l_claim.DEDUCTION_ATTRIBUTE15,
          px_ORG_ID =>  l_org_id,
          p_LEGAL_ENTITY_ID   => l_claim.legal_entity_id,
          p_WRITE_OFF_FLAG =>  l_claim.WRITE_OFF_FLAG,
          p_WRITE_OFF_THRESHOLD_AMOUNT =>  l_claim.WRITE_OFF_THRESHOLD_AMOUNT,
          p_UNDER_WRITE_OFF_THRESHOLD =>  l_claim.UNDER_WRITE_OFF_THRESHOLD,
          p_CUSTOMER_REASON =>  l_claim.CUSTOMER_REASON,
          p_SHIP_TO_CUST_ACCOUNT_ID => l_claim.SHIP_TO_CUST_ACCOUNT_ID,
          p_AMOUNT_APPLIED             => l_claim.AMOUNT_APPLIED,              --BUG:2781186
          p_APPLIED_RECEIPT_ID         => l_claim.APPLIED_RECEIPT_ID,          --BUG:2781186
          p_APPLIED_RECEIPT_NUMBER     => l_claim.APPLIED_RECEIPT_NUMBER,       --BUG:2781186
          p_WO_REC_TRX_ID              => l_claim.WO_REC_TRX_ID,                --Write-off Activity
          p_GROUP_CLAIM_ID             => l_claim.GROUP_CLAIM_ID,
          p_APPR_WF_ITEM_KEY           => l_claim.APPR_WF_ITEM_KEY,
          p_CSTL_WF_ITEM_KEY           => l_claim.CSTL_WF_ITEM_KEY,
          p_BATCH_TYPE                 => l_claim.BATCH_TYPE,
          p_OPEN_STATUS_ID             => l_claim.open_status_id,
          p_close_status_id            => l_claim.close_status_id,
          -- For Rule Based Settlement
          p_pre_auth_ded_number  =>  l_claim.pre_auth_deduction_number,
          p_pre_auth_ded_normalized => l_pad_ref_norm,
          p_offer_id => l_claim.offer_id,
          p_settled_from => l_claim.settled_from,
          p_approval_in_prog => l_claim.approval_in_prog
       );
    EXCEPTION
       WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
    END;

    --  Create Tasks for the claim created if task_template_group_id is not null
    IF (l_claim.task_template_group_id is not NULL AND
        l_claim.task_template_group_id <> FND_API.G_MISS_NUM ) THEN

        generate_tasks(
          p_task_template_group_id => l_claim.task_template_group_id
         ,p_owner_id       => l_claim.owner_id
         ,p_claim_number   => l_claim.claim_number
         ,p_claim_id       => l_claim_id
         ,x_return_status  => l_return_status
        );

       IF OZF_DEBUG_LOW_ON THEN
          FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
          FND_MESSAGE.Set_Token('TEXT','After generate_task: '|| l_return_status);
          FND_MSG_PUB.Add;
       END IF;
    END IF;

    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- This loop should always run
    IF l_access_list.count > 0 THEN
       -- [BEGIN OF BUG 3835800 Fiing]
       l_access_comp_list := l_access_list;
       For i in 1..l_access_list.LAST LOOP
         IF i > 1 THEN
            FOR j IN 1..(i-1) LOOP
               IF l_access_list(i).user_or_role_id = l_access_comp_list(j).user_or_role_id THEN
                  l_dup_resource := TRUE;
               END IF;
            END LOOP;
         END IF;

         IF NOT l_dup_resource THEN
         -- [END OF BUG 3835800 Fiing]
           l_access_list(i).act_access_to_object_id := l_claim_id;
           ams_access_pvt.create_access(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_validation_level => p_validation_level
              ,x_return_status => l_return_status
              ,x_msg_count => x_msg_count
              ,x_msg_data => x_msg_data
              ,p_commit => fnd_api.g_false
              ,p_access_rec => l_access_list(i)
              ,x_access_id => l_access_id);
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;
         END IF; -- end of l_dup_resource checking BUG 3835800 Fixing
      END LOOP;
    END IF;

    -- pass claim id
    x_claim_id := l_claim_id;

    --create history call (uday)
    Create_Claim_History (
           p_api_version    => l_api_version
          ,p_init_msg_list  => FND_API.G_FALSE
          ,p_commit         => FND_API.G_FALSE
          ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status  => l_return_status
          ,x_msg_data       => l_msg_data
          ,x_msg_count      => l_msg_count
          ,p_claim          => l_claim
          ,p_event          => G_NEW_EVENT
          ,x_need_to_create => l_need_to_create
          ,x_claim_history_id => l_claim_history_id
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
    --end of history call (uday)

   --------------------------
   -- Raise Business Event --
   --------------------------
   OZF_CLAIM_SETTLEMENT_PVT.Raise_Business_Event(
       p_api_version            => l_api_version
      ,p_init_msg_list          => FND_API.g_false
      ,p_commit                 => FND_API.g_false
      ,p_validation_level       => FND_API.g_valid_level_full
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count

      ,p_claim_id               => l_claim_id
      ,p_old_status             => NULL
      ,p_new_status             => l_claim.status_code
      ,p_event_name             => 'oracle.apps.ozf.claim.create'
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('After Insert : l_claim.offer_id:'||l_claim.offer_id);
       ozf_utility_PVT.debug_message('After Insert : l_claim.claim_class:'||l_claim.claim_class);
    END IF;

   -- Added For Rule Based Enhancement
   --Fix for ER#9453443
   IF (l_claim.offer_id IS NOT NULL AND l_claim.claim_class = 'CLAIM') THEN


     IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('Create Caim Line And Association');
       ozf_utility_PVT.debug_message('Before Asso API l_claim.claim_id :' || l_claim.claim_id);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.offer_id :' || l_claim.offer_id);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.amount :' || l_claim.amount);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.acctd_amount :' || l_claim.acctd_amount);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.payment_method :' || l_claim.payment_method);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.claim_class :' || l_claim.claim_class);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.cust_account_id :' || l_claim.cust_account_id);
       ozf_utility_PVT.debug_message('Before Asso API l_claim.cust_billto_acct_site_id :' || l_claim.cust_billto_acct_site_id);
     END IF;
      -- API to create claim line and Association
      Create_Claim_Association(
            p_api_version         => 1.0
           ,p_init_msg_list       => FND_API.g_false
           ,p_commit              => FND_API.g_false
           ,p_validation_level    => FND_API.g_valid_level_full
           ,p_claim_id            => l_claim.claim_id
           ,p_offer_id            => l_claim.offer_id
           ,p_claim_amt           => l_claim.amount
           ,p_claim_acc_amt       => l_claim.acctd_amount
           ,x_msg_data            => l_msg_data
           ,x_msg_count           => l_msg_count
           ,x_return_status       => l_return_status
     );
       IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_unexpected_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
       END IF;

     -- Initiate the Settlement for Claim

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Return Status from Association =' || l_return_status);
     END IF;


      l_claim.object_version_number := 1.0;

        -- Get the Payment Detail
      OZF_CLAIM_ACCRUAL_PVT.Get_Payment_Detail
      (
       p_cust_account        => l_claim.cust_account_id,
       p_billto_site_use_id  => l_claim.cust_billto_acct_site_id,
       x_payment_method     => l_payment_method,
       x_vendor_id          => l_vendor_id,
       x_vendor_site_id     => l_vendor_site_id,
       x_return_status     => l_return_status
      );

      IF(l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        l_claim.payment_method        := l_payment_method;
      END IF;

      IF (l_claim.payment_method IN ('CHECK', 'EFT','WIRE','AP_DEBIT','AP_DEFAULT')) THEN
          l_claim.vendor_id := l_vendor_id;
          l_claim.vendor_site_id := l_vendor_site_id;
      ELSE
          l_claim.vendor_id := NULL;
          l_claim.vendor_site_id := NULL;
      END IF;


     IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('Payment Method =' || l_claim.payment_method );
      OZF_Utility_PVT.debug_message('Vendor ID =' || l_claim.vendor_id );
      OZF_Utility_PVT.debug_message('Vendor Site ID =' || l_claim.vendor_site_id );
     END IF;

      IF (l_claim.payment_method IS NOT NULL AND l_claim.payment_method <> FND_API.G_MISS_CHAR) THEN

      l_claim.USER_STATUS_ID   := to_number(
                                                    ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                    P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                                    P_STATUS_CODE=> 'CLOSED'
                                                ));

      OZF_claim_PVT.Update_claim(
             P_Api_Version                => l_api_version,
             P_Init_Msg_List              => FND_API.g_false,
             P_Commit                     => FND_API.g_false,
             P_Validation_Level           => FND_API.g_valid_level_full,
             X_Return_Status              => l_return_status,
             X_Msg_Count                  => x_msg_count,
             X_Msg_Data                   => x_msg_data,
             P_claim                      => l_claim,
             p_event                      => 'UPDATE',
             p_mode                       => OZF_claim_Utility_pvt.G_AUTO_MODE,
             X_Object_Version_Number      => l_object_version_number
          );
          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
       END IF; --IF (l_claim.payment_method IS NOT NULL AND l_claim.payment_method <> FND_API.G_MISS_CHAR)

   END IF; --IF (l_claim.offer_id IS NOT NULL AND l_claim.claim_class = 'CLAIM') THEN
 -- Enf of Rule Based Enhancement

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;

    --Standard call to get message count AND if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Create_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Create_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Create_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Create_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Delete_Claim
--
-- PURPOSE
--    This procedure identify the list of deletable or non deletalbe dependent object
--    for a claim.
--
-- PARAMETERS
--    p_object_id                  IN   NUMBER,
--    p_object_version_number      IN   NUMBER,
--    x_dependent_object_tbl       OUT  ozf_utility_pvt.dependent_objects_tbl_type
--
-- We will only delete claim with status of NEW.  At this stage, all dependent objects
-- are deleteable and we don't have to worry about split and duplications.
-- Also noted, we have not implemented Attachments and NOTES so far. Nor have I found
-- any API to delete these two objects. Checks on these will have to be added later.
-- So here I'm only add line and task information in the dependent objects table.

--TYPE dependent_objects_rec_type IS RECORD
-- view_name/table_name                ozf_claim_lines_b        jtf_tasks_v
-- name                  VARCHAR2(240) line_number         Task_number
--type                  VARCHAR2(30)  LINE                                              TASK
--status                VARCHAR2(30)  NEW                                               Task_status
--owner                 VARCHAR2(240) ozf_claims_v.owner_id           owner
--deletable_flag        VARCHAR2(1)   Y


---------------------------------------------------------------------
PROCEDURE Validate_Delete_Claim (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_id                  IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    x_dependent_object_tbl       OUT NOCOPY  ams_utility_pvt.dependent_objects_tbl_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
) IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Delete_Claim';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status          varchar2(1);
l_msg_data               varchar2(2000);
l_msg_count              number;

CURSOR claim_info_csr (p_id in number) IS
SELECT object_version_number, owner_id, status_code
FROM   ozf_claims_v
WHERE  claim_id = p_id;
l_object_version_number  number;
l_status_code  varchar2(30);
l_owner_id      number;

CURSOR owner_name_csr(p_id in number) is
SELECT FULL_NAME
FROM AMS_JTF_RS_EMP_V
WHERE RESOURCE_ID = p_id;
l_owner_name varchar2(2000);

CURSOR lines_info_csr(p_id in number)IS
SELECT line_number
FROM ozf_claim_lines
WHERE claim_id = p_id;

CURSOR line_count_csr(p_id in number)IS
select count(*)
from ozf_claim_lines
where claim_id = p_id;
l_line_count number :=0;

TYPE lines_info_tbl_type is table of lines_info_csr%rowType INDEX BY BINARY_INTEGER;
l_lines_info_tbl lines_info_tbl_type;

CURSOR tasks_info_csr(p_id in number) IS
-- Bug#8718804 - Start
/*
SELECT jta.task_number,
              jtst.name task_status,
              substrb(jtf_task_utl.get_owner(jta.owner_type_code, jta.owner_id),1,239) owner_name
FROM jtf_tasks_b jta,  jtf_task_statuses_tl jtst
WHERE jta.source_object_type_code = G_CLAIM_TYPE
AND   jta.source_object_id = p_id
AND   jtst.language = userenv('lang')
AND   jtst.task_status_id = jta.task_status_id;
*/
SELECT jta.task_number,
       jtst.name task_status,
       substrb(jtf_task_utl.get_owner(jta.owner_type_code, jta.owner_id),1,239) owner_name
FROM jtf_tasks_b jta,  jtf_task_statuses_tl jtst
WHERE jta.source_object_type_code = G_OBJECT_TYPE
AND   jta.source_object_id = p_id
AND   jtst.language = userenv('lang')
AND   jtst.task_status_id = jta.task_status_id;

-- Bug#8718804 - End

TYPE tasks_info_tbl_type is table of tasks_info_csr%rowType index by binary_integer;
l_tasks_info_tbl tasks_info_tbl_type;

CURSOR task_count_csr(p_id in number)IS
-- Bug#8718804 - Start
/*
select count(task_id)
from jtf_tasks_b
WHERE source_object_type_code = G_CLAIM_TYPE
AND   source_object_id = p_id;
l_task_count number :=0;
*/
select count(task_id)
from jtf_tasks_b
WHERE source_object_type_code = G_OBJECT_TYPE
AND   source_object_id = p_id;
l_task_count number :=0;

-- Bug#8718804 - End

l_index number := 1;
l_rec_num number;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Val_Delete_Claim_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN claim_info_csr(p_object_id);
    FETCH claim_info_csr INTO l_object_version_number, l_owner_id, l_status_code;
    CLOSE claim_info_csr;

    IF p_object_version_number = l_object_version_number THEN
       -- check the status of the claim. We can only delete a claim with status NEW
       IF l_status_code = G_INIT_STATUS THEN
                    -- get owner name
                         OPEN owner_name_csr(l_owner_id);
                         FETCH owner_name_csr into l_owner_name;
                         CLOSE owner_name_csr;

                         -- get claim_line_info
                         open line_count_csr(p_object_id);
                         fetch line_count_csr into l_line_count;
                         close line_count_csr;

                         IF l_line_count > 0 THEN
                            l_rec_num := 1;
                            OPEN lines_info_csr(p_object_id);
                            LOOP
                               EXIT WHEN lines_info_csr%NOTFOUND;
                               FETCH lines_info_csr INTO l_lines_info_tbl(l_rec_num);
                               l_rec_num := l_rec_num + 1;
                            END LOOP;
                            CLOSE lines_info_csr;

                            For i in 1..l_lines_info_tbl.LAST LOOP
                                    x_dependent_object_tbl(i).name:= l_lines_info_tbl(i).line_number;
                                    x_dependent_object_tbl(i).type:= ams_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', G_CLAIM_LINE_OBJECT_TYPE);
                                    x_dependent_object_tbl(i).status:= l_status_code;
                                    x_dependent_object_tbl(i).owner:= l_owner_name;
                                    x_dependent_object_tbl(i).deletable_flag:= G_YES;
                            END LOOP;
                            l_index := l_lines_info_tbl.LAST +1;
                       END IF;


                        -- get tasks info
                        l_rec_num := 1;
                        open task_count_csr(p_object_id);
                        fetch task_count_csr into l_task_count;
                         close task_count_csr;

                         IF l_task_count > 0 THEN
                            OPEN tasks_info_csr(p_object_id);
                            LOOP
                                     EXIT WHEN tasks_info_csr%NOTFOUND;
                                     FETCH tasks_info_csr INTO l_tasks_info_tbl(l_rec_num);
                                     l_rec_num := l_rec_num + 1;
                            END LOOP;
                            CLOSE tasks_info_csr;

                           For i in 1..l_tasks_info_tbl.LAST LOOP
                                    x_dependent_object_tbl(l_index).name:= l_tasks_info_tbl(i).task_number;
                                    x_dependent_object_tbl(l_index).type:= ams_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', G_TASK_OBJECT_TYPE);
                                    x_dependent_object_tbl(l_index).status:= l_tasks_info_tbl(i).task_status;
                                    x_dependent_object_tbl(l_index).owner:= l_tasks_info_tbl(i).owner_name;
                                    x_dependent_object_tbl(l_index).deletable_flag:= G_YES;
                                    l_index := l_index +1;
                            END LOOP;
                        END IF;
        ELSE
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_DEL_CLAIM');
                FND_MSG_PUB.add;
            END IF;
        END IF;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_REC_VERSION_CHANGED');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
    END IF;

     --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;

    --Standard call to get message count AND if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Val_Delete_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Val_Delete_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Val_Delete_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count AND if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
End Validate_Delete_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim
--
-- PURPOSE
--    Update a claim code.
--
-- PARAMETERS
--    p_object_id   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
-- Also noted, we have not implemented Attachments and NOTES so far. Nor have I found
-- any API to delete these two objects. Checks on these will have to be added later.
----------------------------------------------------------------------
PROCEDURE  Delete_Claim (
    p_api_version_number     IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_object_id               IN    NUMBER
   ,p_object_version_number  IN    NUMBER
        ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
        ,x_msg_data               OUT NOCOPY   VARCHAR2
)

IS
l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Claim';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status      varchar2(30);
l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);

l_return_status          varchar2(30);
l_msg_data               varchar2(2000);
l_msg_count              number;

-- Fix for 5048675
l_claim_history_id      number;
l_claim_line_hist_id      number;

CURSOR claim_info_csr (p_id in number) IS
SELECT object_version_number, status_code
FROM   ozf_claims_all
WHERE  claim_id = p_id;
l_object_version_number  number;
l_status_code        varchar2(30);

l_error_index number;
l_claim_line_tbl  OZF_Claim_Line_PVT.claim_line_tbl_type;

CURSOR claim_line_id_csr(p_id in number)is
select claim_line_id, object_version_number
from ozf_claim_lines_all
where claim_id = p_id;

l_claim_line_id number;
l_line_object_version_number number;
l_ind number :=1;

CURSOR tasks_id_csr(p_id in number) IS
-- Bug#8718804 - Start
/*
SELECT task_id, object_version_number
FROM jtf_tasks_b
WHERE source_object_type_code = G_CLAIM_TYPE
AND   source_object_id = p_id;
*/
SELECT task_id, object_version_number
FROM jtf_tasks_b
WHERE source_object_type_code = G_OBJECT_TYPE
AND   source_object_id = p_id;
-- Bug#8718804 - End

-- Fix for 5048675
CURSOR claim_history_id_csr(p_id in number) is
select claim_history_id, object_version_number
from ozf_claims_history_all
where claim_id = p_id;

CURSOR claim_line_his_id_csr(p_id in number) is
select claim_line_history_id, object_version_number
from OZF_CLAIM_LINES_HIST_ALL
where claim_id = p_id;

TYPE tasks_id_tbl_type is table of tasks_id_csr%rowType index by binary_integer;
l_tasks_id_tbl tasks_id_tbl_type;

l_rec_num number;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Delete_Claim_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN claim_info_csr(p_object_id);
    FETCH claim_info_csr INTO l_object_version_number, l_status_code;
    CLOSE claim_info_csr;

    IF p_object_version_number = l_object_version_number THEN
       -- check the status of the claim. We can only delete a claim with status NEW
       IF l_status_code = G_INIT_STATUS THEN

          l_rec_num := 1;
          OPEN tasks_id_csr(p_object_id);
          LOOP
            FETCH tasks_id_csr INTO l_tasks_id_tbl(l_rec_num);
            EXIT WHEN tasks_id_csr%NOTFOUND;
            l_rec_num := l_rec_num + 1;
          END LOOP;
          CLOSE tasks_id_csr;

          For i in 1..l_tasks_id_tbl.count LOOP
             --  Leave p_object_version_number and p_delete_future_recurrences out for delete_task
             JTF_TASKS_PUB.delete_task(
               p_api_version           => l_api_version
              ,p_object_version_number => l_tasks_id_tbl(i).object_version_number
              ,p_task_id               => l_tasks_id_tbl(i).task_id
              ,p_delete_future_recurrences => FND_API.G_TRUE
              ,x_return_status         => l_return_status
              ,x_msg_count             => l_msg_count
              ,x_msg_data              => l_msg_data
             );
             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;
          END LOOP;

          -- Fix for 5048675
           -- delete claim history and claim line history records before deleting the claim records.
          OPEN claim_history_id_csr(p_object_id);
          LOOP
            FETCH claim_history_id_csr into l_claim_history_id, l_object_version_number;
            EXIT When claim_history_id_csr%NOTFOUND;

            OZF_claims_history_PVT.Delete_claims_history(
            P_Api_Version_Number         => l_api_version
            ,P_Init_Msg_List              => FND_API.g_false
            ,P_Commit                     => FND_API.g_false
            ,p_validation_level           => FND_API.g_valid_level_full
            ,X_Return_Status              => l_return_status
            ,X_Msg_Count                  => l_msg_count
            ,X_Msg_Data                   => l_msg_data
            ,P_CLAIM_HISTORY_ID           => l_claim_history_id
            ,P_Object_Version_Number      => l_object_version_number
            );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
          END LOOP;
          CLOSE claim_history_id_csr;

          -- delete claim line history
          OPEN claim_line_his_id_csr(p_object_id);
          LOOP
            FETCH claim_line_his_id_csr into l_claim_line_hist_id, l_object_version_number;
            EXIT When claim_line_his_id_csr%NOTFOUND;

            OZF_Claim_Line_Hist_PVT.Delete_Claim_Line_Hist(
            p_api_version_number         => l_api_version
            ,p_init_msg_list              => FND_API.g_false
            ,p_commit                     => FND_API.g_false
            ,p_validation_level           => FND_API.g_valid_level_full
            ,x_return_status              => l_return_status
            ,x_msg_count                  => l_msg_count
            ,x_msg_data                   => l_msg_data
            ,p_claim_line_history_id      => l_claim_line_hist_id
            ,p_object_version_number      => l_object_version_number
            );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
          END LOOP;
          CLOSE claim_line_his_id_csr;

          -- get claim line information
          l_ind :=1;
          OPEN claim_line_id_csr(p_object_id);
            LOOP
              FETCH claim_line_id_csr into l_claim_line_id, l_line_object_version_number;
              EXIT when claim_line_id_csr%NOTFOUND;
              l_claim_line_tbl(l_ind).claim_line_id := l_claim_line_id;
              l_claim_line_tbl(l_ind).object_version_number := l_line_object_version_number;
              l_ind := l_ind +1;
            END LOOP;
          CLOSE claim_line_id_csr;

          OZF_Claim_Line_PVT.Delete_Claim_Line_Tbl(
             p_api_version       => l_api_version
            ,p_init_msg_list     => FND_API.g_false
            ,p_commit            => FND_API.g_false
            ,p_validation_level  => FND_API.g_valid_level_full
            ,x_return_status     => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data          => l_msg_data
            ,p_claim_line_tbl         => l_claim_line_tbl
            ,p_change_object_version  => FND_API.g_false
            ,x_error_index            => l_error_index
          );
          IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;

          OZF_claims_PKG.Delete_Row(p_object_id);
       ELSE
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_DEL_CLAIM');
             FND_MSG_PUB.add;
          END IF;
       END IF;

    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_REC_VERSION_CHANGED');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
    END IF;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Delete_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Delete_Claim_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Delete_Claim_PVT;
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
END Delete_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    reason_changed
--
-- PURPOSE
--    Check whether the reason code id has changed.
--
-- PARAMETERS
--    p_claim_id
--    p_task_template_group_id
--    x_changed
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE reason_changed(p_claim_id       in number,
                         p_claim_number   in varchar2,
                         p_owner_id       in number,
                         p_reason_code_id in number,
                         p_task_template_group_id in number,
                         x_changed        OUT NOCOPY boolean,
                         x_return_status  OUT NOCOPY varchar2)
IS
l_task_template_group_id number;
l_reason_code_id         number;
l_return_status varchar2(3);

CURSOR reason_csr(p_id in number) IS
SELECT reason_code_id, task_template_group_id
FROM   ozf_claims_all
WHERE  claim_id = p_id;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN reason_csr(p_claim_id);
   FETCH reason_csr into l_reason_code_id, l_task_template_group_id;
   CLOSE reason_csr;


   IF ((l_reason_code_id is not null AND
        p_reason_code_id is not null AND
        p_reason_code_id <> l_reason_code_id) OR
       (l_reason_code_id is null AND p_reason_code_id is not null) OR
       (l_reason_code_id is not null AND p_reason_code_id is null )) THEN
      x_changed := TRUE;
   ELSE
      x_changed := FALSE;
   END IF;

   IF not x_changed THEN
     IF ((l_task_template_group_id is not null AND
        p_task_template_group_id is not null AND
        p_task_template_group_id <> l_task_template_group_id) OR
       (l_task_template_group_id is null AND p_task_template_group_id is not null) OR
       (l_task_template_group_id is not null AND p_task_template_group_id is null )) THEN
      x_changed := TRUE;
     ELSE
      x_changed := FALSE;
     END IF;
   END IF;

/*   -- Here I will generate task if there is no task generated.
   IF (l_task_template_group_id is null AND (p_task_template_group_id is not null AND p_task_template_group_id <> FND_API.G_MISS_NUM)) THEN
      generate_tasks(
          p_task_template_group_id => p_task_template_group_id
         ,p_owner_id       => p_owner_id
         ,p_claim_number   => p_claim_number
         ,p_claim_id       => p_claim_id
         ,x_return_status  => l_return_status
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
   END IF;
*/
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_REASON_CHANGE_ERR');
        FND_MSG_PUB.add;
     END IF;
END reason_changed;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_History
--
-- PURPOSE
--    Create a history record of a claim.
--
-- PARAMETERS
--    p_claim   : the record with new items.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE  Create_Claim_History (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim                  IN    claim_rec_type
   ,p_event                  IN    VARCHAR2
   ,x_need_to_create         OUT NOCOPY   VARCHAR2
   ,x_claim_history_id       OUT NOCOPY   NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Claim_History';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status  varchar2(30);
l_msg_count      number;
l_msg_data       varchar2(2000);

l_history_event_description VARCHAR2(2000);
l_history_event         VARCHAR2(30);
l_needed_to_create        VARCHAR2(1) := 'N';
l_claim_history_id        NUMBER := null;
l_status_code           varchar2(30);
CURSOR user_status_id_csr(p_id in number) is
select user_status_id
from ozf_claims_all
where claim_id = p_id;

l_user_status_id number;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Create_Claim_Hist_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN user_status_id_csr (p_claim.claim_id);
         FETCH user_status_id_csr into l_user_status_id;
         CLOSe user_status_id_csr;

    Get_System_Status( p_user_status_id => l_user_status_id,
                      p_status_type    => G_CLAIM_STATUS,
                      x_system_status  => l_status_code,
                      x_msg_data       => l_msg_data,
                      x_msg_count      => l_msg_count,
                      x_return_status  => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If the status_code is not new, then I will to create_claim_history
    --Comment out the below line (uday) since we will be creating the history
    -- at the time of claim creation also.
    --IF l_status_code <> G_INIT_STATUS THEN
       OZF_claims_history_PVT.Check_Create_History(
         p_claim => p_claim,
         p_event => p_event,
         x_history_event => l_history_event,
         x_history_event_description => l_history_event_description,
         x_needed_to_create => l_needed_to_create,
         x_return_status => l_return_status
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (l_needed_to_create = 'Y') THEN
           -- CREATE history
           OZF_claims_history_PVT.Create_History(
              p_claim_id      => p_claim.claim_id,
              p_history_event => l_history_event,
              p_history_event_description => l_history_event_description,
              x_claim_history_id => l_claim_history_id,
              x_return_status => l_return_status
           );
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
       END IF;
    --END IF; (uday)
    x_need_to_create := l_needed_to_create;
    x_claim_history_id := l_claim_history_id;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Claim_Hist_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Claim_Hist_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Claim_Hist_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
--
END Create_Claim_History;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim
--
-- PURPOSE
--    Update a claim code.
--
-- PARAMETERS
--    p_claim   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE  Update_Claim (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim                  IN    claim_rec_type
   ,p_event                  IN    VARCHAR2
        ,p_mode                   IN    VARCHAR2 := OZF_claim_Utility_pvt.G_AUTO_MODE
   ,x_object_version_number  OUT NOCOPY   NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Claim';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id               number;
l_login_user_id         number;
l_login_user_status     varchar2(30);
l_Error_Msg             varchar2(2000);
l_Error_Token           varchar2(80);
l_object_version_number number(9);

l_claim                 claim_rec_type := p_claim;
l_complete_claim        claim_rec_type;
l_acc_amount            number;
l_rate                  number;

l_claim_history_id      number;

l_rec_num               number :=1;
l_need_to_create        varchar2(1) := 'N';
l_amount_changed        boolean;
l_exchange_changed      boolean;
l_pass              boolean;
l_reason_code_changed   boolean;
l_hist_obj_ver_num      number;
l_claim_lines_sum       number;
l_customer_ref_norm     varchar2(30);

l_return_status  varchar2(30);
l_msg_count      number;
l_msg_data       varchar2(2000);

l_user_sel_status_code_id   number;
l_curr_status_code          varchar2(30);
l_close_status_id  number;
l_open_status_id  number;

CURSOR claim_currency_amount_sum_csr(p_id in NUMBER) IS
select NVL(sum(claim_currency_amount), 0)
from ozf_claim_lines_all
where claim_id = p_id;

CURSOR object_version_number_csr (p_id in number) is
select object_version_number
from ozf_claims_all
where claim_id = p_id;

CURSOR tasks_csr(p_claim_id in number,
                 p_completed_flag in varchar2) IS
SELECT a.task_id, a.object_version_number
FROM jtf_tasks_vl a, jtf_task_statuses_vl b
WHERE b.completed_flag = p_completed_flag
AND   a.deleted_flag   = 'N'
AND   a.task_status_id = b.task_status_id
AND   a.source_object_type_code = G_OBJECT_TYPE
AND   a.source_object_id = p_claim_id;

TYPE  tasks_csr_Tbl_Type IS TABLE OF tasks_csr%rowtype
                               INDEX BY BINARY_INTEGER;
l_completed_tasks_tbl   tasks_csr_Tbl_Type;
l_uncompleted_tasks_tbl tasks_csr_Tbl_Type;

CURSOR claim_history_tbl_csr(p_claim_id in number) IS
SELECT claim_history_id, object_version_number
FROM ozf_claims_history_all
WHERE task_source_object_id = p_claim_id
AND   task_source_object_type_code = G_CLAIM_TYPE
AND   claim_id = p_claim_id;

TYPE  CLAIMS_HISTORY_Tbl_Type      IS TABLE OF CLAIM_HISTORY_tbl_csr%rowtype
                                                    INDEX BY BINARY_INTEGER;
l_claim_history_tbl       CLAIMS_HISTORY_Tbl_Type;

l_claim_history_rec OZF_claims_history_PVT.claims_history_Rec_Type;


-- Fix for Bug 8924230
-- Added For Rule Based Settlement
CURSOR old_info_csr (p_id in number) IS
SELECT user_status_id,
       status_code,
       reason_code_id,
       task_template_group_id,
       cust_account_id,
       owner_id,
       customer_ref_number,
       customer_ref_normalized,
       write_off_flag,
       pre_auth_deduction_number,
       offer_id
FROM ozf_claims_all
WHERE claim_id = p_id;

-- Added for Rule Based Settlement
l_old_offer_id    NUMBER;

l_old_status_code           varchar2(30);
l_prev_status_code          varchar2(30);
l_old_user_status_id        number;
l_old_reason_code_id        number;
l_old_task_template_group_id        number;
l_old_cust_acct_id          number;
l_old_owner_id              number;
l_old_customer_ref_number   varchar2(30);
l_functional_currency_code  varchar2(30);
-- Fix for Bug 8924230
l_old_pad_ref_number        varchar2(30);

--Bug#:2732290 Date:29-May-2003 added following variable.
l_old_write_off_flag      varchar2(1);

CURSOR claim_lines_csr(p_id in number)IS
SELECT *
FROM ozf_claim_lines_all
WHERE claim_id = p_id;

TYPE  Claim_Lines_Type      IS TABLE OF claim_lines_csr%rowtype
                               INDEX BY BINARY_INTEGER;
l_claim_lines             Claim_Lines_Type;
l_claim_line_tbl          OZF_Claim_Line_PVT.claim_line_tbl_type;
l_error_index             number;
l_days_due                number;

CURSOR primary_sales_rep_id_csr(p_customer_account_id in number) IS
SELECT primary_salesrep_id
FROM   HZ_CUST_ACCOUNTS
WHERE  cust_account_id = p_customer_account_id;
l_sales_rep_id  NUMBER;

CURSOR user_status_id_csr (p_id in number) IS
SELECT user_status_id
FROM ozf_claims_all
WHERE claim_id = p_id;

CURSOR status_code_csr (p_id in number) IS
SELECT status_code
FROM ozf_claims_all
WHERE claim_id = p_id;

-- fix for bug 5042046
CURSOR auto_assign_flag_csr IS
SELECT auto_assign_flag
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

l_auto_assign_flag varchar2(1);

CURSOR default_owner_id_csr IS
SELECT default_owner_id
FROM   ozf_sys_parameters
WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR resource_id_csr(p_user_id in number) is
SELECT resource_id
FROM   jtf_rs_resource_extns
WHERE  user_id = p_user_id
AND    category = 'EMPLOYEE';

l_resource_id number;

CURSOR tax_amount_csr(p_id in number) IS
SELECT tax_amount
FROM ozf_claims_all
WHERE claim_id = p_id;

l_tax_amount number;

l_access_list      gp_access_list_type;
-- [BEGIN OF BUG 3835800 Fixing]
l_access_comp_list gp_access_list_type;
l_dup_resource     BOOLEAN := FALSE;
-- [END OF BUG 3835800 Fixing]
l_access varchar2(1) := 'N';
l_access_id number;
l_access_obj_ver number;

CURSOR claim_access_csr(p_id in number) is
select activity_access_id, object_version_number
FROM ams_act_access
WHERE arc_act_access_to_object = 'CLAM'
and   act_access_to_object_id = p_id;

TYPE  claim_access_list_Type   IS TABLE OF claim_access_csr%rowtype
                               INDEX BY BINARY_INTEGER;
l_claim_access_list  claim_access_list_Type;
l_access_index number:=0;

CURSOR owner_access_csr(p_claim_id in number, p_user_id in number) is
select activity_access_id, object_version_number
FROM ams_act_access
WHERE arc_act_access_to_object = 'CLAM'
and act_access_to_object_id = p_claim_id
and user_or_role_id = p_user_id
and arc_user_or_role_type = 'USER'
and rownum =1;

l_owner_changed boolean:= false;

-- get shipto customer based on shipto site
CURSOR shipto_cust_account_id_csr(p_site_use_id in number) is
select a.cust_account_id
FROM   HZ_CUST_ACCT_SITES a
,      HZ_CUST_SITE_USES s
WHERE  a.cust_acct_site_id = s.cust_acct_site_id
and    s.site_use_id = p_site_use_id;

CURSOR csr_user_status_info(p_claim_id in number) is
SELECT open_status_id,
       close_status_id
FROM ozf_claims_all
WHERE claim_id = p_claim_id;

-- Added For Rule Based Settlement

CURSOR claim_line_count_csr(p_claim_id in number
                 ) IS
SELECT count(cln.claim_id)
FROM   ozf_claims_all cla,
       ozf_claim_lines_all cln
WHERE  cla.claim_id = cln.claim_id
AND    cla.claim_id = p_claim_id;

CURSOR csr_claim_line(cv_claim_line_id IN NUMBER) IS
SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
       , acctd_amount
FROM ozf_claim_lines_all
WHERE claim_line_id = cv_claim_line_id;

CURSOR claim_line_id_csr(p_id in number) IS
SELECT claim_line_id, object_version_number
FROM ozf_claim_lines_all
WHERE claim_id = p_id;

/*CURSOR claim_hrd_invoice_csr(cv_claim_id in number) IS
SELECT source_object_id
FROM ozf_claims_all
WHERE claim_id = cv_claim_id;
*/

CURSOR claim_invoice_csr(cv_claim_id in number) IS
SELECT count(*)
FROM ozf_claim_lines_all cln, ozf_claims_all cla
WHERE cla.claim_id = cln.claim_id
AND cla.source_object_id = cln.source_object_id
AND cla.claim_id = cv_claim_id
GROUP BY cln.source_object_id;

CURSOR csr_offer_code(p_offer_id in number) is
SELECT offer_code
FROM ozf_offers
WHERE qp_list_header_id = p_offer_id;

CURSOR csr_claim_line_offr(p_id in number) is
SELECT activity_id
FROM ozf_claim_lines_all
WHERE claim_id = p_id;

l_activity_id NUMBER;
l_ind number :=1;
l_old_claim_line_id number;
l_line_object_version_number number;
l_invoice_count number;
l_invoice_num number;

l_claim_line_count number := 0;
l_claim_line_rec      OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_claim_line_id       NUMBER;
l_funds_util_flt      OZF_Claim_Accrual_PVT.funds_util_flt_type;
l_vendor_id      NUMBER := 0;
l_vendor_site_id NUMBER := 0;
l_payment_method VARCHAR2(30);
l_invoice_del_flag NUMBER :=0;
l_invoice_crt_flag NUMBER :=0;
l_claim_offer_asso NUMBER :=0;
l_offer_code VARCHAR2(30);



--
BEGIN
    -- Standard begin of API savepoint
--    IF ( NOT G_UPDATE_CALLED ) THEN
       SAVEPOINT  Update_Claim_PVT;
--       G_UPDATE_CALLED := true;
--    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('New1: l_claim.pre_auth_deduction_number:'||l_claim.pre_auth_deduction_number);
       ozf_utility_PVT.debug_message('New1: l_claim.customer_ref_number'||l_claim.customer_ref_number);
       OZF_Utility_PVT.debug_message('New1: l_claim.offer_id'||l_claim.offer_id);
     END IF;

    -- Varify object_version_number
    IF (l_claim.object_version_number is NULL or
        l_claim.object_version_number = FND_API.G_MISS_NUM ) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN object_version_number_csr(l_claim.claim_id);
    FETCH object_version_number_csr INTO l_object_version_number;
    CLOSE object_version_number_csr;

    IF l_object_version_number <> l_claim.object_version_number THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
          FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Bug: 2732290 -----------------------------------------------------------
    IF (l_claim.customer_reason is not NULL
        AND l_claim.customer_reason <> FND_API.g_miss_char )
    THEN
       Get_Customer_Reason(p_cust_account_id => l_claim.cust_account_id,
                       px_reason_code_id => l_claim.reason_code_id,
                       p_customer_reason => l_claim.customer_reason,
                       x_return_status  => l_return_status);
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;
    -- End Bug: 2732290 -----------------------------------------------------------

    l_user_id := NVL(FND_GLOBAL.user_id,-1);
    IF (l_user_id = -1) THEN
       l_resource_id := -1;
    ELSE
       OPEN resource_id_csr(l_user_id);
       FETCH resource_id_csr into l_resource_id;
       CLOSE resource_id_csr;
    END IF;

    IF p_mode = OZF_claim_Utility_pvt.G_MANU_MODE THEN
       OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
          P_Api_Version_Number => 1.0,
          P_Init_Msg_List      => FND_API.G_FALSE,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          P_Commit             => FND_API.G_FALSE,
          P_object_id          => p_claim.claim_id,
          P_object_type        => G_CLAIM_OBJECT_TYPE,
          P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1)),
          X_Return_Status      => l_return_status,
          X_Msg_Count          => l_msg_count,
          X_Msg_Data           => l_msg_data,
          X_access             => l_access);

            IF l_access = 'N' THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_NO_ACCESS');
             FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;

    -- Now the object_version_number matches, we can increase it.
    l_object_version_number := l_claim.object_version_number + 1;

    -- Retrieve user_status_id if it is not changed.
    IF l_claim.user_status_id is null OR
       l_claim.user_status_id = FND_API.G_MISS_NUM THEN
       IF l_claim.status_code is null OR
          l_claim.status_code = FND_API.G_MISS_CHAR THEN

          OPEN user_status_id_csr(l_claim.claim_id);
          FETCH user_status_id_csr INTO l_claim.user_status_id;
          CLOSE user_status_id_csr;
       ELSE
          l_claim.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                          P_STATUS_TYPE=> G_CLAIM_STATUS,
                                          P_STATUS_CODE=> l_claim.status_code
                                     )
                                    );
    END IF;
       END IF;

    -- First, we need to update the status code. Status code is not updated
    -- from screen. In order to keep the data integerty, we need to update it first.
    -- modify status_code accordingly
    Get_System_Status( p_user_status_id => l_claim.user_status_id,
                      p_status_type    => G_CLAIM_STATUS,
                      x_system_status  => l_claim.status_code,
                      x_msg_data       => l_msg_data,
                      x_msg_count      => l_msg_count,
                      x_return_status  => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OPEN  csr_user_status_info(l_claim.claim_id);
    FETCH csr_user_status_info INTO l_open_status_id, l_close_status_id;
    CLOSE csr_user_status_info;

    --***************************************************************
    -- Start Fix for Bug 5613926

    IF l_claim.status_code = 'CLOSED' THEN
        l_claim.close_status_id := l_claim.user_status_id;
    END IF;

   /*
    IF l_claim.status_code = 'CLOSED' AND l_close_status_id IS NULL THEN
       l_claim.close_status_id := l_claim.user_status_id;
    END IF;
    */

   -- End Fix for bug 5613926
   --***************************************************************

    IF l_claim.status_code = G_OPEN_STATUS AND l_claim.user_status_id IS NOT NULL THEN
       l_claim.open_status_id := l_claim.user_status_id;
    END IF;

    l_prev_status_code := l_claim.status_code;

    -- Replace g_miss_char/num/date with current column values
    -- We can not complete the claim_rec first, since that will overwrite the new event.
    Complete_Claim_Rec(
       p_claim_rec      => l_claim,
       x_complete_rec   => l_complete_claim,
       x_return_status  => l_return_status
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_claim := l_complete_claim;

    -- check amount first, throw any error if amount for deduction is changed.
    -- round the amount first
    l_claim.amount          := OZF_UTILITY_PVT.CurrRound(l_claim.amount, l_claim.currency_code);
    l_claim.amount_adjusted := OZF_UTILITY_PVT.CurrRound(l_claim.amount_adjusted, l_claim.currency_code);
    l_claim.amount_settled  := OZF_UTILITY_PVT.CurrRound(l_claim.amount_settled, l_claim.currency_code);
    l_claim.amount_remaining  :=  OZF_UTILITY_PVT.CurrRound(l_claim.amount_remaining, l_claim.currency_code);
--    l_claim.acctd_amount    :=  OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount, l_claim.currency_code);
--    l_claim.acctd_amount_remaining :=  OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount_remaining, l_claim.currency_code);

    -- Calculate currency conversions if amount is changed
    -- Added For ER#9453443
    IF(l_claim.offer_id IS NULL ) THEN
     check_amount(
       p_claim              => l_claim,
       p_mode               => p_mode,
       x_amount_changed     => l_amount_changed,
       x_exchange_changed   => l_exchange_changed,
       x_pass               => l_pass,
       x_return_status      => l_return_status
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;
   END IF;

   /*IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('New1: l_amount_changed:'||l_amount_changed);
       ozf_utility_PVT.debug_message('New1: l_exchange_changed'||l_exchange_changed);
   END IF;
   */


    IF l_pass = false THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug: 3359914 -----------------------------------------------------------
    -- Reason is a required field when the claim is updated.
    IF l_claim.reason_code_id is null
    OR l_claim.reason_code_id =  FND_API.G_MISS_NUM
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_REASON_CD_MISSING');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Bug: 3359914 -----------------------------------------------------------


    -- check if action has changes.
    reason_changed(
       p_claim_id       => l_claim.claim_id,
       p_claim_number   => l_claim.claim_number,
       p_owner_id       => l_claim.owner_id,
       p_reason_code_id => l_claim.reason_code_id,
       p_task_template_group_id => l_claim.task_template_group_id,
       x_changed        => l_reason_code_changed,
       x_return_status  => l_return_status
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- ----------------------------------------------------------------------------
    -- Bug        : 2732290
    -- Changed by : Uday Poluri  Date: 29-May-2003
    -- Comments   : Add write_off_flag to following cursor as l_old_write_off_flag
    -- Note       : This is to avoid update of write off flag if status is not Open.
    -- ----------------------------------------------------------------------------
    -- Retrieve some information before the update
    -- Fix for Bug 8924230
    OPEN old_info_csr(l_claim.claim_id);
    FETCH old_info_csr INTO l_old_user_status_id, l_old_status_code, l_old_reason_code_id,
    l_old_task_template_group_id, l_old_cust_acct_id, l_old_owner_id, l_old_customer_ref_number,
    l_customer_ref_norm, l_old_write_off_flag, l_old_pad_ref_number, l_old_offer_id;
    CLOSE old_info_csr;

    -- If reason_codes_id has changed, I will try to reset the action to the default action according to the new reason_code
    -- Code commented for bug# - 5954318 : psomyaju/26.03.2007
    -- Bug#-5954318 : Start
    IF (l_old_reason_code_id <> l_claim.reason_code_id AND
       (--l_old_task_template_group_id = l_claim.task_template_group_id OR
        l_claim.task_template_group_id is null OR
        l_claim.task_template_group_id = fnd_api.g_miss_num))THEN
       l_claim.task_template_group_id := get_action_id(l_claim.reason_code_id);
    END IF;
     -- Bug#-5954318 : End

    -----------* Now Make sure status_code and user_status_id matches
    -- If user_status_id does not change, We need to assigned the
    -- default user_status_id.
    IF l_old_status_code <> l_claim.status_code AND
       l_old_user_status_id = l_claim.user_status_id THEN

       l_claim.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                 P_STATUS_TYPE=> G_CLAIM_STATUS,
                                 P_STATUS_CODE=> l_claim.status_code)
                                           );
    END IF;
    -----------* Done with status

    -----------* Deal with duplicate claim
    -- deal with duplicate claim
    IF l_old_status_code <> l_claim.status_code THEN
       -- if user change status to dupliate, we need to have duplicate_claim_id as inputs
       IF l_claim.status_code = G_DUPLICATE_STATUS THEN
          IF l_claim.duplicate_claim_id is null OR
             l_claim.duplicate_claim_id = FND_API.G_MISS_NUM THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUP_CLM_ID_MISSING');
                FND_MSG_PUB.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Raise an error
          -- if the duplicate_claim_id equal to the current claim_id
          IF l_claim.duplicate_claim_id = l_claim.claim_id THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_DUP_ID_SAME');
                FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       -- if user change status from duplicate, we need to set duplicate_claim_id as null
       IF l_old_status_code = G_DUPLICATE_STATUS THEN
          l_claim.duplicate_claim_id := null;
       END IF;
    END IF;
    -----------* Done with duplicated claim

    -- checking access of the claim if owner_id changes
    IF ((l_claim.owner_id is null AND l_old_owner_id is not null) OR
        (l_claim.owner_id is not null AND l_claim.owner_id <> l_old_owner_id)) THEN

        l_owner_changed := true;

        -- throw exception if user is not the owner nor does he has admin access
        --  (OZF_access_PVT.Check_Admin_Access(l_resource_id) = false)) THEN
        IF ((l_old_owner_id <> l_resource_id) AND
            (l_access <> 'F') AND
            (p_mode = OZF_claim_Utility_pvt.G_MANU_MODE) ) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_UPDT_OWNER_PERM');
              FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- delete access for the current owner
        OPEN owner_access_csr(l_claim.claim_id, l_old_owner_id);
        FETCH owner_access_csr into l_access_id, l_access_obj_ver;
        CLOSE owner_access_csr;

        AMS_ACCESS_PVT.delete_access(
             p_api_version => l_api_version
                ,p_init_msg_list => fnd_api.g_false
                ,p_validation_level => p_validation_level
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data
                ,p_commit => fnd_api.g_false
                ,p_access_id =>l_access_id
                ,p_object_version =>l_access_obj_ver
        );
        IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;


           -- Added for bug fix 4247328
         -- If the new owner is already a part of the access,
         -- the error "The specified User or User Group is already part of the Team"
         -- is displayed. To fix this issue, we need to check if the new owner is
         -- already a part of team access. If yes, we need to delete access
         -- and then create access again as the owner of the claim.
         OPEN owner_access_csr(l_claim.claim_id, l_claim.owner_id);
         FETCH owner_access_csr into l_access_id, l_access_obj_ver;
         CLOSE owner_access_csr;

         AMS_ACCESS_PVT.delete_access(
             p_api_version => l_api_version
                ,p_init_msg_list => fnd_api.g_false
                ,p_validation_level => p_validation_level
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data
                ,p_commit => fnd_api.g_false
                ,p_access_id =>l_access_id
                ,p_object_version =>l_access_obj_ver
         );
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

    END IF;

    -- Default owner_id if necessary

    IF (l_claim.owner_id is not null AND
        l_claim.owner_id <> FND_API.G_MISS_NUM) THEN

       -- Add the new owner to the access list
       l_access_list(1).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
       l_access_list(1).user_or_role_id := l_claim.owner_id;
       l_access_list(1).arc_user_or_role_type := 'USER';
       l_access_list(1).admin_flag := 'Y';
       l_access_list(1).owner_flag := 'Y';
       l_access_list(1).act_access_to_object_id := l_claim.claim_id;
    ELSE
        OPEN auto_assign_flag_csr;
        FETCH auto_assign_flag_csr INTO l_auto_assign_flag;
        CLOSE auto_assign_flag_csr;

        IF l_auto_assign_flag = 'T' THEN

           get_owner (p_claim_type_id   => l_claim.claim_type_id,
                  p_claim_id        => l_claim.claim_id,
                  p_reason_code_id  => l_claim.reason_code_id,
                  p_vendor_id       => l_claim.vendor_id,
                  p_vendor_site_id  => l_claim.vendor_site_id,
                  p_cust_account_id => l_claim.cust_account_id,
                  p_billto_site_id  => l_claim.cust_billto_acct_site_id,
                  p_shipto_site_id  => l_claim.cust_shipto_acct_site_id,
                  p_claim_class     => l_claim.claim_class,
                  x_owner_id        => l_claim.owner_id,
                  x_access_list     => l_access_list,
                  x_return_status   => l_return_status);
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

          -- Default to system parameter if can not find an owner_id
          IF (l_claim.owner_id is null OR
              l_claim.owner_id = FND_API.G_MISS_NUM) THEN

             OPEN default_owner_id_csr;
             FETCH default_owner_id_csr into l_claim.owner_id;
             CLOSE default_owner_id_csr;

             -- Now we need to add owner to the access list
             IF l_access_list.count = 0 THEN
                l_access_index :=1;
             ELSE
                l_access_index := l_access_list.LAST +1;
             END IF;
             l_access_list(l_access_index).arc_act_access_to_object := G_CLAIM_OBJECT_TYPE;
             l_access_list(l_access_index).user_or_role_id := l_claim.owner_id;
             l_access_list(l_access_index).arc_user_or_role_type := 'USER';
             l_access_list(l_access_index).admin_flag := 'Y';
             l_access_list(l_access_index).owner_flag := 'Y';
             l_access_list(l_access_index).act_access_to_object_id := l_claim.claim_id;
          END IF;

          l_access_index := 1;
          -- Now we need to delete the current access list.
           OPEN claim_access_csr(l_claim.claim_id);
           LOOP
            FETCH claim_access_csr into l_claim_access_list(l_access_index);
            exit when claim_access_csr%NOTFOUND;
            l_access_index := l_access_index +1;
          END LOOP;
          CLOSE claim_access_csr;

           IF l_claim_access_list.COUNT <>0 THEN
             FOR i in 1..l_claim_access_list.LAST LOOP
              AMS_ACCESS_PVT.delete_access(
                 p_api_version => l_api_version
                ,p_init_msg_list => fnd_api.g_false
                ,p_validation_level => p_validation_level
                ,x_return_status => l_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data
                ,p_commit => fnd_api.g_false
                ,p_access_id =>l_claim_access_list(i).activity_access_id
                ,p_object_version =>l_claim_access_list(i).object_version_number
               );
               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
              END LOOP;
           END IF;
        ELSE
           -- Should never be in this block.
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_UPDATE_OWNER_ERR');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
        END IF;
    END IF;

    -----------* Deal with currency code issues

    IF l_amount_changed THEN

       -- get functional currency code
       OPEN  gp_func_currency_cd_csr;
       FETCH gp_func_currency_cd_csr INTO l_functional_currency_code;
       IF gp_func_currency_cd_csr%NOTFOUND THEN
          CLOSE gp_func_currency_cd_csr;
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name('OZF', 'OZF_CLAIM_GL_FUNCUR_MISSING');
             fnd_msg_pub.add;
          END IF;
          RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE gp_func_currency_cd_csr;

 --      l_functional_currency_code := fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');

       -- ER#9382547 - ChRM-SLA Uptake
       -- If the functional and claim currency is same we need to populate the
       -- the exchange rate informations along with the date. This will be used for
       -- SLA pogram to calculate the accounting appropriately.

       IF l_claim.currency_code = l_functional_currency_code THEN
                l_claim.exchange_rate :=1;
       END IF;

       IF  l_claim.exchange_rate_type is null OR
              l_claim.exchange_rate_type = FND_API.G_MISS_CHAR THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                 fnd_message.set_name('OZF', 'OZF_CLAIM_CONTYPE_MISSING');
                 fnd_msg_pub.add;
              END IF;
              RAISE fnd_api.g_exc_error;
          END IF;

          IF l_claim.exchange_rate_date is null OR
             l_claim.exchange_rate_date = FND_API.G_MISS_DATE THEN

             -- Default exchange_rate_date to sysdate
             l_claim.exchange_rate_date := SYSDATE;
          END IF;


       -- Convert amount now
       OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim.set_of_books_id,
           P_FROM_CURRENCY   => l_claim.currency_code,
           P_CONVERSION_DATE => l_claim.exchange_rate_date,
           P_CONVERSION_TYPE => l_claim.exchange_rate_type,
           P_CONVERSION_RATE => l_claim.exchange_rate,
           P_AMOUNT          => l_claim.amount,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_acc_amount,
           X_RATE => l_rate
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.exchange_rate := l_rate;
       l_claim.ACCTD_AMOUNT  := l_acc_amount;

       -- We need to round the amount and account_amount according to the currency.
       l_claim.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount,l_functional_currency_code);

       -- get claim_lines_sum
       OPEN claim_currency_amount_sum_csr(l_claim.claim_id);
       FETCH claim_currency_amount_sum_csr INTO l_claim_lines_sum;
       CLOSE claim_currency_amount_sum_csr;

       IF l_claim_lines_sum is null THEN
          l_claim_lines_sum := 0;
       ELSE
       -- [BEGIN FIX 04/29/02] mchang: claim_currency_amount in claim lines is stored as claim currency code
       --                              not functional currency code.
          --l_claim_lines_sum := OZF_UTILITY_PVT.CurrRound(l_claim_lines_sum, l_functional_currency_code);
          l_claim_lines_sum := OZF_UTILITY_PVT.CurrRound(l_claim_lines_sum, l_claim.currency_code);
       -- [END FIX 04/29/02] mchang:
       END IF;

       -- if amount_adjusted = amount then change the status to cancell;
       -- This will happen if we split all the amount of a claim to its children.
       IF l_claim.amount = l_claim.amount_adjusted THEN
          l_claim.status_code    := G_CANCELLED_STATUS;
          l_claim.user_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                          P_STATUS_TYPE=> G_CLAIM_STATUS,
                                          P_STATUS_CODE=> G_CANCELLED_STATUS
                                      )
                                     );

       END IF;

       -- IF l_claim.tax_amount is not null, we need to deduct it from amount_remaining
       OPEN tax_amount_csr (l_claim.claim_id);
       FETCH tax_amount_csr into l_tax_amount;
       CLOSE tax_amount_csr;

       IF l_tax_amount is null THEN
          l_tax_amount := 0;
       END IF;

       IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('UC:STEP 0: Before amount_remaining:'||l_claim.amount_remaining);
       END IF;
       l_claim.amount_remaining := l_claim.amount - l_claim.amount_adjusted - l_claim.amount_settled- l_tax_amount;

       IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('UC:STEP 1: After amount_remaining:'||l_claim.amount_remaining);
          OZF_Utility_PVT.debug_message('UC:STEP 2: amount_adjusted:'||l_claim.amount_adjusted);
          OZF_Utility_PVT.debug_message('UC:STEP 3: amount_settled:'||l_claim.amount_settled);
          OZF_Utility_PVT.debug_message('UC:STEP 4: l_tax_amount:'||l_tax_amount);
          OZF_Utility_PVT.debug_message('UC:STEP 2: lines_sum: '||l_claim_lines_sum );
       END IF;
       -- Raise an error if amount_remaining < claim_lines_sum
       -- [BEGIN FIX 04/29/02] mchang: Add ABS function for claim and line amount checking in case of overpayment.
       -- [BEGIN FIX 05/08/02] mchang: the amount_remaining checking is not doing when claim status is from PENDING_CLOSE to CLOSED.
       -- -------------------------------------------------------------------------------------------
       -- Bug        : 2781186
       -- Changed by : (Uday Poluri)  Date: 03-Jun-2003
       -- Comments   : Add p_mode check, If it is AUTO then allow amount change on claim.
       --              (Relax this rule for Auto Mode)
       -- -------------------------------------------------------------------------------------------
       IF p_mode <> OZF_claim_Utility_pvt.G_AUTO_MODE THEN    --Bug:2781186
          IF l_claim.status_code NOT IN ('PENDING_CLOSE', 'CLOSED') AND
             ABS(l_claim.amount_remaining + l_claim.amount_settled) < ABS(l_claim_lines_sum) THEN
          -- [END FIX 04/29/02]
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AMT_REM_ERR');
                FND_MSG_PUB.add;
             END IF;
             RAISE FND_API.g_exc_error;
          END IF;
      END IF; --End of relaxation.

       -- convert amount_remaing.
       l_acc_amount := null;
       OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim.set_of_books_id,
           P_FROM_CURRENCY   => l_claim.currency_code,
           P_CONVERSION_DATE => l_claim.exchange_rate_date,
           P_CONVERSION_TYPE => l_claim.exchange_rate_type,
           P_CONVERSION_RATE => l_claim.exchange_rate,
           P_AMOUNT          => l_claim.amount_remaining,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_acc_amount,
           X_RATE            => l_rate
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.ACCTD_AMOUNT_REMAINING  := l_acc_amount;

       l_claim.amount_remaining := OZF_UTILITY_PVT.CurrRound(l_claim.amount_remaining, l_claim.currency_code);
       l_claim.acctd_amount_remaining := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount_remaining,l_functional_currency_code);

       IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('UC:AJ STEP 11: After amount_remaining:'||l_claim.amount_remaining);
       END IF;

       -- convert amount_settled.
       l_acc_amount := null;
       OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim.set_of_books_id,
           P_FROM_CURRENCY   => l_claim.currency_code,
           P_CONVERSION_DATE => l_claim.exchange_rate_date,
           P_CONVERSION_TYPE => l_claim.exchange_rate_type,
           P_CONVERSION_RATE => l_claim.exchange_rate,
           P_AMOUNT          => l_claim.amount_settled,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_acc_amount,
           X_RATE            => l_rate
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.ACCTD_amount_settled  := l_acc_amount;

       l_claim.acctd_amount_settled := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount_settled,l_functional_currency_code);

       -- convert amount_adjusted.
       l_acc_amount := null;
       OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim.set_of_books_id,
           P_FROM_CURRENCY   => l_claim.currency_code,
           P_CONVERSION_DATE => l_claim.exchange_rate_date,
           P_CONVERSION_TYPE => l_claim.exchange_rate_type,
           P_CONVERSION_RATE => l_claim.exchange_rate,
           P_AMOUNT          => l_claim.amount_adjusted,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_acc_amount,
           X_RATE            => l_rate
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.ACCTD_amount_adjusted  := l_acc_amount;

       l_claim.acctd_amount_adjusted := OZF_UTILITY_PVT.CurrRound(l_claim.acctd_amount_adjusted,l_functional_currency_code);
    END IF;

   -- If the cust_account_id has changed, we need to change the followings accordingly.
   -- Days due and others
    IF l_old_cust_acct_id <> l_claim.cust_account_id THEN
       get_days_due (p_cust_accout_id => l_claim.cust_account_id,
                     x_days_due       => l_days_due,
                     x_return_status  => l_return_status);
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
       l_claim.DUE_DATE := TRUNC(l_claim.claim_date + l_days_due);

       get_customer_info(p_claim => l_claim,
                         x_claim => l_complete_claim,
                         x_return_status  => l_return_status);
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       l_claim := l_complete_claim;
    END IF;

   -- Bug4334023: User entered only shipto site then default shipto customer
   IF l_claim.ship_to_cust_account_id IS NULL THEN
      IF (l_claim.cust_shipto_acct_site_id is not null AND
           l_claim.cust_shipto_acct_site_id <> FND_API.G_MISS_NUM) THEN
            OPEN shipto_cust_account_id_csr(l_claim.cust_shipto_acct_site_id);
            FETCH shipto_cust_account_id_csr INTO l_claim.ship_to_cust_account_id;
            CLOSE shipto_cust_account_id_csr;
      END IF;
    END IF;

    -- normalize the customer reference number if changed
    -- normalize the customer reference number if changed
    -- Fixed: uday poluri date:03-Jun-2003. following if condition is added to avoid normalize in case of null
    --        customer_ref_number.
    IF (l_claim.customer_ref_number is not null or l_claim.customer_ref_number <> FND_API.g_miss_char) then
       IF (l_old_customer_ref_number IS NULL AND l_claim.customer_ref_number IS NOT NULL) OR
          (l_old_customer_ref_number IS NOT NULL AND l_claim.customer_ref_number IS NULL) OR
          l_old_customer_ref_number <> l_claim.customer_ref_number THEN

          OZF_Claim_Utility_PVT.Normalize_Customer_Reference(
             p_customer_reference => l_claim.customer_ref_number
            ,x_normalized_reference => l_customer_ref_norm
          );
       END IF;
    END IF;

      --Fix for ER#9453443
      -- Delete the claim line if the offer is removed from claim detail page
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_claim.offer_id :' || l_claim.offer_id);
      OZF_Utility_PVT.debug_message('l_old_offer_id :' || l_old_offer_id);
      OZF_Utility_PVT.debug_message('New1: l_claim.settled_from11'||l_claim.settled_from);
   END IF;
   IF (l_claim.offer_id IS NULL AND l_old_offer_id IS NOT NULL AND l_claim.claim_class IN ('CLAIM','DEDUCTION')) THEN

      IF (l_claim.claim_class ='DEDUCTION') THEN
          l_claim.pre_auth_deduction_number := NULL;
          l_claim.pre_auth_deduction_normalized := NULL;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('Delete claim line');
      END IF;
         l_ind :=1;
          OPEN claim_line_id_csr(l_claim.claim_id);
            LOOP
              FETCH claim_line_id_csr into l_old_claim_line_id, l_line_object_version_number;
               EXIT when claim_line_id_csr%NOTFOUND;
              l_claim_line_tbl(l_ind).claim_line_id := l_old_claim_line_id;
              l_claim_line_tbl(l_ind).object_version_number := l_line_object_version_number;
              l_ind := l_ind +1;
            END LOOP;
          CLOSE claim_line_id_csr;

          IF(l_claim_line_tbl.COUNT > 0 ) THEN
            OZF_Claim_Line_PVT.Delete_Claim_Line_Tbl(
               p_api_version       => l_api_version
              ,p_init_msg_list     => FND_API.g_false
              ,p_commit            => FND_API.g_false
              ,p_validation_level  => FND_API.g_valid_level_full
              ,x_return_status     => l_return_status
              ,x_msg_count         => l_msg_count
              ,x_msg_data          => l_msg_data
              ,p_claim_line_tbl         => l_claim_line_tbl
              ,p_change_object_version  => FND_API.g_false
              ,x_error_index            => l_error_index
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF; -- End of delete claim line

      END IF;


      IF OZF_DEBUG_HIGH_ON THEN
       OZF_Utility_PVT.debug_message('l_claim.offer_id1 :' || l_claim.offer_id);
       OZF_Utility_PVT.debug_message('l_old_offer_id1 :' || l_old_offer_id);
       OZF_Utility_PVT.debug_message('New1: l_claim.settled_from22'||l_claim.settled_from);
      END IF;
      -- Added the Check for settled_from for bug fix 9814130
      IF ((l_claim.offer_id IS NOT NULL AND l_claim.offer_id <> FND_API.G_MISS_NUM)
          AND(
              (l_old_offer_id IS NULL OR l_old_offer_id = FND_API.G_MISS_NUM)
              OR
              (l_old_offer_id IS NOT NULL AND l_old_offer_id <> FND_API.G_MISS_NUM AND (l_claim.offer_id <> l_old_offer_id
              OR l_claim.claim_class = 'DEDUCTION'))
              )
           AND (l_claim.settled_from IS NULL OR l_claim.settled_from =FND_API.G_MISS_CHAR )
         ) THEN

          IF (l_claim.claim_class IN ('CLAIM', 'DEDUCTION')) THEN
              OPEN claim_line_count_csr(l_claim.claim_id);
              FETCH claim_line_count_csr INTO l_claim_line_count;
              CLOSE claim_line_count_csr;
             IF (l_claim.claim_class = 'CLAIM') THEN
                IF (l_claim_line_count <> 0)THEN
                   IF OZF_DEBUG_HIGH_ON THEN
                   OZF_Utility_PVT.debug_message('Caim Line Exists :');
                   END IF;
                 IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_LINE_EXISTS');
                     FND_MSG_PUB.Add;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
             END IF;

             IF (l_claim.claim_class = 'DEDUCTION')THEN
                IF l_claim_line_count > 0 THEN
                OPEN claim_invoice_csr(l_claim.claim_id);
                FETCH claim_invoice_csr INTO l_invoice_count;
                CLOSE claim_invoice_csr;
                IF(l_invoice_count = 1) THEN
                   IF OZF_DEBUG_HIGH_ON THEN
                   OZF_Utility_PVT.debug_message('COUNT=1');
                   END IF;
                   l_ind :=1;
                   OPEN claim_line_id_csr(l_claim.claim_id);
                   LOOP
                    FETCH claim_line_id_csr into l_old_claim_line_id, l_line_object_version_number;
                    EXIT when claim_line_id_csr%NOTFOUND;
                    l_claim_line_tbl(l_ind).claim_line_id := l_old_claim_line_id;
                    l_claim_line_tbl(l_ind).object_version_number := l_line_object_version_number;
                    l_ind := l_ind +1;
                   END LOOP;
                  CLOSE claim_line_id_csr;

                  IF(l_claim_line_tbl.COUNT > 0 ) THEN
                     OZF_Claim_Line_PVT.Delete_Claim_Line_Tbl(
                         p_api_version       => l_api_version
                        ,p_init_msg_list     => FND_API.g_false
                        ,p_commit            => FND_API.g_false
                        ,p_validation_level  => FND_API.g_valid_level_full
                        ,x_return_status     => l_return_status
                        ,x_msg_count         => l_msg_count
                        ,x_msg_data          => l_msg_data
                        ,p_claim_line_tbl         => l_claim_line_tbl
                        ,p_change_object_version  => FND_API.g_false
                        ,x_error_index            => l_error_index
                     );
                    IF l_return_status = FND_API.g_ret_sts_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                    END IF;
                  END IF; -- End of delete claim line
                ELSE
                  IF OZF_DEBUG_HIGH_ON THEN
                   OZF_Utility_PVT.debug_message('COUNT >1 And raise error');
                   END IF;
                  IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('OZF','OZF_DED_LINE_UPDATED');
                     FND_MSG_PUB.Add;
                  END IF;
                END IF; --IF(l_invoice_count = 1) THEN

                END IF; --l_claim_line_count > 0

             END IF; --IF (l_claim.claim_class IN ('CLAIM', 'DEDUCTION')) THEN
          END IF; --IF ((l_claim.offer_id IS NOT NULL AND l_claim.offer_id <> FND_API.G_MISS_NUM) ...

              IF OZF_DEBUG_HIGH_ON THEN
                 OZF_Utility_PVT.debug_message('Caim Line Does not Exists :');
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.claim_id :' || l_claim.claim_id);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.offer_id :' || l_claim.offer_id);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.amount :' || l_claim.amount);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.acctd_amount :' || l_claim.acctd_amount);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.payment_method :' || l_claim.payment_method);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.claim_class :' || l_claim.claim_class);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.cust_account_id :' || l_claim.cust_account_id);
                 OZF_Utility_PVT.debug_message('Before Asso API l_claim.cust_billto_acct_site_id :' || l_claim.cust_billto_acct_site_id);
              END IF;

             -- Added For ER#9453443
            IF(l_claim.offer_id IS NOT NULL AND G_INIT_STATUS = 'NEW') THEN

                update ozf_claims_all set status_code = 'OPEN'
                where claim_id = l_claim.claim_id;

            END IF;

              Create_Claim_Association(
                    p_api_version         => 1.0
                   ,p_init_msg_list       => FND_API.g_false
                   ,p_commit              => FND_API.g_false
                   ,p_validation_level    => FND_API.g_valid_level_full
                   ,p_claim_id            => l_claim.claim_id
                   ,p_offer_id            => l_claim.offer_id
                   ,p_claim_amt           => l_claim.amount
                   ,p_claim_acc_amt       => l_claim.acctd_amount
                   ,x_msg_data            => l_msg_data
                   ,x_msg_count           => l_msg_count
                   ,x_return_status       => l_return_status
             );


             IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_unexpected_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
             END IF;
             IF (l_claim.claim_class = 'DEDUCTION') THEN
                 OPEN csr_offer_code(l_claim.offer_id);
                 FETCH csr_offer_code INTO l_offer_code;
                 CLOSE csr_offer_code;

                  IF OZF_DEBUG_HIGH_ON THEN
                       OZF_Utility_PVT.debug_message('l_offer_code =' || l_offer_code);
                  END IF;

                  IF (l_offer_code IS NOT NULL) THEN
                       l_claim.pre_auth_deduction_number := l_offer_code;
                       l_claim.pre_auth_deduction_normalized := l_offer_code;
                  END IF;
             END IF;
          END IF; -- End of offer code comparision

          IF OZF_DEBUG_HIGH_ON THEN
             OZF_Utility_PVT.debug_message('l_return status from Claim Association  =' || l_return_status);
             OZF_Utility_PVT.debug_message('Claim Payment Method Given =' || l_claim.payment_method);
             OZF_Utility_PVT.debug_message('Claim ID =' || l_claim.claim_id);
          END IF;

          OPEN csr_claim_line_offr (l_claim.claim_id);
          FETCH csr_claim_line_offr INTO l_activity_id;
          CLOSE csr_claim_line_offr;

          IF OZF_DEBUG_HIGH_ON THEN
             OZF_Utility_PVT.debug_message('l_activity_id  =' || l_activity_id);
             OZF_Utility_PVT.debug_message('l_claim.offer_id =' || l_claim.offer_id);
             OZF_Utility_PVT.debug_message('l_claim.claim_class =' || l_claim.claim_class);
          END IF;

          -- For Deduction the payment method should be credit memo only.
          IF (l_claim.offer_id IS NOT NULL AND l_claim.offer_id <> FND_API.G_MISS_NUM
                                        AND l_claim.claim_class = 'DEDUCTION') THEN
              l_claim.payment_method := 'CREDIT_MEMO';
	      -- Fix for Bug 9706115
	      l_claim.USER_STATUS_ID   := to_number(
                                                    ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                    P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                                    P_STATUS_CODE=> 'CLOSED'
                                                ));
              l_claim.status_code := 'CLOSED';
              l_prev_status_code := l_claim.status_code;

          END IF;

         IF (l_claim.offer_id IS NOT NULL AND l_claim.offer_id <> FND_API.G_MISS_NUM
             AND l_activity_id = l_claim.offer_id AND l_claim.claim_class = 'CLAIM') THEN

          IF ((l_claim.payment_method IS NULL OR l_claim.payment_method = FND_API.G_MISS_CHAR
               OR l_claim.payment_method ='') AND l_claim.claim_class = 'CLAIM') THEN
             -- Get the Payment Detail
              IF OZF_DEBUG_HIGH_ON THEN
                OZF_Utility_PVT.debug_message('Before Payment Detail');
              END IF;

             OZF_CLAIM_ACCRUAL_PVT.Get_Payment_Detail
            (
               p_cust_account        => l_claim.cust_account_id,
               p_billto_site_use_id  => l_claim.cust_billto_acct_site_id,
               x_payment_method      => l_payment_method,
               x_vendor_id           => l_vendor_id,
               x_vendor_site_id      => l_vendor_site_id,
               x_return_status       => l_return_status
            );

           IF OZF_DEBUG_HIGH_ON THEN
             OZF_Utility_PVT.debug_message('return status from get_payment_details: ' || l_return_status);
             OZF_Utility_PVT.debug_message('l_payment_method from get_payment_detail:' || l_payment_method);
             OZF_Utility_PVT.debug_message('l_vendor_id from get_payment_details:' || l_vendor_id);
             OZF_Utility_PVT.debug_message('l_vendor_site_id from get_payment_details:' || l_vendor_site_id);
           END IF;


            IF(l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
             l_claim.payment_method        := l_payment_method;
            END IF;

            IF (l_claim.payment_method IN ('CHECK', 'EFT','WIRE','AP_DEBIT','AP_DEFAULT')) THEN
              l_claim.vendor_id := l_vendor_id;
              l_claim.vendor_site_id := l_vendor_site_id;
            ELSE
              l_claim.vendor_id := NULL;
              l_claim.vendor_site_id := NULL;
            END IF;

         END IF; -- End of Payment method check for claim

	  IF (l_claim.payment_method IS NOT NULL AND l_claim.payment_method <> FND_API.G_MISS_CHAR) THEN

              l_claim.USER_STATUS_ID   := to_number(
                                                    ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                    P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                                    P_STATUS_CODE=> 'CLOSED'
                                                ));
              l_claim.status_code := 'CLOSED';
              l_prev_status_code := l_claim.status_code;
         ELSE
              l_claim.USER_STATUS_ID   := to_number(
                                                    ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                    P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                                    P_STATUS_CODE=> 'OPEN'
                                                ));

         END IF;

        END IF; -- Check for Success association with offer


    OZF_CLAIM_SETTLEMENT_PVT.complete_settlement(
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,x_return_status    => l_return_status
      ,x_msg_data         => l_msg_data
      ,x_msg_count        => l_msg_count
      ,p_claim_rec        => l_claim
      ,x_claim_rec        => l_complete_claim
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_claim := l_complete_claim;

   -- Validate the record
    Validate_Claim (
       p_api_version       => l_api_version
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data
      ,p_claim             => l_claim
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- R12: eTax Uptake Make call to validate claim tax
   -- bugfix 4754589 added condition  l_claim.tax_action <> FND_API.G_MISS_CHAR
   IF  (l_claim.tax_action IS NOT NULL AND  l_claim.tax_action <> FND_API.G_MISS_CHAR) THEN
           OZF_CLAIM_TAX_PVT. Validate_Claim_For_Tax(
                p_api_version    => l_api_version
               ,p_init_msg_list  => FND_API.G_FALSE
               ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
               ,x_return_status    => l_return_status
               ,x_msg_data          => l_msg_data
               ,x_msg_count         => l_msg_count
               ,p_claim_rec          => l_claim) ;
           IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
           END IF;
   END IF;


    OZF_CLAIM_LINE_PVT.Update_Line_Fm_Claim(
        p_api_version    => l_api_version
       ,p_init_msg_list  => FND_API.G_FALSE
       ,p_commit         => FND_API.G_FALSE
       ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
       ,x_return_status  => l_return_status
       ,x_msg_data       => l_msg_data
       ,x_msg_count      => l_msg_count
       ,p_new_claim_rec  => l_claim
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

-- ----------------------------------------------------------------------------
    -- Bug        : 2732290
    -- Changed by : Uday Poluri  Date: 29-May-2003
    -- Comments   : if write off flag is change and status is not open then raise error.
    -- ----------------------------------------------------------------------------
    -- Varify status code if NOT OPEN then raise error.

    IF (l_old_write_off_flag <> l_claim.write_off_flag AND
       upper(l_claim.status_code) <> 'OPEN')  then
      --Initialize message list if p_init_msg_list is TRUE.
      -- mchang 12/05/2003: comment out the following message initialization code.
      --                    message stack only allow to initialize in the begining
      --                    of api, not at this point.
      /*
      IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;
      */

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('AMS', 'OZF_CLAIM_API_NO_OPEN_STATUS');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Bug: 2732290 -----------------------------------------------------------

    BEGIN
       OZF_claims_PKG.Update_Row(
          p_CLAIM_ID => l_claim.CLAIM_ID,
          p_OBJECT_VERSION_NUMBER => l_object_version_number,
          p_LAST_UPDATE_DATE => SYSDATE,
          p_LAST_UPDATED_BY => NVL(FND_GLOBAL.user_id,-1),
          p_LAST_UPDATE_LOGIN => NVL(FND_GLOBAL.conc_login_id,-1),
          p_REQUEST_ID => l_claim.request_id,
          p_PROGRAM_APPLICATION_ID => l_claim.program_application_id,
          p_PROGRAM_UPDATE_DATE => l_claim.program_update_date,
          p_PROGRAM_ID => l_claim.program_id,
          p_CREATED_FROM => l_claim.CREATED_FROM,
          p_BATCH_ID => l_claim.BATCH_ID,
          p_CLAIM_NUMBER => l_claim.CLAIM_NUMBER,
          p_CLAIM_TYPE_ID => l_claim.CLAIM_TYPE_ID,
          p_CLAIM_CLASS  => l_claim.CLAIM_CLASS,
          p_CLAIM_DATE => trunc(l_claim.CLAIM_DATE), -- Added for Bug 7693000
          p_DUE_DATE => trunc(l_claim.DUE_DATE), -- Added for Bug 7693000
          p_OWNER_ID   => l_claim.OWNER_ID,
          p_HISTORY_EVENT => l_claim.hISTORY_EVENT,
          -- For Bug#9217894 (+)
          -- p_HISTORY_EVENT_DATE => l_claim.HISTORY_EVENT_DATE,
          p_HISTORY_EVENT_DATE => SYSDATE,
          -- For Bug#9217894 (-)
          p_HISTORY_EVENT_DESCRIPTION => l_claim.HISTORY_EVENT_DESCRIPTION,
          p_SPLIT_FROM_CLAIM_ID => l_claim.SPLIT_FROM_CLAIM_ID,
          p_duplicate_claim_id  => l_claim.duplicate_claim_id,
          p_SPLIT_DATE => l_claim.SPLIT_DATE,
          p_ROOT_CLAIM_ID  => l_claim.ROOT_CLAIM_ID,
          p_AMOUNT => l_claim.AMOUNT,
          p_AMOUNT_ADJUSTED => l_claim.AMOUNT_ADJUSTED,
          p_AMOUNT_REMAINING => l_claim.AMOUNT_REMAINING,
          p_AMOUNT_SETTLED => l_claim.AMOUNT_SETTLED,
          p_ACCTD_AMOUNT => l_claim.ACCTD_AMOUNT,
          p_acctd_amount_remaining => l_claim.acctd_amount_remaining,
          p_acctd_AMOUNT_ADJUSTED => l_claim.acctd_AMOUNT_ADJUSTED,
          p_acctd_AMOUNT_SETTLED => l_claim.acctd_AMOUNT_SETTLED,
          p_tax_amount  => l_claim.tax_amount,
          p_tax_code  => l_claim.tax_code,
          p_tax_calculation_flag  => l_claim.tax_calculation_flag,
          p_CURRENCY_CODE => l_claim.CURRENCY_CODE,
          p_EXCHANGE_RATE_TYPE => l_claim.EXCHANGE_RATE_TYPE,
          p_EXCHANGE_RATE_DATE => l_claim.EXCHANGE_RATE_DATE,
          p_EXCHANGE_RATE => l_claim.EXCHANGE_RATE,
          p_SET_OF_BOOKS_ID => l_claim.SET_OF_BOOKS_ID,
          p_ORIGINAL_CLAIM_DATE => l_claim.ORIGINAL_CLAIM_DATE,
          p_SOURCE_OBJECT_ID => l_claim.SOURCE_OBJECT_ID,
          p_SOURCE_OBJECT_CLASS => l_claim.SOURCE_OBJECT_CLASS,
          p_SOURCE_OBJECT_TYPE_ID => l_claim.SOURCE_OBJECT_TYPE_ID,
          p_SOURCE_OBJECT_NUMBER => l_claim.SOURCE_OBJECT_NUMBER,
          p_CUST_ACCOUNT_ID => l_claim.CUST_ACCOUNT_ID,
          p_CUST_BILLTO_ACCT_SITE_ID => l_claim.CUST_BILLTO_ACCT_SITE_ID,
          p_cust_shipto_acct_site_id  => l_claim.cust_shipto_acct_site_id,
          p_LOCATION_ID => l_claim.LOCATION_ID,
          p_PAY_RELATED_ACCOUNT_FLAG  => l_claim.PAY_RELATED_ACCOUNT_FLAG,
          p_RELATED_CUST_ACCOUNT_ID  => l_claim.related_cust_account_id,
          p_RELATED_SITE_USE_ID  => l_claim.RELATED_SITE_USE_ID,
          p_RELATIONSHIP_TYPE  => l_claim.RELATIONSHIP_TYPE,
          p_VENDOR_ID  => l_claim.VENDOR_ID,
          p_VENDOR_SITE_ID  => l_claim.VENDOR_SITE_ID,
          p_REASON_TYPE => l_claim.REASON_TYPE,
          p_REASON_CODE_ID => l_claim.REASON_CODE_ID,
          p_TASK_TEMPLATE_GROUP_ID  => l_claim.TASK_TEMPLATE_GROUP_ID,
          p_STATUS_CODE => l_claim.STATUS_CODE,
          p_USER_STATUS_ID => l_claim.USER_STATUS_ID,
          p_SALES_REP_ID => l_claim.SALES_REP_ID,
          p_COLLECTOR_ID => l_claim.COLLECTOR_ID,
          p_CONTACT_ID => l_claim.CONTACT_ID,
          p_BROKER_ID => l_claim.BROKER_ID,
          p_TERRITORY_ID => l_claim.TERRITORY_ID,
          p_CUSTOMER_REF_DATE => l_claim.CUSTOMER_REF_DATE,
          p_CUSTOMER_REF_NUMBER => l_claim.CUSTOMER_REF_NUMBER,
          p_CUSTOMER_REF_NORMALIZED => l_customer_ref_norm,
          p_ASSIGNED_TO => l_claim.ASSIGNED_TO,
          p_RECEIPT_ID => l_claim.RECEIPT_ID,
          p_RECEIPT_NUMBER => l_claim.RECEIPT_NUMBER,
          p_DOC_SEQUENCE_ID => l_claim.DOC_SEQUENCE_ID,
          p_DOC_SEQUENCE_VALUE => l_claim.DOC_SEQUENCE_VALUE,
          p_GL_DATE    => trunc(l_claim.gl_date), -- Added for Bug 7693000
          p_PAYMENT_METHOD => l_claim.PAYMENT_METHOD,
          p_VOUCHER_ID => l_claim.VOUCHER_ID,
          p_VOUCHER_NUMBER => l_claim.VOUCHER_NUMBER,
          p_PAYMENT_REFERENCE_ID => l_claim.PAYMENT_REFERENCE_ID,
          p_PAYMENT_REFERENCE_NUMBER => l_claim.PAYMENT_REFERENCE_NUMBER,
          p_PAYMENT_REFERENCE_DATE => l_claim.PAYMENT_REFERENCE_DATE,
          p_PAYMENT_STATUS => l_claim.PAYMENT_STATUS,
          p_APPROVED_FLAG => l_claim.APPROVED_FLAG,
          p_APPROVED_DATE => l_claim.APPROVED_DATE,
          p_APPROVED_BY => l_claim.APPROVED_BY,
          p_SETTLED_DATE => l_claim.SETTLED_DATE,
          p_SETTLED_BY => l_claim.SETTLED_BY,
          p_effective_date  => l_claim.effective_date,
               p_CUSTOM_SETUP_ID  => l_claim.CUSTOM_SETUP_ID,
          p_TASK_ID  => l_claim.TASK_ID,
          p_COUNTRY_ID  => l_claim.COUNTRY_ID,
          p_ORDER_TYPE_ID  => l_claim.ORDER_TYPE_ID,
          p_COMMENTS   => l_claim.COMMENTS,
          p_ATTRIBUTE_CATEGORY => l_claim.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1 => l_claim.ATTRIBUTE1,
          p_ATTRIBUTE2 => l_claim.ATTRIBUTE2,
          p_ATTRIBUTE3 => l_claim.ATTRIBUTE3,
          p_ATTRIBUTE4 => l_claim.ATTRIBUTE4,
          p_ATTRIBUTE5 => l_claim.ATTRIBUTE5,
          p_ATTRIBUTE6 => l_claim.ATTRIBUTE6,
          p_ATTRIBUTE7 => l_claim.ATTRIBUTE7,
          p_ATTRIBUTE8 => l_claim.ATTRIBUTE8,
          p_ATTRIBUTE9 => l_claim.ATTRIBUTE9,
          p_ATTRIBUTE10 => l_claim.ATTRIBUTE10,
          p_ATTRIBUTE11 => l_claim.ATTRIBUTE11,
          p_ATTRIBUTE12 => l_claim.ATTRIBUTE12,
          p_ATTRIBUTE13 => l_claim.ATTRIBUTE13,
          p_ATTRIBUTE14 => l_claim.ATTRIBUTE14,
          p_ATTRIBUTE15 => l_claim.ATTRIBUTE15,
          p_DEDUCTION_ATTRIBUTE_CATEGORY  => l_claim.DEDUCTION_ATTRIBUTE_CATEGORY,
          p_DEDUCTION_ATTRIBUTE1  => l_claim.DEDUCTION_ATTRIBUTE1,
          p_DEDUCTION_ATTRIBUTE2  => l_claim.DEDUCTION_ATTRIBUTE2,
          p_DEDUCTION_ATTRIBUTE3  => l_claim.DEDUCTION_ATTRIBUTE3,
          p_DEDUCTION_ATTRIBUTE4  => l_claim.DEDUCTION_ATTRIBUTE4,
          p_DEDUCTION_ATTRIBUTE5  => l_claim.DEDUCTION_ATTRIBUTE5,
          p_DEDUCTION_ATTRIBUTE6  => l_claim.DEDUCTION_ATTRIBUTE6,
          p_DEDUCTION_ATTRIBUTE7  => l_claim.DEDUCTION_ATTRIBUTE7,
          p_DEDUCTION_ATTRIBUTE8  => l_claim.DEDUCTION_ATTRIBUTE8,
          p_DEDUCTION_ATTRIBUTE9  => l_claim.DEDUCTION_ATTRIBUTE9,
          p_DEDUCTION_ATTRIBUTE10  => l_claim.DEDUCTION_ATTRIBUTE10,
          p_DEDUCTION_ATTRIBUTE11  => l_claim.DEDUCTION_ATTRIBUTE11,
          p_DEDUCTION_ATTRIBUTE12  => l_claim.DEDUCTION_ATTRIBUTE12,
          p_DEDUCTION_ATTRIBUTE13  => l_claim.DEDUCTION_ATTRIBUTE13,
          p_DEDUCTION_ATTRIBUTE14  => l_claim.DEDUCTION_ATTRIBUTE14,
          p_DEDUCTION_ATTRIBUTE15  => l_claim.DEDUCTION_ATTRIBUTE15,
          -- Bug 3313062 Fixing: ORG_ID cannot be set to null at any time.
          p_ORG_ID => l_claim.org_id,    -- R12 Enhancements
          p_LEGAL_ENTITY_ID   => l_claim.legal_entity_id,  -- R12 Enhancements
          p_WRITE_OFF_FLAG  => l_claim.WRITE_OFF_FLAG,
          p_WRITE_OFF_THRESHOLD_AMOUNT  => l_claim.WRITE_OFF_THRESHOLD_AMOUNT,
          p_UNDER_WRITE_OFF_THRESHOLD  => l_claim.UNDER_WRITE_OFF_THRESHOLD,
          p_CUSTOMER_REASON  => l_claim.CUSTOMER_REASON,
          p_SHIP_TO_CUST_ACCOUNT_ID => l_claim.SHIP_TO_CUST_ACCOUNT_ID,
          p_AMOUNT_APPLIED              => l_claim.AMOUNT_APPLIED,              --BUG:2781186
          p_APPLIED_RECEIPT_ID          => l_claim.APPLIED_RECEIPT_ID,          --BUG:2781186
          p_APPLIED_RECEIPT_NUMBER      => l_claim.APPLIED_RECEIPT_NUMBER,     --BUG:2781186
          p_WO_REC_TRX_ID               => l_claim.WO_REC_TRX_ID,               --Write-off Activity
          p_GROUP_CLAIM_ID              => l_claim.GROUP_CLAIM_ID,
          p_APPR_WF_ITEM_KEY            => l_claim.APPR_WF_ITEM_KEY,
          p_CSTL_WF_ITEM_KEY            => l_claim.CSTL_WF_ITEM_KEY,
          p_BATCH_TYPE                  => l_claim.BATCH_TYPE,
          p_close_status_id              => l_claim.close_status_id,
          p_open_status_id              => l_claim.open_status_id,
          --For Rule Based Settlement
          p_pre_auth_ded_number   => l_claim.pre_auth_deduction_number,
          p_pre_auth_ded_normalized => l_claim.pre_auth_deduction_normalized,
          p_offer_id => l_claim.offer_id,
          p_settled_from => l_claim.settled_from,
          p_approval_in_prog => l_claim.approval_in_prog
    );

    EXCEPTION
       WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
             FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
    END;
    l_rec_num := 1;

    IF l_user_sel_status_code_id IS NOT NULL THEN
       UPDATE ozf_claims_all
       SET close_status_id = l_user_sel_status_code_id
       WHERE claim_id = l_claim.claim_id;
    END IF;

    -- set the system status
    IF l_old_status_code <> l_claim.status_code THEN

       OZF_CLAIM_SETTLEMENT_PVT.settle_claim(
          p_api_version      => 1.0
         ,p_init_msg_list    => FND_API.G_FALSE
         ,p_commit           => FND_API.G_FALSE
         ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status    => l_return_status
         ,x_msg_data         => l_msg_data
         ,x_msg_count        => l_msg_count
         ,p_claim_id         => l_claim.claim_id
         ,p_curr_status      => l_prev_status_code
         ,p_prev_status      => l_old_status_code
       );
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END IF;

    -- start bug# 4363588
    -- Fetch the current claim status code
    OPEN status_code_csr(l_claim.claim_id);
    FETCH status_code_csr INTO l_curr_status_code;
    CLOSE status_code_csr;

    -- Update the claim with the user selected Close status id
    IF l_curr_status_code = 'CLOSED'  THEN
       UPDATE ozf_claims_all
       SET user_status_id = close_status_id
       WHERE claim_id = l_claim.claim_id
       AND close_status_id IS NOT NULL;
    END IF;
    -- end bug# 4363588

    --Call the create history from here only after the claim update goes successfully(uday)
    Create_Claim_History (
           p_api_version    => l_api_version
          ,p_init_msg_list  => FND_API.G_FALSE
          ,p_commit         => FND_API.G_FALSE
          ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status  => l_return_status
          ,x_msg_data       => l_msg_data
          ,x_msg_count      => l_msg_count
          ,p_claim          => l_claim
          ,p_event          => p_event
          ,x_need_to_create => l_need_to_create
          ,x_claim_history_id => l_claim_history_id
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;


    --  Create Tasks for the claim if the reason code has been changed and a history record is created.
    IF l_reason_code_changed THEN

       -- Delete the uncompleted task for this claim. The completed_flag is set to 'N'
       l_rec_num := 1;
       OPEN tasks_csr(l_claim.claim_id, 'N');
       LOOP
            FETCH tasks_csr INTO l_uncompleted_tasks_tbl(l_rec_num);
            EXIT WHEN tasks_csr%NOTFOUND;
            l_rec_num := l_rec_num + 1;
       END LOOP;
       CLOSE tasks_csr;

       For i in 1..l_uncompleted_tasks_tbl.count LOOP

           --  Leave p_object_version_number and p_delete_future_recurrences out for delete_task
           JTF_TASKS_PUB.delete_task(
               p_api_version           => l_api_version
              ,p_object_version_number => l_uncompleted_tasks_tbl(i).object_version_number
              ,p_task_id               => l_uncompleted_tasks_tbl(i).task_id
              ,p_delete_future_recurrences => FND_API.G_FALSE
              ,x_return_status         => l_return_status
              ,x_msg_count             => l_msg_count
              ,x_msg_data              => l_msg_data
           );
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
       END LOOP;

       -- point the completed tasks to claim_history. The completed_flag is set to 'Y'
       IF l_need_to_create = 'Y' THEN
          l_rec_num :=1;
          OPEN tasks_csr(l_claim.claim_id, 'Y');
          LOOP
            FETCH tasks_csr INTO l_completed_tasks_tbl(l_rec_num);
            EXIT WHEN tasks_csr%NOTFOUND;
            l_rec_num := l_rec_num + 1;
          END LOOP;
          CLOSE tasks_csr;

          For i in 1..l_completed_tasks_tbl.count LOOP
              --  change the source_object_id and source_object_type_code for the tasks.
              JTF_TASKS_PUB.update_task(
                p_api_version       => l_api_version
               ,p_object_version_number => l_completed_tasks_tbl(i).object_version_number
               ,p_init_msg_list     => FND_API.g_false
               ,p_commit            => FND_API.g_false
               ,x_return_status     => l_return_status
               ,x_msg_count         => l_msg_count
               ,x_msg_data          => l_msg_data
               ,p_task_id           => l_completed_tasks_tbl(i).task_id
               ,p_source_object_type_code =>G_CLAIM_HISTORY_TYPE
               ,p_source_object_id  => l_claim_history_id
              );

             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;
          END LOOP;
       END IF;

/*       --- Temp solution for updating the tasks
       update jtf_tasks_b
       set source_object_id =l_claim_history_id,
           source_object_type_code = G_CLAIM_HISTORY_TYPE,
           source_object_name = l_claim.claim_number
       where source_object_id = l_claim.claim_id
       and source_object_type_code = G_OBJECT_TYPE;
*/
       --  Create Tasks for the claim created if there is any
       IF (l_claim.task_template_group_id is not null and
           l_claim.task_template_group_id <> FND_API.G_MISS_NUM) THEN
           generate_tasks(
              p_task_template_group_id => l_claim.task_template_group_id
             ,p_owner_id       => l_claim.owner_id
             ,p_claim_number   => l_claim.claim_number
             ,p_claim_id       => l_claim.claim_id
             ,x_return_status  => l_return_status
           );
          IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
       END IF;
/*
       -- Temp solution for update the claim history
       update ozf_claims_history_all
       set task_source_object_id = l_claim_history_id,
           task_source_object_type_code = G_CLAIM_HISTORY_TYPE
        where task_source_object_id = l_claim.claim_id
        and   task_source_object_id = G_OBJECT_TYPE
        and   claim_id = l_claim.claim_id;

*/
       -- update the task_source_object_id and task_source_object_type in the ozf_claim_history_all table.
       IF l_need_to_create = 'Y' THEN
          l_rec_num := 1;
          OPEN claim_history_tbl_csr(l_claim.claim_id);
          LOOP
             FETCH claim_history_tbl_csr INTO l_claim_history_tbl(l_rec_num);
             EXIT WHEN claim_history_tbl_csr%NOTFOUND;
             l_rec_num := l_rec_num + 1;
          END LOOP;
          CLOSE claim_history_tbl_csr;

          For i in 1..l_claim_history_tbl.count LOOP
--           l_claim_history_rec := OZF_claims_history_PVT.claims_history_rec_type;
            l_claim_history_rec.object_version_number := l_claim_history_tbl(i).object_version_number;
            l_claim_history_rec.claim_history_id := l_claim_history_tbl(i).claim_history_id;
            l_claim_history_rec.task_source_object_id := l_claim_history_id;
            l_claim_history_rec.task_source_object_type_code := G_CLAIM_HISTORY_TYPE;

            OZF_claims_history_PVT.Update_claims_history(
               P_Api_Version_Number => 1.0,
               P_Init_Msg_List      => FND_API.G_FALSE,
               P_Commit             => FND_API.G_FALSE,
               p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               P_CLAIMS_HISTORY_Rec => l_claim_history_rec,
               X_Object_Version_Number => l_hist_obj_ver_num
            );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
          END LOOP;
       END IF;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_PVT.debug_message('Before create access');
    END IF;

    IF l_owner_changed THEN
     IF l_access_list.count > 0 THEN
       -- [BEGIN OF BUG 3835800 Fiing]
       l_access_comp_list := l_access_list;
       For i in 1..l_access_list.LAST LOOP
         IF i > 1 THEN
            FOR j IN 1..(i-1) LOOP
               IF l_access_list(i).user_or_role_id = l_access_comp_list(j).user_or_role_id THEN
                  l_dup_resource := TRUE;
               END IF;
            END LOOP;
         END IF;

         IF NOT l_dup_resource THEN
         -- [END OF BUG 3835800 Fiing]
           l_access_list(i).act_access_to_object_id := l_claim.claim_id;
           ams_access_pvt.create_access(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_validation_level => p_validation_level
              ,x_return_status => l_return_status
              ,x_msg_count => x_msg_count
              ,x_msg_data => x_msg_data
              ,p_commit => fnd_api.g_false
              ,p_access_rec => l_access_list(i)
              ,x_access_id => l_access_id);
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;
         END IF; -- end of l_dup_resource checking BUG  3835800 Fiing
       END LOOP;
     END IF;
    END IF;

   -------------------------------------------------
   -- Raise Business Event (claim status change ) --
   -------------------------------------------------
   IF l_old_status_code <> l_claim.status_code THEN
      OZF_CLAIM_SETTLEMENT_PVT.Raise_Business_Event(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count

         ,p_claim_id               => l_claim.claim_id
         ,p_old_status             => l_old_status_code
         ,p_new_status             => l_claim.status_code
         ,p_event_name             => 'oracle.apps.ozf.claim.updateStatus'
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;





    -- pass the new version number
    x_object_version_number := l_object_version_number;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
--        IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Update_Claim_PVT;
--        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 --       IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Update_Claim_PVT;
 --       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
 --       IF ( NOT G_UPDATE_CALLED ) THEN
           ROLLBACK TO  Update_Claim_PVT;
 --       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
--
END Update_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim
--
-- PURPOSE
--    Validate a claim code record.
--
-- PARAMETERS
--    p_claim : the claim code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Claim (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_claim                 IN  claim_rec_type
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Claim';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status varchar2(30);
l_Error_Msg         varchar2(2000);
l_Error_Token       varchar2(80);
l_claim             claim_rec_type := p_claim;
l_return_status     varchar2(30);

-- Fix for bug 5374006
CURSOR party_csr(p_cust_id in number,
                 p_relation_type in varchar2,
                 p_party_id in number) IS
SELECT count(p.party_id)
FROM   hz_parties p,
       hz_relationships r,
       hz_cust_accounts c
WHERE  p.party_id = r.subject_id
AND    r.relationship_code = p_relation_type
AND    r.object_id = c.party_id
AND    c.cust_account_id = p_cust_id
AND    p.party_id = p_party_id;

l_count number := 0;

CURSOR cust_site_csr(p_cust_id in number,
                     p_site_use_code in varchar2,
                     p_site_use_id in number) IS
SELECT count(hcsu.site_use_id)
FROM   hz_cust_accounts hca,
       hz_cust_acct_sites hcas,
       hz_cust_site_uses hcsu
WHERE  hcas.cust_acct_site_id = hcsu.cust_acct_site_id
AND    hcas.cust_account_id = hca.cust_account_id
AND    hcsu.status = 'A'
AND    hca.cust_account_id = p_cust_id
AND    hcsu.site_use_code = p_site_use_code
AND    hcsu.site_use_id = p_site_use_id;

-- Add cursor for matching actions and task.
CURSOR action_count_csr(p_reason_code_id in number,
                        p_task_template_id in number) IS
SELECT count(t.task_template_group_id)
FROM jtf_task_temp_groups_vl t,
     ozf_reasons r
WHERE t.source_object_type_code = 'OZF_CLAM'
AND r.active_flag = 'T'
AND t.task_template_group_id = r.task_template_group_id
AND NVL(t.start_date_active, SYSDATE) <= SYSDATE
AND NVL(t.end_date_active, SYSDATE) >= SYSDATE
AND r.reason_code_id = p_reason_code_id
AND r.task_template_group_id = p_task_template_id;

CURSOR status_count_csr(p_status_code    in varchar2,
                        p_user_status_id in number) IS
SELECT count(user_status_id)
FROM   ams_user_statuses_vl
WHERE  system_status_type = G_CLAIM_STATUS
AND    system_status_code = p_status_code
AND    user_status_id = p_user_status_id
AND    enabled_flag = 'Y';

CURSOR sales_rep_num_csr (p_id in NUMBER) IS
SELECT count(salesrep_id)
FROM   jtf_rs_salesreps s,
       jtf_rs_resource_extns r,
       fnd_lookups l
WHERE  s.start_date_active <= SYSDATE
AND NVL(s.end_date_active, SYSDATE) >= SYSDATE
AND s.salesrep_id = p_id
AND s.resource_id = r.resource_id
AND r.category = l.lookup_code
AND l.lookup_type ='JTF_RS_RESOURCE_CATEGORY';

l_sales_rep_num number := 0;

-- cursor to check payment_method
CURSOR payment_method_csr (p_lookup_code in VARCHAR) IS
SELECT count(lookup_code)
FROM ozf_lookups
WHERE lookup_type = 'OZF_PAYMENT_METHOD'
AND   lookup_code = p_lookup_code;

l_lookup_code_count  number := 0;

CURSOR order_type_count_csr(p_id in number) is
SELECT count(transaction_type_id)
FROM oe_transaction_types_vl
WHERE transaction_type_code = 'ORDER'
AND order_category_code IN ('MIXED', 'RETURN')
AND default_inbound_line_type_id IS NOT NULL
AND transaction_type_id = p_id;

l_order_type_count number :=0;

CURSOR rel_cust_csr(p_cust_id IN NUMBER, p_rel_cust_id IN NUMBER) IS
SELECT count(related_cust_account_id)
FROM   hz_cust_acct_relate_all
WHERE  cust_account_id = p_cust_id
AND    related_cust_account_id = p_rel_cust_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Validate_Claim_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
       Check_Claim_Items(
          p_claim_rec         => l_claim,
          p_validation_mode   => JTF_PLSQL_API.g_update,
          x_return_status     => l_return_status
       );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    -- Raise an error
    -- Due_date must be later than the claim_date
    IF trunc(l_claim.DUE_DATE) < trunc(l_claim.claim_date) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUE_DATE_ERR');
             FND_MSG_PUB.add;
          END IF;
          IF OZF_DEBUG_HIGH_ON THEN
             ozf_utility_PVT.debug_message('claim date: ' || l_claim.claim_date);
             ozf_utility_PVT.debug_message('due date: ' || l_claim.DUE_DATE);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Raise an error
    -- if the current status code is not duplicate but the duplicate_claim_id is not null
    IF ((l_claim.status_code <> G_DUPLICATE_STATUS) AND
       (l_claim.duplicate_claim_id is not null) AND
       (l_claim.duplicate_claim_id <> FND_API.G_MISS_NUM)) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CANT_DUP');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Raise an error
    -- if billto_site and shipto_site do not belong to the customer
    IF (l_claim.cust_account_id is not null AND
        l_claim.cust_account_id <> FND_API.G_MISS_NUM) THEN

        -- check cust_billto_acct_site_id
        IF (l_claim.cust_billto_acct_site_id is not null AND
            l_claim.cust_account_id <> FND_API.G_MISS_NUM) THEN

           OPEN cust_site_csr(l_claim.cust_account_id, 'BILL_TO', l_claim.cust_billto_acct_site_id);
           FETCH cust_site_csr INTO l_count;
           CLOSE cust_site_csr;

           IF (l_count = 0) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_BILL_TO_ST_WRNG');
                 FND_MSG_PUB.Add;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

      -- 4334023: check for unrelated shipto if profile does not allow unrelated
      IF l_claim.ship_to_cust_account_id IS NOT NULL AND G_ALLOW_UNREL_SHIPTO_FLAG = 'N'
              AND l_claim.ship_to_cust_account_id  <>  l_claim.cust_account_id THEN
          l_count := 0;
            OPEN rel_cust_csr(l_claim.cust_account_id, l_claim.ship_to_cust_account_id);
            FETCH rel_cust_csr INTO l_count;
            CLOSE rel_cust_csr;

            IF (l_count = 0) THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_UNRELATED_SHIPTO');
                  FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
      END IF;

    -- Bug 5498540 -- Removed validation for SHIP_TO Site address
        -- check cust_shipto_acct_site_id
  /*IF (l_claim.cust_shipto_acct_site_id is not null AND
            l_claim.cust_shipto_acct_site_id <> FND_API.G_MISS_NUM) THEN

            l_count := 0;
            OPEN cust_site_csr(l_claim.ship_to_cust_account_id, 'SHIP_TO', l_claim.cust_shipto_acct_site_id);
            FETCH cust_site_csr INTO l_count;
            CLOSE cust_site_csr;

            IF (l_count = 0) THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_SHIP_TO_ST_WRNG');
                  FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF; */

/* phase out this check since

        -- check contact_id
        IF (l_claim.contact_id is not null AND
            l_claim.contact_id <> FND_API.G_MISS_NUM) THEN

            l_count := 0;
            OPEN party_csr(l_claim.cust_account_id, 'CONTACT_OF', l_claim.contact_id);
            FETCH party_csr INTO l_count;
            CLOSE party_csr;

            IF (l_count = 0) THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CONTACT_WRNG');
                  FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
 -- end of phase out this check */

        -- check broker_id
        IF (l_claim.broker_id is not null AND
            l_claim.broker_id <> FND_API.G_MISS_NUM) THEN

            l_count := 0;
            OPEN party_csr(l_claim.cust_account_id, 'BROKER_OF', l_claim.broker_id);
            FETCH party_csr INTO l_count;
            CLOSE party_csr;

            IF (l_count = 0) THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_BROKER_WRNG');
                  FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        -- check sales_rep
    -- 04-MAR-2002 mchang updated: comment out the following section to avoid the sales_rep_id checking
    --   since the sales_rep_id might not be valied over time when claim is updated.
    /*
          IF (l_claim.sales_rep_id is not NULL AND
            l_claim.sales_rep_id <> FND_API.G_MISS_NUM) THEN
            OPEN sales_rep_num_csr(l_claim.sales_rep_id);
            FETCH sales_rep_num_csr INTO l_sales_rep_num;
            CLOSE sales_rep_num_csr;

            IF l_sales_rep_num = 0 THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SALES_REP_MISSING');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
       END IF;
     */

    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CUST_ID_MISSING');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- 04-MAR-2002 mchang updated: comment out the following section to avoid the status code checking
    --   since the status_code and user_status_id mathing is done from the on-line screen already.
    /*
    l_count := 0;
    -- Check whether status_code and user_status_id matches
    -- Note: Neither Status_code nor user_status_id of a claim can be null at any given time
    OPEN status_count_csr(l_claim.status_code, l_claim.user_status_id);
    FETCH status_count_csr INTO l_count;
    CLOSE status_count_csr;

    IF l_count <> 1 THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_STATUS_NOT_MAT');
          FND_MSG_PUB.Add;

           FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT','code: '||l_claim.status_code||' id:'||l_claim.user_status_id);
        FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    -- Check to see whether the reason_code_id and task_template_id matches.
    -- 04-MAR-2002 mchang updated: comment out the following section to avoid the reason_code_id and reason_code_id checking
    --   since the reason_code_id and reason_code_id might not be valied over time when the claim is updated.
    /*
    IF l_claim.reason_code_id is not null AND l_claim.reason_code_id <> FND_API.G_MISS_NUM AND
       l_claim.task_template_group_id is not null AND l_claim.task_template_group_id <> FND_API.G_MISS_NUM THEN
       l_count := 0;

       OPEN action_count_csr(l_claim.reason_code_id, l_claim.task_template_group_id);
       FETCH action_count_csr INTO l_count;
       CLOSE action_count_csr;

       IF l_count <> 1 THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_ACTION_NOT_MAT');
             FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    */

   -- raise an error if owner_id is not found
   IF (l_claim.owner_id is null OR
       l_claim.owner_id = FND_API.G_MISS_NUM) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_OWNER_NOT_FOUND');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- raise an error if status_code is open and amount_remaining is 0
   IF (l_claim.status_code = G_OPEN_STATUS AND
       l_claim.amount_remaining = 0) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_AMT_ZERO_WOPEN');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- raise an error if amount is <0 and claim_class = Claim or DEDUCTION
   -- raise an error if amount is >0 and claim_class = OVERPAYMENT or charge
   IF (l_claim.amount < 0 AND
       (l_claim.claim_class = G_CLAIM_CLASS OR
        l_claim.claim_class = G_DEDUCTION_CLASS)) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_AMT_NEG');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_claim.amount > 0 AND
       (l_claim.claim_class = G_OVERPAYMENT_CLASS OR
        l_claim.claim_class = G_CHARGE_CLASS )) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_AMT_POS_OPM');
          FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- if source_object_id is set, all info about source_object has to be set
   IF (l_claim.claim_class = G_DEDUCTION_CLASS AND
       (l_claim.source_object_id IS NOT NULL AND
       l_claim.source_object_id <> FND_API.G_MISS_NUM)) THEN

      IF ((l_claim.source_object_class IS NULL OR
           l_claim.source_object_class = FND_API.G_MISS_CHAR) OR
          (l_claim.source_object_type_id IS NULL OR
           l_claim.source_object_type_id = FND_API.G_MISS_NUM) OR
          (l_claim.source_object_number IS NULL OR
           l_claim.source_object_number = FND_API.G_MISS_CHAR)) THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SRC_INFO_MISSING');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- check payment_method
   IF l_claim.payment_method IS NOT NULL AND
      l_claim.payment_method <> FND_API.G_MISS_CHAR THEN

       OPEN payment_method_csr(l_claim.payment_method);
       FETCH payment_method_csr into l_lookup_code_count;
       CLOSE payment_method_csr;

       IF l_lookup_code_count = 0 THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_PAY_MTHD_WRG');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- check pay_related_account_flag
   IF (l_claim.pay_related_account_flag IS NOT NULL AND
       l_claim.pay_related_account_flag <> FND_API.G_MISS_CHAR) THEN

      IF (l_claim.pay_related_account_flag <> 'F' AND
          l_claim.pay_related_account_flag <> 'T') THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_PAY_REL_FLG_WRG');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- check order_type_id
   IF (l_claim.order_type_id IS NOT NULL AND
       l_claim.order_type_id <> FND_API.G_MISS_NUM) THEN

       OPEN order_type_count_csr(l_claim.order_type_id);
       FETCH order_type_count_csr into l_order_type_count;
       CLOSE order_type_count_csr;
       IF l_order_type_count = 0 then
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ODTYPE_WRG');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
       FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Validate_Claim_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Validate_Claim_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Validate_Claim_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Validate_Claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Common_Element
--
-- PURPOSE
--    The precedure does validations on claim elements that was not enforced by UI at claim creation.
--    These elements are: claim_type_id, reason_code_id, cust_account_id
--    It should only be called when either of the above field are not mendatory from the inputs.
--
-- PARAMETERS
--    p_validate_claim : the claim code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Check_Claim_Common_Element (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_claim                  IN  claim_rec_type
   ,x_claim                  OUT NOCOPY claim_rec_type
   ,p_mode                   IN  VARCHAR2 := OZF_claim_Utility_pvt.G_AUTO_MODE
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Check_Claim_Common_Element';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_claim             claim_rec_type := p_claim;
l_resource_id       number;
l_user_id           number;
l_login_user_id     number;
l_login_user_status varchar2(30);
l_Error_Msg         varchar2(2000);
l_Error_Token       varchar2(80);
l_return_status     varchar2(30);

--CURSOR claim_type_id_csr IS
--SELECT claim_type_id
--FROM   ozf_sys_parameters;

-- This cursor checks whether a given claim_type_id is of deduction class.
-- and whether it is in the database.
--CURSOR number_of_claim_type_id_csr(p_claim_type_id in number) IS
--SELECT count(claim_type_id)
--FROM   ozf_claim_types_all_b
--WHERE  claim_type_id = p_claim_type_id;

--l_number_of_claim_type_id  NUMBER;

--CURSOR reason_code_id_csr IS
--SELECT reason_code_id
--FROM   ozf_sys_parameters;

-- This cursor checks whether a given reason_type is in the database
--CURSOR number_of_reason_code_id_csr(p_reason_code_id in number) IS
--SELECT count(reason_code_id)
--FROM   ozf_reason_codes_all_b
--WHERE  reason_code_id = p_reason_code_id;

--l_number_of_reason_code_id number;

CURSOR num_of_cust_acctid_csr(l_id in number) IS
SELECT count(hca.cust_account_id)
FROM  hz_cust_accounts hca
WHERE hca.cust_account_id = l_id;
-- remove this condition for now AND hca.status = 'A'

l_number_of_cust number;

BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  Check_Clm_Cmn_Element_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Begin of  minimum required data for claims in general.
    -- We will check: claim_type_id, reason_code_id

-- 11.5.10(uday) Removed check for Claim type id and Reason code id
-- as these values are defaulted from Claim Defaults.
    -- Check claim_type_id
--    IF l_claim.claim_type_id is NULL OR
--       l_claim.claim_type_id = FND_API.G_MISS_NUM  THEN

--      OPEN claim_type_id_csr;
--      FETCH claim_type_id_csr into l_claim.claim_type_id;
--      CLOSE claim_type_id_csr;
--      IF l_claim.claim_type_id is NULL THEN
--         IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
--            FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CLAIM_TYPE_MISSING');
--            FND_MSG_PUB.Add;
--       END IF;
--       RAISE FND_API.G_EXC_ERROR;
--      END IF;
--   ELSE
--      -- check whether the claim_type_id is in the database.
--      OPEN number_of_claim_type_id_csr(l_claim.claim_type_id);
--      FETCH number_of_claim_type_id_csr INTO l_number_of_claim_type_id;
--      CLOSE number_of_claim_type_id_csr;
--
--      IF l_number_of_claim_type_id = 0 THEN
--         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CLAIM_TYPE_NOT_IN_DB');
--            FND_MSG_PUB.add;
--         END IF;
--         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--      END IF;
--   END IF;

--   -- Check reason_code_id
--   IF l_claim.reason_code_id is NULL OR
--      l_claim.reason_code_id = FND_API.G_MISS_NUM  THEN

--   ELSE
      -- check whether reason code exists
--      OPEN number_of_reason_code_id_csr(l_claim.reason_code_id);
--      FETCH number_of_reason_code_id_csr INTO l_number_of_reason_code_id;
--      CLOSE number_of_reason_code_id_csr;

--      IF l_number_of_reason_code_id = 0 THEN
--         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
--            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_REASON_CD_NOT_IN_DB');
--            FND_MSG_PUB.add;
--         END IF;
--         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--      END IF;
--   END IF;

   -- Check cust_account_id
   IF l_claim.cust_account_id is NULL OR
      l_claim.cust_account_id = FND_API.G_MISS_NUM  THEN

      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_CUST_ID_MISSING');
            FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      -- check whether the customer is in the database.
      OPEN num_of_cust_acctid_csr(l_claim.cust_account_id);
      FETCH num_of_cust_acctid_csr INTO l_number_of_cust;
      CLOSE num_of_cust_acctid_csr;

      IF l_number_of_cust = 0 THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CUST_NOT_IN_DB');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   -- End of minimum checking

   -- -----------------------------------------------------------
   -- Bug        : 2710047
   -- Changed by : Uday Poluri          Date: 28-May-2003
   -- Comments   : Call get_write_off_eligibility flag
   -- -----------------------------------------------------------

      IF (p_mode = OZF_claim_Utility_pvt.G_AUTO_MODE)
      THEN
         get_write_off_eligibility( p_cust_account_id  => l_claim.cust_account_id
                                  , px_currency_code  => l_claim.currency_code
                                  , px_exchange_rate_type => l_claim.exchange_rate_type
                                  , px_exchange_rate_date => l_claim.exchange_rate_date
                                  , p_exchange_rate => l_claim.exchange_rate
                                  , p_set_of_books_id => l_claim.set_of_books_id
                                  , p_amount => l_claim.amount
                                  , px_acctd_amount => l_claim.acctd_amount
                                  , px_acctd_amount_remaining => l_claim.acctd_amount_remaining
                                  , x_write_off_flag => l_claim.write_off_flag
                                  , x_write_off_threshold_amount => l_claim.write_off_threshold_amount
                                  , x_under_write_off_threshold => l_claim.under_write_off_threshold
                                   ,x_return_status => l_return_status);
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;
   -- -----------------------------------------------------------
   -- End of Bug  : 2710047
   -- -----------------------------------------------------------

   x_claim := l_claim;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Check_Clm_Cmn_Element_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Check_Clm_Cmn_Element_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Check_Clm_Cmn_Element_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Check_Claim_Common_Element;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_tbl
--
-- PURPOSE
--    Create mutiple claims at one time.
--
-- PARAMETERS
--    p_claim_tbl     : the new record to be inserted
--
-- NOTES: for all the claims to be created
--    1. object_version_number will be set to 1.
--    2. If claim_number is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
---------------------------------------------------------------------
PROCEDURE  Create_Claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_tbl              IN    claim_tbl_type
   ,x_error_index            OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Claim_tbl';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_claim             claim_rec_type;
l_x_claim           claim_rec_type;
l_msg_data         varchar2(2000);
l_Msg_count         number;
l_Error_Token       varchar2(80);
l_return_status     varchar2(30);
l_mode              varchar2(30) := OZF_claim_Utility_pvt.G_MANU_MODE;

l_default_curr_code varchar2(30):= fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');
l_claim_id number;
l_err_row number:=0;
BEGIN
   -- Standard begin of API savepoint
    SAVEPOINT  Create_Claim_Tbl_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    x_error_index := -1;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    For i in 1..p_claim_tbl.count LOOP

            l_claim := p_claim_tbl(i);

            -- default claim_type_id, reason_code_id if necessary.
            OZF_claim_PVT.Check_Claim_Common_Element (
          p_api_version      => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_Return_Status      => l_return_status,
          x_Msg_Count          => l_msg_count,
          x_Msg_Data           => l_msg_data,
          p_claim              => l_claim,
          x_claim              => l_x_claim,
          p_mode               => l_mode
         );
      -- Check return status from the above procedure call
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         x_error_index := i;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         x_error_index := i;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_claim := l_x_claim;

           -- default currency code if necessary.
      -- Default the transaction currency code to functional currency code
      -- if it's null.
      IF (l_claim.currency_code is NULL OR
          l_claim.currency_code = FND_API.G_MISS_CHAR)THEN
          l_claim.currency_code := l_default_curr_code;
      END IF;

--              l_claim.claim_class := G_CLAIM_CLASS;
      --
      -- Calling Private package: Create_claim
      -- Hint: Primary key needs to be returned
      OZF_claim_PVT.Create_Claim(
         P_Api_Version        => 1.0,
         P_Init_Msg_List      => FND_API.G_FALSE,
         P_Commit             => FND_API.G_FALSE,
         P_Validation_Level   => FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status      => l_return_status,
         X_Msg_Count          => l_msg_count,
         X_Msg_Data           => l_msg_data,
         P_claim              => l_claim,
         X_CLAIM_ID           => l_claim_id
      );

      -- Check return status from the above procedure call
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         x_error_index := i;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         x_error_index := i;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

         END LOOP;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
/*      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add;
        END IF;
*/
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*      IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add;
        END IF;
*/
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
*/        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Create_Claim_tbl;




---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_tbl
--
-- PURPOSE
--    Update mutiple claims at one time from summary screen.
--
-- PARAMETERS
--    p_claim_tbl     : the new record to be inserted
--
-- NOTES: for all the claims to be created
--    1. object_version_number will be set to 1.
--    2. If claim_number is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--
-- BUG         : 2732290
-- CHANAGED BY : (Uday Poluri)
-- COMMENTS    : New procedure to Update claim details from Claim Summary Screen
--
---------------------------------------------------------------------
PROCEDURE  Update_Claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,p_claim_tbl              IN    claim_tbl_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Claim_tbl';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--l_object_version_number  number := 1;
l_object_version_number  number;
--
l_claim             claim_rec_type;
l_msg_data          varchar2(2000);
l_Msg_count         number;
l_Error_Token       varchar2(80);
l_return_status     varchar2(30);

l_default_curr_code varchar2(30):= fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');
l_claim_id number;
l_err_row number:=0;
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Update_Claim_Tbl_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
     FND_MSG_PUB.Add;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   For i in 1..p_claim_tbl.count LOOP
     l_claim := p_claim_tbl(i);

     -- Varify status code if NOT OPEN then raise error.
     IF upper(l_claim.status_code) <> 'OPEN' then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         l_err_row := i;
         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_API_NO_OPEN_STATUS');
         FND_MESSAGE.Set_Token('ROW',l_err_row);
         FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- If incoming value for write-off flag is unchecked then set the values in database is 'N'.
     IF (l_claim.write_off_flag is NULL OR
       l_claim.write_off_flag = FND_API.G_MISS_CHAR)THEN
       l_claim.write_off_flag := 'F';
     END IF;

     -- Calling Private package: Update_claim
     OZF_claim_PVT.Update_Claim (
          p_api_version       => l_api_version
         ,p_init_msg_list     => FND_API.G_FALSE
         ,p_commit            => FND_API.G_FALSE
         ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status     => l_return_status
         ,x_msg_data          => l_msg_data
         ,x_msg_count         => l_msg_count
         ,p_claim             => l_claim
         ,p_event             => 'UPDATE'
         ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
         ,x_object_version_number  => l_object_version_number
       );

     IF l_return_status = FND_API.g_ret_sts_error THEN
       l_err_row := i;
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       l_err_row := i;
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
     FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add;
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add;
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Claim_Tbl_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_TBL_ERR');
           FND_MESSAGE.Set_Token('ROW',l_err_row);
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Update_Claim_tbl;
-- --End Bug: 2732290 -----------------------------------------

END OZF_CLAIM_PVT;

/
